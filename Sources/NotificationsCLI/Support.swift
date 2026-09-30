import CryptoKit
import Foundation
import Utility

func notificationRequest(_ options: CLIOptions) throws -> LocalNotificationRequest {
  let title = try requiredOption("title", options: options)
  let body = try requiredOption("body", options: options)

  guard title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--title` cannot be blank.")
  }

  guard body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--body` cannot be blank.")
  }

  return LocalNotificationRequest(
    title: title,
    body: body,
    subtitle: options.targetOption("subtitle")
  )
}

func validateReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation or external-action commands."
    )
  }
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateTargetOptions(_ options: CLIOptions, allowedOptions: Set<String>) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if !unknownOptions.isEmpty || !options.targetFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(options.targetFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` is required."
    )
  }

  return value
}

func notificationScopeDigest(_ request: LocalNotificationRequest) -> String {
  let components = [
    request.title,
    request.subtitle ?? "",
    request.body,
  ].joined(separator: "\u{1f}")

  return "notification:local:\(sha256Hex(components))"
}

func notificationSummary(_ request: LocalNotificationRequest) -> [String: String] {
  [
    "title": request.title,
    "subtitle_present": request.subtitle == nil ? "false" : "true",
    "body_byte_count": "\(Data(request.body.utf8).count)",
  ]
}

func previewHumanOutput(_ request: LocalNotificationRequest) -> String {
  [
    "title: \(request.title)",
    "subtitle: \(request.subtitle ?? "-")",
    "body: \(request.body)",
  ].joined(separator: "\n")
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}
