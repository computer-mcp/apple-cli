import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func fetchSmartList(
    listID: String,
    operation: String,
    store existingStore: REMStore? = nil
  ) throws -> (store: REMStore, smartList: REMSmartList) {
    let store = try existingStore ?? reminderKitStore(operation: operation, details: ["list_id": listID])
    guard let objectID = try coreREMObjectID(entity: "REMCDSmartList", identifier: listID) else {
      throw CLIError(code: .validationError, message: "A valid custom Smart List ID is required.")
    }
    try ReminderKitRuntimeMethod(owner: "REMStore",
      selector: "fetchCustomSmartListWithObjectID:error:", returnType: "@", argumentTypes: ["@", "^@"]
    ).require(operation: operation, receiver: store)
    var fetchError: AnyObject?
    let fetched = store.fetchCustomSmartList(withObjectID: objectID, error: &fetchError)
    if let error = fetchError as? NSError, fetched == nil,
      error.domain == "com.apple.reminderkit", error.code == -3000 {
      throw CLIError(code: .notFound, message: "Custom Smart List was not found.", details: ["list_id": listID])
    }
    guard fetchError == nil else {
      throw reminderKitOperationFailed(capability: capability, operation: operation,
        message: "ReminderKit could not read the custom Smart List.",
        details: ["list_id": listID, "fetch_error": reminderKitErrorSummary(fetchError)])
    }
    guard let fetched else {
      throw CLIError(code: .notFound, message: "Custom Smart List was not found.", details: ["list_id": listID])
    }
    guard let smartList = fetched as? REMSmartList,
      coreObjectIDsMatch(try reminderSmartListStorage(smartList, operation: operation).objectID, objectID)
    else {
      throw reminderKitOperationFailed(capability: capability, operation: operation,
        message: "ReminderKit returned an unexpected Smart List identity.", details: ["list_id": listID])
    }
    return (store, smartList)
  }

  static func fetchList(
    listID: String,
    operation: String
  ) throws -> (store: REMStore, list: REMList) {
    let store = try reminderKitStore(operation: operation, details: ["list_id": listID])
    var fetchError: AnyObject?
    if let objectID = try coreREMObjectID(entity: "REMCDList", identifier: listID),
      let list = store.fetchList(withObjectID: objectID, error: &fetchError) as? REMList
    {
      return (store, list)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the list by its ReminderKit identifier.",
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
    try ReminderKitRuntimeMethod(owner: "REMList", selector: "fetchRemindersAndSubtasksWithError:",
      returnType: "@", argumentTypes: ["^@"]
    ).require(operation: "convert", receiver: source)
    guard let reminders = source.fetchRemindersAndSubtasksWithError(&fetchError) as? [REMReminder],
      fetchError == nil else {
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
