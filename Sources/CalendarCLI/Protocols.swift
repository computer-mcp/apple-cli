import CryptoKit
import EventKit
import Foundation
import Utility

public protocol CalendarReading: Sendable {
  func listSources() throws -> [CalendarSourceRecord]
  func readSource(id: String) throws -> CalendarSourceRecord?
  func listCalendars(sourceID: String?) throws -> [CalendarRecord]
  func readCalendar(id: String) throws -> CalendarRecord?
  func listEvents(_ query: CalendarEventQuery) throws -> [CalendarEventSummary]
  func readEvent(id: String) throws -> CalendarEventDetail?
  func listEventOccurrences(_ query: CalendarEventOccurrenceQuery) throws
    -> CalendarEventOccurrencesResponse?
}

public protocol CalendarMutating: Sendable {
  func createCalendar(_ draft: CalendarCreateDraft) throws -> CalendarRecord
  func updateCalendar(current: CalendarRecord, patch: CalendarPatch) throws -> CalendarRecord
  func deleteCalendar(current: CalendarRecord) throws -> Bool
  func calendarForMutation(selector: String) throws -> CalendarRecord
  func eventForMutation(id: String) throws -> CalendarEventDetail?
  func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEventDetail
  func updateEvent(id: String, patch: CalendarEventPatch) throws -> CalendarEventDetail
  func deleteEvent(id: String) throws -> Bool
}
