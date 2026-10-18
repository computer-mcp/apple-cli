import ArgumentParser
import Utility

struct RemindersTemplateSaveOptions: ParsableArguments, Sendable {
  @Option(help: "Source Reminders list ID or exact title.")
  var list: String?

  @Option(help: "Template title.")
  var title: String?

  @Flag(name: .customLong("include-completed"), help: "Include completed reminders in the saved template.")
  var includeCompleted = false

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, title: title, includeCompleted: includeCompleted)
  }
}

struct RemindersTemplateCreateListOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "Title for the new list created from the template.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(title: title, template: template)
  }
}

struct RemindersTemplateUpdateOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "New template title.")
  var title: String?

  @Option(help: "Reminders color name or hex value such as blue or #0A84FF.")
  var color: String?

  @Option(help: "Reminders native badge token, such as shopping2.")
  var icon: String?

  @Option(help: "Sorting style such as manual, due-date, creation-date, priority, or title.")
  var sort: String?

  @Option(
    name: .customLong("show-large-attachments"),
    help: "Show image attachments as large previews: true or false.")
  var showLargeAttachments: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      title: title,
      template: template,
      color: color,
      icon: icon,
      sort: sort,
      showLargeAttachments: showLargeAttachments
    )
  }
}

struct RemindersTemplateReplaceOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "Source Reminders list ID or exact title.")
  var list: String?

  @Option(help: "Replacement template title. Defaults to the current template title.")
  var title: String?

  @Flag(name: .customLong("include-completed"), help: "Include completed reminders in the replacement template content.")
  var includeCompleted = false

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      list: list,
      title: title,
      template: template,
      includeCompleted: includeCompleted
    )
  }
}

struct RemindersTemplateOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(template: template)
  }
}

struct RemindersTemplateSectionCreateOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "Section title.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(title: title, template: template)
  }
}

struct RemindersTemplateSectionMutationOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "Template section ID or exact title.")
  var section: String?

  @Option(help: "New section title. Used by rename.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(title: title, section: section, template: template)
  }
}

struct RemindersTemplateSectionReorderOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "Template section ID or exact title to move.")
  var section: String?

  @Option(help: "Place the section before this template section ID or exact title.")
  var before: String?

  @Option(help: "Place the section after this template section ID or exact title.")
  var after: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(section: section, template: template, before: before, after: after)
  }
}

struct RemindersTemplateItemCreateOptions: ParsableArguments, Sendable {
  @Option(help: "Template ID or exact title.")
  var template: String?

  @Option(help: "Template item title.")
  var title: String?

  @Option(help: "Template item notes.")
  var notes: String?

  @Option(help: "User-visible URL/link card.")
  var url: String?

  @Option(help: "Due date or date-time, for example 2026-07-01 or 2026-07-01T09:00:00Z.")
  var due: String?

  @Option(help: "Location label for a coordinate-backed trigger.")
  var location: String?

  @Option(name: .customLong("location-latitude"), help: "Location trigger latitude.")
  var locationLatitude: String?

  @Option(name: .customLong("location-longitude"), help: "Location trigger longitude.")
  var locationLongitude: String?

  @Option(name: .customLong("location-radius-meters"), help: "Location trigger radius in meters.")
  var locationRadiusMeters: String?

  @Option(name: .customLong("location-proximity"), help: "Location proximity: entering or leaving.")
  var locationProximity: String?

  @Option(name: .customLong("alarm-at"), help: "Absolute alarm date-time.")
  var alarmAt: String?

  @Option(
    name: .customLong("repeat"),
    help: "Repeat frequency: hourly, daily, weekly, monthly, or yearly.")
  var repeatRule: String?

  @Option(name: .customLong("repeat-interval"), help: "Repeat interval.")
  var repeatInterval: String?

  @Option(name: .customLong("repeat-count"), help: "Maximum repeat count.")
  var repeatCount: String?

  @Option(name: .customLong("repeat-until"), help: "Repeat-until date.")
  var repeatUntil: String?

  @Option(
    name: .customLong("repeat-days-of-week"), help: "Comma-separated weekdays such as mon,wed.")
  var repeatDaysOfWeek: String?

  @Option(name: .customLong("repeat-weekday-positions"), help: "Weekday positions such as mon:2.")
  var repeatWeekdayPositions: String?

  @Option(name: .customLong("repeat-days-of-month"), help: "Comma-separated month days.")
  var repeatDaysOfMonth: String?

  @Option(name: .customLong("repeat-months-of-year"), help: "Comma-separated months.")
  var repeatMonthsOfYear: String?

  @Option(name: .customLong("repeat-set-positions"), help: "BYSETPOS-style positions such as -1.")
  var repeatSetPositions: String?

  @Option(help: "Priority integer accepted by Reminders, from 0 through 9.")
  var priority: String?

  @Option(help: "Flagged state: true or false.")
  var flagged: String?

  @Option(help: "Replace all tags with this comma-separated tag list.")
  var tags: String?

