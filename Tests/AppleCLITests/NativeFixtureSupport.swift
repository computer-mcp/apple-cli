import CryptoKit
import Darwin
import Foundation
import Utility

struct NativeFixtureManifest: Codable, Equatable, Sendable {
  struct Host: Codable, Equatable, Sendable {
    var userID: UInt32
    var osVersion: String
    var osBuild: String
    var architecture: String
  }
  struct Scope: Codable, Equatable, Sendable {
    var accountID: String
    var containerID: String
    var appVersion: String
    var appBuild: String
  }
  var schemaVersion: Int
  var runID: UUID
  var host: Host
  var evidenceDirectory: String
  var notes: Scope?
  var reminders: Scope?

  var marker: String { "Apple CLI Fixture \(runID.uuidString.lowercased())" }

  static func load(environment: [String: String], target: String, host: Host) throws -> Self {
    let key = "APPLE_CLI_RUN_\(target.uppercased())_MUTATION_TESTS"
    guard environment[key] == "1" else { throw refused("mutation_opt_in_required") }
    guard let path = environment["APPLE_CLI_NATIVE_FIXTURE_MANIFEST"], path.hasPrefix("/") else {
      throw refused("fixture_manifest_required")
    }
    let attributes = try FileManager.default.attributesOfItem(atPath: path)
    guard attributes[.type] as? FileAttributeType == .typeRegular,
      ((attributes[.size] as? NSNumber)?.intValue ?? Int.max) <= 65_536
    else { throw refused("manifest_file_invalid") }
    let manifest = try JSONDecoder().decode(Self.self, from: Data(contentsOf: URL(fileURLWithPath: path)))
    try manifest.validate(target: target, host: host)
    return manifest
  }

