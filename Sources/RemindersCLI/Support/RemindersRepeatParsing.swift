import Foundation
import Utility

func hasReminderRepeatOptions(_ options: CLIOptions) -> Bool {
  options.targetOption("repeat") != nil
    || options.targetOption("repeat-interval") != nil
    || options.targetOption("repeat-count") != nil
    || options.targetOption("repeat-until") != nil
    || options.targetOption("repeat-days-of-week") != nil
    || options.targetOption("repeat-weekday-positions") != nil
    || options.targetOption("repeat-days-of-month") != nil
    || options.targetOption("repeat-months-of-year") != nil
    || options.targetOption("repeat-set-positions") != nil
}

func reminderRepeatOption(_ options: CLIOptions, effectiveDueDate: Date?) throws
  -> ReminderRepeatRule?
{
  guard hasReminderRepeatOptions(options) else {
    return nil
  }

  guard let effectiveDueDate else {
    throw CLIError(
      code: .validationError,
      message: "`--repeat` requires `--due` or an existing due date."
    )
  }

  let frequency = try normalizedReminderRepeatFrequency(
    try requiredOption("repeat", options: options))
  let interval = try reminderPositiveIntOption(
    "repeat-interval",
    options: options,
    defaultValue: 1,
    upperBound: 999
  )
  let occurrenceCount = try options.targetOption("repeat-count").map {
    try parsePositiveReminderInteger($0, flag: "--repeat-count", upperBound: 9_999)
  }
  let until = try options.targetOption("repeat-until").map {
    try parseDateBoundary($0, role: .lower)
  }
  let daysOfWeek = try reminderRepeatDaysOfWeekOption(options)
  let weekdayPositions = try reminderRepeatWeekdayPositionsOption(options)
  let daysOfMonth = try reminderRepeatDaysOfMonthOption(options)
  let monthsOfYear = try reminderRepeatMonthsOfYearOption(options)
  let setPositions = try reminderRepeatSetPositionsOption(options)

  if occurrenceCount != nil, until != nil {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-count` cannot be combined with `--repeat-until`."
    )
  }

  if let until, until <= effectiveDueDate {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-until` must be later than the reminder due date."
    )
  }
  try validateReminderRepeatCustomComponents(
    frequency: frequency,
    daysOfWeek: daysOfWeek,
    weekdayPositions: weekdayPositions,
    daysOfMonth: daysOfMonth,
    monthsOfYear: monthsOfYear,
    setPositions: setPositions
  )

  return ReminderRepeatRule(
    frequency: frequency,
    interval: interval,
    occurrenceCount: occurrenceCount,
    until: until,
    daysOfWeek: daysOfWeek,
    weekdayPositions: weekdayPositions,
    daysOfMonth: daysOfMonth,
    monthsOfYear: monthsOfYear,
    setPositions: setPositions
  )
}

func normalizedReminderRepeatFrequency(_ value: String) throws -> String {
  let frequency = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  switch frequency {
  case "day", "daily":
    return "daily"
  case "hour", "hourly":
    return "hourly"
  case "week", "weekly":
    return "weekly"
  case "month", "monthly":
    return "monthly"
  case "year", "yearly", "annually", "annual":
    return "yearly"
  default:
    throw CLIError(
      code: .validationError,
      message: "`--repeat` must be hourly, daily, weekly, monthly, or yearly.",
      details: ["value": value]
    )
  }
}

func reminderPositiveIntOption(
  _ name: String,
  options: CLIOptions,
  defaultValue: Int,
  upperBound: Int
) throws -> Int {
  guard let value = options.targetOption(name) else {
    return defaultValue
  }
  return try parsePositiveReminderInteger(value, flag: "--\(name)", upperBound: upperBound)
}

func parsePositiveReminderInteger(_ value: String, flag: String, upperBound: Int) throws -> Int {
  guard let parsed = Int(value), parsed > 0, parsed <= upperBound else {
    throw CLIError(
      code: .validationError,
      message: "`\(flag)` must be an integer from 1 through \(upperBound).",
      details: ["value": value]
    )
  }
  return parsed
}

func reminderRepeatDaysOfWeekOption(_ options: CLIOptions) throws -> [String] {
  let weekdays = try repeatListOption("repeat-days-of-week", options: options).map {
    try normalizedReminderRepeatWeekday($0)
  }
  return uniqueStrings(weekdays)
}

func reminderRepeatWeekdayPositionsOption(_ options: CLIOptions) throws
  -> [ReminderRepeatWeekdayPosition]
{
  let positions = try repeatListOption("repeat-weekday-positions", options: options).map {
    try parseReminderRepeatWeekdayPosition($0)
  }
  return uniqueWeekdayPositions(positions)
}

