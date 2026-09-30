import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes security workflow audit command")
struct NotesSecurityWorkflowAuditCommandTests {
  @Test func securityAuditAccountsForOfficialLockAndPasswordWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "security", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.state.security.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 19)
    #expect(summary["supportedRecordCount"] as? Int == 15)
    #expect(summary["delegatedRecordCount"] as? Int == 3)
    #expect(summary["gatedRecordCount"] as? Int == 1)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["lock_state_read"]?["status"] as? String == "supported")
    #expect(byFamily["lockability_status_read"]?["status"] as? String == "supported")
    #expect(byFamily["lockability_reason_readback"]?["status"] as? String == "supported")
    #expect(byFamily["icloud_upgrade_lockability_reason"]?["status"] as? String == "supported")
    #expect(byFamily["password_settings_family_accounting"]?["status"] as? String == "supported")
    #expect(byFamily["touch_id_authentication"]?["status"] as? String == "delegated")
    #expect(byFamily["login_password_authentication"]?["status"] as? String == "delegated")
    #expect(byFamily["notes_app_lock_session_timeout"]?["status"] as? String == "delegated")
    #expect(byFamily["set_initial_lock_password"]?["status"] as? String == "supported")
    #expect(byFamily["set_initial_lock_password"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["use_custom_password_method"]?["status"] as? String == "supported")
    #expect(byFamily["use_custom_password_method"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["use_login_password_method"]?["status"] as? String == "supported")
    #expect(byFamily["use_login_password_method"]?["safetyGate"] as? String == "--allow-persistent-action+system_passcode_preflight+empty_protected_notes_preflight")
    #expect(byFamily["touch_id_preference"]?["status"] as? String == "supported")
    #expect(byFamily["touch_id_preference"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["close_locked_notes"]?["status"] as? String == "supported")
    #expect(byFamily["close_locked_notes"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["lock_note"]?["status"] as? String == "supported")
    #expect(byFamily["lock_note"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["unlock_note"]?["status"] as? String == "supported")
    #expect(byFamily["unlock_note"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["remove_note_lock"]?["status"] as? String == "supported")
    #expect(byFamily["remove_note_lock"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["change_locked_notes_password"]?["status"] as? String == "supported")
    #expect(byFamily["change_locked_notes_password"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["reset_custom_password"]?["status"] as? String == "supported")
    #expect(byFamily["reset_custom_password"]?["safetyGate"] as? String == "--allow-persistent-action")
    #expect(byFamily["change_password_method"]?["status"] as? String == "gated")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("state_and_settings_reads_supported"))
    #expect(checkNames.contains("system_authentication_delegated"))
    #expect(checkNames.contains("password_store_mutations_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("note-1") == false)
    #expect(result.stdout?.contains("hunter2") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.updatedPatches.isEmpty)
    #expect(implementation.createdDrafts.isEmpty)
  }

  @Test func securityAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "security", "audit", "--id", "note-1", "--account", "iCloud", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected security audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--account"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("iCloud") == false)
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
