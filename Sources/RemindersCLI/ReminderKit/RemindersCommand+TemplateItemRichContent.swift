import AppKit
import Foundation
import ReminderKit
import UniformTypeIdentifiers
import Utility

extension RemindersCommand {
  public func addReminderTemplateItemAttachment(
    id: String,
    fileURL: URL
  ) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-attachments-add"
    let store = try coreReminderKitStore(operation: operation)
    let reminder = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem,
      let attachmentContext = change.attachmentContext
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template item attachment context was unavailable.",
        details: ["item_id": id]
      )
    }

    try coreAddTemplateItemAttachment(
      fileURL: fileURL,
      to: attachmentContext,
      operation: operation,
      itemID: id
    )
    try coreSaveReminderKit(saveRequest, operation: operation)
    return try coreReminderTemplateItemRecord(
      store: store,
      objectID: reminder.remObjectID,
      operation: operation
    )
  }

  public func removeReminderTemplateItemAttachment(
    id: String,
    attachment: ReminderAttachmentRecord,
    selector: String
  ) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-attachments-remove"
    let store = try coreReminderKitStore(operation: operation)
    let reminder = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem,
      let attachmentContext = change.attachmentContext
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template item attachment context was unavailable.",
        details: ["item_id": id]
      )
    }

    let matches = coreTemplateItemFileAttachments(in: attachmentContext).filter {
      coreTemplateItemFileAttachmentMatches($0, attachment: attachment, selector: selector)
    }
    guard let match = matches.first, matches.count == 1 else {
      throw coreReminderKitError(
        operation: operation,
        message: "Template item attachment selector did not match exactly one attachment.",
        details: [
          "item_id": id,
          "attachment_selector": selector,
          "match_count": "\(matches.count)",
        ]
      )
    }

    attachmentContext.removeAttachment(match)
    try coreSaveReminderKit(saveRequest, operation: operation)
    return try coreReminderTemplateItemRecord(
      store: store,
      objectID: reminder.remObjectID,
      operation: operation
    )
  }

  public func createReminderTemplateItemSubtask(
    parentID: String,
    title: String
  ) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-subtasks-create"
    let store = try coreReminderKitStore(operation: operation)
    let parent = try coreFetchTemplateSavedReminder(
      store: store,
      id: parentID,
      operation: operation
    )
    try coreValidateTemplateSubtaskParent(parent, operation: operation, parentID: parentID)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let parentChange = saveRequest.updateReminder(parent) as? REMReminderChangeItem,
      let subtaskContext = parentChange.subtaskContext,
      let childChange = saveRequest.addReminder(
        withTitle: title,
        toReminderSubtaskContextChangeItem: subtaskContext
      ) as? REMReminderChangeItem,
      let childObjectID = childChange.remObjectID
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template subtask change item could not be created.",
        details: ["parent_item_id": parentID, "title": title]
      )
    }

    try coreSaveReminderKit(saveRequest, operation: operation)
    return try coreReminderTemplateItemRecord(
      store: store,
      objectID: childObjectID,
      operation: operation
    )
  }

  public func moveReminderTemplateItemSubtask(
    id: String,
    parentID: String
  ) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-subtasks-move"
    guard id != parentID else {
      throw CLIError(
        code: .validationError,
        message: "Template item cannot be made a subtask of itself.",
        details: ["id": id]
      )
    }

    let store = try coreReminderKitStore(operation: operation)
    let child = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    let parent = try coreFetchTemplateSavedReminder(store: store, id: parentID, operation: operation)
    try coreValidateTemplateItemsShareTemplate(
      child,
      parent,
      operation: operation,
      details: ["item_id": id, "parent_item_id": parentID]
    )
    try coreValidateTemplateSubtaskParent(parent, operation: operation, parentID: parentID)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let childChange = saveRequest.updateReminder(child) as? REMReminderChangeItem,
      let parentChange = saveRequest.updateReminder(parent) as? REMReminderChangeItem,
      let subtaskContext = parentChange.subtaskContext
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template subtask context was unavailable.",
        details: ["item_id": id, "parent_item_id": parentID]
      )
    }

    subtaskContext.addReminderChangeItem(childChange)
    try coreSaveReminderKit(saveRequest, operation: operation)
    return try coreReminderTemplateItemRecord(
      store: store,
      objectID: child.remObjectID,
      operation: operation
    )
  }

  public func promoteReminderTemplateItemSubtask(id: String) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-subtasks-promote"
    let store = try coreReminderKitStore(operation: operation)
    let child = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    guard child.parentReminderID != nil else {
      throw CLIError(
        code: .validationError,
        message: "Template item is not a subtask.",
        details: ["id": id]
      )
    }

    let resolved = try coreFetchTemplate(store: store,
      selector: coreObjectIDString(child.listID), operation: operation)
    guard coreObjectIDsMatch(child.listID, resolved.template.remObjectID),
      coreObjectIDsMatch(child.accountID, resolved.account.remObjectID) else {
      throw coreReminderKitError(operation: operation,
        message: "ReminderKit template subtask membership could not be resolved.",
        details: ["item_id": id])
    }
    let representation = try coreTemplateListRepresentation(
      store: store, template: resolved.template, operation: operation)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    for selector in ["updateReminder:", "updateList:"] {
      try ReminderKitRuntimeMethod(owner: "REMSaveRequest", selector: selector,
        returnType: "@", argumentTypes: ["@"]
      ).require(operation: operation, receiver: saveRequest)
    }
    guard let childChange = saveRequest.updateReminder(child) as? REMReminderChangeItem,
      let listChange = saveRequest.updateList(representation) as? REMListChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template subtask change item could not be updated.",
        details: ["item_id": id]
      )
    }

    try ReminderKitRuntimeMethod(owner: "REMListChangeItem", selector: "addReminderChangeItem:",
      returnType: "v", argumentTypes: ["@"]
    ).require(operation: operation, receiver: listChange)
    listChange.addReminderChangeItem(childChange)
    try coreSaveReminderKit(saveRequest, operation: operation)
    let promoted = try coreReminderTemplateItemRecord(
      store: store,
      objectID: child.remObjectID,
      operation: operation
    )
    guard promoted.parentReminderId == nil,
      promoted.templateId == coreObjectIDString(resolved.template.remObjectID) else {
      throw coreReminderKitError(operation: operation,
        message: "ReminderKit template subtask promotion could not be verified.",
        details: ["item_id": id])
    }
    return promoted
  }
}

