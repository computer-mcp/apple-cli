import Darwin
import Foundation
import Testing
import Utility

@Suite struct NativeFixtureSupportTests {
  private let host = NativeFixtureManifest.Host(userID: 1001, osVersion: "1.2.3", osBuild: "fixture-build", architecture: "arm64")

  private func manifest() -> NativeFixtureManifest {
    let id = UUID()
    return NativeFixtureManifest(schemaVersion: 1, runID: id, host: host,
      evidenceDirectory: "/native-fixtures/\(id.uuidString.lowercased())",
      notes: .init(accountID: "x-coredata://fixture/ICAccount/p1", containerID: "x-coredata://fixture/ICFolder/p2", appVersion: "6.0", appBuild: "1"),
      reminders: .init(accountID: "x-apple-reminderkit://account/uuid1", containerID: "x-apple-reminderkit://list/uuid2", appVersion: "8.0", appBuild: "1"))
  }

  @Test func configuredScopesBindToExactHostAndTarget() throws {
    let value = manifest()
    try value.validate(target: "notes", host: host)
    try value.validate(target: "reminders", host: host)
    #expect(value.marker.contains(value.runID.uuidString.lowercased()))
  }

  @Test func missingOptInNeverReadsManifest() throws {
    expectRefused("mutation_opt_in_required") {
      _ = try NativeFixtureManifest.load(environment: [:], target: "notes", host: host)
    }
    expectRefused("fixture_manifest_required") {
      _ = try NativeFixtureManifest.load(environment: ["APPLE_CLI_RUN_NOTES_MUTATION_TESTS": "1"],
        target: "notes", host: host)
    }
  }

  @Test func staleHostAndInvalidScopesAreRefused() throws {
    var value = manifest()
    value.host.userID += 1
    expectRefused("fixture_host_mismatch") { try value.validate(target: "notes", host: host) }
    value = manifest()
    value.host.osBuild = "other-build"
    expectRefused("fixture_host_mismatch") { try value.validate(target: "notes", host: host) }
    value = manifest()
    value.schemaVersion = 2
    expectRefused("manifest_schema_unsupported") { try value.validate(target: "notes", host: host) }
    value = manifest()
    value.notes = nil
    expectRefused("notes_scope_required") { try value.validate(target: "notes", host: host) }
    value = manifest()
    value.notes?.containerID = "Today"
    expectRefused("notes_exact_id_required") { try value.validate(target: "notes", host: host) }
    value = manifest()
    value.reminders?.containerID = ""
    expectRefused("fixture_scope_invalid") { try value.validate(target: "reminders", host: host) }
    value = manifest()
    let sourceID = value.reminders!.accountID
    value.reminders?.containerID = sourceID
    expectRefused("fixture_scope_invalid") { try value.validate(target: "reminders", host: host) }
    value = manifest()
    value.evidenceDirectory = "/different-run"
    expectRefused("evidence_directory_invalid") { try value.validate(target: "notes", host: host) }
    expectRefused("fixture_target_unsupported") { try manifest().validate(target: "mail", host: host) }
  }

  @Test func ledgerRejectsUnownedOrMovedObjects() throws {
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    try ledger.register(id: "new-note", title: ledger.intentTitle, containerID: "folder")
    try ledger.requireOwned(id: "new-note", title: ledger.intentTitle, containerID: "folder")
    expectRefused("cleanup_object_not_owned") {
      try ledger.requireOwned(id: "personal-note", title: ledger.intentTitle, containerID: "folder")
    }
    expectRefused("cleanup_object_not_owned") {
      try ledger.requireOwned(id: "new-note", title: "Changed by user", containerID: "folder")
    }
    expectRefused("cleanup_object_not_owned") {
      try ledger.requireOwned(id: "new-note", title: ledger.intentTitle, containerID: "other-folder")
    }
    expectRefused("created_object_scope_mismatch") {
      try ledger.register(id: "another", title: "Personal", containerID: "folder")
    }
    try ledger.markCleaned("new-note")
    expectRefused("cleanup_object_not_owned") {
      try ledger.requireOwned(id: "new-note", title: ledger.intentTitle, containerID: "folder")
    }
  }

