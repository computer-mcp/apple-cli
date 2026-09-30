import ArgumentParser
import Foundation

public struct CLISharedOptions: ParsableArguments, Sendable {
  @Flag(help: "Emit the stable JSON envelope.")
  public var json = false

  @Flag(help: "Pretty-print JSON output.")
  public var pretty = false

  @Flag(help: "Emit additional diagnostics where supported.")
  public var verbose = false

  @Option(help: "Output cap for list/search style commands.")
  public var limit: Int?

  @Flag(
    name: .customLong("dry-run"),
    help: "Run validation and resolution for a mutation, then stop before side effects.")
  public var dryRun = false

  @Flag(
    name: .customLong("allow-destructive-selection"),
    help: "Allow a command to mutate or delete a dynamically selected set.")
  public var allowDestructiveSelection = false

  @Flag(
    name: .customLong("allow-external-dispatch"),
    help: "Allow a command to dispatch work to an external application or system service.")
  public var allowExternalDispatch = false

  @Flag(
    name: .customLong("allow-artifact-action"),
    help: "Allow a command to create, overwrite, move, or remove filesystem artifacts.")
  public var allowArtifactAction = false

  @Flag(
    name: .customLong("allow-persistent-action"),
    help: "Allow a command to persist state outside the immediate command output.")
  public var allowPersistentAction = false

  public init() {}

  public init(
    json: Bool = false,
    pretty: Bool = false,
    verbose: Bool = false,
    limit: Int? = nil,
    dryRun: Bool = false,
    allowDestructiveSelection: Bool = false,
    allowExternalDispatch: Bool = false,
    allowArtifactAction: Bool = false,
    allowPersistentAction: Bool = false
  ) {
    self.json = json
    self.pretty = pretty
    self.verbose = verbose
    self.limit = limit
    self.dryRun = dryRun
    self.allowDestructiveSelection = allowDestructiveSelection
    self.allowExternalDispatch = allowExternalDispatch
    self.allowArtifactAction = allowArtifactAction
    self.allowPersistentAction = allowPersistentAction
  }

  public func cliOptions(
    targetOptions: [String: String] = [:],
    targetFlags: Set<String> = [],
    positionals: [String]
  ) -> CLIOptions {
    CLIOptions(
      json: json,
      pretty: pretty,
      verbose: verbose,
      limit: limit,
      dryRun: dryRun,
      safetyFlags: CLITargetOptionBuilder.flags([
        ("allow-destructive-selection", allowDestructiveSelection),
        ("allow-external-dispatch", allowExternalDispatch),
        ("allow-artifact-action", allowArtifactAction),
        ("allow-persistent-action", allowPersistentAction),
      ]),
      targetOptions: targetOptions,
      targetFlags: targetFlags,
      positionals: positionals
    )
  }
}

public enum CLITargetOptionBuilder {
  public static func options(_ entries: [(String, String?)]) -> [String: String] {
    var options: [String: String] = [:]
    for (name, value) in entries {
      if let value {
        options[name] = value
      }
    }
    return options
  }

  public static func flags(_ entries: [(String, Bool)]) -> Set<String> {
    Set(entries.compactMap { name, enabled in enabled ? name : nil })
  }
}

public enum CLICommandOutput {
  public static func writeStatus(
    target: String,
    status: String,
    implemented: Bool,
    json: Bool,
    pretty: Bool
  ) throws {
    if json {
      let payload = CLITargetStatus(target: target, status: status, implemented: implemented)
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      print(try CLIJSON.encodeString(envelope, pretty: pretty))
    } else {
      print("\(target): \(status)")
    }
  }

  public static func writeDoctor(
    target: String,
    checks: [CLIDoctorCheck],
    json: Bool,
    pretty: Bool
  ) throws {
    let report = CLIDoctorReport(target: target, checks: checks)
    if json {
      let envelope = CLISuccessEnvelope(data: report, meta: ["target": target])
      print(try CLIJSON.encodeString(envelope, pretty: pretty))
    } else {
      print(renderDoctorReport(report))
    }

    if report.exitCode != 0 {
      throw ExitCode(report.exitCode)
    }
  }

  public static func write(_ result: CLICommandResult) throws {
    if let output = result.stdout {
      print(output)
    }

    if let diagnostic = result.stderr {
      writeStandardError(diagnostic)
    }

    if result.exitCode != 0 {
      throw ExitCode(result.exitCode)
    }
  }

  public static func write(
    _ error: CLIError,
    target: String,
    json: Bool,
    pretty: Bool
  ) throws {
    let exitCode = emit(error, target: target, json: json, pretty: pretty)
    throw ExitCode(exitCode)
  }

  private static func renderDoctorReport(_ report: CLIDoctorReport) -> String {
    var lines = [
      "\(report.target) doctor: \(report.status.rawValue)"
    ]

    for check in report.checks {
      lines.append("- \(check.name): \(check.status.rawValue) - \(check.message)")
    }

    return lines.joined(separator: "\n")
  }

  private static func emit(_ error: CLIError, target: String, json: Bool, pretty: Bool) -> Int32 {
    if json {
      let envelope = CLIErrorEnvelope(error: error.payload, meta: ["target": target])
      if let encoded = try? CLIJSON.encodeString(envelope, pretty: pretty) {
        print(encoded)
      } else {
        writeStandardError("internal_error: Failed to encode JSON error envelope.")
        return CLIErrorCode.internalError.exitCode
      }
    } else {
      writeStandardError("\(error.code.rawValue): \(error.message)")
    }

    return error.code.exitCode
  }

  private static func writeStandardError(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
  }
}

public struct CLITargetStatus: Codable, Sendable {
  public var target: String
  public var status: String
  public var implemented: Bool

  public init(target: String, status: String, implemented: Bool) {
    self.target = target
    self.status = status
    self.implemented = implemented
  }
}
