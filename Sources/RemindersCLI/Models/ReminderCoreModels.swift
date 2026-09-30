import Foundation

public enum ReminderCompletionFilter: String, Codable, Equatable, Sendable {
  case all
  case completed
  case incomplete
}

public struct ReminderQuery: Equatable, Sendable {
  public var listSelector: String?
  public var completion: ReminderCompletionFilter
  public var completedBefore: Date?
  public var dueFrom: Date?
  public var dueTo: Date?
  public var searchText: String?
  public var limit: Int

  public init(
    listSelector: String? = nil,
    completion: ReminderCompletionFilter = .incomplete,
    completedBefore: Date? = nil,
    dueFrom: Date? = nil,
    dueTo: Date? = nil,
    searchText: String? = nil,
    limit: Int
  ) {
    self.listSelector = listSelector
    self.completion = completion
    self.completedBefore = completedBefore
    self.dueFrom = dueFrom
    self.dueTo = dueTo
    self.searchText = searchText
    self.limit = limit
  }
}

public struct ReminderSummary: Codable, Equatable, Sendable {
  public var id: String
  public var listId: String
  public var listTitle: String
  public var title: String
  public var isCompleted: Bool
  public var completedAt: String?
  public var createdAt: String?
  public var modifiedAt: String?
  public var url: String?
  public var priority: Int
  public var dueDate: String?
  public var dueDateKind: String?
  public var repeatRule: ReminderRepeatRule?
  public var locationTriggers: [ReminderLocationTrigger]
  public var earlyReminderMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var tags: [String]
  public var isFlagged: Bool?
  public var isUrgent: Bool?
  public var sectionId: String?
  public var sectionTitle: String?
  public var parentReminderId: String?
  public var parentReminderTitle: String?
  public var subtaskCount: Int
  public var attachments: [ReminderAttachmentRecord]
  public var assignments: [ReminderAssignmentRecord]
  public var messagingContactHandles: [ReminderMessagingContactRecord]

  public init(
    id: String,
    listId: String,
    listTitle: String,
    title: String,
    isCompleted: Bool,
    completedAt: String? = nil,
    createdAt: String? = nil,
    modifiedAt: String? = nil,
    url: String? = nil,
    priority: Int,
    dueDate: String? = nil,
    dueDateKind: String? = nil,
    repeatRule: ReminderRepeatRule? = nil,
    locationTriggers: [ReminderLocationTrigger] = [],
    earlyReminderMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    tags: [String] = [],
    isFlagged: Bool? = nil,
    isUrgent: Bool? = nil,
    sectionId: String? = nil,
    sectionTitle: String? = nil,
    parentReminderId: String? = nil,
    parentReminderTitle: String? = nil,
    subtaskCount: Int = 0,
    attachments: [ReminderAttachmentRecord] = [],
    assignments: [ReminderAssignmentRecord] = [],
    messagingContactHandles: [ReminderMessagingContactRecord] = []
  ) {
    self.id = id
    self.listId = listId
    self.listTitle = listTitle
    self.title = title
    self.isCompleted = isCompleted
    self.completedAt = completedAt
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
    self.url = url
    self.priority = priority
    self.dueDate = dueDate
    self.dueDateKind = dueDateKind
    self.repeatRule = repeatRule
    self.locationTriggers = locationTriggers
    self.earlyReminderMinutesBefore = earlyReminderMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.tags = tags
    self.isFlagged = isFlagged
    self.isUrgent = isUrgent
    self.sectionId = sectionId
    self.sectionTitle = sectionTitle
    self.parentReminderId = parentReminderId
    self.parentReminderTitle = parentReminderTitle
    self.subtaskCount = subtaskCount
    self.attachments = attachments
    self.assignments = assignments
    self.messagingContactHandles = messagingContactHandles
  }
}

public struct ReminderRepeatRule: Codable, Equatable, Sendable {
  public var frequency: String
  public var interval: Int
  public var occurrenceCount: Int?
  public var until: Date?
  public var daysOfWeek: [String]
  public var weekdayPositions: [ReminderRepeatWeekdayPosition]
  public var daysOfMonth: [Int]
  public var monthsOfYear: [Int]
  public var setPositions: [Int]

