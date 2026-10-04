import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMAccount", NSClassFromString("REMAccount") != nil),
      ("REMAccountCapabilities", NSClassFromString("REMAccountCapabilities") != nil),
      ("REMAccountChangeItem", NSClassFromString("REMAccountChangeItem") != nil),
      ("REMSmartList", NSClassFromString("REMSmartList") != nil),
      ("REMSmartListChangeItem", NSClassFromString("REMSmartListChangeItem") != nil),
      (
        "REMSmartListCustomContextChangeItem",
        NSClassFromString("REMSmartListCustomContextChangeItem") != nil
      ),
      (
        "REMObjectID.objectIDWithURL:",
        REMObjectID.responds(to: NSSelectorFromString("objectIDWithURL:"))
      ),
      (
        "REMStore.fetchAccountsWithError:",
        REMStore.instancesRespond(to: NSSelectorFromString("fetchAccountsWithError:"))
      ),
      (
        "REMStore.fetchCustomSmartListWithObjectID:error:",
        REMStore.instancesRespond(to: #selector(REMStore.fetchCustomSmartList(withObjectID:error:)))
      ),
      (
        "REMSaveRequest.updateAccount:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateAccount(_:)))
      ),
      (
        "REMSaveRequest.addCustomSmartListWithName:toAccountChangeItem:smartListObjectID:",
        REMSaveRequest.instancesRespond(
          to: NSSelectorFromString(
            "addCustomSmartListWithName:toAccountChangeItem:smartListObjectID:")
        )
      ),
      (
        "REMSaveRequest.updateSmartList:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateSmartList(_:)))
      ),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMAccountCapabilities.supportsCustomSmartLists",
        REMAccountCapabilities.instancesRespond(
          to: NSSelectorFromString("supportsCustomSmartLists"))
      ),
      (
        "REMAccountChangeItem.addSmartListChangeItem:",
        REMAccountChangeItem.instancesRespond(to: NSSelectorFromString("addSmartListChangeItem:"))
      ),
      (
        "REMSmartListChangeItem.customContext",
        REMSmartListChangeItem.instancesRespond(to: NSSelectorFromString("customContext"))
      ),
      (
        "REMSmartListCustomContextChangeItem.setName:",
        REMSmartListCustomContextChangeItem.instancesRespond(to: NSSelectorFromString("setName:"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
