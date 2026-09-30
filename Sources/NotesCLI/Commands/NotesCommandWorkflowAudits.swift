import Foundation
import Utility

extension NotesCommand {
  func runWorkflowAudits(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["notes", "guide", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try notesGuideAudit(options)
    case ["notes", "workflow", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try noteWorkflowAudit(options)
    case ["notes", "workflow", "shortcuts", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try noteWorkflowShortcutsAudit(options)    default:
      return nil
    }
  }

  private func notesGuideAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.guide.audit"
    let records = notesGuideAuditRecords()
    let summary = notesWorkflowAuditSummary(records)
    let verification = verifyNotesGuideAudit(records: records, summary: summary)
    let response = NotesWorkflowAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_pages: \(summary.supportedRecordCount), delegated_pages: \(summary.delegatedRecordCount), gated_pages: \(summary.gatedRecordCount), rejected_pages: \(summary.rejectedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesGuideAuditRecords() -> [NotesWorkflowAuditRecord] {
    struct GuideAuditItem {
      var family: String
      var guideSection: String
      var status: String
      var pageTitle: String
      var command: String
      var mechanism: String
      var requiredImplementation: String
      var requiredVerifier: String
      var privacyBoundary: String
      var reason: String
    }

    let items = [
      GuideAuditItem(
        family: "guide_welcome",
        guideSection: "Notes User Guide / Welcome",
        status: "supported",
        pageTitle: "Welcome",
        command: "guide audit",
        mechanism: "command_layer_official_toc_accounting",
        requiredImplementation: "static_current_apple_notes_toc_map",
        requiredVerifier: "notes_guide_toc_page_coverage",
        privacyBoundary: "no_backend_calls",
        reason: "The welcome page is the official Table of Contents source for this page-level coverage audit."
      ),
      GuideAuditItem(
        family: "guide_get_started",
        guideSection: "Notes User Guide / Get started",
        status: "supported",
        pageTitle: "Get started",
        command: "guide audit; accounts workflow audit; workflow audit; body format audit; attachments workflow audit; state collaboration audit; search audit",
        mechanism: "command_layer_overview_page_mapping",
        requiredImplementation: "existing_family_audits_and_semantic_commands",
        requiredVerifier: "overview_page_family_cross_reference",
        privacyBoundary: "no_note_or_account_values",
        reason: "The overview page maps to accepted family audits for iCloud setup, note creation/editing, formatting/content, collaboration, and search."
      ),
      GuideAuditItem(
        family: "guide_accounts",
        guideSection: "Notes User Guide / Add or remove notes accounts",
        status: "delegated",
        pageTitle: "Add or remove notes accounts",
        command: "accounts workflow audit; accounts add/remove/enable/disable; settings on-my-mac",
        mechanism: "delegated_macos_internet_accounts_plus_supported_local_account_enablement",
        requiredImplementation: "macos_internet_accounts_route_for_external_accounts",
        requiredVerifier: "delegated_account_lifecycle_accounting",
        privacyBoundary: "no_credentials_or_raw_account_values",
        reason: "External account lifecycle belongs to macOS Internet Accounts, while account reads and On My Mac enablement are covered separately."
      ),
      GuideAuditItem(
        family: "guide_create_edit",
        guideSection: "Create, edit, and format notes / Create and edit notes",
        status: "supported",
        pageTitle: "Create and edit notes",
        command: "workflow audit; create; update; append; copy; move",
        mechanism: "typed_private_notes_framework_note_lifecycle_commands",
        requiredImplementation: "private note read/write paths",
        requiredVerifier: "private_framework_note_lifecycle_readback",
        privacyBoundary: "explicit_inputs_only_no_body_dump",
        reason: "Accepted semantic note lifecycle commands cover the persisted create/edit/copy/move results."
      ),
      GuideAuditItem(
        family: "guide_quick_note",
        guideSection: "Create, edit, and format notes / Create a Quick Note",
        status: "supported",
        pageTitle: "Create a Quick Note",
        command: "quick-note create; workflow audit; workflow shortcuts audit; settings quick-note-resume",
        mechanism: "private note writer plus system-paper state readback",
        requiredImplementation: "typed ICNote creation plus ICNote.mark(asSystemPaperIfNeeded:)",
        requiredVerifier: "private_quick_note_folder_and_system_paper_state_readback",
        privacyBoundary: "quick_note_identity_without_body_dump",
        reason: "Semantic Quick Note creation is supported as a persisted system-paper note with private state readback; UI invocation remains delegated."
      ),
      GuideAuditItem(
        family: "guide_audio",
        guideSection: "Create, edit, and format notes / Record and transcribe audio",
        status: "supported",
        pageTitle: "Record and transcribe audio",
        command: "attachments audio audit; attachments audio rename/save/delete/transcript/search/copy-transcript; attachments audio record/transcribe/edit/edit-transcript",
        mechanism: "audio_workflow_audit_plus_supported_private_audio_attachment_commands",
        requiredImplementation: "existing private audio attachment/transcript commands plus delegated/rejected workflow accounting",
        requiredVerifier: "audio_workflow_audit_supported_delegated_rejected_accounting",
        privacyBoundary: "no_audio_bytes_or_transcript_text",
        reason: "Existing audio metadata/transcript reads and saved attachment mutations are supported; live recording, playback, sharing, transcript generation, and recording append stay delegated to Notes.app/system surfaces; transcript text edit is rejected as a non-capability in the current Apple Notes guide."
      ),
      GuideAuditItem(
        family: "guide_format_notes",
        guideSection: "Create, edit, and format notes / Format notes",
        status: "supported",
        pageTitle: "Format notes",
        command: "body format audit; body paragraph style/align/quote; body inline format/color/highlight/font",
        mechanism: "typed_private_notes_framework_rich_text_commands",
        requiredImplementation: "private attributed-body paragraph and inline-format writers",
        requiredVerifier: "private_body_structure_format_readback",
        privacyBoundary: "text_hashes_without_body_dump",
        reason: "Accepted rich text commands cover paragraph style, alignment, quote, emphasis, color, highlight, and font slices."
      ),
      GuideAuditItem(
        family: "guide_add_lists",
        guideSection: "Create, edit, and format notes / Add lists",
        status: "supported",
        pageTitle: "Add lists",
        command: "body format audit; body list ...; body checklist ...",
        mechanism: "typed_private_notes_framework_list_and_checklist_commands",
        requiredImplementation: "private list/checklist paragraph writers",
        requiredVerifier: "private_body_structure_list_readback",
        privacyBoundary: "paragraph_hashes_without_item_text",
        reason: "Accepted ordinary-list and checklist commands cover add, convert, state, sort, reorder, indent, and delete slices."
      ),
      GuideAuditItem(
        family: "guide_add_table",
        guideSection: "Create, edit, and format notes / Add a table",
        status: "supported",
        pageTitle: "Add a table",
        command: "body format audit; body table list/create/import/update/delete/convert-to-text/copy/rows/columns",
        mechanism: "typed_private_notes_framework_table_commands",
        requiredImplementation: "private ICTable read/write paths",
        requiredVerifier: "private_table_structure_and_cell_hash_readback",
        privacyBoundary: "table_shape_and_cell_hashes_without_cell_text",
        reason: "Accepted table commands cover table creation, external table import conversion, single-cell updates, row/column structure edits, copy, conversion, and deletion."
      ),
      GuideAuditItem(
        family: "guide_add_links",
        guideSection: "Add and manage links and attachments / Add links",
        status: "supported",
        pageTitle: "Add links",
        command: "links audit; links list/backlinks/resolve/add/update/remove variants",
        mechanism: "typed_private_notes_framework_link_commands",
        requiredImplementation: "private inline-link attachment readers and writers",
        requiredVerifier: "private_link_metadata_destination_readback",
        privacyBoundary: "hashed_internal_tokens_and_local_urls",
        reason: "Accepted link commands cover metadata, resolution, backlinks, and web/app/file/note/paragraph link mutations while selected-text conversion remains separately gated."
      ),
      GuideAuditItem(
        family: "guide_add_attachments",
        guideSection: "Add and manage links and attachments / Add photos, PDFs, and more",
        status: "supported",
        pageTitle: "Add photos, PDFs, and more",
        command: "attachments workflow audit; attachments list/search/audit/add/add-webpage/update-webpage/rename/remove/export",
        mechanism: "typed_private_notes_framework_attachment_commands",
        requiredImplementation: "private attachment metadata and writer paths",
        requiredVerifier: "attachment_metadata_and_artifact_hash_readback",
        privacyBoundary: "attachment_metadata_without_bytes_or_local_paths",
        reason: "Accepted attachment commands cover file/webpage/map add, metadata/search, title mutation, removal, and artifact export; Photos/UI routes stay delegated."
      ),
      GuideAuditItem(
        family: "guide_manage_pdfs_scans",
        guideSection: "Add and manage links and attachments / Manage PDFs and scanned documents",
        status: "supported",
        pageTitle: "Manage PDFs and scanned documents",
        command: "attachments workflow audit; attachments export-pdf; attachments rename; attachments pdf inspect/search/crop/page rotate/page move/page delete; attachments scan inspect/crop/rotate/filter/page move/delete; attachments scan capture; attachments pdf edit",
        mechanism: "supported_pdf_export_search_inspect_crop_scan_edit_plus_delegated_or_rejected_boundaries",
        requiredImplementation: "typed_private_notes_framework_scan_pdf_operation_writers plus delegated/rejected workflow accounting",
        requiredVerifier: "private_attachment_media_operation_delta_readback+official_product_boundary_accounting",
        privacyBoundary: "pdf_hashes_without_pdf_text_or_image_bytes",
        reason: "PDF artifact export, PDF/scan private metadata inspection, embedded text search, attachment rename, selected PDF crop/page rotation/move/delete, and selected scanned-document crop/rotation/filter/page move/delete are supported. Scan capture is delegated to Continuity Camera, and arbitrary PDF content editing is rejected because Apple's Notes guide exposes PDF/scan crop, filter, rotate, rename, and Markup workflows rather than a direct PDF content editor."
      ),
      GuideAuditItem(
        family: "guide_markup_attachments",
        guideSection: "Add and manage links and attachments / Mark up attachments",
        status: "supported",
        pageTitle: "Mark up attachments",
        command: "attachments workflow audit; attachments markup inspect/edit/add-shape/add-text/add-signature/highlight/sketch/draw/shape-style/border-color/fill-color/text-style/annotate; attachments image crop/rotate/description get/set",
        mechanism: "supported_markup_model_apply_image_description_transform_plus_delegated_markup_tool_boundaries",
        requiredImplementation: "typed_private_notes_framework_markup_model_image_description_and_transform_paths",
        requiredVerifier: "private_markup_model_attachment_and_image_transform_readback",
        privacyBoundary: "markup_model_hashes_without_attachment_bytes",
        reason: "Markup model inspection/export/apply, image-description alt text, and direct image crop/rotate are supported. Interactive Markup element/style tool surfaces and nearby-device annotate are explicitly delegated in the attachment workflow audit rather than remaining guide-level gates."
      ),
      GuideAuditItem(
        family: "guide_solve_math",
        guideSection: "Solve math in Notes / Solve math",
        status: "supported",
        pageTitle: "Solve math",
        command: "body math audit; body math list/insert/update; smart-folders create-criteria --criteria math",
        mechanism: "typed_private_notes_framework_math_result_commands",
        requiredImplementation: "private calculate-recognition and math-result attachment paths",
        requiredVerifier: "private_math_result_expression_hash_readback",
        privacyBoundary: "expression_and_result_hashes_without_text",
        reason: "Accepted math commands cover result listing, insertion, update, Math Notes folder note operations, and Smart Folder math criteria."
      ),
      GuideAuditItem(
        family: "guide_open_math_calculator",
        guideSection: "Solve math in Notes / Open Math Notes from Calculator",
        status: "delegated",
        pageTitle: "Open Math Notes from Calculator",
        command: "body math audit",
        mechanism: "delegated_calculator_app_handoff",
        requiredImplementation: "Calculator app handoff route",
        requiredVerifier: "delegated_app_handoff_accounting",
        privacyBoundary: "no_backend_calls",
        reason: "Opening Math Notes from Calculator is an app handoff/UI route; persisted math results are covered separately."
      ),
      GuideAuditItem(
        family: "guide_view_notes",
        guideSection: "View your notes and attachments / View your notes",
        status: "supported",
        pageTitle: "View your notes",
        command: "workflow audit; list; read; folders list; state read",
        mechanism: "typed_private_notes_framework_read_commands_plus_delegated_view_ui",
        requiredImplementation: "private visible-note and state readers",
        requiredVerifier: "private_note_summary_and_state_readback",
        privacyBoundary: "bounded_reads_and_no_unrequested_body_dump",
        reason: "Accepted read/list/state commands cover data reads, while gallery/list/window view controls remain delegated UI."
      ),
      GuideAuditItem(
        family: "guide_view_attachments",
        guideSection: "View your notes and attachments / View attachments",
        status: "supported",
        pageTitle: "View attachments",
        command: "attachments workflow audit; attachments list/search/audit",
        mechanism: "typed_private_notes_framework_attachment_metadata_commands",
        requiredImplementation: "private attachment metadata readers",
        requiredVerifier: "attachment_family_count_and_metadata_readback",
        privacyBoundary: "metadata_only_no_attachment_bytes",
        reason: "Attachment Browser UI is delegated, but attachment family metadata, listing, and search are accepted."
      ),
      GuideAuditItem(
        family: "guide_search",
        guideSection: "View your notes and attachments / Search your notes",
        status: "supported",
        pageTitle: "Search your notes",
        command: "search audit; search; search natural-language; search locked-title; search attachment-content; attachments search; attachments pdf search; attachments audio search; attachments scan/image/drawing search; attachments recognized-text generate/index; attachments image objects",
        mechanism: "supported_text_natural_language_pdf_audio_metadata_locked_title_attachment_content_search_plus_recognized_text_artifact_generation_indexing_and_image_classification_summary_readback",
        requiredImplementation: "private_search_index_or_visual_search_reader_plus_private_attachment_media_ocr_artifact_path_plus_corespotlight_reindexer_plus_image_classification_summary_reader",
        requiredVerifier: "privacy_preserving_search_result_readback",
        privacyBoundary: "query_hashes_without_raw_query_or_content",
        reason: "Text, natural-language, locked-title-only, PDF, audio, metadata, composite attachment-content, scan/image searchable text, drawing, handwriting search, existing recognized-text export, explicit recognized-text artifact generation, selected-attachment recognized-text search indexing, and image classification summary readback are covered through semantic commands. The search-family audit now has no gated guide search records; attachment-specific UI/system surfaces are delegated there."
      ),
      GuideAuditItem(
        family: "guide_widgets",
        guideSection: "View your notes and attachments / Use Notes widgets to view notes",
        status: "delegated",
        pageTitle: "Use Notes widgets to view notes",
        command: "settings audit; settings widgets",
        mechanism: "delegated_widgetkit_system_surface",
        requiredImplementation: "macOS widget management route",
        requiredVerifier: "delegated_widget_accounting",
        privacyBoundary: "no_backend_calls",
        reason: "Widget placement and customization are system/user-facing surfaces, not Notes data model writes."
      ),
      GuideAuditItem(
        family: "guide_appearance",
        guideSection: "View your notes and attachments / Customize how notes appear",
        status: "delegated",
        pageTitle: "Customize how notes appear",
        command: "settings audit; settings view-layout; settings link-highlight-color; settings text-size",
        mechanism: "mixed_supported_text_size_setting_and_delegated_app_appearance_ui",
        requiredImplementation: "Notes.app appearance/window UI route",
        requiredVerifier: "delegated_appearance_accounting",
        privacyBoundary: "setting_hashes_without_raw_values",
        reason: "Default text size is supported, while view layout, link highlight color, toolbar, and window appearance controls are delegated."
      ),
      GuideAuditItem(
        family: "guide_lock_notes",
        guideSection: "Lock your notes / Lock your notes",
        status: "gated",
        pageTitle: "Lock your notes",
        command: "state security audit; state read/audit; state lock/unlock/remove-lock/export-locked-content",
        mechanism: "supported_lock_state_reads_lock_remove_mutations_and_session_unlocked_export_plus_gated_secret_sensitive_mutations",
        requiredImplementation: "typed_private_notes_framework_lock_unlock_remove_export_paths+password_setup_boundary",
        requiredVerifier: "lock_state_delta_and_session_unlocked_artifact_readback_without_secret_exposure",
        privacyBoundary: "no_passwords_or_locked_content",
        reason: "Lock state and lockability are readable, lock/unlock/remove-lock are supported for eligible notes through private framework readback, custom password setup/change/reset is supported through the account passphrase manager, initial login-password method selection is supported for accounts with no existing password-protected notes, and locked-content export is supported for session-unlocked notes or with an explicit passphrase source in the same command; password-method changes for existing locked notes remain gated."
      ),
      GuideAuditItem(
        family: "guide_change_password",
        guideSection: "Lock your notes / Change your password for locked notes",
        status: "gated",
        pageTitle: "Change your password for locked notes",
        command: "state security audit; settings password/locked-notes/change-password/reset-password/touch-id; state change-password",
        mechanism: "supported_custom_password_change_reset_plus_gated_method_switch_boundary",
        requiredImplementation: "account_passphrase_manager_change_reset_route_plus_password_method_switch_route",
        requiredVerifier: "password_change_secret_source_readback_plus_method_state_readback_without_secret_capture",
        privacyBoundary: "no_password_or_auth_material",
        reason: "Custom locked-notes password change and reset are supported through private account passphrase manager selectors with secret-source boundaries, and initial login-password method selection is supported for accounts with no existing password-protected notes; password-method switching for existing locked notes remains gated until a safe migration/rekey route and verifier readback are proven."
      ),
      GuideAuditItem(
        family: "guide_accounts_folders",
        guideSection: "Organize your notes / About accounts and folders",
        status: "supported",
        pageTitle: "About accounts and folders",
        command: "folders workflow audit; accounts workflow audit; accounts list; folders list",
        mechanism: "typed_private_notes_framework_account_folder_readers",
        requiredImplementation: "private account and folder metadata readers",
        requiredVerifier: "account_folder_metadata_readback",
        privacyBoundary: "account_folder_metadata_without_note_bodies",
        reason: "Account and folder metadata reads plus official workflow accounting are accepted."
      ),
      GuideAuditItem(
        family: "guide_add_remove_folders",
        guideSection: "Organize your notes / Add and remove folders",
        status: "supported",
        pageTitle: "Add and remove folders",
        command: "folders workflow audit; folders create/rename/move/delete/purge",
        mechanism: "typed_private_notes_framework_folder_writers",
        requiredImplementation: "private folder lifecycle paths",
        requiredVerifier: "folder_mutation_readback",
        privacyBoundary: "folder_metadata_without_note_bodies",
        reason: "Accepted folder lifecycle commands cover create, rename, move, delete, and hard purge for eligible folders."
      ),
      GuideAuditItem(
        family: "guide_sort_pin",
        guideSection: "Organize your notes / Sort and pin notes",
        status: "supported",
        pageTitle: "Sort and pin notes",
        command: "workflow audit; folders sort; settings sort; pin; unpin",
        mechanism: "typed_private_notes_framework_sort_and_pin_commands",
        requiredImplementation: "private sort preference/folder sort/pin writers",
        requiredVerifier: "sort_and_pin_state_readback",
        privacyBoundary: "state_and_setting_hashes_without_note_body",
        reason: "Pin/unpin and default/folder sort commands are accepted with private readback."
      ),
      GuideAuditItem(
        family: "guide_tags",
        guideSection: "Organize your notes / Use tags",
        status: "supported",
        pageTitle: "Use tags",
        command: "tags audit; tags list/search/add/remove/convert-to-text/rename/delete",
        mechanism: "typed_private_notes_framework_tag_commands",
        requiredImplementation: "private hashtag readers and writers",
        requiredVerifier: "tag_membership_body_hash_and_cascade_readback",
        privacyBoundary: "tag_metadata_without_note_bodies",
        reason: "Accepted tag commands cover tag metadata, single-tag search, membership, Convert to Text body hash preservation, non-merge rename, and delete with Smart Folder cascade checks."
      ),
      GuideAuditItem(
        family: "guide_smart_folders",
        guideSection: "Organize your notes / Use Smart Folders",
        status: "supported",
        pageTitle: "Use Smart Folders",
        command: "smart-folders workflow audit; smart-folders filters audit; smart-folders list/criteria/explain/reasoning/audit/notes/create/update/create-criteria/update-criteria/filters add/update/remove/duplicate/copy-criteria/export-criteria/import-criteria/rename/delete/convert-folder",
        mechanism: "supported_promoted_smart_folder_workflows_plus_rejected_private_catalog_residuals",
        requiredImplementation: "typed_private_notes_framework_smart_folder_workflow_and_filter_catalog_accounting",
        requiredVerifier: "private_query_filter_readback_and_rejected_catalog_residual_accounting",
        privacyBoundary: "criteria_hashes_without_raw_values",
        reason: "Official Smart Folder create, convert, edit, delete, filter catalog, and promoted per-filter mutation workflows are accounted for with no remaining guide-level gate; raw private value/object shapes are rejected as non-guide catalog residuals while unreconstructable runtime filters still refuse mutation."
      ),
      GuideAuditItem(
        family: "guide_delete_note",
        guideSection: "Organize your notes / Delete a note",
        status: "supported",
        pageTitle: "Delete a note",
        command: "workflow audit; delete; restore; restore-all; purge; empty-trash",
        mechanism: "typed_private_notes_framework_delete_restore_purge_commands",
        requiredImplementation: "private delete/recently-deleted lifecycle paths",
        requiredVerifier: "visibility_restore_and_purge_readback",
        privacyBoundary: "note_identity_hashes_without_body_dump",
        reason: "Accepted commands cover delete, restore, restore-all, purge, empty trash, and retention accounting."
      ),
      GuideAuditItem(
        family: "guide_share",
        guideSection: "Share and collaborate on notes / Share your notes and folders",
        status: "supported",
        pageTitle: "Share your notes and folders",
        command: "state collaboration audit; state share/invite/set-permission/folder-permission/allow-invites",
        mechanism: "supported_private_notes_collaboration_share_mutations_plus_delegated_delivery",
        requiredImplementation: "typed private Notes collaboration share writer plus CloudKit participant lookup/add",
        requiredVerifier: "collaboration_state_delta_readback_without_handles",
        privacyBoundary: "no_share_links_or_participant_handles",
        reason: "Sharing state reads, activity metadata, starting note/folder collaboration, adding one participant, access-scope changes, existing participant permission changes, invite-policy changes, and self-removal are supported with private readback; invitation delivery destination selection remains delegated."
      ),
      GuideAuditItem(
        family: "guide_manage_shared",
        guideSection: "Share and collaborate on notes / Manage shared notes and folders",
        status: "supported",
        pageTitle: "Manage shared notes and folders",
        command: "state collaboration audit; state invite/stop-sharing/remove-participant/set-permission/allow-invites/remove-self",
        mechanism: "supported_private_notes_collaboration_management_mutations_plus_delegated_ui",
        requiredImplementation: "typed private Notes collaboration participant writer and existing share management writers",
        requiredVerifier: "shared_state_participant_delta_readback",
        privacyBoundary: "participant_hashes_without_handles",
        reason: "Shared state/activity reads, participant invite/add, existing shared note/folder participant permission changes, existing shared-note participant removal, shared note/folder stop-sharing, invite-policy changes, and self-removal are supported with hash-only participant/share readback."
      ),
      GuideAuditItem(
        family: "guide_collaborate",
        guideSection: "Share and collaborate on notes / Collaborate with shared notes and folders",
        status: "supported",
        pageTitle: "Collaborate with shared notes and folders",
        command: "state collaboration audit; state activity; state mention; state hide-alerts",
        mechanism: "supported_activity_metadata_mentions_hide_alerts_plus_delegated_realtime_ui",
        requiredImplementation: "typed_private_notes_framework_collaboration_activity_mention_and_notification_settings_paths",
        requiredVerifier: "activity_and_mention_readback_without_content_leakage",
        privacyBoundary: "activity_hashes_without_activity_text",
        reason: "Privacy-safe activity metadata, editable shared-note mutation, starting collaboration, access-scope changes, existing shared note/folder participant permission changes, existing shared-note participant removal, shared note/folder stop-sharing, invite-policy changes, self-removal, participant invite/add, participant mention insertion, and per-shared-note Hide Alerts are supported. Realtime presence and highlight UI remain delegated."
      ),
      GuideAuditItem(
        family: "guide_import_export_print",
        guideSection: "Notes User Guide / Import, export, and print notes",
        status: "supported",
        pageTitle: "Import, export, and print notes",
        command: "import audit; import text/markdown/rtf/rtfd/html/enex/folder; export audit; export pdf/markdown/html/rtf/rtfd; open-in-pages; print",
        mechanism: "typed_private_notes_framework_import_export_paths_plus_delegated_print_pages",
        requiredImplementation: "private import/export/readback paths and system dispatch gates",
        requiredVerifier: "artifact_hash_import_export_readback",
        privacyBoundary: "artifact_hashes_without_note_body_dump",
        reason: "Official import formats, PDF/Markdown export, printing, and Pages handoff are covered by accepted commands with artifact/external-dispatch gates."
      ),
      GuideAuditItem(
        family: "guide_notifications",
        guideSection: "Notes User Guide / Manage notifications",
        status: "delegated",
        pageTitle: "Manage notifications",
        command: "settings audit; settings notifications; settings mention-notifications; state collaboration audit",
        mechanism: "supported_mention_notification_setting_plus_delegated_system_notification_surfaces",
        requiredImplementation: "macOS notification settings and shared-note notification routes",
        requiredVerifier: "delegated_notification_accounting",
        privacyBoundary: "no_backend_calls_for_system_notification_ui",
        reason: "Mention-notification preference and per-shared-note Hide Alerts are supported, while system notification style and Focus delivery are delegated."
      ),
      GuideAuditItem(
        family: "guide_settings",
        guideSection: "Notes User Guide / Change Notes settings",
        status: "supported",
        pageTitle: "Change Notes settings",
        command: "settings audit; settings read; settings sort/default-account/group-by-date/quick-note-resume/mention-notifications/text-size/new-note-style/checklist-sort/on-my-mac",
        mechanism: "typed_private_notes_framework_settings_readers_and_writers",
        requiredImplementation: "private settings and local-account preference paths",
        requiredVerifier: "settings_hash_bool_readback",
        privacyBoundary: "hashes_and_booleans_without_raw_secret_or_account_values",
        reason: "Accepted settings commands cover the current non-secret preference set and On My Mac enablement; password/security and appearance/system surfaces remain separately gated/delegated."
      ),
      GuideAuditItem(
        family: "guide_keyboard_shortcuts",
        guideSection: "Notes User Guide / Keyboard shortcuts and gestures",
        status: "supported",
        pageTitle: "Keyboard shortcuts and gestures",
        command: "workflow shortcuts audit",
        mechanism: "command_layer_keyboard_shortcut_accounting",
        requiredImplementation: "official_shortcut_to_semantic_command_mapping",
        requiredVerifier: "notes_workflow_shortcuts_audit_v1",
        privacyBoundary: "no_backend_calls_or_ui_state_reads",
        reason: "The dedicated shortcut audit accounts for supported semantic equivalents, delegated UI/navigation surfaces, and gated shortcut semantics."
      ),
      GuideAuditItem(
        family: "guide_copyright",
        guideSection: "Notes User Guide / Copyright and trademarks",
        status: "rejected",
        pageTitle: "Copyright and trademarks",
        command: "none",
        mechanism: "non_capability_reference_page",
        requiredImplementation: "none",
        requiredVerifier: "not_a_notes_cli_capability",
        privacyBoundary: "no_backend_calls",
        reason: "The copyright/trademark page is part of the guide TOC but is not a Notes.app capability candidate."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesWorkflowAuditRecord(
        ordinal: index + 1,
        workflowFamily: item.family,
        guideSection: item.guideSection,
        status: item.status,
        appleCapability: item.pageTitle,
        command: item.command,
        implementationMechanism: item.mechanism,
        requiredImplementation: item.requiredImplementation,
        requiredVerifier: item.requiredVerifier,
        safetyGate: "read-only/no-implementation",
        backendCalls: "none",
        privacyBoundary: item.privacyBoundary,
        reason: item.reason
      )
    }
  }

  private func verifyNotesGuideAudit(
    records: [NotesWorkflowAuditRecord],
    summary: NotesWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let rejected = Set(summary.rejectedWorkflowFamilies)
    let allFamilies = Set(records.map(\.workflowFamily))
    let checks = [
      verificationBoolCheck(
        name: "current_toc_page_count_accounted",
        expected: true,
        actual: records.count == 36
      ),
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "official_toc_pages_accounted",
        expected: true,
        actual: allFamilies.isSuperset(
          of: [
            "guide_welcome", "guide_get_started", "guide_accounts", "guide_create_edit",
            "guide_quick_note", "guide_audio", "guide_format_notes", "guide_add_lists",
            "guide_add_table", "guide_add_links", "guide_add_attachments",
            "guide_manage_pdfs_scans", "guide_markup_attachments", "guide_solve_math",
            "guide_open_math_calculator", "guide_view_notes", "guide_view_attachments",
            "guide_search", "guide_widgets", "guide_appearance", "guide_lock_notes",
            "guide_change_password", "guide_accounts_folders", "guide_add_remove_folders",
            "guide_sort_pin", "guide_tags", "guide_smart_folders", "guide_delete_note",
            "guide_share", "guide_manage_shared", "guide_collaborate",
            "guide_import_export_print", "guide_notifications", "guide_settings",
            "guide_keyboard_shortcuts", "guide_copyright",
          ]
        )
      ),
      verificationBoolCheck(
        name: "implemented_family_pages_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "guide_create_edit", "guide_format_notes", "guide_add_lists", "guide_add_table",
            "guide_add_links", "guide_add_attachments", "guide_manage_pdfs_scans",
            "guide_markup_attachments", "guide_solve_math", "guide_view_notes",
            "guide_view_attachments", "guide_search", "guide_add_remove_folders",
            "guide_sort_pin", "guide_tags", "guide_smart_folders", "guide_delete_note",
            "guide_share", "guide_manage_shared", "guide_collaborate", "guide_import_export_print", "guide_settings",
            "guide_keyboard_shortcuts", "guide_quick_note", "guide_audio",
          ]
        )
      ),
      verificationBoolCheck(
        name: "system_ui_pages_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "guide_accounts", "guide_open_math_calculator", "guide_widgets",
            "guide_appearance", "guide_notifications",
          ]
        )
      ),
      verificationBoolCheck(
        name: "remaining_security_pages_gated",
        expected: true,
        actual: gated == Set(["guide_lock_notes", "guide_change_password"])
      ),
      verificationBoolCheck(
        name: "non_capability_toc_page_rejected",
        expected: true,
        actual: rejected.contains("guide_copyright")
      ),
      verificationBoolCheck(
        name: "audit_has_no_selector_input",
        expected: false,
        actual: summary.auditRequiresSelector
      ),
      verificationBoolCheck(
        name: "backend_calls_none",
        expected: true,
        actual: summary.backendCalls == "none" && records.allSatisfy { $0.backendCalls == "none" }
      ),
      verificationBoolCheck(
        name: "privacy_boundaries_recorded",
        expected: true,
        actual: records.allSatisfy { !$0.privacyBoundary.isEmpty }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.guide.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "official_toc_page_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.guide.audit"),
      checks: checks
    )
  }

  private func noteWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.workflow.audit"
    let records = notesWorkflowAuditRecords()
    let summary = notesWorkflowAuditSummary(records)
    let verification = verifyNotesWorkflowAudit(records: records, summary: summary)
    let response = NotesWorkflowAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_records: \(summary.supportedRecordCount), delegated_records: \(summary.delegatedRecordCount), gated_records: \(summary.gatedRecordCount), rejected_records: \(summary.rejectedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesWorkflowAuditRecords() -> [NotesWorkflowAuditRecord] {
    struct NotesWorkflowAuditItem {
      var family: String
      var guideSection: String
      var status: String
      var appleCapability: String
      var command: String
      var mechanism: String
      var requiredImplementation: String
      var requiredVerifier: String
      var safetyGate: String?
      var privacyBoundary: String
      var reason: String
    }

    let items = [
      NotesWorkflowAuditItem(
        family: "visible_note_list",
        guideSection: "View your notes",
        status: "supported",
        appleCapability: "view_notes_from_all_accounts_or_one_folder",
        command: "list [--account ACCOUNT] [--folder FOLDER]",
        mechanism: "typed_private_notes_framework_visible_note_reader",
        requiredImplementation: "NotesShared visible-note summary list",
        requiredVerifier: "private_framework_visible_note_readback+body_redaction_checks",
        safetyGate: "bounded-read",
        privacyBoundary: "note_summaries_without_note_bodies",
        reason: "The accepted list command returns visible note summaries for all accounts, one account, or one folder without printing note bodies."
      ),
      NotesWorkflowAuditItem(
        family: "note_read_open",
        guideSection: "View your notes / Create and edit notes",
        status: "supported",
        appleCapability: "open_or_read_one_visible_note",
        command: "read --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_reader",
        requiredImplementation: "NotesShared single-note detail read",
        requiredVerifier: "private_framework_note_readback+locked_state_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "selected_note_only_with_locked_content_boundary",
        reason: "The accepted read command opens the CLI equivalent of one visible note while preserving locked-content boundaries."
      ),
      NotesWorkflowAuditItem(
        family: "note_create",
        guideSection: "Create a new note",
        status: "supported",
        appleCapability: "create_new_note",
        command: "create --folder FOLDER --title TITLE [--body BODY]",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note creation path",
        requiredVerifier: "private_framework_created_note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "title_body_inputs_only_for_explicit_mutation",
        reason: "The accepted create command creates one note in an explicit folder with dry-run and post-write readback."
      ),
      NotesWorkflowAuditItem(
        family: "note_edit_update",
        guideSection: "Edit a note",
        status: "supported",
        appleCapability: "edit_existing_note_title_or_body",
        command: "update --id NOTE_ID [--title TITLE] [--body BODY]",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note text/title update path",
        requiredVerifier: "private_framework_note_update_readback+preservation_checks",
        safetyGate: "dry-run/readback",
        privacyBoundary: "changed_fields_only_without_unrequested_body_dump",
        reason: "The accepted update command changes explicit title/body fields and verifies the target note while preserving unrelated state."
      ),
      NotesWorkflowAuditItem(
        family: "note_append_text",
        guideSection: "Edit a note",
        status: "supported",
        appleCapability: "append_text_to_existing_note",
        command: "append --id NOTE_ID --body BODY",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note append path",
        requiredVerifier: "private_framework_note_append_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "appended_text_hash_evidence_without_full_body_dump",
        reason: "The accepted append command adds explicit text to one note and verifies body suffix readback without dumping the full body."
      ),
      NotesWorkflowAuditItem(
        family: "note_duplicate_copy",
        guideSection: "Create a copy of a note",
        status: "supported",
        appleCapability: "duplicate_note",
        command: "copy --id NOTE_ID [--folder FOLDER]",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note copy path",
        requiredVerifier: "private_framework_copy_readback+source_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "source_and_copy_identity_without_body_dump",
        reason: "The accepted copy command duplicates one selected note and verifies copy identity and source preservation."
      ),
      NotesWorkflowAuditItem(
        family: "note_move_folder",
        guideSection: "View your notes / Organize your notes",
        status: "supported",
        appleCapability: "move_note_to_folder",
        command: "move --id NOTE_ID --folder FOLDER",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note folder move path",
        requiredVerifier: "private_framework_note_move_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "target_folder_identity_without_body_dump",
        reason: "The accepted move command moves one note to an explicit folder and verifies folder/account placement."
      ),
      NotesWorkflowAuditItem(
        family: "note_delete_recently_deleted",
        guideSection: "Delete a note",
        status: "supported",
        appleCapability: "delete_note_to_recently_deleted_where_available",
        command: "delete --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_delete",
        requiredImplementation: "private note delete path",
        requiredVerifier: "private_framework_visible_absence_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "deleted_identity_without_deleted_body",
        reason: "The accepted delete command removes one visible note through the private delete path and verifies visible absence."
      ),
      NotesWorkflowAuditItem(
        family: "note_restore_recently_deleted",
        guideSection: "View a recently deleted note",
        status: "supported",
        appleCapability: "recover_recently_deleted_note",
        command: "restore --id NOTE_ID --folder FOLDER; restore-all --folder FOLDER",
        mechanism: "typed_private_notes_framework_restorable_note_writer",
        requiredImplementation: "private restorable-note read and restore path",
        requiredVerifier: "private_framework_restored_note_readback",
        safetyGate: "dry-run/readback/destructive-selection-for-batch",
        privacyBoundary: "restorable_note_identity_without_deleted_body",
        reason: "The accepted restore commands recover one note or a bounded batch from restorable readback with placement verification."
      ),
      NotesWorkflowAuditItem(
        family: "note_purge_recently_deleted",
        guideSection: "View a recently deleted note",
        status: "supported",
        appleCapability: "permanently_delete_recently_deleted_note",
        command: "purge --id NOTE_ID; empty-trash",
        mechanism: "typed_private_notes_framework_purge_writer",
        requiredImplementation: "private purgable/restorable note purge path",
        requiredVerifier: "private_framework_visible_and_restorable_absence_readback",
        safetyGate: "dry-run/readback/destructive-selection",
        privacyBoundary: "purged_identity_without_deleted_body",
        reason: "The accepted purge and empty-trash commands permanently remove already deleted notes with destructive-selection gates and absence readback."
      ),
      NotesWorkflowAuditItem(
        family: "note_pin",
        guideSection: "Pin notes",
        status: "supported",
        appleCapability: "pin_note",
        command: "pin --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_state_writer",
        requiredImplementation: "private note pinned-state setter",
        requiredVerifier: "private_framework_pin_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "note_state_only_without_body_dump",
        reason: "The accepted pin command sets one selected note's pinned state and verifies state readback."
      ),
      NotesWorkflowAuditItem(
        family: "note_unpin",
        guideSection: "Pin notes",
        status: "supported",
        appleCapability: "unpin_note",
        command: "unpin --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_state_writer",
        requiredImplementation: "private note pinned-state setter",
        requiredVerifier: "private_framework_pin_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "note_state_only_without_body_dump",
        reason: "The accepted unpin command clears one selected note's pinned state and verifies state readback."
      ),
      NotesWorkflowAuditItem(
        family: "default_sort_setting",
        guideSection: "Choose a default sort for all notes",
        status: "supported",
        appleCapability: "choose_default_sort_for_all_notes",
        command: "settings sort --by FIELD --direction DIRECTION",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private default note-list sort preference setter",
        requiredVerifier: "settings_readback_hash_and_bool_evidence",
        safetyGate: "allow-persistent-action/readback",
        privacyBoundary: "preference_hashes_without_account_or_note_body_values",
        reason: "The accepted settings sort command mutates the default note-list sort preference with persistent-action gating and readback."
      ),
      NotesWorkflowAuditItem(
        family: "folder_sort",
        guideSection: "Sort notes in a folder",
        status: "supported",
        appleCapability: "choose_folder_specific_sort",
        command: "folders sort --folder FOLDER --by FIELD --direction DIRECTION",
        mechanism: "typed_private_notes_framework_folder_sort_writer",
        requiredImplementation: "private folder custom sort setter",
        requiredVerifier: "private_folder_sort_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "folder_identity_hashes_without_note_bodies",
        reason: "The accepted folder sort command changes one editable folder's sort when the folder advertises support and verifies sort metadata."
      ),
      NotesWorkflowAuditItem(
        family: "default_text_size_setting",
        guideSection: "Make text in notes bigger or smaller",
        status: "supported",
        appleCapability: "change_default_text_size_for_every_note",
        command: "settings text-size --size SIZE",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private default text size/global zoom setter",
        requiredVerifier: "settings_text_size_hash_readback",
        safetyGate: "allow-persistent-action/readback",
        privacyBoundary: "size_hash_without_raw_preference_value",
        reason: "The accepted text-size setting mutates default note text size with hash-only output and readback."
      ),
      NotesWorkflowAuditItem(
        family: "quick_note_resume_setting",
        guideSection: "Create a Quick Note",
        status: "supported",
        appleCapability: "always_resume_last_quick_note_setting",
        command: "settings quick-note-resume --enabled true|false",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private Quick Note resume preference setter",
        requiredVerifier: "settings_bool_readback",
        safetyGate: "allow-persistent-action/readback",
        privacyBoundary: "boolean_setting_only",
        reason: "The accepted Quick Note resume setting covers Apple's preference for resuming the last Quick Note versus creating a new one."
      ),
      NotesWorkflowAuditItem(
        family: "collapsible_section_view_state",
        guideSection: "View collapsed sections",
        status: "supported",
        appleCapability: "view_collapse_or_expand_sections",
        command: "body collapsible list|set --id NOTE_ID",
        mechanism: "typed_private_notes_framework_outline_state_reader_writer",
        requiredImplementation: "ICOutlineController/ICOutlineState readback",
        requiredVerifier: "private_outline_state_readback+privacy_hashes",
        safetyGate: "bounded-read/dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_section_text",
        reason: "The accepted collapsible commands list and change existing section state with paragraph hashes rather than section text."
      ),
      NotesWorkflowAuditItem(
        family: "note_date_folder_count_metadata",
        guideSection: "View information about notes",
        status: "supported",
        appleCapability: "view_created_edited_dates_and_folder_note_counts",
        command: "state read --id NOTE_ID; folders list",
        mechanism: "typed_private_notes_framework_state_and_folder_reader",
        requiredImplementation: "private note state/date read plus folder count read",
        requiredVerifier: "private_state_folder_count_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "date_and_count_metadata_without_note_body",
        reason: "The accepted state and folder readers expose note date metadata and folder note counts without note body text."
      ),
      NotesWorkflowAuditItem(
        family: "shared_activity_metadata",
        guideSection: "View information about notes",
        status: "supported",
        appleCapability: "view_shared_note_activity_metadata",
        command: "state activity --id NOTE_ID",
        mechanism: "typed_private_notes_framework_activity_reader",
        requiredImplementation: "private collaboration activity metadata read",
        requiredVerifier: "privacy_safe_activity_metadata_readback",
        safetyGate: "bounded-read/allow-artifact-action",
        privacyBoundary: "activity_hashes_without_activity_text_or_participant_names",
        reason: "The accepted activity command reports privacy-safe collaboration activity metadata and optional artifacts without raw activity text."
      ),
      NotesWorkflowAuditItem(
        family: "siri_note_creation",
        guideSection: "Create a new note",
        status: "delegated",
        appleCapability: "create_note_with_siri",
        command: "Siri voice interaction",
        mechanism: "delegated_siri_surface",
        requiredImplementation: "Siri/Apple Intelligence voice workflow",
        requiredVerifier: "delegated_system_voice_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Siri note creation is a system voice workflow; the CLI supports explicit semantic note creation separately."
      ),
      NotesWorkflowAuditItem(
        family: "notes_app_new_note_ui",
        guideSection: "Create a new note",
        status: "delegated",
        appleCapability: "create_note_from_toolbar_or_touch_bar",
        command: "Notes.app New Note button / Touch Bar",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app toolbar and Touch Bar interaction",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Toolbar and Touch Bar entry are UI affordances for note creation; the accepted CLI create command owns the persisted semantic result."
      ),
      NotesWorkflowAuditItem(
        family: "typing_suggestions_spelling_translation",
        guideSection: "Create a new note / Edit a note",
        status: "delegated",
        appleCapability: "typing_suggestions_spelling_dictionary_translation",
        command: "macOS text input services",
        mechanism: "delegated_system_text_services",
        requiredImplementation: "macOS spelling, dictionary, typing suggestions, and translation UI",
        requiredVerifier: "delegated_system_text_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Typing assistance is provided by macOS text services rather than a Notes private data mutation path."
      ),
      NotesWorkflowAuditItem(
        family: "clipboard_copy_paste",
        guideSection: "Copy and paste text",
        status: "delegated",
        appleCapability: "copy_paste_selected_or_all_note_text",
        command: "Edit > Copy/Paste/Paste and Match Style/Paste and Retain Style",
        mechanism: "delegated_system_clipboard_and_text_ui",
        requiredImplementation: "macOS pasteboard and Notes text editor UI",
        requiredVerifier: "delegated_clipboard_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Interactive copy/paste and paste-style choices are clipboard/editor UI surfaces; explicit CLI note text writes are supported separately."
      ),
      NotesWorkflowAuditItem(
        family: "universal_clipboard",
        guideSection: "Copy and paste text",
        status: "delegated",
        appleCapability: "paste_from_universal_clipboard",
        command: "Universal Clipboard",
        mechanism: "delegated_continuity_clipboard_surface",
        requiredImplementation: "macOS/iCloud Continuity clipboard",
        requiredVerifier: "delegated_continuity_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Universal Clipboard depends on Continuity and system pasteboard state outside the Notes model."
      ),
      NotesWorkflowAuditItem(
        family: "writing_tools",
        guideSection: "Use Writing Tools in Notes",
        status: "delegated",
        appleCapability: "summarize_proofread_or_rewrite_selected_text",
        command: "Apple Intelligence Writing Tools UI",
        mechanism: "delegated_apple_intelligence_surface",
        requiredImplementation: "Apple Intelligence Writing Tools",
        requiredVerifier: "delegated_system_intelligence_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Writing Tools are an Apple Intelligence system workflow over selected text, not a Notes private framework command path."
      ),
      NotesWorkflowAuditItem(
        family: "quick_note_keyboard_hot_corner_window",
        guideSection: "Create a Quick Note",
        status: "delegated",
        appleCapability: "open_quick_note_with_fn_q_hot_corner_or_floating_window",
        command: "Fn-Q / Hot Corner / Quick Note floating window",
        mechanism: "delegated_user_facing_quick_note_ui",
        requiredImplementation: "Notes.app Quick Note UI and window management",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Opening and positioning the Quick Note window is a Notes.app UI workflow; Quick Note preference readback is supported separately."
      ),
      NotesWorkflowAuditItem(
        family: "safari_quick_note_link",
        guideSection: "Add Safari links to a Quick Note",
        status: "delegated",
        appleCapability: "share_safari_page_to_quick_note",
        command: "Safari Share > Add to Quick Note",
        mechanism: "delegated_safari_share_extension_surface",
        requiredImplementation: "Safari/Share Sheet Quick Note integration",
        requiredVerifier: "delegated_external_dispatch_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Safari Quick Note capture depends on Safari and system share integration; explicit Notes links are supported separately."
      ),
      NotesWorkflowAuditItem(
        family: "safari_quick_note_selection_highlight",
        guideSection: "Add content from Safari to a Quick Note",
        status: "delegated",
        appleCapability: "add_selected_safari_content_and_webpage_highlight",
        command: "Safari contextual Add to Quick Note",
        mechanism: "delegated_safari_quick_note_highlight_surface",
        requiredImplementation: "Safari page selection and highlight persistence",
        requiredVerifier: "delegated_safari_highlight_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Persistent webpage highlights and Quick Note thumbnails are Safari/Notes UI integration, not a direct local Notes model mutation."
      ),
      NotesWorkflowAuditItem(
        family: "sidebar_gallery_window_ui",
        guideSection: "View your notes",
        status: "delegated",
        appleCapability: "show_sidebar_gallery_view_or_open_note_window",
        command: "Notes.app sidebar/list/gallery/separate window UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app window and view-state UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Sidebar visibility, gallery/list display, and separate note windows are UI state; CLI list/read expose the underlying note data."
      ),
      NotesWorkflowAuditItem(
        family: "locked_note_authentication_ui",
        guideSection: "Open a note / Delete a note",
        status: "delegated",
        appleCapability: "authenticate_to_view_or_delete_locked_note",
        command: "Notes.app locked-note password or Touch ID prompt",
        mechanism: "delegated_notes_security_ui",
        requiredImplementation: "Notes.app locked-note authentication session",
        requiredVerifier: "delegated_authentication_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Locked-note authentication is an interactive app/security session; the CLI reports lock state and refuses locked-content operations until secret-safe proof exists."
      ),
      NotesWorkflowAuditItem(
        family: "per_note_zoom_ui",
        guideSection: "Make text in notes bigger or smaller",
        status: "delegated",
        appleCapability: "zoom_one_note_in_or_out",
        command: "View > Zoom In / Zoom Out / Actual Size",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app per-window zoom UI",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Per-note zoom is transient view state; the accepted settings text-size command covers persisted default text size."
      ),
      NotesWorkflowAuditItem(
        family: "show_note_count_ui_toggle",
        guideSection: "View information about notes",
        status: "delegated",
        appleCapability: "show_or_hide_folder_note_count",
        command: "View > Show Note Count",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app note-count display preference",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The CLI exposes note counts through folder metadata; toggling the sidebar display is Notes.app UI state."
      ),
      NotesWorkflowAuditItem(
        family: "shortcuts_gestures_menu_ui",
        guideSection: "Keyboard shortcuts and gestures",
        status: "delegated",
        appleCapability: "invoke_notes_commands_with_shortcuts_or_gestures",
        command: "Notes.app keyboard shortcuts, menu bar, and gestures",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "AppKit menu commands, keyboard layout, and trackpad/mouse gestures",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Shortcuts and gestures are input affordances; accepted CLI commands own the semantic operations where implemented."
      ),
      NotesWorkflowAuditItem(
        family: "widgets_access_ui",
        guideSection: "Sort and pin notes / Use Notes widgets",
        status: "delegated",
        appleCapability: "access_notes_and_folders_from_widgets",
        command: "macOS widgets",
        mechanism: "delegated_system_widget_surface",
        requiredImplementation: "WidgetKit/Notification Center/Desktop widgets",
        requiredVerifier: "delegated_widget_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Notes widgets are system UI surfaces and remain delegated in the settings boundary."
      ),
      NotesWorkflowAuditItem(
        family: "recently_deleted_retention_sync",
        guideSection: "What happens to my deleted notes?",
        status: "delegated",
        appleCapability: "iCloud_or_provider_deleted_note_retention_timing",
        command: "Notes.app/iCloud/provider retention behavior",
        mechanism: "delegated_provider_sync_surface",
        requiredImplementation: "iCloud Notes or provider sync retention",
        requiredVerifier: "delegated_provider_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The 30-day local view and 40-day iCloud permanent-deletion timing are provider sync behavior, not a CLI-controlled private Notes write."
      ),
      NotesWorkflowAuditItem(
        family: "swipe_drag_lifecycle_ui",
        guideSection: "Sort and pin notes / Delete a note",
        status: "delegated",
        appleCapability: "pin_unpin_delete_or_share_with_swipe_or_drag",
        command: "Notes.app swipe and drag gestures",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app trackpad/mouse gesture handling",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Swipe and drag operations are UI inputs; the accepted CLI pin, unpin, delete, and sharing boundaries account for the semantic outcomes."
      ),
      NotesWorkflowAuditItem(
        family: "semantic_quick_note_create",
        guideSection: "Create a Quick Note",
        status: "supported",
        appleCapability: "create_new_quick_note_as_quick_note",
        command: "quick-note create",
        mechanism: "typed_private_notes_framework_system_paper_note_writer",
        requiredImplementation: "ICNote.newNote plus ICNote.mark(asSystemPaperIfNeeded:)",
        requiredVerifier: "private_quick_note_folder_and_system_paper_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "quick_note_identity_hashes_without_body_dump",
        reason: "Creates a persisted Quick Note/system-paper note through the private note writer and verifies system-paper state readback."
      ),
      NotesWorkflowAuditItem(
        family: "locked_note_content_open_cli",
        guideSection: "Open a note / Delete a note",
        status: "supported",
        appleCapability: "open_password_protected_note_content_from_cli_after_private_unlock",
        command: "state unlock --id NOTE_ID --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE; state export-locked-content --id NOTE_ID --output FILE.txt [--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE]",
        mechanism: "typed_private_notes_framework_unlock_plus_locked_content_artifact_export",
        requiredImplementation: "ICAuthenticationState.authenticateObject:withPassphrase: plus ICNote.noteAsPlainTextWithoutTitle",
        requiredVerifier: "notes_unlock_session_v1+notes_locked_content_export_v1",
        safetyGate: "--allow-persistent-action for unlock; --allow-artifact-action for export",
        privacyBoundary: "secret_source_boundary_and_no_locked_body_stdout",
        reason: "The CLI unlocks one password-protected note for the current Notes session through private authentication, then exports content only for a session-unlocked protected note to an explicit artifact with hash/readback verification. Currently locked notes without a prior unlock still refuse at the export command boundary."
      ),
      NotesWorkflowAuditItem(
        family: "multi_note_lifecycle_batch",
        guideSection: "Pin notes / Delete a note",
        status: "supported",
        appleCapability: "select_multiple_notes_for_pin_unpin_delete_copy_or_move",
        command: "batch pin|unpin|move|copy|delete --ids NOTE_ID,NOTE_ID [--folder FOLDER]",
        mechanism: "typed_private_notes_framework_batch_note_lifecycle_writer",
        requiredImplementation: "private note pin/move/copy/delete paths with batch selection gating",
        requiredVerifier: "private_framework_batch_identity_readback+destructive_selection_accounting",
        safetyGate: "dry-run/readback/destructive-selection-for-delete",
        privacyBoundary: "batch_id_hashes_without_note_bodies",
        reason: "The accepted batch commands require at least two explicit note IDs, keep batch IDs hash-only in dry-run/result evidence, reuse typed private single-note lifecycle writers, require destructive-selection gating for batch delete, and verify every selected note with private readback."
      ),
      NotesWorkflowAuditItem(
        family: "quick_note_lock_unavailable",
        guideSection: "Edit a Quick Note",
        status: "rejected",
        appleCapability: "lock_a_quick_note",
        command: "not accepted for Quick Notes",
        mechanism: "apple_product_limitation",
        requiredImplementation: "none",
        requiredVerifier: "official_product_limitation_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that Quick Notes cannot be locked, so this is a product limitation rather than pending private framework work."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesWorkflowAuditRecord(
        ordinal: index + 1,
        workflowFamily: item.family,
        guideSection: item.guideSection,
        status: item.status,
        appleCapability: item.appleCapability,
        command: item.command,
        implementationMechanism: item.mechanism,
        requiredImplementation: item.requiredImplementation,
        requiredVerifier: item.requiredVerifier,
        safetyGate: item.safetyGate,
        backendCalls: "none",
        privacyBoundary: item.privacyBoundary,
        reason: item.reason
      )
    }
  }

  private func notesWorkflowAuditSummary(_ records: [NotesWorkflowAuditRecord]) -> NotesWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesWorkflowAuditSummary(
      supportedRecordCount: supported.count,
      delegatedRecordCount: delegated.count,
      gatedRecordCount: gated.count,
      rejectedRecordCount: rejected.count,
      auditRequiresSelector: false,
      backendCalls: "none",
      supportedWorkflowFamilies: supported.map(\.workflowFamily),
      delegatedWorkflowFamilies: delegated.map(\.workflowFamily),
      gatedWorkflowFamilies: gated.map(\.workflowFamily),
      rejectedWorkflowFamilies: rejected.map(\.workflowFamily)
    )
  }

  private func verifyNotesWorkflowAudit(
    records: [NotesWorkflowAuditRecord],
    summary: NotesWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let rejected = Set(summary.rejectedWorkflowFamilies)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "note_lifecycle_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "note_create", "note_edit_update", "note_append_text", "note_duplicate_copy",
            "note_move_folder", "note_delete_recently_deleted", "note_restore_recently_deleted",
            "note_purge_recently_deleted", "semantic_quick_note_create", "multi_note_lifecycle_batch",
            "locked_note_content_open_cli",
          ]
        )
      ),
      verificationBoolCheck(
        name: "view_metadata_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "visible_note_list", "note_read_open", "collapsible_section_view_state",
            "note_date_folder_count_metadata", "shared_activity_metadata",
          ]
        )
      ),
      verificationBoolCheck(
        name: "sort_pin_settings_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "note_pin", "note_unpin", "default_sort_setting", "folder_sort",
            "default_text_size_setting", "quick_note_resume_setting",
          ]
        )
      ),
      verificationBoolCheck(
        name: "ui_system_and_external_surfaces_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "siri_note_creation", "notes_app_new_note_ui", "typing_suggestions_spelling_translation",
            "clipboard_copy_paste", "universal_clipboard", "writing_tools",
            "quick_note_keyboard_hot_corner_window", "safari_quick_note_link",
            "safari_quick_note_selection_highlight", "sidebar_gallery_window_ui",
            "locked_note_authentication_ui", "per_note_zoom_ui", "show_note_count_ui_toggle",
            "shortcuts_gestures_menu_ui", "widgets_access_ui", "recently_deleted_retention_sync",
            "swipe_drag_lifecycle_ui",
          ]
        )
      ),
      verificationBoolCheck(
        name: "note_workflow_semantics_have_no_gated_records",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "product_limitation_rejected",
        expected: true,
        actual: rejected.contains("quick_note_lock_unavailable")
      ),
      verificationBoolCheck(
        name: "audit_has_no_selector_input",
        expected: false,
        actual: summary.auditRequiresSelector
      ),
      verificationBoolCheck(
        name: "backend_calls_none",
        expected: true,
        actual: summary.backendCalls == "none" && records.allSatisfy { $0.backendCalls == "none" }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.workflow.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.workflow.audit"),
      checks: checks
    )
  }

  private func noteWorkflowShortcutsAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.workflow.shortcuts.audit"
    let records = notesWorkflowShortcutsAuditRecords()
    let summary = notesWorkflowAuditSummary(records)
    let verification = verifyNotesWorkflowShortcutsAudit(records: records, summary: summary)
    let response = NotesWorkflowAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_records: \(summary.supportedRecordCount), delegated_records: \(summary.delegatedRecordCount), gated_records: \(summary.gatedRecordCount), rejected_records: \(summary.rejectedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesWorkflowShortcutsAuditRecords() -> [NotesWorkflowAuditRecord] {
    struct ShortcutAuditItem {
      var family: String
      var guideSection: String
      var status: String
      var appleCapability: String
      var command: String
      var mechanism: String
      var requiredImplementation: String
      var requiredVerifier: String
      var safetyGate: String?
      var privacyBoundary: String
      var reason: String
    }

    let items = [
      ShortcutAuditItem(
        family: "shortcut_create_new_note",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "create_new_note_with_command_n",
        command: "create --folder FOLDER --title TITLE [--body BODY]",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note creation path",
        requiredVerifier: "private_framework_created_note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "explicit_title_body_inputs_only",
        reason: "Command-N's persisted semantic result is covered by the accepted note create command."
      ),
      ShortcutAuditItem(
        family: "shortcut_create_quick_note",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "create_quick_note_with_fn_q",
        command: "quick-note create",
        mechanism: "typed_private_notes_framework_system_paper_note_writer",
        requiredImplementation: "ICNote.newNote plus ICNote.mark(asSystemPaperIfNeeded:)",
        requiredVerifier: "private_quick_note_folder_and_system_paper_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "quick_note_identity_without_body_dump",
        reason: "The persisted semantic result of Quick Note creation is now covered by the accepted system-paper note creation command; UI invocation remains delegated."
      ),
      ShortcutAuditItem(
        family: "shortcut_duplicate_note",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "duplicate_note_with_command_d",
        command: "copy --id NOTE_ID [--folder FOLDER]",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "private note copy path",
        requiredVerifier: "private_framework_copy_readback+source_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "source_and_copy_identity_without_body_dump",
        reason: "Command-D's duplicate-note semantic result is covered by the accepted copy command."
      ),
      ShortcutAuditItem(
        family: "shortcut_create_new_folder",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "create_new_folder_with_shift_command_n",
        command: "folders create --name NAME --account ACCOUNT; folders create --name NAME --parent FOLDER",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "private folder create path",
        requiredVerifier: "notes_folder_mutation_v1+folder_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "folder_selector_metadata_without_note_content",
        reason: "Shift-Command-N's persisted folder creation result is covered by accepted folder create commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_show_main_window",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "show_main_notes_window",
        command: "Notes.app Command-0",
        mechanism: "delegated_notes_app_window_ui",
        requiredImplementation: "Notes.app window management",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Showing a window is UI state; it has no persisted Notes data mutation for the CLI."
      ),
      ShortcutAuditItem(
        family: "shortcut_show_list_view",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "show_notes_in_list_view",
        command: "Notes.app Command-1",
        mechanism: "delegated_notes_app_view_ui",
        requiredImplementation: "Notes.app list view state",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The CLI exposes note summaries through `list`; switching the app's list view remains UI state."
      ),
      ShortcutAuditItem(
        family: "shortcut_show_gallery_view",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "show_notes_in_gallery_view",
        command: "Notes.app Command-2",
        mechanism: "delegated_notes_app_view_ui",
        requiredImplementation: "Notes.app gallery view state",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Gallery view is Notes.app presentation state, not a private data-model operation."
      ),
      ShortcutAuditItem(
        family: "shortcut_show_attachments",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "show_attachments_browser",
        command: "Notes.app Command-3",
        mechanism: "delegated_notes_app_attachments_browser_ui",
        requiredImplementation: "Notes.app Attachments Browser UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Opening the Attachments Browser is UI; attachment metadata/search commands expose the underlying data."
      ),
      ShortcutAuditItem(
        family: "shortcut_search_all_notes",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "search_all_notes_with_option_command_f",
        command: "search --query QUERY",
        mechanism: "typed_private_notes_framework_search_reader",
        requiredImplementation: "private visible-note text search",
        requiredVerifier: "query_hash+visible_note_search_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "query_hash_and_note_summaries_without_note_bodies",
        reason: "The accepted search command covers the semantic result of searching all visible notes without printing note bodies."
      ),
      ShortcutAuditItem(
        family: "shortcut_focus_sidebar_list_search",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "move_focus_between_sidebar_notes_list_and_search",
        command: "Notes.app Tab focus movement",
        mechanism: "delegated_notes_app_focus_ui",
        requiredImplementation: "AppKit focus ring/navigation",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Keyboard focus movement is interactive UI state and does not change Notes model data."
      ),
      ShortcutAuditItem(
        family: "shortcut_begin_typing_selected_note",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "begin_typing_in_selected_note",
        command: "Notes.app Return focus into editor",
        mechanism: "delegated_notes_editor_focus_ui",
        requiredImplementation: "Notes.app text editor focus",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Moving the insertion point is editor UI state; explicit CLI update/append commands own text mutations."
      ),
      ShortcutAuditItem(
        family: "shortcut_print_note",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "print_note_with_command_p",
        command: "print --id NOTE_ID --printer PRINTER --allow-external-dispatch",
        mechanism: "private_pdf_exporter_plus_delegated_system_print",
        requiredImplementation: "private note PDF generation plus system print dispatch",
        requiredVerifier: "pdf_artifact_header_hash+print_job_dispatch_evidence",
        safetyGate: "dry-run/allow-external-dispatch",
        privacyBoundary: "print_job_and_pdf_hash_without_note_body",
        reason: "Command-P's note print result is covered by the accepted print command with explicit external-dispatch approval."
      ),
      ShortcutAuditItem(
        family: "shortcut_pin_note_swipe",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "pin_note_with_swipe",
        command: "pin --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_state_writer",
        requiredImplementation: "private pinned-state setter",
        requiredVerifier: "private_framework_pin_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "note_state_only_without_body_dump",
        reason: "The persisted pin state is covered by the accepted pin command; the swipe gesture itself is UI."
      ),
      ShortcutAuditItem(
        family: "shortcut_delete_note_swipe",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "supported",
        appleCapability: "delete_note_with_swipe",
        command: "delete --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_delete",
        requiredImplementation: "private note delete path",
        requiredVerifier: "private_framework_visible_absence_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "deleted_identity_without_deleted_body",
        reason: "The persisted delete result is covered by the accepted delete command; the swipe gesture is only an input route."
      ),
      ShortcutAuditItem(
        family: "shortcut_share_note_swipe",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "share_note_with_swipe",
        command: "Notes.app Share button / Share sheet",
        mechanism: "delegated_notes_app_share_ui",
        requiredImplementation: "Notes.app Share sheet and collaboration UI",
        requiredVerifier: "delegated_or_gated_collaboration_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Sharing from the swipe UI is a Notes.app/share-sheet route; collaboration mutations remain explicitly gated elsewhere."
      ),
      ShortcutAuditItem(
        family: "shortcut_shared_highlights_toggle",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "show_or_hide_highlights_in_shared_note",
        command: "Notes.app Control-Command-I",
        mechanism: "delegated_notes_app_collaboration_ui",
        requiredImplementation: "Notes.app shared-note highlight view state",
        requiredVerifier: "delegated_collaboration_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_participant_or_activity_text_output",
        reason: "Highlight visibility is a shared-note UI view toggle; privacy-safe activity metadata is supported separately."
      ),
      ShortcutAuditItem(
        family: "shortcut_shared_activity_toggle",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "show_or_hide_activity_list_in_shared_note",
        command: "Notes.app Control-Command-K",
        mechanism: "delegated_notes_app_collaboration_ui",
        requiredImplementation: "Notes.app activity list UI",
        requiredVerifier: "delegated_collaboration_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_activity_text_or_participant_values",
        reason: "Activity list presentation is UI; `state activity` exposes bounded privacy-safe metadata."
      ),
      ShortcutAuditItem(
        family: "shortcut_linked_note_forward",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "go_forward_to_linked_note",
        command: "Notes.app Option-Command-]",
        mechanism: "delegated_notes_app_navigation_ui",
        requiredImplementation: "Notes.app linked-note navigation stack",
        requiredVerifier: "delegated_navigation_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Navigation through open note windows is UI; `links resolve` exposes link destination evidence separately."
      ),
      ShortcutAuditItem(
        family: "shortcut_linked_note_back",
        guideSection: "Keyboard shortcuts and gestures / General",
        status: "delegated",
        appleCapability: "return_to_source_note_from_linked_note",
        command: "Notes.app Option-Command-[",
        mechanism: "delegated_notes_app_navigation_ui",
        requiredImplementation: "Notes.app linked-note navigation stack",
        requiredVerifier: "delegated_navigation_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Back navigation is app navigation state, not a persisted Notes model mutation."
      ),
      ShortcutAuditItem(
        family: "shortcut_attach_file",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "attach_file_with_shift_command_a",
        command: "attachments add --id NOTE_ID --file FILE",
        mechanism: "typed_private_notes_framework_attachment_writer",
        requiredImplementation: "ICNote.addAttachmentWithData:filename:",
        requiredVerifier: "attachment_metadata_readback+export_hash_verification",
        safetyGate: "dry-run/readback",
        privacyBoundary: "file_hash_and_attachment_metadata_without_bytes",
        reason: "Shift-Command-A's persisted attachment result is covered by the accepted attachment add command."
      ),
      ShortcutAuditItem(
        family: "shortcut_create_web_link",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "create_webpage_link_with_command_k",
        command: "links add --id NOTE_ID --url URL",
        mechanism: "typed_private_notes_framework_link_writer",
        requiredImplementation: "ICNote.addURLAttachmentWithURL",
        requiredVerifier: "link_metadata_readback+note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "public_web_url_only_for_explicit_link_mutation",
        reason: "Command-K's web-link result is covered by accepted link add commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_insert_table",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "insert_table_with_option_command_t",
        command: "body table create --id NOTE_ID",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "ICNote.addTableAttachmentWithText",
        requiredVerifier: "private_table_structure_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_shape_and_cell_hashes_without_body_dump",
        reason: "Option-Command-T's table insertion result is covered by the accepted table create command."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_title_format",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_title_format",
        command: "body paragraph style --id NOTE_ID --paragraph HASH --style title",
        mechanism: "typed_private_notes_framework_rich_text_writer",
        requiredImplementation: "ICTT paragraph style mutation",
        requiredVerifier: "private_body_structure_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_paragraph_text",
        reason: "Title paragraph style is accepted through the paragraph style command."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_heading_format",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_heading_format",
        command: "body paragraph style --id NOTE_ID --paragraph HASH --style heading",
        mechanism: "typed_private_notes_framework_rich_text_writer",
        requiredImplementation: "ICTT paragraph style mutation",
        requiredVerifier: "private_body_structure_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_paragraph_text",
        reason: "Heading paragraph style is accepted through the paragraph style command."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_subheading_format",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_subheading_format",
        command: "body paragraph style --id NOTE_ID --paragraph HASH --style subheading",
        mechanism: "typed_private_notes_framework_rich_text_writer",
        requiredImplementation: "ICTT paragraph style mutation",
        requiredVerifier: "private_body_structure_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_paragraph_text",
        reason: "Subheading paragraph style is accepted through the paragraph style command."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_body_format",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_body_format",
        command: "body paragraph style --id NOTE_ID --paragraph HASH --style body",
        mechanism: "typed_private_notes_framework_rich_text_writer",
        requiredImplementation: "ICTT paragraph style mutation",
        requiredVerifier: "private_body_structure_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_paragraph_text",
        reason: "Body paragraph style is accepted through the paragraph style command."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_monostyled_format",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_monostyled_paragraph_format",
        command: "body paragraph style --id NOTE_ID --paragraph HASH --style monostyled",
        mechanism: "typed_private_notes_framework_rich_text_writer",
        requiredImplementation: "ICTextStyle.fixedWidthStyle plus ICTT paragraph style mutation",
        requiredVerifier: "private_body_structure_monostyled_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_paragraph_text",
        reason: "The accepted paragraph-style writer applies Apple's Monostyled style through the private fixed-width text style and verifies body-structure readback."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_bulleted_list",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_bulleted_list_format",
        command: "body list convert --style bulleted; body list set-style --style bulleted",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list paragraph style mutation",
        requiredVerifier: "private_body_structure_list_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_list_text",
        reason: "Bulleted list formatting is accepted through ordinary-list commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_dashed_list",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_dashed_list_format",
        command: "body list convert --style dashed; body list set-style --style dashed",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list paragraph style mutation",
        requiredVerifier: "private_body_structure_list_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_list_text",
        reason: "Dashed list formatting is accepted through ordinary-list commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_numbered_list",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_numbered_list_format",
        command: "body list convert --style numbered; body list set-style --style numbered",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list paragraph style mutation",
        requiredVerifier: "private_body_structure_list_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_list_text",
        reason: "Numbered list formatting is accepted through ordinary-list commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_checklist_format",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_checklist_format",
        command: "body checklist convert; body checklist convert-range",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private checklist paragraph mutation",
        requiredVerifier: "private_body_structure_checklist_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_checklist_text",
        reason: "Checklist formatting is accepted through checklist conversion commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_apply_block_quote",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "apply_block_quote_format",
        command: "body paragraph quote --id NOTE_ID --paragraph HASH --state on|off",
        mechanism: "typed_private_notes_framework_rich_text_writer",
        requiredImplementation: "private block quote paragraph mutation",
        requiredVerifier: "private_body_structure_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_paragraph_text",
        reason: "Block quote formatting is accepted through paragraph quote mutation."
      ),
      ShortcutAuditItem(
        family: "shortcut_increase_font_size",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "increase_font_size",
        command: "body inline font --id NOTE_ID --paragraph HASH --text TEXT --size SIZE",
        mechanism: "typed_private_notes_framework_inline_font_writer",
        requiredImplementation: "private attributed-run font mutation",
        requiredVerifier: "private_body_structure_inline_font_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "selected_text_hash_without_body_dump",
        reason: "Selected-text font size changes are accepted through inline font mutation."
      ),
      ShortcutAuditItem(
        family: "shortcut_decrease_font_size",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "decrease_font_size",
        command: "body inline font --id NOTE_ID --paragraph HASH --text TEXT --size SIZE",
        mechanism: "typed_private_notes_framework_inline_font_writer",
        requiredImplementation: "private attributed-run font mutation",
        requiredVerifier: "private_body_structure_inline_font_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "selected_text_hash_without_body_dump",
        reason: "Selected-text font size changes are accepted through inline font mutation."
      ),
      ShortcutAuditItem(
        family: "shortcut_increase_list_level",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "increase_list_or_checklist_level",
        command: "body list indent --by 1; body checklist indent --by 1",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private list/checklist indentation mutation",
        requiredVerifier: "private_body_structure_indentation_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_item_text",
        reason: "Increasing list/checklist level is accepted through explicit indent commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_decrease_list_level",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "decrease_list_or_checklist_level",
        command: "body list indent --by -1; body checklist indent --by -1",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private list/checklist indentation mutation",
        requiredVerifier: "private_body_structure_indentation_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_item_text",
        reason: "Decreasing list/checklist level is accepted through explicit indent commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_list_soft_return",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "add_soft_return_to_list_or_checklist_item",
        command: "body list line-break --id NOTE_ID --paragraph HASH; body checklist line-break --id NOTE_ID --paragraph HASH",
        mechanism: "typed_private_notes_framework_list_text_storage_writer",
        requiredImplementation: "private list/checklist item text-storage line-separator mutation",
        requiredVerifier: "private_body_structure_list_text_insert_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_item_text",
        reason: "Soft return insertion is accepted through bounded text-storage mutation on one selected list or checklist item."
      ),
      ShortcutAuditItem(
        family: "shortcut_list_tab_character",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "insert_tab_character_in_list_item",
        command: "body list tab --id NOTE_ID --paragraph HASH",
        mechanism: "typed_private_notes_framework_list_text_storage_writer",
        requiredImplementation: "private ordinary-list item text-storage tab mutation",
        requiredVerifier: "private_body_structure_list_text_insert_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_item_text",
        reason: "Literal tab insertion is accepted through bounded text-storage mutation on one selected ordinary list item."
      ),
      ShortcutAuditItem(
        family: "shortcut_toggle_checklist_item",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "mark_or_unmark_checklist_item",
        command: "body checklist set --state checked|open",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private checklist state mutation",
        requiredVerifier: "private_body_structure_checklist_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_checklist_text",
        reason: "Checklist item toggle is accepted through checklist set commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_move_list_item_up",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "move_list_or_checklist_item_up",
        command: "body list reorder; body checklist reorder",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private list/checklist paragraph reorder",
        requiredVerifier: "private_body_structure_order_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_item_text",
        reason: "Moving list/checklist items up is accepted through reorder commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_move_list_item_down",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "supported",
        appleCapability: "move_list_or_checklist_item_down",
        command: "body list reorder; body checklist reorder",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private list/checklist paragraph reorder",
        requiredVerifier: "private_body_structure_order_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_item_text",
        reason: "Moving list/checklist items down is accepted through reorder commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_zoom_in_note",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "delegated",
        appleCapability: "zoom_in_on_note_contents",
        command: "Notes.app Shift-Command-.",
        mechanism: "delegated_notes_app_zoom_ui",
        requiredImplementation: "Notes.app per-window zoom state",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Per-note zoom is transient UI state; persisted default text size is supported separately."
      ),
      ShortcutAuditItem(
        family: "shortcut_zoom_out_note",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "delegated",
        appleCapability: "zoom_out_on_note_contents",
        command: "Notes.app Shift-Command-,",
        mechanism: "delegated_notes_app_zoom_ui",
        requiredImplementation: "Notes.app per-window zoom state",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Per-note zoom is transient UI state; persisted default text size is supported separately."
      ),
      ShortcutAuditItem(
        family: "shortcut_zoom_actual_size",
        guideSection: "Keyboard shortcuts and gestures / Edit notes",
        status: "delegated",
        appleCapability: "change_note_contents_to_default_size",
        command: "Notes.app Shift-Command-0",
        mechanism: "delegated_notes_app_zoom_ui",
        requiredImplementation: "Notes.app per-window zoom state",
        requiredVerifier: "delegated_view_state_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Actual-size view reset is a UI zoom command, distinct from persisted default text-size settings."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_return_add_row",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "move_down_or_add_new_bottom_row",
        command: "body table rows insert --position below",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table row insertion mutation",
        requiredVerifier: "private_table_structure_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_cell_hashes_without_cell_text",
        reason: "The persisted add-row result is accepted through table row insertion; cursor movement remains UI."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_move_up_or_above",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "move_up_one_row_or_above_table",
        command: "Notes.app Shift-Return in table",
        mechanism: "delegated_notes_table_navigation_ui",
        requiredImplementation: "Notes.app table cursor navigation",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Cursor movement within or out of a table is editor UI state."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_cell_new_paragraph",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "add_new_paragraph_in_table_cell",
        command: "body table update --id NOTE_ID --ordinal N --row R --column C --text TEXT_WITH_LINE_BREAK",
        mechanism: "typed_private_notes_framework_table_cell_writer",
        requiredImplementation: "ICTable.setAttributedString:columnIndex:rowIndex:",
        requiredVerifier: "private_table_cell_hash_readback+newline_byte_count_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_cell_hash_without_cell_text",
        reason: "The accepted table-cell writer preserves newline text in one selected cell and verifies byte count plus SHA-256 readback without printing cell text."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_add_row_above",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "add_table_row_above",
        command: "body table rows insert --position above",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table row insertion mutation",
        requiredVerifier: "private_table_structure_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_shape_without_cell_text",
        reason: "Adding a row above is accepted through table row insertion commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_add_row_below",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "add_table_row_below",
        command: "body table rows insert --position below",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table row insertion mutation",
        requiredVerifier: "private_table_structure_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_shape_without_cell_text",
        reason: "Adding a row below is accepted through table row insertion commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_add_column_right",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "add_table_column_right",
        command: "body table columns insert --position right",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table column insertion mutation",
        requiredVerifier: "private_table_structure_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_shape_without_cell_text",
        reason: "Adding a column to the right is accepted through table column insertion commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_add_column_left",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "add_table_column_left",
        command: "body table columns insert --position left",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table column insertion mutation",
        requiredVerifier: "private_table_structure_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_shape_without_cell_text",
        reason: "Adding a column to the left is accepted through table column insertion commands."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_next_cell",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "move_to_next_cell_right",
        command: "Notes.app Tab in table",
        mechanism: "delegated_notes_table_navigation_ui",
        requiredImplementation: "Notes.app table cursor navigation",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Moving between cells is editor UI state; explicit cell selectors are used for CLI mutations."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_previous_cell",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "move_to_next_cell_left",
        command: "Notes.app Shift-Tab in table",
        mechanism: "delegated_notes_table_navigation_ui",
        requiredImplementation: "Notes.app table cursor navigation",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Moving between cells is editor UI state; explicit cell selectors are used for CLI mutations."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_cell_tab_character",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "supported",
        appleCapability: "insert_tab_character_in_table_cell",
        command: "body table update --id NOTE_ID --ordinal N --row R --column C --text TEXT_WITH_TAB",
        mechanism: "typed_private_notes_framework_table_cell_writer",
        requiredImplementation: "ICTable.setAttributedString:columnIndex:rowIndex:",
        requiredVerifier: "private_table_cell_hash_readback+tab_byte_count_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_cell_hash_without_cell_text",
        reason: "The accepted table-cell writer preserves literal tab characters in one selected cell and verifies byte count plus SHA-256 readback without printing cell text."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_select_row_range",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "select_range_of_cells_in_row",
        command: "Notes.app Shift-Left/Right in table",
        mechanism: "delegated_notes_table_selection_ui",
        requiredImplementation: "Notes.app table selection UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Interactive range selection is UI state; CLI table commands use explicit row/column/cell selectors."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_select_column_range",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "select_range_of_cells_in_column",
        command: "Notes.app Shift-Up/Down in table",
        mechanism: "delegated_notes_table_selection_ui",
        requiredImplementation: "Notes.app table selection UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Interactive range selection is UI state; CLI table commands use explicit row/column/cell selectors."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_select_cell_content",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "select_current_cell_content",
        command: "Notes.app Command-A in table cell",
        mechanism: "delegated_notes_table_selection_ui",
        requiredImplementation: "Notes.app table selection UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Selecting cell content is UI state; privacy-safe table cell hashes are available through table list/readback paths."
      ),
      ShortcutAuditItem(
        family: "shortcut_table_select_entire_table",
        guideSection: "Keyboard shortcuts and gestures / Navigate in tables",
        status: "delegated",
        appleCapability: "select_entire_table",
        command: "Notes.app Command-A, Command-A",
        mechanism: "delegated_notes_table_selection_ui",
        requiredImplementation: "Notes.app table selection UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Selecting the whole table is UI state; whole-table copy/delete/convert semantics are exposed through explicit CLI commands."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesWorkflowAuditRecord(
        ordinal: index + 1,
        workflowFamily: item.family,
        guideSection: item.guideSection,
        status: item.status,
        appleCapability: item.appleCapability,
        command: item.command,
        implementationMechanism: item.mechanism,
        requiredImplementation: item.requiredImplementation,
        requiredVerifier: item.requiredVerifier,
        safetyGate: item.safetyGate,
        backendCalls: "none",
        privacyBoundary: item.privacyBoundary,
        reason: item.reason
      )
    }
  }

  private func verifyNotesWorkflowShortcutsAudit(
    records: [NotesWorkflowAuditRecord],
    summary: NotesWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let guideSections = records.flatMap { $0.guideSection.components(separatedBy: " / ") }
    let guideSectionSet = Set(guideSections)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "official_shortcuts_sections_accounted",
        expected: true,
        actual: guideSectionSet.contains("Keyboard shortcuts and gestures")
          && guideSectionSet.contains("General")
          && guideSectionSet.contains("Edit notes")
          && guideSectionSet.contains("Navigate in tables")
      ),
      verificationBoolCheck(
        name: "semantic_shortcut_results_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "shortcut_create_new_note", "shortcut_duplicate_note", "shortcut_create_new_folder",
            "shortcut_create_quick_note",
            "shortcut_search_all_notes", "shortcut_print_note", "shortcut_pin_note_swipe",
            "shortcut_delete_note_swipe", "shortcut_attach_file", "shortcut_create_web_link",
            "shortcut_insert_table",
          ]
        )
      ),
      verificationBoolCheck(
        name: "formatting_shortcuts_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "shortcut_apply_title_format", "shortcut_apply_heading_format",
            "shortcut_apply_subheading_format", "shortcut_apply_body_format",
            "shortcut_apply_monostyled_format",
            "shortcut_apply_bulleted_list", "shortcut_apply_dashed_list",
            "shortcut_apply_numbered_list", "shortcut_apply_checklist_format",
            "shortcut_apply_block_quote", "shortcut_increase_font_size",
            "shortcut_decrease_font_size", "shortcut_increase_list_level",
            "shortcut_decrease_list_level", "shortcut_list_soft_return",
            "shortcut_list_tab_character", "shortcut_toggle_checklist_item",
            "shortcut_move_list_item_up", "shortcut_move_list_item_down",
          ]
        )
      ),
      verificationBoolCheck(
        name: "table_mutation_shortcuts_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "shortcut_table_return_add_row", "shortcut_table_add_row_above",
            "shortcut_table_add_row_below", "shortcut_table_add_column_right",
            "shortcut_table_add_column_left", "shortcut_table_cell_new_paragraph",
            "shortcut_table_cell_tab_character",
          ]
        )
      ),
      verificationBoolCheck(
        name: "ui_navigation_selection_shortcuts_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "shortcut_show_main_window", "shortcut_show_list_view", "shortcut_show_gallery_view",
            "shortcut_show_attachments", "shortcut_focus_sidebar_list_search",
            "shortcut_begin_typing_selected_note", "shortcut_share_note_swipe",
            "shortcut_shared_highlights_toggle", "shortcut_shared_activity_toggle",
            "shortcut_linked_note_forward", "shortcut_linked_note_back",
            "shortcut_zoom_in_note", "shortcut_zoom_out_note", "shortcut_zoom_actual_size",
            "shortcut_table_move_up_or_above", "shortcut_table_next_cell",
            "shortcut_table_previous_cell", "shortcut_table_select_row_range",
            "shortcut_table_select_column_range", "shortcut_table_select_cell_content",
            "shortcut_table_select_entire_table",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_shortcut_semantics_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "audit_has_no_selector_input",
        expected: false,
        actual: summary.auditRequiresSelector
      ),
      verificationBoolCheck(
        name: "backend_calls_none",
        expected: true,
        actual: summary.backendCalls == "none" && records.allSatisfy { $0.backendCalls == "none" }
      ),
      verificationBoolCheck(
        name: "privacy_boundaries_recorded",
        expected: true,
        actual: records.allSatisfy { !$0.privacyBoundary.isEmpty }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.workflow.shortcuts.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.workflow.shortcuts.audit"),
      checks: checks
    )
  }
}
