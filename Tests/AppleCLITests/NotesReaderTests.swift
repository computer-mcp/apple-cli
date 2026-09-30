import Foundation
@testable import NotesCLI
import Testing
import Utility

@Suite(.serialized, .enabled(
  if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_NOTES_INTEGRATION_TESTS"] == "1",
  "Requires explicit opt-in to bounded reads of the host's Notes data."
))
struct NotesReaderTests {
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
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}
