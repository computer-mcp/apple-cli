import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderListMetadataWriter {
  static let capability = "list_metadata"

  static func preflight(listID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard let listID else {
      return
    }
    _ = try fetchList(listID: listID, operation: "preflight")
  }

  static func updateListMetadata(listID: String, patch: ReminderListPatch) throws {
    try preflight(listID: nil)
    let unsupportedFields = patch.unsupportedReminderKitListMetadataFields
    guard unsupportedFields.isEmpty else {
      throw reminderKitUnsupportedAction(
        capability: capability,
        details: [
          "list_id": listID,
          "fields": unsupportedFields.joined(separator: ","),
        ]
      )
    }
    guard patch.hasSupportedReminderKitListMetadataFields else {
      throw CLIError(
        code: .validationError,
        message: "At least one supported ReminderKit list metadata field is required.",
        details: ["supported_fields": "type,pinned,sort"]
      )
    }

    let resolved = try fetchList(listID: listID, operation: "update")
    guard let saveRequest = REMSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "update",
        message: "ReminderKit save request could not be created.",
        details: ["list_id": listID]
      )
    }
    guard let listChange = saveRequest.updateList(resolved.list) as? REMListChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "update",
        message: "ReminderKit list change item could not be updated.",
        details: ["list_id": listID, "fields": patch.changedFieldNames.joined(separator: ",")]
      )
    }

    if let listType = patch.listType {
      guard let groceryContext = listChange.groceryContextChangeItem else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "update",
          message: "ReminderKit grocery context was unavailable.",
          details: ["list_id": listID, "type": listType]
        )
      }
      try requireListChangeItemSetters(
        listChange,
        [
          (
            "REMListChangeItem.setShouldCategorizeGroceryItems:", "setShouldCategorizeGroceryItems:"
          ),
          ("REMListChangeItem.setShouldAutoCategorizeItems:", "setShouldAutoCategorizeItems:"),
          ("REMListChangeItem.setGroceryLocaleID:", "setGroceryLocaleID:"),
        ],
        details: ["list_id": listID, "type": listType, "fields": "type"]
      )
      try requireGroceryContextSetters(
        groceryContext,
        [
          (
            "REMListGroceryContextChangeItem.setShouldCategorizeGroceryItems:",
            "setShouldCategorizeGroceryItems:"
          ),
          ("REMListGroceryContextChangeItem.setGroceryLocaleID:", "setGroceryLocaleID:"),
        ],
        details: ["list_id": listID, "type": listType, "fields": "type"]
      )
      let isShopping = listType == "shopping"
      listChange.shouldCategorizeGroceryItems = isShopping
      groceryContext.shouldCategorizeGroceryItems = isShopping
      listChange.shouldAutoCategorizeItems = isShopping
      if isShopping {
        let localeID = normalizedGroceryLocaleID()
        listChange.groceryLocaleID = localeID
        groceryContext.groceryLocaleID = localeID
      } else {
        listChange.groceryLocaleID = nil
        groceryContext.groceryLocaleID = nil
      }
    }

    if let pinned = patch.pinned {
      try requireListChangeItemSetters(
        listChange,
        [
          ("REMListChangeItem.setIsPinned:", "setIsPinned:"),
          ("REMListChangeItem.setPinnedDate:", "setPinnedDate:"),
        ],
        details: ["list_id": listID, "pinned": "\(pinned)", "fields": "pinned"]
      )
      listChange.isPinned = pinned
      listChange.pinnedDate = pinned ? Date() : nil
    }

    if let sortingStyle = patch.sortingStyle {
      try requireListChangeItemSetters(
        listChange,
        [("REMListChangeItem.setSortingStyle:", "setSortingStyle:")],
        details: ["list_id": listID, "sort": sortingStyle, "fields": "sort"]
      )
      listChange.sortingStyle = sortingStyle
    }

    if let showingLargeAttachments = patch.showingLargeAttachments {
      guard let appearanceContext = listChange.appearanceContext else {
        throw reminderKitOperationFailed(
          capability: capability,
          operation: "update",
          message: "ReminderKit list appearance context was unavailable.",
          details: [
            "list_id": listID,
            "show_large_attachments": "\(showingLargeAttachments)",
            "fields": "show-large-attachments",
          ]
        )
      }
      try requireListChangeItemSetters(
        listChange,
        [
          ("REMListChangeItem.setShowingLargeAttachments:", "setShowingLargeAttachments:"),
          ("REMListChangeItem.appearanceContext", "appearanceContext"),
        ],
        details: [
          "list_id": listID,
          "show_large_attachments": "\(showingLargeAttachments)",
          "fields": "show-large-attachments",
        ]
      )
      try requireListAppearanceContextSetters(
        appearanceContext,
        [
          (
            "REMListAppearanceContextChangeItem.setShowingLargeAttachments:",
            "setShowingLargeAttachments:"
          )
        ],
        details: [
          "list_id": listID,
          "show_large_attachments": "\(showingLargeAttachments)",
          "fields": "show-large-attachments",
        ]
      )
      listChange.showingLargeAttachments = showingLargeAttachments
      appearanceContext.setShowingLargeAttachments(showingLargeAttachments)
    }

    try save(
      saveRequest: saveRequest,
      operation: "update",
      details: ["list_id": listID, "fields": patch.changedFieldNames.joined(separator: ",")]
    )
  }

  static func reorderList(
    listID: String,
    anchorListID: String,
    placement: ReminderListReorderPlacement
  ) throws {
    try preflight(listID: nil)
    let missing = missingReorderRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard listID != anchorListID else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list reorder target and anchor must be different.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }

    let target = try fetchList(listID: listID, operation: "reorder")
    let anchor = try fetchList(listID: anchorListID, operation: "reorder")
    guard objectIDsMatch(target.list.accountID, anchor.list.accountID) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "Reminder list reorder target and anchor are in different accounts.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }
    guard objectIDsMatch(target.list.parentListID, anchor.list.parentListID) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "Reminder list reorder target and anchor are in different sidebar groups.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }
    guard let account = target.list.account else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "ReminderKit list account was unavailable.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }

    guard let saveRequest = REMSaveRequest(store: target.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "ReminderKit save request could not be created.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }
    guard let accountChange = saveRequest.updateAccount(account) as? REMAccountChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "ReminderKit account change item could not be updated.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }
    guard let targetChange = saveRequest.updateList(target.list) as? REMListChangeItem,
      let anchorChange = saveRequest.updateList(anchor.list) as? REMListChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "reorder",
        message: "ReminderKit list change items could not be updated.",
        details: ["list_id": listID, "anchor_list_id": anchorListID]
      )
    }

    if placement.beforeListId != nil {
      accountChange.insertListChangeItem(targetChange, beforeListChangeItem: anchorChange)
    } else {
      accountChange.insertListChangeItem(targetChange, afterListChangeItem: anchorChange)
    }
    try markListsDisplayOrderChanged(
      accountChange,
      details: ["list_id": listID, "anchor_list_id": anchorListID, "placement": placement.relation]
    )

    try save(
      saveRequest: saveRequest,
      operation: "reorder",
      details: ["list_id": listID, "anchor_list_id": anchorListID, "placement": placement.relation]
    )
  }

  private static func save(
    saveRequest: REMSaveRequest,
    operation: String,
    details additionalDetails: [String: String]
  ) throws {
    var saveError: AnyObject?
    guard saveRequest.saveSynchronouslyWithError(&saveError) else {
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

  private static func fetchList(
    listID: String,
    operation: String
  ) throws -> (store: REMStore, list: REMList) {
    guard let store = REMStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["list_id": listID]
      )
    }

    var fetchError: AnyObject?
    if let objectID = remObjectID(entity: "REMCDList", identifier: listID),
      let list = store.fetchList(withObjectID: objectID, error: &fetchError) as? REMList
    {
      return (store, list)
    }

    let lists = try reminderKitFetchLists(store: store, operation: operation)
    if let list = lists.first(where: { listMatches($0, listID: listID) }) {
      return (store, list)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the list by title or ReminderKit identifier.",
      details: [
        "list_id": listID,
        "fetch_error": reminderKitErrorSummary(fetchError),
      ]
    )
  }

  private static func remObjectID(entity: String, identifier: String) -> REMObjectID? {
    let urlString =
      identifier.hasPrefix("x-apple-reminderkit://")
      ? identifier
      : "x-apple-reminderkit://\(entity)/\(identifier)"
    guard let url = URL(string: urlString) else {
      return nil
    }
    return REMObjectID.objectID(withURL: url) as? REMObjectID
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

  private static func objectIDsMatch(_ lhs: REMObjectID?, _ rhs: REMObjectID?) -> Bool {
    guard let lhs, let rhs else {
      return lhs == nil && rhs == nil
    }
    return lhs.uuid == rhs.uuid
  }

  private static func normalizedGroceryLocaleID() -> String {
    let identifier = Locale.current.identifier.trimmingCharacters(in: .whitespacesAndNewlines)
    return identifier.isEmpty ? "en_US" : identifier.replacingOccurrences(of: "-", with: "_")
  }

  private static func requireListChangeItemSetters(
    _ listChange: REMListChangeItem,
    _ selectors: [(String, String)],
    details: [String: String]
  ) throws {
    let missing = selectors.compactMap { name, selector in
      listChange.responds(to: NSSelectorFromString(selector)) ? nil : name
    }
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: missing,
        details: details.merging(
          ["operation": "update"],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  private static func requireGroceryContextSetters(
    _ groceryContext: REMListGroceryContextChangeItem,
    _ selectors: [(String, String)],
    details: [String: String]
  ) throws {
    let missing = selectors.compactMap { name, selector in
      groceryContext.responds(to: NSSelectorFromString(selector)) ? nil : name
    }
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: missing,
        details: details.merging(
          ["operation": "update"],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  private static func requireListAppearanceContextSetters(
    _ appearanceContext: REMListAppearanceContextChangeItem,
    _ selectors: [(String, String)],
    details: [String: String]
  ) throws {
    let missing = selectors.compactMap { name, selector in
      appearanceContext.responds(to: NSSelectorFromString(selector)) ? nil : name
    }
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: missing,
        details: details.merging(
          ["operation": "update"],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMList", NSClassFromString("REMList") != nil),
      ("REMListChangeItem", NSClassFromString("REMListChangeItem") != nil),
      (
        "REMListGroceryContextChangeItem",
        NSClassFromString("REMListGroceryContextChangeItem") != nil
      ),
      (
        "REMObjectID.objectIDWithURL:",
        REMObjectID.responds(to: NSSelectorFromString("objectIDWithURL:"))
      ),
      (
        "REMStore.fetchListWithObjectID:error:",
        REMStore.instancesRespond(to: #selector(REMStore.fetchList(withObjectID:error:)))
      ),
      (
        "REMAccount.fetchListsWithError:",
        REMAccount.instancesRespond(to: NSSelectorFromString("fetchListsWithError:"))
      ),
      (
        "REMSaveRequest.updateList:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateList(_:)))
      ),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMListChangeItem.groceryContextChangeItem",
        REMListChangeItem.instancesRespond(to: NSSelectorFromString("groceryContextChangeItem"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }

  private static func markListsDisplayOrderChanged(
    _ accountChange: REMAccountChangeItem,
    details: [String: String]
  ) throws {
    guard accountChange.responds(to: NSSelectorFromString("setListsDADisplayOrderChanged:")) else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: ["REMAccountChangeItem.setListsDADisplayOrderChanged:"],
        details: details.merging(
          ["operation": "reorder"],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
    accountChange.listsDADisplayOrderChanged = true
  }

  private static func missingReorderRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMAccountChangeItem", NSClassFromString("REMAccountChangeItem") != nil),
      (
        "REMSaveRequest.updateAccount:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateAccount(_:)))
      ),
      (
        "REMAccountChangeItem.insertListChangeItem:beforeListChangeItem:",
        REMAccountChangeItem.instancesRespond(
          to: NSSelectorFromString("insertListChangeItem:beforeListChangeItem:")
        )
      ),
      (
        "REMAccountChangeItem.insertListChangeItem:afterListChangeItem:",
        REMAccountChangeItem.instancesRespond(
          to: NSSelectorFromString("insertListChangeItem:afterListChangeItem:")
        )
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
extension ReminderListPatch {
  fileprivate var changedFieldNames: [String] {
    var names: [String] = []
    if title != nil { names.append("title") }
    if listType != nil { names.append("type") }
    if color != nil { names.append("color") }
    if icon != nil { names.append("icon") }
    if pinned != nil { names.append("pinned") }
    if sortingStyle != nil { names.append("sort") }
    if showingLargeAttachments != nil { names.append("show-large-attachments") }
    return names
  }

  fileprivate var unsupportedReminderKitListMetadataFields: [String] {
    var names: [String] = []
    if title != nil { names.append("title") }
    if color != nil { names.append("color") }
    if icon != nil { names.append("icon") }
    return names
  }

  fileprivate var hasSupportedReminderKitListMetadataFields: Bool {
    listType != nil || pinned != nil || sortingStyle != nil
  }
}
