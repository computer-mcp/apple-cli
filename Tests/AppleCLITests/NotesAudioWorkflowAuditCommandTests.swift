import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes audio workflow audit command")
struct NotesAudioWorkflowAuditCommandTests {
  @Test func audioAuditAccountsForOfficialAudioWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments", "audio", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.attachments.audio.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 19)
    #expect(summary["supportedRecordCount"] as? Int == 8)
    #expect(summary["delegatedRecordCount"] as? Int == 10)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 1)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["audio_title_rename"]?["status"] as? String == "supported")
    #expect(byFamily["audio_save_attachment"]?["status"] as? String == "supported")
    #expect(byFamily["audio_delete_attachment"]?["status"] as? String == "supported")
    #expect(byFamily["audio_transcript_read"]?["status"] as? String == "supported")
    #expect(byFamily["audio_transcript_search"]?["status"] as? String == "supported")
    #expect(byFamily["audio_transcript_copy_to_note"]?["status"] as? String == "supported")
    #expect(byFamily["audio_transcript_copy_to_clipboard"]?["status"] as? String == "supported")
    #expect(byFamily["audio_summary_read"]?["status"] as? String == "supported")
    #expect(byFamily["audio_playback_play"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_playback_pause_resume"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_playback_skip"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_share_attachment"]?["status"] as? String == "delegated")
    #expect(byFamily["apple_intelligence_audio_summary_generation"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_record"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_record_pause_resume"]?["status"] as? String == "delegated")
    #expect(byFamily["live_note_edit_while_recording"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_append_recording"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_transcription_generation"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_transcript_edit"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("existing_audio_attachment_workflows_supported"))
    #expect(checkNames.contains("existing_transcript_workflows_supported"))
    #expect(checkNames.contains("playback_and_share_delegated"))
    #expect(checkNames.contains("recording_and_transcription_generation_delegated"))
    #expect(checkNames.contains("no_remaining_audio_data_edit_gated"))
    #expect(checkNames.contains("transcript_edit_non_capability_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("note-1") == false)
    #expect(result.stdout?.contains("audio-1") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.attachmentRenameDrafts.isEmpty)
    #expect(implementation.attachmentRemoveDrafts.isEmpty)
    #expect(implementation.updatedPatches.isEmpty)
  }

  @Test func audioAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments", "audio", "audit", "--id", "note-1", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected audio audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["options"] == "--id")
      #expect(error.details.values.contains("note-1") == false)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
      #expect(implementation.attachmentRenameDrafts.isEmpty)
      #expect(implementation.attachmentRemoveDrafts.isEmpty)
      #expect(implementation.updatedPatches.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
