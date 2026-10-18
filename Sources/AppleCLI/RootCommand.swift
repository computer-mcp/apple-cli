import ArgumentParser
import CalendarCLI
import ClipboardCLI
import ContactsCLI
import Darwin
import Foundation
import IntelligenceCLI
import FaceTimeCLI
import FinderCLI
import KeynoteCLI
import MailCLI
import MapsCLI
import MessagesCLI
import NotesCLI
import NotificationsCLI
import NumbersCLI
import PagesCLI
import PhotosCLI
import PrintCLI
import RemindersCLI
import SafariCLI
import TCCCLI
import Utility

struct RootCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "apple",
    abstract: "Target-first local Apple app/domain/system CLI suite.",
    discussion: """
      Use `apple --help` to discover targets, then `apple <target> --help` and \
      `apple <target> <resource?> <action> --help` for command details.
      Use `--json` for scripts, agents, and MCP clients. `--json` never authorizes writes.
      Use `<target> doctor --json` for setup, dependency, permission, and readiness diagnostics.
      See Documentation/Reference/AppleCLIUserGuide.md in the source package for the usage manual.
      """,
    version: CLIVersion.current,
    subcommands: [
      NotesTarget.self,
      CalendarTarget.self,
      RemindersTarget.self,
      ContactsTarget.self,
      MailTarget.self,
      MessagesTarget.self,
      MapsTarget.self,
      FinderTarget.self,
      NumbersTarget.self,
      PagesTarget.self,
      KeynoteTarget.self,
      FaceTimeTarget.self,
      SafariTarget.self,
      PhotosTarget.self,
      PrintTarget.self,
      ClipboardTarget.self,
      NotificationsTarget.self,
      IntelligenceTarget.self,
      TCCTarget.self,
    ]
  )
}

@main
enum AppleMain {
  static func main() {
    do {
      var command = try RootCommand.parseAsRoot()
      try command.run()
    } catch let exitCode as ExitCode {
      Darwin.exit(exitCode.rawValue)
    } catch {
      if RootCommand.exitCode(for: error) == .success {
        RootCommand.exit(withError: error)
      }
      guard CLIParseErrorOutput.shouldEmitJSON(arguments: CommandLine.arguments) else {
        RootCommand.exit(withError: error)
      }
      CLIParseErrorOutput.write(error: error, arguments: CommandLine.arguments)
      Darwin.exit(CLIErrorCode.validationError.exitCode)
    }
  }
}

private enum CLIParseErrorOutput {
  static func shouldEmitJSON(arguments: [String]) -> Bool {
    arguments.dropFirst().contains("--json")
  }

  static func write(error: Error, arguments: [String]) {
    let target = targetName(arguments: arguments)
    let payload = CLIError(
      code: .validationError,
      message: parseErrorMessage(error),
      details: ["source": "argument_parser"]
    ).payload
    let envelope = CLIErrorEnvelope(error: payload, meta: ["target": target])

    if let encoded = try? CLIJSON.encodeString(envelope, pretty: arguments.dropFirst().contains("--pretty")) {
      print(encoded)
    } else {
      FileHandle.standardError.write(Data("internal_error: Failed to encode JSON error envelope.\n".utf8))
    }
  }

  private static func targetName(arguments: [String]) -> String {
    let knownTargets = Set([
      "notes",
      "calendar",
      "reminders",
      "contacts",
      "mail",
      "messages",
      "maps",
      "finder",
      "numbers",
      "pages",
      "keynote",
      "facetime",
      "safari",
      "photos",
      "print",
      "clipboard",
      "notifications",
      "intelligence",
      "tcc",
    ])

    return arguments.dropFirst().first { knownTargets.contains($0) } ?? "apple"
  }

  private static func parseErrorMessage(_ error: Error) -> String {
    let message = RootCommand.message(for: error)
    let firstLine = message
      .split(separator: "\n", omittingEmptySubsequences: true)
      .first
      .map(String.init)?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if firstLine.hasPrefix("Error: ") {
      return String(firstLine.dropFirst("Error: ".count))
    }

    if firstLine.isEmpty {
      return "Invalid command arguments."
    }
    return firstLine
  }
}
