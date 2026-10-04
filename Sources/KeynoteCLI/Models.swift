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
  public var identityKind: String
  public var skipped: Bool
  public var titleShowing: Bool
  public var bodyShowing: Bool
  public var title: String?
  public var body: String?
  public var presenterNotes: String?

  public init(
    presentationPath: String,
    index: Int,
    id: String,
    skipped: Bool,
    titleShowing: Bool,
    bodyShowing: Bool,
    title: String? = nil,
    body: String? = nil,
    presenterNotes: String? = nil
  ) {
    self.presentationPath = presentationPath
    self.index = index
    self.id = id
    self.identityKind = "snapshot_position"
    self.skipped = skipped
    self.titleShowing = titleShowing
    self.bodyShowing = bodyShowing
    self.title = title
    self.body = body
    self.presenterNotes = presenterNotes
  }
}

public struct KeynoteSlidesResponse: Codable, Equatable, Sendable {
  public var presentation: KeynotePresentationRecord
  public var slides: [KeynoteSlideRecord]
  public var documentID: String
  public var snapshotID: String
  public var totalSlideCount: Int
  public var truncated: Bool
  public var readSource: String

  public init(
    presentation: KeynotePresentationRecord,
    slides: [KeynoteSlideRecord],
    documentID: String,
    snapshotID: String,
    totalSlideCount: Int,
    truncated: Bool,
    readSource: String
  ) {
    self.presentation = presentation
    self.slides = slides
    self.documentID = documentID
    self.snapshotID = snapshotID
    self.totalSlideCount = totalSlideCount
    self.truncated = truncated
    self.readSource = readSource
  }
}

public struct KeynotePreviewRecord: Codable, Equatable, Sendable {
  public var presentationPath: String
  public var index: Int
  public var id: String
  public var previewPath: String

  public init(presentationPath: String, index: Int, id: String, previewPath: String) {
    self.presentationPath = presentationPath
    self.index = index
    self.id = id
    self.previewPath = previewPath
  }
}

public struct KeynotePreviewsResponse: Codable, Equatable, Sendable {
  public var presentation: KeynotePresentationRecord
  public var previews: [KeynotePreviewRecord]
  public var source: String

  public init(presentation: KeynotePresentationRecord, previews: [KeynotePreviewRecord]) {
    self.presentation = presentation
    self.previews = previews
    self.source = "quicklook_cache"
  }
}

public struct KeynoteExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var destinationPath: String
  public var format: String
  public var source: String
  public var documentID: String?
  public var readSource: String?
  public var exportedSlideCount: Int?
  public var byteCount: Int?
  public var sha256: String?
  public var verification: String?
  public var residualArtifactPaths: [String]

  public init(
    operation: String,
    changed: Bool,
    sourcePath: String,
    destinationPath: String,
    format: String,
    source: String = "filesystem",
    documentID: String? = nil,
    readSource: String? = nil,
    exportedSlideCount: Int? = nil,
    byteCount: Int? = nil,
    sha256: String? = nil,
    verification: String? = nil,
    residualArtifactPaths: [String] = []
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePath = sourcePath
    self.destinationPath = destinationPath
    self.format = format
    self.source = source
    self.documentID = documentID
    self.readSource = readSource
    self.exportedSlideCount = exportedSlideCount
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
    self.residualArtifactPaths = residualArtifactPaths
  }
}

public struct KeynotePreviewExportFile: Codable, Equatable, Sendable {
  public var previewID: String
  public var index: Int
  public var sourcePath: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String

  public init(
    previewID: String,
    index: Int,
    sourcePath: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String
  ) {
    self.previewID = previewID
    self.index = index
    self.sourcePath = sourcePath
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public struct KeynotePreviewExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var destinationPath: String
  public var format: String
  public var exportedPreviewCount: Int
  public var source: String
  public var files: [KeynotePreviewExportFile]

  public init(
    operation: String,
    changed: Bool,
    sourcePath: String,
    destinationPath: String,
    format: String,
    exportedPreviewCount: Int,
    files: [KeynotePreviewExportFile]
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePath = sourcePath
    self.destinationPath = destinationPath
    self.format = format
    self.exportedPreviewCount = exportedPreviewCount
    self.source = "quicklook_cache"
    self.files = files
  }
}
