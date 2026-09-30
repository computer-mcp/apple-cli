import Foundation
import Utility

extension RemindersCommand {
  func reminderCreateDraft(_ options: CLIOptions) throws -> ReminderCreateDraft {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError, message: "Reminder list does not allow modifications.",
        details: ["list": list.title])
    }

    let title = try requiredOption("title", options: options).trimmingCharacters(
      in: .whitespacesAndNewlines)
    guard !title.isEmpty else {
      throw CLIError(code: .validationError, message: "`--title` must not be empty.")
    }

    let due = try reminderDueInput(options.targetOption("due"))
    let repeatRule = try reminderRepeatOption(
      options,
      effectiveDueDate: try reminderRepeatDueDate(value: due.value, kind: due.kind)
    )
    let locationTrigger = try reminderLocationOption(options)
    let earlyReminderMinutesBefore = try reminderEarlyReminderMinutesBeforeOption(options) ?? []
    try validateEarlyReminderAnchor(
      minutesBefore: earlyReminderMinutesBefore,
      dueDate: due.value,
      dueDateKind: due.kind
    )
    let absoluteAlarmDates = try reminderAlarmAtOption(options) ?? []
    return ReminderCreateDraft(
      listId: list.id,
      title: title,
      notes: options.targetOption("notes"),
      url: try reminderURL(options.targetOption("url"))?.absoluteString,
      priority: try reminderPriority(options.targetOption("priority")),
      dueDate: due.value,
      dueDateKind: due.kind,
      repeatRule: repeatRule,
      locationTrigger: locationTrigger,
      earlyReminderMinutesBefore: earlyReminderMinutesBefore,
      absoluteAlarmDates: absoluteAlarmDates
    )
  }

  func reminderPatch(_ options: CLIOptions, current: ReminderDetail) throws
    -> ReminderPatch
  {
    let listId: String?
    if let listSelector = options.targetOption("list") {
      let list = try reminderList(selector: listSelector)
      guard list.allowsContentModifications else {
        throw CLIError(
          code: .validationError, message: "Reminder list does not allow modifications.",
          details: ["list": list.title])
      }
      listId = list.id
    } else {
      listId = nil
    }

    let title = options.targetOption("title")?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let title, title.isEmpty {
      throw CLIError(code: .validationError, message: "`--title` must not be empty.")
    }

    if options.targetOption("notes") != nil, options.hasTargetFlag("clear-notes") {
      throw CLIError(
        code: .validationError, message: "`--notes` cannot be combined with `--clear-notes`.")
    }
    if options.targetOption("url") != nil, options.hasTargetFlag("clear-url") {
      throw CLIError(
        code: .validationError, message: "`--url` cannot be combined with `--clear-url`.")
    }
    if options.targetOption("due") != nil, options.hasTargetFlag("clear-due") {
      throw CLIError(
        code: .validationError, message: "`--due` cannot be combined with `--clear-due`.")
    }
    if hasReminderLocationOptions(options), options.hasTargetFlag("clear-location") {
      throw CLIError(
        code: .validationError, message: "`--location` cannot be combined with `--clear-location`.")
    }
    if options.targetOption("alarm-at") != nil, options.hasTargetFlag("clear-alarms") {
      throw CLIError(
        code: .validationError, message: "`--alarm-at` cannot be combined with `--clear-alarms`.")
    }
    if options.targetOption("early-reminder-minutes-before") != nil,
      options.hasTargetFlag("clear-early-reminders")
    {
      throw CLIError(
        code: .validationError,
        message:
          "`--early-reminder-minutes-before` cannot be combined with `--clear-early-reminders`."
      )
    }
    if options.hasTargetFlag("clear-repeat"), hasReminderRepeatOptions(options) {
      throw CLIError(
        code: .validationError, message: "`--clear-repeat` cannot be combined with repeat options.")
    }
    if options.targetOption("tags") != nil,
      options.targetOption("add-tags") != nil || options.targetOption("remove-tags") != nil
        || options.hasTargetFlag("clear-tags")
    {
      throw CLIError(
        code: .validationError,
        message: "`--tags` cannot be combined with add/remove/clear tag options."
      )
    }
    if options.hasTargetFlag("clear-tags"),
      options.targetOption("add-tags") != nil || options.targetOption("remove-tags") != nil
    {
      throw CLIError(
        code: .validationError,
        message: "`--clear-tags` cannot be combined with add/remove tag options."
      )
    }
    if options.targetOption("messaging-person") != nil,
      options.hasTargetFlag("clear-messaging-person")
    {
      throw CLIError(
        code: .validationError,
        message: "`--messaging-person` cannot be combined with `--clear-messaging-person`."
      )
    }

    let due = try reminderDueInput(options.targetOption("due"))
    let clearDue = options.hasTargetFlag("clear-due")
    let clearEarlyReminders = options.hasTargetFlag("clear-early-reminders")
    if clearDue, current.repeatRule != nil, !options.hasTargetFlag("clear-repeat") {
      throw CLIError(
        code: .validationError,
        message: "`--clear-due` on a repeating reminder must also include `--clear-repeat`."
      )
    }
    if clearDue, !current.earlyReminderMinutesBefore.isEmpty, !clearEarlyReminders {
      throw CLIError(
        code: .validationError,
        message:
          "`--clear-due` on a reminder with early reminders must also include `--clear-early-reminders`."
      )
    }
    if due.kind == "date", !current.earlyReminderMinutesBefore.isEmpty,
      !clearEarlyReminders,
      options.targetOption("early-reminder-minutes-before") == nil
    {
      throw CLIError(
        code: .validationError,
        message:
          "Changing a reminder with early reminders to a date-only due date must also include `--clear-early-reminders`."
      )
    }
    let effectiveDueDate: Date?
    if clearDue {
      effectiveDueDate = nil
    } else if let dueDate = due.value {
      effectiveDueDate = try reminderRepeatDueDate(value: dueDate, kind: due.kind)
    } else {
      effectiveDueDate = try reminderRepeatDueDate(
        value: current.dueDate, kind: current.dueDateKind)
    }
    let repeatRule = try reminderRepeatOption(options, effectiveDueDate: effectiveDueDate)
    let locationTrigger = try reminderLocationOption(options)
    let earlyReminderMinutesBefore = try reminderEarlyReminderMinutesBeforeOption(options)
    try validateEarlyReminderAnchor(
      minutesBefore: earlyReminderMinutesBefore,
      dueDate: clearDue ? nil : (due.value ?? current.dueDate),
      dueDateKind: clearDue ? nil : (due.kind ?? current.dueDateKind)
    )
    let absoluteAlarmDates = try reminderAlarmAtOption(options)
    let priority = try options.targetOption("priority").map { try reminderPriority($0) }
    let flagged = try options.targetOption("flagged").map {
      try reminderBool($0, optionName: "flagged")
    }
    let urgent = try options.targetOption("urgent").map {
      try reminderBool($0, optionName: "urgent")
    }
    let messagingPerson = try reminderListTextOption(
      options.targetOption("messaging-person"),
      optionName: "messaging-person"
    )
    let sectionTitle = try reminderSectionOption(options.targetOption("section"))
    let tags = try options.targetOption("tags").map {
      try reminderTagsOption($0, optionName: "tags")
    }
    let addTags = try reminderTagsOption(options.targetOption("add-tags"), optionName: "add-tags")
    let removeTags = try reminderTagsOption(
      options.targetOption("remove-tags"), optionName: "remove-tags")
    return ReminderPatch(
      listId: listId,
      title: title,
      notes: options.targetOption("notes"),
      clearNotes: options.hasTargetFlag("clear-notes"),
      url: try reminderURL(options.targetOption("url"))?.absoluteString,
      clearUrl: options.hasTargetFlag("clear-url"),
      priority: priority,
      dueDate: due.value,
      dueDateKind: due.kind,
      clearDueDate: clearDue,
      repeatRule: repeatRule,
      clearRepeat: options.hasTargetFlag("clear-repeat"),
      locationTrigger: locationTrigger,
      clearLocation: options.hasTargetFlag("clear-location"),
      earlyReminderMinutesBefore: earlyReminderMinutesBefore,
      clearEarlyReminders: clearEarlyReminders,
      absoluteAlarmDates: absoluteAlarmDates,
      clearAlarms: options.hasTargetFlag("clear-alarms"),
      flagged: flagged,
      sectionTitle: sectionTitle,
      tags: tags,
      addTags: addTags,
      removeTags: removeTags,
      clearTags: options.hasTargetFlag("clear-tags"),
      urgent: urgent,
      messagingPerson: messagingPerson,
      clearMessagingPerson: options.hasTargetFlag("clear-messaging-person")
    )
  }

  func reminderMutationIdentity(_ options: CLIOptions) throws -> ReminderMutationIdentity {
    let id = try requiredOption("id", options: options)
    return try reminderMutationIdentity(id: id)
  }

  func reminderMutationIdentity(id: String) throws -> ReminderMutationIdentity {
    guard let reminder = try readReminder(id: id) else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }

    let bindingPayload = [
      reminder.id,
      reminder.listId,
      reminder.title,
      "\(reminder.isCompleted)",
      reminder.completedAt ?? "",
      reminder.createdAt ?? "",
      reminder.modifiedAt ?? "",
      reminder.url ?? "",
      reminder.dueDate ?? "",
      reminderLocationSummary(reminder.locationTriggers),
      minuteList(reminder.earlyReminderMinutesBefore),
      dateList(reminder.absoluteAlarmDates),
      reminderRepeatSummary(reminder.repeatRule),
      "\(reminder.priority)",
      reminder.isFlagged.map(String.init) ?? "",
      reminder.sectionId ?? "",
      reminder.sectionTitle ?? "",
    ].joined(separator: "|")

    return ReminderMutationIdentity(
      reminder: reminder,
      scopeDigest: "reminder:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "id": reminder.id,
        "title": reminder.title,
        "list_id": reminder.listId,
        "completed": "\(reminder.isCompleted)",
        "completed_at": reminder.completedAt ?? "",
        "created_at": reminder.createdAt ?? "",
        "modified_at": reminder.modifiedAt ?? "",
        "location": reminderLocationSummary(reminder.locationTriggers),
        "early_reminder_minutes_before": minuteList(reminder.earlyReminderMinutesBefore),
        "alarm_at": dateList(reminder.absoluteAlarmDates),
        "repeat": reminderRepeatSummary(reminder.repeatRule),
        "flagged": reminder.isFlagged.map(String.init) ?? "",
        "section_id": reminder.sectionId ?? "",
        "section": reminder.sectionTitle ?? "",
      ]
    )
  }
}
