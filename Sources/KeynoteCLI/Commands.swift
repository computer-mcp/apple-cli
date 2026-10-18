import ArgumentParser
import Utility

public struct KeynoteTarget: ParsableCommand {
  public static let targetName = "keynote"
  public static let targetStatus =
    "Implemented: Keynote file/package metadata, native slide text/order/skipped/presenter notes, native PDF export, cached preview list/export, presentation open, and package copy; rich content and presentation writes remain gated."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "keynote",
    abstract: "Keynote presentation and slide workflows.",
    version: CLIVersion.current,
    subcommands: [Presentations.self, Slides.self, Previews.self, Doctor.self]
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

  public struct Presentations: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "presentations",
      subcommands: [List.self, Search.self, Read.self, Open.self, Export.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["presentations", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["presentations", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["presentations", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }

    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["presentations", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }

    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["presentations", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }
  }

  public struct Slides: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "slides",
      subcommands: [List.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["slides", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }
  }

  public struct Previews: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "previews",
      abstract: "Inspect or copy cached QuickLook image previews.",
      subcommands: [List.self, Export.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["previews", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }

    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["previews", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: KeynoteTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: KeynoteTarget.targetName,
        checks: keynoteDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension KeynoteTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try KeynoteCommand().run(options: options) else {
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
    var targetOptions: KeynoteTargetOptions { get }
  }
}

extension KeynoteTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try KeynoteTarget.runCommand(options: options)
  }
}

public struct KeynoteTargetOptions: ParsableArguments, Sendable {
  @Option public var path: String?
  @Option public var query: String?
  @Option public var format: String?
  @Option public var to: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("path", path),
      ("query", query),
      ("format", format),
      ("to", to),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func keynoteDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "keynote_app",
      path: "/Applications/Keynote.app",
      presentMessage: "Keynote app bundle is present.",
      missingMessage: "Keynote app bundle was not found at the expected application path."
    ),
    CLIDoctorCheck(
      name: "keynote_presentation_backend",
      status: .ok,
      message:
        "Path-bounded presentation metadata and cached previews are available; native slide reads and PDF export require Keynote Automation permission."
    ),
  ]
}
