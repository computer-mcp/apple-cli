import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes Smart Folder workflow audit command")
struct NotesSmartFolderWorkflowAuditCommandTests {
  @Test func smartFolderWorkflowAuditAccountsForOfficialWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "smart-folders", "workflow", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.smart-folders.workflow.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 27)
    #expect(summary["supportedRecordCount"] as? Int == 18)
    #expect(summary["delegatedRecordCount"] as? Int == 4)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 5)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["smart_folder_metadata_listing"]?["status"] as? String == "supported")
    #expect(byFamily["smart_folder_matching_notes"]?["status"] as? String == "supported")
    #expect(byFamily["criteria_read_explain_reasoning_audit"]?["status"] as? String == "supported")
    #expect(byFamily["tag_criteria_create_update"]?["status"] as? String == "supported")
    #expect(byFamily["date_created_edited_criteria"]?["status"] as? String == "supported")
    #expect(byFamily["checklist_criteria"]?["status"] as? String == "supported")
    #expect(byFamily["mention_participant_criteria"]?["status"] as? String == "supported")
    #expect(byFamily["promoted_all_rule_combination"]?["status"] as? String == "supported")
    #expect(byFamily["multi_rule_any_scope"]?["status"] as? String == "supported")
    #expect(byFamily["untagged_notes_only_criteria"]?["status"] as? String == "supported")
    #expect(byFamily["promoted_filter_edit"]?["status"] as? String == "supported")
    #expect(byFamily["smart_folder_name_change"]?["status"] as? String == "supported")
    #expect(byFamily["delete_smart_folder_reference_only"]?["status"] as? String == "supported")
    #expect(byFamily["folder_to_smart_folder_conversion"]?["status"] as? String == "supported")
    #expect(byFamily["filter_menu_catalog_accounting"]?["status"] as? String == "supported")
    #expect(byFamily["file_menu_creation_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["contextual_more_button_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["sidebar_visibility_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["sidebar_drag_reorder"]?["status"] as? String == "delegated")
    #expect(byFamily["arbitrary_filter_add"]?["status"] as? String == "supported")
    #expect(byFamily["arbitrary_filter_update"]?["status"] as? String == "supported")
    #expect(byFamily["arbitrary_filter_remove"]?["status"] as? String == "supported")
    #expect(byFamily["arbitrary_filter_add"]?["command"] as? String == "smart-folders filters add --folder FOLDER --criteria KIND [--ordinal N]")
    #expect(byFamily["arbitrary_filter_update"]?["command"] as? String == "smart-folders filters update --folder FOLDER --ordinal N --criteria KIND")
    #expect(byFamily["arbitrary_filter_remove"]?["command"] as? String == "smart-folders filters remove --folder FOLDER --ordinal N")
    #expect(byFamily["smart_folder_locking"]?["status"] as? String == "rejected")
    #expect(byFamily["smart_folder_subfolder_nesting"]?["status"] as? String == "rejected")
    #expect(byFamily["smart_folder_sharing"]?["status"] as? String == "rejected")
    #expect(byFamily["ineligible_folder_conversion"]?["status"] as? String == "rejected")
    #expect(byFamily["empty_filter_smart_folder"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("official_page_sections_accounted"))
    #expect(checkNames.contains("private_smart_folder_workflows_supported"))
    #expect(checkNames.contains("ui_workflows_delegated"))
    #expect(checkNames.contains("no_remaining_workflow_semantics_gated"))
    #expect(checkNames.contains("product_limitations_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private Smart Folder") == false)
    #expect(result.stdout?.contains("private-user-id") == false)
    #expect(implementation.smartFolderCreateDrafts.isEmpty)
    #expect(implementation.smartFolderUpdateDrafts.isEmpty)
    #expect(implementation.smartFolderBuiltInCriteriaCreateDrafts.isEmpty)
    #expect(implementation.smartFolderBuiltInCriteriaUpdateDrafts.isEmpty)
    #expect(implementation.smartFolderDuplicateDrafts.isEmpty)
    #expect(implementation.smartFolderCriteriaCopyDrafts.isEmpty)
    #expect(implementation.smartFolderCriteriaImportDrafts.isEmpty)
    #expect(implementation.smartFolderRenameDrafts.isEmpty)
    #expect(implementation.smartFolderDeleteDrafts.isEmpty)
    #expect(implementation.smartFolderFolderConversionDrafts.isEmpty)
    #expect(implementation.smartFolderNoteLookups.isEmpty)
  }

  @Test func smartFolderFilterCatalogAuditAccountsForSupportedAndGatedCriteriaWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "smart-folders", "filters", "audit", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let summary = try #require(data["summary"] as? [String: Any])
    let records = try #require(data["records"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = verification["checks"] as? [[String: Any]] ?? []
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let byKind = Dictionary(
      uniqueKeysWithValues: records.compactMap { record -> (String, [String: Any])? in
        guard let kind = record["criteriaKind"] as? String else {
          return nil
        }
        return (kind, record)
      })
    let supportedFamilies = Set(summary["supportedFilterFamilies"] as? [String] ?? [])
    let gatedKinds = Set(summary["gatedCriteriaKinds"] as? [String] ?? [])

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.smart-folders.filters.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 61)
    #expect(summary["supportedRecordCount"] as? Int == 55)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 6)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byKind["tag-selected-single"]?["status"] as? String == "supported")
    #expect(byKind["untagged"]?["status"] as? String == "supported")
    #expect(byKind["created-between"]?["status"] as? String == "supported")
    #expect(byKind["edited-relative"]?["status"] as? String == "supported")
    #expect(byKind["attachment-scans"]?["status"] as? String == "supported")
    #expect(byKind["participants"]?["status"] as? String == "supported")
    #expect(byKind["mentions"]?["status"] as? String == "supported")
    #expect(byKind["tag-selected-multiple"]?["status"] as? String == "supported")
    #expect(byKind["tag-selected-multiple-any"]?["status"] as? String == "supported")
    #expect(byKind["tag-unsupported-operator-mode"]?["status"] as? String == "rejected")
    #expect(byKind["raw-value-or-object-bound-filter"]?["status"] as? String == "rejected")
    #expect(supportedFamilies.isSuperset(of: ["tags", "mentions", "checklists", "date_created", "date_edited"]))
    #expect(gatedKinds.isEmpty)
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("supported_criteria_match_writer_modules_catalog"))
    #expect(checkNames.contains("official_example_filter_families_accounted"))
    #expect(checkNames.contains("installed_filter_family_tail_accounted"))
    #expect(checkNames.contains("no_remaining_filter_catalog_gated"))
    #expect(checkNames.contains("tag_catalog_residuals_rejected"))
    #expect(checkNames.contains("object_identity_catalog_residuals_rejected"))
    #expect(checkNames.contains("os_filter_refresh_catalog_residual_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private Smart Folder") == false)
    #expect(result.stdout?.contains("private-user-id") == false)
    #expect(implementation.smartFolderCreateDrafts.isEmpty)
    #expect(implementation.smartFolderUpdateDrafts.isEmpty)
    #expect(implementation.smartFolderBuiltInCriteriaCreateDrafts.isEmpty)
    #expect(implementation.smartFolderBuiltInCriteriaUpdateDrafts.isEmpty)
    #expect(implementation.smartFolderDuplicateDrafts.isEmpty)
    #expect(implementation.smartFolderCriteriaCopyDrafts.isEmpty)
    #expect(implementation.smartFolderCriteriaImportDrafts.isEmpty)
    #expect(implementation.smartFolderRenameDrafts.isEmpty)
    #expect(implementation.smartFolderDeleteDrafts.isEmpty)
    #expect(implementation.smartFolderFolderConversionDrafts.isEmpty)
    #expect(implementation.smartFolderNoteLookups.isEmpty)
  }

  @Test func smartFolderFilterMutationRejectsUnpromotedCriteriaWithoutWriting() throws {
    let cases: [(arguments: [String], operation: String, appleCapability: String, reason: String)] = [
      (
        arguments:
        [
          "smart-folders", "filters", "add",
          "--folder", "Pinned",
          "--criteria", "untagged",
          "--json",
        ],
        operation: "notes.smart-folders.filters.add",
        appleCapability: "add_smart_folder_filter",
        reason: "criteria_kind_not_representable_as_private_filter_selection"
      ),
      (
        arguments:
        [
          "smart-folders", "filters", "update",
          "--folder", "Tagged",
          "--ordinal", "1",
          "--criteria", "unlocked",
          "--json",
        ],
        operation: "notes.smart-folders.filters.update",
        appleCapability: "change_smart_folder_filter",
        reason: "existing_criteria_not_promoted_filter_selection"
      ),
    ]

    for testCase in cases {
      let implementation = TestNotesImplementation()
      let command = NotesCommand(implementation: implementation)
      let options = try CLIOptionsFixture.parse(testCase.arguments)

      do {
        _ = try command.run(options: options)
        Issue.record("Expected Smart Folder filter mutation to reject unpromoted criteria.")
      } catch let error as CLIError {
        #expect(error.code == .unsupportedOperation)
        #expect(error.details["operation"] == testCase.operation)
        #expect(error.details["capability"] == "smart_folder_promoted_filter_mutation")
        #expect(error.details["apple_notes_capability"] == testCase.appleCapability)
        #expect(error.details["status"] == "gated")
        #expect(error.details["future_gate"] == "raw_or_object_bound_filter_reconstruction")
        #expect(error.details["required_implementation"] == "typed_private_notes_framework_filter_selection_reconstruction")
        #expect(error.details["required_verifier"] == "private_per_filter_delta_readback+matching_note_resolution")
        #expect(error.details["reason"] == testCase.reason)
        #expect(error.details.values.contains("Tagged") == false)
        #expect(error.details.values.contains("Pinned") == false)
        #expect(error.details.values.contains("unlocked") == false)
        #expect(implementation.smartFolderCreateDrafts.isEmpty)
        #expect(implementation.smartFolderUpdateDrafts.isEmpty)
        #expect(implementation.smartFolderBuiltInCriteriaCreateDrafts.isEmpty)
        #expect(implementation.smartFolderBuiltInCriteriaUpdateDrafts.isEmpty)
        #expect(implementation.smartFolderDuplicateDrafts.isEmpty)
        #expect(implementation.smartFolderCriteriaCopyDrafts.isEmpty)
        #expect(implementation.smartFolderCriteriaImportDrafts.isEmpty)
        #expect(implementation.smartFolderRenameDrafts.isEmpty)
        #expect(implementation.smartFolderDeleteDrafts.isEmpty)
        #expect(implementation.smartFolderFolderConversionDrafts.isEmpty)
        #expect(implementation.smartFolderNoteLookups.isEmpty)
      }
    }
  }

  @Test func smartFolderWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "smart-folders",
      "workflow",
      "audit",
      "--folder",
      "Private Smart Folder",
      "--account",
      "Private Account",
      "--name",
      "Private Name",
      "--criteria",
      "private-criteria",
      "--tag",
      "private-tag",
      "--participant-user-id",
      "private-user-id",
      "--query",
      "private query",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Smart Folder workflow audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--folder"))
      #expect(rejectedOptions.contains("--account"))
      #expect(rejectedOptions.contains("--name"))
      #expect(rejectedOptions.contains("--criteria"))
      #expect(rejectedOptions.contains("--tag"))
      #expect(rejectedOptions.contains("--participant-user-id"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("Private Smart Folder") == false)
      #expect(error.details.values.contains("Private Account") == false)
      #expect(error.details.values.contains("Private Name") == false)
      #expect(error.details.values.contains("private-criteria") == false)
      #expect(error.details.values.contains("private-tag") == false)
      #expect(error.details.values.contains("private-user-id") == false)
      #expect(error.details.values.contains("private query") == false)
      #expect(implementation.smartFolderCreateDrafts.isEmpty)
      #expect(implementation.smartFolderUpdateDrafts.isEmpty)
      #expect(implementation.smartFolderBuiltInCriteriaCreateDrafts.isEmpty)
      #expect(implementation.smartFolderBuiltInCriteriaUpdateDrafts.isEmpty)
      #expect(implementation.smartFolderDuplicateDrafts.isEmpty)
      #expect(implementation.smartFolderCriteriaCopyDrafts.isEmpty)
      #expect(implementation.smartFolderCriteriaImportDrafts.isEmpty)
      #expect(implementation.smartFolderRenameDrafts.isEmpty)
      #expect(implementation.smartFolderDeleteDrafts.isEmpty)
      #expect(implementation.smartFolderFolderConversionDrafts.isEmpty)
      #expect(implementation.smartFolderNoteLookups.isEmpty)
    }
  }

  @Test func smartFolderFilterCatalogAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "smart-folders",
      "filters",
      "audit",
      "--folder",
      "Private Smart Folder",
      "--account",
      "Private Account",
      "--criteria",
      "private-criteria",
      "--tag",
      "private-tag",
      "--participant-user-id",
      "private-user-id",
      "--query",
      "private query",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Smart Folder filter catalog audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--folder"))
      #expect(rejectedOptions.contains("--account"))
      #expect(rejectedOptions.contains("--criteria"))
      #expect(rejectedOptions.contains("--tag"))
      #expect(rejectedOptions.contains("--participant-user-id"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("Private Smart Folder") == false)
      #expect(error.details.values.contains("Private Account") == false)
      #expect(error.details.values.contains("private-criteria") == false)
      #expect(error.details.values.contains("private-tag") == false)
      #expect(error.details.values.contains("private-user-id") == false)
      #expect(error.details.values.contains("private query") == false)
      #expect(implementation.smartFolderCreateDrafts.isEmpty)
      #expect(implementation.smartFolderUpdateDrafts.isEmpty)
      #expect(implementation.smartFolderBuiltInCriteriaCreateDrafts.isEmpty)
      #expect(implementation.smartFolderBuiltInCriteriaUpdateDrafts.isEmpty)
      #expect(implementation.smartFolderDuplicateDrafts.isEmpty)
      #expect(implementation.smartFolderCriteriaCopyDrafts.isEmpty)
      #expect(implementation.smartFolderCriteriaImportDrafts.isEmpty)
      #expect(implementation.smartFolderRenameDrafts.isEmpty)
      #expect(implementation.smartFolderDeleteDrafts.isEmpty)
      #expect(implementation.smartFolderFolderConversionDrafts.isEmpty)
      #expect(implementation.smartFolderNoteLookups.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
