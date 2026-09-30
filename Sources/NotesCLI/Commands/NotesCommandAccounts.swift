import Foundation
import Utility

extension NotesCommand {
  func runAccounts(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["accounts", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let accounts = try implementation.listAccounts()
      return try result(
        NotesAccountsResponse(accounts: accounts),
        human: accounts.map { "\($0.id)\t\($0.name)" }.joined(separator: "\n"),
        options: options
      )
    case ["accounts", "workflow", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try accountsWorkflowAudit(options)
    case ["accounts", "add"]:
      return try accountLifecycleBoundaryRefusal(
        options: options,
        allowedOptions: ["provider", "account"],
        requiredOptions: ["provider"],
        operation: "notes.accounts.add",
        capability: "external_notes_account_add",
        appleCapability: "add_notes_account"
      )
    case ["accounts", "remove"]:
      return try accountLifecycleBoundaryRefusal(
        options: options,
        allowedOptions: ["account"],
        requiredOptions: ["account"],
        operation: "notes.accounts.remove",
        capability: "external_notes_account_remove",
        appleCapability: "remove_notes_account"
      )
    case ["accounts", "enable"]:
      return try accountLifecycleBoundaryRefusal(
        options: options,
        allowedOptions: ["account"],
        requiredOptions: ["account"],
        operation: "notes.accounts.enable",
        capability: "external_notes_account_service_enable",
        appleCapability: "enable_notes_for_account"
      )
    case ["accounts", "disable"]:
      return try accountLifecycleBoundaryRefusal(
        options: options,
        allowedOptions: ["account"],
        requiredOptions: ["account"],
        operation: "notes.accounts.disable",
        capability: "external_notes_account_service_disable",
        appleCapability: "disable_notes_for_account"
      )    default:
      return nil
    }
  }

  func accountIdentity(selector: String) throws -> NotesAccountRecord {
    let accounts = try implementation.listAccounts()
    if let match = accounts.first(where: { $0.id == selector }) {
      return match
    }

    let nameMatches = accounts.filter {
      $0.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if nameMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Account selector matched multiple Notes accounts.",
        details: ["account_sha256": sha256Hex(selector)]
      )
    }

    guard let match = nameMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Account selector did not match any Notes account.",
        details: ["account_sha256": sha256Hex(selector)]
      )
    }
    return match
  }

  private func accountsWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.accounts.workflow.audit"
    let records = notesAccountsWorkflowAuditRecords()
    let summary = notesAccountsWorkflowAuditSummary(records)
    let verification = verifyAccountsWorkflowAudit(records: records, summary: summary)
    let response = NotesAccountsWorkflowAuditResponse(
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

  private func notesAccountsWorkflowAuditRecords() -> [NotesAccountsWorkflowAuditRecord] {
    struct AccountsWorkflowAuditItem {
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
      AccountsWorkflowAuditItem(
        family: "account_metadata_listing",
        guideSection: "Add or remove accounts / Add an account",
        status: "supported",
        appleCapability: "view_notes_accounts_listed_separately",
        command: "accounts list",
        mechanism: "typed_private_notes_framework_account_reader",
        requiredImplementation: "private account metadata readback",
        requiredVerifier: "private_account_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "account_ids_and_display_names_only",
        reason: "`accounts list` reads visible Notes accounts through the private reader and keeps notes content out of output."
      ),
      AccountsWorkflowAuditItem(
        family: "account_scoped_visibility",
        guideSection: "Add or remove accounts / Add an account",
        status: "supported",
        appleCapability: "view_notes_and_folders_by_account",
        command: "folders list --account ACCOUNT; list --account ACCOUNT; search --account ACCOUNT",
        mechanism: "typed_private_notes_framework_account_scoped_readers",
        requiredImplementation: "private account-scoped visible folder/note selection",
        requiredVerifier: "private_account_scoped_readback+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "account_selector_without_note_bodies",
        reason: "Accepted account-scoped folder, note-list, and text-search readers expose account separation without dumping note bodies."
      ),
      AccountsWorkflowAuditItem(
        family: "on_my_mac_enable",
        guideSection: "Add or remove accounts / Add the On My Mac account",
        status: "supported",
        appleCapability: "enable_on_my_mac_account",
        command: "settings on-my-mac --enabled true",
        mechanism: "typed_private_notes_framework_account_settings_writer",
        requiredImplementation: "ICNoteContext local account enablement path",
        requiredVerifier: "notes_settings_mutation_v1+local_account_presence_readback",
        safetyGate: "--allow-persistent-action",
        privacyBoundary: "local_account_presence_boolean_only",
        reason: "Enabling the local account is accepted with persistent-action safety and private account/settings readback."
      ),
      AccountsWorkflowAuditItem(
        family: "internet_account_add",
        guideSection: "Add or remove accounts / Add an account",
        status: "delegated",
        appleCapability: "add_internet_notes_account",
        command: "accounts add --provider PROVIDER [--account ACCOUNT]",
        mechanism: "delegated_macos_internet_accounts_route",
        requiredImplementation: "macos_internet_accounts_add_account",
        requiredVerifier: "delegated_internet_accounts_accounting",
        safetyGate: "none",
        privacyBoundary: "provider_or_account_hash_without_credentials",
        reason: "Adding Google, Yahoo, AOL, managed, or other internet accounts belongs to macOS Internet Accounts and sign-in UI."
      ),
      AccountsWorkflowAuditItem(
        family: "account_type_selection_sign_in",
        guideSection: "Add or remove accounts / Add an account",
        status: "delegated",
        appleCapability: "select_account_type_and_enter_credentials",
        command: "macOS Internet Accounts sign-in UI",
        mechanism: "delegated_macos_internet_accounts_ui",
        requiredImplementation: "credential_ui_route",
        requiredVerifier: "delegated_credential_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_credentials_accepted_or_printed",
        reason: "Account type selection and credential entry are interactive system UI surfaces, not Notes data-model writes."
      ),
      AccountsWorkflowAuditItem(
        family: "safari_settings_sign_in_continuation",
        guideSection: "Add or remove accounts / Add an account",
        status: "delegated",
        appleCapability: "continue_account_sign_in_from_safari_to_system_settings",
        command: "Safari and System Settings",
        mechanism: "delegated_browser_and_system_settings_route",
        requiredImplementation: "safari_authentication_continuation",
        requiredVerifier: "delegated_authentication_route_accounting",
        safetyGate: "none",
        privacyBoundary: "no_authentication_tokens_or_credentials",
        reason: "Safari-based authentication continuation is a browser/system settings route outside the Notes CLI contract."
      ),
      AccountsWorkflowAuditItem(
        family: "internet_account_notes_enable",
        guideSection: "Add or remove accounts / Add an account / Temporarily stop using an account",
        status: "delegated",
        appleCapability: "turn_notes_on_for_existing_internet_account",
        command: "accounts enable --account ACCOUNT",
        mechanism: "delegated_macos_internet_accounts_route",
        requiredImplementation: "macos_internet_accounts_service_toggle",
        requiredVerifier: "delegated_internet_accounts_accounting",
        safetyGate: "none",
        privacyBoundary: "account_selector_hash_without_account_values",
        reason: "Turning Notes on for an internet account is accounted as delegated system account service management."
      ),
      AccountsWorkflowAuditItem(
        family: "internet_account_notes_disable",
        guideSection: "Add or remove accounts / Temporarily stop using an account",
        status: "delegated",
        appleCapability: "turn_notes_off_for_existing_internet_account",
        command: "accounts disable --account ACCOUNT",
        mechanism: "delegated_macos_internet_accounts_route",
        requiredImplementation: "macos_internet_accounts_service_toggle",
        requiredVerifier: "delegated_internet_accounts_accounting",
        safetyGate: "none",
        privacyBoundary: "account_selector_hash_without_account_values",
        reason: "Temporarily hiding an internet account's Notes is delegated to macOS Internet Accounts rather than direct Notes data mutation."
      ),
      AccountsWorkflowAuditItem(
        family: "internet_account_remove",
        guideSection: "Add or remove accounts / Remove an account",
        status: "delegated",
        appleCapability: "remove_internet_notes_account_from_mac",
        command: "accounts remove --account ACCOUNT",
        mechanism: "delegated_macos_internet_accounts_route",
        requiredImplementation: "macos_internet_accounts_remove_account",
        requiredVerifier: "delegated_internet_accounts_accounting",
        safetyGate: "none",
        privacyBoundary: "account_selector_hash_without_note_content",
        reason: "Removing an internet account affects system account state and remains delegated with no Notes implementation calls."
      ),
      AccountsWorkflowAuditItem(
        family: "cross_device_setup_handoff",
        guideSection: "Add or remove accounts / Remove an account",
        status: "delegated",
        appleCapability: "set_up_same_accounts_on_other_devices_and_use_handoff",
        command: "iCloud/iOS/iPadOS setup and Handoff",
        mechanism: "delegated_icloud_device_and_handoff_route",
        requiredImplementation: "device_setup_or_handoff_route",
        requiredVerifier: "delegated_cross_device_accounting",
        safetyGate: "none",
        privacyBoundary: "no_device_or_note_content_readback",
        reason: "Other-device setup and Handoff are iCloud/device continuity surfaces rather than local Notes CLI writes."
      ),
      AccountsWorkflowAuditItem(
        family: "on_my_mac_disable",
        guideSection: "Add or remove accounts / Add the On My Mac account",
        status: "supported",
        appleCapability: "disable_on_my_mac_account_after_enablement",
        command: "settings on-my-mac --enabled false",
        mechanism: "typed_private_notes_framework_account_settings_writer",
        requiredImplementation: "ICNoteContext empty-local-account disable path",
        requiredVerifier: "notes_settings_mutation_v1+empty_local_account_preflight+local_account_absence_readback",
        safetyGate: "--allow-persistent-action+empty_local_account_preflight",
        privacyBoundary: "must_not_print_local_note_content_or_account_values",
        reason: "Disabling the local account is accepted only when private readback proves no visible or trashed local notes, no local custom folders, a non-local account is active, and the local account is not default."
      ),
      AccountsWorkflowAuditItem(
        family: "non_icloud_feature_parity",
        guideSection: "Add or remove accounts / Add an account",
        status: "rejected",
        appleCapability: "use_every_notes_feature_with_non_icloud_accounts",
        command: "none",
        mechanism: "apple_product_provider_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "provider_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that all guide features are available with iCloud notes and some are unavailable with other providers."
      ),
      AccountsWorkflowAuditItem(
        family: "on_my_mac_cross_device_access",
        guideSection: "Add or remove accounts / Add the On My Mac account",
        status: "rejected",
        appleCapability: "access_on_my_mac_notes_from_other_devices_or_icloud_com",
        command: "none",
        mechanism: "apple_product_local_account_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "local_account_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that On My Mac notes are local to the computer and unavailable on other devices or iCloud.com."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesAccountsWorkflowAuditRecord(
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

  private func notesAccountsWorkflowAuditSummary(
    _ records: [NotesAccountsWorkflowAuditRecord]
  ) -> NotesAccountsWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesAccountsWorkflowAuditSummary(
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

  private func verifyAccountsWorkflowAudit(
    records: [NotesAccountsWorkflowAuditRecord],
    summary: NotesAccountsWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let rejected = Set(summary.rejectedWorkflowFamilies)
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
        name: "official_account_sections_accounted",
        expected: true,
        actual: guideSectionSet.contains("Add or remove accounts")
          && guideSectionSet.contains("Add an account")
          && guideSectionSet.contains("Add the On My Mac account")
          && guideSectionSet.contains("Temporarily stop using an account")
          && guideSectionSet.contains("Remove an account")
      ),
      verificationBoolCheck(
        name: "private_account_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: ["account_metadata_listing", "account_scoped_visibility", "on_my_mac_enable", "on_my_mac_disable"]
        )
      ),
      verificationBoolCheck(
        name: "internet_account_workflows_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "internet_account_add", "account_type_selection_sign_in",
            "safari_settings_sign_in_continuation", "internet_account_notes_enable",
            "internet_account_notes_disable", "internet_account_remove", "cross_device_setup_handoff",
          ]
        )
      ),
      verificationBoolCheck(
        name: "provider_limitations_rejected",
        expected: true,
        actual: rejected.isSuperset(of: ["non_icloud_feature_parity", "on_my_mac_cross_device_access"])
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
      operation: "notes.accounts.workflow.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.accounts.workflow.audit"),
      checks: checks
    )
  }

  private func accountLifecycleBoundaryRefusal(
    options: CLIOptions,
    allowedOptions: [String],
    requiredOptions: [String],
    operation: String,
    capability: String,
    appleCapability: String
  ) throws -> CLICommandResult? {
    try settingsBoundaryRefusal(
      options: options,
      allowedOptions: allowedOptions,
      requiredOptions: requiredOptions,
      operation: operation,
      capability: capability,
      appleCapability: appleCapability,
      status: "delegated",
      futureGate: "internet_accounts_account_management_delegation",
      requiredImplementation: "macos_internet_accounts_route",
      requiredVerifier: "delegated_internet_accounts_accounting"
    )
  }
}
