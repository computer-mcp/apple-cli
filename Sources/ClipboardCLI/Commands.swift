import AppKit
import ArgumentParser
import Utility

public struct ClipboardTarget: ParsableCommand {
  public static let targetName = "clipboard"
  public static let targetStatus =
    "Implemented: pasteboard type/read and dry-run previewed write/clear paths."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "clipboard",
    abstract: "Pasteboard read, type inspection, write, and clear workflows.",
    version: CLIVersion.current,
    subcommands: [Types.self, Read.self, Write.self, Clear.self, Doctor.self]
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

  public struct Types: Leaf {
    public static let configuration = CommandConfiguration(commandName: "types")
    public static let positionals = ["clipboard", "types"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardTargetOptions
    public init() {}
  }

  public struct Read: Leaf {
    public static let configuration = CommandConfiguration(commandName: "read")
    public static let positionals = ["clipboard", "read"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardTargetOptions
    public init() {}
  }

  public struct Write: Leaf {
    public static let configuration = CommandConfiguration(commandName: "write")
    public static let positionals = ["clipboard", "write"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardTargetOptions
    public init() {}
  }

  public struct Clear: Leaf {
    public static let configuration = CommandConfiguration(commandName: "clear")
    public static let positionals = ["clipboard", "clear"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ClipboardTargetOptions
    public init() {}
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: ClipboardTarget.targetName,
        checks: clipboardDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension ClipboardTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try ClipboardCommand().run(options: options) else {
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
    var targetOptions: ClipboardTargetOptions { get }
  }
}

extension ClipboardTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try ClipboardTarget.runCommand(options: options)
  }
}

public struct ClipboardTargetOptions: ParsableArguments, Sendable {
  @Option public var type: String?
  @Option public var text: String?

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("type", type),
      ("text", text),
    ])
  }

  public var cliTargetFlags: Set<String> { [] }
}

public func clipboardDoctorChecks() -> [CLIDoctorCheck] {
  let types = NSPasteboard.general.types ?? []
  return [
    CLIDoctorCheck(
      name: "general_pasteboard",
      status: .ok,
      message: "NSPasteboard general pasteboard is reachable.",
      details: ["type_count": "\(types.count)"]
    ),
    CLIDoctorCheck(
      name: "pasteboard_backend",
      status: .ok,
      message: "Clipboard type/read/write/clear backend is implemented."
    ),
  ]
}
