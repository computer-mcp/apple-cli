import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func fetchSmartList(
    listID: String,
    operation: String
  ) throws -> (store: REMStore, smartList: REMSmartList) {
    let store = try reminderKitStore(operation: operation, details: ["list_id": listID])
    var fetchError: AnyObject?
    if let objectID = remObjectID(entity: "REMCDSmartList", identifier: listID),
      let smartList = store.fetchCustomSmartList(withObjectID: objectID, error: &fetchError)
        as? REMSmartList
    {
      return (store, smartList)
    }

    if let dataView = REMSmartListsDataView(store: store),
      let smartLists = dataView.fetchCustomSmartListsWithError(&fetchError) as? [REMSmartList],
      let smartList = smartLists.first(where: { smartListMatches($0, listID: listID) })
    {
      return (store, smartList)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the custom Smart List.",
      details: [
        "list_id": listID,
        "fetch_error": reminderKitErrorSummary(fetchError),
      ]
    )
  }

  static func fetchList(
    listID: String,
    operation: String
  ) throws -> (store: REMStore, list: REMList) {
    let store = try reminderKitStore(operation: operation, details: ["list_id": listID])
    var fetchError: AnyObject?
    if let objectID = remObjectID(entity: "REMCDList", identifier: listID),
      let list = store.fetchList(withObjectID: objectID, error: &fetchError) as? REMList
    {
      return (store, list)
    }

    let lists = try reminderKitFetchLists(store: store, operation: operation)
    if let list = lists.first(where: { listMatches($0, listID: listID) }) {
      return (store, list)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the list by title or ReminderKit identifier.",
      details: [
        "list_id": listID,
        "fetch_error": reminderKitErrorSummary(fetchError),
      ]
    )
  }

  static func validateConvertibleSourceList(
    _ list: REMList,
    operation: String,
    details: [String: String]
  ) throws {
    guard !list.isGroup else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list groups cannot be converted to Smart Lists.",
        details: details
      )
    }
    guard !list.isShared else {
      throw CLIError(
        code: .validationError,
        message: "Shared reminder lists cannot be converted to Smart Lists.",
        details: details
      )
    }
    guard list.account?.capabilities?.supportsCustomSmartLists == true else {
      throw CLIError(
        code: .validationError,
        message: "The selected Reminders account does not support custom Smart Lists.",
        details: details
      )
    }
  }

  static func conversionTagName(
    for list: REMList,
    details: [String: String]
  ) throws -> String {
    let trimmed = (list.name ?? list.displayName ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Smart List conversion requires a non-empty source list title.",
        details: details
      )
    }
    guard !trimmed.contains("#") else {
      throw CLIError(
        code: .validationError,
        message: "Smart List conversion tag cannot contain `#`.",
        details: details.merging(["tag": trimmed], uniquingKeysWith: { _, new in new })
      )
    }
    return trimmed
  }

  static func conversionFilterData(tagName: String) throws -> Data {
    try ReminderSmartListFilterEncoder.encodeTagFilter(tagName: tagName)
  }

  static func fetchRemindersForConversion(
    _ source: REMList,
    details: [String: String]
  ) throws -> [REMReminder] {
    var fetchError: AnyObject?
    let reminders = source.fetchRemindersAndSubtasksWithError(&fetchError) as? [REMReminder] ?? []
    guard fetchError == nil else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "convert",
        message: "ReminderKit could not fetch source list reminders for Smart List conversion.",
        details: details.merging(
          ["fetch_error": reminderKitErrorSummary(fetchError)],
          uniquingKeysWith: { _, new in new }
        )
      )
    }

    var seen: Set<UUID> = []
    var unique: [REMReminder] = []
    for reminder in reminders {
      guard let uuid = reminder.remObjectID?.uuid ?? reminder.objectID?.uuid else {
        unique.append(reminder)
        continue
      }
      if seen.insert(uuid).inserted {
        unique.append(reminder)
      }
    }
    return unique
  }
}
