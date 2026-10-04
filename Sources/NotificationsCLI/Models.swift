import Foundation

public struct LocalNotificationRequest: Codable, Equatable, Sendable {
  public var title: String
  public var body: String
  public var subtitle: String?
  public var identifier: String?
  public var delaySeconds: Int?

  public init(
    title: String, body: String, subtitle: String? = nil, identifier: String? = nil,
    delaySeconds: Int? = nil
  ) {
    self.title = title
    self.body = body
    self.subtitle = subtitle
    self.identifier = identifier
    self.delaySeconds = delaySeconds
  }
}

public struct NotificationPreviewResponse: Codable, Equatable, Sendable {
  public var notification: LocalNotificationRequest
  public var externalAction: Bool
}

public struct NotificationSendResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var identifier: String
}

public struct NotificationSubmission: Codable, Equatable, Sendable {
  public var identifier: String
  public var submitted: Bool

  public init(identifier: String, submitted: Bool) {
    self.identifier = identifier
    self.submitted = submitted
  }
}

public struct NotificationSettingsRecord: Codable, Equatable, Sendable {
  public var bundleIdentifier: String
  public var authorizationStatus: String
  public var canSchedule: Bool
  public var alert: String
  public var sound: String
  public var badge: String
  public var notificationCenter: String
  public var lockScreen: String
}

public struct NotificationAuthorizationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var granted: Bool
  public var settings: NotificationSettingsRecord
}

public enum NotificationCollection: String, Codable, CaseIterable, Hashable, Sendable {
  case pending
  case delivered
}

public struct NotificationTriggerRecord: Codable, Equatable, Sendable {
  public var kind: String
  public var repeats: Bool
  public var timeIntervalSeconds: Double?
  public var dateComponents: DateComponents?
  public var nextTriggerAt: Date?
}

public struct NotificationRecord: Codable, Equatable, Sendable {
  public var identifier: String
  public var title: String
  public var body: String
  public var subtitle: String
  public var trigger: NotificationTriggerRecord?
  public var deliveredAt: Date?
}

public struct NotificationSummary: Codable, Equatable, Sendable {
  public var identifier: String
  public var title: String
  public var trigger: NotificationTriggerRecord?
  public var deliveredAt: Date?

  init(_ record: NotificationRecord) {
    identifier = record.identifier
    title = record.title
    trigger = record.trigger
    deliveredAt = record.deliveredAt
  }
}

public struct NotificationListResult: Codable, Equatable, Sendable {
  public var operation: String
  public var notifications: [NotificationSummary]
  public var totalCount: Int
  public var limit: Int
  public var truncated: Bool
}

public struct NotificationReadResult: Codable, Equatable, Sendable {
  public var operation: String
  public var notification: NotificationRecord
}

public struct NotificationRemovalResult: Codable, Equatable, Sendable {
  public var operation: String
  public var identifier: String
  public var attempted: Bool
  public var wasPresent: Bool
  public var verifiedAbsent: Bool
}
