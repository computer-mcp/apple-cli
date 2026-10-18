import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite struct NotesTitleEditTests {
  @Test(arguments: ["", "\nBody", "Body\r\n", "\n\n👩🏽‍💻 e\u{301}\n"])
  func titleReplacementPreservesTheDelimiterBodyAndEveryBodyAttribute(body: String) throws {
    let old = "Title 👩🏽‍💻 e\u{301}"
    let new = "Renamed 😀"
    let text = NSMutableAttributedString(string: old + "\n" + body)
    let titleLength = (old as NSString).length
    let tail = NSRange(location: titleLength, length: text.length - titleLength)
    text.addAttributes([.init("native-paragraph-id"): "body-id", .init("bold"): true,
      .init("strikethrough"): true, .init("link"): "attachment-id"], range: tail)
    let preserved = NSAttributedString(attributedString: text.attributedSubstring(from: tail))
    try notesReplaceTitle(in: text, nativeRange: NSRange(location: 0, length: titleLength + 1),
      expectedTitle: old, title: new)
    #expect(text.string == new + "\n" + body)
    let after = text.attributedSubstring(from: NSRange(location: (new as NSString).length,
      length: text.length - (new as NSString).length))
    #expect(after.isEqual(to: preserved))
  }

  @Test(arguments: ["", "\n", "\r", "\r\n", "\u{2028}", "\u{2029}"])
  func nativeTitleRangeMayIncludeOneTerminatorButReplacementExcludesIt(terminator: String) throws {
    let text = NSMutableAttributedString(string: "Title" + terminator + "Body")
    let native = NSRange(location: 0, length: ("Title" + terminator as NSString).length)
    #expect(try notesTitleReplacementRange(in: text.string as NSString,
      nativeRange: native, expectedTitle: "Title") == NSRange(location: 0, length: 5))
  }

  @Test func titleOnlyNoteKeepsItsNativeStyle() throws {
    let text = NSMutableAttributedString(string: "Title", attributes: [.init("TTStyle"): "style-id"])
    try notesReplaceTitle(in: text, nativeRange: NSRange(location: 0, length: 5),
      expectedTitle: "Title", title: "😀 Title")
    #expect(text.string == "😀 Title")
    #expect(text.attribute(.init("TTStyle"), at: 0, effectiveRange: nil) as? String == "style-id")
  }

  @Test func truncatedNativeSnippetDoesNotShortenTheTitleEdit() throws {
    let title = String(repeating: "X", count: 54) + " / combined 😀"
    let string = title + "\n  Body\n\n"
    let native = NSRange(location: 0, length: 65)
    let metadata = (string as NSString).substring(with: native) + "…"
    #expect(notesNativeTitleText(in: string as NSString, metadataTitle: metadata,
      nativeRange: native, truncated: true) == title)
    let complete = try notesTitleReplacementRange(in: string as NSString,
      nativeRange: native, expectedTitle: title, truncated: true)
    #expect(complete == NSRange(location: 0, length: (title as NSString).length))
    let text = NSMutableAttributedString(string: string)
    try notesReplaceTitle(in: text, nativeRange: complete, expectedTitle: title, title: "New 😀")
    #expect(text.string == "New 😀\n  Body\n\n")
  }

  @Test func truncatedNativeSnippetRequiresMatchingMetadataAndFirstParagraph() {
    let string = "Long title 😀\nBody"
    let native = NSRange(location: 0, length: 4)
    #expect(notesNativeTitleText(in: string as NSString, metadataTitle: "Long…",
      nativeRange: native, truncated: false) == nil)
    #expect(notesNativeTitleText(in: string as NSString, metadataTitle: "Other…",
      nativeRange: native, truncated: true) == nil)
    for invalid in [NSRange(location: 1, length: 4), NSRange(location: 0, length: 0),
      NSRange(location: 0, length: Int.max), NSRange(location: 0, length: (string as NSString).length)] {
      #expect(notesNativeTitleText(in: string as NSString, metadataTitle: "Long…",
        nativeRange: invalid, truncated: true) == nil)
      #expect(throws: CLIError.self) {
        try notesTitleReplacementRange(in: string as NSString, nativeRange: invalid,
          expectedTitle: "Long title 😀", truncated: true)
      }
    }
  }

  @Test func mismatchedNativeRangesFailWithoutChangingText() {
    let original = "Title\n\nBody"
    for range in [NSRange(location: NSNotFound, length: 5), NSRange(location: 1, length: 4),
      NSRange(location: 0, length: Int.max), NSRange(location: 0, length: 7), NSRange(location: 0, length: 4)] {
      let text = NSMutableAttributedString(string: original)
      #expect(throws: CLIError.self) {
        try notesReplaceTitle(in: text, nativeRange: range, expectedTitle: "Title", title: "New")
      }
      #expect(text.string == original)
    }
  }

  @Test(arguments: ["", "New\nBody", "New\rBody", "New\u{2028}Body", "New\u{2029}Body"])
  func titleEditsRejectAdditionalParagraphsBeforeMutation(title: String) {
    let text = NSMutableAttributedString(string: "Title\nBody")
    #expect(throws: CLIError.self) {
      try notesReplaceTitle(in: text, nativeRange: NSRange(location: 0, length: 5),
        expectedTitle: "Title", title: title)
    }
    #expect(text.string == "Title\nBody")
  }
}
