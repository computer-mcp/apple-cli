import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderAssignmentWriter {
  static let capability = "shared_assignment"

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

  static func assign(reminderID: String, target: ReminderAssignmentTargetRecord) throws {
    try preflight(reminderID: nil)
    let (saveRequest, changeItem) = try changeItem(reminderID: reminderID, operation: "assign")
    guard let assignmentContext = changeItem.assignmentContext else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "assign",
        message: "ReminderKit reminder change item does not support assignment.",
        details: ["reminder_id": reminderID]
      )
    }
    guard
      let assigneeObjectID = remObjectID(
        entity: "REMCDSharee", identifier: target.assigneeIdentifier)
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "assign",
        message: "ReminderKit assignee object ID could not be built.",
        details: ["reminder_id": reminderID, "assignee_identifier": target.assigneeIdentifier]
      )
    }
    guard
      let originatorObjectID = remObjectID(
        entity: "REMCDSharee",
        identifier: target.originatorIdentifier
      )
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "assign",
        message: "ReminderKit originator object ID could not be built.",
        details: ["reminder_id": reminderID, "originator_identifier": target.originatorIdentifier]
      )
    }

    assignmentContext.removeAllAssignments()
    guard
      assignmentContext.addAssignment(
        withAssigneeID: assigneeObjectID,
        originatorID: originatorObjectID,
        status: 1
      ) != nil
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "assign",
        message: "ReminderKit assignment could not be created.",
        details: [
          "reminder_id": reminderID,
          "assignee_identifier": target.assigneeIdentifier,
          "originator_identifier": target.originatorIdentifier,
        ]
      )
    }

    try save(saveRequest, reminderID: reminderID, operation: "assign")
  }

  static func unassign(
    reminderID: String,
    assignment: ReminderAssignmentRecord,
    assignmentSelector: String?
  ) throws {
    try preflight(reminderID: nil)
    let (saveRequest, changeItem) = try changeItem(reminderID: reminderID, operation: "unassign")
    guard let assignmentContext = changeItem.assignmentContext else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "unassign",
        message: "ReminderKit reminder change item does not support assignment.",
        details: ["reminder_id": reminderID]
      )
    }

    if let expectedAssignee = assignment.assigneeIdentifier {
      let matches = currentAssignments(in: assignmentContext).filter {
        identifiersEqual($0.assigneeID?.uuid.uuidString, expectedAssignee)
      }
      guard matches.count == 1, let match = matches.first else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "unassign",
          message: "ReminderKit assignment target could not be matched exactly.",
          details: [
            "reminder_id": reminderID,
            "assignment_selector": assignmentSelector ?? "",
            "expected_assignee_identifier": expectedAssignee,
            "match_count": "\(matches.count)",
            "actual_assignee_identifiers": currentAssignments(in: assignmentContext)
              .compactMap { $0.assigneeID?.uuid.uuidString }
              .joined(separator: ","),
          ]
        )
      }
      assignmentContext.removeAssignment(match)
    } else if assignmentSelector == nil {
      assignmentContext.removeAllAssignments()
    } else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "unassign",
        message: "ReminderKit assignment target lacks assignee identity.",
        details: ["reminder_id": reminderID, "assignment_selector": assignmentSelector ?? ""]
      )
    }

    try save(saveRequest, reminderID: reminderID, operation: "unassign")
  }

  private static func changeItem(
    reminderID: String,
    operation: String
  ) throws -> (REMSaveRequest, REMReminderChangeItem) {
    let resolved = try fetchReminder(reminderID: reminderID, operation: operation)
    guard let saveRequest = REMSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: ["reminder_id": reminderID]
      )
    }
    guard let changeItem = saveRequest.updateReminder(resolved.reminder) as? REMReminderChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit reminder change item could not be updated.",
        details: ["reminder_id": reminderID]
      )
    }
    return (saveRequest, changeItem)
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

  private static func currentAssignments(
    in context: REMReminderAssignmentContextChangeItem
  ) -> [REMAssignment] {
    Array(context.assignments).compactMap { $0 as? REMAssignment }
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

  private static func identifiersEqual(_ lhs: String?, _ rhs: String) -> Bool {
    guard let lhs else {
      return false
    }
    return normalizedIdentifier(lhs) == normalizedIdentifier(rhs)
  }

  private static func normalizedIdentifier(_ value: String) -> String {
    value.replacingOccurrences(of: "-", with: "").lowercased()
  }

  private static func save(
    _ saveRequest: REMSaveRequest,
    reminderID: String,
    operation: String
  ) throws {
    var saveError: AnyObject?
    guard saveRequest.saveSynchronouslyWithError(&saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: [
          "reminder_id": reminderID,
          "save_error": saveError.map(String.init(describing:)) ?? "",
        ]
      )
    }
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      (
        "REMReminderAssignmentContextChangeItem",
        NSClassFromString("REMReminderAssignmentContextChangeItem") != nil
      ),
      ("REMAssignment", NSClassFromString("REMAssignment") != nil),
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
        "REMReminderChangeItem.assignmentContext",
        REMReminderChangeItem.instancesRespond(to: NSSelectorFromString("assignmentContext"))
      ),
      (
        "REMReminderAssignmentContextChangeItem.addAssignmentWithAssigneeID:originatorID:status:",
        REMReminderAssignmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("addAssignmentWithAssigneeID:originatorID:status:")
        )
      ),
      (
        "REMReminderAssignmentContextChangeItem.removeAllAssignments",
        REMReminderAssignmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("removeAllAssignments")
        )
      ),
      (
        "REMReminderAssignmentContextChangeItem.removeAssignment:",
        REMReminderAssignmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("removeAssignment:")
        )
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
