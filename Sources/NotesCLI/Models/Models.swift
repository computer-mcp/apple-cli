import CryptoKit
import Foundation
import Utility

public struct NotesAccountRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

public struct NotesSettingsFamilyRecord: Codable, Equatable, Sendable {
  public var id: String
  public var label: String
  public var status: String
  public var valueKind: String?
  public var boolValue: Bool?
  public var valueSHA256: String?
  public var evidence: String
  public var notes: String?

  public init(
    id: String,
    label: String,
    status: String,
    valueKind: String? = nil,
    boolValue: Bool? = nil,
    valueSHA256: String? = nil,
    evidence: String,
    notes: String? = nil
  ) {
    self.id = id
    self.label = label
    self.status = status
    self.valueKind = valueKind
    self.boolValue = boolValue
    self.valueSHA256 = valueSHA256
    self.evidence = evidence
    self.notes = notes
  }
}

public struct NotesSettingsReadEvidence: Codable, Equatable, Sendable {
  public var accountScope: String
  public var requestedAccountSHA256: String?
  public var accountCount: Int
  public var selectedAccountCount: Int
  public var defaultAccountIDSHA256: String?
  public var onMyMacAccountPresent: Bool
  public var supportsQueryDateHeaders: Bool?
  public var showsQueryDateHeaders: Bool?
  public var families: [NotesSettingsFamilyRecord]

  public init(
    accountScope: String,
    requestedAccountSHA256: String? = nil,
    accountCount: Int,
    selectedAccountCount: Int,
    defaultAccountIDSHA256: String? = nil,
    onMyMacAccountPresent: Bool,
    supportsQueryDateHeaders: Bool? = nil,
    showsQueryDateHeaders: Bool? = nil,
    families: [NotesSettingsFamilyRecord]
  ) {
    self.accountScope = accountScope
    self.requestedAccountSHA256 = requestedAccountSHA256
    self.accountCount = accountCount
    self.selectedAccountCount = selectedAccountCount
    self.defaultAccountIDSHA256 = defaultAccountIDSHA256
    self.onMyMacAccountPresent = onMyMacAccountPresent
    self.supportsQueryDateHeaders = supportsQueryDateHeaders
    self.showsQueryDateHeaders = showsQueryDateHeaders
    self.families = families
  }
}

public struct NotesSettingsReadResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var accountScope: String
  public var requestedAccountSHA256: String?
  public var accountCount: Int
  public var selectedAccountCount: Int
  public var defaultAccountIDSHA256: String?
  public var onMyMacAccountPresent: Bool
  public var supportsQueryDateHeaders: Bool?
  public var showsQueryDateHeaders: Bool?
  public var families: [NotesSettingsFamilyRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    accountScope: String,
    requestedAccountSHA256: String? = nil,
    accountCount: Int,
    selectedAccountCount: Int,
    defaultAccountIDSHA256: String? = nil,
    onMyMacAccountPresent: Bool,
    supportsQueryDateHeaders: Bool? = nil,
    showsQueryDateHeaders: Bool? = nil,
    families: [NotesSettingsFamilyRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.accountScope = accountScope
    self.requestedAccountSHA256 = requestedAccountSHA256
    self.accountCount = accountCount
    self.selectedAccountCount = selectedAccountCount
    self.defaultAccountIDSHA256 = defaultAccountIDSHA256
    self.onMyMacAccountPresent = onMyMacAccountPresent
    self.supportsQueryDateHeaders = supportsQueryDateHeaders
    self.showsQueryDateHeaders = showsQueryDateHeaders
    self.families = families
    self.verification = verification
  }
}

public struct NotesSettingsWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesSettingsWorkflowAuditSummary
  public var records: [NotesSettingsWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesSettingsWorkflowAuditSummary,
    records: [NotesSettingsWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesSettingsWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesSettingsWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesSettingsParagraphStyleMutationDraft: Codable, Equatable, Sendable {
  public var style: NotesBodyParagraphStyle

  public init(style: NotesBodyParagraphStyle) {
    self.style = style
  }
}

public struct NotesSettingsBoolMutationDraft: Codable, Equatable, Sendable {
  public var enabled: Bool

  public init(enabled: Bool) {
    self.enabled = enabled
  }
}

public struct NotesSettingsAccountBoolMutationDraft: Codable, Equatable, Sendable {
  public var account: String
  public var enabled: Bool

  public init(account: String, enabled: Bool) {
    self.account = account
    self.enabled = enabled
  }
}

public struct NotesSettingsPassphraseMutationDraft: Equatable, Sendable {
  public var account: String
  public var passphrase: String
  public var passphraseSourceKind: String
  public var hint: String?
  public var hintSHA256: String?
  public var isReset: Bool

  public init(
    account: String,
    passphrase: String,
    passphraseSourceKind: String,
    hint: String?,
    hintSHA256: String?,
    isReset: Bool
  ) {
    self.account = account
    self.passphrase = passphrase
    self.passphraseSourceKind = passphraseSourceKind
    self.hint = hint
    self.hintSHA256 = hintSHA256
    self.isReset = isReset
  }
}

public struct NotesSettingsPassphraseChangeMutationDraft: Equatable, Sendable {
  public var account: String
  public var oldPassphrase: String
  public var oldPassphraseSourceKind: String
  public var newPassphrase: String
  public var newPassphraseSourceKind: String
  public var hint: String?
  public var hintSHA256: String?

  public init(
    account: String,
    oldPassphrase: String,
    oldPassphraseSourceKind: String,
    newPassphrase: String,
    newPassphraseSourceKind: String,
    hint: String?,
    hintSHA256: String?
  ) {
    self.account = account
    self.oldPassphrase = oldPassphrase
    self.oldPassphraseSourceKind = oldPassphraseSourceKind
    self.newPassphrase = newPassphrase
    self.newPassphraseSourceKind = newPassphraseSourceKind
    self.hint = hint
    self.hintSHA256 = hintSHA256
  }
}

public struct NotesSettingsLockedNotesMethodMutationDraft: Codable, Equatable, Sendable {
  public var account: String
  public var methodScope: String
  public var modeRawValue: Int
  public var modeSHA256: String

  public init(
    account: String,
    methodScope: String,
    modeRawValue: Int,
    modeSHA256: String
  ) {
    self.account = account
    self.methodScope = methodScope
    self.modeRawValue = modeRawValue
    self.modeSHA256 = modeSHA256
  }
}

public func notesDateHeadersPrivateValue(enabled: Bool) -> Int {
  enabled ? 2 : 1
}

public func notesDateHeadersTypeSHA256(scope: String, privateValue: Int) -> String {
  sha256Hex("ICDateHeadersUtilities.\(scope)|\(privateValue)")
}

public struct NotesSettingsDateHeadersMutationDraft: Codable, Equatable, Sendable {
  public var scope: String
  public var enabled: Bool
  public var privateValue: Int

  public init(scope: String, enabled: Bool, privateValue: Int) {
    self.scope = scope
    self.enabled = enabled
    self.privateValue = privateValue
  }
}

public struct NotesSettingsTextSizeMutationDraft: Codable, Equatable, Sendable {
  public var pointSize: Double

  public init(pointSize: Double) {
    self.pointSize = pointSize
  }
}

public struct NotesSettingsSortMutationDraft: Codable, Equatable, Sendable {
  public var by: String
  public var direction: String
  public var sortOrder: Int
  public var sortDirection: Int

  public init(
    by: String,
    direction: String,
    sortOrder: Int,
    sortDirection: Int
  ) {
    self.by = by
    self.direction = direction
    self.sortOrder = sortOrder
    self.sortDirection = sortDirection
  }
}

public struct NotesSettingsDefaultAccountMutationDraft: Codable, Equatable, Sendable {
  public var accountID: String
  public var accountName: String

  public init(accountID: String, accountName: String) {
    self.accountID = accountID
    self.accountName = accountName
  }
}

public func notesLockedNotesPassphraseStateSHA256(hasPassphraseSet: Bool, hintSHA256: String?) -> String {
  sha256Hex(
    [
      "ICAccount.cryptoStrategy.hasPassphraseSet",
      hasPassphraseSet ? "true" : "false",
      hintSHA256 ?? "",
    ].joined(separator: "|")
  )
}

public func notesLockedNotesModeStateSHA256(modeRawValue: Int, methodScope: String) -> String {
  sha256Hex(
    [
      "ICAccount.resolvedLockedNotesMode",
      "\(modeRawValue)",
      methodScope,
    ].joined(separator: "|")
  )
}

public struct NotesSettingsPreferenceWriteResult: Equatable, Sendable {
  public var settingID: String
  public var valueKind: String
  public var accountSHA256: String?
  public var preferenceKeySHA256: String?
  public var requestedBoolValue: Bool?
  public var requestedValueSHA256: String?
  public var beforeBoolValue: Bool?
  public var beforeValueSHA256: String?
  public var afterBoolValue: Bool?
  public var afterValueSHA256: String?
  public var localAuthenticationAvailable: Bool?
  public var biometricsEnrolled: Bool?
  public var biometricsTypeSHA256: String?
  public var localAccountNoteCountBefore: Int?
  public var localAccountCustomFolderCountBefore: Int?
  public var nonLocalAccountCountBefore: Int?
  public var passphraseSourceKind: String?
  public var oldPassphraseSourceKind: String?
  public var newPassphraseSourceKind: String?
  public var hintSHA256: String?
  public var hintLength: Int?
  public var backendCalls: String?
  public var resetRequested: Bool?
  public var passwordChangeRequested: Bool?
  public var systemPasscodeAvailable: Bool?
  public var lockedNotesModeSupported: Bool?
  public var passwordProtectedNoteCountBefore: Int?

  public init(
    settingID: String,
    valueKind: String,
    accountSHA256: String? = nil,
    preferenceKeySHA256: String? = nil,
    requestedBoolValue: Bool? = nil,
    requestedValueSHA256: String? = nil,
    beforeBoolValue: Bool? = nil,
    beforeValueSHA256: String? = nil,
    afterBoolValue: Bool? = nil,
    afterValueSHA256: String? = nil,
    localAuthenticationAvailable: Bool? = nil,
    biometricsEnrolled: Bool? = nil,
    biometricsTypeSHA256: String? = nil,
    localAccountNoteCountBefore: Int? = nil,
    localAccountCustomFolderCountBefore: Int? = nil,
    nonLocalAccountCountBefore: Int? = nil,
    passphraseSourceKind: String? = nil,
    oldPassphraseSourceKind: String? = nil,
    newPassphraseSourceKind: String? = nil,
    hintSHA256: String? = nil,
    hintLength: Int? = nil,
    backendCalls: String? = nil,
    resetRequested: Bool? = nil,
    passwordChangeRequested: Bool? = nil,
    systemPasscodeAvailable: Bool? = nil,
    lockedNotesModeSupported: Bool? = nil,
    passwordProtectedNoteCountBefore: Int? = nil
  ) {
    self.settingID = settingID
    self.valueKind = valueKind
    self.accountSHA256 = accountSHA256
    self.preferenceKeySHA256 = preferenceKeySHA256
    self.requestedBoolValue = requestedBoolValue
    self.requestedValueSHA256 = requestedValueSHA256
    self.beforeBoolValue = beforeBoolValue
    self.beforeValueSHA256 = beforeValueSHA256
    self.afterBoolValue = afterBoolValue
    self.afterValueSHA256 = afterValueSHA256
    self.localAuthenticationAvailable = localAuthenticationAvailable
    self.biometricsEnrolled = biometricsEnrolled
    self.biometricsTypeSHA256 = biometricsTypeSHA256
    self.localAccountNoteCountBefore = localAccountNoteCountBefore
    self.localAccountCustomFolderCountBefore = localAccountCustomFolderCountBefore
    self.nonLocalAccountCountBefore = nonLocalAccountCountBefore
    self.passphraseSourceKind = passphraseSourceKind
    self.oldPassphraseSourceKind = oldPassphraseSourceKind
    self.newPassphraseSourceKind = newPassphraseSourceKind
    self.hintSHA256 = hintSHA256
    self.hintLength = hintLength
    self.backendCalls = backendCalls
    self.resetRequested = resetRequested
    self.passwordChangeRequested = passwordChangeRequested
    self.systemPasscodeAvailable = systemPasscodeAvailable
    self.lockedNotesModeSupported = lockedNotesModeSupported
    self.passwordProtectedNoteCountBefore = passwordProtectedNoteCountBefore
  }
}

public struct NotesSettingsMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var settingID: String
  public var valueKind: String
  public var accountSHA256: String?
  public var preferenceKeySHA256: String?
  public var boolValue: Bool?
  public var valueSHA256: String?
  public var beforeBoolValue: Bool?
  public var beforeValueSHA256: String?
  public var afterBoolValue: Bool?
  public var afterValueSHA256: String?
  public var passphraseSourceKind: String?
  public var oldPassphraseSourceKind: String?
  public var newPassphraseSourceKind: String?
  public var hintSHA256: String?
  public var hintLength: Int?
  public var backendCalls: String?
  public var resetRequested: Bool?
  public var passwordChangeRequested: Bool?
  public var systemPasscodeAvailable: Bool?
  public var lockedNotesModeSupported: Bool?
  public var passwordProtectedNoteCountBefore: Int?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    settingID: String,
    valueKind: String,
    accountSHA256: String? = nil,
    preferenceKeySHA256: String? = nil,
    boolValue: Bool? = nil,
    valueSHA256: String? = nil,
    beforeBoolValue: Bool? = nil,
    beforeValueSHA256: String? = nil,
    afterBoolValue: Bool? = nil,
    afterValueSHA256: String? = nil,
    passphraseSourceKind: String? = nil,
    oldPassphraseSourceKind: String? = nil,
    newPassphraseSourceKind: String? = nil,
    hintSHA256: String? = nil,
    hintLength: Int? = nil,
    backendCalls: String? = nil,
    resetRequested: Bool? = nil,
    passwordChangeRequested: Bool? = nil,
    systemPasscodeAvailable: Bool? = nil,
    lockedNotesModeSupported: Bool? = nil,
    passwordProtectedNoteCountBefore: Int? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.settingID = settingID
    self.valueKind = valueKind
    self.accountSHA256 = accountSHA256
    self.preferenceKeySHA256 = preferenceKeySHA256
    self.boolValue = boolValue
    self.valueSHA256 = valueSHA256
    self.beforeBoolValue = beforeBoolValue
    self.beforeValueSHA256 = beforeValueSHA256
    self.afterBoolValue = afterBoolValue
    self.afterValueSHA256 = afterValueSHA256
    self.passphraseSourceKind = passphraseSourceKind
    self.oldPassphraseSourceKind = oldPassphraseSourceKind
    self.newPassphraseSourceKind = newPassphraseSourceKind
    self.hintSHA256 = hintSHA256
    self.hintLength = hintLength
    self.backendCalls = backendCalls
    self.resetRequested = resetRequested
    self.passwordChangeRequested = passwordChangeRequested
    self.systemPasscodeAvailable = systemPasscodeAvailable
    self.lockedNotesModeSupported = lockedNotesModeSupported
    self.passwordProtectedNoteCountBefore = passwordProtectedNoteCountBefore
    self.verification = verification
  }
}

public struct NotesSharedNoteAlertsMutationDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var hidden: Bool

  public init(noteID: String, hidden: Bool) {
    self.noteID = noteID
    self.hidden = hidden
  }
}

public struct NotesSharedNoteAlertsWriteResult: Equatable, Sendable {
  public var noteID: String
  public var requestedHidden: Bool
  public var beforeHidden: Bool?
  public var afterHidden: Bool?
  public var recordIDSHA256: String?
  public var wasShared: Bool
  public var participantCount: Int

  public var changed: Bool {
    beforeHidden != afterHidden
  }

  public init(
    noteID: String,
    requestedHidden: Bool,
    beforeHidden: Bool? = nil,
    afterHidden: Bool? = nil,
    recordIDSHA256: String? = nil,
    wasShared: Bool,
    participantCount: Int
  ) {
    self.noteID = noteID
    self.requestedHidden = requestedHidden
    self.beforeHidden = beforeHidden
    self.afterHidden = afterHidden
    self.recordIDSHA256 = recordIDSHA256
    self.wasShared = wasShared
    self.participantCount = participantCount
  }
}

public struct NotesSharedNoteAlertsMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var requestedHidden: Bool
  public var beforeHidden: Bool?
  public var afterHidden: Bool?
  public var recordIDSHA256: String?
  public var wasShared: Bool
  public var participantCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    requestedHidden: Bool,
    beforeHidden: Bool? = nil,
    afterHidden: Bool? = nil,
    recordIDSHA256: String? = nil,
    wasShared: Bool,
    participantCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.requestedHidden = requestedHidden
    self.beforeHidden = beforeHidden
    self.afterHidden = afterHidden
    self.recordIDSHA256 = recordIDSHA256
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.verification = verification
  }
}

public struct NotesCollaborationLinkDraft: Codable, Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(noteID: String? = nil, folderID: String? = nil) {
    self.noteID = noteID
    self.folderID = folderID
  }
}

public struct NotesCollaborationLinkReadResult: Equatable, Sendable {
  public var targetKind: String
  public var targetID: String
  public var urlString: String
  public var urlSHA256: String
  public var urlByteCount: Int
  public var shareRecordIDSHA256: String?
  public var ownerRecordNameSHA256: String?
  public var wasShared: Bool
  public var participantCount: Int?

  public init(
    targetKind: String,
    targetID: String,
    urlString: String,
    urlSHA256: String,
    urlByteCount: Int,
    shareRecordIDSHA256: String? = nil,
    ownerRecordNameSHA256: String? = nil,
    wasShared: Bool,
    participantCount: Int? = nil
  ) {
    self.targetKind = targetKind
    self.targetID = targetID
    self.urlString = urlString
    self.urlSHA256 = urlSHA256
    self.urlByteCount = urlByteCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.ownerRecordNameSHA256 = ownerRecordNameSHA256
    self.wasShared = wasShared
    self.participantCount = participantCount
  }
}

public struct NotesCollaborationLinkCopyResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var destination: String
  public var targetKind: String
  public var targetIDSHA256: String
  public var urlSHA256: String
  public var urlByteCount: Int
  public var shareRecordIDSHA256: String?
  public var ownerRecordNameSHA256: String?
  public var participantCount: Int?
  public var clipboardChangeCount: Int
  public var artifact: NotesCollaborationArtifactRecord?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    destination: String,
    targetKind: String,
    targetIDSHA256: String,
    urlSHA256: String,
    urlByteCount: Int,
    shareRecordIDSHA256: String? = nil,
    ownerRecordNameSHA256: String? = nil,
    participantCount: Int? = nil,
    clipboardChangeCount: Int,
    artifact: NotesCollaborationArtifactRecord? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.destination = destination
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.urlSHA256 = urlSHA256
    self.urlByteCount = urlByteCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.ownerRecordNameSHA256 = ownerRecordNameSHA256
    self.participantCount = participantCount
    self.clipboardChangeCount = clipboardChangeCount
    self.artifact = artifact
    self.verification = verification
  }
}

public struct NotesCollaborationArtifactRecord: Codable, Equatable, Sendable {
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var contentKind: String

  public init(destinationPath: String, byteCount: Int, sha256: String, contentKind: String) {
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.contentKind = contentKind
  }
}

public struct NotesCollaborationParticipantsDraft: Codable, Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(noteID: String? = nil, folderID: String? = nil) {
    self.noteID = noteID
    self.folderID = folderID
  }
}

public struct NotesCollaborationParticipantRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var participantIDSHA256: String
  public var userRecordNameSHA256s: [String]
  public var permissionValue: Int?
  public var permissionLabel: String?
  public var roleValue: Int?
  public var roleLabel: String?
  public var acceptanceStatusValue: Int?
  public var acceptanceStatusLabel: String?
  public var isCurrentUser: Bool?

  public init(
    ordinal: Int,
    participantIDSHA256: String,
    userRecordNameSHA256s: [String] = [],
    permissionValue: Int? = nil,
    permissionLabel: String? = nil,
    roleValue: Int? = nil,
    roleLabel: String? = nil,
    acceptanceStatusValue: Int? = nil,
    acceptanceStatusLabel: String? = nil,
    isCurrentUser: Bool? = nil
  ) {
    self.ordinal = ordinal
    self.participantIDSHA256 = participantIDSHA256
    self.userRecordNameSHA256s = userRecordNameSHA256s
    self.permissionValue = permissionValue
    self.permissionLabel = permissionLabel
    self.roleValue = roleValue
    self.roleLabel = roleLabel
    self.acceptanceStatusValue = acceptanceStatusValue
    self.acceptanceStatusLabel = acceptanceStatusLabel
    self.isCurrentUser = isCurrentUser
  }
}

public struct NotesCollaborationParticipantsReadResult: Codable, Equatable, Sendable {
  public var targetKind: String
  public var targetIDSHA256: String
  public var wasShared: Bool
  public var isReadOnly: Bool?
  public var shareRecordIDSHA256: String?
  public var ownerRecordNameSHA256: String?
  public var publicPermissionValue: Int?
  public var publicPermissionLabel: String?
  public var participantCount: Int
  public var returnedParticipantCount: Int
  public var participantIdentitySetSHA256: String
  public var participants: [NotesCollaborationParticipantRecord]

  public init(
    targetKind: String,
    targetIDSHA256: String,
    wasShared: Bool,
    isReadOnly: Bool? = nil,
    shareRecordIDSHA256: String? = nil,
    ownerRecordNameSHA256: String? = nil,
    publicPermissionValue: Int? = nil,
    publicPermissionLabel: String? = nil,
    participantCount: Int,
    participantIdentitySetSHA256: String,
    participants: [NotesCollaborationParticipantRecord]
  ) {
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.wasShared = wasShared
    self.isReadOnly = isReadOnly
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.ownerRecordNameSHA256 = ownerRecordNameSHA256
    self.publicPermissionValue = publicPermissionValue
    self.publicPermissionLabel = publicPermissionLabel
    self.participantCount = participantCount
    self.returnedParticipantCount = participants.count
    self.participantIdentitySetSHA256 = participantIdentitySetSHA256
    self.participants = participants
  }
}

public struct NotesCollaborationParticipantsResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var wasShared: Bool
  public var isReadOnly: Bool?
  public var shareRecordIDSHA256: String?
  public var ownerRecordNameSHA256: String?
  public var publicPermissionValue: Int?
  public var publicPermissionLabel: String?
  public var participantCount: Int
  public var returnedParticipantCount: Int
  public var participantIdentitySetSHA256: String
  public var participants: [NotesCollaborationParticipantRecord]
  public var artifact: NotesCollaborationArtifactRecord?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    read: NotesCollaborationParticipantsReadResult,
    artifact: NotesCollaborationArtifactRecord? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = read.targetKind
    self.targetIDSHA256 = read.targetIDSHA256
    self.wasShared = read.wasShared
    self.isReadOnly = read.isReadOnly
    self.shareRecordIDSHA256 = read.shareRecordIDSHA256
    self.ownerRecordNameSHA256 = read.ownerRecordNameSHA256
    self.publicPermissionValue = read.publicPermissionValue
    self.publicPermissionLabel = read.publicPermissionLabel
    self.participantCount = read.participantCount
    self.returnedParticipantCount = read.returnedParticipantCount
    self.participantIdentitySetSHA256 = read.participantIdentitySetSHA256
    self.participants = read.participants
    self.artifact = artifact
    self.verification = verification
  }
}

public struct NotesCollaborationPermissionMutationDraft: Codable, Equatable, Sendable {
  public var operation: String?
  public var noteID: String?
  public var folderID: String?
  public var target: String
  public var permissionValue: Int
  public var permissionLabel: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    operation: String? = nil,
    noteID: String? = nil,
    folderID: String? = nil,
    target: String,
    permissionValue: Int,
    permissionLabel: String
  ) {
    self.operation = operation
    self.noteID = noteID
    self.folderID = folderID
    self.target = target
    self.permissionValue = permissionValue
    self.permissionLabel = permissionLabel
  }
}

public struct NotesCollaborationShareMutationDraft: Codable, Equatable, Sendable {
  public var operation: String
  public var noteID: String?
  public var folderID: String?
  public var target: String
  public var permissionValue: Int
  public var permissionLabel: String
  public var createShareIfNeeded: Bool

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    operation: String,
    noteID: String? = nil,
    folderID: String? = nil,
    target: String,
    permissionValue: Int,
    permissionLabel: String,
    createShareIfNeeded: Bool
  ) {
    self.operation = operation
    self.noteID = noteID
    self.folderID = folderID
    self.target = target
    self.permissionValue = permissionValue
    self.permissionLabel = permissionLabel
    self.createShareIfNeeded = createShareIfNeeded
  }
}

public struct NotesCollaborationShareWriteResult: Equatable, Sendable {
  public var operation: String
  public var noteID: String?
  public var folderID: String?
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String?
  public var requestedPermissionValue: Int
  public var requestedPermissionLabel: String
  public var beforeWasShared: Bool
  public var afterWasShared: Bool
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var targetPresentBefore: Bool
  public var targetPresentAfter: Bool
  public var beforePermissionValue: Int?
  public var beforePermissionLabel: String?
  public var afterPermissionValue: Int?
  public var afterPermissionLabel: String?
  public var changed: Bool
  public var shareRecordIDSHA256: String?
  public var shareURLSHA256: String?
  public var backendCalls: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    operation: String,
    noteID: String? = nil,
    folderID: String? = nil,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String? = nil,
    requestedPermissionValue: Int,
    requestedPermissionLabel: String,
    beforeWasShared: Bool,
    afterWasShared: Bool,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    targetPresentBefore: Bool,
    targetPresentAfter: Bool,
    beforePermissionValue: Int? = nil,
    beforePermissionLabel: String? = nil,
    afterPermissionValue: Int? = nil,
    afterPermissionLabel: String? = nil,
    changed: Bool,
    shareRecordIDSHA256: String? = nil,
    shareURLSHA256: String? = nil,
    backendCalls: String
  ) {
    self.operation = operation
    self.noteID = noteID
    self.folderID = folderID
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.requestedPermissionValue = requestedPermissionValue
    self.requestedPermissionLabel = requestedPermissionLabel
    self.beforeWasShared = beforeWasShared
    self.afterWasShared = afterWasShared
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.targetPresentBefore = targetPresentBefore
    self.targetPresentAfter = targetPresentAfter
    self.beforePermissionValue = beforePermissionValue
    self.beforePermissionLabel = beforePermissionLabel
    self.afterPermissionValue = afterPermissionValue
    self.afterPermissionLabel = afterPermissionLabel
    self.changed = changed
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.shareURLSHA256 = shareURLSHA256
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationShareMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var noteIDSHA256: String?
  public var folderIDSHA256: String?
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String?
  public var requestedPermissionValue: Int
  public var requestedPermissionLabel: String
  public var beforeWasShared: Bool
  public var afterWasShared: Bool
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var targetPresentBefore: Bool
  public var targetPresentAfter: Bool
  public var beforePermissionValue: Int?
  public var beforePermissionLabel: String?
  public var afterPermissionValue: Int?
  public var afterPermissionLabel: String?
  public var shareRecordIDSHA256: String?
  public var shareURLSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    targetKind: String,
    targetIDSHA256: String,
    noteIDSHA256: String? = nil,
    folderIDSHA256: String? = nil,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String? = nil,
    requestedPermissionValue: Int,
    requestedPermissionLabel: String,
    beforeWasShared: Bool,
    afterWasShared: Bool,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    targetPresentBefore: Bool,
    targetPresentAfter: Bool,
    beforePermissionValue: Int? = nil,
    beforePermissionLabel: String? = nil,
    afterPermissionValue: Int? = nil,
    afterPermissionLabel: String? = nil,
    shareRecordIDSHA256: String? = nil,
    shareURLSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.noteIDSHA256 = noteIDSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.requestedPermissionValue = requestedPermissionValue
    self.requestedPermissionLabel = requestedPermissionLabel
    self.beforeWasShared = beforeWasShared
    self.afterWasShared = afterWasShared
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.targetPresentBefore = targetPresentBefore
    self.targetPresentAfter = targetPresentAfter
    self.beforePermissionValue = beforePermissionValue
    self.beforePermissionLabel = beforePermissionLabel
    self.afterPermissionValue = afterPermissionValue
    self.afterPermissionLabel = afterPermissionLabel
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.shareURLSHA256 = shareURLSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationAccessScopeMutationDraft: Codable, Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var accessScopeLabel: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(noteID: String? = nil, folderID: String? = nil, accessScopeLabel: String) {
    self.noteID = noteID
    self.folderID = folderID
    self.accessScopeLabel = accessScopeLabel
  }
}

public struct NotesCollaborationAccessScopeWriteResult: Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var requestedAccessScopeLabel: String
  public var requestedPublicPermissionValue: Int
  public var requestedPublicPermissionLabel: String
  public var beforeAccessScopeLabel: String?
  public var beforePublicPermissionValue: Int?
  public var beforePublicPermissionLabel: String?
  public var afterAccessScopeLabel: String?
  public var afterPublicPermissionValue: Int?
  public var afterPublicPermissionLabel: String?
  public var changed: Bool
  public var wasShared: Bool
  public var participantCount: Int
  public var shareRecordIDSHA256: String?
  public var backendCalls: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    noteID: String? = nil,
    folderID: String? = nil,
    requestedAccessScopeLabel: String,
    requestedPublicPermissionValue: Int,
    requestedPublicPermissionLabel: String,
    beforeAccessScopeLabel: String? = nil,
    beforePublicPermissionValue: Int? = nil,
    beforePublicPermissionLabel: String? = nil,
    afterAccessScopeLabel: String? = nil,
    afterPublicPermissionValue: Int? = nil,
    afterPublicPermissionLabel: String? = nil,
    changed: Bool,
    wasShared: Bool,
    participantCount: Int,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.folderID = folderID
    self.requestedAccessScopeLabel = requestedAccessScopeLabel
    self.requestedPublicPermissionValue = requestedPublicPermissionValue
    self.requestedPublicPermissionLabel = requestedPublicPermissionLabel
    self.beforeAccessScopeLabel = beforeAccessScopeLabel
    self.beforePublicPermissionValue = beforePublicPermissionValue
    self.beforePublicPermissionLabel = beforePublicPermissionLabel
    self.afterAccessScopeLabel = afterAccessScopeLabel
    self.afterPublicPermissionValue = afterPublicPermissionValue
    self.afterPublicPermissionLabel = afterPublicPermissionLabel
    self.changed = changed
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationAccessScopeMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var noteIDSHA256: String?
  public var folderIDSHA256: String?
  public var requestedAccessScopeLabel: String
  public var requestedPublicPermissionValue: Int
  public var requestedPublicPermissionLabel: String
  public var beforeAccessScopeLabel: String?
  public var beforePublicPermissionValue: Int?
  public var beforePublicPermissionLabel: String?
  public var afterAccessScopeLabel: String?
  public var afterPublicPermissionValue: Int?
  public var afterPublicPermissionLabel: String?
  public var wasShared: Bool
  public var participantCount: Int
  public var shareRecordIDSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    targetKind: String,
    targetIDSHA256: String,
    noteIDSHA256: String? = nil,
    folderIDSHA256: String? = nil,
    requestedAccessScopeLabel: String,
    requestedPublicPermissionValue: Int,
    requestedPublicPermissionLabel: String,
    beforeAccessScopeLabel: String? = nil,
    beforePublicPermissionValue: Int? = nil,
    beforePublicPermissionLabel: String? = nil,
    afterAccessScopeLabel: String? = nil,
    afterPublicPermissionValue: Int? = nil,
    afterPublicPermissionLabel: String? = nil,
    wasShared: Bool,
    participantCount: Int,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.noteIDSHA256 = noteIDSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.requestedAccessScopeLabel = requestedAccessScopeLabel
    self.requestedPublicPermissionValue = requestedPublicPermissionValue
    self.requestedPublicPermissionLabel = requestedPublicPermissionLabel
    self.beforeAccessScopeLabel = beforeAccessScopeLabel
    self.beforePublicPermissionValue = beforePublicPermissionValue
    self.beforePublicPermissionLabel = beforePublicPermissionLabel
    self.afterAccessScopeLabel = afterAccessScopeLabel
    self.afterPublicPermissionValue = afterPublicPermissionValue
    self.afterPublicPermissionLabel = afterPublicPermissionLabel
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationStopSharingDraft: Codable, Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(noteID: String? = nil, folderID: String? = nil) {
    self.noteID = noteID
    self.folderID = folderID
  }
}

public struct NotesCollaborationStopSharingWriteResult: Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var beforeWasShared: Bool
  public var afterWasShared: Bool
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var beforeShareRecordIDSHA256: String?
  public var afterShareRecordIDSHA256: String?
  public var changed: Bool
  public var backendCalls: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    noteID: String? = nil,
    folderID: String? = nil,
    beforeWasShared: Bool,
    afterWasShared: Bool,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    beforeShareRecordIDSHA256: String? = nil,
    afterShareRecordIDSHA256: String? = nil,
    changed: Bool,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.folderID = folderID
    self.beforeWasShared = beforeWasShared
    self.afterWasShared = afterWasShared
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.beforeShareRecordIDSHA256 = beforeShareRecordIDSHA256
    self.afterShareRecordIDSHA256 = afterShareRecordIDSHA256
    self.changed = changed
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationStopSharingResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var noteIDSHA256: String?
  public var folderIDSHA256: String?
  public var beforeWasShared: Bool
  public var afterWasShared: Bool
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var beforeShareRecordIDSHA256: String?
  public var afterShareRecordIDSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    targetKind: String,
    targetIDSHA256: String,
    noteIDSHA256: String? = nil,
    folderIDSHA256: String? = nil,
    beforeWasShared: Bool,
    afterWasShared: Bool,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    beforeShareRecordIDSHA256: String? = nil,
    afterShareRecordIDSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.noteIDSHA256 = noteIDSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.beforeWasShared = beforeWasShared
    self.afterWasShared = afterWasShared
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.beforeShareRecordIDSHA256 = beforeShareRecordIDSHA256
    self.afterShareRecordIDSHA256 = afterShareRecordIDSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationAllowInvitesDraft: Codable, Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var enabled: Bool

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(noteID: String? = nil, folderID: String? = nil, enabled: Bool) {
    self.noteID = noteID
    self.folderID = folderID
    self.enabled = enabled
  }
}

public struct NotesCollaborationAllowInvitesWriteResult: Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var requestedAllowsInvites: Bool
  public var beforeAllowsInvites: Bool
  public var afterAllowsInvites: Bool
  public var participantCount: Int
  public var eligibleParticipantCount: Int
  public var beforeAdministratorCount: Int
  public var afterAdministratorCount: Int
  public var changed: Bool
  public var wasShared: Bool
  public var shareRecordIDSHA256: String?
  public var backendCalls: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    noteID: String? = nil,
    folderID: String? = nil,
    requestedAllowsInvites: Bool,
    beforeAllowsInvites: Bool,
    afterAllowsInvites: Bool,
    participantCount: Int,
    eligibleParticipantCount: Int,
    beforeAdministratorCount: Int,
    afterAdministratorCount: Int,
    changed: Bool,
    wasShared: Bool,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.folderID = folderID
    self.requestedAllowsInvites = requestedAllowsInvites
    self.beforeAllowsInvites = beforeAllowsInvites
    self.afterAllowsInvites = afterAllowsInvites
    self.participantCount = participantCount
    self.eligibleParticipantCount = eligibleParticipantCount
    self.beforeAdministratorCount = beforeAdministratorCount
    self.afterAdministratorCount = afterAdministratorCount
    self.changed = changed
    self.wasShared = wasShared
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationAllowInvitesResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var noteIDSHA256: String?
  public var folderIDSHA256: String?
  public var requestedAllowsInvites: Bool
  public var beforeAllowsInvites: Bool
  public var afterAllowsInvites: Bool
  public var participantCount: Int
  public var eligibleParticipantCount: Int
  public var beforeAdministratorCount: Int
  public var afterAdministratorCount: Int
  public var shareRecordIDSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    targetKind: String,
    targetIDSHA256: String,
    noteIDSHA256: String? = nil,
    folderIDSHA256: String? = nil,
    requestedAllowsInvites: Bool,
    beforeAllowsInvites: Bool,
    afterAllowsInvites: Bool,
    participantCount: Int,
    eligibleParticipantCount: Int,
    beforeAdministratorCount: Int,
    afterAdministratorCount: Int,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.noteIDSHA256 = noteIDSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.requestedAllowsInvites = requestedAllowsInvites
    self.beforeAllowsInvites = beforeAllowsInvites
    self.afterAllowsInvites = afterAllowsInvites
    self.participantCount = participantCount
    self.eligibleParticipantCount = eligibleParticipantCount
    self.beforeAdministratorCount = beforeAdministratorCount
    self.afterAdministratorCount = afterAdministratorCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationSelfRemovalDraft: Codable, Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(noteID: String? = nil, folderID: String? = nil) {
    self.noteID = noteID
    self.folderID = folderID
  }
}

public struct NotesCollaborationSelfRemovalWriteResult: Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var beforeWasShared: Bool
  public var beforeCurrentUserPresent: Bool
  public var afterCurrentUserPresent: Bool
  public var currentUserParticipantIDSHA256: String
  public var currentUserRecordNameSHA256: String?
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var changed: Bool
  public var shareRecordIDSHA256: String?
  public var backendCalls: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    noteID: String? = nil,
    folderID: String? = nil,
    beforeWasShared: Bool,
    beforeCurrentUserPresent: Bool,
    afterCurrentUserPresent: Bool,
    currentUserParticipantIDSHA256: String,
    currentUserRecordNameSHA256: String? = nil,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    changed: Bool,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.folderID = folderID
    self.beforeWasShared = beforeWasShared
    self.beforeCurrentUserPresent = beforeCurrentUserPresent
    self.afterCurrentUserPresent = afterCurrentUserPresent
    self.currentUserParticipantIDSHA256 = currentUserParticipantIDSHA256
    self.currentUserRecordNameSHA256 = currentUserRecordNameSHA256
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.changed = changed
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationSelfRemovalResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var noteIDSHA256: String?
  public var folderIDSHA256: String?
  public var beforeWasShared: Bool
  public var beforeCurrentUserPresent: Bool
  public var afterCurrentUserPresent: Bool
  public var currentUserParticipantIDSHA256: String
  public var currentUserRecordNameSHA256: String?
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var shareRecordIDSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    targetKind: String,
    targetIDSHA256: String,
    noteIDSHA256: String? = nil,
    folderIDSHA256: String? = nil,
    beforeWasShared: Bool,
    beforeCurrentUserPresent: Bool,
    afterCurrentUserPresent: Bool,
    currentUserParticipantIDSHA256: String,
    currentUserRecordNameSHA256: String? = nil,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.noteIDSHA256 = noteIDSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.beforeWasShared = beforeWasShared
    self.beforeCurrentUserPresent = beforeCurrentUserPresent
    self.afterCurrentUserPresent = afterCurrentUserPresent
    self.currentUserParticipantIDSHA256 = currentUserParticipantIDSHA256
    self.currentUserRecordNameSHA256 = currentUserRecordNameSHA256
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationPermissionWriteResult: Equatable, Sendable {
  public var noteID: String?
  public var folderID: String?
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String?
  public var requestedPermissionValue: Int
  public var requestedPermissionLabel: String
  public var beforePermissionValue: Int?
  public var beforePermissionLabel: String?
  public var afterPermissionValue: Int?
  public var afterPermissionLabel: String?
  public var changed: Bool
  public var wasShared: Bool
  public var participantCount: Int
  public var shareRecordIDSHA256: String?
  public var backendCalls: String

  public var targetID: String {
    noteID ?? folderID ?? ""
  }

  public var targetKind: String {
    noteID == nil ? "folder" : "note"
  }

  public init(
    noteID: String? = nil,
    folderID: String? = nil,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String? = nil,
    requestedPermissionValue: Int,
    requestedPermissionLabel: String,
    beforePermissionValue: Int? = nil,
    beforePermissionLabel: String? = nil,
    afterPermissionValue: Int? = nil,
    afterPermissionLabel: String? = nil,
    changed: Bool,
    wasShared: Bool,
    participantCount: Int,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.folderID = folderID
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.requestedPermissionValue = requestedPermissionValue
    self.requestedPermissionLabel = requestedPermissionLabel
    self.beforePermissionValue = beforePermissionValue
    self.beforePermissionLabel = beforePermissionLabel
    self.afterPermissionValue = afterPermissionValue
    self.afterPermissionLabel = afterPermissionLabel
    self.changed = changed
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationPermissionMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var targetKind: String
  public var targetIDSHA256: String
  public var noteIDSHA256: String?
  public var folderIDSHA256: String?
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String?
  public var requestedPermissionValue: Int
  public var requestedPermissionLabel: String
  public var beforePermissionValue: Int?
  public var beforePermissionLabel: String?
  public var afterPermissionValue: Int?
  public var afterPermissionLabel: String?
  public var wasShared: Bool
  public var participantCount: Int
  public var shareRecordIDSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    targetKind: String,
    targetIDSHA256: String,
    noteIDSHA256: String? = nil,
    folderIDSHA256: String? = nil,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String? = nil,
    requestedPermissionValue: Int,
    requestedPermissionLabel: String,
    beforePermissionValue: Int? = nil,
    beforePermissionLabel: String? = nil,
    afterPermissionValue: Int? = nil,
    afterPermissionLabel: String? = nil,
    wasShared: Bool,
    participantCount: Int,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.targetKind = targetKind
    self.targetIDSHA256 = targetIDSHA256
    self.noteIDSHA256 = noteIDSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.requestedPermissionValue = requestedPermissionValue
    self.requestedPermissionLabel = requestedPermissionLabel
    self.beforePermissionValue = beforePermissionValue
    self.beforePermissionLabel = beforePermissionLabel
    self.afterPermissionValue = afterPermissionValue
    self.afterPermissionLabel = afterPermissionLabel
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationParticipantRemovalDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var target: String

  public init(noteID: String, target: String) {
    self.noteID = noteID
    self.target = target
  }
}

public struct NotesCollaborationParticipantRemovalWriteResult: Equatable, Sendable {
  public var noteID: String
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String?
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var targetPresentAfter: Bool
  public var changed: Bool
  public var wasShared: Bool
  public var shareRecordIDSHA256: String?
  public var backendCalls: String

  public init(
    noteID: String,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String? = nil,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    targetPresentAfter: Bool,
    changed: Bool,
    wasShared: Bool,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.targetPresentAfter = targetPresentAfter
    self.changed = changed
    self.wasShared = wasShared
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationParticipantRemovalResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String?
  public var beforeParticipantCount: Int
  public var afterParticipantCount: Int
  public var targetPresentAfter: Bool
  public var wasShared: Bool
  public var shareRecordIDSHA256: String?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String? = nil,
    beforeParticipantCount: Int,
    afterParticipantCount: Int,
    targetPresentAfter: Bool,
    wasShared: Bool,
    shareRecordIDSHA256: String? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.beforeParticipantCount = beforeParticipantCount
    self.afterParticipantCount = afterParticipantCount
    self.targetPresentAfter = targetPresentAfter
    self.wasShared = wasShared
    self.shareRecordIDSHA256 = shareRecordIDSHA256
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesCollaborationMentionDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var target: String
  public var text: String?

  public init(noteID: String, target: String, text: String? = nil) {
    self.noteID = noteID
    self.target = target
    self.text = text
  }
}

public struct NotesCollaborationMentionWriteResult: Equatable, Sendable {
  public var noteID: String
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String
  public var mentionTextSHA256: String
  public var mentionTextByteCount: Int
  public var beforeMentionCount: Int
  public var afterMentionCount: Int
  public var targetBeforeMentionCount: Int
  public var targetAfterMentionCount: Int
  public var insertedAttachmentIDSHA256: String?
  public var insertedIdentifierSHA256: String?
  public var wasShared: Bool
  public var participantCount: Int
  public var backendCalls: String

  public init(
    noteID: String,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String,
    mentionTextSHA256: String,
    mentionTextByteCount: Int,
    beforeMentionCount: Int,
    afterMentionCount: Int,
    targetBeforeMentionCount: Int,
    targetAfterMentionCount: Int,
    insertedAttachmentIDSHA256: String? = nil,
    insertedIdentifierSHA256: String? = nil,
    wasShared: Bool,
    participantCount: Int,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.mentionTextSHA256 = mentionTextSHA256
    self.mentionTextByteCount = mentionTextByteCount
    self.beforeMentionCount = beforeMentionCount
    self.afterMentionCount = afterMentionCount
    self.targetBeforeMentionCount = targetBeforeMentionCount
    self.targetAfterMentionCount = targetAfterMentionCount
    self.insertedAttachmentIDSHA256 = insertedAttachmentIDSHA256
    self.insertedIdentifierSHA256 = insertedIdentifierSHA256
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.backendCalls = backendCalls
  }
}

public struct NotesCollaborationMentionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var targetSHA256: String
  public var targetParticipantIDSHA256: String
  public var targetUserRecordNameSHA256: String
  public var mentionTextSHA256: String
  public var mentionTextByteCount: Int
  public var beforeMentionCount: Int
  public var afterMentionCount: Int
  public var targetBeforeMentionCount: Int
  public var targetAfterMentionCount: Int
  public var insertedAttachmentIDSHA256: String?
  public var insertedIdentifierSHA256: String?
  public var wasShared: Bool
  public var participantCount: Int
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    targetSHA256: String,
    targetParticipantIDSHA256: String,
    targetUserRecordNameSHA256: String,
    mentionTextSHA256: String,
    mentionTextByteCount: Int,
    beforeMentionCount: Int,
    afterMentionCount: Int,
    targetBeforeMentionCount: Int,
    targetAfterMentionCount: Int,
    insertedAttachmentIDSHA256: String? = nil,
    insertedIdentifierSHA256: String? = nil,
    wasShared: Bool,
    participantCount: Int,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.targetSHA256 = targetSHA256
    self.targetParticipantIDSHA256 = targetParticipantIDSHA256
    self.targetUserRecordNameSHA256 = targetUserRecordNameSHA256
    self.mentionTextSHA256 = mentionTextSHA256
    self.mentionTextByteCount = mentionTextByteCount
    self.beforeMentionCount = beforeMentionCount
    self.afterMentionCount = afterMentionCount
    self.targetBeforeMentionCount = targetBeforeMentionCount
    self.targetAfterMentionCount = targetAfterMentionCount
    self.insertedAttachmentIDSHA256 = insertedAttachmentIDSHA256
    self.insertedIdentifierSHA256 = insertedIdentifierSHA256
    self.wasShared = wasShared
    self.participantCount = participantCount
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public func notesSettingsOfficialFamilyIDs() -> [String] {
  [
    "sort_notes_by",
    "new_notes_start_with",
    "default_account",
    "group_notes_by_date",
    "default_date_headers_type",
    "query_date_headers_type",
    "always_resume_to_last_quick_note",
    "automatically_sort_checked_items",
    "allow_mention_notifications",
    "enable_on_my_mac_account",
    "default_text_size",
    "locked_notes",
    "change_password",
    "reset_password",
    "use_touch_id",
    "view_layout",
    "link_and_highlight_color",
  ]
}

public func notesSettingsFamilies(
  defaultAccountIDSHA256: String?,
  onMyMacAccountPresent: Bool,
  currentNoteListSortSHA256: String? = nil,
  defaultParagraphStyleSHA256: String? = nil,
  groupNotesByDateEnabled: Bool? = nil,
  defaultDateHeadersTypeSHA256: String? = nil,
  queryDateHeadersTypeSHA256: String? = nil,
  supportsQueryDateHeaders: Bool? = nil,
  showsQueryDateHeaders: Bool? = nil,
  quickNoteResumeLastEnabled: Bool? = nil,
  mentionNotificationsEnabled: Bool? = nil,
  checklistAutoSortEnabled: Bool? = nil,
  defaultTextSizeSHA256: String? = nil,
  touchIDPreferenceAvailable: Bool = false,
  touchIDPreferenceEnabled: Bool? = nil,
  lockedNotesPassphraseSet: Bool? = nil,
  lockedNotesStateSHA256: String? = nil
) -> [NotesSettingsFamilyRecord] {
  [
    NotesSettingsFamilyRecord(
      id: "sort_notes_by",
      label: "Sort notes by",
      status: currentNoteListSortSHA256 == nil ? "gated" : "supported",
      valueKind: currentNoteListSortSHA256 == nil ? nil : "note_list_sort_sha256",
      valueSHA256: currentNoteListSortSHA256,
      evidence: currentNoteListSortSHA256 == nil
        ? "no_accepted_global_settings_readback"
        : "ICNoteListSortUtilities.currentNoteListSortType",
      notes: "Folder custom sort is supported separately by folders sort."
    ),
    NotesSettingsFamilyRecord(
      id: "new_notes_start_with",
      label: "New notes start with",
      status: defaultParagraphStyleSHA256 == nil ? "gated" : "supported",
      valueKind: defaultParagraphStyleSHA256 == nil ? nil : "paragraph_style_sha256",
      valueSHA256: defaultParagraphStyleSHA256,
      evidence: defaultParagraphStyleSHA256 == nil
        ? "no_accepted_default_paragraph_style_readback"
        : "ICTextStyle.noteDefaultNamedStyle"
    ),
    NotesSettingsFamilyRecord(
      id: "default_account",
      label: "Default account",
      status: "supported",
      valueKind: "account_id_sha256",
      valueSHA256: defaultAccountIDSHA256,
      evidence: "ICDefaultAccountUtilities.defaultAccount"
    ),
    NotesSettingsFamilyRecord(
      id: "group_notes_by_date",
      label: "Group notes by date",
      status: groupNotesByDateEnabled == nil ? "gated" : "supported",
      valueKind: groupNotesByDateEnabled == nil ? nil : "bool",
      boolValue: groupNotesByDateEnabled,
      evidence: groupNotesByDateEnabled == nil
        ? "no_accepted_global_grouping_readback"
        : "ICDateHeadersUtilities.currentDateHeadersOn",
      notes: "Folder date-header state is supported separately by folders date-headers."
    ),
    NotesSettingsFamilyRecord(
      id: "default_date_headers_type",
      label: "Default date-header type",
      status: defaultDateHeadersTypeSHA256 == nil ? "gated" : "supported",
      valueKind: defaultDateHeadersTypeSHA256 == nil ? nil : "date_headers_type_sha256",
      valueSHA256: defaultDateHeadersTypeSHA256,
      evidence: defaultDateHeadersTypeSHA256 == nil
        ? "no_accepted_default_date_headers_type_readback"
        : "ICDateHeadersUtilities.defaultDateHeadersType",
      notes: "This is the private default date-header type; it is exposed as hash-only enum evidence."
    ),
    NotesSettingsFamilyRecord(
      id: "query_date_headers_type",
      label: "Query date-header type",
      status: queryDateHeadersTypeSHA256 == nil ? "gated" : "supported",
      valueKind: queryDateHeadersTypeSHA256 == nil ? nil : "date_headers_type_sha256",
      boolValue: showsQueryDateHeaders,
      valueSHA256: queryDateHeadersTypeSHA256,
      evidence: queryDateHeadersTypeSHA256 == nil
        ? "no_accepted_query_date_headers_type_readback"
        : "ICDateHeadersUtilities.queryDateHeadersType",
      notes: supportsQueryDateHeaders == false
        ? "The linked private framework reports query date headers as unsupported on this host."
        : "This is the private query date-header type; it is exposed as hash-only enum evidence."
    ),
    NotesSettingsFamilyRecord(
      id: "always_resume_to_last_quick_note",
      label: "Always resume to last Quick Note",
      status: quickNoteResumeLastEnabled == nil ? "gated" : "supported",
      valueKind: quickNoteResumeLastEnabled == nil ? nil : "bool",
      boolValue: quickNoteResumeLastEnabled,
      evidence: quickNoteResumeLastEnabled == nil
        ? "no_accepted_quick_note_preference_readback"
        : "ICPaperCommonUtilities.shouldResumeLastQuickNote"
    ),
    NotesSettingsFamilyRecord(
      id: "automatically_sort_checked_items",
      label: "Automatically sort checked items",
      status: checklistAutoSortEnabled == nil ? "gated" : "supported",
      valueKind: checklistAutoSortEnabled == nil ? nil : "bool",
      boolValue: checklistAutoSortEnabled,
      evidence: checklistAutoSortEnabled == nil
        ? "no_accepted_global_checklist_sort_preference_readback"
        : "ICTextController.checklistAutoSortEnabled",
      notes: "Per-note checklist sorting is supported separately by body checklist sort."
    ),
    NotesSettingsFamilyRecord(
      id: "allow_mention_notifications",
      label: "Allow mention notifications",
      status: mentionNotificationsEnabled == nil ? "gated" : "supported",
      valueKind: mentionNotificationsEnabled == nil ? nil : "bool",
      boolValue: mentionNotificationsEnabled,
      evidence: mentionNotificationsEnabled == nil
        ? "no_accepted_mention_notification_preference_readback"
        : "ICSettingsUtilities.bool(forKey:ICMentionNotificationsPrefIdentifier)",
      notes: "This controls the Notes mention-notification preference; system notification delivery remains delegated."
    ),
    NotesSettingsFamilyRecord(
      id: "enable_on_my_mac_account",
      label: "Enable the On My Mac account",
      status: "supported",
      valueKind: "bool",
      boolValue: onMyMacAccountPresent,
      evidence: "ICAccount.isLocalAccount"
    ),
    NotesSettingsFamilyRecord(
      id: "default_text_size",
      label: "Default text size",
      status: defaultTextSizeSHA256 == nil ? "gated" : "supported",
      valueKind: defaultTextSizeSHA256 == nil ? nil : "text_size_sha256",
      valueSHA256: defaultTextSizeSHA256,
      evidence: defaultTextSizeSHA256 == nil
        ? "no_accepted_text_size_preference_readback"
        : "ICMZoomController.globalZoomFactorIndex"
    ),
    NotesSettingsFamilyRecord(
      id: "locked_notes",
      label: "Locked notes",
      status: lockedNotesPassphraseSet == nil ? "gated" : "supported",
      valueKind: lockedNotesPassphraseSet == nil ? nil : "account_passphrase_state",
      boolValue: lockedNotesPassphraseSet,
      valueSHA256: lockedNotesStateSHA256,
      evidence: lockedNotesPassphraseSet == nil
        ? "password_settings_boundary"
        : "ICAccount.cryptoStrategy.hasPassphraseSet",
      notes: lockedNotesPassphraseSet == nil
        ? nil
        : "For a selected account, this reports password setup state and a hint hash only; it never prints password or hint text."
    ),
    NotesSettingsFamilyRecord(
      id: "change_password",
      label: "Change password",
      status: "gated",
      evidence: "password_settings_mutation_boundary"
    ),
    NotesSettingsFamilyRecord(
      id: "reset_password",
      label: "Reset password",
      status: "gated",
      evidence: "password_settings_mutation_boundary"
    ),
    NotesSettingsFamilyRecord(
      id: "use_touch_id",
      label: "Use Touch ID",
      status: touchIDPreferenceAvailable ? "supported" : "gated",
      valueKind: touchIDPreferenceAvailable ? "account_scoped_bool" : nil,
      boolValue: touchIDPreferenceEnabled,
      evidence: touchIDPreferenceAvailable
        ? "ICAuthenticationState.biometricsEnabledForAccount"
        : "password_settings_boundary",
      notes: touchIDPreferenceAvailable
        ? "This is the Notes account-scoped Touch ID preference. Biometric authentication remains delegated to macOS LocalAuthentication."
        : nil
    ),
    NotesSettingsFamilyRecord(
      id: "view_layout",
      label: "View as list or gallery",
      status: "delegated",
      evidence: "notes_window_view_surface"
    ),
    NotesSettingsFamilyRecord(
      id: "link_and_highlight_color",
      label: "Link and highlight color",
      status: "delegated",
      evidence: "macos_appearance_settings"
    ),
  ]
}

public struct NotesFolderRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var accountName: String
  public var parentID: String?
  public var isRootLevel: Bool?
  public var parentPresent: Bool
  public var depth: Int?
  public var folderType: Int?
  public var visibleNoteCount: Int?
  public var childFolderCount: Int?
  public var isDefault: Bool?
  public var isTrash: Bool?
  public var isSmartFolder: Bool?
  public var isSystemFolder: Bool?
  public var isLeaf: Bool?
  public var isRenamable: Bool?
  public var isMovable: Bool?
  public var isDeletable: Bool?
  public var isPurgable: Bool?
  public var canAddSubfolder: Bool?
  public var supportsEditingNotes: Bool?
  public var noteSortTypeValue: Int?
  public var supportsCustomNoteSortType: Bool?
  public var customNoteSortOrder: Int?
  public var customNoteSortDirection: Int?
  public var customNoteSortIsDefault: Bool?
  public var customNoteSortIsAscending: Bool?
  public var customNoteSortResolvedOrder: Int?
  public var customNoteSortDescription: String?
  public var supportsDateHeaders: Bool?
  public var isShowingDateHeaders: Bool?
  public var dateHeadersTypeValue: Int?
  public var isSharedViaICloud: Bool?
  public var isSharedReadOnly: Bool?
  public var isSubfolderOfReadOnlyFolder: Bool?
  public var siblingOrderIndex: Int?
  public var siblingOrderCount: Int?
  public var siblingOrderSHA256: String?

  public init(
    id: String,
    name: String,
    accountName: String,
    parentID: String? = nil,
    isRootLevel: Bool? = nil,
    parentPresent: Bool = false,
    depth: Int? = nil,
    folderType: Int? = nil,
    visibleNoteCount: Int? = nil,
    childFolderCount: Int? = nil,
    isDefault: Bool? = nil,
    isTrash: Bool? = nil,
    isSmartFolder: Bool? = nil,
    isSystemFolder: Bool? = nil,
    isLeaf: Bool? = nil,
    isRenamable: Bool? = nil,
    isMovable: Bool? = nil,
    isDeletable: Bool? = nil,
    isPurgable: Bool? = nil,
    canAddSubfolder: Bool? = nil,
    supportsEditingNotes: Bool? = nil,
    noteSortTypeValue: Int? = nil,
    supportsCustomNoteSortType: Bool? = nil,
    customNoteSortOrder: Int? = nil,
    customNoteSortDirection: Int? = nil,
    customNoteSortIsDefault: Bool? = nil,
    customNoteSortIsAscending: Bool? = nil,
    customNoteSortResolvedOrder: Int? = nil,
    customNoteSortDescription: String? = nil,
    supportsDateHeaders: Bool? = nil,
    isShowingDateHeaders: Bool? = nil,
    dateHeadersTypeValue: Int? = nil,
    isSharedViaICloud: Bool? = nil,
    isSharedReadOnly: Bool? = nil,
    isSubfolderOfReadOnlyFolder: Bool? = nil,
    siblingOrderIndex: Int? = nil,
    siblingOrderCount: Int? = nil,
    siblingOrderSHA256: String? = nil
  ) {
    self.id = id
    self.name = name
    self.accountName = accountName
    self.parentID = parentID
    self.isRootLevel = isRootLevel
    self.parentPresent = parentPresent
    self.depth = depth
    self.folderType = folderType
    self.visibleNoteCount = visibleNoteCount
    self.childFolderCount = childFolderCount
    self.isDefault = isDefault
    self.isTrash = isTrash
    self.isSmartFolder = isSmartFolder
    self.isSystemFolder = isSystemFolder
    self.isLeaf = isLeaf
    self.isRenamable = isRenamable
    self.isMovable = isMovable
    self.isDeletable = isDeletable
    self.isPurgable = isPurgable
    self.canAddSubfolder = canAddSubfolder
    self.supportsEditingNotes = supportsEditingNotes
    self.noteSortTypeValue = noteSortTypeValue
    self.supportsCustomNoteSortType = supportsCustomNoteSortType
    self.customNoteSortOrder = customNoteSortOrder
    self.customNoteSortDirection = customNoteSortDirection
    self.customNoteSortIsDefault = customNoteSortIsDefault
    self.customNoteSortIsAscending = customNoteSortIsAscending
    self.customNoteSortResolvedOrder = customNoteSortResolvedOrder
    self.customNoteSortDescription = customNoteSortDescription
    self.supportsDateHeaders = supportsDateHeaders
    self.isShowingDateHeaders = isShowingDateHeaders
    self.dateHeadersTypeValue = dateHeadersTypeValue
    self.isSharedViaICloud = isSharedViaICloud
    self.isSharedReadOnly = isSharedReadOnly
    self.isSubfolderOfReadOnlyFolder = isSubfolderOfReadOnlyFolder
    self.siblingOrderIndex = siblingOrderIndex
    self.siblingOrderCount = siblingOrderCount
    self.siblingOrderSHA256 = siblingOrderSHA256
  }
}

public struct NotesNoteSummary: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var folderName: String
  public var accountName: String
  public var createdAt: Date?
  public var updatedAt: Date?

  public init(
    id: String,
    title: String,
    folderName: String,
    accountName: String,
    createdAt: Date? = nil,
    updatedAt: Date? = nil
  ) {
    self.id = id
    self.title = title
    self.folderName = folderName
    self.accountName = accountName
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

public struct NotesNoteDetail: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var folderName: String
  public var accountName: String
  public var body: String?
  public var createdAt: Date?
  public var updatedAt: Date?
  public var tags: [NotesTagRecord]

  public init(
    id: String,
    title: String,
    folderName: String,
    accountName: String,
    body: String? = nil,
    createdAt: Date? = nil,
    updatedAt: Date? = nil,
    tags: [NotesTagRecord] = []
  ) {
    self.id = id
    self.title = title
    self.folderName = folderName
    self.accountName = accountName
    self.body = body
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.tags = tags
  }
}

public struct NotesTagRecord: Codable, Equatable, Sendable {
  public var id: String
  public var displayText: String
  public var standardizedContent: String?
  public var accountName: String
  public var visibleUseCount: Int?

  public init(
    id: String,
    displayText: String,
    standardizedContent: String? = nil,
    accountName: String,
    visibleUseCount: Int? = nil
  ) {
    self.id = id
    self.displayText = displayText
    self.standardizedContent = standardizedContent
    self.accountName = accountName
    self.visibleUseCount = visibleUseCount
  }
}

public struct NotesAttachmentRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String?
  public var typeUTI: String?
  public var contentIdentifier: String?
  public var attachmentType: Int?
  public var fileSizeBytes: Int64?
  public var mediaFilename: String?
  public var isInline: Bool
  public var isDeletedOrInTrash: Bool?
  public var imageDescriptionPresent: Bool?
  public var imageDescriptionByteCount: Int?
  public var imageDescriptionSHA256: String?
  public var imageDescriptionSourceKind: String?
  public var imageClassificationSummaryPresent: Bool?
  public var imageClassificationSummaryByteCount: Int?
  public var imageClassificationSummarySHA256: String?
  public var imageClassificationSummaryVersion: Int?
  public var imageClassificationSummarySourceKind: String?

  public init(
    id: String,
    title: String? = nil,
    typeUTI: String? = nil,
    contentIdentifier: String? = nil,
    attachmentType: Int? = nil,
    fileSizeBytes: Int64? = nil,
    mediaFilename: String? = nil,
    isInline: Bool = false,
    isDeletedOrInTrash: Bool? = nil,
    imageDescriptionPresent: Bool? = nil,
    imageDescriptionByteCount: Int? = nil,
    imageDescriptionSHA256: String? = nil,
    imageDescriptionSourceKind: String? = nil,
    imageClassificationSummaryPresent: Bool? = nil,
    imageClassificationSummaryByteCount: Int? = nil,
    imageClassificationSummarySHA256: String? = nil,
    imageClassificationSummaryVersion: Int? = nil,
    imageClassificationSummarySourceKind: String? = nil
  ) {
    self.id = id
    self.title = title
    self.typeUTI = typeUTI
    self.contentIdentifier = contentIdentifier
    self.attachmentType = attachmentType
    self.fileSizeBytes = fileSizeBytes
    self.mediaFilename = mediaFilename
    self.isInline = isInline
    self.isDeletedOrInTrash = isDeletedOrInTrash
    self.imageDescriptionPresent = imageDescriptionPresent
    self.imageDescriptionByteCount = imageDescriptionByteCount
    self.imageDescriptionSHA256 = imageDescriptionSHA256
    self.imageDescriptionSourceKind = imageDescriptionSourceKind
    self.imageClassificationSummaryPresent = imageClassificationSummaryPresent
    self.imageClassificationSummaryByteCount = imageClassificationSummaryByteCount
    self.imageClassificationSummarySHA256 = imageClassificationSummarySHA256
    self.imageClassificationSummaryVersion = imageClassificationSummaryVersion
    self.imageClassificationSummarySourceKind = imageClassificationSummarySourceKind
  }
}

public struct NotesAttachmentImageObjectSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var classificationSummaryText: String?
  public var classificationSummaryVersion: Int?
  public var sourceKind: String
  public var backendCalls: [String]

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    classificationSummaryText: String?,
    classificationSummaryVersion: Int?,
    sourceKind: String,
    backendCalls: [String]
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.classificationSummaryText = classificationSummaryText
    self.classificationSummaryVersion = classificationSummaryVersion
    self.sourceKind = sourceKind
    self.backendCalls = backendCalls
  }
}

public struct NotesAttachmentImageObjectResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var classificationSummaryPresent: Bool
  public var classificationSummaryByteCount: Int?
  public var classificationSummarySHA256: String?
  public var classificationSummaryVersion: Int?
  public var queryByteCount: Int?
  public var querySHA256: String?
  public var queryMatchCount: Int?
  public var sourceKind: String
  public var backendCalls: [String]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    classificationSummaryPresent: Bool,
    classificationSummaryByteCount: Int? = nil,
    classificationSummarySHA256: String? = nil,
    classificationSummaryVersion: Int? = nil,
    queryByteCount: Int? = nil,
    querySHA256: String? = nil,
    queryMatchCount: Int? = nil,
    sourceKind: String,
    backendCalls: [String],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.classificationSummaryPresent = classificationSummaryPresent
    self.classificationSummaryByteCount = classificationSummaryByteCount
    self.classificationSummarySHA256 = classificationSummarySHA256
    self.classificationSummaryVersion = classificationSummaryVersion
    self.queryByteCount = queryByteCount
    self.querySHA256 = querySHA256
    self.queryMatchCount = queryMatchCount
    self.sourceKind = sourceKind
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesAttachmentImageDescriptionSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var descriptionText: String?
  public var sourceKind: String

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    descriptionText: String?,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.descriptionText = descriptionText
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentImageDescriptionDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var descriptionText: String

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    descriptionText: String
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.descriptionText = descriptionText
  }
}

public struct NotesAttachmentImageDescriptionWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldSource: NotesAttachmentImageDescriptionSource
  public var source: NotesAttachmentImageDescriptionSource
  public var changed: Bool

  public init(
    noteID: String,
    oldSource: NotesAttachmentImageDescriptionSource,
    source: NotesAttachmentImageDescriptionSource,
    changed: Bool
  ) {
    self.noteID = noteID
    self.oldSource = oldSource
    self.source = source
    self.changed = changed
  }
}

public struct NotesAttachmentImageDescriptionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var descriptionPresent: Bool
  public var descriptionByteCount: Int?
  public var descriptionSHA256: String?
  public var previousDescriptionPresent: Bool?
  public var previousDescriptionByteCount: Int?
  public var previousDescriptionSHA256: String?
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    descriptionPresent: Bool,
    descriptionByteCount: Int? = nil,
    descriptionSHA256: String? = nil,
    previousDescriptionPresent: Bool? = nil,
    previousDescriptionByteCount: Int? = nil,
    previousDescriptionSHA256: String? = nil,
    sourceKind: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.descriptionPresent = descriptionPresent
    self.descriptionByteCount = descriptionByteCount
    self.descriptionSHA256 = descriptionSHA256
    self.previousDescriptionPresent = previousDescriptionPresent
    self.previousDescriptionByteCount = previousDescriptionByteCount
    self.previousDescriptionSHA256 = previousDescriptionSHA256
    self.sourceKind = sourceKind
    self.verification = verification
  }
}

public struct NotesAttachmentExportSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var data: Data

  public init(noteID: String, attachment: NotesAttachmentRecord, data: Data) {
    self.noteID = noteID
    self.attachment = attachment
    self.data = data
  }
}

public struct NotesAttachmentPDFExportSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var data: Data
  public var sourceKind: String

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    data: Data,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.data = data
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentScanPDFInspectionSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var pdfDataByteCount: Int?
  public var pdfDataSHA256: String?
  public var pdfPageCount: Int?
  public var pdfSourceKind: String?
  public var croppingQuadPresent: Bool
  public var croppingQuadSHA256: String?
  public var scannedDocumentsMetadataPresent: Bool
  public var scannedDocumentsMetadataCount: Int?
  public var scannedDocumentsMetadataSHA256: String?
  public var docCamPDFVersion: Int?
  public var orientation: Int?
  public var orientationSHA256: String?
  public var imageFilterType: Int?
  public var imageFilterTypeSHA256: String?
  public var sourceKinds: [String]

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    pdfDataByteCount: Int? = nil,
    pdfDataSHA256: String? = nil,
    pdfPageCount: Int? = nil,
    pdfSourceKind: String? = nil,
    croppingQuadPresent: Bool = false,
    croppingQuadSHA256: String? = nil,
    scannedDocumentsMetadataPresent: Bool = false,
    scannedDocumentsMetadataCount: Int? = nil,
    scannedDocumentsMetadataSHA256: String? = nil,
    docCamPDFVersion: Int? = nil,
    orientation: Int? = nil,
    orientationSHA256: String? = nil,
    imageFilterType: Int? = nil,
    imageFilterTypeSHA256: String? = nil,
    sourceKinds: [String] = []
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.pdfDataByteCount = pdfDataByteCount
    self.pdfDataSHA256 = pdfDataSHA256
    self.pdfPageCount = pdfPageCount
    self.pdfSourceKind = pdfSourceKind
    self.croppingQuadPresent = croppingQuadPresent
    self.croppingQuadSHA256 = croppingQuadSHA256
    self.scannedDocumentsMetadataPresent = scannedDocumentsMetadataPresent
    self.scannedDocumentsMetadataCount = scannedDocumentsMetadataCount
    self.scannedDocumentsMetadataSHA256 = scannedDocumentsMetadataSHA256
    self.docCamPDFVersion = docCamPDFVersion
    self.orientation = orientation
    self.orientationSHA256 = orientationSHA256
    self.imageFilterType = imageFilterType
    self.imageFilterTypeSHA256 = imageFilterTypeSHA256
    self.sourceKinds = sourceKinds
  }
}

public struct NotesAttachmentMarkupInspectionSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var attachmentDataByteCount: Int
  public var attachmentDataSHA256: String
  public var markupModelData: Data?
  public var sourceKind: String

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    attachmentDataByteCount: Int,
    attachmentDataSHA256: String,
    markupModelData: Data?,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.attachmentDataByteCount = attachmentDataByteCount
    self.attachmentDataSHA256 = attachmentDataSHA256
    self.markupModelData = markupModelData
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentAudioTranscriptSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var transcriptText: String?
  public var recordingSummaryText: String?
  public var topLineSummaryText: String?
  public var transcriptVersion: Int?
  public var sourceKind: String

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    transcriptText: String? = nil,
    recordingSummaryText: String? = nil,
    topLineSummaryText: String? = nil,
    transcriptVersion: Int? = nil,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.transcriptText = transcriptText
    self.recordingSummaryText = recordingSummaryText
    self.topLineSummaryText = topLineSummaryText
    self.transcriptVersion = transcriptVersion
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentSearchableTextContentSource: Equatable, Sendable {
  public var kind: String
  public var text: String
  public var sourceKind: String

  public init(kind: String, text: String, sourceKind: String) {
    self.kind = kind
    self.text = text
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentSearchableTextSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var content: [NotesAttachmentSearchableTextContentSource]

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    content: [NotesAttachmentSearchableTextContentSource]
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.content = content
  }
}

public struct NotesAttachmentRecognizedTextGenerationInput: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var attachmentFamily: String
  public var data: Data
  public var sourceKind: String
  public var usesPDFExport: Bool

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    attachmentFamily: String,
    data: Data,
    sourceKind: String,
    usesPDFExport: Bool
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.attachmentFamily = attachmentFamily
    self.data = data
    self.sourceKind = sourceKind
    self.usesPDFExport = usesPDFExport
  }
}

public struct NotesAttachmentRecognizedTextGeneration: Equatable, Sendable {
  public var text: String
  public var sourceKind: String
  public var pageCount: Int?
  public var observationCount: Int

  public init(
    text: String,
    sourceKind: String,
    pageCount: Int? = nil,
    observationCount: Int
  ) {
    self.text = text
    self.sourceKind = sourceKind
    self.pageCount = pageCount
    self.observationCount = observationCount
  }
}

public struct NotesAttachmentRecognizedTextGenerateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var family: String
  public var sourceKind: String
  public var recognitionSourceKind: String
  public var usesPDFExport: Bool
  public var sourceByteCount: Int
  public var sourceSHA256: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var pageCount: Int?
  public var observationCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    family: String,
    sourceKind: String,
    recognitionSourceKind: String,
    usesPDFExport: Bool,
    sourceByteCount: Int,
    sourceSHA256: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    pageCount: Int? = nil,
    observationCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.family = family
    self.sourceKind = sourceKind
    self.recognitionSourceKind = recognitionSourceKind
    self.usesPDFExport = usesPDFExport
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.pageCount = pageCount
    self.observationCount = observationCount
    self.verification = verification
  }
}

public struct NotesAttachmentRecognizedTextExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var family: String
  public var contentKinds: [String]
  public var sourceKinds: [String]
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    family: String,
    contentKinds: [String],
    sourceKinds: [String],
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.family = family
    self.contentKinds = contentKinds
    self.sourceKinds = sourceKinds
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
  }
}

public struct NotesAttachmentSearchIndexDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var attachmentFamily: String

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    attachmentFamily: String
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.attachmentFamily = attachmentFamily
  }
}

public struct NotesAttachmentSearchIndexWriteResult: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var attachmentFamily: String
  public var objectIDURISHA256: String
  public var backendCalls: [String]
  public var completionStatus: String
  public var sourceKind: String

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    attachmentFamily: String,
    objectIDURISHA256: String,
    backendCalls: [String],
    completionStatus: String,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.attachmentFamily = attachmentFamily
    self.objectIDURISHA256 = objectIDURISHA256
    self.backendCalls = backendCalls
    self.completionStatus = completionStatus
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentSearchIndexResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var family: String
  public var objectIDURISHA256: String
  public var backendCalls: [String]
  public var completionStatus: String
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    family: String,
    objectIDURISHA256: String,
    backendCalls: [String],
    completionStatus: String,
    sourceKind: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.family = family
    self.objectIDURISHA256 = objectIDURISHA256
    self.backendCalls = backendCalls
    self.completionStatus = completionStatus
    self.sourceKind = sourceKind
    self.verification = verification
  }
}

public struct NotesAttachmentAudioTranscriptTextRecord: Codable, Equatable, Sendable {
  public var kind: String
  public var present: Bool
  public var byteCount: Int?
  public var sha256: String?
  public var version: Int?

  public init(
    kind: String,
    present: Bool,
    byteCount: Int? = nil,
    sha256: String? = nil,
    version: Int? = nil
  ) {
    self.kind = kind
    self.present = present
    self.byteCount = byteCount
    self.sha256 = sha256
    self.version = version
  }
}

public struct NotesAttachmentExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.verification = verification
  }
}

public struct NotesAttachmentAudioTranscriptResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var sourceKind: String
  public var texts: [NotesAttachmentAudioTranscriptTextRecord]
  public var destinationPath: String?
  public var exportedContentKind: String?
  public var byteCount: Int?
  public var sha256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    sourceKind: String,
    texts: [NotesAttachmentAudioTranscriptTextRecord],
    destinationPath: String? = nil,
    exportedContentKind: String? = nil,
    byteCount: Int? = nil,
    sha256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.sourceKind = sourceKind
    self.texts = texts
    self.destinationPath = destinationPath
    self.exportedContentKind = exportedContentKind
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
  }
}

public struct NotesClipboardWriteRecord: Codable, Equatable, Sendable {
  public var changeCount: Int

  public init(changeCount: Int) {
    self.changeCount = changeCount
  }
}

public struct NotesAttachmentAudioTranscriptCopyResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var destination: String
  public var sourceNoteID: String
  public var sourceAttachmentID: String
  public var targetNoteID: String?
  public var contentKind: String
  public var sourceKind: String
  public var byteCount: Int
  public var sha256: String
  public var version: Int?
  public var targetBodyByteCount: Int?
  public var targetBodySHA256: String?
  public var clipboardChangeCount: Int?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    destination: String,
    sourceNoteID: String,
    sourceAttachmentID: String,
    targetNoteID: String? = nil,
    contentKind: String,
    sourceKind: String,
    byteCount: Int,
    sha256: String,
    version: Int? = nil,
    targetBodyByteCount: Int? = nil,
    targetBodySHA256: String? = nil,
    clipboardChangeCount: Int? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.destination = destination
    self.sourceNoteID = sourceNoteID
    self.sourceAttachmentID = sourceAttachmentID
    self.targetNoteID = targetNoteID
    self.contentKind = contentKind
    self.sourceKind = sourceKind
    self.byteCount = byteCount
    self.sha256 = sha256
    self.version = version
    self.targetBodyByteCount = targetBodyByteCount
    self.targetBodySHA256 = targetBodySHA256
    self.clipboardChangeCount = clipboardChangeCount
    self.verification = verification
  }
}

public struct NotesAttachmentAudioTranscriptSearchContentMatch: Codable, Equatable, Sendable {
  public var kind: String
  public var matchCount: Int
  public var byteCount: Int
  public var sha256: String
  public var version: Int?

  public init(
    kind: String,
    matchCount: Int,
    byteCount: Int,
    sha256: String,
    version: Int? = nil
  ) {
    self.kind = kind
    self.matchCount = matchCount
    self.byteCount = byteCount
    self.sha256 = sha256
    self.version = version
  }
}

public struct NotesAttachmentAudioTranscriptSearchMatch: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var attachment: NotesAttachmentRecord
  public var sourceKind: String
  public var contentMatches: [NotesAttachmentAudioTranscriptSearchContentMatch]

  public init(
    note: NotesNoteSummary,
    attachment: NotesAttachmentRecord,
    sourceKind: String,
    contentMatches: [NotesAttachmentAudioTranscriptSearchContentMatch]
  ) {
    self.note = note
    self.attachment = attachment
    self.sourceKind = sourceKind
    self.contentMatches = contentMatches
  }
}

public struct NotesAttachmentAudioTranscriptSearchResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var querySHA256: String
  public var queryByteCount: Int
  public var account: String?
  public var folder: String?
  public var contentKinds: [String]
  public var scannedNoteCount: Int
  public var scannedAudioAttachmentCount: Int
  public var skippedAudioAttachmentCount: Int
  public var matchedAttachmentCount: Int
  public var matches: [NotesAttachmentAudioTranscriptSearchMatch]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    querySHA256: String,
    queryByteCount: Int,
    account: String? = nil,
    folder: String? = nil,
    contentKinds: [String],
    scannedNoteCount: Int,
    scannedAudioAttachmentCount: Int,
    skippedAudioAttachmentCount: Int,
    matchedAttachmentCount: Int,
    matches: [NotesAttachmentAudioTranscriptSearchMatch],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.querySHA256 = querySHA256
    self.queryByteCount = queryByteCount
    self.account = account
    self.folder = folder
    self.contentKinds = contentKinds
    self.scannedNoteCount = scannedNoteCount
    self.scannedAudioAttachmentCount = scannedAudioAttachmentCount
    self.skippedAudioAttachmentCount = skippedAudioAttachmentCount
    self.matchedAttachmentCount = matchedAttachmentCount
    self.matches = matches
    self.verification = verification
  }
}

public struct NotesAttachmentPDFExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    sourceKind: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.sourceKind = sourceKind
    self.verification = verification
  }
}

public struct NotesAttachmentScanPDFInspectionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var pdfDataByteCount: Int?
  public var pdfDataSHA256: String?
  public var pdfPageCount: Int?
  public var pdfSourceKind: String?
  public var croppingQuadPresent: Bool
  public var croppingQuadSHA256: String?
  public var scannedDocumentsMetadataPresent: Bool
  public var scannedDocumentsMetadataCount: Int?
  public var scannedDocumentsMetadataSHA256: String?
  public var docCamPDFVersion: Int?
  public var orientation: Int?
  public var orientationSHA256: String?
  public var imageFilterType: Int?
  public var imageFilterTypeSHA256: String?
  public var sourceKinds: [String]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    pdfDataByteCount: Int? = nil,
    pdfDataSHA256: String? = nil,
    pdfPageCount: Int? = nil,
    pdfSourceKind: String? = nil,
    croppingQuadPresent: Bool,
    croppingQuadSHA256: String? = nil,
    scannedDocumentsMetadataPresent: Bool,
    scannedDocumentsMetadataCount: Int? = nil,
    scannedDocumentsMetadataSHA256: String? = nil,
    docCamPDFVersion: Int? = nil,
    orientation: Int? = nil,
    orientationSHA256: String? = nil,
    imageFilterType: Int? = nil,
    imageFilterTypeSHA256: String? = nil,
    sourceKinds: [String],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.pdfDataByteCount = pdfDataByteCount
    self.pdfDataSHA256 = pdfDataSHA256
    self.pdfPageCount = pdfPageCount
    self.pdfSourceKind = pdfSourceKind
    self.croppingQuadPresent = croppingQuadPresent
    self.croppingQuadSHA256 = croppingQuadSHA256
    self.scannedDocumentsMetadataPresent = scannedDocumentsMetadataPresent
    self.scannedDocumentsMetadataCount = scannedDocumentsMetadataCount
    self.scannedDocumentsMetadataSHA256 = scannedDocumentsMetadataSHA256
    self.docCamPDFVersion = docCamPDFVersion
    self.orientation = orientation
    self.orientationSHA256 = orientationSHA256
    self.imageFilterType = imageFilterType
    self.imageFilterTypeSHA256 = imageFilterTypeSHA256
    self.sourceKinds = sourceKinds
    self.verification = verification
  }
}

public struct NotesAttachmentAddDraft: Equatable, Sendable {
  public var noteID: String
  public var filename: String
  public var sourcePath: String
  public var data: Data

  public init(noteID: String, filename: String, sourcePath: String, data: Data) {
    self.noteID = noteID
    self.filename = filename
    self.sourcePath = sourcePath
    self.data = data
  }
}

public struct NotesAttachmentAddBatchDraft: Equatable, Sendable {
  public var noteID: String
  public var attachments: [NotesAttachmentAddDraft]

  public init(noteID: String, attachments: [NotesAttachmentAddDraft]) {
    self.noteID = noteID
    self.attachments = attachments
  }
}

public struct NotesAttachmentAddWriteResult: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord

  public init(noteID: String, attachment: NotesAttachmentRecord) {
    self.noteID = noteID
    self.attachment = attachment
  }
}

public struct NotesAttachmentAddResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var byteCount: Int
  public var sha256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachment: NotesAttachmentRecord,
    byteCount: Int,
    sha256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachment = attachment
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
  }
}

public struct NotesAttachmentAddBatchItemResult: Codable, Equatable, Sendable {
  public var filename: String
  public var attachment: NotesAttachmentRecord
  public var byteCount: Int
  public var sha256: String
  public var verification: NotesMutationVerificationReport

  public init(
    filename: String,
    attachment: NotesAttachmentRecord,
    byteCount: Int,
    sha256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.filename = filename
    self.attachment = attachment
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
  }
}

public struct NotesAttachmentAddBatchResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentCount: Int
  public var totalByteCount: Int
  public var aggregateSHA256: String
  public var attachments: [NotesAttachmentRecord]
  public var items: [NotesAttachmentAddBatchItemResult]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentCount: Int,
    totalByteCount: Int,
    aggregateSHA256: String,
    attachments: [NotesAttachmentRecord],
    items: [NotesAttachmentAddBatchItemResult],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentCount = attachmentCount
    self.totalByteCount = totalByteCount
    self.aggregateSHA256 = aggregateSHA256
    self.attachments = attachments
    self.items = items
    self.verification = verification
  }
}

public struct NotesWebpageAttachmentAddResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var webpagePreview: NotesLinkRecord
  public var urlSHA256: String
  public var attachmentFamily: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    webpagePreview: NotesLinkRecord,
    urlSHA256: String,
    attachmentFamily: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.webpagePreview = webpagePreview
    self.urlSHA256 = urlSHA256
    self.attachmentFamily = attachmentFamily
    self.verification = verification
  }
}

public struct NotesWebpageAttachmentUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var oldWebpagePreview: NotesLinkRecord
  public var webpagePreview: NotesLinkRecord
  public var oldURLSHA256: String?
  public var urlSHA256: String
  public var attachmentFamily: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    oldWebpagePreview: NotesLinkRecord,
    webpagePreview: NotesLinkRecord,
    oldURLSHA256: String?,
    urlSHA256: String,
    attachmentFamily: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.oldWebpagePreview = oldWebpagePreview
    self.webpagePreview = webpagePreview
    self.oldURLSHA256 = oldURLSHA256
    self.urlSHA256 = urlSHA256
    self.attachmentFamily = attachmentFamily
    self.verification = verification
  }
}

public struct NotesAttachmentRenameDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var name: String

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    name: String
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.name = name
  }
}

public struct NotesAttachmentRenameWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldAttachment: NotesAttachmentRecord
  public var attachment: NotesAttachmentRecord
  public var changed: Bool

  public init(
    noteID: String,
    oldAttachment: NotesAttachmentRecord,
    attachment: NotesAttachmentRecord,
    changed: Bool
  ) {
    self.noteID = noteID
    self.oldAttachment = oldAttachment
    self.attachment = attachment
    self.changed = changed
  }
}

public struct NotesAttachmentRenameResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var oldAttachment: NotesAttachmentRecord
  public var attachment: NotesAttachmentRecord
  public var oldNameSHA256: String?
  public var nameSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    oldAttachment: NotesAttachmentRecord,
    attachment: NotesAttachmentRecord,
    oldNameSHA256: String?,
    nameSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.oldAttachment = oldAttachment
    self.attachment = attachment
    self.oldNameSHA256 = oldNameSHA256
    self.nameSHA256 = nameSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentRemoveDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord

  public init(noteID: String, attachmentID: String, attachment: NotesAttachmentRecord) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
  }
}

public struct NotesAttachmentRemoveWriteResult: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var changed: Bool

  public init(noteID: String, attachment: NotesAttachmentRecord, changed: Bool) {
    self.noteID = noteID
    self.attachment = attachment
    self.changed = changed
  }
}

public struct NotesAttachmentRemoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachment: NotesAttachmentRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachment = attachment
    self.verification = verification
  }
}

public struct NotesAttachmentScanRotateDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var beforeOrientation: Int?
  public var targetOrientation: Int
  public var rotationDeltaDegrees: Int

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    beforeOrientation: Int?,
    targetOrientation: Int,
    rotationDeltaDegrees: Int
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.beforeOrientation = beforeOrientation
    self.targetOrientation = targetOrientation
    self.rotationDeltaDegrees = rotationDeltaDegrees
  }
}

public struct NotesAttachmentScanRotateWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var rotationDeltaDegrees: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    rotationDeltaDegrees: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentScanRotateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var rotationDeltaDegrees: Int
  public var beforeOrientation: Int?
  public var afterOrientation: Int?
  public var beforeOrientationSHA256: String?
  public var afterOrientationSHA256: String?
  public var sourceKind: String
  public var pdfDataSHA256: String?
  public var croppingQuadSHA256: String?
  public var scannedDocumentsMetadataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    rotationDeltaDegrees: Int,
    beforeOrientation: Int? = nil,
    afterOrientation: Int? = nil,
    beforeOrientationSHA256: String? = nil,
    afterOrientationSHA256: String? = nil,
    sourceKind: String,
    pdfDataSHA256: String? = nil,
    croppingQuadSHA256: String? = nil,
    scannedDocumentsMetadataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.beforeOrientation = beforeOrientation
    self.afterOrientation = afterOrientation
    self.beforeOrientationSHA256 = beforeOrientationSHA256
    self.afterOrientationSHA256 = afterOrientationSHA256
    self.sourceKind = sourceKind
    self.pdfDataSHA256 = pdfDataSHA256
    self.croppingQuadSHA256 = croppingQuadSHA256
    self.scannedDocumentsMetadataSHA256 = scannedDocumentsMetadataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentScanCropPoint: Equatable, Sendable {
  public var x: Double
  public var y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

public struct NotesAttachmentScanCropDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var topLeft: NotesAttachmentScanCropPoint
  public var topRight: NotesAttachmentScanCropPoint
  public var bottomRight: NotesAttachmentScanCropPoint
  public var bottomLeft: NotesAttachmentScanCropPoint
  public var requestedCropQuadSHA256: String
  public var beforeCroppingQuadSHA256: String?
  public var pageCount: Int?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    topLeft: NotesAttachmentScanCropPoint,
    topRight: NotesAttachmentScanCropPoint,
    bottomRight: NotesAttachmentScanCropPoint,
    bottomLeft: NotesAttachmentScanCropPoint,
    requestedCropQuadSHA256: String,
    beforeCroppingQuadSHA256: String? = nil,
    pageCount: Int? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.topLeft = topLeft
    self.topRight = topRight
    self.bottomRight = bottomRight
    self.bottomLeft = bottomLeft
    self.requestedCropQuadSHA256 = requestedCropQuadSHA256
    self.beforeCroppingQuadSHA256 = beforeCroppingQuadSHA256
    self.pageCount = pageCount
  }
}

public struct NotesAttachmentScanCropWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var requestedCropQuadSHA256: String
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    requestedCropQuadSHA256: String,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.requestedCropQuadSHA256 = requestedCropQuadSHA256
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentScanCropResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var requestedCropQuadSHA256: String
  public var beforeCroppingQuadSHA256: String?
  public var afterCroppingQuadSHA256: String?
  public var cropPointCount: Int
  public var pageCount: Int?
  public var sourceKind: String
  public var pdfDataSHA256: String?
  public var scannedDocumentsMetadataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    requestedCropQuadSHA256: String,
    beforeCroppingQuadSHA256: String? = nil,
    afterCroppingQuadSHA256: String? = nil,
    cropPointCount: Int,
    pageCount: Int? = nil,
    sourceKind: String,
    pdfDataSHA256: String? = nil,
    scannedDocumentsMetadataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.requestedCropQuadSHA256 = requestedCropQuadSHA256
    self.beforeCroppingQuadSHA256 = beforeCroppingQuadSHA256
    self.afterCroppingQuadSHA256 = afterCroppingQuadSHA256
    self.cropPointCount = cropPointCount
    self.pageCount = pageCount
    self.sourceKind = sourceKind
    self.pdfDataSHA256 = pdfDataSHA256
    self.scannedDocumentsMetadataSHA256 = scannedDocumentsMetadataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentImageTransformSource: Equatable, Sendable {
  public var noteID: String
  public var attachment: NotesAttachmentRecord
  public var dataByteCount: Int
  public var dataSHA256: String
  public var sourceKind: String

  public init(
    noteID: String,
    attachment: NotesAttachmentRecord,
    dataByteCount: Int,
    dataSHA256: String,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.attachment = attachment
    self.dataByteCount = dataByteCount
    self.dataSHA256 = dataSHA256
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentImageCropDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var topLeft: NotesAttachmentScanCropPoint
  public var topRight: NotesAttachmentScanCropPoint
  public var bottomRight: NotesAttachmentScanCropPoint
  public var bottomLeft: NotesAttachmentScanCropPoint
  public var requestedCropRectSHA256: String
  public var beforeImageDataSHA256: String?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    topLeft: NotesAttachmentScanCropPoint,
    topRight: NotesAttachmentScanCropPoint,
    bottomRight: NotesAttachmentScanCropPoint,
    bottomLeft: NotesAttachmentScanCropPoint,
    requestedCropRectSHA256: String,
    beforeImageDataSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.topLeft = topLeft
    self.topRight = topRight
    self.bottomRight = bottomRight
    self.bottomLeft = bottomLeft
    self.requestedCropRectSHA256 = requestedCropRectSHA256
    self.beforeImageDataSHA256 = beforeImageDataSHA256
  }
}

public struct NotesAttachmentImageCropWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldSource: NotesAttachmentImageTransformSource
  public var source: NotesAttachmentImageTransformSource
  public var requestedCropRectSHA256: String
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldSource: NotesAttachmentImageTransformSource,
    source: NotesAttachmentImageTransformSource,
    requestedCropRectSHA256: String,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldSource = oldSource
    self.source = source
    self.requestedCropRectSHA256 = requestedCropRectSHA256
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentImageCropResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var requestedCropRectSHA256: String
  public var cropPointCount: Int
  public var beforeImageDataByteCount: Int
  public var afterImageDataByteCount: Int
  public var beforeImageDataSHA256: String
  public var afterImageDataSHA256: String
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    requestedCropRectSHA256: String,
    cropPointCount: Int,
    beforeImageDataByteCount: Int,
    afterImageDataByteCount: Int,
    beforeImageDataSHA256: String,
    afterImageDataSHA256: String,
    sourceKind: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.requestedCropRectSHA256 = requestedCropRectSHA256
    self.cropPointCount = cropPointCount
    self.beforeImageDataByteCount = beforeImageDataByteCount
    self.afterImageDataByteCount = afterImageDataByteCount
    self.beforeImageDataSHA256 = beforeImageDataSHA256
    self.afterImageDataSHA256 = afterImageDataSHA256
    self.sourceKind = sourceKind
    self.verification = verification
  }
}

public struct NotesAttachmentImageRotateDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var rotationDeltaDegrees: Int
  public var beforeImageDataSHA256: String?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    rotationDeltaDegrees: Int,
    beforeImageDataSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.beforeImageDataSHA256 = beforeImageDataSHA256
  }
}

public struct NotesAttachmentImageRotateWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldSource: NotesAttachmentImageTransformSource
  public var source: NotesAttachmentImageTransformSource
  public var rotationDeltaDegrees: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldSource: NotesAttachmentImageTransformSource,
    source: NotesAttachmentImageTransformSource,
    rotationDeltaDegrees: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldSource = oldSource
    self.source = source
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentImageRotateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var rotationDeltaDegrees: Int
  public var beforeImageDataByteCount: Int
  public var afterImageDataByteCount: Int
  public var beforeImageDataSHA256: String
  public var afterImageDataSHA256: String
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    rotationDeltaDegrees: Int,
    beforeImageDataByteCount: Int,
    afterImageDataByteCount: Int,
    beforeImageDataSHA256: String,
    afterImageDataSHA256: String,
    sourceKind: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.beforeImageDataByteCount = beforeImageDataByteCount
    self.afterImageDataByteCount = afterImageDataByteCount
    self.beforeImageDataSHA256 = beforeImageDataSHA256
    self.afterImageDataSHA256 = afterImageDataSHA256
    self.sourceKind = sourceKind
    self.verification = verification
  }
}

public struct NotesAttachmentScanFilterDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var style: String
  public var filterType: Int
  public var beforeImageFilterType: Int?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    style: String,
    filterType: Int,
    beforeImageFilterType: Int?
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.style = style
    self.filterType = filterType
    self.beforeImageFilterType = beforeImageFilterType
  }
}

public struct NotesAttachmentScanFilterWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var style: String
  public var filterType: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    style: String,
    filterType: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.style = style
    self.filterType = filterType
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentScanFilterResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var style: String
  public var filterType: Int
  public var beforeImageFilterType: Int?
  public var afterImageFilterType: Int?
  public var beforeImageFilterTypeSHA256: String?
  public var afterImageFilterTypeSHA256: String?
  public var sourceKind: String
  public var pdfDataSHA256: String?
  public var croppingQuadSHA256: String?
  public var scannedDocumentsMetadataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    style: String,
    filterType: Int,
    beforeImageFilterType: Int? = nil,
    afterImageFilterType: Int? = nil,
    beforeImageFilterTypeSHA256: String? = nil,
    afterImageFilterTypeSHA256: String? = nil,
    sourceKind: String,
    pdfDataSHA256: String? = nil,
    croppingQuadSHA256: String? = nil,
    scannedDocumentsMetadataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.style = style
    self.filterType = filterType
    self.beforeImageFilterType = beforeImageFilterType
    self.afterImageFilterType = afterImageFilterType
    self.beforeImageFilterTypeSHA256 = beforeImageFilterTypeSHA256
    self.afterImageFilterTypeSHA256 = afterImageFilterTypeSHA256
    self.sourceKind = sourceKind
    self.pdfDataSHA256 = pdfDataSHA256
    self.croppingQuadSHA256 = croppingQuadSHA256
    self.scannedDocumentsMetadataSHA256 = scannedDocumentsMetadataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentScanPageMoveDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var fromPage: Int
  public var toPage: Int
  public var pageCount: Int

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    fromPage: Int,
    toPage: Int,
    pageCount: Int
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.fromPage = fromPage
    self.toPage = toPage
    self.pageCount = pageCount
  }
}

public struct NotesAttachmentScanPageMoveWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var fromPage: Int
  public var toPage: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    fromPage: Int,
    toPage: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.fromPage = fromPage
    self.toPage = toPage
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentScanPageMoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var fromPage: Int
  public var toPage: Int
  public var beforePageCount: Int?
  public var afterPageCount: Int?
  public var sourceKind: String
  public var beforePDFDataSHA256: String?
  public var afterPDFDataSHA256: String?
  public var beforeScannedDocumentsMetadataSHA256: String?
  public var afterScannedDocumentsMetadataSHA256: String?
  public var croppingQuadSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    fromPage: Int,
    toPage: Int,
    beforePageCount: Int? = nil,
    afterPageCount: Int? = nil,
    sourceKind: String,
    beforePDFDataSHA256: String? = nil,
    afterPDFDataSHA256: String? = nil,
    beforeScannedDocumentsMetadataSHA256: String? = nil,
    afterScannedDocumentsMetadataSHA256: String? = nil,
    croppingQuadSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.fromPage = fromPage
    self.toPage = toPage
    self.beforePageCount = beforePageCount
    self.afterPageCount = afterPageCount
    self.sourceKind = sourceKind
    self.beforePDFDataSHA256 = beforePDFDataSHA256
    self.afterPDFDataSHA256 = afterPDFDataSHA256
    self.beforeScannedDocumentsMetadataSHA256 = beforeScannedDocumentsMetadataSHA256
    self.afterScannedDocumentsMetadataSHA256 = afterScannedDocumentsMetadataSHA256
    self.croppingQuadSHA256 = croppingQuadSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentScanPageDeleteDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var page: Int
  public var pageCount: Int

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    page: Int,
    pageCount: Int
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.page = page
    self.pageCount = pageCount
  }
}

public struct NotesAttachmentScanPageDeleteWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var page: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    page: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.page = page
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentScanPageDeleteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var page: Int
  public var beforePageCount: Int?
  public var afterPageCount: Int?
  public var sourceKind: String
  public var beforePDFDataSHA256: String?
  public var afterPDFDataSHA256: String?
  public var beforeScannedDocumentsMetadataSHA256: String?
  public var afterScannedDocumentsMetadataSHA256: String?
  public var croppingQuadSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    page: Int,
    beforePageCount: Int? = nil,
    afterPageCount: Int? = nil,
    sourceKind: String,
    beforePDFDataSHA256: String? = nil,
    afterPDFDataSHA256: String? = nil,
    beforeScannedDocumentsMetadataSHA256: String? = nil,
    afterScannedDocumentsMetadataSHA256: String? = nil,
    croppingQuadSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.page = page
    self.beforePageCount = beforePageCount
    self.afterPageCount = afterPageCount
    self.sourceKind = sourceKind
    self.beforePDFDataSHA256 = beforePDFDataSHA256
    self.afterPDFDataSHA256 = afterPDFDataSHA256
    self.beforeScannedDocumentsMetadataSHA256 = beforeScannedDocumentsMetadataSHA256
    self.afterScannedDocumentsMetadataSHA256 = afterScannedDocumentsMetadataSHA256
    self.croppingQuadSHA256 = croppingQuadSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentPDFCropDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var page: Int
  public var pageCount: Int
  public var topLeft: NotesAttachmentScanCropPoint
  public var topRight: NotesAttachmentScanCropPoint
  public var bottomRight: NotesAttachmentScanCropPoint
  public var bottomLeft: NotesAttachmentScanCropPoint
  public var requestedCropRectSHA256: String
  public var beforePDFDataSHA256: String?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    page: Int,
    pageCount: Int,
    topLeft: NotesAttachmentScanCropPoint,
    topRight: NotesAttachmentScanCropPoint,
    bottomRight: NotesAttachmentScanCropPoint,
    bottomLeft: NotesAttachmentScanCropPoint,
    requestedCropRectSHA256: String,
    beforePDFDataSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.page = page
    self.pageCount = pageCount
    self.topLeft = topLeft
    self.topRight = topRight
    self.bottomRight = bottomRight
    self.bottomLeft = bottomLeft
    self.requestedCropRectSHA256 = requestedCropRectSHA256
    self.beforePDFDataSHA256 = beforePDFDataSHA256
  }
}

public struct NotesAttachmentPDFCropWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var page: Int
  public var requestedCropRectSHA256: String
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    page: Int,
    requestedCropRectSHA256: String,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.page = page
    self.requestedCropRectSHA256 = requestedCropRectSHA256
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentPDFCropResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var page: Int
  public var requestedCropRectSHA256: String
  public var cropPointCount: Int
  public var beforePageCount: Int?
  public var afterPageCount: Int?
  public var sourceKind: String
  public var beforePDFDataSHA256: String?
  public var afterPDFDataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    page: Int,
    requestedCropRectSHA256: String,
    cropPointCount: Int,
    beforePageCount: Int? = nil,
    afterPageCount: Int? = nil,
    sourceKind: String,
    beforePDFDataSHA256: String? = nil,
    afterPDFDataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.page = page
    self.requestedCropRectSHA256 = requestedCropRectSHA256
    self.cropPointCount = cropPointCount
    self.beforePageCount = beforePageCount
    self.afterPageCount = afterPageCount
    self.sourceKind = sourceKind
    self.beforePDFDataSHA256 = beforePDFDataSHA256
    self.afterPDFDataSHA256 = afterPDFDataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentPDFPageRotateDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var page: Int
  public var pageCount: Int
  public var beforePageRotation: Int
  public var targetPageRotation: Int
  public var rotationDeltaDegrees: Int
  public var beforePDFDataSHA256: String?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    page: Int,
    pageCount: Int,
    beforePageRotation: Int,
    targetPageRotation: Int,
    rotationDeltaDegrees: Int,
    beforePDFDataSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.page = page
    self.pageCount = pageCount
    self.beforePageRotation = beforePageRotation
    self.targetPageRotation = targetPageRotation
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.beforePDFDataSHA256 = beforePDFDataSHA256
  }
}

public struct NotesAttachmentPDFPageRotateWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var page: Int
  public var beforePageRotation: Int
  public var afterPageRotation: Int
  public var rotationDeltaDegrees: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    page: Int,
    beforePageRotation: Int,
    afterPageRotation: Int,
    rotationDeltaDegrees: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.page = page
    self.beforePageRotation = beforePageRotation
    self.afterPageRotation = afterPageRotation
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentPDFPageRotateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var page: Int
  public var rotationDeltaDegrees: Int
  public var beforePageRotation: Int
  public var afterPageRotation: Int
  public var beforePageCount: Int?
  public var afterPageCount: Int?
  public var sourceKind: String
  public var beforePDFDataSHA256: String?
  public var afterPDFDataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    page: Int,
    rotationDeltaDegrees: Int,
    beforePageRotation: Int,
    afterPageRotation: Int,
    beforePageCount: Int? = nil,
    afterPageCount: Int? = nil,
    sourceKind: String,
    beforePDFDataSHA256: String? = nil,
    afterPDFDataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.page = page
    self.rotationDeltaDegrees = rotationDeltaDegrees
    self.beforePageRotation = beforePageRotation
    self.afterPageRotation = afterPageRotation
    self.beforePageCount = beforePageCount
    self.afterPageCount = afterPageCount
    self.sourceKind = sourceKind
    self.beforePDFDataSHA256 = beforePDFDataSHA256
    self.afterPDFDataSHA256 = afterPDFDataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentPDFPageMoveDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var fromPage: Int
  public var toPage: Int
  public var pageCount: Int
  public var beforePDFDataSHA256: String?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    fromPage: Int,
    toPage: Int,
    pageCount: Int,
    beforePDFDataSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.fromPage = fromPage
    self.toPage = toPage
    self.pageCount = pageCount
    self.beforePDFDataSHA256 = beforePDFDataSHA256
  }
}

public struct NotesAttachmentPDFPageMoveWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var fromPage: Int
  public var toPage: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    fromPage: Int,
    toPage: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.fromPage = fromPage
    self.toPage = toPage
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentPDFPageMoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var fromPage: Int
  public var toPage: Int
  public var beforePageCount: Int?
  public var afterPageCount: Int?
  public var sourceKind: String
  public var beforePDFDataSHA256: String?
  public var afterPDFDataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    fromPage: Int,
    toPage: Int,
    beforePageCount: Int? = nil,
    afterPageCount: Int? = nil,
    sourceKind: String,
    beforePDFDataSHA256: String? = nil,
    afterPDFDataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.fromPage = fromPage
    self.toPage = toPage
    self.beforePageCount = beforePageCount
    self.afterPageCount = afterPageCount
    self.sourceKind = sourceKind
    self.beforePDFDataSHA256 = beforePDFDataSHA256
    self.afterPDFDataSHA256 = afterPDFDataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentPDFPageDeleteDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var page: Int
  public var pageCount: Int
  public var beforePDFDataSHA256: String?

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    page: Int,
    pageCount: Int,
    beforePDFDataSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.page = page
    self.pageCount = pageCount
    self.beforePDFDataSHA256 = beforePDFDataSHA256
  }
}

public struct NotesAttachmentPDFPageDeleteWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldInspection: NotesAttachmentScanPDFInspectionSource
  public var inspection: NotesAttachmentScanPDFInspectionSource
  public var page: Int
  public var changed: Bool
  public var sourceKind: String

  public init(
    noteID: String,
    oldInspection: NotesAttachmentScanPDFInspectionSource,
    inspection: NotesAttachmentScanPDFInspectionSource,
    page: Int,
    changed: Bool,
    sourceKind: String
  ) {
    self.noteID = noteID
    self.oldInspection = oldInspection
    self.inspection = inspection
    self.page = page
    self.changed = changed
    self.sourceKind = sourceKind
  }
}

public struct NotesAttachmentPDFPageDeleteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var page: Int
  public var beforePageCount: Int?
  public var afterPageCount: Int?
  public var sourceKind: String
  public var beforePDFDataSHA256: String?
  public var afterPDFDataSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    page: Int,
    beforePageCount: Int? = nil,
    afterPageCount: Int? = nil,
    sourceKind: String,
    beforePDFDataSHA256: String? = nil,
    afterPDFDataSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.page = page
    self.beforePageCount = beforePageCount
    self.afterPageCount = afterPageCount
    self.sourceKind = sourceKind
    self.beforePDFDataSHA256 = beforePDFDataSHA256
    self.afterPDFDataSHA256 = afterPDFDataSHA256
    self.verification = verification
  }
}

public struct NotesAttachmentMarkupEditDraft: Equatable, Sendable {
  public var noteID: String
  public var attachmentID: String
  public var attachment: NotesAttachmentRecord
  public var sourcePath: String
  public var data: Data

  public init(
    noteID: String,
    attachmentID: String,
    attachment: NotesAttachmentRecord,
    sourcePath: String,
    data: Data
  ) {
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.attachment = attachment
    self.sourcePath = sourcePath
    self.data = data
  }
}

public struct NotesAttachmentMarkupEditWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldAttachment: NotesAttachmentRecord
  public var attachment: NotesAttachmentRecord
  public var changed: Bool

  public init(
    noteID: String,
    oldAttachment: NotesAttachmentRecord,
    attachment: NotesAttachmentRecord,
    changed: Bool
  ) {
    self.noteID = noteID
    self.oldAttachment = oldAttachment
    self.attachment = attachment
    self.changed = changed
  }
}

public struct NotesAttachmentMarkupEditResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var attachmentFamily: String
  public var markupModelByteCount: Int
  public var markupModelSHA256: String
  public var sourcePath: String
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    attachmentFamily: String,
    markupModelByteCount: Int,
    markupModelSHA256: String,
    sourcePath: String,
    sourceKind: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.attachmentFamily = attachmentFamily
    self.markupModelByteCount = markupModelByteCount
    self.markupModelSHA256 = markupModelSHA256
    self.sourcePath = sourcePath
    self.sourceKind = sourceKind
    self.verification = verification
  }
}

public struct NotesAttachmentMarkupInspectionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var attachmentID: String
  public var requestedAttachmentID: String
  public var title: String?
  public var typeUTI: String?
  public var mediaFilename: String?
  public var sourceKind: String
  public var attachmentDataByteCount: Int
  public var attachmentDataSHA256: String
  public var markupModelPresent: Bool
  public var markupModelByteCount: Int?
  public var markupModelSHA256: String?
  public var destinationPath: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    attachmentID: String,
    requestedAttachmentID: String,
    title: String? = nil,
    typeUTI: String? = nil,
    mediaFilename: String? = nil,
    sourceKind: String,
    attachmentDataByteCount: Int,
    attachmentDataSHA256: String,
    markupModelPresent: Bool,
    markupModelByteCount: Int? = nil,
    markupModelSHA256: String? = nil,
    destinationPath: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.attachmentID = attachmentID
    self.requestedAttachmentID = requestedAttachmentID
    self.title = title
    self.typeUTI = typeUTI
    self.mediaFilename = mediaFilename
    self.sourceKind = sourceKind
    self.attachmentDataByteCount = attachmentDataByteCount
    self.attachmentDataSHA256 = attachmentDataSHA256
    self.markupModelPresent = markupModelPresent
    self.markupModelByteCount = markupModelByteCount
    self.markupModelSHA256 = markupModelSHA256
    self.destinationPath = destinationPath
    self.verification = verification
  }
}

public struct NotesNotePDFExportSource: Equatable, Sendable {
  public var noteID: String
  public var title: String?
  public var data: Data
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?

  public init(
    noteID: String,
    title: String? = nil,
    data: Data,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil
  ) {
    self.noteID = noteID
    self.title = title
    self.data = data
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
  }
}

public struct NotesNotePDFExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var title: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    title: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.title = title
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.verification = verification
  }
}

public struct NotesNoteMarkdownExportSource: Equatable, Sendable {
  public var noteID: String
  public var title: String?
  public var data: Data
  public var includesAttachments: Bool
  public var attachmentCount: Int
  public var markdownRelativePath: String
  public var resourceFiles: [NotesNoteMarkdownExportFile]
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?

  public init(
    noteID: String,
    title: String? = nil,
    data: Data,
    includesAttachments: Bool = false,
    attachmentCount: Int = 0,
    markdownRelativePath: String = "Note.md",
    resourceFiles: [NotesNoteMarkdownExportFile] = [],
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil
  ) {
    self.noteID = noteID
    self.title = title
    self.data = data
    self.includesAttachments = includesAttachments
    self.attachmentCount = attachmentCount
    self.markdownRelativePath = markdownRelativePath
    self.resourceFiles = resourceFiles
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
  }
}

public struct NotesNoteMarkdownExportFile: Equatable, Sendable {
  public var relativePath: String
  public var data: Data

  public init(relativePath: String, data: Data) {
    self.relativePath = relativePath
    self.data = data
  }
}

public struct NotesNoteMarkdownExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var title: String?
  public var includesAttachments: Bool
  public var attachmentCount: Int
  public var isPackage: Bool
  public var fileCount: Int?
  public var totalByteCount: Int?
  public var treeSHA256: String?
  public var markdownRelativePath: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    title: String? = nil,
    includesAttachments: Bool = false,
    attachmentCount: Int = 0,
    isPackage: Bool = false,
    fileCount: Int? = nil,
    totalByteCount: Int? = nil,
    treeSHA256: String? = nil,
    markdownRelativePath: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.title = title
    self.includesAttachments = includesAttachments
    self.attachmentCount = attachmentCount
    self.isPackage = isPackage
    self.fileCount = fileCount
    self.totalByteCount = totalByteCount
    self.treeSHA256 = treeSHA256
    self.markdownRelativePath = markdownRelativePath
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.verification = verification
  }
}

public struct NotesNoteHTMLExportSource: Equatable, Sendable {
  public var noteID: String
  public var title: String?
  public var data: Data
  public var includesAttachments: Bool
  public var attachmentCount: Int
  public var htmlRelativePath: String
  public var resourceFiles: [NotesNoteHTMLExportFile]
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?

  public init(
    noteID: String,
    title: String? = nil,
    data: Data,
    includesAttachments: Bool = false,
    attachmentCount: Int = 0,
    htmlRelativePath: String = "Note.html",
    resourceFiles: [NotesNoteHTMLExportFile] = [],
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil
  ) {
    self.noteID = noteID
    self.title = title
    self.data = data
    self.includesAttachments = includesAttachments
    self.attachmentCount = attachmentCount
    self.htmlRelativePath = htmlRelativePath
    self.resourceFiles = resourceFiles
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
  }
}

public struct NotesNoteHTMLExportFile: Equatable, Sendable {
  public var relativePath: String
  public var data: Data

  public init(relativePath: String, data: Data) {
    self.relativePath = relativePath
    self.data = data
  }
}

public struct NotesNoteHTMLExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var title: String?
  public var includesAttachments: Bool
  public var attachmentCount: Int
  public var isPackage: Bool
  public var fileCount: Int?
  public var totalByteCount: Int?
  public var treeSHA256: String?
  public var htmlRelativePath: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    title: String? = nil,
    includesAttachments: Bool = false,
    attachmentCount: Int = 0,
    isPackage: Bool = false,
    fileCount: Int? = nil,
    totalByteCount: Int? = nil,
    treeSHA256: String? = nil,
    htmlRelativePath: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.title = title
    self.includesAttachments = includesAttachments
    self.attachmentCount = attachmentCount
    self.isPackage = isPackage
    self.fileCount = fileCount
    self.totalByteCount = totalByteCount
    self.treeSHA256 = treeSHA256
    self.htmlRelativePath = htmlRelativePath
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.verification = verification
  }
}

public struct NotesNoteRTFExportSource: Equatable, Sendable {
  public var noteID: String
  public var title: String?
  public var data: Data
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?

  public init(
    noteID: String,
    title: String? = nil,
    data: Data,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil
  ) {
    self.noteID = noteID
    self.title = title
    self.data = data
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
  }
}

public struct NotesNoteRTFExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var title: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    title: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.title = title
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.verification = verification
  }
}

public struct NotesNoteRTFDExportFile: Equatable, Sendable {
  public var relativePath: String
  public var data: Data

  public init(relativePath: String, data: Data) {
    self.relativePath = relativePath
    self.data = data
  }
}

public struct NotesNoteRTFDExportSource: Equatable, Sendable {
  public var noteID: String
  public var title: String?
  public var files: [NotesNoteRTFDExportFile]
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?

  public init(
    noteID: String,
    title: String? = nil,
    files: [NotesNoteRTFDExportFile],
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil
  ) {
    self.noteID = noteID
    self.title = title
    self.files = files
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
  }
}

public struct NotesNoteRTFDExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var destinationPath: String
  public var fileCount: Int
  public var totalByteCount: Int
  public var treeSHA256: String
  public var title: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    destinationPath: String,
    fileCount: Int,
    totalByteCount: Int,
    treeSHA256: String,
    title: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.destinationPath = destinationPath
    self.fileCount = fileCount
    self.totalByteCount = totalByteCount
    self.treeSHA256 = treeSHA256
    self.title = title
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.verification = verification
  }
}

public struct NotesPagesOpenDispatchRecord: Codable, Equatable, Sendable {
  public var applicationName: String
  public var stagedPackagePathSHA256: String
  public var fileCount: Int
  public var totalByteCount: Int
  public var treeSHA256: String

  public init(
    applicationName: String,
    stagedPackagePathSHA256: String,
    fileCount: Int,
    totalByteCount: Int,
    treeSHA256: String
  ) {
    self.applicationName = applicationName
    self.stagedPackagePathSHA256 = stagedPackagePathSHA256
    self.fileCount = fileCount
    self.totalByteCount = totalByteCount
    self.treeSHA256 = treeSHA256
  }
}

public struct NotesPagesOpenResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var noteID: String
  public var title: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var applicationName: String
  public var fileCount: Int
  public var totalByteCount: Int
  public var treeSHA256: String
  public var stagedPackagePathSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    submitted: Bool,
    noteID: String,
    title: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    applicationName: String,
    fileCount: Int,
    totalByteCount: Int,
    treeSHA256: String,
    stagedPackagePathSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.submitted = submitted
    self.noteID = noteID
    self.title = title
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.applicationName = applicationName
    self.fileCount = fileCount
    self.totalByteCount = totalByteCount
    self.treeSHA256 = treeSHA256
    self.stagedPackagePathSHA256 = stagedPackagePathSHA256
    self.verification = verification
  }
}

public struct NotesPrintSubmissionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var noteID: String
  public var title: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var printerName: String
  public var jobID: String
  public var pdfByteCount: Int
  public var pdfSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    submitted: Bool,
    noteID: String,
    title: String? = nil,
    isPasswordProtected: Bool = false,
    isPasswordProtectedAndLocked: Bool? = nil,
    printerName: String,
    jobID: String,
    pdfByteCount: Int,
    pdfSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.submitted = submitted
    self.noteID = noteID
    self.title = title
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.printerName = printerName
    self.jobID = jobID
    self.pdfByteCount = pdfByteCount
    self.pdfSHA256 = pdfSHA256
    self.verification = verification
  }
}

public struct NotesLinkRecord: Codable, Equatable, Sendable {
  public var id: String
  public var kind: String
  public var displayText: String?
  public var altText: String?
  public var urlString: String?
  public var urlScheme: String?
  public var urlSHA256: String?
  public var tokenContentIdentifierSHA256: String?
  public var typeUTI: String?
  public var createdAt: Date?
  public var isParagraphLink: Bool
  public var isInternalParagraphLink: Bool

  public init(
    id: String,
    kind: String,
    displayText: String? = nil,
    altText: String? = nil,
    urlString: String? = nil,
    urlScheme: String? = nil,
    urlSHA256: String? = nil,
    tokenContentIdentifierSHA256: String? = nil,
    typeUTI: String? = nil,
    createdAt: Date? = nil,
    isParagraphLink: Bool = false,
    isInternalParagraphLink: Bool = false
  ) {
    self.id = id
    self.kind = kind
    self.displayText = displayText
    self.altText = altText
    self.urlString = urlString
    self.urlScheme = urlScheme
    self.urlSHA256 = urlSHA256
    self.tokenContentIdentifierSHA256 = tokenContentIdentifierSHA256
    self.typeUTI = typeUTI
    self.createdAt = createdAt
    self.isParagraphLink = isParagraphLink
    self.isInternalParagraphLink = isInternalParagraphLink
  }
}

public struct NotesBacklinkRecord: Codable, Equatable, Sendable {
  public var sourceNote: NotesNoteSummary
  public var link: NotesLinkRecord

  public init(sourceNote: NotesNoteSummary, link: NotesLinkRecord) {
    self.sourceNote = sourceNote
    self.link = link
  }
}

public struct NotesLinkDestinationRecord: Codable, Equatable, Sendable {
  public var kind: String
  public var resolved: Bool
  public var urlScheme: String?
  public var publicURLString: String?
  public var urlSHA256: String?
  public var targetNoteID: String?
  public var targetNoteIDSHA256: String?
  public var targetParagraphIDSHA256: String?
  public var tokenContentIdentifierSHA256: String?
  public var rawURLHidden: Bool
  public var rawInternalTokenHidden: Bool
  public var warnings: [String]

  public init(
    kind: String,
    resolved: Bool,
    urlScheme: String? = nil,
    publicURLString: String? = nil,
    urlSHA256: String? = nil,
    targetNoteID: String? = nil,
    targetNoteIDSHA256: String? = nil,
    targetParagraphIDSHA256: String? = nil,
    tokenContentIdentifierSHA256: String? = nil,
    rawURLHidden: Bool = false,
    rawInternalTokenHidden: Bool = false,
    warnings: [String] = []
  ) {
    self.kind = kind
    self.resolved = resolved
    self.urlScheme = urlScheme
    self.publicURLString = publicURLString
    self.urlSHA256 = urlSHA256
    self.targetNoteID = targetNoteID
    self.targetNoteIDSHA256 = targetNoteIDSHA256
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.tokenContentIdentifierSHA256 = tokenContentIdentifierSHA256
    self.rawURLHidden = rawURLHidden
    self.rawInternalTokenHidden = rawInternalTokenHidden
    self.warnings = warnings
  }
}

public struct NotesLinkResolutionRecord: Codable, Equatable, Sendable {
  public var noteID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord
  public var destination: NotesLinkDestinationRecord

  public init(
    noteID: String,
    requestedLinkID: String,
    link: NotesLinkRecord,
    destination: NotesLinkDestinationRecord
  ) {
    self.noteID = noteID
    self.requestedLinkID = requestedLinkID
    self.link = link
    self.destination = destination
  }
}

public struct NotesLinkAddDraft: Equatable, Sendable {
  public var noteID: String
  public var url: URL
  public var urlString: String
  public var sourceKind: String?
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var selectedText: String?
  public var occurrence: Int?

  public init(
    noteID: String,
    url: URL,
    urlString: String,
    sourceKind: String? = nil,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    selectedText: String? = nil,
    occurrence: Int? = nil
  ) {
    self.noteID = noteID
    self.url = url
    self.urlString = urlString
    self.sourceKind = sourceKind
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.selectedText = selectedText
    self.occurrence = occurrence
  }

  public var convertsSelectedText: Bool {
    selectedText != nil
  }
}

public struct NotesLinkAddWriteResult: Equatable, Sendable {
  public var noteID: String
  public var link: NotesLinkRecord
  public var selectedTextParagraphIDSHA256: String?
  public var selectedTextOrdinal: Int?
  public var selectedTextByteCount: Int?
  public var selectedTextSHA256: String?
  public var selectedTextOccurrence: Int?

  public init(
    noteID: String,
    link: NotesLinkRecord,
    selectedTextParagraphIDSHA256: String? = nil,
    selectedTextOrdinal: Int? = nil,
    selectedTextByteCount: Int? = nil,
    selectedTextSHA256: String? = nil,
    selectedTextOccurrence: Int? = nil
  ) {
    self.noteID = noteID
    self.link = link
    self.selectedTextParagraphIDSHA256 = selectedTextParagraphIDSHA256
    self.selectedTextOrdinal = selectedTextOrdinal
    self.selectedTextByteCount = selectedTextByteCount
    self.selectedTextSHA256 = selectedTextSHA256
    self.selectedTextOccurrence = selectedTextOccurrence
  }
}

public struct NotesNoteLinkDisplayTextDraft: Equatable, Sendable {
  public var mode: String
  public var displayText: String?
  public var displayTextSHA256: String
  public var displayTextByteCount: Int
  public var sourceKind: String

  public init(
    mode: String,
    displayText: String? = nil,
    displayTextSHA256: String,
    displayTextByteCount: Int,
    sourceKind: String
  ) {
    self.mode = mode
    self.displayText = displayText
    self.displayTextSHA256 = displayTextSHA256
    self.displayTextByteCount = displayTextByteCount
    self.sourceKind = sourceKind
  }
}

public struct NotesNoteLinkAddDraft: Equatable, Sendable {
  public var sourceNoteID: String
  public var targetNoteID: String
  public var requestedTargetNoteID: String
  public var displayText: NotesNoteLinkDisplayTextDraft?

  public init(
    sourceNoteID: String,
    targetNoteID: String,
    requestedTargetNoteID: String,
    displayText: NotesNoteLinkDisplayTextDraft? = nil
  ) {
    self.sourceNoteID = sourceNoteID
    self.targetNoteID = targetNoteID
    self.requestedTargetNoteID = requestedTargetNoteID
    self.displayText = displayText
  }
}

public struct NotesNoteLinkAddWriteResult: Equatable, Sendable {
  public var sourceNoteID: String
  public var targetNoteID: String
  public var link: NotesLinkRecord

  public init(sourceNoteID: String, targetNoteID: String, link: NotesLinkRecord) {
    self.sourceNoteID = sourceNoteID
    self.targetNoteID = targetNoteID
    self.link = link
  }
}

public struct NotesParagraphLinkAddDraft: Equatable, Sendable {
  public var sourceNoteID: String
  public var targetNoteID: String
  public var requestedTargetNoteID: String
  public var targetParagraphID: String
  public var requestedTargetParagraphIDSHA256: String
  public var targetParagraphIDSHA256: String
  public var targetParagraphTitle: String?

  public init(
    sourceNoteID: String,
    targetNoteID: String,
    requestedTargetNoteID: String,
    targetParagraphID: String,
    requestedTargetParagraphIDSHA256: String,
    targetParagraphIDSHA256: String,
    targetParagraphTitle: String? = nil
  ) {
    self.sourceNoteID = sourceNoteID
    self.targetNoteID = targetNoteID
    self.requestedTargetNoteID = requestedTargetNoteID
    self.targetParagraphID = targetParagraphID
    self.requestedTargetParagraphIDSHA256 = requestedTargetParagraphIDSHA256
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.targetParagraphTitle = targetParagraphTitle
  }
}

public struct NotesParagraphLinkAddWriteResult: Equatable, Sendable {
  public var sourceNoteID: String
  public var targetNoteID: String
  public var targetParagraphIDSHA256: String
  public var link: NotesLinkRecord

  public init(
    sourceNoteID: String,
    targetNoteID: String,
    targetParagraphIDSHA256: String,
    link: NotesLinkRecord
  ) {
    self.sourceNoteID = sourceNoteID
    self.targetNoteID = targetNoteID
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.link = link
  }
}

public struct NotesLinkUpdateDraft: Equatable, Sendable {
  public var noteID: String
  public var linkID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord
  public var url: URL
  public var urlString: String
  public var sourceKind: String?

  public init(
    noteID: String,
    linkID: String,
    requestedLinkID: String,
    link: NotesLinkRecord,
    url: URL,
    urlString: String,
    sourceKind: String? = nil
  ) {
    self.noteID = noteID
    self.linkID = linkID
    self.requestedLinkID = requestedLinkID
    self.link = link
    self.url = url
    self.urlString = urlString
    self.sourceKind = sourceKind
  }
}

public struct NotesLinkUpdateWriteResult: Equatable, Sendable {
  public var noteID: String
  public var oldLink: NotesLinkRecord
  public var link: NotesLinkRecord
  public var changed: Bool

  public init(noteID: String, oldLink: NotesLinkRecord, link: NotesLinkRecord, changed: Bool) {
    self.noteID = noteID
    self.oldLink = oldLink
    self.link = link
    self.changed = changed
  }
}

public struct NotesNoteLinkUpdateDraft: Equatable, Sendable {
  public var sourceNoteID: String
  public var linkID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord
  public var targetNoteID: String
  public var requestedTargetNoteID: String
  public var displayText: NotesNoteLinkDisplayTextDraft?

  public init(
    sourceNoteID: String,
    linkID: String,
    requestedLinkID: String,
    link: NotesLinkRecord,
    targetNoteID: String,
    requestedTargetNoteID: String,
    displayText: NotesNoteLinkDisplayTextDraft? = nil
  ) {
    self.sourceNoteID = sourceNoteID
    self.linkID = linkID
    self.requestedLinkID = requestedLinkID
    self.link = link
    self.targetNoteID = targetNoteID
    self.requestedTargetNoteID = requestedTargetNoteID
    self.displayText = displayText
  }
}

public struct NotesNoteLinkUpdateWriteResult: Equatable, Sendable {
  public var sourceNoteID: String
  public var oldTargetNoteID: String
  public var targetNoteID: String
  public var oldLink: NotesLinkRecord
  public var link: NotesLinkRecord
  public var changed: Bool

  public init(
    sourceNoteID: String,
    oldTargetNoteID: String,
    targetNoteID: String,
    oldLink: NotesLinkRecord,
    link: NotesLinkRecord,
    changed: Bool
  ) {
    self.sourceNoteID = sourceNoteID
    self.oldTargetNoteID = oldTargetNoteID
    self.targetNoteID = targetNoteID
    self.oldLink = oldLink
    self.link = link
    self.changed = changed
  }
}

public struct NotesParagraphLinkUpdateDraft: Equatable, Sendable {
  public var sourceNoteID: String
  public var linkID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord
  public var targetNoteID: String
  public var requestedTargetNoteID: String
  public var targetParagraphID: String
  public var requestedTargetParagraphIDSHA256: String
  public var targetParagraphIDSHA256: String
  public var targetParagraphTitle: String?

  public init(
    sourceNoteID: String,
    linkID: String,
    requestedLinkID: String,
    link: NotesLinkRecord,
    targetNoteID: String,
    requestedTargetNoteID: String,
    targetParagraphID: String,
    requestedTargetParagraphIDSHA256: String,
    targetParagraphIDSHA256: String,
    targetParagraphTitle: String? = nil
  ) {
    self.sourceNoteID = sourceNoteID
    self.linkID = linkID
    self.requestedLinkID = requestedLinkID
    self.link = link
    self.targetNoteID = targetNoteID
    self.requestedTargetNoteID = requestedTargetNoteID
    self.targetParagraphID = targetParagraphID
    self.requestedTargetParagraphIDSHA256 = requestedTargetParagraphIDSHA256
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.targetParagraphTitle = targetParagraphTitle
  }
}

public struct NotesParagraphLinkUpdateWriteResult: Equatable, Sendable {
  public var sourceNoteID: String
  public var oldTargetNoteID: String
  public var targetNoteID: String
  public var oldTargetParagraphIDSHA256: String?
  public var targetParagraphIDSHA256: String
  public var oldTokenContentIdentifierSHA256: String?
  public var targetTokenContentIdentifierSHA256: String
  public var oldLink: NotesLinkRecord
  public var link: NotesLinkRecord
  public var changed: Bool

  public init(
    sourceNoteID: String,
    oldTargetNoteID: String,
    targetNoteID: String,
    oldTargetParagraphIDSHA256: String? = nil,
    targetParagraphIDSHA256: String,
    oldTokenContentIdentifierSHA256: String? = nil,
    targetTokenContentIdentifierSHA256: String,
    oldLink: NotesLinkRecord,
    link: NotesLinkRecord,
    changed: Bool
  ) {
    self.sourceNoteID = sourceNoteID
    self.oldTargetNoteID = oldTargetNoteID
    self.targetNoteID = targetNoteID
    self.oldTargetParagraphIDSHA256 = oldTargetParagraphIDSHA256
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.oldTokenContentIdentifierSHA256 = oldTokenContentIdentifierSHA256
    self.targetTokenContentIdentifierSHA256 = targetTokenContentIdentifierSHA256
    self.oldLink = oldLink
    self.link = link
    self.changed = changed
  }
}

public struct NotesNoteLinkRemoveDraft: Equatable, Sendable {
  public var noteID: String
  public var linkID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord

  public init(noteID: String, linkID: String, requestedLinkID: String, link: NotesLinkRecord) {
    self.noteID = noteID
    self.linkID = linkID
    self.requestedLinkID = requestedLinkID
    self.link = link
  }
}

public struct NotesNoteLinkRemoveWriteResult: Equatable, Sendable {
  public var noteID: String
  public var link: NotesLinkRecord
  public var changed: Bool

  public init(noteID: String, link: NotesLinkRecord, changed: Bool) {
    self.noteID = noteID
    self.link = link
    self.changed = changed
  }
}

public struct NotesParagraphLinkRemoveDraft: Equatable, Sendable {
  public var noteID: String
  public var linkID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord

  public init(noteID: String, linkID: String, requestedLinkID: String, link: NotesLinkRecord) {
    self.noteID = noteID
    self.linkID = linkID
    self.requestedLinkID = requestedLinkID
    self.link = link
  }
}

public struct NotesParagraphLinkRemoveWriteResult: Equatable, Sendable {
  public var noteID: String
  public var link: NotesLinkRecord
  public var changed: Bool

  public init(noteID: String, link: NotesLinkRecord, changed: Bool) {
    self.noteID = noteID
    self.link = link
    self.changed = changed
  }
}

public struct NotesLinkRemoveDraft: Equatable, Sendable {
  public var noteID: String
  public var linkID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord

  public init(noteID: String, linkID: String, requestedLinkID: String, link: NotesLinkRecord) {
    self.noteID = noteID
    self.linkID = linkID
    self.requestedLinkID = requestedLinkID
    self.link = link
  }
}

public struct NotesLinkRemoveWriteResult: Equatable, Sendable {
  public var noteID: String
  public var link: NotesLinkRecord
  public var changed: Bool

  public init(noteID: String, link: NotesLinkRecord, changed: Bool) {
    self.noteID = noteID
    self.link = link
    self.changed = changed
  }
}

public struct NotesLinkRemoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.link = link
    self.verification = verification
  }
}

public struct NotesLinkUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var oldLink: NotesLinkRecord
  public var link: NotesLinkRecord
  public var oldURLSHA256: String?
  public var urlSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    oldLink: NotesLinkRecord,
    link: NotesLinkRecord,
    oldURLSHA256: String?,
    urlSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.oldLink = oldLink
    self.link = link
    self.oldURLSHA256 = oldURLSHA256
    self.urlSHA256 = urlSHA256
    self.verification = verification
  }
}

public struct NotesNoteLinkUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var oldTargetNoteIDSHA256: String
  public var targetNoteID: String
  public var targetNoteIDSHA256: String
  public var displayTextMode: String?
  public var displayTextSHA256: String?
  public var displayTextByteCount: Int?
  public var displayTextSourceKind: String?
  public var oldLink: NotesLinkRecord
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    oldTargetNoteIDSHA256: String,
    targetNoteID: String,
    targetNoteIDSHA256: String,
    displayTextMode: String? = nil,
    displayTextSHA256: String? = nil,
    displayTextByteCount: Int? = nil,
    displayTextSourceKind: String? = nil,
    oldLink: NotesLinkRecord,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.oldTargetNoteIDSHA256 = oldTargetNoteIDSHA256
    self.targetNoteID = targetNoteID
    self.targetNoteIDSHA256 = targetNoteIDSHA256
    self.displayTextMode = displayTextMode
    self.displayTextSHA256 = displayTextSHA256
    self.displayTextByteCount = displayTextByteCount
    self.displayTextSourceKind = displayTextSourceKind
    self.oldLink = oldLink
    self.link = link
    self.verification = verification
  }
}

public struct NotesLinkAddResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var link: NotesLinkRecord
  public var urlSHA256: String
  public var selectedTextConverted: Bool
  public var selectedTextParagraphIDSHA256: String?
  public var selectedTextOrdinal: Int?
  public var selectedTextByteCount: Int?
  public var selectedTextSHA256: String?
  public var selectedTextOccurrence: Int?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    link: NotesLinkRecord,
    urlSHA256: String,
    selectedTextConverted: Bool = false,
    selectedTextParagraphIDSHA256: String? = nil,
    selectedTextOrdinal: Int? = nil,
    selectedTextByteCount: Int? = nil,
    selectedTextSHA256: String? = nil,
    selectedTextOccurrence: Int? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.link = link
    self.urlSHA256 = urlSHA256
    self.selectedTextConverted = selectedTextConverted
    self.selectedTextParagraphIDSHA256 = selectedTextParagraphIDSHA256
    self.selectedTextOrdinal = selectedTextOrdinal
    self.selectedTextByteCount = selectedTextByteCount
    self.selectedTextSHA256 = selectedTextSHA256
    self.selectedTextOccurrence = selectedTextOccurrence
    self.verification = verification
  }
}

public struct NotesNoteLinkAddResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var targetNoteID: String
  public var targetNoteIDSHA256: String
  public var displayTextMode: String?
  public var displayTextSHA256: String?
  public var displayTextByteCount: Int?
  public var displayTextSourceKind: String?
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    targetNoteID: String,
    targetNoteIDSHA256: String,
    displayTextMode: String? = nil,
    displayTextSHA256: String? = nil,
    displayTextByteCount: Int? = nil,
    displayTextSourceKind: String? = nil,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.targetNoteID = targetNoteID
    self.targetNoteIDSHA256 = targetNoteIDSHA256
    self.displayTextMode = displayTextMode
    self.displayTextSHA256 = displayTextSHA256
    self.displayTextByteCount = displayTextByteCount
    self.displayTextSourceKind = displayTextSourceKind
    self.link = link
    self.verification = verification
  }
}

public struct NotesParagraphLinkAddResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var targetNoteID: String
  public var targetNoteIDSHA256: String
  public var targetParagraphIDSHA256: String
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    targetNoteID: String,
    targetNoteIDSHA256: String,
    targetParagraphIDSHA256: String,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.targetNoteID = targetNoteID
    self.targetNoteIDSHA256 = targetNoteIDSHA256
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.link = link
    self.verification = verification
  }
}

public struct NotesParagraphLinkUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var oldTargetNoteIDSHA256: String
  public var targetNoteID: String
  public var targetNoteIDSHA256: String
  public var oldTargetParagraphIDSHA256: String?
  public var targetParagraphIDSHA256: String
  public var oldTokenContentIdentifierSHA256: String?
  public var targetTokenContentIdentifierSHA256: String
  public var oldLink: NotesLinkRecord
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    oldTargetNoteIDSHA256: String,
    targetNoteID: String,
    targetNoteIDSHA256: String,
    oldTargetParagraphIDSHA256: String? = nil,
    targetParagraphIDSHA256: String,
    oldTokenContentIdentifierSHA256: String? = nil,
    targetTokenContentIdentifierSHA256: String,
    oldLink: NotesLinkRecord,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.oldTargetNoteIDSHA256 = oldTargetNoteIDSHA256
    self.targetNoteID = targetNoteID
    self.targetNoteIDSHA256 = targetNoteIDSHA256
    self.oldTargetParagraphIDSHA256 = oldTargetParagraphIDSHA256
    self.targetParagraphIDSHA256 = targetParagraphIDSHA256
    self.oldTokenContentIdentifierSHA256 = oldTokenContentIdentifierSHA256
    self.targetTokenContentIdentifierSHA256 = targetTokenContentIdentifierSHA256
    self.oldLink = oldLink
    self.link = link
    self.verification = verification
  }
}

public struct NotesNoteLinkRemoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.link = link
    self.verification = verification
  }
}

public struct NotesParagraphLinkRemoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var link: NotesLinkRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    link: NotesLinkRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.link = link
    self.verification = verification
  }
}

public struct NotesSmartFolderRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var accountName: String
  public var description: String?
  public var shortDescription: String?
  public var queryPresent: Bool
  public var queryJSONLength: Int?
  public var querySHA256: String?
  public var criteria: NotesSmartFolderCriteriaSummary?
  public var visibleNoteCount: Int?
  public var isEditable: Bool?
  public var isDeletable: Bool?

  public init(
    id: String,
    name: String,
    accountName: String,
    description: String? = nil,
    shortDescription: String? = nil,
    queryPresent: Bool,
    queryJSONLength: Int? = nil,
    querySHA256: String? = nil,
    criteria: NotesSmartFolderCriteriaSummary? = nil,
    visibleNoteCount: Int? = nil,
    isEditable: Bool? = nil,
    isDeletable: Bool? = nil
  ) {
    self.id = id
    self.name = name
    self.accountName = accountName
    self.description = description
    self.shortDescription = shortDescription
    self.queryPresent = queryPresent
    self.queryJSONLength = queryJSONLength
    self.querySHA256 = querySHA256
    self.criteria = criteria
    self.visibleNoteCount = visibleNoteCount
    self.isEditable = isEditable
    self.isDeletable = isDeletable
  }
}

public struct NotesSmartFolderCreateDraft: Codable, Equatable, Sendable {
  public var name: String
  public var accountID: String?
  public var accountName: String
  public var tagDisplayText: String
  public var tagStandardizedContent: String
  public var tagDisplayTexts: [String]
  public var tagStandardizedContents: [String]
  public var tagMatch: String
  public var tagOperator: Int
  public var matchedTagCount: Int
  public var matchingNoteCount: Int

  public init(
    name: String,
    accountID: String?,
    accountName: String,
    tagDisplayText: String,
    tagStandardizedContent: String,
    tagDisplayTexts: [String]? = nil,
    tagStandardizedContents: [String]? = nil,
    tagMatch: String = "all",
    tagOperator: Int = 1,
    matchedTagCount: Int,
    matchingNoteCount: Int
  ) {
    self.name = name
    self.accountID = accountID
    self.accountName = accountName
    self.tagDisplayText = tagDisplayText
    self.tagStandardizedContent = tagStandardizedContent
    self.tagDisplayTexts = tagDisplayTexts ?? [tagDisplayText]
    self.tagStandardizedContents = tagStandardizedContents ?? [tagStandardizedContent]
    self.tagMatch = tagMatch
    self.tagOperator = tagOperator
    self.matchedTagCount = matchedTagCount
    self.matchingNoteCount = matchingNoteCount
  }
}

public struct NotesSmartFolderCreateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord
  public var tag: NotesTagRecord

  public init(changed: Bool, smartFolder: NotesSmartFolderRecord, tag: NotesTagRecord) {
    self.changed = changed
    self.smartFolder = smartFolder
    self.tag = tag
  }
}

public struct NotesSmartFolderUpdateDraft: Codable, Equatable, Sendable {
  public var smartFolderID: String
  public var name: String
  public var accountName: String
  public var previousQueryPresent: Bool
  public var previousQuerySHA256: String?
  public var previousVisibleNoteCount: Int?
  public var tagDisplayText: String
  public var tagStandardizedContent: String
  public var tagDisplayTexts: [String]
  public var tagStandardizedContents: [String]
  public var tagMatch: String
  public var tagOperator: Int
  public var matchedTagCount: Int
  public var matchingNoteCount: Int

  public init(
    smartFolderID: String,
    name: String,
    accountName: String,
    previousQueryPresent: Bool,
    previousQuerySHA256: String? = nil,
    previousVisibleNoteCount: Int? = nil,
    tagDisplayText: String,
    tagStandardizedContent: String,
    tagDisplayTexts: [String]? = nil,
    tagStandardizedContents: [String]? = nil,
    tagMatch: String = "all",
    tagOperator: Int = 1,
    matchedTagCount: Int,
    matchingNoteCount: Int
  ) {
    self.smartFolderID = smartFolderID
    self.name = name
    self.accountName = accountName
    self.previousQueryPresent = previousQueryPresent
    self.previousQuerySHA256 = previousQuerySHA256
    self.previousVisibleNoteCount = previousVisibleNoteCount
    self.tagDisplayText = tagDisplayText
    self.tagStandardizedContent = tagStandardizedContent
    self.tagDisplayTexts = tagDisplayTexts ?? [tagDisplayText]
    self.tagStandardizedContents = tagStandardizedContents ?? [tagStandardizedContent]
    self.tagMatch = tagMatch
    self.tagOperator = tagOperator
    self.matchedTagCount = matchedTagCount
    self.matchingNoteCount = matchingNoteCount
  }
}

public struct NotesSmartFolderUpdateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord
  public var tag: NotesTagRecord

  public init(changed: Bool, smartFolder: NotesSmartFolderRecord, tag: NotesTagRecord) {
    self.changed = changed
    self.smartFolder = smartFolder
    self.tag = tag
  }
}

public struct NotesSmartFolderDateCriteriaParameters: Codable, Equatable, Sendable {
  public var primaryDate: Date?
  public var secondaryDate: Date?
  public var dateText: String?
  public var startDateText: String?
  public var endDateText: String?
  public var relativeAmount: Int?
  public var relativeUnit: String?
  public var relativeUnitSelectionType: UInt64?

  public init(
    primaryDate: Date? = nil,
    secondaryDate: Date? = nil,
    dateText: String? = nil,
    startDateText: String? = nil,
    endDateText: String? = nil,
    relativeAmount: Int? = nil,
    relativeUnit: String? = nil,
    relativeUnitSelectionType: UInt64? = nil
  ) {
    self.primaryDate = primaryDate
    self.secondaryDate = secondaryDate
    self.dateText = dateText
    self.startDateText = startDateText
    self.endDateText = endDateText
    self.relativeAmount = relativeAmount
    self.relativeUnit = relativeUnit
    self.relativeUnitSelectionType = relativeUnitSelectionType
  }
}

public struct NotesSmartFolderFolderCriteriaParameters: Codable, Equatable, Sendable {
  public var folderID: String
  public var folderName: String
  public var folderAccountName: String
  public var requestedFolder: String
  public var folderIDs: [String]
  public var folderNames: [String]
  public var requestedFolders: [String]
  public var inclusionType: Int

  public init(
    folderID: String,
    folderName: String,
    folderAccountName: String,
    requestedFolder: String,
    inclusionType: Int,
    folderIDs: [String]? = nil,
    folderNames: [String]? = nil,
    requestedFolders: [String]? = nil
  ) {
    self.folderID = folderID
    self.folderName = folderName
    self.folderAccountName = folderAccountName
    self.requestedFolder = requestedFolder
    self.folderIDs = folderIDs ?? (folderID.isEmpty ? [] : [folderID])
    self.folderNames = folderNames ?? (folderName.isEmpty ? [] : [folderName])
    self.requestedFolders = requestedFolders ?? (requestedFolder.isEmpty ? [] : [requestedFolder])
    self.inclusionType = inclusionType
  }
}

public struct NotesSmartFolderParticipantCriteriaParameters: Codable, Equatable, Sendable {
  public var participantUserID: String
  public var participantUserIDSHA256: String
  public var selectionType: Int
  public var joinOperator: Int

  enum CodingKeys: String, CodingKey {
    case participantUserIDSHA256
    case selectionType
    case joinOperator
  }

  public init(
    participantUserID: String,
    selectionType: Int = 1,
    joinOperator: Int = 0
  ) {
    self.participantUserID = participantUserID
    self.participantUserIDSHA256 = sha256Hex(participantUserID)
    self.selectionType = selectionType
    self.joinOperator = joinOperator
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.participantUserID = ""
    self.participantUserIDSHA256 = try container.decode(String.self, forKey: .participantUserIDSHA256)
    self.selectionType = try container.decode(Int.self, forKey: .selectionType)
    self.joinOperator = try container.decode(Int.self, forKey: .joinOperator)
  }
}

public struct NotesSmartFolderBuiltInCriteriaCreateDraft: Codable, Equatable, Sendable {
  public var name: String
  public var accountID: String?
  public var accountName: String
  public var criteriaKind: String
  public var criteriaKinds: [String]
  public var criteriaMatch: String
  public var joinOperator: Int
  public var includeRecentlyDeleted: Bool
  public var dateCriteria: NotesSmartFolderDateCriteriaParameters?
  public var folderCriteria: NotesSmartFolderFolderCriteriaParameters?
  public var folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]
  public var participantCriteria: NotesSmartFolderParticipantCriteriaParameters?

  public init(
    name: String,
    accountID: String?,
    accountName: String,
    criteriaKind: String,
    criteriaKinds: [String]? = nil,
    criteriaMatch: String = "all",
    joinOperator: Int = 1,
    includeRecentlyDeleted: Bool,
    dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]? = nil,
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters? = nil
  ) {
    self.name = name
    self.accountID = accountID
    self.accountName = accountName
    self.criteriaKind = criteriaKind
    self.criteriaKinds = criteriaKinds ?? [criteriaKind]
    self.criteriaMatch = criteriaMatch
    self.joinOperator = joinOperator
    self.includeRecentlyDeleted = includeRecentlyDeleted
    self.dateCriteria = dateCriteria
    self.folderCriteria = folderCriteria
    if let folderCriteriaByKind {
      self.folderCriteriaByKind = folderCriteriaByKind
    } else if let folderCriteria {
      switch folderCriteria.inclusionType {
      case 1:
        self.folderCriteriaByKind = ["folder": folderCriteria]
      case 0:
        self.folderCriteriaByKind = ["not-folder": folderCriteria]
      default:
        self.folderCriteriaByKind = [:]
      }
    } else {
      self.folderCriteriaByKind = [:]
    }
    self.participantCriteria = participantCriteria
  }
}

public struct NotesSmartFolderBuiltInCriteriaCreateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord

  public init(changed: Bool, smartFolder: NotesSmartFolderRecord) {
    self.changed = changed
    self.smartFolder = smartFolder
  }
}

public struct NotesSmartFolderBuiltInCriteriaUpdateDraft: Codable, Equatable, Sendable {
  public var smartFolderID: String
  public var name: String
  public var accountName: String
  public var previousQueryPresent: Bool
  public var previousQuerySHA256: String?
  public var previousVisibleNoteCount: Int?
  public var criteriaKind: String
  public var criteriaKinds: [String]
  public var criteriaMatch: String
  public var joinOperator: Int
  public var includeRecentlyDeleted: Bool
  public var dateCriteria: NotesSmartFolderDateCriteriaParameters?
  public var folderCriteria: NotesSmartFolderFolderCriteriaParameters?
  public var folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]
  public var participantCriteria: NotesSmartFolderParticipantCriteriaParameters?

  public init(
    smartFolderID: String,
    name: String,
    accountName: String,
    previousQueryPresent: Bool,
    previousQuerySHA256: String? = nil,
    previousVisibleNoteCount: Int? = nil,
    criteriaKind: String,
    criteriaKinds: [String]? = nil,
    criteriaMatch: String = "all",
    joinOperator: Int = 1,
    includeRecentlyDeleted: Bool,
    dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]? = nil,
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters? = nil
  ) {
    self.smartFolderID = smartFolderID
    self.name = name
    self.accountName = accountName
    self.previousQueryPresent = previousQueryPresent
    self.previousQuerySHA256 = previousQuerySHA256
    self.previousVisibleNoteCount = previousVisibleNoteCount
    self.criteriaKind = criteriaKind
    self.criteriaKinds = criteriaKinds ?? [criteriaKind]
    self.criteriaMatch = criteriaMatch
    self.joinOperator = joinOperator
    self.includeRecentlyDeleted = includeRecentlyDeleted
    self.dateCriteria = dateCriteria
    self.folderCriteria = folderCriteria
    if let folderCriteriaByKind {
      self.folderCriteriaByKind = folderCriteriaByKind
    } else if let folderCriteria {
      switch folderCriteria.inclusionType {
      case 1:
        self.folderCriteriaByKind = ["folder": folderCriteria]
      case 0:
        self.folderCriteriaByKind = ["not-folder": folderCriteria]
      default:
        self.folderCriteriaByKind = [:]
      }
    } else {
      self.folderCriteriaByKind = [:]
    }
    self.participantCriteria = participantCriteria
  }
}

public struct NotesSmartFolderBuiltInCriteriaUpdateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord

  public init(changed: Bool, smartFolder: NotesSmartFolderRecord) {
    self.changed = changed
    self.smartFolder = smartFolder
  }
}

public struct NotesSmartFolderFilterMutationDraft: Codable, Equatable, Sendable {
  public var mutationKind: String
  public var ordinal: Int
  public var criteriaKind: String?
  public var previousCriteriaKinds: [String]
  public var resultingCriteriaKinds: [String]
  public var updateDraft: NotesSmartFolderBuiltInCriteriaUpdateDraft

  public init(
    mutationKind: String,
    ordinal: Int,
    criteriaKind: String? = nil,
    previousCriteriaKinds: [String],
    resultingCriteriaKinds: [String],
    updateDraft: NotesSmartFolderBuiltInCriteriaUpdateDraft
  ) {
    self.mutationKind = mutationKind
    self.ordinal = ordinal
    self.criteriaKind = criteriaKind
    self.previousCriteriaKinds = previousCriteriaKinds
    self.resultingCriteriaKinds = resultingCriteriaKinds
    self.updateDraft = updateDraft
  }
}

public struct NotesSmartFolderDuplicateDraft: Codable, Equatable, Sendable {
  public var sourceSmartFolderID: String
  public var sourceName: String
  public var name: String
  public var accountName: String
  public var sourceQueryPresent: Bool
  public var sourceQuerySHA256: String?
  public var sourceVisibleNoteCount: Int?
  public var sourceCriteria: NotesSmartFolderCriteriaSummary?
  public var sourceMatchingNoteCount: Int

  public init(
    sourceSmartFolderID: String,
    sourceName: String,
    name: String,
    accountName: String,
    sourceQueryPresent: Bool,
    sourceQuerySHA256: String? = nil,
    sourceVisibleNoteCount: Int? = nil,
    sourceCriteria: NotesSmartFolderCriteriaSummary? = nil,
    sourceMatchingNoteCount: Int
  ) {
    self.sourceSmartFolderID = sourceSmartFolderID
    self.sourceName = sourceName
    self.name = name
    self.accountName = accountName
    self.sourceQueryPresent = sourceQueryPresent
    self.sourceQuerySHA256 = sourceQuerySHA256
    self.sourceVisibleNoteCount = sourceVisibleNoteCount
    self.sourceCriteria = sourceCriteria
    self.sourceMatchingNoteCount = sourceMatchingNoteCount
  }
}

public struct NotesSmartFolderDuplicateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord
  public var sourceSmartFolder: NotesSmartFolderRecord

  public init(
    changed: Bool,
    smartFolder: NotesSmartFolderRecord,
    sourceSmartFolder: NotesSmartFolderRecord
  ) {
    self.changed = changed
    self.smartFolder = smartFolder
    self.sourceSmartFolder = sourceSmartFolder
  }
}

public struct NotesSmartFolderCriteriaCopyDraft: Codable, Equatable, Sendable {
  public var sourceSmartFolderID: String
  public var sourceName: String
  public var targetSmartFolderID: String
  public var targetName: String
  public var accountName: String
  public var sourceQueryPresent: Bool
  public var sourceQuerySHA256: String?
  public var sourceVisibleNoteCount: Int?
  public var sourceCriteria: NotesSmartFolderCriteriaSummary?
  public var sourceMatchingNoteCount: Int
  public var targetPreviousQueryPresent: Bool
  public var targetPreviousQuerySHA256: String?
  public var targetPreviousVisibleNoteCount: Int?

  public init(
    sourceSmartFolderID: String,
    sourceName: String,
    targetSmartFolderID: String,
    targetName: String,
    accountName: String,
    sourceQueryPresent: Bool,
    sourceQuerySHA256: String? = nil,
    sourceVisibleNoteCount: Int? = nil,
    sourceCriteria: NotesSmartFolderCriteriaSummary? = nil,
    sourceMatchingNoteCount: Int,
    targetPreviousQueryPresent: Bool,
    targetPreviousQuerySHA256: String? = nil,
    targetPreviousVisibleNoteCount: Int? = nil
  ) {
    self.sourceSmartFolderID = sourceSmartFolderID
    self.sourceName = sourceName
    self.targetSmartFolderID = targetSmartFolderID
    self.targetName = targetName
    self.accountName = accountName
    self.sourceQueryPresent = sourceQueryPresent
    self.sourceQuerySHA256 = sourceQuerySHA256
    self.sourceVisibleNoteCount = sourceVisibleNoteCount
    self.sourceCriteria = sourceCriteria
    self.sourceMatchingNoteCount = sourceMatchingNoteCount
    self.targetPreviousQueryPresent = targetPreviousQueryPresent
    self.targetPreviousQuerySHA256 = targetPreviousQuerySHA256
    self.targetPreviousVisibleNoteCount = targetPreviousVisibleNoteCount
  }
}

public struct NotesSmartFolderCriteriaCopyWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord
  public var sourceSmartFolder: NotesSmartFolderRecord

  public init(
    changed: Bool,
    smartFolder: NotesSmartFolderRecord,
    sourceSmartFolder: NotesSmartFolderRecord
  ) {
    self.changed = changed
    self.smartFolder = smartFolder
    self.sourceSmartFolder = sourceSmartFolder
  }
}

public struct NotesSmartFolderCriteriaExportSource: Equatable, Sendable {
  public var smartFolder: NotesSmartFolderRecord
  public var data: Data

  public init(smartFolder: NotesSmartFolderRecord, data: Data) {
    self.smartFolder = smartFolder
    self.data = data
  }
}

public struct NotesSmartFolderCriteriaExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    smartFolder: NotesSmartFolderRecord,
    destinationPath: String,
    byteCount: Int,
    sha256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.smartFolder = smartFolder
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
  }
}

public struct NotesSmartFolderCriteriaImportDraft: Codable, Equatable, Sendable {
  public var smartFolderID: String
  public var name: String
  public var accountName: String
  public var previousQueryPresent: Bool
  public var previousQuerySHA256: String?
  public var previousVisibleNoteCount: Int?
  public var sourcePath: String
  public var queryJSON: String
  public var sourceByteCount: Int
  public var sourceSHA256: String

  public init(
    smartFolderID: String,
    name: String,
    accountName: String,
    previousQueryPresent: Bool,
    previousQuerySHA256: String? = nil,
    previousVisibleNoteCount: Int? = nil,
    sourcePath: String,
    queryJSON: String,
    sourceByteCount: Int,
    sourceSHA256: String
  ) {
    self.smartFolderID = smartFolderID
    self.name = name
    self.accountName = accountName
    self.previousQueryPresent = previousQueryPresent
    self.previousQuerySHA256 = previousQuerySHA256
    self.previousVisibleNoteCount = previousVisibleNoteCount
    self.sourcePath = sourcePath
    self.queryJSON = queryJSON
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
  }
}

public struct NotesSmartFolderCriteriaImportWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord

  public init(changed: Bool, smartFolder: NotesSmartFolderRecord) {
    self.changed = changed
    self.smartFolder = smartFolder
  }
}

public struct NotesSmartFolderRenameDraft: Codable, Equatable, Sendable {
  public var smartFolderID: String
  public var currentName: String
  public var newName: String
  public var accountName: String
  public var queryPresent: Bool
  public var querySHA256: String?
  public var visibleNoteCount: Int?

  public init(
    smartFolderID: String,
    currentName: String,
    newName: String,
    accountName: String,
    queryPresent: Bool,
    querySHA256: String? = nil,
    visibleNoteCount: Int? = nil
  ) {
    self.smartFolderID = smartFolderID
    self.currentName = currentName
    self.newName = newName
    self.accountName = accountName
    self.queryPresent = queryPresent
    self.querySHA256 = querySHA256
    self.visibleNoteCount = visibleNoteCount
  }
}

public struct NotesSmartFolderDeleteDraft: Codable, Equatable, Sendable {
  public var smartFolderID: String
  public var name: String
  public var accountName: String
  public var queryPresent: Bool
  public var visibleNoteCount: Int?

  public init(
    smartFolderID: String,
    name: String,
    accountName: String,
    queryPresent: Bool,
    visibleNoteCount: Int? = nil
  ) {
    self.smartFolderID = smartFolderID
    self.name = name
    self.accountName = accountName
    self.queryPresent = queryPresent
    self.visibleNoteCount = visibleNoteCount
  }
}

public struct NotesSmartFolderFolderConversionDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var folderName: String
  public var accountName: String
  public var parentID: String?
  public var visibleNoteCount: Int
  public var childFolderCount: Int
  public var noteIDs: [String]
  public var noteIDHashes: [String]
  public var tagDisplayText: String
  public var tagStandardizedContent: String
  public var targetFolderID: String?
  public var targetFolderName: String?

  enum CodingKeys: String, CodingKey {
    case folderID
    case folderName
    case accountName
    case parentID
    case visibleNoteCount
    case childFolderCount
    case noteIDHashes
    case tagDisplayText
    case tagStandardizedContent
    case targetFolderID
    case targetFolderName
  }

  public init(
    folderID: String,
    folderName: String,
    accountName: String,
    parentID: String? = nil,
    visibleNoteCount: Int,
    childFolderCount: Int,
    noteIDs: [String],
    noteIDHashes: [String]? = nil,
    tagDisplayText: String,
    tagStandardizedContent: String,
    targetFolderID: String? = nil,
    targetFolderName: String? = nil
  ) {
    self.folderID = folderID
    self.folderName = folderName
    self.accountName = accountName
    self.parentID = parentID
    self.visibleNoteCount = visibleNoteCount
    self.childFolderCount = childFolderCount
    self.noteIDs = noteIDs
    self.noteIDHashes = noteIDHashes ?? noteIDs.map(sha256Hex)
    self.tagDisplayText = tagDisplayText
    self.tagStandardizedContent = tagStandardizedContent
    self.targetFolderID = targetFolderID
    self.targetFolderName = targetFolderName
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.folderID = try container.decode(String.self, forKey: .folderID)
    self.folderName = try container.decode(String.self, forKey: .folderName)
    self.accountName = try container.decode(String.self, forKey: .accountName)
    self.parentID = try container.decodeIfPresent(String.self, forKey: .parentID)
    self.visibleNoteCount = try container.decode(Int.self, forKey: .visibleNoteCount)
    self.childFolderCount = try container.decode(Int.self, forKey: .childFolderCount)
    self.noteIDs = []
    self.noteIDHashes = try container.decode([String].self, forKey: .noteIDHashes)
    self.tagDisplayText = try container.decode(String.self, forKey: .tagDisplayText)
    self.tagStandardizedContent = try container.decode(String.self, forKey: .tagStandardizedContent)
    self.targetFolderID = try container.decodeIfPresent(String.self, forKey: .targetFolderID)
    self.targetFolderName = try container.decodeIfPresent(String.self, forKey: .targetFolderName)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(folderID, forKey: .folderID)
    try container.encode(folderName, forKey: .folderName)
    try container.encode(accountName, forKey: .accountName)
    try container.encodeIfPresent(parentID, forKey: .parentID)
    try container.encode(visibleNoteCount, forKey: .visibleNoteCount)
    try container.encode(childFolderCount, forKey: .childFolderCount)
    try container.encode(noteIDHashes, forKey: .noteIDHashes)
    try container.encode(tagDisplayText, forKey: .tagDisplayText)
    try container.encode(tagStandardizedContent, forKey: .tagStandardizedContent)
    try container.encodeIfPresent(targetFolderID, forKey: .targetFolderID)
    try container.encodeIfPresent(targetFolderName, forKey: .targetFolderName)
  }
}

public struct NotesSmartFolderFolderConversionWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord
  public var sourceFolderID: String
  public var sourceFolderName: String
  public var targetFolderID: String?
  public var targetFolderName: String?
  public var tag: NotesTagRecord
  public var movedNoteCount: Int
  public var taggedNoteCount: Int
  public var noteIDHashes: [String]

  public init(
    changed: Bool,
    smartFolder: NotesSmartFolderRecord,
    sourceFolderID: String,
    sourceFolderName: String,
    targetFolderID: String? = nil,
    targetFolderName: String? = nil,
    tag: NotesTagRecord,
    movedNoteCount: Int,
    taggedNoteCount: Int,
    noteIDHashes: [String]
  ) {
    self.changed = changed
    self.smartFolder = smartFolder
    self.sourceFolderID = sourceFolderID
    self.sourceFolderName = sourceFolderName
    self.targetFolderID = targetFolderID
    self.targetFolderName = targetFolderName
    self.tag = tag
    self.movedNoteCount = movedNoteCount
    self.taggedNoteCount = taggedNoteCount
    self.noteIDHashes = noteIDHashes
  }
}

public struct NotesSmartFolderCriteriaSummary: Codable, Equatable, Sendable {
  public var queryKind: String
  public var canBeEdited: Bool?
  public var minimumSupportedVersion: Int?
  public var entityName: String?
  public var predicatePresent: Bool
  public var predicateFormatLength: Int?
  public var predicateFormatSHA256: String?
  public var joinOperator: Int?
  public var includeRecentlyDeleted: Bool?
  public var isValid: Bool?
  public var filterCount: Int
  public var filters: [NotesSmartFolderCriteriaFilter]
  public var tagSelection: NotesSmartFolderTagCriteria?

  public init(
    queryKind: String,
    canBeEdited: Bool? = nil,
    minimumSupportedVersion: Int? = nil,
    entityName: String? = nil,
    predicatePresent: Bool = false,
    predicateFormatLength: Int? = nil,
    predicateFormatSHA256: String? = nil,
    joinOperator: Int? = nil,
    includeRecentlyDeleted: Bool? = nil,
    isValid: Bool? = nil,
    filterCount: Int = 0,
    filters: [NotesSmartFolderCriteriaFilter] = [],
    tagSelection: NotesSmartFolderTagCriteria? = nil
  ) {
    self.queryKind = queryKind
    self.canBeEdited = canBeEdited
    self.minimumSupportedVersion = minimumSupportedVersion
    self.entityName = entityName
    self.predicatePresent = predicatePresent
    self.predicateFormatLength = predicateFormatLength
    self.predicateFormatSHA256 = predicateFormatSHA256
    self.joinOperator = joinOperator
    self.includeRecentlyDeleted = includeRecentlyDeleted
    self.isValid = isValid
    self.filterCount = filterCount
    self.filters = filters
    self.tagSelection = tagSelection
  }
}

public struct NotesSmartFolderCriteriaFilter: Codable, Equatable, Sendable {
  public var kind: String
  public var isEmpty: Bool?
  public var isValid: Bool?
  public var selectionType: Int?
  public var inclusionType: Int?
  public var joinOperator: Int?
  public var rawValuePresent: Bool
  public var rawValueLength: Int?
  public var rawValueSHA256: String?
  public var count: Int?
  public var includedCount: Int?
  public var excludedCount: Int?
  public var hasPrimaryDate: Bool?
  public var hasSecondaryDate: Bool?
  public var hasRelativeRange: Bool?
  public var folderID: String?
  public var primaryDate: Date?
  public var secondaryDate: Date?
  public var relativeRangeAmount: Int?
  public var relativeRangeSelectionType: Int?
  public var participantUserIDSHA256s: [String]

  public init(
    kind: String,
    isEmpty: Bool? = nil,
    isValid: Bool? = nil,
    selectionType: Int? = nil,
    inclusionType: Int? = nil,
    joinOperator: Int? = nil,
    rawValuePresent: Bool = false,
    rawValueLength: Int? = nil,
    rawValueSHA256: String? = nil,
    count: Int? = nil,
    includedCount: Int? = nil,
    excludedCount: Int? = nil,
    hasPrimaryDate: Bool? = nil,
    hasSecondaryDate: Bool? = nil,
    hasRelativeRange: Bool? = nil,
    folderID: String? = nil,
    primaryDate: Date? = nil,
    secondaryDate: Date? = nil,
    relativeRangeAmount: Int? = nil,
    relativeRangeSelectionType: Int? = nil,
    participantUserIDSHA256s: [String] = []
  ) {
    self.kind = kind
    self.isEmpty = isEmpty
    self.isValid = isValid
    self.selectionType = selectionType
    self.inclusionType = inclusionType
    self.joinOperator = joinOperator
    self.rawValuePresent = rawValuePresent
    self.rawValueLength = rawValueLength
    self.rawValueSHA256 = rawValueSHA256
    self.count = count
    self.includedCount = includedCount
    self.excludedCount = excludedCount
    self.hasPrimaryDate = hasPrimaryDate
    self.hasSecondaryDate = hasSecondaryDate
    self.hasRelativeRange = hasRelativeRange
    self.folderID = folderID
    self.primaryDate = primaryDate
    self.secondaryDate = secondaryDate
    self.relativeRangeAmount = relativeRangeAmount
    self.relativeRangeSelectionType = relativeRangeSelectionType
    self.participantUserIDSHA256s = participantUserIDSHA256s
  }

  enum CodingKeys: String, CodingKey {
    case kind
    case isEmpty
    case isValid
    case selectionType
    case inclusionType
    case joinOperator
    case rawValuePresent
    case rawValueLength
    case rawValueSHA256
    case count
    case includedCount
    case excludedCount
    case hasPrimaryDate
    case hasSecondaryDate
    case hasRelativeRange
    case participantUserIDSHA256s
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.kind = try container.decode(String.self, forKey: .kind)
    self.isEmpty = try container.decodeIfPresent(Bool.self, forKey: .isEmpty)
    self.isValid = try container.decodeIfPresent(Bool.self, forKey: .isValid)
    self.selectionType = try container.decodeIfPresent(Int.self, forKey: .selectionType)
    self.inclusionType = try container.decodeIfPresent(Int.self, forKey: .inclusionType)
    self.joinOperator = try container.decodeIfPresent(Int.self, forKey: .joinOperator)
    self.rawValuePresent = try container.decodeIfPresent(Bool.self, forKey: .rawValuePresent) ?? false
    self.rawValueLength = try container.decodeIfPresent(Int.self, forKey: .rawValueLength)
    self.rawValueSHA256 = try container.decodeIfPresent(String.self, forKey: .rawValueSHA256)
    self.count = try container.decodeIfPresent(Int.self, forKey: .count)
    self.includedCount = try container.decodeIfPresent(Int.self, forKey: .includedCount)
    self.excludedCount = try container.decodeIfPresent(Int.self, forKey: .excludedCount)
    self.hasPrimaryDate = try container.decodeIfPresent(Bool.self, forKey: .hasPrimaryDate)
    self.hasSecondaryDate = try container.decodeIfPresent(Bool.self, forKey: .hasSecondaryDate)
    self.hasRelativeRange = try container.decodeIfPresent(Bool.self, forKey: .hasRelativeRange)
    self.folderID = nil
    self.primaryDate = nil
    self.secondaryDate = nil
    self.relativeRangeAmount = nil
    self.relativeRangeSelectionType = nil
    self.participantUserIDSHA256s =
      try container.decodeIfPresent([String].self, forKey: .participantUserIDSHA256s) ?? []
  }
}

public struct NotesSmartFolderTagCriteria: Codable, Equatable, Sendable {
  public var selectedTagCount: Int?
  public var includedTagCount: Int?
  public var excludedTagCount: Int?
  public var tagOperator: Int?
  public var mode: Int?
  public var allowsRecentlyDeleted: Bool?
  public var tagIdentifiersSHA256: String?
  public var displayTextsSHA256: String?
  public var tagIdentifiers: [String]?
  public var displayTexts: [String]?
  public var includedTagIdentifiers: [String]?
  public var includedDisplayTexts: [String]?
  public var excludedTagIdentifiers: [String]?
  public var excludedDisplayTexts: [String]?

  public init(
    selectedTagCount: Int? = nil,
    includedTagCount: Int? = nil,
    excludedTagCount: Int? = nil,
    tagOperator: Int? = nil,
    mode: Int? = nil,
    allowsRecentlyDeleted: Bool? = nil,
    tagIdentifiersSHA256: String? = nil,
    displayTextsSHA256: String? = nil,
    tagIdentifiers: [String]? = nil,
    displayTexts: [String]? = nil,
    includedTagIdentifiers: [String]? = nil,
    includedDisplayTexts: [String]? = nil,
    excludedTagIdentifiers: [String]? = nil,
    excludedDisplayTexts: [String]? = nil
  ) {
    self.selectedTagCount = selectedTagCount
    self.includedTagCount = includedTagCount
    self.excludedTagCount = excludedTagCount
    self.tagOperator = tagOperator
    self.mode = mode
    self.allowsRecentlyDeleted = allowsRecentlyDeleted
    self.tagIdentifiersSHA256 = tagIdentifiersSHA256
    self.displayTextsSHA256 = displayTextsSHA256
    self.tagIdentifiers = tagIdentifiers
    self.displayTexts = displayTexts
    self.includedTagIdentifiers = includedTagIdentifiers
    self.includedDisplayTexts = includedDisplayTexts
    self.excludedTagIdentifiers = excludedTagIdentifiers
    self.excludedDisplayTexts = excludedDisplayTexts
  }

  enum CodingKeys: String, CodingKey {
    case selectedTagCount
    case includedTagCount
    case excludedTagCount
    case tagOperator
    case mode
    case allowsRecentlyDeleted
    case tagIdentifiersSHA256
    case displayTextsSHA256
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.selectedTagCount = try container.decodeIfPresent(Int.self, forKey: .selectedTagCount)
    self.includedTagCount = try container.decodeIfPresent(Int.self, forKey: .includedTagCount)
    self.excludedTagCount = try container.decodeIfPresent(Int.self, forKey: .excludedTagCount)
    self.tagOperator = try container.decodeIfPresent(Int.self, forKey: .tagOperator)
    self.mode = try container.decodeIfPresent(Int.self, forKey: .mode)
    self.allowsRecentlyDeleted = try container.decodeIfPresent(Bool.self, forKey: .allowsRecentlyDeleted)
    self.tagIdentifiersSHA256 = try container.decodeIfPresent(String.self, forKey: .tagIdentifiersSHA256)
    self.displayTextsSHA256 = try container.decodeIfPresent(String.self, forKey: .displayTextsSHA256)
    self.tagIdentifiers = nil
    self.displayTexts = nil
    self.includedTagIdentifiers = nil
    self.includedDisplayTexts = nil
    self.excludedTagIdentifiers = nil
    self.excludedDisplayTexts = nil
  }
}

public struct NotesBodyStyleCount: Codable, Equatable, Sendable {
  public var style: String
  public var count: Int

  public init(style: String, count: Int) {
    self.style = style
    self.count = count
  }
}

public struct NotesBodyAttachmentKindCount: Codable, Equatable, Sendable {
  public var kind: String
  public var count: Int

  public init(kind: String, count: Int) {
    self.kind = kind
    self.count = count
  }
}

public struct NotesBodyInlineFormatCount: Codable, Equatable, Sendable {
  public var format: String
  public var count: Int

  public init(format: String, count: Int) {
    self.format = format
    self.count = count
  }
}

public struct NotesBodyColorHashCount: Codable, Equatable, Sendable {
  public var role: String
  public var colorSHA256: String
  public var count: Int

  public init(role: String, colorSHA256: String, count: Int) {
    self.role = role
    self.colorSHA256 = colorSHA256
    self.count = count
  }
}

public struct NotesBodyInlineFormatRunRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var paragraphIDSHA256: String?
  public var format: String
  public var fontSHA256: String?
  public var textByteCount: Int
  public var textSHA256: String

  public init(
    ordinal: Int,
    paragraphIDSHA256: String? = nil,
    format: String,
    fontSHA256: String? = nil,
    textByteCount: Int,
    textSHA256: String
  ) {
    self.ordinal = ordinal
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.format = format
    self.fontSHA256 = fontSHA256
    self.textByteCount = textByteCount
    self.textSHA256 = textSHA256
  }
}

public struct NotesBodyInlineColorRunRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var paragraphIDSHA256: String?
  public var role: String
  public var colorSHA256: String
  public var textByteCount: Int
  public var textSHA256: String

  public init(
    ordinal: Int,
    paragraphIDSHA256: String? = nil,
    role: String,
    colorSHA256: String,
    textByteCount: Int,
    textSHA256: String
  ) {
    self.ordinal = ordinal
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.role = role
    self.colorSHA256 = colorSHA256
    self.textByteCount = textByteCount
    self.textSHA256 = textSHA256
  }
}

public struct NotesLockedSessionCloseDraft: Codable, Equatable, Sendable {
  public var account: String?

  public init(account: String? = nil) {
    self.account = account
  }
}

public struct NotesLockedSessionCloseWriteResult: Equatable, Sendable {
  public var accountSelectorSHA256: String?
  public var accountSHA256: String?
  public var scope: String
  public var beforeAuthenticated: Bool
  public var beforeHasAuthenticatedObject: Bool
  public var afterAuthenticated: Bool
  public var afterHasAuthenticatedObject: Bool
  public var backendCalls: String

  public var changed: Bool {
    beforeAuthenticated != afterAuthenticated
      || beforeHasAuthenticatedObject != afterHasAuthenticatedObject
  }

  public init(
    accountSelectorSHA256: String? = nil,
    accountSHA256: String? = nil,
    scope: String,
    beforeAuthenticated: Bool,
    beforeHasAuthenticatedObject: Bool,
    afterAuthenticated: Bool,
    afterHasAuthenticatedObject: Bool,
    backendCalls: String
  ) {
    self.accountSelectorSHA256 = accountSelectorSHA256
    self.accountSHA256 = accountSHA256
    self.scope = scope
    self.beforeAuthenticated = beforeAuthenticated
    self.beforeHasAuthenticatedObject = beforeHasAuthenticatedObject
    self.afterAuthenticated = afterAuthenticated
    self.afterHasAuthenticatedObject = afterHasAuthenticatedObject
    self.backendCalls = backendCalls
  }
}

public struct NotesLockedSessionCloseResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var accountSelectorSHA256: String?
  public var accountSHA256: String?
  public var scope: String
  public var beforeAuthenticated: Bool
  public var beforeHasAuthenticatedObject: Bool
  public var afterAuthenticated: Bool
  public var afterHasAuthenticatedObject: Bool
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    accountSelectorSHA256: String? = nil,
    accountSHA256: String? = nil,
    scope: String,
    beforeAuthenticated: Bool,
    beforeHasAuthenticatedObject: Bool,
    afterAuthenticated: Bool,
    afterHasAuthenticatedObject: Bool,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.accountSelectorSHA256 = accountSelectorSHA256
    self.accountSHA256 = accountSHA256
    self.scope = scope
    self.beforeAuthenticated = beforeAuthenticated
    self.beforeHasAuthenticatedObject = beforeHasAuthenticatedObject
    self.afterAuthenticated = afterAuthenticated
    self.afterHasAuthenticatedObject = afterHasAuthenticatedObject
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesNoteLockMutationDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var action: String

  public init(noteID: String, action: String) {
    self.noteID = noteID
    self.action = action
  }
}

public struct NotesNoteLockMutationWriteResult: Equatable, Sendable {
  public var noteID: String
  public var action: String
  public var beforePasswordProtected: Bool
  public var beforePasswordProtectedAndLocked: Bool?
  public var beforeLockable: Bool?
  public var afterPasswordProtected: Bool
  public var afterPasswordProtectedAndLocked: Bool?
  public var afterLockable: Bool?
  public var backendCalls: String

  public var changed: Bool {
    beforePasswordProtected != afterPasswordProtected
      || beforePasswordProtectedAndLocked != afterPasswordProtectedAndLocked
  }

  public init(
    noteID: String,
    action: String,
    beforePasswordProtected: Bool,
    beforePasswordProtectedAndLocked: Bool? = nil,
    beforeLockable: Bool? = nil,
    afterPasswordProtected: Bool,
    afterPasswordProtectedAndLocked: Bool? = nil,
    afterLockable: Bool? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.action = action
    self.beforePasswordProtected = beforePasswordProtected
    self.beforePasswordProtectedAndLocked = beforePasswordProtectedAndLocked
    self.beforeLockable = beforeLockable
    self.afterPasswordProtected = afterPasswordProtected
    self.afterPasswordProtectedAndLocked = afterPasswordProtectedAndLocked
    self.afterLockable = afterLockable
    self.backendCalls = backendCalls
  }
}

public struct NotesNoteLockMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var action: String
  public var beforePasswordProtected: Bool
  public var beforePasswordProtectedAndLocked: Bool?
  public var beforeLockable: Bool?
  public var afterPasswordProtected: Bool
  public var afterPasswordProtectedAndLocked: Bool?
  public var afterLockable: Bool?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    action: String,
    beforePasswordProtected: Bool,
    beforePasswordProtectedAndLocked: Bool? = nil,
    beforeLockable: Bool? = nil,
    afterPasswordProtected: Bool,
    afterPasswordProtectedAndLocked: Bool? = nil,
    afterLockable: Bool? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.action = action
    self.beforePasswordProtected = beforePasswordProtected
    self.beforePasswordProtectedAndLocked = beforePasswordProtectedAndLocked
    self.beforeLockable = beforeLockable
    self.afterPasswordProtected = afterPasswordProtected
    self.afterPasswordProtectedAndLocked = afterPasswordProtectedAndLocked
    self.afterLockable = afterLockable
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesNoteUnlockDraft: Equatable, Sendable {
  public var noteID: String
  public var passphrase: String
  public var passphraseSourceKind: String

  public init(noteID: String, passphrase: String, passphraseSourceKind: String) {
    self.noteID = noteID
    self.passphrase = passphrase
    self.passphraseSourceKind = passphraseSourceKind
  }
}

public struct NotesNoteUnlockWriteResult: Equatable, Sendable {
  public var noteID: String
  public var passphraseSourceKind: String
  public var beforePasswordProtected: Bool
  public var beforePasswordProtectedAndLocked: Bool?
  public var beforeAuthenticated: Bool?
  public var beforeHasAuthenticatedObject: Bool?
  public var afterPasswordProtected: Bool
  public var afterPasswordProtectedAndLocked: Bool?
  public var afterAuthenticated: Bool?
  public var afterHasAuthenticatedObject: Bool?
  public var backendCalls: String

  public var changed: Bool {
    beforePasswordProtectedAndLocked != afterPasswordProtectedAndLocked
      || beforeAuthenticated != afterAuthenticated
      || beforeHasAuthenticatedObject != afterHasAuthenticatedObject
  }

  public init(
    noteID: String,
    passphraseSourceKind: String,
    beforePasswordProtected: Bool,
    beforePasswordProtectedAndLocked: Bool? = nil,
    beforeAuthenticated: Bool? = nil,
    beforeHasAuthenticatedObject: Bool? = nil,
    afterPasswordProtected: Bool,
    afterPasswordProtectedAndLocked: Bool? = nil,
    afterAuthenticated: Bool? = nil,
    afterHasAuthenticatedObject: Bool? = nil,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.passphraseSourceKind = passphraseSourceKind
    self.beforePasswordProtected = beforePasswordProtected
    self.beforePasswordProtectedAndLocked = beforePasswordProtectedAndLocked
    self.beforeAuthenticated = beforeAuthenticated
    self.beforeHasAuthenticatedObject = beforeHasAuthenticatedObject
    self.afterPasswordProtected = afterPasswordProtected
    self.afterPasswordProtectedAndLocked = afterPasswordProtectedAndLocked
    self.afterAuthenticated = afterAuthenticated
    self.afterHasAuthenticatedObject = afterHasAuthenticatedObject
    self.backendCalls = backendCalls
  }
}

public struct NotesNoteUnlockResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var passphraseSourceKind: String
  public var beforePasswordProtected: Bool
  public var beforePasswordProtectedAndLocked: Bool?
  public var beforeAuthenticated: Bool?
  public var beforeHasAuthenticatedObject: Bool?
  public var afterPasswordProtected: Bool
  public var afterPasswordProtectedAndLocked: Bool?
  public var afterAuthenticated: Bool?
  public var afterHasAuthenticatedObject: Bool?
  public var backendCalls: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    passphraseSourceKind: String,
    beforePasswordProtected: Bool,
    beforePasswordProtectedAndLocked: Bool? = nil,
    beforeAuthenticated: Bool? = nil,
    beforeHasAuthenticatedObject: Bool? = nil,
    afterPasswordProtected: Bool,
    afterPasswordProtectedAndLocked: Bool? = nil,
    afterAuthenticated: Bool? = nil,
    afterHasAuthenticatedObject: Bool? = nil,
    backendCalls: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.passphraseSourceKind = passphraseSourceKind
    self.beforePasswordProtected = beforePasswordProtected
    self.beforePasswordProtectedAndLocked = beforePasswordProtectedAndLocked
    self.beforeAuthenticated = beforeAuthenticated
    self.beforeHasAuthenticatedObject = beforeHasAuthenticatedObject
    self.afterPasswordProtected = afterPasswordProtected
    self.afterPasswordProtectedAndLocked = afterPasswordProtectedAndLocked
    self.afterAuthenticated = afterAuthenticated
    self.afterHasAuthenticatedObject = afterHasAuthenticatedObject
    self.backendCalls = backendCalls
    self.verification = verification
  }
}

public struct NotesLockedContentExportDraft: Equatable, Sendable {
  public var noteID: String
  public var passphrase: String?
  public var passphraseSourceKind: String?

  public init(noteID: String, passphrase: String? = nil, passphraseSourceKind: String? = nil) {
    self.noteID = noteID
    self.passphrase = passphrase
    self.passphraseSourceKind = passphraseSourceKind
  }
}

public struct NotesLockedContentExportSource: Equatable, Sendable {
  public var noteID: String
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var authenticatedDuringExport: Bool
  public var passphraseSourceKind: String?
  public var content: String
  public var backendCalls: String

  public var data: Data {
    Data(content.utf8)
  }

  public init(
    noteID: String,
    isPasswordProtected: Bool,
    isPasswordProtectedAndLocked: Bool?,
    authenticatedDuringExport: Bool = false,
    passphraseSourceKind: String? = nil,
    content: String,
    backendCalls: String
  ) {
    self.noteID = noteID
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.authenticatedDuringExport = authenticatedDuringExport
    self.passphraseSourceKind = passphraseSourceKind
    self.content = content
    self.backendCalls = backendCalls
  }
}

public struct NotesLockedContentArtifactRecord: Codable, Equatable, Sendable {
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String
  public var contentKind: String

  public init(destinationPath: String, byteCount: Int, sha256: String, contentKind: String) {
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
    self.contentKind = contentKind
  }
}

public struct NotesLockedContentExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var passphraseSourceKind: String?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var authenticatedDuringExport: Bool
  public var contentByteCount: Int
  public var contentSHA256: String
  public var backendCalls: String
  public var artifact: NotesLockedContentArtifactRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    passphraseSourceKind: String? = nil,
    isPasswordProtected: Bool,
    isPasswordProtectedAndLocked: Bool?,
    authenticatedDuringExport: Bool = false,
    contentByteCount: Int,
    contentSHA256: String,
    backendCalls: String,
    artifact: NotesLockedContentArtifactRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.passphraseSourceKind = passphraseSourceKind
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.authenticatedDuringExport = authenticatedDuringExport
    self.contentByteCount = contentByteCount
    self.contentSHA256 = contentSHA256
    self.backendCalls = backendCalls
    self.artifact = artifact
    self.verification = verification
  }
}

public struct NotesBodyParagraphAnchorRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var idSHA256: String
  public var titleByteCount: Int?
  public var titleSHA256: String?
  public var style: String
  public var listStyle: String?
  public var alignment: String?
  public var isHeader: Bool
  public var isList: Bool
  public var isChecklist: Bool
  public var isBlockQuote: Bool
  public var indentationLevel: Int?
  public var canIndent: Bool?
  public var checklistDone: Bool?

  public init(
    ordinal: Int,
    idSHA256: String,
    titleByteCount: Int? = nil,
    titleSHA256: String? = nil,
    style: String,
    listStyle: String? = nil,
    alignment: String? = nil,
    isHeader: Bool = false,
    isList: Bool = false,
    isChecklist: Bool = false,
    isBlockQuote: Bool = false,
    indentationLevel: Int? = nil,
    canIndent: Bool? = nil,
    checklistDone: Bool? = nil
  ) {
    self.ordinal = ordinal
    self.idSHA256 = idSHA256
    self.titleByteCount = titleByteCount
    self.titleSHA256 = titleSHA256
    self.style = style
    self.listStyle = listStyle
    self.alignment = alignment
    self.isHeader = isHeader
    self.isList = isList
    self.isChecklist = isChecklist
    self.isBlockQuote = isBlockQuote
    self.indentationLevel = indentationLevel
    self.canIndent = canIndent
    self.checklistDone = checklistDone
  }
}

public enum NotesBodyParagraphStyle: String, Codable, Equatable, CaseIterable, Sendable {
  case title
  case heading
  case subheading
  case body
  case monostyled

  public var isHeader: Bool {
    switch self {
    case .title, .heading, .subheading:
      return true
    case .body, .monostyled:
      return false
    }
  }

  public var createsCollapsibleSection: Bool {
    switch self {
    case .heading, .subheading:
      return true
    case .title, .body, .monostyled:
      return false
    }
  }

  public var isDefaultNewNoteStyle: Bool {
    switch self {
    case .title, .heading, .subheading, .body:
      return true
    case .monostyled:
      return false
    }
  }

  public static var allowedDescription: String {
    allCases.map(\.rawValue).joined(separator: ",")
  }

  public static var defaultNewNoteAllowedDescription: String {
    allCases.filter(\.isDefaultNewNoteStyle).map(\.rawValue).joined(separator: ",")
  }
}

public enum NotesBodyParagraphAlignment: String, Codable, Equatable, CaseIterable, Sendable {
  case left
  case center
  case right
  case justified
  case natural

  public var textAlignmentRawValue: Int {
    switch self {
    case .left: 0
    case .right: 1
    case .center: 2
    case .justified: 3
    case .natural: 4
    }
  }

  public static var allowedDescription: String {
    allCases.map(\.rawValue).joined(separator: ",")
  }

  public static func alignmentName(forTextAlignmentRawValue value: Int) -> String? {
    allCases.first { $0.textAlignmentRawValue == value }?.rawValue
  }
}

public enum NotesBodyInlineFormat: String, Codable, Equatable, CaseIterable, Sendable {
  case bold
  case italic
  case underline
  case strikethrough

  public static var allowedDescription: String {
    allCases.map(\.rawValue).joined(separator: ",")
  }
}

public struct NotesParagraphAnchorResolution: Equatable, Sendable {
  public var anchor: NotesBodyParagraphAnchorRecord
  public var paragraphID: String
  public var title: String?

  public init(anchor: NotesBodyParagraphAnchorRecord, paragraphID: String, title: String? = nil) {
    self.anchor = anchor
    self.paragraphID = paragraphID
    self.title = title
  }
}

public struct NotesBodyTableRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var idSHA256: String
  public var attachmentIDSHA256: String?
  public var contentIdentifierSHA256: String?
  public var typeUTISHA256: String?
  public var rowCount: Int?
  public var columnCount: Int?
  public var isDeletable: Bool?

  public init(
    ordinal: Int,
    idSHA256: String,
    attachmentIDSHA256: String? = nil,
    contentIdentifierSHA256: String? = nil,
    typeUTISHA256: String? = nil,
    rowCount: Int? = nil,
    columnCount: Int? = nil,
    isDeletable: Bool? = nil
  ) {
    self.ordinal = ordinal
    self.idSHA256 = idSHA256
    self.attachmentIDSHA256 = attachmentIDSHA256
    self.contentIdentifierSHA256 = contentIdentifierSHA256
    self.typeUTISHA256 = typeUTISHA256
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.isDeletable = isDeletable
  }
}

public struct NotesBodyTableCellRecord: Codable, Equatable, Sendable {
  public var tableOrdinal: Int
  public var tableIDSHA256: String
  public var row: Int
  public var column: Int
  public var textByteCount: Int
  public var textSHA256: String
  public var formatRunCount: Int?
  public var formatSHA256: String?
  public var containsBold: Bool?
  public var containsItalic: Bool?
  public var containsUnderline: Bool?
  public var containsStrikethrough: Bool?

  public init(
    tableOrdinal: Int,
    tableIDSHA256: String,
    row: Int,
    column: Int,
    textByteCount: Int,
    textSHA256: String,
    formatRunCount: Int? = nil,
    formatSHA256: String? = nil,
    containsBold: Bool? = nil,
    containsItalic: Bool? = nil,
    containsUnderline: Bool? = nil,
    containsStrikethrough: Bool? = nil
  ) {
    self.tableOrdinal = tableOrdinal
    self.tableIDSHA256 = tableIDSHA256
    self.row = row
    self.column = column
    self.textByteCount = textByteCount
    self.textSHA256 = textSHA256
    self.formatRunCount = formatRunCount
    self.formatSHA256 = formatSHA256
    self.containsBold = containsBold
    self.containsItalic = containsItalic
    self.containsUnderline = containsUnderline
    self.containsStrikethrough = containsStrikethrough
  }
}

public struct NotesBodyTablesResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var tables: [NotesBodyTableRecord]
  public var structure: NotesBodyStructureRecord
  public var verification: NotesMutationVerificationReport

  public init(
    noteID: String,
    tables: [NotesBodyTableRecord],
    structure: NotesBodyStructureRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.noteID = noteID
    self.tables = tables
    self.structure = structure
    self.verification = verification
  }
}

public struct NotesBodyMathResultRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var idSHA256: String
  public var attachmentIDSHA256: String?
  public var contentIdentifierSHA256: String?
  public var typeUTISHA256: String?
  public var resultByteCount: Int?
  public var resultSHA256: String?
  public var expressionByteCount: Int?
  public var expressionSHA256: String?
  public var isValid: Bool?
  public var isRightToLeft: Bool?

  public init(
    ordinal: Int,
    idSHA256: String,
    attachmentIDSHA256: String? = nil,
    contentIdentifierSHA256: String? = nil,
    typeUTISHA256: String? = nil,
    resultByteCount: Int? = nil,
    resultSHA256: String? = nil,
    expressionByteCount: Int? = nil,
    expressionSHA256: String? = nil,
    isValid: Bool? = nil,
    isRightToLeft: Bool? = nil
  ) {
    self.ordinal = ordinal
    self.idSHA256 = idSHA256
    self.attachmentIDSHA256 = attachmentIDSHA256
    self.contentIdentifierSHA256 = contentIdentifierSHA256
    self.typeUTISHA256 = typeUTISHA256
    self.resultByteCount = resultByteCount
    self.resultSHA256 = resultSHA256
    self.expressionByteCount = expressionByteCount
    self.expressionSHA256 = expressionSHA256
    self.isValid = isValid
    self.isRightToLeft = isRightToLeft
  }
}

public struct NotesBodyMathResultsResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var results: [NotesBodyMathResultRecord]
  public var structure: NotesBodyStructureRecord
  public var verification: NotesMutationVerificationReport

  public init(
    noteID: String,
    results: [NotesBodyMathResultRecord],
    structure: NotesBodyStructureRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.noteID = noteID
    self.results = results
    self.structure = structure
    self.verification = verification
  }
}

public struct NotesBodyMathResultsPreferenceRecord: Codable, Equatable, Sendable {
  public var mode: String
  public var rawValue: Int
  public var valueSHA256: String
  public var userDefaultsKeySHA256: String?
  public var sourceKind: String

  public init(
    mode: String,
    rawValue: Int,
    valueSHA256: String,
    userDefaultsKeySHA256: String? = nil,
    sourceKind: String
  ) {
    self.mode = mode
    self.rawValue = rawValue
    self.valueSHA256 = valueSHA256
    self.userDefaultsKeySHA256 = userDefaultsKeySHA256
    self.sourceKind = sourceKind
  }
}

public struct NotesBodyMathExpressionScanDraft: Codable, Equatable, Sendable {
  public var expression: String
  public var expressionByteCount: Int
  public var expressionSHA256: String
  public var expressionUTF16Length: Int

  public init(expression: String) {
    self.expression = expression
    self.expressionByteCount = expression.utf8.count
    self.expressionSHA256 = sha256Hex(expression)
    self.expressionUTF16Length = (expression as NSString).length
  }
}

public struct NotesBodyMathExpressionScanRecord: Codable, Equatable, Sendable {
  public var expressionByteCount: Int
  public var expressionSHA256: String
  public var expressionUTF16Length: Int
  public var scanRangeLocation: Int
  public var scanRangeLength: Int
  public var recognized: Bool
  public var scanObjectCount: Int?
  public var scanObjectTypeSHA256: String?
  public var sourceKind: String
  public var backendCalls: [String]
  public var privacyBoundary: String

  public init(
    expressionByteCount: Int,
    expressionSHA256: String,
    expressionUTF16Length: Int,
    scanRangeLocation: Int,
    scanRangeLength: Int,
    recognized: Bool,
    scanObjectCount: Int? = nil,
    scanObjectTypeSHA256: String? = nil,
    sourceKind: String,
    backendCalls: [String],
    privacyBoundary: String = "hashes_counts_and_type_hashes_only"
  ) {
    self.expressionByteCount = expressionByteCount
    self.expressionSHA256 = expressionSHA256
    self.expressionUTF16Length = expressionUTF16Length
    self.scanRangeLocation = scanRangeLocation
    self.scanRangeLength = scanRangeLength
    self.recognized = recognized
    self.scanObjectCount = scanObjectCount
    self.scanObjectTypeSHA256 = scanObjectTypeSHA256
    self.sourceKind = sourceKind
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
  }
}

public struct NotesBodyMathExpressionScanResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var scan: NotesBodyMathExpressionScanRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    scan: NotesBodyMathExpressionScanRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.scan = scan
    self.verification = verification
  }
}

public struct NotesMathWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesMathWorkflowAuditSummary
  public var records: [NotesMathWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesMathWorkflowAuditSummary,
    records: [NotesMathWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesMathWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesMathWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesBodyInlineFormatDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var text: String
  public var occurrence: Int?
  public var format: NotesBodyInlineFormat
  public var enabled: Bool

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    text: String,
    occurrence: Int? = nil,
    format: NotesBodyInlineFormat,
    enabled: Bool
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.text = text
    self.occurrence = occurrence
    self.format = format
    self.enabled = enabled
  }
}

public struct NotesBodyInlineColorDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var text: String
  public var occurrence: Int?
  public var color: String?

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    text: String,
    occurrence: Int? = nil,
    color: String? = nil
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.text = text
    self.occurrence = occurrence
    self.color = color
  }
}

public struct NotesBodyInlineFontDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var text: String
  public var occurrence: Int?
  public var family: String
  public var pointSize: Double

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    text: String,
    occurrence: Int? = nil,
    family: String,
    pointSize: Double
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.text = text
    self.occurrence = occurrence
    self.family = family
    self.pointSize = pointSize
  }
}

public struct NotesBodyInlineMutationEvidence: Equatable, Sendable {
  public var paragraphIDSHA256: String?
  public var textByteCount: Int
  public var textSHA256: String
  public var occurrence: Int
  public var role: String
  public var colorSHA256: String?
  public var fontSHA256: String?

  public init(
    paragraphIDSHA256: String? = nil,
    textByteCount: Int,
    textSHA256: String,
    occurrence: Int,
    role: String,
    colorSHA256: String? = nil,
    fontSHA256: String? = nil
  ) {
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.textByteCount = textByteCount
    self.textSHA256 = textSHA256
    self.occurrence = occurrence
    self.role = role
    self.colorSHA256 = colorSHA256
    self.fontSHA256 = fontSHA256
  }
}

public struct NotesBodyInlineFormatWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var evidence: NotesBodyInlineMutationEvidence

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    evidence: NotesBodyInlineMutationEvidence
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.evidence = evidence
  }
}

public typealias NotesBodyInlineColorWriteResult = NotesBodyInlineFormatWriteResult

public enum NotesBodyListStyle: String, Codable, Equatable, CaseIterable, Sendable {
  case bulleted
  case dashed
  case numbered

  public var paragraphStyleValue: UInt32 {
    switch self {
    case .bulleted: 100
    case .dashed: 101
    case .numbered: 102
    }
  }

  public static var allowedDescription: String {
    allCases.map(\.rawValue).joined(separator: ",")
  }

  public static func styleName(for paragraphStyleValue: Int) -> String? {
    allCases.first { Int($0.paragraphStyleValue) == paragraphStyleValue }?.rawValue
  }
}

public struct NotesNoteStateRecord: Codable, Equatable, Sendable {
  public var noteID: String
  public var isDeletedOrInTrash: Bool
  public var isPinned: Bool
  public var isPinnable: Bool?
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var isEditable: Bool
  public var isLockable: Bool
  public var isSharedViaICloud: Bool
  public var isSharedViaICloudFolder: Bool
  public var isSharedReadOnly: Bool
  public var isSystemPaper: Bool
  public var isMathNote: Bool
  public var isCallNote: Bool
  public var hasUnreadChanges: Bool?
  public var isUnsupported: Bool?
  public var needsCloudFetch: Bool?
  public var sharedNoteAlertsHidden: Bool?
  public var participantCount: Int?
  public var participantUserIDSHA256s: [String]
  public var accountCanPasswordProtectNotes: Bool?
  public var accountCanHaveCryptoStrategy: Bool?
  public var accountIsInICloud: Bool?
  public var accountIsLocal: Bool?
  public var accountLockedNotesModeSHA256: String?
  public var accountResolvedLockedNotesModeSHA256: String?
  public var accountPasswordProtectedNoteCount: Int?
  public var folderID: String?
  public var folderIsTrash: Bool?
  public var folderIsDefault: Bool?
  public var folderIsSharedViaICloud: Bool?
  public var folderIsSharedReadOnly: Bool?

  public init(
    noteID: String,
    isDeletedOrInTrash: Bool,
    isPinned: Bool,
    isPinnable: Bool? = nil,
    isPasswordProtected: Bool,
    isPasswordProtectedAndLocked: Bool? = nil,
    isEditable: Bool,
    isLockable: Bool,
    isSharedViaICloud: Bool,
    isSharedViaICloudFolder: Bool,
    isSharedReadOnly: Bool,
    isSystemPaper: Bool,
    isMathNote: Bool,
    isCallNote: Bool,
    hasUnreadChanges: Bool? = nil,
    isUnsupported: Bool? = nil,
    needsCloudFetch: Bool? = nil,
    sharedNoteAlertsHidden: Bool? = nil,
    participantCount: Int? = nil,
    participantUserIDSHA256s: [String] = [],
    accountCanPasswordProtectNotes: Bool? = nil,
    accountCanHaveCryptoStrategy: Bool? = nil,
    accountIsInICloud: Bool? = nil,
    accountIsLocal: Bool? = nil,
    accountLockedNotesModeSHA256: String? = nil,
    accountResolvedLockedNotesModeSHA256: String? = nil,
    accountPasswordProtectedNoteCount: Int? = nil,
    folderID: String? = nil,
    folderIsTrash: Bool? = nil,
    folderIsDefault: Bool? = nil,
    folderIsSharedViaICloud: Bool? = nil,
    folderIsSharedReadOnly: Bool? = nil
  ) {
    self.noteID = noteID
    self.isDeletedOrInTrash = isDeletedOrInTrash
    self.isPinned = isPinned
    self.isPinnable = isPinnable
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.isEditable = isEditable
    self.isLockable = isLockable
    self.isSharedViaICloud = isSharedViaICloud
    self.isSharedViaICloudFolder = isSharedViaICloudFolder
    self.isSharedReadOnly = isSharedReadOnly
    self.isSystemPaper = isSystemPaper
    self.isMathNote = isMathNote
    self.isCallNote = isCallNote
    self.hasUnreadChanges = hasUnreadChanges
    self.isUnsupported = isUnsupported
    self.needsCloudFetch = needsCloudFetch
    self.sharedNoteAlertsHidden = sharedNoteAlertsHidden
    self.participantCount = participantCount
    self.participantUserIDSHA256s = participantUserIDSHA256s
    self.accountCanPasswordProtectNotes = accountCanPasswordProtectNotes
    self.accountCanHaveCryptoStrategy = accountCanHaveCryptoStrategy
    self.accountIsInICloud = accountIsInICloud
    self.accountIsLocal = accountIsLocal
    self.accountLockedNotesModeSHA256 = accountLockedNotesModeSHA256
    self.accountResolvedLockedNotesModeSHA256 = accountResolvedLockedNotesModeSHA256
    self.accountPasswordProtectedNoteCount = accountPasswordProtectedNoteCount
    self.folderID = folderID
    self.folderIsTrash = folderIsTrash
    self.folderIsDefault = folderIsDefault
    self.folderIsSharedViaICloud = folderIsSharedViaICloud
    self.folderIsSharedReadOnly = folderIsSharedReadOnly
  }
}

public struct NotesBodyStructureRecord: Codable, Equatable, Sendable {
  public var noteID: String
  public var isPasswordProtected: Bool
  public var plainTextByteCount: Int?
  public var plainTextSHA256: String?
  public var richTextLength: Int?
  public var paragraphCount: Int?
  public var paragraphStyleRunCount: Int
  public var headingCount: Int
  public var listItemCount: Int
  public var checklistItemCount: Int
  public var checklistDoneCount: Int
  public var checklistOpenCount: Int
  public var blockQuoteCount: Int
  public var tableCount: Int
  public var collapsibleSectionCount: Int
  public var collapsedSectionCount: Int
  public var inlineAttachmentCount: Int
  public var linkCount: Int
  public var attachmentCount: Int
  public var mathAttachmentCount: Int
  public var inlineFormatRunCount: Int
  public var boldRunCount: Int
  public var italicRunCount: Int
  public var underlineRunCount: Int
  public var strikethroughRunCount: Int
  public var fontRunCount: Int
  public var foregroundColorRunCount: Int
  public var highlightRunCount: Int
  public var hasChecklist: Bool
  public var hasChecklistInProgress: Bool
  public var isMathNote: Bool
  public var styleCounts: [NotesBodyStyleCount]
  public var attachmentKindCounts: [NotesBodyAttachmentKindCount]
  public var inlineFormatCounts: [NotesBodyInlineFormatCount]
  public var colorHashCounts: [NotesBodyColorHashCount]
  public var inlineFormatRuns: [NotesBodyInlineFormatRunRecord]
  public var colorRuns: [NotesBodyInlineColorRunRecord]
  public var mentionUserIDSHA256s: [String]
  public var paragraphAnchors: [NotesBodyParagraphAnchorRecord]

  public init(
    noteID: String,
    isPasswordProtected: Bool,
    plainTextByteCount: Int? = nil,
    plainTextSHA256: String? = nil,
    richTextLength: Int? = nil,
    paragraphCount: Int? = nil,
    paragraphStyleRunCount: Int = 0,
    headingCount: Int = 0,
    listItemCount: Int = 0,
    checklistItemCount: Int = 0,
    checklistDoneCount: Int = 0,
    checklistOpenCount: Int = 0,
    blockQuoteCount: Int = 0,
    tableCount: Int = 0,
    collapsibleSectionCount: Int = 0,
    collapsedSectionCount: Int = 0,
    inlineAttachmentCount: Int = 0,
    linkCount: Int = 0,
    attachmentCount: Int = 0,
    mathAttachmentCount: Int = 0,
    inlineFormatRunCount: Int = 0,
    boldRunCount: Int = 0,
    italicRunCount: Int = 0,
    underlineRunCount: Int = 0,
    strikethroughRunCount: Int = 0,
    fontRunCount: Int = 0,
    foregroundColorRunCount: Int = 0,
    highlightRunCount: Int = 0,
    hasChecklist: Bool = false,
    hasChecklistInProgress: Bool = false,
    isMathNote: Bool = false,
    styleCounts: [NotesBodyStyleCount] = [],
    attachmentKindCounts: [NotesBodyAttachmentKindCount] = [],
    inlineFormatCounts: [NotesBodyInlineFormatCount] = [],
    colorHashCounts: [NotesBodyColorHashCount] = [],
    inlineFormatRuns: [NotesBodyInlineFormatRunRecord] = [],
    colorRuns: [NotesBodyInlineColorRunRecord] = [],
    mentionUserIDSHA256s: [String] = [],
    paragraphAnchors: [NotesBodyParagraphAnchorRecord] = []
  ) {
    self.noteID = noteID
    self.isPasswordProtected = isPasswordProtected
    self.plainTextByteCount = plainTextByteCount
    self.plainTextSHA256 = plainTextSHA256
    self.richTextLength = richTextLength
    self.paragraphCount = paragraphCount
    self.paragraphStyleRunCount = paragraphStyleRunCount
    self.headingCount = headingCount
    self.listItemCount = listItemCount
    self.checklistItemCount = checklistItemCount
    self.checklistDoneCount = checklistDoneCount
    self.checklistOpenCount = checklistOpenCount
    self.blockQuoteCount = blockQuoteCount
    self.tableCount = tableCount
    self.collapsibleSectionCount = collapsibleSectionCount
    self.collapsedSectionCount = collapsedSectionCount
    self.inlineAttachmentCount = inlineAttachmentCount
    self.linkCount = linkCount
    self.attachmentCount = attachmentCount
    self.mathAttachmentCount = mathAttachmentCount
    self.inlineFormatRunCount = inlineFormatRunCount
    self.boldRunCount = boldRunCount
    self.italicRunCount = italicRunCount
    self.underlineRunCount = underlineRunCount
    self.strikethroughRunCount = strikethroughRunCount
    self.fontRunCount = fontRunCount
    self.foregroundColorRunCount = foregroundColorRunCount
    self.highlightRunCount = highlightRunCount
    self.hasChecklist = hasChecklist
    self.hasChecklistInProgress = hasChecklistInProgress
    self.isMathNote = isMathNote
    self.styleCounts = styleCounts
    self.attachmentKindCounts = attachmentKindCounts
    self.inlineFormatCounts = inlineFormatCounts
    self.colorHashCounts = colorHashCounts
    self.inlineFormatRuns = inlineFormatRuns
    self.colorRuns = colorRuns
    self.mentionUserIDSHA256s = mentionUserIDSHA256s
    self.paragraphAnchors = paragraphAnchors
  }
}

public struct NotesAccountsResponse: Codable, Equatable, Sendable {
  public var accounts: [NotesAccountRecord]
}

public struct NotesFolderCompletenessWarning: Codable, Equatable, Sendable {
  public var folderID: String
  public var expectedChildFolderCount: Int
  public var returnedChildFolderCount: Int

  public init(
    folderID: String,
    expectedChildFolderCount: Int,
    returnedChildFolderCount: Int
  ) {
    self.folderID = folderID
    self.expectedChildFolderCount = expectedChildFolderCount
    self.returnedChildFolderCount = returnedChildFolderCount
  }
}

public struct NotesFoldersResponse: Codable, Equatable, Sendable {
  public var folders: [NotesFolderRecord]
  public var returnedFolderCount: Int
  public var incompleteFolderCount: Int
  public var incompleteFolders: [NotesFolderCompletenessWarning]

  public init(
    folders: [NotesFolderRecord],
    incompleteFolders: [NotesFolderCompletenessWarning] = []
  ) {
    self.folders = folders
    self.returnedFolderCount = folders.count
    self.incompleteFolderCount = incompleteFolders.count
    self.incompleteFolders = incompleteFolders
  }
}

public struct NotesListResponse: Codable, Equatable, Sendable {
  public var notes: [NotesNoteSummary]
}

public struct NotesNaturalLanguageSearchEvidence: Codable, Equatable, Sendable {
  public var notes: [NotesNoteSummary]
  public var querySHA256: String
  public var queryByteCount: Int
  public var rawResultCount: Int
  public var mappedNoteCount: Int
  public var skippedResultCount: Int
  public var limit: Int
  public var privateNLQueryClassName: String?
  public var privateNLQueryPresent: Bool
  public var sourceKind: String

  public init(
    notes: [NotesNoteSummary],
    querySHA256: String,
    queryByteCount: Int,
    rawResultCount: Int,
    mappedNoteCount: Int,
    skippedResultCount: Int,
    limit: Int,
    privateNLQueryClassName: String?,
    privateNLQueryPresent: Bool,
    sourceKind: String
  ) {
    self.notes = notes
    self.querySHA256 = querySHA256
    self.queryByteCount = queryByteCount
    self.rawResultCount = rawResultCount
    self.mappedNoteCount = mappedNoteCount
    self.skippedResultCount = skippedResultCount
    self.limit = limit
    self.privateNLQueryClassName = privateNLQueryClassName
    self.privateNLQueryPresent = privateNLQueryPresent
    self.sourceKind = sourceKind
  }
}

public struct NotesNaturalLanguageSearchResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var notes: [NotesNoteSummary]
  public var querySHA256: String
  public var queryByteCount: Int
  public var rawResultCount: Int
  public var mappedNoteCount: Int
  public var skippedResultCount: Int
  public var limit: Int
  public var privateNLQueryClassName: String?
  public var privateNLQueryPresent: Bool
  public var sourceKind: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    evidence: NotesNaturalLanguageSearchEvidence,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.notes = evidence.notes
    self.querySHA256 = evidence.querySHA256
    self.queryByteCount = evidence.queryByteCount
    self.rawResultCount = evidence.rawResultCount
    self.mappedNoteCount = evidence.mappedNoteCount
    self.skippedResultCount = evidence.skippedResultCount
    self.limit = evidence.limit
    self.privateNLQueryClassName = evidence.privateNLQueryClassName
    self.privateNLQueryPresent = evidence.privateNLQueryPresent
    self.sourceKind = evidence.sourceKind
    self.verification = verification
  }
}

public struct NotesReadResponse: Codable, Equatable, Sendable {
  public var note: NotesNoteDetail
}

public struct NotesTagsResponse: Codable, Equatable, Sendable {
  public var tags: [NotesTagRecord]
}

public enum NotesTagSearchMode: String, Codable, Equatable, CaseIterable, Sendable {
  case all
  case any

  public static var allowedDescription: String {
    allCases.map(\.rawValue).joined(separator: ",")
  }
}

public struct NotesTagSearchResponse: Codable, Equatable, Sendable {
  public var notes: [NotesNoteSummary]
  public var mode: NotesTagSearchMode
  public var includedTagCount: Int
  public var excludedTagCount: Int
  public var includedTagSHA256: [String]
  public var excludedTagSHA256: [String]
  public var scannedNoteCount: Int
  public var returnedNoteCount: Int
  public var limit: Int

  public init(
    notes: [NotesNoteSummary],
    mode: NotesTagSearchMode,
    includedTagCount: Int,
    excludedTagCount: Int,
    includedTagSHA256: [String],
    excludedTagSHA256: [String],
    scannedNoteCount: Int,
    returnedNoteCount: Int,
    limit: Int
  ) {
    self.notes = notes
    self.mode = mode
    self.includedTagCount = includedTagCount
    self.excludedTagCount = excludedTagCount
    self.includedTagSHA256 = includedTagSHA256
    self.excludedTagSHA256 = excludedTagSHA256
    self.scannedNoteCount = scannedNoteCount
    self.returnedNoteCount = returnedNoteCount
    self.limit = limit
  }
}

public struct NotesTagWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesTagWorkflowAuditSummary
  public var records: [NotesTagWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesTagWorkflowAuditSummary,
    records: [NotesTagWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesTagWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesTagWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesAttachmentsResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var attachments: [NotesAttachmentRecord]

  public init(noteID: String, attachments: [NotesAttachmentRecord]) {
    self.noteID = noteID
    self.attachments = attachments
  }
}

public struct NotesAttachmentCollectionResponse: Codable, Equatable, Sendable {
  public var account: String?
  public var folder: String?
  public var family: String?
  public var scannedNoteCount: Int
  public var notesWithAttachmentsCount: Int
  public var attachmentCount: Int
  public var familyCounts: [NotesAttachmentAuditCount]
  public var notes: [NotesAttachmentCollectionNoteRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    account: String?,
    folder: String?,
    family: String?,
    scannedNoteCount: Int,
    familyCounts: [NotesAttachmentAuditCount],
    notes: [NotesAttachmentCollectionNoteRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.account = account
    self.folder = folder
    self.family = family
    self.scannedNoteCount = scannedNoteCount
    self.notesWithAttachmentsCount = notes.count
    self.attachmentCount = notes.reduce(0) { $0 + $1.attachmentCount }
    self.familyCounts = familyCounts
    self.notes = notes
    self.verification = verification
  }
}

public struct NotesAttachmentCollectionNoteRecord: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var noteIDSHA256: String
  public var attachmentCount: Int
  public var attachments: [NotesAttachmentRecord]

  public init(
    note: NotesNoteSummary,
    noteIDSHA256: String,
    attachments: [NotesAttachmentRecord]
  ) {
    self.note = note
    self.noteIDSHA256 = noteIDSHA256
    self.attachmentCount = attachments.count
    self.attachments = attachments
  }
}

public struct NotesAttachmentSearchResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var querySHA256: String
  public var queryByteCount: Int
  public var account: String?
  public var folder: String?
  public var family: String?
  public var scannedNoteCount: Int
  public var scannedAttachmentCount: Int
  public var matchedAttachmentCount: Int
  public var searchedFields: [String]
  public var matches: [NotesAttachmentSearchMatch]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    querySHA256: String,
    queryByteCount: Int,
    account: String?,
    folder: String?,
    family: String?,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    searchedFields: [String],
    matches: [NotesAttachmentSearchMatch],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = false
    self.querySHA256 = querySHA256
    self.queryByteCount = queryByteCount
    self.account = account
    self.folder = folder
    self.family = family
    self.scannedNoteCount = scannedNoteCount
    self.scannedAttachmentCount = scannedAttachmentCount
    self.matchedAttachmentCount = matches.count
    self.searchedFields = searchedFields
    self.matches = matches
    self.verification = verification
  }
}

public struct NotesAttachmentSearchMatch: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var noteIDSHA256: String
  public var attachment: NotesAttachmentRecord
  public var family: String
  public var matchedFields: [String]
  public var matchCount: Int

  public init(
    note: NotesNoteSummary,
    noteIDSHA256: String,
    attachment: NotesAttachmentRecord,
    family: String,
    matchedFields: [String]
  ) {
    self.note = note
    self.noteIDSHA256 = noteIDSHA256
    self.attachment = attachment
    self.family = family
    self.matchedFields = matchedFields
    self.matchCount = matchedFields.count
  }
}

public struct NotesAttachmentPDFTextSearchResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var querySHA256: String
  public var queryByteCount: Int
  public var account: String?
  public var folder: String?
  public var scannedNoteCount: Int
  public var scannedAttachmentCount: Int
  public var scannedPDFAttachmentCount: Int
  public var skippedPDFAttachmentCount: Int
  public var matchedAttachmentCount: Int
  public var searchedContentKinds: [String]
  public var matches: [NotesAttachmentPDFTextSearchMatch]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    querySHA256: String,
    queryByteCount: Int,
    account: String?,
    folder: String?,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    scannedPDFAttachmentCount: Int,
    skippedPDFAttachmentCount: Int,
    searchedContentKinds: [String],
    matches: [NotesAttachmentPDFTextSearchMatch],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = false
    self.querySHA256 = querySHA256
    self.queryByteCount = queryByteCount
    self.account = account
    self.folder = folder
    self.scannedNoteCount = scannedNoteCount
    self.scannedAttachmentCount = scannedAttachmentCount
    self.scannedPDFAttachmentCount = scannedPDFAttachmentCount
    self.skippedPDFAttachmentCount = skippedPDFAttachmentCount
    self.matchedAttachmentCount = matches.count
    self.searchedContentKinds = searchedContentKinds
    self.matches = matches
    self.verification = verification
  }
}

public struct NotesAttachmentPDFTextSearchMatch: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var noteIDSHA256: String
  public var attachment: NotesAttachmentRecord
  public var family: String
  public var pdfSourceKind: String
  public var textSourceKind: String
  public var pageCount: Int
  public var pdfByteCount: Int
  public var pdfSHA256: String
  public var textByteCount: Int
  public var textSHA256: String
  public var matchCount: Int

  public init(
    note: NotesNoteSummary,
    noteIDSHA256: String,
    attachment: NotesAttachmentRecord,
    family: String,
    pdfSourceKind: String,
    textSourceKind: String,
    pageCount: Int,
    pdfByteCount: Int,
    pdfSHA256: String,
    textByteCount: Int,
    textSHA256: String,
    matchCount: Int
  ) {
    self.note = note
    self.noteIDSHA256 = noteIDSHA256
    self.attachment = attachment
    self.family = family
    self.pdfSourceKind = pdfSourceKind
    self.textSourceKind = textSourceKind
    self.pageCount = pageCount
    self.pdfByteCount = pdfByteCount
    self.pdfSHA256 = pdfSHA256
    self.textByteCount = textByteCount
    self.textSHA256 = textSHA256
    self.matchCount = matchCount
  }
}

public struct NotesAttachmentSearchableTextSearchResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var querySHA256: String
  public var queryByteCount: Int
  public var contentFamily: String
  public var account: String?
  public var folder: String?
  public var scannedNoteCount: Int
  public var scannedAttachmentCount: Int
  public var scannedCandidateAttachmentCount: Int
  public var skippedCandidateAttachmentCount: Int
  public var matchedAttachmentCount: Int
  public var searchedContentKinds: [String]
  public var matches: [NotesAttachmentSearchableTextSearchMatch]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    querySHA256: String,
    queryByteCount: Int,
    contentFamily: String,
    account: String?,
    folder: String?,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    scannedCandidateAttachmentCount: Int,
    skippedCandidateAttachmentCount: Int,
    searchedContentKinds: [String],
    matches: [NotesAttachmentSearchableTextSearchMatch],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = false
    self.querySHA256 = querySHA256
    self.queryByteCount = queryByteCount
    self.contentFamily = contentFamily
    self.account = account
    self.folder = folder
    self.scannedNoteCount = scannedNoteCount
    self.scannedAttachmentCount = scannedAttachmentCount
    self.scannedCandidateAttachmentCount = scannedCandidateAttachmentCount
    self.skippedCandidateAttachmentCount = skippedCandidateAttachmentCount
    self.matchedAttachmentCount = matches.count
    self.searchedContentKinds = searchedContentKinds
    self.matches = matches
    self.verification = verification
  }
}

public struct NotesAttachmentSearchableTextSearchMatch: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var noteIDSHA256: String
  public var attachment: NotesAttachmentRecord
  public var family: String
  public var contentMatches: [NotesAttachmentSearchableTextSearchContentMatch]
  public var matchCount: Int

  public init(
    note: NotesNoteSummary,
    noteIDSHA256: String,
    attachment: NotesAttachmentRecord,
    family: String,
    contentMatches: [NotesAttachmentSearchableTextSearchContentMatch]
  ) {
    self.note = note
    self.noteIDSHA256 = noteIDSHA256
    self.attachment = attachment
    self.family = family
    self.contentMatches = contentMatches
    self.matchCount = contentMatches.reduce(0) { $0 + $1.matchCount }
  }
}

public struct NotesAttachmentSearchableTextSearchContentMatch: Codable, Equatable, Sendable {
  public var kind: String
  public var sourceKind: String
  public var byteCount: Int
  public var sha256: String
  public var matchCount: Int

  public init(
    kind: String,
    sourceKind: String,
    byteCount: Int,
    sha256: String,
    matchCount: Int
  ) {
    self.kind = kind
    self.sourceKind = sourceKind
    self.byteCount = byteCount
    self.sha256 = sha256
    self.matchCount = matchCount
  }
}

public struct NotesAttachmentContentSearchResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var querySHA256: String
  public var queryByteCount: Int
  public var account: String?
  public var folder: String?
  public var family: String?
  public var scannedNoteCount: Int
  public var scannedAttachmentCount: Int
  public var searchedSlices: [String]
  public var componentSummaries: [NotesAttachmentContentSearchComponentSummary]
  public var matchedAttachmentCount: Int
  public var matches: [NotesAttachmentContentSearchMatch]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    querySHA256: String,
    queryByteCount: Int,
    account: String?,
    folder: String?,
    family: String?,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    searchedSlices: [String],
    componentSummaries: [NotesAttachmentContentSearchComponentSummary],
    matches: [NotesAttachmentContentSearchMatch],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = false
    self.querySHA256 = querySHA256
    self.queryByteCount = queryByteCount
    self.account = account
    self.folder = folder
    self.family = family
    self.scannedNoteCount = scannedNoteCount
    self.scannedAttachmentCount = scannedAttachmentCount
    self.searchedSlices = searchedSlices
    self.componentSummaries = componentSummaries
    self.matchedAttachmentCount = Set(matches.map(\.attachment.id)).count
    self.matches = matches
    self.verification = verification
  }
}

public struct NotesAttachmentContentSearchComponentSummary: Codable, Equatable, Sendable {
  public var slice: String
  public var sourceKind: String
  public var scannedAttachmentCount: Int
  public var skippedAttachmentCount: Int
  public var matchedAttachmentCount: Int
  public var searchedContentKinds: [String]

  public init(
    slice: String,
    sourceKind: String,
    scannedAttachmentCount: Int,
    skippedAttachmentCount: Int,
    matchedAttachmentCount: Int,
    searchedContentKinds: [String]
  ) {
    self.slice = slice
    self.sourceKind = sourceKind
    self.scannedAttachmentCount = scannedAttachmentCount
    self.skippedAttachmentCount = skippedAttachmentCount
    self.matchedAttachmentCount = matchedAttachmentCount
    self.searchedContentKinds = searchedContentKinds
  }
}

public struct NotesAttachmentContentSearchMatch: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var noteIDSHA256: String
  public var attachment: NotesAttachmentRecord
  public var family: String
  public var slice: String
  public var sourceKind: String
  public var artifactSourceKind: String?
  public var artifactByteCount: Int?
  public var artifactSHA256: String?
  public var pageCount: Int?
  public var matchedFields: [String]
  public var contentMatches: [NotesAttachmentContentSearchContentMatch]
  public var matchCount: Int

  public init(
    note: NotesNoteSummary,
    noteIDSHA256: String,
    attachment: NotesAttachmentRecord,
    family: String,
    slice: String,
    sourceKind: String,
    artifactSourceKind: String? = nil,
    artifactByteCount: Int? = nil,
    artifactSHA256: String? = nil,
    pageCount: Int? = nil,
    matchedFields: [String] = [],
    contentMatches: [NotesAttachmentContentSearchContentMatch] = []
  ) {
    self.note = note
    self.noteIDSHA256 = noteIDSHA256
    self.attachment = attachment
    self.family = family
    self.slice = slice
    self.sourceKind = sourceKind
    self.artifactSourceKind = artifactSourceKind
    self.artifactByteCount = artifactByteCount
    self.artifactSHA256 = artifactSHA256
    self.pageCount = pageCount
    self.matchedFields = matchedFields
    self.contentMatches = contentMatches
    self.matchCount = matchedFields.count + contentMatches.reduce(0) { $0 + $1.matchCount }
  }
}

public struct NotesAttachmentContentSearchContentMatch: Codable, Equatable, Sendable {
  public var kind: String
  public var sourceKind: String
  public var byteCount: Int
  public var sha256: String
  public var matchCount: Int
  public var version: Int?

  public init(
    kind: String,
    sourceKind: String,
    byteCount: Int,
    sha256: String,
    matchCount: Int,
    version: Int? = nil
  ) {
    self.kind = kind
    self.sourceKind = sourceKind
    self.byteCount = byteCount
    self.sha256 = sha256
    self.matchCount = matchCount
    self.version = version
  }
}

public struct NotesAttachmentAuditResponse: Codable, Equatable, Sendable {
  public var account: String?
  public var folder: String?
  public var summary: NotesAttachmentAuditSummary
  public var records: [NotesAttachmentAuditRecord]
  public var returnedNoteCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    account: String?,
    folder: String?,
    summary: NotesAttachmentAuditSummary,
    records: [NotesAttachmentAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.account = account
    self.folder = folder
    self.summary = summary
    self.records = records
    self.returnedNoteCount = records.count
    self.verification = verification
  }
}

public struct NotesAttachmentAuditSummary: Codable, Equatable, Sendable {
  public var noteCount: Int
  public var notesWithAttachmentsCount: Int
  public var attachmentCount: Int
  public var visibleAttachmentCount: Int
  public var deletedOrTrashAttachmentCount: Int
  public var inlineAttachmentCount: Int
  public var mediaBackedAttachmentCount: Int
  public var knownByteCountAttachmentCount: Int
  public var totalKnownByteCount: Int64
  public var rawUTIHashCount: Int
  public var pdfOrScanMarkupCandidateCount: Int
  public var familyCounts: [NotesAttachmentAuditCount]
  public var filenameExtensionCounts: [NotesAttachmentAuditCount]
  public var attachmentTypeCounts: [NotesAttachmentAuditCount]
  public var supportedReadFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedMutationFamilies: [String]

  public init(
    noteCount: Int,
    notesWithAttachmentsCount: Int,
    attachmentCount: Int,
    visibleAttachmentCount: Int,
    deletedOrTrashAttachmentCount: Int,
    inlineAttachmentCount: Int,
    mediaBackedAttachmentCount: Int,
    knownByteCountAttachmentCount: Int,
    totalKnownByteCount: Int64,
    rawUTIHashCount: Int,
    pdfOrScanMarkupCandidateCount: Int,
    familyCounts: [NotesAttachmentAuditCount],
    filenameExtensionCounts: [NotesAttachmentAuditCount],
    attachmentTypeCounts: [NotesAttachmentAuditCount],
    supportedReadFamilies: [String],
    delegatedWorkflowFamilies: [String] = [],
    gatedMutationFamilies: [String]
  ) {
    self.noteCount = noteCount
    self.notesWithAttachmentsCount = notesWithAttachmentsCount
    self.attachmentCount = attachmentCount
    self.visibleAttachmentCount = visibleAttachmentCount
    self.deletedOrTrashAttachmentCount = deletedOrTrashAttachmentCount
    self.inlineAttachmentCount = inlineAttachmentCount
    self.mediaBackedAttachmentCount = mediaBackedAttachmentCount
    self.knownByteCountAttachmentCount = knownByteCountAttachmentCount
    self.totalKnownByteCount = totalKnownByteCount
    self.rawUTIHashCount = rawUTIHashCount
    self.pdfOrScanMarkupCandidateCount = pdfOrScanMarkupCandidateCount
    self.familyCounts = familyCounts
    self.filenameExtensionCounts = filenameExtensionCounts
    self.attachmentTypeCounts = attachmentTypeCounts
    self.supportedReadFamilies = supportedReadFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedMutationFamilies = gatedMutationFamilies
  }
}

public struct NotesAttachmentAuditRecord: Codable, Equatable, Sendable {
  public var noteIDSHA256: String
  public var attachmentCount: Int
  public var visibleAttachmentCount: Int
  public var deletedOrTrashAttachmentCount: Int
  public var inlineAttachmentCount: Int
  public var mediaBackedAttachmentCount: Int
  public var knownByteCountAttachmentCount: Int
  public var totalKnownByteCount: Int64
  public var rawUTIHashCount: Int
  public var pdfOrScanMarkupCandidateCount: Int
  public var familyCounts: [NotesAttachmentAuditCount]
  public var filenameExtensionCounts: [NotesAttachmentAuditCount]
  public var attachmentTypeCounts: [NotesAttachmentAuditCount]

  public init(
    noteIDSHA256: String,
    attachmentCount: Int,
    visibleAttachmentCount: Int,
    deletedOrTrashAttachmentCount: Int,
    inlineAttachmentCount: Int,
    mediaBackedAttachmentCount: Int,
    knownByteCountAttachmentCount: Int,
    totalKnownByteCount: Int64,
    rawUTIHashCount: Int,
    pdfOrScanMarkupCandidateCount: Int,
    familyCounts: [NotesAttachmentAuditCount],
    filenameExtensionCounts: [NotesAttachmentAuditCount],
    attachmentTypeCounts: [NotesAttachmentAuditCount]
  ) {
    self.noteIDSHA256 = noteIDSHA256
    self.attachmentCount = attachmentCount
    self.visibleAttachmentCount = visibleAttachmentCount
    self.deletedOrTrashAttachmentCount = deletedOrTrashAttachmentCount
    self.inlineAttachmentCount = inlineAttachmentCount
    self.mediaBackedAttachmentCount = mediaBackedAttachmentCount
    self.knownByteCountAttachmentCount = knownByteCountAttachmentCount
    self.totalKnownByteCount = totalKnownByteCount
    self.rawUTIHashCount = rawUTIHashCount
    self.pdfOrScanMarkupCandidateCount = pdfOrScanMarkupCandidateCount
    self.familyCounts = familyCounts
    self.filenameExtensionCounts = filenameExtensionCounts
    self.attachmentTypeCounts = attachmentTypeCounts
  }
}

public struct NotesAttachmentAuditCount: Codable, Equatable, Sendable {
  public var name: String
  public var count: Int

  public init(name: String, count: Int) {
    self.name = name
    self.count = count
  }
}

public struct NotesAttachmentWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesAttachmentWorkflowAuditSummary
  public var records: [NotesAttachmentWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesAttachmentWorkflowAuditSummary,
    records: [NotesAttachmentWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesAttachmentWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesAttachmentWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesLinksResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var links: [NotesLinkRecord]

  public init(noteID: String, links: [NotesLinkRecord]) {
    self.noteID = noteID
    self.links = links
  }
}

public struct NotesLinkWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesLinkWorkflowAuditSummary
  public var records: [NotesLinkWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesLinkWorkflowAuditSummary,
    records: [NotesLinkWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesLinkWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesLinkWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesBacklinksResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var backlinks: [NotesBacklinkRecord]

  public init(noteID: String, backlinks: [NotesBacklinkRecord]) {
    self.noteID = noteID
    self.backlinks = backlinks
  }
}

public struct NotesLinkResolutionResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var requestedLinkID: String
  public var link: NotesLinkRecord
  public var destination: NotesLinkDestinationRecord
  public var verification: NotesMutationVerificationReport

  public init(
    noteID: String,
    requestedLinkID: String,
    link: NotesLinkRecord,
    destination: NotesLinkDestinationRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.noteID = noteID
    self.requestedLinkID = requestedLinkID
    self.link = link
    self.destination = destination
    self.verification = verification
  }
}

public struct NotesSmartFoldersResponse: Codable, Equatable, Sendable {
  public var smartFolders: [NotesSmartFolderRecord]

  public init(smartFolders: [NotesSmartFolderRecord]) {
    self.smartFolders = smartFolders
  }
}

public struct NotesSmartFolderNotesResponse: Codable, Equatable, Sendable {
  public var smartFolder: NotesSmartFolderRecord
  public var notes: [NotesNoteSummary]
  public var returnedNoteCount: Int
  public var visibleNoteCount: Int?

  public init(
    smartFolder: NotesSmartFolderRecord,
    notes: [NotesNoteSummary],
    visibleNoteCount: Int? = nil
  ) {
    self.smartFolder = smartFolder
    self.notes = notes
    self.returnedNoteCount = notes.count
    self.visibleNoteCount = visibleNoteCount
  }
}

public struct NotesSmartFolderCriteriaResponse: Codable, Equatable, Sendable {
  public var smartFolder: NotesSmartFolderRecord
  public var criteria: NotesSmartFolderCriteriaSummary?
  public var notes: [NotesNoteSummary]
  public var returnedNoteCount: Int
  public var visibleNoteCount: Int?
  public var verification: NotesMutationVerificationReport

  public init(
    smartFolder: NotesSmartFolderRecord,
    criteria: NotesSmartFolderCriteriaSummary?,
    notes: [NotesNoteSummary],
    visibleNoteCount: Int? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.smartFolder = smartFolder
    self.criteria = criteria
    self.notes = notes
    self.returnedNoteCount = notes.count
    self.visibleNoteCount = visibleNoteCount
    self.verification = verification
  }
}

public struct NotesSmartFolderCriteriaExplanationResponse: Codable, Equatable, Sendable {
  public var smartFolder: NotesSmartFolderRecord
  public var criteria: NotesSmartFolderCriteriaSummary?
  public var explanation: NotesSmartFolderCriteriaExplanationSummary
  public var notes: [NotesNoteSummary]
  public var returnedNoteCount: Int
  public var visibleNoteCount: Int?
  public var verification: NotesMutationVerificationReport

  public init(
    smartFolder: NotesSmartFolderRecord,
    criteria: NotesSmartFolderCriteriaSummary?,
    explanation: NotesSmartFolderCriteriaExplanationSummary,
    notes: [NotesNoteSummary],
    visibleNoteCount: Int? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.smartFolder = smartFolder
    self.criteria = criteria
    self.explanation = explanation
    self.notes = notes
    self.returnedNoteCount = notes.count
    self.visibleNoteCount = visibleNoteCount
    self.verification = verification
  }
}

public struct NotesSmartFolderMatchReasoningResponse: Codable, Equatable, Sendable {
  public var smartFolder: NotesSmartFolderRecord
  public var criteria: NotesSmartFolderCriteriaSummary?
  public var explanation: NotesSmartFolderCriteriaExplanationSummary
  public var matches: [NotesSmartFolderMatchReasonRecord]
  public var returnedMatchCount: Int
  public var visibleNoteCount: Int?
  public var verification: NotesMutationVerificationReport

  public init(
    smartFolder: NotesSmartFolderRecord,
    criteria: NotesSmartFolderCriteriaSummary?,
    explanation: NotesSmartFolderCriteriaExplanationSummary,
    matches: [NotesSmartFolderMatchReasonRecord],
    visibleNoteCount: Int? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.smartFolder = smartFolder
    self.criteria = criteria
    self.explanation = explanation
    self.matches = matches
    self.returnedMatchCount = matches.count
    self.visibleNoteCount = visibleNoteCount
    self.verification = verification
  }
}

public struct NotesSmartFolderMatchReasonRecord: Codable, Equatable, Sendable {
  public var note: NotesNoteSummary
  public var matchStatus: String
  public var reasoningStatus: String
  public var criteriaFamilies: [String]
  public var filters: [NotesSmartFolderCriteriaFilterExplanation]
  public var filterReasons: [NotesSmartFolderFilterReasonRecord]
  public var tagSelectionReason: NotesSmartFolderFilterReasonRecord?
  public var booleanTrace: NotesSmartFolderBooleanTraceRecord?
  public var tagSelectionPresent: Bool
  public var predicateHashPresent: Bool
  public var multiCondition: Bool
  public var gatedReasoningFamilies: [String]

  public init(
    note: NotesNoteSummary,
    matchStatus: String,
    reasoningStatus: String,
    criteriaFamilies: [String],
    filters: [NotesSmartFolderCriteriaFilterExplanation],
    filterReasons: [NotesSmartFolderFilterReasonRecord] = [],
    tagSelectionReason: NotesSmartFolderFilterReasonRecord? = nil,
    booleanTrace: NotesSmartFolderBooleanTraceRecord? = nil,
    tagSelectionPresent: Bool,
    predicateHashPresent: Bool,
    multiCondition: Bool,
    gatedReasoningFamilies: [String]
  ) {
    self.note = note
    self.matchStatus = matchStatus
    self.reasoningStatus = reasoningStatus
    self.criteriaFamilies = criteriaFamilies
    self.filters = filters
    self.filterReasons = filterReasons
    self.tagSelectionReason = tagSelectionReason
    self.booleanTrace = booleanTrace
    self.tagSelectionPresent = tagSelectionPresent
    self.predicateHashPresent = predicateHashPresent
    self.multiCondition = multiCondition
    self.gatedReasoningFamilies = gatedReasoningFamilies
  }
}

public struct NotesSmartFolderBooleanTraceRecord: Codable, Equatable, Sendable {
  public var status: String
  public var joinOperator: Int?
  public var conditionCount: Int
  public var filterCount: Int
  public var provedConditionCount: Int
  public var failedConditionCount: Int
  public var unknownConditionCount: Int
  public var provedFilterCount: Int
  public var failedFilterCount: Int
  public var unknownFilterCount: Int
  public var tagSelectionPresent: Bool
  public var tagSelectionProved: Bool?
  public var predicateHashPresent: Bool
  public var allKnownConditionsPassed: Bool?
  public var gatedReasoningFamilies: [String]

  public init(
    status: String,
    joinOperator: Int? = nil,
    conditionCount: Int,
    filterCount: Int,
    provedConditionCount: Int,
    failedConditionCount: Int,
    unknownConditionCount: Int,
    provedFilterCount: Int,
    failedFilterCount: Int,
    unknownFilterCount: Int,
    tagSelectionPresent: Bool,
    tagSelectionProved: Bool? = nil,
    predicateHashPresent: Bool,
    allKnownConditionsPassed: Bool? = nil,
    gatedReasoningFamilies: [String] = []
  ) {
    self.status = status
    self.joinOperator = joinOperator
    self.conditionCount = conditionCount
    self.filterCount = filterCount
    self.provedConditionCount = provedConditionCount
    self.failedConditionCount = failedConditionCount
    self.unknownConditionCount = unknownConditionCount
    self.provedFilterCount = provedFilterCount
    self.failedFilterCount = failedFilterCount
    self.unknownFilterCount = unknownFilterCount
    self.tagSelectionPresent = tagSelectionPresent
    self.tagSelectionProved = tagSelectionProved
    self.predicateHashPresent = predicateHashPresent
    self.allKnownConditionsPassed = allKnownConditionsPassed
    self.gatedReasoningFamilies = gatedReasoningFamilies
  }
}

public struct NotesSmartFolderFilterReasonRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var kind: String
  public var reasoningStatus: String
  public var matchStatus: String
  public var evidenceSource: String
  public var expectedBool: Bool?
  public var actualBool: Bool?
  public var expectedCount: Int?
  public var actualCount: Int?
  public var rawValueComparisonStatus: String
  public var gatedReasoningFamilies: [String]

  public init(
    ordinal: Int,
    kind: String,
    reasoningStatus: String,
    matchStatus: String,
    evidenceSource: String,
    expectedBool: Bool? = nil,
    actualBool: Bool? = nil,
    expectedCount: Int? = nil,
    actualCount: Int? = nil,
    rawValueComparisonStatus: String,
    gatedReasoningFamilies: [String] = []
  ) {
    self.ordinal = ordinal
    self.kind = kind
    self.reasoningStatus = reasoningStatus
    self.matchStatus = matchStatus
    self.evidenceSource = evidenceSource
    self.expectedBool = expectedBool
    self.actualBool = actualBool
    self.expectedCount = expectedCount
    self.actualCount = actualCount
    self.rawValueComparisonStatus = rawValueComparisonStatus
    self.gatedReasoningFamilies = gatedReasoningFamilies
  }
}

public struct NotesSmartFolderCriteriaExplanationSummary: Codable, Equatable, Sendable {
  public var queryKind: String
  public var filterCount: Int
  public var tagSelectionPresent: Bool
  public var predicateHashPresent: Bool
  public var multiCondition: Bool
  public var supportedReadFamilies: [String]
  public var gatedMutationFamilies: [String]
  public var filters: [NotesSmartFolderCriteriaFilterExplanation]

  public init(
    queryKind: String,
    filterCount: Int,
    tagSelectionPresent: Bool,
    predicateHashPresent: Bool,
    multiCondition: Bool,
    supportedReadFamilies: [String],
    gatedMutationFamilies: [String],
    filters: [NotesSmartFolderCriteriaFilterExplanation]
  ) {
    self.queryKind = queryKind
    self.filterCount = filterCount
    self.tagSelectionPresent = tagSelectionPresent
    self.predicateHashPresent = predicateHashPresent
    self.multiCondition = multiCondition
    self.supportedReadFamilies = supportedReadFamilies
    self.gatedMutationFamilies = gatedMutationFamilies
    self.filters = filters
  }
}

public struct NotesSmartFolderCriteriaAuditResponse: Codable, Equatable, Sendable {
  public var summary: NotesSmartFolderCriteriaAuditSummary
  public var records: [NotesSmartFolderCriteriaAuditRecord]
  public var returnedSmartFolderCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    summary: NotesSmartFolderCriteriaAuditSummary,
    records: [NotesSmartFolderCriteriaAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.summary = summary
    self.records = records
    self.returnedSmartFolderCount = records.count
    self.verification = verification
  }
}

public struct NotesSmartFolderCriteriaAuditSummary: Codable, Equatable, Sendable {
  public var smartFolderCount: Int
  public var queryPresentCount: Int
  public var criteriaSummaryCount: Int
  public var editableCount: Int
  public var multiConditionCount: Int
  public var predicateHashCount: Int
  public var tagSelectionCount: Int
  public var rawValueHashCount: Int
  public var filterKindCounts: [NotesSmartFolderCriteriaAuditKindCount]
  public var supportedReadFamilies: [String]
  public var gatedMutationFamilies: [String]

  public init(
    smartFolderCount: Int,
    queryPresentCount: Int,
    criteriaSummaryCount: Int,
    editableCount: Int,
    multiConditionCount: Int,
    predicateHashCount: Int,
    tagSelectionCount: Int,
    rawValueHashCount: Int,
    filterKindCounts: [NotesSmartFolderCriteriaAuditKindCount],
    supportedReadFamilies: [String],
    gatedMutationFamilies: [String]
  ) {
    self.smartFolderCount = smartFolderCount
    self.queryPresentCount = queryPresentCount
    self.criteriaSummaryCount = criteriaSummaryCount
    self.editableCount = editableCount
    self.multiConditionCount = multiConditionCount
    self.predicateHashCount = predicateHashCount
    self.tagSelectionCount = tagSelectionCount
    self.rawValueHashCount = rawValueHashCount
    self.filterKindCounts = filterKindCounts
    self.supportedReadFamilies = supportedReadFamilies
    self.gatedMutationFamilies = gatedMutationFamilies
  }
}

public struct NotesSmartFolderCriteriaAuditRecord: Codable, Equatable, Sendable {
  public var smartFolder: NotesSmartFolderRecord
  public var explanation: NotesSmartFolderCriteriaExplanationSummary

  public init(
    smartFolder: NotesSmartFolderRecord,
    explanation: NotesSmartFolderCriteriaExplanationSummary
  ) {
    self.smartFolder = smartFolder
    self.explanation = explanation
  }
}

public struct NotesSmartFolderCriteriaAuditKindCount: Codable, Equatable, Sendable {
  public var kind: String
  public var count: Int

  public init(kind: String, count: Int) {
    self.kind = kind
    self.count = count
  }
}

public struct NotesSmartFolderWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesSmartFolderWorkflowAuditSummary
  public var records: [NotesSmartFolderWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesSmartFolderWorkflowAuditSummary,
    records: [NotesSmartFolderWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesSmartFolderWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesSmartFolderWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesAccountsWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesAccountsWorkflowAuditSummary
  public var records: [NotesAccountsWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesAccountsWorkflowAuditSummary,
    records: [NotesAccountsWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesAccountsWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesAccountsWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesFoldersWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesFoldersWorkflowAuditSummary
  public var records: [NotesFoldersWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesFoldersWorkflowAuditSummary,
    records: [NotesFoldersWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesFoldersWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesFoldersWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesSmartFolderCriteriaFilterExplanation: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var kind: String
  public var readbackStatus: String
  public var mutationStatus: String
  public var selectionType: Int?
  public var inclusionType: Int?
  public var joinOperator: Int?
  public var rawValuePresent: Bool
  public var rawValueLength: Int?
  public var rawValueSHA256: String?
  public var count: Int?
  public var includedCount: Int?
  public var excludedCount: Int?
  public var hasPrimaryDate: Bool?
  public var hasSecondaryDate: Bool?
  public var hasRelativeRange: Bool?
  public var participantUserIDSHA256s: [String]

  public init(
    ordinal: Int,
    kind: String,
    readbackStatus: String,
    mutationStatus: String,
    selectionType: Int? = nil,
    inclusionType: Int? = nil,
    joinOperator: Int? = nil,
    rawValuePresent: Bool,
    rawValueLength: Int? = nil,
    rawValueSHA256: String? = nil,
    count: Int? = nil,
    includedCount: Int? = nil,
    excludedCount: Int? = nil,
    hasPrimaryDate: Bool? = nil,
    hasSecondaryDate: Bool? = nil,
    hasRelativeRange: Bool? = nil,
    participantUserIDSHA256s: [String] = []
  ) {
    self.ordinal = ordinal
    self.kind = kind
    self.readbackStatus = readbackStatus
    self.mutationStatus = mutationStatus
    self.selectionType = selectionType
    self.inclusionType = inclusionType
    self.joinOperator = joinOperator
    self.rawValuePresent = rawValuePresent
    self.rawValueLength = rawValueLength
    self.rawValueSHA256 = rawValueSHA256
    self.count = count
    self.includedCount = includedCount
    self.excludedCount = excludedCount
    self.hasPrimaryDate = hasPrimaryDate
    self.hasSecondaryDate = hasSecondaryDate
    self.hasRelativeRange = hasRelativeRange
    self.participantUserIDSHA256s = participantUserIDSHA256s
  }
}

public struct NotesBodyStructureResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var structure: NotesBodyStructureRecord

  public init(noteID: String, structure: NotesBodyStructureRecord) {
    self.noteID = noteID
    self.structure = structure
  }
}

public struct NotesBodySurfaceSummary: Codable, Equatable, Sendable {
  public var tableCount: Int
  public var collapsibleSectionCount: Int
  public var collapsedSectionCount: Int
  public var mathAttachmentCount: Int
  public var inlineAttachmentCount: Int
  public var isMathNote: Bool
  public var supportedReadFamilies: [String]
  public var supportedMutationFamilies: [String]
  public var gatedReadFamilies: [String]
  public var gatedMutationFamilies: [String]

  public init(
    tableCount: Int,
    collapsibleSectionCount: Int,
    collapsedSectionCount: Int,
    mathAttachmentCount: Int,
    inlineAttachmentCount: Int,
    isMathNote: Bool,
    supportedReadFamilies: [String],
    supportedMutationFamilies: [String] = [],
    gatedReadFamilies: [String],
    gatedMutationFamilies: [String]
  ) {
    self.tableCount = tableCount
    self.collapsibleSectionCount = collapsibleSectionCount
    self.collapsedSectionCount = collapsedSectionCount
    self.mathAttachmentCount = mathAttachmentCount
    self.inlineAttachmentCount = inlineAttachmentCount
    self.isMathNote = isMathNote
    self.supportedReadFamilies = supportedReadFamilies
    self.supportedMutationFamilies = supportedMutationFamilies
    self.gatedReadFamilies = gatedReadFamilies
    self.gatedMutationFamilies = gatedMutationFamilies
  }
}

public struct NotesBodySurfaceFamilyRecord: Codable, Equatable, Sendable {
  public var family: String
  public var readbackStatus: String
  public var mutationStatus: String
  public var count: Int?
  public var evidenceFields: [String]

  public init(
    family: String,
    readbackStatus: String,
    mutationStatus: String,
    count: Int? = nil,
    evidenceFields: [String]
  ) {
    self.family = family
    self.readbackStatus = readbackStatus
    self.mutationStatus = mutationStatus
    self.count = count
    self.evidenceFields = evidenceFields
  }
}

public struct NotesSmartFolderFilterCatalogAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesSmartFolderFilterCatalogAuditSummary
  public var records: [NotesSmartFolderFilterCatalogAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesSmartFolderFilterCatalogAuditSummary,
    records: [NotesSmartFolderFilterCatalogAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesSmartFolderFilterCatalogAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedFilterFamilies: [String]
  public var gatedFilterFamilies: [String]
  public var supportedCriteriaKinds: [String]
  public var gatedCriteriaKinds: [String]

  public init(
    supportedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedFilterFamilies: [String],
    gatedFilterFamilies: [String],
    supportedCriteriaKinds: [String],
    gatedCriteriaKinds: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedFilterFamilies = supportedFilterFamilies
    self.gatedFilterFamilies = gatedFilterFamilies
    self.supportedCriteriaKinds = supportedCriteriaKinds
    self.gatedCriteriaKinds = gatedCriteriaKinds
  }
}

public struct NotesSmartFolderFilterCatalogAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var filterFamily: String
  public var criteriaKind: String
  public var appleFilter: String
  public var valueShape: String
  public var status: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var combinationSupport: String
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    filterFamily: String,
    criteriaKind: String,
    appleFilter: String,
    valueShape: String,
    status: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    combinationSupport: String,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.filterFamily = filterFamily
    self.criteriaKind = criteriaKind
    self.appleFilter = appleFilter
    self.valueShape = valueShape
    self.status = status
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.combinationSupport = combinationSupport
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesBodySurfacesResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var summary: NotesBodySurfaceSummary
  public var surfaces: [NotesBodySurfaceFamilyRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    noteID: String,
    summary: NotesBodySurfaceSummary,
    surfaces: [NotesBodySurfaceFamilyRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.noteID = noteID
    self.summary = summary
    self.surfaces = surfaces
    self.verification = verification
  }
}

public struct NotesBodyFormatAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesBodyFormatAuditSummary
  public var records: [NotesBodyFormatAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesBodyFormatAuditSummary,
    records: [NotesBodyFormatAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesBodyFormatAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesBodyFormatAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesBodyCollapsibleSectionRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var paragraphIDSHA256: String
  public var titleByteCount: Int?
  public var titleSHA256: String?
  public var collapsed: Bool

  public init(
    ordinal: Int,
    paragraphIDSHA256: String,
    titleByteCount: Int? = nil,
    titleSHA256: String? = nil,
    collapsed: Bool
  ) {
    self.ordinal = ordinal
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.titleByteCount = titleByteCount
    self.titleSHA256 = titleSHA256
    self.collapsed = collapsed
  }
}

public struct NotesBodyCollapsibleSectionsResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var sections: [NotesBodyCollapsibleSectionRecord]
  public var structure: NotesBodyStructureRecord
  public var verification: NotesMutationVerificationReport

  public init(
    noteID: String,
    sections: [NotesBodyCollapsibleSectionRecord],
    structure: NotesBodyStructureRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.noteID = noteID
    self.sections = sections
    self.structure = structure
    self.verification = verification
  }
}

public enum NotesBodyCollapsibleState: String, Codable, Equatable, CaseIterable, Sendable {
  case collapsed
  case expanded
  case toggle

  public static var allowedDescription: String {
    allCases.map(\.rawValue).joined(separator: ",")
  }
}

public struct NotesBodyCollapsibleSetDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var state: NotesBodyCollapsibleState

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    state: NotesBodyCollapsibleState
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.state = state
  }
}

public struct NotesBodyCollapsibleSetWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyCollapsibleSectionRecord
  public var sections: [NotesBodyCollapsibleSectionRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyCollapsibleSectionRecord,
    sections: [NotesBodyCollapsibleSectionRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.sections = sections
  }
}

public struct NotesBodyTableCreateDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var text: String
  public var textByteCount: Int
  public var textSHA256: String
  public var rowCount: Int
  public var maxColumnCount: Int

  public init(
    noteID: String,
    text: String,
    rowCount: Int,
    maxColumnCount: Int
  ) {
    self.noteID = noteID
    self.text = text
    self.textByteCount = text.utf8.count
    self.textSHA256 = sha256Hex(text)
    self.rowCount = rowCount
    self.maxColumnCount = maxColumnCount
  }
}

public struct NotesBodyTableCreateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyTableImportDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var sourceKind: String
  public var sourceFormat: String
  public var sourceByteCount: Int
  public var sourceSHA256: String
  public var tableText: String
  public var tableTextByteCount: Int
  public var tableTextSHA256: String
  public var rowCount: Int
  public var maxColumnCount: Int
  public var cellCount: Int

  public init(
    noteID: String,
    sourceKind: String,
    sourceFormat: String,
    source: String,
    tableText: String,
    rowCount: Int,
    maxColumnCount: Int
  ) {
    self.noteID = noteID
    self.sourceKind = sourceKind
    self.sourceFormat = sourceFormat
    self.sourceByteCount = source.utf8.count
    self.sourceSHA256 = sha256Hex(source)
    self.tableText = tableText
    self.tableTextByteCount = tableText.utf8.count
    self.tableTextSHA256 = sha256Hex(tableText)
    self.rowCount = rowCount
    self.maxColumnCount = maxColumnCount
    self.cellCount = rowCount * maxColumnCount
  }
}

public struct NotesBodyTableImportWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
  }
}

public struct NotesBodyTableUpdateDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int
  public var row: Int
  public var column: Int
  public var text: String
  public var textByteCount: Int
  public var textSHA256: String

  public init(noteID: String, ordinal: Int, row: Int, column: Int, text: String) {
    self.noteID = noteID
    self.ordinal = ordinal
    self.row = row
    self.column = column
    self.text = text
    self.textByteCount = text.utf8.count
    self.textSHA256 = sha256Hex(text)
  }
}

public struct NotesBodyTableUpdateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var cell: NotesBodyTableCellRecord
  public var tables: [NotesBodyTableRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    cell: NotesBodyTableCellRecord,
    tables: [NotesBodyTableRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.cell = cell
    self.tables = tables
  }
}

public struct NotesBodyTableDeleteDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int

  public init(noteID: String, ordinal: Int) {
    self.noteID = noteID
    self.ordinal = ordinal
  }
}

public struct NotesBodyTableDeleteWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
  }
}

public struct NotesBodyTableConvertToTextDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int

  public init(noteID: String, ordinal: Int, rowCount: Int, columnCount: Int) {
    self.noteID = noteID
    self.ordinal = ordinal
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = rowCount * columnCount
  }
}

public struct NotesBodyTableConvertToTextWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var convertedText: String
  public var convertedTextByteCount: Int
  public var convertedTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    convertedText: String,
    rowCount: Int,
    columnCount: Int
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
    self.convertedText = convertedText
    self.convertedTextByteCount = convertedText.utf8.count
    self.convertedTextSHA256 = sha256Hex(convertedText)
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = rowCount * columnCount
  }
}

public struct NotesBodyTableConvertFromTextDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String
  public var ordinal: Int
  public var requestedSelector: String
  public var sourceTitleByteCount: Int?
  public var sourceTitleSHA256: String?

  public init(
    noteID: String,
    paragraphIDSHA256: String,
    ordinal: Int,
    requestedSelector: String,
    sourceTitleByteCount: Int? = nil,
    sourceTitleSHA256: String? = nil
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.requestedSelector = requestedSelector
    self.sourceTitleByteCount = sourceTitleByteCount
    self.sourceTitleSHA256 = sourceTitleSHA256
  }
}

public struct NotesBodyTableConvertFromTextWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var sourceParagraphIDSHA256: String
  public var sourceText: String
  public var sourceTextByteCount: Int
  public var sourceTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    sourceParagraphIDSHA256: String,
    sourceText: String,
    rowCount: Int,
    columnCount: Int
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
    self.sourceParagraphIDSHA256 = sourceParagraphIDSHA256
    self.sourceText = sourceText
    self.sourceTextByteCount = sourceText.utf8.count
    self.sourceTextSHA256 = sha256Hex(sourceText)
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = rowCount * columnCount
  }
}

public struct NotesBodyTableCopyDraft: Codable, Equatable, Sendable {
  public var sourceNoteID: String
  public var targetNoteID: String
  public var ordinal: Int
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int

  public var sameNote: Bool {
    sourceNoteID == targetNoteID
  }

  public init(
    sourceNoteID: String,
    targetNoteID: String,
    ordinal: Int,
    rowCount: Int,
    columnCount: Int
  ) {
    self.sourceNoteID = sourceNoteID
    self.targetNoteID = targetNoteID
    self.ordinal = ordinal
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = rowCount * columnCount
  }
}

public struct NotesBodyTableCopyWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var sourceNote: NotesNoteDetail
  public var targetNote: NotesNoteDetail
  public var sourceStructure: NotesBodyStructureRecord
  public var targetStructure: NotesBodyStructureRecord
  public var sourceTable: NotesBodyTableRecord
  public var targetTable: NotesBodyTableRecord
  public var sourceTables: [NotesBodyTableRecord]
  public var targetTables: [NotesBodyTableRecord]
  public var copiedText: String
  public var copiedTextByteCount: Int
  public var copiedTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int

  public init(
    changed: Bool,
    sourceNote: NotesNoteDetail,
    targetNote: NotesNoteDetail,
    sourceStructure: NotesBodyStructureRecord,
    targetStructure: NotesBodyStructureRecord,
    sourceTable: NotesBodyTableRecord,
    targetTable: NotesBodyTableRecord,
    sourceTables: [NotesBodyTableRecord],
    targetTables: [NotesBodyTableRecord],
    copiedText: String,
    rowCount: Int,
    columnCount: Int
  ) {
    self.changed = changed
    self.sourceNote = sourceNote
    self.targetNote = targetNote
    self.sourceStructure = sourceStructure
    self.targetStructure = targetStructure
    self.sourceTable = sourceTable
    self.targetTable = targetTable
    self.sourceTables = sourceTables
    self.targetTables = targetTables
    self.copiedText = copiedText
    self.copiedTextByteCount = copiedText.utf8.count
    self.copiedTextSHA256 = sha256Hex(copiedText)
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = rowCount * columnCount
  }
}

public struct NotesBodyTableMoveDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int
  public var targetOrdinal: Int

  public init(noteID: String, ordinal: Int, targetOrdinal: Int) {
    self.noteID = noteID
    self.ordinal = ordinal
    self.targetOrdinal = targetOrdinal
  }
}

public struct NotesBodyTableMoveWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var beforeTarget: NotesBodyTableRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    beforeTarget: NotesBodyTableRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.beforeTarget = beforeTarget
    self.target = target
    self.tables = tables
  }
}

public enum NotesBodyTableStructureAxis: String, Codable, Equatable, Sendable {
  case row
  case column
}

public enum NotesBodyTableStructureAction: String, Codable, Equatable, Sendable {
  case insert
  case delete
  case move
  case copy
  case clear
}

public struct NotesBodyTableStructureDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int
  public var axis: NotesBodyTableStructureAxis
  public var action: NotesBodyTableStructureAction
  public var index: Int
  public var toIndex: Int?
  public var count: Int

  public init(
    noteID: String,
    ordinal: Int,
    axis: NotesBodyTableStructureAxis,
    action: NotesBodyTableStructureAction,
    index: Int,
    toIndex: Int? = nil,
    count: Int
  ) {
    self.noteID = noteID
    self.ordinal = ordinal
    self.axis = axis
    self.action = action
    self.index = index
    self.toIndex = toIndex
    self.count = count
  }
}

public struct NotesBodyTableStructureWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var beforeTarget: NotesBodyTableRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var movedSliceCellCount: Int?
  public var movedSliceSHA256: String?
  public var copiedSliceCellCount: Int?
  public var copiedSliceSHA256: String?
  public var clearedSliceCellCount: Int?
  public var clearedSliceSHA256: String?

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    beforeTarget: NotesBodyTableRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    movedSliceCellCount: Int? = nil,
    movedSliceSHA256: String? = nil,
    copiedSliceCellCount: Int? = nil,
    copiedSliceSHA256: String? = nil,
    clearedSliceCellCount: Int? = nil,
    clearedSliceSHA256: String? = nil
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.beforeTarget = beforeTarget
    self.target = target
    self.tables = tables
    self.movedSliceCellCount = movedSliceCellCount
    self.movedSliceSHA256 = movedSliceSHA256
    self.copiedSliceCellCount = copiedSliceCellCount
    self.copiedSliceSHA256 = copiedSliceSHA256
    self.clearedSliceCellCount = clearedSliceCellCount
    self.clearedSliceSHA256 = clearedSliceSHA256
  }
}

public struct NotesBodyTableFormatDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int
  public var axis: NotesBodyTableStructureAxis
  public var index: Int
  public var count: Int
  public var format: NotesBodyInlineFormat
  public var enabled: Bool
  public var selectedCellCount: Int

  public init(
    noteID: String,
    ordinal: Int,
    axis: NotesBodyTableStructureAxis,
    index: Int,
    count: Int,
    format: NotesBodyInlineFormat,
    enabled: Bool,
    selectedCellCount: Int
  ) {
    self.noteID = noteID
    self.ordinal = ordinal
    self.axis = axis
    self.index = index
    self.count = count
    self.format = format
    self.enabled = enabled
    self.selectedCellCount = selectedCellCount
  }
}

public struct NotesBodyTableFormatWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var beforeTarget: NotesBodyTableRecord
  public var target: NotesBodyTableRecord
  public var cells: [NotesBodyTableCellRecord]
  public var tables: [NotesBodyTableRecord]
  public var beforeTextSliceSHA256: String
  public var afterTextSliceSHA256: String
  public var beforeFormatSliceSHA256: String?
  public var afterFormatSliceSHA256: String?

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    beforeTarget: NotesBodyTableRecord,
    target: NotesBodyTableRecord,
    cells: [NotesBodyTableCellRecord],
    tables: [NotesBodyTableRecord],
    beforeTextSliceSHA256: String,
    afterTextSliceSHA256: String,
    beforeFormatSliceSHA256: String? = nil,
    afterFormatSliceSHA256: String? = nil
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.beforeTarget = beforeTarget
    self.target = target
    self.cells = cells
    self.tables = tables
    self.beforeTextSliceSHA256 = beforeTextSliceSHA256
    self.afterTextSliceSHA256 = afterTextSliceSHA256
    self.beforeFormatSliceSHA256 = beforeFormatSliceSHA256
    self.afterFormatSliceSHA256 = afterFormatSliceSHA256
  }
}

public struct NotesBodyMathInsertDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var expression: String
  public var expressionByteCount: Int
  public var expressionSHA256: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?

  public init(noteID: String, expression: String, paragraphIDSHA256: String? = nil, ordinal: Int? = nil) {
    self.noteID = noteID
    self.expression = expression
    self.expressionByteCount = expression.utf8.count
    self.expressionSHA256 = sha256Hex(expression)
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
  }
}

public struct NotesBodyMathInsertWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.results = results
  }
}

public struct NotesBodyMathUpdateDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var ordinal: Int
  public var result: String
  public var resultByteCount: Int
  public var resultSHA256: String

  public init(noteID: String, ordinal: Int, result: String) {
    self.noteID = noteID
    self.ordinal = ordinal
    self.result = result
    self.resultByteCount = result.utf8.count
    self.resultSHA256 = sha256Hex(result)
  }
}

public struct NotesBodyMathResultsPreferenceDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var mode: String
  public var rawValue: Int
  public var requestedValueSHA256: String

  public init(noteID: String, mode: String, rawValue: Int) {
    self.noteID = noteID
    self.mode = mode
    self.rawValue = rawValue
    self.requestedValueSHA256 = NotesBodyMathResultsPreferenceDraft.valueSHA256(
      mode: mode,
      rawValue: rawValue
    )
  }

  public static func valueSHA256(mode: String, rawValue: Int) -> String {
    sha256Hex(["ICNote.calculatePreviewBehavior", mode, "\(rawValue)"].joined(separator: "|"))
  }
}

public struct NotesBodyMathResultsPreferenceWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var before: NotesBodyMathResultsPreferenceRecord
  public var after: NotesBodyMathResultsPreferenceRecord

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    before: NotesBodyMathResultsPreferenceRecord,
    after: NotesBodyMathResultsPreferenceRecord
  ) {
    self.changed = changed
    self.note = note
    self.before = before
    self.after = after
  }
}

public struct NotesBodyMathUpdateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    target: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.results = results
  }
}

public struct NotesBodyMathVariableSetDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var name: String
  public var value: String
  public var expression: String
  public var variableDefinitionExpression: String
  public var dependentExpression: String
  public var variableNameByteCount: Int
  public var variableNameSHA256: String
  public var variableValueByteCount: Int
  public var variableValueSHA256: String
  public var dependentExpressionByteCount: Int
  public var dependentExpressionSHA256: String
  public var variableDefinitionExpressionByteCount: Int
  public var variableDefinitionExpressionSHA256: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?

  public init(
    noteID: String,
    name: String,
    value: String,
    expression: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil
  ) {
    self.noteID = noteID
    self.name = name
    self.value = value
    self.expression = expression
    variableDefinitionExpression = "\(name)=\(value)"
    dependentExpression = "\(expression)="
    variableNameByteCount = name.utf8.count
    variableNameSHA256 = sha256Hex(name)
    variableValueByteCount = value.utf8.count
    variableValueSHA256 = sha256Hex(value)
    dependentExpressionByteCount = dependentExpression.utf8.count
    dependentExpressionSHA256 = sha256Hex(dependentExpression)
    variableDefinitionExpressionByteCount = variableDefinitionExpression.utf8.count
    variableDefinitionExpressionSHA256 = sha256Hex(variableDefinitionExpression)
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
  }
}

public struct NotesBodyMathVariableSetWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var variableDefinitionResult: NotesBodyMathResultRecord
  public var dependentResult: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    variableDefinitionResult: NotesBodyMathResultRecord,
    dependentResult: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.variableDefinitionResult = variableDefinitionResult
    self.dependentResult = dependentResult
    self.results = results
  }
}

public struct NotesBodyMathVariableUpdateDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var definitionOrdinal: Int
  public var dependentOrdinal: Int
  public var value: String
  public var variableValueByteCount: Int
  public var variableValueSHA256: String

  public init(noteID: String, definitionOrdinal: Int, dependentOrdinal: Int, value: String) {
    self.noteID = noteID
    self.definitionOrdinal = definitionOrdinal
    self.dependentOrdinal = dependentOrdinal
    self.value = value
    variableValueByteCount = value.utf8.count
    variableValueSHA256 = sha256Hex(value)
  }
}

public struct NotesBodyMathVariableUpdateWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var beforeDefinition: NotesBodyMathResultRecord
  public var afterDefinition: NotesBodyMathResultRecord
  public var beforeDependent: NotesBodyMathResultRecord
  public var afterDependent: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    beforeDefinition: NotesBodyMathResultRecord,
    afterDefinition: NotesBodyMathResultRecord,
    beforeDependent: NotesBodyMathResultRecord,
    afterDependent: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord]
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.beforeDefinition = beforeDefinition
    self.afterDefinition = afterDefinition
    self.beforeDependent = beforeDependent
    self.afterDependent = afterDependent
    self.results = results
  }
}

public struct NotesBodyChecklistAddDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var text: String
  public var checked: Bool

  public init(noteID: String, text: String, checked: Bool = false) {
    self.noteID = noteID
    self.text = text
    self.checked = checked
  }
}

public struct NotesBodyChecklistAddWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistSetDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var checked: Bool

  public init(noteID: String, paragraphIDSHA256: String? = nil, ordinal: Int? = nil, checked: Bool) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.checked = checked
  }
}

public struct NotesBodyChecklistSetWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistSetAllDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var checked: Bool

  public init(noteID: String, checked: Bool) {
    self.noteID = noteID
    self.checked = checked
  }
}

public struct NotesBodyChecklistSetAllWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistSortDraft: Codable, Equatable, Sendable {
  public var noteID: String

  public init(noteID: String) {
    self.noteID = noteID
  }
}

public struct NotesBodyChecklistSortWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistConvertDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var checked: Bool

  public init(noteID: String, paragraphIDSHA256: String? = nil, ordinal: Int? = nil, checked: Bool) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.checked = checked
  }
}

public struct NotesBodyChecklistConvertWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistConvertRangeDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var fromOrdinal: Int
  public var toOrdinal: Int
  public var checked: Bool

  public init(noteID: String, fromOrdinal: Int, toOrdinal: Int, checked: Bool) {
    self.noteID = noteID
    self.fromOrdinal = fromOrdinal
    self.toOrdinal = toOrdinal
    self.checked = checked
  }
}

public struct NotesBodyChecklistConvertRangeWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistReorderDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var targetOrdinal: Int

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    targetOrdinal: Int
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.targetOrdinal = targetOrdinal
  }
}

public struct NotesBodyChecklistReorderWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistIndentDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var delta: Int

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    delta: Int
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.delta = delta
  }
}

public struct NotesBodyChecklistIndentWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistDeleteDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?

  public init(noteID: String, paragraphIDSHA256: String? = nil, ordinal: Int? = nil) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
  }
}

public struct NotesBodyChecklistDeleteWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListAddDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var text: String
  public var style: NotesBodyListStyle

  public init(noteID: String, text: String, style: NotesBodyListStyle) {
    self.noteID = noteID
    self.text = text
    self.style = style
  }
}

public struct NotesBodyListAddWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListConvertDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var style: NotesBodyListStyle

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    style: NotesBodyListStyle
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.style = style
  }
}

public struct NotesBodyListConvertWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListConvertRangeDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var fromOrdinal: Int
  public var toOrdinal: Int
  public var style: NotesBodyListStyle

  public init(noteID: String, fromOrdinal: Int, toOrdinal: Int, style: NotesBodyListStyle) {
    self.noteID = noteID
    self.fromOrdinal = fromOrdinal
    self.toOrdinal = toOrdinal
    self.style = style
  }
}

public struct NotesBodyListConvertRangeWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListSetStyleDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var style: NotesBodyListStyle

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    style: NotesBodyListStyle
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.style = style
  }
}

public struct NotesBodyListSetStyleWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListReorderDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var targetOrdinal: Int

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    targetOrdinal: Int
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.targetOrdinal = targetOrdinal
  }
}

public struct NotesBodyListReorderWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListIndentDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var delta: Int

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    delta: Int
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.delta = delta
  }
}

public struct NotesBodyListIndentWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyListDeleteDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?

  public init(noteID: String, paragraphIDSHA256: String? = nil, ordinal: Int? = nil) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
  }
}

public struct NotesBodyListDeleteWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public enum NotesBodyListTextInsertTargetKind: String, Codable, Equatable, Sendable {
  case ordinaryList = "ordinary_list"
  case checklist
}

public enum NotesBodyListTextInsertKind: String, Codable, Equatable, Sendable {
  case lineBreak = "line_break"
  case tab

  public var insertedText: String {
    switch self {
    case .lineBreak:
      return "\u{2028}"
    case .tab:
      return "\t"
    }
  }

  public var insertedTextByteCount: Int {
    insertedText.utf8.count
  }

  public var insertedTextSHA256: String {
    sha256Hex(insertedText)
  }
}

public struct NotesBodyListTextInsertDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var targetKind: NotesBodyListTextInsertTargetKind
  public var insertKind: NotesBodyListTextInsertKind

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    targetKind: NotesBodyListTextInsertTargetKind,
    insertKind: NotesBodyListTextInsertKind
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.targetKind = targetKind
    self.insertKind = insertKind
  }
}

public struct NotesBodyListTextInsertWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var insertedTextByteCount: Int
  public var insertedTextSHA256: String

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    insertedTextByteCount: Int,
    insertedTextSHA256: String
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.insertedTextByteCount = insertedTextByteCount
    self.insertedTextSHA256 = insertedTextSHA256
  }
}

public enum NotesBodyListEndTargetKind: String, Codable, Equatable, Sendable {
  case ordinaryList = "ordinary_list"
  case checklist
}

public struct NotesBodyListEndDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var targetKind: NotesBodyListEndTargetKind

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    targetKind: NotesBodyListEndTargetKind
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.targetKind = targetKind
  }
}

public struct NotesBodyListEndWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord
  public var createdParagraphStyle: String
  public var createdParagraphIDSHA256: String?

  public init(
    changed: Bool,
    note: NotesNoteDetail,
    structure: NotesBodyStructureRecord,
    createdParagraphStyle: String,
    createdParagraphIDSHA256: String? = nil
  ) {
    self.changed = changed
    self.note = note
    self.structure = structure
    self.createdParagraphStyle = createdParagraphStyle
    self.createdParagraphIDSHA256 = createdParagraphIDSHA256
  }
}

public struct NotesBodyParagraphStyleDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var style: NotesBodyParagraphStyle

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    style: NotesBodyParagraphStyle
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.style = style
  }
}

public struct NotesBodyParagraphAlignmentDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var alignment: NotesBodyParagraphAlignment

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    alignment: NotesBodyParagraphAlignment
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.alignment = alignment
  }
}

public struct NotesBodyParagraphQuoteDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var paragraphIDSHA256: String?
  public var ordinal: Int?
  public var enabled: Bool

  public init(
    noteID: String,
    paragraphIDSHA256: String? = nil,
    ordinal: Int? = nil,
    enabled: Bool
  ) {
    self.noteID = noteID
    self.paragraphIDSHA256 = paragraphIDSHA256
    self.ordinal = ordinal
    self.enabled = enabled
  }
}

public struct NotesBodyParagraphFormatWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var structure: NotesBodyStructureRecord

  public init(changed: Bool, note: NotesNoteDetail, structure: NotesBodyStructureRecord) {
    self.changed = changed
    self.note = note
    self.structure = structure
  }
}

public struct NotesBodyChecklistMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.verification = verification
  }
}

public struct NotesBodyListEndMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var targetKind: NotesBodyListEndTargetKind
  public var createdParagraphStyle: String
  public var createdParagraphIDSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    targetKind: NotesBodyListEndTargetKind,
    createdParagraphStyle: String,
    createdParagraphIDSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.targetKind = targetKind
    self.createdParagraphStyle = createdParagraphStyle
    self.createdParagraphIDSHA256 = createdParagraphIDSHA256
    self.verification = verification
  }
}

public struct NotesBodyListTextInsertMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var targetKind: NotesBodyListTextInsertTargetKind
  public var insertedKind: NotesBodyListTextInsertKind
  public var insertedTextByteCount: Int
  public var insertedTextSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    targetKind: NotesBodyListTextInsertTargetKind,
    insertedKind: NotesBodyListTextInsertKind,
    insertedTextByteCount: Int,
    insertedTextSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.targetKind = targetKind
    self.insertedKind = insertedKind
    self.insertedTextByteCount = insertedTextByteCount
    self.insertedTextSHA256 = insertedTextSHA256
    self.verification = verification
  }
}

public struct NotesBodyTableCreateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var tableTextByteCount: Int
  public var tableTextSHA256: String
  public var tableRowCount: Int
  public var tableMaxColumnCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    tableTextByteCount: Int,
    tableTextSHA256: String,
    tableRowCount: Int,
    tableMaxColumnCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.tableTextByteCount = tableTextByteCount
    self.tableTextSHA256 = tableTextSHA256
    self.tableRowCount = tableRowCount
    self.tableMaxColumnCount = tableMaxColumnCount
    self.verification = verification
  }
}

public struct NotesBodyTableImportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var sourceKind: String
  public var sourceFormat: String
  public var sourceByteCount: Int
  public var sourceSHA256: String
  public var tableTextByteCount: Int
  public var tableTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    sourceKind: String,
    sourceFormat: String,
    sourceByteCount: Int,
    sourceSHA256: String,
    tableTextByteCount: Int,
    tableTextSHA256: String,
    rowCount: Int,
    columnCount: Int,
    cellCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
    self.sourceKind = sourceKind
    self.sourceFormat = sourceFormat
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.tableTextByteCount = tableTextByteCount
    self.tableTextSHA256 = tableTextSHA256
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = cellCount
    self.verification = verification
  }
}

public struct NotesBodyTableUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var cell: NotesBodyTableCellRecord
  public var tables: [NotesBodyTableRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    cell: NotesBodyTableCellRecord,
    tables: [NotesBodyTableRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.cell = cell
    self.tables = tables
    self.verification = verification
  }
}

public struct NotesBodyTableDeleteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
    self.verification = verification
  }
}

public struct NotesBodyTableConvertToTextResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var convertedTextByteCount: Int
  public var convertedTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    convertedTextByteCount: Int,
    convertedTextSHA256: String,
    rowCount: Int,
    columnCount: Int,
    cellCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
    self.convertedTextByteCount = convertedTextByteCount
    self.convertedTextSHA256 = convertedTextSHA256
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = cellCount
    self.verification = verification
  }
}

public struct NotesBodyTableConvertFromTextResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var sourceParagraphIDSHA256: String
  public var sourceTextByteCount: Int
  public var sourceTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    sourceParagraphIDSHA256: String,
    sourceTextByteCount: Int,
    sourceTextSHA256: String,
    rowCount: Int,
    columnCount: Int,
    cellCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.tables = tables
    self.sourceParagraphIDSHA256 = sourceParagraphIDSHA256
    self.sourceTextByteCount = sourceTextByteCount
    self.sourceTextSHA256 = sourceTextSHA256
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = cellCount
    self.verification = verification
  }
}

public struct NotesBodyTableCopyResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourceNote: NotesNoteSummary
  public var targetNote: NotesNoteSummary
  public var sourceStructure: NotesBodyStructureRecord
  public var targetStructure: NotesBodyStructureRecord
  public var sourceTable: NotesBodyTableRecord
  public var targetTable: NotesBodyTableRecord
  public var sourceTables: [NotesBodyTableRecord]
  public var targetTables: [NotesBodyTableRecord]
  public var copiedTextByteCount: Int
  public var copiedTextSHA256: String
  public var rowCount: Int
  public var columnCount: Int
  public var cellCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    sourceNote: NotesNoteSummary,
    targetNote: NotesNoteSummary,
    sourceStructure: NotesBodyStructureRecord,
    targetStructure: NotesBodyStructureRecord,
    sourceTable: NotesBodyTableRecord,
    targetTable: NotesBodyTableRecord,
    sourceTables: [NotesBodyTableRecord],
    targetTables: [NotesBodyTableRecord],
    copiedTextByteCount: Int,
    copiedTextSHA256: String,
    rowCount: Int,
    columnCount: Int,
    cellCount: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.sourceNote = sourceNote
    self.targetNote = targetNote
    self.sourceStructure = sourceStructure
    self.targetStructure = targetStructure
    self.sourceTable = sourceTable
    self.targetTable = targetTable
    self.sourceTables = sourceTables
    self.targetTables = targetTables
    self.copiedTextByteCount = copiedTextByteCount
    self.copiedTextSHA256 = copiedTextSHA256
    self.rowCount = rowCount
    self.columnCount = columnCount
    self.cellCount = cellCount
    self.verification = verification
  }
}

public struct NotesBodyTableMoveResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var ordinal: Int
  public var targetOrdinal: Int
  public var beforeTarget: NotesBodyTableRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    ordinal: Int,
    targetOrdinal: Int,
    beforeTarget: NotesBodyTableRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.ordinal = ordinal
    self.targetOrdinal = targetOrdinal
    self.beforeTarget = beforeTarget
    self.target = target
    self.tables = tables
    self.verification = verification
  }
}

public struct NotesBodyTableStructureResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var axis: NotesBodyTableStructureAxis
  public var action: NotesBodyTableStructureAction
  public var index: Int
  public var toIndex: Int?
  public var count: Int
  public var beforeTarget: NotesBodyTableRecord
  public var target: NotesBodyTableRecord
  public var tables: [NotesBodyTableRecord]
  public var movedSliceCellCount: Int?
  public var movedSliceSHA256: String?
  public var copiedSliceCellCount: Int?
  public var copiedSliceSHA256: String?
  public var clearedSliceCellCount: Int?
  public var clearedSliceSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    axis: NotesBodyTableStructureAxis,
    action: NotesBodyTableStructureAction,
    index: Int,
    toIndex: Int? = nil,
    count: Int,
    beforeTarget: NotesBodyTableRecord,
    target: NotesBodyTableRecord,
    tables: [NotesBodyTableRecord],
    movedSliceCellCount: Int? = nil,
    movedSliceSHA256: String? = nil,
    copiedSliceCellCount: Int? = nil,
    copiedSliceSHA256: String? = nil,
    clearedSliceCellCount: Int? = nil,
    clearedSliceSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.axis = axis
    self.action = action
    self.index = index
    self.toIndex = toIndex
    self.count = count
    self.beforeTarget = beforeTarget
    self.target = target
    self.tables = tables
    self.movedSliceCellCount = movedSliceCellCount
    self.movedSliceSHA256 = movedSliceSHA256
    self.copiedSliceCellCount = copiedSliceCellCount
    self.copiedSliceSHA256 = copiedSliceSHA256
    self.clearedSliceCellCount = clearedSliceCellCount
    self.clearedSliceSHA256 = clearedSliceSHA256
    self.verification = verification
  }
}

public struct NotesBodyTableFormatResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var axis: NotesBodyTableStructureAxis
  public var index: Int
  public var count: Int
  public var format: NotesBodyInlineFormat
  public var enabled: Bool
  public var selectedCellCount: Int
  public var beforeTarget: NotesBodyTableRecord
  public var target: NotesBodyTableRecord
  public var cells: [NotesBodyTableCellRecord]
  public var tables: [NotesBodyTableRecord]
  public var beforeTextSliceSHA256: String
  public var afterTextSliceSHA256: String
  public var beforeFormatSliceSHA256: String?
  public var afterFormatSliceSHA256: String?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    axis: NotesBodyTableStructureAxis,
    index: Int,
    count: Int,
    format: NotesBodyInlineFormat,
    enabled: Bool,
    selectedCellCount: Int,
    beforeTarget: NotesBodyTableRecord,
    target: NotesBodyTableRecord,
    cells: [NotesBodyTableCellRecord],
    tables: [NotesBodyTableRecord],
    beforeTextSliceSHA256: String,
    afterTextSliceSHA256: String,
    beforeFormatSliceSHA256: String? = nil,
    afterFormatSliceSHA256: String? = nil,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.axis = axis
    self.index = index
    self.count = count
    self.format = format
    self.enabled = enabled
    self.selectedCellCount = selectedCellCount
    self.beforeTarget = beforeTarget
    self.target = target
    self.cells = cells
    self.tables = tables
    self.beforeTextSliceSHA256 = beforeTextSliceSHA256
    self.afterTextSliceSHA256 = afterTextSliceSHA256
    self.beforeFormatSliceSHA256 = beforeFormatSliceSHA256
    self.afterFormatSliceSHA256 = afterFormatSliceSHA256
    self.verification = verification
  }
}

public struct NotesBodyMathUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.results = results
    self.verification = verification
  }
}

public struct NotesBodyMathInsertResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var target: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]
  public var placement: String
  public var expressionByteCount: Int
  public var expressionSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    target: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord],
    placement: String,
    expressionByteCount: Int,
    expressionSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.target = target
    self.results = results
    self.placement = placement
    self.expressionByteCount = expressionByteCount
    self.expressionSHA256 = expressionSHA256
    self.verification = verification
  }
}

public struct NotesBodyMathResultsPreferenceResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var before: NotesBodyMathResultsPreferenceRecord
  public var after: NotesBodyMathResultsPreferenceRecord
  public var requestedMode: String
  public var requestedRawValue: Int
  public var requestedValueSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    before: NotesBodyMathResultsPreferenceRecord,
    after: NotesBodyMathResultsPreferenceRecord,
    requestedMode: String,
    requestedRawValue: Int,
    requestedValueSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.before = before
    self.after = after
    self.requestedMode = requestedMode
    self.requestedRawValue = requestedRawValue
    self.requestedValueSHA256 = requestedValueSHA256
    self.verification = verification
  }
}

public struct NotesBodyMathVariableSetResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var variableDefinitionResult: NotesBodyMathResultRecord
  public var dependentResult: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]
  public var placement: String
  public var variableNameByteCount: Int
  public var variableNameSHA256: String
  public var variableValueByteCount: Int
  public var variableValueSHA256: String
  public var variableDefinitionExpressionByteCount: Int
  public var variableDefinitionExpressionSHA256: String
  public var dependentExpressionByteCount: Int
  public var dependentExpressionSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    variableDefinitionResult: NotesBodyMathResultRecord,
    dependentResult: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord],
    placement: String,
    variableNameByteCount: Int,
    variableNameSHA256: String,
    variableValueByteCount: Int,
    variableValueSHA256: String,
    variableDefinitionExpressionByteCount: Int,
    variableDefinitionExpressionSHA256: String,
    dependentExpressionByteCount: Int,
    dependentExpressionSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.variableDefinitionResult = variableDefinitionResult
    self.dependentResult = dependentResult
    self.results = results
    self.placement = placement
    self.variableNameByteCount = variableNameByteCount
    self.variableNameSHA256 = variableNameSHA256
    self.variableValueByteCount = variableValueByteCount
    self.variableValueSHA256 = variableValueSHA256
    self.variableDefinitionExpressionByteCount = variableDefinitionExpressionByteCount
    self.variableDefinitionExpressionSHA256 = variableDefinitionExpressionSHA256
    self.dependentExpressionByteCount = dependentExpressionByteCount
    self.dependentExpressionSHA256 = dependentExpressionSHA256
    self.verification = verification
  }
}

public struct NotesBodyMathVariableUpdateResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var structure: NotesBodyStructureRecord
  public var beforeDefinition: NotesBodyMathResultRecord
  public var afterDefinition: NotesBodyMathResultRecord
  public var beforeDependent: NotesBodyMathResultRecord
  public var afterDependent: NotesBodyMathResultRecord
  public var results: [NotesBodyMathResultRecord]
  public var requestedValueByteCount: Int
  public var requestedValueSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    structure: NotesBodyStructureRecord,
    beforeDefinition: NotesBodyMathResultRecord,
    afterDefinition: NotesBodyMathResultRecord,
    beforeDependent: NotesBodyMathResultRecord,
    afterDependent: NotesBodyMathResultRecord,
    results: [NotesBodyMathResultRecord],
    requestedValueByteCount: Int,
    requestedValueSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.structure = structure
    self.beforeDefinition = beforeDefinition
    self.afterDefinition = afterDefinition
    self.beforeDependent = beforeDependent
    self.afterDependent = afterDependent
    self.results = results
    self.requestedValueByteCount = requestedValueByteCount
    self.requestedValueSHA256 = requestedValueSHA256
    self.verification = verification
  }
}

public struct NotesBodyCollapsibleSetMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteSummary
  public var target: NotesBodyCollapsibleSectionRecord
  public var sections: [NotesBodyCollapsibleSectionRecord]
  public var structure: NotesBodyStructureRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteSummary,
    target: NotesBodyCollapsibleSectionRecord,
    sections: [NotesBodyCollapsibleSectionRecord],
    structure: NotesBodyStructureRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.target = target
    self.sections = sections
    self.structure = structure
    self.verification = verification
  }
}

public struct NotesNoteStateResponse: Codable, Equatable, Sendable {
  public var noteID: String
  public var state: NotesNoteStateRecord

  public init(noteID: String, state: NotesNoteStateRecord) {
    self.noteID = noteID
    self.state = state
  }
}

public struct NotesNoteLockabilityReasonRecord: Codable, Equatable, Sendable {
  public var reasonID: String
  public var status: String
  public var evidenceSource: String
  public var evidenceCount: Int?
  public var evidenceSHA256: String?

  public init(
    reasonID: String,
    status: String,
    evidenceSource: String,
    evidenceCount: Int? = nil,
    evidenceSHA256: String? = nil
  ) {
    self.reasonID = reasonID
    self.status = status
    self.evidenceSource = evidenceSource
    self.evidenceCount = evidenceCount
    self.evidenceSHA256 = evidenceSHA256
  }
}

public struct NotesNoteLockabilityResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteID: String
  public var noteIDSHA256: String
  public var privateFrameworkLockable: Bool
  public var isPasswordProtected: Bool
  public var isPasswordProtectedAndLocked: Bool?
  public var isEditable: Bool
  public var blockingReasonCount: Int
  public var unresolvedReasonCount: Int
  public var tagCount: Int
  public var tagSetSHA256: String?
  public var accountCanPasswordProtectNotes: Bool?
  public var accountCanHaveCryptoStrategy: Bool?
  public var accountIsInICloud: Bool?
  public var accountIsLocal: Bool?
  public var accountLockedNotesModeSHA256: String?
  public var accountResolvedLockedNotesModeSHA256: String?
  public var accountPasswordProtectedNoteCount: Int?
  public var attachmentCount: Int
  public var allowedAttachmentFamilyCounts: [String: Int]
  public var prohibitedAttachmentFamilyCounts: [String: Int]
  public var unknownAttachmentFamilyCount: Int
  public var reasons: [NotesNoteLockabilityReasonRecord]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteID: String,
    privateFrameworkLockable: Bool,
    isPasswordProtected: Bool,
    isPasswordProtectedAndLocked: Bool?,
    isEditable: Bool,
    blockingReasonCount: Int,
    unresolvedReasonCount: Int,
    tagCount: Int,
    tagSetSHA256: String?,
    accountCanPasswordProtectNotes: Bool? = nil,
    accountCanHaveCryptoStrategy: Bool? = nil,
    accountIsInICloud: Bool? = nil,
    accountIsLocal: Bool? = nil,
    accountLockedNotesModeSHA256: String? = nil,
    accountResolvedLockedNotesModeSHA256: String? = nil,
    accountPasswordProtectedNoteCount: Int? = nil,
    attachmentCount: Int,
    allowedAttachmentFamilyCounts: [String: Int],
    prohibitedAttachmentFamilyCounts: [String: Int],
    unknownAttachmentFamilyCount: Int,
    reasons: [NotesNoteLockabilityReasonRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteID = noteID
    self.noteIDSHA256 = sha256Hex(noteID)
    self.privateFrameworkLockable = privateFrameworkLockable
    self.isPasswordProtected = isPasswordProtected
    self.isPasswordProtectedAndLocked = isPasswordProtectedAndLocked
    self.isEditable = isEditable
    self.blockingReasonCount = blockingReasonCount
    self.unresolvedReasonCount = unresolvedReasonCount
    self.tagCount = tagCount
    self.tagSetSHA256 = tagSetSHA256
    self.accountCanPasswordProtectNotes = accountCanPasswordProtectNotes
    self.accountCanHaveCryptoStrategy = accountCanHaveCryptoStrategy
    self.accountIsInICloud = accountIsInICloud
    self.accountIsLocal = accountIsLocal
    self.accountLockedNotesModeSHA256 = accountLockedNotesModeSHA256
    self.accountResolvedLockedNotesModeSHA256 = accountResolvedLockedNotesModeSHA256
    self.accountPasswordProtectedNoteCount = accountPasswordProtectedNoteCount
    self.attachmentCount = attachmentCount
    self.allowedAttachmentFamilyCounts = allowedAttachmentFamilyCounts
    self.prohibitedAttachmentFamilyCounts = prohibitedAttachmentFamilyCounts
    self.unknownAttachmentFamilyCount = unknownAttachmentFamilyCount
    self.reasons = reasons
    self.verification = verification
  }
}

public struct NotesNoteActivityResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var activity: NotesNoteActivityRecord
  public var artifact: NotesNoteActivityArtifactRecord?
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    activity: NotesNoteActivityRecord,
    artifact: NotesNoteActivityArtifactRecord?,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.activity = activity
    self.artifact = artifact
    self.verification = verification
  }
}

public struct NotesNoteActivityRecord: Codable, Equatable, Sendable {
  public var noteID: String
  public var noteIDSHA256: String
  public var isShared: Bool
  public var isSharedReadOnly: Bool
  public var isSharedViaICloudFolder: Bool
  public var hasUnreadChanges: Bool?
  public var participantCount: Int
  public var participantUserIDSHA256s: [String]
  public var supportsActivityEvents: Bool?
  public var activityEventsPresent: Bool
  public var activityEventsByteCount: Int
  public var activityEventsSHA256: String?
  public var activityEventsDocumentPresent: Bool
  public var persistedActivityEventsStorageCount: Int?
  public var checklistActivityEventsStorageCount: Int?
  public var shareTimestampPresent: Bool
  public var shareTimestampSHA256: String?
  public var privacyBoundary: String

  public init(
    noteID: String,
    noteIDSHA256: String? = nil,
    isShared: Bool,
    isSharedReadOnly: Bool,
    isSharedViaICloudFolder: Bool,
    hasUnreadChanges: Bool?,
    participantCount: Int,
    participantUserIDSHA256s: [String],
    supportsActivityEvents: Bool?,
    activityEventsPresent: Bool,
    activityEventsByteCount: Int,
    activityEventsSHA256: String?,
    activityEventsDocumentPresent: Bool,
    persistedActivityEventsStorageCount: Int?,
    checklistActivityEventsStorageCount: Int?,
    shareTimestampPresent: Bool,
    shareTimestampSHA256: String?,
    privacyBoundary: String = "hashes_counts_and_booleans_only"
  ) {
    self.noteID = noteID
    self.noteIDSHA256 = noteIDSHA256 ?? sha256Hex(noteID)
    self.isShared = isShared
    self.isSharedReadOnly = isSharedReadOnly
    self.isSharedViaICloudFolder = isSharedViaICloudFolder
    self.hasUnreadChanges = hasUnreadChanges
    self.participantCount = participantCount
    self.participantUserIDSHA256s = participantUserIDSHA256s
    self.supportsActivityEvents = supportsActivityEvents
    self.activityEventsPresent = activityEventsPresent
    self.activityEventsByteCount = activityEventsByteCount
    self.activityEventsSHA256 = activityEventsSHA256
    self.activityEventsDocumentPresent = activityEventsDocumentPresent
    self.persistedActivityEventsStorageCount = persistedActivityEventsStorageCount
    self.checklistActivityEventsStorageCount = checklistActivityEventsStorageCount
    self.shareTimestampPresent = shareTimestampPresent
    self.shareTimestampSHA256 = shareTimestampSHA256
    self.privacyBoundary = privacyBoundary
  }
}

public struct NotesNoteActivityArtifactRecord: Codable, Equatable, Sendable {
  public var destinationPath: String
  public var byteCount: Int
  public var sha256: String

  public init(destinationPath: String, byteCount: Int, sha256: String) {
    self.destinationPath = destinationPath
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public struct NotesNoteStateAuditResponse: Codable, Equatable, Sendable {
  public var account: String?
  public var folder: String?
  public var summary: NotesNoteStateAuditSummary
  public var records: [NotesNoteStateRecord]
  public var returnedNoteCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    account: String?,
    folder: String?,
    summary: NotesNoteStateAuditSummary,
    records: [NotesNoteStateRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.account = account
    self.folder = folder
    self.summary = summary
    self.records = records
    self.returnedNoteCount = records.count
    self.verification = verification
  }
}

public struct NotesNoteStateAuditSummary: Codable, Equatable, Sendable {
  public var noteCount: Int
  public var deletedOrTrashCount: Int
  public var pinnedCount: Int
  public var pinnableCount: Int
  public var passwordProtectedCount: Int
  public var lockedCount: Int
  public var editableCount: Int
  public var lockableCount: Int
  public var sharedNoteCount: Int
  public var sharedFolderCount: Int
  public var sharedReadOnlyCount: Int
  public var systemPaperCount: Int
  public var mathNoteCount: Int
  public var callNoteCount: Int
  public var unreadChangesCount: Int
  public var unsupportedCount: Int
  public var needsCloudFetchCount: Int
  public var notesWithParticipantsCount: Int
  public var participantCount: Int
  public var folderTrashCount: Int
  public var folderDefaultCount: Int
  public var folderSharedReadOnlyCount: Int
  public var supportedReadFamilies: [String]
  public var gatedMutationFamilies: [String]

  public init(
    noteCount: Int,
    deletedOrTrashCount: Int,
    pinnedCount: Int,
    pinnableCount: Int,
    passwordProtectedCount: Int,
    lockedCount: Int,
    editableCount: Int,
    lockableCount: Int,
    sharedNoteCount: Int,
    sharedFolderCount: Int,
    sharedReadOnlyCount: Int,
    systemPaperCount: Int,
    mathNoteCount: Int,
    callNoteCount: Int,
    unreadChangesCount: Int,
    unsupportedCount: Int,
    needsCloudFetchCount: Int,
    notesWithParticipantsCount: Int,
    participantCount: Int,
    folderTrashCount: Int,
    folderDefaultCount: Int,
    folderSharedReadOnlyCount: Int,
    supportedReadFamilies: [String],
    gatedMutationFamilies: [String]
  ) {
    self.noteCount = noteCount
    self.deletedOrTrashCount = deletedOrTrashCount
    self.pinnedCount = pinnedCount
    self.pinnableCount = pinnableCount
    self.passwordProtectedCount = passwordProtectedCount
    self.lockedCount = lockedCount
    self.editableCount = editableCount
    self.lockableCount = lockableCount
    self.sharedNoteCount = sharedNoteCount
    self.sharedFolderCount = sharedFolderCount
    self.sharedReadOnlyCount = sharedReadOnlyCount
    self.systemPaperCount = systemPaperCount
    self.mathNoteCount = mathNoteCount
    self.callNoteCount = callNoteCount
    self.unreadChangesCount = unreadChangesCount
    self.unsupportedCount = unsupportedCount
    self.needsCloudFetchCount = needsCloudFetchCount
    self.notesWithParticipantsCount = notesWithParticipantsCount
    self.participantCount = participantCount
    self.folderTrashCount = folderTrashCount
    self.folderDefaultCount = folderDefaultCount
    self.folderSharedReadOnlyCount = folderSharedReadOnlyCount
    self.supportedReadFamilies = supportedReadFamilies
    self.gatedMutationFamilies = gatedMutationFamilies
  }
}

public struct NotesTagMutationWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var tag: NotesTagRecord

  public init(changed: Bool, note: NotesNoteDetail, tag: NotesTagRecord) {
    self.changed = changed
    self.note = note
    self.tag = tag
  }
}

public struct NotesTagConvertToTextDraft: Equatable, Sendable {
  public var noteID: String
  public var displayText: String
  public var standardizedContent: String
  public var matchedTagCount: Int
  public var wasPresentOnNote: Bool
  public var beforePlainTextByteCount: Int
  public var beforePlainTextSHA256: String

  public init(
    noteID: String,
    displayText: String,
    standardizedContent: String,
    matchedTagCount: Int,
    wasPresentOnNote: Bool,
    beforePlainTextByteCount: Int,
    beforePlainTextSHA256: String
  ) {
    self.noteID = noteID
    self.displayText = displayText
    self.standardizedContent = standardizedContent
    self.matchedTagCount = matchedTagCount
    self.wasPresentOnNote = wasPresentOnNote
    self.beforePlainTextByteCount = beforePlainTextByteCount
    self.beforePlainTextSHA256 = beforePlainTextSHA256
  }
}

public struct NotesTagConvertToTextWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var note: NotesNoteDetail
  public var tag: NotesTagRecord

  public init(changed: Bool, note: NotesNoteDetail, tag: NotesTagRecord) {
    self.changed = changed
    self.note = note
    self.tag = tag
  }
}

public struct NotesTagRenameDraft: Equatable, Sendable {
  public var currentDisplayText: String
  public var currentStandardizedContent: String
  public var newDisplayText: String
  public var newStandardizedContent: String
  public var matchedTagCount: Int
  public var targetMatchedTagCount: Int
  public var affectedNoteCount: Int
  public var allowMerge: Bool

  public init(
    currentDisplayText: String,
    currentStandardizedContent: String,
    newDisplayText: String,
    newStandardizedContent: String,
    matchedTagCount: Int,
    targetMatchedTagCount: Int,
    affectedNoteCount: Int,
    allowMerge: Bool = false
  ) {
    self.currentDisplayText = currentDisplayText
    self.currentStandardizedContent = currentStandardizedContent
    self.newDisplayText = newDisplayText
    self.newStandardizedContent = newStandardizedContent
    self.matchedTagCount = matchedTagCount
    self.targetMatchedTagCount = targetMatchedTagCount
    self.affectedNoteCount = affectedNoteCount
    self.allowMerge = allowMerge
  }
}

public struct NotesTagRenameWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var tag: NotesTagRecord
  public var affectedNotes: [NotesNoteDetail]

  public init(changed: Bool, tag: NotesTagRecord, affectedNotes: [NotesNoteDetail]) {
    self.changed = changed
    self.tag = tag
    self.affectedNotes = affectedNotes
  }
}

public struct NotesTagDeleteDraft: Equatable, Sendable {
  public var displayText: String
  public var standardizedContent: String
  public var matchedTagCount: Int
  public var affectedNoteCount: Int

  public init(
    displayText: String,
    standardizedContent: String,
    matchedTagCount: Int,
    affectedNoteCount: Int
  ) {
    self.displayText = displayText
    self.standardizedContent = standardizedContent
    self.matchedTagCount = matchedTagCount
    self.affectedNoteCount = affectedNoteCount
  }
}

public struct NotesTagDeleteWriteResult: Equatable, Sendable {
  public var changed: Bool
  public var tag: NotesTagRecord
  public var affectedNotes: [NotesNoteDetail]

  public init(changed: Bool, tag: NotesTagRecord, affectedNotes: [NotesNoteDetail]) {
    self.changed = changed
    self.tag = tag
    self.affectedNotes = affectedNotes
  }
}

public struct NotesSmartFolderTagCriteriaSnapshot: Equatable, Sendable {
  public var smartFolderID: String
  public var smartFolderIDSHA256: String
  public var queryPresent: Bool
  public var selectedTagCount: Int?
  public var tagIdentifiersSHA256: String?
  public var displayTextsSHA256: String?
  public var matchingNoteIDHashes: [String]
  public var matchingNoteCount: Int
  public var visibleNoteCount: Int?

  public init(
    smartFolderID: String,
    queryPresent: Bool,
    selectedTagCount: Int?,
    tagIdentifiersSHA256: String?,
    displayTextsSHA256: String?,
    matchingNoteIDHashes: [String],
    matchingNoteCount: Int,
    visibleNoteCount: Int?
  ) {
    self.smartFolderID = smartFolderID
    self.smartFolderIDSHA256 = sha256Hex(smartFolderID)
    self.queryPresent = queryPresent
    self.selectedTagCount = selectedTagCount
    self.tagIdentifiersSHA256 = tagIdentifiersSHA256
    self.displayTextsSHA256 = displayTextsSHA256
    self.matchingNoteIDHashes = matchingNoteIDHashes
    self.matchingNoteCount = matchingNoteCount
    self.visibleNoteCount = visibleNoteCount
  }
}

public struct NotesTagBatchDeleteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var deletedTagCount: Int
  public var affectedNoteCount: Int
  public var deletedTagHashes: [String]
  public var deletedTagIDHashes: [String]
  public var affectedNoteIDHashes: [String]
  public var perTagAffectedNoteCounts: [Int]
  public var verification: NotesMutationVerificationReport?

  public init(
    operation: String,
    changed: Bool,
    deletedTagCount: Int,
    affectedNoteCount: Int,
    deletedTagHashes: [String],
    deletedTagIDHashes: [String],
    affectedNoteIDHashes: [String],
    perTagAffectedNoteCounts: [Int],
    verification: NotesMutationVerificationReport? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.deletedTagCount = deletedTagCount
    self.affectedNoteCount = affectedNoteCount
    self.deletedTagHashes = deletedTagHashes
    self.deletedTagIDHashes = deletedTagIDHashes
    self.affectedNoteIDHashes = affectedNoteIDHashes
    self.perTagAffectedNoteCounts = perTagAffectedNoteCounts
    self.verification = verification
  }
}

public struct NotesMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteDetail?
  public var state: NotesNoteStateRecord?
  public var tag: NotesTagRecord?
  public var affectedNoteCount: Int?
  public var deletedID: String?
  public var verification: NotesMutationVerificationReport?

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteDetail? = nil,
    state: NotesNoteStateRecord? = nil,
    tag: NotesTagRecord? = nil,
    affectedNoteCount: Int? = nil,
    deletedID: String? = nil,
    verification: NotesMutationVerificationReport? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.state = state
    self.tag = tag
    self.affectedNoteCount = affectedNoteCount
    self.deletedID = deletedID
    self.verification = verification
  }
}

public struct NotesMarkdownImportAttachmentResult: Codable, Equatable, Sendable {
  public var relativePath: String
  public var filename: String
  public var byteCount: Int
  public var sha256: String
  public var attachment: NotesAttachmentRecord
  public var verification: NotesMutationVerificationReport

  public init(
    relativePath: String,
    filename: String,
    byteCount: Int,
    sha256: String,
    attachment: NotesAttachmentRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.relativePath = relativePath
    self.filename = filename
    self.byteCount = byteCount
    self.sha256 = sha256
    self.attachment = attachment
    self.verification = verification
  }
}

public struct NotesRichImportAttachmentResult: Codable, Equatable, Sendable {
  public var relativePath: String
  public var filename: String
  public var byteCount: Int
  public var sha256: String
  public var attachment: NotesAttachmentRecord
  public var verification: NotesMutationVerificationReport

  public init(
    relativePath: String,
    filename: String,
    byteCount: Int,
    sha256: String,
    attachment: NotesAttachmentRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.relativePath = relativePath
    self.filename = filename
    self.byteCount = byteCount
    self.sha256 = sha256
    self.attachment = attachment
    self.verification = verification
  }
}

public struct NotesMarkdownSemanticSummary: Codable, Equatable, Sendable {
  public var headingCount: Int
  public var unorderedListItemCount: Int
  public var orderedListItemCount: Int
  public var blockQuoteLineCount: Int
  public var fencedCodeBlockCount: Int
  public var inlineCodeSpanCount: Int
  public var linkReferenceCount: Int
  public var imageReferenceCount: Int
  public var emphasizedSpanCount: Int

  public var listItemCount: Int { unorderedListItemCount + orderedListItemCount }

  public init(
    headingCount: Int = 0,
    unorderedListItemCount: Int = 0,
    orderedListItemCount: Int = 0,
    blockQuoteLineCount: Int = 0,
    fencedCodeBlockCount: Int = 0,
    inlineCodeSpanCount: Int = 0,
    linkReferenceCount: Int = 0,
    imageReferenceCount: Int = 0,
    emphasizedSpanCount: Int = 0
  ) {
    self.headingCount = headingCount
    self.unorderedListItemCount = unorderedListItemCount
    self.orderedListItemCount = orderedListItemCount
    self.blockQuoteLineCount = blockQuoteLineCount
    self.fencedCodeBlockCount = fencedCodeBlockCount
    self.inlineCodeSpanCount = inlineCodeSpanCount
    self.linkReferenceCount = linkReferenceCount
    self.imageReferenceCount = imageReferenceCount
    self.emphasizedSpanCount = emphasizedSpanCount
  }
}

public struct NotesMarkdownImportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteDetail
  public var isPackage: Bool
  public var markdownRelativePath: String?
  public var sourceByteCount: Int
  public var sourceSHA256: String
  public var resourceCount: Int
  public var packageFileCount: Int?
  public var packageTotalByteCount: Int?
  public var packageTreeSHA256: String?
  public var semanticSummary: NotesMarkdownSemanticSummary
  public var importedPlainTextLength: Int
  public var importedPlainTextSHA256: String
  public var attributedRunCount: Int
  public var attachments: [NotesMarkdownImportAttachmentResult]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteDetail,
    isPackage: Bool,
    markdownRelativePath: String? = nil,
    sourceByteCount: Int,
    sourceSHA256: String,
    resourceCount: Int,
    packageFileCount: Int? = nil,
    packageTotalByteCount: Int? = nil,
    packageTreeSHA256: String? = nil,
    semanticSummary: NotesMarkdownSemanticSummary = NotesMarkdownSemanticSummary(),
    importedPlainTextLength: Int = 0,
    importedPlainTextSHA256: String = "",
    attributedRunCount: Int = 0,
    attachments: [NotesMarkdownImportAttachmentResult] = [],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.isPackage = isPackage
    self.markdownRelativePath = markdownRelativePath
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.resourceCount = resourceCount
    self.packageFileCount = packageFileCount
    self.packageTotalByteCount = packageTotalByteCount
    self.packageTreeSHA256 = packageTreeSHA256
    self.semanticSummary = semanticSummary
    self.importedPlainTextLength = importedPlainTextLength
    self.importedPlainTextSHA256 = importedPlainTextSHA256
    self.attributedRunCount = attributedRunCount
    self.attachments = attachments
    self.verification = verification
  }
}

public struct NotesRichImportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteDetail
  public var formatFamily: String
  public var sourceByteCount: Int
  public var sourceSHA256: String?
  public var importedPlainTextLength: Int
  public var importedPlainTextSHA256: String
  public var attributedRunCount: Int
  public var attachmentRunCount: Int
  public var htmlRelativePath: String?
  public var resourceCount: Int
  public var packageFileCount: Int?
  public var packageResourceFileCount: Int?
  public var packageTotalByteCount: Int?
  public var packageTreeSHA256: String?
  public var attachments: [NotesRichImportAttachmentResult]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteDetail,
    formatFamily: String,
    sourceByteCount: Int,
    sourceSHA256: String? = nil,
    importedPlainTextLength: Int,
    importedPlainTextSHA256: String,
    attributedRunCount: Int,
    attachmentRunCount: Int,
    htmlRelativePath: String? = nil,
    resourceCount: Int = 0,
    packageFileCount: Int? = nil,
    packageResourceFileCount: Int? = nil,
    packageTotalByteCount: Int? = nil,
    packageTreeSHA256: String? = nil,
    attachments: [NotesRichImportAttachmentResult] = [],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.formatFamily = formatFamily
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.importedPlainTextLength = importedPlainTextLength
    self.importedPlainTextSHA256 = importedPlainTextSHA256
    self.attributedRunCount = attributedRunCount
    self.attachmentRunCount = attachmentRunCount
    self.htmlRelativePath = htmlRelativePath
    self.resourceCount = resourceCount
    self.packageFileCount = packageFileCount
    self.packageResourceFileCount = packageResourceFileCount
    self.packageTotalByteCount = packageTotalByteCount
    self.packageTreeSHA256 = packageTreeSHA256
    self.attachments = attachments
    self.verification = verification
  }
}

public struct NotesRichReplaceAttachmentResult: Codable, Equatable, Sendable {
  public var relativePath: String
  public var filename: String
  public var byteCount: Int
  public var sha256: String
  public var inlineReferenceCount: Int
  public var inlinePlacementCount: Int
  public var attachment: NotesAttachmentRecord
  public var verification: NotesMutationVerificationReport

  public init(
    relativePath: String,
    filename: String,
    byteCount: Int,
    sha256: String,
    inlineReferenceCount: Int,
    inlinePlacementCount: Int,
    attachment: NotesAttachmentRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.relativePath = relativePath
    self.filename = filename
    self.byteCount = byteCount
    self.sha256 = sha256
    self.inlineReferenceCount = inlineReferenceCount
    self.inlinePlacementCount = inlinePlacementCount
    self.attachment = attachment
    self.verification = verification
  }
}

public struct NotesRichReplaceResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var note: NotesNoteDetail
  public var formatFamily: String
  public var sourceByteCount: Int
  public var sourceSHA256: String?
  public var importedPlainTextLength: Int
  public var importedPlainTextSHA256: String
  public var attributedRunCount: Int
  public var attachmentRunCount: Int
  public var resourceCount: Int
  public var inlineReferenceCount: Int
  public var inlinePlacementCount: Int
  public var packageFileCount: Int?
  public var packageResourceFileCount: Int?
  public var packageTotalByteCount: Int?
  public var packageTreeSHA256: String?
  public var markdownRelativePath: String?
  public var htmlRelativePath: String?
  public var semanticSummary: NotesMarkdownSemanticSummary?
  public var attachments: [NotesRichReplaceAttachmentResult]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    note: NotesNoteDetail,
    formatFamily: String,
    sourceByteCount: Int,
    sourceSHA256: String? = nil,
    importedPlainTextLength: Int,
    importedPlainTextSHA256: String,
    attributedRunCount: Int,
    attachmentRunCount: Int,
    resourceCount: Int = 0,
    inlineReferenceCount: Int = 0,
    inlinePlacementCount: Int = 0,
    packageFileCount: Int? = nil,
    packageResourceFileCount: Int? = nil,
    packageTotalByteCount: Int? = nil,
    packageTreeSHA256: String? = nil,
    markdownRelativePath: String? = nil,
    htmlRelativePath: String? = nil,
    semanticSummary: NotesMarkdownSemanticSummary? = nil,
    attachments: [NotesRichReplaceAttachmentResult] = [],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.note = note
    self.formatFamily = formatFamily
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.importedPlainTextLength = importedPlainTextLength
    self.importedPlainTextSHA256 = importedPlainTextSHA256
    self.attributedRunCount = attributedRunCount
    self.attachmentRunCount = attachmentRunCount
    self.resourceCount = resourceCount
    self.inlineReferenceCount = inlineReferenceCount
    self.inlinePlacementCount = inlinePlacementCount
    self.packageFileCount = packageFileCount
    self.packageResourceFileCount = packageResourceFileCount
    self.packageTotalByteCount = packageTotalByteCount
    self.packageTreeSHA256 = packageTreeSHA256
    self.markdownRelativePath = markdownRelativePath
    self.htmlRelativePath = htmlRelativePath
    self.semanticSummary = semanticSummary
    self.attachments = attachments
    self.verification = verification
  }
}

public struct NotesAttachmentCopyResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourceNoteIDSHA256: String
  public var targetNoteID: String
  public var targetNoteIDSHA256: String
  public var sourceAttachmentIDSHA256: String
  public var attachment: NotesAttachmentRecord
  public var filename: String
  public var byteCount: Int
  public var sha256: String
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    sourceNoteIDSHA256: String,
    targetNoteID: String,
    targetNoteIDSHA256: String,
    sourceAttachmentIDSHA256: String,
    attachment: NotesAttachmentRecord,
    filename: String,
    byteCount: Int,
    sha256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.sourceNoteIDSHA256 = sourceNoteIDSHA256
    self.targetNoteID = targetNoteID
    self.targetNoteIDSHA256 = targetNoteIDSHA256
    self.sourceAttachmentIDSHA256 = sourceAttachmentIDSHA256
    self.attachment = attachment
    self.filename = filename
    self.byteCount = byteCount
    self.sha256 = sha256
    self.verification = verification
  }
}

public struct NotesENEXImportAttachmentResult: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var filename: String
  public var mimeType: String?
  public var byteCount: Int
  public var sha256: String
  public var inlineReferenceCount: Int
  public var inlinePlacementCount: Int
  public var attachment: NotesAttachmentRecord

  public init(
    ordinal: Int,
    filename: String,
    mimeType: String? = nil,
    byteCount: Int,
    sha256: String,
    inlineReferenceCount: Int = 0,
    inlinePlacementCount: Int = 0,
    attachment: NotesAttachmentRecord
  ) {
    self.ordinal = ordinal
    self.filename = filename
    self.mimeType = mimeType
    self.byteCount = byteCount
    self.sha256 = sha256
    self.inlineReferenceCount = inlineReferenceCount
    self.inlinePlacementCount = inlinePlacementCount
    self.attachment = attachment
  }
}

public struct NotesENEXImportedNoteResult: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var note: NotesNoteDetail
  public var sourceTitleSHA256: String
  public var sourceContentSHA256: String
  public var importedPlainTextLength: Int
  public var importedPlainTextSHA256: String
  public var tagCount: Int
  public var resourceCount: Int
  public var resourceByteCount: Int
  public var inlineResourceReferenceCount: Int
  public var matchedInlineResourceReferenceCount: Int
  public var placedInlineResourceReferenceCount: Int
  public var attachments: [NotesENEXImportAttachmentResult]
  public var createdAtPreserved: Bool?
  public var updatedAtPreserved: Bool?

  public init(
    ordinal: Int,
    note: NotesNoteDetail,
    sourceTitleSHA256: String,
    sourceContentSHA256: String,
    importedPlainTextLength: Int,
    importedPlainTextSHA256: String,
    tagCount: Int,
    resourceCount: Int,
    resourceByteCount: Int = 0,
    inlineResourceReferenceCount: Int = 0,
    matchedInlineResourceReferenceCount: Int = 0,
    placedInlineResourceReferenceCount: Int = 0,
    attachments: [NotesENEXImportAttachmentResult] = [],
    createdAtPreserved: Bool? = nil,
    updatedAtPreserved: Bool? = nil
  ) {
    self.ordinal = ordinal
    self.note = note
    self.sourceTitleSHA256 = sourceTitleSHA256
    self.sourceContentSHA256 = sourceContentSHA256
    self.importedPlainTextLength = importedPlainTextLength
    self.importedPlainTextSHA256 = importedPlainTextSHA256
    self.tagCount = tagCount
    self.resourceCount = resourceCount
    self.resourceByteCount = resourceByteCount
    self.inlineResourceReferenceCount = inlineResourceReferenceCount
    self.matchedInlineResourceReferenceCount = matchedInlineResourceReferenceCount
    self.placedInlineResourceReferenceCount = placedInlineResourceReferenceCount
    self.attachments = attachments
    self.createdAtPreserved = createdAtPreserved
    self.updatedAtPreserved = updatedAtPreserved
  }
}

public struct NotesENEXImportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var importedNoteCount: Int
  public var sourceByteCount: Int
  public var sourceSHA256: String
  public var tagCount: Int
  public var uniqueTagCount: Int
  public var normalizedTagCount: Int
  public var resourceCount: Int
  public var resourceByteCount: Int
  public var inlineResourceReferenceCount: Int
  public var matchedInlineResourceReferenceCount: Int
  public var placedInlineResourceReferenceCount: Int
  public var createdDateCount: Int
  public var updatedDateCount: Int
  public var importedNotes: [NotesENEXImportedNoteResult]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    importedNoteCount: Int,
    sourceByteCount: Int,
    sourceSHA256: String,
    tagCount: Int,
    uniqueTagCount: Int,
    normalizedTagCount: Int = 0,
    resourceCount: Int,
    resourceByteCount: Int = 0,
    inlineResourceReferenceCount: Int = 0,
    matchedInlineResourceReferenceCount: Int = 0,
    placedInlineResourceReferenceCount: Int = 0,
    createdDateCount: Int,
    updatedDateCount: Int,
    importedNotes: [NotesENEXImportedNoteResult],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.importedNoteCount = importedNoteCount
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.tagCount = tagCount
    self.uniqueTagCount = uniqueTagCount
    self.normalizedTagCount = normalizedTagCount
    self.resourceCount = resourceCount
    self.resourceByteCount = resourceByteCount
    self.inlineResourceReferenceCount = inlineResourceReferenceCount
    self.matchedInlineResourceReferenceCount = matchedInlineResourceReferenceCount
    self.placedInlineResourceReferenceCount = placedInlineResourceReferenceCount
    self.createdDateCount = createdDateCount
    self.updatedDateCount = updatedDateCount
    self.importedNotes = importedNotes
    self.verification = verification
  }
}

public struct NotesFolderImportFolderResult: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var relativePathSHA256: String
  public var parentRelativePathSHA256: String?
  public var folderIDSHA256: String
  public var nameSHA256: String
  public var nameLength: Int
  public var depth: Int
  public var verification: NotesMutationVerificationReport

  public init(
    ordinal: Int,
    relativePathSHA256: String,
    parentRelativePathSHA256: String? = nil,
    folderIDSHA256: String,
    nameSHA256: String,
    nameLength: Int,
    depth: Int,
    verification: NotesMutationVerificationReport
  ) {
    self.ordinal = ordinal
    self.relativePathSHA256 = relativePathSHA256
    self.parentRelativePathSHA256 = parentRelativePathSHA256
    self.folderIDSHA256 = folderIDSHA256
    self.nameSHA256 = nameSHA256
    self.nameLength = nameLength
    self.depth = depth
    self.verification = verification
  }
}

public struct NotesFolderImportFileResult: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var relativePathSHA256: String
  public var folderRelativePathSHA256: String?
  public var formatFamily: String
  public var sourceByteCount: Int
  public var importedNoteCount: Int
  public var resourceCount: Int
  public var noteIDsSHA256: String
  public var verification: NotesMutationVerificationReport

  public init(
    ordinal: Int,
    relativePathSHA256: String,
    folderRelativePathSHA256: String? = nil,
    formatFamily: String,
    sourceByteCount: Int,
    importedNoteCount: Int,
    resourceCount: Int = 0,
    noteIDsSHA256: String,
    verification: NotesMutationVerificationReport
  ) {
    self.ordinal = ordinal
    self.relativePathSHA256 = relativePathSHA256
    self.folderRelativePathSHA256 = folderRelativePathSHA256
    self.formatFamily = formatFamily
    self.sourceByteCount = sourceByteCount
    self.importedNoteCount = importedNoteCount
    self.resourceCount = resourceCount
    self.noteIDsSHA256 = noteIDsSHA256
    self.verification = verification
  }
}

public struct NotesFolderImportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePathSHA256: String
  public var sourceNameSHA256: String
  public var sourceTreeSHA256: String
  public var sourceTotalByteCount: Int
  public var createdFolderCount: Int
  public var sourceDirectoryCount: Int
  public var importedFileCount: Int
  public var importedNoteCount: Int
  public var resourceCount: Int
  public var formatFamilyCounts: [String: Int]
  public var folders: [NotesFolderImportFolderResult]
  public var files: [NotesFolderImportFileResult]
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    sourcePathSHA256: String,
    sourceNameSHA256: String,
    sourceTreeSHA256: String,
    sourceTotalByteCount: Int,
    createdFolderCount: Int,
    sourceDirectoryCount: Int,
    importedFileCount: Int,
    importedNoteCount: Int,
    resourceCount: Int,
    formatFamilyCounts: [String: Int],
    folders: [NotesFolderImportFolderResult],
    files: [NotesFolderImportFileResult],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.sourcePathSHA256 = sourcePathSHA256
    self.sourceNameSHA256 = sourceNameSHA256
    self.sourceTreeSHA256 = sourceTreeSHA256
    self.sourceTotalByteCount = sourceTotalByteCount
    self.createdFolderCount = createdFolderCount
    self.sourceDirectoryCount = sourceDirectoryCount
    self.importedFileCount = importedFileCount
    self.importedNoteCount = importedNoteCount
    self.resourceCount = resourceCount
    self.formatFamilyCounts = formatFamilyCounts
    self.folders = folders
    self.files = files
    self.verification = verification
  }
}

public struct NotesWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesWorkflowAuditSummary
  public var records: [NotesWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesWorkflowAuditSummary,
    records: [NotesWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesSearchAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesSearchAuditSummary
  public var records: [NotesSearchAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesSearchAuditSummary,
    records: [NotesSearchAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesSearchAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var queryRequiredForExecution: Bool
  public var auditRequiresQuery: Bool
  public var backendCalls: String
  public var supportedSearchFamilies: [String]
  public var delegatedSearchFamilies: [String]
  public var gatedSearchFamilies: [String]
  public var rejectedSearchFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    queryRequiredForExecution: Bool,
    auditRequiresQuery: Bool,
    backendCalls: String,
    supportedSearchFamilies: [String],
    delegatedSearchFamilies: [String],
    gatedSearchFamilies: [String],
    rejectedSearchFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.queryRequiredForExecution = queryRequiredForExecution
    self.auditRequiresQuery = auditRequiresQuery
    self.backendCalls = backendCalls
    self.supportedSearchFamilies = supportedSearchFamilies
    self.delegatedSearchFamilies = delegatedSearchFamilies
    self.gatedSearchFamilies = gatedSearchFamilies
    self.rejectedSearchFamilies = rejectedSearchFamilies
  }
}

public struct NotesSearchAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var searchFamily: String
  public var scope: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var queryRequired: Bool
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    searchFamily: String,
    scope: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    queryRequired: Bool,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.searchFamily = searchFamily
    self.scope = scope
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.queryRequired = queryRequired
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesAudioWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesAudioWorkflowAuditSummary
  public var records: [NotesAudioWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesAudioWorkflowAuditSummary,
    records: [NotesAudioWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesAudioWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesAudioWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesCollaborationWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesCollaborationWorkflowAuditSummary
  public var records: [NotesCollaborationWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesCollaborationWorkflowAuditSummary,
    records: [NotesCollaborationWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesCollaborationWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesCollaborationWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesSecurityWorkflowAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var summary: NotesSecurityWorkflowAuditSummary
  public var records: [NotesSecurityWorkflowAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    summary: NotesSecurityWorkflowAuditSummary,
    records: [NotesSecurityWorkflowAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesSecurityWorkflowAuditSummary: Codable, Equatable, Sendable {
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var auditRequiresSelector: Bool
  public var backendCalls: String
  public var supportedWorkflowFamilies: [String]
  public var delegatedWorkflowFamilies: [String]
  public var gatedWorkflowFamilies: [String]
  public var rejectedWorkflowFamilies: [String]

  public init(
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int,
    auditRequiresSelector: Bool,
    backendCalls: String,
    supportedWorkflowFamilies: [String],
    delegatedWorkflowFamilies: [String],
    gatedWorkflowFamilies: [String],
    rejectedWorkflowFamilies: [String]
  ) {
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.auditRequiresSelector = auditRequiresSelector
    self.backendCalls = backendCalls
    self.supportedWorkflowFamilies = supportedWorkflowFamilies
    self.delegatedWorkflowFamilies = delegatedWorkflowFamilies
    self.gatedWorkflowFamilies = gatedWorkflowFamilies
    self.rejectedWorkflowFamilies = rejectedWorkflowFamilies
  }
}

public struct NotesSecurityWorkflowAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var workflowFamily: String
  public var guideSection: String
  public var status: String
  public var appleCapability: String
  public var command: String
  public var implementationMechanism: String
  public var requiredImplementation: String
  public var requiredVerifier: String
  public var safetyGate: String?
  public var backendCalls: String
  public var privacyBoundary: String
  public var reason: String

  public init(
    ordinal: Int,
    workflowFamily: String,
    guideSection: String,
    status: String,
    appleCapability: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    safetyGate: String? = nil,
    backendCalls: String,
    privacyBoundary: String,
    reason: String
  ) {
    self.ordinal = ordinal
    self.workflowFamily = workflowFamily
    self.guideSection = guideSection
    self.status = status
    self.appleCapability = appleCapability
    self.command = command
    self.implementationMechanism = implementationMechanism
    self.requiredImplementation = requiredImplementation
    self.requiredVerifier = requiredVerifier
    self.safetyGate = safetyGate
    self.backendCalls = backendCalls
    self.privacyBoundary = privacyBoundary
    self.reason = reason
  }
}

public struct NotesExportAuditResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var noteIDSHA256: String
  public var titleSHA256: String
  public var summary: NotesExportAuditSummary
  public var records: [NotesExportAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    noteIDSHA256: String,
    titleSHA256: String,
    summary: NotesExportAuditSummary,
    records: [NotesExportAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.noteIDSHA256 = noteIDSHA256
    self.titleSHA256 = titleSHA256
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesExportAuditSummary: Codable, Equatable, Sendable {
  public var selectedNoteStatus: String
  public var noteIsDeletedOrInTrash: Bool
  public var noteIsPasswordProtected: Bool
  public var noteIsPasswordProtectedAndLocked: Bool?
  public var noteIsEditable: Bool
  public var noteIsSharedReadOnly: Bool
  public var supportedRecordCount: Int
  public var delegatedRecordCount: Int
  public var gatedRecordCount: Int
  public var rejectedRecordCount: Int
  public var artifactActionRequired: Bool
  public var externalDispatchRequired: Bool
  public var supportedExportFamilies: [String]
  public var delegatedExportFamilies: [String]
  public var gatedExportFamilies: [String]
  public var rejectedExportFamilies: [String]

  public init(
    selectedNoteStatus: String,
    noteIsDeletedOrInTrash: Bool,
    noteIsPasswordProtected: Bool,
    noteIsPasswordProtectedAndLocked: Bool?,
    noteIsEditable: Bool,
    noteIsSharedReadOnly: Bool,
    supportedRecordCount: Int,
    delegatedRecordCount: Int,
    gatedRecordCount: Int,
    rejectedRecordCount: Int = 0,
    artifactActionRequired: Bool,
    externalDispatchRequired: Bool,
    supportedExportFamilies: [String],
    delegatedExportFamilies: [String],
    gatedExportFamilies: [String],
    rejectedExportFamilies: [String] = []
  ) {
    self.selectedNoteStatus = selectedNoteStatus
    self.noteIsDeletedOrInTrash = noteIsDeletedOrInTrash
    self.noteIsPasswordProtected = noteIsPasswordProtected
    self.noteIsPasswordProtectedAndLocked = noteIsPasswordProtectedAndLocked
    self.noteIsEditable = noteIsEditable
    self.noteIsSharedReadOnly = noteIsSharedReadOnly
    self.supportedRecordCount = supportedRecordCount
    self.delegatedRecordCount = delegatedRecordCount
    self.gatedRecordCount = gatedRecordCount
    self.rejectedRecordCount = rejectedRecordCount
    self.artifactActionRequired = artifactActionRequired
    self.externalDispatchRequired = externalDispatchRequired
    self.supportedExportFamilies = supportedExportFamilies
    self.delegatedExportFamilies = delegatedExportFamilies
    self.gatedExportFamilies = gatedExportFamilies
    self.rejectedExportFamilies = rejectedExportFamilies
  }
}

public struct NotesExportAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var formatFamily: String
  public var command: String
  public var exportStatus: String
  public var artifactKind: String
  public var requiresArtifactAction: Bool
  public var requiresExternalDispatch: Bool
  public var noteStateGate: String?
  public var reason: String

  public init(
    ordinal: Int,
    formatFamily: String,
    command: String,
    exportStatus: String,
    artifactKind: String,
    requiresArtifactAction: Bool,
    requiresExternalDispatch: Bool,
    noteStateGate: String? = nil,
    reason: String
  ) {
    self.ordinal = ordinal
    self.formatFamily = formatFamily
    self.command = command
    self.exportStatus = exportStatus
    self.artifactKind = artifactKind
    self.requiresArtifactAction = requiresArtifactAction
    self.requiresExternalDispatch = requiresExternalDispatch
    self.noteStateGate = noteStateGate
    self.reason = reason
  }
}

public struct NotesImportAuditResponse: Codable, Equatable, Sendable {
  public var summary: NotesImportAuditSummary
  public var records: [NotesImportAuditRecord]
  public var returnedRecordCount: Int
  public var verification: NotesMutationVerificationReport

  public init(
    summary: NotesImportAuditSummary,
    records: [NotesImportAuditRecord],
    verification: NotesMutationVerificationReport
  ) {
    self.summary = summary
    self.records = records
    self.returnedRecordCount = records.count
    self.verification = verification
  }
}

public struct NotesImportAuditSummary: Codable, Equatable, Sendable {
  public var sourceKind: String
  public var scannedItemCount: Int
  public var regularFileCount: Int
  public var directoryCount: Int
  public var supportedTextCount: Int
  public var supportedMarkdownCount: Int
  public var supportedMarkdownPackageCount: Int
  public var supportedRichFormatCount: Int
  public var gatedRichFormatCount: Int
  public var supportedENEXCount: Int
  public var gatedENEXCount: Int
  public var unsupportedCount: Int
  public var folderImportRequested: Bool
  public var preserveFolderStructureStatus: String
  public var enexTagImportStatus: String
  public var supportedImportFamilies: [String]
  public var gatedImportFamilies: [String]
  public var delegatedImportFamilies: [String]
  public var rejectedImportFamilies: [String]

  public init(
    sourceKind: String,
    scannedItemCount: Int,
    regularFileCount: Int,
    directoryCount: Int,
    supportedTextCount: Int,
    supportedMarkdownCount: Int,
    supportedMarkdownPackageCount: Int,
    supportedRichFormatCount: Int = 0,
    gatedRichFormatCount: Int,
    supportedENEXCount: Int = 0,
    gatedENEXCount: Int,
    unsupportedCount: Int,
    folderImportRequested: Bool,
    preserveFolderStructureStatus: String,
    enexTagImportStatus: String,
    supportedImportFamilies: [String],
    gatedImportFamilies: [String],
    delegatedImportFamilies: [String] = [],
    rejectedImportFamilies: [String] = []
  ) {
    self.sourceKind = sourceKind
    self.scannedItemCount = scannedItemCount
    self.regularFileCount = regularFileCount
    self.directoryCount = directoryCount
    self.supportedTextCount = supportedTextCount
    self.supportedMarkdownCount = supportedMarkdownCount
    self.supportedMarkdownPackageCount = supportedMarkdownPackageCount
    self.supportedRichFormatCount = supportedRichFormatCount
    self.gatedRichFormatCount = gatedRichFormatCount
    self.supportedENEXCount = supportedENEXCount
    self.gatedENEXCount = gatedENEXCount
    self.unsupportedCount = unsupportedCount
    self.folderImportRequested = folderImportRequested
    self.preserveFolderStructureStatus = preserveFolderStructureStatus
    self.enexTagImportStatus = enexTagImportStatus
    self.supportedImportFamilies = supportedImportFamilies
    self.gatedImportFamilies = gatedImportFamilies
    self.delegatedImportFamilies = delegatedImportFamilies
    self.rejectedImportFamilies = rejectedImportFamilies
  }
}

public struct NotesImportAuditRecord: Codable, Equatable, Sendable {
  public var ordinal: Int
  public var sourceKind: String
  public var pathSHA256: String
  public var nameSHA256: String
  public var extensionName: String?
  public var byteCount: Int?
  public var formatFamily: String
  public var importStatus: String
  public var reason: String
  public var isDirectory: Bool

  public init(
    ordinal: Int,
    sourceKind: String,
    pathSHA256: String,
    nameSHA256: String,
    extensionName: String? = nil,
    byteCount: Int? = nil,
    formatFamily: String,
    importStatus: String,
    reason: String,
    isDirectory: Bool
  ) {
    self.ordinal = ordinal
    self.sourceKind = sourceKind
    self.pathSHA256 = pathSHA256
    self.nameSHA256 = nameSHA256
    self.extensionName = extensionName
    self.byteCount = byteCount
    self.formatFamily = formatFamily
    self.importStatus = importStatus
    self.reason = reason
    self.isDirectory = isDirectory
  }
}

public struct NotesFolderMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var folder: NotesFolderRecord?
  public var deletedID: String?
  public var verification: NotesMutationVerificationReport?

  public init(
    operation: String,
    changed: Bool,
    folder: NotesFolderRecord? = nil,
    deletedID: String? = nil,
    verification: NotesMutationVerificationReport? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.folder = folder
    self.deletedID = deletedID
    self.verification = verification
  }
}

public struct NotesSmartFolderMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var smartFolder: NotesSmartFolderRecord?
  public var sourceSmartFolder: NotesSmartFolderRecord?
  public var deletedID: String?
  public var tag: NotesTagRecord?
  public var criteriaKind: String?
  public var criteriaKinds: [String]?
  public var matchingNoteCount: Int?
  public var sourceMatchingNoteCount: Int?
  public var sourceByteCount: Int?
  public var sourceSHA256: String?
  public var convertedFolderID: String?
  public var convertedFolderName: String?
  public var targetFolderID: String?
  public var targetFolderName: String?
  public var movedNoteCount: Int?
  public var taggedNoteCount: Int?
  public var noteIDHashes: [String]?
  public var verification: NotesMutationVerificationReport?

  public init(
    operation: String,
    changed: Bool,
    smartFolder: NotesSmartFolderRecord? = nil,
    sourceSmartFolder: NotesSmartFolderRecord? = nil,
    deletedID: String? = nil,
    tag: NotesTagRecord? = nil,
    criteriaKind: String? = nil,
    criteriaKinds: [String]? = nil,
    matchingNoteCount: Int? = nil,
    sourceMatchingNoteCount: Int? = nil,
    sourceByteCount: Int? = nil,
    sourceSHA256: String? = nil,
    convertedFolderID: String? = nil,
    convertedFolderName: String? = nil,
    targetFolderID: String? = nil,
    targetFolderName: String? = nil,
    movedNoteCount: Int? = nil,
    taggedNoteCount: Int? = nil,
    noteIDHashes: [String]? = nil,
    verification: NotesMutationVerificationReport? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.smartFolder = smartFolder
    self.sourceSmartFolder = sourceSmartFolder
    self.deletedID = deletedID
    self.tag = tag
    self.criteriaKind = criteriaKind
    self.criteriaKinds = criteriaKinds
    self.matchingNoteCount = matchingNoteCount
    self.sourceMatchingNoteCount = sourceMatchingNoteCount
    self.sourceByteCount = sourceByteCount
    self.sourceSHA256 = sourceSHA256
    self.convertedFolderID = convertedFolderID
    self.convertedFolderName = convertedFolderName
    self.targetFolderID = targetFolderID
    self.targetFolderName = targetFolderName
    self.movedNoteCount = movedNoteCount
    self.taggedNoteCount = taggedNoteCount
    self.noteIDHashes = noteIDHashes
    self.verification = verification
  }
}

public struct NotesBulkMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var affectedNoteCount: Int
  public var affectedIDHashes: [String]
  public var createdIDHashes: [String]
  public var deletedIDHashes: [String]
  public var restoredIDHashes: [String]
  public var targetFolderName: String?
  public var targetAccountName: String?
  public var targetPinned: Bool?
  public var verification: NotesMutationVerificationReport?

  public init(
    operation: String,
    changed: Bool,
    affectedNoteCount: Int,
    affectedIDHashes: [String] = [],
    createdIDHashes: [String] = [],
    deletedIDHashes: [String] = [],
    restoredIDHashes: [String] = [],
    targetFolderName: String? = nil,
    targetAccountName: String? = nil,
    targetPinned: Bool? = nil,
    verification: NotesMutationVerificationReport? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.affectedNoteCount = affectedNoteCount
    self.affectedIDHashes = affectedIDHashes
    self.createdIDHashes = createdIDHashes
    self.deletedIDHashes = deletedIDHashes
    self.restoredIDHashes = restoredIDHashes
    self.targetFolderName = targetFolderName
    self.targetAccountName = targetAccountName
    self.targetPinned = targetPinned
    self.verification = verification
  }
}

public struct NotesCreateDraft: Codable, Equatable, Sendable {
  public var folderId: String
  public var folderName: String
  public var accountName: String
  public var title: String
  public var body: String
  public var isSystemPaper: Bool

  public init(
    folderId: String,
    folderName: String,
    accountName: String,
    title: String,
    body: String,
    isSystemPaper: Bool = false
  ) {
    self.folderId = folderId
    self.folderName = folderName
    self.accountName = accountName
    self.title = title
    self.body = body
    self.isSystemPaper = isSystemPaper
  }
}

public struct NotesFolderCreateDraft: Codable, Equatable, Sendable {
  public var name: String
  public var accountID: String?
  public var accountName: String
  public var parentID: String?
  public var parentName: String?

  public init(
    name: String,
    accountID: String?,
    accountName: String,
    parentID: String? = nil,
    parentName: String? = nil
  ) {
    self.name = name
    self.accountID = accountID
    self.accountName = accountName
    self.parentID = parentID
    self.parentName = parentName
  }
}

public struct NotesFolderRenameDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var currentName: String
  public var accountName: String
  public var parentID: String?
  public var parentName: String?
  public var name: String

  public init(
    folderID: String,
    currentName: String,
    accountName: String,
    parentID: String? = nil,
    parentName: String? = nil,
    name: String
  ) {
    self.folderID = folderID
    self.currentName = currentName
    self.accountName = accountName
    self.parentID = parentID
    self.parentName = parentName
    self.name = name
  }
}

public struct NotesFolderMoveDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var name: String
  public var accountName: String
  public var sourceAccountName: String
  public var accountID: String?
  public var currentParentID: String?
  public var parentID: String?
  public var parentName: String?
  public var descendantIDs: [String]

  public init(
    folderID: String,
    name: String,
    accountName: String,
    sourceAccountName: String? = nil,
    accountID: String? = nil,
    currentParentID: String? = nil,
    parentID: String? = nil,
    parentName: String? = nil,
    descendantIDs: [String] = []
  ) {
    self.folderID = folderID
    self.name = name
    self.accountName = accountName
    self.sourceAccountName = sourceAccountName ?? accountName
    self.accountID = accountID
    self.currentParentID = currentParentID
    self.parentID = parentID
    self.parentName = parentName
    self.descendantIDs = descendantIDs
  }
}

public struct NotesFolderMoveImpactRecord: Codable, Equatable, Sendable {
  public var sourceFolderIDSHA256: String
  public var sourceAccountSHA256: String
  public var destinationKind: String
  public var destinationIDSHA256: String
  public var destinationAccountSHA256: String
  public var crossAccountMove: Bool
  public var decisionType: UInt64
  public var additionalStep: UInt64
  public var decisionTypeStringSHA256: String?
  public var shouldMove: Bool
  public var shouldProceed: Bool
  public var shouldContinueDecisionMaking: Bool
  public var modernSourceObjectCount: Int
  public var htmlSourceObjectCount: Int
  public var modernFolderCount: Int
  public var accountCountOfModernSourceObjects: Int
  public var accountCountOfHTMLSourceObjects: Int
  public var ownedSharedRootObjectCount: Int
  public var joinedSharedRootObjectCount: Int
  public var readWriteSharedSubObjectCount: Int
  public var readOnlySharedSubObjectCount: Int
  public var sharedObjectCount: Int
  public var sharedObjectNotFromDestinationFolderCount: Int
  public var hasSharedObjectsNotFromDestinationAccount: Bool
  public var lockedObjectCount: Int
  public var hasLockedObjects: Bool
  public var hasLockedNotesNotFromDestinationAccount: Bool
  public var unsupportedObjectCount: Int
  public var privateModernNoteWithAttachmentsCount: Int
  public var systemPaperNoteCount: Int
  public var mathNoteCount: Int
  public var callNoteCount: Int
  public var guiltyObjectCount: Int
  public var sourceObjectSetSHA256: String
  public var guiltyObjectSetSHA256: String?
  public var requiresSharedPermissionReview: Bool
  public var requiresCrossAccountFidelityReview: Bool
  public var privacyBoundary: String
  public var sourceKind: String
  public var backendCalls: [String]

  public init(
    sourceFolderIDSHA256: String,
    sourceAccountSHA256: String,
    destinationKind: String,
    destinationIDSHA256: String,
    destinationAccountSHA256: String,
    crossAccountMove: Bool,
    decisionType: UInt64,
    additionalStep: UInt64,
    decisionTypeStringSHA256: String?,
    shouldMove: Bool,
    shouldProceed: Bool,
    shouldContinueDecisionMaking: Bool,
    modernSourceObjectCount: Int,
    htmlSourceObjectCount: Int,
    modernFolderCount: Int,
    accountCountOfModernSourceObjects: Int,
    accountCountOfHTMLSourceObjects: Int,
    ownedSharedRootObjectCount: Int,
    joinedSharedRootObjectCount: Int,
    readWriteSharedSubObjectCount: Int,
    readOnlySharedSubObjectCount: Int,
    sharedObjectCount: Int,
    sharedObjectNotFromDestinationFolderCount: Int,
    hasSharedObjectsNotFromDestinationAccount: Bool,
    lockedObjectCount: Int,
    hasLockedObjects: Bool,
    hasLockedNotesNotFromDestinationAccount: Bool,
    unsupportedObjectCount: Int,
    privateModernNoteWithAttachmentsCount: Int,
    systemPaperNoteCount: Int,
    mathNoteCount: Int,
    callNoteCount: Int,
    guiltyObjectCount: Int,
    sourceObjectSetSHA256: String,
    guiltyObjectSetSHA256: String?,
    requiresSharedPermissionReview: Bool,
    requiresCrossAccountFidelityReview: Bool,
    privacyBoundary: String,
    sourceKind: String,
    backendCalls: [String]
  ) {
    self.sourceFolderIDSHA256 = sourceFolderIDSHA256
    self.sourceAccountSHA256 = sourceAccountSHA256
    self.destinationKind = destinationKind
    self.destinationIDSHA256 = destinationIDSHA256
    self.destinationAccountSHA256 = destinationAccountSHA256
    self.crossAccountMove = crossAccountMove
    self.decisionType = decisionType
    self.additionalStep = additionalStep
    self.decisionTypeStringSHA256 = decisionTypeStringSHA256
    self.shouldMove = shouldMove
    self.shouldProceed = shouldProceed
    self.shouldContinueDecisionMaking = shouldContinueDecisionMaking
    self.modernSourceObjectCount = modernSourceObjectCount
    self.htmlSourceObjectCount = htmlSourceObjectCount
    self.modernFolderCount = modernFolderCount
    self.accountCountOfModernSourceObjects = accountCountOfModernSourceObjects
    self.accountCountOfHTMLSourceObjects = accountCountOfHTMLSourceObjects
    self.ownedSharedRootObjectCount = ownedSharedRootObjectCount
    self.joinedSharedRootObjectCount = joinedSharedRootObjectCount
    self.readWriteSharedSubObjectCount = readWriteSharedSubObjectCount
    self.readOnlySharedSubObjectCount = readOnlySharedSubObjectCount
    self.sharedObjectCount = sharedObjectCount
    self.sharedObjectNotFromDestinationFolderCount = sharedObjectNotFromDestinationFolderCount
    self.hasSharedObjectsNotFromDestinationAccount = hasSharedObjectsNotFromDestinationAccount
    self.lockedObjectCount = lockedObjectCount
    self.hasLockedObjects = hasLockedObjects
    self.hasLockedNotesNotFromDestinationAccount = hasLockedNotesNotFromDestinationAccount
    self.unsupportedObjectCount = unsupportedObjectCount
    self.privateModernNoteWithAttachmentsCount = privateModernNoteWithAttachmentsCount
    self.systemPaperNoteCount = systemPaperNoteCount
    self.mathNoteCount = mathNoteCount
    self.callNoteCount = callNoteCount
    self.guiltyObjectCount = guiltyObjectCount
    self.sourceObjectSetSHA256 = sourceObjectSetSHA256
    self.guiltyObjectSetSHA256 = guiltyObjectSetSHA256
    self.requiresSharedPermissionReview = requiresSharedPermissionReview
    self.requiresCrossAccountFidelityReview = requiresCrossAccountFidelityReview
    self.privacyBoundary = privacyBoundary
    self.sourceKind = sourceKind
    self.backendCalls = backendCalls
  }
}

public struct NotesFolderMoveImpactResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var impact: NotesFolderMoveImpactRecord
  public var verification: NotesMutationVerificationReport

  public init(
    operation: String,
    changed: Bool,
    impact: NotesFolderMoveImpactRecord,
    verification: NotesMutationVerificationReport
  ) {
    self.operation = operation
    self.changed = changed
    self.impact = impact
    self.verification = verification
  }
}

public struct NotesFolderDeleteDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var name: String
  public var accountName: String
  public var parentID: String?
  public var visibleNoteCount: Int?
  public var childFolderCount: Int?

  public init(
    folderID: String,
    name: String,
    accountName: String,
    parentID: String? = nil,
    visibleNoteCount: Int? = nil,
    childFolderCount: Int? = nil
  ) {
    self.folderID = folderID
    self.name = name
    self.accountName = accountName
    self.parentID = parentID
    self.visibleNoteCount = visibleNoteCount
    self.childFolderCount = childFolderCount
  }
}

public struct NotesFolderPurgeDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var name: String
  public var accountName: String
  public var parentID: String?
  public var visibleNoteCount: Int?
  public var childFolderCount: Int?

  public init(
    folderID: String,
    name: String,
    accountName: String,
    parentID: String? = nil,
    visibleNoteCount: Int? = nil,
    childFolderCount: Int? = nil
  ) {
    self.folderID = folderID
    self.name = name
    self.accountName = accountName
    self.parentID = parentID
    self.visibleNoteCount = visibleNoteCount
    self.childFolderCount = childFolderCount
  }
}

public struct NotesFolderSortDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var name: String
  public var accountName: String
  public var parentID: String?
  public var by: String
  public var direction: String
  public var sortOrder: Int
  public var sortDirection: Int
  public var sortValue: Int
  public var sortIsDefault: Bool
  public var sortIsAscending: Bool
  public var resolvedSortOrder: Int

  public init(
    folderID: String,
    name: String,
    accountName: String,
    parentID: String? = nil,
    by: String,
    direction: String,
    sortOrder: Int,
    sortDirection: Int,
    sortValue: Int,
    sortIsDefault: Bool,
    sortIsAscending: Bool,
    resolvedSortOrder: Int
  ) {
    self.folderID = folderID
    self.name = name
    self.accountName = accountName
    self.parentID = parentID
    self.by = by
    self.direction = direction
    self.sortOrder = sortOrder
    self.sortDirection = sortDirection
    self.sortValue = sortValue
    self.sortIsDefault = sortIsDefault
    self.sortIsAscending = sortIsAscending
    self.resolvedSortOrder = resolvedSortOrder
  }
}

public struct NotesFolderReorderDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var name: String
  public var accountName: String
  public var parentID: String?
  public var referenceFolderID: String
  public var referenceName: String
  public var placement: String
  public var requestedIndex: Int
  public var currentIndex: Int?
  public var siblingOrderCount: Int?

  public init(
    folderID: String,
    name: String,
    accountName: String,
    parentID: String? = nil,
    referenceFolderID: String,
    referenceName: String,
    placement: String,
    requestedIndex: Int,
    currentIndex: Int? = nil,
    siblingOrderCount: Int? = nil
  ) {
    self.folderID = folderID
    self.name = name
    self.accountName = accountName
    self.parentID = parentID
    self.referenceFolderID = referenceFolderID
    self.referenceName = referenceName
    self.placement = placement
    self.requestedIndex = requestedIndex
    self.currentIndex = currentIndex
    self.siblingOrderCount = siblingOrderCount
  }
}

public struct NotesFolderDateHeadersDraft: Codable, Equatable, Sendable {
  public var folderID: String
  public var name: String
  public var accountName: String
  public var parentID: String?
  public var enabled: Bool
  public var privateValue: Int

  public init(
    folderID: String,
    name: String,
    accountName: String,
    parentID: String? = nil,
    enabled: Bool,
    privateValue: Int
  ) {
    self.folderID = folderID
    self.name = name
    self.accountName = accountName
    self.parentID = parentID
    self.enabled = enabled
    self.privateValue = privateValue
  }
}

public struct NotesUpdatePatch: Codable, Equatable, Sendable {
  public var title: String?
  public var body: String?
  public var appendBody: String?

  public init(title: String? = nil, body: String? = nil, appendBody: String? = nil) {
    self.title = title
    self.body = body
    self.appendBody = appendBody
  }

  var hasChanges: Bool {
    title != nil || body != nil || appendBody != nil
  }
}

public struct NotesMoveDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var folderID: String
  public var folderName: String
  public var accountName: String

  public init(noteID: String, folderID: String, folderName: String, accountName: String) {
    self.noteID = noteID
    self.folderID = folderID
    self.folderName = folderName
    self.accountName = accountName
  }
}

public struct NotesCopyDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var folderID: String
  public var folderName: String
  public var accountName: String

  public init(noteID: String, folderID: String, folderName: String, accountName: String) {
    self.noteID = noteID
    self.folderID = folderID
    self.folderName = folderName
    self.accountName = accountName
  }
}

public struct NotesRestoreDraft: Codable, Equatable, Sendable {
  public var noteID: String
  public var folderID: String
  public var folderName: String
  public var accountName: String

  public init(noteID: String, folderID: String, folderName: String, accountName: String) {
    self.noteID = noteID
    self.folderID = folderID
    self.folderName = folderName
    self.accountName = accountName
  }
}

public struct NotesStoreFileRecord: Codable, Equatable, Sendable {
  public var path: String
  public var exists: Bool
  public var isDirectory: Bool
  public var isReadable: Bool
  public var sizeBytes: Int64?
  public var modifiedAt: Date?

  public init(
    path: String,
    exists: Bool,
    isDirectory: Bool,
    isReadable: Bool,
    sizeBytes: Int64? = nil,
    modifiedAt: Date? = nil
  ) {
    self.path = path
    self.exists = exists
    self.isDirectory = isDirectory
    self.isReadable = isReadable
    self.sizeBytes = sizeBytes
    self.modifiedAt = modifiedAt
  }
}

public struct NotesStoreSchemaTableRecord: Codable, Equatable, Sendable {
  public var tableName: String
  public var columnCount: Int
  public var columns: [String]

  public init(tableName: String, columnCount: Int, columns: [String]) {
    self.tableName = tableName
    self.columnCount = columnCount
    self.columns = columns
  }
}

public struct NotesStoreEntityCountRecord: Codable, Equatable, Sendable {
  public var entity: String
  public var rows: Int

  public init(entity: String, rows: Int) {
    self.entity = entity
    self.rows = rows
  }
}

public struct NotesStoreSearchIndexStateRecord: Codable, Equatable, Sendable {
  public var stateValue: String
  public var rows: Int

  public init(stateValue: String, rows: Int) {
    self.stateValue = stateValue
    self.rows = rows
  }
}

public struct NotesStoreDebugResponse: Codable, Equatable, Sendable {
  public var scope: String
  public var container: NotesStoreFileRecord
  public var store: NotesStoreFileRecord
  public var wal: NotesStoreFileRecord
  public var shm: NotesStoreFileRecord
  public var indexStateFiles: [NotesStoreFileRecord]
  public var tableCount: Int?
  public var indexCount: Int?
  public var requiredTablesPresent: [String]
  public var requiredTablesMissing: [String]
  public var schemaTables: [NotesStoreSchemaTableRecord]
  public var entityCounts: [NotesStoreEntityCountRecord]
  public var searchIndexStateCounts: [NotesStoreSearchIndexStateRecord]
  public var warnings: [String]

  public init(
    scope: String,
    container: NotesStoreFileRecord,
    store: NotesStoreFileRecord,
    wal: NotesStoreFileRecord,
    shm: NotesStoreFileRecord,
    indexStateFiles: [NotesStoreFileRecord],
    tableCount: Int? = nil,
    indexCount: Int? = nil,
    requiredTablesPresent: [String] = [],
    requiredTablesMissing: [String] = [],
    schemaTables: [NotesStoreSchemaTableRecord] = [],
    entityCounts: [NotesStoreEntityCountRecord] = [],
    searchIndexStateCounts: [NotesStoreSearchIndexStateRecord] = [],
    warnings: [String] = []
  ) {
    self.scope = scope
    self.container = container
    self.store = store
    self.wal = wal
    self.shm = shm
    self.indexStateFiles = indexStateFiles
    self.tableCount = tableCount
    self.indexCount = indexCount
    self.requiredTablesPresent = requiredTablesPresent
    self.requiredTablesMissing = requiredTablesMissing
    self.schemaTables = schemaTables
    self.entityCounts = entityCounts
    self.searchIndexStateCounts = searchIndexStateCounts
    self.warnings = warnings
  }
}

public struct NotesReadbackRecord: Codable, Equatable, Sendable {
  public var kind: String
  public var idSHA256: String
  public var titleSHA256: String?
  public var titleLength: Int?
  public var nameSHA256: String?
  public var nameLength: Int?
  public var accountNameSHA256: String?
  public var accountNameLength: Int?
  public var folderNameSHA256: String?
  public var folderNameLength: Int?
  public var hasBody: Bool?
  public var bodyByteCount: Int?
  public var bodySHA256: String?
  public var hasCreatedAt: Bool?
  public var hasUpdatedAt: Bool?

  public init(
    kind: String,
    idSHA256: String,
    titleSHA256: String? = nil,
    titleLength: Int? = nil,
    nameSHA256: String? = nil,
    nameLength: Int? = nil,
    accountNameSHA256: String? = nil,
    accountNameLength: Int? = nil,
    folderNameSHA256: String? = nil,
    folderNameLength: Int? = nil,
    hasBody: Bool? = nil,
    bodyByteCount: Int? = nil,
    bodySHA256: String? = nil,
    hasCreatedAt: Bool? = nil,
    hasUpdatedAt: Bool? = nil
  ) {
    self.kind = kind
    self.idSHA256 = idSHA256
    self.titleSHA256 = titleSHA256
    self.titleLength = titleLength
    self.nameSHA256 = nameSHA256
    self.nameLength = nameLength
    self.accountNameSHA256 = accountNameSHA256
    self.accountNameLength = accountNameLength
    self.folderNameSHA256 = folderNameSHA256
    self.folderNameLength = folderNameLength
    self.hasBody = hasBody
    self.bodyByteCount = bodyByteCount
    self.bodySHA256 = bodySHA256
    self.hasCreatedAt = hasCreatedAt
    self.hasUpdatedAt = hasUpdatedAt
  }
}

public struct NotesStoreObjectRecord: Codable, Equatable, Sendable {
  public var entity: String?
  public var primaryKey: Int64?
  public var matched: Bool
  public var markedForDeletion: Bool?
  public var passwordProtected: Bool?
  public var pinned: Bool?
  public var folderPrimaryKey: Int64?
  public var accountPrimaryKey: Int64?
  public var noteDataPrimaryKey: Int64?
  public var parentPrimaryKey: Int64?
  public var folderType: Int?
  public var accountType: Int?
  public var titleLength: Int?
  public var snippetLength: Int?
  public var smartFolderQueryJSONLength: Int?
  public var noteCount: Int?
  public var folderCount: Int?
  public var childFolderCount: Int?
  public var searchIndexStateCounts: [NotesStoreSearchIndexStateRecord]

  public init(
    entity: String? = nil,
    primaryKey: Int64? = nil,
    matched: Bool,
    markedForDeletion: Bool? = nil,
    passwordProtected: Bool? = nil,
    pinned: Bool? = nil,
    folderPrimaryKey: Int64? = nil,
    accountPrimaryKey: Int64? = nil,
    noteDataPrimaryKey: Int64? = nil,
    parentPrimaryKey: Int64? = nil,
    folderType: Int? = nil,
    accountType: Int? = nil,
    titleLength: Int? = nil,
    snippetLength: Int? = nil,
    smartFolderQueryJSONLength: Int? = nil,
    noteCount: Int? = nil,
    folderCount: Int? = nil,
    childFolderCount: Int? = nil,
    searchIndexStateCounts: [NotesStoreSearchIndexStateRecord] = []
  ) {
    self.entity = entity
    self.primaryKey = primaryKey
    self.matched = matched
    self.markedForDeletion = markedForDeletion
    self.passwordProtected = passwordProtected
    self.pinned = pinned
    self.folderPrimaryKey = folderPrimaryKey
    self.accountPrimaryKey = accountPrimaryKey
    self.noteDataPrimaryKey = noteDataPrimaryKey
    self.parentPrimaryKey = parentPrimaryKey
    self.folderType = folderType
    self.accountType = accountType
    self.titleLength = titleLength
    self.snippetLength = snippetLength
    self.smartFolderQueryJSONLength = smartFolderQueryJSONLength
    self.noteCount = noteCount
    self.folderCount = folderCount
    self.childFolderCount = childFolderCount
    self.searchIndexStateCounts = searchIndexStateCounts
  }
}

public struct NotesObjectDebugResponse: Codable, Equatable, Sendable {
  public var kind: String
  public var selectorSHA256: String
  public var readback: NotesReadbackRecord
  public var storeObject: NotesStoreObjectRecord
  public var warnings: [String]

  public init(
    kind: String,
    selectorSHA256: String,
    readback: NotesReadbackRecord,
    storeObject: NotesStoreObjectRecord,
    warnings: [String] = []
  ) {
    self.kind = kind
    self.selectorSHA256 = selectorSHA256
    self.readback = readback
    self.storeObject = storeObject
    self.warnings = warnings
  }
}

public struct NotesVerificationCheckRecord: Codable, Equatable, Sendable {
  public var name: String
  public var status: String
  public var expectedSHA256: String?
  public var actualSHA256: String?
  public var expectedLength: Int?
  public var actualLength: Int?
  public var expectedBool: Bool?
  public var actualBool: Bool?

  public init(
    name: String,
    status: String,
    expectedSHA256: String? = nil,
    actualSHA256: String? = nil,
    expectedLength: Int? = nil,
    actualLength: Int? = nil,
    expectedBool: Bool? = nil,
    actualBool: Bool? = nil
  ) {
    self.name = name
    self.status = status
    self.expectedSHA256 = expectedSHA256
    self.actualSHA256 = actualSHA256
    self.expectedLength = expectedLength
    self.actualLength = actualLength
    self.expectedBool = expectedBool
    self.actualBool = actualBool
  }
}

public struct NotesMutationVerificationReport: Codable, Equatable, Sendable {
  public var verifier: String
  public var operation: String
  public var verified: Bool
  public var evidenceLevel: String
  public var targetIDSHA256: String
  public var readback: NotesReadbackRecord?
  public var storeObject: NotesStoreObjectRecord?
  public var checks: [NotesVerificationCheckRecord]
  public var warnings: [String]

  public init(
    verifier: String = "notes_mutation_v1",
    operation: String,
    verified: Bool,
    evidenceLevel: String,
    targetIDSHA256: String,
    readback: NotesReadbackRecord? = nil,
    storeObject: NotesStoreObjectRecord? = nil,
    checks: [NotesVerificationCheckRecord],
    warnings: [String] = []
  ) {
    self.verifier = verifier
    self.operation = operation
    self.verified = verified
    self.evidenceLevel = evidenceLevel
    self.targetIDSHA256 = targetIDSHA256
    self.readback = readback
    self.storeObject = storeObject
    self.checks = checks
    self.warnings = warnings
  }
}
