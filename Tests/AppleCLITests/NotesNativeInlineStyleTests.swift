import Foundation
import Testing
@testable import NotesCLI

@Suite struct NotesNativeInlineStyleTests {
  @Test func fontChangesPreserveNativeParagraphTimestampAndOtherFormats() throws {
    let style = NSObject()
    let original: [NSAttributedString.Key: Any] = [.init("TTStyle"): style,
      .init("TTTimestamp"): 42, .init("TTColor"): "color", .init("TTStrikethrough"): true,
      .init("TTUnderline"): true, .init("TTHints"): 0]
    let font = NSObject()
    let converted: [NSAttributedString.Key: Any] = [.init("TTStyle"): NSObject(),
      .init("TTTimestamp"): 99, .init("TTHints"): 1, .init("ICTTFont"): font]
    let merged = notesMergeInlineModelAttributes(original: original, converted: converted,
      ownedKeys: ["TTHints", "ICTTFont"])
    #expect(merged[.init("TTStyle")] as? NSObject === style)
    #expect(merged[.init("TTTimestamp")] as? Int == 42)
    #expect(merged[.init("TTColor")] as? String == "color")
    #expect(merged[.init("TTStrikethrough")] as? Bool == true)
    #expect(merged[.init("TTUnderline")] as? Bool == true)
    #expect(merged[.init("TTHints")] as? Int == 1)
    #expect(merged[.init("ICTTFont")] as? NSObject === font)
  }

  @Test func RemovingAFormatOnlyRemovesItsOwnedModelAttribute() {
    let original: [NSAttributedString.Key: Any] = [.init("TTStrikethrough"): true,
      .init("TTHints"): 3, .init("ICTTFont"): "font", .init("TTEmphasis"): 2]
    let merged = notesMergeInlineModelAttributes(original: original, converted: [:],
      ownedKeys: ["TTStrikethrough"])
    #expect(merged[.init("TTStrikethrough")] == nil)
    #expect(merged[.init("TTHints")] as? Int == 3)
    #expect(merged[.init("ICTTFont")] as? String == "font")
    #expect(merged[.init("TTEmphasis")] as? Int == 2)
  }

  @Test func unavailableInlineConversionPreservesIndependentStructureEvidence() {
    let reader = NotesReader()
    var record = reader.bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: "Body", attributedString: NSAttributedString(string: "Body"))
    let before = record
    var summary = BodyAttributeSummary()
    summary.inlineReadbackAvailable = false
    summary.boldRunCount = 1
    reader.applyInlineFormatReadback(summary, to: &record)
    #expect(record.boldRunCount == nil)
    #expect(record.strikethroughRunCount == nil)
    #expect(record.inlineFormatRuns == nil)
    #expect(record.colorRuns == nil)
    #expect(record.paragraphStyleRunCount == before.paragraphStyleRunCount)
    #expect(record.paragraphCount == before.paragraphCount)
    #expect(record.plainTextSHA256 == before.plainTextSHA256)
    #expect(record.richTextSHA256 == before.richTextSHA256)
  }
}
