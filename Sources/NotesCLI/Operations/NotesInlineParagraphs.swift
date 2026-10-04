import Foundation
import Utility

struct NotesInlineParagraph {
  var range: NSRange
  var idSHA256: String
}

func notesInlineParagraphs(
  noteID: String, in string: NSString, nativeAnchors: [NotesInlineParagraph]
) -> [NotesInlineParagraph] {
  var paragraphs: [NotesInlineParagraph] = []
  var location = 0
  let snapshot = sha256Hex(string as String)
  let noteIdentity = sha256Hex(noteID)
  while location < string.length {
    let range = string.paragraphRange(for: NSRange(location: location, length: 0))
    let nativeIDs = Set(nativeAnchors.filter { $0.range == range }.map(\.idSHA256))
    let identity: String
    if nativeIDs.count == 1, let nativeID = nativeIDs.first {
      identity = nativeID
    } else {
      identity = sha256Hex(
        "notes.inline.paragraph.v1:\(noteIdentity):\(snapshot):\(range.location):\(range.length)")
    }
    paragraphs.append(NotesInlineParagraph(range: range, idSHA256: identity))
    location = NSMaxRange(range)
  }
  return paragraphs
}

func notesInlineParagraph(
  noteID: String, in string: NSString, nativeAnchors: [NotesInlineParagraph],
  paragraphIDSHA256: String?, ordinal: Int?, operation: String
) throws -> NotesInlineParagraph {
  guard (paragraphIDSHA256 != nil) != (ordinal != nil) else {
    throw CLIError(code: .validationError,
      message: "Inline formatting requires one paragraph hash or text paragraph ordinal.",
      details: ["operation": operation])
  }
  let paragraphs = notesInlineParagraphs(noteID: noteID, in: string, nativeAnchors: nativeAnchors)
  let matches: [NotesInlineParagraph]
  if let paragraphIDSHA256 {
    let native = nativeAnchors.filter { $0.idSHA256 == paragraphIDSHA256 }
    matches = native.isEmpty ? paragraphs.filter { $0.idSHA256 == paragraphIDSHA256 } : native
  } else if let ordinal, ordinal > 0, ordinal <= paragraphs.count {
    matches = [paragraphs[ordinal - 1]]
  } else {
    matches = []
  }
  guard !matches.isEmpty else {
    throw CLIError(code: .notFound, message: "Notes inline paragraph selector did not match a paragraph.",
      details: ["operation": operation, "paragraph_count": "\(paragraphs.count)"])
  }
  guard matches.count == 1, let match = matches.first else {
    throw CLIError(code: .ambiguousIdentity, message: "Notes inline paragraph identity is ambiguous.",
      details: ["operation": operation])
  }
  guard notesInlineRange(location: match.range.location, length: match.range.length,
    bodyLength: string.length) != nil else {
    throw CLIError(code: .backendUnavailable, message: "Notes inline paragraph range is unavailable.",
      details: ["operation": operation])
  }
  return match
}
