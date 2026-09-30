import CryptoKit
import Foundation
import Utility

struct PrintSubmissionIdentity {
  var printerName: String
  var filePath: String
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct PrintCancellationIdentity {
  var job: PrintJobRecord
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct PrintFileIdentity {
  var path: String
  var name: String
  var sizeBytes: Int64?
  var modifiedAtUnix: Int?
}

func parsePrinters(statusOutput: String, deviceOutput: String, defaultOutput: String)
  -> [PrinterRecord]
{
  var records: [String: PrinterRecord] = [:]
  let defaultPrinter = parseDefaultPrinter(defaultOutput)

  for line in statusOutput.lines {
    guard line.hasPrefix("printer ") else {
      continue
    }
    let parts = line.split(separator: " ", maxSplits: 3).map(String.init)
    guard parts.count >= 3 else {
      continue
    }

    let name = parts[1]
    records[name] = PrinterRecord(
      name: name,
      state: parsePrinterState(line),
      isEnabled: parseEnabled(line),
      isDefault: name == defaultPrinter,
      deviceURI: nil
    )
  }

  for line in deviceOutput.lines {
    guard line.hasPrefix("device for ") else {
      continue
    }
    let body = String(line.dropFirst("device for ".count))
    guard let separator = body.firstIndex(of: ":") else {
      continue
    }
    let name = String(body[..<separator])
    let uriStart = body.index(after: separator)
    let uri = body[uriStart...].trimmingCharacters(in: .whitespaces)

    var record =
      records[name]
      ?? PrinterRecord(
        name: name,
        state: "unknown",
        isDefault: name == defaultPrinter
      )
    record.deviceURI = uri
    record.isDefault = name == defaultPrinter
    records[name] = record
  }

  return records.values.sorted {
    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
  }
}

func parseSubmittedJobID(_ output: String) throws -> String {
  let prefix = "request id is "
  if let line = output.lines.first(where: { $0.lowercased().hasPrefix(prefix) }) {
    let tail = String(line.dropFirst(prefix.count))
    if let id = tail.split(separator: " ").first.map(String.init), !id.isEmpty {
      return id
    }
  }

  throw CLIError(
    code: .backendUnavailable,
    message: "`lp` did not report a print job id."
  )
}

func parseJobs(_ output: String) -> [PrintJobRecord] {
  output.lines.compactMap { line in
    let parts = line.split(separator: " ").map(String.init)
    guard let first = parts.first else {
      return nil
    }

    return PrintJobRecord(
      id: first,
      printerName: printerName(fromJobId: first),
      owner: parts[safe: 1],
      sizeBytes: parts[safe: 2].flatMap(Int.init),
      submittedAtText: parts.count > 3 ? parts.dropFirst(3).joined(separator: " ") : nil
    )
  }
}

func parseDefaultPrinter(_ output: String) -> String? {
  let prefix = "system default destination: "
  return output.lines.first { $0.hasPrefix(prefix) }.map { String($0.dropFirst(prefix.count)) }
}

func parsePrinterState(_ line: String) -> String {
  guard let start = line.range(of: " is ")?.upperBound else {
    return "unknown"
  }

  let tail = line[start...]
  let end = tail.firstIndex(of: ".") ?? tail.endIndex
  return String(tail[..<end])
}

func parseEnabled(_ line: String) -> Bool? {
  if line.contains(". enabled since") {
    return true
  }
  if line.contains(". disabled since") {
    return false
  }
  return nil
}

func printerName(fromJobId jobId: String) -> String {
  guard let dash = jobId.lastIndex(of: "-") else {
    return jobId
  }
  return String(jobId[..<dash])
}

func isEmptyCUPSState(_ output: String) -> Bool {
  let lowercased = output.lowercased()
  return lowercased.contains("no destinations added")
    || lowercased.contains("no destination")
    || lowercased.contains("no system default destination")
    || lowercased.contains("no entries")
    || output.contains("未添加目的位置")
    || output.contains("无系统默认目的位置")
}

func printFileIdentity(path: String) throws -> PrintFileIdentity {
  let expanded = (path as NSString).expandingTildeInPath
  let url =
    (expanded.hasPrefix("/")
    ? URL(fileURLWithPath: expanded)
    : URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(
      expanded))
    .standardizedFileURL

  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
    throw CLIError(code: .notFound, message: "Print file was not found.", details: ["path": path])
  }

  guard !isDirectory.boolValue else {
    throw CLIError(
      code: .validationError, message: "`--file` must identify a file, not a directory.",
      details: ["path": path])
  }

  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.fileNotReadable(resource: "Print file"),
      details: ["path": path])
  }

  let values = try url.resourceValues(forKeys: [
    .nameKey, .isRegularFileKey, .fileSizeKey, .contentModificationDateKey,
  ])
  guard values.isRegularFile == true else {
    throw CLIError(
      code: .validationError, message: "`--file` must identify a regular file.",
      details: ["path": path])
  }

  return PrintFileIdentity(
    path: url.path,
    name: values.name ?? url.lastPathComponent,
    sizeBytes: values.fileSize.map(Int64.init),
    modifiedAtUnix: values.contentModificationDate.map { Int($0.timeIntervalSince1970) }
  )
}

func validateReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation or external-action commands."
    )
  }
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateTargetOptions(_ options: CLIOptions, allowedOptions: Set<String>) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if !unknownOptions.isEmpty || !options.targetFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(options.targetFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name),
    !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }
  return value
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 500 for Print read commands.")
  }
  return limit
}

func printersHumanOutput(_ printers: [PrinterRecord]) -> String {
  printers.map { printer in
    "\(printer.name)\t\(printer.state)\tdefault=\(printer.isDefault)"
  }.joined(separator: "\n")
}

func printerHumanOutput(_ printer: PrinterRecord) -> String {
  [
    "name: \(printer.name)",
    "state: \(printer.state)",
    "enabled: \(printer.isEnabled.map(String.init) ?? "-")",
    "default: \(printer.isDefault)",
    "deviceURI: \(printer.deviceURI ?? "-")",
  ].joined(separator: "\n")
}

func jobsHumanOutput(_ jobs: [PrintJobRecord]) -> String {
  jobs.map { job in
    "\(job.id)\t\(job.printerName)\t\(job.owner ?? "-")"
  }.joined(separator: "\n")
}

extension String {
  var lines: [String] {
    split(whereSeparator: \.isNewline).map(String.init)
  }
}

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
