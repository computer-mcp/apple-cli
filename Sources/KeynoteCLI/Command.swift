import AppKit
import Foundation
import Utility

public struct KeynoteCommand: Sendable {
  private let backend: any KeynoteReading & KeynoteExporting
  private let externalActions: any KeynoteExternalActioning
  private let target = "keynote"

  public init(
    backend: any KeynoteReading & KeynoteExporting = FileManagerKeynoteBackend(),
    externalActions: any KeynoteExternalActioning = NSWorkspaceKeynoteExternalActions()
  ) {
    self.backend = backend
    self.externalActions = externalActions
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["presentations", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let presentations = try backend.listPresentations(
        path: try requiredOption("path", options: options), limit: try commandLimit(options))
      return try result(
        KeynotePresentationsResponse(presentations: presentations),
        human: presentationsHumanOutput(presentations), options: options)
    case ["presentations", "search"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path", "query"])
      let presentations = try backend.searchPresentations(
        path: try requiredOption("path", options: options),
        query: try nonTrivialQuery(options),
        limit: try commandLimit(options)
      )
      return try result(
        KeynotePresentationsResponse(presentations: presentations),
        human: presentationsHumanOutput(presentations), options: options)
    case ["presentations", "read"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let path = try requiredOption("path", options: options)
      guard let presentation = try backend.readPresentation(path: path) else {
        throw CLIError(
          code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
      }
      return try result(
        KeynotePresentationResponse(presentation: presentation),
        human: presentationHumanOutput(presentation), options: options)
    case ["slides", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let path = try requiredOption("path", options: options)
      guard let slides = try backend.listSlides(path: path, limit: try commandLimit(options)) else {
        throw CLIError(
          code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
      }
      return try result(slides, human: slidesHumanOutput(slides), options: options)
    case ["previews", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let path = try requiredOption("path", options: options)
      guard let previews = try backend.listPreviews(path: path, limit: try commandLimit(options)) else {
        throw CLIError(
          code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
      }
      return try result(previews, human: previewsHumanOutput(previews), options: options)
    case ["previews", "export"]:
      try validateTargetOptions(options, allowedOptions: ["path", "format", "to"])
      try validateMutationIntent(options, commandDescription: "Keynote preview export")
      let format = try previewExportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("to", options: options))
      if options.dryRun {
        try validatePreviewExportDestination(destinationPath)
      } else {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message:
            "Keynote preview export writes filesystem artifacts and requires `--allow-artifact-action`."
        )
      }
      let path = try requiredOption("path", options: options)
      guard let previews = try backend.listPreviews(path: path, limit: try commandLimit(options)) else {
        throw CLIError(
          code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
      }
      return try exportPreviews(
        previews, format: format, destinationPath: destinationPath, options: options)
    case ["presentations", "open"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-external-dispatch",
          in: options,
          category: .externalDispatch,
          message: "keynote.open opens Keynote and requires `--allow-external-dispatch`."
        )
      }
      let presentation = try requiredPresentation(options)
      return try externalAction(
        presentation, operation: "keynote.open", scope: "keynote-open", options: options
      ) {
        try externalActions.open(path: presentation.path)
      }
    case ["presentations", "export"]:
      try validateTargetOptions(options, allowedOptions: ["path", "format", "to"])
      try validateMutationIntent(options, commandDescription: "Keynote export")
      let format = try exportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("to", options: options))
      if options.dryRun {
        try validatePresentationExportDestination(destinationPath, format: format)
      } else {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Keynote export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let presentation = try requiredPresentation(options)
      return try exportPresentation(
        presentation, format: format, destinationPath: destinationPath, options: options)
    default:
      return nil
    }
  }

  private func requiredPresentation(_ options: CLIOptions) throws -> KeynotePresentationRecord {
    let path = try requiredOption("path", options: options)
    guard let presentation = try backend.readPresentation(path: path) else {
      throw CLIError(
        code: .notFound, message: "Keynote presentation was not found.", details: ["path": path])
    }
    return presentation
  }

  private func externalAction(
    _ presentation: KeynotePresentationRecord,
    operation: String,
    scope: String,
    options: CLIOptions,
    submit: () throws -> Bool
  ) throws -> CLICommandResult {
    let scopeDigest = "keynote-path:\(sha256Hex(presentation.path))"
    let summary = [
      "path": presentation.path,
      "name": presentation.name,
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
      message: "\(operation) opens Keynote and requires `--allow-external-dispatch`."
    )

    let submitted = try submit()
    return try result(
      KeynoteExternalActionResult(
        operation: operation, submitted: submitted, path: presentation.path),
      human: "\(operation) submitted=\(submitted)",
      options: options
    )
  }

  private func exportPresentation(
    _ presentation: KeynotePresentationRecord,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "keynote.export"
    let scopeDigest = presentationExportScopeDigest(
      presentation, format: format, destinationPath: destinationPath)
    let summary = [
      "path": presentation.path,
      "name": presentation.name,
      "format": format,
      "destination_path": destinationPath,
    ]
    try validatePresentationArtifactRelationship(
      source: URL(fileURLWithPath: presentation.path).standardizedFileURL,
      destination: URL(fileURLWithPath: destinationPath).standardizedFileURL
    )

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
      message: "Keynote export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    return try result(
      try backend.exportPresentation(path: presentation.path, format: format, to: destinationPath),
      human: "\(operation) executed",
      options: options
    )
  }

  private func exportPreviews(
    _ response: KeynotePreviewsResponse,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "keynote.previews-export"
    let artifacts = try previewExportArtifacts(response, destinationPath: destinationPath)
    let scopeDigest = previewExportScopeDigest(
      response.presentation,
      artifacts: artifacts,
      format: format,
      destinationPath: destinationPath
    )
    let summary = [
      "path": response.presentation.path,
      "name": response.presentation.name,
      "format": format,
      "destination_path": destinationPath,
      "previews": "\(artifacts.count)",
      "sha256": previewExportDigest(artifacts),
    ]

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
      message:
        "Keynote preview export writes filesystem artifacts and requires `--allow-artifact-action`."
    )
    try writePreviewExportArtifacts(artifacts, destinationPath: destinationPath)

    return try result(
      KeynotePreviewExportResult(
        operation: operation,
        changed: true,
        sourcePath: response.presentation.path,
        destinationPath: destinationPath,
        format: format,
        exportedPreviewCount: artifacts.count,
        files: artifacts.map(\.file)
      ),
      human: "\(operation) executed",
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
