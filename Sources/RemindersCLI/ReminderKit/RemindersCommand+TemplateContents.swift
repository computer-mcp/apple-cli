import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension RemindersCommand {
  public func listReminderTemplateSections(template: ReminderTemplateRecord) throws
    -> [ReminderTemplateSectionRecord]
  {
    let operation = "templates-sections-list"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: template.id, operation: operation)
    return try coreTemplateSections(
      store: store,
      template: resolved.template,
      operation: operation
    ).map {
      coreReminderTemplateSectionRecord($0, template: resolved.template)
    }
  }

  public func addReminderTemplateSection(
    template: ReminderTemplateRecord,
    title: String
  ) throws -> ReminderTemplateSectionRecord {
    let operation = "templates-sections-add"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: template.id, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)
    let existingSections = try coreTemplateSections(
      store: store,
      template: resolved.template,
      operation: operation
    )

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let templateChange = saveRequest.updateTemplate(resolved.template) as? REMTemplateChangeItem,
      let sectionContext = templateChange.sectionsContextChangeItem,
      let sectionChange = saveRequest.addTemplateSection(
        withDisplayName: title,
        toTemplateSectionContextChangeItem: sectionContext
      ) as? REMTemplateSectionChangeItem,
      let newSectionID = sectionChange.remObjectID
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template section change item could not be created.",
        details: ["template_id": template.id, "title": title]
      )
    }

    let reorderedIDs = try coreTemplateSectionObjectIDs(existingSections) + [newSectionID]
    sectionContext.unsavedSectionIDsOrdering = reorderedIDs
    sectionContext.shouldUpdateSectionsOrdering = true
    templateChange.unsavedSectionIDsOrdering = reorderedIDs
    templateChange.shouldUpdateSectionsOrdering = true
    try coreSaveReminderKit(saveRequest, operation: operation)

    return try coreReminderTemplateSectionRecord(
      store: store,
      templateID: template.id,
      sectionID: newSectionID,
      operation: operation
    )
  }

  public func renameReminderTemplateSection(
    template: ReminderTemplateRecord,
    sectionSelector: String,
    title: String
  ) throws -> ReminderTemplateSectionRecord {
    let operation = "templates-sections-rename"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: template.id, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)
    let section = try coreResolveTemplateSection(
      store: store,
      template: resolved.template,
      selector: sectionSelector,
      operation: operation
    )

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateTemplateSection(section) as? REMTemplateSectionChangeItem
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template section change item could not be updated.",
        details: ["template_id": template.id, "section": sectionSelector]
      )
    }
    change.displayName = title
    try coreSaveReminderKit(saveRequest, operation: operation)

    return try coreReminderTemplateSectionRecord(
      store: store,
      templateID: template.id,
      sectionID: section.remObjectID,
      operation: operation
    )
  }

  public func deleteReminderTemplateSection(
    template: ReminderTemplateRecord,
    sectionSelector: String
  ) throws -> ReminderTemplateSectionRecord {
    let operation = "templates-sections-delete"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: template.id, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)
    let section = try coreResolveTemplateSection(
      store: store,
      template: resolved.template,
      selector: sectionSelector,
      operation: operation
    )
    let record = coreReminderTemplateSectionRecord(section, template: resolved.template)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateTemplateSection(section) as? REMTemplateSectionChangeItem
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template section change item could not be updated.",
        details: ["template_id": template.id, "section": sectionSelector]
      )
    }
    change.removeFromParentTemplate()
    try coreSaveReminderKit(saveRequest, operation: operation)
    return record
  }

  public func reorderReminderTemplateSection(
    template: ReminderTemplateRecord,
    sectionSelector: String,
    anchorSectionSelector: String,
    placement: ReminderSectionReorderPlacement
  ) throws -> [ReminderTemplateSectionRecord] {
    let operation = "templates-sections-reorder"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: template.id, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)
    let sections = try coreTemplateSections(store: store, template: resolved.template, operation: operation)
    let section = try coreResolveTemplateSection(
      sections: sections,
      selector: sectionSelector,
      operation: operation
    )
    let anchor = try coreResolveTemplateSection(
      sections: sections,
      selector: anchorSectionSelector,
      operation: operation
    )
    let sectionID = try coreTemplateSectionObjectID(section, operation: operation)
    let anchorID = try coreTemplateSectionObjectID(anchor, operation: operation)
    guard !coreObjectIDsMatch(sectionID, anchorID) else {
      throw CLIError(
        code: .validationError,
        message: "Reminder template section cannot be reordered relative to itself.",
        details: ["section": sectionSelector]
      )
    }

    var reorderedSections = sections.filter {
      !coreObjectIDsMatch($0.remObjectID, sectionID)
    }
    guard
      let anchorIndex = reorderedSections.firstIndex(where: {
        coreObjectIDsMatch($0.remObjectID, anchorID)
      })
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template section reorder anchor disappeared.",
        details: ["anchor_section": anchorSectionSelector]
      )
    }

    let insertionIndex = placement.beforeSectionId != nil ? anchorIndex : anchorIndex + 1
    reorderedSections.insert(section, at: insertionIndex)
    let reorderedIDs = try coreTemplateSectionObjectIDs(reorderedSections)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let templateChange = saveRequest.updateTemplate(resolved.template) as? REMTemplateChangeItem,
      let sectionContext = templateChange.sectionsContextChangeItem
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template section context could not be updated.",
        details: ["template_id": template.id]
      )
    }
    sectionContext.unsavedSectionIDsOrdering = reorderedIDs
    sectionContext.shouldUpdateSectionsOrdering = true
    templateChange.unsavedSectionIDsOrdering = reorderedIDs
    templateChange.shouldUpdateSectionsOrdering = true
    try coreSaveReminderKit(saveRequest, operation: operation)

    return try coreTemplateSections(
      store: store,
      template: resolved.template,
      operation: operation
    ).map {
      coreReminderTemplateSectionRecord($0, template: resolved.template)
    }
  }

  public func addReminderTemplateItem(
    template: ReminderTemplateRecord,
    title: String,
    patch: ReminderPatch
  ) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-add"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: template.id, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)
    let representation = try coreTemplateListRepresentation(
      store: store,
      template: resolved.template,
      operation: operation
    )

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard
      let listChange = saveRequest.updateList(representation) as? REMListChangeItem,
      let reminderChange = saveRequest.addReminder(
        withTitle: title,
        toListChangeItem: listChange
      ) as? REMReminderChangeItem,
      let savedObjectID = reminderChange.remObjectID
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template item change item could not be created.",
        details: ["template_id": template.id, "title": title]
      )
    }
    try coreApplyTemplateItemPatch(patch, to: reminderChange, operation: operation)
    if let sectionTitle = patch.sectionTitle {
      try coreApplyTemplateItemSectionMembership(
        store: store,
        saveRequest: saveRequest,
        template: resolved.template,
        reminderObjectID: savedObjectID,
        sectionSelector: sectionTitle,
        operation: operation
      )
    }
    try coreSaveReminderKit(saveRequest, operation: operation)
    return try coreReminderTemplateItemRecord(
      store: store,
      objectID: savedObjectID,
      operation: operation
    )
  }

  public func updateReminderTemplateItem(
    id: String,
    patch: ReminderPatch
  ) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-update"
    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError,
        message: "At least one template item update field is required."
      )
    }
    let store = try coreReminderKitStore(operation: operation)
    let reminder = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template item change item could not be updated.",
        details: ["id": id]
      )
    }
    try coreApplyTemplateItemPatch(patch, to: change, operation: operation)
    if let sectionTitle = patch.sectionTitle {
      let templateID = coreObjectIDString(reminder.listID)
      let resolved = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
      try coreApplyTemplateItemSectionMembership(
        store: store,
        saveRequest: saveRequest,
        template: resolved.template,
        reminderObjectID: reminder.remObjectID,
        sectionSelector: sectionTitle,
        operation: operation
      )
    }
    try coreSaveReminderKit(saveRequest, operation: operation)
    return try coreReminderTemplateItemRecord(
      store: store,
      objectID: reminder.remObjectID,
      operation: operation
    )
  }

  public func deleteReminderTemplateItem(id: String) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-delete"
    let store = try coreReminderKitStore(operation: operation)
    let reminder = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    let record = coreReminderTemplateItemRecord(reminder)
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template item change item could not be updated.",
        details: ["id": id]
      )
    }
    change.removeFromList()
    try coreSaveReminderKit(saveRequest, operation: operation)
    return record
  }

  public func readReminderTemplateItem(id: String) throws -> ReminderDetail {
    let operation = "templates-items-read"
    let store = try coreReminderKitStore(operation: operation)
    let reminder = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    return coreReminderDetail(reminder)
  }

  public func readReminderTemplateItemRecord(id: String) throws -> ReminderTemplateItemRecord {
    let operation = "templates-items-read"
    let store = try coreReminderKitStore(operation: operation)
    let reminder = try coreFetchTemplateSavedReminder(store: store, id: id, operation: operation)
    return coreReminderTemplateItemRecord(reminder)
  }
}

