import AppleMCPAdapter
import CryptoKit
import Foundation
import MCP
import Testing
import Utility

@testable import RemindersCLI

@Suite
struct RemindersAttachmentExportTests {
  @Test func listAndSingleExportPreserveIdentityContentAndJSON() throws {
    let fixture = try AttachmentFixture()
    let rows = try fixture.runList()
    let item = try #require(rows.attachments.first)
    #expect(rows.reminderId == "meeting")
    #expect(rows.attachments.count == 1)
    #expect(item.id == firstAttachment)
    #expect(item.fileName == "meeting.pdf")
    #expect(item.kind == .file && item.typeIdentifier == "com.adobe.pdf")
    #expect(item.localAvailable && item.status == .available && item.integrity == .storedSHA512)
    #expect(item.sizeBytes == Int64(pdfBytes.count) && item.sha512 == fixtureHash(pdfBytes))
    let listJSON = try #require(try fixture.run(["attachments", "list"]).stdout)
    #expect(!listJSON.contains("Group Containers"))
    #expect(!listJSON.contains("Account-"))

    let output = fixture.home.appendingPathComponent("original.pdf")
    let outputPath = output.path.hasPrefix("/var/") ? "/private" + output.path : output.path
    let preview: CLIDryRun = try fixture.decode(
      fixture.export(output, selector: "meeting.pdf", dryRun: true))
    #expect(preview.requirements.allowFlags == ["--allow-artifact-action"])
    #expect(preview.wouldMutate.first?.identifier == outputPath)
    #expect(preview.wouldMutate.first?.fields["sha512"] == item.sha512)
    #expect(!FileManager.default.fileExists(atPath: output.path))
    let result: ReminderAttachmentExportResult = try fixture.decode(
      fixture.export(output, selector: firstAttachment.uuidString.lowercased()))
    #expect(result.operation == "reminders.attachments.export")
    #expect(result.reminderId == "meeting")
    #expect(result.files.first?.attachmentId == firstAttachment)
    #expect(result.files.first?.path == outputPath && result.files.first?.sha512 == item.sha512)
    #expect(try Data(contentsOf: output) == pdfBytes)
    #expect(try Data(contentsOf: fixture.cacheURL(pdfBytes, ext: "pdf")) == pdfBytes)
    #expect(try fixture.runList().attachments.first?.id == item.id)
    expectCLIError(.unsafeMutationRefused) { try fixture.export(output, selector: "meeting.pdf") }
    #expect(try Data(contentsOf: output) == pdfBytes)
  }

