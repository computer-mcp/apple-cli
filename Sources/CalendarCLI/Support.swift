import CryptoKit
import EventKit
import Foundation
import Utility

struct CalendarMutationIdentity {
  var event: CalendarEventDetail
  var scopeDigest: String
  var summaryFields: [String: String]
}

enum DateBoundaryRole {
  case lower
  case upper
}

func validateReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation or external-action commands."
    )
  }
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateMutationIntent(_ options: CLIOptions) throws {}

func validateExportIntent(_ options: CLIOptions) throws {}

func validateTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String>,
  allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(unknownFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` is required."
    )
  }

  return value
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func sha256Hex(_ data: Data) -> String {
  let digest = SHA256.hash(data: data)
  return digest.map { String(format: "%02x", $0) }.joined()
}

func eventCreateScopeDigest(_ draft: CalendarEventDraft) -> String {
  let payload = [
    draft.calendarId,
    draft.title,
    formatDate(draft.start),
    formatDate(draft.end),
    "\(draft.isAllDay)",
    draft.location ?? "",
    draft.notes ?? "",
    alarmList(draft.alarmMinutesBefore),
    dateList(draft.absoluteAlarmDates),
    recurrenceSummary(draft.recurrence),
  ].joined(separator: "|")
  return "calendar-event-create:\(sha256Hex(payload))"
}

func eventIdentityScopeDigest(_ event: CalendarEventDetail) -> String {
  let payload = [
    event.id,
    event.calendarId,
    event.title,
    formatDate(event.start),
    formatDate(event.end),
    "\(event.isAllDay)",
    event.location ?? "",
    event.notes ?? "",
    alarmList(event.alarmMinutesBefore),
    dateList(event.absoluteAlarmDates),
    recurrenceSummary(event.recurrence),
    attendeeList(event.attendees),
  ].joined(separator: "|")
  return "calendar-event:\(sha256Hex(payload))"
}

func eventUpdateScopeDigest(current: CalendarEventDetail, patch: CalendarEventPatch) -> String {
  let payload = [
    eventIdentityScopeDigest(current),
    patch.calendarId ?? "",
    patch.title ?? "",
    patch.start.map(formatDate) ?? "",
    patch.end.map(formatDate) ?? "",
    patch.isAllDay.map { "\($0)" } ?? "",
    patch.location ?? "",
    patch.notes ?? "",
    patch.alarmMinutesBefore.map(alarmList) ?? "",
    patch.absoluteAlarmDates.map(dateList) ?? "",
    recurrenceSummary(patch.recurrence),
    "\(patch.clearLocation)",
    "\(patch.clearNotes)",
    "\(patch.clearAlarms)",
    "\(patch.clearRecurrence)",
  ].joined(separator: "|")
  return "calendar-event-update:\(sha256Hex(payload))"
}

func calendarExportScopeDigest(
  query: CalendarEventQuery,
  events: [CalendarEventSummary],
  format: String,
  destinationPath: String
) -> String {
  let payload = [
    formatDate(query.from),
    formatDate(query.to),
    query.calendarSelector ?? "",
    query.searchText ?? "",
    "\(query.limit)",
    format,
    destinationPath,
    calendarExportEventList(events),
  ].joined(separator: "|")
  return "calendar-event-export:\(sha256Hex(payload))"
}

func calendarExportEventList(_ events: [CalendarEventSummary]) -> String {
  events
    .map { event in
      [
        event.id,
        event.calendarId,
        event.title,
        formatDate(event.start),
        formatDate(event.end),
        "\(event.isAllDay)",
        event.location ?? "",
        alarmList(event.alarmMinutesBefore),
        dateList(event.absoluteAlarmDates),
        recurrenceSummary(event.recurrence),
        attendeeList(event.attendees),
      ].joined(separator: "~")
    }
    .sorted()
    .joined(separator: ",")
}

func eventCreateSummary(_ draft: CalendarEventDraft) -> [String: String] {
  var summary = [
    "calendar_id": draft.calendarId,
    "title": draft.title,
    "start": formatDate(draft.start),
    "end": formatDate(draft.end),
    "all_day": "\(draft.isAllDay)",
  ]
  if !draft.alarmMinutesBefore.isEmpty {
    summary["alarm_minutes_before"] = alarmList(draft.alarmMinutesBefore)
  }
  if !draft.absoluteAlarmDates.isEmpty {
    summary["alarm_at"] = dateList(draft.absoluteAlarmDates)
  }
  if let recurrence = draft.recurrence {
    summary["recurrence"] = recurrenceSummary(recurrence)
  }
  return summary
}

func eventUpdateSummary(current: CalendarEventDetail, patch: CalendarEventPatch) -> [String: String]
{
  var summary = [
    "id": current.id,
    "current_title": current.title,
    "current_calendar_id": current.calendarId,
  ]
  if let calendarId = patch.calendarId {
    summary["new_calendar_id"] = calendarId
  }
  if let title = patch.title {
    summary["new_title"] = title
  }
  if let start = patch.start {
    summary["new_start"] = formatDate(start)
  }
  if let end = patch.end {
    summary["new_end"] = formatDate(end)
  }
  if let isAllDay = patch.isAllDay {
    summary["new_all_day"] = "\(isAllDay)"
  }
  if let location = patch.location {
    summary["new_location"] = location
  }
  if let notes = patch.notes {
    summary["new_notes"] = notes
  }
  if let alarmMinutesBefore = patch.alarmMinutesBefore {
    summary["new_alarm_minutes_before"] = alarmList(alarmMinutesBefore)
  }
  if let absoluteAlarmDates = patch.absoluteAlarmDates {
    summary["new_alarm_at"] = dateList(absoluteAlarmDates)
  }
  if let recurrence = patch.recurrence {
    summary["new_recurrence"] = recurrenceSummary(recurrence)
  }
  if patch.clearLocation {
    summary["clear_location"] = "true"
  }
  if patch.clearNotes {
    summary["clear_notes"] = "true"
  }
  if patch.clearAlarms {
    summary["clear_alarms"] = "true"
  }
  if patch.clearRecurrence {
    summary["clear_recurrence"] = "true"
  }
  return summary
}

func alarmMinutesBeforeOption(_ options: CLIOptions) throws -> [Int]? {
  guard let value = options.targetOption("alarm-minutes-before") else {
    return nil
  }

  let values =
    try value
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { chunk -> Int in
      let trimmed = chunk.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, let minutes = Int(trimmed), minutes >= 0, minutes <= 525_600 else {
        throw CLIError(
          code: .validationError,
          message:
            "`--alarm-minutes-before` must be a comma-separated list of minute offsets from 0 through 525600.",
          details: ["value": value]
        )
      }
      return minutes
    }

  guard !values.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--alarm-minutes-before` must include at least one minute offset."
    )
  }

  return Array(Set(values)).sorted()
}

