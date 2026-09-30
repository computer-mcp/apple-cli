import AppKit
import CryptoKit
import Foundation
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
  public init() {}

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
    return try listPresentations(path: path, limit: 500)
      .filter { $0.name.localizedCaseInsensitiveContains(normalizedQuery) }
      .prefix(limit)
      .map { $0 }
  }

  public func readPresentation(path: String) throws -> KeynotePresentationRecord? {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }
    guard isKeynotePresentation(url) else {
      throw CLIError(
        code: .validationError, message: "`--path` must identify a `.key` presentation package.",
        details: ["path": path])
    }
    return try presentationRecord(url)
  }

  public func listSlides(path: String, limit: Int) throws -> KeynoteSlidesResponse? {
    guard let presentation = try readPresentation(path: path) else {
      return nil
    }

    let root = URL(fileURLWithPath: presentation.path).standardizedFileURL
    let quickLook = root.appendingPathComponent("QuickLook", isDirectory: true)
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: quickLook.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      return KeynoteSlidesResponse(presentation: presentation, slides: [])
    }

    let previews = try FileManager.default.contentsOfDirectory(
      at: quickLook,
      includingPropertiesForKeys: Array(KeynoteResourceKeys.all),
      options: [.skipsHiddenFiles]
    )
    .filter(isSlidePreviewArtifact)
    .sorted {
      $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
    }
    .prefix(limit)

    let slides = previews.enumerated().map { offset, preview in
      KeynoteSlideRecord(
        presentationPath: presentation.path,
        index: offset + 1,
        id: keynoteSlideID(presentation: presentation, preview: preview, index: offset + 1),
        previewPath: preview.path
      )
    }

    return KeynoteSlidesResponse(presentation: presentation, slides: slides)
  }

  public func exportPresentation(path: String, format: String, to destinationPath: String) throws
    -> KeynoteExportResult
  {
    guard let presentation = try readPresentation(path: path) else {
      throw CLIError(
        code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
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
      try validatePackageExportRelationship(source: source, destination: destination)
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
    case "pdf":
      sourcePath = presentation.quickLookPreviewPath
    case "thumbnail":
      sourcePath = presentation.quickLookThumbnailPath
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Keynote export currently supports only `pdf`, `thumbnail`, and `package`.")
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
      format: format
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
        message: "`--path` must identify a directory or `.key` presentation package.",
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
    var isDirectory: ObjCBool = false
    return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
      && isDirectory.boolValue
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

  private func isSlidePreviewArtifact(_ url: URL) -> Bool {
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
