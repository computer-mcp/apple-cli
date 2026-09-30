import Utility

public enum IntelligenceFailure: String, Codable, CaseIterable, Sendable {
  case dryRunRejectedForReadOnly = "dry_run_rejected_for_read_only"
  case readOnlyRiskFlagsRejected = "read_only_risk_flags_rejected"
  case unsupportedOption = "unsupported_option"
  case missingRequiredOption = "missing_required_option"
  case unsupportedPatchScope = "unsupported_patch_scope"
  case invalidCountryCode = "invalid_eligibility_country"
  case invalidPositiveInteger = "invalid_positive_integer"
  case missingRiskFlag = "missing_risk_flag"
  case systemRootOnlyFlag = "system_root_only_flag"
  case latestStateEscapesStateDir = "latest_state_escapes_state_dir"
  case invalidStateID = "invalid_state_id"
  case stateEscapesStateDir = "state_escapes_state_dir"
  case stateRootMismatch = "state_root_mismatch"
  case manifestEscapesStateDir = "manifest_escapes_state_dir"
  case rollbackTargetEscapesRoot = "rollback_target_escapes_root"
  case rollbackBackupEscapesStateDir = "rollback_backup_escapes_state_dir"
  case plistRootNotDictionary = "plist_root_not_dictionary"
  case lldbPathNotExecutable = "lldb_path_not_executable"
  case lldbNotFound = "lldb_not_found"
  case rootRequiredForSystemWrite = "root_required_for_system_write"
  case sipBlocksSystemWrite = "sip_blocks_system_write"
  case targetPathNotWritable = "target_path_not_writable"
  case targetPathParentNotWritable = "target_path_parent_not_writable"
  case backendNotImplemented = "backend_not_implemented"
  case unhandledError = "unhandled_error"
}

public enum IntelligenceWording {
  public static func message(for failure: IntelligenceFailure, details: [String: String] = [:]) -> String {
    switch failure {
    case .dryRunRejectedForReadOnly:
      return "Read-only intelligence commands do not accept `--dry-run`."
    case .readOnlyRiskFlagsRejected:
      return "Read-only intelligence commands do not accept risk flags."
    case .unsupportedOption:
      return "Unsupported option for intelligence command."
    case .missingRequiredOption:
      return "Missing required intelligence option."
    case .unsupportedPatchScope:
      return "Unsupported eligibility patch scope."
    case .invalidCountryCode:
      return "`--eligibility-country` must be a two-letter country code."
    case .invalidPositiveInteger:
      return "Intelligence option must be a positive integer."
    case .missingRiskFlag:
      let operation = details["operation"] ?? "This intelligence operation"
      let flag = details["required_flag"].map { "--\($0)" } ?? "the required risk flag"
      return "\(operation) requires \(flag)."
    case .systemRootOnlyFlag:
      let flag = details["flag"].map { "--\($0)" } ?? "This flag"
      return "\(flag) is only valid with `--root /`."
    case .latestStateEscapesStateDir:
      return "Latest intelligence state escapes state-dir."
    case .invalidStateID:
      return "`--state` must be `latest` or a state id created by apple intelligence."
    case .stateEscapesStateDir:
      return "Intelligence state escapes state-dir."
    case .stateRootMismatch:
      return "Intelligence state root does not match the requested root."
    case .manifestEscapesStateDir:
      return "Intelligence manifest path escapes state-dir."
    case .rollbackTargetEscapesRoot:
      return "Intelligence rollback target escapes root."
    case .rollbackBackupEscapesStateDir:
      return "Intelligence rollback backup escapes state-dir."
    case .plistRootNotDictionary:
      return "Plist root is not a dictionary."
    case .lldbPathNotExecutable:
      return "Explicit lldb path is not executable."
    case .lldbNotFound:
      return "lldb not found; install Xcode Command Line Tools or pass `--lldb-path`."
    case .rootRequiredForSystemWrite:
      let operation = details["operation"] ?? "This intelligence operation"
      return "\(operation) writes system eligibility state and must be run as root when `--root` is `/`."
    case .sipBlocksSystemWrite:
      let operation = details["operation"] ?? "This intelligence operation"
      return "\(operation) requires System Integrity Protection to allow system eligibility cache writes."
    case .targetPathNotWritable:
      let operation = details["operation"] ?? "This intelligence operation"
      return "\(operation) cannot write eligibility target path."
    case .targetPathParentNotWritable:
      let operation = details["operation"] ?? "This intelligence operation"
      return "\(operation) cannot create missing eligibility target path."
    case .backendNotImplemented:
      return "Command is documented but this intelligence backend is not implemented."
    case .unhandledError:
      return "Unhandled intelligence CLI error."
    }
  }
}

func intelligenceError(
  code: CLIErrorCode,
  failure: IntelligenceFailure,
  details: [String: String] = [:]
) -> CLIError {
  var normalizedDetails = details
  normalizedDetails["failure"] = failure.rawValue
  return CLIError(
    code: code,
    message: IntelligenceWording.message(for: failure, details: normalizedDetails),
    details: normalizedDetails
  )
}
