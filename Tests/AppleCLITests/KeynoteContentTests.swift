import AppKit
import Carbon
import CoreGraphics
import CryptoKit
import Foundation
@testable import KeynoteCLI
import Testing
import Utility

@Suite
struct KeynoteContentTests {
  @Test func nativeSlidesRemainAvailableWithoutQuickLookCache() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key")
    try Data("source".utf8).write(to: file)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { _ in
      keynoteSlideDescriptor()
    })
    let response = try #require(try backend.listSlides(path: file.path, limit: 10))
    #expect(response.presentation.isPackage == false)
    #expect(response.totalSlideCount == 2)
    #expect(response.slides.map(\.index) == [1, 2])
    #expect(response.slides.map(\.skipped) == [false, true])
    #expect(response.slides.first?.title == "第一张 🧭")
    #expect(response.slides.first?.body == "Body\nSecond line")
    #expect(response.slides.last?.presenterNotes == "Notes\n备注")
    #expect(response.slides.last?.body == nil)
    #expect(response.slides.last?.bodyShowing == false)
    #expect(response.slides.allSatisfy { $0.identityKind == "snapshot_position" })
    #expect(response.slides.first?.id == "snapshot:\(response.snapshotID):1")
    #expect(response.documentID == "native-document")
    #expect(response.readSource == "live_document")
    #expect(!response.truncated)
    #expect(try backend.listPreviews(path: file.path, limit: 10)?.previews == [])
    #expect(try Data(contentsOf: file) == Data("source".utf8))
  }

  @Test func nativeSlideCountAndOrderDoNotComeFromStaleCache() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key", isDirectory: true)
    let cache = file.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
    try Data("old preview".utf8).write(to: cache.appendingPathComponent("Slide 99.jpg"))
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { _ in
      keynoteSlideDescriptor()
    })
    let response = try #require(try backend.listSlides(path: file.path, limit: 10))
    let next = try #require(try backend.listSlides(path: file.path, limit: 10))
    #expect(response.totalSlideCount == 2)
    #expect(response.slides.map(\.title) == ["第一张 🧭", "Closing"])
    #expect(response.snapshotID != next.snapshotID)
    #expect(response.slides.map(\.id) != next.slides.map(\.id))
    let previews = try #require(try backend.listPreviews(path: file.path, limit: 10))
    #expect(previews.source == "quicklook_cache")
    #expect(previews.previews.count == 1)
    #expect(previews.previews.first?.previewPath.hasSuffix("Slide 99.jpg") == true)
  }

  @Test func nativeSlidesReportTotalAndTruncationWithoutDroppingSkippedSlides() throws {
    let reader = KeynoteAppleScriptBackend { _ in keynoteSlideDescriptor(limit: 1) }
    let snapshot = try reader.readSlides(path: "/fixture.key", limit: 1)
    #expect(snapshot.totalSlideCount == 2)
    #expect(snapshot.slides.count == 1)
  }

  @Test func missingNativeContentDoesNotReportAnEmptyPresentation() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key")
    try Data().write(to: file)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { _ in
      throw CLIError(code: .permissionDenied, message: "Fixture permission denied.")
    })
    try expectKeynoteError(.permissionDenied) { _ = try backend.listSlides(path: file.path, limit: 10) }
    #expect(try backend.listPreviews(path: file.path, limit: 10)?.previews == [])
  }

  @Test func aNativeZeroSlideCountRequiresACompleteTypedResponse() throws {
    let reader = KeynoteAppleScriptBackend { _ in keynoteSlideDescriptor(total: 0) }
    let snapshot = try reader.readSlides(path: "/fixture.key", limit: 10)
    #expect(snapshot.totalSlideCount == 0)
    #expect(snapshot.slides.isEmpty)
  }

  @Test(arguments: ["missing", "non-list", "short-row", "wrong-index", "short-list", "bool-text", "count-text", "unknown-source", "empty-id", "text-number"])
  func incompleteNativeSchemasFailRatherThanDiscardingSlides(_ defect: String) throws {
    let reader = KeynoteAppleScriptBackend { _ in keynoteSlideDescriptor(defect: defect) }
    try expectKeynoteError(.backendUnavailable) { _ = try reader.readSlides(path: "/fixture.key", limit: 10) }
  }

  @Test(arguments: [0, -1, 501])
  func invalidLimitsFailBeforeAutomation(_ limit: Int) throws {
    let reader = KeynoteAppleScriptBackend { _ in
      Issue.record("Invalid selection must not execute automation.")
      return keynoteSlideDescriptor()
    }
    try expectKeynoteError(.validationError) { _ = try reader.readSlides(path: "/fixture.key", limit: limit) }
  }

  @Test(arguments: [(-1712, CLIErrorCode.timeout), (-1743, .permissionDenied), (-1744, .permissionDenied), (-1728, .notFound), (-43, .notFound), (-2702, .backendUnavailable), (-10000, .backendUnavailable)])
  func nativeErrorsKeepPermissionTimeoutAndConcurrentChangeSemantics(_ number: Int, _ code: CLIErrorCode) {
    let error = KeynoteAppleScriptBackend.automationError([
      NSAppleScript.errorNumber: number, NSAppleScript.errorMessage: "private selected text",
    ])
    #expect(error.code == code)
    #expect(!error.message.contains("private selected text"))
    #expect(!error.details.values.contains("private selected text"))
  }

  @Test func nativePDFExportPublishesVerifiedOutputInsteadOfCachedPDF() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key", isDirectory: true)
    let cache = file.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
    try Data("stale cached PDF".utf8).write(to: cache.appendingPathComponent("Preview.pdf"))
    let pdf = try keynoteFixturePDF(pages: 2)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { source in
      try pdf.write(to: keynoteStagingPDF(in: source), options: .withoutOverwriting)
      return keynotePDFReceipt(slides: 2)
    })
    let destination = root.appendingPathComponent("Deck.pdf")
    let result = try backend.exportPresentation(path: file.path, format: "pdf", to: destination.path)
    #expect(result.source == "keynote_document")
    #expect(result.readSource == "opened_file")
    #expect(result.documentID == "native-document")
    #expect(result.exportedSlideCount == 2)
    #expect(result.verification == "verified")
    #expect(result.residualArtifactPaths.isEmpty)
    #expect(result.byteCount == pdf.count)
    #expect(result.sha256 == SHA256.hash(data: pdf).map { String(format: "%02x", $0) }.joined())
    #expect(try Data(contentsOf: destination) == pdf)
    #expect(try Data(contentsOf: cache.appendingPathComponent("Preview.pdf")) == Data("stale cached PDF".utf8))
    #expect(try FileManager.default.contentsOfDirectory(atPath: root.path).allSatisfy { !$0.hasPrefix(".apple-cli-keynote-") })
  }

  @Test(arguments: ["missing", "invalid-pdf", "wrong-page-count", "unknown-receipt"])
  func unverifiedNativePDFNeverPublishesTheDestination(_ defect: String) throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key")
    try Data("source".utf8).write(to: file)
    let validPDF = try keynoteFixturePDF(pages: 1)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { source in
      if defect != "missing" {
        let data = defect == "invalid-pdf" ? Data("not a PDF".utf8) : validPDF
        try data.write(to: keynoteStagingPDF(in: source), options: .withoutOverwriting)
      }
      return defect == "unknown-receipt" ? NSAppleEventDescriptor.list() : keynotePDFReceipt(slides: 2)
    })
    let destination = root.appendingPathComponent("Deck.pdf")
    try expectKeynoteError(.backendUnavailable) {
      _ = try backend.exportPresentation(path: file.path, format: "pdf", to: destination.path)
    }
    #expect(!FileManager.default.fileExists(atPath: destination.path))
    #expect(try Data(contentsOf: file) == Data("source".utf8))
  }

  @Test func PDFDestinationThatAppearsDuringExportIsPreserved() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key")
    try Data().write(to: file)
    let destination = root.appendingPathComponent("Deck.pdf")
    let pdf = try keynoteFixturePDF(pages: 2)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { source in
      try pdf.write(to: keynoteStagingPDF(in: source), options: .withoutOverwriting)
      try Data("user artifact".utf8).write(to: destination)
      return keynotePDFReceipt(slides: 2)
    })
    try expectKeynoteError(.validationError) {
      _ = try backend.exportPresentation(path: file.path, format: "pdf", to: destination.path)
    }
    #expect(try Data(contentsOf: destination) == Data("user artifact".utf8))
  }

  @Test func nativePDFTimeoutRemainsUnconfirmedWithoutRetryOrCacheFallback() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key")
    try Data().write(to: file)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { _ in
      throw CLIError(code: .timeout, message: "Fixture timeout.")
    })
    do {
      _ = try backend.exportPresentation(path: file.path, format: "pdf", to: root.appendingPathComponent("Deck.pdf").path)
      Issue.record("Expected unconfirmed native export.")
    } catch let error as CLIError {
      #expect(error.code == .timeout)
      #expect(error.details["artifact_outcome"] == "unconfirmed")
      #expect(error.details["retry_policy"] == "inspect_before_retry")
      #expect(error.details["staging_path"]?.hasSuffix(".pdf") == true)
    }
  }

  @Test func searchMatchesPastTheOldFiveHundredCandidateLimit() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    for index in 0..<501 {
      try Data().write(to: root.appendingPathComponent(String(format: "A%03d.key", index)))
    }
    try Data().write(to: root.appendingPathComponent("ZZZ-Match.key"))
    let matches = try FileManagerKeynoteBackend().searchPresentations(path: root.path, query: "match", limit: 1)
    #expect(matches.map(\.name) == ["ZZZ-Match.key"])
  }

  @Test(arguments: ["pdf", "preview-pdf", "thumbnail", "package"])
  func exportsCannotWriteInsideTheSourcePackageThroughASymlink(_ format: String) throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key", isDirectory: true)
    try FileManager.default.createDirectory(at: file, withIntermediateDirectories: false)
    let alias = root.appendingPathComponent("Alias", isDirectory: true)
    try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: file)
    let backend = FileManagerKeynoteBackend(native: KeynoteAppleScriptBackend { _ in
      Issue.record("A destination within the presentation must fail before automation.")
      return keynotePDFReceipt(slides: 2)
    })
    let name = format == "package" ? "Copy.key" : (format == "thumbnail" ? "Copy.jpg" : "Copy.pdf")
    try expectKeynoteError(.validationError) {
      _ = try backend.exportPresentation(path: file.path, format: format, to: alias.appendingPathComponent(name).path)
    }
    #expect(try FileManager.default.contentsOfDirectory(atPath: file.path).isEmpty)
  }

  @Test func sourceProtectionUsesFilesystemIdentityForAlternatePathCasing() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key", isDirectory: true)
    let alternate = root.appendingPathComponent("dECk.KEY", isDirectory: true)
    try FileManager.default.createDirectory(at: file, withIntermediateDirectories: false)
    let destination = alternate.appendingPathComponent("Copy.pdf")
    if FileManager.default.fileExists(atPath: alternate.path) {
      try expectKeynoteError(.validationError) {
        try validatePresentationArtifactRelationship(source: file, destination: destination)
      }
    } else {
      try FileManager.default.createDirectory(at: alternate, withIntermediateDirectories: false)
      try validatePresentationArtifactRelationship(source: file, destination: destination)
    }
    #expect(try FileManager.default.contentsOfDirectory(atPath: file.path).isEmpty)
  }

  @Test(arguments: ["/fixture \"quoted\"\\Deck.key", "/fixture\nDeck.key", "/fixture\rDeck.key", "/fixture\r\nDeck.key", "/资料/🧭/e\u{301}.key"])
  @MainActor func scriptPathLiteralsPreserveExactScalarSequences(_ path: String) throws {
    let source = "return \(keynoteAppleScriptLiteral(path))"
    let script = try #require(NSAppleScript(source: source))
    var errorInfo: NSDictionary?
    let descriptor = script.executeAndReturnError(&errorInfo)
    #expect(errorInfo == nil)
    let decoded = try #require(descriptor.stringValue)
    #expect(Array(decoded.utf8) == Array(path.utf8))
  }

  @Test func previewExportCannotWriteInsideItsPresentationThroughASymlink() throws {
    let root = try keynoteScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("Deck.key", isDirectory: true)
    let cache = file.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
    try Data("cached preview".utf8).write(to: cache.appendingPathComponent("Slide 1.jpg"))
    let alias = root.appendingPathComponent("Alias", isDirectory: true)
    try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: file)
    let options = try CLIOptionsFixture.parse([
      "previews", "export", "--path", file.path, "--to", alias.appendingPathComponent("Images").path,
      "--format", "images", "--allow-artifact-action", "--json",
    ])
    try expectKeynoteError(.validationError) { _ = try KeynoteCommand().run(options: options) }
    #expect(!FileManager.default.fileExists(atPath: file.appendingPathComponent("Images").path))
    #expect(try Data(contentsOf: cache.appendingPathComponent("Slide 1.jpg")) == Data("cached preview".utf8))
  }

  @Test(.enabled(if: ProcessInfo.processInfo.environment["APPLE_CLI_VALIDATE_IWORK_SDEF"] == "1"))
  func keynoteScriptsCompileAgainstInstalledDictionary() throws {
    for source in [
      KeynoteAppleScriptBackend.slidesScript(path: "/fixture \"quoted\"\\name\nDeck.key", limit: 2),
      KeynoteAppleScriptBackend.pdfScript(path: "/fixture.key", to: "/fixture-export.pdf"),
    ] {
      let script = try #require(NSAppleScript(source: source))
      var errorInfo: NSDictionary?
      let compiled = script.compileAndReturnError(&errorInfo)
      #expect(compiled, "\(errorInfo?[NSAppleScript.errorNumber] ?? "unknown")")
      #expect(errorInfo == nil)
    }
  }
}

