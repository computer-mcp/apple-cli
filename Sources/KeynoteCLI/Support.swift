import AppKit
import CryptoKit
import Foundation
import Utility

enum KeynoteResourceKeys {
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

func validateMutationIntent(_ options: CLIOptions, commandDescription: String) throws {}

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

func sha256Hex(_ data: Data) -> String {
  let digest = SHA256.hash(data: data)
  return digest.map { String(format: "%02x", $0) }.joined()
}

func presentationIdentityScopeDigest(_ presentation: KeynotePresentationRecord) -> String {
  let payload = [
    presentation.path,
    presentation.name,
    "\(presentation.isPackage)",
    presentation.size.map(String.init) ?? "",
    presentation.modifiedAt.map(formatDate) ?? "",
    presentation.quickLookPreviewPath ?? "",
    presentation.quickLookThumbnailPath ?? "",
  ].joined(separator: "|")
  return "keynote-presentation:\(sha256Hex(payload))"
}

func presentationExportScopeDigest(
  _ presentation: KeynotePresentationRecord,
  format: String,
  destinationPath: String
) -> String {
  let payload = [
    presentationIdentityScopeDigest(presentation),
    format,
    destinationPath,
  ].joined(separator: "|")
  return "keynote-export:\(sha256Hex(payload))"
}

struct SlideExportArtifact {
  var file: KeynoteSlideExportFile
  var data: Data
}

func slideExportArtifacts(
  _ response: KeynoteSlidesResponse,
  destinationPath: String
) throws -> [SlideExportArtifact] {
  guard !response.slides.isEmpty else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Keynote presentation does not contain QuickLook slide preview artifacts.",
      details: ["path": response.presentation.path]
    )
  }

  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  return try response.slides.map { slide in
    guard let previewPath = slide.previewPath else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Keynote slide does not contain a QuickLook preview artifact.",
        details: ["slide_id": slide.id]
      )
    }
    let source = URL(fileURLWithPath: previewPath).standardizedFileURL
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: source.path, isDirectory: &isDirectory),
      !isDirectory.boolValue
    else {
      throw CLIError(
        code: .notFound,
        message: "Keynote slide preview artifact was not found.",
        details: ["path": source.path]
      )
    }

    let data = try Data(contentsOf: source)
    let fileExtension = source.pathExtension.lowercased()
    let destinationFile = destination.appendingPathComponent(
      "slide-\(String(format: "%03d", slide.index)).\(fileExtension)"
    )
    return SlideExportArtifact(
      file: KeynoteSlideExportFile(
        slideID: slide.id,
        index: slide.index,
        sourcePath: source.path,
        destinationPath: destinationFile.path,
        byteCount: data.count,
        sha256: sha256Hex(data)
      ),
      data: data
    )
  }
}

func slideExportScopeDigest(
  _ presentation: KeynotePresentationRecord,
  artifacts: [SlideExportArtifact],
  format: String,
  destinationPath: String
) -> String {
  let artifactPayload = artifacts.map { artifact in
    [
      artifact.file.slideID,
      "\(artifact.file.index)",
      artifact.file.sourcePath,
      artifact.file.destinationPath,
      "\(artifact.file.byteCount)",
      artifact.file.sha256,
    ].joined(separator: "\u{1f}")
  }.joined(separator: "\u{1e}")
  let payload = [
    presentationIdentityScopeDigest(presentation),
    format,
    destinationPath,
    artifactPayload,
  ].joined(separator: "|")
  return "keynote-slides-export:\(sha256Hex(payload))"
}

func slideExportDigest(_ artifacts: [SlideExportArtifact]) -> String {
  sha256Hex(artifacts.map(\.file.sha256).joined(separator: "|"))
}

func keynoteSlideID(presentation: KeynotePresentationRecord, preview: URL, index: Int) -> String {
  let payload = [
    presentationIdentityScopeDigest(presentation),
    String(index),
    preview.lastPathComponent,
  ].joined(separator: "|")
  return "slide-\(index)-\(String(sha256Hex(payload).prefix(8)))"
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
      message: "Keynote export currently supports only `pdf`, `thumbnail`, and `package`.")
  }
  return value
}

func slideExportFormat(_ options: CLIOptions) throws -> String {
  let value = try requiredOption("format", options: options).trimmingCharacters(
    in: .whitespacesAndNewlines
  ).lowercased()
  guard value == "images" else {
    throw CLIError(
      code: .unsupportedOperation, message: "Keynote slide export currently supports only `images`."
    )
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

func validateSlideExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
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

func writeSlideExportArtifacts(_ artifacts: [SlideExportArtifact], destinationPath: String) throws {
  try validateSlideExportDestination(destinationPath)
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  do {
    try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: false)
    for artifact in artifacts {
      try artifact.data.write(
        to: URL(fileURLWithPath: artifact.file.destinationPath), options: .withoutOverwriting)
    }
  } catch let error as CLIError {
    try? FileManager.default.removeItem(at: destination)
    throw error
  } catch {
    try? FileManager.default.removeItem(at: destination)
    throw CLIError(
      code: .internalError,
      message: "Failed to write Keynote slide export.",
      details: ["path": destination.path, "reason": String(describing: error)]
    )
  }
}

func validatePresentationExportDestination(_ destinationPath: String, format: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let expectedExtensions: [String]
  switch format {
  case "pdf":
    expectedExtensions = ["pdf"]
  case "thumbnail":
    expectedExtensions = ["jpg", "jpeg"]
  case "package":
    expectedExtensions = ["key"]
  default:
    throw CLIError(
      code: .unsupportedOperation,
      message: "Keynote export currently supports only `pdf`, `thumbnail`, and `package`.")
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
      code: .validationError,
      message: "`--limit` cannot exceed 500 for Keynote presentation commands.")
  }
  return limit
}

func presentationsHumanOutput(_ presentations: [KeynotePresentationRecord]) -> String {
  presentations.map { "\($0.path)\t\($0.name)" }.joined(separator: "\n")
}

func presentationHumanOutput(_ presentation: KeynotePresentationRecord) -> String {
  [
    "path: \(presentation.path)", "name: \(presentation.name)",
    "quickLookPreviewPath: \(presentation.quickLookPreviewPath ?? "")",
  ].joined(separator: "\n")
}

func slidesHumanOutput(_ response: KeynoteSlidesResponse) -> String {
  response.slides
    .map { "\($0.index)\t\($0.id)\t\($0.previewPath ?? "")" }
    .joined(separator: "\n")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}
