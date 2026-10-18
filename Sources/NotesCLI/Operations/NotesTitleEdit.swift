import Foundation
import Utility

func notesValidateTitleEdit(_ title: String) throws {
  guard !title.isEmpty, title.rangeOfCharacter(from: .newlines) == nil else {
    throw CLIError(code: .validationError, message: "A note title edit requires one non-empty text paragraph.")
  }
}

func notesTitleReplacementRange(
  in string: NSString, nativeRange: NSRange, expectedTitle: String, truncated: Bool = false
) throws -> NSRange {
  guard nativeRange.location == 0, nativeRange.length >= 0, nativeRange.length <= string.length else {
    throw CLIError(code: .backendUnavailable, message: "Notes native title range is unavailable.")
  }
  let selected = string.substring(with: nativeRange)
  let candidates = [expectedTitle] + ["\n", "\r", "\r\n", "\u{2028}", "\u{2029}"].map { expectedTitle + $0 }
  let titleLength = (expectedTitle as NSString).length
  let completeTruncatedTitle = truncated && nativeRange.length > 0 && nativeRange.length <= titleLength
    && notesFirstTitleParagraph(in: string)?.utf8.elementsEqual(expectedTitle.utf8) == true
  guard candidates.contains(where: { $0.utf8.elementsEqual(selected.utf8) }) || completeTruncatedTitle else {
    throw CLIError(code: .backendUnavailable, message: "Notes title does not match its native text range.")
  }
  return NSRange(location: 0, length: titleLength)
}

func notesNativeTitleText(
  in string: NSString, metadataTitle: String, nativeRange: NSRange, truncated: Bool
) -> String? {
  guard !metadataTitle.isEmpty, nativeRange.location == 0, nativeRange.length > 0,
    nativeRange.length <= string.length, let paragraph = notesFirstTitleParagraph(in: string) else { return nil }
  let titleLength = (paragraph as NSString).length
  guard (try? notesTitleReplacementRange(in: string, nativeRange: nativeRange,
    expectedTitle: paragraph, truncated: truncated)) != nil else { return nil }
  let selected = string.substring(with: NSRange(location: 0, length: min(nativeRange.length, titleLength)))
    .trimmingCharacters(in: .whitespacesAndNewlines)
  let metadataCandidates = [paragraph, selected] + (truncated ? [selected + "…"] : [])
  guard metadataCandidates.contains(where: { $0.utf8.elementsEqual(metadataTitle.utf8) }) else { return nil }
  return paragraph
}

private func notesFirstTitleParagraph(in string: NSString) -> String? {
  let terminator = string.rangeOfCharacter(from: .newlines)
  let end = terminator.location == NSNotFound ? string.length : terminator.location
  guard end > 0 else { return nil }
  return string.substring(to: end)
}

func notesReplaceTitle(
  in text: NSMutableAttributedString, nativeRange: NSRange, expectedTitle: String, title: String
) throws {
  try notesValidateTitleEdit(title)
  let range = try notesTitleReplacementRange(in: text.string as NSString,
    nativeRange: nativeRange, expectedTitle: expectedTitle)
  text.replaceCharacters(in: range, with: title)
}
