import Foundation
import ReminderKit
import Utility

let reminderKitEarlyReminderMinuteUnit: Int64 = 64

func coreReminderKitStore(operation: String) throws -> REMStore {
  guard let store = REMStore() else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit store could not be created."
    )
  }
  return store
}

func coreReminderKitSaveRequest(store: REMStore, operation: String) throws -> REMSaveRequest
{
  guard let saveRequest = REMSaveRequest(store: store) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit save request could not be created."
    )
  }
  return saveRequest
}

func coreSaveReminderKit(_ saveRequest: REMSaveRequest, operation: String) throws {
  var error: AnyObject?
  guard saveRequest.saveSynchronouslyWithError(&error) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit save failed.",
      details: ["save_error": error.map(String.init(describing:)) ?? ""]
    )
  }
}

func reminderKitFetchLists(store: REMStore, operation: String) throws -> [REMList] {
  var accountError: AnyObject?
  let accounts = store.fetchAccountsWithError(&accountError) as? [REMAccount] ?? []
  var lists: [REMList] = []
  var listErrors: [String] = []

  for account in accounts {
    var listError: AnyObject?
    let accountLists = account.fetchListsAndSublistsWithError(&listError) as? [REMList] ?? []
    lists.append(contentsOf: accountLists)
    if let listError {
      let accountTitle =
        account.displayName ?? account.name ?? coreObjectIDString(account.remObjectID)
      listErrors.append("\(accountTitle): \(String(describing: listError))")
    }
  }

  if lists.isEmpty, let accountError {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit could not fetch reminder accounts.",
      details: ["accounts_error": String(describing: accountError)]
    )
  }
  if lists.isEmpty, !listErrors.isEmpty {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit could not fetch reminder lists.",
      details: ["list_errors": listErrors.prefix(3).joined(separator: "\n")]
    )
  }
  return lists
}

func reminderKitFetchReminders(store: REMStore, lists: [REMList], operation: String) throws
  -> [REMReminder]
{
  guard let dataView = REMRemindersDataView(store: store) else {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit reminders data view could not be created."
    )
  }
  var reminders: [REMReminder] = []
  var reminderErrors: [String] = []

  for list in lists {
    var reminderError: AnyObject?
    let listReminders =
      dataView.fetchReminders(
        withListID: list.remObjectID,
        includingSubtasks: true,
        includingCompleted: true,
        error: &reminderError
      ) as? [REMReminder] ?? []
    reminders.append(contentsOf: listReminders)
    if let reminderError {
      let listTitle = list.displayName ?? list.name ?? coreObjectIDString(list.remObjectID)
      reminderErrors.append("\(listTitle): \(String(describing: reminderError))")
    }
  }

  if reminders.isEmpty, !reminderErrors.isEmpty {
    throw coreReminderKitError(
      operation: operation,
      message: "ReminderKit could not fetch reminders.",
      details: ["reminder_errors": reminderErrors.prefix(3).joined(separator: "\n")]
    )
  }
  return reminders
}

func coreResolveLists(store: REMStore, selector: String?) throws -> [REMList] {
  let lists = try reminderKitFetchLists(store: store, operation: "resolve-list")
  guard let selector, !selector.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    return lists
  }
  let matches = lists.filter { coreReminderListMatches($0, selector: selector) }
  guard !matches.isEmpty else {
    throw CLIError(
      code: .notFound, message: "Reminder list was not found.", details: ["list": selector])
  }
  guard matches.count == 1 else {
    throw CLIError(
      code: .ambiguousIdentity, message: "Reminder list matched multiple lists.",
      details: ["list": selector])
  }
  return matches
}

func coreResolveList(store: REMStore, selector: String?, operation: String) throws
  -> REMList
{
  if let selector, !selector.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    return try coreResolveLists(store: store, selector: selector).first!
  }
  var error: AnyObject?
  if let list = store.fetchDefaultListWithError(&error) as? REMList {
    return list
  }
  let lists = try reminderKitFetchLists(store: store, operation: operation)
  if let list = lists.first {
    return list
  }
  throw coreReminderKitError(
    operation: operation,
    message: "ReminderKit default list was not available.",
    details: ["error": error.map(String.init(describing:)) ?? ""]
  )
}

