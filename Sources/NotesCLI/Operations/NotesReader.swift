import AppKit
import CoreData
import CoreGraphics
import CoreSpotlight
import Foundation
#if canImport(PDFKit)
import PDFKit
#endif
import NotesEditor
import NotesShared
import NotesSupport
import NotesUI
import Utility

private final class NotesPassphraseChangeCompletion: @unchecked Sendable {
  private let lock = NSLock()
  private var _completed = false

  func complete() {
    lock.lock()
    _completed = true
    lock.unlock()
  }

  var completed: Bool {
    lock.lock()
    let value = _completed
    lock.unlock()
    return value
  }
}

struct NotesReader: NotesReading, NotesFolderPurgeReading, NotesTagReading, NotesAttachmentReading,
  NotesAttachmentSearchIndexMutating,
  NotesLinkReading, NotesSmartFolderReading, NotesFolderMoveImpactReading, NotesBodyStructureReading, NotesBodyMathExpressionScanning, NotesParagraphAnchorResolving,
  NotesNoteStateReading, NotesNoteStateMutating, NotesCollaborationLinkReading, NotesCollaborationParticipantsReading,
  NotesSettingsReading,
  NotesSettingsMutating, NotesNoteExporting, NotesLockedContentExporting, NotesNaturalLanguageSearching
{
  func listAccounts() throws -> [NotesAccountRecord] {
    let managedObjectContext = try managedObjectContext()
    let accounts: [ICAccount] = objects(
      ICAccount.allActiveAccounts(inContext: managedObjectContext))
    return accounts
      .map { account in
        NotesAccountRecord(
          id: objectIDString(account),
          name: nonEmpty(account.localizedName) ?? nonEmpty(account.name) ?? "Notes"
        )
      }
      .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
  }

  func readSettings(account selector: String?) throws -> NotesSettingsReadEvidence {
    let managedObjectContext = try managedObjectContext()
    let accounts: [ICAccount] = objects(ICAccount.allActiveAccounts(inContext: managedObjectContext))
    let selectedAccounts = accounts.filter { account in
      matchesAccount(account, accountName: account.localizedName ?? account.name, selector: selector)
    }
    if selector != nil && selectedAccounts.isEmpty {
      throw CLIError(
        code: .notFound,
        message: "Notes settings account scope was not found.",
        details: ["account_sha256": selector.map(sha256Hex) ?? ""]
      )
    }
    let defaultAccount = ICDefaultAccountUtilities.defaultAccount() as? ICAccount
    let defaultAccountID = defaultAccount.map { objectIDString($0) }
    let defaultAccountIDSHA256 = defaultAccountID.map(sha256Hex)
    let onMyMacAccountPresent = accounts.contains { $0.isLocalAccount }
    let currentNoteListSortSHA256 = noteListSortReadbackSHA256()
    let defaultParagraphStyleSHA256 = defaultParagraphStyleReadbackSHA256()
    let groupNotesByDateEnabled = ICDateHeadersUtilities.currentDateHeadersOn()
    let defaultDateHeadersTypeSHA256 = dateHeadersTypeReadbackSHA256(
      scope: "default",
      type: ICDateHeadersUtilities.defaultDateHeadersType()
    )
    let supportsQueryDateHeaders = ICDateHeadersUtilities.supportsQueryDateHeaders()
    let queryDateHeadersTypeSHA256 = supportsQueryDateHeaders
      ? dateHeadersTypeReadbackSHA256(scope: "query", type: ICDateHeadersUtilities.queryDateHeadersType())
      : nil
    let showsQueryDateHeaders = supportsQueryDateHeaders ? ICDateHeadersUtilities.showsQueryDateHeaders() : nil
    let quickNoteResumeLastEnabled = ICPaperCommonUtilities.shouldResumeLastQuickNote()
    let mentionNotificationsEnabled = ICSettingsUtilities.bool(forKey: ICMentionNotificationsPrefIdentifier)
    let checklistAutoSortEnabled = ICTextController.checklistAutoSortEnabled()
    let defaultTextSizeSHA256 = defaultTextSizeReadbackSHA256()
    let touchIDPreferenceEnabled = selectedAccounts.count == 1
      ? touchIDPreferenceEnabled(for: selectedAccounts[0])
      : nil
    let lockedNotesPassphraseState = selectedAccounts.count == 1
      ? accountPassphraseState(selectedAccounts[0])
      : nil
    return NotesSettingsReadEvidence(
      accountScope: selector == nil ? "all" : "selected",
      requestedAccountSHA256: selector.map(sha256Hex),
      accountCount: accounts.count,
      selectedAccountCount: selectedAccounts.count,
      defaultAccountIDSHA256: defaultAccountIDSHA256,
      onMyMacAccountPresent: onMyMacAccountPresent,
      supportsQueryDateHeaders: supportsQueryDateHeaders,
      showsQueryDateHeaders: showsQueryDateHeaders,
      families: notesSettingsFamilies(
        defaultAccountIDSHA256: defaultAccountIDSHA256,
        onMyMacAccountPresent: onMyMacAccountPresent,
        currentNoteListSortSHA256: currentNoteListSortSHA256,
        defaultParagraphStyleSHA256: defaultParagraphStyleSHA256,
        groupNotesByDateEnabled: groupNotesByDateEnabled,
        defaultDateHeadersTypeSHA256: defaultDateHeadersTypeSHA256,
        queryDateHeadersTypeSHA256: queryDateHeadersTypeSHA256,
        supportsQueryDateHeaders: supportsQueryDateHeaders,
        showsQueryDateHeaders: showsQueryDateHeaders,
        quickNoteResumeLastEnabled: quickNoteResumeLastEnabled,
        mentionNotificationsEnabled: mentionNotificationsEnabled,
        checklistAutoSortEnabled: checklistAutoSortEnabled,
        defaultTextSizeSHA256: defaultTextSizeSHA256,
        touchIDPreferenceAvailable: touchIDAuthenticationState() != nil,
        touchIDPreferenceEnabled: touchIDPreferenceEnabled,
        lockedNotesPassphraseSet: lockedNotesPassphraseState?.hasPassphraseSet,
        lockedNotesStateSHA256: lockedNotesPassphraseState?.stateSHA256
      )
    )
  }

  func setNoteListSort(_ draft: NotesSettingsSortMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "sort_notes_by"
    let operation = "notes.settings.sort"
    let before = try readSettings(account: nil)
    let sortType = try settingsNoteListSortType(draft, operation: operation)
    let requestedValueSHA256 = noteListSortReadbackSHA256(forType: sortType)
    ICNoteListSortUtilities.setCurrentNoteListSortType(sortType)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "note_list_sort_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256
    )
  }

  func setDefaultNewNoteStyle(_ draft: NotesSettingsParagraphStyleMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "new_notes_start_with"
    let operation = "notes.settings.new-note-style"
    let before = try readSettings(account: nil)
    let desiredStyle = try settingsParagraphStyleValue(draft.style, operation: operation)
    let requestedValueSHA256 = defaultParagraphStyleReadbackSHA256(forRawStyle: desiredStyle)
    ICTextStyle.setNoteDefaultNamed(desiredStyle)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "paragraph_style_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256
    )
  }

  func setDefaultAccount(_ draft: NotesSettingsDefaultAccountMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "default_account"
    let before = try readSettings(account: nil)
    let account = try accountObject(id: draft.accountID, name: draft.accountName)
    let accountID = objectIDString(account)
    let requestedValueSHA256 = sha256Hex(accountID)
    ICDefaultAccountUtilities.setDefaultAccountIdentifier(accountID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_id_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256
    )
  }

  func setGroupNotesByDate(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "group_notes_by_date"
    let before = try readSettings(account: nil)
    ICDateHeadersUtilities.setDateHeadersOn(draft.enabled)
    ICDateHeadersUtilities.clearCache()
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: settingsFamily(in: before, id: settingID)?.boolValue,
      afterBoolValue: settingsFamily(in: after, id: settingID)?.boolValue
    )
  }

  func setDateHeadersPreference(_ draft: NotesSettingsDateHeadersMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "\(draft.scope)_date_headers_type"
    let before = try readSettings(account: nil)
    let requestedValueSHA256 = dateHeadersTypeReadbackSHA256(
      scope: draft.scope,
      type: Int64(draft.privateValue)
    )
    switch draft.scope {
    case "default":
      ICDateHeadersUtilities.setDefaultDateHeadersType(Int64(draft.privateValue))
    case "query":
      guard ICDateHeadersUtilities.supportsQueryDateHeaders() else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Notes query date headers are not supported by the linked private framework on this host.",
          details: [
            "operation": "notes.settings.group-by-date",
            "setting_id": settingID,
          ]
        )
      }
      ICDateHeadersUtilities.setQueryDateHeadersType(Int64(draft.privateValue))
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes date-header preference scope.",
        details: [
          "operation": "notes.settings.group-by-date",
          "scope": draft.scope,
        ]
      )
    }
    ICDateHeadersUtilities.clearCache()
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "date_headers_type_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256
    )
  }

  func setQuickNoteResumeLast(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "always_resume_to_last_quick_note"
    let before = try readSettings(account: nil)
    ICSettingsUtilities.setBool(draft.enabled, forKey: ICResumeLastQuickNotePrefIdentifier)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: settingsFamily(in: before, id: settingID)?.boolValue,
      afterBoolValue: settingsFamily(in: after, id: settingID)?.boolValue
    )
  }

  func setMentionNotifications(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "allow_mention_notifications"
    let before = try readSettings(account: nil)
    ICSettingsUtilities.setBool(draft.enabled, forKey: ICMentionNotificationsPrefIdentifier)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: settingsFamily(in: before, id: settingID)?.boolValue,
      afterBoolValue: settingsFamily(in: after, id: settingID)?.boolValue
    )
  }

  func setDefaultTextSize(_ draft: NotesSettingsTextSizeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "default_text_size"
    let operation = "notes.settings.text-size"
    let before = try readSettings(account: nil)
    let zoomIndex = try defaultTextSizeZoomIndex(forPointSize: draft.pointSize, operation: operation)
    let requestedValueSHA256 = defaultTextSizeReadbackSHA256(forIndex: zoomIndex)
    ICMZoomController.setGlobalZoomFactorIndex(zoomIndex)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "text_size_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256
    )
  }

  func setOnMyMacAccountEnabled(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "enable_on_my_mac_account"
    let before = try readSettings(account: nil)
    var localAccountNoteCount: Int?
    var localAccountCustomFolderCount: Int?
    var nonLocalAccountCount: Int?
    if draft.enabled, settingsFamily(in: before, id: settingID)?.boolValue != true {
      ICNoteContext.enableLocalAccount()
    } else if !draft.enabled {
      let context = try noteContext()
      let managedObjectContext = try managedObjectContext()
      let accounts: [ICAccount] = objects(ICAccount.allActiveAccounts(inContext: managedObjectContext))
      let localAccount = accounts.first(where: \.isLocalAccount)
      let nonLocalAccounts = accounts.filter { !$0.isLocalAccount }
      nonLocalAccountCount = nonLocalAccounts.count
      if let localAccount {
        localAccountNoteCount = localAccountVisibleNoteCountIncludingTrash(localAccount)
        localAccountCustomFolderCount = localAccountVisibleCustomFolderCount(localAccount)
        let defaultAccount = ICDefaultAccountUtilities.defaultAccount() as? ICAccount
        let defaultAccountIsLocal = defaultAccount.map { objectIDString($0) == objectIDString(localAccount) } ?? false
        guard localAccountNoteCount == .some(0),
          localAccountCustomFolderCount == .some(0),
          !defaultAccountIsLocal,
          !nonLocalAccounts.isEmpty
        else {
          throw CLIError(
            code: .validationError,
            message: "Disabling the Notes On My Mac account requires an empty non-default local account and another active Notes account.",
            details: [
              "operation": "notes.settings.on-my-mac",
              "capability": settingID,
              "status": "refused",
              "required_local_note_count": "0",
              "local_note_count": "\(localAccountNoteCount ?? -1)",
              "required_local_custom_folder_count": "0",
              "local_custom_folder_count": "\(localAccountCustomFolderCount ?? -1)",
              "non_local_account_count": "\(nonLocalAccounts.count)",
              "default_account_is_local": defaultAccountIsLocal ? "true" : "false",
              "backend_calls": "private_framework_read_preflight_only",
            ]
          )
        }
        context.shouldEnsureLocalAccount = false
        context.addOrDeleteLocalAccountIfNecessary()
        try save(context: context, operation: "notes.settings.on-my-mac")
      }
    }
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: settingsFamily(in: before, id: settingID)?.boolValue,
      afterBoolValue: settingsFamily(in: after, id: settingID)?.boolValue,
      localAccountNoteCountBefore: localAccountNoteCount,
      localAccountCustomFolderCountBefore: localAccountCustomFolderCount,
      nonLocalAccountCountBefore: nonLocalAccountCount
    )
  }

  func setChecklistAutoSort(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "automatically_sort_checked_items"
    let before = try readSettings(account: nil)
    ICTextController.setChecklistAutoSortEnabled(draft.enabled)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: settingsFamily(in: before, id: settingID)?.boolValue,
      afterBoolValue: settingsFamily(in: after, id: settingID)?.boolValue
    )
  }

  func setTouchIDPreference(_ draft: NotesSettingsAccountBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "use_touch_id"
    let operation = "notes.settings.touch-id"
    let account = try accountObject(selector: draft.account, operation: operation)
    guard let state = touchIDAuthenticationState() else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private Touch ID preference state is unavailable.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(draft.account),
        ]
      )
    }

    let before = try readSettings(account: draft.account)
    try touchIDSetPreferenceEnabled(draft.enabled, for: account, state: state, operation: operation)
    let after = try readSettings(account: draft.account)
    let accountID = objectIDString(account)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_scoped_bool",
      accountSHA256: sha256Hex(accountID),
      preferenceKeySHA256: touchIDPreferenceKeySHA256(for: account, state: state),
      requestedBoolValue: draft.enabled,
      beforeBoolValue: settingsFamily(in: before, id: settingID)?.boolValue,
      afterBoolValue: settingsFamily(in: after, id: settingID)?.boolValue,
      localAuthenticationAvailable: ICLocalAuthentication.biometricsAvailable(),
      biometricsEnrolled: ICLocalAuthentication.biometricsEnrolled(),
      biometricsTypeSHA256: sha256Hex("ICLocalAuthentication.biometricsType|\(ICLocalAuthentication.biometricsType())")
    )
  }

  func setCustomPassphrase(_ draft: NotesSettingsPassphraseMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "locked_notes"
    let operation = draft.isReset ? "notes.settings.reset-password" : "notes.settings.locked-notes"
    let account = try accountObject(selector: draft.account, operation: operation)
    try validateAccountSupportsCustomPassphrase(account, operation: operation)
    let before = try readSettings(account: draft.account)
    guard let manager = ICAccountPassphraseManager(account: account) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private account passphrase manager could not be created.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
        ]
      )
    }
    let hint = draft.hint ?? ""
    let changed = try setPassphrase(
      draft.passphrase,
      hint: hint,
      manager: manager,
      operation: operation,
      reset: draft.isReset
    )
    guard changed else {
      throw CLIError(
        code: .internalError,
        message: "Notes private account passphrase manager refused the custom passphrase update.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "passphrase_source_kind": draft.passphraseSourceKind,
          "backend_calls": draft.isReset
            ? "ICAccountPassphraseManager.setPassphrase:hint:isReset:"
            : "ICAccountPassphraseManager.setPassphrase:hint:",
        ]
      )
    }
    if let context = account.managedObjectContext {
      try save(managedObjectContext: context, operation: operation)
    }
    let after = try readSettings(account: draft.account)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_passphrase_state",
      accountSHA256: sha256Hex(objectIDString(account)),
      requestedValueSHA256: notesLockedNotesPassphraseStateSHA256(
        hasPassphraseSet: true,
        hintSHA256: draft.hintSHA256
      ),
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256,
      passphraseSourceKind: draft.passphraseSourceKind,
      hintSHA256: draft.hintSHA256,
      hintLength: draft.hint?.utf8.count ?? 0,
      backendCalls: draft.isReset
        ? "ICAccountPassphraseManager.setPassphrase:hint:isReset:"
        : "ICAccountPassphraseManager.setPassphrase:hint:",
      resetRequested: draft.isReset
    )
  }

  func changeCustomPassphrase(_ draft: NotesSettingsPassphraseChangeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "locked_notes"
    let operation = "notes.settings.change-password"
    let account = try accountObject(selector: draft.account, operation: operation)
    try validateAccountSupportsCustomPassphrase(account, operation: operation)
    let before = try readSettings(account: draft.account)
    guard let manager = ICAccountPassphraseManager(account: account) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private account passphrase manager could not be created.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
        ]
      )
    }
    try changePassphrase(
      from: draft.oldPassphrase,
      to: draft.newPassphrase,
      hint: draft.hint ?? "",
      manager: manager,
      operation: operation
    )
    if let context = account.managedObjectContext {
      try save(managedObjectContext: context, operation: operation)
    }
    let after = try readSettings(account: draft.account)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_passphrase_state",
      accountSHA256: sha256Hex(objectIDString(account)),
      requestedValueSHA256: notesLockedNotesPassphraseStateSHA256(
        hasPassphraseSet: true,
        hintSHA256: draft.hintSHA256
      ),
      beforeValueSHA256: settingsFamily(in: before, id: settingID)?.valueSHA256,
      afterValueSHA256: settingsFamily(in: after, id: settingID)?.valueSHA256,
      oldPassphraseSourceKind: draft.oldPassphraseSourceKind,
      newPassphraseSourceKind: draft.newPassphraseSourceKind,
      hintSHA256: draft.hintSHA256,
      hintLength: draft.hint?.utf8.count ?? 0,
      backendCalls: "ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:",
      passwordChangeRequested: true
    )
  }

  func setLockedNotesMethod(_ draft: NotesSettingsLockedNotesMethodMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "locked_notes_method"
    let operation = "notes.settings.locked-notes"
    let account = try accountObject(selector: draft.account, operation: operation)
    try validateAccountSupportsLockedNotesMethod(account, operation: operation)
    guard draft.methodScope == "login-password", draft.modeRawValue == 2 else {
      throw CLIError(
        code: .validationError,
        message: "Only the Notes login-password locked-notes method is supported by this mutation path.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "method_scope": draft.methodScope,
        ]
      )
    }

    ICLocalAuthentication.refreshHasPasscode()
    let systemPasscodeAvailable = ICLocalAuthentication.hasPasscode()
    guard systemPasscodeAvailable else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes login-password locked-notes method requires a macOS login password on this host.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "status": "gated",
          "system_passcode_available": "false",
          "future_gate": "macos_login_password_required",
        ]
      )
    }

    let mode = Int16(draft.modeRawValue)
    let modeSupported = try lockedNotesModeSupported(account: account, mode: mode, operation: operation)
    guard modeSupported else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Selected Notes account does not support the login-password locked-notes method.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "status": "gated",
          "locked_notes_mode_supported": "false",
        ]
      )
    }

    guard let protectedNoteCount = accountPasswordProtectedNoteCount(account) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private framework did not expose selected-account password-protected note count.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "private_selector": "passwordProtectedNotes.count",
        ]
      )
    }
    guard protectedNoteCount == 0 else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Changing a Notes locked-notes password method for existing locked notes remains gated until migration readback is proven.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "status": "gated",
          "future_gate": "locked_notes_method_migration",
          "password_protected_note_count": "\(protectedNoteCount)",
          "required_implementation": "ICLockedNotesModeMigrator.migrateLockedNotesInAccount:toMode:window:completionHandler:",
          "required_verifier": "private_locked_note_rekey_migration_readback",
        ]
      )
    }

    guard let beforeMode = optionalInt(account, key: "resolvedLockedNotesMode") else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private framework did not expose selected-account locked-notes mode readback.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "private_selector": "resolvedLockedNotesMode",
        ]
      )
    }
    let beforeValueSHA256 = notesLockedNotesModeStateSHA256(
      modeRawValue: beforeMode,
      methodScope: lockedNotesMethodScope(modeRawValue: beforeMode)
    )
    if beforeMode != draft.modeRawValue {
      try setResolvedLockedNotesMode(mode, account: account, operation: operation)
      if let context = account.managedObjectContext {
        try save(managedObjectContext: context, operation: operation)
      }
    }
    guard let afterMode = optionalInt(account, key: "resolvedLockedNotesMode") else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private framework did not expose selected-account locked-notes mode readback after mutation.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "private_selector": "resolvedLockedNotesMode",
        ]
      )
    }
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "locked_notes_mode_state",
      accountSHA256: sha256Hex(objectIDString(account)),
      requestedValueSHA256: draft.modeSHA256,
      beforeValueSHA256: beforeValueSHA256,
      afterValueSHA256: notesLockedNotesModeStateSHA256(
        modeRawValue: afterMode,
        methodScope: lockedNotesMethodScope(modeRawValue: afterMode)
      ),
      backendCalls: "ICAccount.setResolvedLockedNotesMode:",
      systemPasscodeAvailable: systemPasscodeAvailable,
      lockedNotesModeSupported: modeSupported,
      passwordProtectedNoteCountBefore: protectedNoteCount
    )
  }

  private func noteListSortReadbackSHA256() -> String {
    noteListSortReadbackSHA256(forType: ICNoteListSortUtilities.currentNoteListSortType())
  }

  private func noteListSortReadbackSHA256(forType sortType: Int64) -> String {
    let description = ICNoteListSortUtilities.description(forNoteListSortType: sortType) as? String
    let folderSortOrder = ICNoteListSortUtilities.folderSortOrder(forNoteListSortType: sortType)
    return sha256Hex(
      [
        "ICNoteListSortUtilities.currentNoteListSortType",
        "\(sortType)",
        "\(folderSortOrder)",
        description ?? "",
      ].joined(separator: "|")
    )
  }

  private func defaultParagraphStyleReadbackSHA256() -> String {
    defaultParagraphStyleReadbackSHA256(forRawStyle: ICTextStyle.noteDefaultNamedStyle())
  }

  private func defaultParagraphStyleReadbackSHA256(forRawStyle rawStyle: UInt32) -> String {
    let validatedStyle = ICTextStyle.validatedNamedStyle(rawStyle)
    let description = ICTextStyle.settingsDescription(forNamedStyle: validatedStyle) as? String
    return sha256Hex(
      [
        "ICTextStyle.noteDefaultNamedStyle",
        "\(rawStyle)",
        "\(validatedStyle)",
        description ?? "",
      ].joined(separator: "|")
    )
  }

  private func defaultTextSizeReadbackSHA256() -> String {
    defaultTextSizeReadbackSHA256(forIndex: ICMZoomController.globalZoomFactorIndex())
  }

  private func dateHeadersTypeReadbackSHA256(scope: String, type: Int64) -> String {
    notesDateHeadersTypeSHA256(scope: scope, privateValue: Int(type))
  }

  private func defaultTextSizeReadbackSHA256(forIndex index: Int64) -> String {
    let factor = defaultTextSizeZoomFactor(forIndex: index) ?? ICMZoomController.globalZoomFactor()
    let pointSize = factor * ICMZoomBaseFontPointSize
    return sha256Hex(
      [
        "ICMZoomController.globalZoomFactorIndex",
        "\(index)",
        formattedFontPointSize(pointSize),
        String(format: "%.6f", factor),
      ].joined(separator: "|")
    )
  }

  private func defaultTextSizeZoomIndex(forPointSize pointSize: Double, operation: String) throws -> Int64 {
    let basePointSize = ICMZoomBaseFontPointSize
    guard pointSize.isFinite, pointSize >= 1, pointSize <= 288, basePointSize.isFinite, basePointSize > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes settings text size could not be normalized.",
        details: ["operation": operation]
      )
    }
    let factors = defaultTextSizeZoomFactors()
    guard !factors.isEmpty else {
      throw CLIError(
        code: .internalError,
        message: "Notes settings text size factors were not available.",
        details: ["operation": operation]
      )
    }
    let requestedFactor = pointSize / basePointSize
    let closest = factors.enumerated().min { lhs, rhs in
      abs(lhs.element - requestedFactor) < abs(rhs.element - requestedFactor)
    }
    guard let closest else {
      throw CLIError(
        code: .internalError,
        message: "Notes settings text size could not resolve a private zoom factor.",
        details: ["operation": operation]
      )
    }
    return Int64(closest.offset)
  }

  private func defaultTextSizeZoomFactor(forIndex index: Int64) -> Double? {
    let factors = defaultTextSizeZoomFactors()
    guard index >= 0, Int(index) < factors.count else { return nil }
    return factors[Int(index)]
  }

  private func defaultTextSizeZoomFactors() -> [Double] {
    let rawFactors = ICMZoomController.globalZoomFactors() as? [Any] ?? []
    return rawFactors.compactMap { value in
      if let number = value as? NSNumber { return number.doubleValue }
      return value as? Double
    }
  }

  private func settingsParagraphStyleValue(
    _ style: NotesBodyParagraphStyle,
    operation: String
  ) throws -> UInt32 {
    guard style.isDefaultNewNoteStyle else {
      throw CLIError(
        code: .validationError,
        message: "Notes settings default paragraph style is not accepted for this style.",
        details: [
          "operation": operation,
          "style_sha256": sha256Hex(style.rawValue),
        ]
      )
    }
    guard let textStyle = bodyTextStyle(style) else {
      throw CLIError(
        code: .internalError,
        message: "Notes settings paragraph style could not be resolved.",
        details: [
          "operation": operation,
          "style_sha256": sha256Hex(style.rawValue),
        ]
      )
    }
    return textStyle.ttStyle
  }

  private func settingsNoteListSortType(
    _ draft: NotesSettingsSortMutationDraft,
    operation: String
  ) throws -> Int64 {
    guard let sortObject = ICFolderCustomNoteSortType.folderNoteSortType(
      withOrder: Int64(draft.sortOrder),
      direction: Int64(draft.sortDirection)
    ) as? ICFolderCustomNoteSortType else {
      throw CLIError(
        code: .internalError,
        message: "Notes settings sort type could not be resolved.",
        details: ["operation": operation]
      )
    }
    let sortType = Int64(sortObject.valueRepresentation.intValue)
    let resolvedOrder = ICNoteListSortUtilities.folderSortOrder(forNoteListSortType: sortType)
    guard resolvedOrder == draft.sortOrder else {
      throw CLIError(
        code: .internalError,
        message: "Notes settings sort type did not round-trip through private sort utilities.",
        details: [
          "operation": operation,
          "sort_sha256": sha256Hex("\(draft.by)|\(draft.direction)"),
        ]
      )
    }
    return sortType
  }

  private func accountObject(id: String, name: String) throws -> ICAccount {
    let managedObjectContext = try managedObjectContext()
    let accounts: [ICAccount] = objects(ICAccount.allActiveAccounts(inContext: managedObjectContext))
    if let match = accounts.first(where: { objectIDString($0) == id }) {
      return match
    }

    let matches = accounts.filter {
      (nonEmpty($0.localizedName) ?? nonEmpty($0.name) ?? "Notes")
        .localizedCaseInsensitiveCompare(name) == .orderedSame
    }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Account selector matched multiple Notes accounts.",
        details: ["account_sha256": sha256Hex(name)]
      )
    }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Notes account was not found.",
        details: ["account_sha256": sha256Hex(name)]
      )
    }
    return match
  }

  private func folder(id: String, name: String, accountName: String) throws -> ICFolder {
    let managedObjectContext = try managedObjectContext()
    let folders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
    if let match = folders.first(where: { objectIDString($0) == id }) {
      return match
    }

    let matches = folders.filter {
      folderDisplayName($0).localizedCaseInsensitiveCompare(name) == .orderedSame
        && (nonEmpty($0.accountName) ?? nonEmpty($0.account?.localizedName) ?? "Notes")
          .localizedCaseInsensitiveCompare(accountName) == .orderedSame
    }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Folder selector matched multiple Notes folders.",
        details: ["folder_sha256": sha256Hex(name)]
      )
    }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Notes folder was not found.",
        details: ["folder_id_sha256": sha256Hex(id)]
      )
    }
    return match
  }

  private func moveDecisionSourceObjects(for folder: ICFolder) -> [AnyObject] {
    let selector = NSSelectorFromString("objectsForMakingDecisionForNonSharedFolder:")
    guard let method = class_getClassMethod(ICMoveDecision.self, selector) else {
      return [folder]
    }
    typealias SourceObjectsIMP = @convention(c) (AnyClass, Selector, AnyObject) -> AnyObject?
    let function = unsafeBitCast(method_getImplementation(method), to: SourceObjectsIMP.self)
    guard let value = function(ICMoveDecision.self, selector, folder) else {
      return [folder]
    }
    let objects = anyObjects(value)
    return objects.isEmpty ? [folder] : objects
  }

  private func moveDecisionCount(_ value: Any?) -> Int {
    objectCount(value as AnyObject?) ?? anyObjects(value).count
  }

  private func objectSetSHA256(_ objects: [AnyObject]) -> String {
    sha256Hex(objects.map(objectIDString).sorted().joined(separator: "\n"))
  }

  private func accountObject(selector: String, operation: String) throws -> ICAccount {
    let managedObjectContext = try managedObjectContext()
    let accounts: [ICAccount] = objects(ICAccount.allActiveAccounts(inContext: managedObjectContext))
    let matches = accounts.filter { account in
      matchesAccount(account, accountName: account.localizedName ?? account.name, selector: selector)
    }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Account selector matched multiple Notes accounts.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(selector),
        ]
      )
    }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Notes account was not found.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(selector),
        ]
      )
    }
    return match
  }

  private func notesAuthenticationState() -> NSObject? {
    ICAuthenticationState.sharedState() as? NSObject
  }

  private func touchIDAuthenticationState() -> NSObject? {
    notesAuthenticationState()
  }

  private func authenticationStateBool(
    _ state: NSObject,
    selectorName: String,
    operation: String
  ) throws -> Bool {
    let selector = NSSelectorFromString(selectorName)
    guard let stateClass = object_getClass(state),
      let method = class_getInstanceMethod(stateClass, selector)
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private authentication state readback selector is unavailable.",
        details: [
          "operation": operation,
          "private_selector": selectorName,
        ]
      )
    }
    typealias AuthenticationStateBoolIMP = @convention(c) (AnyObject, Selector) -> Bool
    let function = unsafeBitCast(method_getImplementation(method), to: AuthenticationStateBoolIMP.self)
    return function(state, selector)
  }

  private func callAuthenticationStateVoid(
    _ state: NSObject,
    selectorName: String,
    operation: String
  ) throws {
    let selector = NSSelectorFromString(selectorName)
    guard let stateClass = object_getClass(state),
      let method = class_getInstanceMethod(stateClass, selector)
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private authentication state mutation selector is unavailable.",
        details: [
          "operation": operation,
          "private_selector": selectorName,
        ]
      )
    }
    typealias AuthenticationStateVoidIMP = @convention(c) (AnyObject, Selector) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: AuthenticationStateVoidIMP.self)
    function(state, selector)
  }

  private func touchIDPreferenceEnabled(for account: ICAccount) -> Bool? {
    guard let state = touchIDAuthenticationState() else {
      return nil
    }
    let selector = NSSelectorFromString("biometricsEnabledForAccount:")
    guard let stateClass = object_getClass(state),
      let method = class_getInstanceMethod(stateClass, selector)
    else {
      return nil
    }
    typealias TouchIDPreferenceReadIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Bool
    let function = unsafeBitCast(method_getImplementation(method), to: TouchIDPreferenceReadIMP.self)
    return function(state, selector, account)
  }

  private func touchIDSetPreferenceEnabled(
    _ enabled: Bool,
    for account: ICAccount,
    state: NSObject,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("setBiometricsEnabled:forAccount:")
    guard let stateClass = object_getClass(state),
      let method = class_getInstanceMethod(stateClass, selector)
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private Touch ID preference setter is unavailable.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
        ]
      )
    }
    typealias TouchIDPreferenceWriteIMP = @convention(c) (AnyObject, Selector, Bool, AnyObject) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: TouchIDPreferenceWriteIMP.self)
    function(state, selector, enabled, account)
  }

  private func touchIDPreferenceKeySHA256(for account: ICAccount, state: NSObject) -> String? {
    let selector = NSSelectorFromString("touchIDEnabledKeyForAccountIdentifier:")
    guard let stateClass = object_getClass(state),
      let method = class_getInstanceMethod(stateClass, selector)
    else {
      return nil
    }
    typealias TouchIDPreferenceKeyIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Unmanaged<AnyObject>?
    let function = unsafeBitCast(method_getImplementation(method), to: TouchIDPreferenceKeyIMP.self)
    guard let keyObject = function(state, selector, touchIDAccountIdentifier(account) as NSString)?
      .takeUnretainedValue()
    else {
      return nil
    }
    if let key = keyObject as? String {
      return sha256Hex(key)
    }
    if let key = keyObject as? NSString {
      return sha256Hex(key as String)
    }
    return sha256Hex("\(keyObject)")
  }

  private func touchIDAccountIdentifier(_ account: ICAccount) -> String {
    nonEmpty(optionalString(account, key: "identifier"))
      ?? nonEmpty(optionalString(account, key: "accountIdentifier"))
      ?? objectIDString(account)
  }

  private func accountPassphraseState(_ account: ICAccount) -> (hasPassphraseSet: Bool, stateSHA256: String)? {
    guard let strategy = optionalObject(account, key: "cryptoStrategy"),
      let hasPassphraseSet = optionalBool(strategy, key: "hasPassphraseSet")
    else {
      return nil
    }
    let hint = nonEmpty(optionalString(strategy, key: "passphraseHint"))
    let hintSHA256 = hint.map(sha256Hex)
    return (
      hasPassphraseSet,
      notesLockedNotesPassphraseStateSHA256(
        hasPassphraseSet: hasPassphraseSet,
        hintSHA256: hintSHA256
      )
    )
  }

  private func validateAccountSupportsCustomPassphrase(_ account: ICAccount, operation: String) throws {
    let canPasswordProtect = optionalBool(account, key: "canPasswordProtectNotes") ?? false
    let canHaveCryptoStrategy = optionalBool(account, key: "canHaveCryptoStrategy") ?? false
    guard canPasswordProtect, canHaveCryptoStrategy else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Selected Notes account does not support locked-note custom passwords.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "can_password_protect_notes": canPasswordProtect ? "true" : "false",
          "can_have_crypto_strategy": canHaveCryptoStrategy ? "true" : "false",
        ]
      )
    }
  }

  private func validateAccountSupportsLockedNotesMethod(_ account: ICAccount, operation: String) throws {
    let canPasswordProtect = optionalBool(account, key: "canPasswordProtectNotes") ?? false
    let canHaveCryptoStrategy = optionalBool(account, key: "canHaveCryptoStrategy") ?? false
    guard canPasswordProtect, canHaveCryptoStrategy else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Selected Notes account does not support locked-note password methods.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "can_password_protect_notes": canPasswordProtect ? "true" : "false",
          "can_have_crypto_strategy": canHaveCryptoStrategy ? "true" : "false",
        ]
      )
    }
  }

  private func accountPasswordProtectedNoteCount(_ account: ICAccount) -> Int? {
    objectCount(optionalObject(account, key: "passwordProtectedNotes"))
  }

  private func lockedNotesMethodScope(modeRawValue: Int) -> String {
    switch modeRawValue {
    case 1:
      return "custom"
    case 2:
      return "login-password"
    default:
      return "unknown"
    }
  }

  private func lockedNotesModeMigrator(operation: String) throws -> NSObject {
    let selector = NSSelectorFromString("sharedMigrator")
    guard let method = class_getClassMethod(ICLockedNotesModeMigrator.self, selector) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private locked-notes mode migrator is unavailable.",
        details: [
          "operation": operation,
          "private_selector": "ICLockedNotesModeMigrator.sharedMigrator",
        ]
      )
    }
    typealias SharedMigratorIMP = @convention(c) (AnyClass, Selector) -> Unmanaged<AnyObject>?
    let function = unsafeBitCast(method_getImplementation(method), to: SharedMigratorIMP.self)
    guard let migrator = function(ICLockedNotesModeMigrator.self, selector)?.takeUnretainedValue() as? NSObject else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private locked-notes mode migrator could not be created.",
        details: [
          "operation": operation,
          "private_selector": "ICLockedNotesModeMigrator.sharedMigrator",
        ]
      )
    }
    return migrator
  }

  private func lockedNotesModeSupported(account: ICAccount, mode: Int16, operation: String) throws -> Bool {
    let migrator = try lockedNotesModeMigrator(operation: operation)
    let selector = NSSelectorFromString("account:supportsMode:")
    let migratorClass: AnyClass = object_getClass(migrator) ?? ICLockedNotesModeMigrator.self
    guard let method = class_getInstanceMethod(migratorClass, selector)
      ?? class_getInstanceMethod(ICLockedNotesModeMigrator.self, selector)
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private locked-notes mode support selector is unavailable.",
        details: [
          "operation": operation,
          "private_selector": "ICLockedNotesModeMigrator.account:supportsMode:",
        ]
      )
    }
    typealias SupportsModeIMP = @convention(c) (AnyObject, Selector, AnyObject, Int16) -> Bool
    let function = unsafeBitCast(method_getImplementation(method), to: SupportsModeIMP.self)
    return function(migrator, selector, account, mode)
  }

  private func setResolvedLockedNotesMode(
    _ mode: Int16,
    account: ICAccount,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("setResolvedLockedNotesMode:")
    guard let method = class_getInstanceMethod(ICAccount.self, selector) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private locked-notes mode setter is unavailable.",
        details: [
          "operation": operation,
          "account_sha256": sha256Hex(objectIDString(account)),
          "private_selector": "ICAccount.setResolvedLockedNotesMode:",
        ]
      )
    }
    typealias SetLockedNotesModeIMP = @convention(c) (AnyObject, Selector, Int16) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: SetLockedNotesModeIMP.self)
    function(account, selector, mode)
  }

  private func setPassphrase(
    _ passphrase: String,
    hint: String,
    manager: ICAccountPassphraseManager,
    operation: String,
    reset: Bool
  ) throws -> Bool {
    if reset {
      let selector = NSSelectorFromString("setPassphrase:hint:isReset:")
      guard let method = class_getInstanceMethod(ICAccountPassphraseManager.self, selector) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes private account passphrase reset selector is unavailable.",
          details: [
            "operation": operation,
            "private_selector": "setPassphrase:hint:isReset:",
          ]
        )
      }
      typealias SetPassphraseResetIMP = @convention(c) (AnyObject, Selector, AnyObject, AnyObject, Bool) -> Bool
      let function = unsafeBitCast(method_getImplementation(method), to: SetPassphraseResetIMP.self)
      return function(manager, selector, passphrase as NSString, hint as NSString, true)
    }

    let selector = NSSelectorFromString("setPassphrase:hint:")
    guard let method = class_getInstanceMethod(ICAccountPassphraseManager.self, selector) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private account passphrase setter is unavailable.",
        details: [
          "operation": operation,
          "private_selector": "setPassphrase:hint:",
        ]
      )
    }
    typealias SetPassphraseIMP = @convention(c) (AnyObject, Selector, AnyObject, AnyObject) -> Bool
    let function = unsafeBitCast(method_getImplementation(method), to: SetPassphraseIMP.self)
    return function(manager, selector, passphrase as NSString, hint as NSString)
  }

  private func changePassphrase(
    from oldPassphrase: String,
    to newPassphrase: String,
    hint: String,
    manager: ICAccountPassphraseManager,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("changePassphrase:toPassphrase:hint:completion:")
    guard let method = class_getInstanceMethod(ICAccountPassphraseManager.self, selector) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private account passphrase change selector is unavailable.",
        details: [
          "operation": operation,
          "private_selector": "changePassphrase:toPassphrase:hint:completion:",
        ]
      )
    }

    let semaphore = DispatchSemaphore(value: 0)
    let completion = NotesPassphraseChangeCompletion()
    let block: @convention(block) () -> Void = {
      completion.complete()
      semaphore.signal()
    }
    typealias ChangePassphraseIMP = @convention(c) (
      AnyObject, Selector, AnyObject, AnyObject, AnyObject, AnyObject
    ) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: ChangePassphraseIMP.self)
    function(
      manager,
      selector,
      oldPassphrase as NSString,
      newPassphrase as NSString,
      hint as NSString,
      unsafeBitCast(block, to: AnyObject.self)
    )
    guard semaphore.wait(timeout: .now() + .seconds(15)) == .success, completion.completed else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private account passphrase change did not complete before the verifier timeout.",
        details: [
          "operation": operation,
          "private_selector": "changePassphrase:toPassphrase:hint:completion:",
        ]
      )
    }
  }

  private func settingsFamily(
    in evidence: NotesSettingsReadEvidence,
    id: String
  ) -> NotesSettingsFamilyRecord? {
    evidence.families.first { $0.id == id }
  }

  func listFolders(account selector: String?, limit: Int) throws -> [NotesFolderRecord] {
    let managedObjectContext = try managedObjectContext()
    let seedFolders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
    let folders = completeVisibleFolders(from: seedFolders)
    let records = folders
      .filter { folder in matchesAccount(folder.account, accountName: folder.accountName, selector: selector) }
      .map { folderRecord($0) }
    return hierarchicalFolderRecords(records).prefixCount(limit)
  }

  func listPurgableFolders(account selector: String?, limit: Int) throws -> [NotesFolderRecord] {
    let managedObjectContext = try managedObjectContext()
    let folders = try purgableFolders(in: managedObjectContext)
    return folders
      .filter { folder in matchesAccount(folder.account, accountName: folder.accountName, selector: selector) }
      .map { folderRecord($0, isPurgable: true) }
      .sorted {
        if $0.accountName == $1.accountName {
          return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        return $0.accountName.localizedStandardCompare($1.accountName) == .orderedAscending
      }
      .prefixCount(limit)
  }

  func readFolderMoveImpact(_ draft: NotesFolderMoveDraft) throws -> NotesFolderMoveImpactRecord {
    let sourceFolder = try folder(id: draft.folderID, name: draft.name, accountName: draft.sourceAccountName)
    let destination: AnyObject
    let destinationKind: String
    let destinationID: String
    if let parentID = draft.parentID {
      let parentFolder = try folder(id: parentID, name: draft.parentName ?? "", accountName: draft.accountName)
      destination = parentFolder
      destinationKind = "folder"
      destinationID = objectIDString(parentFolder)
    } else {
      let account = try accountObject(id: draft.accountID ?? "", name: draft.accountName)
      destination = account
      destinationKind = "account"
      destinationID = objectIDString(account)
    }

    let sourceObjects = moveDecisionSourceObjects(for: sourceFolder)
    guard let decision = ICMoveDecision(sourceObjects: sourceObjects as NSArray, destination: destination) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private move decision was unavailable.",
        details: [
          "capability": "folder_move_impact",
          "required_module": "NotesUI.ICMoveDecision",
          "folder_id_sha256": sha256Hex(draft.folderID),
        ]
      )
    }

    let sharedCount = moveDecisionCount(decision.sharedObjectsInSource)
    let sharedNotDestinationFolderCount = moveDecisionCount(decision.sharedObjectsNotFromDestinationFolderInSource)
    let ownedSharedRootCount = moveDecisionCount(decision.ownedSharedRootObjectsInSource)
    let joinedSharedRootCount = moveDecisionCount(decision.joinedSharedRootObjectsInSource)
    let readWriteSharedSubCount = moveDecisionCount(decision.readWriteSharedSubObjectsInSource)
    let readOnlySharedSubCount = moveDecisionCount(decision.readOnlySharedSubObjectsInSource)
    let privateAttachmentCount = moveDecisionCount(decision.privateModernNoteWithAttachmentsInSource)
    let unsupportedCount = moveDecisionCount(decision.unsupportedObjectsInSource)
    let lockedCount = moveDecisionCount(decision.lockedObjectsInSource)
    let guiltyObjects = anyObjects(decision.guiltyObjects)
    let crossAccountMove = draft.sourceAccountName.localizedCaseInsensitiveCompare(draft.accountName) != .orderedSame
    let requiresSharedReview = decision.hasSharedObjectsNotFromDestinationAccountInSource
      || sharedCount > 0
      || sharedNotDestinationFolderCount > 0
      || ownedSharedRootCount > 0
      || joinedSharedRootCount > 0
      || readWriteSharedSubCount > 0
      || readOnlySharedSubCount > 0
    let requiresFidelityReview = crossAccountMove
      || decision.hasLockedNotesNotFromDestinationAccountInSource
      || privateAttachmentCount > 0
      || unsupportedCount > 0

    return NotesFolderMoveImpactRecord(
      sourceFolderIDSHA256: sha256Hex(objectIDString(sourceFolder)),
      sourceAccountSHA256: sha256Hex(draft.sourceAccountName),
      destinationKind: destinationKind,
      destinationIDSHA256: sha256Hex(destinationID),
      destinationAccountSHA256: sha256Hex(draft.accountName),
      crossAccountMove: crossAccountMove,
      decisionType: UInt64(decision.type),
      additionalStep: UInt64(decision.additionalStep),
      decisionTypeStringSHA256: nonEmpty(string(decision.typeString())).map(sha256Hex),
      shouldMove: decision.shouldMove,
      shouldProceed: decision.shouldProceed,
      shouldContinueDecisionMaking: decision.shouldContinueDecisionMaking,
      modernSourceObjectCount: moveDecisionCount(decision.modernSourceObjects),
      htmlSourceObjectCount: moveDecisionCount(decision.htmlSourceObjects),
      modernFolderCount: moveDecisionCount(decision.modernFoldersInSource),
      accountCountOfModernSourceObjects: moveDecisionCount(decision.accountsOfModernSourceObjects),
      accountCountOfHTMLSourceObjects: moveDecisionCount(decision.accountsOfHTMLSourceObjects),
      ownedSharedRootObjectCount: ownedSharedRootCount,
      joinedSharedRootObjectCount: joinedSharedRootCount,
      readWriteSharedSubObjectCount: readWriteSharedSubCount,
      readOnlySharedSubObjectCount: readOnlySharedSubCount,
      sharedObjectCount: sharedCount,
      sharedObjectNotFromDestinationFolderCount: sharedNotDestinationFolderCount,
      hasSharedObjectsNotFromDestinationAccount: decision.hasSharedObjectsNotFromDestinationAccountInSource,
      lockedObjectCount: lockedCount,
      hasLockedObjects: decision.hasLockedObjects,
      hasLockedNotesNotFromDestinationAccount: decision.hasLockedNotesNotFromDestinationAccountInSource,
      unsupportedObjectCount: unsupportedCount,
      privateModernNoteWithAttachmentsCount: privateAttachmentCount,
      systemPaperNoteCount: moveDecisionCount(decision.systemPaperNotesInSource),
      mathNoteCount: moveDecisionCount(decision.mathNotesNotesInSource),
      callNoteCount: moveDecisionCount(decision.callNotesInSource),
      guiltyObjectCount: guiltyObjects.count,
      sourceObjectSetSHA256: objectSetSHA256(sourceObjects),
      guiltyObjectSetSHA256: guiltyObjects.isEmpty ? nil : objectSetSHA256(guiltyObjects),
      requiresSharedPermissionReview: requiresSharedReview,
      requiresCrossAccountFidelityReview: requiresFidelityReview,
      privacyBoundary: "hashes_counts_booleans_without_names_participants_note_bodies_or_object_uris",
      sourceKind: "ICMoveDecision.initWithSourceObjects:destination:",
      backendCalls: [
        "ICMoveDecision.objectsForMakingDecisionForNonSharedFolder",
        "ICMoveDecision.initWithSourceObjects:destination:",
      ]
    )
  }

  func listNotes(folder selector: String?, limit: Int) throws -> [NotesNoteSummary] {
    let notes = try visibleNotes()
    return notes
      .filter { matchesFolder($0, selector: selector) }
      .map(noteSummary)
      .sorted(by: compareNotes)
      .prefixCount(limit)
  }

  func listNotes(account accountSelector: String?, folder folderSelector: String?, limit: Int) throws -> [NotesNoteSummary] {
    let notes = try visibleNotes()
    return notes
      .filter { note in
        matchesAccount(note.account, accountName: note.accountName, selector: accountSelector)
          && matchesFolder(note, selector: folderSelector)
      }
      .map(noteSummary)
      .sorted(by: compareNotes)
      .prefixCount(limit)
  }

  func searchNotes(query: String, folder selector: String?, limit: Int) throws -> [NotesNoteSummary] {
    let normalizedQuery = query.localizedLowercase
    let notes = try visibleNotes()
    return notes
      .filter { note in
        matchesFolder(note, selector: selector)
          && noteSearchTextMatches(note, normalizedQuery: normalizedQuery)
      }
      .map(noteSummary)
      .sorted(by: compareNotes)
      .prefixCount(limit)
  }

  func searchNotes(
    query: String,
    account accountSelector: String?,
    folder folderSelector: String?,
    limit: Int
  ) throws -> [NotesNoteSummary] {
    let normalizedQuery = query.localizedLowercase
    let notes = try visibleNotes()
    return notes
      .filter { note in
        matchesAccount(note.account, accountName: note.accountName, selector: accountSelector)
          && matchesFolder(note, selector: folderSelector)
          && noteSearchTextMatches(note, normalizedQuery: normalizedQuery)
      }
      .map(noteSummary)
      .sorted(by: compareNotes)
      .prefixCount(limit)
  }

  func searchNaturalLanguageNotes(
    query: String,
    account accountSelector: String?,
    folder folderSelector: String?,
    limit: Int
  ) throws -> NotesNaturalLanguageSearchEvidence {
    let boundedLimit = max(1, limit)
    guard let operation = ICSearchQueryOperation(
      searchSuggestionsResponder: nil,
      searchString: query,
      performNLSearch: true,
      tokens: nil,
      modernResultsOnly: true
    ) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes natural-language search operation could not be created.",
        details: [
          "operation": "notes.search.natural-language",
          "query_sha256": sha256Hex(query),
        ]
      )
    }
    operation.main()
    if let error = operation.error {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes natural-language search failed in the private search operation.",
        details: [
          "operation": "notes.search.natural-language",
          "query_sha256": sha256Hex(query),
          "error_sha256": sha256Hex(error.localizedDescription),
        ]
      )
    }

    let results = naturalLanguageSearchResultObjects(operation.results)
    let notesBySearchIdentifier = try naturalLanguageSearchNoteIndex(visibleNotes())
    var returnedNotes: [NotesNoteSummary] = []
    var returnedIDs = Set<String>()

    for result in results {
      guard let identifier = naturalLanguageSearchResultIdentifier(result),
        let note = notesBySearchIdentifier[identifier],
        matchesAccount(note.account, accountName: note.accountName, selector: accountSelector),
        matchesFolder(note, selector: folderSelector)
      else {
        continue
      }
      let noteID = noteIdentifier(note)
      guard returnedIDs.insert(noteID).inserted else {
        continue
      }
      returnedNotes.append(noteSummary(note))
      if returnedNotes.count >= boundedLimit {
        break
      }
    }

    return NotesNaturalLanguageSearchEvidence(
      notes: returnedNotes,
      querySHA256: sha256Hex(query),
      queryByteCount: Data(query.utf8).count,
      rawResultCount: results.count,
      mappedNoteCount: returnedNotes.count,
      skippedResultCount: max(0, results.count - returnedNotes.count),
      limit: boundedLimit,
      privateNLQueryClassName: operation.nlQuery.map { String(describing: type(of: $0)) },
      privateNLQueryPresent: operation.nlQuery != nil,
      sourceKind: "ICSearchQueryOperation.performNLSearch"
    )
  }

  func readNote(id: String) throws -> NotesNoteDetail? {
    try frameworkNote(id: id).map(noteDetail)
  }

  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    guard let note = try frameworkNote(id: id, includeDeleted: true),
      optionalBool(note, key: "isDeletedOrInTrash") == true
    else {
      return nil
    }
    return noteDetail(note)
  }

  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    let managedObjectContext = try managedObjectContext()
    let notes: [ICNote] = objects(ICNote.allNotes(inContext: managedObjectContext))
    return notes
      .filter { optionalBool($0, key: "isDeletedOrInTrash") == true }
      .map(noteDetail)
      .sorted(by: compareNoteDetails)
      .prefixCount(limit)
  }

  func readNotesByTitle(_ title: String, folder selector: String?, limit: Int) throws
    -> [NotesNoteDetail]
  {
    try visibleNotes()
      .filter { note in
        matchesFolder(note, selector: selector)
          && string(note.title).localizedCaseInsensitiveCompare(title) == .orderedSame
      }
      .map(noteDetail)
      .sorted(by: compareNoteDetails)
      .prefixCount(limit)
  }

  func listTags(account selector: String?, limit: Int) throws -> [NotesTagRecord] {
    let managedObjectContext = try managedObjectContext()
    let hashtags: [ICHashtag] = objects(ICHashtag.allVisibleHashtags(inContext: managedObjectContext))
    return hashtags
      .filter { matchesAccount($0.account, accountName: nil, selector: selector) }
      .map(tagRecord)
      .sorted {
        if $0.accountName == $1.accountName {
          return $0.displayText.localizedStandardCompare($1.displayText) == .orderedAscending
        }
        return $0.accountName.localizedStandardCompare($1.accountName) == .orderedAscending
      }
      .prefixCount(limit)
  }

  func readNotes(tag: String, limit: Int) throws -> [NotesNoteDetail] {
    let managedObjectContext = try managedObjectContext()
    let notes: [ICNote] = objects(
      ICNote.notesContainingHashtag(
        withStandarizedContent: standardizedTagContent(tag),
        context: managedObjectContext
      ))
    return notes
      .filter { optionalBool($0, key: "isDeletedOrInTrash") != true }
      .map(noteDetail)
      .sorted(by: compareNoteDetails)
      .prefixCount(limit)
  }

  func listSmartFolders(account selector: String?, limit: Int) throws -> [NotesSmartFolderRecord] {
    let managedObjectContext = try managedObjectContext()
    let folders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
    return folders
      .filter { folder in
        optionalBool(folder, key: "isSmartFolder") == true
          && matchesAccount(folder.account, accountName: folder.accountName, selector: selector)
      }
      .map(smartFolderRecord)
      .sorted {
        if $0.accountName == $1.accountName {
          return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        return $0.accountName.localizedStandardCompare($1.accountName) == .orderedAscending
      }
      .prefixCount(limit)
  }

  func listSmartFolderNotes(smartFolderID: String, limit: Int) throws -> [NotesNoteSummary] {
    let folder = try smartFolder(id: smartFolderID)
    let notes: [ICNote] = {
      let visibleNotesInFolder: [ICNote] = objects(optionalObject(folder, key: "visibleNotesInFolder"))
      if !visibleNotesInFolder.isEmpty {
        return visibleNotesInFolder
      }
      return objects(optionalObject(folder, key: "visibleNotes"))
    }()

    return notes
      .filter { optionalBool($0, key: "isDeletedOrInTrash") != true }
      .map(noteSummary)
      .sorted(by: compareNotes)
      .prefixCount(limit)
  }

  func exportSmartFolderCriteria(smartFolderID: String) throws -> NotesSmartFolderCriteriaExportSource {
    let folder = try smartFolder(id: smartFolderID)
    guard let queryJSON = nonEmpty(folder.smartFolderQueryJSON) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Smart Folder raw criteria JSON is unavailable.",
        details: ["smart_folder_id_sha256": sha256Hex(smartFolderID)]
      )
    }
    return NotesSmartFolderCriteriaExportSource(
      smartFolder: smartFolderRecord(folder),
      data: Data(queryJSON.utf8)
    )
  }

  func listAttachments(noteID id: String, limit: Int) throws -> [NotesAttachmentRecord] {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    return attachmentObjects(note)
      .map(attachmentRecord)
      .prefixCount(limit)
  }

  func exportAttachment(noteID id: String, attachmentID: String) throws -> NotesAttachmentExportSource {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    let data = try attachmentData(attachment, record: record)
    return NotesAttachmentExportSource(noteID: id, attachment: record, data: data)
  }

  func exportAttachmentPDF(noteID id: String, attachmentID: String) throws -> NotesAttachmentPDFExportSource {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    let pdf = try attachmentPDFData(attachment, record: record)
    return NotesAttachmentPDFExportSource(
      noteID: id,
      attachment: record,
      data: pdf.data,
      sourceKind: pdf.sourceKind
    )
  }

  func inspectAttachmentScanPDF(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentScanPDFInspectionSource
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    let pdf = try? attachmentPDFData(attachment, record: record)
    let croppingQuad = optionalObject(attachment, key: "croppingQuad")
    let scannedDocumentsMetadata = optionalObject(attachment, key: "scannedDocumentsMetadata")
    let docCamPDFVersion = optionalInt(attachment, key: "docCamPDFVersion")
    let orientation = optionalInt(attachment, key: "orientation")
    let imageFilterType = optionalInt(attachment, key: "imageFilterType")
    let sourceKinds = scanPDFInspectionSourceKinds(
      pdfSourceKind: pdf?.sourceKind,
      croppingQuad: croppingQuad,
      scannedDocumentsMetadata: scannedDocumentsMetadata,
      docCamPDFVersion: docCamPDFVersion,
      orientation: orientation,
      imageFilterType: imageFilterType
    )
    return NotesAttachmentScanPDFInspectionSource(
      noteID: id,
      attachment: record,
      pdfDataByteCount: pdf?.data.count,
      pdfDataSHA256: pdf.map { sha256Hex($0.data) },
      pdfPageCount: pdf.flatMap { pdfPageCount($0.data) },
      pdfSourceKind: pdf?.sourceKind,
      croppingQuadPresent: croppingQuad != nil,
      croppingQuadSHA256: metadataDigest(croppingQuad),
      scannedDocumentsMetadataPresent: scannedDocumentsMetadata != nil,
      scannedDocumentsMetadataCount: metadataObjectCount(scannedDocumentsMetadata),
      scannedDocumentsMetadataSHA256: metadataDigest(scannedDocumentsMetadata),
      docCamPDFVersion: docCamPDFVersion,
      orientation: orientation,
      orientationSHA256: orientation.map { sha256Hex("\($0)") },
      imageFilterType: imageFilterType,
      imageFilterTypeSHA256: imageFilterType.map { sha256Hex("\($0)") },
      sourceKinds: sourceKinds
    )
  }

  func inspectAttachmentMarkup(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentMarkupInspectionSource
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    let data = try attachmentData(attachment, record: record)
    return NotesAttachmentMarkupInspectionSource(
      noteID: id,
      attachment: record,
      attachmentDataByteCount: data.count,
      attachmentDataSHA256: sha256Hex(data),
      markupModelData: try markupModelData(from: data, record: record),
      sourceKind: "ICMarkupUtilities.markupModelDataFromData"
    )
  }

  func readAttachmentImageDescription(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageDescriptionSource
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedImageDescriptionAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    guard record.isInline else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description read requires an inline attachment with private alt-text metadata.",
        details: [
          "id_sha256": sha256Hex(id),
          "attachment_sha256": sha256Hex(attachmentID),
          "attachment_id_sha256": sha256Hex(record.id),
        ]
      )
    }
    return NotesAttachmentImageDescriptionSource(
      noteID: id,
      attachment: record,
      descriptionText: nonEmpty(optionalString(attachment, key: "altText")),
      sourceKind: "ICInlineAttachment.altText"
    )
  }

  func readAttachmentImageObjects(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageObjectSource
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    let classificationSummary = normalizedImageClassificationSummary(
      optionalString(attachment, key: "imageClassificationSummary")
    )
    return NotesAttachmentImageObjectSource(
      noteID: id,
      attachment: imageClassificationAttachmentRecord(
        record,
        summary: classificationSummary,
        version: optionalInt(attachment, key: "imageClassificationSummaryVersion")
      ),
      classificationSummaryText: classificationSummary,
      classificationSummaryVersion: optionalInt(attachment, key: "imageClassificationSummaryVersion"),
      sourceKind: "ICAttachment.imageClassificationSummary",
      backendCalls: [
        "ICAttachment.imageClassificationSummary",
        "ICAttachment.imageClassificationSummaryVersion",
      ]
    )
  }

  func readAttachmentAudioTranscript(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentAudioTranscriptSource
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    guard let audioDocument = attachmentAudioDocument(attachment) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment does not expose an audio transcript document through Notes private APIs.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "type_uti": record.typeUTI ?? "",
          "media_filename": record.mediaFilename ?? "",
          "attempted_paths": "ICAttachment.audioModel.audioDocument,ICAttachment.attachmentModel.audioDocument,ICAttachment.audioDocument",
        ]
      )
    }
    return NotesAttachmentAudioTranscriptSource(
      noteID: id,
      attachment: record,
      transcriptText: nonEmpty(optionalString(audioDocument.document, key: "transcriptAsPlainText")),
      recordingSummaryText: nonEmpty(optionalString(audioDocument.document, key: "recordingSummaryAsPlainText")),
      topLineSummaryText: nonEmpty(optionalString(audioDocument.document, key: "topLineSummaryAsPlainText")),
      transcriptVersion: optionalInt(audioDocument.document, key: "transcriptVersion"),
      sourceKind: audioDocument.sourceKind
    )
  }

  func readAttachmentSearchableText(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentSearchableTextSource
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: id,
      selector: attachmentID
    )
    let content = attachmentSearchableTextContent(attachment)
    guard !content.isEmpty else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment does not expose searchable text through Notes private APIs.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "type_uti": record.typeUTI ?? "",
          "media_filename": record.mediaFilename ?? "",
          "attempted_paths": attachmentSearchableTextAttemptedPaths,
        ]
      )
    }
    return NotesAttachmentSearchableTextSource(noteID: id, attachment: record, content: content)
  }

  func reindexAttachmentSearchableText(_ draft: NotesAttachmentSearchIndexDraft) throws
    -> NotesAttachmentSearchIndexWriteResult
  {
    guard let note = try frameworkNote(id: draft.noteID) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": draft.noteID])
    }

    let (attachment, record) = try selectedAttachment(
      in: note,
      noteID: draft.noteID,
      selector: draft.attachmentID
    )
    guard record.id == draft.attachment.id else {
      throw CLIError(
        code: .validationError,
        message: "Attachment search index target changed before private-framework execution.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "expected_attachment_id_sha256": sha256Hex(draft.attachment.id),
        ]
      )
    }
    guard let objectIDURI = objectIDURI(attachment) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment does not expose a Core Data object URI for Notes search indexing.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "type_uti": record.typeUTI ?? "",
        ]
      )
    }
    guard let reindexer = ICCDCSIReindexer.sharedReindexer() as? ICCDCSIReindexer else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes CoreSpotlight reindexer is unavailable.",
        details: ["required_class": "ICCDCSIReindexer"]
      )
    }

    let semaphore = DispatchSemaphore(value: 0)
    let completion: @convention(block) () -> Void = {
      semaphore.signal()
    }
    reindexer.reindexSearchableItems(withObjectIDURIs: [objectIDURI], completionHandler: completion)
    let completed = semaphore.wait(timeout: .now() + 10) == .success
    guard completed else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes CoreSpotlight attachment reindexing did not complete before the verifier timeout.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "object_id_uri_sha256": sha256Hex(objectIDURI.absoluteString),
        ]
      )
    }

    let implementationCall = "ICCDCSIReindexer.reindexSearchableItemsWithObjectIDURIs"
    return NotesAttachmentSearchIndexWriteResult(
      noteID: draft.noteID,
      attachment: record,
      attachmentFamily: draft.attachmentFamily,
      objectIDURISHA256: sha256Hex(objectIDURI.absoluteString),
      backendCalls: [implementationCall],
      completionStatus: "completed",
      sourceKind: implementationCall
    )
  }

  func listLinks(noteID id: String, limit: Int) throws -> [NotesLinkRecord] {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    return linkObjects(note)
      .map(linkRecord)
      .prefixCount(limit)
  }

  func listBacklinks(noteID id: String, limit: Int) throws -> [NotesBacklinkRecord] {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    var links: [AnyObject] = []
    let block: @convention(block) (Any?) -> Void = { value in
      links.append(contentsOf: backlinkLinkObjects(from: value))
    }

    ICInlineAttachment.enumerateLinks(
      toNote: note,
      batchSize: UInt64(max(limit, 1)),
      visibleOnly: true,
      saveAfterBatch: false,
      context: note.managedObjectContext,
      usingBlock: block
    )

    return links
      .filter(isLinkObject)
      .compactMap(backlinkRecord)
      .sorted(by: compareBacklinks)
      .prefixCount(limit)
  }

  func resolveLink(noteID id: String, linkID: String) throws -> NotesLinkResolutionRecord {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let matches = linkObjects(note)
      .map { object in (object, linkRecord(object)) }
      .filter { linkRecordMatches($0.1, selector: linkID) }
    guard !matches.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "Link was not found.",
        details: ["link_sha256": sha256Hex(linkID)]
      )
    }
    guard matches.count == 1, let match = matches.first else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links.",
        details: ["link_sha256": sha256Hex(linkID), "match_count": "\(matches.count)"]
      )
    }

    return NotesLinkResolutionRecord(
      noteID: noteIdentifier(note),
      requestedLinkID: linkID,
      link: match.1,
      destination: linkDestinationRecord(match.0, record: match.1)
    )
  }

  func readBodyStructure(noteID id: String) throws -> NotesBodyStructureRecord {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    return bodyStructureRecord(note)
  }

  func listTables(noteID id: String) throws -> [NotesBodyTableRecord] {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard !note.isPasswordProtected else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes table metadata is not exposed.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    return bodyTableRecords(note)
  }

  func listMathResults(noteID id: String) throws -> [NotesBodyMathResultRecord] {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard !note.isPasswordProtected else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes math result metadata is not exposed.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    return bodyMathResultRecords(note)
  }

  func readMathResultsPreference(noteID id: String) throws -> NotesBodyMathResultsPreferenceRecord {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard !note.isPasswordProtected else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes math preference metadata is not exposed.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    return bodyMathResultsPreferenceRecord(note)
  }

  func scanMathExpression(_ draft: NotesBodyMathExpressionScanDraft) throws
    -> NotesBodyMathExpressionScanRecord
  {
    let range = NSRange(location: 0, length: draft.expressionUTF16Length)
    guard let scanner = ICCalculateStringScanner(textStorage: nil) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private calculate string scanner was unavailable.",
        details: [
          "capability": "body_math_expression_scan",
          "required_module": "NotesUI.ICCalculateStringScanner",
        ]
      )
    }
    let scanObject = scanner.scanStringforRange(range, previewedExpressionString: draft.expression)
    let scanObjectReference = scanObject as AnyObject?
    let typeSHA256 = scanObjectReference.map { sha256Hex(objectTypeName($0)) }
    return NotesBodyMathExpressionScanRecord(
      expressionByteCount: draft.expressionByteCount,
      expressionSHA256: draft.expressionSHA256,
      expressionUTF16Length: draft.expressionUTF16Length,
      scanRangeLocation: range.location,
      scanRangeLength: range.length,
      recognized: scanObjectReference != nil,
      scanObjectCount: objectCount(scanObjectReference),
      scanObjectTypeSHA256: typeSHA256,
      sourceKind: "ICCalculateStringScanner.scanStringforRange",
      backendCalls: ["ICCalculateStringScanner.scanStringforRange"]
    )
  }

  func readTableCell(noteID id: String, tableOrdinal: Int, row: Int, column: Int) throws
    -> NotesBodyTableCellRecord
  {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard !note.isPasswordProtected else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes table cell metadata is not exposed.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    let target = try bodyTableTarget(
      note,
      ordinal: tableOrdinal,
      operation: "notes.body.table.cell.read"
    )
    try validateTableCellCoordinate(
      target.record,
      row: row,
      column: column,
      operation: "notes.body.table.cell.read"
    )
    let text = try tableCellString(
      target.table,
      row: row,
      column: column,
      operation: "notes.body.table.cell.read"
    )
    let formatSummary = tableCellFormatSummary(
      tableCellAttributedString(
        target.table,
        row: row,
        column: column,
        operation: "notes.body.table.cell.read"
      ))
    return NotesBodyTableCellRecord(
      tableOrdinal: target.record.ordinal,
      tableIDSHA256: target.record.idSHA256,
      row: row,
      column: column,
      textByteCount: text.utf8.count,
      textSHA256: sha256Hex(text),
      formatRunCount: formatSummary?.formatRunCount,
      formatSHA256: formatSummary?.formatSHA256,
      containsBold: formatSummary?.containsBold,
      containsItalic: formatSummary?.containsItalic,
      containsUnderline: formatSummary?.containsUnderline,
      containsStrikethrough: formatSummary?.containsStrikethrough
    )
  }

  func listCollapsibleSections(noteID id: String) throws -> [NotesBodyCollapsibleSectionRecord] {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard !note.isPasswordProtected else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes collapsible section state is not exposed.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    return collapsibleSections(note: note, paragraphs: paragraphAnchorResolutions(note))
  }

  func resolveParagraphAnchor(noteID id: String, paragraphIDSHA256: String) throws -> NotesParagraphAnchorResolution {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard !note.isPasswordProtected else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes paragraph anchors are not exposed.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    let matches = paragraphAnchorResolutions(note)
      .filter { $0.anchor.idSHA256 == paragraphIDSHA256 }
    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Paragraph anchor hash did not match any paragraph on the target note.",
        details: [
          "id_sha256": sha256Hex(id),
          "paragraph_sha256": paragraphIDSHA256,
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Paragraph anchor hash matched multiple paragraphs on the target note.",
        details: [
          "id_sha256": sha256Hex(id),
          "paragraph_sha256": paragraphIDSHA256,
          "match_count": "\(matches.count)",
        ]
      )
    }
    return match
  }

  func readNoteState(noteID id: String) throws -> NotesNoteStateRecord {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    return noteStateRecord(note)
  }

  func setSharedNoteAlertsHidden(_ draft: NotesSharedNoteAlertsMutationDraft) throws
    -> NotesSharedNoteAlertsWriteResult
  {
    guard let note = try frameworkNote(id: draft.noteID) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id_sha256": sha256Hex(draft.noteID)])
    }
    let state = noteStateRecord(note)
    let participantCount = state.participantCount ?? 0
    let wasShared = state.isSharedViaICloud || state.isSharedViaICloudFolder || participantCount > 0
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes shared-note Hide Alerts requires a shared note.",
        details: [
          "operation": "notes.state.hide-alerts",
          "capability": "shared_note_notification_preference",
          "required_state": "shared_note",
          "note_id_sha256": sha256Hex(draft.noteID),
          "backend_calls": "private_framework_state_readback_only",
        ]
      )
    }
    guard let recordID = optionalObject(note, key: "recordID") else {
      throw CLIError(
        code: .validationError,
        message: "Notes shared-note Hide Alerts requires private CloudKit record identity readback.",
        details: [
          "operation": "notes.state.hide-alerts",
          "capability": "shared_note_notification_preference",
          "required_private_field": "recordID",
          "note_id_sha256": sha256Hex(draft.noteID),
          "backend_calls": "private_framework_state_readback_only",
        ]
      )
    }
    let recordIDSHA256 = sha256Hex(String(describing: recordID))
    let before = ICShareNotifier.shouldPreventNotifications(forRecordID: recordID)
    if before != draft.hidden {
      ICShareNotifier.setShouldPreventNotifications(draft.hidden, forRecordID: recordID)
    }
    let after = ICShareNotifier.shouldPreventNotifications(forRecordID: recordID)
    return NotesSharedNoteAlertsWriteResult(
      noteID: state.noteID,
      requestedHidden: draft.hidden,
      beforeHidden: before,
      afterHidden: after,
      recordIDSHA256: recordIDSHA256,
      wasShared: wasShared,
      participantCount: participantCount
    )
  }

  func closeLockedSession(_ draft: NotesLockedSessionCloseDraft) throws
    -> NotesLockedSessionCloseWriteResult
  {
    let operation = "notes.state.close-locked"
    var accountSHA256: String?
    if let account = draft.account {
      let accountObject = try accountObject(selector: account, operation: operation)
      accountSHA256 = sha256Hex(objectIDString(accountObject))
    }
    guard let state = notesAuthenticationState() else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private authentication state is unavailable.",
        details: [
          "operation": operation,
          "account_selector_sha256": draft.account.map(sha256Hex) ?? "",
        ]
      )
    }

    let beforeAuthenticated = try authenticationStateBool(
      state,
      selectorName: "isAuthenticated",
      operation: operation
    )
    let beforeHasAuthenticatedObject = try authenticationStateBool(
      state,
      selectorName: "hasAuthenticatedObject",
      operation: operation
    )
    try callAuthenticationStateVoid(
      state,
      selectorName: "deauthenticateAllObjects",
      operation: operation
    )
    let afterAuthenticated = try authenticationStateBool(
      state,
      selectorName: "isAuthenticated",
      operation: operation
    )
    let afterHasAuthenticatedObject = try authenticationStateBool(
      state,
      selectorName: "hasAuthenticatedObject",
      operation: operation
    )

    return NotesLockedSessionCloseWriteResult(
      accountSelectorSHA256: draft.account.map(sha256Hex),
      accountSHA256: accountSHA256,
      scope: draft.account == nil
        ? "all_authenticated_locked_objects"
        : "all_authenticated_locked_objects_after_account_preflight",
      beforeAuthenticated: beforeAuthenticated,
      beforeHasAuthenticatedObject: beforeHasAuthenticatedObject,
      afterAuthenticated: afterAuthenticated,
      afterHasAuthenticatedObject: afterHasAuthenticatedObject,
      backendCalls: "ICAuthenticationState.deauthenticateAllObjects"
    )
  }

  func setNoteLockState(_ draft: NotesNoteLockMutationDraft) throws
    -> NotesNoteLockMutationWriteResult
  {
    try NotesWriter().setNoteLockState(draft)
  }

  func unlockNote(_ draft: NotesNoteUnlockDraft) throws -> NotesNoteUnlockWriteResult {
    try NotesWriter().unlockNote(draft)
  }

  func readCollaborationLink(_ draft: NotesCollaborationLinkDraft) throws
    -> NotesCollaborationLinkReadResult
  {
    if let noteID = draft.noteID {
      guard let note = try frameworkNote(id: noteID) else {
        throw CLIError(code: .notFound, message: "Note was not found.", details: ["id_sha256": sha256Hex(noteID)])
      }
      let state = noteStateRecord(note)
      let wasShared = state.isSharedViaICloud || state.isSharedViaICloudFolder || (state.participantCount ?? 0) > 0
      return try collaborationLinkResult(
        targetKind: "note",
        targetID: state.noteID,
        object: note,
        wasShared: wasShared,
        participantCount: state.participantCount,
        selectorHash: sha256Hex(noteID)
      )
    }

    if let folderID = draft.folderID {
      guard let folder = try frameworkFolder(id: folderID) else {
        throw CLIError(
          code: .notFound,
          message: "Folder was not found.",
          details: ["folder_id_sha256": sha256Hex(folderID)]
        )
      }
      let wasShared = optionalBool(folder, key: "isSharedViaICloud") == true
        || optionalBool(folder, key: "isSharedReadOnly") == true
      let share = collaborationShareObject(for: folder)
      let participantCount = share.flatMap(collaborationShareParticipantCount(_:))
      return try collaborationLinkResult(
        targetKind: "folder",
        targetID: objectIDString(folder),
        object: folder,
        wasShared: wasShared || (participantCount ?? 0) > 0,
        participantCount: participantCount,
        selectorHash: sha256Hex(folderID)
      )
    }

    throw CLIError(
      code: .validationError,
      message: "Notes collaboration link copy requires exactly one note or folder selector.",
      details: ["operation": "notes.state.copy-link"]
    )
  }

  func readCollaborationParticipants(_ draft: NotesCollaborationParticipantsDraft) throws
    -> NotesCollaborationParticipantsReadResult
  {
    if let noteID = draft.noteID {
      guard let note = try frameworkNote(id: noteID) else {
        throw CLIError(code: .notFound, message: "Note was not found.", details: ["id_sha256": sha256Hex(noteID)])
      }
      let state = noteStateRecord(note)
      let share = collaborationShareObject(for: note)
      let participants = collaborationParticipantRecords(object: note, share: share)
      let wasShared = state.isSharedViaICloud || state.isSharedViaICloudFolder || (state.participantCount ?? 0) > 0
      return try collaborationParticipantsResult(
        targetKind: "note",
        targetHash: sha256Hex(state.noteID),
        object: note,
        share: share,
        wasShared: wasShared,
        isReadOnly: state.isSharedReadOnly,
        participantCount: max(state.participantCount ?? 0, participants.count),
        participants: participants,
        selectorHash: sha256Hex(noteID)
      )
    }

    if let folderID = draft.folderID {
      guard let folder = try frameworkFolder(id: folderID) else {
        throw CLIError(
          code: .notFound,
          message: "Folder was not found.",
          details: ["folder_id_sha256": sha256Hex(folderID)]
        )
      }
      let share = collaborationShareObject(for: folder)
      let participants = collaborationParticipantRecords(object: folder, share: share)
      let sharedByFlag = optionalBool(folder, key: "isSharedViaICloud") == true
        || optionalBool(folder, key: "isSharedReadOnly") == true
      let participantCount = max(
        share.flatMap(collaborationShareParticipantCount(_:)) ?? 0,
        participants.count
      )
      return try collaborationParticipantsResult(
        targetKind: "folder",
        targetHash: sha256Hex(objectIDString(folder)),
        object: folder,
        share: share,
        wasShared: sharedByFlag || participantCount > 0,
        isReadOnly: optionalBool(folder, key: "isSharedReadOnly"),
        participantCount: participantCount,
        participants: participants,
        selectorHash: sha256Hex(folderID)
      )
    }

    throw CLIError(
      code: .validationError,
      message: "Notes collaboration participants requires exactly one note or folder selector.",
      details: ["operation": "notes.state.participants"]
    )
  }

  func readNoteActivity(noteID id: String) throws -> NotesNoteActivityRecord {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }

    let state = noteStateRecord(note)
    let activityData = dataValue(optionalValue(note, key: "activityEventsData"))
    let shareTimestamp = optionalDate(note, key: "shareTimestamp")
    return NotesNoteActivityRecord(
      noteID: state.noteID,
      isShared: state.isSharedViaICloud || state.isSharedViaICloudFolder,
      isSharedReadOnly: state.isSharedReadOnly,
      isSharedViaICloudFolder: state.isSharedViaICloudFolder,
      hasUnreadChanges: state.hasUnreadChanges,
      participantCount: state.participantCount ?? 0,
      participantUserIDSHA256s: state.participantUserIDSHA256s,
      supportsActivityEvents: ICNote.supportsActivityEvents(),
      activityEventsPresent: activityData?.isEmpty == false,
      activityEventsByteCount: activityData?.count ?? 0,
      activityEventsSHA256: activityData.map(sha256Hex(_:)),
      activityEventsDocumentPresent: optionalObject(note, key: "activityEventsDocument") != nil,
      persistedActivityEventsStorageCount: objectCount(optionalObject(note, key: "persistedActivityEventsStorage")),
      checklistActivityEventsStorageCount: objectCount(optionalObject(note, key: "checklistItemToActivityEventsStorage")),
      shareTimestampPresent: shareTimestamp != nil,
      shareTimestampSHA256: shareTimestamp.map { sha256Hex(formatDate($0)) }
    )
  }

  func exportNotePDF(noteID id: String) throws -> NotesNotePDFExportSource {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard note.isDeletedOrInTrash == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Deleted or trashed notes cannot be exported as PDF.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    let exportState = try noteExportSessionState(note, requestedID: id, formatName: "PDF")

    let frame = CGRect(x: 0, y: 0, width: 612, height: 792)
    let controller = ICMPrintController(note: note, frame: frame)
    defer { controller?.postPrintCleanup() }
    guard let data = dataValue(controller?.pdfRepresentation()), isPDFData(data) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes private PDF exporter did not return valid PDF data.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    return NotesNotePDFExportSource(
      noteID: noteIdentifier(note),
      title: exportState.title,
      data: data,
      isPasswordProtected: exportState.isPasswordProtected,
      isPasswordProtectedAndLocked: exportState.isPasswordProtectedAndLocked
    )
  }

  func exportNoteMarkdown(noteID id: String, includeAttachments: Bool) throws -> NotesNoteMarkdownExportSource {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard note.isDeletedOrInTrash == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Deleted or trashed notes cannot be exported as Markdown.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    let exportState = try noteExportSessionState(note, requestedID: id, formatName: "Markdown")

    let resourceAttachments = exportableMarkdownResourceAttachments(note)
    let attachmentCount = resourceAttachments.count
    guard includeAttachments || attachmentCount == 0 else {
      throw CLIError(
        code: .unsupportedOperation,
        message:
          "Notes Markdown export with attachment resources requires `--include-attachments` and a package output path.",
        details: [
          "id_sha256": sha256Hex(id),
          "attachment_count": "\(attachmentCount)",
        ]
      )
    }

    guard let attributedString = note.attributedString() as? NSAttributedString,
      attributedString.length > 0
    else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes private Markdown exporter did not receive note text.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    let markdown = markdownString(
      ICMarkdownRepresentation.createMarkdownString(
        from: attributedString,
        context: nil,
        rangeMapping: nil
      ))
      ?? markdownString(
        ICMarkdownString.stringWithMarkdownStyles(
          fromAttributedString: attributedString,
          withContext: nil
        ))
    guard let data = markdown?.data(using: .utf8), notesMarkdownDataIsValid(data) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes private Markdown exporter did not return valid Markdown text.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    return NotesNoteMarkdownExportSource(
      noteID: noteIdentifier(note),
      title: exportState.title,
      data: data,
      includesAttachments: includeAttachments,
      attachmentCount: attachmentCount,
      markdownRelativePath: includeAttachments ? markdownPackageMainFilename(note) : "Note.md",
      resourceFiles: includeAttachments ? try markdownResourceFiles(from: resourceAttachments) : [],
      isPasswordProtected: exportState.isPasswordProtected,
      isPasswordProtectedAndLocked: exportState.isPasswordProtectedAndLocked
    )
  }

  func exportNoteHTML(
    noteID id: String,
    includeAttachments: Bool,
    includeAttachmentResources: Bool
  ) throws -> NotesNoteHTMLExportSource {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard note.isDeletedOrInTrash == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Deleted or trashed notes cannot be exported as HTML.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    let exportState = try noteExportSessionState(note, requestedID: id, formatName: "HTML")

    let resourceAttachments = exportableMarkdownResourceAttachments(note)
    let attachmentCount = resourceAttachments.count
    guard includeAttachments || attachmentCount == 0 else {
      throw CLIError(
        code: .unsupportedOperation,
        message:
          "Notes HTML export with attachment resources requires `--include-attachments`.",
        details: [
          "id_sha256": sha256Hex(id),
          "attachment_count": "\(attachmentCount)",
        ]
      )
    }

    let html = string(note.htmlString(withAttachments: includeAttachments))
    guard !html.isEmpty, let data = html.data(using: .utf8), notesHTMLDataHasMarker(data) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes private HTML exporter did not return valid HTML data.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    return NotesNoteHTMLExportSource(
      noteID: noteIdentifier(note),
      title: exportState.title,
      data: data,
      includesAttachments: includeAttachments,
      attachmentCount: attachmentCount,
      htmlRelativePath: includeAttachmentResources ? htmlPackageMainFilename(note) : "Note.html",
      resourceFiles: includeAttachmentResources ? try htmlResourceFiles(from: resourceAttachments) : [],
      isPasswordProtected: exportState.isPasswordProtected,
      isPasswordProtectedAndLocked: exportState.isPasswordProtectedAndLocked
    )
  }

  func exportNoteRTF(noteID id: String) throws -> NotesNoteRTFExportSource {
    let rtfd = try exportNoteRTFD(noteID: id)
    let rtfFiles = rtfd.files.filter {
      URL(fileURLWithPath: $0.relativePath).pathExtension.localizedCaseInsensitiveCompare("rtf")
        == .orderedSame
    }
    guard rtfd.files.count == 1, let rtfFile = rtfFiles.first, notesRTFDataHasHeader(rtfFile.data)
    else {
      throw CLIError(
        code: .unsupportedOperation,
        message:
          "Notes RTF export would omit RTFD package resources; use `notes export rtfd` for this note.",
        details: [
          "id_sha256": sha256Hex(rtfd.noteID),
          "file_count": "\(rtfd.files.count)",
          "rtf_file_count": "\(rtfFiles.count)",
        ]
      )
    }
    return NotesNoteRTFExportSource(
      noteID: rtfd.noteID,
      title: rtfd.title,
      data: rtfFile.data,
      isPasswordProtected: rtfd.isPasswordProtected,
      isPasswordProtectedAndLocked: rtfd.isPasswordProtectedAndLocked
    )
  }

  func exportNoteRTFD(noteID id: String) throws -> NotesNoteRTFDExportSource {
    guard let note = try frameworkNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
    }
    guard note.isDeletedOrInTrash == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Deleted or trashed notes cannot be exported as RTFD.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    let exportState = try noteExportSessionState(note, requestedID: id, formatName: "RTFD")

    let exporter = ICShareNoteExporter()
    guard let fileWrapper = exporter.fileWrapper(forNote: note) as? FileWrapper else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes private RTFD exporter did not return a file wrapper.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    let files = try rtfdFiles(from: fileWrapper)
    guard !files.isEmpty, notesRTFDContainsRTFFile(files) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes private RTFD exporter did not return an RTFD package.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }
    return NotesNoteRTFDExportSource(
      noteID: noteIdentifier(note),
      title: exportState.title,
      files: files,
      isPasswordProtected: exportState.isPasswordProtected,
      isPasswordProtectedAndLocked: exportState.isPasswordProtectedAndLocked
    )
  }

  private func noteExportSessionState(
    _ note: ICNote,
    requestedID id: String,
    formatName: String
  ) throws -> (isPasswordProtected: Bool, isPasswordProtectedAndLocked: Bool?, title: String?) {
    let state = noteStateRecord(note)
    guard state.isPasswordProtected == false || state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message:
          "Password-protected Notes \(formatName) export requires the selected note to already be unlocked in the current Notes session.",
        details: [
          "id_sha256": sha256Hex(id),
          "required_state": "non_password_protected_or_session_unlocked_password_protected_note",
          "future_gate": "secret_safe_authentication_session",
        ]
      )
    }
    return (
      isPasswordProtected: state.isPasswordProtected,
      isPasswordProtectedAndLocked: state.isPasswordProtectedAndLocked,
      title: state.isPasswordProtected ? nil : nonEmpty(string(note.title))
    )
  }

  func exportUnlockedLockedContent(_ draft: NotesLockedContentExportDraft) throws
    -> NotesLockedContentExportSource
  {
    let operation = "notes.state.export-locked-content"
    guard let note = try frameworkNote(id: draft.noteID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(draft.noteID)]
      )
    }
    var state = noteStateRecord(note)
    guard state.isDeletedOrInTrash == false && state.folderIsTrash != true else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Deleted or trashed notes cannot export locked content.",
        details: [
          "operation": operation,
          "note_id_sha256": sha256Hex(draft.noteID),
          "required_state": "visible_note",
        ]
      )
    }
    guard state.isPasswordProtected else {
      throw CLIError(
        code: .validationError,
        message: "Locked-content export requires a password-protected note.",
        details: [
          "operation": operation,
          "note_id_sha256": sha256Hex(draft.noteID),
          "required_state": "password_protected_note",
        ]
      )
    }
    var authenticatedDuringExport = false
    if state.isPasswordProtectedAndLocked == true,
      let passphrase = draft.passphrase,
      let passphraseSourceKind = draft.passphraseSourceKind
    {
      _ = try NotesWriter().unlockNote(
        NotesNoteUnlockDraft(
          noteID: draft.noteID,
          passphrase: passphrase,
          passphraseSourceKind: passphraseSourceKind
        )
      )
      authenticatedDuringExport = true
      state = noteStateRecord(note)
    }
    guard state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message:
          "Locked-content export requires the selected note to already be unlocked in the current Notes session.",
        details: [
          "operation": operation,
          "note_id_sha256": sha256Hex(draft.noteID),
          "required_state": "password_protected_unlocked_note",
          "future_gate": "secret_safe_authentication_session",
        ]
      )
    }

    return NotesLockedContentExportSource(
      noteID: state.noteID,
      isPasswordProtected: state.isPasswordProtected,
      isPasswordProtectedAndLocked: state.isPasswordProtectedAndLocked,
      authenticatedDuringExport: authenticatedDuringExport,
      passphraseSourceKind: draft.passphraseSourceKind,
      content: plainTextBody(note),
      backendCalls: authenticatedDuringExport
        ? "ICAuthenticationState.authenticateObject:withPassphrase:+ICNote.noteAsPlainTextWithoutTitle"
        : "ICNote.noteAsPlainTextWithoutTitle"
    )
  }

  private func frameworkNote(id: String, includeDeleted: Bool = false) throws -> ICNote? {
    let managedObjectContext = try managedObjectContext()
    if includeDeleted,
      let note = try managedObject(id: id, context: managedObjectContext) as? ICNote
    {
      return note
    }

    if includeDeleted,
      let note = ICNote.note(withIdentifier: id, includeDeleted: true, context: managedObjectContext)
        as? ICNote
    {
      return note
    }

    if !includeDeleted,
      let note = ICNote.note(withIdentifier: id, context: managedObjectContext) as? ICNote
    {
      return note
    }

    if includeDeleted {
      return objects(ICNote.allNotes(inContext: managedObjectContext)).first { note in
        noteIdentifier(note) == id || objectIDString(note) == id
      }
    }

    return try visibleNotes().first { note in
      noteIdentifier(note) == id || objectIDString(note) == id
    }
  }

  private func frameworkFolder(id: String) throws -> ICFolder? {
    let managedObjectContext = try managedObjectContext()
    if let folder = try managedObject(id: id, context: managedObjectContext) as? ICFolder {
      return folder
    }

    let folders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
    if let match = folders.first(where: { objectIDString($0) == id }) {
      return match
    }

    let matches = folders.filter {
      folderDisplayName($0).localizedCaseInsensitiveCompare(id) == .orderedSame
    }
    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Folder selector matched multiple Notes folders.",
        details: ["folder_sha256": sha256Hex(id)]
      )
    }
    return matches.first
  }

  private func managedObject(id: String, context: NSManagedObjectContext) throws -> NSManagedObject? {
    guard id.hasPrefix("x-coredata://"),
      let url = URL(string: id),
      let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    else {
      return nil
    }
    return try context.existingObject(with: objectID)
  }

  private func visibleNotes() throws -> [ICNote] {
    let managedObjectContext = try managedObjectContext()
    return objects(ICNote.visibleNotes(inContext: managedObjectContext))
  }

  private func managedObjectContext() throws -> NSManagedObjectContext {
    let context = try noteContext()
    guard let managedObjectContext = context.managedObjectContext else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private framework context did not expose a managed object context."
      )
    }
    return managedObjectContext
  }

  private func save(context: ICNoteContext, operation: String) throws {
    var error: AnyObject?
    guard context.save(&error) else {
      throw CLIError(
        code: .internalError,
        message: "Notes private framework context save failed.",
        details: [
          "operation": operation,
          "reason": "ICNoteContext.save returned false.",
          "error_sha256": error.map { sha256Hex(String(describing: $0)) } ?? "",
        ]
      )
    }
    if let managedObjectContext = context.managedObjectContext, !managedObjectContext.ic_save() {
      throw CLIError(
        code: .internalError,
        message: "Notes private framework managed object context save failed.",
        details: [
          "operation": operation,
          "reason": "NSManagedObjectContext.ic_save returned false.",
        ]
      )
    }
  }

  private func save(managedObjectContext: NSManagedObjectContext, operation: String) throws {
    guard managedObjectContext.ic_save() else {
      throw CLIError(
        code: .internalError,
        message: "Notes private framework managed object context save failed.",
        details: [
          "operation": operation,
          "reason": "NSManagedObjectContext.ic_save returned false.",
        ]
      )
    }
  }

  private func noteContext() throws -> ICNoteContext {
    if let context = ICNoteContext.sharedContext() as? ICNoteContext {
      return context
    }

    ICNoteContext.startSharedContext(withOptions: 0)
    if let context = ICNoteContext.sharedContext() as? ICNoteContext {
      return context
    }

    if let context = ICNoteContext(options: 0) {
      return context
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Notes private framework context could not be started."
    )
  }

  private func localAccountVisibleNoteCountIncludingTrash(_ account: ICAccount) -> Int? {
    optionalInt(account, key: "visibleNotesIncludingTrashCount")
  }

  private func localAccountVisibleCustomFolderCount(_ account: ICAccount) -> Int? {
    optionalInt(account, key: "visibleCustomFoldersCount")
  }

  private func completeVisibleFolders(from seedFolders: [ICFolder]) -> [ICFolder] {
    var foldersByID: [String: ICFolder] = [:]
    var pending = seedFolders
    var index = 0
    while index < pending.count {
      let folder = pending[index]
      index += 1
      let folderID = objectIDString(folder)
      guard foldersByID[folderID] == nil else {
        continue
      }
      foldersByID[folderID] = folder
      pending.append(contentsOf: visibleFolderDescendants(of: folder))
    }
    return Array(foldersByID.values)
  }

  private func visibleFolderDescendants(of folder: ICFolder) -> [ICFolder] {
    let directVisible: [ICFolder] = objects(optionalObject(folder, key: "visibleSubFolders"))
    let recursiveVisible: [ICFolder] = objects(optionalObject(folder, key: "recursiveVisibleSubfolders"))
    let folderRelationship: [ICFolder] = objects(optionalObject(folder, key: "foldersInFolder"))
    return uniqueVisibleFolders(directVisible + recursiveVisible + folderRelationship)
  }

  private func uniqueVisibleFolders(_ folders: [ICFolder]) -> [ICFolder] {
    var seen: Set<String> = []
    var result: [ICFolder] = []
    for folder in folders {
      guard optionalBool(folder, key: "isTrashFolder") != true,
        optionalBool(folder, key: "isSystemFolder") != true
      else {
        continue
      }
      let folderID = objectIDString(folder)
      guard seen.insert(folderID).inserted else {
        continue
      }
      result.append(folder)
    }
    return result
  }

  private func hierarchicalFolderRecords(_ records: [NotesFolderRecord]) -> [NotesFolderRecord] {
    let recordsByID = Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0) })
    let childrenByParent = Dictionary(grouping: records.compactMap { record -> NotesFolderRecord? in
      guard let parentID = record.parentID, recordsByID[parentID] != nil else {
        return nil
      }
      return record
    }, by: { $0.parentID ?? "" })
    let roots = records.filter { record in
      guard let parentID = record.parentID else {
        return true
      }
      return recordsByID[parentID] == nil
    }

    var emitted: Set<String> = []
    var ordered: [NotesFolderRecord] = []

    func emit(_ record: NotesFolderRecord) {
      guard emitted.insert(record.id).inserted else {
        return
      }
      ordered.append(record)
      for child in sortedFolderRecords(childrenByParent[record.id] ?? []) {
        emit(child)
      }
    }

    for root in sortedFolderRecords(roots) {
      emit(root)
    }
    for record in sortedFolderRecords(records) where emitted.contains(record.id) == false {
      emit(record)
    }
    return ordered
  }

  private func sortedFolderRecords(_ records: [NotesFolderRecord]) -> [NotesFolderRecord] {
    records.sorted { lhs, rhs in
      if lhs.accountName != rhs.accountName {
        return lhs.accountName.localizedStandardCompare(rhs.accountName) == .orderedAscending
      }
      switch (lhs.siblingOrderIndex, rhs.siblingOrderIndex) {
      case let (left?, right?) where left != right:
        return left < right
      default:
        break
      }
      if lhs.name != rhs.name {
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
      }
      return lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
    }
  }

  private func folderRecord(_ folder: ICFolder, isPurgable: Bool? = nil) -> NotesFolderRecord {
    let parent = folder.parent
    let sortType = optionalObject(folder, key: "customNoteSortType")
    let siblingOrder = folderSiblingOrderEvidence(folder)
    return NotesFolderRecord(
      id: objectIDString(folder),
      name: folderDisplayName(folder),
      accountName: nonEmpty(folder.accountName) ?? nonEmpty(folder.account?.localizedName) ?? "Notes",
      parentID: parent.map(objectIDString),
      isRootLevel: isRootLevel(folder),
      parentPresent: parent != nil,
      depth: optionalInt(folder, key: "depth"),
      folderType: optionalInt(folder, key: "folderType"),
      visibleNoteCount: optionalInt(folder, key: "visibleNotesCount")
        ?? optionalInt(folder, key: "countOfVisibleNotesInFolder"),
      childFolderCount: objectCount(optionalObject(folder, key: "foldersInFolder"))
        ?? objectCount(optionalObject(folder, key: "visibleSubFolders")),
      isDefault: optionalBool(folder, key: "isDefaultFolderForAccount"),
      isTrash: optionalBool(folder, key: "isTrashFolder"),
      isSmartFolder: optionalBool(folder, key: "isSmartFolder"),
      isSystemFolder: optionalBool(folder, key: "isSystemFolder"),
      isLeaf: optionalBool(folder, key: "isLeaf"),
      isRenamable: optionalBool(folder, key: "isRenamable"),
      isMovable: optionalBool(folder, key: "isMovable"),
      isDeletable: optionalBool(folder, key: "isDeletable"),
      isPurgable: isPurgable,
      canAddSubfolder: optionalBool(folder, key: "canAddSubfolder"),
      supportsEditingNotes: optionalBool(folder, key: "supportsEditingNotes"),
      noteSortTypeValue: optionalInt(folder, key: "customNoteSortTypeValue"),
      supportsCustomNoteSortType: optionalBool(folder, key: "supportsCustomNoteSortType"),
      customNoteSortOrder: sortType.flatMap { optionalInt($0, key: "order") },
      customNoteSortDirection: sortType.flatMap { optionalInt($0, key: "direction") },
      customNoteSortIsDefault: sortType.flatMap { optionalBool($0, key: "isDefault") },
      customNoteSortIsAscending: sortType.flatMap { optionalBool($0, key: "isAscending") },
      customNoteSortResolvedOrder: sortType.flatMap { optionalInt($0, key: "resolvedCustomSortTypeOrder") },
      customNoteSortDescription: sortType.flatMap {
        nonEmpty(optionalString($0, key: "buttonTitleDescription"))
      },
      supportsDateHeaders: optionalBool(folder, key: "supportsDateHeaders"),
      isShowingDateHeaders: optionalBool(folder, key: "isShowingDateHeaders"),
      dateHeadersTypeValue: optionalInt(folder, key: "dateHeadersType"),
      isSharedViaICloud: optionalBool(folder, key: "isSharedViaICloud"),
      isSharedReadOnly: optionalBool(folder, key: "isSharedReadOnly"),
      isSubfolderOfReadOnlyFolder: optionalBool(folder, key: "isSubfolderOfReadonlyFolder"),
      siblingOrderIndex: siblingOrder.index,
      siblingOrderCount: siblingOrder.count,
      siblingOrderSHA256: siblingOrder.sha256
    )
  }

  private func folderSiblingOrderEvidence(_ folder: ICFolder) -> (index: Int?, count: Int?, sha256: String?) {
    let siblings = folderSiblingOrder(folder)
    guard !siblings.isEmpty else {
      return (nil, nil, nil)
    }
    let folderID = objectIDString(folder)
    let siblingIDs = siblings.map(objectIDString(_:))
    return (
      siblingIDs.firstIndex(of: folderID),
      siblingIDs.count,
      sha256Hex(siblingIDs.joined(separator: "\n"))
    )
  }

  private func folderSiblingOrder(_ folder: ICFolder) -> [ICFolder] {
    let container: AnyObject? = folder.parent ?? folder.account
    guard let container else {
      return []
    }
    let candidateKeys = [
      "visibleNoteContainerChildren",
      "visibleSubFolders",
      "customRootLevelFolders",
      "foldersInFolder",
    ]
    for key in candidateKeys {
      let candidates: [ICFolder] = objects(optionalObject(container, key: key))
      let visible = candidates.filter {
        optionalBool($0, key: "isTrashFolder") != true
          && optionalBool($0, key: "isSystemFolder") != true
      }
      if visible.contains(where: { objectIDString($0) == objectIDString(folder) }) {
        return visible
      }
    }
    return []
  }

  private func purgableFolders(in context: NSManagedObjectContext) throws -> [ICFolder] {
    guard let request = ICFolder.purgableFoldersFetchRequest() as? NSFetchRequest<NSFetchRequestResult> else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes private framework did not expose a folder purge fetch request."
      )
    }
    return try context.fetch(request).compactMap { $0 as? ICFolder }
  }

  private func isRootLevel(_ folder: ICFolder) -> Bool? {
    if let account = folder.account {
      let rootFolders: [ICFolder] = objects(optionalObject(account, key: "customRootLevelFolders"))
      if !rootFolders.isEmpty {
        let folderID = objectIDString(folder)
        return rootFolders.contains { objectIDString($0) == folderID }
      }
    }
    return folder.parent == nil
  }

  private func smartFolderRecord(_ folder: ICFolder) -> NotesSmartFolderRecord {
    let queryJSON = nonEmpty(optionalString(folder, key: "smartFolderQueryJSON"))
    let query = optionalObject(folder, key: "smartFolderQuery") as? ICQuery
    let queryPresent = optionalObject(folder, key: "smartFolderQuery") != nil || queryJSON != nil
    return NotesSmartFolderRecord(
      id: objectIDString(folder),
      name: folderDisplayName(folder),
      accountName: nonEmpty(folder.accountName) ?? nonEmpty(folder.account?.localizedName) ?? "Notes",
      description: nonEmpty(optionalString(folder, key: "smartFolderDescription")),
      shortDescription: nonEmpty(optionalString(folder, key: "smartFolderShortDescription")),
      queryPresent: queryPresent,
      queryJSONLength: queryJSON?.utf8.count,
      querySHA256: queryJSON.map(sha256Hex),
      criteria: smartFolderCriteriaSummary(folder, query: query, queryJSON: queryJSON),
      visibleNoteCount: optionalInt(folder, key: "visibleNotesCount"),
      isEditable: optionalBool(folder, key: "isEditableSmartFolder"),
      isDeletable: optionalBool(folder, key: "isDeletable")
    )
  }

  private func smartFolder(id: String) throws -> ICFolder {
    let managedObjectContext = try managedObjectContext()
    let folders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
    guard let folder = folders.first(where: {
      objectIDString($0) == id && optionalBool($0, key: "isSmartFolder") == true
    }) else {
      throw CLIError(
        code: .notFound,
        message: "Smart Folder selector did not match any Notes Smart Folder.",
        details: ["smart_folder_id_sha256": sha256Hex(id)]
      )
    }
    return folder
  }

  private func smartFolderCriteriaSummary(
    _ folder: ICFolder,
    query: ICQuery?,
    queryJSON: String?
  ) -> NotesSmartFolderCriteriaSummary? {
    guard let query else {
      guard queryJSON != nil else {
        return nil
      }
      return NotesSmartFolderCriteriaSummary(queryKind: "query_json", predicatePresent: false)
    }

    let predicateFormat = smartFolderPredicateFormat(query)
    let filterSelection = performedObject(
      query,
      selector: "filterSelectionWithManagedObjectContext:account:",
      folder.managedObjectContext,
      folder.account
    )
    let tagSelection = performedObject(
      query,
      selector: "tagSelectionWithManagedObjectContext:",
      folder.managedObjectContext
    )
    let filters = filterSelection
      .map { anyObjects(optionalObject($0, key: "filterTypeSelections")).map(smartFolderCriteriaFilter) }
      ?? []
    let tagCriteria = tagSelection.flatMap(smartFolderTagCriteria)

    let queryKind: String
    if !filters.isEmpty, tagCriteria != nil {
      queryKind = "mixed_selection"
    } else if !filters.isEmpty || filterSelection != nil {
      queryKind = "filter_selection"
    } else if tagCriteria != nil {
      queryKind = "tag_selection"
    } else {
      queryKind = "query"
    }

    return NotesSmartFolderCriteriaSummary(
      queryKind: queryKind,
      canBeEdited: optionalBool(query, key: "canBeEdited"),
      minimumSupportedVersion: optionalInt(query, key: "minimumSupportedVersion"),
      entityName: smartFolderEntityName(optionalString(query, key: "entityName")),
      predicatePresent: predicateFormat != nil,
      predicateFormatLength: predicateFormat?.utf8.count,
      predicateFormatSHA256: predicateFormat.map(sha256Hex),
      joinOperator: filterSelection.flatMap { optionalInt($0, key: "joinOperator") },
      includeRecentlyDeleted: filterSelection.flatMap { optionalBool($0, key: "includeRecentlyDeleted") },
      isValid: filterSelection.flatMap { optionalBool($0, key: "isValid") },
      filterCount: filters.count,
      filters: filters,
      tagSelection: tagCriteria
    )
  }

  private func smartFolderPredicateFormat(_ query: ICQuery) -> String? {
    guard let predicate = optionalObject(query, key: "predicate") as? NSPredicate else {
      return nil
    }
    return nonEmpty(predicate.predicateFormat)
  }

  private func smartFolderEntityName(_ name: String?) -> String? {
    guard let name = nonEmpty(name) else {
      return nil
    }
    if name.localizedCaseInsensitiveContains("note") {
      return "note"
    }
    if name.localizedCaseInsensitiveContains("attachment") {
      return "attachment"
    }
    if name.localizedCaseInsensitiveContains("folder") {
      return "folder"
    }
    return "unknown"
  }

  private func smartFolderCriteriaFilter(_ selection: AnyObject) -> NotesSmartFolderCriteriaFilter {
    let rawValue = nonEmpty(optionalString(selection, key: "rawFilterValue"))
    let kind = smartFolderCriteriaKind(selection, rawValue: rawValue)
    return NotesSmartFolderCriteriaFilter(
      kind: kind,
      isEmpty: optionalBool(selection, key: "isEmpty"),
      isValid: optionalBool(selection, key: "isValid"),
      selectionType: optionalInt(selection, key: "selectionType"),
      inclusionType: optionalInt(selection, key: "inclusionType"),
      joinOperator: optionalInt(selection, key: "joinOperator"),
      rawValuePresent: rawValue != nil,
      rawValueLength: rawValue?.utf8.count,
      rawValueSHA256: rawValue.map(sha256Hex),
      count: smartFolderCriteriaCount(selection),
      includedCount: smartFolderCriteriaIncludedCount(selection),
      excludedCount: smartFolderCriteriaExcludedCount(selection),
      hasPrimaryDate: optionalDate(selection, key: "primaryDate") != nil,
      hasSecondaryDate: optionalDate(selection, key: "secondaryDate") != nil,
      hasRelativeRange: optionalObject(selection, key: "relativeRangeAmount") != nil
        || optionalInt(selection, key: "relativeRangeSelectionType") != nil,
      folderID: kind == "folders" ? rawValue : nil,
      primaryDate: optionalDate(selection, key: "primaryDate"),
      secondaryDate: optionalDate(selection, key: "secondaryDate"),
      relativeRangeAmount: optionalInt(selection, key: "relativeRangeAmount"),
      relativeRangeSelectionType: optionalInt(selection, key: "relativeRangeSelectionType"),
      participantUserIDSHA256s: participantUserIDSHA256s(from: optionalObject(selection, key: "participantUserIDs"))
    )
  }

  private func smartFolderCriteriaKind(_ selection: AnyObject, rawValue: String?) -> String {
    switch selection {
    case is ICTagSelection:
      return "tags"
    case is ICFoldersFilterTypeSelection:
      return "folders"
    case is ICAttachmentsFilterTypeSelection:
      return "attachments"
    case is ICChecklistsFilterTypeSelection:
      return "checklists"
    case is ICDateCreatedFilterTypeSelection:
      return "date_created"
    case is ICDateEditedFilterTypeSelection:
      return "date_edited"
    case is ICLockedNotesFilterTypeSelection:
      return "locked"
    case is ICMentionsFilterTypeSelection:
      return "mentions"
    case is ICPinnedNotesFilterTypeSelection:
      return "pinned"
    case is ICQuickNotesFilterTypeSelection:
      return "quick_notes"
    case is ICSharedFilterTypeSelection:
      return "shared"
    case is ICParticipantsFilterTypeSelection:
      return "participants"
    case is ICDateFilterTypeSelection:
      return "date"
    case is ICInclusionFilterTypeSelection:
      return smartFolderInclusionCriteriaKind(rawValue: rawValue) ?? "inclusion"
    default:
      return smartFolderInclusionCriteriaKind(rawValue: rawValue) ?? "unknown"
    }
  }

  private func smartFolderInclusionCriteriaKind(rawValue: String?) -> String? {
    guard let value = rawValue?.replacingOccurrences(of: "_", with: "-").localizedLowercase else {
      return nil
    }
    if value.contains("system-paper") || value.contains("systempaper") {
      return "system_paper"
    }
    if value.contains("math") {
      return "math"
    }
    if value.contains("call") {
      return "call"
    }
    return nil
  }

  private func smartFolderCriteriaCount(_ selection: AnyObject) -> Int? {
    if let selectedTagCount = optionalInt(selection, key: "selectedTagCount") {
      return selectedTagCount
    }
    return objectCount(optionalObject(selection, key: "folderIdentifiers"))
      ?? objectCount(optionalObject(selection, key: "participantUserIDs"))
      ?? objectCount(optionalObject(selection, key: "tags"))
      ?? objectCount(optionalObject(selection, key: "objectIDs"))
  }

  private func smartFolderCriteriaIncludedCount(_ selection: AnyObject) -> Int? {
    objectCount(optionalObject(selection, key: "includedObjectIDURLs"))
      ?? objectCount(optionalObject(selection, key: "includedTags"))
      ?? objectCount(optionalObject(selection, key: "includedDisplayTexts"))
      ?? objectCount(optionalObject(selection, key: "includedTagIdentifiers"))
  }

  private func smartFolderCriteriaExcludedCount(_ selection: AnyObject) -> Int? {
    objectCount(optionalObject(selection, key: "excludedObjectIDURLs"))
      ?? objectCount(optionalObject(selection, key: "excludedTags"))
      ?? objectCount(optionalObject(selection, key: "excludedDisplayTexts"))
      ?? objectCount(optionalObject(selection, key: "excludedTagIdentifiers"))
  }

  private func smartFolderTagCriteria(_ selection: AnyObject) -> NotesSmartFolderTagCriteria? {
    let tagIdentifiers = strings(optionalValue(selection, key: "tagIdentifiers")).sorted()
    let displayTexts = strings(optionalValue(selection, key: "displayTexts")).sorted()
    let includedTagIdentifiers = strings(optionalValue(selection, key: "includedTagIdentifiers")).sorted()
    let includedDisplayTexts = strings(optionalValue(selection, key: "includedDisplayTexts")).sorted()
    let excludedTagIdentifiers = strings(optionalValue(selection, key: "excludedTagIdentifiers")).sorted()
    let excludedDisplayTexts = strings(optionalValue(selection, key: "excludedDisplayTexts")).sorted()
    let includedCount = smartFolderCriteriaIncludedCount(selection)
    let excludedCount = smartFolderCriteriaExcludedCount(selection)
    let effectiveIncludedTagIdentifiers =
      includedTagIdentifiers.isEmpty && (excludedCount ?? 0) == 0 ? tagIdentifiers : includedTagIdentifiers
    let effectiveIncludedDisplayTexts =
      includedDisplayTexts.isEmpty && (excludedCount ?? 0) == 0 ? displayTexts : includedDisplayTexts
    return NotesSmartFolderTagCriteria(
      selectedTagCount: optionalInt(selection, key: "selectedTagCount"),
      includedTagCount: includedCount,
      excludedTagCount: excludedCount,
      tagOperator: optionalInt(selection, key: "tagOperator"),
      mode: optionalInt(selection, key: "mode"),
      allowsRecentlyDeleted: optionalBool(selection, key: "allowsRecentlyDeleted"),
      tagIdentifiersSHA256: tagIdentifiers.isEmpty ? nil : sha256Hex(tagIdentifiers.joined(separator: "\0")),
      displayTextsSHA256: displayTexts.isEmpty ? nil : sha256Hex(displayTexts.joined(separator: "\0")),
      tagIdentifiers: tagIdentifiers.isEmpty ? nil : tagIdentifiers,
      displayTexts: displayTexts.isEmpty ? nil : displayTexts,
      includedTagIdentifiers: effectiveIncludedTagIdentifiers.isEmpty ? nil : effectiveIncludedTagIdentifiers,
      includedDisplayTexts: effectiveIncludedDisplayTexts.isEmpty ? nil : effectiveIncludedDisplayTexts,
      excludedTagIdentifiers: excludedTagIdentifiers.isEmpty ? nil : excludedTagIdentifiers,
      excludedDisplayTexts: excludedDisplayTexts.isEmpty ? nil : excludedDisplayTexts
    )
  }

  private func noteSummary(_ note: ICNote) -> NotesNoteSummary {
    NotesNoteSummary(
      id: noteIdentifier(note),
      title: nonEmpty(note.title) ?? "Untitled",
      folderName: noteFolderDisplayName(note),
      accountName: nonEmpty(note.accountName) ?? "Notes",
      createdAt: note.creationDate,
      updatedAt: note.modificationDate
    )
  }

  private func naturalLanguageSearchResultObjects(_ value: Any?) -> [AnyObject] {
    switch value {
    case let array as NSArray:
      return array.compactMap { $0 as AnyObject }
    case let array as [AnyObject]:
      return array
    default:
      return []
    }
  }

  private func naturalLanguageSearchResultIdentifier(_ result: AnyObject) -> String? {
    if let searchableItem = optionalValue(result, key: "searchableItem") as? CSSearchableItem {
      return nonEmpty(searchableItem.uniqueIdentifier)
    }
    if let configuration = optionalValue(result, key: "configuration") as? AnyObject,
      let sortable = optionalValue(configuration, key: "sortableSearchableItem") as? AnyObject,
      let searchableItem = optionalValue(sortable, key: "searchableItem") as? CSSearchableItem
    {
      return nonEmpty(searchableItem.uniqueIdentifier)
    }
    if let note = optionalValue(result, key: "object") as? ICNote {
      return noteIdentifier(note)
    }
    if let note = optionalValue(result, key: "currentContextObject") as? ICNote {
      return noteIdentifier(note)
    }
    return nil
  }

  private func naturalLanguageSearchNoteIndex(_ notes: [ICNote]) -> [String: ICNote] {
    var index: [String: ICNote] = [:]
    for note in notes {
      for identifier in naturalLanguageSearchIdentifiers(note) where index[identifier] == nil {
        index[identifier] = note
      }
    }
    return index
  }

  private func naturalLanguageSearchIdentifiers(_ note: ICNote) -> [String] {
    [
      noteIdentifier(note),
      objectIDString(note),
      nonEmpty(note.searchIndexingIdentifier),
      nonEmpty(note.contentIdentifier),
      optionalString(note, key: "identifier"),
    ].compactMap { $0 }
  }

  private func noteDetail(_ note: ICNote) -> NotesNoteDetail {
    NotesNoteDetail(
      id: noteIdentifier(note),
      title: nonEmpty(note.title) ?? "Untitled",
      folderName: noteFolderDisplayName(note),
      accountName: nonEmpty(note.accountName) ?? "Notes",
      body: note.isPasswordProtected ? nil : plainTextBody(note),
      createdAt: note.creationDate,
      updatedAt: note.modificationDate,
      tags: noteTags(note)
    )
  }

  private func noteSearchTextMatches(_ note: ICNote, normalizedQuery: String) -> Bool {
    if string(note.title).localizedLowercase.contains(normalizedQuery) {
      return true
    }
    guard note.isPasswordProtected == false,
      optionalBool(note, key: "isPasswordProtectedAndLocked") != true
    else {
      return false
    }
    return plainTextBody(note).localizedLowercase.contains(normalizedQuery)
  }

  private func tagRecord(_ hashtag: ICHashtag) -> NotesTagRecord {
    let standardizedContent = nonEmpty(hashtag.standardizedContent)
    let visibleUseCount = standardizedContent.map {
      Int(
        ICInlineAttachment.countOfVisibleInlineAttachments(
          forHashtagStandardizedContent: $0,
          account: hashtag.account
        ))
    }
    return NotesTagRecord(
      id: objectIDString(hashtag),
      displayText: nonEmpty(hashtag.displayText) ?? standardizedContent ?? "Untitled",
      standardizedContent: standardizedContent,
      accountName: nonEmpty(hashtag.account?.localizedName) ?? nonEmpty(hashtag.account?.name) ?? "Notes",
      visibleUseCount: visibleUseCount
    )
  }

  private func noteTags(_ note: ICNote) -> [NotesTagRecord] {
    let identifiers = Set(strings(note.hashtagContentIdentifiers).map(standardizedTagContent))
    guard !identifiers.isEmpty else {
      return []
    }
    let hashtags: [ICHashtag] = objects(ICHashtag.allVisibleHashtags(inContext: note.managedObjectContext))
    return hashtags
      .filter { hashtag in
        tagIdentifierCandidates(hashtag).contains { identifiers.contains(standardizedTagContent($0)) }
      }
      .map(tagRecord)
      .sorted { $0.displayText.localizedStandardCompare($1.displayText) == .orderedAscending }
  }

  private func attachmentObjects(_ note: ICNote) -> [AnyObject] {
    let ordered = anyObjects(note.attachmentsInOrder())
    if !ordered.isEmpty {
      return ordered
    }
    return anyObjects(note.visibleAttachments())
  }

  private func imageDescriptionAttachmentObjects(_ note: ICNote) -> [AnyObject] {
    var seen = Set<String>()
    var result: [AnyObject] = []
    for attachment in attachmentObjects(note) + anyObjects(note.allNoteTextInlineAttachments()) {
      let identity = objectIDString(attachment)
      guard seen.insert(identity).inserted else {
        continue
      }
      result.append(attachment)
    }
    return result
  }

  private func selectedImageDescriptionAttachment(
    in note: ICNote,
    noteID: String,
    selector: String
  ) throws -> (attachment: AnyObject, record: NotesAttachmentRecord) {
    let matches = imageDescriptionAttachmentObjects(note).filter { attachment in
      attachmentMatches(attachment, selector: selector)
    }
    guard let attachment = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any image-description-capable attachment on the note.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "attachment_sha256": sha256Hex(selector),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple image-description-capable attachments on the note.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "attachment_sha256": sha256Hex(selector),
          "match_count": "\(matches.count)",
        ]
      )
    }
    return (attachment, attachmentRecord(attachment))
  }

  private func exportableMarkdownResourceAttachments(_ note: ICNote) -> [AnyObject] {
    attachmentObjects(note).filter { attachment in
      let record = attachmentRecord(attachment)
      return record.isDeletedOrInTrash != true && optionalObject(attachment, key: "media") != nil
    }
  }

  private func markdownPackageMainFilename(_ note: ICNote) -> String {
    "\(sanitizedMarkdownPackageFilename(nonEmpty(string(note.title)) ?? "Note", fallback: "Note")).md"
  }

  private func htmlPackageMainFilename(_ note: ICNote) -> String {
    "\(sanitizedMarkdownPackageFilename(nonEmpty(string(note.title)) ?? "Note", fallback: "Note")).html"
  }

  private func markdownResourceFiles(from attachments: [AnyObject]) throws -> [NotesNoteMarkdownExportFile] {
    var usedFilenames: Set<String> = []
    var files: [NotesNoteMarkdownExportFile] = []
    for (offset, attachment) in attachments.enumerated() {
      let record = attachmentRecord(attachment)
      let ordinal = offset + 1
      let filename = uniqueMarkdownResourceFilename(
        markdownResourceFilename(record: record, ordinal: ordinal),
        used: &usedFilenames,
        ordinal: ordinal
      )
      files.append(
        NotesNoteMarkdownExportFile(
          relativePath: "Resources/\(filename)",
          data: try attachmentData(attachment, record: record)
        ))
    }
    return try normalizedNotesMarkdownExportFiles(files)
  }

  private func htmlResourceFiles(from attachments: [AnyObject]) throws -> [NotesNoteHTMLExportFile] {
    let markdownFiles = try markdownResourceFiles(from: attachments)
    return try normalizedNotesHTMLExportFiles(
      markdownFiles.map { NotesNoteHTMLExportFile(relativePath: $0.relativePath, data: $0.data) }
    )
  }

  private func markdownResourceFilename(record: NotesAttachmentRecord, ordinal: Int) -> String {
    sanitizedMarkdownPackageFilename(
      record.mediaFilename ?? record.title ?? record.contentIdentifier ?? "attachment-\(ordinal)",
      fallback: "attachment-\(ordinal)"
    )
  }

  private func uniqueMarkdownResourceFilename(
    _ filename: String,
    used: inout Set<String>,
    ordinal: Int
  ) -> String {
    if used.insert(filename).inserted {
      return filename
    }

    let url = URL(fileURLWithPath: filename)
    let ext = url.pathExtension
    let base: String
    if ext.isEmpty {
      base = filename
    } else {
      base = String(filename.dropLast(ext.count + 1))
    }
    var candidate = ext.isEmpty ? "\(base)-\(ordinal)" : "\(base)-\(ordinal).\(ext)"
    var suffix = ordinal
    while !used.insert(candidate).inserted {
      suffix += 1
      candidate = ext.isEmpty ? "\(base)-\(suffix)" : "\(base)-\(suffix).\(ext)"
    }
    return candidate
  }

  private func sanitizedMarkdownPackageFilename(_ value: String, fallback: String) -> String {
    var result = ""
    let slash = UnicodeScalar("/")
    let backslash = UnicodeScalar("\\")
    let colon = UnicodeScalar(":")
    for scalar in value.unicodeScalars {
      if scalar.value < 32 || scalar == slash || scalar == backslash || scalar == colon {
        result.append("-")
      } else {
        result.unicodeScalars.append(scalar)
      }
    }
    let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, trimmed != ".", trimmed != ".." else {
      return fallback
    }
    return trimmed
  }

  private func attachmentRecord(_ attachment: AnyObject) -> NotesAttachmentRecord {
    let isInline = attachment is ICInlineAttachment
      || optionalObject(attachment, key: "parentAttachment") != nil
    let imageDescription = isInline
      ? nonEmpty(optionalString(attachment, key: "altText"))
      : nil
    return NotesAttachmentRecord(
      id: optionalString(attachment, key: "identifier") ?? objectIDString(attachment),
      title: nonEmpty(optionalString(attachment, key: "title")),
      typeUTI: nonEmpty(optionalString(attachment, key: "typeUTI")),
      contentIdentifier: nonEmpty(optionalString(attachment, key: "contentIdentifier")),
      attachmentType: optionalInt(attachment, key: "attachmentType"),
      fileSizeBytes: optionalInt64(attachment, key: "fileSize"),
      mediaFilename: optionalObject(attachment, key: "media")
        .flatMap { nonEmpty(optionalString($0, key: "filename")) },
      isInline: isInline,
      isDeletedOrInTrash: optionalBool(attachment, key: "isDeletedOrInTrash"),
      imageDescriptionPresent: isInline ? imageDescription != nil : nil,
      imageDescriptionByteCount: imageDescription.map { $0.utf8.count },
      imageDescriptionSHA256: imageDescription.map(sha256Hex),
      imageDescriptionSourceKind: isInline ? "ICInlineAttachment.altText" : nil,
      imageClassificationSummaryPresent: normalizedImageClassificationSummary(
        optionalString(attachment, key: "imageClassificationSummary")
      ) != nil,
      imageClassificationSummaryByteCount: normalizedImageClassificationSummary(
        optionalString(attachment, key: "imageClassificationSummary")
      ).map { $0.utf8.count },
      imageClassificationSummarySHA256: normalizedImageClassificationSummary(
        optionalString(attachment, key: "imageClassificationSummary")
      ).map(sha256Hex),
      imageClassificationSummaryVersion: optionalInt(attachment, key: "imageClassificationSummaryVersion"),
      imageClassificationSummarySourceKind: "ICAttachment.imageClassificationSummary"
    )
  }

  private func normalizedImageClassificationSummary(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  private func imageClassificationAttachmentRecord(
    _ attachment: NotesAttachmentRecord,
    summary: String?,
    version: Int?
  ) -> NotesAttachmentRecord {
    var record = attachment
    record.imageClassificationSummaryPresent = summary != nil
    record.imageClassificationSummaryByteCount = summary.map { $0.utf8.count }
    record.imageClassificationSummarySHA256 = summary.map(sha256Hex)
    record.imageClassificationSummaryVersion = version
    record.imageClassificationSummarySourceKind = "ICAttachment.imageClassificationSummary"
    return record
  }

  private func attachmentMatches(_ attachment: AnyObject, selector: String) -> Bool {
    let record = attachmentRecord(attachment)
    return [
      record.id,
      record.contentIdentifier,
      record.mediaFilename,
      record.title,
    ].compactMap { $0 }
      .contains { $0 == selector }
  }

  private func selectedAttachment(
    in note: ICNote,
    noteID: String,
    selector: String
  ) throws -> (attachment: AnyObject, record: NotesAttachmentRecord) {
    let matches = attachmentObjects(note).filter {
      attachmentMatches($0, selector: selector)
    }
    guard let attachment = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the note.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "attachment_sha256": sha256Hex(selector),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments on the note.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "attachment_sha256": sha256Hex(selector),
          "match_count": "\(matches.count)",
        ]
      )
    }
    return (attachment, attachmentRecord(attachment))
  }

  private func attachmentData(_ attachment: AnyObject, record: NotesAttachmentRecord) throws -> Data {
    guard let media = optionalObject(attachment, key: "media") as? ICMedia else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment does not expose exportable Notes media data.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "type_uti": record.typeUTI ?? "",
        ]
      )
    }

    if let data = dataValue(media.decryptedData()) {
      return data
    }
    if let data = dataValue(media.data()) {
      return data
    }
    if let url = urlValue(media.mediaURL()) {
      return try Data(contentsOf: url)
    }

    throw CLIError(
      code: .unsupportedOperation,
      message: "Attachment data could not be read through NotesShared media APIs.",
      details: [
        "attachment_id_sha256": sha256Hex(record.id),
        "type_uti": record.typeUTI ?? "",
        "media_filename": record.mediaFilename ?? "",
        "attempted_paths": "ICMedia.decryptedData,ICMedia.data,ICMedia.mediaURL",
      ]
    )
  }

  private func attachmentPDFData(
    _ attachment: AnyObject,
    record: NotesAttachmentRecord
  ) throws -> (data: Data, sourceKind: String) {
    if let data = try? attachmentData(attachment, record: record), isPDFData(data) {
      return (data, "media_pdf")
    }

    if let cryptoStrategy = optionalObject(attachment, key: "cryptoStrategy") as? NSObject,
      let data = dataValue(performedObject(cryptoStrategy, selector: "decryptedFallbackPDFData")),
      isPDFData(data)
    {
      return (data, "fallback_pdf_crypto")
    }

    let selector = NSSelectorFromString("generateFallbackPDFDataForAttachment:")
    let paperBundleModel = ICAttachmentPaperBundleModel.self as AnyObject
    if paperBundleModel.responds(to: selector),
      let value = paperBundleModel.perform(selector, with: attachment)?.takeUnretainedValue(),
      let data = dataValue(value),
      isPDFData(data)
    {
      return (data, "paper_bundle_fallback_pdf")
    }

    if let generated = try docCamGeneratedPDFData(for: attachment) {
      return (generated, "doccam_generated_pdf")
    }

    throw CLIError(
      code: .unsupportedOperation,
      message: "Attachment does not expose PDF data through Notes private APIs.",
      details: [
        "attachment_id_sha256": sha256Hex(record.id),
        "type_uti": record.typeUTI ?? "",
        "media_filename": record.mediaFilename ?? "",
        "attempted_paths": "ICMedia PDF bytes,ICAttachmentCryptoStrategy.decryptedFallbackPDFData,ICAttachmentPaperBundleModel.generateFallbackPDFDataForAttachment,ICDocCamPDFGenerator PDF URL generation",
      ]
    )
  }

  private func docCamGeneratedPDFData(for attachment: AnyObject) throws -> Data? {
    let generator = ICDocCamPDFGenerator.self as AnyObject
    let selectors = [
      "generatePDFURLForAttachment:",
      "pdfURLForAttachment:",
    ]
    for selectorName in selectors {
      let selector = NSSelectorFromString(selectorName)
      guard generator.responds(to: selector),
        let value = generator.perform(selector, with: attachment)?.takeUnretainedValue()
      else {
        continue
      }
      if let data = dataValue(value), isPDFData(data) {
        return data
      }
      guard let url = fileURLValue(value) else {
        continue
      }
      guard let data = try? Data(contentsOf: url) else {
        continue
      }
      if isPDFData(data) {
        return data
      }
    }
    return nil
  }

  private func scanPDFInspectionSourceKinds(
    pdfSourceKind: String?,
    croppingQuad: AnyObject?,
    scannedDocumentsMetadata: AnyObject?,
    docCamPDFVersion: Int?,
    orientation: Int?,
    imageFilterType: Int?
  ) -> [String] {
    var sourceKinds: [String] = []
    if let pdfSourceKind {
      sourceKinds.append(pdfSourceKind)
    }
    if croppingQuad != nil {
      sourceKinds.append("ICAttachment.croppingQuad")
    }
    if scannedDocumentsMetadata != nil {
      sourceKinds.append("ICAttachment.scannedDocumentsMetadata")
    }
    if docCamPDFVersion != nil {
      sourceKinds.append("ICAttachment.docCamPDFVersion")
    }
    if orientation != nil {
      sourceKinds.append("ICAttachment.orientation")
    }
    if imageFilterType != nil {
      sourceKinds.append("ICAttachment.imageFilterType")
    }
    return sourceKinds
  }

  private func metadataObjectCount(_ value: AnyObject?) -> Int? {
    switch value {
    case let array as NSArray:
      return array.count
    case let set as NSSet:
      return set.count
    case let dictionary as NSDictionary:
      return dictionary.count
    default:
      return nil
    }
  }

  private func metadataDigest(_ value: AnyObject?) -> String? {
    guard let value else {
      return nil
    }
    if let data = metadataDigestData(value) {
      return sha256Hex(data)
    }
    return sha256Hex("\(type(of: value)):\(String(describing: value))")
  }

  private func metadataDigestData(_ value: Any) -> Data? {
    let normalized = normalizedMetadataValue(value)
    if JSONSerialization.isValidJSONObject(normalized),
      let data = try? JSONSerialization.data(withJSONObject: normalized, options: [.sortedKeys])
    {
      return data
    }
    if PropertyListSerialization.propertyList(normalized, isValidFor: .binary),
      let data = try? PropertyListSerialization.data(
        fromPropertyList: normalized,
        format: .binary,
        options: 0
      )
    {
      return data
    }
    return nil
  }

  private func normalizedMetadataValue(_ value: Any) -> Any {
    switch value {
    case let data as Data:
      return ["byteCount": data.count, "sha256": sha256Hex(data)]
    case let data as NSData:
      let swiftData = data as Data
      return ["byteCount": swiftData.count, "sha256": sha256Hex(swiftData)]
    case let date as Date:
      return date.timeIntervalSinceReferenceDate
    case let date as NSDate:
      return date.timeIntervalSinceReferenceDate
    case let url as URL:
      return ["url_sha256": sha256Hex(url.absoluteString)]
    case let url as NSURL:
      return ["url_sha256": sha256Hex(url.absoluteString ?? "")]
    case let string as NSString:
      return sha256Hex(string as String)
    case let number as NSNumber:
      return number
    case let array as NSArray:
      return array.map { normalizedMetadataValue($0) }
    case let set as NSSet:
      return set.allObjects.map { normalizedMetadataValue($0) }
        .sorted { String(describing: $0) < String(describing: $1) }
    case let dictionary as NSDictionary:
      var normalized: [String: Any] = [:]
      for key in dictionary.allKeys {
        normalized[String(describing: key)] = normalizedMetadataValue(dictionary[key] as Any)
      }
      return normalized
    default:
      return "\(type(of: value)):\(String(describing: value))"
    }
  }

  private func pdfPageCount(_ data: Data) -> Int? {
    #if canImport(PDFKit)
    return PDFDocument(data: data)?.pageCount
    #else
    return nil
    #endif
  }

  private func attachmentAudioDocument(_ attachment: AnyObject) -> (document: AnyObject, sourceKind: String)? {
    let candidates: [(sourceKind: String, object: AnyObject?)] = [
      ("ICAttachment.audioModel.audioDocument", optionalObject(attachment, key: "audioModel")),
      ("ICAttachment.attachmentModel.audioDocument", optionalObject(attachment, key: "attachmentModel")),
      ("ICAttachment.audioDocument", attachment),
    ]
    for candidate in candidates {
      guard let object = candidate.object,
        let document = optionalObject(object, key: "audioDocument")
      else {
        continue
      }
      return (document, candidate.sourceKind)
    }
    return nil
  }

  private var attachmentSearchableTextAttemptedPaths: String {
    [
      "ICAttachment.searchableTextContent",
      "ICAttachment.searchableTextContentWithoutTitle",
      "ICAttachment.attachmentModel.searchableTextContent",
      "ICAttachment.attachmentModel.searchableTextContentForLocation",
      "ICAttachment.attachmentModel.searchableTextContentInNote",
      "ICAttachment.attachmentModel.additionalIndexableTextContentInNote",
      "ICAttachment.attachmentModel.textContentInNote",
    ].joined(separator: ",")
  }

  private func attachmentSearchableTextContent(_ attachment: AnyObject)
    -> [NotesAttachmentSearchableTextContentSource]
  {
    var records: [NotesAttachmentSearchableTextContentSource] = []
    var seen: Set<String> = []
    let candidates: [(kind: String, sourceKind: String, value: Any?)] = [
      (
        "searchable_text",
        "ICAttachment.searchableTextContent",
        optionalValue(attachment, key: "searchableTextContent")
      ),
      (
        "searchable_text_without_title",
        "ICAttachment.searchableTextContentWithoutTitle",
        optionalValue(attachment, key: "searchableTextContentWithoutTitle")
      ),
    ]
    let modelCandidates = optionalObject(attachment, key: "attachmentModel").map { model in
      [
        (
          "model_searchable_text",
          "ICAttachment.attachmentModel.searchableTextContent",
          optionalValue(model, key: "searchableTextContent")
        ),
        (
          "location_searchable_text",
          "ICAttachment.attachmentModel.searchableTextContentForLocation",
          optionalValue(model, key: "searchableTextContentForLocation")
        ),
        (
          "note_searchable_text",
          "ICAttachment.attachmentModel.searchableTextContentInNote",
          optionalValue(model, key: "searchableTextContentInNote")
        ),
        (
          "additional_indexable_text",
          "ICAttachment.attachmentModel.additionalIndexableTextContentInNote",
          optionalValue(model, key: "additionalIndexableTextContentInNote")
        ),
        (
          "text_content_in_note",
          "ICAttachment.attachmentModel.textContentInNote",
          optionalValue(model, key: "textContentInNote")
        ),
      ]
    } ?? []

    for candidate in candidates + modelCandidates {
      for text in searchableTextStrings(from: candidate.value) {
        let key = "\(candidate.sourceKind)|\(sha256Hex(text))"
        guard seen.insert(key).inserted else {
          continue
        }
        records.append(
          NotesAttachmentSearchableTextContentSource(
            kind: candidate.kind,
            text: text,
            sourceKind: candidate.sourceKind
          ))
      }
    }
    return records
  }

  private func searchableTextStrings(from value: Any?) -> [String] {
    switch value {
    case let string as String:
      return [string].compactMap { nonEmpty($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    case let string as NSString:
      return [string as String].compactMap { nonEmpty($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    case let attributedString as NSAttributedString:
      return [attributedString.string].compactMap { nonEmpty($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    case let array as NSArray:
      return array.flatMap(searchableTextStrings)
    case let set as NSSet:
      return set.allObjects.flatMap(searchableTextStrings)
    default:
      return []
    }
  }

  private func markupModelData(from data: Data, record: NotesAttachmentRecord) throws -> Data? {
    let selector = NSSelectorFromString("markupModelDataFromData:")
    let utilities = ICMarkupUtilities.self as AnyObject
    guard utilities.responds(to: selector) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes Markup model reader is unavailable in the linked private framework.",
        details: [
          "attachment_id_sha256": sha256Hex(record.id),
          "type_uti": record.typeUTI ?? "",
          "media_filename": record.mediaFilename ?? "",
          "attempted_paths": "ICMarkupUtilities.markupModelDataFromData",
        ]
      )
    }
    guard let value = utilities.perform(selector, with: data as NSData)?.takeUnretainedValue() else {
      return nil
    }
    return dataValue(value)
  }

  private func dataValue(_ value: Any?) -> Data? {
    if let data = value as? Data {
      return data
    }
    if let data = value as? NSData {
      return Data(referencing: data)
    }
    return nil
  }

  private func urlValue(_ value: Any?) -> URL? {
    if let url = value as? URL {
      return url
    }
    if let url = value as? NSURL {
      return url as URL
    }
    return nil
  }

  private func fileURLValue(_ value: Any?) -> URL? {
    if let url = urlValue(value) {
      return url
    }
    if let path = value as? String {
      if let url = URL(string: path), url.isFileURL {
        return url
      }
      return URL(fileURLWithPath: path)
    }
    if let path = value as? NSString {
      let stringPath = path as String
      if let url = URL(string: stringPath), url.isFileURL {
        return url
      }
      return URL(fileURLWithPath: stringPath)
    }
    return nil
  }

  private func isPDFData(_ data: Data) -> Bool {
    data.count >= 4 && data.prefix(4) == Data("%PDF".utf8)
  }

  private func rtfdFiles(from fileWrapper: FileWrapper, path: String = "") throws
    -> [NotesNoteRTFDExportFile]
  {
    if fileWrapper.isRegularFile {
      guard let data = fileWrapper.regularFileContents else {
        throw CLIError(code: .unsupportedOperation, message: "RTFD file wrapper did not contain file data.")
      }
      let relativePath = try normalizedNotesRTFDRelativePath(
        path.isEmpty ? (nonEmpty(fileWrapper.preferredFilename) ?? "TXT.rtf") : path
      )
      return [NotesNoteRTFDExportFile(relativePath: relativePath, data: data)]
    }

    guard fileWrapper.isDirectory, let children = fileWrapper.fileWrappers else {
      throw CLIError(code: .unsupportedOperation, message: "RTFD file wrapper was not a directory package.")
    }

    var files: [NotesNoteRTFDExportFile] = []
    for (name, child) in children {
      let component = try normalizedNotesRTFDRelativePath(nonEmpty(child.preferredFilename) ?? name)
      let childPath = path.isEmpty ? component : "\(path)/\(component)"
      files.append(contentsOf: try rtfdFiles(from: child, path: childPath))
    }
    return try normalizedNotesRTFDExportFiles(files)
  }

  private func linkObjects(_ note: ICNote) -> [AnyObject] {
    anyObjects(note.allNoteTextInlineAttachments())
      .filter(isLinkObject)
  }

  private func isLinkObject(_ object: AnyObject) -> Bool {
    optionalBool(object, key: "isLinkAttachment") == true
      || optionalBool(object, key: "isParagraphLinkAttachment") == true
      || optionalBool(object, key: "isInternalParagraphLinkAttachment") == true
  }

  private func linkRecord(_ link: AnyObject) -> NotesLinkRecord {
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    let urlCandidate = linkURLCandidate(link: link, token: token)
    let scheme = linkURLScheme(urlCandidate)
    let paragraph = optionalBool(link, key: "isParagraphLinkAttachment") ?? false
    let internalParagraph = optionalBool(link, key: "isInternalParagraphLinkAttachment") ?? false

    return NotesLinkRecord(
      id: optionalString(link, key: "identifier") ?? objectIDString(link),
      kind: linkKind(urlString: urlCandidate, scheme: scheme, paragraph: paragraph, internalParagraph: internalParagraph),
      displayText: nonEmpty(optionalString(link, key: "displayText")),
      altText: nonEmpty(optionalString(link, key: "altText")),
      urlString: publicLinkURLString(urlCandidate),
      urlScheme: scheme,
      urlSHA256: urlCandidate.map(sha256Hex),
      tokenContentIdentifierSHA256: token.map(sha256Hex),
      typeUTI: nonEmpty(optionalString(link, key: "typeUTI")),
      createdAt: optionalDate(link, key: "creationDate"),
      isParagraphLink: paragraph,
      isInternalParagraphLink: internalParagraph
    )
  }

  private func linkDestinationRecord(_ link: AnyObject, record: NotesLinkRecord) -> NotesLinkDestinationRecord {
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    let urlCandidate = linkURLCandidate(link: link, token: token)
    let scheme = linkURLScheme(urlCandidate) ?? record.urlScheme
    let urlSHA256 = urlCandidate.map(sha256Hex) ?? record.urlSHA256
    let tokenSHA256 = token.map(sha256Hex) ?? record.tokenContentIdentifierSHA256

    if record.isParagraphLink || record.isInternalParagraphLink || record.kind == "paragraph"
      || record.kind == "internal_paragraph"
    {
      return noteDestinationRecord(
        kind: record.isInternalParagraphLink || record.kind == "internal_paragraph"
          ? "internal_paragraph"
          : "paragraph",
        urlString: urlCandidate,
        scheme: scheme,
        urlSHA256: urlSHA256,
        tokenSHA256: tokenSHA256,
        expectsParagraph: true
      )
    }

    if record.kind == "note" || ["notes", "applenotes", "mobilenotes"].contains(scheme ?? "") {
      return noteDestinationRecord(
        kind: "note",
        urlString: urlCandidate,
        scheme: scheme,
        urlSHA256: urlSHA256,
        tokenSHA256: tokenSHA256,
        expectsParagraph: false
      )
    }

    if scheme == "file" {
      return NotesLinkDestinationRecord(
        kind: "file",
        resolved: urlSHA256 != nil,
        urlScheme: scheme,
        urlSHA256: urlSHA256,
        tokenContentIdentifierSHA256: tokenSHA256,
        rawURLHidden: true
      )
    }

    if let scheme, isAppLinkScheme(scheme) {
      return NotesLinkDestinationRecord(
        kind: "app",
        resolved: urlSHA256 != nil,
        urlScheme: scheme,
        urlSHA256: urlSHA256,
        tokenContentIdentifierSHA256: tokenSHA256,
        rawURLHidden: true
      )
    }

    if let publicURLString = publicLinkURLString(urlCandidate) {
      return NotesLinkDestinationRecord(
        kind: "public_url",
        resolved: true,
        urlScheme: scheme,
        publicURLString: publicURLString,
        urlSHA256: urlSHA256,
        tokenContentIdentifierSHA256: tokenSHA256
      )
    }

    return NotesLinkDestinationRecord(
      kind: "unresolved",
      resolved: false,
      urlScheme: scheme,
      urlSHA256: urlSHA256,
      tokenContentIdentifierSHA256: tokenSHA256,
      warnings: ["unsupported_link_kind"]
    )
  }

  private func noteDestinationRecord(
    kind: String,
    urlString: String?,
    scheme: String?,
    urlSHA256: String?,
    tokenSHA256: String?,
    expectsParagraph: Bool
  ) -> NotesLinkDestinationRecord {
    guard let urlString, let url = URL(string: urlString) else {
      return NotesLinkDestinationRecord(
        kind: kind,
        resolved: false,
        urlScheme: scheme,
        urlSHA256: urlSHA256,
        tokenContentIdentifierSHA256: tokenSHA256,
        rawInternalTokenHidden: true,
        warnings: ["missing_internal_link_token"]
      )
    }

    let noteID = noteIdentifierFromNotesAppURL(url)
    var targetNoteID: String?
    if let noteID, let note = try? frameworkNote(id: noteID) {
      targetNoteID = noteIdentifier(note)
    }
    let paragraphIDSHA256 = expectsParagraph
      ? paragraphIDForNotesAppURL(url).map(sha256Hex)
      : nil
    var warnings: [String] = []
    if noteID != nil && targetNoteID == nil {
      warnings.append("target_note_not_visible")
    }
    if expectsParagraph && paragraphIDSHA256 == nil {
      warnings.append("target_paragraph_not_resolved")
    }

    return NotesLinkDestinationRecord(
      kind: kind,
      resolved: targetNoteID != nil && (!expectsParagraph || paragraphIDSHA256 != nil),
      urlScheme: scheme,
      urlSHA256: urlSHA256,
      targetNoteID: targetNoteID,
      targetNoteIDSHA256: (targetNoteID ?? noteID).map(sha256Hex),
      targetParagraphIDSHA256: paragraphIDSHA256,
      tokenContentIdentifierSHA256: tokenSHA256,
      rawInternalTokenHidden: true,
      warnings: warnings
    )
  }

  private func noteIdentifierFromNotesAppURL(_ url: URL) -> String? {
    let selector = NSSelectorFromString("noteIdentifierFromNotesAppURL:")
    let utilities = ICAppURLUtilities.self as AnyObject
    guard utilities.responds(to: selector) else {
      return nil
    }
    return nonEmpty(utilities.perform(selector, with: url as NSURL)?
      .takeUnretainedValue() as? String)
  }

  private func paragraphIDForNotesAppURL(_ url: URL) -> String? {
    let selector = NSSelectorFromString("paragraphIDForURL:")
    let utilities = ICAppURLUtilities.self as AnyObject
    guard utilities.responds(to: selector) else {
      return nil
    }
    return nonEmpty(utilities.perform(selector, with: url as NSURL)?
      .takeUnretainedValue() as? String)
  }

  private func backlinkRecord(_ link: AnyObject) -> NotesBacklinkRecord? {
    guard let sourceNote = optionalObject(link, key: "note") as? ICNote else {
      return nil
    }
    return NotesBacklinkRecord(sourceNote: noteSummary(sourceNote), link: linkRecord(link))
  }

  private func backlinkLinkObjects(from value: Any?) -> [AnyObject] {
    if let values = value as? [AnyObject] {
      return values
    }
    if let values = value as? NSArray {
      return values.compactMap { $0 as AnyObject }
    }
    if let values = value as? NSSet {
      return values.allObjects.compactMap { $0 as AnyObject }
    }
    guard let object = value as AnyObject? else {
      return []
    }
    return [object]
  }

  private func compareBacklinks(_ lhs: NotesBacklinkRecord, _ rhs: NotesBacklinkRecord) -> Bool {
    if lhs.sourceNote.id == rhs.sourceNote.id {
      return lhs.link.id.localizedStandardCompare(rhs.link.id) == .orderedAscending
    }
    if lhs.sourceNote.title == rhs.sourceNote.title {
      return lhs.sourceNote.id.localizedStandardCompare(rhs.sourceNote.id) == .orderedAscending
    }
    return lhs.sourceNote.title.localizedStandardCompare(rhs.sourceNote.title) == .orderedAscending
  }

  private func linkURLCandidate(link: AnyObject, token: String?) -> String? {
    nonEmpty(optionalString(link, key: "urlString"))
      ?? optionalURLString(link, key: "URL")
      ?? token.flatMap { linkURLScheme($0) == nil ? nil : $0 }
  }

  private func linkKind(
    urlString: String?,
    scheme: String?,
    paragraph: Bool,
    internalParagraph: Bool
  ) -> String {
    if internalParagraph {
      return "internal_paragraph"
    }
    if paragraph {
      return "paragraph"
    }
    if let scheme, ["notes", "applenotes", "mobilenotes"].contains(scheme) {
      return "note"
    }
    if let scheme, isAppLinkScheme(scheme) {
      return "app"
    }
    if urlString != nil {
      return "url"
    }
    return "link"
  }

  private func isAppLinkScheme(_ scheme: String) -> Bool {
    !["http", "https", "mailto", "tel", "sms", "file", "notes", "applenotes", "mobilenotes"]
      .contains(scheme.lowercased())
  }

  private func publicLinkURLString(_ urlString: String?) -> String? {
    guard let urlString, let scheme = linkURLScheme(urlString) else {
      return nil
    }
    return ["http", "https", "mailto", "tel", "sms"].contains(scheme) ? urlString : nil
  }

  private func linkRecordMatches(_ link: NotesLinkRecord, selector: String) -> Bool {
    [
      link.id,
      link.displayText,
      link.altText,
      link.urlString,
      link.urlSHA256,
      link.tokenContentIdentifierSHA256,
    ].compactMap { $0 }
      .contains { $0 == selector }
      || normalizedLinkURLForMatching(link.urlString) == normalizedLinkURLForMatching(selector)
  }

  private func normalizedLinkURLForMatching(_ value: String?) -> String? {
    guard let value, let url = URL(string: value) else {
      return value
    }
    return url.absoluteString
  }

  private func linkURLScheme(_ urlString: String?) -> String? {
    guard let urlString, let url = URL(string: urlString), let scheme = url.scheme else {
      return nil
    }
    return scheme.localizedLowercase
  }

  private func bodyStructureRecord(_ note: ICNote) -> NotesBodyStructureRecord {
    let passwordProtected = note.isPasswordProtected
    let plainText = passwordProtected ? nil : plainTextBody(note)
    let attributedString = passwordProtected ? nil : note.attributedString() as? NSAttributedString
    let attributeSummary = attributedString.map(bodyAttributeSummary) ?? BodyAttributeSummary()
    let inlineAttachments = passwordProtected ? [] : anyObjects(note.allNoteTextInlineAttachments())
    let attachmentKindCounts = mergedAttachmentKindCounts(
      attributeSummary.attachmentKindCounts,
      inlineAttachments: inlineAttachments
    )
    let tableCount = max(attributeSummary.tableCount, attachmentKindCounts["table"] ?? 0)
    let mathAttachmentCount = max(
      attributeSummary.mathAttachmentCount,
      inlineAttachments.filter(isMathAttachmentObject).count
    )

    let paragraphAnchors = passwordProtected ? [] : paragraphAnchorResolutions(note)
    let collapsibleSections = passwordProtected
      ? (collapsible: 0, collapsed: 0)
      : collapsibleSectionCounts(note: note, paragraphs: paragraphAnchors)

    return NotesBodyStructureRecord(
      noteID: noteIdentifier(note),
      isPasswordProtected: passwordProtected,
      plainTextByteCount: plainText?.utf8.count,
      plainTextSHA256: plainText.map(sha256Hex),
      richTextLength: attributedString?.length,
      paragraphCount: plainText.map(paragraphCount),
      paragraphStyleRunCount: attributeSummary.paragraphStyleRunCount,
      headingCount: attributeSummary.headingCount,
      listItemCount: attributeSummary.listItemCount,
      checklistItemCount: attributeSummary.checklistItemCount,
      checklistDoneCount: attributeSummary.checklistDoneCount,
      checklistOpenCount: attributeSummary.checklistOpenCount,
      blockQuoteCount: attributeSummary.blockQuoteCount,
      tableCount: tableCount,
      collapsibleSectionCount: collapsibleSections.collapsible,
      collapsedSectionCount: collapsibleSections.collapsed,
      inlineAttachmentCount: max(attributeSummary.inlineAttachmentCount, inlineAttachments.count),
      linkCount: linkObjects(note).count,
      attachmentCount: attachmentObjects(note).count,
      mathAttachmentCount: mathAttachmentCount,
      inlineFormatRunCount: attributeSummary.inlineFormatRunCount,
      boldRunCount: attributeSummary.boldRunCount,
      italicRunCount: attributeSummary.italicRunCount,
      underlineRunCount: attributeSummary.underlineRunCount,
      strikethroughRunCount: attributeSummary.strikethroughRunCount,
      fontRunCount: attributeSummary.fontRunCount,
      foregroundColorRunCount: attributeSummary.foregroundColorRunCount,
      highlightRunCount: attributeSummary.highlightRunCount,
      hasChecklist: optionalBool(note, key: "hasChecklist") ?? false,
      hasChecklistInProgress: optionalBool(note, key: "hasChecklistInProgress") ?? false,
      isMathNote: optionalBool(note, key: "isMathNote") ?? false,
      styleCounts: styleCountRecords(attributeSummary.styleCounts),
      attachmentKindCounts: attachmentKindCountRecords(attachmentKindCounts),
      inlineFormatCounts: inlineFormatCountRecords(attributeSummary.inlineFormatCounts),
      colorHashCounts: colorHashCountRecords(attributeSummary.colorHashCounts),
      inlineFormatRuns: attributeSummary.inlineFormatRuns,
      colorRuns: attributeSummary.colorRuns,
      mentionUserIDSHA256s: mentionUserIDSHA256s(inlineAttachments),
      paragraphAnchors: paragraphAnchors.map(\.anchor)
    )
  }

  private func bodyTableRecords(_ note: ICNote) -> [NotesBodyTableRecord] {
    guard let attributedString = note.attributedString() as? NSAttributedString else {
      return []
    }

    var records: [NotesBodyTableRecord] = []
    var seen = Set<String>()
    attributedString.enumerateAttributes(
      in: NSRange(location: 0, length: attributedString.length),
      options: []
    ) { attributes, _, _ in
      for value in attributes.values {
        guard let object = value as AnyObject?,
          bodyAttachmentKind(object) == "table"
        else {
          continue
        }
        let identity = tableIdentity(object)
        guard seen.insert(identity).inserted else {
          continue
        }
        records.append(bodyTableRecord(object, ordinal: records.count + 1, identity: identity))
      }
    }
    return records
  }

  private func bodyMathResultRecords(_ note: ICNote) -> [NotesBodyMathResultRecord] {
    var records: [NotesBodyMathResultRecord] = []
    var seen = Set<String>()
    for attachment in anyObjects(note.allNoteTextInlineAttachments()) {
      guard isMathResultAttachmentObject(attachment) else {
        continue
      }
      let identity = mathResultIdentity(attachment)
      guard seen.insert(identity).inserted else {
        continue
      }
      records.append(bodyMathResultRecord(attachment, ordinal: records.count + 1, identity: identity))
    }
    return records
  }

  private func bodyMathResultsPreferenceRecord(_ note: ICNote) -> NotesBodyMathResultsPreferenceRecord {
    let rawValue = Int(note.calculatePreviewBehavior())
    let mode = bodyMathResultsPreferenceMode(rawValue: rawValue)
    let userDefaultsKey = note.calculatePreviewBehaviorUserDefaultsKey() as? String
    return NotesBodyMathResultsPreferenceRecord(
      mode: mode,
      rawValue: rawValue,
      valueSHA256: NotesBodyMathResultsPreferenceDraft.valueSHA256(mode: mode, rawValue: rawValue),
      userDefaultsKeySHA256: nonEmpty(userDefaultsKey).map(sha256Hex),
      sourceKind: "ICNote.calculatePreviewBehavior"
    )
  }

  private func bodyMathResultsPreferenceMode(rawValue: Int) -> String {
    switch rawValue {
    case 2:
      return "insert"
    case 0:
      return "suggest"
    case 1:
      return "off"
    default:
      return "unknown"
    }
  }

  private func bodyTableTarget(
    _ note: ICNote,
    ordinal: Int,
    operation: String
  ) throws -> (record: NotesBodyTableRecord, table: AnyObject) {
    guard ordinal > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table ordinal must be positive.",
        details: ["operation": operation]
      )
    }
    guard let attributedString = note.attributedString() as? NSAttributedString else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: ["operation": operation, "ordinal": "\(ordinal)", "table_count": "0"]
      )
    }

    var targets: [(record: NotesBodyTableRecord, table: AnyObject)] = []
    var seen = Set<String>()
    attributedString.enumerateAttributes(
      in: NSRange(location: 0, length: attributedString.length),
      options: []
    ) { attributes, _, _ in
      for value in attributes.values {
        guard let object = value as AnyObject?,
          bodyAttachmentKind(object) == "table"
        else {
          continue
        }
        let identity = tableIdentity(object)
        guard seen.insert(identity).inserted else {
          continue
        }
        let attachment = tableBackingAttachment(object)
        guard let table = tableObject(tableAttachment: object, backingAttachment: attachment) else {
          continue
        }
        targets.append((bodyTableRecord(object, ordinal: targets.count + 1, identity: identity), table))
      }
    }

    guard ordinal <= targets.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "operation": operation,
          "ordinal": "\(ordinal)",
          "table_count": "\(targets.count)",
        ]
      )
    }
    return targets[ordinal - 1]
  }

  private func validateTableCellCoordinate(
    _ table: NotesBodyTableRecord,
    row: Int,
    column: Int,
    operation: String
  ) throws {
    guard row > 0, column > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table row and column must be positive.",
        details: ["operation": operation]
      )
    }
    if let rowCount = table.rowCount, row > rowCount {
      throw CLIError(
        code: .validationError,
        message: "Notes body table row is outside the selected table.",
        details: ["operation": operation, "row": "\(row)", "row_count": "\(rowCount)"]
      )
    }
    if let columnCount = table.columnCount, column > columnCount {
      throw CLIError(
        code: .validationError,
        message: "Notes body table column is outside the selected table.",
        details: ["operation": operation, "column": "\(column)", "column_count": "\(columnCount)"]
      )
    }
  }

  private func bodyMathResultRecord(
    _ object: AnyObject,
    ordinal: Int,
    identity: String
  ) -> NotesBodyMathResultRecord {
    let attachmentID = nonEmpty(optionalString(object, key: "identifier"))
      ?? nonEmpty(optionalString(object, key: "attachmentIdentifier"))
    let contentIdentifier = nonEmpty(optionalString(object, key: "contentIdentifier"))
      ?? nonEmpty(optionalString(object, key: "tokenContentIdentifier"))
    let typeUTI = nonEmpty(optionalString(object, key: "typeUTI"))
      ?? nonEmpty(optionalString(object, key: "attachmentUTI"))
    let result = mathResultText(object)
    let expression = nonEmpty(optionalString(object, key: "expression"))
      ?? nonEmpty(optionalString(object, key: "altText"))

    return NotesBodyMathResultRecord(
      ordinal: ordinal,
      idSHA256: sha256Hex(identity),
      attachmentIDSHA256: attachmentID.map(sha256Hex),
      contentIdentifierSHA256: contentIdentifier.map(sha256Hex),
      typeUTISHA256: typeUTI.map(sha256Hex),
      resultByteCount: result?.utf8.count,
      resultSHA256: result.map(sha256Hex),
      expressionByteCount: expression?.utf8.count,
      expressionSHA256: expression.map(sha256Hex),
      isValid: optionalBool(object, key: "validCalculateAttachment")
        ?? optionalBool(object, key: "isValidCalculateAttachment"),
      isRightToLeft: optionalBool(object, key: "rightToLeftCalculateAttachment")
        ?? optionalBool(object, key: "isRightToLeftCalculateAttachment")
    )
  }

  private func mathResultIdentity(_ object: AnyObject) -> String {
    [
      nonEmpty(optionalString(object, key: "identifier")),
      nonEmpty(optionalString(object, key: "contentIdentifier")),
      nonEmpty(optionalString(object, key: "tokenContentIdentifier")),
      Optional(objectIDString(object)),
    ].compactMap { $0 }.first ?? objectIDString(object)
  }

  private func mathResultText(_ object: AnyObject) -> String? {
    nonEmpty(optionalString(object, key: "displayText"))
      ?? nonEmpty(optionalString(object, key: "calculateState"))
      ?? nonEmpty(optionalString(object, key: "altText"))
      ?? nonEmpty(optionalString(object, key: "nonNilAltText"))
  }

  private func bodyTableRecord(_ object: AnyObject, ordinal: Int, identity: String) -> NotesBodyTableRecord {
    let attachment = tableBackingAttachment(object)
    let table = tableObject(tableAttachment: object, backingAttachment: attachment)
    let attachmentID = attachment.flatMap { nonEmpty(optionalString($0, key: "identifier")) }
      ?? nonEmpty(optionalString(object, key: "attachmentIdentifier"))
    let contentIdentifier = attachment.flatMap { nonEmpty(optionalString($0, key: "contentIdentifier")) }
    let typeUTI = attachment.flatMap { nonEmpty(optionalString($0, key: "typeUTI")) }
      ?? nonEmpty(optionalString(object, key: "attachmentUTI"))
    let isDeletable = attachment.flatMap { optionalBool($0, key: "isDeletable") }

    return NotesBodyTableRecord(
      ordinal: ordinal,
      idSHA256: sha256Hex(identity),
      attachmentIDSHA256: attachmentID.map(sha256Hex),
      contentIdentifierSHA256: contentIdentifier.map(sha256Hex),
      typeUTISHA256: typeUTI.map(sha256Hex),
      rowCount: table.flatMap { optionalInt($0, key: "rowCount") },
      columnCount: table.flatMap { optionalInt($0, key: "columnCount") },
      isDeletable: isDeletable
    )
  }

  private func tableIdentity(_ object: AnyObject) -> String {
    let attachment = tableBackingAttachment(object)
    return [
      nonEmpty(optionalString(object, key: "attachmentIdentifier")),
      attachment.flatMap { nonEmpty(optionalString($0, key: "identifier")) },
      attachment.flatMap { nonEmpty(optionalString($0, key: "contentIdentifier")) },
      attachment.map(objectIDString),
      Optional(objectIDString(object)),
    ].compactMap { $0 }.first ?? objectIDString(object)
  }

  private func tableBackingAttachment(_ object: AnyObject) -> AnyObject? {
    optionalObject(object, key: "attachment")
      ?? optionalObject(object, key: "representedObject")
  }

  private func tableObject(tableAttachment: AnyObject, backingAttachment: AnyObject?) -> AnyObject? {
    optionalObject(tableAttachment, key: "table")
      ?? backingAttachment.flatMap { optionalObject($0, key: "table") }
      ?? backingAttachment.flatMap { optionalObject($0, key: "attachmentModel") }
        .flatMap { optionalObject($0, key: "table") }
  }

  private func tableCellString(
    _ table: AnyObject,
    row: Int,
    column: Int,
    operation: String
  ) throws -> String {
    guard row > 0, column > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table row and column must be positive.",
        details: ["operation": operation]
      )
    }
    let selector = NSSelectorFromString("stringForColumnIndex:rowIndex:")
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      throw CLIError(
        code: .backendUnavailable,
        message: "ICTable.stringForColumnIndex:rowIndex: is unavailable.",
        details: ["operation": operation]
      )
    }
    typealias TableCellStringIMP = @convention(c) (AnyObject, Selector, Int, Int) -> Unmanaged<AnyObject>?
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: TableCellStringIMP.self)
    let value = function(table, selector, column - 1, row - 1)?.takeUnretainedValue()
    switch value {
    case let string as String:
      return string
    case let string as NSString:
      return string as String
    case .none:
      return ""
    default:
      return "\(value!)"
    }
  }

  private func tableCellAttributedString(
    _ table: AnyObject,
    row: Int,
    column: Int,
    operation: String
  ) -> NSAttributedString? {
    if let columnID = tableIdentifier(table, selectorName: "identifierForColumnAtIndex:", index: column, operation: operation),
      let rowID = tableIdentifier(table, selectorName: "identifierForRowAtIndex:", index: row, operation: operation),
      let mergeable = tableMergeableString(table, columnID: columnID, rowID: rowID, operation: operation),
      let attributedString = attributedStringValue(mergeable)
    {
      return attributedString
    }
    if let object = tableCellObject(table, row: row, column: column, operation: operation),
      let attributedString = attributedStringValue(object)
    {
      return attributedString
    }
    return nil
  }

  private func tableIdentifier(
    _ table: AnyObject,
    selectorName: String,
    index: Int,
    operation: String
  ) -> AnyObject? {
    let selector = NSSelectorFromString(selectorName)
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      return nil
    }
    typealias TableIdentifierIMP = @convention(c) (AnyObject, Selector, Int) -> Unmanaged<AnyObject>?
    let function = unsafeBitCast(method_getImplementation(method), to: TableIdentifierIMP.self)
    return function(table, selector, index - 1)?.takeUnretainedValue()
  }

  private func tableMergeableString(
    _ table: AnyObject,
    columnID: AnyObject,
    rowID: AnyObject,
    operation: String
  ) -> AnyObject? {
    let selector = NSSelectorFromString("mergeableStringForColumnID:rowID:")
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      return nil
    }
    typealias TableMergeableStringIMP = @convention(c) (AnyObject, Selector, AnyObject, AnyObject) -> Unmanaged<AnyObject>?
    let function = unsafeBitCast(method_getImplementation(method), to: TableMergeableStringIMP.self)
    return function(table, selector, columnID, rowID)?.takeUnretainedValue()
  }

  private func tableCellObject(
    _ table: AnyObject,
    row: Int,
    column: Int,
    operation: String
  ) -> AnyObject? {
    let selector = NSSelectorFromString("objectForColumnIndex:rowIndex:")
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      return nil
    }
    typealias TableCellObjectIMP = @convention(c) (AnyObject, Selector, Int, Int) -> Unmanaged<AnyObject>?
    let function = unsafeBitCast(method_getImplementation(method), to: TableCellObjectIMP.self)
    return function(table, selector, column - 1, row - 1)?.takeUnretainedValue()
  }

  private func attributedStringValue(_ object: AnyObject) -> NSAttributedString? {
    if let attributedString = object as? NSAttributedString {
      return attributedString
    }
    return (optionalObject(object, key: "editsAttributedString") as? NSAttributedString)
      ?? (optionalObject(object, key: "attributedString") as? NSAttributedString)
  }

  private func tableCellFormatSummary(_ attributedString: NSAttributedString?) -> TableCellFormatSummary? {
    guard let attributedString else {
      return nil
    }
    let fullRange = NSRange(location: 0, length: attributedString.length)
    guard fullRange.length > 0 else {
      return TableCellFormatSummary(
        formatRunCount: 0,
        formatSHA256: sha256Hex("empty"),
        containsBold: false,
        containsItalic: false,
        containsUnderline: false,
        containsStrikethrough: false
      )
    }

    var runCount = 0
    var containsBold = false
    var containsItalic = false
    var containsUnderline = false
    var containsStrikethrough = false
    var pieces: [String] = []
    attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
      let formats = inlineFormatKinds(attributes)
      if formats.isEmpty == false {
        runCount += 1
      }
      containsBold = containsBold || formats.contains("bold")
      containsItalic = containsItalic || formats.contains("italic")
      containsUnderline = containsUnderline || formats.contains("underline")
      containsStrikethrough = containsStrikethrough || formats.contains("strikethrough")
      let colorHashes = inlineColorHashes(attributes)
        .map { "\($0.role):\($0.hash)" }
        .sorted()
        .joined(separator: ",")
      let fontHash = (attributes[.font] as? NSFont).map(notesFontSHA256) ?? ""
      pieces.append("\(range.location):\(range.length):\(formats.sorted().joined(separator: ",")):\(fontHash):\(colorHashes)")
    }
    return TableCellFormatSummary(
      formatRunCount: runCount,
      formatSHA256: sha256Hex(pieces.joined(separator: "|")),
      containsBold: containsBold,
      containsItalic: containsItalic,
      containsUnderline: containsUnderline,
      containsStrikethrough: containsStrikethrough
    )
  }

  private func noteStateRecord(_ note: ICNote) -> NotesNoteStateRecord {
    let folder = note.folder as? ICFolder
    let account = optionalObject(note, key: "account")
    let accountData = account.flatMap { optionalObject($0, key: "accountData") }
    let lockedNotesMode = accountData.flatMap { optionalInt($0, key: "lockedNotesMode") }
    let resolvedLockedNotesMode = account.flatMap { optionalInt($0, key: "resolvedLockedNotesMode") }
    let needsCloudFetch = [
      optionalBool(note, key: "needsToBeFetchedFromCloud"),
      optionalBool(note, key: "needsInitialFetchFromCloud"),
    ].contains(true)

    return NotesNoteStateRecord(
      noteID: noteIdentifier(note),
      isDeletedOrInTrash: note.isDeletedOrInTrash,
      isPinned: note.isPinned,
      isPinnable: optionalBool(note, key: "isPinnable"),
      isPasswordProtected: note.isPasswordProtected,
      isPasswordProtectedAndLocked: optionalBool(note, key: "isPasswordProtectedAndLocked"),
      isEditable: optionalBool(note, key: "isEditable") ?? false,
      isLockable: optionalBool(note, key: "isLockable") ?? false,
      isSharedViaICloud: optionalBool(note, key: "isSharedViaICloud") ?? false,
      isSharedViaICloudFolder: optionalBool(note, key: "isSharedViaICloudFolder") ?? false,
      isSharedReadOnly: optionalBool(note, key: "isSharedReadOnly") ?? false,
      isSystemPaper: optionalBool(note, key: "isSystemPaper") ?? false,
      isMathNote: optionalBool(note, key: "isMathNote") ?? false,
      isCallNote: optionalBool(note, key: "isCallNote") ?? false,
      hasUnreadChanges: optionalBool(note, key: "hasUnreadChanges"),
      isUnsupported: optionalBool(note, key: "isUnsupported"),
      needsCloudFetch: needsCloudFetch,
      sharedNoteAlertsHidden: sharedNoteAlertsHidden(note),
      participantCount: objectCount(optionalObject(note, key: "participants")),
      participantUserIDSHA256s: participantUserIDSHA256s(from: optionalObject(note, key: "participants")),
      accountCanPasswordProtectNotes: account.flatMap { optionalBool($0, key: "canPasswordProtectNotes") },
      accountCanHaveCryptoStrategy: account.flatMap { optionalBool($0, key: "canHaveCryptoStrategy") },
      accountIsInICloud: account.flatMap { optionalBool($0, key: "isInICloudAccount") },
      accountIsLocal: account.flatMap { optionalBool($0, key: "isLocalAccount") },
      accountLockedNotesModeSHA256: lockedNotesMode.map { sha256Hex("locked_notes_mode:\($0)") },
      accountResolvedLockedNotesModeSHA256: resolvedLockedNotesMode.map {
        sha256Hex("resolved_locked_notes_mode:\($0)")
      },
      accountPasswordProtectedNoteCount: account.flatMap {
        objectCount(optionalObject($0, key: "passwordProtectedNotes"))
      },
      folderID: folder.map(objectIDString),
      folderIsTrash: folder.flatMap { optionalBool($0, key: "isTrashFolder") },
      folderIsDefault: folder.flatMap { optionalBool($0, key: "isDefaultFolderForAccount") },
      folderIsSharedViaICloud: folder.flatMap { optionalBool($0, key: "isSharedViaICloud") },
      folderIsSharedReadOnly: folder.flatMap { optionalBool($0, key: "isSharedReadOnly") }
    )
  }

  private func sharedNoteAlertsHidden(_ note: ICNote) -> Bool? {
    let participantCount = objectCount(optionalObject(note, key: "participants")) ?? 0
    let isShared = optionalBool(note, key: "isSharedViaICloud") == true
      || optionalBool(note, key: "isSharedViaICloudFolder") == true
      || participantCount > 0
    guard isShared, let recordID = optionalObject(note, key: "recordID") else {
      return nil
    }
    return ICShareNotifier.shouldPreventNotifications(forRecordID: recordID)
  }

  private func collaborationLinkResult(
    targetKind: String,
    targetID: String,
    object: AnyObject,
    wasShared: Bool,
    participantCount: Int?,
    selectorHash: String
  ) throws -> NotesCollaborationLinkReadResult {
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration link copy requires an already shared note or folder.",
        details: [
          "operation": "notes.state.copy-link",
          "capability": "collaboration_link_access",
          "required_state": "shared",
          "\(targetKind)_id_sha256": selectorHash,
          "backend_calls": "private_framework_share_readback_only",
        ]
      )
    }

    guard let share = collaborationShareObject(for: object),
      let urlString = collaborationShareURLString(share)
    else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration link copy requires private share URL readback.",
        details: [
          "operation": "notes.state.copy-link",
          "capability": "collaboration_link_access",
          "required_private_field": "serverShare.url",
          "\(targetKind)_id_sha256": selectorHash,
          "backend_calls": "private_framework_share_readback_only",
        ]
      )
    }

    let urlData = Data(urlString.utf8)
    return NotesCollaborationLinkReadResult(
      targetKind: targetKind,
      targetID: targetID,
      urlString: urlString,
      urlSHA256: sha256Hex(urlData),
      urlByteCount: urlData.count,
      shareRecordIDSHA256: collaborationShareRecordHash(share, fallbackObject: object),
      ownerRecordNameSHA256: collaborationOwnerRecordNameHash(share, fallbackObject: object),
      wasShared: wasShared,
      participantCount: participantCount
    )
  }

  private func collaborationShareObject(for object: AnyObject) -> AnyObject? {
    optionalObject(object, key: "serverShareCheckingParent")
      ?? optionalObject(object, key: "serverShare")
  }

  private func collaborationShareURLString(_ share: AnyObject) -> String? {
    if let url = optionalObject(share, key: "url") as? URL {
      return nonEmpty(url.absoluteString)
    }
    if let url = optionalObject(share, key: "URL") as? URL {
      return nonEmpty(url.absoluteString)
    }
    return nonEmpty(optionalString(share, key: "url"))
      ?? nonEmpty(optionalString(share, key: "URL"))
  }

  private func collaborationShareRecordHash(_ share: AnyObject, fallbackObject: AnyObject) -> String? {
    let recordID = optionalObject(share, key: "recordID")
      ?? optionalObject(fallbackObject, key: "recordID")
    return recordID.map { sha256Hex(String(describing: $0)) }
  }

  private func collaborationOwnerRecordNameHash(_ share: AnyObject, fallbackObject: AnyObject) -> String? {
    let owner = nonEmpty(optionalString(share, key: "ownerRecordName"))
      ?? nonEmpty(optionalString(fallbackObject, key: "ownerRecordName"))
      ?? nonEmpty(optionalString(fallbackObject, key: "sharedOwnerRecordName"))
    return owner.map(sha256Hex)
  }

  private func collaborationShareParticipantCount(_ share: AnyObject) -> Int? {
    objectCount(optionalObject(share, key: "participants"))
      ?? objectCount(optionalObject(share, key: "ic_nonCurrentUserParticipants"))
      ?? objectCount(optionalObject(share, key: "ic_acceptedParticipants"))
  }

  private func collaborationParticipantsResult(
    targetKind: String,
    targetHash: String,
    object: AnyObject,
    share: AnyObject?,
    wasShared: Bool,
    isReadOnly: Bool?,
    participantCount: Int,
    participants: [NotesCollaborationParticipantRecord],
    selectorHash: String
  ) throws -> NotesCollaborationParticipantsReadResult {
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration participant metadata requires an already shared note or folder.",
        details: [
          "operation": "notes.state.participants",
          "capability": "collaboration_participant_access_metadata",
          "required_state": "shared",
          "\(targetKind)_id_sha256": selectorHash,
          "backend_calls": "private_framework_share_readback_only",
        ]
      )
    }

    let publicPermission = share.flatMap { collaborationOptionalInt($0, keys: ["publicPermission"]) }
    let participantHashes = participants.map(\.participantIDSHA256).sorted()
    return NotesCollaborationParticipantsReadResult(
      targetKind: targetKind,
      targetIDSHA256: targetHash,
      wasShared: wasShared,
      isReadOnly: isReadOnly,
      shareRecordIDSHA256: share.flatMap { collaborationShareRecordHash($0, fallbackObject: object) },
      ownerRecordNameSHA256: share.flatMap { collaborationOwnerRecordNameHash($0, fallbackObject: object) },
      publicPermissionValue: publicPermission,
      publicPermissionLabel: collaborationPermissionLabel(publicPermission),
      participantCount: max(participantCount, participants.count),
      participantIdentitySetSHA256: sha256Hex(participantHashes.joined(separator: "\n")),
      participants: participants
    )
  }

  private func collaborationParticipantRecords(
    object: AnyObject,
    share: AnyObject?
  ) -> [NotesCollaborationParticipantRecord] {
    let objectParticipants = anyObjects(optionalObject(object, key: "participants"))
    let shareParticipants = share.map { anyObjects(optionalObject($0, key: "participants")) } ?? []
    var unique: [NotesCollaborationParticipantRecord] = []
    var seen = Set<String>()
    for participant in objectParticipants + shareParticipants {
      let record = collaborationParticipantRecord(participant, ordinal: unique.count + 1)
      guard seen.insert(record.participantIDSHA256).inserted else {
        continue
      }
      unique.append(record)
    }
    return unique
  }

  private func collaborationParticipantRecord(
    _ participant: AnyObject,
    ordinal: Int
  ) -> NotesCollaborationParticipantRecord {
    let userHashes = participantUserIDSHA256s(from: participant)
    let participantHash = userHashes.isEmpty
      ? sha256Hex(String(describing: participant))
      : sha256Hex(userHashes.sorted().joined(separator: "\n"))
    let permission = collaborationOptionalInt(participant, keys: ["permission"])
    let role = collaborationOptionalInt(participant, keys: ["role"])
    let acceptanceStatus = collaborationOptionalInt(participant, keys: ["acceptanceStatus"])
    return NotesCollaborationParticipantRecord(
      ordinal: ordinal,
      participantIDSHA256: participantHash,
      userRecordNameSHA256s: userHashes,
      permissionValue: permission,
      permissionLabel: collaborationPermissionLabel(permission),
      roleValue: role,
      roleLabel: collaborationRoleLabel(role),
      acceptanceStatusValue: acceptanceStatus,
      acceptanceStatusLabel: collaborationAcceptanceStatusLabel(acceptanceStatus),
      isCurrentUser: collaborationOptionalBool(participant, keys: ["isCurrentUser"])
    )
  }

  private func collaborationOptionalInt(_ object: AnyObject, keys: [String]) -> Int? {
    for key in keys {
      if let value = optionalInt(object, key: key) {
        return value
      }
    }
    return nil
  }

  private func collaborationOptionalBool(_ object: AnyObject, keys: [String]) -> Bool? {
    for key in keys {
      if let value = optionalBool(object, key: key) {
        return value
      }
    }
    return nil
  }

  private func collaborationPermissionLabel(_ value: Int?) -> String? {
    guard let value else {
      return nil
    }
    switch value {
    case 0: return "unknown"
    case 1: return "none"
    case 2: return "read-only"
    case 3: return "read-write"
    default: return "unrecognized-\(value)"
    }
  }

  private func collaborationRoleLabel(_ value: Int?) -> String? {
    guard let value else {
      return nil
    }
    switch value {
    case 0: return "unknown"
    case 1: return "owner"
    case 2: return "administrator"
    case 3: return "private-user"
    case 4: return "public-user"
    default: return "unrecognized-\(value)"
    }
  }

  private func collaborationAcceptanceStatusLabel(_ value: Int?) -> String? {
    guard let value else {
      return nil
    }
    switch value {
    case 0: return "unknown"
    case 1: return "pending"
    case 2: return "accepted"
    case 3: return "removed"
    default: return "unrecognized-\(value)"
    }
  }

  private func bodyAttributeSummary(_ attributedString: NSAttributedString) -> BodyAttributeSummary {
    var summary = BodyAttributeSummary()
    let fullRange = NSRange(location: 0, length: attributedString.length)
    guard fullRange.length > 0 else {
      return summary
    }

    attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
      let runText = attributedString.attributedSubstring(from: range).string
      let runTextByteCount = runText.utf8.count
      let runTextSHA256 = sha256Hex(runText)
      let paragraphIDSHA256 = paragraphIDSHA256(attributes)
      let inlineFormats = inlineFormatKinds(attributes)
      if inlineFormats.isEmpty == false {
        summary.inlineFormatRunCount += 1
        for format in inlineFormats {
          summary.inlineFormatCounts[format, default: 0] += 1
          let fontSHA256 = format == "font"
            ? (attributes[.font] as? NSFont).map(notesFontSHA256)
            : nil
          summary.inlineFormatRuns.append(
            NotesBodyInlineFormatRunRecord(
              ordinal: summary.inlineFormatRuns.count + 1,
              paragraphIDSHA256: paragraphIDSHA256,
              format: format,
              fontSHA256: fontSHA256,
              textByteCount: runTextByteCount,
              textSHA256: runTextSHA256
            ))
        }
      }
      if inlineFormats.contains("bold") {
        summary.boldRunCount += 1
      }
      if inlineFormats.contains("italic") {
        summary.italicRunCount += 1
      }
      if inlineFormats.contains("underline") {
        summary.underlineRunCount += 1
      }
      if inlineFormats.contains("strikethrough") {
        summary.strikethroughRunCount += 1
      }
      if inlineFormats.contains("font") {
        summary.fontRunCount += 1
      }
      if inlineFormats.contains("foreground_color") {
        summary.foregroundColorRunCount += 1
      }
      if inlineFormats.contains("highlight") {
        summary.highlightRunCount += 1
      }
      for (role, hash) in inlineColorHashes(attributes) {
        summary.colorHashCounts[BodyColorHashKey(role: role, colorSHA256: hash), default: 0] += 1
        summary.colorRuns.append(
          NotesBodyInlineColorRunRecord(
            ordinal: summary.colorRuns.count + 1,
            paragraphIDSHA256: paragraphIDSHA256,
            role: role,
            colorSHA256: hash,
            textByteCount: runTextByteCount,
            textSHA256: runTextSHA256
          ))
      }

      for value in attributes.values {
        guard let object = value as AnyObject? else {
          continue
        }
        if let style = bodyParagraphStyleKind(object) {
          summary.paragraphStyleRunCount += 1
          summary.styleCounts[style, default: 0] += 1
          if optionalBool(object, key: "isHeader") == true {
            summary.headingCount += 1
          }
          if optionalBool(object, key: "isList") == true {
            summary.listItemCount += 1
          }
          if optionalBool(object, key: "isChecklist") == true {
            summary.checklistItemCount += 1
            if optionalObject(object, key: "todo").flatMap({ optionalBool($0, key: "done") }) == true {
              summary.checklistDoneCount += 1
            } else {
              summary.checklistOpenCount += 1
            }
          }
          if optionalBool(object, key: "isBlockQuote") == true {
            summary.blockQuoteCount += 1
          }
        }

        if let kind = bodyAttachmentKind(object) {
          summary.attachmentKindCounts[kind, default: 0] += 1
          summary.inlineAttachmentCount += 1
          if kind == "table" {
            summary.tableCount += 1
          }
          if kind.hasPrefix("math") {
            summary.mathAttachmentCount += 1
          }
        }
      }
    }

    return summary
  }

  private func inlineFormatKinds(_ attributes: [NSAttributedString.Key: Any]) -> Set<String> {
    var formats = Set<String>()
    if let font = attributes[.font] {
      formats.insert("font")
      if let font = font as? NSFont {
        let traits = NSFontManager.shared.traits(of: font)
        if traits.contains(.boldFontMask) {
          formats.insert("bold")
        }
        if traits.contains(.italicFontMask) {
          formats.insert("italic")
        }
      }
    }
    if nonZeroAttribute(attributes[.underlineStyle]) {
      formats.insert("underline")
    }
    if nonZeroAttribute(attributes[.strikethroughStyle]) {
      formats.insert("strikethrough")
    }

    for key in attributes.keys {
      let raw = key.rawValue.localizedLowercase
      if key == .foregroundColor || raw.contains("foreground") {
        formats.insert("foreground_color")
      }
      if key == .backgroundColor || raw.contains("background") || raw.contains("highlight") {
        formats.insert("highlight")
      }
    }
    return formats
  }

  private func inlineColorHashes(_ attributes: [NSAttributedString.Key: Any]) -> [(role: String, hash: String)] {
    attributes.compactMap { key, value in
      let raw = key.rawValue.localizedLowercase
      let role: String?
      if key == .foregroundColor || raw.contains("foreground") {
        role = "foreground"
      } else if key == .backgroundColor || raw.contains("background") || raw.contains("highlight") {
        role = "highlight"
      } else {
        role = nil
      }
      guard let role, let hash = colorHash(value) else {
        return nil
      }
      return (role, hash)
    }
  }

  private func paragraphIDSHA256(_ attributes: [NSAttributedString.Key: Any]) -> String? {
    for value in attributes.values {
      guard let object = value as AnyObject?,
        bodyParagraphStyleKind(object) != nil,
        let paragraphID = paragraphStyleUUIDString(object)
      else {
        continue
      }
      return sha256Hex(paragraphID)
    }
    return nil
  }

  private func colorHash(_ value: Any) -> String? {
    if let color = value as? NSColor {
      let rgb = color.usingColorSpace(.deviceRGB) ?? color
      return sha256Hex(
        [
          "r:\(roundedColorComponent(rgb.redComponent))",
          "g:\(roundedColorComponent(rgb.greenComponent))",
          "b:\(roundedColorComponent(rgb.blueComponent))",
          "a:\(roundedColorComponent(rgb.alphaComponent))",
        ].joined(separator: ";")
      )
    }
    let object = value as AnyObject
    if CFGetTypeID(object) == CGColor.typeID {
      let cgColor = unsafeDowncast(object, to: CGColor.self)
      return sha256Hex(
        [
          "space:\(cgColor.colorSpace?.name.map { String($0) } ?? "unknown")",
          "components:\((cgColor.components ?? []).map(roundedColorComponent).joined(separator: ","))",
          "alpha:\(roundedColorComponent(cgColor.alpha))",
        ].joined(separator: ";")
      )
    }
    return sha256Hex("\(type(of: value)):\(String(describing: value))")
  }

  private func roundedColorComponent(_ value: CGFloat) -> String {
    String(Int((value * 10_000).rounded()))
  }

  private func nonZeroAttribute(_ value: Any?) -> Bool {
    if let number = value as? NSNumber {
      return number.intValue != 0
    }
    if let int = value as? Int {
      return int != 0
    }
    if let bool = value as? Bool {
      return bool
    }
    return value != nil
  }

  private func paragraphAnchorResolutions(_ note: ICNote) -> [NotesParagraphAnchorResolution] {
    guard let attributedString = note.attributedString() as? NSAttributedString else {
      return []
    }

    var anchors: [NotesParagraphAnchorResolution] = []
    var seenIDs = Set<String>()
    let fullRange = NSRange(location: 0, length: attributedString.length)
    guard fullRange.length > 0 else {
      return anchors
    }

    attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, _, _ in
      for value in attributes.values {
        guard let object = value as AnyObject?,
          let style = bodyParagraphStyleKind(object),
          let paragraphID = paragraphStyleUUIDString(object),
          seenIDs.insert(paragraphID).inserted
        else {
          continue
        }
        let title = paragraphTitle(note, paragraphID: paragraphID)
        let anchor = NotesBodyParagraphAnchorRecord(
          ordinal: anchors.count + 1,
          idSHA256: sha256Hex(paragraphID),
          titleByteCount: title?.utf8.count,
          titleSHA256: title.map(sha256Hex),
          style: style,
          listStyle: bodyParagraphListStyle(object),
          alignment: bodyParagraphAlignment(object),
          isHeader: optionalBool(object, key: "isHeader") == true,
          isList: optionalBool(object, key: "isList") == true,
          isChecklist: optionalBool(object, key: "isChecklist") == true,
          isBlockQuote: optionalBool(object, key: "isBlockQuote") == true,
          indentationLevel: optionalInt(object, key: "indent"),
          canIndent: optionalBool(object, key: "canIndent"),
          checklistDone: optionalObject(object, key: "todo").flatMap { optionalBool($0, key: "done") }
        )
        anchors.append(NotesParagraphAnchorResolution(anchor: anchor, paragraphID: paragraphID, title: title))
      }
    }

    return anchors
  }

  private func collapsibleSectionCounts(
    note: ICNote,
    paragraphs: [NotesParagraphAnchorResolution]
  ) -> (collapsible: Int, collapsed: Int) {
    let sections = collapsibleSections(note: note, paragraphs: paragraphs)
    return (sections.count, sections.filter { $0.collapsed }.count)
  }

  private func collapsibleSections(
    note: ICNote,
    paragraphs: [NotesParagraphAnchorResolution]
  ) -> [NotesBodyCollapsibleSectionRecord] {
    guard paragraphs.isEmpty == false,
      let textStorage = note.textStorage() as? ICTTTextStorage
    else {
      return []
    }
    let collapsedUUIDs = note.outlineState?.collapsedUUIDs ?? Set<AnyHashable>()
    guard let outlineController = ICOutlineController(
      textStorage: textStorage,
      collapsedUUIDs: collapsedUUIDs,
      asynchronous: false
    ) else {
      return []
    }
    var sections: [NotesBodyCollapsibleSectionRecord] = []
    for paragraph in paragraphs {
      guard let uuid = UUID(uuidString: paragraph.paragraphID) else {
        continue
      }
      if outlineController.isUUIDCollapsible(uuid) {
        sections.append(
          NotesBodyCollapsibleSectionRecord(
            ordinal: sections.count + 1,
            paragraphIDSHA256: paragraph.anchor.idSHA256,
            titleByteCount: paragraph.anchor.titleByteCount,
            titleSHA256: paragraph.anchor.titleSHA256,
            collapsed: outlineController.isUUIDCollapsed(uuid)
          ))
      }
    }
    return sections
  }

  private func paragraphStyleUUIDString(_ object: AnyObject) -> String? {
    guard let uuid = optionalObject(object, key: "uuid") else {
      return nil
    }
    if let uuid = uuid as? UUID {
      return uuid.uuidString
    }
    if let uuid = uuid as? NSUUID {
      return uuid.uuidString
    }
    return nonEmpty(String(describing: uuid))
  }

  private func paragraphTitle(_ note: ICNote, paragraphID: String) -> String? {
    let selector = NSSelectorFromString("titleForParagraphID:")
    let noteObject = note as NSObject
    guard noteObject.responds(to: selector) else {
      return nil
    }
    return nonEmpty(noteObject.perform(selector, with: paragraphID as NSString)?
      .takeUnretainedValue() as? String)
  }

  private func bodyParagraphStyleKind(_ object: AnyObject) -> String? {
    let name = objectTypeName(object)
    let hasParagraphSignals = name.contains("ICTTParagraphStyle")
      || optionalInt(object, key: "style") != nil
      || optionalBool(object, key: "isList") != nil
      || optionalBool(object, key: "isChecklist") != nil
      || optionalBool(object, key: "isHeader") != nil
    guard hasParagraphSignals else {
      return nil
    }

    if optionalBool(object, key: "isChecklist") == true {
      return "checklist"
    }
    if let style = optionalInt(object, key: "style"),
      let textStyleName = bodyTextStyleName(for: style)
    {
      return textStyleName
    }
    if optionalBool(object, key: "isHeader") == true {
      return "heading"
    }
    if optionalBool(object, key: "isBlockQuote") == true {
      return "block_quote"
    }
    if optionalBool(object, key: "isList") == true {
      return "list"
    }
    if let style = optionalInt(object, key: "style") {
      return "style_\(style)"
    }
    return "paragraph"
  }

  private func bodyTextStyleName(for styleValue: Int) -> String? {
    for style in NotesBodyParagraphStyle.allCases {
      guard let textStyle = bodyTextStyle(style) else {
        continue
      }
      if Int(textStyle.ttStyle) == styleValue {
        return style.rawValue
      }
    }
    return nil
  }

  private func bodyTextStyle(_ style: NotesBodyParagraphStyle) -> ICTextStyle? {
    switch style {
    case .title:
      return ICTextStyle.titleStyle() as? ICTextStyle
    case .heading:
      return ICTextStyle.headingStyle() as? ICTextStyle
    case .subheading:
      return ICTextStyle.subheadingStyle() as? ICTextStyle
    case .body:
      return ICTextStyle.bodyStyle() as? ICTextStyle
    case .monostyled:
      return ICTextStyle.fixedWidthStyle() as? ICTextStyle
    }
  }

  private func bodyParagraphListStyle(_ object: AnyObject) -> String? {
    guard optionalBool(object, key: "isList") == true,
      optionalBool(object, key: "isChecklist") != true,
      let style = optionalInt(object, key: "style")
    else {
      return nil
    }
    return NotesBodyListStyle.styleName(for: style)
  }

  private func bodyParagraphAlignment(_ object: AnyObject) -> String? {
    guard let alignment = optionalInt(object, key: "alignment") else {
      return nil
    }
    let textAlignment = ICTTParagraphStyle.textAlignment(forParagraphStyleAlignment: Int32(alignment))
    return NotesBodyParagraphAlignment.alignmentName(forTextAlignmentRawValue: Int(textAlignment))
  }

  private func bodyAttachmentKind(_ object: AnyObject) -> String? {
    let name = objectTypeName(object)
    if isMentionAttachmentObject(object) {
      return "mention"
    }
    if name.contains("ICTableTextAttachment") {
      return "table"
    }
    if name.contains("ICTK2TodoTextAttachment") {
      return "checklist"
    }
    if name.contains("ICCalculateResultTextAttachment") {
      return "math_result"
    }
    if name.contains("ICCalculateGraphExpressionTextAttachment") {
      return "math_graph_expression"
    }
    if name.contains("Calculate") && name.contains("TextAttachment") {
      return "math"
    }
    if name.contains("ICLinkTextAttachment") {
      return "link"
    }
    if name.contains("ICDividerLineTextAttachment") {
      return "divider"
    }
    if name.contains("ICInlineTextAttachment") {
      return "inline"
    }
    if name.contains("ICTextAttachment") || name.contains("NSTextAttachment") {
      return "attachment"
    }
    return nil
  }

  private func mergedAttachmentKindCounts(
    _ attributedCounts: [String: Int],
    inlineAttachments: [AnyObject]
  ) -> [String: Int] {
    var counts = attributedCounts
    for attachment in inlineAttachments {
      if isMentionAttachmentObject(attachment) {
        counts["mention", default: 0] += 1
      } else if isLinkObject(attachment) {
        counts["link", default: 0] += 1
      } else if isMathAttachmentObject(attachment) {
        counts["math", default: 0] += 1
      } else {
        counts["inline", default: 0] += 1
      }
    }
    return counts
  }

  private func isMathAttachmentObject(_ object: AnyObject) -> Bool {
    optionalBool(object, key: "isCalculateResultAttachment") == true
      || optionalBool(object, key: "isCalculateGraphExpressionAttachment") == true
      || optionalBool(object, key: "validCalculateAttachment") == true
  }

  private func isMathResultAttachmentObject(_ object: AnyObject) -> Bool {
    optionalBool(object, key: "isCalculateResultAttachment") == true
      || objectTypeName(object).contains("ICCalculateResultTextAttachment")
  }

  private func isMentionAttachmentObject(_ object: AnyObject) -> Bool {
    optionalBool(object, key: "isMentionAttachment") == true
      || objectTypeName(object).contains("ICMentionTextAttachment")
  }

  private func styleCountRecords(_ counts: [String: Int]) -> [NotesBodyStyleCount] {
    counts
      .map { NotesBodyStyleCount(style: $0.key, count: $0.value) }
      .sorted { $0.style.localizedStandardCompare($1.style) == .orderedAscending }
  }

  private func attachmentKindCountRecords(_ counts: [String: Int]) -> [NotesBodyAttachmentKindCount] {
    counts
      .map { NotesBodyAttachmentKindCount(kind: $0.key, count: $0.value) }
      .sorted { $0.kind.localizedStandardCompare($1.kind) == .orderedAscending }
  }

  private func inlineFormatCountRecords(_ counts: [String: Int]) -> [NotesBodyInlineFormatCount] {
    counts
      .map { NotesBodyInlineFormatCount(format: $0.key, count: $0.value) }
      .sorted { $0.format.localizedStandardCompare($1.format) == .orderedAscending }
  }

  private func colorHashCountRecords(_ counts: [BodyColorHashKey: Int]) -> [NotesBodyColorHashCount] {
    counts
      .map { NotesBodyColorHashCount(role: $0.key.role, colorSHA256: $0.key.colorSHA256, count: $0.value) }
      .sorted {
        if $0.role == $1.role {
          return $0.colorSHA256 < $1.colorSHA256
        }
        return $0.role.localizedStandardCompare($1.role) == .orderedAscending
      }
  }

  private func paragraphCount(_ text: String) -> Int {
    guard !text.isEmpty else {
      return 0
    }
    var count = 0
    text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: [.byParagraphs]) { _, _, _, _ in
      count += 1
    }
    return count
  }

  private func objectTypeName(_ object: AnyObject) -> String {
    String(describing: type(of: object))
  }

  private func tagIdentifierCandidates(_ hashtag: ICHashtag) -> [String] {
    [
      nonEmpty(hashtag.standardizedContent),
      nonEmpty(hashtag.contentIdentifier),
      nonEmpty(hashtag.displayText),
      Optional(objectIDString(hashtag)),
    ].compactMap { $0 }
  }

  private func noteIdentifier(_ note: ICNote) -> String {
    objectIDString(note)
  }

  private func noteFolderDisplayName(_ note: ICNote) -> String {
    if let folder = note.folder as? ICFolder {
      return folderDisplayName(folder)
    }
    return nonEmpty(note.folderName) ?? nonEmpty(note.folderNameForNoteList) ?? "Notes"
  }

  private func folderDisplayName(_ folder: ICFolder) -> String {
    nonEmpty(string(folder.titleForNavigationBar()))
      ?? nonEmpty(string(folder.titleForTableViewCell()))
      ?? nonEmpty(folder.title)
      ?? nonEmpty(folder.localizedTitle)
      ?? "Untitled"
  }

  private func objectIDString(_ object: AnyObject) -> String {
    if let cloudObject = object as? ICCloudObject, let objectID = cloudObject.objectID {
      return objectID.uriRepresentation().absoluteString
    }
    if let managedObject = object as? NSManagedObject {
      return managedObject.objectID.uriRepresentation().absoluteString
    }
    return String(ObjectIdentifier(object).hashValue)
  }

  private func objectIDURI(_ object: AnyObject) -> URL? {
    if let cloudObject = object as? ICCloudObject, let objectID = cloudObject.objectID {
      return objectID.uriRepresentation()
    }
    if let managedObject = object as? NSManagedObject {
      return managedObject.objectID.uriRepresentation()
    }
    return nil
  }

  private func matchesAccount(_ account: ICAccount?, accountName: String?, selector: String?) -> Bool {
    guard let selector = nonEmpty(selector) else {
      return true
    }

    let candidates = [
      account.map(objectIDString),
      account.flatMap { nonEmpty($0.localizedName) },
      account.flatMap { nonEmpty($0.name) },
      nonEmpty(accountName),
    ]
    return candidates.contains { candidate in
      candidate?.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
  }

  private func matchesFolder(_ note: ICNote, selector: String?) -> Bool {
    guard let selector = nonEmpty(selector) else {
      return true
    }

    let candidates = [
      nonEmpty(note.folderName),
      nonEmpty(note.folderManagedIdentifier),
      note.folder.map { objectIDString($0 as AnyObject) },
    ]
    return candidates.contains { candidate in
      candidate?.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
  }

  private func plainTextBody(_ note: ICNote) -> String {
    string(note.noteAsPlainTextWithoutTitle)
  }

  private func compareNotes(_ lhs: NotesNoteSummary, _ rhs: NotesNoteSummary) -> Bool {
    switch (lhs.updatedAt, rhs.updatedAt) {
    case let (left?, right?) where left != right:
      return left > right
    case (_?, nil):
      return true
    case (nil, _?):
      return false
    default:
      return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
  }

  private func compareNoteDetails(_ lhs: NotesNoteDetail, _ rhs: NotesNoteDetail) -> Bool {
    compareNotes(
      NotesNoteSummary(
        id: lhs.id,
        title: lhs.title,
        folderName: lhs.folderName,
        accountName: lhs.accountName,
        createdAt: lhs.createdAt,
        updatedAt: lhs.updatedAt
      ),
      NotesNoteSummary(
        id: rhs.id,
        title: rhs.title,
        folderName: rhs.folderName,
        accountName: rhs.accountName,
        createdAt: rhs.createdAt,
        updatedAt: rhs.updatedAt
      )
    )
  }

  private func objects<T>(_ value: Any?) -> [T] {
    if let values = value as? [T] {
      return values
    }
    if let values = value as? NSArray {
      return values.compactMap { $0 as? T }
    }
    if let values = value as? NSOrderedSet {
      return values.array.compactMap { $0 as? T }
    }
    if let values = value as? NSSet {
      return values.allObjects.compactMap { $0 as? T }
    }
    return []
  }

  private func anyObjects(_ value: Any?) -> [AnyObject] {
    if let values = value as? [AnyObject] {
      return values
    }
    if let values = value as? NSArray {
      return values.compactMap { $0 as AnyObject }
    }
    if let values = value as? NSSet {
      return values.allObjects.compactMap { $0 as AnyObject }
    }
    return []
  }

  private func participantUserIDSHA256s(from value: Any?) -> [String] {
    let strings = stringValues(from: value)
      + anyObjects(value).flatMap(participantUserIDStrings)
    return Array(Set(strings.map(sha256Hex))).sorted()
  }

  private func mentionUserIDSHA256s(_ inlineAttachments: [AnyObject]) -> [String] {
    let strings = inlineAttachments
      .filter(isMentionAttachmentObject)
      .flatMap(participantUserIDStrings)
    return Array(Set(strings.map(sha256Hex))).sorted()
  }

  private func participantUserIDStrings(from object: AnyObject) -> [String] {
    let direct = [
      "participantUserID",
      "participantUserIdentifier",
      "mentionedParticipantUserID",
      "mentionUserID",
      "userID",
      "userIdentifier",
      "userRecordName",
      "recordName",
      "identifier",
    ].compactMap { nonEmpty(optionalString(object, key: $0)) }

    let nestedKeys = [
      "participant",
      "mentionedParticipant",
      "user",
      "owner",
      "identity",
      "userRecordID",
      "recordID",
      "cloudKitUserRecordID",
    ]
    let nested = nestedKeys
      .compactMap { optionalObject(object, key: $0) }
      .flatMap { nestedObject in
        stringValues(from: nestedObject)
          + [
            "participantUserID",
            "userID",
            "userIdentifier",
            "userRecordName",
            "recordName",
            "identifier",
          ].compactMap { nonEmpty(optionalString(nestedObject, key: $0)) }
      }
    return direct + nested
  }

  private func stringValues(from value: Any?) -> [String] {
    switch value {
    case let string as String:
      return [string].compactMap { nonEmpty($0) }
    case let string as NSString:
      return [string as String].compactMap { nonEmpty($0) }
    case let array as NSArray:
      return array.flatMap { stringValues(from: $0) }
    case let set as NSSet:
      return set.allObjects.flatMap { stringValues(from: $0) }
    default:
      return []
    }
  }

  private func optionalObject(_ object: AnyObject, key: String) -> AnyObject? {
    guard let value = optionalValue(object, key: key) else {
      return nil
    }
    return value as AnyObject
  }

  private func performedObject(
    _ object: NSObject,
    selector name: String,
    _ argument: AnyObject? = nil,
    _ secondArgument: AnyObject? = nil
  ) -> AnyObject? {
    let selector = NSSelectorFromString(name)
    guard object.responds(to: selector) else {
      return nil
    }
    return object.perform(selector, with: argument, with: secondArgument)?.takeUnretainedValue()
  }

  private func objectCount(_ value: AnyObject?) -> Int? {
    switch value {
    case let array as NSArray:
      return array.count
    case let set as NSSet:
      return set.count
    case let orderedSet as NSOrderedSet:
      return orderedSet.count
    default:
      return nil
    }
  }

  private func optionalString(_ object: AnyObject, key: String) -> String? {
    optionalValue(object, key: key) as? String
  }

  private func optionalURLString(_ object: AnyObject, key: String) -> String? {
    switch optionalValue(object, key: key) {
    case let value as URL:
      return value.absoluteString
    case let value as NSURL:
      return value.absoluteString
    case let value as String:
      return value
    default:
      return nil
    }
  }

  private func optionalDate(_ object: AnyObject, key: String) -> Date? {
    optionalValue(object, key: key) as? Date
  }

  private func optionalBool(_ object: AnyObject, key: String) -> Bool? {
    switch optionalValue(object, key: key) {
    case let value as Bool:
      return value
    case let value as NSNumber:
      return value.boolValue
    default:
      return nil
    }
  }

  private func optionalInt(_ object: AnyObject, key: String) -> Int? {
    switch optionalValue(object, key: key) {
    case let value as Int:
      return value
    case let value as NSNumber:
      return value.intValue
    default:
      return nil
    }
  }

  private func optionalInt64(_ object: AnyObject, key: String) -> Int64? {
    switch optionalValue(object, key: key) {
    case let value as Int64:
      return value
    case let value as Int:
      return Int64(value)
    case let value as NSNumber:
      return value.int64Value
    default:
      return nil
    }
  }

  private func optionalValue(_ object: AnyObject, key: String) -> Any? {
    guard let object = object as? NSObject else {
      return nil
    }
    let selector = NSSelectorFromString(key)
    guard object.responds(to: selector) else {
      return nil
    }
    return object.value(forKey: key)
  }

  private func string(_ value: Any?) -> String {
    value as? String ?? ""
  }

  private func markdownString(_ value: Any?) -> String? {
    if let string = value as? String {
      return nonEmpty(string)
    }
    if let attributedString = value as? NSAttributedString {
      return nonEmpty(attributedString.string)
    }
    if let representation = value as? ICMarkdownRepresentation {
      return nonEmpty(representation.markdown?.string)
    }
    if let object = value as? AnyObject,
      let markdown = optionalObject(object, key: "markdown") as? NSAttributedString
    {
      return nonEmpty(markdown.string)
    }
    return nil
  }

  private func strings(_ value: Any?) -> [String] {
    if let strings = value as? [String] {
      return strings
    }
    if let values = value as? NSArray {
      return values.compactMap { $0 as? String }
    }
    return []
  }

  private func nonEmpty(_ value: String?) -> String? {
    guard let value else {
      return nil
    }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : value
  }
}

private struct BodyAttributeSummary {
  var paragraphStyleRunCount = 0
  var headingCount = 0
  var listItemCount = 0
  var checklistItemCount = 0
  var checklistDoneCount = 0
  var checklistOpenCount = 0
  var blockQuoteCount = 0
  var tableCount = 0
  var inlineAttachmentCount = 0
  var mathAttachmentCount = 0
  var inlineFormatRunCount = 0
  var boldRunCount = 0
  var italicRunCount = 0
  var underlineRunCount = 0
  var strikethroughRunCount = 0
  var fontRunCount = 0
  var foregroundColorRunCount = 0
  var highlightRunCount = 0
  var styleCounts: [String: Int] = [:]
  var attachmentKindCounts: [String: Int] = [:]
  var inlineFormatCounts: [String: Int] = [:]
  var colorHashCounts: [BodyColorHashKey: Int] = [:]
  var inlineFormatRuns: [NotesBodyInlineFormatRunRecord] = []
  var colorRuns: [NotesBodyInlineColorRunRecord] = []
}

private struct BodyColorHashKey: Hashable {
  var role: String
  var colorSHA256: String
}

extension NotesReader: NotesParityMetadataProviding {
  func notesParityMetadata(section: String, ids: Set<String>) throws -> [String: [String: String]] {
    switch section {
    case "folders":
      let managedObjectContext = try managedObjectContext()
      let folders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
      return Dictionary(
        uniqueKeysWithValues: folders.compactMap { folder in
          let id = objectIDString(folder)
          guard ids.contains(id) else {
            return nil
          }
          return (id, folderParityMetadata(folder))
        })
    case "notes":
      return Dictionary(
        uniqueKeysWithValues: try visibleNotes().compactMap { note in
          let id = noteIdentifier(note)
          guard ids.contains(id) else {
            return nil
          }
          return (id, noteParityMetadata(note))
        })
    default:
      return [:]
    }
  }

  private func folderParityMetadata(_ folder: ICFolder) -> [String: String] {
    var metadata = [
      "database_scope": metadataNumber(folder.value(forKey: "databaseScope")),
      "depth": metadataNumber(folder.value(forKey: "depth")),
      "folder_type": metadataNumber(folder.value(forKey: "folderType")),
      "has_visible_notes": metadataBool(folder.value(forKey: "hasVisibleNotes")),
      "is_default": metadataBool(folder.value(forKey: "isDefaultFolderForAccount")),
      "is_modern_custom": metadataBool(folder.value(forKey: "isModernCustomFolder")),
      "is_renamable": metadataBool(folder.value(forKey: "isRenamable")),
      "is_trash": metadataBool(folder.value(forKey: "isTrashFolder")),
      "parent_present": metadataBool(folder.value(forKey: "parent") != nil),
      "smart_query_present": metadataBool(folder.value(forKey: "smartFolderQuery") != nil),
      "visibility_testing_type": metadataNumber(folder.value(forKey: "visibilityTestingType")),
    ]

    metadata["localized_title_sha256"] = metadataHash(folder.localizedTitle)
    metadata["navigation_title_sha256"] = metadataHash(string(folder.titleForNavigationBar()))
    if let parent = folder.parent {
      metadata["parent_id_sha256"] = metadataHash(objectIDString(parent))
      metadata["parent_localized_title_sha256"] = metadataHash(parent.localizedTitle)
      metadata["parent_navigation_title_sha256"] = metadataHash(string(parent.titleForNavigationBar()))
      metadata["parent_table_title_sha256"] = metadataHash(string(parent.titleForTableViewCell()))
      metadata["parent_title_sha256"] = metadataHash(parent.title)
    }
    metadata["table_title_sha256"] = metadataHash(string(folder.titleForTableViewCell()))
    metadata["title_sha256"] = metadataHash(folder.title)
    return metadata
  }

  private func noteParityMetadata(_ note: ICNote) -> [String: String] {
    var metadata = [
      "current_status": metadataNumber(note.value(forKey: "currentStatus")),
      "is_deleted_or_trash": metadataBool(note.value(forKey: "isDeletedOrInTrash")),
      "is_password_protected": metadataBool(note.value(forKey: "isPasswordProtected")),
      "is_pinned": metadataBool(note.value(forKey: "isPinned")),
    ]

    if let folder = note.folder as? ICFolder {
      metadata["folder_id_sha256"] = metadataHash(objectIDString(folder))
      metadata["folder_type"] = metadataNumber(folder.value(forKey: "folderType"))
      metadata["folder_is_default"] = metadataBool(folder.value(forKey: "isDefaultFolderForAccount"))
      metadata["folder_is_trash"] = metadataBool(folder.value(forKey: "isTrashFolder"))
      metadata["folder_navigation_title_sha256"] = metadataHash(string(folder.titleForNavigationBar()))
      metadata["folder_table_title_sha256"] = metadataHash(string(folder.titleForTableViewCell()))
      metadata["folder_title_sha256"] = metadataHash(folder.title)
      if let parent = folder.parent {
        metadata["folder_parent_id_sha256"] = metadataHash(objectIDString(parent))
        metadata["folder_parent_navigation_title_sha256"] =
          metadataHash(string(parent.titleForNavigationBar()))
        metadata["folder_parent_table_title_sha256"] = metadataHash(string(parent.titleForTableViewCell()))
        metadata["folder_parent_title_sha256"] = metadataHash(parent.title)
      }
    }

    return metadata
  }

  private func metadataHash(_ value: String?) -> String {
    sha256Hex(value ?? "")
  }

  private func metadataBool(_ value: Any?) -> String {
    switch value {
    case let value as Bool:
      return value ? "true" : "false"
    case let value as NSNumber:
      return value.boolValue ? "true" : "false"
    case let value?:
      return String(describing: value)
    case nil:
      return ""
    }
  }

  private func metadataNumber(_ value: Any?) -> String {
    switch value {
    case let value as NSNumber:
      return value.stringValue
    case let value?:
      return String(describing: value)
    case nil:
      return ""
    }
  }
}

private struct TableCellFormatSummary {
  var formatRunCount: Int
  var formatSHA256: String
  var containsBold: Bool
  var containsItalic: Bool
  var containsUnderline: Bool
  var containsStrikethrough: Bool
}

private extension Array {
  func prefixCount(_ limit: Int) -> [Element] {
    Array(prefix(Swift.max(0, limit)))
  }
}