func reminderRepeatDaysOfMonthOption(_ options: CLIOptions) throws -> [Int] {
  let days = try repeatListOption("repeat-days-of-month", options: options).map {
    try parseReminderRepeatDayOfMonth($0)
  }
  return sortedUniqueInts(days)
}

func reminderRepeatMonthsOfYearOption(_ options: CLIOptions) throws -> [Int] {
  let months = try repeatListOption("repeat-months-of-year", options: options).map {
    try parseReminderRepeatMonthOfYear($0)
  }
  return sortedUniqueInts(months)
}

func reminderRepeatSetPositionsOption(_ options: CLIOptions) throws -> [Int] {
  let positions = try repeatListOption("repeat-set-positions", options: options).map {
    try parseReminderRepeatSetPosition($0)
  }
  return sortedUniqueInts(positions)
}

func repeatListOption(_ name: String, options: CLIOptions) throws -> [String] {
  guard let value = options.targetOption(name) else {
    return []
  }
  let rawValues = value
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  let values = rawValues.filter { !$0.isEmpty }
  guard !values.isEmpty, values.count == rawValues.count else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` must contain non-empty comma-separated values.",
      details: ["value": value]
    )
  }
  return Array(NSOrderedSet(array: values).compactMap { $0 as? String })
}

func uniqueStrings(_ values: [String]) -> [String] {
  var seen: Set<String> = []
  var unique: [String] = []
  for value in values where seen.insert(value).inserted {
    unique.append(value)
  }
  return unique
}

func sortedUniqueInts(_ values: [Int]) -> [Int] {
  Array(Set(values)).sorted()
}

func uniqueWeekdayPositions(_ values: [ReminderRepeatWeekdayPosition])
  -> [ReminderRepeatWeekdayPosition]
{
  var seen: Set<String> = []
  var unique: [ReminderRepeatWeekdayPosition] = []
  for value in values {
    let key = "\(value.weekday):\(value.weekNumber)"
    if seen.insert(key).inserted {
      unique.append(value)
    }
  }
  return unique.sorted {
    if $0.weekNumber == $1.weekNumber {
      return reminderRepeatWeekdayOrder($0.weekday) < reminderRepeatWeekdayOrder($1.weekday)
    }
    return $0.weekNumber < $1.weekNumber
  }
}

func normalizedReminderRepeatWeekday(_ value: String) throws -> String {
  switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
  case "sun", "sunday", "1":
    return "sun"
  case "mon", "monday", "2":
    return "mon"
  case "tue", "tues", "tuesday", "3":
    return "tue"
  case "wed", "wednesday", "4":
    return "wed"
  case "thu", "thur", "thurs", "thursday", "5":
    return "thu"
  case "fri", "friday", "6":
    return "fri"
  case "sat", "saturday", "7":
    return "sat"
  default:
    throw CLIError(
      code: .validationError,
      message: "`--repeat-days-of-week` values must be sun, mon, tue, wed, thu, fri, or sat.",
      details: ["value": value]
    )
  }
}

func parseReminderRepeatWeekdayPosition(_ value: String) throws -> ReminderRepeatWeekdayPosition {
  let parts = value.split(separator: ":", omittingEmptySubsequences: false).map {
    String($0).trimmingCharacters(in: .whitespacesAndNewlines)
  }
  guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-weekday-positions` values must use weekday:weekNumber, for example mon:2 or fri:-1.",
      details: ["value": value]
    )
  }
  let weekday = try normalizedReminderRepeatWeekday(parts[0])
  guard let weekNumber = Int(parts[1]), (1...53).contains(abs(weekNumber)) else {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-weekday-positions` week numbers must be integers from -53 through -1 or 1 through 53.",
      details: ["value": value]
    )
  }
  return ReminderRepeatWeekdayPosition(weekday: weekday, weekNumber: weekNumber)
}

func parseReminderRepeatDayOfMonth(_ value: String) throws -> Int {
  guard let day = Int(value), (1...31).contains(day) else {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-days-of-month` values must be integers from 1 through 31.",
      details: ["value": value]
    )
  }
  return day
}