private func coreTemplateSections(
  store: REMStore,
  template: REMTemplate,
  operation: String
) throws -> [REMTemplateSection] {
  guard let context = template.sectionContext else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template section context was unavailable.",
      details: ["template_id": coreObjectIDString(template.remObjectID)]
    )
  }
  var error: AnyObject?
  guard
    let sections = store.fetchTemplateSections(
      forTemplateSectionContext: context,
      error: &error
    ) as? [REMTemplateSection]
  else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template sections could not be fetched.",
      details: [
        "template_id": coreObjectIDString(template.remObjectID),
        "fetch_error": reminderKitErrorSummary(error),
      ]
    )
  }
  return sections
}

private func coreResolveTemplateSection(
  store: REMStore,
  template: REMTemplate,
  selector: String,
  operation: String
) throws -> REMTemplateSection {
  let sections = try coreTemplateSections(store: store, template: template, operation: operation)
  return try coreResolveTemplateSection(
    sections: sections,
    selector: selector,
    operation: operation
  )
}

private func coreResolveTemplateSection(
  sections: [REMTemplateSection],
  selector: String,
  operation: String
) throws -> REMTemplateSection {
  let matches = sections.filter {
    coreObjectIDString($0.remObjectID) == selector
      || ($0.displayName ?? "").localizedCaseInsensitiveCompare(selector) == .orderedSame
  }
  if let match = matches.first, matches.count == 1 {
    return match
  }
  if matches.count > 1 {
    throw CLIError(
      code: .ambiguousIdentity,
      message: "Reminder template section selector matched multiple sections.",
      details: ["selector": selector]
    )
  }
  throw CLIError(
    code: .notFound,
    message: "Reminder template section was not found.",
    details: ["selector": selector]
  )
}

