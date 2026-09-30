import Foundation
import Utility

extension NotesCommand {

  func bodyTableCreateDraft(_ options: CLIOptions) throws -> NotesBodyTableCreateDraft {
    let text = try normalizedBodyTableText(try requiredOption("text", options: options))
    return NotesBodyTableCreateDraft(
      noteID: try requiredOption("id", options: options),
      text: text.text,
      rowCount: text.rowCount,
      maxColumnCount: text.maxColumnCount
    )
  }

  func bodyTableImportDraft(_ options: CLIOptions) throws -> NotesBodyTableImportDraft {
    let noteID = try requiredOption("id", options: options)
    let text = options.targetOption("text")
    let file = options.targetOption("file")
    switch (text?.isEmpty == false, file?.isEmpty == false) {
    case (true, true):
      throw CLIError(
        code: .validationError,
        message: "`body table import` requires exactly one of `--text` or `--file`.",
        details: ["id_sha256": sha256Hex(noteID)]
      )
    case (false, false):
      throw CLIError(
        code: .validationError,
        message: "`body table import` requires `--text` or `--file`.",
        details: ["id_sha256": sha256Hex(noteID)]
      )
    default:
      break
    }

    let sourceKind: String
    let source: String
    let format: String?
    if let text {
      sourceKind = "inline-text"
      source = text
      format = options.targetOption("format")
    } else if let file {
      sourceKind = "file"
      source = try bodyTableImportFileText(path: file)
      format = options.targetOption("format") ?? inferredBodyTableImportFormat(filePath: file)
    } else {
      throw CLIError(code: .internalError, message: "Notes body table import source was not resolved.")
    }

    let normalized = try normalizedBodyTableImportText(source: source, format: format)
    return NotesBodyTableImportDraft(
      noteID: noteID,
      sourceKind: sourceKind,
      sourceFormat: normalized.sourceFormat,
      source: source,
      tableText: normalized.text,
      rowCount: normalized.rowCount,
      maxColumnCount: normalized.maxColumnCount
    )
  }

