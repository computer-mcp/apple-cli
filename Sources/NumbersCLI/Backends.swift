import AppKit
import Carbon
import CryptoKit
import Darwin
import Foundation
import Utility


public struct NumbersExternalActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var path: String
}

public struct NSWorkspaceNumbersExternalActions: NumbersExternalActioning {
  public init() {}

  public func open(path: String) throws -> Bool {
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
  }
}

public struct NumbersAppleScriptContentBackend: NumbersContentReading, NumbersContentWriting {
  private let executeScript: @Sendable (String) throws -> NSAppleEventDescriptor

  public init() {
    executeScript = Self.runScript
  }

  init(executeScript: @escaping @Sendable (String) throws -> NSAppleEventDescriptor) {
    self.executeScript = executeScript
  }

  public func listSheets(path: String) throws -> [NumbersSheetRecord] {
    let rows = try runRows(
      """
      set output to {}
      tell application "Numbers"
        set targetDocument to missing value
        set documentWasOpen to false
        set existingDocumentIDs to id of every document
        repeat with eachDocument in documents
          try
            set documentPath to POSIX path of (file of eachDocument as alias)
            if documentPath is equal to "\(appleScriptString(path))" then
              set targetDocument to eachDocument
              set documentWasOpen to true
              exit repeat
            end if
          end try
        end repeat
        if targetDocument is missing value then
          set targetDocument to open (POSIX file "\(appleScriptString(path))")
          set documentWasOpen to (id of targetDocument) is in existingDocumentIDs
        end if
        set sheetIndex to 0
        repeat with eachSheet in sheets of targetDocument
          set sheetIndex to sheetIndex + 1
          set sheetName to name of eachSheet as text
          set tableIndex to 0
          if (count of tables of eachSheet) is 0 then
            set end of output to {sheetIndex as text, sheetName, "", "", "0", "0"}
          else
            repeat with eachTable in tables of eachSheet
              set tableIndex to tableIndex + 1
              set tableName to name of eachTable as text
              set rowCount to count of rows of eachTable
              set columnCount to count of columns of eachTable
              set end of output to {sheetIndex as text, sheetName, tableIndex as text, tableName, rowCount as text, columnCount as text}
            end repeat
          end if
        end repeat
        if documentWasOpen is false then close targetDocument saving no
      end tell
      return output
      """)

    var sheets: [NumbersSheetRecord] = []
    for row in rows {
      guard let sheetIndex = Int(row[safe: 0] ?? ""), let sheetName = row[safe: 1] else {
        continue
      }
      let table: NumbersTableSummary?
      if let tableIndex = Int(row[safe: 2] ?? ""), let tableName = row[safe: 3], !tableName.isEmpty
      {
        table = NumbersTableSummary(
          index: tableIndex,
          name: tableName,
          rowCount: Int(row[safe: 4] ?? "") ?? 0,
          columnCount: Int(row[safe: 5] ?? "") ?? 0
        )
      } else {
        table = nil
      }

      if let existingIndex = sheets.firstIndex(where: {
        $0.index == sheetIndex && $0.name == sheetName
      }) {
        if let table {
          sheets[existingIndex].tables.append(table)
        }
      } else {
        sheets.append(
          NumbersSheetRecord(index: sheetIndex, name: sheetName, tables: table.map { [$0] } ?? []))
      }
    }
    return sheets
  }

