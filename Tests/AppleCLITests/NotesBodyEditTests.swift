import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite struct NotesBodyEditTests {
  @Test(arguments: ["", "  New 👩🏽‍💻 e\u{301}\n\n", "\n\n", "Title"])
  func bodyReplacementPreservesHeaderAttributesAndClearsOnlyBodyFormatting(body: String) throws {
    let title = "Title 😀"
    let prefix = title + "\n"
    let text = NSMutableAttributedString(string: prefix + "Old\nBody")
    let range = NSRange(location: 0, length: (prefix as NSString).length)
    text.addAttributes([.init("TTStyle"): "title-id", .init("TTHints"): 1], range: range)
    text.addAttribute(.init("TTStrikethrough"), value: 1,
      range: NSRange(location: range.length, length: text.length - range.length))
    let header = text.attributedSubstring(from: range)
    try notesReplaceBody(in: text, nativeTitleRange: range, expectedTitle: title, body: body)
    #expect(text.string.utf8.elementsEqual((prefix + body).utf8))
    #expect(text.attributedSubstring(from: range).isEqual(to: header))
    if !body.isEmpty { #expect(text.attributes(at: range.length, effectiveRange: nil).isEmpty) }
  }

  @Test(arguments: ["\r\n", "\r", "\u{2028}", "\u{2029}"])
  func nativeTerminatorsRemainOutsideTheBodyEdit(separator: String) throws {
    let text = NSMutableAttributedString(string: "Title" + separator + "Old")
    try notesReplaceBody(in: text, nativeTitleRange: NSRange(location: 0, length: 5),
      expectedTitle: "Title", body: "New")
    #expect(text.string == "Title" + separator + "New")
  }

  @Test func insertingBodyIntoTitleOnlyNotePreservesTheNativeTitleStyle() throws {
    let text = NSMutableAttributedString(string: "Title", attributes: [.init("TTStyle"): "title-id"])
    try notesReplaceBody(in: text, nativeTitleRange: NSRange(location: 0, length: 5),
      expectedTitle: "Title", body: "Body")
    #expect(text.string == "Title\nBody")
    #expect(text.attribute(.init("TTStyle"), at: 5, effectiveRange: nil) as? String == "title-id")
    #expect(text.attributes(at: 6, effectiveRange: nil).isEmpty)
  }

  @Test func mismatchedTitleOrMissingTerminatorFailsBeforeChangingText() {
    for value in ["Wrong\nBody", "TitleBody"] {
      let text = NSMutableAttributedString(string: value)
      #expect(throws: CLIError.self) {
        try notesReplaceBody(in: text, nativeTitleRange: NSRange(location: 0, length: 5),
          expectedTitle: "Title", body: "New")
      }
      #expect(text.string == value)
    }
  }
}
