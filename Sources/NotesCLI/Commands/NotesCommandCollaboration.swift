import Foundation
import Utility

extension NotesCommand {

  func collaborationWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.collaboration.audit"
    let records = notesCollaborationWorkflowAuditRecords()
    let summary = notesCollaborationWorkflowAuditSummary(records)
    let verification = verifyCollaborationWorkflowAudit(records: records, summary: summary)
    let response = NotesCollaborationWorkflowAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_records: \(summary.supportedRecordCount), delegated_records: \(summary.delegatedRecordCount), gated_records: \(summary.gatedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesCollaborationWorkflowAuditRecords() -> [NotesCollaborationWorkflowAuditRecord] {
    struct CollaborationWorkflowAuditItem {
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
      CollaborationWorkflowAuditItem(
        family: "share_state_read",
        guideSection: "Share and manage shared notes and folders",
        status: "supported",
        appleCapability: "read_shared_note_state",
        command: "state read --id NOTE_ID; state audit [--account ACCOUNT|--folder FOLDER]",
        mechanism: "typed_private_notes_framework_note_state_reader",
        requiredImplementation: "ICNote and ICCloudSyncingObject shared-state readback",
        requiredVerifier: "private_note_state_readback+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_counts_and_booleans_only",
        reason: "Shared note, folder-share, read-only, participant-count, and unread-change flags are accepted read surfaces."
      ),
      CollaborationWorkflowAuditItem(
        family: "shared_folder_state_read",
        guideSection: "Share a folder / Manage shared notes and folders",
        status: "supported",
        appleCapability: "read_shared_folder_membership_state",
        command: "state audit [--folder FOLDER]",
        mechanism: "typed_private_notes_framework_note_state_reader",
        requiredImplementation: "visible-note selection plus private folder/shared-read-only state",
        requiredVerifier: "private_note_state_batch_readback+shared_folder_count_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_folder_name_or_participant_names",
        reason: "The existing state audit accounts for notes shared through iCloud folders without printing collaboration handles."
      ),
      CollaborationWorkflowAuditItem(
        family: "editable_shared_note_mutation",
        guideSection: "Collaborate with shared notes and folders",
        status: "supported",
        appleCapability: "edit_shared_note_when_permission_allows",
        command: "update/append/body commands on editable shared notes",
        mechanism: "typed_private_notes_framework_note_body_writer",
        requiredImplementation: "accepted note and rich-body writers with shared-read-only/editability gates",
        requiredVerifier: "private_note_readback+editability_gate+mutation_delta",
        safetyGate: "DryRun payload",
        privacyBoundary: "does_not_print_note_body_in_diagnostics",
        reason: "Shared notes that private state readback reports as editable use the same accepted note/body mutation verifier path."
      ),
      CollaborationWorkflowAuditItem(
        family: "activity_metadata_read",
        guideSection: "View activity for a shared note",
        status: "supported",
        appleCapability: "view_shared_note_activity_metadata",
        command: "state activity --id NOTE_ID",
        mechanism: "typed_private_notes_framework_activity_metadata_reader",
        requiredImplementation: "private activity metadata readback with participant hashes and event hashes",
        requiredVerifier: "private_activity_metadata_readback+privacy_hash_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_activity_text_or_participant_names",
        reason: "The accepted activity command reports privacy-safe activity metadata, not raw activity detail text."
      ),
      CollaborationWorkflowAuditItem(
        family: "activity_metadata_artifact_export",
        guideSection: "View activity for a shared note",
        status: "supported",
        appleCapability: "export_shared_note_activity_metadata",
        command: "state activity --id NOTE_ID --output FILE.json",
        mechanism: "typed_private_notes_framework_activity_metadata_reader_plus_artifact_writer",
        requiredImplementation: "private activity metadata readback plus verified JSON artifact",
        requiredVerifier: "private_activity_metadata_readback+artifact_sha256_verification",
        safetyGate: "--allow-artifact-action",
        privacyBoundary: "artifact_contains_hashes_counts_and_booleans_only",
        reason: "The CLI can export the same privacy-safe metadata artifact after an explicit artifact-action gate."
      ),
      CollaborationWorkflowAuditItem(
        family: "participant_access_metadata_read",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "view_participants_and_access_metadata",
        command: "state participants --id NOTE_ID|--folder FOLDER",
        mechanism: "typed_private_notes_framework_share_participant_reader",
        requiredImplementation: "ICCloudSyncingObject.serverShare participants/publicPermission plus note/folder shared-state readback",
        requiredVerifier: "private_share_participant_hash_readback+permission_enum_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_participant_names_handles_share_link_or_note_content",
        reason: "Existing shared note or folder participant/access metadata is accepted as a read-only, privacy-safe state surface; changing participants or permissions remains gated."
      ),
      CollaborationWorkflowAuditItem(
        family: "participant_access_metadata_artifact_export",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "export_participants_and_access_metadata",
        command: "state participants --id NOTE_ID|--folder FOLDER --output FILE.json",
        mechanism: "typed_private_notes_framework_share_participant_reader_plus_artifact_writer",
        requiredImplementation: "privacy-safe participant/access metadata JSON artifact",
        requiredVerifier: "private_share_participant_hash_readback+artifact_sha256_verification",
        safetyGate: "--allow-artifact-action",
        privacyBoundary: "artifact_contains_hashes_counts_booleans_and_permission_enums_only",
        reason: "The CLI can export the same privacy-safe participant/access metadata after an explicit artifact-action gate without writing participant names, handles, note title, note body, or share links."
      ),
      CollaborationWorkflowAuditItem(
        family: "send_copy_share_sheet",
        guideSection: "Share a note",
        status: "delegated",
        appleCapability: "send_static_copy_of_note",
        command: "Notes.app share sheet; use export commands for CLI artifacts",
        mechanism: "delegated_system_share_sheet",
        requiredImplementation: "macos_share_sheet_or_capability_specific_export_route",
        requiredVerifier: "delegated_share_sheet_accounting",
        safetyGate: "future --allow-external-dispatch if a CLI share route is accepted",
        privacyBoundary: "no_backend_calls",
        reason: "Sending a static copy through Messages, Mail, AirDrop, or extensions belongs to the system share surface."
      ),
      CollaborationWorkflowAuditItem(
        family: "invitation_delivery_route",
        guideSection: "Share a note / Share a folder",
        status: "delegated",
        appleCapability: "deliver_collaboration_invitation",
        command: "Messages/Mail/AirDrop/Contacts share UI",
        mechanism: "delegated_system_share_destination",
        requiredImplementation: "macos_share_destination_route",
        requiredVerifier: "delegated_invitation_delivery_accounting",
        safetyGate: "future --allow-external-dispatch if a CLI invitation route is accepted",
        privacyBoundary: "no_backend_calls",
        reason: "Recipient picking and delivery are user-facing system/app surfaces even when collaboration state mutation is Notes-owned."
      ),
      CollaborationWorkflowAuditItem(
        family: "open_shared_link",
        guideSection: "Collaborate with shared notes and folders",
        status: "delegated",
        appleCapability: "open_shared_note_or_folder_link",
        command: "shared link / iCloud / Apple Account verification surface",
        mechanism: "delegated_icloud_link_open_surface",
        requiredImplementation: "icloud_link_dispatch_and_account_verification_route",
        requiredVerifier: "delegated_icloud_link_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Opening invitations depends on iCloud link dispatch and Apple Account verification outside the Notes data writer."
      ),
      CollaborationWorkflowAuditItem(
        family: "realtime_presence_ui",
        guideSection: "Collaborate with shared notes and folders",
        status: "delegated",
        appleCapability: "view_realtime_collaboration_presence",
        command: "Notes.app collaboration UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_realtime_presence_surface",
        requiredVerifier: "delegated_presence_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Live cursors, color-coded presence, and near-real-time UI state are Notes.app UI surfaces, not CLI mutations."
      ),
      CollaborationWorkflowAuditItem(
        family: "view_highlights_ui",
        guideSection: "View highlights for a shared note",
        status: "delegated",
        appleCapability: "show_or_hide_shared_note_highlights",
        command: "Notes.app Show Highlights / Hide Highlights UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_collaboration_highlights_surface",
        requiredVerifier: "delegated_highlight_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The visual highlight overlay and participant-color rendering remain delegated to Notes.app."
      ),
      CollaborationWorkflowAuditItem(
        family: "activity_participant_highlight_ui",
        guideSection: "View activity for a shared note",
        status: "delegated",
        appleCapability: "highlight_changes_from_activity_participant",
        command: "Notes.app Activity view",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_activity_highlight_surface",
        requiredVerifier: "delegated_activity_highlight_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Selecting a participant in Activity view to highlight changed text is an interactive Notes.app display workflow."
      ),
      CollaborationWorkflowAuditItem(
        family: "share_note_collaboration",
        guideSection: "Share a note",
        status: "supported",
        appleCapability: "share_note_for_collaboration",
        command: "state share --id NOTE_ID --target PARTICIPANT_ID --scope read-only|read-write",
        mechanism: "typed_private_notes_framework_share_participant_writer",
        requiredImplementation: "NotesUI ICCollaborationController share creation plus CloudKit share participant lookup/add",
        requiredVerifier: "private_share_state_readback+participant_delta+permission_delta",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_echo_participant_target_or_collaboration_handle",
        reason: "Starting one note collaboration is supported through private Notes share creation, CloudKit participant lookup/add, private share save, and participant/permission readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "share_folder_collaboration",
        guideSection: "Share a folder",
        status: "supported",
        appleCapability: "share_folder_for_collaboration",
        command: "state share-folder --folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write",
        mechanism: "typed_private_notes_framework_folder_share_participant_writer",
        requiredImplementation: "NotesUI ICCollaborationController folder share creation plus CloudKit share participant lookup/add",
        requiredVerifier: "private_folder_share_state_readback+participant_delta+permission_delta",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_echo_folder_or_participant_target",
        reason: "Starting one folder collaboration is supported through private Notes share creation, CloudKit participant lookup/add, private share save, and participant/permission readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "share_access_scope",
        guideSection: "Share a note / Share a folder",
        status: "supported",
        appleCapability: "set_who_can_access_shared_item",
        command: "state share --id NOTE_ID|--folder FOLDER --scope invited-only|anyone-with-link",
        mechanism: "typed_private_notes_framework_share_public_permission_writer",
        requiredImplementation: "NotesShared CKShare.publicPermission mutation plus ICCollaborationController share save",
        requiredVerifier: "private_share_public_permission_readback+privacy_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_share_link_or_participant_handles",
        reason: "Changing one already shared note or folder between invited-only and anyone-with-link access is supported through private share publicPermission mutation, share save, and enum readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "share_permission_scope",
        guideSection: "Share a note / Manage shared notes and folders",
        status: "supported",
        appleCapability: "set_collaboration_read_write_or_view_only_permission",
        command: "state set-permission --id NOTE_ID|--folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write; state folder-permission --folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write",
        mechanism: "typed_private_notes_framework_share_participant_permission_writer",
        requiredImplementation: "NotesShared CKShareParticipant.permission mutation plus ICCollaborationController share save",
        requiredVerifier: "private_permission_readback+participant_hash_accounting",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_echo_participant_target",
        reason: "Changing one existing shared note or folder participant between read-only and read-write is supported through private participant resolution, permission enum mutation, share save, and hash-only readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "allow_participants_to_invite",
        guideSection: "Share a note / Manage shared notes and folders",
        status: "supported",
        appleCapability: "allow_others_to_add_people",
        command: "state allow-invites --id NOTE_ID|--folder FOLDER --enabled true|false",
        mechanism: "typed_private_notes_framework_share_participant_role_writer",
        requiredImplementation: "NotesShared CKShareParticipant.role administrator/private-user mutation plus ICCollaborationController share save",
        requiredVerifier: "private_participant_role_readback+admin_count_accounting",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_collaboration_handles",
        reason: "Changing whether existing collaborators can add people is supported through private participant role mutation, share save, and administrator-count readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "stop_sharing",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "stop_sharing_shared_note_or_folder",
        command: "state stop-sharing --id NOTE_ID|--folder FOLDER",
        mechanism: "typed_private_notes_framework_stop_sharing_writer",
        requiredImplementation: "NotesUI ICCollaborationController.removeShareIfNeededWithOwnedObjectID plus private share absence readback",
        requiredVerifier: "private_share_absence_readback+participant_delta",
        safetyGate: "--allow-destructive-selection + --allow-persistent-action",
        privacyBoundary: "does_not_print_participant_handles",
        reason: "Stopping collaboration for one already shared note or folder is supported through private collaboration controller share removal and share/participant absence readback."
      ),
      CollaborationWorkflowAuditItem(
        family: "invite_more_people",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "invite_more_people_to_shared_note_or_folder",
        command: "state invite --id NOTE_ID|--folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write",
        mechanism: "typed_private_notes_framework_share_participant_writer",
        requiredImplementation: "CloudKit share participant lookup/add plus ICCollaborationController share save",
        requiredVerifier: "private_participant_delta_readback+invited_status_accounting",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_echo_participant_target",
        reason: "Adding one participant to an existing shared note or folder is supported through CloudKit participant lookup/add, private share save, and participant/permission readback verification; delivery destination selection remains delegated."
      ),
      CollaborationWorkflowAuditItem(
        family: "remove_participant",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "remove_participant_access",
        command: "state remove-participant --id NOTE_ID --target PARTICIPANT_ID",
        mechanism: "typed_private_notes_framework_share_participant_removal_writer",
        requiredImplementation: "NotesShared CKShare.removeParticipant plus ICCollaborationController share save",
        requiredVerifier: "private_participant_absence_readback+participant_hash_accounting",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_echo_participant_target",
        reason: "Removing one existing non-owner, non-current-user participant is supported through private participant resolution, CKShare participant removal, share save, and hash/count absence readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "copy_collaboration_link",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "copy_shared_note_or_folder_link",
        command: "state copy-link --id NOTE_ID|--folder FOLDER",
        mechanism: "typed_private_notes_framework_share_url_reader_plus_system_clipboard_writer",
        requiredImplementation: "ICCloudSyncingObject.serverShare.url readback for an already shared note or folder",
        requiredVerifier: "private_collaboration_link_hash_readback+clipboard_sha256_readback+change_count",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_raw_share_link",
        reason: "Copying an existing collaboration link for one already shared note or folder is supported through private share URL readback and hash-only clipboard verification; link creation remains gated and access scope changes are handled by `state share --id NOTE_ID|--folder FOLDER --scope invited-only|anyone-with-link`."
      ),
      CollaborationWorkflowAuditItem(
        family: "collaboration_link_artifact_export",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "export_existing_shared_note_or_folder_link",
        command: "state copy-link --id NOTE_ID|--folder FOLDER --output FILE.txt",
        mechanism: "typed_private_notes_framework_share_url_reader_plus_artifact_writer",
        requiredImplementation: "ICCloudSyncingObject.serverShare.url readback plus explicit raw-link artifact writer",
        requiredVerifier: "private_collaboration_link_hash_readback+artifact_sha256_verification",
        safetyGate: "--allow-artifact-action",
        privacyBoundary: "raw_link_written_only_to_explicit_artifact_not_json_stdout",
        reason: "Exporting an existing collaboration link is supported for one already shared note or folder through private share URL readback and artifact hash verification; JSON output reports only hashes, byte counts, and destination metadata."
      ),
      CollaborationWorkflowAuditItem(
        family: "remove_self",
        guideSection: "Manage shared notes and folders",
        status: "supported",
        appleCapability: "remove_self_from_shared_note_or_folder",
        command: "state remove-self --id NOTE_ID|--folder FOLDER",
        mechanism: "typed_private_notes_framework_current_user_participant_removal_writer",
        requiredImplementation: "NotesShared CKShare.currentUserParticipant resolution plus CKShare.removeParticipant and ICCollaborationController share save",
        requiredVerifier: "private_current_user_participant_absence_readback+participant_hash_accounting",
        safetyGate: "--allow-destructive-selection + --allow-persistent-action",
        privacyBoundary: "does_not_print_account_or_participant_identity",
        reason: "Removing the current user from one already shared note or folder is supported through private current-user participant resolution, share participant removal, share save, and self-absence readback verification."
      ),
      CollaborationWorkflowAuditItem(
        family: "hide_alerts_shared_note",
        guideSection: "Manage notifications",
        status: "supported",
        appleCapability: "hide_alerts_for_shared_note",
        command: "state hide-alerts --id NOTE_ID --enabled true|false",
        mechanism: "typed_private_notes_framework_share_notifier_preference",
        requiredImplementation: "NotesShared.ICShareNotifier.setShouldPreventNotifications:forRecordID:",
        requiredVerifier: "private_shared_note_notification_preference_readback+privacy_hash",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_note_title_or_participant_handles",
        reason: "Per-shared-note Hide Alerts is supported as Notes collaboration preference state, separate from global notification delegation."
      ),
      CollaborationWorkflowAuditItem(
        family: "participant_mentions",
        guideSection: "Collaborate with shared notes and folders",
        status: "supported",
        appleCapability: "mention_participant_in_shared_note",
        command: "state mention --id NOTE_ID --target PARTICIPANT_ID [--text TEXT]",
        mechanism: "typed_private_notes_framework_mention_attachment_writer",
        requiredImplementation: "NotesShared.ICInlineAttachment.newMentionAttachmentWithIdentifier plus ICNote textStorage insertion",
        requiredVerifier: "private_mention_attachment_readback+participant_hash_accounting",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_participant_name_or_mention_text",
        reason: "Creating one semantic participant mention in an already shared editable note is supported through private inline-mention attachment creation, participant metadata resolution, and count/hash readback verification; share invitation and remaining collaboration mutations remain gated."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesCollaborationWorkflowAuditRecord(
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

  private func notesCollaborationWorkflowAuditSummary(
    _ records: [NotesCollaborationWorkflowAuditRecord]
  ) -> NotesCollaborationWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesCollaborationWorkflowAuditSummary(
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

  private func verifyCollaborationWorkflowAudit(
    records: [NotesCollaborationWorkflowAuditRecord],
    summary: NotesCollaborationWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "state_and_activity_reads_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "share_state_read", "shared_folder_state_read", "activity_metadata_read",
            "activity_metadata_artifact_export", "participant_access_metadata_read",
            "participant_access_metadata_artifact_export",
          ]
        )
      ),
      verificationBoolCheck(
        name: "editable_shared_note_mutation_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "share_note_collaboration", "share_folder_collaboration",
            "editable_shared_note_mutation", "share_permission_scope",
            "share_access_scope", "allow_participants_to_invite", "stop_sharing", "remove_participant",
            "invite_more_people", "remove_self", "hide_alerts_shared_note", "participant_mentions",
          ])
      ),
      verificationBoolCheck(
        name: "collaboration_link_copy_and_artifact_supported",
        expected: true,
        actual: supported.isSuperset(of: ["copy_collaboration_link", "collaboration_link_artifact_export"])
      ),
      verificationBoolCheck(
        name: "external_delivery_and_ui_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "send_copy_share_sheet", "invitation_delivery_route", "open_shared_link",
            "realtime_presence_ui", "view_highlights_ui", "activity_participant_highlight_ui",
          ]
        )
      ),
      verificationBoolCheck(
        name: "collaboration_mutations_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "share_note_collaboration", "share_folder_collaboration",
            "invite_more_people",
          ]
        )
      ),
      verificationBoolCheck(
        name: "collaboration_gated_families_empty",
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
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.state.collaboration.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.state.collaboration.audit"),
      checks: checks
    )
  }

  func setSharedNoteAlertsHidden(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.hide-alerts"
    let id = try requiredOption("id", options: options)
    let hidden = try normalizedBoolOption("enabled", options: options)
    let draft = NotesSharedNoteAlertsMutationDraft(noteID: id, hidden: hidden)
    return try mutation(
      operation: operation,
      scopeDigest: sha256Hex(["notes.state.hide-alerts", id].joined(separator: "|")),
      summary: [
        "note_id_sha256": sha256Hex(id),
        "requested_hidden": hidden ? "true" : "false",
        "capability": "shared_note_notification_preference",
      ],
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Modifies one shared note's Hide Alerts notification preference.",
        "Execution requires private shared-note record readback and `--allow-persistent-action`.",
        "Result output is limited to note/record hashes, booleans, and counts.",
      ]
    ) {
      let write = try noteStateMutator().setSharedNoteAlertsHidden(draft)
      let verification = verifySharedNoteAlertsMutation(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes shared-note Hide Alerts verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesSharedNoteAlertsMutationResult(
        operation: operation,
        changed: write.changed,
        noteIDSHA256: sha256Hex(write.noteID),
        requestedHidden: write.requestedHidden,
        beforeHidden: write.beforeHidden,
        afterHidden: write.afterHidden,
        recordIDSHA256: write.recordIDSHA256,
        wasShared: write.wasShared,
        participantCount: write.participantCount,
        verification: verification
      )
    }
  }

  private func verifySharedNoteAlertsMutation(
    _ write: NotesSharedNoteAlertsWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let recordHashReadback = write.recordIDSHA256?.count == 64
    let requestedReadback = write.afterHidden == write.requestedHidden
    let expectedChanged = write.beforeHidden != write.requestedHidden
    let beforeAfterAccounting = write.changed == expectedChanged
      && write.beforeHidden != nil
      && write.afterHidden != nil
    let privacyAccounting = sha256Hex(write.noteID).count == 64
      && recordHashReadback
      && write.participantCount >= 0
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_state_preflight",
        status: write.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "record_id_readback",
        status: recordHashReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: recordHashReadback
      ),
      NotesVerificationCheckRecord(
        name: "requested_alert_preference_readback",
        status: requestedReadback ? "passed" : "failed",
        expectedBool: write.requestedHidden,
        actualBool: write.afterHidden
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: beforeAfterAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: write.changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyAccounting
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_shared_note_alerts_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_notifier_preference_readback+privacy_hash",
      targetIDSHA256: sha256Hex(write.noteID),
      checks: checks
    )
  }

  func setCollaborationAccessScope(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.share"
    try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state share")
    let noteID = options.targetOption("id")
    let folderID = try options.targetOption("folder").map { try folderIdentity(selector: $0).id }
    let targetID = noteID ?? folderID ?? ""
    let targetKind = noteID == nil ? "folder" : "note"
    let accessScope = try normalizedCollaborationAccessScope(options)
    let draft = NotesCollaborationAccessScopeMutationDraft(
      noteID: noteID,
      folderID: folderID,
      accessScopeLabel: accessScope
    )
    let scopeDigest = sha256Hex([operation, targetKind, targetID, accessScope].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "target_kind": targetKind,
        "\(targetKind)_id_sha256": sha256Hex(targetID),
        "requested_access_scope": accessScope,
        "capability": "collaboration_access_scope_mutation",
      ],
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Changes who can access one already shared note or folder.",
        "Execution writes `CKShare.publicPermission` through private collaboration share save.",
        "Result output is limited to target/share hashes, public-permission enum labels, and participant-count readback.",
      ]
    ) {
      let write = try collaborationAccessScopeMutator().setCollaborationAccessScope(draft)
      let verification = verifyCollaborationAccessScopeMutation(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes collaboration access scope verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationAccessScopeMutationResult(
        operation: operation,
        changed: write.changed,
        targetKind: write.targetKind,
        targetIDSHA256: sha256Hex(write.targetID),
        noteIDSHA256: write.noteID.map(sha256Hex),
        folderIDSHA256: write.folderID.map(sha256Hex),
        requestedAccessScopeLabel: write.requestedAccessScopeLabel,
        requestedPublicPermissionValue: write.requestedPublicPermissionValue,
        requestedPublicPermissionLabel: write.requestedPublicPermissionLabel,
        beforeAccessScopeLabel: write.beforeAccessScopeLabel,
        beforePublicPermissionValue: write.beforePublicPermissionValue,
        beforePublicPermissionLabel: write.beforePublicPermissionLabel,
        afterAccessScopeLabel: write.afterAccessScopeLabel,
        afterPublicPermissionValue: write.afterPublicPermissionValue,
        afterPublicPermissionLabel: write.afterPublicPermissionLabel,
        wasShared: write.wasShared,
        participantCount: write.participantCount,
        shareRecordIDSHA256: write.shareRecordIDSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationAccessScopeMutation(
    _ write: NotesCollaborationAccessScopeWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let requestedScopeReadback = write.afterAccessScopeLabel == write.requestedAccessScopeLabel
    let requestedPermissionReadback = write.afterPublicPermissionValue == write.requestedPublicPermissionValue
      && write.afterPublicPermissionLabel == write.requestedPublicPermissionLabel
    let expectedChanged = write.beforePublicPermissionValue != write.requestedPublicPermissionValue
    let beforeAfterAccounting = write.changed == expectedChanged
      && write.beforePublicPermissionValue != nil
      && write.afterPublicPermissionValue != nil
    let implementationCallAccepted = write.backendCalls
      == "CKShare.publicPermission+ICCollaborationController.saveServerShare"
    let privacyHashes = sha256Hex(write.targetID).count == 64
      && (write.shareRecordIDSHA256?.count ?? 64) == 64
      && write.participantCount >= 0
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_preflight",
        status: write.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "private_access_scope_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "requested_access_scope_readback",
        status: requestedScopeReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: requestedScopeReadback
      ),
      NotesVerificationCheckRecord(
        name: "public_permission_enum_readback",
        status: requestedPermissionReadback ? "passed" : "failed",
        expectedLength: write.requestedPublicPermissionValue,
        actualLength: write.afterPublicPermissionValue
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: beforeAfterAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: write.changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_access_scope_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_public_permission_readback+privacy_hash",
      targetIDSHA256: sha256Hex(
        [
          write.targetKind,
          write.targetID,
          write.requestedAccessScopeLabel,
          "\(write.requestedPublicPermissionValue)",
          "\(write.afterPublicPermissionValue ?? -1)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func stopSharing(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.stop-sharing"
    try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state stop-sharing")
    let noteID = options.targetOption("id")
    let folderID = try options.targetOption("folder").map { try folderIdentity(selector: $0).id }
    let targetID = noteID ?? folderID ?? ""
    let targetKind = noteID == nil ? "folder" : "note"
    let draft = NotesCollaborationStopSharingDraft(noteID: noteID, folderID: folderID)
    let scopeDigest = sha256Hex([operation, targetKind, targetID].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "target_kind": targetKind,
        "\(targetKind)_id_sha256": sha256Hex(targetID),
        "capability": "collaboration_stop_sharing",
      ],
      options: options,
      category: .destructiveSelection,
      allowFlags: ["--allow-destructive-selection", "--allow-persistent-action"],
      dryRunNotes: [
        "Stops sharing one already shared note or folder and removes participant access.",
        "Execution calls `ICCollaborationController.removeShareIfNeededWithOwnedObjectID`.",
        "Result output is limited to target/share hashes, participant counts, and share-absence readback.",
      ]
    ) {
      let write = try collaborationStopSharingMutator().stopSharing(draft)
      let verification = verifyCollaborationStopSharing(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes stop-sharing verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationStopSharingResult(
        operation: operation,
        changed: write.changed,
        targetKind: write.targetKind,
        targetIDSHA256: sha256Hex(write.targetID),
        noteIDSHA256: write.noteID.map(sha256Hex),
        folderIDSHA256: write.folderID.map(sha256Hex),
        beforeWasShared: write.beforeWasShared,
        afterWasShared: write.afterWasShared,
        beforeParticipantCount: write.beforeParticipantCount,
        afterParticipantCount: write.afterParticipantCount,
        beforeShareRecordIDSHA256: write.beforeShareRecordIDSHA256,
        afterShareRecordIDSHA256: write.afterShareRecordIDSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationStopSharing(
    _ write: NotesCollaborationStopSharingWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let implementationCallAccepted = write.backendCalls == "ICCollaborationController.removeShareIfNeededWithOwnedObjectID"
    let shareAbsent = write.afterWasShared == false && write.afterShareRecordIDSHA256 == nil
    let participantsRemoved = write.afterParticipantCount == 0
      && write.afterParticipantCount <= write.beforeParticipantCount
    let expectedChanged = write.beforeWasShared && shareAbsent
    let deltaAccounting = write.changed == expectedChanged
    let privacyHashes = sha256Hex(write.targetID).count == 64
      && (write.beforeShareRecordIDSHA256?.count ?? 64) == 64
      && write.afterShareRecordIDSHA256 == nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_preflight",
        status: write.beforeWasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.beforeWasShared
      ),
      NotesVerificationCheckRecord(
        name: "private_stop_sharing_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "share_absence_readback",
        status: shareAbsent ? "passed" : "failed",
        expectedBool: false,
        actualBool: write.afterWasShared
      ),
      NotesVerificationCheckRecord(
        name: "participant_access_removed_readback",
        status: participantsRemoved ? "passed" : "failed",
        expectedLength: 0,
        actualLength: write.afterParticipantCount
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: deltaAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: write.changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_stop_sharing_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_absence_readback+participant_count_accounting",
      targetIDSHA256: sha256Hex(write.targetID),
      checks: checks
    )
  }

  func setCollaborationInvitePolicy(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.allow-invites"
    try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state allow-invites")
    let noteID = options.targetOption("id")
    let folderID = try options.targetOption("folder").map { try folderIdentity(selector: $0).id }
    let targetID = noteID ?? folderID ?? ""
    let targetKind = noteID == nil ? "folder" : "note"
    let enabled = try normalizedBoolOption("enabled", options: options)
    let draft = NotesCollaborationAllowInvitesDraft(noteID: noteID, folderID: folderID, enabled: enabled)
    let scopeDigest = sha256Hex([operation, targetKind, targetID, enabled ? "true" : "false"].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "target_kind": targetKind,
        "\(targetKind)_id_sha256": sha256Hex(targetID),
        "requested_allows_invites": enabled ? "true" : "false",
        "capability": "collaboration_invite_policy_mutation",
      ],
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Changes whether existing collaborators can add people to one already shared note or folder.",
        "Execution writes private `CKShareParticipant.role` values and saves the collaboration share.",
        "Result output is limited to target/share hashes, booleans, participant counts, and verifier checks.",
      ]
    ) {
      let write = try collaborationInvitePolicyMutator().setCollaborationInvitePolicy(draft)
      let verification = verifyCollaborationInvitePolicyMutation(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes collaboration invite policy verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationAllowInvitesResult(
        operation: operation,
        changed: write.changed,
        targetKind: write.targetKind,
        targetIDSHA256: sha256Hex(write.targetID),
        noteIDSHA256: write.noteID.map(sha256Hex),
        folderIDSHA256: write.folderID.map(sha256Hex),
        requestedAllowsInvites: write.requestedAllowsInvites,
        beforeAllowsInvites: write.beforeAllowsInvites,
        afterAllowsInvites: write.afterAllowsInvites,
        participantCount: write.participantCount,
        eligibleParticipantCount: write.eligibleParticipantCount,
        beforeAdministratorCount: write.beforeAdministratorCount,
        afterAdministratorCount: write.afterAdministratorCount,
        shareRecordIDSHA256: write.shareRecordIDSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationInvitePolicyMutation(
    _ write: NotesCollaborationAllowInvitesWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let implementationCallAccepted = write.backendCalls
      == "CKShareParticipant.role+ICCollaborationController.saveServerShare"
    let requestedReadback = write.afterAllowsInvites == write.requestedAllowsInvites
    let expectedChanged = write.beforeAllowsInvites != write.requestedAllowsInvites
    let deltaAccounting = write.changed == expectedChanged
      && write.afterAdministratorCount >= 0
      && write.beforeAdministratorCount >= 0
      && write.afterAdministratorCount <= write.eligibleParticipantCount
      && write.beforeAdministratorCount <= write.eligibleParticipantCount
    let eligibleParticipants = write.eligibleParticipantCount > 0
      && write.participantCount >= write.eligibleParticipantCount
    let privacyHashes = sha256Hex(write.targetID).count == 64
      && (write.shareRecordIDSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_preflight",
        status: write.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "eligible_participant_role_readback",
        status: eligibleParticipants ? "passed" : "failed",
        expectedBool: true,
        actualBool: eligibleParticipants
      ),
      NotesVerificationCheckRecord(
        name: "private_invite_policy_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "requested_invite_policy_readback",
        status: requestedReadback ? "passed" : "failed",
        expectedBool: write.requestedAllowsInvites,
        actualBool: write.afterAllowsInvites
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: deltaAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: write.changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_invite_policy_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_participant_role_readback+privacy_hash",
      targetIDSHA256: sha256Hex(
        [
          write.targetKind,
          write.targetID,
          write.requestedAllowsInvites ? "true" : "false",
          "\(write.afterAdministratorCount)",
          "\(write.eligibleParticipantCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func shareCollaboration(
    options: CLIOptions,
    operation: String,
    createShareIfNeeded: Bool
  ) throws -> CLICommandResult {
    try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: operation)
    let noteID = options.targetOption("id")
    let folderID = try options.targetOption("folder").map { try folderIdentity(selector: $0).id }
    let target = try requiredOption("target", options: options)
    let permission = try normalizedCollaborationPermissionScope(options)
    let targetID = noteID ?? folderID ?? ""
    let targetKind = noteID == nil ? "folder" : "note"
    let capability = createShareIfNeeded ? "collaboration_share_mutation" : "collaboration_participant_invite"
    let draft = NotesCollaborationShareMutationDraft(
      operation: operation,
      noteID: noteID,
      folderID: folderID,
      target: target,
      permissionValue: permission.value,
      permissionLabel: permission.label,
      createShareIfNeeded: createShareIfNeeded
    )
    let scopeDigest = sha256Hex(
      [
        operation,
        targetKind,
        targetID,
        sha256Hex(target),
        permission.label,
        createShareIfNeeded ? "create-share-if-needed" : "existing-share-only",
      ].joined(separator: "|")
    )
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "target_kind": targetKind,
        "\(targetKind)_id_sha256": sha256Hex(targetID),
        "participant_target_sha256": sha256Hex(target),
        "requested_permission": permission.label,
        "capability": capability,
      ],
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        createShareIfNeeded
          ? "Starts collaboration for one note or folder when needed, then adds one participant."
          : "Adds one participant to an already shared note or folder.",
        "Execution resolves the participant through CloudKit share-participant lookup and writes the Notes private collaboration share.",
        "Result output is limited to target, participant, share hashes, permission enum readback, and participant counts.",
      ]
    ) {
      let write = try collaborationSharingMutator().shareCollaboration(draft)
      let verification = verifyCollaborationShareMutation(
        write,
        operation: operation,
        createShareIfNeeded: createShareIfNeeded
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes collaboration share verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationShareMutationResult(
        operation: operation,
        changed: write.changed,
        targetKind: write.targetKind,
        targetIDSHA256: sha256Hex(write.targetID),
        noteIDSHA256: write.noteID.map(sha256Hex),
        folderIDSHA256: write.folderID.map(sha256Hex),
        targetSHA256: write.targetSHA256,
        targetParticipantIDSHA256: write.targetParticipantIDSHA256,
        targetUserRecordNameSHA256: write.targetUserRecordNameSHA256,
        requestedPermissionValue: write.requestedPermissionValue,
        requestedPermissionLabel: write.requestedPermissionLabel,
        beforeWasShared: write.beforeWasShared,
        afterWasShared: write.afterWasShared,
        beforeParticipantCount: write.beforeParticipantCount,
        afterParticipantCount: write.afterParticipantCount,
        targetPresentBefore: write.targetPresentBefore,
        targetPresentAfter: write.targetPresentAfter,
        beforePermissionValue: write.beforePermissionValue,
        beforePermissionLabel: write.beforePermissionLabel,
        afterPermissionValue: write.afterPermissionValue,
        afterPermissionLabel: write.afterPermissionLabel,
        shareRecordIDSHA256: write.shareRecordIDSHA256,
        shareURLSHA256: write.shareURLSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationShareMutation(
    _ write: NotesCollaborationShareWriteResult,
    operation: String,
    createShareIfNeeded: Bool
  ) -> NotesMutationVerificationReport {
    let implementationCallAccepted = write.backendCalls
      == "CKContainer.fetchShareParticipant+CKShare.addParticipant+ICCollaborationController.saveServerShare"
    let shareStateReadback = write.afterWasShared && (createShareIfNeeded || write.beforeWasShared)
    let participantDelta = write.targetPresentAfter
      && write.afterParticipantCount >= write.beforeParticipantCount
      && (write.targetPresentBefore || write.afterParticipantCount > write.beforeParticipantCount)
    let permissionReadback = write.afterPermissionValue == write.requestedPermissionValue
      && write.afterPermissionLabel == write.requestedPermissionLabel
    let expectedChanged = (write.beforeWasShared == false && write.afterWasShared)
      || (write.targetPresentBefore == false && write.targetPresentAfter)
      || write.beforePermissionValue != write.requestedPermissionValue
    let deltaAccounting = write.changed == expectedChanged
    let privacyHashes = sha256Hex(write.targetID).count == 64
      && write.targetSHA256.count == 64
      && write.targetParticipantIDSHA256.count == 64
      && (write.targetUserRecordNameSHA256?.count ?? 64) == 64
      && (write.shareRecordIDSHA256?.count ?? 64) == 64
      && (write.shareURLSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: createShareIfNeeded ? "share_target_preflight" : "existing_share_preflight",
        status: shareStateReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: shareStateReadback
      ),
      NotesVerificationCheckRecord(
        name: "private_participant_lookup_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "participant_delta_readback",
        status: participantDelta ? "passed" : "failed",
        expectedBool: true,
        actualBool: participantDelta
      ),
      NotesVerificationCheckRecord(
        name: "permission_enum_readback",
        status: permissionReadback ? "passed" : "failed",
        expectedLength: write.requestedPermissionValue,
        actualLength: write.afterPermissionValue
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: deltaAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: write.changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_share_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_participant_lookup+share_readback+privacy_hash",
      targetIDSHA256: sha256Hex(
        [
          write.targetKind,
          write.targetID,
          write.targetParticipantIDSHA256,
          write.requestedPermissionLabel,
          "\(write.afterParticipantCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func removeSelfFromCollaboration(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.remove-self"
    try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state remove-self")
    let noteID = options.targetOption("id")
    let folderID = try options.targetOption("folder").map { try folderIdentity(selector: $0).id }
    let targetID = noteID ?? folderID ?? ""
    let targetKind = noteID == nil ? "folder" : "note"
    let draft = NotesCollaborationSelfRemovalDraft(noteID: noteID, folderID: folderID)
    let scopeDigest = sha256Hex([operation, targetKind, targetID].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "target_kind": targetKind,
        "\(targetKind)_id_sha256": sha256Hex(targetID),
        "capability": "collaboration_self_removal",
      ],
      options: options,
      category: .destructiveSelection,
      allowFlags: ["--allow-destructive-selection", "--allow-persistent-action"],
      dryRunNotes: [
        "Removes the current user from one already shared note or folder.",
        "Execution resolves the current user participant and calls `CKShare.removeParticipant`.",
        "Result output is limited to target/share hashes, current-user participant hash, counts, and verifier checks.",
      ]
    ) {
      let write = try collaborationSelfRemovalMutator().removeSelfFromCollaboration(draft)
      let verification = verifyCollaborationSelfRemoval(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes self-removal verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationSelfRemovalResult(
        operation: operation,
        changed: write.changed,
        targetKind: write.targetKind,
        targetIDSHA256: sha256Hex(write.targetID),
        noteIDSHA256: write.noteID.map(sha256Hex),
        folderIDSHA256: write.folderID.map(sha256Hex),
        beforeWasShared: write.beforeWasShared,
        beforeCurrentUserPresent: write.beforeCurrentUserPresent,
        afterCurrentUserPresent: write.afterCurrentUserPresent,
        currentUserParticipantIDSHA256: write.currentUserParticipantIDSHA256,
        currentUserRecordNameSHA256: write.currentUserRecordNameSHA256,
        beforeParticipantCount: write.beforeParticipantCount,
        afterParticipantCount: write.afterParticipantCount,
        shareRecordIDSHA256: write.shareRecordIDSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationSelfRemoval(
    _ write: NotesCollaborationSelfRemovalWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let targetResolved = write.beforeWasShared
      && write.beforeCurrentUserPresent
      && write.currentUserParticipantIDSHA256.count == 64
    let selfAbsent = write.afterCurrentUserPresent == false
    let expectedChanged = write.beforeCurrentUserPresent && selfAbsent
      && write.afterParticipantCount < write.beforeParticipantCount
    let deltaAccounting = write.changed == expectedChanged
      && write.afterParticipantCount == max(0, write.beforeParticipantCount - 1)
    let implementationCallAccepted = write.backendCalls
      == "CKShare.removeParticipant(currentUserParticipant)+ICCollaborationController.saveServerShare"
    let privacyHashes = sha256Hex(write.targetID).count == 64
      && write.currentUserParticipantIDSHA256.count == 64
      && (write.currentUserRecordNameSHA256?.count ?? 64) == 64
      && (write.shareRecordIDSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_target_preflight",
        status: write.beforeWasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.beforeWasShared
      ),
      NotesVerificationCheckRecord(
        name: "current_user_participant_resolved",
        status: targetResolved ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetResolved
      ),
      NotesVerificationCheckRecord(
        name: "private_self_removal_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "current_user_absence_readback",
        status: selfAbsent ? "passed" : "failed",
        expectedBool: false,
        actualBool: write.afterCurrentUserPresent
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: deltaAccounting ? "passed" : "failed",
        expectedLength: write.beforeParticipantCount - 1,
        actualLength: write.afterParticipantCount
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_self_removal_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_current_user_participant_absence_readback+participant_hash_accounting",
      targetIDSHA256: sha256Hex(
        [
          write.targetKind,
          write.targetID,
          write.currentUserParticipantIDSHA256,
          "\(write.beforeParticipantCount)",
          "\(write.afterParticipantCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func removeCollaborationParticipant(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.remove-participant"
    let id = try requiredOption("id", options: options)
    let target = try requiredOption("target", options: options)
    let draft = NotesCollaborationParticipantRemovalDraft(noteID: id, target: target)
    let scopeDigest = sha256Hex(
      [
        operation,
        id,
        sha256Hex(target),
      ].joined(separator: "|")
    )
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "note_id_sha256": sha256Hex(id),
        "target_sha256": sha256Hex(target),
        "capability": "collaboration_participant_removal",
      ],
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Removes one existing non-owner, non-current-user participant from an already shared note.",
        "Execution resolves the participant through private share metadata and calls `CKShare.removeParticipant`.",
        "Result output is limited to note, target, participant, share hashes and participant-count readback.",
      ]
    ) {
      let write = try collaborationParticipantMutator().removeCollaborationParticipant(draft)
      let verification = verifyCollaborationParticipantRemoval(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes participant removal verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationParticipantRemovalResult(
        operation: operation,
        changed: write.changed,
        noteIDSHA256: sha256Hex(write.noteID),
        targetSHA256: write.targetSHA256,
        targetParticipantIDSHA256: write.targetParticipantIDSHA256,
        targetUserRecordNameSHA256: write.targetUserRecordNameSHA256,
        beforeParticipantCount: write.beforeParticipantCount,
        afterParticipantCount: write.afterParticipantCount,
        targetPresentAfter: write.targetPresentAfter,
        wasShared: write.wasShared,
        shareRecordIDSHA256: write.shareRecordIDSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationParticipantRemoval(
    _ write: NotesCollaborationParticipantRemovalWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let targetResolved = write.beforeParticipantCount > 0
      && write.targetParticipantIDSHA256.count == 64
    let removedReadback = write.targetPresentAfter == false
    let expectedChanged = write.afterParticipantCount < write.beforeParticipantCount
    let deltaAccounting = write.changed == expectedChanged
      && write.afterParticipantCount == max(0, write.beforeParticipantCount - 1)
    let implementationCallAccepted = write.backendCalls
      == "CKShare.removeParticipant+ICCollaborationController.saveServerShare"
    let privacyHashes = sha256Hex(write.noteID).count == 64
      && write.targetSHA256.count == 64
      && write.targetParticipantIDSHA256.count == 64
      && (write.targetUserRecordNameSHA256?.count ?? 64) == 64
      && (write.shareRecordIDSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_preflight",
        status: write.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "participant_target_resolved",
        status: targetResolved ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetResolved
      ),
      NotesVerificationCheckRecord(
        name: "private_participant_removal_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "target_participant_absence_readback",
        status: removedReadback ? "passed" : "failed",
        expectedBool: false,
        actualBool: write.targetPresentAfter
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: deltaAccounting ? "passed" : "failed",
        expectedLength: write.beforeParticipantCount - 1,
        actualLength: write.afterParticipantCount
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_participant_removal_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_participant_absence_readback+participant_hash_accounting",
      targetIDSHA256: sha256Hex(
        [
          write.noteID,
          write.targetParticipantIDSHA256,
          "\(write.beforeParticipantCount)",
          "\(write.afterParticipantCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func setCollaborationParticipantPermission(
    options: CLIOptions,
    operation: String = "notes.state.set-permission",
    commandName: String = "state set-permission"
  ) throws -> CLICommandResult {
    try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: commandName)
    let noteID = options.targetOption("id")
    let folderID = try options.targetOption("folder").map { try folderIdentity(selector: $0).id }
    let targetID = noteID ?? folderID ?? ""
    let targetKind = noteID == nil ? "folder" : "note"
    let target = try requiredOption("target", options: options)
    let permission = try normalizedCollaborationPermissionScope(options)
    let draft = NotesCollaborationPermissionMutationDraft(
      operation: operation,
      noteID: noteID,
      folderID: folderID,
      target: target,
      permissionValue: permission.value,
      permissionLabel: permission.label
    )
    let scopeDigest = sha256Hex(
      [
        operation,
        targetKind,
        targetID,
        sha256Hex(target),
        permission.label,
      ].joined(separator: "|")
    )
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: [
        "target_kind": targetKind,
        "\(targetKind)_id_sha256": sha256Hex(targetID),
        "target_sha256": sha256Hex(target),
        "requested_permission": permission.label,
        "capability": "collaboration_permission_mutation",
      ],
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Changes one existing shared note or folder participant permission.",
        "Execution resolves the participant through private share metadata and writes `CKShareParticipant.permission`.",
        "Result output is limited to target, participant, share hashes and permission enum readback.",
      ]
    ) {
      let write = try collaborationPermissionMutator().setCollaborationParticipantPermission(draft)
      let verification = verifyCollaborationPermissionMutation(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes collaboration permission verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationPermissionMutationResult(
        operation: operation,
        changed: write.changed,
        targetKind: write.targetKind,
        targetIDSHA256: sha256Hex(write.targetID),
        noteIDSHA256: write.noteID.map(sha256Hex),
        folderIDSHA256: write.folderID.map(sha256Hex),
        targetSHA256: write.targetSHA256,
        targetParticipantIDSHA256: write.targetParticipantIDSHA256,
        targetUserRecordNameSHA256: write.targetUserRecordNameSHA256,
        requestedPermissionValue: write.requestedPermissionValue,
        requestedPermissionLabel: write.requestedPermissionLabel,
        beforePermissionValue: write.beforePermissionValue,
        beforePermissionLabel: write.beforePermissionLabel,
        afterPermissionValue: write.afterPermissionValue,
        afterPermissionLabel: write.afterPermissionLabel,
        wasShared: write.wasShared,
        participantCount: write.participantCount,
        shareRecordIDSHA256: write.shareRecordIDSHA256,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func normalizedCollaborationPermissionScope(_ options: CLIOptions) throws -> (value: Int, label: String) {
    let rawScope = try requiredOption("scope", options: options)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
    switch rawScope {
    case "read-only", "readonly", "view-only", "view":
      return (2, "read-only")
    case "read-write", "readwrite", "edit", "editable":
      return (3, "read-write")
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes collaboration permission scope.",
        details: [
          "scope_sha256": sha256Hex(rawScope),
          "allowed_scopes": "read-only,read-write",
        ]
      )
    }
  }

  private func normalizedCollaborationAccessScope(_ options: CLIOptions) throws -> String {
    let rawScope = try requiredOption("scope", options: options)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
    switch rawScope {
    case "invited-only", "invite-only", "only-invited", "private":
      return "invited-only"
    case "anyone-with-link", "anyone", "link", "public":
      return "anyone-with-link"
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes collaboration access scope.",
        details: [
          "scope_sha256": sha256Hex(rawScope),
          "allowed_scopes": "invited-only,anyone-with-link",
        ]
      )
    }
  }

  private func verifyCollaborationPermissionMutation(
    _ write: NotesCollaborationPermissionWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let targetResolved = write.participantCount > 0
      && write.targetParticipantIDSHA256.count == 64
    let permissionReadback = write.afterPermissionValue == write.requestedPermissionValue
      && write.afterPermissionLabel == write.requestedPermissionLabel
    let expectedChanged = write.beforePermissionValue != write.requestedPermissionValue
    let deltaAccounting = write.changed == expectedChanged
      && write.beforePermissionValue != nil
      && write.afterPermissionValue != nil
    let implementationCallAccepted = write.backendCalls
      == "CKShareParticipant.permission+ICCollaborationController.saveServerShare"
    let privacyHashes = sha256Hex(write.targetID).count == 64
      && write.targetSHA256.count == 64
      && write.targetParticipantIDSHA256.count == 64
      && (write.targetUserRecordNameSHA256?.count ?? 64) == 64
      && (write.shareRecordIDSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_preflight",
        status: write.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "participant_target_resolved",
        status: targetResolved ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetResolved
      ),
      NotesVerificationCheckRecord(
        name: "private_permission_writer_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "requested_permission_readback",
        status: permissionReadback ? "passed" : "failed",
        expectedLength: write.requestedPermissionValue,
        actualLength: write.afterPermissionValue
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: deltaAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: write.changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_permission_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_participant_permission_readback+participant_hash_accounting",
      targetIDSHA256: sha256Hex(
        [
          write.targetKind,
          write.targetID,
          write.targetParticipantIDSHA256,
          "\(write.requestedPermissionValue)",
          "\(write.afterPermissionValue ?? -1)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func insertParticipantMention(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.mention"
    let id = try requiredOption("id", options: options)
    let targetParticipant = try requiredOption("target", options: options)
    let rawText = options.targetOption("text")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let text = rawText?.isEmpty == false ? rawText : nil
    let draft = NotesCollaborationMentionDraft(noteID: id, target: targetParticipant, text: text)
    var summary = [
      "note_id_sha256": sha256Hex(id),
      "target_sha256": sha256Hex(targetParticipant),
      "capability": "semantic_participant_mention",
    ]
    if let text {
      summary["mention_text_sha256"] = sha256Hex(text)
      summary["mention_text_byte_count"] = "\(text.utf8.count)"
    } else {
      summary["mention_text_source"] = "participant_metadata_fallback"
    }
    let scopeDigest = sha256Hex(
      [
        operation,
        id,
        sha256Hex(targetParticipant),
        text.map(sha256Hex) ?? "participant_metadata_fallback",
      ].joined(separator: "|")
    )

    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: summary,
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Creates one semantic participant mention attachment in an already shared editable note.",
        "Execution resolves an existing participant through private share metadata and inserts an `ICInlineAttachment` mention.",
        "Result output is limited to note, participant, target, text, and attachment hashes plus counts.",
      ]
    ) {
      let write = try collaborationMentionMutator().insertParticipantMention(draft)
      let verification = verifyCollaborationMentionMutation(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes participant mention verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesCollaborationMentionResult(
        operation: operation,
        changed: true,
        noteIDSHA256: sha256Hex(write.noteID),
        targetSHA256: write.targetSHA256,
        targetParticipantIDSHA256: write.targetParticipantIDSHA256,
        targetUserRecordNameSHA256: write.targetUserRecordNameSHA256,
        mentionTextSHA256: write.mentionTextSHA256,
        mentionTextByteCount: write.mentionTextByteCount,
        beforeMentionCount: write.beforeMentionCount,
        afterMentionCount: write.afterMentionCount,
        targetBeforeMentionCount: write.targetBeforeMentionCount,
        targetAfterMentionCount: write.targetAfterMentionCount,
        insertedAttachmentIDSHA256: write.insertedAttachmentIDSHA256,
        insertedIdentifierSHA256: write.insertedIdentifierSHA256,
        wasShared: write.wasShared,
        participantCount: write.participantCount,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyCollaborationMentionMutation(
    _ write: NotesCollaborationMentionWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let mentionDelta = write.afterMentionCount == write.beforeMentionCount + 1
    let targetDelta = write.targetAfterMentionCount == write.targetBeforeMentionCount + 1
    let privacyHashes = sha256Hex(write.noteID).count == 64
      && write.targetSHA256.count == 64
      && write.targetParticipantIDSHA256.count == 64
      && write.targetUserRecordNameSHA256.count == 64
      && write.mentionTextSHA256.count == 64
      && (write.insertedAttachmentIDSHA256?.count ?? 64) == 64
      && (write.insertedIdentifierSHA256?.count ?? 64) == 64
    let textAccounting = write.mentionTextByteCount > 0
    let implementationCallAccepted = write.backendCalls
      == "ICInlineAttachment.newMentionAttachmentWithIdentifier+ICNote.textStorage"
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_note_preflight",
        status: write.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "participant_target_resolved",
        status: write.participantCount > 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.participantCount > 0
      ),
      NotesVerificationCheckRecord(
        name: "private_mention_attachment_implementation",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "mention_count_delta",
        status: mentionDelta ? "passed" : "failed",
        expectedLength: write.beforeMentionCount + 1,
        actualLength: write.afterMentionCount
      ),
      NotesVerificationCheckRecord(
        name: "target_mention_count_delta",
        status: targetDelta ? "passed" : "failed",
        expectedLength: write.targetBeforeMentionCount + 1,
        actualLength: write.targetAfterMentionCount
      ),
      NotesVerificationCheckRecord(
        name: "mention_text_accounting",
        status: textAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: textAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyHashes ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashes
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_mention_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_mention_attachment_readback+participant_hash_accounting",
      targetIDSHA256: sha256Hex(
        [
          write.noteID,
          write.targetParticipantIDSHA256,
          write.targetUserRecordNameSHA256,
          write.mentionTextSHA256,
          "\(write.afterMentionCount)",
          "\(write.targetAfterMentionCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func copyCollaborationLink(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.copy-link"
    let destinationPath = options.targetOption("output").map(standardizedAbsolutePath(_:))
    if let destinationPath {
      try validateNotesCollaborationLinkExportDestination(destinationPath)
    }

    let draft = NotesCollaborationLinkDraft(
      noteID: options.targetOption("id"),
      folderID: options.targetOption("folder")
    )
    let targetID = draft.targetID
    var summary = [
      "target_kind": draft.targetKind,
      "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
      "destination": destinationPath == nil ? "clipboard" : "artifact",
      "capability": "collaboration_link_clipboard_copy",
    ]
    if let destinationPath {
      summary["capability"] = "collaboration_link_artifact_export"
      summary["output_path_sha256"] = sha256Hex(destinationPath)
    }
    let scopeDigest = sha256Hex(
      [operation, draft.targetKind, targetID, destinationPath ?? "clipboard"].joined(separator: "|"))

    if options.dryRun {
      try validateDryRunOptions(options)
      let artifactOutput = destinationPath != nil
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: artifactOutput ? .artifactAction : .persistentAction,
          allowFlags: [artifactOutput ? "--allow-artifact-action" : "--allow-persistent-action"],
          notes: artifactOutput
            ? [
              "Exports an existing Notes collaboration link for one already shared note or folder to an explicit `.txt` artifact.",
              "Execution reads private share URL metadata and writes the raw link only to the requested file; JSON output never prints the raw link.",
            ]
            : [
              "Copies an existing Notes collaboration link for one already shared note or folder to the system clipboard.",
              "Execution reads private share URL metadata and writes pasteboard state; JSON output never prints the raw link.",
            ]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    if let destinationPath {
      try CLISafety.requireFlag(
        "allow-artifact-action",
        in: options,
        category: .artifactAction,
        message: "Notes collaboration link export writes a filesystem artifact and requires `--allow-artifact-action`."
      )

      let source = try collaborationLinkReader().readCollaborationLink(draft)
      let artifactData = Data(source.urlString.utf8)
      let artifactSHA256 = sha256Hex(artifactData)
      try writeNotesCollaborationLinkExport(artifactData, to: destinationPath)
      let verification = try verifyCollaborationLinkArtifactExport(
        draft: draft,
        source: source,
        destinationPath: destinationPath,
        expectedData: artifactData,
        expectedSHA256: artifactSHA256,
        operation: operation
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes collaboration link artifact export verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return try result(
        NotesCollaborationLinkCopyResult(
          operation: operation,
          changed: true,
          destination: "artifact",
          targetKind: source.targetKind,
          targetIDSHA256: sha256Hex(source.targetID),
          urlSHA256: source.urlSHA256,
          urlByteCount: source.urlByteCount,
          shareRecordIDSHA256: source.shareRecordIDSHA256,
          ownerRecordNameSHA256: source.ownerRecordNameSHA256,
          participantCount: source.participantCount,
          clipboardChangeCount: 0,
          artifact: NotesCollaborationArtifactRecord(
            destinationPath: destinationPath,
            byteCount: artifactData.count,
            sha256: artifactSHA256,
            contentKind: "raw_collaboration_link"
          ),
          verification: verification
        ),
        human: "\(operation) executed",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-persistent-action",
      in: options,
      category: .persistentAction,
      message: "Notes collaboration link copy writes system clipboard state and requires `--allow-persistent-action`."
    )

    let source = try collaborationLinkReader().readCollaborationLink(draft)
    let writeRecord = try clipboardWriter.writeString(source.urlString)
    let clipboardText = try clipboardWriter.readString()
    let verification = verifyCollaborationLinkClipboardCopy(
      source: source,
      clipboardText: clipboardText,
      clipboardChangeCount: writeRecord.changeCount,
      operation: operation
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes collaboration link clipboard copy verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try result(
      NotesCollaborationLinkCopyResult(
        operation: operation,
        changed: true,
        destination: "clipboard",
        targetKind: source.targetKind,
        targetIDSHA256: sha256Hex(source.targetID),
        urlSHA256: source.urlSHA256,
        urlByteCount: source.urlByteCount,
        shareRecordIDSHA256: source.shareRecordIDSHA256,
        ownerRecordNameSHA256: source.ownerRecordNameSHA256,
        participantCount: source.participantCount,
        clipboardChangeCount: writeRecord.changeCount,
        verification: verification
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func verifyCollaborationLinkArtifactExport(
    draft: NotesCollaborationLinkDraft,
    source: NotesCollaborationLinkReadResult,
    destinationPath: String,
    expectedData: Data,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let fileText = String(data: fileData, encoding: .utf8)
    let actualSHA256 = sha256Hex(fileData)
    let readback = try collaborationLinkReader().readCollaborationLink(draft)
    let privateURLReadback = source.urlSHA256.count == 64 && source.urlByteCount > 0
      && !source.urlString.isEmpty
    let artifactTextReadback = fileText == source.urlString
    let artifactByteCountMatches = fileData.count == expectedData.count
    let artifactHashMatches = actualSHA256 == expectedSHA256 && actualSHA256 == source.urlSHA256
    let sourceStable = readback.urlSHA256 == source.urlSHA256
      && readback.urlByteCount == source.urlByteCount
      && readback.targetKind == source.targetKind
      && readback.wasShared == source.wasShared
    let privacyAccounting = sha256Hex(source.targetID).count == 64
      && source.urlSHA256.count == 64
      && (source.shareRecordIDSHA256?.count ?? 64) == 64
      && (source.ownerRecordNameSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_state_preflight",
        status: source.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "private_share_url_readback",
        status: privateURLReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: privateURLReadback
      ),
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "artifact_text_readback",
        status: artifactTextReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: artifactTextReadback
      ),
      NotesVerificationCheckRecord(
        name: "artifact_byte_count",
        status: artifactByteCountMatches ? "passed" : "failed",
        expectedLength: expectedData.count,
        actualLength: fileData.count
      ),
      NotesVerificationCheckRecord(
        name: "artifact_sha256",
        status: artifactHashMatches ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
      ),
      verificationBoolCheck(
        name: "collaboration_link_readback_stable",
        expected: true,
        actual: sourceStable
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyAccounting
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_link_artifact_export_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_url_readback+artifact_hash+privacy_hash",
      targetIDSHA256: sha256Hex(
        [
          source.targetKind,
          source.targetID,
          destination.path,
          source.urlSHA256,
          "\(source.urlByteCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  private func verifyCollaborationLinkClipboardCopy(
    source: NotesCollaborationLinkReadResult,
    clipboardText: String?,
    clipboardChangeCount: Int,
    operation: String
  ) -> NotesMutationVerificationReport {
    let clipboardData = Data((clipboardText ?? "").utf8)
    let clipboardHash = sha256Hex(clipboardData)
    let privateURLReadback = source.urlSHA256.count == 64 && source.urlByteCount > 0 && !source.urlString.isEmpty
    let clipboardReadback = clipboardText == source.urlString
    let clipboardHashMatches = clipboardHash == source.urlSHA256
    let clipboardByteCountMatches = clipboardData.count == source.urlByteCount
    let privacyAccounting = sha256Hex(source.targetID).count == 64
      && source.urlSHA256.count == 64
      && (source.shareRecordIDSHA256?.count ?? 64) == 64
      && (source.ownerRecordNameSHA256?.count ?? 64) == 64
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_state_preflight",
        status: source.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "private_share_url_readback",
        status: privateURLReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: privateURLReadback
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_text_readback",
        status: clipboardReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: clipboardReadback
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_url_sha256",
        status: clipboardHashMatches ? "passed" : "failed",
        expectedSHA256: source.urlSHA256,
        actualSHA256: clipboardHash
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_byte_count",
        status: clipboardByteCountMatches ? "passed" : "failed",
        expectedLength: source.urlByteCount,
        actualLength: clipboardData.count
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_change_count",
        status: clipboardChangeCount > 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: clipboardChangeCount > 0
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: privacyAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyAccounting
      ),
    ]
    let targetFields = [
      source.targetKind,
      source.targetID,
      "clipboard",
      source.urlSHA256,
      "\(source.urlByteCount)",
      "\(clipboardChangeCount)",
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_link_clipboard_copy_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_url_readback+system_clipboard_readback+privacy_hash",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  func readCollaborationParticipants(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.participants"
    let destinationPath = options.targetOption("output").map(standardizedAbsolutePath(_:))
    if let destinationPath {
      try validateNotesCollaborationParticipantsExportDestination(destinationPath)
    } else {
      try validateReadOnly(options)
    }
    let draft = NotesCollaborationParticipantsDraft(
      noteID: options.targetOption("id"),
      folderID: options.targetOption("folder")
    )
    let read = try collaborationParticipantsReader().readCollaborationParticipants(draft)
    let artifactData = try Data(CLIJSON.encodeString(read).utf8)
    let artifactSHA256 = sha256Hex(artifactData)

    if let destinationPath {
      let summary = [
        "target_kind": read.targetKind,
        "\(read.targetKind)_id_sha256": read.targetIDSHA256,
        "destination": "artifact",
        "output_path_sha256": sha256Hex(destinationPath),
        "participant_count": "\(read.participantCount)",
        "returned_participant_count": "\(read.returnedParticipantCount)",
        "participant_identity_set_sha256": read.participantIdentitySetSHA256,
        "capability": "collaboration_participant_metadata_artifact_export",
      ]
      if options.dryRun {
        try validateDryRunOptions(options)
        return try result(
          CLISafety.dryRun(
            target: target,
            operation: operation,
            summary: summary,
            scope: sha256Hex(
              [
                operation,
                read.targetKind,
                read.targetIDSHA256,
                destinationPath,
                artifactSHA256,
              ].joined(separator: "|")
            ),
            category: .artifactAction,
            allowFlags: ["--allow-artifact-action"],
            notes: [
              "Exports privacy-safe collaboration participant/access metadata for one already shared note or folder.",
              "Artifact contains hashes, counts, booleans, and permission enums; it does not contain participant names, handles, share links, note title, or note body.",
            ]
          ),
          human: "dry-run: \(operation)",
          options: options
        )
      }

      try CLISafety.requireFlag(
        "allow-artifact-action",
        in: options,
        category: .artifactAction,
        message: "Notes collaboration participant metadata export writes a filesystem artifact and requires `--allow-artifact-action`."
      )
      try writeNotesCollaborationParticipantsExport(artifactData, to: destinationPath)
      let verification = try verifyCollaborationParticipantsExport(
        draft: draft,
        read: read,
        destinationPath: destinationPath,
        expectedData: artifactData,
        expectedSHA256: artifactSHA256,
        operation: operation
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes collaboration participant metadata export verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return try result(
        NotesCollaborationParticipantsResponse(
          operation: operation,
          changed: true,
          read: read,
          artifact: NotesCollaborationArtifactRecord(
            destinationPath: destinationPath,
            byteCount: artifactData.count,
            sha256: artifactSHA256,
            contentKind: "collaboration_participant_metadata_json"
          ),
          verification: verification
        ),
        human: "\(operation) executed",
        options: options
      )
    }

    let verification = verifyCollaborationParticipantsRead(read, operation: operation)
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes collaboration participant metadata verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try result(
      NotesCollaborationParticipantsResponse(
        operation: operation,
        changed: false,
        read: read,
        verification: verification
      ),
      human: [
        "target_kind: \(read.targetKind)",
        "shared: \(read.wasShared)",
        "participants: \(read.returnedParticipantCount)",
      ].joined(separator: "\n"),
      options: options
    )
  }

  private func verifyCollaborationParticipantsExport(
    draft: NotesCollaborationParticipantsDraft,
    read: NotesCollaborationParticipantsReadResult,
    destinationPath: String,
    expectedData: Data,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let decoded = try? JSONDecoder().decode(NotesCollaborationParticipantsReadResult.self, from: fileData)
    let readback = try collaborationParticipantsReader().readCollaborationParticipants(draft)
    var checks = verifyCollaborationParticipantsRead(read, operation: operation).checks
    checks += [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "artifact_byte_count",
        status: fileData.count == expectedData.count ? "passed" : "failed",
        expectedLength: expectedData.count,
        actualLength: fileData.count
      ),
      NotesVerificationCheckRecord(
        name: "artifact_sha256",
        status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
      ),
      verificationBoolCheck(
        name: "json_artifact_readable",
        expected: true,
        actual: decoded != nil
      ),
      verificationBoolCheck(
        name: "artifact_metadata_matches_readback",
        expected: true,
        actual: decoded?.targetKind == read.targetKind
          && decoded?.targetIDSHA256 == read.targetIDSHA256
          && decoded?.participantCount == read.participantCount
          && decoded?.returnedParticipantCount == read.returnedParticipantCount
          && decoded?.participantIdentitySetSHA256 == read.participantIdentitySetSHA256
      ),
      verificationBoolCheck(
        name: "participant_readback_stable",
        expected: true,
        actual: readback.targetKind == read.targetKind
          && readback.targetIDSHA256 == read.targetIDSHA256
          && readback.participantCount == read.participantCount
          && readback.returnedParticipantCount == read.returnedParticipantCount
          && readback.participantIdentitySetSHA256 == read.participantIdentitySetSHA256
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_participants_artifact_export_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_share_participant_readback+artifact_hash+privacy_hash",
      targetIDSHA256: sha256Hex(
        [
          read.targetKind,
          read.targetIDSHA256,
          destination.path,
          read.participantIdentitySetSHA256,
          "\(read.returnedParticipantCount)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  private func verifyCollaborationParticipantsRead(
    _ read: NotesCollaborationParticipantsReadResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let participantHashes = read.participants.map(\.participantIDSHA256).sorted()
    let expectedIdentitySetHash = sha256Hex(participantHashes.joined(separator: "\n"))
    let hashesArePrivacySafe = read.targetIDSHA256.count == 64
      && read.participantIdentitySetSHA256.count == 64
      && read.participants.allSatisfy { participant in
        participant.participantIDSHA256.count == 64
          && participant.userRecordNameSHA256s.allSatisfy { $0.count == 64 }
      }
      && (read.shareRecordIDSHA256?.count ?? 64) == 64
      && (read.ownerRecordNameSHA256?.count ?? 64) == 64
    let permissionEnumsAccounted = read.participants.allSatisfy { participant in
      (participant.permissionValue == nil) == (participant.permissionLabel == nil)
    }
    let checks = [
      NotesVerificationCheckRecord(
        name: "shared_state_preflight",
        status: read.wasShared ? "passed" : "failed",
        expectedBool: true,
        actualBool: read.wasShared
      ),
      NotesVerificationCheckRecord(
        name: "participant_count_accounting",
        status: read.participantCount >= read.returnedParticipantCount ? "passed" : "failed",
        expectedLength: read.participantCount,
        actualLength: read.returnedParticipantCount
      ),
      NotesVerificationCheckRecord(
        name: "participant_identity_hash_set",
        status: read.participantIdentitySetSHA256 == expectedIdentitySetHash ? "passed" : "failed",
        expectedSHA256: expectedIdentitySetHash,
        actualSHA256: read.participantIdentitySetSHA256
      ),
      NotesVerificationCheckRecord(
        name: "permission_enum_accounting",
        status: permissionEnumsAccounted ? "passed" : "failed",
        expectedBool: true,
        actualBool: permissionEnumsAccounted
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: hashesArePrivacySafe ? "passed" : "failed",
        expectedBool: true,
        actualBool: hashesArePrivacySafe
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_collaboration_participants_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_share_participant_readback+permission_enum_hash_accounting",
      targetIDSHA256: sha256Hex(
        [
          read.targetKind,
          read.targetIDSHA256,
          "\(read.participantCount)",
          "\(read.returnedParticipantCount)",
          read.participantIdentitySetSHA256,
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  private func collaborationLinkReader() throws -> any NotesCollaborationLinkReading {
    guard let collaborationLinkReader = implementation as? any NotesCollaborationLinkReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes collaboration link copy requires a private-framework collaboration link reader.",
        details: [
          "capability": "collaboration_link_access",
          "required_module": "NotesShared",
        ]
      )
    }
    return collaborationLinkReader
  }

  private func collaborationParticipantsReader() throws -> any NotesCollaborationParticipantsReading {
    guard let collaborationParticipantsReader = implementation as? any NotesCollaborationParticipantsReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes collaboration participant commands require a private-framework collaboration participant reader.",
        details: [
          "capability": "collaboration_participant_access_metadata",
          "required_module": "NotesShared",
        ]
      )
    }
    return collaborationParticipantsReader
  }

  private func collaborationPermissionMutator() throws -> any NotesCollaborationPermissionMutating {
    guard let collaborationPermissionMutator = implementation as? any NotesCollaborationPermissionMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes collaboration permission changes require a private-framework share participant writer.",
        details: [
          "capability": "collaboration_permission_mutation",
          "required_module": "NotesShared.CKShareParticipant",
        ]
      )
    }
    return collaborationPermissionMutator
  }

  private func collaborationSharingMutator() throws -> any NotesCollaborationSharingMutating {
    guard let collaborationSharingMutator = implementation as? any NotesCollaborationSharingMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes collaboration sharing requires a private-framework share participant writer.",
        details: [
          "capability": "collaboration_share_mutation",
          "required_module": "NotesUI.ICCollaborationController+CloudKit.CKShareParticipant",
        ]
      )
    }
    return collaborationSharingMutator
  }

  private func collaborationAccessScopeMutator() throws -> any NotesCollaborationAccessScopeMutating {
    guard let collaborationAccessScopeMutator = implementation as? any NotesCollaborationAccessScopeMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes collaboration access scope changes require a private-framework share writer.",
        details: [
          "capability": "collaboration_access_scope_mutation",
          "required_module": "NotesShared.CKShare",
        ]
      )
    }
    return collaborationAccessScopeMutator
  }

  private func collaborationStopSharingMutator() throws -> any NotesCollaborationStopSharingMutating {
    guard let collaborationStopSharingMutator = implementation as? any NotesCollaborationStopSharingMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes stop-sharing requires a private-framework collaboration writer.",
        details: [
          "capability": "collaboration_stop_sharing",
          "required_module": "NotesUI.ICCollaborationController",
        ]
      )
    }
    return collaborationStopSharingMutator
  }

  private func collaborationInvitePolicyMutator() throws -> any NotesCollaborationInvitePolicyMutating {
    guard let collaborationInvitePolicyMutator = implementation as? any NotesCollaborationInvitePolicyMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes collaboration invite policy changes require a private-framework participant role writer.",
        details: [
          "capability": "collaboration_invite_policy_mutation",
          "required_module": "NotesShared.CKShareParticipant.role",
        ]
      )
    }
    return collaborationInvitePolicyMutator
  }

  private func collaborationSelfRemovalMutator() throws -> any NotesCollaborationSelfRemovalMutating {
    guard let collaborationSelfRemovalMutator = implementation as? any NotesCollaborationSelfRemovalMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes self removal requires a private-framework current-user participant writer.",
        details: [
          "capability": "collaboration_self_removal",
          "required_module": "NotesShared.CKShare.currentUserParticipant",
        ]
      )
    }
    return collaborationSelfRemovalMutator
  }

  private func collaborationParticipantMutator() throws -> any NotesCollaborationParticipantMutating {
    guard let collaborationParticipantMutator = implementation as? any NotesCollaborationParticipantMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes participant removal requires a private-framework share participant writer.",
        details: [
          "capability": "collaboration_participant_removal",
          "required_module": "NotesShared.CKShare",
        ]
      )
    }
    return collaborationParticipantMutator
  }

  private func collaborationMentionMutator() throws -> any NotesCollaborationMentionMutating {
    guard let collaborationMentionMutator = implementation as? any NotesCollaborationMentionMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes participant mention requires a private-framework mention attachment writer.",
        details: [
          "capability": "semantic_participant_mention",
          "required_module": "NotesShared.ICInlineAttachment",
        ]
      )
    }
    return collaborationMentionMutator
  }
}
