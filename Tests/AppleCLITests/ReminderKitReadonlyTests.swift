import Foundation
import ReminderKit
import Testing

@testable import RemindersCLI

@Suite(.serialized, .enabled(
  if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_REMINDERKIT_READONLY_TESTS"] == "1",
  "Requires explicit opt-in to reads of the host's Reminders accounts and lists."
))
struct ReminderKitReadonlyTests {
  @Test func realStoreBootstrapAndAccountListReads() throws {
    let store = try coreReminderKitStore(operation: "test.native-read")
    try ReminderKitNativeMethods.fetchAccounts.require(operation: "test.native-read", receiver: store)
    var error: AnyObject?
    let accounts = try #require(store.fetchAccountsWithError(&error) as? [REMAccount])
    #expect(error == nil)
    try #require(!accounts.isEmpty,
      "Native ReminderKit validation requires at least one configured account.")
    let lists = try reminderKitFetchLists(store: store, operation: "test.native-read")
    try #require(!lists.isEmpty,
      "Native ReminderKit validation requires at least one existing list.")
    #expect(lists.allSatisfy { $0.remObjectID != nil })
    // Save signatures are inspected without creating a change request or saving.
    try ReminderKitNativeMethods.saveRequestInit.require(operation: "test.native-read")
    try ReminderKitNativeMethods.save.require(operation: "test.native-read")
  }
}
