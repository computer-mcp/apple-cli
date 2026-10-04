import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

public struct NumbersCommand: Sendable {
  private let backend: any NumbersReading & NumbersExporting
  private let contentBackend: any NumbersContentReading & NumbersContentWriting
  private let externalActions: any NumbersExternalActioning
  private let target = "numbers"

  public init(
    backend: any NumbersReading & NumbersExporting = FileManagerNumbersBackend(),
    contentBackend: any NumbersContentReading & NumbersContentWriting =
      NumbersAppleScriptContentBackend(),
    externalActions: any NumbersExternalActioning = NSWorkspaceNumbersExternalActions()
  ) {
    self.backend = backend
    self.contentBackend = contentBackend
    self.externalActions = externalActions
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["documents", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let documents = try backend.listDocuments(
        path: try requiredOption("path", options: options),
        limit: try commandLimit(options)
      )
      return try result(
        NumbersDocumentsResponse(documents: documents),
        human: documentsHumanOutput(documents),
        options: options
      )
    case ["documents", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path", "query"])
      let documents = try backend.searchDocuments(
        path: try requiredOption("path", options: options),
        query: try nonTrivialQuery(options),
        limit: try commandLimit(options)
      )
      return try result(
        NumbersDocumentsResponse(documents: documents),
        human: documentsHumanOutput(documents),
        options: options
      )
    case ["documents", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let path = try requiredOption("path", options: options)
      guard let document = try backend.readDocument(path: path) else {
        throw CLIError(
          code: .notFound, message: "Numbers document was not found.", details: ["path": path])
      }
      return try result(
        NumbersDocumentResponse(document: document),
        human: documentHumanOutput(document),
        options: options
      )
    case ["sheets", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path"])
      let document = try requiredDocument(options)
      let sheets = try contentBackend.listSheets(path: document.path)
      return try result(
        NumbersSheetsResponse(document: document, sheets: sheets),
        human: sheetsHumanOutput(sheets),
        options: options
      )
    case ["tables", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["path", "sheet", "table"])
      let document = try requiredDocument(options)
      let sheet = try normalizedName("sheet", options: options)
      let table = try normalizedName("table", options: options)
      guard
        let tableRecord = try contentBackend.readTable(
          path: document.path,
          sheet: sheet,
          table: table,
          limit: try commandLimit(options)
        )
      else {
        throw CLIError(
          code: .notFound,
          message: "Numbers table was not found.",
          details: ["path": document.path, "sheet": sheet, "table": table]
        )
      }
      return try result(
        NumbersTableResponse(document: document, table: tableRecord),
        human: tableHumanOutput(tableRecord),
        options: options
      )
    case ["tables", "export"]:
      try validateTargetOptions(
        options, allowedOptions: ["path", "sheet", "table", "format", "to"])
      try validateMutationIntent(options, commandDescription: "Numbers table export")
      let format = try tableExportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("to", options: options))
      if options.dryRun {
        try validateTableExportDestination(destinationPath, format: format)
      } else {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Numbers table export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let document = try requiredDocument(options)
      let sheet = try normalizedName("sheet", options: options)
      let table = try normalizedName("table", options: options)
      guard
        let tableRecord = try contentBackend.readTable(
          path: document.path,
          sheet: sheet,
          table: table,
          limit: try commandLimit(options)
        )
      else {
        throw CLIError(
          code: .notFound,
          message: "Numbers table was not found.",
          details: ["path": document.path, "sheet": sheet, "table": table]
        )
      }
      return try exportTable(
        document,
        table: tableRecord,
        format: format,
        destinationPath: destinationPath,
        options: options
      )
    case ["tables", "set-cell"]:
      try validateTargetOptions(
        options, allowedOptions: ["path", "sheet", "table", "row", "column", "value"])
      try validateMutationIntent(options, commandDescription: "Numbers table cell write")
      let sheet = try normalizedName("sheet", options: options)
      let table = try normalizedName("table", options: options)
      let row = try positiveIntOption("row", options: options)
      let column = try positiveIntOption("column", options: options)
      let value = try cellTextValue(options)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-persistent-action",
          in: options,
          category: .persistentAction,
          message: "Numbers table cell writes persist document state and require `--allow-persistent-action`."
        )
      }
      let document = try requiredDocument(options)
      guard
        let cell = try contentBackend.readCell(
          path: document.path,
          sheet: sheet,
          table: table,
          row: row,
          column: column
        )
      else {
        throw CLIError(
          code: .notFound,
          message: "Numbers cell was not found.",
          details: [
            "path": document.path,
            "sheet": sheet,
            "table": table,
            "row": "\(row)",
            "column": "\(column)",
          ]
        )
      }
      return try setCell(
        document,
        cell: cell,
        value: value,
        options: options
      )
    case ["documents", "open"]:
      try validateTargetOptions(options, allowedOptions: ["path"])
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-external-dispatch",
          in: options,
          category: .externalDispatch,
          message: "numbers.open opens Numbers and requires `--allow-external-dispatch`."
        )
      }
      let document = try requiredDocument(options)
      return try externalAction(
        document, operation: "numbers.open", scope: "numbers-open", options: options
      ) {
        try externalActions.open(path: document.path)
      }
    case ["documents", "export"]:
      try validateTargetOptions(options, allowedOptions: ["path", "format", "to"])
      try validateMutationIntent(options, commandDescription: "Numbers document export")
      let format = try exportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("to", options: options))
      if options.dryRun {
        try validateDocumentExportDestination(destinationPath, format: format)
      } else {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Numbers export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let document = try requiredDocument(options)
      return try exportDocument(
        document, format: format, destinationPath: destinationPath, options: options)
    default:
      return nil
    }
  }

  private func requiredDocument(_ options: CLIOptions) throws -> NumbersDocumentRecord {
    let path = try requiredOption("path", options: options)
    guard let document = try backend.readDocument(path: path) else {
      throw CLIError(
        code: .notFound, message: "Numbers document was not found.", details: ["path": path])
    }
    return document
  }

  private func externalAction(
    _ document: NumbersDocumentRecord,
    operation: String,
    scope: String,
    options: CLIOptions,
    submit: () throws -> Bool
  ) throws -> CLICommandResult {
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
          scope: scope,
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
      message: "\(operation) opens Numbers and requires `--allow-external-dispatch`."
    )

    let submitted = try submit()
    return try result(
      NumbersExternalActionResult(operation: operation, submitted: submitted, path: document.path),
      human: "\(operation) submitted=\(submitted)",
      options: options
    )
  }

  private func exportDocument(
    _ document: NumbersDocumentRecord,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "numbers.export"
    let scope = "numbers-export"
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
          scope: scope,
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
      message: "Numbers export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    return try result(
      try backend.exportDocument(path: document.path, format: format, to: destinationPath),
      human: "\(operation) executed",
      options: options
    )
  }

  private func exportTable(
    _ document: NumbersDocumentRecord,
    table: NumbersTableRecord,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "numbers.table-export"
    let scope = "numbers-table-export"
    let data = tableExportData(for: table, format: format)
    let dataHash = sha256Hex(data)
    let summary = [
      "path": document.path,
      "name": document.name,
      "sheet": table.sheetName,
      "table": table.tableName,
      "format": format,
      "destination_path": destinationPath,
      "rows": "\(table.rows.count)",
      "sha256": dataHash,
    ]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
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
      message: "Numbers table export writes a filesystem artifact and requires `--allow-artifact-action`."
    )
    try validateTableExportDestination(destinationPath, format: format)
    try writeDataWithoutOverwriting(
      data, to: URL(fileURLWithPath: destinationPath).standardizedFileURL)

    return try result(
      NumbersTableExportResult(
        operation: operation,
        changed: true,
        sourcePath: document.path,
        sheetName: table.sheetName,
        tableName: table.tableName,
        destinationPath: destinationPath,
        format: format,
        rowCount: table.rowCount,
        exportedRowCount: table.rows.count,
        byteCount: data.count,
        sha256: dataHash
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func setCell(
    _ document: NumbersDocumentRecord,
    cell: NumbersCellRecord,
    value: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "numbers.table-cell-set"
    let scope = "numbers-table-cell-set"
    let valueHash = sha256Hex(value)
    let summary = [
      "path": document.path,
      "name": document.name,
      "sheet": cell.sheetName,
      "table": cell.tableName,
      "row": "\(cell.row)",
      "column": "\(cell.column)",
      "previous_value_sha256": sha256Hex(cell.value),
      "previous_value_type": cell.valueType?.rawValue ?? "unknown",
      "previous_formula_sha256": cell.formula.map(sha256Hex) ?? "unknown",
      "value_sha256": valueHash,
      "value_bytes": "\(Data(value.utf8).count)",
    ]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .persistentAction,
          allowFlags: ["--allow-persistent-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-persistent-action",
      in: options,
      category: .persistentAction,
      message: "Numbers table cell writes persist document state and require `--allow-persistent-action`."
    )

    let changed = !cell.matchesLiteralText(value)
    if changed {
      do {
        try contentBackend.setCellText(
          path: document.path,
          sheet: cell.sheetName,
          table: cell.tableName,
          row: cell.row,
          column: cell.column,
          value: value
        )
      } catch var error as CLIError where error.code == .timeout || error.code == .backendUnavailable {
        error.details["mutation_may_have_occurred"] = "true"
        error.details["verification"] = "unconfirmed"
        error.details["retry_guidance"] = "inspect_document_before_retrying"
        throw error
      }
      do {
        guard let actual = try contentBackend.readCell(
          path: document.path, sheet: cell.sheetName, table: cell.tableName,
          row: cell.row, column: cell.column
        ), actual.sheetName == cell.sheetName, actual.tableName == cell.tableName,
          actual.row == cell.row, actual.column == cell.column,
          actual.rowCount == cell.rowCount, actual.columnCount == cell.columnCount,
          actual.matchesLiteralText(value) else {
          throw CLIError(code: .backendUnavailable, message: "Numbers cell readback did not match.")
        }
      } catch {
        throw CLIError(
          code: .backendUnavailable,
          message: "Numbers cell write could not be verified. Inspect the document before retrying.",
          details: [
            "mutation_may_have_occurred": "true", "verification": "unconfirmed",
            "retry_guidance": "inspect_document_before_retrying",
          ]
        )
      }
    }

    return try result(
      NumbersCellWriteResult(
        operation: operation,
        changed: changed,
        sourcePath: document.path,
        sheetName: cell.sheetName,
        tableName: cell.tableName,
        row: cell.row,
        column: cell.column,
        valueByteCount: Data(value.utf8).count,
        valueSHA256: valueHash,
        verified: true
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
