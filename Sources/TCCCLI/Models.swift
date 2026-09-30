import Foundation
import Utility

public enum TCCScope: String, Codable, CaseIterable, Sendable {
  case user
  case system
  case both
}

public enum TCCClientKind: String, Codable, Sendable {
  case bundleIdentifier = "bundle_identifier"
  case absolutePath = "absolute_path"

  public var databaseValue: Int {
    switch self {
    case .bundleIdentifier:
      return 0
    case .absolutePath:
      return 1
    }
  }
}

public struct TCCServiceInfo: Codable, Equatable, Sendable {
  public var suffix: String
  public var rawName: String
  public var aliases: [String]
  public var relatedTargets: [String]
  public var publicAPIRoute: String?
  public var canonical: Bool

  public init(
    suffix: String,
    rawName: String? = nil,
    aliases: [String] = [],
    relatedTargets: [String] = [],
    publicAPIRoute: String? = nil,
    canonical: Bool = true
  ) {
    self.suffix = suffix
    self.rawName = rawName ?? "kTCCService\(suffix)"
    self.aliases = aliases
    self.relatedTargets = relatedTargets
    self.publicAPIRoute = publicAPIRoute
    self.canonical = canonical
  }
}

public struct TCCClientInfo: Codable, Equatable, Sendable {
  public var input: String
  public var client: String
  public var clientType: Int
  public var clientTypeName: TCCClientKind
  public var bundleIdentifier: String?
  public var path: String?

  public init(input: String, kind: TCCClientKind) {
    self.input = input
    self.client = input
    self.clientType = kind.databaseValue
    self.clientTypeName = kind
    switch kind {
    case .bundleIdentifier:
      self.bundleIdentifier = input
      self.path = nil
    case .absolutePath:
      self.bundleIdentifier = nil
      self.path = input
    }
  }
}

public struct TCCCodeIdentity: Codable, Equatable, Sendable {
  public var input: String
  public var path: String?
  public var bundleIdentifier: String?
  public var codesignIdentifier: String?
  public var cdHash: String?
  public var teamIdentifier: String?
  public var signatureKind: String
  public var infoPlistBinding: String?
  public var resolvedBy: String

  public init(
    input: String,
    path: String?,
    bundleIdentifier: String?,
    codesignIdentifier: String?,
    cdHash: String?,
    teamIdentifier: String?,
    signatureKind: String,
    infoPlistBinding: String?,
    resolvedBy: String
  ) {
    self.input = input
    self.path = path
    self.bundleIdentifier = bundleIdentifier
    self.codesignIdentifier = codesignIdentifier
    self.cdHash = cdHash
    self.teamIdentifier = teamIdentifier
    self.signatureKind = signatureKind
    self.infoPlistBinding = infoPlistBinding
    self.resolvedBy = resolvedBy
  }
}

public struct TCCAccessRecord: Codable, Equatable, Sendable {
  public var service: String
  public var client: String
  public var clientType: Int?
  public var clientTypeName: String?
  public var authValue: Int?
  public var authValueDescription: String?
  public var authReason: Int?
  public var authReasonDescription: String?
  public var authVersion: Int?
  public var allowed: Int?
  public var promptCount: Int?
  public var csreqSHA256: String?
  public var csreqLength: Int?
  public var policyID: Int?
  public var indirectObjectIdentifierType: Int?
  public var indirectObjectIdentifier: String?
  public var indirectObjectCodeIdentitySHA256: String?
  public var indirectObjectCodeIdentityLength: Int?
  public var flags: Int?
  public var lastModifiedRaw: Int?
  public var lastModifiedISO8601: String?
  public var rowHash: String

