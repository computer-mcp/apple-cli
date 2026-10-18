import Foundation
import Utility

public struct PrintCommand: Sendable {
  private let backend: any PrintReading
  private let actions: any PrintActing
  private let target = "print"

  public init(
    backend: any PrintReading = CUPSPrintBackend(),
    actions: any PrintActing = CUPSPrintActions()
  ) {
    self.backend = backend
    self.actions = actions
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["printers", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let printers = try backend.listPrinters(limit: try commandLimit(options))
      return try result(
        PrintersResponse(printers: printers), human: printersHumanOutput(printers), options: options
      )
    case ["printers", "read"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["name"])
      let name = try requiredOption("name", options: options)
      guard let printer = try backend.readPrinter(name: name) else {
        throw CLIError(code: .notFound, message: "Printer was not found.", details: ["name": name])
      }
      return try result(
        PrinterResponse(printer: printer), human: printerHumanOutput(printer), options: options)
    case ["jobs", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["printer"])
      let jobs = try backend.listJobs(
        printer: options.targetOption("printer"), limit: try commandLimit(options))
      return try result(
        PrintJobsResponse(jobs: jobs), human: jobsHumanOutput(jobs), options: options)
    case ["jobs", "submit"]:
      try validateTargetOptions(options, allowedOptions: ["printer", "file"])
      let submission = try requiredSubmission(options)
      return try printAction(
        operation: "print.submit",
        scopeDigest: submission.scopeDigest,
        summary: submission.summaryFields,
        options: options
      ) {
        let jobID = try actions.submit(
          filePath: submission.filePath, printerName: submission.printerName)
        return PrintActionResult(
          operation: "print.submit",
          submitted: true,
          printerName: submission.printerName,
          filePath: submission.filePath,
          jobID: jobID
        )
      }
    case ["jobs", "cancel"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      let cancellation = try requiredCancellation(options)
      return try printAction(
        operation: "print.cancel",
        scopeDigest: cancellation.scopeDigest,
        summary: cancellation.summaryFields,
        options: options
      ) {
        let submitted = try actions.cancel(jobID: cancellation.job.id)
        return PrintActionResult(
          operation: "print.cancel",
          submitted: submitted,
          printerName: cancellation.job.printerName,
          filePath: nil,
          jobID: cancellation.job.id
        )
      }
    default:
      return nil
    }
  }

  private func requiredSubmission(_ options: CLIOptions) throws -> PrintSubmissionIdentity {
    let printerName = try requiredOption("printer", options: options)
    guard let printer = try backend.readPrinter(name: printerName) else {
      throw CLIError(
        code: .notFound, message: "Printer was not found.", details: ["name": printerName])
    }

    if printer.isEnabled == false {
      throw CLIError(
        code: .validationError, message: "Printer is disabled.", details: ["name": printerName])
    }

    let file = try printFileIdentity(path: try requiredOption("file", options: options))
    return PrintSubmissionIdentity(
      printerName: printer.name,
      filePath: file.path,
      scopeDigest:
        "print-submit:\(sha256Hex("\(printer.name)|\(file.path)|\(file.sizeBytes.map(String.init) ?? "-")|\(file.modifiedAtUnix.map(String.init) ?? "-")"))",
      summaryFields: [
        "printer": printer.name,
        "file": file.path,
        "file_name": file.name,
        "size_bytes": file.sizeBytes.map(String.init) ?? "",
      ]
    )
  }

  private func requiredCancellation(_ options: CLIOptions) throws -> PrintCancellationIdentity {
    let id = try requiredOption("id", options: options)
    let matches = try backend.listJobs(printer: nil, limit: 500).filter { $0.id == id }
    guard !matches.isEmpty else {
      throw CLIError(code: .notFound, message: "Print job was not found.", details: ["id": id])
    }
    guard matches.count == 1, let job = matches.first else {
      throw CLIError(
        code: .ambiguousIdentity, message: "Print job identity is ambiguous.", details: ["id": id])
    }

    return PrintCancellationIdentity(
      job: job,
      scopeDigest:
        "print-cancel:\(sha256Hex("\(job.id)|\(job.printerName)|\(job.owner ?? "-")|\(job.sizeBytes.map(String.init) ?? "-")"))",
      summaryFields: [
        "job_id": job.id,
        "printer": job.printerName,
        "owner": job.owner ?? "",
        "size_bytes": job.sizeBytes.map(String.init) ?? "",
      ]
    )
  }

  private func printAction(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    submit: () throws -> PrintActionResult
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "Print actions dispatch to the system print service and require `--allow-external-dispatch`."
    )

    let actionResult = try submit()
    return try result(
      actionResult, human: "\(operation) submitted=\(actionResult.submitted)", options: options)
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
