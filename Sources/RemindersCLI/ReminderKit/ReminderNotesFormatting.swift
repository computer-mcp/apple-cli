import Foundation
import ReminderKit
import Utility

func reminderNotesSelection(in text: NSString, literal: String?, occurrence: Int?) throws -> NSRange {
  if literal?.isEmpty == true || (occurrence != nil && literal == nil) || (occurrence ?? 1) < 1 {
    throw CLIError(code: .validationError,
      message: "Select non-empty `--text` before specifying a positive `--occurrence`.")
  }
  guard text.length > 0 else {
    throw CLIError(code: .validationError, message: "Reminder notes are empty.")
  }
  guard let literal else { return NSRange(location: 0, length: text.length) }
  var matches: [NSRange] = []
  var cursor = 0
  while cursor < text.length {
    let match = text.range(of: literal, options: .literal,
      range: NSRange(location: cursor, length: text.length - cursor))
    guard match.location != NSNotFound else { break }
    matches.append(match)
    cursor = NSMaxRange(match)
  }
  guard !matches.isEmpty else {
    throw CLIError(code: .notFound, message: "The literal text was not found in reminder notes.")
  }
  if let occurrence {
    guard occurrence > 0, occurrence <= matches.count else {
      throw CLIError(code: .validationError, message: "The requested text occurrence does not exist.")
    }
    return matches[occurrence - 1]
  }
  guard matches.count == 1 else {
    throw CLIError(code: .ambiguousIdentity,
      message: "The literal text occurs more than once; select it with `--occurrence`."
    )
  }
  return matches[0]
}

func reminderNotesFormat(_ text: NSMutableAttributedString, range: NSRange,
  format: ReminderNotesFormat, enabled: Bool) throws
{
  let operation = "notes.format"
  try reminderNotesRequireRange(range, length: text.length)
  let selected = try reminderNotesRecord(id: "", notes: text).runs.filter {
    $0.location < NSMaxRange(range) && $0.location + $0.length > range.location
  }
  let alreadyMatches = selected.allSatisfy { run in
    switch format {
    case .bold: run.bold == enabled
    case .italic: run.italic == enabled
    case .underline: run.underline == enabled
    case .strikethrough: run.strikethrough == enabled
    }
  }
  if alreadyMatches { return }
  switch format {
  case .bold, .italic:
    try ReminderKitRuntimeMethod(owner: "NSMutableAttributedString",
      selector: "rem_setFontHint:isOn:inRange:", returnType: "v",
      argumentTypes: ["Q", "B", "{_NSRange=QQ}"]
    ).require(operation: operation, receiver: text)
    text.rem_setFontHint(format == .bold ? 1 : 2, isOn: enabled, in: range)
  case .underline:
    try ReminderKitRuntimeMethod(owner: "NSMutableAttributedString",
      selector: "rem_setUnderline:inRange:", returnType: "v",
      argumentTypes: ["B", "{_NSRange=QQ}"]
    ).require(operation: operation, receiver: text)
    text.rem_setUnderline(enabled, in: range)
  case .strikethrough:
    let key = NSAttributedString.Key("TTStrikethrough")
    if enabled { text.addAttribute(key, value: NSNumber(value: 1), range: range) }
    else { text.removeAttribute(key, range: range) }
  }
}

