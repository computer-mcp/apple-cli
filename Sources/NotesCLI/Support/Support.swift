import CryptoKit
import AppKit
import Foundation
import Utility

private let notesMathVariableLatinAlphabet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")

struct NotesMutationIdentity {
  var note: NotesNoteDetail
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct NotesMarkdownSource {
  var path: String
  var name: String
  var byteCount: Int
  var modifiedAt: Date?
  var body: String
  var semanticSummary: NotesMarkdownSemanticSummary
  var isPackage: Bool
  var markdownRelativePath: String?
  var packageFileCount: Int?
  var packageTotalByteCount: Int?
  var packageTreeSHA256: String?
  var resources: [NotesMarkdownResourceSource]
}

struct NotesMarkdownImportDraft {
  var draft: NotesCreateDraft
  var source: NotesMarkdownSource
}

struct NotesMarkdownResourceSource {
  var relativePath: String
  var sourcePath: String
  var filename: String
  var byteCount: Int
  var data: Data
}

struct NotesRichImportResourceSource {
  var relativePath: String
  var sourcePath: String
  var filename: String
  var byteCount: Int
  var data: Data
}

struct NotesTextSource {
  var path: String
  var name: String
  var byteCount: Int
  var modifiedAt: Date?
  var body: String
}

struct NotesTextImportDraft {
  var draft: NotesCreateDraft
  var source: NotesTextSource
}

enum NotesRichImportFormat: String, Codable, Equatable, Sendable {
  case rtf
  case rtfd
  case html
}

struct NotesRichImportSource {
  var path: String
  var name: String
  var byteCount: Int
  var modifiedAt: Date?
  var format: NotesRichImportFormat
  var data: Data?
  var htmlRelativePath: String?
  var packageFileCount: Int?
  var packageResourceFileCount: Int?
  var packageTotalByteCount: Int?
  var packageTreeSHA256: String?
  var resources: [NotesRichImportResourceSource]
}

struct NotesRichImportDraft {
  var draft: NotesCreateDraft
  var source: NotesRichImportSource
}

enum NotesRichReplaceSource {
  case markdown(NotesMarkdownSource)
  case rich(NotesRichImportSource)

  var formatFamily: String {
    switch self {
    case .markdown:
      return "markdown"
    case .rich(let source):
      return source.format.rawValue
    }
  }

  var sourceByteCount: Int {
    switch self {
    case .markdown(let source):
      return source.byteCount
    case .rich(let source):
      return source.byteCount
    }
  }

  var resourceCount: Int {
    switch self {
    case .markdown(let source):
      return source.resources.count
    case .rich(let source):
      return source.resources.count
    }
  }
}

struct NotesRichReplaceDraft {
  var noteID: String
  var title: String
  var source: NotesRichReplaceSource
}

struct NotesAttachmentCopyDraft {
  var sourceNoteID: String
  var requestedAttachmentID: String
  var targetNoteID: String
  var filename: String
  var data: Data
  var sourceAttachment: NotesAttachmentRecord
}

struct NotesENEXImportDraft {
  var folderID: String
  var folderName: String
  var accountName: String
  var source: NotesENEXImportSource
}

struct NotesENEXImportSource {
  var path: String
  var name: String
  var byteCount: Int
  var modifiedAt: Date?
  var dataSHA256: String
  var notes: [NotesENEXImportNoteSource]

  var noteCount: Int { notes.count }
  var resourceCount: Int { notes.reduce(0) { $0 + $1.resourceCount } }
  var resourceByteCount: Int { notes.reduce(0) { $0 + $1.resourceByteCount } }
  var tagCount: Int { notes.reduce(0) { $0 + $1.tags.count } }
  var uniqueTagCount: Int { Set(notes.flatMap(\.tags).compactMap(notesENEXNormalizedTagText)).count }
  var normalizedTagCount: Int { notes.flatMap(\.tags).filter(notesENEXTagRequiresNormalization).count }
  var unsupportedTagCount: Int { notes.flatMap(\.tags).filter(notesENEXTagIsUnsupported).count }
  var createdDateCount: Int { notes.filter { $0.createdAt != nil }.count }
  var updatedDateCount: Int { notes.filter { $0.updatedAt != nil }.count }
  var inlineResourceReferenceCount: Int { notes.reduce(0) { $0 + $1.inlineResourceReferenceCount } }
  var matchedInlineResourceReferenceCount: Int {
    notes.reduce(0) { $0 + $1.matchedInlineResourceReferenceCount }
  }
  var unmatchedInlineResourceReferenceCount: Int {
    notes.reduce(0) { $0 + $1.unmatchedInlineResourceReferenceCount }
  }
}

struct NotesENEXImportNoteSource {
  var ordinal: Int
  var title: String
  var content: String
  var tags: [String]
  var createdAt: Date?
  var updatedAt: Date?
  var resources: [NotesENEXResourceSource]
  var inlineResourceReferences: [NotesENEXMediaReferenceSource]

  var resourceCount: Int { resources.count }
  var resourceByteCount: Int { resources.reduce(0) { $0 + $1.byteCount } }
  var inlineResourceReferenceCount: Int { inlineResourceReferences.count }
  var matchedInlineResourceReferenceCount: Int {
    inlineResourceReferences.filter { $0.matchedResourceOrdinal != nil }.count
  }
  var unmatchedInlineResourceReferenceCount: Int {
    inlineResourceReferences.filter { $0.matchedResourceOrdinal == nil }.count
  }
  var titleSHA256: String { sha256Hex(title) }
  var contentSHA256: String { sha256Hex(content) }
}

struct NotesENEXMediaReferenceSource {
  var ordinal: Int
  var resourceDataMD5: String?
  var mimeType: String?
  var matchedResourceOrdinal: Int?
}

struct NotesENEXResourceSource {
  var ordinal: Int
  var filename: String
  var mimeType: String?
  var byteCount: Int
  var dataSHA256: String
  var dataMD5: String
  var data: Data
}

struct NotesFolderImportDraft {
  var parentFolderID: String
  var parentFolderName: String
  var accountName: String
  var importRootFolderName: String
  var source: NotesFolderImportSource
}

struct NotesFolderImportSource {
  var path: String
  var name: String
  var directories: [NotesFolderImportDirectorySource]
  var files: [NotesFolderImportFileSource]
  var totalByteCount: Int
  var treeSHA256: String

  var directoryCount: Int { directories.count }
  var fileCount: Int { files.count }
  var importedNoteCount: Int { files.reduce(0) { $0 + folderImportedNoteCount($1) } }
  var resourceCount: Int { files.reduce(0) { $0 + folderImportResourceCount($1) } }
  var textCount: Int { files.filter { $0.formatFamily == "txt" }.count }
  var markdownCount: Int { files.filter { $0.formatFamily == "markdown" }.count }
  var markdownPackageCount: Int { files.filter { $0.formatFamily == "markdown_package" }.count }
  var richFormatCount: Int { files.filter { ["rtf", "rtfd", "html"].contains($0.formatFamily) }.count }
  var enexCount: Int { files.filter { $0.formatFamily == "enex" }.count }
  var formatFamilyCounts: [String: Int] {
    [
      "enex": enexCount,
      "html": files.filter { $0.formatFamily == "html" }.count,
      "markdown": markdownCount,
      "markdown_package": markdownPackageCount,
      "rtf": files.filter { $0.formatFamily == "rtf" }.count,
      "rtfd": files.filter { $0.formatFamily == "rtfd" }.count,
      "txt": textCount,
    ].filter { $0.value > 0 }
  }
}

struct NotesFolderImportDirectorySource {
  var ordinal: Int
  var relativePath: String
  var name: String
  var parentRelativePath: String
}

struct NotesFolderImportFileSource {
  var ordinal: Int
  var relativePath: String
  var directoryRelativePath: String
  var formatFamily: String
  var byteCount: Int
  var sourceSHA256: String
  var text: NotesTextSource?
  var markdown: NotesMarkdownSource?
  var rich: NotesRichImportSource?
  var enex: NotesENEXImportSource?
}

struct NotesAttachmentAddFileSource {
  var path: String
  var filename: String
  var byteCount: Int
  var modifiedAt: Date?
  var data: Data
}

struct NotesAttachmentMarkupModelSource {
  var path: String
  var byteCount: Int
  var modifiedAt: Date?
  var data: Data
}

struct NotesFileLinkSource {
  var path: String
  var url: URL
  var urlString: String
  var kind: String
}

let notesAttachmentAddMaxBytes = 50 * 1024 * 1024
let notesAttachmentAddBatchMaxFiles = 32
let notesAttachmentAddBatchMaxBytes = 250 * 1024 * 1024
let notesAttachmentMarkupModelMaxBytes = 50 * 1024 * 1024
let notesMarkdownImportMaxBytes = 1_000_000
let notesMarkdownPackageImportMaxFiles = 256
let notesMarkdownPackageImportMaxBytes = 100 * 1024 * 1024
let notesRichImportMaxBytes = 25 * 1024 * 1024
let notesRichImportPackageMaxFiles = 256
let notesRichImportPackageMaxBytes = 100 * 1024 * 1024
let notesENEXImportMaxBytes = 100 * 1024 * 1024
let notesENEXImportMaxNotes = 500
let notesENEXImportMaxTagsPerNote = 64
let notesENEXImportMaxResources = 512
let notesFolderImportMaxItems = 500
let notesFolderImportMaxDepth = 16
let notesFolderImportMaxBytes = 250 * 1024 * 1024

func runRows(_ source: String) throws -> [[String]] {
  var errorInfo: NSDictionary?
  guard let script = NSAppleScript(source: appleScriptWithTimeout(source, seconds: 30)) else {
    throw CLIError(code: .internalError, message: "Failed to compile Notes automation script.")
  }

  let descriptor = script.executeAndReturnError(&errorInfo)
  if let errorInfo {
    throw automationError(errorInfo)
  }

  return descriptor.rows()
}

func appleScriptWithTimeout(_ source: String, seconds: Int) -> String {
  """
  with timeout of \(seconds) seconds
  \(source)
  end timeout
  """
}

func automationError(_ errorInfo: NSDictionary) -> CLIError {
  let number = errorInfo[NSAppleScript.errorNumber] as? Int
  let code: CLIErrorCode =
    if number == -1712 {
      .timeout
    } else if let number, [-1743, -25211].contains(number) {
      .permissionDenied
    } else {
      .backendUnavailable
    }
  return CLIError.appleEventFailure(
    target: "Notes", code: code, number: number,
    details: ["executor": "NSAppleScript"])
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

func validateTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String>,
  allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(unknownFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func normalizedOption(_ name: String, options: CLIOptions) throws -> String {
  let value = try requiredOption(name, options: options).trimmingCharacters(
    in: .whitespacesAndNewlines)
  guard !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  return value
}

func normalizedOptionalOption(_ name: String, options: CLIOptions) throws -> String? {
  guard let value = options.targetOption(name) else {
    return nil
  }

  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  return trimmed
}

func normalizedTagOption(_ options: CLIOptions) throws -> String {
  try normalizedTagOption(named: "tag", options: options)
}

func normalizedTagOption(named name: String, options: CLIOptions) throws -> String {
  let raw = try normalizedOption(name, options: options)
  let withoutPrefix = raw.hasPrefix("#") ? String(raw.dropFirst()) : raw
  let trimmed = withoutPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  guard trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not contain whitespace.")
  }
  return trimmed
}

func standardizedTagContent(_ tag: String) -> String {
  let withoutPrefix = tag.hasPrefix("#") ? String(tag.dropFirst()) : tag
  return withoutPrefix.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase
}

func tagMatches(_ record: NotesTagRecord, _ tag: String) -> Bool {
  let standardized = standardizedTagContent(tag)
  return record.id.localizedCaseInsensitiveCompare(tag) == .orderedSame
    || record.displayText.localizedCaseInsensitiveCompare(tag) == .orderedSame
    || record.standardizedContent?.localizedCaseInsensitiveCompare(standardized) == .orderedSame
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func sha256Hex(_ data: Data) -> String {
  let digest = SHA256.hash(data: data)
  return digest.map { String(format: "%02x", $0) }.joined()
}

func md5Hex(_ data: Data) -> String {
  let digest = Insecure.MD5.hash(data: data)
  return digest.map { String(format: "%02x", $0) }.joined()
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

func notesFileLinkSource(path: String) throws -> NotesFileLinkSource {
  let absolutePath = standardizedAbsolutePath(path)
  var isDirectory = false
  let initialURL = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: initialURL.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "File link source was not found.",
      details: ["path_sha256": sha256Hex(initialURL.path)]
    )
  }

  let fileType = attributes[.type] as? FileAttributeType
  if fileType == .typeDirectory {
    isDirectory = true
  }
  guard fileType == .typeRegular || fileType == .typeDirectory else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a regular file or directory for Notes file link.",
      details: ["path_sha256": sha256Hex(initialURL.path)]
    )
  }
  let url = URL(fileURLWithPath: initialURL.path, isDirectory: isDirectory).standardizedFileURL
  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "File link source is not readable.",
      details: ["path_sha256": sha256Hex(url.path)]
    )
  }

  return NotesFileLinkSource(
    path: url.path,
    url: url,
    urlString: url.absoluteString,
    kind: isDirectory ? "directory" : "file"
  )
}

func validateNotesArtifactExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard !FileManager.default.fileExists(atPath: destination.path) else {
    throw CLIError(
      code: .validationError,
      message: "Destination path already exists.",
      details: ["path": destination.path]
    )
  }
  let parent = destination.deletingLastPathComponent()
  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory),
    isDirectory.boolValue
  else {
    throw CLIError(
      code: .notFound,
      message: "Destination parent directory was not found.",
      details: ["path": parent.path]
    )
  }
}

func validateNotesAttachmentExportDestination(_ destinationPath: String) throws {
  try validateNotesArtifactExportDestination(destinationPath)
}

func validateNotesAttachmentAudioTranscriptExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "txt" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.txt` for audio transcript export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesAttachmentRecognizedTextExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "txt" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.txt` for recognized text export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesLockedContentExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "txt" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.txt` for locked content export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesAttachmentMarkupExportDestination(_ destinationPath: String) throws {
  try validateNotesArtifactExportDestination(destinationPath)
}

func validateNotesSmartFolderCriteriaExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "json" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.json` for Smart Folder criteria export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesActivityExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "json" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.json` for Notes activity export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesCollaborationLinkExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "txt" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.txt` for Notes collaboration link export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesCollaborationParticipantsExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "json" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.json` for Notes collaboration participant metadata export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesPDFExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "pdf" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.pdf` for PDF export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func notesHTMLExportDestinationIsPackage(_ destinationPath: String) -> Bool {
  let ext = URL(fileURLWithPath: destinationPath).standardizedFileURL.pathExtension.lowercased()
  return ["htmlpkg", "htmlpackage"].contains(ext)
}

