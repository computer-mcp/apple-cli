import AppleMCPAdapter
import Darwin
import Foundation
import MCP
import Testing
import Utility

#if canImport(System)
  import System
#else
  @preconcurrency import SystemPackage
#endif

// Each case stages and launches real executables; concurrent requests stay inside their test.
@Suite(.serialized)
struct MCPExecutableTests {
  @Test(.timeLimit(.minutes(1)))
  func mcpStdioExecutableBlackBoxRunsCliThroughSdkClient() async throws {
    let installation = try stagedMCPInstallation(separateCLI: false)
    defer { try? FileManager.default.removeItem(at: installation.root) }
    let process = Process()
    let stdin = Pipe()
    let stdout = Pipe()
    let stderr = Pipe()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["apple-cli-mcp", "stdio"]
    process.currentDirectoryURL = installation.root
    var environment = ProcessInfo.processInfo.environment
    environment.removeValue(forKey: "APPLE_CLI_BIN_DIR")
    let aliases = installation.root.appendingPathComponent("aliases", isDirectory: true)
    try FileManager.default.createDirectory(at: aliases, withIntermediateDirectories: false)
    try FileManager.default.createSymbolicLink(
      at: aliases.appendingPathComponent("apple-cli-mcp"), withDestinationURL: installation.server)
    environment["PATH"] = aliases.path + ":/usr/bin:/bin"
    process.environment = environment
    process.standardInput = stdin
    process.standardOutput = stdout
    process.standardError = stderr

    try process.run()
    defer {
      stopTestProcess(process)
      try? stdin.fileHandleForWriting.close()
      try? stdout.fileHandleForReading.close()
      try? stderr.fileHandleForReading.close()
    }

    let transport = StdioTransport(
      input: FileDescriptor(rawValue: stdout.fileHandleForReading.fileDescriptor),
      output: FileDescriptor(rawValue: stdin.fileHandleForWriting.fileDescriptor)
    )
    let client = Client(name: "apple-cli-stdio-tests", version: "1.0")
    let initializeResult = try await client.connect(transport: transport)

    #expect(initializeResult.serverInfo.name == "apple-cli-mcp")
    #expect(initializeResult.serverInfo.version == CLIVersion.current)
    #expect(initializeResult.capabilities.tools != nil)

    let (tools, _) = try await client.listTools()
    #expect(
      tools.map(\.name) == [
        "apple_cli_list_targets",
        "apple_cli_doctor",
        "apple_cli_status",
        "apple_cli_help",
        "apple_cli_command_catalog",
        "apple_cli_run",
      ])

