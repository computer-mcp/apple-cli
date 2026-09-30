import Foundation
import Testing

@Suite
struct PhotosOracleFixtureTests {
  @Test func photosOracleFixtureReadmeIsBundledForDefaultTests() throws {
    let resource = Bundle.module.url(
      forResource: "README",
      withExtension: "md",
      subdirectory: "Fixtures/Photos/Oracle"
    )

    #expect(resource != nil)
  }
}
