import EventKit
import Foundation
import Utility

extension EventKitCalendarBackend {
  public func listSources() throws -> [CalendarSourceRecord] {
    let store = try eventStoreWithReadAccess()
    return store.sources.map(calendarSourceRecord).sorted { lhs, rhs in
      let order = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
      return order == .orderedSame ? lhs.id < rhs.id : order == .orderedAscending
    }
  }

  public func readSource(id: String) throws -> CalendarSourceRecord? {
    let store = try eventStoreWithReadAccess()
    return store.source(withIdentifier: id).map(calendarSourceRecord)
  }

  public func readCalendar(id: String) throws -> CalendarRecord? {
    let store = try eventStoreWithReadAccess()
    guard let calendar = store.calendar(withIdentifier: id),
      calendar.allowedEntityTypes.contains(.event)
    else { return nil }
    return calendarRecord(calendar)
  }

  public func createCalendar(_ draft: CalendarCreateDraft) throws -> CalendarRecord {
    let title = try validatedCalendarTitle(draft.title)
    let canonicalColor = try draft.color.map(validatedCalendarColor)
    let color = try canonicalColor.map(calendarColor)
    let store = try eventStoreWithCalendarWriteAccess()
    guard let source = store.source(withIdentifier: draft.sourceId) else {
      throw CLIError(
        code: .notFound, message: "Calendar source was not found.",
        details: ["source_id": draft.sourceId])
    }
    try requireCalendarCreationSource(calendarSourceRecord(source))
    let calendar = EKCalendar(for: .event, eventStore: store)
    calendar.source = source
    calendar.title = title
    if let color { calendar.color = color }
    try saveCalendarCollection(calendar, in: store)
    let saved = try coldCalendarCollection(id: calendar.calendarIdentifier)
    guard saved.sourceId == draft.sourceId, saved.title == title,
      canonicalColor == nil || saved.color == canonicalColor
    else { throw calendarCollectionVerificationFailure(id: calendar.calendarIdentifier) }
    return saved
  }

  public func updateCalendar(current: CalendarRecord, patch: CalendarPatch) throws -> CalendarRecord {
    let title = try patch.title.map(validatedCalendarTitle)
    let color = try patch.color.map(calendarColor)
    let store = try eventStoreWithCalendarWriteAccess()
    let calendar = try calendarCollection(current: current, in: store)
    var expected = current
    if let title { expected.title = title }
    if let color { expected.color = calendarColorString(color) }
    guard expected != current else { return current }
    try requireMutableCalendar(current)
    if let title { calendar.title = title }
    if let color { calendar.color = color }
    try saveCalendarCollection(calendar, in: store)
    let saved = try coldCalendarCollection(id: calendar.calendarIdentifier)
    guard saved == expected else {
      throw calendarCollectionVerificationFailure(id: calendar.calendarIdentifier)
    }
    return saved
  }

  public func deleteCalendar(current: CalendarRecord) throws -> Bool {
    let store = try eventStoreWithCalendarWriteAccess()
    let calendar = try calendarCollection(current: current, in: store)
    try requireMutableCalendar(current)
    do {
      try store.removeCalendar(calendar, commit: true)
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "Calendar deletion failed; check its current state before retrying.",
        details: CLIError.diagnosticDetails(for: error).merging([
          "calendar_id": current.id, "source_id": current.sourceId ?? "", "outcome": "unknown",
        ]) { _, value in value })
    }
    let coldStore = try eventStoreWithReadAccess()
    guard coldStore.calendar(withIdentifier: current.id) == nil else {
      throw calendarCollectionVerificationFailure(id: current.id)
    }
    return true
  }

  private func calendarCollection(current: CalendarRecord, in store: EKEventStore) throws -> EKCalendar {
    guard let calendar = store.calendar(withIdentifier: current.id),
      calendar.allowedEntityTypes.contains(.event)
    else {
      throw CLIError(
        code: .notFound, message: "Calendar was not found.", details: ["calendar_id": current.id])
    }
    let actual = calendarRecord(calendar)
    guard actual == current else {
      throw CLIError(
        code: .ambiguousIdentity, message: "Calendar state changed before the operation; read it again.",
        details: ["calendar_id": current.id])
    }
    return calendar
  }

  private func saveCalendarCollection(_ calendar: EKCalendar, in store: EKEventStore) throws {
    do {
      try store.saveCalendar(calendar, commit: true)
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "Calendar save failed; check its current state before retrying.",
        details: CLIError.diagnosticDetails(for: error).merging([
          "calendar_id": calendar.calendarIdentifier,
          "source_id": calendar.source?.sourceIdentifier ?? "", "outcome": "unknown",
        ]) { _, value in value })
    }
  }

  private func coldCalendarCollection(id: String) throws -> CalendarRecord {
    let store = try eventStoreWithReadAccess()
    guard let calendar = store.calendar(withIdentifier: id),
      calendar.allowedEntityTypes.contains(.event)
    else { throw calendarCollectionVerificationFailure(id: id) }
    return calendarRecord(calendar)
  }

  private func calendarCollectionVerificationFailure(id: String) -> CLIError {
    CLIError(
      code: .backendUnavailable,
      message: "Calendar change was accepted but could not be verified from a fresh read.",
      details: ["calendar_id": id, "save_outcome": "accepted", "verification": "unavailable"])
  }
}
