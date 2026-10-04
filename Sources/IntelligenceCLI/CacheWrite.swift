import Foundation
import Utility

protocol IntelligenceCacheFileWriting {
  func write(_ data: Data, to url: URL) throws
}

struct IntelligenceAtomicCacheWriter: IntelligenceCacheFileWriting {
  func write(_ data: Data, to url: URL) throws { try data.write(to: url, options: .atomic) }
}

struct IntelligencePreparedCacheWrite {
  let path: String
  let originalData: Data?
  let updatedData: Data
  let actions: [IntelligenceActionResult]
  let countryRewrite: IntelligenceCountryCacheRewrite?

  func matchesOriginal() throws -> Bool {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: path) else { return originalData == nil }
    return try Data(contentsOf: url) == originalData
  }

  func requireOriginal() throws {
    guard try matchesOriginal() else {
      throw intelligenceError(
        code: .unsafeMutationRefused, failure: .cacheChangedSincePreflight, details: ["path": path])
    }
  }

  func verifyReadback(_ data: Data) throws {
    if let countryRewrite { try countryRewrite.verify(data) }
    guard data == updatedData else {
      throw intelligenceError(
        code: .backendUnavailable, failure: .cacheVerificationFailed,
        details: ["path": path, "verification": "unconfirmed"])
    }
  }
}