  public func readTable(path: String, sheet: String, table: String, limit: Int) throws
    -> NumbersTableRecord?
  {
    let rows = try runRows(
      """
      set output to {}
      tell application "Numbers"
        set targetDocument to missing value
        set documentWasOpen to false
        set existingDocumentIDs to id of every document
        repeat with eachDocument in documents
          try
            set documentPath to POSIX path of (file of eachDocument as alias)
            if documentPath is equal to "\(appleScriptString(path))" then
              set targetDocument to eachDocument
              set documentWasOpen to true
              exit repeat
            end if
          end try
        end repeat
        if targetDocument is missing value then
          set targetDocument to open (POSIX file "\(appleScriptString(path))")
          set documentWasOpen to (id of targetDocument) is in existingDocumentIDs
        end if
        repeat with eachSheet in sheets of targetDocument
          set sheetName to name of eachSheet as text
          if sheetName is equal to "\(appleScriptString(sheet))" then
            repeat with eachTable in tables of eachSheet
              set tableName to name of eachTable as text
              if tableName is equal to "\(appleScriptString(table))" then
                set rowCount to count of rows of eachTable
                set columnCount to count of columns of eachTable
                set maxRows to rowCount
                if maxRows is greater than \(limit) then set maxRows to \(limit)
                if maxRows is 0 then
                  set end of output to {sheetName, tableName, rowCount as text, columnCount as text, "0"}
                else
                  repeat with rowIndex from 1 to maxRows
                    set rowValues to {sheetName, tableName, rowCount as text, columnCount as text, rowIndex as text}
                    repeat with columnIndex from 1 to columnCount
                      set cellText to ""
                      try
                        set cellText to formatted value of cell columnIndex of row rowIndex of eachTable as text
                      on error
                        try
                          set cellText to value of cell columnIndex of row rowIndex of eachTable as text
                        end try
                      end try
                      set end of rowValues to cellText
                    end repeat
                    set end of output to rowValues
                  end repeat
                end if
                if documentWasOpen is false then close targetDocument saving no
                return output
              end if
            end repeat
          end if
        end repeat
        if documentWasOpen is false then close targetDocument saving no
      end tell
      return output
      """)

    guard let first = rows.first, let rowCount = Int(first[safe: 2] ?? ""),
      let columnCount = Int(first[safe: 3] ?? "")
    else {
      return nil
    }

    let tableRows = rows.compactMap { row -> NumbersTableRow? in
      guard let index = Int(row[safe: 4] ?? ""), index > 0 else {
        return nil
      }
      return NumbersTableRow(index: index, values: Array(row.dropFirst(5)))
    }

    return NumbersTableRecord(
      sheetName: first[safe: 0] ?? sheet,
      tableName: first[safe: 1] ?? table,
      rowCount: rowCount,
      columnCount: columnCount,
      rows: tableRows
    )
  }

