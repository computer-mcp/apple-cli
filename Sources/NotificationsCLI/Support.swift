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

  let delay: Int?
  if let raw = options.targetOption("delay-seconds") {
    guard let value = Int(raw), (1...604_800).contains(value) else {
      throw CLIError(
        code: .validationError, message: "--delay-seconds requires an integer from 1 to 604800.")
    }
    delay = value
  } else {
    delay = nil
  }
  return LocalNotificationRequest(
    title: title,
    body: body,
    subtitle: options.targetOption("subtitle"),
    identifier: try options.targetOption("id").map(notificationIdentifier),
    delaySeconds: delay
  )
}

func notificationIdentifier(_ value: String) throws -> String {
  let normalized =
    value.hasPrefix(NotificationIdentity.requestPrefix)
    ? value : NotificationIdentity.requestPrefix + value
  guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
    normalized.utf8.count <= 500,
    !value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains)
  else {
    throw CLIError(
      code: .validationError,
      message: "Notification ID is blank, too long or contains control characters.")
  }
  return normalized
}

func notificationListLimit(_ options: CLIOptions) throws -> Int {
  let value = options.limit ?? 50
  guard (1...500).contains(value) else {
    throw CLIError(code: .validationError, message: "--limit requires an integer from 1 to 500.")
  }
  return value
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
  var components = [
    request.title,
    request.subtitle ?? "",
    request.body,
  ]
  if let identifier = request.identifier { components.append("id:\(identifier)") }
  if let delay = request.delaySeconds { components.append("delay:\(delay)") }

  return "notification:local:\(sha256Hex(components.joined(separator: "\u{1f}")))"
}

func notificationSummary(_ request: LocalNotificationRequest) -> [String: String] {
  var result = [
    "title": request.title,
    "subtitle_present": request.subtitle == nil ? "false" : "true",
    "body_byte_count": "\(Data(request.body.utf8).count)",
  ]
  if let identifier = request.identifier { result["identifier"] = identifier }
  if let delay = request.delaySeconds { result["delay_seconds"] = "\(delay)" }
  return result
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
