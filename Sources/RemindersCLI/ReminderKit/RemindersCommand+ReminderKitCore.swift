import Foundation
import ReminderKit
import Utility

extension RemindersCommand {

  func fetchReminderKitLists() throws -> [ReminderListRecord] {
    let store = try coreReminderKitStore(operation: "lists")
    let lists = try reminderKitFetchLists(store: store, operation: "lists")
    return lists.map(coreReminderListRecord).sorted {
      $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
    }
  }

  func fetchReminderKitListSources() throws -> [ReminderListSourceRecord] {
    let store = try coreReminderKitStore(operation: "sources")
    var error: AnyObject?
    let accounts = store.fetchAccountsWithError(&error) as? [REMAccount] ?? []
    if accounts.isEmpty, let error {
      throw coreReminderKitError(
        operation: "sources",
        message: "ReminderKit could not fetch accounts.",
        details: (error as? NSError).map { CLIError.diagnosticDetails(for: $0) } ?? [:]
      )
    }
    return accounts.map { account in
      var listError: AnyObject?
      let lists = account.fetchListsWithError(&listError) as? [REMList] ?? []
      return ReminderListSourceRecord(
        id: coreObjectIDString(account.remObjectID),
        title: account.displayName ?? account.name ?? "",
        sourceType: coreReminderAccountType(account.type),
        reminderListCount: lists.count
      )
    }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
  }

  func fetchDefaultReminderKitListSource() throws -> ReminderListSourceRecord {
    let store = try coreReminderKitStore(operation: "default-source")
    var error: AnyObject?
    if let account = store.fetchDefaultAccountWithError(&error) as? REMAccount {
      var listError: AnyObject?
      let lists = account.fetchListsWithError(&listError) as? [REMList] ?? []
      return ReminderListSourceRecord(
        id: coreObjectIDString(account.remObjectID),
        title: account.displayName ?? account.name ?? "",
        sourceType: coreReminderAccountType(account.type),
        reminderListCount: lists.count
      )
    }
    throw coreReminderKitError(
      operation: "default-source",
      message: "ReminderKit default account was not available.",
      details: ["error": reminderKitErrorSummary(error)]
    )
  }

  func fetchReminderKitReminders(_ query: ReminderQuery) throws -> [ReminderSummary] {
    let store = try coreReminderKitStore(operation: "list-reminders")
    let lists = try coreResolveLists(store: store, selector: query.listSelector)
    let reminders = try reminderKitFetchReminders(
      store: store, lists: lists, operation: "list-reminders")
    let listTitles = Dictionary(
      uniqueKeysWithValues: lists.map {
        (coreObjectIDString($0.remObjectID), $0.displayName ?? $0.name ?? "")
      })
    return
      reminders
      .filter { coreMatchesCompletion($0, filter: query.completion) }
      .filter { coreMatchesCompletedBefore($0, before: query.completedBefore) }
      .filter { coreMatchesDueRange($0, from: query.dueFrom, to: query.dueTo) }
      .filter { reminder in
        guard let text = query.searchText?.trimmingCharacters(in: .whitespacesAndNewlines),
          !text.isEmpty
        else {
          return true
        }
        let haystack = [reminder.titleAsString ?? "", reminder.notesAsString ?? ""].joined(
          separator: "\n")
        return haystack.localizedCaseInsensitiveContains(text)
      }
      .sorted { lhs, rhs in
        let lhsDue = reminderDueDate(lhs.dueDateComponents) ?? Date.distantFuture
        let rhsDue = reminderDueDate(rhs.dueDateComponents) ?? Date.distantFuture
        if lhsDue != rhsDue {
          return lhsDue < rhsDue
        }
        return (lhs.titleAsString ?? "").localizedCaseInsensitiveCompare(rhs.titleAsString ?? "")
          == .orderedAscending
      }
      .prefix(query.limit)
      .map { coreReminderSummary($0, listTitles: listTitles) }
  }