func validateNotesHTMLExportDestination(_ destinationPath: String, includeAttachments: Bool = false) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  if notesHTMLExportDestinationIsPackage(destination.path) {
    guard includeAttachments else {
      throw CLIError(
        code: .validationError,
        message: "`--include-attachments` is required for `.htmlpkg` or `.htmlpackage` HTML export.",
        details: ["path": destination.path]
      )
    }
    try validateNotesArtifactExportDestination(destination.path)
    return
  }
  guard destination.pathExtension.lowercased() == "html" else {
    throw CLIError(
      code: .validationError,
      message:
        includeAttachments
          ? "`--output` must end in `.html`, `.htmlpkg`, or `.htmlpackage` for HTML export with attachments."
          : "`--output` must end in `.html` for HTML export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesMarkdownExportDestination(_ destinationPath: String, includeAttachments: Bool = false) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  if includeAttachments {
    guard ["mdpkg", "markdownpackage"].contains(destination.pathExtension.lowercased()) else {
      throw CLIError(
        code: .validationError,
        message:
          "`--output` must end in `.mdpkg` or `.markdownpackage` for Markdown export with attachments.",
        details: ["path": destination.path]
      )
    }
    try validateNotesArtifactExportDestination(destination.path)
    return
  }
  guard ["md", "markdown"].contains(destination.pathExtension.lowercased()) else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.md` or `.markdown` for Markdown export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesRTFExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "rtf" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.rtf` for RTF export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func validateNotesRTFDExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "rtfd" else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.rtfd` for RTFD export.",
      details: ["path": destination.path]
    )
  }
  try validateNotesArtifactExportDestination(destination.path)
}

func writeNotesArtifactExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesArtifactExportDestination(destinationPath)
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let parent = destination.deletingLastPathComponent()
  let temporary = parent.appendingPathComponent(
    ".\(destination.lastPathComponent).\(UUID().uuidString).tmp")

  do {
    try data.write(to: temporary, options: [.atomic])
    try FileManager.default.moveItem(at: temporary, to: destination)
  } catch {
    try? FileManager.default.removeItem(at: temporary)
    throw error
  }
}

func writeNotesAttachmentExport(_ data: Data, to destinationPath: String) throws {
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesAttachmentAudioTranscriptExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesAttachmentAudioTranscriptExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesAttachmentRecognizedTextExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesAttachmentRecognizedTextExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesLockedContentExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesLockedContentExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesAttachmentMarkupExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesAttachmentMarkupExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesSmartFolderCriteriaExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesSmartFolderCriteriaExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesActivityExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesActivityExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesCollaborationLinkExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesCollaborationLinkExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesCollaborationParticipantsExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesCollaborationParticipantsExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesPDFExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesPDFExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesHTMLExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesHTMLExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesHTMLPackageExport(_ files: [NotesNoteHTMLExportFile], to destinationPath: String) throws {
  try validateNotesHTMLExportDestination(destinationPath, includeAttachments: true)
  guard notesHTMLExportDestinationIsPackage(destinationPath) else {
    throw CLIError(
      code: .validationError,
      message: "`--output` must end in `.htmlpkg` or `.htmlpackage` for HTML package export.",
      details: ["path": URL(fileURLWithPath: destinationPath).standardizedFileURL.path]
    )
  }
  let files = try normalizedNotesHTMLExportFiles(files)
  guard !files.isEmpty else {
    throw CLIError(code: .validationError, message: "HTML package export did not contain any files.")
  }
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let parent = destination.deletingLastPathComponent()
  let temporary = parent.appendingPathComponent(
    ".\(destination.lastPathComponent).\(UUID().uuidString).tmp",
    isDirectory: true
  )

  do {
    try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: false)
    for file in files {
      let target = notesHTMLExportFileURL(root: temporary, relativePath: file.relativePath)
      try FileManager.default.createDirectory(
        at: target.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try file.data.write(to: target, options: [.atomic])
    }
    try FileManager.default.moveItem(at: temporary, to: destination)
  } catch {
    try? FileManager.default.removeItem(at: temporary)
    throw error
  }
}

func writeNotesMarkdownExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesMarkdownExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesMarkdownPackageExport(_ files: [NotesNoteMarkdownExportFile], to destinationPath: String) throws {
  try validateNotesMarkdownExportDestination(destinationPath, includeAttachments: true)
  let files = try normalizedNotesMarkdownExportFiles(files)
  guard !files.isEmpty else {
    throw CLIError(code: .validationError, message: "Markdown package export did not contain any files.")
  }
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let parent = destination.deletingLastPathComponent()
  let temporary = parent.appendingPathComponent(
    ".\(destination.lastPathComponent).\(UUID().uuidString).tmp",
    isDirectory: true
  )

  do {
    try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: false)
    for file in files {
      let target = notesMarkdownExportFileURL(root: temporary, relativePath: file.relativePath)
      try FileManager.default.createDirectory(
        at: target.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try file.data.write(to: target, options: [.atomic])
    }
    try FileManager.default.moveItem(at: temporary, to: destination)
  } catch {
    try? FileManager.default.removeItem(at: temporary)
    throw error
  }
}

func writeNotesRTFExport(_ data: Data, to destinationPath: String) throws {
  try validateNotesRTFExportDestination(destinationPath)
  try writeNotesArtifactExport(data, to: destinationPath)
}

func writeNotesRTFDExport(_ files: [NotesNoteRTFDExportFile], to destinationPath: String) throws {
  try validateNotesRTFDExportDestination(destinationPath)
  let files = try normalizedNotesRTFDExportFiles(files)
  guard !files.isEmpty else {
    throw CLIError(code: .validationError, message: "RTFD export did not contain any files.")
  }
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let parent = destination.deletingLastPathComponent()
  let temporary = parent.appendingPathComponent(
    ".\(destination.lastPathComponent).\(UUID().uuidString).tmp",
    isDirectory: true
  )

  do {
    try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: false)
    for file in files {
      let target = notesRTFDExportFileURL(root: temporary, relativePath: file.relativePath)
      try FileManager.default.createDirectory(
        at: target.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try file.data.write(to: target, options: [.atomic])
    }
    try FileManager.default.moveItem(at: temporary, to: destination)
  } catch {
    try? FileManager.default.removeItem(at: temporary)
    throw error
  }
}

func notesRTFDTotalByteCount(_ files: [NotesNoteRTFDExportFile]) -> Int {
  files.reduce(0) { $0 + $1.data.count }
}

func notesRTFDTreeSHA256(_ files: [NotesNoteRTFDExportFile]) -> String {
  let payload = files
    .sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
    .map { "\($0.relativePath)\0\($0.data.count)\0\(sha256Hex($0.data))" }
    .joined(separator: "\n")
  return sha256Hex(payload)
}

func notesRTFDContainsRTFFile(_ files: [NotesNoteRTFDExportFile]) -> Bool {
  files.contains { file in
    URL(fileURLWithPath: file.relativePath).pathExtension.localizedCaseInsensitiveCompare("rtf")
      == .orderedSame
  }
}

func notesRTFDResourceFileCount(_ files: [NotesNoteRTFDExportFile]) -> Int {
  files.filter { file in
    URL(fileURLWithPath: file.relativePath).pathExtension.localizedCaseInsensitiveCompare("rtf")
      != .orderedSame
  }.count
}

func notesMarkdownPackageFiles(_ source: NotesNoteMarkdownExportSource) throws -> [NotesNoteMarkdownExportFile] {
  try normalizedNotesMarkdownExportFiles(
    [NotesNoteMarkdownExportFile(relativePath: source.markdownRelativePath, data: source.data)]
      + source.resourceFiles
  )
}

func notesMarkdownPackageTotalByteCount(_ files: [NotesNoteMarkdownExportFile]) -> Int {
  files.reduce(0) { $0 + $1.data.count }
}

func notesMarkdownPackageTreeSHA256(_ files: [NotesNoteMarkdownExportFile]) -> String {
  let payload = files
    .sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
    .map { "\($0.relativePath)\0\($0.data.count)\0\(sha256Hex($0.data))" }
    .joined(separator: "\n")
  return sha256Hex(payload)
}

func notesMarkdownPackageContainsMarkdownFile(_ files: [NotesNoteMarkdownExportFile]) -> Bool {
  files.contains { file in
    let ext = URL(fileURLWithPath: file.relativePath).pathExtension.lowercased()
    return ["md", "markdown"].contains(ext) && notesMarkdownDataIsValid(file.data)
  }
}

func notesHTMLPackageFiles(_ source: NotesNoteHTMLExportSource) throws -> [NotesNoteHTMLExportFile] {
  try normalizedNotesHTMLExportFiles(
    [NotesNoteHTMLExportFile(relativePath: source.htmlRelativePath, data: source.data)]
      + source.resourceFiles
  )
}

func notesHTMLPackageTotalByteCount(_ files: [NotesNoteHTMLExportFile]) -> Int {
  files.reduce(0) { $0 + $1.data.count }
}

func notesHTMLPackageTreeSHA256(_ files: [NotesNoteHTMLExportFile]) -> String {
  let payload = files
    .sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
    .map { "\($0.relativePath)\0\($0.data.count)\0\(sha256Hex($0.data))" }
    .joined(separator: "\n")
  return sha256Hex(payload)
}

func notesHTMLPackageContainsHTMLFile(_ files: [NotesNoteHTMLExportFile]) -> Bool {
  files.contains { file in
    URL(fileURLWithPath: file.relativePath).pathExtension.localizedCaseInsensitiveCompare("html")
      == .orderedSame && notesHTMLDataHasMarker(file.data)
  }
}

func notesHTMLDataHasMarker(_ data: Data) -> Bool {
  guard let html = String(data: data, encoding: .utf8)?.localizedLowercase else {
    return false
  }
  return html.contains("<!doctype html")
    || html.contains("<html")
    || html.contains("<body")
    || html.contains("<div")
    || html.contains("<p")
    || html.contains("<span")
    || html.contains("<br")
}

func notesMarkdownDataIsValid(_ data: Data) -> Bool {
  guard let markdown = String(data: data, encoding: .utf8) else {
    return false
  }
  return !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

func notesRTFDataHasHeader(_ data: Data) -> Bool {
  data.count >= 5 && data.prefix(5) == Data("{\\rtf".utf8)
}

func readNotesRTFDExportFiles(at destinationPath: String) throws -> [NotesNoteRTFDExportFile] {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL.resolvingSymlinksInPath()
  let resourceKeys: [URLResourceKey] = [.isRegularFileKey]
  guard
    let enumerator = FileManager.default.enumerator(
      at: destination,
      includingPropertiesForKeys: resourceKeys,
      options: [],
      errorHandler: nil
    )
  else {
    return []
  }

  var files: [NotesNoteRTFDExportFile] = []
  for case let fileURL as URL in enumerator {
    let values = try fileURL.resourceValues(forKeys: Set(resourceKeys))
    guard values.isRegularFile == true else {
      continue
    }
    let path = fileURL.standardizedFileURL.resolvingSymlinksInPath().path
    let relativePath = String(path.dropFirst(destination.path.count + 1))
    files.append(
      NotesNoteRTFDExportFile(
        relativePath: try normalizedNotesRTFDRelativePath(relativePath),
        data: try Data(contentsOf: fileURL)
      ))
  }
  return files.sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
}

func readNotesMarkdownPackageExportFiles(at destinationPath: String) throws -> [NotesNoteMarkdownExportFile] {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL.resolvingSymlinksInPath()
  let resourceKeys: [URLResourceKey] = [.isRegularFileKey]
  guard
    let enumerator = FileManager.default.enumerator(
      at: destination,
      includingPropertiesForKeys: resourceKeys,
      options: [],
      errorHandler: nil
    )
  else {
    return []
  }

  var files: [NotesNoteMarkdownExportFile] = []
  for case let fileURL as URL in enumerator {
    let values = try fileURL.resourceValues(forKeys: Set(resourceKeys))
    guard values.isRegularFile == true else {
      continue
    }
    let path = fileURL.standardizedFileURL.resolvingSymlinksInPath().path
    let relativePath = String(path.dropFirst(destination.path.count + 1))
    files.append(
      NotesNoteMarkdownExportFile(
        relativePath: try normalizedNotesMarkdownRelativePath(relativePath),
        data: try Data(contentsOf: fileURL)
      ))
  }
  return files.sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
}

func readNotesHTMLPackageExportFiles(at destinationPath: String) throws -> [NotesNoteHTMLExportFile] {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL.resolvingSymlinksInPath()
  let resourceKeys: [URLResourceKey] = [.isRegularFileKey]
  guard
    let enumerator = FileManager.default.enumerator(
      at: destination,
      includingPropertiesForKeys: resourceKeys,
      options: [],
      errorHandler: nil
    )
  else {
    return []
  }

  var files: [NotesNoteHTMLExportFile] = []
  for case let fileURL as URL in enumerator {
    let values = try fileURL.resourceValues(forKeys: Set(resourceKeys))
    guard values.isRegularFile == true else {
      continue
    }
    let path = fileURL.standardizedFileURL.resolvingSymlinksInPath().path
    let relativePath = String(path.dropFirst(destination.path.count + 1))
    files.append(
      NotesNoteHTMLExportFile(
        relativePath: try normalizedNotesHTMLRelativePath(relativePath),
        data: try Data(contentsOf: fileURL)
      ))
  }
  return files.sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
}

func notesRTFDExportFileURL(root: URL, relativePath: String) -> URL {
  let components = relativePath.split(separator: "/").map(String.init)
  return components.enumerated().reduce(root) { url, pair in
    let isLast = pair.offset == components.count - 1
    return url.appendingPathComponent(pair.element, isDirectory: !isLast)
  }
}

func notesMarkdownExportFileURL(root: URL, relativePath: String) -> URL {
  let components = relativePath.split(separator: "/").map(String.init)
  return components.enumerated().reduce(root) { url, pair in
    let isLast = pair.offset == components.count - 1
    return url.appendingPathComponent(pair.element, isDirectory: !isLast)
  }
}

func notesHTMLExportFileURL(root: URL, relativePath: String) -> URL {
  let components = relativePath.split(separator: "/").map(String.init)
  return components.enumerated().reduce(root) { url, pair in
    let isLast = pair.offset == components.count - 1
    return url.appendingPathComponent(pair.element, isDirectory: !isLast)
  }
}

func normalizedNotesMarkdownExportFiles(_ files: [NotesNoteMarkdownExportFile]) throws
  -> [NotesNoteMarkdownExportFile]
{
  var seen: Set<String> = []
  return try files.map { file in
    let relativePath = try normalizedNotesMarkdownRelativePath(file.relativePath)
    guard seen.insert(relativePath).inserted else {
      throw CLIError(
        code: .validationError,
        message: "Markdown package contains duplicate file paths.",
        details: ["path": relativePath]
      )
    }
    return NotesNoteMarkdownExportFile(relativePath: relativePath, data: file.data)
  }
}

func normalizedNotesMarkdownRelativePath(_ path: String) throws -> String {
  let normalized = path.replacingOccurrences(of: "\\", with: "/")
  let components = normalized.split(separator: "/", omittingEmptySubsequences: false)
  guard !normalized.isEmpty,
    !normalized.hasPrefix("/"),
    !components.contains(where: { $0.isEmpty || $0 == "." || $0 == ".." })
  else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package contains an unsafe relative file path.",
      details: ["path": path]
    )
  }
  return components.joined(separator: "/")
}

func normalizedNotesHTMLExportFiles(_ files: [NotesNoteHTMLExportFile]) throws
  -> [NotesNoteHTMLExportFile]
{
  var seen: Set<String> = []
  return try files.map { file in
    let relativePath = try normalizedNotesHTMLRelativePath(file.relativePath)
    guard seen.insert(relativePath).inserted else {
      throw CLIError(
        code: .validationError,
        message: "HTML package contains duplicate file paths.",
        details: ["path": relativePath]
      )
    }
    return NotesNoteHTMLExportFile(relativePath: relativePath, data: file.data)
  }
}

func normalizedNotesHTMLRelativePath(_ path: String) throws -> String {
  let normalized = path.replacingOccurrences(of: "\\", with: "/")
  let components = normalized.split(separator: "/", omittingEmptySubsequences: false)
  guard !normalized.isEmpty,
    !normalized.hasPrefix("/"),
    !components.contains(where: { $0.isEmpty || $0 == "." || $0 == ".." })
  else {
    throw CLIError(
      code: .validationError,
      message: "HTML package contains an unsafe relative file path.",
      details: ["path": path]
    )
  }
  return components.joined(separator: "/")
}

func normalizedNotesRTFDExportFiles(_ files: [NotesNoteRTFDExportFile]) throws
  -> [NotesNoteRTFDExportFile]
{
  var seen: Set<String> = []
  return try files.map { file in
    let relativePath = try normalizedNotesRTFDRelativePath(file.relativePath)
    guard seen.insert(relativePath).inserted else {
      throw CLIError(
        code: .validationError,
        message: "RTFD export contains duplicate file paths.",
        details: ["path": relativePath]
      )
    }
    return NotesNoteRTFDExportFile(relativePath: relativePath, data: file.data)
  }
}

func normalizedNotesRTFDRelativePath(_ path: String) throws -> String {
  let normalized = path.replacingOccurrences(of: "\\", with: "/")
  let components = normalized.split(separator: "/", omittingEmptySubsequences: false)
  guard !normalized.isEmpty,
    !normalized.hasPrefix("/"),
    !components.contains(where: { $0.isEmpty || $0 == "." || $0 == ".." })
  else {
    throw CLIError(
      code: .validationError,
      message: "RTFD export contains an unsafe relative file path.",
      details: ["path": path]
    )
  }
  return components.joined(separator: "/")
}

func markdownSource(path: String, includeAttachments: Bool = false) throws -> NotesMarkdownSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let ext = url.pathExtension.lowercased()
  if ["mdpkg", "markdownpackage"].contains(ext) {
    guard includeAttachments else {
      throw CLIError(
        code: .validationError,
        message: "Markdown package import requires `--include-attachments`.",
        details: ["path": url.path]
      )
    }
    return try markdownPackageSource(url: url)
  }

  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound, message: "Markdown file was not found.", details: ["path": url.path])
  }

  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError, message: "`--file` must reference a regular Markdown file.",
      details: ["path": url.path])
  }
  guard ["md", "markdown"].contains(ext) else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must end in `.md`, `.markdown`, `.mdpkg`, or `.markdownpackage`.",
      details: ["path": url.path])
  }

  let data = try Data(contentsOf: url)
  guard data.count <= notesMarkdownImportMaxBytes else {
    throw CLIError(
      code: .validationError, message: "Markdown import files must be 1 MB or smaller.",
      details: ["path": url.path])
  }
  guard let body = String(data: data, encoding: .utf8) else {
    throw CLIError(
      code: .validationError, message: "Markdown import files must be UTF-8 text.",
      details: ["path": url.path])
  }
  guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    throw CLIError(
      code: .validationError, message: "Markdown import file must not be empty.",
      details: ["path": url.path])
  }
  let resources = includeAttachments
    ? try markdownExternalResourceSources(markdownURL: url, body: body)
    : []

  return NotesMarkdownSource(
    path: url.path,
    name: url.deletingPathExtension().lastPathComponent,
    byteCount: data.count,
    modifiedAt: attributes[.modificationDate] as? Date,
    body: body,
    semanticSummary: markdownSemanticSummary(body),
    isPackage: false,
    markdownRelativePath: nil,
    packageFileCount: nil,
    packageTotalByteCount: nil,
    packageTreeSHA256: nil,
    resources: resources
  )
}

func markdownPackageSource(url: URL) throws -> NotesMarkdownSource {
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "Markdown package was not found.",
      details: ["path": url.path]
    )
  }
  guard attributes[.type] as? FileAttributeType == .typeDirectory else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a Markdown package directory.",
      details: ["path": url.path]
    )
  }
  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "Markdown package is not readable.",
      details: ["path": url.path]
    )
  }

  let files = try readNotesMarkdownPackageImportFiles(at: url)
  guard !files.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package import requires at least one Markdown member.",
      details: ["path": url.path]
    )
  }
  guard files.count <= notesMarkdownPackageImportMaxFiles else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package import contains too many files.",
      details: ["path": url.path, "max_files": "\(notesMarkdownPackageImportMaxFiles)"]
    )
  }
  let totalByteCount = files.reduce(0) { $0 + $1.data.count }
  guard totalByteCount <= notesMarkdownPackageImportMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package import is too large.",
      details: ["path": url.path, "max_bytes": "\(notesMarkdownPackageImportMaxBytes)"]
    )
  }

  let markdownFiles = files.filter { file in
    ["md", "markdown"].contains(URL(fileURLWithPath: file.relativePath).pathExtension.lowercased())
  }
  guard markdownFiles.count == 1, let markdown = markdownFiles.first else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package import requires exactly one `.md` or `.markdown` member.",
      details: ["path": url.path, "markdown_file_count": "\(markdownFiles.count)"]
    )
  }
  guard !markdown.relativePath.hasPrefix("Resources/") else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package main Markdown member must not be inside `Resources/`.",
      details: ["path": markdown.relativePath]
    )
  }
  guard markdown.data.count <= notesMarkdownImportMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package main Markdown member must be 1 MB or smaller.",
      details: ["path": markdown.relativePath]
    )
  }
  guard let body = String(data: markdown.data, encoding: .utf8),
    !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package main Markdown member must be non-empty UTF-8 text.",
      details: ["path": markdown.relativePath]
    )
  }

  let resourceFiles = files.filter { $0.relativePath != markdown.relativePath }
  for file in resourceFiles {
    let components = file.relativePath.split(separator: "/").map(String.init)
    guard components.count == 2, components.first == "Resources" else {
      throw CLIError(
        code: .validationError,
        message: "Markdown package resources must be direct files under `Resources/`.",
        details: ["path": file.relativePath]
      )
    }
    guard file.data.count > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Markdown package resources must not be empty.",
        details: ["path": file.relativePath]
      )
    }
    guard file.data.count <= notesAttachmentAddMaxBytes else {
      throw CLIError(
        code: .validationError,
        message: "Markdown package resources must be 50 MB or smaller.",
        details: ["path": file.relativePath, "max_bytes": "\(notesAttachmentAddMaxBytes)"]
      )
    }
  }

  let resources = try resourceFiles.map { file in
    let filename = try normalizedNotesAttachmentFilename(
      URL(fileURLWithPath: file.relativePath).lastPathComponent
    )
    return NotesMarkdownResourceSource(
      relativePath: file.relativePath,
      sourcePath: notesMarkdownExportFileURL(root: url, relativePath: file.relativePath).path,
      filename: filename,
      byteCount: file.data.count,
      data: file.data
    )
  }

  let duplicateFilenames = Dictionary(grouping: resources, by: \.filename)
    .filter { $0.value.count > 1 }
    .keys
  guard duplicateFilenames.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Markdown package resources must have unique file names.",
      details: ["filenames_sha256": sha256Hex(duplicateFilenames.sorted().joined(separator: "\n"))]
    )
  }

  return NotesMarkdownSource(
    path: url.path,
    name: url.deletingPathExtension().lastPathComponent,
    byteCount: totalByteCount,
    modifiedAt: attributes[.modificationDate] as? Date,
    body: body,
    semanticSummary: markdownSemanticSummary(body),
    isPackage: true,
    markdownRelativePath: markdown.relativePath,
    packageFileCount: files.count,
    packageTotalByteCount: totalByteCount,
    packageTreeSHA256: notesMarkdownPackageTreeSHA256(files),
    resources: resources
  )
}

func markdownSemanticSummary(_ body: String) -> NotesMarkdownSemanticSummary {
  var headingCount = 0
  var unorderedListItemCount = 0
  var orderedListItemCount = 0
  var blockQuoteLineCount = 0
  var fencedCodeBlockCount = 0
  var inFence = false

  for line in body.components(separatedBy: .newlines) {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("```") || trimmed.hasPrefix("~~~") {
      if !inFence {
        fencedCodeBlockCount += 1
      }
      inFence.toggle()
      continue
    }
    guard !inFence else {
      continue
    }
    if markdownLineIsHeading(trimmed) {
      headingCount += 1
    }
    if markdownLineIsUnorderedListItem(trimmed) {
      unorderedListItemCount += 1
    }
    if markdownLineIsOrderedListItem(trimmed) {
      orderedListItemCount += 1
    }
    if trimmed.hasPrefix(">") {
      blockQuoteLineCount += 1
    }
  }

  let references = markdownInlineReferenceCounts(body)
  return NotesMarkdownSemanticSummary(
    headingCount: headingCount,
    unorderedListItemCount: unorderedListItemCount,
    orderedListItemCount: orderedListItemCount,
    blockQuoteLineCount: blockQuoteLineCount,
    fencedCodeBlockCount: fencedCodeBlockCount,
    inlineCodeSpanCount: max(0, countOccurrences("`", in: body) - fencedCodeBlockCount * 2) / 2,
    linkReferenceCount: references.links,
    imageReferenceCount: references.images,
    emphasizedSpanCount: countOccurrences("**", in: body) / 2 + countOccurrences("__", in: body) / 2
  )
}

private func markdownLineIsHeading(_ trimmed: String) -> Bool {
  guard let firstNonHash = trimmed.firstIndex(where: { $0 != "#" }) else {
    return false
  }
  let hashCount = trimmed[..<firstNonHash].count
  guard (1...6).contains(hashCount) else {
    return false
  }
  return trimmed[firstNonHash].isWhitespace
}

private func markdownLineIsUnorderedListItem(_ trimmed: String) -> Bool {
  guard trimmed.count >= 3, let first = trimmed.first else {
    return false
  }
  guard ["-", "*", "+"].contains(String(first)) else {
    return false
  }
  let next = trimmed[trimmed.index(after: trimmed.startIndex)]
  return next.isWhitespace
}

private func markdownLineIsOrderedListItem(_ trimmed: String) -> Bool {
  var digitCount = 0
  var index = trimmed.startIndex
  while index < trimmed.endIndex, trimmed[index].isNumber {
    digitCount += 1
    index = trimmed.index(after: index)
  }
  guard digitCount > 0, index < trimmed.endIndex, trimmed[index] == "." || trimmed[index] == ")" else {
    return false
  }
  let afterMarker = trimmed.index(after: index)
  return afterMarker < trimmed.endIndex && trimmed[afterMarker].isWhitespace
}

private func markdownInlineReferenceCounts(_ body: String) -> (links: Int, images: Int) {
  var links = 0
  var images = 0
  var index = body.startIndex
  while index < body.endIndex {
    let isImage = body[index] == "!" && body.index(after: index) < body.endIndex
      && body[body.index(after: index)] == "["
    let isLink = body[index] == "["
    guard isImage || isLink else {
      index = body.index(after: index)
      continue
    }
    let bracketStart = isImage ? body.index(after: index) : index
    guard let bracketEnd = body[bracketStart...].firstIndex(of: "]") else {
      index = body.index(after: index)
      continue
    }
    let parenStart = body.index(after: bracketEnd)
    guard parenStart < body.endIndex, body[parenStart] == "(",
      body[parenStart...].firstIndex(of: ")") != nil
    else {
      index = body.index(after: bracketEnd)
      continue
    }
    if isImage {
      images += 1
    } else {
      links += 1
    }
    index = body.index(after: parenStart)
  }
  return (links, images)
}

private func markdownInlineImageDestinations(_ body: String) -> [String] {
  var destinations: [String] = []
  var index = body.startIndex
  while index < body.endIndex {
    let next = body.index(after: index)
    guard body[index] == "!", next < body.endIndex, body[next] == "[" else {
      index = next
      continue
    }
    guard let bracketEnd = body[next...].firstIndex(of: "]") else {
      index = next
      continue
    }
    let parenStart = body.index(after: bracketEnd)
    guard parenStart < body.endIndex, body[parenStart] == "(",
      let parenEnd = body[parenStart...].firstIndex(of: ")")
    else {
      index = body.index(after: bracketEnd)
      continue
    }
    destinations.append(String(body[body.index(after: parenStart)..<parenEnd]))
    index = body.index(after: parenEnd)
  }
  return destinations
}

private func markdownExternalResourceSources(markdownURL: URL, body: String) throws -> [NotesMarkdownResourceSource] {
  let baseURL = markdownURL.deletingLastPathComponent().standardizedFileURL
  let basePath = baseURL.path
  let destinations = markdownInlineImageDestinations(body)
  var seenRelativePaths: Set<String> = []
  var resources: [NotesMarkdownResourceSource] = []

  for rawDestination in destinations {
    guard let resourcePath = try markdownLocalResourceReferencePath(rawDestination) else {
      continue
    }
    let candidate = baseURL.appendingPathComponent(resourcePath, isDirectory: false).standardizedFileURL
    guard candidate.path.hasPrefix(basePath + "/") else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resource references must stay under the Markdown file directory.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    let relativePath = String(candidate.path.dropFirst(basePath.count + 1))
    let normalizedRelativePath = try normalizedNotesMarkdownRelativePath(relativePath)
    guard seenRelativePaths.insert(normalizedRelativePath).inserted else {
      continue
    }
    let values: URLResourceValues
    do {
      values = try candidate.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isHiddenKey])
    } catch {
      throw CLIError(
        code: .notFound,
        message: "Markdown attachment resource was not found.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    guard values.isSymbolicLink != true else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resources do not allow symbolic links.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    guard values.isHidden != true else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resources do not allow hidden files.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    guard values.isRegularFile == true else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resources must be regular files.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    let data = try Data(contentsOf: candidate)
    guard !data.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resources must not be empty.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    guard data.count <= notesAttachmentAddMaxBytes else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resources must be 50 MB or smaller.",
        details: [
          "resource_reference_sha256": sha256Hex(rawDestination),
          "max_bytes": "\(notesAttachmentAddMaxBytes)",
        ]
      )
    }
    let filename = try normalizedNotesAttachmentFilename(candidate.lastPathComponent)
    resources.append(
      NotesMarkdownResourceSource(
        relativePath: normalizedRelativePath,
        sourcePath: candidate.path,
        filename: filename,
        byteCount: data.count,
        data: data
      ))
  }

  let duplicateFilenames = Dictionary(grouping: resources, by: \.filename)
    .filter { $0.value.count > 1 }
    .keys
  guard duplicateFilenames.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Markdown attachment resources must have unique file names.",
      details: ["filenames_sha256": sha256Hex(duplicateFilenames.sorted().joined(separator: "\n"))]
    )
  }
  return resources
}

private func markdownLocalResourceReferencePath(_ rawDestination: String) throws -> String? {
  let trimmed = rawDestination.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    return nil
  }
  let destination: String
  if trimmed.hasPrefix("<") {
    guard let end = trimmed.firstIndex(of: ">"), end > trimmed.startIndex else {
      throw CLIError(
        code: .validationError,
        message: "Markdown attachment resource references must use valid local relative paths.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    destination = String(trimmed[trimmed.index(after: trimmed.startIndex)..<end])
  } else {
    destination = String(trimmed.prefix { !$0.isWhitespace })
  }
  let decoded = destination.removingPercentEncoding ?? destination
  guard !decoded.isEmpty, decoded != "#" else {
    return nil
  }
  guard decoded.hasPrefix("#") == false,
    decoded.hasPrefix("/") == false,
    decoded.hasPrefix("//") == false,
    decoded.contains("?") == false,
    decoded.contains("#") == false,
    URL(string: decoded)?.scheme == nil
  else {
    throw CLIError(
      code: .validationError,
      message: "Markdown attachment resource references must be local relative file paths.",
      details: ["resource_reference_sha256": sha256Hex(rawDestination)]
    )
  }
  return decoded
}

private func countOccurrences(_ needle: String, in haystack: String) -> Int {
  guard !needle.isEmpty else {
    return 0
  }
  var count = 0
  var searchRange = haystack.startIndex..<haystack.endIndex
  while let range = haystack.range(of: needle, range: searchRange) {
    count += 1
    searchRange = range.upperBound..<haystack.endIndex
  }
  return count
}

func readNotesMarkdownPackageImportFiles(at packageURL: URL) throws -> [NotesNoteMarkdownExportFile] {
  let root = packageURL.standardizedFileURL
  let resourceKeys: Set<URLResourceKey> = [.isRegularFileKey, .isSymbolicLinkKey, .isHiddenKey]
  guard
    let enumerator = FileManager.default.enumerator(
      at: root,
      includingPropertiesForKeys: Array(resourceKeys),
      options: [],
      errorHandler: nil
    )
  else {
    return []
  }

  var files: [NotesNoteMarkdownExportFile] = []
  for case let fileURL as URL in enumerator {
    let values = try fileURL.resourceValues(forKeys: resourceKeys)
    if values.isHidden == true {
      continue
    }
    guard values.isSymbolicLink != true else {
      throw CLIError(
        code: .validationError,
        message: "Markdown package import does not allow symbolic links.",
        details: ["path": fileURL.path]
      )
    }
    guard values.isRegularFile == true else {
      continue
    }
    let standardized = fileURL.standardizedFileURL
    let relativePath = String(standardized.path.dropFirst(root.path.count + 1))
    let normalizedRelativePath = try normalizedNotesMarkdownRelativePath(relativePath)
    files.append(
      NotesNoteMarkdownExportFile(
        relativePath: normalizedRelativePath,
        data: try Data(contentsOf: standardized)
      )
    )
  }
  return try normalizedNotesMarkdownExportFiles(files)
    .sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
}

func readNotesHTMLPackageImportFiles(at packageURL: URL) throws -> [NotesNoteHTMLExportFile] {
  let root = packageURL.standardizedFileURL
  let resourceKeys: Set<URLResourceKey> = [.isRegularFileKey, .isSymbolicLinkKey, .isHiddenKey]
  guard
    let enumerator = FileManager.default.enumerator(
      at: root,
      includingPropertiesForKeys: Array(resourceKeys),
      options: [],
      errorHandler: nil
    )
  else {
    return []
  }

  var files: [NotesNoteHTMLExportFile] = []
  for case let fileURL as URL in enumerator {
    let values = try fileURL.resourceValues(forKeys: resourceKeys)
    if values.isHidden == true {
      continue
    }
    guard values.isSymbolicLink != true else {
      throw CLIError(
        code: .validationError,
        message: "HTML package import does not allow symbolic links.",
        details: ["path": fileURL.path]
      )
    }
    guard values.isRegularFile == true else {
      continue
    }
    let standardized = fileURL.standardizedFileURL
    let relativePath = String(standardized.path.dropFirst(root.path.count + 1))
    let normalizedRelativePath = try normalizedNotesHTMLRelativePath(relativePath)
    files.append(
      NotesNoteHTMLExportFile(
        relativePath: normalizedRelativePath,
        data: try Data(contentsOf: standardized)
      )
    )
  }
  return try normalizedNotesHTMLExportFiles(files)
    .sorted { $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending }
}

func textImportSource(path: String) throws -> NotesTextSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(code: .notFound, message: "Text import file was not found.", details: ["path": url.path])
  }

  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a regular text file.",
      details: ["path": url.path])
  }
  guard url.pathExtension.lowercased() == "txt" else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must end in `.txt` for text import.",
      details: ["path": url.path])
  }

  let data = try Data(contentsOf: url)
  guard data.count <= 1_000_000 else {
    throw CLIError(
      code: .validationError,
      message: "Text import files must be 1 MB or smaller.",
      details: ["path": url.path])
  }
  guard let body = String(data: data, encoding: .utf8) else {
    throw CLIError(
      code: .validationError,
      message: "Text import files must be UTF-8 text.",
      details: ["path": url.path])
  }
  guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Text import file must not be empty.",
      details: ["path": url.path])
  }

  return NotesTextSource(
    path: url.path,
    name: url.deletingPathExtension().lastPathComponent,
    byteCount: data.count,
    modifiedAt: attributes[.modificationDate] as? Date,
    body: body
  )
}

func richImportSource(
  path: String,
  format: NotesRichImportFormat,
  includeAttachments: Bool = false
) throws -> NotesRichImportSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "Rich Notes import file was not found.",
      details: ["path": url.path]
    )
  }

  switch format {
  case .rtf:
    return try richImportRegularFileSource(
      url: url,
      attributes: attributes,
      format: format,
      allowedExtensions: ["rtf"],
      expectedDescription: "RTF"
    )
  case .html:
    let ext = url.pathExtension.lowercased()
    if ["htmlpkg", "htmlpackage"].contains(ext) {
      guard includeAttachments else {
        throw CLIError(
          code: .validationError,
          message: "HTML package import requires `--include-attachments`.",
          details: ["path": url.path]
        )
      }
      return try richHTMLPackageSource(url: url, attributes: attributes)
    }
    guard !includeAttachments else {
      throw CLIError(
        code: .validationError,
        message: "`--include-attachments` is only valid for `.htmlpkg` or `.htmlpackage` HTML imports.",
        details: ["path": url.path]
      )
    }
    return try richImportRegularFileSource(
      url: url,
      attributes: attributes,
      format: format,
      allowedExtensions: ["html", "htm"],
      expectedDescription: "HTML"
    )
  case .rtfd:
    guard attributes[.type] as? FileAttributeType == .typeDirectory else {
      throw CLIError(
        code: .validationError,
        message: "`--file` must reference an RTFD package directory.",
        details: ["path": url.path]
      )
    }
    guard url.pathExtension.lowercased() == "rtfd" else {
      throw CLIError(
        code: .validationError,
        message: "`--file` must end in `.rtfd` for RTFD import.",
        details: ["path": url.path]
      )
    }
    guard FileManager.default.isReadableFile(atPath: url.path) else {
      throw CLIError(
        code: .permissionDenied,
        message: "RTFD import package is not readable.",
        details: ["path": url.path]
      )
    }
    let files = try readNotesRTFDExportFiles(at: url.path)
    guard !files.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "RTFD import package must contain at least one file.",
        details: ["path": url.path]
      )
    }
    guard files.count <= notesRichImportPackageMaxFiles else {
      throw CLIError(
        code: .validationError,
        message: "RTFD import package contains too many files.",
        details: ["path": url.path, "max_files": "\(notesRichImportPackageMaxFiles)"]
      )
    }
    let totalByteCount = notesRTFDTotalByteCount(files)
    guard totalByteCount <= notesRichImportPackageMaxBytes else {
      throw CLIError(
        code: .validationError,
        message: "RTFD import package is too large.",
        details: ["path": url.path, "max_bytes": "\(notesRichImportPackageMaxBytes)"]
      )
    }
    guard notesRTFDContainsRTFFile(files) else {
      throw CLIError(
        code: .validationError,
        message: "RTFD import package must contain an RTF member.",
        details: ["path": url.path]
      )
    }
    return NotesRichImportSource(
      path: url.path,
      name: url.deletingPathExtension().lastPathComponent,
      byteCount: totalByteCount,
      modifiedAt: attributes[.modificationDate] as? Date,
      format: format,
      data: nil,
      htmlRelativePath: nil,
      packageFileCount: files.count,
      packageResourceFileCount: notesRTFDResourceFileCount(files),
      packageTotalByteCount: totalByteCount,
      packageTreeSHA256: notesRTFDTreeSHA256(files),
      resources: []
    )
  }
}

