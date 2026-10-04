import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderListGroupWriter {
  static let capability = "list_groups"

  static func createGroup(title: String) throws {
    try preflight()
    let store = try reminderKitStore(operation: "create", details: ["title": title])
    let account = try preferredAccount(store: store, operation: "create", details: ["title": title])
    let saveRequest = try reminderKitSaveRequest(
      store: store,
      operation: "create",
      details: ["title": title]
    )
    let accountChange = try accountChangeItem(
      saveRequest: saveRequest,
      account: account,
      operation: "create",
      details: ["title": title]
    )
    guard let groupContext = accountChange.groupContext else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "create",
        message: "ReminderKit account group context was unavailable.",
        details: ["title": title]
      )
    }

    let change: REMListChangeItem?
    if REMSaveRequest.instancesRespond(
      to: NSSelectorFromString("addGroupWithName:toAccountGroupContextChangeItem:groupObjectID:")
    ) {
      change =
        saveRequest.addGroup(
          withName: title,
          toAccountGroupContextChangeItem: groupContext,
          groupObjectID: nil
        ) as? REMListChangeItem
    } else {
      change =
        saveRequest.addGroup(
          withName: title,
          toAccountGroupContextChangeItem: groupContext
        ) as? REMListChangeItem
    }
    guard let change else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "create",
        message: "ReminderKit group change item could not be created.",
        details: ["title": title]
      )
    }
    change.parentOwnerID = account.remObjectID
    try save(saveRequest, operation: "create", details: ["title": title])
  }

  static func renameGroup(groupID: String, title: String) throws {
    try preflight()
    let resolved = try fetchGroup(groupID: groupID, operation: "rename")
    let saveRequest = try reminderKitSaveRequest(
      store: resolved.store,
      operation: "rename",
      details: ["group_id": groupID, "title": title]
    )
    guard let change = saveRequest.updateList(resolved.group) as? REMListChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "rename",
        message: "ReminderKit group change item could not be updated.",
        details: ["group_id": groupID, "title": title]
      )
    }
    change.name = title
    change.parentOwnerID = resolved.group.account?.remObjectID
    try save(saveRequest, operation: "rename", details: ["group_id": groupID, "title": title])
  }

  static func deleteGroup(groupID: String) throws {
    try preflight()
    let resolved = try fetchGroup(groupID: groupID, operation: "delete")
    let account = try preferredAccount(
      store: resolved.store,
      preferredList: resolved.group,
      operation: "delete",
      details: ["group_id": groupID]
    )
    let saveRequest = try reminderKitSaveRequest(
      store: resolved.store,
      operation: "delete",
      details: ["group_id": groupID]
    )
    let accountChange = try accountChangeItem(
      saveRequest: saveRequest,
      account: account,
      operation: "delete",
      details: ["group_id": groupID]
    )
    let children = try childLists(
      store: resolved.store,
      group: resolved.group,
      operation: "delete",
      details: ["group_id": groupID]
    )
    for child in children {
      guard let childChange = saveRequest.updateList(child) as? REMListChangeItem else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "delete",
          message: "ReminderKit child list change item could not be updated.",
          details: [
            "group_id": groupID,
            "child_list_id": objectIDBinding(child.remObjectID ?? child.objectID) ?? "",
          ]
        )
      }
      childChange.parentOwnerID = account.remObjectID
      childChange.parentSubContainerID = nil
    }

    guard let groupChange = saveRequest.updateList(resolved.group) as? REMListChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit group change item could not be updated.",
        details: ["group_id": groupID]
      )
    }
    groupChange.removeFromParent(withAccountChangeItem: accountChange)
    try save(saveRequest, operation: "delete", details: ["group_id": groupID])
  }

  static func moveList(listID: String, toGroupID groupID: String) throws {
    try preflight(listID: listID)
    let resolvedList = try fetchList(listID: listID, operation: "move")
    let resolvedGroup = try fetchGroup(
      groupID: groupID,
      store: resolvedList.store,
      operation: "move",
      details: ["list_id": listID, "group_id": groupID]
    )
    try updateListParentGroup(
      list: resolvedList.list,
      group: resolvedGroup,
      store: resolvedList.store,
      operation: "move",
      details: ["list_id": listID, "group_id": groupID]
    )
  }

  static func removeListFromGroup(listID: String) throws {
    try preflight(listID: listID)
    let resolved = try fetchList(listID: listID, operation: "remove")
    try updateListParentGroup(
      list: resolved.list,
      group: nil,
      store: resolved.store,
      operation: "remove",
      details: ["list_id": listID]
    )
  }

  private static func updateListParentGroup(
    list: REMList,
    group: REMList?,
    store: REMStore,
    operation: String,
    details: [String: String]
  ) throws {
    if let group {
      try validateSameAccount(list: list, group: group, operation: operation, details: details)
    }
    let account = try preferredAccount(
      store: store,
      preferredList: list,
      fallbackList: group,
      operation: operation,
      details: details
    )
    let saveRequest = try reminderKitSaveRequest(
      store: store, operation: operation, details: details)
    guard let change = saveRequest.updateList(list) as? REMListChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit list change item could not be updated.",
        details: details
      )
    }
    change.parentOwnerID = account.remObjectID
    change.parentSubContainerID = group?.remObjectID ?? group?.objectID
    try save(saveRequest, operation: operation, details: details)
  }

  private static func preflight(listID: String? = nil) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard let listID else {
      return
    }
    _ = try fetchList(listID: listID, operation: "preflight")
  }

  private static func fetchList(
    listID: String,
    operation: String
  ) throws -> (store: REMStore, list: REMList) {
    let store = try reminderKitStore(operation: operation, details: ["list_id": listID])
    return (
      store,
      try fetchList(
        listID: listID,
        store: store,
        operation: operation,
        details: ["list_id": listID]
      )
    )
  }

  private static func fetchList(
    listID: String,
    store: REMStore,
    operation: String,
    details: [String: String]
  ) throws -> REMList {
    var fetchError: AnyObject?
    if let objectID = remObjectID(entity: "REMCDList", identifier: listID),
      let list = store.fetchList(withObjectID: objectID, error: &fetchError) as? REMList
    {
      return list
    }

    let lists = try reminderKitFetchLists(store: store, operation: operation)
    if let list = lists.first(where: { listMatches($0, listID: listID) }) {
      return list
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the list by title or ReminderKit identifier.",
      details: details.merging(
        ["fetch_error": reminderKitErrorSummary(fetchError)],
        uniquingKeysWith: { _, new in new }
      )
    )
  }

  private static func fetchGroup(
    groupID: String,
    operation: String
  ) throws -> (store: REMStore, group: REMList) {
    let store = try reminderKitStore(operation: operation, details: ["group_id": groupID])
    let group = try fetchGroup(
      groupID: groupID,
      store: store,
      operation: operation,
      details: ["group_id": groupID]
    )
    return (store, group)
  }

  private static func fetchGroup(
    groupID: String,
    store: REMStore,
    operation: String,
    details: [String: String]
  ) throws -> REMList {
    let group = try fetchList(
      listID: groupID,
      store: store,
      operation: operation,
      details: details
    )
    guard group.isGroup else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list group selector resolved to a normal list.",
        details: details
      )
    }
    return group
  }

  private static func childLists(
    store: REMStore,
    group: REMList,
    operation: String,
    details: [String: String]
  ) throws -> [REMList] {
    var fetchError: AnyObject?
    guard let dataView = REMListsDataView(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit lists data view could not be created.",
        details: details
      )
    }
    if let lists = dataView.fetchLists(inGroup: group, error: &fetchError) as? [REMList] {
      return lists
    }
    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit child lists could not be fetched for the group.",
      details: details.merging(
        ["fetch_error": reminderKitErrorSummary(fetchError)],
        uniquingKeysWith: { _, new in new }
      )
    )
  }

  private static func preferredAccount(
    store: REMStore,
    preferredList: REMList? = nil,
    fallbackList: REMList? = nil,
    operation: String,
    details: [String: String]
  ) throws -> REMAccount {
    if let account = preferredList?.account {
      return account
    }
    if let account = fallbackList?.account {
      return account
    }

    var fetchError: AnyObject?
    if let account = store.fetchPrimaryActiveCloudKitAccountWithError(&fetchError) as? REMAccount {
      return account
    }
    if let account = store.fetchDefaultAccountWithError(&fetchError) as? REMAccount {
      return account
    }
    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit account could not be resolved.",
      details: details.merging(
        ["fetch_error": reminderKitErrorSummary(fetchError)],
        uniquingKeysWith: { _, new in new }
      )
    )
  }

  private static func accountChangeItem(
    saveRequest: REMSaveRequest,
    account: REMAccount,
    operation: String,
    details: [String: String]
  ) throws -> REMAccountChangeItem {
    guard let accountChange = saveRequest.updateAccount(account) as? REMAccountChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit account change item could not be updated.",
        details: details
      )
    }
    return accountChange
  }

  private static func reminderKitStore(
    operation: String,
    details: [String: String]
  ) throws -> REMStore {
    guard let store = try reminderKitNewStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: details
      )
    }
    return store
  }

  private static func reminderKitSaveRequest(
    store: REMStore,
    operation: String,
    details: [String: String]
  ) throws -> REMSaveRequest {
    guard let saveRequest = try reminderKitNewSaveRequest(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: details
      )
    }
    return saveRequest
  }

  private static func save(
    _ saveRequest: REMSaveRequest,
    operation: String,
    details: [String: String]
  ) throws {
    var saveError: AnyObject?
    guard try reminderKitSaveSynchronously(saveRequest, error: &saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: details.merging(
          ["save_error": reminderKitErrorSummary(saveError)],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  private static func validateSameAccount(
    list: REMList,
    group: REMList,
    operation: String,
    details: [String: String]
  ) throws {
    guard let listAccount = objectIDBinding(list.accountID),
      let groupAccount = objectIDBinding(group.accountID)
    else {
      return
    }
    guard listAccount == groupAccount else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list and group belong to different accounts.",
        details: details.merging(
          [
            "list_account": listAccount,
            "group_account": groupAccount,
            "operation": operation,
          ],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  private static func objectIDBinding(_ objectID: REMObjectID?) -> String? {
    guard let objectID else {
      return nil
    }
    return objectID.uuid.uuidString
  }

  private static func remObjectID(entity: String, identifier: String) -> REMObjectID? {
    let urlString =
      identifier.hasPrefix("x-apple-reminderkit://")
      ? identifier
      : "x-apple-reminderkit://\(entity)/\(identifier)"
    guard let url = URL(string: urlString) else {
      return nil
    }
    return REMObjectID.objectID(withURL: url) as? REMObjectID
  }

  private static func listMatches(_ list: REMList, listID: String) -> Bool {
    let candidates = [
      list.objectID?.uuid.uuidString,
      list.remObjectID?.uuid.uuidString,
      list.objectID?.urlRepresentation.absoluteString,
      list.remObjectID?.urlRepresentation.absoluteString,
      list.externalIdentifier,
      list.daExternalIdentificationTag,
    ].compactMap { $0 }
    return candidates.contains { $0.localizedCaseInsensitiveCompare(listID) == .orderedSame }
  }

  private static func missingRequirements() -> [String] {
    let hasAddGroup =
      REMSaveRequest.instancesRespond(
        to: NSSelectorFromString("addGroupWithName:toAccountGroupContextChangeItem:")
      )
      || REMSaveRequest.instancesRespond(
        to: NSSelectorFromString("addGroupWithName:toAccountGroupContextChangeItem:groupObjectID:")
      )
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMAccount", NSClassFromString("REMAccount") != nil),
      ("REMAccountChangeItem", NSClassFromString("REMAccountChangeItem") != nil),
      (
        "REMAccountGroupContextChangeItem",
        NSClassFromString("REMAccountGroupContextChangeItem") != nil
      ),
      ("REMList", NSClassFromString("REMList") != nil),
      ("REMListChangeItem", NSClassFromString("REMListChangeItem") != nil),
      ("REMListsDataView", NSClassFromString("REMListsDataView") != nil),
      (
        "REMObjectID.objectIDWithURL:",
        REMObjectID.responds(to: NSSelectorFromString("objectIDWithURL:"))
      ),
      (
        "REMStore.fetchListWithObjectID:error:",
        REMStore.instancesRespond(to: #selector(REMStore.fetchList(withObjectID:error:)))
      ),
      (
        "REMListsDataView.fetchListsInGroup:error:",
        REMListsDataView.instancesRespond(to: NSSelectorFromString("fetchListsInGroup:error:"))
      ),
      (
        "REMAccount.fetchListsWithError:",
        REMAccount.instancesRespond(to: NSSelectorFromString("fetchListsWithError:"))
      ),
      (
        "REMStore.fetchPrimaryActiveCloudKitAccountWithError:",
        REMStore.instancesRespond(
          to: NSSelectorFromString("fetchPrimaryActiveCloudKitAccountWithError:"))
      ),
      (
        "REMStore.fetchDefaultAccountWithError:",
        REMStore.instancesRespond(to: NSSelectorFromString("fetchDefaultAccountWithError:"))
      ),
      (
        "REMSaveRequest.updateAccount:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateAccount(_:)))
      ),
      (
        "REMSaveRequest.updateList:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateList(_:)))
      ),
      ("REMSaveRequest.addGroupWithName:...", hasAddGroup),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMAccountChangeItem.groupContext",
        REMAccountChangeItem.instancesRespond(to: NSSelectorFromString("groupContext"))
      ),
      (
        "REMListChangeItem.setParentSubContainerID:",
        REMListChangeItem.instancesRespond(to: NSSelectorFromString("setParentSubContainerID:"))
      ),
      (
        "REMListChangeItem.setParentOwnerID:",
        REMListChangeItem.instancesRespond(to: NSSelectorFromString("setParentOwnerID:"))
      ),
      (
        "REMListChangeItem.removeFromParentWithAccountChangeItem:",
        REMListChangeItem.instancesRespond(
          to: NSSelectorFromString("removeFromParentWithAccountChangeItem:")
        )
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
