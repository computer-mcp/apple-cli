import ArgumentParser
import Utility

public struct RemindersTargetOptions: ParsableArguments, Sendable {
  @Option public var list: String?
  @Option public var source: String?
  @Option public var status: String?
  @Option(name: .customLong("due-from")) public var dueFrom: String?
  @Option(name: .customLong("due-to")) public var dueTo: String?
  @Option public var query: String?
  @Option public var id: String?
  @Option(name: .customLong("parent-id")) public var parentId: String?
  @Option public var title: String?
  @Option public var notes: String?
  @Option public var url: String?
  @Option public var due: String?
  @Option public var location: String?
  @Option(name: .customLong("location-latitude")) public var locationLatitude: String?
  @Option(name: .customLong("location-longitude")) public var locationLongitude: String?
  @Option(name: .customLong("location-radius-meters")) public var locationRadiusMeters: String?
  @Option(name: .customLong("location-proximity")) public var locationProximity: String?
  @Option(name: .customLong("early-reminder-minutes-before"))
  public var earlyReminderMinutesBefore: String?
  @Option(name: .customLong("alarm-at")) public var alarmAt: String?
  @Option(name: .customLong("repeat")) public var repeatRule: String?
  @Option(name: .customLong("repeat-interval")) public var repeatInterval: String?
  @Option(name: .customLong("repeat-count")) public var repeatCount: String?
  @Option(name: .customLong("repeat-until")) public var repeatUntil: String?
  @Option(name: .customLong("repeat-days-of-week")) public var repeatDaysOfWeek: String?
  @Option(name: .customLong("repeat-weekday-positions")) public var repeatWeekdayPositions: String?
  @Option(name: .customLong("repeat-days-of-month")) public var repeatDaysOfMonth: String?
  @Option(name: .customLong("repeat-months-of-year")) public var repeatMonthsOfYear: String?
  @Option(name: .customLong("repeat-set-positions")) public var repeatSetPositions: String?
  @Option public var priority: String?
  @Option public var flagged: String?
  @Option public var urgent: String?
  @Option(name: .customLong("messaging-person")) public var messagingPerson: String?
  @Option public var section: String?
  @Option public var tag: String?
  @Option public var attachment: String?
  @Option public var assignee: String?
  @Option public var assignment: String?
  @Option public var file: String?
  @Option public var template: String?
  @Option public var group: String?
  @Option public var type: String?
  @Option public var color: String?
  @Option public var icon: String?
  @Option public var pinned: String?
  @Option public var sort: String?
  @Option(name: .customLong("show-large-attachments")) public var showLargeAttachments: String?
  @Option public var criteria: String?
  @Option public var match: String?
  @Option public var before: String?
  @Option public var after: String?
  @Option public var tags: String?
  @Option(name: .customLong("add-tags")) public var addTags: String?
  @Option(name: .customLong("remove-tags")) public var removeTags: String?
  @Option public var ids: String?
  @Option(name: .customLong("completed-before")) public var completedBefore: String?
  @Option(name: .customLong("completed-at")) public var completedAt: String?
  @Option public var scope: String?
  @Option(name: .customLong("max-depth")) public var maxDepth: String?
  @Flag(name: .customLong("clear-notes")) public var clearNotes = false
  @Flag(name: .customLong("clear-url")) public var clearUrl = false
  @Flag(name: .customLong("clear-due")) public var clearDue = false
  @Flag(name: .customLong("clear-location")) public var clearLocation = false
  @Flag(name: .customLong("clear-early-reminders")) public var clearEarlyReminders = false
  @Flag(name: .customLong("clear-alarms")) public var clearAlarms = false
  @Flag(name: .customLong("clear-repeat")) public var clearRepeat = false
  @Flag(name: .customLong("clear-tags")) public var clearTags = false
  @Flag(name: .customLong("clear-messaging-person")) public var clearMessagingPerson = false
  @Flag(name: .customLong("include-completed")) public var includeCompleted = false

  public init() {
    self.init(list: nil)
  }

