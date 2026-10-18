import Foundation
import UserNotifications
import Utility

enum NotificationIdentity {
  static let bundleIdentifier = "io.github.computer-mcp.apple-cli"
  static let requestPrefix = "apple-cli:"
}

public struct UserNotificationsBackend: NotificationDelivering {
  public init() {}

  private func center() throws -> UNUserNotificationCenter {
    guard Bundle.main.bundleIdentifier == NotificationIdentity.bundleIdentifier else {
      throw CLIError(
        code: .backendUnavailable,
        message: "The apple executable does not have its notification identity.",
        details: ["expected_bundle_identifier": NotificationIdentity.bundleIdentifier])
    }
    return UNUserNotificationCenter.current()
  }

  public func settings() throws -> NotificationSettingsRecord {
    let center = try center()
    return try notificationCallback(phase: "settings") { finish in
      center.getNotificationSettings { value in
        finish(.success(notificationSettingsRecord(value)))
      }
    }
  }

  public func send(_ request: LocalNotificationRequest) throws -> NotificationSubmission {
    if let delay = request.delaySeconds, !(1...604_800).contains(delay) {
      throw CLIError(
        code: .validationError, message: "Notification delay is outside the supported range.")
    }
    let identifier =
      try request.identifier.map(notificationIdentifier) ?? "apple-cli:\(UUID().uuidString)"
    let state = try settings()
    guard state.canSchedule else {
      throw CLIError(
        code: .permissionDenied,
        message: "Apple CLI is not authorized to schedule notifications.",
        details: [
          "authorization_status": state.authorizationStatus,
          "bundle_identifier": state.bundleIdentifier,
          "guidance": "Use apple notifications permissions request to ask for authorization.",
        ])
    }
    let center = try center()
    let content = UNMutableNotificationContent()
    content.title = request.title
    content.body = request.body
    content.subtitle = request.subtitle ?? ""
    let trigger = request.delaySeconds.map {
      UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval($0), repeats: false)
    }
    let native = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    return try notificationCallback(phase: "add", identifier: identifier, mutation: true) {
      finish in
      center.add(native) { error in
        if let error {
          finish(.failure(notificationNativeError(error, phase: "add", identifier: identifier)))
        } else {
          finish(.success(NotificationSubmission(identifier: identifier, submitted: true)))
        }
      }
    }
  }

  public func requestAuthorization() throws -> NotificationAuthorizationResult {
    let center = try center()
    let granted: Bool = try notificationCallback(
      phase: "authorization", mutation: true, timeoutSeconds: 60
    ) { finish in
      center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error {
          finish(.failure(notificationNativeError(error, phase: "authorization")))
        } else {
          finish(.success(granted))
        }
      }
    }
    do {
      return NotificationAuthorizationResult(
        operation: "notifications.permissions.request", granted: granted, settings: try settings())
    } catch let error as CLIError {
      var details = error.details
      details["phase"] = "authorization_settings_readback"
      details["authorization_callback_received"] = "true"
      details["granted"] = "\(granted)"
      details["mutation_may_have_occurred"] = "true"
      throw CLIError(
        code: error.code,
        message: "Authorization completed, but native settings could not be read.",
        details: details)
    }
  }

  public func requests(in collection: NotificationCollection) throws -> [NotificationRecord] {
    let center = try center()
    return try notificationCallback(phase: collection.rawValue) { finish in
      switch collection {
      case .pending:
        center.getPendingNotificationRequests { requests in
          finish(.success(notificationRecords(requests)))
        }
      case .delivered:
        center.getDeliveredNotifications { notifications in
          let records = notifications.filter {
            $0.request.identifier.hasPrefix(NotificationIdentity.requestPrefix)
          }.map { notificationRecord($0.request, deliveredAt: $0.date) }
          finish(.success(records.sorted { $0.identifier < $1.identifier }))
        }
      }
    }
  }

  public func remove(identifier: String, from collection: NotificationCollection) throws
    -> NotificationRemovalResult
  {
    let identifier = try notificationIdentifier(identifier)
    let action = collection == .pending ? "cancel" : "remove"
    let operation = "notifications.\(collection.rawValue).\(action)"
    let before = try requests(in: collection)
    guard before.contains(where: { $0.identifier == identifier }) else {
      return NotificationRemovalResult(
        operation: operation, identifier: identifier, attempted: false,
        wasPresent: false, verifiedAbsent: true)
    }
    let center = try center()
    switch collection {
    case .pending: center.removePendingNotificationRequests(withIdentifiers: [identifier])
    case .delivered: center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    do {
      let after = try requests(in: collection)
      guard !after.contains(where: { $0.identifier == identifier }) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "The selected notification remains in the native collection.")
      }
    } catch let error as CLIError {
      var details = error.details
      details["phase"] = "\(collection.rawValue)_removal_readback"
      details["identifier"] = identifier
      details["attempted"] = "true"
      details["mutation_may_have_occurred"] = "true"
      throw CLIError(code: error.code, message: error.message, details: details)
    }
    return NotificationRemovalResult(
      operation: operation, identifier: identifier, attempted: true,
      wasPresent: true, verifiedAbsent: true)
  }
}

