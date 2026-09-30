import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

public struct NumbersDocumentRecord: Codable, Equatable, Sendable {
  public var path: String
  public var name: String
  public var isPackage: Bool
  public var size: Int64?
  public var modifiedAt: Date?
  public var quickLookPreviewPath: String?
  public var quickLookThumbnailPath: String?

  public init(
    path: String,
    name: String,
    isPackage: Bool,
    size: Int64? = nil,
    modifiedAt: Date? = nil,
    quickLookPreviewPath: String? = nil,
    quickLookThumbnailPath: String? = nil
  ) {
    self.path = path
    self.name = name
    self.isPackage = isPackage
    self.size = size
    self.modifiedAt = modifiedAt
    self.quickLookPreviewPath = quickLookPreviewPath
    self.quickLookThumbnailPath = quickLookThumbnailPath
  }
}

public struct NumbersDocumentsResponse: Codable, Equatable, Sendable {
  public var documents: [NumbersDocumentRecord]
}

public struct NumbersDocumentResponse: Codable, Equatable, Sendable {
  public var document: NumbersDocumentRecord
}

public struct NumbersTableSummary: Codable, Equatable, Sendable {
  public var index: Int
  public var name: String
  public var rowCount: Int
  public var columnCount: Int

  public init(index: Int, name: String, rowCount: Int, columnCount: Int) {
    self.index = index
    self.name = name
    self.rowCount = rowCount
    self.columnCount = columnCount
  }
}

public struct NumbersSheetRecord: Codable, Equatable, Sendable {
  public var index: Int
  public var name: String
  public var tables: [NumbersTableSummary]

  public init(index: Int, name: String, tables: [NumbersTableSummary] = []) {
    self.index = index
    self.name = name
    self.tables = tables
  }
}

public struct NumbersSheetsResponse: Codable, Equatable, Sendable {
  public var document: NumbersDocumentRecord
  public var sheets: [NumbersSheetRecord]
}

public struct NumbersTableRow: Codable, Equatable, Sendable {
  public var index: Int
  public var values: [String]

  public init(index: Int, values: [String]) {
    self.index = index
    self.values = values
  }
}

public struct NumbersTableRecord: Codable, Equatable, Sendable {
  public var sheetName: String
  public var tableName: String
  public var rowCount: Int
  public var columnCount: Int
  public var rows: [NumbersTableRow]

  public init(
    sheetName: String,
    tableName: String,
    rowCount: Int,
    columnCount: Int,
    rows: [NumbersTableRow]
  ) {
    self.sheetName = sheetName
    self.tableName = tableName
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.rows = rows
  }
}

public struct NumbersTableResponse: Codable, Equatable, Sendable {
  public var document: NumbersDocumentRecord
  public var table: NumbersTableRecord
}

public struct NumbersRangeResponse: Codable, Equatable, Sendable {
  public var document: NumbersDocumentRecord
  public var sheetName: String
  public var tableName: String
  public var range: String
  public var rows: [[String]]
}

public struct NumbersCellRecord: Codable, Equatable, Sendable {
  public var sheetName: String
  public var tableName: String
  public var row: Int
  public var column: Int
  public var rowCount: Int
  public var columnCount: Int
  public var value: String

  public init(
    sheetName: String,
    tableName: String,
    row: Int,
    column: Int,
    rowCount: Int,
    columnCount: Int,
    value: String
  ) {
    self.sheetName = sheetName
    self.tableName = tableName
    self.row = row
    self.column = column
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.value = value
  }
}

public struct NumbersFormulaResponse: Codable, Equatable, Sendable {
  public var document: NumbersDocumentRecord
  public var sheetName: String
  public var tableName: String
  public var row: Int
  public var column: Int
  public var formula: String
}

public struct NumbersExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var destinationPath: String
  public var format: String

  public init(
    operation: String,
    changed: Bool,
    sourcePath: String,
    destinationPath: String,
    format: String
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePath = sourcePath
    self.destinationPath = destinationPath
    self.format = format
  }
}

public struct NumbersTableExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var sheetName: String
  public var tableName: String
  public var destinationPath: String
  public var format: String
  public var rowCount: Int
  public var exportedRowCount: Int
  public var byteCount: Int
  public var sha256: String

  public init(
    operation: String,
    changed: Bool,
    sourcePath: String,
    sheetName: String,
    tableName: String,
    destinationPath: String,
    format: String,
    rowCount: Int,
    exportedRowCount: Int,
    byteCount: Int,
    sha256: String
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePath = sourcePath
    self.sheetName = sheetName
    self.tableName = tableName
    self.destinationPath = destinationPath
    self.format = format
    self.rowCount = rowCount
    self.exportedRowCount = exportedRowCount
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public struct NumbersCellWriteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var sheetName: String
  public var tableName: String
  public var row: Int
  public var column: Int
  public var valueByteCount: Int
  public var valueSHA256: String

  public init(
    operation: String,
    changed: Bool,
    sourcePath: String,
    sheetName: String,
    tableName: String,
    row: Int,
    column: Int,
    valueByteCount: Int,
    valueSHA256: String
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePath = sourcePath
    self.sheetName = sheetName
    self.tableName = tableName
    self.row = row
    self.column = column
    self.valueByteCount = valueByteCount
    self.valueSHA256 = valueSHA256
  }
}

public struct NumbersRangeWriteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var sheetName: String
  public var tableName: String
  public var range: String
  public var cellCount: Int
  public var payloadByteCount: Int
  public var payloadSHA256: String
}
