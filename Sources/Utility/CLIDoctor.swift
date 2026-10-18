import Foundation

public enum CLIDoctorStatus: String, Codable, Equatable, Sendable {
  case ok
  case warning
  case notChecked = "not_checked"
  case permissionDenied = "permission_denied"
  case timeout
  case backendUnavailable = "backend_unavailable"
  case unsupportedOperation = "unsupported_operation"
}

public struct CLIDoctorCheck: Codable, Equatable, Sendable {
  public var name: String
  public var status: CLIDoctorStatus
  public var message: String
  public var details: [String: String]

  public init(
    name: String,
    status: CLIDoctorStatus,
    message: String,
    details: [String: String] = [:]
  ) {
    self.name = name
    self.status = status
    self.message = message
    self.details = details
  }

  public static func backendUnavailable(_ message: String) -> CLIDoctorCheck {
    CLIDoctorCheck(
      name: "backend",
      status: .backendUnavailable,
      message: message
    )
  }

  public static func localPathExists(
    name: String,
    path: String,
    presentMessage: String,
    missingMessage: String
  ) -> CLIDoctorCheck {
    let exists = FileManager.default.fileExists(atPath: path)
    return CLIDoctorCheck(
      name: name,
      status: exists ? .ok : .warning,
      message: exists ? presentMessage : missingMessage,
      details: ["path": path]
    )
  }
}

public struct CLIDoctorReport: Codable, Equatable, Sendable {
  public var target: String
  public var status: CLIDoctorStatus
  public var checks: [CLIDoctorCheck]

  public init(target: String, checks: [CLIDoctorCheck]) {
    self.target = target
    self.checks = checks
    self.status = CLIDoctorReport.overallStatus(for: checks)
  }

  public var exitCode: Int32 {
    switch status {
    case .ok, .warning, .notChecked:
      return 0
    case .permissionDenied:
      return CLIErrorCode.permissionDenied.exitCode
    case .timeout:
      return CLIErrorCode.timeout.exitCode
    case .backendUnavailable:
      return CLIErrorCode.backendUnavailable.exitCode
    case .unsupportedOperation:
      return CLIErrorCode.unsupportedOperation.exitCode
    }
  }

  private static func overallStatus(for checks: [CLIDoctorCheck]) -> CLIDoctorStatus {
    let statuses = checks.map(\.status)

    if statuses.contains(.permissionDenied) {
      return .permissionDenied
    }

    if statuses.contains(.timeout) {
      return .timeout
    }

    if statuses.contains(.backendUnavailable) {
      return .backendUnavailable
    }

    if statuses.contains(.unsupportedOperation) {
      return .unsupportedOperation
    }

    if statuses.contains(.warning) {
      return .warning
    }

    if statuses.contains(.notChecked) {
      return .notChecked
    }

    return .ok
  }
}