func reminderNotesListStyle(_ text: NSMutableAttributedString, range: NSRange,
  style: ReminderNotesListStyle) throws
{
  let operation = "notes.list-style"
  try reminderNotesRequireRange(range, length: text.length)
  let string = text.string as NSString
  var cursor = range.location
  while cursor < NSMaxRange(range) {
    let paragraph = string.paragraphRange(for: NSRange(location: cursor, length: 0))
    let key = NSAttributedString.Key("TTStyle")
    let old = text.attribute(key, at: paragraph.location, effectiveRange: nil)
    let source: TTParagraphStyle
    if let old {
      guard let native = old as? TTParagraphStyle else { throw reminderNotesUnavailable() }
      source = native
      var conflicting = false
      text.enumerateAttribute(key, in: paragraph) { value, _, _ in
        if let value = value as? NSObject { conflicting = conflicting || !value.isEqual(source) }
        else { conflicting = true }
      }
      guard !conflicting else { throw reminderNotesUnavailable() }
    } else {
      var hasPartialStyle = false
      text.enumerateAttribute(key, in: paragraph) { value, _, _ in
        hasPartialStyle = hasPartialStyle || value != nil
      }
      guard !hasPartialStyle else { throw reminderNotesUnavailable() }
      try ReminderKitRuntimeMethod(owner: "TTParagraphStyle", selector: "defaultParagraphStyle",
        scope: .classMethod, returnType: "@"
      ).require(operation: operation)
      guard let native = TTParagraphStyle.defaultParagraphStyle() as? TTParagraphStyle else {
        throw reminderNotesUnavailable()
      }
      source = native
    }
    try ReminderKitRuntimeMethod(owner: "TTParagraphStyle", selector: "style", returnType: "I")
      .require(operation: operation, receiver: source)
    if style == .plain {
      try ReminderKitRuntimeMethod(owner: "NSMutableAttributedString",
        selector: "rem_removeParagraphNamedStyleFromRange:", returnType: "v",
        argumentTypes: ["{_NSRange=QQ}"]
      ).require(operation: operation, receiver: text)
      text.rem_removeParagraphNamedStyle(from: paragraph)
      cursor = NSMaxRange(paragraph)
      continue
    }
    if source.style != style.nativeValue {
      try ReminderKitRuntimeMethod(owner: "TTParagraphStyle", selector: "mutableCopyWithZone:",
        returnType: "@", argumentTypes: ["^{_NSZone=}"]
      ).require(operation: operation, receiver: source)
      guard let copy = source.mutableCopy() as? TTParagraphStyle else { throw reminderNotesUnavailable() }
      try ReminderKitRuntimeMethod(owner: "TTParagraphStyle", selector: "setStyle:",
        returnType: "v", argumentTypes: ["I"]
      ).require(operation: operation, receiver: copy)
      copy.style = style.nativeValue
      text.addAttribute(key, value: copy, range: paragraph)
    }
    cursor = NSMaxRange(paragraph)
  }
}

func reminderNotesRecord(id: String, notes: NSAttributedString?) throws -> ReminderNotesRecord {
  guard let notes, notes.length > 0 else {
    return .init(reminderId: id, plainText: notes?.string, utf16Length: 0, runs: [])
  }
  let operation = "notes.read"
  try ReminderKitRuntimeMethod(owner: "NSAttributedString", selector: "rem_fontHintAtIndex:effectiveRange:",
    returnType: "Q", argumentTypes: ["q", "^{_NSRange=QQ}"]
  ).require(operation: operation, receiver: notes)
  var runs: [ReminderNotesRecord.Run] = []
  var failure: (any Error)?
  notes.enumerateAttributes(in: NSRange(location: 0, length: notes.length)) { attributes, range, stop in
    do {
      if let hint = attributes[.init("TTHints")] {
        guard let hint = hint as? NSNumber, UInt64(hint.stringValue) != nil else {
          throw reminderNotesUnavailable()
        }
      }
      let hints = notes.rem_fontHint(at: Int64(range.location), effectiveRange: nil)
      let underline = try reminderNotesFlag(attributes[.init("TTUnderline")])
      let strike = try reminderNotesFlag(attributes[.init("TTStrikethrough")])
      var listStyle: ReminderNotesListStyle? = .plain
      var indent: UInt64?
      if let value = attributes[.init("TTStyle")] {
        guard let style = value as? TTParagraphStyle else { throw reminderNotesUnavailable() }
        for (selector, returns) in [("style", "I"), ("indent", "Q")] {
          try ReminderKitRuntimeMethod(owner: "TTParagraphStyle", selector: selector, returnType: returns)
            .require(operation: operation, receiver: style)
        }
        listStyle = ReminderNotesListStyle.allCases.first { $0.nativeValue == style.style }
        indent = style.indent
      }
      var link: String?
      if let value = attributes[.init("NSLink")] {
        if let url = value as? URL { link = url.absoluteString }
        else if let string = value as? String { link = string }
        else { throw reminderNotesUnavailable() }
      }
      runs.append(.init(location: range.location, length: range.length,
        bold: hints & 1 != 0, italic: hints & 2 != 0, underline: underline,
        strikethrough: strike, link: link, listStyle: listStyle, indent: indent))
    } catch { failure = error; stop.pointee = true }
  }
  if let failure { throw failure }
  return .init(reminderId: id, plainText: notes.string, utf16Length: notes.length, runs: runs)
}

private func reminderNotesFlag(_ value: Any?) throws -> Bool {
  guard let value else { return false }
  guard let number = value as? NSNumber, number.doubleValue.isFinite else {
    throw reminderNotesUnavailable()
  }
  return number.boolValue
}

private func reminderNotesRequireRange(_ range: NSRange, length: Int) throws {
  guard range.location >= 0, range.location <= length,
    range.length > 0, range.length <= length - range.location else {
    throw CLIError(code: .validationError, message: "Reminder notes selection is outside the text.")
  }
}

func reminderNotesUnavailable() -> CLIError {
  CLIError(code: .backendUnavailable, message: "Reminder notes formatting could not be read safely.")
}
