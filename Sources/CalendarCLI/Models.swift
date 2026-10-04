import CryptoKit
import EventKit
import Foundation
import Utility

public struct CalendarRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var sourceTitle: String?
  public var allowsContentModifications: Bool
  public var sourceId: String?
  public var type: String?
  public var typeRawValue: Int?
  public var isImmutable: Bool?
  public var isSubscribed: Bool?
  public var color: String?
  public var allowedEntityTypesRawValue: UInt?
  public var supportedEventAvailabilitiesRawValue: UInt?

  public init(
    id: String,
    title: String,
    sourceTitle: String?,
    allowsContentModifications: Bool,
    sourceId: String? = nil,
    type: String? = nil,
    typeRawValue: Int? = nil,
    isImmutable: Bool? = nil,
    isSubscribed: Bool? = nil,
    color: String? = nil,
    allowedEntityTypesRawValue: UInt? = nil,
    supportedEventAvailabilitiesRawValue: UInt? = nil
  ) {
    self.id = id
    self.title = title
    self.sourceTitle = sourceTitle
    self.allowsContentModifications = allowsContentModifications
    self.sourceId = sourceId
    self.type = type
    self.typeRawValue = typeRawValue
    self.isImmutable = isImmutable
    self.isSubscribed = isSubscribed
    self.color = color
    self.allowedEntityTypesRawValue = allowedEntityTypesRawValue
    self.supportedEventAvailabilitiesRawValue = supportedEventAvailabilitiesRawValue
  }
}

public struct CalendarSourceRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var type: String
  public var typeRawValue: Int
  public var isDelegate: Bool
  public var calendarIds: [String]

  public init(
    id: String, title: String, type: String, typeRawValue: Int, isDelegate: Bool,
    calendarIds: [String]
  ) {
    self.id = id
    self.title = title
    self.type = type
    self.typeRawValue = typeRawValue
    self.isDelegate = isDelegate
    self.calendarIds = calendarIds
  }
}

public struct CalendarCreateDraft: Codable, Equatable, Sendable {
  public var sourceId: String
  public var title: String
  public var color: String?

  public init(sourceId: String, title: String, color: String? = nil) {
    self.sourceId = sourceId
    self.title = title
    self.color = color
  }
}

public struct CalendarPatch: Codable, Equatable, Sendable {
  public var title: String?
  public var color: String?

  public init(title: String? = nil, color: String? = nil) {
    self.title = title
    self.color = color
  }
}

public struct CalendarEventQuery: Equatable, Sendable {
  public var from: Date
  public var to: Date
  public var calendarSelector: String?
  public var searchText: String?
  public var limit: Int

  public init(
    from: Date,
    to: Date,
    calendarSelector: String? = nil,
    searchText: String? = nil,
    limit: Int
  ) {
    self.from = from
    self.to = to
    self.calendarSelector = calendarSelector
    self.searchText = searchText
    self.limit = limit
  }
}

public struct CalendarEventOccurrenceQuery: Equatable, Sendable {
  public var eventId: String
  public var from: Date
  public var to: Date
  public var calendarSelector: String?
  public var limit: Int

  public init(
    eventId: String,
    from: Date,
    to: Date,
    calendarSelector: String? = nil,
    limit: Int
  ) {
    self.eventId = eventId
    self.from = from
    self.to = to
    self.calendarSelector = calendarSelector
    self.limit = limit
  }
}

public struct CalendarAttendeeRecord: Codable, Equatable, Sendable {
  public var name: String?
  public var url: String?
  public var status: String
  public var role: String
  public var type: String
  public var isCurrentUser: Bool

  public init(
    name: String? = nil,
    url: String? = nil,
    status: String,
    role: String,
    type: String,
    isCurrentUser: Bool = false
  ) {
    self.name = name
    self.url = url
    self.status = status
    self.role = role
    self.type = type
    self.isCurrentUser = isCurrentUser
  }
}

public struct CalendarEventSummary: Codable, Equatable, Sendable {
  public var id: String
  public var calendarId: String
  public var calendarTitle: String
  public var title: String
  public var start: Date
  public var end: Date
  public var isAllDay: Bool
  public var location: String?
  public var alarmMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var recurrence: CalendarRecurrenceRule?
  public var attendees: [CalendarAttendeeRecord]
  public var recurrenceRules: [CalendarRecurrenceRule]?
  public var isDetached: Bool?
  public var timeZoneIdentifier: String?