    let listTargets: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_list_targets",
      arguments: [:]
    )
    let result = try await listTargets.value
    #expect(result.isError == false)
    let object = try #require(result.structuredContent?.objectValue)
    let targets = try #require(object["targets"]?.arrayValue).compactMap { $0.stringValue }
    #expect(targets.contains("notes"))
    #expect(targets.contains("reminders"))
    #expect(!targets.contains("apple-cli-mcp"))

    let help: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_help", arguments: ["target": .string("notes")]
    )
    let helpResult = try await help.value
    let helpPayload = try #require(helpResult.structuredContent?.objectValue)
    #expect(helpResult.isError == false)
    #expect(helpPayload["exitCode"]?.intValue == 0)
    #expect(helpPayload["stdout"]?.stringValue?.contains("USAGE: apple notes") == true)

    let preview: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("notifications"),
        "arguments": .array([
          .string("preview"), .string("--title"), .string("release-test"),
          .string("--body"), .string("preview"),
        ]),
      ]
    )
    let previewResult = try await preview.value
    #expect(previewResult.isError == false)
    #expect(previewResult.structuredContent?.objectValue?["exitCode"]?.intValue == 0)

    await client.disconnect()
  }

  @Test(.timeLimit(.minutes(1)), arguments: ["127.0.0.1", "localhost", "::1", "[::1]"])
  func mcpHTTPExecutableBlackBoxRunsCliThroughSdkClient(host: String) async throws {
    guard #available(macOS 14.0, *) else {
      return
    }

    let installation = try stagedMCPInstallation(separateCLI: true)
    defer { try? FileManager.default.removeItem(at: installation.root) }
    let port = try availableLoopbackPort()
    let path = "/mcp-test-\(UUID().uuidString)"
    let endpointHost = host == "::1" ? "[::1]" : host
    let endpoint = try #require(URL(string: "http://\(endpointHost):\(port)\(path)"))
    let process = Process()
    let logURL = installation.root.appendingPathComponent("http-server.log")
    try Data().write(to: logURL)
    let log = try FileHandle(forWritingTo: logURL)
    defer { try? log.close() }
    process.executableURL = installation.server
    process.currentDirectoryURL = installation.root
    var environment = ProcessInfo.processInfo.environment
    environment["APPLE_CLI_BIN_DIR"] = installation.cliDirectory.path
    process.environment = environment
    process.arguments = [
      "serve",
      "http",
      "--host",
      host,
      "--port",
      "\(port)",
      "--path",
      path,
      "--session-timeout-seconds",
      "30",
      "--max-sessions",
      "2",
    ]
    process.standardOutput = log
    process.standardError = log

    try process.run()
    defer {
      stopTestProcess(process)
    }

    try await waitForHTTPServer(
      endpoint: endpoint, process: process, logURL: logURL, timeoutSeconds: 8)

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 5
    configuration.timeoutIntervalForResource = 10
    let transport = HTTPClientTransport(
      endpoint: endpoint,
      configuration: configuration,
      streaming: false,
      logger: nil
    )
    let client = Client(name: "apple-cli-http-tests", version: "1.0")
    let initializeResult = try await client.connect(transport: transport)

    #expect(initializeResult.serverInfo.name == "apple-cli-mcp")
    #expect(initializeResult.serverInfo.version == CLIVersion.current)
    #expect(initializeResult.capabilities.tools != nil)

    let (tools, _) = try await client.listTools()
    #expect(
      tools.map(\.name) == [
        "apple_cli_list_targets",
        "apple_cli_doctor",
        "apple_cli_status",
        "apple_cli_help",
        "apple_cli_command_catalog",
        "apple_cli_run",
      ])

    let listTargets: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_list_targets",
      arguments: [:]
    )
    let result = try await listTargets.value
    #expect(result.isError == false)
    let object = try #require(result.structuredContent?.objectValue)
    let targets = try #require(object["targets"]?.arrayValue).compactMap { $0.stringValue }
    #expect(targets.contains("notes"))
    #expect(targets.contains("reminders"))
    #expect(!targets.contains("apple-cli-mcp"))

    let help: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_help", arguments: ["target": .string("notes")]
    )
    let helpResult = try await help.value
    let helpPayload = try #require(helpResult.structuredContent?.objectValue)
    #expect(helpResult.isError == false)
    #expect(helpPayload["exitCode"]?.intValue == 0)
    #expect(helpPayload["stdout"]?.stringValue?.contains("USAGE: apple notes") == true)

    let preview: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("notifications"),
        "arguments": .array([
          .string("preview"), .string("--title"), .string("release-test"),
          .string("--body"), .string("preview"),
        ]),
      ]
    )
    let previewResult = try await preview.value
    #expect(previewResult.isError == false)
    #expect(previewResult.structuredContent?.objectValue?["exitCode"]?.intValue == 0)

    await client.disconnect()
  }

  @Test(.timeLimit(.minutes(1)))
  func mcpHTTPConcurrentInitializationsRespectSessionLimitAndReleaseCapacity() async throws {
    guard #available(macOS 14.0, *) else { return }

    let installation = try stagedMCPInstallation(separateCLI: false)
    defer { try? FileManager.default.removeItem(at: installation.root) }
    let port = try availableLoopbackPort()
    let endpoint = try #require(URL(string: "http://127.0.0.1:\(port)/mcp"))
    let process = Process()
    let logURL = installation.root.appendingPathComponent("http-server.log")
    try Data().write(to: logURL)
    let log = try FileHandle(forWritingTo: logURL)
    defer { try? log.close() }
    process.executableURL = installation.server
    process.currentDirectoryURL = installation.root
    process.arguments = ["serve", "http", "--port", "\(port)", "--max-sessions", "1"]
    process.standardOutput = log
    process.standardError = log
    try process.run()
    defer {
      stopTestProcess(process)
    }
    try await waitForHTTPServer(
      endpoint: endpoint, process: process, logURL: logURL, timeoutSeconds: 8)

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 5
    configuration.timeoutIntervalForResource = 10
    configuration.httpMaximumConnectionsPerHost = 4
    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONSerialization.data(withJSONObject: [
      "jsonrpc": "2.0", "id": 1, "method": "initialize",
      "params": [
        "protocolVersion": Version.latest, "capabilities": [:],
        "clientInfo": ["name": "apple-cli-session-tests", "version": "1.0"],
      ],
    ])
    let initialization = request

    var invalid = initialization
    invalid.setValue("text/plain", forHTTPHeaderField: "Content-Type")
    let (_, invalidResponse) = try await session.data(for: invalid)
    #expect((invalidResponse as? HTTPURLResponse)?.statusCode == 415)

    let responses = try await concurrentHTTPInitializations(
      port: port, request: initialization, count: 4)
    #expect(responses.filter { $0.0 == 200 }.count == 1)
    #expect(responses.filter { $0.0 == 503 }.count == 3)
    let sessionID = try #require(responses.first { $0.0 == 200 }?.1)

    var close = URLRequest(url: endpoint)
    close.httpMethod = "DELETE"
    close.setValue(sessionID, forHTTPHeaderField: "Mcp-Session-Id")
    close.setValue(Version.latest, forHTTPHeaderField: "MCP-Protocol-Version")
    close.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
    let (_, closeResponse) = try await session.data(for: close)
    #expect((closeResponse as? HTTPURLResponse)?.statusCode == 200)

    let (_, reopenedResponse) = try await session.data(for: initialization)
    let reopened = try #require(reopenedResponse as? HTTPURLResponse)
    #expect(reopened.statusCode == 200)
    let reopenedSessionID = try #require(reopened.value(forHTTPHeaderField: "Mcp-Session-Id"))
    close.setValue(reopenedSessionID, forHTTPHeaderField: "Mcp-Session-Id")
    let (_, finalCloseResponse) = try await session.data(for: close)
    #expect((finalCloseResponse as? HTTPURLResponse)?.statusCode == 200)
  }

}

