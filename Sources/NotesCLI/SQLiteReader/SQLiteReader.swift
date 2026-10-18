import Foundation
import Utility

struct NotesStoreFileEvidence: Equatable, Sendable {
  var path: String
  var exists: Bool
  var isDirectory: Bool
  var isReadable: Bool
  var sizeBytes: Int64?
  var modifiedAt: Date?
}

struct NotesStoreEntityCount: Equatable, Sendable {
  var entity: String
  var rows: Int
}

struct NotesStoreSearchIndexStateCount: Equatable, Sendable {
  var stateValue: String
  var rows: Int
}

struct NotesStoreSchemaSummary: Equatable, Sendable {
  var tableCount: Int
  var indexCount: Int
  var requiredTablesPresent: [String]
  var requiredTablesMissing: [String]
  var entityCounts: [NotesStoreEntityCount]
  var searchIndexStateCounts: [NotesStoreSearchIndexStateCount]
}

struct NotesStoreInspection: Equatable, Sendable {
  var container: NotesStoreFileEvidence
  var store: NotesStoreFileEvidence
  var wal: NotesStoreFileEvidence
  var shm: NotesStoreFileEvidence
  var indexStateFiles: [NotesStoreFileEvidence]
  var schemaSummary: NotesStoreSchemaSummary?
  var warnings: [String]
}

private struct CoreDataObjectReference: Equatable, Sendable {
  var entity: String
  var primaryKey: Int64
}

public struct SQLiteReader: Sendable {
  let homeDirectory: URL

  public init(
    homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
  ) {
    self.homeDirectory = homeDirectory
  }

  var notesContainerURL: URL {
    homeDirectory
      .appendingPathComponent("Library", isDirectory: true)
      .appendingPathComponent("Group Containers", isDirectory: true)
      .appendingPathComponent("group.com.apple.notes", isDirectory: true)
  }

  var noteStoreURL: URL {
    notesContainerURL.appendingPathComponent("NoteStore.sqlite", isDirectory: false)
  }

  func debugNote(_ note: NotesNoteDetail) -> NotesObjectDebugResponse {
    var warnings: [String] = []
    let storeObject = storeObject(
      id: note.id,
      expectedEntity: "ICNote",
      warnings: &warnings
    ) { storePath, reference in
      try noteStoreObject(storePath: storePath, reference: reference, noteID: note.id)
    }

    return NotesObjectDebugResponse(
      kind: "note",
      selectorSHA256: sha256Hex(note.id),
      readback: NotesReadbackRecord(
        kind: "note",
        idSHA256: sha256Hex(note.id),
        titleSHA256: sha256Hex(note.title),
        titleLength: note.title.count,
        accountNameSHA256: sha256Hex(note.accountName),
        accountNameLength: note.accountName.count,
        folderNameSHA256: sha256Hex(note.folderName),
        folderNameLength: note.folderName.count,
        hasBody: note.body != nil,
        bodyByteCount: note.body?.utf8.count,
        bodySHA256: note.body.map(sha256Hex),
        hasCreatedAt: note.createdAt != nil,
        hasUpdatedAt: note.updatedAt != nil
      ),
      storeObject: storeObject,
      warnings: warnings
    )
  }

  func debugFolder(_ folder: NotesFolderRecord, selector: String) -> NotesObjectDebugResponse {
    var warnings: [String] = []
    let storeObject = storeObject(
      id: folder.id,
      expectedEntity: "ICFolder",
      warnings: &warnings
    ) { storePath, reference in
      try folderStoreObject(storePath: storePath, reference: reference, folderID: folder.id)
    }

    return NotesObjectDebugResponse(
      kind: "folder",
      selectorSHA256: sha256Hex(selector),
      readback: NotesReadbackRecord(
        kind: "folder",
        idSHA256: sha256Hex(folder.id),
        nameSHA256: sha256Hex(folder.name),
        nameLength: folder.name.count,
        accountNameSHA256: sha256Hex(folder.accountName),
        accountNameLength: folder.accountName.count
      ),
      storeObject: storeObject,
      warnings: warnings
    )
  }

