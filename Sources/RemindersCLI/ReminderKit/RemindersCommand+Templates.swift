import Foundation
import ReminderKit
import Utility

extension RemindersCommand {
  func fetchReminderTemplatesWithReminderKit() throws -> [ReminderTemplateRecord] {
    let store = try coreReminderKitStore(operation: "templates-list")
    let records = try coreFetchTemplates(store: store, operation: "templates-list")
      .map { template, account, sourceListTitles in
        coreReminderTemplateRecord(
          template,
          account: account,
          sourceListTitles: sourceListTitles
        )
      }
      .sorted {
        if $0.sourceTitle != $1.sourceTitle {
          return $0.sourceTitle.localizedCaseInsensitiveCompare($1.sourceTitle)
            == .orderedAscending
        }
        return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
      }
    return records
  }

  func saveReminderTemplateWithReminderKit(
    sourceListID: String,
    title: String,
    includeCompleted: Bool
  ) throws -> ReminderTemplateRecord {
    let operation = "templates-save"
    let store = try coreReminderKitStore(operation: operation)
    let sourceList = try coreResolveList(store: store, selector: sourceListID, operation: operation)
    guard let account = sourceList.account else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit source list account was not available.",
        details: ["list_id": coreObjectIDString(sourceList.remObjectID)]
      )
    }
    try coreRequireTemplateSupport(account: account, operation: operation)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let accountChange = saveRequest.updateAccount(account) as? REMAccountChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit account change item could not be updated.",
        details: ["source_id": coreObjectIDString(account.remObjectID)]
      )
    }
    guard
      let configuration = REMTemplateConfiguration(
        sourceListID: sourceList.remObjectID,
        shouldSaveCompleted: includeCompleted
      )
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template configuration could not be created.",
        details: ["list_id": coreObjectIDString(sourceList.remObjectID)]
      )
    }
    guard
      let change = saveRequest.addTemplate(
        withName: title,
        configuration: configuration,
        toAccountChangeItem: accountChange
      ) as? REMTemplateChangeItem
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template change item could not be created.",
        details: ["title": title, "list_id": coreObjectIDString(sourceList.remObjectID)]
      )
    }

    try coreSaveReminderKit(saveRequest, operation: operation)
    let sourceListTitles = try coreSourceListTitles(store: store, operation: operation)
    let template = try coreFetchTemplate(
      store: store,
      selector: coreObjectIDString(change.remObjectID),
      operation: operation
    ).template
    return coreReminderTemplateRecord(
      template,
      account: account,
      sourceListTitles: sourceListTitles
    )
  }

  func createReminderListFromTemplateWithReminderKit(
    templateID: String,
    title: String
  ) throws -> ReminderListRecord {
    let operation = "templates-create-list"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
    let account = resolved.account
    try coreRequireTemplateSupport(account: account, operation: operation)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let accountChange = saveRequest.updateAccount(account) as? REMAccountChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit account change item could not be updated.",
        details: ["source_id": coreObjectIDString(account.remObjectID)]
      )
    }
    guard
      let change = saveRequest.addList(
        usingTemplate: resolved.template,
        toAccountChangeItem: accountChange
      ) as? REMListChangeItem
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit list change item could not be created from template.",
        details: ["template_id": templateID]
      )
    }
    change.name = title
    try coreSaveReminderKit(saveRequest, operation: operation)

    var error: AnyObject?
    guard
      let list = store.fetchList(
        withObjectID: change.remObjectID,
        error: &error
      ) as? REMList
    else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit could not fetch list after template creation.",
        details: [
          "template_id": templateID,
          "error": error.map(String.init(describing:)) ?? "",
        ]
      )
    }
    return coreReminderListRecord(list)
  }

  func updateReminderTemplateWithReminderKit(
    templateID: String,
    patch: ReminderTemplatePatch
  ) throws -> ReminderTemplateRecord {
    let operation = "templates-update"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)

    let sourceList: REMList?
    if let replacementSourceListId = patch.replacementSourceListId {
      sourceList = try coreResolveList(
        store: store,
        selector: replacementSourceListId,
        operation: operation
      )
      guard coreObjectIDString(sourceList?.account?.remObjectID) == coreObjectIDString(resolved.account.remObjectID)
      else {
        throw CLIError(
          code: .validationError,
          message: "Replacement source list must belong to the same source as the template.",
          details: [
            "template_source_id": coreObjectIDString(resolved.account.remObjectID),
            "source_list_id": replacementSourceListId,
          ]
        )
      }
    } else {
      sourceList = nil
    }

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateTemplate(resolved.template) as? REMTemplateChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template change item could not be updated.",
        details: ["template_id": templateID]
      )
    }
    if let title = patch.title {
      change.name = title
    }
    if let color = patch.color {
      change.color = coreReminderColor(color)
    }
    if let icon = patch.icon {
      change.badgeEmblem = icon
    }
    if let sortingStyle = patch.sortingStyle {
      change.sortingStyle = sortingStyle
    }
    if let showingLargeAttachments = patch.showingLargeAttachments {
      change.showingLargeAttachments = showingLargeAttachments
    }
    if let sourceList {
      guard
        let configuration = REMTemplateConfiguration(
          sourceListID: sourceList.remObjectID,
          shouldSaveCompleted: patch.includeCompleted ?? false
        )
      else {
        throw coreReminderKitError(
          operation: operation,
          message: "ReminderKit template configuration could not be created.",
          details: ["list_id": coreObjectIDString(sourceList.remObjectID)]
        )
      }
      change.configuration = configuration
    }

    try coreSaveReminderKit(saveRequest, operation: operation)
    let updated = try coreFetchTemplate(
      store: store,
      selector: templateID,
      operation: operation
    )
    let sourceListTitles = try coreSourceListTitles(store: store, operation: operation)
    return coreReminderTemplateRecord(
      updated.template,
      account: updated.account,
      sourceListTitles: sourceListTitles
    )
  }

  func deleteReminderTemplateWithReminderKit(templateID: String) throws -> Bool {
    let operation = "templates-delete"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateTemplate(resolved.template) as? REMTemplateChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template change item could not be updated.",
        details: ["template_id": templateID]
      )
    }
    change.removeFromParentAccount()
    try coreSaveReminderKit(saveRequest, operation: operation)
    return true
  }

  func replaceReminderTemplateWithReminderKit(
    templateID: String,
    sourceListID: String,
    title: String,
    includeCompleted: Bool
  ) throws -> ReminderTemplateRecord {
    let operation = "templates-replace"
    let store = try coreReminderKitStore(operation: operation)
    _ = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
    let sourceList = try coreResolveList(store: store, selector: sourceListID, operation: operation)
    let sourceColor = sourceList.color?.copy() as? REMColor
    let sourceBadgeEmblem = sourceList.badgeEmblem
    let sourceSortingStyle = sourceList.sortingStyle
    let sourceShowingLargeAttachments = sourceList.showingLargeAttachments

    let replacementTitle = "apple-cli replacement \(UUID().uuidString)"
    let replacement = try saveReminderTemplateWithReminderKit(
      sourceListID: sourceListID,
      title: replacementTitle,
      includeCompleted: includeCompleted
    )
    do {
      _ = try deleteReminderTemplateWithReminderKit(templateID: templateID)
      return try updateReminderTemplateMetadataWithReminderKit(
        templateID: replacement.id,
        title: title,
        color: sourceColor,
        badgeEmblem: sourceBadgeEmblem,
        sortingStyle: sourceSortingStyle,
        showingLargeAttachments: sourceShowingLargeAttachments
      )
    } catch {
      _ = try? deleteReminderTemplateWithReminderKit(templateID: replacement.id)
      throw error
    }
  }

  private func updateReminderTemplateMetadataWithReminderKit(
    templateID: String,
    title: String,
    color: REMColor?,
    badgeEmblem: String?,
    sortingStyle: String?,
    showingLargeAttachments: Bool
  ) throws -> ReminderTemplateRecord {
    let operation = "templates-update-metadata"
    let store = try coreReminderKitStore(operation: operation)
    let resolved = try coreFetchTemplate(store: store, selector: templateID, operation: operation)
    try coreRequireTemplateSupport(account: resolved.account, operation: operation)

    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: operation)
    guard let change = saveRequest.updateTemplate(resolved.template) as? REMTemplateChangeItem else {
      throw coreReminderKitError(
        operation: operation,
        message: "ReminderKit template change item could not be updated.",
        details: ["template_id": templateID]
      )
    }
    change.name = title
    if let color {
      change.color = color
    }
    if let badgeEmblem {
      change.badgeEmblem = badgeEmblem
    }
    if let sortingStyle {
      change.sortingStyle = sortingStyle
    }
    change.showingLargeAttachments = showingLargeAttachments

    try coreSaveReminderKit(saveRequest, operation: operation)
    let updated = try coreFetchTemplate(
      store: store,
      selector: templateID,
      operation: operation
    )
    let sourceListTitles = try coreSourceListTitles(store: store, operation: operation)
    return coreReminderTemplateRecord(
      updated.template,
      account: updated.account,
      sourceListTitles: sourceListTitles
    )
  }
}

