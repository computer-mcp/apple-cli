import AppKit
import Contacts
import CryptoKit
import Foundation
import Utility

public struct ContactsFaceTimeResolver: FaceTimeResolving {
  public init() {}

  public func resolveContacts(query: String, limit: Int) throws -> [FaceTimeContactCandidate] {
    let store = try contactStoreWithReadAccess()
    let request = CNContactFetchRequest(keysToFetch: contactKeys())
    request.sortOrder = .userDefault

    var results: [FaceTimeContactCandidate] = []
    try store.enumerateContacts(with: request) { contact, stop in
      guard contactMatches(contact, query: query) else {
        return
      }

      let handles = faceTimeHandles(contact)
      guard !handles.isEmpty else {
        return
      }

      results.append(
        FaceTimeContactCandidate(
          contactId: contact.identifier,
          displayName: displayName(contact),
          handles: handles
        )
      )

      if results.count >= limit {
        stop.pointee = true
      }
    }

    return results
  }
}

public struct NSWorkspaceFaceTimeCaller: FaceTimeCalling {
  public init() {}

  public func startCall(_ preview: FaceTimeCallPreview) throws -> Bool {
    guard let url = URL(string: preview.url) else {
      throw CLIError(code: .internalError, message: "Prepared FaceTime URL is invalid.")
    }

    return NSWorkspace.shared.open(url)
  }
}