  func debugAccount(_ account: NotesAccountRecord, selector: String) -> NotesObjectDebugResponse {
    var warnings: [String] = []
    let storeObject = storeObject(
      id: account.id,
      expectedEntity: "ICAccount",
      warnings: &warnings
    ) { storePath, reference in
      try accountStoreObject(storePath: storePath, reference: reference, accountID: account.id)
    }

    return NotesObjectDebugResponse(
      kind: "account",
      selectorSHA256: sha256Hex(selector),
      readback: NotesReadbackRecord(
        kind: "account",
        idSHA256: sha256Hex(account.id),
        nameSHA256: sha256Hex(account.name),
        nameLength: account.name.count
      ),
      storeObject: storeObject,
      warnings: warnings
    )
  }

  func debugStore(scope: String) throws -> NotesStoreDebugResponse {
    let normalizedScope =
      scope.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      ? "summary"
      : scope.trimmingCharacters(in: .whitespacesAndNewlines)
    let supportedScopes: Set<String> = ["summary", "schema", "entities", "indexes"]
    guard supportedScopes.contains(normalizedScope) else {
      throw CLIError(
        code: .validationError,
        message: "`--scope` must be one of: summary, schema, entities, indexes."
      )
    }

    let inspection = inspect()
    let schema = inspection.schemaSummary
    var warnings = inspection.warnings
    var schemaTables: [NotesStoreSchemaTableRecord] = []

    if normalizedScope == "schema", inspection.store.exists, inspection.store.isReadable {
      do {
        schemaTables = try storeSchemaTables(storePath: inspection.store.path)
      } catch let error as CLIError {
        warnings.append("Read-only Notes store schema-table query failed: \(error.message)")
      } catch {
        warnings.append("Read-only Notes store schema-table query failed: \(error)")
      }
    }

    return NotesStoreDebugResponse(
      scope: normalizedScope,
      container: fileRecord(inspection.container),
      store: fileRecord(inspection.store),
      wal: fileRecord(inspection.wal),
      shm: fileRecord(inspection.shm),
      indexStateFiles: inspection.indexStateFiles.map(fileRecord),
      tableCount: schema?.tableCount,
      indexCount: schema?.indexCount,
      requiredTablesPresent: schema?.requiredTablesPresent ?? [],
      requiredTablesMissing: schema?.requiredTablesMissing ?? [],
      schemaTables: normalizedScope == "schema" ? schemaTables : [],
      entityCounts: ["summary", "entities"].contains(normalizedScope)
        ? (schema?.entityCounts.map(entityCountRecord) ?? [])
        : [],
      searchIndexStateCounts: ["summary", "indexes"].contains(normalizedScope)
        ? (schema?.searchIndexStateCounts.map(searchIndexStateRecord) ?? [])
        : [],
      warnings: warnings
    )
  }

  private func storeObject(
    id: String,
    expectedEntity: String,
    warnings: inout [String],
    query: (String, CoreDataObjectReference) throws -> NotesStoreObjectRecord
  ) -> NotesStoreObjectRecord {
    guard let reference = coreDataObjectReference(id) else {
      warnings.append("Object ID is not a Core Data object URI.")
      return NotesStoreObjectRecord(matched: false)
    }
    guard reference.entity == expectedEntity else {
      warnings.append("Object ID entity did not match expected \(expectedEntity).")
      return NotesStoreObjectRecord(
        entity: reference.entity,
        primaryKey: reference.primaryKey,
        matched: false
      )
    }

    let inspection = inspect()
    guard inspection.store.exists, inspection.store.isReadable else {
      warnings.append("Notes NoteStore.sqlite is not readable.")
      return NotesStoreObjectRecord(
        entity: reference.entity,
        primaryKey: reference.primaryKey,
        matched: false
      )
    }

    do {
      var record = try query(inspection.store.path, reference)
      record.lookupSucceeded = true
      return record
    } catch let error as CLIError {
      warnings.append("Read-only Notes object query failed: \(error.message)")
    } catch {
      warnings.append("Read-only Notes object query failed: \(error)")
    }

    return NotesStoreObjectRecord(
      entity: reference.entity,
      primaryKey: reference.primaryKey,
      matched: false
    )
  }

