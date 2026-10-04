import Dispatch
import Foundation
import Utility

func reminderUpdateScopeDigest(identity: ReminderMutationIdentity, patch: ReminderPatch) -> String {
  let parts: [String] = [
    identity.scopeDigest,
    patch.listId ?? "",
    patch.title ?? "",
    patch.notes ?? "",
    "\(patch.clearNotes)",
    patch.url ?? "",
    "\(patch.clearUrl)",
    patch.priority.map(String.init) ?? "",
    patch.dueDate ?? "",
    patch.dueDateKind ?? "",
    "\(patch.clearDueDate)",
    reminderLocationSummary(patch.locationTrigger),
    "\(patch.clearLocation)",
    patch.earlyReminderMinutesBefore.map(minuteList) ?? "",
    "\(patch.clearEarlyReminders)",
    patch.absoluteAlarmDates.map(dateList) ?? "",
    "\(patch.clearAlarms)",
    reminderRepeatSummary(patch.repeatRule),
    "\(patch.clearRepeat)",
    patch.flagged.map(String.init) ?? "",
    patch.sectionTitle ?? "",
    patch.tags?.joined(separator: ",") ?? "",
    patch.addTags.joined(separator: ","),
    patch.removeTags.joined(separator: ","),
    "\(patch.clearTags)",
    patch.urgent.map(String.init) ?? "",
    patch.messagingPerson ?? "",
    "\(patch.clearMessagingPerson)",
  ]
  let payload = parts.joined(separator: "|")
  return "reminder-update:\(sha256Hex(payload))"
}

func reminderListUpdateScopeDigest(
  identity: ReminderListMutationIdentity,
  patch: ReminderListPatch
) -> String {
  let parts: [String] = [
    identity.scopeDigest,
    patch.title ?? "",
    patch.listType ?? "",
    patch.color ?? "",
    patch.icon ?? "",
    patch.pinned.map(String.init) ?? "",
    patch.sortingStyle ?? "",
    patch.showingLargeAttachments.map(String.init) ?? "",
  ]
  return "reminder-list-update:\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderListCreateScopeDigest(identity: ReminderListCreateIdentity) -> String {
  let parts: [String] = [
    identity.title,
    identity.source.id,
    identity.source.title,
    identity.source.sourceType,
    "\(identity.source.reminderListCount)",
    identity.scopeDigest,
  ]
  return "reminder-list-create:\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderListReorderScopeDigest(identity: ReminderListReorderIdentity) -> String {
  let parts: [String] = [
    identity.scopeDigest,
    identity.list.id,
    identity.anchorList.id,
    identity.placement.relation,
  ]
  return "reminder-list-reorder:\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderSectionMutationScopeDigest(
  identity: ReminderSectionMutationIdentity,
  operation: String,
  sectionTitle: String,
  newTitle: String? = nil,
  anchorSectionTitle: String? = nil,
  placement: ReminderSectionReorderPlacement? = nil
) -> String {
  let parts: [String] = [
    identity.scopeDigest,
    operation,
    sectionTitle,
    newTitle ?? "",
    anchorSectionTitle ?? "",
    placement?.relation ?? "",
    placement?.anchorSectionId ?? "",
  ]
  return "reminder-section-\(operation):\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderSectionMutationSummary(
  operation: String,
  sectionTitle: String,
  newTitle: String? = nil,
  anchorSectionTitle: String? = nil,
  placement: ReminderSectionReorderPlacement? = nil
) -> [String: String] {
  [
    "operation": operation,
    "section": sectionTitle,
    "new_title": newTitle ?? "",
    "anchor_section": anchorSectionTitle ?? "",
    "placement": placement?.relation ?? "",
  ]
}

func reminderTagMutationScopeDigest(
  identity: ReminderTagMutationIdentity,
  operation: String,
  newName: String? = nil
) -> String {
  let parts: [String] = [
    identity.scopeDigest,
    operation,
    newName ?? "",
  ]
  return "reminder-tag-\(operation):\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderTagMutationSummary(
  operation: String,
  tag: ReminderTagRecord,
  newName: String? = nil
) -> [String: String] {
  [
    "operation": operation,
    "tag_id": tag.id,
    "tag": tag.name,
    "new_name": newName ?? "",
  ]
}

func reminderSubtaskCreateScopeDigest(identity: ReminderSubtaskCreateIdentity) -> String {
  let parts: [String] = [
    identity.parent.scopeDigest,
    identity.title,
  ]
  return "reminder-subtask-create:\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderSubtaskMoveScopeDigest(identity: ReminderSubtaskMoveIdentity, operation: String) -> String {
  let parts: [String] = [
    identity.scopeDigest,
    identity.parent?.scopeDigest ?? "",
    operation,
  ]
  return "reminder-subtask-\(operation):\(sha256Hex(parts.joined(separator: "|")))"
}