private func coreTemplateSectionObjectIDs(_ sections: [REMTemplateSection]) throws -> [REMObjectID] {
  try sections.map {
    try coreTemplateSectionObjectID($0, operation: "templates-sections")
  }
}

private func coreTemplateSectionObjectID(
  _ section: REMTemplateSection,
  operation: String
) throws -> REMObjectID {
  guard let objectID = section.remObjectID else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template section object ID was unavailable."
    )
  }
  return objectID
}

private func coreObjectIDsMatch(_ lhs: REMObjectID?, _ rhs: REMObjectID?) -> Bool {
  guard let lhs, let rhs else {
    return lhs == nil && rhs == nil
  }
  return lhs.uuid == rhs.uuid || lhs.urlRepresentation == rhs.urlRepresentation
}

private func coreReminderTemplateSectionRecord(
  _ section: REMTemplateSection,
  template: REMTemplate
) -> ReminderTemplateSectionRecord {
  ReminderTemplateSectionRecord(
    id: coreObjectIDString(section.remObjectID),
    title: section.displayName ?? "",
    templateId: coreObjectIDString(template.remObjectID),
    templateTitle: template.name ?? ""
  )
}

private func coreReminderTemplateSectionRecord(
  store: REMStore,
  templateID: String,
  sectionID: REMObjectID?,
  operation: String
) throws -> ReminderTemplateSectionRecord {
  guard let sectionID else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template section object ID was unavailable."
    )
  }
  let resolved = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
  let sections = try coreTemplateSections(store: store, template: resolved.template, operation: operation)
  guard let section = sections.first(where: { coreObjectIDString($0.remObjectID) == coreObjectIDString(sectionID) })
  else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template section was not present after mutation.",
      details: ["section_id": coreObjectIDString(sectionID)]
    )
  }
  return coreReminderTemplateSectionRecord(section, template: resolved.template)
}

