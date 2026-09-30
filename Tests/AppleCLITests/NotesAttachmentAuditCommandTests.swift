import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes attachment audit command")
struct NotesAttachmentAuditCommandTests {
  @Test func listCanViewFolderAttachmentMetadataWithoutBodiesOrBytes() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--folder", "Research", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let notes = data?["notes"] as? [[String: Any]] ?? []
    let firstRecord = notes.first
    let firstNote = firstRecord?["note"] as? [String: Any]
    let firstAttachments = firstRecord?["attachments"] as? [[String: Any]] ?? []
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["folder"] as? String == "Research")
    #expect(data?["scannedNoteCount"] as? Int == 3)
    #expect(data?["notesWithAttachmentsCount"] as? Int == 3)
    #expect(data?["attachmentCount"] as? Int == 7)
    #expect(notes.count == 3)
    #expect(firstNote?["id"] as? String == "note-pdf-scan")
    #expect(firstRecord?["noteIDSHA256"] as? String != nil)
    #expect(firstRecord?["attachmentCount"] as? Int == 2)
    #expect(firstAttachments.first?["id"] as? String == "attachment-pdf")
    #expect(firstAttachments.first?["title"] as? String == "Quarterly Secret.pdf")
    #expect(verification?["operation"] as? String == "notes.attachments.list.collection")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("scanned_note_count_bounded"))
    #expect(checkNames.contains("visible_attachment_records_only"))
    #expect(checkNames.contains("metadata_only_batch_read"))
    #expect(implementation.listedFolders == ["Research"])
    #expect(implementation.attachmentReadIDs == ["note-pdf-scan", "note-media", "note-web"])
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(implementation.exportLookups.isEmpty)
    #expect(output.contains("Private PDF body") == false)
    #expect(output.contains("Private media body") == false)
    #expect(output.contains("Other private body") == false)
    #expect(output.contains("Deleted Private.png") == false)
  }

  @Test func listFiltersCollectionByOfficialAttachmentFamilyCategory() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--folder", "Research", "--family", "photos-videos", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let familyCounts = data?["familyCounts"] as? [[String: Any]] ?? []
    let notes = data?["notes"] as? [[String: Any]] ?? []
    let firstRecord = notes.first
    let firstNote = firstRecord?["note"] as? [String: Any]
    let attachments = firstRecord?["attachments"] as? [[String: Any]] ?? []
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["family"] as? String == "photo-video")
    #expect(data?["scannedNoteCount"] as? Int == 3)
    #expect(data?["notesWithAttachmentsCount"] as? Int == 1)
    #expect(data?["attachmentCount"] as? Int == 2)
    #expect(auditCount(familyCounts, named: "photo_image") == 1)
    #expect(auditCount(familyCounts, named: "video") == 1)
    #expect(firstNote?["id"] as? String == "note-media")
    #expect(attachments.map { $0["id"] as? String } == ["attachment-photo", "attachment-video"])
    #expect(checkNames.contains("family_counts_accounted"))
    #expect(checkNames.contains("family_filter_applied"))
    #expect(implementation.listedFolders == ["Research"])
    #expect(implementation.attachmentReadIDs == ["note-pdf-scan", "note-media", "note-web"])
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(implementation.exportLookups.isEmpty)
    #expect(output.contains("Board Meeting Audio") == false)
    #expect(output.contains("Quarterly Secret.pdf") == false)
    #expect(output.contains("Private PDF body") == false)
  }

  @Test func listFiltersSingleNoteByAttachmentFamily() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--id", "note-media", "--family", "audio", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let attachments = data?["attachments"] as? [[String: Any]] ?? []
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["noteID"] as? String == "note-media")
    #expect(attachments.count == 1)
    #expect(attachments.first?["id"] as? String == "attachment-audio")
    #expect(implementation.listedFolders.isEmpty)
    #expect(implementation.attachmentReadIDs == ["note-media"])
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(implementation.exportLookups.isEmpty)
    #expect(output.contains("Private Photo") == false)
    #expect(output.contains("Private Video") == false)
  }

  @Test func listRejectsUnsupportedAttachmentFamilyBeforeImplementationRead() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--family", "contacts", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected attachments list to reject unsupported family selectors.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("Unsupported attachment family"))
      #expect(error.details["family_sha256"] != nil)
      #expect(implementation.listedFolders.isEmpty)
      #expect(implementation.attachmentReadIDs.isEmpty)
    }
  }

  @Test func listRejectsNoteAndFolderSelectorCombination() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--id", "note-pdf-scan", "--folder", "Research", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected attachments list to reject combined note and folder selectors.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("cannot be combined"))
      #expect(implementation.listedFolders.isEmpty)
      #expect(implementation.attachmentReadIDs.isEmpty)
    }
  }

  @Test func listRejectsNoteAndAccountSelectorCombination() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--id", "note-local", "--account", "Local", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected attachments list to reject combined note and account selectors.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(implementation.accountListQueries.isEmpty)
      #expect(implementation.attachmentReadIDs.isEmpty)
    }
  }

  @Test func listCanLimitCollectionToAccount() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "list", "--account", "Local", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let notes = data?["notes"] as? [[String: Any]] ?? []
    let firstRecord = notes.first
    let firstNote = firstRecord?["note"] as? [String: Any]
    let firstAttachments = firstRecord?["attachments"] as? [[String: Any]] ?? []
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["account"] as? String == "Local")
    #expect(data?["scannedNoteCount"] as? Int == 1)
    #expect(notes.count == 1)
    #expect(firstNote?["id"] as? String == "note-local")
    #expect(firstAttachments.map { $0["id"] as? String } == ["attachment-local"])
    #expect(implementation.accountListQueries == ["Local||50"])
    #expect(implementation.attachmentReadIDs == ["note-local"])
    #expect(output.contains("Local private body") == false)
  }

  @Test func searchFindsAttachmentMetadataWithoutBodiesOrBytes() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "search", "--folder", "Research", "--query", "Quarterly", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let matches = data?["matches"] as? [[String: Any]] ?? []
    let firstMatch = matches.first
    let attachment = firstMatch?["attachment"] as? [String: Any]
    let matchedFields = firstMatch?["matchedFields"] as? [String] ?? []
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["operation"] as? String == "notes.attachments.search")
    #expect(data?["querySHA256"] as? String != nil)
    #expect(data?["queryByteCount"] as? Int == 9)
    #expect(data?["scannedNoteCount"] as? Int == 3)
    #expect(data?["scannedAttachmentCount"] as? Int == 7)
    #expect(data?["matchedAttachmentCount"] as? Int == 1)
    #expect(firstMatch?["family"] as? String == "pdf")
    #expect(attachment?["id"] as? String == "attachment-pdf")
    #expect(matchedFields == ["title", "media_filename"])
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("metadata_field_accounting"))
    #expect(checkNames.contains("metadata_only_batch_read"))
    #expect(implementation.listedFolders == ["Research"])
    #expect(implementation.attachmentReadIDs == ["note-pdf-scan", "note-media", "note-web"])
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(implementation.exportLookups.isEmpty)
    #expect(output.contains("Private PDF body") == false)
    #expect(output.contains("Private media body") == false)
    #expect(output.contains("Other private body") == false)
    #expect(output.contains("Deleted Private.png") == false)
  }

  @Test func searchCanLimitCollectionToAccount() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "search", "--account", "Local", "--query", "Local", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let matches = data?["matches"] as? [[String: Any]] ?? []
    let firstMatch = matches.first
    let attachment = firstMatch?["attachment"] as? [String: Any]
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["account"] as? String == "Local")
    #expect(data?["scannedNoteCount"] as? Int == 1)
    #expect(data?["matchedAttachmentCount"] as? Int == 1)
    #expect(attachment?["id"] as? String == "attachment-local")
    #expect(implementation.accountListQueries == ["Local||50"])
    #expect(implementation.attachmentReadIDs == ["note-local"])
    #expect(output.contains("Local private body") == false)
  }

  @Test func searchFiltersSingleNoteByAttachmentFamily() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "search", "--id", "note-media", "--family", "audio", "--query", "audio", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let matches = data?["matches"] as? [[String: Any]] ?? []
    let firstAttachment = matches.first?["attachment"] as? [String: Any]
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["family"] as? String == "audio-recording")
    #expect(data?["scannedNoteCount"] as? Int == 1)
    #expect(data?["scannedAttachmentCount"] as? Int == 1)
    #expect(data?["matchedAttachmentCount"] as? Int == 1)
    #expect(firstAttachment?["id"] as? String == "attachment-audio")
    #expect(implementation.listedFolders.isEmpty)
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(implementation.attachmentReadIDs == ["note-media"])
    #expect(implementation.exportLookups.isEmpty)
    #expect(output.contains("Private Photo") == false)
    #expect(output.contains("Private Video") == false)
  }

  @Test func searchRejectsShortQueryBeforeImplementationRead() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "search", "--query", "q", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected attachments search to reject short queries.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("at least 2"))
      #expect(implementation.listedFolders.isEmpty)
      #expect(implementation.attachmentReadIDs.isEmpty)
      #expect(implementation.readNoteLookups.isEmpty)
    }
  }

  @Test func searchRejectsNoteAndAccountSelectorCombination() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "search", "--id", "note-local", "--account", "Local", "--query", "Local", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected attachments search to reject combined note and account selectors.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(implementation.accountListQueries.isEmpty)
      #expect(implementation.attachmentReadIDs.isEmpty)
    }
  }

  @Test func auditAccountsForOfficialAttachmentFamiliesWithoutContentOrBytes() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "audit", "--folder", "Research", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let familyCounts = summary?["familyCounts"] as? [[String: Any]] ?? []
    let extensionCounts = summary?["filenameExtensionCounts"] as? [[String: Any]] ?? []
    let supportedFamilies = summary?["supportedReadFamilies"] as? [String] ?? []
    let delegatedFamilies = summary?["delegatedWorkflowFamilies"] as? [String] ?? []
    let gatedFamilies = summary?["gatedMutationFamilies"] as? [String] ?? []
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["returnedNoteCount"] as? Int == 3)
    #expect(records?.count == 3)
    #expect(summary?["noteCount"] as? Int == 3)
    #expect(summary?["notesWithAttachmentsCount"] as? Int == 3)
    #expect(summary?["attachmentCount"] as? Int == 8)
    #expect(summary?["visibleAttachmentCount"] as? Int == 7)
    #expect(summary?["deletedOrTrashAttachmentCount"] as? Int == 1)
    #expect(summary?["inlineAttachmentCount"] as? Int == 2)
    #expect(summary?["mediaBackedAttachmentCount"] as? Int == 5)
    #expect(summary?["knownByteCountAttachmentCount"] as? Int == 5)
    #expect(summary?["pdfOrScanMarkupCandidateCount"] as? Int == 2)
    #expect(auditCount(familyCounts, named: "pdf") == 1)
    #expect(auditCount(familyCounts, named: "scanned_document") == 1)
    #expect(auditCount(familyCounts, named: "photo_image") == 1)
    #expect(auditCount(familyCounts, named: "video") == 1)
    #expect(auditCount(familyCounts, named: "audio_recording") == 1)
    #expect(auditCount(familyCounts, named: "webpage_preview") == 1)
    #expect(auditCount(familyCounts, named: "map_preview") == 1)
    #expect(auditCount(extensionCounts, named: "pdf") == 1)
    #expect(auditCount(extensionCounts, named: "m4a") == 1)
    #expect(supportedFamilies.contains("scan_metadata"))
    #expect(supportedFamilies.contains("audio_recording_metadata"))
    #expect(supportedFamilies.contains("webpage_preview_metadata"))
    #expect(supportedFamilies.contains("map_preview_metadata"))
    #expect(delegatedFamilies.contains("scan_capture"))
    #expect(delegatedFamilies.contains("audio_recording_generation"))
    #expect(delegatedFamilies.contains("audio_recording_edit"))
    #expect(delegatedFamilies.contains("audio_transcription_generation"))
    #expect(gatedFamilies.contains("semantic_markup_element_edit"))
    #expect(gatedFamilies.contains("pdf_content_edit") == false)
    #expect(gatedFamilies.contains("audio_recording_edit") == false)
    #expect(gatedFamilies.contains("audio_transcript_edit") == false)
    #expect(gatedFamilies.contains("scan_capture") == false)
    #expect(gatedFamilies.contains("pdf_scan_crop_filter_rotate_rename") == false)
    #expect(gatedFamilies.contains("webpage_preview_generation_update") == false)
    #expect(verification?["operation"] as? String == "notes.attachments.audit")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("family_counts_accounted"))
    #expect(checkNames.contains("privacy_surface_limited_to_attachment_accounting"))
    #expect(checkNames.contains("scan_capture_delegated"))
    #expect(checkNames.contains("audio_recording_generation_delegated"))
    #expect(checkNames.contains("audio_transcription_generation_delegated"))
    #expect(checkNames.contains("semantic_markup_element_edit_gated"))
    #expect(checkNames.contains("pdf_content_edit_gated") == false)
    #expect(implementation.listedFolders == ["Research"])
    #expect(implementation.attachmentReadIDs == ["note-pdf-scan", "note-media", "note-web"])
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(implementation.exportLookups.isEmpty)
    #expect(output.contains("Private PDF body") == false)
    #expect(output.contains("Research PDF") == false)
    #expect(output.contains("Quarterly Secret.pdf") == false)
    #expect(output.contains("SensitiveMeeting.m4a") == false)
    #expect(output.contains("Confidential Site") == false)
    #expect(output.contains("Private Map") == false)
  }

  @Test func auditCanLimitCollectionToAccount() throws {
    let implementation = AttachmentAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "audit", "--account", "Local", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["account"] as? String == "Local")
    #expect(data?["returnedNoteCount"] as? Int == 1)
    #expect(records?.count == 1)
    #expect(summary?["noteCount"] as? Int == 1)
    #expect(summary?["attachmentCount"] as? Int == 1)
    #expect(implementation.accountListQueries == ["Local||50"])
    #expect(implementation.attachmentReadIDs == ["note-local"])
    #expect(output.contains("Local private body") == false)
    #expect(output.contains("Local Secret") == false)
  }
}

