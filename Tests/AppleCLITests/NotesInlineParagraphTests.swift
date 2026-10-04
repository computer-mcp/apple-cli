import AppKit
import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite struct NotesInlineParagraphTests {
  @Test func unstyledBodyAndEmptyParagraphsHaveRealUTF16Ranges() throws {
    let text = "Title\r\n\r\n前😀 e\u{301}\nTail" as NSString
    let paragraphs = notesInlineParagraphs(noteID: "note", in: text, nativeAnchors: [])
    #expect(paragraphs.map { text.substring(with: $0.range) } == ["Title\r\n", "\r\n", "前😀 e\u{301}\n", "Tail"])
    let selected = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: [],
      paragraphIDSHA256: nil, ordinal: 3, operation: "test")
    #expect(selected.range == NSRange(location: 9, length: 7))
    #expect(notesInlineParagraphs(noteID: "note", in: "", nativeAnchors: []).isEmpty)
  }

  @Test func nativeHashesSelectAnchorsIndependentlyOfPlainTextOrdinals() throws {
    let text = "Title\nPlain\nHeading\nBody" as NSString
    let headingRange = text.paragraphRange(for: text.range(of: "Heading"))
    let native = NotesInlineParagraph(range: headingRange, idSHA256: "native-heading-hash")
    let paragraphs = notesInlineParagraphs(noteID: "note", in: text, nativeAnchors: [native])
    #expect(paragraphs[2].idSHA256 == native.idSHA256)
    let byHash = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: [native],
      paragraphIDSHA256: native.idSHA256, ordinal: nil, operation: "test")
    #expect(byHash.range == headingRange)
    let body = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: [native],
      paragraphIDSHA256: nil, ordinal: 2, operation: "test")
    #expect(text.substring(with: body.range) == "Plain\n")
    #expect(body.idSHA256 != native.idSHA256)
  }

  @Test func textSnapshotIdentityPreservesFormattingAndBindsTheNoteAndPlainText() throws {
    let text = NSMutableAttributedString(string: "Title\nRepeated 😀 text")
    let before = notesInlineParagraphs(noteID: "note-A", in: text.string as NSString, nativeAnchors: [])
    text.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 12), range: NSRange(location: 6, length: 8))
    text.addAttribute(.foregroundColor, value: NSColor.red, range: NSRange(location: 15, length: 2))
    let after = notesInlineParagraphs(noteID: "note-A", in: text.string as NSString, nativeAnchors: [])
    #expect(after.map(\.idSHA256) == before.map(\.idSHA256))
    let selected = try notesInlineParagraph(noteID: "note-A", in: text.string as NSString, nativeAnchors: [],
      paragraphIDSHA256: before[1].idSHA256, ordinal: nil, operation: "test")
    #expect(selected.range == before[1].range)
    #expect(notesInlineParagraphs(noteID: "note-B", in: text.string as NSString,
      nativeAnchors: [])[1].idSHA256 != before[1].idSHA256)
    let edited = "Title\nRepeated 😀 TEXT" as NSString
    #expect(notesInlineParagraphs(noteID: "note-A", in: edited,
      nativeAnchors: [])[1].idSHA256 != before[1].idSHA256)
    #expect(throws: CLIError.self) {
      try notesInlineParagraph(noteID: "note-A", in: edited, nativeAnchors: [],
        paragraphIDSHA256: before[1].idSHA256, ordinal: nil, operation: "test")
    }
  }

  @Test func literalOccurrencesStayInsideTheSelectedUnstyledParagraph() throws {
    let text = "Title\nliteral 👩🏽‍💻 e\u{301} / literal 👩🏽‍💻 e\u{301}\nliteral 👩🏽‍💻 e\u{301}" as NSString
    let paragraph = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: [],
      paragraphIDSHA256: nil, ordinal: 2, operation: "test")
    let literal = "literal 👩🏽‍💻 e\u{301}"
    let selected = try notesInlineTextSelection(in: text, text: literal,
      paragraphRange: paragraph.range, occurrence: 2, operation: "test")
    #expect(selected.occurrence == 2)
    #expect(text.substring(with: selected.range) == literal)
    #expect(NSMaxRange(selected.range) < NSMaxRange(paragraph.range))
    #expect(throws: CLIError.self) {
      try notesInlineTextSelection(in: text, text: literal,
        paragraphRange: paragraph.range, occurrence: nil, operation: "test")
    }
    #expect(throws: CLIError.self) {
      try notesInlineTextSelection(in: text, text: literal,
        paragraphRange: paragraph.range, occurrence: 3, operation: "test")
    }
  }

  @Test func invalidAndAmbiguousSelectorsFailBeforeFormatting() throws {
    let text = "Title\nBody" as NSString
    for (hash, ordinal) in [(nil as String?, nil as Int?), ("hash", 1)] {
      do {
        _ = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: [],
          paragraphIDSHA256: hash, ordinal: ordinal, operation: "test")
        Issue.record("An invalid paragraph selector was accepted.")
      } catch let error as CLIError { #expect(error.code == .validationError) }
    }
    let invalid = NotesInlineParagraph(range: NSRange(location: NSNotFound, length: 1), idSHA256: "hash")
    do {
      _ = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: [invalid],
        paragraphIDSHA256: "hash", ordinal: nil, operation: "test")
      Issue.record("An unavailable native range was accepted.")
    } catch let error as CLIError { #expect(error.code == .backendUnavailable) }
    let duplicated = [NotesInlineParagraph(range: NSRange(location: 0, length: 6), idSHA256: "hash"),
      NotesInlineParagraph(range: NSRange(location: 6, length: 4), idSHA256: "hash")]
    do {
      _ = try notesInlineParagraph(noteID: "note", in: text, nativeAnchors: duplicated,
        paragraphIDSHA256: "hash", ordinal: nil, operation: "test")
      Issue.record("An ambiguous native identity was accepted.")
    } catch let error as CLIError { #expect(error.code == .ambiguousIdentity) }
  }
}