  @Test func bulkUsesSafeNamesReportsLinksAndRefusesAmbiguousSelectors() throws {
    let fixture = try AttachmentFixture(attachments: [
      .init(firstAttachment, name: "Meeting.pdf", bytes: pdfBytes),
      .init(secondAttachment, name: "Meeting.pdf", bytes: secondBytes),
      .init(
        thirdAttachment, name: "../escape.png", bytes: secondBytes,
        entity: 4, uti: "public.png"),
      .init(fourthAttachment, name: nil, bytes: nil, entity: 5, uti: "public.url"),
    ])
    let output = fixture.home.appendingPathComponent("export")
    let listing = try fixture.runList()
    #expect(listing.attachments.count == 4)
    #expect(listing.attachments.last?.kind == .link)
    #expect(listing.attachments.last?.status == .unsupportedType)
    expectCLIError(.ambiguousIdentity) { try fixture.export(output, selector: "Meeting.pdf") }
    expectCLIError(.unsupportedOperation, status: "unsupported_type") {
      try fixture.export(output, selector: fourthAttachment.uuidString)
    }
    let result: ReminderAttachmentExportResult = try fixture.decode(fixture.export(output))
    #expect(result.skippedAttachmentIds == [fourthAttachment])
    #expect(
      result.files.map(\.attachmentId) == [firstAttachment, secondAttachment, thirdAttachment])
    #expect(
      Set(try FileManager.default.contentsOfDirectory(atPath: output.path)) == [
        "Meeting.pdf", "Meeting (2).pdf", "attachment-\(thirdAttachment.uuidString).png",
      ])
    for (file, bytes) in zip(result.files, [pdfBytes, secondBytes, secondBytes]) {
      #expect(try Data(contentsOf: URL(fileURLWithPath: file.path)) == bytes)
      #expect(file.sha512 == fixtureHash(bytes))
    }
    #expect(
      !FileManager.default.fileExists(
        atPath: fixture.home.appendingPathComponent("escape.png").path))
    expectCLIError(.unsafeMutationRefused) { try fixture.export(output) }
  }

  @Test func accountAndReminderScopePrecedeNativeSelection() throws {
    let fixture = try AttachmentFixture()
    try fixture.createStore(
      "Data-other.sqlite", account: otherAccount, reminder: otherReminder,
      id: "meeting", attachments: [.init(secondAttachment, name: "other.pdf", bytes: secondBytes)])
    let native = ReminderNativeAttachmentInventory(
      inventory: .init(
        reminderId: "meeting", reminderUUID: firstReminder, accountUUID: firstAccount,
        attachments: []))
    expectCLIError(.ambiguousIdentity) {
      try fixture.run(["attachments", "list"], native: native)
    }
    let objectID = "x-apple-reminderkit://REMCDReminder/\(firstReminder.uuidString)"
    let exact = try fixture.runList(id: objectID)
    #expect(exact.reminderId == objectID && exact.attachments.map(\.id) == [firstAttachment])
    let output = fixture.home.appendingPathComponent("wrong.pdf")
    expectCLIError(.notFound) {
      try fixture.export(output, id: objectID, selector: secondAttachment.uuidString)
    }
    try FileManager.default.removeItem(at: fixture.cacheURL(pdfBytes, ext: "pdf"))
    try fixture.putCache(pdfBytes, ext: "pdf", account: otherAccount)
    #expect(try fixture.runList(id: objectID).attachments.first?.status == .missingLocalFile)
    #expect(try fixture.runList(id: "ck-meeting-first").attachments.map(\.id) == [firstAttachment])
  }

  @Test func deletedRecordsAreExcludedAndMismatchedOwnershipIsRejected() throws {
    let fixture = try AttachmentFixture(attachments: [
      .init(firstAttachment, name: "active.pdf", bytes: pdfBytes),
      .init(secondAttachment, name: "deleted.pdf", bytes: secondBytes, deleted: true),
    ])
    let staleNative = ReminderNativeAttachmentInventory(
      inventory: .init(
        reminderId: "meeting", reminderUUID: firstReminder, accountUUID: firstAccount,
        attachments: [
          .init(
            id: secondAttachment, kind: .file, typeIdentifier: "com.adobe.pdf",
            nativeURL: fixture.cacheURL(secondBytes, ext: "pdf"))
        ]))
    let listing: ReminderAttachmentsListResult = try fixture.decode(
      fixture.run(["attachments", "list"], native: staleNative))
    #expect(listing.attachments.map(\.id) == [firstAttachment])
    try fixture.sql("UPDATE ZREMCDREMINDER SET ZMARKEDFORDELETION = 1;")
    expectCLIError(.notFound) { try fixture.runList() }
    expectCLIError(.notFound) {
      try fixture.run(
        ["attachments", "list"],
        id: "x-apple-reminderkit://REMCDReminder/\(firstReminder.uuidString)", native: staleNative)
    }
    try fixture.sql(
      "UPDATE ZREMCDREMINDER SET ZMARKEDFORDELETION = 0; UPDATE ZREMCDOBJECT SET ZACCOUNT = 42 WHERE Z_PK = 10;"
    )
    expectCLIError(.backendUnavailable) { try fixture.runList() }
  }

  @Test func missingCorruptAndAmbiguousCacheNeverPublishABatch() throws {
    let fixture = try AttachmentFixture(attachments: [
      .init(firstAttachment, name: "first.pdf", bytes: pdfBytes),
      .init(secondAttachment, name: "other.pdf", bytes: secondBytes),
      .init(thirdAttachment, name: "cloud.png", bytes: nil, entity: 4, uti: "public.png"),
    ])
    let output = fixture.home.appendingPathComponent("missing")
    let other = fixture.cacheURL(secondBytes, ext: "pdf")
    try FileManager.default.removeItem(at: other)
    #expect(
      try fixture.runList().attachments.map(\.status) == [
        .available, .missingLocalFile, .missingContentHash,
      ])
    expectCLIError(.backendUnavailable, status: "missing_local_file") { try fixture.export(output) }
    #expect(!FileManager.default.fileExists(atPath: output.path))

    try Data(repeating: 0, count: secondBytes.count).write(to: other)
    #expect(try fixture.runList().attachments[1].status == .integrityMismatch)
    expectCLIError(.backendUnavailable, status: "integrity_mismatch") {
      try fixture.export(output, dryRun: true)
    }
    #expect(!FileManager.default.fileExists(atPath: output.path))

    try fixture.putCache(secondBytes, ext: "bin")
    #expect(try fixture.runList().attachments[1].status == .ambiguousLocalFile)
    expectCLIError(.backendUnavailable, status: "ambiguous_local_file") {
      try fixture.export(output)
    }
    #expect(!FileManager.default.fileExists(atPath: output.path))
  }

  @Test func nativeOriginalIsPreferredAndSchemaDriftIsExplicit() throws {
    let fixture = try AttachmentFixture()
    let nativeURL = fixture.home.appendingPathComponent("native-original.pdf")
    try pdfBytes.write(to: nativeURL)
    var native = ReminderNativeAttachmentInventory(
      inventory: .init(
        reminderId: "meeting", reminderUUID: firstReminder, accountUUID: firstAccount,
        attachments: [
          .init(
            id: firstAttachment, kind: .file, typeIdentifier: "com.adobe.pdf",
            sizeBytes: Int64(pdfBytes.count), nativeURL: nativeURL)
        ]))
    try Data(repeating: 0, count: pdfBytes.count).write(to: fixture.cacheURL(pdfBytes, ext: "pdf"))
    let original: ReminderAttachmentsListResult = try fixture.decode(
      fixture.run(["attachments", "list"], native: native))
    #expect(original.attachments.first?.integrity == .storedSHA512)
    #expect(original.attachments.first?.fileName == "meeting.pdf")
    native.inventory.attachments[0].typeIdentifier = "public.png"
    expectCLIError(.backendUnavailable) {
      try fixture.run(["attachments", "list"], native: native)
    }
    native.inventory.attachments[0].typeIdentifier = "com.adobe.pdf"

    try fixture.sql("ALTER TABLE ZREMCDOBJECT DROP COLUMN ZSHA512SUM;")
    #expect(try fixture.runList().attachments.first?.status == .missingContentHash)
    let nativeOnly: ReminderAttachmentsListResult = try fixture.decode(
      fixture.run(["attachments", "list"], native: native))
    #expect(nativeOnly.attachments.first?.integrity == .nativeOriginal)
    try fixture.sql("ALTER TABLE ZREMCDOBJECT RENAME COLUMN ZREMINDER2 TO ZUNKNOWN;")
    expectCLIError(.backendUnavailable) { try fixture.runList() }
    let explicit: ReminderAttachmentsListResult = try fixture.decode(
      fixture.run(
        ["attachments", "list"],
        id: "x-apple-reminderkit://REMCDReminder/\(firstReminder.uuidString)", native: native))
    #expect(explicit.attachments.first?.sha512 == fixtureHash(pdfBytes))
  }

  @Test func rejectsTraversalSymlinksPrivatePathsAndUnauthorizedWrites() throws {
    let fixture = try AttachmentFixture()
    let output = fixture.home.appendingPathComponent("output")
    expectCLIError(.unsafeMutationRefused) { try fixture.export(output, allow: false) }
    expectCLIError(.validationError) {
      try fixture.run(
        ["attachments", "export"], options: ["output": fixture.home.path + "/../escaped"])
    }
    expectCLIError(.unsafeMutationRefused) {
      try fixture.export(fixture.reader.remindersContainerURL.appendingPathComponent("output"))
    }
    let alias = fixture.home.appendingPathComponent("symlink")
    try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: fixture.home)
    expectCLIError(.unsafeMutationRefused) { try fixture.export(alias) }
    expectCLIError(.validationError) { try fixture.export(alias.appendingPathComponent("output")) }
    let cache = fixture.cacheURL(pdfBytes, ext: "pdf")
    let ordinaryFile = fixture.home.appendingPathComponent("target.pdf")
    try pdfBytes.write(to: ordinaryFile)
    try FileManager.default.removeItem(at: cache)
    try FileManager.default.createSymbolicLink(at: cache, withDestinationURL: ordinaryFile)
    #expect(try fixture.runList().attachments.first?.status == .unreadable)
    expectCLIError(.backendUnavailable, status: "unreadable") { try fixture.export(output) }
  }

  @Test func lateDestinationAndSourceChangesPreventPublicationWithoutLeavingStaging() throws {
    let fixture = try AttachmentFixture()
    let output = fixture.home.appendingPathComponent("export")
    let destination = try ReminderAttachmentExportDestination(
      output.path, all: true, protectedDirectory: fixture.reader.remindersContainerURL)
    let resolver = ReminderAttachmentResolver(sqliteReader: fixture.reader)
    let inventory = try resolver.inventory(
      for: ReminderAttachmentReminderSelector("meeting"), native: nil)
    let entries = try destination.entries(
      for: inventory.attachments.map {
        resolver.resolve($0, account: inventory.accountUUID)
      })

    try destination.withParent { parent in
      try FileManager.default.createDirectory(at: output, withIntermediateDirectories: false)
      expectCLIError(.unsafeMutationRefused) { try destination.publish(entries, in: parent) }
    }
    #expect(try FileManager.default.contentsOfDirectory(atPath: output.path).isEmpty)
    try FileManager.default.removeItem(at: output)
    let original = try #require(entries.first?.original.url)
    try Data(repeating: 0, count: pdfBytes.count).write(to: original)
    try destination.withParent { parent in
      expectCLIError(.backendUnavailable, status: "integrity_mismatch") {
        try destination.publish(entries, in: parent)
      }
    }
    #expect(!FileManager.default.fileExists(atPath: output.path))
    #expect(
      try FileManager.default.contentsOfDirectory(atPath: fixture.home.path)
        == ["Library"])
  }

  @Test func cliAndMCPDiscoverAttachmentLeavesAndShareTheWriteGate() async throws {
    let help = RemindersTarget.Attachments.helpMessage()
    for name in ["add", "remove", "list", "export"] { #expect(help.contains(name)) }
    #expect(RemindersTarget.Read.helpMessage().contains("--id"))
    let executable =
      ProcessInfo.processInfo.environment["APPLE_CLI_BIN"]
      ?? FileManager.default.currentDirectoryPath + "/.build/debug/apple"
    let dir = URL(fileURLWithPath: executable).deletingLastPathComponent()
    let adapter = AppleMCPAdapter(runner: CLIProcessRunner(binDirectory: dir))
    let result = try await adapter.callTool(
      name: "apple_cli_help",
      arguments: [
        "target": .string("reminders"),
        "arguments": .array(["attachments", "export"].map(Value.string)),
      ])
    let helpResult = try #require(result.structuredContent?.objectValue)
    #expect(result.isError == false)
    let text = try #require(helpResult["stdout"]?.stringValue)
    for option in [
      "--id", "--attachment", "--all", "--output", "--dry-run", "--allow-artifact-action",
    ] {
      #expect(text.contains(option))
    }
    let call = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("reminders"),
        "arguments": .array(
          ["attachments", "export", "--id", "meeting", "--all", "--output", "export"].map(
            Value.string)),
      ])
    let callResult = try #require(call.structuredContent?.objectValue)
    #expect(callResult["exitCode"]?.intValue == Int(CLIErrorCode.unsafeMutationRefused.exitCode))
    #expect(callResult["stdout"]?.stringValue?.contains("unsafe_mutation_refused") == true)
  }

  @Test func existingReadAddAndRemoveKeepTheirAttachmentContracts() throws {
    let fixture = try AttachmentFixture()
    let file = fixture.home.appendingPathComponent("meeting.pdf")
    try pdfBytes.write(to: file)
    let read = try RemindersTarget.Read.parse(["--id", "meeting", "--json"])
    let add = try RemindersTarget.Attachments.Add.parse(
      ["--id", "meeting", "--file", file.path, "--dry-run"])
    let remove = try RemindersTarget.Attachments.Remove.parse(
      ["--id", "meeting", "--attachment", "#1", "--dry-run"])
    #expect(read.targetOptions.cliTargetOptions == ["id": "meeting"])
    #expect(add.shared.dryRun && remove.shared.dryRun)

    let command = RemindersCommand(sqliteReader: fixture.reader)
    let source = try command.reminderAttachmentFileURL(
      CLIOptions(targetOptions: add.targetOptions.cliTargetOptions))
    let signature = try command.reminderAttachmentFileSignature(source)
    #expect(signature.sha256 == sha256Hex(pdfBytes))
    #expect(signature.sizeBytes == Int64(pdfBytes.count))

    let legacyRecord = try #require(
      fixture.reader.attachmentRecord(
        uti: "com.adobe.pdf", url: "file:///legacy.pdf", fileName: "meeting.pdf"))
    let selector = try #require(remove.targetOptions.cliTargetOptions["attachment"])
    #expect(try command.reminderAttachment(selector: selector, in: [legacyRecord]) == legacyRecord)
    let json = try #require(
      JSONSerialization.jsonObject(with: JSONEncoder().encode(legacyRecord)) as? [String: String])
    #expect(Set(json.keys) == ["kind", "typeIdentifier", "fileName", "url"])
  }
}