private func coreAddTemplateItemAttachment(
  fileURL: URL,
  to attachmentContext: REMReminderAttachmentContextChangeItem,
  operation: String,
  itemID: String
) throws {
  var addError: AnyObject?
  if let imageDimensions = try coreTemplateItemImageDimensionsIfImage(fileURL: fileURL) {
    guard
      attachmentContext.addImageAttachment(
        withURL: fileURL,
        width: imageDimensions.width,
        height: imageDimensions.height,
        error: &addError
      ) != nil
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template image attachment could not be created.",
        details: [
          "item_id": itemID,
          "file_path": fileURL.path,
          "attachment_error": reminderKitErrorSummary(addError),
        ]
      )
    }
    return
  }

  guard attachmentContext.addFileAttachment(withURL: fileURL, error: &addError) != nil else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template file attachment could not be created.",
      details: [
        "item_id": itemID,
        "file_path": fileURL.path,
        "attachment_error": reminderKitErrorSummary(addError),
      ]
    )
  }
}

private func coreTemplateItemImageDimensionsIfImage(fileURL: URL) throws -> (
  width: UInt64, height: UInt64
)? {
  let type =
    fileURL.pathExtension.isEmpty
    ? nil
    : UTType(filenameExtension: fileURL.pathExtension)
  guard type?.conforms(to: .image) == true else {
    return nil
  }
  guard let image = NSImage(contentsOf: fileURL) else {
    throw CLIError(
      code: .validationError,
      message: "Template image attachment file could not be read.",
      details: ["file_path": fileURL.path]
    )
  }
  guard !image.representations.contains(where: { $0 is NSPDFImageRep }) else {
    throw CLIError(
      code: .validationError,
      message: "Template image attachment path resolved to a PDF representation.",
      details: ["file_path": fileURL.path, "file_type": UTType.pdf.identifier]
    )
  }

  let width = UInt64(max(1, image.size.width.rounded(.toNearestOrAwayFromZero)))
  let height = UInt64(max(1, image.size.height.rounded(.toNearestOrAwayFromZero)))
  guard width > 0, height > 0 else {
    throw CLIError(
      code: .validationError,
      message: "Template image attachment dimensions were unavailable.",
      details: ["file_path": fileURL.path]
    )
  }
  return (width, height)
}

