import Foundation
import Utility

extension NotesCommand {

  func audioWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.attachments.audio.audit"
    let records = notesAudioWorkflowAuditRecords()
    let summary = notesAudioWorkflowAuditSummary(records)
    let verification = verifyAudioWorkflowAudit(records: records, summary: summary)
    let response = NotesAudioWorkflowAuditResponse(
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

  private func notesAudioWorkflowAuditRecords() -> [NotesAudioWorkflowAuditRecord] {
    struct AudioWorkflowAuditItem {
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
      AudioWorkflowAuditItem(
        family: "audio_record",
        guideSection: "Record audio",
        status: "delegated",
        appleCapability: "record_audio_in_note",
        command: "Notes.app Record Audio UI",
        mechanism: "delegated_user_facing_notes_audio_recorder",
        requiredImplementation: "Notes.app microphone capture and recording session UI",
        requiredVerifier: "delegated_audio_recording_accounting",
        safetyGate: "none",
        privacyBoundary: "does_not_capture_microphone_or_create_audio_attachment",
        reason: "Recording new audio is a live microphone capture session in Notes.app, not a persisted Notes private data-model write owned by the CLI. The CLI supports existing audio attachment metadata, title/save/delete, and transcript readback after the recording exists."
      ),
      AudioWorkflowAuditItem(
        family: "audio_record_pause_resume",
        guideSection: "Record audio",
        status: "delegated",
        appleCapability: "pause_resume_audio_recording",
        command: "Notes.app Record Audio UI",
        mechanism: "delegated_user_facing_notes_audio_recorder",
        requiredImplementation: "Notes.app recording session controls",
        requiredVerifier: "delegated_audio_recording_accounting",
        safetyGate: "none",
        privacyBoundary: "does_not_capture_microphone_or_expose_audio_bytes",
        reason: "Pause/resume recording is part of the transient Notes.app microphone capture session rather than a standalone private Notes model operation."
      ),
      AudioWorkflowAuditItem(
        family: "live_note_edit_while_recording",
        guideSection: "Record audio",
        status: "delegated",
        appleCapability: "edit_note_while_recording",
        command: "Notes.app live recording editor UI",
        mechanism: "delegated_user_facing_notes_audio_recorder",
        requiredImplementation: "Notes.app recording session UI plus ordinary editor surface",
        requiredVerifier: "delegated_audio_recording_accounting",
        safetyGate: "none",
        privacyBoundary: "does_not_start_live_recording_or_print_note_body",
        reason: "Editing while recording combines the Notes.app live recording session with the interactive editor. Ordinary note body mutations are supported separately; the live capture session is delegated."
      ),
      AudioWorkflowAuditItem(
        family: "audio_title_rename",
        guideSection: "Record audio / Make changes to an audio recording",
        status: "supported",
        appleCapability: "change_audio_recording_title",
        command: "attachments audio rename --id NOTE_ID --attachment ATTACHMENT --name NAME",
        mechanism: "typed_private_notes_framework_attachment_title_writer",
        requiredImplementation: "ICAttachment title/userTitle private writer with audio-family readback",
        requiredVerifier: "private_attachment_title_readback+audio_family_verification",
        safetyGate: "DryRun payload",
        privacyBoundary: "does_not_print_audio_bytes_or_transcript_text",
        reason: "Existing audio attachment title changes are accepted through the private attachment title path."
      ),
      AudioWorkflowAuditItem(
        family: "audio_playback_play",
        guideSection: "Play an audio recording",
        status: "delegated",
        appleCapability: "play_audio_recording",
        command: "Notes.app audio playback UI; use attachments audio save for a CLI artifact",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_audio_player_or_future_external_dispatch_route",
        requiredVerifier: "delegated_audio_playback_accounting",
        safetyGate: "future --allow-external-dispatch if a CLI playback route is accepted",
        privacyBoundary: "no_backend_calls",
        reason: "Inline playback is a user-facing Notes audio player surface, not an accepted Notes private-framework CLI read/write operation."
      ),
      AudioWorkflowAuditItem(
        family: "audio_playback_pause_resume",
        guideSection: "Play an audio recording",
        status: "delegated",
        appleCapability: "pause_resume_audio_playback",
        command: "Notes.app audio playback UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_audio_player_session_control",
        requiredVerifier: "delegated_audio_playback_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Playback pause/resume is part of the Notes app player session and remains delegated to the UI surface."
      ),
      AudioWorkflowAuditItem(
        family: "audio_playback_skip",
        guideSection: "Play an audio recording",
        status: "delegated",
        appleCapability: "skip_backward_forward_audio_playback",
        command: "Notes.app audio playback UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_audio_player_seek_control",
        requiredVerifier: "delegated_audio_playback_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The 15-second skip controls belong to the Notes app player UI until a CLI playback route is accepted."
      ),
      AudioWorkflowAuditItem(
        family: "audio_append_recording",
        guideSection: "Make changes to an audio recording",
        status: "delegated",
        appleCapability: "add_onto_audio_recording",
        command: "Notes.app audio details recording UI",
        mechanism: "delegated_user_facing_notes_audio_recorder",
        requiredImplementation: "Notes.app audio recording append UI",
        requiredVerifier: "delegated_audio_recording_accounting",
        safetyGate: "none",
        privacyBoundary: "does_not_capture_microphone_or_mutate_audio_bytes",
        reason: "Adding onto an existing recording starts the Notes.app recording UI at the end of the recording. The CLI does not synthesize microphone capture or mutate audio bytes directly."
      ),
      AudioWorkflowAuditItem(
        family: "audio_transcription_generation",
        guideSection: "Transcribe audio",
        status: "delegated",
        appleCapability: "generate_audio_transcript",
        command: "Notes.app audio transcript generation surface",
        mechanism: "delegated_system_transcription_surface",
        requiredImplementation: "device transcription service surfaced by Notes.app",
        requiredVerifier: "delegated_transcription_generation_accounting",
        safetyGate: "none",
        privacyBoundary: "does_not_generate_or_print_transcript_text",
        reason: "Transcript generation depends on Apple's device transcription availability and Notes.app audio-details surface. The CLI reads, searches, exports, and copies existing private audio-document transcript metadata after generation."
      ),
      AudioWorkflowAuditItem(
        family: "audio_transcript_read",
        guideSection: "Transcribe audio",
        status: "supported",
        appleCapability: "view_existing_audio_transcript",
        command: "attachments audio transcript --id NOTE_ID --attachment ATTACHMENT",
        mechanism: "typed_private_notes_framework_audio_document_reader",
        requiredImplementation: "ICAttachment audioDocument transcript/summary/topline metadata readback",
        requiredVerifier: "private_audio_document_readback+privacy_hash_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_transcript_text",
        reason: "Existing transcript metadata is accepted through the private audio-document read path."
      ),
      AudioWorkflowAuditItem(
        family: "audio_transcript_search",
        guideSection: "Transcribe audio",
        status: "supported",
        appleCapability: "search_existing_audio_transcript",
        command: "attachments audio search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "typed_private_notes_framework_audio_document_reader",
        requiredImplementation: "bounded private audio-document transcript/summary scan",
        requiredVerifier: "private_audio_document_batch_readback+query_hash_accounting+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_raw_query_or_transcript_text",
        reason: "Existing transcript search is accepted with query hash and transcript-content hash accounting."
      ),
      AudioWorkflowAuditItem(
        family: "audio_transcript_copy_to_note",
        guideSection: "Transcribe audio",
        status: "supported",
        appleCapability: "copy_audio_transcript_to_note",
        command: "attachments audio copy-transcript --id NOTE_ID --attachment ATTACHMENT [--target TARGET_NOTE_ID]",
        mechanism: "typed_private_notes_framework_audio_document_reader_plus_note_append_writer",
        requiredImplementation: "private audio-document readback plus accepted note append path",
        requiredVerifier: "private_audio_document_readback+note_body_suffix_hash_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "does_not_print_copied_transcript_or_target_body",
        reason: "Copying existing transcript-family text into a note is accepted with target body suffix verification."
      ),
      AudioWorkflowAuditItem(
        family: "audio_transcript_copy_to_clipboard",
        guideSection: "Transcribe audio",
        status: "supported",
        appleCapability: "copy_audio_transcript_to_clipboard",
        command: "attachments audio copy-transcript --scope clipboard --id NOTE_ID --attachment ATTACHMENT",
        mechanism: "private_audio_document_reader_plus_delegated_pasteboard_writer",
        requiredImplementation: "private audio-document readback plus delegated system pasteboard write",
        requiredVerifier: "private_audio_document_readback+clipboard_sha256_readback+change_count",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_copied_or_clipboard_text",
        reason: "Clipboard copy is an accepted command with a delegated pasteboard side effect and explicit persistent-action safety."
      ),
      AudioWorkflowAuditItem(
        family: "audio_summary_read",
        guideSection: "Transcribe audio",
        status: "supported",
        appleCapability: "read_existing_audio_summary",
        command: "attachments audio transcript --content summary|topline-summary",
        mechanism: "typed_private_notes_framework_audio_document_reader",
        requiredImplementation: "ICAttachment audioDocument recording summary/top-line summary metadata readback",
        requiredVerifier: "private_audio_document_readback+summary_hash_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_summary_text",
        reason: "Existing recording summaries exposed by the private audio document are accepted as read/export/copy/search content kinds."
      ),
      AudioWorkflowAuditItem(
        family: "apple_intelligence_audio_summary_generation",
        guideSection: "Transcribe audio",
        status: "delegated",
        appleCapability: "generate_apple_intelligence_audio_summary",
        command: "Apple Intelligence in Notes surface",
        mechanism: "delegated_apple_intelligence_surface",
        requiredImplementation: "apple_intelligence_notes_summary_route",
        requiredVerifier: "delegated_apple_intelligence_summary_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Generating Apple Intelligence summaries belongs to the Apple Intelligence/Notes UI surface until a separate accepted route is proven."
      ),
      AudioWorkflowAuditItem(
        family: "audio_save_attachment",
        guideSection: "Save, share, or delete an audio recording",
        status: "supported",
        appleCapability: "save_audio_recording",
        command: "attachments audio save --id NOTE_ID --attachment ATTACHMENT --output FILE",
        mechanism: "typed_private_notes_framework_attachment_export_reader",
        requiredImplementation: "private attachment media byte read plus command-layer artifact writer",
        requiredVerifier: "private_attachment_readback+artifact_sha256_verification+audio_family_verification",
        safetyGate: "--allow-artifact-action",
        privacyBoundary: "does_not_print_audio_bytes_or_source_media_path",
        reason: "Saving an existing audio attachment is accepted as an explicit artifact export."
      ),
      AudioWorkflowAuditItem(
        family: "audio_share_attachment",
        guideSection: "Save, share, or delete an audio recording",
        status: "delegated",
        appleCapability: "share_audio_recording",
        command: "Notes.app share sheet; use attachments audio save for a CLI artifact",
        mechanism: "delegated_system_share_sheet",
        requiredImplementation: "macos_share_sheet_or_future_external_dispatch_route",
        requiredVerifier: "delegated_share_sheet_accounting",
        safetyGate: "future --allow-external-dispatch if a CLI share route is accepted",
        privacyBoundary: "no_backend_calls",
        reason: "Share Audio dispatches to a system/user-selected share destination rather than a direct Notes private-framework mutation."
      ),
      AudioWorkflowAuditItem(
        family: "audio_delete_attachment",
        guideSection: "Save, share, or delete an audio recording",
        status: "supported",
        appleCapability: "delete_audio_recording",
        command: "attachments audio delete --id NOTE_ID --attachment ATTACHMENT",
        mechanism: "typed_private_notes_framework_attachment_remove_writer",
        requiredImplementation: "private attachment remove path with audio-family readback",
        requiredVerifier: "private_attachment_absence_readback+audio_family_verification",
        safetyGate: "DryRun payload",
        privacyBoundary: "does_not_print_audio_bytes_or_transcript_text",
        reason: "Deleting one existing audio attachment is accepted through the private attachment remove path."
      ),
      AudioWorkflowAuditItem(
        family: "audio_transcript_edit",
        guideSection: "Transcribe audio",
        status: "rejected",
        appleCapability: "edit_audio_transcript",
        command: "attachments audio edit-transcript --id NOTE_ID --attachment ATTACHMENT",
        mechanism: "apple_product_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_audio_guide_limitation_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The current Apple Notes audio guide supports viewing, searching, copying, saving, sharing, and deleting audio transcript/recording data, but does not expose transcript text editing as a Notes product capability."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesAudioWorkflowAuditRecord(
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

  private func notesAudioWorkflowAuditSummary(
    _ records: [NotesAudioWorkflowAuditRecord]
  ) -> NotesAudioWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesAudioWorkflowAuditSummary(
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

  private func verifyAudioWorkflowAudit(
    records: [NotesAudioWorkflowAuditRecord],
    summary: NotesAudioWorkflowAuditSummary
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
        name: "existing_audio_attachment_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: ["audio_title_rename", "audio_save_attachment", "audio_delete_attachment"]
        )
      ),
      verificationBoolCheck(
        name: "existing_transcript_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "audio_transcript_read", "audio_transcript_search", "audio_transcript_copy_to_note",
            "audio_transcript_copy_to_clipboard", "audio_summary_read",
          ]
        )
      ),
      verificationBoolCheck(
        name: "playback_and_share_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "audio_playback_play", "audio_playback_pause_resume", "audio_playback_skip",
            "audio_share_attachment",
          ]
        )
      ),
      verificationBoolCheck(
        name: "apple_intelligence_summary_generation_delegated",
        expected: true,
        actual: delegated.contains("apple_intelligence_audio_summary_generation")
      ),
      verificationBoolCheck(
        name: "recording_and_transcription_generation_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "audio_record", "audio_record_pause_resume", "live_note_edit_while_recording",
            "audio_append_recording", "audio_transcription_generation",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_audio_data_edit_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "transcript_edit_non_capability_rejected",
        expected: true,
        actual: rejected.contains("audio_transcript_edit")
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
      operation: "notes.attachments.audio.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.attachments.audio.audit"),
      checks: checks
    )
  }

  private func validateAudioTranscriptCopyTargetState(_ state: NotesNoteStateRecord, operation: String) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes audio transcript copy target must be a visible non-trash note.",
        details: [
          "operation": operation,
          "target_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isPasswordProtected == false, state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes audio transcript copy target remains gated.",
        details: [
          "operation": operation,
          "target_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isEditable == true, state.isSharedReadOnly == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes audio transcript copy target must be editable.",
        details: [
          "operation": operation,
          "target_sha256": sha256Hex(state.noteID),
        ]
      )
    }
  }

  func readAttachmentAudioTranscript(
    _ source: NotesAttachmentAudioTranscriptSource,
    requestedAttachmentID: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.audio.transcript"
    let verification = try verifyAttachmentAudioTranscriptRead(
      source: source,
      operation: operation
    )
    let result = NotesAttachmentAudioTranscriptResult(
      operation: operation,
      changed: false,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      sourceKind: source.sourceKind,
      texts: attachmentAudioTranscriptTextRecords(source),
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes audio transcript read verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) read", options: options)
  }

  func exportAttachmentAudioTranscript(
    _ source: NotesAttachmentAudioTranscriptSource,
    requestedAttachmentID: String,
    contentKind: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.audio.transcript"
    let data = try attachmentAudioTranscriptData(source, contentKind: contentKind)
    let dataHash = sha256Hex(data)
    let summary = attachmentAudioTranscriptExportSummary(
      source: source,
      requestedAttachmentID: requestedAttachmentID,
      contentKind: contentKind,
      destinationPath: destinationPath,
      dataHash: dataHash,
      byteCount: data.count
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: attachmentAudioTranscriptExportScopeDigest(
            source: source,
            contentKind: contentKind,
            destinationPath: destinationPath,
            dataHash: dataHash,
            byteCount: data.count
          ),
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "Notes audio transcript export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeNotesAttachmentAudioTranscriptExport(data, to: destinationPath)
    let verification = try verifyAttachmentAudioTranscriptExport(
      source: source,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      expectedByteCount: data.count,
      operation: operation
    )
    let result = NotesAttachmentAudioTranscriptResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      sourceKind: source.sourceKind,
      texts: attachmentAudioTranscriptTextRecords(source),
      destinationPath: destinationPath,
      exportedContentKind: contentKind,
      byteCount: data.count,
      sha256: dataHash,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes audio transcript export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  func copyAttachmentAudioTranscript(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.attachments.audio.copy-transcript"
    let sourceNoteID = try requiredOption("id", options: options)
    let requestedAttachmentID = try requiredOption("attachment", options: options)
    let destination = try attachmentAudioTranscriptCopyDestination(options)
    if destination == "clipboard", options.targetOption("target") != nil {
      throw CLIError(
        code: .validationError,
        message: "`--target` cannot be combined with `--scope clipboard`.",
        details: ["scope": destination]
      )
    }
    let contentKind = try attachmentAudioTranscriptContentKind(options)
    let source = try attachmentReader().readAttachmentAudioTranscript(
      noteID: sourceNoteID,
      attachmentID: requestedAttachmentID
    )
    let data = try attachmentAudioTranscriptData(source, contentKind: contentKind)
    let transcriptText = String(decoding: data, as: UTF8.self)
    guard !transcriptText.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Requested audio transcript content is empty.",
        details: [
          "operation": operation,
          "content": contentKind,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    let dataHash = sha256Hex(data)

    if destination == "clipboard" {
      return try copyAttachmentAudioTranscriptToClipboard(
        source: source,
        contentKind: contentKind,
        transcriptText: transcriptText,
        dataHash: dataHash,
        byteCount: data.count,
        operation: operation,
        options: options
      )
    }

    let targetNoteID = options.targetOption("target") ?? sourceNoteID
    guard let targetNote = try implementation.readNote(id: targetNoteID) else {
      throw CLIError(
        code: .notFound,
        message: "Target note was not found.",
        details: ["target_sha256": sha256Hex(targetNoteID)]
      )
    }
    try validateAudioTranscriptCopyTargetState(
      try noteStateReader().readNoteState(noteID: targetNote.id),
      operation: operation
    )

    let summary = attachmentAudioTranscriptCopySummary(
      source: source,
      targetNote: targetNote,
      contentKind: contentKind,
      dataHash: dataHash,
      byteCount: data.count
    )

    return try mutation(
      operation: operation,
      scopeDigest: attachmentAudioTranscriptCopyScopeDigest(
        source: source,
        targetNote: targetNote,
        contentKind: contentKind,
        dataHash: dataHash,
        byteCount: data.count
      ),
      summary: summary,
      options: options
    ) {
      let resultNote = try implementation.updateNote(
        id: targetNote.id,
        patch: NotesUpdatePatch(appendBody: transcriptText)
      )
      let verification = try verifyAttachmentAudioTranscriptCopy(
        source: source,
        targetBefore: targetNote,
        resultNote: resultNote,
        copiedText: transcriptText,
        contentKind: contentKind,
        expectedSHA256: dataHash,
        expectedByteCount: data.count,
        operation: operation
      )
      let targetBodyData = Data((resultNote.body ?? "").utf8)
      let result = NotesAttachmentAudioTranscriptCopyResult(
        operation: operation,
        changed: true,
        destination: destination,
        sourceNoteID: source.noteID,
        sourceAttachmentID: source.attachment.id,
        targetNoteID: resultNote.id,
        contentKind: contentKind,
        sourceKind: source.sourceKind,
        byteCount: data.count,
        sha256: dataHash,
        version: attachmentAudioTranscriptText(source, kind: contentKind).version,
        targetBodyByteCount: targetBodyData.count,
        targetBodySHA256: sha256Hex(targetBodyData),
        verification: verification
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes audio transcript copy verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return result
    }
  }

  private func copyAttachmentAudioTranscriptToClipboard(
    source: NotesAttachmentAudioTranscriptSource,
    contentKind: String,
    transcriptText: String,
    dataHash: String,
    byteCount: Int,
    operation: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let summary = attachmentAudioTranscriptClipboardCopySummary(
      source: source,
      contentKind: contentKind,
      dataHash: dataHash,
      byteCount: byteCount
    )
    let scopeDigest = attachmentAudioTranscriptClipboardCopyScopeDigest(
      source: source,
      contentKind: contentKind,
      dataHash: dataHash,
      byteCount: byteCount
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .persistentAction,
          allowFlags: ["--allow-persistent-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-persistent-action",
      in: options,
      category: .persistentAction,
      message: "Notes audio transcript clipboard copy persists pasteboard state and requires `--allow-persistent-action`."
    )

    let writeRecord = try clipboardWriter.writeString(transcriptText)
    let clipboardText = try clipboardWriter.readString()
    let verification = try verifyAttachmentAudioTranscriptClipboardCopy(
      source: source,
      copiedText: transcriptText,
      clipboardText: clipboardText,
      contentKind: contentKind,
      expectedSHA256: dataHash,
      expectedByteCount: byteCount,
      clipboardChangeCount: writeRecord.changeCount,
      operation: operation
    )
    let result = NotesAttachmentAudioTranscriptCopyResult(
      operation: operation,
      changed: true,
      destination: "clipboard",
      sourceNoteID: source.noteID,
      sourceAttachmentID: source.attachment.id,
      contentKind: contentKind,
      sourceKind: source.sourceKind,
      byteCount: byteCount,
      sha256: dataHash,
      version: attachmentAudioTranscriptText(source, kind: contentKind).version,
      clipboardChangeCount: writeRecord.changeCount,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes audio transcript clipboard copy verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  func searchAttachmentAudioTranscripts(
    query: String,
    contentKinds: [String],
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.audio.search"
    let limit = try commandLimit(options)
    let notes = try attachmentAudioTranscriptSearchNotes(options, limit: limit)
    let reader = try attachmentReader()
    var scannedAudioAttachmentCount = 0
    var skippedAudioAttachmentCount = 0
    var matches: [NotesAttachmentAudioTranscriptSearchMatch] = []

    for note in notes {
      let attachments = try reader.listAttachments(noteID: note.id, limit: 2_000)
      for attachment in attachments where attachmentAuditFamily(attachment) == "audio_recording" {
        scannedAudioAttachmentCount += 1
        let source: NotesAttachmentAudioTranscriptSource
        do {
          source = try reader.readAttachmentAudioTranscript(noteID: note.id, attachmentID: attachment.id)
        } catch let error as CLIError where error.code == .unsupportedOperation {
          skippedAudioAttachmentCount += 1
          continue
        }
        let contentMatches = attachmentAudioTranscriptSearchContentMatches(
          source,
          query: query,
          contentKinds: contentKinds
        )
        guard !contentMatches.isEmpty else {
          continue
        }
        matches.append(
          NotesAttachmentAudioTranscriptSearchMatch(
            note: note,
            attachment: source.attachment,
            sourceKind: source.sourceKind,
            contentMatches: contentMatches
          ))
        if matches.count >= limit {
          break
        }
      }
      if matches.count >= limit {
        break
      }
    }

    let verification = verifyAttachmentAudioTranscriptSearch(
      query: query,
      contentKinds: contentKinds,
      scannedNoteCount: notes.count,
      scannedAudioAttachmentCount: scannedAudioAttachmentCount,
      skippedAudioAttachmentCount: skippedAudioAttachmentCount,
      matches: matches,
      operation: operation
    )
    let result = NotesAttachmentAudioTranscriptSearchResult(
      operation: operation,
      changed: false,
      querySHA256: sha256Hex(query),
      queryByteCount: Data(query.utf8).count,
      account: options.targetOption("account"),
      folder: options.targetOption("folder"),
      contentKinds: contentKinds,
      scannedNoteCount: notes.count,
      scannedAudioAttachmentCount: scannedAudioAttachmentCount,
      skippedAudioAttachmentCount: skippedAudioAttachmentCount,
      matchedAttachmentCount: matches.count,
      matches: matches,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes audio transcript search verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) matched \(matches.count)", options: options)
  }

  private func attachmentAudioTranscriptSearchNotes(_ options: CLIOptions, limit: Int) throws
    -> [NotesNoteSummary]
  {
    if let id = options.targetOption("id") {
      if options.targetOption("folder") != nil {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for audio transcript search."
        )
      }
      if options.targetOption("account") != nil {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for audio transcript search."
        )
      }
      guard let note = try implementation.readNote(id: id) else {
        throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
      }
      return [noteSummary(note)]
    }
    return try listVisibleNotes(options, limit: limit)
  }

  func attachmentAudioTranscriptSearchQuery(_ options: CLIOptions) throws -> String {
    let query = try requiredOption("query", options: options).trimmingCharacters(in: .whitespacesAndNewlines)
    guard query.count >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "`--query` must contain at least 2 non-whitespace characters."
      )
    }
    return query
  }

  func attachmentAudioTranscriptSearchContentKinds(_ options: CLIOptions) throws -> [String] {
    let value = (options.targetOption("content") ?? "all").lowercased()
    switch value {
    case "all":
      return ["transcript", "summary", "topline-summary"]
    case "transcript":
      return ["transcript"]
    case "summary", "recording-summary", "recording_summary":
      return ["summary"]
    case "topline-summary", "top-line-summary", "topline_summary", "top_line_summary":
      return ["topline-summary"]
    default:
      throw CLIError(
        code: .validationError,
        message: "`--content` must be one of `all`, `transcript`, `summary`, or `topline-summary`.",
        details: ["content": value]
      )
    }
  }

  func attachmentAudioTranscriptContentKind(_ options: CLIOptions) throws -> String {
    let value = (options.targetOption("content") ?? "transcript").lowercased()
    switch value {
    case "transcript":
      return "transcript"
    case "summary", "recording-summary", "recording_summary":
      return "summary"
    case "topline-summary", "top-line-summary", "topline_summary", "top_line_summary":
      return "topline-summary"
    default:
      throw CLIError(
        code: .validationError,
        message: "`--content` must be one of `transcript`, `summary`, or `topline-summary`.",
        details: ["content": value]
      )
    }
  }

  private func attachmentAudioTranscriptCopyDestination(_ options: CLIOptions) throws -> String {
    let value = (options.targetOption("scope") ?? "note").lowercased()
    switch value {
    case "note":
      return "note"
    case "clipboard":
      return "clipboard"
    default:
      throw CLIError(
        code: .validationError,
        message: "`--scope` must be one of `note` or `clipboard`.",
        details: ["scope": value]
      )
    }
  }

  private func attachmentAudioTranscriptTextRecords(
    _ source: NotesAttachmentAudioTranscriptSource
  ) -> [NotesAttachmentAudioTranscriptTextRecord] {
    [
      attachmentAudioTranscriptTextRecord(
        kind: "transcript",
        text: source.transcriptText,
        version: source.transcriptVersion
      ),
      attachmentAudioTranscriptTextRecord(
        kind: "summary",
        text: source.recordingSummaryText
      ),
      attachmentAudioTranscriptTextRecord(
        kind: "topline-summary",
        text: source.topLineSummaryText
      ),
    ]
  }

  private func attachmentAudioTranscriptTextRecord(
    kind: String,
    text: String?,
    version: Int? = nil
  ) -> NotesAttachmentAudioTranscriptTextRecord {
    guard let text else {
      return NotesAttachmentAudioTranscriptTextRecord(kind: kind, present: false, version: version)
    }
    let data = Data(text.utf8)
    return NotesAttachmentAudioTranscriptTextRecord(
      kind: kind,
      present: true,
      byteCount: data.count,
      sha256: sha256Hex(data),
      version: version
    )
  }

  private func attachmentAudioTranscriptData(
    _ source: NotesAttachmentAudioTranscriptSource,
    contentKind: String
  ) throws -> Data {
    let text: String?
    switch contentKind {
    case "transcript":
      text = source.transcriptText
    case "summary":
      text = source.recordingSummaryText
    case "topline-summary":
      text = source.topLineSummaryText
    default:
      text = nil
    }
    guard let text else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Requested audio transcript content is not present on the attachment.",
        details: [
          "attachment_id_sha256": sha256Hex(source.attachment.id),
          "content": contentKind,
        ]
      )
    }
    return Data(text.utf8)
  }

  private func attachmentAudioTranscriptExportSummary(
    source: NotesAttachmentAudioTranscriptSource,
    requestedAttachmentID: String,
    contentKind: String,
    destinationPath: String,
    dataHash: String,
    byteCount: Int
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "requested_attachment": requestedAttachmentID,
      "content": contentKind,
      "destination_path": destinationPath,
      "byte_count": "\(byteCount)",
      "sha256": dataHash,
      "title": source.attachment.title ?? "",
      "type_uti": source.attachment.typeUTI ?? "",
      "media_filename": source.attachment.mediaFilename ?? "",
      "source_kind": source.sourceKind,
    ]
  }

  private func attachmentAudioTranscriptExportScopeDigest(
    source: NotesAttachmentAudioTranscriptSource,
    contentKind: String,
    destinationPath: String,
    dataHash: String,
    byteCount: Int
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      contentKind,
      destinationPath,
      "\(byteCount)",
      dataHash,
      source.sourceKind,
    ].joined(separator: "|")
    return "notes-attachment-audio-transcript-export:\(sha256Hex(fields))"
  }

  private func attachmentAudioTranscriptCopySummary(
    source: NotesAttachmentAudioTranscriptSource,
    targetNote: NotesNoteDetail,
    contentKind: String,
    dataHash: String,
    byteCount: Int
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "scope": "note",
      "target": targetNote.id,
      "content": contentKind,
      "byte_count": "\(byteCount)",
      "sha256": dataHash,
      "source_kind": source.sourceKind,
      "target_body_sha256": sha256Hex(targetNote.body ?? ""),
    ]
  }

  private func attachmentAudioTranscriptCopyScopeDigest(
    source: NotesAttachmentAudioTranscriptSource,
    targetNote: NotesNoteDetail,
    contentKind: String,
    dataHash: String,
    byteCount: Int
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      "note",
      targetNote.id,
      contentKind,
      "\(byteCount)",
      dataHash,
      sha256Hex(targetNote.body ?? ""),
      source.sourceKind,
    ].joined(separator: "|")
    return "notes-attachment-audio-transcript-copy:\(sha256Hex(fields))"
  }

  private func attachmentAudioTranscriptClipboardCopySummary(
    source: NotesAttachmentAudioTranscriptSource,
    contentKind: String,
    dataHash: String,
    byteCount: Int
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "scope": "clipboard",
      "content": contentKind,
      "byte_count": "\(byteCount)",
      "sha256": dataHash,
      "source_kind": source.sourceKind,
    ]
  }

  private func attachmentAudioTranscriptClipboardCopyScopeDigest(
    source: NotesAttachmentAudioTranscriptSource,
    contentKind: String,
    dataHash: String,
    byteCount: Int
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      "clipboard",
      contentKind,
      "\(byteCount)",
      dataHash,
      source.sourceKind,
    ].joined(separator: "|")
    return "notes-attachment-audio-transcript-clipboard-copy:\(sha256Hex(fields))"
  }

  private func verifyAttachmentAudioTranscriptRead(
    source: NotesAttachmentAudioTranscriptSource,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let textHashAccounting = attachmentAudioTranscriptTextRecords(source).allSatisfy { text in
      !text.present || (text.byteCount != nil && text.sha256 != nil)
    }
    let audioDocumentReadback = !source.sourceKind.isEmpty
    let checks = [
      NotesVerificationCheckRecord(
        name: "audio_document_readback",
        status: audioDocumentReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: audioDocumentReadback
      ),
      NotesVerificationCheckRecord(
        name: "privacy_hash_accounting",
        status: textHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: textHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_audio_document_readback+privacy_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentAudioTranscriptSearch(
    query: String,
    contentKinds: [String],
    scannedNoteCount: Int,
    scannedAudioAttachmentCount: Int,
    skippedAudioAttachmentCount: Int,
    matches: [NotesAttachmentAudioTranscriptSearchMatch],
    operation: String
  ) -> NotesMutationVerificationReport {
    let allowedContentKinds = Set(["transcript", "summary", "topline-summary"])
    let contentKindAccounting = !contentKinds.isEmpty && contentKinds.allSatisfy { allowedContentKinds.contains($0) }
    let privacyHashAccounting = matches.allSatisfy { match in
      !match.sourceKind.isEmpty
        && match.contentMatches.allSatisfy { contentMatch in
          allowedContentKinds.contains(contentMatch.kind)
            && contentMatch.matchCount > 0
            && contentMatch.byteCount > 0
            && !contentMatch.sha256.isEmpty
        }
    }
    let audioScanAccounting =
      scannedAudioAttachmentCount >= matches.count + skippedAudioAttachmentCount
    let boundedScan = scannedNoteCount <= 500 && matches.count <= 500
    let checks = [
      NotesVerificationCheckRecord(
        name: "query_hash_accounting",
        status: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 ? "passed" : "failed",
        expectedBool: true,
        actualBool: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
      ),
      NotesVerificationCheckRecord(
        name: "content_kind_accounting",
        status: contentKindAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: contentKindAccounting
      ),
      NotesVerificationCheckRecord(
        name: "bounded_scan",
        status: boundedScan ? "passed" : "failed",
        expectedBool: true,
        actualBool: boundedScan
      ),
      NotesVerificationCheckRecord(
        name: "audio_attachment_scan_accounting",
        status: audioScanAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: audioScanAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_hash_accounting",
        status: privacyHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashAccounting
      ),
    ]
    let targetFields = [
      sha256Hex(query),
      contentKinds.joined(separator: ","),
      matches.map { $0.attachment.id }.joined(separator: ","),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_audio_document_batch_readback+privacy_hash+bounded_scan",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func verifyAttachmentAudioTranscriptExport(
    source: NotesAttachmentAudioTranscriptSource,
    destinationPath: String,
    expectedSHA256: String,
    expectedByteCount: Int,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "byte_count",
        status: fileData.count == expectedByteCount ? "passed" : "failed",
        expectedLength: expectedByteCount,
        actualLength: fileData.count
      ),
      NotesVerificationCheckRecord(
        name: "sha256",
        status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_audio_document_readback+artifact_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentAudioTranscriptCopy(
    source: NotesAttachmentAudioTranscriptSource,
    targetBefore: NotesNoteDetail,
    resultNote: NotesNoteDetail,
    copiedText: String,
    contentKind: String,
    expectedSHA256: String,
    expectedByteCount: Int,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let copiedData = Data(copiedText.utf8)
    let resultBody = resultNote.body ?? ""
    let resultBodyData = Data(resultBody.utf8)
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let targetIdentityPreserved = resultNote.id == targetBefore.id
      && resultNote.folderName == targetBefore.folderName
      && resultNote.accountName == targetBefore.accountName
    let suffixReadback = resultBody.hasSuffix(copiedText)
    let hashMatches = sha256Hex(copiedData) == expectedSHA256
    let byteCountMatches = copiedData.count == expectedByteCount
    let checks = [
      NotesVerificationCheckRecord(
        name: "audio_document_readback",
        status: source.sourceKind.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: !source.sourceKind.isEmpty
      ),
      NotesVerificationCheckRecord(
        name: "content_kind",
        status: ["transcript", "summary", "topline-summary"].contains(contentKind) ? "passed" : "failed",
        expectedBool: true,
        actualBool: ["transcript", "summary", "topline-summary"].contains(contentKind)
      ),
      NotesVerificationCheckRecord(
        name: "copied_byte_count",
        status: byteCountMatches ? "passed" : "failed",
        expectedLength: expectedByteCount,
        actualLength: copiedData.count
      ),
      NotesVerificationCheckRecord(
        name: "copied_text_sha256",
        status: hashMatches ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: sha256Hex(copiedData)
      ),
      NotesVerificationCheckRecord(
        name: "target_note_identity",
        status: targetIdentityPreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetIdentityPreserved
      ),
      NotesVerificationCheckRecord(
        name: "target_body_suffix_readback",
        status: suffixReadback ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: suffixReadback ? expectedSHA256 : sha256Hex(resultBodyData)
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_body_privacy_hash",
        status: resultBodyData.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: !resultBodyData.isEmpty
      ),
    ]
    let targetFields = [
      source.noteID,
      source.attachment.id,
      targetBefore.id,
      contentKind,
      "\(expectedByteCount)",
      expectedSHA256,
      sha256Hex(resultBodyData),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_audio_document_readback+note_append_readback+privacy_hash",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func verifyAttachmentAudioTranscriptClipboardCopy(
    source: NotesAttachmentAudioTranscriptSource,
    copiedText: String,
    clipboardText: String?,
    contentKind: String,
    expectedSHA256: String,
    expectedByteCount: Int,
    clipboardChangeCount: Int,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let copiedData = Data(copiedText.utf8)
    let clipboardData = Data((clipboardText ?? "").utf8)
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let contentKindSupported = ["transcript", "summary", "topline-summary"].contains(contentKind)
    let copiedHashMatches = sha256Hex(copiedData) == expectedSHA256
    let copiedByteCountMatches = copiedData.count == expectedByteCount
    let clipboardReadbackMatches = clipboardText == copiedText
    let clipboardHash = sha256Hex(clipboardData)
    let checks = [
      NotesVerificationCheckRecord(
        name: "audio_document_readback",
        status: source.sourceKind.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: !source.sourceKind.isEmpty
      ),
      NotesVerificationCheckRecord(
        name: "content_kind",
        status: contentKindSupported ? "passed" : "failed",
        expectedBool: true,
        actualBool: contentKindSupported
      ),
      NotesVerificationCheckRecord(
        name: "copied_byte_count",
        status: copiedByteCountMatches ? "passed" : "failed",
        expectedLength: expectedByteCount,
        actualLength: copiedData.count
      ),
      NotesVerificationCheckRecord(
        name: "copied_text_sha256",
        status: copiedHashMatches ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: sha256Hex(copiedData)
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_text_readback",
        status: clipboardReadbackMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: clipboardReadbackMatches
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_text_sha256",
        status: clipboardHash == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: clipboardHash
      ),
      NotesVerificationCheckRecord(
        name: "clipboard_change_count",
        status: clipboardChangeCount > 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: clipboardChangeCount > 0
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
    ]
    let targetFields = [
      source.noteID,
      source.attachment.id,
      "clipboard",
      contentKind,
      "\(expectedByteCount)",
      expectedSHA256,
      "\(clipboardChangeCount)",
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_audio_document_readback+system_clipboard_readback+privacy_hash",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  func attachmentAudioTranscriptSearchContentMatches(
    _ source: NotesAttachmentAudioTranscriptSource,
    query: String,
    contentKinds: [String]
  ) -> [NotesAttachmentAudioTranscriptSearchContentMatch] {
    contentKinds.compactMap { kind in
      let textAndVersion = attachmentAudioTranscriptText(source, kind: kind)
      guard let text = textAndVersion.text else {
        return nil
      }
      let matchCount = attachmentAudioTranscriptSearchMatchCount(text: text, query: query)
      guard matchCount > 0 else {
        return nil
      }
      let data = Data(text.utf8)
      return NotesAttachmentAudioTranscriptSearchContentMatch(
        kind: kind,
        matchCount: matchCount,
        byteCount: data.count,
        sha256: sha256Hex(data),
        version: textAndVersion.version
      )
    }
  }

  private func attachmentAudioTranscriptText(
    _ source: NotesAttachmentAudioTranscriptSource,
    kind: String
  ) -> (text: String?, version: Int?) {
    switch kind {
    case "transcript":
      return (source.transcriptText, source.transcriptVersion)
    case "summary":
      return (source.recordingSummaryText, nil)
    case "topline-summary":
      return (source.topLineSummaryText, nil)
    default:
      return (nil, nil)
    }
  }

  private func attachmentAudioTranscriptSearchMatchCount(text: String, query: String) -> Int {
    privacySafeTextSearchMatchCount(text: text, query: query)
  }
}
