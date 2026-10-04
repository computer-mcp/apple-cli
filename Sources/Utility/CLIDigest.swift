import CryptoKit
import Foundation

public func sha256Hex(_ value: String) -> String {
  sha256Hex(Data(value.utf8))
}

public func sha256Hex(_ data: Data) -> String {
  SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}
