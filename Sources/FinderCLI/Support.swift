import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

enum FinderResourceKeys {
  static let all: Set<URLResourceKey> = [
    .nameKey,
    .isDirectoryKey,
    .isRegularFileKey,
    .isSymbolicLinkKey,
    .fileSizeKey,
    .contentModificationDateKey,
    .tagNamesKey,
  ]
}

enum FinderTagMutationMode: String {
  case set
  case add
  case remove
  case clear
}

struct FinderContentWriteDraft {
  var path: String
  var parent: FinderItemRecord
  var text: String
  var textBytes: Int
  var textHash: String
}

struct FinderContentOverwriteDraft {
  var item: FinderItemRecord
  var text: String
  var textBytes: Int
  var textHash: String
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

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func itemIdentityScopeDigest(_ item: FinderItemRecord) -> String {
  let payload = [
    item.path,
    item.name,
    "\(item.isDirectory)",
    "\(item.isRegularFile)",
    "\(item.isSymbolicLink)",
    item.size.map(String.init) ?? "",
    item.modifiedAt.map(formatDate) ?? "",
    item.tags.joined(separator: ","),
  ].joined(separator: "|")
  return "finder-item:\(sha256Hex(payload))"
}

func itemMutationScopeDigest(
  _ item: FinderItemRecord,
  operation: String,
  destinationPath: String?,
  tags: [String]
) -> String {
  let payload = [
    itemIdentityScopeDigest(item),
    operation,
    destinationPath ?? "",
    tags.joined(separator: ","),
  ].joined(separator: "|")
  return "finder-mutation:\(sha256Hex(payload))"
}

func contentWriteScopeDigest(_ draft: FinderContentWriteDraft) -> String {
  let payload = [
    itemIdentityScopeDigest(draft.parent),
    draft.path,
    "\(draft.textBytes)",
    draft.textHash,
  ].joined(separator: "|")
  return "finder-content-write:\(sha256Hex(payload))"
}

func contentWriteSummary(_ draft: FinderContentWriteDraft) -> [String: String] {
  [
    "path": draft.path,
    "parent_path": draft.parent.path,
    "content_bytes": "\(draft.textBytes)",
    "content_hash": draft.textHash,
    "overwrite": "false",
  ]
}

func contentOverwriteScopeDigest(_ draft: FinderContentOverwriteDraft) -> String {
  let payload = [
    itemIdentityScopeDigest(draft.item),
    "\(draft.textBytes)",
    draft.textHash,
  ].joined(separator: "|")
  return "finder-content-overwrite:\(sha256Hex(payload))"
}

func contentOverwriteSummary(_ draft: FinderContentOverwriteDraft) -> [String: String] {
  [
    "path": draft.item.path,
    "current_size": draft.item.size.map(String.init) ?? "",
    "content_bytes": "\(draft.textBytes)",
    "content_hash": draft.textHash,
    "overwrite": "true",
  ]
}

func deleteFileSummary(_ item: FinderItemRecord) -> [String: String] {
  [
    "path": item.path,
    "name": item.name,
    "item_type": "regular_file",
    "size": item.size.map(String.init) ?? "",
    "permanent": "true",
  ]
}

private let finderTagsAttribute = "com.apple.metadata:_kMDItemUserTags"

func setFinderTags(_ tags: [String], url: URL) throws {
  if tags.isEmpty {
    if removexattr(url.path, finderTagsAttribute, 0) == -1, errno != ENOATTR {
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to clear Finder tags.",
        details: ["path": url.path, "errno": "\(errno)"]
      )
    }
    return
  }

  let values = tags.map { "\($0)\n0" }
  let data = try PropertyListSerialization.data(
    fromPropertyList: values, format: .binary, options: 0)
  let status = data.withUnsafeBytes { bytes in
    setxattr(url.path, finderTagsAttribute, bytes.baseAddress, data.count, 0, 0)
  }

  if status == -1 {
    throw CLIError(
      code: .backendUnavailable,
      message: "Failed to set Finder tags.",
      details: ["path": url.path, "errno": "\(errno)"]
    )
  }
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

func writeDataWithoutOverwriting(_ data: Data, to url: URL) throws {
  let fileDescriptor = open(
    url.path,
    O_WRONLY | O_CREAT | O_EXCL,
    S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
  )
  guard fileDescriptor >= 0 else {
    if errno == EEXIST {
      throw CLIError(
        code: .validationError, message: "Destination path already exists.",
        details: ["path": url.path])
    }
    throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
  }

  var closed = false
  do {
    try data.withUnsafeBytes { buffer in
      guard let baseAddress = buffer.baseAddress else {
        return
      }
      var written = 0
      while written < buffer.count {
        let count = write(fileDescriptor, baseAddress.advanced(by: written), buffer.count - written)
        guard count > 0 else {
          throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        written += count
      }
    }
    if close(fileDescriptor) != 0 {
      closed = true
      throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
    }
    closed = true
  } catch {
    if !closed {
      _ = close(fileDescriptor)
    }
    try? FileManager.default.removeItem(at: url)
    throw error
  }
}

func parseTags(_ value: String) throws -> [String] {
  let tags =
    value
    .split(separator: ",")
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }

  guard !tags.isEmpty else {
    throw CLIError(code: .validationError, message: "`--tags` must contain at least one tag.")
  }
  guard tags.allSatisfy({ !$0.contains("\n") }) else {
    throw CLIError(code: .validationError, message: "Finder tag names must not contain newlines.")
  }

  var seen: Set<String> = []
  return tags.filter { tag in
    let inserted = seen.insert(tag).inserted
    return inserted
  }
}

func finalTagsForMutation(current: [String], requested: [String], mode: FinderTagMutationMode)
  -> [String]
{
  switch mode {
  case .set:
    return requested
  case .add:
    var tags = current
    for tag in requested where !tags.contains(tag) {
      tags.append(tag)
    }
    return tags
  case .remove:
    let removal = Set(requested)
    return current.filter { !removal.contains($0) }
  case .clear:
    return []
  }
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
      code: .validationError, message: "`--limit` cannot exceed 500 for Finder read commands.")
  }
  return limit
}

func itemsHumanOutput(_ items: [FinderItemRecord]) -> String {
  items.map { item in
    "\(item.isDirectory ? "directory" : "file")\t\(item.path)"
  }.joined(separator: "\n")
}

func itemHumanOutput(_ item: FinderItemRecord) -> String {
  [
    "path: \(item.path)",
    "name: \(item.name)",
    "directory: \(item.isDirectory)",
    "regularFile: \(item.isRegularFile)",
    "symbolicLink: \(item.isSymbolicLink)",
    "tags: \(item.tags.joined(separator: ","))",
  ].joined(separator: "\n")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}
