import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func addConvertedSmartListChangeItem(
    saveRequest: REMSaveRequest,
    accountChange: REMAccountChangeItem,
    source: REMList,
    details: [String: String]
  ) throws -> REMSmartListChangeItem {
    let change: REMSmartListChangeItem?
    if let parent = source.parent,
      let parentChange = saveRequest.updateList(parent) as? REMListChangeItem,
      let sublistContext = parentChange.sublistContext
    {
      change =
        saveRequest.addCustomSmartList(
          withName: source.name,
          toListSublistContextChangeItem: sublistContext,
          smartListObjectID: nil as REMObjectID?
        ) as? REMSmartListChangeItem
      if let change {
        sublistContext.addSmartListChangeItem(change)
        change.parentSubContainerID = parent.remObjectID ?? parent.objectID
      }
    } else {
      change =
        saveRequest.addCustomSmartList(
          withName: source.name,
          toAccountChangeItem: accountChange,
          smartListObjectID: nil as REMObjectID?
        ) as? REMSmartListChangeItem
      if let change {
        accountChange.addSmartListChangeItem(change)
      }
    }

    guard let change else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "convert",
        message: "ReminderKit custom Smart List change item could not be created for conversion.",
        details: details
      )
    }
    return change
  }

  static func addTag(
    _ tag: String,
    to context: REMReminderHashtagContextChangeItem
  ) {
    guard
      !hashtagObjects(in: context).contains(where: {
        normalizedTagKey($0.name) == normalizedTagKey(tag)
      })
    else {
      return
    }
    _ = context.addHashtag(withType: 0, name: tag)
  }

  static func hashtagObjects(in context: REMReminderHashtagContextChangeItem)
    -> [REMHashtag]
  {
    if let values = context.hashtags as? Set<REMHashtag> {
      return Array(values)
    }
    if let values = context.hashtags {
      return values.compactMap { $0.base as? REMHashtag }
    }
    return []
  }
}