  public init(
    id: String,
    calendarId: String,
    calendarTitle: String,
    title: String,
    start: Date,
    end: Date,
    isAllDay: Bool,
    location: String? = nil,
    alarmMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    recurrence: CalendarRecurrenceRule? = nil,
    attendees: [CalendarAttendeeRecord] = [],
    recurrenceRules: [CalendarRecurrenceRule]? = nil,
    isDetached: Bool? = nil,
    timeZoneIdentifier: String? = nil
  ) {
    self.id = id
    self.calendarId = calendarId
    self.calendarTitle = calendarTitle
    self.title = title
    self.start = start
    self.end = end
    self.isAllDay = isAllDay
    self.location = location
    self.alarmMinutesBefore = alarmMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.recurrence = recurrence
    self.attendees = attendees
    self.recurrenceRules = recurrenceRules
    self.isDetached = isDetached
    self.timeZoneIdentifier = timeZoneIdentifier
  }
}

public struct CalendarEventDetail: Codable, Equatable, Sendable {
  public var id: String
  public var calendarId: String
  public var calendarTitle: String
  public var title: String
  public var start: Date
  public var end: Date
  public var isAllDay: Bool
  public var location: String?
  public var notes: String?
  public var alarmMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var recurrence: CalendarRecurrenceRule?
  public var attendees: [CalendarAttendeeRecord]
  public var recurrenceRules: [CalendarRecurrenceRule]?
  public var timeZoneIdentifier: String?

  public init(
    id: String,
    calendarId: String,
    calendarTitle: String,
    title: String,
    start: Date,
    end: Date,
    isAllDay: Bool,
    location: String? = nil,
    notes: String? = nil,
    alarmMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    recurrence: CalendarRecurrenceRule? = nil,
    attendees: [CalendarAttendeeRecord] = [],
    recurrenceRules: [CalendarRecurrenceRule]? = nil,
    timeZoneIdentifier: String? = nil
  ) {
    self.id = id
    self.calendarId = calendarId
    self.calendarTitle = calendarTitle
    self.title = title
    self.start = start
    self.end = end
    self.isAllDay = isAllDay
    self.location = location
    self.notes = notes
    self.alarmMinutesBefore = alarmMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.recurrence = recurrence
    self.attendees = attendees
    self.recurrenceRules = recurrenceRules
    self.timeZoneIdentifier = timeZoneIdentifier
  }
}

public struct CalendarEventOccurrence: Codable, Equatable, Sendable {
  public var occurrenceKey: String
  public var id: String
  public var seriesId: String
  public var calendarId: String
  public var calendarTitle: String
  public var title: String
  public var start: Date
  public var end: Date
  public var occurrenceDate: Date
  public var isDetached: Bool
  public var isAllDay: Bool
  public var location: String?
  public var alarmMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var attendees: [CalendarAttendeeRecord]

  public init(
    occurrenceKey: String,
    id: String,
    seriesId: String,
    calendarId: String,
    calendarTitle: String,
    title: String,
    start: Date,
    end: Date,
    occurrenceDate: Date,
    isDetached: Bool,
    isAllDay: Bool,
    location: String? = nil,
    alarmMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    attendees: [CalendarAttendeeRecord] = []
  ) {
    self.occurrenceKey = occurrenceKey
    self.id = id
    self.seriesId = seriesId
    self.calendarId = calendarId
    self.calendarTitle = calendarTitle
    self.title = title
    self.start = start
    self.end = end
    self.occurrenceDate = occurrenceDate
    self.isDetached = isDetached
    self.isAllDay = isAllDay
    self.location = location
    self.alarmMinutesBefore = alarmMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.attendees = attendees
  }
}

public struct CalendarRecurrenceWeekday: Codable, Equatable, Hashable, Sendable {
  public var dayOfWeek: String
  public var weekNumber: Int

  public init(dayOfWeek: String, weekNumber: Int = 0) {
    self.dayOfWeek = dayOfWeek
    self.weekNumber = weekNumber
  }
}

