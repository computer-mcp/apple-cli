import Foundation

struct NotesStyledParagraph<Style> {
  var id: String
  var style: Style
  var range: NSRange
}

func notesStyledParagraphs<Style>(
  in text: NSAttributedString,
  resolve: (Any) -> (id: String, style: Style)?
) -> [NotesStyledParagraph<Style>] {
  var paragraphs: [NotesStyledParagraph<Style>] = []
  var seenIDs: [Int: Set<String>] = [:]
  guard text.length > 0 else { return paragraphs }
  let string = text.string as NSString
  text.enumerateAttributes(in: NSRange(location: 0, length: text.length), options: []) { attributes, range, _ in
    var location = range.location
    while location < NSMaxRange(range) {
      let paragraphRange = string.paragraphRange(for: NSRange(location: location, length: 0))
      for value in attributes.values {
        guard let resolved = resolve(value),
          seenIDs[paragraphRange.location, default: []].insert(resolved.id).inserted else { continue }
        paragraphs.append(NotesStyledParagraph(id: resolved.id, style: resolved.style, range: paragraphRange))
      }
      location = NSMaxRange(paragraphRange)
    }
  }
  return paragraphs
}
