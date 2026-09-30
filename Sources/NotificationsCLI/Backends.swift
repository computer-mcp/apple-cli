import CryptoKit
import Foundation
import Utility

public struct LegacyNSUserNotificationBackend: NotificationDelivering {
  public init() {}

  @available(macOS, deprecated: 11.0)
  public func send(_ request: LocalNotificationRequest) throws -> Bool {
    let notification = NSUserNotification()
    notification.title = request.title
    notification.subtitle = request.subtitle
    notification.informativeText = request.body
    NSUserNotificationCenter.default.deliver(notification)
    return true
  }
}
