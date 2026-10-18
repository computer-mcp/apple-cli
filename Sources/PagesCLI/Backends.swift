import AppKit
import CryptoKit
import Foundation
import Utility


public struct PagesExternalActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var path: String
}

public struct NSWorkspacePagesExternalActions: PagesExternalActioning {
  public init() {}

  public func open(path: String) throws -> Bool {
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
  }
}

public struct FileManagerPagesBackend: PagesReading, PagesExporting {
  public init() {}

  public func listDocuments(path: String, limit: Int) throws -> [PagesDocumentRecord] {
    let url = normalizedURL(path)
    if isPagesDocument(url) {
      return try [documentRecord(url)]
    }

    let root = try directoryURL(path)
    let urls = try FileManager.default.contentsOfDirectory(
      at: root,
      includingPropertiesForKeys: Array(PagesResourceKeys.all),
      options: [.skipsHiddenFiles]
    )
    .filter(isPagesDocument)
    .sorted {
      $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
        == .orderedAscending
    }
    .prefix(limit)

    return try urls.map(documentRecord)
  }

  public func searchDocuments(path: String, query: String, limit: Int) throws
    -> [PagesDocumentRecord]
  {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    return try listDocuments(path: path, limit: 500)
      .filter { $0.name.localizedCaseInsensitiveContains(normalizedQuery) }
      .prefix(limit)
      .map { $0 }
  }

  public func readDocument(path: String) throws -> PagesDocumentRecord? {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }
    guard isPagesDocument(url) else {
      throw CLIError(
        code: .validationError, message: "`--path` must identify a `.pages` document.",
        details: ["path": path])
    }
    return try documentRecord(url)
  }

  public func exportDocument(path: String, format: String, to destinationPath: String) throws
    -> PagesExportResult
  {
    guard let document = try readDocument(path: path) else {
      throw CLIError(
        code: .notFound, message: "Pages document was not found.", details: ["path": path])
    }

    let sourcePath: String?
    switch format {
    case "pdf":
      sourcePath = document.quickLookPreviewPath
    case "thumbnail":
      sourcePath = document.quickLookThumbnailPath
    case "package":
      guard document.isPackage else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Pages package export requires a package-style `.pages` document.",
          details: ["path": document.path]
        )
      }
      let source = normalizedURL(document.path)
      let destination = normalizedURL(destinationPath)
      try validateExportDestination(destination.path, format: format)
      try validatePackageExportRelationship(source: source, destination: destination)
      try FileManager.default.copyItem(at: source, to: destination)
      return PagesExportResult(
        operation: "pages.export",
        changed: true,
        sourcePath: document.path,
        destinationPath: destination.path,
        format: format
      )
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Pages export currently supports only `pdf`, `thumbnail`, and `package`.")
    }

    guard let sourcePath else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Pages document does not contain a QuickLook \(format) export source.",
        details: ["path": document.path, "format": format]
      )
    }

    let destination = normalizedURL(destinationPath)
    try validateExportDestination(destination.path, format: format)

    try FileManager.default.copyItem(at: URL(fileURLWithPath: sourcePath), to: destination)
    return PagesExportResult(
      operation: "pages.export",
      changed: true,
      sourcePath: document.path,
      destinationPath: destination.path,
      format: format
    )
  }

  private func directoryURL(_ path: String) throws -> URL {
    let url = normalizedURL(path)
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
      throw CLIError(code: .notFound, message: "Pages path was not found.", details: ["path": path])
    }
    guard isDirectory.boolValue else {
      throw CLIError(
        code: .validationError, message: "`--path` must identify a directory or `.pages` document.",
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

  private func isPagesDocument(_ url: URL) -> Bool {
    url.pathExtension.lowercased() == "pages"
  }

  private func documentRecord(_ url: URL) throws -> PagesDocumentRecord {
    let values = try url.resourceValues(forKeys: PagesResourceKeys.all)
    return PagesDocumentRecord(
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
}
