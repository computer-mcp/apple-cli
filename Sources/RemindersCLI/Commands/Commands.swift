import ArgumentParser
import Utility

public struct RemindersTarget: ParsableCommand {
  public static let targetName = "reminders"
  public static let targetStatus =
    "Implemented: ReminderKit list/read-search, rich notes, reminder/list lifecycle mutations, repeat rules, location triggers, alarms, URL/link cards, tags, flag, urgent, When Messaging, sections, subtasks, attachments, shared assignment, list metadata, list groups, templates, supported Smart Lists, and read-only SQLite verification plus doctor diagnostics."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "reminders",
    abstract:
      "ReminderKit workflows for reminders, lists, tags, sections, subtasks, attachments, assignments, templates, Smart Lists, and diagnostics.",
    version: CLIVersion.current,
    subcommands: [
      Lists.self, Tags.self, Sections.self, Subtasks.self, Attachments.self, Assignments.self,
      Templates.self, Notes.self,
      List.self,
      Search.self, Read.self, Create.self, Update.self, Complete.self, Uncomplete.self,
      CompleteMany.self, UncompleteMany.self, CompleteMatching.self, UncompleteMatching.self,
      Delete.self, CleanupCompleted.self, Doctor.self,
    ]
  )

  @OptionGroup var sharedOptions: RemindersReadSharedOptions
  public init() {}

  public mutating func run() throws {
    let shared = sharedOptions.shared
    try CLICommandOutput.writeStatus(
      target: Self.targetName,
      status: Self.targetStatus,
      implemented: Self.isImplemented,
      json: shared.json,
      pretty: shared.pretty
    )
  }
}

extension RemindersTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try RemindersCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Documented Reminders command was not dispatched.",
          details: [
            "target": targetName,
            "command": options.positionals.joined(separator: " "),
            "dispatch_status": "missing_command_case",
          ]
        )
      }

      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(
        error, target: targetName, json: options.json, pretty: options.pretty)
    } catch {
      try CLICommandOutput.write(
        CLIError.unexpected(error, verbose: options.verbose),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }

  public protocol Leaf: ParsableCommand {
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: RemindersTargetOptions { get }
  }
}

extension RemindersTarget.Leaf {
  public mutating func run() throws {
    let options = remindersProcessSharedFlagFallback(
      shared.cliOptions(
        targetOptions: targetOptions.cliTargetOptions,
        targetFlags: targetOptions.cliTargetFlags,
        positionals: Self.positionals
      )
    )
    try RemindersTarget.runCommand(options: options)
  }
}

private func remindersProcessSharedFlagFallback(
  _ options: CLIOptions,
  arguments: [String] = CommandLine.arguments
) -> CLIOptions {
  var resolved = options
  let tokens = Array(arguments.dropFirst())

  if tokens.contains("--json") {
    resolved.json = true
  }
  if tokens.contains("--pretty") {
    resolved.pretty = true
  }
  if tokens.contains("--verbose") {
    resolved.verbose = true
  }
  if let index = tokens.firstIndex(of: "--limit"),
    tokens.indices.contains(tokens.index(after: index)),
    let limit = Int(tokens[tokens.index(after: index)])
  {
    resolved.limit = limit
  }

  return resolved
}
