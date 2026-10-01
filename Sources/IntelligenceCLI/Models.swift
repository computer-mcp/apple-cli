import Foundation

public enum IntelligencePatchScope: String, Codable, CaseIterable, Sendable {
  case answer
  case comprehensive
}

public enum IntelligenceCacheFile: String, Codable, CaseIterable, Sendable {
  case eligibility
  case osEligibility = "os_eligibility"
  case countryd
}

public enum IntelligenceDomain: String, Codable, CaseIterable, Sendable {
  case strontium = "OS_ELIGIBILITY_DOMAIN_STRONTIUM"
  case greymatter = "OS_ELIGIBILITY_DOMAIN_GREYMATTER"
  case foundationModels = "OS_ELIGIBILITY_DOMAIN_FOUNDATION_MODELS"
  case calcium = "OS_ELIGIBILITY_DOMAIN_CALCIUM"
}

public enum IntelligenceMechanism: String, Codable, CaseIterable, Sendable {
  case directPlistPatch = "direct-plist-patch"
  case expandedStatusPatch = "expanded-status-patch"
  case countryCacheRewrite = "country-cache-rewrite"
  case cacheReset = "cache-reset"
  case backupState = "backup-state"
  case rollbackRestore = "rollback-restore"
  case debugRecompute = "debug-recompute"
  case persistentService = "persistent-service"
}

public struct IntelligencePaths: Codable, Equatable, Sendable {
  static let serviceLabel = "io.github.computer-mcp.apple-cli.intelligence.recompute"
  public var root: String
  public var stateDir: String

  public init(root: String = "/", stateDir: String? = nil) {
    let normalizedRoot = URL(fileURLWithPath: root).standardizedFileURL.path
    self.root = normalizedRoot
    self.stateDir =
      stateDir.map { URL(fileURLWithPath: $0).standardizedFileURL.path }
      ?? IntelligencePaths.join(normalizedRoot, "private/var/db/apple-cli/intelligence")
  }

  public var eligibilityPlist: String {
    Self.join(root, "private/var/db/eligibilityd/eligibility.plist")
  }

  public var osEligibilityPlist: String {
    Self.join(root, "private/var/db/os_eligibility/eligibility.plist")
  }

  public var countrydPlist: String {
    Self.join(root, "private/var/db/com.apple.countryd/countryCodeCache.plist")
  }

  public var servicePlist: String {
    Self.join(root, "Library/LaunchDaemons/\(Self.serviceLabel).plist")
  }

  public static func join(_ root: String, _ relative: String) -> String {
    if root == "/" {
      return "/" + relative
    }
    return URL(fileURLWithPath: root).appendingPathComponent(relative).path
  }
}

public struct IntelligencePatchRule: Codable, Equatable, Sendable {
  public var file: IntelligenceCacheFile
  public var domain: IntelligenceDomain
  public var keyPath: [String]
  public var value: Int
  public var mechanism: IntelligenceMechanism
}

public let intelligenceAnswerRules: [IntelligencePatchRule] = [
  IntelligencePatchRule(
    file: .osEligibility,
    domain: .strontium,
    keyPath: [IntelligenceDomain.strontium.rawValue, "os_eligibility_answer_t"],
    value: 4,
    mechanism: .directPlistPatch
  ),
  IntelligencePatchRule(
    file: .eligibility,
    domain: .greymatter,
    keyPath: [IntelligenceDomain.greymatter.rawValue, "os_eligibility_answer_t"],
    value: 4,
    mechanism: .directPlistPatch
  ),
  IntelligencePatchRule(
    file: .eligibility,
    domain: .foundationModels,
    keyPath: [IntelligenceDomain.foundationModels.rawValue, "os_eligibility_answer_t"],
    value: 4,
    mechanism: .directPlistPatch
  ),
]