func coreResolveAccount(store: REMStore, sourceID: String, operation: String) throws
  -> REMAccount
{
  var error: AnyObject?
  let accounts = store.fetchAccountsWithError(&error) as? [REMAccount] ?? []
  if sourceID.isEmpty, let account = store.fetchDefaultAccountWithError(&error) as? REMAccount {
    return account
  }
  let matches = accounts.filter {
    coreObjectIDString($0.remObjectID) == sourceID
      || ($0.displayName ?? $0.name ?? "").localizedCaseInsensitiveCompare(sourceID) == .orderedSame
  }
  if let match = matches.first, matches.count == 1 {
    return match
  }
  if sourceID.isEmpty, let account = accounts.first {
    return account
  }
  throw coreReminderKitError(
    operation: operation,
    message: "ReminderKit account was not found.",
    details: ["source_id": sourceID, "error": error.map(String.init(describing:)) ?? ""]
  )
}

func coreFetchReminder(store: REMStore, id: String, operation: String) throws
  -> REMReminder?
{
  var error: AnyObject?
  if let reminder = store.fetchReminder(
    withDACalendarItemUniqueIdentifier: id,
    inList: nil,
    error: &error
  ) as? REMReminder {
    return reminder
  }
  if let objectID = coreREMObjectID(entity: "REMCDReminder", identifier: id),
    let reminder = store.fetchReminder(withObjectID: objectID, fetchOptions: nil, error: &error)
      as? REMReminder
  {
    return reminder
  }
  return nil
}

func coreApplyDraft(_ draft: ReminderCreateDraft, to change: REMReminderChangeItem) throws {
  change.title = NSAttributedString(string: draft.title)
  change.notes = draft.notes.map(NSAttributedString.init(string:))
  change.priority = UInt64(max(0, draft.priority))
  change.dueDateComponents = try reminderDueComponents(
    value: draft.dueDate, kind: draft.dueDateKind)
  if let url = try reminderURL(draft.url) {
    change.icsUrl = url
  }
  try coreReplaceAlarms(
    on: change, location: draft.locationTrigger, absoluteDates: draft.absoluteAlarmDates,
    earlyMinutes: draft.earlyReminderMinutesBefore)
  try coreReplaceRepeat(on: change, repeatRule: draft.repeatRule)
}

func coreApplyPatch(_ patch: ReminderPatch, to change: REMReminderChangeItem) throws {
  if let title = patch.title {
    change.title = NSAttributedString(string: title)
  }
  if let notes = patch.notes {
    change.notes = NSAttributedString(string: notes)
  }
  if patch.clearNotes {
    change.notes = nil
  }
  if let url = try reminderURL(patch.url) {
    change.icsUrl = url
  }
  if patch.clearUrl {
    change.icsUrl = nil
  }
  if let priority = patch.priority {
    change.priority = UInt64(max(0, priority))
  }
  if patch.clearDueDate {
    change.dueDateComponents = nil
  } else if patch.dueDate != nil || patch.dueDateKind != nil {
    change.dueDateComponents = try reminderDueComponents(
      value: patch.dueDate, kind: patch.dueDateKind)
  }
  if patch.clearAlarms || !(patch.absoluteAlarmDates ?? []).isEmpty || patch.clearLocation
    || patch.locationTrigger != nil
    || patch.clearEarlyReminders || !(patch.earlyReminderMinutesBefore ?? []).isEmpty
  {
    try coreReplaceAlarms(
      on: change,
      location: patch.clearLocation ? nil : patch.locationTrigger,
      absoluteDates: patch.clearAlarms ? [] : (patch.absoluteAlarmDates ?? []),
      earlyMinutes: patch.clearEarlyReminders ? [] : (patch.earlyReminderMinutesBefore ?? [])
    )
  }
  if patch.clearRepeat {
    change.removeAllRecurrenceRules()
  } else if let repeatRule = patch.repeatRule {
    try coreReplaceRepeat(on: change, repeatRule: repeatRule)
  }
}

