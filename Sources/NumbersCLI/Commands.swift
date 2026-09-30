import ArgumentParser
import Utility

public struct NumbersTarget: ParsableCommand {
  public static let targetName = "numbers"
  public static let targetStatus =
    "Implemented: Numbers document list/search/read metadata, sheets list, tables read, table CSV/TSV export, set-cell, open, QuickLook PDF/thumbnail export, and package export paths; broader writes remain gated."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "numbers",
    abstract: "Numbers document, sheet, and table workflows.",
    version: CLIVersion.current,
    subcommands: [Documents.self, Sheets.self, Tables.self, Doctor.self]
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
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["documents", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["documents", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }

    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["documents", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }

    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["documents", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }
  }

  public struct Sheets: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "sheets",
      subcommands: [List.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["sheets", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }
  }

  public struct Tables: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "tables",
      subcommands: [Read.self, Export.self, SetCell.self]
    )
    public init() {}

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["tables", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }

    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["tables", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }

    public struct SetCell: Leaf {
      public static let configuration = CommandConfiguration(commandName: "set-cell")
      public static let positionals = ["tables", "set-cell"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NumbersTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: NumbersTarget.targetName,
        checks: numbersDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension NumbersTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try NumbersCommand().run(options: options) else {
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
        CLIError(
          code: .internalError,
          message: "Unhandled CLI error.",
          details: ["error": String(describing: error)]
        ),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }

  public protocol Leaf: ParsableCommand {
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: NumbersTargetOptions { get }
  }
}

extension NumbersTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try NumbersTarget.runCommand(options: options)
  }
}

public struct NumbersTargetOptions: ParsableArguments, Sendable {
  @Option public var path: String?
  @Option public var query: String?
  @Option public var sheet: String?
  @Option public var table: String?
  @Option public var format: String?
  @Option public var to: String?
  @Option public var row: String?
  @Option public var column: String?
  @Option public var value: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("path", path),
      ("query", query),
      ("sheet", sheet),
      ("table", table),
      ("format", format),
      ("to", to),
      ("row", row),
      ("column", column),
      ("value", value),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func numbersDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "numbers_app",
      path: "/Applications/Numbers.app",
      presentMessage: "Numbers app bundle is present.",
      missingMessage: "Numbers app bundle was not found at the expected application path."
    ),
    CLIDoctorCheck(
      name: "numbers_document_backend",
      status: .ok,
      message:
        "Path-bounded Numbers document metadata, sheet/table read, table CSV/TSV export, single-cell table text write, QuickLook PDF/thumbnail export, and package export commands are implemented."
    ),
  ]
}
