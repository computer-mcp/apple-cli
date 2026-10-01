import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderTagWriter {
  static let capability = "tags"
  private static let explicitTagType: Int64 = 0

  static func preflight(reminderID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard let reminderID else {
      return
    }
    _ = try fetchReminder(reminderID: reminderID, operation: "preflight")
  }

  static func updateTags(
    reminderID: String,
    tags: [String]?,
    addTags: [String],
    removeTags: [String],
    clearTags: Bool
  ) throws {
    try preflight(reminderID: nil)
    let resolved = try fetchReminder(reminderID: reminderID, operation: "update")
    let mutation = try editableHashtagContext(
      store: resolved.store,
      reminder: resolved.reminder,
      reminderID: reminderID,
      operation: "update"
    )

    if let tags {
      mutation.hashtagContext.removeAllHashtags()
      for tag in normalizedTags(tags) {
        addTag(tag, to: mutation.hashtagContext)
      }
    } else if clearTags {
      mutation.hashtagContext.removeAllHashtags()
    } else {
      let removeKeys = Set(removeTags.map { normalizedTagKey($0) })
      for hashtag in hashtagObjects(in: mutation.hashtagContext)
      where removeKeys.contains(normalizedTagKey(hashtag.name)) {
        mutation.hashtagContext.removeHashtag(hashtag)
      }
      for tag in normalizedTags(addTags) {
        addTag(tag, to: mutation.hashtagContext)
      }
    }

    try save(saveRequest: mutation.saveRequest, operation: "update", reminderID: reminderID)
  }

  static func renameTag(
    tagName: String,
    newName: String,
    reminderIDs: [String]
  ) throws {
    try preflight(reminderID: nil)
    let tagKey = normalizedTagKey(tagName)
    guard let newTag = normalizedTags([newName]).first, !tagKey.isEmpty else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "rename",
        message: "ReminderKit tag rename received an invalid tag name.",
        details: ["tag": tagName, "new_name": newName]
      )
    }
    let reminderIDs = normalizedReminderIDs(reminderIDs)
    guard !reminderIDs.isEmpty else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "rename",
        message: "ReminderKit tag rename requires reminder membership evidence.",
        details: ["tag": tagName, "new_name": newName]
      )
    }

    let mutation = try editableBatchMutation(operation: "rename", reminderIDs: reminderIDs)
    var changedCount = 0
    for reminderID in reminderIDs {
      let reminder = try fetchReminder(
        reminderID: reminderID, store: mutation.store, operation: "rename")
      let context = try editableHashtagContext(
        saveRequest: mutation.saveRequest,
        reminder: reminder,
        reminderID: reminderID,
        operation: "rename"
      )
      let matches = explicitHashtagObjects(in: context).filter {
        normalizedTagKey($0.name) == tagKey
      }
      guard !matches.isEmpty else {
        continue
      }
      for hashtag in matches {
        context.removeHashtag(hashtag)
        changedCount += 1
      }
      addTag(newTag, to: context)
    }

    guard changedCount > 0 else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "rename",
        message: "ReminderKit tag rename found no explicit hashtag membership to mutate.",
        details: [
          "tag": tagName,
          "new_name": newName,
          "affected_reminder_count": "\(reminderIDs.count)",
        ]
      )
    }
    try save(
      saveRequest: mutation.saveRequest,
      operation: "rename",
      details: [
        "tag": tagName,
        "new_name": newName,
        "affected_reminder_count": "\(reminderIDs.count)",
      ]
    )
  }

  static func deleteTag(tagName: String, reminderIDs: [String]) throws {
    try preflight(reminderID: nil)
    let tagKey = normalizedTagKey(tagName)
    guard !tagKey.isEmpty else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit tag delete received an invalid tag name.",
        details: ["tag": tagName]
      )
    }
    let reminderIDs = normalizedReminderIDs(reminderIDs)
    guard !reminderIDs.isEmpty else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit tag delete requires reminder membership evidence.",
        details: ["tag": tagName]
      )
    }

    let mutation = try editableBatchMutation(operation: "delete", reminderIDs: reminderIDs)
    var changedCount = 0
    for reminderID in reminderIDs {
      let reminder = try fetchReminder(
        reminderID: reminderID, store: mutation.store, operation: "delete")
      let context = try editableHashtagContext(
        saveRequest: mutation.saveRequest,
        reminder: reminder,
        reminderID: reminderID,
        operation: "delete"
      )
      for hashtag in explicitHashtagObjects(in: context)
      where normalizedTagKey(hashtag.name) == tagKey {
        context.removeHashtag(hashtag)
        changedCount += 1
      }
    }

    guard changedCount > 0 else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: "delete",
        message: "ReminderKit tag delete found no explicit hashtag membership to mutate.",
        details: [
          "tag": tagName,
          "affected_reminder_count": "\(reminderIDs.count)",
        ]
      )
    }
    try save(
      saveRequest: mutation.saveRequest,
      operation: "delete",
      details: [
        "tag": tagName,
        "affected_reminder_count": "\(reminderIDs.count)",
      ]
    )
  }

  private static func addTag(
    _ tag: String,
    to context: REMReminderHashtagContextChangeItem
  ) {
    guard
      !hashtagObjects(in: context).contains(where: {
        normalizedTagKey($0.name) == normalizedTagKey(tag)
      })
    else {
      return
    }
    _ = context.addHashtag(withType: explicitTagType, name: tag)
  }

  private static func editableHashtagContext(
    store: REMStore,
    reminder: Any,
    reminderID: String,
    operation: String
  ) throws -> (saveRequest: REMSaveRequest, hashtagContext: REMReminderHashtagContextChangeItem) {
    guard let saveRequest = REMSaveRequest(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: ["reminder_id": reminderID]
      )
    }

    let hashtagContext = try editableHashtagContext(
      saveRequest: saveRequest,
      reminder: reminder,
      reminderID: reminderID,
      operation: operation
    )
    return (saveRequest, hashtagContext)
  }

  private static func editableBatchMutation(
    operation: String,
    reminderIDs: [String]
  ) throws -> (store: REMStore, saveRequest: REMSaveRequest) {
    guard let store = REMStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["affected_reminder_count": "\(reminderIDs.count)"]
      )
    }
    guard let saveRequest = REMSaveRequest(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: ["affected_reminder_count": "\(reminderIDs.count)"]
      )
    }
    return (store, saveRequest)
  }

  private static func editableHashtagContext(
    saveRequest: REMSaveRequest,
    reminder: Any,
    reminderID: String,
    operation: String
  ) throws -> REMReminderHashtagContextChangeItem {
    guard
      let changeItem = saveRequest.updateReminder(reminder) as? REMReminderChangeItem,
      let hashtagContext = changeItem.hashtagContext
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit reminder hashtag context was unavailable.",
        details: ["reminder_id": reminderID]
      )
    }
    return hashtagContext
  }

  private static func fetchReminder(
    reminderID: String,
    operation: String
  ) throws -> (store: REMStore, reminder: Any) {
    guard let store = REMStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["reminder_id": reminderID]
      )
    }
    let reminder = try fetchReminder(reminderID: reminderID, store: store, operation: operation)
    return (store, reminder)
  }

  private static func fetchReminder(
    reminderID: String,
    store: REMStore,
    operation: String
  ) throws -> Any {
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
    return reminder
  }

  private static func save(
    saveRequest: REMSaveRequest,
    operation: String,
    reminderID: String
  ) throws {
    try save(
      saveRequest: saveRequest,
      operation: operation,
      details: ["reminder_id": reminderID]
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

  private static func hashtagObjects(
    in context: REMReminderHashtagContextChangeItem
  ) -> [REMHashtag] {
    guard let hashtags = context.hashtags else {
      return []
    }
    return hashtags.compactMap { $0 as? REMHashtag }
  }

  private static func explicitHashtagObjects(
    in context: REMReminderHashtagContextChangeItem
  ) -> [REMHashtag] {
    hashtagObjects(in: context).filter { $0.type == explicitTagType }
  }

  private static func normalizedReminderIDs(_ reminderIDs: [String]) -> [String] {
    Array(
      Set(
        reminderIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
          .filter { !$0.isEmpty })
    )
    .sorted()
  }

  private static func normalizedTags(_ tags: [String]) -> [String] {
    var seen: Set<String> = []
    var result: [String] = []
    for tag in tags {
      let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
      let key = normalizedTagKey(trimmed)
      guard !trimmed.isEmpty, seen.insert(key).inserted else {
        continue
      }
      result.append(trimmed)
    }
    return result
  }

  private static func normalizedTagKey(_ tag: String) -> String {
    tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      (
        "REMReminderHashtagContextChangeItem",
        NSClassFromString("REMReminderHashtagContextChangeItem") != nil
      ),
      ("REMHashtag", NSClassFromString("REMHashtag") != nil),
      (
        "REMStore.fetchReminderWithDACalendarItemUniqueIdentifier:inList:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withDACalendarItemUniqueIdentifier:inList:error:))
        )
      ),
      (
        "REMSaveRequest.updateReminder:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateReminder(_:)))
      ),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMReminderHashtagContextChangeItem.addHashtagWithType:name:",
        REMReminderHashtagContextChangeItem.instancesRespond(
          to: NSSelectorFromString("addHashtagWithType:name:"))
      ),
      (
        "REMReminderHashtagContextChangeItem.removeAllHashtags",
        REMReminderHashtagContextChangeItem.instancesRespond(
          to: #selector(REMReminderHashtagContextChangeItem.removeAllHashtags))
      ),
      (
        "REMReminderHashtagContextChangeItem.removeHashtag:",
        REMReminderHashtagContextChangeItem.instancesRespond(
          to: #selector(REMReminderHashtagContextChangeItem.removeHashtag(_:)))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