private func richHTMLPackageSource(
  url: URL,
  attributes: [FileAttributeKey: Any]
) throws -> NotesRichImportSource {
  guard attributes[.type] as? FileAttributeType == .typeDirectory else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference an HTML package directory.",
      details: ["path": url.path]
    )
  }
  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "HTML package is not readable.",
      details: ["path": url.path]
    )
  }

  let files = try readNotesHTMLPackageImportFiles(at: url)
  guard !files.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "HTML package import requires at least one HTML member.",
      details: ["path": url.path]
    )
  }
  guard files.count <= notesRichImportPackageMaxFiles else {
    throw CLIError(
      code: .validationError,
      message: "HTML package import contains too many files.",
      details: ["path": url.path, "max_files": "\(notesRichImportPackageMaxFiles)"]
    )
  }
  let totalByteCount = notesHTMLPackageTotalByteCount(files)
  guard totalByteCount <= notesRichImportPackageMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "HTML package import is too large.",
      details: ["path": url.path, "max_bytes": "\(notesRichImportPackageMaxBytes)"]
    )
  }

  let htmlFiles = files.filter { file in
    ["html", "htm"].contains(URL(fileURLWithPath: file.relativePath).pathExtension.lowercased())
  }
  guard htmlFiles.count == 1, let html = htmlFiles.first else {
    throw CLIError(
      code: .validationError,
      message: "HTML package import requires exactly one `.html` or `.htm` member.",
      details: ["path": url.path, "html_file_count": "\(htmlFiles.count)"]
    )
  }
  guard !html.relativePath.hasPrefix("Resources/") else {
    throw CLIError(
      code: .validationError,
      message: "HTML package main HTML member must not be inside `Resources/`.",
      details: ["path": html.relativePath]
    )
  }
  guard html.data.count <= notesRichImportMaxBytes, notesHTMLDataHasMarker(html.data) else {
    throw CLIError(
      code: .validationError,
      message: "HTML package main HTML member must be a non-empty HTML file 25 MB or smaller.",
      details: ["path": html.relativePath, "max_bytes": "\(notesRichImportMaxBytes)"]
    )
  }

  let resourceFiles = files.filter { $0.relativePath != html.relativePath }
  for file in resourceFiles {
    let components = file.relativePath.split(separator: "/").map(String.init)
    guard components.count == 2, components.first == "Resources" else {
      throw CLIError(
        code: .validationError,
        message: "HTML package resources must be direct files under `Resources/`.",
        details: ["path": file.relativePath]
      )
    }
    guard file.data.count > 0 else {
      throw CLIError(
        code: .validationError,
        message: "HTML package resources must not be empty.",
        details: ["path": file.relativePath]
      )
    }
    guard file.data.count <= notesAttachmentAddMaxBytes else {
      throw CLIError(
        code: .validationError,
        message: "HTML package resources must be 50 MB or smaller.",
        details: ["path": file.relativePath, "max_bytes": "\(notesAttachmentAddMaxBytes)"]
      )
    }
  }

  let resources = try resourceFiles.map { file in
    let filename = try normalizedNotesAttachmentFilename(
      URL(fileURLWithPath: file.relativePath).lastPathComponent
    )
    return NotesRichImportResourceSource(
      relativePath: file.relativePath,
      sourcePath: notesHTMLExportFileURL(root: url, relativePath: file.relativePath).path,
      filename: filename,
      byteCount: file.data.count,
      data: file.data
    )
  }
  let duplicateFilenames = Dictionary(grouping: resources, by: \.filename)
    .filter { $0.value.count > 1 }
    .keys
  guard duplicateFilenames.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "HTML package resources must have unique file names.",
      details: ["filenames_sha256": sha256Hex(duplicateFilenames.sorted().joined(separator: "\n"))]
    )
  }

  return NotesRichImportSource(
    path: url.path,
    name: url.deletingPathExtension().lastPathComponent,
    byteCount: totalByteCount,
    modifiedAt: attributes[.modificationDate] as? Date,
    format: .html,
    data: html.data,
    htmlRelativePath: html.relativePath,
    packageFileCount: files.count,
    packageResourceFileCount: resourceFiles.count,
    packageTotalByteCount: totalByteCount,
    packageTreeSHA256: notesHTMLPackageTreeSHA256(files),
    resources: resources
  )
}

private func richImportRegularFileSource(
  url: URL,
  attributes: [FileAttributeKey: Any],
  format: NotesRichImportFormat,
  allowedExtensions: Set<String>,
  expectedDescription: String
) throws -> NotesRichImportSource {
  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a regular \(expectedDescription) file.",
      details: ["path": url.path]
    )
  }
  guard allowedExtensions.contains(url.pathExtension.lowercased()) else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must end in \(allowedExtensions.sorted().map { ".\($0)" }.joined(separator: " or ")) for \(expectedDescription) import.",
      details: ["path": url.path]
    )
  }
  let data = try Data(contentsOf: url)
  guard !data.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "\(expectedDescription) import file must not be empty.",
      details: ["path": url.path]
    )
  }
  guard data.count <= notesRichImportMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "\(expectedDescription) import files must be 25 MB or smaller.",
      details: ["path": url.path, "max_bytes": "\(notesRichImportMaxBytes)"]
    )
  }
  return NotesRichImportSource(
    path: url.path,
    name: url.deletingPathExtension().lastPathComponent,
    byteCount: data.count,
    modifiedAt: attributes[.modificationDate] as? Date,
    format: format,
    data: data,
    htmlRelativePath: nil,
    packageFileCount: nil,
    packageResourceFileCount: nil,
    packageTotalByteCount: nil,
    packageTreeSHA256: nil,
    resources: []
  )
}

func notesAttachmentAddFileSource(path: String, name: String?) throws -> NotesAttachmentAddFileSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "Attachment source file was not found.",
      details: ["path": url.path]
    )
  }

  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a regular attachment file.",
      details: ["path": url.path]
    )
  }
  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "Attachment source file is not readable.",
      details: ["path": url.path]
    )
  }

  let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
  guard size > 0 else {
    throw CLIError(
      code: .validationError,
      message: "Attachment source file must not be empty.",
      details: ["path": url.path]
    )
  }
  guard size <= notesAttachmentAddMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "Attachment source file must be 50 MB or smaller.",
      details: ["path": url.path, "max_bytes": "\(notesAttachmentAddMaxBytes)"]
    )
  }

  let data = try Data(contentsOf: url)
  guard data.count == size else {
    throw CLIError(
      code: .validationError,
      message: "Attachment source file changed while being read.",
      details: ["path": url.path]
    )
  }

  let filename = try normalizedNotesAttachmentFilename(name ?? url.lastPathComponent)
  return NotesAttachmentAddFileSource(
    path: url.path,
    filename: filename,
    byteCount: data.count,
    modifiedAt: attributes[.modificationDate] as? Date,
    data: data
  )
}

func notesAttachmentAddFileSources(paths: [String], name: String?) throws -> [NotesAttachmentAddFileSource] {
  guard !paths.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`attachments add` requires at least one attachment source file."
    )
  }
  guard paths.count <= notesAttachmentAddBatchMaxFiles else {
    throw CLIError(
      code: .validationError,
      message: "`attachments add --files` is bounded to 32 files per command.",
      details: [
        "file_count": "\(paths.count)",
        "max_files": "\(notesAttachmentAddBatchMaxFiles)",
      ]
    )
  }
  guard name == nil || paths.count == 1 else {
    throw CLIError(
      code: .validationError,
      message: "`--name` is only supported when adding one attachment file."
    )
  }

  var seenPaths = Set<String>()
  var sources: [NotesAttachmentAddFileSource] = []
  for path in paths {
    let source = try notesAttachmentAddFileSource(path: path, name: name)
    guard seenPaths.insert(source.path).inserted else {
      throw CLIError(
        code: .validationError,
        message: "`attachments add --files` must not repeat the same source path.",
        details: ["path": source.path]
      )
    }
    sources.append(source)
  }

  let totalBytes = sources.reduce(0) { $0 + $1.byteCount }
  guard totalBytes <= notesAttachmentAddBatchMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "`attachments add --files` is bounded to 250 MB per command.",
      details: [
        "total_byte_count": "\(totalBytes)",
        "max_bytes": "\(notesAttachmentAddBatchMaxBytes)",
      ]
    )
  }
  return sources
}

func notesAttachmentAddFileList(_ raw: String) throws -> [String] {
  let paths = raw.split(separator: ",", omittingEmptySubsequences: false)
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  guard paths.allSatisfy({ !$0.isEmpty }) else {
    throw CLIError(
      code: .validationError,
      message: "`--files` must contain comma-separated non-empty paths."
    )
  }
  return paths
}

func notesAttachmentMarkupModelSource(path: String) throws -> NotesAttachmentMarkupModelSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "Markup model source file was not found.",
      details: ["path": url.path]
    )
  }

  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a regular Markup model file.",
      details: ["path": url.path]
    )
  }
  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "Markup model source file is not readable.",
      details: ["path": url.path]
    )
  }

  let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
  guard size > 0 else {
    throw CLIError(
      code: .validationError,
      message: "Markup model source file must not be empty.",
      details: ["path": url.path]
    )
  }
  guard size <= notesAttachmentMarkupModelMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "Markup model source file must be 50 MB or smaller.",
      details: ["path": url.path, "max_bytes": "\(notesAttachmentMarkupModelMaxBytes)"]
    )
  }

  let data = try Data(contentsOf: url)
  guard data.count == size else {
    throw CLIError(
      code: .validationError,
      message: "Markup model source file changed while being read.",
      details: ["path": url.path]
    )
  }

  return NotesAttachmentMarkupModelSource(
    path: url.path,
    byteCount: data.count,
    modifiedAt: attributes[.modificationDate] as? Date,
    data: data
  )
}

func normalizedNotesAttachmentFilename(_ value: String) throws -> String {
  let filename = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !filename.isEmpty else {
    throw CLIError(code: .validationError, message: "`--name` must not be empty.")
  }
  guard filename != "." && filename != ".." else {
    throw CLIError(code: .validationError, message: "`--name` must be a file name, not a relative path.")
  }
  guard filename.rangeOfCharacter(from: CharacterSet(charactersIn: "/\\")) == nil else {
    throw CLIError(code: .validationError, message: "`--name` must not contain path separators.")
  }
  return filename
}

func markdownTitle(_ source: NotesMarkdownSource) -> String {
  for line in source.body.components(separatedBy: .newlines) {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("# ") {
      let title = trimmed.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
      if !title.isEmpty {
        return title
      }
    }
  }

  return source.name.isEmpty ? "Imported Markdown" : source.name
}

func textImportTitle(_ source: NotesTextSource) -> String {
  source.name.isEmpty ? "Imported Text" : source.name
}

func richImportTitle(_ source: NotesRichImportSource) -> String {
  if !source.name.isEmpty {
    return source.name
  }
  switch source.format {
  case .rtf:
    return "Imported RTF"
  case .rtfd:
    return "Imported RTFD"
  case .html:
    return "Imported HTML"
  }
}

func enexImportSource(path: String) throws -> NotesENEXImportSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "ENEX import file was not found.",
      details: ["path_sha256": sha256Hex(url.path)]
    )
  }

  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError,
      message: "`--file` must reference a regular `.enex` file for ENEX import.",
      details: ["path_sha256": sha256Hex(url.path)]
    )
  }
  guard url.pathExtension.lowercased() == "enex" else {
    throw CLIError(code: .validationError, message: "`--file` must end in `.enex` for ENEX import.")
  }
  guard FileManager.default.isReadableFile(atPath: url.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "ENEX import file is not readable.",
      details: ["path_sha256": sha256Hex(url.path)]
    )
  }

  let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
  guard size > 0 else {
    throw CLIError(code: .validationError, message: "ENEX import file must not be empty.")
  }
  guard size <= notesENEXImportMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "ENEX import files must be 100 MB or smaller.",
      details: ["max_bytes": "\(notesENEXImportMaxBytes)"]
    )
  }

  let data = try Data(contentsOf: url)
  guard data.count == size else {
    throw CLIError(
      code: .validationError,
      message: "ENEX import file changed while being read.",
      details: ["path_sha256": sha256Hex(url.path)]
    )
  }

  let notes = try parseNotesENEX(data: data)
  guard !notes.isEmpty else {
    throw CLIError(code: .validationError, message: "ENEX import file did not contain any notes.")
  }
  guard notes.count <= notesENEXImportMaxNotes else {
    throw CLIError(
      code: .validationError,
      message: "ENEX import is bounded to 500 notes per command.",
      details: ["note_count": "\(notes.count)", "max_notes": "\(notesENEXImportMaxNotes)"]
    )
  }
  if let note = notes.first(where: { $0.tags.count > notesENEXImportMaxTagsPerNote }) {
    throw CLIError(
      code: .validationError,
      message: "ENEX import is bounded to 64 tags per note.",
      details: [
        "note_ordinal": "\(note.ordinal)",
        "tag_count": "\(note.tags.count)",
        "max_tags_per_note": "\(notesENEXImportMaxTagsPerNote)",
      ]
    )
  }
  guard notes.reduce(0, { $0 + $1.resourceCount }) <= notesENEXImportMaxResources else {
    throw CLIError(
      code: .validationError,
      message: "ENEX import is bounded to 512 resources per command.",
      details: [
        "resource_count": "\(notes.reduce(0) { $0 + $1.resourceCount })",
        "max_resources": "\(notesENEXImportMaxResources)",
      ]
    )
  }
  if let duplicate = notes.compactMap(notesENEXDuplicateResourceFilename).first {
    throw CLIError(
      code: .validationError,
      message: "ENEX resources in one note must have unique attachment file names.",
      details: [
        "note_ordinal": "\(duplicate.noteOrdinal)",
        "filename_sha256": sha256Hex(duplicate.filename),
      ]
    )
  }

  return NotesENEXImportSource(
    path: url.path,
    name: url.deletingPathExtension().lastPathComponent,
    byteCount: data.count,
    modifiedAt: attributes[.modificationDate] as? Date,
    dataSHA256: sha256Hex(data),
    notes: notes
  )
}

func enexImportScopeDigest(_ importDraft: NotesENEXImportDraft) -> String {
  let fields = [
    importDraft.folderID,
    importDraft.folderName,
    importDraft.accountName,
    importDraft.source.path,
    "\(importDraft.source.byteCount)",
    importDraft.source.modifiedAt.map(formatDate) ?? "",
    importDraft.source.dataSHA256,
    "\(importDraft.source.noteCount)",
    "\(importDraft.source.resourceCount)",
    "\(importDraft.source.resourceByteCount)",
    "\(importDraft.source.tagCount)",
    "\(importDraft.source.unsupportedTagCount)",
    "\(importDraft.source.normalizedTagCount)",
    importDraft.source.notes
      .flatMap { note in
        note.tags.map {
          "\(note.ordinal):\(sha256Hex($0)):\(notesENEXNormalizedTagText($0) ?? "")"
        }
      }
      .joined(separator: ","),
    "\(importDraft.source.inlineResourceReferenceCount)",
    "\(importDraft.source.matchedInlineResourceReferenceCount)",
    "\(importDraft.source.unmatchedInlineResourceReferenceCount)",
    importDraft.source.notes.map { "\($0.ordinal):\($0.titleSHA256):\($0.contentSHA256)" }
      .joined(separator: ","),
    importDraft.source.notes
      .flatMap { note in
        note.inlineResourceReferences.map {
          "\(note.ordinal):\($0.ordinal):\($0.resourceDataMD5 ?? ""):\($0.matchedResourceOrdinal ?? 0)"
        }
      }
      .joined(separator: ","),
    importDraft.source.notes
      .flatMap { note in note.resources.map { "\(note.ordinal):\($0.ordinal):\($0.filename):\($0.dataSHA256)" } }
      .joined(separator: ","),
  ]
  return "notes-import-enex:\(sha256Hex(fields.joined(separator: "|")))"
}

func enexImportSummary(_ importDraft: NotesENEXImportDraft) -> [String: String] {
  [
    "folder_id": importDraft.folderID,
    "folder": importDraft.folderName,
    "account": importDraft.accountName,
    "source_path_sha256": sha256Hex(importDraft.source.path),
    "source_name_sha256": sha256Hex(importDraft.source.name),
    "source_byte_count": "\(importDraft.source.byteCount)",
    "source_sha256": importDraft.source.dataSHA256,
    "note_count": "\(importDraft.source.noteCount)",
    "resource_count": "\(importDraft.source.resourceCount)",
    "resource_byte_count": "\(importDraft.source.resourceByteCount)",
    "tag_count": "\(importDraft.source.tagCount)",
    "unique_tag_count": "\(importDraft.source.uniqueTagCount)",
    "normalized_tag_count": "\(importDraft.source.normalizedTagCount)",
    "unsupported_tag_count": "\(importDraft.source.unsupportedTagCount)",
    "created_date_count": "\(importDraft.source.createdDateCount)",
    "updated_date_count": "\(importDraft.source.updatedDateCount)",
    "inline_resource_reference_count": "\(importDraft.source.inlineResourceReferenceCount)",
    "matched_inline_resource_reference_count": "\(importDraft.source.matchedInlineResourceReferenceCount)",
    "unmatched_inline_resource_reference_count": "\(importDraft.source.unmatchedInlineResourceReferenceCount)",
  ]
}

func validateExecutableENEXImport(_ source: NotesENEXImportSource) throws {
  guard source.unsupportedTagCount == 0 else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "ENEX import contains tags that cannot be normalized to Notes tag text.",
      details: [
        "unsupported_tag_count": "\(source.unsupportedTagCount)",
        "source_path_sha256": sha256Hex(source.path),
      ]
    )
  }
  guard source.unmatchedInlineResourceReferenceCount == 0 else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "ENEX import with unmatched inline resource references remains gated until resource placement preservation is verified.",
      details: [
        "unmatched_inline_resource_reference_count": "\(source.unmatchedInlineResourceReferenceCount)",
        "source_path_sha256": sha256Hex(source.path),
      ]
    )
  }
}

func notesENEXNormalizedTagText(_ tag: String) -> String? {
  let withoutPrefix = tag.hasPrefix("#") ? String(tag.dropFirst()) : tag
  let parts = withoutPrefix
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: .whitespacesAndNewlines)
    .filter { !$0.isEmpty }
  guard !parts.isEmpty else {
    return nil
  }
  return parts.joined(separator: "-").localizedLowercase
}

func notesENEXTagRequiresNormalization(_ tag: String) -> Bool {
  guard let normalized = notesENEXNormalizedTagText(tag) else {
    return true
  }
  return standardizedTagContent(tag) != normalized
}

func notesENEXTagIsUnsupported(_ tag: String) -> Bool {
  notesENEXNormalizedTagText(tag) == nil
}

private func parseNotesENEX(data: Data) throws -> [NotesENEXImportNoteSource] {
  let delegate = NotesENEXParserDelegate()
  let parser = XMLParser(data: data)
  parser.delegate = delegate
  parser.shouldResolveExternalEntities = false
  guard parser.parse() else {
    throw CLIError(
      code: .validationError, message: "ENEX XML could not be parsed.",
      details: ["line": "\(parser.lineNumber)", "column": "\(parser.columnNumber)"])
  }
  return try delegate.notes.enumerated().map { index, note in
    let ordinal = index + 1
    let resources = try note.resources.enumerated().map { resourceIndex, resource in
      try notesENEXResourceSource(
        resource,
        noteOrdinal: ordinal,
        resourceOrdinal: resourceIndex + 1
      )
    }
    let inlineResourceReferences = notesENEXMediaReferences(
      content: note.content,
      resources: resources
    )
    return NotesENEXImportNoteSource(
      ordinal: ordinal,
      title: note.title.isEmpty ? "Imported ENEX Note \(ordinal)" : note.title,
      content: note.content,
      tags: note.tags,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      resources: resources,
      inlineResourceReferences: inlineResourceReferences
    )
  }
}

private struct NotesENEXParsedResource {
  var mimeType = ""
  var filename = ""
  var dataBase64 = ""
}

private struct NotesENEXParsedNote {
  var title = ""
  var content = ""
  var tags: [String] = []
  var createdAt: Date?
  var updatedAt: Date?
  var resources: [NotesENEXParsedResource] = []
}

private final class NotesENEXParserDelegate: NSObject, XMLParserDelegate {
  private var currentNote: NotesENEXParsedNote?
  private var currentResource: NotesENEXParsedResource?
  private var elementStack: [String] = []
  private var textBuffer = ""
  private(set) var notes: [NotesENEXParsedNote] = []

  func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    let element = elementName.lowercased()
    elementStack.append(element)
    textBuffer.removeAll(keepingCapacity: true)
    if element == "note" {
      currentNote = NotesENEXParsedNote()
    } else if element == "resource", currentNote != nil {
      currentResource = NotesENEXParsedResource()
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    textBuffer.append(string)
  }

  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    if let string = String(data: CDATABlock, encoding: .utf8) {
      textBuffer.append(string)
    }
  }

  func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?
  ) {
    let element = elementName.lowercased()
    defer {
      _ = elementStack.popLast()
      textBuffer.removeAll(keepingCapacity: true)
    }

    guard var note = currentNote else {
      return
    }

    let value = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
    switch element {
    case "title":
      note.title = value
    case "content":
      note.content = value
    case "tag":
      if !value.isEmpty {
        note.tags.append(value)
      }
    case "created":
      note.createdAt = notesENEXDate(value)
    case "updated":
      note.updatedAt = notesENEXDate(value)
    case "mime":
      if currentResource != nil {
        currentResource?.mimeType = value
      }
    case "data":
      if currentResource != nil {
        currentResource?.dataBase64 += value
      }
    case "file-name":
      if currentResource != nil {
        currentResource?.filename = value
      }
    case "resource":
      if let currentResource {
        note.resources.append(currentResource)
      }
      self.currentResource = nil
    case "note":
      notes.append(note)
      currentNote = nil
      return
    default:
      break
    }
    currentNote = note
  }
}

private func notesENEXResourceSource(
  _ resource: NotesENEXParsedResource,
  noteOrdinal: Int,
  resourceOrdinal: Int
) throws -> NotesENEXResourceSource {
  let compactBase64 = resource.dataBase64.filter { !$0.isWhitespace }
  guard !compactBase64.isEmpty, let data = Data(base64Encoded: compactBase64) else {
    throw CLIError(
      code: .validationError,
      message: "ENEX resource data must be base64 encoded.",
      details: ["note_ordinal": "\(noteOrdinal)", "resource_ordinal": "\(resourceOrdinal)"]
    )
  }
  guard !data.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "ENEX resource data must not be empty.",
      details: ["note_ordinal": "\(noteOrdinal)", "resource_ordinal": "\(resourceOrdinal)"]
    )
  }
  guard data.count <= notesAttachmentAddMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "ENEX resources must be 50 MB or smaller.",
      details: [
        "note_ordinal": "\(noteOrdinal)",
        "resource_ordinal": "\(resourceOrdinal)",
        "max_bytes": "\(notesAttachmentAddMaxBytes)",
      ]
    )
  }

  let filename = try normalizedNotesAttachmentFilename(
    notesENEXResourceFilename(
      resource.filename,
      mimeType: resource.mimeType,
      noteOrdinal: noteOrdinal,
      resourceOrdinal: resourceOrdinal
    ))
  return NotesENEXResourceSource(
    ordinal: resourceOrdinal,
    filename: filename,
    mimeType: notesENEXOptionalText(resource.mimeType),
    byteCount: data.count,
    dataSHA256: sha256Hex(data),
    dataMD5: md5Hex(data),
    data: data
  )
}

private func notesENEXMediaReferences(
  content: String,
  resources: [NotesENEXResourceSource]
) -> [NotesENEXMediaReferenceSource] {
  let resourceOrdinalsByMD5 = Dictionary(grouping: resources, by: \.dataMD5)
    .mapValues { $0.map(\.ordinal) }
  let pattern = #"(?is)<en-media\b([^>]*)/?>"#
  guard let regex = try? NSRegularExpression(pattern: pattern) else {
    return []
  }
  let range = NSRange(location: 0, length: (content as NSString).length)
  return regex.matches(in: content, range: range).enumerated().map { index, match in
    let attributes = (content as NSString).substring(with: match.range(at: 1))
    let dataMD5 = notesENEXMediaAttribute("hash", in: attributes).flatMap(notesENEXMediaHash)
    let mimeType = notesENEXMediaAttribute("type", in: attributes).flatMap(notesENEXOptionalText)
    let matchedResourceOrdinal = dataMD5.flatMap { hash -> Int? in
      let ordinals = resourceOrdinalsByMD5[hash] ?? []
      return ordinals.count == 1 ? ordinals[0] : nil
    }
    return NotesENEXMediaReferenceSource(
      ordinal: index + 1,
      resourceDataMD5: dataMD5,
      mimeType: mimeType,
      matchedResourceOrdinal: matchedResourceOrdinal
    )
  }
}

private func notesENEXMediaAttribute(_ name: String, in attributes: String) -> String? {
  let escapedName = NSRegularExpression.escapedPattern(for: name)
  let pattern = #"(?is)\b"# + escapedName + #"\s*=\s*(['"])(.*?)\1"#
  guard let regex = try? NSRegularExpression(pattern: pattern) else {
    return nil
  }
  let range = NSRange(location: 0, length: (attributes as NSString).length)
  guard let match = regex.firstMatch(in: attributes, range: range), match.range(at: 2).location != NSNotFound else {
    return nil
  }
  return (attributes as NSString).substring(with: match.range(at: 2))
}

private func notesENEXMediaHash(_ value: String) -> String? {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  guard trimmed.count == 32, trimmed.allSatisfy(\.isHexDigit) else {
    return nil
  }
  return trimmed
}

private func notesENEXDuplicateResourceFilename(
  _ note: NotesENEXImportNoteSource
) -> (noteOrdinal: Int, filename: String)? {
  var seen: Set<String> = []
  for resource in note.resources {
    let key = resource.filename.localizedLowercase
    if seen.contains(key) {
      return (note.ordinal, resource.filename)
    }
    seen.insert(key)
  }
  return nil
}

private func notesENEXOptionalText(_ value: String) -> String? {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  return trimmed.isEmpty ? nil : trimmed
}

private func notesENEXResourceFilename(
  _ value: String,
  mimeType: String,
  noteOrdinal: Int,
  resourceOrdinal: Int
) -> String {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  if !trimmed.isEmpty {
    return trimmed
  }
  let ext = notesENEXResourceExtension(mimeType)
  return "enex-note-\(noteOrdinal)-resource-\(resourceOrdinal)\(ext.map { ".\($0)" } ?? "")"
}

