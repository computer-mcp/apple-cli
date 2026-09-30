import Testing
import Utility

@testable import NotesCLI

@Suite
struct NotesExecutionRoutingTests {
  @Test(arguments: [
    [], ["unknown"], ["notes"], ["notes", "unknown"],
    ["notes", "search", "unknown"], ["notes", "import", "unknown"],
    ["notes", "batch", "unknown"], ["doctor", "unknown"],
    ["accounts", "list", "extra"], ["folders", "create", "extra"],
    ["tags", "unknown"], ["smart-folders", "unknown"],
    ["links", "unknown"], ["body", "table", "unknown"],
    ["attachments", "audio", "unknown"], ["state", "unlock", "extra"],
    ["settings", "unknown"],
  ])
  func unrecognizedExecutionPathsReturnNilWithoutBackendAccess(_ path: [String]) throws {
    let command = NotesCommand(implementation: UnreachableNotesBackend())
    let options = CLIOptions(
      json: true, dryRun: true,
      targetOptions: ["passphrase-env": "APPLE_CLI_TEST_UNAVAILABLE_SECRET"],
      positionals: path)
    #expect(try command.run(options: options) == nil)
  }
}

private struct UnexpectedBackendAccess: Error {}

private struct UnreachableNotesBackend: NotesReading, NotesMutating {
  func listAccounts() throws -> [NotesAccountRecord] { throw UnexpectedBackendAccess() }
  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    throw UnexpectedBackendAccess()
  }
  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw UnexpectedBackendAccess()
  }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw UnexpectedBackendAccess()
  }
  func readNote(id: String) throws -> NotesNoteDetail? { throw UnexpectedBackendAccess() }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    throw UnexpectedBackendAccess()
  }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? { throw UnexpectedBackendAccess() }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    throw UnexpectedBackendAccess()
  }
  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    throw UnexpectedBackendAccess()
  }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw UnexpectedBackendAccess()
  }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw UnexpectedBackendAccess()
  }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw UnexpectedBackendAccess()
  }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw UnexpectedBackendAccess()
  }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw UnexpectedBackendAccess()
  }
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    throw UnexpectedBackendAccess()
  }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw UnexpectedBackendAccess()
  }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw UnexpectedBackendAccess()
  }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw UnexpectedBackendAccess()
  }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw UnexpectedBackendAccess()
  }
  func deleteNote(id: String) throws -> Bool { throw UnexpectedBackendAccess() }
  func purgeNote(id: String) throws -> Bool { throw UnexpectedBackendAccess() }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw UnexpectedBackendAccess()
  }
}
