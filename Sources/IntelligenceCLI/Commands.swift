import ArgumentParser
import Utility

public struct IntelligenceTarget: ParsableCommand {
  public static let targetName = "intelligence"
  public static let targetStatus =
    "Implemented: Swift-owned Apple Intelligence support/doctor/verify plus risk-flag-gated local-cache enablement, rollback, debug recompute, and service workflows."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "intelligence",
    abstract: "Apple Intelligence local enablement workflows.",
    discussion: """
      Supports the current Swift-owned local-cache path for Apple Intelligence \
      enablement. This implementation operates on local macOS eligibility cache \
      files and eligibilityd state. \
      It does not guarantee Apple service availability, account eligibility, \
      model downloads, or System Settings UI state.

      Start with `apple intelligence doctor --json` for setup diagnostics and \
      `apple intelligence verify --json` for local cache verification.
      System cache writes require root and, on the real system root, SIP disabled.
      Execution commands reject `--dry-run`; use the \
      exact `--allow-*` risk flag shown by the command help.

      See Documentation/Reference/Intelligence/UserGuide.md for the full runbook.
      """,
    version: CLIVersion.current,
    subcommands: [
      Support.self,
      Doctor.self,
      Verify.self,
      Enable.self,
      ResetCache.self,
      Rollback.self,
      Unlock.self,
      Recompute.self,
      Service.self,
    ]
  )

  @OptionGroup public var shared: IntelligenceSharedOptions
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

  public struct Support: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "support",
      abstract: "Show host support hints and starter commands without mutation."
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: [:],
        targetFlags: [],
        positionals: ["intelligence", "support"]
      )
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "doctor",
      abstract: "Inspect host facts, known eligibility files, state, and service status."
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var paths: IntelligencePathOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: paths.cliTargetOptions,
        targetFlags: [],
        positionals: ["intelligence", "doctor"]
      )
    }
  }

  public struct Verify: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "verify",
      abstract: "Verify known local plist/cache values for the modern mainline."
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var paths: IntelligencePathOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: paths.cliTargetOptions,
        targetFlags: [],
        positionals: ["intelligence", "verify"]
      )
    }
  }

  public struct Enable: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "enable",
      abstract: "Patch local eligibility cache values for the modern mainline.",
      discussion: """
        Default patch scope is `comprehensive`. Use `answer` only for the \
        smallest answer-key patch. Use `--eligibility-country US` only when you \
        intentionally want to rewrite the cached eligibility country; pair \
        iPhone Mirroring before changing country.

        Requires `--allow-system-cache-write`. On the real system root, run with \
        sudo/root and disable SIP before writing system eligibility cache files.

        Example:
          sudo apple intelligence enable --allow-system-cache-write --json

        Add `--eligibility-country US` to the same command only when you \
        intentionally want to rewrite the cached eligibility country.
        """
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var options: IntelligenceEnableOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: options.cliTargetOptions,
        targetFlags: options.cliTargetFlags,
        positionals: ["intelligence", "enable"]
      )
    }
  }

  public struct ResetCache: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "reset-cache",
      abstract: "Delete only known eligibility cache files so macOS can rebuild them.",
      discussion: """
        Use this as recovery or cleanup, not as the first enable step. The \
        command deletes only the known eligibility plist cache paths and can \
        optionally kickstart eligibilityd.

        Requires `--allow-cache-reset`.
        """
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var options: IntelligenceResetCacheOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: options.cliTargetOptions,
        targetFlags: options.cliTargetFlags,
        positionals: ["intelligence", "reset-cache"]
      )
    }
  }

  public struct Rollback: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "rollback",
      abstract: "Restore eligibility files from state created by this CLI.",
      discussion: "Requires `--allow-system-cache-write`. Default state is `latest`."
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var options: IntelligenceRollbackOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: options.cliTargetOptions,
        targetFlags: options.cliTargetFlags,
        positionals: ["intelligence", "rollback"]
      )
    }
  }

  public struct Unlock: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "unlock",
      abstract: "Remove file locks/flags from known eligibility cache files.",
      discussion: "Requires `--allow-system-cache-write`."
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var options: IntelligenceUnlockOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: options.cliTargetOptions,
        targetFlags: options.cliTargetFlags,
        positionals: ["intelligence", "unlock"]
      )
    }
  }

  public struct Recompute: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "recompute",
      abstract: "Run a bounded one-shot lldb recompute against eligibilityd.",
      discussion: """
        Use only after plist/cache values look correct but eligibilityd has not \
        refreshed after reboot. This attaches a debugger to eligibilityd.

        Requires `--allow-debug-attach`.
        """
    )
    @OptionGroup public var shared: IntelligenceSharedOptions
    @OptionGroup public var options: IntelligenceRecomputeOptions
    public init() {}
    public mutating func run() throws {
      try IntelligenceTarget.runCommand(
        shared: shared,
        targetOptions: options.cliTargetOptions,
        targetFlags: options.cliTargetFlags,
        positionals: ["intelligence", "recompute"]
      )
    }
  }

  public struct Service: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "service",
      abstract: "Manage the optional Apple Intelligence recompute LaunchDaemon.",
      discussion: """
        The service is not part of the default enable path. Install it only when \
        you need persistent recompute behavior after boot or daemon reload.
        """,
      subcommands: [Install.self, Uninstall.self]
    )
    public init() {}

    public struct Install: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install this CLI's direct recompute LaunchDaemon.",
        discussion: """
          Writes a LaunchDaemon that directly invokes:
          apple intelligence recompute --allow-debug-attach --json

          Requires `--allow-debug-attach` and `--allow-persistent-service`.
          """
      )
      @OptionGroup public var shared: IntelligenceSharedOptions
      @OptionGroup public var options: IntelligenceServiceInstallOptions
      public init() {}
      public mutating func run() throws {
        try IntelligenceTarget.runCommand(
          shared: shared,
          targetOptions: options.cliTargetOptions,
          targetFlags: options.cliTargetFlags,
          positionals: ["intelligence", "service", "install"]
        )
      }
    }

    public struct Uninstall: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Remove this CLI's Apple Intelligence recompute LaunchDaemon.",
        discussion: "Requires `--allow-persistent-service`."
      )
      @OptionGroup public var shared: IntelligenceSharedOptions
      @OptionGroup public var options: IntelligenceServiceUninstallOptions
      public init() {}
      public mutating func run() throws {
        try IntelligenceTarget.runCommand(
          shared: shared,
          targetOptions: options.cliTargetOptions,
          targetFlags: options.cliTargetFlags,
          positionals: ["intelligence", "service", "uninstall"]
        )
      }
    }
  }

}