private func notesENEXResourceExtension(_ mimeType: String) -> String? {
  switch mimeType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
  case "image/jpeg", "image/jpg":
    return "jpg"
  case "image/png":
    return "png"
  case "image/gif":
    return "gif"
  case "image/tiff":
    return "tiff"
  case "application/pdf":
    return "pdf"
  case "text/plain":
    return "txt"
  case "text/html":
    return "html"
  case "audio/mpeg":
    return "mp3"
  case "audio/mp4", "audio/x-m4a":
    return "m4a"
  default:
    return nil
  }
}

private func notesENEXDate(_ value: String) -> Date? {
  guard !value.isEmpty else {
    return nil
  }
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
  return formatter.date(from: value)
}

func folderImportSource(path: String) throws -> NotesFolderImportSource {
  let absolutePath = standardizedAbsolutePath(path)
  let root = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let rootExtension = root.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  guard !["rtfd", "mdpkg", "markdownpackage"].contains(rootExtension) else {
    throw CLIError(
      code: .validationError,
      message: "`notes import folder` requires a directory tree, not a single import package.",
      details: ["source_path_sha256": sha256Hex(root.path)]
    )
  }

  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: root.path)
  } catch {
    throw CLIError(
      code: .notFound,
      message: "Folder import source was not found.",
      details: ["source_path_sha256": sha256Hex(root.path)]
    )
  }
  guard attributes[.type] as? FileAttributeType == .typeDirectory else {
    throw CLIError(
      code: .validationError,
      message: "`notes import folder` requires `--file` to reference a directory.",
      details: ["source_path_sha256": sha256Hex(root.path)]
    )
  }
  guard FileManager.default.isReadableFile(atPath: root.path) else {
    throw CLIError(
      code: .permissionDenied,
      message: "Folder import source is not readable.",
      details: ["source_path_sha256": sha256Hex(root.path)]
    )
  }

  let resourceKeys: Set<URLResourceKey> = [
    .isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey, .isHiddenKey, .fileSizeKey,
  ]
  guard
    let enumerator = FileManager.default.enumerator(
      at: root,
      includingPropertiesForKeys: Array(resourceKeys),
      options: [.skipsHiddenFiles],
      errorHandler: nil
    )
  else {
    throw CLIError(
      code: .validationError,
      message: "Folder import source could not be enumerated.",
      details: ["source_path_sha256": sha256Hex(root.path)]
    )
  }

  var candidateURLs: [URL] = []
  for case let child as URL in enumerator {
    let standardized = child.standardizedFileURL
    let values = try standardized.resourceValues(forKeys: resourceKeys)
    if values.isHidden == true {
      continue
    }
    guard values.isSymbolicLink != true else {
      throw CLIError(
        code: .validationError,
        message: "Folder import does not allow symbolic links.",
        details: [
          "source_path_sha256": sha256Hex(root.path),
          "relative_path_sha256": sha256Hex(try folderImportRelativePath(root: root, url: standardized)),
        ]
      )
    }
    if values.isDirectory == true,
      ["rtfd", "mdpkg", "markdownpackage"].contains(standardized.pathExtension.lowercased())
    {
      candidateURLs.append(standardized)
      enumerator.skipDescendants()
      continue
    }
    if values.isRegularFile == true {
      candidateURLs.append(standardized)
    }
  }

  guard candidateURLs.count <= notesFolderImportMaxItems else {
    throw CLIError(
      code: .validationError,
      message: "Folder import is bounded to 500 importable items per command.",
      details: [
        "source_path_sha256": sha256Hex(root.path),
        "item_count": "\(candidateURLs.count)",
        "max_items": "\(notesFolderImportMaxItems)",
      ]
    )
  }

  let files = try candidateURLs
    .sorted { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
    .enumerated()
    .map { index, url in
      try folderImportFileSource(root: root, url: url, ordinal: index + 1)
    }
  guard !files.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Folder import requires at least one supported Notes import file.",
      details: ["source_path_sha256": sha256Hex(root.path)]
    )
  }

  let directoryPaths = folderImportDirectoryPaths(for: files)
  let directories = try directoryPaths.enumerated().map { index, relativePath in
    let components = relativePath.split(separator: "/").map(String.init)
    guard components.count <= notesFolderImportMaxDepth else {
      throw CLIError(
        code: .validationError,
        message: "Folder import directory depth is bounded.",
        details: [
          "relative_path_sha256": sha256Hex(relativePath),
          "max_depth": "\(notesFolderImportMaxDepth)",
        ]
      )
    }
    let name = try folderImportDirectoryName(components.last ?? "")
    return NotesFolderImportDirectorySource(
      ordinal: index + 1,
      relativePath: relativePath,
      name: name,
      parentRelativePath: folderImportParentPath(relativePath)
    )
  }
  let totalByteCount = files.reduce(0) { $0 + $1.byteCount }
  guard totalByteCount <= notesFolderImportMaxBytes else {
    throw CLIError(
      code: .validationError,
      message: "Folder import is bounded to 250 MB of importable source data per command.",
      details: [
        "source_path_sha256": sha256Hex(root.path),
        "total_byte_count": "\(totalByteCount)",
        "max_bytes": "\(notesFolderImportMaxBytes)",
      ]
    )
  }
  let treeSHA256 = sha256Hex(
    files.map { "\($0.relativePath)\0\($0.formatFamily)\0\($0.byteCount)\0\($0.sourceSHA256)" }
      .joined(separator: "\n")
  )

  return NotesFolderImportSource(
    path: root.path,
    name: root.lastPathComponent,
    directories: directories,
    files: files,
    totalByteCount: totalByteCount,
    treeSHA256: treeSHA256
  )
}

private func folderImportFileSource(
  root: URL,
  url: URL,
  ordinal: Int
) throws -> NotesFolderImportFileSource {
  let relativePath = try folderImportRelativePath(root: root, url: url)
  let directoryRelativePath = folderImportParentPath(relativePath)
  let ext = url.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

  do {
    switch ext {
    case "txt", "text":
      let source = try textImportSource(path: url.path)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "txt",
        byteCount: source.byteCount,
        sourceSHA256: sha256Hex(source.body),
        text: source
      )
    case "md", "markdown":
      let source = try markdownSource(path: url.path, includeAttachments: false)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "markdown",
        byteCount: source.byteCount,
        sourceSHA256: sha256Hex(source.body),
        markdown: source
      )
    case "mdpkg", "markdownpackage":
      let source = try markdownSource(path: url.path, includeAttachments: true)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "markdown_package",
        byteCount: source.byteCount,
        sourceSHA256: source.packageTreeSHA256 ?? sha256Hex(source.body),
        markdown: source
      )
    case "rtf":
      let source = try richImportSource(path: url.path, format: .rtf)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "rtf",
        byteCount: source.byteCount,
        sourceSHA256: source.data.map(sha256Hex) ?? "",
        rich: source
      )
    case "rtfd":
      let source = try richImportSource(path: url.path, format: .rtfd)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "rtfd",
        byteCount: source.byteCount,
        sourceSHA256: source.packageTreeSHA256 ?? "",
        rich: source
      )
    case "html", "htm":
      let source = try richImportSource(path: url.path, format: .html)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "html",
        byteCount: source.byteCount,
        sourceSHA256: source.data.map(sha256Hex) ?? "",
        rich: source
      )
    case "enex":
      let source = try enexImportSource(path: url.path)
      try validateExecutableENEXImport(source)
      return NotesFolderImportFileSource(
        ordinal: ordinal,
        relativePath: relativePath,
        directoryRelativePath: directoryRelativePath,
        formatFamily: "enex",
        byteCount: source.byteCount,
        sourceSHA256: source.dataSHA256,
        enex: source
      )
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Folder import encountered an unsupported file family.",
        details: [
          "relative_path_sha256": sha256Hex(relativePath),
          "extension": ext.isEmpty ? "none" : ext,
        ]
      )
    }
  } catch let error as CLIError {
    throw CLIError(
      code: error.code,
      message: error.message,
      details: [
        "relative_path_sha256": sha256Hex(relativePath),
        "source_path_sha256": sha256Hex(url.path),
        "format_family": notesFolderImportFamily(extensionName: ext),
      ]
    )
  }
}

private func folderImportRelativePath(root: URL, url: URL) throws -> String {
  let rootPath = root.standardizedFileURL.path
  let path = url.standardizedFileURL.path
  guard path.hasPrefix(rootPath + "/") else {
    throw CLIError(
      code: .validationError,
      message: "Folder import item was outside the source directory.",
      details: ["source_path_sha256": sha256Hex(rootPath), "item_path_sha256": sha256Hex(path)]
    )
  }
  return try normalizedNotesMarkdownRelativePath(String(path.dropFirst(rootPath.count + 1)))
}

private func folderImportDirectoryPaths(for files: [NotesFolderImportFileSource]) -> [String] {
  var paths: Set<String> = []
  for file in files {
    var current = file.directoryRelativePath
    while !current.isEmpty {
      paths.insert(current)
      current = folderImportParentPath(current)
    }
  }
  return paths.sorted {
    let lhsDepth = $0.split(separator: "/").count
    let rhsDepth = $1.split(separator: "/").count
    if lhsDepth == rhsDepth {
      return $0.localizedStandardCompare($1) == .orderedAscending
    }
    return lhsDepth < rhsDepth
  }
}

private func folderImportParentPath(_ relativePath: String) -> String {
  let components = relativePath.split(separator: "/").map(String.init)
  guard components.count > 1 else {
    return ""
  }
  return components.dropLast().joined(separator: "/")
}

private func folderImportDirectoryName(_ value: String) throws -> String {
  try normalizedNotesFolderImportName(value, label: "Folder import directory name")
}

func normalizedNotesFolderImportName(_ value: String, label: String = "`--name`") throws -> String {
  let name = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !name.isEmpty else {
    throw CLIError(code: .validationError, message: "\(label) must not be empty.")
  }
  guard name != "." && name != ".." else {
    throw CLIError(code: .validationError, message: "\(label) must not be a relative path.")
  }
  guard name.rangeOfCharacter(from: CharacterSet(charactersIn: "/\\")) == nil else {
    throw CLIError(code: .validationError, message: "\(label) must not contain path separators.")
  }
  return name
}

func folderImportedNoteCount(_ file: NotesFolderImportFileSource) -> Int {
  file.enex?.noteCount ?? 1
}

func folderImportResourceCount(_ file: NotesFolderImportFileSource) -> Int {
  if let markdown = file.markdown {
    return markdown.resources.count
  }
  if let enex = file.enex {
    return enex.resourceCount
  }
  return 0
}

private func notesFolderImportFamily(extensionName ext: String) -> String {
  switch ext {
  case "txt", "text":
    return "txt"
  case "md", "markdown":
    return "markdown"
  case "mdpkg", "markdownpackage":
    return "markdown_package"
  case "rtf":
    return "rtf"
  case "rtfd":
    return "rtfd"
  case "html", "htm":
    return "html"
  case "enex":
    return "enex"
  default:
    return "unsupported"
  }
}

func createScopeDigest(_ draft: NotesCreateDraft) -> String {
  let fields = [
    draft.folderId,
    draft.folderName,
    draft.accountName,
    draft.title,
    sha256Hex(draft.body),
    draft.isSystemPaper ? "system-paper" : "standard-note",
  ]
  return "notes-create:\(sha256Hex(fields.joined(separator: "|")))"
}

func markdownImportScopeDigest(_ importDraft: NotesMarkdownImportDraft) -> String {
  let fields = [
    createScopeDigest(importDraft.draft),
    importDraft.source.path,
    "\(importDraft.source.byteCount)",
    importDraft.source.modifiedAt.map(formatDate) ?? "",
    sha256Hex(importDraft.source.body),
    "\(importDraft.source.semanticSummary.headingCount)",
    "\(importDraft.source.semanticSummary.unorderedListItemCount)",
    "\(importDraft.source.semanticSummary.orderedListItemCount)",
    "\(importDraft.source.semanticSummary.blockQuoteLineCount)",
    "\(importDraft.source.semanticSummary.fencedCodeBlockCount)",
    "\(importDraft.source.semanticSummary.inlineCodeSpanCount)",
    "\(importDraft.source.semanticSummary.linkReferenceCount)",
    "\(importDraft.source.semanticSummary.imageReferenceCount)",
    "\(importDraft.source.semanticSummary.emphasizedSpanCount)",
    importDraft.source.isPackage
      ? "package"
      : (importDraft.source.resources.isEmpty ? "single-file" : "single-file-resources"),
    importDraft.source.markdownRelativePath ?? "",
    "\(importDraft.source.resources.count)",
    importDraft.source.packageTreeSHA256 ?? "",
    importDraft.source.resources
      .map { "\($0.relativePath)\0\($0.byteCount)\0\(sha256Hex($0.data))" }
      .joined(separator: "\n"),
  ]
  return "notes-import-markdown:\(sha256Hex(fields.joined(separator: "|")))"
}

func markdownImportSummary(_ importDraft: NotesMarkdownImportDraft) -> [String: String] {
  var summary = [
    "folder_id": importDraft.draft.folderId,
    "folder": importDraft.draft.folderName,
    "account": importDraft.draft.accountName,
    "title": importDraft.draft.title,
    "source_path": importDraft.source.path,
    "source_byte_count": "\(importDraft.source.byteCount)",
    "source_sha256": sha256Hex(importDraft.source.body),
    "body_sha256": sha256Hex(importDraft.draft.body),
    "semantic_heading_count": "\(importDraft.source.semanticSummary.headingCount)",
    "semantic_list_item_count": "\(importDraft.source.semanticSummary.listItemCount)",
    "semantic_block_quote_line_count": "\(importDraft.source.semanticSummary.blockQuoteLineCount)",
    "semantic_fenced_code_block_count": "\(importDraft.source.semanticSummary.fencedCodeBlockCount)",
    "semantic_inline_code_span_count": "\(importDraft.source.semanticSummary.inlineCodeSpanCount)",
    "semantic_link_reference_count": "\(importDraft.source.semanticSummary.linkReferenceCount)",
    "semantic_image_reference_count": "\(importDraft.source.semanticSummary.imageReferenceCount)",
    "semantic_emphasized_span_count": "\(importDraft.source.semanticSummary.emphasizedSpanCount)",
    "is_package": importDraft.source.isPackage ? "true" : "false",
    "resource_count": "\(importDraft.source.resources.count)",
  ]
  if let markdownRelativePath = importDraft.source.markdownRelativePath {
    summary["markdown_relative_path"] = markdownRelativePath
  }
  if let packageFileCount = importDraft.source.packageFileCount {
    summary["package_file_count"] = "\(packageFileCount)"
  }
  if let packageTotalByteCount = importDraft.source.packageTotalByteCount {
    summary["package_total_byte_count"] = "\(packageTotalByteCount)"
  }
  if let packageTreeSHA256 = importDraft.source.packageTreeSHA256 {
    summary["package_tree_sha256"] = packageTreeSHA256
  }
  return summary
}

func textImportScopeDigest(_ importDraft: NotesTextImportDraft) -> String {
  let fields = [
    createScopeDigest(importDraft.draft),
    importDraft.source.path,
    "\(importDraft.source.byteCount)",
    importDraft.source.modifiedAt.map(formatDate) ?? "",
    sha256Hex(importDraft.source.body),
  ]
  return "notes-import-text:\(sha256Hex(fields.joined(separator: "|")))"
}

func richImportScopeDigest(_ importDraft: NotesRichImportDraft) -> String {
  let fields = [
    createScopeDigest(importDraft.draft),
    importDraft.source.path,
    importDraft.source.format.rawValue,
    "\(importDraft.source.byteCount)",
    importDraft.source.modifiedAt.map(formatDate) ?? "",
    importDraft.source.data.map(sha256Hex) ?? "",
    importDraft.source.htmlRelativePath ?? "",
    importDraft.source.packageTreeSHA256 ?? "",
    "\(importDraft.source.packageFileCount ?? 0)",
    "\(importDraft.source.packageResourceFileCount ?? 0)",
    "\(importDraft.source.packageTotalByteCount ?? 0)",
    importDraft.source.resources
      .map { "\($0.relativePath)\0\($0.byteCount)\0\(sha256Hex($0.data))" }
      .joined(separator: "\n"),
  ]
  return "notes-import-\(importDraft.source.format.rawValue):\(sha256Hex(fields.joined(separator: "|")))"
}

func richImportSummary(_ importDraft: NotesRichImportDraft) -> [String: String] {
  var summary = [
    "folder_id": importDraft.draft.folderId,
    "folder": importDraft.draft.folderName,
    "account": importDraft.draft.accountName,
    "title": importDraft.draft.title,
    "source_path_sha256": sha256Hex(importDraft.source.path),
    "source_name_sha256": sha256Hex(importDraft.source.name),
    "format_family": importDraft.source.format.rawValue,
    "source_byte_count": "\(importDraft.source.byteCount)",
  ]
  if let data = importDraft.source.data {
    summary["source_sha256"] = sha256Hex(data)
  }
  if let htmlRelativePath = importDraft.source.htmlRelativePath {
    summary["html_relative_path"] = htmlRelativePath
  }
  if importDraft.source.resources.isEmpty == false {
    summary["resource_count"] = "\(importDraft.source.resources.count)"
  }
  if let packageFileCount = importDraft.source.packageFileCount {
    summary["package_file_count"] = "\(packageFileCount)"
  }
  if let packageResourceFileCount = importDraft.source.packageResourceFileCount {
    summary["package_resource_file_count"] = "\(packageResourceFileCount)"
  }
  if let packageTotalByteCount = importDraft.source.packageTotalByteCount {
    summary["package_total_byte_count"] = "\(packageTotalByteCount)"
  }
  if let packageTreeSHA256 = importDraft.source.packageTreeSHA256 {
    summary["package_tree_sha256"] = packageTreeSHA256
  }
  return summary
}

func richReplaceScopeDigest(_ draft: NotesRichReplaceDraft) -> String {
  let fields: [String]
  switch draft.source {
  case .markdown(let source):
    fields = [
      draft.noteID,
      draft.title,
      source.path,
      "markdown",
      "\(source.byteCount)",
      source.modifiedAt.map(formatDate) ?? "",
      sha256Hex(source.body),
      source.markdownRelativePath ?? "",
      source.packageTreeSHA256 ?? "",
      "\(source.packageFileCount ?? 0)",
      "\(source.packageTotalByteCount ?? 0)",
      source.resources
        .map { "\($0.relativePath)\0\($0.byteCount)\0\(sha256Hex($0.data))" }
        .joined(separator: "\n"),
    ]
  case .rich(let source):
    fields = [
      draft.noteID,
      draft.title,
      source.path,
      source.format.rawValue,
      "\(source.byteCount)",
      source.modifiedAt.map(formatDate) ?? "",
      source.data.map(sha256Hex) ?? "",
      source.htmlRelativePath ?? "",
      source.packageTreeSHA256 ?? "",
      "\(source.packageFileCount ?? 0)",
      "\(source.packageResourceFileCount ?? 0)",
      "\(source.packageTotalByteCount ?? 0)",
      source.resources
        .map { "\($0.relativePath)\0\($0.byteCount)\0\(sha256Hex($0.data))" }
        .joined(separator: "\n"),
    ]
  }
  return "notes-replace-\(draft.source.formatFamily):\(sha256Hex(fields.joined(separator: "|")))"
}

func richReplaceSummary(_ draft: NotesRichReplaceDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "id_sha256": sha256Hex(draft.noteID),
    "title_sha256": sha256Hex(draft.title),
    "format_family": draft.source.formatFamily,
    "source_byte_count": "\(draft.source.sourceByteCount)",
    "resource_count": "\(draft.source.resourceCount)",
  ]
  switch draft.source {
  case .markdown(let source):
    summary["source_path_sha256"] = sha256Hex(source.path)
    summary["source_name_sha256"] = sha256Hex(source.name)
    summary["source_sha256"] = sha256Hex(source.body)
    summary["semantic_heading_count"] = "\(source.semanticSummary.headingCount)"
    summary["semantic_list_item_count"] = "\(source.semanticSummary.listItemCount)"
    summary["semantic_link_reference_count"] = "\(source.semanticSummary.linkReferenceCount)"
    summary["semantic_image_reference_count"] = "\(source.semanticSummary.imageReferenceCount)"
    summary["is_package"] = source.isPackage ? "true" : "false"
    if let markdownRelativePath = source.markdownRelativePath {
      summary["markdown_relative_path"] = markdownRelativePath
    }
    if let packageFileCount = source.packageFileCount {
      summary["package_file_count"] = "\(packageFileCount)"
    }
    if let packageTotalByteCount = source.packageTotalByteCount {
      summary["package_total_byte_count"] = "\(packageTotalByteCount)"
    }
    if let packageTreeSHA256 = source.packageTreeSHA256 {
      summary["package_tree_sha256"] = packageTreeSHA256
    }
  case .rich(let source):
    summary["source_path_sha256"] = sha256Hex(source.path)
    summary["source_name_sha256"] = sha256Hex(source.name)
    if let data = source.data {
      summary["source_sha256"] = sha256Hex(data)
    }
    if let htmlRelativePath = source.htmlRelativePath {
      summary["html_relative_path"] = htmlRelativePath
    }
    if let packageFileCount = source.packageFileCount {
      summary["package_file_count"] = "\(packageFileCount)"
    }
    if let packageResourceFileCount = source.packageResourceFileCount {
      summary["package_resource_file_count"] = "\(packageResourceFileCount)"
    }
    if let packageTotalByteCount = source.packageTotalByteCount {
      summary["package_total_byte_count"] = "\(packageTotalByteCount)"
    }
    if let packageTreeSHA256 = source.packageTreeSHA256 {
      summary["package_tree_sha256"] = packageTreeSHA256
    }
  }
  return summary
}

func textImportSummary(_ importDraft: NotesTextImportDraft) -> [String: String] {
  [
    "folder_id": importDraft.draft.folderId,
    "folder": importDraft.draft.folderName,
    "account": importDraft.draft.accountName,
    "title": importDraft.draft.title,
    "source_path": importDraft.source.path,
    "source_byte_count": "\(importDraft.source.byteCount)",
    "source_sha256": sha256Hex(importDraft.source.body),
    "body_sha256": sha256Hex(importDraft.draft.body),
  ]
}

func folderImportScopeDigest(_ draft: NotesFolderImportDraft) -> String {
  let fields = [
    draft.parentFolderID,
    draft.parentFolderName,
    draft.accountName,
    draft.importRootFolderName,
    draft.source.path,
    draft.source.treeSHA256,
    "\(draft.source.directoryCount)",
    "\(draft.source.fileCount)",
    "\(draft.source.totalByteCount)",
    draft.source.files
      .map { "\($0.relativePath)\0\($0.formatFamily)\0\($0.byteCount)\0\($0.sourceSHA256)" }
      .joined(separator: "\n"),
  ]
  return "notes-import-folder:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderImportSummary(_ draft: NotesFolderImportDraft) -> [String: String] {
  [
    "parent_folder_id": draft.parentFolderID,
    "parent_folder": draft.parentFolderName,
    "account": draft.accountName,
    "import_root_folder_name_sha256": sha256Hex(draft.importRootFolderName),
    "import_root_folder_name_length": "\((draft.importRootFolderName as NSString).length)",
    "source_path_sha256": sha256Hex(draft.source.path),
    "source_name_sha256": sha256Hex(draft.source.name),
    "created_folder_count": "\(draft.source.directoryCount + 1)",
    "source_directory_count": "\(draft.source.directoryCount)",
    "import_file_count": "\(draft.source.fileCount)",
    "imported_note_count": "\(draft.source.importedNoteCount)",
    "resource_count": "\(draft.source.resourceCount)",
    "total_byte_count": "\(draft.source.totalByteCount)",
    "tree_sha256": draft.source.treeSHA256,
    "text_count": "\(draft.source.textCount)",
    "markdown_count": "\(draft.source.markdownCount)",
    "markdown_package_count": "\(draft.source.markdownPackageCount)",
    "rich_format_count": "\(draft.source.richFormatCount)",
    "enex_count": "\(draft.source.enexCount)",
    "folder_preserve_structure": "true",
  ]
}

public struct NotesCUPSPrintDispatcher: NotesPrintDispatching {
  public init() {}

  public func validatePrinter(name: String) throws -> String {
    let printer = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !printer.isEmpty else {
      throw CLIError(code: .validationError, message: "`--printer` must not be empty.")
    }
    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(.path("/usr/bin/lpstat"), arguments: ["-p", printer])
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .backendUnavailable, message: "`lpstat` could not be started.")
    }
    guard result.exitCode == 0, result.stdout.contains("printer \(printer) ") else {
      throw CLIError(code: .notFound, message: "Printer was not found.", details: ["printer": printer])
    }
    return printer
  }

  public func submitPDF(_ data: Data, suggestedFilename: String, printerName: String) throws -> String {
    let filename = sanitizedNotesPrintFilename(suggestedFilename)
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-notes-print-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    let fileURL = directory.appendingPathComponent(filename)
    try data.write(to: fileURL, options: [.atomic])

    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(.path("/usr/bin/lp"), arguments: ["-d", printerName, fileURL.path])
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .backendUnavailable, message: "`lp` could not be started.")
    }
    guard result.exitCode == 0 else {
      throw CLIError(
        code: .backendUnavailable,
        message: "`lp` failed while submitting the Notes print job.",
        details: ["status": "\(result.exitCode)"])
    }
    return try notesSubmittedPrintJobID(result.stdout)
  }
}

public struct NotesPagesOpenDispatcher: NotesPagesDispatching {
  public init() {}

  public func openRTFDPackage(_ files: [NotesNoteRTFDExportFile], suggestedTitle: String?) throws
    -> NotesPagesOpenDispatchRecord
  {
    let normalizedFiles = try normalizedNotesRTFDExportFiles(files)
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-notes-pages-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)

    let packageURL = directory.appendingPathComponent(
      sanitizedNotesPagesFilename(suggestedTitle ?? "Note"),
      isDirectory: true
    )
    try writeNotesRTFDExport(normalizedFiles, to: packageURL.path)

    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(.path("/usr/bin/open"), arguments: ["-a", "Pages", packageURL.path])
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .backendUnavailable, message: "`open` could not be started.")
    }
    guard result.exitCode == 0 else {
      throw CLIError(
        code: .backendUnavailable,
        message: "`open -a Pages` failed while dispatching the Notes RTFD package.",
        details: ["status": "\(result.exitCode)"]
      )
    }

    return NotesPagesOpenDispatchRecord(
      applicationName: "Pages",
      stagedPackagePathSHA256: sha256Hex(packageURL.path),
      fileCount: normalizedFiles.count,
      totalByteCount: notesRTFDTotalByteCount(normalizedFiles),
      treeSHA256: notesRTFDTreeSHA256(normalizedFiles)
    )
  }
}

public struct NotesAppKitClipboardWriter: NotesClipboardWriting {
  public init() {}

