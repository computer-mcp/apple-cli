import AppKit
import CryptoKit
import Foundation
import Utility

public struct ClipboardReadItem: Codable, Equatable, Sendable {
  public var type: String
  public var value: String

  public init(type: String, value: String) {
    self.type = type
    self.value = value
  }
}

public struct ClipboardTypesResponse: Codable, Equatable, Sendable {
  public var types: [String]
}

public struct ClipboardReadResponse: Codable, Equatable, Sendable {
  public var item: ClipboardReadItem?
  public var sensitive: Bool
}


public struct ClipboardMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
}
