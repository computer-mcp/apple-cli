import ArgumentParser
import Foundation
import Utility

public struct NotificationsTarget: ParsableCommand {
  public static let targetName = "notifications"
  public static let targetStatus =
    "Implemented: notification preview and dry-run previewed local send paths; global history out of scope."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "notifications",
    abstract: "Local notification preview and send workflows.",
    version: CLIVersion.current,
    subcommands: [Preview.self, Send.self, Doctor.self]
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
    @OptionGroup public var targetOptions: NotificationsTargetOptions
    public init() {}
  }

  public struct Send: Leaf {
    public static let configuration = CommandConfiguration(commandName: "send")
    public static let positionals = ["notifications", "send"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotificationsTargetOptions
    public init() {}
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
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: NotificationsTargetOptions { get }
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

public struct NotificationsTargetOptions: ParsableArguments, Sendable {
  @Option public var title: String?
  @Option public var body: String?
  @Option public var subtitle: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("title", title),
      ("body", body),
      ("subtitle", subtitle),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
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
      status: .warning,
      message:
        "Notification send uses a target-local legacy CLI delivery backend because UserNotifications is unsafe from an unbundled SwiftPM process."
    ),
  ]
}

public func notificationAuthorizationCheck() -> CLIDoctorCheck {
  CLIDoctorCheck(
    name: "notification_authorization",
    status: .notChecked,
    message: CLIPermissionWording.notificationAccessNotProbeable(),
    details: [
      "bundle_url": Bundle.main.bundleURL.path,
      "bundle_identifier": Bundle.main.bundleIdentifier ?? "",
    ]
  )
}
