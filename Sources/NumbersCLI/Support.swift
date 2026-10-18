import AppKit
import Darwin
import Foundation
import Utility

enum NumbersResourceKeys {
  static let all: Set<URLResourceKey> = [
    .nameKey,
    .isDirectoryKey,
    .isRegularFileKey,
    .fileSizeKey,
    .contentModificationDateKey,
  ]
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateMutationIntent(_ options: CLIOptions, commandDescription: String) throws {}

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

func unsupportedNumbersCapability(_ message: String) -> CLIError {
  CLIError(code: .unsupportedOperation, message: message)
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name),
    !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  else {
    throw CLIError(code: .validationError, message: "Missing required option `--\(name)`.")
  }
  return value
}

func normalizedName(_ name: String, options: CLIOptions) throws -> String {
  let value = try requiredOption(name, options: options).trimmingCharacters(
    in: .whitespacesAndNewlines)
  guard !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  guard !value.contains("\n"), !value.contains("\r") else {
    throw CLIError(code: .validationError, message: "`--\(name)` must be a single line.")
  }
  return value
}

func exportFormat(_ options: CLIOptions) throws -> String {
  let value = try requiredOption("format", options: options).trimmingCharacters(
    in: .whitespacesAndNewlines
  ).lowercased()
  guard ["pdf", "thumbnail", "package"].contains(value) else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers export currently supports only `pdf`, `thumbnail`, and `package`.")
  }
  return value
}

func tableExportFormat(_ options: CLIOptions) throws -> String {
  let value = try requiredOption("format", options: options).trimmingCharacters(
    in: .whitespacesAndNewlines
  ).lowercased()
  guard ["csv", "tsv"].contains(value) else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers table export currently supports only `csv` and `tsv`.")
  }
  return value
}

func positiveIntOption(_ name: String, options: CLIOptions) throws -> Int {
  let rawValue = try requiredOption(name, options: options)
  guard let value = Int(rawValue), value > 0 else {
    throw CLIError(code: .validationError, message: "`--\(name)` must be a positive integer.")
  }
  return value
}

func cellTextValue(_ options: CLIOptions) throws -> String {
  let value = try requiredOption("value", options: options)
  guard Data(value.utf8).count <= 10_000 else {
    throw CLIError(code: .validationError, message: "`--value` cannot exceed 10000 UTF-8 bytes.")
  }
  guard !value.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("=") else {
    throw CLIError(code: .validationError, message: "`--value` must be plain text, not a formula.")
  }
  let allowedControls: Set<UnicodeScalar> = ["\n", "\r", "\t"]
  guard value.unicodeScalars.allSatisfy({ $0.value >= 0x20 || allowedControls.contains($0) }) else {
    throw CLIError(
      code: .validationError, message: "`--value` contains unsupported control characters.")
  }
  return value
}

func standardizedAbsolutePath(_ path: String) -> String {
  let expanded = (path as NSString).expandingTildeInPath
  if expanded.hasPrefix("/") {
    return URL(fileURLWithPath: expanded).standardizedFileURL.path
  }

  return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent(expanded)
    .standardizedFileURL
    .path
}

func validateDocumentExportDestination(_ destinationPath: String, format: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let expectedExtensions: [String]
  switch format {
  case "pdf":
    expectedExtensions = ["pdf"]
  case "thumbnail":
    expectedExtensions = ["jpg", "jpeg"]
  case "package":
    expectedExtensions = ["numbers"]
  default:
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers export currently supports only `pdf`, `thumbnail`, and `package`.")
  }
  guard expectedExtensions.contains(destination.pathExtension.lowercased()) else {
    let extensionList = expectedExtensions.map { ".\($0)" }.joined(separator: "` or `")
    throw CLIError(
      code: .validationError,
      message: "`--to` must end in `\(extensionList)` for \(format) export.",
      details: ["path": destination.path])
  }
  guard !FileManager.default.fileExists(atPath: destination.path) else {
    throw CLIError(
      code: .validationError, message: "Destination path already exists.",
      details: ["path": destination.path])
  }
  let parent = destination.deletingLastPathComponent()
  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory),
    isDirectory.boolValue
  else {
    throw CLIError(
      code: .notFound, message: "Destination parent directory was not found.",
      details: ["path": parent.path])
  }
}

func validatePackageExportRelationship(source: URL, destination: URL) throws {
  let sourcePath = source.standardizedFileURL.path
  let destinationPath = destination.standardizedFileURL.path
  guard sourcePath != destinationPath else {
    throw CLIError(
      code: .validationError, message: "Destination path must differ from source path.",
      details: ["path": destinationPath])
  }
  guard !destinationPath.hasPrefix(sourcePath + "/") else {
    throw CLIError(
      code: .validationError, message: "Destination path cannot be inside the source package.",
      details: ["path": destinationPath])
  }
}