  @Test func renameIntentOwnsOnlyTheExactOldOrRecordedNewTitle() throws {
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / original")
    try ledger.register(id: "note", title: ledger.intentTitle, containerID: "folder")
    let renamed = value.marker + " / renamed"
    try ledger.beginRename(id: "note", title: renamed)
    try ledger.requireOwned(id: "note", title: ledger.intentTitle, containerID: "folder")
    try ledger.requireOwned(id: "note", title: renamed, containerID: "folder")
    #expect(throws: CLIError.self) {
      try ledger.requireOwned(id: "note", title: value.marker + " / unrelated", containerID: "folder")
    }
    #expect(throws: CLIError.self) {
      try ledger.requireOwned(id: "note", title: renamed, containerID: "other-folder")
    }
    #expect(try JSONDecoder().decode(NativeFixtureLedger.self,
      from: JSONEncoder().encode(ledger)) == ledger)
    #expect(throws: CLIError.self) { try ledger.completeRename(id: "note", title: "Unexpected") }
    try ledger.completeRename(id: "note", title: renamed)
    #expect(ledger.objects.first?.title == renamed)
    #expect(ledger.objects.first?.pendingTitle == nil)
    #expect(throws: CLIError.self) {
      try ledger.requireOwned(id: "note", title: ledger.intentTitle, containerID: "folder")
    }
    try ledger.markCleaned("note")
    #expect(throws: CLIError.self) { try ledger.beginRename(id: "note", title: value.marker + " / later") }
  }

  @Test func renameIntentRejectsUnownedObjectsAndForeignTitles() throws {
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / original")
    try ledger.register(id: "note", title: ledger.intentTitle, containerID: "folder")
    #expect(throws: CLIError.self) { try ledger.beginRename(id: "foreign", title: value.marker + " / next") }
    #expect(throws: CLIError.self) { try ledger.beginRename(id: "note", title: "Personal title") }
    #expect(throws: CLIError.self) { try ledger.beginRename(id: "note", title: ledger.intentTitle) }
    #expect(ledger.objects.first?.pendingTitle == nil)
    try ledger.beginRename(id: "note", title: value.marker + " / next")
    #expect(throws: CLIError.self) { try ledger.beginRename(id: "note", title: value.marker + " / other") }
  }

  @Test func commandResultNeedsBothExitSuccessAndSuccessfulEnvelope() throws {
    let success = NativeFixtureCLI { _ in .init(exitCode: 0, stdout: "{\"ok\":true,\"data\":{\"value\":42}}", stderr: "") }
    #expect(try success.data(["notes", "read"])["value"] as? Int == 42)
    for (exit, stdout) in [(Int32(7), "{\"ok\":true,\"data\":{}}"), (0, "{\"ok\":false,\"data\":{}}"),
      (0, "{\"ok\":true}"), (0, "{\"ok\":true,\"data\":null}")] {
      let cli = NativeFixtureCLI { _ in .init(exitCode: exit, stdout: stdout, stderr: "private diagnostic") }
      do { _ = try cli.data(["notes", "read"]); Issue.record("Invalid command result was accepted.") }
      catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
        #expect(!error.details.values.contains("private diagnostic"))
      }
    }
  }

  @Test func onlyMatchingNotFoundExitAndEnvelopeProveAbsence() throws {
    let absent = NativeFixtureCLI { _ in
      .init(exitCode: CLIErrorCode.notFound.exitCode,
        stdout: "{\"ok\":false,\"error\":{\"code\":\"not_found\"}}", stderr: "")
    }
    #expect(try absent.dataOrNotFound(["notes", "search"]) == nil)
    for (exit, stdout) in [(Int32(0), "{\"ok\":false,\"error\":{\"code\":\"not_found\"}}"),
      (7, "{\"ok\":false,\"error\":{\"code\":\"not_found\"}}"),
      (5, "{\"ok\":false,\"error\":{\"code\":\"permission_denied\"}}"),
      (5, "{\"ok\":true,\"error\":{\"code\":\"not_found\"}}"), (5, "not JSON")] {
      let cli = NativeFixtureCLI { _ in .init(exitCode: exit, stdout: stdout, stderr: "") }
      #expect(throws: CLIError.self) { _ = try cli.dataOrNotFound(["notes", "search"]) }
    }
    #expect(throws: CLIError.self) { _ = try absent.data(["notes", "search"]) }
  }

  @Test func operationAndCleanupFailuresRemainIndependentlyRecorded() throws {
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    try ledger.register(id: "fixture-note", title: ledger.intentTitle, containerID: "folder")
    ledger.recordOperationFailure(NativeFixtureManifest.refused("fixture_object_not_in_container"))
    ledger.recordCleanupFailure(CLIError(code: .permissionDenied, message: "private diagnostic"))
    #expect(ledger.status == "cleanup_failed")
    #expect(ledger.operationFailure?.code == "unsafe_mutation_refused")
    #expect(ledger.operationFailure?.reason == "fixture_object_not_in_container")
    #expect(ledger.cleanupFailure?.code == "permission_denied")
    #expect(ledger.objects.first?.cleaned == false)
    let data = try JSONEncoder().encode(ledger)
    #expect(!String(decoding: data, as: UTF8.self).contains("private diagnostic"))
    #expect(try JSONDecoder().decode(NativeFixtureLedger.self, from: data) == ledger)
  }

  @Test func evidenceSnapshotsAreExclusiveAndBindPhaseToRun() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }
    let value = manifest()
    let evidence = NativeFixtureEvidence(runID: value.runID, target: "notes", directory: root)
    try evidence.record("before", value: ["body": "Unicode 👩🏽‍💻 e\u{301}"])
    let path = root.appendingPathComponent("before.json")
    let original = try Data(contentsOf: path)
    let snapshot = try #require(try JSONSerialization.jsonObject(with: original) as? [String: Any])
    #expect(snapshot["runID"] as? String == value.runID.uuidString)
    #expect(snapshot["phase"] as? String == "before")
    #expect(snapshot["target"] as? String == "notes")
    #expect(throws: (any Error).self) { try evidence.record("before", value: ["body": "replacement"]) }
    #expect(try Data(contentsOf: path) == original)
    expectRefused("evidence_phase_invalid") { try evidence.record("../outside", value: "unowned") }
    try evidence.recordJSON("command", value: ["changed": false, "count": 1])
    let command = try #require(try JSONSerialization.jsonObject(
      with: Data(contentsOf: root.appendingPathComponent("command.json"))) as? [String: Any])
    #expect((command["value"] as? [String: Any])?["changed"] as? Bool == false)
  }

  @Test func failedCommandsKeepPrivateStreamsWithoutExposingThemInErrors() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }
    let value = manifest()
    let evidence = NativeFixtureEvidence(runID: value.runID, target: "notes", directory: root)
    let cli = NativeFixtureCLI { _ in
      .init(exitCode: 70, stdout: "private output", stderr: "native failure details")
    }.recording(to: evidence)
    do {
      _ = try cli.data(["notes", "read", "--id", "owned-id"])
      Issue.record("An unsuccessful command was accepted.")
    } catch let error as CLIError {
      #expect(error.code == .backendUnavailable)
      #expect(error.details["exit_code"] == "70")
      #expect(!error.details.values.contains("private output"))
      #expect(!error.details.values.contains("native failure details"))
    }
    let snapshot = try #require(try JSONSerialization.jsonObject(
      with: Data(contentsOf: root.appendingPathComponent("command-1.json"))) as? [String: Any])
    let receipt = try #require(snapshot["value"] as? [String: Any])
    #expect(receipt["stdout"] as? String == "private output")
    #expect(receipt["stderr"] as? String == "native failure details")
    #expect(receipt["exitCode"] as? Int == 70)
    #expect(receipt["arguments"] as? [String] == ["notes", "read", "--id", "owned-id", "--json"])
  }

  @Test func noteCleanupRequiresOwnedIdentityBeforeDispatch() throws {
    let value = manifest()
    let ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    let cli = NativeFixtureCLI { _ in
      Issue.record("Cleanup dispatched for an unowned object.")
      throw NativeFixtureManifest.refused("unexpected_dispatch")
    }
    expectRefused("cleanup_object_not_owned") {
      try NativeNoteFixtureCleanup.purge(.init(id: "personal", title: ledger.intentTitle,
        containerID: "folder"), ledger: ledger, cli: cli)
    }
    var owned = ledger
    try owned.register(id: "fixture", title: owned.intentTitle, containerID: "folder")
    let changed = NativeFixtureCLI { _ in
      .init(exitCode: 0, stdout: "{\"ok\":true,\"data\":{\"notes\":[{\"id\":\"fixture\",\"title\":\"Changed\"}]}}", stderr: "")
    }
    expectRefused("trashed_note_identity_unverified") {
      try NativeNoteFixtureCleanup.purge(owned.objects[0], ledger: owned, cli: changed)
    }
  }

  @Test(arguments: [true, false])
  func noteCleanupProvesAbsenceWithExactColdRead(notFound: Bool) throws {
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    try ledger.register(id: "fixture", title: ledger.intentTitle, containerID: "folder")
    let before = try JSONSerialization.data(withJSONObject: ["ok": true,
      "data": ["notes": [["id": "fixture", "title": ledger.intentTitle]]]])
    let script = NativeFixtureScript(results: [
      .init(exitCode: 0, stdout: String(decoding: before, as: UTF8.self), stderr: ""),
      .init(exitCode: 0, stdout: "{\"ok\":true,\"data\":{\"changed\":true}}", stderr: ""),
      .init(exitCode: notFound ? 5 : 0, stdout: notFound
        ? "{\"ok\":false,\"error\":{\"code\":\"not_found\"}}"
        : "{\"ok\":true,\"data\":{\"notes\":[]}}", stderr: "")])
    try NativeNoteFixtureCleanup.purge(ledger.objects[0], ledger: ledger,
      cli: NativeFixtureCLI(invoke: script.invoke))
    let arguments = script.recordedArguments
    #expect(arguments.count == 3)
    #expect(arguments.first == arguments.last)
    #expect(arguments.allSatisfy { $0.contains("--id") && !$0.contains("--account") && !$0.contains("--folder") })
    #expect(arguments[1].contains("--allow-destructive-selection"))
  }

  @Test func noteCleanupRejectsUnknownReadbackAfterPurge() throws {
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    try ledger.register(id: "fixture", title: ledger.intentTitle, containerID: "folder")
    let before = try JSONSerialization.data(withJSONObject: ["ok": true,
      "data": ["notes": [["id": "fixture", "title": ledger.intentTitle]]]])
    let script = NativeFixtureScript(results: [
      .init(exitCode: 0, stdout: String(decoding: before, as: UTF8.self), stderr: ""),
      .init(exitCode: 0, stdout: "{\"ok\":true,\"data\":{}}", stderr: ""),
      .init(exitCode: 3, stdout: "{\"ok\":false,\"error\":{\"code\":\"permission_denied\"}}", stderr: "")])
    #expect(throws: CLIError.self) {
      try NativeNoteFixtureCleanup.purge(ledger.objects[0], ledger: ledger,
        cli: NativeFixtureCLI(invoke: script.invoke))
    }
    #expect(ledger.objects[0].cleaned == false)
  }

  @Test func ledgerPersistenceCannotReplaceAnotherRun() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }
    let path = root.appendingPathComponent("ledger.json")
    let value = manifest()
    var ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    try ledger.persist(to: path)
    let original = try Data(contentsOf: path)
    ledger.runID = UUID()
    expectRefused("ledger_owner_mismatch") { try ledger.persist(to: path) }
    #expect(try Data(contentsOf: path) == original)
  }

  @Test func manifestFilesAreBoundedRegularInputs() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }
    let path = root.appendingPathComponent("manifest.json")
    let value = manifest()
    try JSONEncoder().encode(value).write(to: path)
    let environment = ["APPLE_CLI_RUN_NOTES_MUTATION_TESTS": "1",
      "APPLE_CLI_NATIVE_FIXTURE_MANIFEST": path.path]
    #expect(try NativeFixtureManifest.load(environment: environment, target: "notes", host: host) == value)
    try Data(repeating: 0, count: 65_537).write(to: path)
    expectRefused("manifest_file_invalid") {
      _ = try NativeFixtureManifest.load(environment: environment, target: "notes", host: host)
    }
    try FileManager.default.removeItem(at: path)
    #expect(mkfifo(path.path, 0o600) == 0)
    expectRefused("manifest_file_invalid") {
      _ = try NativeFixtureManifest.load(environment: environment, target: "notes", host: host)
    }
  }

  @Test func runDirectoriesAndDanglingLedgersCannotBeReused() throws {
    let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
      .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }
    var value = manifest()
    value.evidenceDirectory = root.appendingPathComponent(value.runID.uuidString.lowercased()).path
    let url = try nativeFixtureLedgerURL(manifest: value, target: "notes")
    expectRefused("fixture_run_already_exists") {
      _ = try nativeFixtureLedgerURL(manifest: value, target: "notes")
    }
    let destination = root.appendingPathComponent("unowned.json")
    try FileManager.default.createSymbolicLink(at: url, withDestinationURL: destination)
    let ledger = NativeFixtureLedger(runID: value.runID, target: "notes", containerID: "folder",
      marker: value.marker, intentTitle: value.marker + " / body")
    expectRefused("ledger_file_invalid") { try ledger.persist(to: url) }
    #expect(!FileManager.default.fileExists(atPath: destination.path))
    #expect(try FileManager.default.destinationOfSymbolicLink(atPath: url.path) == destination.path)
  }

  private func expectRefused(_ reason: String, operation: () throws -> Void) {
    do { try operation(); Issue.record("Expected native fixture refusal: \(reason)") }
    catch let error as CLIError { #expect(error.details["reason"] == reason) }
    catch { Issue.record("Unexpected refusal type: \(error)") }
  }
}

private final class NativeFixtureScript: @unchecked Sendable {
  private let lock = NSLock()
  private var results: [CLISubprocessResult]
  private var arguments: [[String]] = []

  init(results: [CLISubprocessResult]) { self.results = results }

  func invoke(_ arguments: [String]) throws -> CLISubprocessResult {
    lock.lock()
    defer { lock.unlock() }
    self.arguments.append(arguments)
    guard !results.isEmpty else { throw NativeFixtureManifest.refused("unexpected_dispatch") }
    return results.removeFirst()
  }

  var recordedArguments: [[String]] {
    lock.lock()
    defer { lock.unlock() }
    return arguments
  }
}
