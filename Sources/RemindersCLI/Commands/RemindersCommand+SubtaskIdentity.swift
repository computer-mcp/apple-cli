import Foundation
import Utility

extension RemindersCommand {
  func reminderSubtaskCreateIdentity(_ options: CLIOptions) throws
    -> ReminderSubtaskCreateIdentity
  {
    let parent = try reminderMutationIdentity(id: try requiredOption("parent-id", options: options))
    let title = try reminderRequiredTextOption("title", options: options)
    let bindingPayload = [
      parent.scopeDigest,
      title,
    ].joined(separator: "|")
    return ReminderSubtaskCreateIdentity(
      parent: parent,
      title: title,
      scopeDigest: "reminder-subtask-create:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "parent_id": parent.reminder.id,
        "parent_title": parent.reminder.title,
        "title": title,
      ]
    )
  }

  func reminderSubtaskMoveIdentity(
    _ options: CLIOptions,
    requireParent: Bool
  ) throws -> ReminderSubtaskMoveIdentity {
    let reminder = try reminderMutationIdentity(options)
    let parent: ReminderMutationIdentity?
    if requireParent {
      let parentIdentity = try reminderMutationIdentity(
        id: try requiredOption("parent-id", options: options)
      )
      guard parentIdentity.reminder.id != reminder.reminder.id else {
        throw CLIError(
          code: .validationError,
          message: "Reminder cannot be made a subtask of itself.",
          details: ["id": reminder.reminder.id]
        )
      }
      parent = parentIdentity
    } else {
      parent = nil
    }

    let bindingPayload = [
      reminder.scopeDigest,
      parent?.scopeDigest ?? "",
      reminder.reminder.parentReminderId ?? "",
      reminder.reminder.parentReminderTitle ?? "",
    ].joined(separator: "|")
    var summary = reminder.summaryFields.merging(
      [
        "current_parent_id": reminder.reminder.parentReminderId ?? "",
        "current_parent_title": reminder.reminder.parentReminderTitle ?? "",
      ],
      uniquingKeysWith: { _, new in new }
    )
    if let parent {
      summary["parent_id"] = parent.reminder.id
      summary["parent_title"] = parent.reminder.title
    }

    return ReminderSubtaskMoveIdentity(
      reminder: reminder,
      parent: parent,
      scopeDigest: "reminder-subtask-hierarchy:\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func validateReminderIsSubtask(_ reminder: ReminderDetail) throws {
    guard reminder.parentReminderId != nil || reminder.parentReminderTitle != nil else {
      throw CLIError(
        code: .validationError,
        message: "Reminder does not have read-only subtask parent evidence.",
        details: ["id": reminder.id]
      )
    }
  }
}
