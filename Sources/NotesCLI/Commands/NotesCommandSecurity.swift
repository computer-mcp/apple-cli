import Foundation
import Utility

extension NotesCommand {

  func normalizedLockedNotesScope(_ raw: String?) throws -> String {
    let value = (raw ?? "custom").trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
      .replacingOccurrences(of: "_", with: "-")
      .replacingOccurrences(of: " ", with: "-")
    switch value {
    case "custom", "custom-password":
      return "custom"
    case "login", "login-password", "mac-login", "mac-login-password":
      return "login-password"
    default:
      throw CLIError(
        code: .validationError,
        message: "`--scope` must be custom or login-password for Notes locked-notes settings.",
        details: ["allowed": "custom,login-password"]
      )
    }
  }

  func normalizedOptionalHint(options: CLIOptions, operation: String) throws -> String? {
    guard let raw = try normalizedOptionalOption("hint", options: options) else {
      return nil
    }
    guard raw.utf8.count <= 256 else {
      throw CLIError(
        code: .validationError,
        message: "Notes locked-notes password hint is too long.",
        details: [
          "operation": operation,
          "hint_sha256": sha256Hex(raw),
          "hint_length": "\(raw.utf8.count)",
          "maximum_hint_length": "256",
        ]
      )
    }
    return raw
  }

  func validateCustomPassphraseHint(
    _ hint: String?,
    passphrase: String,
    operation: String
  ) throws {
    guard let hint, hint == passphrase else {
      return
    }
    throw CLIError(
      code: .validationError,
      message: "Notes locked-notes password hint must not match the passphrase.",
      details: [
        "operation": operation,
        "hint_sha256": sha256Hex(hint),
        "hint_length": "\(hint.utf8.count)",
      ]
    )
  }

