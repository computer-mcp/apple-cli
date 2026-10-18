import Foundation
import Testing
@testable import NotesCLI

@Suite("Notes Smart Folder audit command")
struct NotesSmartFolderAuditCommandTests {
  @Test func auditReturnsCriteriaFamilyAccountingOnly() throws {
    let implementation = SmartFolderAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "smart-folders", "audit", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let warnings = verification?["warnings"] as? [String] ?? []
    let supportedFamilies = summary?["supportedReadFamilies"] as? [String] ?? []
    let gatedFamilies = summary?["gatedMutationFamilies"] as? [String] ?? []
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["returnedSmartFolderCount"] as? Int == 2)
    #expect(summary?["smartFolderCount"] as? Int == 2)
    #expect(summary?["criteriaSummaryCount"] as? Int == 1)
    #expect(summary?["multiConditionCount"] as? Int == 1)
    #expect(summary?["rawValueHashCount"] as? Int == 2)
    #expect(supportedFamilies == ["pinned", "predicate_hash", "tag_selection", "tags"])
    #expect(gatedFamilies.contains("user_editable_criteria_construction"))
    #expect(gatedFamilies.contains("raw_criteria_export_import") == false)
    #expect(gatedFamilies.contains("criteria_summary_unavailable"))
    #expect(records?.count == 2)
    #expect(verification?["operation"] as? String == "notes.smart-folders.audit")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("audit_record_count_matches"))
    #expect(checkNames.contains("raw_value_hashes_accounted"))
    #expect(checkNames.contains("missing_criteria_summaries_accounted"))
    #expect(warnings.contains("criteria_summary_unavailable"))
    #expect(implementation.smartFolderNoteLookups.isEmpty)
    #expect(output.contains("Private body") == false)
    #expect(output.contains("criteriaJSON") == false)
    #expect(output.contains("secret-tag") == false)
    #expect(output.contains("rawFilterValue") == false)
    #expect(output.contains("ICFilter") == false)
  }
}

private enum SmartFolderAuditImplementationError: Error {
  case unsupported
}

private final class SmartFolderAuditImplementation: NotesReading, NotesMutating, NotesSmartFolderReading,
  @unchecked Sendable
{
  var smartFolderNoteLookups: [String] = []

  private let smartFolders: [NotesSmartFolderRecord] = [
    NotesSmartFolderRecord(
      id: "smart-folder-tags",
      name: "Tagged",
      accountName: "iCloud",
      description: "Notes tagged Launch",
      shortDescription: "Launch",
      queryPresent: true,
      queryJSONLength: 42,
      querySHA256: "smart-query-hash",
      criteria: NotesSmartFolderCriteriaSummary(
        queryKind: "mixed_selection",
        canBeEdited: true,
        minimumSupportedVersion: 1,
        entityName: "note",
        predicatePresent: true,
        predicateFormatLength: 19,
        predicateFormatSHA256: "predicate-hash",
        joinOperator: 1,
        includeRecentlyDeleted: false,
        isValid: true,
        filterCount: 2,
        filters: [
          NotesSmartFolderCriteriaFilter(
            kind: "tags",
            isEmpty: false,
            isValid: true,
            rawValuePresent: true,
            rawValueLength: 17,
            rawValueSHA256: "tag-filter-hash",
            count: 1,
            includedCount: 1,
            excludedCount: 0
          ),
          NotesSmartFolderCriteriaFilter(
            kind: "pinned",
            isEmpty: false,
            isValid: true,
            inclusionType: 1,
            rawValuePresent: true,
            rawValueLength: 6,
            rawValueSHA256: "pinned-filter-hash"
          ),
        ],
        tagSelection: NotesSmartFolderTagCriteria(
          selectedTagCount: 1,
          includedTagCount: 1,
          excludedTagCount: 0,
          tagOperator: 1,
          mode: 1,
          allowsRecentlyDeleted: false,
          tagIdentifiersSHA256: "tag-identifiers-hash",
          displayTextsSHA256: "display-texts-hash"
        )
      ),
      visibleNoteCount: 3,
      isEditable: true,
      isDeletable: true
    ),
    NotesSmartFolderRecord(
      id: "smart-folder-local",
      name: "Local Tagged",
      accountName: "Local",
      queryPresent: true,
      queryJSONLength: 19,
      querySHA256: "local-smart-query-hash",
      visibleNoteCount: 1,
      isEditable: false,
      isDeletable: false
    ),
  ]

  func listSmartFolders(account: String?, limit: Int) throws -> [NotesSmartFolderRecord] {
    let filtered = smartFolders.filter { account == nil || $0.accountName == account }
    return Array(filtered.prefix(limit))
  }

  func listSmartFolderNotes(smartFolderID: String, limit: Int) throws -> [NotesNoteSummary] {
    smartFolderNoteLookups.append(smartFolderID)
    return []
  }

  func exportSmartFolderCriteria(smartFolderID: String) throws -> NotesSmartFolderCriteriaExportSource {
    guard let smartFolder = smartFolders.first(where: { $0.id == smartFolderID }) else {
      throw SmartFolderAuditImplementationError.unsupported
    }
    return NotesSmartFolderCriteriaExportSource(
      smartFolder: smartFolder,
      data: Data(#"{"query":"audit"}"#.utf8)
    )
  }

  func listAccounts() throws -> [NotesAccountRecord] { throw SmartFolderAuditImplementationError.unsupported }
  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func readNote(id: String) throws -> NotesNoteDetail? { throw SmartFolderAuditImplementationError.unsupported }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    throw SmartFolderAuditImplementationError.unsupported
  }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw SmartFolderAuditImplementationError.unsupported
  }
  func deleteNote(id: String) throws -> Bool { throw SmartFolderAuditImplementationError.unsupported }
  func purgeNote(id: String) throws -> Bool { throw SmartFolderAuditImplementationError.unsupported }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw SmartFolderAuditImplementationError.unsupported
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
