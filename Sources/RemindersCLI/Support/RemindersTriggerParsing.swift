import Foundation
import Utility

func hasReminderLocationOptions(_ options: CLIOptions) -> Bool {
  options.targetOption("location") != nil
    || options.targetOption("location-latitude") != nil
    || options.targetOption("location-longitude") != nil
    || options.targetOption("location-radius-meters") != nil
    || options.targetOption("location-proximity") != nil
}

func reminderLocationOption(_ options: CLIOptions) throws -> ReminderLocationTrigger? {
  guard hasReminderLocationOptions(options) else {
    return nil
  }

  let title = try requiredOption("location", options: options)
    .trimmingCharacters(in: .whitespacesAndNewlines)
  guard !title.isEmpty else {
    throw CLIError(code: .validationError, message: "`--location` must not be empty.")
  }

  let latitude = try requiredDoubleOption("location-latitude", options: options)
  let longitude = try requiredDoubleOption("location-longitude", options: options)
  guard (-90...90).contains(latitude) else {
    throw CLIError(
      code: .validationError,
      message: "`--location-latitude` must be between -90 and 90.",
      details: ["value": "\(latitude)"]
    )
  }
  guard (-180...180).contains(longitude) else {
    throw CLIError(
      code: .validationError,
      message: "`--location-longitude` must be between -180 and 180.",
      details: ["value": "\(longitude)"]
    )
  }

  let radius = try options.targetOption("location-radius-meters").map {
    try reminderLocationRadius($0)
  }
  return ReminderLocationTrigger(
    title: title,
    latitude: latitude,
    longitude: longitude,
    radiusMeters: radius,
    proximity: try reminderLocationProximity(options.targetOption("location-proximity"))
  )
}

func requiredDoubleOption(_ name: String, options: CLIOptions) throws -> Double {
  let value = try requiredOption(name, options: options)
  guard let parsed = Double(value), parsed.isFinite else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` must be a finite number.",
      details: ["value": value]
    )
  }
  return parsed
}

func reminderLocationRadius(_ value: String) throws -> Double {
  guard let parsed = Double(value), parsed.isFinite, parsed > 0, parsed <= 1_000_000 else {
    throw CLIError(
      code: .validationError,
      message: "`--location-radius-meters` must be a number greater than 0 and at most 1000000.",
      details: ["value": value]
    )
  }
  return parsed
}

func reminderLocationProximity(_ value: String?) throws -> String {
  guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    return "entering"
  }

  switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
  case "enter", "entering", "arrive", "arriving", "arrival":
    return "entering"
  case "leave", "leaving", "depart", "departing", "departure":
    return "leaving"
  default:
    throw CLIError(
      code: .validationError,
      message: "`--location-proximity` must be entering or leaving.",
      details: ["value": value]
    )
  }
}

func reminderLocationSummary(_ trigger: ReminderLocationTrigger?) -> String {
  guard let trigger else {
    return ""
  }
  return reminderLocationSummary(trigger)
}

func reminderLocationSummary(_ triggers: [ReminderLocationTrigger]) -> String {
  triggers.map(reminderLocationSummary).joined(separator: ",")
}

func reminderLocationSummary(_ trigger: ReminderLocationTrigger) -> String {
  [
    trigger.title,
    trigger.latitude.map { "lat=\($0)" } ?? "",
    trigger.longitude.map { "lon=\($0)" } ?? "",
    trigger.radiusMeters.map { "radius=\($0)" } ?? "",
    "proximity=\(trigger.proximity)",
  ]
  .filter { !$0.isEmpty }
  .joined(separator: ";")
}

func reminderAlarmAtOption(_ options: CLIOptions) throws -> [Date]? {
  guard let value = options.targetOption("alarm-at") else {
    return nil
  }

  let values =
    try value
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { chunk -> Date in
      let trimmed = chunk.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else {
        throw CLIError(
          code: .validationError,
          message: "`--alarm-at` must be a comma-separated list of ISO-8601 date-time values.",
          details: ["value": value]
        )
      }
      return try parseReminderAlarmDate(trimmed)
    }

  guard !values.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--alarm-at` must include at least one ISO-8601 date-time value."
    )
  }

  return uniqueSortedDates(values)
}

func reminderEarlyReminderMinutesBeforeOption(_ options: CLIOptions) throws -> [Int]? {
  guard let value = options.targetOption("early-reminder-minutes-before") else {
    return nil
  }

  let values =
    try value
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { chunk -> Int in
      let trimmed = chunk.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, let minutes = Int(trimmed), minutes >= 0, minutes <= 525_600
      else {
        throw CLIError(
          code: .validationError,
          message:
            "`--early-reminder-minutes-before` must be a comma-separated list of minute offsets from 0 through 525600.",
          details: ["value": value]
        )
      }
      return minutes
    }

  guard !values.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--early-reminder-minutes-before` must include at least one minute offset."
    )
  }

  return Array(Set(values)).sorted()
}

func validateEarlyReminderAnchor(
  minutesBefore: [Int]?,
  dueDate: String?,
  dueDateKind: String?
) throws {
  guard let minutesBefore, !minutesBefore.isEmpty else {
    return
  }
  guard dueDate != nil, dueDateKind == "date_time" else {
    throw CLIError(
      code: .validationError,
      message:
        "`--early-reminder-minutes-before` requires a reminder due date with a time.",
      details: ["due_kind": dueDateKind ?? ""]
    )
  }
}

func minuteList(_ values: [Int]) -> String {
  values.sorted().map(String.init).joined(separator: ",")
}

func parseReminderAlarmDate(_ value: String) throws -> Date {
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
    message: "`--alarm-at` values must use ISO-8601 date-time format.",
    details: ["value": value]
  )
}

func dateList(_ values: [Date]) -> String {
  values.sorted().map(formatDate).joined(separator: ",")
}

func uniqueSortedDates(_ values: [Date]) -> [Date] {
  values
    .sorted()
    .reduce(into: [Date]()) { result, date in
      if result.last != date {
        result.append(date)
      }
    }
}