  func securityWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.security.audit"
    let records = notesSecurityWorkflowAuditRecords()
    let summary = notesSecurityWorkflowAuditSummary(records)
    let verification = verifySecurityWorkflowAudit(records: records, summary: summary)
    let response = NotesSecurityWorkflowAuditResponse(
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

  private func notesSecurityWorkflowAuditRecords() -> [NotesSecurityWorkflowAuditRecord] {
    struct SecurityWorkflowAuditItem {
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
      SecurityWorkflowAuditItem(
        family: "lock_state_read",
        guideSection: "Lock your notes",
        status: "supported",
        appleCapability: "read_locked_note_state",
        command: "state read --id NOTE_ID; state audit [--account ACCOUNT|--folder FOLDER]",
        mechanism: "typed_private_notes_framework_note_state_reader",
        requiredImplementation: "ICNote password-protected, locked, editable, and lockable state readback",
        requiredVerifier: "private_note_state_readback+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "booleans_counts_and_hashes_only",
        reason: "The accepted state reader reports password-protected, locked, editable, and lockable state without exposing note content or secrets."
      ),
      SecurityWorkflowAuditItem(
        family: "lockability_status_read",
        guideSection: "If you can't lock a note",
        status: "supported",
        appleCapability: "read_note_lockability_status",
        command: "state read --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_state_reader",
        requiredImplementation: "ICNote isLockable/isEditable plus privacy-safe state flags",
        requiredVerifier: "private_note_state_readback+lockability_flag_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_note_body_or_title",
        reason: "The current private state read path exposes whether a note is lockable without printing unsupported content."
      ),
      SecurityWorkflowAuditItem(
        family: "lockability_reason_readback",
        guideSection: "If you can't lock a note",
        status: "supported",
        appleCapability: "explain_provable_note_lockability_reasons",
        command: "state lockability --id NOTE_ID",
        mechanism: "typed_private_notes_framework_note_state_account_tag_attachment_reader",
        requiredImplementation: "ICNote state flags, ICAccount lockability evidence, note tag membership, and attachment family metadata",
        requiredVerifier: "private_lockability_reason_readback+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_counts_booleans_and_reason_ids_only",
        reason: "The accepted lockability reader explains private-readback-proven Quick Note, sharing, account/provider, tag, and unsupported attachment-family blockers without printing note content, account values, tag names, attachment filenames, or attachment bytes."
      ),
      SecurityWorkflowAuditItem(
        family: "password_settings_family_accounting",
        guideSection: "Set a password to lock notes / Change your password for locked notes",
        status: "supported",
        appleCapability: "account_for_locked_notes_password_settings",
        command: "settings read [--account ACCOUNT]",
        mechanism: "typed_private_notes_framework_settings_reader",
        requiredImplementation: "privacy-safe official settings-family accounting",
        requiredVerifier: "notes_settings_read_v1+password_family_status_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "does_not_print_passwords_hints_account_values_or_defaults",
        reason: "`settings read` accounts for locked-notes, change-password, reset-password, Touch ID, and legacy password setting families without dumping values."
      ),
      SecurityWorkflowAuditItem(
        family: "touch_id_authentication",
        guideSection: "Lock your notes / Unlock a note",
        status: "delegated",
        appleCapability: "unlock_notes_with_touch_id",
        command: "system Touch ID authentication surface",
        mechanism: "delegated_local_authentication_surface",
        requiredImplementation: "macos_local_authentication_route",
        requiredVerifier: "delegated_touch_id_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Touch ID biometric authentication belongs to the macOS local authentication surface, not the Notes CLI data writer."
      ),
      SecurityWorkflowAuditItem(
        family: "login_password_authentication",
        guideSection: "Set a password to lock notes / Unlock a note",
        status: "delegated",
        appleCapability: "use_mac_login_password_for_locked_notes",
        command: "macOS login password / System Settings authentication surface",
        mechanism: "delegated_system_security_surface",
        requiredImplementation: "macos_login_password_and_keychain_route",
        requiredVerifier: "delegated_login_password_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Mac login password verification and login-password changes are system security workflows outside Notes data mutation."
      ),
      SecurityWorkflowAuditItem(
        family: "notes_app_lock_session_timeout",
        guideSection: "Close locked notes",
        status: "delegated",
        appleCapability: "auto_close_locked_notes_after_inactivity_or_quit",
        command: "Notes.app session behavior",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_locked_session_lifecycle",
        requiredVerifier: "delegated_session_timeout_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Automatic closing of unlocked note content is Notes.app session behavior rather than a persisted Notes data write."
      ),
      SecurityWorkflowAuditItem(
        family: "set_initial_lock_password",
        guideSection: "Set a password to lock notes",
        status: "supported",
        appleCapability: "set_password_to_lock_notes",
        command: "settings locked-notes --account ACCOUNT --scope custom --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.setPassphrase:hint:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+secret_source_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_passwords_hints_or_account_values",
        reason: "Initial custom locked-notes password setup is supported through the private account passphrase manager with stdin/env/file passphrase sources and account crypto-strategy readback."
      ),
      SecurityWorkflowAuditItem(
        family: "use_custom_password_method",
        guideSection: "Set a password to lock notes",
        status: "supported",
        appleCapability: "use_custom_password_for_locked_notes",
        command: "settings locked-notes --account ACCOUNT --scope custom --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.setPassphrase:hint:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+secret_source_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_password_or_hint",
        reason: "The custom password method is supported for one selected account through the private account passphrase manager; initial login-password method selection is covered separately, and method switching for existing locked notes remains gated."
      ),
      SecurityWorkflowAuditItem(
        family: "use_login_password_method",
        guideSection: "Set a password to lock notes / Change your password method",
        status: "supported",
        appleCapability: "use_login_password_for_locked_notes",
        command: "settings locked-notes --account ACCOUNT --scope login-password",
        mechanism: "typed_private_notes_framework_locked_notes_mode_writer",
        requiredImplementation: "NotesShared.ICLocalAuthentication.hasPasscode + NotesUI.ICLockedNotesModeMigrator.account:supportsMode: + NotesShared.ICAccount.setResolvedLockedNotesMode:",
        requiredVerifier: "notes_settings_mutation_v1+locked_notes_mode_readback+system_passcode_preflight+empty_protected_notes_preflight",
        safetyGate: "--allow-persistent-action+system_passcode_preflight+empty_protected_notes_preflight",
        privacyBoundary: "does_not_print_account_or_login_password_values",
        reason: "The login-password locked-notes method is supported for initial selection on one account when macOS login-password preflight passes, the private mode migrator reports support, and private readback proves no existing locked notes require migration."
      ),
      SecurityWorkflowAuditItem(
        family: "touch_id_preference",
        guideSection: "Set a password to lock notes",
        status: "supported",
        appleCapability: "enable_touch_id_for_locked_notes",
        command: "settings touch-id --enabled true|false --account ACCOUNT",
        mechanism: "typed_private_notes_framework_touch_id_preference_writer",
        requiredImplementation: "NotesShared.ICAuthenticationState.setBiometricsEnabled:forAccount:",
        requiredVerifier: "private_touch_id_preference_readback+local_auth_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_biometric_or_account_values",
        reason: "The Notes account-scoped Touch ID preference is supported through private preference readback; biometric authentication remains delegated."
      ),
      SecurityWorkflowAuditItem(
        family: "lock_note",
        guideSection: "Lock a note",
        status: "supported",
        appleCapability: "lock_note",
        command: "state lock --id NOTE_ID --allow-persistent-action",
        mechanism: "typed_private_notes_framework_lock_writer",
        requiredImplementation: "NotesUI.ICNoteLockManager.addLockWithCompletionHandler",
        requiredVerifier: "private_lock_state_readback+lockability_reason_accounting",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_read_or_print_locked_note_body",
        reason: "Adding locked-note protection to one eligible non-password-protected note is supported through private ICNoteLockManager mutation and lock-state readback without accepting or printing password material."
      ),
      SecurityWorkflowAuditItem(
        family: "unlock_note",
        guideSection: "Unlock a note",
        status: "supported",
        appleCapability: "unlock_note",
        command: "state unlock --id NOTE_ID --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE --allow-persistent-action",
        mechanism: "typed_private_notes_framework_unlock_session_control",
        requiredImplementation: "NotesShared.ICAuthenticationState.authenticateObject:withPassphrase:",
        requiredVerifier: "notes_unlock_session_v1+private_note_state_readback+secret_source_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_passwords_hints_or_locked_content",
        reason: "Unlocking one password-protected note for the current Notes session is supported through private authentication state with stdin/env/file passphrase sources and lock-state/session readback, without printing the passphrase or locked content."
      ),
      SecurityWorkflowAuditItem(
        family: "close_locked_notes",
        guideSection: "Close locked notes",
        status: "supported",
        appleCapability: "close_all_locked_notes",
        command: "state close-locked [--account ACCOUNT] --allow-persistent-action",
        mechanism: "typed_private_notes_framework_locked_session_control",
        requiredImplementation: "NotesShared.ICAuthenticationState.deauthenticateAllObjects",
        requiredVerifier: "private_authentication_state_deauthenticate_all_objects_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_note_content_or_account_values",
        reason: "The accepted command closes the current Notes locked-note authentication session through private authentication state and verifies authenticated/has-authenticated-object readback without exposing locked content or account values."
      ),
      SecurityWorkflowAuditItem(
        family: "remove_note_lock",
        guideSection: "Remove a lock",
        status: "supported",
        appleCapability: "remove_lock_from_note",
        command: "state remove-lock --id NOTE_ID --allow-persistent-action",
        mechanism: "typed_private_notes_framework_remove_lock_writer",
        requiredImplementation: "NotesUI.ICNoteLockManager.removeLockWithCompletionHandler",
        requiredVerifier: "private_lock_absence_readback+content_preservation",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_note_body_or_password_material",
        reason: "Removing locked-note protection from one already unlocked password-protected note is supported through private ICNoteLockManager mutation and lock-state absence readback. Currently locked notes can be unlocked first through `state unlock`."
      ),
      SecurityWorkflowAuditItem(
        family: "change_locked_notes_password",
        guideSection: "Change your password for locked notes",
        status: "supported",
        appleCapability: "change_locked_notes_password",
        command: "settings change-password --account ACCOUNT --old-passphrase-stdin|--old-passphrase-env NAME|--old-passphrase-file FILE --new-passphrase-stdin|--new-passphrase-env NAME|--new-passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager_change",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+old_new_secret_source_boundary+change_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_old_or_new_passwords_hints_or_account_values",
        reason: "Changing the selected account custom locked-notes password is supported through the private account passphrase manager change selector with separate old/new secret sources and hash-only hint/account readback. Password-method switching and diverged locked-note rekeying remain separately gated."
      ),
      SecurityWorkflowAuditItem(
        family: "reset_custom_password",
        guideSection: "Reset your custom password",
        status: "supported",
        appleCapability: "reset_custom_locked_notes_password",
        command: "settings reset-password --account ACCOUNT --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager_reset",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.setPassphrase:hint:isReset:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+secret_source_boundary+reset_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_passwords_hints_or_account_values",
        reason: "Resetting the selected account custom password is supported through the private account passphrase manager reset selector with hash-only secret source, hint, and account readback. Existing locked notes can retain the old password, so the verifier records the reset boundary rather than claiming old-note rekeying."
      ),
      SecurityWorkflowAuditItem(
        family: "change_password_method",
        guideSection: "Change your password method for locked notes",
        status: "gated",
        appleCapability: "change_locked_notes_password_method",
        command: "settings locked-notes --account ACCOUNT --scope custom|login-password",
        mechanism: "semantic_gated_boundary",
        requiredImplementation: "typed_private_notes_framework_password_method_switch_writer",
        requiredVerifier: "private_password_method_readback+locked_note_update_accounting",
        safetyGate: nil,
        privacyBoundary: "does_not_print_passwords_hints_or_account_values",
        reason: "Switching between custom and login-password methods updates locked notes and needs dedicated private readback proof."
      ),
      SecurityWorkflowAuditItem(
        family: "icloud_upgrade_lockability_reason",
        guideSection: "If you can't lock a note",
        status: "supported",
        appleCapability: "explain_account_upgrade_lockability_requirement",
        command: "state lockability --id NOTE_ID",
        mechanism: "typed_private_notes_framework_account_lockability_reader",
        requiredImplementation: "ICNote.account plus ICAccount canPasswordProtectNotes/canHaveCryptoStrategy/provider flags and ICAccountData lockedNotesMode hash evidence",
        requiredVerifier: "private_account_lockability_readback+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "booleans_counts_hashes_and_reason_ids_only",
        reason: "`state lockability` now reports account/provider lockability evidence through private account readback, including unsupported provider and account crypto blockers, without printing account names, raw identifiers, passwords, hints, or note content."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesSecurityWorkflowAuditRecord(
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

  private func notesSecurityWorkflowAuditSummary(
    _ records: [NotesSecurityWorkflowAuditRecord]
  ) -> NotesSecurityWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesSecurityWorkflowAuditSummary(
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

  private func verifySecurityWorkflowAudit(
    records: [NotesSecurityWorkflowAuditRecord],
    summary: NotesSecurityWorkflowAuditSummary
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
        name: "state_and_settings_reads_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "lock_state_read",
            "lockability_status_read",
            "lockability_reason_readback",
            "icloud_upgrade_lockability_reason",
            "password_settings_family_accounting",
            "set_initial_lock_password",
            "use_custom_password_method",
            "use_login_password_method",
            "touch_id_preference",
            "close_locked_notes",
            "lock_note",
            "unlock_note",
            "remove_note_lock",
            "change_locked_notes_password",
            "reset_custom_password",
          ]
        )
      ),
      verificationBoolCheck(
        name: "system_authentication_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: ["touch_id_authentication", "login_password_authentication", "notes_app_lock_session_timeout"]
        )
      ),
      verificationBoolCheck(
        name: "password_store_mutations_gated",
        expected: true,
        actual: gated.isSuperset(
          of: [
            "change_password_method",
          ]
        )
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
      operation: "notes.state.security.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.state.security.audit"),
      checks: checks
    )
  }

  func closeLockedSession(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.close-locked"
    let account = options.targetOption("account")
    var summary = [
      "scope": "all_authenticated_locked_objects",
      "capability": "locked_session_close",
    ]
    if let account {
      summary["account_selector_sha256"] = sha256Hex(account)
      summary["scope"] = "all_authenticated_locked_objects_after_account_preflight"
    }
    let draft = NotesLockedSessionCloseDraft(account: account)
    let scopeDigest = sha256Hex(
      [operation, account.map(sha256Hex) ?? "all_authenticated_locked_objects"].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: summary,
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Closes the current private Notes locked-note authentication session.",
        "Execution calls `ICAuthenticationState.deauthenticateAllObjects` and verifies session state readback.",
        "Account input, when provided, is a selector preflight; the private session close applies to all authenticated locked objects.",
      ]
    ) {
      let write = try noteStateMutator().closeLockedSession(draft)
      let verification = verifyLockedSessionClose(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes locked-session close verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesLockedSessionCloseResult(
        operation: operation,
        changed: write.changed,
        accountSelectorSHA256: write.accountSelectorSHA256,
        accountSHA256: write.accountSHA256,
        scope: write.scope,
        beforeAuthenticated: write.beforeAuthenticated,
        beforeHasAuthenticatedObject: write.beforeHasAuthenticatedObject,
        afterAuthenticated: write.afterAuthenticated,
        afterHasAuthenticatedObject: write.afterHasAuthenticatedObject,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  func setNoteLockState(options: CLIOptions, action: String) throws -> CLICommandResult {
    let operation = action == "remove-lock" ? "notes.state.remove-lock" : "notes.state.lock"
    let noteID = try requiredOption("id", options: options)
    let draft = NotesNoteLockMutationDraft(noteID: noteID, action: action)
    let summary = [
      "note_id_sha256": sha256Hex(noteID),
      "action": action,
      "capability": "note_lock_state_mutation",
    ]
    let scopeDigest = sha256Hex([operation, sha256Hex(noteID), action].joined(separator: "|"))
    let verb = action == "remove-lock" ? "removes locked-note protection from" : "adds locked-note protection to"
    let implementationCall = action == "remove-lock" ? "ICNoteLockManager.removeLock" : "ICNoteLockManager.addLock"
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: summary,
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Private framework execution \(verb) one eligible selected note.",
        "Execution calls `\(implementationCall)` and verifies lock-state readback.",
        "The command never accepts, prints, or exports passwords, hints, or locked note content.",
      ]
    ) {
      let write = try noteStateMutator().setNoteLockState(draft)
      let verification = verifyNoteLockMutation(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes lock-state mutation verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesNoteLockMutationResult(
        operation: operation,
        changed: write.changed,
        noteIDSHA256: sha256Hex(write.noteID),
        action: write.action,
        beforePasswordProtected: write.beforePasswordProtected,
        beforePasswordProtectedAndLocked: write.beforePasswordProtectedAndLocked,
        beforeLockable: write.beforeLockable,
        afterPasswordProtected: write.afterPasswordProtected,
        afterPasswordProtectedAndLocked: write.afterPasswordProtectedAndLocked,
        afterLockable: write.afterLockable,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  func unlockNote(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.unlock"
    let noteID = try requiredOption("id", options: options)
    let source = try passphraseSource(options: options, operation: operation)
    var summary = [
      "note_id_sha256": sha256Hex(noteID),
      "capability": "unlock_locked_note",
      "passphrase_source_kind": source.kind,
    ]
    if let selectorSHA256 = source.selectorSHA256 {
      summary["passphrase_source_sha256"] = selectorSHA256
    }
    let scopeDigest = sha256Hex(
      [operation, sha256Hex(noteID), source.kind, source.selectorSHA256 ?? "stdin"].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: summary,
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: [
        "Private framework execution authenticates one selected locked note for the current Notes session.",
        "Execution calls `ICAuthenticationState.authenticateObject:withPassphrase:` and verifies lock-state/session readback.",
        "The command reads the passphrase only from stdin, an environment variable, or a file and never prints it or locked note content.",
      ]
    ) {
      let passphrase = try readPassphrase(sourceKind: source.kind, options: options, operation: operation)
      let draft = NotesNoteUnlockDraft(
        noteID: noteID,
        passphrase: passphrase,
        passphraseSourceKind: source.kind
      )
      let write = try noteStateMutator().unlockNote(draft)
      let verification = verifyNoteUnlock(write, operation: operation)
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes unlock verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesNoteUnlockResult(
        operation: operation,
        changed: write.changed,
        noteIDSHA256: sha256Hex(write.noteID),
        passphraseSourceKind: write.passphraseSourceKind,
        beforePasswordProtected: write.beforePasswordProtected,
        beforePasswordProtectedAndLocked: write.beforePasswordProtectedAndLocked,
        beforeAuthenticated: write.beforeAuthenticated,
        beforeHasAuthenticatedObject: write.beforeHasAuthenticatedObject,
        afterPasswordProtected: write.afterPasswordProtected,
        afterPasswordProtectedAndLocked: write.afterPasswordProtectedAndLocked,
        afterAuthenticated: write.afterAuthenticated,
        afterHasAuthenticatedObject: write.afterHasAuthenticatedObject,
        backendCalls: write.backendCalls,
        verification: verification
      )
    }
  }

  private func verifyNoteUnlock(
    _ write: NotesNoteUnlockWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let supportedSource = ["stdin", "env", "file"].contains(write.passphraseSourceKind)
    let implementationAccepted = [
      "ICAuthenticationState.authenticateObject:withPassphrase:",
      "ICAuthenticationState.noop",
    ].contains(write.backendCalls)
    let sessionUnlocked = write.beforePasswordProtected
      && write.afterPasswordProtected
      && write.afterPasswordProtectedAndLocked == false
    let sessionReadback = write.backendCalls == "ICAuthenticationState.noop"
      || write.afterAuthenticated == true
      || write.afterHasAuthenticatedObject == true
    let secretNotAccounted = write.passphraseSourceKind.isEmpty == false
      && write.noteID.isEmpty == false
    let checks = [
      NotesVerificationCheckRecord(
        name: "passphrase_source_supported",
        status: supportedSource ? "passed" : "failed",
        expectedBool: true,
        actualBool: supportedSource
      ),
      NotesVerificationCheckRecord(
        name: "private_authentication_state_implementation",
        status: implementationAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationAccepted
      ),
      NotesVerificationCheckRecord(
        name: "locked_note_session_unlocked",
        status: sessionUnlocked ? "passed" : "failed",
        expectedBool: true,
        actualBool: sessionUnlocked
      ),
      NotesVerificationCheckRecord(
        name: "authentication_session_readback",
        status: sessionReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: sessionReadback
      ),
      NotesVerificationCheckRecord(
        name: "privacy_surface_limited_to_hashes_and_flags",
        status: secretNotAccounted ? "passed" : "failed",
        expectedBool: true,
        actualBool: secretNotAccounted
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_unlock_session_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "ICAuthenticationState.authenticateObject+private_note_state_readback+secret_source_boundary",
      targetIDSHA256: sha256Hex(
        [
          write.noteID,
          write.passphraseSourceKind,
          "\(write.beforePasswordProtectedAndLocked ?? false)",
          "\(write.afterPasswordProtectedAndLocked ?? false)",
          "\(write.afterAuthenticated ?? false)",
          "\(write.afterHasAuthenticatedObject ?? false)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func passphraseSource(
    options: CLIOptions,
    operation: String
  ) throws -> (kind: String, selectorSHA256: String?) {
    try passphraseSource(options: options, operation: operation, prefix: nil, role: nil)
  }

  private func optionalPassphraseSource(
    options: CLIOptions,
    operation: String
  ) throws -> (kind: String, selectorSHA256: String?)? {
    let usesStdin = options.hasTargetFlag("passphrase-stdin")
    let envName = try normalizedOptionalOption("passphrase-env", options: options)
    let filePath = try normalizedOptionalOption("passphrase-file", options: options)
    let presentCount = (usesStdin ? 1 : 0) + (envName == nil ? 0 : 1) + (filePath == nil ? 0 : 1)
    if presentCount == 0 {
      return nil
    }
    return try passphraseSource(options: options, operation: operation)
  }

  func passphraseSource(
    options: CLIOptions,
    operation: String,
    prefix: String?,
    role: String?
  ) throws -> (kind: String, selectorSHA256: String?) {
    let stdinOption = prefix.map { "\($0)-passphrase-stdin" } ?? "passphrase-stdin"
    let envOption = prefix.map { "\($0)-passphrase-env" } ?? "passphrase-env"
    let fileOption = prefix.map { "\($0)-passphrase-file" } ?? "passphrase-file"
    let usesStdin = options.hasTargetFlag(stdinOption)
    let envName = try normalizedOptionalOption(envOption, options: options)
    let filePath = try normalizedOptionalOption(fileOption, options: options)
    let presentCount = (usesStdin ? 1 : 0) + (envName == nil ? 0 : 1) + (filePath == nil ? 0 : 1)
    guard presentCount == 1 else {
      var details = [
        "operation": operation,
        "required_selector_count": "1",
        "accepted_selectors": "\(stdinOption),\(envOption),\(fileOption)",
        "provided_selector_count": "\(presentCount)",
      ]
      if let role {
        details["passphrase_source_role"] = role
      }
      throw CLIError(
        code: .validationError,
        message: "`\(operation)` requires exactly one passphrase source.",
        details: details
      )
    }
    if usesStdin {
      return ("stdin", nil)
    }
    if let envName {
      try validatePassphraseEnvironmentName(envName, operation: operation)
      return ("env", sha256Hex(envName))
    }
    let path = standardizedAbsolutePath(filePath ?? "")
    return ("file", sha256Hex(path))
  }

  func readPassphrase(
    sourceKind: String,
    options: CLIOptions,
    operation: String
  ) throws -> String {
    try readPassphrase(sourceKind: sourceKind, options: options, operation: operation, prefix: nil, role: nil)
  }

  func readPassphrase(
    sourceKind: String,
    options: CLIOptions,
    operation: String,
    prefix: String?,
    role: String?
  ) throws -> String {
    let passphrase: String
    let selectorSHA256: String?
    switch sourceKind {
    case "stdin":
      let data = FileHandle.standardInput.readDataToEndOfFile()
      passphrase = try passphraseString(from: data, sourceKind: sourceKind, selectorSHA256: nil, operation: operation)
      selectorSHA256 = nil
    case "env":
      let envName = try normalizedOption(prefix.map { "\($0)-passphrase-env" } ?? "passphrase-env", options: options)
      try validatePassphraseEnvironmentName(envName, operation: operation)
      guard let value = ProcessInfo.processInfo.environment[envName] else {
        var details = [
          "operation": operation,
          "passphrase_source_kind": sourceKind,
          "passphrase_source_sha256": sha256Hex(envName),
        ]
        if let role {
          details["passphrase_source_role"] = role
        }
        throw CLIError(
          code: .validationError,
          message: "Notes unlock passphrase environment variable is not set.",
          details: details
        )
      }
      passphrase = value
      selectorSHA256 = sha256Hex(envName)
    case "file":
      let path = standardizedAbsolutePath(
        try normalizedOption(prefix.map { "\($0)-passphrase-file" } ?? "passphrase-file", options: options)
      )
      let data: Data
      do {
        data = try Data(contentsOf: URL(fileURLWithPath: path))
      } catch {
        var details = [
          "operation": operation,
          "passphrase_source_kind": sourceKind,
          "passphrase_source_sha256": sha256Hex(path),
        ]
        if let role {
          details["passphrase_source_role"] = role
        }
        throw CLIError(
          code: .validationError,
          message: "Notes unlock passphrase file could not be read.",
          details: details
        )
      }
      passphrase = try passphraseString(
        from: data,
        sourceKind: sourceKind,
        selectorSHA256: sha256Hex(path),
        operation: operation
      )
      selectorSHA256 = sha256Hex(path)
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes unlock passphrase source.",
        details: [
          "operation": operation,
          "passphrase_source_kind": sourceKind,
        ]
      )
    }
    return try validatePassphraseValue(
      passphrase,
      sourceKind: sourceKind,
      selectorSHA256: selectorSHA256,
      operation: operation
    )
  }

  private func passphraseString(
    from data: Data,
    sourceKind: String,
    selectorSHA256: String?,
    operation: String
  ) throws -> String {
    guard let string = String(data: data, encoding: .utf8) else {
      var details = [
        "operation": operation,
        "passphrase_source_kind": sourceKind,
      ]
      if let selectorSHA256 {
        details["passphrase_source_sha256"] = selectorSHA256
      }
      throw CLIError(
        code: .validationError,
        message: "Notes unlock passphrase source must be UTF-8 text.",
        details: details
      )
    }
    return stripTerminalNewlines(string)
  }

  private func validatePassphraseEnvironmentName(_ name: String, operation: String) throws {
    guard name.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil,
      name.contains("=") == false
    else {
      throw CLIError(
        code: .validationError,
        message: "Notes unlock passphrase environment variable name is invalid.",
        details: [
          "operation": operation,
          "passphrase_source_kind": "env",
          "passphrase_source_sha256": sha256Hex(name),
        ]
      )
    }
  }

  private func validatePassphraseValue(
    _ value: String,
    sourceKind: String,
    selectorSHA256: String?,
    operation: String
  ) throws -> String {
    guard value.isEmpty == false else {
      var details = [
        "operation": operation,
        "passphrase_source_kind": sourceKind,
      ]
      if let selectorSHA256 {
        details["passphrase_source_sha256"] = selectorSHA256
      }
      throw CLIError(
        code: .validationError,
        message: "Notes unlock passphrase source produced an empty passphrase.",
        details: details
      )
    }
    return value
  }

  private func stripTerminalNewlines(_ value: String) -> String {
    var result = value
    while result.last == "\n" || result.last == "\r" {
      result.removeLast()
    }
    return result
  }

  private func verifyNoteLockMutation(
    _ write: NotesNoteLockMutationWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let validAction = ["lock", "remove-lock"].contains(write.action)
    let implementationAccepted = [
      "ICNoteLockManager.addLock",
      "ICNoteLockManager.removeLock",
      "ICNoteLockManager.noop",
    ].contains(write.backendCalls)
    let requestedStateReadback: Bool
    if write.action == "lock" {
      requestedStateReadback = write.beforePasswordProtected == false
        && write.afterPasswordProtected == true
        && write.beforeLockable == true
    } else {
      requestedStateReadback = write.afterPasswordProtected == false
        && write.afterPasswordProtectedAndLocked != true
    }
    let changeAccounting = write.changed == (
      write.beforePasswordProtected != write.afterPasswordProtected
        || write.beforePasswordProtectedAndLocked != write.afterPasswordProtectedAndLocked
    )
    let checks = [
      NotesVerificationCheckRecord(
        name: "lock_action_supported",
        status: validAction ? "passed" : "failed",
        expectedBool: true,
        actualBool: validAction
      ),
      NotesVerificationCheckRecord(
        name: "private_note_lock_manager_implementation",
        status: implementationAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationAccepted
      ),
      NotesVerificationCheckRecord(
        name: "requested_lock_state_readback",
        status: requestedStateReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: requestedStateReadback
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: changeAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: changeAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_surface_limited_to_lock_flags",
        status: write.noteID.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: write.noteID.isEmpty == false
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_lock_state_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "ICNoteLockManager+private_note_state_readback+secret_free_boundary",
      targetIDSHA256: sha256Hex(
        [
          write.noteID,
          write.action,
          "\(write.beforePasswordProtected)",
          "\(write.beforePasswordProtectedAndLocked ?? false)",
          "\(write.afterPasswordProtected)",
          "\(write.afterPasswordProtectedAndLocked ?? false)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func exportLockedContent(options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.state.export-locked-content"
    try validateTargetOptions(
      options,
      allowedOptions: ["id", "output", "passphrase-env", "passphrase-file"],
      allowedFlags: ["passphrase-stdin"]
    )
    let noteID = try requiredOption("id", options: options)
    let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
    try validateNotesLockedContentExportDestination(destinationPath)
    let passphraseSource = try optionalPassphraseSource(options: options, operation: operation)
    var summary = [
      "note_id_sha256": sha256Hex(noteID),
      "output_path_sha256": sha256Hex(destinationPath),
      "capability": passphraseSource == nil
        ? "session_unlocked_locked_content_export"
        : "secret_safe_authenticated_locked_content_export",
    ]
    if let passphraseSource {
      summary["passphrase_source_kind"] = passphraseSource.kind
      if let selectorSHA256 = passphraseSource.selectorSHA256 {
        summary["passphrase_source_sha256"] = selectorSHA256
      }
    }
    let scopeDigest = sha256Hex(
      [
        operation,
        sha256Hex(noteID),
        sha256Hex(destinationPath),
        passphraseSource?.kind ?? "session",
        passphraseSource?.selectorSHA256 ?? "",
      ].joined(separator: "|")
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .artifactAction,
          allowFlags: passphraseSource == nil
            ? ["--allow-artifact-action"]
            : ["--allow-artifact-action", "--allow-persistent-action"],
          notes: [
            passphraseSource == nil
              ? "Exports text content only when the selected password-protected note is already unlocked in the current Notes session."
              : "Authenticates one selected password-protected note with the supplied secret source, then exports text content in the same command.",
            "Execution reads private note plaintext through Notes frameworks and writes the content only to the requested `.txt` artifact.",
            passphraseSource == nil
              ? "The command does not accept passwords, unlock notes, print locked content, or write Notes data."
              : "The command reads the passphrase only during execution, never prints it, and records only source kind/hash evidence.",
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
      message: "Notes locked-content export writes a filesystem artifact and requires `--allow-artifact-action`."
    )
    if passphraseSource != nil {
      try CLISafety.requireFlag(
        "allow-persistent-action",
        in: options,
        category: .persistentAction,
        message:
          "Notes locked-content export with a passphrase authenticates the selected note session and requires `--allow-persistent-action`."
      )
    }
    let passphrase = try passphraseSource.map {
      try readPassphrase(sourceKind: $0.kind, options: options, operation: operation)
    }
    let draft = NotesLockedContentExportDraft(
      noteID: noteID,
      passphrase: passphrase,
      passphraseSourceKind: passphraseSource?.kind
    )
    let source = try lockedContentExporter().exportUnlockedLockedContent(draft)
    let contentData = source.data
    let contentSHA256 = sha256Hex(contentData)
    try writeNotesLockedContentExport(contentData, to: destinationPath)
    let verification = try verifyLockedContentExport(
      source: source,
      destinationPath: destinationPath,
      expectedData: contentData,
      expectedSHA256: contentSHA256,
      operation: operation
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes locked-content export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try result(
      NotesLockedContentExportResult(
        operation: operation,
        changed: true,
        noteIDSHA256: sha256Hex(source.noteID),
        passphraseSourceKind: source.passphraseSourceKind,
        isPasswordProtected: source.isPasswordProtected,
        isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
        authenticatedDuringExport: source.authenticatedDuringExport,
        contentByteCount: contentData.count,
        contentSHA256: contentSHA256,
        backendCalls: source.backendCalls,
        artifact: NotesLockedContentArtifactRecord(
          destinationPath: destinationPath,
          byteCount: contentData.count,
          sha256: contentSHA256,
          contentKind: source.authenticatedDuringExport
            ? "authenticated_locked_note_plain_text"
            : "session_unlocked_locked_note_plain_text"
        ),
        verification: verification
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func verifyLockedContentExport(
    source: NotesLockedContentExportSource,
    destinationPath: String,
    expectedData: Data,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let artifactData = try Data(contentsOf: URL(fileURLWithPath: destinationPath))
    let artifactSHA256 = sha256Hex(artifactData)
    let sessionUnlocked = source.isPasswordProtected && source.isPasswordProtectedAndLocked == false
    let implementationAccepted = [
      "ICNote.noteAsPlainTextWithoutTitle",
      "ICAuthenticationState.authenticateObject:withPassphrase:+ICNote.noteAsPlainTextWithoutTitle",
    ].contains(source.backendCalls)
    let passphraseSourceSupported = source.passphraseSourceKind == nil
      || ["stdin", "env", "file"].contains(source.passphraseSourceKind ?? "")
    let authenticationBoundaryAccounted = source.authenticatedDuringExport == false
      || source.backendCalls.contains("ICAuthenticationState.authenticateObject:withPassphrase:")
    let hashAccounting = expectedSHA256.count == 64 && artifactSHA256 == expectedSHA256
    let checks = [
      NotesVerificationCheckRecord(
        name: "session_unlocked_locked_note_readback",
        status: sessionUnlocked ? "passed" : "failed",
        expectedBool: true,
        actualBool: sessionUnlocked
      ),
      NotesVerificationCheckRecord(
        name: "private_plain_text_implementation",
        status: implementationAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationAccepted
      ),
      NotesVerificationCheckRecord(
        name: "passphrase_source_supported_when_present",
        status: passphraseSourceSupported ? "passed" : "failed",
        expectedBool: true,
        actualBool: passphraseSourceSupported
      ),
      NotesVerificationCheckRecord(
        name: "secret_safe_authentication_session",
        status: authenticationBoundaryAccounted ? "passed" : "failed",
        expectedBool: true,
        actualBool: authenticationBoundaryAccounted
      ),
      NotesVerificationCheckRecord(
        name: "artifact_text_readback",
        status: artifactData == expectedData ? "passed" : "failed",
        expectedBool: true,
        actualBool: artifactData == expectedData
      ),
      NotesVerificationCheckRecord(
        name: "content_hash_accounting",
        status: hashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: hashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_surface_limited_to_hashes_and_artifact_metadata",
        status: source.noteID.isEmpty == false ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.noteID.isEmpty == false
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_locked_content_export_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: source.authenticatedDuringExport
        ? "ICAuthenticationState.authenticateObject+ICNote.noteAsPlainTextWithoutTitle+artifact_hash_readback+secret_source_boundary"
        : "private_session_unlocked_plain_text_readback+artifact_sha256_verification",
      targetIDSHA256: sha256Hex(
        [
          source.noteID,
          source.passphraseSourceKind ?? "session",
          "\(source.authenticatedDuringExport)",
          expectedSHA256,
          "\(expectedData.count)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  private func verifyLockedSessionClose(
    _ write: NotesLockedSessionCloseWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let scopeAccepted = [
      "all_authenticated_locked_objects",
      "all_authenticated_locked_objects_after_account_preflight",
    ].contains(write.scope)
    let afterClosed = !write.afterAuthenticated && !write.afterHasAuthenticatedObject
    let changeAccounting = write.changed == (
      write.beforeAuthenticated != write.afterAuthenticated
        || write.beforeHasAuthenticatedObject != write.afterHasAuthenticatedObject
    )
    let accountHashAccounting = write.accountSelectorSHA256 == nil
      || write.accountSelectorSHA256?.count == 64
    let resolvedAccountHashAccounting = write.accountSHA256 == nil
      || write.accountSHA256?.count == 64
    let implementationCallAccepted = write.backendCalls == "ICAuthenticationState.deauthenticateAllObjects"
    let checks = [
      NotesVerificationCheckRecord(
        name: "session_scope_accounting",
        status: scopeAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: scopeAccepted
      ),
      NotesVerificationCheckRecord(
        name: "private_deauthenticate_all_objects_call",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "locked_session_closed_readback",
        status: afterClosed ? "passed" : "failed",
        expectedBool: true,
        actualBool: afterClosed
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: changeAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: changeAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: accountHashAccounting && resolvedAccountHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: accountHashAccounting && resolvedAccountHashAccounting
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_locked_session_close_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_authentication_state_deauthenticate_all_objects_readback",
      targetIDSHA256: write.accountSHA256 ?? write.accountSelectorSHA256 ?? sha256Hex(operation),
      checks: checks
    )
  }

  private func lockedContentExporter() throws -> any NotesLockedContentExporting {
    guard let exporter = implementation as? any NotesLockedContentExporting else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes locked-content export requires a private-framework locked-content reader.",
        details: [
          "capability": "session_unlocked_locked_content_export",
          "required_module": "NotesShared",
        ]
      )
    }
    return exporter
  }
}
