import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes attachment workflow audit command")
struct NotesAttachmentWorkflowAuditCommandTests {
  @Test func attachmentWorkflowAuditAccountsForOfficialMediaWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments", "workflow", "audit", "--json",
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
    #expect(data["operation"] as? String == "notes.attachments.workflow.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 43)
    #expect(summary["supportedRecordCount"] as? Int == 23)
    #expect(summary["delegatedRecordCount"] as? Int == 18)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 2)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["attachment_note_metadata"]?["status"] as? String == "supported")
    #expect(byFamily["attachment_collection_metadata"]?["status"] as? String == "supported")
    #expect(byFamily["attachment_family_accounting"]?["status"] as? String == "supported")
    #expect(byFamily["local_file_photo_video_add"]?["status"] as? String == "supported")
    #expect(byFamily["webpage_map_preview_add"]?["status"] as? String == "supported")
    #expect(byFamily["attachment_save_export"]?["status"] as? String == "supported")
    #expect(byFamily["pdf_scan_pdf_export"]?["status"] as? String == "supported")
    #expect(byFamily["attachment_rename"]?["status"] as? String == "supported")
    #expect(byFamily["attachment_name_search"]?["status"] as? String == "supported")
    #expect(byFamily["pdf_scan_text_search"]?["status"] as? String == "supported")
    #expect(byFamily["pdf_crop"]?["status"] as? String == "supported")
    #expect(byFamily["pdf_page_order_edit"]?["status"] as? String == "supported")
    #expect(byFamily["markup_model_inspect"]?["status"] as? String == "supported")
    #expect(byFamily["markup_model_apply"]?["status"] as? String == "supported")
    #expect(byFamily["scan_crop"]?["status"] as? String == "supported")
    #expect(byFamily["scan_rotate"]?["status"] as? String == "supported")
    #expect(byFamily["scan_filter"]?["status"] as? String == "supported")
    #expect(byFamily["scan_page_order_edit"]?["status"] as? String == "supported")
    #expect(byFamily["photo_library_picker"]?["status"] as? String == "delegated")
    #expect(byFamily["drag_drop_import"]?["status"] as? String == "delegated")
    #expect(byFamily["continuity_insert_photo_scan_sketch"]?["status"] as? String == "delegated")
    #expect(byFamily["emoji_symbols_picker"]?["status"] as? String == "delegated")
    #expect(byFamily["genmoji_creation"]?["status"] as? String == "delegated")
    #expect(byFamily["share_sheet_to_notes"]?["status"] as? String == "delegated")
    #expect(byFamily["attachments_browser_window_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["quick_look_preview"]?["status"] as? String == "delegated")
    #expect(byFamily["open_default_app"]?["status"] as? String == "delegated")
    #expect(byFamily["attachment_view_size_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["pdf_scan_page_navigation_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["share_attachment_external"]?["status"] as? String == "delegated")
    #expect(byFamily["markup_ui_tool_palette"]?["status"] as? String == "delegated")
    #expect(byFamily["markup_extension_enablement"]?["status"] as? String == "delegated")
    #expect(byFamily["markup_continuity_annotate"]?["status"] as? String == "delegated")
    #expect(byFamily["markup_continuity_annotate"]?["command"] as? String == "attachments markup annotate --id NOTE_ID --attachment ATTACHMENT_ID [--device DEVICE]")
    #expect(byFamily["scan_capture"]?["status"] as? String == "delegated")
    #expect(byFamily["pdf_content_edit"]?["status"] as? String == "rejected")
    #expect(byFamily["scanned_document_ocr_search"]?["status"] as? String == "supported")
    #expect(byFamily["image_drawing_handwriting_content_search"]?["status"] as? String == "supported")
    #expect((byFamily["scanned_document_ocr_search"]?["reason"] as? String)?.contains("attachments recognized-text generate") == true)
    #expect((byFamily["scanned_document_ocr_search"]?["reason"] as? String)?.contains("recognized text artifact export/generation and selected-attachment search indexing are supported separately") == true)
    #expect((byFamily["image_drawing_handwriting_content_search"]?["reason"] as? String)?.contains("attachments image objects") == true)
    #expect((byFamily["image_drawing_handwriting_content_search"]?["reason"] as? String)?.contains("attachments recognized-text generate") == true)
    #expect(byFamily["recognized_text_export"]?["status"] as? String == "supported")
    #expect((byFamily["recognized_text_export"]?["command"] as? String)?.contains("attachments recognized-text index --id NOTE_ID --attachment ATTACHMENT_ID") == true)
    #expect(byFamily["image_description_alt_text"]?["status"] as? String == "supported")
    #expect(byFamily["image_description_alt_text"]?["command"] as? String == "attachments image description get/set --id NOTE_ID --attachment ATTACHMENT_ID")
    #expect(byFamily["markup_semantic_element_creation"]?["status"] as? String == "delegated")
    #expect(byFamily["markup_style_and_color"]?["status"] as? String == "delegated")
    #expect(byFamily["markup_style_and_color"]?["command"] as? String == "attachments markup shape-style|border-color|fill-color|text-style")
    #expect(byFamily["image_crop_rotate"]?["status"] as? String == "supported")
    #expect(byFamily["image_crop_rotate"]?["command"] as? String == "attachments image crop|rotate --id NOTE_ID --attachment ATTACHMENT_ID")
    #expect(byFamily["exchange_attachment_unavailable"]?["status"] as? String == "rejected")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("attachment_read_and_add_supported"))
    #expect(checkNames.contains("attachment_export_rename_search_supported"))
    #expect(checkNames.contains("image_direct_media_transform_supported"))
    #expect(checkNames.contains("markup_model_scan_edit_supported"))
    #expect(checkNames.contains("ui_system_and_external_surfaces_delegated"))
    #expect(checkNames.contains("no_remaining_attachment_workflow_gated"))
    #expect(checkNames.contains("provider_limitation_rejected"))
    #expect(checkNames.contains("pdf_content_edit_non_capability_rejected"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private attachment text") == false)
    #expect(result.stdout?.contains("note-1") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.attachmentAddDrafts.isEmpty)
    #expect(implementation.webpageAttachmentAddDrafts.isEmpty)
    #expect(implementation.webpageAttachmentUpdateDrafts.isEmpty)
    #expect(implementation.attachmentRenameDrafts.isEmpty)
    #expect(implementation.attachmentRemoveDrafts.isEmpty)
    #expect(implementation.attachmentMarkupEditDrafts.isEmpty)
    #expect(implementation.markupInspectionLookups.isEmpty)
    #expect(implementation.audioTranscriptLookups.isEmpty)
  }

  @Test func attachmentWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments",
      "workflow",
      "audit",
      "--id",
      "note-1",
      "--attachment",
      "attachment-1",
      "--file",
      "/Users/private/Attachment.pdf",
      "--query",
      "Private attachment text",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected attachment workflow audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--attachment"))
      #expect(rejectedOptions.contains("--file"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("attachment-1") == false)
      #expect(error.details.values.contains("/Users/private/Attachment.pdf") == false)
      #expect(error.details.values.contains("Private attachment text") == false)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
      #expect(implementation.attachmentAddDrafts.isEmpty)
      #expect(implementation.webpageAttachmentAddDrafts.isEmpty)
      #expect(implementation.webpageAttachmentUpdateDrafts.isEmpty)
      #expect(implementation.attachmentRenameDrafts.isEmpty)
      #expect(implementation.attachmentRemoveDrafts.isEmpty)
      #expect(implementation.attachmentMarkupEditDrafts.isEmpty)
      #expect(implementation.markupInspectionLookups.isEmpty)
      #expect(implementation.audioTranscriptLookups.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
