import Foundation
import Testing
import Utility

@Suite
struct CLIExecutableTests {
  @Test func productsAndTargetVersionsAgree() throws {
    let targets = ["notes", "calendar", "reminders", "contacts", "mail", "messages", "maps",
      "finder", "numbers", "pages", "keynote", "facetime", "safari", "photos", "print",
      "clipboard", "notifications", "intelligence", "tcc"]
    for arguments in [[]] + targets.map({ [$0] }) {
      let result = try cli(arguments + ["--version"])
      #expect(result.exitCode == 0)
      #expect(result.stdout == CLIVersion.current + "\n")
      #expect(result.stderr.isEmpty)
    }
    let mcp = try CLISubprocess.run(.path(executable("apple-cli-mcp")), arguments: ["--version"], timeoutSeconds: 5)
    #expect(mcp.exitCode == 0 && mcp.stdout == CLIVersion.current + "\n")
  }

  @Test(arguments: [[], ["notes"], ["notes", "settings"]])
  func helpWithJSONIsSuccessful(path: [String]) throws {
    let result = try cli(path + ["--help", "--json"])
    #expect(result.exitCode == 0)
    #expect(result.stdout.contains("USAGE:"))
    #expect(!result.stdout.contains("validation_error"))
    #expect(result.stderr.isEmpty)
  }

  @Test func parsingErrorsRemainStructured() throws {
    for arguments in [["unknown-target", "--json"], ["notes", "list", "--unknown-flag", "--json", "--pretty"]] {
      let result = try cli(arguments)
      #expect(result.exitCode == 2)
      let json = try #require(JSONSerialization.jsonObject(with: Data(result.stdout.utf8)) as? [String: Any])
      #expect(json["ok"] as? Bool == false)
      #expect((json["error"] as? [String: Any])?["code"] as? String == "validation_error")
    }
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