func notificationRecords(_ requests: [UNNotificationRequest]) -> [NotificationRecord] {
  requests.filter { $0.identifier.hasPrefix(NotificationIdentity.requestPrefix) }
    .map { notificationRecord($0) }
    .sorted { $0.identifier < $1.identifier }
}

func notificationRecord(_ request: UNNotificationRequest, deliveredAt: Date? = nil)
  -> NotificationRecord
{
  let trigger: NotificationTriggerRecord?
  if let interval = request.trigger as? UNTimeIntervalNotificationTrigger {
    trigger = NotificationTriggerRecord(
      kind: "timeInterval", repeats: interval.repeats,
      timeIntervalSeconds: interval.timeInterval, nextTriggerAt: interval.nextTriggerDate())
  } else if let calendar = request.trigger as? UNCalendarNotificationTrigger {
    trigger = NotificationTriggerRecord(
      kind: "calendar", repeats: calendar.repeats, dateComponents: calendar.dateComponents,
      nextTriggerAt: calendar.nextTriggerDate())
  } else if let native = request.trigger {
    trigger = NotificationTriggerRecord(
      kind: native is UNPushNotificationTrigger ? "push" : "unknown", repeats: native.repeats)
  } else {
    trigger = nil
  }
  return NotificationRecord(
    identifier: request.identifier, title: request.content.title, body: request.content.body,
    subtitle: request.content.subtitle, trigger: trigger, deliveredAt: deliveredAt)
}

func notificationNativeError(
  _ error: any Error, phase: String, identifier: String? = nil
) -> CLIError {
  let native = error as NSError
  var details = ["phase": phase, "error_domain": native.domain, "error_code": "\(native.code)"]
  if let identifier { details["identifier"] = identifier }
  if native.domain == UNErrorDomain, native.code == UNError.Code.notificationsNotAllowed.rawValue {
    return CLIError(
      code: .permissionDenied, message: "Apple CLI notifications are not allowed.", details: details
    )
  }
  return CLIError(
    code: .backendUnavailable, message: "The notification service rejected the request.",
    details: details)
}

private func notificationSettingsRecord(_ value: UNNotificationSettings)
  -> NotificationSettingsRecord
{
  let authorization: String
  switch value.authorizationStatus {
  case .notDetermined: authorization = "notDetermined"
  case .denied: authorization = "denied"
  case .authorized: authorization = "authorized"
  case .provisional: authorization = "provisional"
  @unknown default: authorization = "unknown"
  }
  return NotificationSettingsRecord(
    bundleIdentifier: NotificationIdentity.bundleIdentifier, authorizationStatus: authorization,
    canSchedule: value.authorizationStatus == .authorized
      || value.authorizationStatus == .provisional,
    alert: notificationSetting(value.alertSetting), sound: notificationSetting(value.soundSetting),
    badge: notificationSetting(value.badgeSetting),
    notificationCenter: notificationSetting(value.notificationCenterSetting),
    lockScreen: notificationSetting(value.lockScreenSetting))
}

private func notificationSetting(_ value: UNNotificationSetting) -> String {
  switch value {
  case .notSupported: "notSupported"
  case .disabled: "disabled"
  case .enabled: "enabled"
  @unknown default: "unknown"
  }
}

func notificationCallback<Value: Sendable>(
  phase: String, identifier: String? = nil, mutation: Bool = false, timeoutSeconds: Int = 10,
  start: (@escaping @Sendable (Result<Value, CLIError>) -> Void) -> Void
) throws -> Value {
  let completion = NotificationCompletion<Value>()
  start { completion.finish($0) }
  return try completion.wait(
    phase: phase, identifier: identifier, mutation: mutation, timeoutSeconds: timeoutSeconds)
}

private final class NotificationCompletion<Value: Sendable>: @unchecked Sendable {
  private let lock = NSLock()
  private let signal = DispatchSemaphore(value: 0)
  private var result: Result<Value, CLIError>?
  private var closed = false

  func finish(_ result: Result<Value, CLIError>) {
    lock.withLock {
      guard !closed, self.result == nil else { return }
      self.result = result
      signal.signal()
    }
  }

  func wait(phase: String, identifier: String?, mutation: Bool, timeoutSeconds: Int) throws -> Value
  {
    _ = signal.wait(timeout: .now() + .seconds(timeoutSeconds))
    return try lock.withLock {
      closed = true
      if let result { return try result.get() }
      var details = ["phase": phase]
      if let identifier { details["identifier"] = identifier }
      if mutation { details["mutation_may_have_occurred"] = "true" }
      throw CLIError(
        code: .timeout, message: "The notification service did not return a result in time.",
        details: details)
    }
  }
}
