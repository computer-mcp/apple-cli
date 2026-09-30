import CryptoKit
import Foundation
import SQLite3
import Utility

public struct TCCDatabaseBackend: Sendable {
  private let now: @Sendable () -> Date

  private var fileManager: FileManager { FileManager.default }

  public init(now: @escaping @Sendable () -> Date = Date.init) {
    self.now = now
  }

  public static func defaultDatabasePath(scope: TCCScope) -> String {
    switch scope {
    case .user:
      let home = FileManager.default.homeDirectoryForCurrentUser.path
      return "\(home)/Library/Application Support/com.apple.TCC/TCC.db"
    case .system:
      return "/Library/Application Support/com.apple.TCC/TCC.db"
    case .both:
      return ""
    }
  }

  public func databaseInfos(scope: TCCScope, overridePath: String? = nil) -> [TCCDatabaseInfo] {
    scopes(for: scope).map { scoped in
      databaseInfo(scope: scoped, path: overridePath ?? Self.defaultDatabasePath(scope: scoped))
    }
  }

  public func records(
    scope: TCCScope,
    overridePath: String?,
    service: TCCServiceInfo?,
    client: TCCClientInfo?,
    limit: Int
  ) throws -> [TCCScopedAccessRecord] {
    try recordQuery(
      scope: scope,
      overridePath: overridePath,
      service: service,
      client: client,
      limit: limit
    ).records
  }

  public func recordQuery(
    scope: TCCScope,
    overridePath: String?,
    service: TCCServiceInfo?,
    client: TCCClientInfo?,
    limit: Int
  ) throws -> TCCRecordQueryResult {
    var output: [TCCScopedAccessRecord] = []
    var issues: [TCCDatabaseIssue] = []
    for scoped in scopes(for: scope) {
      let path = overridePath ?? Self.defaultDatabasePath(scope: scoped)
      do {
        let rows = try readRecords(
          scope: scoped,
          path: path,
          serviceRawName: service?.rawName,
          client: client,
          limit: limit
        )
        output.append(contentsOf: rows)
      } catch let error as CLIError where scope == .both {
        issues.append(
          TCCDatabaseIssue(scope: scoped, path: path, code: error.code, message: error.message)
        )
      }
    }
    return TCCRecordQueryResult(records: output, issues: issues)
  }

  public func databaseMutationContext(
    operation: TCCRecordsOperation,
    scope: TCCScope,
    overridePath: String?,
    backupDir: String?,
    backupPathOverride: String? = nil,
    service: TCCServiceInfo,
    client: TCCClientInfo
  ) throws -> TCCDatabaseMutationContext {
    guard scope != .both else {
      throw CLIError(
        code: .validationError,
        message: TCCWording.privateDatabaseScopeRequired()
      )
    }
    let path = overridePath ?? Self.defaultDatabasePath(scope: scope)
    let info = try requireReadableInfo(scope: scope, path: path)
    let existing = try readRecords(
      scope: scope,
      path: path,
      serviceRawName: service.rawName,
      client: client,
      limit: 100
    )
    let currentRowHash = TCCDatabaseMutationContext.combinedRowHash(existing.map(\.record))
    let backupPath: String
    if let backupPathOverride {
      backupPath = backupPathOverride
    } else {
      backupPath = try defaultBackupPath(databasePath: path, backupDir: backupDir)
    }
    let intendedDiff = intendedDiff(operation: operation, service: service, client: client)
    return TCCDatabaseMutationContext(
      operation: operation,
      scope: scope,
      databasePath: path,
      databaseInfo: info,
      service: service,
      client: client,
      currentRows: existing.map(\.record),
      currentRowHash: currentRowHash,
      intendedDiff: intendedDiff,
      backupPath: backupPath
    )
  }

