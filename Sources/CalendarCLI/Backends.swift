import CryptoKit
import EventKit
import Foundation
import Utility

public struct EventKitCalendarBackend: CalendarReading, CalendarMutating {
  public init() {}

  public func listCalendars() throws -> [CalendarRecord] {
    let store = try eventStoreWithReadAccess()
    return store.calendars(for: .event)
      .map(calendarRecord)
      .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
  }

  public func listEvents(_ query: CalendarEventQuery) throws -> [CalendarEventSummary] {
    let store = try eventStoreWithReadAccess()
    let calendars = try resolveCalendars(query.calendarSelector, store: store)
    let predicate = store.predicateForEvents(
      withStart: query.from, end: query.to, calendars: calendars)
    let searchText = query.searchText?.trimmingCharacters(in: .whitespacesAndNewlines)

    return store.events(matching: predicate)
      .filter { event in
        guard let searchText, !searchText.isEmpty else {
          return true
        }

        return event.title.localizedCaseInsensitiveContains(searchText)
          || (event.location?.localizedCaseInsensitiveContains(searchText) ?? false)
          || (event.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
      }
      .sorted { lhs, rhs in lhs.startDate < rhs.startDate }
      .prefix(query.limit)
      .map(eventSummary)
  }

  public func readEvent(id: String) throws -> CalendarEventDetail? {
    let store = try eventStoreWithReadAccess()
    let event =
      store.event(withIdentifier: id) ?? (store.calendarItem(withIdentifier: id) as? EKEvent)
    return event.map(eventDetail)
  }

  public func listEventOccurrences(_ query: CalendarEventOccurrenceQuery) throws
    -> CalendarEventOccurrencesResponse?
  {
    let store = try eventStoreWithReadAccess()
    guard
      let seriesEvent = store.event(withIdentifier: query.eventId)
        ?? (store.calendarItem(withIdentifier: query.eventId) as? EKEvent)
    else {
      return nil
    }

    let selectedCalendars = try resolveCalendars(query.calendarSelector, store: store)
    if let selectedCalendars,
      !selectedCalendars.contains(where: {
        $0.calendarIdentifier == seriesEvent.calendar.calendarIdentifier
      })
    {
      throw CLIError(
        code: .notFound,
        message: "Calendar selector did not match the event calendar.",
        details: [
          "id": query.eventId,
          "calendar": query.calendarSelector ?? "",
        ]
      )
    }

    let predicate = store.predicateForEvents(
      withStart: query.from,
      end: query.to,
      calendars: selectedCalendars ?? [seriesEvent.calendar]
    )
    let occurrences = store.events(matching: predicate)
      .filter { sameEventSeries($0, seriesEvent) }
      .sorted { lhs, rhs in
        if lhs.startDate == rhs.startDate {
          return lhs.eventIdentifier < rhs.eventIdentifier
        }
        return lhs.startDate < rhs.startDate
      }
      .prefix(query.limit)
      .map { eventOccurrence($0, seriesId: query.eventId) }

    return CalendarEventOccurrencesResponse(
      series: eventDetail(seriesEvent),
      from: query.from,
      to: query.to,
      calendarSelector: query.calendarSelector,
      occurrences: Array(occurrences)
    )
  }

  public func calendarForMutation(selector: String) throws -> CalendarRecord {
    let store = try eventStoreWithCalendarWriteAccess()
    return calendarRecord(try resolveSingleCalendar(selector, store: store))
  }

  public func eventForMutation(id: String) throws -> CalendarEventDetail? {
    let store = try eventStoreWithCalendarWriteAccess()
    let event =
      store.event(withIdentifier: id) ?? (store.calendarItem(withIdentifier: id) as? EKEvent)
    return event.map(eventDetail)
  }

  public func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEventDetail {
    let store = try eventStoreWithCalendarWriteAccess()
    guard
      let calendar = store.calendars(for: .event).first(where: {
        $0.calendarIdentifier == draft.calendarId
      })
    else {
      throw CLIError(
        code: .notFound, message: "Calendar was not found.",
        details: ["calendar_id": draft.calendarId])
    }
    guard calendar.allowsContentModifications else {
      throw CLIError(
        code: .validationError, message: "Calendar does not allow modifications.",
        details: ["calendar": calendar.title])
    }

    let event = EKEvent(eventStore: store)
    event.calendar = calendar
    applyDraft(draft, to: event)
    try store.save(event, span: .thisEvent, commit: true)
    return eventDetail(event)
  }

  public func updateEvent(id: String, patch: CalendarEventPatch) throws -> CalendarEventDetail {
    let store = try eventStoreWithCalendarWriteAccess()
    guard
      let event = store.event(withIdentifier: id)
        ?? (store.calendarItem(withIdentifier: id) as? EKEvent)
    else {
      throw CLIError(code: .notFound, message: "Calendar event was not found.", details: ["id": id])
    }

    if let calendarId = patch.calendarId {
      guard
        let calendar = store.calendars(for: .event).first(where: {
          $0.calendarIdentifier == calendarId
        })
      else {
        throw CLIError(
          code: .notFound, message: "Calendar was not found.", details: ["calendar_id": calendarId])
      }
      guard calendar.allowsContentModifications else {
        throw CLIError(
          code: .validationError, message: "Calendar does not allow modifications.",
          details: ["calendar": calendar.title])
      }
      event.calendar = calendar
    }

    applyPatch(patch, to: event)
    try store.save(event, span: .thisEvent, commit: true)
    return eventDetail(event)
  }

  public func deleteEvent(id: String) throws -> Bool {
    let store = try eventStoreWithCalendarWriteAccess()
    guard
      let event = store.event(withIdentifier: id)
        ?? (store.calendarItem(withIdentifier: id) as? EKEvent)
    else {
      throw CLIError(code: .notFound, message: "Calendar event was not found.", details: ["id": id])
    }

    try store.remove(event, span: .thisEvent, commit: true)
    return true
  }

  private func resolveCalendars(_ selector: String?, store: EKEventStore) throws -> [EKCalendar]? {
    guard let selector, !selector.isEmpty else {
      return nil
    }

    let calendars = store.calendars(for: .event)
    let idMatches = calendars.filter { $0.calendarIdentifier == selector }
    if !idMatches.isEmpty {
      return idMatches
    }

    let titleMatches = calendars.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }

    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Calendar selector matched multiple calendars.",
        details: ["selector": selector]
      )
    }

    guard !titleMatches.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "Calendar selector did not match any calendar.",
        details: ["selector": selector]
      )
    }

    return titleMatches
  }

  private func resolveSingleCalendar(_ selector: String, store: EKEventStore) throws -> EKCalendar {
    let calendars = store.calendars(for: .event)
    let idMatches = calendars.filter { $0.calendarIdentifier == selector }
    if let match = idMatches.first {
      return match
    }

    let titleMatches = calendars.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }

    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Calendar selector matched multiple calendars.",
        details: ["selector": selector]
      )
    }

    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Calendar selector did not match any calendar.",
        details: ["selector": selector]
      )
    }

    return match
  }
}
