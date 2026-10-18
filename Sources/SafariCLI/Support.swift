import CryptoKit
import Foundation
import Utility

func safariRunRows(_ source: String, timeoutSeconds: Int = 30) throws -> [[String]] {
  var errorInfo: NSDictionary?
  guard let script = NSAppleScript(source: safariScriptWithTimeout(source, seconds: timeoutSeconds))
  else {
    throw CLIError(code: .internalError, message: "Failed to compile Safari automation script.")
  }

  let descriptor = script.executeAndReturnError(&errorInfo)
  if let errorInfo {
    throw safariAutomationError(errorInfo)
  }

  return descriptor.rows()
}

func safariRunVoid(_ source: String, timeoutSeconds: Int = 30) throws {
  _ = try safariRunRows(source, timeoutSeconds: timeoutSeconds)
}

func safariRunString(_ source: String, timeoutSeconds: Int = 30) throws -> String {
  var errorInfo: NSDictionary?
  guard let script = NSAppleScript(source: safariScriptWithTimeout(source, seconds: timeoutSeconds))
  else {
    throw CLIError(code: .internalError, message: "Failed to compile Safari automation script.")
  }

  let descriptor = script.executeAndReturnError(&errorInfo)
  if let errorInfo {
    throw safariAutomationError(errorInfo)
  }

  return descriptor.stringValue ?? ""
}

func safariScriptWithTimeout(_ source: String, seconds: Int) -> String {
  """
  with timeout of \(seconds) seconds
  \(source)
  end timeout
  """
}

func safariAutomationError(_ errorInfo: NSDictionary) -> CLIError {
  let number = errorInfo[NSAppleScript.errorNumber] as? Int
  let code: CLIErrorCode =
    if number == -1712 {
      .timeout
    } else if let number, [-1743, -25211].contains(number) {
      .permissionDenied
    } else if number == -1728 {
      .notFound
    } else {
      .backendUnavailable
    }
  return CLIError.appleEventFailure(
    target: "Safari", code: code, number: number,
    details: ["executor": "NSAppleScript"])
}

func validateSafariReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation, state-action, or strong-gate commands."
    )
  }
}

func validateSafariDryRunOptions(_ options: CLIOptions) throws {}

func validateSafariDryRunIntent(_ options: CLIOptions, description: String) throws {}

func validateSafariTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String>,
  allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    let unsupported =
      (unknownOptions.map { "--\($0)" } + unknownFlags.map { "--\($0)" }).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.joined(separator: ",")]
    )
  }
}

func safariRequiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name)?.trimmingCharacters(in: .whitespacesAndNewlines),
    !value.isEmpty
  else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }
  return value
}

func safariOptionalPositiveInt(_ name: String, options: CLIOptions) throws -> Int? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  return try safariPositiveInt(value, flag: "--\(name)")
}

func safariRequiredPositiveInt(_ name: String, options: CLIOptions) throws -> Int {
  try safariPositiveInt(try safariRequiredOption(name, options: options), flag: "--\(name)")
}

func safariPositiveInt(_ value: String, flag: String) throws -> Int {
  guard let parsed = Int(value), parsed > 0 else {
    throw CLIError(code: .validationError, message: "`\(flag)` requires a positive integer value.")
  }
  return parsed
}

func safariMaxBytes(_ options: CLIOptions, default defaultValue: Int = 16 * 1024) throws -> Int {
  guard let value = options.targetOption("max-bytes") else {
    return defaultValue
  }
  let parsed = try safariPositiveInt(value, flag: "--max-bytes")
  guard parsed <= 1024 * 1024 else {
    throw CLIError(code: .validationError, message: "`--max-bytes` cannot exceed 1048576.")
  }
  return parsed
}

func safariValidatedURL(_ value: String, option: String = "--url") throws -> URL {
  guard let url = URL(string: value), let scheme = url.scheme?.lowercased(),
    ["http", "https"].contains(scheme), url.host != nil
  else {
    throw CLIError(
      code: .validationError,
      message: "`\(option)` must be an absolute http or https URL."
    )
  }
  return url
}

func safariQuery(_ options: CLIOptions) throws -> String {
  let query = try safariRequiredOption("query", options: options)
  guard query.count >= 2 else {
    throw CLIError(
      code: .validationError,
      message: "`--query` must contain at least 2 non-whitespace characters."
    )
  }
  return query
}

func safariRequireFlag(_ flag: String, options: CLIOptions) throws {
  guard options.hasTargetFlag(flag) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(flag)` is required for this strong-gate command.",
      details: ["gate": "strong-gate"]
    )
  }
}

func safariProofFailed(_ command: String, reason: String) -> CLIError {
  CLIError(
    code: .unsupportedOperation,
    message: "Proof failed for this Safari command.",
    details: ["command": command, "proof_status": "proof-failed", "reason": reason]
  )
}

func safariAppleScriptString(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
}

func safariBool(_ value: String?) -> Bool {
  switch value?.lowercased() {
  case "true", "yes", "1":
    return true
  default:
    return false
  }
}

func safariInt(_ value: String?) -> Int? {
  guard let value else {
    return nil
  }
  return Int(value)
}

func safariTruncate(_ value: String, maxBytes: Int) -> (String, Bool) {
  let data = Data(value.utf8)
  guard data.count > maxBytes else {
    return (value, false)
  }

  var prefix = data.prefix(maxBytes)
  while String(data: prefix, encoding: .utf8) == nil, !prefix.isEmpty {
    prefix = prefix.dropLast()
  }
  return (String(data: prefix, encoding: .utf8) ?? "", true)
}

func safariSHA256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

extension NSAppleEventDescriptor {
  func rows() -> [[String]] {
    guard numberOfItems > 0 else {
      return []
    }

    return (1...numberOfItems).map { index in
      guard let row = atIndex(index) else {
        return []
      }
      return row.strings()
    }
  }

  func strings() -> [String] {
    guard numberOfItems > 0 else {
      return [stringValue ?? ""]
    }

    return (1...numberOfItems).map { index in
      atIndex(index)?.stringValue ?? ""
    }
  }
}

extension Array {
  subscript(safariSafe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