  public func performMutation(_ context: TCCDatabaseMutationContext) throws -> TCCOperationResult {
    let refreshed = try databaseMutationContext(
      operation: context.operation,
      scope: context.scope,
      overridePath: context.databasePath,
      backupDir: URL(fileURLWithPath: context.backupPath).deletingLastPathComponent().path,
      backupPathOverride: context.backupPath,
      service: context.service,
      client: context.client
    )

    guard refreshed.databaseInfo.digest == context.databaseInfo.digest else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.schemaDigestChangedBeforeMutation(),
        details: [
          "expected_digest": context.databaseInfo.digest ?? "",
          "actual_digest": refreshed.databaseInfo.digest ?? "",
        ]
      )
    }
    guard refreshed.databaseInfo.schemaColumns == context.databaseInfo.schemaColumns else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.schemaColumnsChangedBeforeMutation()
      )
    }
    guard refreshed.currentRowHash == context.currentRowHash else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.currentRowChangedBeforeMutation(),
        details: [
          "expected_row_hash": context.currentRowHash,
          "actual_row_hash": refreshed.currentRowHash,
        ]
      )
    }

    try copyDatabaseBackup(from: context.databasePath, to: context.backupPath)

    var handle: OpaquePointer?
    guard sqlite3_open_v2(context.databasePath, &handle, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK,
      let handle
    else {
      let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown sqlite error"
      if let handle {
        sqlite3_close(handle)
      }
      throw CLIError(
        code: .permissionDenied,
        message: TCCWording.databaseOpenReadWriteFailed(),
        details: ["path": context.databasePath, "sqlite_error": message]
      )
    }
    defer { sqlite3_close(handle) }

    let affectedRows: Int
    switch context.operation {
    case .add:
      affectedRows = try insertOrReplaceAccessRecord(handle: handle, context: context)
    case .remove:
      affectedRows = try deleteAccessRecord(handle: handle, context: context)
    case .enable:
      affectedRows = try updateAccessRecord(handle: handle, context: context, enabled: true)
    case .disable:
      affectedRows = try updateAccessRecord(handle: handle, context: context, enabled: false)
    }

    return TCCOperationResult(
      operation: context.operation.operationName,
      changed: affectedRows > 0,
      scope: context.scope,
      service: context.service.rawName,
      client: context.client.client,
      affectedRows: affectedRows,
      backupPath: context.backupPath,
      backend: "tcc-db"
    )
  }

  private func requireReadableInfo(scope: TCCScope, path: String) throws -> TCCDatabaseInfo {
    let info = databaseInfo(scope: scope, path: path)
    guard info.exists else {
      throw CLIError(code: .notFound, message: "TCC database does not exist.", details: ["path": path])
    }
    guard info.readable else {
      throw CLIError(
        code: .permissionDenied,
        message: TCCWording.databaseNotReadableByProcess(),
        details: ["path": path, "error": info.error ?? ""]
      )
    }
    guard info.schemaColumns.contains("service"), info.schemaColumns.contains("client") else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.databaseSchemaNotRecognized(),
        details: ["path": path, "columns": info.schemaColumns.joined(separator: ",")]
      )
    }
    return info
  }

  private func databaseInfo(scope: TCCScope, path: String) -> TCCDatabaseInfo {
    let exists = fileManager.fileExists(atPath: path)
    let writable = fileManager.isWritableFile(atPath: path)
    guard exists else {
      return TCCDatabaseInfo(
        scope: scope,
        path: path,
        exists: false,
        readable: false,
        writable: false,
        schemaColumns: [],
        digest: nil,
        openMode: "read-only",
        error: "missing"
      )
    }

    var handle: OpaquePointer?
    let openResult = sqlite3_open_v2(path, &handle, SQLITE_OPEN_READONLY, nil)
    guard openResult == SQLITE_OK, let handle else {
      let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown sqlite error"
      if let handle {
        sqlite3_close(handle)
      }
      return TCCDatabaseInfo(
        scope: scope,
        path: path,
        exists: true,
        readable: false,
        writable: writable,
        schemaColumns: [],
        digest: nil,
        openMode: "read-only",
        error: message
      )
    }
    defer { sqlite3_close(handle) }

    do {
      let columns = try accessTableColumns(handle)
      let schemaSQL = try schemaSQL(handle)
      return TCCDatabaseInfo(
        scope: scope,
        path: path,
        exists: true,
        readable: true,
        writable: writable,
        schemaColumns: columns,
        digest: schemaSQL.map(schemaDigest),
        openMode: "read-only",
        error: nil
      )
    } catch let error as CLIError {
      return TCCDatabaseInfo(
        scope: scope,
        path: path,
        exists: true,
        readable: true,
        writable: writable,
        schemaColumns: [],
        digest: nil,
        openMode: "read-only",
        error: error.message
      )
    } catch {
      return TCCDatabaseInfo(
        scope: scope,
        path: path,
        exists: true,
        readable: true,
        writable: writable,
        schemaColumns: [],
        digest: nil,
        openMode: "read-only",
        error: String(describing: error)
      )
    }
  }

  private func readRecords(
    scope: TCCScope,
    path: String,
    serviceRawName: String?,
    client: TCCClientInfo?,
    limit: Int
  ) throws -> [TCCScopedAccessRecord] {
    let info = try requireReadableInfo(scope: scope, path: path)
    let selectedColumns = accessKnownColumns.filter { info.schemaColumns.contains($0) }
    guard !selectedColumns.isEmpty else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.databaseHasNoRecognizedColumns(),
        details: ["path": path]
      )
    }

    var handle: OpaquePointer?
    guard sqlite3_open_v2(path, &handle, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let handle else {
      let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown sqlite error"
      if let handle {
        sqlite3_close(handle)
      }
      throw CLIError(
        code: .permissionDenied,
        message: TCCWording.databaseNotReadableByProcess(),
        details: ["path": path, "sqlite_error": message]
      )
    }
    defer { sqlite3_close(handle) }

    var whereClauses: [String] = []
    var bindings: [SQLiteBinding] = []
    if let serviceRawName {
      whereClauses.append("service = ?")
      bindings.append(.text(serviceRawName))
    }
    if let client {
      whereClauses.append("client = ?")
      bindings.append(.text(client.client))
      if info.schemaColumns.contains("client_type") {
        whereClauses.append("client_type = ?")
        bindings.append(.int(client.clientType))
      }
    }

    let whereSQL = whereClauses.isEmpty ? "" : " WHERE " + whereClauses.joined(separator: " AND ")
    let orderSQL = selectedColumns.contains("last_modified") ? " ORDER BY last_modified DESC" : ""
    let sql =
      "SELECT \(selectedColumns.map(quoteIdentifier).joined(separator: ", ")) FROM access\(whereSQL)\(orderSQL) LIMIT ?"
    bindings.append(.int(limit))

    let rows = try queryRows(handle: handle, sql: sql, bindings: bindings)
    return rows.map { row in
      TCCScopedAccessRecord(
        scope: scope,
        databasePath: path,
        record: accessRecord(from: row)
      )
    }
  }

  private func insertOrReplaceAccessRecord(
    handle: OpaquePointer,
    context: TCCDatabaseMutationContext
  ) throws -> Int {
    let columns = context.databaseInfo.schemaColumns
    let insertColumns = accessInsertColumns.filter { columns.contains($0) }
    guard insertColumns.contains("service"), insertColumns.contains("client") else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.databaseCannotAcceptServiceClientInserts()
      )
    }
    let placeholders = Array(repeating: "?", count: insertColumns.count).joined(separator: ", ")
    let sql =
      "INSERT OR REPLACE INTO access (\(insertColumns.map(quoteIdentifier).joined(separator: ", "))) VALUES (\(placeholders))"
    let bindings = insertColumns.map { bindingValue(for: $0, context: context, enabled: true) }
    return try executeSQL(handle: handle, sql: sql, bindings: bindings)
  }

  private func deleteAccessRecord(
    handle: OpaquePointer,
    context: TCCDatabaseMutationContext
  ) throws -> Int {
    let clientTypeClause = context.databaseInfo.schemaColumns.contains("client_type")
      ? " AND client_type = ?" : ""
    let sql = "DELETE FROM access WHERE service = ? AND client = ?\(clientTypeClause)"
    var bindings: [SQLiteBinding] = [.text(context.service.rawName), .text(context.client.client)]
    if context.databaseInfo.schemaColumns.contains("client_type") {
      bindings.append(.int(context.client.clientType))
    }
    return try executeSQL(handle: handle, sql: sql, bindings: bindings)
  }

  private func updateAccessRecord(
    handle: OpaquePointer,
    context: TCCDatabaseMutationContext,
    enabled: Bool
  ) throws -> Int {
    let columns = context.databaseInfo.schemaColumns
    let authColumn: String
    if columns.contains("auth_value") {
      authColumn = "auth_value"
    } else if columns.contains("allowed") {
      authColumn = "allowed"
    } else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.databaseHasNoAuthorizationColumn()
      )
    }
    let clientTypeClause = columns.contains("client_type") ? " AND client_type = ?" : ""
    let timestampClause = columns.contains("last_modified") ? ", last_modified = ?" : ""
    let sql =
      "UPDATE access SET \(quoteIdentifier(authColumn)) = ?\(timestampClause) WHERE service = ? AND client = ?\(clientTypeClause)"
    var bindings: [SQLiteBinding] = [
      .int(authColumn == "auth_value" ? (enabled ? 2 : 0) : (enabled ? 1 : 0))
    ]
    if columns.contains("last_modified") {
      bindings.append(.int(Int(now().timeIntervalSince1970)))
    }
    bindings.append(.text(context.service.rawName))
    bindings.append(.text(context.client.client))
    if columns.contains("client_type") {
      bindings.append(.int(context.client.clientType))
    }
    return try executeSQL(handle: handle, sql: sql, bindings: bindings)
  }

  private func bindingValue(
    for column: String,
    context: TCCDatabaseMutationContext,
    enabled: Bool
  ) -> SQLiteBinding {
    switch column {
    case "service":
      return .text(context.service.rawName)
    case "client":
      return .text(context.client.client)
    case "client_type":
      return .int(context.client.clientType)
    case "auth_value":
      return .int(enabled ? 2 : 0)
    case "auth_reason":
      return .int(4)
    case "auth_version":
      return .int(1)
    case "allowed":
      return .int(enabled ? 1 : 0)
    case "prompt_count":
      return .int(1)
    case "csreq":
      return .null
    case "policy_id":
      return .null
    case "indirect_object_identifier_type":
      return .int(0)
    case "indirect_object_identifier":
      return .text("UNUSED")
    case "indirect_object_code_identity":
      return .null
    case "flags":
      return .int(0)
    case "last_modified":
      return .int(Int(now().timeIntervalSince1970))
    default:
      return .null
    }
  }

  private func intendedDiff(
    operation: TCCRecordsOperation,
    service: TCCServiceInfo,
    client: TCCClientInfo
  ) -> [String: String] {
    switch operation {
    case .add:
      return [
        "action": "insert_or_replace",
        "service": service.rawName,
        "client": client.client,
        "client_type": "\(client.clientType)",
        "auth_value": "2",
        "auth_reason": "4",
      ]
    case .remove:
      return [
        "action": "delete_exact",
        "service": service.rawName,
        "client": client.client,
        "client_type": "\(client.clientType)",
      ]
    case .enable:
      return [
        "action": "update_exact",
        "service": service.rawName,
        "client": client.client,
        "client_type": "\(client.clientType)",
        "auth_value": "2",
      ]
    case .disable:
      return [
        "action": "update_exact",
        "service": service.rawName,
        "client": client.client,
        "client_type": "\(client.clientType)",
        "auth_value": "0",
      ]
    }
  }

  private func defaultBackupPath(databasePath: String, backupDir: String?) throws -> String {
    let directory: URL
    if let backupDir {
      directory = URL(fileURLWithPath: backupDir, isDirectory: true)
    } else {
      directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("apple-cli-tcc-backups", isDirectory: true)
    }
    let timestamp = ISO8601DateFormatter()
      .string(from: now())
      .replacingOccurrences(of: ":", with: "")
    let nonce = UUID().uuidString.lowercased()
    return directory
      .appendingPathComponent("\(timestamp)-\(nonce)-\(URL(fileURLWithPath: databasePath).lastPathComponent)")
      .path
  }

  private func copyDatabaseBackup(from source: String, to destination: String) throws {
    let destinationURL = URL(fileURLWithPath: destination)
    try fileManager.createDirectory(
      at: destinationURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    if fileManager.fileExists(atPath: destination) {
      try fileManager.removeItem(atPath: destination)
    }
    try fileManager.copyItem(atPath: source, toPath: destination)
  }

  private func accessRecord(from row: [String: SQLiteValue]) -> TCCAccessRecord {
    let service = row["service"]?.stringValue ?? ""
    let client = row["client"]?.stringValue ?? ""
    let canonicalValues = accessKnownColumns.map { "\($0)=\(row[$0]?.canonicalString ?? "<missing>")" }
      .joined(separator: "\u{1f}")
    return TCCAccessRecord(
      service: service,
      client: client,
      clientType: row["client_type"]?.intValue,
      authValue: row["auth_value"]?.intValue,
      authReason: row["auth_reason"]?.intValue,
      authVersion: row["auth_version"]?.intValue,
      allowed: row["allowed"]?.intValue,
      promptCount: row["prompt_count"]?.intValue,
      csreqSHA256: row["csreq"]?.blobSHA256,
      csreqLength: row["csreq"]?.blobLength,
      policyID: row["policy_id"]?.intValue,
      indirectObjectIdentifierType: row["indirect_object_identifier_type"]?.intValue,
      indirectObjectIdentifier: row["indirect_object_identifier"]?.stringValue,
      indirectObjectCodeIdentitySHA256: row["indirect_object_code_identity"]?.blobSHA256,
      indirectObjectCodeIdentityLength: row["indirect_object_code_identity"]?.blobLength,
      flags: row["flags"]?.intValue,
      lastModifiedRaw: row["last_modified"]?.intValue,
      rowHash: sha256Hex(canonicalValues)
    )
  }

  private func queryRows(
    handle: OpaquePointer,
    sql: String,
    bindings: [SQLiteBinding]
  ) throws -> [[String: SQLiteValue]] {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
      throw sqliteError(handle, message: "Failed to prepare TCC database query.")
    }
    defer { sqlite3_finalize(statement) }
    try bind(bindings, to: statement)

    var rows: [[String: SQLiteValue]] = []
    while true {
      let step = sqlite3_step(statement)
      if step == SQLITE_DONE {
        break
      }
      guard step == SQLITE_ROW else {
        throw sqliteError(handle, message: "Failed to step TCC database query.")
      }
      var row: [String: SQLiteValue] = [:]
      for columnIndex in 0..<sqlite3_column_count(statement) {
        let name = String(cString: sqlite3_column_name(statement, columnIndex))
        switch sqlite3_column_type(statement, columnIndex) {
        case SQLITE_INTEGER:
          row[name] = .integer(Int(sqlite3_column_int64(statement, columnIndex)))
        case SQLITE_FLOAT:
          row[name] = .real(sqlite3_column_double(statement, columnIndex))
        case SQLITE_TEXT:
          if let text = sqlite3_column_text(statement, columnIndex) {
            row[name] = .text(String(cString: text))
          } else {
            row[name] = .null
          }
        case SQLITE_BLOB:
          let length = Int(sqlite3_column_bytes(statement, columnIndex))
          if let bytes = sqlite3_column_blob(statement, columnIndex), length > 0 {
            row[name] = .blob(Data(bytes: bytes, count: length))
          } else {
            row[name] = .blob(Data())
          }
        default:
          row[name] = .null
        }
      }
      rows.append(row)
    }
    return rows
  }

  private func executeSQL(
    handle: OpaquePointer,
    sql: String,
    bindings: [SQLiteBinding]
  ) throws -> Int {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
      throw sqliteError(handle, message: "Failed to prepare TCC database mutation.")
    }
    defer { sqlite3_finalize(statement) }
    try bind(bindings, to: statement)
    let step = sqlite3_step(statement)
    guard step == SQLITE_DONE else {
      throw sqliteError(handle, message: "Failed to execute TCC database mutation.")
    }
    return Int(sqlite3_changes(handle))
  }

  private func bind(_ bindings: [SQLiteBinding], to statement: OpaquePointer) throws {
    for (index, binding) in bindings.enumerated() {
      let position = Int32(index + 1)
      switch binding {
      case .null:
        sqlite3_bind_null(statement, position)
      case .int(let value):
        sqlite3_bind_int64(statement, position, sqlite3_int64(value))
      case .text(let value):
        sqlite3_bind_text(statement, position, value, -1, sqliteTransient)
      case .blob(let data):
        _ = data.withUnsafeBytes { buffer in
          sqlite3_bind_blob(statement, position, buffer.baseAddress, Int32(buffer.count), sqliteTransient)
        }
      }
    }
  }

  private func accessTableColumns(_ handle: OpaquePointer) throws -> [String] {
    let rows = try queryRows(handle: handle, sql: "PRAGMA table_info(access)", bindings: [])
    return rows.compactMap { $0["name"]?.stringValue }
  }

  private func schemaSQL(_ handle: OpaquePointer) throws -> String? {
    let rows = try queryRows(
      handle: handle,
      sql: "SELECT sql FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1",
      bindings: [.text("table"), .text("access")]
    )
    return rows.first?["sql"]?.stringValue
  }

  private func sqliteError(_ handle: OpaquePointer, message: String) -> CLIError {
    let primaryCode = sqlite3_errcode(handle)
    let extendedCode = sqlite3_extended_errcode(handle)
    let errorCode: CLIErrorCode =
      primaryCode == SQLITE_READONLY || primaryCode == SQLITE_PERM || primaryCode == SQLITE_AUTH
      ? .permissionDenied
      : .backendUnavailable
    return CLIError(
      code: errorCode,
      message: message,
      details: [
        "sqlite_error": String(cString: sqlite3_errmsg(handle)),
        "sqlite_code": "\(primaryCode)",
        "sqlite_extended_code": "\(extendedCode)",
      ]
    )
  }

  private func scopes(for scope: TCCScope) -> [TCCScope] {
    switch scope {
    case .user:
      return [.user]
    case .system:
      return [.system]
    case .both:
      return [.user, .system]
    }
  }
}

