import Foundation
import Utility

extension RemindersCommand {
  public func createReminderSection(list: ReminderListRecord, title: String) throws
    -> ReminderSectionRecord
  {
    try validateListCanMutateSections(list)
    try validateSectionDoesNotExist(title, list: list)
    try self.preflightSectionMutation(listID: list.id, reminderID: nil)
    try self.createSection(listID: list.id, title: title)
    return try verifySectionPresent(list: list, expectedSectionTitle: title)
  }

  public func renameReminderSection(
    list: ReminderListRecord,
    sectionTitle: String,
    newTitle: String
  ) throws -> ReminderSectionRecord {
    try validateListCanMutateSections(list)
    try validateSectionExists(sectionTitle, list: list)
    guard !sectionTitleMatches(sectionTitle, newTitle) else {
      throw CLIError(
        code: .validationError,
        message: "New reminder section title must differ from the current title.",
        details: ["section": sectionTitle]
      )
    }
    try validateSectionDoesNotExist(newTitle, list: list)
    try self.preflightSectionMutation(listID: list.id, reminderID: nil)
    try self.renameSection(
      listID: list.id,
      sectionTitle: sectionTitle,
      newTitle: newTitle
    )
    return try verifySectionPresent(list: list, expectedSectionTitle: newTitle)
  }

  public func deleteReminderSection(list: ReminderListRecord, sectionTitle: String) throws -> Bool {
    try validateListCanMutateSections(list)
    try validateSectionExists(sectionTitle, list: list)
    try self.preflightSectionMutation(listID: list.id, reminderID: nil)
    try self.deleteSection(listID: list.id, sectionTitle: sectionTitle)
    try verifySectionAbsent(list: list, sectionTitle: sectionTitle)
    return true
  }

  public func reorderReminderSection(
    list: ReminderListRecord,
    sectionTitle: String,
    anchorSectionTitle: String,
    placement: ReminderSectionReorderPlacement
  ) throws -> [ReminderSectionRecord] {
    try validateListCanMutateSections(list)
    let section = try sectionRecord(title: sectionTitle, list: list)
    let anchor = try sectionRecord(title: anchorSectionTitle, list: list)
    guard section.id != anchor.id else {
      throw CLIError(
        code: .validationError,
        message: "Reminder section cannot be reordered relative to itself.",
        details: ["section": sectionTitle]
      )
    }
    guard placement.anchorSectionId == anchor.id else {
      throw CLIError(
        code: .validationError,
        message: "Reminder section reorder anchor did not match placement.",
        details: ["anchor_section_id": anchor.id]
      )
    }
    try self.preflightSectionMutation(listID: list.id, reminderID: nil)
    try self.reorderSection(
      listID: list.id,
      sectionTitle: section.title,
      anchorSectionTitle: anchor.title,
      placement: placement
    )
    return try verifySectionReorder(
      list: list,
      section: section,
      anchorSection: anchor,
      placement: placement
    )
  }

  func validateListCanMutateSections(_ list: ReminderListRecord) throws {
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }
  }

  func validateSectionExists(_ title: String, list: ReminderListRecord) throws {
    _ = try sectionRecord(title: title, list: list)
  }

  func sectionRecord(title: String, list: ReminderListRecord) throws -> ReminderSectionRecord {
    let sections = try sqliteReader.listSections(list: list)
    guard let section = sections.first(where: { sectionTitleMatches($0.title, title) }) else {
      throw CLIError(
        code: .notFound,
        message: "Reminder section was not found.",
        details: ["list": list.title, "section": title]
      )
    }
    return section
  }

  func validateSectionDoesNotExist(_ title: String, list: ReminderListRecord) throws {
    let sections = try sqliteReader.listSections(list: list)
    guard !sections.contains(where: { sectionTitleMatches($0.title, title) }) else {
      throw CLIError(
        code: .validationError,
        message: "Reminder section already exists.",
        details: ["list": list.title, "section": title]
      )
    }
  }

  func verifySectionPresent(
    list: ReminderListRecord,
    expectedSectionTitle: String
  ) throws -> ReminderSectionRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastSections: [ReminderSectionRecord] = []
    var lastError: Error?

    repeat {
      do {
        let sections = try sqliteReader.listSections(list: list)
        lastSections = sections
        if let section = sections.first(where: {
          sectionTitleMatches($0.title, expectedSectionTitle)
        }) {
          return section
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "expected_section": expectedSectionTitle,
      "actual_sections": lastSections.map(\.title).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app section update could not be verified.",
      details: details
    )
  }

  func verifySectionAbsent(
    list: ReminderListRecord,
    sectionTitle: String
  ) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastSections: [ReminderSectionRecord] = []
    var lastError: Error?

    repeat {
      do {
        let sections = try sqliteReader.listSections(list: list)
        lastSections = sections
        if !sections.contains(where: { sectionTitleMatches($0.title, sectionTitle) }) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "section": sectionTitle,
      "actual_sections": lastSections.map(\.title).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app section deletion could not be verified.",
      details: details
    )
  }

  func verifySectionReorder(
    list: ReminderListRecord,
    section: ReminderSectionRecord,
    anchorSection: ReminderSectionRecord,
    placement: ReminderSectionReorderPlacement
  ) throws -> [ReminderSectionRecord] {
    let deadline = Date().addingTimeInterval(10)
    var lastSections: [ReminderSectionRecord] = []
    var lastError: Error?

    repeat {
      do {
        let sections = try sqliteReader.listSections(list: list)
        lastSections = sections
        if sectionReorderSatisfied(
          sections: sections,
          sectionID: section.id,
          anchorSectionID: anchorSection.id,
          placement: placement
        ) {
          return sections
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "section_id": section.id,
      "anchor_section_id": anchorSection.id,
      "placement": placement.relation,
      "actual_sections": lastSections.map(\.title).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app section reorder could not be verified.",
      details: details
    )
  }

  func sectionReorderSatisfied(
    sections: [ReminderSectionRecord],
    sectionID: String,
    anchorSectionID: String,
    placement: ReminderSectionReorderPlacement
  ) -> Bool {
    guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }),
      let anchorIndex = sections.firstIndex(where: { $0.id == anchorSectionID })
    else {
      return false
    }
    if placement.beforeSectionId != nil {
      return sectionIndex < anchorIndex
    }
    return sectionIndex > anchorIndex
  }

  func sectionTitleMatches(_ lhs: String, _ rhs: String) -> Bool {
    lhs.localizedCaseInsensitiveCompare(rhs) == .orderedSame
  }
}
