import Foundation
import Utility

extension RemindersSQLiteReader {
  func sqliteJSONRows(storePath: String, sql: String) throws -> [[String: Any]] {
    let result = try CLISubprocess.run(
      .path("/usr/bin/sqlite3"),
      arguments: ["-readonly", "-json", storePath, sql],
      timeoutSeconds: 5,
      outputLimit: 256 * 1024
    )
    guard result.exitCode == 0 else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Read-only Reminders SQLite query failed.",
        details: [
          "store_path": storePath,
          "exit_code": "\(result.exitCode)",
          "stderr": result.stderr,
        ]
      )
    }

    let trimmed = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return []
    }

    let data = Data(trimmed.utf8)
    guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Read-only Reminders SQLite query did not return JSON rows.",
        details: ["store_path": storePath]
      )
    }
    return rows
  }

  func sqliteStringLiteral(_ value: String) -> String {
    "'\(value.replacingOccurrences(of: "'", with: "''"))'"
  }

  func sqliteIdentifier(_ value: String) -> String {
    "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
  }

  func normalizedLookup(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
      .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
  }

  func identifiersEqual(_ lhs: String, _ rhs: String) -> Bool {
    normalizedIdentifier(lhs) == normalizedIdentifier(rhs)
  }

  func normalizedIdentifier(_ value: String) -> String {
    value.replacingOccurrences(of: "-", with: "").lowercased()
  }

  func uuidStringFromSQLiteHex(_ value: String?) -> String? {
    guard let value = emptyToNil(value) else {
      return nil
    }
    let hex = value.replacingOccurrences(of: "-", with: "").lowercased()
    guard hex.count == 32 else {
      return value.uppercased()
    }
    let chars = Array(hex)
    func slice(_ range: Range<Int>) -> String {
      String(chars[range])
    }
    return [
      slice(0..<8),
      slice(8..<12),
      slice(12..<16),
      slice(16..<20),
      slice(20..<32),
    ].joined(separator: "-").uppercased()
  }

  func stringValue(_ value: Any?) -> String? {
    switch value {
    case let string as String:
      return string
    case let number as NSNumber:
      return number.stringValue
    default:
      return nil
    }
  }

  func int64Value(_ value: Any?) -> Int64? {
    switch value {
    case let number as NSNumber:
      return number.int64Value
    case let string as String:
      return Int64(string)
    default:
      return nil
    }
  }

  func intValue(_ value: Any?) -> Int? {
    int64Value(value).map(Int.init)
  }

  func doubleValue(_ value: Any?) -> Double? {
    switch value {
    case let number as NSNumber:
      return number.doubleValue
    case let string as String:
      return Double(string)
    default:
      return nil
    }
  }

  func boolValue(_ value: Any?) -> Bool? {
    switch value {
    case let number as NSNumber:
      return number.intValue != 0
    case let string as String:
      if let int = Int(string) {
        return int != 0
      }
      return nil
    default:
      return nil
    }
  }

  func emptyToNil(_ value: String?) -> String? {
    guard let value, !value.isEmpty else {
      return nil
    }
    return value
  }

  func privateListOrderingIndexes(storePath: String) -> [String: Int] {
    let rows: [[String: Any]]
    do {
      rows = try sqliteJSONRows(
        storePath: storePath,
        sql: """
          select hex(ZORDEREDIDENTIFIERMAP) as ordered_identifier_map
          from ZREMCDACCOUNTLISTDATA
          where ZORDEREDIDENTIFIERMAP is not null;
          """
      )
    } catch {
      return [:]
    }
    var indexes: [String: Int] = [:]
    for row in rows {
      guard let hex = emptyToNil(stringValue(row["ordered_identifier_map"])),
        let data = dataFromHexString(hex)
      else {
        continue
      }
      let identifiers = orderedIdentifiers(fromKeyedArchiveData: data)
      for (index, identifier) in identifiers.enumerated() where indexes[identifier] == nil {
        indexes[identifier] = index
      }
    }
    return indexes
  }

  func privateListDisplayOrder(
    row: [String: Any],
    orderingIndexes: [String: Int]
  ) -> Int? {
    let storedDisplayOrder = intValue(row["display_order"])
    if let storedDisplayOrder, storedDisplayOrder != 0 {
      return storedDisplayOrder
    }

    for identifier in [
      emptyToNil(stringValue(row["ck_identifier"])),
      emptyToNil(stringValue(row["external_identifier"])),
    ].compactMap({ $0?.uppercased() }) {
      if let orderingIndex = orderingIndexes[identifier] {
        return orderingIndex
      }
    }

    return storedDisplayOrder
  }

  func orderedIdentifiers(fromKeyedArchiveData data: Data) -> [String] {
    guard
      let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
      let archive = plist as? [String: Any],
      let objects = archive["$objects"] as? [Any],
      let top = archive["$top"] as? [String: Any],
      let rootIndex = keyedArchiveUIDValue(top["root"]),
      objects.indices.contains(rootIndex),
      let root = objects[rootIndex] as? [String: Any],
      let identifiersIndex = keyedArchiveUIDValue(root["orderedIdentifiers"]),
      objects.indices.contains(identifiersIndex),
      let identifiersContainer = objects[identifiersIndex] as? [String: Any],
      let identifierUIDs = identifiersContainer["NS.objects"] as? [Any]
    else {
      return []
    }

    return identifierUIDs.compactMap { uid in
      guard let index = keyedArchiveUIDValue(uid), objects.indices.contains(index) else {
        return nil
      }
      return (objects[index] as? String)?.uppercased()
    }
  }

  func keyedArchiveUIDValue(_ value: Any?) -> Int? {
    guard let value else {
      return nil
    }
    let description = String(describing: value)
    guard let range = description.range(of: "value = ") else {
      return nil
    }
    let digits = description[range.upperBound...].prefix { $0.isNumber }
    return Int(digits)
  }

  func dataFromHexString(_ value: String) -> Data? {
    let scalars = Array(value.trimmingCharacters(in: .whitespacesAndNewlines).unicodeScalars)
    guard scalars.count.isMultiple(of: 2) else {
      return nil
    }

    var data = Data()
    data.reserveCapacity(scalars.count / 2)
    var index = 0
    while index < scalars.count {
      let byteString = String(String.UnicodeScalarView([scalars[index], scalars[index + 1]]))
      guard let byte = UInt8(byteString, radix: 16) else {
        return nil
      }
      data.append(byte)
      index += 2
    }
    return data
  }
}
