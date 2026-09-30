import Foundation
import Utility

extension RemindersCommand {
  public func createReminder(_ draft: ReminderCreateDraft) throws -> ReminderDetail {
    let reminderKitRepeatRule = reminderKitRepeatRule(draft.repeatRule)
    if reminderKitRepeatRule != nil {
      try self.preflightRepeatMutation(reminderID: nil)
    }
    if draft.url != nil {
      try self.preflightVisibleURLMutation()
    }

    var created = try createReminderWithReminderKit(reminderKitCreateDraft(draft))

    if let url = draft.url {
      try self.setVisibleURL(reminderID: created.id, url: url)
      try verifyVisibleURL(reminder: created, expectedURL: url)
      let current = try readReminderKitReminder(id: created.id) ?? created
      created = try sqliteReader.enrichReminder(current)
    }

    guard let reminderKitRepeatRule else {
      return created
    }

    try self.setRepeat(reminderID: created.id, repeatRule: reminderKitRepeatRule)
    return try verifyRepeatRule(reminder: created, expected: reminderKitRepeatRule)
  }

  public func updateReminder(id: String, patch: ReminderPatch) throws -> ReminderDetail {
    if patch.flagged != nil {
      try self.preflightFlaggedMutation()
    }
    let metadataPreflightReminder = try proofGatedUpdateReminder(id: id, patch: patch)
    let reminderKitRepeatRule = reminderKitRepeatRule(patch.repeatRule)
    if reminderKitRepeatRule != nil {
      try self.preflightRepeatMutation(reminderID: metadataPreflightReminder?.id ?? id)
    }
    if patch.url != nil || patch.clearUrl {
      try self.preflightVisibleURLMutation(
        reminderID: metadataPreflightReminder?.id ?? id)
    }
    let expectedTags = try expectedTagsAfterMutation(id: id, patch: patch)
    if patch.hasTagChanges {
      try self.preflightTagMutation(reminderID: metadataPreflightReminder?.id ?? id)
    }
    if patch.hasSectionChanges {
      try self.preflightSectionMutation(
        listID: patch.listId ?? metadataPreflightReminder?.listId,
        reminderID: metadataPreflightReminder?.id ?? id
      )
    }
    if patch.urgent != nil {
      try self.preflightUrgentMutation(reminderID: metadataPreflightReminder?.id ?? id)
    }
    if patch.hasMessagingPersonChanges {
      try self.preflightMessagingPersonMutation(
        reminderID: metadataPreflightReminder?.id ?? id
      )
    }

    let locationTriggersToPreserve = try locationPreservationSnapshot(id: id, patch: patch)
    let earlyRemindersToPreserve = try earlyReminderPreservationSnapshot(id: id, patch: patch)
    let alarmsToPreserve = try absoluteAlarmPreservationSnapshot(id: id, patch: patch)
    let repeatRuleToPreserve = try repeatRulePreservationSnapshot(id: id, patch: patch)
    let preservationSnapshot = try privateObjectPreservationSnapshot(id: id, patch: patch)
    let updated = try updateReminderWithReminderKit(id: id, patch: reminderKitCorePatch(patch))
    try verifyLocationPreserved(
      expected: locationTriggersToPreserve, actual: updated.locationTriggers, id: id)
    try verifyEarlyRemindersPreserved(
      expected: earlyRemindersToPreserve,
      actual: updated.earlyReminderMinutesBefore,
      id: id
    )
    try verifyAbsoluteAlarmsPreserved(
      expected: alarmsToPreserve, actual: updated.absoluteAlarmDates, id: id)
    try verifyRepeatRulePreserved(
      expected: repeatRuleToPreserve, actual: updated.repeatRule, id: id)

    if let url = patch.url {
      try self.setVisibleURL(reminderID: updated.id, url: url)
      try verifyVisibleURL(reminder: updated, expectedURL: url)
    } else if patch.clearUrl {
      try self.setVisibleURL(reminderID: updated.id, url: nil)
      try verifyVisibleURL(reminder: updated, expectedURL: nil)
    }
    if let flagged = patch.flagged {
      try self.setFlagged(reminderID: updated.id, flagged: flagged)
      try verifyFlagged(reminder: updated, expectedFlagged: flagged)
    }
    if patch.hasTagChanges {
      try self.updateTags(
        reminderID: updated.id,
        tags: patch.tags,
        addTags: patch.addTags,
        removeTags: patch.removeTags,
        clearTags: patch.clearTags
      )
      try verifyTags(reminder: updated, expectedTags: expectedTags)
    }
    if let sectionTitle = patch.sectionTitle {
      try self.moveReminder(reminderID: updated.id, toSectionTitle: sectionTitle)
      try verifySection(reminder: updated, expectedSectionTitle: sectionTitle)
    }
    if let urgent = patch.urgent {
      try self.setUrgent(reminderID: updated.id, urgent: urgent)
      try verifyUrgent(reminder: updated, expectedUrgent: urgent)
    }
    if let messagingPerson = patch.messagingPerson {
      try self.setMessagingPerson(
        reminderID: updated.id,
        personSelector: messagingPerson
      )
      try verifyMessagingPerson(reminder: updated, expectedPresent: true)
    } else if patch.clearMessagingPerson {
      try self.setMessagingPerson(reminderID: updated.id, personSelector: nil)
      try verifyMessagingPerson(reminder: updated, expectedPresent: false)
    }
    if let reminderKitRepeatRule {
      try self.setRepeat(reminderID: updated.id, repeatRule: reminderKitRepeatRule)
      _ = try verifyRepeatRule(reminder: updated, expected: reminderKitRepeatRule)
    }
    if let preservationSnapshot {
      try verifyPrivateObjectsPreserved(
        snapshot: preservationSnapshot, reminder: updated, patch: patch)
      try verifySubtaskRelationshipPreserved(snapshot: preservationSnapshot, reminder: updated)
    }

    let current = try readReminderKitReminder(id: id) ?? updated
    do {
      return try sqliteReader.enrichReminder(current)
    } catch {
      return current
    }
  }