func alarmList(_ values: [Int]) -> String {
  values.sorted().map(String.init).joined(separator: ",")
}

func alarmAtOption(_ options: CLIOptions) throws -> [Date]? {
  guard let value = options.targetOption("alarm-at") else {
    return nil
  }

  let values =
    try value
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { chunk -> Date in
      let trimmed = chunk.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else {
        throw CLIError(
          code: .validationError,
          message: "`--alarm-at` must be a comma-separated list of ISO-8601 date-time values.",
          details: ["value": value]
        )
      }
      return try parseAlarmDate(trimmed)
    }

  guard !values.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--alarm-at` must include at least one ISO-8601 date-time value."
    )
  }

  return uniqueSortedDates(values)
}

func parseAlarmDate(_ value: String) throws -> Date {
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = formatter.date(from: value) {
    return date
  }

  formatter.formatOptions = [.withInternetDateTime]
  if let date = formatter.date(from: value) {
    return date
  }

  throw CLIError(
    code: .validationError,
    message: "`--alarm-at` values must use ISO-8601 date-time format.",
    details: ["value": value]
  )
}

func dateList(_ values: [Date]) -> String {
  values.sorted().map(formatDate).joined(separator: ",")
}

func uniqueSortedDates(_ values: [Date]) -> [Date] {
  values
    .sorted()
    .reduce(into: [Date]()) { result, date in
      if result.last != date {
        result.append(date)
      }
    }
}

func attendeeList(_ attendees: [CalendarAttendeeRecord]) -> String {
  guard !attendees.isEmpty else {
    return ""
  }

  return
    attendees
    .map { attendee in
      [
        attendee.url ?? "",
        attendee.name ?? "",
        attendee.status,
        attendee.role,
        attendee.type,
        "\(attendee.isCurrentUser)",
      ].joined(separator: "~")
    }
    .sorted()
    .joined(separator: ",")
}

func hasRecurrenceOptions(_ options: CLIOptions) -> Bool {
  options.targetOption("recurrence-frequency") != nil
    || options.targetOption("recurrence-interval") != nil
    || options.targetOption("recurrence-count") != nil
    || options.targetOption("recurrence-until") != nil
}

func recurrenceRuleOption(_ options: CLIOptions, effectiveStart: Date) throws
  -> CalendarRecurrenceRule?
{
  guard hasRecurrenceOptions(options) else {
    return nil
  }

  let frequency = try normalizedRecurrenceFrequency(
    try requiredOption("recurrence-frequency", options: options))
  let interval = try positiveIntOption(
    "recurrence-interval",
    options: options,
    defaultValue: 1,
    upperBound: 999
  )
  let occurrenceCount = try options.targetOption("recurrence-count").map {
    try parsePositiveInteger($0, flag: "--recurrence-count", upperBound: 9_999)
  }
  let until = try options.targetOption("recurrence-until").map(parseEventDate)

  if occurrenceCount != nil, until != nil {
    throw CLIError(
      code: .validationError,
      message: "`--recurrence-count` cannot be combined with `--recurrence-until`."
    )
  }

  if let until, until <= effectiveStart {
    throw CLIError(
      code: .validationError,
      message: "`--recurrence-until` must be later than the event start."
    )
  }

  return CalendarRecurrenceRule(
    frequency: frequency,
    interval: interval,
    occurrenceCount: occurrenceCount,
    until: until
  )
}

func normalizedRecurrenceFrequency(_ value: String) throws -> String {
  let frequency = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  guard ["daily", "weekly", "monthly", "yearly"].contains(frequency) else {
    throw CLIError(
      code: .validationError,
      message: "`--recurrence-frequency` must be daily, weekly, monthly, or yearly.",
      details: ["value": value]
    )
  }
  return frequency
}

func positiveIntOption(
  _ name: String,
  options: CLIOptions,
  defaultValue: Int,
  upperBound: Int
) throws -> Int {
  guard let value = options.targetOption(name) else {
    return defaultValue
  }
  return try parsePositiveInteger(value, flag: "--\(name)", upperBound: upperBound)
}

func parsePositiveInteger(_ value: String, flag: String, upperBound: Int) throws -> Int {
  guard let parsed = Int(value), parsed > 0, parsed <= upperBound else {
    throw CLIError(
      code: .validationError,
      message: "`\(flag)` must be an integer from 1 through \(upperBound).",
      details: ["value": value]
    )
  }
  return parsed
}

func exportFormat(_ options: CLIOptions) throws -> String {
  let value = try requiredOption("format", options: options).trimmingCharacters(
    in: .whitespacesAndNewlines
  ).lowercased()
  guard value == "ics" else {
    throw CLIError(
      code: .unsupportedOperation, message: "Calendar event export currently supports only `ics`.")
  }
  return value
}

func recurrenceSummary(_ recurrence: CalendarRecurrenceRule?) -> String {
  guard let recurrence else {
    return ""
  }
  return recurrenceSummary(recurrence)
}

func recurrenceSummary(_ recurrence: CalendarRecurrenceRule) -> String {
  [
    recurrence.frequency,
    "interval=\(recurrence.interval)",
    recurrence.occurrenceCount.map { "count=\($0)" } ?? "",
    recurrence.until.map { "until=\(formatDate($0))" } ?? "",
  ]
  .filter { !$0.isEmpty }
  .joined(separator: ";")
}

func eventAllDayPatch(_ options: CLIOptions) -> Bool? {
  if options.hasTargetFlag("all-day") {
    return true
  }

  if options.hasTargetFlag("timed") {
    return false
  }

  return nil
}

func validateEventRange(start: Date, end: Date) throws {
  guard start < end else {
    throw CLIError(
      code: .validationError,
      message: "`--start` must be earlier than `--end`."
    )
  }
}

func parseEventDate(_ value: String) throws -> Date {
  if let date = parseDateOnly(value, role: .lower) {
    return date
  }

  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = formatter.date(from: value) {
    return date
  }

  formatter.formatOptions = [.withInternetDateTime]
  if let date = formatter.date(from: value) {
    return date
  }

  throw CLIError(
    code: .validationError,
    message: "Event date values must use YYYY-MM-DD or ISO-8601 date-time format.",
    details: ["value": value]
  )
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError,
      message: "`--limit` cannot exceed 500 for EventKit read commands."
    )
  }
  return limit
}

func parseDateBoundary(_ value: String, role: DateBoundaryRole) throws -> Date {
  if let date = parseDateOnly(value, role: role) {
    return date
  }

  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = formatter.date(from: value) {
    return date
  }

  formatter.formatOptions = [.withInternetDateTime]
  if let date = formatter.date(from: value) {
    return date
  }

  throw CLIError(
    code: .validationError,
    message: "Date values must use YYYY-MM-DD or ISO-8601 date-time format.",
    details: ["value": value]
  )
}

func parseDateOnly(_ value: String, role: DateBoundaryRole) -> Date? {
  let parts = value.split(separator: "-")
  guard parts.count == 3,
    let year = Int(parts[0]),
    let month = Int(parts[1]),
    let day = Int(parts[2])
  else {
    return nil
  }

  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = .current
  let components = DateComponents(
    calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day)
  guard let startOfDay = components.date else {
    return nil
  }

  switch role {
  case .lower:
    return startOfDay
  case .upper:
    return calendar.date(byAdding: .day, value: 1, to: startOfDay)
  }
}

func standardizedAbsolutePath(_ path: String) -> String {
  let expanded = (path as NSString).expandingTildeInPath
  if expanded.hasPrefix("/") {
    return URL(fileURLWithPath: expanded).standardizedFileURL.path
  }

  return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent(expanded)
    .standardizedFileURL
    .path
}

func validateICalendarExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "ics" else {
    throw CLIError(
      code: .validationError, message: "`--output` must end in `.ics` for ics export.",
      details: ["path": destination.path])
  }
  guard !FileManager.default.fileExists(atPath: destination.path) else {
    throw CLIError(
      code: .validationError, message: "Destination path already exists.",
      details: ["path": destination.path])
  }
  let parent = destination.deletingLastPathComponent()
  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory),
    isDirectory.boolValue
  else {
    throw CLIError(
      code: .notFound, message: "Destination parent directory was not found.",
      details: ["path": parent.path])
  }
}

func writeCalendarExport(_ data: Data, to destinationPath: String) throws {
  try validateICalendarExportDestination(destinationPath)
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let parent = destination.deletingLastPathComponent()
  let temporary = parent.appendingPathComponent(
    ".\(destination.lastPathComponent).\(UUID().uuidString).tmp")

  do {
    try data.write(to: temporary, options: [.atomic])
    try FileManager.default.moveItem(at: temporary, to: destination)
  } catch {
    try? FileManager.default.removeItem(at: temporary)
    throw error
  }
}

func eventStoreWithReadAccess() throws -> EKEventStore {
  switch EKEventStore.authorizationStatus(for: .event) {
  case .authorized, .fullAccess:
    return EKEventStore()
  case .writeOnly:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.fullAccessRequired(
        "Calendar", operation: "read/search commands")
    )
  case .notDetermined:
    return try requestCalendarFullAccess(
      deniedMessage: CLIPermissionWording.accessNotGranted(
        "Calendar", operation: "read/search commands"))
  case .denied, .restricted:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted(
        "Calendar", operation: "read/search commands")
    )
  @unknown default:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessStatusUnknown("Calendar")
    )
  }
}

func eventStoreWithCalendarWriteAccess() throws -> EKEventStore {
  switch EKEventStore.authorizationStatus(for: .event) {
  case .authorized, .fullAccess, .writeOnly:
    return EKEventStore()
  case .notDetermined:
    return try requestCalendarFullAccess(
      deniedMessage: CLIPermissionWording.accessNotGranted(
        "Calendar", operation: "mutation commands"))
  case .denied, .restricted:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted(
        "Calendar", operation: "mutation commands")
    )
  @unknown default:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessStatusUnknown("Calendar")
    )
  }
}

func requestCalendarFullAccess(deniedMessage: String) throws -> EKEventStore {
  let store = EKEventStore()
  let box = EventKitAccessRequestBox()
  let semaphore = DispatchSemaphore(value: 0)

  let completion: @Sendable (Bool, Error?) -> Void = { granted, error in
    box.store(granted: granted, error: error)
    semaphore.signal()
  }

  if #available(macOS 14.0, *) {
    store.requestFullAccessToEvents(completion: completion)
  } else {
    store.requestAccess(to: .event, completion: completion)
  }

  guard semaphore.wait(timeout: .now() + .seconds(60)) == .success else {
    throw CLIError(
      code: .timeout,
      message: CLIPermissionWording.accessRequestTimedOut("Calendar")
    )
  }

  let result = box.take()
  if let error = result.error {
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessRequestFailed("Calendar"),
      details: CLIError.diagnosticDetails(for: error)
    )
  }
  guard result.granted else {
    throw CLIError(code: .permissionDenied, message: deniedMessage)
  }

  return store
}

private final class EventKitAccessRequestBox: @unchecked Sendable {
  private let lock = NSLock()
  private var granted = false
  private var error: Error?

  func store(granted: Bool, error: Error?) {
    lock.lock()
    self.granted = granted
    self.error = error
    lock.unlock()
  }

  func take() -> (granted: Bool, error: Error?) {
    lock.lock()
    let result = (granted, error)
    lock.unlock()
    return result
  }
}

func applyDraft(_ draft: CalendarEventDraft, to event: EKEvent) {
  event.title = draft.title
  event.startDate = draft.start
  event.endDate = draft.end
  event.isAllDay = draft.isAllDay
  event.location = draft.location
  event.notes = draft.notes
  replaceAlarms(on: event, with: draft.alarmMinutesBefore, absoluteDates: draft.absoluteAlarmDates)
  replaceRecurrence(on: event, with: draft.recurrence)
}

func applyPatch(_ patch: CalendarEventPatch, to event: EKEvent) {
  if let title = patch.title {
    event.title = title
  }
  if let start = patch.start {
    event.startDate = start
  }
  if let end = patch.end {
    event.endDate = end
  }
  if let isAllDay = patch.isAllDay {
    event.isAllDay = isAllDay
  }
  if let location = patch.location {
    event.location = location
  } else if patch.clearLocation {
    event.location = nil
  }
  if let notes = patch.notes {
    event.notes = notes
  } else if patch.clearNotes {
    event.notes = nil
  }
  if patch.alarmMinutesBefore != nil || patch.absoluteAlarmDates != nil {
    replaceAlarms(
      on: event,
      with: patch.alarmMinutesBefore ?? [],
      absoluteDates: patch.absoluteAlarmDates ?? []
    )
  } else if patch.clearAlarms {
    removeAlarms(from: event)
  }
  if let recurrence = patch.recurrence {
    replaceRecurrence(on: event, with: recurrence)
  } else if patch.clearRecurrence {
    removeRecurrence(from: event)
  }
}

func replaceAlarms(on event: EKEvent, with minutesBefore: [Int], absoluteDates: [Date]) {
  removeAlarms(from: event)
  for minutes in minutesBefore.sorted() {
    event.addAlarm(EKAlarm(relativeOffset: -TimeInterval(minutes * 60)))
  }
  for date in absoluteDates.sorted() {
    event.addAlarm(EKAlarm(absoluteDate: date))
  }
}

func removeAlarms(from event: EKEvent) {
  for alarm in event.alarms ?? [] {
    event.removeAlarm(alarm)
  }
}

func replaceRecurrence(on event: EKEvent, with recurrence: CalendarRecurrenceRule?) {
  removeRecurrence(from: event)
  guard let recurrence else {
    return
  }
  event.addRecurrenceRule(eventKitRecurrenceRule(recurrence))
}

func removeRecurrence(from event: EKEvent) {
  for rule in event.recurrenceRules ?? [] {
    event.removeRecurrenceRule(rule)
  }
}

func eventKitRecurrenceRule(_ recurrence: CalendarRecurrenceRule) -> EKRecurrenceRule {
  let end: EKRecurrenceEnd?
  if let occurrenceCount = recurrence.occurrenceCount {
    end = EKRecurrenceEnd(occurrenceCount: occurrenceCount)
  } else if let until = recurrence.until {
    end = EKRecurrenceEnd(end: until)
  } else {
    end = nil
  }

  return EKRecurrenceRule(
    recurrenceWith: eventKitRecurrenceFrequency(recurrence.frequency),
    interval: recurrence.interval,
    end: end
  )
}

func eventKitRecurrenceFrequency(_ value: String) -> EKRecurrenceFrequency {
  switch value {
  case "weekly":
    return .weekly
  case "monthly":
    return .monthly
  case "yearly":
    return .yearly
  default:
    return .daily
  }
}

func calendarRecord(_ calendar: EKCalendar) -> CalendarRecord {
  CalendarRecord(
    id: calendar.calendarIdentifier,
    title: calendar.title,
    sourceTitle: calendar.source.title,
    allowsContentModifications: calendar.allowsContentModifications
  )
}

func eventSummary(_ event: EKEvent) -> CalendarEventSummary {
  let id = event.eventIdentifier ?? event.calendarItemIdentifier
  return CalendarEventSummary(
    id: id,
    calendarId: event.calendar.calendarIdentifier,
    calendarTitle: event.calendar.title,
    title: event.title,
    start: event.startDate,
    end: event.endDate,
    isAllDay: event.isAllDay,
    location: event.location,
    alarmMinutesBefore: relativeAlarmMinutesBefore(event),
    absoluteAlarmDates: absoluteAlarmDates(event),
    recurrence: recurrenceRule(event),
    attendees: eventAttendees(event)
  )
}

func eventDetail(_ event: EKEvent) -> CalendarEventDetail {
  CalendarEventDetail(
    id: event.eventIdentifier ?? event.calendarItemIdentifier,
    calendarId: event.calendar.calendarIdentifier,
    calendarTitle: event.calendar.title,
    title: event.title,
    start: event.startDate,
    end: event.endDate,
    isAllDay: event.isAllDay,
    location: event.location,
    notes: event.notes,
    alarmMinutesBefore: relativeAlarmMinutesBefore(event),
    absoluteAlarmDates: absoluteAlarmDates(event),
    recurrence: recurrenceRule(event),
    attendees: eventAttendees(event)
  )
}

func eventOccurrence(_ event: EKEvent, seriesId: String) -> CalendarEventOccurrence {
  let occurrenceDate = event.occurrenceDate ?? event.startDate ?? Date(timeIntervalSince1970: 0)
  return CalendarEventOccurrence(
    occurrenceKey: "\(seriesId)@\(formatDate(occurrenceDate))",
    id: event.eventIdentifier ?? event.calendarItemIdentifier,
    seriesId: seriesId,
    calendarId: event.calendar.calendarIdentifier,
    calendarTitle: event.calendar.title,
    title: event.title,
    start: event.startDate,
    end: event.endDate,
    occurrenceDate: occurrenceDate,
    isDetached: event.isDetached,
    isAllDay: event.isAllDay,
    location: event.location,
    alarmMinutesBefore: relativeAlarmMinutesBefore(event),
    absoluteAlarmDates: absoluteAlarmDates(event),
    attendees: eventAttendees(event)
  )
}

func sameEventSeries(_ candidate: EKEvent, _ seriesEvent: EKEvent) -> Bool {
  candidate.calendar.calendarIdentifier == seriesEvent.calendar.calendarIdentifier
    && eventSeriesKey(candidate) == eventSeriesKey(seriesEvent)
}

func eventSeriesKey(_ event: EKEvent) -> String {
  if let externalIdentifier = event.calendarItemExternalIdentifier, !externalIdentifier.isEmpty {
    return "external:\(externalIdentifier)"
  }

  let itemIdentifier = event.calendarItemIdentifier
  if !itemIdentifier.isEmpty {
    return "item:\(itemIdentifier)"
  }

  return "item:\(event.eventIdentifier ?? "")"
}

func relativeAlarmMinutesBefore(_ event: EKEvent) -> [Int] {
  let values = (event.alarms ?? []).compactMap { alarm -> Int? in
    guard alarm.absoluteDate == nil, alarm.relativeOffset <= 0 else {
      return nil
    }

    let minutes = Int((-alarm.relativeOffset / 60).rounded())
    guard minutes >= 0 else {
      return nil
    }
    return minutes
  }
  return Array(Set(values)).sorted()
}

func absoluteAlarmDates(_ event: EKEvent) -> [Date] {
  uniqueSortedDates((event.alarms ?? []).compactMap(\.absoluteDate))
}

func recurrenceRule(_ event: EKEvent) -> CalendarRecurrenceRule? {
  guard let rule = event.recurrenceRules?.first else {
    return nil
  }

  let recurrenceEnd = rule.recurrenceEnd
  let occurrenceCount = recurrenceEnd?.occurrenceCount ?? 0
  return CalendarRecurrenceRule(
    frequency: recurrenceFrequency(rule.frequency),
    interval: rule.interval,
    occurrenceCount: occurrenceCount > 0 ? occurrenceCount : nil,
    until: recurrenceEnd?.endDate
  )
}

func recurrenceFrequency(_ frequency: EKRecurrenceFrequency) -> String {
  switch frequency {
  case .daily:
    return "daily"
  case .weekly:
    return "weekly"
  case .monthly:
    return "monthly"
  case .yearly:
    return "yearly"
  @unknown default:
    return "unknown"
  }
}

func eventAttendees(_ event: EKEvent) -> [CalendarAttendeeRecord] {
  (event.attendees ?? []).map { participant in
    CalendarAttendeeRecord(
      name: participant.name,
      url: participant.url.absoluteString,
      status: participantStatus(participant.participantStatus),
      role: participantRole(participant.participantRole),
      type: participantType(participant.participantType),
      isCurrentUser: participant.isCurrentUser
    )
  }
}

func participantStatus(_ status: EKParticipantStatus) -> String {
  switch status {
  case .unknown:
    return "unknown"
  case .pending:
    return "pending"
  case .accepted:
    return "accepted"
  case .declined:
    return "declined"
  case .tentative:
    return "tentative"
  case .delegated:
    return "delegated"
  case .completed:
    return "completed"
  case .inProcess:
    return "in_process"
  @unknown default:
    return "unknown"
  }
}

func participantRole(_ role: EKParticipantRole) -> String {
  switch role {
  case .unknown:
    return "unknown"
  case .required:
    return "required"
  case .optional:
    return "optional"
  case .chair:
    return "chair"
  case .nonParticipant:
    return "non_participant"
  @unknown default:
    return "unknown"
  }
}

func participantType(_ type: EKParticipantType) -> String {
  switch type {
  case .unknown:
    return "unknown"
  case .person:
    return "person"
  case .room:
    return "room"
  case .resource:
    return "resource"
  case .group:
    return "group"
  @unknown default:
    return "unknown"
  }
}

func renderICalendar(_ events: [CalendarEventSummary]) -> String {
  var lines = [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//apple-cli//calendar//EN",
    "CALSCALE:GREGORIAN",
    "METHOD:PUBLISH",
  ]
  let stamp = iCalendarDateTime(Date())

  for event in events {
    lines.append("BEGIN:VEVENT")
    lines.append("UID:\(iCalendarText(event.id))")
    lines.append("DTSTAMP:\(stamp)")
    if event.isAllDay {
      lines.append("DTSTART;VALUE=DATE:\(iCalendarDate(event.start))")
      lines.append("DTEND;VALUE=DATE:\(iCalendarDate(event.end))")
    } else {
      lines.append("DTSTART:\(iCalendarDateTime(event.start))")
      lines.append("DTEND:\(iCalendarDateTime(event.end))")
    }
    lines.append("SUMMARY:\(iCalendarText(event.title))")
    lines.append("X-APPLE-CLI-CALENDAR-ID:\(iCalendarText(event.calendarId))")
    lines.append("X-APPLE-CLI-CALENDAR-TITLE:\(iCalendarText(event.calendarTitle))")
    if let location = event.location, !location.isEmpty {
      lines.append("LOCATION:\(iCalendarText(location))")
    }
    if let recurrence = event.recurrence {
      lines.append("RRULE:\(iCalendarRecurrence(recurrence))")
    }
    for minutes in event.alarmMinutesBefore.sorted() {
      lines.append("BEGIN:VALARM")
      lines.append("ACTION:DISPLAY")
      lines.append("DESCRIPTION:\(iCalendarText(event.title))")
      lines.append("TRIGGER:-PT\(minutes)M")
      lines.append("END:VALARM")
    }
    for date in event.absoluteAlarmDates.sorted() {
      lines.append("BEGIN:VALARM")
      lines.append("ACTION:DISPLAY")
      lines.append("DESCRIPTION:\(iCalendarText(event.title))")
      lines.append("TRIGGER;VALUE=DATE-TIME:\(iCalendarDateTime(date))")
      lines.append("END:VALARM")
    }
    lines.append("END:VEVENT")
  }

  lines.append("END:VCALENDAR")
  return lines.map(foldICalendarLine).joined(separator: "\r\n") + "\r\n"
}

func iCalendarDateTime(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .gregorian)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
  return formatter.string(from: date)
}

func iCalendarDate(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .gregorian)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyyMMdd"
  return formatter.string(from: date)
}

func iCalendarText(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\n", with: "\\n")
    .replacingOccurrences(of: "\r", with: "")
    .replacingOccurrences(of: ";", with: "\\;")
    .replacingOccurrences(of: ",", with: "\\,")
}

func iCalendarRecurrence(_ recurrence: CalendarRecurrenceRule) -> String {
  var parts = [
    "FREQ=\(recurrence.frequency.uppercased())",
    "INTERVAL=\(recurrence.interval)",
  ]
  if let occurrenceCount = recurrence.occurrenceCount {
    parts.append("COUNT=\(occurrenceCount)")
  }
  if let until = recurrence.until {
    parts.append("UNTIL=\(iCalendarDateTime(until))")
  }
  return parts.joined(separator: ";")
}

func foldICalendarLine(_ line: String) -> String {
  guard line.count > 75 else {
    return line
  }

  var chunks: [String] = []
  var remainder = line
  while remainder.count > 75 {
    let index = remainder.index(remainder.startIndex, offsetBy: 75)
    chunks.append(String(remainder[..<index]))
    remainder = String(remainder[index...])
  }
  chunks.append(remainder)
  return chunks.enumerated().map { index, chunk in
    index == 0 ? chunk : " \(chunk)"
  }.joined(separator: "\r\n")
}

func calendarsHumanOutput(_ calendars: [CalendarRecord]) -> String {
  calendars
    .map { "\($0.id)\t\($0.title)\t\($0.sourceTitle)" }
    .joined(separator: "\n")
}

func eventsHumanOutput(_ events: [CalendarEventSummary]) -> String {
  events
    .map { "\($0.id)\t\(formatDate($0.start))\t\(formatDate($0.end))\t\($0.title)" }
    .joined(separator: "\n")
}

func eventOccurrencesHumanOutput(_ occurrences: [CalendarEventOccurrence]) -> String {
  occurrences
    .map { "\($0.occurrenceKey)\t\(formatDate($0.start))\t\(formatDate($0.end))\t\($0.title)" }
    .joined(separator: "\n")
}

func calendarStatistics(query: CalendarEventQuery, events: [CalendarEventSummary])
  -> CalendarStatisticsResponse
{
  var buckets: [String: CalendarStatisticsCalendarBucket] = [:]
  for event in events {
    let seconds = clippedBusySeconds(event, from: query.from, to: query.to)
    var bucket =
      buckets[event.calendarId]
      ?? CalendarStatisticsCalendarBucket(
        calendarId: event.calendarId,
        calendarTitle: event.calendarTitle,
        eventCount: 0,
        allDayEventCount: 0,
        busySeconds: 0
      )
    bucket.eventCount += 1
    bucket.allDayEventCount += event.isAllDay ? 1 : 0
    bucket.busySeconds += seconds
    buckets[event.calendarId] = bucket
  }

  let calendarBuckets = buckets.values.sorted {
    if $0.calendarTitle == $1.calendarTitle {
      return $0.calendarId < $1.calendarId
    }
    return $0.calendarTitle.localizedCaseInsensitiveCompare($1.calendarTitle) == .orderedAscending
  }

  return CalendarStatisticsResponse(
    from: query.from,
    to: query.to,
    calendarSelector: query.calendarSelector,
    eventCount: events.count,
    allDayEventCount: events.filter(\.isAllDay).count,
    busySeconds: calendarBuckets.reduce(0) { $0 + $1.busySeconds },
    calendars: calendarBuckets
  )
}

func clippedBusySeconds(_ event: CalendarEventSummary, from: Date, to: Date) -> Int {
  let start = max(event.start, from)
  let end = min(event.end, to)
  return max(0, Int(end.timeIntervalSince(start).rounded()))
}

func statisticsHumanOutput(_ statistics: CalendarStatisticsResponse) -> String {
  let header = "events: \(statistics.eventCount)\tbusySeconds: \(statistics.busySeconds)"
  guard !statistics.calendars.isEmpty else {
    return header
  }

  return
    ([header]
    + statistics.calendars.map {
      "\($0.calendarTitle)\tevents=\($0.eventCount)\tbusySeconds=\($0.busySeconds)"
    }).joined(separator: "\n")
}

func eventHumanOutput(_ event: CalendarEventDetail) -> String {
  [
    "id: \(event.id)",
    "title: \(event.title)",
    "calendar: \(event.calendarTitle)",
    "start: \(formatDate(event.start))",
    "end: \(formatDate(event.end))",
  ].joined(separator: "\n")
}

func availabilityHumanOutput(from: Date, to: Date, conflicts: [CalendarEventSummary]) -> String {
  let status = conflicts.isEmpty ? "free" : "busy"
  let header = "availability: \(status)\t\(formatDate(from))\t\(formatDate(to))"
  guard !conflicts.isEmpty else {
    return header
  }

  return
    ([header]
    + conflicts.map { "\($0.id)\t\(formatDate($0.start))\t\(formatDate($0.end))\t\($0.title)" })
    .joined(separator: "\n")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}
