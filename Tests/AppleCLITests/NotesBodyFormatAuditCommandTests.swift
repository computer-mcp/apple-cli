import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes body format audit command")
struct NotesBodyFormatAuditCommandTests {
  @Test func formatAuditAccountsForOfficialFormattingWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "body", "format", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.body.format.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 36)
	    #expect(summary["supportedRecordCount"] as? Int == 32)
	    #expect(summary["delegatedRecordCount"] as? Int == 4)
	    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["inline_emphasis"]?["status"] as? String == "supported")
    #expect(byFamily["inline_text_color"]?["status"] as? String == "supported")
    #expect(byFamily["inline_highlight_color"]?["status"] as? String == "supported")
    #expect(byFamily["inline_font_family"]?["status"] as? String == "supported")
    #expect(byFamily["inline_font_size"]?["status"] as? String == "supported")
    #expect(byFamily["paragraph_style"]?["status"] as? String == "supported")
    #expect((byFamily["paragraph_style"]?["command"] as? String)?.contains("monostyled") == true)
    #expect(byFamily["default_new_note_style"]?["status"] as? String == "supported")
    #expect(byFamily["text_alignment"]?["status"] as? String == "supported")
    #expect(byFamily["collapsible_section_create"]?["status"] as? String == "supported")
    #expect(byFamily["collapsible_section_state_read"]?["status"] as? String == "supported")
    #expect(byFamily["collapsible_section_collapse_expand"]?["status"] as? String == "supported")
    #expect(byFamily["ordinary_list_add"]?["status"] as? String == "supported")
    #expect(byFamily["ordinary_list_style_change"]?["status"] as? String == "supported")
    #expect(byFamily["ordinary_list_indent_outdent"]?["status"] as? String == "supported")
    #expect(byFamily["ordinary_list_reorder"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_add"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_convert"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_set_one"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_set_all"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_auto_sort_setting"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_reorder"]?["status"] as? String == "supported")
    #expect(byFamily["table_create"]?["status"] as? String == "supported")
    #expect(byFamily["table_cell_update"]?["status"] as? String == "supported")
    #expect(byFamily["table_convert_to_text"]?["status"] as? String == "supported")
    #expect(byFamily["text_selection_to_table"]?["status"] as? String == "supported")
    #expect(byFamily["table_move"]?["status"] as? String == "supported")
    #expect(byFamily["table_row_column_insert_delete"]?["status"] as? String == "supported")
    #expect(byFamily["table_row_column_move_copy_clear"]?["status"] as? String == "supported")
    #expect(byFamily["touch_bar_list_checklist"]?["status"] as? String == "delegated")
    #expect(byFamily["keyboard_shortcuts_and_menu_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["table_keyboard_navigation_selection"]?["status"] as? String == "delegated")
    #expect(byFamily["typing_suggestions"]?["status"] as? String == "delegated")
    #expect(byFamily["list_end_to_paragraph"]?["status"] as? String == "supported")
    #expect((byFamily["list_end_to_paragraph"]?["command"] as? String)?.contains("body checklist end") == true)
    #expect(byFamily["list_soft_return"]?["status"] as? String == "supported")
	    #expect(byFamily["table_row_column_formatting"]?["status"] as? String == "supported")
	    #expect(byFamily["external_table_paste_conversion"]?["status"] as? String == "supported")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("inline_formatting_supported"))
    #expect(checkNames.contains("paragraph_and_collapsible_supported"))
    #expect(checkNames.contains("list_and_checklist_supported"))
    #expect(checkNames.contains("table_structure_supported"))
    #expect(checkNames.contains("ui_interactions_delegated"))
    #expect(checkNames.contains("no_remaining_format_semantics_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Selected body text") == false)
    #expect(result.stdout?.contains("note-1") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.updatedPatches.isEmpty)
    #expect(implementation.createdDrafts.isEmpty)
  }

  @Test func formatAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "body", "format", "audit", "--id", "note-1", "--text", "Selected body text", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected body format audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--text"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("Selected body text") == false)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
      #expect(implementation.updatedPatches.isEmpty)
      #expect(implementation.createdDrafts.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
