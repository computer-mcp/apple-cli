import CryptoKit
import Foundation
import Utility

public struct NotificationsCommand: Sendable {
  private let backend: any NotificationDelivering
  private let target = "notifications"

  public init(backend: any NotificationDelivering = LegacyNSUserNotificationBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["notifications", "preview"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["title", "body", "subtitle"])
      let request = try notificationRequest(options)
      return try result(
        NotificationPreviewResponse(notification: request, externalAction: false),
        human: previewHumanOutput(request),
        options: options
      )
    case ["notifications", "send"]:
      try validateTargetOptions(options, allowedOptions: ["title", "body", "subtitle"])
      let request = try notificationRequest(options)
      return try send(request, options: options)
    default:
      return nil
    }
  }

  private func send(_ request: LocalNotificationRequest, options: CLIOptions) throws
    -> CLICommandResult
  {
    let operation = "notifications.send"
    let scopeDigest = notificationScopeDigest(request)
    let summary = notificationSummary(request)

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message:
        "Notification send dispatches to UserNotifications and requires `--allow-external-dispatch`."
    )

    let submitted = try backend.send(request)
    return try result(
      NotificationSendResult(operation: operation, submitted: submitted),
      human: "notifications.send submitted=\(submitted)",
      options: options
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
