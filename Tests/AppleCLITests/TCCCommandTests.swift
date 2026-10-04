import Foundation
import SQLite3
import TCCCLI
import Testing
import Utility

@Suite
struct TCCCommandTests {
  @Test func tccServiceCatalogNormalizesAliasSuffixAndRaw() throws {
    let reminders = try TCCServiceCatalog.resolve("reminders")
    let bySuffix = try TCCServiceCatalog.resolve("Reminders")
    let raw = try TCCServiceCatalog.resolve("kTCCServiceReminders")
    let unknownRaw = try TCCServiceCatalog.resolve("kTCCServiceFutureThing")

    #expect(reminders.rawName == "kTCCServiceReminders")
    #expect(bySuffix.rawName == reminders.rawName)
    #expect(raw.rawName == reminders.rawName)
    #expect(unknownRaw.canonical == false)
    #expect(unknownRaw.rawName == "kTCCServiceFutureThing")
    #expect(TCCServiceCatalog.services.map(\.suffix).contains("SystemPolicyDownloadsFolder"))
    #expect(TCCServiceCatalog.services.map(\.suffix).contains("Willow"))
  }

  @Test func tccClientTypeInferenceUsesBundleIDAndAbsolutePath() throws {
    let bundle = try TCCServiceCatalog.client(from: "com.example.App")
    let path = try TCCServiceCatalog.client(from: "/Applications/Example.app")

    #expect(bundle.clientType == 0)
    #expect(bundle.clientTypeName == .bundleIdentifier)
    #expect(path.clientType == 1)
    #expect(path.clientTypeName == .absolutePath)
  }

