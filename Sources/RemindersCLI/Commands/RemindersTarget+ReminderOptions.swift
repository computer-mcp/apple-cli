import ArgumentParser
import Utility

struct RemindersListReadOptions: ParsableArguments, Sendable {
  @Option(help: "Filter to one reminder list ID or exact title.")
  var list: String?

  @Option(help: "Completion filter: incomplete, completed, or all.")
  var status: String?

  @Option(name: .customLong("due-from"), help: "Inclusive due-date lower bound.")
  var dueFrom: String?

  @Option(name: .customLong("due-to"), help: "Inclusive due-date upper bound.")
  var dueTo: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, status: status, dueFrom: dueFrom, dueTo: dueTo)
  }
}

struct RemindersSearchOptions: ParsableArguments, Sendable {
  @Option(help: "Search text matched against reminder title and notes.")
  var query: String?

  @Option(help: "Filter to one reminder list ID or exact title.")
  var list: String?

  @Option(help: "Completion filter: incomplete, completed, or all.")
  var status: String?

  @Option(name: .customLong("due-from"), help: "Inclusive due-date lower bound.")
  var dueFrom: String?

  @Option(name: .customLong("due-to"), help: "Inclusive due-date upper bound.")
  var dueTo: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      list: list,
      status: status,
      dueFrom: dueFrom,
      dueTo: dueTo,
      query: query
    )
  }
}

struct RemindersCreateOptions: ParsableArguments, Sendable {
  @Option(help: "Destination reminder list ID or exact title.")
  var list: String?

  @Option(help: "Reminder title.")
  var title: String?

  @Option(help: "Reminder notes/body text.")
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

  @Option(
    name: .customLong("early-reminder-minutes-before"),
    help: "Comma-separated minute offsets before a timed due date."
  )
  var earlyReminderMinutesBefore: String?

  @Option(name: .customLong("alarm-at"), help: "Absolute alarm date-time.")
  var alarmAt: String?

  @Option(
    name: .customLong("repeat"),
    help: "Repeat frequency: hourly, daily, weekly, monthly, or yearly.")
  var repeatRule: String?

  @Option(
    name: .customLong("repeat-interval"), help: "Repeat interval, for example 2 for every 2 weeks.")
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

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      list: list,
      title: title,
      notes: notes,
      url: url,
      due: due,
      location: location,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      locationRadiusMeters: locationRadiusMeters,
      locationProximity: locationProximity,
      earlyReminderMinutesBefore: earlyReminderMinutesBefore,
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
      priority: priority
    )
  }
}

struct RemindersUpdateOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID to update.")
  var id: String?

  @Option(help: "Move reminder to this list ID or exact title.")
  var list: String?

  @Option(help: "Replacement reminder title.")
  var title: String?

  @Option(help: "Replacement reminder notes/body text.")
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

  @Option(
    name: .customLong("early-reminder-minutes-before"),
    help: "Comma-separated minute offsets before a timed due date.")
  var earlyReminderMinutesBefore: String?

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

  @Option(help: "Urgent state: true or false.")
  var urgent: String?

  @Option(
    name: .customLong("messaging-person"),
    help: "When Messaging person selector, email, or phone handle.")
  var messagingPerson: String?

  @Option(help: "Replace all tags with this comma-separated tag list.")
  var tags: String?

  @Option(name: .customLong("add-tags"), help: "Comma-separated tags to add.")
  var addTags: String?

  @Option(name: .customLong("remove-tags"), help: "Comma-separated tags to remove.")
  var removeTags: String?

  @Option(help: "Section ID or exact title for item section membership.")
  var section: String?

  @Flag(name: .customLong("clear-notes"), help: "Clear notes.")
  var clearNotes = false

  @Flag(name: .customLong("clear-url"), help: "Clear the visible URL/link card.")
  var clearUrl = false

  @Flag(name: .customLong("clear-due"), help: "Clear due date.")
  var clearDue = false

  @Flag(name: .customLong("clear-location"), help: "Clear location trigger.")
  var clearLocation = false

  @Flag(name: .customLong("clear-early-reminders"), help: "Clear early reminder offsets.")
  var clearEarlyReminders = false

  @Flag(name: .customLong("clear-alarms"), help: "Clear absolute alarms.")
  var clearAlarms = false

  @Flag(name: .customLong("clear-repeat"), help: "Clear repeat rule.")
  var clearRepeat = false

  @Flag(name: .customLong("clear-tags"), help: "Clear all tags.")
  var clearTags = false

  @Flag(name: .customLong("clear-messaging-person"), help: "Clear When Messaging contact handles.")
  var clearMessagingPerson = false

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      list: list,
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
      earlyReminderMinutesBefore: earlyReminderMinutesBefore,
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
      urgent: urgent,
      messagingPerson: messagingPerson,
      section: section,
      tags: tags,
      addTags: addTags,
      removeTags: removeTags,
      clearNotes: clearNotes,
      clearUrl: clearUrl,
      clearDue: clearDue,
      clearLocation: clearLocation,
      clearEarlyReminders: clearEarlyReminders,
      clearAlarms: clearAlarms,
      clearRepeat: clearRepeat,
      clearTags: clearTags,
      clearMessagingPerson: clearMessagingPerson
    )
  }
}

struct RemindersIDsOptions: ParsableArguments, Sendable {
  @Option(help: "Comma-separated reminder IDs.")
  var ids: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(ids: ids) }
}

struct RemindersMatchingOptions: ParsableArguments, Sendable {
  @Option(help: "Filter to one reminder list ID or exact title.")
  var list: String?

  @Option(help: "Search text matched against reminder title and notes.")
  var query: String?

  @Option(name: .customLong("due-from"), help: "Inclusive due-date lower bound.")
  var dueFrom: String?

  @Option(name: .customLong("due-to"), help: "Inclusive due-date upper bound.")
  var dueTo: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, dueFrom: dueFrom, dueTo: dueTo, query: query)
  }
}

struct RemindersCleanupCompletedOptions: ParsableArguments, Sendable {
  @Option(help: "Filter cleanup to one reminder list ID or exact title.")
  var list: String?

  @Option(
    name: .customLong("completed-before"),
    help: "Delete completed reminders completed before this date.")
  var completedBefore: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, completedBefore: completedBefore)
  }
}