extension IntelligenceTarget {
  fileprivate static func runCommand(
    shared: IntelligenceSharedOptions,
    targetOptions: [String: String],
    targetFlags: Set<String>,
    positionals: [String]
  ) throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions,
      targetFlags: targetFlags,
      positionals: positionals
    )
    do {
      guard let result = try IntelligenceCommand().run(options: options) else {
        throw intelligenceError(
          code: .backendUnavailable,
          failure: .backendNotImplemented,
          details: ["command": options.positionals.joined(separator: " ")]
        )
      }
      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(
        error,
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    } catch {
      try CLICommandOutput.write(
        intelligenceError(
          code: .internalError,
          failure: .unhandledError,
          details: options.verbose ? CLIError.diagnosticDetails(for: error) : [:]
        ),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }
}

public struct IntelligenceSharedOptions: ParsableArguments, Sendable {
  @Flag(help: "Emit the stable JSON envelope. This never authorizes writes.")
  public var json = false
  @Flag(help: "Pretty-print JSON output for human inspection.")
  public var pretty = false
  @Flag(help: "Emit additional diagnostics to stderr where supported.")
  public var verbose = false
  @Option(help: "Shared output cap for list/search style commands.")
  public var limit: Int?

  public init() {}

  public func cliOptions(
    targetOptions: [String: String],
    targetFlags: Set<String>,
    positionals: [String]
  ) -> CLIOptions {
    CLIOptions(
      json: json,
      pretty: pretty,
      verbose: verbose,
      limit: limit,
      targetOptions: targetOptions,
      targetFlags: targetFlags,
      positionals: positionals
    )
  }
}

public struct IntelligencePathOptions: ParsableArguments, Sendable {
  @Option(help: "Root prefix for system paths. Default: /.")
  public var root: String?
  @Option(
    name: .customLong("state-dir"),
    help: "State and backup directory. Default: <root>/private/var/db/apple-cli/intelligence."
  )
  public var stateDir: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("root", root),
      ("state-dir", stateDir),
    ])
  }
}

public struct IntelligenceEnableOptions: ParsableArguments, Sendable {
  @OptionGroup public var paths: IntelligencePathOptions
  @Option(
    name: .customLong("patch-scope"),
    help: "Patch scope: answer or comprehensive. Default: comprehensive."
  )
  public var patchScope: String?
  @Option(
    name: .customLong("eligibility-country"),
    help: "Optional two-letter cached eligibility country rewrite, for example US."
  )
  public var eligibilityCountry: String?
  @Flag(
    name: .customLong("create-missing"),
    help: "Create missing known plist files under --root before patching."
  )
  public var createMissing = false
  @Flag(name: .customLong("skip-lock"), help: "Skip file unlock/lock helper actions.")
  public var skipLock = false
  @Flag(
    name: .customLong("allow-system-cache-write"),
    help: "Required risk flag for writing macOS eligibility cache files."
  )
  public var allowSystemCacheWrite = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    paths.cliTargetOptions.merging(
      CLITargetOptionBuilder.options([
        ("patch-scope", patchScope),
        ("eligibility-country", eligibilityCountry),
      ]),
      uniquingKeysWith: { _, new in new }
    )
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("create-missing", createMissing),
      ("skip-lock", skipLock),
      ("allow-system-cache-write", allowSystemCacheWrite),
    ])
  }
}

