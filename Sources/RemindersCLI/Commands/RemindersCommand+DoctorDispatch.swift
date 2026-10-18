import Foundation
import Utility

extension RemindersCommand {
  func runDoctorCommand(_ options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["doctor", "store"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["scope"])
      let debug = try sqliteReader.debugStore(scope: options.targetOption("scope") ?? "summary")
      return try result(
        debug,
        human: remindersStoreDebugHumanOutput(debug),
        options: options
      )
    case ["doctor", "item"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let reminder = try readReminder(id: id) else {
        throw CLIError(
          code: .notFound,
          message: "Reminder was not found.",
          details: ["id": id]
        )
      }
      let debug = try sqliteReader.debugItem(reminder: reminder)
      return try result(
        debug,
        human: remindersItemDebugHumanOutput(debug),
        options: options
      )
    case ["doctor", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["list"])
      let list = try reminderList(selector: try requiredOption("list", options: options))
      let debug = try sqliteReader.debugList(list: list)
      return try result(
        debug,
        human: remindersListDebugHumanOutput(debug),
        options: options
      )
    default:
      return nil
    }
  }
}