  public init(
    frequency: String,
    interval: Int = 1,
    occurrenceCount: Int? = nil,
    until: Date? = nil,
    daysOfWeek: [String] = [],
    weekdayPositions: [ReminderRepeatWeekdayPosition] = [],
    daysOfMonth: [Int] = [],
    monthsOfYear: [Int] = [],
    setPositions: [Int] = []
  ) {
    self.frequency = frequency
    self.interval = interval
    self.occurrenceCount = occurrenceCount
    self.until = until
    self.daysOfWeek = daysOfWeek
    self.weekdayPositions = weekdayPositions
    self.daysOfMonth = daysOfMonth
    self.monthsOfYear = monthsOfYear
    self.setPositions = setPositions
  }
}

public struct ReminderRepeatWeekdayPosition: Codable, Equatable, Sendable {
  public var weekday: String
  public var weekNumber: Int

  public init(weekday: String, weekNumber: Int) {
    self.weekday = weekday
    self.weekNumber = weekNumber
  }
}

public struct ReminderLocationTrigger: Codable, Equatable, Sendable {
  public var title: String
  public var latitude: Double?
  public var longitude: Double?
  public var radiusMeters: Double?
  public var proximity: String

  public init(
    title: String,
    latitude: Double? = nil,
    longitude: Double? = nil,
    radiusMeters: Double? = nil,
    proximity: String = "entering"
  ) {
    self.title = title
    self.latitude = latitude
    self.longitude = longitude
    self.radiusMeters = radiusMeters
    self.proximity = proximity
  }
}

public struct ReminderAttachmentRecord: Codable, Equatable, Hashable, Sendable {
  public var kind: String
  public var typeIdentifier: String?
  public var fileName: String?
  public var url: String?

  public init(
    kind: String,
    typeIdentifier: String? = nil,
    fileName: String? = nil,
    url: String? = nil
  ) {
    self.kind = kind
    self.typeIdentifier = typeIdentifier
    self.fileName = fileName
    self.url = url
  }
}

public struct ReminderMessagingContactRecord: Codable, Equatable, Hashable, Sendable {
  public var phones: [String]
  public var emails: [String]
  public var evidence: String
  public var lengthBytes: Int?

  public init(
    phones: [String] = [],
    emails: [String] = [],
    evidence: String = "contact_handles_blob",
    lengthBytes: Int? = nil
  ) {
    self.phones = phones
    self.emails = emails
    self.evidence = evidence
    self.lengthBytes = lengthBytes
  }
}

public struct ReminderAssignmentRecord: Codable, Equatable, Hashable, Sendable {
  public var personId: String?
  public var contactLabel: String?
  public var assigneeIdentifier: String?
  public var assignedAtRaw: Double?

  public init(
    personId: String? = nil,
    contactLabel: String? = nil,
    assigneeIdentifier: String? = nil,
    assignedAtRaw: Double? = nil
  ) {
    self.personId = personId
    self.contactLabel = contactLabel
    self.assigneeIdentifier = assigneeIdentifier
    self.assignedAtRaw = assignedAtRaw
  }
}

public struct ReminderAssignmentTargetRecord: Codable, Equatable, Hashable, Sendable {
  public var assigneeIdentifier: String
  public var originatorIdentifier: String
  public var assigneeLabel: String?
  public var assigneeAddress: String?
  public var originatorLabel: String?
  public var originatorAddress: String?

  public init(
    assigneeIdentifier: String,
    originatorIdentifier: String,
    assigneeLabel: String? = nil,
    assigneeAddress: String? = nil,
    originatorLabel: String? = nil,
    originatorAddress: String? = nil
  ) {
    self.assigneeIdentifier = assigneeIdentifier
    self.originatorIdentifier = originatorIdentifier
    self.assigneeLabel = assigneeLabel
    self.assigneeAddress = assigneeAddress
    self.originatorLabel = originatorLabel
    self.originatorAddress = originatorAddress
  }
}