func coreReplaceAlarms(
  on change: REMReminderChangeItem,
  location: ReminderLocationTrigger?,
  absoluteDates: [Date],
  earlyMinutes: [Int]
) throws {
  change.removeAllAlarms()
  for date in absoluteDates.sorted() {
    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: date)
    let trigger = REMAlarmDateTrigger(dateComponents: components)
    _ = change.addAlarm(withTrigger: trigger)
  }
  if let location {
    guard let structured = REMStructuredLocation(title: location.title) else {
      throw coreReminderKitError(
        operation: "alarm-location",
        message: "ReminderKit structured location could not be created.")
    }
    if let latitude = location.latitude, let longitude = location.longitude {
      structured.latitude = latitude
      structured.longitude = longitude
    }
    if let radius = location.radiusMeters {
      structured.radius = radius
    }
    let proximity: Int64 = location.proximity == "leaving" ? 2 : 1
    guard
      let trigger = REMAlarmLocationTrigger(structuredLocation: structured, proximity: proximity)
    else {
      throw coreReminderKitError(
        operation: "alarm-location", message: "ReminderKit location trigger could not be created.")
    }
    _ = change.addAlarm(withTrigger: trigger)
  }
  for minutes in earlyMinutes.sorted() {
    let delta = REMDueDateDeltaInterval(
      unitInteger: reminderKitEarlyReminderMinuteUnit,
      count: Int64(minutes)
    )
    _ = change.dueDateDeltaAlertContext.addDueDateDeltaAlert(withDueDateDelta: delta)
  }
}

func coreReplaceRepeat(on change: REMReminderChangeItem, repeatRule: ReminderRepeatRule?)
  throws
{
  change.removeAllRecurrenceRules()
  guard let repeatRule else {
    return
  }
  _ = change.addRecurrenceRule(
    withFrequency: coreReminderRepeatFrequency(repeatRule.frequency),
    interval: Int64(repeatRule.interval),
    daysOfTheWeek: nil,
    daysOfTheMonth: repeatRule.daysOfMonth.isEmpty
      ? nil : repeatRule.daysOfMonth.map(NSNumber.init(value:)),
    monthsOfTheYear: repeatRule.monthsOfYear.isEmpty
      ? nil : repeatRule.monthsOfYear.map(NSNumber.init(value:)),
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: repeatRule.setPositions.isEmpty
      ? nil : repeatRule.setPositions.map(NSNumber.init(value:)),
    end: coreReminderRepeatEnd(repeatRule)
  )
}

func coreReminderRepeatEnd(_ repeatRule: ReminderRepeatRule) -> REMRecurrenceEnd? {
  if let count = repeatRule.occurrenceCount {
    return REMRecurrenceEnd.recurrenceEnd(withOccurrenceCount: UInt64(count)) as? REMRecurrenceEnd
  }
  if let until = repeatRule.until {
    return REMRecurrenceEnd.recurrenceEnd(withEndDate: until) as? REMRecurrenceEnd
  }
  return nil
}

func coreReminderRepeatFrequency(_ value: String) -> Int64 {
  switch value {
  case "hourly": return 4
  case "weekly": return 1
  case "monthly": return 2
  case "yearly": return 3
  default: return 0
  }
}

func coreReminderListMatches(_ list: REMList, selector: String) -> Bool {
  coreObjectIDString(list.remObjectID) == selector
    || list.externalIdentifier == selector
    || list.daExternalIdentificationTag == selector
    || (list.displayName ?? list.name ?? "").localizedCaseInsensitiveCompare(selector)
      == .orderedSame
}

