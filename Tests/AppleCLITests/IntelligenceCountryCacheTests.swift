@testable import IntelligenceCLI
import Foundation
import Testing
import Utility

@Suite
struct IntelligenceCountryCacheTests {
  @Test func sharedEstimatesAreCopiedWithAllExistingNodesPreserved() throws {
    var archive = try intelligenceCountryArchiveFixture()
    var objects = try #require(archive["$objects"] as? [Any])
    var combined = try #require(objects[16] as? [String: Any])
    combined["NS.objects"] = [try intelligenceCountryUID(3), try intelligenceCountryUID(10), try intelligenceCountryUID(3)]
    objects[16] = combined
    archive["$objects"] = objects
    let original = try encodeCountryArchive(archive)
    let rewrite = try IntelligenceCountryCacheRewrite(data: original, country: "US")
    #expect(rewrite.changedEstimateCount == 3)
    try rewrite.verify(rewrite.updatedData)
    let output = try decodeCountryArchive(rewrite.updatedData)
    #expect(try intelligenceCountryArchiveCodes(output) == ["US", "US", "US"])
    #expect(try intelligenceCountryArchiveCodes(output, branch: "LastKnownCombinedEstimate") == ["CN"])
    #expect(try intelligenceCountryArchiveCodes(output, branch: "LocalEstimates") == ["CN"])
    let outputObjects = try #require(output["$objects"] as? [Any])
    // A repeated active reference keeps aliasing the same copied estimate.
    let outputRoot = try intelligenceCountryArchiveRoot(output)
    let collectionIndex = try intelligenceCountryUIDIndex(#require(outputRoot["CombinedEstimate"]))
    let outputCombined = try #require(outputObjects[collectionIndex] as? [String: Any])
    let references = try #require(outputCombined["NS.objects"] as? [Any])
    #expect(try intelligenceCountryUIDIndex(references[0]) == intelligenceCountryUIDIndex(references[2]))
    let restored = NSMutableDictionary(dictionary: output)
    restored["$objects"] = Array(outputObjects.prefix(objects.count))
    restored["$top"] = archive["$top"]
    let restoredArchive = try #require(restored as? [String: Any])
    let restoredValue = try intelligenceCountryArchiveComparable(restoredArchive)
    let originalValue = try intelligenceCountryArchiveComparable(decodeCountryArchive(original))
    #expect(NSDictionary(dictionary: restoredValue).isEqual(to: originalValue))
  }

  @Test func repeatedCountryRequestPreservesExactArchiveBytes() throws {
    let original = try encodeCountryArchive(intelligenceCountryArchiveFixture())
    let first = try IntelligenceCountryCacheRewrite(data: original, country: "US")
    let second = try IntelligenceCountryCacheRewrite(data: first.updatedData, country: "US")
    #expect(second.changedEstimateCount == 0)
    #expect(second.updatedData == first.updatedData)
    try second.verify(second.updatedData)

    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let backend = IntelligenceBackend()
    _ = try backend.enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: true)
    let beforeRepeat = try countryTestSnapshots(paths)
    let repeated = try backend.enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: true)
    #expect(!repeated.changed)
    #expect(try countryTestSnapshots(paths) == beforeRepeat)
  }

  @Test func readbackDetectsHistoryOrUnrelatedChangesEvenWhenActiveCountryMatches() throws {
    let rewrite = try IntelligenceCountryCacheRewrite(
      data: encodeCountryArchive(intelligenceCountryArchiveFixture()), country: "US")
    var changed = try decodeCountryArchive(rewrite.updatedData)
    var objects = try #require(changed["$objects"] as? [Any])
    objects[4] = "GB"
    changed["$objects"] = objects
    #expect(try intelligenceCountryArchiveCodes(changed) == ["US"])
    #expect(throws: CLIError.self) { try rewrite.verify(encodeCountryArchive(changed)) }
  }

  @Test(arguments: InvalidCountryArchive.allCases)
  func invalidArchiveRefusesEntireEnableBeforeBackupOrUnlock(_ kind: InvalidCountryArchive) throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    var archive = try intelligenceCountryArchiveFixture()
    var objects = try #require(archive["$objects"] as? [Any])
    var cached = try #require(objects[1] as? [String: Any])
    var combined = try #require(objects[16] as? [String: Any])
    switch kind {
    case .version: cached["Version"] = 6
    case .booleanVersion: cached["Version"] = true
    case .archiver: archive["$archiver"] = "UnknownArchiver"
    case .className: objects[20] = ["$classname": "Other", "$classes": ["Other", "NSObject"]]
    case .activeClass: combined["$class"] = try intelligenceCountryUID(19)
    case .dangling: combined["NS.objects"] = [try intelligenceCountryUID(100_000)]
    case .cycle: objects[21] = ["loop": try intelligenceCountryUID(21)]
    case .fakeUID: archive["$top"] = ["root": ["CF$UID": 1]]
    case .nullActive: cached["CombinedEstimate"] = try intelligenceCountryUID(0)
    case .empty: combined["NS.objects"] = []
    case .missingField:
      var estimate = try #require(objects[3] as? [String: Any])
      estimate.removeValue(forKey: "CountryCode")
      objects[3] = estimate
    case .invalidCountry: objects[4] = "LL/A"
    }
    objects[1] = cached
    objects[16] = combined
    archive["$objects"] = objects
    try encodeCountryArchive(archive).write(to: URL(fileURLWithPath: paths.countrydPlist))
    let original = try countryTestSnapshots(paths)
    let runner = CountryTestRunner()
    let backend = IntelligenceBackend(systemRunner: runner)
    do {
      _ = try backend.enable(
        paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: true, skipLock: false)
      Issue.record("Invalid country archive must be refused before any mutation.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["failure"] == "country_cache_invalid")
    }
    #expect(try countryTestSnapshots(paths) == original)
    #expect(!FileManager.default.fileExists(atPath: paths.stateDir))
    #expect(runner.callCount == 0)
  }

  @Test func missingCountryCannotCreateOrPatchEligibilityFiles() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let before = try Data(contentsOf: URL(fileURLWithPath: paths.eligibilityPlist))
    #expect(throws: CLIError.self) {
      try IntelligenceBackend().enable(
        paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: true, skipLock: true)
    }
    #expect(try Data(contentsOf: URL(fileURLWithPath: paths.eligibilityPlist)) == before)
    #expect(!FileManager.default.fileExists(atPath: paths.stateDir))
  }

  @Test func malformedEligibilityRefusesCountryAndOtherEligibilityBeforeBackup() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    try Data("not a plist".utf8).write(to: URL(fileURLWithPath: paths.osEligibilityPlist))
    let before = try countryTestSnapshots(paths)
    #expect(throws: (any Error).self) {
      try IntelligenceBackend().enable(
        paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: true, skipLock: true)
    }
    #expect(try countryTestSnapshots(paths) == before)
    #expect(!FileManager.default.fileExists(atPath: paths.stateDir))
  }

  @Test(arguments: [false, true])
  func failedWriteRestoresOnlyOperationBytesIncludingWriteThenThrow(_ writeFirst: Bool) throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let before = try countryTestSnapshots(paths)
    let writer = CountryFailureWriter(path: paths.countrydPlist, writeFirst: writeFirst)
    let backend = IntelligenceBackend(cacheWriter: writer)
    let result = try backend.enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: true)
    #expect(result.status == .failed)
    #expect(!result.changed)
    #expect(result.actions.contains { $0.kind == "rollbackRestore" && $0.status == "restored" })
    #expect(try countryTestSnapshots(paths) == before)
    let state = try #require(result.state)
    let manifest = try JSONDecoder().decode(
      IntelligenceStateManifest.self, from: Data(contentsOf: URL(fileURLWithPath: state.manifestPath)))
    #expect(manifest.backups.count == 3)
    for row in manifest.backups {
      #expect(try Data(contentsOf: URL(fileURLWithPath: row.backup)) == before[row.target])
    }
  }

  @Test func concurrentReadbackChangeIsPreservedAndReportedUnconfirmed() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let before = try countryTestSnapshots(paths)
    let concurrent = Data("a concurrent replacement".utf8)
    let backend = IntelligenceBackend(cacheWriter: CountryConcurrentWriter(
      path: paths.countrydPlist, replacement: concurrent))
    let result = try backend.enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: true)
    #expect(result.status == .failed)
    #expect(result.changed)
    #expect(result.actions.contains { $0.kind == "rollbackRestore" && $0.status == "unconfirmed" })
    #expect(try Data(contentsOf: URL(fileURLWithPath: paths.countrydPlist)) == concurrent)
    for path in [paths.eligibilityPlist, paths.osEligibilityPlist] {
      #expect(try Data(contentsOf: URL(fileURLWithPath: path)) == before[path])
    }
  }

  @Test func concurrentChangeAfterUnlockIsNotOverwritten() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let before = try countryTestSnapshots(paths)
    let concurrent = Data("a daemon update after preflight".utf8)
    let runner = CountryTestRunner {
      try concurrent.write(to: URL(fileURLWithPath: paths.countrydPlist), options: .atomic)
    }
    let result = try IntelligenceBackend(systemRunner: runner).enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: false)
    #expect(result.status == .failed)
    #expect(!result.changed)
    #expect(try Data(contentsOf: URL(fileURLWithPath: paths.countrydPlist)) == concurrent)
    for path in [paths.eligibilityPlist, paths.osEligibilityPlist] {
      #expect(try Data(contentsOf: URL(fileURLWithPath: path)) == before[path])
    }
  }

  @Test func explicitRollbackRestoresExactCountryArchiveAndEligibility() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let before = try countryTestSnapshots(paths)
    let backend = IntelligenceBackend()
    _ = try backend.enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: true)
    _ = try backend.rollback(paths: paths, stateID: "latest", skipLock: true)
    #expect(try countryTestSnapshots(paths) == before)
  }

  @Test func failedEnableRemovesOnlyItsNewlyCreatedCache() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    try FileManager.default.removeItem(atPath: paths.osEligibilityPlist)
    let before = try Data(contentsOf: URL(fileURLWithPath: paths.eligibilityPlist))
    let countryBefore = try Data(contentsOf: URL(fileURLWithPath: paths.countrydPlist))
    let backend = IntelligenceBackend(cacheWriter: CountryFailureWriter(path: paths.countrydPlist, writeFirst: false))
    let result = try backend.enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: true, skipLock: true)
    #expect(result.status == .failed)
    #expect(!result.changed)
    #expect(!FileManager.default.fileExists(atPath: paths.osEligibilityPlist))
    #expect(try Data(contentsOf: URL(fileURLWithPath: paths.eligibilityPlist)) == before)
    #expect(try Data(contentsOf: URL(fileURLWithPath: paths.countrydPlist)) == countryBefore)
  }

  @Test func corruptedBackupRefusesAllRestoresBeforeUnlock() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let paths = IntelligencePaths(root: root.path, stateDir: root.appendingPathComponent("state").path)
    let result = try IntelligenceBackend().enable(
      paths: paths, patchScope: .comprehensive, eligibilityCountry: "US", createMissing: false, skipLock: true)
    let state = try #require(result.state)
    let manifest = try JSONDecoder().decode(
      IntelligenceStateManifest.self, from: Data(contentsOf: URL(fileURLWithPath: state.manifestPath)))
    let countryBackup = try #require(manifest.backups.first { $0.target == paths.countrydPlist })
    try Data("corrupt backup".utf8).write(to: URL(fileURLWithPath: countryBackup.backup))
    let before = try countryTestSnapshots(paths)
    let runner = CountryTestRunner()
    do {
      _ = try IntelligenceBackend(systemRunner: runner).rollback(paths: paths, stateID: "latest", skipLock: false)
      Issue.record("Corrupt backup must be refused before any restore.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["failure"] == "backup_digest_mismatch")
    }
    #expect(runner.callCount == 0)
    #expect(try countryTestSnapshots(paths) == before)
  }
}