  public func writeString(_ value: String) throws -> NotesClipboardWriteRecord {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    guard pasteboard.setString(value, forType: .string) else {
      throw CLIError(
        code: .internalError,
        message: "System clipboard did not accept the Notes audio transcript text."
      )
    }
    return NotesClipboardWriteRecord(changeCount: pasteboard.changeCount)
  }

  public func readString() throws -> String? {
    NSPasteboard.general.string(forType: .string)
  }
}

func sanitizedNotesPrintFilename(_ value: String) -> String {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  let base = trimmed.isEmpty ? "Note" : trimmed
  let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " ._-"))
  let scalars = base.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
  let filename = String(scalars).trimmingCharacters(in: .whitespacesAndNewlines)
  return (filename.isEmpty ? "Note" : filename) + ".pdf"
}

func sanitizedNotesPagesFilename(_ value: String) -> String {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  let base = trimmed.isEmpty ? "Note" : trimmed
  let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " ._-"))
  let scalars = base.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
  var filename = String(scalars).trimmingCharacters(in: .whitespacesAndNewlines)
  if filename.isEmpty {
    filename = "Note"
  }
  if filename.localizedLowercase.hasSuffix(".rtfd") {
    return filename
  }
  return filename + ".rtfd"
}

func notesSubmittedPrintJobID(_ output: String) throws -> String {
  let prefix = "request id is "
  if let line = output.split(whereSeparator: \.isNewline)
    .first(where: { $0.lowercased().hasPrefix(prefix) })
  {
    let tail = String(line.dropFirst(prefix.count))
    if let id = tail.split(separator: " ").first.map(String.init), !id.isEmpty {
      return id
    }
  }
  throw CLIError(code: .backendUnavailable, message: "`lp` did not report a print job id.")
}

func folderCreateScopeDigest(_ draft: NotesFolderCreateDraft) -> String {
  let fields = [
    draft.name,
    draft.accountID ?? "",
    draft.accountName,
    draft.parentID ?? "",
    draft.parentName ?? "",
  ]
  return "notes-folder-create:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderCreateSummary(_ draft: NotesFolderCreateDraft) -> [String: String] {
  var summary = [
    "name": draft.name,
    "account": draft.accountName,
  ]
  if let accountID = draft.accountID {
    summary["account_id"] = accountID
  }
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  if let parentName = draft.parentName {
    summary["parent"] = parentName
  }
  return summary
}

func smartFolderCreateScopeDigest(_ draft: NotesSmartFolderCreateDraft) -> String {
  let fields = [
    draft.name,
    draft.accountID ?? "",
    draft.accountName,
    draft.tagStandardizedContent,
    draft.tagStandardizedContents.joined(separator: "\0"),
    draft.tagMatch,
    "\(draft.tagOperator)",
    "\(draft.matchedTagCount)",
    "\(draft.matchingNoteCount)",
  ]
  return "notes-smart-folder-create:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderCreateSummary(_ draft: NotesSmartFolderCreateDraft) -> [String: String] {
  var summary = [
    "name": draft.name,
    "account": draft.accountName,
    "tag": draft.tagDisplayText,
    "tag_standardized_content": draft.tagStandardizedContent,
    "tag_count": "\(draft.tagStandardizedContents.count)",
    "tag_standardized_contents_sha256": sha256Hex(draft.tagStandardizedContents.joined(separator: "\0")),
    "tag_match": draft.tagMatch,
    "tag_operator": "\(draft.tagOperator)",
    "matched_tag_count": "\(draft.matchedTagCount)",
    "matching_note_count": "\(draft.matchingNoteCount)",
  ]
  if let accountID = draft.accountID {
    summary["account_id"] = accountID
  }
  return summary
}

func smartFolderUpdateScopeDigest(_ draft: NotesSmartFolderUpdateDraft) -> String {
  let fields = [
    draft.smartFolderID,
    draft.name,
    draft.accountName,
    draft.previousQueryPresent ? "query" : "no-query",
    draft.previousQuerySHA256 ?? "",
    draft.previousVisibleNoteCount.map(String.init) ?? "",
    draft.tagStandardizedContent,
    draft.tagStandardizedContents.joined(separator: "\0"),
    draft.tagMatch,
    "\(draft.tagOperator)",
    "\(draft.matchedTagCount)",
    "\(draft.matchingNoteCount)",
  ]
  return "notes-smart-folder-update:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderUpdateSummary(_ draft: NotesSmartFolderUpdateDraft) -> [String: String] {
  var summary = [
    "smart_folder_id": draft.smartFolderID,
    "name": draft.name,
    "account": draft.accountName,
    "previous_query_present": draft.previousQueryPresent ? "true" : "false",
    "tag": draft.tagDisplayText,
    "tag_standardized_content": draft.tagStandardizedContent,
    "tag_count": "\(draft.tagStandardizedContents.count)",
    "tag_standardized_contents_sha256": sha256Hex(draft.tagStandardizedContents.joined(separator: "\0")),
    "tag_match": draft.tagMatch,
    "tag_operator": "\(draft.tagOperator)",
    "matched_tag_count": "\(draft.matchedTagCount)",
    "matching_note_count": "\(draft.matchingNoteCount)",
  ]
  if let previousVisibleNoteCount = draft.previousVisibleNoteCount {
    summary["previous_visible_note_count"] = "\(previousVisibleNoteCount)"
  }
  return summary
}

struct NotesSmartFolderBuiltInCriteriaFilterExpectation: Equatable, Sendable {
  var filterKind: String
  var selectionType: Int?
  var inclusionType: Int?
  var count: Int?
  var hasPrimaryDate: Bool?
  var hasSecondaryDate: Bool?
  var hasRelativeRange: Bool?

  init(
    filterKind: String,
    selectionType: Int?,
    inclusionType: Int?,
    count: Int? = nil,
    hasPrimaryDate: Bool? = nil,
    hasSecondaryDate: Bool? = nil,
    hasRelativeRange: Bool? = nil
  ) {
    self.filterKind = filterKind
    self.selectionType = selectionType
    self.inclusionType = inclusionType
    self.count = count
    self.hasPrimaryDate = hasPrimaryDate
    self.hasSecondaryDate = hasSecondaryDate
    self.hasRelativeRange = hasRelativeRange
  }
}

struct NotesSmartFolderDateCriteriaDescriptor: Equatable, Sendable {
  var filterKind: String
  var selectionType: UInt64
  var parameterKind: String?
}

let notesSmartFolderTagSelectionModeAllTagged = 1
let notesSmartFolderTagSelectionModeAllUntagged = 2
let notesSmartFolderTagSelectionOperatorAll = 1
let notesSmartFolderTagSelectionOperatorAny = 2

let notesSmartFolderBuiltInCriteriaKinds = [
  "pinned",
  "unpinned",
  "shared",
  "not-shared",
  "folder",
  "not-folder",
  "untagged",
  "math",
  "call",
  "system-paper",
  "recently-deleted-math",
  "locked",
  "unlocked",
  "quick-notes",
  "not-quick-notes",
  "attachments",
  "no-attachments",
  "attachment-photo-video",
  "attachment-scans",
  "attachment-drawings",
  "attachment-maps",
  "attachment-websites",
  "attachment-audio",
  "attachment-documents",
  "checklists",
  "incomplete-checklists",
  "completed-checklists",
  "no-checklists",
  "created-today",
  "created-yesterday",
  "created-last-7-days",
  "created-last-30-days",
  "created-last-3-months",
  "created-last-12-months",
  "created-on",
  "created-before",
  "created-after",
  "created-between",
  "created-relative",
  "edited-today",
  "edited-yesterday",
  "edited-last-7-days",
  "edited-last-30-days",
  "edited-last-3-months",
  "edited-last-12-months",
  "edited-on",
  "edited-before",
  "edited-after",
  "edited-between",
  "edited-relative",
  "participants",
  "mentions",
]

func smartFolderBuiltInCriteriaSupportedList() -> String {
  notesSmartFolderBuiltInCriteriaKinds.joined(separator: ",")
}

func smartFolderUntaggedCriteriaKind(_ kind: String) -> Bool {
  kind == "untagged"
}

func smartFolderBuiltInCriteriaAttachmentSelectionType(_ kind: String) -> UInt64? {
  switch kind {
  case "attachments":
    return 1
  case "attachment-photo-video":
    return 2
  case "attachment-scans":
    return 3
  case "attachment-drawings":
    return 4
  case "attachment-maps":
    return 5
  case "attachment-websites":
    return 6
  case "attachment-audio":
    return 7
  case "attachment-documents":
    return 8
  case "no-attachments":
    return 9
  default:
    return nil
  }
}

func smartFolderBuiltInCriteriaChecklistSelectionType(_ kind: String) -> UInt64? {
  switch kind {
  case "checklists":
    return 0
  case "incomplete-checklists":
    return 1
  case "completed-checklists":
    return 2
  case "no-checklists":
    return 3
  default:
    return nil
  }
}

func smartFolderBuiltInCriteriaDateSelection(_ kind: String) -> (filterKind: String, selectionType: UInt64)? {
  guard let descriptor = smartFolderDateCriteriaDescriptor(kind) else {
    return nil
  }
  return (descriptor.filterKind, descriptor.selectionType)
}

func smartFolderFolderCriteriaInclusionType(_ kind: String) -> Int? {
  switch kind {
  case "folder":
    return 1
  case "not-folder":
    return 0
  default:
    return nil
  }
}

func smartFolderParticipantCriteriaKind(_ kind: String) -> Bool {
  kind == "participants" || kind == "mentions"
}

func smartFolderDateCriteriaDescriptor(_ kind: String) -> NotesSmartFolderDateCriteriaDescriptor? {
  let createdPrefix = "created-"
  let editedPrefix = "edited-"
  let filterKind: String
  let suffix: String
  if kind.hasPrefix(createdPrefix) {
    filterKind = "date_created"
    suffix = String(kind.dropFirst(createdPrefix.count))
  } else if kind.hasPrefix(editedPrefix) {
    filterKind = "date_edited"
    suffix = String(kind.dropFirst(editedPrefix.count))
  } else {
    return nil
  }
  switch suffix {
  case "today":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 0, parameterKind: nil)
  case "yesterday":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 1, parameterKind: nil)
  case "last-7-days":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 2, parameterKind: nil)
  case "last-30-days":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 3, parameterKind: nil)
  case "last-3-months":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 4, parameterKind: nil)
  case "last-12-months":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 5, parameterKind: nil)
  case "between":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 6, parameterKind: "range")
  case "relative":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 7, parameterKind: "relative")
  case "on":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 8, parameterKind: "single_date")
  case "before":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 9, parameterKind: "single_date")
  case "after":
    return NotesSmartFolderDateCriteriaDescriptor(filterKind: filterKind, selectionType: 10, parameterKind: "single_date")
  default:
    return nil
  }
}

func smartFolderBuiltInCriteriaFilterExpectation(
  kind: String,
  dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
  folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil
) -> NotesSmartFolderBuiltInCriteriaFilterExpectation? {
  switch kind {
  case "pinned":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "pinned", selectionType: nil, inclusionType: 1)
  case "unpinned":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "pinned", selectionType: nil, inclusionType: 0)
  case "shared":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "shared", selectionType: nil, inclusionType: 1)
  case "not-shared":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "shared", selectionType: nil, inclusionType: 0)
  case "folder":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(
      filterKind: "folders",
      selectionType: nil,
      inclusionType: 1,
      count: folderCriteria?.folderIDs.count ?? 1
    )
  case "not-folder":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(
      filterKind: "folders",
      selectionType: nil,
      inclusionType: 0,
      count: folderCriteria?.folderIDs.count ?? 1
    )
  case "locked":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "locked", selectionType: nil, inclusionType: 1)
  case "unlocked":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "locked", selectionType: nil, inclusionType: 0)
  case "quick-notes":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "quick_notes", selectionType: nil, inclusionType: 1)
  case "not-quick-notes":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "quick_notes", selectionType: nil, inclusionType: 0)
  case "participants":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(
      filterKind: "participants",
      selectionType: 1,
      inclusionType: nil,
      count: 1
    )
  case "mentions":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(
      filterKind: "mentions",
      selectionType: 1,
      inclusionType: nil,
      count: 1
    )
  default:
    if let selectionType = smartFolderBuiltInCriteriaAttachmentSelectionType(kind) {
      return NotesSmartFolderBuiltInCriteriaFilterExpectation(
        filterKind: "attachments",
        selectionType: Int(selectionType),
        inclusionType: nil
      )
    }
    if let selectionType = smartFolderBuiltInCriteriaChecklistSelectionType(kind) {
      return NotesSmartFolderBuiltInCriteriaFilterExpectation(
        filterKind: "checklists",
        selectionType: Int(selectionType),
        inclusionType: nil
      )
    }
    if let dateSelection = smartFolderDateCriteriaDescriptor(kind) {
      let hasPrimaryDate: Bool?
      let hasSecondaryDate: Bool?
      let hasRelativeRange: Bool?
      switch dateSelection.parameterKind {
      case "single_date":
        hasPrimaryDate = dateCriteria?.primaryDate != nil ? true : nil
        hasSecondaryDate = dateSelection.selectionType == 8 ? true : nil
        hasRelativeRange = false
      case "range":
        hasPrimaryDate = dateCriteria?.primaryDate != nil ? true : nil
        hasSecondaryDate = dateCriteria?.secondaryDate != nil ? true : nil
        hasRelativeRange = false
      case "relative":
        hasPrimaryDate = false
        hasSecondaryDate = false
        hasRelativeRange = dateCriteria?.relativeAmount != nil ? true : nil
      default:
        hasPrimaryDate = false
        hasSecondaryDate = false
        hasRelativeRange = false
      }
      return NotesSmartFolderBuiltInCriteriaFilterExpectation(
        filterKind: dateSelection.filterKind,
        selectionType: Int(dateSelection.selectionType),
        inclusionType: nil,
        hasPrimaryDate: hasPrimaryDate,
        hasSecondaryDate: hasSecondaryDate,
        hasRelativeRange: hasRelativeRange
      )
    }
    return nil
  }
}

func smartFolderBuiltInCriteriaCombinationFilterExpectation(
  kind: String,
  dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
  folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil
) -> NotesSmartFolderBuiltInCriteriaFilterExpectation? {
  if let expectation = smartFolderBuiltInCriteriaFilterExpectation(
    kind: kind,
    dateCriteria: dateCriteria,
    folderCriteria: folderCriteria
  ) {
    return expectation
  }
  switch kind {
  case "math":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "math", selectionType: nil, inclusionType: nil)
  case "recently-deleted-math":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "math", selectionType: nil, inclusionType: nil)
  case "call":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(filterKind: "call", selectionType: nil, inclusionType: nil)
  case "system-paper":
    return NotesSmartFolderBuiltInCriteriaFilterExpectation(
      filterKind: "system_paper",
      selectionType: nil,
      inclusionType: nil
    )
  default:
    return nil
  }
}

func smartFolderPromotedCriteriaKind(for filter: NotesSmartFolderCriteriaFilter) -> String? {
  switch filter.kind {
  case "pinned":
    return smartFolderInclusionCriteriaKind(
      inclusionType: filter.inclusionType,
      includedKind: "pinned",
      excludedKind: "unpinned"
    )
  case "shared":
    return smartFolderInclusionCriteriaKind(
      inclusionType: filter.inclusionType,
      includedKind: "shared",
      excludedKind: "not-shared"
    )
  case "locked":
    return smartFolderInclusionCriteriaKind(
      inclusionType: filter.inclusionType,
      includedKind: "locked",
      excludedKind: "unlocked"
    )
  case "quick_notes":
    return smartFolderInclusionCriteriaKind(
      inclusionType: filter.inclusionType,
      includedKind: "quick-notes",
      excludedKind: "not-quick-notes"
    )
  case "folders":
    return smartFolderInclusionCriteriaKind(
      inclusionType: filter.inclusionType,
      includedKind: "folder",
      excludedKind: "not-folder"
    )
  case "attachments":
    return smartFolderAttachmentCriteriaKind(selectionType: filter.selectionType)
  case "checklists":
    return smartFolderChecklistCriteriaKind(selectionType: filter.selectionType)
  case "date_created":
    return smartFolderDateCriteriaKind(prefix: "created", selectionType: filter.selectionType)
  case "date_edited":
    return smartFolderDateCriteriaKind(prefix: "edited", selectionType: filter.selectionType)
  case "participants":
    return "participants"
  case "mentions":
    return "mentions"
  case "math":
    return "math"
  case "call":
    return "call"
  case "system_paper":
    return "system-paper"
  default:
    return nil
  }
}

func smartFolderPromotedCriteriaKinds(from criteria: NotesSmartFolderCriteriaSummary?) -> [String]? {
  guard let criteria,
    criteria.tagSelection == nil,
    criteria.filterCount == criteria.filters.count
  else {
    return nil
  }
  let kinds = criteria.filters.compactMap(smartFolderPromotedCriteriaKind)
  return kinds.count == criteria.filters.count ? kinds : nil
}

private func smartFolderInclusionCriteriaKind(
  inclusionType: Int?,
  includedKind: String,
  excludedKind: String
) -> String? {
  switch inclusionType {
  case 1:
    return includedKind
  case 0:
    return excludedKind
  default:
    return nil
  }
}

private func smartFolderAttachmentCriteriaKind(selectionType: Int?) -> String? {
  switch selectionType {
  case 1:
    return "attachments"
  case 2:
    return "attachment-photo-video"
  case 3:
    return "attachment-scans"
  case 4:
    return "attachment-drawings"
  case 5:
    return "attachment-maps"
  case 6:
    return "attachment-websites"
  case 7:
    return "attachment-audio"
  case 8:
    return "attachment-documents"
  case 9:
    return "no-attachments"
  default:
    return nil
  }
}

private func smartFolderChecklistCriteriaKind(selectionType: Int?) -> String? {
  switch selectionType {
  case 0:
    return "checklists"
  case 1:
    return "incomplete-checklists"
  case 2:
    return "completed-checklists"
  case 3:
    return "no-checklists"
  default:
    return nil
  }
}

private func smartFolderDateCriteriaKind(prefix: String, selectionType: Int?) -> String? {
  let suffix: String
  switch selectionType {
  case 0:
    suffix = "today"
  case 1:
    suffix = "yesterday"
  case 2:
    suffix = "last-7-days"
  case 3:
    suffix = "last-30-days"
  case 4:
    suffix = "last-3-months"
  case 5:
    suffix = "last-12-months"
  case 6:
    suffix = "between"
  case 7:
    suffix = "relative"
  case 8:
    suffix = "on"
  case 9:
    suffix = "before"
  case 10:
    suffix = "after"
  default:
    return nil
  }
  return "\(prefix)-\(suffix)"
}

func validateSmartFolderParticipantCriteriaParameters(
  kind: String,
  participantCriteria: NotesSmartFolderParticipantCriteriaParameters?
) throws {
  guard smartFolderParticipantCriteriaKind(kind) else {
    if participantCriteria != nil {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder participant options require a participants or mentions criteria kind.",
        details: ["criteria": kind]
      )
    }
    return
  }
  guard let participantCriteria else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder participant criteria requires `--participant-user-id USER_ID`.",
      details: ["criteria": kind, "required_option": "participant-user-id"]
    )
  }
  guard participantCriteria.selectionType == 1 else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder participant criteria selection type did not match the selected-participant criteria kind.",
      details: ["criteria": kind]
    )
  }
}

func validateSmartFolderFolderCriteriaParameters(
  kind: String,
  folderCriteria: NotesSmartFolderFolderCriteriaParameters?
) throws {
  guard smartFolderFolderCriteriaInclusionType(kind) != nil else {
    if folderCriteria != nil {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria options require a folder-based criteria kind.",
        details: ["criteria": kind]
      )
    }
    return
  }
  guard let folderCriteria else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder folder criteria requires `--criteria-folder FOLDER[,FOLDER...]`.",
      details: ["criteria": kind, "required_option": "criteria-folder"]
    )
  }
  guard folderCriteria.inclusionType == smartFolderFolderCriteriaInclusionType(kind) else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder folder criteria inclusion type did not match the criteria kind.",
      details: ["criteria": kind]
    )
  }
  guard !folderCriteria.folderIDs.isEmpty,
    folderCriteria.folderIDs.count == folderCriteria.folderNames.count,
    folderCriteria.folderIDs.count == folderCriteria.requestedFolders.count
  else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder folder criteria requires at least one resolved folder target.",
      details: ["criteria": kind, "criteria_folder_count": "\(folderCriteria.folderIDs.count)"]
    )
  }
}

func notesSmartFolderDateCriteriaUnitSelectionType(_ unit: String) -> UInt64? {
  switch unit.trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "_", with: "-")
    .localizedLowercase
  {
  case "hour", "hours":
    return 1
  case "day", "days":
    return 2
  case "week", "weeks":
    return 3
  case "month", "months":
    return 4
  case "year", "years":
    return 5
  default:
    return nil
  }
}

func normalizedNotesSmartFolderDateCriteriaUnit(_ raw: String) throws -> (unit: String, selectionType: UInt64) {
  let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "_", with: "-")
    .localizedLowercase
  guard let selectionType = notesSmartFolderDateCriteriaUnitSelectionType(value) else {
    throw CLIError(
      code: .validationError,
      message: "Unsupported Smart Folder relative date unit.",
      details: [
        "unit_sha256": sha256Hex(value),
        "supported": "hours,days,weeks,months,years",
      ]
    )
  }
  switch selectionType {
  case 1:
    return ("hours", selectionType)
  case 2:
    return ("days", selectionType)
  case 3:
    return ("weeks", selectionType)
  case 4:
    return ("months", selectionType)
  case 5:
    return ("years", selectionType)
  default:
    return (value, selectionType)
  }
}

func parseNotesSmartFolderCriteriaDate(_ raw: String, optionName: String) throws -> (text: String, date: Date) {
  let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .gregorian)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone.current
  formatter.dateFormat = "yyyy-MM-dd"
  guard let parsed = formatter.date(from: value), formatter.string(from: parsed) == value else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder date criteria requires a date in YYYY-MM-DD format.",
      details: [
        "option": optionName,
        "value_sha256": sha256Hex(value),
        "expected_format": "YYYY-MM-DD",
      ]
    )
  }
  let startOfDay = Calendar.current.startOfDay(for: parsed)
  return (value, startOfDay)
}

func notesSmartFolderCriteriaEndOfDay(_ date: Date) -> Date {
  let calendar = Calendar.current
  let start = calendar.startOfDay(for: date)
  return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? start
}

func normalizedSmartFolderBuiltInCriteria(_ raw: String) throws -> String {
  let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "_", with: "-")
    .localizedLowercase
  if notesSmartFolderBuiltInCriteriaKinds.contains(value) {
    return value
  }
  throw CLIError(
    code: .validationError,
    message: "Unsupported built-in Smart Folder criteria.",
    details: [
      "criteria_sha256": sha256Hex(value),
      "supported": smartFolderBuiltInCriteriaSupportedList(),
    ]
  )
}

func normalizedSmartFolderBuiltInCriteriaList(_ raw: String) throws -> [String] {
  let values = raw.split(separator: ",", omittingEmptySubsequences: false)
    .map {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "_", with: "-")
        .localizedLowercase
    }
  guard values.allSatisfy({ !$0.isEmpty }) else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder criteria list cannot contain empty criteria entries.",
      details: ["criteria_sha256": sha256Hex(raw)]
    )
  }
  let normalized = try values.map(normalizedSmartFolderBuiltInCriteria)
  guard Set(normalized).count == normalized.count else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder criteria list cannot contain duplicate criteria kinds.",
      details: ["criteria_sha256": sha256Hex(normalized.joined(separator: ","))]
    )
  }
  return normalized
}

func effectiveSmartFolderBuiltInCriteriaIncludeRecentlyDeleted(
  kinds: [String],
  requestedIncludeRecentlyDeleted: Bool
) -> Bool {
  requestedIncludeRecentlyDeleted || kinds.contains("recently-deleted-math")
}

func normalizedSmartFolderBuiltInCriteriaMatch(_ raw: String?) throws -> (match: String, joinOperator: Int) {
  guard let raw else {
    return ("all", 1)
  }
  let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "_", with: "-")
    .localizedLowercase
  switch value {
  case "all", "and":
    return ("all", 1)
  case "any", "or":
    return ("any", 0)
  default:
    throw CLIError(
      code: .validationError,
      message: "Unsupported Smart Folder criteria match mode.",
      details: [
        "match_sha256": sha256Hex(value),
        "supported": "all,any",
      ]
    )
  }
}

func validateSmartFolderBuiltInCriteriaOptions(kind: String, includeRecentlyDeleted: Bool) throws {
  guard kind == "recently-deleted-math", includeRecentlyDeleted else {
    return
  }
  throw CLIError(
    code: .validationError,
    message: "Unsupported Smart Folder criteria flag combination.",
    details: [
      "criteria": kind,
      "unsupported_flag": "include-recently-deleted",
      "reason": "recently-deleted-math already selects the recently deleted math-note query.",
    ]
  )
}

func validateSmartFolderBuiltInCriteriaOptions(kinds: [String], includeRecentlyDeleted: Bool) throws {
  for kind in kinds {
    try validateSmartFolderBuiltInCriteriaOptions(kind: kind, includeRecentlyDeleted: includeRecentlyDeleted)
  }
  guard kinds.count > 1 else {
    return
  }
  let gated = kinds.filter { smartFolderBuiltInCriteriaCombinationFilterExpectation(kind: $0) == nil }
  guard gated.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Combined Smart Folder criteria require criteria kinds that can be represented by private filter selections.",
      details: [
        "criteria": kinds.joined(separator: ","),
        "gated_criteria": gated.joined(separator: ","),
        "required_implementation": "typed_private_filter_selection_or_query_factory_combination",
      ]
    )
  }
}

func validateSmartFolderBuiltInCriteriaMatch(kinds: [String], match: String) throws {
  guard match == "any" else {
    return
  }
  guard kinds.count > 1 else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder `--match any` requires multiple criteria.",
      details: [
        "criteria": kinds.joined(separator: ","),
        "required_criteria_count": "2",
      ]
    )
  }
  let gated = kinds.filter { smartFolderBuiltInCriteriaCombinationFilterExpectation(kind: $0) == nil }
  guard gated.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder `--match any` requires criteria kinds that can be represented by private filter selections.",
      details: [
        "criteria": kinds.joined(separator: ","),
        "gated_criteria": gated.joined(separator: ","),
        "required_implementation": "typed_private_filter_selection_join_operator",
      ]
    )
  }
}