  func reminderKitRepeatRule(_ repeatRule: ReminderRepeatRule?) -> ReminderRepeatRule? {
    guard let repeatRule, repeatRule.frequency == "hourly" else {
      return nil
    }
    return repeatRule
  }

  func reminderKitCreateDraft(_ draft: ReminderCreateDraft) -> ReminderCreateDraft {
    guard reminderKitRepeatRule(draft.repeatRule) != nil else {
      return draft
    }
    var reminderKitDraft = draft
    reminderKitDraft.repeatRule = nil
    return reminderKitDraft
  }

  func reminderKitCorePatch(_ patch: ReminderPatch) -> ReminderPatch {
    guard reminderKitRepeatRule(patch.repeatRule) != nil else {
      return patch
    }
    var reminderKitCorePatch = patch
    reminderKitCorePatch.repeatRule = nil
    return reminderKitCorePatch
  }

  func verifyRepeatRule(
    reminder: ReminderDetail,
    expected: ReminderRepeatRule
  ) throws -> ReminderDetail {
    let deadline = Date().addingTimeInterval(10)
    var lastReminder: ReminderDetail?
    var lastError: Error?

    repeat {
      do {
        let current = try readReminderKitReminder(id: reminder.id) ?? reminder
        let enriched = try sqliteReader.enrichReminder(current)
        lastReminder = enriched
        if reminderRepeatRuleMatches(enriched.repeatRule, expected) {
          return enriched
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_repeat": reminderRepeatSummary(expected),
      "actual_repeat": reminderRepeatSummary(lastReminder?.repeatRule),
    ]
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }
    throw CLIError(
      code: .backendUnavailable,
      message: "Reminder repeat rule could not be verified.",
      details: details
    )
  }

  func reminderRepeatRuleMatches(
    _ actual: ReminderRepeatRule?,
    _ expected: ReminderRepeatRule
  ) -> Bool {
    guard let actual else {
      return false
    }
    guard actual.frequency == expected.frequency,
      actual.interval == expected.interval,
      actual.occurrenceCount == expected.occurrenceCount,
      actual.daysOfWeek == expected.daysOfWeek,
      actual.weekdayPositions == expected.weekdayPositions,
      actual.daysOfMonth == expected.daysOfMonth,
      actual.monthsOfYear == expected.monthsOfYear,
      actual.setPositions == expected.setPositions
    else {
      return false
    }
    switch (actual.until, expected.until) {
    case (nil, nil):
      return true
    case (let actual?, let expected?):
      return abs(actual.timeIntervalSince(expected)) < 1
    default:
      return false
    }
  }

  func proofGatedUpdateReminder(id: String, patch: ReminderPatch) throws -> ReminderDetail? {
    guard
      patch.url != nil || patch.clearUrl || patch.hasTagChanges || patch.hasSectionChanges
        || patch.urgent != nil || patch.hasMessagingPersonChanges
    else {
      return nil
    }
    guard let reminder = try readReminderKitReminder(id: id) else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }
    return reminder
  }

  public func setReminderCompleted(
    id: String,
    completed: Bool,
    completedAt: Date? = nil
  ) throws -> ReminderDetail {
    try setReminderCompletedWithReminderKit(id: id, completed: completed, completedAt: completedAt)
  }

  public func setRemindersCompleted(ids: [String], completed: Bool) throws -> [ReminderDetail] {
    try setRemindersCompletedWithReminderKit(ids: ids, completed: completed)
  }

  public func deleteReminder(id: String) throws -> Bool {
    try deleteReminderWithReminderKit(id: id)
  }

  public func deleteReminders(ids: [String]) throws -> [String] {
    try deleteRemindersWithReminderKit(ids: ids)
  }
}
