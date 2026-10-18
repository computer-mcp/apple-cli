import AppKit
import Foundation
import Testing
@testable import NotesCLI

@Suite struct NotesParagraphStructureTests {
  @Test func inlineFormattingAndAttributeAliasesDoNotCreateHeadings() {
    let style = ParagraphStructureFixtureStyle()
    style.isHeader = true
    let text = NSMutableAttributedString(string: "Title 👩🏽‍💻 e\u{301}\nBody")
    let range = (text.string as NSString).paragraphRange(for: .init(location: 0, length: 0))
    text.addAttributes([.init("paragraph-a"): style, .init("paragraph-b"): style], range: range)
    text.addAttribute(.underlineStyle, value: 1, range: .init(location: 1, length: 3))
    let record = NotesReader().bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: text.string, attributedString: text)
    #expect(record.headingCount == 1)
    #expect(record.styleCounts == [.init(style: "heading", count: 1)])
    #expect(record.paragraphStyleRunCount == 3)
  }

  @Test func sharedChecklistStyleCountsEachPhysicalParagraphOnce() {
    let style = ParagraphStructureFixtureStyle()
    style.isList = true
    style.isChecklist = true
    style.todo = ParagraphStructureFixtureTodo(done: true)
    let text = NSMutableAttributedString(string: "One\r\nTwo\n", attributes: [.init("paragraph"): style])
    text.addAttribute(.strikethroughStyle, value: 1, range: .init(location: 1, length: 1))
    let record = NotesReader().bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: text.string, attributedString: text)
    #expect(record.listItemCount == 2)
    #expect(record.checklistItemCount == 2)
    #expect(record.checklistDoneCount == 2)
    #expect(record.checklistOpenCount == 0)
  }

  @Test func missingChecklistCompletionDoesNotMeanOpen() {
    let style = ParagraphStructureFixtureStyle()
    style.isChecklist = true
    let text = NSAttributedString(string: "Item", attributes: [.init("paragraph"): style])
    let record = NotesReader().bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: text.string, attributedString: text)
    #expect(record.checklistItemCount == 1)
    #expect(record.checklistDoneCount == nil)
    #expect(record.checklistOpenCount == nil)
  }

  @Test(arguments: ["\n", "\r", "\r\n", "\u{2029}"])
  func oneStyleSpanAcrossParagraphsKeepsSemanticAndRunCountsDistinct(separator: String) {
    let style = ParagraphStructureFixtureStyle()
    style.isHeader = true
    let text = NSAttributedString(string: "👩🏽‍💻" + separator + "e\u{301}", attributes: [.init("paragraph"): style])
    let record = NotesReader().bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: text.string, attributedString: text)
    #expect(record.headingCount == 2)
    #expect(record.paragraphStyleRunCount == 1)
    #expect(record.styleCounts == [.init(style: "heading", count: 2)])
  }

  @Test func conflictingStylesWithinOneParagraphDoNotInventCounts() {
    let heading = ParagraphStructureFixtureStyle()
    heading.isHeader = true
    let ordinary = ParagraphStructureFixtureStyle()
    let text = NSMutableAttributedString(string: "One paragraph", attributes: [.init("paragraph"): heading])
    text.addAttribute(.init("paragraph"), value: ordinary, range: .init(location: 4, length: 9))
    let record = NotesReader().bodyAttributeStructureRecord(noteID: "fixture", isPasswordProtected: false,
      plainText: text.string, attributedString: text)
    #expect(record.headingCount == nil)
    #expect(record.styleCounts == nil)
    #expect(record.checklistItemCount == 0)
    #expect(record.blockQuoteCount == 0)
  }

  @Test func unavailableFlagsOnlyInvalidateTheirOwnCounters() {
    let text = NSAttributedString(string: "Body", attributes: [.init("style"): "fixture"])
    let result = notesParagraphStructure(in: text) { value in
      guard value as? String == "fixture" else { return nil }
      return NotesParagraphStyleEvidence(kind: "body", isHeader: nil, isList: false,
        isChecklist: false, checked: nil, isBlockQuote: true)
    }
    #expect(result.headingCount == nil)
    #expect(result.listItemCount == 0)
    #expect(result.checklistItemCount == 0)
    #expect(result.checklistDoneCount == 0)
    #expect(result.checklistOpenCount == 0)
    #expect(result.blockQuoteCount == 1)
  }
}

private final class ParagraphStructureFixtureStyle: NSObject {
  @objc dynamic var isHeader = false
  @objc dynamic var isList = false
  @objc dynamic var isChecklist = false
  @objc dynamic var isBlockQuote = false
  @objc dynamic var todo: NSObject?
}

private final class ParagraphStructureFixtureTodo: NSObject {
  @objc dynamic var done: Bool
  init(done: Bool) { self.done = done }
}
