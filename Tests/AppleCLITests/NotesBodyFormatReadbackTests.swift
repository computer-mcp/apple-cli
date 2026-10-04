import AppKit
import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite
struct NotesBodyFormatReadbackTests {
  @Test func missingAttributedBodyPreservesKnownPlainTextWithoutInventingStructure() throws {
    let record = NotesReader().bodyAttributeStructureRecord(
      noteID: "fixture", isPasswordProtected: false, plainText: "中文😀\n", attributedString: nil)
    let object = try #require(JSONSerialization.jsonObject(
      with: Data(CLIJSON.encodeString(record).utf8)) as? [String: Any])
    #expect(record.plainTextByteCount == "中文😀\n".utf8.count)
    #expect(record.paragraphCount != nil)
    for key in [
      "richTextLength", "paragraphStyleRunCount", "headingCount", "listItemCount",
      "checklistItemCount", "checklistDoneCount", "checklistOpenCount", "blockQuoteCount",
      "tableCount", "collapsibleSectionCount", "collapsedSectionCount", "inlineAttachmentCount",
      "linkCount", "attachmentCount", "mathAttachmentCount", "hasChecklist", "hasChecklistInProgress",
      "isMathNote", "styleCounts", "attachmentKindCounts", "mentionUserIDSHA256s", "paragraphAnchors",
    ] {
      #expect(object[key] == nil)
    }
  }

  @Test func knownEmptyBodyKeepsObservedZerosAndUnknownNativeMetadata() {
    let record = NotesReader().bodyAttributeStructureRecord(
      noteID: "fixture", isPasswordProtected: false, plainText: "",
      attributedString: NSAttributedString(string: ""))
    #expect(record.paragraphStyleRunCount == 0)
    #expect(record.headingCount == 0)
    #expect(record.checklistItemCount == 0)
    #expect(record.checklistDoneCount == 0)
    #expect(record.checklistOpenCount == 0)
    #expect(record.tableCount == 0)
    #expect(record.inlineAttachmentCount == 0)
    #expect(record.mathAttachmentCount == 0)
    #expect(record.styleCounts == [])
    #expect(record.attachmentKindCounts == [])
    #expect(record.inlineFormatRunCount == 0)
    #expect(record.boldRunCount == 0)
    #expect(record.strikethroughRunCount == 0)
    #expect(record.highlightRunCount == 0)
    #expect(record.inlineFormatRuns == [])
    #expect(record.inlineFormatCounts == [])
    #expect(record.colorRuns == [])
    #expect(record.colorHashCounts == [])
    #expect(record.hasChecklist == nil)
    #expect(record.hasChecklistInProgress == nil)
    #expect(record.isMathNote == nil)
    #expect(record.attachmentCount == nil)
    #expect(record.mentionUserIDSHA256s == nil)
  }

  @Test func protectedBodyDoesNotExposeSuppliedTextOrAttributes() {
    let record = NotesReader().bodyAttributeStructureRecord(
      noteID: "fixture", isPasswordProtected: true, plainText: "Secret",
      attributedString: NSAttributedString(string: "Secret", attributes: [.strikethroughStyle: 1]))
    #expect(record.isPasswordProtected)
    #expect(record.plainTextSHA256 == nil)
    #expect(record.plainTextByteCount == nil)
    #expect(record.richTextLength == nil)
    #expect(record.paragraphCount == nil)
    #expect(record.strikethroughRunCount == nil)
    #expect(record.inlineFormatRuns == nil)
    #expect(record.styleCounts == nil)
  }

  @Test func unavailableInlineFormattingDoesNotBecomeEmptyFormatting() throws {
    var record = NotesBodyStructureRecord(
      noteID: "fixture", isPasswordProtected: false, plainTextByteCount: 0,
      inlineFormatRunCount: 3, boldRunCount: 3, inlineFormatRuns: [])
    NotesReader().applyInlineFormatReadback(nil, to: &record)
    let object = try #require(JSONSerialization.jsonObject(
      with: Data(CLIJSON.encodeString(record).utf8)) as? [String: Any])

    for key in [
      "inlineFormatRunCount", "boldRunCount", "italicRunCount", "underlineRunCount",
      "strikethroughRunCount", "fontRunCount", "foregroundColorRunCount", "highlightRunCount",
      "inlineFormatCounts", "colorHashCounts", "inlineFormatRuns", "colorRuns",
    ] {
      #expect(object[key] == nil)
    }
    #expect(object["plainTextByteCount"] as? Int == 0)
  }

  @Test func standardStrikethroughRemainsKnownForUnicodeAndNewlineOnlyRuns() {
    let reader = NotesReader()
    for text in ["中文😀", "\n"] {
      let attributed = NSAttributedString(
        string: text, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
      var record = NotesBodyStructureRecord(noteID: "fixture", isPasswordProtected: false)
      reader.applyInlineFormatReadback(reader.bodyAttributeSummary(attributed), to: &record)

      #expect(record.strikethroughRunCount == 1)
      #expect(record.inlineFormatRuns?.first?.textByteCount == text.utf8.count)
      #expect(record.inlineFormatRuns?.first?.format == "strikethrough")
    }
  }

  @Test func mixedSelectionRequiresChangingEitherRequestedFormatState() throws {
    let writer = NotesWriter()
    let text = NSMutableAttributedString(string: "前😀A\nB后")
    let selection = (text.string as NSString).range(of: "A\nB")
    text.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue,
      range: NSRange(location: selection.location, length: 1))

    #expect(try !writer.inlineRangeMatchesFormat(.strikethrough, enabled: false, in: text, range: selection))
    #expect(try !writer.inlineRangeMatchesFormat(.strikethrough, enabled: true, in: text, range: selection))

    text.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: selection)
    text.addAttribute(.foregroundColor, value: NSColor.red,
      range: NSRange(location: selection.location + 2, length: 1))
    #expect(try writer.inlineRangeMatchesFormat(.strikethrough, enabled: true, in: text, range: selection))
    #expect(try !writer.inlineRangeMatchesFormat(.strikethrough, enabled: false, in: text, range: selection))

    text.removeAttribute(.strikethroughStyle, range: selection)
    #expect(try writer.inlineRangeMatchesFormat(.strikethrough, enabled: false, in: text, range: selection))
    #expect(try !writer.inlineRangeMatchesFormat(.strikethrough, enabled: true, in: text, range: selection))
  }

  @Test func formatStateUsesOnlyTheSelectedOccurrenceAndIncludesNewlines() throws {
    let writer = NotesWriter()
    let text = NSMutableAttributedString(string: "😀A\nA\n")
    let string = text.string as NSString
    let first = string.range(of: "A\n")
    let second = string.range(of: "A\n", options: .backwards)
    text.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: first)

    #expect(try writer.inlineRangeMatchesFormat(.underline, enabled: true, in: text, range: first))
    #expect(try writer.inlineRangeMatchesFormat(.underline, enabled: false, in: text, range: second))
    let newline = NSRange(location: first.location + 1, length: 1)
    #expect(try writer.inlineRangeMatchesFormat(.underline, enabled: true, in: text, range: newline))
  }

  @Test func formatStateRejectsUnavailableSelectionRanges() throws {
    let text = NSAttributedString(string: "😀")
    for range in [NSRange(location: 0, length: 0), NSRange(location: 1, length: Int.max),
      NSRange(location: NSNotFound, length: 1), NSRange(location: 3, length: 1)] {
      do {
        _ = try NotesWriter().inlineRangeMatchesFormat(.bold, enabled: false, in: text, range: range)
        Issue.record("An unavailable selection must not be treated as a matching empty range.")
      } catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
      }
    }
  }

  @Test func verificationCoversAnEntireSelectionAcrossUnrelatedAttributeSplits() throws {
    let text = NSMutableAttributedString(string: "前😀A\nB后")
    let selection = (text.string as NSString).range(of: "A\nB", options: .literal)
    text.addAttribute(.strikethroughStyle, value: 1, range: selection)
    text.addAttribute(.font, value: NSFont.systemFont(ofSize: 12),
      range: NSRange(location: selection.location, length: 1))
    text.addAttribute(.foregroundColor, value: NSColor.red,
      range: NSRange(location: selection.location + 2, length: 1))
    let structure = structure(text)
    let evidence = try evidence(structure, range: selection, text: "A\nB")
    #expect(structure.inlineFormatRuns?.filter { $0.format == "strikethrough" }.count == 3)
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "strikethrough") == .full)
  }

  @Test func partialCoverageRequiresChangingBothEnableAndDisableRequests() throws {
    let text = NSMutableAttributedString(string: "A\nBC")
    text.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: 1))
    text.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 2, length: 2))
    let structure = structure(text)
    let evidence = try evidence(structure, range: NSRange(location: 0, length: 4), text: "A\nBC")
    let coverage = try #require(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "strikethrough"))
    #expect(coverage == .partial)
    #expect(!coverage.matches(enabled: true))
    #expect(!coverage.matches(enabled: false))
  }

  @Test func equalTextAtAnotherUTF16PositionCannotVerifyTheSelectedOccurrence() throws {
    let text = NSMutableAttributedString(string: "😀A\nA\n")
    let string = text.string as NSString
    let first = string.range(of: "A\n", options: .literal)
    let second = string.range(of: "A\n", options: [.literal, .backwards])
    text.addAttribute(.underlineStyle, value: 1, range: first)
    let structure = structure(text)
    let evidence = try evidence(structure, range: second, text: "A\n", occurrence: 2)
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "underline") == .absent)
    #expect(first.location == 2)
    #expect(second.location == 4)
  }

  @Test func fontCoverageRequiresTheRequestedFontThroughoutTheSelection() throws {
    let text = NSMutableAttributedString(string: "字😀ab")
    let font = NSFont.systemFont(ofSize: 14)
    text.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.length))
    text.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 3, length: 1))
    var structure = structure(text)
    var evidence = try evidence(structure, range: NSRange(location: 0, length: text.length), text: text.string)
    evidence.fontSHA256 = notesFontSHA256(font)
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "font") == .full)
    text.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
      range: NSRange(location: 4, length: 1))
    structure = self.structure(text)
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "font") == .partial)
  }

  @Test func colorCoverageHandlesSplitRunsAndRemovalOfMixedColors() throws {
    let text = NSMutableAttributedString(string: "abc")
    text.addAttribute(.foregroundColor, value: NSColor.red, range: NSRange(location: 0, length: 3))
    text.addAttribute(.backgroundColor, value: NSColor.yellow, range: NSRange(location: 1, length: 1))
    var structure = structure(text)
    var evidence = try evidence(structure, range: NSRange(location: 0, length: 3), text: "abc", role: "foreground")
    let colorHash: String = try #require(structure.colorRuns?.first { $0.role == "foreground" }?.colorSHA256)
    evidence.colorSHA256 = colorHash
    #expect(notesInlineColorCoverage(in: structure, evidence: evidence) == .full)
    text.addAttribute(.foregroundColor, value: NSColor.blue, range: NSRange(location: 2, length: 1))
    structure = self.structure(text)
    #expect(notesInlineColorCoverage(in: structure, evidence: evidence) == .partial)
    evidence.colorSHA256 = nil
    #expect(notesInlineColorCoverage(in: structure, evidence: evidence) == .full)
    text.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: 3))
    structure = self.structure(text)
    #expect(notesInlineColorCoverage(in: structure, evidence: evidence) == .absent)
  }

  @Test func coverageRejectsMissingGeometryAndDifferentBodySnapshots() throws {
    let text = NSAttributedString(string: "abc", attributes: [.strikethroughStyle: 1])
    var structure = structure(text)
    let evidence = try evidence(structure, range: NSRange(location: 0, length: 3), text: "abc")
    structure.inlineFormatRuns?[0].utf16Location = nil
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "strikethrough") == nil)
    structure = self.structure(text)
    structure.richTextSHA256 = "different-body"
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "strikethrough") == nil)
    structure.richTextSHA256 = nil
    #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "strikethrough") == nil)
  }

  @Test func coverageRejectsOverflowAndOutOfBodyRanges() throws {
    let text = NSAttributedString(string: "abc", attributes: [.strikethroughStyle: 1])
    let original = structure(text)
    let evidence = try evidence(original, range: NSRange(location: 0, length: 3), text: "abc")
    for (location, length) in [(1, Int.max), (-1, 1), (NSNotFound, 1), (0, 0), (3, 1)] {
      var structure = original
      structure.inlineFormatRuns?[0].utf16Location = location
      structure.inlineFormatRuns?[0].utf16Length = length
      #expect(notesInlineFormatCoverage(in: structure, evidence: evidence, format: "strikethrough") == nil)
    }
  }

  @Test func literalSelectionBindsTheRequestedOccurrenceWithinTheParagraph() throws {
    let text = "前😀ab ab后\nab" as NSString
    let scope = text.paragraphRange(for: NSRange(location: 0, length: 1))
    let selected = try notesInlineTextSelection(in: text, text: "ab", paragraphRange: scope,
      occurrence: 2, operation: "fixture")
    #expect(selected.range.location == 6)
    #expect(selected.range.length == 2)
    #expect(selected.occurrence == 2)
    do {
      _ = try notesInlineTextSelection(in: text, text: "ab", paragraphRange: scope,
        occurrence: nil, operation: "fixture")
      Issue.record("Repeated text needs an explicit occurrence.")
    } catch let error as CLIError { #expect(error.code == .ambiguousIdentity) }
    do {
      _ = try notesInlineTextSelection(in: text, text: "ab", paragraphRange: scope,
        occurrence: 3, operation: "fixture")
      Issue.record("A match in another paragraph cannot satisfy this selector.")
    } catch let error as CLIError { #expect(error.code == .notFound) }
  }

  @Test func literalSelectionDoesNotConfuseDifferentUnicodeRepresentations() throws {
    let text = "e\u{301} é" as NSString
    let range = NSRange(location: 0, length: text.length)
    let selected = try notesInlineTextSelection(in: text, text: "é", paragraphRange: range,
      occurrence: nil, operation: "fixture")
    #expect(selected.range.location == 3)
    #expect(selected.range.length == 1)
  }

  private func structure(_ text: NSAttributedString) -> NotesBodyStructureRecord {
    NotesReader().bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: text.string, attributedString: text)
  }

  private func evidence(
    _ structure: NotesBodyStructureRecord, range: NSRange, text: String,
    occurrence: Int = 1, role: String = "strikethrough"
  ) throws -> NotesBodyInlineMutationEvidence {
    let bodyHash: String = try #require(structure.richTextSHA256)
    return NotesBodyInlineMutationEvidence(textByteCount: text.utf8.count,
      textSHA256: "selection-hash", occurrence: occurrence, role: role,
      utf16Location: range.location, utf16Length: range.length,
      richTextSHA256: bodyHash)
  }
}
