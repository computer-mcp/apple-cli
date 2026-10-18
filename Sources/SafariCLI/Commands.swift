import ArgumentParser
import Utility

public struct SafariTarget: ParsableCommand {
  public static let targetName = "safari"
  public static let targetStatus =
    "Implemented: Safari windows/tabs/page reads plus gated browser state actions, dry-run previewed mutations, and strong-gate SDEF commands."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "safari",
    abstract: "Safari windows, tabs, tab groups, page reads, and safety-gated actions.",
    version: CLIVersion.current,
    subcommands: [
      Window.self, Windows.self, Tab.self, Tabs.self, Profile.self, Pages.self, ReadingList.self,
      Search.self,
      Bookmarks.self,
      Extensions.self, PrivacyReport.self, Internals.self, CreditCardSettings.self, Doctor.self,
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

  public struct Windows: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "windows", subcommands: [List.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["windows", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Window: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "window", subcommands: [List.self, Read.self, Profile.self, Tab.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["window", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["window", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Profile: Leaf {
      public static let configuration = CommandConfiguration(commandName: "profile")
      public static let positionals = ["window", "profile"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Tab: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "tab", subcommands: [List.self])
      public init() {}
      public struct List: Leaf {
        public static let configuration = CommandConfiguration(commandName: "list")
        public static let positionals = ["window", "tab", "list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
    }
  }

  public struct Tabs: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "tabs",
      subcommands: [
        List.self, Current.self, Read.self, Select.self, Open.self, Navigate.self, Close.self,
      ]
    )
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["tabs", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Current: Leaf {
      public static let configuration = CommandConfiguration(commandName: "current")
      public static let positionals = ["tabs", "current"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["tabs", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Select: Leaf {
      public static let configuration = CommandConfiguration(commandName: "select")
      public static let positionals = ["tabs", "select"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["tabs", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Navigate: Leaf {
      public static let configuration = CommandConfiguration(commandName: "navigate")
      public static let positionals = ["tabs", "navigate"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Close: Leaf {
      public static let configuration = CommandConfiguration(commandName: "close")
      public static let positionals = ["tabs", "close"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Tab: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "tab",
      subcommands: [
        List.self, Current.self, Read.self, Select.self, Open.self, Navigate.self, Close.self,
        Group.self,
      ]
    )
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["tab", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Current: Leaf {
      public static let configuration = CommandConfiguration(commandName: "current")
      public static let positionals = ["tab", "current"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["tab", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Select: Leaf {
      public static let configuration = CommandConfiguration(commandName: "select")
      public static let positionals = ["tab", "select"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["tab", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Navigate: Leaf {
      public static let configuration = CommandConfiguration(commandName: "navigate")
      public static let positionals = ["tab", "navigate"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Close: Leaf {
      public static let configuration = CommandConfiguration(commandName: "close")
      public static let positionals = ["tab", "close"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }

    public struct Group: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "group",
        subcommands: [
          Diagnose.self, List.self, Read.self, Open.self, Select.self,
          Create.self, Rename.self, Delete.self, AddTab.self, RemoveTab.self,
        ]
      )
      public init() {}
      public struct Diagnose: Leaf {
        public static let configuration = CommandConfiguration(commandName: "diagnose")
        public static let positionals = ["tab", "group", "diagnose"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct List: Leaf {
        public static let configuration = CommandConfiguration(commandName: "list")
        public static let positionals = ["tab", "group", "list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct Read: Leaf {
        public static let configuration = CommandConfiguration(commandName: "read")
        public static let positionals = ["tab", "group", "read"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct Open: Leaf {
        public static let configuration = CommandConfiguration(commandName: "open")
        public static let positionals = ["tab", "group", "open"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct Select: Leaf {
        public static let configuration = CommandConfiguration(commandName: "select")
        public static let positionals = ["tab", "group", "select"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct Create: Leaf {
        public static let configuration = CommandConfiguration(commandName: "create")
        public static let positionals = ["tab", "group", "create"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct Rename: Leaf {
        public static let configuration = CommandConfiguration(commandName: "rename")
        public static let positionals = ["tab", "group", "rename"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(commandName: "delete")
        public static let positionals = ["tab", "group", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct AddTab: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add-tab")
        public static let positionals = ["tab", "group", "add-tab"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
      public struct RemoveTab: Leaf {
        public static let configuration = CommandConfiguration(commandName: "remove-tab")
        public static let positionals = ["tab", "group", "remove-tab"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
    }
  }

  public struct Profile: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "profile",
      subcommands: [List.self, Read.self]
    )
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["profile", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["profile", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Pages: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "pages",
      subcommands: [Read.self, EmailContents.self, EvaluateJavaScript.self]
    )
    public init() {}
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["pages", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct EmailContents: Leaf {
      public static let configuration = CommandConfiguration(commandName: "email-contents")
      public static let positionals = ["pages", "email-contents"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
    public struct EvaluateJavaScript: Leaf {
      public static let configuration = CommandConfiguration(commandName: "evaluate-javascript")
      public static let positionals = ["pages", "evaluate-javascript"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct ReadingList: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "reading-list", subcommands: [Add.self])
    public init() {}
    public struct Add: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add")
      public static let positionals = ["reading-list", "add"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Search: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "search", subcommands: [Web.self])
    public init() {}
    public struct Web: Leaf {
      public static let configuration = CommandConfiguration(commandName: "web")
      public static let positionals = ["search", "web"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Bookmarks: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "bookmarks", subcommands: [Show.self])
    public init() {}
    public struct Show: Leaf {
      public static let configuration = CommandConfiguration(commandName: "show")
      public static let positionals = ["bookmarks", "show"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Extensions: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "extensions",
      subcommands: [Preferences.self, DispatchMessage.self]
    )
    public init() {}
    public struct Preferences: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "preferences", subcommands: [Show.self])
      public init() {}
      public struct Show: Leaf {
        public static let configuration = CommandConfiguration(commandName: "show")
        public static let positionals = ["extensions", "preferences", "show"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: SafariTargetOptions
        public init() {}
      }
    }
    public struct DispatchMessage: Leaf {
      public static let configuration = CommandConfiguration(commandName: "dispatch-message")
      public static let positionals = ["extensions", "dispatch-message"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct PrivacyReport: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "privacy-report", subcommands: [Show.self])
    public init() {}
    public struct Show: Leaf {
      public static let configuration = CommandConfiguration(commandName: "show")
      public static let positionals = ["privacy-report", "show"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Internals: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "internals", subcommands: [SyncPlist.self])
    public init() {}
    public struct SyncPlist: Leaf {
      public static let configuration = CommandConfiguration(commandName: "sync-plist")
      public static let positionals = ["internals", "sync-plist"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct CreditCardSettings: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "credit-card-settings", subcommands: [Show.self])
    public init() {}
    public struct Show: Leaf {
      public static let configuration = CommandConfiguration(commandName: "show")
      public static let positionals = ["credit-card-settings", "show"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: SafariTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}
    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: SafariTarget.targetName,
        checks: safariDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension SafariTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try SafariCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Command is documented but this target backend is not implemented yet.",
          details: ["target": targetName, "command": options.positionals.joined(separator: " ")]
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
    var targetOptions: SafariTargetOptions { get }
  }
}

extension SafariTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try SafariTarget.runCommand(options: options)
  }
}

public struct SafariTargetOptions: ParsableArguments, Sendable {
  @Option public var id: String?
  @Option public var name: String?
  @Option(name: .customLong("window-index")) public var windowIndex: Int?
  @Option(name: .customLong("window-id")) public var windowID: String?
  @Option(name: .customLong("tab-index")) public var tabIndex: Int?
  @Option(name: .customLong("tab-id")) public var tabID: String?
  @Option(name: .customLong("profile-id")) public var profileID: String?
  @Option public var include: [String] = []
  @Option(name: .customLong("max-bytes")) public var maxBytes: Int?
  @Option public var url: String?
  @Option public var title: String?
  @Option(name: .customLong("preview-text")) public var previewText: String?
  @Option public var query: String?
  @Option public var script: String?
  @Option(name: .customLong("extension-id")) public var extensionID: String?
  @Option(name: .customLong("payload-json")) public var payloadJSON: String?
  @Flag(name: .customLong("allow-javascript")) public var allowJavaScript = false
  @Flag(name: .customLong("allow-email-contents")) public var allowEmailContents = false
  @Flag(name: .customLong("allow-bookmarks")) public var allowBookmarks = false
  @Flag(name: .customLong("allow-hidden-sdef")) public var allowHiddenSDEF = false
  @Flag(name: .customLong("allow-privacy-report")) public var allowPrivacyReport = false
  @Flag(name: .customLong("include-hidden")) public var includeHidden = false
  @Flag(name: .customLong("include-restorable")) public var includeRestorable = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("id", id),
      ("name", name),
      ("window-index", windowIndex.map(String.init)),
      ("window-id", windowID),
      ("tab-index", tabIndex.map(String.init)),
      ("tab-id", tabID),
      ("profile-id", profileID),
      ("include", include.isEmpty ? nil : include.joined(separator: ",")),
      ("max-bytes", maxBytes.map(String.init)),
      ("url", url),
      ("title", title),
      ("preview-text", previewText),
      ("query", query),
      ("script", script),
      ("extension-id", extensionID),
      ("payload-json", payloadJSON),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("allow-javascript", allowJavaScript),
      ("allow-email-contents", allowEmailContents),
      ("allow-bookmarks", allowBookmarks),
      ("allow-hidden-sdef", allowHiddenSDEF),
      ("allow-privacy-report", allowPrivacyReport),
      ("include-hidden", includeHidden),
      ("include-restorable", includeRestorable),
    ])
  }
}

public func safariDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "safari_app",
      path: "/Applications/Safari.app",
      presentMessage: "Safari app bundle is present.",
      missingMessage: "Safari app bundle was not found at /Applications/Safari.app."
    ),
    CLIDoctorCheck(
      name: "safari_backend",
      status: .ok,
      message:
        "Safari windows/tabs/page reads, dry-run previewed mutations, and strong-gate SDEF commands are implemented."
    ),
  ]
}
