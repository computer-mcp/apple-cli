import CryptoKit
import Foundation
import Utility

public struct LocalNotificationRequest: Codable, Equatable, Sendable {
  public var title: String
  public var body: String
  public var subtitle: String?

  public init(title: String, body: String, subtitle: String? = nil) {
    self.title = title
    self.body = body
    self.subtitle = subtitle
  }
}

public struct NotificationPreviewResponse: Codable, Equatable, Sendable {
  public var notification: LocalNotificationRequest
  public var externalAction: Bool
}


public struct NotificationSendResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
}
