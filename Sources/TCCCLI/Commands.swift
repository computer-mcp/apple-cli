import ArgumentParser
import Utility

public struct TCCTarget: ParsableCommand {
  public static let targetName = "tcc"
  public static let targetStatus =
    "Implemented: TCC service catalog, identity diagnostics, read-only database inspection, private dry-run-previewed private database writes, official tccutil reset, public API preflight/request, private TCC.framework probe/write diagnostics, and target-assisted doctor mapping."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "tcc",
    abstract: "TCC privacy service diagnostics and gated TCC mutation workflows.",
    version: CLIVersion.current,
    subcommands: [
      Services.self,
      Identity.self,
      Database.self,
      Records.self,
      Doctor.self,
      Access.self,
      Reset.self,
      Framework.self,
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

  public struct Services: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "services",
      subcommands: [List.self, Read.self]
    )
    public init() {}

    public struct List: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "list")
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(positionals: ["services", "list"])
        )
      }
    }

    public struct Read: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "read")
      @Argument public var service: String
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(positionals: ["services", "read", service])
        )
      }
    }
  }

  public struct Identity: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "identity",
      subcommands: [Read.self, Resolve.self]
    )
    public init() {}

    public struct Read: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "read")
      @Flag(name: .customLong("self")) public var readSelf = false
      @Option public var path: String?
      @Option(name: .customLong("bundle-id")) public var bundleID: String?
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        let targetOptions = CLITargetOptionBuilder.options([
          ("path", path),
          ("bundle-id", bundleID),
        ])
        let targetFlags = CLITargetOptionBuilder.flags([
          ("self", readSelf)
        ])
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetOptions: targetOptions,
            targetFlags: targetFlags,
            positionals: ["identity", "read"]
          )
        )
      }
    }

    public struct Resolve: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "resolve")
      @Option public var client: String
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetOptions: CLITargetOptionBuilder.options([("client", client)]),
            positionals: ["identity", "resolve"]
          )
        )
      }
    }
  }

  public struct Database: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "database",
      subcommands: [Info.self, Digest.self]
    )
    public init() {}

    public struct Info: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "info")
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var databaseOptions: TCCDatabaseReadOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetOptions: databaseOptions.cliTargetOptions,
            positionals: ["database", "info"]
          )
        )
      }
    }

    public struct Digest: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "digest")
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var databaseOptions: TCCDatabaseReadOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetOptions: databaseOptions.cliTargetOptions,
            positionals: ["database", "digest"]
          )
        )
      }
    }
  }

  public struct Records: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "records",
      subcommands: [List.self, Read.self, Add.self, Remove.self, Enable.self, Disable.self]
    )
    public init() {}

    public struct List: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "list")
      @Argument public var service: String?
      @Argument public var client: String?
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var options: TCCRecordReadOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetOptions: options.cliTargetOptions,
            positionals: ["records", "list"] + [service, client].compactMap { $0 }
          )
        )
      }
    }

    public struct Read: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "read")
      @Argument public var service: String
      @Argument public var client: String
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var options: TCCRecordReadOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetOptions: options.cliTargetOptions,
            positionals: ["records", "read", service, client]
          )
        )
      }
    }

    public struct Add: TCCRecordMutationLeaf {
      public static let commandName = "add"
      public static let configuration = CommandConfiguration(commandName: "add")
      @Argument public var service: String
      @Argument public var client: String
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var options: TCCRecordWriteOptions
      public init() {}
    }

    public struct Remove: TCCRecordMutationLeaf {
      public static let commandName = "remove"
      public static let configuration = CommandConfiguration(commandName: "remove")
      @Argument public var service: String
      @Argument public var client: String
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var options: TCCRecordWriteOptions
      public init() {}
    }

    public struct Enable: TCCRecordMutationLeaf {
      public static let commandName = "enable"
      public static let configuration = CommandConfiguration(commandName: "enable")
      @Argument public var service: String
      @Argument public var client: String
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var options: TCCRecordWriteOptions
      public init() {}
    }

    public struct Disable: TCCRecordMutationLeaf {
      public static let commandName = "disable"
      public static let configuration = CommandConfiguration(commandName: "disable")
      @Argument public var service: String
      @Argument public var client: String
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var options: TCCRecordWriteOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @Argument public var service: String?
    @Argument public var client: String?
    @Option(name: .customLong("for-target")) public var forTarget: String?
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var options: TCCRecordReadOptions
    public init() {}

    public mutating func run() throws {
      var targetOptions = options.cliTargetOptions
      if let forTarget {
        targetOptions["for-target"] = forTarget
      }
      try TCCTarget.runCommand(
        options: shared.cliOptions(
          targetOptions: targetOptions,
          positionals: ["doctor"] + [service, client].compactMap { $0 }
        )
      )
    }
  }

  public struct Access: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "access",
      subcommands: [Preflight.self, Request.self]
    )
    public init() {}

    public struct Preflight: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "preflight")
      @Argument public var service: String
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(positionals: ["access", "preflight", service])
        )
      }
    }

    public struct Request: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "request")
      @Argument public var service: String
      @Flag(name: .customLong("allow-tcc-prompt")) public var allowTCCPrompt = false
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(
            targetFlags: CLITargetOptionBuilder.flags([("allow-tcc-prompt", allowTCCPrompt)]),
            positionals: ["access", "request", service]
          )
        )
      }
    }
  }

  public struct Reset: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "reset")
    @Argument public var service: String
    @Argument public var client: String?
    @Flag(name: .customLong("allow-tcc-reset")) public var allowTCCReset = false
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try TCCTarget.runCommand(
        options: shared.cliOptions(
          targetFlags: CLITargetOptionBuilder.flags([("allow-tcc-reset", allowTCCReset)]),
          positionals: ["reset", service] + [client].compactMap { $0 }
        )
      )
    }
  }

  public struct Framework: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "framework",
      subcommands: [Probe.self, Add.self, Reset.self]
    )
    public init() {}

    public struct Probe: ParsableCommand {
      public static let configuration = CommandConfiguration(commandName: "probe")
      @OptionGroup public var shared: CLISharedOptions
      public init() {}

      public mutating func run() throws {
        try TCCTarget.runCommand(
          options: shared.cliOptions(positionals: ["framework", "probe"])
        )
      }
    }

    public struct Add: TCCFrameworkMutationLeaf {
      public static let commandName = "add"
      public static let configuration = CommandConfiguration(commandName: "add")
      @Argument public var service: String
      @Argument public var bundleID: String
      @Flag(name: .customLong("allow-private-tcc-framework-write"))
      public var allowPrivateTCCFrameworkWrite = false
      @Flag(name: .customLong("allow-unknown-tcc-service"))
      public var allowUnknownTCCService = false
      @OptionGroup public var shared: CLISharedOptions
      public init() {}
    }

    public struct Reset: TCCFrameworkMutationLeaf {
      public static let commandName = "reset"
      public static let configuration = CommandConfiguration(commandName: "reset")
      @Argument public var service: String
      @Argument public var bundleID: String
      @Flag(name: .customLong("allow-private-tcc-framework-write"))
      public var allowPrivateTCCFrameworkWrite = false
      @Flag(name: .customLong("allow-unknown-tcc-service"))
      public var allowUnknownTCCService = false
      @OptionGroup public var shared: CLISharedOptions
      public init() {}
    }
  }
}

