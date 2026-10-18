import AppKit
import Darwin
import Foundation
import Utility

enum KeynoteResourceKeys {
  static let all: Set<URLResourceKey> = [
    .nameKey, .isDirectoryKey, .isRegularFileKey, .fileSizeKey, .contentModificationDateKey,
  ]
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

struct PreviewExportArtifact {
  var file: KeynotePreviewExportFile
  var data: Data
}

func previewExportArtifacts(
  _ response: KeynotePreviewsResponse,
  destinationPath: String
) throws -> [PreviewExportArtifact] {
  guard !response.previews.isEmpty else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Keynote presentation does not contain QuickLook image preview artifacts.",
      details: ["path": response.presentation.path]
    )
  }

  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  try validatePresentationArtifactRelationship(
    source: URL(fileURLWithPath: response.presentation.path), destination: destination)
  return try response.previews.map { preview in
    let source = URL(fileURLWithPath: preview.previewPath).standardizedFileURL
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: source.path, isDirectory: &isDirectory),
      !isDirectory.boolValue
    else {
      throw CLIError(
        code: .notFound,
        message: "Keynote preview artifact was not found.",
        details: ["path": source.path]
      )
    }

    let data = try Data(contentsOf: source)
    let fileExtension = source.pathExtension.lowercased()
    let destinationFile = destination.appendingPathComponent(
      "preview-\(String(format: "%03d", preview.index)).\(fileExtension)"
    )
    return PreviewExportArtifact(
      file: KeynotePreviewExportFile(
        previewID: preview.id,
        index: preview.index,
        sourcePath: source.path,
        destinationPath: destinationFile.path,
        byteCount: data.count,
        sha256: sha256Hex(data)
      ),
      data: data
    )
  }
}

func previewExportScopeDigest(
  _ presentation: KeynotePresentationRecord,
  artifacts: [PreviewExportArtifact],
  format: String,
  destinationPath: String
) -> String {
  let artifactPayload = artifacts.map { artifact in
    [
      artifact.file.previewID,
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
  return "keynote-previews-export:\(sha256Hex(payload))"
}

func previewExportDigest(_ artifacts: [PreviewExportArtifact]) -> String {
  sha256Hex(artifacts.map(\.file.sha256).joined(separator: "|"))
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
  guard ["pdf", "preview-pdf", "thumbnail", "package"].contains(value) else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Keynote export currently supports `pdf`, `preview-pdf`, `thumbnail`, and `package`.")
  }
  return value
}

func previewExportFormat(_ options: CLIOptions) throws -> String {
  let value = try requiredOption("format", options: options).trimmingCharacters(
    in: .whitespacesAndNewlines
  ).lowercased()
  guard value == "images" else {
    throw CLIError(
      code: .unsupportedOperation, message: "Keynote preview export currently supports `images`."
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

func validatePreviewExportDestination(_ destinationPath: String) throws {
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

func writePreviewExportArtifacts(_ artifacts: [PreviewExportArtifact], destinationPath: String) throws {
  try validatePreviewExportDestination(destinationPath)
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard mkdir(destination.path, 0o755) == 0 else {
    throw CLIError(
      code: errno == EEXIST ? .validationError : .backendUnavailable,
      message: "Could not create the preview export directory without replacing an existing path.",
      details: ["path": destination.path]
    )
  }
  do {
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
      message: "Failed to write Keynote preview export.",
      details: CLIError.diagnosticDetails(for: error).merging(["path": destination.path]) { _, new in new }
    )
  }
}

func validatePresentationExportDestination(_ destinationPath: String, format: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let expectedExtensions: [String]
  switch format {
  case "pdf", "preview-pdf":
    expectedExtensions = ["pdf"]
  case "thumbnail":
    expectedExtensions = ["jpg", "jpeg"]
  case "package":
    expectedExtensions = ["key"]
  default:
    throw CLIError(
      code: .unsupportedOperation,
      message: "Keynote export currently supports `pdf`, `preview-pdf`, `thumbnail`, and `package`.")
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

func validatePresentationArtifactRelationship(source: URL, destination: URL) throws {
  let sourcePath = source.standardizedFileURL.resolvingSymlinksInPath().path
  // The export leaf is absent; resolve its existing ancestor before adding missing components.
  var ancestor = destination.standardizedFileURL
  var components: [String] = []
  while !FileManager.default.fileExists(atPath: ancestor.path) && ancestor.path != "/" {
    components.append(ancestor.lastPathComponent)
    ancestor = ancestor.deletingLastPathComponent()
  }
  var resolvedDestination = ancestor.resolvingSymlinksInPath()
  for component in components.reversed() {
    resolvedDestination.appendPathComponent(component)
  }
  let destinationPath = resolvedDestination.standardizedFileURL.path
  let identityKeys: Set<URLResourceKey> = [.fileResourceIdentifierKey, .volumeIdentifierKey]
  let sourceIdentity = try? source.resourceValues(forKeys: identityKeys)
  var current = ancestor.resolvingSymlinksInPath()
  while true {
    let candidate = try? current.resourceValues(forKeys: identityKeys)
    if let sourceFile = sourceIdentity?.fileResourceIdentifier as? NSObject,
      let sourceVolume = sourceIdentity?.volumeIdentifier as? NSObject,
      let candidateFile = candidate?.fileResourceIdentifier as? NSObject,
      let candidateVolume = candidate?.volumeIdentifier as? NSObject,
      sourceFile.isEqual(candidateFile), sourceVolume.isEqual(candidateVolume)
    {
      throw CLIError(code: .validationError, message: "Export destination must be outside the source presentation.")
    }
    if current.path == "/" { break }
    current = current.deletingLastPathComponent()
  }
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
    .map { "\($0.index)\t\($0.id)\tskipped=\($0.skipped)\t\($0.title ?? "")" }
    .joined(separator: "\n")
}

func previewsHumanOutput(_ response: KeynotePreviewsResponse) -> String {
  response.previews
    .map { "\($0.index)\t\($0.id)\t\($0.previewPath)" }
    .joined(separator: "\n")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}
