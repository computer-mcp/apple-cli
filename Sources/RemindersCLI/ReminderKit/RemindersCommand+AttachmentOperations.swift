import Foundation
import Utility

extension RemindersCommand {
  public func addReminderAttachment(reminder: ReminderDetail, fileURL: URL) throws
    -> ReminderDetail
  {
    try self.preflightAttachmentMutation(reminderID: reminder.id)
    try self.addAttachment(reminderID: reminder.id, fileURL: fileURL)
    return try verifyAttachmentPresent(reminder: reminder, fileURL: fileURL)
  }

  public func removeReminderAttachment(
    reminder: ReminderDetail,
    attachment: ReminderAttachmentRecord,
    selector: String
  ) throws -> ReminderDetail {
    try self.preflightAttachmentMutation(reminderID: reminder.id)
    try self.removeAttachment(
      reminderID: reminder.id,
      attachment: attachment,
      attachmentSelector: selector
    )
    return try verifyAttachmentAbsent(
      reminder: reminder,
      attachment: attachment,
      selector: selector
    )
  }

  func verifyAttachmentPresent(
    reminder: ReminderDetail,
    fileURL: URL
  ) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastReminder: ReminderDetail?
    var lastError: Error?

    repeat {
      do {
        let current = try enrichedReminderAfterAttachmentMutation(reminder)
        lastReminder = current
        if current.attachments.contains(where: { attachmentMatchesFile($0, fileURL: fileURL) }) {
          return current
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "file_path": fileURL.path,
      "file_name": fileURL.lastPathComponent,
      "actual_attachments": lastReminder.map { attachmentEvidenceSummary($0.attachments) } ?? "",
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app attachment add could not be verified.",
      details: details
    )
  }

  func verifyAttachmentAbsent(
    reminder: ReminderDetail,
    attachment: ReminderAttachmentRecord,
    selector: String
  ) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastReminder: ReminderDetail?
    var lastError: Error?

    repeat {
      do {
        let current = try enrichedReminderAfterAttachmentMutation(reminder)
        lastReminder = current
        let stillPresent = current.attachments.contains {
          $0 == attachment || attachmentMatchesSelector($0, selector: selector)
        }
        if !stillPresent {
          return current
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "attachment_selector": selector,
      "expected_file_name": attachment.fileName ?? "",
      "expected_url": attachment.url ?? "",
      "actual_attachments": lastReminder.map { attachmentEvidenceSummary($0.attachments) } ?? "",
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app attachment removal could not be verified.",
      details: details
    )
  }

  func enrichedReminderAfterAttachmentMutation(_ reminder: ReminderDetail) throws
    -> ReminderDetail
  {
    if let current = try readReminderKitReminder(id: reminder.id) {
      do {
        return try sqliteReader.enrichReminder(current)
      } catch {
        return current
      }
    }
    do {
      return try sqliteReader.enrichReminder(reminder)
    } catch {
      return reminder
    }
  }

  func attachmentMatchesFile(
    _ attachment: ReminderAttachmentRecord,
    fileURL: URL
  ) -> Bool {
    if let fileName = attachment.fileName,
      fileName.localizedCaseInsensitiveCompare(fileURL.lastPathComponent) == .orderedSame
    {
      return true
    }
    let path = fileURL.path
    let absoluteString = fileURL.absoluteString
    if let url = attachment.url {
      return url == path || url == absoluteString
        || URL(fileURLWithPath: url).standardizedFileURL.path == fileURL.standardizedFileURL.path
    }
    return false
  }

  func attachmentMatchesSelector(
    _ attachment: ReminderAttachmentRecord,
    selector: String
  ) -> Bool {
    let normalized = selector.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else {
      return false
    }
    return [attachment.fileName, attachment.url, attachment.typeIdentifier, attachment.kind]
      .compactMap { $0 }
      .contains { $0.localizedCaseInsensitiveCompare(normalized) == .orderedSame }
  }

  func attachmentEvidenceSummary(_ attachments: [ReminderAttachmentRecord]) -> String {
    attachments
      .map { attachment in
        [
          attachment.kind,
          attachment.typeIdentifier ?? "",
          attachment.fileName ?? "",
          attachment.url ?? "",
        ].filter { !$0.isEmpty }.joined(separator: ":")
      }
      .joined(separator: ",")
  }
}
