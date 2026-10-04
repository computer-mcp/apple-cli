import Foundation

struct NotesParagraphStyleEvidence: Hashable {
  var kind: String
  var isHeader: Bool?
  var isList: Bool?
  var isChecklist: Bool?
  var checked: Bool?
  var isBlockQuote: Bool?
}

struct NotesParagraphStructure {
  var styleRunCount = 0
  var headingCount: Int? = 0
  var listItemCount: Int? = 0
  var checklistItemCount: Int? = 0
  var checklistDoneCount: Int? = 0
  var checklistOpenCount: Int? = 0
  var blockQuoteCount: Int? = 0
  var styleCounts: [String: Int]? = [:]
}

func notesParagraphStructure(
  in text: NSAttributedString, resolve: (Any) -> NotesParagraphStyleEvidence?
) -> NotesParagraphStructure {
  var result = NotesParagraphStructure()
  var paragraphs: [Int: Set<NotesParagraphStyleEvidence>] = [:]
  let string = text.string as NSString
  text.enumerateAttributes(in: NSRange(location: 0, length: text.length), options: []) { attributes, range, _ in
    let styles = Set(attributes.values.compactMap(resolve))
    result.styleRunCount += styles.isEmpty ? 0 : 1
    guard !styles.isEmpty else { return }
    var location = range.location
    while location < NSMaxRange(range) {
      let paragraph = string.paragraphRange(for: NSRange(location: location, length: 0))
      paragraphs[paragraph.location, default: []].formUnion(styles)
      location = min(NSMaxRange(paragraph), NSMaxRange(range))
    }
  }
  var styleCounts: [String: Int] = [:]
  var stylesAvailable = true
  for styles in paragraphs.values {
    let kinds = Set(styles.map(\.kind))
    if kinds.count == 1, let kind = kinds.first { styleCounts[kind, default: 0] += 1 }
    else { stylesAvailable = false }
    add(singleFlag(styles.map(\.isHeader)), to: &result.headingCount)
    add(singleFlag(styles.map(\.isList)), to: &result.listItemCount)
    let checklist = singleFlag(styles.map(\.isChecklist))
    add(checklist, to: &result.checklistItemCount)
    add(singleFlag(styles.map(\.isBlockQuote)), to: &result.blockQuoteCount)
    if checklist == true {
      let checked = singleFlag(styles.map(\.checked))
      add(checked, to: &result.checklistDoneCount)
      add(checked.map { !$0 }, to: &result.checklistOpenCount)
    } else if checklist == nil {
      result.checklistDoneCount = nil
      result.checklistOpenCount = nil
    }
  }
  result.styleCounts = stylesAvailable ? styleCounts : nil
  return result
}

private func singleFlag(_ flags: [Bool?]) -> Bool? {
  let values = Set(flags)
  guard values.count == 1 else { return nil }
  return values.first ?? nil
}

private func add(_ flag: Bool?, to count: inout Int?) {
  guard let flag else { count = nil; return }
  if flag { count = count.map { $0 + 1 } }
}
