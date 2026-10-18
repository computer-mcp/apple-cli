import CryptoKit
import Foundation
import Utility

public protocol NotesReading: Sendable {
  func listAccounts() throws -> [NotesAccountRecord]
  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord]
  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary]
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary]
  func readNote(id: String) throws -> NotesNoteDetail?
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail]
}

public protocol NotesAccountScopedListing: Sendable {
  func listNotes(account: String?, folder: String?, limit: Int) throws -> [NotesNoteSummary]
}

public protocol NotesAccountScopedSearching: Sendable {
  func searchNotes(query: String, account: String?, folder: String?, limit: Int) throws -> [NotesNoteSummary]
}

public protocol NotesNaturalLanguageSearching: Sendable {
  func searchNaturalLanguageNotes(
    query: String,
    account: String?,
    folder: String?,
    limit: Int
  ) throws -> NotesNaturalLanguageSearchEvidence
}

public protocol NotesRestorableReading: Sendable {
  func readRestorableNote(id: String) throws -> NotesNoteDetail?
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail]
}

public protocol NotesFolderPurgeReading: Sendable {
  func listPurgableFolders(account: String?, limit: Int) throws -> [NotesFolderRecord]
}

public protocol NotesFolderPurging: Sendable {
  func purgeFolder(_ draft: NotesFolderPurgeDraft) throws -> Bool
}

public protocol NotesTagReading: Sendable {
  func listTags(account: String?, limit: Int) throws -> [NotesTagRecord]
  func readNotes(tag: String, limit: Int) throws -> [NotesNoteDetail]
}

public protocol NotesAttachmentReading: Sendable {
  func listAttachments(noteID id: String, limit: Int) throws -> [NotesAttachmentRecord]
  func exportAttachment(noteID id: String, attachmentID: String) throws -> NotesAttachmentExportSource
  func exportAttachmentPDF(noteID id: String, attachmentID: String) throws -> NotesAttachmentPDFExportSource
  func inspectAttachmentScanPDF(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentScanPDFInspectionSource
  func inspectAttachmentMarkup(noteID id: String, attachmentID: String) throws -> NotesAttachmentMarkupInspectionSource
  func readAttachmentImageObjects(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageObjectSource
  func readAttachmentImageDescription(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageDescriptionSource
  func readAttachmentAudioTranscript(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentAudioTranscriptSource
  func readAttachmentSearchableText(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentSearchableTextSource
}

public protocol NotesAttachmentRecognizedTextGenerating: Sendable {
  func generateRecognizedText(
    from input: NotesAttachmentRecognizedTextGenerationInput
  ) throws -> NotesAttachmentRecognizedTextGeneration
}

public protocol NotesAttachmentSearchIndexMutating: Sendable {
  func reindexAttachmentSearchableText(
    _ draft: NotesAttachmentSearchIndexDraft
  ) throws -> NotesAttachmentSearchIndexWriteResult
}

public extension NotesAttachmentReading {
  func readAttachmentImageObjects(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageObjectSource
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes image object classification readback is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(id),
        "attachment_sha256": sha256Hex(attachmentID),
      ]
    )
  }

  func inspectAttachmentScanPDF(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentScanPDFInspectionSource
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes PDF/scan attachment inspection is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(id),
        "attachment_sha256": sha256Hex(attachmentID),
      ]
    )
  }

  func readAttachmentSearchableText(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentSearchableTextSource
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes attachment searchable text readback is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(id),
        "attachment_sha256": sha256Hex(attachmentID),
      ]
    )
  }

  func readAttachmentImageDescription(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageDescriptionSource
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes attachment image description readback is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(id),
        "attachment_sha256": sha256Hex(attachmentID),
      ]
    )
  }
}

public extension NotesAttachmentSearchIndexMutating {
  func reindexAttachmentSearchableText(
    _ draft: NotesAttachmentSearchIndexDraft
  ) throws -> NotesAttachmentSearchIndexWriteResult {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes attachment search index mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }
}