public struct CalendarRecurrenceRule: Codable, Equatable, Sendable {
  public var frequency: String
  public var interval: Int
  public var occurrenceCount: Int?
  public var until: Date?
  public var calendarIdentifier: String?
  public var firstDayOfTheWeek: Int?
  public var daysOfTheWeek: [CalendarRecurrenceWeekday]?
  public var daysOfTheMonth: [Int]?
  public var monthsOfTheYear: [Int]?
  public var weeksOfTheYear: [Int]?
  public var daysOfTheYear: [Int]?
  public var setPositions: [Int]?

  public init(
    frequency: String,
    interval: Int = 1,
    occurrenceCount: Int? = nil,
    until: Date? = nil,
    calendarIdentifier: String? = nil,
    firstDayOfTheWeek: Int? = nil,
    daysOfTheWeek: [CalendarRecurrenceWeekday]? = nil,
    daysOfTheMonth: [Int]? = nil,
    monthsOfTheYear: [Int]? = nil,
    weeksOfTheYear: [Int]? = nil,
    daysOfTheYear: [Int]? = nil,
    setPositions: [Int]? = nil
  ) {
    self.frequency = frequency
    self.interval = interval
    self.occurrenceCount = occurrenceCount
    self.until = until
    self.calendarIdentifier = calendarIdentifier
    self.firstDayOfTheWeek = firstDayOfTheWeek
    self.daysOfTheWeek = daysOfTheWeek
    self.daysOfTheMonth = daysOfTheMonth
    self.monthsOfTheYear = monthsOfTheYear
    self.weeksOfTheYear = weeksOfTheYear
    self.daysOfTheYear = daysOfTheYear
    self.setPositions = setPositions
  }
}

public struct CalendarListResponse: Codable, Equatable, Sendable {
  public var calendars: [CalendarRecord]
  public var truncated: Bool = false
}

public struct CalendarSourceListResponse: Codable, Equatable, Sendable {
  public var sources: [CalendarSourceRecord]
  public var truncated: Bool = false
}

public struct CalendarSourceResponse: Codable, Equatable, Sendable {
  public var source: CalendarSourceRecord
}

public struct CalendarResponse: Codable, Equatable, Sendable {
  public var calendar: CalendarRecord
}

public struct CalendarEventsResponse: Codable, Equatable, Sendable {
  public var events: [CalendarEventSummary]
}

public struct CalendarEventResponse: Codable, Equatable, Sendable {
  public var event: CalendarEventDetail
}

public struct CalendarEventOccurrencesResponse: Codable, Equatable, Sendable {
  public var series: CalendarEventDetail
  public var from: Date
  public var to: Date
  public var calendarSelector: String?
  public var occurrences: [CalendarEventOccurrence]

  public init(
    series: CalendarEventDetail,
    from: Date,
    to: Date,
    calendarSelector: String? = nil,
    occurrences: [CalendarEventOccurrence]
  ) {
    self.series = series
    self.from = from
    self.to = to
    self.calendarSelector = calendarSelector
    self.occurrences = occurrences
  }
}

public struct CalendarAvailabilityResponse: Codable, Equatable, Sendable {
  public var from: Date
  public var to: Date
  public var calendarSelector: String?
  public var isBusy: Bool
  public var conflictCount: Int
  public var conflicts: [CalendarEventSummary]

  public init(
    from: Date,
    to: Date,
    calendarSelector: String? = nil,
    isBusy: Bool,
    conflictCount: Int,
    conflicts: [CalendarEventSummary]
  ) {
    self.from = from
    self.to = to
    self.calendarSelector = calendarSelector
    self.isBusy = isBusy
    self.conflictCount = conflictCount
    self.conflicts = conflicts
  }
}

public struct CalendarStatisticsCalendarBucket: Codable, Equatable, Sendable {
  public var calendarId: String
  public var calendarTitle: String
  public var eventCount: Int
  public var allDayEventCount: Int
  public var busySeconds: Int

  public init(
    calendarId: String,
    calendarTitle: String,
    eventCount: Int,
    allDayEventCount: Int,
    busySeconds: Int
  ) {
    self.calendarId = calendarId
    self.calendarTitle = calendarTitle
    self.eventCount = eventCount
    self.allDayEventCount = allDayEventCount
    self.busySeconds = busySeconds
  }
}

