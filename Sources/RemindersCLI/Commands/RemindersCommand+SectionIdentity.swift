import Foundation
import Utility

extension RemindersCommand {
  func reminderSectionMutationIdentity(_ options: CLIOptions) throws
    -> ReminderSectionMutationIdentity
  {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }

    let sections = try sqliteReader.listSections(list: list)
    let sectionBindings = sections.map { section in
      [
        section.id,
        section.listId,
        section.listTitle,
        section.title,
      ].joined(separator: ":")
    }
    let sectionsHash = sha256Hex(sectionBindings.joined(separator: "\n"))
    let bindingPayload = [
      list.id,
      list.title,
      list.sourceTitle,
      "\(list.allowsContentModifications)",
      sectionsHash,
    ].joined(separator: "|")

    return ReminderSectionMutationIdentity(
      list: list,
      sections: sections,
      scopeDigest: "reminder-sections:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "list_id": list.id,
        "list_title": list.title,
        "section_count": "\(sections.count)",
        "sections_sha256": sectionsHash,
      ]
    )
  }

  func validateSectionExists(
    _ title: String,
    identity: ReminderSectionMutationIdentity
  ) throws {
    _ = try sectionRecord(title: title, identity: identity)
  }

  func sectionRecord(
    title: String,
    identity: ReminderSectionMutationIdentity
  ) throws -> ReminderSectionRecord {
    guard
      let section = identity.sections.first(where: { identitySectionTitleMatches($0.title, title) })
    else {
      throw CLIError(
        code: .notFound,
        message: "Reminder section was not found.",
        details: ["list": identity.list.title, "section": title]
      )
    }
    return section
  }

  func validateSectionDoesNotExist(
    _ title: String,
    identity: ReminderSectionMutationIdentity
  ) throws {
    guard !identity.sections.contains(where: { identitySectionTitleMatches($0.title, title) })
    else {
      throw CLIError(
        code: .validationError,
        message: "Reminder section already exists.",
        details: ["list": identity.list.title, "section": title]
      )
    }
  }

  func validateSectionRenameTarget(
    sectionTitle: String,
    newTitle: String,
    identity: ReminderSectionMutationIdentity
  ) throws {
    guard !identitySectionTitleMatches(sectionTitle, newTitle) else {
      throw CLIError(
        code: .validationError,
        message: "New reminder section title must differ from the current title.",
        details: ["section": sectionTitle]
      )
    }
    try validateSectionDoesNotExist(newTitle, identity: identity)
  }

  func reminderSectionReorderPlacement(
    _ options: CLIOptions,
    identity: ReminderSectionMutationIdentity
  ) throws -> (anchorSection: ReminderSectionRecord, placement: ReminderSectionReorderPlacement) {
    let before = try reminderListTextOption(options.targetOption("before"), optionName: "before")
    let after = try reminderListTextOption(options.targetOption("after"), optionName: "after")
    if (before == nil && after == nil) || (before != nil && after != nil) {
      throw CLIError(
        code: .validationError,
        message: "`sections reorder` requires exactly one of `--before` or `--after`."
      )
    }

    let anchorTitle = before ?? after ?? ""
    let anchor = try sectionRecord(title: anchorTitle, identity: identity)
    return (
      anchorSection: anchor,
      placement: ReminderSectionReorderPlacement(
        beforeSectionId: before == nil ? nil : anchor.id,
        afterSectionId: after == nil ? nil : anchor.id
      )
    )
  }

  func identitySectionTitleMatches(_ lhs: String, _ rhs: String) -> Bool {
    lhs.localizedCaseInsensitiveCompare(rhs) == .orderedSame
  }
}
