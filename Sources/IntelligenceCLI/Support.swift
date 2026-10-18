import Foundation
import Utility
#if canImport(Darwin)
import Darwin
#endif

func validateNoDryRunForReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw intelligenceError(
      code: .validationError,
      failure: .dryRunRejectedForReadOnly
    )
  }
}

func validateReadOnly(_ options: CLIOptions) throws {
  try validateNoDryRunForReadOnly(options)
  if !options.targetFlags.isEmpty {
    throw intelligenceError(
      code: .validationError,
      failure: .readOnlyRiskFlagsRejected,
      details: ["flags": options.targetFlags.sorted().joined(separator: ",")]
    )
  }
}

func validateTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String>,
  allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    throw intelligenceError(
      code: .validationError,
      failure: .unsupportedOption,
      details: [
        "options": unknownOptions.sorted().joined(separator: ","),
        "flags": unknownFlags.sorted().joined(separator: ","),
      ]
    )
  }
}

func requireRiskFlag(_ name: String, options: CLIOptions, operation: String) throws {
  if options.dryRun {
    return
  }
  guard options.hasTargetFlag(name) else {
    throw intelligenceError(
      code: .unsafeMutationRefused,
      failure: .missingRiskFlag,
      details: ["operation": operation, "required_flag": name]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw intelligenceError(
      code: .validationError,
      failure: .missingRequiredOption,
      details: ["option": name]
    )
  }
  return value
}

func patchScopeOption(_ options: CLIOptions) throws -> IntelligencePatchScope {
  let raw = options.targetOption("patch-scope") ?? IntelligencePatchScope.comprehensive.rawValue
  guard let patchScope = IntelligencePatchScope(rawValue: raw) else {
    throw intelligenceError(
      code: .validationError,
      failure: .unsupportedPatchScope,
      details: ["patch_scope": raw, "allowed": "answer,comprehensive"]
    )
  }
  return patchScope
}

func validatedCountryCode(_ raw: String?) throws -> String? {
  guard let raw, !raw.isEmpty else { return nil }
  let country = raw.uppercased()
  guard country.count == 2, country.allSatisfy({ $0 >= "A" && $0 <= "Z" }) else {
    throw intelligenceError(
      code: .validationError,
      failure: .invalidCountryCode,
      details: ["eligibility_country": raw]
    )
  }
  return country
}

func intOption(_ name: String, options: CLIOptions, default defaultValue: Int) throws -> Int {
  guard let raw = options.targetOption(name) else {
    return defaultValue
  }
  guard let value = Int(raw), value > 0 else {
    throw intelligenceError(
      code: .validationError,
      failure: .invalidPositiveInteger,
      details: [name: raw]
    )
  }
  return value
}

func boolFlag(_ name: String, options: CLIOptions) -> Bool {
  options.hasTargetFlag(name)
}

func intelligencePaths(options: CLIOptions) -> IntelligencePaths {
  IntelligencePaths(root: options.targetOption("root") ?? "/", stateDir: options.targetOption("state-dir"))
}

func preflightSystemCacheWrite(
  paths: IntelligencePaths,
  targets: [String],
  createMissing: Bool,
  operation: String
) throws {
  if paths.root == "/" {
    try requireRootForSystemMutation(operation: operation)
    try requireSIPDisabledForSystemMutation(operation: operation)
  }

  for target in targets {
    try preflightWritableTarget(target, createMissing: createMissing, operation: operation)
  }
}

func preflightDebugAttach(lldbPath: String?) throws {
  if let lldbPath, !lldbPath.isEmpty {
    let normalized = URL(fileURLWithPath: lldbPath).standardizedFileURL.path
    guard FileManager.default.fileExists(atPath: normalized), FileManager.default.isExecutableFile(atPath: normalized)
    else {
      throw intelligenceError(
        code: .notFound,
        failure: .lldbPathNotExecutable,
        details: ["lldb_path": normalized]
      )
    }
  }
}

func intelligenceResult(_ payload: some Encodable, human: String, options: CLIOptions) throws
  -> CLICommandResult
{
  if options.json {
    let envelope = CLISuccessEnvelope(data: payload, meta: ["target": "intelligence"])
    return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
  }
  return CLICommandResult(stdout: human)
}

func intelligenceOperationCommand(_ operation: String, result: IntelligenceOperationResult) -> String {
  var parts = [
    "\(operation) status=\(result.status.rawValue)",
    "changed=\(result.changed)",
    "actions=\(result.actions.count)",
  ]
  if let state = result.state {
    parts.append("state=\(state.id)")
  }
  if let command = result.rollback?.command {
    parts.append("rollback=\"\(command)\"")
  }
  return parts.joined(separator: " ")
}

private func requireRootForSystemMutation(operation: String) throws {
  #if canImport(Darwin)
  let euid = geteuid()
  guard euid == 0 else {
    throw intelligenceError(
      code: .unsafeMutationRefused,
      failure: .rootRequiredForSystemWrite,
      details: ["operation": operation, "euid": "\(euid)"]
    )
  }
  #endif
}

private func requireSIPDisabledForSystemMutation(operation: String) throws {
  guard let sip = readPreflightCommand(.path("/usr/bin/csrutil"), ["status"]) else {
    return
  }
  let normalized = sip.lowercased()
  if normalized.contains("enabled"), !normalized.contains("disabled") {
    throw intelligenceError(
      code: .unsafeMutationRefused,
      failure: .sipBlocksSystemWrite,
      details: ["operation": operation, "sip": sip]
    )
  }
}

private func preflightWritableTarget(_ target: String, createMissing: Bool, operation: String) throws {
  let fileManager = FileManager.default
  let url = URL(fileURLWithPath: target)
  let parent = url.deletingLastPathComponent()

  if fileManager.fileExists(atPath: target) {
    if fileManager.isWritableFile(atPath: target) || fileManager.isWritableFile(atPath: parent.path) {
      return
    }
    throw intelligenceError(
      code: .unsafeMutationRefused,
      failure: .targetPathNotWritable,
      details: ["operation": operation, "path": target]
    )
  }

  guard createMissing else { return }
  let writableParent = nearestExistingParent(parent)
  guard fileManager.isWritableFile(atPath: writableParent.path) else {
    throw intelligenceError(
      code: .unsafeMutationRefused,
      failure: .targetPathParentNotWritable,
      details: ["operation": operation, "path": target, "parent": writableParent.path]
    )
  }
}

private func nearestExistingParent(_ url: URL) -> URL {
  let fileManager = FileManager.default
  var candidate = url.standardizedFileURL
  while !fileManager.fileExists(atPath: candidate.path) {
    let parent = candidate.deletingLastPathComponent()
    if parent.path == candidate.path {
      return candidate
    }
    candidate = parent
  }
  return candidate
}

private func readPreflightCommand(_ executable: CLISubprocess.Executable, _ arguments: [String]) -> String? {
  guard let result = try? CLISubprocess.run(executable, arguments: arguments, timeoutSeconds: 3),
    result.exitCode == 0
  else {
    return nil
  }
  return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
}
