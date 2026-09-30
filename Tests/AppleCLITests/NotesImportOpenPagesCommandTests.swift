import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes import audit and open Pages commands")
struct NotesImportOpenPagesCommandTests {
  @Test func importAuditAccountsForOfficialImportFamiliesWithoutImporting() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-import-audit-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    try "Private text body".write(
      to: root.appendingPathComponent("Plan.txt"), atomically: true, encoding: .utf8)
    try "{\\rtf1\\ansi Private rich body}".write(
      to: root.appendingPathComponent("Rich.rtf"), atomically: true, encoding: .utf8)
    try "<html><body>Private web body</body></html>".write(
      to: root.appendingPathComponent("Web.html"), atomically: true, encoding: .utf8)
    try """
      <en-export>
        <note>
          <title>Private ENEX</title>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note>Private ENEX body</en-note>]]></content>
          <tag>project</tag>
        </note>
      </en-export>
      """.write(
      to: root.appendingPathComponent("Evernote.enex"), atomically: true, encoding: .utf8)
    try "unsupported".write(
      to: root.appendingPathComponent("Data.csv"), atomically: true, encoding: .utf8)

    let nested = root.appendingPathComponent("Nested", isDirectory: true)
    try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: false)
    try "# Private markdown body".write(
      to: nested.appendingPathComponent("Nested.md"), atomically: true, encoding: .utf8)

    let rtfd = root.appendingPathComponent("Package.rtfd", isDirectory: true)
    try FileManager.default.createDirectory(at: rtfd, withIntermediateDirectories: false)
    try "{\\rtf1\\ansi Package body}".write(
      to: rtfd.appendingPathComponent("TXT.rtf"), atomically: true, encoding: .utf8)

    let markdownPackage = root.appendingPathComponent("RoundTrip.mdpkg", isDirectory: true)
    try FileManager.default.createDirectory(at: markdownPackage, withIntermediateDirectories: false)
    try "# Package body".write(
      to: markdownPackage.appendingPathComponent("Package.md"), atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "audit", "--file", root.path, "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let supportedFamilies = summary?["supportedImportFamilies"] as? [String] ?? []
    let gatedFamilies = summary?["gatedImportFamilies"] as? [String] ?? []

    #expect(object["ok"] as? Bool == true)
    #expect(data?["returnedRecordCount"] as? Int == records?.count)
    #expect(summary?["sourceKind"] as? String == "directory")
    #expect(summary?["supportedTextCount"] as? Int == 1)
    #expect(summary?["supportedMarkdownCount"] as? Int == 1)
    #expect(summary?["supportedMarkdownPackageCount"] as? Int == 1)
    #expect(summary?["supportedRichFormatCount"] as? Int == 3)
    #expect(summary?["gatedRichFormatCount"] as? Int == 0)
    #expect(summary?["supportedENEXCount"] as? Int == 1)
    #expect(summary?["gatedENEXCount"] as? Int == 0)
    #expect(summary?["unsupportedCount"] as? Int == 1)
    #expect(summary?["folderImportRequested"] as? Bool == true)
    #expect(summary?["preserveFolderStructureStatus"] as? String == "supported")
    #expect(summary?["enexTagImportStatus"] as? String == "supported")
    #expect(supportedFamilies.contains("txt"))
    #expect(supportedFamilies.contains("markdown_semantic"))
    #expect(supportedFamilies.contains("markdown_package_resources"))
    #expect(supportedFamilies.contains("markdown_relative_resources"))
    #expect(supportedFamilies.contains("rtf"))
    #expect(supportedFamilies.contains("rtfd"))
    #expect(supportedFamilies.contains("html"))
    #expect(supportedFamilies.contains("enex_attachment_resources"))
    #expect(supportedFamilies.contains("enex_normalized_tags"))
    #expect(supportedFamilies.contains("enex_inline_resource_placement"))
    #expect(supportedFamilies.contains("enex_resource_free"))
    #expect(supportedFamilies.contains("folder_preserve_structure"))
    #expect(gatedFamilies.contains("rtf") == false)
    #expect(gatedFamilies.contains("rtfd") == false)
    #expect(gatedFamilies.contains("html") == false)
    #expect(gatedFamilies.contains("enex") == false)
    #expect(gatedFamilies.contains("enex_inline_resource_placement") == false)
    #expect(gatedFamilies.contains { $0.contains("markdown") } == false)
    #expect(gatedFamilies.contains("folder_preserve_structure") == false)
    #expect(gatedFamilies.isEmpty)
    #expect(verification?["operation"] as? String == "notes.import.audit")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("official_import_formats_accounted"))
    #expect(checkNames.contains("privacy_surface_limited_to_hashes"))
    #expect(implementation.createdDrafts.isEmpty)
    #expect(output.contains(root.path) == false)
    #expect(output.contains("Plan.txt") == false)
    #expect(output.contains("Nested.md") == false)
    #expect(output.contains("Private text body") == false)
    #expect(output.contains("Private rich body") == false)
    #expect(output.contains("Private ENEX") == false)
    #expect(output.contains("Private ENEX body") == false)
  }

  @Test func exportAuditAccountsForExportPrintAndPagesWithoutArtifactWrites() throws {
    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "export", "audit", "--id", "note-2", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]] ?? []
    let families = Set(records.compactMap { $0["formatFamily"] as? String })
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(object["ok"] as? Bool == true)
    #expect(data?["operation"] as? String == "notes.export.audit")
    #expect(data?["changed"] as? Bool == false)
    #expect((data?["noteIDSHA256"] as? String)?.count == 64)
    #expect((data?["titleSHA256"] as? String)?.count == 64)
    #expect(data?["returnedRecordCount"] as? Int == records.count)
    #expect(summary?["selectedNoteStatus"] as? String == "eligible")
    #expect(summary?["supportedRecordCount"] as? Int == 8)
    #expect(summary?["delegatedRecordCount"] as? Int == 2)
    #expect(summary?["gatedRecordCount"] as? Int == 1)
    #expect(summary?["rejectedRecordCount"] as? Int == 1)
    #expect(summary?["artifactActionRequired"] as? Bool == true)
    #expect(summary?["externalDispatchRequired"] as? Bool == true)
    let rejectedFamilies = summary?["rejectedExportFamilies"] as? [String] ?? []
    #expect(families.contains("pdf"))
    #expect(families.contains("markdown"))
    #expect(families.contains("markdown_package"))
    #expect(families.contains("html"))
    #expect(families.contains("html_package"))
    #expect(families.contains("rtf"))
    #expect(families.contains("rtfd"))
    #expect(families.contains("print_dispatch"))
    #expect(families.contains("pages_handoff"))
    #expect(families.contains("locked_note_export"))
    #expect(families.contains("package_resource_preservation"))
    #expect(families.contains("unbounded_conversion_fidelity"))
    #expect(rejectedFamilies == ["unbounded_conversion_fidelity"])
    #expect(verification?["operation"] as? String == "notes.export.audit")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("official_export_print_pages_accounted"))
    #expect(checkNames.contains("private_export_formats_accounted"))
    #expect(checkNames.contains("delegated_dispatch_accounted"))
    #expect(checkNames.contains("residual_export_families_accounted"))
    #expect(checkNames.contains("privacy_surface_limited_to_hashes"))
    #expect(output.contains("Launch Plan") == false)
    #expect(output.contains("Private note body") == false)
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("Work") == false)
  }

  @Test func exportAuditSupportsAuthenticatedLockedContentForSelectedLockedNoteOnly() throws {
    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "export", "audit", "--id", "note-locked", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]] ?? []
    let lockedExport = records.first { $0["formatFamily"] as? String == "locked_note_export" }
    let acceptedRecords = records.filter {
      ($0["artifactKind"] as? String) == "file"
        || ($0["artifactKind"] as? String) == "package"
        || ($0["artifactKind"] as? String) == "external_dispatch"
    }.filter {
      $0["formatFamily"] as? String != "locked_note_export"
    }
    let verification = data?["verification"] as? [String: Any]

    #expect(object["ok"] as? Bool == true)
    #expect(summary?["selectedNoteStatus"] as? String == "gated_locked_password_protected")
    #expect(summary?["supportedRecordCount"] as? Int == 1)
    #expect(summary?["delegatedRecordCount"] as? Int == 0)
    #expect(summary?["gatedRecordCount"] as? Int == 10)
    #expect(summary?["rejectedRecordCount"] as? Int == 1)
    #expect(lockedExport?["exportStatus"] as? String == "supported")
    #expect(lockedExport?["artifactKind"] as? String == "file")
    #expect(lockedExport?["requiresArtifactAction"] as? Bool == true)
    #expect(lockedExport?["noteStateGate"] == nil)
    #expect(acceptedRecords.allSatisfy { $0["exportStatus"] as? String == "gated_note_state" })
    #expect(acceptedRecords.allSatisfy { $0["noteStateGate"] as? String == "gated_locked_password_protected" })
    #expect(verification?["verified"] as? Bool == true)
    #expect(output.contains("Locked Private Plan") == false)
    #expect(output.contains("Locked private body") == false)
  }

  @Test func exportAuditSupportsSessionUnlockedExportsLockedContentAndDispatch() throws {
    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "export", "audit", "--id", "note-unlocked-protected", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]] ?? []
    let lockedExport = try #require(records.first { $0["formatFamily"] as? String == "locked_note_export" })
    let ordinaryArtifactRecords = records.filter {
      ($0["artifactKind"] as? String) == "file"
        || ($0["artifactKind"] as? String) == "package"
    }.filter { $0["formatFamily"] as? String != "locked_note_export" }
    let externalDispatchRecords = records.filter {
      ($0["artifactKind"] as? String) == "external_dispatch"
    }
    let verification = data?["verification"] as? [String: Any]

    #expect(object["ok"] as? Bool == true)
    #expect(summary?["selectedNoteStatus"] as? String == "eligible_session_unlocked_password_protected")
    #expect(summary?["supportedRecordCount"] as? Int == 9)
    #expect(summary?["delegatedRecordCount"] as? Int == 2)
    #expect(summary?["gatedRecordCount"] as? Int == 0)
    #expect(summary?["rejectedRecordCount"] as? Int == 1)
    #expect(summary?["artifactActionRequired"] as? Bool == true)
    #expect(summary?["externalDispatchRequired"] as? Bool == true)
    #expect(lockedExport["exportStatus"] as? String == "supported")
    #expect(lockedExport["artifactKind"] as? String == "file")
    #expect(lockedExport["requiresArtifactAction"] as? Bool == true)
    #expect(lockedExport["noteStateGate"] as? String == nil)
    #expect(ordinaryArtifactRecords.allSatisfy {
      $0["exportStatus"] as? String == "supported"
        && $0["noteStateGate"] as? String == nil
    })
    #expect(externalDispatchRecords.allSatisfy {
      $0["exportStatus"] as? String == "delegated"
        && $0["noteStateGate"] as? String == nil
    })
    #expect(verification?["verified"] as? Bool == true)
    #expect(output.contains("Unlocked Private Plan") == false)
    #expect(output.contains("Unlocked protected body") == false)
  }

  @Test func folderImportPreservesSupportedDirectoryTreeWithVerifier() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-folder-import-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    try "Private folder text body".write(
      to: root.appendingPathComponent("Plan.txt"), atomically: true, encoding: .utf8)
    let team = root.appendingPathComponent("Team", isDirectory: true)
    try FileManager.default.createDirectory(at: team, withIntermediateDirectories: false)
    try "<html><body>Private folder html body</body></html>".write(
      to: team.appendingPathComponent("Brief.html"), atomically: true, encoding: .utf8)
    try """
      <en-export>
        <note>
          <title>Private Folder ENEX</title>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note>Private folder ENEX body</en-note>]]></content>
          <tag>project</tag>
        </note>
      </en-export>
      """.write(to: team.appendingPathComponent("Evernote.enex"), atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)

    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "folder", "--folder", "Work", "--file", root.path,
      "--name", "Imported Tree", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let normalized = dryRunData?["normalizedArguments"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]
    let requirementNotes = requirements?["notes"] as? [String] ?? []

    #expect(dryRunData?["operation"] as? String == "notes.import.folder")
    #expect(normalized?["created_folder_count"] as? String == "2")
    #expect(normalized?["source_directory_count"] as? String == "1")
    #expect(normalized?["import_file_count"] as? String == "3")
    #expect(normalized?["imported_note_count"] as? String == "3")
    #expect(normalized?["text_count"] as? String == "1")
    #expect(normalized?["rich_format_count"] as? String == "1")
    #expect(normalized?["enex_count"] as? String == "1")
    #expect((normalized?["source_path_sha256"] as? String)?.count == 64)
    #expect(requirements?["allowFlags"] as? [String] == ["--allow-destructive-selection"])
    #expect(requirementNotes.contains { $0.contains("directory structure") })
    #expect(implementation.createdFolderDrafts.isEmpty)
    #expect(implementation.createdDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains(root.path) == false)
    #expect((dryRun.stdout ?? "").contains("Plan.txt") == false)
    #expect((dryRun.stdout ?? "").contains("Brief.html") == false)
    #expect((dryRun.stdout ?? "").contains("Private folder text body") == false)

    do {
      _ = try command.run(options: CLIOptionsFixture.parse([
        "notes", "import", "folder", "--folder", "Work", "--file", root.path,
        "--name", "Imported Tree", "--json",
      ]))
      Issue.record("Expected folder import without --allow-destructive-selection to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-destructive-selection")
      #expect(implementation.createdFolderDrafts.isEmpty)
      #expect(implementation.createdDrafts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "folder", "--folder", "Work", "--file", root.path,
      "--name", "Imported Tree", "--allow-destructive-selection", "--json",
    ])))
    let output = executed.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let folders = data?["folders"] as? [[String: Any]] ?? []
    let files = data?["files"] as? [[String: Any]] ?? []
    let familyCounts = data?["formatFamilyCounts"] as? [String: Any] ?? [:]
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(data?["operation"] as? String == "notes.import.folder")
    #expect(data?["changed"] as? Bool == true)
    #expect(data?["createdFolderCount"] as? Int == 2)
    #expect(data?["sourceDirectoryCount"] as? Int == 1)
    #expect(data?["importedFileCount"] as? Int == 3)
    #expect(data?["importedNoteCount"] as? Int == 3)
    #expect(folders.count == 2)
    #expect(files.count == 3)
    #expect(familyCounts["txt"] as? Int == 1)
    #expect(familyCounts["html"] as? Int == 1)
    #expect(familyCounts["enex"] as? Int == 1)
    #expect(verification?["operation"] as? String == "notes.import.folder")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("created_folder_count"))
    #expect(checkNames.contains("imported_file_count"))
    #expect(checkNames.contains("privacy_surface_limited_to_hashes"))
    #expect(implementation.createdFolderDrafts.map(\.name) == ["Imported Tree", "Team"])
    #expect(implementation.createdDrafts.map(\.folderName).contains("Imported Tree"))
    #expect(implementation.richImportDrafts.map(\.draft.folderName).contains("Team"))
    #expect(implementation.enexImportDrafts.map(\.folderName).contains("Team"))
    #expect(output.contains(root.path) == false)
    #expect(output.contains("Plan.txt") == false)
    #expect(output.contains("Brief.html") == false)
    #expect(output.contains("Evernote.enex") == false)
    #expect(output.contains("Private folder text body") == false)
    #expect(output.contains("Private folder html body") == false)
    #expect(output.contains("Private folder ENEX body") == false)
  }

  @Test func folderImportRejectsUnsupportedFilesBeforeMutation() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-folder-import-reject-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }
    try "private,csv".write(
      to: root.appendingPathComponent("PrivateData.csv"), atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    do {
      _ = try command.run(options: CLIOptionsFixture.parse([
        "notes", "import", "folder", "--folder", "Work", "--file", root.path,
        "--dry-run", "--json",
      ]))
      Issue.record("Expected unsupported folder import file to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(error.details["source_path_sha256"]?.count == 64)
      #expect(error.details["relative_path_sha256"]?.count == 64)
      #expect(error.details.values.contains { $0.contains(root.path) } == false)
      #expect(error.details.values.contains { $0.contains("PrivateData.csv") } == false)
      #expect(implementation.createdFolderDrafts.isEmpty)
      #expect(implementation.createdDrafts.isEmpty)
      #expect(implementation.richImportDrafts.isEmpty)
      #expect(implementation.enexImportDrafts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func enexImportSupportsResourceFreeNotesAndTagsWithVerifier() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-enex-import-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    let enex = root.appendingPathComponent("PrivateEvernote.enex")
    try """
      <en-export>
        <note>
          <title>Private First ENEX</title>
          <created>20240102T030405Z</created>
          <updated>20240103T040506Z</updated>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note><div>Private first ENEX body</div></en-note>]]></content>
          <tag>project</tag>
          <tag>review</tag>
        </note>
        <note>
          <title>Private Second ENEX</title>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note>Private second ENEX body</en-note>]]></content>
          <tag>project</tag>
        </note>
      </en-export>
      """.write(to: enex, atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)

    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let normalized = dryRunData?["normalizedArguments"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]
    let requirementNotes = requirements?["notes"] as? [String] ?? []

    #expect(dryRunData?["operation"] as? String == "notes.import.enex")
    #expect(normalized?["note_count"] as? String == "2")
    #expect(normalized?["tag_count"] as? String == "3")
    #expect(normalized?["unique_tag_count"] as? String == "2")
    #expect(normalized?["normalized_tag_count"] as? String == "0")
    #expect(normalized?["resource_count"] as? String == "0")
    #expect(normalized?["unsupported_tag_count"] as? String == "0")
    #expect((normalized?["source_path_sha256"] as? String)?.count == 64)
    #expect((normalized?["source_name_sha256"] as? String)?.count == 64)
    #expect(requirementNotes.contains { $0.contains("imports notes") })
    #expect(implementation.enexImportDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains(enex.path) == false)
    #expect((dryRun.stdout ?? "").contains(enex.lastPathComponent) == false)
    #expect((dryRun.stdout ?? "").contains("Private first ENEX body") == false)

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path, "--json",
    ])))
    let output = executed.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let importedNotes = data?["importedNotes"] as? [[String: Any]] ?? []
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(data?["operation"] as? String == "notes.import.enex")
    #expect(data?["changed"] as? Bool == true)
    #expect(data?["importedNoteCount"] as? Int == 2)
    #expect(data?["tagCount"] as? Int == 3)
    #expect(data?["uniqueTagCount"] as? Int == 2)
    #expect(data?["normalizedTagCount"] as? Int == 0)
    #expect(data?["resourceCount"] as? Int == 0)
    #expect(data?["resourceByteCount"] as? Int == 0)
    #expect(importedNotes.count == 2)
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("resource_payloads_supported"))
    #expect(checkNames.contains("tag_shape_supported"))
    #expect(checkNames.contains("tag_normalization_accounting"))
    #expect(checkNames.contains("note_1_tag_membership_readback"))
    #expect(checkNames.contains("note_1_created_date_preserved"))
    #expect(checkNames.contains("note_1_updated_date_preserved"))
    #expect(checkNames.contains("imported_note_count"))
    #expect(implementation.enexImportDrafts.count == 1)
    #expect(implementation.enexImportDrafts.first?.source.notes.count == 2)
    #expect(output.contains(enex.path) == false)
    #expect(output.contains(enex.lastPathComponent) == false)
    #expect(output.contains("Private first ENEX body") == false)
    #expect(output.contains("Private second ENEX body") == false)
  }

  @Test func enexImportNormalizesWhitespaceTagsWithVerifier() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-enex-normalized-tags-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    let enex = root.appendingPathComponent("PrivateWhitespaceTags.enex")
    try """
      <en-export>
        <note>
          <title>Private Whitespace Tags ENEX</title>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note><div>Private whitespace tag body</div></en-note>]]></content>
          <tag>Project Plan</tag>
          <tag>#Project\tPlan</tag>
        </note>
      </en-export>
      """.write(to: enex, atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)

    let audit = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "audit", "--file", enex.path, "--json",
    ])))
    let auditObject = try jsonObject(audit.stdout ?? "")
    let auditData = auditObject["data"] as? [String: Any]
    let auditSummary = auditData?["summary"] as? [String: Any]
    let auditRecords = auditData?["records"] as? [[String: Any]] ?? []
    let auditRecord = try #require(auditRecords.first)

    #expect(auditSummary?["supportedENEXCount"] as? Int == 1)
    #expect(auditSummary?["gatedENEXCount"] as? Int == 0)
    #expect(auditSummary?["enexTagImportStatus"] as? String == "supported_normalized")
    #expect(auditRecord["importStatus"] as? String == "supported_enex_normalized_tags")
    #expect((audit.stdout ?? "").contains("Project Plan") == false)

    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let normalized = dryRunData?["normalizedArguments"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]
    let requirementNotes = requirements?["notes"] as? [String] ?? []

    #expect(normalized?["tag_count"] as? String == "2")
    #expect(normalized?["unique_tag_count"] as? String == "1")
    #expect(normalized?["normalized_tag_count"] as? String == "2")
    #expect(normalized?["unsupported_tag_count"] as? String == "0")
    #expect(requirementNotes.contains { $0.contains("normalizes whitespace-bearing ENEX tags") })
    #expect(implementation.enexImportDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains("Project Plan") == false)
    #expect((dryRun.stdout ?? "").contains("#Project") == false)

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path, "--json",
    ])))
    let output = executed.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let tagCheck = try #require(checks.first { $0["name"] as? String == "tag_normalization_accounting" })

    #expect(data?["tagCount"] as? Int == 2)
    #expect(data?["uniqueTagCount"] as? Int == 1)
    #expect(data?["normalizedTagCount"] as? Int == 2)
    #expect(verification?["verified"] as? Bool == true)
    #expect(tagCheck["expectedLength"] as? Int == 2)
    #expect(tagCheck["actualLength"] as? Int == 2)
    #expect(implementation.enexImportDrafts.count == 1)
    #expect(implementation.enexImportDrafts.first?.source.normalizedTagCount == 2)
    #expect(output.contains("Project Plan") == false)
    #expect(output.contains("#Project") == false)
    #expect(output.contains("Private whitespace tag body") == false)
  }

  @Test func enexImportPreservesResourceAttachmentsWithVerifier() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-enex-resource-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    let enex = root.appendingPathComponent("PrivateResource.enex")
    let resourceData = Data("secret".utf8)
    try """
      <en-export>
        <note>
          <title>Private Resource ENEX</title>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note><div>Private resource body</div><en-media type="image/png" hash="5ebe2294ecd0e0f08eab7690d2a6ee69"/></en-note>]]></content>
          <resource>
            <mime>image/png</mime>
            <data encoding="base64">c2VjcmV0</data>
            <resource-attributes><file-name>PrivateImage.png</file-name></resource-attributes>
          </resource>
        </note>
      </en-export>
      """.write(to: enex, atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let normalized = dryRunData?["normalizedArguments"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]
    let requirementNotes = requirements?["notes"] as? [String] ?? []

    #expect(normalized?["resource_count"] as? String == "1")
    #expect(normalized?["resource_byte_count"] as? String == "\(resourceData.count)")
    #expect(normalized?["inline_resource_reference_count"] as? String == "1")
    #expect(normalized?["matched_inline_resource_reference_count"] as? String == "1")
    #expect(normalized?["unmatched_inline_resource_reference_count"] as? String == "0")
    #expect(requirementNotes.contains { $0.contains("attachment export hashes") })
    #expect(requirementNotes.contains { $0.contains("inline media references") })
    #expect(implementation.enexImportDrafts.isEmpty)

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path, "--json",
    ])))
    let output = executed.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let importedNotes = data?["importedNotes"] as? [[String: Any]] ?? []
    let firstImported = try #require(importedNotes.first)
    let attachments = firstImported["attachments"] as? [[String: Any]] ?? []
    let firstAttachment = try #require(attachments.first)
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(data?["resourceCount"] as? Int == 1)
    #expect(data?["resourceByteCount"] as? Int == resourceData.count)
    #expect(data?["inlineResourceReferenceCount"] as? Int == 1)
    #expect(data?["matchedInlineResourceReferenceCount"] as? Int == 1)
    #expect(data?["placedInlineResourceReferenceCount"] as? Int == 1)
    #expect(firstImported["resourceCount"] as? Int == 1)
    #expect(firstImported["resourceByteCount"] as? Int == resourceData.count)
    #expect(firstImported["inlineResourceReferenceCount"] as? Int == 1)
    #expect(firstImported["matchedInlineResourceReferenceCount"] as? Int == 1)
    #expect(firstImported["placedInlineResourceReferenceCount"] as? Int == 1)
    #expect(firstAttachment["filename"] as? String == "PrivateImage.png")
    #expect(firstAttachment["mimeType"] as? String == "image/png")
    #expect(firstAttachment["byteCount"] as? Int == resourceData.count)
    #expect(firstAttachment["sha256"] as? String == sha256Hex(resourceData))
    #expect(firstAttachment["inlineReferenceCount"] as? Int == 1)
    #expect(firstAttachment["inlinePlacementCount"] as? Int == 1)
    #expect(checkNames.contains("resource_payloads_supported"))
    #expect(checkNames.contains("inline_resource_references_matched"))
    #expect(checkNames.contains("note_1_resource_1_attachment_readback"))
    #expect(checkNames.contains("note_1_resource_1_sha256"))
    #expect(checkNames.contains("note_1_resource_1_inline_placement_count"))
    #expect(checkNames.contains("note_1_resource_1_inline_attachment_readback"))
    #expect(checkNames.contains("note_1_resource_count_readback"))
    #expect(checkNames.contains("note_1_inline_resource_reference_count"))
    #expect(checkNames.contains("note_1_inline_resource_placement_count"))
    #expect(implementation.enexImportDrafts.count == 1)
    #expect(implementation.enexImportDrafts.first?.source.notes.first?.resources.first?.data == resourceData)
    #expect(implementation.enexImportDrafts.first?.source.notes.first?.inlineResourceReferences.first?.matchedResourceOrdinal == 1)
    #expect(output.contains(enex.path) == false)
    #expect(output.contains(enex.lastPathComponent) == false)
    #expect(output.contains("Private resource body") == false)
    #expect(output.contains("secret") == false)
  }

  @Test func enexImportRejectsUnmatchedInlineResourcesBeforeMutation() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-enex-unmatched-resource-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    let enex = root.appendingPathComponent("PrivateUnmatchedResource.enex")
    try """
      <en-export>
        <note>
          <title>Private Unmatched ENEX</title>
          <content><![CDATA[<?xml version="1.0" encoding="UTF-8"?><en-note><div>Private unmatched body</div><en-media type="image/png" hash="00000000000000000000000000000000"/></en-note>]]></content>
        </note>
      </en-export>
      """.write(to: enex, atomically: true, encoding: .utf8)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)

    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "enex", "--folder", "Work", "--file", enex.path,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let normalized = dryRunData?["normalizedArguments"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]
    let requirementNotes = requirements?["notes"] as? [String] ?? []
    #expect(normalized?["inline_resource_reference_count"] as? String == "1")
    #expect(normalized?["matched_inline_resource_reference_count"] as? String == "0")
    #expect(normalized?["unmatched_inline_resource_reference_count"] as? String == "1")
    #expect(requirementNotes.contains { $0.contains("matched to a decoded resource") })
    #expect((dryRun.stdout ?? "").contains(enex.path) == false)
    #expect((dryRun.stdout ?? "").contains("Private unmatched body") == false)

    do {
      _ = try command.run(options: CLIOptionsFixture.parse([
        "notes", "import", "enex", "--folder", "Work", "--file", enex.path, "--json",
      ]))
      Issue.record("Expected unmatched inline ENEX resource reference to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(error.details["unmatched_inline_resource_reference_count"] == "1")
      #expect(error.details["source_path_sha256"]?.count == 64)
    }
    #expect(implementation.enexImportDrafts.isEmpty)
  }

  @Test func richImportsUsePrivateWriterAndVerifierForRTFRTFDAndHTML() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-rich-import-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    let rtf = root.appendingPathComponent("PrivateRich.rtf")
    let html = root.appendingPathComponent("PrivateWeb.html")
    let rtfd = root.appendingPathComponent("PrivatePackage.rtfd", isDirectory: true)
    let rtfdRTFData = Data("{\\rtf1\\ansi Private package import body}".utf8)
    let rtfdResourceData = Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
    try "{\\rtf1\\ansi Private rich import body}".write(to: rtf, atomically: true, encoding: .utf8)
    try "<html><body><b>Private html import body</b></body></html>".write(
      to: html, atomically: true, encoding: .utf8)
    try FileManager.default.createDirectory(at: rtfd, withIntermediateDirectories: false)
    try rtfdRTFData.write(to: rtfd.appendingPathComponent("TXT.rtf"), options: [.atomic])
    try rtfdResourceData.write(to: rtfd.appendingPathComponent("PrivateImage.png"), options: [.atomic])
    let rtfdFiles = [
      NotesNoteRTFDExportFile(relativePath: "TXT.rtf", data: rtfdRTFData),
      NotesNoteRTFDExportFile(relativePath: "PrivateImage.png", data: rtfdResourceData),
    ]
    let rtfdTotalBytes = rtfdFiles.reduce(0) { $0 + $1.data.count }
    let rtfdTreeSHA256 = notesRTFDTreeSHA256(rtfdFiles)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let cases: [
      (
        command: String,
        file: URL,
        format: String,
        packageFileCount: Int?,
        packageResourceFileCount: Int?,
        packageTotalByteCount: Int?,
        packageTreeSHA256: String?
      )
    ] = [
      ("rtf", rtf, "rtf", nil, nil, nil, nil),
      ("rtfd", rtfd, "rtfd", 2, 1, rtfdTotalBytes, rtfdTreeSHA256),
      ("html", html, "html", nil, nil, nil, nil),
    ]

    for item in cases {
      let draftCountBeforeDryRun = implementation.richImportDrafts.count
      let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
        "notes", "import", item.command, "--folder", "Work", "--file", item.file.path,
        "--title", "Imported \(item.format.uppercased())",
        "--dry-run", "--json",
      ])))
      let dryRunObject = try jsonObject(dryRun.stdout ?? "")
      let dryRunData = dryRunObject["data"] as? [String: Any]
      let normalized = dryRunData?["normalizedArguments"] as? [String: Any]
      #expect(dryRunData?["operation"] as? String == "notes.import.\(item.format)")
      #expect(normalized?["format_family"] as? String == item.format)
      #expect((normalized?["source_path_sha256"] as? String)?.count == 64)
      #expect((normalized?["source_name_sha256"] as? String)?.count == 64)
      if let packageFileCount = item.packageFileCount {
        #expect(normalized?["package_file_count"] as? String == "\(packageFileCount)")
        #expect(normalized?["package_resource_file_count"] as? String == "\(item.packageResourceFileCount ?? 0)")
        #expect(normalized?["package_total_byte_count"] as? String == "\(item.packageTotalByteCount ?? 0)")
        #expect(normalized?["package_tree_sha256"] as? String == item.packageTreeSHA256)
      } else {
        #expect(normalized?["package_file_count"] == nil)
        #expect(normalized?["package_resource_file_count"] == nil)
        #expect(normalized?["package_tree_sha256"] == nil)
      }
      #expect((dryRun.stdout ?? "").contains(item.file.path) == false)
      #expect((dryRun.stdout ?? "").contains(item.file.lastPathComponent) == false)
      #expect(implementation.richImportDrafts.count == draftCountBeforeDryRun)

      let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
        "notes", "import", item.command, "--folder", "Work", "--file", item.file.path,
        "--title", "Imported \(item.format.uppercased())",
        "--json",
      ])))
      let output = executed.stdout ?? ""
      let object = try jsonObject(output)
      let data = object["data"] as? [String: Any]
      let verification = data?["verification"] as? [String: Any]
      let checks = verification?["checks"] as? [[String: Any]] ?? []
      let checkNames = checks.compactMap { $0["name"] as? String }

      #expect(data?["operation"] as? String == "notes.import.\(item.format)")
      #expect(data?["formatFamily"] as? String == item.format)
      #expect(data?["changed"] as? Bool == true)
      #expect(verification?["verified"] as? Bool == true)
      #expect(checkNames.contains("note_readback"))
      #expect(checkNames.contains("format_family_accounted"))
      #expect(checkNames.contains("body_structure_readback"))
      if let packageFileCount = item.packageFileCount {
        #expect(checkNames.contains("package_tree_hash"))
        #expect(checkNames.contains("package_size_accounted"))
        #expect(checkNames.contains("package_resource_attachment_run"))
        #expect(data?["packageFileCount"] as? Int == packageFileCount)
        #expect(data?["packageResourceFileCount"] as? Int == item.packageResourceFileCount)
        #expect(data?["packageTotalByteCount"] as? Int == item.packageTotalByteCount)
        #expect(data?["packageTreeSHA256"] as? String == item.packageTreeSHA256)
        #expect(data?["attachmentRunCount"] as? Int == item.packageResourceFileCount)
      } else {
        #expect(data?["packageFileCount"] == nil)
        #expect(data?["packageResourceFileCount"] == nil)
        #expect(data?["packageTreeSHA256"] == nil)
      }
      #expect(implementation.richImportDrafts.last?.source.format.rawValue == item.format)
      #expect((data?["note"] as? [String: Any])?["body"] == nil)
      #expect(output.contains(item.file.path) == false)
      #expect(output.contains(item.file.lastPathComponent) == false)
      #expect(output.contains("Private rich import body") == false)
      #expect(output.contains("Private package import body") == false)
      #expect(output.contains("PrivateImage.png") == false)
      #expect(output.contains("Private html import body") == false)
    }

    #expect(implementation.richImportDrafts.count == 3)
  }

  @Test func htmlPackageImportPreservesResourcesWithVerifier() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("notes-html-package-import-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: root) }

    let htmlPackage = root.appendingPathComponent("PrivateWeb.htmlpkg", isDirectory: true)
    let resources = htmlPackage.appendingPathComponent("Resources", isDirectory: true)
    try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
    let htmlData = Data("<html><body><p>Private packaged html body</p></body></html>".utf8)
    let resourceData = Data("%PDF-1.7 private packaged pdf".utf8)
    try htmlData.write(to: htmlPackage.appendingPathComponent("Note.html"), options: [.atomic])
    try resourceData.write(to: resources.appendingPathComponent("Launch.pdf"), options: [.atomic])
    let files = [
      NotesNoteHTMLExportFile(relativePath: "Note.html", data: htmlData),
      NotesNoteHTMLExportFile(relativePath: "Resources/Launch.pdf", data: resourceData),
    ]
    let totalBytes = notesHTMLPackageTotalByteCount(files)
    let treeSHA256 = notesHTMLPackageTreeSHA256(files)

    let implementation = ImportOpenPagesImplementation()
    let command = NotesCommand(implementation: implementation)
    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "html", "--folder", "Work", "--file", htmlPackage.path,
      "--title", "Imported HTML Package", "--include-attachments",
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let normalized = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "notes.import.html")
    #expect(normalized?["format_family"] as? String == "html")
    #expect(normalized?["html_relative_path"] as? String == "Note.html")
    #expect(normalized?["resource_count"] as? String == "1")
    #expect(normalized?["package_file_count"] as? String == "2")
    #expect(normalized?["package_resource_file_count"] as? String == "1")
    #expect(normalized?["package_total_byte_count"] as? String == "\(totalBytes)")
    #expect(normalized?["package_tree_sha256"] as? String == treeSHA256)
    #expect(implementation.richImportDrafts.isEmpty)
    #expect(implementation.attachmentAddDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains(htmlPackage.path) == false)
    #expect((dryRun.stdout ?? "").contains(htmlPackage.lastPathComponent) == false)
    #expect((dryRun.stdout ?? "").contains("Private packaged html body") == false)
    #expect((dryRun.stdout ?? "").contains("private packaged pdf") == false)

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "import", "html", "--folder", "Work", "--file", htmlPackage.path,
      "--title", "Imported HTML Package", "--include-attachments", "--json",
    ])))
    let output = executed.stdout ?? ""
    let object = try jsonObject(output)
    let data = object["data"] as? [String: Any]
    let attachments = data?["attachments"] as? [[String: Any]] ?? []
    let firstAttachment = try #require(attachments.first)
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(data?["operation"] as? String == "notes.import.html")
    #expect(data?["formatFamily"] as? String == "html")
    #expect(data?["htmlRelativePath"] as? String == "Note.html")
    #expect(data?["resourceCount"] as? Int == 1)
    #expect(data?["packageFileCount"] as? Int == 2)
    #expect(data?["packageResourceFileCount"] as? Int == 1)
    #expect(data?["packageTotalByteCount"] as? Int == totalBytes)
    #expect(data?["packageTreeSHA256"] as? String == treeSHA256)
    #expect(firstAttachment["relativePath"] as? String == "Resources/Launch.pdf")
    #expect(firstAttachment["filename"] as? String == "Launch.pdf")
    #expect(firstAttachment["byteCount"] as? Int == resourceData.count)
    #expect(firstAttachment["sha256"] as? String == sha256Hex(resourceData))
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("html_package_mode"))
    #expect(checkNames.contains("html_package_main_file"))
    #expect(checkNames.contains("package_resource_count"))
    #expect(checkNames.contains("attachment_verifications"))
    #expect(implementation.richImportDrafts.count == 1)
    #expect(implementation.richImportDrafts.first?.source.htmlRelativePath == "Note.html")
    #expect(implementation.richImportDrafts.first?.source.resources.count == 1)
    #expect(implementation.attachmentAddDrafts.map(\.filename) == ["Launch.pdf"])
    #expect(output.contains(htmlPackage.path) == false)
    #expect(output.contains(htmlPackage.lastPathComponent) == false)
    #expect(output.contains("Private packaged html body") == false)
    #expect(output.contains("private packaged pdf") == false)
  }

  @Test func openPagesUsesPrivateRTFDExportAndExternalDispatchGate() throws {
    let implementation = ImportOpenPagesImplementation()
    let pages = TestNotesPagesDispatcher()
    let command = NotesCommand(implementation: implementation, pagesDispatcher: pages)

    let dryRun = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "open-in-pages", "--id", "note-2", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "notes.open-in-pages")
    #expect(summary?["application"] as? String == "Pages")
    #expect(summary?["file_count"] as? String == "2")
    #expect(summary?["tree_sha256"] != nil)
    #expect(requirements?["allowFlags"] as? [String] == ["--allow-external-dispatch"])
    #expect(pages.submissions.isEmpty)

    do {
      _ = try command.run(options: CLIOptionsFixture.parse([
        "notes", "open-in-pages", "--id", "note-2", "--json",
      ]))
      Issue.record("Expected open-in-pages without --allow-external-dispatch to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-external-dispatch")
      #expect(pages.submissions.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes", "open-in-pages", "--id", "note-2", "--allow-external-dispatch", "--json",
    ])))
    let output = executed.stdout ?? ""
    let executedObject = try jsonObject(output)
    let executedData = executedObject["data"] as? [String: Any]
    let verification = executedData?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(executedData?["operation"] as? String == "notes.open-in-pages")
    #expect(executedData?["submitted"] as? Bool == true)
    #expect(executedData?["applicationName"] as? String == "Pages")
    #expect(executedData?["fileCount"] as? Int == 2)
    #expect((executedData?["stagedPackagePathSHA256"] as? String)?.count == 64)
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("application_pages"))
    #expect(checkNames.contains("tree_sha256"))
    #expect(checkNames.contains("note_readback"))
    #expect(pages.submissions.count == 1)
    #expect(pages.submissions.first?.suggestedTitle == "Launch Plan")
    #expect(pages.submissions.first?.files.count == 2)
    #expect(output.contains("{\\rtf1") == false)
    #expect(output.contains("test pages attachment") == false)
  }

  @Test func openPagesSupportsSessionUnlockedProtectedNoteWithoutTitleLeakage() throws {
    let implementation = ImportOpenPagesImplementation()
    let pages = TestNotesPagesDispatcher()
    let command = NotesCommand(implementation: implementation, pagesDispatcher: pages)

    let executed = try #require(try command.run(options: CLIOptionsFixture.parse([
      "notes",
      "open-in-pages",
      "--id",
      "note-unlocked-protected",
      "--allow-external-dispatch",
      "--json",
    ])))
    let output = executed.stdout ?? ""
    let executedObject = try jsonObject(output)
    let executedData = executedObject["data"] as? [String: Any]
    let verification = executedData?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }

    #expect(executedData?["operation"] as? String == "notes.open-in-pages")
    #expect(executedData?["submitted"] as? Bool == true)
    #expect(executedData?["title"] == nil)
    #expect(executedData?["isPasswordProtected"] as? Bool == true)
    #expect(executedData?["isPasswordProtectedAndLocked"] as? Bool == false)
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("session_unlocked_password_protected_external_dispatch_boundary"))
    #expect(pages.submissions.count == 1)
    #expect(pages.submissions.first?.suggestedTitle == "note-unlocked-protected")
    #expect(output.contains("Unlocked Private Plan") == false)
    #expect(output.contains("Unlocked protected body") == false)
  }
}