func reminderBatchCompletionScopeDigest(identities: [ReminderMutationIdentity], completed: Bool)
  -> String
{
  let payload = [
    "\(completed)",
    identities.map(\.scopeDigest).joined(separator: ","),
  ].joined(separator: "|")
  return "reminder-completion-batch:\(sha256Hex(payload))"
}

func reminderBatchCompletionSummary(
  identities: [ReminderMutationIdentity],
  completed: Bool
) -> [String: String] {
  let ids = identities.map(\.reminder.id)
  let identityHash = sha256Hex(identities.map(\.scopeDigest).joined(separator: ","))
  return [
    "ids": ids.joined(separator: ","),
    "reminder_count": "\(ids.count)",
    "target_completed": "\(completed)",
    "identity_hash": identityHash,
  ]
}

func reminderPatchSummary(_ patch: ReminderPatch) -> [String: String] {
  [
    "new_list_id": patch.listId ?? "",
    "new_title": patch.title ?? "",
    "notes_changed": "\(patch.notes != nil || patch.clearNotes)",
    "url_changed": "\(patch.url != nil || patch.clearUrl)",
    "new_url": patch.url ?? "",
    "new_priority": patch.priority.map(String.init) ?? "",
    "new_due": patch.dueDate ?? "",
    "clear_due": "\(patch.clearDueDate)",
    "new_location": reminderLocationSummary(patch.locationTrigger),
    "clear_location": "\(patch.clearLocation)",
    "new_early_reminder_minutes_before": patch.earlyReminderMinutesBefore.map(minuteList) ?? "",
    "clear_early_reminders": "\(patch.clearEarlyReminders)",
    "new_alarm_at": patch.absoluteAlarmDates.map(dateList) ?? "",
    "clear_alarms": "\(patch.clearAlarms)",
    "new_repeat": reminderRepeatSummary(patch.repeatRule),
    "clear_repeat": "\(patch.clearRepeat)",
    "new_flagged": patch.flagged.map(String.init) ?? "",
    "new_urgent": patch.urgent.map(String.init) ?? "",
    "messaging_person_changed": "\(patch.hasMessagingPersonChanges)",
    "new_messaging_person": patch.messagingPerson ?? "",
    "clear_messaging_person": "\(patch.clearMessagingPerson)",
    "section_changed": "\(patch.hasSectionChanges)",
    "new_section": patch.sectionTitle ?? "",
    "tags_changed": "\(patch.tags != nil || !patch.addTags.isEmpty || !patch.removeTags.isEmpty || patch.clearTags)",
    "new_tags": patch.tags?.joined(separator: ",") ?? "",
    "add_tags": patch.addTags.joined(separator: ","),
    "remove_tags": patch.removeTags.joined(separator: ","),
    "clear_tags": "\(patch.clearTags)",
  ]
}

func reminderListPatchSummary(_ patch: ReminderListPatch) -> [String: String] {
  [
    "new_title": patch.title ?? "",
    "new_type": patch.listType ?? "",
    "new_color": patch.color ?? "",
    "new_icon": patch.icon ?? "",
    "new_pinned": patch.pinned.map(String.init) ?? "",
    "new_sort": patch.sortingStyle ?? "",
    "new_show_large_attachments": patch.showingLargeAttachments.map(String.init) ?? "",
  ]
}

func reminderListDeleteReminderSnapshotHash(_ reminders: [ReminderSummary]) -> String {
  let payload = reminders
    .sorted { $0.id < $1.id }
    .map { reminder in
      [
        reminder.id,
        reminder.listId,
        reminder.title,
        "\(reminder.isCompleted)",
        reminder.completedAt ?? "",
        reminder.createdAt ?? "",
        reminder.modifiedAt ?? "",
        reminder.dueDate ?? "",
        reminder.dueDateKind ?? "",
        "\(reminder.priority)",
        reminderRepeatSummary(reminder.repeatRule),
        reminderLocationSummary(reminder.locationTriggers),
        minuteList(reminder.earlyReminderMinutesBefore),
        dateList(reminder.absoluteAlarmDates),
      ].joined(separator: "\u{1F}")
    }
    .joined(separator: "\u{1E}")
  return sha256Hex(payload)
}

func cleanupCandidateScopeDigest(_ reminder: ReminderSummary) -> String {
  [
    reminder.id,
    reminder.listId,
    reminder.title,
    "\(reminder.isCompleted)",
    reminder.completedAt ?? "",
    reminder.createdAt ?? "",
    reminder.modifiedAt ?? "",
    reminder.url ?? "",
    reminder.dueDate ?? "",
    reminderLocationSummary(reminder.locationTriggers),
    minuteList(reminder.earlyReminderMinutesBefore),
    dateList(reminder.absoluteAlarmDates),
    reminderRepeatSummary(reminder.repeatRule),
    "\(reminder.priority)",
  ].joined(separator: ":")
}