private func keynoteScratchRoot() throws -> URL {
  let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
  try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
  return root
}

private func expectKeynoteError(_ code: CLIErrorCode, operation: () throws -> Void) throws {
  do {
    try operation()
    Issue.record("Expected Keynote error \(code).")
  } catch let error as CLIError {
    #expect(error.code == code)
  }
}

private func keynoteAEList(_ fields: [NSAppleEventDescriptor]) -> NSAppleEventDescriptor {
  let result = NSAppleEventDescriptor.list()
  for (offset, field) in fields.enumerated() { result.insert(field, at: offset + 1) }
  return result
}

private func keynoteSlideDescriptor(limit: Int = 2, total: Int = 2, defect: String? = nil) -> NSAppleEventDescriptor {
  if defect == "missing" { return NSAppleEventDescriptor.list() }
  if defect == "non-list" { return NSAppleEventDescriptor(string: "not a list") }
  var first: [NSAppleEventDescriptor] = [
    NSAppleEventDescriptor(int32: defect == "wrong-index" ? 2 : 1),
    defect == "bool-text" ? NSAppleEventDescriptor(string: "false") : NSAppleEventDescriptor(boolean: false),
    NSAppleEventDescriptor(boolean: true), NSAppleEventDescriptor(boolean: true),
    defect == "text-number" ? NSAppleEventDescriptor(int32: 123) : NSAppleEventDescriptor(string: "第一张 🧭"),
    NSAppleEventDescriptor(string: "Body\nSecond line"), NSAppleEventDescriptor(string: ""),
  ]
  if defect == "short-row" { first.removeLast() }
  let second = keynoteAEList([
    NSAppleEventDescriptor(int32: 2), NSAppleEventDescriptor(boolean: true),
    NSAppleEventDescriptor(boolean: true), NSAppleEventDescriptor(boolean: false),
    NSAppleEventDescriptor(string: "Closing"), NSAppleEventDescriptor(typeCode: OSType(cMissingValue)),
    NSAppleEventDescriptor(string: "Notes\n备注"),
  ])
  let rows = total == 0 ? [] : Array([keynoteAEList(first), second].prefix(defect == "short-list" ? 1 : limit))
  return keynoteAEList([
    NSAppleEventDescriptor(string: defect == "empty-id" ? "" : "native-document"),
    NSAppleEventDescriptor(string: defect == "unknown-source" ? "unknown" : "live_document"),
    defect == "count-text" ? NSAppleEventDescriptor(string: "2") : NSAppleEventDescriptor(int32: Int32(total)),
    keynoteAEList(rows),
  ])
}

private func keynotePDFReceipt(slides: Int) -> NSAppleEventDescriptor {
  keynoteAEList([
    NSAppleEventDescriptor(string: "native-document"), NSAppleEventDescriptor(string: "opened_file"),
    NSAppleEventDescriptor(int32: Int32(slides)),
  ])
}

private func keynoteFixturePDF(pages: Int) throws -> Data {
  let data = NSMutableData()
  let consumer = try #require(CGDataConsumer(data: data))
  var box = CGRect(x: 0, y: 0, width: 320, height: 240)
  let context = try #require(CGContext(consumer: consumer, mediaBox: &box, nil))
  for _ in 0..<pages { context.beginPDFPage(nil); context.endPDFPage() }
  context.closePDF()
  return data as Data
}

private func keynoteStagingPDF(in source: String) throws -> URL {
  let marker = "export targetDocument to (POSIX file (\""
  let start = try #require(source.range(of: marker)?.upperBound)
  let end = try #require(source[start...].firstIndex(of: "\""))
  return URL(fileURLWithPath: String(source[start..<end]))
}
