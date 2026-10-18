import AppKit
import Foundation
import NotesShared
import Testing
import Utility
@testable import NotesCLI

@Suite struct NotesStyledParagraphTests {
  @Test func formattingRunsDoNotChangeParagraphOrdinalsOrUTF16Ranges() throws {
    let text = NSMutableAttributedString(string: "Title\nliteral 👩🏽‍💻 e\u{301}\nSecond.")
    let string = text.string as NSString
    let ranges = [string.paragraphRange(for: string.range(of: "Title")),
      string.paragraphRange(for: string.range(of: "literal")),
      string.paragraphRange(for: string.range(of: "Second."))]
    for (index, range) in ranges.enumerated() {
      text.addAttribute(.init("paragraph"), value: "paragraph-\(index + 1)", range: range)
    }
    text.addAttribute(.init("font"), value: "bold", range: string.range(of: "literal"))
    text.addAttribute(.init("color"), value: "red", range: string.range(of: "👩🏽‍💻"))
    let paragraphs = notesStyledParagraphs(in: text) { value -> (id: String, style: String)? in
      guard let id = value as? String, id.hasPrefix("paragraph-") else { return nil }
      return (id, id)
    }
    #expect(paragraphs.map(\.id) == ["paragraph-1", "paragraph-2", "paragraph-3"])
    #expect(paragraphs.map(\.range) == ranges)
    let body = try #require(paragraphs.dropFirst().first)
    #expect(string.substring(with: body.range) == "literal 👩🏽‍💻 e\u{301}\n")
  }

  @Test func missingNativeIdentityDoesNotInventParagraphs() {
    let text = NSAttributedString(string: "Title\nBody")
    let paragraphs = notesStyledParagraphs(in: text) { _ -> (id: String, style: String)? in nil }
    #expect(paragraphs.isEmpty)
    let empty = notesStyledParagraphs(in: NSAttributedString(string: "")) {
      _ -> (id: String, style: String)? in Issue.record("An empty string was inspected."); return ("id", "body")
    }
    #expect(empty.isEmpty)
  }

  @Test func aSharedStyleSpanStillHasSeparatePhysicalParagraphs() {
    let text = NSMutableAttributedString(string: "First\r\nSecond", attributes: [.init("paragraph"): "shared-id"])
    text.addAttribute(.font, value: NSFont.systemFont(ofSize: 12), range: .init(location: 8, length: 2))
    let paragraphs = notesStyledParagraphs(in: text) { value -> (id: String, style: String)? in
      guard value as? String == "shared-id" else { return nil }
      return ("shared-id", "body")
    }
    #expect(paragraphs.map(\.id) == ["shared-id", "shared-id"])
    #expect(paragraphs.map(\.range) == [.init(location: 0, length: 7), .init(location: 7, length: 6)])
  }

  @Test(arguments: ["checklist", "list"])
  func nativeListSelectorsUseTheRequestedItemAndWholeParagraph(family: String) throws {
    let text = NSTextStorage(string: "First 😀\nSecond e\u{301}\n")
    let string = text.string as NSString
    let ranges = [string.paragraphRange(for: string.range(of: "First")),
      string.paragraphRange(for: string.range(of: "Second"))]
    let writer = NotesWriter()
    let appended = family == "checklist" ? try writer.checklistAttributedString(text: "Item 😀", checked: false)
      : try writer.listAttributedString(text: "Item 😀", style: .bulleted, operation: "test.append")
    #expect(appended.string == "Item 😀")
    let styles = try ranges.map { range in
      let style = try family == "checklist" ? writer.checklistParagraphStyle(checked: false)
        : #require(ICTTMutableParagraphStyle.paragraphStyleNamed(NotesBodyListStyle.bulleted.paragraphStyleValue)
          as? ICTTMutableParagraphStyle)
      style.uuid = UUID()
      try #require(family == "checklist" ? style.isChecklist : style.isList && !style.isChecklist)
      text.addAttributes([.init("paragraph"): style, .init("paragraph-alias"): style], range: range)
      return style
    }
    text.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 12), range: string.range(of: "Second"))
    let hash = nativeFixtureDigest(try #require(styles[1].uuid).uuidString)
    func select(id: String?, ordinal: Int?) throws -> NotesChecklistParagraphTarget {
      family == "checklist"
        ? try writer.checklistParagraphTarget(noteID: "fixture", paragraphIDSHA256: id,
            ordinal: ordinal, textStorage: text, operation: "test.select")
        : try writer.listParagraphTarget(noteID: "fixture", paragraphIDSHA256: id,
            ordinal: ordinal, textStorage: text, operation: "test.select")
    }
    func targets() throws -> [NotesChecklistParagraphTarget] {
      family == "checklist"
        ? try writer.checklistParagraphTargets(noteID: "fixture", textStorage: text, operation: "test.select")
        : try writer.listParagraphTargets(noteID: "fixture", textStorage: text, operation: "test.select")
    }
    func reorderIndex(hash: String) throws -> Int {
      family == "checklist"
        ? try writer.checklistParagraphTargetIndex(draft: .init(noteID: "fixture", paragraphIDSHA256: hash,
            targetOrdinal: 1), targets: targets(), operation: "test.reorder")
        : try writer.listParagraphTargetIndex(draft: .init(noteID: "fixture", paragraphIDSHA256: hash,
            targetOrdinal: 1), targets: targets(), operation: "test.reorder")
    }
    for (id, ordinal) in [(hash as String?, nil as Int?), (nil, 2)] {
      let selected = try select(id: id, ordinal: ordinal)
      #expect(selected.paragraphIDSHA256 == hash)
      #expect(selected.range == ranges[1])
    }
    #expect(try targets().map(\.range) == ranges)
    #expect(try writer.paragraphStyleTargets(noteID: "fixture", textStorage: text,
      operation: "test.select").map(\.range) == ranges)
    #expect(try reorderIndex(hash: hash) == 1)
    do {
      _ = try select(id: "absent", ordinal: nil)
      Issue.record("An absent native paragraph hash selected an item.")
    } catch let error as CLIError { #expect(error.code == .notFound) }
    styles[1].uuid = nil
    let anonymous = try select(id: nil, ordinal: 2)
    #expect(anonymous.range == ranges[1] && anonymous.paragraphIDSHA256 == nil)
    styles[1].uuid = styles[0].uuid
    let sharedHash = nativeFixtureDigest(try #require(styles[0].uuid).uuidString)
    for operation in [{ _ = try select(id: sharedHash, ordinal: nil) }, { _ = try reorderIndex(hash: sharedHash) }] {
      do { try operation(); Issue.record("A duplicated paragraph identity was selected.") }
      catch let error as CLIError { #expect(error.code == .ambiguousIdentity) }
    }
  }

  @Test(arguments: [false, true])
  func checklistCreationAndConversionUseChecklistStyles(checked: Bool) throws {
    let writer = NotesWriter()
    let created = try writer.checklistParagraphStyle(checked: checked)
    #expect(created.isChecklist && created.isList && !created.isHeader)
    #expect(created.todo?.done == checked)
    #expect(created.uuid != nil)
    let body = try #require(ICTTMutableParagraphStyle.paragraphStyleNamed(3) as? ICTTMutableParagraphStyle)
    body.uuid = UUID()
    body.indent = 1
    let converted = try writer.checklistParagraphStyle(from: body, checked: checked, operation: "test.convert")
    #expect(converted.isChecklist && converted.isList && !converted.isHeader)
    #expect(converted.todo?.done == checked)
    #expect(converted.uuid == body.uuid && converted.indent == body.indent)
    #expect(!body.isChecklist && body.todo == nil)
  }
}
