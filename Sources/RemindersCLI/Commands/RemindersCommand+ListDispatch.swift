import Foundation
import Utility

extension RemindersCommand {
  func runListsCommand(_ options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["lists", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let lists = try listReminderLists()
      return try result(
        ReminderListsResponse(lists: lists),
        human: listsHumanOutput(lists),
        options: options
      )
    case ["lists", "icons", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let response = ReminderListIconsResponse(icons: ReminderListIconCatalog.records)
      return try result(
        response,
        human: reminderListIconsHumanOutput(response.icons),
        options: options
      )
    case ["lists", "groups", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let groups = try sqliteReader.listGroups()
      return try result(
        ReminderListGroupsResponse(groups: groups),
        human: reminderListGroupsHumanOutput(groups),
        options: options
      )
    case ["lists", "groups", "create"]:
      try validateTargetOptions(options, allowedOptions: ["title"])
      try validateMutationIntent(options)
      let identity = try reminderListGroupCreateIdentity(options)
      return try mutation(
        operation: "reminders.lists.groups.create",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let group = try createReminderListGroup(title: identity.title)
        return ReminderListMutationResult(
          operation: "reminders.lists.groups.create",
          changed: true,
          group: group
        )
      }
    case ["lists", "groups", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["group", "title"])
      try validateMutationIntent(options)
      let identity = try reminderListGroupMutationIdentity(options)
      let title = try reminderRequiredTextOption("title", options: options)
      try validateListGroupRenameTarget(
        group: identity.group, title: title, groups: identity.groups)
      return try mutation(
        operation: "reminders.lists.groups.rename",
        scopeDigest: reminderListGroupMutationScopeDigest(
          identity: identity,
          operation: "rename",
          title: title
        ),
        summary: identity.summaryFields.merging(
          ["operation": "rename", "new_title": title],
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let group = try renameReminderListGroup(
          group: identity.group,
          title: title
        )
        return ReminderListMutationResult(
          operation: "reminders.lists.groups.rename",
          changed: true,
          group: group
        )
      }
    case ["lists", "groups", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["group"])
      try validateMutationIntent(options)
      let identity = try reminderListGroupMutationIdentity(options)
      return try mutation(
        operation: "reminders.lists.groups.delete",
        scopeDigest: reminderListGroupMutationScopeDigest(identity: identity, operation: "delete"),
        summary: identity.summaryFields.merging(
          ["operation": "delete"],
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let changed = try deleteReminderListGroup(group: identity.group)
        return ReminderListMutationResult(
          operation: "reminders.lists.groups.delete",
          changed: changed,
          group: identity.group
        )
      }
    case ["lists", "groups", "move-list"]:
      try validateTargetOptions(options, allowedOptions: ["list", "group"])
      try validateMutationIntent(options)
      let identity = try reminderListGroupMoveIdentity(options, requireGroup: true)
      guard let group = identity.group else {
        throw CLIError(code: .validationError, message: "`--group` is required.")
      }
      return try mutation(
        operation: "reminders.lists.groups.move-list",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try moveReminderList(identity.list, toGroup: group)
        return ReminderListMutationResult(
          operation: "reminders.lists.groups.move-list",
          changed: true,
          list: list,
          group: group
        )
      }
    case ["lists", "groups", "remove-list"]:
      try validateTargetOptions(options, allowedOptions: ["list"])
      try validateMutationIntent(options)
      let identity = try reminderListGroupMoveIdentity(options, requireGroup: false)
      return try mutation(
        operation: "reminders.lists.groups.remove-list",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try removeReminderListFromGroup(identity.list)
        return ReminderListMutationResult(
          operation: "reminders.lists.groups.remove-list",
          changed: true,
          list: list,
          group: identity.currentGroup
        )
      }
    case ["lists", "create"]:
      try validateTargetOptions(options, allowedOptions: ["title", "source"])
      try validateMutationIntent(options)
      let identity = try reminderListCreateIdentity(options)
      return try mutation(
        operation: "reminders.lists.create",
        scopeDigest: reminderListCreateScopeDigest(identity: identity),
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try createReminderList(
          title: identity.title,
          sourceID: identity.source.id
        )
        return ReminderListMutationResult(
          operation: "reminders.lists.create",
          changed: true,
          list: list
        )
      }
    case ["lists", "update"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "list", "title", "type", "color", "icon", "pinned", "sort",
          "show-large-attachments",
        ]
      )
      try validateMutationIntent(options)
      let identity = try reminderListMutationIdentity(options)
      let patch = try reminderListPatch(options)
      guard patch.hasChanges else {
        throw CLIError(
          code: .validationError,
          message: "At least one reminder list update field is required."
        )
      }
      return try mutation(
        operation: "reminders.lists.update",
        scopeDigest: reminderListUpdateScopeDigest(identity: identity, patch: patch),
        summary: identity.summaryFields.merging(
          reminderListPatchSummary(patch), uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let list = try updateReminderList(id: identity.list.id, patch: patch)
        return ReminderListMutationResult(
          operation: "reminders.lists.update",
          changed: true,
          list: list
        )
      }
    case ["lists", "reorder"]:
      try validateTargetOptions(options, allowedOptions: ["list", "before", "after"])
      try validateMutationIntent(options)
      let identity = try reminderListReorderIdentity(options)
      return try mutation(
        operation: "reminders.lists.reorder",
        scopeDigest: reminderListReorderScopeDigest(identity: identity),
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try reorderReminderList(
          id: identity.list.id,
          anchorListID: identity.anchorList.id,
          placement: identity.placement
        )
        return ReminderListReorderResult(
          operation: "reminders.lists.reorder",
          changed: true,
          list: list,
          anchorList: identity.anchorList,
          placement: identity.placement
        )
      }
    case ["lists", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["list"])
      try validateMutationIntent(options)
      let identity = try reminderListDeleteIdentity(options)
      return try mutation(
        operation: "reminders.lists.delete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let changed = try deleteReminderList(id: identity.list.id)
        return ReminderListDeleteResult(
          operation: "reminders.lists.delete",
          changed: changed,
          deletedListID: identity.list.id,
          deletedListTitle: identity.list.title,
          deletedReminderCount: identity.reminderCount
        )
      }
    case ["lists", "smart", "create"]:
      try validateTargetOptions(options, allowedOptions: ["title", "source", "criteria", "match"])
      try validateMutationIntent(options)
      let identity = try reminderSmartListCreateIdentity(options)
      return try mutation(
        operation: "reminders.lists.smart.create",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try createReminderSmartList(
          title: identity.title,
          source: identity.source,
          criteria: identity.criteria
        )
        return ReminderSmartListMutationResult(
          operation: "reminders.lists.smart.create",
          changed: true,
          list: list,
          criteria: identity.criteria
        )
      }
    case ["lists", "smart", "update"]:
      try validateTargetOptions(options, allowedOptions: ["list", "criteria", "match"])
      try validateMutationIntent(options)
      let identity = try reminderSmartListMutationIdentity(options, requireCriteria: true)
      guard let criteria = identity.criteria else {
        throw CLIError(code: .validationError, message: "`--criteria` is required.")
      }
      return try mutation(
        operation: "reminders.lists.smart.update",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try updateReminderSmartList(
          list: identity.list,
          criteria: criteria
        )
        return ReminderSmartListMutationResult(
          operation: "reminders.lists.smart.update",
          changed: true,
          list: list,
          criteria: criteria
        )
      }
    case ["lists", "smart", "convert"]:
      try validateTargetOptions(options, allowedOptions: ["list"])
      try validateMutationIntent(options)
      let identity = try reminderSmartListMutationIdentity(options, requireCriteria: false)
      return try mutation(
        operation: "reminders.lists.smart.convert",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try convertReminderListToSmartList(
          list: identity.list
        )
        return ReminderSmartListMutationResult(
          operation: "reminders.lists.smart.convert",
          changed: true,
          list: list
        )
      }
    case ["lists", "smart", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["list"])
      try validateMutationIntent(options)
      let identity = try reminderSmartListDeleteIdentity(options)
      return try mutation(
        operation: "reminders.lists.smart.delete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let changed = try deleteReminderSmartList(list: identity.list)
        return ReminderListDeleteResult(
          operation: "reminders.lists.smart.delete",
          changed: changed,
          deletedListID: identity.list.id,
          deletedListTitle: identity.list.title,
          deletedReminderCount: 0
        )
      }
    default:
      return nil
    }
  }
}
