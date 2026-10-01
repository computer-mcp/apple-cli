import Foundation
import Utility

extension RemindersCommand {
  public func createReminderSmartList(
    title: String,
    source: ReminderListSourceRecord,
    criteria: ReminderSmartListCriteria
  ) throws -> ReminderListRecord {
    try self.preflightSmartListMutation(listID: nil)
    try self.createSmartList(title: title, sourceID: source.id, criteria: criteria)
    return try verifySmartListPresent(title: title, source: source, requireCriteriaEvidence: true)
  }

  public func updateReminderSmartList(
    list: ReminderListRecord,
    criteria: ReminderSmartListCriteria
  ) throws -> ReminderListRecord {
    try validateSmartListEvidence(list)
    try self.preflightSmartListMutation(listID: list.id)
    try self.updateSmartListCriteria(listID: list.id, criteria: criteria)
    return try verifySmartList(list: list, requireCriteriaEvidence: true)
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
    try self.convertListToSmartList(listID: list.id)
    let source = ReminderListSourceRecord(
      id: list.sourceId,
      title: list.sourceTitle,
      sourceType: "",
      reminderListCount: 0
    )
    return try verifySmartListPresent(
      title: list.title,
      source: source,
      requireCriteriaEvidence: true
    )
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
    let lists = try listReminderLists()
    guard !lists.contains(where: { $0.id == list.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Smart List was still present after delete.",
        details: [
          "id": list.id,
          "mechanism": "reminderkit",
          "capability": "smart_lists",
        ]
      )
    }
    return true
  }

  func verifySmartListPresent(
    title: String,
    source: ReminderListSourceRecord,
    requireCriteriaEvidence: Bool
  ) throws -> ReminderListRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastLists: [ReminderListRecord] = []
    var lastError: Error?

    repeat {
      do {
        let lists = try enrichedReminderListsForVerification()
        lastLists = lists
        if let list = lists.first(where: {
          smartListCreateCandidate($0, title: title, source: source)
        }) {
          do {
            return try verifySmartList(list: list, requireCriteriaEvidence: requireCriteriaEvidence)
          } catch {
            lastError = error
          }
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "title": title,
      "source_id": source.id,
      "actual_lists": lastLists.map { "\($0.title):\($0.listType ?? "")" }.joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = reminderKitErrorSummary(lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app Smart List creation could not be verified.",
      details: details
    )
  }

  func verifySmartList(
    list: ReminderListRecord,
    requireCriteriaEvidence: Bool
  ) throws -> ReminderListRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastList: ReminderListRecord?
    var lastDebug: RemindersListDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let lists = try enrichedReminderListsForVerification()
        lastList = lists.first(where: { $0.id == list.id }) ?? list
        if let current = lastList, current.listType == "smart" {
          let debug = try sqliteReader.debugList(list: current)
          lastDebug = debug
          if smartListCriteriaEvidenceSatisfied(debug: debug, required: requireCriteriaEvidence) {
            return current
          }
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "expected_type": "smart",
      "actual_type": lastList?.listType ?? "",
      "require_criteria_evidence": "\(requireCriteriaEvidence)",
    ]
    if let lastDebug {
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["actual_smart_types"] = lastDebug.privateStoreMatches.compactMap(\.smartListType)
        .joined(separator: ",")
      details["actual_filter_lengths"] = lastDebug.privateStoreMatches.compactMap {
        $0.filterDataLengthBytes.map(String.init)
      }.joined(separator: ",")
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = reminderKitErrorSummary(lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app Smart List state could not be verified.",
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

  func smartListCreateCandidate(
    _ list: ReminderListRecord,
    title: String,
    source: ReminderListSourceRecord
  ) -> Bool {
    guard list.title.localizedCaseInsensitiveCompare(title) == .orderedSame else {
      return false
    }
    guard list.listType == "smart" else {
      return false
    }
    if list.sourceId == source.id
      || (list.sourceId.isEmpty
        && list.sourceTitle.localizedCaseInsensitiveCompare(source.title) == .orderedSame)
    {
      return true
    }
    return list.sourceId.isEmpty && list.listType == "smart"
  }

  func smartListCriteriaEvidenceSatisfied(
    debug: RemindersListDebugResponse,
    required: Bool
  ) -> Bool {
    guard required else {
      return debug.privateStoreMatches.contains { $0.listType == "smart" }
    }
    return debug.privateStoreMatches.contains { match in
      match.listType == "smart" && (match.filterDataLengthBytes ?? 0) > 0
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
