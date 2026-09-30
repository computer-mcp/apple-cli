import AppKit
import CryptoKit
import Foundation
import Utility

public struct PagesDocumentRecord: Codable, Equatable, Sendable {
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

public struct PagesDocumentsResponse: Codable, Equatable, Sendable {
  public var documents: [PagesDocumentRecord]
}

public struct PagesDocumentResponse: Codable, Equatable, Sendable {
  public var document: PagesDocumentRecord
}

public struct PagesExportResult: Codable, Equatable, Sendable {
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
