import Foundation
import Utility

extension RemindersCommand {
  public func renameReminderTag(
    tag: ReminderTagRecord,
    newName: String,
    reminderIDs: [String]
  ) throws -> ReminderTagRecord {
    try validateTagRenameTarget(tag: tag, newName: newName)
    let reminderIDs = try validateTagMutationReminderIDs(tag: tag, reminderIDs: reminderIDs)
    try self.preflightTagMutation()
    try self.renameTag(tagName: tag.name, newName: newName, reminderIDs: reminderIDs)
    return try verifyTagPresent(name: newName)
  }

  public func deleteReminderTag(tag: ReminderTagRecord, reminderIDs: [String]) throws -> Bool {
    try validateTagExists(tag)
    let reminderIDs = try validateTagMutationReminderIDs(tag: tag, reminderIDs: reminderIDs)
    try self.preflightTagMutation()
    try self.deleteTag(tagName: tag.name, reminderIDs: reminderIDs)
    try verifyTagAbsent(tag)
    return true
  }

  func validateTagExists(_ tag: ReminderTagRecord) throws {
    let tags = try sqliteReader.listTags()
    guard tags.contains(where: { tagRecordRepresents($0, tag) }) else {
      throw CLIError(
        code: .notFound,
        message: "Reminder tag was not found.",
        details: ["tag": tag.name]
      )
    }
  }

  func validateTagMutationReminderIDs(
    tag: ReminderTagRecord,
    reminderIDs: [String]
  ) throws -> [String] {
    let requestedIDs = normalizedReminderIDs(reminderIDs)
    guard !requestedIDs.isEmpty else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder tag mutation has no read-only reminder membership evidence.",
        details: [
          "verifier": "reminders_store_readonly",
          "tag": tag.name,
        ]
      )
    }

    let currentIDs = try normalizedReminderIDs(sqliteReader.reminderIDs(tagName: tag.name))
    guard Set(currentIDs) == Set(requestedIDs) else {
      throw CLIError(
        code: .validationError,
        message: "Reminder tag membership changed; rerun the dry-run before executing.",
        details: [
          "tag": tag.name,
          "requested_reminder_count": "\(requestedIDs.count)",
          "current_reminder_count": "\(currentIDs.count)",
          "requested_reminders_sha256": sha256Hex(requestedIDs.joined(separator: "\n")),
          "current_reminders_sha256": sha256Hex(currentIDs.joined(separator: "\n")),
        ]
      )
    }
    return requestedIDs
  }

  func normalizedReminderIDs(_ reminderIDs: [String]) -> [String] {
    Array(
      Set(
        reminderIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
          .filter { !$0.isEmpty })
    )
    .sorted()
  }

  func validateTagRenameTarget(tag: ReminderTagRecord, newName: String) throws {
    let tags = try sqliteReader.listTags()
    guard tags.contains(where: { tagRecordRepresents($0, tag) }) else {
      throw CLIError(
        code: .notFound,
        message: "Reminder tag was not found.",
        details: ["tag": tag.name]
      )
    }
    guard !tagRecordMatches(tag, selector: newName) else {
      throw CLIError(
        code: .validationError,
        message: "New reminder tag name must differ from the current name.",
        details: ["tag": tag.name]
      )
    }
    guard !tags.contains(where: { $0.id != tag.id && tagRecordMatches($0, selector: newName) })
    else {
      throw CLIError(
        code: .validationError,
        message: "Reminder tag already exists.",
        details: ["tag": newName]
      )
    }
  }

  func verifyTagPresent(name: String) throws -> ReminderTagRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastTags: [ReminderTagRecord] = []
    var lastError: Error?

    repeat {
      do {
        let tags = try sqliteReader.listTags()
        lastTags = tags
        if let tag = tags.first(where: { tagRecordMatches($0, selector: name) }) {
          return tag
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "expected_tag": name,
      "actual_tags": lastTags.map(\.name).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app tag update could not be verified.",
      details: details
    )
  }

  func verifyTagAbsent(_ tag: ReminderTagRecord) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastTags: [ReminderTagRecord] = []
    var lastError: Error?

    repeat {
      do {
        let tags = try sqliteReader.listTags()
        lastTags = tags
        if !tags.contains(where: { tagRecordRepresents($0, tag) }) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "tag_id": tag.id,
      "tag": tag.name,
      "actual_tags": lastTags.map(\.name).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app tag deletion could not be verified.",
      details: details
    )
  }

  func tagRecordRepresents(_ current: ReminderTagRecord, _ expected: ReminderTagRecord)
    -> Bool
  {
    current.id == expected.id
      || tagRecordMatches(current, selector: expected.name)
      || expected.canonicalName.map { tagRecordMatches(current, selector: $0) } == true
  }

  func tagRecordMatches(_ tag: ReminderTagRecord, selector: String) -> Bool {
    tag.id == selector
      || tagNameMatches(tag.name, selector)
      || tag.canonicalName.map { tagNameMatches($0, selector) } == true
  }

  func tagNameMatches(_ lhs: String, _ rhs: String) -> Bool {
    lhs.localizedCaseInsensitiveCompare(rhs) == .orderedSame
  }
}
