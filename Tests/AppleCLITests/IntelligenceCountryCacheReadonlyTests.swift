@testable import IntelligenceCLI
import CryptoKit
import Foundation
import Testing

@Suite(.enabled(
  if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_INTELLIGENCE_COUNTRY_READONLY"] == "1",
  "Requires explicit opt-in to read the host country archive and validate copies in memory."
))
struct IntelligenceCountryCacheReadonlyTests {
  @Test func nativeArchiveSupportsSelectiveCopiesWithoutAnyFileWrite() throws {
    let url = URL(fileURLWithPath: IntelligencePaths().countrydPlist)
    let original = try Data(contentsOf: url)
    for country in ["US", "GB"] {
      let rewrite = try IntelligenceCountryCacheRewrite(data: original, country: country)
      try rewrite.verify(rewrite.updatedData)
      let archive = try #require(
        PropertyListSerialization.propertyList(from: rewrite.updatedData, options: [], format: nil) as? [String: Any])
      let allMatch = try intelligenceCountryArchiveCodes(archive).allSatisfy { $0 == country }
      #expect(allMatch)
    }
    let sameFileDigest = SHA256.hash(data: original) == SHA256.hash(data: try Data(contentsOf: url))
    #expect(sameFileDigest)
  }
}
