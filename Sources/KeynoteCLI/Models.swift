import AppKit
import CryptoKit
import Foundation
import Utility

public struct KeynotePresentationRecord: Codable, Equatable, Sendable {
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

public struct KeynotePresentationsResponse: Codable, Equatable, Sendable {
  public var presentations: [KeynotePresentationRecord]
}

public struct KeynotePresentationResponse: Codable, Equatable, Sendable {
  public var presentation: KeynotePresentationRecord
}

public struct KeynoteSlideRecord: Codable, Equatable, Sendable {
  public var presentationPath: String
  public var index: Int
  public var id: String
  public var previewPath: String?

  public init(
    presentationPath: String,
    index: Int,
    id: String,
    previewPath: String? = nil
  ) {
    self.presentationPath = presentationPath
    self.index = index
    self.id = id
    self.previewPath = previewPath
  }
}

public struct KeynoteSlidesResponse: Codable, Equatable, Sendable {
  public var presentation: KeynotePresentationRecord
  public var slides: [KeynoteSlideRecord]

  public init(presentation: KeynotePresentationRecord, slides: [KeynoteSlideRecord]) {
    self.presentation = presentation
    self.slides = slides
  }
}

public struct KeynoteExportResult: Codable, Equatable, Sendable {
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

public struct KeynoteSlideExportFile: Codable, Equatable, Sendable {
  public var slideID: String
  public var index: Int
  public var sourcePath: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String

  public init(
    slideID: String,
    index: Int,
    sourcePath: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String
  ) {
    self.slideID = slideID
    self.index = index
    self.sourcePath = sourcePath
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public struct KeynoteSlideExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var destinationPath: String
  public var format: String
  public var exportedSlideCount: Int
  public var files: [KeynoteSlideExportFile]

  public init(
    operation: String,
    changed: Bool,
    sourcePath: String,
    destinationPath: String,
    format: String,
    exportedSlideCount: Int,
    files: [KeynoteSlideExportFile]
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePath = sourcePath
    self.destinationPath = destinationPath
    self.format = format
    self.exportedSlideCount = exportedSlideCount
    self.files = files
  }
}