  func inspect() -> NotesStoreInspection {
    let container = fileEvidence(notesContainerURL)
    let store = fileEvidence(noteStoreURL)
    let wal = fileEvidence(notesContainerURL.appendingPathComponent("NoteStore.sqlite-wal"))
    let shm = fileEvidence(notesContainerURL.appendingPathComponent("NoteStore.sqlite-shm"))
    let indexStateFiles = [
      "HTML.index-progress",
      "NotesIndexerState-HTML",
      "NotesIndexerState-Modern",
    ].map { fileEvidence(notesContainerURL.appendingPathComponent($0)) }

    var warnings: [String] = []
    if !container.exists {
      warnings.append("Notes group container was not found.")
    } else if !container.isDirectory {
      warnings.append("Notes group container path is not a directory.")
    }

    if !store.exists {
      warnings.append("Notes NoteStore.sqlite was not found.")
    } else if !store.isReadable {
      warnings.append("Notes NoteStore.sqlite is not readable.")
    }

    var schemaSummary: NotesStoreSchemaSummary?
    if store.exists, store.isReadable {
      do {
        schemaSummary = try sqliteSchemaSummary(storePath: store.path)
      } catch let error as CLIError {
        warnings.append("Read-only Notes store schema query failed: \(error.message)")
      } catch {
        warnings.append("Read-only Notes store schema query failed: \(error)")
      }
    }

    return NotesStoreInspection(
      container: container,
      store: store,
      wal: wal,
      shm: shm,
      indexStateFiles: indexStateFiles,
      schemaSummary: schemaSummary,
      warnings: warnings
    )
  }

  func doctorCheck() -> CLIDoctorCheck {
    let inspection = inspect()
    var details = [
      "container_path": displayPath(inspection.container.path),
      "container_exists": boolString(inspection.container.exists),
      "store_path": displayPath(inspection.store.path),
      "store_present": boolString(inspection.store.exists),
      "store_readable": boolString(inspection.store.isReadable),
      "sqlite_readonly": "true",
      "write_access": "none",
      "body_output": "none",
    ]

    addFileDetails(prefix: "store", file: inspection.store, to: &details)
    addFileDetails(prefix: "wal", file: inspection.wal, to: &details)
    addFileDetails(prefix: "shm", file: inspection.shm, to: &details)

    let presentIndexFiles = inspection.indexStateFiles
      .filter { $0.exists }
      .map { URL(fileURLWithPath: $0.path).lastPathComponent }
      .sorted()
    details["index_state_files"] = presentIndexFiles.joined(separator: ",")
    details["index_state_file_count"] = "\(presentIndexFiles.count)"

    if let schema = inspection.schemaSummary {
      details["schema_table_count"] = "\(schema.tableCount)"
      details["schema_index_count"] = "\(schema.indexCount)"
      details["required_tables_present"] = schema.requiredTablesPresent.joined(separator: ",")
      details["required_tables_missing"] = schema.requiredTablesMissing.joined(separator: ",")
      details["entity_counts"] = entityCountsDescription(schema.entityCounts)
      details["search_index_state_counts"] = searchIndexStateDescription(
        schema.searchIndexStateCounts)
    }

    if !inspection.warnings.isEmpty {
      details["warnings"] = inspection.warnings.joined(separator: " | ")
    }

    return CLIDoctorCheck(
      name: "notes_store",
      status: inspection.warnings.isEmpty ? .ok : .warning,
      message: inspection.warnings.isEmpty
        ? "Notes group container, store, and bounded index evidence are readable."
        : "Notes store/index evidence is incomplete; see warning details.",
      details: details
    )
  }

  private func fileEvidence(_ url: URL) -> NotesStoreFileEvidence {
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    let values = try? url.resourceValues(forKeys: [
      .contentModificationDateKey,
      .fileSizeKey,
      .isReadableKey,
    ])
    return NotesStoreFileEvidence(
      path: url.path,
      exists: exists,
      isDirectory: exists && isDirectory.boolValue,
      isReadable: exists
        && (values?.isReadable ?? FileManager.default.isReadableFile(atPath: url.path)),
      sizeBytes: exists ? values?.fileSize.map(Int64.init) : nil,
      modifiedAt: exists ? values?.contentModificationDate : nil
    )
  }

