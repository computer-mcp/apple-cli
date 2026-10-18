import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderRepeatWriter {
  static let capability = "repeat_rules"
  private static let hourlyFrequency: Int64 = 4

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

  static func setRepeat(reminderID: String, repeatRule: ReminderRepeatRule?) throws {
    try preflight(reminderID: nil)
    let operation = repeatRule == nil ? "clear" : "set"
    let details = [
      "reminder_id": reminderID,
      "repeat": reminderRepeatSummary(repeatRule),
    ]
    if let repeatRule {
      try validateRepeatRuleSupported(repeatRule, details: details)
    }

    let resolved = try fetchReminder(reminderID: reminderID, operation: operation)
    guard let saveRequest = try reminderKitNewSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: details
      )
    }
    guard let changeItem = saveRequest.updateReminder(resolved.reminder) as? REMReminderChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit reminder change item could not be updated.",
        details: details
      )
    }

    if repeatRule != nil {
      try validateHourlyRecurrenceSupported(changeItem: changeItem, details: details)
    }
    changeItem.removeAllRecurrenceRules()
    if let repeatRule {
      _ = changeItem.addRecurrenceRule(
        withFrequency: hourlyFrequency,
        interval: Int64(repeatRule.interval),
        end: recurrenceEnd(repeatRule)
      )
    }

    var saveError: AnyObject?
    guard try reminderKitSaveSynchronously(saveRequest, error: &saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: details.merging(
          ["save_error": reminderKitErrorSummary(saveError)],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  private static func validateRepeatRuleSupported(
    _ repeatRule: ReminderRepeatRule,
    details: [String: String]
  ) throws {
    guard repeatRule.frequency == "hourly" else {
      throw reminderKitUnsupportedAction(
        capability: capability,
        details: details.merging(
          ["frequency": repeatRule.frequency],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
    guard repeatRule.daysOfWeek.isEmpty,
      repeatRule.weekdayPositions.isEmpty,
      repeatRule.daysOfMonth.isEmpty,
      repeatRule.monthsOfYear.isEmpty,
      repeatRule.setPositions.isEmpty
    else {
      throw CLIError(
        code: .validationError,
        message: "Hourly repeat does not support calendar component filters.",
        details: details
      )
    }
  }

  private static func validateHourlyRecurrenceSupported(
    changeItem: REMReminderChangeItem,
    details: [String: String]
  ) throws {
    guard let capabilities = changeItem.accountCapabilities else {
      return
    }
    guard capabilities.supportsHourlyRecurrence else {
      throw CLIError(
        code: .validationError,
        message: "The selected Reminders account does not support hourly repeats.",
        details: details
      )
    }
  }

  private static func recurrenceEnd(_ repeatRule: ReminderRepeatRule) -> REMRecurrenceEnd? {
    if let occurrenceCount = repeatRule.occurrenceCount {
      return REMRecurrenceEnd.recurrenceEnd(withOccurrenceCount: UInt64(occurrenceCount))
        as? REMRecurrenceEnd
    }
    if let until = repeatRule.until {
      return REMRecurrenceEnd.recurrenceEnd(withEndDate: until) as? REMRecurrenceEnd
    }
    return nil
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
    let externalReminder = store.fetchReminder(
      withDACalendarItemUniqueIdentifier: reminderID,
      inList: nil,
      error: &fetchError
    )
    if let externalReminder {
      return (store, externalReminder)
    }

    if let objectID = remObjectID(entity: "REMCDReminder", identifier: reminderID),
      let reminder = store.fetchReminder(
        withObjectID: objectID, fetchOptions: nil, error: &fetchError)
    {
      return (store, reminder)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the reminder by external or ReminderKit identifier.",
      details: [
        "reminder_id": reminderID,
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

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      ("REMRecurrenceEnd", NSClassFromString("REMRecurrenceEnd") != nil),
      ("REMAccountCapabilities", NSClassFromString("REMAccountCapabilities") != nil),
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
        "REMStore.fetchReminderWithObjectID:fetchOptions:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withObjectID:fetchOptions:error:))
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
        "REMReminderChangeItem.removeAllRecurrenceRules",
        REMReminderChangeItem.instancesRespond(to: NSSelectorFromString("removeAllRecurrenceRules"))
      ),
      (
        "REMReminderChangeItem.addRecurrenceRuleWithFrequency:interval:end:",
        REMReminderChangeItem.instancesRespond(
          to: NSSelectorFromString("addRecurrenceRuleWithFrequency:interval:end:")
        )
      ),
      (
        "REMAccountCapabilities.supportsHourlyRecurrence",
        REMAccountCapabilities.instancesRespond(
          to: NSSelectorFromString("supportsHourlyRecurrence"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}
