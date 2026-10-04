import Foundation
import ReminderKit
import Utility

struct ReminderSmartListSnapshot {
  var list: ReminderListRecord
  var filterData: Data?
}

func reminderSmartListStorage(_ list: REMSmartList, operation: String) throws -> REMSmartListStorage
{
  try ReminderKitRuntimeMethod(owner: "REMSmartList", selector: "storage", returnType: "@")
    .require(operation: operation, receiver: list)
  guard let storage = list.storage else {
    throw coreReminderKitError(operation: operation, message: "Smart List storage is unavailable.")
  }
  for (selector, returns) in [
    ("objectID", "@"), ("accountID", "@"), ("name", "@"),
    ("smartListType", "@"), ("filterData", "@"), ("pinnedDate", "@"),
    ("sortingStyle", "@"), ("showingLargeAttachments", "B"), ("color", "@"),
  ] {
    try ReminderKitRuntimeMethod(
      owner: "REMSmartListStorage", selector: selector, returnType: returns
    )
    .require(operation: operation, receiver: storage)
  }
  return storage
}

func reminderSmartListSnapshot(
  _ list: REMSmartList, store: REMStore,
  operation: String
) throws -> ReminderSmartListSnapshot {
  let storage = try reminderSmartListStorage(list, operation: operation)
  guard let id = storage.objectID, id.entityName == "REMCDSmartList", let uuid = id.uuid,
    let accountID = storage.accountID, accountID.entityName == "REMCDAccount",
    storage.smartListType == ReminderSmartListWriter.customSmartListType
  else {
    throw coreReminderKitError(operation: operation, message: "Smart List identity is unavailable.")
  }
  let sourceID = coreObjectIDString(accountID)
  let account = try coreResolveAccount(store: store, sourceID: sourceID, operation: operation)
  guard coreObjectIDsMatch(account.remObjectID, accountID) else {
    throw coreReminderKitError(
      operation: operation, message: "Smart List account could not be verified.")
  }
  if let color = storage.color {
    for selector in ["red", "green", "blue", "alpha"] {
      try ReminderKitRuntimeMethod(owner: "REMColor", selector: selector, returnType: "d")
        .require(operation: operation, receiver: color)
    }
  }
  return .init(
    list: .init(
      id: uuid.uuidString, title: storage.name ?? "",
      sourceId: sourceID, sourceTitle: account.displayName ?? account.name ?? "",
      allowsContentModifications: true, listType: "smart", smartListType: storage.smartListType,
      isPinned: storage.pinnedDate != nil, sortingStyle: storage.sortingStyle,
      showingLargeAttachments: storage.showingLargeAttachments,
      color: coreReminderColorHex(storage.color), hasColor: storage.color != nil),
    filterData: storage.filterData)
}

func reminderSmartListFiltersMatch(_ actual: Data?, expected: Data) -> Bool {
  guard let actual,
    let actualObject = try? JSONSerialization.jsonObject(with: actual) as? [String: Any],
    let expectedObject = try? JSONSerialization.jsonObject(with: expected) as? [String: Any],
    let actualCanonical = try? JSONSerialization.data(
      withJSONObject: actualObject, options: [.sortedKeys]),
    let expectedCanonical = try? JSONSerialization.data(
      withJSONObject: expectedObject, options: [.sortedKeys])
  else { return false }
  return actualCanonical == expectedCanonical
}

func reminderSmartListReadbackMatches(
  _ snapshot: ReminderSmartListSnapshot?, id: String,
  sourceID: String, expectedFilter: Data
) -> Bool {
  guard let snapshot, !sourceID.isEmpty, snapshot.list.sourceId == sourceID,
    snapshot.list.listType == "smart",
    snapshot.list.smartListType == ReminderSmartListWriter.customSmartListType,
    let actualID = try? coreREMObjectID(entity: "REMCDSmartList", identifier: snapshot.list.id),
    let expectedID = try? coreREMObjectID(entity: "REMCDSmartList", identifier: id),
    coreObjectIDsMatch(actualID, expectedID)
  else { return false }
  return reminderSmartListFiltersMatch(snapshot.filterData, expected: expectedFilter)
}

extension RemindersCommand {
  func fetchReminderSmartListSnapshots(store existingStore: REMStore? = nil) throws -> [ReminderSmartListSnapshot] {
    let operation = "smart-lists.read"
    let store = try existingStore ?? coreReminderKitStore(operation: operation)
    try ReminderKitRuntimeMethod(
      owner: "REMStore", selector: "fetchCustomSmartListsWithError:",
      returnType: "@", argumentTypes: ["^@"]
    ).require(operation: operation, receiver: store)
    var error: AnyObject?
    guard let lists = store.fetchCustomSmartListsWithError(&error) as? [REMSmartList], error == nil
    else {
      throw coreReminderKitError(
        operation: operation, message: "Smart Lists could not be read.",
        details: ["fetch_error": reminderKitErrorSummary(error)])
    }
    return try lists.map { try reminderSmartListSnapshot($0, store: store, operation: operation) }
  }

  func fetchReminderKitReadSelection(store: REMStore, lists: [REMList], selector: String?) throws
    -> (lists: [REMList], smartList: REMSmartList?) {
    guard let selector, !selector.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return (lists, nil)
    }
    if selector.hasPrefix("x-apple-reminderkit://") || UUID(uuidString: selector) != nil {
      if let id = try coreREMObjectID(entity: "REMCDList", identifier: selector) {
        let standard = lists.filter {
          coreObjectIDsMatch($0.remObjectID, id)
            || (!selector.hasPrefix("x-apple-reminderkit://") && coreReminderListMatches($0, selector: selector))
        }
        guard standard.count < 2 else {
          throw CLIError(code: .ambiguousIdentity, message: "Reminder list matched multiple lists.", details: ["list": selector])
        }
        if let list = standard.first { return ([list], nil) }
      }
      guard try coreREMObjectID(entity: "REMCDSmartList", identifier: selector) != nil else {
        throw CLIError(code: .notFound, message: "Reminder list was not found.", details: ["list": selector])
      }
      let resolved = try ReminderSmartListWriter.fetchSmartList(listID: selector,
        operation: "list-reminders", store: store)
      return ([], resolved.smartList)
    }
    let standard = lists.filter { coreReminderListMatches($0, selector: selector) }
    let smart = try fetchReminderSmartListSnapshots(store: store).filter {
      $0.list.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    guard standard.count + smart.count > 0 else {
      throw CLIError(code: .notFound, message: "Reminder list was not found.", details: ["list": selector])
    }
    guard standard.count + smart.count == 1 else {
      throw CLIError(code: .ambiguousIdentity, message: "Reminder list matched multiple lists.", details: ["list": selector])
    }
    guard let snapshot = smart.first else { return (standard, nil) }
    return ([], try ReminderSmartListWriter.fetchSmartList(listID: snapshot.list.id,
      operation: "list-reminders", store: store).smartList)
  }

  func readReminderSmartListSnapshot(id: String) throws -> ReminderSmartListSnapshot? {
    do {
      let resolved = try ReminderSmartListWriter.fetchSmartList(
        listID: id, operation: "smart-list.read")
      return try reminderSmartListSnapshot(
        resolved.smartList, store: resolved.store, operation: "smart-list.read")
    } catch let error as CLIError where error.code == .notFound { return nil }
  }
}
