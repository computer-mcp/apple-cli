import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

enum ReminderSmartListWriter {
  static let capability = "smart_lists"
  static let customSmartListType = "com.apple.reminders.smartlist.custom"
  static let minimumSupportedVersion: Int64 = 20_220_430

  static func preflight(listID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard let listID else {
      return
    }
    _ = try fetchSmartList(listID: listID, operation: "preflight")
  }

  static func createSmartList(
    title: String,
    sourceID: String,
    criteria: ReminderSmartListCriteria
  ) throws {
    let filterData = try ReminderSmartListFilterEncoder.encode(criteria: criteria)
    try preflight(listID: nil)

    let details = [
      "operation": "create",
      "title": title,
      "source_id": sourceID,
      "criteria_match": criteria.match,
    ]
    let store = try reminderKitStore(operation: "create", details: details)
    let account = try preferredAccount(
      store: store,
      sourceID: sourceID,
      operation: "create",
      details: details
    )
    try validateCustomSmartListsSupported(account: account, operation: "create", details: details)

    let saveRequest = try reminderKitSaveRequest(
      store: store, operation: "create", details: details)
    let accountChange = try accountChangeItem(
      saveRequest: saveRequest,
      account: account,
      operation: "create",
      details: details
    )
    guard
      let changeItem = saveRequest.addCustomSmartList(
        withName: title,
        toAccountChangeItem: accountChange,
        smartListObjectID: nil as REMObjectID?
      ) as? REMSmartListChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "create",
        message: "ReminderKit custom Smart List change item could not be created.",
        details: details
      )
    }

    accountChange.addSmartListChangeItem(changeItem)
    try configureCustomSmartListChange(
      changeItem,
      title: title,
      filterData: filterData,
      account: account,
      operation: "create",
      details: details
    )
    try save(saveRequest, operation: "create", details: details)
  }

  static func updateSmartListCriteria(listID: String, criteria: ReminderSmartListCriteria) throws {
    let filterData = try ReminderSmartListFilterEncoder.encode(criteria: criteria)
    try preflight(listID: listID)

    let resolved = try fetchSmartList(listID: listID, operation: "update")
    let details = [
      "operation": "update",
      "list_id": listID,
      "criteria_match": criteria.match,
    ]
    try validateCustomSmartListsSupported(
      account: resolved.smartList.account,
      operation: "update",
      details: details
    )
    guard let saveRequest = REMSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "update",
        message: "ReminderKit save request could not be created.",
        details: details
      )
    }
    guard
      let changeItem = saveRequest.updateSmartList(resolved.smartList) as? REMSmartListChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "update",
        message: "ReminderKit Smart List change item could not be updated.",
        details: details
      )
    }

    try configureCustomSmartListChange(
      changeItem,
      title: resolved.smartList.name,
      filterData: filterData,
      account: resolved.smartList.account,
      operation: "update",
      details: details
    )
    try save(saveRequest, operation: "update", details: details)
  }

  static func convertListToSmartList(listID: String) throws {
    try preflight(listID: nil)

    let resolved = try fetchList(listID: listID, operation: "convert")
    let source = resolved.list
    let details = [
      "operation": "convert",
      "list_id": listID,
    ]
    try validateConvertibleSourceList(source, operation: "convert", details: details)
    guard let sourceAccount = source.account else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "convert",
        message: "ReminderKit source list account was unavailable.",
        details: details
      )
    }
    try validateCustomSmartListsSupported(
      account: sourceAccount,
      operation: "convert",
      details: details
    )

    var fetchError: AnyObject?
    guard let defaultList = resolved.store.fetchDefaultListWithError(&fetchError) as? REMList else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "convert",
        message: "ReminderKit default list could not be fetched for Smart List conversion.",
        details: details.merging(
          ["fetch_error": reminderKitErrorSummary(fetchError)],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
    guard
      !objectIDsMatch(
        source.remObjectID ?? source.objectID, defaultList.remObjectID ?? defaultList.objectID)
    else {
      throw CLIError(
        code: .validationError,
        message: "The default Reminders list cannot be converted to a Smart List.",
        details: details
      )
    }
    guard objectIDsMatch(source.accountID, defaultList.accountID) else {
      throw CLIError(
        code: .validationError,
        message: "Smart List conversion requires the default list to be in the same account.",
        details: details.merging(
          [
            "source_account_id": objectIDBinding(source.accountID) ?? "",
            "default_account_id": objectIDBinding(defaultList.accountID) ?? "",
          ],
          uniquingKeysWith: { _, new in new }
        )
      )
    }

    let tagName = try conversionTagName(for: source, details: details)
    let filterData = try conversionFilterData(tagName: tagName)
    let reminders = try fetchRemindersForConversion(source, details: details)
    let saveRequest = try reminderKitSaveRequest(
      store: resolved.store, operation: "convert", details: details)
    let accountChange = try accountChangeItem(
      saveRequest: saveRequest,
      account: sourceAccount,
      operation: "convert",
      details: details
    )
    guard let sourceChange = saveRequest.updateList(source) as? REMListChangeItem,
      let defaultChange = saveRequest.updateList(defaultList) as? REMListChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "convert",
        message: "ReminderKit list change items could not be updated for Smart List conversion.",
        details: details
      )
    }

    for reminder in reminders {
      guard let reminderChange = saveRequest.updateReminder(reminder) as? REMReminderChangeItem
      else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "convert",
          message:
            "ReminderKit reminder change item could not be updated for Smart List conversion.",
          details: details
        )
      }
      if reminderChange.isSubtask() || reminderChange.parentReminderID != nil {
        reminderChange.removeFromParentReminder()
      }
      if let hashtagContext = reminderChange.hashtagContext {
        addTag(tagName, to: hashtagContext)
      }
      defaultChange.addReminderChangeItem(reminderChange)
    }

    let smartChange = try addConvertedSmartListChangeItem(
      saveRequest: saveRequest,
      accountChange: accountChange,
      source: source,
      details: details
    )
    try configureCustomSmartListChange(
      smartChange,
      title: source.name,
      filterData: filterData,
      account: sourceAccount,
      operation: "convert",
      details: details
    )
    sourceChange.removeFromParent(withAccountChangeItem: accountChange)

    try save(
      saveRequest,
      operation: "convert",
      details: details.merging(
        [
          "tag": tagName,
          "moved_reminder_count": "\(reminders.count)",
          "default_list_id": objectIDBinding(defaultList.remObjectID ?? defaultList.objectID) ?? "",
        ],
        uniquingKeysWith: { _, new in new }
      )
    )
  }

  static func deleteSmartList(listID: String) throws {
    try preflight(listID: listID)

    let resolved = try fetchSmartList(listID: listID, operation: "delete")
    let details = [
      "operation": "delete",
      "list_id": listID,
    ]
    try validateCustomSmartListsSupported(
      account: resolved.smartList.account,
      operation: "delete",
      details: details
    )
    let saveRequest = try reminderKitSaveRequest(
      store: resolved.store, operation: "delete", details: details)
    let accountChange = try accountChangeItem(
      saveRequest: saveRequest,
      account: resolved.smartList.account,
      operation: "delete",
      details: details
    )
    guard
      let changeItem = saveRequest.updateSmartList(resolved.smartList) as? REMSmartListChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit Smart List change item could not be updated for deletion.",
        details: details
      )
    }
    try removeSmartListFromParent(changeItem, accountChange: accountChange, details: details)
    try save(saveRequest, operation: "delete", details: details)
  }
}