private func stopTestProcess(_ process: Process) {
  guard process.isRunning else { return }
  process.terminate()
  let grace = ProcessInfo.processInfo.systemUptime + 0.25
  while process.isRunning, ProcessInfo.processInfo.systemUptime < grace {
    usleep(10_000)
  }
  if process.isRunning { _ = kill(process.processIdentifier, SIGKILL) }
  let deadline = ProcessInfo.processInfo.systemUptime + 2
  while process.isRunning, ProcessInfo.processInfo.systemUptime < deadline {
    usleep(10_000)
  }
  #expect(!process.isRunning, "Test process did not stop within the cleanup deadline.")
}

private func stagedMCPInstallation(separateCLI: Bool) throws -> (
  root: URL, server: URL, cliDirectory: URL
) {
  let source = try appleMCPExecutablePath().resolvingSymlinksInPath()
  let manager = FileManager.default
  let root = manager.temporaryDirectory.appendingPathComponent(
    "apple-cli-install-test-\(UUID().uuidString)")
  let bin = root.appendingPathComponent("bin")
  let cliDirectory = separateCLI ? root.appendingPathComponent("cli-bin") : bin
  do {
    try manager.createDirectory(at: bin, withIntermediateDirectories: true)
    if separateCLI {
      try manager.createDirectory(at: cliDirectory, withIntermediateDirectories: true)
    }
    let server = bin.appendingPathComponent("apple-cli-mcp")
    try manager.copyItem(at: source, to: server)
    let cli =
      ProcessInfo.processInfo.environment["APPLE_CLI_BIN"].map { URL(fileURLWithPath: $0) }
      ?? source.deletingLastPathComponent().appendingPathComponent("apple")
    try manager.copyItem(at: cli, to: cliDirectory.appendingPathComponent("apple"))
    for (executable, destination) in [(source, bin), (cli.resolvingSymlinksInPath(), cliDirectory)]
    {
      let libraries = try manager.contentsOfDirectory(
        at: executable.deletingLastPathComponent(), includingPropertiesForKeys: nil
      ).filter { $0.lastPathComponent.hasPrefix("libswift") && $0.pathExtension == "dylib" }
      for library in libraries {
        let copy = destination.appendingPathComponent(library.lastPathComponent)
        if manager.fileExists(atPath: copy.path) {
          #expect(try Data(contentsOf: library) == Data(contentsOf: copy))
        } else {
          try manager.copyItem(at: library, to: copy)
        }
      }
    }
    return (root, server, cliDirectory)
  } catch {
    try? manager.removeItem(at: root)
    throw error
  }
}

