import Foundation
import Utility

extension RemindersSQLiteReader {
  func attachmentRecord(_ object: RemindersPrivateObjectDebugRecord)
    -> ReminderAttachmentRecord?
  {
    attachmentRecord(uti: object.uti, url: object.url, fileName: object.fileName)
  }

  func assignmentRecord(_ object: RemindersPrivateObjectDebugRecord)
    -> ReminderAssignmentRecord?
  {
    assignmentRecord(
      personId: object.personId,
      contactLabel: object.contactLabel,
      assigneeIdentifier: object.assigneeIdentifier,
      assignedAtRaw: object.assignedAtRaw
    )
  }

  func assignmentRecord(
    personId: String?,
    contactLabel: String?,
    assigneeIdentifier: String?,
    assignedAtRaw: Double?
  ) -> ReminderAssignmentRecord? {
    let personId = emptyToNil(personId)
    let contactLabel = emptyToNil(contactLabel)
    let assigneeIdentifier = emptyToNil(assigneeIdentifier)
    guard
      personId != nil || contactLabel != nil || assigneeIdentifier != nil || assignedAtRaw != nil
    else {
      return nil
    }

    return ReminderAssignmentRecord(
      personId: personId,
      contactLabel: contactLabel,
      assigneeIdentifier: assigneeIdentifier,
      assignedAtRaw: assignedAtRaw
    )
  }

  func messagingContactHandles(
    hasEvidence: Bool,
    lengthBytes: Int?
  ) -> [ReminderMessagingContactRecord] {
    guard hasEvidence else {
      return []
    }
    return [ReminderMessagingContactRecord(lengthBytes: lengthBytes)]
  }

  func attachmentRecord(
    uti: String?,
    url: String?,
    fileName: String?
  ) -> ReminderAttachmentRecord? {
    let uti = emptyToNil(uti)
    let url = emptyToNil(url)
    let fileName = emptyToNil(fileName)
    guard uti != nil || url != nil || fileName != nil else {
      return nil
    }
    if uti == "public.url", url != nil, fileName == nil {
      return nil
    }

    return ReminderAttachmentRecord(
      kind: attachmentKind(uti: uti, fileName: fileName, url: url),
      typeIdentifier: uti,
      fileName: fileName,
      url: url
    )
  }

  func attachmentKind(uti: String?, fileName: String?, url: String?) -> String {
    if isImageAttachment(uti: uti, fileName: fileName) {
      return "image"
    }
    if url != nil {
      return "link"
    }
    if fileName != nil {
      return "file"
    }
    return "object"
  }

  func isImageAttachment(uti: String?, fileName: String?) -> Bool {
    let lowerUTI = uti?.lowercased() ?? ""
    if lowerUTI.contains("image") || lowerUTI == "public.jpeg" || lowerUTI == "public.png" {
      return true
    }
    let lowerFileName = fileName?.lowercased() ?? ""
    return [".jpg", ".jpeg", ".png", ".heic", ".gif", ".tiff", ".webp"].contains { suffix in
      lowerFileName.hasSuffix(suffix)
    }
  }
}
