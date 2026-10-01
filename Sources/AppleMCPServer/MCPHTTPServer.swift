import AppleMCPAdapter
import ArgumentParser
import Foundation
import HTTPTypes
import Hummingbird
import MCP

struct MCPHTTPServerConfiguration: Sendable {
  static let defaultMaxBodyBytes = 4 * 1_024 * 1_024

  let host: String
  let port: Int
  let path: String
  let bearerToken: String?
  let sessionTimeoutSeconds: Int
  let maxSessions: Int
  let maxBodyBytes: Int

  init(
    host: String,
    port: Int,
    path: String,
    allowNonLoopback: Bool,
    tokenEnvironmentVariable: String?,
    sessionTimeoutSeconds: Int,
    maxSessions: Int,
    maxBodyBytes: Int = Self.defaultMaxBodyBytes,
    environment: [String: String]
  ) throws {
    guard (1...65_535).contains(port) else {
      throw ValidationError("`--port` must be between 1 and 65535.")
    }
    guard path.hasPrefix("/"), !path.contains("?"), !path.contains("#") else {
      throw ValidationError(
        "`--path` must start with `/` and must not contain query or fragment text.")
    }
    guard sessionTimeoutSeconds > 0 else {
      throw ValidationError("`--session-timeout-seconds` must be greater than 0.")
    }
    guard maxSessions > 0 else {
      throw ValidationError("`--max-sessions` must be greater than 0.")
    }
    guard maxBodyBytes > 0 else {
      throw ValidationError("Maximum request body size must be greater than 0.")
    }

    let token: String?
    if let tokenEnvironmentVariable {
      guard !tokenEnvironmentVariable.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        throw ValidationError("`--token-env` must name a non-empty environment variable.")
      }
      guard let value = environment[tokenEnvironmentVariable], !value.isEmpty else {
        throw ValidationError("`--token-env` points to an empty or missing environment variable.")
      }
      token = value
    } else {
      token = nil
    }

    let loopback = Self.isLoopback(host)
    if !loopback {
      guard allowNonLoopback else {
        throw ValidationError("Non-loopback HTTP serving requires `--allow-non-loopback`.")
      }
      guard token != nil else {
        throw ValidationError("Non-loopback HTTP serving requires `--token-env`.")
      }
    }

    self.host = host
    self.port = port
    self.path = path
    self.bearerToken = token
    self.sessionTimeoutSeconds = sessionTimeoutSeconds
    self.maxSessions = maxSessions
    self.maxBodyBytes = maxBodyBytes
  }

  var isLoopback: Bool {
    Self.isLoopback(host)
  }

  private static func isLoopback(_ host: String) -> Bool {
    ["127.0.0.1", "localhost", "::1", "[::1]"].contains(host)
  }
}

@available(macOS 14.0, *)
struct MCPHTTPServer: Sendable {
  let configuration: MCPHTTPServerConfiguration
  let adapter: AppleMCPAdapter

  func run() async throws {
    let sessions = MCPHTTPSessionManager(configuration: configuration, adapter: adapter)
    let router = Router()
    let endpoint = RouterPath(configuration.path)

    router.on(endpoint, method: .post) { request, _ in
      var request = request
      return await sessions.handle(request: &request)
    }
    router.on(endpoint, method: .get) { request, _ in
      var request = request
      return await sessions.handle(request: &request)
    }
    router.on(endpoint, method: .delete) { request, _ in
      var request = request
      return await sessions.handle(request: &request)
    }

    let application = Application(
      router: router,
      configuration: .init(
        address: .hostname(configuration.host, port: configuration.port),
        serverName: "apple-cli-mcp"
      )
    )
    try await application.runService()
  }
}