func validateTableExportDestination(_ destinationPath: String, format: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let expectedExtension = format == "tsv" ? "tsv" : "csv"
  guard destination.pathExtension.lowercased() == expectedExtension else {
    throw CLIError(
      code: .validationError,
      message: "`--to` must end in `.\(expectedExtension)` for \(format) export.",
      details: ["path": destination.path]
    )
  }
  guard !FileManager.default.fileExists(atPath: destination.path) else {
    throw CLIError(
      code: .validationError, message: "Destination path already exists.",
      details: ["path": destination.path])
  }
  let parent = destination.deletingLastPathComponent()
  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory),
    isDirectory.boolValue
  else {
    throw CLIError(
      code: .notFound, message: "Destination parent directory was not found.",
      details: ["path": parent.path])
  }
}

func nonTrivialQuery(_ options: CLIOptions) throws -> String {
  let query = try requiredOption("query", options: options)
  guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
    throw CLIError(
      code: .validationError,
      message: "`--query` must contain at least 2 non-whitespace characters.")
  }
  return query
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 500 for Numbers document commands.")
  }
  return limit
}

func documentsHumanOutput(_ documents: [NumbersDocumentRecord]) -> String {
  documents.map { "\($0.path)\t\($0.name)" }.joined(separator: "\n")
}

func documentHumanOutput(_ document: NumbersDocumentRecord) -> String {
  [
    "path: \(document.path)",
    "name: \(document.name)",
    "quickLookPreviewPath: \(document.quickLookPreviewPath ?? "")",
  ].joined(separator: "\n")
}

func sheetsHumanOutput(_ sheets: [NumbersSheetRecord]) -> String {
  sheets.map { sheet in
    let tableNames = sheet.tables.map(\.name).joined(separator: ",")
    return "\(sheet.index)\t\(sheet.name)\t\(tableNames)"
  }.joined(separator: "\n")
}

func tableHumanOutput(_ table: NumbersTableRecord) -> String {
  let header =
    "sheet: \(table.sheetName)\ntable: \(table.tableName)\nrows: \(table.rowCount)\ncolumns: \(table.columnCount)"
  let rows = table.rows.map { row in
    "\(row.index)\t\(row.values.joined(separator: "\t"))"
  }.joined(separator: "\n")
  return rows.isEmpty ? header : "\(header)\n\(rows)"
}

func tableExportData(for table: NumbersTableRecord, format: String) -> Data {
  switch format {
  case "tsv":
    return delimitedData(for: table, delimiter: "\t")
  default:
    return delimitedData(for: table, delimiter: ",")
  }
}

func delimitedData(for table: NumbersTableRecord, delimiter: Character) -> Data {
  let rows = table.rows.map { row in
    row.values.map { delimitedEscapedValue($0, delimiter: delimiter) }.joined(
      separator: String(delimiter))
  }
  let text = rows.isEmpty ? "" : rows.joined(separator: "\n") + "\n"
  return Data(text.utf8)
}

func delimitedEscapedValue(_ value: String, delimiter: Character) -> String {
  if value.contains("\"") || value.contains(String(delimiter)) || value.contains("\n")
    || value.contains("\r")
  {
    return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
  }
  return value
}

func writeDataWithoutOverwriting(_ data: Data, to url: URL) throws {
  let fileDescriptor = Darwin.open(
    url.path,
    O_WRONLY | O_CREAT | O_EXCL,
    S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
  )
  guard fileDescriptor >= 0 else {
    throw fileWriteError(errno, path: url.path)
  }

  var shouldClose = true
  do {
    try data.withUnsafeBytes { rawBuffer throws in
      guard let baseAddress = rawBuffer.baseAddress else {
        return
      }
      var written = 0
      while written < rawBuffer.count {
        let result = Darwin.write(
          fileDescriptor,
          baseAddress.advanced(by: written),
          rawBuffer.count - written
        )
        if result < 0 {
          throw fileWriteError(errno, path: url.path)
        }
        if result == 0 {
          throw fileWriteError(EIO, path: url.path)
        }
        written += result
      }
    }

    if Darwin.close(fileDescriptor) != 0 {
      shouldClose = false
      throw fileWriteError(errno, path: url.path)
    }
    shouldClose = false
  } catch {
    if shouldClose {
      _ = Darwin.close(fileDescriptor)
    }
    try? FileManager.default.removeItem(at: url)
    throw error
  }
}

func fileWriteError(_ errorNumber: Int32, path: String) -> CLIError {
  if errorNumber == EEXIST {
    return CLIError(
      code: .validationError, message: "Destination path already exists.", details: ["path": path])
  }
  if errorNumber == ENOENT {
    return CLIError(
      code: .notFound, message: "Destination parent directory was not found.",
      details: ["path": path])
  }
  return CLIError(
    code: .internalError,
    message: "Failed to write export file.",
    details: [
      "path": path, "errno": "\(errorNumber)", "reason": String(cString: strerror(errorNumber)),
    ]
  )
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}

func appleScriptString(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
}

extension NSAppleEventDescriptor {
  func rows() -> [[String]] {
    guard numberOfItems > 0 else {
      return []
    }

    return (1...numberOfItems).map { index in
      guard let row = atIndex(index) else {
        return []
      }
      return row.strings()
    }
  }

  func strings() -> [String] {
    guard numberOfItems > 0 else {
      return [stringValue ?? ""]
    }

    return (1...numberOfItems).map { index in
      atIndex(index)?.stringValue ?? ""
    }
  }
}

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
