import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes collaboration workflow audit command")
struct NotesCollaborationWorkflowAuditCommandTests {
  @Test func collaborationAuditAccountsForOfficialSharingWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "collaboration", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.state.collaboration.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 26)
    #expect(summary["supportedRecordCount"] as? Int == 20)
    #expect(summary["delegatedRecordCount"] as? Int == 6)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["share_state_read"]?["status"] as? String == "supported")
    #expect(byFamily["shared_folder_state_read"]?["status"] as? String == "supported")
    #expect(byFamily["editable_shared_note_mutation"]?["status"] as? String == "supported")
    #expect(byFamily["activity_metadata_read"]?["status"] as? String == "supported")
    #expect(byFamily["activity_metadata_artifact_export"]?["status"] as? String == "supported")
    #expect(byFamily["participant_access_metadata_read"]?["status"] as? String == "supported")
    #expect(byFamily["participant_access_metadata_read"]?["command"] as? String == "state participants --id NOTE_ID|--folder FOLDER")
    #expect(byFamily["participant_access_metadata_artifact_export"]?["status"] as? String == "supported")
    #expect(byFamily["participant_access_metadata_artifact_export"]?["command"] as? String == "state participants --id NOTE_ID|--folder FOLDER --output FILE.json")
    #expect(byFamily["send_copy_share_sheet"]?["status"] as? String == "delegated")
    #expect(byFamily["invitation_delivery_route"]?["status"] as? String == "delegated")
    #expect(byFamily["open_shared_link"]?["status"] as? String == "delegated")
    #expect(byFamily["realtime_presence_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["view_highlights_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["activity_participant_highlight_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["share_note_collaboration"]?["status"] as? String == "supported")
    #expect(byFamily["share_note_collaboration"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["share_folder_collaboration"]?["status"] as? String == "supported")
    #expect(byFamily["share_folder_collaboration"]?["command"] as? String == "state share-folder --folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write")
    #expect(byFamily["share_folder_collaboration"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["share_access_scope"]?["status"] as? String == "supported")
    #expect(byFamily["share_access_scope"]?["command"] as? String == "state share --id NOTE_ID|--folder FOLDER --scope invited-only|anyone-with-link")
    #expect(byFamily["share_access_scope"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["share_permission_scope"]?["status"] as? String == "supported")
    #expect(byFamily["share_permission_scope"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["allow_participants_to_invite"]?["status"] as? String == "supported")
    #expect(byFamily["allow_participants_to_invite"]?["command"] as? String == "state allow-invites --id NOTE_ID|--folder FOLDER --enabled true|false")
    #expect(byFamily["allow_participants_to_invite"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["stop_sharing"]?["status"] as? String == "supported")
    #expect(byFamily["stop_sharing"]?["appleCapability"] as? String == "stop_sharing_shared_note_or_folder")
    #expect(byFamily["stop_sharing"]?["command"] as? String == "state stop-sharing --id NOTE_ID|--folder FOLDER")
    #expect(byFamily["stop_sharing"]?["safetyGate"] as? String == "--allow-destructive-selection + --allow-persistent-action")
    #expect(byFamily["invite_more_people"]?["status"] as? String == "supported")
    #expect(byFamily["invite_more_people"]?["command"] as? String == "state invite --id NOTE_ID|--folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write")
    #expect(byFamily["invite_more_people"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["remove_participant"]?["status"] as? String == "supported")
    #expect(byFamily["remove_participant"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["copy_collaboration_link"]?["status"] as? String == "supported")
    #expect(byFamily["copy_collaboration_link"]?["command"] as? String == "state copy-link --id NOTE_ID|--folder FOLDER")
    #expect(byFamily["copy_collaboration_link"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["collaboration_link_artifact_export"]?["status"] as? String == "supported")
    #expect(byFamily["collaboration_link_artifact_export"]?["command"] as? String == "state copy-link --id NOTE_ID|--folder FOLDER --output FILE.txt")
    #expect(byFamily["collaboration_link_artifact_export"]?["safetyGate"] as? String == "--allow-artifact-action")
    #expect(byFamily["remove_self"]?["status"] as? String == "supported")
    #expect(byFamily["remove_self"]?["command"] as? String == "state remove-self --id NOTE_ID|--folder FOLDER")
    #expect(byFamily["remove_self"]?["safetyGate"] as? String == "--allow-destructive-selection + --allow-persistent-action")
    #expect(byFamily["hide_alerts_shared_note"]?["status"] as? String == "supported")
    #expect(byFamily["hide_alerts_shared_note"]?["command"] as? String == "state hide-alerts --id NOTE_ID --enabled true|false")
    #expect(byFamily["participant_mentions"]?["status"] as? String == "supported")
    #expect(byFamily["participant_mentions"]?["command"] as? String == "state mention --id NOTE_ID --target PARTICIPANT_ID [--text TEXT]")
    #expect(byFamily["participant_mentions"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("state_and_activity_reads_supported"))
    #expect(checkNames.contains("editable_shared_note_mutation_supported"))
    #expect(checkNames.contains("collaboration_link_copy_and_artifact_supported"))
    #expect(checkNames.contains("external_delivery_and_ui_delegated"))
    #expect(checkNames.contains("collaboration_mutations_supported"))
    #expect(checkNames.contains("collaboration_gated_families_empty"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("note-1") == false)
    #expect(result.stdout?.contains("ada@example.com") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.updatedPatches.isEmpty)
    #expect(implementation.createdDrafts.isEmpty)
  }

  @Test func collaborationAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "collaboration", "audit", "--id", "note-1", "--target", "ada@example.com", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected collaboration audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["options"] == "--id,--target")
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("ada@example.com") == false)
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
