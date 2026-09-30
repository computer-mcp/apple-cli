public enum CLIPermissionWording {
  public static func accessGranted(_ service: String) -> String {
    "\(service) access is granted."
  }

  public static func accessNotRequested(_ service: String) -> String {
    "\(service) access has not been requested."
  }

  public static func accessNotGranted(_ service: String, operation: String) -> String {
    "\(service) access was not granted for \(operation)."
  }

  public static func accessDeniedOrRestricted(_ service: String) -> String {
    "\(service) access is denied or restricted."
  }

  public static func accessDeniedOrRestricted(_ service: String, operation: String) -> String {
    "\(service) access is denied or restricted for \(operation)."
  }

  public static func fullAccessRequired(_ service: String, operation: String) -> String {
    "Full \(service) access is required for \(operation); current access is write-only."
  }

  public static func accessStatusUnknown(_ service: String) -> String {
    "\(service) access status is unknown."
  }

  public static func unknownAuthorizationStatus(_ service: String) -> String {
    "\(service) returned an unknown authorization status."
  }

  public static func accessRequestTimedOut(_ service: String) -> String {
    "Timed out while requesting \(service) access."
  }

  public static func accessRequestFailed(_ service: String) -> String {
    "\(service) access request failed."
  }

  public static func fullDiskAccessRequired(resource: String) -> String {
    "\(resource) is not readable. Grant Full Disk Access to the process running `apple`."
  }

  public static func fullDiskAccessRequired(resource: String, operation: String) -> String {
    "\(resource) is not readable. Grant Full Disk Access to the process running `apple` before using \(operation)."
  }

  public static func automationPermissionRequired(target: String) -> String {
    "Grant Automation permission to the process running `apple` for \(target)."
  }

  public static func fileNotReadable(resource: String) -> String {
    "\(resource) is not readable."
  }

  public static func notificationAccessNotProbeable() -> String {
    "Notification access cannot be safely checked from an unbundled SwiftPM CLI process."
  }
}
