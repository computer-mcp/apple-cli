import Foundation
import CoreData
import NotesShared
@testable import NotesCLI
import Testing
import Utility

@Suite(.serialized, .enabled(
  if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_NOTES_INTEGRATION_TESTS"] == "1",
  "Requires explicit opt-in to bounded reads of the host's Notes data."
))
struct NotesReaderTests {
  @Test func realManagedObjectProvidesDateAndPlainTextAccessors() throws {
    let reader = NotesReader()
    let note = try #require(try reader.listNotes(folder: nil, limit: 1).first,
      "Native accessor validation requires a nonempty host Notes sample.")
    let noteContext = try NotesNativeContext.open()
    let context = try #require(noteContext.managedObjectContext)
    let coordinator = try #require(context.persistentStoreCoordinator)
    let uri = try #require(URL(string: note.id))
    let id = try #require(coordinator.managedObjectID(forURIRepresentation: uri))
    try NotesNativeContext.preflightSave(noteContext, operation: "test.native-metadata")
    try context.performAndWait {
      let object = try #require(try context.existingObject(with: id) as? ICNote)
      #expect(object.managedObjectContext === context)
      try NotesNativeContext.noteSave.require(operation: "test.native-metadata", receiver: object)
      try notesRequireDateAccessors(object, operation: "test.native-read")
      _ = try #require(object.creationDate)
      _ = try #require(object.modificationDate)
      try #require(!object.isPasswordProtected,
        "Plain-text validation requires an unprotected Notes sample.")
      try NotesRuntimeMethod(owner: "ICNote", selector: "noteAsPlainTextWithoutTitle", returnType: "@")
        .require(operation: "test.native-read", receiver: object)
      _ = try #require(object.noteAsPlainTextWithoutTitle)
    }
    let detail = try #require(try reader.readNote(id: note.id))
    #expect(detail.id == note.id)
    #expect(detail.createdAt != nil)
    #expect(detail.updatedAt != nil)
    #expect(detail.body != nil)
  }

  @Test func privateFrameworkReaderReadsBoundedMetadata() throws {
    let reader = NotesReader()

    let accounts = try reader.listAccounts()
    let folders = try reader.listFolders(account: nil, limit: 1)
    let notes = try reader.listNotes(folder: nil, limit: 1)

    #expect(folders.count <= 1)
    #expect(notes.count <= 1)
    #expect(accounts.allSatisfy { !$0.id.isEmpty && !$0.name.isEmpty })
    #expect(folders.allSatisfy { !$0.id.isEmpty && !$0.name.isEmpty })
    #expect(notes.allSatisfy { !$0.id.isEmpty && !$0.title.isEmpty })

    if let first = notes.first {
      let detail = try reader.readNote(id: first.id)
      #expect(detail?.id == first.id)
    }
  }

  @Test func privateFrameworkReaderReturnsCompleteParentFirstFolderTree() throws {
    let reader = NotesReader()

    let folders = try reader.listFolders(account: nil, limit: 10_000)
    let indexByID = Dictionary(uniqueKeysWithValues: folders.enumerated().map { ($0.element.id, $0.offset) })
    let childCounts = Dictionary(grouping: folders.compactMap(\.parentID), by: { $0 }).mapValues(\.count)
    let incompleteFolders = folders.filter { folder in
      guard let expected = folder.childFolderCount else {
        return false
      }
      return expected != (childCounts[folder.id] ?? 0)
    }

    for folder in folders {
      if let parentID = folder.parentID,
        let parentIndex = indexByID[parentID],
        let childIndex = indexByID[folder.id]
      {
        #expect(parentIndex < childIndex)
      }
    }
    #expect(incompleteFolders.isEmpty)
  }

  @Test func privateFrameworkReaderKeepsFolderAccountScopeAndLimit() throws {
    let reader = NotesReader()

    let accounts = try reader.listAccounts()
    guard let account = accounts.first else {
      return
    }
    let scopedFolders = try reader.listFolders(account: account.name, limit: 10_000)
    let limitedFolders = try reader.listFolders(account: account.name, limit: 1)

    #expect(scopedFolders.allSatisfy { $0.accountName == account.name })
    #expect(limitedFolders.count <= 1)
  }

  @Test func defaultNotesCommandUsesPrivateReaderForReads() throws {
    let command = NotesCommand()
    let options = try CLIOptionsFixture.parse(["notes", "list", "--limit", "1", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let notes = data?["notes"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect((notes?.count ?? 0) <= 1)
    #expect(notes?.first?["body"] == nil)
  }

  @Test func privateFrameworkInlineSelectionReadbackBindsARealParagraphSnapshot() throws {
    let reader = NotesReader()
    let note = try #require(try reader.listNotes(folder: nil, limit: 1).first,
      "Inline selection validation requires a nonempty host Notes sample.")
    let structure = try reader.readBodyStructure(noteID: note.id)
    #expect(!structure.isPasswordProtected)
    let anchor = try #require(structure.paragraphAnchors?.first { $0.style == "title" && $0.isHeader })
    let text = note.title
    try #require(!text.isEmpty)
    let selection = try reader.readInlineSelection(noteID: note.id,
      paragraphIDSHA256: anchor.idSHA256, ordinal: nil, text: text, occurrence: 1)
    let bodyLength = try #require(structure.richTextLength)
    let paragraphRange = try #require(notesInlineRange(location: anchor.utf16Location,
      length: anchor.utf16Length, bodyLength: bodyLength))
    let selectedRange = NSRange(location: selection.utf16Location, length: selection.utf16Length)
    #expect(selection.paragraphIDSHA256 == anchor.idSHA256)
    #expect(selection.richTextSHA256 == structure.richTextSHA256)
    #expect(selection.textByteCount == text.utf8.count)
    #expect(selection.textSHA256 == sha256Hex(text))
    #expect(selection.utf16Length == (text as NSString).length)
    #expect(NSIntersectionRange(paragraphRange, selectedRange) == selectedRange)
    #expect(selection.occurrence == 1)
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}