  public func readCell(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> NumbersCellRecord?
  {
    let output = try executeScript(
      """
      set output to {}
      tell application "Numbers"
        set targetDocument to missing value
        set documentWasOpen to false
        set existingDocumentIDs to id of every document
        repeat with eachDocument in documents
          try
            set documentPath to POSIX path of (file of eachDocument as alias)
            if documentPath is equal to "\(appleScriptString(path))" then
              set targetDocument to eachDocument
              set documentWasOpen to true
              exit repeat
            end if
          end try
        end repeat
        if targetDocument is missing value then
          set targetDocument to open (POSIX file "\(appleScriptString(path))")
          set documentWasOpen to (id of targetDocument) is in existingDocumentIDs
        end if
        try
          repeat with eachSheet in sheets of targetDocument
            set sheetName to name of eachSheet as text
            if sheetName is equal to "\(appleScriptString(sheet))" then
              repeat with eachTable in tables of eachSheet
                set tableName to name of eachTable as text
                if tableName is equal to "\(appleScriptString(table))" then
                  set rowCount to count of rows of eachTable
                  set columnCount to count of columns of eachTable
                  if \(row) is greater than rowCount or \(column) is greater than columnCount then
                    if documentWasOpen is false then close targetDocument saving no
                    return output
                  end if
                  set targetCell to cell \(column) of row \(row) of eachTable
                  set cellText to formatted value of targetCell
                  set rawCellValue to value of targetCell
                  set cellFormula to formula of targetCell
                  set end of output to {sheetName, tableName, rowCount as text, columnCount as text, "\(row)", "\(column)", cellText, rawCellValue, cellFormula}
                  if documentWasOpen is false then close targetDocument saving no
                  return output
                end if
              end repeat
            end if
          end repeat
          if documentWasOpen is false then close targetDocument saving no
        on error failureMessage number failureNumber
          try
            if documentWasOpen is false then close targetDocument saving no
          end try
          error "Numbers cell read failed." number failureNumber
        end try
      end tell
      return output
      """)

    guard output.descriptorType == typeAEList else {
      throw CLIError(code: .backendUnavailable, message: "Numbers did not return a cell result list.")
    }
    if output.numberOfItems == 0 { return nil }
    guard output.numberOfItems == 1, let first = output.atIndex(1) else {
      throw CLIError(code: .backendUnavailable, message: "Numbers returned an ambiguous cell result.")
    }
    return try numbersCellRecord(first)
  }

  public func readRange(path: String, sheet: String, table: String, range: String) throws
    -> [[String]]
  {
    throw unsupportedRangeOrFormulaOperation()
  }

  public func getFormula(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> String
  {
    throw unsupportedRangeOrFormulaOperation()
  }

  public func setCellText(
    path: String, sheet: String, table: String, row: Int, column: Int, value: String
  ) throws {
    let rows = try runRows(
      """
      set output to {}
      tell application "Numbers"
        set targetDocument to missing value
        set documentWasOpen to false
        set existingDocumentIDs to id of every document
        repeat with eachDocument in documents
          try
            set documentPath to POSIX path of (file of eachDocument as alias)
            if documentPath is equal to "\(appleScriptString(path))" then
              set targetDocument to eachDocument
              set documentWasOpen to true
              exit repeat
            end if
          end try
        end repeat
        if documentWasOpen then
          error "Close the document in Numbers before writing cells." number -2701
        end if
        if targetDocument is missing value then
          set targetDocument to open (POSIX file "\(appleScriptString(path))")
          if (id of targetDocument) is in existingDocumentIDs then
            error "Close the document in Numbers before writing cells." number -2701
          end if
        end if
        try
          repeat with eachSheet in sheets of targetDocument
            set sheetName to name of eachSheet as text
            if sheetName is equal to "\(appleScriptString(sheet))" then
              repeat with eachTable in tables of eachSheet
                set tableName to name of eachTable as text
                if tableName is equal to "\(appleScriptString(table))" then
                  set rowCount to count of rows of eachTable
                  set columnCount to count of columns of eachTable
                  if \(row) is greater than rowCount or \(column) is greater than columnCount then
                    if documentWasOpen is false then close targetDocument saving no
                    error "Numbers cell was not found." number -1728
                  end if
                  set value of cell \(column) of row \(row) of eachTable to "\(appleScriptString(value))"
                  save targetDocument
                  set end of output to {"ok"}
                  if documentWasOpen is false then close targetDocument saving yes
                  return output
                end if
              end repeat
            end if
          end repeat
          if documentWasOpen is false then close targetDocument saving no
          error "Numbers table was not found." number -1728
        on error failureMessage number failureNumber
          try
            close targetDocument saving no
          end try
          error "Numbers cell write failed." number failureNumber
        end try
      end tell
      return output
      """)

    guard rows.first?.first == "ok" else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Numbers cell write did not return an execution result."
      )
    }
  }

  public func setRangeText(
    path: String, sheet: String, table: String, startRow: Int, startColumn: Int, values: [[String]]
  ) throws {
    throw unsupportedRangeOrFormulaOperation()
  }

  public func clearRange(path: String, sheet: String, table: String, range: String) throws {
    throw unsupportedRangeOrFormulaOperation()
  }

  public func setFormula(
    path: String, sheet: String, table: String, row: Int, column: Int, formula: String
  ) throws {
    throw unsupportedRangeOrFormulaOperation()
  }

  private func unsupportedRangeOrFormulaOperation() -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message: "Numbers range and formula operations are not supported by the current CLI contract."
    )
  }

  private func runRows(_ source: String) throws -> [[String]] {
    try executeScript(source).rows()
  }

  private static func runScript(_ source: String) throws -> NSAppleEventDescriptor {
    var errorInfo: NSDictionary?
    let boundedSource = """
    with timeout of 30 seconds
    \(source)
    end timeout
    """
    guard let script = NSAppleScript(source: boundedSource) else {
      throw CLIError(code: .internalError, message: "Failed to compile Numbers automation script.")
    }
    let descriptor = script.executeAndReturnError(&errorInfo)
    if let errorInfo { throw automationError(errorInfo) }
    return descriptor
  }

  private static func automationError(_ errorInfo: NSDictionary) -> CLIError {
    let number = errorInfo[NSAppleScript.errorNumber] as? Int
    let code: CLIErrorCode
    if number == -1712 {
      code = .timeout
    } else if number == -1743 || number == -1744 {
      code = .permissionDenied
    } else if number == -2701 {
      return CLIError(
        code: .unsafeMutationRefused,
        message: "Close the document in Numbers before writing cells."
      )
    } else if number == -1728 {
      code = .notFound
    } else {
      code = .backendUnavailable
    }
    return CLIError.appleEventFailure(
      target: "Numbers", code: code, number: number)
  }
}