private let firstReminder = UUID(uuidString: "11111111-0000-4000-8000-000000000001")!
private let otherReminder = UUID(uuidString: "11111111-0000-4000-8000-000000000002")!
private let firstAccount = UUID(uuidString: "22222222-0000-4000-8000-000000000001")!
private let otherAccount = UUID(uuidString: "22222222-0000-4000-8000-000000000002")!
private let firstAttachment = UUID(uuidString: "33333333-0000-4000-8000-000000000001")!
private let secondAttachment = UUID(uuidString: "33333333-0000-4000-8000-000000000002")!
private let thirdAttachment = UUID(uuidString: "33333333-0000-4000-8000-000000000003")!
private let fourthAttachment = UUID(uuidString: "33333333-0000-4000-8000-000000000004")!
private let pdfBytes = Data("%PDF-1.7\nattachment fixture\n%%EOF".utf8)
private let secondBytes = Data([0x89, 0x50, 0x4e, 0x47, 0, 42, 255])

private func fixtureHash(_ data: Data) -> String {
  SHA512.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private func expectCLIError(
  _ code: CLIErrorCode, status: String? = nil, _ work: () throws -> Any
) {
  do {
    _ = try work()
    Issue.record("Expected \(code).")
  } catch let error as CLIError {
    #expect(error.code == code)
    if let status { #expect(error.details["status"] == status) }
  } catch {
    Issue.record("Expected CLIError, got \(error).")
  }
}

private final class AttachmentFixture {
  struct Row {
    let id: UUID
    let name: String?
    let bytes: Data?
    let entity: Int
    let uti: String
    let deleted: Bool

    init(
      _ id: UUID, name: String?, bytes: Data?, entity: Int = 3,
      uti: String = "com.adobe.pdf", deleted: Bool = false
    ) {
      self.id = id
      self.name = name
      self.bytes = bytes
      self.entity = entity
      self.uti = uti
      self.deleted = deleted
    }
  }

  private struct Envelope<T: Decodable>: Decodable {
    let ok: Bool
    let data: T
  }

  let home: URL
  let reader: RemindersSQLiteReader

  init(attachments: [Row] = [.init(firstAttachment, name: "meeting.pdf", bytes: pdfBytes)]) throws {
    let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
    home = root.appendingPathComponent(
      "reminders-export-fixture-" + UUID().uuidString, isDirectory: true)
    reader = RemindersSQLiteReader(homeDirectory: home)
    try FileManager.default.createDirectory(
      at: reader.remindersStoresURL, withIntermediateDirectories: true)
    try createStore(
      "Data-first.sqlite", account: firstAccount, reminder: firstReminder,
      id: "meeting", attachments: attachments)
  }

  deinit {
    try? FileManager.default.removeItem(at: home)
  }

  func cacheURL(_ data: Data, ext: String, account: UUID = firstAccount) -> URL {
    reader.remindersStoresURL.deletingLastPathComponent()
      .appendingPathComponent(
        "Files/Account-\(account.uuidString)/Attachments/\(fixtureHash(data)).\(ext)")
  }

  func putCache(_ data: Data, ext: String, account: UUID = firstAccount) throws {
    let url = cacheURL(data, ext: ext, account: account)
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
  }

  func createStore(_ file: String, account: UUID, reminder: UUID, id: String, attachments: [Row])
    throws
  {
    let ckID = account == firstAccount ? "ck-meeting-first" : "ck-meeting-other"
    try sql(
      """
      CREATE TABLE ZREMCDREMINDER (
        Z_PK INTEGER PRIMARY KEY, ZACCOUNT INTEGER, ZIDENTIFIER BLOB,
        ZDACALENDARITEMUNIQUEIDENTIFIER TEXT, ZCKIDENTIFIER TEXT, ZMARKEDFORDELETION INTEGER);
      CREATE TABLE ZREMCDOBJECT (
        Z_PK INTEGER PRIMARY KEY, Z_ENT INTEGER, ZACCOUNT INTEGER, ZIDENTIFIER BLOB,
        ZREMINDER2 INTEGER, ZMARKEDFORDELETION INTEGER, ZFILENAME TEXT, ZUTI TEXT,
        ZFILESIZE INTEGER, ZSHA512SUM TEXT);
      CREATE TABLE Z_PRIMARYKEY (Z_ENT INTEGER PRIMARY KEY, Z_NAME TEXT, Z_SUPER INTEGER);
      INSERT INTO Z_PRIMARYKEY VALUES
        (1,'REMCDAccount',0),(2,'REMCDAttachment',0),(3,'REMCDFileAttachment',2),
        (4,'REMCDImageAttachment',3),(5,'REMCDURLAttachment',2),(6,'REMCDReminder',0);
      INSERT INTO ZREMCDOBJECT (Z_PK,Z_ENT,ZIDENTIFIER,ZMARKEDFORDELETION)
        VALUES (1,1,\(hex(account)),0);
      INSERT INTO ZREMCDREMINDER VALUES (2,1,\(hex(reminder)),'\(id)','\(ckID)',0);
      """, file: file)
    for (index, row) in attachments.enumerated() {
      try sql(
        """
        INSERT INTO ZREMCDOBJECT VALUES (\(10 + index),\(row.entity),1,\(hex(row.id)),2,
          \(row.deleted ? 1 : 0),\(literal(row.name)),'\(row.uti)',
          \(row.bytes.map { String($0.count) } ?? "NULL"),
          \(literal(row.bytes.map(fixtureHash))));
        """, file: file)
      if let bytes = row.bytes {
        // The cache suffix is independent of the display name and UTI.
        try putCache(bytes, ext: "pdf", account: account)
      }
    }
  }

  func sql(_ sql: String, file: String = "Data-first.sqlite") throws {
    let path = reader.remindersStoresURL.appendingPathComponent(file).path
    let result = try CLISubprocess.run(
      .path("/usr/bin/sqlite3"), arguments: [path, sql], timeoutSeconds: 5)
    try #require(result.exitCode == 0, Comment(rawValue: result.stderr))
  }

  func runList(id: String = "meeting") throws -> ReminderAttachmentsListResult {
    try decode(run(["attachments", "list"], id: id))
  }

  func export(
    _ output: URL, id: String = "meeting", selector: String? = nil,
    dryRun: Bool = false, allow: Bool = true
  ) throws -> CLICommandResult {
    var values = ["output": output.path]
    if let selector { values["attachment"] = selector }
    return try run(
      ["attachments", "export"], id: id, options: values,
      all: selector == nil, dryRun: dryRun, allow: allow)
  }

  func run(
    _ positionals: [String], id: String = "meeting", options: [String: String] = [:],
    all: Bool = true, dryRun: Bool = false, allow: Bool = true,
    native: ReminderNativeAttachmentInventory? = nil
  ) throws -> CLICommandResult {
    var values = options
    values["id"] = id
    return try RemindersCommand(sqliteReader: reader).runAttachmentReadCommand(
      CLIOptions(
        json: true, dryRun: dryRun,
        safetyFlags: allow ? ["allow-artifact-action"] : [],
        targetOptions: values, targetFlags: all && positionals.last == "export" ? ["all"] : [],
        positionals: positionals),
      readNative: { _ in native })
  }

  func decode<T: Decodable>(_ result: CLICommandResult) throws -> T {
    let text = try #require(result.stdout)
    let envelope = try JSONDecoder().decode(Envelope<T>.self, from: Data(text.utf8))
    #expect(envelope.ok)
    return envelope.data
  }

  private func literal(_ value: String?) -> String {
    value.map { "'" + $0.replacingOccurrences(of: "'", with: "''") + "'" } ?? "NULL"
  }

  private func hex(_ uuid: UUID) -> String {
    "X'" + uuid.uuidString.replacingOccurrences(of: "-", with: "") + "'"
  }
}
