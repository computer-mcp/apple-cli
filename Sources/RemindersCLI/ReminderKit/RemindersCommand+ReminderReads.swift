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
      return try readReminderFromPrivateStore(id: id)
    }
    do {
      return try sqliteReader.enrichReminder(reminder)
    } catch {
      return reminder
    }
  }

  func readReminderFromPrivateStore(id: String) throws -> ReminderDetail? {
    let seed = ReminderDetail(
      id: id,
      listId: "",
      listTitle: "",
      title: "",
      isCompleted: false,
      priority: 0
    )
    let debug = try sqliteReader.debugItem(reminder: seed)
    guard !debug.privateStoreMatches.isEmpty else {
      return nil
    }
    guard debug.privateStoreMatches.count == 1, let match = debug.privateStoreMatches.first else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Reminder SQLite identifier matched multiple reminders.",
        details: ["id": id, "match_count": "\(debug.privateStoreMatches.count)"]
      )
    }

    let reminder = ReminderDetail(
      id: match.calendarItemIdentifier ?? match.ckIdentifier ?? id,
      listId: match.listIdentifier ?? "",
      listTitle: match.listTitle ?? "",
      title: match.title ?? "",
      url: match.icsURL,
      isCompleted: match.completed ?? false,
      priority: 0,
      isFlagged: match.flagged,
      isUrgent: match.isUrgent,
      sectionId: match.sectionId,
      sectionTitle: match.sectionTitle,
      parentReminderId: match.parentReminderId,
      parentReminderTitle: match.parentReminderTitle,
      subtaskCount: match.subtaskCount
    )
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