public struct ReminderDetail: Codable, Equatable, Sendable {
  public var id: String
  public var listId: String
  public var listTitle: String
  public var title: String
  public var notes: String?
  public var url: String?
  public var isCompleted: Bool
  public var completedAt: String?
  public var createdAt: String?
  public var modifiedAt: String?
  public var priority: Int
  public var dueDate: String?
  public var dueDateKind: String?
  public var repeatRule: ReminderRepeatRule?
  public var locationTriggers: [ReminderLocationTrigger]
  public var earlyReminderMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var tags: [String]
  public var isFlagged: Bool?
  public var isUrgent: Bool?
  public var sectionId: String?
  public var sectionTitle: String?
  public var parentReminderId: String?
  public var parentReminderTitle: String?
  public var subtaskCount: Int
  public var attachments: [ReminderAttachmentRecord]
  public var assignments: [ReminderAssignmentRecord]
  public var messagingContactHandles: [ReminderMessagingContactRecord]

  public init(
    id: String,
    listId: String,
    listTitle: String,
    title: String,
    notes: String? = nil,
    url: String? = nil,
    isCompleted: Bool,
    completedAt: String? = nil,
    createdAt: String? = nil,
    modifiedAt: String? = nil,
    priority: Int,
    dueDate: String? = nil,
    dueDateKind: String? = nil,
    repeatRule: ReminderRepeatRule? = nil,
    locationTriggers: [ReminderLocationTrigger] = [],
    earlyReminderMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    tags: [String] = [],
    isFlagged: Bool? = nil,
    isUrgent: Bool? = nil,
    sectionId: String? = nil,
    sectionTitle: String? = nil,
    parentReminderId: String? = nil,
    parentReminderTitle: String? = nil,
    subtaskCount: Int = 0,
    attachments: [ReminderAttachmentRecord] = [],
    assignments: [ReminderAssignmentRecord] = [],
    messagingContactHandles: [ReminderMessagingContactRecord] = []
  ) {
    self.id = id
    self.listId = listId
    self.listTitle = listTitle
    self.title = title
    self.notes = notes
    self.url = url
    self.isCompleted = isCompleted
    self.completedAt = completedAt
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
    self.priority = priority
    self.dueDate = dueDate
    self.dueDateKind = dueDateKind
    self.repeatRule = repeatRule
    self.locationTriggers = locationTriggers
    self.earlyReminderMinutesBefore = earlyReminderMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.tags = tags
    self.isFlagged = isFlagged
    self.isUrgent = isUrgent
    self.sectionId = sectionId
    self.sectionTitle = sectionTitle
    self.parentReminderId = parentReminderId
    self.parentReminderTitle = parentReminderTitle
    self.subtaskCount = subtaskCount
    self.attachments = attachments
    self.assignments = assignments
    self.messagingContactHandles = messagingContactHandles
  }
}
public struct RemindersResponse: Codable, Equatable, Sendable {
  public var reminders: [ReminderSummary]
}

public struct ReminderResponse: Codable, Equatable, Sendable {
  public var reminder: ReminderDetail
}

public struct ReminderMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var reminder: ReminderDetail?
  public var reminders: [ReminderDetail]?
  public var deletedID: String?
  public var deletedIDs: [String]?
  public var changedIDs: [String]?
  public var requestedCount: Int?
  public var changedCount: Int?

  public init(
    operation: String,
    changed: Bool,
    reminder: ReminderDetail? = nil,
    reminders: [ReminderDetail]? = nil,
    deletedID: String? = nil,
    deletedIDs: [String]? = nil,
    changedIDs: [String]? = nil,
    requestedCount: Int? = nil,
    changedCount: Int? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.reminder = reminder
    self.reminders = reminders
    self.deletedID = deletedID
    self.deletedIDs = deletedIDs
    self.changedIDs = changedIDs
    self.requestedCount = requestedCount
    self.changedCount = changedCount
  }
}
public struct ReminderCreateDraft: Codable, Equatable, Sendable {
  public var listId: String
  public var title: String
  public var notes: String?
  public var url: String?
  public var priority: Int
  public var dueDate: String?
  public var dueDateKind: String?
  public var repeatRule: ReminderRepeatRule?
  public var locationTrigger: ReminderLocationTrigger?
  public var earlyReminderMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]

  public init(
    listId: String,
    title: String,
    notes: String? = nil,
    url: String? = nil,
    priority: Int = 0,
    dueDate: String? = nil,
    dueDateKind: String? = nil,
    repeatRule: ReminderRepeatRule? = nil,
    locationTrigger: ReminderLocationTrigger? = nil,
    earlyReminderMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = []
  ) {
    self.listId = listId
    self.title = title
    self.notes = notes
    self.url = url
    self.priority = priority
    self.dueDate = dueDate
    self.dueDateKind = dueDateKind
    self.repeatRule = repeatRule
    self.locationTrigger = locationTrigger
    self.earlyReminderMinutesBefore = earlyReminderMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
  }
}