func coreMatchesCompletion(_ reminder: REMReminder, filter: ReminderCompletionFilter)
  -> Bool
{
  switch filter {
  case .all: return true
  case .completed: return coreReminderIsCompleted(reminder)
  case .incomplete: return !coreReminderIsCompleted(reminder)
  }
}

func coreMatchesCompletedBefore(_ reminder: REMReminder, before: Date?) -> Bool {
  guard let before else { return true }
  guard coreReminderIsCompleted(reminder), let completion = reminder.completionDate else { return false }
  return completion < before
}

func coreMatchesDueRange(_ reminder: REMReminder, from: Date?, to: Date?) -> Bool {
  guard from != nil || to != nil else { return true }
  guard let due = reminderDueDate(reminder.dueDateComponents) else { return false }
  if let from, due < from { return false }
  if let to, due >= to { return false }
  return true
}

func coreReminderListRecord(_ list: REMList) -> ReminderListRecord {
  ReminderListRecord(
    id: coreObjectIDString(list.remObjectID),
    title: list.displayName ?? list.name ?? "",
    sourceId: coreObjectIDString(list.account?.remObjectID),
    sourceTitle: list.account?.displayName ?? list.account?.name ?? "",
    allowsContentModifications: !list.daIsReadOnly && !list.daIsImmutable,
    isPinned: list.isPinned,
    displayOrder: Int(list.daDisplayOrder),
    sortingStyle: list.sortingStyle,
    showingLargeAttachments: list.showingLargeAttachments,
    color: coreReminderColorHex(list.color),
    hasColor: list.color != nil
  )
}

func coreReminderSummary(_ reminder: REMReminder, listTitles: [String: String])
  -> ReminderSummary
{
  let due = reminderDue(reminder.dueDateComponents)
  let listID = coreObjectIDString(reminder.list?.remObjectID ?? reminder.listID)
  return ReminderSummary(
    id: coreReminderID(reminder),
    listId: listID,
    listTitle: reminder.list?.displayName ?? reminder.list?.name ?? listTitles[listID] ?? "",
    title: reminder.titleAsString ?? reminder.title?.string ?? "",
    isCompleted: coreReminderIsCompleted(reminder),
    completedAt: reminder.completionDate.map(formatDate),
    createdAt: reminder.creationDate.map(formatDate),
    modifiedAt: reminder.lastModifiedDate.map(formatDate),
    url: reminder.icsUrl?.absoluteString,
    priority: Int(reminder.priority),
    dueDate: due.value,
    dueDateKind: due.kind,
    repeatRule: coreReminderRepeatRule(reminder),
    locationTriggers: coreLocationTriggers(reminder),
    earlyReminderMinutesBefore: coreEarlyReminderMinutesBefore(reminder),
    absoluteAlarmDates: coreAbsoluteAlarmDates(reminder),
    isFlagged: reminder.flagged != 0,
    isUrgent: reminder.isUrgentStateEnabledForCurrentUser,
    parentReminderId: reminder.parentReminderID.map(coreObjectIDString),
    parentReminderTitle: reminder.parent?.titleAsString,
    subtaskCount: 0
  )
}

func coreReminderIsCompleted(_ reminder: REMReminder) -> Bool {
  reminder.completionDate != nil
}

func coreReminderDetail(_ reminder: REMReminder) -> ReminderDetail {
  let summary = coreReminderSummary(reminder, listTitles: [:])
  return ReminderDetail(
    id: summary.id,
    listId: summary.listId,
    listTitle: summary.listTitle,
    title: summary.title,
    notes: reminder.notesAsString ?? reminder.notes?.string,
    url: summary.url,
    isCompleted: summary.isCompleted,
    completedAt: summary.completedAt,
    createdAt: summary.createdAt,
    modifiedAt: summary.modifiedAt,
    priority: summary.priority,
    dueDate: summary.dueDate,
    dueDateKind: summary.dueDateKind,
    repeatRule: summary.repeatRule,
    locationTriggers: summary.locationTriggers,
    earlyReminderMinutesBefore: summary.earlyReminderMinutesBefore,
    absoluteAlarmDates: summary.absoluteAlarmDates,
    tags: summary.tags,
    isFlagged: summary.isFlagged,
    isUrgent: summary.isUrgent,
    sectionId: summary.sectionId,
    sectionTitle: summary.sectionTitle,
    parentReminderId: summary.parentReminderId,
    parentReminderTitle: summary.parentReminderTitle,
    subtaskCount: summary.subtaskCount,
    attachments: summary.attachments,
    assignments: summary.assignments,
    messagingContactHandles: summary.messagingContactHandles
  )
}

