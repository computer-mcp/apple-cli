import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes links audit command")
struct NotesLinksAuditCommandTests {
  @Test func linksAuditAccountsForOfficialLinkWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "links", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.links.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 18)
    #expect(summary["supportedRecordCount"] as? Int == 11)
    #expect(summary["delegatedRecordCount"] as? Int == 7)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["link_metadata_list"]?["status"] as? String == "supported")
    #expect(byFamily["link_destination_resolve"]?["status"] as? String == "supported")
    #expect(byFamily["webpage_link_add"]?["status"] as? String == "supported")
    #expect(byFamily["note_link_add"]?["status"] as? String == "supported")
    #expect(byFamily["paragraph_note_link"]?["status"] as? String == "supported")
    #expect(byFamily["app_link_add"]?["status"] as? String == "supported")
    #expect(byFamily["link_edit"]?["status"] as? String == "supported")
    #expect(byFamily["link_remove"]?["status"] as? String == "supported")
    #expect(byFamily["backlink_read"]?["status"] as? String == "supported")
    #expect(byFamily["selected_text_to_link"]?["status"] as? String == "supported")
    #expect(byFamily["edit_menu_keyboard_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["smart_links_substitution"]?["status"] as? String == "delegated")
    #expect(byFamily["note_link_typeahead_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["active_app_link_capture_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["quick_note_link_thumbnail"]?["status"] as? String == "delegated")
    #expect(byFamily["link_color_appearance"]?["status"] as? String == "delegated")
    #expect(byFamily["legacy_os_visibility"]?["status"] as? String == "delegated")
    #expect(byFamily["custom_link_text_title_sync"]?["status"] as? String == "supported")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("web_note_app_links_supported"))
    #expect(checkNames.contains("link_readback_supported"))
    #expect(checkNames.contains("link_edit_remove_supported"))
    #expect(checkNames.contains("ui_and_system_surfaces_delegated"))
    #expect(checkNames.contains("no_remaining_link_semantics_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Selected link text") == false)
    #expect(result.stdout?.contains("note-1") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.linkAddDrafts.isEmpty)
    #expect(implementation.appLinkAddDrafts.isEmpty)
    #expect(implementation.noteLinkAddDrafts.isEmpty)
    #expect(implementation.paragraphLinkAddDrafts.isEmpty)
    #expect(implementation.linkUpdateDrafts.isEmpty)
    #expect(implementation.noteLinkUpdateDrafts.isEmpty)
    #expect(implementation.paragraphLinkUpdateDrafts.isEmpty)
    #expect(implementation.linkRemoveDrafts.isEmpty)
    #expect(implementation.noteLinkRemoveDrafts.isEmpty)
    #expect(implementation.paragraphLinkRemoveDrafts.isEmpty)
  }

  @Test func linksAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "links",
      "audit",
      "--id",
      "note-1",
      "--url",
      "https://example.com/private",
      "--target",
      "note-2",
      "--text",
      "Selected link text",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected links audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--url"))
      #expect(rejectedOptions.contains("--target"))
      #expect(rejectedOptions.contains("--text"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("note-2") == false)
      #expect(error.details.values.contains("https://example.com/private") == false)
      #expect(error.details.values.contains("Selected link text") == false)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
      #expect(implementation.linkAddDrafts.isEmpty)
      #expect(implementation.appLinkAddDrafts.isEmpty)
      #expect(implementation.noteLinkAddDrafts.isEmpty)
      #expect(implementation.paragraphLinkAddDrafts.isEmpty)
      #expect(implementation.linkUpdateDrafts.isEmpty)
      #expect(implementation.noteLinkUpdateDrafts.isEmpty)
      #expect(implementation.paragraphLinkUpdateDrafts.isEmpty)
      #expect(implementation.linkRemoveDrafts.isEmpty)
      #expect(implementation.noteLinkRemoveDrafts.isEmpty)
      #expect(implementation.paragraphLinkRemoveDrafts.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
