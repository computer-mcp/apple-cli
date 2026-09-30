import Foundation
import Utility

func reminderListTypeOption(_ value: String?) throws -> String? {
  guard let value else {
    return nil
  }
  let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  switch normalized {
  case "standard":
    return "standard"
  case "shopping", "grocery":
    return "shopping"
  default:
    throw CLIError(
      code: .validationError,
      message: "`--type` must be one of: standard, shopping."
    )
  }
}

enum ReminderListIconCatalog {
  static let records: [ReminderListIconRecord] =
    [icon("default", category: "default")]
    + icons("bookmarks", 1...2)
    + icons("celebration", 1...2)
    + icons("concept", 1...3)
    + icons("education", 1...5)
    + icons("finance", 1...3)
    + [icon("fitness", category: "fitness")]
    + [icon("food", category: "food")]
    + icons("health", 1...2)
    + icons("lifestyle", 1...2)
    + icons("location", 1...3)
    + icons("media", 1...5)
    + icons("nature", 1...2)
    + icons("people", 1...3)
    + icons("pet", 1...3)
    + icons("shopping", 1...4)
    + icons("sport", 1...6)
    + icons("symbol", 1...7)
    + icons("transport", 1...4)
    + [icon("vacation", category: "vacation")]
    + icons("weather", 1...5)
    + [icon("wine", category: "wine")]
    + icons("work", 1...5)

  private static let tokens = Set(records.map(\.token))

  static func normalizedToken(_ value: String) -> String? {
    let token = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard tokens.contains(token) else {
      return nil
    }
    return token
  }

  private static func icons(_ category: String, _ range: ClosedRange<Int>)
    -> [ReminderListIconRecord]
  {
    range.map { number in
      icon("\(category)\(number)", category: category)
    }
  }

  private static func icon(_ token: String, category: String) -> ReminderListIconRecord {
    ReminderListIconRecord(
      token: token,
      assetName: "ListBadge\(assetSuffix(token))",
      category: category
    )
  }

  private static func assetSuffix(_ token: String) -> String {
    guard let first = token.first else {
      return token
    }
    return first.uppercased() + String(token.dropFirst())
  }
}

func reminderListIconOption(_ value: String?) throws -> String? {
  guard let value else {
    return nil
  }

  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--icon` must not be empty.")
  }

  if let token = ReminderListIconCatalog.normalizedToken(trimmed) {
    return token
  }

  if isReminderListEmojiRawValue(trimmed) {
    return trimmed
  }

  throw CLIError(
    code: .validationError,
    message: "Unsupported Reminders list icon.",
    details: [
      "icon": trimmed,
      "supported": "Use `apple reminders lists icons list` for native badge tokens, "
        + "or pass a Reminders emoji raw value like {\"Emoji\":\"...\"}.",
    ]
  )
}

private func isReminderListEmojiRawValue(_ value: String) -> Bool {
  guard value.hasPrefix("{"), value.hasSuffix("}"),
    let data = value.data(using: .utf8),
    let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
    let emoji = object["Emoji"] as? String
  else {
    return false
  }
  return !emoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

func reminderListTextOption(_ value: String?, optionName: String) throws -> String? {
  guard let value else {
    return nil
  }
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(optionName)` must not be empty.")
  }
  return trimmed
}

func reminderRequiredTextOption(_ name: String, options: CLIOptions) throws -> String {
  let value = try requiredOption(name, options: options)
    .trimmingCharacters(in: .whitespacesAndNewlines)
  guard !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  return value
}

func reminderListSortOption(_ value: String?) throws -> String? {
  guard let value else {
    return nil
  }
  let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  switch normalized {
  case "manual":
    return "manual"
  case "due-date", "duedate", "due":
    return "dueDate"
  case "creation-date", "creationdate", "created":
    return "creationDate"
  case "title", "name":
    return "title"
  case "priority":
    return "priority"
  default:
    throw CLIError(
      code: .validationError,
      message: "`--sort` must be one of: manual, due-date, creation-date, title, priority."
    )
  }
}
