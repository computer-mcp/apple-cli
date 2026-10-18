import Foundation
import Utility

public struct SafariWindowRecord: Codable, Equatable, Sendable {
  public var id: String
  public var index: Int
  public var currentTabIndex: Int?
  public var tabCount: Int

  public init(id: String, index: Int, currentTabIndex: Int?, tabCount: Int) {
    self.id = id
    self.index = index
    self.currentTabIndex = currentTabIndex
    self.tabCount = tabCount
  }
}

public struct SafariTabRecord: Codable, Equatable, Sendable {
  public var id: String
  public var windowIndex: Int
  public var index: Int
  public var title: String
  public var url: String?
  public var visible: Bool
  public var current: Bool

  public init(
    id: String,
    windowIndex: Int,
    index: Int,
    title: String,
    url: String?,
    visible: Bool,
    current: Bool
  ) {
    self.id = id
    self.windowIndex = windowIndex
    self.index = index
    self.title = title
    self.url = url
    self.visible = visible
    self.current = current
  }
}

public struct SafariPageRecord: Codable, Equatable, Sendable {
  public var tab: SafariTabRecord
  public var text: String?
  public var source: String?
  public var truncated: Bool
  public var maxBytes: Int?

  public init(
    tab: SafariTabRecord,
    text: String? = nil,
    source: String? = nil,
    truncated: Bool = false,
    maxBytes: Int? = nil
  ) {
    self.tab = tab
    self.text = text
    self.source = source
    self.truncated = truncated
    self.maxBytes = maxBytes
  }
}

public struct SafariWindowsResponse: Codable, Equatable, Sendable {
  public var windows: [SafariWindowRecord]
}

public struct SafariTabsResponse: Codable, Equatable, Sendable {
  public var tabs: [SafariTabRecord]
}

public struct SafariTabResponse: Codable, Equatable, Sendable {
  public var tab: SafariTabRecord
}

public struct SafariPageResponse: Codable, Equatable, Sendable {
  public var page: SafariPageRecord
}


public struct SafariActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var summaryFields: [String: String]
}

public struct SafariJavaScriptResult: Codable, Equatable, Sendable {
  public var operation: String
  public var result: String
  public var truncated: Bool
  public var resultSHA256: String

  public init(operation: String, result: String, truncated: Bool, resultSHA256: String) {
    self.operation = operation
    self.result = result
    self.truncated = truncated
    self.resultSHA256 = resultSHA256
  }
}

public struct SafariTabGroupsSource: Codable, Equatable, Sendable {
  public var database: String
  public var databasePath: String?
  public var table: String?
  public var rowId: Int?
  public var stability: String

  public init(
    database: String = "SafariTabs.db",
    databasePath: String? = nil,
    table: String? = nil,
    rowId: Int? = nil,
    stability: String = "private-sqlite"
  ) {
    self.database = database
    self.databasePath = databasePath
    self.table = table
    self.rowId = rowId
    self.stability = stability
  }
}

public struct SafariTabGroupSyncMetadata: Codable, Equatable, Sendable {
  public var syncable: Bool?
  public var hasServerId: Bool
  public var hasSyncKey: Bool
  public var hasSyncData: Bool
  public var participantPresenceCount: Int
  public var classification: String
  public var confidence: String

  public init(
    syncable: Bool?,
    hasServerId: Bool,
    hasSyncKey: Bool,
    hasSyncData: Bool,
    participantPresenceCount: Int,
    classification: String,
    confidence: String
  ) {
    self.syncable = syncable
    self.hasServerId = hasServerId
    self.hasSyncKey = hasSyncKey
    self.hasSyncData = hasSyncData
    self.participantPresenceCount = participantPresenceCount
    self.classification = classification
    self.confidence = confidence
  }
}

public struct SafariProfileRecord: Codable, Equatable, Sendable {
  public var id: String
  public var rawId: Int?
  public var tabGroupParentId: Int?
  public var name: String
  public var tabGroupCount: Int
  public var source: SafariTabGroupsSource?

  public init(
    id: String,
    rawId: Int?,
    tabGroupParentId: Int? = nil,
    name: String,
    tabGroupCount: Int = 0,
    source: SafariTabGroupsSource? = nil
  ) {
    self.id = id
    self.rawId = rawId
    self.tabGroupParentId = tabGroupParentId
    self.name = name
    self.tabGroupCount = tabGroupCount
    self.source = source
  }
}

public struct SafariTabGroupRecord: Codable, Equatable, Sendable {
  public var id: String
  public var rawId: Int?
  public var name: String
  public var profile: SafariProfileRecord?
  public var tabCount: Int
  public var resolvedTabCount: Int
  public var hidden: Bool
  public var shared: Bool
  public var source: SafariTabGroupsSource?
  public var sync: SafariTabGroupSyncMetadata?

  public init(
    id: String,
    rawId: Int?,
    name: String,
    profile: SafariProfileRecord? = nil,
    tabCount: Int,
    resolvedTabCount: Int,
    hidden: Bool = false,
    shared: Bool = false,
    source: SafariTabGroupsSource? = nil,
    sync: SafariTabGroupSyncMetadata? = nil
  ) {
    self.id = id
    self.rawId = rawId
    self.name = name
    self.profile = profile
    self.tabCount = tabCount
    self.resolvedTabCount = resolvedTabCount
    self.hidden = hidden
    self.shared = shared
    self.source = source
    self.sync = sync
  }
}

public struct SafariTabGroupWindowRecord: Codable, Equatable, Sendable {
  public var id: String
  public var rawId: Int
  public var sessionIndex: Int?
  public var uuid: String?
  public var profile: SafariProfileRecord?
  public var activeTabGroup: SafariTabGroupRecord?
  public var activeTabGroupRawId: Int?
  public var localTabGroupRawId: Int?
  public var privateTabGroupRawId: Int?
  public var isLastSession: Bool
  public var open: Bool
  public var resolvedTabCount: Int
  public var source: SafariTabGroupsSource?