public struct FileManagerNumbersBackend: NumbersReading, NumbersExporting {
  public init() {}

  public func listDocuments(path: String, limit: Int) throws -> [NumbersDocumentRecord] {
    let url = normalizedURL(path)
    if isNumbersDocument(url) {
      return try [documentRecord(url)]
    }

    let root = try directoryURL(path)
    return try directNumbersDocuments(root: root, limit: limit)
  }

  public func searchDocuments(path: String, query: String, limit: Int) throws
    -> [NumbersDocumentRecord]
  {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    return try listDocuments(path: path, limit: 500)
      .filter { $0.name.localizedCaseInsensitiveContains(normalizedQuery) }
      .prefix(limit)
      .map { $0 }
  }

  public func readDocument(path: String) throws -> NumbersDocumentRecord? {
    let url = normalizedURL(path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }
    guard isNumbersDocument(url) else {
      throw CLIError(
        code: .validationError,
        message: "`--path` must identify a `.numbers` document.",
        details: ["path": path]
      )
    }
    return try documentRecord(url)
  }

  public func exportDocument(path: String, format: String, to destinationPath: String) throws
    -> NumbersExportResult
  {
    guard let document = try readDocument(path: path) else {
      throw CLIError(
        code: .notFound, message: "Numbers document was not found.", details: ["path": path])
    }
    if format == "package" {
      guard document.isPackage else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Numbers package export requires a package-style `.numbers` document.",
          details: ["path": document.path]
        )
      }
      let source = normalizedURL(document.path)
      let destination = normalizedURL(destinationPath)
      try validateDocumentExportDestination(destination.path, format: format)
      try validatePackageExportRelationship(source: source, destination: destination)
      try FileManager.default.copyItem(at: source, to: destination)
      return NumbersExportResult(
        operation: "numbers.export",
        changed: true,
        sourcePath: document.path,
        destinationPath: destination.path,
        format: format
      )
    }
    let sourcePath: String?
    switch format {
    case "pdf":
      sourcePath = document.quickLookPreviewPath
    case "thumbnail":
      sourcePath = document.quickLookThumbnailPath
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Numbers export currently supports only `pdf`, `thumbnail`, and `package`.")
    }
    guard let sourcePath else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Numbers document does not contain a QuickLook \(format) export source.",
        details: ["path": path, "format": format]
      )
    }

    let destination = normalizedURL(destinationPath)
    try validateDocumentExportDestination(destination.path, format: format)

    try FileManager.default.copyItem(at: URL(fileURLWithPath: sourcePath), to: destination)
    return NumbersExportResult(
      operation: "numbers.export",
      changed: true,
      sourcePath: document.path,
      destinationPath: destination.path,
      format: format
    )
  }

  private func directNumbersDocuments(root: URL, limit: Int) throws -> [NumbersDocumentRecord] {
    let urls = try FileManager.default.contentsOfDirectory(
      at: root,
      includingPropertiesForKeys: Array(NumbersResourceKeys.all),
      options: [.skipsHiddenFiles]
    )
    .filter(isNumbersDocument)
    .sorted {
      $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
        == .orderedAscending
    }
    .prefix(limit)

    return try urls.map(documentRecord)
  }

  private func directoryURL(_ path: String) throws -> URL {
    let url = normalizedURL(path)
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
      throw CLIError(
        code: .notFound, message: "Numbers path was not found.", details: ["path": path])
    }
    guard isDirectory.boolValue else {
      throw CLIError(
        code: .validationError,
        message: "`--path` must identify a directory or `.numbers` document.",
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

  private func isNumbersDocument(_ url: URL) -> Bool {
    url.pathExtension.lowercased() == "numbers"
  }

  private func documentRecord(_ url: URL) throws -> NumbersDocumentRecord {
    let values = try url.resourceValues(forKeys: NumbersResourceKeys.all)
    return NumbersDocumentRecord(
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
