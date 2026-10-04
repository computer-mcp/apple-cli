import Foundation
import NotesCLI
import Testing
import Utility

@Suite struct NativeNotesBodyEvidenceTests {
  private func note(_ title: String) -> NotesNoteDetail {
    NotesNoteDetail(id: "note", title: title, folderName: "Fixture", accountName: "Fixture", body: "Body")
  }

  private func structure(_ title: String) -> NotesBodyStructureRecord {
    let start = (title + "\n" as NSString).length
    let fullText = title + "\nBody"
    let formats = [
      NotesBodyInlineFormatRunRecord(ordinal: 1, format: "bold", textByteCount: (title + "\n").utf8.count,
        textSHA256: nativeFixtureDigest(title + "\n"), utf16Location: 0, utf16Length: start),
      NotesBodyInlineFormatRunRecord(ordinal: 2, paragraphIDSHA256: "body-id", format: "font",
        fontSHA256: "font", textByteCount: 4, textSHA256: nativeFixtureDigest("Body"),
        utf16Location: start, utf16Length: 4),
      NotesBodyInlineFormatRunRecord(ordinal: 3, paragraphIDSHA256: "body-id", format: "strikethrough",
        textByteCount: 4, textSHA256: nativeFixtureDigest("Body"), utf16Location: start, utf16Length: 4),
    ]
    let colors = [NotesBodyInlineColorRunRecord(ordinal: 1, paragraphIDSHA256: "body-id",
      role: "foreground", colorSHA256: "color", textByteCount: 4, textSHA256: nativeFixtureDigest("Body"),
      utf16Location: start, utf16Length: 4)]
    return NotesBodyStructureRecord(noteID: "note", isPasswordProtected: false,
      richTextLength: (fullText as NSString).length, richTextSHA256: nativeFixtureDigest(fullText),
      inlineFormatRuns: formats, colorRuns: colors)
  }

  @Test func changedTitleLengthAndTitleRunFragmentationPreserveBodyEvidence() throws {
    let before = try NativeNotesBodyEvidence.capture(structure("Title"), note: note("Title"))
    let title = "Renamed 👩🏽‍💻 e\u{301}"
    var after = structure(title)
    let start = (title as NSString).length
    after.inlineFormatRuns?[0].utf16Length = start
    after.inlineFormatRuns?[0].textByteCount = title.utf8.count
    after.inlineFormatRuns?[0].textSHA256 = nativeFixtureDigest(title)
    after.inlineFormatRuns?.insert(NotesBodyInlineFormatRunRecord(ordinal: 8, format: "bold",
      textByteCount: 1, textSHA256: nativeFixtureDigest("\n"), utf16Location: start, utf16Length: 1), at: 1)
    after.inlineFormatRuns?.reverse()
    #expect(try NativeNotesBodyEvidence.capture(after, note: note(title)) == before)
  }

  @Test(arguments: ["font", "format", "color", "identity"])
  func bodyAttributeChangesRemainVisible(attribute: String) throws {
    var changed = structure("Title")
    switch attribute {
    case "font": changed.inlineFormatRuns?[1].fontSHA256 = "other-font"
    case "format": changed.inlineFormatRuns?[2].format = "underline"
    case "color": changed.colorRuns?[0].colorSHA256 = "other-color"
    default: changed.inlineFormatRuns?[1].paragraphIDSHA256 = "other-body-id"
    }
    #expect(try NativeNotesBodyEvidence.capture(changed, note: note("Title"))
      != NativeNotesBodyEvidence.capture(structure("Title"), note: note("Title")))
  }

  @Test(arguments: ["unknown", "snapshot", "missing_range", "overflow", "cross_title", "text", "font"])
  func unavailableOrUnboundBodyEvidenceCannotCompareAsPreserved(reason: String) {
    var changed = structure("Title")
    switch reason {
    case "unknown": changed.inlineFormatRuns = nil
    case "snapshot": changed.richTextSHA256 = nil
    case "missing_range": changed.inlineFormatRuns?[1].utf16Location = nil
    case "overflow": changed.inlineFormatRuns?[1].utf16Length = Int.max
    case "cross_title": changed.inlineFormatRuns?[1].utf16Location = 5
    case "text": changed.inlineFormatRuns?[1].textSHA256 = "unbound-text"
    default: changed.inlineFormatRuns?[1].fontSHA256 = nil
    }
    #expect(throws: CLIError.self) {
      try NativeNotesBodyEvidence.capture(changed, note: note("Title"))
    }
  }
}