  public init(
    id: String,
    rawId: Int,
    sessionIndex: Int? = nil,
    uuid: String? = nil,
    profile: SafariProfileRecord? = nil,
    activeTabGroup: SafariTabGroupRecord? = nil,
    activeTabGroupRawId: Int? = nil,
    localTabGroupRawId: Int? = nil,
    privateTabGroupRawId: Int? = nil,
    isLastSession: Bool,
    open: Bool,
    resolvedTabCount: Int,
    source: SafariTabGroupsSource? = nil
  ) {
    self.id = id
    self.rawId = rawId
    self.sessionIndex = sessionIndex
    self.uuid = uuid
    self.profile = profile
    self.activeTabGroup = activeTabGroup
    self.activeTabGroupRawId = activeTabGroupRawId
    self.localTabGroupRawId = localTabGroupRawId
    self.privateTabGroupRawId = privateTabGroupRawId
    self.isLastSession = isLastSession
    self.open = open
    self.resolvedTabCount = resolvedTabCount
    self.source = source
  }
}

public struct SafariTabGroupTabRecord: Codable, Equatable, Sendable {
  public var id: String
  public var rawId: Int
  public var title: String
  public var url: String?
  public var orderIndex: Int
  public var source: SafariTabGroupsSource?
  public var confidence: [String: String]

  public init(
    id: String,
    rawId: Int,
    title: String,
    url: String?,
    orderIndex: Int,
    source: SafariTabGroupsSource? = nil,
    confidence: [String: String] = [:]
  ) {
    self.id = id
    self.rawId = rawId
    self.title = title
    self.url = url
    self.orderIndex = orderIndex
    self.source = source
    self.confidence = confidence
  }
}

public struct SafariTabGroupWindowsResponse: Codable, Equatable, Sendable {
  public var windows: [SafariTabGroupWindowRecord]
  public var source: SafariTabGroupsSource
  public var warnings: [String]

  public init(
    windows: [SafariTabGroupWindowRecord],
    source: SafariTabGroupsSource,
    warnings: [String] = []
  ) {
    self.windows = windows
    self.source = source
    self.warnings = warnings
  }
}

public struct SafariSnapshotWindowResponse: Codable, Equatable, Sendable {
  public var window: SafariTabGroupWindowRecord
  public var source: SafariTabGroupsSource
  public var warnings: [String]

  public init(
    window: SafariTabGroupWindowRecord,
    source: SafariTabGroupsSource,
    warnings: [String] = []
  ) {
    self.window = window
    self.source = source
    self.warnings = warnings
  }
}

public struct SafariSnapshotWindowTabsResponse: Codable, Equatable, Sendable {
  public var window: SafariTabGroupWindowRecord
  public var tabs: [SafariTabGroupTabRecord]
  public var source: SafariTabGroupsSource
  public var warnings: [String]

  public init(
    window: SafariTabGroupWindowRecord,
    tabs: [SafariTabGroupTabRecord],
    source: SafariTabGroupsSource,
    warnings: [String] = []
  ) {
    self.window = window
    self.tabs = tabs
    self.source = source
    self.warnings = warnings
  }
}

public struct SafariProfilesResponse: Codable, Equatable, Sendable {
  public var profiles: [SafariProfileRecord]

  public init(profiles: [SafariProfileRecord]) {
    self.profiles = profiles
  }
}

public struct SafariProfileResponse: Codable, Equatable, Sendable {
  public var profile: SafariProfileRecord

  public init(profile: SafariProfileRecord) {
    self.profile = profile
  }
}

public struct SafariTabGroupsResponse: Codable, Equatable, Sendable {
  public var tabGroups: [SafariTabGroupRecord]
  public var source: SafariTabGroupsSource
  public var warnings: [String]

  public init(
    tabGroups: [SafariTabGroupRecord],
    source: SafariTabGroupsSource,
    warnings: [String] = []
  ) {
    self.tabGroups = tabGroups
    self.source = source
    self.warnings = warnings
  }
}

public struct SafariTabGroupResponse: Codable, Equatable, Sendable {
  public var tabGroup: SafariTabGroupRecord
  public var tabs: [SafariTabGroupTabRecord]
  public var source: SafariTabGroupsSource
  public var warnings: [String]

  public init(
    tabGroup: SafariTabGroupRecord,
    tabs: [SafariTabGroupTabRecord],
    source: SafariTabGroupsSource,
    warnings: [String] = []
  ) {
    self.tabGroup = tabGroup
    self.tabs = tabs
    self.source = source
    self.warnings = warnings
  }
}

public struct SafariTabGroupsDiagnoseResponse: Codable, Equatable, Sendable {
  public var databasePath: String
  public var readable: Bool
  public var schemaSupported: Bool
  public var tables: [String]
  public var requiredColumns: [String]
  public var missingRequiredColumns: [String]
  public var counts: [String: Int]
  public var source: SafariTabGroupsSource
  public var warnings: [String]

  public init(
    databasePath: String,
    readable: Bool,
    schemaSupported: Bool,
    tables: [String],
    requiredColumns: [String],
    missingRequiredColumns: [String],
    counts: [String: Int],
    source: SafariTabGroupsSource,
    warnings: [String] = []
  ) {
    self.databasePath = databasePath
    self.readable = readable
    self.schemaSupported = schemaSupported
    self.tables = tables
    self.requiredColumns = requiredColumns
    self.missingRequiredColumns = missingRequiredColumns
    self.counts = counts
    self.source = source
    self.warnings = warnings
  }
}
