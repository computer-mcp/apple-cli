import Foundation
import SQLite3
import Utility

public struct SafariTabGroupsSQLiteBackend: SafariTabGroupReading, SafariTabGroupMutating,
  @unchecked Sendable
{
  public static let defaultDatabasePath =
    NSHomeDirectory() + "/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db"

  private static let requiredBookmarkColumns: Set<String> = [
    "id", "parent", "type", "subtype", "title", "url", "num_children", "hidden",
    "order_index",
  ]

  private let databasePath: String
  private let fileManager: FileManager

  public init(
    databasePath: String = SafariTabGroupsSQLiteBackend.defaultDatabasePath,
    fileManager: FileManager = .default
  ) {
    self.databasePath = databasePath
    self.fileManager = fileManager
  }

  public func diagnoseTabGroups() throws -> SafariTabGroupsDiagnoseResponse {
    let source = source()
    guard fileManager.fileExists(atPath: databasePath) else {
      return SafariTabGroupsDiagnoseResponse(
        databasePath: databasePath,
        readable: false,
        schemaSupported: false,
        tables: [],
        requiredColumns: Self.requiredBookmarkColumns.sorted(),
        missingRequiredColumns: Self.requiredBookmarkColumns.sorted(),
        counts: [:],
        source: source,
        warnings: ["SafariTabs.db was not found."]
      )
    }

    guard fileManager.isReadableFile(atPath: databasePath) else {
      return SafariTabGroupsDiagnoseResponse(
        databasePath: databasePath,
        readable: false,
        schemaSupported: false,
        tables: [],
        requiredColumns: Self.requiredBookmarkColumns.sorted(),
        missingRequiredColumns: Self.requiredBookmarkColumns.sorted(),
        counts: [:],
        source: source,
        warnings: [
          CLIPermissionWording.fullDiskAccessRequired(resource: "SafariTabs.db")
        ]
      )
    }

    do {
      return try withSnapshot { connection in
        let tables = try connection.tableNames()
        let bookmarkColumns =
          tables.contains("bookmarks") ? try connection.columns(table: "bookmarks") : []
        let missing = Self.requiredBookmarkColumns.subtracting(bookmarkColumns).sorted()
        var counts: [String: Int] = [:]
        for table in [
          "bookmarks", "windows", "windows_tab_groups", "windows_profiles",
          "windows_unnamed_tab_groups", "participant_presence", "sync_properties",
        ] where tables.contains(table) {
          counts[table] = try connection.countRows(table: table)
        }

        return SafariTabGroupsDiagnoseResponse(
          databasePath: databasePath,
          readable: true,
          schemaSupported: tables.contains("bookmarks") && missing.isEmpty,
          tables: tables,
          requiredColumns: Self.requiredBookmarkColumns.sorted(),
          missingRequiredColumns: missing,
          counts: counts,
          source: source,
          warnings: missing.isEmpty ? [] : ["SafariTabs.db schema is missing required columns."]
        )
      }
    } catch let error as CLIError {
      return SafariTabGroupsDiagnoseResponse(
        databasePath: databasePath,
        readable: true,
        schemaSupported: false,
        tables: [],
        requiredColumns: Self.requiredBookmarkColumns.sorted(),
        missingRequiredColumns: Self.requiredBookmarkColumns.sorted(),
        counts: [:],
        source: source,
        warnings: [error.message]
      )
    }
  }

  public func listProfiles(verbose: Bool) throws -> [SafariProfileRecord] {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).listProfiles(verbose: verbose)
    }
  }

  public func listWindows(includeRestorable: Bool, verbose: Bool) throws
    -> SafariTabGroupWindowsResponse
  {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).listWindows(includeRestorable: includeRestorable, verbose: verbose)
    }
  }

  public func readWindow(id: String, verbose: Bool) throws -> SafariSnapshotWindowResponse? {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).readWindow(id: id, verbose: verbose)
    }
  }

  public func windowProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).windowProfile(id: id, verbose: verbose)
    }
  }

  public func listWindowTabs(windowID: String, verbose: Bool) throws
    -> SafariSnapshotWindowTabsResponse?
  {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).listWindowTabs(windowID: windowID, verbose: verbose)
    }
  }

  public func readProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).readProfile(id: id, verbose: verbose)
    }
  }

  public func listTabGroups(profileID: String?, includeHidden: Bool, verbose: Bool) throws
    -> SafariTabGroupsResponse
  {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).listTabGroups(profileID: profileID, includeHidden: includeHidden, verbose: verbose)
    }
  }

  public func readTabGroup(id: String, verbose: Bool) throws -> SafariTabGroupResponse? {
    try withSnapshot { snapshot in
      try SafariTabGroupsSnapshot(
        connection: snapshot,
        databasePath: databasePath,
        requiredBookmarkColumns: Self.requiredBookmarkColumns
      ).readTabGroup(id: id, verbose: verbose)
    }
  }

  public func createTabGroup(name: String, url: URL?, profileID: String?) throws -> Bool {
    throw unsupportedMutation("safari tab group create")
  }

  public func renameTabGroup(id: String, name: String) throws -> Bool {
    throw unsupportedMutation("safari tab group rename")
  }

  public func deleteTabGroup(id: String) throws -> Bool {
    throw unsupportedMutation("safari tab group delete")
  }

  public func addTabToGroup(id: String, url: URL, title: String?) throws -> Bool {
    throw unsupportedMutation("safari tab group add-tab")
  }

  public func removeTabFromGroup(id: String, tabID: String) throws -> Bool {
    throw unsupportedMutation("safari tab group remove-tab")
  }

  public func selectTabGroup(id: String, windowIndex: Int?) throws -> Bool {
    throw unsupportedMutation("safari tab group select")
  }

  public func openTabGroup(id: String, windowIndex: Int?) throws -> Bool {
    throw unsupportedMutation("safari tab group open")
  }

  private func unsupportedMutation(_ command: String) -> CLIError {
    safariProofFailed(
      command,
      reason:
        "Local Safari SDEF and Shortcuts inspection did not expose a Safari-owned Tab Group/Profile mutation backend. Direct SafariTabs.db writes are intentionally rejected."
    )
  }

  private func withSnapshot<T>(_ body: (SafariSQLiteConnection) throws -> T) throws -> T {
    guard fileManager.fileExists(atPath: databasePath) else {
      throw CLIError(
        code: .notFound,
        message: "SafariTabs.db was not found.",
        details: ["path": databasePath]
      )
    }
    guard fileManager.isReadableFile(atPath: databasePath) else {
      throw CLIError(
        code: .permissionDenied,
        message: CLIPermissionWording.fullDiskAccessRequired(resource: "SafariTabs.db"),
        details: ["path": databasePath]
      )
    }

    let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(
      "apple-cli-safari-tabs-\(UUID().uuidString)",
      isDirectory: true
    )
    try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: tempDirectory) }

    let sourceURL = URL(fileURLWithPath: databasePath)
    let snapshotURL = tempDirectory.appendingPathComponent("SafariTabs.db")
    try copyIfPresent(from: sourceURL, to: snapshotURL, required: true)
    try copyIfPresent(
      from: URL(fileURLWithPath: databasePath + "-wal"),
      to: tempDirectory.appendingPathComponent("SafariTabs.db-wal"),
      required: false
    )
    try copyIfPresent(
      from: URL(fileURLWithPath: databasePath + "-shm"),
      to: tempDirectory.appendingPathComponent("SafariTabs.db-shm"),
      required: false
    )

    let connection = try SafariSQLiteConnection(path: snapshotURL.path)
    defer { connection.close() }
    try connection.execute("PRAGMA query_only=ON")
    return try body(connection)
  }

  private func copyIfPresent(from source: URL, to destination: URL, required: Bool) throws {
    guard fileManager.fileExists(atPath: source.path) else {
      if required {
        throw CLIError(
          code: .notFound,
          message: "SafariTabs.db was not found.",
          details: ["path": source.path]
        )
      }
      return
    }

    do {
      try fileManager.copyItem(at: source, to: destination)
    } catch let error as NSError where !required && error.code == NSFileNoSuchFileError {
      return
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to create a read-only SafariTabs.db snapshot.",
        details: CLIError.diagnosticDetails(for: error).merging(["path": source.path]) { _, new in new }
      )
    }
  }

  private func source(rowId: Int? = nil) -> SafariTabGroupsSource {
    SafariTabGroupsSource(databasePath: databasePath, table: "bookmarks", rowId: rowId)
  }
}

