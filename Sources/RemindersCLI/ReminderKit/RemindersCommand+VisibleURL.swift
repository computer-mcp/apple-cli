import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderVisibleURLWriter {
  static let capability = "visible_url_link_card"

  static func preflight() throws {
    try preflight(reminderID: nil)
  }

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

  static func setVisibleURL(reminderID: String, url: String?) throws {
    try preflight()
    let operation = url == nil ? "clear" : "set"
    let resolved = try fetchReminder(reminderID: reminderID, operation: operation)
    let store = resolved.store
    let reminder = resolved.reminder

    guard let saveRequest = REMSaveRequest(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: ["reminder_id": reminderID]
      )
    }

    guard
      let changeItem = saveRequest.updateReminder(reminder) as? REMReminderChangeItem,
      let attachmentContext = changeItem.attachmentContext
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit reminder attachment context was unavailable.",
        details: ["reminder_id": reminderID]
      )
    }

    if let url {
      guard let parsedURL = URL(string: url), parsedURL.scheme != nil else {
        throw CLIError(
          code: .validationError,
          message: "`--url` must be an absolute URL.",
          details: ["url": url]
        )
      }
      _ = attachmentContext.setURLAttachmentWithURL(parsedURL)
    } else {
      attachmentContext.removeURLAttachments()
    }

    var saveError: AnyObject?
    guard saveRequest.saveSynchronouslyWithError(&saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: [
          "reminder_id": reminderID,
          "url": url ?? "",
          "save_error": reminderKitErrorSummary(saveError),
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
    let reminder = store.fetchReminder(
      withDACalendarItemUniqueIdentifier: reminderID,
      inList: nil,
      error: &fetchError
    )
    guard let reminder else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit could not fetch the reminder by ReminderKit-compatible identifier.",
        details: [
          "reminder_id": reminderID,
          "fetch_error": reminderKitErrorSummary(fetchError),
        ]
      )
    }
    return (store, reminder)
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      (
        "REMReminderAttachmentContextChangeItem",
        NSClassFromString("REMReminderAttachmentContextChangeItem") != nil
      ),
      (
        "REMStore.fetchReminderWithDACalendarItemUniqueIdentifier:inList:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withDACalendarItemUniqueIdentifier:inList:error:))
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
        "REMReminderAttachmentContextChangeItem.setURLAttachmentWithURL:",
        REMReminderAttachmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("setURLAttachmentWithURL:"))
      ),
      (
        "REMReminderAttachmentContextChangeItem.removeURLAttachments",
        REMReminderAttachmentContextChangeItem.instancesRespond(
          to: #selector(REMReminderAttachmentContextChangeItem.removeURLAttachments))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
