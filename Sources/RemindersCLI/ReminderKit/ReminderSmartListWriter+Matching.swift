import Foundation
import ReminderKit
import ReminderKitInternal
import Utility

extension ReminderSmartListWriter {
  static func smartListMatches(_ smartList: REMSmartList, listID: String) -> Bool {
    let candidates = [
      smartList.objectID?.uuid.uuidString,
      smartList.remObjectID?.uuid.uuidString,
      smartList.objectID?.urlRepresentation.absoluteString,
      smartList.remObjectID?.urlRepresentation.absoluteString,
      smartList.name,
    ].compactMap { $0 }
    return candidates.contains { $0.localizedCaseInsensitiveCompare(listID) == .orderedSame }
  }

  static func listMatches(_ list: REMList, listID: String) -> Bool {
    let candidates = [
      list.objectID?.uuid.uuidString,
      list.remObjectID?.uuid.uuidString,
      list.objectID?.urlRepresentation.absoluteString,
      list.remObjectID?.urlRepresentation.absoluteString,
      list.externalIdentifier,
      list.daExternalIdentificationTag,
      list.name,
    ].compactMap { $0 }
    return candidates.contains { $0.localizedCaseInsensitiveCompare(listID) == .orderedSame }
  }

  static func accountMatches(_ account: REMAccount, sourceID: String) -> Bool {
    let candidates = [
      account.objectID?.uuid.uuidString,
      account.remObjectID?.uuid.uuidString,
      account.objectID?.urlRepresentation.absoluteString,
      account.remObjectID?.urlRepresentation.absoluteString,
      account.externalIdentifier,
      account.name,
      account.displayName,
    ].compactMap { $0 }
    return candidates.contains { $0.localizedCaseInsensitiveCompare(sourceID) == .orderedSame }
  }

  static func objectIDsMatch(_ lhs: REMObjectID?, _ rhs: REMObjectID?) -> Bool {
    guard let lhs, let rhs else {
      return lhs == nil && rhs == nil
    }
    return lhs.uuid == rhs.uuid
  }

  static func objectIDBinding(_ objectID: REMObjectID?) -> String? {
    objectID?.uuid.uuidString
  }

  static func normalizedTagKey(_ tag: String?) -> String {
    (tag ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
      .lowercased()
  }

  static func remObjectID(entity: String, identifier: String) -> REMObjectID? {
    let urlString =
      identifier.hasPrefix("x-apple-reminderkit://")
      ? identifier
      : "x-apple-reminderkit://\(entity)/\(identifier)"
    guard let url = URL(string: urlString) else {
      return nil
    }
    return REMObjectID.objectID(withURL: url) as? REMObjectID
  }
}
