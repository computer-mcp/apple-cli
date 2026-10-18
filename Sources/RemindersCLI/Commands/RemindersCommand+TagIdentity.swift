import Foundation
import Utility

extension RemindersCommand {
  func reminderTagMutationIdentity(_ options: CLIOptions) throws
    -> ReminderTagMutationIdentity
  {
    let selector = try reminderRequiredTextOption("tag", options: options)
    let tags = try sqliteReader.listTags()
    let tag = try reminderTag(selector: selector, in: tags)
    let reminderIDs = try sqliteReader.reminderIDs(tagName: tag.name)
    let tagsHash = reminderTagsHash(tags)
    let reminderIDsHash = reminderTagReminderIDsHash(reminderIDs)
    let bindingPayload = [
      tag.id,
      tag.name,
      tag.canonicalName ?? "",
      "\(tag.relatedObjectCount)",
      "\(tag.reminderReferenceCount)",
      tagsHash,
      "\(reminderIDs.count)",
      reminderIDsHash,
    ].joined(separator: "|")
    return ReminderTagMutationIdentity(
      tag: tag,
      tags: tags,
      reminderIDs: reminderIDs,
      scopeDigest: "reminder-tag:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "tag_id": tag.id,
        "tag": tag.name,
        "canonical_name": tag.canonicalName ?? "",
        "related_object_count": "\(tag.relatedObjectCount)",
        "reminder_reference_count": "\(tag.reminderReferenceCount)",
        "affected_reminder_count": "\(reminderIDs.count)",
        "affected_reminders_sha256": reminderIDsHash,
        "tag_count": "\(tags.count)",
        "tags_sha256": tagsHash,
      ]
    )
  }

  func reminderTag(
    selector: String,
    in tags: [ReminderTagRecord]
  ) throws -> ReminderTagRecord {
    if let match = tags.first(where: { $0.id == selector }) {
      return match
    }

    let matches = tags.filter { identityTagRecordMatches($0, selector: selector) }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Reminder tag selector matched multiple tags.",
        details: ["selector": selector]
      )
    }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Reminder tag selector did not match any tag.",
        details: ["selector": selector]
      )
    }
    return match
  }

  func validateTagRenameTarget(
    tag: ReminderTagRecord,
    newName: String,
    identity: ReminderTagMutationIdentity
  ) throws {
    guard !identityTagRecordMatches(tag, selector: newName) else {
      throw CLIError(
        code: .validationError,
        message: "New reminder tag name must differ from the current name.",
        details: ["tag": tag.name]
      )
    }
    guard
      !identity.tags.contains(where: {
        $0.id != tag.id && identityTagRecordMatches($0, selector: newName)
      })
    else {
      throw CLIError(
        code: .validationError,
        message: "Reminder tag already exists.",
        details: ["tag": newName]
      )
    }
  }

  func reminderTagsHash(_ tags: [ReminderTagRecord]) -> String {
    let payload =
      tags
      .sorted { $0.id < $1.id }
      .map { tag in
        [
          tag.id,
          tag.name,
          tag.canonicalName ?? "",
          "\(tag.relatedObjectCount)",
          "\(tag.reminderReferenceCount)",
        ].joined(separator: ":")
      }
      .joined(separator: "\n")
    return sha256Hex(payload)
  }

  func reminderTagReminderIDsHash(_ reminderIDs: [String]) -> String {
    sha256Hex(Array(Set(reminderIDs)).sorted().joined(separator: "\n"))
  }

  func identityTagRecordMatches(_ tag: ReminderTagRecord, selector: String) -> Bool {
    tag.id == selector
      || tag.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
      || tag.canonicalName?.localizedCaseInsensitiveCompare(selector) == .orderedSame
  }
}
