import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func objectIDBinding(_ objectID: REMObjectID?) -> String? {
    objectID?.uuid.uuidString
  }

  static func normalizedTagKey(_ tag: String?) -> String {
    (tag ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
      .lowercased()
  }

}
