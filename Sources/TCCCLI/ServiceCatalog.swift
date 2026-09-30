import Foundation
import Utility

public enum TCCServiceCatalog {
  public static let rawPrefix = "kTCCService"

  public static let services: [TCCServiceInfo] = [
    TCCServiceInfo(
      suffix: "All",
      aliases: ["all"],
      publicAPIRoute: "/usr/bin/tccutil reset All only; not a database row service"
    ),
    TCCServiceInfo(
      suffix: "Accessibility",
      aliases: ["accessibility", "ax"],
      relatedTargets: ["finder", "messages"],
      publicAPIRoute: "ApplicationServices.AXIsProcessTrustedWithOptions"
    ),
    TCCServiceInfo(
      suffix: "AddressBook",
      aliases: ["addressbook", "contacts", "contacts-legacy"],
      relatedTargets: ["contacts"],
      publicAPIRoute: "Contacts.CNContactStore.authorizationStatus"
    ),
    TCCServiceInfo(
      suffix: "AppleEvents",
      aliases: ["appleevents", "automation", "apple-events"],
      relatedTargets: [
        "safari", "messages", "notes", "mail", "numbers", "pages", "keynote", "finder",
        "facetime", "maps",
      ],
      publicAPIRoute: "CoreServices.AEDeterminePermissionToAutomateTarget"
    ),
    TCCServiceInfo(
      suffix: "Calendar",
      aliases: ["calendar", "calendars"],
      relatedTargets: ["calendar"],
      publicAPIRoute: "EventKit.EKEventStore.requestFullAccessToEvents"
    ),
    TCCServiceInfo(
      suffix: "Camera",
      aliases: ["camera"],
      relatedTargets: ["facetime"],
      publicAPIRoute: "AVFoundation.AVCaptureDevice.requestAccess(for: .video)"
    ),
    TCCServiceInfo(
      suffix: "ContactsFull",
      aliases: ["contactsfull", "contacts-full"],
      relatedTargets: ["contacts"],
      publicAPIRoute: "Contacts.CNContactStore.requestAccess"
    ),
    TCCServiceInfo(
      suffix: "ContactsLimited",
      aliases: ["contactslimited", "contacts-limited"],
      relatedTargets: ["contacts"],
      publicAPIRoute: "Contacts.CNContactStore limited access APIs"
    ),
    TCCServiceInfo(
      suffix: "DeveloperTool",
      aliases: ["developertool", "developer-tool", "developer"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Facebook",
      aliases: ["facebook"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "LinkedIn",
      aliases: ["linkedin"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "ListenEvent",
      aliases: ["listenevent", "listen-event", "input-monitoring", "inputmonitoring"],
      publicAPIRoute: "IOKit.hidsystem.IOHIDCheckAccess/IOHIDRequestAccess"
    ),
    TCCServiceInfo(
      suffix: "Liverpool",
      aliases: ["liverpool"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Location",
      aliases: ["location", "location-services"],
      relatedTargets: ["maps"],
      publicAPIRoute: "CoreLocation authorization APIs"
    ),
    TCCServiceInfo(
      suffix: "MediaLibrary",
      aliases: ["medialibrary", "media-library"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Microphone",
      aliases: ["microphone", "mic"],
      relatedTargets: ["facetime"],
      publicAPIRoute: "AVFoundation.AVCaptureDevice.requestAccess(for: .audio)"
    ),
    TCCServiceInfo(
      suffix: "Motion",
      aliases: ["motion"],
      publicAPIRoute: "CoreMotion authorization APIs"
    ),
    TCCServiceInfo(
      suffix: "Photos",
      aliases: ["photos", "photos-read-write"],
      relatedTargets: ["photos"],
      publicAPIRoute: "Photos.PHPhotoLibrary.requestAuthorization"
    ),
    TCCServiceInfo(
      suffix: "PhotosAdd",
      aliases: ["photosadd", "photos-add", "add-photos"],
      relatedTargets: ["photos"],
      publicAPIRoute: "Photos.PHPhotoLibrary.requestAuthorization(for: .addOnly)"
    ),
    TCCServiceInfo(
      suffix: "PostEvent",
      aliases: ["postevent", "post-event"],
      publicAPIRoute: "IOKit.hidsystem.IOHIDRequestAccess post-event route"
    ),
    TCCServiceInfo(
      suffix: "Reminders",
      aliases: ["reminders", "reminder"],
      relatedTargets: ["reminders"],
      publicAPIRoute: "EventKit.EKEventStore.requestFullAccessToReminders"
    ),
    TCCServiceInfo(
      suffix: "ScreenCapture",
      aliases: ["screencapture", "screen-capture", "screen-recording", "screenrecording"],
      publicAPIRoute: "CoreGraphics.CGPreflightScreenCaptureAccess/CGRequestScreenCaptureAccess"
    ),
    TCCServiceInfo(
      suffix: "ShareKit",
      aliases: ["sharekit", "share-kit"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "SinaWeibo",
      aliases: ["sinaweibo", "sina-weibo"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Siri",
      aliases: ["siri"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "SpeechRecognition",
      aliases: ["speechrecognition", "speech-recognition", "speech"],
      publicAPIRoute: "Speech.SFSpeechRecognizer.requestAuthorization"
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyAllFiles",
      aliases: ["systempolicyallfiles", "system-policy-all-files", "full-disk-access", "fda"],
      relatedTargets: ["notes", "mail", "messages", "safari"],
      publicAPIRoute: "No public grant API; System Settings user approval only"
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyDesktopFolder",
      aliases: ["systempolicydesktopfolder", "desktop-folder", "desktop"],
      publicAPIRoute: "No public grant API; scoped file access can avoid TCC"
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyDeveloperFiles",
      aliases: ["systempolicydeveloperfiles", "developer-files"],
      relatedTargets: ["intelligence"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyDocumentsFolder",
      aliases: ["systempolicydocumentsfolder", "documents-folder", "documents"],
      publicAPIRoute: "No public grant API; scoped file access can avoid TCC"
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyDownloadsFolder",
      aliases: ["systempolicydownloadsfolder", "downloads-folder", "downloads"],
      publicAPIRoute: "No public grant API; scoped file access can avoid TCC"
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyNetworkVolumes",
      aliases: ["systempolicynetworkvolumes", "network-volumes"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "SystemPolicyRemovableVolumes",
      aliases: ["systempolicyremovablevolumes", "removable-volumes"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "SystemPolicySysAdminFiles",
      aliases: ["systempolicysysadminfiles", "sysadmin-files", "admin-files"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "TencentWeibo",
      aliases: ["tencentweibo", "tencent-weibo"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Twitter",
      aliases: ["twitter"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Ubiquity",
      aliases: ["ubiquity", "icloud-documents"],
      publicAPIRoute: nil
    ),
    TCCServiceInfo(
      suffix: "Willow",
      aliases: ["willow"],
      publicAPIRoute: nil
    ),
  ]

  public static func resolve(
    _ input: String,
    allowUnknownRawService: Bool = true,
    writeOperation: Bool = false
  ) throws -> TCCServiceInfo {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw CLIError(code: .validationError, message: "TCC service must not be empty.")
    }

    if let match = services.first(where: { $0.rawName == trimmed || $0.suffix == trimmed }) {
      return match
    }

    let key = normalizedKey(trimmed)
    if let match = services.first(where: { service in
      normalizedKey(service.suffix) == key
        || normalizedKey(service.rawName) == key
        || service.aliases.contains(where: { normalizedKey($0) == key })
    }) {
      return match
    }

    if trimmed.hasPrefix(rawPrefix) {
      if writeOperation && !allowUnknownRawService {
        throw CLIError(
          code: .unsafeMutationRefused,
          message: TCCWording.unknownRawServiceWriteRequiresAllowFlag(),
          details: ["service": trimmed]
        )
      }
      return TCCServiceInfo(
        suffix: String(trimmed.dropFirst(rawPrefix.count)),
        rawName: trimmed,
        aliases: [],
        relatedTargets: [],
        publicAPIRoute: nil,
        canonical: false
      )
    }

    throw CLIError(
      code: .validationError,
      message: "Unknown TCC service. Use a known suffix, alias, or raw kTCCService... name.",
      details: ["service": trimmed]
    )
  }

  public static func client(from input: String, explicitType: String? = nil) throws -> TCCClientInfo {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw CLIError(code: .validationError, message: "TCC client must not be empty.")
    }

    let kind: TCCClientKind
    if let explicitType {
      switch normalizedKey(explicitType) {
      case "bundleid", "bundleidentifier", "bundle":
        kind = .bundleIdentifier
      case "path", "absolutepath", "absolute":
        kind = .absolutePath
      default:
        throw CLIError(
          code: .validationError,
          message: "`--client-type` must be `bundle-id` or `path`.",
          details: ["client_type": explicitType]
        )
      }
    } else if trimmed.hasPrefix("/") {
      kind = .absolutePath
    } else {
      kind = .bundleIdentifier
    }

    if kind == .absolutePath, !trimmed.hasPrefix("/") {
      throw CLIError(
        code: .validationError,
        message: "Path TCC clients must be absolute paths.",
        details: ["client": trimmed]
      )
    }

    return TCCClientInfo(input: trimmed, kind: kind)
  }

  public static func rawNameForTccutil(_ service: TCCServiceInfo) -> String {
    service.suffix
  }

  public static func services(forTarget target: String) -> TCCDoctorTargetMapping? {
    let normalized = normalizedKey(target)
    let mapping: [String: TCCDoctorTargetMapping] = [
      "reminders": TCCDoctorTargetMapping(
        target: "reminders",
        services: ["Reminders"],
        publicAPIRoutes: ["EventKit full reminder access"],
        notes: ["The granted subject is the process using EventKit."]
      ),
      "calendar": TCCDoctorTargetMapping(
        target: "calendar",
        services: ["Calendar"],
        publicAPIRoutes: ["EventKit full calendar access"],
        notes: ["Calendar and Reminders are separate TCC services."]
      ),
      "contacts": TCCDoctorTargetMapping(
        target: "contacts",
        services: ["AddressBook", "ContactsFull", "ContactsLimited"],
        publicAPIRoutes: ["Contacts framework authorization"],
        notes: ["Modern systems may record full or limited Contacts access."]
      ),
      "photos": TCCDoctorTargetMapping(
        target: "photos",
        services: ["Photos", "PhotosAdd"],
        publicAPIRoutes: ["Photos framework authorization"],
        notes: ["Read/write and add-only Photos grants are distinct."]
      ),
      "safari": TCCDoctorTargetMapping(
        target: "safari",
        services: ["AppleEvents", "SystemPolicyAllFiles"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Apple Events grants are target-app specific; Safari data files may also need FDA."]
      ),
      "messages": TCCDoctorTargetMapping(
        target: "messages",
        services: ["AppleEvents", "Accessibility", "SystemPolicyAllFiles"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Messages automation and local database reads can fail under different identities."]
      ),
      "notes": TCCDoctorTargetMapping(
        target: "notes",
        services: ["AppleEvents", "SystemPolicyAllFiles"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Notes automation and local store access are separate permission paths."]
      ),
      "mail": TCCDoctorTargetMapping(
        target: "mail",
        services: ["AppleEvents", "SystemPolicyAllFiles"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Mail automation grants are per controlling client."]
      ),
      "numbers": TCCDoctorTargetMapping(
        target: "numbers",
        services: ["AppleEvents"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Numbers scripting depends on Automation permission for the controlling identity."]
      ),
      "pages": TCCDoctorTargetMapping(
        target: "pages",
        services: ["AppleEvents"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Pages scripting depends on Automation permission for the controlling identity."]
      ),
      "keynote": TCCDoctorTargetMapping(
        target: "keynote",
        services: ["AppleEvents"],
        publicAPIRoutes: ["Apple Events automation preflight"],
        notes: ["Keynote scripting depends on Automation permission for the controlling identity."]
      ),
      "notifications": TCCDoctorTargetMapping(
        target: "notifications",
        services: [],
        publicAPIRoutes: ["UserNotifications authorization APIs"],
        notes: ["Notifications authorization is not an access-table TCC service."]
      ),
      "clipboard": TCCDoctorTargetMapping(
        target: "clipboard",
        services: [],
        publicAPIRoutes: ["Pasteboard APIs; user prompts are OS-version dependent"],
        notes: ["Clipboard reads are sensitive but are not modeled as a stable TCC access row."]
      ),
      "print": TCCDoctorTargetMapping(
        target: "print",
        services: ["AppleEvents"],
        publicAPIRoutes: ["Print/PM APIs and app-specific Apple Events where used"],
        notes: ["Printer enumeration is not a TCC service; scripted app print flows can be."]
      ),
      "finder": TCCDoctorTargetMapping(
        target: "finder",
        services: ["AppleEvents", "Accessibility", "SystemPolicyAllFiles"],
        publicAPIRoutes: ["Apple Events automation preflight", "Accessibility preflight"],
        notes: ["Finder automation and UI scripting are separate permission services."]
      ),
      "facetime": TCCDoctorTargetMapping(
        target: "facetime",
        services: ["Camera", "Microphone", "AppleEvents"],
        publicAPIRoutes: ["AVFoundation camera/microphone authorization"],
        notes: ["Camera and microphone grants attach to the calling process."]
      ),
      "maps": TCCDoctorTargetMapping(
        target: "maps",
        services: ["Location", "AppleEvents"],
        publicAPIRoutes: ["CoreLocation authorization", "Apple Events automation preflight"],
        notes: ["Map automation and location access are separate capabilities."]
      ),
      "intelligence": TCCDoctorTargetMapping(
        target: "intelligence",
        services: ["SystemPolicyDeveloperFiles", "SystemPolicyAllFiles"],
        publicAPIRoutes: ["No public grant API for Full Disk Access"],
        notes: ["Apple Intelligence eligibility cache inspection can hit protected system or developer-file locations."]
      ),
    ]
    return mapping[normalized]
  }

  private static func normalizedKey(_ value: String) -> String {
    value
      .lowercased()
      .filter { $0.isLetter || $0.isNumber }
  }
}