enum InvalidCountryArchive: CaseIterable, Sendable {
  case version, booleanVersion, archiver, className, activeClass, dangling, cycle, fakeUID
  case nullActive, empty, missingField, invalidCountry
}

private func encodeCountryArchive(_ archive: [String: Any]) throws -> Data {
  try PropertyListSerialization.data(fromPropertyList: archive, format: .binary, options: 0)
}

private func decodeCountryArchive(_ data: Data) throws -> [String: Any] {
  try #require(PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any])
}

private func countryTestSnapshots(_ paths: IntelligencePaths) throws -> [String: Data] {
  try Dictionary(uniqueKeysWithValues: [paths.eligibilityPlist, paths.osEligibilityPlist, paths.countrydPlist].map {
    ($0, try Data(contentsOf: URL(fileURLWithPath: $0)))
  })
}

private final class CountryFailureWriter: IntelligenceCacheFileWriting {
  let path: String
  let writeFirst: Bool
  private var failed = false

  init(path: String, writeFirst: Bool) { self.path = path; self.writeFirst = writeFirst }
  func write(_ data: Data, to url: URL) throws {
    if url.path == path && !failed {
      failed = true
      if writeFirst { try data.write(to: url, options: .atomic) }
      throw CocoaError(.fileWriteUnknown)
    }
    try data.write(to: url, options: .atomic)
  }
}

