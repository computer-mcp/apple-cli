import ArgumentParser
import Utility

public struct MapsTarget: ParsableCommand {
  public static let targetName = "maps"
  public static let targetStatus =
    "Implemented: places search/read, coordinate-aware directions preview, and dry-run previewed Maps open paths."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "maps",
    abstract: "Places, directions previews, and Maps open actions.",
    version: CLIVersion.current,
    subcommands: [Places.self, Directions.self, Open.self, Doctor.self]
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

  public struct Places: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "places",
      subcommands: [Search.self, Read.self]
    )
    public init() {}

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["places", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsTargetOptions
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["places", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsTargetOptions
      public init() {}
    }
  }

  public struct Directions: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "directions",
      subcommands: [Preview.self]
    )
    public init() {}

    public struct Preview: Leaf {
      public static let configuration = CommandConfiguration(commandName: "preview")
      public static let positionals = ["directions", "preview"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsTargetOptions
      public init() {}
    }
  }

  public struct Open: Leaf {
    public static let configuration = CommandConfiguration(commandName: "open")
    public static let positionals = ["maps", "open"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MapsTargetOptions
    public init() {}
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: MapsTarget.targetName,
        checks: mapsDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension MapsTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try MapsCommand().run(options: options) else {
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
    var targetOptions: MapsTargetOptions { get }
  }
}

extension MapsTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try MapsTarget.runCommand(options: options)
  }
}

public struct MapsTargetOptions: ParsableArguments, Sendable {
  @Option public var query: String?
  @Option public var latitude: String?
  @Option public var longitude: String?
  @Option public var name: String?
  @Option public var from: String?
  @Option(name: .customLong("from-latitude")) public var fromLatitude: String?
  @Option(name: .customLong("from-longitude")) public var fromLongitude: String?
  @Option(name: .customLong("from-name")) public var fromName: String?
  @Option public var to: String?
  @Option(name: .customLong("to-latitude")) public var toLatitude: String?
  @Option(name: .customLong("to-longitude")) public var toLongitude: String?
  @Option(name: .customLong("to-name")) public var toName: String?
  @Option public var mode: String?
  @Option public var url: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("query", query),
      ("latitude", latitude),
      ("longitude", longitude),
      ("name", name),
      ("from", from),
      ("from-latitude", fromLatitude),
      ("from-longitude", fromLongitude),
      ("from-name", fromName),
      ("to", to),
      ("to-latitude", toLatitude),
      ("to-longitude", toLongitude),
      ("to-name", toName),
      ("mode", mode),
      ("url", url),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func mapsDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "maps_app",
      path: "/System/Applications/Maps.app",
      presentMessage: "Maps app bundle is present.",
      missingMessage: "Maps app bundle was not found at the expected system path."
    ),
    CLIDoctorCheck(
      name: "maps_backend",
      status: .ok,
      message:
        "Maps places search/read, coordinate-aware directions preview, and dry-run previewed open commands are implemented."
    ),
  ]
}
