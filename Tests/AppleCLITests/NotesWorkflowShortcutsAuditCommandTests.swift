import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes workflow shortcuts audit command")
struct NotesWorkflowShortcutsAuditCommandTests {
  @Test func workflowShortcutsAuditAccountsForOfficialShortcutPageWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "workflow", "shortcuts", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.workflow.shortcuts.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 58)
    #expect(summary["supportedRecordCount"] as? Int == 37)
    #expect(summary["delegatedRecordCount"] as? Int == 21)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["shortcut_create_new_note"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_create_quick_note"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_duplicate_note"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_create_new_folder"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_search_all_notes"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_print_note"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_pin_note_swipe"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_delete_note_swipe"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_attach_file"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_create_web_link"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_insert_table"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_apply_monostyled_format"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_list_soft_return"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_list_tab_character"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_table_cell_new_paragraph"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_table_cell_tab_character"]?["status"] as? String == "supported")
    #expect(byFamily["shortcut_show_main_window"]?["status"] as? String == "delegated")
    #expect(byFamily["shortcut_table_select_entire_table"]?["status"] as? String == "delegated")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("official_shortcuts_sections_accounted"))
    #expect(checkNames.contains("semantic_shortcut_results_supported"))
    #expect(checkNames.contains("formatting_shortcuts_supported"))
    #expect(checkNames.contains("table_mutation_shortcuts_supported"))
    #expect(checkNames.contains("ui_navigation_selection_shortcuts_delegated"))
    #expect(checkNames.contains("no_remaining_shortcut_semantics_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private note body") == false)
    #expect(result.stdout?.contains("note-1") == false)
    expectNoNotesShortcutAuditImplementationCalls(implementation)
  }

  @Test func workflowShortcutsAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "notes",
      "workflow",
      "shortcuts",
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
      Issue.record("Expected notes workflow shortcuts audit to reject selector input.")
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
      expectNoNotesShortcutAuditImplementationCalls(implementation)
    }
  }
}

private func expectNoNotesShortcutAuditImplementationCalls(_ implementation: TestNotesImplementation) {
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
