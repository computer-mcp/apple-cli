import Foundation
import Testing
import Utility

@Suite
struct CLIExecutableTests {
  @Test func embeddedExecutableMetadataSupportsCalendarAndNotifications() throws {
    let result = try cli(["calendar", "doctor", "--json"])
    let envelope = try #require(
      JSONSerialization.jsonObject(with: Data(result.stdout.utf8)) as? [String: Any])
    let data = try #require(envelope["data"] as? [String: Any])
    let checks = try #require(data["checks"] as? [[String: Any]])
    let purpose = try #require(
      checks.first { $0["name"] as? String == "calendar_usage_descriptions" })
    #expect(purpose["status"] as? String == "ok")
    #expect(result.stderr.isEmpty)
    let notification = try cli(["notifications", "settings", "--json"])
    #expect(notification.exitCode == 0)
    #expect(notification.stderr.isEmpty)
    let notificationEnvelope = try #require(
      JSONSerialization.jsonObject(with: Data(notification.stdout.utf8)) as? [String: Any])
    let settings = try #require(notificationEnvelope["data"] as? [String: Any])
    #expect(settings["bundleIdentifier"] as? String == "io.github.computer-mcp.apple-cli")
    #expect(settings["authorizationStatus"] as? String != nil)
    for collection in ["pending", "delivered"] {
      let result = try cli(["notifications", collection, "list", "--limit", "1", "--json"])
      #expect(result.exitCode == 0)
      #expect(result.stderr.isEmpty)
      let envelope = try #require(
        JSONSerialization.jsonObject(with: Data(result.stdout.utf8)) as? [String: Any])
      let data = try #require(envelope["data"] as? [String: Any])
      let notifications = try #require(data["notifications"] as? [[String: Any]])
      #expect(data["limit"] as? Int == 1)
      #expect(notifications.count <= 1)
    }
  }

  @Test func notesDefaultStatusIsConciseAndCommandsRemainDiscoverable() throws {
    let result = try cli(["notes", "--json"])
    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    let envelope = try #require(
      JSONSerialization.jsonObject(with: Data(result.stdout.utf8)) as? [String: Any])
    #expect(envelope["ok"] as? Bool == true)
    let data = try #require(envelope["data"] as? [String: Any])
    #expect(data["target"] as? String == "notes")
    #expect(data["implemented"] as? Bool == true)
    let status = try #require(data["status"] as? String)
    #expect(!status.isEmpty && status.count < 512)

    let help = try cli(["notes", "--help"])
    #expect(help.exitCode == 0)
    #expect(help.stderr.isEmpty)
    for command in ["smart-folders", "attachments", "settings"] {
      #expect(help.stdout.contains(command))
    }
  }

  @Test func productsAndTargetVersionsAgree() throws {
    let targets = [
      "notes", "calendar", "reminders", "contacts", "mail", "messages", "maps",
      "finder", "numbers", "pages", "keynote", "facetime", "safari", "photos", "print",
      "clipboard", "notifications", "intelligence", "tcc",
    ]
    for arguments in [[]] + targets.map({ [$0] }) {
      let result = try cli(arguments + ["--version"])
      #expect(result.exitCode == 0)
      #expect(result.stdout == CLIVersion.current + "\n")
      #expect(result.stderr.isEmpty)
    }
    let mcp = try CLISubprocess.run(
      .path(executable("apple-cli-mcp")), arguments: ["--version"], timeoutSeconds: 5)
    #expect(mcp.exitCode == 0 && mcp.stdout == CLIVersion.current + "\n")
  }

  @Test(arguments: [
    [], ["notes"], ["notes", "settings"], ["maps", "collections", "places", "create"],
  ])
  func helpWithJSONIsSuccessful(path: [String]) throws {
    let result = try cli(path + ["--help", "--json"])
    #expect(result.exitCode == 0)
    #expect(result.stdout.contains("USAGE:"))
    #expect(!result.stdout.contains("validation_error"))
    #expect(result.stderr.isEmpty)
  }

  @Test func parsingErrorsRemainStructured() throws {
    for arguments in [
      ["unknown-target", "--json"], ["notes", "list", "--unknown-flag", "--json", "--pretty"],
    ] {
      let result = try cli(arguments)
      #expect(result.exitCode == 2)
      let json = try #require(
        JSONSerialization.jsonObject(with: Data(result.stdout.utf8)) as? [String: Any])
      #expect(json["ok"] as? Bool == false)
      #expect((json["error"] as? [String: Any])?["code"] as? String == "validation_error")
    }
  }

  @Test(arguments: [
    "", " ", "host/path", "user@host", "host?query", "host#fragment", "http://localhost",
    "localhost:80", "[localhost]", "[invalid:ipv6]",
  ])
  func mcpHTTPRejectsInvalidHostBeforeStarting(host: String) throws {
    let result = try CLISubprocess.run(
      .path("/usr/bin/env"),
      arguments: [
        "APPLE_CLI_SYNTHETIC_HTTP_TOKEN=synthetic-http-token",
        executable("apple-cli-mcp"), "serve", "http", "--host", host,
        "--allow-non-loopback", "--token-env", "APPLE_CLI_SYNTHETIC_HTTP_TOKEN",
      ],
      timeoutSeconds: 5)

    #expect(result.exitCode == 64)
    #expect(result.stdout.isEmpty)
    #expect(result.stderr.contains("--host"))
    #expect(!result.stderr.contains("synthetic-http-token"))
    #expect(!result.stderr.contains("Fatal error"))
  }
}

private func cli(_ arguments: [String]) throws -> CLISubprocessResult {
  try CLISubprocess.run(.path(executable("apple")), arguments: arguments, timeoutSeconds: 5)
}

private func executable(_ product: String) -> String {
  let key = product == "apple" ? "APPLE_CLI_BIN" : "APPLE_CLI_MCP_BIN"
  if let path = ProcessInfo.processInfo.environment[key], !path.isEmpty { return path }
  return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent(".build/debug/\(product)").path
}
