import AppKit
import CryptoKit
import Foundation
import Utility

public struct AppKitClipboardBackend: ClipboardAccessing {
  public init() {}

  public func types() -> [String] {
    (NSPasteboard.general.types ?? [])
      .map(\.rawValue)
      .sorted()
  }

  public func readString(preferredType: String?) -> ClipboardReadItem? {
    let type = preferredType.map(NSPasteboard.PasteboardType.init(rawValue:)) ?? .string
    guard let value = NSPasteboard.general.string(forType: type) else {
      return nil
    }
    return ClipboardReadItem(type: type.rawValue, value: value)
  }

  public func stateDigest() -> String {
    let pasteboard = NSPasteboard.general
    let typeDigest = sha256Hex(types().joined(separator: "\n"))
    return "change:\(pasteboard.changeCount):types:\(typeDigest)"
  }

  public func writeText(_ text: String) throws -> Bool {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    return pasteboard.setString(text, forType: .string)
  }

  public func clear() throws -> Bool {
    NSPasteboard.general.clearContents()
    return true
  }
}
