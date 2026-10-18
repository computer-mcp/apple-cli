import Foundation
import ReminderKit
import Utility

struct ReminderNotesSnapshot {
  var store: REMStore
  var native: REMReminder
  var detail: ReminderDetail
  var text: NSAttributedString?
  var record: ReminderNotesRecord
}

extension RemindersCommand {
  func reminderNotesSnapshot(id: String, operation: String) throws -> ReminderNotesSnapshot {
    let store = try coreReminderKitStore(operation: operation)
    guard let reminder = try coreFetchReminder(store: store, id: id, operation: operation) else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }
    try ReminderKitRuntimeMethod(owner: "REMReminder", selector: "notes", returnType: "@")
      .require(operation: operation, receiver: reminder)
    let text = reminder.notes.map(NSAttributedString.init(attributedString:))
    let core = coreReminderDetail(reminder)
    let detail = (try? sqliteReader.enrichReminder(core)) ?? core
    return .init(store: store, native: reminder, detail: detail, text: text,
      record: try reminderNotesRecord(id: detail.id, notes: text))
  }

  func saveReminderNotes(_ before: ReminderNotesSnapshot, expected: NSAttributedString,
    operation: String) throws -> ReminderNotesMutationResult
  {
    if before.text?.isEqual(to: expected) == true {
      return .init(operation: operation, changed: false, verified: true,
        reminder: before.detail, notes: before.record)
    }
    let request = try coreReminderKitSaveRequest(store: before.store, operation: operation)
    try ReminderKitRuntimeMethod(owner: "REMSaveRequest", selector: "updateReminder:",
      returnType: "@", argumentTypes: ["@"]
    ).require(operation: operation, receiver: request)
    guard let change = request.updateReminder(before.native) as? REMReminderChangeItem else {
      throw coreReminderKitError(operation: operation, message: "Reminder notes change could not be created.")
    }
    try ReminderKitRuntimeMethod(owner: "REMReminderChangeItem", selector: "setNotes:",
      returnType: "v", argumentTypes: ["@"]
    ).require(operation: operation, receiver: change)
    change.notes = expected
    do {
      try coreSaveReminderKit(request, operation: operation)
      let deadline = Date().addingTimeInterval(5)
      repeat {
        let after = try reminderNotesSnapshot(id: before.detail.id, operation: operation)
        var preserved = after.detail
        preserved.modifiedAt = before.detail.modifiedAt
        if after.text?.isEqual(to: expected) == true, preserved == before.detail {
          return .init(operation: operation, changed: true, verified: true,
            reminder: after.detail, notes: after.record)
        }
        Thread.sleep(forTimeInterval: 0.1)
      } while Date() < deadline
      throw reminderNotesUnavailable()
    } catch {
      var error = (error as? CLIError) ?? CLIError.unexpected(error)
      error.details["mutation_may_have_occurred"] = "true"
      error.details["verification"] = "unconfirmed"
      error.details["retry_guidance"] = "inspect_reminder_notes_before_retrying"
      throw error
    }
  }
}
