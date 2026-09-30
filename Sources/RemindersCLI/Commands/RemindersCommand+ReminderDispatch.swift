import Foundation
import Utility

extension RemindersCommand {
  func runReminderItemCommand(_ options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["reminders", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["list", "status", "due-from", "due-to"])
      let query = try reminderQuery(options: options, searchText: nil)
      let reminders = try listReminders(query)
      return try result(
        RemindersResponse(reminders: reminders),
        human: remindersHumanOutput(reminders),
        options: options
      )
    case ["reminders", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(
        options, allowedOptions: ["list", "status", "due-from", "due-to", "query"])
      let searchText = try requiredOption("query", options: options)
      let query = try reminderQuery(options: options, searchText: searchText)
      let reminders = try listReminders(query)
      return try result(
        RemindersResponse(reminders: reminders),
        human: remindersHumanOutput(reminders),
        options: options
      )
    case ["reminders", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let reminder = try readReminder(id: id) else {
        throw CLIError(
          code: .notFound,
          message: "Reminder was not found.",
          details: ["id": id]
        )
      }
      return try result(
        ReminderResponse(reminder: reminder),
        human: reminderHumanOutput(reminder),
        options: options
      )
    case ["reminders", "create"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "list", "title", "notes", "url", "due", "location", "location-latitude",
          "location-longitude", "location-radius-meters", "location-proximity",
          "early-reminder-minutes-before", "alarm-at", "repeat", "repeat-interval",
          "repeat-count", "repeat-until", "repeat-days-of-week", "repeat-days-of-month",
          "repeat-weekday-positions", "repeat-months-of-year", "repeat-set-positions",
          "priority",
        ])
      try validateMutationIntent(options)
      let draft = try reminderCreateDraft(options)
      let bindingPayload = [
        draft.listId,
        draft.title,
        draft.notes ?? "",
        draft.url ?? "",
        draft.dueDate ?? "",
        draft.dueDateKind ?? "",
        reminderLocationSummary(draft.locationTrigger),
        minuteList(draft.earlyReminderMinutesBefore),
        dateList(draft.absoluteAlarmDates),
        reminderRepeatSummary(draft.repeatRule),
        "\(draft.priority)",
      ].joined(separator: "|")
      let scopeDigest = "reminder-create:\(sha256Hex(bindingPayload))"
      return try mutation(
        operation: "reminders.create",
        scopeDigest: scopeDigest,
        summary: [
          "list_id": draft.listId,
          "title": draft.title,
          "url": draft.url ?? "",
          "due": draft.dueDate ?? "",
          "location": reminderLocationSummary(draft.locationTrigger),
          "early_reminder_minutes_before": minuteList(draft.earlyReminderMinutesBefore),
          "alarm_at": dateList(draft.absoluteAlarmDates),
          "repeat": reminderRepeatSummary(draft.repeatRule),
          "priority": "\(draft.priority)",
        ],
        options: options
      ) {
        let reminder = try createReminder(draft)
        return ReminderMutationResult(
          operation: "reminders.create", changed: true, reminder: reminder, deletedID: nil)
      }
    case ["reminders", "update"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "id", "list", "title", "notes", "url", "due", "location", "location-latitude",
          "location-longitude", "location-radius-meters", "location-proximity",
          "early-reminder-minutes-before", "alarm-at", "repeat", "repeat-interval",
          "repeat-count", "repeat-until", "repeat-days-of-week", "repeat-days-of-month",
          "repeat-weekday-positions", "repeat-months-of-year", "repeat-set-positions",
          "priority", "flagged", "urgent", "messaging-person", "tags", "add-tags",
          "remove-tags", "section",
        ],
        allowedFlags: [
          "clear-notes", "clear-url", "clear-due", "clear-location", "clear-repeat",
          "clear-early-reminders", "clear-alarms", "clear-tags", "clear-messaging-person",
        ]
      )
      try validateMutationIntent(options)
      let identity = try reminderMutationIdentity(options)
      let patch = try reminderPatch(options, current: identity.reminder)
      guard patch.hasChanges else {
        throw CLIError(
          code: .validationError, message: "At least one reminder update field is required.")
      }
      return try mutation(
        operation: "reminders.update",
        scopeDigest: reminderUpdateScopeDigest(identity: identity, patch: patch),
        summary: identity.summaryFields.merging(
          reminderPatchSummary(patch), uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let reminder = try updateReminder(id: identity.reminder.id, patch: patch)
        return ReminderMutationResult(
          operation: "reminders.update",
          changed: true,
          reminder: reminder,
          deletedID: nil
        )
      }
    case ["reminders", "complete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "completed-at"])
      try validateMutationIntent(options)
      let identity = try reminderMutationIdentity(options)
      let completedAt = try optionalISO8601DateTime(
        options.targetOption("completed-at"),
        optionName: "completed-at"
      )
      let completedAtText = completedAt.map(formatDate)
      let scopeDigest = [
        identity.scopeDigest,
        "true",
        completedAtText ?? "",
      ].joined(separator: "|")
      let summary = identity.summaryFields.merging(
        ["target_completed_at": completedAtText ?? ""],
        uniquingKeysWith: { _, new in new })
      return try mutation(
        operation: "reminders.complete",
        scopeDigest: "reminder-completion:\(sha256Hex(scopeDigest))",
        summary: summary,
        options: options
      ) {
        let reminder = try setReminderCompleted(
          id: identity.reminder.id,
          completed: true,
          completedAt: completedAt
        )
        return ReminderMutationResult(
          operation: "reminders.complete",
          changed: identity.reminder.isCompleted == false
            || (completedAtText != nil && identity.reminder.completedAt != completedAtText),
          reminder: reminder,
          deletedID: nil
        )
      }
    case ["reminders", "uncomplete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let identity = try reminderMutationIdentity(options)
      return try mutation(
        operation: "reminders.uncomplete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try setReminderCompleted(id: identity.reminder.id, completed: false)
        return ReminderMutationResult(
          operation: "reminders.uncomplete",
          changed: identity.reminder.isCompleted == true,
          reminder: reminder,
          deletedID: nil
        )
      }
    case ["reminders", "complete-many"]:
      try validateTargetOptions(options, allowedOptions: ["ids"])
      try validateMutationIntent(options)
      let identities = try reminderMutationIdentities(ids: reminderIDsOption(options))
      return try completionBatchMutation(identities: identities, completed: true, options: options)
    case ["reminders", "uncomplete-many"]:
      try validateTargetOptions(options, allowedOptions: ["ids"])
      try validateMutationIntent(options)
      let identities = try reminderMutationIdentities(ids: reminderIDsOption(options))
      return try completionBatchMutation(identities: identities, completed: false, options: options)
    case ["reminders", "complete-matching"]:
      try validateTargetOptions(options, allowedOptions: ["list", "query", "due-from", "due-to"])
      try validateMutationIntent(options)
      try requireDestructiveSelectionIfExecuting(options, operation: "reminders.complete-matching")
      let context = try matchingCompletionContext(options, completed: true)
      return try matchingCompletionMutation(context: context, completed: true, options: options)
    case ["reminders", "uncomplete-matching"]:
      try validateTargetOptions(options, allowedOptions: ["list", "query", "due-from", "due-to"])
      try validateMutationIntent(options)
      try requireDestructiveSelectionIfExecuting(
        options, operation: "reminders.uncomplete-matching")
      let context = try matchingCompletionContext(options, completed: false)
      return try matchingCompletionMutation(context: context, completed: false, options: options)
    case ["reminders", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let identity = try reminderMutationIdentity(options)
      return try mutation(
        operation: "reminders.delete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let changed = try deleteReminder(id: identity.reminder.id)
        return ReminderMutationResult(
          operation: "reminders.delete",
          changed: changed,
          reminder: nil,
          deletedID: identity.reminder.id
        )
      }
    case ["reminders", "cleanup-completed"]:
      try validateTargetOptions(options, allowedOptions: ["list", "completed-before"])
      try validateMutationIntent(options)
      try requireDestructiveSelectionIfExecuting(options, operation: "reminders.cleanup-completed")
      let cleanup = try cleanupCompletedPlan(options)
      return try mutation(
        operation: "reminders.cleanup-completed",
        scopeDigest: cleanup.scopeDigest,
        summary: cleanup.summaryFields,
        options: options
      ) {
        let deletedIDs = try deleteReminders(ids: cleanup.candidates.map(\.id))
        return ReminderMutationResult(
          operation: "reminders.cleanup-completed",
          changed: !deletedIDs.isEmpty,
          deletedIDs: deletedIDs
        )
      }
    default:
      return nil
    }
  }
}
