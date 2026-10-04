import EventKit
import Foundation
import Utility

let recurrenceOptionNames: Set<String> = [
  "recurrence-frequency", "recurrence-interval", "recurrence-count", "recurrence-until",
  "recurrence-by-day", "recurrence-by-month-day", "recurrence-by-month",
  "recurrence-by-week-no", "recurrence-by-year-day", "recurrence-by-set-pos",
]

private let recurrenceWeekdays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

func hasRecurrenceOptions(_ options: CLIOptions) -> Bool {
  recurrenceOptionNames.contains { options.targetOption($0) != nil }
}

func recurrenceRuleOption(_ options: CLIOptions, effectiveStart: Date) throws
  -> CalendarRecurrenceRule?
{
  guard hasRecurrenceOptions(options) else { return nil }
  let frequency = try normalizedRecurrenceFrequency(
    try requiredOption("recurrence-frequency", options: options))
  let rule = CalendarRecurrenceRule(
    frequency: frequency,
    interval: try positiveIntOption(
      "recurrence-interval", options: options, defaultValue: 1, upperBound: 999),
    occurrenceCount: try options.targetOption("recurrence-count").map {
      try parsePositiveInteger($0, flag: "--recurrence-count", upperBound: 9_999)
    },
    until: try options.targetOption("recurrence-until").map(parseEventDate),
    daysOfTheWeek: try options.targetOption("recurrence-by-day").map(parseRecurrenceWeekdays),
    daysOfTheMonth: try recurrenceIntegers("recurrence-by-month-day", options: options),
    monthsOfTheYear: try recurrenceIntegers("recurrence-by-month", options: options),
    weeksOfTheYear: try recurrenceIntegers("recurrence-by-week-no", options: options),
    daysOfTheYear: try recurrenceIntegers("recurrence-by-year-day", options: options),
    setPositions: try recurrenceIntegers("recurrence-by-set-pos", options: options)
  )
  try validateRecurrence(rule)
  if let until = rule.until, until <= effectiveStart {
    throw CLIError(
      code: .validationError, message: "`--recurrence-until` must be later than the event start.")
  }
  return rule
}

private func parseRecurrenceWeekdays(_ value: String) throws -> [CalendarRecurrenceWeekday] {
  guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    throw CLIError(
      code: .validationError, message: "`--recurrence-by-day` requires at least one weekday.")
  }
  let days = try value.split(separator: ",", omittingEmptySubsequences: false).map { part in
    let token = part.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    let day = String(token.suffix(2))
    let ordinal = token.dropLast(min(2, token.count))
    guard recurrenceWeekdays.contains(day),
      ordinal.isEmpty || (Int(ordinal).map { (-53...53).contains($0) && $0 != 0 } ?? false)
    else {
      throw CLIError(
        code: .validationError,
        message:
          "`--recurrence-by-day` uses SU, MO, TU, WE, TH, FR, SA, optionally with a signed week number."
      )
    }
    return CalendarRecurrenceWeekday(dayOfWeek: day, weekNumber: Int(ordinal) ?? 0)
  }
  return Array(Set(days)).sorted {
    let left = recurrenceWeekdays.firstIndex(of: $0.dayOfWeek)!
    let right = recurrenceWeekdays.firstIndex(of: $1.dayOfWeek)!
    return left == right ? $0.weekNumber < $1.weekNumber : left < right
  }
}

private func recurrenceIntegers(_ name: String, options: CLIOptions) throws -> [Int]? {
  try options.targetOption(name).map { value in
    guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw CLIError(code: .validationError, message: "`--\(name)` requires at least one integer.")
    }
    let integers = try value.split(separator: ",", omittingEmptySubsequences: false).map { part in
      guard let integer = Int(part.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        throw CLIError(
          code: .validationError,
          message: "`--\(name)` requires a comma-separated list of integers.")
      }
      return integer
    }
    return Array(Set(integers)).sorted()
  }
}

