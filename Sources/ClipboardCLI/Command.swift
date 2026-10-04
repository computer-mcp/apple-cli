import AppKit
import Foundation
import Utility

public struct ClipboardCommand: Sendable {
  private let backend: any ClipboardAccessing
  private let target = "clipboard"

  public init(backend: any ClipboardAccessing = AppKitClipboardBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["clipboard", "types"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let snapshot = try backend.types()
      return try result(snapshot, human: snapshot.types.joined(separator: "\n"), options: options)
    case ["clipboard", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["type", "max-bytes"])
      let snapshot = try backend.readString(
        preferredType: options.targetOption("type"), maxBytes: clipboardMaxBytes(options))
      return try result(snapshot, human: snapshot.item?.value ?? "", options: options)
    case ["clipboard", "items", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["type", "max-bytes"])
      let maxBytes = try clipboardMaxBytes(options)
      let limit = options.limit ?? ClipboardLimits.defaultItems
      try ClipboardLimits.validate(maxBytes: maxBytes, limit: limit)
      let snapshot = try backend.readItems(
        preferredType: options.targetOption("type"), limit: limit, maxBytes: maxBytes)
      return try result(
        snapshot, human: CLIJSON.encodeString(snapshot, pretty: true), options: options)
    case ["clipboard", "write"]:
      try validateTargetOptions(
        options, allowedOptions: ["text", "if-change-count", "max-bytes"],
        allowedFlags: ["current-host-only"])
      let text = try requiredOption("text", options: options, allowEmpty: true)
      let maxBytes = try clipboardMaxBytes(options)
      guard text.utf8.count <= maxBytes else { throw clipboardSizeError(maxBytes) }
      let count = try clipboardChangeCount(options)
      let operation = "clipboard.write"
      let summary = [
        "type": NSPasteboard.PasteboardType.string.rawValue,
        "byte_count": "\(text.utf8.count)",
        "sha256": sha256Hex(text),
      ]
      if options.dryRun {
        return try dryRunPreview(
          operation: operation, scopeDigest: "clipboard:general:text:\(sha256Hex(text))",
          summaryFields: summary, count: count, options: options)
      }
      try requirePersistentAction(options)
      return try mutationResult(
        try backend.writeText(
          text, ifChangeCount: count, maxBytes: maxBytes,
          currentHostOnly: options.hasTargetFlag("current-host-only")),
        operation: operation, options: options)
    case ["clipboard", "items", "write"]:
      try validateTargetOptions(
        options, allowedOptions: ["input", "if-change-count", "max-bytes"],
        allowedFlags: ["current-host-only"])
      let input = try requiredOption("input", options: options)
      let maxBytes = try clipboardMaxBytes(options)
      let count = try clipboardChangeCount(options)
      let items = try readClipboardInput(input, maxBytes: maxBytes)
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      let digest = sha256Hex(try encoder.encode(items))
      let operation = "clipboard.items.write"
      let representations = items.flatMap(\.representations)
      let summary = [
        "item_count": "\(items.count)",
        "representation_count": "\(representations.count)",
        "byte_count": "\(representations.reduce(0) { $0 + ($1.data?.count ?? 0) })",
        "sha256": digest,
      ]
      if options.dryRun {
        _ = try prepareClipboardItems(items)
        return try dryRunPreview(
          operation: operation, scopeDigest: "clipboard:general:items:\(digest)",
          summaryFields: summary, count: count, options: options)
      }
      try requirePersistentAction(options)
      return try mutationResult(
        try backend.writeItems(
          items, ifChangeCount: count, maxBytes: maxBytes,
          currentHostOnly: options.hasTargetFlag("current-host-only")),
        operation: operation, options: options)
    case ["clipboard", "clear"]:
      try validateTargetOptions(options, allowedOptions: ["if-change-count"])
      let count = try clipboardChangeCount(options)
      let operation = "clipboard.clear"
      if options.dryRun {
        let snapshot = try backend.types()
        let digest =
          "change:\(snapshot.changeCount):types:\(sha256Hex(snapshot.types.joined(separator: "\n")))"
        return try dryRunPreview(
          operation: operation, scopeDigest: "clipboard:general:state:\(digest)",
          summaryFields: ["state_digest": digest], count: count, options: options)
      }
      try requirePersistentAction(options)
      return try mutationResult(
        try backend.clear(ifChangeCount: count), operation: operation, options: options)
    default:
      return nil
    }
  }

  private func requirePersistentAction(_ options: CLIOptions) throws {
    try CLISafety.requireFlag(
      "allow-persistent-action", in: options, category: .persistentAction,
      message: "Clipboard replacement requires --allow-persistent-action.")
  }

  private func mutationResult(
    _ change: ClipboardChange, operation: String, options: CLIOptions
  ) throws -> CLICommandResult {
    try result(
      ClipboardMutationResult(
        operation: operation, changed: change.changed, changeCount: change.changeCount),
      human: "\(operation) changed=\(change.changed) changeCount=\(change.changeCount)",
      options: options)
  }

  private func dryRunPreview(
    operation: String, scopeDigest: String, summaryFields: [String: String],
    count: Int?, options: CLIOptions
  ) throws -> CLICommandResult {
    var summary = summaryFields
    var scope = scopeDigest
    if options.hasTargetFlag("current-host-only") {
      summary["current_host_only"] = "true"
      scope += ":current-host-only"
    }
    if let count {
      summary["if_change_count"] = "\(count)"
      scope += ":if-change-count:\(count)"
    }
    let dryRun = CLISafety.dryRun(
      target: target, operation: operation, summary: summary, scope: scope,
      category: .persistentAction, allowFlags: ["--allow-persistent-action"])
    return try result(dryRun, human: "dry-run: \(operation)", options: options)
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }
    return CLICommandResult(stdout: human)
  }
}
