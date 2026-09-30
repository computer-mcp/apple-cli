import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes accounts and folders workflow audit commands")
struct NotesAccountsFoldersWorkflowAuditCommandTests {
  @Test func accountsWorkflowAuditAccountsForOfficialWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "accounts", "workflow", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.accounts.workflow.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 13)
    #expect(summary["supportedRecordCount"] as? Int == 4)
    #expect(summary["delegatedRecordCount"] as? Int == 7)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 2)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["account_metadata_listing"]?["status"] as? String == "supported")
    #expect(byFamily["account_scoped_visibility"]?["status"] as? String == "supported")
    #expect(byFamily["on_my_mac_enable"]?["status"] as? String == "supported")
    #expect(byFamily["internet_account_add"]?["status"] as? String == "delegated")
    #expect(byFamily["account_type_selection_sign_in"]?["status"] as? String == "delegated")
    #expect(byFamily["safari_settings_sign_in_continuation"]?["status"] as? String == "delegated")
    #expect(byFamily["internet_account_notes_enable"]?["status"] as? String == "delegated")
    #expect(byFamily["internet_account_notes_disable"]?["status"] as? String == "delegated")
    #expect(byFamily["internet_account_remove"]?["status"] as? String == "delegated")
    #expect(byFamily["cross_device_setup_handoff"]?["status"] as? String == "delegated")
    #expect(byFamily["on_my_mac_disable"]?["status"] as? String == "supported")
    #expect((byFamily["on_my_mac_disable"]?["reason"] as? String)?.contains("no visible or trashed local notes") == true)
    #expect(byFamily["non_icloud_feature_parity"]?["status"] as? String == "rejected")
    #expect(byFamily["on_my_mac_cross_device_access"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("official_account_sections_accounted"))
    #expect(checkNames.contains("private_account_workflows_supported"))
    #expect(checkNames.contains("internet_account_workflows_delegated"))
    #expect(checkNames.contains("provider_limitations_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private Account") == false)
    #expect(result.stdout?.contains("private-provider") == false)
    #expect(result.stdout?.contains("private note") == false)
    expectNoNotesMutations(implementation)
  }

  @Test func accountsWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "accounts",
      "workflow",
      "audit",
      "--account",
      "Private Account",
      "--provider",
      "private-provider",
      "--folder",
      "Private Folder",
      "--name",
      "Private Name",
      "--query",
      "private query",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected accounts workflow audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--account"))
      #expect(rejectedOptions.contains("--provider"))
      #expect(rejectedOptions.contains("--folder"))
      #expect(rejectedOptions.contains("--name"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("Private Account") == false)
      #expect(error.details.values.contains("private-provider") == false)
      #expect(error.details.values.contains("Private Folder") == false)
      #expect(error.details.values.contains("Private Name") == false)
      #expect(error.details.values.contains("private query") == false)
      expectNoNotesMutations(implementation)
    }
  }

  @Test func foldersWorkflowAuditAccountsForOfficialWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "folders", "workflow", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.folders.workflow.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 26)
    #expect(summary["supportedRecordCount"] as? Int == 14)
    #expect(summary["delegatedRecordCount"] as? Int == 6)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 6)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["folder_hierarchy_listing"]?["status"] as? String == "supported")
    #expect(byFamily["system_folder_metadata_accounting"]?["status"] as? String == "supported")
    #expect(byFamily["concrete_folder_create"]?["status"] as? String == "supported")
    #expect(byFamily["subfolder_create"]?["status"] as? String == "supported")
    #expect(byFamily["folder_rename"]?["status"] as? String == "supported")
    #expect(byFamily["folder_parent_move"]?["status"] as? String == "supported")
    #expect(byFamily["note_move_to_folder"]?["status"] as? String == "supported")
    #expect(byFamily["note_copy_to_folder"]?["status"] as? String == "supported")
    #expect(byFamily["folder_delete_recently_deleted"]?["status"] as? String == "supported")
    #expect(byFamily["folder_sort_per_folder"]?["status"] as? String == "supported")
    #expect(byFamily["deleted_folder_hard_purge"]?["status"] as? String == "supported")
    #expect(byFamily["custom_sidebar_folder_order"]?["status"] as? String == "supported")
    #expect(byFamily["sidebar_show_hide_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["account_folder_disclosure_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["sidebar_resize_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["file_menu_folder_creation_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["folder_contextual_more_button_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["drag_and_drop_note_folder_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["shared_folder_move_permission_delta"]?["status"] as? String == "supported")
    #expect(byFamily["cross_account_format_attachment_preservation"]?["status"] as? String == "supported")
    #expect(byFamily["shared_folder_move_permission_delta"]?["command"] as? String == "folders move-impact --folder FOLDER --parent PARENT|--account ACCOUNT; folders move --folder FOLDER ...")
    #expect(byFamily["cross_account_format_attachment_preservation"]?["command"] as? String == "folders move-impact --folder FOLDER --account ACCOUNT; move/copy/folders move with readback")
    #expect(byFamily["auto_created_folder_mutations"]?["status"] as? String == "rejected")
    #expect(byFamily["subfolder_under_all_or_notes"]?["status"] as? String == "rejected")
    #expect(byFamily["move_notes_to_all_account_folder"]?["status"] as? String == "rejected")
    #expect(byFamily["recently_deleted_unavailable_for_unsupported_accounts"]?["status"] as? String == "rejected")
    #expect(byFamily["shared_note_cross_account_move"]?["status"] as? String == "rejected")
    #expect(byFamily["locked_note_unpermitted_account_move"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("official_folder_sections_accounted"))
    #expect(checkNames.contains("private_folder_workflows_supported"))
    #expect(checkNames.contains("folder_ui_workflows_delegated"))
    #expect(checkNames.contains("no_remaining_folder_semantics_gated"))
    #expect(checkNames.contains("folder_product_limitations_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private Folder") == false)
    #expect(result.stdout?.contains("Private Account") == false)
    expectNoNotesMutations(implementation)
  }

  @Test func foldersWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "folders",
      "workflow",
      "audit",
      "--account",
      "Private Account",
      "--folder",
      "Private Folder",
      "--parent",
      "Private Parent",
      "--name",
      "Private Name",
      "--query",
      "private query",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected folders workflow audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--account"))
      #expect(rejectedOptions.contains("--folder"))
      #expect(rejectedOptions.contains("--parent"))
      #expect(rejectedOptions.contains("--name"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("Private Account") == false)
      #expect(error.details.values.contains("Private Folder") == false)
      #expect(error.details.values.contains("Private Parent") == false)
      #expect(error.details.values.contains("Private Name") == false)
      #expect(error.details.values.contains("private query") == false)
      expectNoNotesMutations(implementation)
    }
  }
}

