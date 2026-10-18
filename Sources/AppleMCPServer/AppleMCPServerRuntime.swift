import AppleMCPAdapter
import Foundation
import MCP

enum AppleMCPServerRuntime {
  static func runStdio() async throws {
    let server = await AppleMCPServerFactory.makeServer(adapter: AppleMCPAdapter())
    let transport = StdioTransport()
    try await server.start(transport: transport)
    await server.waitUntilCompleted()
  }

  static func runHTTP(configuration: MCPHTTPServerConfiguration) async throws {
    if #available(macOS 14.0, *) {
      let server = MCPHTTPServer(configuration: configuration, adapter: AppleMCPAdapter())
      try await server.run()
    } else {
      throw MCPHTTPServerError.unsupportedPlatform
    }
  }

  static func makeServer(adapter: AppleMCPAdapter) async -> Server {
    await AppleMCPServerFactory.makeServer(adapter: adapter)
  }

  static func writeStandardError(_ message: String) {
    guard let data = message.data(using: .utf8) else {
      return
    }
    FileHandle.standardError.write(data)
  }
}

enum MCPHTTPServerError: Error, CustomStringConvertible {
  case unsupportedPlatform

  var description: String {
    switch self {
    case .unsupportedPlatform:
      return "Streamable HTTP MCP serving requires macOS 14 or newer."
    }
  }
}
