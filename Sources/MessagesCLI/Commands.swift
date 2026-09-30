import ArgumentParser
import Foundation
import Utility

public struct MessagesTarget: ParsableCommand {
  public static let targetName = "messages"
  public static let targetStatus =
    "Implemented: Messages read/search paths plus dry-run previewed iMessage send, conversation send, and explicit-recipient send-many."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "messages",
    abstract: "Messages conversations, message reads, and dry-run sends.",
    version: CLIVersion.current,
    subcommands: [
      Conversations.self, List.self, Search.self, Read.self, Send.self, SendConversation.self,
      SendMany.self, Doctor.self,
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

  public struct Conversations: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "conversations",
      subcommands: [List.self, Search.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["conversations", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MessagesTargetOptions
      public init() {}
    }

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["conversations", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MessagesTargetOptions
      public init() {}
    }
  }

  public struct List: Leaf {
    public static let configuration = CommandConfiguration(commandName: "list")
    public static let positionals = ["messages", "list"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MessagesTargetOptions
    public init() {}
  }

  public struct Search: Leaf {
    public static let configuration = CommandConfiguration(commandName: "search")
    public static let positionals = ["messages", "search"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MessagesTargetOptions
    public init() {}
  }

  public struct Read: Leaf {
    public static let configuration = CommandConfiguration(commandName: "read")
    public static let positionals = ["messages", "read"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MessagesTargetOptions
    public init() {}
  }

  public struct Send: Leaf {
    public static let configuration = CommandConfiguration(commandName: "send")
    public static let positionals = ["messages", "send"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MessagesTargetOptions
    public init() {}
  }

  public struct SendConversation: Leaf {
    public static let configuration = CommandConfiguration(commandName: "send-conversation")
    public static let positionals = ["messages", "send-conversation"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MessagesTargetOptions
    public init() {}
  }

  public struct SendMany: Leaf {
    public static let configuration = CommandConfiguration(commandName: "send-many")
    public static let positionals = ["messages", "send-many"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MessagesTargetOptions
    public init() {}
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: MessagesTarget.targetName,
        checks: messagesDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension MessagesTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try MessagesCommand().run(options: options) else {
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
    var targetOptions: MessagesTargetOptions { get }
  }
}

extension MessagesTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try MessagesTarget.runCommand(options: options)
  }
}

public struct MessagesTargetOptions: ParsableArguments, Sendable {
  @Option public var query: String?
  @Option public var conversation: String?
  @Option public var id: String?
  @Option public var to: String?
  @Option public var text: String?
  @Option public var service: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("query", query),
      ("conversation", conversation),
      ("id", id),
      ("to", to),
      ("text", text),
      ("service", service),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func messagesDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "messages_app",
      path: "/System/Applications/Messages.app",
      presentMessage: "Messages app bundle is present.",
      missingMessage: "Messages app bundle was not found at the expected system path."
    ),
    .localPathExists(
      name: "messages_chat_db",
      path: "\(NSHomeDirectory())/Library/Messages/chat.db",
      presentMessage: "Messages chat database path is present.",
      missingMessage: "Messages chat database was not found at the expected path."
    ),
    SQLiteMessagesBackend().diagnosticCheck(),
    CLIDoctorCheck(
      name: "messages_send_backend",
      status: .ok,
      message:
        "Messages send, conversation send, and explicit-recipient send-many are implemented as dry-run previewed iMessage external actions."
    ),
  ]
}
