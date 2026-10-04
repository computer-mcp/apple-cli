import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility


public struct FinderExternalActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var path: String
}

public struct NSWorkspaceFinderExternalActions: FinderExternalActioning {
  public init() {}

  public func open(path: String) throws -> Bool {
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
  }

  public func reveal(path: String) throws -> Bool {
    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    return true
  }
}

public struct FileManagerFinderBackend: FinderReading, FinderMutating {
  public init() {}

  public func listItems(path: String, includeHidden: Bool, limit: Int) throws -> [FinderItemRecord]
  {
    let root = try directoryURL(path)
    return try directoryItems(root: root, includeHidden: includeHidden, limit: limit)
  }

  public func searchItems(path: String, query: String, includeHidden: Bool, limit: Int) throws
    -> [FinderItemRecord]
  {
    let root = try directoryURL(path)
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    return try directoryItems(
      root: root, includeHidden: includeHidden, limit: limit, query: normalizedQuery)
  }

  public func readMetadata(path: String) throws -> FinderItemRecord? {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }
    return try itemRecord(url)
  }

  public func moveItem(path: String, to destinationPath: String) throws -> FinderItemRecord {
    let source = normalizedURL(path)
    let destination = normalizedURL(destinationPath)
    guard FileManager.default.fileExists(atPath: source.path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }
    guard !FileManager.default.fileExists(atPath: destination.path) else {
      throw CLIError(
        code: .validationError, message: "Destination path already exists.",
        details: ["path": destination.path])
    }
    let destinationParent = destination.deletingLastPathComponent()
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: destinationParent.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      throw CLIError(
        code: .notFound, message: "Destination parent directory was not found.",
        details: ["path": destinationParent.path])
    }

    try FileManager.default.moveItem(at: source, to: destination)
    return try itemRecord(destination)
  }

  public func trashItem(path: String) throws -> Bool {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }

    var resultingURL: NSURL?
    try FileManager.default.trashItem(at: url, resultingItemURL: &resultingURL)
    return true
  }

  public func deleteFile(path: String) throws -> Bool {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }

    let item = try itemRecord(url)
    guard item.isRegularFile, !item.isDirectory, !item.isSymbolicLink else {
      throw CLIError(
        code: .validationError,
        message: "`items delete` only supports single regular files.",
        details: ["path": item.path]
      )
    }

    do {
      try FileManager.default.removeItem(at: url)
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to delete Finder file.",
        details: CLIError.diagnosticDetails(for: error).merging(["path": url.path]) { _, new in new }
      )
    }
    return true
  }

  public func setTags(path: String, tags: [String]) throws -> FinderItemRecord {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }

    try setFinderTags(tags, url: url)
    return try itemRecord(url)
  }

  public func writeTextFile(path: String, text: String) throws -> FinderItemRecord {
    let url = normalizedURL(path)
    guard !FileManager.default.fileExists(atPath: url.path) else {
      throw CLIError(
        code: .validationError, message: "Destination path already exists.",
        details: ["path": url.path])
    }

    let parent = url.deletingLastPathComponent()
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      throw CLIError(
        code: .notFound, message: "Destination parent directory was not found.",
        details: ["path": parent.path])
    }

    let data = Data(text.utf8)
    do {
      try writeDataWithoutOverwriting(data, to: url)
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to write Finder text file.",
        details: CLIError.diagnosticDetails(for: error).merging(["path": url.path]) { _, new in new }
      )
    }
    return try itemRecord(url)
  }

  public func overwriteTextFile(path: String, text: String) throws -> FinderItemRecord {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }

    let existing = try itemRecord(url)
    guard existing.isRegularFile, !existing.isDirectory, !existing.isSymbolicLink else {
      throw CLIError(
        code: .validationError,
        message: "`items overwrite-text` only supports single regular files.",
        details: ["path": existing.path]
      )
    }

    do {
      try Data(text.utf8).write(to: url, options: .atomic)
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to overwrite Finder text file.",
        details: CLIError.diagnosticDetails(for: error).merging(["path": url.path]) { _, new in new }
      )
    }
    return try itemRecord(url)
  }

  private func directoryItems(root: URL, includeHidden: Bool, limit: Int, query: String? = nil) throws
    -> [FinderItemRecord]
  {
    let options: FileManager.DirectoryEnumerationOptions = includeHidden ? [] : [.skipsHiddenFiles]
    let keys = FinderResourceKeys.all
    let urls = try FileManager.default.contentsOfDirectory(
      at: root,
      includingPropertiesForKeys: Array(keys),
      options: options
    )
    .sorted {
      $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
        == .orderedAscending
    }
    .filter { url in
      query.map { url.lastPathComponent.localizedCaseInsensitiveContains($0) } ?? true
    }
    .prefix(limit)

    return try urls.map(itemRecord)
  }

  private func directoryURL(_ path: String) throws -> URL {
    let url = normalizedURL(path)
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
      throw CLIError(
        code: .notFound, message: "Finder path was not found.", details: ["path": path])
    }
    guard isDirectory.boolValue else {
      throw CLIError(
        code: .validationError, message: "`--path` must identify a directory for this command.",
        details: ["path": path])
    }
    return url
  }

  private func normalizedURL(_ path: String) -> URL {
    let expanded = (path as NSString).expandingTildeInPath
    if expanded.hasPrefix("/") {
      return URL(fileURLWithPath: expanded).standardizedFileURL
    }

    return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(expanded)
      .standardizedFileURL
  }

  private func itemRecord(_ url: URL) throws -> FinderItemRecord {
    let values = try url.resourceValues(forKeys: FinderResourceKeys.all)
    return FinderItemRecord(
      path: url.path,
      name: values.name ?? url.lastPathComponent,
      isDirectory: values.isDirectory ?? false,
      isRegularFile: values.isRegularFile ?? false,
      isSymbolicLink: values.isSymbolicLink ?? false,
      size: values.fileSize.map(Int64.init),
      modifiedAt: values.contentModificationDate,
      tags: values.tagNames ?? []
    )
  }
}
