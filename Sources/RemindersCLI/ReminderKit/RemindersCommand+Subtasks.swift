import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderSubtaskWriter {
  static let capability = "subtasks"

  static func preflight(reminderID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
  }

  static func createSubtask(parentReminderID: String, title: String) throws -> ReminderDetail {
    try preflight(reminderID: nil)
    return try withRetriedStore(
      operation: "create",
      details: ["parent_reminder_id": parentReminderID, "title": title]
    ) { store in
      let parent = try fetchTypedReminder(
        reminderID: parentReminderID,
        store: store,
        operation: "create"
      )

      guard parent.parentReminderID == nil else {
        throw nestedSubtaskError(
          operation: "create",
          details: ["parent_reminder_id": parentReminderID]
        )
      }

      let mutation = try editableSubtaskContext(
        store: store,
        parent: parent,
        operation: "create",
        details: ["parent_reminder_id": parentReminderID, "title": title]
      )

      guard
        let childChange = mutation.saveRequest.addReminder(
          withTitle: title,
          toReminderSubtaskContextChangeItem: mutation.subtaskContext
        ) as? REMReminderChangeItem
      else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "create",
          message: "ReminderKit subtask change item could not be created.",
          details: ["parent_reminder_id": parentReminderID, "title": title]
        )
      }

      let childID = try reminderObjectIdentifier(
        childChange,
        operation: "create",
        details: ["parent_reminder_id": parentReminderID, "title": title]
      )
      try save(
        saveRequest: mutation.saveRequest,
        operation: "create",
        details: ["parent_reminder_id": parentReminderID, "child_reminder_id": childID]
      )

      return ReminderDetail(
        id: childID,
        listId: listIdentifier(parent),
        listTitle: listTitle(parent),
        title: title,
        isCompleted: false,
        priority: 0,
        parentReminderId: parentReminderID,
        parentReminderTitle: parent.titleAsString
      )
    }
  }

  static func moveSubtask(reminderID: String, toParentReminderID parentReminderID: String) throws {
    try preflight(reminderID: nil)
    guard reminderID != parentReminderID else {
      throw CLIError(
        code: .validationError,
        message: "Reminder cannot be made a subtask of itself.",
        details: ["id": reminderID]
      )
    }

    try withRetriedStore(
      operation: "move",
      details: ["reminder_id": reminderID, "parent_reminder_id": parentReminderID]
    ) { store in
      let child = try fetchTypedReminder(reminderID: reminderID, store: store, operation: "move")
      let parent = try fetchTypedReminder(
        reminderID: parentReminderID,
        store: store,
        operation: "move"
      )

      guard parent.parentReminderID == nil else {
        throw nestedSubtaskError(
          operation: "move",
          details: ["reminder_id": reminderID, "parent_reminder_id": parentReminderID]
        )
      }

      let saveRequest = try makeSaveRequest(
        store: store,
        operation: "move",
        details: ["reminder_id": reminderID, "parent_reminder_id": parentReminderID]
      )
      guard
        let childChange = saveRequest.updateReminder(child) as? REMReminderChangeItem,
        let parentChange = saveRequest.updateReminder(parent) as? REMReminderChangeItem,
        let parentSubtaskContext = parentChange.subtaskContext
      else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "move",
          message: "ReminderKit subtask change context was unavailable.",
          details: ["reminder_id": reminderID, "parent_reminder_id": parentReminderID]
        )
      }

      parentSubtaskContext.addReminderChangeItem(childChange)

      try save(
        saveRequest: saveRequest,
        operation: "move",
        details: ["reminder_id": reminderID, "parent_reminder_id": parentReminderID]
      )
    }
  }

  static func promoteSubtask(reminderID: String) throws {
    try preflight(reminderID: nil)
    try withRetriedStore(operation: "promote", details: ["reminder_id": reminderID]) { store in
      let child = try fetchTypedReminder(reminderID: reminderID, store: store, operation: "promote")

      guard child.parentReminderID != nil else {
        return
      }
      guard let list = child.list, objectIDsMatch(child.listID, list.remObjectID) else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "promote",
          message: "ReminderKit subtask list could not be resolved.",
          details: ["reminder_id": reminderID]
        )
      }

      let saveRequest = try makeSaveRequest(
        store: store,
        operation: "promote",
        details: ["reminder_id": reminderID]
      )
      try ReminderKitRuntimeMethod(
        owner: "REMSaveRequest", selector: "updateList:",
        returnType: "@", argumentTypes: ["@"]
      ).require(operation: "subtasks.promote", receiver: saveRequest)
      guard let childChange = saveRequest.updateReminder(child) as? REMReminderChangeItem,
        let listChange = saveRequest.updateList(list) as? REMListChangeItem
      else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "promote",
          message: "ReminderKit subtask and list change items could not be updated.",
          details: ["reminder_id": reminderID]
        )
      }
      try ReminderKitRuntimeMethod(
        owner: "REMListChangeItem", selector: "addReminderChangeItem:",
        returnType: "v", argumentTypes: ["@"]
      ).require(operation: "subtasks.promote", receiver: listChange)
      listChange.addReminderChangeItem(childChange)
      try save(saveRequest: saveRequest, operation: "promote", details: ["reminder_id": reminderID])
    }
  }

  private static func editableSubtaskContext(
    store: REMStore,
    parent: REMReminder,
    operation: String,
    details: [String: String]
  ) throws -> (
    saveRequest: REMSaveRequest,
    parentChange: REMReminderChangeItem,
    subtaskContext: REMReminderSubtaskContextChangeItem
  ) {
    let saveRequest = try makeSaveRequest(store: store, operation: operation, details: details)
    guard
      let parentChange = saveRequest.updateReminder(parent) as? REMReminderChangeItem,
      let subtaskContext = parentChange.subtaskContext
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit reminder subtask context was unavailable.",
        details: details
      )
    }
    return (saveRequest, parentChange, subtaskContext)
  }

  private static func makeStore(
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

  private static func withRetriedStore<T>(
    operation: String,
    details: [String: String],
    _ body: (REMStore) throws -> T
  ) throws -> T {
    var lastError: Error?
    for attempt in 1...3 {
      do {
        let store = try makeStore(operation: operation, details: details)
        return try body(store)
      } catch {
        lastError = error
        guard attempt < 3, isRetriableReminderDaemonInterruption(error) else {
          throw error
        }
        Thread.sleep(forTimeInterval: 0.3)
      }
    }
    throw lastError
      ?? reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit operation failed.",
        details: details
      )
  }

  private static func isRetriableReminderDaemonInterruption(_ error: Error) -> Bool {
    guard let cliError = error as? CLIError else {
      return String(describing: error).contains("com.apple.remindd")
    }
    let payload = ([cliError.message] + Array(cliError.details.values)).joined(separator: " ")
    return payload.contains("com.apple.remindd")
      || payload.contains("Code=4099")
      || payload.contains("proxy has become invalid")
  }

  private static func makeSaveRequest(
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

  private static func fetchTypedReminder(
    reminderID: String,
    store: REMStore,
    operation: String
  ) throws -> REMReminder {
    let reminder = try fetchReminder(reminderID: reminderID, store: store, operation: operation)
    guard let typedReminder = reminder as? REMReminder else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit returned an unexpected reminder object.",
        details: ["reminder_id": reminderID]
      )
    }
    return typedReminder
  }

  private static func fetchReminder(
    reminderID: String,
    store: REMStore,
    operation: String
  ) throws -> Any {
    var fetchError: AnyObject?
    let reminder = store.fetchReminder(
      withDACalendarItemUniqueIdentifier: reminderID,
      inList: nil,
      error: &fetchError
    )
    if let reminder {
      return reminder
    }

    if let objectID = remObjectID(entity: "REMCDReminder", identifier: reminderID),
      let reminder = store.fetchReminder(
        withObjectID: objectID, fetchOptions: nil, error: &fetchError)
    {
      return reminder
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the reminder by external or ReminderKit identifier.",
      details: [
        "reminder_id": reminderID,
        "fetch_error": reminderKitErrorSummary(fetchError),
      ]
    )
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

  private static func reminderObjectIdentifier(
    _ reminder: REMReminderChangeItem,
    operation: String,
    details: [String: String]
  ) throws -> String {
    if !reminder.daCalendarItemUniqueIdentifier.isEmpty {
      return reminder.daCalendarItemUniqueIdentifier
    }
    if let objectID = reminder.remObjectID {
      return objectID.uuid.uuidString
    }
    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit subtask object identifier was unavailable.",
      details: details
    )
  }

  private static func listIdentifier(_ reminder: REMReminder) -> String {
    if let listID = reminder.listID {
      return listID.uuid.uuidString
    }
    if let list = reminder.list, let objectID = list.remObjectID {
      return objectID.uuid.uuidString
    }
    return ""
  }

  private static func listTitle(_ reminder: REMReminder) -> String {
    reminder.list?.displayName ?? reminder.list?.name ?? ""
  }

  private static func objectIDsMatch(_ lhs: REMObjectID?, _ rhs: REMObjectID?) -> Bool {
    guard let lhs, let rhs else {
      return false
    }
    return lhs.uuid == rhs.uuid
  }

  private static func save(
    saveRequest: REMSaveRequest,
    operation: String,
    details additionalDetails: [String: String]
  ) throws {
    var saveError: AnyObject?
    guard try reminderKitSaveSynchronously(saveRequest, error: &saveError) else {
      var details = additionalDetails
      details["save_error"] = reminderKitErrorSummary(saveError)
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: details
      )
    }
  }

  private static func nestedSubtaskError(
    operation: String,
    details: [String: String]
  ) -> CLIError {
    CLIError(
      code: .validationError,
      message: "Nested subtasks are not supported by this ReminderKit action.",
      details: [
        "mechanism": "reminderkit",
        "capability": capability,
        "operation": operation,
      ].merging(details) { current, _ in current }
    )
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMReminder", NSClassFromString("REMReminder") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      ("REMListChangeItem", NSClassFromString("REMListChangeItem") != nil),
      (
        "REMReminderSubtaskContextChangeItem",
        NSClassFromString("REMReminderSubtaskContextChangeItem") != nil
      ),
      (
        "REMObjectID.objectIDWithURL:",
        REMObjectID.responds(to: NSSelectorFromString("objectIDWithURL:"))
      ),
      (
        "REMStore.fetchReminderWithDACalendarItemUniqueIdentifier:inList:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withDACalendarItemUniqueIdentifier:inList:error:))
        )
      ),
      (
        "REMStore.fetchReminderWithObjectID:fetchOptions:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withObjectID:fetchOptions:error:))
        )
      ),
      (
        "REMSaveRequest.updateReminder:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateReminder(_:)))
      ),
      (
        "REMSaveRequest.addReminderWithTitle:toReminderSubtaskContextChangeItem:",
        REMSaveRequest.instancesRespond(
          to: NSSelectorFromString("addReminderWithTitle:toReminderSubtaskContextChangeItem:")
        )
      ),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMReminderChangeItem.subtaskContext",
        REMReminderChangeItem.instancesRespond(to: NSSelectorFromString("subtaskContext"))
      ),
      (
        "REMSaveRequest.updateList:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateList(_:)))
      ),
      (
        "REMListChangeItem.addReminderChangeItem:",
        REMListChangeItem.instancesRespond(to: NSSelectorFromString("addReminderChangeItem:"))
      ),
      (
        "REMReminderSubtaskContextChangeItem.addReminderChangeItem:",
        REMReminderSubtaskContextChangeItem.instancesRespond(
          to: NSSelectorFromString("addReminderChangeItem:")
        )
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