  func readReminderKitReminder(id: String) throws -> ReminderDetail? {
    let store = try coreReminderKitStore(operation: "read")
    guard let reminder = try coreFetchReminder(store: store, id: id, operation: "read") else {
      return nil
    }
    return coreReminderDetail(reminder)
  }

  func createReminderWithReminderKit(_ draft: ReminderCreateDraft) throws -> ReminderDetail {
    let store = try coreReminderKitStore(operation: "create")
    let list = try coreResolveList(store: store, selector: draft.listId, operation: "create")
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "create")
    guard let listChange = saveRequest.updateList(list) as? REMListChangeItem else {
      throw coreReminderKitError(
        operation: "create",
        message: "ReminderKit list change item could not be updated.",
        details: ["list_id": coreObjectIDString(list.remObjectID)]
      )
    }
    guard
      let change = saveRequest.addReminder(
        withTitle: draft.title,
        toListChangeItem: listChange
      ) as? REMReminderChangeItem
    else {
      throw coreReminderKitError(
        operation: "create",
        message: "ReminderKit reminder change item could not be created.",
        details: ["list_id": coreObjectIDString(list.remObjectID)]
      )
    }
    try coreApplyDraft(draft, to: change)
    try coreSaveReminderKit(saveRequest, operation: "create")

    let createdObjectID = coreObjectIDString(change.remObjectID)
    let deadline = Date().addingTimeInterval(10)
    var lastDirectFetchError: AnyObject?
    var lastListFetchError: AnyObject?

    repeat {
      lastDirectFetchError = nil
      if let created = store.fetchReminder(
        withObjectID: change.remObjectID,
        fetchOptions: nil,
        error: &lastDirectFetchError
      ) as? REMReminder {
        return coreReminderDetail(created)
      }

      lastListFetchError = nil
      if let dataView = REMRemindersDataView(store: store),
        let reminders = dataView.fetchReminders(
          withListID: list.remObjectID,
          includingSubtasks: true,
          includingCompleted: true,
          error: &lastListFetchError
        ) as? [REMReminder],
        let created = reminders.first(where: {
          coreObjectIDString($0.remObjectID) == createdObjectID
        })
      {
        return coreReminderDetail(created)
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    throw coreReminderKitError(
      operation: "create",
      message: "ReminderKit could not fetch reminder after creation.",
      details: [
        "reminder_object_id": createdObjectID,
        "direct_fetch_error": reminderKitErrorSummary(lastDirectFetchError),
        "list_fetch_error": reminderKitErrorSummary(lastListFetchError),
      ]
    )
  }

  func updateReminderWithReminderKit(id: String, patch: ReminderPatch) throws -> ReminderDetail {
    let store = try coreReminderKitStore(operation: "update")
    guard let reminder = try coreFetchReminder(store: store, id: id, operation: "update") else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "update")
    guard let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem else {
      throw coreReminderKitError(
        operation: "update",
        message: "ReminderKit reminder change item could not be updated.",
        details: ["id": id]
      )
    }
    if let listID = patch.listId {
      let list = try coreResolveList(store: store, selector: listID, operation: "update")
      change.listID = list.remObjectID
    }
    try coreApplyPatch(patch, to: change)
    try coreSaveReminderKit(saveRequest, operation: "update")
    return coreReminderDetail(store.refreshReminder(reminder) as? REMReminder ?? reminder)
  }