private enum AttachmentAuditImplementationError: Error {
  case unsupported
}

private final class AttachmentAuditImplementation: NotesReading, NotesAccountScopedListing, NotesMutating, NotesAttachmentReading,
  @unchecked Sendable
{
  var listedFolders: [String?] = []
  var accountListQueries: [String] = []
  var readNoteLookups: [String] = []
  var attachmentReadIDs: [String] = []
  var exportLookups: [String] = []

  private let notes: [NotesNoteDetail] = [
    NotesNoteDetail(
      id: "note-pdf-scan",
      title: "Research PDF",
      folderName: "Research",
      accountName: "iCloud",
      body: "Private PDF body"
    ),
    NotesNoteDetail(
      id: "note-media",
      title: "Research Media",
      folderName: "Research",
      accountName: "iCloud",
      body: "Private media body"
    ),
    NotesNoteDetail(
      id: "note-web",
      title: "Research Links",
      folderName: "Research",
      accountName: "iCloud",
      body: "Private webpage body"
    ),
    NotesNoteDetail(
      id: "note-other",
      title: "Other Secret",
      folderName: "Other",
      accountName: "iCloud",
      body: "Other private body"
    ),
    NotesNoteDetail(
      id: "note-local",
      title: "Local Attachment",
      folderName: "Local Research",
      accountName: "Local",
      body: "Local private body"
    ),
  ]

  private let attachments: [String: [NotesAttachmentRecord]] = [
    "note-pdf-scan": [
      NotesAttachmentRecord(
        id: "attachment-pdf",
        title: "Quarterly Secret.pdf",
        typeUTI: "com.adobe.pdf",
        contentIdentifier: "cid-pdf",
        attachmentType: 3,
        fileSizeBytes: 1024,
        mediaFilename: "Quarterly Secret.pdf"
      ),
      NotesAttachmentRecord(
        id: "attachment-scan",
        title: "Scanned Documents",
        typeUTI: "public.jpeg",
        contentIdentifier: "cid-scan",
        attachmentType: 4,
        fileSizeBytes: 2048,
        mediaFilename: "Scan Secret.jpg"
      ),
      NotesAttachmentRecord(
        id: "attachment-deleted",
        title: "Deleted Private.png",
        typeUTI: "public.png",
        contentIdentifier: "cid-deleted",
        attachmentType: 4,
        fileSizeBytes: 512,
        mediaFilename: "Deleted Private.png",
        isDeletedOrInTrash: true
      ),
    ],
    "note-media": [
      NotesAttachmentRecord(
        id: "attachment-photo",
        title: "Private Photo",
        typeUTI: "public.jpeg",
        contentIdentifier: "cid-photo",
        attachmentType: 4,
        fileSizeBytes: 4096,
        mediaFilename: "PrivatePhoto.jpg"
      ),
      NotesAttachmentRecord(
        id: "attachment-video",
        title: "Private Video",
        typeUTI: "public.movie",
        contentIdentifier: "cid-video",
        attachmentType: 5,
        fileSizeBytes: 8192,
        mediaFilename: "SecretMovie.mov"
      ),
      NotesAttachmentRecord(
        id: "attachment-audio",
        title: "Board Meeting Audio",
        typeUTI: "public.mpeg-4-audio",
        contentIdentifier: "cid-audio",
        attachmentType: 6,
        fileSizeBytes: 16384,
        mediaFilename: "SensitiveMeeting.m4a"
      ),
    ],
    "note-web": [
      NotesAttachmentRecord(
        id: "attachment-web",
        title: "Confidential Site",
        typeUTI: "public.url",
        contentIdentifier: "cid-web",
        attachmentType: 7,
        isInline: true
      ),
      NotesAttachmentRecord(
        id: "attachment-map",
        title: "Private Map Location",
        typeUTI: "com.apple.map",
        contentIdentifier: "cid-map",
        attachmentType: 7,
        isInline: true
      ),
    ],
    "note-local": [
      NotesAttachmentRecord(
        id: "attachment-local",
        title: "Local Secret.pdf",
        typeUTI: "com.adobe.pdf",
        contentIdentifier: "cid-local",
        attachmentType: 3,
        fileSizeBytes: 256,
        mediaFilename: "Local Secret.pdf"
      ),
    ],
  ]

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    listedFolders.append(folder)
    return notes
      .filter { folder == nil || $0.folderName.localizedCaseInsensitiveCompare(folder ?? "") == .orderedSame }
      .prefix(limit)
      .map {
        NotesNoteSummary(
          id: $0.id,
          title: $0.title,
          folderName: $0.folderName,
          accountName: $0.accountName
        )
      }
  }

  func listNotes(account: String?, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    accountListQueries.append("\(account ?? "")|\(folder ?? "")|\(limit)")
    return notes
      .filter {
        (account == nil || $0.accountName.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame)
          && (folder == nil || $0.folderName.localizedCaseInsensitiveCompare(folder ?? "") == .orderedSame)
      }
      .prefix(limit)
      .map {
        NotesNoteSummary(
          id: $0.id,
          title: $0.title,
          folderName: $0.folderName,
          accountName: $0.accountName
        )
      }
  }

  func listAttachments(noteID id: String, limit: Int) throws -> [NotesAttachmentRecord] {
    attachmentReadIDs.append(id)
    return Array((attachments[id] ?? []).prefix(limit))
  }

  func exportAttachment(noteID id: String, attachmentID: String) throws -> NotesAttachmentExportSource {
    exportLookups.append("\(id):\(attachmentID)")
    throw AttachmentAuditImplementationError.unsupported
  }

  func exportAttachmentPDF(noteID id: String, attachmentID: String) throws -> NotesAttachmentPDFExportSource {
    exportLookups.append("\(id):\(attachmentID)")
    throw AttachmentAuditImplementationError.unsupported
  }

  func inspectAttachmentMarkup(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentMarkupInspectionSource
  {
    exportLookups.append("\(id):\(attachmentID)")
    throw AttachmentAuditImplementationError.unsupported
  }

  func readAttachmentAudioTranscript(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentAudioTranscriptSource
  {
    exportLookups.append("\(id):\(attachmentID)")
    throw AttachmentAuditImplementationError.unsupported
  }

  func listAccounts() throws -> [NotesAccountRecord] { throw AttachmentAuditImplementationError.unsupported }
  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    throw AttachmentAuditImplementationError.unsupported
  }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw AttachmentAuditImplementationError.unsupported
  }
  func readNote(id: String) throws -> NotesNoteDetail? {
    readNoteLookups.append(id)
    throw AttachmentAuditImplementationError.unsupported
  }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    throw AttachmentAuditImplementationError.unsupported
  }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    throw AttachmentAuditImplementationError.unsupported
  }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw AttachmentAuditImplementationError.unsupported
  }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw AttachmentAuditImplementationError.unsupported
  }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw AttachmentAuditImplementationError.unsupported
  }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw AttachmentAuditImplementationError.unsupported
  }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw AttachmentAuditImplementationError.unsupported
  }
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    throw AttachmentAuditImplementationError.unsupported
  }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw AttachmentAuditImplementationError.unsupported
  }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw AttachmentAuditImplementationError.unsupported
  }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw AttachmentAuditImplementationError.unsupported
  }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    throw AttachmentAuditImplementationError.unsupported
  }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    throw AttachmentAuditImplementationError.unsupported
  }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw AttachmentAuditImplementationError.unsupported
  }
  func deleteNote(id: String) throws -> Bool { throw AttachmentAuditImplementationError.unsupported }
  func purgeNote(id: String) throws -> Bool { throw AttachmentAuditImplementationError.unsupported }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw AttachmentAuditImplementationError.unsupported
  }
}

private func auditCount(_ counts: [[String: Any]], named name: String) -> Int {
  counts.first { $0["name"] as? String == name }?["count"] as? Int ?? 0
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
