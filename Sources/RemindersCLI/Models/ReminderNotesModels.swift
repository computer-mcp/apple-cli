import Foundation

enum ReminderNotesFormat: String, CaseIterable, Codable, Sendable {
  case bold, italic, underline, strikethrough
}

enum ReminderNotesListStyle: String, CaseIterable, Codable, Sendable {
  case plain, bulleted, dashed, numbered

  var nativeValue: UInt32 {
    switch self {
    case .plain: 3
    case .bulleted: 100
    case .dashed: 101
    case .numbered: 102
    }
  }
}

struct ReminderNotesRecord: Codable, Equatable, Sendable {
  struct Run: Codable, Equatable, Sendable {
    var location: Int
    var length: Int
    var bold: Bool
    var italic: Bool
    var underline: Bool
    var strikethrough: Bool
    var link: String?
    var listStyle: ReminderNotesListStyle?
    var indent: UInt64?
  }

  var reminderId: String
  var plainText: String?
  var utf16Length: Int
  var runs: [Run]
}

struct ReminderNotesResponse: Encodable {
  var notes: ReminderNotesRecord
}

struct ReminderNotesMutationResult: Encodable {
  var operation: String
  var changed: Bool
  var verified: Bool
  var reminder: ReminderDetail
  var notes: ReminderNotesRecord
}
