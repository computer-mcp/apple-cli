import CryptoKit
import Foundation
import Utility


public struct PrintActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var printerName: String?
  public var filePath: String?
  public var jobID: String?
}

public struct CUPSPrintBackend: PrintReading {
  private let runner: any CUPSCommandRunning

  public init(runner: any CUPSCommandRunning = CUPSProcessRunner()) {
    self.runner = runner
  }

  public func listPrinters(limit: Int) throws -> [PrinterRecord] {
    let statusOutput = try runner.runLPStat(arguments: ["-p"])
    let deviceOutput = try runner.runLPStat(arguments: ["-v"])
    let defaultOutput = try? runner.runLPStat(arguments: ["-d"])

    return parsePrinters(
      statusOutput: statusOutput,
      deviceOutput: deviceOutput,
      defaultOutput: defaultOutput ?? ""
    )
    .prefix(limit)
    .map { $0 }
  }

  public func readPrinter(name: String) throws -> PrinterRecord? {
    try listPrinters(limit: 500).first { $0.name == name }
  }

  public func listJobs(printer: String?, limit: Int) throws -> [PrintJobRecord] {
    let output = try runner.runLPStat(arguments: printer.map { ["-o", $0] } ?? ["-o"])
    return parseJobs(output)
      .prefix(limit)
      .map { $0 }
  }
}

public struct CUPSProcessRunner: CUPSCommandRunning {
  public init() {}

  public func runLPStat(arguments: [String]) throws -> String {
    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(.path("/usr/bin/lpstat"), arguments: arguments)
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .backendUnavailable, message: "`lpstat` could not be started.")
    }

    if result.exitCode == 0 {
      return result.stdout
    }

    if isEmptyCUPSState(result.stderr) || isEmptyCUPSState(result.stdout) {
      return ""
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "`lpstat` failed while inspecting the print system.",
      details: ["status": "\(result.exitCode)"]
    )
  }
}

public struct CUPSPrintActions: PrintActing {
  private let runner: any CUPSActionCommandRunning

  public init(runner: any CUPSActionCommandRunning = CUPSActionProcessRunner()) {
    self.runner = runner
  }

  public func submit(filePath: String, printerName: String) throws -> String {
    let output = try runner.runLP(arguments: ["-d", printerName, filePath])
    return try parseSubmittedJobID(output)
  }

  public func cancel(jobID: String) throws -> Bool {
    _ = try runner.runCancel(arguments: [jobID])
    return true
  }
}

public struct CUPSActionProcessRunner: CUPSActionCommandRunning {
  public init() {}

  public func runLP(arguments: [String]) throws -> String {
    try runProcess(executablePath: "/usr/bin/lp", arguments: arguments, commandName: "lp")
  }

  public func runCancel(arguments: [String]) throws -> String {
    try runProcess(executablePath: "/usr/bin/cancel", arguments: arguments, commandName: "cancel")
  }

  private func runProcess(executablePath: String, arguments: [String], commandName: String) throws
    -> String
  {
    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(.path(executablePath), arguments: arguments)
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .backendUnavailable, message: "`\(commandName)` could not be started.")
    }

    if result.exitCode == 0 {
      return result.stdout
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "`\(commandName)` failed while submitting a print-system action.",
      details: ["status": "\(result.exitCode)"]
    )
  }
}
