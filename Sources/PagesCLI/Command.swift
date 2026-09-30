import AppKit
import CryptoKit
import Foundation
import Utility

public struct PagesCommand: Sendable {
  private let backend: any PagesReading & PagesExporting
  private let externalActions: any PagesExternalActioning
  private let target = "pages"

  public init(
    backend: any PagesReading & PagesExporting = FileManagerPagesBackend(),
    externalActions: any PagesExternalActioning = NSWorkspacePagesExternalActions()
  ) {
    self.backend = backend
    self.externalActions = externalActions
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["documents", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let documents = try backend.listDocuments(
        path: try requiredOption("path", options: options), limit: try commandLimit(options))
      return try result(
        PagesDocumentsResponse(documents: documents), human: documentsHumanOutput(documents),
        options: options)
    case ["documents", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path", "query"])
      let documents = try backend.searchDocuments(
        path: try requiredOption("path", options: options),
        query: try nonTrivialQuery(options),
        limit: try commandLimit(options)
      )
      return try result(
        PagesDocumentsResponse(documents: documents), human: documentsHumanOutput(documents),
        options: options)
    case ["documents", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let path = try requiredOption("path", options: options)
      guard let document = try backend.readDocument(path: path) else {
        throw CLIError(
          code: .notFound, message: "Pages document was not found.", details: ["path": path])
      }
      return try result(
        PagesDocumentResponse(document: document), human: documentHumanOutput(document),
        options: options)
    case ["documents", "open"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-external-dispatch",
          in: options,
          category: .externalDispatch,
          message: "pages.open opens Pages and requires `--allow-external-dispatch`."
        )
      }
      let document = try requiredDocument(options)
      return try externalAction(
        document, operation: "pages.open", scope: "pages-open", options: options
      ) {
        try externalActions.open(path: document.path)
      }
    case ["documents", "export"]:
      try validateTargetOptions(options, allowedOptions: ["path", "format", "to"])
      try validateMutationIntent(options)
      let format = try exportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("to", options: options))
      if options.dryRun {
        try validateExportDestination(destinationPath, format: format)
      } else {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Pages export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let document = try requiredDocument(options)
      return try exportDocument(
        document, format: format, destinationPath: destinationPath, options: options)
    default:
      return nil
    }
  }

  private func requiredDocument(_ options: CLIOptions) throws -> PagesDocumentRecord {
    let path = try requiredOption("path", options: options)
    guard let document = try backend.readDocument(path: path) else {
      throw CLIError(
        code: .notFound, message: "Pages document was not found.", details: ["path": path])
    }
    return document
  }

  private func externalAction(
    _ document: PagesDocumentRecord,
    operation: String,
    scope: String,
    options: CLIOptions,
    submit: () throws -> Bool
  ) throws -> CLICommandResult {
    let scopeDigest = "pages-path:\(sha256Hex(document.path))"
    let summary = [
      "path": document.path,
      "name": document.name,
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
      message: "\(operation) opens Pages and requires `--allow-external-dispatch`."
    )

    let submitted = try submit()
    return try result(
      PagesExternalActionResult(operation: operation, submitted: submitted, path: document.path),
      human: "\(operation) submitted=\(submitted)",
      options: options
    )
  }

  private func exportDocument(
    _ document: PagesDocumentRecord,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "pages.export"
    let scopeDigest = documentExportScopeDigest(document, format: format, destinationPath: destinationPath)
    let summary = [
      "path": document.path,
      "name": document.name,
      "format": format,
      "destination_path": destinationPath,
    ]
    if format == "package" {
      try validatePackageExportRelationship(
        source: URL(fileURLWithPath: document.path).standardizedFileURL,
        destination: URL(fileURLWithPath: destinationPath).standardizedFileURL
      )
    }

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
      message: "Pages export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    return try result(
      try backend.exportDocument(path: document.path, format: format, to: destinationPath),
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
