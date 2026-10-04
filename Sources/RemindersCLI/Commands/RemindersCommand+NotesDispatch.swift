import Foundation
import Utility

extension RemindersCommand {
  func runNotesCommand(_ options: CLIOptions) throws -> CLICommandResult? {
    if options.positionals == ["notes", "read"] {
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let snapshot = try reminderNotesSnapshot(id: requiredOption("id", options: options), operation: "notes.read")
      return try result(ReminderNotesResponse(notes: snapshot.record),
        human: snapshot.record.plainText ?? "", options: options)
    }
    let isFormat = options.positionals == ["notes", "format"]
    guard isFormat || options.positionals == ["notes", "list-style"] else { return nil }
    try validateTargetOptions(options,
      allowedOptions: isFormat ? ["id", "text", "occurrence", "format", "state"] : ["id", "text", "occurrence", "style"])
    try validateMutationIntent(options)
    let id = try requiredOption("id", options: options)
    let literal = options.targetOption("text")
    let occurrence = try options.targetOption("occurrence").map { raw in
      guard literal != nil, let value = Int(raw), value > 0 else {
        throw CLIError(code: .validationError, message: "`--occurrence` requires `--text` and a positive integer.")
      }
      return value
    }
    guard literal?.isEmpty != true else {
      throw CLIError(code: .validationError, message: "`--text` cannot be empty.")
    }
    var format: ReminderNotesFormat?
    var enabled = false
    var style: ReminderNotesListStyle?
    if isFormat {
      guard let value = ReminderNotesFormat(rawValue: try requiredOption("format", options: options)),
        let state = options.targetOption("state"), ["on", "off"].contains(state) else {
        throw CLIError(code: .validationError, message: "Use a supported `--format` and `--state on|off`.")
      }
      format = value
      enabled = state == "on"
    } else {
      guard let value = ReminderNotesListStyle(rawValue: try requiredOption("style", options: options)) else {
        throw CLIError(code: .validationError, message: "Use `--style plain|bulleted|dashed|numbered`.")
      }
      style = value
    }
    let operation = "reminders.notes." + (isFormat ? "format" : "list-style")
    let before = try reminderNotesSnapshot(id: id, operation: operation)
    let expected = NSMutableAttributedString(attributedString: before.text ?? NSAttributedString(string: ""))
    let selection = try reminderNotesSelection(in: expected.string as NSString, literal: literal, occurrence: occurrence)
    if let format { try reminderNotesFormat(expected, range: selection, format: format, enabled: enabled) }
    if let style { try reminderNotesListStyle(expected, range: selection, style: style) }
    var summary = ["id": before.detail.id, "list_id": before.detail.listId,
      "selection_location": String(selection.location), "selection_length": String(selection.length),
      "notes_sha256": sha256Hex(before.record.plainText ?? "")]
    if let format {
      summary["format"] = format.rawValue
      summary["state"] = enabled ? "on" : "off"
    }
    if let style { summary["style"] = style.rawValue }
    let binding = try CLIJSON.encodeString(before.record) + "|" + CLIJSON.encodeString(summary)
    return try mutation(operation: operation, scopeDigest: "reminder-notes:" + sha256Hex(binding),
      summary: summary, options: options) {
      try saveReminderNotes(before, expected: expected, operation: operation)
    }
  }
}