  public init(
    list: String? = nil,
    source: String? = nil,
    status: String? = nil,
    dueFrom: String? = nil,
    dueTo: String? = nil,
    query: String? = nil,
    id: String? = nil,
    parentId: String? = nil,
    title: String? = nil,
    notes: String? = nil,
    url: String? = nil,
    due: String? = nil,
    location: String? = nil,
    locationLatitude: String? = nil,
    locationLongitude: String? = nil,
    locationRadiusMeters: String? = nil,
    locationProximity: String? = nil,
    earlyReminderMinutesBefore: String? = nil,
    alarmAt: String? = nil,
    repeatRule: String? = nil,
    repeatInterval: String? = nil,
    repeatCount: String? = nil,
    repeatUntil: String? = nil,
    repeatDaysOfWeek: String? = nil,
    repeatWeekdayPositions: String? = nil,
    repeatDaysOfMonth: String? = nil,
    repeatMonthsOfYear: String? = nil,
    repeatSetPositions: String? = nil,
    priority: String? = nil,
    flagged: String? = nil,
    urgent: String? = nil,
    messagingPerson: String? = nil,
    section: String? = nil,
    tag: String? = nil,
    attachment: String? = nil,
    assignee: String? = nil,
    assignment: String? = nil,
    file: String? = nil,
    template: String? = nil,
    group: String? = nil,
    type: String? = nil,
    color: String? = nil,
    icon: String? = nil,
    pinned: String? = nil,
    sort: String? = nil,
    showLargeAttachments: String? = nil,
    criteria: String? = nil,
    match: String? = nil,
    before: String? = nil,
    after: String? = nil,
    tags: String? = nil,
    addTags: String? = nil,
    removeTags: String? = nil,
    ids: String? = nil,
    completedBefore: String? = nil,
    completedAt: String? = nil,
    scope: String? = nil,
    maxDepth: String? = nil,
    clearNotes: Bool = false,
    clearUrl: Bool = false,
    clearDue: Bool = false,
    clearLocation: Bool = false,
    clearEarlyReminders: Bool = false,
    clearAlarms: Bool = false,
    clearRepeat: Bool = false,
    clearTags: Bool = false,
    clearMessagingPerson: Bool = false,
    includeCompleted: Bool = false
  ) {
    self.list = list
    self.source = source
    self.status = status
    self.dueFrom = dueFrom
    self.dueTo = dueTo
    self.query = query
    self.id = id
    self.parentId = parentId
    self.title = title
    self.notes = notes
    self.url = url
    self.due = due
    self.location = location
    self.locationLatitude = locationLatitude
    self.locationLongitude = locationLongitude
    self.locationRadiusMeters = locationRadiusMeters
    self.locationProximity = locationProximity
    self.earlyReminderMinutesBefore = earlyReminderMinutesBefore
    self.alarmAt = alarmAt
    self.repeatRule = repeatRule
    self.repeatInterval = repeatInterval
    self.repeatCount = repeatCount
    self.repeatUntil = repeatUntil
    self.repeatDaysOfWeek = repeatDaysOfWeek
    self.repeatWeekdayPositions = repeatWeekdayPositions
    self.repeatDaysOfMonth = repeatDaysOfMonth
    self.repeatMonthsOfYear = repeatMonthsOfYear
    self.repeatSetPositions = repeatSetPositions
    self.priority = priority
    self.flagged = flagged
    self.urgent = urgent
    self.messagingPerson = messagingPerson
    self.section = section
    self.tag = tag
    self.attachment = attachment
    self.assignee = assignee
    self.assignment = assignment
    self.file = file
    self.template = template
    self.group = group
    self.type = type
    self.color = color
    self.icon = icon
    self.pinned = pinned
    self.sort = sort
    self.showLargeAttachments = showLargeAttachments
    self.criteria = criteria
    self.match = match
    self.before = before
    self.after = after
    self.tags = tags
    self.addTags = addTags
    self.removeTags = removeTags
    self.ids = ids
    self.completedBefore = completedBefore
    self.completedAt = completedAt
    self.scope = scope
    self.maxDepth = maxDepth
    self.clearNotes = clearNotes
    self.clearUrl = clearUrl
    self.clearDue = clearDue
    self.clearLocation = clearLocation
    self.clearEarlyReminders = clearEarlyReminders
    self.clearAlarms = clearAlarms
    self.clearRepeat = clearRepeat
    self.clearTags = clearTags
    self.clearMessagingPerson = clearMessagingPerson
    self.includeCompleted = includeCompleted
  }

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("list", list),
      ("source", source),
      ("status", status),
      ("due-from", dueFrom),
      ("due-to", dueTo),
      ("query", query),
      ("id", id),
      ("parent-id", parentId),
      ("title", title),
      ("notes", notes),
      ("url", url),
      ("due", due),
      ("location", location),
      ("location-latitude", locationLatitude),
      ("location-longitude", locationLongitude),
      ("location-radius-meters", locationRadiusMeters),
      ("location-proximity", locationProximity),
      ("early-reminder-minutes-before", earlyReminderMinutesBefore),
      ("alarm-at", alarmAt),
      ("repeat", repeatRule),
      ("repeat-interval", repeatInterval),
      ("repeat-count", repeatCount),
      ("repeat-until", repeatUntil),
      ("repeat-days-of-week", repeatDaysOfWeek),
      ("repeat-weekday-positions", repeatWeekdayPositions),
      ("repeat-days-of-month", repeatDaysOfMonth),
      ("repeat-months-of-year", repeatMonthsOfYear),
      ("repeat-set-positions", repeatSetPositions),
      ("priority", priority),
      ("flagged", flagged),
      ("urgent", urgent),
      ("messaging-person", messagingPerson),
      ("section", section),
      ("tag", tag),
      ("attachment", attachment),
      ("assignee", assignee),
      ("assignment", assignment),
      ("file", file),
      ("template", template),
      ("group", group),
      ("type", type),
      ("color", color),
      ("icon", icon),
      ("pinned", pinned),
      ("sort", sort),
      ("show-large-attachments", showLargeAttachments),
      ("criteria", criteria),
      ("match", match),
      ("before", before),
      ("after", after),
      ("tags", tags),
      ("add-tags", addTags),
      ("remove-tags", removeTags),
      ("ids", ids),
      ("completed-before", completedBefore),
      ("completed-at", completedAt),
      ("scope", scope),
      ("max-depth", maxDepth),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("clear-notes", clearNotes),
      ("clear-url", clearUrl),
      ("clear-due", clearDue),
      ("clear-location", clearLocation),
      ("clear-early-reminders", clearEarlyReminders),
      ("clear-alarms", clearAlarms),
      ("clear-repeat", clearRepeat),
      ("clear-tags", clearTags),
      ("clear-messaging-person", clearMessagingPerson),
      ("include-completed", includeCompleted),
    ])
  }
}
