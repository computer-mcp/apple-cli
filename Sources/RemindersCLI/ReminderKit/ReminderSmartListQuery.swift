import Foundation
import ObjectiveC.runtime
import ReminderKit
import Utility

private struct ReminderSmartListQueryResult: Decodable {
  struct SmartList: Decodable { let objectIDUUID: UUID }
  struct Model: Decodable { let reminders: [Node] }
  struct Node: Decodable {
    struct ObjectID: Decodable { let uuid: UUID; let entityName: String }
    let objectID: ObjectID
    let subtasks: [Node]?
  }
  let smartList: SmartList
  let model: Model
}

func reminderSmartListQueryIDs(_ data: Data, smartListID: UUID) throws -> [UUID] {
  let operation = "smart-list.query"
  guard data.count <= 2 * 1024 * 1024 else {
    throw coreReminderKitError(operation: operation, message: "Smart List result exceeds 2 MiB.")
  }
  let result: ReminderSmartListQueryResult
  do { result = try PropertyListDecoder().decode(ReminderSmartListQueryResult.self, from: data) }
  catch {
    throw coreReminderKitError(operation: operation, message: "Smart List result could not be decoded.")
  }
  guard result.smartList.objectIDUUID == smartListID else {
    throw coreReminderKitError(operation: operation, message: "Smart List result identity does not match the request.")
  }
  var ids: [UUID] = [], seen: Set<UUID> = [], visited = 0
  func append(_ nodes: [ReminderSmartListQueryResult.Node], ancestors: Set<UUID>) throws {
    for node in nodes {
      visited += 1
      let id = node.objectID.uuid
      guard node.objectID.entityName == "REMCDReminder", !ancestors.contains(id),
        ancestors.count < 64, visited <= 100_000 else {
        throw coreReminderKitError(operation: operation, message: "Smart List reminder hierarchy is invalid or exceeds the read bound.")
      }
      // Native views can include a contextual child both below its parent and as a matching root.
      if seen.insert(id).inserted { ids.append(id) }
      if let children = node.subtasks { try append(children, ancestors: ancestors.union([id])) }
    }
  }
  try append(result.model.reminders, ancestors: [])
  return ids
}

private func reminderSmartListQueryInvocation(operation: String) throws -> NSObject {
  let owner = "REMRemindersListDataView_CustomSmartListInvocation"
  let allocation = ReminderKitRuntimeMethod(owner: owner, selector: "alloc", scope: .classMethod, returnType: "@")
  let initialization = ReminderKitRuntimeMethod(owner: owner,
    selector: "initWithFetchResultTokenToDiffAgainst:", returnType: "@", argumentTypes: ["@"])
  try allocation.require(operation: operation)
  try initialization.require(operation: operation)
  guard let runtimeClass = NSClassFromString(owner),
    let allocateMethod = class_getClassMethod(runtimeClass, NSSelectorFromString(allocation.selector)) else {
    throw coreReminderKitError(operation: operation, message: "Smart List query invocation is unavailable.")
  }
  typealias Allocate = @convention(c) (AnyClass, Selector) -> Unmanaged<NSObject>?
  let allocate = unsafeBitCast(method_getImplementation(allocateMethod), to: Allocate.self)
  guard let allocated = allocate(runtimeClass, NSSelectorFromString(allocation.selector)) else {
    throw coreReminderKitError(operation: operation, message: "Smart List query invocation could not be allocated.")
  }
  let initializeMethod: Method
  do {
    try initialization.require(operation: operation, receiver: allocated.takeUnretainedValue())
    guard let method = class_getInstanceMethod(object_getClass(allocated.takeUnretainedValue()),
      NSSelectorFromString(initialization.selector)) else {
      throw coreReminderKitError(operation: operation, message: "Smart List query initializer is unavailable.")
    }
    initializeMethod = method
  } catch { allocated.release(); throw error }
  // The initializer consumes the allocation and returns an owned object, including replacement self.
  typealias Initialize = @convention(c) (UnsafeMutableRawPointer, Selector, AnyObject?) -> Unmanaged<NSObject>?
  let initialize = unsafeBitCast(method_getImplementation(initializeMethod), to: Initialize.self)
  guard let initialized = initialize(allocated.toOpaque(), NSSelectorFromString(initialization.selector), nil) else {
    throw coreReminderKitError(operation: operation, message: "Smart List query invocation could not be initialized.")
  }
  let invocation = initialized.takeRetainedValue()
  guard invocation.isKind(of: runtimeClass) else {
    throw coreReminderKitError(operation: operation, message: "Smart List query initializer returned an unexpected object.")
  }
  return invocation
}

