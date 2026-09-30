import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes guide audit command")
struct NotesGuideAuditCommandTests {
  @Test func guideAuditAccountsForCurrentOfficialGuideTocWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "guide", "audit", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let summary = try #require(data["summary"] as? [String: Any])
    let records = try #require(data["records"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = verification["checks"] as? [[String: Any]] ?? []
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let byFamily = Dictionary(
      uniqueKeysWithValues: records.compactMap { record -> (String, [String: Any])? in
        guard let family = record["workflowFamily"] as? String else {
          return nil
        }
        return (family, record)
      })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.guide.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 36)
    #expect(summary["supportedRecordCount"] as? Int == 28)
    #expect(summary["delegatedRecordCount"] as? Int == 5)
    #expect(summary["gatedRecordCount"] as? Int == 2)
    #expect(summary["rejectedRecordCount"] as? Int == 1)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["guide_welcome"]?["status"] as? String == "supported")
    #expect(byFamily["guide_get_started"]?["status"] as? String == "supported")
    #expect(byFamily["guide_create_edit"]?["status"] as? String == "supported")
    #expect(byFamily["guide_import_export_print"]?["status"] as? String == "supported")
    #expect(byFamily["guide_keyboard_shortcuts"]?["status"] as? String == "supported")
    #expect(byFamily["guide_accounts"]?["status"] as? String == "delegated")
    #expect(byFamily["guide_widgets"]?["status"] as? String == "delegated")
    #expect(byFamily["guide_quick_note"]?["status"] as? String == "supported")
    #expect(byFamily["guide_audio"]?["status"] as? String == "supported")
    #expect(byFamily["guide_manage_pdfs_scans"]?["status"] as? String == "supported")
    #expect(byFamily["guide_markup_attachments"]?["status"] as? String == "supported")
    #expect(byFamily["guide_search"]?["status"] as? String == "supported")
    #expect((byFamily["guide_search"]?["command"] as? String)?.contains("attachments recognized-text generate") == true)
    #expect((byFamily["guide_search"]?["command"] as? String)?.contains("attachments recognized-text generate/index") == true)
    #expect((byFamily["guide_search"]?["command"] as? String)?.contains("attachments image objects") == true)
    #expect(byFamily["guide_smart_folders"]?["status"] as? String == "supported")
    #expect(byFamily["guide_share"]?["status"] as? String == "supported")
    #expect(byFamily["guide_manage_shared"]?["status"] as? String == "supported")
    #expect(byFamily["guide_collaborate"]?["status"] as? String == "supported")
    #expect(byFamily["guide_copyright"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("current_toc_page_count_accounted"))
    #expect(checkNames.contains("official_toc_pages_accounted"))
    #expect(checkNames.contains("implemented_family_pages_supported"))
    #expect(checkNames.contains("system_ui_pages_delegated"))
    #expect(checkNames.contains("remaining_security_pages_gated"))
    #expect(checkNames.contains("non_capability_toc_page_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private note body") == false)
    #expect(result.stdout?.contains("note-1") == false)
    expectNoNotesGuideAuditImplementationCalls(implementation)
  }

  @Test func guideAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "notes",
      "guide",
      "audit",
      "--id",
      "note-1",
      "--folder",
      "Private Folder",
      "--title",
      "Secret title",
      "--body",
      "Private note body",
      "--text",
      "Selected text",
      "--paragraph",
      "private-paragraph",
      "--query",
      "Launch",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected notes guide audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--folder"))
      #expect(rejectedOptions.contains("--title"))
      #expect(rejectedOptions.contains("--body"))
      #expect(rejectedOptions.contains("--text"))
      #expect(rejectedOptions.contains("--paragraph"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("Private Folder") == false)
      #expect(error.details.values.contains("Secret title") == false)
      #expect(error.details.values.contains("Private note body") == false)
      #expect(error.details.values.contains("Selected text") == false)
      #expect(error.details.values.contains("private-paragraph") == false)
      #expect(error.details.values.contains("Launch") == false)
      expectNoNotesGuideAuditImplementationCalls(implementation)
    }
  }
}

private func expectNoNotesGuideAuditImplementationCalls(_ implementation: TestNotesImplementation) {
  #expect(implementation.searchQueries.isEmpty)
  #expect(implementation.accountSearchQueries.isEmpty)
  #expect(implementation.accountListQueries.isEmpty)
  #expect(implementation.createdDrafts.isEmpty)
  #expect(implementation.updatedPatches.isEmpty)
  #expect(implementation.movedDrafts.isEmpty)
  #expect(implementation.copiedDrafts.isEmpty)
  #expect(implementation.restoredDrafts.isEmpty)
  #expect(implementation.deletedIDs.isEmpty)
  #expect(implementation.purgedIDs.isEmpty)
  #expect(implementation.pinnedMutations.isEmpty)
  #expect(implementation.createdFolderDrafts.isEmpty)
  #expect(implementation.renamedFolderDrafts.isEmpty)
  #expect(implementation.movedFolderDrafts.isEmpty)
  #expect(implementation.deletedFolderDrafts.isEmpty)
  #expect(implementation.bodyParagraphStyleDrafts.isEmpty)
  #expect(implementation.bodyParagraphAlignmentDrafts.isEmpty)
  #expect(implementation.bodyParagraphQuoteDrafts.isEmpty)
  #expect(implementation.bodyInlineFormatDrafts.isEmpty)
  #expect(implementation.bodyInlineFontDrafts.isEmpty)
  #expect(implementation.bodyChecklistSetDrafts.isEmpty)
  #expect(implementation.bodyChecklistReorderDrafts.isEmpty)
  #expect(implementation.bodyListReorderDrafts.isEmpty)
  #expect(implementation.bodyTableCreateDrafts.isEmpty)
  #expect(implementation.bodyTableUpdateDrafts.isEmpty)
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
