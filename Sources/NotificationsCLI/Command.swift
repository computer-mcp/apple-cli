import Foundation
import Utility

public struct NotificationsCommand: Sendable {
  private let backend: any NotificationDelivering
  private let target = "notifications"

  public init(backend: any NotificationDelivering = UserNotificationsBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["notifications", "preview"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(
        options, allowedOptions: ["title", "body", "subtitle", "id", "delay-seconds"])
      let request = try notificationRequest(options)
      return try result(
        NotificationPreviewResponse(notification: request, externalAction: false),
        human: previewHumanOutput(request),
        options: options
      )
    case ["notifications", "send"]:
      try validateTargetOptions(
        options, allowedOptions: ["title", "body", "subtitle", "id", "delay-seconds"])
      let request = try notificationRequest(options)
      return try send(request, options: options)
    case ["notifications", "settings"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let settings = try backend.settings()
      return try result(
        settings,
        human: "authorization=\(settings.authorizationStatus) canSchedule=\(settings.canSchedule)",
        options: options)
    case ["notifications", "permissions", "request"]:
      try validateTargetOptions(options, allowedOptions: [])
      if options.dryRun {
        return try result(
          CLISafety.dryRun(
            target: target, operation: "notifications.permissions.request",
            summary: ["bundle_identifier": NotificationIdentity.bundleIdentifier],
            scope: "notification:authorization:\(NotificationIdentity.bundleIdentifier)",
            category: .persistentAction, allowFlags: ["--allow-persistent-action"]),
          human: "dry-run: notifications.permissions.request", options: options)
      }
      try CLISafety.requireFlag(
        "allow-persistent-action", in: options, category: .persistentAction,
        message: "Notification authorization requires --allow-persistent-action.")
      let authorization = try backend.requestAuthorization()
      return try result(
        authorization, human: "notifications.permissions.request granted=\(authorization.granted)",
        options: options)
    case ["notifications", "pending", "list"], ["notifications", "pending", "read"],
      ["notifications", "pending", "cancel"]:
      return try manage(.pending, action: options.positionals[2], options: options)
    case ["notifications", "delivered", "list"], ["notifications", "delivered", "read"],
      ["notifications", "delivered", "remove"]:
      return try manage(.delivered, action: options.positionals[2], options: options)
    default:
      return nil
    }
  }

  private func manage(
    _ collection: NotificationCollection, action: String, options: CLIOptions
  ) throws -> CLICommandResult? {
    let operation = "notifications.\(collection.rawValue).\(action)"
    switch action {
    case "list":
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let limit = try notificationListLimit(options)
      let records = try backend.requests(in: collection)
      return try result(
        NotificationListResult(
          operation: operation, notifications: records.prefix(limit).map(NotificationSummary.init),
          totalCount: records.count, limit: limit, truncated: records.count > limit),
        human: records.prefix(limit).map { "\($0.identifier)\t\($0.title)" }.joined(
          separator: "\n"),
        options: options)
    case "read":
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let identifier = try notificationIdentifier(requiredOption("id", options: options))
      guard
        let record = try backend.requests(in: collection).first(where: {
          $0.identifier == identifier
        })
      else {
        throw CLIError(
          code: .notFound, message: "The selected notification is not in this collection.",
          details: ["identifier": identifier, "collection": collection.rawValue])
      }
      return try result(
        NotificationReadResult(operation: operation, notification: record),
        human: "\(record.identifier)\n\(record.title)\n\(record.body)", options: options)
    case "cancel" where collection == .pending, "remove" where collection == .delivered:
      try validateTargetOptions(options, allowedOptions: ["id"])
      let identifier = try notificationIdentifier(requiredOption("id", options: options))
      if options.dryRun {
        return try result(
          CLISafety.dryRun(
            target: target, operation: operation,
            summary: ["identifier": identifier, "collection": collection.rawValue],
            scope: "notification:\(collection.rawValue):\(identifier)", category: .persistentAction,
            allowFlags: ["--allow-persistent-action"]),
          human: "dry-run: \(operation) \(identifier)", options: options)
      }
      try CLISafety.requireFlag(
        "allow-persistent-action", in: options, category: .persistentAction,
        message: "Notification removal requires --allow-persistent-action.")
      let removal = try backend.remove(identifier: identifier, from: collection)
      return try result(
        removal,
        human:
          "\(operation) attempted=\(removal.attempted) verifiedAbsent=\(removal.verifiedAbsent)",
        options: options)
    default: return nil
    }
  }

  private func send(_ request: LocalNotificationRequest, options: CLIOptions) throws
    -> CLICommandResult
  {
    let operation = "notifications.send"
    let scopeDigest = notificationScopeDigest(request)
    let summary = notificationSummary(request)

    if options.dryRun {
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

    let submission = try backend.send(request)
    return try result(
      NotificationSendResult(
        operation: operation, submitted: submission.submitted, identifier: submission.identifier),
      human:
        "notifications.send submitted=\(submission.submitted) identifier=\(submission.identifier)",
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
