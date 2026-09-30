import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func preferredAccount(
    store: REMStore,
    sourceID: String,
    operation: String,
    details: [String: String]
  ) throws -> REMAccount {
    var fetchError: AnyObject?
    if let accounts = store.fetchAccountsWithError(&fetchError) as? [REMAccount] {
      let matches = accounts.filter { accountMatches($0, sourceID: sourceID) }
      if let match = matches.first {
        return match
      }
    }
    if let account = store.fetchPrimaryActiveCloudKitAccountWithError(&fetchError) as? REMAccount {
      return account
    }
    if let account = store.fetchDefaultAccountWithError(&fetchError) as? REMAccount {
      return account
    }
    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit account could not be resolved for Smart List mutation.",
      details: details.merging(
        ["fetch_error": fetchError.map(String.init(describing:)) ?? ""],
        uniquingKeysWith: { _, new in new }
      )
    )
  }

  static func validateCustomSmartListsSupported(
    account: REMAccount?,
    operation: String,
    details: [String: String]
  ) throws {
    guard let account else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit Smart List account is missing.",
        details: details
      )
    }
    guard account.capabilities?.supportsCustomSmartLists == true else {
      throw CLIError(
        code: .validationError,
        message: "The selected Reminders account does not support custom Smart Lists.",
        details: details.merging(
          ["account": account.name ?? account.externalIdentifier ?? ""],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }

  static func accountChangeItem(
    saveRequest: REMSaveRequest,
    account: REMAccount,
    operation: String,
    details: [String: String]
  ) throws -> REMAccountChangeItem {
    guard let accountChange = saveRequest.updateAccount(account) as? REMAccountChangeItem else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit account change item could not be updated.",
        details: details
      )
    }
    return accountChange
  }

  static func reminderKitStore(
    operation: String,
    details: [String: String]
  ) throws -> REMStore {
    guard let store = REMStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: details
      )
    }
    return store
  }

  static func reminderKitSaveRequest(
    store: REMStore,
    operation: String,
    details: [String: String]
  ) throws -> REMSaveRequest {
    guard let saveRequest = REMSaveRequest(store: store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: details
      )
    }
    return saveRequest
  }

  static func save(
    _ saveRequest: REMSaveRequest,
    operation: String,
    details: [String: String]
  ) throws {
    var saveError: AnyObject?
    guard saveRequest.saveSynchronouslyWithError(&saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: details.merging(
          ["save_error": saveError.map(String.init(describing:)) ?? ""],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
  }
}
