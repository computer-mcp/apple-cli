import Foundation
import SQLite3
import SafariCLI
import Testing
import Utility

@Suite
struct SafariCommandTests {
  @Test func safariWindowsListReturnsJSON() throws {
    let command = SafariCommand(backend: FakeSafariBackend())
    let options = try CLIOptionsFixture.parse(["windows", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let windows = data?["windows"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(windows?.first?["index"] as? Int == 1)
    #expect(windows?.first?["tabCount"] as? Int == 2)
  }

  @Test func safariPagesReadReturnsBoundedTextAndSource() throws {
    let command = SafariCommand(backend: FakeSafariBackend())
    let options = try CLIOptionsFixture.parse([
      "pages", "read", "--window-index", "1", "--tab-index", "1", "--include", "text,source",
      "--max-bytes", "8", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let page = data?["page"] as? [String: Any]

    #expect(page?["text"] as? String == "Visible ")
    #expect(page?["source"] as? String == "<html>Sa")
    #expect(page?["truncated"] as? Bool == true)
  }

  @Test func safariReadOnlyCommandsRejectDryRuns() throws {
    let command = SafariCommand(backend: FakeSafariBackend())
    let options = try CLIOptionsFixture.parse([
      "tabs", "list", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Safari read-only command to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariTabAliasCurrentMatchesTabsCurrent() throws {
    let command = SafariCommand(backend: FakeSafariBackend())
    let options = try CLIOptionsFixture.parse(["tab", "current", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let tab = data?["tab"] as? [String: Any]

    #expect(tab?["id"] as? String == "safari-tab:1:1")
    #expect(tab?["title"] as? String == "Example Domain")
  }

  @Test func safariProfileListReturnsJSON() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse(["profile", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let profiles = data?["profiles"] as? [[String: Any]]

    #expect(profiles?.first?["id"] as? String == "safari-profile:default")
    #expect(profiles?.first?["tabGroupCount"] as? Int == 1)
  }

  @Test func safariTabGroupListReturnsJSON() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse(["tab", "group", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let groups = data?["tabGroups"] as? [[String: Any]]

    #expect(groups?.first?["id"] as? String == "safari-tab-group:row:10")
    #expect(groups?.first?["resolvedTabCount"] as? Int == 1)
  }

  @Test func safariWindowListReturnsSnapshotJSON() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse(["window", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let windows = data?["windows"] as? [[String: Any]]

    #expect(windows?.first?["id"] as? String == "safari-window:row:1")
    #expect(windows?.first?["rawId"] as? Int == 1)
    #expect(windows?.first?["sessionIndex"] as? Int == 1)
  }

  @Test func safariWindowReadReturnsSnapshotJSON() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse([
      "window", "read", "--id", "safari-window:row:1", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let window = data?["window"] as? [String: Any]
    let profile = window?["profile"] as? [String: Any]
    let group = window?["activeTabGroup"] as? [String: Any]

    #expect(window?["id"] as? String == "safari-window:row:1")
    #expect(profile?["id"] as? String == "safari-profile:default")
    #expect(group?["id"] as? String == "safari-tab-group:row:10")
  }

  @Test func safariTabGroupReadReturnsTabs() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse([
      "tab", "group", "read", "--id", "safari-tab-group:row:10", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let group = data?["tabGroup"] as? [String: Any]
    let tabs = data?["tabs"] as? [[String: Any]]

    #expect(group?["id"] as? String == "safari-tab-group:row:10")
    #expect(tabs?.first?["url"] as? String == "https://example.com/")
  }

  @Test func safariWindowProfileAcceptsWindowID() throws {
    let backend = FakeSafariTabGroupBackend()
    let command = SafariCommand(backend: FakeSafariBackend(), tabGroupBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "window", "profile", "--id", "safari-window:row:42", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let profile = data?["profile"] as? [String: Any]

    #expect(profile?["id"] as? String == "safari-profile:default")
    #expect(backend.lastWindowID == "safari-window:row:42")
  }

  @Test func safariWindowTabListReturnsSnapshotTabs() throws {
    let backend = FakeSafariTabGroupBackend()
    let command = SafariCommand(backend: FakeSafariBackend(), tabGroupBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "window", "tab", "list", "--window-id", "safari-window:row:42", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let tabs = data?["tabs"] as? [[String: Any]]

    #expect(tabs?.first?["id"] as? String == "safari-tab:row:11")
    #expect(backend.lastWindowTabWindowID == "safari-window:row:42")
  }

  @Test func safariWindowTabListRejectsWindowIndex() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse([
      "window", "tab", "list", "--window-index", "1", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Safari snapshot window tab list to reject live window indexes.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariTabGroupReadRejectsDryRuns() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: FakeSafariTabGroupBackend()
    )
    let options = try CLIOptionsFixture.parse([
      "tab", "group", "read", "--id", "safari-tab-group:row:10", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Safari Tab Group read to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariTabGroupCreateRequiresAllowExternalDispatchBeforeBackend() throws {
    let backend = FakeSafariTabGroupBackend()
    let command = SafariCommand(backend: FakeSafariBackend(), tabGroupBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "tab", "group", "create", "--name", "Research", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Safari Tab Group create to require the appropriate allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.createdNames.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariTabGroupCreateDryRunAndAllowFlagExecutesCreate() throws {
    let backend = FakeSafariTabGroupBackend()
    let command = SafariCommand(backend: FakeSafariBackend(), tabGroupBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tab", "group", "create", "--name", "Research", "--url", "https://example.com/",
      "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "tab", "group", "create", "--name", "Research", "--url", "https://example.com/",
      "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["operation"] as? String == "safari.tab-group.create")
    #expect(backend.createdNames == ["Research"])
  }

  @Test func safariTabGroupsSQLiteBackendReadsFixtureSnapshot() throws {
    let fixture = try makeSafariTabsSQLiteFixture()
    defer { try? FileManager.default.removeItem(at: fixture.directory) }
    let backend = SafariTabGroupsSQLiteBackend(databasePath: fixture.database.path)

    let diagnostic = try backend.diagnoseTabGroups()
    let profiles = try backend.listProfiles(verbose: false)
    let defaultGroups = try backend.listTabGroups(
      profileID: "safari-profile:default",
      includeHidden: false,
      verbose: false
    )
    let workGroups = try backend.listTabGroups(
      profileID: "safari-profile:row:20",
      includeHidden: false,
      verbose: false
    )
    let group = try #require(
      try backend.readTabGroup(id: "safari-tab-group:row:10", verbose: false))
    let firstWindow = try #require(
      try backend.readWindow(id: "safari-window:row:1", verbose: false))
    let firstWindowProfile = try #require(
      try backend.windowProfile(id: "1", verbose: false))
    let firstWindowTabs = try #require(
      try backend.listWindowTabs(windowID: "1", verbose: false))
    let secondWindow = try #require(
      try backend.readWindow(id: "safari-window:row:2", verbose: false))
    let secondWindowProfile = try #require(
      try backend.windowProfile(id: "safari-window:row:2", verbose: false))
    let windows = try backend.listWindows(includeRestorable: false, verbose: false)
    let restorableWindows = try backend.listWindows(includeRestorable: true, verbose: false)

    #expect(diagnostic.schemaSupported == true)
    #expect(profiles.map(\.id) == ["safari-profile:row:5", "safari-profile:row:20"])
    #expect(profiles.first?.tabGroupParentId == 0)
    #expect(defaultGroups.tabGroups.map(\.id) == ["safari-tab-group:row:10"])
    #expect(workGroups.tabGroups.map(\.id) == ["safari-tab-group:row:21"])
    #expect(group.tabs.first?.url == "https://example.com/")
    #expect(firstWindow.window.activeTabGroup?.id == "safari-tab-group:row:10")
    #expect(firstWindow.window.profile?.id == "safari-profile:row:5")
    #expect(firstWindowProfile.id == "safari-profile:row:5")
    #expect(firstWindowTabs.tabs.first?.url == "https://example.com/")
    #expect(secondWindow.window.activeTabGroup?.id == "safari-tab-group:row:21")
    #expect(secondWindowProfile.id == "safari-profile:row:20")
    #expect(windows.windows.map(\.rawId) == [1, 2])
    #expect(windows.windows.map(\.sessionIndex) == [1, 2])
    #expect(restorableWindows.windows.map(\.rawId) == [1, 2, 3])
    #expect(restorableWindows.windows.last?.sessionIndex == nil)
  }

  @Test func safariTabGroupCreateExecutionFailsClosedWithProductionBackend() throws {
    let command = SafariCommand(
      backend: FakeSafariBackend(),
      tabGroupBackend: SafariTabGroupsSQLiteBackend(databasePath: "/tmp/nonexistent-SafariTabs.db")
    )
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tab", "group", "create", "--name", "Research", "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "tab", "group", "create", "--name", "Research", "--allow-external-dispatch", "--json",
    ])

    do {
      _ = try command.run(options: executedOptions)
      Issue.record("Expected production Safari Tab Group mutation backend to fail closed.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(error.details["proof_status"] == "proof-failed")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariReadingListRequiresAllowExternalDispatchBeforeBackend() throws {
    let backend = FakeSafariBackend()
    let command = SafariCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "reading-list", "add", "--url", "https://www.apple.com/", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Safari Reading List add to require the appropriate allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.readingListAdds.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariReadingListDryRunAndAllowFlagExecutesAdd() throws {
    let backend = FakeSafariBackend()
    let command = SafariCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "reading-list", "add", "--url", "https://www.apple.com/", "--title", "Apple", "--dry-run",
      "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "reading-list", "add", "--url", "https://www.apple.com/", "--title", "Apple",
      "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["operation"] as? String == "safari.reading-list.add")
    #expect(backend.readingListAdds == ["https://www.apple.com/"])
  }

  @Test func safariJavaScriptRequiresAllowFlagBeforeDryRun() throws {
    let command = SafariCommand(backend: FakeSafariBackend())
    let options = try CLIOptionsFixture.parse([
      "pages", "evaluate-javascript", "--window-index", "1", "--tab-index", "1", "--script",
      "document.title", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Safari JavaScript command to require an allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["gate"] == "strong-gate")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func safariJavaScriptDryRunAndAllowFlagExecutesScript() throws {
    let backend = FakeSafariBackend()
    let command = SafariCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "pages", "evaluate-javascript", "--window-index", "1", "--tab-index", "1", "--script",
      "document.title", "--allow-javascript", "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "pages", "evaluate-javascript", "--window-index", "1", "--tab-index", "1", "--script",
      "document.title", "--allow-javascript", "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["operation"] as? String == "safari.pages.evaluate-javascript")
    #expect(data?["result"] as? String == "Example Domain")
    #expect(backend.evaluatedScripts == ["document.title"])
  }

  @Test func safariProofFailedCommandReturnsUnsupportedOperation() throws {
    let command = SafariCommand(backend: FakeSafariBackend())
    let options = try CLIOptionsFixture.parse(["internals", "sync-plist", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected proof-failed Safari command to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(error.details["proof_status"] == "proof-failed")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private final class FakeSafariBackend: SafariAutomating, @unchecked Sendable {
  var readingListAdds: [String] = []
  var evaluatedScripts: [String] = []

  func listWindows() throws -> [SafariWindowRecord] {
    [SafariWindowRecord(id: "safari-window:1", index: 1, currentTabIndex: 1, tabCount: 2)]
  }

  func listTabs(windowIndex: Int?) throws -> [SafariTabRecord] {
    [
      SafariTabRecord(
        id: "safari-tab:1:1",
        windowIndex: 1,
        index: 1,
        title: "Example Domain",
        url: "https://example.com/",
        visible: true,
        current: true
      )
    ]
  }

  func currentTab(windowIndex: Int?) throws -> SafariTabRecord? {
    try listTabs(windowIndex: windowIndex).first
  }

  func readPage(
    windowIndex: Int,
    tabIndex: Int,
    includeText: Bool,
    includeSource: Bool,
    maxBytes: Int
  ) throws -> SafariPageRecord {
    guard let tab = try currentTab(windowIndex: windowIndex) else {
      throw SafariCommandTestError.missingTab
    }
    let text = includeText ? "Visible page text" : nil
    let source = includeSource ? "<html>Safari</html>" : nil
    let truncatedText = text.map { safariTestTruncate($0, maxBytes: maxBytes) }
    let truncatedSource = source.map { safariTestTruncate($0, maxBytes: maxBytes) }
    return SafariPageRecord(
      tab: tab,
      text: truncatedText?.0,
      source: truncatedSource?.0,
      truncated: (truncatedText?.1 ?? false) || (truncatedSource?.1 ?? false),
      maxBytes: maxBytes
    )
  }

  func selectTab(windowIndex: Int, tabIndex: Int) throws -> SafariTabRecord {
    guard let tab = try currentTab(windowIndex: windowIndex) else {
      throw SafariCommandTestError.missingTab
    }
    return tab
  }

  func openTab(url: URL, windowIndex: Int?) throws -> SafariTabRecord {
    SafariTabRecord(
      id: "safari-tab:1:2",
      windowIndex: windowIndex ?? 1,
      index: 2,
      title: url.host ?? "",
      url: url.absoluteString,
      visible: true,
      current: true
    )
  }

  func navigateTab(windowIndex: Int, tabIndex: Int, url: URL) throws -> SafariTabRecord {
    SafariTabRecord(
      id: "safari-tab:\(windowIndex):\(tabIndex)",
      windowIndex: windowIndex,
      index: tabIndex,
      title: url.host ?? "",
      url: url.absoluteString,
      visible: true,
      current: true
    )
  }

  func closeTab(windowIndex: Int, tabIndex: Int) throws -> Bool { true }

  func addReadingListItem(url: URL, title: String?, previewText: String?) throws -> Bool {
    readingListAdds.append(url.absoluteString)
    return true
  }

  func searchWeb(query: String, windowIndex: Int?, tabIndex: Int?) throws -> Bool { true }
  func showBookmarks() throws -> Bool { true }
  func emailContents(windowIndex: Int, tabIndex: Int) throws -> Bool { true }

  func evaluateJavaScript(
    windowIndex: Int,
    tabIndex: Int,
    script: String,
    maxBytes: Int
  ) throws -> SafariJavaScriptResult {
    evaluatedScripts.append(script)
    return SafariJavaScriptResult(
      operation: "safari.pages.evaluate-javascript",
      result: "Example Domain",
      truncated: false,
      resultSHA256: "sha"
    )
  }

  func showExtensionsPreferences(extensionID: String) throws -> Bool { true }
  func dispatchMessageToExtension(payloadJSON: String) throws -> Bool { true }
  func showPrivacyReport() throws -> Bool { true }
}

private final class FakeSafariTabGroupBackend: SafariTabGroupReading, SafariTabGroupMutating,
  @unchecked Sendable
{
  var createdNames: [String] = []
  var lastWindowID: String?
  var lastWindowTabWindowID: String?

  private var profile: SafariProfileRecord {
    SafariProfileRecord(
      id: "safari-profile:default",
      rawId: nil,
      name: "Default",
      tabGroupCount: 1
    )
  }

  private var group: SafariTabGroupRecord {
    SafariTabGroupRecord(
      id: "safari-tab-group:row:10",
      rawId: 10,
      name: "Research",
      profile: profile,
      tabCount: 1,
      resolvedTabCount: 1
    )
  }

  private var tab: SafariTabGroupTabRecord {
    SafariTabGroupTabRecord(
      id: "safari-tab:row:11",
      rawId: 11,
      title: "Example Domain",
      url: "https://example.com/",
      orderIndex: 0
    )
  }

  func diagnoseTabGroups() throws -> SafariTabGroupsDiagnoseResponse {
    SafariTabGroupsDiagnoseResponse(
      databasePath: "/tmp/SafariTabs.db",
      readable: true,
      schemaSupported: true,
      tables: ["bookmarks"],
      requiredColumns: ["id"],
      missingRequiredColumns: [],
      counts: ["bookmarks": 2],
      source: SafariTabGroupsSource(databasePath: "/tmp/SafariTabs.db", table: "bookmarks")
    )
  }

  func listProfiles(verbose: Bool) throws -> [SafariProfileRecord] {
    [profile]
  }

  func readProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    id == profile.id ? profile : nil
  }

  private func snapshotWindow(id: String = "safari-window:row:1") -> SafariTabGroupWindowRecord {
    SafariTabGroupWindowRecord(
      id: id,
      rawId: 1,
      sessionIndex: 1,
      uuid: "fixture-window",
      profile: profile,
      activeTabGroup: group,
      activeTabGroupRawId: 10,
      localTabGroupRawId: 10,
      isLastSession: true,
      open: true,
      resolvedTabCount: 1
    )
  }

  func listWindows(includeRestorable: Bool, verbose: Bool) throws
    -> SafariTabGroupWindowsResponse
  {
    SafariTabGroupWindowsResponse(
      windows: [snapshotWindow()],
      source: SafariTabGroupsSource(databasePath: "/tmp/SafariTabs.db", table: "windows")
    )
  }

  func readWindow(id: String, verbose: Bool) throws -> SafariSnapshotWindowResponse? {
    lastWindowID = id
    return SafariSnapshotWindowResponse(
      window: snapshotWindow(id: id),
      source: SafariTabGroupsSource(databasePath: "/tmp/SafariTabs.db", table: "windows")
    )
  }

  func windowProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    lastWindowID = id
    return profile
  }

  func listWindowTabs(windowID: String, verbose: Bool) throws -> SafariSnapshotWindowTabsResponse? {
    lastWindowTabWindowID = windowID
    return SafariSnapshotWindowTabsResponse(
      window: snapshotWindow(id: windowID),
      tabs: [tab],
      source: SafariTabGroupsSource(databasePath: "/tmp/SafariTabs.db", table: "windows")
    )
  }

  func listTabGroups(profileID: String?, includeHidden: Bool, verbose: Bool) throws
    -> SafariTabGroupsResponse
  {
    SafariTabGroupsResponse(
      tabGroups: [group],
      source: SafariTabGroupsSource(databasePath: "/tmp/SafariTabs.db", table: "bookmarks")
    )
  }

  func readTabGroup(id: String, verbose: Bool) throws -> SafariTabGroupResponse? {
    guard id == group.id else {
      return nil
    }
    return SafariTabGroupResponse(
      tabGroup: group,
      tabs: [tab],
      source: SafariTabGroupsSource(databasePath: "/tmp/SafariTabs.db", table: "bookmarks")
    )
  }

  func createTabGroup(name: String, url: URL?, profileID: String?) throws -> Bool {
    createdNames.append(name)
    return true
  }

  func renameTabGroup(id: String, name: String) throws -> Bool { true }
  func deleteTabGroup(id: String) throws -> Bool { true }
  func addTabToGroup(id: String, url: URL, title: String?) throws -> Bool { true }
  func removeTabFromGroup(id: String, tabID: String) throws -> Bool { true }
  func selectTabGroup(id: String, windowIndex: Int?) throws -> Bool { true }
  func openTabGroup(id: String, windowIndex: Int?) throws -> Bool { true }
}

private struct SafariTabsSQLiteFixture {
  var directory: URL
  var database: URL
}

private func makeSafariTabsSQLiteFixture() throws -> SafariTabsSQLiteFixture {
  let directory = FileManager.default.temporaryDirectory.appendingPathComponent(
    "apple-cli-safari-test-\(UUID().uuidString)",
    isDirectory: true
  )
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  let database = directory.appendingPathComponent("SafariTabs.db")

  var handle: OpaquePointer?
  guard sqlite3_open(database.path, &handle) == SQLITE_OK, let handle else {
    throw SafariCommandTestError.sqlite("Failed to create fixture database.")
  }
  defer { sqlite3_close(handle) }

  try safariFixtureExec(
    handle,
    """
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY,
      parent INTEGER,
      type INTEGER,
      subtype INTEGER,
      title TEXT,
      url TEXT,
      num_children INTEGER,
      hidden INTEGER,
      order_index INTEGER,
      external_uuid TEXT,
      deleted INTEGER DEFAULT 0,
      server_id TEXT,
      sync_key TEXT,
      syncable INTEGER
    );
    CREATE TABLE windows (
      id INTEGER PRIMARY KEY,
      active_tab_group_id INTEGER,
      local_tab_group_id INTEGER,
      date_closed REAL,
      is_last_session INTEGER,
      uuid TEXT NOT NULL,
      active_profile_id INTEGER
    );
    CREATE TABLE participant_presence (
      id INTEGER PRIMARY KEY,
      participant_id TEXT,
      tab_group_server_id TEXT,
      tab_server_id TEXT
    );
    INSERT INTO bookmarks
      (id, parent, type, subtype, title, url, num_children, hidden, order_index, deleted)
    VALUES
      (5, 0, 1, 2, 'Personal', NULL, 1, 1, 0, 0),
      (10, 0, 1, 0, 'Research', NULL, 1, 0, 1, 0),
      (11, 10, 0, 0, 'Example Domain', 'https://example.com/', 0, 0, 1, 0),
      (20, 0, 1, 2, 'Work', NULL, 1, 0, 2, 0),
      (21, 20, 1, 0, 'Work Group', NULL, 1, 0, 1, 0),
      (22, 21, 0, 0, 'Apple', 'https://www.apple.com/', 0, 0, 1, 0);
    INSERT INTO windows
      (id, active_tab_group_id, local_tab_group_id, date_closed, is_last_session, uuid, active_profile_id)
    VALUES
      (1, 10, 10, NULL, 1, 'fixture-window-1', 5),
      (2, 21, 21, NULL, 1, 'fixture-window-2', 20),
      (3, 21, 21, NULL, 0, 'fixture-window-3', 20);
    """
  )

  return SafariTabsSQLiteFixture(directory: directory, database: database)
}

private func safariFixtureExec(_ handle: OpaquePointer, _ sql: String) throws {
  var error: UnsafeMutablePointer<Int8>?
  let result = sqlite3_exec(handle, sql, nil, nil, &error)
  guard result == SQLITE_OK else {
    let message = error.map { String(cString: $0) } ?? "unknown sqlite error"
    sqlite3_free(error)
    throw SafariCommandTestError.sqlite(message)
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw SafariCommandTestError.notObject
  }
  return object
}

private func safariTestTruncate(_ value: String, maxBytes: Int) -> (String, Bool) {
  let data = Data(value.utf8)
  guard data.count > maxBytes else {
    return (value, false)
  }
  return (String(data: data.prefix(maxBytes), encoding: .utf8) ?? "", true)
}

private enum SafariCommandTestError: Error {
  case missingTab
  case notObject
  case sqlite(String)
}