func parseReminderRepeatMonthOfYear(_ value: String) throws -> Int {
  let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  let monthNames = [
    "jan": 1, "january": 1,
    "feb": 2, "february": 2,
    "mar": 3, "march": 3,
    "apr": 4, "april": 4,
    "may": 5,
    "jun": 6, "june": 6,
    "jul": 7, "july": 7,
    "aug": 8, "august": 8,
    "sep": 9, "sept": 9, "september": 9,
    "oct": 10, "october": 10,
    "nov": 11, "november": 11,
    "dec": 12, "december": 12,
  ]
  if let month = monthNames[normalized] {
    return month
  }
  guard let month = Int(normalized), (1...12).contains(month) else {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-months-of-year` values must be months from 1 through 12.",
      details: ["value": value]
    )
  }
  return month
}

func parseReminderRepeatSetPosition(_ value: String) throws -> Int {
  guard let position = Int(value), (1...366).contains(abs(position)) else {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-set-positions` values must be integers from -366 through -1 or 1 through 366.",
      details: ["value": value]
    )
  }
  return position
}

func validateReminderRepeatCustomComponents(
  frequency: String,
  daysOfWeek: [String],
  weekdayPositions: [ReminderRepeatWeekdayPosition],
  daysOfMonth: [Int],
  monthsOfYear: [Int],
  setPositions: [Int]
) throws {
  if !daysOfWeek.isEmpty, frequency != "weekly" && frequency != "monthly" && frequency != "yearly" {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-days-of-week` requires `--repeat weekly`, `--repeat monthly`, or `--repeat yearly`."
    )
  }
  if !weekdayPositions.isEmpty, frequency != "monthly" && frequency != "yearly" {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-weekday-positions` requires `--repeat monthly` or `--repeat yearly`."
    )
  }
  if !daysOfMonth.isEmpty, frequency != "monthly" {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-days-of-month` requires `--repeat monthly`."
    )
  }
  if !monthsOfYear.isEmpty, frequency != "yearly" {
    throw CLIError(
      code: .validationError,
      message: "`--repeat-months-of-year` requires `--repeat yearly`."
    )
  }
  if !setPositions.isEmpty {
    let hasByComponent = !daysOfWeek.isEmpty || !weekdayPositions.isEmpty || !daysOfMonth.isEmpty
      || !monthsOfYear.isEmpty
    guard frequency != "daily" && frequency != "hourly", hasByComponent else {
      throw CLIError(
        code: .validationError,
        message: "`--repeat-set-positions` requires a weekly, monthly, or yearly repeat with weekday, weekday-position, day-of-month, or month component."
      )
    }
  }
}

func reminderRepeatSummary(_ repeatRule: ReminderRepeatRule?) -> String {
  guard let repeatRule else {
    return ""
  }
  return reminderRepeatSummary(repeatRule)
}

func reminderRepeatSummary(_ repeatRule: ReminderRepeatRule) -> String {
  [
    repeatRule.frequency,
    "interval=\(repeatRule.interval)",
    repeatRule.occurrenceCount.map { "count=\($0)" } ?? "",
    repeatRule.until.map { "until=\(formatDate($0))" } ?? "",
    repeatRule.daysOfWeek.isEmpty ? "" : "weekdays=\(repeatRule.daysOfWeek.joined(separator: ","))",
    repeatRule.weekdayPositions.isEmpty
      ? ""
      : "weekday-positions=\(reminderWeekdayPositionList(repeatRule.weekdayPositions))",
    repeatRule.daysOfMonth.isEmpty ? "" : "month-days=\(intList(repeatRule.daysOfMonth))",
    repeatRule.monthsOfYear.isEmpty ? "" : "months=\(intList(repeatRule.monthsOfYear))",
    repeatRule.setPositions.isEmpty ? "" : "set-positions=\(intList(repeatRule.setPositions))",
  ]
  .filter { !$0.isEmpty }
  .joined(separator: ";")
}

func reminderWeekdayPositionList(_ values: [ReminderRepeatWeekdayPosition]) -> String {
  values.map { "\($0.weekday):\($0.weekNumber)" }.joined(separator: ",")
}

func intList(_ values: [Int]) -> String {
  values.map(String.init).joined(separator: ",")
}

func sortedReminderRepeatWeekdays(_ values: [String]) -> [String] {
  values.sorted { reminderRepeatWeekdayOrder($0) < reminderRepeatWeekdayOrder($1) }
}

func sortedReminderRepeatWeekdayPositions(_ values: [ReminderRepeatWeekdayPosition])
  -> [ReminderRepeatWeekdayPosition]
{
  uniqueWeekdayPositions(values)
}

func reminderRepeatWeekdayOrder(_ value: String) -> Int {
  switch value {
  case "sun":
    return 1
  case "mon":
    return 2
  case "tue":
    return 3
  case "wed":
    return 4
  case "thu":
    return 5
  case "fri":
    return 6
  case "sat":
    return 7
  default:
    return Int.max
  }
}
