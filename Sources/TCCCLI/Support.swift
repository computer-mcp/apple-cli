import Foundation
import Utility

func tccValidateReadOnly(
  _ options: CLIOptions,
  allowedOptions: Set<String> = [],
  allowedFlags: Set<String> = []
) throws {
  if options.dryRun {
    throw CLIError(
      code: .unsafeMutationRefused,
      message: TCCWording.readOnlyRejectsDryRun()
    )
  }
  let riskFlags = options.targetFlags.filter {
    $0.hasPrefix("allow-") && !allowedFlags.contains($0)
  }
  if let flag = riskFlags.sorted().first {
    throw CLIError(
      code: .unsafeMutationRefused,
      message: TCCWording.readOnlyRejectsRiskFlags(),
      details: ["flag": "--\(flag)"]
    )
  }
  try tccValidateTargetOptions(options, allowedOptions: allowedOptions, allowedFlags: allowedFlags)
}

func tccValidateTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String> = [],
  allowedFlags: Set<String> = []
) throws {
  let unexpectedOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if let option = unexpectedOptions.sorted().first {
    throw CLIError(
      code: .validationError,
      message: "Unsupported TCC option for this command.",
      details: ["option": "--\(option)"]
    )
  }
  let unexpectedFlags = options.targetFlags.subtracting(allowedFlags)
  if let flag = unexpectedFlags.sorted().first {
    throw CLIError(
      code: .validationError,
      message: "Unsupported TCC flag for this command.",
      details: ["flag": "--\(flag)"]
    )
  }
}

func tccScope(_ options: CLIOptions, default defaultScope: TCCScope = .user) throws -> TCCScope {
  guard let value = options.targetOption("scope") else {
    return defaultScope
  }
  guard let scope = TCCScope(rawValue: value.lowercased()) else {
    throw CLIError(
      code: .validationError,
      message: "`--scope` must be `user`, `system`, or `both`.",
      details: ["scope": value]
    )
  }
  return scope
}

func tccPositiveLimit(_ options: CLIOptions, default defaultLimit: Int = 100) throws -> Int {
  let limit = options.limit ?? defaultLimit
  guard limit > 0 else {
    throw CLIError(code: .validationError, message: "`--limit` must be positive.")
  }
  return limit
}

func tccRequiredPositional(_ options: CLIOptions, at index: Int, name: String) throws -> String {
  guard options.positionals.count > index else {
    throw CLIError(code: .validationError, message: "Missing required positional `\(name)`.")
  }
  return options.positionals[index]
}

func tccOptionalPositional(_ options: CLIOptions, at index: Int) -> String? {
  guard options.positionals.count > index else {
    return nil
  }
  return options.positionals[index]
}

func tccResult(_ payload: some Encodable, human: String, options: CLIOptions, exitCode: Int32 = 0)
  throws -> CLICommandResult
{
  if options.json {
    let envelope = CLISuccessEnvelope(data: payload, meta: ["target": "tcc"])
    return CLICommandResult(
      exitCode: exitCode,
      stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty)
    )
  }
  return CLICommandResult(exitCode: exitCode, stdout: human)
}

func tccBoolFlag(_ options: CLIOptions, _ name: String) -> Bool {
  options.hasTargetFlag(name)
}

struct TCCDryRunContext {
  var operation: String
  var scopeDigest: String
  var scope: String
}

func tccDryRunContext(
  operation: String,
  scope: String,
  summary: [String: String]
) -> TCCDryRunContext {
  TCCDryRunContext(
    operation: operation,
    scopeDigest: sha256Hex(
      summary.keys.sorted().map { "\($0)=\(summary[$0] ?? "")" }.joined(separator: "\u{1f}")
    ),
    scope: scope
  )
}