  private func sqliteSchemaSummary(storePath: String) throws -> NotesStoreSchemaSummary {
    let objectRows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select type, count(*) as rows
        from sqlite_master
        where type in ('table', 'index')
        group by type
        order by type;
        """
    )
    let tableCount = countValue(named: "table", in: objectRows)
    let indexCount = countValue(named: "index", in: objectRows)

    let tableRows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select name
        from sqlite_master
        where type = 'table'
        order by name;
        """
    )
    let tableNames = Set(tableRows.compactMap { stringValue($0["name"]) })
    let requiredTables = [
      "ZICCLOUDSYNCINGOBJECT",
      "ZICNOTEDATA",
      "ZICSEARCHINDEXSTATE",
      "Z_PRIMARYKEY",
    ]
    let requiredPresent = requiredTables.filter(tableNames.contains)
    let requiredMissing = requiredTables.filter { !tableNames.contains($0) }

    let entityCounts =
      requiredMissing.contains("ZICCLOUDSYNCINGOBJECT") || requiredMissing.contains("Z_PRIMARYKEY")
      ? []
      : try storeEntityCounts(storePath: storePath)
    let searchIndexStateCounts =
      requiredMissing.contains("ZICSEARCHINDEXSTATE")
      ? []
      : try storeSearchIndexStateCounts(storePath: storePath)

