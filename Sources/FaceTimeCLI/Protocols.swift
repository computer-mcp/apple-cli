import AppKit
import Contacts
import CryptoKit
import Foundation
import Utility

public protocol FaceTimeResolving: Sendable {
  func resolveContacts(query: String, limit: Int) throws -> [FaceTimeContactCandidate]
}

public protocol FaceTimeCalling: Sendable {
  func startCall(_ preview: FaceTimeCallPreview) throws -> Bool
}
