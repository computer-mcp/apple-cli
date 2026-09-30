import Foundation

public struct CLIDryRun: Codable, Equatable, Sendable {
  public var mode: String
  public var target: String
  public var operation: String
  public var normalizedArguments: [String: String]
  public var resolvedScope: [String: String]
  public var wouldMutate: [CLIDryRunMutation]
  public var requirements: CLIDryRunRequirements
  public var risks: [CLIDryRunRisk]

  public init(
    target: String,
    operation: String,
    normalizedArguments: [String: String] = [:],
    resolvedScope: [String: String] = [:],
    wouldMutate: [CLIDryRunMutation] = [],
    requirements: CLIDryRunRequirements = CLIDryRunRequirements(),
    risks: [CLIDryRunRisk] = []
  ) {
    self.mode = "dry-run"
    self.target = target
    self.operation = operation
    self.normalizedArguments = normalizedArguments
    self.resolvedScope = resolvedScope
    self.wouldMutate = wouldMutate
    self.requirements = requirements
    self.risks = risks
  }
}

public struct CLIDryRunMutation: Codable, Equatable, Sendable {
  public var action: String
  public var resource: String
  public var identifier: String?
  public var fields: [String: String]

  public init(
    action: String,
    resource: String,
    identifier: String? = nil,
    fields: [String: String] = [:]
  ) {
    self.action = action
    self.resource = resource
    self.identifier = identifier
    self.fields = fields
  }
}

public struct CLIDryRunRequirements: Codable, Equatable, Sendable {
  public var allowFlags: [String]
  public var permissions: [String]
  public var notes: [String]

  public init(
    allowFlags: [String] = [],
    permissions: [String] = [],
    notes: [String] = []
  ) {
    self.allowFlags = allowFlags
    self.permissions = permissions
    self.notes = notes
  }
}

public struct CLIDryRunRisk: Codable, Equatable, Sendable {
  public var category: CLISafetyCategory
  public var flag: String?
  public var message: String

  public init(category: CLISafetyCategory, flag: String? = nil, message: String) {
    self.category = category
    self.flag = flag
    self.message = message
  }
}

public enum CLISafetyCategory: String, Codable, Equatable, Sendable {
  case readOnly
  case boundedRead
  case ordinaryMutation
  case destructiveSelection
  case externalDispatch
  case riskBoundSystemAction
  case artifactAction
  case persistentAction
}

public enum CLISafety {
  public static func dryRun(
    target: String,
    operation: String,
    summary: [String: String],
    scope: String,
    category: CLISafetyCategory = .ordinaryMutation,
    allowFlags: [String] = [],
    permissions: [String] = [],
    notes: [String] = []
  ) -> CLIDryRun {
    CLIDryRun(
      target: target,
      operation: operation,
      normalizedArguments: summary,
      resolvedScope: ["scope": scope],
      wouldMutate: [
        CLIDryRunMutation(
          action: operation,
          resource: target,
          identifier: summary["id"],
          fields: summary
        )
      ],
      requirements: CLIDryRunRequirements(
        allowFlags: allowFlags,
        permissions: permissions,
        notes: notes
      ),
      risks: [
        CLIDryRunRisk(
          category: category,
          flag: allowFlags.first,
          message: riskMessage(category: category, operation: operation)
        )
      ]
    )
  }

  public static func requireFlag(
    _ flag: String,
    in options: CLIOptions,
    category: CLISafetyCategory,
    message: String
  ) throws {
    if options.dryRun {
      return
    }
    guard options.hasTargetFlag(flag) else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: message,
        details: [
          "required_flag": "--\(flag)",
          "risk": category.rawValue,
        ]
      )
    }
  }

  public static func rejectDryRunForReadOnly(_ options: CLIOptions) throws {
    if options.dryRun {
      throw CLIError(
        code: .validationError,
        message: "`--dry-run` is only valid for mutation or external-action commands."
      )
    }
  }

  private static func riskMessage(category: CLISafetyCategory, operation: String) -> String {
    switch category {
    case .readOnly:
      return "\(operation) is read-only."
    case .boundedRead:
      return "\(operation) performs a bounded read before the side-effect boundary."
    case .ordinaryMutation:
      return "\(operation) would perform an explicit mutation."
    case .destructiveSelection:
      return "\(operation) would mutate or delete a selected set."
    case .externalDispatch:
      return "\(operation) would dispatch work to an external application or system service."
    case .riskBoundSystemAction:
      return "\(operation) would perform a risk-bound system action."
    case .artifactAction:
      return "\(operation) would create, overwrite, move, or remove filesystem artifacts."
    case .persistentAction:
      return "\(operation) would persist state beyond the immediate command."
    }
  }
}
