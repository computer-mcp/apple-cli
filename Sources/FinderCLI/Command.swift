import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

public struct FinderCommand: Sendable {
  private let backend: any FinderReading & FinderMutating
  private let externalActions: any FinderExternalActioning
  private let target = "finder"

  public init(
    backend: any FinderReading & FinderMutating = FileManagerFinderBackend(),
    externalActions: any FinderExternalActioning = NSWorkspaceFinderExternalActions()
  ) {
    self.backend = backend
    self.externalActions = externalActions
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["items", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"], allowedFlags: ["include-hidden"])
      let items = try backend.listItems(
        path: try requiredOption("path", options: options),
        includeHidden: options.hasTargetFlag("include-hidden"),
        limit: try commandLimit(options)
      )
      return try result(
        FinderItemsResponse(items: items),
        human: itemsHumanOutput(items),
        options: options
      )
    case ["items", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(
        options, allowedOptions: ["path", "query"], allowedFlags: ["include-hidden"])
      let query = try requiredOption("query", options: options)
      guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
        throw CLIError(
          code: .validationError,
          message: "`--query` must contain at least 2 non-whitespace characters.")
      }
      let items = try backend.searchItems(
        path: try requiredOption("path", options: options),
        query: query,
        includeHidden: options.hasTargetFlag("include-hidden"),
        limit: try commandLimit(options)
      )
      return try result(
        FinderItemsResponse(items: items),
        human: itemsHumanOutput(items),
        options: options
      )
    case ["items", "metadata"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let path = try requiredOption("path", options: options)
      guard let item = try backend.readMetadata(path: path) else {
        throw CLIError(
          code: .notFound, message: "Finder item was not found.", details: ["path": path])
      }
      return try result(
        FinderMetadataResponse(item: item),
        human: itemHumanOutput(item),
        options: options
      )
    case ["items", "open"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      let item = try requiredItem(options)
      return try externalAction(
        item, operation: "finder.open", scope: "finder-open", options: options
      ) {
        try externalActions.open(path: item.path)
      }
    case ["items", "reveal"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      let item = try requiredItem(options)
      return try externalAction(
        item, operation: "finder.reveal", scope: "finder-reveal", options: options
      ) {
        try externalActions.reveal(path: item.path)
      }
    case ["items", "move"]:
      try validateTargetOptions(options, allowedOptions: ["path", "to"])
      try validateMutationIntent(options)
      let item = try requiredItem(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("to", options: options))
      guard destinationPath != item.path else {
        throw CLIError(code: .validationError, message: "`--to` must differ from `--path`.")
      }
      return try mutation(
        item,
        operation: "finder.move",
        scopeDigest: itemMutationScopeDigest(
          item, operation: "move", destinationPath: destinationPath, tags: []),
        summary: ["path": item.path, "destination_path": destinationPath],
        options: options
      ) {
        let moved = try backend.moveItem(path: item.path, to: destinationPath)
        return FinderMutationResult(
          operation: "finder.move",
          changed: true,
          sourcePath: item.path,
          destinationPath: moved.path,
          item: moved
        )
      }
    case ["items", "trash"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      try validateMutationIntent(options)
      let item = try requiredItem(options)
      return try mutation(
        item,
        operation: "finder.trash",
        scopeDigest: itemMutationScopeDigest(item, operation: "trash", destinationPath: nil, tags: []),
        summary: ["path": item.path, "name": item.name],
        options: options
      ) {
        let changed = try backend.trashItem(path: item.path)
        return FinderMutationResult(
          operation: "finder.trash",
          changed: changed,
          sourcePath: item.path,
          destinationPath: nil,
          item: nil
        )
      }
    case ["items", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      try validateMutationIntent(options)
      let item = try requiredDeleteFileItem(options)
      return try mutation(
        item,
        operation: "finder.delete_file",
        scopeDigest: itemMutationScopeDigest(
          item, operation: "delete-file", destinationPath: nil, tags: []),
        summary: deleteFileSummary(item),
        options: options
      ) {
        let changed = try backend.deleteFile(path: item.path)
        return FinderMutationResult(
          operation: "finder.delete_file",
          changed: changed,
          sourcePath: item.path,
          destinationPath: nil,
          item: nil
        )
      }
    case ["items", "write-text"]:
      try validateTargetOptions(options, allowedOptions: ["path", "text"])
      try validateMutationIntent(options)
      let draft = try contentWriteDraft(options)
      return try mutation(
        operation: "finder.write_text",
        scopeDigest: contentWriteScopeDigest(draft),
        summary: contentWriteSummary(draft),
        options: options
      ) {
        let item = try backend.writeTextFile(path: draft.path, text: draft.text)
        return FinderMutationResult(
          operation: "finder.write_text",
          changed: true,
          sourcePath: draft.path,
          destinationPath: nil,
          item: item
        )
      }
    case ["items", "overwrite-text"]:
      try validateTargetOptions(options, allowedOptions: ["path", "text"])
      try validateMutationIntent(options)
      let draft = try contentOverwriteDraft(options)
      return try mutation(
        operation: "finder.overwrite_text",
        scopeDigest: contentOverwriteScopeDigest(draft),
        summary: contentOverwriteSummary(draft),
        options: options
      ) {
        let item = try backend.overwriteTextFile(path: draft.item.path, text: draft.text)
        return FinderMutationResult(
          operation: "finder.overwrite_text",
          changed: true,
          sourcePath: draft.item.path,
          destinationPath: nil,
          item: item
        )
      }
    case ["items", "tags", "set"]:
      return try tagMutation(options: options, mode: .set)
    case ["items", "tags", "add"]:
      return try tagMutation(options: options, mode: .add)
    case ["items", "tags", "remove"]:
      return try tagMutation(options: options, mode: .remove)
    case ["items", "tags", "clear"]:
      return try tagMutation(options: options, mode: .clear)
    default:
      return nil
    }
  }

  private func requiredDeleteFileItem(_ options: CLIOptions) throws -> FinderItemRecord {
    let item = try requiredItem(options)
    guard item.isRegularFile, !item.isDirectory, !item.isSymbolicLink else {
      throw CLIError(
        code: .validationError,
        message: "`items delete` only supports single regular files.",
        details: ["path": item.path]
      )
    }
    return item
  }

  private func requiredItem(_ options: CLIOptions) throws -> FinderItemRecord {
    let path = try requiredOption("path", options: options)
    guard let item = try backend.readMetadata(path: path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }
    return item
  }

  private func contentWriteDraft(_ options: CLIOptions) throws -> FinderContentWriteDraft {
    let path = standardizedAbsolutePath(try requiredOption("path", options: options))
    let text = try requiredOption("text", options: options)
    let textBytes = text.utf8.count
    guard textBytes <= 1_048_576 else {
      throw CLIError(
        code: .validationError, message: "`--text` cannot exceed 1 MB for Finder content writes.")
    }
    guard try backend.readMetadata(path: path) == nil else {
      throw CLIError(
        code: .validationError, message: "Destination path already exists.", details: ["path": path]
      )
    }

    let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().standardizedFileURL.path
    guard let parent = try backend.readMetadata(path: parentPath) else {
      throw CLIError(
        code: .notFound, message: "Destination parent directory was not found.",
        details: ["path": parentPath])
    }
    guard parent.isDirectory, !parent.isSymbolicLink else {
      throw CLIError(
        code: .validationError, message: "Destination parent must be a real directory.",
        details: ["path": parentPath])
    }

    return FinderContentWriteDraft(
      path: path,
      parent: parent,
      text: text,
      textBytes: textBytes,
      textHash: sha256Hex(text)
    )
  }

  private func contentOverwriteDraft(_ options: CLIOptions) throws -> FinderContentOverwriteDraft {
    let path = standardizedAbsolutePath(try requiredOption("path", options: options))
    let text = try requiredOption("text", options: options)
    let textBytes = text.utf8.count
    guard textBytes <= 1_048_576 else {
      throw CLIError(
        code: .validationError,
        message: "`--text` cannot exceed 1 MB for Finder content overwrites.")
    }

    guard let item = try backend.readMetadata(path: path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }
    guard item.isRegularFile, !item.isDirectory, !item.isSymbolicLink else {
      throw CLIError(
        code: .validationError,
        message: "`items overwrite-text` only supports single regular files.",
        details: ["path": item.path]
      )
    }

    return FinderContentOverwriteDraft(
      item: item,
      text: text,
      textBytes: textBytes,
      textHash: sha256Hex(text)
    )
  }

  private func tagMutation(options: CLIOptions, mode: FinderTagMutationMode) throws
    -> CLICommandResult
  {
    switch mode {
    case .set, .add, .remove:
      try validateTargetOptions(options, allowedOptions: ["path", "tags"])
    case .clear:
      try validateTargetOptions(options, allowedOptions: ["path"])
    }
    try validateMutationIntent(options)
    let item = try requiredItem(options)
    let requestedTags =
      try mode == .clear ? [] : parseTags(try requiredOption("tags", options: options))
    let finalTags = finalTagsForMutation(current: item.tags, requested: requestedTags, mode: mode)
    return try mutation(
      item,
      operation: "finder.tags.\(mode.rawValue)",
      scopeDigest: itemMutationScopeDigest(
        item, operation: "tags.\(mode.rawValue)", destinationPath: nil, tags: requestedTags),
      summary: [
        "path": item.path,
        "current_tags": item.tags.joined(separator: ","),
        "requested_tags": requestedTags.joined(separator: ","),
        "final_tags": finalTags.joined(separator: ","),
      ],
      options: options
    ) {
      let tagged = try backend.setTags(path: item.path, tags: finalTags)
      return FinderMutationResult(
        operation: "finder.tags.\(mode.rawValue)",
        changed: tagged.tags != item.tags,
        sourcePath: item.path,
        destinationPath: nil,
        item: tagged
      )
    }
  }

  private func externalAction(
    _ item: FinderItemRecord,
    operation: String,
    scope: String,
    options: CLIOptions,
    submit: () throws -> Bool
  ) throws -> CLICommandResult {
    let scopeDigest = "finder-path:\(sha256Hex(item.path))"
    let summary = [
      "path": item.path,
      "name": item.name,
    ]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "\(operation) dispatches to Finder and requires `--allow-external-dispatch`."
    )

    let submitted = try submit()
    return try result(
      FinderExternalActionResult(operation: operation, submitted: submitted, path: item.path),
      human: "\(operation) submitted=\(submitted)",
      options: options
    )
  }

  private func mutation(
    _ item: FinderItemRecord,
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    commit: () throws -> FinderMutationResult
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "\(operation) changes filesystem artifacts and requires `--allow-artifact-action`."
    )

    return try result(try commit(), human: "\(operation) executed", options: options)
  }

  private func mutation(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    commit: () throws -> FinderMutationResult
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "\(operation) changes filesystem artifacts and requires `--allow-artifact-action`."
    )

    return try result(try commit(), human: "\(operation) executed", options: options)
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