func validateSmartFolderDateCriteriaParameters(
  kind: String,
  dateCriteria: NotesSmartFolderDateCriteriaParameters?
) throws {
  guard let descriptor = smartFolderDateCriteriaDescriptor(kind) else {
    if dateCriteria != nil {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder date criteria options require a date-based criteria kind.",
        details: ["criteria": kind]
      )
    }
    return
  }

  switch descriptor.parameterKind {
  case nil:
    if dateCriteria != nil {
      throw CLIError(
        code: .validationError,
        message: "This Smart Folder date criteria kind does not accept custom date parameters.",
        details: ["criteria": kind]
      )
    }
  case "single_date":
    guard let dateCriteria, dateCriteria.primaryDate != nil, dateCriteria.dateText != nil else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder single-date criteria requires `--date YYYY-MM-DD`.",
        details: ["criteria": kind, "required_option": "date"]
      )
    }
    guard dateCriteria.secondaryDate == nil, dateCriteria.startDateText == nil, dateCriteria.endDateText == nil,
      dateCriteria.relativeAmount == nil, dateCriteria.relativeUnit == nil
    else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder single-date criteria only accepts `--date`.",
        details: ["criteria": kind]
      )
    }
  case "range":
    guard let dateCriteria,
      let primaryDate = dateCriteria.primaryDate,
      let secondaryDate = dateCriteria.secondaryDate,
      dateCriteria.startDateText != nil,
      dateCriteria.endDateText != nil
    else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder date range criteria requires `--start-date YYYY-MM-DD` and `--end-date YYYY-MM-DD`.",
        details: ["criteria": kind, "required_options": "start-date,end-date"]
      )
    }
    guard primaryDate <= secondaryDate else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder date range criteria requires `--start-date` to be on or before `--end-date`.",
        details: ["criteria": kind]
      )
    }
    guard dateCriteria.dateText == nil, dateCriteria.relativeAmount == nil, dateCriteria.relativeUnit == nil else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder date range criteria only accepts `--start-date` and `--end-date`.",
        details: ["criteria": kind]
      )
    }
  case "relative":
    guard let dateCriteria,
      let relativeAmount = dateCriteria.relativeAmount,
      let relativeUnit = dateCriteria.relativeUnit,
      dateCriteria.relativeUnitSelectionType != nil
    else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder relative date criteria requires `--relative-amount` and `--relative-unit`.",
        details: ["criteria": kind, "required_options": "relative-amount,relative-unit"]
      )
    }
    guard relativeAmount > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder relative date amount must be greater than zero.",
        details: ["criteria": kind, "relative_amount": "\(relativeAmount)"]
      )
    }
    guard dateCriteria.primaryDate == nil, dateCriteria.secondaryDate == nil, dateCriteria.dateText == nil,
      dateCriteria.startDateText == nil, dateCriteria.endDateText == nil
    else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder relative date criteria only accepts `--relative-amount` and `--relative-unit`.",
        details: ["criteria": kind, "relative_unit": relativeUnit]
      )
    }
  default:
    throw CLIError(
      code: .validationError,
      message: "Unsupported Smart Folder date criteria parameter kind.",
      details: ["criteria": kind]
    )
  }
}

func validateSmartFolderDateCriteriaParameters(
  kinds: [String],
  dateCriteria: NotesSmartFolderDateCriteriaParameters?
) throws {
  let dateKinds = kinds.filter { smartFolderDateCriteriaDescriptor($0) != nil }
  guard !dateKinds.isEmpty else {
    if dateCriteria != nil {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder date criteria options require a date-based criteria kind.",
        details: ["criteria": kinds.joined(separator: ",")]
      )
    }
    return
  }
  for kind in dateKinds {
    try validateSmartFolderDateCriteriaParameters(kind: kind, dateCriteria: dateCriteria)
  }
}

func validateSmartFolderFolderCriteriaParameters(
  kinds: [String],
  folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
  folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:]
) throws {
  let folderKinds = kinds.filter { smartFolderFolderCriteriaInclusionType($0) != nil }
  let unexpectedFolderKinds = folderCriteriaByKind.keys.filter { !folderKinds.contains($0) }.sorted()
  guard !folderKinds.isEmpty else {
    if folderCriteria != nil || !folderCriteriaByKind.isEmpty {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria options require a folder-based criteria kind.",
        details: ["criteria": kinds.joined(separator: ",")]
      )
    }
    return
  }
  guard unexpectedFolderKinds.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder folder criteria options require a folder-based criteria kind.",
      details: [
        "criteria": kinds.joined(separator: ","),
        "unexpected_folder_criteria": unexpectedFolderKinds.joined(separator: ","),
      ]
    )
  }
  var validatedKinds = Set<String>()
  for kind in folderKinds {
    guard let criteria = smartFolderFolderCriteria(
      for: kind,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: folderCriteriaByKind
    ) else {
      let requiredOption =
        folderKinds.count == 1
        ? "criteria-folder"
        : (kind == "folder" ? "include-criteria-folder" : "exclude-criteria-folder")
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria requires `--criteria-folder FOLDER[,FOLDER...]` or the matching include/exclude folder option.",
        details: [
          "criteria": kind,
          "required_option": requiredOption,
        ]
      )
    }
    try validateSmartFolderFolderCriteriaParameters(kind: kind, folderCriteria: criteria)
    validatedKinds.insert(kind)
  }
  let unvalidatedCriteria = folderCriteriaByKind.keys.filter { !validatedKinds.contains($0) }.sorted()
  guard unvalidatedCriteria.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder folder criteria inclusion type did not match the criteria kind.",
      details: ["criteria": unvalidatedCriteria.joined(separator: ",")]
    )
  }
}

func smartFolderFolderCriteria(
  for kind: String,
  folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
  folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:]
) -> NotesSmartFolderFolderCriteriaParameters? {
  if let criteria = folderCriteriaByKind[kind] {
    return criteria
  }
  guard let folderCriteria else {
    return nil
  }
  guard folderCriteria.inclusionType == smartFolderFolderCriteriaInclusionType(kind) else {
    return nil
  }
  return folderCriteria
}

func validateSmartFolderParticipantCriteriaParameters(
  kinds: [String],
  participantCriteria: NotesSmartFolderParticipantCriteriaParameters?
) throws {
  let participantKinds = kinds.filter(smartFolderParticipantCriteriaKind)
  guard !participantKinds.isEmpty else {
    if participantCriteria != nil {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder participant options require a participants or mentions criteria kind.",
        details: ["criteria": kinds.joined(separator: ",")]
      )
    }
    return
  }
  guard let participantCriteria else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder participant criteria requires `--participant-user-id USER_ID`.",
      details: ["criteria": participantKinds.joined(separator: ","), "required_option": "participant-user-id"]
    )
  }
  guard participantCriteria.selectionType == 1 else {
    throw CLIError(
      code: .validationError,
      message: "Smart Folder participant criteria selection type did not match the selected-participant criteria kind.",
      details: ["criteria": participantKinds.joined(separator: ",")]
    )
  }
}

func smartFolderBuiltInCriteriaCreateScopeDigest(_ draft: NotesSmartFolderBuiltInCriteriaCreateDraft) -> String {
  let folderCriteriaSignature = smartFolderFolderCriteriaSignature(
    folderCriteria: draft.folderCriteria,
    folderCriteriaByKind: draft.folderCriteriaByKind
  )
  let fields: [String] = [
    draft.name,
    draft.accountID ?? "",
    draft.accountName,
    draft.criteriaKind,
    draft.criteriaKinds.joined(separator: ","),
    draft.criteriaMatch,
    draft.joinOperator.description,
    draft.includeRecentlyDeleted ? "recently-deleted" : "active-only",
    draft.dateCriteria?.dateText ?? "",
    draft.dateCriteria?.startDateText ?? "",
    draft.dateCriteria?.endDateText ?? "",
    draft.dateCriteria?.relativeAmount.map(String.init) ?? "",
    draft.dateCriteria?.relativeUnit ?? "",
    folderCriteriaSignature,
    draft.participantCriteria?.participantUserIDSHA256 ?? "",
    draft.participantCriteria?.selectionType.description ?? "",
    draft.participantCriteria?.joinOperator.description ?? "",
  ]
  return "notes-smart-folder-create-built-in-criteria:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderBuiltInCriteriaCreateSummary(
  _ draft: NotesSmartFolderBuiltInCriteriaCreateDraft
) -> [String: String] {
  var summary = [
    "name": draft.name,
    "account": draft.accountName,
    "criteria_kind": draft.criteriaKind,
    "criteria_kinds": draft.criteriaKinds.joined(separator: ","),
    "criteria_count": "\(draft.criteriaKinds.count)",
    "match": draft.criteriaMatch,
    "join_operator": "\(draft.joinOperator)",
    "include_recently_deleted": draft.includeRecentlyDeleted ? "true" : "false",
  ]
  if let dateCriteria = draft.dateCriteria {
    summary.merge(smartFolderDateCriteriaSummary(dateCriteria), uniquingKeysWith: { _, new in new })
  }
  if let folderCriteria = draft.folderCriteria {
    summary.merge(smartFolderFolderCriteriaSummary(folderCriteria), uniquingKeysWith: { _, new in new })
  }
  summary.merge(
    smartFolderFolderCriteriaByKindSummary(
      folderCriteria: draft.folderCriteria,
      folderCriteriaByKind: draft.folderCriteriaByKind
    ),
    uniquingKeysWith: { _, new in new }
  )
  if let participantCriteria = draft.participantCriteria {
    summary.merge(smartFolderParticipantCriteriaSummary(participantCriteria), uniquingKeysWith: { _, new in new })
  }
  if let accountID = draft.accountID {
    summary["account_id"] = accountID
  }
  return summary
}

func smartFolderBuiltInCriteriaUpdateScopeDigest(_ draft: NotesSmartFolderBuiltInCriteriaUpdateDraft) -> String {
  let folderCriteriaSignature = smartFolderFolderCriteriaSignature(
    folderCriteria: draft.folderCriteria,
    folderCriteriaByKind: draft.folderCriteriaByKind
  )
  let fields: [String] = [
    draft.smartFolderID,
    draft.name,
    draft.accountName,
    draft.previousQueryPresent ? "query" : "no-query",
    draft.previousQuerySHA256 ?? "",
    draft.previousVisibleNoteCount.map(String.init) ?? "",
    draft.criteriaKind,
    draft.criteriaKinds.joined(separator: ","),
    draft.criteriaMatch,
    draft.joinOperator.description,
    draft.includeRecentlyDeleted ? "recently-deleted" : "active-only",
    draft.dateCriteria?.dateText ?? "",
    draft.dateCriteria?.startDateText ?? "",
    draft.dateCriteria?.endDateText ?? "",
    draft.dateCriteria?.relativeAmount.map(String.init) ?? "",
    draft.dateCriteria?.relativeUnit ?? "",
    folderCriteriaSignature,
    draft.participantCriteria?.participantUserIDSHA256 ?? "",
    draft.participantCriteria?.selectionType.description ?? "",
    draft.participantCriteria?.joinOperator.description ?? "",
  ]
  return "notes-smart-folder-update-built-in-criteria:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderBuiltInCriteriaUpdateSummary(
  _ draft: NotesSmartFolderBuiltInCriteriaUpdateDraft
) -> [String: String] {
  var summary = [
    "smart_folder_id": draft.smartFolderID,
    "name": draft.name,
    "account": draft.accountName,
    "previous_query_present": draft.previousQueryPresent ? "true" : "false",
    "criteria_kind": draft.criteriaKind,
    "criteria_kinds": draft.criteriaKinds.joined(separator: ","),
    "criteria_count": "\(draft.criteriaKinds.count)",
    "match": draft.criteriaMatch,
    "join_operator": "\(draft.joinOperator)",
    "include_recently_deleted": draft.includeRecentlyDeleted ? "true" : "false",
  ]
  if let dateCriteria = draft.dateCriteria {
    summary.merge(smartFolderDateCriteriaSummary(dateCriteria), uniquingKeysWith: { _, new in new })
  }
  if let folderCriteria = draft.folderCriteria {
    summary.merge(smartFolderFolderCriteriaSummary(folderCriteria), uniquingKeysWith: { _, new in new })
  }
  summary.merge(
    smartFolderFolderCriteriaByKindSummary(
      folderCriteria: draft.folderCriteria,
      folderCriteriaByKind: draft.folderCriteriaByKind
    ),
    uniquingKeysWith: { _, new in new }
  )
  if let participantCriteria = draft.participantCriteria {
    summary.merge(smartFolderParticipantCriteriaSummary(participantCriteria), uniquingKeysWith: { _, new in new })
  }
  if let previousQuerySHA256 = draft.previousQuerySHA256 {
    summary["previous_query_sha256"] = previousQuerySHA256
  }
  if let previousVisibleNoteCount = draft.previousVisibleNoteCount {
    summary["previous_visible_note_count"] = "\(previousVisibleNoteCount)"
  }
  return summary
}

func smartFolderFolderCriteriaSummary(_ criteria: NotesSmartFolderFolderCriteriaParameters) -> [String: String] {
  [
    "criteria_folder": criteria.folderNames.joined(separator: ","),
    "criteria_folder_count": "\(criteria.folderIDs.count)",
    "criteria_folder_id_sha256": sha256Hex(criteria.folderIDs.joined(separator: "\0")),
    "criteria_folder_account": criteria.folderAccountName,
    "criteria_folder_inclusion_type": "\(criteria.inclusionType)",
  ]
}

func smartFolderFolderCriteriaByKindSummary(
  folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
  folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]
) -> [String: String] {
  let entries = smartFolderFolderCriteriaEntries(
    folderCriteria: folderCriteria,
    folderCriteriaByKind: folderCriteriaByKind
  )
  guard entries.count > 1 else {
    return [:]
  }
  var summary: [String: String] = [
    "criteria_folder_kinds": entries.map { $0.kind }.joined(separator: ","),
    "criteria_folder_total_count": "\(entries.reduce(0) { $0 + $1.criteria.folderIDs.count })",
  ]
  for entry in entries {
    let prefix = entry.kind == "folder" ? "include_criteria_folder" : "exclude_criteria_folder"
    summary["\(prefix)"] = entry.criteria.folderNames.joined(separator: ",")
    summary["\(prefix)_count"] = "\(entry.criteria.folderIDs.count)"
    summary["\(prefix)_id_sha256"] = sha256Hex(entry.criteria.folderIDs.joined(separator: "\0"))
    summary["\(prefix)_account"] = entry.criteria.folderAccountName
    summary["\(prefix)_inclusion_type"] = "\(entry.criteria.inclusionType)"
  }
  return summary
}

func smartFolderFolderCriteriaSignature(
  folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
  folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]
) -> String {
  smartFolderFolderCriteriaEntries(
    folderCriteria: folderCriteria,
    folderCriteriaByKind: folderCriteriaByKind
  )
  .map { entry in
    [
      entry.kind,
      "\(entry.criteria.inclusionType)",
      entry.criteria.folderAccountName,
      entry.criteria.folderIDs.joined(separator: "\0"),
    ].joined(separator: ":")
  }
  .joined(separator: "|")
}

private func smartFolderFolderCriteriaEntries(
  folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
  folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]
) -> [(kind: String, criteria: NotesSmartFolderFolderCriteriaParameters)] {
  if !folderCriteriaByKind.isEmpty {
    return folderCriteriaByKind.keys.sorted().compactMap { kind in
      folderCriteriaByKind[kind].map { (kind: kind, criteria: $0) }
    }
  }
  guard let folderCriteria else {
    return []
  }
  switch folderCriteria.inclusionType {
  case 1:
    return [(kind: "folder", criteria: folderCriteria)]
  case 0:
    return [(kind: "not-folder", criteria: folderCriteria)]
  default:
    return []
  }
}

func smartFolderParticipantCriteriaSummary(
  _ criteria: NotesSmartFolderParticipantCriteriaParameters
) -> [String: String] {
  [
    "participant_user_id_sha256": criteria.participantUserIDSHA256,
    "participant_user_id_count": "1",
    "participant_selection_type": "\(criteria.selectionType)",
    "participant_join_operator": "\(criteria.joinOperator)",
  ]
}

func smartFolderDateCriteriaSummary(_ criteria: NotesSmartFolderDateCriteriaParameters) -> [String: String] {
  var summary: [String: String] = [:]
  if let dateText = criteria.dateText {
    summary["date"] = dateText
  }
  if let startDateText = criteria.startDateText {
    summary["start_date"] = startDateText
  }
  if let endDateText = criteria.endDateText {
    summary["end_date"] = endDateText
  }
  if let relativeAmount = criteria.relativeAmount {
    summary["relative_amount"] = "\(relativeAmount)"
  }
  if let relativeUnit = criteria.relativeUnit {
    summary["relative_unit"] = relativeUnit
  }
  return summary
}

func smartFolderFilterMutationScopeDigest(_ draft: NotesSmartFolderFilterMutationDraft) -> String {
  let updateDigest = smartFolderBuiltInCriteriaUpdateScopeDigest(draft.updateDraft)
  let fields = [
    draft.mutationKind,
    String(draft.ordinal),
    draft.criteriaKind ?? "",
    draft.previousCriteriaKinds.joined(separator: ","),
    draft.resultingCriteriaKinds.joined(separator: ","),
    updateDigest,
  ]
  return "notes-smart-folder-filter-mutation:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderFilterMutationSummary(
  _ draft: NotesSmartFolderFilterMutationDraft
) -> [String: String] {
  var summary = smartFolderBuiltInCriteriaUpdateSummary(draft.updateDraft)
  summary["filter_mutation"] = draft.mutationKind
  summary["filter_ordinal"] = String(draft.ordinal)
  summary["previous_criteria_kinds"] = draft.previousCriteriaKinds.joined(separator: ",")
  summary["resulting_criteria_kinds"] = draft.resultingCriteriaKinds.joined(separator: ",")
  if let criteriaKind = draft.criteriaKind {
    summary["filter_criteria_kind"] = criteriaKind
  }
  return summary
}

func smartFolderDuplicateScopeDigest(_ draft: NotesSmartFolderDuplicateDraft) -> String {
  let fields: [String] = [
    draft.sourceSmartFolderID,
    draft.sourceName,
    draft.name,
    draft.accountName,
    draft.sourceQueryPresent ? "query" : "no-query",
    draft.sourceQuerySHA256 ?? "",
    draft.sourceVisibleNoteCount.map { String($0) } ?? "",
    draft.sourceCriteria?.queryKind ?? "",
    draft.sourceCriteria.map { "\($0.filterCount)" } ?? "",
    "\(draft.sourceMatchingNoteCount)",
  ]
  return "notes-smart-folder-duplicate:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderDuplicateSummary(_ draft: NotesSmartFolderDuplicateDraft) -> [String: String] {
  var summary = [
    "source_smart_folder_id": draft.sourceSmartFolderID,
    "source_name": draft.sourceName,
    "name": draft.name,
    "account": draft.accountName,
    "source_query_present": draft.sourceQueryPresent ? "true" : "false",
    "source_matching_note_count": "\(draft.sourceMatchingNoteCount)",
  ]
  if let sourceQuerySHA256 = draft.sourceQuerySHA256 {
    summary["source_query_sha256"] = sourceQuerySHA256
  }
  if let sourceVisibleNoteCount = draft.sourceVisibleNoteCount {
    summary["source_visible_note_count"] = "\(sourceVisibleNoteCount)"
  }
  if let sourceCriteria = draft.sourceCriteria {
    summary["source_criteria_kind"] = sourceCriteria.queryKind
    summary["source_filter_count"] = "\(sourceCriteria.filterCount)"
  }
  return summary
}

func smartFolderCriteriaCopyScopeDigest(_ draft: NotesSmartFolderCriteriaCopyDraft) -> String {
  let fields: [String] = [
    draft.sourceSmartFolderID,
    draft.sourceName,
    draft.targetSmartFolderID,
    draft.targetName,
    draft.accountName,
    draft.sourceQueryPresent ? "query" : "no-query",
    draft.sourceQuerySHA256 ?? "",
    draft.sourceVisibleNoteCount.map { String($0) } ?? "",
    draft.sourceCriteria?.queryKind ?? "",
    draft.sourceCriteria.map { "\($0.filterCount)" } ?? "",
    "\(draft.sourceMatchingNoteCount)",
    draft.targetPreviousQueryPresent ? "target-query" : "target-no-query",
    draft.targetPreviousQuerySHA256 ?? "",
    draft.targetPreviousVisibleNoteCount.map { String($0) } ?? "",
  ]
  return "notes-smart-folder-copy-criteria:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderCriteriaCopySummary(_ draft: NotesSmartFolderCriteriaCopyDraft) -> [String: String] {
  var summary = [
    "source_smart_folder_id": draft.sourceSmartFolderID,
    "source_name": draft.sourceName,
    "target_smart_folder_id": draft.targetSmartFolderID,
    "target_name": draft.targetName,
    "account": draft.accountName,
    "source_query_present": draft.sourceQueryPresent ? "true" : "false",
    "source_matching_note_count": "\(draft.sourceMatchingNoteCount)",
    "target_previous_query_present": draft.targetPreviousQueryPresent ? "true" : "false",
  ]
  if let sourceQuerySHA256 = draft.sourceQuerySHA256 {
    summary["source_query_sha256"] = sourceQuerySHA256
  }
  if let sourceVisibleNoteCount = draft.sourceVisibleNoteCount {
    summary["source_visible_note_count"] = "\(sourceVisibleNoteCount)"
  }
  if let sourceCriteria = draft.sourceCriteria {
    summary["source_criteria_kind"] = sourceCriteria.queryKind
    summary["source_filter_count"] = "\(sourceCriteria.filterCount)"
  }
  if let targetPreviousQuerySHA256 = draft.targetPreviousQuerySHA256 {
    summary["target_previous_query_sha256"] = targetPreviousQuerySHA256
  }
  if let targetPreviousVisibleNoteCount = draft.targetPreviousVisibleNoteCount {
    summary["target_previous_visible_note_count"] = "\(targetPreviousVisibleNoteCount)"
  }
  return summary
}

func smartFolderCriteriaImportScopeDigest(_ draft: NotesSmartFolderCriteriaImportDraft) -> String {
  let fields: [String] = [
    draft.smartFolderID,
    draft.name,
    draft.accountName,
    draft.previousQueryPresent ? "query" : "no-query",
    draft.previousQuerySHA256 ?? "",
    draft.previousVisibleNoteCount.map { String($0) } ?? "",
    draft.sourcePath,
    "\(draft.sourceByteCount)",
    draft.sourceSHA256,
  ]
  return "notes-smart-folder-import-criteria:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderCriteriaImportSummary(_ draft: NotesSmartFolderCriteriaImportDraft) -> [String: String] {
  var summary = [
    "smart_folder_id": draft.smartFolderID,
    "name": draft.name,
    "account": draft.accountName,
    "previous_query_present": draft.previousQueryPresent ? "true" : "false",
    "source_path": draft.sourcePath,
    "source_byte_count": "\(draft.sourceByteCount)",
    "source_sha256": draft.sourceSHA256,
  ]
  if let previousQuerySHA256 = draft.previousQuerySHA256 {
    summary["previous_query_sha256"] = previousQuerySHA256
  }
  if let previousVisibleNoteCount = draft.previousVisibleNoteCount {
    summary["previous_visible_note_count"] = "\(previousVisibleNoteCount)"
  }
  return summary
}

func smartFolderRenameScopeDigest(_ draft: NotesSmartFolderRenameDraft) -> String {
  let fields = [
    draft.smartFolderID,
    draft.currentName,
    draft.newName,
    draft.accountName,
    draft.queryPresent ? "query" : "no-query",
    draft.querySHA256 ?? "",
    draft.visibleNoteCount.map(String.init) ?? "",
  ]
  return "notes-smart-folder-rename:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderRenameSummary(_ draft: NotesSmartFolderRenameDraft) -> [String: String] {
  var summary = [
    "smart_folder_id": draft.smartFolderID,
    "from_name": draft.currentName,
    "to_name": draft.newName,
    "account": draft.accountName,
    "query_present": draft.queryPresent ? "true" : "false",
  ]
  if let visibleNoteCount = draft.visibleNoteCount {
    summary["visible_note_count"] = "\(visibleNoteCount)"
  }
  return summary
}

func smartFolderDeleteScopeDigest(_ draft: NotesSmartFolderDeleteDraft) -> String {
  let fields = [
    draft.smartFolderID,
    draft.name,
    draft.accountName,
    draft.queryPresent ? "query" : "no-query",
    draft.visibleNoteCount.map(String.init) ?? "",
  ]
  return "notes-smart-folder-delete:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderDeleteSummary(_ draft: NotesSmartFolderDeleteDraft) -> [String: String] {
  var summary = [
    "smart_folder_id": draft.smartFolderID,
    "name": draft.name,
    "account": draft.accountName,
    "query_present": draft.queryPresent ? "true" : "false",
  ]
  if let visibleNoteCount = draft.visibleNoteCount {
    summary["visible_note_count"] = "\(visibleNoteCount)"
  }
  return summary
}

func smartFolderFolderConversionScopeDigest(_ draft: NotesSmartFolderFolderConversionDraft) -> String {
  let fields = [
    draft.folderID,
    draft.folderName,
    draft.accountName,
    draft.parentID ?? "",
    "\(draft.visibleNoteCount)",
    "\(draft.childFolderCount)",
    draft.noteIDHashes.joined(separator: "\0"),
    draft.tagStandardizedContent,
    draft.targetFolderID ?? "",
    draft.targetFolderName ?? "",
  ]
  return "notes-smart-folder-convert-folder:\(sha256Hex(fields.joined(separator: "|")))"
}

func smartFolderFolderConversionSummary(_ draft: NotesSmartFolderFolderConversionDraft) -> [String: String] {
  var summary = [
    "folder_id": draft.folderID,
    "folder_name": draft.folderName,
    "account": draft.accountName,
    "visible_note_count": "\(draft.visibleNoteCount)",
    "child_folder_count": "\(draft.childFolderCount)",
    "note_count": "\(draft.noteIDHashes.count)",
    "note_id_hashes_sha256": sha256Hex(draft.noteIDHashes.joined(separator: "\0")),
    "tag": draft.tagDisplayText,
    "tag_standardized_content": draft.tagStandardizedContent,
  ]
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  if let targetFolderID = draft.targetFolderID {
    summary["target_folder_id"] = targetFolderID
  }
  if let targetFolderName = draft.targetFolderName {
    summary["target_folder_name"] = targetFolderName
  }
  return summary
}

func folderRenameScopeDigest(_ draft: NotesFolderRenameDraft) -> String {
  let fields = [
    draft.folderID,
    draft.currentName,
    draft.accountName,
    draft.parentID ?? "",
    draft.parentName ?? "",
    draft.name,
  ]
  return "notes-folder-rename:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderRenameSummary(_ draft: NotesFolderRenameDraft) -> [String: String] {
  var summary = [
    "folder_id": draft.folderID,
    "from_name": draft.currentName,
    "to_name": draft.name,
    "account": draft.accountName,
  ]
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  if let parentName = draft.parentName {
    summary["parent"] = parentName
  }
  return summary
}

