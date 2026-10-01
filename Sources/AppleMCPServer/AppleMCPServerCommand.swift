import ArgumentParser
import Foundation
import Utility

@main
@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct AppleMCPServerCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "apple-cli-mcp",
    abstract: "Expose the apple CLI contract through MCP.",
    version: CLIVersion.current,
    subcommands: [StdioCommand.self, ServeCommand.self],
    defaultSubcommand: StdioCommand.self
  )
}

struct StdioCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "stdio",
    abstract: "Run the stdio MCP server."
  )

  mutating func run() async throws {
    do {
      try await AppleMCPServerRuntime.runStdio()
    } catch {
      AppleMCPServerRuntime.writeStandardError("apple-cli-mcp stdio failed. Check the client connection.\n")
      throw ExitCode.failure
    }
  }
}

struct ServeCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "serve",
    abstract: "Run an MCP server transport.",
    subcommands: [HTTPServeCommand.self]
  )
}

struct HTTPServeCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "http",
    abstract: "Run the Streamable HTTP MCP server."
  )

  @Option(help: "Host address to bind.")
  var host = "127.0.0.1"

  @Option(help: "Port to bind.")
  var port = 8765

  @Option(help: "MCP endpoint path.")
  var path = "/mcp"

  @Option(name: .customLong("token-env"), help: "Environment variable containing the bearer token.")
  var tokenEnvironmentVariable: String?

  @Flag(name: .customLong("allow-non-loopback"), help: "Allow binding to a non-loopback host.")
  var allowNonLoopback = false

  @Option(name: .customLong("session-timeout-seconds"), help: "Idle session timeout in seconds.")
  var sessionTimeoutSeconds = 3_600

  @Option(name: .customLong("max-sessions"), help: "Maximum concurrent HTTP MCP sessions.")
  var maxSessions = 16

  func validate() throws {
    _ = try MCPHTTPServerConfiguration(
      host: host,
      port: port,
      path: path,
      allowNonLoopback: allowNonLoopback,
      tokenEnvironmentVariable: tokenEnvironmentVariable,
      sessionTimeoutSeconds: sessionTimeoutSeconds,
      maxSessions: maxSessions,
      environment: ProcessInfo.processInfo.environment
    )
  }

  mutating func run() async throws {
    let configuration = try MCPHTTPServerConfiguration(
      host: host,
      port: port,
      path: path,
      allowNonLoopback: allowNonLoopback,
      tokenEnvironmentVariable: tokenEnvironmentVariable,
      sessionTimeoutSeconds: sessionTimeoutSeconds,
      maxSessions: maxSessions,
      environment: ProcessInfo.processInfo.environment
    )

    do {
      try await AppleMCPServerRuntime.runHTTP(configuration: configuration)
    } catch let error as MCPHTTPServerError {
      AppleMCPServerRuntime.writeStandardError("\(error.description)\n")
      throw ExitCode.failure
    } catch {
      AppleMCPServerRuntime.writeStandardError(
        "apple-cli-mcp serve http failed. Check the host, port, and network permissions.\n")
      throw ExitCode.failure
    }
  }
}
