import AppKit
import CryptoKit
import Foundation
import Utility

public protocol KeynoteReading: Sendable {
  func listPresentations(path: String, limit: Int) throws -> [KeynotePresentationRecord]
  func searchPresentations(path: String, query: String, limit: Int) throws
    -> [KeynotePresentationRecord]
  func readPresentation(path: String) throws -> KeynotePresentationRecord?
  func listSlides(path: String, limit: Int) throws -> KeynoteSlidesResponse?
  func listPreviews(path: String, limit: Int) throws -> KeynotePreviewsResponse?
}

public protocol KeynoteExporting: Sendable {
  func exportPresentation(path: String, format: String, to destinationPath: String) throws
    -> KeynoteExportResult
}

public protocol KeynoteExternalActioning: Sendable {
  func open(path: String) throws -> Bool
}
