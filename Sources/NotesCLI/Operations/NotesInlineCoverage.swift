import Foundation
import Utility

public struct NotesBodyInlineSelectionReadback: Equatable, Sendable {
  public var paragraphIDSHA256: String
  public var utf16Location: Int
  public var utf16Length: Int
  public var textByteCount: Int
  public var textSHA256: String
  public var richTextSHA256: String
  public var occurrence: Int
  public var paragraphUTF16Location: Int?
  public var paragraphUTF16Length: Int?

  public init(paragraphIDSHA256: String, utf16Location: Int, utf16Length: Int,
    textByteCount: Int, textSHA256: String, richTextSHA256: String, occurrence: Int,
    paragraphUTF16Location: Int? = nil, paragraphUTF16Length: Int? = nil) {
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.utf16Location = utf16Location
    self.utf16Length = utf16Length
    self.textByteCount = textByteCount
    self.textSHA256 = textSHA256
    self.richTextSHA256 = richTextSHA256
    self.occurrence = occurrence
    self.paragraphUTF16Location = paragraphUTF16Location
    self.paragraphUTF16Length = paragraphUTF16Length
  }
}

func notesInlineTextSelection(
  in string: NSString, text: String, paragraphRange: NSRange, occurrence: Int?, operation: String
) throws -> (range: NSRange, occurrence: Int) {
  guard !text.isEmpty else {
    throw CLIError(code: .validationError, message: "Inline body formatting requires non-empty `--text`.")
  }
  guard let searchRange = notesInlineRange(location: paragraphRange.location,
    length: paragraphRange.length, bodyLength: string.length) else {
    throw CLIError(code: .backendUnavailable, message: "Notes inline paragraph range is unavailable.",
      details: ["operation": operation])
  }
  var matches: [NSRange] = []
  var cursor = searchRange.location
  while cursor < NSMaxRange(searchRange) {
    let match = string.range(of: text, options: .literal,
      range: NSRange(location: cursor, length: NSMaxRange(searchRange) - cursor))
    if match.location == NSNotFound { break }
    matches.append(match)
    cursor = NSMaxRange(match)
  }
  let selected = occurrence ?? 1
  guard selected > 0, selected <= matches.count else {
    throw CLIError(code: .notFound, message: "Inline text occurrence did not match the selected paragraph.",
      details: ["operation": operation, "match_count": "\(matches.count)", "requested_occurrence": "\(selected)"])
  }
  guard occurrence != nil || matches.count == 1 else {
    throw CLIError(code: .ambiguousIdentity,
      message: "Inline text selector matched multiple ranges; use `--occurrence`.",
      details: ["operation": operation, "match_count": "\(matches.count)"])
  }
  return (matches[selected - 1], selected)
}

enum NotesInlineCoverage: Equatable {
  case absent
  case partial
  case full

  func matches(enabled: Bool) -> Bool {
    enabled ? self == .full : self == .absent
  }
}

func notesInlineRange(location: Int?, length: Int?, bodyLength: Int?) -> NSRange? {
  guard let location, let length, let bodyLength,
    location >= 0, length > 0, bodyLength >= 0,
    location <= bodyLength, length <= bodyLength - location
  else { return nil }
  return NSRange(location: location, length: length)
}

func notesInlineSelectionRange(
  in structure: NotesBodyStructureRecord,
  evidence: NotesBodyInlineMutationEvidence
) -> NSRange? {
  guard let bodyHash = structure.richTextSHA256, bodyHash == evidence.richTextSHA256 else { return nil }
  return notesInlineRange(location: evidence.utf16Location, length: evidence.utf16Length,
    bodyLength: structure.richTextLength)
}

func notesInlineFormatCoverage(
  in structure: NotesBodyStructureRecord,
  evidence: NotesBodyInlineMutationEvidence,
  format: String
) -> NotesInlineCoverage? {
  guard let selection = notesInlineSelectionRange(in: structure, evidence: evidence),
    let runs = structure.inlineFormatRuns
  else { return nil }
  var ranges: [NSRange] = []
  for run in runs where run.format == format {
    guard let range = notesInlineRange(location: run.utf16Location, length: run.utf16Length,
      bodyLength: structure.richTextLength) else { return nil }
    if let paragraph = run.paragraphIDSHA256, let selectedParagraph = evidence.paragraphIDSHA256,
      paragraph != selectedParagraph, NSIntersectionRange(range, selection).length > 0
    { return nil }
    if evidence.fontSHA256 == nil || run.fontSHA256 == evidence.fontSHA256 {
      ranges.append(range)
    }
  }
  return notesInlineCoverage(selection: selection, ranges: ranges)
}

func notesInlineColorCoverage(
  in structure: NotesBodyStructureRecord,
  evidence: NotesBodyInlineMutationEvidence
) -> NotesInlineCoverage? {
  guard let selection = notesInlineSelectionRange(in: structure, evidence: evidence),
    let runs = structure.colorRuns
  else { return nil }
  var ranges: [NSRange] = []
  for run in runs where run.role == evidence.role {
    guard let range = notesInlineRange(location: run.utf16Location, length: run.utf16Length,
      bodyLength: structure.richTextLength) else { return nil }
    if let paragraph = run.paragraphIDSHA256, let selectedParagraph = evidence.paragraphIDSHA256,
      paragraph != selectedParagraph, NSIntersectionRange(range, selection).length > 0
    { return nil }
    if evidence.colorSHA256 == nil || run.colorSHA256 == evidence.colorSHA256 {
      ranges.append(range)
    }
  }
  return notesInlineCoverage(selection: selection, ranges: ranges)
}

private func notesInlineCoverage(selection: NSRange, ranges: [NSRange]) -> NotesInlineCoverage {
  let intersections = ranges.map { NSIntersectionRange($0, selection) }
    .filter { $0.length > 0 }.sorted { $0.location < $1.location }
  guard !intersections.isEmpty else { return .absent }
  var coveredEnd = selection.location
  for range in intersections {
    if range.location > coveredEnd { return .partial }
    coveredEnd = max(coveredEnd, NSMaxRange(range))
    if coveredEnd == NSMaxRange(selection) { return .full }
  }
  return .partial
}