  public init(
    service: String,
    client: String,
    clientType: Int?,
    authValue: Int?,
    authReason: Int?,
    authVersion: Int?,
    allowed: Int?,
    promptCount: Int?,
    csreqSHA256: String?,
    csreqLength: Int?,
    policyID: Int?,
    indirectObjectIdentifierType: Int?,
    indirectObjectIdentifier: String?,
    indirectObjectCodeIdentitySHA256: String?,
    indirectObjectCodeIdentityLength: Int?,
    flags: Int?,
    lastModifiedRaw: Int?,
    rowHash: String
  ) {
    self.service = service
    self.client = client
    self.clientType = clientType
    self.clientTypeName = clientType.map(Self.clientTypeDescription)
    self.authValue = authValue
    self.authValueDescription = authValue.map(Self.authValueDescription)
    self.authReason = authReason
    self.authReasonDescription = authReason.map(Self.authReasonDescription)
    self.authVersion = authVersion
    self.allowed = allowed
    self.promptCount = promptCount
    self.csreqSHA256 = csreqSHA256
    self.csreqLength = csreqLength
    self.policyID = policyID
    self.indirectObjectIdentifierType = indirectObjectIdentifierType
    self.indirectObjectIdentifier = indirectObjectIdentifier
    self.indirectObjectCodeIdentitySHA256 = indirectObjectCodeIdentitySHA256
    self.indirectObjectCodeIdentityLength = indirectObjectCodeIdentityLength
    self.flags = flags
    self.lastModifiedRaw = lastModifiedRaw
    self.lastModifiedISO8601 = lastModifiedRaw.map(Self.iso8601)
    self.rowHash = rowHash
  }

  public static func clientTypeDescription(_ value: Int) -> String {
    switch value {
    case 0:
      return TCCClientKind.bundleIdentifier.rawValue
    case 1:
      return TCCClientKind.absolutePath.rawValue
    default:
      return "unknown_\(value)"
    }
  }

  public static func authValueDescription(_ value: Int) -> String {
    switch value {
    case 0:
      return "denied"
    case 1:
      return "unknown"
    case 2:
      return "allowed"
    case 3:
      return "limited"
    default:
      return "raw_\(value)"
    }
  }

  public static func authReasonDescription(_ value: Int) -> String {
    switch value {
    case 1:
      return "error"
    case 2:
      return "user_consent"
    case 3:
      return "user_set"
    case 4:
      return "system_set"
    case 5:
      return "service_policy"
    case 6:
      return "mdm_policy"
    case 7:
      return "override_policy"
    case 8:
      return "missing_usage_string"
    case 9:
      return "prompt_timeout"
    case 10:
      return "preflight_unknown"
    case 11:
      return "entitled"
    default:
      return "raw_\(value)"
    }
  }

  private static func iso8601(_ timestamp: Int) -> String {
    ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
  }
}

public struct TCCDatabaseInfo: Codable, Equatable, Sendable {
  public var scope: TCCScope
  public var path: String
  public var exists: Bool
  public var readable: Bool
  public var writable: Bool
  public var schemaColumns: [String]
  public var digest: String?
  public var openMode: String
  public var error: String?

  public init(
    scope: TCCScope,
    path: String,
    exists: Bool,
    readable: Bool,
    writable: Bool,
    schemaColumns: [String],
    digest: String?,
    openMode: String,
    error: String? = nil
  ) {
    self.scope = scope
    self.path = path
    self.exists = exists
    self.readable = readable
    self.writable = writable
    self.schemaColumns = schemaColumns
    self.digest = digest
    self.openMode = openMode
    self.error = error
  }
}

public struct TCCDatabaseIssue: Codable, Equatable, Sendable {
  public var scope: TCCScope
  public var path: String
  public var code: CLIErrorCode
  public var message: String

  public init(scope: TCCScope, path: String, code: CLIErrorCode, message: String) {
    self.scope = scope
    self.path = path
    self.code = code
    self.message = message
  }
}

public struct TCCOperationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var scope: TCCScope?
  public var service: String?
  public var client: String?
  public var affectedRows: Int
  public var backupPath: String?
  public var backend: String

  public init(
    operation: String,
    changed: Bool,
    scope: TCCScope? = nil,
    service: String? = nil,
    client: String? = nil,
    affectedRows: Int = 0,
    backupPath: String? = nil,
    backend: String
  ) {
    self.operation = operation
    self.changed = changed
    self.scope = scope
    self.service = service
    self.client = client
    self.affectedRows = affectedRows
    self.backupPath = backupPath
    self.backend = backend
  }
}


public struct TCCFrameworkProbe: Codable, Equatable, Sendable {
  public var frameworkPath: String
  public var available: Bool
  public var symbols: [String: Bool]
  public var sipStatus: String
  public var amfiStatus: String
  public var entitlementStatus: String
  public var diagnostics: [String]

