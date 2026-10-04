import Foundation
import ReminderKit

enum ReminderKitNativeMethods {
  static let storeInit = ReminderKitRuntimeMethod(
    owner: "REMStore", selector: "init", returnType: "@")
  static let saveRequestInit = ReminderKitRuntimeMethod(
    owner: "REMSaveRequest", selector: "initWithStore:", returnType: "@", argumentTypes: ["@"])
  static let save = ReminderKitRuntimeMethod(
    owner: "REMSaveRequest", selector: "saveSynchronouslyWithError:",
    returnType: "B", argumentTypes: ["^@"])
  static let fetchAccounts = ReminderKitRuntimeMethod(
    owner: "REMStore", selector: "fetchAccountsWithError:", returnType: "@", argumentTypes: ["^@"])
  static let fetchDefaultList = ReminderKitRuntimeMethod(
    owner: "REMStore", selector: "fetchDefaultListWithError:", returnType: "@", argumentTypes: ["^@"])
  static let fetchDefaultAccount = ReminderKitRuntimeMethod(
    owner: "REMStore", selector: "fetchDefaultAccountWithError:", returnType: "@", argumentTypes: ["^@"])
}

func reminderKitNewStore() throws -> REMStore? {
  try ReminderKitNativeMethods.storeInit.require(operation: "reminders.store.open")
  return REMStore()
}

func reminderKitNewSaveRequest(store: REMStore) throws -> REMSaveRequest? {
  let operation = "reminders.save-request.create"
  try ReminderKitNativeMethods.saveRequestInit.require(operation: operation)
  try ReminderKitNativeMethods.save.require(operation: operation)
  let request = REMSaveRequest(store: store)
  if let request {
    try ReminderKitNativeMethods.save.require(operation: operation, receiver: request)
  }
  return request
}

func reminderKitSaveSynchronously(_ request: REMSaveRequest, error: inout AnyObject?) throws -> Bool {
  try ReminderKitNativeMethods.save.require(operation: "reminders.save", receiver: request)
  return request.saveSynchronouslyWithError(&error)
}
