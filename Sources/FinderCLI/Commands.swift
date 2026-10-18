import ArgumentParser
import Utility

public struct FinderTarget: ParsableCommand {
  public static let targetName = "finder"
  public static let targetStatus =
    "Implemented: path-validated Finder item list/search/metadata, dry-run previewed open/reveal, dry-run previewed tag/move/trash/single-file delete, create-only write-text, and single-file overwrite-text paths."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "finder",
    abstract: "Finder-bound item workflows.",
    version: CLIVersion.current,
    subcommands: [Items.self, Doctor.self]
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

  public struct Items: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "items",
      subcommands: [
        List.self, Search.self, Metadata.self, Open.self, Reveal.self, Move.self, Trash.self,
        Delete.self, WriteText.self, OverwriteText.self, Tags.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["items", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["items", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Metadata: Leaf {
      public static let configuration = CommandConfiguration(commandName: "metadata")
      public static let positionals = ["items", "metadata"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["items", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Reveal: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reveal")
      public static let positionals = ["items", "reveal"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Move: Leaf {
      public static let configuration = CommandConfiguration(commandName: "move")
      public static let positionals = ["items", "move"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Trash: Leaf {
      public static let configuration = CommandConfiguration(commandName: "trash")
      public static let positionals = ["items", "trash"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["items", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct WriteText: Leaf {
      public static let configuration = CommandConfiguration(commandName: "write-text")
      public static let positionals = ["items", "write-text"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }
    public struct OverwriteText: Leaf {
      public static let configuration = CommandConfiguration(commandName: "overwrite-text")
      public static let positionals = ["items", "overwrite-text"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: FinderTargetOptions
      public init() {}
    }

    public struct Tags: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "tags",
        subcommands: [Set.self, Add.self, Remove.self, Clear.self]
      )
      public init() {}

      public struct Set: Leaf {
        public static let configuration = CommandConfiguration(commandName: "set")
        public static let positionals = ["items", "tags", "set"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: FinderTargetOptions
        public init() {}
      }
      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add")
        public static let positionals = ["items", "tags", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: FinderTargetOptions
        public init() {}
      }
      public struct Remove: Leaf {
        public static let configuration = CommandConfiguration(commandName: "remove")
        public static let positionals = ["items", "tags", "remove"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: FinderTargetOptions
        public init() {}
      }
      public struct Clear: Leaf {
        public static let configuration = CommandConfiguration(commandName: "clear")
        public static let positionals = ["items", "tags", "clear"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: FinderTargetOptions
        public init() {}
      }
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: FinderTarget.targetName,
        checks: finderDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension FinderTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try FinderCommand().run(options: options) else {
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
    var targetOptions: FinderTargetOptions { get }
  }
}

extension FinderTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try FinderTarget.runCommand(options: options)
  }
}

public struct FinderTargetOptions: ParsableArguments, Sendable {
  @Option public var path: String?
  @Option public var query: String?
  @Option public var to: String?
  @Option public var text: String?
  @Option public var tags: String?
  @Flag(name: .customLong("include-hidden")) public var includeHidden = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("path", path),
      ("query", query),
      ("to", to),
      ("text", text),
      ("tags", tags),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("include-hidden", includeHidden)
    ])
  }
}

public func finderDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "finder_app",
      path: "/System/Library/CoreServices/Finder.app",
      presentMessage: "Finder app bundle is present.",
      missingMessage: "Finder app bundle was not found at the expected system path."
    ),
    CLIDoctorCheck(
      name: "finder_read_backend",
      status: .ok,
      message: "Path-validated Finder item list/search/metadata commands are implemented."
    ),
    CLIDoctorCheck(
      name: "finder_mutation_backend",
      status: .ok,
      message:
        "Finder tag/move/trash/single-file delete plus create-only write-text and single-file overwrite-text commands are dry-run previewed and shell-free."
    ),
  ]
}