func reminderKitQuerySmartList(store: REMStore, list: REMSmartList,
  completion: ReminderCompletionFilter) throws -> [REMReminder] {
  let operation = "smart-list.query"
  let snapshot = try reminderSmartListSnapshot(list, store: store, operation: operation)
  let storage = try reminderSmartListStorage(list, operation: operation)
  guard let listID = storage.objectID, let uuid = listID.uuid, let accountID = storage.accountID else {
    throw coreReminderKitError(operation: operation, message: "Smart List query identity is unavailable.")
  }
  let account = try coreResolveAccount(store: store, sourceID: snapshot.list.sourceId, operation: operation)
  try ReminderKitRuntimeMethod(owner: "REMAccount", selector: "storage", returnType: "@")
    .require(operation: operation, receiver: account)
  guard let accountStorage = account.storage else {
    throw coreReminderKitError(operation: operation, message: "Smart List account storage is unavailable.")
  }
  try ReminderKitRuntimeMethod(owner: "REMAccountStorage", selector: "objectID", returnType: "@")
    .require(operation: operation, receiver: accountStorage)
  guard coreObjectIDsMatch(accountStorage.objectID, accountID) else {
    throw coreReminderKitError(operation: operation, message: "Smart List account storage identity could not be verified.")
  }
  var storages: [REMObjectID: Any] = [listID: storage, accountID: accountStorage]
  try ReminderKitRuntimeMethod(owner: "REMSmartListStorage", selector: "parentListID", returnType: "@")
    .require(operation: operation, receiver: storage)
  if let parentID = storage.parentListID {
    try ReminderKitRuntimeMethod(owner: "REMStore", selector: "fetchListWithObjectID:error:",
      returnType: "@", argumentTypes: ["@", "^@"])
      .require(operation: operation, receiver: store)
    var error: AnyObject?
    guard let parent = store.fetchList(withObjectID: parentID, error: &error) as? REMList,
      error == nil, coreObjectIDsMatch(parent.remObjectID, parentID) else {
      throw coreReminderKitError(operation: operation, message: "Smart List parent group could not be read.")
    }
    try ReminderKitRuntimeMethod(owner: "REMList", selector: "storage", returnType: "@")
      .require(operation: operation, receiver: parent)
    guard let parentStorage = parent.storage else {
      throw coreReminderKitError(operation: operation, message: "Smart List parent group storage is unavailable.")
    }
    try ReminderKitRuntimeMethod(owner: "REMListStorage", selector: "objectID", returnType: "@")
      .require(operation: operation, receiver: parentStorage)
    guard coreObjectIDsMatch(parentStorage.objectID, parentID) else {
      throw coreReminderKitError(operation: operation, message: "Smart List parent group storage identity could not be verified.")
    }
    storages[parentID] = parentStorage
  }
  let parameters: [String: Any] = [
    "smartList": ["objectIDUUID": uuid.uuidString], "sortingStyle": ["base": "default"],
    "showCompleted": ["base": completion == .incomplete ? "off" : "on"],
    "countCompleted": false, "remindersPrefetch": ["base": "none"], "fetchSubtasks": "on",
    "shouldFetchManualOrderingID": false,
  ]
  let data = try PropertyListSerialization.data(fromPropertyList: parameters, format: .binary, options: 0)
  let invocation = try reminderSmartListQueryInvocation(operation: operation)
  try ReminderKitRuntimeMethod(owner: "REMStore",
    selector: "resultFromPerformingSwiftInvocation:parametersData:storages:error:",
    returnType: "@", argumentTypes: ["@", "@", "@", "^@"])
    .require(operation: operation, receiver: store)
  var error: AnyObject?
  let raw = store.result(fromPerformingSwiftInvocation: invocation, parametersData: data,
    storages: storages, error: &error)
  guard error == nil, let result = raw as? NSObject,
    let resultClass = NSClassFromString("REMStoreSwiftInvocationResult"), result.isKind(of: resultClass) else {
    throw coreReminderKitError(operation: operation, message: "Smart List reminders could not be queried.",
      details: ["fetch_error": reminderKitErrorSummary(error)])
  }
  try ReminderKitRuntimeMethod(owner: "REMStoreSwiftInvocationResult", selector: "resultData", returnType: "@")
    .require(operation: operation, receiver: result)
  guard let resultData = result.perform(NSSelectorFromString("resultData"))?.takeUnretainedValue() as? Data else {
    throw coreReminderKitError(operation: operation, message: "Smart List query data is unavailable.")
  }
  return try reminderSmartListQueryIDs(resultData, smartListID: uuid).map { id in
    guard let reminder = try coreFetchReminder(store: store,
      id: "x-apple-reminderkit://REMCDReminder/\(id.uuidString)", operation: operation),
      reminder.remObjectID?.uuid == id, reminder.remObjectID?.entityName == "REMCDReminder" else {
      throw coreReminderKitError(operation: operation, message: "A Smart List reminder could not be read with its native identity.")
    }
    return reminder
  }
}
