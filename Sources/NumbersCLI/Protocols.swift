import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

public protocol NumbersReading: Sendable {
  func listDocuments(path: String, limit: Int) throws -> [NumbersDocumentRecord]
  func searchDocuments(path: String, query: String, limit: Int) throws -> [NumbersDocumentRecord]
  func readDocument(path: String) throws -> NumbersDocumentRecord?
}

public protocol NumbersContentReading: Sendable {
  func listSheets(path: String) throws -> [NumbersSheetRecord]
  func readTable(path: String, sheet: String, table: String, limit: Int) throws
    -> NumbersTableRecord?
  func readCell(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> NumbersCellRecord?
  func readRange(path: String, sheet: String, table: String, range: String) throws -> [[String]]
  func getFormula(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> String
}

public protocol NumbersContentWriting: Sendable {
  func setCellText(path: String, sheet: String, table: String, row: Int, column: Int, value: String)
    throws
  func setRangeText(
    path: String, sheet: String, table: String, startRow: Int, startColumn: Int, values: [[String]])
    throws
  func clearRange(path: String, sheet: String, table: String, range: String) throws
  func setFormula(
    path: String, sheet: String, table: String, row: Int, column: Int, formula: String) throws
}

extension NumbersContentReading {
  public func readRange(path: String, sheet: String, table: String, range: String) throws
    -> [[String]]
  {
    throw unsupportedNumbersCapability("Numbers range reads are not implemented.")
  }

  public func getFormula(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> String
  {
    throw unsupportedNumbersCapability("Numbers formula reads are not implemented.")
  }
}

extension NumbersContentWriting {
  public func setRangeText(
    path: String, sheet: String, table: String, startRow: Int, startColumn: Int, values: [[String]]
  ) throws {
    throw unsupportedNumbersCapability("Numbers range writes are not implemented.")
  }

  public func clearRange(path: String, sheet: String, table: String, range: String) throws {
    throw unsupportedNumbersCapability("Numbers range clears are not implemented.")
  }

  public func setFormula(
    path: String, sheet: String, table: String, row: Int, column: Int, formula: String
  ) throws {
    throw unsupportedNumbersCapability("Numbers formula writes are not implemented.")
  }
}

public protocol NumbersExporting: Sendable {
  func exportDocument(path: String, format: String, to destinationPath: String) throws
    -> NumbersExportResult
}

public protocol NumbersExternalActioning: Sendable {
  func open(path: String) throws -> Bool
}