func coreFetchTemplates(
  store: REMStore,
  operation: String
) throws -> [(template: REMTemplate, account: REMAccount, sourceListTitles: [String: String])] {
  var accountError: AnyObject?
  let accounts = store.fetchAccountsWithError(&accountError) as? [REMAccount] ?? []
  if accounts.isEmpty, let accountError {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit could not fetch accounts for templates.",
      details: ["accounts_error": String(describing: accountError)]
    )
  }

  let sourceListTitles = try coreSourceListTitles(store: store, operation: operation)
  var rows: [(template: REMTemplate, account: REMAccount, sourceListTitles: [String: String])] = []
  var templateErrors: [String] = []
  for account in accounts {
    guard coreAccountSupportsTemplates(account) else {
      continue
    }
    guard let context = account.templatesContext else {
      templateErrors.append("\(coreObjectIDString(account.remObjectID)): missing template context")
      continue
    }
    var templateError: AnyObject?
    let templates = context.fetchTemplatesWithError(&templateError) as? [REMTemplate] ?? []
    rows.append(
      contentsOf: templates.map {
        (template: $0, account: account, sourceListTitles: sourceListTitles)
      }
    )
    if let templateError {
      let accountTitle = account.displayName ?? account.name ?? coreObjectIDString(account.remObjectID)
      templateErrors.append("\(accountTitle): \(String(describing: templateError))")
    }
  }

  if rows.isEmpty, !templateErrors.isEmpty {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit could not fetch templates.",
      details: ["template_errors": templateErrors.prefix(3).joined(separator: "\n")]
    )
  }
  return rows
}