@available(macOS 14.0, *)
actor MCPHTTPSessionManager {
  private struct Session {
    let server: Server
    let transport: StatefulHTTPServerTransport
    var lastAccessedAt: Date
  }

  private let configuration: MCPHTTPServerConfiguration
  private let adapter: AppleMCPAdapter
  private let validationPipeline: any HTTPRequestValidationPipeline
  private var sessions: [String: Session] = [:]
  private var initializingSessions = 0

  init(configuration: MCPHTTPServerConfiguration, adapter: AppleMCPAdapter) {
    self.configuration = configuration
    self.adapter = adapter
    self.validationPipeline = Self.makeValidationPipeline(configuration: configuration)
  }

  func handle(request: inout Request) async -> Response {
    await cleanupExpiredSessions()

    let mcpRequest: MCP.HTTPRequest
    do {
      mcpRequest = try await makeMCPRequest(from: &request)
    } catch {
      return makeResponse(
        from: .error(
          statusCode: 413,
          .invalidRequest(
            "Payload Too Large: request body exceeds \(configuration.maxBodyBytes) bytes")
        )
      )
    }

    let mcpResponse = await handle(mcpRequest)
    return makeResponse(from: mcpResponse)
  }

  private func handle(_ request: MCP.HTTPRequest) async -> MCP.HTTPResponse {
    let method = request.method.uppercased()
    if let sessionID = request.header(HTTPHeaderName.sessionID) {
      guard var session = sessions[sessionID] else {
        return .error(statusCode: 404, .invalidRequest("Not Found: Session not found or expired"))
      }

      session.lastAccessedAt = Date()
      sessions[sessionID] = session
      let response = await session.transport.handleRequest(request)

      if method == "DELETE", response.statusCode == 200 {
        await closeSession(sessionID)
      }
      return response
    }

    guard method == "POST" else {
      return .error(
        statusCode: 400,
        .invalidRequest("Bad Request: Missing \(HTTPHeaderName.sessionID) header")
      )
    }

    guard sessions.count + initializingSessions < configuration.maxSessions else {
      return .error(
        statusCode: 503,
        .internalError("Too many active MCP HTTP sessions")
      )
    }

    // Reserve capacity before SDK actor calls can admit another initialization.
    initializingSessions += 1
    defer { initializingSessions -= 1 }

    let transport = StatefulHTTPServerTransport(validationPipeline: validationPipeline)
    let server = await AppleMCPServerRuntime.makeServer(adapter: adapter)

    do {
      try await server.start(transport: transport)
    } catch {
      await transport.disconnect()
      return .error(statusCode: 500, .internalError("Failed to start MCP session: \(error)"))
    }

    let response = await transport.handleRequest(request)
    if response.statusCode == 200, let sessionID = response.headers[HTTPHeaderName.sessionID] {
      sessions[sessionID] = Session(server: server, transport: transport, lastAccessedAt: Date())
    } else {
      await transport.disconnect()
    }
    return response
  }

  private func closeSession(_ sessionID: String) async {
    guard let session = sessions.removeValue(forKey: sessionID) else {
      return
    }
    await session.transport.disconnect()
  }

  private func cleanupExpiredSessions() async {
    let now = Date()
    let expired = sessions.compactMap { sessionID, session -> String? in
      let age = now.timeIntervalSince(session.lastAccessedAt)
      return age > TimeInterval(configuration.sessionTimeoutSeconds) ? sessionID : nil
    }
    for sessionID in expired {
      await closeSession(sessionID)
    }
  }

  private func makeMCPRequest(from request: inout Request) async throws -> MCP.HTTPRequest {
    let buffer = try await request.collectBody(upTo: configuration.maxBodyBytes)
    let body: Data? =
      if buffer.readableBytes == 0 {
        nil
      } else {
        Data(buffer.readableBytesView)
      }

    var headers: [String: String] = [:]
    for field in request.headers {
      if let existing = headers[field.name.rawName] {
        headers[field.name.rawName] = "\(existing), \(field.value)"
      } else {
        headers[field.name.rawName] = field.value
      }
    }

    return MCP.HTTPRequest(
      method: request.method.rawValue,
      headers: headers,
      body: body,
      path: request.uri.path
    )
  }

  private func makeResponse(from response: MCP.HTTPResponse) -> Response {
    let status = HTTPTypes.HTTPResponse.Status(code: response.statusCode)
    let headers = makeHeaders(response.headers)

    switch response {
    case .stream(let stream, _):
      let body = ResponseBody { writer in
        let allocator = ByteBufferAllocator()
        for try await chunk in stream {
          var buffer = allocator.buffer(capacity: chunk.count)
          buffer.writeBytes(chunk)
          try await writer.write(buffer)
        }
        try await writer.finish(nil)
      }
      return Response(status: status, headers: headers, body: body)

    default:
      guard let data = response.bodyData else {
        return Response(status: status, headers: headers)
      }
      var buffer = ByteBufferAllocator().buffer(capacity: data.count)
      buffer.writeBytes(data)
      return Response(status: status, headers: headers, body: .init(byteBuffer: buffer))
    }
  }

  private func makeHeaders(_ headers: [String: String]) -> HTTPFields {
    var fields = HTTPFields()
    for (name, value) in headers {
      guard let fieldName = HTTPField.Name(name) else {
        continue
      }
      fields[fieldName] = value
    }
    return fields
  }

  private static func makeValidationPipeline(
    configuration: MCPHTTPServerConfiguration
  ) -> any HTTPRequestValidationPipeline {
    var validators: [any HTTPRequestValidator] = [
      configuration.isLoopback
        ? OriginValidator.localhost(port: configuration.port) : OriginValidator.disabled
    ]

    if let bearerToken = configuration.bearerToken {
      validators.append(
        BearerTokenValidator(
          resourceMetadataURL: resourceMetadataURL(configuration: configuration),
          resourceIdentifier: resourceIdentifier(configuration: configuration),
          tokenValidator: { token, _, _ in
            constantTimeEquals(token, bearerToken)
              ? .valid(BearerTokenInfo())
              : .invalidToken(errorDescription: "Token did not match")
          }
        )
      )
    }

    validators.append(AcceptHeaderValidator(mode: .sseRequired))
    validators.append(ContentTypeValidator())
    validators.append(ProtocolVersionValidator())
    validators.append(SessionValidator())
    return StandardValidationPipeline(validators: validators)
  }

  private static func resourceIdentifier(configuration: MCPHTTPServerConfiguration) -> URL {
    URL(string: "http://\(urlHost(configuration.host)):\(configuration.port)")!
  }

  private static func resourceMetadataURL(configuration: MCPHTTPServerConfiguration) -> URL {
    resourceIdentifier(configuration: configuration)
      .appendingPathComponent(".well-known")
      .appendingPathComponent("oauth-protected-resource")
  }

  private static func urlHost(_ host: String) -> String {
    if host == "::1" {
      return "[::1]"
    }
    return host
  }

  private static func constantTimeEquals(_ lhs: String, _ rhs: String) -> Bool {
    let left = Array(lhs.utf8)
    let right = Array(rhs.utf8)
    let count = max(left.count, right.count)
    var difference = left.count ^ right.count
    for index in 0..<count {
      let leftByte = index < left.count ? left[index] : 0
      let rightByte = index < right.count ? right[index] : 0
      difference |= Int(leftByte ^ rightByte)
    }
    return difference == 0
  }
}
