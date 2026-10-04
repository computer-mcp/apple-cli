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
    guard let current = try readReminderKitReminder(id: reminder.id) else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": reminder.id])
    }
    let debug = try sqliteReader.debugItem(reminder: current)
    guard verifiedSubtaskRelationship(debug) != nil else {
      throw subtaskVerificationError(
        message: "Reminder subtask relationship is unavailable before moving.",
        reminder: current,
        expectedParent: parent,
        lastDebug: debug,
        lastError: nil
      )
    }
    if subtaskParentSatisfied(debug: debug, expectedParent: parent) {
      return try verifySubtaskParent(reminder: current, expectedParent: parent)
    }
    try self.moveSubtask(reminderID: reminder.id, toParentReminderID: parent.id)
    return try verifySubtaskParent(reminder: reminder, expectedParent: parent)
  }

  public func promoteReminderSubtask(reminder: ReminderDetail) throws -> ReminderDetail {
    try self.preflightSubtaskMutation(reminderID: reminder.id)
    guard let current = try readReminderKitReminder(id: reminder.id) else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": reminder.id])
    }
    let debug = try sqliteReader.debugItem(reminder: current)
    guard verifiedSubtaskRelationship(debug) != nil else {
      throw subtaskVerificationError(
        message: "Reminder subtask relationship is unavailable before promoting.",
        reminder: current,
        expectedParent: nil,
        lastDebug: debug,
        lastError: nil
      )
    }
    try self.promoteSubtask(reminderID: current.id)
    return try verifySubtaskPromoted(reminder: current)
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
        if let current = try readReminderKitReminder(id: reminder.id),
          let parent = try readReminderKitReminder(id: expectedParent.id)
        {
          let debug = try sqliteReader.debugItem(reminder: current)
          lastDebug = debug
          if parent.id == expectedParent.id, parent.listId == expectedParent.listId,
            subtaskParentSatisfied(debug: debug, expectedParent: expectedParent)
          {
            return (try? sqliteReader.enrichReminder(current)) ?? current
          }
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
        if let current = try readReminderKitReminder(id: reminder.id) {
          let debug = try sqliteReader.debugItem(reminder: current)
          lastDebug = debug
          if current.listId == reminder.listId, subtaskPromotionSatisfied(debug: debug) {
            return (try? sqliteReader.enrichReminder(current)) ?? current
          }
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
    guard let match = verifiedSubtaskRelationship(debug), let parentID = match.parentReminderId else {
      return false
    }
    return subtaskIdentifiersEqual(parentID, expectedParent.id, entity: "REMCDReminder")
      && subtaskIdentifiersEqual(debug.reminder.listId, expectedParent.listId, entity: "REMCDList")
  }

  func subtaskPromotionSatisfied(debug: RemindersItemDebugResponse) -> Bool {
    guard let match = verifiedSubtaskRelationship(debug) else { return false }
    return match.parentReminderId == nil && match.parentReminderTitle == nil
      && debug.reminder.parentReminderId == nil && debug.reminder.parentReminderTitle == nil
  }

  func subtaskRelationshipChanged(from before: ReminderDetail, to after: ReminderDetail) -> Bool {
    let sameParent: Bool
    if let previous = before.parentReminderId, let current = after.parentReminderId {
      sameParent = subtaskIdentifiersEqual(previous, current, entity: "REMCDReminder")
    } else {
      sameParent = before.parentReminderId == nil && after.parentReminderId == nil
    }
    return !sameParent || !subtaskIdentifiersEqual(before.listId, after.listId, entity: "REMCDList")
  }

  private func verifiedSubtaskRelationship(
    _ debug: RemindersItemDebugResponse
  ) -> RemindersPrivateReminderDebugRecord? {
    guard debug.privateStoreMatches.count == 1, let match = debug.privateStoreMatches.first,
      match.subtaskRelationshipAvailable == true,
      [match.calendarItemIdentifier, match.ckIdentifier, match.externalIdentifier].compactMap({ $0 })
        .contains(where: { subtaskIdentifiersEqual($0, debug.reminder.id, entity: "REMCDReminder") })
    else {
      return nil
    }
    return match
  }

  private func subtaskIdentifiersEqual(_ lhs: String, _ rhs: String, entity: String) -> Bool {
    guard !lhs.isEmpty, !rhs.isEmpty else { return false }
    if lhs == rhs { return true }
    func uuid(_ value: String) -> UUID? {
      if let uuid = UUID(uuidString: value) { return uuid }
      guard let url = URL(string: value), url.scheme == "x-apple-reminderkit",
        url.host?.caseInsensitiveCompare(entity) == .orderedSame,
        url.query == nil, url.fragment == nil, url.pathComponents.count == 2
      else {
        return nil
      }
      return UUID(uuidString: url.lastPathComponent)
    }
    guard let left = uuid(lhs), let right = uuid(rhs) else { return false }
    return left == right
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
