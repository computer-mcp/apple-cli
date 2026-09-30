import Foundation
import Utility

extension RemindersCommand {
  func reminderTemplateItemCreateInput(_ options: CLIOptions) throws
    -> (title: String, patch: ReminderPatch)
  {
    let title = try reminderRequiredTextOption("title", options: options)
    let due = try reminderDueInput(options.targetOption("due"))
    let repeatRule = try reminderRepeatOption(
      options,
      effectiveDueDate: try reminderRepeatDueDate(value: due.value, kind: due.kind)
    )
    let locationTrigger = try reminderLocationOption(options)
    let absoluteAlarmDates = try reminderAlarmAtOption(options) ?? []
    let flagged = try options.targetOption("flagged").map {
      try reminderBool($0, optionName: "flagged")
    }
    let sectionTitle = try reminderSectionOption(options.targetOption("section"))
    let tags = try options.targetOption("tags").map {
      try reminderTagsOption($0, optionName: "tags")
    }

    return (
      title,
      ReminderPatch(
        notes: options.targetOption("notes"),
        url: try reminderURL(options.targetOption("url"))?.absoluteString,
        priority: try options.targetOption("priority").map { try reminderPriority($0) },
        dueDate: due.value,
        dueDateKind: due.kind,
        repeatRule: repeatRule,
        locationTrigger: locationTrigger,
        absoluteAlarmDates: absoluteAlarmDates,
        flagged: flagged,
        sectionTitle: sectionTitle,
        tags: tags
      )
    )
  }

  func reminderTemplateItemPatch(_ options: CLIOptions, current: ReminderDetail) throws
    -> ReminderPatch
  {
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

    let due = try reminderDueInput(options.targetOption("due"))
    let clearDue = options.hasTargetFlag("clear-due")
    if clearDue, current.repeatRule != nil, !options.hasTargetFlag("clear-repeat") {
      throw CLIError(
        code: .validationError,
        message: "`--clear-due` on a repeating reminder must also include `--clear-repeat`."
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
    let absoluteAlarmDates = try reminderAlarmAtOption(options)
    let flagged = try options.targetOption("flagged").map {
      try reminderBool($0, optionName: "flagged")
    }
    let sectionTitle = try reminderSectionOption(options.targetOption("section"))
    let tags = try options.targetOption("tags").map {
      try reminderTagsOption($0, optionName: "tags")
    }
    let addTags = try reminderTagsOption(options.targetOption("add-tags"), optionName: "add-tags")
    let removeTags = try reminderTagsOption(
      options.targetOption("remove-tags"), optionName: "remove-tags")

    return ReminderPatch(
      title: title,
      notes: options.targetOption("notes"),
      clearNotes: options.hasTargetFlag("clear-notes"),
      url: try reminderURL(options.targetOption("url"))?.absoluteString,
      clearUrl: options.hasTargetFlag("clear-url"),
      priority: try options.targetOption("priority").map { try reminderPriority($0) },
      dueDate: due.value,
      dueDateKind: due.kind,
      clearDueDate: clearDue,
      repeatRule: repeatRule,
      clearRepeat: options.hasTargetFlag("clear-repeat"),
      locationTrigger: locationTrigger,
      clearLocation: options.hasTargetFlag("clear-location"),
      absoluteAlarmDates: absoluteAlarmDates,
      clearAlarms: options.hasTargetFlag("clear-alarms"),
      flagged: flagged,
      sectionTitle: sectionTitle,
      tags: tags,
      addTags: addTags,
      removeTags: removeTags,
      clearTags: options.hasTargetFlag("clear-tags")
    )
  }
}