func coreReminderID(_ reminder: REMReminder) -> String {
  if let externalIdentifier = reminder.daCalendarItemUniqueIdentifier, !externalIdentifier.isEmpty {
    return externalIdentifier
  }
  return coreObjectIDString(reminder.remObjectID)
}

func coreReminderRepeatRule(_ reminder: REMReminder) -> ReminderRepeatRule? {
  guard let recurrenceRules = reminder.recurrenceRules,
    let rule = recurrenceRules.first as? REMRecurrenceRule
  else {
    return nil
  }
  return ReminderRepeatRule(
    frequency: coreReminderRepeatFrequencyName(rule.frequency),
    interval: Int(rule.interval),
    occurrenceCount: {
      let count = rule.recurrenceEnd?.occurrenceCount ?? 0
      return count > 0 ? Int(count) : nil
    }(),
    until: rule.recurrenceEnd?.endDate,
    daysOfMonth: sortedUniqueInts(
      (rule.daysOfTheMonth ?? []).compactMap { ($0 as? NSNumber)?.intValue }),
    monthsOfYear: sortedUniqueInts(
      (rule.monthsOfTheYear ?? []).compactMap { ($0 as? NSNumber)?.intValue }),
    setPositions: sortedUniqueInts(
      (rule.setPositions ?? []).compactMap { ($0 as? NSNumber)?.intValue })
  )
}

func coreReminderRepeatFrequencyName(_ value: Int64) -> String {
  switch value {
  case 4: return "hourly"
  case 1: return "weekly"
  case 2: return "monthly"
  case 3: return "yearly"
  default: return "daily"
  }
}

func coreReminderColor(_ value: String) -> REMColor? {
  let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  switch normalized {
  case "black": return REMColor.blackColor() as? REMColor
  case "blue": return REMColor.blueColor() as? REMColor
  case "brown": return REMColor.brownColor() as? REMColor
  case "clear": return REMColor.clear() as? REMColor
  case "cyan": return REMColor.cyanColor() as? REMColor
  case "gray", "grey": return REMColor.grayColor() as? REMColor
  case "green": return REMColor.greenColor() as? REMColor
  case "light-gray", "lightgray", "light grey": return REMColor.lightGrayColor() as? REMColor
  case "magenta": return REMColor.magentaColor() as? REMColor
  case "orange": return REMColor.orangeColor() as? REMColor
  case "purple": return REMColor.purpleColor() as? REMColor
  case "red": return REMColor.redColor() as? REMColor
  case "white": return REMColor.whiteColor() as? REMColor
  case "yellow": return REMColor.yellowColor() as? REMColor
  default:
    return coreReminderHexColor(value)
      ?? REMColor.color(withHexString: value) as? REMColor
      ?? REMColor.color(withHexString: normalized) as? REMColor
  }
}

