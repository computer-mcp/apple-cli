import Foundation
import NotesCLI
import Testing
import Utility

@Suite
struct NotesFolderDateHeadersCommandTests {
  @Test func dryRunAndExecutionVerifyDateHeaders() throws {
    let implementation = FolderDateHeadersNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "folders", "date-headers", "--folder", "Work", "--enabled", "true",
      "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "notes.folders.date-headers")
    #expect(summary?["folder_id"] as? String == "folder-work")
    #expect(summary?["name"] as? String == "Work")
    #expect(summary?["account"] as? String == "iCloud")
    #expect(summary?["enabled"] as? String == "true")
    #expect(summary?["current_enabled"] as? String == "false")
    #expect(implementation.dateHeaderDrafts.isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "folders", "date-headers", "--folder", "Work", "--enabled", "true",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let folder = executedData?["folder"] as? [String: Any]
    let verification = executedData?["verification"] as? [String: Any]
    let names = checkNames(verification?["checks"] as? [[String: Any]])

    #expect(executedData?["operation"] as? String == "notes.folders.date-headers")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(folder?["id"] as? String == "folder-work")
    #expect(folder?["isShowingDateHeaders"] as? Bool == true)
    #expect(folder?["dateHeadersTypeValue"] as? Int == 2)
    #expect(verification?["verified"] as? Bool == true)
    #expect(names.contains("date_headers_supported"))
    #expect(names.contains("date_headers_enabled"))
    #expect(names.contains("date_headers_type"))
    #expect(implementation.dateHeaderDrafts.map(\.enabled) == [true])
    #expect(implementation.dateHeaderDrafts.map(\.privateValue) == [2])
  }

  @Test func skipsWriteWhenAlreadyApplied() throws {
    let implementation = FolderDateHeadersNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "folders", "date-headers", "--folder", "Work", "--enabled", "false",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let folder = data?["folder"] as? [String: Any]
    let verification = data?["verification"] as? [String: Any]
    let changedCheck = check(verification?["checks"] as? [[String: Any]], named: "changed")

    #expect(data?["operation"] as? String == "notes.folders.date-headers")
    #expect(data?["changed"] as? Bool == false)
    #expect(folder?["isShowingDateHeaders"] as? Bool == false)
    #expect(verification?["verified"] as? Bool == true)
    #expect(changedCheck?["actualBool"] as? Bool == false)
    #expect(implementation.dateHeaderDrafts.isEmpty)
  }

  @Test func rejectsUnsupportedEnabledValue() throws {
    let implementation = FolderDateHeadersNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "folders", "date-headers", "--folder", "Work", "--enabled", "default",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected folder date headers with unsupported enabled value to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(implementation.dateHeaderDrafts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private final class FolderDateHeadersNotesImplementation: NotesReading, NotesMutating, @unchecked Sendable {
  var dateHeaderDrafts: [NotesFolderDateHeadersDraft] = []
  private var folders: [NotesFolderRecord] = [
    NotesFolderRecord(
      id: "folder-work",
      name: "Work",
      accountName: "iCloud",
      parentID: "folder-root",
      parentPresent: true,
      depth: 1,
      folderType: 3,
      visibleNoteCount: 2,
      childFolderCount: 0,
      isDefault: false,
      isTrash: false,
      isSmartFolder: false,
      isSystemFolder: false,
      isRenamable: true,
      isMovable: true,
      isDeletable: true,
      canAddSubfolder: true,
      supportsEditingNotes: true,
      noteSortTypeValue: 0,
      supportsCustomNoteSortType: true,
      customNoteSortOrder: 1,
      customNoteSortDirection: 0,
      customNoteSortIsDefault: true,
      customNoteSortIsAscending: true,
      customNoteSortResolvedOrder: 1,
      customNoteSortDescription: "Default",
      supportsDateHeaders: true,
      isShowingDateHeaders: false,
      dateHeadersTypeValue: 1,
      isSharedViaICloud: true,
      isSharedReadOnly: false,
      isSubfolderOfReadOnlyFolder: false
    )
  ]

  func listAccounts() throws -> [NotesAccountRecord] {
    [NotesAccountRecord(id: "account-icloud", name: "iCloud")]
  }

  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    folders
      .filter { account == nil || $0.accountName.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame }
      .prefix(limit)
      .map { $0 }
  }

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] { [] }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] { [] }
  func readNote(id: String) throws -> NotesNoteDetail? { nil }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] { [] }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    throw unsupported("Folder create")
  }

  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw unsupported("Folder rename")
  }

  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw unsupported("Folder move")
  }

  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw unsupported("Folder delete")
  }

  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw unsupported("Folder sort")
  }

  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    dateHeaderDrafts.append(draft)
    guard let index = folders.firstIndex(where: { $0.id == draft.folderID }) else {
      throw CLIError(code: .notFound, message: "Folder was not found.", details: ["folder": draft.folderID])
    }
    folders[index].isShowingDateHeaders = draft.enabled
    folders[index].dateHeadersTypeValue = draft.privateValue
    return folders[index]
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

  private func unsupported(_ operation: String) -> CLIError {
    CLIError(code: .unsupportedOperation, message: "\(operation) is not supported by this fixture.")
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
