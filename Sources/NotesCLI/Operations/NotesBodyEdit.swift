import Foundation
import Utility

func notesBodyReplacementRange(
  in text: NSString, nativeTitleRange: NSRange, expectedTitle: String
) throws -> NSRange {
  let title = try notesTitleReplacementRange(in: text, nativeRange: nativeTitleRange,
    expectedTitle: expectedTitle)
  if title.length == text.length { return NSRange(location: title.length, length: 0) }
  let suffix = text.substring(from: title.length)
  guard let terminator = ["\r\n", "\n", "\r", "\u{2028}", "\u{2029}"].first(where: suffix.hasPrefix) else {
    throw CLIError(code: .backendUnavailable, message: "Notes native title terminator is unavailable.")
  }
  let start = title.length + (terminator as NSString).length
  return NSRange(location: start, length: text.length - start)
}

func notesReplaceBody(
  in text: NSMutableAttributedString, nativeTitleRange: NSRange, expectedTitle: String, body: String
) throws {
  var range = try notesBodyReplacementRange(in: text.string as NSString,
    nativeTitleRange: nativeTitleRange, expectedTitle: expectedTitle)
  if range.location == (expectedTitle as NSString).length, !body.isEmpty {
    let attributes = text.length > 0 ? text.attributes(at: text.length - 1, effectiveRange: nil) : [:]
    text.append(NSAttributedString(string: "\n", attributes: attributes))
    range.location += 1
  }
  text.replaceCharacters(in: range, with: body)
  if !body.isEmpty {
    text.setAttributes([:], range: NSRange(location: range.location, length: (body as NSString).length))
  }
}
