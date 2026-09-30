import Foundation

public protocol SafariAutomating: Sendable {
  func listWindows() throws -> [SafariWindowRecord]
  func listTabs(windowIndex: Int?) throws -> [SafariTabRecord]
  func currentTab(windowIndex: Int?) throws -> SafariTabRecord?
  func readPage(
    windowIndex: Int,
    tabIndex: Int,
    includeText: Bool,
    includeSource: Bool,
    maxBytes: Int
  ) throws -> SafariPageRecord
  func selectTab(windowIndex: Int, tabIndex: Int) throws -> SafariTabRecord
  func openTab(url: URL, windowIndex: Int?) throws -> SafariTabRecord
  func navigateTab(windowIndex: Int, tabIndex: Int, url: URL) throws -> SafariTabRecord
  func closeTab(windowIndex: Int, tabIndex: Int) throws -> Bool
  func addReadingListItem(url: URL, title: String?, previewText: String?) throws -> Bool
  func searchWeb(query: String, windowIndex: Int?, tabIndex: Int?) throws -> Bool
  func showBookmarks() throws -> Bool
  func emailContents(windowIndex: Int, tabIndex: Int) throws -> Bool
  func evaluateJavaScript(
    windowIndex: Int,
    tabIndex: Int,
    script: String,
    maxBytes: Int
  ) throws -> SafariJavaScriptResult
  func showExtensionsPreferences(extensionID: String) throws -> Bool
  func dispatchMessageToExtension(payloadJSON: String) throws -> Bool
  func showPrivacyReport() throws -> Bool
}

public protocol SafariTabGroupReading: Sendable {
  func diagnoseTabGroups() throws -> SafariTabGroupsDiagnoseResponse
  func listWindows(includeRestorable: Bool, verbose: Bool) throws
    -> SafariTabGroupWindowsResponse
  func readWindow(id: String, verbose: Bool) throws -> SafariSnapshotWindowResponse?
  func windowProfile(id: String, verbose: Bool) throws -> SafariProfileRecord?
  func listWindowTabs(windowID: String, verbose: Bool) throws -> SafariSnapshotWindowTabsResponse?
  func listProfiles(verbose: Bool) throws -> [SafariProfileRecord]
  func readProfile(id: String, verbose: Bool) throws -> SafariProfileRecord?
  func listTabGroups(profileID: String?, includeHidden: Bool, verbose: Bool) throws
    -> SafariTabGroupsResponse
  func readTabGroup(id: String, verbose: Bool) throws -> SafariTabGroupResponse?
}

public protocol SafariTabGroupMutating: Sendable {
  func createTabGroup(name: String, url: URL?, profileID: String?) throws -> Bool
  func renameTabGroup(id: String, name: String) throws -> Bool
  func deleteTabGroup(id: String) throws -> Bool
  func addTabToGroup(id: String, url: URL, title: String?) throws -> Bool
  func removeTabFromGroup(id: String, tabID: String) throws -> Bool
  func selectTabGroup(id: String, windowIndex: Int?) throws -> Bool
  func openTabGroup(id: String, windowIndex: Int?) throws -> Bool
}
