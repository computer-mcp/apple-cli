import ArgumentParser
import Utility

public struct FaceTimeTarget: ParsableCommand {
  public static let targetName = "facetime"
  public static let targetStatus =
    "Implemented: contact resolve, call prepare, and dry-run previewed call start paths."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "facetime",
    abstract: "FaceTime contact resolve and call workflows.",
    version: CLIVersion.current,
    subcommands: [Contacts.self, Calls.self, Doctor.self]
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

  public struct Contacts: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "contacts",
      subcommands: [Resolve.self]
    )
    public init() {}

    public struct Resolve: Leaf {
      public static let configuration = CommandConfiguration(commandName: "resolve")
      public static let positionals = ["contacts", "resolve"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FaceTimeTargetOptions
      public init() {}
    }
  }

  public struct Calls: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "calls",
      subcommands: [Prepare.self, Start.self]
    )
    public init() {}

    public struct Prepare: Leaf {
      public static let configuration = CommandConfiguration(commandName: "prepare")
      public static let positionals = ["calls", "prepare"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FaceTimeTargetOptions
      public init() {}
    }

    public struct Start: Leaf {
      public static let configuration = CommandConfiguration(commandName: "start")
      public static let positionals = ["calls", "start"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FaceTimeTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: FaceTimeTarget.targetName,
        checks: faceTimeDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension FaceTimeTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try FaceTimeCommand().run(options: options) else {
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
    var targetOptions: FaceTimeTargetOptions { get }
  }
}

extension FaceTimeTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try FaceTimeTarget.runCommand(options: options)
  }
}

public struct FaceTimeTargetOptions: ParsableArguments, Sendable {
  @Option public var query: String?
  @Option public var handle: String?
  @Option public var kind: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("query", query),
      ("handle", handle),
      ("kind", kind),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func faceTimeDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "facetime_app",
      path: "/System/Applications/FaceTime.app",
      presentMessage: "FaceTime app bundle is present.",
      missingMessage: "FaceTime app bundle was not found at the expected system path."
    ),
    CLIDoctorCheck(
      name: "facetime_call_backend",
      status: .ok,
      message:
        "FaceTime contact resolve, call prepare, and dry-run previewed call start commands are implemented."
    ),
  ]
}
