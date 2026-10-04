import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderAttachmentWriter {
  static let capability = "attachments"

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

  static func addAttachment(reminderID: String, fileURL: URL) throws {
    try preflight(reminderID: nil)
    let resolved = try fetchReminder(reminderID: reminderID, operation: "add")
    let store = resolved.store
    let reminder = resolved.reminder
    let mutation = try editableAttachmentContext(
      store: store,
      reminder: reminder,
      reminderID: reminderID,
      operation: "add"
    )

    var addError: AnyObject?
    if let imageDimensions = try imageDimensionsIfImage(fileURL: fileURL) {
      guard
        mutation.attachmentContext.addImageAttachment(
          withURL: fileURL,
          width: imageDimensions.width,
          height: imageDimensions.height,
          error: &addError
        )
          != nil
      else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "add",
          message: "ReminderKit image attachment could not be created.",
          details: [
            "reminder_id": reminderID,
            "file_path": fileURL.path,
            "attachment_error": reminderKitErrorSummary(addError),
          ]
        )
      }
    } else {
      guard mutation.attachmentContext.addFileAttachment(withURL: fileURL, error: &addError) != nil
      else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "add",
          message: "ReminderKit file attachment could not be created.",
          details: [
            "reminder_id": reminderID,
            "file_path": fileURL.path,
            "attachment_error": reminderKitErrorSummary(addError),
          ]
        )
      }
    }

    try save(saveRequest: mutation.saveRequest, operation: "add", reminderID: reminderID)
  }

  static func removeAttachment(
    reminderID: String,
    attachment: ReminderAttachmentRecord,
    attachmentSelector: String
  ) throws {
    try preflight(reminderID: nil)
    let resolved = try fetchReminder(reminderID: reminderID, operation: "remove")
    let store = resolved.store
    let reminder = resolved.reminder
    let mutation = try editableAttachmentContext(
      store: store,
      reminder: reminder,
      reminderID: reminderID,
      operation: "remove"
    )
    let matches = uniquedVisibleFileAttachments(
      fileAttachments(in: mutation.attachmentContext).filter {
        fileAttachmentMatches($0, attachment: attachment, selector: attachmentSelector)
      })

    guard let match = matches.first else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "remove",
        message: "ReminderKit attachment matching the dry-run result evidence was not found.",
        details: [
          "reminder_id": reminderID,
          "attachment_selector": attachmentSelector,
          "expected_file_name": attachment.fileName ?? "",
          "expected_url": attachment.url ?? "",
          "expected_type_identifier": attachment.typeIdentifier ?? "",
          "match_count": "\(matches.count)",
        ]
      )
    }

    // The dry-run path resolves the user-visible attachment uniquely. ReminderKit
    // can expose duplicate REMFileAttachment wrappers for that same visible
    // record through raw and image attachment accessors, so remove one wrapper.
    mutation.attachmentContext.removeAttachment(match)
    try save(saveRequest: mutation.saveRequest, operation: "remove", reminderID: reminderID)
  }

  private static func imageDimensionsIfImage(fileURL: URL) throws -> (
    width: UInt64, height: UInt64
  )? {
    let type =
      fileURL.pathExtension.isEmpty
      ? nil
      : UTType(filenameExtension: fileURL.pathExtension)
    if let type, !type.conforms(to: .image) {
      return nil
    }
    guard type?.conforms(to: .image) == true else {
      return nil
    }

    guard let image = NSImage(contentsOf: fileURL) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "add",
        message: "ReminderKit image attachment file could not be read.",
        details: ["file_path": fileURL.path]
      )
    }
    guard !image.representations.contains(where: { $0 is NSPDFImageRep }) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "add",
        message: "ReminderKit image attachment path resolved to a PDF representation.",
        details: [
          "file_path": fileURL.path,
          "file_type": UTType.pdf.identifier,
        ]
      )
    }

    let width = UInt64(max(1, image.size.width.rounded(.toNearestOrAwayFromZero)))
    let height = UInt64(max(1, image.size.height.rounded(.toNearestOrAwayFromZero)))
    guard width > 0, height > 0 else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "add",
        message: "ReminderKit image attachment dimensions were unavailable.",
        details: ["file_path": fileURL.path]
      )
    }
    return (width, height)
  }

  private static func editableAttachmentContext(
    store: REMStore,
    reminder: Any,
    reminderID: String,
    operation: String
  ) throws -> (
    saveRequest: REMSaveRequest, attachmentContext: REMReminderAttachmentContextChangeItem
  ) {
    guard let saveRequest = try reminderKitNewSaveRequest(store: store) else {
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
    return (saveRequest, attachmentContext)
  }

  private static func fetchReminder(
    reminderID: String,
    operation: String
  ) throws -> (store: REMStore, reminder: Any) {
    guard let store = try reminderKitNewStore() else {
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

  private static func save(
    saveRequest: REMSaveRequest,
    operation: String,
    reminderID: String
  ) throws {
    var saveError: AnyObject?
    guard try reminderKitSaveSynchronously(saveRequest, error: &saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: [
          "reminder_id": reminderID,
          "save_error": reminderKitErrorSummary(saveError),
        ]
      )
    }
  }

  private static func fileAttachments(
    in context: REMReminderAttachmentContextChangeItem
  ) -> [REMFileAttachment] {
    var result: [REMFileAttachment] = []
    func appendUnique(_ attachment: REMFileAttachment) {
      let key = fileAttachmentStableKey(attachment)
      guard !result.contains(where: { fileAttachmentStableKey($0) == key }) else {
        return
      }
      result.append(attachment)
    }

    if let attachments = context.attachments(of: REMFileAttachment.self) as? [REMFileAttachment] {
      attachments.forEach(appendUnique)
    }
    if let rawAttachments = context.fileAttachments {
      for attachment in rawAttachments.compactMap({ $0 as? REMFileAttachment }) {
        appendUnique(attachment)
      }
    }
    if let imageAttachments = context.imageAttachments {
      for attachment in imageAttachments.compactMap({ $0 as? REMFileAttachment }) {
        appendUnique(attachment)
      }
    }
    return result
  }

  private static func fileAttachmentStableKey(_ attachment: REMFileAttachment) -> String {
    [
      attachment.fileURL?.standardizedFileURL.path ?? "",
      attachment.fileURL?.lastPathComponent ?? "",
      attachment.uti,
    ].joined(separator: "\u{1F}")
  }

  private static func uniquedVisibleFileAttachments(
    _ attachments: [REMFileAttachment]
  ) -> [REMFileAttachment] {
    var result: [REMFileAttachment] = []
    for attachment in attachments {
      let key = fileAttachmentVisibleKey(attachment)
      guard !result.contains(where: { fileAttachmentVisibleKey($0) == key }) else {
        continue
      }
      result.append(attachment)
    }
    return result
  }

  private static func fileAttachmentVisibleKey(_ attachment: REMFileAttachment) -> String {
    [
      attachment.fileURL?.lastPathComponent ?? "",
      attachment.uti,
    ].joined(separator: "\u{1F}")
  }

  private static func fileAttachmentMatches(
    _ file: REMFileAttachment,
    attachment: ReminderAttachmentRecord,
    selector: String
  ) -> Bool {
    let fileURL = file.fileURL
    let fileValues = [
      fileURL?.lastPathComponent,
      fileURL?.path,
      fileURL?.absoluteString,
      file.uti,
    ].compactMap { $0 }

    if let fileName = attachment.fileName, containsCaseInsensitive(fileName, in: fileValues) {
      return true
    }
    if let url = attachment.url, urlMatches(url, fileURL: fileURL) {
      return true
    }
    if let typeIdentifier = attachment.typeIdentifier,
      file.uti.localizedCaseInsensitiveCompare(typeIdentifier) == .orderedSame
    {
      return true
    }

    let normalizedSelector = selector.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedSelector.isEmpty, !normalizedSelector.hasPrefix("#") else {
      return false
    }
    return containsCaseInsensitive(normalizedSelector, in: fileValues)
  }

  private static func containsCaseInsensitive(_ value: String, in candidates: [String]) -> Bool {
    candidates.contains { $0.localizedCaseInsensitiveCompare(value) == .orderedSame }
  }

  private static func urlMatches(_ value: String, fileURL: URL?) -> Bool {
    guard let fileURL else {
      return false
    }
    if value == fileURL.path || value == fileURL.absoluteString {
      return true
    }
    if value.hasPrefix("file://"), let parsed = URL(string: value) {
      return parsed.standardizedFileURL.path == fileURL.standardizedFileURL.path
    }
    return URL(fileURLWithPath: value).standardizedFileURL.path == fileURL.standardizedFileURL.path
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
      ("REMFileAttachment", NSClassFromString("REMFileAttachment") != nil),
      ("REMImageAttachment", NSClassFromString("REMImageAttachment") != nil),
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
        "REMReminderAttachmentContextChangeItem.addFileAttachmentWithURL:error:",
        REMReminderAttachmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("addFileAttachmentWithURL:error:"))
      ),
      (
        "REMReminderAttachmentContextChangeItem.addImageAttachmentWithURL:width:height:error:",
        REMReminderAttachmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("addImageAttachmentWithURL:width:height:error:"))
      ),
      (
        "REMReminderAttachmentContextChangeItem.removeAttachment:",
        REMReminderAttachmentContextChangeItem.instancesRespond(
          to: #selector(REMReminderAttachmentContextChangeItem.removeAttachment(_:)))
      ),
      (
        "REMReminderAttachmentContextChangeItem.attachmentsOfClass:",
        REMReminderAttachmentContextChangeItem.instancesRespond(
          to: NSSelectorFromString("attachmentsOfClass:"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
