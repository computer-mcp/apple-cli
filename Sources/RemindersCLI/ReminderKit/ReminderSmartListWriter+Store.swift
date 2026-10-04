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
    guard let expectedID = try coreREMObjectID(entity: "REMCDAccount", identifier: sourceID) else {
      throw CLIError(code: .validationError, message: "A valid Reminders account ID is required.", details: details)
    }
    let account = try coreResolveAccount(store: store, sourceID: sourceID, operation: operation)
    guard coreObjectIDsMatch(account.remObjectID, expectedID) else {
      throw reminderKitOperationFailed(capability: capability, operation: operation,
        message: "ReminderKit could not verify the selected Smart List account.", details: details)
    }
    return account
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
    guard let store = try reminderKitNewStore() else {
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
    guard let saveRequest = try reminderKitNewSaveRequest(store: store) else {
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
}