    return NotesStoreSchemaSummary(
      tableCount: tableCount,
      indexCount: indexCount,
      requiredTablesPresent: requiredPresent,
      requiredTablesMissing: requiredMissing,
      entityCounts: entityCounts,
      searchIndexStateCounts: searchIndexStateCounts
    )
  }

  private func storeEntityCounts(storePath: String) throws -> [NotesStoreEntityCount] {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select pk.Z_NAME as entity, count(object.Z_PK) as rows
        from Z_PRIMARYKEY pk
        left join ZICCLOUDSYNCINGOBJECT object on object.Z_ENT = pk.Z_ENT
        where pk.Z_NAME in (
          'ICAccount',
          'ICAttachment',
          'ICFolder',
          'ICHashtag',
          'ICMedia',
          'ICNote'
        )
        group by pk.Z_NAME
        order by pk.Z_NAME;
        """
    )
    return rows.compactMap { row in
      guard let entity = stringValue(row["entity"]), let rows = intValue(row["rows"]) else {
        return nil
      }
      return NotesStoreEntityCount(entity: entity, rows: rows)
    }
  }

  private func storeSearchIndexStateCounts(storePath: String) throws
    -> [NotesStoreSearchIndexStateCount]
  {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select coalesce(cast(ZSTATEVALUE as text), 'null') as state_value, count(*) as rows
        from ZICSEARCHINDEXSTATE
        group by ZSTATEVALUE
        order by ZSTATEVALUE;
        """
    )
    return rows.compactMap { row in
      guard
        let stateValue = stringValue(row["state_value"]),
        let rows = intValue(row["rows"])
      else {
        return nil
      }
      return NotesStoreSearchIndexStateCount(stateValue: stateValue, rows: rows)
    }
  }

  private func storeSchemaTables(storePath: String) throws -> [NotesStoreSchemaTableRecord] {
    let tableRows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select name
        from sqlite_master
        where type = 'table'
        order by name;
        """
    )
    return try tableRows.compactMap { row in
      guard let tableName = stringValue(row["name"]) else {
        return nil
      }
      let columnRows = try sqliteJSONRows(
        storePath: storePath,
        sql: "pragma table_info(\(sqliteIdentifier(tableName)));"
      )
      let columns = columnRows.compactMap { stringValue($0["name"]) }
      return NotesStoreSchemaTableRecord(
        tableName: tableName,
        columnCount: columns.count,
        columns: columns
      )
    }
  }

  private func noteStoreObject(
    storePath: String,
    reference: CoreDataObjectReference,
    noteID: String
  ) throws -> NotesStoreObjectRecord {
    guard
      let row = try sqliteJSONRows(
        storePath: storePath,
        sql: """
          select
            pk.Z_NAME as entity,
            object.Z_PK as primary_key,
            object.ZMARKEDFORDELETION as marked_for_deletion,
            object.ZISPASSWORDPROTECTED as password_protected,
            object.ZISPINNED as pinned,
            object.ZFOLDER as folder_primary_key,
            object.ZACCOUNT7 as account_primary_key,
            object.ZNOTEDATA as note_data_primary_key,
            length(coalesce(object.ZTITLE, '')) as title_length,
            length(coalesce(object.ZSNIPPET, '')) as snippet_length
          from ZICCLOUDSYNCINGOBJECT object
          left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
          where object.Z_PK = \(reference.primaryKey)
            and pk.Z_NAME = \(sqliteStringLiteral(reference.entity))
          limit 1;
          """
      ).first
    else {
      return NotesStoreObjectRecord(
        entity: reference.entity,
        primaryKey: reference.primaryKey,
        matched: false,
        searchIndexStateCounts: try searchIndexStateCounts(storePath: storePath, objectID: noteID)
      )
    }

    return NotesStoreObjectRecord(
      entity: stringValue(row["entity"]),
      primaryKey: int64Value(row["primary_key"]),
      matched: true,
      markedForDeletion: boolValue(row["marked_for_deletion"]),
      passwordProtected: boolValue(row["password_protected"]),
      pinned: boolValue(row["pinned"]),
      folderPrimaryKey: int64Value(row["folder_primary_key"]),
      accountPrimaryKey: int64Value(row["account_primary_key"]),
      noteDataPrimaryKey: int64Value(row["note_data_primary_key"]),
      titleLength: intValue(row["title_length"]),
      snippetLength: intValue(row["snippet_length"]),
      searchIndexStateCounts: try searchIndexStateCounts(storePath: storePath, objectID: noteID)
    )
  }

  private func folderStoreObject(
    storePath: String,
    reference: CoreDataObjectReference,
    folderID: String
  ) throws -> NotesStoreObjectRecord {
    guard
      let row = try sqliteJSONRows(
        storePath: storePath,
        sql: """
          select
            pk.Z_NAME as entity,
            object.Z_PK as primary_key,
            object.ZMARKEDFORDELETION as marked_for_deletion,
            object.ZPARENT as parent_primary_key,
            object.ZACCOUNT8 as account_primary_key,
            object.ZFOLDERTYPE as folder_type,
            length(coalesce(object.ZTITLE2, object.ZTITLE, object.ZNAME, '')) as title_length,
            length(coalesce(object.ZSMARTFOLDERQUERYJSON, '')) as smart_query_json_length
          from ZICCLOUDSYNCINGOBJECT object
          left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
          where object.Z_PK = \(reference.primaryKey)
            and pk.Z_NAME = \(sqliteStringLiteral(reference.entity))
          limit 1;
          """
      ).first
    else {
      return NotesStoreObjectRecord(
        entity: reference.entity,
        primaryKey: reference.primaryKey,
        matched: false,
        searchIndexStateCounts: try searchIndexStateCounts(storePath: storePath, objectID: folderID)
      )
    }

    return NotesStoreObjectRecord(
      entity: stringValue(row["entity"]),
      primaryKey: int64Value(row["primary_key"]),
      matched: true,
      markedForDeletion: boolValue(row["marked_for_deletion"]),
      accountPrimaryKey: int64Value(row["account_primary_key"]),
      parentPrimaryKey: int64Value(row["parent_primary_key"]),
      folderType: intValue(row["folder_type"]),
      titleLength: intValue(row["title_length"]),
      smartFolderQueryJSONLength: intValue(row["smart_query_json_length"]),
      noteCount: try noteCount(storePath: storePath, folderPrimaryKey: reference.primaryKey),
      childFolderCount: try childFolderCount(
        storePath: storePath, folderPrimaryKey: reference.primaryKey),
      searchIndexStateCounts: try searchIndexStateCounts(storePath: storePath, objectID: folderID)
    )
  }

  private func accountStoreObject(
    storePath: String,
    reference: CoreDataObjectReference,
    accountID: String
  ) throws -> NotesStoreObjectRecord {
    guard
      let row = try sqliteJSONRows(
        storePath: storePath,
        sql: """
          select
            pk.Z_NAME as entity,
            object.Z_PK as primary_key,
            object.ZMARKEDFORDELETION as marked_for_deletion,
            object.ZACCOUNTTYPE as account_type,
            length(coalesce(object.ZACCOUNTNAMEFORACCOUNTLISTSORTING, object.ZNAME, '')) as title_length
          from ZICCLOUDSYNCINGOBJECT object
          left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
          where object.Z_PK = \(reference.primaryKey)
            and pk.Z_NAME = \(sqliteStringLiteral(reference.entity))
          limit 1;
          """
      ).first
    else {
      return NotesStoreObjectRecord(
        entity: reference.entity,
        primaryKey: reference.primaryKey,
        matched: false,
        searchIndexStateCounts: try searchIndexStateCounts(storePath: storePath, objectID: accountID)
      )
    }

    return NotesStoreObjectRecord(
      entity: stringValue(row["entity"]),
      primaryKey: int64Value(row["primary_key"]),
      matched: true,
      markedForDeletion: boolValue(row["marked_for_deletion"]),
      accountType: intValue(row["account_type"]),
      titleLength: intValue(row["title_length"]),
      noteCount: try noteCount(storePath: storePath, accountPrimaryKey: reference.primaryKey),
      folderCount: try folderCount(storePath: storePath, accountPrimaryKey: reference.primaryKey),
      searchIndexStateCounts: try searchIndexStateCounts(storePath: storePath, objectID: accountID)
    )
  }

  private func noteCount(storePath: String, folderPrimaryKey: Int64) throws -> Int {
    try scalarCount(
      storePath: storePath,
      sql: """
        select count(*) as rows
        from ZICCLOUDSYNCINGOBJECT object
        left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
        where pk.Z_NAME = 'ICNote'
          and object.ZFOLDER = \(folderPrimaryKey)
          and coalesce(object.ZMARKEDFORDELETION, 0) = 0;
        """
    )
  }

  private func noteCount(storePath: String, accountPrimaryKey: Int64) throws -> Int {
    try scalarCount(
      storePath: storePath,
      sql: """
        select count(*) as rows
        from ZICCLOUDSYNCINGOBJECT object
        left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
        where pk.Z_NAME = 'ICNote'
          and object.ZACCOUNT7 = \(accountPrimaryKey)
          and coalesce(object.ZMARKEDFORDELETION, 0) = 0;
        """
    )
  }

  private func childFolderCount(storePath: String, folderPrimaryKey: Int64) throws -> Int {
    try scalarCount(
      storePath: storePath,
      sql: """
        select count(*) as rows
        from ZICCLOUDSYNCINGOBJECT object
        left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
        where pk.Z_NAME = 'ICFolder'
          and object.ZPARENT = \(folderPrimaryKey)
          and coalesce(object.ZMARKEDFORDELETION, 0) = 0;
        """
    )
  }

  private func folderCount(storePath: String, accountPrimaryKey: Int64) throws -> Int {
    try scalarCount(
      storePath: storePath,
      sql: """
        select count(*) as rows
        from ZICCLOUDSYNCINGOBJECT object
        left join Z_PRIMARYKEY pk on pk.Z_ENT = object.Z_ENT
        where pk.Z_NAME = 'ICFolder'
          and object.ZACCOUNT8 = \(accountPrimaryKey)
          and coalesce(object.ZMARKEDFORDELETION, 0) = 0;
        """
    )
  }

  private func scalarCount(storePath: String, sql: String) throws -> Int {
    let rows = try sqliteJSONRows(storePath: storePath, sql: sql)
    return rows.first.flatMap { intValue($0["rows"]) } ?? 0
  }

  private func searchIndexStateCounts(storePath: String, objectID: String) throws
    -> [NotesStoreSearchIndexStateRecord]
  {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select coalesce(cast(ZSTATEVALUE as text), 'null') as state_value, count(*) as rows
        from ZICSEARCHINDEXSTATE
        where ZIDENTIFIER = \(sqliteStringLiteral(objectID))
        group by ZSTATEVALUE
        order by ZSTATEVALUE;
        """
    )
    return rows.compactMap { row in
      guard
        let stateValue = stringValue(row["state_value"]),
        let rows = intValue(row["rows"])
      else {
        return nil
      }
      return NotesStoreSearchIndexStateRecord(stateValue: stateValue, rows: rows)
    }
  }

  private func sqliteJSONRows(storePath: String, sql: String) throws -> [[String: Any]] {
    let result = try CLISubprocess.run(
      .path("/usr/bin/sqlite3"),
      arguments: ["-readonly", "-json", storePath, sql],
      timeoutSeconds: 5,
      outputLimit: 256 * 1024
    )
    guard result.exitCode == 0 else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Read-only Notes store query failed.",
        details: [
          "store_path": storePath,
          "exit_code": "\(result.exitCode)",
          "stderr": result.stderr,
        ]
      )
    }

    let trimmed = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return []
    }

    let data = Data(trimmed.utf8)
    guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Read-only Notes store query did not return JSON rows.",
        details: ["store_path": storePath]
      )
    }
    return rows
  }

  private func countValue(named type: String, in rows: [[String: Any]]) -> Int {
    rows.first { stringValue($0["type"]) == type }
      .flatMap { intValue($0["rows"]) } ?? 0
  }

  private func stringValue(_ value: Any?) -> String? {
    switch value {
    case let string as String:
      return string
    case let number as NSNumber:
      return number.stringValue
    default:
      return nil
    }
  }

  private func int64Value(_ value: Any?) -> Int64? {
    switch value {
    case let number as NSNumber:
      return number.int64Value
    case let string as String:
      return Int64(string)
    default:
      return nil
    }
  }

  private func intValue(_ value: Any?) -> Int? {
    int64Value(value).map(Int.init)
  }

  private func boolValue(_ value: Any?) -> Bool? {
    switch value {
    case let number as NSNumber:
      return number.intValue != 0
    case let string as String:
      if let int = Int(string) {
        return int != 0
      }
      return nil
    default:
      return nil
    }
  }

  private func addFileDetails(
    prefix: String,
    file: NotesStoreFileEvidence,
    to details: inout [String: String]
  ) {
    details["\(prefix)_present"] = boolString(file.exists)
    details["\(prefix)_readable"] = boolString(file.isReadable)
    if let sizeBytes = file.sizeBytes {
      details["\(prefix)_size_bytes"] = "\(sizeBytes)"
    }
    if let modifiedAt = file.modifiedAt {
      details["\(prefix)_modified_at"] = formatDate(modifiedAt)
    }
  }

  private func fileRecord(_ evidence: NotesStoreFileEvidence) -> NotesStoreFileRecord {
    NotesStoreFileRecord(
      path: displayPath(evidence.path),
      exists: evidence.exists,
      isDirectory: evidence.isDirectory,
      isReadable: evidence.isReadable,
      sizeBytes: evidence.sizeBytes,
      modifiedAt: evidence.modifiedAt
    )
  }

  private func entityCountRecord(_ count: NotesStoreEntityCount) -> NotesStoreEntityCountRecord {
    NotesStoreEntityCountRecord(entity: count.entity, rows: count.rows)
  }

  private func searchIndexStateRecord(_ count: NotesStoreSearchIndexStateCount)
    -> NotesStoreSearchIndexStateRecord
  {
    NotesStoreSearchIndexStateRecord(stateValue: count.stateValue, rows: count.rows)
  }

  private func displayPath(_ path: String) -> String {
    let homePath = homeDirectory.standardizedFileURL.path
    if path == homePath {
      return "~"
    }
    let prefix = homePath + "/"
    if path.hasPrefix(prefix) {
      return "~/" + String(path.dropFirst(prefix.count))
    }
    return path
  }

  private func sqliteIdentifier(_ value: String) -> String {
    "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
  }

  private func sqliteStringLiteral(_ value: String) -> String {
    "'\(value.replacingOccurrences(of: "'", with: "''"))'"
  }

  private func coreDataObjectReference(_ id: String) -> CoreDataObjectReference? {
    guard let url = URL(string: id), url.scheme == "x-coredata" else {
      return nil
    }
    let components = url.pathComponents.filter { $0 != "/" }
    guard components.count >= 2 else {
      return nil
    }
    let entity = components[components.count - 2]
    let primaryKeyComponent = components[components.count - 1]
    guard primaryKeyComponent.hasPrefix("p") else {
      return nil
    }
    guard let primaryKey = Int64(primaryKeyComponent.dropFirst()) else {
      return nil
    }
    return CoreDataObjectReference(entity: entity, primaryKey: primaryKey)
  }

  private func entityCountsDescription(_ counts: [NotesStoreEntityCount]) -> String {
    counts
      .sorted { $0.entity < $1.entity }
      .map { "\($0.entity):\($0.rows)" }
      .joined(separator: ",")
  }

  private func searchIndexStateDescription(_ counts: [NotesStoreSearchIndexStateCount]) -> String {
    counts
      .sorted { $0.stateValue < $1.stateValue }
      .map { "state_\($0.stateValue):\($0.rows)" }
      .joined(separator: ",")
  }

  private func boolString(_ value: Bool) -> String {
    value ? "true" : "false"
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
  }
}

func notesStoreDoctorCheck(
  sqliteReader: SQLiteReader = SQLiteReader()
) -> CLIDoctorCheck {
  sqliteReader.doctorCheck()
}
