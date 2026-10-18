import Foundation
import Utility

extension RemindersCommand {
  func reminderAssignmentAssignIdentity(_ options: CLIOptions) throws
    -> ReminderAssignmentMutationIdentity
  {
    let reminder = try reminderMutationIdentity(options)
    let assignee = try reminderRequiredTextOption("assignee", options: options)
    let assignmentsHash = reminderAssignmentEvidenceHash(reminder.reminder.assignments)
    let bindingPayload = [
      reminder.scopeDigest,
      assignee,
      assignmentsHash,
    ].joined(separator: "|")
    var summary = reminder.summaryFields
    summary["operation"] = "assign"
    summary["assignee"] = assignee
    summary["assignment_count"] = "\(reminder.reminder.assignments.count)"
    summary["assignments_sha256"] = assignmentsHash

    return ReminderAssignmentMutationIdentity(
      reminder: reminder,
      assigneeSelector: assignee,
      assignmentEvidenceSHA256: assignmentsHash,
      scopeDigest: "reminder-assignment-assign:\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func reminderAssignmentUnassignIdentity(_ options: CLIOptions) throws
    -> ReminderAssignmentMutationIdentity
  {
    let reminder = try reminderMutationIdentity(options)
    let selector = options.targetOption("assignment")?.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    let normalizedSelector = selector?.isEmpty == true ? nil : selector
    let (assignment, selectedSelector) = try reminderAssignment(
      selector: normalizedSelector,
      in: reminder.reminder.assignments
    )
    let assignmentsHash = reminderAssignmentEvidenceHash(reminder.reminder.assignments)
    let bindingPayload = [
      reminder.scopeDigest,
      selectedSelector ?? "",
      reminderAssignmentScopeDigest(assignment),
      assignmentsHash,
    ].joined(separator: "|")
    var summary = reminder.summaryFields
    summary["operation"] = "unassign"
    summary["assignment_selector"] = selectedSelector ?? ""
    summary["assignment_assignee_identifier"] = assignment.assigneeIdentifier ?? ""
    summary["assignment_person_id"] = assignment.personId ?? ""
    summary["assignment_contact_label"] = assignment.contactLabel ?? ""
    summary["assignment_assigned_at_raw"] =
      assignment.assignedAtRaw.map { String(describing: $0) } ?? ""
    summary["assignment_count"] = "\(reminder.reminder.assignments.count)"
    summary["assignments_sha256"] = assignmentsHash

    return ReminderAssignmentMutationIdentity(
      reminder: reminder,
      assignment: assignment,
      assignmentSelector: selectedSelector,
      assignmentEvidenceSHA256: assignmentsHash,
      scopeDigest: "reminder-assignment-unassign:\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func reminderAssignment(
    selector: String?,
    in assignments: [ReminderAssignmentRecord]
  ) throws -> (ReminderAssignmentRecord, String?) {
    guard let selector, !selector.isEmpty else {
      if assignments.count == 1, let assignment = assignments.first {
        return (assignment, nil)
      }
      if assignments.isEmpty {
        throw CLIError(
          code: .notFound,
          message: "Reminder has no shared assignment evidence.",
          details: ["assignment_count": "0"]
        )
      }
      throw CLIError(
        code: .ambiguousIdentity,
        message: "`assignments unassign` requires `--assignment` when multiple assignments exist.",
        details: ["assignment_count": "\(assignments.count)"]
      )
    }

    if selector.hasPrefix("#"),
      let index = Int(selector.dropFirst()),
      assignments.indices.contains(index - 1)
    {
      return (assignments[index - 1], selector)
    }

    let matches = assignments.filter {
      reminderAssignmentMatchesSelector($0, selector: selector)
    }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Assignment selector matched multiple assignments.",
        details: ["selector": selector]
      )
    }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Assignment selector did not match any assignment on the reminder.",
        details: [
          "selector": selector,
          "assignment_count": "\(assignments.count)",
        ]
      )
    }
    return (match, selector)
  }

  func reminderAssignmentMatchesSelector(
    _ assignment: ReminderAssignmentRecord,
    selector: String
  ) -> Bool {
    guard !selector.isEmpty else {
      return false
    }
    return [
      assignment.assigneeIdentifier,
      assignment.personId,
      assignment.contactLabel,
      assignment.assignedAtRaw.map { String(describing: $0) },
    ]
    .compactMap { $0 }
    .contains { $0.localizedCaseInsensitiveCompare(selector) == .orderedSame }
  }

  func reminderAssignmentEvidenceHash(_ assignments: [ReminderAssignmentRecord]) -> String {
    let payload =
      assignments
      .sorted {
        reminderAssignmentScopeDigest($0) < reminderAssignmentScopeDigest($1)
      }
      .map(reminderAssignmentScopeDigest)
      .joined(separator: "\n")
    return sha256Hex("\(assignments.count)|\(payload)")
  }

  func reminderAssignmentScopeDigest(_ assignment: ReminderAssignmentRecord) -> String {
    [
      assignment.assigneeIdentifier ?? "",
      assignment.personId ?? "",
      assignment.contactLabel ?? "",
      assignment.assignedAtRaw.map { String(describing: $0) } ?? "",
    ].joined(separator: "\u{1F}")
  }
}