public protocol NotesAttachmentMutating: Sendable {
  func addAttachment(_ draft: NotesAttachmentAddDraft) throws -> NotesAttachmentAddWriteResult
  func renameAttachment(_ draft: NotesAttachmentRenameDraft) throws -> NotesAttachmentRenameWriteResult
  func removeAttachment(_ draft: NotesAttachmentRemoveDraft) throws -> NotesAttachmentRemoveWriteResult
  func rotateScanAttachment(_ draft: NotesAttachmentScanRotateDraft) throws
    -> NotesAttachmentScanRotateWriteResult
  func cropScanAttachment(_ draft: NotesAttachmentScanCropDraft) throws
    -> NotesAttachmentScanCropWriteResult
  func filterScanAttachment(_ draft: NotesAttachmentScanFilterDraft) throws
    -> NotesAttachmentScanFilterWriteResult
  func moveScanPage(_ draft: NotesAttachmentScanPageMoveDraft) throws
    -> NotesAttachmentScanPageMoveWriteResult
  func deleteScanPage(_ draft: NotesAttachmentScanPageDeleteDraft) throws
    -> NotesAttachmentScanPageDeleteWriteResult
  func cropPDF(_ draft: NotesAttachmentPDFCropDraft) throws
    -> NotesAttachmentPDFCropWriteResult
  func cropImageAttachment(_ draft: NotesAttachmentImageCropDraft) throws
    -> NotesAttachmentImageCropWriteResult
  func rotateImageAttachment(_ draft: NotesAttachmentImageRotateDraft) throws
    -> NotesAttachmentImageRotateWriteResult
  func rotatePDFPage(_ draft: NotesAttachmentPDFPageRotateDraft) throws
    -> NotesAttachmentPDFPageRotateWriteResult
  func movePDFPage(_ draft: NotesAttachmentPDFPageMoveDraft) throws
    -> NotesAttachmentPDFPageMoveWriteResult
  func deletePDFPage(_ draft: NotesAttachmentPDFPageDeleteDraft) throws
    -> NotesAttachmentPDFPageDeleteWriteResult
  func applyAttachmentMarkup(_ draft: NotesAttachmentMarkupEditDraft) throws
    -> NotesAttachmentMarkupEditWriteResult
  func setAttachmentImageDescription(_ draft: NotesAttachmentImageDescriptionDraft) throws
    -> NotesAttachmentImageDescriptionWriteResult
}

public extension NotesAttachmentMutating {
  func rotateScanAttachment(_ draft: NotesAttachmentScanRotateDraft) throws
    -> NotesAttachmentScanRotateWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes scan attachment rotation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func setAttachmentImageDescription(_ draft: NotesAttachmentImageDescriptionDraft) throws
    -> NotesAttachmentImageDescriptionWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes attachment image description mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func filterScanAttachment(_ draft: NotesAttachmentScanFilterDraft) throws
    -> NotesAttachmentScanFilterWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes scan attachment filter mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func cropScanAttachment(_ draft: NotesAttachmentScanCropDraft) throws
    -> NotesAttachmentScanCropWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes scan attachment crop mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func moveScanPage(_ draft: NotesAttachmentScanPageMoveDraft) throws
    -> NotesAttachmentScanPageMoveWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes scan page move mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func deleteScanPage(_ draft: NotesAttachmentScanPageDeleteDraft) throws
    -> NotesAttachmentScanPageDeleteWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes scan page delete mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func cropPDF(_ draft: NotesAttachmentPDFCropDraft) throws
    -> NotesAttachmentPDFCropWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes PDF crop mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func cropImageAttachment(_ draft: NotesAttachmentImageCropDraft) throws
    -> NotesAttachmentImageCropWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes image attachment crop mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func rotateImageAttachment(_ draft: NotesAttachmentImageRotateDraft) throws
    -> NotesAttachmentImageRotateWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes image attachment rotation mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func rotatePDFPage(_ draft: NotesAttachmentPDFPageRotateDraft) throws
    -> NotesAttachmentPDFPageRotateWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes PDF page rotation mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func movePDFPage(_ draft: NotesAttachmentPDFPageMoveDraft) throws
    -> NotesAttachmentPDFPageMoveWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes PDF page move mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }

  func deletePDFPage(_ draft: NotesAttachmentPDFPageDeleteDraft) throws
    -> NotesAttachmentPDFPageDeleteWriteResult
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes PDF page delete mutation is unavailable in this implementation.",
      details: [
        "id_sha256": sha256Hex(draft.noteID),
        "attachment_sha256": sha256Hex(draft.attachmentID),
      ]
    )
  }
}

public protocol NotesLinkReading: Sendable {
  func listLinks(noteID id: String, limit: Int) throws -> [NotesLinkRecord]
  func listBacklinks(noteID id: String, limit: Int) throws -> [NotesBacklinkRecord]
  func resolveLink(noteID id: String, linkID: String) throws -> NotesLinkResolutionRecord
}

