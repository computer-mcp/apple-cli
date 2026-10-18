import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func smartListChangeID(_ changeItem: REMSmartListChangeItem, operation: String) throws -> String {
    try ReminderKitRuntimeMethod(owner: "REMSmartListChangeItem", selector: "storage", returnType: "@")
      .require(operation: operation, receiver: changeItem)
    guard let storage = changeItem.storage else {
      throw coreReminderKitError(operation: operation, message: "Smart List change storage is unavailable.")
    }
    try ReminderKitRuntimeMethod(owner: "REMSmartListStorage", selector: "objectID", returnType: "@")
      .require(operation: operation, receiver: storage)
    guard let id = storage.objectID, id.entityName == "REMCDSmartList", let uuid = id.uuid else {
      throw coreReminderKitError(operation: operation, message: "Smart List change identity is unavailable.")
    }
    return uuid.uuidString
  }

  static func configureCustomSmartListChange(
    _ changeItem: REMSmartListChangeItem,
    title: String?,
    filterData: Data,
    account: REMAccount,
    operation: String,
    details: [String: String]
  ) throws {
    try requireSmartListChangeItemSetters(changeItem, operation: operation, details: details)
    changeItem.smartListType = customSmartListType
    changeItem.filterData = filterData
    changeItem.parentOwnerID = account.remObjectID
    changeItem.accountID = account.remObjectID
    if let title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      let customContext = changeItem.customContext
    {
      customContext.name = title
    }
    setMinimumSupportedVersion(on: changeItem)
  }

  static func requireSmartListChangeItemSetters(
    _ changeItem: REMSmartListChangeItem,
    operation: String,
    details: [String: String]
  ) throws {
    let requirements: [(String, Bool)] = [
      (
        "REMSmartListChangeItem.setSmartListType:",
        changeItem.responds(to: NSSelectorFromString("setSmartListType:"))
      ),
      (
        "REMSmartListChangeItem.setFilterData:",
        changeItem.responds(to: NSSelectorFromString("setFilterData:"))
      ),
      (
        "REMSmartListChangeItem.setParentOwnerID:",
        changeItem.responds(to: NSSelectorFromString("setParentOwnerID:"))
      ),
      (
        "REMSmartListChangeItem.setAccountID:",
        changeItem.responds(to: NSSelectorFromString("setAccountID:"))
      ),
    ]
    let missing = requirements.compactMap { name, available in available ? nil : name }
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: missing,
        details: details.merging(
          ["operation": operation],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  static func removeSmartListFromParent(
    _ changeItem: REMSmartListChangeItem,
    accountChange: REMAccountChangeItem,
    details: [String: String]
  ) throws {
    guard
      changeItem.responds(
        to: NSSelectorFromString("removeFromParentWithAccountChangeItem:"))
    else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: ["REMSmartListChangeItem.removeFromParentWithAccountChangeItem:"],
        details: details
      )
    }
    changeItem.removeFromParent(withAccountChangeItem: accountChange)
  }

  static func setMinimumSupportedVersion(on changeItem: REMSmartListChangeItem) {
    let version = NSNumber(value: minimumSupportedVersion)
    if changeItem.responds(to: NSSelectorFromString("setMinimumSupportedVersion:")) {
      changeItem.setValue(version, forKey: "minimumSupportedVersion")
    }
  }
}