public struct CalendarStatisticsResponse: Codable, Equatable, Sendable {
  public var from: Date
  public var to: Date
  public var calendarSelector: String?
  public var eventCount: Int
  public var allDayEventCount: Int
  public var busySeconds: Int
  public var calendars: [CalendarStatisticsCalendarBucket]

  public init(
    from: Date,
    to: Date,
    calendarSelector: String? = nil,
    eventCount: Int,
    allDayEventCount: Int,
    busySeconds: Int,
    calendars: [CalendarStatisticsCalendarBucket]
  ) {
    self.from = from
    self.to = to
    self.calendarSelector = calendarSelector
    self.eventCount = eventCount
    self.allDayEventCount = allDayEventCount
    self.busySeconds = busySeconds
    self.calendars = calendars
  }
}


public struct CalendarMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var event: CalendarEventDetail?
  public var deletedID: String?
  public var calendar: CalendarRecord? = nil
}

public struct CalendarExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var destinationPath: String
  public var format: String
  public var eventCount: Int
  public var byteCount: Int
  public var sha256: String

  public init(
    operation: String,
    changed: Bool,
    destinationPath: String,
    format: String,
    eventCount: Int,
    byteCount: Int,
    sha256: String
  ) {
    self.operation = operation
    self.changed = changed
    self.destinationPath = destinationPath
    self.format = format
    self.eventCount = eventCount
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public struct CalendarEventDraft: Codable, Equatable, Sendable {
  public var calendarId: String
  public var title: String
  public var start: Date
  public var end: Date
  public var isAllDay: Bool
  public var location: String?
  public var notes: String?
  public var alarmMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var recurrence: CalendarRecurrenceRule?

  public init(
    calendarId: String,
    title: String,
    start: Date,
    end: Date,
    isAllDay: Bool = false,
    location: String? = nil,
    notes: String? = nil,
    alarmMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    recurrence: CalendarRecurrenceRule? = nil
  ) {
    self.calendarId = calendarId
    self.title = title
    self.start = start
    self.end = end
    self.isAllDay = isAllDay
    self.location = location
    self.notes = notes
    self.alarmMinutesBefore = alarmMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.recurrence = recurrence
  }
}

public struct CalendarEventPatch: Codable, Equatable, Sendable {
  public var calendarId: String?
  public var title: String?
  public var start: Date?
  public var end: Date?
  public var isAllDay: Bool?
  public var location: String?
  public var notes: String?
  public var alarmMinutesBefore: [Int]?
  public var absoluteAlarmDates: [Date]?
  public var recurrence: CalendarRecurrenceRule?
  public var clearLocation: Bool
  public var clearNotes: Bool
  public var clearAlarms: Bool
  public var clearRecurrence: Bool

  public init(
    calendarId: String? = nil,
    title: String? = nil,
    start: Date? = nil,
    end: Date? = nil,
    isAllDay: Bool? = nil,
    location: String? = nil,
    notes: String? = nil,
    alarmMinutesBefore: [Int]? = nil,
    absoluteAlarmDates: [Date]? = nil,
    recurrence: CalendarRecurrenceRule? = nil,
    clearLocation: Bool = false,
    clearNotes: Bool = false,
    clearAlarms: Bool = false,
    clearRecurrence: Bool = false
  ) {
    self.calendarId = calendarId
    self.title = title
    self.start = start
    self.end = end
    self.isAllDay = isAllDay
    self.location = location
    self.notes = notes
    self.alarmMinutesBefore = alarmMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.recurrence = recurrence
    self.clearLocation = clearLocation
    self.clearNotes = clearNotes
    self.clearAlarms = clearAlarms
    self.clearRecurrence = clearRecurrence
  }

  var hasChanges: Bool {
    calendarId != nil
      || title != nil
      || start != nil
      || end != nil
      || isAllDay != nil
      || location != nil
      || notes != nil
      || alarmMinutesBefore != nil
      || absoluteAlarmDates != nil
      || recurrence != nil
      || clearLocation
      || clearNotes
      || clearAlarms
      || clearRecurrence
  }
}