  @Test func tccDemoCLIIdentityFixtureCompilesAndResolvesAsPathClient() throws {
    let source = try #require(Bundle.module.url(
      forResource: "TCCDemo",
      withExtension: "swift",
      subdirectory: "Fixtures/TCC"
    ))
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-tcc-demo-\(UUID().uuidString)", isDirectory: true)
    let executable = root.appendingPathComponent("apple-tcc-demo")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let compile = try CLISubprocess.run(
      .name("swiftc"),
      arguments: [source.path, "-o", executable.path],
      timeoutSeconds: 30,
      outputLimit: 256_000
    )
    #expect(compile.exitCode == 0)
    #expect(FileManager.default.isExecutableFile(atPath: executable.path))

    let demoRun = try CLISubprocess.run(
      .path(executable.path),
      arguments: [],
      timeoutSeconds: 10,
      outputLimit: 64_000
    )
    #expect(demoRun.exitCode == 0)
    let demoOutput = try tccJSONObject(demoRun.stdout)
    #expect((demoOutput["executable"] as? String)?.hasSuffix("apple-tcc-demo") == true)
    #expect(demoOutput["accessibilityTrusted"] is Bool)
    #expect(demoOutput["screenCaptureGranted"] is Bool)

    let client = try TCCServiceCatalog.client(from: executable.path)
    #expect(client.clientType == 1)
    #expect(client.clientTypeName == .absolutePath)

    let command = TCCCommand()
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "identity",
      "read",
      "--path",
      executable.path,
      "--json",
    ])))
    let object = try tccJSONObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let identity = try #require(data["identity"] as? [String: Any])

    #expect(identity["path"] as? String == executable.path)
    #expect(identity["bundleIdentifier"] == nil)
    #expect(identity["resolvedBy"] as? String == "path")
    #expect(identity["signatureKind"] as? String == "adhoc")
    #expect((identity["codesignIdentifier"] as? String)?.isEmpty == false)
    #expect((identity["cdHash"] as? String)?.isEmpty == false)
  }

  @Test func tccRecordsListReadsFixtureByNamedColumns() throws {
    let fixture = try TCCDatabaseFixture()
    try fixture.insert(
      service: "kTCCServiceReminders",
      client: "com.example.App",
      clientType: 0,
      authValue: 3,
      authReason: 6
    )
    let command = TCCCommand(database: fixture.backend)
    let options = try CLIOptionsFixture.parse([
      "records",
      "list",
      "Reminders",
      "com.example.App",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try tccJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]] ?? []
    let scoped = try #require(records.first)
    let record = try #require(scoped["record"] as? [String: Any])

    #expect(records.count == 1)
    #expect(record["service"] as? String == "kTCCServiceReminders")
    #expect(record["client"] as? String == "com.example.App")
    #expect(record["authValue"] as? Int == 3)
    #expect(record["authValueDescription"] as? String == "limited")
    #expect(record["authReason"] as? Int == 6)
    #expect(record["authReasonDescription"] as? String == "mdm_policy")
    #expect((record["rowHash"] as? String)?.isEmpty == false)
  }

  @Test func tccRecordsListBothReportsMissingScopeAsIssue() throws {
    let command = TCCCommand()
    let missing = FileManager.default.temporaryDirectory
      .appendingPathComponent("missing-tcc-\(UUID().uuidString).db")
    let options = try CLIOptionsFixture.parse([
      "records",
      "list",
      "Reminders",
      "--scope",
      "both",
      "--database",
      missing.path,
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try tccJSONObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let records = data["records"] as? [[String: Any]] ?? []
    let issues = data["issues"] as? [[String: Any]] ?? []

    #expect(object["ok"] as? Bool == true)
    #expect(records.isEmpty)
    #expect(issues.count == 2)
    #expect(Set(issues.compactMap { $0["scope"] as? String }) == Set(["user", "system"]))
    #expect(Set(issues.compactMap { $0["code"] as? String }) == Set(["not_found"]))
  }

  @Test func tccDatabaseInfoIncludesSchemaDigestAndColumns() throws {
    let fixture = try TCCDatabaseFixture()
    let command = TCCCommand(database: fixture.backend)
    let options = try CLIOptionsFixture.parse([
      "database",
      "info",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try tccJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let databases = data?["databases"] as? [[String: Any]] ?? []
    let info = try #require(databases.first)
    let columns = info["schemaColumns"] as? [String] ?? []

    #expect(info["readable"] as? Bool == true)
    #expect((info["digest"] as? String)?.count == 10)
    #expect(columns.contains("service"))
    #expect(columns.contains("auth_value"))
    #expect(!columns.contains("*"))
  }

  @Test func tccRecordsAddDryRunAndAllowFlagWriteFixture() throws {
    let fixture = try TCCDatabaseFixture()
    let command = TCCCommand(database: fixture.backend)
    let base = [
      "records",
      "add",
      "Reminders",
      "com.example.App",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--backup-dir",
      fixture.backups.path,
      "--json",
    ]

    do {
      _ = try command.run(options: try CLIOptionsFixture.parse(base))
      Issue.record("Expected private TCC DB write without allow flag to fail.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    }

    _ = try #require(
      try command.run(options: try CLIOptionsFixture.parse(base + [
        "--allow-private-tcc-db-write",
        "--dry-run",
      ])))
    let executed = try #require(
      try command.run(options: try CLIOptionsFixture.parse(base + [
        "--allow-private-tcc-db-write",
        "--allow-external-dispatch",
      ])))
    let object = try tccJSONObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])

    #expect(data["changed"] as? Bool == true)
    #expect(data["affectedRows"] as? Int == 1)
    #expect(try fixture.authValue(service: "kTCCServiceReminders", client: "com.example.App") == 2)
    #expect(FileManager.default.fileExists(atPath: fixture.backups.path))
  }

  @Test func tccRecordsMutationLifecycleWritesFixtureAndUniqueBackups() throws {
    let fixture = try TCCDatabaseFixture()
    let command = TCCCommand(database: fixture.backend)

    func args(_ operation: String) -> [String] {
      [
        "records",
        operation,
        "Reminders",
        "com.example.App",
        "--scope",
        "user",
        "--database",
        fixture.database.path,
        "--backup-dir",
        fixture.backups.path,
        "--allow-private-tcc-db-write",
        "--json",
      ]
    }

    let addBackup = try tccExecuteRecordsMutation(command: command, args: args("add"))
    #expect(try fixture.authValue(service: "kTCCServiceReminders", client: "com.example.App") == 2)

    let disableBackup = try tccExecuteRecordsMutation(command: command, args: args("disable"))
    #expect(try fixture.authValue(service: "kTCCServiceReminders", client: "com.example.App") == 0)

    let enableBackup = try tccExecuteRecordsMutation(command: command, args: args("enable"))
    #expect(try fixture.authValue(service: "kTCCServiceReminders", client: "com.example.App") == 2)

    let removeBackup = try tccExecuteRecordsMutation(command: command, args: args("remove"))
    #expect(try fixture.authValue(service: "kTCCServiceReminders", client: "com.example.App") == nil)

    let backupPaths = [addBackup, disableBackup, enableBackup, removeBackup]
    #expect(Set(backupPaths).count == 4)
    #expect(backupPaths.allSatisfy { FileManager.default.fileExists(atPath: $0) })
    #expect(try FileManager.default.contentsOfDirectory(atPath: fixture.backups.path).count == 4)
  }

  @Test func tccRecordsDryRunRejectsStaleRow() throws {
    let fixture = try TCCDatabaseFixture()
    try fixture.insert(
      service: "kTCCServiceReminders",
      client: "com.example.App",
      clientType: 0,
      authValue: 0,
      authReason: 4
    )
    let command = TCCCommand(database: fixture.backend)
    let args = [
      "records",
      "enable",
      "Reminders",
      "com.example.App",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--backup-dir",
      fixture.backups.path,
      "--allow-private-tcc-db-write",
      "--json",
    ]
    _ = try #require(try command.run(options: try CLIOptionsFixture.parse(args + ["--dry-run"])))

    try fixture.setAuthValue(1, service: "kTCCServiceReminders", client: "com.example.App")

    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse(args)))
    let object = try tccJSONObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])

    #expect(data["changed"] as? Bool == true)
    #expect(try fixture.authValue(service: "kTCCServiceReminders", client: "com.example.App") == 2)
  }

  @Test func tccRecordsWriteToReadonlyDatabaseReportsPermissionDenied() throws {
    let fixture = try TCCDatabaseFixture()
    let command = TCCCommand(database: fixture.backend)
    let args = [
      "records",
      "add",
      "Reminders",
      "com.example.App",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--backup-dir",
      fixture.backups.path,
      "--allow-private-tcc-db-write",
      "--json",
    ]
    _ = try #require(try command.run(options: try CLIOptionsFixture.parse(args + ["--dry-run"])))
    try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: fixture.database.path)
    defer {
      try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: fixture.database.path)
    }

    do {
      _ = try command.run(options: try CLIOptionsFixture.parse(args))
      Issue.record("Expected readonly TCC database write to fail.")
    } catch let error as CLIError {
      #expect(error.code == .permissionDenied)
      #expect(error.details["sqlite_error"]?.contains("readonly") == true)
    }
  }

  @Test func tccUnknownRawServiceWriteNeedsExplicitUnknownAllowFlag() throws {
    let fixture = try TCCDatabaseFixture()
    let command = TCCCommand(database: fixture.backend)
    let options = try CLIOptionsFixture.parse([
      "records",
      "add",
      "kTCCServiceFutureThing",
      "com.example.App",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--allow-private-tcc-db-write",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected unknown raw write without unknown-service flag to fail.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    }
  }

  @Test func tccDoctorForTargetMapsTargetWithoutDuplicatingDBLogic() throws {
    let fixture = try TCCDatabaseFixture()
    let command = TCCCommand(database: fixture.backend)
    let options = try CLIOptionsFixture.parse([
      "doctor",
      "--for-target",
      "reminders",
      "--scope",
      "user",
      "--database",
      fixture.database.path,
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try tccJSONObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let mapping = try #require(data["targetMapping"] as? [String: Any])
    let report = try #require(data["report"] as? [String: Any])

    #expect(mapping["target"] as? String == "reminders")
    #expect(mapping["services"] as? [String] == ["Reminders"])
    #expect(report["target"] as? String == "reminders")
  }

  @Test func tccResetRequiresAllowFlagAndUsesServiceSuffix() throws {
    let reset = FakeTCCResetRunner()
    let command = TCCCommand(resetRunner: reset)
    let denied = try CLIOptionsFixture.parse(["reset", "Reminders", "com.example.App", "--json"])

    do {
      _ = try command.run(options: denied)
      Issue.record("Expected reset without allow flag to fail.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    }

    let allowed = try CLIOptionsFixture.parse([
      "reset",
      "Reminders",
      "com.example.App",
      "--allow-tcc-reset",
      "--json",
    ])
    _ = try #require(try command.run(options: allowed))

    #expect(reset.calls == [FakeTCCResetRunner.Call(service: "Reminders", client: "com.example.App")])
  }

  @Test func tccFrameworkMutationRequiresAllowAndDryRun() throws {
    let framework = FakeTCCFramework()
    let command = TCCCommand(framework: framework)
    let args = [
      "framework",
      "add",
      "Reminders",
      "com.example.App",
      "--allow-private-tcc-framework-write",
      "--json",
    ]

    do {
      _ = try command.run(options: try CLIOptionsFixture.parse(Array(args.dropLast(2)) + ["--json"]))
      Issue.record("Expected framework mutation without allow flag to fail.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    }

    _ = try #require(try command.run(options: try CLIOptionsFixture.parse(args + ["--dry-run"])))
    let result = try #require(
      try command.run(options: try CLIOptionsFixture.parse(args)))
    let object = try tccJSONObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])

    #expect(framework.calls == ["add:kTCCServiceReminders:com.example.App"])
    #expect(data["attempted"] as? Bool == true)
    #expect(data["verification"] as? String == "unverified")
    #expect(data["changed"] == nil)
  }
}

private final class FakeTCCResetRunner: TCCResetRunning, @unchecked Sendable {
  struct Call: Equatable {
    var service: String
    var client: String?
  }

  private(set) var calls: [Call] = []

  func reset(service: TCCServiceInfo, client: String?) throws -> TCCOperationResult {
    calls.append(Call(service: service.suffix, client: client))
    return TCCOperationResult(
      operation: "tcc.reset",
      changed: true,
      service: service.rawName,
      client: client,
      backend: "/usr/bin/tccutil"
    )
  }
}

private final class FakeTCCFramework: TCCFrameworkManaging, @unchecked Sendable {
  private(set) var calls: [String] = []

  func probe() -> TCCFrameworkProbe {
    TCCFrameworkProbe(
      frameworkPath: "/fake/TCC.framework/TCC",
      available: true,
      symbols: ["TCCAccessSetForBundle": true, "TCCAccessResetForBundle": true],
      sipStatus: "test",
      amfiStatus: "test",
      entitlementStatus: "test",
      diagnostics: []
    )
  }

  func add(service: TCCServiceInfo, bundleIdentifier: String) throws -> TCCOperationResult {
    calls.append("add:\(service.rawName):\(bundleIdentifier)")
    return TCCOperationResult(
      operation: "tcc.framework.add",
      changed: nil,
      service: service.rawName,
      client: bundleIdentifier,
      backend: "TCC.framework",
      attempted: true,
      verification: .unverified
    )
  }

  func reset(service: TCCServiceInfo, bundleIdentifier: String) throws -> TCCOperationResult {
    calls.append("reset:\(service.rawName):\(bundleIdentifier)")
    return TCCOperationResult(
      operation: "tcc.framework.reset",
      changed: nil,
      service: service.rawName,
      client: bundleIdentifier,
      backend: "TCC.framework",
      attempted: true,
      verification: .unverified
    )
  }
}

private struct TCCDatabaseFixture {
  let root: URL
  let database: URL
  let backups: URL
  let backend: TCCDatabaseBackend

  init() throws {
    root = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-tcc-\(UUID().uuidString)", isDirectory: true)
    database = root.appendingPathComponent("TCC.db")
    backups = root.appendingPathComponent("backups", isDirectory: true)
    backend = TCCDatabaseBackend(now: { Date(timeIntervalSince1970: 1_800_000_000) })
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try createDatabase()
  }

  func insert(
    service: String,
    client: String,
    clientType: Int,
    authValue: Int,
    authReason: Int
  ) throws {
    try execute(
      """
      INSERT INTO access (
        service, client, client_type, auth_value, auth_reason, auth_version,
        csreq, policy_id, indirect_object_identifier_type,
        indirect_object_identifier, indirect_object_code_identity, flags, last_modified
      ) VALUES (?, ?, ?, ?, ?, 1, NULL, NULL, 0, 'UNUSED', NULL, 0, 1800000000)
      """,
      bindings: [service, client, "\(clientType)", "\(authValue)", "\(authReason)"]
    )
  }

  func authValue(service: String, client: String) throws -> Int? {
    var handle: OpaquePointer?
    guard sqlite3_open(database.path, &handle) == SQLITE_OK, let handle else {
      throw TCCFixtureError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(
      handle,
      "SELECT auth_value FROM access WHERE service = ? AND client = ? LIMIT 1",
      -1,
      &statement,
      nil
    ) == SQLITE_OK, let statement else {
      throw TCCFixtureError.sqlitePrepare
    }
    defer { sqlite3_finalize(statement) }
    sqlite3_bind_text(statement, 1, service, -1, sqliteTransient)
    sqlite3_bind_text(statement, 2, client, -1, sqliteTransient)
    guard sqlite3_step(statement) == SQLITE_ROW else {
      return nil
    }
    return Int(sqlite3_column_int64(statement, 0))
  }

  func setAuthValue(_ value: Int, service: String, client: String) throws {
    try execute(
      "UPDATE access SET auth_value = ? WHERE service = ? AND client = ?",
      bindings: ["\(value)", service, client]
    )
  }

  private func createDatabase() throws {
    try execute(
      """
      CREATE TABLE access (
        service TEXT NOT NULL,
        client TEXT NOT NULL,
        client_type INTEGER NOT NULL,
        auth_value INTEGER NOT NULL,
        auth_reason INTEGER NOT NULL,
        auth_version INTEGER NOT NULL,
        csreq BLOB,
        policy_id INTEGER,
        indirect_object_identifier_type INTEGER,
        indirect_object_identifier TEXT NOT NULL DEFAULT 'UNUSED',
        indirect_object_code_identity BLOB,
        flags INTEGER,
        last_modified INTEGER NOT NULL,
        PRIMARY KEY (service, client, client_type)
      )
      """,
      bindings: []
    )
  }

  private func execute(_ sql: String, bindings: [String]) throws {
    var handle: OpaquePointer?
    guard sqlite3_open(database.path, &handle) == SQLITE_OK, let handle else {
      throw TCCFixtureError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
      throw TCCFixtureError.sqlitePrepare
    }
    defer { sqlite3_finalize(statement) }
    for (index, binding) in bindings.enumerated() {
      if let intValue = Int(binding) {
        sqlite3_bind_int64(statement, Int32(index + 1), sqlite3_int64(intValue))
      } else {
        sqlite3_bind_text(statement, Int32(index + 1), binding, -1, sqliteTransient)
      }
    }
    guard sqlite3_step(statement) == SQLITE_DONE else {
      throw TCCFixtureError.sqliteStep
    }
  }
}

private enum TCCFixtureError: Error {
  case sqliteOpen
  case sqlitePrepare
  case sqliteStep
}

private func tccExecuteRecordsMutation(command: TCCCommand, args: [String]) throws -> String {
  let dryRun = try #require(try command.run(options: try CLIOptionsFixture.parse(args + ["--dry-run"])))
  let dryRunObject = try tccJSONObject(dryRun.stdout ?? "")
  let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
  let dryRunSummary = try #require(dryRunData["normalizedArguments"] as? [String: Any])
  let dryRunBackupPath = try #require(dryRunSummary["backup_path"] as? String)
  #expect(dryRunBackupPath.hasSuffix("TCC.db"))
  let executed = try #require(
    try command.run(options: try CLIOptionsFixture.parse(args)))
  let executedObject = try tccJSONObject(executed.stdout ?? "")
  let executedData = try #require(executedObject["data"] as? [String: Any])
  let backupPath = try #require(executedData["backupPath"] as? String)

  #expect(executedData["changed"] as? Bool == true)
  #expect(executedData["affectedRows"] as? Int == 1)
  #expect(backupPath.hasSuffix("TCC.db"))

  return backupPath
}

private func tccJSONObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
