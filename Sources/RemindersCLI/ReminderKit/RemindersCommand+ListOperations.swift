import Foundation
import Utility

extension RemindersCommand {
  public func updateReminderList(id: String, patch: ReminderListPatch) throws -> ReminderListRecord
  {
    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError,
        message: "At least one reminder list update field is required."
      )
    }

    guard let current = try fetchReminderKitLists().first(where: { $0.id == id }) else {
      throw CLIError(code: .notFound, message: "Reminder list was not found.", details: ["id": id])
    }

    let appearancePatch = patch.listAppearancePatch
    let privateMetadataPatch = patch.privateListMetadataPatch

    if appearancePatch.hasAppearanceChanges {
      try self.preflightListAppearanceMutation(listID: current.id)
    }
    if privateMetadataPatch.hasPrivateListMetadataChanges {
      try self.preflightListMetadataMutation(listID: current.id)
    }

    if privateMetadataPatch.hasPrivateListMetadataChanges {
      try self.updateReminderListMetadata(
        listID: current.id,
        patch: privateMetadataPatch
      )
    }
    if appearancePatch.hasAppearanceChanges {
      try self.updateReminderListAppearance(
        listID: current.id,
        patch: appearancePatch
      )
    }

    try verifyListMetadata(list: current, patch: patch)

    var fresh = try fetchReminderKitLists().first(where: { $0.id == id }) ?? current
    if let title = patch.title {
      fresh.title = title
    }
    do {
      return try sqliteReader.enrichLists([fresh]).first ?? fresh
    } catch {
      return fresh
    }
  }

  public func reorderReminderList(
    id: String,
    anchorListID: String,
    placement: ReminderListReorderPlacement
  ) throws -> ReminderListRecord {
    guard placement.anchorListId == anchorListID else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list reorder anchor did not match placement.",
        details: ["anchor_list_id": anchorListID]
      )
    }

    let lists = try enrichedReminderListsForVerification()
    guard let target = lists.first(where: { $0.id == id }) else {
      throw CLIError(code: .notFound, message: "Reminder list was not found.", details: ["id": id])
    }
    guard lists.contains(where: { $0.id == anchorListID }) else {
      throw CLIError(
        code: .notFound,
        message: "Reminder list reorder anchor was not found.",
        details: ["anchor_list_id": anchorListID]
      )
    }

    try self.preflightListMetadataMutation(listID: target.id)
    try self.reorderReminderListMetadata(
      listID: id,
      anchorListID: anchorListID,
      placement: placement
    )
    return try verifyListReorder(
      list: target,
      anchorListID: anchorListID,
      placement: placement
    )
  }

  public func createReminderList(title: String, sourceID: String) throws -> ReminderListRecord {
    let created = try createReminderListWithReminderKit(title: title, sourceID: sourceID)
    guard try fetchReminderKitLists().contains(where: { $0.id == created.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder list was not present after creation.",
        details: ["id": created.id, "mechanism": "reminderkit"]
      )
    }
    do {
      return try sqliteReader.enrichLists([created]).first ?? created
    } catch {
      return created
    }
  }

  public func deleteReminderList(id: String) throws -> Bool {
    guard let current = try fetchReminderKitLists().first(where: { $0.id == id }) else {
      throw CLIError(code: .notFound, message: "Reminder list was not found.", details: ["id": id])
    }
    guard current.allowsContentModifications else {
      throw CLIError(
        code: .validationError,
        message: "Reminder list does not allow modifications.",
        details: ["list": current.title]
      )
    }

    let changed = try deleteReminderListWithReminderKit(id: id)
    if try fetchReminderKitLists().contains(where: { $0.id == id }) {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder list was still present after delete.",
        details: ["id": id, "mechanism": "reminderkit"]
      )
    }
    return changed
  }

  func verifyListReorder(
    list: ReminderListRecord,
    anchorListID: String,
    placement: ReminderListReorderPlacement
  ) throws -> ReminderListRecord {
    let deadline = Date().addingTimeInterval(10)
    var lastLists: [ReminderListRecord] = []
    var lastError: Error?

    repeat {
      do {
        let lists = try enrichedReminderListsForVerification()
        lastLists = lists
        if let current = lists.first(where: { $0.id == list.id }),
          let anchor = lists.first(where: { $0.id == anchorListID }),
          listReorderSatisfied(list: current, anchor: anchor, placement: placement)
        {
          return current
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    let current = lastLists.first(where: { $0.id == list.id })
    let anchor = lastLists.first(where: { $0.id == anchorListID })
    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "anchor_list_id": anchorListID,
      "placement": placement.relation,
      "actual_display_order": current?.displayOrder.map(String.init) ?? "",
      "anchor_display_order": anchor?.displayOrder.map(String.init) ?? "",
    ]
    if let lastError {
      details["last_error"] = reminderKitErrorSummary(lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app list reorder could not be verified.",
      details: details
    )
  }

  func listReorderSatisfied(
    list: ReminderListRecord,
    anchor: ReminderListRecord,
    placement: ReminderListReorderPlacement
  ) -> Bool {
    guard let listOrder = list.displayOrder, let anchorOrder = anchor.displayOrder else {
      return false
    }
    if placement.beforeListId != nil {
      return listOrder < anchorOrder
    }
    return listOrder > anchorOrder
  }
}

extension ReminderListPatch {
  fileprivate var hasAppearanceChanges: Bool {
    title != nil || color != nil || icon != nil
  }

  fileprivate var hasPrivateListMetadataChanges: Bool {
    listType != nil || pinned != nil || sortingStyle != nil
  }

  fileprivate var listAppearancePatch: ReminderListPatch {
    ReminderListPatch(title: title, color: color, icon: icon)
  }

  fileprivate var privateListMetadataPatch: ReminderListPatch {
    ReminderListPatch(listType: listType, pinned: pinned, sortingStyle: sortingStyle)
  }
}
