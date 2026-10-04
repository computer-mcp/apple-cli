import Foundation
import Utility

enum ReminderSmartListFilterEncoder {
  static func encode(criteria: ReminderSmartListCriteria) throws -> Data {
    let payload = try payload(criteria: criteria)
    return try encodePayload(payload, criteriaDescription: criteria.descriptor)
  }

  static func encodeTagFilter(tagName: String) throws -> Data {
    let trimmed = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Smart List tag filter requires a non-empty tag.",
        details: ["criterion": "tags"]
      )
    }
    return try encodePayload(
      ["hashtags": ["hashtags": [trimmed]]],
      criteriaDescription: "tags:\(trimmed)"
    )
  }

  private static func encodePayload(
    _ payload: [String: Any],
    criteriaDescription: String
  ) throws -> Data {
    guard JSONSerialization.isValidJSONObject(payload) else {
      throw CLIError(
        code: .validationError,
        message: "Smart List criteria could not be encoded.",
        details: ["criteria": criteriaDescription]
      )
    }
    return try JSONSerialization.data(
      withJSONObject: payload,
      options: [.sortedKeys]
    )
  }

  private static func payload(criteria: ReminderSmartListCriteria) throws -> [String: Any] {
    let operation = try matchOperation(criteria.match)
    let tokens = try criterionTokens(criteria.descriptor)
    var fields: [String: Any] = [:]

    for token in tokens {
      let field: String
      switch token.key {
      case "tags", "any-tag": field = "hashtags"
      case "priority": field = "priorities"
      case "date", "date-on", "date-before", "date-after", "date-range": field = "date"
      default: field = token.key
      }
      guard fields[field] == nil else {
        throw unsupportedCriterion(token, reason: "Specify each Smart List filter once. Use comma-separated values or date-range for a combined filter.")
      }
      let lowerValue = token.value.lowercased()
      switch token.key {
      case "flagged":
        guard lowerValue == "true" else {
          throw unsupportedCriterion(token, reason: "Only flagged:true is supported.")
        }
        fields["flagged"] = true
      case "priority":
        fields["priorities"] = try priorityValues(token.value)
      case "tags":
        let tags = try listValues(token.value, key: token.key, lowercased: false)
        fields["hashtags"] = [
          "hashtags": [
            "operation": operation,
            "include": tags,
            "exclude": [],
          ]
        ]
      case "any-tag":
        guard lowerValue == "true" else {
          throw unsupportedCriterion(token, reason: "Only any-tag:true is supported.")
        }
        fields["hashtags"] = ["any": ""]
      case "date":
        fields["date"] = try dateValue(lowerValue)
      case "date-on":
        try validateISODate(token.value, key: token.key)
        fields["date"] = ["onDate": token.value]
      case "date-before":
        try validateISODate(token.value, key: token.key)
        fields["date"] = ["beforeDate": token.value]
      case "date-after":
        try validateISODate(token.value, key: token.key)
        fields["date"] = ["afterDate": token.value]
      case "date-range":
        let dates = token.value.split(separator: ".", omittingEmptySubsequences: false)
        guard dates.count == 3, dates[1].isEmpty else {
          throw unsupportedCriterion(token, reason: "Use date-range:YYYY-MM-DD..YYYY-MM-DD.")
        }
        let start = String(dates[0])
        let end = String(dates[2])
        try validateISODate(start, key: token.key)
        try validateISODate(end, key: token.key)
        guard start <= end else {
          throw unsupportedCriterion(token, reason: "Smart List date range must start on or before its end date.")
        }
        fields["date"] = ["dateRange": [start, end]]
      default:
        throw unsupportedCriterion(token, reason: "Unsupported Smart List criterion.")
      }
    }

    guard !fields.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "At least one supported Smart List criterion is required.",
        details: ["supported_criteria": supportedCriteriaDescription]
      )
    }
    if fields.count > 1 || operation == "or" {
      fields["operation"] = operation
    }
    return fields
  }

  private static func criterionTokens(_ descriptor: String) throws -> [(key: String, value: String)]
  {
    let tokens =
      descriptor
      .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
      .map(String.init)
    guard !tokens.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Smart List criteria are required.",
        details: ["supported_criteria": supportedCriteriaDescription]
      )
    }
    return try tokens.map { token in
      let parts = token.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
      guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else {
        throw CLIError(
          code: .validationError,
          message: "Smart List criteria must use key:value tokens.",
          details: [
            "criterion": token,
            "supported_criteria": supportedCriteriaDescription,
          ]
        )
      }
      return (String(parts[0]).lowercased(), String(parts[1]))
    }
  }

  private static func matchOperation(_ match: String) throws -> String {
    switch match.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "all":
      return "and"
    case "any":
      return "or"
    default:
      throw CLIError(
        code: .validationError,
        message: "Smart List match must be all or any.",
        details: ["match": match]
      )
    }
  }

  private static func priorityValues(_ value: String) throws -> [String] {
    let priorities = try listValues(value, key: "priority")
    let supported = Set(["low", "medium", "high"])
    let unsupported = priorities.filter { !supported.contains($0) }
    guard unsupported.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Unsupported Smart List priority criterion.",
        details: [
          "criterion": "priority:\(value)",
          "unsupported_values": unsupported.joined(separator: ","),
          "supported_values": supported.sorted().joined(separator: ","),
        ]
      )
    }
    return priorities
  }

  private static func dateValue(_ value: String) throws -> [String: Any] {
    switch value {
    case "any":
      return ["any": ""]
    case "today":
      return ["today": true]
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Smart List date criterion.",
        details: [
          "criterion": "date:\(value)",
          "supported_values": "any,today",
          "supported_criteria": supportedCriteriaDescription,
        ]
      )
    }
  }

  private static func listValues(
    _ value: String,
    key: String,
    lowercased: Bool = true
  ) throws -> [String] {
    let values =
      value
      .split(separator: ",")
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { lowercased ? $0.lowercased() : $0 }
      .filter { !$0.isEmpty }
    guard !values.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Smart List criterion requires at least one value.",
        details: ["criterion": "\(key):\(value)"]
      )
    }
    return values
  }

  private static func validateISODate(_ value: String, key: String) throws {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    guard let date = formatter.date(from: value), formatter.string(from: date) == value else {
      throw CLIError(
        code: .validationError,
        message: "Smart List date criterion must use YYYY-MM-DD.",
        details: ["criterion": "\(key):\(value)"]
      )
    }
  }

  private static func unsupportedCriterion(
    _ token: (key: String, value: String),
    reason: String
  ) -> CLIError {
    CLIError(
      code: .validationError,
      message: reason,
      details: [
        "criterion": "\(token.key):\(token.value)",
        "supported_criteria": supportedCriteriaDescription,
      ]
    )
  }

  private static var supportedCriteriaDescription: String {
    [
      "flagged:true",
      "priority:low|medium|high",
      "tags:name[,name]",
      "any-tag:true",
      "date:any|today",
      "date-on:YYYY-MM-DD",
      "date-before:YYYY-MM-DD",
      "date-after:YYYY-MM-DD",
      "date-range:YYYY-MM-DD..YYYY-MM-DD",
    ].joined(separator: " ")
  }
}
