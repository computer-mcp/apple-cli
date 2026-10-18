import ArgumentParser
import Foundation
import Utility

public struct NotificationsTarget: ParsableCommand {
  public static let targetName = "notifications"
  public static let targetStatus =
    "Implemented: notification preview, authorization, submission and scoped pending/delivered management."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "notifications",
    abstract: "Submit and manage Apple CLI's local notifications.",
    version: CLIVersion.current,
    subcommands: [
      Preview.self, Send.self, Settings.self, Permissions.self, Pending.self, Delivered.self,
      Doctor.self,
    ]
  )

  @OptionGroup public var shared: CLISharedOptions
  public init() {}

  public mutating func run() throws {
    try CLICommandOutput.writeStatus(
      target: Self.targetName,
      status: Self.targetStatus,
      implemented: Self.isImplemented,
      json: shared.json,
      pretty: shared.pretty
    )
  }

  public struct Preview: Leaf {
    public static let configuration = CommandConfiguration(commandName: "preview")
    public static let positionals = ["notifications", "preview"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotificationContentOptions
    public init() {}
  }

  public struct Send: Leaf {
    public static let configuration = CommandConfiguration(commandName: "send")
    public static let positionals = ["notifications", "send"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotificationContentOptions
    public init() {}
  }

  public struct Settings: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "settings", abstract: "Read Apple CLI notification authorization and settings.")
    public static let positionals = ["notifications", "settings"]
    @OptionGroup public var shared: CLISharedOptions
    public var targetOptions: NotificationNoOptions { .init() }
    public init() {}
  }

  public struct Permissions: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "permissions", subcommands: [Request.self])
    public init() {}

    public struct Request: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "request", abstract: "Explicitly ask for notification authorization.")
      public static let positionals = ["notifications", "permissions", "request"]
      @OptionGroup public var shared: CLISharedOptions
      public var targetOptions: NotificationNoOptions { .init() }
      public init() {}
    }
  }

  public struct Pending: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "pending", abstract: "Manage Apple CLI requests waiting for their trigger.",
      subcommands: [List.self, Read.self, Cancel.self])
    public init() {}

    public struct List: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["notifications", "pending", "list"]
      @OptionGroup public var shared: CLISharedOptions
      public var targetOptions: NotificationNoOptions { .init() }
      public init() {}
    }

    public struct Read: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["notifications", "pending", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotificationIdentifierOptions
      public init() {}
    }

    public struct Cancel: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "cancel", abstract: "Remove one pending request and verify its absence.")
      public static let positionals = ["notifications", "pending", "cancel"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotificationIdentifierOptions
      public init() {}
    }
  }

  public struct Delivered: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "delivered", abstract: "Manage Apple CLI entries still in Notification Center.",
      subcommands: [List.self, Read.self, Remove.self])
    public init() {}

    public struct List: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["notifications", "delivered", "list"]
      @OptionGroup public var shared: CLISharedOptions
      public var targetOptions: NotificationNoOptions { .init() }
      public init() {}
    }

    public struct Read: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["notifications", "delivered", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotificationIdentifierOptions
      public init() {}
    }

    public struct Remove: NotificationsTarget.Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove one Notification Center entry and verify its absence.")
      public static let positionals = ["notifications", "delivered", "remove"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotificationIdentifierOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: NotificationsTarget.targetName,
        checks: notificationsDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension NotificationsTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try NotificationsCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Command is documented but this target backend is not implemented yet.",
          details: [
            "target": targetName,
            "command": options.positionals.joined(separator: " "),
          ]
        )
      }

      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(
        error, target: targetName, json: options.json, pretty: options.pretty)
    } catch {
      try CLICommandOutput.write(
        CLIError.unexpected(error, verbose: options.verbose),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }

  public protocol Leaf: ParsableCommand {
    associatedtype TargetOptions: NotificationCommandOptions
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: TargetOptions { get }
  }
}

extension NotificationsTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try NotificationsTarget.runCommand(options: options)
  }
}

public protocol NotificationCommandOptions: ParsableArguments {
  var cliTargetOptions: [String: String] { get }
  var cliTargetFlags: Set<String> { get }
}

extension NotificationCommandOptions {
  public var cliTargetFlags: Set<String> { [] }
}

public struct NotificationNoOptions: NotificationCommandOptions {
  public init() {}
  public var cliTargetOptions: [String: String] { [:] }
}

public struct NotificationContentOptions: NotificationCommandOptions, Sendable {
  @Option public var title: String
  @Option public var body: String
  @Option public var subtitle: String?
  @Option(help: "Stable request ID; apple-cli: is added when omitted from the ID.")
  public var id: String?
  @Option(
    name: .customLong("delay-seconds"),
    help: "One-time delay from 1 to 604800 seconds; default immediate.")
  public var delaySeconds: Int?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("title", title),
      ("body", body),
      ("subtitle", subtitle),
      ("id", id),
      ("delay-seconds", delaySeconds.map(String.init)),
    ])
  }

}

public struct NotificationIdentifierOptions: NotificationCommandOptions, Sendable {
  @Option(help: "Exact request ID; apple-cli: is added when omitted from the ID.")
  public var id: String
  public init() {}
  public var cliTargetOptions: [String: String] { ["id": id] }
}

public func notificationsDoctorChecks() -> [CLIDoctorCheck] {
  [
    notificationAuthorizationCheck(),
    CLIDoctorCheck(
      name: "notification_preview_backend",
      status: .ok,
      message: "Notification preview command is implemented."
    ),
    CLIDoctorCheck(
      name: "notification_send_backend",
      status: .ok,
      message:
        "UserNotifications settings and callback-confirmed submission use Apple CLI's embedded identity."
    ),
  ]
}

public func notificationAuthorizationCheck() -> CLIDoctorCheck {
  do {
    let settings = try UserNotificationsBackend().settings()
    return CLIDoctorCheck(
      name: "notification_authorization",
      status: settings.canSchedule
        ? .ok : settings.authorizationStatus == "denied" ? .permissionDenied : .warning,
      message: "Apple CLI notification authorization: \(settings.authorizationStatus).",
      details: [
        "bundle_identifier": settings.bundleIdentifier,
        "authorization_status": settings.authorizationStatus,
        "alert": settings.alert,
        "notification_center": settings.notificationCenter,
      ])
  } catch let error as CLIError {
    return CLIDoctorCheck(
      name: "notification_authorization", status: .notChecked,
      message: error.message, details: error.details)
  } catch {
    return CLIDoctorCheck(
      name: "notification_authorization", status: .notChecked,
      message: "Notification settings are unavailable.")
  }
}