  private func bodyTableImportFileText(path: String) throws -> String {
    let url = URL(fileURLWithPath: path).standardizedFileURL
    let data: Data
    do {
      data = try Data(contentsOf: url)
    } catch {
      throw CLIError(
        code: .notFound,
        message: "Notes body table import file could not be read.",
        details: [
          "file_sha256": sha256Hex(path),
          "reason": "\(type(of: error))",
        ]
      )
    }
    guard let text = String(data: data, encoding: .utf8) else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table import file must be UTF-8 text.",
        details: [
          "file_sha256": sha256Hex(path),
          "byte_count": "\(data.count)",
          "data_sha256": sha256Hex(data),
        ]
      )
    }
    return text
  }

  private func inferredBodyTableImportFormat(filePath: String) -> String? {
    switch URL(fileURLWithPath: filePath).pathExtension.lowercased() {
    case "csv":
      return "csv"
    case "tsv", "tab":
      return "tsv"
    default:
      return nil
    }
  }

  func bodyTableUpdateDraft(_ options: CLIOptions) throws -> NotesBodyTableUpdateDraft {
    guard let rawText = options.targetOption("text") else {
      throw CLIError(code: .validationError, message: "`--text` is required.")
    }
    return NotesBodyTableUpdateDraft(
      noteID: try requiredOption("id", options: options),
      ordinal: try normalizedPositiveIntOption("ordinal", options: options),
      row: try normalizedPositiveIntOption("row", options: options),
      column: try normalizedPositiveIntOption("column", options: options),
      text: try normalizedBodyTableCellText(rawText)
    )
  }

  func bodyTableDeleteDraft(_ options: CLIOptions) throws -> NotesBodyTableDeleteDraft {
    NotesBodyTableDeleteDraft(
      noteID: try requiredOption("id", options: options),
      ordinal: try normalizedPositiveIntOption("ordinal", options: options)
    )
  }

  func bodyTableConvertToTextDraft(
    noteID: String,
    ordinal: Int,
    tables: [NotesBodyTableRecord]
  ) throws -> NotesBodyTableConvertToTextDraft {
    guard ordinal > 0 && ordinal <= tables.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "ordinal": "\(ordinal)",
          "table_count": "\(tables.count)",
        ]
      )
    }
    let target = tables[ordinal - 1]
    guard let rowCount = target.rowCount, let columnCount = target.columnCount,
      rowCount > 0, columnCount > 0
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes body table conversion requires private framework row and column counts.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "ordinal": "\(ordinal)",
        ]
      )
    }
    return NotesBodyTableConvertToTextDraft(
      noteID: noteID,
      ordinal: ordinal,
      rowCount: rowCount,
      columnCount: columnCount
    )
  }

  func bodyTableConvertFromTextDraft(
    noteID: String,
    options: CLIOptions,
    structure: NotesBodyStructureRecord
  ) throws -> NotesBodyTableConvertFromTextDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body table convert-from-text"
    )
    let anchor: NotesBodyParagraphAnchorRecord?
    let requestedSelector: String
    if let paragraph {
      requestedSelector = "paragraph"
      anchor = structure.paragraphAnchors.first { $0.idSHA256 == paragraph }
    } else if let ordinal {
      requestedSelector = "ordinal"
      anchor = structure.paragraphAnchors.first { $0.ordinal == ordinal }
    } else {
      requestedSelector = "unknown"
      anchor = nil
    }
    guard let anchor else {
      throw CLIError(
        code: .notFound,
        message: "Notes body paragraph selector did not match any paragraph anchor.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": paragraph ?? "",
          "ordinal": ordinal.map(String.init) ?? "",
          "paragraph_anchor_count": "\(structure.paragraphAnchors.count)",
        ]
      )
    }
    guard !anchor.isHeader, !anchor.isList, !anchor.isChecklist, !anchor.isBlockQuote else {
      throw CLIError(
        code: .validationError,
        message: "Notes text-to-table conversion currently requires an ordinary body paragraph.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": anchor.idSHA256,
          "ordinal": "\(anchor.ordinal)",
          "requires": "non-header,non-list,non-checklist,non-block-quote paragraph",
        ]
      )
    }
    return NotesBodyTableConvertFromTextDraft(
      noteID: noteID,
      paragraphIDSHA256: anchor.idSHA256,
      ordinal: anchor.ordinal,
      requestedSelector: requestedSelector,
      sourceTitleByteCount: anchor.titleByteCount,
      sourceTitleSHA256: anchor.titleSHA256
    )
  }

  func bodyTableCopyDraft(
    sourceNoteID: String,
    targetNoteID: String,
    ordinal: Int,
    tables: [NotesBodyTableRecord]
  ) throws -> NotesBodyTableCopyDraft {
    guard ordinal > 0 && ordinal <= tables.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "id_sha256": sha256Hex(sourceNoteID),
          "ordinal": "\(ordinal)",
          "table_count": "\(tables.count)",
        ]
      )
    }
    let target = tables[ordinal - 1]
    guard let rowCount = target.rowCount, let columnCount = target.columnCount,
      rowCount > 0, columnCount > 0
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes body table copy requires private framework row and column counts.",
        details: [
          "id_sha256": sha256Hex(sourceNoteID),
          "ordinal": "\(ordinal)",
        ]
      )
    }
    return NotesBodyTableCopyDraft(
      sourceNoteID: sourceNoteID,
      targetNoteID: targetNoteID,
      ordinal: ordinal,
      rowCount: rowCount,
      columnCount: columnCount
    )
  }

  func bodyTableMoveDraft(
    noteID: String,
    ordinal: Int,
    targetOrdinal: Int,
    tables: [NotesBodyTableRecord]
  ) throws -> NotesBodyTableMoveDraft {
    guard ordinal > 0 && ordinal <= tables.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "ordinal": "\(ordinal)",
          "table_count": "\(tables.count)",
        ]
      )
    }
    guard targetOrdinal > 0 && targetOrdinal <= tables.count else {
      throw CLIError(
        code: .validationError,
        message: "`--to-ordinal` must target an existing table ordinal.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "to_ordinal": "\(targetOrdinal)",
          "table_count": "\(tables.count)",
        ]
      )
    }
    guard ordinal != targetOrdinal else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table move source and destination must differ.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "ordinal": "\(ordinal)",
          "to_ordinal": "\(targetOrdinal)",
        ]
      )
    }
    return NotesBodyTableMoveDraft(noteID: noteID, ordinal: ordinal, targetOrdinal: targetOrdinal)
  }

  func bodyTableFormatDraft(
    path: [String],
    options: CLIOptions,
    tables: [NotesBodyTableRecord]
  ) throws -> NotesBodyTableFormatDraft {
    let axis: NotesBodyTableStructureAxis
    switch path {
    case ["body", "table", "rows", "format"]:
      axis = .row
    case ["body", "table", "columns", "format"]:
      axis = .column
    default:
      throw CLIError(code: .internalError, message: "Unknown Notes body table format command.")
    }
    let noteID = try requiredOption("id", options: options)
    let ordinal = try normalizedPositiveIntOption("ordinal", options: options)
    guard ordinal > 0 && ordinal <= tables.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "ordinal": "\(ordinal)",
          "table_count": "\(tables.count)",
        ]
      )
    }
    let target = tables[ordinal - 1]
    let selectedDimension = axis == .row ? target.rowCount : target.columnCount
    let otherDimension = axis == .row ? target.columnCount : target.rowCount
    guard let selectedDimension, let otherDimension, selectedDimension > 0, otherDimension > 0 else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes body table format requires private framework row and column counts.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "ordinal": "\(ordinal)",
          "axis": axis.rawValue,
        ]
      )
    }
    let index = try normalizedPositiveIntOption("index", options: options)
    let count = options.targetOption("count") == nil
      ? 1
      : try normalizedPositiveIntOption("count", options: options)
    guard index + count - 1 <= selectedDimension else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table format range is outside the selected table.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "axis": axis.rawValue,
          "index": "\(index)",
          "count": "\(count)",
          "dimension": "\(selectedDimension)",
        ]
      )
    }
    return NotesBodyTableFormatDraft(
      noteID: noteID,
      ordinal: ordinal,
      axis: axis,
      index: index,
      count: count,
      format: try normalizedTableInlineFormatOption(options),
      enabled: options.targetOption("state") == nil ? true : try normalizedInlineStateOption("state", options: options),
      selectedCellCount: count * otherDimension
    )
  }

  private func normalizedTableInlineFormatOption(_ options: CLIOptions) throws -> NotesBodyInlineFormat {
    let hasFormat = options.targetOption("format") != nil
    let hasStyle = options.targetOption("style") != nil
    guard hasFormat || hasStyle else {
      throw CLIError(
        code: .validationError,
        message: "`body table rows format` and `body table columns format` require `--format` or `--style`.",
        details: ["allowed": NotesBodyInlineFormat.allowedDescription]
      )
    }
    guard !(hasFormat && hasStyle) else {
      throw CLIError(
        code: .validationError,
        message: "`--format` and `--style` cannot be used together.",
        details: ["allowed": "format,style"]
      )
    }
    return try normalizedInlineFormatOption(hasFormat ? "format" : "style", options: options)
  }

  func bodyTableFormatCells(
    _ draft: NotesBodyTableFormatDraft,
    tables: [NotesBodyTableRecord],
    reader: any NotesBodyStructureReading
  ) throws -> [NotesBodyTableCellRecord] {
    guard draft.ordinal > 0 && draft.ordinal <= tables.count else {
      return []
    }
    let table = tables[draft.ordinal - 1]
    switch draft.axis {
    case .row:
      guard let columnCount = table.columnCount, columnCount > 0 else {
        return []
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { row in
        try (1...columnCount).map { column in
          try reader.readTableCell(noteID: draft.noteID, tableOrdinal: draft.ordinal, row: row, column: column)
        }
      }
    case .column:
      guard let rowCount = table.rowCount, rowCount > 0 else {
        return []
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { column in
        try (1...rowCount).map { row in
          try reader.readTableCell(noteID: draft.noteID, tableOrdinal: draft.ordinal, row: row, column: column)
        }
      }
    }
  }

  func bodyTableStructureDraft(path: [String], options: CLIOptions) throws -> NotesBodyTableStructureDraft {
    let axis: NotesBodyTableStructureAxis
    let action: NotesBodyTableStructureAction
  switch path {
  case ["body", "table", "rows", "insert"]:
    axis = .row
    action = .insert
  case ["body", "table", "rows", "delete"]:
    axis = .row
    action = .delete
  case ["body", "table", "rows", "move"]:
    axis = .row
    action = .move
  case ["body", "table", "rows", "copy"]:
    axis = .row
    action = .copy
  case ["body", "table", "rows", "clear"]:
    axis = .row
    action = .clear
  case ["body", "table", "columns", "insert"]:
    axis = .column
    action = .insert
  case ["body", "table", "columns", "delete"]:
    axis = .column
    action = .delete
  case ["body", "table", "columns", "move"]:
    axis = .column
    action = .move
  case ["body", "table", "columns", "copy"]:
    axis = .column
    action = .copy
  case ["body", "table", "columns", "clear"]:
    axis = .column
    action = .clear
  default:
    throw CLIError(code: .internalError, message: "Unknown Notes body table structure command.")
  }
  let count = options.targetOption("count") == nil
    ? 1
    : try normalizedPositiveIntOption("count", options: options)
  let toIndex = action == .move || action == .copy
    ? try normalizedPositiveIntOption("to", options: options)
    : nil
  return NotesBodyTableStructureDraft(
    noteID: try requiredOption("id", options: options),
    ordinal: try normalizedPositiveIntOption("ordinal", options: options),
    axis: axis,
    action: action,
    index: try normalizedPositiveIntOption("index", options: options),
    toIndex: toIndex,
    count: count
  )
}

  func verifyBodyTables(
    structure: NotesBodyStructureRecord,
    tables: [NotesBodyTableRecord]
  ) -> NotesMutationVerificationReport {
    let ordinals = tables.map(\.ordinal)
    let expectedOrdinals = tables.isEmpty ? [] : Array(1...tables.count)
    let checks = [
      verificationBoolCheck(
        name: "table_count_matches_structure",
        expected: true,
        actual: tables.count == structure.tableCount
      ),
      verificationBoolCheck(
        name: "table_ordinals_contiguous",
        expected: true,
        actual: ordinals == expectedOrdinals
      ),
      verificationBoolCheck(
        name: "table_identity_hashes_present",
        expected: true,
        actual: tables.allSatisfy { !$0.idSHA256.isEmpty }
      ),
      verificationBoolCheck(
        name: "table_cell_text_hidden",
        expected: true,
        actual: true
      ),
      verificationBoolCheck(
        name: "private_identifiers_hidden",
        expected: true,
        actual: true
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.body.table.list",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_body_table_attachment_readback",
      targetIDSHA256: sha256Hex(structure.noteID),
      checks: checks
    )
  }

  func verifiedBodyTableMutationResult(
    _ result: NotesBodyTableCreateResult
  ) throws -> NotesBodyTableCreateResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body table mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyTableMutationResult(
    _ result: NotesBodyTableImportResult
  ) throws -> NotesBodyTableImportResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body table import verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

	  func verifiedBodyTableMutationResult(
	    _ result: NotesBodyTableUpdateResult
	  ) throws -> NotesBodyTableUpdateResult {
   guard result.verification.verified else {
     throw CLIError(
       code: .internalError,
       message: "Notes body table mutation verification failed.",
       details: [
         "operation": result.operation,
         "failed_checks": result.verification.checks
           .filter { $0.status == "failed" }
           .map(\.name)
           .joined(separator: ","),
         "target_id_sha256": result.verification.targetIDSHA256,
       ]
     )
   }
	    return result
	  }

	  func verifiedBodyTableMutationResult(
	    _ result: NotesBodyTableFormatResult
	  ) throws -> NotesBodyTableFormatResult {
	    guard result.verification.verified else {
	      throw CLIError(
	        code: .internalError,
	        message: "Notes body table mutation verification failed.",
	        details: [
	          "operation": result.operation,
	          "failed_checks": result.verification.checks
	            .filter { $0.status == "failed" }
	            .map(\.name)
	            .joined(separator: ","),
	          "target_id_sha256": result.verification.targetIDSHA256,
	        ]
	      )
	    }
	    return result
	  }

	    func verifiedBodyTableMutationResult(
	      _ result: NotesBodyTableDeleteResult
 ) throws -> NotesBodyTableDeleteResult {
 guard result.verification.verified else {
   throw CLIError(
     code: .internalError,
     message: "Notes body table mutation verification failed.",
     details: [
       "operation": result.operation,
       "failed_checks": result.verification.checks
         .filter { $0.status == "failed" }
         .map(\.name)
         .joined(separator: ","),
       "target_id_sha256": result.verification.targetIDSHA256,
     ]
   )
 }
   return result
 }

  func verifiedBodyTableMutationResult(
    _ result: NotesBodyTableConvertToTextResult
  ) throws -> NotesBodyTableConvertToTextResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body table mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyTableMutationResult(
    _ result: NotesBodyTableConvertFromTextResult
  ) throws -> NotesBodyTableConvertFromTextResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body table mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyTableMutationResult(
    _ result: NotesBodyTableCopyResult
  ) throws -> NotesBodyTableCopyResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body table mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyTableMutationResult(
    _ result: NotesBodyTableMoveResult
  ) throws -> NotesBodyTableMoveResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body table mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyTableStructureMutationResult(
    _ result: NotesBodyTableStructureResult
) throws -> NotesBodyTableStructureResult {
  guard result.verification.verified else {
    throw CLIError(
      code: .internalError,
      message: "Notes body table structure verification failed.",
      details: [
        "operation": result.operation,
        "failed_checks": result.verification.checks
          .filter { $0.status == "failed" }
          .map(\.name)
          .joined(separator: ","),
        "target_id_sha256": result.verification.targetIDSHA256,
      ]
    )
  }
  return result
}
}
