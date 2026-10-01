import Foundation
import Utility

extension RemindersCommand {
  public func createReminderSubtask(parent: ReminderDetail, title: String) throws
    -> ReminderDetail
  {
    try self.preflightSubtaskMutation(reminderID: parent.id)
    let created = try self.createSubtask(parentReminderID: parent.id, title: title)
    return try verifySubtaskParent(reminder: created, expectedParent: parent)
  }

  public func moveReminderSubtask(reminder: ReminderDetail, parent: ReminderDetail) throws
    -> ReminderDetail
  {
    guard reminder.id != parent.id else {
      throw CLIError(
        code: .validationError,
        message: "Reminder cannot be made a subtask of itself.",
        details: ["id": reminder.id]
      )
    }
    try self.preflightSubtaskMutation(reminderID: reminder.id)
    try self.moveSubtask(reminderID: reminder.id, toParentReminderID: parent.id)
    return try verifySubtaskParent(reminder: reminder, expectedParent: parent)
  }

  public func promoteReminderSubtask(reminder: ReminderDetail) throws -> ReminderDetail {
    try self.preflightSubtaskMutation(reminderID: reminder.id)
    try self.promoteSubtask(reminderID: reminder.id)
    return try verifySubtaskPromoted(reminder: reminder)
  }

  func verifySubtaskParent(
    reminder: ReminderDetail,
    expectedParent: ReminderDetail
  ) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if subtaskParentSatisfied(debug: debug, expectedParent: expectedParent) {
          return try enrichedReminderAfterSubtaskMutation(reminder)
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    throw subtaskVerificationError(
      message: "Reminders.app subtask parent update could not be verified.",
      reminder: reminder,
      expectedParent: expectedParent,
      lastDebug: lastDebug,
      lastError: lastError
    )
  }

  func verifySubtaskPromoted(reminder: ReminderDetail) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if subtaskPromotionSatisfied(debug: debug) {
          return try enrichedReminderAfterSubtaskMutation(reminder)
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    throw subtaskVerificationError(
      message: "Reminders.app subtask promotion could not be verified.",
      reminder: reminder,
      expectedParent: nil,
      lastDebug: lastDebug,
      lastError: lastError
    )
  }

  func subtaskParentSatisfied(
    debug: RemindersItemDebugResponse,
    expectedParent: ReminderDetail
  ) -> Bool {
    debug.privateStoreMatches.contains { match in
      match.parentReminderId == expectedParent.id
        || match.parentReminderTitle == expectedParent.title
    }
  }

  func subtaskPromotionSatisfied(debug: RemindersItemDebugResponse) -> Bool {
    debug.privateStoreMatches.contains { match in
      (match.parentReminderId ?? "").isEmpty && (match.parentReminderTitle ?? "").isEmpty
    }
  }

  func enrichedReminderAfterSubtaskMutation(_ reminder: ReminderDetail) throws
    -> ReminderDetail
  {
    if let current = try readReminderKitReminder(id: reminder.id) {
      do {
        return try sqliteReader.enrichReminder(current)
      } catch {
        return current
      }
    }
    do {
      return try sqliteReader.enrichReminder(reminder)
    } catch {
      return reminder
    }
  }

  func subtaskVerificationError(
    message: String,
    reminder: ReminderDetail,
    expectedParent: ReminderDetail?,
    lastDebug: RemindersItemDebugResponse?,
    lastError: Error?
  ) -> CLIError {
    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_parent_id": expectedParent?.id ?? "",
      "expected_parent_title": expectedParent?.title ?? "",
    ]
    if let lastDebug {
      details["actual_parent_ids"] = lastDebug.privateStoreMatches
        .compactMap(\.parentReminderId)
        .joined(separator: ",")
      details["actual_parent_titles"] = lastDebug.privateStoreMatches
        .compactMap(\.parentReminderTitle)
        .joined(separator: ",")
      details["actual_subtask_counts"] = lastDebug.privateStoreMatches
        .map { String($0.subtaskCount) }
        .joined(separator: ",")
      details["match_count"] = "\(lastDebug.privateStoreMatches.count)"
    }
    if let lastError {
      details["last_error"] = reminderKitErrorSummary(lastError)
    }
    return CLIError(code: .backendUnavailable, message: message, details: details)
  }
}
