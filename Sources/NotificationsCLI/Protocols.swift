public protocol NotificationDelivering: Sendable {
  func send(_ request: LocalNotificationRequest) throws -> NotificationSubmission
  func settings() throws -> NotificationSettingsRecord
  func requestAuthorization() throws -> NotificationAuthorizationResult
  func requests(in collection: NotificationCollection) throws -> [NotificationRecord]
  func remove(identifier: String, from collection: NotificationCollection) throws
    -> NotificationRemovalResult
}
