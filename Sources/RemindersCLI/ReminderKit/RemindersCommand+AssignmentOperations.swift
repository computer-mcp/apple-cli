import Foundation
import Utility

extension RemindersCommand {
  public func assignReminder(reminder: ReminderDetail, assigneeSelector: String) throws
    -> ReminderDetail
  {
    try self.preflightAssignmentMutation(reminderID: reminder.id)
    let target = try sqliteReader.resolveAssignmentTarget(
      reminder: reminder,
      assigneeSelector: assigneeSelector
    )
    try self.assignReminder(
      reminderID: reminder.id,
      target: target
    )
    return try verifyAssignmentPresent(reminder: reminder, target: target)
  }

  public func unassignReminder(
    reminder: ReminderDetail,
    assignment: ReminderAssignmentRecord,
    selector: String?
  ) throws -> ReminderDetail {
    try self.preflightAssignmentMutation(reminderID: reminder.id)
    try self.unassignReminder(
      reminderID: reminder.id,
      assignment: assignment,
      assignmentSelector: selector
    )
    return try verifyAssignmentAbsent(
      reminder: reminder,
      assignment: assignment,
      selector: selector
    )
  }

  func verifyAssignmentPresent(
    reminder: ReminderDetail,
    target: ReminderAssignmentTargetRecord
  ) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastReminder: ReminderDetail?
    var lastError: Error?

    repeat {
      do {
        let current = try enrichedReminderAfterAssignmentMutation(reminder)
        lastReminder = current
        if current.assignments.contains(where: {
          assignmentMatchesSelector($0, selector: target.assigneeIdentifier)
            || assignmentMatchesSelector($0, selector: target.assigneeLabel ?? "")
            || assignmentMatchesSelector($0, selector: target.assigneeAddress ?? "")
        }) {
          return current
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "assignee_identifier": target.assigneeIdentifier,
      "assignee_label": target.assigneeLabel ?? "",
      "actual_assignments": lastReminder.map { assignmentEvidenceSummary($0.assignments) } ?? "",
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app shared assignment update could not be verified.",
      details: details
    )
  }

  func verifyAssignmentAbsent(
    reminder: ReminderDetail,
    assignment: ReminderAssignmentRecord,
    selector: String?
  ) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastReminder: ReminderDetail?
    var lastError: Error?

    repeat {
      do {
        let current = try enrichedReminderAfterAssignmentMutation(reminder)
        lastReminder = current
        let stillPresent = current.assignments.contains { currentAssignment in
          if currentAssignment == assignment {
            return true
          }
          guard let selector else {
            return false
          }
          return assignmentMatchesSelector(currentAssignment, selector: selector)
        }
        if !stillPresent {
          return current
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "assignment_selector": selector ?? "",
      "expected_assignee_identifier": assignment.assigneeIdentifier ?? "",
      "expected_person_id": assignment.personId ?? "",
      "expected_contact_label": assignment.contactLabel ?? "",
      "actual_assignments": lastReminder.map { assignmentEvidenceSummary($0.assignments) } ?? "",
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app shared assignment removal could not be verified.",
      details: details
    )
  }

  func enrichedReminderAfterAssignmentMutation(_ reminder: ReminderDetail) throws
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

  func assignmentMatchesSelector(
    _ assignment: ReminderAssignmentRecord,
    selector: String
  ) -> Bool {
    let normalized = selector.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else {
      return false
    }
    return [
      assignment.assigneeIdentifier,
      assignment.personId,
      assignment.contactLabel,
      assignment.assignedAtRaw.map { String(describing: $0) },
    ]
    .compactMap { $0 }
    .contains { $0.localizedCaseInsensitiveCompare(normalized) == .orderedSame }
  }

  func assignmentEvidenceSummary(_ assignments: [ReminderAssignmentRecord]) -> String {
    assignments.map { assignment in
      [
        assignment.assigneeIdentifier ?? "",
        assignment.personId ?? "",
        assignment.contactLabel ?? "",
        assignment.assignedAtRaw.map { String(describing: $0) } ?? "",
      ].joined(separator: ":")
    }.joined(separator: ",")
  }
}