private func coreTemplateListRepresentation(
  store: REMStore,
  template: REMTemplate,
  operation: String
) throws -> REMList {
  guard let dataView = REMListsDataView(store: store) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit lists data view could not be created."
    )
  }
  var error: AnyObject?
  guard
    let representation = dataView.fetchListRepresentationOfTemplate(
      withObjectID: template.remObjectID,
      error: &error
    ) as? REMList
  else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template list representation could not be fetched.",
      details: [
        "template_id": coreObjectIDString(template.remObjectID),
        "fetch_error": reminderKitErrorSummary(error),
      ]
    )
  }
  return representation
}

func coreFetchTemplateSavedReminder(
  store: REMStore,
  id: String,
  operation: String
) throws -> REMReminder {
  guard let objectID = coreREMObjectID(entity: "REMCDSavedReminder", identifier: id) else {
    throw CLIError(
      code: .validationError,
      message: "Template item ID was not a valid ReminderKit saved reminder ID.",
      details: ["id": id]
    )
  }
  guard let dataView = REMRemindersDataView(store: store) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit reminders data view could not be created."
    )
  }
  var error: AnyObject?
  let options = REMReminderFetchOptions.defaultFetchOptions() as? REMReminderFetchOptions
  guard
    let reminder = dataView.fetchReminder(
      withObjectID: objectID,
      fetchOptions: options,
      error: &error
    ) as? REMReminder
  else {
    throw CLIError(
      code: .notFound,
      message: "Reminder template item was not found.",
      details: [
        "id": id,
        "fetch_error": reminderKitErrorSummary(error),
      ]
    )
  }
  return reminder
}

func coreReminderTemplateItemRecord(
  store: REMStore,
  objectID: REMObjectID?,
  operation: String
) throws -> ReminderTemplateItemRecord {
  guard let objectID else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item object ID was unavailable."
    )
  }
  let reminder = try coreFetchTemplateSavedReminder(
    store: store,
    id: coreObjectIDString(objectID),
    operation: operation
  )
  return coreReminderTemplateItemRecord(reminder)
}

func coreReminderTemplateItemRecord(_ reminder: REMReminder) -> ReminderTemplateItemRecord {
  let detail = coreReminderDetail(reminder)
  return ReminderTemplateItemRecord(
    id: detail.id,
    title: detail.title,
    notes: detail.notes,
    templateId: coreObjectIDString(reminder.listID),
    url: detail.url,
    priority: detail.priority,
    dueDate: detail.dueDate,
    dueDateKind: detail.dueDateKind,
    repeatRule: detail.repeatRule,
    locationTriggers: detail.locationTriggers,
    earlyReminderMinutesBefore: detail.earlyReminderMinutesBefore,
    absoluteAlarmDates: detail.absoluteAlarmDates,
    tags: coreTemplateItemTags(reminder),
    isFlagged: detail.isFlagged,
    isUrgent: detail.isUrgent,
    sectionId: detail.sectionId,
    sectionTitle: detail.sectionTitle,
    parentReminderId: detail.parentReminderId,
    parentReminderTitle: detail.parentReminderTitle,
    subtaskCount: coreTemplateItemSubtaskCount(reminder),
    attachments: coreTemplateItemAttachments(reminder)
  )
}

