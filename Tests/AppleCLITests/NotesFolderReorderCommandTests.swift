import CryptoKit
import Foundation
import NotesCLI
import Testing
import Utility

@Suite
struct NotesFolderReorderCommandTests {
  @Test func dryRunAndExecutionVerifySidebarOrderReadback() throws {
    let implementation = FolderReorderNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let dryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "folders", "reorder", "--folder", "Work", "--after", "Archive",
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let normalized = try #require(dryRunData["normalizedArguments"] as? [String: Any])

    #expect(dryRunData["operation"] as? String == "notes.folders.reorder")
    #expect(normalized["placement"] as? String == "after")
    #expect(normalized["requested_index"] as? String == "1")
    #expect(normalized["current_index"] as? String == "0")
    #expect((normalized["folder_id_sha256"] as? String)?.count == 64)
    #expect((normalized["reference_folder_id_sha256"] as? String)?.count == 64)
    #expect((dryRun.stdout ?? "").contains("Work") == false)
    #expect((dryRun.stdout ?? "").contains("Archive") == false)
    #expect((dryRun.stdout ?? "").contains("iCloud") == false)
    #expect(implementation.reorderDrafts.isEmpty)

    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "folders", "reorder", "--folder", "Work", "--after", "Archive", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let folder = try #require(data["folder"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let names = checkNames(verification["checks"] as? [[String: Any]])

    #expect(data["operation"] as? String == "notes.folders.reorder")
    #expect(data["changed"] as? Bool == true)
    #expect(folder["id"] as? String == "folder-work")
    #expect(folder["siblingOrderIndex"] as? Int == 1)
    #expect(folder["siblingOrderCount"] as? Int == 3)
    #expect((folder["siblingOrderSHA256"] as? String)?.count == 64)
    #expect(verification["verified"] as? Bool == true)
    #expect(names.contains("target_sibling_index"))
    #expect(names.contains("sibling_count_preserved"))
    #expect(names.contains("sibling_order_hash_readback"))
    #expect(implementation.reorderDrafts.map(\.requestedIndex) == [1])
  }

  @Test func skipsWriteWhenOrderAlreadyMatches() throws {
    let implementation = FolderReorderNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "folders", "reorder", "--folder", "Ideas", "--after", "Archive", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let folder = try #require(data["folder"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let changed = check(verification["checks"] as? [[String: Any]], named: "changed")

    #expect(data["changed"] as? Bool == false)
    #expect(folder["siblingOrderIndex"] as? Int == 2)
    #expect(changed?["actualBool"] as? Bool == false)
    #expect(implementation.reorderDrafts.isEmpty)
  }