private func coreTemplateItemFileAttachments(
  in context: REMReminderAttachmentContextChangeItem
) -> [REMFileAttachment] {
  var result: [REMFileAttachment] = []
  func appendUnique(_ attachment: REMFileAttachment) {
    let key = coreTemplateItemFileAttachmentKey(attachment)
    guard !result.contains(where: { coreTemplateItemFileAttachmentKey($0) == key }) else {
      return
    }
    result.append(attachment)
  }

  if let files = context.attachments(of: REMFileAttachment.self) as? [REMFileAttachment] {
    files.forEach(appendUnique)
  }
  if let files = context.fileAttachments {
    files.compactMap { $0 as? REMFileAttachment }.forEach(appendUnique)
  }
  if let images = context.imageAttachments {
    images.compactMap { $0 as? REMFileAttachment }.forEach(appendUnique)
  }
  return result
}

private func coreTemplateItemFileAttachmentKey(_ attachment: REMFileAttachment) -> String {
  [
    attachment.fileURL?.standardizedFileURL.path ?? "",
    attachment.fileURL?.lastPathComponent ?? "",
    attachment.uti,
  ].joined(separator: "\u{1F}")
}

private func coreTemplateItemFileAttachmentMatches(
  _ file: REMFileAttachment,
  attachment: ReminderAttachmentRecord,
  selector: String
) -> Bool {
  let fileURL = file.fileURL
  let values = [
    fileURL?.lastPathComponent,
    fileURL?.path,
    fileURL?.absoluteString,
    file.uti,
  ].compactMap { $0 }

  if let fileName = attachment.fileName,
    values.contains(where: { $0.localizedCaseInsensitiveCompare(fileName) == .orderedSame })
  {
    return true
  }
  if let url = attachment.url, coreTemplateItemFileURLMatches(url, fileURL: fileURL) {
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
  return values.contains {
    $0.localizedCaseInsensitiveCompare(normalizedSelector) == .orderedSame
  }
}

private func coreTemplateItemFileURLMatches(_ value: String, fileURL: URL?) -> Bool {
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

private func coreValidateTemplateSubtaskParent(
  _ parent: REMReminder,
  operation: String,
  parentID: String
) throws {
  guard parent.parentReminderID == nil else {
    throw CLIError(
      code: .validationError,
      message: "Nested template subtasks are not supported.",
      details: ["operation": operation, "parent_item_id": parentID]
    )
  }
}

private func coreValidateTemplateItemsShareTemplate(
  _ lhs: REMReminder,
  _ rhs: REMReminder,
  operation: String,
  details: [String: String]
) throws {
  guard coreObjectIDString(lhs.listID) == coreObjectIDString(rhs.listID) else {
    throw CLIError(
      code: .validationError,
      message: "Template subtask items must belong to the same template.",
      details: ["operation": operation].merging(details, uniquingKeysWith: { _, new in new })
    )
  }
}