private func coreReminderHexColor(_ value: String) -> REMColor? {
  var hex = value.trimmingCharacters(in: .whitespacesAndNewlines)
  if hex.hasPrefix("#") {
    hex.removeFirst()
  }
  if hex.lowercased().hasPrefix("0x") {
    hex = String(hex.dropFirst(2))
  }
  guard (hex.count == 6 || hex.count == 8), hex.allSatisfy(\.isHexDigit),
    let raw = UInt64(hex, radix: 16)
  else {
    return nil
  }

  let red: UInt64
  let green: UInt64
  let blue: UInt64
  let alpha: UInt64
  if hex.count == 8 {
    red = (raw >> 24) & 0xff
    green = (raw >> 16) & 0xff
    blue = (raw >> 8) & 0xff
    alpha = raw & 0xff
  } else {
    red = (raw >> 16) & 0xff
    green = (raw >> 8) & 0xff
    blue = raw & 0xff
    alpha = 0xff
  }

  return REMColor.color(
    withRed: Double(red) / 255,
    green: Double(green) / 255,
    blue: Double(blue) / 255,
    alpha: Double(alpha) / 255
  ) as? REMColor
}

func coreReminderColorHex(_ color: REMColor?) -> String? {
  guard let color else { return nil }
  let red = coreReminderColorByte(color.red)
  let green = coreReminderColorByte(color.green)
  let blue = coreReminderColorByte(color.blue)
  let alpha = coreReminderColorByte(color.alpha)
  if alpha < 255 {
    return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
  }
  return String(format: "#%02X%02X%02X", red, green, blue)
}

private func coreReminderColorByte(_ value: Double) -> Int {
  let clamped = min(max(value, 0), 1)
  return Int((clamped * 255).rounded())
}

func coreAbsoluteAlarmDates(_ reminder: REMReminder) -> [Date] {
  uniqueSortedDates(
    (reminder.alarms ?? []).compactMap { alarm in
      guard let alarm = alarm as? REMAlarm,
        let trigger = alarm.trigger as? REMAlarmDateTrigger,
        let date = trigger.dateComponents.date
      else {
        return nil
      }
      return date
    })
}

func coreLocationTriggers(_ reminder: REMReminder) -> [ReminderLocationTrigger] {
  (reminder.alarms ?? []).compactMap { alarm -> ReminderLocationTrigger? in
    guard let alarm = alarm as? REMAlarm,
      let trigger = alarm.trigger as? REMAlarmLocationTrigger
    else {
      return nil
    }
    let location = trigger.structuredLocation
    let latitude = location?.latitude
    let longitude = location?.longitude
    return ReminderLocationTrigger(
      title: location?.title ?? "",
      latitude: latitude,
      longitude: longitude,
      radiusMeters: location?.radius,
      proximity: trigger.proximity == 2 ? "leaving" : "entering"
    )
  }
}

func coreEarlyReminderMinutesBefore(_ reminder: REMReminder) -> [Int] {
  let alerts = reminder.dueDateDeltaAlertContext?.dueDateDeltaAlerts ?? []
  return sortedUniqueInts(
    alerts.compactMap { alert in
      guard let value = alert as? NSObject,
        let delta = value.value(forKey: "dueDateDelta") as? REMDueDateDeltaInterval
      else {
        return nil
      }
      return Int(delta.count)
    })
}

func coreREMObjectID(entity: String, identifier: String) -> REMObjectID? {
  let urlString =
    identifier.hasPrefix("x-apple-reminderkit://")
    ? identifier
    : "x-apple-reminderkit://\(entity)/\(identifier)"
  guard let url = URL(string: urlString) else {
    return nil
  }
  return REMObjectID.objectID(withURL: url) as? REMObjectID
}

func coreObjectIDString(_ objectID: REMObjectID?) -> String {
  guard let objectID else {
    return ""
  }
  return objectID.urlRepresentation?.absoluteString ?? objectID.stringRepresentation
    ?? String(describing: objectID)
}

func coreReminderAccountType(_ type: Int64) -> String {
  switch type {
  case 1: return "local"
  case 2: return "calDAV"
  case 3: return "exchange"
  default: return "\(type)"
  }
}

func coreReminderKitError(
  operation: String,
  message: String,
  details: [String: String] = [:]
) -> CLIError {
  CLIError(
    code: .backendUnavailable,
    message: message,
    details: details.merging(
      ["mechanism": "reminderkit", "operation": operation],
      uniquingKeysWith: { current, _ in current }
    )
  )
}
