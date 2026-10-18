import Foundation
import Utility

extension RemindersCommand {
  func reminderSmartListCreateIdentity(_ options: CLIOptions) throws
    -> ReminderSmartListCreateIdentity
  {
    let title = try reminderRequiredTextOption("title", options: options)
    let source = try reminderListSource(selector: options.targetOption("source"))
    let criteria = try reminderSmartListCriteria(options)
    let lists = try listReminderLists()
    try validateReminderListDoesNotExist(title: title, source: source, lists: lists)

    let sourceListHash = reminderListSourceContentsHash(source: source, lists: lists)
    let bindingPayload = [
      title,
      source.id,
      source.title,
      source.sourceType,
      "\(source.reminderListCount)",
      sourceListHash,
      criteria.match,
      criteria.descriptor,
    ].joined(separator: "|")

    return ReminderSmartListCreateIdentity(
      title: title,
      source: source,
      criteria: criteria,
      sourceListHash: sourceListHash,
      scopeDigest: "reminder-smart-list-create:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "title": title,
        "source_id": source.id,
        "source_title": source.title,
        "source_type": source.sourceType,
        "source_list_count": "\(source.reminderListCount)",
        "source_list_sha256": sourceListHash,
        "criteria_match": criteria.match,
        "criteria": criteria.descriptor,
        "criteria_sha256": sha256Hex(criteria.descriptor),
      ]
    )
  }

  func reminderSmartListMutationIdentity(
    _ options: CLIOptions,
    requireCriteria: Bool
  ) throws -> ReminderSmartListMutationIdentity {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    let criteria = requireCriteria ? try reminderSmartListCriteria(options) : nil
    let smartEvidenceHash = try reminderSmartListEvidenceHash(list)

    if requireCriteria, list.listType != "smart" {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is not known to be a Smart List.",
        details: ["list": list.title, "list_type": list.listType ?? ""]
      )
    }
    if !requireCriteria, list.listType == "smart" {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is already a Smart List.",
        details: ["list": list.title]
      )
    }

    let operation = requireCriteria ? "update" : "convert"
    let bindingPayload = [
      operation,
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      list.listType ?? "",
      list.smartListType ?? "",
      smartEvidenceHash,
      criteria?.match ?? "",
      criteria?.descriptor ?? "",
    ].joined(separator: "|")
    var summary = [
      "operation": operation,
      "list_id": list.id,
      "list_title": list.title,
      "source_id": list.sourceId,
      "list_type": list.listType ?? "",
      "smart_list_type": list.smartListType ?? "",
      "smart_list_evidence_sha256": smartEvidenceHash,
    ]
    if let criteria {
      summary["criteria_match"] = criteria.match
      summary["criteria"] = criteria.descriptor
      summary["criteria_sha256"] = sha256Hex(criteria.descriptor)
    }

    return ReminderSmartListMutationIdentity(
      list: list,
      criteria: criteria,
      scopeDigest: "reminder-smart-list-\(operation):\(sha256Hex(bindingPayload))",
      summaryFields: summary
    )
  }

  func reminderSmartListDeleteIdentity(_ options: CLIOptions) throws
    -> ReminderSmartListMutationIdentity
  {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.listType == "smart" else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list is not known to be a Smart List.",
        details: ["list": list.title, "list_type": list.listType ?? ""]
      )
    }
    let smartEvidenceHash = try reminderSmartListEvidenceHash(list)
    let bindingPayload = [
      "delete",
      list.id,
      list.title,
      list.sourceId,
      list.sourceTitle,
      list.listType ?? "",
      list.smartListType ?? "",
      smartEvidenceHash,
    ].joined(separator: "|")

    return ReminderSmartListMutationIdentity(
      list: list,
      criteria: nil,
      scopeDigest: "reminder-smart-list-delete:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "operation": "delete",
        "list_id": list.id,
        "list_title": list.title,
        "source_id": list.sourceId,
        "list_type": list.listType ?? "",
        "smart_list_type": list.smartListType ?? "",
        "smart_list_evidence_sha256": smartEvidenceHash,
      ]
    )
  }

  func reminderSmartListCriteria(_ options: CLIOptions) throws
    -> ReminderSmartListCriteria
  {
    let descriptor = try reminderRequiredTextOption("criteria", options: options)
    let match = try reminderSmartListMatchOption(options.targetOption("match"))
    let criteria = ReminderSmartListCriteria(match: match, descriptor: descriptor)
    _ = try ReminderSmartListFilterEncoder.encode(criteria: criteria)
    return criteria
  }

  func reminderSmartListMatchOption(_ value: String?) throws -> String {
    guard let value else {
      return "all"
    }
    switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "all", "any":
      return value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    default:
      throw CLIError(
        code: .validationError,
        message: "`--match` must be all or any.",
        details: ["match": value]
      )
    }
  }

  func reminderSmartListEvidenceHash(_ list: ReminderListRecord) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    if list.listType == "smart" {
      guard let snapshot = try readReminderSmartListSnapshot(id: list.id),
        snapshot.list.sourceId == list.sourceId else {
        throw CLIError(code: .backendUnavailable, message: "Smart List identity could not be verified.",
          details: ["list_id": list.id])
      }
      let payload = String(decoding: try encoder.encode(snapshot.list), as: UTF8.self)
      return sha256Hex(payload + "|" + (snapshot.filterData?.base64EncodedString() ?? ""))
    }
    return sha256Hex(String(decoding: try encoder.encode(list), as: UTF8.self))
  }
}