func coreFetchTemplate(
  store: REMStore,
  selector: String,
  operation: String
) throws -> (template: REMTemplate, account: REMAccount) {
  let rows = try coreFetchTemplates(store: store, operation: operation)
  let matches = rows.filter { row in
    coreObjectIDString(row.template.remObjectID) == selector
      || row.template.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
  }
  if let match = matches.first, matches.count == 1 {
    return (template: match.template, account: match.account)
  }
  if matches.count > 1 {
    throw CLIError(
      code: .ambiguousIdentity,
      message: "Reminder template selector matched multiple templates.",
      details: ["selector": selector]
    )
  }
  throw CLIError(
    code: .notFound,
    message: "Reminder template was not found.",
    details: ["selector": selector]
  )
}

func coreSourceListTitles(
  store: REMStore,
  operation: String
) throws -> [String: String] {
  let lists = try reminderKitFetchLists(store: store, operation: operation)
  return Dictionary(
    uniqueKeysWithValues: lists.map {
      (coreObjectIDString($0.remObjectID), $0.displayName ?? $0.name ?? "")
    }
  )
}

func coreReminderTemplateRecord(
  _ template: REMTemplate,
  account: REMAccount,
  sourceListTitles: [String: String]
) -> ReminderTemplateRecord {
  let sourceListId = template.storage?.configuration?.sourceListID.map(coreObjectIDString)
  return ReminderTemplateRecord(
    id: coreObjectIDString(template.remObjectID),
    title: template.name,
    sourceId: coreObjectIDString(account.remObjectID),
    sourceTitle: account.displayName ?? account.name ?? "",
    sourceListId: sourceListId ?? nil,
    sourceListTitle: sourceListId.flatMap { sourceListTitles[$0] },
    sortingStyle: template.sortingStyle,
    showingLargeAttachments: template.showingLargeAttachments,
    color: coreReminderColorHex(template.color),
    hasColor: template.color != nil
  )
}

func coreRequireTemplateSupport(account: REMAccount, operation: String) throws {
  guard coreAccountSupportsTemplates(account) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit account does not support templates.",
      details: [
        "source_id": coreObjectIDString(account.remObjectID),
        "source_title": account.displayName ?? account.name ?? "",
      ]
    )
  }
}

func coreAccountSupportsTemplates(_ account: REMAccount) -> Bool {
  account.capabilities?.supportsTemplates ?? false
}
