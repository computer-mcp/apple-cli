import AppKit
import CryptoKit
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
      return try result(
        ClipboardTypesResponse(types: backend.types()),
        human: backend.types().joined(separator: "\n"),
        options: options
      )
    case ["clipboard", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["type"])
      let item = backend.readString(preferredType: options.targetOption("type"))
      return try result(
        ClipboardReadResponse(item: item, sensitive: true),
        human: item.map(\.value) ?? "",
        options: options
      )
    case ["clipboard", "write"]:
      try validateTargetOptions(options, allowedOptions: ["text"])
      let text = try requiredOption("text", options: options)
      return try writeText(text, options: options)
    case ["clipboard", "clear"]:
      try validateTargetOptions(options, allowedOptions: [])
      return try clear(options: options)
    default:
      return nil
    }
  }

  private func writeText(_ text: String, options: CLIOptions) throws -> CLICommandResult {
    let operation = "clipboard.write"
    let scopeDigest = "clipboard:general:text:\(sha256Hex(text))"
    let summary = [
      "type": NSPasteboard.PasteboardType.string.rawValue,
      "byte_count": "\(Data(text.utf8).count)",
      "sha256": sha256Hex(text),
    ]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try dryRunPreview(
        operation: operation,
        scopeDigest: scopeDigest,
        summaryFields: summary,
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-persistent-action",
      in: options,
      category: .persistentAction,
      message: "Clipboard write persists pasteboard state and requires `--allow-persistent-action`."
    )

    let changed = try backend.writeText(text)
    return try result(
      ClipboardMutationResult(operation: operation, changed: changed),
      human: changed ? "clipboard.write changed=true" : "clipboard.write changed=false",
      options: options
    )
  }

  private func clear(options: CLIOptions) throws -> CLICommandResult {
    let operation = "clipboard.clear"
    let scopeDigest = "clipboard:general:state:\(backend.stateDigest())"
    let summary = ["state_digest": backend.stateDigest()]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try dryRunPreview(
        operation: operation,
        scopeDigest: scopeDigest,
        summaryFields: summary,
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-persistent-action",
      in: options,
      category: .persistentAction,
      message: "Clipboard clear persists pasteboard state and requires `--allow-persistent-action`."
    )

    let changed = try backend.clear()
    return try result(
      ClipboardMutationResult(operation: operation, changed: changed),
      human: changed ? "clipboard.clear changed=true" : "clipboard.clear changed=false",
      options: options
    )
  }

  private func dryRunPreview(
    operation: String,
    scopeDigest: String,
    summaryFields: [String: String],
    options: CLIOptions
  ) throws -> CLICommandResult {
    let dryRun = CLISafety.dryRun(
      target: target,
      operation: operation,
      summary: summaryFields,
      scope: scopeDigest,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"]
    )

    return try result(
      dryRun,
      human: "dry-run: \(operation)",
      options: options
    )
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