public struct IntelligenceResetCacheOptions: ParsableArguments, Sendable {
  @OptionGroup public var paths: IntelligencePathOptions
  @Flag(help: "Kickstart eligibilityd after deleting known cache files.")
  public var kickstart = false
  @Flag(name: .customLong("skip-lock"), help: "Skip file unlock/lock helper actions.")
  public var skipLock = false
  @Flag(
    name: .customLong("allow-cache-reset"),
    help: "Required risk flag for deleting known eligibility cache files."
  )
  public var allowCacheReset = false

  public init() {}

  public var cliTargetOptions: [String: String] { paths.cliTargetOptions }
  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("kickstart", kickstart),
      ("skip-lock", skipLock),
      ("allow-cache-reset", allowCacheReset),
    ])
  }
}

public struct IntelligenceRollbackOptions: ParsableArguments, Sendable {
  @OptionGroup public var paths: IntelligencePathOptions
  @Option(help: "State id to restore, or latest. Default: latest.")
  public var state: String?
  @Flag(name: .customLong("skip-lock"), help: "Skip file unlock/lock helper actions.")
  public var skipLock = false
  @Flag(
    name: .customLong("allow-system-cache-write"),
    help: "Required risk flag for restoring macOS eligibility cache files."
  )
  public var allowSystemCacheWrite = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    paths.cliTargetOptions.merging(CLITargetOptionBuilder.options([("state", state)])) { _, new in new }
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("skip-lock", skipLock),
      ("allow-system-cache-write", allowSystemCacheWrite),
    ])
  }
}

public struct IntelligenceUnlockOptions: ParsableArguments, Sendable {
  @OptionGroup public var paths: IntelligencePathOptions
  @Flag(
    name: .customLong("allow-system-cache-write"),
    help: "Required risk flag for changing known eligibility file flags."
  )
  public var allowSystemCacheWrite = false

  public init() {}

  public var cliTargetOptions: [String: String] { paths.cliTargetOptions }
  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([("allow-system-cache-write", allowSystemCacheWrite)])
  }
}

public struct IntelligenceRecomputeOptions: ParsableArguments, Sendable {
  @Option(help: "lldb timeout in seconds. Default: 60.")
  public var timeout: Int?
  @Option(name: .customLong("lldb-path"), help: "Explicit lldb executable path.")
  public var lldbPath: String?
  @Flag(name: .customLong("skip-restart"), help: "Skip restart/kickstart helper actions.")
  public var skipRestart = false
  @Flag(
    name: .customLong("allow-debug-attach"),
    help: "Required risk flag for attaching a debugger to eligibilityd."
  )
  public var allowDebugAttach = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("timeout", timeout.map(String.init)),
      ("lldb-path", lldbPath),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("skip-restart", skipRestart),
      ("allow-debug-attach", allowDebugAttach),
    ])
  }
}

public struct IntelligenceServiceInstallOptions: ParsableArguments, Sendable {
  @OptionGroup public var paths: IntelligencePathOptions
  @Option(help: "Recompute timeout in seconds passed to the service. Default: 60.")
  public var timeout: Int?
  @Option(name: .customLong("lldb-path"), help: "Explicit lldb executable path for service recompute.")
  public var lldbPath: String?
  @Flag(help: "Load the LaunchDaemon after writing it.")
  public var load = false
  @Flag(
    name: .customLong("allow-debug-attach"),
    help: "Required risk flag because the service runs debug recompute."
  )
  public var allowDebugAttach = false
  @Flag(
    name: .customLong("allow-persistent-service"),
    help: "Required risk flag for installing a persistent LaunchDaemon."
  )
  public var allowPersistentService = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    paths.cliTargetOptions.merging(
      CLITargetOptionBuilder.options([
        ("timeout", timeout.map(String.init)),
        ("lldb-path", lldbPath),
      ]),
      uniquingKeysWith: { _, new in new }
    )
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("load", load),
      ("allow-debug-attach", allowDebugAttach),
      ("allow-persistent-service", allowPersistentService),
    ])
  }
}

public struct IntelligenceServiceUninstallOptions: ParsableArguments, Sendable {
  @OptionGroup public var paths: IntelligencePathOptions
  @Flag(help: "Unload the LaunchDaemon before removing it.")
  public var unload = false
  @Flag(
    name: .customLong("allow-persistent-service"),
    help: "Required risk flag for removing this CLI's persistent LaunchDaemon."
  )
  public var allowPersistentService = false

  public init() {}

  public var cliTargetOptions: [String: String] { paths.cliTargetOptions }
  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("unload", unload),
      ("allow-persistent-service", allowPersistentService),
    ])
  }
}
