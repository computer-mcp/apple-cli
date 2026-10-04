import Foundation
import Utility

extension NotesCommand {
  func runSettings(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["settings", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try settingsWorkflowAudit(options)
    case ["settings", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let evidence = try settingsReader().readSettings(account: options.targetOption("account"))
      return try readSettings(evidence, options: options)
    case ["settings", "sort"]:
      return try setNoteListSort(options: options)
    case ["settings", "new-note-style"]:
      return try setDefaultNewNoteStyle(options: options)
    case ["settings", "default-account"]:
      return try setDefaultAccount(options: options)
    case ["settings", "group-by-date"]:
      return try setGroupNotesByDate(options: options)
    case ["settings", "quick-note-resume"]:
      return try setQuickNoteResumeLast(options: options)
    case ["settings", "checklist-sort"]:
      return try setChecklistAutoSort(options: options)
    case ["settings", "mention-notifications"]:
      return try setMentionNotifications(options: options)
    case ["settings", "on-my-mac"]:
      return try setOnMyMacAccountEnabled(options: options)
    case ["settings", "text-size"]:
      return try setDefaultTextSize(options: options)
    case ["settings", "locked-notes"]:
      return try setLockedNotesCustomPassphrase(options: options)
    case ["settings", "change-password"]:
      return try changeLockedNotesCustomPassphrase(options: options)
    case ["settings", "reset-password"]:
      return try resetLockedNotesCustomPassphrase(options: options)
    case ["settings", "touch-id"]:
      return try setTouchIDPreference(options: options)
    case ["settings", "view-layout"]:
      return try settingsBoundaryRefusal(
        options: options,
        allowedOptions: ["style"],
        requiredOptions: ["style"],
        operation: "notes.settings.view-layout",
        capability: "view_layout",
        appleCapability: "view_layout",
        status: "delegated",
        futureGate: "notes_window_view_surface_delegation",
        requiredImplementation: "notes_window_view_surface",
        requiredVerifier: "delegated_window_view_accounting"
      )
    case ["settings", "link-highlight-color"]:
      return try settingsBoundaryRefusal(
        options: options,
        allowedOptions: ["color"],
        requiredOptions: ["color"],
        operation: "notes.settings.link-highlight-color",
        capability: "link_and_highlight_color",
        appleCapability: "link_and_highlight_color",
        status: "delegated",
        futureGate: "macos_appearance_settings_delegation",
        requiredImplementation: "macos_appearance_settings_route",
        requiredVerifier: "delegated_appearance_settings_accounting"
      )
    case ["settings", "notifications"]:
      try validateTargetOptions(options, allowedOptions: ["account"])
      throw settingsBoundaryCapabilityError(
        operation: "notes.settings.notifications",
        capability: "notes_notification_settings",
        appleCapability: "manage_notes_notifications",
        status: "delegated",
        futureGate: "system_notification_settings_delegation",
        requiredImplementation: "macos_notification_settings_route",
        requiredVerifier: "delegated_system_settings_accounting"
      )
    case ["settings", "widgets"]:
      try validateTargetOptions(options, allowedOptions: ["account"])
      throw settingsBoundaryCapabilityError(
        operation: "notes.settings.widgets",
        capability: "notes_widgets",
        appleCapability: "notes_widgets",
        status: "delegated",
        futureGate: "macos_widget_surface_delegation",
        requiredImplementation: "macos_widget_system",
        requiredVerifier: "delegated_widget_surface_accounting"
      )
    case ["settings", "password"]:
      try validateTargetOptions(options, allowedOptions: ["account"])
      throw settingsBoundaryCapabilityError(
        operation: "notes.settings.password",
        capability: "locked_notes_password_change",
        appleCapability: "change_locked_notes_password",
        status: "gated",
        futureGate: "locked_notes_password_settings_mutation",
        requiredImplementation: "typed_private_notes_framework",
        requiredVerifier: "private_framework_state_readback+privacy_boundary"
      )    default:
      return nil
    }
  }

  private func normalizedGroupByDateScope(_ raw: String?) throws -> String {
    let value = (raw ?? "current").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    switch value {
    case "current", "global":
      return "current"
    case "default", "query":
      return value
    default:
      throw CLIError(
        code: .validationError,
        message: "`--scope` must be current, default, or query for Notes group-by-date settings.",
        details: ["allowed": "current,default,query"]
      )
    }
  }

  private func settingsWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.settings.audit"
    let records = notesSettingsWorkflowAuditRecords()
    let summary = notesSettingsWorkflowAuditSummary(records)
    let verification = verifySettingsWorkflowAudit(records: records, summary: summary)
    let response = NotesSettingsWorkflowAuditResponse(
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

  private func notesSettingsWorkflowAuditRecords() -> [NotesSettingsWorkflowAuditRecord] {
    struct SettingsWorkflowAuditItem {
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
      SettingsWorkflowAuditItem(
        family: "settings_family_accounting",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "account_for_notes_settings_options",
        command: "settings read [--account ACCOUNT]",
        mechanism: "typed_private_notes_framework_settings_reader",
        requiredImplementation: "privacy-safe settings family readback",
        requiredVerifier: "notes_settings_read_v1",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_booleans_counts_and_statuses_only",
        reason: "`settings read` accounts for the official settings options without printing defaults, account identifiers, style names, text sizes, passwords, or hints."
      ),
      SettingsWorkflowAuditItem(
        family: "default_note_sort",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "choose_default_note_sort_order",
        command: "settings sort --by FIELD --direction DIRECTION",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private note-list sort setter",
        requiredVerifier: "notes_settings_mutation_v1+sort_hash_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "sort_hash_and_private_enum_evidence_only",
        reason: "The accepted setting mutation changes the default note-list sort order and verifies post-write private readback."
      ),
      SettingsWorkflowAuditItem(
        family: "default_new_note_style",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "choose_default_new_note_paragraph_style",
        command: "settings new-note-style --style STYLE",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private default paragraph style setter",
        requiredVerifier: "notes_settings_mutation_v1+paragraph_style_hash_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "style_hash_only",
        reason: "The accepted setting mutation changes the default paragraph style used by new notes and verifies hashed readback."
      ),
      SettingsWorkflowAuditItem(
        family: "default_account",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "choose_default_notes_account_for_siri",
        command: "settings default-account --account ACCOUNT",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private default account setter",
        requiredVerifier: "notes_settings_mutation_v1+account_hash_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "account_hash_only",
        reason: "The accepted setting mutation changes Notes' default account preference; Siri note creation itself remains a delegated input surface."
      ),
      SettingsWorkflowAuditItem(
        family: "global_group_by_date",
        guideSection: "Change Notes settings / Customize how notes appear",
        status: "supported",
        appleCapability: "group_all_notes_by_date",
        command: "settings group-by-date --enabled true|false",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private global group-by-date preference setter",
        requiredVerifier: "notes_settings_mutation_v1+bool_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "boolean_state_only",
        reason: "The accepted setting mutation changes the global Group notes by date preference and verifies boolean readback."
      ),
      SettingsWorkflowAuditItem(
        family: "date_header_type_preferences",
        guideSection: "Change Notes settings / Customize how notes appear",
        status: "supported",
        appleCapability: "choose_default_or_query_date_header_type",
        command: "settings group-by-date --scope default|query --enabled true|false",
        mechanism: "typed_private_notes_framework_date_header_type_writer",
        requiredImplementation: "ICDateHeadersUtilities default/query date-header type setter",
        requiredVerifier: "notes_settings_mutation_v1+date_header_type_hash_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "date_header_enum_hash_only",
        reason: "Default and query date-header type preferences are accepted through private enum setters and hash-only readback."
      ),
      SettingsWorkflowAuditItem(
        family: "folder_group_by_date",
        guideSection: "Customize how notes appear",
        status: "supported",
        appleCapability: "group_one_folder_by_date",
        command: "folders date-headers --folder FOLDER --enabled true|false",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "private folder date-header setter",
        requiredVerifier: "private_folder_date_header_readback",
        safetyGate: "readback verified",
        privacyBoundary: "folder_selector_and_boolean_state_only",
        reason: "Folder-specific date grouping is accepted through the existing folder date-header mutation path."
      ),
      SettingsWorkflowAuditItem(
        family: "quick_note_resume_last",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "always_resume_to_last_quick_note",
        command: "settings quick-note-resume --enabled true|false",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private Quick Note resume preference setter",
        requiredVerifier: "notes_settings_mutation_v1+bool_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "boolean_state_only",
        reason: "The accepted setting mutation controls whether Quick Note resumes the previous Quick Note and verifies boolean readback."
      ),
      SettingsWorkflowAuditItem(
        family: "checklist_auto_sort",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "automatically_sort_checked_items",
        command: "settings checklist-sort --enabled true|false",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private checklist auto-sort preference setter",
        requiredVerifier: "notes_settings_mutation_v1+bool_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "boolean_state_only",
        reason: "The accepted setting mutation changes automatic checked-item sorting and verifies boolean readback."
      ),
      SettingsWorkflowAuditItem(
        family: "mention_notifications",
        guideSection: "Change Notes settings / Manage notifications",
        status: "supported",
        appleCapability: "allow_mention_notifications",
        command: "settings mention-notifications --enabled true|false",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private mention-notification preference setter",
        requiredVerifier: "notes_settings_mutation_v1+bool_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "boolean_state_only",
        reason: "The accepted setting mutation controls Notes mention notifications for shared notes and verifies boolean readback."
      ),
      SettingsWorkflowAuditItem(
        family: "on_my_mac_enable",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "enable_on_my_mac_account",
        command: "settings on-my-mac --enabled true",
        mechanism: "typed_private_notes_framework_account_settings_writer",
        requiredImplementation: "ICNoteContext local account enablement path",
        requiredVerifier: "notes_settings_mutation_v1+local_account_presence_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "local_account_presence_boolean_only",
        reason: "Enabling the local On My Mac account is accepted and verified through private account/settings readback."
      ),
      SettingsWorkflowAuditItem(
        family: "default_text_size",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "set_default_text_size",
        command: "settings text-size --size SIZE",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private default text-size preference setter",
        requiredVerifier: "notes_settings_mutation_v1+text_size_hash_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "text_size_hash_only",
        reason: "The accepted setting mutation changes default text size and verifies hashed readback without printing the raw value."
      ),
      SettingsWorkflowAuditItem(
        family: "note_list_gallery_layout",
        guideSection: "Customize how notes appear",
        status: "delegated",
        appleCapability: "view_notes_as_gallery_or_list",
        command: "settings view-layout --style gallery|list",
        mechanism: "delegated_notes_window_view_surface",
        requiredImplementation: "notes_app_window_view_route",
        requiredVerifier: "delegated_window_view_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Gallery/list display mode is a Notes.app window/view surface rather than a proven persisted Notes private setting."
      ),
      SettingsWorkflowAuditItem(
        family: "link_highlight_appearance_color",
        guideSection: "Customize how notes appear",
        status: "delegated",
        appleCapability: "change_link_and_highlight_color",
        command: "settings link-highlight-color --color COLOR",
        mechanism: "delegated_macos_appearance_settings",
        requiredImplementation: "macos_appearance_settings_route",
        requiredVerifier: "delegated_appearance_settings_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents link/highlight color as a system Appearance setting that applies across apps."
      ),
      SettingsWorkflowAuditItem(
        family: "toolbar_customization",
        guideSection: "Customize how notes appear",
        status: "delegated",
        appleCapability: "customize_notes_toolbar",
        command: "Notes.app toolbar customization UI",
        mechanism: "delegated_appkit_toolbar_ui",
        requiredImplementation: "notes_app_toolbar_customization_route",
        requiredVerifier: "delegated_toolbar_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Toolbar icon customization is a user-facing AppKit UI workflow, not a Notes data-model mutation."
      ),
      SettingsWorkflowAuditItem(
        family: "note_widget_view",
        guideSection: "Use Notes widgets to view notes",
        status: "delegated",
        appleCapability: "view_one_note_in_widget",
        command: "settings widgets [--account ACCOUNT]",
        mechanism: "delegated_macos_widget_system",
        requiredImplementation: "macos_widget_system",
        requiredVerifier: "delegated_widget_surface_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "A Note widget is presented and configured by the macOS widget system rather than the Notes CLI data writer."
      ),
      SettingsWorkflowAuditItem(
        family: "folder_widget_view",
        guideSection: "Use Notes widgets to view notes",
        status: "delegated",
        appleCapability: "view_one_folder_in_widget",
        command: "settings widgets [--account ACCOUNT]",
        mechanism: "delegated_macos_widget_system",
        requiredImplementation: "macos_widget_system",
        requiredVerifier: "delegated_widget_surface_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "A Folder widget is presented and configured by the macOS widget system rather than the Notes private model API."
      ),
      SettingsWorkflowAuditItem(
        family: "widget_add_customize_surface",
        guideSection: "Use Notes widgets to view notes",
        status: "delegated",
        appleCapability: "add_or_customize_notes_widgets_on_desktop_or_notification_center",
        command: "macOS widget customization UI",
        mechanism: "delegated_macos_widget_system",
        requiredImplementation: "macos_widget_customization_route",
        requiredVerifier: "delegated_widget_surface_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Adding or customizing widgets belongs to macOS Desktop/Notification Center widget management."
      ),
      SettingsWorkflowAuditItem(
        family: "all_notes_notification_system_toggle",
        guideSection: "Manage notifications",
        status: "delegated",
        appleCapability: "turn_off_all_notes_notifications",
        command: "settings notifications [--account ACCOUNT]",
        mechanism: "delegated_macos_notification_settings",
        requiredImplementation: "macos_notification_settings_route",
        requiredVerifier: "delegated_system_settings_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Turning all Notes notifications on or off is documented as a System Settings notification workflow."
      ),
      SettingsWorkflowAuditItem(
        family: "notification_delivery_style_settings",
        guideSection: "Manage notifications",
        status: "delegated",
        appleCapability: "change_notes_notification_style_and_delivery_options",
        command: "settings notifications [--account ACCOUNT]",
        mechanism: "delegated_macos_notification_settings",
        requiredImplementation: "macos_notification_settings_route",
        requiredVerifier: "delegated_system_settings_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Banner style, location, and notification delivery options are macOS notification settings, not Notes private data."
      ),
      SettingsWorkflowAuditItem(
        family: "focus_notification_delivery",
        guideSection: "Manage notifications",
        status: "delegated",
        appleCapability: "allow_notes_notifications_during_focus",
        command: "macOS Focus settings",
        mechanism: "delegated_macos_focus_settings",
        requiredImplementation: "macos_focus_settings_route",
        requiredVerifier: "delegated_focus_settings_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Focus exceptions for notifications are managed by macOS Focus settings."
      ),
      SettingsWorkflowAuditItem(
        family: "on_my_mac_disable",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "disable_on_my_mac_account",
        command: "settings on-my-mac --enabled false",
        mechanism: "typed_private_notes_framework_account_settings_writer",
        requiredImplementation: "ICNoteContext empty-local-account disable path",
        requiredVerifier: "notes_settings_mutation_v1+empty_local_account_preflight+local_account_absence_readback",
        safetyGate: "--allow-persistent-action+empty_local_account_preflight",
        privacyBoundary: "does_not_print_account_values_or_local_note_content",
        reason: "Disabling On My Mac is accepted only when private readback proves the local account has no visible or trashed notes, no custom folders, is not the default account, and another Notes account is active."
      ),
      SettingsWorkflowAuditItem(
        family: "locked_notes_password_method_settings",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "choose_locked_notes_account_and_password_method",
        command: "settings locked-notes --account ACCOUNT --scope login-password",
        mechanism: "typed_private_notes_framework_locked_notes_mode_writer",
        requiredImplementation: "NotesShared.ICLocalAuthentication.hasPasscode + NotesUI.ICLockedNotesModeMigrator.account:supportsMode: + NotesShared.ICAccount.setResolvedLockedNotesMode:",
        requiredVerifier: "notes_settings_mutation_v1+locked_notes_mode_readback+system_passcode_preflight+empty_protected_notes_preflight",
        safetyGate: "--allow-persistent-action+system_passcode_preflight+empty_protected_notes_preflight",
        privacyBoundary: "must_not_print_password_hint_or_account_values",
        reason: "Initial login-password locked-notes method selection is supported for one selected account when macOS login-password preflight passes and private readback proves the account has no existing password-protected notes. Method switching for existing locked notes remains separately gated until private migration proof exists."
      ),
      SettingsWorkflowAuditItem(
        family: "locked_notes_password_setup",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "set_initial_locked_notes_password",
        command: "settings locked-notes --account ACCOUNT --scope custom --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.setPassphrase:hint:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+secret_source_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_password_hint_or_account_values",
        reason: "Initial custom locked-notes password setup is supported through the private account passphrase manager with stdin/env/file passphrase sources, hint hash accounting, and account crypto-strategy readback."
      ),
      SettingsWorkflowAuditItem(
        family: "locked_notes_change_password",
        guideSection: "Change Notes settings / Manage locked-note passwords",
        status: "supported",
        appleCapability: "change_locked_notes_password",
        command: "settings change-password --account ACCOUNT --old-passphrase-stdin|--old-passphrase-env NAME|--old-passphrase-file FILE --new-passphrase-stdin|--new-passphrase-env NAME|--new-passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager_change",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+old_new_secret_source_boundary+change_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_old_or_new_password_hint_or_account_values",
        reason: "Changing a selected account custom locked-notes password is supported through the private account passphrase manager change selector with separate old/new stdin/env/file passphrase sources, hint hash accounting, private completion, and account crypto-strategy readback. Password-method switching and diverged locked-note rekeying remain separately gated."
      ),
      SettingsWorkflowAuditItem(
        family: "locked_notes_reset_password",
        guideSection: "Change Notes settings / Manage locked-note passwords",
        status: "supported",
        appleCapability: "reset_locked_notes_password",
        command: "settings reset-password --account ACCOUNT --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]",
        mechanism: "typed_private_notes_framework_account_passphrase_manager_reset",
        requiredImplementation: "NotesUI.ICAccountPassphraseManager.setPassphrase:hint:isReset:",
        requiredVerifier: "notes_settings_mutation_v1+account_crypto_strategy_readback+secret_source_boundary+reset_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_password_hint_or_account_values",
        reason: "Custom locked-notes password reset is supported through the private account passphrase manager reset selector with stdin/env/file passphrase sources, hint hash accounting, account crypto-strategy readback, and explicit accounting that existing locked notes may retain the old password."
      ),
      SettingsWorkflowAuditItem(
        family: "locked_notes_touch_id_preference",
        guideSection: "Change Notes settings",
        status: "supported",
        appleCapability: "use_touch_id_for_locked_notes",
        command: "settings touch-id --enabled true|false --account ACCOUNT",
        mechanism: "typed_private_notes_framework_touch_id_preference_writer",
        requiredImplementation: "NotesShared.ICAuthenticationState.setBiometricsEnabled:forAccount:",
        requiredVerifier: "private_touch_id_preference_readback+local_auth_boundary",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_biometric_or_account_values",
        reason: "The Notes account-scoped Touch ID preference is supported through private preference readback; biometric authentication remains delegated."
      ),
      SettingsWorkflowAuditItem(
        family: "shared_note_hide_alerts",
        guideSection: "Manage notifications",
        status: "supported",
        appleCapability: "hide_alerts_for_one_shared_note",
        command: "state hide-alerts --id NOTE_ID --enabled true|false",
        mechanism: "typed_private_notes_framework_share_notifier_preference",
        requiredImplementation: "NotesShared.ICShareNotifier.setShouldPreventNotifications:forRecordID:",
        requiredVerifier: "private_shared_note_notification_preference_readback+privacy_hash",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "does_not_print_note_title_body_or_participant_values",
        reason: "Per-shared-note Hide Alerts is supported for one shared note through private recordID readback and share-notifier preference verification."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesSettingsWorkflowAuditRecord(
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

  private func notesSettingsWorkflowAuditSummary(
    _ records: [NotesSettingsWorkflowAuditRecord]
  ) -> NotesSettingsWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesSettingsWorkflowAuditSummary(
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

  private func verifySettingsWorkflowAudit(
    records: [NotesSettingsWorkflowAuditRecord],
    summary: NotesSettingsWorkflowAuditSummary
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
        name: "official_pages_accounted",
        expected: true,
        actual: guideSectionSet.contains("Change Notes settings")
          && guideSectionSet.contains("Customize how notes appear")
          && guideSectionSet.contains("Use Notes widgets to view notes")
          && guideSectionSet.contains("Manage notifications")
      ),
      verificationBoolCheck(
        name: "private_settings_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "settings_family_accounting", "default_note_sort", "default_new_note_style",
            "default_account", "global_group_by_date", "date_header_type_preferences", "folder_group_by_date",
            "quick_note_resume_last", "checklist_auto_sort", "mention_notifications",
            "on_my_mac_enable", "on_my_mac_disable", "default_text_size",
            "locked_notes_password_method_settings", "locked_notes_password_setup",
            "locked_notes_change_password", "locked_notes_reset_password",
            "locked_notes_touch_id_preference", "shared_note_hide_alerts",
          ]
        )
      ),
      verificationBoolCheck(
        name: "system_ui_workflows_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "note_list_gallery_layout", "link_highlight_appearance_color", "toolbar_customization",
            "note_widget_view", "folder_widget_view", "widget_add_customize_surface",
            "all_notes_notification_system_toggle", "notification_delivery_style_settings",
            "focus_notification_delivery",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_settings_security_mutations_gated",
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
      operation: "notes.settings.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.settings.audit"),
      checks: checks
    )
  }

  private func readSettings(
    _ evidence: NotesSettingsReadEvidence,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.settings.read"
    let verification = verifySettingsRead(evidence, operation: operation)
    let result = NotesSettingsReadResult(
      operation: operation,
      changed: false,
      accountScope: evidence.accountScope,
      requestedAccountSHA256: evidence.requestedAccountSHA256,
      accountCount: evidence.accountCount,
      selectedAccountCount: evidence.selectedAccountCount,
      defaultAccountIDSHA256: evidence.defaultAccountIDSHA256,
      onMyMacAccountPresent: evidence.onMyMacAccountPresent,
      supportsQueryDateHeaders: evidence.supportsQueryDateHeaders,
      showsQueryDateHeaders: evidence.showsQueryDateHeaders,
      families: evidence.families,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes settings read verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) read \(evidence.families.count) settings families", options: options)
  }

  private func setNoteListSort(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["by", "direction"])
    let sortBy = try normalizedFolderSortBy(try normalizedOption("by", options: options))
    guard sortBy != "default" else {
      throw CLIError(
        code: .validationError,
        message: "`settings sort` requires a concrete sort field.",
        details: ["allowed": "date-edited,date-created,title"]
      )
    }
    let direction = try normalizedFolderSortDirection(
      try normalizedOptionalOption("direction", options: options),
      sortBy: sortBy
    )
    let sortOrder = folderSortOrder(sortBy)
    let sortDirection = folderSortDirection(direction)
    let sortSHA256 = sha256Hex("\(sortBy)|\(direction)")
    let draft = NotesSettingsSortMutationDraft(
      by: sortBy,
      direction: direction,
      sortOrder: sortOrder,
      sortDirection: sortDirection
    )
    return try settingsPreferenceMutation(
      operation: "notes.settings.sort",
      settingID: "sort_notes_by",
      valueKind: "note_list_sort_sha256",
      requestedBoolValue: nil,
      requestedValueSHA256: sortSHA256,
      summary: [
        "setting_id": "sort_notes_by",
        "sort_sha256": sortSHA256,
        "sort_order": "\(sortOrder)",
        "sort_direction": "\(sortDirection)",
      ],
      options: options,
      dryRunNotes: [
        "Modifies the global Notes preference for default note-list sort order.",
        "Execution requires private-framework setter readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setNoteListSort(draft)
    }
  }

  private func setDefaultNewNoteStyle(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["style"])
    let style = try normalizedParagraphStyleOption("style", options: options)
    guard style.isDefaultNewNoteStyle else {
      throw CLIError(
        code: .validationError,
        message: "`--style` must be \(NotesBodyParagraphStyle.defaultNewNoteAllowedDescription).",
        details: ["allowed": NotesBodyParagraphStyle.defaultNewNoteAllowedDescription]
      )
    }
    let styleSHA256 = sha256Hex(style.rawValue)
    return try settingsPreferenceMutation(
      operation: "notes.settings.new-note-style",
      settingID: "new_notes_start_with",
      valueKind: "paragraph_style_sha256",
      requestedBoolValue: nil,
      requestedValueSHA256: styleSHA256,
      summary: [
        "setting_id": "new_notes_start_with",
        "style_sha256": styleSHA256,
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes default paragraph style for newly created notes.",
        "Execution requires private-framework setter readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setDefaultNewNoteStyle(NotesSettingsParagraphStyleMutationDraft(style: style))
    }
  }

  private func setDefaultAccount(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["account"])
    let account = try accountIdentity(selector: try requiredOption("account", options: options))
    let accountSHA256 = sha256Hex(account.id)
    return try settingsPreferenceMutation(
      operation: "notes.settings.default-account",
      settingID: "default_account",
      valueKind: "account_id_sha256",
      requestedBoolValue: nil,
      requestedValueSHA256: accountSHA256,
      summary: [
        "setting_id": "default_account",
        "account_id_sha256": accountSHA256,
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes default account used for new notes created through account-agnostic surfaces.",
        "Execution requires private-framework default-account readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setDefaultAccount(
        NotesSettingsDefaultAccountMutationDraft(
          accountID: account.id,
          accountName: account.name
        )
      )
    }
  }

  private func setGroupNotesByDate(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["enabled", "scope"])
    let enabled = try normalizedBoolOption("enabled", options: options)
    let scope = try normalizedGroupByDateScope(try normalizedOptionalOption("scope", options: options))
    guard scope != "current" else {
      return try settingsPreferenceMutation(
        operation: "notes.settings.group-by-date",
        settingID: "group_notes_by_date",
        valueKind: "bool",
        requestedBoolValue: enabled,
        requestedValueSHA256: nil,
        summary: [
          "setting_id": "group_notes_by_date",
          "enabled": enabled ? "true" : "false",
          "scope": "current",
        ],
        options: options,
        dryRunNotes: [
          "Modifies the global Notes preference that groups notes by date.",
          "Execution requires private-framework date-header readback and `--allow-persistent-action`.",
        ]
      ) {
        try settingsMutator().setGroupNotesByDate(NotesSettingsBoolMutationDraft(enabled: enabled))
      }
    }
    let privateValue = notesDateHeadersPrivateValue(enabled: enabled)
    let settingID = "\(scope)_date_headers_type"
    let requestedValueSHA256 = notesDateHeadersTypeSHA256(scope: scope, privateValue: privateValue)
    return try settingsPreferenceMutation(
      operation: "notes.settings.group-by-date",
      settingID: settingID,
      valueKind: "date_headers_type_sha256",
      requestedBoolValue: nil,
      requestedValueSHA256: requestedValueSHA256,
      summary: [
        "setting_id": settingID,
        "enabled": enabled ? "true" : "false",
        "scope": scope,
        "date_headers_type_value": "\(privateValue)",
        "date_headers_type_sha256": requestedValueSHA256,
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes \(scope) date-header type preference.",
        "Execution requires private-framework date-header type readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setDateHeadersPreference(
        NotesSettingsDateHeadersMutationDraft(
          scope: scope,
          enabled: enabled,
          privateValue: privateValue
        ))
    }
  }

  private func setQuickNoteResumeLast(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["enabled"])
    let enabled = try normalizedBoolOption("enabled", options: options)
    return try settingsPreferenceMutation(
      operation: "notes.settings.quick-note-resume",
      settingID: "always_resume_to_last_quick_note",
      valueKind: "bool",
      requestedBoolValue: enabled,
      requestedValueSHA256: nil,
      summary: [
        "setting_id": "always_resume_to_last_quick_note",
        "enabled": enabled ? "true" : "false",
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes preference that resumes the last Quick Note.",
        "Execution requires private-framework Quick Note readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setQuickNoteResumeLast(NotesSettingsBoolMutationDraft(enabled: enabled))
    }
  }

  private func setMentionNotifications(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["enabled"])
    let enabled = try normalizedBoolOption("enabled", options: options)
    return try settingsPreferenceMutation(
      operation: "notes.settings.mention-notifications",
      settingID: "allow_mention_notifications",
      valueKind: "bool",
      requestedBoolValue: enabled,
      requestedValueSHA256: nil,
      summary: [
        "setting_id": "allow_mention_notifications",
        "enabled": enabled ? "true" : "false",
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes preference that allows mention notifications for shared notes.",
        "System notification delivery remains delegated to macOS notification settings.",
        "Execution requires private-framework setter readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setMentionNotifications(NotesSettingsBoolMutationDraft(enabled: enabled))
    }
  }

  private func setDefaultTextSize(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["size"])
    let pointSize = try normalizedFontPointSizeOption("size", options: options)
    let sizeSHA256 = sha256Hex(formattedFontPointSize(pointSize))
    return try settingsPreferenceMutation(
      operation: "notes.settings.text-size",
      settingID: "default_text_size",
      valueKind: "text_size_sha256",
      requestedBoolValue: nil,
      requestedValueSHA256: sizeSHA256,
      summary: [
        "setting_id": "default_text_size",
        "size_sha256": sizeSHA256,
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes default text size preference through the private global zoom setting.",
        "Execution requires private-framework text-size readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setDefaultTextSize(NotesSettingsTextSizeMutationDraft(pointSize: pointSize))
    }
  }

  private func setOnMyMacAccountEnabled(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["enabled"])
    let enabled = try normalizedBoolOption("enabled", options: options)
    return try settingsPreferenceMutation(
      operation: "notes.settings.on-my-mac",
      settingID: "enable_on_my_mac_account",
      valueKind: "bool",
      requestedBoolValue: enabled,
      requestedValueSHA256: nil,
      summary: [
        "setting_id": "enable_on_my_mac_account",
        "enabled": enabled ? "true" : "false",
      ],
      options: options,
      dryRunNotes: [
        enabled
          ? "Enables the Notes On My Mac account through the private Notes account lifecycle path."
          : "Disables the Notes On My Mac account only when the local account is empty, non-default, and another Notes account is active.",
        "Execution requires private-framework local-account lifecycle readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setOnMyMacAccountEnabled(NotesSettingsBoolMutationDraft(enabled: enabled))
    }
  }

  private func setChecklistAutoSort(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["enabled"])
    let enabled = try normalizedBoolOption("enabled", options: options)
    return try settingsPreferenceMutation(
      operation: "notes.settings.checklist-sort",
      settingID: "automatically_sort_checked_items",
      valueKind: "bool",
      requestedBoolValue: enabled,
      requestedValueSHA256: nil,
      summary: [
        "setting_id": "automatically_sort_checked_items",
        "enabled": enabled ? "true" : "false",
      ],
      options: options,
      dryRunNotes: [
        "Modifies the global Notes preference that moves checked checklist items automatically.",
        "Execution requires private-framework setter readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setChecklistAutoSort(NotesSettingsBoolMutationDraft(enabled: enabled))
    }
  }

  private func setTouchIDPreference(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["account", "enabled"])
    let account = try normalizedOption("account", options: options)
    let enabled = try normalizedBoolOption("enabled", options: options)
    let accountSHA256 = sha256Hex(account)
    return try settingsPreferenceMutation(
      operation: "notes.settings.touch-id",
      settingID: "use_touch_id",
      valueKind: "account_scoped_bool",
      requestedBoolValue: enabled,
      requestedValueSHA256: nil,
      summary: [
        "setting_id": "use_touch_id",
        "account_sha256": accountSHA256,
        "enabled": enabled ? "true" : "false",
      ],
      options: options,
      dryRunNotes: [
        "Modifies the Notes account-scoped Touch ID preference for locked notes.",
        "Biometric authentication itself remains delegated to macOS LocalAuthentication.",
        "Execution requires private-framework Touch ID preference readback and `--allow-persistent-action`.",
      ]
    ) {
      try settingsMutator().setTouchIDPreference(
        NotesSettingsAccountBoolMutationDraft(account: account, enabled: enabled)
      )
    }
  }