private struct SafariTabGroupsSnapshot {
  let connection: SafariSQLiteConnection
  let databasePath: String
  let requiredBookmarkColumns: Set<String>

  private var source: SafariTabGroupsSource {
    SafariTabGroupsSource(databasePath: databasePath, table: "bookmarks")
  }

  private var windowSource: SafariTabGroupsSource {
    SafariTabGroupsSource(databasePath: databasePath, table: "windows")
  }

  func listProfiles(verbose: Bool) throws -> [SafariProfileRecord] {
    try ensureSupportedSchema()
    let profileRows = try profileRows()
    let defaultProfile = try defaultProfile(verbose: verbose)
    let profiles = try profileRows.filter { row in
      intValue(row, "id") != defaultProfile.rawId
    }.map { row in
      try profileRecord(row: row, verbose: verbose)
    }
    return [defaultProfile] + profiles
  }

  func readProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    try ensureSupportedSchema()
    return try resolveProfile(id: id, verbose: verbose)
  }

  func listWindows(includeRestorable: Bool, verbose: Bool) throws
    -> SafariTabGroupWindowsResponse
  {
    try ensureSupportedSchema()
    guard try connection.tableNames().contains("windows") else {
      return SafariTabGroupWindowsResponse(
        windows: [],
        source: windowSource,
        warnings: ["SafariTabs.db schema is missing `windows`."]
      )
    }
    let windows = try windowRows(includeRestorable: includeRestorable)
    let sessionIDs = try sessionWindowIDs()
    let records = try windows.map { row in
      try windowRecord(
        row: row, sessionIndex: sessionIDs[intValue(row, "id") ?? -1], verbose: verbose)
    }
    return SafariTabGroupWindowsResponse(windows: records, source: windowSource)
  }

  func readWindow(id: String, verbose: Bool) throws -> SafariSnapshotWindowResponse? {
    try ensureSupportedSchema()
    guard try connection.tableNames().contains("windows") else {
      return nil
    }
    let rows = try windowRows(windowID: id)
    guard let row = rows.first else {
      return nil
    }
    let sessionIDs = try sessionWindowIDs()
    let record = try windowRecord(
      row: row,
      sessionIndex: sessionIDs[intValue(row, "id") ?? -1],
      verbose: verbose
    )
    return SafariSnapshotWindowResponse(window: record, source: windowSource)
  }

  func windowProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    try ensureSupportedSchema()
    guard try connection.tableNames().contains("windows") else {
      return nil
    }
    let rows = try windowRows(windowID: id)
    guard let row = rows.first else {
      return nil
    }
    guard let profileID = intValue(row, "active_profile_id"), profileID > 0 else {
      return try defaultProfile(verbose: verbose)
    }
    return try profileRecordForRawID(profileID, verbose: verbose)
      ?? defaultProfile(verbose: verbose)
  }

  func listWindowTabs(windowID: String, verbose: Bool) throws -> SafariSnapshotWindowTabsResponse? {
    try ensureSupportedSchema()
    guard try connection.tableNames().contains("windows") else {
      return nil
    }
    let rows = try windowRows(windowID: windowID)
    guard let row = rows.first else {
      return nil
    }
    let sessionIDs = try sessionWindowIDs()
    let window = try windowRecord(
      row: row,
      sessionIndex: sessionIDs[intValue(row, "id") ?? -1],
      verbose: verbose
    )
    guard let groupID = intValue(row, "active_tab_group_id") ?? intValue(row, "local_tab_group_id")
    else {
      return SafariSnapshotWindowTabsResponse(
        window: window,
        tabs: [],
        source: windowSource,
        warnings: ["Safari snapshot window does not reference an active or local Tab Group."]
      )
    }
    return SafariSnapshotWindowTabsResponse(
      window: window,
      tabs: try tabsForGroup(rawID: groupID, verbose: verbose),
      source: windowSource
    )
  }

  func listTabGroups(profileID: String?, includeHidden: Bool, verbose: Bool) throws
    -> SafariTabGroupsResponse
  {
    try ensureSupportedSchema()
    let profiles: [SafariProfileRecord]
    if let profileID {
      guard let profile = try resolveProfile(id: profileID, verbose: verbose) else {
        throw CLIError(
          code: .notFound,
          message: "Safari profile was not found.",
          details: ["id": profileID]
        )
      }
      profiles = [profile]
    } else {
      profiles = try listProfiles(verbose: verbose)
    }

    var groups: [SafariTabGroupRecord] = []
    for profile in profiles {
      let parent = profile.tabGroupParentId ?? profile.rawId ?? 0
      let rows = try groupRows(parentID: parent, includeHidden: includeHidden)
      for row in rows {
        groups.append(try tabGroupRecord(row: row, profile: profile, verbose: verbose))
      }
    }

    return SafariTabGroupsResponse(tabGroups: groups, source: source)
  }

  func readTabGroup(id: String, verbose: Bool) throws -> SafariTabGroupResponse? {
    try ensureSupportedSchema()
    guard let row = try resolveTabGroupRow(id: id) else {
      return nil
    }
    return try tabGroupResponse(row: row, verbose: verbose)
  }

  private func tabGroupResponse(row: SafariSQLiteRow, verbose: Bool) throws
    -> SafariTabGroupResponse
  {
    let parent = intValue(row, "parent") ?? 0
    let profile = try profileForParent(parent, verbose: verbose)
    let group = try tabGroupRecord(row: row, profile: profile, verbose: verbose)
    let tabs = try tabsForGroup(rawID: group.rawId ?? -1, verbose: verbose)
    return SafariTabGroupResponse(tabGroup: group, tabs: tabs, source: source)
  }

  private func ensureSupportedSchema() throws {
    let tables = try connection.tableNames()
    guard tables.contains("bookmarks") else {
      throw CLIError(
        code: .backendUnavailable,
        message: "SafariTabs.db schema is unsupported because `bookmarks` is missing.",
        details: ["database": databasePath]
      )
    }
    let columns = try connection.columns(table: "bookmarks")
    let missing = requiredBookmarkColumns.subtracting(columns).sorted()
    guard missing.isEmpty else {
      throw CLIError(
        code: .backendUnavailable,
        message: "SafariTabs.db schema is unsupported.",
        details: ["missing_columns": missing.joined(separator: ","), "database": databasePath]
      )
    }
  }

  private func profileRows() throws -> [SafariSQLiteRow] {
    try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(profileSelectColumns))
        FROM bookmarks
        WHERE parent = 0
          AND COALESCE(subtype, 0) = 2
          AND COALESCE(deleted, 0) = 0
          AND COALESCE(title, '') <> ''
        ORDER BY COALESCE(order_index, id) ASC, id ASC
        """
    )
  }

  private func defaultProfile(verbose: Bool) throws -> SafariProfileRecord {
    if let row = try defaultProfileRow() {
      return try profileRecord(row: row, tabGroupParentID: 0, verbose: verbose)
    }
    let tabGroupParentID = 0
    let count = try groupRows(parentID: tabGroupParentID, includeHidden: false).count
    return SafariProfileRecord(
      id: "safari-profile:default",
      rawId: nil,
      tabGroupParentId: tabGroupParentID,
      name: "Default",
      tabGroupCount: count,
      source: verbose ? source : nil
    )
  }

  private func defaultProfileRow() throws -> SafariSQLiteRow? {
    guard let activeProfileID = try rootProfileCandidateID() else {
      return nil
    }
    return try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(profileSelectColumns))
        FROM bookmarks
        WHERE id = ?
          AND parent = 0
          AND COALESCE(subtype, 0) = 2
          AND COALESCE(deleted, 0) = 0
        LIMIT 1
        """,
      bindings: [.integer(activeProfileID)]
    ).first
  }

  private func rootProfileCandidateID() throws -> Int? {
    guard try connection.tableNames().contains("windows") else {
      return nil
    }
    let rows = try connection.rows(
      sql:
        """
        SELECT w.active_profile_id AS active_profile_id, COUNT(*) AS count
        FROM windows w
        JOIN bookmarks b ON b.id = COALESCE(w.active_tab_group_id, w.local_tab_group_id)
        WHERE w.active_profile_id IS NOT NULL
          AND COALESCE(w.active_profile_id, 0) > 0
          AND (b.parent IS NULL OR b.parent = 0)
          AND COALESCE(b.deleted, 0) = 0
        GROUP BY w.active_profile_id
        ORDER BY count DESC, w.active_profile_id ASC
        """
    )
    return rows.first.flatMap { intValue($0, "active_profile_id") }
  }

  private func profileRecord(
    row: SafariSQLiteRow,
    tabGroupParentID: Int? = nil,
    verbose: Bool
  ) throws -> SafariProfileRecord {
    guard let rawID = intValue(row, "id") else {
      throw CLIError(code: .backendUnavailable, message: "Safari profile row was missing an id.")
    }
    let parentID = tabGroupParentID ?? (isDefaultProfileRow(row) ? 0 : rawID)
    return SafariProfileRecord(
      id: profileIdentifier(row: row),
      rawId: rawID,
      tabGroupParentId: parentID,
      name: stringValue(row, "title") ?? "Profile \(rawID)",
      tabGroupCount: try groupRows(parentID: parentID, includeHidden: false).count,
      source: verbose ? source(rowId: rawID) : nil
    )
  }

  private func isDefaultProfileRow(_ row: SafariSQLiteRow) -> Bool {
    stringValue(row, "external_uuid") == "DefaultProfile"
  }

  private func profileForParent(_ parent: Int, verbose: Bool) throws -> SafariProfileRecord? {
    if parent == 0 {
      return try defaultProfile(verbose: verbose)
    }
    return try profileRecordForRawID(parent, verbose: verbose)
  }

  private func profileRecordForRawID(_ rawID: Int, verbose: Bool) throws -> SafariProfileRecord? {
    guard
      let row = try connection.rows(
        sql:
          """
          SELECT \(try selectColumns(profileSelectColumns))
          FROM bookmarks
          WHERE id = ?
            AND COALESCE(subtype, 0) = 2
            AND COALESCE(deleted, 0) = 0
          LIMIT 1
          """,
        bindings: [.integer(rawID)]
      ).first
    else {
      return nil
    }
    return try profileRecord(row: row, verbose: verbose)
  }

  private func resolveProfile(id: String, verbose: Bool) throws -> SafariProfileRecord? {
    let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed == "default" || trimmed == "safari-profile:default" {
      return try defaultProfile(verbose: verbose)
    }
    if let rawID = rawID(from: trimmed, prefix: "safari-profile:row:")
      ?? Int(trimmed)
    {
      return try profileRecordForRawID(rawID, verbose: verbose)
    }
    if trimmed.hasPrefix("safari-profile:uuid:") {
      return try profileRecordForUUID(
        String(trimmed.dropFirst("safari-profile:uuid:".count)),
        verbose: verbose
      )
    }

    let matches = try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(profileSelectColumns))
        FROM bookmarks
        WHERE COALESCE(title, '') = ?
          AND parent = 0
          AND COALESCE(subtype, 0) = 2
          AND COALESCE(deleted, 0) = 0
        ORDER BY id ASC
        """,
      bindings: [.text(trimmed)]
    )
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Multiple Safari profiles matched this id/name.",
        details: ["id": trimmed, "matches": "\(matches.count)"]
      )
    }
    return try matches.first.map { try profileRecord(row: $0, verbose: verbose) }
  }

  private func profileRecordForUUID(_ uuid: String, verbose: Bool) throws -> SafariProfileRecord? {
    guard try connection.columns(table: "bookmarks").contains("external_uuid") else {
      return nil
    }
    guard
      let row = try connection.rows(
        sql:
          """
          SELECT \(try selectColumns(profileSelectColumns))
          FROM bookmarks
          WHERE external_uuid = ?
            AND parent = 0
            AND COALESCE(subtype, 0) = 2
            AND COALESCE(deleted, 0) = 0
          LIMIT 1
          """,
        bindings: [.text(uuid)]
      ).first
    else {
      return nil
    }
    return try profileRecord(row: row, verbose: verbose)
  }

  private func groupRows(parentID: Int, includeHidden: Bool) throws -> [SafariSQLiteRow] {
    try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(tabGroupSelectColumns))
        FROM bookmarks
        WHERE parent = ?
          AND type = 1
          AND COALESCE(subtype, 0) = 0
          AND COALESCE(num_children, 0) > 0
          AND COALESCE(deleted, 0) = 0
          \(includeHidden ? "" : "AND COALESCE(hidden, 0) = 0")
        ORDER BY COALESCE(order_index, id) ASC, id ASC
        """,
      bindings: [.integer(parentID)]
    )
  }

  private func resolveTabGroupRow(id: String) throws -> SafariSQLiteRow? {
    let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
    if let rawID = rawID(from: trimmed, prefix: "safari-tab-group:row:")
      ?? Int(trimmed)
    {
      return try tabGroupRow(rawID: rawID)
    }
    if trimmed.hasPrefix("safari-tab-group:uuid:") {
      return try tabGroupRow(uuid: String(trimmed.dropFirst("safari-tab-group:uuid:".count)))
    }

    let matches = try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(tabGroupSelectColumns))
        FROM bookmarks
        WHERE COALESCE(title, '') = ?
          AND type = 1
          AND COALESCE(subtype, 0) = 0
          AND COALESCE(num_children, 0) > 0
          AND COALESCE(deleted, 0) = 0
        ORDER BY id ASC
        """,
      bindings: [.text(trimmed)]
    )
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Multiple Safari Tab Groups matched this id/name.",
        details: ["id": trimmed, "matches": "\(matches.count)"]
      )
    }
    return matches.first
  }

  private func tabGroupRow(rawID: Int) throws -> SafariSQLiteRow? {
    try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(tabGroupSelectColumns))
        FROM bookmarks
        WHERE id = ?
          AND type = 1
          AND COALESCE(subtype, 0) = 0
          AND COALESCE(num_children, 0) > 0
          AND COALESCE(deleted, 0) = 0
        LIMIT 1
        """,
      bindings: [.integer(rawID)]
    ).first
  }

  private func tabGroupRow(uuid: String) throws -> SafariSQLiteRow? {
    guard try connection.columns(table: "bookmarks").contains("external_uuid") else {
      return nil
    }
    return try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(tabGroupSelectColumns))
        FROM bookmarks
        WHERE external_uuid = ?
          AND type = 1
          AND COALESCE(subtype, 0) = 0
          AND COALESCE(num_children, 0) > 0
          AND COALESCE(deleted, 0) = 0
        LIMIT 1
        """,
      bindings: [.text(uuid)]
    ).first
  }

  private func tabGroupRecord(
    row: SafariSQLiteRow,
    profile: SafariProfileRecord?,
    verbose: Bool
  ) throws -> SafariTabGroupRecord {
    guard let rawID = intValue(row, "id") else {
      throw CLIError(code: .backendUnavailable, message: "Safari Tab Group row was missing an id.")
    }
    let tabs = try tabsForGroup(rawID: rawID, verbose: false)
    let sync: SafariTabGroupSyncMetadata? = verbose ? try syncMetadata(row: row) : nil
    return SafariTabGroupRecord(
      id: tabGroupIdentifier(row: row),
      rawId: rawID,
      name: stringValue(row, "title") ?? "Tab Group \(rawID)",
      profile: profile,
      tabCount: intValue(row, "num_children") ?? tabs.count,
      resolvedTabCount: tabs.count,
      hidden: boolValue(row, "hidden"),
      shared: (sync?.participantPresenceCount ?? 0) > 0,
      source: verbose ? source(rowId: rawID) : nil,
      sync: sync
    )
  }

  private func tabsForGroup(rawID: Int, verbose: Bool) throws -> [SafariTabGroupTabRecord] {
    let rows = try connection.rows(
      sql:
        """
        SELECT \(try selectColumns(tabSelectColumns))
        FROM bookmarks
        WHERE parent = ?
          AND COALESCE(deleted, 0) = 0
          AND COALESCE(url, '') <> ''
          AND COALESCE(title, '') NOT IN ('TopScopedBookmarkList', 'Untitled', 'Start Page')
        ORDER BY COALESCE(order_index, id) ASC, id ASC
        """,
      bindings: [.integer(rawID)]
    )
    return rows.enumerated().compactMap { index, row in
      guard let rawTabID = intValue(row, "id") else {
        return nil
      }
      return SafariTabGroupTabRecord(
        id: tabIdentifier(row: row),
        rawId: rawTabID,
        title: stringValue(row, "title") ?? "",
        url: stringValue(row, "url"),
        orderIndex: intValue(row, "order_index") ?? index,
        source: verbose ? source(rowId: rawTabID) : nil,
        confidence: ["membership": "direct-parent"]
      )
    }
  }

  private func syncMetadata(row: SafariSQLiteRow) throws -> SafariTabGroupSyncMetadata {
    let syncable = optionalBoolValue(row, "syncable")
    let serverID = stringValue(row, "server_id")
    let syncKey = stringValue(row, "sync_key")
    let syncDataBytes = intValue(row, "sync_data_length") ?? 0
    let participantCount = try participantPresenceCount(serverID: serverID)
    let classification: String
    let confidence: String
    if participantCount > 0 {
      classification = "shared"
      confidence = "medium"
    } else if serverID?.isEmpty == false || syncKey?.isEmpty == false || syncDataBytes > 0
      || syncable == true
    {
      classification = "synced"
      confidence = "medium"
    } else {
      classification = "local"
      confidence = "low"
    }

    return SafariTabGroupSyncMetadata(
      syncable: syncable,
      hasServerId: serverID?.isEmpty == false,
      hasSyncKey: syncKey?.isEmpty == false,
      hasSyncData: syncDataBytes > 0,
      participantPresenceCount: participantCount,
      classification: classification,
      confidence: confidence
    )
  }

  private func participantPresenceCount(serverID: String?) throws -> Int {
    guard let serverID, !serverID.isEmpty,
      try connection.tableNames().contains("participant_presence")
    else {
      return 0
    }
    let row = try connection.rows(
      sql: "SELECT COUNT(*) AS count FROM participant_presence WHERE tab_group_server_id = ?",
      bindings: [.text(serverID)]
    ).first
    return intValue(row ?? [:], "count") ?? 0
  }

  private func windowRecord(row: SafariSQLiteRow, sessionIndex: Int?, verbose: Bool) throws
    -> SafariTabGroupWindowRecord
  {
    guard let rawWindowID = intValue(row, "id") else {
      throw CLIError(code: .backendUnavailable, message: "Safari window row was missing an id.")
    }
    let activeProfileID = intValue(row, "active_profile_id")
    let activeGroupID = intValue(row, "active_tab_group_id")
    let localGroupID = intValue(row, "local_tab_group_id")
    let groupID = activeGroupID ?? localGroupID
    let profile = try activeProfileID.flatMap { try profileRecordForRawID($0, verbose: verbose) }
    let groupRow = try groupID.flatMap { try tabGroupRow(rawID: $0) }
    let group = try groupRow.map { row in
      try tabGroupRecord(
        row: row,
        profile: profile ?? profileForParent(intValue(row, "parent") ?? 0, verbose: verbose),
        verbose: verbose
      )
    }
    let resolvedTabCount =
      try groupID.map { try tabsForGroup(rawID: $0, verbose: false).count } ?? 0
    return SafariTabGroupWindowRecord(
      id: "safari-window:row:\(rawWindowID)",
      rawId: rawWindowID,
      sessionIndex: sessionIndex,
      uuid: stringValue(row, "uuid"),
      profile: profile,
      activeTabGroup: group,
      activeTabGroupRawId: activeGroupID,
      localTabGroupRawId: localGroupID,
      privateTabGroupRawId: intValue(row, "private_tab_group_id"),
      isLastSession: boolValue(row, "is_last_session"),
      open: stringValue(row, "date_closed") == nil,
      resolvedTabCount: resolvedTabCount,
      source: verbose
        ? SafariTabGroupsSource(
          databasePath: databasePath,
          table: "windows",
          rowId: rawWindowID
        ) : nil
    )
  }

  private func sessionWindowIDs() throws -> [Int: Int] {
    let rows = try windowRows(includeRestorable: false)
    var indexes: [Int: Int] = [:]
    for (index, row) in rows.enumerated() {
      if let id = intValue(row, "id") {
        indexes[id] = index + 1
      }
    }
    return indexes
  }

  private func windowRows(includeRestorable: Bool) throws -> [SafariSQLiteRow] {
    var sql =
      """
      SELECT \(try selectColumns(windowSelectColumns, table: "windows"))
      FROM windows
      WHERE date_closed IS NULL
      """
    if !includeRestorable {
      sql += "\n  AND COALESCE(is_last_session, 0) = 1"
    }
    sql += "\nORDER BY id ASC"
    return try connection.rows(sql: sql)
  }

  private func windowRows(windowID: String?) throws -> [SafariSQLiteRow] {
    if let rawWindowID = try rawWindowID(from: windowID) {
      return try connection.rows(
        sql:
          """
          SELECT \(try selectColumns(windowSelectColumns, table: "windows"))
          FROM windows
          WHERE id = ?
          LIMIT 1
          """,
        bindings: [.integer(rawWindowID)]
      )
    }
    var sql =
      """
        SELECT \(try selectColumns(windowSelectColumns, table: "windows"))
        FROM windows
        WHERE date_closed IS NULL
          AND COALESCE(is_last_session, 0) = 1
        ORDER BY COALESCE(is_last_session, 0) DESC,
          id ASC
      """
    sql += "\nLIMIT 1"
    return try connection.rows(sql: sql)
  }

  private func rawWindowID(from id: String?) throws -> Int? {
    guard let trimmed = id?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
      return nil
    }
    let raw = rawID(from: trimmed, prefix: "safari-window:row:") ?? Int(trimmed)
    guard let raw, raw > 0 else {
      throw CLIError(
        code: .validationError,
        message: "`--window-id` must be a positive integer or `safari-window:row:<id>` value."
      )
    }
    return raw
  }

  private var profileSelectColumns: [(String, String)] {
    [
      ("id", "NULL"), ("title", "NULL"), ("order_index", "NULL"), ("external_uuid", "NULL"),
      ("hidden", "0"),
    ]
  }

  private var tabGroupSelectColumns: [(String, String)] {
    [
      ("id", "NULL"), ("parent", "NULL"), ("title", "NULL"), ("order_index", "NULL"),
      ("num_children", "0"), ("hidden", "0"), ("external_uuid", "NULL"),
      ("server_id", "NULL"), ("sync_key", "NULL"), ("syncable", "NULL"),
      ("length(sync_data)", "0"),
    ]
  }

  private var tabSelectColumns: [(String, String)] {
    [
      ("id", "NULL"), ("title", "NULL"), ("url", "NULL"), ("order_index", "NULL"),
      ("external_uuid", "NULL"),
    ]
  }

  private var windowSelectColumns: [(String, String)] {
    [
      ("id", "NULL"), ("active_profile_id", "NULL"), ("active_tab_group_id", "NULL"),
      ("local_tab_group_id", "NULL"), ("private_tab_group_id", "NULL"),
      ("is_last_session", "0"), ("date_closed", "NULL"), ("uuid", "NULL"),
    ]
  }

  private func selectColumns(_ columns: [(String, String)], table: String = "bookmarks") throws
    -> String
  {
    let available = try connection.columns(table: table)
    return columns.map { name, fallback in
      if name == "length(sync_data)" {
        return available.contains("sync_data")
          ? "length(sync_data) AS sync_data_length" : "\(fallback) AS sync_data_length"
      }
      return available.contains(name)
        ? "\(quotedIdentifier(name)) AS \(quotedIdentifier(name))"
        : "\(fallback) AS \(quotedIdentifier(name))"
    }.joined(separator: ", ")
  }

  private func tabGroupIdentifier(row: SafariSQLiteRow) -> String {
    if let uuid = stringValue(row, "external_uuid"), !uuid.isEmpty {
      return "safari-tab-group:uuid:\(uuid)"
    }
    return "safari-tab-group:row:\(intValue(row, "id") ?? 0)"
  }

  private func tabIdentifier(row: SafariSQLiteRow) -> String {
    if let uuid = stringValue(row, "external_uuid"), !uuid.isEmpty {
      return "safari-tab:uuid:\(uuid)"
    }
    return "safari-tab:row:\(intValue(row, "id") ?? 0)"
  }

  private func profileIdentifier(row: SafariSQLiteRow) -> String {
    if let uuid = stringValue(row, "external_uuid"), !uuid.isEmpty {
      return "safari-profile:uuid:\(uuid)"
    }
    return "safari-profile:row:\(intValue(row, "id") ?? 0)"
  }

  private func source(rowId: Int? = nil) -> SafariTabGroupsSource {
    SafariTabGroupsSource(databasePath: databasePath, table: "bookmarks", rowId: rowId)
  }
}

private final class SafariSQLiteConnection {
  private var handle: OpaquePointer?

  init(path: String) throws {
    var database: OpaquePointer?
    let result = sqlite3_open_v2(path, &database, SQLITE_OPEN_READONLY, nil)
    guard result == SQLITE_OK, let database else {
      let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown sqlite error"
      if let database {
        sqlite3_close(database)
      }
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to open SafariTabs.db snapshot.",
        details: ["sqlite_error": message]
      )
    }
    handle = database
  }

  deinit {
    close()
  }

  func close() {
    if let handle {
      sqlite3_close(handle)
      self.handle = nil
    }
  }

  func execute(_ sql: String) throws {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
      throw sqliteError(message: "Failed to prepare SafariTabs.db statement.")
    }
    defer { sqlite3_finalize(statement) }
    let step = sqlite3_step(statement)
    guard step == SQLITE_DONE || step == SQLITE_ROW else {
      throw sqliteError(message: "Failed to execute SafariTabs.db statement.")
    }
  }

  func tableNames() throws -> [String] {
    try rows(sql: "SELECT name FROM sqlite_schema WHERE type = 'table' ORDER BY name").compactMap {
      stringValue($0, "name")
    }
  }

  func columns(table: String) throws -> Set<String> {
    Set(
      try rows(sql: "PRAGMA table_info(\(quotedIdentifier(table)))").compactMap {
        stringValue($0, "name")
      })
  }

  func countRows(table: String) throws -> Int {
    let row = try rows(sql: "SELECT COUNT(*) AS count FROM \(quotedIdentifier(table))").first
    return intValue(row ?? [:], "count") ?? 0
  }

  func rows(sql: String, bindings: [SafariSQLiteBinding] = []) throws -> [SafariSQLiteRow] {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
      throw sqliteError(message: "Failed to prepare SafariTabs.db statement.")
    }
    defer { sqlite3_finalize(statement) }

    for (index, binding) in bindings.enumerated() {
      let position = Int32(index + 1)
      switch binding {
      case .integer(let value):
        sqlite3_bind_int64(statement, position, sqlite3_int64(value))
      case .text(let value):
        sqlite3_bind_text(statement, position, value, -1, sqliteTransient)
      }
    }

    var output: [SafariSQLiteRow] = []
    while true {
      let step = sqlite3_step(statement)
      if step == SQLITE_DONE {
        return output
      }
      guard step == SQLITE_ROW else {
        throw sqliteError(message: "Failed to read SafariTabs.db rows.")
      }

      var row: SafariSQLiteRow = [:]
      for index in 0..<sqlite3_column_count(statement) {
        let name = String(cString: sqlite3_column_name(statement, index))
        switch sqlite3_column_type(statement, index) {
        case SQLITE_INTEGER:
          row[name] = String(sqlite3_column_int64(statement, index))
        case SQLITE_FLOAT:
          row[name] = String(sqlite3_column_double(statement, index))
        case SQLITE_TEXT:
          if let text = sqlite3_column_text(statement, index) {
            row[name] = String(cString: text)
          } else {
            row[name] = nil
          }
        case SQLITE_BLOB:
          row[name] = String(sqlite3_column_bytes(statement, index))
        default:
          row[name] = nil
        }
      }
      output.append(row)
    }
  }

  private func sqliteError(message: String) -> CLIError {
    CLIError(
      code: .backendUnavailable,
      message: message,
      details: ["sqlite_error": handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown"]
    )
  }
}

private typealias SafariSQLiteRow = [String: String?]

private enum SafariSQLiteBinding {
  case integer(Int)
  case text(String)
}

private func rawID(from value: String, prefix: String) -> Int? {
  guard value.hasPrefix(prefix) else {
    return nil
  }
  return Int(value.dropFirst(prefix.count))
}

private func stringValue(_ row: SafariSQLiteRow, _ key: String) -> String? {
  guard let value = row[key] else {
    return nil
  }
  return value
}

private func intValue(_ row: SafariSQLiteRow, _ key: String) -> Int? {
  guard let value = stringValue(row, key) else {
    return nil
  }
  return Int(value)
}

private func boolValue(_ row: SafariSQLiteRow, _ key: String) -> Bool {
  optionalBoolValue(row, key) ?? false
}

private func optionalBoolValue(_ row: SafariSQLiteRow, _ key: String) -> Bool? {
  guard let value = stringValue(row, key) else {
    return nil
  }
  switch value.lowercased() {
  case "1", "true", "yes":
    return true
  case "0", "false", "no":
    return false
  default:
    return nil
  }
}

private func quotedIdentifier(_ value: String) -> String {
  "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
}

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