private func appleMCPExecutablePath() throws -> URL {
  let fileManager = FileManager.default
  var candidates: [URL] = []

  if let override = ProcessInfo.processInfo.environment["APPLE_CLI_MCP_BIN"],
    !override.isEmpty
  {
    candidates.append(URL(fileURLWithPath: override))
  }

  if let testExecutable = CommandLine.arguments.first,
    testExecutable.contains("/")
  {
    var directory = URL(fileURLWithPath: testExecutable)
    for _ in 0..<8 {
      directory.deleteLastPathComponent()
      candidates.append(directory.appendingPathComponent("apple-cli-mcp"))
    }
  }

  let packageRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
  candidates.append(packageRoot.appendingPathComponent(".build/debug/apple-cli-mcp"))
  candidates.append(
    packageRoot.appendingPathComponent(".build/arm64-apple-macosx/debug/apple-cli-mcp")
  )

  var seen: Set<String> = []
  var searched: [String] = []
  for candidate in candidates {
    let path = candidate.standardizedFileURL.path
    guard seen.insert(path).inserted else {
      continue
    }
    searched.append(path)
    if fileManager.isExecutableFile(atPath: path) {
      return URL(fileURLWithPath: path)
    }
  }

  throw CLIError(
    code: .backendUnavailable,
    message: "apple-cli-mcp executable was not found for black-box MCP stdio validation.",
    details: ["searched": searched.joined(separator: "\n")]
  )
}

private func availableLoopbackPort() throws -> Int {
  let descriptor = socket(AF_INET, SOCK_STREAM, 0)
  guard descriptor >= 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Could not allocate a loopback socket for MCP HTTP validation.",
      details: ["errno": "\(errno)"]
    )
  }
  defer { close(descriptor) }

  var reuseAddress: Int32 = 1
  _ = setsockopt(
    descriptor,
    SOL_SOCKET,
    SO_REUSEADDR,
    &reuseAddress,
    socklen_t(MemoryLayout<Int32>.size)
  )

  var address = sockaddr_in()
  address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
  address.sin_family = sa_family_t(AF_INET)
  address.sin_port = in_port_t(0).bigEndian
  address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

  let bindResult = withUnsafePointer(to: &address) { pointer in
    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
      Darwin.bind(descriptor, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
    }
  }
  guard bindResult == 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Could not bind a loopback socket for MCP HTTP validation.",
      details: ["errno": "\(errno)"]
    )
  }

  var boundAddress = sockaddr_in()
  var length = socklen_t(MemoryLayout<sockaddr_in>.size)
  let nameResult = withUnsafeMutablePointer(to: &boundAddress) { pointer in
    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
      getsockname(descriptor, sockaddrPointer, &length)
    }
  }
  guard nameResult == 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Could not read the allocated MCP HTTP validation port.",
      details: ["errno": "\(errno)"]
    )
  }

  return Int(in_port_t(bigEndian: boundAddress.sin_port))
}

