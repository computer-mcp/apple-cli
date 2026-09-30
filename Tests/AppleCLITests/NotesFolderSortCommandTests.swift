import Foundation
import NotesCLI
import Testing
import Utility

@Suite
struct NotesFolderSortCommandTests {
  @Test func dryRunAndExecutionVerifySortMetadata() throws {
    let implementation = FolderSortNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "folders", "sort", "--folder", "Work", "--by", "date-edited", "--direction", "newest-first",
      "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "notes.folders.sort")
    #expect(summary?["folder_id"] as? String == "folder-work")
    #expect(summary?["name"] as? String == "Work")
    #expect(summary?["account"] as? String == "iCloud")
    #expect(summary?["by"] as? String == "date-edited")
    #expect(summary?["direction"] as? String == "newest-first")
    #expect(summary?["sort_order"] as? String == "1")
    #expect(summary?["sort_direction"] as? String == "0")
    #expect(summary?["sort_value"] as? String == "10")
    #expect(summary?["current_sort_value"] as? String == "21")
    #expect(summary?["current_sort_order"] as? String == "2")
    #expect(summary?["current_sort_direction"] as? String == "1")
    #expect(implementation.sortedFolderDrafts.isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "folders", "sort", "--folder", "Work", "--by", "date-edited", "--direction", "newest-first",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let folder = executedData?["folder"] as? [String: Any]
    let verification = executedData?["verification"] as? [String: Any]
    let names = checkNames(verification?["checks"] as? [[String: Any]])

    #expect(executedData?["operation"] as? String == "notes.folders.sort")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(folder?["id"] as? String == "folder-work")
    #expect(folder?["noteSortTypeValue"] as? Int == 10)
    #expect(folder?["customNoteSortOrder"] as? Int == 1)
    #expect(folder?["customNoteSortDirection"] as? Int == 0)
    #expect(folder?["customNoteSortIsDefault"] as? Bool == false)
    #expect(folder?["customNoteSortIsAscending"] as? Bool == true)
    #expect(folder?["customNoteSortResolvedOrder"] as? Int == 1)
    #expect(verification?["verified"] as? Bool == true)
    #expect(names.contains("sort_value"))
    #expect(names.contains("sort_order"))
    #expect(names.contains("sort_direction"))
    #expect(names.contains("sort_default"))
    #expect(names.contains("sort_ascending"))
    #expect(implementation.sortedFolderDrafts.map(\.sortValue) == [10])
  }

  @Test func skipsWriteWhenAlreadyApplied() throws {
    let implementation = FolderSortNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "folders", "sort", "--folder", "Work", "--by", "date-created", "--direction", "oldest-first",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let folder = data?["folder"] as? [String: Any]
    let verification = data?["verification"] as? [String: Any]
    let changedCheck = check(verification?["checks"] as? [[String: Any]], named: "changed")

    #expect(data?["operation"] as? String == "notes.folders.sort")
    #expect(data?["changed"] as? Bool == false)
    #expect(folder?["noteSortTypeValue"] as? Int == 21)
    #expect(verification?["verified"] as? Bool == true)
    #expect(changedCheck?["actualBool"] as? Bool == false)
    #expect(implementation.sortedFolderDrafts.isEmpty)
  }

  @Test func rejectsUnsupportedDirection() throws {
    let implementation = FolderSortNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "folders", "sort", "--folder", "Work", "--by", "date-edited", "--direction", "ascending",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected folder sort with unsupported direction to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(implementation.sortedFolderDrafts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private final class FolderSortNotesImplementation: NotesReading, NotesMutating, @unchecked Sendable {
  var sortedFolderDrafts: [NotesFolderSortDraft] = []
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
      noteSortTypeValue: 21,
      supportsCustomNoteSortType: true,
      customNoteSortOrder: 2,
      customNoteSortDirection: 1,
      customNoteSortIsDefault: false,
      customNoteSortIsAscending: false,
      customNoteSortResolvedOrder: 2,
      customNoteSortDescription: "Date Created Oldest First",
      supportsDateHeaders: true,
      isShowingDateHeaders: true,
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

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    []
  }

  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    []
  }

  func readNote(id: String) throws -> NotesNoteDetail? {
    nil
  }

  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    []
  }

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
    sortedFolderDrafts.append(draft)
    guard let index = folders.firstIndex(where: { $0.id == draft.folderID }) else {
      throw CLIError(code: .notFound, message: "Folder was not found.", details: ["folder": draft.folderID])
    }
    folders[index].noteSortTypeValue = draft.sortValue
    folders[index].customNoteSortOrder = draft.sortOrder
    folders[index].customNoteSortDirection = draft.sortDirection
    folders[index].customNoteSortIsDefault = draft.sortIsDefault
    folders[index].customNoteSortIsAscending = draft.sortIsAscending
    folders[index].customNoteSortResolvedOrder = draft.resolvedSortOrder
    folders[index].customNoteSortDescription = sortDescription(draft)
    return folders[index]
  }

  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw unsupported("Folder date headers")
  }

  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    throw unsupported("Create")
  }

  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw unsupported("Update")
  }

  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw unsupported("Move")
  }

  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw unsupported("Copy")
  }

  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    nil
  }

  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    []
  }

  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw unsupported("Restore")
  }

  func deleteNote(id: String) throws -> Bool {
    throw unsupported("Delete")
  }

  func purgeNote(id: String) throws -> Bool {
    throw unsupported("Purge")
  }

  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw unsupported("Pin")
  }

  private func sortDescription(_ draft: NotesFolderSortDraft) -> String {
    switch draft.by {
    case "default":
      return "Default"
    case "date-edited":
      return draft.direction == "oldest-first" ? "Date Edited Oldest First" : "Date Edited Newest First"
    case "date-created":
      return draft.direction == "oldest-first" ? "Date Created Oldest First" : "Date Created Newest First"
    case "title":
      return draft.direction == "descending" ? "Title Descending" : "Title Ascending"
    default:
      return draft.by
    }
  }

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