public let intelligenceComprehensiveExtraRules: [IntelligencePatchRule] = [
  IntelligencePatchRule(
    file: .eligibility,
    domain: .greymatter,
    keyPath: [
      IntelligenceDomain.greymatter.rawValue, "status",
      "OS_ELIGIBILITY_INPUT_COUNTRY_BILLING",
    ],
    value: 2,
    mechanism: .expandedStatusPatch
  ),
  IntelligencePatchRule(
    file: .eligibility,
    domain: .greymatter,
    keyPath: [
      IntelligenceDomain.greymatter.rawValue, "status",
      "OS_ELIGIBILITY_INPUT_DEVICE_AND_SIRI_LANGUAGE_MATCH",
    ],
    value: 2,
    mechanism: .expandedStatusPatch
  ),
  IntelligencePatchRule(
    file: .eligibility,
    domain: .greymatter,
    keyPath: [
      IntelligenceDomain.greymatter.rawValue, "status",
      "OS_ELIGIBILITY_INPUT_DEVICE_REGION_CODE",
    ],
    value: 2,
    mechanism: .expandedStatusPatch
  ),
  IntelligencePatchRule(
    file: .eligibility,
    domain: .greymatter,
    keyPath: [
      IntelligenceDomain.greymatter.rawValue, "status",
      "OS_ELIGIBILITY_INPUT_EXTERNAL_BOOT_DRIVE",
    ],
    value: 2,
    mechanism: .expandedStatusPatch
  ),
  IntelligencePatchRule(
    file: .eligibility,
    domain: .calcium,
    keyPath: [
      IntelligenceDomain.calcium.rawValue, "status",
      "OS_ELIGIBILITY_INPUT_DEVICE_REGION_CODE",
    ],
    value: 2,
    mechanism: .expandedStatusPatch
  ),
]

public func intelligenceRules(patchScope: IntelligencePatchScope) -> [IntelligencePatchRule] {
  switch patchScope {
  case .answer:
    return intelligenceAnswerRules
  case .comprehensive:
    return intelligenceAnswerRules + intelligenceComprehensiveExtraRules
  }
}

public struct IntelligenceHostFacts: Codable, Equatable, Sendable {
  public var macos: String?
  public var macosBuild: String?
  public var machine: String
  public var sip: String?
  public var bootArgs: String?
  public var lldbPath: String?
}

public struct IntelligenceSupportAssessment: Codable, Equatable, Sendable {
  public var recommendedCommands: [String]
  public var warnings: [String]
}

public struct IntelligenceFileStatus: Codable, Equatable, Sendable {
  public var path: String
  public var exists: Bool
  public var readablePlist: Bool
  public var readError: String?
}

public struct IntelligenceDoctorReport: Codable, Equatable, Sendable {
  public var host: IntelligenceHostFacts
  public var support: IntelligenceSupportAssessment
  public var files: [String: IntelligenceFileStatus]
  public var stateDir: String
  public var service: [String: IntelligenceFileStatus]
}

public enum IntelligenceOperationStatus: String, Codable, Sendable {
  case succeeded
  case failed
  case partial
}

public struct IntelligenceActionResult: Codable, Equatable, Sendable {
  public var kind: String
  public var status: String
  public var path: String?
  public var domain: String?
  public var key: String?
  public var previous: String?
  public var current: String?
  public var mechanism: String?
  public var exitCode: Int32?
  public var stdout: String?
  public var stderr: String?
  public var detail: String?
  public var subsystem: String?

  public init(
    kind: String,
    status: String,
    path: String? = nil,
    domain: String? = nil,
    key: String? = nil,
    previous: String? = nil,
    current: String? = nil,
    mechanism: String? = nil,
    exitCode: Int32? = nil,
    stdout: String? = nil,
    stderr: String? = nil,
    detail: String? = nil,
    subsystem: String? = nil
  ) {
    self.kind = kind
    self.status = status
    self.path = path
    self.domain = domain
    self.key = key
    self.previous = previous
    self.current = current
    self.mechanism = mechanism
    self.exitCode = exitCode
    self.stdout = stdout
    self.stderr = stderr
    self.detail = detail
    self.subsystem = subsystem
  }
}

public struct IntelligenceBackupEntry: Codable, Equatable, Sendable {
  public var target: String
  public var backup: String
  public var sha256: String
}

public struct IntelligenceStateManifest: Codable, Equatable, Sendable {
  public var id: String
  public var createdAt: String
  public var root: String
  public var metadata: [String: String]
  public var backups: [IntelligenceBackupEntry]
}

public struct IntelligenceOperationState: Codable, Equatable, Sendable {
  public var id: String
  public var manifestPath: String
  public var backupCount: Int
}

public struct IntelligenceRollbackHint: Codable, Equatable, Sendable {
  public var state: String?
  public var command: String?
}

public struct IntelligenceOperationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var status: IntelligenceOperationStatus
  public var changed: Bool
  public var actions: [IntelligenceActionResult]
  public var state: IntelligenceOperationState?
  public var rollback: IntelligenceRollbackHint?
  public var warnings: [String]
}

public struct IntelligenceVerifyResult: Codable, Equatable, Sendable {
  public var domains: [IntelligenceDomainStatus]
  public var warnings: [String]
}

public struct IntelligenceDomainStatus: Codable, Equatable, Sendable {
  public var domain: String
  public var file: String
  public var key: String
  public var found: Bool
  public var value: String?
  public var expected: String?
  public var matchesExpected: Bool?
}