  func validate(target: String, host current: Host) throws {
    guard schemaVersion == 1 else { throw Self.refused("manifest_schema_unsupported") }
    guard host == current else { throw Self.refused("fixture_host_mismatch") }
    guard evidenceDirectory.hasPrefix("/"),
      URL(fileURLWithPath: evidenceDirectory).lastPathComponent == runID.uuidString.lowercased()
    else { throw Self.refused("evidence_directory_invalid") }
    let scope = try self.scope(target)
    guard !scope.accountID.isEmpty, !scope.containerID.isEmpty,
      scope.accountID != scope.containerID,
      ![scope.accountID, scope.containerID].contains(where: { $0 != $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    else { throw Self.refused("fixture_scope_invalid") }
    guard !scope.appVersion.isEmpty, !scope.appBuild.isEmpty else {
      throw Self.refused("fixture_app_version_required")
    }
    let scheme = target == "notes" ? "x-coredata" : "x-apple-reminderkit"
    for id in [scope.accountID, scope.containerID] {
      guard let url = URL(string: id), url.scheme == scheme, url.host != nil else {
        throw Self.refused("\(target)_exact_id_required")
      }
    }
  }

  func scope(_ target: String) throws -> Scope {
    switch target {
    case "notes":
      guard let notes else { throw Self.refused("notes_scope_required") }
      return notes
    case "reminders":
      guard let reminders else { throw Self.refused("reminders_scope_required") }
      return reminders
    default: throw Self.refused("fixture_target_unsupported")
    }
  }

  static func refused(_ reason: String) -> CLIError {
    CLIError(code: .unsafeMutationRefused, message: "Native fixture requirements were not met.",
      details: ["reason": reason])
  }
}

struct NativeFixtureCLI: Sendable {
  var invoke: @Sendable ([String]) throws -> CLISubprocessResult

  init(executable: String) {
    self.invoke = { arguments in
      try CLISubprocess.run(.path(executable), arguments: arguments,
        timeoutSeconds: 20, outputLimit: 2_097_152)
    }
  }

  init(invoke: @escaping @Sendable ([String]) throws -> CLISubprocessResult) {
    self.invoke = invoke
  }

  func recording(to evidence: NativeFixtureEvidence) -> Self {
    let recorder = NativeFixtureCommandRecorder(evidence: evidence)
    let original = invoke
    var copy = self
    copy.invoke = { arguments in
      let result = try original(arguments)
      try recorder.record(arguments: arguments, result: result)
      return result
    }
    return copy
  }

  func data(_ arguments: [String]) throws -> [String: Any] {
    guard let data = try resultData(arguments, allowNotFound: false) else {
      throw NativeFixtureManifest.refused("command_data_missing")
    }
    return data
  }

  func dataOrNotFound(_ arguments: [String]) throws -> [String: Any]? {
    try resultData(arguments, allowNotFound: true)
  }

  private func resultData(_ arguments: [String], allowNotFound: Bool) throws -> [String: Any]? {
    let result = try invoke(arguments + ["--json"])
    if let object = (try? JSONSerialization.jsonObject(with: Data(result.stdout.utf8))) as? [String: Any] {
      if object["ok"] as? Bool == true, result.exitCode == 0,
        let data = object["data"] as? [String: Any] {
        return data
      }
      if allowNotFound, result.exitCode == CLIErrorCode.notFound.exitCode,
        object["ok"] as? Bool == false,
        let error = object["error"] as? [String: Any], error["code"] as? String == CLIErrorCode.notFound.rawValue {
        return nil
      }
    }
    throw CLIError(code: .backendUnavailable, message: "Native fixture command did not succeed.",
      details: ["exit_code": "\(result.exitCode)", "stdout_sha256": nativeFixtureDigest(result.stdout),
        "stderr_sha256": nativeFixtureDigest(result.stderr)])
  }

  func decode<T: Decodable>(_ type: T.Type, arguments: [String], key: String) throws -> T {
    let data = try self.data(arguments)
    guard let value = data[key] else { throw NativeFixtureManifest.refused("command_value_missing") }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(type, from: JSONSerialization.data(withJSONObject: value))
  }
}

struct NativeFixtureLedger: Codable, Equatable, Sendable {
  struct Failure: Codable, Equatable, Sendable {
    var code: String
    var reason: String?
    var diagnosticSHA256: String

    init(_ error: any Error) {
      let cliError = error as? CLIError
      code = cliError?.code.rawValue ?? "validation_failure"
      reason = cliError?.details["reason"]
      diagnosticSHA256 = nativeFixtureDigest(String(describing: error))
    }
  }

  struct Object: Codable, Equatable, Sendable {
    var id: String
    var title: String
    var containerID: String
    var cleaned: Bool = false
    var pendingTitle: String?
  }
  var runID: UUID
  var target: String
  var containerID: String
  var marker: String
  var intentTitle: String
  var objects: [Object] = []
  var status = "prepared"
  var operationFailure: Failure?
  var cleanupFailure: Failure?

  mutating func recordOperationFailure(_ error: any Error) {
    operationFailure = Failure(error)
    status = "operation_failed"
  }

  mutating func recordCleanupFailure(_ error: any Error) {
    cleanupFailure = Failure(error)
    status = "cleanup_failed"
  }

  mutating func register(id: String, title: String, containerID: String) throws {
    guard !id.isEmpty, title == intentTitle, title.hasPrefix(marker + " / "),
      containerID == self.containerID, !objects.contains(where: { $0.id == id }), objects.count < 8
    else { throw NativeFixtureManifest.refused("created_object_scope_mismatch") }
    objects.append(Object(id: id, title: title, containerID: containerID))
  }

  func requireOwned(id: String, title: String, containerID: String) throws {
    guard let object = objects.first(where: { $0.id == id }), !object.cleaned,
      (object.title == title || object.pendingTitle == title), object.containerID == containerID,
      containerID == self.containerID
    else { throw NativeFixtureManifest.refused("cleanup_object_not_owned") }
  }

  mutating func beginRename(id: String, title: String) throws {
    guard let index = objects.firstIndex(where: { $0.id == id }), !objects[index].cleaned,
      objects[index].pendingTitle == nil, title.hasPrefix(marker + " / "),
      !title.utf8.elementsEqual(objects[index].title.utf8)
    else { throw NativeFixtureManifest.refused("rename_intent_not_owned") }
    objects[index].pendingTitle = title
  }

  mutating func completeRename(id: String, title: String) throws {
    guard let index = objects.firstIndex(where: { $0.id == id }), !objects[index].cleaned,
      objects[index].pendingTitle == title
    else { throw NativeFixtureManifest.refused("rename_readback_not_owned") }
    objects[index].title = title
    objects[index].pendingTitle = nil
  }

  mutating func markCleaned(_ id: String) throws {
    guard let index = objects.firstIndex(where: { $0.id == id }) else {
      throw NativeFixtureManifest.refused("cleanup_object_not_owned")
    }
    objects[index].cleaned = true
    objects[index].pendingTitle = nil
  }

  func persist(to url: URL) throws {
    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
    if let attributes {
      guard attributes[.type] as? FileAttributeType == .typeRegular else {
        throw NativeFixtureManifest.refused("ledger_file_invalid")
      }
      let previous = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
      guard previous.runID == runID, previous.target == target, previous.marker == marker,
        previous.containerID == containerID, previous.intentTitle == intentTitle
      else { throw NativeFixtureManifest.refused("ledger_owner_mismatch") }
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(self).write(to: url, options: .atomic)
  }
}

struct NativeFixtureEvidence: Sendable {
  let runID: UUID
  let target: String
  let directory: URL

  private struct Snapshot<Value: Encodable>: Encodable {
    var schemaVersion = 1
    var runID: UUID
    var target: String
    var phase: String
    var capturedAt: Date
    var value: Value
  }

  func record<Value: Encodable>(_ phase: String, value: Value) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let snapshot = Snapshot(runID: runID, target: target, phase: phase, capturedAt: Date(), value: value)
    try write(encoder.encode(snapshot), phase: phase)
  }

  func recordJSON(_ phase: String, value: [String: Any]) throws {
    let snapshot: [String: Any] = ["schemaVersion": 1, "runID": runID.uuidString,
      "target": target, "phase": phase, "capturedAt": ISO8601DateFormatter().string(from: Date()), "value": value]
    try write(JSONSerialization.data(withJSONObject: snapshot, options: [.prettyPrinted, .sortedKeys]), phase: phase)
  }

  private func write(_ data: Data, phase: String) throws {
    guard !phase.isEmpty, phase.utf8.count <= 64,
      phase.utf8.allSatisfy({ (97...122).contains($0) || (48...57).contains($0) || $0 == 45 })
    else { throw NativeFixtureManifest.refused("evidence_phase_invalid") }
    try data.write(to: directory.appendingPathComponent(phase + ".json"), options: .withoutOverwriting)
  }
}

private final class NativeFixtureCommandRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var sequence = 0
  private let evidence: NativeFixtureEvidence

  init(evidence: NativeFixtureEvidence) { self.evidence = evidence }

  func record(arguments: [String], result: CLISubprocessResult) throws {
    lock.lock()
    sequence += 1
    let phase = "command-\(sequence)"
    lock.unlock()
    try evidence.recordJSON(phase, value: ["arguments": arguments, "exitCode": result.exitCode,
      "stdout": result.stdout, "stderr": result.stderr])
  }
}

func nativeFixtureLedgerURL(manifest: NativeFixtureManifest, target: String) throws -> URL {
  let root = URL(fileURLWithPath: manifest.evidenceDirectory)
  guard root.standardizedFileURL.path == root.resolvingSymlinksInPath().path else {
    throw NativeFixtureManifest.refused("evidence_directory_link")
  }
  if !FileManager.default.fileExists(atPath: root.path) {
    guard mkdir(root.path, 0o700) == 0 else {
      throw NativeFixtureManifest.refused("evidence_directory_unavailable")
    }
  }
  let directory = root.appendingPathComponent(target)
  guard mkdir(directory.path, 0o700) == 0 else {
    throw NativeFixtureManifest.refused("fixture_run_already_exists")
  }
  return directory.appendingPathComponent("ledger.json")
}

func nativeFixtureCurrentHost() throws -> NativeFixtureManifest.Host {
  let version = ProcessInfo.processInfo.operatingSystemVersion
  let build = try CLISubprocess.run(.path("/usr/bin/sw_vers"), arguments: ["-buildVersion"],
    timeoutSeconds: 5, outputLimit: 1_024)
  guard build.exitCode == 0 else { throw NativeFixtureManifest.refused("host_build_unavailable") }
  return .init(userID: getuid(), osVersion: "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)",
    osBuild: build.stdout.trimmingCharacters(in: .whitespacesAndNewlines), architecture: nativeFixtureArchitecture())
}

func nativeFixturePackageCLI() -> NativeFixtureCLI {
  let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    .deletingLastPathComponent().deletingLastPathComponent()
  return NativeFixtureCLI(executable: root.appendingPathComponent(".build/debug/apple").path)
}

func nativeFixtureDigest(_ value: String) -> String {
  SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
}

private func nativeFixtureArchitecture() -> String {
  #if arch(arm64)
  return "arm64"
  #elseif arch(x86_64)
  return "x86_64"
  #else
  return "unsupported"
  #endif
}
