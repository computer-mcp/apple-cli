import Foundation
import Utility

extension RemindersCommand {
  func privateObjectPreservationSnapshot(
    id: String,
    patch: ReminderPatch
  ) throws -> RemindersItemDebugResponse? {
    guard patch.listId != nil || patch.hasSectionChanges else {
      return nil
    }

    guard let reminder = try readReminderKitReminder(id: id) else {
      return nil
    }
    return try sqliteReader.debugItem(reminder: reminder)
  }

  func repeatRulePreservationSnapshot(id: String, patch: ReminderPatch) throws
    -> ReminderRepeatRule?
  {
    guard patch.listId != nil, patch.repeatRule == nil, patch.clearRepeat == false else {
      return nil
    }
    return try readReminderKitReminder(id: id)?.repeatRule
  }

  func locationPreservationSnapshot(id: String, patch: ReminderPatch) throws
    -> [ReminderLocationTrigger]?
  {
    guard patch.listId != nil, patch.locationTrigger == nil, patch.clearLocation == false else {
      return nil
    }
    return try readReminderKitReminder(id: id)?.locationTriggers
  }

  func absoluteAlarmPreservationSnapshot(id: String, patch: ReminderPatch) throws -> [Date]? {
    guard patch.listId != nil, patch.absoluteAlarmDates == nil, patch.clearAlarms == false else {
      return nil
    }
    return try readReminderKitReminder(id: id)?.absoluteAlarmDates
  }

  func earlyReminderPreservationSnapshot(id: String, patch: ReminderPatch) throws -> [Int]? {
    guard patch.listId != nil, patch.earlyReminderMinutesBefore == nil,
      patch.clearEarlyReminders == false
    else {
      return nil
    }
    return try readReminderKitReminder(id: id)?.earlyReminderMinutesBefore
  }

  func verifyLocationPreserved(
    expected: [ReminderLocationTrigger]?,
    actual: [ReminderLocationTrigger],
    id: String
  ) throws {
    guard let expected, expected.isEmpty == false, actual != expected else {
      return
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder location trigger was not preserved during list move.",
      details: [
        "verifier": "reminderkit_readback",
        "reminder_id": id,
        "expected_location": reminderLocationSummary(expected),
        "actual_location": reminderLocationSummary(actual),
      ]
    )
  }

  func verifyAbsoluteAlarmsPreserved(expected: [Date]?, actual: [Date], id: String) throws {
    guard let expected, expected.isEmpty == false, uniqueSortedDates(actual) != expected else {
      return
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder alarms were not preserved during list move.",
      details: [
        "verifier": "reminderkit_readback",
        "reminder_id": id,
        "expected_alarm_at": dateList(expected),
        "actual_alarm_at": dateList(actual),
      ]
    )
  }

  func verifyEarlyRemindersPreserved(expected: [Int]?, actual: [Int], id: String) throws {
    guard let expected, expected.isEmpty == false, actual.sorted() != expected.sorted() else {
      return
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder early reminders were not preserved during list move.",
      details: [
        "verifier": "reminderkit_readback",
        "reminder_id": id,
        "expected_early_reminder_minutes_before": minuteList(expected),
        "actual_early_reminder_minutes_before": minuteList(actual),
      ]
    )
  }

  func verifyRepeatRulePreserved(
    expected: ReminderRepeatRule?,
    actual: ReminderRepeatRule?,
    id: String
  ) throws {
    guard let expected, actual != expected else {
      return
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder repeat rule was not preserved during list move.",
      details: [
        "verifier": "reminderkit_readback",
        "reminder_id": id,
        "expected_repeat": reminderRepeatSummary(expected),
        "actual_repeat": reminderRepeatSummary(actual),
      ]
    )
  }

