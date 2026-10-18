import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderSectionWriter {
  static let capability = "sections"

  static func preflight(listID: String?, reminderID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }

    if let listID {
      _ = try fetchList(listID: listID, operation: "preflight")
    }
    if let reminderID {
      _ = try fetchReminder(reminderID: reminderID, operation: "preflight")
    }
  }

  static func createSection(listID: String, title: String) throws {
    try preflight(listID: nil, reminderID: nil)
    let resolved = try fetchList(listID: listID, operation: "create")
    let sections = try listSections(store: resolved.store, list: resolved.list, operation: "create")

    let mutation = try editableSectionContext(
      store: resolved.store,
      list: resolved.list,
      operation: "create",
      details: ["list_id": listID, "title": title]
    )
    guard
      let sectionChange = mutation.saveRequest.addListSection(
        withDisplayName: title,
        toListSectionContextChangeItem: mutation.sectionContext
      ) as? REMListSectionChangeItem,
      let newSectionID = sectionChange.remObjectID
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "create",
        message: "ReminderKit section change item could not be created.",
        details: ["list_id": listID, "title": title]
      )
    }

    let existingSectionIDs = try sectionObjectIDs(
      sections,
      operation: "create",
      details: ["list_id": listID, "title": title]
    )
    mutation.sectionContext.unsavedSectionIDsOrdering = existingSectionIDs + [newSectionID]
    mutation.sectionContext.shouldUpdateSectionsOrdering = true
    mutation.listChange.unsavedSectionIDsOrdering = existingSectionIDs + [newSectionID]
    mutation.listChange.shouldUpdateSectionsOrdering = true
    try save(saveRequest: mutation.saveRequest, operation: "create", details: ["list_id": listID])
  }

  static func renameSection(listID: String, sectionTitle: String, newTitle: String) throws {
    try preflight(listID: nil, reminderID: nil)
    let resolved = try fetchList(listID: listID, operation: "rename")
    let section = try resolveSection(
      title: sectionTitle,
      store: resolved.store,
      list: resolved.list,
      operation: "rename",
      details: ["list_id": listID, "section": sectionTitle]
    )

    guard let saveRequest = try reminderKitNewSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "rename",
        message: "ReminderKit save request could not be created.",
        details: ["list_id": listID, "section": sectionTitle]
      )
    }
    guard let sectionChange = saveRequest.updateListSection(section) as? REMListSectionChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "rename",
        message: "ReminderKit section change item could not be updated.",
        details: ["list_id": listID, "section": sectionTitle]
      )
    }

    sectionChange.displayName = newTitle
    try save(saveRequest: saveRequest, operation: "rename", details: ["list_id": listID])
  }

  static func deleteSection(listID: String, sectionTitle: String) throws {
    try preflight(listID: nil, reminderID: nil)
    let resolved = try fetchList(listID: listID, operation: "delete")
    let section = try resolveSection(
      title: sectionTitle,
      store: resolved.store,
      list: resolved.list,
      operation: "delete",
      details: ["list_id": listID, "section": sectionTitle]
    )

    guard let saveRequest = try reminderKitNewSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit save request could not be created.",
        details: ["list_id": listID, "section": sectionTitle]
      )
    }
    guard let sectionChange = saveRequest.updateListSection(section) as? REMListSectionChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit section change item could not be updated.",
        details: ["list_id": listID, "section": sectionTitle]
      )
    }

    sectionChange.removeFromList()
    try save(saveRequest: saveRequest, operation: "delete", details: ["list_id": listID])
  }

  static func reorderSection(
    listID: String,
    sectionTitle: String,
    anchorSectionTitle: String,
    placement: ReminderSectionReorderPlacement
  ) throws {
    try preflight(listID: nil, reminderID: nil)
    let resolved = try fetchList(listID: listID, operation: "reorder")
    let sections = try listSections(
      store: resolved.store,
      list: resolved.list,
      operation: "reorder"
    )
    guard let section = uniqueSection(title: sectionTitle, in: sections) else {
      throw sectionNotFound(
        operation: "reorder",
        details: ["list_id": listID, "section": sectionTitle]
      )
    }
    guard let anchor = uniqueSection(title: anchorSectionTitle, in: sections) else {
      throw sectionNotFound(
        operation: "reorder",
        details: ["list_id": listID, "section": anchorSectionTitle]
      )
    }
    let sectionID = try sectionObjectID(
      section,
      operation: "reorder",
      details: ["list_id": listID, "section": sectionTitle]
    )
    let anchorID = try sectionObjectID(
      anchor,
      operation: "reorder",
      details: ["list_id": listID, "section": anchorSectionTitle]
    )
    guard !objectIDsMatch(sectionID, anchorID) else {
      throw CLIError(
        code: .validationError,
        message: "Reminder section cannot be reordered relative to itself.",
        details: ["section": sectionTitle]
      )
    }

    let mutation = try editableSectionContext(
      store: resolved.store,
      list: resolved.list,
      operation: "reorder",
      details: [
        "list_id": listID,
        "section": sectionTitle,
        "anchor_section": anchorSectionTitle,
        "placement": placement.relation,
      ]
    )
    var reorderedSections = sections.filter {
      !objectIDsMatch($0.objectID, sectionID)
    }
    guard
      let anchorIndex = reorderedSections.firstIndex(where: {
        objectIDsMatch($0.objectID, anchorID)
      })
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "ReminderKit section reorder anchor disappeared.",
        details: ["list_id": listID, "anchor_section": anchorSectionTitle]
      )
    }

    let insertionIndex = placement.beforeSectionId != nil ? anchorIndex : anchorIndex + 1
    reorderedSections.insert(section, at: insertionIndex)
    let reorderedIDs = try sectionObjectIDs(
      reorderedSections,
      operation: "reorder",
      details: ["list_id": listID, "section": sectionTitle]
    )

    mutation.sectionContext.unsavedSectionIDsOrdering = reorderedIDs
    mutation.sectionContext.shouldUpdateSectionsOrdering = true
    mutation.listChange.unsavedSectionIDsOrdering = reorderedIDs
    mutation.listChange.shouldUpdateSectionsOrdering = true
    try save(saveRequest: mutation.saveRequest, operation: "reorder", details: ["list_id": listID])
  }

  static func moveReminder(reminderID: String, toSectionTitle sectionTitle: String) throws {
    try preflight(listID: nil, reminderID: nil)
    let resolved = try fetchReminder(reminderID: reminderID, operation: "assign")
    guard let reminder = resolved.reminder as? REMReminder, let list = reminder.list else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "assign",
        message: "ReminderKit reminder list was unavailable.",
        details: ["reminder_id": reminderID, "section": sectionTitle]
      )
    }
    let section = try resolveSection(
      title: sectionTitle,
      store: resolved.store,
      list: list,
      operation: "assign",
      details: ["reminder_id": reminderID, "section": sectionTitle]
    )
    let mutation = try editableSectionContext(
      store: resolved.store,
      list: list,
      operation: "assign",
      details: ["reminder_id": reminderID, "section": sectionTitle]
    )
    let membership = try sectionMembership(
      reminderObjectID: reminder.remObjectID,
      sectionObjectID: sectionObjectID(
        section,
        operation: "assign",
        details: ["reminder_id": reminderID, "section": sectionTitle]
      ),
      operation: "assign",
      details: ["reminder_id": reminderID, "section": sectionTitle]
    )
    mutation.sectionContext.unsavedMembershipsOfRemindersInSections = membership
    try save(
      saveRequest: mutation.saveRequest, operation: "assign", details: ["reminder_id": reminderID])
  }

  private static func fetchList(
    listID: String,
    operation: String
  ) throws -> (store: REMStore, list: REMList) {
    guard let store = try reminderKitNewStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["list_id": listID]
      )
    }
    var fetchError: AnyObject?
    let objectID = try remObjectID(entity: "REMCDList", identifier: listID, operation: operation)
    if let list = store.fetchList(withObjectID: objectID, error: &fetchError) as? REMList {
      return (store, list)
    }

    let lists = try reminderKitFetchLists(store: store, operation: operation)
    if let list = lists.first(where: { listMatches($0, listID: listID) }) {
      return (store, list)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the list by ReminderKit-compatible identifier.",
      details: [
        "list_id": listID,
        "fetch_error": reminderKitErrorSummary(fetchError),
      ]
    )
  }

  private static func fetchReminder(
    reminderID: String,
    operation: String
  ) throws -> (store: REMStore, reminder: Any) {
    guard let store = try reminderKitNewStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["reminder_id": reminderID]
      )
    }
    var fetchError: AnyObject?
    let reminder = store.fetchReminder(
      withDACalendarItemUniqueIdentifier: reminderID,
      inList: nil,
      error: &fetchError
    )
    guard let reminder else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit could not fetch the reminder by ReminderKit-compatible identifier.",
        details: [
          "reminder_id": reminderID,
          "fetch_error": reminderKitErrorSummary(fetchError),
        ]
      )
    }
    return (store, reminder)
  }

  private static func editableSectionContext(
    store: REMStore,
    list: REMList,
    operation: String,
    details: [String: String]
  ) throws -> (
    saveRequest: REMSaveRequest,
    listChange: REMListChangeItem,
    sectionContext: REMListSectionContextChangeItem
  ) {
    guard let saveRequest = try reminderKitNewSaveRequest(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: details
      )
    }
    guard
      let listChange = saveRequest.updateList(list) as? REMListChangeItem,
      let sectionContext = listChange.sectionsContextChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit list section context was unavailable.",
        details: details
      )
    }
    return (saveRequest, listChange, sectionContext)
  }

  private static func listSections(
    store: REMStore,
    list: REMList,
    operation: String
  ) throws -> [REMListSection] {
    guard let sectionContext = list.sectionContext else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit list section context was unavailable.",
        details: ["list_id": listIdentifier(list)]
      )
    }

    var fetchError: AnyObject?
    let sections = store.fetchListSections(
      forListSectionContext: sectionContext, error: &fetchError)
    guard let typedSections = sections as? [REMListSection] else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit list sections could not be fetched.",
        details: [
          "list_id": listIdentifier(list),
          "fetch_error": reminderKitErrorSummary(fetchError),
        ]
      )
    }
    return typedSections
  }

  private static func resolveSection(
    title: String,
    store: REMStore,
    list: REMList,
    operation: String,
    details: [String: String]
  ) throws -> REMListSection {
    let sections = try listSections(store: store, list: list, operation: operation)
    guard let section = uniqueSection(title: title, in: sections) else {
      if sections.contains(where: { sectionTitleMatches($0.displayName, title) }) {
        throw CLIError(
          code: .ambiguousIdentity,
          message: "Reminder section title matched multiple sections.",
          details: details
        )
      }
      throw sectionNotFound(operation: operation, details: details)
    }
    return section
  }

  private static func uniqueSection(title: String, in sections: [REMListSection]) -> REMListSection?
  {
    let matches = sections.filter { sectionTitleMatches($0.displayName, title) }
    return matches.count == 1 ? matches[0] : nil
  }

  private static func sectionMembership(
    reminderObjectID: REMObjectID,
    sectionObjectID: REMObjectID,
    operation: String,
    details: [String: String]
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
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit section membership could not be created.",
        details: details
      )
    }
    return memberships
  }

  private static func sectionObjectIDs(
    _ sections: [REMListSection],
    operation: String,
    details: [String: String]
  ) throws -> [REMObjectID] {
    try sections.map {
      try sectionObjectID($0, operation: operation, details: details)
    }
  }

  private static func sectionObjectID(
    _ section: REMListSection,
    operation: String,
    details: [String: String]
  ) throws -> REMObjectID {
    guard let objectID = section.objectID else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit section object ID was unavailable.",
        details: details
      )
    }
    return objectID
  }

  private static func objectIDsMatch(_ lhs: REMObjectID?, _ rhs: REMObjectID?) -> Bool {
    guard let lhs, let rhs else {
      return lhs == nil && rhs == nil
    }
    return lhs.uuid == rhs.uuid || lhs.urlRepresentation == rhs.urlRepresentation
  }

  private static func remObjectID(
    entity: String,
    identifier: String,
    operation: String
  ) throws -> REMObjectID {
    let urlString =
      identifier.hasPrefix("x-apple-reminderkit://")
      ? identifier
      : "x-apple-reminderkit://\(entity)/\(identifier)"
    guard
      let url = URL(string: urlString),
      let objectID = REMObjectID.objectID(withURL: url) as? REMObjectID
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit object ID could not be built.",
        details: ["object_id": identifier, "entity": entity]
      )
    }
    return objectID
  }

  private static func save(
    saveRequest: REMSaveRequest,
    operation: String,
    details additionalDetails: [String: String]
  ) throws {
    var saveError: AnyObject?
    guard try reminderKitSaveSynchronously(saveRequest, error: &saveError) else {
      var details = additionalDetails
      details["save_error"] = reminderKitErrorSummary(saveError)
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: details
      )
    }
  }

  private static func sectionNotFound(
    operation: String,
    details: [String: String]
  ) -> CLIError {
    CLIError(
      code: .notFound,
      message: "Reminder section was not found.",
      details: details.merging(
        ["mechanism": "reminderkit", "capability": capability, "operation": operation],
        uniquingKeysWith: { current, _ in current }
      )
    )
  }

  private static func listMatches(_ list: REMList, listID: String) -> Bool {
    let candidates = [
      list.objectID?.uuid.uuidString,
      list.remObjectID?.uuid.uuidString,
      list.objectID?.urlRepresentation.absoluteString,
      list.remObjectID?.urlRepresentation.absoluteString,
      list.externalIdentifier,
      list.daExternalIdentificationTag,
    ].compactMap { $0 }
    return candidates.contains { $0.localizedCaseInsensitiveCompare(listID) == .orderedSame }
  }

  private static func listIdentifier(_ list: REMList) -> String {
    list.objectID?.uuid.uuidString ?? list.name ?? "unknown"
  }

  private static func sectionTitleMatches(_ lhs: String, _ rhs: String) -> Bool {
    lhs.trimmingCharacters(in: .whitespacesAndNewlines)
      .localizedCaseInsensitiveCompare(rhs.trimmingCharacters(in: .whitespacesAndNewlines))
      == .orderedSame
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMList", NSClassFromString("REMList") != nil),
      ("REMListChangeItem", NSClassFromString("REMListChangeItem") != nil),
      ("REMListSection", NSClassFromString("REMListSection") != nil),
      ("REMListSectionChangeItem", NSClassFromString("REMListSectionChangeItem") != nil),
      (
        "REMListSectionContextChangeItem",
        NSClassFromString("REMListSectionContextChangeItem") != nil
      ),
      ("REMMembership", NSClassFromString("REMMembership") != nil),
      ("REMMemberships", NSClassFromString("REMMemberships") != nil),
      (
        "REMObjectID.objectIDWithURL:",
        REMObjectID.responds(to: NSSelectorFromString("objectIDWithURL:"))
      ),
      (
        "REMStore.fetchReminderWithDACalendarItemUniqueIdentifier:inList:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withDACalendarItemUniqueIdentifier:inList:error:))
        )
      ),
      (
        "REMStore.fetchListWithObjectID:error:",
        REMStore.instancesRespond(to: #selector(REMStore.fetchList(withObjectID:error:)))
      ),
      (
        "REMStore.fetchListSectionsForListSectionContext:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchListSections(forListSectionContext:error:))
        )
      ),
      (
        "REMSaveRequest.updateList:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateList(_:)))
      ),
      (
        "REMSaveRequest.addListSectionWithDisplayName:toListSectionContextChangeItem:",
        REMSaveRequest.instancesRespond(
          to: NSSelectorFromString("addListSectionWithDisplayName:toListSectionContextChangeItem:")
        )
      ),
      (
        "REMSaveRequest.updateListSection:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateListSection(_:)))
      ),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMListChangeItem.sectionsContextChangeItem",
        REMListChangeItem.instancesRespond(to: NSSelectorFromString("sectionsContextChangeItem"))
      ),
      (
        "REMListSectionChangeItem.removeFromList",
        REMListSectionChangeItem.instancesRespond(
          to: #selector(REMListSectionChangeItem.removeFromList))
      ),
      (
        "REMListSectionContextChangeItem.setUnsavedMembershipsOfRemindersInSections:",
        REMListSectionContextChangeItem.instancesRespond(
          to: NSSelectorFromString("setUnsavedMembershipsOfRemindersInSections:")
        )
      ),
      (
        "REMListSectionContextChangeItem.setUnsavedSectionIDsOrdering:",
        REMListSectionContextChangeItem.instancesRespond(
          to: NSSelectorFromString("setUnsavedSectionIDsOrdering:")
        )
      ),
      (
        "REMListSectionContextChangeItem.setShouldUpdateSectionsOrdering:",
        REMListSectionContextChangeItem.instancesRespond(
          to: NSSelectorFromString("setShouldUpdateSectionsOrdering:")
        )
      ),
      (
        "REMMembership.initWithMemberIdentifier:groupIdentifier:isObsolete:modifiedOn:",
        REMMembership.instancesRespond(
          to: NSSelectorFromString(
            "initWithMemberIdentifier:groupIdentifier:isObsolete:modifiedOn:")
        )
      ),
      (
        "REMMemberships.initWithMemberships:",
        REMMemberships.instancesRespond(to: NSSelectorFromString("initWithMemberships:"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