public protocol NotesLinkMutating: Sendable {
  func addLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult
  func addWebpageAttachment(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult
  func updateWebpageAttachment(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult
  func addAppLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult
  func addFileLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult
  func addNoteLink(_ draft: NotesNoteLinkAddDraft) throws -> NotesNoteLinkAddWriteResult
  func addParagraphLink(_ draft: NotesParagraphLinkAddDraft) throws -> NotesParagraphLinkAddWriteResult
  func updateLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult
  func updateAppLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult
  func updateFileLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult
  func updateNoteLink(_ draft: NotesNoteLinkUpdateDraft) throws -> NotesNoteLinkUpdateWriteResult
  func updateParagraphLink(_ draft: NotesParagraphLinkUpdateDraft) throws
    -> NotesParagraphLinkUpdateWriteResult
  func removeAppLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult
  func removeNoteLink(_ draft: NotesNoteLinkRemoveDraft) throws -> NotesNoteLinkRemoveWriteResult
  func removeParagraphLink(_ draft: NotesParagraphLinkRemoveDraft) throws -> NotesParagraphLinkRemoveWriteResult
  func removeFileLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult
  func removeLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult
}

public protocol NotesSmartFolderReading: Sendable {
  func listSmartFolders(account: String?, limit: Int) throws -> [NotesSmartFolderRecord]
  func listSmartFolderNotes(smartFolderID: String, limit: Int) throws -> [NotesNoteSummary]
  func exportSmartFolderCriteria(smartFolderID: String) throws -> NotesSmartFolderCriteriaExportSource
}

public protocol NotesSmartFolderMutating: Sendable {
  func createSmartFolder(_ draft: NotesSmartFolderCreateDraft) throws -> NotesSmartFolderCreateWriteResult
  func updateSmartFolder(_ draft: NotesSmartFolderUpdateDraft) throws -> NotesSmartFolderUpdateWriteResult
  func createSmartFolderBuiltInCriteria(_ draft: NotesSmartFolderBuiltInCriteriaCreateDraft) throws
    -> NotesSmartFolderBuiltInCriteriaCreateWriteResult
  func updateSmartFolderBuiltInCriteria(_ draft: NotesSmartFolderBuiltInCriteriaUpdateDraft) throws
    -> NotesSmartFolderBuiltInCriteriaUpdateWriteResult
  func duplicateSmartFolder(_ draft: NotesSmartFolderDuplicateDraft) throws -> NotesSmartFolderDuplicateWriteResult
  func copySmartFolderCriteria(_ draft: NotesSmartFolderCriteriaCopyDraft) throws
    -> NotesSmartFolderCriteriaCopyWriteResult
  func importSmartFolderCriteria(_ draft: NotesSmartFolderCriteriaImportDraft) throws
    -> NotesSmartFolderCriteriaImportWriteResult
  func renameSmartFolder(_ draft: NotesSmartFolderRenameDraft) throws -> NotesSmartFolderRecord
  func deleteSmartFolder(_ draft: NotesSmartFolderDeleteDraft) throws -> Bool
  func convertFolderToSmartFolder(_ draft: NotesSmartFolderFolderConversionDraft) throws
    -> NotesSmartFolderFolderConversionWriteResult
}

public protocol NotesFolderMoveImpactReading: Sendable {
  func readFolderMoveImpact(_ draft: NotesFolderMoveDraft) throws -> NotesFolderMoveImpactRecord
}

public protocol NotesBodyStructureReading: Sendable {
  func readBodyStructure(noteID id: String) throws -> NotesBodyStructureRecord
  func readInlineSelection(noteID: String, paragraphIDSHA256: String?, ordinal: Int?,
    text: String, occurrence: Int?) throws -> NotesBodyInlineSelectionReadback
  func listTables(noteID id: String) throws -> [NotesBodyTableRecord]
  func readTableCell(noteID id: String, tableOrdinal: Int, row: Int, column: Int) throws
    -> NotesBodyTableCellRecord
  func listMathResults(noteID id: String) throws -> [NotesBodyMathResultRecord]
  func readMathResultsPreference(noteID id: String) throws -> NotesBodyMathResultsPreferenceRecord
  func listCollapsibleSections(noteID id: String) throws -> [NotesBodyCollapsibleSectionRecord]
}

public extension NotesBodyStructureReading {
  func readInlineSelection(noteID: String, paragraphIDSHA256: String?, ordinal: Int?,
    text: String, occurrence: Int?) throws -> NotesBodyInlineSelectionReadback {
    throw CLIError(code: .backendUnavailable, message: "Notes inline selection readback is unavailable.")
  }
}

public protocol NotesBodyMathExpressionScanning: Sendable {
  func scanMathExpression(_ draft: NotesBodyMathExpressionScanDraft) throws
    -> NotesBodyMathExpressionScanRecord
}

public protocol NotesBodyMutating: Sendable {
  func addChecklistItem(_ draft: NotesBodyChecklistAddDraft) throws -> NotesBodyChecklistAddWriteResult
  func setChecklistItemState(_ draft: NotesBodyChecklistSetDraft) throws -> NotesBodyChecklistSetWriteResult
  func setAllChecklistItemStates(_ draft: NotesBodyChecklistSetAllDraft) throws -> NotesBodyChecklistSetAllWriteResult
  func sortChecklistItems(_ draft: NotesBodyChecklistSortDraft) throws -> NotesBodyChecklistSortWriteResult
  func convertParagraphToChecklistItem(_ draft: NotesBodyChecklistConvertDraft) throws
    -> NotesBodyChecklistConvertWriteResult
  func convertParagraphRangeToChecklistItems(_ draft: NotesBodyChecklistConvertRangeDraft) throws
    -> NotesBodyChecklistConvertRangeWriteResult
  func reorderChecklistItem(_ draft: NotesBodyChecklistReorderDraft) throws
    -> NotesBodyChecklistReorderWriteResult
  func indentChecklistItem(_ draft: NotesBodyChecklistIndentDraft) throws
    -> NotesBodyChecklistIndentWriteResult
  func deleteChecklistItem(_ draft: NotesBodyChecklistDeleteDraft) throws
    -> NotesBodyChecklistDeleteWriteResult
  func addListItem(_ draft: NotesBodyListAddDraft) throws -> NotesBodyListAddWriteResult
  func convertParagraphToListItem(_ draft: NotesBodyListConvertDraft) throws
    -> NotesBodyListConvertWriteResult
  func convertParagraphRangeToListItems(_ draft: NotesBodyListConvertRangeDraft) throws
    -> NotesBodyListConvertRangeWriteResult
  func setListItemStyle(_ draft: NotesBodyListSetStyleDraft) throws -> NotesBodyListSetStyleWriteResult
  func reorderListItem(_ draft: NotesBodyListReorderDraft) throws
    -> NotesBodyListReorderWriteResult
  func indentListItem(_ draft: NotesBodyListIndentDraft) throws
    -> NotesBodyListIndentWriteResult
  func deleteListItem(_ draft: NotesBodyListDeleteDraft) throws
    -> NotesBodyListDeleteWriteResult
  func insertTextInListItem(_ draft: NotesBodyListTextInsertDraft) throws
    -> NotesBodyListTextInsertWriteResult
  func endList(_ draft: NotesBodyListEndDraft) throws -> NotesBodyListEndWriteResult
  func createTable(_ draft: NotesBodyTableCreateDraft) throws -> NotesBodyTableCreateWriteResult
  func importTable(_ draft: NotesBodyTableImportDraft) throws -> NotesBodyTableImportWriteResult
  func updateTableCell(_ draft: NotesBodyTableUpdateDraft) throws -> NotesBodyTableUpdateWriteResult
  func deleteTable(_ draft: NotesBodyTableDeleteDraft) throws -> NotesBodyTableDeleteWriteResult
  func convertTableToText(_ draft: NotesBodyTableConvertToTextDraft) throws
    -> NotesBodyTableConvertToTextWriteResult
  func convertTextToTable(_ draft: NotesBodyTableConvertFromTextDraft) throws
    -> NotesBodyTableConvertFromTextWriteResult
  func copyTable(_ draft: NotesBodyTableCopyDraft) throws -> NotesBodyTableCopyWriteResult
  func moveTable(_ draft: NotesBodyTableMoveDraft) throws -> NotesBodyTableMoveWriteResult
  func changeTableStructure(_ draft: NotesBodyTableStructureDraft) throws -> NotesBodyTableStructureWriteResult
  func formatTableRange(_ draft: NotesBodyTableFormatDraft) throws -> NotesBodyTableFormatWriteResult
  func insertMathResult(_ draft: NotesBodyMathInsertDraft) throws -> NotesBodyMathInsertWriteResult
  func updateMathResult(_ draft: NotesBodyMathUpdateDraft) throws -> NotesBodyMathUpdateWriteResult
  func setMathVariable(_ draft: NotesBodyMathVariableSetDraft) throws -> NotesBodyMathVariableSetWriteResult
  func updateMathVariable(_ draft: NotesBodyMathVariableUpdateDraft) throws
    -> NotesBodyMathVariableUpdateWriteResult
  func setMathResultsPreference(_ draft: NotesBodyMathResultsPreferenceDraft) throws
    -> NotesBodyMathResultsPreferenceWriteResult
  func setCollapsibleSectionState(_ draft: NotesBodyCollapsibleSetDraft) throws
    -> NotesBodyCollapsibleSetWriteResult
  func setParagraphStyle(_ draft: NotesBodyParagraphStyleDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  func setParagraphAlignment(_ draft: NotesBodyParagraphAlignmentDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  func setParagraphBlockQuote(_ draft: NotesBodyParagraphQuoteDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  func setInlineFormat(_ draft: NotesBodyInlineFormatDraft) throws
    -> NotesBodyInlineFormatWriteResult
  func setInlineForegroundColor(_ draft: NotesBodyInlineColorDraft) throws
    -> NotesBodyInlineColorWriteResult
  func setInlineHighlightColor(_ draft: NotesBodyInlineColorDraft) throws
    -> NotesBodyInlineColorWriteResult
  func setInlineFont(_ draft: NotesBodyInlineFontDraft) throws
    -> NotesBodyInlineFormatWriteResult
}

public protocol NotesParagraphAnchorResolving: Sendable {
  func resolveParagraphAnchor(noteID id: String, paragraphIDSHA256: String) throws -> NotesParagraphAnchorResolution
}

public protocol NotesNoteStateReading: Sendable {
  func readNoteState(noteID id: String) throws -> NotesNoteStateRecord
}

public protocol NotesNoteStateMutating: Sendable {
  func setSharedNoteAlertsHidden(_ draft: NotesSharedNoteAlertsMutationDraft) throws
    -> NotesSharedNoteAlertsWriteResult
  func closeLockedSession(_ draft: NotesLockedSessionCloseDraft) throws
    -> NotesLockedSessionCloseWriteResult
  func setNoteLockState(_ draft: NotesNoteLockMutationDraft) throws
    -> NotesNoteLockMutationWriteResult
  func unlockNote(_ draft: NotesNoteUnlockDraft) throws
    -> NotesNoteUnlockWriteResult
}

public protocol NotesCollaborationLinkReading: Sendable {
  func readCollaborationLink(_ draft: NotesCollaborationLinkDraft) throws
    -> NotesCollaborationLinkReadResult
}

public protocol NotesCollaborationParticipantsReading: Sendable {
  func readCollaborationParticipants(_ draft: NotesCollaborationParticipantsDraft) throws
    -> NotesCollaborationParticipantsReadResult
}

public protocol NotesCollaborationPermissionMutating: Sendable {
  func setCollaborationParticipantPermission(_ draft: NotesCollaborationPermissionMutationDraft) throws
    -> NotesCollaborationPermissionWriteResult
}

public protocol NotesCollaborationSharingMutating: Sendable {
  func shareCollaboration(_ draft: NotesCollaborationShareMutationDraft) throws
    -> NotesCollaborationShareWriteResult
}

public protocol NotesCollaborationAccessScopeMutating: Sendable {
  func setCollaborationAccessScope(_ draft: NotesCollaborationAccessScopeMutationDraft) throws
    -> NotesCollaborationAccessScopeWriteResult
}

public protocol NotesCollaborationStopSharingMutating: Sendable {
  func stopSharing(_ draft: NotesCollaborationStopSharingDraft) throws
    -> NotesCollaborationStopSharingWriteResult
}

public protocol NotesCollaborationInvitePolicyMutating: Sendable {
  func setCollaborationInvitePolicy(_ draft: NotesCollaborationAllowInvitesDraft) throws
    -> NotesCollaborationAllowInvitesWriteResult
}

public protocol NotesCollaborationSelfRemovalMutating: Sendable {
  func removeSelfFromCollaboration(_ draft: NotesCollaborationSelfRemovalDraft) throws
    -> NotesCollaborationSelfRemovalWriteResult
}

public protocol NotesCollaborationParticipantMutating: Sendable {
  func removeCollaborationParticipant(_ draft: NotesCollaborationParticipantRemovalDraft) throws
    -> NotesCollaborationParticipantRemovalWriteResult
}

public protocol NotesCollaborationMentionMutating: Sendable {
  func insertParticipantMention(_ draft: NotesCollaborationMentionDraft) throws
    -> NotesCollaborationMentionWriteResult
}

public protocol NotesNoteActivityReading: Sendable {
  func readNoteActivity(noteID id: String) throws -> NotesNoteActivityRecord
}

public protocol NotesSettingsReading: Sendable {
  func readSettings(account: String?) throws -> NotesSettingsReadEvidence
}

public protocol NotesSettingsMutating: Sendable {
  func setNoteListSort(_ draft: NotesSettingsSortMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setDefaultNewNoteStyle(_ draft: NotesSettingsParagraphStyleMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setDefaultAccount(_ draft: NotesSettingsDefaultAccountMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setGroupNotesByDate(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setDateHeadersPreference(_ draft: NotesSettingsDateHeadersMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setQuickNoteResumeLast(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setMentionNotifications(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setDefaultTextSize(_ draft: NotesSettingsTextSizeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setOnMyMacAccountEnabled(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setChecklistAutoSort(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setTouchIDPreference(_ draft: NotesSettingsAccountBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setCustomPassphrase(_ draft: NotesSettingsPassphraseMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func changeCustomPassphrase(_ draft: NotesSettingsPassphraseChangeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  func setLockedNotesMethod(_ draft: NotesSettingsLockedNotesMethodMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
}

public protocol NotesNoteExporting: Sendable {
  func exportNotePDF(noteID id: String) throws -> NotesNotePDFExportSource
  func exportNoteMarkdown(noteID id: String, includeAttachments: Bool) throws -> NotesNoteMarkdownExportSource
  func exportNoteHTML(
    noteID id: String,
    includeAttachments: Bool,
    includeAttachmentResources: Bool
  ) throws -> NotesNoteHTMLExportSource
  func exportNoteRTF(noteID id: String) throws -> NotesNoteRTFExportSource
  func exportNoteRTFD(noteID id: String) throws -> NotesNoteRTFDExportSource
}

public protocol NotesLockedContentExporting: Sendable {
  func exportUnlockedLockedContent(_ draft: NotesLockedContentExportDraft) throws
    -> NotesLockedContentExportSource
}

protocol NotesRichImporting: Sendable {
  func importRichText(_ draft: NotesRichImportDraft) throws -> NotesRichImportResult
}

protocol NotesMarkdownImporting: Sendable {
  func importMarkdown(_ draft: NotesMarkdownImportDraft) throws -> NotesMarkdownImportResult
}

protocol NotesRichReplacing: Sendable {
  func replaceRichText(_ draft: NotesRichReplaceDraft) throws -> NotesRichReplaceResult
}

protocol NotesENEXImporting: Sendable {
  func importENEX(_ draft: NotesENEXImportDraft) throws -> NotesENEXImportResult
}

public protocol NotesPrintDispatching: Sendable {
  func validatePrinter(name: String) throws -> String
  func submitPDF(_ data: Data, suggestedFilename: String, printerName: String) throws -> String
}

public protocol NotesPagesDispatching: Sendable {
  func openRTFDPackage(_ files: [NotesNoteRTFDExportFile], suggestedTitle: String?) throws
    -> NotesPagesOpenDispatchRecord
}

public protocol NotesClipboardWriting: Sendable {
  func writeString(_ value: String) throws -> NotesClipboardWriteRecord
  func readString() throws -> String?
}

public protocol NotesTagMutating: Sendable {
  func addTag(_ tag: String, toNoteID id: String) throws -> NotesTagMutationWriteResult
  func removeTag(_ tag: String, fromNoteID id: String) throws -> NotesTagMutationWriteResult
  func convertTagToText(_ draft: NotesTagConvertToTextDraft) throws -> NotesTagConvertToTextWriteResult
  func renameTag(_ draft: NotesTagRenameDraft) throws -> NotesTagRenameWriteResult
  func deleteTag(_ draft: NotesTagDeleteDraft) throws -> NotesTagDeleteWriteResult
}

public protocol NotesMutating: NotesRestorableReading, Sendable {
  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord
  func reorderFolder(_ draft: NotesFolderReorderDraft) throws -> NotesFolderRecord
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail
  func deleteNote(id: String) throws -> Bool
  func purgeNote(id: String) throws -> Bool
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail
}

public extension NotesMutating {
  func reorderFolder(_ draft: NotesFolderReorderDraft) throws -> NotesFolderRecord {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Notes folder sidebar order mutation requires a private Notes framework writer.",
      details: [
        "operation": "notes.folders.reorder",
        "capability": "custom_sidebar_folder_order",
        "folder_id_sha256": sha256Hex(draft.folderID),
      ]
    )
  }
}
