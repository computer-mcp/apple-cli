import AppKit
import CryptoKit
import Foundation
import PDFKit
import Utility


public struct KeynoteExternalActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var path: String
}

public struct NSWorkspaceKeynoteExternalActions: KeynoteExternalActioning {
  public init() {}

  public func open(path: String) throws -> Bool {
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
  }
}

public struct FileManagerKeynoteBackend: KeynoteReading, KeynoteExporting {
  private let native: KeynoteAppleScriptBackend

  public init() { native = KeynoteAppleScriptBackend() }

  init(native: KeynoteAppleScriptBackend) { self.native = native }

  public func listPresentations(path: String, limit: Int) throws -> [KeynotePresentationRecord] {
    let url = normalizedURL(path)
    if isKeynotePresentation(url) {
      return try [presentationRecord(url)]
    }

    let root = try directoryURL(path)
    let urls = try FileManager.default.contentsOfDirectory(
      at: root,
      includingPropertiesForKeys: Array(KeynoteResourceKeys.all),
      options: [.skipsHiddenFiles]
    )
    .filter(isKeynotePresentation)
    .sorted {
      $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
        == .orderedAscending
    }
    .prefix(limit)

    return try urls.map(presentationRecord)
  }

  public func searchPresentations(path: String, query: String, limit: Int) throws
    -> [KeynotePresentationRecord]
  {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let url = normalizedURL(path)
    let candidates: [URL]
    if isKeynotePresentation(url) {
      candidates = [url]
    } else {
      candidates = try FileManager.default.contentsOfDirectory(
        at: directoryURL(path),
        includingPropertiesForKeys: Array(KeynoteResourceKeys.all),
        options: [.skipsHiddenFiles]
      ).filter(isKeynotePresentation)
    }
    return try candidates
      .filter { $0.lastPathComponent.localizedCaseInsensitiveContains(normalizedQuery) }
      .sorted {
        $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
      }
      .prefix(limit)
      .map(presentationRecord)
  }

