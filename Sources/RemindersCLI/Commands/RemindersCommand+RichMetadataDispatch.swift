import Foundation
import Utility

extension RemindersCommand {
  func runRichMetadataCommand(_ options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["tags", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let tags = try sqliteReader.listTags()
      return try result(
        ReminderTagsResponse(tags: tags),
        human: reminderTagsHumanOutput(tags),
        options: options
      )
    case ["tags", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["tag", "title"])
      try validateMutationIntent(options)
      let identity = try reminderTagMutationIdentity(options)
      let newName = try reminderRequiredTextOption("title", options: options)
      try validateTagRenameTarget(tag: identity.tag, newName: newName, identity: identity)
      return try mutation(
        operation: "reminders.tags.rename",
        scopeDigest: reminderTagMutationScopeDigest(
          identity: identity,
          operation: "rename",
          newName: newName
        ),
        summary: identity.summaryFields.merging(
          reminderTagMutationSummary(operation: "rename", tag: identity.tag, newName: newName),
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let tag = try renameReminderTag(
          tag: identity.tag,
          newName: newName,
          reminderIDs: identity.reminderIDs
        )
        return ReminderTagMutationResult(
          operation: "reminders.tags.rename",
          changed: true,
          tag: tag
        )
      }
    case ["tags", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["tag"])
      try validateMutationIntent(options)
      let identity = try reminderTagMutationIdentity(options)
      return try mutation(
        operation: "reminders.tags.delete",
        scopeDigest: reminderTagMutationScopeDigest(identity: identity, operation: "delete"),
        summary: identity.summaryFields.merging(
          reminderTagMutationSummary(operation: "delete", tag: identity.tag),
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let changed = try deleteReminderTag(
          tag: identity.tag,
          reminderIDs: identity.reminderIDs
        )
        return ReminderTagMutationResult(
          operation: "reminders.tags.delete",
          changed: changed,
          deletedTagName: identity.tag.name
        )
      }
    case ["sections", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["list"])
      let list = try reminderList(selector: try requiredOption("list", options: options))
      let sections = try sqliteReader.listSections(list: list)
      return try result(
        ReminderSectionsResponse(list: list, sections: sections),
        human: reminderSectionsHumanOutput(sections),
        options: options
      )
    case ["sections", "create"]:
      try validateTargetOptions(options, allowedOptions: ["list", "title"])
      try validateMutationIntent(options)
      let identity = try reminderSectionMutationIdentity(options)
      let title = try reminderRequiredTextOption("title", options: options)
      try validateSectionDoesNotExist(title, identity: identity)
      return try mutation(
        operation: "reminders.sections.create",
        scopeDigest: reminderSectionMutationScopeDigest(
          identity: identity,
          operation: "create",
          sectionTitle: title
        ),
        summary: identity.summaryFields.merging(
          reminderSectionMutationSummary(operation: "create", sectionTitle: title),
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let section = try createReminderSection(
          list: identity.list,
          title: title
        )
        return ReminderSectionMutationResult(
          operation: "reminders.sections.create",
          changed: true,
          list: identity.list,
          section: section
        )
      }
    case ["sections", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["list", "section", "title"])
      try validateMutationIntent(options)
      let identity = try reminderSectionMutationIdentity(options)
      let sectionTitle =
        try reminderSectionOption(
          try requiredOption("section", options: options)) ?? ""
      let newTitle = try reminderRequiredTextOption("title", options: options)
      try validateSectionExists(sectionTitle, identity: identity)
      try validateSectionRenameTarget(
        sectionTitle: sectionTitle, newTitle: newTitle, identity: identity)
      return try mutation(
        operation: "reminders.sections.rename",
        scopeDigest: reminderSectionMutationScopeDigest(
          identity: identity,
          operation: "rename",
          sectionTitle: sectionTitle,
          newTitle: newTitle
        ),
        summary: identity.summaryFields.merging(
          reminderSectionMutationSummary(
            operation: "rename",
            sectionTitle: sectionTitle,
            newTitle: newTitle
          ),
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let section = try renameReminderSection(
          list: identity.list,
          sectionTitle: sectionTitle,
          newTitle: newTitle
        )
        return ReminderSectionMutationResult(
          operation: "reminders.sections.rename",
          changed: true,
          list: identity.list,
          section: section
        )
      }
    case ["sections", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["list", "section"])
      try validateMutationIntent(options)
      let identity = try reminderSectionMutationIdentity(options)
      let sectionTitle =
        try reminderSectionOption(
          try requiredOption("section", options: options)) ?? ""
      try validateSectionExists(sectionTitle, identity: identity)
      return try mutation(
        operation: "reminders.sections.delete",
        scopeDigest: reminderSectionMutationScopeDigest(
          identity: identity,
          operation: "delete",
          sectionTitle: sectionTitle
        ),
        summary: identity.summaryFields.merging(
          reminderSectionMutationSummary(operation: "delete", sectionTitle: sectionTitle),
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let changed = try deleteReminderSection(
          list: identity.list,
          sectionTitle: sectionTitle
        )
        return ReminderSectionMutationResult(
          operation: "reminders.sections.delete",
          changed: changed,
          list: identity.list,
          deletedSectionTitle: sectionTitle
        )
      }
    case ["sections", "reorder"]:
      try validateTargetOptions(options, allowedOptions: ["list", "section", "before", "after"])
      try validateMutationIntent(options)
      let identity = try reminderSectionMutationIdentity(options)
      let sectionTitle =
        try reminderSectionOption(
          try requiredOption("section", options: options)) ?? ""
      let reorder = try reminderSectionReorderPlacement(options, identity: identity)
      let section = try sectionRecord(title: sectionTitle, identity: identity)
      guard section.id != reorder.anchorSection.id else {
        throw CLIError(
          code: .validationError,
          message: "Reminder section cannot be reordered relative to itself.",
          details: ["section": sectionTitle]
        )
      }
      return try mutation(
        operation: "reminders.sections.reorder",
        scopeDigest: reminderSectionMutationScopeDigest(
          identity: identity,
          operation: "reorder",
          sectionTitle: sectionTitle,
          anchorSectionTitle: reorder.anchorSection.title,
          placement: reorder.placement
        ),
        summary: identity.summaryFields.merging(
          reminderSectionMutationSummary(
            operation: "reorder",
            sectionTitle: sectionTitle,
            anchorSectionTitle: reorder.anchorSection.title,
            placement: reorder.placement
          ),
          uniquingKeysWith: { _, new in new }),
        options: options
      ) {
        let sections = try reorderReminderSection(
          list: identity.list,
          sectionTitle: section.title,
          anchorSectionTitle: reorder.anchorSection.title,
          placement: reorder.placement
        )
        return ReminderSectionMutationResult(
          operation: "reminders.sections.reorder",
          changed: true,
          list: identity.list,
          section: sections.first(where: { $0.id == section.id }) ?? section,
          anchorSection: sections.first(where: { $0.id == reorder.anchorSection.id })
            ?? reorder.anchorSection,
          placement: reorder.placement,
          sections: sections
        )
      }
    case ["subtasks", "create"]:
      try validateTargetOptions(options, allowedOptions: ["parent-id", "title"])
      try validateMutationIntent(options)
      let identity = try reminderSubtaskCreateIdentity(options)
      return try mutation(
        operation: "reminders.subtasks.create",
        scopeDigest: reminderSubtaskCreateScopeDigest(identity: identity),
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try createReminderSubtask(
          parent: identity.parent.reminder,
          title: identity.title
        )
        return ReminderSubtaskMutationResult(
          operation: "reminders.subtasks.create",
          changed: true,
          reminder: reminder,
          parentReminder: identity.parent.reminder
        )
      }
    case ["subtasks", "move"]:
      try validateTargetOptions(options, allowedOptions: ["id", "parent-id"])
      try validateMutationIntent(options)
      let identity = try reminderSubtaskMoveIdentity(options, requireParent: true)
      guard let parent = identity.parent else {
        throw CLIError(code: .validationError, message: "`--parent-id` is required.")
      }
      return try mutation(
        operation: "reminders.subtasks.move",
        scopeDigest: reminderSubtaskMoveScopeDigest(identity: identity, operation: "move"),
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try moveReminderSubtask(
          reminder: identity.reminder.reminder,
          parent: parent.reminder
        )
        return ReminderSubtaskMutationResult(
          operation: "reminders.subtasks.move",
          changed: true,
          reminder: reminder,
          parentReminder: parent.reminder
        )
      }
    case ["subtasks", "promote"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let identity = try reminderSubtaskMoveIdentity(options, requireParent: false)
      try validateReminderIsSubtask(identity.reminder.reminder)
      return try mutation(
        operation: "reminders.subtasks.promote",
        scopeDigest: reminderSubtaskMoveScopeDigest(identity: identity, operation: "promote"),
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try promoteReminderSubtask(
          reminder: identity.reminder.reminder
        )
        return ReminderSubtaskMutationResult(
          operation: "reminders.subtasks.promote",
          changed: true,
          reminder: reminder,
          parentReminder: nil
        )
      }
    case ["attachments", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "file"])
      try validateMutationIntent(options)
      let identity = try reminderAttachmentAddIdentity(options)
      guard let filePath = identity.filePath else {
        throw CLIError(code: .validationError, message: "`--file` is required.")
      }
      let fileURL = URL(fileURLWithPath: filePath)
      return try mutation(
        operation: "reminders.attachments.add",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try addReminderAttachment(
          reminder: identity.reminder.reminder,
          fileURL: fileURL
        )
        return ReminderAttachmentMutationResult(
          operation: "reminders.attachments.add",
          changed: true,
          reminder: reminder,
          attachment: reminder.attachments.first {
            reminderAttachmentMatchesFile($0, fileURL: fileURL)
          }
        )
      }
    case ["attachments", "remove"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      try validateMutationIntent(options)
      let identity = try reminderAttachmentRemoveIdentity(options)
      guard let attachment = identity.attachment,
        let selector = identity.attachmentSelector
      else {
        throw CLIError(code: .validationError, message: "`--attachment` is required.")
      }
      return try mutation(
        operation: "reminders.attachments.remove",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try removeReminderAttachment(
          reminder: identity.reminder.reminder,
          attachment: attachment,
          selector: selector
        )
        return ReminderAttachmentMutationResult(
          operation: "reminders.attachments.remove",
          changed: true,
          reminder: reminder,
          attachment: attachment,
          attachmentSelector: selector
        )
      }
    case ["assignments", "assign"]:
      try validateTargetOptions(options, allowedOptions: ["id", "assignee"])
      try validateMutationIntent(options)
      let identity = try reminderAssignmentAssignIdentity(options)
      guard let assigneeSelector = identity.assigneeSelector else {
        throw CLIError(code: .validationError, message: "`--assignee` is required.")
      }
      return try mutation(
        operation: "reminders.assignments.assign",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try assignReminder(
          reminder: identity.reminder.reminder,
          assigneeSelector: assigneeSelector
        )
        return ReminderAssignmentMutationResult(
          operation: "reminders.assignments.assign",
          changed: true,
          reminder: reminder,
          assignment: reminder.assignments.first {
            reminderAssignmentMatchesSelector($0, selector: assigneeSelector)
          },
          assigneeSelector: assigneeSelector
        )
      }
    case ["assignments", "unassign"]:
      try validateTargetOptions(options, allowedOptions: ["id", "assignment"])
      try validateMutationIntent(options)
      let identity = try reminderAssignmentUnassignIdentity(options)
      guard let assignment = identity.assignment else {
        throw CLIError(
          code: .validationError,
          message: "`--assignment` matched no assignment."
        )
      }
      return try mutation(
        operation: "reminders.assignments.unassign",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let reminder = try unassignReminder(
          reminder: identity.reminder.reminder,
          assignment: assignment,
          selector: identity.assignmentSelector
        )
        return ReminderAssignmentMutationResult(
          operation: "reminders.assignments.unassign",
          changed: true,
          reminder: reminder,
          assignment: assignment,
          assignmentSelector: identity.assignmentSelector
        )
      }
    default:
      return nil
    }
  }
}