  @Test func rejectsReferenceOutsideSiblingGroup() throws {
    let implementation = FolderReorderNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    do {
      _ = try command.run(options: try CLIOptionsFixture.parse([
        "folders", "reorder", "--folder", "Work", "--before", "Subproject", "--json",
      ]))
      Issue.record("Expected folder reorder across parents to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(implementation.reorderDrafts.isEmpty)
      #expect(error.details.values.contains("Work") == false)
      #expect(error.details.values.contains("Subproject") == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private final class FolderReorderNotesImplementation: NotesReading, NotesMutating, @unchecked Sendable {
  var reorderDrafts: [NotesFolderReorderDraft] = []
  private var folderOrder = [
    NotesFolderRecord(
      id: "folder-work",
      name: "Work",
      accountName: "iCloud",
      parentID: "folder-root",
      isRootLevel: true,
      parentPresent: true,
      depth: 1,
      isDefault: false,
      isTrash: false,
      isSmartFolder: false,
      isSystemFolder: false,
      isMovable: true,
      supportsEditingNotes: true
    ),
    NotesFolderRecord(
      id: "folder-archive",
      name: "Archive",
      accountName: "iCloud",
      parentID: "folder-root",
      isRootLevel: true,
      parentPresent: true,
      depth: 1,
      isDefault: false,
      isTrash: false,
      isSmartFolder: false,
      isSystemFolder: false,
      isMovable: true,
      supportsEditingNotes: true
    ),
    NotesFolderRecord(
      id: "folder-ideas",
      name: "Ideas",
      accountName: "iCloud",
      parentID: "folder-root",
      isRootLevel: true,
      parentPresent: true,
      depth: 1,
      isDefault: false,
      isTrash: false,
      isSmartFolder: false,
      isSystemFolder: false,
      isMovable: true,
      supportsEditingNotes: true
    ),
    NotesFolderRecord(
      id: "folder-subproject",
      name: "Subproject",
      accountName: "iCloud",
      parentID: "folder-work",
      isRootLevel: false,
      parentPresent: true,
      depth: 2,
      isDefault: false,
      isTrash: false,
      isSmartFolder: false,
      isSystemFolder: false,
      isMovable: true,
      supportsEditingNotes: true
    ),
  ]

  func listAccounts() throws -> [NotesAccountRecord] {
    [NotesAccountRecord(id: "account-icloud", name: "iCloud")]
  }

  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    orderedFolders()
      .filter { account == nil || $0.accountName.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame }
      .prefix(limit)
      .map { $0 }
  }

  func reorderFolder(_ draft: NotesFolderReorderDraft) throws -> NotesFolderRecord {
    reorderDrafts.append(draft)
    guard let current = folderOrder.firstIndex(where: { $0.id == draft.folderID }) else {
      throw CLIError(code: .notFound, message: "Folder was not found.", details: ["folder": draft.folderID])
    }
    let moving = folderOrder.remove(at: current)
    let siblings = orderedFolders()
      .filter { $0.accountName == draft.accountName && $0.parentID == draft.parentID && $0.id != draft.folderID }
    let insertionSiblingID = draft.requestedIndex < siblings.count ? siblings[draft.requestedIndex].id : nil
    if let insertionSiblingID,
      let insertionIndex = folderOrder.firstIndex(where: { $0.id == insertionSiblingID })
    {
      folderOrder.insert(moving, at: insertionIndex)
    } else {
      let lastSiblingIndex = folderOrder.lastIndex {
        $0.accountName == draft.accountName && $0.parentID == draft.parentID
      }
      folderOrder.insert(moving, at: lastSiblingIndex.map { $0 + 1 } ?? folderOrder.count)
    }
    guard let folder = orderedFolders().first(where: { $0.id == draft.folderID }) else {
      throw CLIError(
        code: .notFound,
        message: "Folder reorder readback was not found.",
        details: ["folder": draft.folderID]
      )
    }
    return folder
  }

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] { [] }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] { [] }
  func readNote(id: String) throws -> NotesNoteDetail? { nil }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] { [] }
  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord { throw unsupported("Folder create") }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord { throw unsupported("Folder rename") }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord { throw unsupported("Folder move") }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool { throw unsupported("Folder delete") }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord { throw unsupported("Folder sort") }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw unsupported("Folder date headers")
  }
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail { throw unsupported("Create") }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail { throw unsupported("Update") }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail { throw unsupported("Move") }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail { throw unsupported("Copy") }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? { nil }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] { [] }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail { throw unsupported("Restore") }
  func deleteNote(id: String) throws -> Bool { throw unsupported("Delete") }
  func purgeNote(id: String) throws -> Bool { throw unsupported("Purge") }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail { throw unsupported("Pin") }

  private func orderedFolders() -> [NotesFolderRecord] {
    var records = folderOrder
    let groupKeys = Set(records.map { "\($0.accountName)|\($0.parentID ?? "<root>")|\($0.isRootLevel == true)" })
    for key in groupKeys {
      let indexes = records.indices.filter {
        "\(records[$0].accountName)|\(records[$0].parentID ?? "<root>")|\(records[$0].isRootLevel == true)" == key
      }
      let ids = indexes.map { records[$0].id }
      let orderHash = sha256Hex(ids.joined(separator: "\n"))
      for (offset, index) in indexes.enumerated() {
        records[index].siblingOrderIndex = offset
        records[index].siblingOrderCount = indexes.count
        records[index].siblingOrderSHA256 = orderHash
      }
    }
    return records
  }

  private func unsupported(_ operation: String) -> CLIError {
    CLIError(code: .unsupportedOperation, message: "\(operation) is not supported in this fixture.")
  }
}

private func checkNames(_ checks: [[String: Any]]?) -> Set<String> {
  Set((checks ?? []).compactMap { $0["name"] as? String })
}

private func check(_ checks: [[String: Any]]?, named name: String) -> [String: Any]? {
  (checks ?? []).first { $0["name"] as? String == name }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  let value = try JSONSerialization.jsonObject(with: data)
  guard let object = value as? [String: Any] else {
    throw CLIError(code: .internalError, message: "Expected JSON object.")
  }
  return object
}

private func sha256Hex(_ value: String) -> String {
  SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
}
