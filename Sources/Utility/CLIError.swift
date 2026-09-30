public enum CLIErrorCode: String, Codable, CaseIterable, Sendable {
  case validationError = "validation_error"
  case permissionDenied = "permission_denied"
  case ambiguousIdentity = "ambiguous_identity"
  case notFound = "not_found"
  case timeout = "timeout"
  case backendUnavailable = "backend_unavailable"
  case unsupportedOperation = "unsupported_operation"
  case unsafeMutationRefused = "unsafe_mutation_refused"
  case internalError = "internal_error"

  public var exitCode: Int32 {
    switch self {
    case .validationError:
      return 2
    case .permissionDenied:
      return 3
    case .ambiguousIdentity:
      return 4
    case .notFound:
      return 5
    case .timeout:
      return 6
    case .backendUnavailable:
      return 7
    case .unsupportedOperation:
      return 8
    case .unsafeMutationRefused:
      return 9
    case .internalError:
      return 70
    }
  }
}

public struct CLIErrorPayload: Codable, Equatable, Sendable {
  public var code: CLIErrorCode
  public var message: String
  public var details: [String: String]

  public init(
    code: CLIErrorCode,
    message: String,
    details: [String: String] = [:]
  ) {
    self.code = code
    self.message = message
    self.details = details
  }
}

public struct CLIError: Error, Equatable, Sendable {
  public var code: CLIErrorCode
  public var message: String
  public var details: [String: String]

  public init(
    code: CLIErrorCode,
    message: String,
    details: [String: String] = [:]
  ) {
    self.code = code
    self.message = message
    self.details = details
  }

  public var payload: CLIErrorPayload {
    CLIErrorPayload(code: code, message: message, details: details)
  }
}
