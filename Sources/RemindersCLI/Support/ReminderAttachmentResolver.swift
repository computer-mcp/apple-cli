import Foundation
import Utility

struct ReminderAttachmentOriginal {
  let url: URL
  let signature: ReminderAttachmentSignature
  let integrity: ReminderAttachmentIntegrity
}

struct ReminderAttachmentResolution {
  let inspection: ReminderAttachmentInspection
  let original: ReminderAttachmentOriginal?
}

struct ReminderAttachmentResolver {
  let sqliteReader: RemindersSQLiteReader

  func inventory(
    for selector: ReminderAttachmentReminderSelector, native: ReminderAttachmentInventory?
  ) throws -> ReminderAttachmentInventory {
    let indexed: ReminderAttachmentInventory?
    do {
      indexed = try sqliteReader.attachmentInventory(for: selector)
    } catch ReminderAttachmentIndexError.unavailable {
      if let native, selector.explicitObjectID, native.reminderUUID == selector.objectUUID {
        return try merged(native, native: nil)
      }
      throw CLIError(
        code: .backendUnavailable,
        message:
          "The local Reminders attachment index is unavailable or uses an unsupported schema.",
        details: ["reason": "attachment_index_unavailable", "id": selector.value])
    }
    guard let indexed else {
      // A current ReminderKit object can be outside the on-disk index.
      if let native, selector.explicitObjectID, native.reminderUUID == selector.objectUUID {
        return try merged(native, native: nil)
      }
      throw CLIError(
        code: .notFound, message: "Reminder was not found in the local attachment index.",
        details: ["id": selector.value])
    }
    return try merged(indexed, native: native)
  }

  func resolve(_ source: ReminderAttachmentSource, account: UUID) -> ReminderAttachmentResolution {
    let digest = source.storedSHA512.flatMap(attachmentSHA512)
    do {
      let original = try original(for: source, account: account, digest: digest)
      return ReminderAttachmentResolution(
        inspection: inspection(
          source, digest: original.signature.sha512,
          size: original.signature.sizeBytes, status: .available, integrity: original.integrity),
        original: original)
    } catch {
      return ReminderAttachmentResolution(
        inspection: inspection(
          source, digest: digest, size: source.sizeBytes,
          status: error as? ReminderAttachmentStatus ?? .unreadable, integrity: nil),
        original: nil)
    }
  }

  private func merged(
    _ indexed: ReminderAttachmentInventory, native: ReminderAttachmentInventory?
  ) throws -> ReminderAttachmentInventory {
    var combined: [UUID: ReminderAttachmentSource] = [:]
    for attachment in indexed.attachments {
      guard combined.updateValue(attachment, forKey: attachment.id) == nil else {
        throw attachmentIndexConflict()
      }
    }
    if let native {
      guard indexed.reminderUUID == native.reminderUUID, indexed.accountUUID == native.accountUUID,
        Set(native.attachments.map(\.id)).count == native.attachments.count
      else { throw attachmentIndexConflict() }
      for attachment in native.attachments
      where !indexed.deletedAttachmentIDs.contains(attachment.id) {
        if var row = combined[attachment.id] {
          guard row.kind == attachment.kind,
            row.typeIdentifier != nil, row.typeIdentifier == attachment.typeIdentifier,
            row.sizeBytes == nil || attachment.sizeBytes == nil
              || row.sizeBytes == attachment.sizeBytes
          else { throw attachmentIndexConflict() }
          row.nativeURL = attachment.nativeURL
          row.fileName = row.fileName ?? attachment.fileName
          row.sizeBytes = row.sizeBytes ?? attachment.sizeBytes
          combined[row.id] = row
        } else {
          combined[attachment.id] = attachment
        }
      }
    }
    var result = indexed
    result.attachments = combined.values.sorted { $0.id.uuidString < $1.id.uuidString }
    return result
  }

  private func original(for source: ReminderAttachmentSource, account: UUID, digest: String?) throws
    -> ReminderAttachmentOriginal
  {
    guard [.file, .image, .audio].contains(source.kind) else {
      throw ReminderAttachmentStatus.unsupportedType
    }
    guard source.typeIdentifier?.isEmpty == false else {
      throw ReminderAttachmentStatus.integrityMismatch
    }
    if source.storedSHA512 != nil, digest == nil {
      throw ReminderAttachmentStatus.integrityMismatch
    }

    var nativeFailure: ReminderAttachmentStatus?
    if let url = source.nativeURL {
      do {
        return try verify(url, size: source.sizeBytes, digest: digest)
      } catch let error as ReminderAttachmentStatus {
        nativeFailure = error
      }
    }
    guard let digest else {
      throw nativeFailure ?? .missingContentHash
    }
    let files = sqliteReader.remindersStoresURL.deletingLastPathComponent()
      .appendingPathComponent("Files", isDirectory: true)
    do {
      let url = try ReminderAttachmentFiles.cacheOriginal(for: digest, account: account, in: files)
      return try verify(url, size: source.sizeBytes, digest: digest)
    } catch ReminderAttachmentStatus.missingLocalFile {
      throw nativeFailure ?? ReminderAttachmentStatus.missingLocalFile
    }
  }

  private func verify(_ url: URL, size: Int64?, digest: String?) throws
    -> ReminderAttachmentOriginal
  {
    let signature = try ReminderAttachmentFiles.signature(of: url)
    guard size == nil || size == signature.sizeBytes, digest == nil || digest == signature.sha512
    else { throw ReminderAttachmentStatus.integrityMismatch }
    return ReminderAttachmentOriginal(
      url: url, signature: signature, integrity: digest == nil ? .nativeOriginal : .storedSHA512)
  }

  private func inspection(
    _ source: ReminderAttachmentSource, digest: String?, size: Int64?,
    status: ReminderAttachmentStatus, integrity: ReminderAttachmentIntegrity?
  ) -> ReminderAttachmentInspection {
    ReminderAttachmentInspection(
      id: source.id, fileName: source.fileName, kind: source.kind,
      typeIdentifier: source.typeIdentifier,
      sizeBytes: size, sha512: digest, localAvailable: status == .available, status: status,
      integrity: integrity)
  }
}