  @Option(help: "Template section ID or exact title for item section membership.")
  var section: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      title: title,
      notes: notes,
      url: url,
      due: due,
      location: location,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      locationRadiusMeters: locationRadiusMeters,
      locationProximity: locationProximity,
      alarmAt: alarmAt,
      repeatRule: repeatRule,
      repeatInterval: repeatInterval,
      repeatCount: repeatCount,
      repeatUntil: repeatUntil,
      repeatDaysOfWeek: repeatDaysOfWeek,
      repeatWeekdayPositions: repeatWeekdayPositions,
      repeatDaysOfMonth: repeatDaysOfMonth,
      repeatMonthsOfYear: repeatMonthsOfYear,
      repeatSetPositions: repeatSetPositions,
      priority: priority,
      flagged: flagged,
      section: section,
      template: template,
      tags: tags
    )
  }
}

struct RemindersTemplateItemUpdateOptions: ParsableArguments, Sendable {
  @Option(help: "Template saved reminder ID.")
  var id: String?

  @Option(help: "New template item title.")
  var title: String?

  @Option(help: "New template item notes.")
  var notes: String?

  @Option(help: "Replacement user-visible URL/link card.")
  var url: String?

  @Option(help: "Replacement due date or date-time.")
  var due: String?

  @Option(help: "Replacement location label for a coordinate-backed trigger.")
  var location: String?

  @Option(name: .customLong("location-latitude"), help: "Location trigger latitude.")
  var locationLatitude: String?

  @Option(name: .customLong("location-longitude"), help: "Location trigger longitude.")
  var locationLongitude: String?

  @Option(name: .customLong("location-radius-meters"), help: "Location trigger radius in meters.")
  var locationRadiusMeters: String?

  @Option(name: .customLong("location-proximity"), help: "Location proximity: entering or leaving.")
  var locationProximity: String?

  @Option(name: .customLong("alarm-at"), help: "Replacement absolute alarm date-time.")
  var alarmAt: String?

  @Option(
    name: .customLong("repeat"),
    help: "Repeat frequency: hourly, daily, weekly, monthly, or yearly.")
  var repeatRule: String?

  @Option(name: .customLong("repeat-interval"), help: "Repeat interval.")
  var repeatInterval: String?

  @Option(name: .customLong("repeat-count"), help: "Maximum repeat count.")
  var repeatCount: String?

  @Option(name: .customLong("repeat-until"), help: "Repeat-until date.")
  var repeatUntil: String?

  @Option(
    name: .customLong("repeat-days-of-week"), help: "Comma-separated weekdays such as mon,wed.")
  var repeatDaysOfWeek: String?

  @Option(name: .customLong("repeat-weekday-positions"), help: "Weekday positions such as mon:2.")
  var repeatWeekdayPositions: String?

  @Option(name: .customLong("repeat-days-of-month"), help: "Comma-separated month days.")
  var repeatDaysOfMonth: String?

  @Option(name: .customLong("repeat-months-of-year"), help: "Comma-separated months.")
  var repeatMonthsOfYear: String?

  @Option(name: .customLong("repeat-set-positions"), help: "BYSETPOS-style positions such as -1.")
  var repeatSetPositions: String?

  @Option(help: "Priority integer accepted by Reminders, from 0 through 9.")
  var priority: String?

  @Option(help: "Flagged state: true or false.")
  var flagged: String?

  @Option(help: "Replace all tags with this comma-separated tag list.")
  var tags: String?

  @Option(name: .customLong("add-tags"), help: "Comma-separated tags to add.")
  var addTags: String?

  @Option(name: .customLong("remove-tags"), help: "Comma-separated tags to remove.")
  var removeTags: String?

  @Option(help: "Template section ID or exact title for item section membership.")
  var section: String?

  @Flag(name: .customLong("clear-notes"), help: "Clear template item notes.")
  var clearNotes = false

  @Flag(name: .customLong("clear-url"), help: "Clear the visible URL/link card.")
  var clearUrl = false

  @Flag(name: .customLong("clear-due"), help: "Clear due date.")
  var clearDue = false

  @Flag(name: .customLong("clear-location"), help: "Clear location trigger.")
  var clearLocation = false

  @Flag(name: .customLong("clear-alarms"), help: "Clear absolute alarms.")
  var clearAlarms = false

  @Flag(name: .customLong("clear-repeat"), help: "Clear repeat rule.")
  var clearRepeat = false

  @Flag(name: .customLong("clear-tags"), help: "Clear all tags.")
  var clearTags = false

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      id: id,
      title: title,
      notes: notes,
      url: url,
      due: due,
      location: location,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      locationRadiusMeters: locationRadiusMeters,
      locationProximity: locationProximity,
      alarmAt: alarmAt,
      repeatRule: repeatRule,
      repeatInterval: repeatInterval,
      repeatCount: repeatCount,
      repeatUntil: repeatUntil,
      repeatDaysOfWeek: repeatDaysOfWeek,
      repeatWeekdayPositions: repeatWeekdayPositions,
      repeatDaysOfMonth: repeatDaysOfMonth,
      repeatMonthsOfYear: repeatMonthsOfYear,
      repeatSetPositions: repeatSetPositions,
      priority: priority,
      flagged: flagged,
      section: section,
      tags: tags,
      addTags: addTags,
      removeTags: removeTags,
      clearNotes: clearNotes,
      clearUrl: clearUrl,
      clearDue: clearDue,
      clearLocation: clearLocation,
      clearAlarms: clearAlarms,
      clearRepeat: clearRepeat,
      clearTags: clearTags
    )
  }
}

struct RemindersTemplateItemOptions: ParsableArguments, Sendable {
  @Option(help: "Template saved reminder ID.")
  var id: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id)
  }
}
