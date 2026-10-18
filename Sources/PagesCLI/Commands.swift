import ArgumentParser
import Utility

public struct PagesTarget: ParsableCommand {
  public static let targetName = "pages"
  public static let targetStatus =
    "Implemented: Pages document list/search/read metadata, open, QuickLook PDF/thumbnail export, and package export paths; writes remain gated."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "pages",
    abstract: "Pages document workflows.",
    version: CLIVersion.current,
    subcommands: [Documents.self, Doctor.self]
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

  public struct Documents: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "documents",
      subcommands: [List.self, Search.self, Read.self, Open.self, Export.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["documents", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PagesTargetOptions
      public init() {}
    }

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["documents", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PagesTargetOptions
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["documents", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PagesTargetOptions
      public init() {}
    }

    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["documents", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PagesTargetOptions
      public init() {}
    }

    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["documents", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PagesTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: PagesTarget.targetName,
        checks: pagesDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension PagesTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try PagesCommand().run(options: options) else {
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
    var targetOptions: PagesTargetOptions { get }
  }
}

extension PagesTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try PagesTarget.runCommand(options: options)
  }
}

public struct PagesTargetOptions: ParsableArguments, Sendable {
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

public func pagesDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "pages_app",
      path: "/Applications/Pages.app",
      presentMessage: "Pages app bundle is present.",
      missingMessage: "Pages app bundle was not found at the expected application path."
    ),
    CLIDoctorCheck(
      name: "pages_document_backend",
      status: .ok,
      message:
        "Path-bounded Pages document metadata, QuickLook PDF/thumbnail export, and package export commands are implemented."
    ),
  ]
}