func validateRecurrence(_ rule: CalendarRecurrenceRule) throws {
  _ = try normalizedRecurrenceFrequency(rule.frequency)
  guard rule.interval > 0, rule.occurrenceCount.map({ $0 > 0 }) ?? true,
    rule.until?.timeIntervalSince1970.isFinite ?? true
  else {
    throw CLIError(
      code: .validationError,
      message: "Recurrence interval and count must be positive, and its end must be a valid date.")
  }
  guard rule.occurrenceCount == nil || rule.until == nil else {
    throw CLIError(
      code: .validationError,
      message: "`--recurrence-count` cannot be combined with `--recurrence-until`.")
  }
  let days = rule.daysOfTheWeek ?? []
  if !days.isEmpty {
    guard rule.frequency != "daily" else {
      throw invalidRecurrenceCondition("recurrence-by-day", frequency: rule.frequency)
    }
    let bound = rule.frequency == "weekly" ? 0 : rule.frequency == "monthly" ? 5 : 53
    guard
      days.allSatisfy({
        recurrenceWeekdays.contains($0.dayOfWeek) && (-bound...bound).contains($0.weekNumber)
      })
    else {
      throw CLIError(
        code: .validationError,
        message:
          "Week numbers must be zero for weekly rules, within -5...5 for monthly rules, and within -53...53 for yearly rules."
      )
    }
  }
  for (name, values, frequency, bound, signed) in [
    ("recurrence-by-month-day", rule.daysOfTheMonth, "monthly", 31, true),
    ("recurrence-by-month", rule.monthsOfTheYear, "yearly", 12, false),
    ("recurrence-by-week-no", rule.weeksOfTheYear, "yearly", 53, true),
    ("recurrence-by-year-day", rule.daysOfTheYear, "yearly", 366, true),
  ] {
    guard let values, !values.isEmpty else { continue }
    guard rule.frequency == frequency else {
      throw invalidRecurrenceCondition(name, frequency: rule.frequency)
    }
    guard values.allSatisfy({ $0 != 0 && (signed ? -bound : 1) <= $0 && $0 <= bound }) else {
      throw CLIError(code: .validationError, message: "`--\(name)` contains an out-of-range value.")
    }
  }
  if !(rule.weeksOfTheYear ?? []).isEmpty, days.contains(where: { $0.weekNumber != 0 }) {
    throw CLIError(
      code: .validationError,
      message: "Numbered weekdays cannot be combined with `--recurrence-by-week-no`.")
  }
  if let positions = rule.setPositions, !positions.isEmpty {
    let hasSelector =
      !days.isEmpty
      || [
        rule.daysOfTheMonth, rule.monthsOfTheYear,
        rule.weeksOfTheYear, rule.daysOfTheYear,
      ].contains { !($0 ?? []).isEmpty }
    guard hasSelector, positions.allSatisfy({ $0 != 0 && (-366...366).contains($0) }) else {
      throw CLIError(
        code: .validationError,
        message:
          "`--recurrence-by-set-pos` requires another recurrence selector and values within -366...-1 or 1...366."
      )
    }
  }
  if let firstDay = rule.firstDayOfTheWeek, !(0...7).contains(firstDay) {
    throw CLIError(code: .validationError, message: "Recurrence week start is invalid.")
  }
}

private func invalidRecurrenceCondition(_ name: String, frequency: String) -> CLIError {
  CLIError(
    code: .validationError, message: "`--\(name)` is not supported for \(frequency) recurrence.")
}

func recurrenceRecord(_ rule: EKRecurrenceRule) -> CalendarRecurrenceRule {
  let count = rule.recurrenceEnd?.occurrenceCount ?? 0
  return CalendarRecurrenceRule(
    frequency: recurrenceFrequency(rule.frequency), interval: rule.interval,
    occurrenceCount: count > 0 ? count : nil, until: rule.recurrenceEnd?.endDate,
    calendarIdentifier: rule.calendarIdentifier, firstDayOfTheWeek: rule.firstDayOfTheWeek,
    daysOfTheWeek: rule.daysOfTheWeek?.map {
      CalendarRecurrenceWeekday(
        dayOfWeek: recurrenceWeekdayName($0.dayOfTheWeek.rawValue), weekNumber: $0.weekNumber)
    },
    daysOfTheMonth: rule.daysOfTheMonth?.map(\.intValue),
    monthsOfTheYear: rule.monthsOfTheYear?.map(\.intValue),
    weeksOfTheYear: rule.weeksOfTheYear?.map(\.intValue),
    daysOfTheYear: rule.daysOfTheYear?.map(\.intValue),
    setPositions: rule.setPositions?.map(\.intValue)
  )
}

