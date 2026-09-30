import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes settings workflow audit command")
struct NotesSettingsWorkflowAuditCommandTests {
  @Test func settingsWorkflowAuditAccountsForOfficialSettingsWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.settings.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 28)
    #expect(summary["supportedRecordCount"] as? Int == 19)
    #expect(summary["delegatedRecordCount"] as? Int == 9)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["settings_family_accounting"]?["status"] as? String == "supported")
    #expect(byFamily["default_note_sort"]?["status"] as? String == "supported")
    #expect(byFamily["default_new_note_style"]?["status"] as? String == "supported")
    #expect(byFamily["default_account"]?["status"] as? String == "supported")
    #expect(byFamily["global_group_by_date"]?["status"] as? String == "supported")
    #expect(byFamily["date_header_type_preferences"]?["status"] as? String == "supported")
    #expect(byFamily["date_header_type_preferences"]?["command"] as? String == "settings group-by-date --scope default|query --enabled true|false")
    #expect(byFamily["folder_group_by_date"]?["status"] as? String == "supported")
    #expect(byFamily["quick_note_resume_last"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_auto_sort"]?["status"] as? String == "supported")
    #expect(byFamily["mention_notifications"]?["status"] as? String == "supported")
    #expect(byFamily["on_my_mac_enable"]?["status"] as? String == "supported")
    #expect(byFamily["on_my_mac_disable"]?["status"] as? String == "supported")
    #expect((byFamily["on_my_mac_disable"]?["reason"] as? String)?.contains("no visible or trashed notes") == true)
    #expect(byFamily["default_text_size"]?["status"] as? String == "supported")
    #expect(byFamily["note_list_gallery_layout"]?["status"] as? String == "delegated")
    #expect(byFamily["link_highlight_appearance_color"]?["status"] as? String == "delegated")
    #expect(byFamily["toolbar_customization"]?["status"] as? String == "delegated")
    #expect(byFamily["note_widget_view"]?["status"] as? String == "delegated")
    #expect(byFamily["folder_widget_view"]?["status"] as? String == "delegated")
    #expect(byFamily["widget_add_customize_surface"]?["status"] as? String == "delegated")
    #expect(byFamily["all_notes_notification_system_toggle"]?["status"] as? String == "delegated")
    #expect(byFamily["notification_delivery_style_settings"]?["status"] as? String == "delegated")
    #expect(byFamily["focus_notification_delivery"]?["status"] as? String == "delegated")
    #expect(byFamily["locked_notes_password_method_settings"]?["status"] as? String == "supported")
    #expect(byFamily["locked_notes_password_method_settings"]?["safetyGate"] as? String == "--allow-persistent-action+system_passcode_preflight+empty_protected_notes_preflight")
    #expect(byFamily["locked_notes_password_setup"]?["status"] as? String == "supported")
    #expect(byFamily["locked_notes_password_setup"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["locked_notes_change_password"]?["status"] as? String == "supported")
    #expect(byFamily["locked_notes_change_password"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["locked_notes_reset_password"]?["status"] as? String == "supported")
    #expect(byFamily["locked_notes_reset_password"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["locked_notes_touch_id_preference"]?["status"] as? String == "supported")
    #expect(byFamily["locked_notes_touch_id_preference"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["shared_note_hide_alerts"]?["status"] as? String == "supported")
    #expect(byFamily["shared_note_hide_alerts"]?["command"] as? String == "state hide-alerts --id NOTE_ID --enabled true|false")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("official_pages_accounted"))
    #expect(checkNames.contains("private_settings_workflows_supported"))
    #expect(checkNames.contains("system_ui_workflows_delegated"))
    #expect(checkNames.contains("no_remaining_settings_security_mutations_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private Account") == false)
    #expect(result.stdout?.contains("private@example.com") == false)
    #expect(implementation.tagListQueries.isEmpty)
    #expect(implementation.tagReadQueries.isEmpty)
    #expect(implementation.tagMutations.isEmpty)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.smartFolderCreateDrafts.isEmpty)
    #expect(implementation.smartFolderUpdateDrafts.isEmpty)
  }

  @Test func settingsWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "settings",
      "audit",
      "--account",
      "Private Account",
      "--id",
      "note-1",
      "--style",
      "gallery",
      "--color",
      "purple",
      "--enabled",
      "true",
      "--query",
      "private setting value",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected settings audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--account"))
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--style"))
      #expect(rejectedOptions.contains("--color"))
      #expect(rejectedOptions.contains("--enabled"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("Private Account") == false)
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("gallery") == false)
      #expect(error.details.values.contains("purple") == false)
      #expect(error.details.values.contains("private setting value") == false)
      #expect(implementation.tagListQueries.isEmpty)
      #expect(implementation.tagReadQueries.isEmpty)
      #expect(implementation.tagMutations.isEmpty)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
      #expect(implementation.smartFolderCreateDrafts.isEmpty)
      #expect(implementation.smartFolderUpdateDrafts.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