func folderMoveScopeDigest(_ draft: NotesFolderMoveDraft) -> String {
  let fields = [
    draft.folderID,
    draft.name,
    draft.sourceAccountName,
    draft.accountName,
    draft.accountID ?? "",
    draft.currentParentID ?? "",
    draft.parentID ?? "",
    draft.parentName ?? "",
    draft.descendantIDs.sorted().joined(separator: ","),
  ]
  return "notes-folder-move:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderMoveSummary(_ draft: NotesFolderMoveDraft) -> [String: String] {
  var summary = [
    "folder_id": draft.folderID,
    "name": draft.name,
    "account": draft.accountName,
    "source_account": draft.sourceAccountName,
    "target_account": draft.accountName,
    "descendant_count": "\(draft.descendantIDs.count)",
  ]
  if let accountID = draft.accountID {
    summary["target_account_id"] = accountID
  }
  if let parentID = draft.parentID {
    summary["to_parent_id"] = parentID
  } else {
    summary["to_root"] = "true"
  }
  if let parentName = draft.parentName {
    summary["to_parent"] = parentName
  }
  if let currentParentID = draft.currentParentID {
    summary["from_parent_id"] = currentParentID
  }
  return summary
}

func folderDeleteScopeDigest(_ draft: NotesFolderDeleteDraft) -> String {
  let fields = [
    draft.folderID,
    draft.name,
    draft.accountName,
    draft.parentID ?? "",
    draft.visibleNoteCount.map(String.init) ?? "",
    draft.childFolderCount.map(String.init) ?? "",
  ]
  return "notes-folder-delete:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderDeleteSummary(_ draft: NotesFolderDeleteDraft) -> [String: String] {
  var summary = [
    "folder_id": draft.folderID,
    "name": draft.name,
    "account": draft.accountName,
  ]
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  if let visibleNoteCount = draft.visibleNoteCount {
    summary["visible_note_count"] = "\(visibleNoteCount)"
  }
  if let childFolderCount = draft.childFolderCount {
    summary["child_folder_count"] = "\(childFolderCount)"
  }
  return summary
}

func folderPurgeScopeDigest(_ draft: NotesFolderPurgeDraft) -> String {
  let fields = [
    draft.folderID,
    draft.name,
    draft.accountName,
    draft.parentID ?? "",
    draft.visibleNoteCount.map(String.init) ?? "",
    draft.childFolderCount.map(String.init) ?? "",
  ]
  return "notes-folder-purge:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderPurgeSummary(_ draft: NotesFolderPurgeDraft) -> [String: String] {
  var summary = [
    "folder_id": draft.folderID,
    "name": draft.name,
    "account": draft.accountName,
  ]
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  if let visibleNoteCount = draft.visibleNoteCount {
    summary["visible_note_count"] = "\(visibleNoteCount)"
  }
  if let childFolderCount = draft.childFolderCount {
    summary["child_folder_count"] = "\(childFolderCount)"
  }
  return summary
}

func folderSortScopeDigest(_ draft: NotesFolderSortDraft) -> String {
  let fields = [
    draft.folderID,
    draft.name,
    draft.accountName,
    draft.parentID ?? "",
    draft.by,
    draft.direction,
    "\(draft.sortOrder)",
    "\(draft.sortDirection)",
    "\(draft.sortValue)",
  ]
  return "notes-folder-sort:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderSortSummary(_ draft: NotesFolderSortDraft, current: NotesFolderRecord) -> [String: String] {
  var summary: [String: String] = [:]
  summary["folder_id"] = draft.folderID
  summary["name"] = draft.name
  summary["account"] = draft.accountName
  summary["by"] = draft.by
  summary["direction"] = draft.direction
  summary["sort_order"] = String(draft.sortOrder)
  summary["sort_direction"] = String(draft.sortDirection)
  summary["sort_value"] = String(draft.sortValue)
  summary["current_sort_value"] = current.noteSortTypeValue.map(String.init) ?? ""
  summary["current_sort_order"] = current.customNoteSortOrder.map(String.init) ?? ""
  summary["current_sort_direction"] = current.customNoteSortDirection.map(String.init) ?? ""
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  return summary
}

func folderReorderScopeDigest(_ draft: NotesFolderReorderDraft) -> String {
  let fields = [
    draft.folderID,
    draft.accountName,
    draft.parentID ?? "",
    draft.referenceFolderID,
    draft.placement,
    "\(draft.requestedIndex)",
    draft.currentIndex.map(String.init) ?? "",
    draft.siblingOrderCount.map(String.init) ?? "",
  ]
  return "notes-folder-reorder:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderReorderSummary(
  _ draft: NotesFolderReorderDraft,
  current: NotesFolderRecord
) -> [String: String] {
  var summary: [String: String] = [:]
  summary["folder_id_sha256"] = sha256Hex(draft.folderID)
  summary["reference_folder_id_sha256"] = sha256Hex(draft.referenceFolderID)
  summary["account_sha256"] = sha256Hex(draft.accountName)
  summary["placement"] = draft.placement
  summary["requested_index"] = "\(draft.requestedIndex)"
  summary["current_index"] = draft.currentIndex.map(String.init) ?? ""
  summary["current_readback_index"] = current.siblingOrderIndex.map(String.init) ?? ""
  summary["sibling_order_count"] = draft.siblingOrderCount.map(String.init) ?? ""
  if let parentID = draft.parentID {
    summary["parent_id_sha256"] = sha256Hex(parentID)
  } else {
    summary["root_level"] = "true"
  }
  if let currentOrderHash = current.siblingOrderSHA256 {
    summary["current_sibling_order_sha256"] = currentOrderHash
  }
  return summary
}

func folderDateHeadersScopeDigest(_ draft: NotesFolderDateHeadersDraft) -> String {
  let fields = [
    draft.folderID,
    draft.name,
    draft.accountName,
    draft.parentID ?? "",
    "\(draft.enabled)",
    "\(draft.privateValue)",
  ]
  return "notes-folder-date-headers:\(sha256Hex(fields.joined(separator: "|")))"
}

func folderDateHeadersSummary(
  _ draft: NotesFolderDateHeadersDraft,
  current: NotesFolderRecord
) -> [String: String] {
  var summary: [String: String] = [:]
  summary["folder_id"] = draft.folderID
  summary["name"] = draft.name
  summary["account"] = draft.accountName
  summary["enabled"] = String(draft.enabled)
  summary["current_enabled"] = current.isShowingDateHeaders.map(String.init) ?? ""
  summary["date_headers_type_value"] = "\(draft.privateValue)"
  summary["current_date_headers_type_value"] = current.dateHeadersTypeValue.map(String.init) ?? ""
  if let parentID = draft.parentID {
    summary["parent_id"] = parentID
  }
  return summary
}

func noteIdentityScopeDigest(_ note: NotesNoteDetail) -> String {
  let fields = [
    note.id,
    note.title,
    note.folderName,
    note.accountName,
    note.createdAt.map(formatDate) ?? "",
    note.updatedAt.map(formatDate) ?? "",
    sha256Hex(note.body ?? ""),
  ]
  return "notes-note:\(sha256Hex(fields.joined(separator: "|")))"
}

func updateScopeDigest(current: NotesNoteDetail, patch: NotesUpdatePatch) -> String {
  let fields = [
    noteIdentityScopeDigest(current),
    patch.title ?? "",
    patch.body.map(sha256Hex) ?? "",
    patch.appendBody.map(sha256Hex) ?? "",
  ]
  return "notes-update:\(sha256Hex(fields.joined(separator: "|")))"
}

func updateSummary(current: NotesNoteDetail, patch: NotesUpdatePatch) -> [String: String] {
  var summary = [
    "id": current.id,
    "title": current.title,
    "folder": current.folderName,
    "account": current.accountName,
    "current_body_sha256": sha256Hex(current.body ?? ""),
  ]
  if let title = patch.title {
    summary["new_title"] = title
  }
  if let body = patch.body {
    summary["new_body_sha256"] = sha256Hex(body)
  }
  if let appendBody = patch.appendBody {
    summary["append_body_sha256"] = sha256Hex(appendBody)
  }
  return summary
}

func bodyChecklistAddScopeDigest(_ draft: NotesBodyChecklistAddDraft) -> String {
  let fields = [
    draft.noteID,
    sha256Hex(draft.text),
    draft.checked ? "checked" : "open",
  ]
  return "notes-body-checklist-add:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistAddSummary(_ draft: NotesBodyChecklistAddDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "text_sha256": sha256Hex(draft.text),
    "text_byte_count": "\(draft.text.utf8.count)",
    "checked": String(draft.checked),
  ]
}

func normalizedBodyTableText(_ raw: String) throws -> (text: String, rowCount: Int, maxColumnCount: Int) {
  guard raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--text` must contain table text.")
  }
  guard raw.utf8.count <= 65_536 else {
    throw CLIError(
      code: .validationError,
      message: "Notes table text is too large for a single table create command.",
      details: [
        "text_sha256": sha256Hex(raw),
        "max_bytes": "65536",
      ]
    )
  }
  guard raw.unicodeScalars.allSatisfy({ $0.value != 0 }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes table text cannot contain NUL characters.",
      details: ["text_sha256": sha256Hex(raw)]
    )
  }

  let rows = raw.components(separatedBy: CharacterSet.newlines)
  let rowCount = max(1, rows.count)
  let maxColumnCount = max(1, rows.map { $0.components(separatedBy: "\t").count }.max() ?? 1)
  return (raw, rowCount, maxColumnCount)
}

func normalizedBodyTableImportFormat(_ raw: String?) throws -> String {
  let value = (raw ?? "tsv").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  switch value {
  case "tsv", "tab", "tab-separated", "tab-separated-values":
    return "tsv"
  case "csv", "comma", "comma-separated", "comma-separated-values":
    return "csv"
  default:
    throw CLIError(
      code: .validationError,
      message: "`--format` must be `tsv` or `csv`.",
      details: ["format_sha256": sha256Hex(value)]
    )
  }
}

func normalizedBodyTableImportText(
  source: String,
  format rawFormat: String?
) throws -> (sourceFormat: String, text: String, rowCount: Int, maxColumnCount: Int) {
  let format = try normalizedBodyTableImportFormat(rawFormat)
  switch format {
  case "tsv":
    let normalized = try normalizedBodyTableText(source)
    return (format, normalized.text, normalized.rowCount, normalized.maxColumnCount)
  case "csv":
    let tableText = try normalizedCSVTableImportText(source)
    let normalized = try normalizedBodyTableText(tableText)
    return (format, normalized.text, normalized.rowCount, normalized.maxColumnCount)
  default:
    throw CLIError(code: .internalError, message: "Unknown Notes body table import format.")
  }
}

private func normalizedCSVTableImportText(_ raw: String) throws -> String {
  guard raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--text` or `--file` must contain CSV table text.")
  }
  guard raw.utf8.count <= 65_536 else {
    throw CLIError(
      code: .validationError,
      message: "Notes CSV table text is too large for a single table import command.",
      details: [
        "text_sha256": sha256Hex(raw),
        "max_bytes": "65536",
      ]
    )
  }
  guard raw.unicodeScalars.allSatisfy({ $0.value != 0 }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes CSV table text cannot contain NUL characters.",
      details: ["text_sha256": sha256Hex(raw)]
    )
  }

  let rows = try parseCSVRows(raw)
  guard rows.isEmpty == false else {
    throw CLIError(code: .validationError, message: "CSV table import produced no rows.")
  }
  for row in rows {
    guard row.isEmpty == false else {
      throw CLIError(code: .validationError, message: "CSV table import produced an empty row.")
    }
    for cell in row {
      if cell.rangeOfCharacter(from: CharacterSet(charactersIn: "\t\r\n")) != nil {
        throw CLIError(
          code: .validationError,
          message: "CSV cells containing tabs or newlines cannot be imported losslessly as a Notes table.",
          details: ["cell_sha256": sha256Hex(cell)]
        )
      }
    }
  }
  return rows.map { row in row.joined(separator: "\t") }.joined(separator: "\n")
}

private func parseCSVRows(_ raw: String) throws -> [[String]] {
  var rows: [[String]] = []
  var row: [String] = []
  var field = ""
  var index = raw.startIndex
  var inQuotes = false
  var justClosedQuote = false
  var endedWithRowSeparator = false

  func appendField() {
    row.append(field)
    field = ""
    justClosedQuote = false
  }

  func appendRow() {
    appendField()
    rows.append(row)
    row = []
    endedWithRowSeparator = true
  }

  while index < raw.endIndex {
    let character = raw[index]
    let next = raw.index(after: index)
    switch character {
    case "\"":
      endedWithRowSeparator = false
      if inQuotes, next < raw.endIndex, raw[next] == "\"" {
        field.append("\"")
        index = raw.index(after: next)
        justClosedQuote = false
        continue
      }
      if inQuotes {
        inQuotes = false
        justClosedQuote = true
      } else if field.isEmpty {
        inQuotes = true
        justClosedQuote = false
      } else {
        throw CLIError(
          code: .validationError,
          message: "CSV quote appeared in an unquoted field.",
          details: ["text_sha256": sha256Hex(raw)]
        )
      }
    case "," where !inQuotes:
      appendField()
      endedWithRowSeparator = false
    case "\n" where !inQuotes:
      appendRow()
    case "\r" where !inQuotes:
      appendRow()
      if next < raw.endIndex, raw[next] == "\n" {
        index = raw.index(after: next)
        continue
      }
    default:
      if justClosedQuote {
        throw CLIError(
          code: .validationError,
          message: "CSV quoted field must be followed by a comma or row break.",
          details: ["text_sha256": sha256Hex(raw)]
        )
      }
      field.append(character)
      endedWithRowSeparator = false
    }
    index = next
  }

  guard !inQuotes else {
    throw CLIError(
      code: .validationError,
      message: "CSV table import has an unterminated quoted field.",
      details: ["text_sha256": sha256Hex(raw)]
    )
  }
  if !endedWithRowSeparator || !row.isEmpty || !field.isEmpty {
    appendField()
    rows.append(row)
  }
  return rows
}

func normalizedBodyTableCellText(_ raw: String) throws -> String {
  guard raw.utf8.count <= 65_536 else {
    throw CLIError(
      code: .validationError,
      message: "Notes table cell text is too large for a single table update command.",
      details: [
        "text_sha256": sha256Hex(raw),
        "max_bytes": "65536",
      ]
    )
  }
  guard raw.unicodeScalars.allSatisfy({ $0.value != 0 }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes table cell text cannot contain NUL characters.",
      details: ["text_sha256": sha256Hex(raw)]
    )
  }
  return raw
}

func normalizedBodyMathResultText(_ raw: String) throws -> String {
  guard raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--text` must contain math result text.")
  }
  let value = raw
  guard value.utf8.count <= 16_384 else {
    throw CLIError(
      code: .validationError,
      message: "Notes math result text is too large for a single math update command.",
      details: [
        "text_sha256": sha256Hex(value),
        "max_bytes": "16384",
      ]
    )
  }
  guard value.unicodeScalars.allSatisfy({ $0.value != 0 }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes math result text cannot contain NUL characters.",
      details: ["text_sha256": sha256Hex(value)]
    )
  }
  return value
}

func normalizedBodyMathExpressionText(_ raw: String) throws -> String {
  guard raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--text` must contain math expression text.")
  }
  let value = raw
  guard value.utf8.count <= 16_384 else {
    throw CLIError(
      code: .validationError,
      message: "Notes math expression text is too large for a single math insert command.",
      details: [
        "text_sha256": sha256Hex(value),
        "max_bytes": "16384",
      ]
    )
  }
  guard value.unicodeScalars.allSatisfy({ $0.value != 0 }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes math expression text cannot contain NUL characters.",
      details: ["text_sha256": sha256Hex(value)]
    )
  }
  return value
}

func normalizedBodyMathVariableName(_ raw: String) throws -> String {
  let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
  guard value.isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--name` must contain a Notes math variable name.")
  }
  guard value.utf8.count <= 512 else {
    throw CLIError(
      code: .validationError,
      message: "Notes math variable name is too large for a single variable command.",
      details: [
        "name_sha256": sha256Hex(value),
        "max_bytes": "512",
      ]
    )
  }
  guard value.unicodeScalars.allSatisfy({ $0.value != 0 && !CharacterSet.newlines.contains($0) }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes math variable name cannot contain NUL or newline characters.",
      details: ["name_sha256": sha256Hex(value)]
    )
  }
  guard value.unicodeScalars.allSatisfy({ notesMathVariableLatinAlphabet.contains($0) }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes math variable name must use only Latin alphabet letters.",
      details: [
        "name_sha256": sha256Hex(value),
        "allowed": "A-Z,a-z",
      ]
    )
  }
  return value
}

func normalizedBodyMathVariableValue(_ raw: String) throws -> String {
  let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
  guard value.isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--value` must contain a Notes math variable value.")
  }
  guard value.utf8.count <= 16_384 else {
    throw CLIError(
      code: .validationError,
      message: "Notes math variable value is too large for a single variable command.",
      details: [
        "value_sha256": sha256Hex(value),
        "max_bytes": "16384",
      ]
    )
  }
  guard value.unicodeScalars.allSatisfy({ $0.value != 0 && !CharacterSet.newlines.contains($0) }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes math variable value cannot contain NUL or newline characters.",
      details: ["value_sha256": sha256Hex(value)]
    )
  }
  return value
}

func normalizedBodyMathVariableExpression(_ raw: String) throws -> String {
  var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
  if value.hasSuffix("=") {
    value.removeLast()
    value = value.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  guard value.isEmpty == false else {
    throw CLIError(code: .validationError, message: "`--expression` must contain a Notes math expression.")
  }
  guard value.utf8.count <= 16_384 else {
    throw CLIError(
      code: .validationError,
      message: "Notes math expression is too large for a single variable command.",
      details: [
        "expression_sha256": sha256Hex(value),
        "max_bytes": "16384",
      ]
    )
  }
  guard value.unicodeScalars.allSatisfy({ $0.value != 0 && !CharacterSet.newlines.contains($0) }) else {
    throw CLIError(
      code: .validationError,
      message: "Notes math expression cannot contain NUL or newline characters.",
      details: ["expression_sha256": sha256Hex(value)]
    )
  }
  return value
}

func bodyTableCreateScopeDigest(_ draft: NotesBodyTableCreateDraft) -> String {
  let fields = [
    draft.noteID,
    draft.textSHA256,
    "\(draft.rowCount)",
    "\(draft.maxColumnCount)",
  ]
  return "notes-body-table-create:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableCreateSummary(_ draft: NotesBodyTableCreateDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "text_sha256": draft.textSHA256,
    "text_byte_count": "\(draft.textByteCount)",
    "row_count": "\(draft.rowCount)",
    "max_column_count": "\(draft.maxColumnCount)",
    "placement": "append",
  ]
}

func bodyTableImportScopeDigest(_ draft: NotesBodyTableImportDraft) -> String {
  let fields = [
    draft.noteID,
    draft.sourceKind,
    draft.sourceFormat,
    draft.sourceSHA256,
    draft.tableTextSHA256,
    "\(draft.rowCount)",
    "\(draft.maxColumnCount)",
  ]
  return "notes-body-table-import:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableImportSummary(_ draft: NotesBodyTableImportDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "source_kind": draft.sourceKind,
    "source_format": draft.sourceFormat,
    "source_sha256": draft.sourceSHA256,
    "source_byte_count": "\(draft.sourceByteCount)",
    "table_text_sha256": draft.tableTextSHA256,
    "table_text_byte_count": "\(draft.tableTextByteCount)",
    "row_count": "\(draft.rowCount)",
    "max_column_count": "\(draft.maxColumnCount)",
    "cell_count": "\(draft.cellCount)",
    "placement": "append",
  ]
}

func bodyTableUpdateScopeDigest(_ draft: NotesBodyTableUpdateDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
    "\(draft.row)",
    "\(draft.column)",
    draft.textSHA256,
  ]
  return "notes-body-table-update:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableUpdateSummary(_ draft: NotesBodyTableUpdateDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "row": "\(draft.row)",
    "column": "\(draft.column)",
    "selector": "ordinal_row_column",
    "text_sha256": draft.textSHA256,
    "text_byte_count": "\(draft.textByteCount)",
  ]
}

func bodyTableDeleteScopeDigest(_ draft: NotesBodyTableDeleteDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
  ]
  return "notes-body-table-delete:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableDeleteSummary(_ draft: NotesBodyTableDeleteDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "selector": "ordinal",
  ]
}

func bodyTableConvertToTextScopeDigest(_ draft: NotesBodyTableConvertToTextDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
    "\(draft.rowCount)",
    "\(draft.columnCount)",
    "\(draft.cellCount)",
  ]
  return "notes-body-table-convert-to-text:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableConvertToTextSummary(_ draft: NotesBodyTableConvertToTextDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "selector": "ordinal",
    "row_count": "\(draft.rowCount)",
    "column_count": "\(draft.columnCount)",
    "cell_count": "\(draft.cellCount)",
    "replacement": "tab_newline_plain_text",
  ]
}

func bodyTableConvertFromTextScopeDigest(_ draft: NotesBodyTableConvertFromTextDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256,
    "\(draft.ordinal)",
    draft.requestedSelector,
    draft.sourceTitleSHA256 ?? "",
  ]
  return "notes-body-table-convert-from-text:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableConvertFromTextSummary(_ draft: NotesBodyTableConvertFromTextDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "paragraph_sha256": draft.paragraphIDSHA256,
    "ordinal": "\(draft.ordinal)",
    "selector": draft.requestedSelector,
    "source": "existing_body_paragraph",
    "replacement": "notes_table_attachment",
  ]
  if let sourceTitleByteCount = draft.sourceTitleByteCount {
    summary["source_title_byte_count"] = "\(sourceTitleByteCount)"
  }
  if let sourceTitleSHA256 = draft.sourceTitleSHA256 {
    summary["source_title_sha256"] = sourceTitleSHA256
  }
  return summary
}

func bodyTableCopyScopeDigest(_ draft: NotesBodyTableCopyDraft) -> String {
  let fields = [
    draft.sourceNoteID,
    draft.targetNoteID,
    "\(draft.ordinal)",
    "\(draft.rowCount)",
    "\(draft.columnCount)",
    "\(draft.cellCount)",
  ]
  return "notes-body-table-copy:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableCopySummary(_ draft: NotesBodyTableCopyDraft) -> [String: String] {
  [
    "id": draft.sourceNoteID,
    "target": draft.targetNoteID,
    "ordinal": "\(draft.ordinal)",
    "selector": "source_ordinal_target_append",
    "same_note": draft.sameNote ? "true" : "false",
    "row_count": "\(draft.rowCount)",
    "column_count": "\(draft.columnCount)",
    "cell_count": "\(draft.cellCount)",
    "placement": "append",
  ]
}

func bodyTableMoveScopeDigest(_ draft: NotesBodyTableMoveDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
    "\(draft.targetOrdinal)",
  ]
  return "notes-body-table-move:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableMoveSummary(_ draft: NotesBodyTableMoveDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "to_ordinal": "\(draft.targetOrdinal)",
    "selector": "ordinal_to_ordinal",
    "placement": "table_order",
  ]
}

func bodyTableStructureOperationName(_ draft: NotesBodyTableStructureDraft) -> String {
  let axis = draft.axis == .row ? "rows" : "columns"
  return "notes.body.table.\(axis).\(draft.action.rawValue)"
}

func bodyTableStructureScopeDigest(_ draft: NotesBodyTableStructureDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
    draft.axis.rawValue,
    draft.action.rawValue,
    "\(draft.index)",
    draft.toIndex.map(String.init) ?? "",
    "\(draft.count)",
  ]
  return "notes-body-table-structure:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableStructureSummary(_ draft: NotesBodyTableStructureDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "selector": draft.action == .move || draft.action == .copy ? "ordinal_index_to" : "ordinal_index_count",
    "axis": draft.axis.rawValue,
    "action": draft.action.rawValue,
    "index": "\(draft.index)",
    "count": "\(draft.count)",
  ]
  if let toIndex = draft.toIndex {
    summary["to"] = "\(toIndex)"
  }
  return summary
}

func bodyTableFormatOperationName(_ draft: NotesBodyTableFormatDraft) -> String {
  let axis = draft.axis == .row ? "rows" : "columns"
  return "notes.body.table.\(axis).format"
}

func bodyTableFormatScopeDigest(_ draft: NotesBodyTableFormatDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
    draft.axis.rawValue,
    "\(draft.index)",
    "\(draft.count)",
    draft.format.rawValue,
    draft.enabled ? "on" : "off",
    "\(draft.selectedCellCount)",
  ]
  return "notes-body-table-format:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyTableFormatSummary(_ draft: NotesBodyTableFormatDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "selector": "ordinal_axis_index_count",
    "axis": draft.axis.rawValue,
    "index": "\(draft.index)",
    "count": "\(draft.count)",
    "format": draft.format.rawValue,
    "state": draft.enabled ? "on" : "off",
    "selected_cell_count": "\(draft.selectedCellCount)",
  ]
}

func bodyMathUpdateScopeDigest(_ draft: NotesBodyMathUpdateDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.ordinal)",
    draft.resultSHA256,
  ]
  return "notes-body-math-update:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyMathInsertScopeDigest(_ draft: NotesBodyMathInsertDraft) -> String {
  let fields = [
    draft.noteID,
    draft.expressionSHA256,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
  ]
  return "notes-body-math-insert:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyMathVariableSetScopeDigest(_ draft: NotesBodyMathVariableSetDraft) -> String {
  let fields = [
    draft.noteID,
    draft.variableNameSHA256,
    draft.variableValueSHA256,
    draft.variableDefinitionExpressionSHA256,
    draft.dependentExpressionSHA256,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
  ]
  return "notes-body-math-variable-set:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyMathVariableUpdateScopeDigest(_ draft: NotesBodyMathVariableUpdateDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.definitionOrdinal)",
    "\(draft.dependentOrdinal)",
    draft.variableValueSHA256,
  ]
  return "notes-body-math-variable-update:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyMathResultsPreferenceScopeDigest(_ draft: NotesBodyMathResultsPreferenceDraft) -> String {
  let fields = [
    draft.noteID,
    draft.mode,
    "\(draft.rawValue)",
    draft.requestedValueSHA256,
  ]
  return "notes-body-math-results:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyMathInsertSummary(_ draft: NotesBodyMathInsertDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "selector": draft.paragraphIDSHA256 != nil ? "paragraph" : draft.ordinal != nil ? "ordinal" : "append",
    "expression_sha256": draft.expressionSHA256,
    "expression_byte_count": "\(draft.expressionByteCount)",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
  }
  return summary
}

func bodyMathVariableSetSummary(_ draft: NotesBodyMathVariableSetDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "selector": draft.paragraphIDSHA256 != nil ? "paragraph" : draft.ordinal != nil ? "ordinal" : "append",
    "variable_name_sha256": draft.variableNameSHA256,
    "variable_name_byte_count": "\(draft.variableNameByteCount)",
    "variable_value_sha256": draft.variableValueSHA256,
    "variable_value_byte_count": "\(draft.variableValueByteCount)",
    "variable_definition_expression_sha256": draft.variableDefinitionExpressionSHA256,
    "dependent_expression_sha256": draft.dependentExpressionSHA256,
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
  }
  return summary
}