  private func setLockedNotesCustomPassphrase(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(
      options,
      allowedOptions: ["account", "scope", "hint", "passphrase-env", "passphrase-file"],
      allowedFlags: ["passphrase-stdin"]
    )
    let operation = "notes.settings.locked-notes"
    let account = try normalizedOption("account", options: options)
    let scope = try normalizedLockedNotesScope(try normalizedOptionalOption("scope", options: options))
    if scope == "login-password" {
      try validateLoginPasswordMethodOptions(options: options, operation: operation)
      let modeRawValue = 2
      let requestedModeSHA256 = notesLockedNotesModeStateSHA256(
        modeRawValue: modeRawValue,
        methodScope: scope
      )
      return try settingsPreferenceMutation(
        operation: operation,
        settingID: "locked_notes_method",
        valueKind: "locked_notes_mode_state",
        requestedBoolValue: nil,
        requestedValueSHA256: requestedModeSHA256,
        summary: [
          "setting_id": "locked_notes_method",
          "account_sha256": sha256Hex(account),
          "scope": scope,
          "locked_notes_mode_sha256": requestedModeSHA256,
          "locked_notes_mode_raw_value": "\(modeRawValue)",
        ],
        options: options,
        dryRunNotes: [
          "Sets the selected Notes account to the login-password locked-notes method when no existing password-protected notes require migration.",
          "Execution requires macOS login-password preflight, private locked-notes mode readback, empty protected-note preflight, and `--allow-persistent-action`.",
          "Changing methods for accounts with existing locked notes remains gated until private migration readback is proven.",
        ]
      ) {
        try settingsMutator().setLockedNotesMethod(
          NotesSettingsLockedNotesMethodMutationDraft(
            account: account,
            methodScope: scope,
            modeRawValue: modeRawValue,
            modeSHA256: requestedModeSHA256
          )
        )
      }
    }
    guard scope == "custom" else {
      throw settingsBoundaryCapabilityError(
        operation: operation,
        capability: "locked_notes_login_password_method",
        appleCapability: "use_login_password_for_locked_notes",
        status: "gated",
        futureGate: "locked_notes_login_password_method_mutation",
        requiredImplementation: "typed_private_notes_framework_login_password_method_writer",
        requiredVerifier: "private_password_method_readback+system_security_precondition_accounting"
      )
    }
    let source = try passphraseSource(options: options, operation: operation)
    let hint = try normalizedOptionalHint(options: options, operation: operation)
    let hintSHA256 = hint.map(sha256Hex)
    let requestedStateSHA256 = notesLockedNotesPassphraseStateSHA256(
      hasPassphraseSet: true,
      hintSHA256: hintSHA256
    )
    var summary: [String: String] = [
      "setting_id": "locked_notes",
      "account_sha256": sha256Hex(account),
      "scope": "custom",
      "passphrase_source_kind": source.kind,
      "locked_notes_state_sha256": requestedStateSHA256,
    ]
    if let selectorSHA256 = source.selectorSHA256 {
      summary["passphrase_source_sha256"] = selectorSHA256
    }
    if let hintSHA256 {
      summary["hint_sha256"] = hintSHA256
      summary["hint_length"] = "\(hint?.utf8.count ?? 0)"
    }
    return try settingsPreferenceMutation(
      operation: operation,
      settingID: "locked_notes",
      valueKind: "account_passphrase_state",
      requestedBoolValue: nil,
      requestedValueSHA256: requestedStateSHA256,
      summary: summary,
      options: options,
      dryRunNotes: [
        "Sets the selected Notes account to a custom locked-notes password through the private account passphrase manager.",
        "Dry-run validates the secret source but does not read the passphrase.",
        "Execution requires `--allow-persistent-action` and private account passphrase readback.",
      ]
    ) {
      let passphrase = try readPassphrase(sourceKind: source.kind, options: options, operation: operation)
      try validateCustomPassphraseHint(hint, passphrase: passphrase, operation: operation)
      return try settingsMutator().setCustomPassphrase(
        NotesSettingsPassphraseMutationDraft(
          account: account,
          passphrase: passphrase,
          passphraseSourceKind: source.kind,
          hint: hint,
          hintSHA256: hintSHA256,
          isReset: false
        )
      )
    }
  }