func eventKitRecurrenceRule(_ recurrence: CalendarRecurrenceRule) throws -> EKRecurrenceRule {
  // EventKit can raise Objective-C exceptions for invalid weekday ordinals.
  try validateRecurrence(recurrence)
  let end: EKRecurrenceEnd?
  if let count = recurrence.occurrenceCount {
    end = EKRecurrenceEnd(occurrenceCount: count)
  } else if let until = recurrence.until {
    end = EKRecurrenceEnd(end: until)
  } else {
    end = nil
  }
  let native = EKRecurrenceRule(
    recurrenceWith: try eventKitRecurrenceFrequency(recurrence.frequency),
    interval: recurrence.interval,
    daysOfTheWeek: recurrence.daysOfTheWeek?.map {
      EKRecurrenceDayOfWeek(
        EKWeekday(rawValue: recurrenceWeekdays.firstIndex(of: $0.dayOfWeek)! + 1)!,
        weekNumber: $0.weekNumber)
    },
    daysOfTheMonth: recurrence.daysOfTheMonth?.map { NSNumber(value: $0) },
    monthsOfTheYear: recurrence.monthsOfTheYear?.map { NSNumber(value: $0) },
    weeksOfTheYear: recurrence.weeksOfTheYear?.map { NSNumber(value: $0) },
    daysOfTheYear: recurrence.daysOfTheYear?.map { NSNumber(value: $0) },
    setPositions: recurrence.setPositions?.map { NSNumber(value: $0) }, end: end)
  let observed = recurrenceRecord(native)
  guard observed.frequency == recurrence.frequency, observed.interval == recurrence.interval,
    observed.occurrenceCount == recurrence.occurrenceCount, observed.until == recurrence.until,
    Set(observed.daysOfTheWeek ?? []) == Set(recurrence.daysOfTheWeek ?? []),
    Set(observed.daysOfTheMonth ?? []) == Set(recurrence.daysOfTheMonth ?? []),
    Set(observed.monthsOfTheYear ?? []) == Set(recurrence.monthsOfTheYear ?? []),
    Set(observed.weeksOfTheYear ?? []) == Set(recurrence.weeksOfTheYear ?? []),
    Set(observed.daysOfTheYear ?? []) == Set(recurrence.daysOfTheYear ?? []),
    Set(observed.setPositions ?? []) == Set(recurrence.setPositions ?? []),
    recurrence.calendarIdentifier == nil
      || observed.calendarIdentifier == recurrence.calendarIdentifier,
    recurrence.firstDayOfTheWeek == nil
      || observed.firstDayOfTheWeek == recurrence.firstDayOfTheWeek
  else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "EventKit did not retain the requested recurrence conditions.",
      details: ["frequency": recurrence.frequency])
  }
  return native
}

func recurrenceFrequency(_ frequency: EKRecurrenceFrequency) -> String {
  switch frequency {
  case .daily: return "daily"
  case .weekly: return "weekly"
  case .monthly: return "monthly"
  case .yearly: return "yearly"
  @unknown default: return "unknown"
  }
}

private func eventKitRecurrenceFrequency(_ value: String) throws -> EKRecurrenceFrequency {
  switch value {
  case "daily": return .daily
  case "weekly": return .weekly
  case "monthly": return .monthly
  case "yearly": return .yearly
  default: throw CLIError(code: .validationError, message: "Recurrence frequency is invalid.")
  }
}

private func recurrenceWeekdayName(_ value: Int) -> String {
  (1...7).contains(value) ? recurrenceWeekdays[value - 1] : "unknown"
}

func iCalendarRecurrence(_ recurrence: CalendarRecurrenceRule) -> String {
  var parts = ["FREQ=\(recurrence.frequency.uppercased())", "INTERVAL=\(recurrence.interval)"]
  if let count = recurrence.occurrenceCount { parts.append("COUNT=\(count)") }
  if let until = recurrence.until { parts.append("UNTIL=\(iCalendarDateTime(until))") }
  if let days = recurrence.daysOfTheWeek, !days.isEmpty {
    parts.append(
      "BYDAY="
        + days.map { ($0.weekNumber == 0 ? "" : String($0.weekNumber)) + $0.dayOfWeek }.joined(
          separator: ","))
  }
  for (name, values) in [
    ("BYMONTHDAY", recurrence.daysOfTheMonth), ("BYMONTH", recurrence.monthsOfTheYear),
    ("BYWEEKNO", recurrence.weeksOfTheYear), ("BYYEARDAY", recurrence.daysOfTheYear),
    ("BYSETPOS", recurrence.setPositions),
  ] {
    if let values, !values.isEmpty {
      parts.append(name + "=" + values.map(String.init).joined(separator: ","))
    }
  }
  if let day = recurrence.firstDayOfTheWeek, day != 0 {
    parts.append("WKST=" + recurrenceWeekdayName(day))
  }
  return parts.joined(separator: ";")
}
