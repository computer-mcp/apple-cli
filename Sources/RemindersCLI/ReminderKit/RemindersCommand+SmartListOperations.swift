import Foundation
import Utility

extension RemindersCommand {
  public func createReminderSmartList(
    title: String,
    source: ReminderListSourceRecord,
    criteria: ReminderSmartListCriteria
  ) throws -> ReminderListRecord {
    try self.preflightSmartListMutation(listID: nil)
    let expectedFilter = try ReminderSmartListFilterEncoder.encode(criteria: criteria)
    let id = try self.createSmartList(title: title, sourceID: source.id, criteria: criteria)
    return try verifySmartList(id: id, sourceID: source.id, expectedFilter: expectedFilter)
  }

  public func updateReminderSmartList(
    list: ReminderListRecord,
    criteria: ReminderSmartListCriteria
  ) throws -> ReminderSmartListMutationResult {
    try validateSmartListEvidence(list)
    try self.preflightSmartListMutation(listID: list.id)
    let expectedFilter = try ReminderSmartListFilterEncoder.encode(criteria: criteria)
    let changed = try self.updateSmartListCriteria(listID: list.id, criteria: criteria)
    let current = try verifySmartList(
      id: list.id, sourceID: list.sourceId,
      expectedFilter: expectedFilter, mutationOccurred: changed)
    return ReminderSmartListMutationResult(
      operation: "reminders.lists.smart.update",
      changed: changed, list: current, criteria: criteria)
  }

  public func convertReminderListToSmartList(list: ReminderListRecord) throws
    -> ReminderListRecord
  {
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }
    guard list.listType != "smart" else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is already a Smart List.",
        details: ["list": list.title]
      )
    }
    try validateSmartListConversionTagScope(list: list)
    let expectedFilter = try ReminderSmartListFilterEncoder.encodeTagFilter(
      tagName: list.title.trimmingCharacters(in: .whitespacesAndNewlines))
    let id = try self.convertListToSmartList(listID: list.id)
    return try verifySmartList(id: id, sourceID: list.sourceId, expectedFilter: expectedFilter)
  }

  public func deleteReminderSmartList(list: ReminderListRecord) throws -> Bool {
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }
    try validateSmartListEvidence(list)
    try self.preflightSmartListMutation(listID: list.id)
    try self.deleteSmartList(listID: list.id)
    let deadline = Date().addingTimeInterval(10)
    var lastError: Error?
    repeat {
      do {
        if try readReminderSmartListSnapshot(id: list.id) == nil { return true }
      } catch { lastError = error }
      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline
    throw CLIError(
      code: .backendUnavailable,
      message: "Smart List deletion could not be verified. Inspect the list before retrying.",
      details: [
        "list_id": list.id, "verification": "unconfirmed", "mutation_may_have_occurred": "true",
        "last_error": lastError.map(reminderKitErrorSummary) ?? "",
      ])
  }

  func verifySmartList(
    id: String,
    sourceID: String,
    expectedFilter: Data,
    mutationOccurred: Bool = true
  ) throws -> ReminderListRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastSnapshot: ReminderSmartListSnapshot?
    var lastError: Error?

    repeat {
      do {
        lastSnapshot = try readReminderSmartListSnapshot(id: id)
        if reminderSmartListReadbackMatches(
          lastSnapshot, id: id, sourceID: sourceID,
          expectedFilter: expectedFilter), let current = lastSnapshot?.list
        {
          return (try? sqliteReader.enrichLists([current]).first) ?? current
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminderkit_smart_list_storage",
      "list_id": id,
      "source_id": sourceID,
      "actual_source_id": lastSnapshot?.list.sourceId ?? "",
      "verification": "unconfirmed",
      "mutation_may_have_occurred": "\(mutationOccurred)",
    ]
    if let lastError {
      details["last_error"] = reminderKitErrorSummary(lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message:
        "Smart List identity, account and requested rules could not be verified. Inspect the list before retrying.",
      details: details
    )
  }

  func validateSmartListEvidence(_ list: ReminderListRecord) throws {
    guard list.listType == "smart" else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is not known to be a Smart List.",
        details: [
          "list": list.title,
          "list_type": list.listType ?? "",
        ]
      )
    }
  }

  func validateSmartListConversionTagScope(list: ReminderListRecord) throws {
    let tagName = list.title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !tagName.isEmpty else {
      return
    }

    let taggedReminderIDs = try normalizedReminderIDs(sqliteReader.reminderIDs(tagName: tagName))
    guard !taggedReminderIDs.isEmpty else {
      return
    }

    let sourceReminderIDs = Set(
      try fetchReminderKitReminders(
        ReminderQuery(
          listSelector: list.id,
          completion: .all,
          limit: max(taggedReminderIDs.count + 100, 1_000)
        )
      ).map(\.id)
    )
    let outsideSource = taggedReminderIDs.filter { !sourceReminderIDs.contains($0) }
    guard outsideSource.isEmpty else {
      throw CLIError(
        code: .validationError,
        message:
          "Smart List conversion tag is already used by reminders outside the source list.",
        details: [
          "list_id": list.id,
          "tag": tagName,
          "conflicting_reminder_count": "\(outsideSource.count)",
          "conflicting_reminder_ids": outsideSource.prefix(20).joined(separator: ","),
        ]
      )
    }
  }
}