public enum TCCRecordsOperation: String, Codable, CaseIterable, Sendable {
  case add
  case remove
  case enable
  case disable

  public var operationName: String {
    "tcc.records.\(rawValue)"
  }
}

public struct TCCDatabaseMutationContext: Equatable, Sendable {
  public var operation: TCCRecordsOperation
  public var scope: TCCScope
  public var databasePath: String
  public var databaseInfo: TCCDatabaseInfo
  public var service: TCCServiceInfo
  public var client: TCCClientInfo
  public var currentRows: [TCCAccessRecord]
  public var currentRowHash: String
  public var intendedDiff: [String: String]
  public var backupPath: String

  public init(
    operation: TCCRecordsOperation,
    scope: TCCScope,
    databasePath: String,
    databaseInfo: TCCDatabaseInfo,
    service: TCCServiceInfo,
    client: TCCClientInfo,
    currentRows: [TCCAccessRecord],
    currentRowHash: String,
    intendedDiff: [String: String],
    backupPath: String
  ) {
    self.operation = operation
    self.scope = scope
    self.databasePath = databasePath
    self.databaseInfo = databaseInfo
    self.service = service
    self.client = client
    self.currentRows = currentRows
    self.currentRowHash = currentRowHash
    self.intendedDiff = intendedDiff
    self.backupPath = backupPath
  }

