import CryptoKit
import Foundation
import Utility

extension RemindersCommand {
  func reminderAttachmentAddIdentity(_ options: CLIOptions) throws
    -> ReminderAttachmentMutationIdentity
  {
    let reminder = try reminderMutationIdentity(options)
    let fileURL = try reminderAttachmentFileURL(options)
    let signature = try reminderAttachmentFileSignature(fileURL)
    let attachmentsHash = reminderAttachmentEvidenceHash(reminder.reminder.attachments)
    let bindingPayload = [
      reminder.scopeDigest,
      fileURL.path,
      fileURL.lastPathComponent,
      "\(signature.sizeBytes)",
      signature.sha256,
      attachmentsHash,
    ].joined(separator: "|")
    var summary = reminder.summaryFields
    summary["operation"] = "add"
    summary["file_path"] = fileURL.path
    summary["file_name"] = fileURL.lastPathComponent
    summary["file_size_bytes"] = "\(signature.sizeBytes)"
    summary["file_sha256"] = signature.sha256
    summary["attachment_count"] = "\(reminder.reminder.attachments.count)"
    summary["attachments_sha256"] = attachmentsHash

    return ReminderAttachmentMutationIdentity(
      reminder: reminder,
      filePath: fileURL.path,
      fileName: fileURL.lastPathComponent,
      fileSizeBytes: signature.sizeBytes,
      fileContentSHA256: signature.sha256,
      attachmentEvidenceSHA256: attachmentsHash,
      scopeDigest: "reminder-attachment-add:\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func reminderAttachmentRemoveIdentity(_ options: CLIOptions) throws
    -> ReminderAttachmentMutationIdentity
  {
    let reminder = try reminderMutationIdentity(options)
    let selector = try reminderRequiredTextOption("attachment", options: options)
    let attachment = try reminderAttachment(
      selector: selector,
      in: reminder.reminder.attachments
    )
    let attachmentsHash = reminderAttachmentEvidenceHash(reminder.reminder.attachments)
    let bindingPayload = [
      reminder.scopeDigest,
      selector,
      attachment.kind,
      attachment.typeIdentifier ?? "",
      attachment.fileName ?? "",
      attachment.url ?? "",
      attachmentsHash,
    ].joined(separator: "|")
    var summary = reminder.summaryFields
    summary["operation"] = "remove"
    summary["attachment_selector"] = selector
    summary["attachment_kind"] = attachment.kind
    summary["attachment_type_identifier"] = attachment.typeIdentifier ?? ""
    summary["attachment_file_name"] = attachment.fileName ?? ""
    summary["attachment_url"] = attachment.url ?? ""
    summary["attachment_count"] = "\(reminder.reminder.attachments.count)"
    summary["attachments_sha256"] = attachmentsHash

    return ReminderAttachmentMutationIdentity(
      reminder: reminder,
      attachment: attachment,
      attachmentSelector: selector,
      attachmentEvidenceSHA256: attachmentsHash,
      scopeDigest: "reminder-attachment-remove:\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func reminderAttachmentFileURL(_ options: CLIOptions) throws -> URL {
    let raw = try reminderRequiredTextOption("file", options: options)
    let expanded: String
    if raw == "~" {
      expanded = FileManager.default.homeDirectoryForCurrentUser.path
    } else if raw.hasPrefix("~/") {
      expanded =
        FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(String(raw.dropFirst(2)))
        .path
    } else {
      expanded = raw
    }

    let url = URL(fileURLWithPath: expanded)
      .standardizedFileURL
      .resolvingSymlinksInPath()
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
      throw CLIError(
        code: .notFound,
        message: "Attachment file was not found.",
        details: ["file": raw]
      )
    }
    guard !isDirectory.boolValue else {
      throw CLIError(
        code: .validationError,
        message: "`--file` must point to a regular file.",
        details: ["file": url.path]
      )
    }
    guard FileManager.default.isReadableFile(atPath: url.path) else {
      throw CLIError(
        code: .permissionDenied,
        message: "Attachment file is not readable.",
        details: ["file": url.path]
      )
    }
    return url
  }

  func reminderAttachmentFileSignature(_ fileURL: URL) throws
    -> (sizeBytes: Int64, sha256: String)
  {
    let handle = try FileHandle(forReadingFrom: fileURL)
    defer {
      try? handle.close()
    }

    var hasher = SHA256()
    var sizeBytes: Int64 = 0
    while true {
      let chunk = try handle.read(upToCount: 1024 * 1024) ?? Data()
      guard !chunk.isEmpty else {
        break
      }
      sizeBytes += Int64(chunk.count)
      hasher.update(data: chunk)
    }
    let digest = hasher.finalize()
    let hash = digest.map { String(format: "%02x", $0) }.joined()
    return (sizeBytes: sizeBytes, sha256: hash)
  }

  func reminderAttachment(
    selector: String,
    in attachments: [ReminderAttachmentRecord]
  ) throws -> ReminderAttachmentRecord {
    let normalized = selector.trimmingCharacters(in: .whitespacesAndNewlines)
    if normalized.hasPrefix("#"),
      let index = Int(normalized.dropFirst()),
      attachments.indices.contains(index - 1)
    {
      return attachments[index - 1]
    }

    let matches = attachments.filter {
      reminderAttachmentMatchesSelector($0, selector: normalized)
    }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments.",
        details: ["selector": normalized]
      )
    }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the reminder.",
        details: [
          "selector": normalized,
          "attachment_count": "\(attachments.count)",
        ]
      )
    }
    return match
  }

  func reminderAttachmentMatchesSelector(
    _ attachment: ReminderAttachmentRecord,
    selector: String
  ) -> Bool {
    guard !selector.isEmpty else {
      return false
    }
    return [attachment.fileName, attachment.url, attachment.typeIdentifier, attachment.kind]
      .compactMap { $0 }
      .contains { $0.localizedCaseInsensitiveCompare(selector) == .orderedSame }
  }

  func reminderAttachmentMatchesFile(
    _ attachment: ReminderAttachmentRecord,
    fileURL: URL
  ) -> Bool {
    if let fileName = attachment.fileName,
      fileName.localizedCaseInsensitiveCompare(fileURL.lastPathComponent) == .orderedSame
    {
      return true
    }
    guard let url = attachment.url else {
      return false
    }
    return url == fileURL.path || url == fileURL.absoluteString
  }

  func reminderAttachmentEvidenceHash(_ attachments: [ReminderAttachmentRecord]) -> String {
    let payload =
      attachments
      .sorted {
        reminderAttachmentScopeDigest($0) < reminderAttachmentScopeDigest($1)
      }
      .map(reminderAttachmentScopeDigest)
      .joined(separator: "\n")
    return sha256Hex("\(attachments.count)|\(payload)")
  }

  func reminderAttachmentScopeDigest(_ attachment: ReminderAttachmentRecord) -> String {
    [
      attachment.kind,
      attachment.typeIdentifier ?? "",
      attachment.fileName ?? "",
      attachment.url ?? "",
    ].joined(separator: "\u{1F}")
  }
}
