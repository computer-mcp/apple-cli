import AppKit
import ArgumentParser
import Utility

public struct ClipboardTarget: ParsableCommand {
  public static let targetName = "clipboard"
  public static let targetStatus =
    "Implemented: bounded text and typed item reads, verified replacement and clear."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "clipboard",
    abstract: "Read and replace the current system pasteboard.",
    version: CLIVersion.current,
    subcommands: [Types.self, Read.self, Write.self, Clear.self, Items.self, Doctor.self]
  )

  @OptionGroup public var shared: CLISharedOptions
  public init() {}

  public mutating func run() throws {
    try CLICommandOutput.writeStatus(
      target: Self.targetName, status: Self.targetStatus, implemented: Self.isImplemented,
      json: shared.json, pretty: shared.pretty)
  }

  public struct Types: Leaf {
    public static let configuration = CommandConfiguration(commandName: "types")
    public static let positionals = ["clipboard", "types"]
    @OptionGroup public var shared: CLISharedOptions
    public var targetOptions: ClipboardNoOptions { .init() }
    public init() {}
  }

  public struct Read: Leaf {
    public static let configuration = CommandConfiguration(commandName: "read")
    public static let positionals = ["clipboard", "read"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardReadOptions
    public init() {}
  }

  public struct Write: Leaf {
    public static let configuration = CommandConfiguration(commandName: "write")
    public static let positionals = ["clipboard", "write"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardWriteOptions
    public init() {}
  }

  public struct Clear: Leaf {
    public static let configuration = CommandConfiguration(commandName: "clear")
    public static let positionals = ["clipboard", "clear"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardClearOptions
    public init() {}
  }

  public struct Items: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "items", abstract: "Preserve item boundaries and typed data.",
      subcommands: [Read.self, Write.self])
    public init() {}

    public struct Read: ClipboardTarget.Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "read", abstract: "Read ordered items and their base64 representations.")
      public static let positionals = ["clipboard", "items", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: ClipboardReadOptions
      public init() {}
    }

    public struct Write: ClipboardTarget.Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "write", abstract: "Replace all items from a complete JSON payload.")
      public static let positionals = ["clipboard", "items", "write"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: ClipboardItemsWriteOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: ClipboardTarget.targetName, checks: clipboardDoctorChecks(),
        json: shared.json, pretty: shared.pretty)
    }
  }

  public protocol Leaf: ParsableCommand {
    associatedtype TargetOptions: ClipboardCommandOptions
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: TargetOptions { get }
  }
}

extension ClipboardTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try ClipboardCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable, message: "Clipboard command is unavailable.",
          details: ["target": targetName, "command": options.positionals.joined(separator: " ")])
      }
      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(
        error, target: targetName, json: options.json, pretty: options.pretty)
    } catch {
      try CLICommandOutput.write(
        CLIError.unexpected(error, verbose: options.verbose), target: targetName,
        json: options.json, pretty: options.pretty)
    }
  }
}

extension ClipboardTarget.Leaf {
  public mutating func run() throws {
    try ClipboardTarget.runCommand(
      options: shared.cliOptions(
        targetOptions: targetOptions.cliTargetOptions, targetFlags: targetOptions.cliTargetFlags,
        positionals: Self.positionals))
  }
}

public protocol ClipboardCommandOptions: ParsableArguments {
  var cliTargetOptions: [String: String] { get }
  var cliTargetFlags: Set<String> { get }
}

extension ClipboardCommandOptions {
  public var cliTargetFlags: Set<String> { [] }
}

public struct ClipboardNoOptions: ClipboardCommandOptions {
  public init() {}
  public var cliTargetOptions: [String: String] { [:] }
}

public struct ClipboardReadOptions: ClipboardCommandOptions, Sendable {
  @Option(help: "Exact type. read defaults to plain text; items read defaults to all formats.")
  public var type: String?
  @Option(
    name: .customLong("max-bytes"), help: "Raw content cap, default 1048576, maximum 67108864.")
  public var maxBytes: Int?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([("type", type), ("max-bytes", maxBytes.map(String.init))])
  }
}

public struct ClipboardWriteOptions: ClipboardCommandOptions, Sendable {
  @Option(help: "Plain text, including an explicit empty string.") public var text: String
  @Flag(name: .customLong("current-host-only"), help: "Keep new content on this device.")
  public var currentHostOnly = false
  @Option(
    name: .customLong("if-change-count"), help: "Refuse replacement if the current counter differs."
  )
  public var ifChangeCount: Int?
  @Option(
    name: .customLong("max-bytes"), help: "Raw content cap, default 1048576, maximum 67108864.")
  public var maxBytes: Int?
  public init() {}
  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([("current-host-only", currentHostOnly)])
  }
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("text", text), ("if-change-count", ifChangeCount.map(String.init)),
      ("max-bytes", maxBytes.map(String.init)),
    ])
  }
}

public struct ClipboardItemsWriteOptions: ClipboardCommandOptions, Sendable {
  @Option(help: "Regular JSON file containing items or a complete items read envelope.") public
    var input: String
  @Flag(name: .customLong("current-host-only"), help: "Keep new content on this device.")
  public var currentHostOnly = false
  @Option(
    name: .customLong("if-change-count"), help: "Refuse replacement if the current counter differs."
  )
  public var ifChangeCount: Int?
  @Option(
    name: .customLong("max-bytes"), help: "Raw content cap, default 1048576, maximum 67108864.")
  public var maxBytes: Int?
  public init() {}
  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([("current-host-only", currentHostOnly)])
  }
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("input", input), ("if-change-count", ifChangeCount.map(String.init)),
      ("max-bytes", maxBytes.map(String.init)),
    ])
  }
}

public struct ClipboardClearOptions: ClipboardCommandOptions, Sendable {
  @Option(
    name: .customLong("if-change-count"), help: "Refuse clear if the current counter differs.")
  public var ifChangeCount: Int?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([("if-change-count", ifChangeCount.map(String.init))])
  }
}

public func clipboardDoctorChecks() -> [CLIDoctorCheck] {
  let pasteboard = NSPasteboard.general
  let types = pasteboard.types ?? []
  var checks = [
    CLIDoctorCheck(
      name: "general_pasteboard", status: .ok,
      message: "NSPasteboard general pasteboard is reachable.",
      details: ["type_count": "\(types.count)"]),
    CLIDoctorCheck(
      name: "pasteboard_backend", status: .ok,
      message: "Bounded text/item reads and verified replacement/clear are implemented."),
  ]
  if #available(macOS 15.4, *) {
    let behavior = pasteboard.accessBehavior
    checks.append(
      CLIDoctorCheck(
        name: "pasteboard_access",
        status: behavior == .alwaysDeny
          ? .permissionDenied : (behavior == .alwaysAllow ? .ok : .warning),
        message: behavior == .alwaysDeny
          ? "macOS denies programmatic clipboard reads for this app."
          : "Programmatic reads follow the app's Paste from Other Apps setting; macOS may ask for access.",
        details: ["access_behavior": "\(behavior.rawValue)"]))
  }
  return checks
}
