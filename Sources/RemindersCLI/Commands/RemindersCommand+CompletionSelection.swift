import Foundation
import Utility

extension RemindersCommand {
  func reminderMutationIdentities(ids: [String]) throws -> [ReminderMutationIdentity] {
    try ids.map { try reminderMutationIdentity(id: $0) }
  }

  func completionBatchMutation(
    identities: [ReminderMutationIdentity],
    completed: Bool,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = completed ? "reminders.complete-many" : "reminders.uncomplete-many"
    let changedIDs =
      identities
      .filter { $0.reminder.isCompleted != completed }
      .map(\.reminder.id)

    return try mutation(
      operation: operation,
      scopeDigest: reminderBatchCompletionScopeDigest(identities: identities, completed: completed),
      summary: reminderBatchCompletionSummary(identities: identities, completed: completed),
      options: options
    ) {
      let ids = identities.map(\.reminder.id)
      let reminders = try setRemindersCompleted(ids: ids, completed: completed)
      return ReminderMutationResult(
        operation: operation,
        changed: !changedIDs.isEmpty,
        reminders: reminders,
        changedIDs: changedIDs,
        requestedCount: ids.count,
        changedCount: changedIDs.count
      )
    }
  }

  func matchingCompletionContext(_ options: CLIOptions, completed: Bool) throws
    -> ReminderMatchingCompletionContext
  {
    let listSelector = try requiredOption("list", options: options)
    let searchText = try matchingSearchText(options.targetOption("query"))
    let dueFromText = options.targetOption("due-from")
    let dueToText = options.targetOption("due-to")
    guard searchText != nil || dueFromText != nil || dueToText != nil else {
      throw CLIError(
        code: .validationError,
        message:
          "`complete-matching` and `uncomplete-matching` require `--query`, `--due-from`, or `--due-to`."
      )
    }

    let dueFrom = try optionalDateBoundary(dueFromText, role: .lower)
    let dueTo = try optionalDateBoundary(dueToText, role: .upper)
    if let dueFrom, let dueTo, dueFrom >= dueTo {
      throw CLIError(
        code: .validationError,
        message: "`--due-from` must be earlier than `--due-to`."
      )
    }

    let list = try reminderList(selector: listSelector)
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError, message: "Reminder list does not allow modifications.",
        details: ["list": list.title])
    }

    let query = ReminderQuery(
      listSelector: list.id,
      completion: completed ? .incomplete : .completed,
      dueFrom: dueFrom,
      dueTo: dueTo,
      searchText: searchText,
      limit: try mutationCandidateLimit(options)
    )
    let candidates = try listReminders(query)
    let identities = try reminderMutationIdentities(ids: candidates.map(\.id))
    let candidateIDs = identities.map(\.reminder.id)
    let identityHash = sha256Hex(identities.map(\.scopeDigest).joined(separator: ","))
    let bindingPayload = [
      "\(completed)",
      list.id,
      searchText ?? "",
      dueFromText ?? "",
      dueToText ?? "",
      candidateIDs.joined(separator: ","),
      identityHash,
    ].joined(separator: "|")

    return ReminderMatchingCompletionContext(
      identities: identities,
      scopeDigest: "reminder-matching-completion:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "list_id": list.id,
        "list_title": list.title,
        "query": searchText ?? "",
        "due_from": dueFromText ?? "",
        "due_to": dueToText ?? "",
        "candidate_count": "\(candidateIDs.count)",
        "candidate_ids": candidateIDs.joined(separator: ","),
        "candidate_ids_sha256": sha256Hex(candidateIDs.joined(separator: ",")),
        "identity_hash": identityHash,
        "target_completed": "\(completed)",
      ]
    )
  }

  func matchingCompletionMutation(
    context: ReminderMatchingCompletionContext,
    completed: Bool,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = completed ? "reminders.complete-matching" : "reminders.uncomplete-matching"
    let changedIDs = context.identities
      .filter { $0.reminder.isCompleted != completed }
      .map(\.reminder.id)

    return try mutation(
      operation: operation,
      scopeDigest: context.scopeDigest,
      summary: context.summaryFields,
      options: options
    ) {
      let ids = context.identities.map(\.reminder.id)
      let reminders = try setRemindersCompleted(ids: ids, completed: completed)
      return ReminderMutationResult(
        operation: operation,
        changed: !changedIDs.isEmpty,
        reminders: reminders,
        changedIDs: changedIDs,
        requestedCount: ids.count,
        changedCount: changedIDs.count
      )
    }
  }

  func cleanupCompletedPlan(_ options: CLIOptions) throws -> ReminderCleanupPlan {
    let list = try reminderList(selector: try requiredOption("list", options: options))
    guard list.allowsContentModifications else {
      throw CLIError(
        code: .validationError, message: "Reminder list does not allow modifications.",
        details: ["list": list.title])
    }

    let completedBeforeText = try requiredOption("completed-before", options: options)
    let completedBefore = try parseDateBoundary(completedBeforeText, role: .lower)
    let query = ReminderQuery(
      listSelector: list.id,
      completion: .completed,
      completedBefore: completedBefore,
      limit: try commandLimit(options)
    )
    let candidates = try listReminders(query)
    let ids = candidates.map(\.id)
    let bindingPayload = [
      list.id,
      completedBeforeText,
      ids.joined(separator: ","),
      candidates.map(cleanupCandidateScopeDigest).joined(separator: ","),
    ].joined(separator: "|")

    return ReminderCleanupPlan(
      candidates: candidates,
      scopeDigest: "reminder-cleanup-completed:\(sha256Hex(bindingPayload))",
      summaryFields: [
        "list_id": list.id,
        "list_title": list.title,
        "completed_before": completedBeforeText,
        "candidate_count": "\(candidates.count)",
        "candidate_ids": ids.joined(separator: ","),
        "candidate_ids_sha256": sha256Hex(ids.joined(separator: ",")),
      ]
    )
  }
}
