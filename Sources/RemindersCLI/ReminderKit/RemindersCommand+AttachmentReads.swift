import Foundation
import ReminderKit
import Utility

func readNativeReminderAttachments(id: String) throws -> ReminderNativeAttachmentInventory? {
  let operation = "attachments.read"
  let store = try coreReminderKitStore(operation: operation)
  guard let reminder = try coreFetchReminder(store: store, id: id, operation: operation) else {
    return nil
  }
  guard let reminderUUID = reminder.remObjectID?.uuid,
    let accountUUID = reminder.account?.remObjectID?.uuid ?? reminder.accountID?.uuid
  else {
    throw CLIError(
      code: .backendUnavailable, message: "ReminderKit attachment owner is unavailable.")
  }

  try ReminderKitRuntimeMethod(owner: "REMReminder", selector: "attachmentContext", returnType: "@")
    .require(operation: operation, receiver: reminder)
  guard let context = reminder.attachmentContext else {
    throw CLIError(
      code: .backendUnavailable, message: "ReminderKit attachment context is unavailable.")
  }
  try ReminderKitRuntimeMethod(
    owner: "REMReminderAttachmentContext", selector: "attachments",
    returnType: "@"
  ).require(operation: operation, receiver: context)
  let objects = context.attachments ?? []
  var sources: [ReminderAttachmentSource] = []
  for object in objects {
    guard let attachment = object as? REMAttachment,
      let attachmentID = attachment.objectID?.uuid,
      attachment.reminderID?.uuid == reminderUUID, attachment.accountID?.uuid == accountUUID
    else {
      throw CLIError(
        code: .backendUnavailable, message: "ReminderKit attachment identity is inconsistent.")
    }
    var source = ReminderAttachmentSource(
      id: attachmentID, kind: .unsupported, typeIdentifier: attachment.uti)
    if let file = attachment as? REMFileAttachment {
      try ReminderKitRuntimeMethod(owner: "REMFileAttachment", selector: "fileURL", returnType: "@")
        .require(operation: operation, receiver: file)
      source.kind = .file
      if file is REMImageAttachment {
        source.kind = .image
      } else if let audioClass = NSClassFromString("REMAudioAttachment"),
        file.isKind(of: audioClass)
      {
        source.kind = .audio
      }
      source.sizeBytes = file.fileSize > 0 ? Int64(exactly: file.fileSize) : nil
      if let url = file.fileURL, url.isFileURL,
        url.host == nil || url.host == "" || url.host == "localhost"
      {
        source.nativeURL = url
        if !file.isTemporaryFileURL,
          attachmentSHA512(url.deletingPathExtension().lastPathComponent) == nil,
          attachmentSHA512(url.lastPathComponent) == nil
        {
          source.fileName = url.lastPathComponent
        }
      }
    } else if attachment is REMURLAttachment {
      source.kind = .link
    }
    sources.append(source)
  }
  return ReminderNativeAttachmentInventory(
    inventory: ReminderAttachmentInventory(
      reminderId: id, reminderUUID: reminderUUID, accountUUID: accountUUID,
      attachments: sources),
    retainedObjects: [store, reminder, context] + objects.compactMap { $0 as? REMAttachment })
}
