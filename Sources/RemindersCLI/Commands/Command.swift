import Foundation
import Utility

let reminderListDeleteSnapshotLimit = 500

public struct RemindersCommand: Sendable {
  let sqliteReader: RemindersSQLiteReader
  let target = "reminders"

  public init(sqliteReader: RemindersSQLiteReader = RemindersSQLiteReader()) {
    self.sqliteReader = sqliteReader
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals.first {
    case "lists":
      return try runListsCommand(options)
    case "tags", "sections", "subtasks", "attachments", "assignments":
      return try runRichMetadataCommand(options)
    case "templates":
      return try runTemplateCommand(options)
    case "notes":
      return try runNotesCommand(options)
    case "reminders":
      return try runReminderItemCommand(options)
    case "doctor":
      return try runDoctorCommand(options)
    default:
      return nil
    }
  }
}