  public static func combinedRowHash(_ records: [TCCAccessRecord]) -> String {
    guard !records.isEmpty else {
      return "absent"
    }
    return sha256Hex(records.map(\.rowHash).sorted().joined(separator: "|"))
  }
}

public struct TCCRecordQueryResult: Equatable, Sendable {
  public var records: [TCCScopedAccessRecord]
  public var issues: [TCCDatabaseIssue]

  public init(records: [TCCScopedAccessRecord], issues: [TCCDatabaseIssue]) {
    self.records = records
    self.issues = issues
  }
}

private enum SQLiteBinding {
  case null
  case int(Int)
  case text(String)
  case blob(Data)
}

private enum SQLiteValue: Equatable {
  case null
  case integer(Int)
  case real(Double)
  case text(String)
  case blob(Data)

  var stringValue: String? {
    switch self {
    case .text(let value):
      return value
    case .integer(let value):
      return "\(value)"
    case .real(let value):
      return "\(value)"
    case .null, .blob:
      return nil
    }
  }

  var intValue: Int? {
    switch self {
    case .integer(let value):
      return value
    case .text(let value):
      return Int(value)
    case .real(let value):
      return Int(value)
    case .null, .blob:
      return nil
    }
  }

  var blobSHA256: String? {
    guard case .blob(let data) = self else {
      return nil
    }
    return sha256Hex(data)
  }

