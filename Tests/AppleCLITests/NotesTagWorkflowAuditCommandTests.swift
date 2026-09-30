import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes tag workflow audit command")
struct NotesTagWorkflowAuditCommandTests {
  @Test func tagWorkflowAuditAccountsForOfficialTagWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "tags", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.tags.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 15)
    #expect(summary["supportedRecordCount"] as? Int == 12)
    #expect(summary["delegatedRecordCount"] as? Int == 3)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["tag_metadata_list"]?["status"] as? String == "supported")
    #expect(byFamily["single_tag_note_search"]?["status"] as? String == "supported")
    #expect(byFamily["note_tag_add"]?["status"] as? String == "supported")
    #expect(byFamily["note_tag_remove_membership"]?["status"] as? String == "supported")
    #expect(byFamily["tag_rename_single_non_merge"]?["status"] as? String == "supported")
    #expect(byFamily["tag_delete_single"]?["status"] as? String == "supported")
    #expect(byFamily["suggested_tag_picker"]?["status"] as? String == "delegated")
    #expect(byFamily["sidebar_click_tag_selection_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["shared_note_tag_adoption_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["multi_tag_all_any_search"]?["status"] as? String == "supported")
    #expect(byFamily["tag_exclusion_search"]?["status"] as? String == "supported")
    #expect(byFamily["rename_merge_existing_tag"]?["status"] as? String == "supported")
    #expect(byFamily["smart_folder_tag_update_readback"]?["status"] as? String == "supported")
    #expect(byFamily["multi_tag_delete"]?["status"] as? String == "supported")
    #expect(byFamily["convert_tag_to_plain_text"]?["status"] as? String == "supported")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("tag_read_search_supported"))
    #expect(checkNames.contains("tag_membership_mutations_supported"))
    #expect(checkNames.contains("tag_rename_delete_supported"))
    #expect(checkNames.contains("tag_ui_and_shared_surfaces_delegated"))
    #expect(checkNames.contains("tag_convert_to_text_supported"))
    #expect(checkNames.contains("no_remaining_tag_semantics_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private tag body") == false)
    #expect(result.stdout?.contains("note-1") == false)
    #expect(implementation.tagListQueries.isEmpty)
    #expect(implementation.tagReadQueries.isEmpty)
    #expect(implementation.tagMutations.isEmpty)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.smartFolderCreateDrafts.isEmpty)
    #expect(implementation.smartFolderUpdateDrafts.isEmpty)
  }

  @Test func tagWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "tags",
      "audit",
      "--tag",
      "PrivateTag",
      "--id",
      "note-1",
      "--name",
      "MergedTag",
      "--account",
      "Private Account",
      "--query",
      "Private tag body",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected tags audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--tag"))
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--name"))
      #expect(rejectedOptions.contains("--account"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("PrivateTag") == false)
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("MergedTag") == false)
      #expect(error.details.values.contains("Private Account") == false)
      #expect(error.details.values.contains("Private tag body") == false)
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
