import Foundation
import Utility

extension RemindersCommand {
  func reminderListGroupCreateIdentity(_ options: CLIOptions) throws
    -> ReminderListGroupCreateIdentity
  {
    let title = try reminderRequiredTextOption("title", options: options)
    let groups = try sqliteReader.listGroups()
    try validateListGroupDoesNotExist(title: title, groups: groups)
    let groupsHash = reminderListGroupsHash(groups)
    let hierarchyHash = try reminderListHierarchyHash()
    let bindingPayload = [
      title,
      groupsHash,
      hierarchyHash,
    ].joined(separator: "|")
    return ReminderListGroupCreateIdentity(
      title: title,
      groups: groups,
      scopeDigest: "reminder-list-group-create:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "title": title,
        "group_count": "\(groups.count)",
        "groups_sha256": groupsHash,
        "list_hierarchy_sha256": hierarchyHash,
      ]
    )
  }

  func reminderListGroupMutationIdentity(_ options: CLIOptions) throws
    -> ReminderListGroupMutationIdentity
  {
    let groups = try sqliteReader.listGroups()
    let group = try reminderListGroup(
      selector: try requiredOption("group", options: options),
      in: groups
    )
    let groupsHash = reminderListGroupsHash(groups)
    let hierarchyHash = try reminderListHierarchyHash()
    let bindingPayload = [
      group.id,
      group.title,
      "\(group.childListCount)",
      "\(group.childGroupCount)",
      groupsHash,
      hierarchyHash,
    ].joined(separator: "|")
    return ReminderListGroupMutationIdentity(
      group: group,
      groups: groups,
      scopeDigest: "reminder-list-group:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "group_id": group.id,
        "group_title": group.title,
        "child_list_count": "\(group.childListCount)",
        "child_group_count": "\(group.childGroupCount)",
        "groups_sha256": groupsHash,
        "list_hierarchy_sha256": hierarchyHash,
      ]
    )
  }

  func reminderListGroupMoveIdentity(
    _ options: CLIOptions,
    requireGroup: Bool
  ) throws -> ReminderListGroupMoveIdentity {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }
    let groups = try sqliteReader.listGroups()
    let group: ReminderListGroupRecord?
    if requireGroup {
      group = try reminderListGroup(
        selector: try requiredOption("group", options: options),
        in: groups
      )
    } else {
      group = nil
    }
    let currentGroup = try currentListGroup(list)
    if let group, currentGroup?.id == group.id {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is already in the requested group.",
        details: ["list": list.title, "group": group.title]
      )
    }
    if !requireGroup, currentGroup == nil {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is not currently in a group.",
        details: ["list": list.title]
      )
    }

    let groupsHash = reminderListGroupsHash(groups)
    let hierarchyHash = try reminderListHierarchyHash()
    let bindingPayload = [
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      group?.id ?? "",
      group?.title ?? "",
      currentGroup?.id ?? "",
      currentGroup?.title ?? "",
      groupsHash,
      hierarchyHash,
    ].joined(separator: "|")
    var summary = [
      "list_id": list.id,
      "list_title": list.title,
      "target_group_id": group?.id ?? "",
      "target_group_title": group?.title ?? "",
      "current_group_id": currentGroup?.id ?? "",
      "current_group_title": currentGroup?.title ?? "",
      "groups_sha256": groupsHash,
      "list_hierarchy_sha256": hierarchyHash,
    ]
    summary["operation"] = requireGroup ? "move-list" : "remove-list"
    return ReminderListGroupMoveIdentity(
      list: list,
      group: group,
      currentGroup: currentGroup,
      scopeDigest: "reminder-list-group-membership:\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func reminderListGroup(
    selector: String,
    in groups: [ReminderListGroupRecord]
  ) throws -> ReminderListGroupRecord {
    let idMatches = groups.filter { $0.id == selector }
    if let match = idMatches.first {
      return match
    }

    let titleMatches = groups.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Reminder list group selector matched multiple groups.",
        details: ["selector": selector]
      )
    }
    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Reminder list group selector did not match any group.",
        details: ["selector": selector]
      )
    }
    return match
  }

  func validateListGroupDoesNotExist(
    title: String,
    groups: [ReminderListGroupRecord]
  ) throws {
    guard
      !groups.contains(where: { $0.title.localizedCaseInsensitiveCompare(title) == .orderedSame })
    else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list group already exists.",
        details: ["title": title]
      )
    }
  }

  func validateListGroupRenameTarget(
    group: ReminderListGroupRecord,
    title: String,
    groups: [ReminderListGroupRecord]
  ) throws {
    guard group.title.localizedCaseInsensitiveCompare(title) != .orderedSame else {
      throw CLIError(
        code: .validationError,
        message: "New reminder list group title must differ from the current title.",
        details: ["group": group.title]
      )
    }
    try validateListGroupDoesNotExist(title: title, groups: groups)
  }

  func currentListGroup(_ list: ReminderListRecord) throws -> ReminderListGroupRecord? {
    let debug = try sqliteReader.debugList(list: list)
    guard
      let match = debug.privateStoreMatches.first(where: {
        $0.parentListIdentifier != nil || $0.parentListTitle != nil
      })
    else {
      return nil
    }
    let title = match.parentListTitle ?? match.parentListIdentifier ?? ""
    let id = match.parentListIdentifier ?? title
    guard !id.isEmpty || !title.isEmpty else {
      return nil
    }
    return ReminderListGroupRecord(id: id, title: title)
  }

  func reminderListGroupsHash(_ groups: [ReminderListGroupRecord]) -> String {
    let payload =
      groups
      .sorted { $0.id < $1.id }
      .map { group in
        [
          group.id,
          group.title,
          "\(group.childListCount)",
          "\(group.childGroupCount)",
        ].joined(separator: ":")
      }
      .joined(separator: "\n")
    return sha256Hex(payload)
  }

  func reminderListGroupMutationScopeDigest(
    identity: ReminderListGroupMutationIdentity,
    operation: String,
    title: String? = nil
  ) -> String {
    let payload = [
      identity.scopeDigest,
      operation,
      title ?? "",
    ].joined(separator: "|")
    return "reminder-list-group-\(operation):\(sha256Hex(payload))"
  }

  func reminderListHierarchyHash() throws -> String {
    let debug = try sqliteReader.debugStore(scope: "lists")
    let payload = debug.lists
      .sorted {
        if $0.storePath == $1.storePath {
          return $0.primaryKey < $1.primaryKey
        }
        return $0.storePath < $1.storePath
      }
      .map { row in
        [
          row.ckIdentifier ?? "",
          row.externalIdentifier ?? "",
          row.title ?? "",
          row.isGroup.map(String.init) ?? "",
          row.parentListIdentifier ?? "",
          row.parentListTitle ?? "",
          "\(row.childListCount)",
          "\(row.childGroupCount)",
        ].joined(separator: ":")
      }
      .joined(separator: "\n")
    return sha256Hex(payload)
  }

  func reminderListOrderHash(_ lists: [ReminderListRecord]) -> String {
    let payload =
      lists
      .sorted { $0.id < $1.id }
      .map { list in
        [
          list.id,
          list.title,
          list.sourceId,
          list.sourceTitle,
          list.displayOrder.map(String.init) ?? "",
          list.isPinned.map(String.init) ?? "",
        ].joined(separator: ":")
      }
      .joined(separator: "\n")
    return sha256Hex(payload)
  }
}