  var blobLength: Int? {
    guard case .blob(let data) = self else {
      return nil
    }
    return data.count
  }

  var canonicalString: String {
    switch self {
    case .null:
      return "null"
    case .integer(let value):
      return "i:\(value)"
    case .real(let value):
      return "r:\(value)"
    case .text(let value):
      return "t:\(value)"
    case .blob(let data):
      return "b:\(sha256Hex(data)):\(data.count)"
    }
  }
}

private let accessKnownColumns = [
  "service",
  "client",
  "client_type",
  "auth_value",
  "auth_reason",
  "auth_version",
  "allowed",
  "prompt_count",
  "csreq",
  "policy_id",
  "indirect_object_identifier_type",
  "indirect_object_identifier",
  "indirect_object_code_identity",
  "flags",
  "last_modified",
]

private let accessInsertColumns = [
  "service",
  "client",
  "client_type",
  "auth_value",
  "auth_reason",
  "auth_version",
  "allowed",
  "prompt_count",
  "csreq",
  "policy_id",
  "indirect_object_identifier_type",
  "indirect_object_identifier",
  "indirect_object_code_identity",
  "flags",
  "last_modified",
]

private func quoteIdentifier(_ identifier: String) -> String {
  "\"\(identifier.replacingOccurrences(of: "\"", with: "\"\""))\""
}

private func schemaDigest(_ sql: String) -> String {
  let digest = Insecure.SHA1.hash(data: Data(sql.utf8))
  return digest.map { String(format: "%02x", $0) }.joined().prefix(10).description
}

func sha256Hex(_ value: String) -> String {
  sha256Hex(Data(value.utf8))
}

func sha256Hex(_ data: Data) -> String {
  SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
