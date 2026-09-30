import CryptoKit
import Foundation
import Utility

public protocol NotificationDelivering: Sendable {
  func send(_ request: LocalNotificationRequest) throws -> Bool
}
