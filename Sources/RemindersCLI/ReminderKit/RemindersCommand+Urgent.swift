import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderUrgentWriter {
  static let capability = "urgent_reminders"

  static func preflight(reminderID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard let reminderID else {
      return
    }
    _ = try fetchReminder(reminderID: reminderID, operation: "preflight")
  }

  static func setUrgent(reminderID: String, urgent: Bool) throws {
    try preflight(reminderID: nil)
    let resolved = try fetchReminder(reminderID: reminderID, operation: "set")
    guard let saveRequest = REMSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "set",
        message: "ReminderKit save request could not be created.",
        details: ["reminder_id": reminderID]
      )
    }

    guard let changeItem = saveRequest.updateReminder(resolved.reminder) as? REMReminderChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "set",
        message: "ReminderKit reminder change item could not be updated.",
        details: ["reminder_id": reminderID]
      )
    }

    try setUrgentState(urgent, on: changeItem, reminderID: reminderID)

    var saveError: AnyObject?
    guard saveRequest.saveSynchronouslyWithError(&saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "set",
        message: "ReminderKit save failed.",
        details: [
          "reminder_id": reminderID,
          "urgent": "\(urgent)",
          "save_error": saveError.map(String.init(describing:)) ?? "",
        ]
      )
    }
  }

  private static func fetchReminder(
    reminderID: String,
    operation: String
  ) throws -> (store: REMStore, reminder: Any) {
    guard let store = REMStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["reminder_id": reminderID]
      )
    }

    var fetchError: AnyObject?
    let externalReminder = store.fetchReminder(
      withDACalendarItemUniqueIdentifier: reminderID,
      inList: nil,
      error: &fetchError
    )
    if let externalReminder {
      return (store, externalReminder)
    }

    if let objectID = remObjectID(entity: "REMCDReminder", identifier: reminderID),
      let reminder = store.fetchReminder(
        withObjectID: objectID, fetchOptions: nil, error: &fetchError)
    {
      return (store, reminder)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the reminder by external or ReminderKit identifier.",
      details: [
        "reminder_id": reminderID,
        "fetch_error": fetchError.map(String.init(describing:)) ?? "",
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

  private static func setUrgentState(
    _ urgent: Bool,
    on changeItem: REMReminderChangeItem,
    reminderID: String
  ) throws {
    let selector = NSSelectorFromString("setIsUrgentStateEnabledForCurrentUser:")
    if let urgentContext = changeItem.urgentAlarmContext {
      guard urgentContext.responds(to: selector) else {
        throw reminderKitMethodUnavailable(
          capability: capability,
          missing: [
            "REMReminderUrgentAlarmContextChangeItem.setIsUrgentStateEnabledForCurrentUser:"
          ],
          details: [
            "operation": "set",
            "reminder_id": reminderID,
            "urgent": "\(urgent)",
          ]
        )
      }
      urgentContext.isUrgentStateEnabledForCurrentUser = urgent
      return
    }

    guard changeItem.responds(to: selector) else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: ["REMReminderChangeItem.setIsUrgentStateEnabledForCurrentUser:"],
        details: [
          "operation": "set",
          "reminder_id": reminderID,
          "urgent": "\(urgent)",
        ]
      )
    }
    changeItem.isUrgentStateEnabledForCurrentUser = urgent
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      (
        "REMReminderUrgentAlarmContextChangeItem",
        NSClassFromString("REMReminderUrgentAlarmContextChangeItem") != nil
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
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMReminderChangeItem.urgentAlarmContext",
        REMReminderChangeItem.instancesRespond(to: NSSelectorFromString("urgentAlarmContext"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