  func verifyPrivateObjectsPreserved(
    snapshot: RemindersItemDebugResponse,
    reminder: ReminderDetail,
    patch: ReminderPatch
  ) throws {
    let ignoredKinds: Set<PrivateObjectSignature.Kind> =
      (patch.url != nil || patch.clearUrl) ? [.visibleURL] : []
    let expected = privateObjectSignatures(snapshot, ignoring: ignoredKinds)
    guard !expected.isEmpty else {
      return
    }

    let deadline = Date().addingTimeInterval(10)
    var lastActual: Set<PrivateObjectSignature> = []
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastActual = privateObjectSignatures(debug, ignoring: ignoredKinds)
        if expected.isSubset(of: lastActual) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    let missing = expected.subtracting(lastActual)
    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_private_object_count": "\(expected.count)",
      "actual_private_object_count": "\(lastActual.count)",
      "missing_private_objects": missing.map(\.description).sorted().joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder private objects could not be verified after moving the reminder.",
      details: details
    )
  }

  func verifySubtaskRelationshipPreserved(
    snapshot: RemindersItemDebugResponse,
    reminder: ReminderDetail
  ) throws {
    let expected = subtaskRelationshipSignatures(snapshot)
    guard !expected.isEmpty else {
      return
    }

    let deadline = Date().addingTimeInterval(10)
    var lastActual: Set<SubtaskRelationshipSignature> = []
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastActual = subtaskRelationshipSignatures(debug)
        if expected.isSubset(of: lastActual) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    let missing = expected.subtracting(lastActual)
    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_subtask_relationship_count": "\(expected.count)",
      "actual_subtask_relationship_count": "\(lastActual.count)",
      "missing_subtask_relationships": missing.map(\.description).sorted().joined(separator: ","),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder subtask relationship could not be verified after moving the reminder.",
      details: details
    )
  }

  fileprivate func privateObjectSignatures(
    _ debug: RemindersItemDebugResponse,
    ignoring ignoredKinds: Set<PrivateObjectSignature.Kind>
  ) -> Set<PrivateObjectSignature> {
    Set(
      debug.privateStoreMatches
        .flatMap(\.objects)
        .compactMap { object in
          guard let signature = PrivateObjectSignature(object) else {
            return nil
          }
          return ignoredKinds.contains(signature.kind) ? nil : signature
        }
    )
  }

  fileprivate func subtaskRelationshipSignatures(
    _ debug: RemindersItemDebugResponse
  ) -> Set<SubtaskRelationshipSignature> {
    Set(debug.privateStoreMatches.compactMap(SubtaskRelationshipSignature.init))
  }
}

private struct PrivateObjectSignature: Hashable, CustomStringConvertible {
  enum Kind: Hashable {
    case visibleURL
    case tag
    case assignment
    case other
  }

  var kind: Kind
  var uti: String
  var url: String
  var fileName: String
  var tagName: String
  var assigneeIdentifier: String
  var personId: String
  var contactLabel: String
  var assignedAtRaw: String

  init?(_ object: RemindersPrivateObjectDebugRecord) {
    let uti = object.uti ?? ""
    let url = object.url ?? ""
    let fileName = object.fileName ?? ""
    let tagName = object.tagCanonicalName ?? object.tagName ?? ""
    let assigneeIdentifier = object.assigneeIdentifier ?? ""
    let personId = object.personId ?? ""
    let contactLabel = object.contactLabel ?? ""
    let assignedAtRaw = object.assignedAtRaw.map { String(describing: $0) } ?? ""
    guard
      !uti.isEmpty || !url.isEmpty || !fileName.isEmpty || !tagName.isEmpty
        || !assigneeIdentifier.isEmpty || !personId.isEmpty || !contactLabel.isEmpty
        || !assignedAtRaw.isEmpty
    else {
      return nil
    }

    if uti == "public.url" && !url.isEmpty {
      self.kind = .visibleURL
    } else if !tagName.isEmpty {
      self.kind = .tag
    } else if !assigneeIdentifier.isEmpty || !personId.isEmpty || !contactLabel.isEmpty
      || !assignedAtRaw.isEmpty
    {
      self.kind = .assignment
    } else {
      self.kind = .other
    }
    self.uti = uti
    self.url = url
    self.fileName = fileName
    self.tagName = tagName
    self.assigneeIdentifier = assigneeIdentifier
    self.personId = personId
    self.contactLabel = contactLabel
    self.assignedAtRaw = assignedAtRaw
  }

  var description: String {
    [uti, url, fileName, tagName, assigneeIdentifier, personId, contactLabel, assignedAtRaw]
      .filter { !$0.isEmpty }.joined(separator: "|")
  }
}

private struct SubtaskRelationshipSignature: Hashable, CustomStringConvertible {
  var parentReminderId: String
  var parentReminderTitle: String
  var subtaskCount: Int

  init?(_ match: RemindersPrivateReminderDebugRecord) {
    let parentReminderId = match.parentReminderId ?? ""
    let parentReminderTitle = match.parentReminderTitle ?? ""
    guard !parentReminderId.isEmpty || !parentReminderTitle.isEmpty || match.subtaskCount > 0 else {
      return nil
    }

    self.parentReminderId = parentReminderId
    self.parentReminderTitle = parentReminderTitle
    self.subtaskCount = match.subtaskCount
  }

  var description: String {
    [parentReminderId, parentReminderTitle, "\(subtaskCount)"].joined(separator: "|")
  }
}