  func setReminderCompletedWithReminderKit(
    id: String,
    completed: Bool,
    completedAt: Date? = nil
  ) throws -> ReminderDetail {
    let store = try coreReminderKitStore(operation: completed ? "complete" : "uncomplete")
    guard let reminder = try coreFetchReminder(store: store, id: id, operation: "complete") else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "complete")
    guard let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem else {
      throw coreReminderKitError(
        operation: "complete",
        message: "ReminderKit reminder change item could not be updated.",
        details: ["id": id]
      )
    }
    change.completed = completed
    change.completionDate = completed ? (completedAt ?? Date()) : nil
    try coreSaveReminderKit(saveRequest, operation: "complete")
    return coreReminderDetail(store.refreshReminder(reminder) as? REMReminder ?? reminder)
  }

  func setRemindersCompletedWithReminderKit(ids: [String], completed: Bool) throws
    -> [ReminderDetail]
  {
    try ids.map { try setReminderCompletedWithReminderKit(id: $0, completed: completed) }
  }

  func deleteReminderWithReminderKit(id: String) throws -> Bool {
    let store = try coreReminderKitStore(operation: "delete")
    guard let reminder = try coreFetchReminder(store: store, id: id, operation: "delete") else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "delete")
    guard let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem else {
      throw coreReminderKitError(
        operation: "delete",
        message: "ReminderKit reminder change item could not be updated.",
        details: ["id": id]
      )
    }
    change.removeFromList()
    try coreSaveReminderKit(saveRequest, operation: "delete")
    return true
  }

  func deleteRemindersWithReminderKit(ids: [String]) throws -> [String] {
    var deleted: [String] = []
    for id in ids {
      if try deleteReminderWithReminderKit(id: id) {
        deleted.append(id)
      }
    }
    return deleted
  }

  func createReminderListWithReminderKit(title: String, sourceID: String) throws
    -> ReminderListRecord
  {
    let store = try coreReminderKitStore(operation: "list-create")
    let account = try coreResolveAccount(store: store, sourceID: sourceID, operation: "list-create")
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "list-create")
    guard let accountChange = saveRequest.updateAccount(account) as? REMAccountChangeItem else {
      throw coreReminderKitError(
        operation: "list-create",
        message: "ReminderKit account change item could not be updated.",
        details: ["source_id": sourceID]
      )
    }
    guard
      let change = saveRequest.addList(
        withName: title,
        toAccountChangeItem: accountChange
      ) as? REMListChangeItem
    else {
      throw coreReminderKitError(
        operation: "list-create",
        message: "ReminderKit list change item could not be created.",
        details: ["source_id": sourceID, "title": title]
      )
    }
    try coreSaveReminderKit(saveRequest, operation: "list-create")
    guard let list = store.fetchList(withObjectID: change.remObjectID, error: nil) as? REMList
    else {
      throw coreReminderKitError(
        operation: "list-create", message: "ReminderKit could not fetch list after creation.")
    }
    return coreReminderListRecord(list)
  }

  func deleteReminderListWithReminderKit(id: String) throws -> Bool {
    let store = try coreReminderKitStore(operation: "list-delete")
    let list = try coreResolveList(store: store, selector: id, operation: "list-delete")
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "list-delete")
    guard let change = saveRequest.updateList(list) as? REMListChangeItem else {
      throw coreReminderKitError(
        operation: "list-delete",
        message: "ReminderKit list change item could not be updated.",
        details: ["id": id]
      )
    }
    _ = change.removeFromAccountAllowingUndo()
    try coreSaveReminderKit(saveRequest, operation: "list-delete")
    return true
  }

  func preflightFlaggedMutation() throws {}

  func preflightFlaggedMutation(reminderID: String?) throws {
    guard let reminderID else { return }
    let store = try coreReminderKitStore(operation: "flag-preflight")
    _ = try coreFetchReminder(store: store, id: reminderID, operation: "flag-preflight")
  }

  func setFlagged(reminderID: String, flagged: Bool) throws {
    let store = try coreReminderKitStore(operation: "flag")
    guard let reminder = try coreFetchReminder(store: store, id: reminderID, operation: "flag")
    else {
      throw CLIError(
        code: .notFound, message: "Reminder was not found.", details: ["id": reminderID])
    }
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "flag")
    guard let change = saveRequest.updateReminder(reminder) as? REMReminderChangeItem else {
      throw coreReminderKitError(
        operation: "flag",
        message: "ReminderKit reminder change item could not be updated.",
        details: ["id": reminderID]
      )
    }
    change.flagged = flagged ? 1 : 0
    try coreSaveReminderKit(saveRequest, operation: "flag")
  }

  func preflightListAppearanceMutation(listID: String?) throws {
    guard let listID else { return }
    let store = try coreReminderKitStore(operation: "list-appearance-preflight")
    _ = try coreResolveList(store: store, selector: listID, operation: "list-appearance-preflight")
  }

  func updateReminderListAppearance(listID: String, patch: ReminderListPatch) throws {
    let store = try coreReminderKitStore(operation: "list-appearance")
    let list = try coreResolveList(store: store, selector: listID, operation: "list-appearance")
    let saveRequest = try coreReminderKitSaveRequest(store: store, operation: "list-appearance")
    guard let change = saveRequest.updateList(list) as? REMListChangeItem else {
      throw coreReminderKitError(
        operation: "list-appearance",
        message: "ReminderKit list change item could not be updated.",
        details: ["list_id": listID]
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
    try coreSaveReminderKit(saveRequest, operation: "list-appearance")
  }

  func reminderKitReadAccessDoctorCheck() -> CLIDoctorCheck {
    do {
      let store = try coreReminderKitStore(operation: "doctor-read-access")
      var accountError: AnyObject?
      let accounts = store.fetchAccountsWithError(&accountError) as? [REMAccount] ?? []

      let lists: [REMList]
      var listFailure: Error?
      do {
        lists = try reminderKitFetchLists(store: store, operation: "doctor-read-access")
      } catch {
        lists = []
        listFailure = error
      }

      let reminders: [REMReminder]
      var reminderFailure: Error?
      do {
        reminders = try reminderKitFetchReminders(
          store: store, lists: lists, operation: "doctor-read-access")
      } catch {
        reminders = []
        reminderFailure = error
      }

      var smartListError: AnyObject?
      let smartLists = store.fetchCustomSmartListsWithError(&smartListError) as? [Any] ?? []

      var sectionCount = 0
      var sectionErrors: [String] = []
      for list in lists.prefix(10) {
        var sectionError: AnyObject?
        let sections =
          store.fetchListSections(
            withListObjectID: list.remObjectID,
            error: &sectionError
          ) as? [Any] ?? []
        sectionCount += sections.count
        if let sectionError {
          sectionErrors.append(reminderKitErrorSummary(sectionError))
        }
      }

      var details: [String: String] = [
        "mechanism": "reminderkit",
        "accounts": "\(accounts.count)",
        "lists": "\(lists.count)",
        "reminders_sample": "\(reminders.count)",
        "custom_smart_lists": "\(smartLists.count)",
        "sections_sample": "\(sectionCount)",
        "sampled_lists_for_sections": "\(min(lists.count, 10))",
      ]
      if let accountError {
        details["accounts_error"] = reminderKitErrorSummary(accountError)
      }
      if let listFailure {
        details["lists_error"] = reminderKitErrorSummary(listFailure)
      }
      if let reminderFailure {
        details["reminders_error"] = reminderKitErrorSummary(reminderFailure)
      }
      if let smartListError {
        details["smart_lists_error"] = reminderKitErrorSummary(smartListError)
      }
      if !sectionErrors.isEmpty {
        details["section_errors"] = sectionErrors.prefix(3).joined(separator: "\n")
      }

      let status: CLIDoctorStatus = listFailure != nil || reminderFailure != nil ? .warning : .ok
      return CLIDoctorCheck(
        name: "reminderkit_read_access",
        status: status,
        message:
          "ReminderKit read APIs are available for accounts, lists, reminders, Smart Lists, and list sections.",
        details: details
      )
    } catch {
      return CLIDoctorCheck(
        name: "reminderkit_read_access",
        status: .backendUnavailable,
        message: "ReminderKit read APIs could not be checked.",
        details: CLIError.diagnosticDetails(for: error)
      )
    }
  }
}