private func coreApplyTemplateItemPatch(
  _ patch: ReminderPatch,
  to change: REMReminderChangeItem,
  operation: String
) throws {
  if patch.earlyReminderMinutesBefore != nil || patch.clearEarlyReminders {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item early reminders are not supported by the current implementation."
    )
  }
  if patch.urgent != nil {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item urgent state is not supported by the current implementation."
    )
  }
  try coreApplyPatch(patch, to: change)

  if let url = patch.url {
    try coreSetTemplateItemVisibleURL(url, on: change, operation: operation)
  } else if patch.clearUrl {
    try coreSetTemplateItemVisibleURL(nil, on: change, operation: operation)
  }

  if let flagged = patch.flagged {
    change.flagged = flagged ? 1 : 0
  }

  if patch.hasTagChanges {
    try coreApplyTemplateItemTags(patch, to: change, operation: operation)
  }

}

private func coreSetTemplateItemVisibleURL(
  _ url: String?,
  on change: REMReminderChangeItem,
  operation: String
) throws {
  guard let attachmentContext = change.attachmentContext else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item attachment context was unavailable."
    )
  }
  if let url {
    guard let parsedURL = URL(string: url), parsedURL.scheme != nil else {
      throw CLIError(
        code: .validationError,
        message: "`--url` must be an absolute URL.",
        details: ["url": url]
      )
    }
    _ = attachmentContext.setURLAttachmentWithURL(parsedURL)
  } else {
    attachmentContext.removeURLAttachments()
  }
}

private func coreApplyTemplateItemTags(
  _ patch: ReminderPatch,
  to change: REMReminderChangeItem,
  operation: String
) throws {
  guard let context = change.hashtagContext else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item hashtag context was unavailable."
    )
  }

  if let tags = patch.tags {
    context.removeAllHashtags()
    for tag in coreNormalizedTemplateTags(tags) {
      coreAddTemplateTag(tag, to: context)
    }
  } else if patch.clearTags {
    context.removeAllHashtags()
  } else {
    let removeKeys = Set(patch.removeTags.map(coreNormalizedTemplateTagKey))
    for hashtag in coreTemplateHashtagObjects(in: context)
    where removeKeys.contains(coreNormalizedTemplateTagKey(hashtag.name)) {
      context.removeHashtag(hashtag)
    }
    for tag in coreNormalizedTemplateTags(patch.addTags) {
      coreAddTemplateTag(tag, to: context)
    }
  }
}

private func coreAddTemplateTag(
  _ tag: String,
  to context: REMReminderHashtagContextChangeItem
) {
  guard
    !coreTemplateHashtagObjects(in: context).contains(where: {
      coreNormalizedTemplateTagKey($0.name) == coreNormalizedTemplateTagKey(tag)
    })
  else {
    return
  }
  _ = context.addHashtag(withType: 0, name: tag)
}

private func coreTemplateItemTags(_ reminder: REMReminder) -> [String] {
  let hashtags = reminder.hashtags as? Set<REMHashtag> ?? []
  return hashtags.map(\.name).sorted {
    $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
  }
}

func coreTemplateItemSubtaskCount(_ reminder: REMReminder) -> Int {
  var error: AnyObject?
  guard
    let subtasks = reminder.subtaskContext?.fetchRemindersWithError(&error) as? [REMReminder]
  else {
    return 0
  }
  return subtasks.count
}

func coreTemplateItemAttachments(_ reminder: REMReminder) -> [ReminderAttachmentRecord] {
  guard let context = reminder.attachmentContext else {
    return []
  }

  var result: [ReminderAttachmentRecord] = []
  func appendUnique(_ file: REMFileAttachment) {
    let record = coreTemplateItemAttachmentRecord(file)
    guard !result.contains(record) else {
      return
    }
    result.append(record)
  }

  if let files = context.attachments(of: REMFileAttachment.self) as? [REMFileAttachment] {
    files.forEach(appendUnique)
  }
  if let files = context.fileAttachments {
    files.compactMap { $0 as? REMFileAttachment }.forEach(appendUnique)
  }
  if let images = context.imageAttachments {
    images.compactMap { $0 as? REMFileAttachment }.forEach(appendUnique)
  }

  return result
}

