import Foundation
import Utility

extension RemindersCommand {
  func reminderList(selector: String) throws -> ReminderListRecord {
    let lists = try listReminderLists()
    return try reminderList(selector: selector, in: lists)
  }

  func reminderList(selector: String, in lists: [ReminderListRecord]) throws
    -> ReminderListRecord
  {
    let idMatches = lists.filter { $0.id == selector }
    if let match = idMatches.first {
      return match
    }

    let titleMatches = lists.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity, message: "Reminder list selector matched multiple lists.",
        details: ["selector": selector])
    }
    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound, message: "Reminder list selector did not match any list.",
        details: ["selector": selector])
    }
    return match
  }

  func reminderListMutationIdentity(_ options: CLIOptions) throws
    -> ReminderListMutationIdentity
  {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }

    let bindingFields: [String] = [
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      "\(list.allowsContentModifications)",
      list.listType ?? "",
      list.smartListType ?? "",
      list.isPinned.map(String.init) ?? "",
      list.displayOrder.map(String.init) ?? "",
      list.sortingStyle ?? "",
      list.showingLargeAttachments.map(String.init) ?? "",
      list.color ?? "",
      list.hasColor.map(String.init) ?? "",
    ]
    let bindingPayload = bindingFields.joined(separator: "|")

    return ReminderListMutationIdentity(
      list: list,
      scopeDigest: "reminder-list:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "list_id": list.id,
        "list_title": list.title,
        "source_id": list.sourceId,
        "list_type": list.listType ?? "",
        "smart_list_type": list.smartListType ?? "",
        "pinned": list.isPinned.map(String.init) ?? "",
        "display_order": list.displayOrder.map(String.init) ?? "",
        "sorting_style": list.sortingStyle ?? "",
        "show_large_attachments": list.showingLargeAttachments.map(String.init) ?? "",
        "color": list.color ?? "",
        "has_color": list.hasColor.map(String.init) ?? "",
      ]
    )
  }

  func reminderListCreateIdentity(_ options: CLIOptions) throws
    -> ReminderListCreateIdentity
  {
    let title = try reminderRequiredTextOption("title", options: options)
    let source = try reminderListSource(selector: options.targetOption("source"))
    let lists = try listReminderLists()
    try validateReminderListDoesNotExist(title: title, source: source, lists: lists)

    let sourceListHash = reminderListSourceContentsHash(source: source, lists: lists)
    let bindingFields: [String] = [
      title,
      source.id,
      source.title,
      source.sourceType,
      "\(source.reminderListCount)",
      sourceListHash,
    ]
    let bindingPayload = bindingFields.joined(separator: "|")

    return ReminderListCreateIdentity(
      title: title,
      source: source,
      scopeDigest: "reminder-list-source:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "title": title,
        "source_id": source.id,
        "source_title": source.title,
        "source_type": source.sourceType,
        "source_list_count": "\(source.reminderListCount)",
        "source_list_sha256": sourceListHash,
      ]
    )
  }

  func reminderListSource(selector: String?) throws -> ReminderListSourceRecord {
    guard let selector, !selector.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return try defaultReminderListSource()
    }

    let sources = try listReminderListSources()
    let idMatches = sources.filter { $0.id == selector }
    if let match = idMatches.first {
      return match
    }

    let titleMatches = sources.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Reminder list source selector matched multiple sources.",
        details: ["selector": selector]
      )
    }
    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Reminder list source selector did not match any source.",
        details: ["selector": selector]
      )
    }
    return match
  }

  func validateReminderListDoesNotExist(
    title: String,
    source: ReminderListSourceRecord,
    lists: [ReminderListRecord]
  ) throws {
    let matches = lists.filter { list in
      let sameSource =
        list.sourceId == source.id
        || (list.sourceId.isEmpty
          && list.sourceTitle.localizedCaseInsensitiveCompare(source.title) == .orderedSame)
      return sameSource && list.title.localizedCaseInsensitiveCompare(title) == .orderedSame
    }
    guard matches.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list already exists in the target source.",
        details: ["title": title, "source_id": source.id, "source_title": source.title]
      )
    }
  }

  func reminderListSourceContentsHash(
    source: ReminderListSourceRecord,
    lists: [ReminderListRecord]
  ) -> String {
    let payload =
      lists
      .filter { list in
        list.sourceId == source.id
          || (list.sourceId.isEmpty
            && list.sourceTitle.localizedCaseInsensitiveCompare(source.title) == .orderedSame)
      }
      .sorted { $0.id < $1.id }
      .map { list in
        [
          list.id,
          list.title,
          list.sourceId,
          list.sourceTitle,
          "\(list.allowsContentModifications)",
          list.listType ?? "",
          list.smartListType ?? "",
        ].joined(separator: "\u{1F}")
      }
      .joined(separator: "\u{1E}")
    return sha256Hex(payload)
  }

  func reminderListReorderIdentity(_ options: CLIOptions) throws
    -> ReminderListReorderIdentity
  {
    let before = options.targetOption("before")
    let after = options.targetOption("after")
    if (before == nil && after == nil) || (before != nil && after != nil) {
      throw CLIError(
        code: .validationError,
        message: "`lists reorder` requires exactly one of `--before` or `--after`."
      )
    }

    let lists = try listReminderLists()
    let list = try reminderList(selector: try requiredOption("list", options: options), in: lists)
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }
    let anchorSelector = before ?? after ?? ""
    let anchorList = try reminderList(selector: anchorSelector, in: lists)
    guard list.id != anchorList.id else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list cannot be reordered relative to itself.",
        details: ["list": list.title]
      )
    }

    let placement = ReminderListReorderPlacement(
      beforeListId: before == nil ? nil : anchorList.id,
      afterListId: after == nil ? nil : anchorList.id
    )
    let orderHash = reminderListOrderHash(lists)
    let bindingPayload = [
      orderHash,
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      list.displayOrder.map(String.init) ?? "",
      anchorList.id,
      anchorList.title,
      anchorList.sourceId,
      anchorList.sourceTitle,
      anchorList.displayOrder.map(String.init) ?? "",
      placement.relation,
    ].joined(separator: "|")

    return ReminderListReorderIdentity(
      list: list,
      anchorList: anchorList,
      placement: placement,
      scopeDigest: "reminder-list-order:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "list_id": list.id,
        "list_title": list.title,
        "source_id": list.sourceId,
        "anchor_list_id": anchorList.id,
        "anchor_list_title": anchorList.title,
        "anchor_source_id": anchorList.sourceId,
        "placement": placement.relation,
        "list_order_sha256": orderHash,
      ]
    )
  }

  func reminderListDeleteIdentity(_ options: CLIOptions) throws
    -> ReminderListDeleteIdentity
  {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": list.title]
      )
    }

    let reminders = try listReminders(
      ReminderQuery(
        listSelector: list.id,
        completion: .all,
        limit: reminderListDeleteSnapshotLimit + 1
      )
    )
    guard reminders.count <= reminderListDeleteSnapshotLimit else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message:
          "Reminder list delete matched more than 500 reminders. Move or delete reminders first.",
        details: [
          "list_id": list.id,
          "list_title": list.title,
          "snapshot_limit": "\(reminderListDeleteSnapshotLimit)",
        ]
      )
    }

    let reminderSnapshotHash = reminderListDeleteReminderSnapshotHash(reminders)
    let bindingFields: [String] = [
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      "\(list.allowsContentModifications)",
      list.listType ?? "",
      list.smartListType ?? "",
      list.isPinned.map(String.init) ?? "",
      list.displayOrder.map(String.init) ?? "",
      list.sortingStyle ?? "",
      list.showingLargeAttachments.map(String.init) ?? "",
      list.color ?? "",
      list.hasColor.map(String.init) ?? "",
      "\(reminders.count)",
      reminderSnapshotHash,
    ]
    let bindingPayload = bindingFields.joined(separator: "|")

    return ReminderListDeleteIdentity(
      list: list,
      reminderCount: reminders.count,
      reminderSnapshotHash: reminderSnapshotHash,
      scopeDigest: "reminder-list-delete:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "list_id": list.id,
        "list_title": list.title,
        "source_id": list.sourceId,
        "list_type": list.listType ?? "",
        "smart_list_type": list.smartListType ?? "",
        "reminder_count": "\(reminders.count)",
        "reminder_snapshot_sha256": reminderSnapshotHash,
      ]
    )
  }

  func reminderListPatch(_ options: CLIOptions) throws -> ReminderListPatch {
    ReminderListPatch(
      title: try reminderListTextOption(options.targetOption("title"), optionName: "title"),
      listType: try reminderListTypeOption(options.targetOption("type")),
      color: try reminderListTextOption(options.targetOption("color"), optionName: "color"),
      icon: try reminderListIconOption(options.targetOption("icon")),
      pinned: try options.targetOption("pinned").map {
        try reminderBool($0, optionName: "pinned")
      },
      sortingStyle: try reminderListSortOption(options.targetOption("sort")),
      showingLargeAttachments: try options.targetOption("show-large-attachments").map {
        try reminderBool($0, optionName: "show-large-attachments")
      }
    )
  }
}
