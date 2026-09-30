import Foundation
import Utility

extension RemindersCommand {
  public func createReminderListGroup(title: String) throws -> ReminderListGroupRecord {
    try self.preflightListMetadataMutation(listID: nil)
    try self.createReminderListGroupChange(title: title)
    return try verifyListGroupPresent(title: title)
  }

  public func renameReminderListGroup(
    group: ReminderListGroupRecord,
    title: String
  ) throws -> ReminderListGroupRecord {
    try self.preflightListMetadataMutation(listID: nil)
    try self.renameReminderListGroupChange(groupID: group.id, title: title)
    return try verifyListGroupRenamed(group: group, expectedTitle: title)
  }

  public func deleteReminderListGroup(group: ReminderListGroupRecord) throws -> Bool {
    try self.preflightListMetadataMutation(listID: nil)
    try self.deleteReminderListGroupChange(groupID: group.id)
    try verifyListGroupAbsent(group: group)
    return true
  }

  public func moveReminderList(
    _ list: ReminderListRecord,
    toGroup group: ReminderListGroupRecord
  ) throws -> ReminderListRecord {
    try self.preflightListMetadataMutation(listID: list.id)
    try self.moveReminderListToGroup(listID: list.id, toGroupID: group.id)
    return try verifyListParentGroup(list: list, expectedGroup: group)
  }

  public func removeReminderListFromGroup(_ list: ReminderListRecord) throws -> ReminderListRecord {
    try self.preflightListMetadataMutation(listID: list.id)
    try self.removeReminderListFromGroupChange(listID: list.id)
    return try verifyListParentGroup(list: list, expectedGroup: nil)
  }

  func verifyListGroupPresent(title: String) throws -> ReminderListGroupRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastGroups: [ReminderListGroupRecord] = []
    var lastError: Error?

    repeat {
      do {
        let groups = try sqliteReader.listGroups()
        lastGroups = groups
        if let group = groups.first(where: { groupTitleMatches($0.title, title) }) {
          return group
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "expected_group": title,
      "actual_groups": lastGroups.map(\.title).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app list group creation could not be verified.",
      details: details
    )
  }

  func verifyListGroupRenamed(
    group: ReminderListGroupRecord,
    expectedTitle: String
  ) throws -> ReminderListGroupRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastGroups: [ReminderListGroupRecord] = []
    var lastError: Error?

    repeat {
      do {
        let groups = try sqliteReader.listGroups()
        lastGroups = groups
        if let renamed = groups.first(where: {
          $0.id == group.id && groupTitleMatches($0.title, expectedTitle)
        }) {
          return renamed
        }
        if let renamedByTitle = groups.first(where: { groupTitleMatches($0.title, expectedTitle) })
        {
          return renamedByTitle
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "group_id": group.id,
      "old_title": group.title,
      "expected_title": expectedTitle,
      "actual_groups": lastGroups.map(\.title).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app list group rename could not be verified.",
      details: details
    )
  }

  func verifyListGroupAbsent(group: ReminderListGroupRecord) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastGroups: [ReminderListGroupRecord] = []
    var lastError: Error?

    repeat {
      do {
        let groups = try sqliteReader.listGroups()
        lastGroups = groups
        if !groups.contains(where: { $0.id == group.id || groupTitleMatches($0.title, group.title) }
        ) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "group_id": group.id,
      "group_title": group.title,
      "actual_groups": lastGroups.map(\.title).joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app list group deletion could not be verified.",
      details: details
    )
  }

  func verifyListParentGroup(
    list: ReminderListRecord,
    expectedGroup: ReminderListGroupRecord?
  ) throws -> ReminderListRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastMatches: [RemindersPrivateListDebugRecord] = []
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugList(list: list)
        lastMatches = debug.privateStoreMatches
        if listParentGroupSatisfied(debug: debug, expectedGroup: expectedGroup) {
          return try enrichedReminderListsForVerification().first(where: { $0.id == list.id })
            ?? list
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "expected_group": expectedGroup?.title ?? "",
      "actual_parent_groups": lastMatches.map {
        $0.parentListTitle ?? $0.parentListIdentifier ?? ""
      }
      .joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app list group membership could not be verified.",
      details: details
    )
  }

  func listParentGroupSatisfied(
    debug: RemindersListDebugResponse,
    expectedGroup: ReminderListGroupRecord?
  ) -> Bool {
    if let expectedGroup {
      return debug.privateStoreMatches.contains { match in
        match.parentListIdentifier == expectedGroup.id
          || (match.parentListTitle?.localizedCaseInsensitiveCompare(expectedGroup.title)
            == .orderedSame)
      }
    }
    return debug.privateStoreMatches.contains { match in
      match.parentListIdentifier == nil && match.parentListTitle == nil
    }
  }

  func groupTitleMatches(_ lhs: String, _ rhs: String) -> Bool {
    lhs.localizedCaseInsensitiveCompare(rhs) == .orderedSame
  }
}