extension TCCTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try TCCCommand().run(options: options) else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Unsupported TCC command.",
          details: ["command": options.positionals.joined(separator: " ")]
        )
      }
      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(error, target: targetName, json: options.json, pretty: options.pretty)
    } catch {
      try CLICommandOutput.write(
        CLIError(
          code: .internalError,
          message: "Unhandled TCC CLI error.",
          details: ["error": String(describing: error)]
        ),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }
}

public protocol TCCRecordMutationLeaf: ParsableCommand {
  static var commandName: String { get }
  var service: String { get }
  var client: String { get }
  var shared: CLISharedOptions { get }
  var options: TCCRecordWriteOptions { get }
}

extension TCCRecordMutationLeaf {
  public mutating func run() throws {
    try TCCTarget.runCommand(
      options: shared.cliOptions(
        targetOptions: options.cliTargetOptions,
        targetFlags: options.cliTargetFlags,
        positionals: ["records", Self.commandName, service, client]
      )
    )
  }
}

public protocol TCCFrameworkMutationLeaf: ParsableCommand {
  static var commandName: String { get }
  var service: String { get }
  var bundleID: String { get }
  var allowPrivateTCCFrameworkWrite: Bool { get }
  var allowUnknownTCCService: Bool { get }
  var shared: CLISharedOptions { get }
}

extension TCCFrameworkMutationLeaf {
  public mutating func run() throws {
    try TCCTarget.runCommand(
      options: shared.cliOptions(
        targetFlags: CLITargetOptionBuilder.flags([
          ("allow-private-tcc-framework-write", allowPrivateTCCFrameworkWrite),
          ("allow-unknown-tcc-service", allowUnknownTCCService),
        ]),
        positionals: ["framework", Self.commandName, service, bundleID]
      )
    )
  }
}

public struct TCCDatabaseReadOptions: ParsableArguments, Sendable {
  @Option public var scope: String?
  @Option public var database: String?
  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("scope", scope),
      ("database", database),
    ])
  }
}

public struct TCCRecordReadOptions: ParsableArguments, Sendable {
  @Option public var scope: String?
  @Option public var database: String?
  @Option(name: .customLong("client-type")) public var clientType: String?
  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("scope", scope),
      ("database", database),
      ("client-type", clientType),
    ])
  }
}

public struct TCCRecordWriteOptions: ParsableArguments, Sendable {
  @Option public var scope: String?
  @Option public var database: String?
  @Option(name: .customLong("backup-dir")) public var backupDir: String?
  @Option(name: .customLong("client-type")) public var clientType: String?
  @Flag(name: .customLong("allow-private-tcc-db-write"))
  public var allowPrivateTCCDBWrite = false
  @Flag(name: .customLong("allow-unknown-tcc-service"))
  public var allowUnknownTCCService = false
  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("scope", scope),
      ("database", database),
      ("backup-dir", backupDir),
      ("client-type", clientType),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("allow-private-tcc-db-write", allowPrivateTCCDBWrite),
      ("allow-unknown-tcc-service", allowUnknownTCCService),
    ])
  }
}
