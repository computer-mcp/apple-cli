import CryptoKit
import EventKit
import Foundation
import Utility

public protocol CalendarReading: Sendable {
  func listCalendars() throws -> [CalendarRecord]
  func listEvents(_ query: CalendarEventQuery) throws -> [CalendarEventSummary]
  func readEvent(id: String) throws -> CalendarEventDetail?
  func listEventOccurrences(_ query: CalendarEventOccurrenceQuery) throws
    -> CalendarEventOccurrencesResponse?
}

public protocol CalendarMutating: Sendable {
  func calendarForMutation(selector: String) throws -> CalendarRecord
  func eventForMutation(id: String) throws -> CalendarEventDetail?
  func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEventDetail
  func updateEvent(id: String, patch: CalendarEventPatch) throws -> CalendarEventDetail
  func deleteEvent(id: String) throws -> Bool
}
