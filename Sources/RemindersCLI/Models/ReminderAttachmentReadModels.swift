import Foundation

enum ReminderAttachmentKind: String, Codable {
  case file, image, audio, link, unsupported
}

enum ReminderAttachmentStatus: String, Codable, Error {
  case available
  case unsupportedType = "unsupported_type"
  case missingLocalFile = "missing_local_file"
  case missingContentHash = "missing_content_hash"
  case unreadable
  case ambiguousLocalFile = "ambiguous_local_file"
  case integrityMismatch = "integrity_mismatch"
}

enum ReminderAttachmentIntegrity: String, Codable {
  case storedSHA512 = "stored_sha512"
  case nativeOriginal = "native_original"
}

struct ReminderAttachmentInspection: Codable {
  var id: UUID
  var fileName: String?
  var kind: ReminderAttachmentKind
  var typeIdentifier: String?
  var sizeBytes: Int64?
  var sha512: String?
  var localAvailable: Bool
  var status: ReminderAttachmentStatus
  var integrity: ReminderAttachmentIntegrity?
}

struct ReminderAttachmentsListResult: Codable {
  var reminderId: String
  var attachments: [ReminderAttachmentInspection]
}

struct ReminderAttachmentExportedFile: Codable {
  var attachmentId: UUID
  var fileName: String?
  var typeIdentifier: String?
  var path: String
  var sizeBytes: Int64
  var sha512: String
  var integrity: ReminderAttachmentIntegrity
}

struct ReminderAttachmentExportResult: Codable {
  var operation = "reminders.attachments.export"
  var reminderId: String
  var files: [ReminderAttachmentExportedFile]
  var skippedAttachmentIds: [UUID]
}

struct ReminderAttachmentSource {
  var id: UUID
  var kind: ReminderAttachmentKind
  var fileName: String?
  var typeIdentifier: String?
  var sizeBytes: Int64?
  var storedSHA512: String?
  var nativeURL: URL?
}

struct ReminderAttachmentInventory {
  var reminderId: String
  var reminderUUID: UUID
  var accountUUID: UUID
  var attachments: [ReminderAttachmentSource]
  var deletedAttachmentIDs: Set<UUID> = []
}

struct ReminderNativeAttachmentInventory {
  var inventory: ReminderAttachmentInventory
  var retainedObjects: [AnyObject] = []
}
