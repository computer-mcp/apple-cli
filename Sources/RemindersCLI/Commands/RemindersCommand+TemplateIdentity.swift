import Foundation
import Utility

extension RemindersCommand {
  func reminderTemplate(selector: String, in templates: [ReminderTemplateRecord]) throws
    -> ReminderTemplateRecord
  {
    let idMatches = templates.filter { $0.id == selector }
    if let match = idMatches.first {
      return match
    }

    let titleMatches = templates.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Reminder template selector matched multiple templates.",
        details: ["selector": selector]
      )
    }
    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Reminder template selector did not match any template.",
        details: ["selector": selector]
      )
    }
    return match
  }

  func reminderTemplateSaveIdentity(_ options: CLIOptions) throws
    -> ReminderTemplateSaveIdentity
  {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }
    let title = try reminderRequiredTextOption("title", options: options)
    let includeCompleted = options.hasTargetFlag("include-completed")
    let templates = try listReminderTemplates()
    try validateReminderTemplateDoesNotExist(title: title, sourceList: list, templates: templates)

    let bindingPayload = [
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      "\(list.allowsContentModifications)",
      list.listType ?? "",
      list.smartListType ?? "",
      title,
      "\(includeCompleted)",
      reminderTemplateListSnapshotHash(list: list),
    ].joined(separator: "|")

    return ReminderTemplateSaveIdentity(
      sourceList: list,
      title: title,
      includeCompleted: includeCompleted,
      scopeDigest: "reminder-template-save:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "source_list_id": list.id,
        "source_list_title": list.title,
        "source_id": list.sourceId,
        "source_title": list.sourceTitle,
        "title": title,
        "include_completed": "\(includeCompleted)",
      ]
    )
  }

  func reminderTemplateCreateListIdentity(_ options: CLIOptions) throws
    -> ReminderTemplateCreateListIdentity
  {
    let templates = try listReminderTemplates()
    let template = try reminderTemplate(
      selector: try requiredOption("template", options: options),
      in: templates
    )
    let title = try reminderRequiredTextOption("title", options: options)
    let lists = try listReminderLists()
    try validateReminderTemplateDestinationDoesNotExist(
      title: title,
      template: template,
      lists: lists
    )

    let bindingPayload = [
      template.id,
      template.title,
      template.sourceId,
      template.sourceTitle,
      template.sourceListId ?? "",
      template.sourceListTitle ?? "",
      title,
      reminderListSourceContentsHash(
        source: ReminderListSourceRecord(
          id: template.sourceId,
          title: template.sourceTitle,
          sourceType: "",
          reminderListCount: lists.filter { $0.sourceId == template.sourceId }.count
        ),
        lists: lists
      ),
    ].joined(separator: "|")

    return ReminderTemplateCreateListIdentity(
      template: template,
      title: title,
      scopeDigest: "reminder-template-create-list:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "template_id": template.id,
        "template_title": template.title,
        "source_id": template.sourceId,
        "source_title": template.sourceTitle,
        "title": title,
      ]
    )
  }

  func reminderTemplateUpdateIdentity(_ options: CLIOptions) throws
    -> ReminderTemplateMutationIdentity
  {
    let templates = try listReminderTemplates()
    let template = try reminderTemplate(
      selector: try requiredOption("template", options: options),
      in: templates
    )
    let patch = try reminderTemplateUpdatePatch(options)
    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError,
        message: "At least one reminder template update field is required."
      )
    }
    if let title = patch.title {
      try validateReminderTemplateDoesNotExist(
        title: title,
        existingTemplate: template,
        templates: templates
      )
    }

    let bindingPayload = reminderTemplateBinding(template: template, patch: patch)
    return ReminderTemplateMutationIdentity(
      template: template,
      patch: patch,
      sourceList: nil,
      scopeDigest: "reminder-template-update:\(sha256Hex(bindingPayload))",
      summaryFields: reminderTemplateMutationSummary(template: template, patch: patch)
    )
  }

  func reminderTemplateReplaceIdentity(_ options: CLIOptions) throws
    -> ReminderTemplateMutationIdentity
  {
    let templates = try listReminderTemplates()
    let template = try reminderTemplate(
      selector: try requiredOption("template", options: options),
      in: templates
    )
    let sourceList = try reminderList(selector: try requiredOption("list", options: options))
    guard sourceList.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": sourceList.title]
      )
    }

    let replacementTitle =
      try reminderListTextOption(options.targetOption("title"), optionName: "title")
      ?? template.title
    if replacementTitle.localizedCaseInsensitiveCompare(template.title) != .orderedSame {
      try validateReminderTemplateDoesNotExist(
        title: replacementTitle,
        existingTemplate: template,
        templates: templates
      )
    }

    let patch = ReminderTemplatePatch(
      title: replacementTitle,
      replacementSourceListId: sourceList.id,
      includeCompleted: options.hasTargetFlag("include-completed")
    )
    let bindingPayload = [
      reminderTemplateBinding(template: template, patch: patch),
      sourceList.id,
      sourceList.title,
      sourceList.sourceId,
      sourceList.sourceTitle,
      reminderTemplateListSnapshotHash(list: sourceList),
    ].joined(separator: "|")

    return ReminderTemplateMutationIdentity(
      template: template,
      patch: patch,
      sourceList: sourceList,
      scopeDigest: "reminder-template-replace:\(sha256Hex(bindingPayload))",
      summaryFields: reminderTemplateMutationSummary(template: template, patch: patch).merging(
        [
          "source_list_id": sourceList.id,
          "source_list_title": sourceList.title,
          "include_completed": "\(options.hasTargetFlag("include-completed"))",
        ],
        uniquingKeysWith: { _, new in new }
      )
    )
  }

  func reminderTemplateDeleteIdentity(_ options: CLIOptions) throws
    -> ReminderTemplateMutationIdentity
  {
    let templates = try listReminderTemplates()
    let template = try reminderTemplate(
      selector: try requiredOption("template", options: options),
      in: templates
    )
    let patch = ReminderTemplatePatch()
    let bindingPayload = reminderTemplateBinding(template: template, patch: patch)
    return ReminderTemplateMutationIdentity(
      template: template,
      patch: patch,
      sourceList: nil,
      scopeDigest: "reminder-template-delete:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "template_id": template.id,
        "template_title": template.title,
        "source_id": template.sourceId,
        "source_title": template.sourceTitle,
      ]
    )
  }

  func validateReminderTemplateDoesNotExist(
    title: String,
    sourceList: ReminderListRecord,
    templates: [ReminderTemplateRecord]
  ) throws {
    let matches = templates.filter { template in
      template.sourceId == sourceList.sourceId
        && template.title.localizedCaseInsensitiveCompare(title) == .orderedSame
    }
    guard matches.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Reminder template already exists in the target source.",
        details: ["title": title, "source_id": sourceList.sourceId]
      )
    }
  }

  func validateReminderTemplateDoesNotExist(
    title: String,
    existingTemplate: ReminderTemplateRecord,
    templates: [ReminderTemplateRecord]
  ) throws {
    let matches = templates.filter { template in
      template.id != existingTemplate.id
        && template.sourceId == existingTemplate.sourceId
        && template.title.localizedCaseInsensitiveCompare(title) == .orderedSame
    }
    guard matches.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Reminder template already exists in the target source.",
        details: ["title": title, "source_id": existingTemplate.sourceId]
      )
    }
  }

  func validateReminderTemplateDestinationDoesNotExist(
    title: String,
    template: ReminderTemplateRecord,
    lists: [ReminderListRecord]
  ) throws {
    let matches = lists.filter { list in
      list.sourceId == template.sourceId
        && list.title.localizedCaseInsensitiveCompare(title) == .orderedSame
    }
    guard matches.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list already exists in the template source.",
        details: ["title": title, "source_id": template.sourceId]
      )
    }
  }

  func reminderTemplateListSnapshotHash(list: ReminderListRecord) -> String {
    do {
      let reminders = try listReminders(
        ReminderQuery(listSelector: list.id, completion: .all, limit: 2_000))
      let payload =
        reminders
        .sorted { $0.id < $1.id }
        .map {
          [
            $0.id,
            $0.title,
            String($0.isCompleted),
            $0.sectionId ?? "",
            $0.sectionTitle ?? "",
            $0.parentReminderId ?? "",
          ].joined(separator: "\u{1F}")
        }
        .joined(separator: "\u{1E}")
      return sha256Hex(payload)
    } catch {
      return sha256Hex("\(list.id)|\(list.title)")
    }
  }

  func reminderTemplateUpdatePatch(_ options: CLIOptions) throws -> ReminderTemplatePatch {
    ReminderTemplatePatch(
      title: try reminderListTextOption(options.targetOption("title"), optionName: "title"),
      color: try reminderListTextOption(options.targetOption("color"), optionName: "color"),
      icon: try reminderListIconOption(options.targetOption("icon")),
      sortingStyle: try reminderListSortOption(options.targetOption("sort")),
      showingLargeAttachments: try options.targetOption("show-large-attachments").map {
        try reminderBool($0, optionName: "show-large-attachments")
      }
    )
  }

  func reminderTemplateBinding(
    template: ReminderTemplateRecord,
    patch: ReminderTemplatePatch
  ) -> String {
    var parts: [String] = [
      template.id,
      template.title,
      template.sourceId,
      template.sourceTitle,
      template.sourceListId ?? "",
      template.sourceListTitle ?? "",
      template.sortingStyle ?? "",
      template.showingLargeAttachments.map(String.init) ?? "",
      template.color ?? "",
      template.hasColor.map(String.init) ?? "",
      patch.title ?? "",
      patch.color ?? "",
      patch.icon ?? "",
      patch.sortingStyle ?? "",
      patch.replacementSourceListId ?? "",
    ]
    parts.append(patch.showingLargeAttachments.map { String($0) } ?? "")
    parts.append(patch.includeCompleted.map { String($0) } ?? "")
    return parts.joined(separator: "|")
  }

  func reminderTemplateMutationSummary(
    template: ReminderTemplateRecord,
    patch: ReminderTemplatePatch
  ) -> [String: String] {
    var summary: [String: String] = [
      "template_id": template.id,
      "template_title": template.title,
      "source_id": template.sourceId,
      "source_title": template.sourceTitle,
    ]
    if let currentColor = template.color {
      summary["current_color"] = currentColor
    }
    if let title = patch.title {
      summary["new_title"] = title
    }
    if let color = patch.color {
      summary["color"] = color
    }
    if let icon = patch.icon {
      summary["icon"] = icon
    }
    if let sortingStyle = patch.sortingStyle {
      summary["sorting_style"] = sortingStyle
    }
    if let showingLargeAttachments = patch.showingLargeAttachments {
      summary["show_large_attachments"] = "\(showingLargeAttachments)"
    }
    if let replacementSourceListId = patch.replacementSourceListId {
      summary["replacement_source_list_id"] = replacementSourceListId
    }
    return summary
  }
}