  private func validateLoginPasswordMethodOptions(options: CLIOptions, operation: String) throws {
    let disallowedOptions = ["hint", "passphrase-env", "passphrase-file"]
      .filter { options.targetOptions[$0] != nil }
    let disallowedFlags = ["passphrase-stdin"]
      .filter { options.hasTargetFlag($0) }
    let disallowed = (disallowedOptions + disallowedFlags).sorted()
    guard disallowed.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Notes login-password locked-notes method does not accept custom passphrase or hint input.",
        details: [
          "operation": operation,
          "scope": "login-password",
          "unsupported_options": disallowed.map { "--\($0)" }.joined(separator: ","),
          "accepted_options": "--account,--scope",
        ]
      )
    }
  }

  private func resetLockedNotesCustomPassphrase(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(
      options,
      allowedOptions: ["account", "hint", "passphrase-env", "passphrase-file"],
      allowedFlags: ["passphrase-stdin"]
    )
    let operation = "notes.settings.reset-password"
    let account = try normalizedOption("account", options: options)
    let source = try passphraseSource(options: options, operation: operation)
    let hint = try normalizedOptionalHint(options: options, operation: operation)
    let hintSHA256 = hint.map(sha256Hex)
    let requestedStateSHA256 = notesLockedNotesPassphraseStateSHA256(
      hasPassphraseSet: true,
      hintSHA256: hintSHA256
    )
    var summary: [String: String] = [
      "setting_id": "locked_notes",
      "account_sha256": sha256Hex(account),
      "reset": "true",
      "passphrase_source_kind": source.kind,
      "locked_notes_state_sha256": requestedStateSHA256,
    ]
    if let selectorSHA256 = source.selectorSHA256 {
      summary["passphrase_source_sha256"] = selectorSHA256
    }
    if let hintSHA256 {
      summary["hint_sha256"] = hintSHA256
      summary["hint_length"] = "\(hint?.utf8.count ?? 0)"
    }
    return try settingsPreferenceMutation(
      operation: operation,
      settingID: "locked_notes",
      valueKind: "account_passphrase_state",
      requestedBoolValue: nil,
      requestedValueSHA256: requestedStateSHA256,
      summary: summary,
      options: options,
      dryRunNotes: [
        "Resets the selected Notes account custom locked-notes password through the private account passphrase manager.",
        "Existing locked notes may retain the old password; this command verifies the selected-account reset state without printing passwords or hints.",
        "Dry-run validates the secret source but does not read the passphrase.",
        "Execution requires `--allow-persistent-action` and private account passphrase readback.",
      ]
    ) {
      let passphrase = try readPassphrase(sourceKind: source.kind, options: options, operation: operation)
      try validateCustomPassphraseHint(hint, passphrase: passphrase, operation: operation)
      return try settingsMutator().setCustomPassphrase(
        NotesSettingsPassphraseMutationDraft(
          account: account,
          passphrase: passphrase,
          passphraseSourceKind: source.kind,
          hint: hint,
          hintSHA256: hintSHA256,
          isReset: true
        )
      )
    }
  }

  private func changeLockedNotesCustomPassphrase(options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(
      options,
      allowedOptions: [
        "account", "hint",
        "old-passphrase-env", "old-passphrase-file",
        "new-passphrase-env", "new-passphrase-file",
      ],
      allowedFlags: ["old-passphrase-stdin", "new-passphrase-stdin"]
    )
    let operation = "notes.settings.change-password"
    let account = try normalizedOption("account", options: options)
    let oldSource = try passphraseSource(
      options: options,
      operation: operation,
      prefix: "old",
      role: "old"
    )
    let newSource = try passphraseSource(
      options: options,
      operation: operation,
      prefix: "new",
      role: "new"
    )
    guard oldSource.kind != "stdin" || newSource.kind != "stdin" else {
      throw CLIError(
        code: .validationError,
        message: "`\(operation)` cannot read both old and new passphrases from the same stdin stream.",
        details: [
          "operation": operation,
          "old_passphrase_source_kind": oldSource.kind,
          "new_passphrase_source_kind": newSource.kind,
          "accepted_new_passphrase_selectors": "new-passphrase-env,new-passphrase-file",
        ]
      )
    }
    let hint = try normalizedOptionalHint(options: options, operation: operation)
    let hintSHA256 = hint.map(sha256Hex)
    let requestedStateSHA256 = notesLockedNotesPassphraseStateSHA256(
      hasPassphraseSet: true,
      hintSHA256: hintSHA256
    )
    var summary: [String: String] = [
      "setting_id": "locked_notes",
      "account_sha256": sha256Hex(account),
      "password_change": "true",
      "old_passphrase_source_kind": oldSource.kind,
      "new_passphrase_source_kind": newSource.kind,
      "locked_notes_state_sha256": requestedStateSHA256,
    ]
    if let selectorSHA256 = oldSource.selectorSHA256 {
      summary["old_passphrase_source_sha256"] = selectorSHA256
    }
    if let selectorSHA256 = newSource.selectorSHA256 {
      summary["new_passphrase_source_sha256"] = selectorSHA256
    }
    if let hintSHA256 {
      summary["hint_sha256"] = hintSHA256
      summary["hint_length"] = "\(hint?.utf8.count ?? 0)"
    }
    return try settingsPreferenceMutation(
      operation: operation,
      settingID: "locked_notes",
      valueKind: "account_passphrase_state",
      requestedBoolValue: nil,
      requestedValueSHA256: requestedStateSHA256,
      summary: summary,
      options: options,
      dryRunNotes: [
        "Changes the selected Notes account custom locked-notes password through the private account passphrase manager.",
        "Dry-run validates both secret sources but does not read either passphrase.",
        "Execution requires `--allow-persistent-action` and private account passphrase readback.",
      ]
    ) {
      let oldPassphrase = try readPassphrase(
        sourceKind: oldSource.kind,
        options: options,
        operation: operation,
        prefix: "old",
        role: "old"
      )
      let newPassphrase = try readPassphrase(
        sourceKind: newSource.kind,
        options: options,
        operation: operation,
        prefix: "new",
        role: "new"
      )
      guard oldPassphrase != newPassphrase else {
        throw CLIError(
          code: .validationError,
          message: "Notes locked-notes old and new passphrases must differ.",
          details: [
            "operation": operation,
            "old_passphrase_source_kind": oldSource.kind,
            "new_passphrase_source_kind": newSource.kind,
          ]
        )
      }
      try validateCustomPassphraseHint(hint, passphrase: newPassphrase, operation: operation)
      return try settingsMutator().changeCustomPassphrase(
        NotesSettingsPassphraseChangeMutationDraft(
          account: account,
          oldPassphrase: oldPassphrase,
          oldPassphraseSourceKind: oldSource.kind,
          newPassphrase: newPassphrase,
          newPassphraseSourceKind: newSource.kind,
          hint: hint,
          hintSHA256: hintSHA256
        )
      )
    }
  }

  private func settingsPreferenceMutation(
    operation: String,
    settingID: String,
    valueKind: String,
    requestedBoolValue: Bool?,
    requestedValueSHA256: String?,
    summary: [String: String],
    options: CLIOptions,
    dryRunNotes: [String],
    commit: () throws -> NotesSettingsPreferenceWriteResult
  ) throws -> CLICommandResult {
    let scopeDigest = sha256Hex(["notes.settings", settingID].joined(separator: "|"))
    return try mutation(
      operation: operation,
      scopeDigest: scopeDigest,
      summary: summary,
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"],
      dryRunNotes: dryRunNotes
    ) {
      let write = try commit()
      let verification = verifySettingsPreferenceMutation(
        write,
        operation: operation,
        settingID: settingID,
        valueKind: valueKind,
        requestedBoolValue: requestedBoolValue,
        requestedValueSHA256: requestedValueSHA256
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes settings mutation verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return NotesSettingsMutationResult(
        operation: operation,
        changed: settingsPreferenceChanged(write),
        settingID: settingID,
        valueKind: valueKind,
        accountSHA256: write.accountSHA256,
        preferenceKeySHA256: write.preferenceKeySHA256,
        boolValue: write.afterBoolValue,
        valueSHA256: write.afterValueSHA256,
        beforeBoolValue: write.beforeBoolValue,
        beforeValueSHA256: write.beforeValueSHA256,
        afterBoolValue: write.afterBoolValue,
        afterValueSHA256: write.afterValueSHA256,
        passphraseSourceKind: write.passphraseSourceKind,
        oldPassphraseSourceKind: write.oldPassphraseSourceKind,
        newPassphraseSourceKind: write.newPassphraseSourceKind,
        hintSHA256: write.hintSHA256,
        hintLength: write.hintLength,
        backendCalls: write.backendCalls,
        resetRequested: write.resetRequested,
        passwordChangeRequested: write.passwordChangeRequested,
        systemPasscodeAvailable: write.systemPasscodeAvailable,
        lockedNotesModeSupported: write.lockedNotesModeSupported,
        passwordProtectedNoteCountBefore: write.passwordProtectedNoteCountBefore,
        verification: verification
      )
    }
  }

  private func verifySettingsPreferenceMutation(
    _ write: NotesSettingsPreferenceWriteResult,
    operation: String,
    settingID: String,
    valueKind: String,
    requestedBoolValue: Bool?,
    requestedValueSHA256: String?
  ) -> NotesMutationVerificationReport {
    let changed = settingsPreferenceChanged(write)
    let expectedChanged = settingsPreferenceExpectedChanged(write)
    let boolValueKind = settingsPreferenceValueIsBool(valueKind)
    let requestedReadback: Bool
    let privacyHashAccounting: Bool
    if boolValueKind {
      requestedReadback = write.afterBoolValue == requestedBoolValue && write.afterBoolValue != nil
      privacyHashAccounting = true
    } else {
      requestedReadback =
        write.afterValueSHA256 == write.requestedValueSHA256
          && write.afterValueSHA256?.count == 64
          && write.requestedValueSHA256?.count == 64
      privacyHashAccounting = [
        write.requestedValueSHA256,
        write.beforeValueSHA256,
        write.afterValueSHA256,
        requestedValueSHA256,
      ].allSatisfy { $0.map { $0.count == 64 } ?? true }
    }
    let beforeAfterAccounting = changed == expectedChanged
      && (boolValueKind
        ? write.beforeBoolValue != nil && write.afterBoolValue != nil
        : write.beforeValueSHA256?.count == 64 && write.afterValueSHA256?.count == 64)
    var checks = [
      NotesVerificationCheckRecord(
        name: "setting_id",
        status: write.settingID == settingID ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.settingID == settingID
      ),
      NotesVerificationCheckRecord(
        name: "setting_value_kind",
        status: write.valueKind == valueKind ? "passed" : "failed",
        expectedBool: true,
        actualBool: write.valueKind == valueKind
      ),
      NotesVerificationCheckRecord(
        name: "requested_value_readback",
        status: requestedReadback ? "passed" : "failed",
        expectedSHA256: boolValueKind ? nil : write.requestedValueSHA256,
        actualSHA256: boolValueKind ? nil : write.afterValueSHA256,
        expectedBool: boolValueKind ? requestedBoolValue : true,
        actualBool: boolValueKind ? write.afterBoolValue : requestedReadback
      ),
      NotesVerificationCheckRecord(
        name: "before_after_delta_accounting",
        status: beforeAfterAccounting ? "passed" : "failed",
        expectedBool: expectedChanged,
        actualBool: changed
      ),
      NotesVerificationCheckRecord(
        name: "privacy_hash_accounting",
        status: privacyHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashAccounting
      ),
    ]
    if settingID == "enable_on_my_mac_account", requestedBoolValue == false {
      let localAccountWasPresent = write.beforeBoolValue == true
      let emptyLocalNotes = !localAccountWasPresent || write.localAccountNoteCountBefore == .some(0)
      let emptyLocalFolders = !localAccountWasPresent || write.localAccountCustomFolderCountBefore == .some(0)
      let replacementAccountAvailable = !localAccountWasPresent || (write.nonLocalAccountCountBefore ?? 0) > 0
      checks.append(
        NotesVerificationCheckRecord(
          name: "empty_local_account_notes_preflight",
          status: emptyLocalNotes ? "passed" : "failed",
          expectedLength: localAccountWasPresent ? 0 : nil,
          actualLength: write.localAccountNoteCountBefore,
          expectedBool: true,
          actualBool: emptyLocalNotes
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "empty_local_account_folders_preflight",
          status: emptyLocalFolders ? "passed" : "failed",
          expectedLength: localAccountWasPresent ? 0 : nil,
          actualLength: write.localAccountCustomFolderCountBefore,
          expectedBool: true,
          actualBool: emptyLocalFolders
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "non_local_account_available",
          status: replacementAccountAvailable ? "passed" : "failed",
          expectedBool: true,
          actualBool: replacementAccountAvailable
        )
      )
    }
    if settingID == "use_touch_id" {
      let accountHashPresent = write.accountSHA256?.count == 64
      let preferenceKeyHashPresent = write.preferenceKeySHA256?.count == 64
      let localAuthBoundaryPresent =
        write.localAuthenticationAvailable != nil
          && write.biometricsEnrolled != nil
          && write.biometricsTypeSHA256?.count == 64
      checks.append(
        NotesVerificationCheckRecord(
          name: "account_hash_accounting",
          status: accountHashPresent ? "passed" : "failed",
          expectedBool: true,
          actualBool: accountHashPresent
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "touch_id_preference_key_hash",
          status: preferenceKeyHashPresent ? "passed" : "failed",
          expectedBool: true,
          actualBool: preferenceKeyHashPresent
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "local_auth_boundary_accounting",
          status: localAuthBoundaryPresent ? "passed" : "failed",
          expectedBool: true,
          actualBool: localAuthBoundaryPresent
        )
      )
    }
    if settingID == "locked_notes" {
      let passphraseSourceKinds = [
        write.passphraseSourceKind,
        write.oldPassphraseSourceKind,
        write.newPassphraseSourceKind,
      ].compactMap(\.self)
      let passphraseSourceSupported =
        passphraseSourceKinds.isEmpty == false
          && passphraseSourceKinds.allSatisfy { ["stdin", "env", "file"].contains($0) }
      let accountHashPresent = write.accountSHA256?.count == 64
      let hintHashAccounting = write.hintSHA256.map { $0.count == 64 } ?? true
      let hintLengthAccounting = (write.hintLength ?? 0) >= 0
      let acceptedImplementationCalls = [
        "ICAccountPassphraseManager.setPassphrase:hint:",
        "ICAccountPassphraseManager.setPassphrase:hint:isReset:",
        "ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:",
      ]
      let implementationCallSupported = acceptedImplementationCalls.contains(write.backendCalls ?? "")
      let resetBoundaryAccounting =
        operation != "notes.settings.reset-password"
          || (write.resetRequested == true
            && write.backendCalls == "ICAccountPassphraseManager.setPassphrase:hint:isReset:")
      let changeBoundaryAccounting =
        operation != "notes.settings.change-password"
          || (write.passwordChangeRequested == true
            && write.oldPassphraseSourceKind != nil
            && write.newPassphraseSourceKind != nil
            && write.backendCalls == "ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:")
      checks.append(
        NotesVerificationCheckRecord(
          name: "passphrase_source_supported",
          status: passphraseSourceSupported ? "passed" : "failed",
          expectedBool: true,
          actualBool: passphraseSourceSupported
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "account_hash_accounting",
          status: accountHashPresent ? "passed" : "failed",
          expectedBool: true,
          actualBool: accountHashPresent
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "hint_hash_boundary",
          status: hintHashAccounting && hintLengthAccounting ? "passed" : "failed",
          expectedBool: true,
          actualBool: hintHashAccounting && hintLengthAccounting
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "private_passphrase_manager_implementation",
          status: implementationCallSupported ? "passed" : "failed",
          expectedSHA256: expectedPassphraseImplementationSHA256(write),
          actualSHA256: write.backendCalls.map(sha256Hex)
        )
      )
      if operation == "notes.settings.reset-password" {
        checks.append(
          NotesVerificationCheckRecord(
            name: "reset_passphrase_boundary",
            status: resetBoundaryAccounting ? "passed" : "failed",
            expectedBool: true,
            actualBool: resetBoundaryAccounting
          )
        )
      }
      if operation == "notes.settings.change-password" {
        checks.append(
          NotesVerificationCheckRecord(
            name: "change_passphrase_boundary",
            status: changeBoundaryAccounting ? "passed" : "failed",
            expectedBool: true,
            actualBool: changeBoundaryAccounting
          )
        )
        checks.append(
          NotesVerificationCheckRecord(
            name: "old_new_passphrase_source_boundary",
            status: write.oldPassphraseSourceKind != nil && write.newPassphraseSourceKind != nil ? "passed" : "failed",
            expectedBool: true,
            actualBool: write.oldPassphraseSourceKind != nil && write.newPassphraseSourceKind != nil
          )
        )
      }
    }
    if settingID == "locked_notes_method" {
      let accountHashPresent = write.accountSHA256?.count == 64
      let systemPasscodePreflight = write.systemPasscodeAvailable == true
      let modeSupported = write.lockedNotesModeSupported == true
      let emptyProtectedNotes = write.passwordProtectedNoteCountBefore == .some(0)
      let implementationCallSupported = write.backendCalls == "ICAccount.setResolvedLockedNotesMode:"
      checks.append(
        NotesVerificationCheckRecord(
          name: "account_hash_accounting",
          status: accountHashPresent ? "passed" : "failed",
          expectedBool: true,
          actualBool: accountHashPresent
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "system_passcode_precondition",
          status: systemPasscodePreflight ? "passed" : "failed",
          expectedBool: true,
          actualBool: systemPasscodePreflight
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "locked_notes_mode_supported",
          status: modeSupported ? "passed" : "failed",
          expectedBool: true,
          actualBool: modeSupported
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "no_existing_password_protected_notes_preflight",
          status: emptyProtectedNotes ? "passed" : "failed",
          expectedLength: 0,
          actualLength: write.passwordProtectedNoteCountBefore
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "private_locked_notes_mode_implementation",
          status: implementationCallSupported ? "passed" : "failed",
          expectedSHA256: sha256Hex("ICAccount.setResolvedLockedNotesMode:"),
          actualSHA256: write.backendCalls.map(sha256Hex)
        )
      )
    }
    return NotesMutationVerificationReport(
      verifier: "notes_settings_mutation_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: settingsPreferenceEvidenceLevel(settingID),
      targetIDSHA256: sha256Hex(["notes.settings", settingID].joined(separator: "|")),
      checks: checks
    )
  }

  private func settingsPreferenceChanged(_ write: NotesSettingsPreferenceWriteResult) -> Bool {
    if write.passwordChangeRequested == true {
      return true
    }
    switch settingsPreferenceValueIsBool(write.valueKind) {
    case true:
      return write.beforeBoolValue != write.afterBoolValue
    case false:
      return write.beforeValueSHA256 != write.afterValueSHA256
    }
  }

  private func settingsPreferenceExpectedChanged(_ write: NotesSettingsPreferenceWriteResult) -> Bool {
    if write.passwordChangeRequested == true {
      return true
    }
    switch settingsPreferenceValueIsBool(write.valueKind) {
    case true:
      return write.beforeBoolValue != write.requestedBoolValue
    case false:
      return write.beforeValueSHA256 != write.requestedValueSHA256
    }
  }

  private func settingsPreferenceValueIsBool(_ valueKind: String) -> Bool {
    valueKind == "bool" || valueKind == "account_scoped_bool"
  }

  private func expectedPassphraseImplementationSHA256(_ write: NotesSettingsPreferenceWriteResult) -> String {
    if write.passwordChangeRequested == true {
      return sha256Hex("ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:")
    }
    if write.resetRequested == true {
      return sha256Hex("ICAccountPassphraseManager.setPassphrase:hint:isReset:")
    }
    return sha256Hex("ICAccountPassphraseManager.setPassphrase:hint:")
  }

  private func settingsPreferenceEvidenceLevel(_ settingID: String) -> String {
    switch settingID {
    case "enable_on_my_mac_account":
      return "private_framework_local_account_lifecycle+settings_readback"
    case "use_touch_id":
      return "private_touch_id_preference_readback+local_auth_boundary"
    case "locked_notes":
      return "ICAccountPassphraseManager.setPassphrase+account_crypto_strategy_readback+secret_source_boundary"
    case "locked_notes_method":
      return "ICAccount.setResolvedLockedNotesMode+system_passcode_preflight+empty_protected_notes_preflight"
    default:
      return "private_framework_settings_setter+preference_readback"
    }
  }

  private func verifySettingsRead(
    _ evidence: NotesSettingsReadEvidence,
    operation: String
  ) -> NotesMutationVerificationReport {
    let officialIDs = Set(notesSettingsOfficialFamilyIDs())
    let familyIDs = Set(evidence.families.map(\.id))
    let allowedStatuses = Set(["supported", "gated", "delegated", "rejected"])
    let statusAccounting = evidence.families.allSatisfy { allowedStatuses.contains($0.status) }
    let sortFamily = evidence.families.first { $0.id == "sort_notes_by" }
    let defaultAccountFamily = evidence.families.first { $0.id == "default_account" }
    let defaultParagraphStyleFamily = evidence.families.first { $0.id == "new_notes_start_with" }
    let groupNotesByDateFamily = evidence.families.first { $0.id == "group_notes_by_date" }
    let defaultDateHeadersTypeFamily = evidence.families.first { $0.id == "default_date_headers_type" }
    let queryDateHeadersTypeFamily = evidence.families.first { $0.id == "query_date_headers_type" }
    let quickNoteResumeFamily = evidence.families.first { $0.id == "always_resume_to_last_quick_note" }
    let mentionNotificationsFamily = evidence.families.first { $0.id == "allow_mention_notifications" }
    let checklistAutoSortFamily = evidence.families.first { $0.id == "automatically_sort_checked_items" }
    let defaultTextSizeFamily = evidence.families.first { $0.id == "default_text_size" }
    let touchIDFamily = evidence.families.first { $0.id == "use_touch_id" }
    let lockedNotesFamily = evidence.families.first { $0.id == "locked_notes" }
    let onMyMacFamily = evidence.families.first { $0.id == "enable_on_my_mac_account" }
    let supportedEvidence =
      (sortFamily?.status != "supported"
        || (sortFamily?.valueKind == "note_list_sort_sha256"
          && sortFamily?.valueSHA256?.count == 64))
        && defaultAccountFamily?.status == "supported"
        && defaultAccountFamily?.valueKind == "account_id_sha256"
        && (defaultParagraphStyleFamily?.status != "supported"
          || (defaultParagraphStyleFamily?.valueKind == "paragraph_style_sha256"
            && defaultParagraphStyleFamily?.valueSHA256?.count == 64))
        && (groupNotesByDateFamily?.status != "supported"
          || (groupNotesByDateFamily?.valueKind == "bool"
            && groupNotesByDateFamily?.boolValue != nil))
        && (defaultDateHeadersTypeFamily?.status != "supported"
          || (defaultDateHeadersTypeFamily?.valueKind == "date_headers_type_sha256"
            && defaultDateHeadersTypeFamily?.valueSHA256?.count == 64))
        && (queryDateHeadersTypeFamily?.status != "supported"
          || (queryDateHeadersTypeFamily?.valueKind == "date_headers_type_sha256"
            && queryDateHeadersTypeFamily?.valueSHA256?.count == 64))
        && (quickNoteResumeFamily?.status != "supported"
          || (quickNoteResumeFamily?.valueKind == "bool"
            && quickNoteResumeFamily?.boolValue != nil))
        && (mentionNotificationsFamily?.status != "supported"
          || (mentionNotificationsFamily?.valueKind == "bool"
            && mentionNotificationsFamily?.boolValue != nil))
        && (checklistAutoSortFamily?.status != "supported"
          || (checklistAutoSortFamily?.valueKind == "bool"
            && checklistAutoSortFamily?.boolValue != nil))
        && (defaultTextSizeFamily?.status != "supported"
          || (defaultTextSizeFamily?.valueKind == "text_size_sha256"
            && defaultTextSizeFamily?.valueSHA256?.count == 64))
        && (touchIDFamily?.status != "supported"
          || (touchIDFamily?.valueKind == "account_scoped_bool"
            && (evidence.selectedAccountCount == 1 ? touchIDFamily?.boolValue != nil : true)))
        && (lockedNotesFamily?.status != "supported"
          || (lockedNotesFamily?.valueKind == "account_passphrase_state"
            && (evidence.selectedAccountCount == 1
              ? lockedNotesFamily?.boolValue != nil && lockedNotesFamily?.valueSHA256?.count == 64
              : true)))
        && onMyMacFamily?.status == "supported"
        && onMyMacFamily?.valueKind == "bool"
        && onMyMacFamily?.boolValue == evidence.onMyMacAccountPresent
    let privacyHashAccounting =
      (evidence.requestedAccountSHA256.map { $0.count == 64 } ?? true)
        && (evidence.defaultAccountIDSHA256.map { $0.count == 64 } ?? true)
        && evidence.families.allSatisfy { family in
          family.valueSHA256.map { $0.count == 64 } ?? true
        }
    let accountScopeAccounting =
      (evidence.accountScope == "all" || evidence.accountScope == "selected")
        && evidence.accountCount >= 0
        && evidence.selectedAccountCount >= 0
        && evidence.selectedAccountCount <= evidence.accountCount
    let checks = [
      NotesVerificationCheckRecord(
        name: "official_settings_family_accounting",
        status: officialIDs.isSubset(of: familyIDs) ? "passed" : "failed",
        expectedBool: true,
        actualBool: officialIDs.isSubset(of: familyIDs)
      ),
      NotesVerificationCheckRecord(
        name: "status_accounting",
        status: statusAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: statusAccounting
      ),
      NotesVerificationCheckRecord(
        name: "supported_private_readback_accounting",
        status: supportedEvidence ? "passed" : "failed",
        expectedBool: true,
        actualBool: supportedEvidence
      ),
      NotesVerificationCheckRecord(
        name: "privacy_hash_accounting",
        status: privacyHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "account_scope_accounting",
        status: accountScopeAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: accountScopeAccounting
      ),
    ]
    let targetFields = [
      evidence.accountScope,
      evidence.requestedAccountSHA256 ?? "",
      evidence.defaultAccountIDSHA256 ?? "",
      evidence.families.map { "\($0.id):\($0.status)" }.joined(separator: ","),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_settings_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_account_settings_readback+official_settings_family_accounting",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func settingsBoundaryCapabilityError(
    operation: String,
    capability: String,
    appleCapability: String,
    status: String,
    futureGate: String,
    requiredImplementation: String,
    requiredVerifier: String
  ) -> CLIError {
    let appleName = appleCapability.replacingOccurrences(of: "_", with: " ")
    let displayName =
      appleName.hasPrefix("notes ") ? String(appleName.dropFirst("notes ".count)) : appleName
    let message: String
    switch status {
    case "delegated":
      message = "Notes \(displayName) is delegated to macOS or user-facing system surfaces, not direct Notes data mutation."
    case "rejected":
      message = "Notes \(displayName) is outside the direct Notes CLI mutation contract."
    default:
      message = "Notes \(displayName) is gated until capability-specific proof and verifier readback are accepted."
    }

    return CLIError(
      code: .unsupportedOperation,
      message: message,
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": status,
        "future_gate": futureGate,
        "required_implementation": requiredImplementation,
        "required_verifier": requiredVerifier,
        "backend_calls": "none",
      ]
    )
  }

  func settingsBoundaryRefusal(
    options: CLIOptions,
    allowedOptions: [String],
    requiredOptions: [String] = [],
    boolOptions: [String] = [],
    operation: String,
    capability: String,
    appleCapability: String,
    status: String,
    futureGate: String,
    requiredImplementation: String,
    requiredVerifier: String
  ) throws -> CLICommandResult? {
    try validateTargetOptions(options, allowedOptions: Set(allowedOptions))
    for option in requiredOptions {
      _ = try requiredOption(option, options: options)
    }
    for option in boolOptions {
      _ = try normalizedBoolOption(option, options: options)
    }
    throw settingsBoundaryCapabilityError(
      operation: operation,
      capability: capability,
      appleCapability: appleCapability,
      status: status,
      futureGate: futureGate,
      requiredImplementation: requiredImplementation,
      requiredVerifier: requiredVerifier
    )
  }

  private func settingsReader() throws -> any NotesSettingsReading {
    guard let settingsReader = implementation as? any NotesSettingsReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes settings read requires a private-framework settings reader.",
        details: [
          "capability": "settings_read",
          "required_module": "NotesShared",
        ]
      )
    }
    return settingsReader
  }

  private func settingsMutator() throws -> any NotesSettingsMutating {
    guard let settingsMutator = implementation as? any NotesSettingsMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes settings mutations require a private-framework settings writer.",
        details: [
          "capability": "settings_mutation",
          "required_module": "NotesShared/NotesUI/NotesEditor",
        ]
      )
    }
    return settingsMutator
  }
}
