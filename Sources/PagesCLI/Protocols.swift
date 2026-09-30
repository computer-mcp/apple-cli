import AppKit
import CryptoKit
import Foundation
import Utility

public protocol PagesReading: Sendable {
  func listDocuments(path: String, limit: Int) throws -> [PagesDocumentRecord]
  func searchDocuments(path: String, query: String, limit: Int) throws -> [PagesDocumentRecord]
  func readDocument(path: String) throws -> PagesDocumentRecord?
}

public protocol PagesExporting: Sendable {
  func exportDocument(path: String, format: String, to destinationPath: String) throws
    -> PagesExportResult
}

public protocol PagesExternalActioning: Sendable {
  func open(path: String) throws -> Bool
}