private enum ImportOpenPagesImplementationError: Error {
  case unsupported
}

private final class ImportOpenPagesImplementation: NotesReading, NotesNoteStateReading, NotesNoteExporting, NotesRichImporting, NotesENEXImporting,
  NotesAttachmentReading, NotesAttachmentMutating, NotesMutating,
  @unchecked Sendable
{
  var createdDrafts: [NotesCreateDraft] = []
  var createdFolderDrafts: [NotesFolderCreateDraft] = []
  var richImportDrafts: [NotesRichImportDraft] = []
  var enexImportDrafts: [NotesENEXImportDraft] = []
  var attachmentAddDrafts: [NotesAttachmentAddDraft] = []

  private var folders: [String: NotesFolderRecord] = [
    "folder-work": NotesFolderRecord(
      id: "folder-work",
      name: "Work",
      accountName: "iCloud",
      parentPresent: false,
      canAddSubfolder: true,
      supportsEditingNotes: true
    )
  ]

  private var notes: [String: NotesNoteDetail] = [
    "note-2": NotesNoteDetail(
      id: "note-2",
      title: "Launch Plan",
      folderName: "Work",
      accountName: "iCloud",
      body: "Private note body"
    ),
    "note-locked": NotesNoteDetail(
      id: "note-locked",
      title: "Locked Private Plan",
      folderName: "Work",
      accountName: "iCloud",
      body: "Locked private body"
    ),
    "note-unlocked-protected": NotesNoteDetail(
      id: "note-unlocked-protected",
      title: "Unlocked Private Plan",
      folderName: "Work",
      accountName: "iCloud",
      body: "Unlocked protected body"
    ),
  ]

  private var noteStates: [String: NotesNoteStateRecord] = [
    "note-2": NotesNoteStateRecord(
      noteID: "note-2",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPasswordProtected: false,
      isEditable: true,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      folderID: "folder-work",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
    "note-locked": NotesNoteStateRecord(
      noteID: "note-locked",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPasswordProtected: true,
      isPasswordProtectedAndLocked: true,
      isEditable: false,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      folderID: "folder-work",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
    "note-unlocked-protected": NotesNoteStateRecord(
      noteID: "note-unlocked-protected",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPasswordProtected: true,
      isPasswordProtectedAndLocked: false,
      isEditable: true,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      folderID: "folder-work",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
  ]

  private var attachments: [String: [NotesAttachmentRecord]] = [:]
  private var attachmentData: [String: [String: Data]] = [:]

  private func visibleState(noteID id: String) -> NotesNoteStateRecord {
    NotesNoteStateRecord(
      noteID: id,
      isDeletedOrInTrash: false,
      isPinned: false,
      isPasswordProtected: false,
      isEditable: true,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      folderID: "folder-work",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    )
  }

  private func noteExportPrivacyState(
    noteID id: String
  ) throws -> (isPasswordProtected: Bool, isPasswordProtectedAndLocked: Bool?, title: String?) {
    let state = try readNoteState(noteID: id)
    guard state.isPasswordProtected == false || state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message:
          "Password-protected Notes export requires the selected note to already be unlocked in the current Notes session.",
        details: [
          "id_sha256": "test",
          "required_state": "non_password_protected_or_session_unlocked_password_protected_note",
          "future_gate": "secret_safe_authentication_session",
        ]
      )
    }
    return (
      state.isPasswordProtected,
      state.isPasswordProtectedAndLocked,
      state.isPasswordProtected ? nil : notes[id]?.title
    )
  }

  func exportNoteRTFD(noteID id: String) throws -> NotesNoteRTFDExportSource {
    guard let note = notes[id] else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    let exportState = try noteExportPrivacyState(noteID: id)
    let rtfData = id == "note-unlocked-protected"
      ? Data("{\\rtf1\\ansi Unlocked protected body}".utf8)
      : Data("{\\rtf1\\ansi Launch plan}".utf8)
    return NotesNoteRTFDExportSource(
      noteID: note.id,
      title: exportState.title,
      files: [
        NotesNoteRTFDExportFile(
          relativePath: "TXT.rtf",
          data: rtfData
        ),
        NotesNoteRTFDExportFile(
          relativePath: "Attachments/info.txt",
          data: Data("test pages attachment".utf8)
        ),
      ],
      isPasswordProtected: exportState.isPasswordProtected,
      isPasswordProtectedAndLocked: exportState.isPasswordProtectedAndLocked
    )
  }

  func readNote(id: String) throws -> NotesNoteDetail? {
    notes[id]
  }

  func readNoteState(noteID id: String) throws -> NotesNoteStateRecord {
    if let state = noteStates[id] {
      return state
    }
    guard notes[id] != nil else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    return visibleState(noteID: id)
  }

  func listAccounts() throws -> [NotesAccountRecord] { throw ImportOpenPagesImplementationError.unsupported }
  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    folders.values
      .filter { account == nil || $0.accountName.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame }
      .sorted { $0.id < $1.id }
  }
  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func listAttachments(noteID id: String, limit: Int) throws -> [NotesAttachmentRecord] {
    guard notes[id] != nil else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    return (attachments[id] ?? []).prefix(limit).map { $0 }
  }

  func exportAttachment(noteID id: String, attachmentID: String) throws -> NotesAttachmentExportSource {
    guard notes[id] != nil else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    let matches = (attachments[id] ?? []).filter { attachment in
      attachment.id == attachmentID
        || attachment.contentIdentifier == attachmentID
        || attachment.mediaFilename == attachmentID
        || attachment.title == attachmentID
    }
    guard let attachment = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the note.",
        details: ["attachment_sha256": "test"]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments on the note.",
        details: ["attachment_sha256": "test"]
      )
    }
    let data = attachmentData[id]?[attachment.id]
      ?? attachment.contentIdentifier.flatMap { attachmentData[id]?[$0] }
    guard let data else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment data could not be read through NotesShared media APIs.",
        details: ["attachment_sha256": "test"]
      )
    }
    return NotesAttachmentExportSource(noteID: id, attachment: attachment, data: data)
  }

  func exportAttachmentPDF(noteID id: String, attachmentID: String) throws -> NotesAttachmentPDFExportSource {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func inspectAttachmentMarkup(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentMarkupInspectionSource
  {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func readAttachmentAudioTranscript(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentAudioTranscriptSource
  {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func exportNotePDF(noteID id: String) throws -> NotesNotePDFExportSource {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func exportNoteMarkdown(noteID id: String, includeAttachments: Bool) throws
    -> NotesNoteMarkdownExportSource
  {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func exportNoteHTML(
    noteID id: String,
    includeAttachments: Bool,
    includeAttachmentResources: Bool
  ) throws -> NotesNoteHTMLExportSource {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func exportNoteRTF(noteID id: String) throws -> NotesNoteRTFExportSource {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    createdDrafts.append(draft)
    let note = NotesNoteDetail(
      id: "created-\(createdDrafts.count)",
      title: draft.title,
      folderName: draft.folderName,
      accountName: draft.accountName,
      body: draft.body
    )
    notes[note.id] = note
    noteStates[note.id] = visibleState(noteID: note.id)
    return note
  }

  func addAttachment(_ draft: NotesAttachmentAddDraft) throws -> NotesAttachmentAddWriteResult {
    guard notes[draft.noteID] != nil else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": draft.noteID])
    }
    let next = attachmentAddDrafts.count + 1
    let record = NotesAttachmentRecord(
      id: "attachment-added-\(next)",
      title: draft.filename,
      typeUTI: "public.data",
      contentIdentifier: "attachment-added-content-\(next)",
      attachmentType: 9,
      fileSizeBytes: Int64(draft.data.count),
      mediaFilename: draft.filename,
      isInline: false,
      isDeletedOrInTrash: false
    )
    attachments[draft.noteID, default: []].append(record)
    attachmentData[draft.noteID, default: [:]][record.id] = draft.data
    if let contentIdentifier = record.contentIdentifier {
      attachmentData[draft.noteID, default: [:]][contentIdentifier] = draft.data
    }
    attachmentAddDrafts.append(draft)
    return NotesAttachmentAddWriteResult(noteID: draft.noteID, attachment: record)
  }

  func renameAttachment(_ draft: NotesAttachmentRenameDraft) throws -> NotesAttachmentRenameWriteResult {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func removeAttachment(_ draft: NotesAttachmentRemoveDraft) throws -> NotesAttachmentRemoveWriteResult {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func applyAttachmentMarkup(_ draft: NotesAttachmentMarkupEditDraft) throws
    -> NotesAttachmentMarkupEditWriteResult
  {
    throw ImportOpenPagesImplementationError.unsupported
  }

  func importRichText(_ draft: NotesRichImportDraft) throws -> NotesRichImportResult {
    richImportDrafts.append(draft)
    let id = "rich-\(draft.source.format.rawValue)-\(richImportDrafts.count)"
    let note = NotesNoteDetail(
      id: id,
      title: draft.draft.title,
      folderName: draft.draft.folderName,
      accountName: draft.draft.accountName,
      body: nil
      )
      notes[id] = note
      noteStates[id] = visibleState(noteID: id)
      let plainText = "Imported rich body \(draft.source.format.rawValue)"
    let resourceFileCount = draft.source.packageResourceFileCount ?? 0
    let attachmentRunCount = draft.source.format == .rtfd ? resourceFileCount : 0
    var checks = [
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: "passed",
        expectedBool: true,
        actualBool: true
      ),
      NotesVerificationCheckRecord(
        name: "format_family_accounted",
        status: "passed",
        expectedBool: true,
        actualBool: true
      ),
      NotesVerificationCheckRecord(
        name: "body_structure_readback",
        status: "passed",
        expectedBool: true,
        actualBool: true
      ),
    ]
    if draft.source.format == .rtfd {
      checks.append(contentsOf: [
        NotesVerificationCheckRecord(
          name: "package_tree_hash",
          status: "passed",
          expectedBool: true,
          actualBool: draft.source.packageTreeSHA256 != nil
        ),
        NotesVerificationCheckRecord(
          name: "package_size_accounted",
          status: "passed",
          expectedBool: true,
          actualBool: (draft.source.packageFileCount ?? 0) > 0
            && (draft.source.packageTotalByteCount ?? 0) > 0
        ),
        NotesVerificationCheckRecord(
          name: "package_resource_attachment_run",
          status: "passed",
          expectedBool: true,
          actualBool: resourceFileCount == 0 || attachmentRunCount > 0
        ),
      ])
    }
    return NotesRichImportResult(
      operation: "notes.import.\(draft.source.format.rawValue)",
      changed: true,
      note: note,
      formatFamily: draft.source.format.rawValue,
      sourceByteCount: draft.source.byteCount,
      sourceSHA256: draft.source.data.map(sha256Hex),
      importedPlainTextLength: (plainText as NSString).length,
      importedPlainTextSHA256: sha256Hex(plainText),
      attributedRunCount: 2,
      attachmentRunCount: attachmentRunCount,
      packageFileCount: draft.source.packageFileCount,
      packageResourceFileCount: draft.source.packageResourceFileCount,
      packageTotalByteCount: draft.source.packageTotalByteCount,
      packageTreeSHA256: draft.source.packageTreeSHA256,
      verification: NotesMutationVerificationReport(
        verifier: "notes_rich_import_v1",
        operation: "notes.import.\(draft.source.format.rawValue)",
        verified: true,
        evidenceLevel: "private_framework_rich_text_import+text_storage_write+note_readback",
        targetIDSHA256: sha256Hex(id),
        checks: checks
      )
    )
  }

  func importENEX(_ draft: NotesENEXImportDraft) throws -> NotesENEXImportResult {
    enexImportDrafts.append(draft)
    var importedNotes: [NotesENEXImportedNoteResult] = []
    var checks = [
      NotesVerificationCheckRecord(
        name: "resource_payloads_supported",
        status: "passed",
        expectedBool: true,
        actualBool: true
      ),
      NotesVerificationCheckRecord(
        name: "tag_shape_supported",
        status: draft.source.unsupportedTagCount == 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: draft.source.unsupportedTagCount == 0
      ),
      NotesVerificationCheckRecord(
        name: "tag_normalization_accounting",
        status: "passed",
        expectedLength: draft.source.normalizedTagCount,
        actualLength: draft.source.normalizedTagCount
      ),
      NotesVerificationCheckRecord(
        name: "inline_resource_references_matched",
        status: draft.source.unmatchedInlineResourceReferenceCount == 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: draft.source.unmatchedInlineResourceReferenceCount == 0
      ),
    ]

    for sourceNote in draft.source.notes {
      let id = "enex-\(sourceNote.ordinal)"
      let tags = sourceNote.tags.map {
        let displayText = notesENEXNormalizedTagText($0) ?? standardizedTagContent($0)
        return NotesTagRecord(
          id: "tag-\(displayText)",
          displayText: displayText,
          standardizedContent: displayText,
          accountName: draft.accountName,
          visibleUseCount: 1
        )
      }
      let note = NotesNoteDetail(
        id: id,
        title: sourceNote.title,
        folderName: draft.folderName,
        accountName: draft.accountName,
        body: nil,
        createdAt: sourceNote.createdAt,
        updatedAt: sourceNote.updatedAt,
        tags: tags
      )
      notes[id] = note
      noteStates[id] = visibleState(noteID: id)
      let plainText = "Imported ENEX body \(sourceNote.ordinal)"
      let inlineReferenceCountsByResourceOrdinal = Dictionary(
        grouping: sourceNote.inlineResourceReferences.compactMap(\.matchedResourceOrdinal),
        by: { $0 }
      ).mapValues(\.count)
      let attachmentResults: [NotesENEXImportAttachmentResult] = sourceNote.resources.map { resource in
        let inlineReferenceCount = inlineReferenceCountsByResourceOrdinal[resource.ordinal] ?? 0
        return NotesENEXImportAttachmentResult(
          ordinal: resource.ordinal,
          filename: resource.filename,
          mimeType: resource.mimeType,
          byteCount: resource.byteCount,
          sha256: resource.dataSHA256,
          inlineReferenceCount: inlineReferenceCount,
          inlinePlacementCount: inlineReferenceCount,
          attachment: NotesAttachmentRecord(
            id: "enex-\(sourceNote.ordinal)-resource-\(resource.ordinal)",
            title: resource.filename,
            typeUTI: resource.mimeType,
            attachmentType: 0,
            fileSizeBytes: Int64(resource.byteCount),
            mediaFilename: resource.filename,
            isInline: inlineReferenceCount > 0
          )
        )
      }
      importedNotes.append(
        NotesENEXImportedNoteResult(
          ordinal: sourceNote.ordinal,
          note: note,
          sourceTitleSHA256: sourceNote.titleSHA256,
          sourceContentSHA256: sourceNote.contentSHA256,
          importedPlainTextLength: (plainText as NSString).length,
          importedPlainTextSHA256: sha256Hex(plainText),
          tagCount: sourceNote.tags.count,
          resourceCount: sourceNote.resourceCount,
          resourceByteCount: sourceNote.resourceByteCount,
          inlineResourceReferenceCount: sourceNote.inlineResourceReferenceCount,
          matchedInlineResourceReferenceCount: sourceNote.matchedInlineResourceReferenceCount,
          placedInlineResourceReferenceCount: attachmentResults.reduce(0) { $0 + $1.inlinePlacementCount },
          attachments: attachmentResults,
          createdAtPreserved: sourceNote.createdAt != nil ? true : nil,
          updatedAtPreserved: sourceNote.updatedAt != nil ? true : nil
        ))
      checks.append(contentsOf: [
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_readback",
          status: "passed",
          expectedBool: true,
          actualBool: true
        ),
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_title_readback",
          status: "passed",
          expectedBool: true,
          actualBool: true
        ),
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_folder_readback",
          status: "passed",
          expectedBool: true,
          actualBool: true
        ),
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_tag_membership_readback",
          status: "passed",
          expectedBool: true,
          actualBool: true
        ),
      ])
      checks.append(
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_resource_count_readback",
          status: attachmentResults.count == sourceNote.resourceCount ? "passed" : "failed",
          expectedLength: sourceNote.resourceCount,
          actualLength: attachmentResults.count
        ))
      checks.append(
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_inline_resource_reference_count",
          status: sourceNote.matchedInlineResourceReferenceCount == sourceNote.inlineResourceReferenceCount
            ? "passed" : "failed",
          expectedLength: sourceNote.inlineResourceReferenceCount,
          actualLength: sourceNote.matchedInlineResourceReferenceCount
        ))
      checks.append(
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_inline_resource_placement_count",
          status: attachmentResults.reduce(0) { $0 + $1.inlinePlacementCount } == sourceNote.inlineResourceReferenceCount
            ? "passed" : "failed",
          expectedLength: sourceNote.inlineResourceReferenceCount,
          actualLength: attachmentResults.reduce(0) { $0 + $1.inlinePlacementCount }
        ))
      for resource in sourceNote.resources {
        let inlineReferenceCount = inlineReferenceCountsByResourceOrdinal[resource.ordinal] ?? 0
        checks.append(contentsOf: [
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_resource_\(resource.ordinal)_attachment_readback",
            status: "passed",
            expectedBool: true,
            actualBool: true
          ),
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_resource_\(resource.ordinal)_filename_readback",
            status: "passed",
            expectedBool: true,
            actualBool: true
          ),
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_resource_\(resource.ordinal)_byte_count",
            status: "passed",
            expectedLength: resource.byteCount,
            actualLength: resource.byteCount
          ),
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_resource_\(resource.ordinal)_sha256",
            status: "passed",
            expectedSHA256: resource.dataSHA256,
            actualSHA256: resource.dataSHA256
          ),
        ])
        if inlineReferenceCount > 0 {
          checks.append(
            NotesVerificationCheckRecord(
              name: "note_\(sourceNote.ordinal)_resource_\(resource.ordinal)_inline_placement_count",
              status: "passed",
              expectedLength: inlineReferenceCount,
              actualLength: inlineReferenceCount
            ))
          checks.append(
            NotesVerificationCheckRecord(
              name: "note_\(sourceNote.ordinal)_resource_\(resource.ordinal)_inline_attachment_readback",
              status: "passed",
              expectedBool: true,
              actualBool: true
            ))
        }
      }
      if sourceNote.createdAt != nil {
        checks.append(
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_created_date_preserved",
            status: "passed",
            expectedBool: true,
            actualBool: true
          ))
      }
      if sourceNote.updatedAt != nil {
        checks.append(
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_updated_date_preserved",
            status: "passed",
            expectedBool: true,
            actualBool: true
          ))
      }
    }

    checks.append(
      NotesVerificationCheckRecord(
        name: "imported_note_count",
        status: importedNotes.count == draft.source.noteCount ? "passed" : "failed",
        expectedBool: true,
        actualBool: importedNotes.count == draft.source.noteCount
      ))

    return NotesENEXImportResult(
      operation: "notes.import.enex",
      changed: true,
      importedNoteCount: importedNotes.count,
      sourceByteCount: draft.source.byteCount,
      sourceSHA256: draft.source.dataSHA256,
      tagCount: draft.source.tagCount,
      uniqueTagCount: draft.source.uniqueTagCount,
      normalizedTagCount: draft.source.normalizedTagCount,
      resourceCount: draft.source.resourceCount,
      resourceByteCount: draft.source.resourceByteCount,
      inlineResourceReferenceCount: draft.source.inlineResourceReferenceCount,
      matchedInlineResourceReferenceCount: draft.source.matchedInlineResourceReferenceCount,
      placedInlineResourceReferenceCount: importedNotes.reduce(0) { $0 + $1.placedInlineResourceReferenceCount },
      createdDateCount: draft.source.createdDateCount,
      updatedDateCount: draft.source.updatedDateCount,
      importedNotes: importedNotes,
      verification: NotesMutationVerificationReport(
        verifier: "notes_enex_import_v1",
        operation: "notes.import.enex",
        verified: checks.allSatisfy { $0.status == "passed" },
        evidenceLevel: "private_framework_enex_parse+tag_normalization+inline_media_reference_match+inline_media_body_position_insert+note_create+tag_write+attachment_write+attachment_export_hash+note_readback",
        targetIDSHA256: sha256Hex(importedNotes.map(\.note.id).joined(separator: "\n")),
        checks: checks
      )
    )
  }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    createdFolderDrafts.append(draft)
    let parentDepth = draft.parentID.flatMap { folders[$0]?.depth } ?? 0
    let folder = NotesFolderRecord(
      id: "folder-created-\(createdFolderDrafts.count)",
      name: draft.name,
      accountName: draft.accountName,
      parentID: draft.parentID,
      parentPresent: draft.parentID != nil,
      depth: draft.parentID == nil ? 0 : parentDepth + 1,
      canAddSubfolder: true,
      supportsEditingNotes: true
    )
    folders[folder.id] = folder
    return folder
  }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func deleteNote(id: String) throws -> Bool {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func purgeNote(id: String) throws -> Bool {
    throw ImportOpenPagesImplementationError.unsupported
  }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw ImportOpenPagesImplementationError.unsupported
  }
}

private final class TestNotesPagesDispatcher: NotesPagesDispatching, @unchecked Sendable {
  struct Submission {
    var files: [NotesNoteRTFDExportFile]
    var suggestedTitle: String?
  }

  var submissions: [Submission] = []

  func openRTFDPackage(_ files: [NotesNoteRTFDExportFile], suggestedTitle: String?) throws
    -> NotesPagesOpenDispatchRecord
  {
    let normalized = try normalizedNotesRTFDExportFiles(files)
    submissions.append(Submission(files: normalized, suggestedTitle: suggestedTitle))
    return NotesPagesOpenDispatchRecord(
      applicationName: "Pages",
      stagedPackagePathSHA256: sha256Hex("/tmp/test-pages-\(submissions.count).rtfd"),
      fileCount: normalized.count,
      totalByteCount: notesRTFDTotalByteCount(normalized),
      treeSHA256: notesRTFDTreeSHA256(normalized)
    )
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw ImportOpenPagesCommandTestError.notObject
  }
  return object
}

private enum ImportOpenPagesCommandTestError: Error {
  case notObject
}