private func concurrentHTTPInitializations(
  port: Int, request: URLRequest, count: Int
) async throws -> [(Int, String?)] {
  var descriptors: [Int32] = []
  defer { for descriptor in descriptors { close(descriptor) } }
  for _ in 0..<count {
    let descriptor = socket(AF_INET, SOCK_STREAM, 0)
    try #require(descriptor >= 0)
    descriptors.append(descriptor)
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = in_port_t(port).bigEndian
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
    let result = withUnsafePointer(to: &address) { pointer in
      pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.connect(descriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    try #require(result == 0)
    let flags = fcntl(descriptor, F_GETFL)
    try #require(flags >= 0)
    try #require(fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) == 0)
  }

  let body = try #require(request.httpBody)
  var fields = request.allHTTPHeaderFields ?? [:]
  fields["Host"] = "127.0.0.1:\(port)"
  fields["Content-Length"] = "\(body.count)"
  fields["Connection"] = "close"
  let headers = fields.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }
    .joined(separator: "\r\n")
  let path = try #require(request.url).path
  var payload = Data("POST \(path) HTTP/1.1\r\n\(headers)\r\n\r\n".utf8)
  payload.append(body)
  for descriptor in descriptors {
    let sent = payload.withUnsafeBytes { Darwin.send(descriptor, $0.baseAddress, $0.count, 0) }
    try #require(sent == payload.count)
  }

  return try await withThrowingTaskGroup(of: (Int, String?).self) { group in
    for descriptor in descriptors {
      group.addTask {
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        let separator = Data("\r\n\r\n".utf8)
        var received = Data()
        var buffer = [UInt8](repeating: 0, count: 2_048)
        while received.range(of: separator) == nil {
          let bytes = recv(descriptor, &buffer, buffer.count, 0)
          if bytes > 0 {
            received.append(contentsOf: buffer.prefix(bytes))
          } else {
            try #require(bytes < 0 && (errno == EAGAIN || errno == EWOULDBLOCK))
            try #require(ContinuousClock.now < deadline, "HTTP response headers were not received.")
            try await Task.sleep(for: .milliseconds(1))
          }
        }
        let header = String(decoding: received, as: UTF8.self)
          .components(separatedBy: "\r\n\r\n")[0]
        let lines = header.components(separatedBy: "\r\n")
        let status = try #require(Int(lines[0].split(separator: " ").dropFirst().first ?? ""))
        let sessionID = lines.first { $0.lowercased().hasPrefix("mcp-session-id:") }
          .map { $0.split(separator: ":", maxSplits: 1)[1].trimmingCharacters(in: .whitespaces) }
        return (status, sessionID)
      }
    }
    var responses: [(Int, String?)] = []
    for try await response in group { responses.append(response) }
    return responses
  }
}

private func waitForHTTPServer(
  endpoint: URL, process: Process, logURL: URL, timeoutSeconds: TimeInterval
)
  async throws
{
  let deadline = ContinuousClock.now.advanced(by: .seconds(timeoutSeconds))
  let configuration = URLSessionConfiguration.ephemeral
  configuration.timeoutIntervalForRequest = 0.5
  configuration.timeoutIntervalForResource = 0.5
  let session = URLSession(configuration: configuration)
  defer { session.invalidateAndCancel() }

  var lastError: String?
  while ContinuousClock.now < deadline {
    if !process.isRunning {
      throw CLIError(
        code: .backendUnavailable,
        message: "apple-cli-mcp HTTP process exited before accepting connections.",
        details: [
          "endpoint": endpoint.absoluteString, "exitStatus": "\(process.terminationStatus)",
          "serverLog": String(decoding: (try? Data(contentsOf: logURL)) ?? Data(), as: UTF8.self),
        ]
      )
    }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "GET"
    request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
    do {
      let (_, response) = try await session.data(for: request)
      if let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 400,
        httpResponse.value(forHTTPHeaderField: "Server") == "apple-cli-mcp"
      {
        return
      }
    } catch {
      lastError = String(describing: error)
    }

    try await Task.sleep(nanoseconds: 100_000_000)
  }

  throw CLIError(
    code: .backendUnavailable,
    message: "Timed out waiting for apple-cli-mcp HTTP validation server.",
    details: [
      "endpoint": endpoint.absoluteString,
      "lastError": lastError ?? "none",
      "serverLog": String(decoding: (try? Data(contentsOf: logURL)) ?? Data(), as: UTF8.self),
    ]
  )
}