  public func readPresentation(path: String) throws -> KeynotePresentationRecord? {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }
    guard isKeynotePresentation(url) else {
      throw CLIError(
        code: .validationError, message: "`--path` must identify a `.key` presentation file or package.",
        details: ["path": path])
    }
    return try presentationRecord(url)
  }

  public func listSlides(path: String, limit: Int) throws -> KeynoteSlidesResponse? {
    guard let presentation = try readPresentation(path: path) else {
      return nil
    }

    let snapshot = try native.readSlides(
      path: normalizedURL(presentation.path).resolvingSymlinksInPath().path, limit: limit)
    let snapshotID = UUID().uuidString
    let slides = snapshot.slides.map { slide in
      KeynoteSlideRecord(
        presentationPath: presentation.path,
        index: slide.index,
        id: "snapshot:\(snapshotID):\(slide.index)",
        skipped: slide.skipped,
        titleShowing: slide.titleShowing,
        bodyShowing: slide.bodyShowing,
        title: slide.title,
        body: slide.body,
        presenterNotes: slide.presenterNotes
      )
    }
    return KeynoteSlidesResponse(
      presentation: presentation, slides: slides, documentID: snapshot.documentID,
      snapshotID: snapshotID, totalSlideCount: snapshot.totalSlideCount,
      truncated: slides.count < snapshot.totalSlideCount, readSource: snapshot.readSource
    )
  }

  public func listPreviews(path: String, limit: Int) throws -> KeynotePreviewsResponse? {
    guard let presentation = try readPresentation(path: path) else { return nil }
    let root = URL(fileURLWithPath: presentation.path).standardizedFileURL
    let quickLook = root.appendingPathComponent("QuickLook", isDirectory: true)
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: quickLook.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      return KeynotePreviewsResponse(presentation: presentation, previews: [])
    }

    let previews = try FileManager.default.contentsOfDirectory(
      at: quickLook,
      includingPropertiesForKeys: Array(KeynoteResourceKeys.all),
      options: [.skipsHiddenFiles]
    )
    .filter(isPreviewArtifact)
    .sorted {
      $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
    }
    .prefix(limit)

    let records = previews.enumerated().map { offset, preview in
      KeynotePreviewRecord(
        presentationPath: presentation.path,
        index: offset + 1,
        id: "preview:\(sha256Hex(preview.path))",
        previewPath: preview.path
      )
    }

    return KeynotePreviewsResponse(presentation: presentation, previews: records)
  }

  public func exportPresentation(path: String, format: String, to destinationPath: String) throws
    -> KeynoteExportResult
  {
    guard let presentation = try readPresentation(path: path) else {
      throw CLIError(
        code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
    }
    try validatePresentationArtifactRelationship(
      source: normalizedURL(presentation.path), destination: normalizedURL(destinationPath))
    if format == "pdf" {
      return try exportNativePDF(presentation, to: destinationPath)
    }
    if format == "package" {
      guard presentation.isPackage else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Keynote package export requires a package-style `.key` presentation.",
          details: ["path": presentation.path]
        )
      }
      let source = normalizedURL(presentation.path)
      let destination = normalizedURL(destinationPath)
      try validatePresentationExportDestination(destination.path, format: format)
      try validatePresentationArtifactRelationship(source: source, destination: destination)
      try FileManager.default.copyItem(at: source, to: destination)
      return KeynoteExportResult(
        operation: "keynote.export",
        changed: true,
        sourcePath: presentation.path,
        destinationPath: destination.path,
        format: format
      )
    }
    let sourcePath: String?
    switch format {
    case "preview-pdf":
      sourcePath = presentation.quickLookPreviewPath
    case "thumbnail":
      sourcePath = presentation.quickLookThumbnailPath
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Keynote export supports `pdf`, `preview-pdf`, `thumbnail`, and `package`.")
    }
    guard let sourcePath else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Keynote presentation does not contain a QuickLook \(format) export source.",
        details: ["path": path, "format": format]
      )
    }

    let destination = normalizedURL(destinationPath)
    try validatePresentationExportDestination(destination.path, format: format)

    try FileManager.default.copyItem(at: URL(fileURLWithPath: sourcePath), to: destination)
    return KeynoteExportResult(
      operation: "keynote.export",
      changed: true,
      sourcePath: presentation.path,
      destinationPath: destination.path,
      format: format,
      source: "quicklook_cache"
    )
  }

  private func exportNativePDF(
    _ presentation: KeynotePresentationRecord, to destinationPath: String
  ) throws -> KeynoteExportResult {
    let destination = normalizedURL(destinationPath)
    try validatePresentationExportDestination(destination.path, format: "pdf")
    let staging = destination.deletingLastPathComponent().appendingPathComponent(
      ".apple-cli-keynote-\(UUID().uuidString).pdf")
    var published = false
    defer { if !published { try? FileManager.default.removeItem(at: staging) } }
    let receipt: KeynoteNativePDFReceipt
    do {
      receipt = try native.exportPDF(
        path: normalizedURL(presentation.path).resolvingSymlinksInPath().path, to: staging.path)
    } catch let error as CLIError {
      throw CLIError(
        code: error.code, message: error.message,
        details: error.details.merging([
          "artifact_outcome": "unconfirmed", "staging_path": staging.path,
          "retry_policy": "inspect_before_retry",
        ]) { _, new in new }
      )
    }
    let data: Data
    do {
      data = try Data(contentsOf: staging)
    } catch {
      throw CLIError(code: .backendUnavailable, message: "Keynote PDF export did not produce a readable artifact.")
    }
    guard data.starts(with: Data("%PDF-".utf8)),
      let document = PDFDocument(data: data), !document.isEncrypted,
      receipt.slideCount > 0, document.pageCount == receipt.slideCount
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Keynote PDF export could not verify one page for each slide, including skipped slides."
      )
    }
    try validatePresentationExportDestination(destination.path, format: "pdf")
    // A same-volume hard link publishes the verified file without replacing an existing destination.
    do {
      try FileManager.default.linkItem(at: staging, to: destination)
    } catch {
      throw CLIError(
        code: FileManager.default.fileExists(atPath: destination.path) ? .validationError : .backendUnavailable,
        message: "Could not publish the verified PDF without replacing an existing destination.",
        details: CLIError.diagnosticDetails(for: error)
      )
    }
    published = true
    var residualArtifactPaths: [String] = []
    do {
      try FileManager.default.removeItem(at: staging)
    } catch {
      residualArtifactPaths = [staging.path]
    }
    return KeynoteExportResult(
      operation: "keynote.export", changed: true, sourcePath: presentation.path,
      destinationPath: destination.path, format: "pdf", source: "keynote_document",
      documentID: receipt.documentID, readSource: receipt.readSource,
      exportedSlideCount: receipt.slideCount, byteCount: data.count,
      sha256: sha256Hex(data), verification: "verified", residualArtifactPaths: residualArtifactPaths
    )
  }

  private func directoryURL(_ path: String) throws -> URL {
    let url = normalizedURL(path)
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
      throw CLIError(
        code: .notFound, message: "Keynote path was not found.", details: ["path": path])
    }
    guard isDirectory.boolValue else {
      throw CLIError(
        code: .validationError,
        message: "`--path` must identify a directory or `.key` presentation.",
        details: ["path": path])
    }
    return url
  }

  private func normalizedURL(_ path: String) -> URL {
    let expanded = (path as NSString).expandingTildeInPath
    if expanded.hasPrefix("/") {
      return URL(fileURLWithPath: expanded).standardizedFileURL
    }
    return URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(
      expanded
    ).standardizedFileURL
  }

  private func isKeynotePresentation(_ url: URL) -> Bool {
    guard url.pathExtension.lowercased() == "key" else {
      return false
    }
    guard let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey]) else {
      return false
    }
    return values.isDirectory == true || values.isRegularFile == true
  }

  private func presentationRecord(_ url: URL) throws -> KeynotePresentationRecord {
    let values = try url.resourceValues(forKeys: KeynoteResourceKeys.all)
    return KeynotePresentationRecord(
      path: url.path,
      name: values.name ?? url.lastPathComponent,
      isPackage: values.isDirectory ?? false,
      size: values.fileSize.map(Int64.init),
      modifiedAt: values.contentModificationDate,
      quickLookPreviewPath: existingQuickLookPath(root: url, component: "Preview.pdf"),
      quickLookThumbnailPath: existingQuickLookPath(root: url, component: "Thumbnail.jpg")
    )
  }

  private func existingQuickLookPath(root: URL, component: String) -> String? {
    let path = root.appendingPathComponent("QuickLook").appendingPathComponent(component).path
    return FileManager.default.fileExists(atPath: path) ? path : nil
  }

  private func isPreviewArtifact(_ url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      !isDirectory.boolValue
    else {
      return false
    }

    let allowedExtensions: Set<String> = ["jpg", "jpeg", "png", "tif", "tiff", "heic"]
    guard allowedExtensions.contains(url.pathExtension.lowercased()) else {
      return false
    }

    let basename = url.deletingPathExtension().lastPathComponent.lowercased()
    return !basename.hasPrefix("thumbnail")
  }
}
