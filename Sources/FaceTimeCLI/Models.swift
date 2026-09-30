import AppKit
import Contacts
import CryptoKit
import Foundation
import Utility

public struct FaceTimeHandle: Codable, Equatable, Sendable {
  public var kind: String
  public var value: String

  public init(kind: String, value: String) {
    self.kind = kind
    self.value = value
  }
}

public struct FaceTimeContactCandidate: Codable, Equatable, Sendable {
  public var contactId: String
  public var displayName: String
  public var handles: [FaceTimeHandle]

  public init(contactId: String, displayName: String, handles: [FaceTimeHandle]) {
    self.contactId = contactId
    self.displayName = displayName
    self.handles = handles
  }
}

public struct FaceTimeContactsResponse: Codable, Equatable, Sendable {
  public var contacts: [FaceTimeContactCandidate]
}

public struct FaceTimeCallPreview: Codable, Equatable, Sendable {
  public var handle: String
  public var kind: String
  public var url: String
  public var externalAction: Bool

  public init(handle: String, kind: String, url: String, externalAction: Bool) {
    self.handle = handle
    self.kind = kind
    self.url = url
    self.externalAction = externalAction
  }
}

public struct FaceTimeCallResponse: Codable, Equatable, Sendable {
  public var call: FaceTimeCallPreview
}


public struct FaceTimeCallResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var url: String
}
