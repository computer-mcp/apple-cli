import ArgumentParser
import Utility

public struct PrintTarget: ParsableCommand {
  public static let targetName = "print"
  public static let targetStatus =
    "Implemented: printer/job inspection plus dry-run previewed submit/cancel paths."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "print",
    abstract: "Printer and job workflows.",
    version: CLIVersion.current,
    subcommands: [Printers.self, Jobs.self, Doctor.self]
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

  public struct Printers: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "printers",
      subcommands: [List.self, Read.self]
    )

    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["printers", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PrintTargetOptions
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["printers", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PrintTargetOptions
      public init() {}
    }
  }

  public struct Jobs: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "jobs",
      subcommands: [List.self, Submit.self, Cancel.self]
    )

    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["jobs", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PrintTargetOptions
      public init() {}
    }

    public struct Submit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "submit")
      public static let positionals = ["jobs", "submit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PrintTargetOptions
      public init() {}
    }

    public struct Cancel: Leaf {
      public static let configuration = CommandConfiguration(commandName: "cancel")
      public static let positionals = ["jobs", "cancel"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PrintTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: PrintTarget.targetName,
        checks: printDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension PrintTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try PrintCommand().run(options: options) else {
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
    var targetOptions: PrintTargetOptions { get }
  }
}

extension PrintTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try PrintTarget.runCommand(options: options)
  }
}

public struct PrintTargetOptions: ParsableArguments, Sendable {
  @Option public var name: String?
  @Option public var printer: String?
  @Option public var file: String?
  @Option public var id: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("name", name),
      ("printer", printer),
      ("file", file),
      ("id", id),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func printDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "lpstat",
      path: "/usr/bin/lpstat",
      presentMessage: "`lpstat` is present for print-system inspection.",
      missingMessage: "`lpstat` was not found at the expected system path."
    ),
    .localPathExists(
      name: "lp",
      path: "/usr/bin/lp",
      presentMessage: "`lp` is present for dry-run previewed print submission.",
      missingMessage: "`lp` was not found at the expected system path."
    ),
    .localPathExists(
      name: "cancel",
      path: "/usr/bin/cancel",
      presentMessage: "`cancel` is present for dry-run previewed print job cancellation.",
      missingMessage: "`cancel` was not found at the expected system path."
    ),
    CLIDoctorCheck(
      name: "print_read_backend",
      status: .ok,
      message: "Printer and print job inspection commands are implemented."
    ),
    CLIDoctorCheck(
      name: "print_action_backend",
      status: .ok,
      message: "Print submit/cancel commands require dry-run results before execution."
    ),
  ]
}
