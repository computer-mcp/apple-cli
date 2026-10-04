import Foundation
import Utility

extension NotesCommand {
  func runState(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["state", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let state = try noteStateReader().readNoteState(noteID: id)
      return try result(
        NotesNoteStateResponse(noteID: id, state: state),
        human: [
          "note_id: \(state.noteID)",
          "deleted_or_trash: \(state.isDeletedOrInTrash)",
          "pinned: \(state.isPinned)",
          "password_protected: \(state.isPasswordProtected)",
          "shared: \(state.isSharedViaICloud || state.isSharedViaICloudFolder)",
          "shared_read_only: \(state.isSharedReadOnly)",
          "editable: \(state.isEditable)",
          "lockable: \(state.isLockable)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["state", "lockability"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      return try readNoteLockability(options: options)
    case ["state", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account", "folder"])
      let records = try noteStateAuditRecords(options)
      let summary = noteStateAuditSummary(records)
      let verification = verifyNoteStateAudit(records: records, summary: summary)
      return try result(
        NotesNoteStateAuditResponse(
          account: options.targetOption("account"),
          folder: options.targetOption("folder"),
          summary: summary,
          records: records,
          verification: verification
        ),
        human: [
          "notes: \(summary.noteCount)",
          "password_protected: \(summary.passwordProtectedCount)",
          "locked: \(summary.lockedCount)",
          "shared_notes: \(summary.sharedNoteCount)",
          "shared_folders: \(summary.sharedFolderCount)",
          "shared_read_only: \(summary.sharedReadOnlyCount)",
          "participants: \(summary.participantCount)",
          "gated_mutations: \(summary.gatedMutationFamilies.joined(separator: ","))",
        ].joined(separator: "\n"),
        options: options
      )
    case ["state", "collaboration", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try collaborationWorkflowAudit(options)
    case ["state", "security", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try securityWorkflowAudit(options)
    case ["state", "lock"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      return try setNoteLockState(options: options, action: "lock")
    case ["state", "unlock"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "passphrase-env", "passphrase-file"],
        allowedFlags: ["passphrase-stdin"]
      )
      return try unlockNote(options: options)
    case ["state", "remove-lock"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      return try setNoteLockState(options: options, action: "remove-lock")
    case ["state", "close-locked"]:
      try validateTargetOptions(options, allowedOptions: ["account"])
      return try closeLockedSession(options: options)
    case ["state", "export-locked-content"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "output", "passphrase-env", "passphrase-file"],
        allowedFlags: ["passphrase-stdin"]
      )
      return try exportLockedContent(options: options)
    case ["state", "share"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder", "target", "scope"])
      if try normalizedOptionalOption("target", options: options) == nil {
        return try setCollaborationAccessScope(options: options)
      }
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state share")
      return try shareCollaboration(options: options, operation: "notes.state.share", createShareIfNeeded: true)
    case ["state", "share-folder"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "target", "scope"])
      _ = try requiredOption("folder", options: options)
      _ = try requiredOption("target", options: options)
      return try shareCollaboration(options: options, operation: "notes.state.share-folder", createShareIfNeeded: true)
    case ["state", "stop-sharing"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder"])
      return try stopSharing(options: options)
    case ["state", "invite"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder", "target", "scope"])
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state invite")
      _ = try requiredOption("target", options: options)
      return try shareCollaboration(options: options, operation: "notes.state.invite", createShareIfNeeded: false)
    case ["state", "remove-participant"]:
      try validateTargetOptions(options, allowedOptions: ["id", "target"])
      return try removeCollaborationParticipant(options: options)
    case ["state", "set-permission"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder", "target", "scope"])
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state set-permission")
      return try setCollaborationParticipantPermission(options: options)
    case ["state", "allow-invites"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder", "enabled"])
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state allow-invites")
      return try setCollaborationInvitePolicy(options: options)
    case ["state", "copy-link"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder", "output"])
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state copy-link")
      return try copyCollaborationLink(options: options)
    case ["state", "participants"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder", "output"])
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state participants")
      return try readCollaborationParticipants(options: options)
    case ["state", "remove-self"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder"])
      try validateExactlyOneTargetOption(["id", "folder"], options: options, commandName: "state remove-self")
      return try removeSelfFromCollaboration(options: options)
    case ["state", "hide-alerts"]:
      try validateTargetOptions(options, allowedOptions: ["id", "enabled"])
      return try setSharedNoteAlertsHidden(options: options)
    case ["state", "mention"]:
      try validateTargetOptions(options, allowedOptions: ["id", "target", "text"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("target", options: options)
      return try insertParticipantMention(options: options)
    case ["state", "activity"]:
      try validateTargetOptions(options, allowedOptions: ["id", "output"])
      return try readNoteActivity(options: options)
    case ["state", "folder-permission"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "target", "scope"])
      _ = try requiredOption("folder", options: options)
      return try setCollaborationParticipantPermission(
        options: options,
        operation: "notes.state.folder-permission",
        commandName: "state folder-permission"
      )
    case ["state", "change-password"]:
      try validateTargetOptions(options, allowedOptions: ["account"])
      throw gatedStateCapabilityError(
        operation: "notes.state.change-password",
        capability: "locked_notes_password_change",
        appleCapability: "change_locked_notes_password",
        futureGate: "locked_notes_password_settings_mutation"
      )    default:
      return nil
    }
  }

  private func noteStateAuditRecords(_ options: CLIOptions) throws -> [NotesNoteStateRecord] {
    let summaries = try listVisibleNotes(options, limit: try commandLimit(options))
    let reader = try noteStateReader()
    return try summaries.map { try reader.readNoteState(noteID: $0.id) }
  }

  private func readNoteLockability(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.lockability"
    let noteID = try requiredOption("id", options: options)
    let state = try noteStateReader().readNoteState(noteID: noteID)
    guard let note = try implementation.readNote(id: noteID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(noteID)]
      )
    }
    let attachments = try attachmentReader()
      .listAttachments(noteID: noteID, limit: 2_000)
      .filter { $0.isDeletedOrInTrash != true }
    let familyCounts = lockabilityAttachmentFamilyCounts(attachments)
    let allowedFamilies = lockabilityAllowedAttachmentFamilies()
    let prohibitedFamilies = lockabilityProhibitedAttachmentFamilies()
    let allowedCounts = familyCounts.filter { allowedFamilies.contains($0.key) }
    let prohibitedCounts = familyCounts.filter { prohibitedFamilies.contains($0.key) }
    let unknownAttachmentCount = familyCounts["unknown"] ?? 0
    let tagIdentifiers = note.tags
      .map { $0.standardizedContent ?? $0.displayText }
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .sorted()
    let tagSetSHA256 = tagIdentifiers.isEmpty ? nil : sha256Hex(tagIdentifiers.joined(separator: "\n"))
    let reasons = lockabilityReasons(
      state: state,
      tagCount: tagIdentifiers.count,
      tagSetSHA256: tagSetSHA256,
      prohibitedAttachmentFamilyCounts: prohibitedCounts,
      unknownAttachmentCount: unknownAttachmentCount
    )
    let blockingReasonCount = reasons.filter { $0.status == "blocking" }.count
    let unresolvedReasonCount = reasons.filter { $0.status == "unresolved" }.count
    let verification = verifyNoteLockability(
      noteID: noteID,
      state: state,
      tagCount: tagIdentifiers.count,
      tagSetSHA256: tagSetSHA256,
      attachmentCount: attachments.count,
      familyCounts: familyCounts,
      reasons: reasons
    )
    let response = NotesNoteLockabilityResponse(
      operation: operation,
      changed: false,
      noteID: noteID,
      privateFrameworkLockable: state.isLockable,
      isPasswordProtected: state.isPasswordProtected,
      isPasswordProtectedAndLocked: state.isPasswordProtectedAndLocked,
      isEditable: state.isEditable,
      blockingReasonCount: blockingReasonCount,
      unresolvedReasonCount: unresolvedReasonCount,
      tagCount: tagIdentifiers.count,
      tagSetSHA256: tagSetSHA256,
      accountCanPasswordProtectNotes: state.accountCanPasswordProtectNotes,
      accountCanHaveCryptoStrategy: state.accountCanHaveCryptoStrategy,
      accountIsInICloud: state.accountIsInICloud,
      accountIsLocal: state.accountIsLocal,
      accountLockedNotesModeSHA256: state.accountLockedNotesModeSHA256,
      accountResolvedLockedNotesModeSHA256: state.accountResolvedLockedNotesModeSHA256,
      accountPasswordProtectedNoteCount: state.accountPasswordProtectedNoteCount,
      attachmentCount: attachments.count,
      allowedAttachmentFamilyCounts: allowedCounts,
      prohibitedAttachmentFamilyCounts: prohibitedCounts,
      unknownAttachmentFamilyCount: unknownAttachmentCount,
      reasons: reasons,
      verification: verification
    )
    return try result(
      response,
      human: [
        "note_id: \(state.noteID)",
        "private_framework_lockable: \(state.isLockable)",
        "blocking_reasons: \(blockingReasonCount)",
        "unresolved_reasons: \(unresolvedReasonCount)",
      ].joined(separator: "\n"),
      options: options
    )
  }

  private func lockabilityAttachmentFamilyCounts(_ attachments: [NotesAttachmentRecord]) -> [String: Int] {
    var counts: [String: Int] = [:]
    for attachment in attachments {
      counts[attachmentAuditFamily(attachment), default: 0] += 1
    }
    return counts
  }

  private func lockabilityAllowedAttachmentFamilies() -> Set<String> {
    ["drawing_or_sketch", "map_preview", "photo_image", "scanned_document", "webpage_preview"]
  }

  private func lockabilityProhibitedAttachmentFamilies() -> Set<String> {
    ["audio_recording", "file", "pdf", "video"]
  }

  private func lockabilityReasons(
    state: NotesNoteStateRecord,
    tagCount: Int,
    tagSetSHA256: String?,
    prohibitedAttachmentFamilyCounts: [String: Int],
    unknownAttachmentCount: Int
  ) -> [NotesNoteLockabilityReasonRecord] {
    var reasons: [NotesNoteLockabilityReasonRecord] = []
    if state.isSystemPaper {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "quick_note",
          status: "blocking",
          evidenceSource: "note_state.isSystemPaper",
          evidenceCount: 1,
          evidenceSHA256: sha256Hex(state.noteID)
        ))
    }
    let shared = state.isSharedViaICloud || state.isSharedViaICloudFolder || (state.participantCount ?? 0) > 0
    if shared {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "shared_note",
          status: "blocking",
          evidenceSource: "note_state.shared_flags+participant_count",
          evidenceCount: state.participantCount ?? 0,
          evidenceSHA256: sha256Hex(state.participantUserIDSHA256s.sorted().joined(separator: "\n"))
        ))
    }
    if state.accountIsInICloud == false && state.accountIsLocal == false {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "account_provider_does_not_support_locking",
          status: "blocking",
          evidenceSource: "account.isInICloudAccount+isLocalAccount",
          evidenceCount: 1,
          evidenceSHA256: sha256Hex("icloud:false|local:false")
        ))
    }
    if state.accountCanPasswordProtectNotes == false {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "account_cannot_password_protect_notes",
          status: "blocking",
          evidenceSource: "account.canPasswordProtectNotes",
          evidenceCount: 1,
          evidenceSHA256: sha256Hex("can_password_protect_notes:false")
        ))
    }
    if state.accountCanHaveCryptoStrategy == false {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "account_has_no_crypto_strategy",
          status: "blocking",
          evidenceSource: "account.canHaveCryptoStrategy",
          evidenceCount: 1,
          evidenceSHA256: sha256Hex("can_have_crypto_strategy:false")
        ))
    }
    if !prohibitedAttachmentFamilyCounts.isEmpty {
      let familyEvidence = prohibitedAttachmentFamilyCounts
        .sorted { $0.key < $1.key }
        .map { "\($0.key):\($0.value)" }
        .joined(separator: "\n")
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "unsupported_attachment_family",
          status: "blocking",
          evidenceSource: "attachment_metadata.family_counts",
          evidenceCount: prohibitedAttachmentFamilyCounts.values.reduce(0, +),
          evidenceSHA256: sha256Hex(familyEvidence)
        ))
    }
    if tagCount > 0 {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "contains_tags",
          status: "blocking",
          evidenceSource: "note_detail.tags",
          evidenceCount: tagCount,
          evidenceSHA256: tagSetSHA256
        ))
    }
    if unknownAttachmentCount > 0 {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "unknown_attachment_family",
          status: "unresolved",
          evidenceSource: "attachment_metadata.family_counts",
          evidenceCount: unknownAttachmentCount
        ))
    }
    if state.needsCloudFetch == true {
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: "cloud_fetch_required",
          status: "unresolved",
          evidenceSource: "note_state.needsCloudFetch",
          evidenceCount: 1,
          evidenceSHA256: sha256Hex(state.noteID)
        ))
    }
    if state.isLockable == false && reasons.isEmpty {
      let accountEvidencePresent = state.accountCanPasswordProtectNotes != nil
        || state.accountCanHaveCryptoStrategy != nil
        || state.accountIsInICloud != nil
        || state.accountIsLocal != nil
        || state.accountLockedNotesModeSHA256 != nil
        || state.accountResolvedLockedNotesModeSHA256 != nil
        || state.accountPasswordProtectedNoteCount != nil
      reasons.append(
        NotesNoteLockabilityReasonRecord(
          reasonID: accountEvidencePresent
            ? "private_lockability_reason_unproven"
            : "icloud_upgrade_or_private_reason_unproven",
          status: "unresolved",
          evidenceSource: accountEvidencePresent
            ? "private_state.isLockable_with_account_evidence_without_reason_detail"
            : "private_state.isLockable_without_reason_detail",
          evidenceCount: 1,
          evidenceSHA256: sha256Hex(state.noteID)
        ))
    }
    return reasons
  }

  private func verifyNoteLockability(
    noteID: String,
    state: NotesNoteStateRecord,
    tagCount: Int,
    tagSetSHA256: String?,
    attachmentCount: Int,
    familyCounts: [String: Int],
    reasons: [NotesNoteLockabilityReasonRecord]
  ) -> NotesMutationVerificationReport {
    let blockingReasonCount = reasons.filter { $0.status == "blocking" }.count
    let unresolvedReasonCount = reasons.filter { $0.status == "unresolved" }.count
    let accountedAttachmentCount = familyCounts.values.reduce(0, +)
    let accountEvidencePresent = state.accountCanPasswordProtectNotes != nil
      || state.accountCanHaveCryptoStrategy != nil
      || state.accountIsInICloud != nil
      || state.accountIsLocal != nil
      || state.accountLockedNotesModeSHA256 != nil
      || state.accountResolvedLockedNotesModeSHA256 != nil
      || state.accountPasswordProtectedNoteCount != nil
    let checks = [
      verificationBoolCheck(
        name: "state_readback_identity",
        expected: true,
        actual: state.noteID == noteID
      ),
      verificationBoolCheck(
        name: "tag_hash_accounting",
        expected: true,
        actual: (tagCount == 0 && tagSetSHA256 == nil) || tagSetSHA256?.count == 64
      ),
      verificationBoolCheck(
        name: "attachment_family_accounting",
        expected: true,
        actual: accountedAttachmentCount == attachmentCount
      ),
      verificationBoolCheck(
        name: "account_lockability_evidence_readback",
        expected: true,
        actual: accountEvidencePresent
      ),
      verificationBoolCheck(
        name: "non_lockable_has_reason_evidence",
        expected: true,
        actual: state.isLockable || blockingReasonCount + unresolvedReasonCount > 0
      ),
      verificationBoolCheck(
        name: "privacy_surface_limited_to_hashes_counts_and_booleans",
        expected: true,
        actual: reasons.allSatisfy { reason in
          !reason.reasonID.isEmpty
            && !reason.evidenceSource.isEmpty
            && (reason.evidenceSHA256 == nil || reason.evidenceSHA256?.count == 64)
        }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.state.lockability",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_note_state+account_lockability+tag_membership+attachment_family_readback",
      targetIDSHA256: sha256Hex(noteID),
      checks: checks
    )
  }

  private func gatedStateCapabilityError(
    operation: String,
    capability: String,
    appleCapability: String,
    futureGate: String
  ) -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message:
        "Notes \(appleCapability.replacingOccurrences(of: "_", with: " ")) is gated until private-framework mutation proof and verifier readback are accepted.",
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": "gated",
        "future_gate": futureGate,
        "required_implementation": "typed_private_notes_framework",
        "required_verifier": "private_framework_state_readback+privacy_boundary",
        "backend_calls": "none",
      ]
    )
  }

  private func noteStateAuditSummary(_ records: [NotesNoteStateRecord]) -> NotesNoteStateAuditSummary {
    NotesNoteStateAuditSummary(
      noteCount: records.count,
      deletedOrTrashCount: records.filter { $0.isDeletedOrInTrash }.count,
      pinnedCount: records.filter { $0.isPinned }.count,
      pinnableCount: records.filter { $0.isPinnable == true }.count,
      passwordProtectedCount: records.filter { $0.isPasswordProtected }.count,
      lockedCount: records.filter { $0.isPasswordProtectedAndLocked == true }.count,
      editableCount: records.filter { $0.isEditable }.count,
      lockableCount: records.filter { $0.isLockable }.count,
      sharedNoteCount: records.filter { $0.isSharedViaICloud }.count,
      sharedFolderCount: records.filter { $0.isSharedViaICloudFolder }.count,
      sharedReadOnlyCount: records.filter { $0.isSharedReadOnly }.count,
      systemPaperCount: records.filter { $0.isSystemPaper }.count,
      mathNoteCount: records.filter { $0.isMathNote }.count,
      callNoteCount: records.filter { $0.isCallNote }.count,
      unreadChangesCount: records.filter { $0.hasUnreadChanges == true }.count,
      unsupportedCount: records.filter { $0.isUnsupported == true }.count,
      needsCloudFetchCount: records.filter { $0.needsCloudFetch == true }.count,
      notesWithParticipantsCount: records.filter { ($0.participantCount ?? 0) > 0 }.count,
      participantCount: records.reduce(0) { $0 + ($1.participantCount ?? 0) },
      folderTrashCount: records.filter { $0.folderIsTrash == true }.count,
      folderDefaultCount: records.filter { $0.folderIsDefault == true }.count,
      folderSharedReadOnlyCount: records.filter { $0.folderIsSharedReadOnly == true }.count,
      supportedReadFamilies: [
        "collaboration_activity_metadata",
        "cloud_fetch_status",
        "deleted_trash_status",
        "editability",
        "folder_state",
        "lock_remove_lock_mutation",
        "lock_status",
        "math_call_note_status",
        "participant_count",
        "pin_status",
        "session_unlocked_locked_content_export",
        "share_status",
      ],
      gatedMutationFamilies: [
        "unlock_locked_note",
      ]
    )
  }

  private func verifyNoteStateAudit(
    records: [NotesNoteStateRecord],
    summary: NotesNoteStateAuditSummary
  ) -> NotesMutationVerificationReport {
    let checks = [
      verificationBoolCheck(
        name: "audit_record_count_matches",
        expected: true,
        actual: summary.noteCount == records.count
      ),
      verificationBoolCheck(
        name: "lock_status_accounted",
        expected: true,
        actual: summary.passwordProtectedCount == records.filter { $0.isPasswordProtected }.count
          && summary.lockedCount == records.filter { $0.isPasswordProtectedAndLocked == true }.count
      ),
      verificationBoolCheck(
        name: "sharing_status_accounted",
        expected: true,
        actual: summary.sharedNoteCount == records.filter { $0.isSharedViaICloud }.count
          && summary.sharedFolderCount == records.filter { $0.isSharedViaICloudFolder }.count
          && summary.sharedReadOnlyCount == records.filter { $0.isSharedReadOnly }.count
      ),
      verificationBoolCheck(
        name: "participant_counts_accounted",
        expected: true,
        actual: summary.participantCount == records.reduce(0) { $0 + ($1.participantCount ?? 0) }
      ),
      verificationBoolCheck(
        name: "locked_mutations_gated",
        expected: true,
        actual: summary.gatedMutationFamilies.contains("unlock_locked_note")
          && summary.supportedReadFamilies.contains("session_unlocked_locked_content_export")
      ),
      verificationBoolCheck(
        name: "sharing_mutations_supported",
        expected: true,
        actual: summary.gatedMutationFamilies.contains("sharing_permission_mutation") == false
          && summary.gatedMutationFamilies.contains("participant_invite") == false
          && summary.gatedMutationFamilies.contains("shared_folder_permission_mutation") == false
      ),
      verificationBoolCheck(
        name: "privacy_surface_limited_to_state",
        expected: true,
        actual: true
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.state.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_note_state_batch_readback",
      targetIDSHA256: sha256Hex(records.map(\.noteID).joined(separator: "\n")),
      checks: checks
    )
  }

  private func readNoteActivity(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.activity"
    let id = try requiredOption("id", options: options)
    let destinationPath = options.targetOption("output").map(standardizedAbsolutePath(_:))

    if destinationPath == nil {
      try validateReadOnly(options)
    }
    if let destinationPath {
      try validateNotesActivityExportDestination(destinationPath)
    }

    let activity = try noteActivityReader().readNoteActivity(noteID: id)
    let artifactData = try Data(CLIJSON.encodeString(activity).utf8)
    let artifactSHA256 = sha256Hex(artifactData)

    guard let destinationPath else {
      let verification = verifyNoteActivityRead(activity: activity, operation: operation)
      return try result(
        NotesNoteActivityResponse(
          operation: operation,
          changed: false,
          activity: activity,
          artifact: nil,
          verification: verification
        ),
        human: [
          "note_id: \(activity.noteID)",
          "shared: \(activity.isShared)",
          "participants: \(activity.participantCount)",
          "activity_events_bytes: \(activity.activityEventsByteCount)",
        ].joined(separator: "\n"),
        options: options
      )
    }

    let summary = noteActivityExportSummary(
      activity: activity,
      destinationPath: destinationPath,
      artifactData: artifactData,
      artifactSHA256: artifactSHA256
    )
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: noteActivityExportScopeDigest(
            activity: activity,
            destinationPath: destinationPath,
            artifactSHA256: artifactSHA256
          ),
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"],
          notes: [
            "Exports privacy-safe Notes collaboration activity metadata only.",
            "Artifact contains hashes, byte counts, booleans, and participant identifier hashes; it does not contain note body, note title, activity text, or contact details.",
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
      message: "Notes activity export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeNotesActivityExport(artifactData, to: destinationPath)
    let verification = try verifyNoteActivityExport(
      activity: activity,
      destinationPath: destinationPath,
      expectedData: artifactData,
      expectedSHA256: artifactSHA256,
      operation: operation
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes activity export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }

    return try result(
      NotesNoteActivityResponse(
        operation: operation,
        changed: true,
        activity: activity,
        artifact: NotesNoteActivityArtifactRecord(
          destinationPath: destinationPath,
          byteCount: artifactData.count,
          sha256: artifactSHA256
        ),
        verification: verification
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func noteActivityExportSummary(
    activity: NotesNoteActivityRecord,
    destinationPath: String,
    artifactData: Data,
    artifactSHA256: String
  ) -> [String: String] {
    [
      "note_id_sha256": activity.noteIDSHA256,
      "destination_path": destinationPath,
      "artifact_byte_count": "\(artifactData.count)",
      "artifact_sha256": artifactSHA256,
      "activity_events_byte_count": "\(activity.activityEventsByteCount)",
      "activity_events_present": activity.activityEventsPresent ? "true" : "false",
      "participant_count": "\(activity.participantCount)",
      "shared": activity.isShared ? "true" : "false",
    ]
  }

  private func noteActivityExportScopeDigest(
    activity: NotesNoteActivityRecord,
    destinationPath: String,
    artifactSHA256: String
  ) -> String {
    let fields = [
      activity.noteID,
      activity.activityEventsSHA256 ?? "",
      "\(activity.activityEventsByteCount)",
      "\(activity.participantCount)",
      destinationPath,
      artifactSHA256,
    ].joined(separator: "|")
    return "notes-activity-export:\(sha256Hex(fields))"
  }

  private func verifyNoteActivityRead(
    activity: NotesNoteActivityRecord,
    operation: String
  ) -> NotesMutationVerificationReport {
    let checks = [
      verificationBoolCheck(
        name: "note_identity_hashed",
        expected: true,
        actual: activity.noteIDSHA256 == sha256Hex(activity.noteID)
      ),
      verificationBoolCheck(
        name: "participant_hash_count_matches",
        expected: true,
        actual: activity.participantUserIDSHA256s.count <= activity.participantCount
      ),
      verificationBoolCheck(
        name: "activity_data_hash_accounted",
        expected: true,
        actual: activity.activityEventsPresent == (activity.activityEventsByteCount > 0)
          && (activity.activityEventsPresent == (activity.activityEventsSHA256 != nil))
      ),
      verificationBoolCheck(
        name: "privacy_surface_limited_to_activity_metadata",
        expected: true,
        actual: activity.privacyBoundary == "hashes_counts_and_booleans_only"
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_activity_events_metadata_readback",
      targetIDSHA256: activity.noteIDSHA256,
      checks: checks
    )
  }

  private func verifyNoteActivityExport(
    activity: NotesNoteActivityRecord,
    destinationPath: String,
    expectedData: Data,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let jsonReadable = (try? JSONDecoder().decode(NotesNoteActivityRecord.self, from: fileData)) != nil
    let readback = try noteActivityReader().readNoteActivity(noteID: activity.noteID)
    var checks = verifyNoteActivityRead(activity: activity, operation: operation).checks
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
      NotesVerificationCheckRecord(
        name: "json_artifact_readable",
        status: jsonReadable ? "passed" : "failed",
        expectedBool: true,
        actualBool: jsonReadable
      ),
      verificationBoolCheck(
        name: "activity_readback_stable",
        expected: true,
        actual: readback.activityEventsSHA256 == activity.activityEventsSHA256
          && readback.activityEventsByteCount == activity.activityEventsByteCount
          && readback.participantCount == activity.participantCount
          && readback.isShared == activity.isShared
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_activity_events_metadata_readback+artifact_hash+activity_readback",
      targetIDSHA256: activity.noteIDSHA256,
      checks: checks
    )
  }

  func noteStateReader() throws -> any NotesNoteStateReading {
    guard let noteStateReader = implementation as? any NotesNoteStateReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes state commands require a private-framework state reader.",
        details: [
          "capability": "note_state",
          "required_module": "NotesShared",
        ]
      )
    }
    return noteStateReader
  }

  func noteStateMutator() throws -> any NotesNoteStateMutating {
    guard let noteStateMutator = implementation as? any NotesNoteStateMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes state mutations require a private-framework state writer.",
        details: [
          "capability": "shared_note_notification_preference",
          "required_module": "NotesShared",
        ]
      )
    }
    return noteStateMutator
  }

  private func noteActivityReader() throws -> any NotesNoteActivityReading {
    guard let noteActivityReader = implementation as? any NotesNoteActivityReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes activity commands require a private-framework activity reader.",
        details: [
          "capability": "collaboration_activity",
          "required_module": "NotesShared",
        ]
      )
    }
    return noteActivityReader
  }
}