private func expectNoNotesMutations(_ implementation: TestNotesImplementation) {
  #expect(implementation.createdFolderDrafts.isEmpty)
  #expect(implementation.renamedFolderDrafts.isEmpty)
  #expect(implementation.movedFolderDrafts.isEmpty)
  #expect(implementation.deletedFolderDrafts.isEmpty)
  #expect(implementation.purgedFolderDrafts.isEmpty)
  #expect(implementation.createdDrafts.isEmpty)
  #expect(implementation.movedDrafts.isEmpty)
  #expect(implementation.copiedDrafts.isEmpty)
  #expect(implementation.smartFolderCreateDrafts.isEmpty)
  #expect(implementation.smartFolderUpdateDrafts.isEmpty)
  #expect(implementation.smartFolderBuiltInCriteriaCreateDrafts.isEmpty)
  #expect(implementation.smartFolderBuiltInCriteriaUpdateDrafts.isEmpty)
  #expect(implementation.smartFolderDuplicateDrafts.isEmpty)
  #expect(implementation.smartFolderCriteriaCopyDrafts.isEmpty)
  #expect(implementation.smartFolderCriteriaImportDrafts.isEmpty)
  #expect(implementation.smartFolderRenameDrafts.isEmpty)
  #expect(implementation.smartFolderDeleteDrafts.isEmpty)
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
