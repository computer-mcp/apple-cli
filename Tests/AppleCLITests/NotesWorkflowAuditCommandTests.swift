import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes workflow audit command")
struct NotesWorkflowAuditCommandTests {
  @Test func workflowAuditAccountsForOfficialNoteLifecycleWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "workflow", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.workflow.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 40)
    #expect(summary["supportedRecordCount"] as? Int == 22)
    #expect(summary["delegatedRecordCount"] as? Int == 17)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 1)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["visible_note_list"]?["status"] as? String == "supported")
    #expect(byFamily["note_read_open"]?["status"] as? String == "supported")
    #expect(byFamily["note_create"]?["status"] as? String == "supported")
    #expect(byFamily["note_edit_update"]?["status"] as? String == "supported")
    #expect(byFamily["note_append_text"]?["status"] as? String == "supported")
    #expect(byFamily["note_duplicate_copy"]?["status"] as? String == "supported")
    #expect(byFamily["note_move_folder"]?["status"] as? String == "supported")
    #expect(byFamily["note_delete_recently_deleted"]?["status"] as? String == "supported")
    #expect(byFamily["note_restore_recently_deleted"]?["status"] as? String == "supported")
    #expect(byFamily["note_purge_recently_deleted"]?["status"] as? String == "supported")
    #expect(byFamily["note_pin"]?["status"] as? String == "supported")
    #expect(byFamily["note_unpin"]?["status"] as? String == "supported")
    #expect(byFamily["default_sort_setting"]?["status"] as? String == "supported")
    #expect(byFamily["folder_sort"]?["status"] as? String == "supported")
    #expect(byFamily["default_text_size_setting"]?["status"] as? String == "supported")
    #expect(byFamily["quick_note_resume_setting"]?["status"] as? String == "supported")
    #expect(byFamily["collapsible_section_view_state"]?["status"] as? String == "supported")
    #expect(byFamily["note_date_folder_count_metadata"]?["status"] as? String == "supported")
    #expect(byFamily["shared_activity_metadata"]?["status"] as? String == "supported")
    #expect(byFamily["siri_note_creation"]?["status"] as? String == "delegated")
    #expect(byFamily["notes_app_new_note_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["typing_suggestions_spelling_translation"]?["status"] as? String == "delegated")
    #expect(byFamily["clipboard_copy_paste"]?["status"] as? String == "delegated")
    #expect(byFamily["universal_clipboard"]?["status"] as? String == "delegated")
    #expect(byFamily["writing_tools"]?["status"] as? String == "delegated")
    #expect(byFamily["quick_note_keyboard_hot_corner_window"]?["status"] as? String == "delegated")
    #expect(byFamily["safari_quick_note_link"]?["status"] as? String == "delegated")
    #expect(byFamily["safari_quick_note_selection_highlight"]?["status"] as? String == "delegated")
    #expect(byFamily["sidebar_gallery_window_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["locked_note_authentication_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["per_note_zoom_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["show_note_count_ui_toggle"]?["status"] as? String == "delegated")
    #expect(byFamily["shortcuts_gestures_menu_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["widgets_access_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["recently_deleted_retention_sync"]?["status"] as? String == "delegated")
    #expect(byFamily["swipe_drag_lifecycle_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["semantic_quick_note_create"]?["status"] as? String == "supported")
    #expect(byFamily["locked_note_content_open_cli"]?["status"] as? String == "supported")
    #expect(byFamily["multi_note_lifecycle_batch"]?["status"] as? String == "supported")
    #expect(byFamily["quick_note_lock_unavailable"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("note_lifecycle_workflows_supported"))
    #expect(checkNames.contains("view_metadata_workflows_supported"))
    #expect(checkNames.contains("sort_pin_settings_workflows_supported"))
    #expect(checkNames.contains("ui_system_and_external_surfaces_delegated"))
    #expect(checkNames.contains("note_workflow_semantics_have_no_gated_records"))
    #expect(checkNames.contains("product_limitation_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private note body") == false)
    #expect(result.stdout?.contains("note-1") == false)
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
  }

  @Test func workflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "notes",
      "workflow",
      "audit",
      "--id",
      "note-1",
      "--folder",
      "Private Folder",
      "--title",
      "Secret title",
      "--body",
      "Private note body",
      "--query",
      "Launch",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected notes workflow audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--folder"))
      #expect(rejectedOptions.contains("--title"))
      #expect(rejectedOptions.contains("--body"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("Private Folder") == false)
      #expect(error.details.values.contains("Secret title") == false)
      #expect(error.details.values.contains("Private note body") == false)
      #expect(error.details.values.contains("Launch") == false)
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
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