private struct CountryConcurrentWriter: IntelligenceCacheFileWriting {
  let path: String
  let replacement: Data
  func write(_ data: Data, to url: URL) throws {
    try data.write(to: url, options: .atomic)
    if url.path == path { try replacement.write(to: url, options: .atomic) }
  }
}

private final class CountryTestRunner: IntelligenceSystemActionRunning, @unchecked Sendable {
  private let lock = NSLock()
  private var calls = 0
  private let firstUnlock: (@Sendable () throws -> Void)?
  var callCount: Int { lock.withLock { calls } }
  init(firstUnlock: (@Sendable () throws -> Void)? = nil) { self.firstUnlock = firstUnlock }
  func run(
    _ executable: CLISubprocess.Executable, arguments: [String], timeout: Int,
    kind: String, path: String?, mechanism: IntelligenceMechanism
  ) -> IntelligenceActionResult {
    let first = lock.withLock { calls += 1; return calls == 1 }
    do {
      if first && kind == "unlock" { try firstUnlock?() }
      return IntelligenceActionResult(kind: kind, status: "succeeded", path: path, mechanism: mechanism.rawValue)
    } catch {
      return IntelligenceActionResult(kind: kind, status: "failed", path: path, mechanism: mechanism.rawValue)
    }
  }
}