  public init(
    frameworkPath: String,
    available: Bool,
    symbols: [String: Bool],
    sipStatus: String,
    amfiStatus: String,
    entitlementStatus: String,
    diagnostics: [String]
  ) {
    self.frameworkPath = frameworkPath
    self.available = available
    self.symbols = symbols
    self.sipStatus = sipStatus
    self.amfiStatus = amfiStatus
    self.entitlementStatus = entitlementStatus
    self.diagnostics = diagnostics
  }
}

public struct TCCDoctorTargetMapping: Codable, Equatable, Sendable {
  public var target: String
  public var services: [String]
  public var publicAPIRoutes: [String]
  public var notes: [String]

  public init(target: String, services: [String], publicAPIRoutes: [String], notes: [String]) {
    self.target = target
    self.services = services
    self.publicAPIRoutes = publicAPIRoutes
    self.notes = notes
  }
}

public struct TCCServicesResponse: Codable, Equatable, Sendable {
  public var services: [TCCServiceInfo]

  public init(services: [TCCServiceInfo]) {
    self.services = services
  }
}

public struct TCCServiceResponse: Codable, Equatable, Sendable {
  public var service: TCCServiceInfo

  public init(service: TCCServiceInfo) {
    self.service = service
  }
}

public struct TCCClientResponse: Codable, Equatable, Sendable {
  public var client: TCCClientInfo

  public init(client: TCCClientInfo) {
    self.client = client
  }
}

public struct TCCIdentityResponse: Codable, Equatable, Sendable {
  public var identity: TCCCodeIdentity

  public init(identity: TCCCodeIdentity) {
    self.identity = identity
  }
}

public struct TCCDatabaseInfoResponse: Codable, Equatable, Sendable {
  public var databases: [TCCDatabaseInfo]

  public init(databases: [TCCDatabaseInfo]) {
    self.databases = databases
  }
}

public struct TCCDatabaseDigestResponse: Codable, Equatable, Sendable {
  public var digests: [TCCDatabaseInfo]

  public init(digests: [TCCDatabaseInfo]) {
    self.digests = digests
  }
}

public struct TCCScopedAccessRecord: Codable, Equatable, Sendable {
  public var scope: TCCScope
  public var databasePath: String
  public var record: TCCAccessRecord

  public init(scope: TCCScope, databasePath: String, record: TCCAccessRecord) {
    self.scope = scope
    self.databasePath = databasePath
    self.record = record
  }
}

public struct TCCRecordsResponse: Codable, Equatable, Sendable {
  public var records: [TCCScopedAccessRecord]
  public var truncated: Bool
  public var issues: [TCCDatabaseIssue]

  public init(
    records: [TCCScopedAccessRecord],
    truncated: Bool = false,
    issues: [TCCDatabaseIssue] = []
  ) {
    self.records = records
    self.truncated = truncated
    self.issues = issues
  }
}

public struct TCCRecordResponse: Codable, Equatable, Sendable {
  public var record: TCCScopedAccessRecord?

  public init(record: TCCScopedAccessRecord?) {
    self.record = record
  }
}

public struct TCCAccessCheckResponse: Codable, Equatable, Sendable {
  public var service: TCCServiceInfo
  public var granted: Bool?
  public var route: String
  public var prompted: Bool
  public var diagnostics: [String]

  public init(
    service: TCCServiceInfo,
    granted: Bool?,
    route: String,
    prompted: Bool,
    diagnostics: [String] = []
  ) {
    self.service = service
    self.granted = granted
    self.route = route
    self.prompted = prompted
    self.diagnostics = diagnostics
  }
}

public struct TCCDoctorResponse: Codable, Equatable, Sendable {
  public var report: CLIDoctorReport
  public var targetMapping: TCCDoctorTargetMapping?

  public init(report: CLIDoctorReport, targetMapping: TCCDoctorTargetMapping?) {
    self.report = report
    self.targetMapping = targetMapping
  }
}

public struct TCCFrameworkProbeResponse: Codable, Equatable, Sendable {
  public var probe: TCCFrameworkProbe

  public init(probe: TCCFrameworkProbe) {
    self.probe = probe
  }
}
