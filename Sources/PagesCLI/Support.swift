import AppKit
import CryptoKit
import Foundation
import Utility

enum PagesResourceKeys {
  static let all: Set<URLResourceKey> = [
    .nameKey, .isDirectoryKey, .isRegularFileKey, .fileSizeKey, .contentModificationDateKey,
  ]
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

func validateMutationIntent(_ options: CLIOptions) throws {}

func validateTargetOptions(_ options: CLIOptions, allowedOptions: Set<String>) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if !unknownOptions.isEmpty || !options.targetFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(options.targetFlags)).sorted()
    throw CLIError(
      code: .validationError, message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")])
  }
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func documentIdentityScopeDigest(_ document: PagesDocumentRecord) -> String {
  let payload = [
    document.path,
    document.name,
    "\(document.isPackage)",
    document.size.map(String.init) ?? "",
    document.modifiedAt.map(formatDate) ?? "",
    document.quickLookPreviewPath ?? "",
    document.quickLookThumbnailPath ?? "",
  ].joined(separator: "|")
  return "pages-document:\(sha256Hex(payload))"
}

func documentExportScopeDigest(_ document: PagesDocumentRecord, format: String, destinationPath: String)
  -> String
{
  let payload = [
    documentIdentityScopeDigest(document),
    format,
    destinationPath,
  ].joined(separator: "|")
  return "pages-export:\(sha256Hex(payload))"
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name),
    !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  else {
    throw CLIError(code: .validationError, message: "Missing required option `--\(name)`.")
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
      message: "Pages export currently supports only `pdf`, `thumbnail`, and `package`.")
  }
  return value
}

func standardizedAbsolutePath(_ path: String) -> String {
  let expanded = (path as NSString).expandingTildeInPath
  if expanded.hasPrefix("/") {
    return URL(fileURLWithPath: expanded).standardizedFileURL.path
  }
  return URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(
    expanded
  ).standardizedFileURL.path
}

func validateExportDestination(_ destinationPath: String, format: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let allowedExtensions: Set<String>
  let extensionMessage: String
  switch format {
  case "pdf":
    allowedExtensions = ["pdf"]
    extensionMessage = "`--to` must end in `.pdf` for pdf export."
  case "thumbnail":
    allowedExtensions = ["jpg", "jpeg"]
    extensionMessage = "`--to` must end in `.jpg` or `.jpeg` for thumbnail export."
  case "package":
    allowedExtensions = ["pages"]
    extensionMessage = "`--to` must end in `.pages` for package export."
  default:
    throw CLIError(
      code: .unsupportedOperation,
      message: "Pages export currently supports only `pdf`, `thumbnail`, and `package`.")
  }

  guard allowedExtensions.contains(destination.pathExtension.lowercased()) else {
    throw CLIError(
      code: .validationError, message: extensionMessage, details: ["path": destination.path])
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
      code: .validationError, message: "`--limit` cannot exceed 500 for Pages document commands.")
  }
  return limit
}

func documentsHumanOutput(_ documents: [PagesDocumentRecord]) -> String {
  documents.map { "\($0.path)\t\($0.name)" }.joined(separator: "\n")
}

func documentHumanOutput(_ document: PagesDocumentRecord) -> String {
  [
    "path: \(document.path)", "name: \(document.name)",
    "quickLookPreviewPath: \(document.quickLookPreviewPath ?? "")",
  ].joined(separator: "\n")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}
