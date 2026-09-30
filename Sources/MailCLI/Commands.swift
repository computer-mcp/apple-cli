import ArgumentParser
import Utility

public struct MailTarget: ParsableCommand {
  public static let targetName = "mail"
  public static let targetStatus =
    "Implemented: Mail.app accounts/mailboxes/list/unread/search/read metadata, bounded body search, explicit bounded body preview, metadata-only reply/forward preview, and dry-run previewed draft/reply-draft/forward-draft/send/move/archive/delete paths."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "mail",
    abstract: "Mail accounts, mailboxes, message reads, previews, and dry-run writes.",
    version: CLIVersion.current,
    subcommands: [Accounts.self, Mailboxes.self, Messages.self, Doctor.self]
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

  public struct Accounts: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "accounts",
      subcommands: [List.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["accounts", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
  }

  public struct Mailboxes: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "mailboxes",
      subcommands: [List.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["mailboxes", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
  }

  public struct Messages: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "messages",
      subcommands: [
        List.self, Unread.self, Search.self, Read.self, BodyPreview.self, ReplyPreview.self,
        ForwardPreview.self, ReplyDraft.self, ForwardDraft.self, Draft.self, Send.self, Move.self,
        Archive.self, Delete.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["mail", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Unread: Leaf {
      public static let configuration = CommandConfiguration(commandName: "unread")
      public static let positionals = ["mail", "unread"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["mail", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["mail", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct BodyPreview: Leaf {
      public static let configuration = CommandConfiguration(commandName: "body-preview")
      public static let positionals = ["mail", "body-preview"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct ReplyPreview: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reply-preview")
      public static let positionals = ["mail", "reply-preview"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct ForwardPreview: Leaf {
      public static let configuration = CommandConfiguration(commandName: "forward-preview")
      public static let positionals = ["mail", "forward-preview"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct ReplyDraft: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reply-draft")
      public static let positionals = ["mail", "reply-draft"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct ForwardDraft: Leaf {
      public static let configuration = CommandConfiguration(commandName: "forward-draft")
      public static let positionals = ["mail", "forward-draft"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Draft: Leaf {
      public static let configuration = CommandConfiguration(commandName: "draft")
      public static let positionals = ["mail", "draft"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Send: Leaf {
      public static let configuration = CommandConfiguration(commandName: "send")
      public static let positionals = ["mail", "send"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Move: Leaf {
      public static let configuration = CommandConfiguration(commandName: "move")
      public static let positionals = ["mail", "move"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Archive: Leaf {
      public static let configuration = CommandConfiguration(commandName: "archive")
      public static let positionals = ["mail", "archive"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["mail", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MailTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: MailTarget.targetName,
        checks: mailDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension MailTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try MailCommand().run(options: options) else {
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
    var targetOptions: MailTargetOptions { get }
  }
}

extension MailTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try MailTarget.runCommand(options: options)
  }
}

public struct MailTargetOptions: ParsableArguments, Sendable {
  @Option public var account: String?
  @Option public var mailbox: String?
  @Option public var query: String?
  @Option public var scope: String?
  @Option(name: .customLong("max-scan")) public var maxScan: String?
  @Option public var id: String?
  @Option(name: .customLong("max-bytes")) public var maxBytes: String?
  @Option public var body: String?
  @Option public var to: String?
  @Option public var cc: String?
  @Option public var bcc: String?
  @Option public var subject: String?
  @Option(name: .customLong("destination-mailbox")) public var destinationMailbox: String?
  @Option(name: .customLong("archive-mailbox")) public var archiveMailbox: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("account", account),
      ("mailbox", mailbox),
      ("query", query),
      ("scope", scope),
      ("max-scan", maxScan),
      ("id", id),
      ("max-bytes", maxBytes),
      ("body", body),
      ("to", to),
      ("cc", cc),
      ("bcc", bcc),
      ("subject", subject),
      ("destination-mailbox", destinationMailbox),
      ("archive-mailbox", archiveMailbox),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func mailDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "mail_app",
      path: "/System/Applications/Mail.app",
      presentMessage: "Mail app bundle is present.",
      missingMessage: "Mail app bundle was not found at the expected system path."
    ),
    CLIDoctorCheck(
      name: "mail_backend",
      status: .ok,
      message:
        "Mail.app accounts/mailboxes/list/unread/search/read metadata, bounded body search, bounded body preview, reply/forward preview, and dry-run previewed draft/reply-draft/forward-draft/send/move/archive/delete commands are implemented."
    ),
  ]
}