func bodyMathVariableUpdateSummary(_ draft: NotesBodyMathVariableUpdateDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "definition_ordinal": "\(draft.definitionOrdinal)",
    "dependent_ordinal": "\(draft.dependentOrdinal)",
    "variable_value_sha256": draft.variableValueSHA256,
    "variable_value_byte_count": "\(draft.variableValueByteCount)",
  ]
}

func bodyMathResultsPreferenceSummary(_ draft: NotesBodyMathResultsPreferenceDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "mode": draft.mode,
    "raw_value": "\(draft.rawValue)",
    "value_sha256": draft.requestedValueSHA256,
  ]
}

func bodyMathUpdateSummary(_ draft: NotesBodyMathUpdateDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "ordinal": "\(draft.ordinal)",
    "selector": "ordinal",
    "result_sha256": draft.resultSHA256,
    "result_byte_count": "\(draft.resultByteCount)",
  ]
}

func bodyCollapsibleSetScopeDigest(_ draft: NotesBodyCollapsibleSetDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.state.rawValue,
  ]
  return "notes-body-collapsible-set:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyCollapsibleSetSummary(_ draft: NotesBodyCollapsibleSetDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "state": draft.state.rawValue,
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyChecklistSetScopeDigest(_ draft: NotesBodyChecklistSetDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.checked ? "checked" : "open",
  ]
  return "notes-body-checklist-set:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistSetSummary(_ draft: NotesBodyChecklistSetDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "state": draft.checked ? "checked" : "open",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyChecklistSetAllScopeDigest(_ draft: NotesBodyChecklistSetAllDraft) -> String {
  let fields = [
    draft.noteID,
    draft.checked ? "checked" : "open",
  ]
  return "notes-body-checklist-set-all:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistSetAllSummary(_ draft: NotesBodyChecklistSetAllDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "state": draft.checked ? "checked" : "open",
    "selector": "all",
  ]
}

func bodyChecklistSortScopeDigest(_ draft: NotesBodyChecklistSortDraft) -> String {
  "notes-body-checklist-sort:\(sha256Hex(draft.noteID))"
}

func bodyChecklistSortSummary(_ draft: NotesBodyChecklistSortDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "sort": "open-then-checked",
    "stability": "preserve-relative-order",
  ]
}

func bodyChecklistConvertScopeDigest(_ draft: NotesBodyChecklistConvertDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.checked ? "checked" : "open",
  ]
  return "notes-body-checklist-convert:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistConvertSummary(_ draft: NotesBodyChecklistConvertDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "state": draft.checked ? "checked" : "open",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_id_sha256"] = paragraphIDSHA256
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
  }
  return summary
}

func bodyChecklistConvertRangeScopeDigest(_ draft: NotesBodyChecklistConvertRangeDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.fromOrdinal)",
    "\(draft.toOrdinal)",
    draft.checked ? "checked" : "open",
  ]
  return "notes-body-checklist-convert-range:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistConvertRangeSummary(_ draft: NotesBodyChecklistConvertRangeDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "selector": "ordinal_range",
    "from_ordinal": "\(draft.fromOrdinal)",
    "to_ordinal": "\(draft.toOrdinal)",
    "state": draft.checked ? "checked" : "open",
    "requested_count": "\(draft.toOrdinal - draft.fromOrdinal + 1)",
  ]
}

func bodyChecklistReorderScopeDigest(_ draft: NotesBodyChecklistReorderDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    "\(draft.targetOrdinal)",
  ]
  return "notes-body-checklist-reorder:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistReorderSummary(_ draft: NotesBodyChecklistReorderDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "to_ordinal": "\(draft.targetOrdinal)",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyChecklistIndentScopeDigest(_ draft: NotesBodyChecklistIndentDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    "\(draft.delta)",
  ]
  return "notes-body-checklist-indent:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistIndentSummary(_ draft: NotesBodyChecklistIndentDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "by": "\(draft.delta)",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyChecklistDeleteScopeDigest(_ draft: NotesBodyChecklistDeleteDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
  ]
  return "notes-body-checklist-delete:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyChecklistDeleteSummary(_ draft: NotesBodyChecklistDeleteDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyParagraphStyleScopeDigest(_ draft: NotesBodyParagraphStyleDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.style.rawValue,
  ]
  return "notes-body-paragraph-style:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyParagraphStyleSummary(_ draft: NotesBodyParagraphStyleDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "style": draft.style.rawValue,
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyParagraphAlignmentScopeDigest(_ draft: NotesBodyParagraphAlignmentDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.alignment.rawValue,
  ]
  return "notes-body-paragraph-align:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyParagraphAlignmentSummary(_ draft: NotesBodyParagraphAlignmentDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "alignment": draft.alignment.rawValue,
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyParagraphQuoteScopeDigest(_ draft: NotesBodyParagraphQuoteDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.enabled ? "on" : "off",
  ]
  return "notes-body-paragraph-quote:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyParagraphQuoteSummary(_ draft: NotesBodyParagraphQuoteDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "state": draft.enabled ? "on" : "off",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyInlineFormatScopeDigest(_ draft: NotesBodyInlineFormatDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    sha256Hex(draft.text),
    draft.occurrence.map(String.init) ?? "",
    draft.format.rawValue,
    draft.enabled ? "on" : "off",
  ]
  return "notes-body-inline-format:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyInlineFormatSummary(_ draft: NotesBodyInlineFormatDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "text_sha256": sha256Hex(draft.text),
    "text_byte_count": "\(draft.text.utf8.count)",
    "format": draft.format.rawValue,
    "state": draft.enabled ? "on" : "off",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  if let occurrence = draft.occurrence {
    summary["occurrence"] = "\(occurrence)"
  }
  return summary
}

func bodyInlineFontScopeDigest(_ draft: NotesBodyInlineFontDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    sha256Hex(draft.text),
    draft.occurrence.map(String.init) ?? "",
    sha256Hex(draft.family),
    formattedFontPointSize(draft.pointSize),
  ]
  return "notes-body-inline-font:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyInlineFontSummary(_ draft: NotesBodyInlineFontDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "text_sha256": sha256Hex(draft.text),
    "text_byte_count": "\(draft.text.utf8.count)",
    "font_family_sha256": sha256Hex(draft.family),
    "font_size": formattedFontPointSize(draft.pointSize),
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  if let occurrence = draft.occurrence {
    summary["occurrence"] = "\(occurrence)"
  }
  return summary
}

func formattedFontPointSize(_ size: Double) -> String {
  String(format: "%.3f", size)
}

func bodyInlineColorScopeDigest(_ draft: NotesBodyInlineColorDraft, role: String) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    sha256Hex(draft.text),
    draft.occurrence.map(String.init) ?? "",
    role,
    draft.color.map(sha256Hex) ?? "clear",
  ]
  return "notes-body-inline-\(role):\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyInlineColorSummary(_ draft: NotesBodyInlineColorDraft, role: String) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "text_sha256": sha256Hex(draft.text),
    "text_byte_count": "\(draft.text.utf8.count)",
    "role": role,
    "color_sha256": draft.color.map(sha256Hex) ?? "clear",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  if let occurrence = draft.occurrence {
    summary["occurrence"] = "\(occurrence)"
  }
  return summary
}

func bodyListAddScopeDigest(_ draft: NotesBodyListAddDraft) -> String {
  let fields = [
    draft.noteID,
    sha256Hex(draft.text),
    draft.style.rawValue,
  ]
  return "notes-body-list-add:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListAddSummary(_ draft: NotesBodyListAddDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "text_sha256": sha256Hex(draft.text),
    "text_byte_count": "\(draft.text.utf8.count)",
    "style": draft.style.rawValue,
  ]
}

func bodyListConvertScopeDigest(_ draft: NotesBodyListConvertDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.style.rawValue,
  ]
  return "notes-body-list-convert:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListConvertSummary(_ draft: NotesBodyListConvertDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "style": draft.style.rawValue,
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyListConvertRangeScopeDigest(_ draft: NotesBodyListConvertRangeDraft) -> String {
  let fields = [
    draft.noteID,
    "\(draft.fromOrdinal)",
    "\(draft.toOrdinal)",
    draft.style.rawValue,
  ]
  return "notes-body-list-convert-range:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListConvertRangeSummary(_ draft: NotesBodyListConvertRangeDraft) -> [String: String] {
  [
    "id": draft.noteID,
    "selector": "ordinal_range",
    "from_ordinal": "\(draft.fromOrdinal)",
    "to_ordinal": "\(draft.toOrdinal)",
    "style": draft.style.rawValue,
    "requested_count": "\(draft.toOrdinal - draft.fromOrdinal + 1)",
  ]
}

func bodyListSetStyleScopeDigest(_ draft: NotesBodyListSetStyleDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.style.rawValue,
  ]
  return "notes-body-list-set-style:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListSetStyleSummary(_ draft: NotesBodyListSetStyleDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "style": draft.style.rawValue,
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyListReorderScopeDigest(_ draft: NotesBodyListReorderDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    "\(draft.targetOrdinal)",
  ]
  return "notes-body-list-reorder:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListReorderSummary(_ draft: NotesBodyListReorderDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "to_ordinal": "\(draft.targetOrdinal)",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyListIndentScopeDigest(_ draft: NotesBodyListIndentDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    "\(draft.delta)",
  ]
  return "notes-body-list-indent:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListIndentSummary(_ draft: NotesBodyListIndentDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "by": "\(draft.delta)",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyListDeleteScopeDigest(_ draft: NotesBodyListDeleteDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
  ]
  return "notes-body-list-delete:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListDeleteSummary(_ draft: NotesBodyListDeleteDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyListTextInsertScopeDigest(_ draft: NotesBodyListTextInsertDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.targetKind.rawValue,
    draft.insertKind.rawValue,
    draft.insertKind.insertedTextSHA256,
  ]
  return "notes-body-list-text-insert:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListTextInsertSummary(_ draft: NotesBodyListTextInsertDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "target_kind": draft.targetKind.rawValue,
    "inserted_kind": draft.insertKind.rawValue,
    "inserted_text_sha256": draft.insertKind.insertedTextSHA256,
    "inserted_text_byte_count": "\(draft.insertKind.insertedTextByteCount)",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func bodyListEndScopeDigest(_ draft: NotesBodyListEndDraft) -> String {
  let fields = [
    draft.noteID,
    draft.paragraphIDSHA256 ?? "",
    draft.ordinal.map(String.init) ?? "",
    draft.targetKind.rawValue,
    "body",
  ]
  return "notes-body-list-end:\(sha256Hex(fields.joined(separator: "|")))"
}

func bodyListEndSummary(_ draft: NotesBodyListEndDraft) -> [String: String] {
  var summary = [
    "id": draft.noteID,
    "target_kind": draft.targetKind.rawValue,
    "created_paragraph_style": "body",
  ]
  if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
    summary["paragraph_sha256"] = paragraphIDSHA256
    summary["selector"] = "paragraph"
  }
  if let ordinal = draft.ordinal {
    summary["ordinal"] = "\(ordinal)"
    summary["selector"] = "ordinal"
  }
  return summary
}

func moveScopeDigest(current: NotesNoteDetail, draft: NotesMoveDraft) -> String {
  let fields = [
    noteIdentityScopeDigest(current),
    draft.folderID,
    draft.folderName,
    draft.accountName,
  ]
  return "notes-move:\(sha256Hex(fields.joined(separator: "|")))"
}

func moveSummary(current: NotesNoteDetail, draft: NotesMoveDraft) -> [String: String] {
  [
    "id": current.id,
    "title": current.title,
    "from_folder": current.folderName,
    "from_account": current.accountName,
    "to_folder_id": draft.folderID,
    "to_folder": draft.folderName,
    "to_account": draft.accountName,
    "current_body_sha256": sha256Hex(current.body ?? ""),
  ]
}

func copyScopeDigest(current: NotesNoteDetail, draft: NotesCopyDraft) -> String {
  let fields = [
    noteIdentityScopeDigest(current),
    draft.folderID,
    draft.folderName,
    draft.accountName,
  ]
  return "notes-copy:\(sha256Hex(fields.joined(separator: "|")))"
}

func copySummary(current: NotesNoteDetail, draft: NotesCopyDraft) -> [String: String] {
  [
    "id": current.id,
    "title": current.title,
    "from_folder": current.folderName,
    "from_account": current.accountName,
    "to_folder_id": draft.folderID,
    "to_folder": draft.folderName,
    "to_account": draft.accountName,
    "current_body_sha256": sha256Hex(current.body ?? ""),
  ]
}

func restoreScopeDigest(current: NotesNoteDetail, draft: NotesRestoreDraft) -> String {
  let fields = [
    noteIdentityScopeDigest(current),
    draft.folderID,
    draft.folderName,
    draft.accountName,
  ]
  return "notes-restore:\(sha256Hex(fields.joined(separator: "|")))"
}

func restoreSummary(current: NotesNoteDetail, draft: NotesRestoreDraft) -> [String: String] {
  [
    "id": current.id,
    "title": current.title,
    "from_folder": current.folderName,
    "from_account": current.accountName,
    "to_folder_id": draft.folderID,
    "to_folder": draft.folderName,
    "to_account": draft.accountName,
    "current_body_sha256": sha256Hex(current.body ?? ""),
  ]
}

func restoreAllScopeDigest(notes: [NotesNoteDetail], targetFolder: NotesFolderRecord) -> String {
  let fields = notes
    .map(noteIdentityScopeDigest)
    .sorted()
    .joined(separator: "|")
  return "notes-restore-all:\(sha256Hex([fields, targetFolder.id, targetFolder.name, targetFolder.accountName].joined(separator: "|")))"
}

func restoreAllSummary(notes: [NotesNoteDetail], targetFolder: NotesFolderRecord) -> [String: String] {
  [
    "restorable_note_count": "\(notes.count)",
    "restorable_note_ids_sha256": sha256Hex(notes.map(\.id).sorted().joined(separator: "|")),
    "to_folder_id": targetFolder.id,
    "to_folder": targetFolder.name,
    "to_account": targetFolder.accountName,
  ]
}

func purgeScopeDigest(current: NotesNoteDetail) -> String {
  "notes-purge:\(sha256Hex(noteIdentityScopeDigest(current)))"
}

func purgeSummary(current: NotesNoteDetail) -> [String: String] {
  [
    "id": current.id,
    "title": current.title,
    "folder": current.folderName,
    "account": current.accountName,
    "current_body_sha256": sha256Hex(current.body ?? ""),
  ]
}

func emptyTrashScopeDigest(notes: [NotesNoteDetail]) -> String {
  let fields = notes
    .map(noteIdentityScopeDigest)
    .sorted()
    .joined(separator: "|")
  return "notes-empty-trash:\(sha256Hex(fields))"
}

func emptyTrashSummary(notes: [NotesNoteDetail]) -> [String: String] {
  [
    "restorable_note_count": "\(notes.count)",
    "restorable_note_ids_sha256": sha256Hex(notes.map(\.id).sorted().joined(separator: "|")),
  ]
}

func pinScopeDigest(current: NotesNoteDetail, targetPinned: Bool) -> String {
  "notes-pin:\(targetPinned):\(sha256Hex(noteIdentityScopeDigest(current)))"
}

func pinSummary(
  current: NotesNoteDetail,
  state: NotesNoteStateRecord,
  targetPinned: Bool
) -> [String: String] {
  [
    "id": current.id,
    "title": current.title,
    "folder": current.folderName,
    "account": current.accountName,
    "current_pinned": String(state.isPinned),
    "target_pinned": String(targetPinned),
    "current_body_sha256": sha256Hex(current.body ?? ""),
  ]
}

func tagMutationScopeDigest(note: NotesNoteDetail, tag: String, action: String) -> String {
  let fields = [
    noteIdentityScopeDigest(note),
    action,
    standardizedTagContent(tag),
  ]
  return "notes-tags-\(action):\(sha256Hex(fields.joined(separator: "|")))"
}

func tagMutationSummary(note: NotesNoteDetail, tag: String, action: String) -> [String: String] {
  [
    "id": note.id,
    "title": note.title,
    "folder": note.folderName,
    "account": note.accountName,
    "action": action,
    "tag": tag,
    "tag_standardized_content": standardizedTagContent(tag),
    "current_tag_count": "\(note.tags.count)",
  ]
}

func tagConvertToTextScopeDigest(_ draft: NotesTagConvertToTextDraft) -> String {
  let fields = [
    draft.noteID,
    draft.standardizedContent,
    "\(draft.matchedTagCount)",
    "\(draft.wasPresentOnNote)",
    "\(draft.beforePlainTextByteCount)",
    draft.beforePlainTextSHA256,
  ]
  return "notes-tags-convert-to-text:\(sha256Hex(fields.joined(separator: "|")))"
}

func tagConvertToTextSummary(_ draft: NotesTagConvertToTextDraft, note: NotesNoteDetail) -> [String: String] {
  [
    "id": note.id,
    "title": note.title,
    "folder": note.folderName,
    "account": note.accountName,
    "tag": draft.displayText,
    "tag_standardized_content": draft.standardizedContent,
    "matched_tag_count": "\(draft.matchedTagCount)",
    "tag_present_on_note": "\(draft.wasPresentOnNote)",
    "body_plain_text_byte_count": "\(draft.beforePlainTextByteCount)",
    "body_plain_text_sha256": draft.beforePlainTextSHA256,
  ]
}

func tagRenameScopeDigest(_ draft: NotesTagRenameDraft) -> String {
  let fields = [
    draft.currentStandardizedContent,
    draft.newStandardizedContent,
    "\(draft.matchedTagCount)",
    "\(draft.targetMatchedTagCount)",
    "\(draft.affectedNoteCount)",
    "\(draft.allowMerge)",
  ]
  return "notes-tags-rename:\(sha256Hex(fields.joined(separator: "|")))"
}

func tagRenameSummary(_ draft: NotesTagRenameDraft) -> [String: String] {
  [
    "from_tag": draft.currentDisplayText,
    "from_tag_standardized_content": draft.currentStandardizedContent,
    "to_tag": draft.newDisplayText,
    "to_tag_standardized_content": draft.newStandardizedContent,
    "matched_tag_count": "\(draft.matchedTagCount)",
    "target_matched_tag_count": "\(draft.targetMatchedTagCount)",
    "affected_note_count": "\(draft.affectedNoteCount)",
    "allow_merge": "\(draft.allowMerge)",
  ]
}

func tagDeleteScopeDigest(_ draft: NotesTagDeleteDraft) -> String {
  let fields = [
    draft.standardizedContent,
    "\(draft.matchedTagCount)",
    "\(draft.affectedNoteCount)",
  ]
  return "notes-tags-delete:\(sha256Hex(fields.joined(separator: "|")))"
}

func tagDeleteSummary(_ draft: NotesTagDeleteDraft) -> [String: String] {
  [
    "tag": draft.displayText,
    "tag_standardized_content": draft.standardizedContent,
    "matched_tag_count": "\(draft.matchedTagCount)",
    "affected_note_count": "\(draft.affectedNoteCount)",
  ]
}

func tagBatchDeleteScopeDigest(
  drafts: [NotesTagDeleteDraft],
  affectedNotes: [NotesNoteDetail]
) -> String {
  let fields = [
    drafts.map(\.standardizedContent).sorted().joined(separator: "\0"),
    drafts.map { "\($0.matchedTagCount):\($0.affectedNoteCount)" }.joined(separator: "|"),
    affectedNotes.map(\.id).sorted().joined(separator: "\0"),
  ]
  return "notes-tags-delete-batch:\(sha256Hex(fields.joined(separator: "|")))"
}

func tagBatchDeleteSummary(
  drafts: [NotesTagDeleteDraft],
  affectedNotes: [NotesNoteDetail]
) -> [String: String] {
  let tagContents = drafts.map(\.standardizedContent).sorted().joined(separator: "\0")
  let affectedIDs = affectedNotes.map(\.id).sorted().joined(separator: "\0")
  return [
    "tag_count": "\(drafts.count)",
    "tag_set_sha256": sha256Hex(tagContents),
    "affected_note_count": "\(affectedNotes.count)",
    "affected_note_ids_sha256": sha256Hex(affectedIDs),
    "per_tag_affected_note_counts": drafts.map { "\($0.affectedNoteCount)" }.joined(separator: ","),
  ]
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }

  return value
}

func requiredOptionAllowingEmpty(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name) else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }

  return value
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 500 for Notes read commands.")
  }
  return limit
}

func noteSummary(_ row: [String]) -> NotesNoteSummary {
  NotesNoteSummary(
    id: row[safe: 0] ?? "",
    title: row[safe: 1] ?? "",
    folderName: row[safe: 2] ?? "",
    accountName: row[safe: 3] ?? "",
    createdAt: parseAppleScriptDate(row[safe: 4]),
    updatedAt: parseAppleScriptDate(row[safe: 5])
  )
}

func noteSummary(_ detail: NotesNoteDetail) -> NotesNoteSummary {
  NotesNoteSummary(
    id: detail.id,
    title: detail.title,
    folderName: detail.folderName,
    accountName: detail.accountName,
    createdAt: detail.createdAt,
    updatedAt: detail.updatedAt
  )
}

func noteDetail(_ row: [String]) -> NotesNoteDetail {
  NotesNoteDetail(
    id: row[safe: 0] ?? "",
    title: row[safe: 1] ?? "",
    folderName: row[safe: 2] ?? "",
    accountName: row[safe: 3] ?? "",
    body: row[safe: 6],
    createdAt: parseAppleScriptDate(row[safe: 4]),
    updatedAt: parseAppleScriptDate(row[safe: 5])
  )
}

func noteHumanOutput(_ note: NotesNoteDetail) -> String {
  [
    "id: \(note.id)",
    "title: \(note.title)",
    "folder: \(note.folderName)",
    "account: \(note.accountName)",
  ].joined(separator: "\n")
}

func notesStoreDebugHumanOutput(_ debug: NotesStoreDebugResponse) -> String {
  var lines = [
    "scope: \(debug.scope)",
    "container: \(debug.container.exists ? "present" : "missing") \(debug.container.path)",
    "store: \(debug.store.exists ? "present" : "missing") \(debug.store.path)",
    "wal: \(debug.wal.exists ? "present" : "missing")",
    "shm: \(debug.shm.exists ? "present" : "missing")",
    "index state files: \(debug.indexStateFiles.filter { $0.exists }.count)",
  ]

  if let tableCount = debug.tableCount {
    lines.append("tables: \(tableCount)")
  }
  if let indexCount = debug.indexCount {
    lines.append("indexes: \(indexCount)")
  }
  if !debug.requiredTablesMissing.isEmpty {
    lines.append("missing required tables: \(debug.requiredTablesMissing.joined(separator: ","))")
  }
  if !debug.schemaTables.isEmpty {
    lines.append("schema tables:")
    lines.append(
      contentsOf: debug.schemaTables.map {
        "\($0.tableName)\tcolumns=\($0.columnCount)"
      })
  }
  if !debug.entityCounts.isEmpty {
    lines.append("entity counts:")
    lines.append(
      contentsOf: debug.entityCounts.map {
        "\($0.entity)\t\($0.rows)"
      })
  }
  if !debug.searchIndexStateCounts.isEmpty {
    lines.append("search index states:")
    lines.append(
      contentsOf: debug.searchIndexStateCounts.map {
        "\($0.stateValue)\t\($0.rows)"
      })
  }
  if !debug.warnings.isEmpty {
    lines.append("warnings:")
    lines.append(contentsOf: debug.warnings)
  }

  return lines.joined(separator: "\n")
}

func notesObjectDebugHumanOutput(_ debug: NotesObjectDebugResponse) -> String {
  var lines = [
    "kind: \(debug.kind)",
    "selector_sha256: \(debug.selectorSHA256)",
    "readback_id_sha256: \(debug.readback.idSHA256)",
    "store_matched: \(debug.storeObject.matched)",
  ]

  if let entity = debug.storeObject.entity {
    lines.append("entity: \(entity)")
  }
  if let primaryKey = debug.storeObject.primaryKey {
    lines.append("primary_key: \(primaryKey)")
  }
  if let noteCount = debug.storeObject.noteCount {
    lines.append("note_count: \(noteCount)")
  }
  if let folderCount = debug.storeObject.folderCount {
    lines.append("folder_count: \(folderCount)")
  }
  if let childFolderCount = debug.storeObject.childFolderCount {
    lines.append("child_folder_count: \(childFolderCount)")
  }
  if !debug.storeObject.searchIndexStateCounts.isEmpty {
    lines.append("search index states:")
    lines.append(
      contentsOf: debug.storeObject.searchIndexStateCounts.map {
        "\($0.stateValue)\t\($0.rows)"
      })
  }
  if !debug.warnings.isEmpty {
    lines.append("warnings:")
    lines.append(contentsOf: debug.warnings)
  }

  return lines.joined(separator: "\n")
}

func notesDoctorCheckHumanOutput(_ check: CLIDoctorCheck) -> String {
  var lines = [
    "name: \(check.name)",
    "status: \(check.status.rawValue)",
    "message: \(check.message)",
  ]
  lines.append(
    contentsOf: check.details
      .sorted { $0.key < $1.key }
      .map { "\($0.key): \($0.value)" })
  return lines.joined(separator: "\n")
}

func appleScriptEqualsOrTrue(_ variable: String, selector: String?) -> String {
  guard let selector, !selector.isEmpty else {
    return "true"
  }
  return "\(variable) is equal to \"\(appleScriptString(selector))\""
}

func appleScriptNoteMatches(_ query: String?) -> String {
  guard let query, !query.isEmpty else {
    return "true"
  }

  let escaped = appleScriptString(query)
  return "noteName contains \"\(escaped)\" or noteBody contains \"\(escaped)\""
}

func noteBodyAssignment(query: String?, includeBody: Bool) -> String {
  if query != nil || includeBody {
    return "set noteBody to body of eachNote as text"
  }

  return "set noteBody to \"\""
}

func appleScriptString(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}

func parseAppleScriptDate(_ value: String?) -> Date? {
  guard let value, !value.isEmpty else {
    return nil
  }

  if let seconds = TimeInterval(value) {
    return Date(timeIntervalSince1970: seconds)
  }

  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm:ss a"
  if let date = formatter.date(from: value) {
    return date
  }

  let localizedFormatter = DateFormatter()
  localizedFormatter.locale = Locale(identifier: "zh_CN")
  localizedFormatter.dateFormat = "yyyy年M月d日 EEEE ah:mm:ss"
  if let date = localizedFormatter.date(from: value) {
    return date
  }

  let flexibleLocalizedFormatter = DateFormatter()
  flexibleLocalizedFormatter.locale = Locale(identifier: "zh_CN")
  flexibleLocalizedFormatter.dateFormat = "yyyy年M月d日 EEEE Bh:mm:ss"
  return flexibleLocalizedFormatter.date(from: value)
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
