@testable import NotesCLI
import Foundation
import Testing
import Utility

@Suite
struct SQLiteReaderTests {
  @Test func storeDoctorReportsBoundedStoreAndIndexEvidence() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }

    let container = home
      .appendingPathComponent("Library", isDirectory: true)
      .appendingPathComponent("Group Containers", isDirectory: true)
      .appendingPathComponent("group.com.apple.notes", isDirectory: true)
    try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)

    let store = container.appendingPathComponent("NoteStore.sqlite")
    try createFixtureStore(at: store)
    FileManager.default.createFile(
      atPath: container.appendingPathComponent("NoteStore.sqlite-wal").path,
      contents: Data("wal".utf8)
    )
    FileManager.default.createFile(
      atPath: container.appendingPathComponent("NotesIndexerState-Modern").path,
      contents: Data("index".utf8)
    )

    let check = notesStoreDoctorCheck(sqliteReader: SQLiteReader(homeDirectory: home))

    #expect(check.status == .ok)
    #expect(check.name == "notes_store")
    #expect(check.details["container_path"] == "~/Library/Group Containers/group.com.apple.notes")
    #expect(
      check.details["store_path"]
        == "~/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite")
    #expect(check.details["container_exists"] == "true")
    #expect(check.details["store_present"] == "true")
    #expect(check.details["store_readable"] == "true")
    #expect(check.details["wal_present"] == "true")
    #expect(check.details["shm_present"] == "false")
    #expect(check.details["index_state_files"] == "NotesIndexerState-Modern")
    #expect(check.details["schema_table_count"] == "4")
    #expect(check.details["schema_index_count"] == "1")
    #expect(check.details["required_tables_missing"] == "")
    #expect(check.details["entity_counts"] == "ICAccount:1,ICFolder:1,ICNote:2")
    #expect(check.details["search_index_state_counts"] == "state_4:3")
    #expect(check.details["body_output"] == "none")
    #expect(check.details["write_access"] == "none")
    #expect(check.details.values.contains { $0.contains("Sensitive Plan") } == false)
  }

  @Test func storeDoctorWarnsWhenContainerIsMissing() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }

    let check = notesStoreDoctorCheck(sqliteReader: SQLiteReader(homeDirectory: home))

    #expect(check.status == .warning)
    #expect(check.details["container_exists"] == "false")
    #expect(check.details["store_present"] == "false")
    #expect(check.details["warnings"]?.contains("Notes group container was not found.") == true)
  }

  @Test func storeDebugScopesExposeOnlyBoundedEvidence() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }
    try createFixtureContainer(home: home)

    let reader = SQLiteReader(homeDirectory: home)
    let schema = try reader.debugStore(scope: "schema")
    let entities = try reader.debugStore(scope: "entities")
    let indexes = try reader.debugStore(scope: "indexes")

    #expect(schema.scope == "schema")
    #expect(schema.schemaTables.map(\.tableName).contains("ZICCLOUDSYNCINGOBJECT"))
    #expect(schema.entityCounts.isEmpty)
    #expect(entities.entityCounts == [
      NotesStoreEntityCountRecord(entity: "ICAccount", rows: 1),
      NotesStoreEntityCountRecord(entity: "ICFolder", rows: 1),
      NotesStoreEntityCountRecord(entity: "ICNote", rows: 2),
    ])
    #expect(entities.schemaTables.isEmpty)
    #expect(indexes.searchIndexStateCounts == [
      NotesStoreSearchIndexStateRecord(stateValue: "4", rows: 3)
    ])
    #expect(indexes.entityCounts.isEmpty)

    let encoded = try CLIJSON.encodeString(schema)
    #expect(encoded.contains("Sensitive Plan") == false)
    #expect(encoded.contains("Another Sensitive Plan") == false)
  }

  @Test func notesDoctorStoreCommandReturnsScopedJSON() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }
    try createFixtureContainer(home: home)

    let command = NotesCommand(
      implementation: FixtureNotesImplementation(),
      sqliteReader: SQLiteReader(homeDirectory: home)
    )
    let options = try CLIOptionsFixture.parse([
      "doctor",
      "store",
      "--scope",
      "entities",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let entityCounts = data?["entityCounts"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(data?["scope"] as? String == "entities")
    #expect((data?["schemaTables"] as? [[String: Any]])?.isEmpty == true)
    #expect(entityCounts?.compactMap { $0["entity"] as? String } == [
      "ICAccount", "ICFolder", "ICNote",
    ])
    #expect(result.stdout?.contains("Sensitive Plan") == false)
  }

  @Test func notesDoctorNoteCommandReturnsPrivateAndStoreEvidenceWithoutContent() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }
    try createFixtureContainer(home: home)

    let command = NotesCommand(
      implementation: FixtureNotesImplementation(),
      sqliteReader: SQLiteReader(homeDirectory: home)
    )
    let options = try CLIOptionsFixture.parse([
      "doctor",
      "note",
      "--id",
      fixtureNoteID,
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let readback = data?["readback"] as? [String: Any]
    let storeObject = data?["storeObject"] as? [String: Any]

    #expect(data?["kind"] as? String == "note")
    #expect(readback?["titleSHA256"] as? String != nil)
    #expect(readback?["bodySHA256"] as? String != nil)
    #expect(storeObject?["entity"] as? String == "ICNote")
    #expect(storeObject?["primaryKey"] as? Int == 1)
    #expect(storeObject?["matched"] as? Bool == true)
    #expect(storeObject?["folderPrimaryKey"] as? Int == 4)
    #expect(storeObject?["accountPrimaryKey"] as? Int == 3)
    #expect(result.stdout?.contains("Sensitive Plan") == false)
    #expect(result.stdout?.contains("Private body") == false)
    #expect(result.stdout?.contains(fixtureNoteID) == false)
  }

  @Test func notesDoctorFolderAndAccountCommandsReturnScopedEvidence() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }
    try createFixtureContainer(home: home)

    let command = NotesCommand(
      implementation: FixtureNotesImplementation(),
      sqliteReader: SQLiteReader(homeDirectory: home)
    )
    let folderResult = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "doctor", "folder", "--folder", fixtureFolderID, "--json",
        ])))
    let accountResult = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "doctor", "account", "--account", fixtureAccountID, "--json",
        ])))

    let folderData = try jsonObject(folderResult.stdout ?? "")["data"] as? [String: Any]
    let folderStore = folderData?["storeObject"] as? [String: Any]
    let accountData = try jsonObject(accountResult.stdout ?? "")["data"] as? [String: Any]
    let accountStore = accountData?["storeObject"] as? [String: Any]

    #expect(folderData?["kind"] as? String == "folder")
    #expect(folderStore?["entity"] as? String == "ICFolder")
    #expect(folderStore?["folderType"] as? Int == 0)
    #expect(folderStore?["noteCount"] as? Int == 2)
    #expect(accountData?["kind"] as? String == "account")
    #expect(accountStore?["entity"] as? String == "ICAccount")
    #expect(accountStore?["accountType"] as? Int == 1)
    #expect(accountStore?["noteCount"] as? Int == 2)
    #expect(accountStore?["folderCount"] as? Int == 1)
    #expect(folderResult.stdout?.contains("Private Folder") == false)
    #expect(accountResult.stdout?.contains("Private Account") == false)
  }

  @Test func storeDebugRejectsUnknownScope() throws {
    let home = try makeTemporaryHome()
    defer { try? FileManager.default.removeItem(at: home) }

    do {
      _ = try SQLiteReader(homeDirectory: home).debugStore(scope: "content")
      Issue.record("Expected unknown Notes store scope to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("summary, schema, entities, indexes"))
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private func makeTemporaryHome() throws -> URL {
  let home = FileManager.default.temporaryDirectory
    .appendingPathComponent("SQLiteReaderTests-\(UUID().uuidString)", isDirectory: true)
  try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
  return home
}

private func createFixtureContainer(home: URL) throws {
  let container = home
    .appendingPathComponent("Library", isDirectory: true)
    .appendingPathComponent("Group Containers", isDirectory: true)
    .appendingPathComponent("group.com.apple.notes", isDirectory: true)
  try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)

  try createFixtureStore(at: container.appendingPathComponent("NoteStore.sqlite"))
  FileManager.default.createFile(
    atPath: container.appendingPathComponent("NoteStore.sqlite-wal").path,
    contents: Data("wal".utf8)
  )
  FileManager.default.createFile(
    atPath: container.appendingPathComponent("NotesIndexerState-Modern").path,
    contents: Data("index".utf8)
  )
}

private func createFixtureStore(at url: URL) throws {
  let sql = """
    create table Z_PRIMARYKEY (
      Z_ENT integer,
      Z_NAME varchar,
      Z_SUPER integer,
      Z_MAX integer
    );
    create table ZICCLOUDSYNCINGOBJECT (
      Z_PK integer primary key,
      Z_ENT integer,
      ZTITLE varchar,
      ZTITLE2 varchar,
      ZNAME varchar,
      ZSNIPPET varchar,
      ZMARKEDFORDELETION integer,
      ZISPASSWORDPROTECTED integer,
      ZISPINNED integer,
      ZFOLDER integer,
      ZACCOUNT7 integer,
      ZNOTEDATA integer,
      ZPARENT integer,
      ZACCOUNT8 integer,
      ZFOLDERTYPE integer,
      ZSMARTFOLDERQUERYJSON varchar,
      ZACCOUNTNAMEFORACCOUNTLISTSORTING varchar,
      ZACCOUNTTYPE integer
    );
    create table ZICNOTEDATA (
      Z_PK integer primary key
    );
    create table ZICSEARCHINDEXSTATE (
      Z_PK integer primary key,
      ZSTATEVALUE integer,
      ZIDENTIFIER varchar
    );
    create index ZICCLOUDSYNCINGOBJECT_Z_ENT_INDEX on ZICCLOUDSYNCINGOBJECT(Z_ENT);
    insert into Z_PRIMARYKEY (Z_ENT, Z_NAME, Z_SUPER, Z_MAX) values
      (12, 'ICNote', 3, 0),
      (14, 'ICAccount', 13, 0),
      (15, 'ICFolder', 13, 0);
    insert into ZICCLOUDSYNCINGOBJECT (
      Z_PK, Z_ENT, ZTITLE, ZTITLE2, ZNAME, ZSNIPPET, ZMARKEDFORDELETION,
      ZISPASSWORDPROTECTED, ZISPINNED, ZFOLDER, ZACCOUNT7, ZNOTEDATA, ZPARENT,
      ZACCOUNT8, ZFOLDERTYPE, ZSMARTFOLDERQUERYJSON, ZACCOUNTNAMEFORACCOUNTLISTSORTING,
      ZACCOUNTTYPE
    ) values
      (1, 12, 'Sensitive Plan', null, null, 'abc', 0, 0, 1, 4, 3, 10, null, null, null, null, null, null),
      (2, 12, 'Another Sensitive Plan', null, null, 'def', 0, 0, 0, 4, 3, 11, null, null, null, null, null, null),
      (3, 14, null, null, 'Private Account', null, 0, 0, 0, null, null, null, null, null, null, null, 'Private Account', 1),
      (4, 15, null, 'Private Folder', null, null, 0, 0, 0, null, null, null, null, 3, 0, '', null, null);
    insert into ZICSEARCHINDEXSTATE (Z_PK, ZSTATEVALUE, ZIDENTIFIER) values
      (1, 4, 'x-coredata://fixture/ICNote/p1'),
      (2, 4, 'x-coredata://fixture/ICFolder/p4'),
      (3, 4, 'x-coredata://fixture/ICAccount/p3');
    """
  let result = try CLISubprocess.run(
    .path("/usr/bin/sqlite3"),
    arguments: [url.path, sql],
    timeoutSeconds: 5,
    outputLimit: 64 * 1024
  )
  #expect(result.exitCode == 0)
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}

private let fixtureNoteID = "x-coredata://fixture/ICNote/p1"
private let fixtureFolderID = "x-coredata://fixture/ICFolder/p4"
private let fixtureAccountID = "x-coredata://fixture/ICAccount/p3"

private struct FixtureNotesImplementation: NotesReading, NotesMutating {
  func listAccounts() throws -> [NotesAccountRecord] {
    [NotesAccountRecord(id: fixtureAccountID, name: "Private Account")]
  }

  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    [
      NotesFolderRecord(id: fixtureFolderID, name: "Private Folder", accountName: "Private Account")
    ].prefix(limit).map { $0 }
  }

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    [
      NotesNoteSummary(
        id: fixtureNoteID,
        title: "Sensitive Plan",
        folderName: "Private Folder",
        accountName: "Private Account"
      )
    ].prefix(limit).map { $0 }
  }

  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try listNotes(folder: folder, limit: limit)
  }

  func readNote(id: String) throws -> NotesNoteDetail? {
    guard id == fixtureNoteID else {
      return nil
    }
    return NotesNoteDetail(
      id: fixtureNoteID,
      title: "Sensitive Plan",
      folderName: "Private Folder",
      accountName: "Private Account",
      body: "Private body"
    )
  }

  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    []
  }
  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func deleteNote(id: String) throws -> Bool {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func purgeNote(id: String) throws -> Bool {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw CLIError(code: .unsupportedOperation, message: "Noop implementation does not mutate.")
  }
}
