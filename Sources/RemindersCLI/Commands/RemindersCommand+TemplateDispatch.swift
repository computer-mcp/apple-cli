import Foundation
import Utility

extension RemindersCommand {
  func runTemplateCommand(_ options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["templates", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let templates = try listReminderTemplates()
      return try result(
        ReminderTemplatesResponse(templates: templates),
        human: reminderTemplatesHumanOutput(templates),
        options: options
      )
    case ["templates", "save"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["list", "title"],
        allowedFlags: ["include-completed"]
      )
      try validateMutationIntent(options)
      let identity = try reminderTemplateSaveIdentity(options)
      return try mutation(
        operation: "reminders.templates.save",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let template = try saveReminderTemplate(
          sourceList: identity.sourceList,
          title: identity.title,
          includeCompleted: identity.includeCompleted
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.save",
          changed: true,
          template: template
        )
      }
    case ["templates", "create-list"]:
      try validateTargetOptions(options, allowedOptions: ["template", "title"])
      try validateMutationIntent(options)
      let identity = try reminderTemplateCreateListIdentity(options)
      return try mutation(
        operation: "reminders.templates.create-list",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let list = try createReminderListFromTemplate(
          template: identity.template,
          title: identity.title
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.create-list",
          changed: true,
          template: identity.template,
          list: list
        )
      }
    case ["templates", "update"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["template", "title", "color", "icon", "sort", "show-large-attachments"]
      )
      try validateMutationIntent(options)
      let identity = try reminderTemplateUpdateIdentity(options)
      return try mutation(
        operation: "reminders.templates.update",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let template = try updateReminderTemplate(
          template: identity.template,
          patch: identity.patch
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.update",
          changed: true,
          template: template
        )
      }
    case ["templates", "replace"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["template", "list", "title"],
        allowedFlags: ["include-completed"]
      )
      try validateMutationIntent(options)
      let identity = try reminderTemplateReplaceIdentity(options)
      return try mutation(
        operation: "reminders.templates.replace",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        guard let sourceList = identity.sourceList else {
          throw CLIError(
            code: .validationError,
            message: "`templates replace` requires a replacement source list."
          )
        }
        let template = try replaceReminderTemplate(
          template: identity.template,
          sourceList: sourceList,
          title: identity.patch.title ?? identity.template.title,
          includeCompleted: identity.patch.includeCompleted ?? false
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.replace",
          changed: true,
          template: template
        )
      }
    case ["templates", "sections", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["template"])
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let sections = try listReminderTemplateSections(template: template)
      return try result(
        ReminderTemplateSectionsResponse(sections: sections),
        human: reminderTemplateSectionsHumanOutput(sections),
        options: options
      )
    case ["templates", "sections", "add"]:
      try validateTargetOptions(options, allowedOptions: ["template", "title"])
      try validateMutationIntent(options)
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let title = try reminderRequiredTextOption("title", options: options)
      let summary = reminderTemplateContentSummary(
        template: template,
        fields: ["title": title]
      )
      return try mutation(
        operation: "reminders.templates.sections.add",
        scopeDigest: reminderTemplateContentScope("sections-add", summary: summary),
        summary: summary,
        options: options
      ) {
        let section = try addReminderTemplateSection(template: template, title: title)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.sections.add",
          changed: true,
          template: template,
          section: section
        )
      }
    case ["templates", "sections", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["template", "section", "title"])
      try validateMutationIntent(options)
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let sectionSelector = try requiredOption("section", options: options)
      let title = try reminderRequiredTextOption("title", options: options)
      let summary = reminderTemplateContentSummary(
        template: template,
        fields: ["section": sectionSelector, "title": title]
      )
      return try mutation(
        operation: "reminders.templates.sections.rename",
        scopeDigest: reminderTemplateContentScope("sections-rename", summary: summary),
        summary: summary,
        options: options
      ) {
        let section = try renameReminderTemplateSection(
          template: template,
          sectionSelector: sectionSelector,
          title: title
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.sections.rename",
          changed: true,
          template: template,
          section: section
        )
      }
    case ["templates", "sections", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["template", "section"])
      try validateMutationIntent(options)
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let sectionSelector = try requiredOption("section", options: options)
      let summary = reminderTemplateContentSummary(
        template: template,
        fields: ["section": sectionSelector]
      )
      return try mutation(
        operation: "reminders.templates.sections.delete",
        scopeDigest: reminderTemplateContentScope("sections-delete", summary: summary),
        summary: summary,
        options: options
      ) {
        let section = try deleteReminderTemplateSection(
          template: template,
          sectionSelector: sectionSelector
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.sections.delete",
          changed: true,
          template: template,
          section: section
        )
      }
    case ["templates", "sections", "reorder"]:
      try validateTargetOptions(options, allowedOptions: ["template", "section", "before", "after"])
      try validateMutationIntent(options)
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let sectionSelector = try requiredOption("section", options: options)
      let before = try reminderListTextOption(options.targetOption("before"), optionName: "before")
      let after = try reminderListTextOption(options.targetOption("after"), optionName: "after")
      if (before == nil && after == nil) || (before != nil && after != nil) {
        throw CLIError(
          code: .validationError,
          message: "`templates sections reorder` requires exactly one of `--before` or `--after`."
        )
      }
      let anchorSelector = before ?? after ?? ""
      let placement = ReminderSectionReorderPlacement(
        beforeSectionId: before == nil ? nil : anchorSelector,
        afterSectionId: after == nil ? nil : anchorSelector
      )
      let summary = reminderTemplateContentSummary(
        template: template,
        fields: [
          "section": sectionSelector,
          "anchor_section": anchorSelector,
          "placement": placement.relation,
        ]
      )
      return try mutation(
        operation: "reminders.templates.sections.reorder",
        scopeDigest: reminderTemplateContentScope("sections-reorder", summary: summary),
        summary: summary,
        options: options
      ) {
        let sections = try reorderReminderTemplateSection(
          template: template,
          sectionSelector: sectionSelector,
          anchorSectionSelector: anchorSelector,
          placement: placement
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.sections.reorder",
          changed: true,
          template: template,
          section: sections.first(where: { $0.id == sectionSelector || $0.title == sectionSelector })
        )
      }
    case ["templates", "items", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["template"])
      let limit = try commandLimit(options)
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let items = try listReminderTemplateItems(template: template, limit: limit)
      return try result(
        ReminderTemplateItemsResponse(items: items),
        human: items.map { "\($0.id)\t\($0.title)" }.joined(separator: "\n"),
        options: options
      )
    case ["templates", "items", "read"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let item = try readReminderTemplateItemRecord(id: try requiredOption("id", options: options))
      return try result(
        ReminderTemplateItemResponse(item: item),
        human: reminderTemplateItemHumanOutput(item),
        options: options
      )
    case ["templates", "items", "add"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "template", "title", "notes", "url", "due", "location", "location-latitude",
          "location-longitude", "location-radius-meters", "location-proximity",
          "alarm-at", "repeat", "repeat-interval",
          "repeat-count", "repeat-until", "repeat-days-of-week", "repeat-days-of-month",
          "repeat-weekday-positions", "repeat-months-of-year", "repeat-set-positions",
          "priority", "flagged", "tags", "section",
        ])
      try validateMutationIntent(options)
      let template = try reminderTemplate(
        selector: try requiredOption("template", options: options),
        in: listReminderTemplates()
      )
      let input = try reminderTemplateItemCreateInput(options)
      let summary = reminderTemplateContentSummary(
        template: template,
        fields: ["title": input.title].merging(
          reminderTemplateItemPatchSummary(input.patch), uniquingKeysWith: { _, new in new })
      )
      return try mutation(
        operation: "reminders.templates.items.add",
        scopeDigest: reminderTemplateContentScope("items-add", summary: summary),
        summary: summary,
        options: options
      ) {
        let item = try addReminderTemplateItem(
          template: template,
          title: input.title,
          patch: input.patch
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.add",
          changed: true,
          template: template,
          item: item
        )
      }
    case ["templates", "items", "update"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "id", "title", "notes", "url", "due", "location", "location-latitude",
          "location-longitude", "location-radius-meters", "location-proximity",
          "alarm-at", "repeat", "repeat-interval",
          "repeat-count", "repeat-until", "repeat-days-of-week", "repeat-days-of-month",
          "repeat-weekday-positions", "repeat-months-of-year", "repeat-set-positions",
          "priority", "flagged", "tags", "add-tags", "remove-tags", "section",
        ],
        allowedFlags: [
          "clear-notes", "clear-url", "clear-due", "clear-location", "clear-repeat",
          "clear-alarms", "clear-tags",
        ]
      )
      try validateMutationIntent(options)
      let id = try requiredOption("id", options: options)
      let current = try readReminderTemplateItem(id: id)
      let patch = try reminderTemplateItemPatch(options, current: current)
      guard patch.hasChanges else {
        throw CLIError(
          code: .validationError,
          message: "At least one template item update field is required."
        )
      }
      let summary = ["item_id": id].merging(
        reminderTemplateItemPatchSummary(patch), uniquingKeysWith: { _, new in new })
      return try mutation(
        operation: "reminders.templates.items.update",
        scopeDigest: reminderTemplateContentScope("items-update", summary: summary),
        summary: summary,
        options: options
      ) {
        let item = try updateReminderTemplateItem(id: id, patch: patch)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.update",
          changed: true,
          item: item
        )
      }
    case ["templates", "items", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let id = try requiredOption("id", options: options)
      let summary = ["item_id": id]
      return try mutation(
        operation: "reminders.templates.items.delete",
        scopeDigest: reminderTemplateContentScope("items-delete", summary: summary),
        summary: summary,
        options: options
      ) {
        let item = try deleteReminderTemplateItem(id: id)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.delete",
          changed: true,
          item: item
        )
      }
    case ["templates", "items", "attachments", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "file"])
      try validateMutationIntent(options)
      let id = try requiredOption("id", options: options)
      let item = try readReminderTemplateItemRecord(id: id)
      let fileURL = try reminderAttachmentFileURL(options)
      let signature = try reminderAttachmentFileSignature(fileURL)
      let attachmentsHash = reminderAttachmentEvidenceHash(item.attachments)
      let summary = reminderTemplateItemContentSummary(
        item: item,
        fields: [
          "operation": "add",
          "file_path": fileURL.path,
          "file_name": fileURL.lastPathComponent,
          "file_size_bytes": "\(signature.sizeBytes)",
          "file_sha256": signature.sha256,
          "attachment_count": "\(item.attachments.count)",
          "attachments_sha256": attachmentsHash,
        ]
      )
      return try mutation(
        operation: "reminders.templates.items.attachments.add",
        scopeDigest: reminderTemplateContentScope("items-attachments-add", summary: summary),
        summary: summary,
        options: options
      ) {
        let changedItem = try addReminderTemplateItemAttachment(id: id, fileURL: fileURL)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.attachments.add",
          changed: true,
          item: changedItem
        )
      }
    case ["templates", "items", "attachments", "remove"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      try validateMutationIntent(options)
      let id = try requiredOption("id", options: options)
      let item = try readReminderTemplateItemRecord(id: id)
      let selector = try reminderRequiredTextOption("attachment", options: options)
      let attachment = try reminderAttachment(selector: selector, in: item.attachments)
      let attachmentsHash = reminderAttachmentEvidenceHash(item.attachments)
      let summary = reminderTemplateItemContentSummary(
        item: item,
        fields: [
          "operation": "remove",
          "attachment_selector": selector,
          "attachment_kind": attachment.kind,
          "attachment_type_identifier": attachment.typeIdentifier ?? "",
          "attachment_file_name": attachment.fileName ?? "",
          "attachment_url": attachment.url ?? "",
          "attachment_count": "\(item.attachments.count)",
          "attachments_sha256": attachmentsHash,
        ]
      )
      return try mutation(
        operation: "reminders.templates.items.attachments.remove",
        scopeDigest: reminderTemplateContentScope("items-attachments-remove", summary: summary),
        summary: summary,
        options: options
      ) {
        let changedItem = try removeReminderTemplateItemAttachment(
          id: id,
          attachment: attachment,
          selector: selector
        )
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.attachments.remove",
          changed: true,
          item: changedItem
        )
      }
    case ["templates", "items", "subtasks", "create"]:
      try validateTargetOptions(options, allowedOptions: ["parent-id", "title"])
      try validateMutationIntent(options)
      let parentID = try requiredOption("parent-id", options: options)
      let title = try reminderRequiredTextOption("title", options: options)
      let parent = try readReminderTemplateItemRecord(id: parentID)
      try validateReminderTemplateItemCanBeParent(parent)
      let summary = reminderTemplateItemContentSummary(
        item: parent,
        fields: [
          "operation": "create",
          "parent_item_id": parent.id,
          "parent_item_title": parent.title,
          "title": title,
        ]
      )
      return try mutation(
        operation: "reminders.templates.items.subtasks.create",
        scopeDigest: reminderTemplateContentScope("items-subtasks-create", summary: summary),
        summary: summary,
        options: options
      ) {
        let item = try createReminderTemplateItemSubtask(parentID: parentID, title: title)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.subtasks.create",
          changed: true,
          item: item
        )
      }
    case ["templates", "items", "subtasks", "move"]:
      try validateTargetOptions(options, allowedOptions: ["id", "parent-id"])
      try validateMutationIntent(options)
      let id = try requiredOption("id", options: options)
      let parentID = try requiredOption("parent-id", options: options)
      guard id != parentID else {
        throw CLIError(
          code: .validationError,
          message: "Template item cannot be made a subtask of itself.",
          details: ["id": id]
        )
      }
      let item = try readReminderTemplateItemRecord(id: id)
      let parent = try readReminderTemplateItemRecord(id: parentID)
      try validateReminderTemplateItemsShareTemplate(item, parent)
      try validateReminderTemplateItemCanBeParent(parent)
      let summary = reminderTemplateItemContentSummary(
        item: item,
        fields: [
          "operation": "move",
          "parent_item_id": parent.id,
          "parent_item_title": parent.title,
          "current_parent_id": item.parentReminderId ?? "",
          "current_parent_title": item.parentReminderTitle ?? "",
        ]
      )
      return try mutation(
        operation: "reminders.templates.items.subtasks.move",
        scopeDigest: reminderTemplateContentScope("items-subtasks-move", summary: summary),
        summary: summary,
        options: options
      ) {
        let changedItem = try moveReminderTemplateItemSubtask(id: id, parentID: parentID)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.subtasks.move",
          changed: true,
          item: changedItem
        )
      }
    case ["templates", "items", "subtasks", "promote"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let id = try requiredOption("id", options: options)
      let item = try readReminderTemplateItemRecord(id: id)
      try validateReminderTemplateItemIsSubtask(item)
      let summary = reminderTemplateItemContentSummary(
        item: item,
        fields: [
          "operation": "promote",
          "current_parent_id": item.parentReminderId ?? "",
          "current_parent_title": item.parentReminderTitle ?? "",
        ]
      )
      return try mutation(
        operation: "reminders.templates.items.subtasks.promote",
        scopeDigest: reminderTemplateContentScope("items-subtasks-promote", summary: summary),
        summary: summary,
        options: options
      ) {
        let changedItem = try promoteReminderTemplateItemSubtask(id: id)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.items.subtasks.promote",
          changed: true,
          item: changedItem
        )
      }
    case ["templates", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["template"])
      try validateMutationIntent(options)
      let identity = try reminderTemplateDeleteIdentity(options)
      return try mutation(
        operation: "reminders.templates.delete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let changed = try deleteReminderTemplate(template: identity.template)
        return ReminderTemplateMutationResult(
          operation: "reminders.templates.delete",
          changed: changed,
          template: identity.template
        )
      }
    default:
      return nil
    }
  }

  private func reminderTemplateContentSummary(
    template: ReminderTemplateRecord,
    fields: [String: String]
  ) -> [String: String] {
    [
      "template_id": template.id,
      "template_title": template.title,
      "source_id": template.sourceId,
      "source_title": template.sourceTitle,
    ].merging(fields, uniquingKeysWith: { _, new in new })
  }

  private func reminderTemplateContentScope(
    _ operation: String,
    summary: [String: String]
  ) -> String {
    let payload = summary
      .sorted { $0.key < $1.key }
      .map { "\($0.key)=\($0.value)" }
      .joined(separator: "|")
    return "reminder-template-\(operation):\(sha256Hex(payload))"
  }

  private func reminderTemplateItemContentSummary(
    item: ReminderTemplateItemRecord,
    fields: [String: String]
  ) -> [String: String] {
    [
      "item_id": item.id,
      "item_title": item.title,
      "template_id": item.templateId,
      "section_id": item.sectionId ?? "",
      "section_title": item.sectionTitle ?? "",
    ].merging(fields, uniquingKeysWith: { _, new in new })
  }

  private func validateReminderTemplateItemCanBeParent(
    _ item: ReminderTemplateItemRecord
  ) throws {
    guard item.parentReminderId == nil && item.parentReminderTitle == nil else {
      throw CLIError(
        code: .validationError,
        message: "Nested template subtasks are not supported.",
        details: ["parent_item_id": item.id, "parent_item_title": item.title]
      )
    }
  }

  private func validateReminderTemplateItemIsSubtask(
    _ item: ReminderTemplateItemRecord
  ) throws {
    guard item.parentReminderId != nil || item.parentReminderTitle != nil else {
      throw CLIError(
        code: .validationError,
        message: "Template item is not a subtask.",
        details: ["item_id": item.id, "item_title": item.title]
      )
    }
  }

  private func validateReminderTemplateItemsShareTemplate(
    _ item: ReminderTemplateItemRecord,
    _ parent: ReminderTemplateItemRecord
  ) throws {
    guard item.templateId == parent.templateId else {
      throw CLIError(
        code: .validationError,
        message: "Template subtask items must belong to the same template.",
        details: [
          "item_id": item.id,
          "item_template_id": item.templateId,
          "parent_item_id": parent.id,
          "parent_template_id": parent.templateId,
        ]
      )
    }
  }

  private func reminderTemplateItemPatchSummary(_ patch: ReminderPatch) -> [String: String] {
    var summary = reminderPatchSummary(patch)
    for key in [
      "new_list_id",
      "new_early_reminder_minutes_before",
      "clear_early_reminders",
      "new_urgent",
      "messaging_person_changed",
      "new_messaging_person",
      "clear_messaging_person",
    ] {
      summary.removeValue(forKey: key)
    }
    return summary
  }
}