func coreTemplateItemAttachmentRecord(_ file: REMFileAttachment) -> ReminderAttachmentRecord {
  let fileName = file.fileURL?.lastPathComponent
  let url = file.fileURL?.path ?? file.fileURL?.absoluteString
  let uti = file.uti
  return ReminderAttachmentRecord(
    kind: coreTemplateItemAttachmentKind(file: file, uti: uti, fileName: fileName),
    typeIdentifier: uti,
    fileName: fileName,
    url: url
  )
}

private func coreTemplateItemAttachmentKind(
  file: REMFileAttachment,
  uti: String?,
  fileName: String?
) -> String {
  if file is REMImageAttachment {
    return "image"
  }
  let lowerUTI = uti?.lowercased() ?? ""
  if lowerUTI.contains("image") || lowerUTI == "public.jpeg" || lowerUTI == "public.png" {
    return "image"
  }
  let lowerFileName = fileName?.lowercased() ?? ""
  if [".jpg", ".jpeg", ".png", ".heic", ".gif", ".tiff", ".webp"].contains(where: {
    lowerFileName.hasSuffix($0)
  }) {
    return "image"
  }
  return "file"
}

private func coreTemplateHashtagObjects(
  in context: REMReminderHashtagContextChangeItem
) -> [REMHashtag] {
  guard let hashtags = context.hashtags else {
    return []
  }
  return hashtags.compactMap { $0 as? REMHashtag }
}

private func coreNormalizedTemplateTags(_ tags: [String]) -> [String] {
  var seen: Set<String> = []
  var result: [String] = []
  for tag in tags {
    let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
    let key = coreNormalizedTemplateTagKey(trimmed)
    guard !trimmed.isEmpty, seen.insert(key).inserted else {
      continue
    }
    result.append(trimmed)
  }
  return result
}

private func coreNormalizedTemplateTagKey(_ tag: String?) -> String {
  (tag ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
}

private func coreSetTemplateItemUrgent(
  _ urgent: Bool,
  on change: REMReminderChangeItem,
  operation: String
) throws {
  let selector = NSSelectorFromString("setIsUrgentStateEnabledForCurrentUser:")
  if let urgentContext = change.urgentAlarmContext {
    guard urgentContext.responds(to: selector) else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template item urgent context setter was unavailable."
      )
    }
    urgentContext.isUrgentStateEnabledForCurrentUser = urgent
    return
  }

  guard change.responds(to: selector) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item urgent setter was unavailable."
    )
  }
  change.isUrgentStateEnabledForCurrentUser = urgent
}

private func coreApplyTemplateItemSectionMembership(
  store: REMStore,
  saveRequest: REMSaveRequest,
  template: REMTemplate,
  reminderObjectID: REMObjectID?,
  sectionSelector: String,
  operation: String
) throws {
  guard let reminderObjectID else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template item object ID was unavailable."
    )
  }
  let section = try coreResolveTemplateSection(
    store: store,
    template: template,
    selector: sectionSelector,
    operation: operation
  )
  let sectionObjectID = try coreTemplateSectionObjectID(section, operation: operation)
  let membership = try coreTemplateSectionMembership(
    reminderObjectID: reminderObjectID,
    sectionObjectID: sectionObjectID,
    operation: operation
  )
  guard
    let templateChange = saveRequest.updateTemplate(template) as? REMTemplateChangeItem,
    let sectionContext = templateChange.sectionsContextChangeItem
  else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template section context could not be updated.",
      details: ["template_id": coreObjectIDString(template.remObjectID)]
    )
  }
  sectionContext.unsavedMembershipsOfRemindersInSections = membership
  templateChange.unsavedMembershipsOfRemindersInSections = membership
}

private func coreTemplateSectionMembership(
  reminderObjectID: REMObjectID,
  sectionObjectID: REMObjectID,
  operation: String
) throws -> REMMemberships {
  guard
    let membership = REMMembership(
      memberIdentifier: reminderObjectID.uuid,
      groupIdentifier: sectionObjectID.uuid,
      isObsolete: false,
      modifiedOn: Date()
    ),
    let memberships = REMMemberships(memberships: [membership])
  else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit template section membership could not be created."
    )
  }
  return memberships
}
