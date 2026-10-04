import Foundation
import Utility

extension RemindersCommand {
  public func listReminderLists() throws -> [ReminderListRecord] {
    let lists = try fetchReminderKitLists()
    do {
      return try sqliteReader.enrichLists(lists)
    } catch {
      return lists
    }
  }

  public func listReminderListSources() throws -> [ReminderListSourceRecord] {
    try fetchReminderKitListSources()
  }

  public func defaultReminderListSource() throws -> ReminderListSourceRecord {
    try fetchDefaultReminderKitListSource()
  }

  public func listReminders(_ query: ReminderQuery) throws -> [ReminderSummary] {
    let reminders = try fetchReminderKitReminders(query)
    do {
      return try sqliteReader.enrichReminders(reminders)
    } catch {
      return reminders
    }
  }

  public func readReminder(id: String) throws -> ReminderDetail? {
    guard let reminder = try readReminderKitReminder(id: id) else {
      return nil
    }
    do {
      return try sqliteReader.enrichReminder(reminder)
    } catch {
      return reminder
    }
  }

  func enrichedReminderListsForVerification() throws -> [ReminderListRecord] {
    try sqliteReader.enrichLists(try fetchReminderKitLists())
  }
}
