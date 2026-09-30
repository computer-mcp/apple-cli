import AppKit
import CryptoKit
import Foundation
import Utility

public protocol ClipboardAccessing: Sendable {
  func types() -> [String]
  func readString(preferredType: String?) -> ClipboardReadItem?
  func stateDigest() -> String
  func writeText(_ text: String) throws -> Bool
  func clear() throws -> Bool
}
