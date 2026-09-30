@testable import NotesCLI
import Foundation
import Testing
import Utility

@Suite
struct NotesReadParityTests {
  @Test func parityMatchesWhenBoundedMetadataMatches() throws {
    let reader = StaticNotesReader()
    let report = try NotesReadParityChecker(
      implementationReader: reader,
      parityReader: reader,
      sampleLimit: 10
    ).run()

    #expect(report.isMatching)
    #expect(report.mismatchedSections.isEmpty)

    let check = notesReadParityDoctorCheck(report)
    #expect(check.status == .ok)
    #expect(check.details["notes_private_count"] == "1")
    #expect(check.details["notes_mismatched_fields"] == "")
    #expect(check.details.values.contains { $0.contains("Sensitive Plan") } == false)
    #expect(check.details.values.contains { $0.contains("Private body") } == false)
  }

  @Test func parityWarnsWhenBoundedMetadataDiffers() throws {
    let implementationReader = StaticNotesReader(noteTitle: "Sensitive Plan")
    let parityReader = StaticNotesReader(noteTitle: "Different Sensitive Plan")
    let report = try NotesReadParityChecker(
      implementationReader: implementationReader,
      parityReader: parityReader,
      sampleLimit: 10
    ).run()

    #expect(!report.isMatching)
    #expect(report.mismatchedSections == ["notes"])

    let check = notesReadParityDoctorCheck(report)
    #expect(check.status == .warning)
    #expect(check.details["mismatched_sections"] == "notes")
    #expect(check.details["notes_mismatched_fields"] == "title")
    #expect(check.details["notes_matched_id_count"] == "1")
    #expect(check.details["notes_title_matched_id_mismatch_count"] == "1")
    #expect(check.details["notes_title_matched_id_mismatch_samples"] != nil)
    #expect(check.details["notes_title_private_digest"] != nil)
    #expect(check.details["notes_title_reference_digest"] != nil)
    #expect(check.details.values.contains { $0.contains("Sensitive Plan") } == false)
    #expect(check.details.values.contains { $0.contains("Different Sensitive Plan") } == false)
  }

  @Test func parityReportsCoarseDateDeltaBuckets() throws {
    let implementationReader = StaticNotesReader(
      createdAt: Date(timeIntervalSince1970: 28_800),
      updatedAt: Date(timeIntervalSince1970: 28_800)
    )
    let parityReader = StaticNotesReader(
      createdAt: Date(timeIntervalSince1970: 0),
      updatedAt: Date(timeIntervalSince1970: 0)
    )
    let report = try NotesReadParityChecker(
      implementationReader: implementationReader,
      parityReader: parityReader,
      sampleLimit: 10
    ).run()

    let check = notesReadParityDoctorCheck(report)
    #expect(check.status == .warning)
    #expect(check.details["notes_created_matched_id_date_delta_buckets"] == "private_later_exact_8h:1")
    #expect(check.details["notes_updated_matched_id_date_delta_buckets"] == "private_later_exact_8h:1")
  }

  @Test func doctorDoesNotRunParityCheckWithoutOptIn() {
    let parity = notesDoctorChecks().first { $0.name == "notes_read_parity" }

    #expect(parity == nil)
  }

  @Test func parityCheckDocumentsOptInWhenCalledDirectly() {
    let parity = notesReadParityDoctorCheck()

    #expect(parity.status == .notChecked)
    #expect(parity.details["enabled"] == "false")
    #expect(parity.details["body_output"] == "none")
  }

  @Test func parityDefaultSampleLimitIsBounded() {
    #expect(notesReadParitySampleLimit() == 1000)
  }
}

private struct StaticNotesReader: NotesReading {
  var noteTitle = "Sensitive Plan"
  var createdAt: Date?
  var updatedAt: Date?

  func listAccounts() throws -> [NotesAccountRecord] {
    [NotesAccountRecord(id: "private-account-id", name: "Private Account")]
  }

  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    [
      NotesFolderRecord(
        id: "private-folder-id",
        name: "Private Folder",
        accountName: "Private Account"
      )
    ].prefixCount(limit)
  }

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    [
      NotesNoteSummary(
        id: "private-note-id",
        title: noteTitle,
        folderName: "Private Folder",
        accountName: "Private Account",
        createdAt: createdAt,
        updatedAt: updatedAt
      )
    ].prefixCount(limit)
  }

  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try listNotes(folder: folder, limit: limit)
  }

  func readNote(id: String) throws -> NotesNoteDetail? {
    NotesNoteDetail(
      id: id,
      title: noteTitle,
      folderName: "Private Folder",
      accountName: "Private Account",
      body: "Private body"
    )
  }

  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws
    -> [NotesNoteDetail]
  {
    [
      NotesNoteDetail(
        id: "private-note-id",
        title: title,
        folderName: "Private Folder",
        accountName: "Private Account",
        body: "Private body"
      )
    ].prefixCount(limit)
  }
}

private extension Array {
  func prefixCount(_ limit: Int) -> [Element] {
    Array(prefix(Swift.max(0, limit)))
  }
}