public struct ReminderPatch: Codable, Equatable, Sendable {
  public var listId: String?
  public var title: String?
  public var notes: String?
  public var clearNotes: Bool
  public var url: String?
  public var clearUrl: Bool
  public var priority: Int?
  public var dueDate: String?
  public var dueDateKind: String?
  public var clearDueDate: Bool
  public var repeatRule: ReminderRepeatRule?
  public var clearRepeat: Bool
  public var locationTrigger: ReminderLocationTrigger?
  public var clearLocation: Bool
  public var earlyReminderMinutesBefore: [Int]?
  public var clearEarlyReminders: Bool
  public var absoluteAlarmDates: [Date]?
  public var clearAlarms: Bool
  public var flagged: Bool?
  public var sectionTitle: String?
  public var tags: [String]?
  public var addTags: [String]
  public var removeTags: [String]
  public var clearTags: Bool
  public var urgent: Bool?
  public var messagingPerson: String?
  public var clearMessagingPerson: Bool

  public init(
    listId: String? = nil,
    title: String? = nil,
    notes: String? = nil,
    clearNotes: Bool = false,
    url: String? = nil,
    clearUrl: Bool = false,
    priority: Int? = nil,
    dueDate: String? = nil,
    dueDateKind: String? = nil,
    clearDueDate: Bool = false,
    repeatRule: ReminderRepeatRule? = nil,
    clearRepeat: Bool = false,
    locationTrigger: ReminderLocationTrigger? = nil,
    clearLocation: Bool = false,
    earlyReminderMinutesBefore: [Int]? = nil,
    clearEarlyReminders: Bool = false,
    absoluteAlarmDates: [Date]? = nil,
    clearAlarms: Bool = false,
    flagged: Bool? = nil,
    sectionTitle: String? = nil,
    tags: [String]? = nil,
    addTags: [String] = [],
    removeTags: [String] = [],
    clearTags: Bool = false,
    urgent: Bool? = nil,
    messagingPerson: String? = nil,
    clearMessagingPerson: Bool = false
  ) {
    self.listId = listId
    self.title = title
    self.notes = notes
    self.clearNotes = clearNotes
    self.url = url
    self.clearUrl = clearUrl
    self.priority = priority
    self.dueDate = dueDate
    self.dueDateKind = dueDateKind
    self.clearDueDate = clearDueDate
    self.repeatRule = repeatRule
    self.clearRepeat = clearRepeat
    self.locationTrigger = locationTrigger
    self.clearLocation = clearLocation
    self.earlyReminderMinutesBefore = earlyReminderMinutesBefore
    self.clearEarlyReminders = clearEarlyReminders
    self.absoluteAlarmDates = absoluteAlarmDates
    self.clearAlarms = clearAlarms
    self.flagged = flagged
    self.sectionTitle = sectionTitle
    self.tags = tags
    self.addTags = addTags
    self.removeTags = removeTags
    self.clearTags = clearTags
    self.urgent = urgent
    self.messagingPerson = messagingPerson
    self.clearMessagingPerson = clearMessagingPerson
  }

  public var hasChanges: Bool {
    listId != nil || title != nil || notes != nil || clearNotes || url != nil || clearUrl
      || priority != nil || dueDate != nil || clearDueDate || repeatRule != nil || clearRepeat
      || locationTrigger != nil || clearLocation || flagged != nil || sectionTitle != nil
      || tags != nil
      || earlyReminderMinutesBefore != nil || clearEarlyReminders || absoluteAlarmDates != nil
      || clearAlarms || !addTags.isEmpty || !removeTags.isEmpty || clearTags || urgent != nil
      || hasMessagingPersonChanges
  }

  public var hasTagChanges: Bool {
    tags != nil || !addTags.isEmpty || !removeTags.isEmpty || clearTags
  }

  public var hasSectionChanges: Bool {
    sectionTitle != nil
  }

  public var hasMessagingPersonChanges: Bool {
    messagingPerson != nil || clearMessagingPerson
  }
}
