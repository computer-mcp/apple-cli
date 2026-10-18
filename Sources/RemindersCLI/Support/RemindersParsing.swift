import Foundation
import Utility

enum DateBoundaryRole {
  case lower
  case upper
}
func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` is required."
    )
  }

  return value
}

func reminderIDsOption(_ options: CLIOptions) throws -> [String] {
  let rawIDs = try requiredOption("ids", options: options)
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  let ids = rawIDs.filter { !$0.isEmpty }
  guard ids.count == rawIDs.count, !ids.isEmpty else {
    throw CLIError(code: .validationError, message: "`--ids` must contain non-empty reminder IDs.")
  }
  guard ids.count <= 100 else {
    throw CLIError(
      code: .validationError, message: "`--ids` cannot contain more than 100 reminders.")
  }

  var seen: Set<String> = []
  for id in ids where !seen.insert(id).inserted {
    throw CLIError(
      code: .validationError, message: "`--ids` must not contain duplicate reminder IDs.",
      details: ["id": id])
  }
  return ids
}

func matchingSearchText(_ value: String?) throws -> String? {
  guard let value else {
    return nil
  }

  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard trimmed.count >= 2 else {
    throw CLIError(
      code: .validationError,
      message:
        "`--query` must contain at least two non-whitespace characters for matching mutations."
    )
  }
  return trimmed
}

func reminderPriority(_ value: String?) throws -> Int {
  guard let value, !value.isEmpty else {
    return 0
  }
  guard let priority = Int(value), (0...9).contains(priority) else {
    throw CLIError(
      code: .validationError, message: "`--priority` must be an integer from 0 through 9.")
  }
  return priority
}

func reminderDueInput(_ value: String?) throws -> (value: String?, kind: String?) {
  guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    return (nil, nil)
  }

  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  if parseDateOnlyParts(trimmed) != nil {
    return (trimmed, "date")
  }

  _ = try parseDateBoundary(trimmed, role: .lower)
  return (trimmed, "date_time")
}

func reminderRepeatDueDate(value: String?, kind: String?) throws -> Date? {
  guard let value, kind != nil else {
    return nil
  }
  return try parseDateBoundary(value, role: .lower)
}

func completionFilter(_ value: String?) throws -> ReminderCompletionFilter {
  guard let value else {
    return .incomplete
  }

  guard let filter = ReminderCompletionFilter(rawValue: value) else {
    throw CLIError(
      code: .validationError,
      message: "`--status` must be one of: all, completed, incomplete."
    )
  }

  return filter
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError,
      message: "`--limit` cannot exceed 500 for Reminders read commands."
    )
  }
  return limit
}

func mutationCandidateLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 100 else {
    throw CLIError(
      code: .validationError,
      message: "`--limit` cannot exceed 100 for Reminders matching mutations."
    )
  }
  return limit
}

func optionalDateBoundary(_ value: String?, role: DateBoundaryRole) throws -> Date? {
  guard let value else {
    return nil
  }
  return try parseDateBoundary(value, role: role)
}

func optionalISO8601DateTime(_ value: String?, optionName: String) throws -> Date? {
  guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    return nil
  }
  return try parseISO8601DateTime(value, optionName: optionName)
}

func parseISO8601DateTime(_ value: String, optionName: String) throws -> Date {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = formatter.date(from: trimmed) {
    return date
  }

  formatter.formatOptions = [.withInternetDateTime]
  if let date = formatter.date(from: trimmed) {
    return date
  }

  throw CLIError(
    code: .validationError,
    message: "`--\(optionName)` must use ISO-8601 date-time format.",
    details: ["value": value, "example": "2021-01-02T03:04:05Z"]
  )
}

func parseDateBoundary(_ value: String, role: DateBoundaryRole) throws -> Date {
  if let date = parseDateOnly(value, role: role) {
    return date
  }

  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = formatter.date(from: value) {
    return date
  }

  formatter.formatOptions = [.withInternetDateTime]
  if let date = formatter.date(from: value) {
    return date
  }

  throw CLIError(
    code: .validationError,
    message: "Date values must use YYYY-MM-DD or ISO-8601 date-time format.",
    details: ["value": value]
  )
}

func parseDateOnly(_ value: String, role: DateBoundaryRole) -> Date? {
  guard let parsed = parseDateOnlyParts(value) else {
    return nil
  }

  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = .current
  let components = DateComponents(
    calendar: calendar, timeZone: calendar.timeZone, year: parsed.year, month: parsed.month,
    day: parsed.day)
  guard let startOfDay = components.date else {
    return nil
  }

  switch role {
  case .lower:
    return startOfDay
  case .upper:
    return calendar.date(byAdding: .day, value: 1, to: startOfDay)
  }
}

func parseDateOnlyParts(_ value: String) -> (year: Int, month: Int, day: Int)? {
  let parts = value.split(separator: "-")
  guard parts.count == 3,
    let year = Int(parts[0]),
    let month = Int(parts[1]),
    let day = Int(parts[2])
  else {
    return nil
  }
  return (year, month, day)
}

func reminderDueComponents(value: String?, kind: String?) throws -> DateComponents? {
  guard let value, let kind else {
    return nil
  }

  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = .current

  if kind == "date", let parts = parseDateOnlyParts(value) {
    return DateComponents(
      calendar: calendar, timeZone: calendar.timeZone, year: parts.year, month: parts.month,
      day: parts.day)
  }

  let date = try parseDateBoundary(value, role: .lower)
  return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
}

func reminderURL(_ value: String?) throws -> URL? {
  guard let value else {
    return nil
  }

  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--url` must not be empty.")
  }

  guard let url = URL(string: trimmed), url.scheme != nil else {
    throw CLIError(
      code: .validationError, message: "`--url` must be an absolute URL.")
  }

  return url
}

func reminderBool(_ value: String, optionName: String) throws -> Bool {
  switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
  case "true", "yes", "1":
    return true
  case "false", "no", "0":
    return false
  default:
    throw CLIError(
      code: .validationError,
      message: "`--\(optionName)` must be true or false."
    )
  }
}

func reminderDue(_ components: DateComponents?) -> (value: String?, kind: String?) {
  guard var components else {
    return (nil, nil)
  }

  if components.calendar == nil {
    components.calendar = Calendar(identifier: .gregorian)
  }

  if components.timeZone == nil {
    components.timeZone = .current
  }

  let hasTime = components.hour != nil || components.minute != nil || components.second != nil
  if !hasTime, let year = components.year, let month = components.month, let day = components.day {
    return (String(format: "%04d-%02d-%02d", year, month, day), "date")
  }

  guard let date = components.date else {
    return (nil, nil)
  }

  return (ISO8601DateFormatter().string(from: date), "date_time")
}

func reminderDueDate(_ components: DateComponents?) -> Date? {
  guard var components else {
    return nil
  }

  if components.calendar == nil {
    components.calendar = Calendar(identifier: .gregorian)
  }

  if components.timeZone == nil {
    components.timeZone = .current
  }

  return components.date
}
