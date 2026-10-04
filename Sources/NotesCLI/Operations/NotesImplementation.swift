import Utility

func makeDefaultNotesImplementation() -> any NotesReading & NotesMutating {
  NotesImplementation()
}

struct NotesImplementation: NotesReading, NotesFolderPurgeReading,
  NotesFolderPurging, NotesTagReading, NotesAttachmentReading,
  NotesAttachmentMutating, NotesAttachmentSearchIndexMutating, NotesLinkReading, NotesLinkMutating, NotesSmartFolderReading, NotesSmartFolderMutating, NotesFolderMoveImpactReading, NotesBodyStructureReading,
  NotesBodyMathExpressionScanning, NotesBodyMutating, NotesParagraphAnchorResolving, NotesNoteStateReading, NotesNoteStateMutating, NotesCollaborationLinkReading, NotesCollaborationParticipantsReading, NotesCollaborationPermissionMutating, NotesCollaborationSharingMutating, NotesCollaborationAccessScopeMutating, NotesCollaborationStopSharingMutating, NotesCollaborationInvitePolicyMutating, NotesCollaborationSelfRemovalMutating, NotesCollaborationParticipantMutating, NotesCollaborationMentionMutating, NotesNoteActivityReading, NotesSettingsReading, NotesSettingsMutating,
  NotesNoteExporting, NotesLockedContentExporting, NotesRichImporting, NotesMarkdownImporting, NotesRichReplacing, NotesENEXImporting, NotesTagMutating,
  NotesAccountScopedListing, NotesAccountScopedSearching, NotesNaturalLanguageSearching, NotesMutating
{
  private let reader = NotesReader()
  private let writer = NotesWriter()

  func listAccounts() throws -> [NotesAccountRecord] {
    try reader.listAccounts()
  }

  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    try reader.listFolders(account: account, limit: limit)
  }

  func listPurgableFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    try reader.listPurgableFolders(account: account, limit: limit)
  }

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try reader.listNotes(folder: folder, limit: limit)
  }

  func listNotes(account: String?, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try reader.listNotes(account: account, folder: folder, limit: limit)
  }

  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try reader.searchNotes(query: query, folder: folder, limit: limit)
  }

  func searchNotes(query: String, account: String?, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try reader.searchNotes(query: query, account: account, folder: folder, limit: limit)
  }

  func searchNaturalLanguageNotes(
    query: String,
    account: String?,
    folder: String?,
    limit: Int
  ) throws -> NotesNaturalLanguageSearchEvidence {
    try reader.searchNaturalLanguageNotes(query: query, account: account, folder: folder, limit: limit)
  }

  func readNote(id: String) throws -> NotesNoteDetail? {
    try reader.readNote(id: id)
  }

  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    try reader.readNotesByTitle(title, folder: folder, limit: limit)
  }

  func listTags(account: String?, limit: Int) throws -> [NotesTagRecord] {
    try reader.listTags(account: account, limit: limit)
  }

  func readNotes(tag: String, limit: Int) throws -> [NotesNoteDetail] {
    try reader.readNotes(tag: tag, limit: limit)
  }

  func listAttachments(noteID id: String, limit: Int) throws -> [NotesAttachmentRecord] {
    try reader.listAttachments(noteID: id, limit: limit)
  }

  func exportAttachment(noteID id: String, attachmentID: String) throws -> NotesAttachmentExportSource {
    try reader.exportAttachment(noteID: id, attachmentID: attachmentID)
  }

  func exportAttachmentPDF(noteID id: String, attachmentID: String) throws -> NotesAttachmentPDFExportSource {
    try reader.exportAttachmentPDF(noteID: id, attachmentID: attachmentID)
  }

  func inspectAttachmentScanPDF(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentScanPDFInspectionSource
  {
    try reader.inspectAttachmentScanPDF(noteID: id, attachmentID: attachmentID)
  }

  func inspectAttachmentMarkup(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentMarkupInspectionSource
  {
    try reader.inspectAttachmentMarkup(noteID: id, attachmentID: attachmentID)
  }

  func readAttachmentImageDescription(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentImageDescriptionSource
  {
    try reader.readAttachmentImageDescription(noteID: id, attachmentID: attachmentID)
  }

  func readAttachmentAudioTranscript(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentAudioTranscriptSource
  {
    try reader.readAttachmentAudioTranscript(noteID: id, attachmentID: attachmentID)
  }

  func readAttachmentSearchableText(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentSearchableTextSource
  {
    try reader.readAttachmentSearchableText(noteID: id, attachmentID: attachmentID)
  }

  func reindexAttachmentSearchableText(_ draft: NotesAttachmentSearchIndexDraft) throws
    -> NotesAttachmentSearchIndexWriteResult
  {
    try reader.reindexAttachmentSearchableText(draft)
  }

  func addAttachment(_ draft: NotesAttachmentAddDraft) throws -> NotesAttachmentAddWriteResult {
    try writer.addAttachment(draft)
  }

  func renameAttachment(_ draft: NotesAttachmentRenameDraft) throws -> NotesAttachmentRenameWriteResult {
    try writer.renameAttachment(draft)
  }

  func removeAttachment(_ draft: NotesAttachmentRemoveDraft) throws -> NotesAttachmentRemoveWriteResult {
    try writer.removeAttachment(draft)
  }

  func rotateScanAttachment(_ draft: NotesAttachmentScanRotateDraft) throws
    -> NotesAttachmentScanRotateWriteResult
  {
    try writer.rotateScanAttachment(draft)
  }

  func cropScanAttachment(_ draft: NotesAttachmentScanCropDraft) throws
    -> NotesAttachmentScanCropWriteResult
  {
    try writer.cropScanAttachment(draft)
  }

  func filterScanAttachment(_ draft: NotesAttachmentScanFilterDraft) throws
    -> NotesAttachmentScanFilterWriteResult
  {
    try writer.filterScanAttachment(draft)
  }

  func moveScanPage(_ draft: NotesAttachmentScanPageMoveDraft) throws
    -> NotesAttachmentScanPageMoveWriteResult
  {
    try writer.moveScanPage(draft)
  }

  func deleteScanPage(_ draft: NotesAttachmentScanPageDeleteDraft) throws
    -> NotesAttachmentScanPageDeleteWriteResult
  {
    try writer.deleteScanPage(draft)
  }

  func cropPDF(_ draft: NotesAttachmentPDFCropDraft) throws
    -> NotesAttachmentPDFCropWriteResult
  {
    try writer.cropPDF(draft)
  }

  func cropImageAttachment(_ draft: NotesAttachmentImageCropDraft) throws
    -> NotesAttachmentImageCropWriteResult
  {
    try writer.cropImageAttachment(draft)
  }

  func rotateImageAttachment(_ draft: NotesAttachmentImageRotateDraft) throws
    -> NotesAttachmentImageRotateWriteResult
  {
    try writer.rotateImageAttachment(draft)
  }

  func rotatePDFPage(_ draft: NotesAttachmentPDFPageRotateDraft) throws
    -> NotesAttachmentPDFPageRotateWriteResult
  {
    try writer.rotatePDFPage(draft)
  }

  func movePDFPage(_ draft: NotesAttachmentPDFPageMoveDraft) throws
    -> NotesAttachmentPDFPageMoveWriteResult
  {
    try writer.movePDFPage(draft)
  }

  func deletePDFPage(_ draft: NotesAttachmentPDFPageDeleteDraft) throws
    -> NotesAttachmentPDFPageDeleteWriteResult
  {
    try writer.deletePDFPage(draft)
  }

  func applyAttachmentMarkup(_ draft: NotesAttachmentMarkupEditDraft) throws
    -> NotesAttachmentMarkupEditWriteResult
  {
    try writer.applyAttachmentMarkup(draft)
  }

  func setAttachmentImageDescription(_ draft: NotesAttachmentImageDescriptionDraft) throws
    -> NotesAttachmentImageDescriptionWriteResult
  {
    try writer.setAttachmentImageDescription(draft)
  }

  func listLinks(noteID id: String, limit: Int) throws -> [NotesLinkRecord] {
    try reader.listLinks(noteID: id, limit: limit)
  }

  func listBacklinks(noteID id: String, limit: Int) throws -> [NotesBacklinkRecord] {
    try reader.listBacklinks(noteID: id, limit: limit)
  }

  func resolveLink(noteID id: String, linkID: String) throws -> NotesLinkResolutionRecord {
    try reader.resolveLink(noteID: id, linkID: linkID)
  }

  func addLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try writer.addLink(draft)
  }

  func addWebpageAttachment(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try writer.addWebpageAttachment(draft)
  }

  func updateWebpageAttachment(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try writer.updateWebpageAttachment(draft)
  }

  func addAppLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try writer.addAppLink(draft)
  }

  func addFileLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try writer.addFileLink(draft)
  }

  func addNoteLink(_ draft: NotesNoteLinkAddDraft) throws -> NotesNoteLinkAddWriteResult {
    try writer.addNoteLink(draft)
  }

  func addParagraphLink(_ draft: NotesParagraphLinkAddDraft) throws -> NotesParagraphLinkAddWriteResult {
    try writer.addParagraphLink(draft)
  }

  func updateLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try writer.updateLink(draft)
  }

  func updateAppLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try writer.updateAppLink(draft)
  }

  func updateFileLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try writer.updateFileLink(draft)
  }

  func updateNoteLink(_ draft: NotesNoteLinkUpdateDraft) throws -> NotesNoteLinkUpdateWriteResult {
    try writer.updateNoteLink(draft)
  }

  func updateParagraphLink(_ draft: NotesParagraphLinkUpdateDraft) throws
    -> NotesParagraphLinkUpdateWriteResult
  {
    try writer.updateParagraphLink(draft)
  }

  func removeAppLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult {
    try writer.removeAppLink(draft)
  }

  func removeNoteLink(_ draft: NotesNoteLinkRemoveDraft) throws -> NotesNoteLinkRemoveWriteResult {
    try writer.removeNoteLink(draft)
  }

  func removeParagraphLink(_ draft: NotesParagraphLinkRemoveDraft) throws -> NotesParagraphLinkRemoveWriteResult {
    try writer.removeParagraphLink(draft)
  }

  func removeFileLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult {
    try writer.removeFileLink(draft)
  }

  func removeLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult {
    try writer.removeLink(draft)
  }

  func listSmartFolders(account: String?, limit: Int) throws -> [NotesSmartFolderRecord] {
    try reader.listSmartFolders(account: account, limit: limit)
  }

  func listSmartFolderNotes(smartFolderID: String, limit: Int) throws -> [NotesNoteSummary] {
    try reader.listSmartFolderNotes(smartFolderID: smartFolderID, limit: limit)
  }

  func exportSmartFolderCriteria(smartFolderID: String) throws -> NotesSmartFolderCriteriaExportSource {
    try reader.exportSmartFolderCriteria(smartFolderID: smartFolderID)
  }

  func createSmartFolder(_ draft: NotesSmartFolderCreateDraft) throws -> NotesSmartFolderCreateWriteResult {
    try writer.createSmartFolder(draft)
  }

  func updateSmartFolder(_ draft: NotesSmartFolderUpdateDraft) throws -> NotesSmartFolderUpdateWriteResult {
    try writer.updateSmartFolder(draft)
  }

  func createSmartFolderBuiltInCriteria(_ draft: NotesSmartFolderBuiltInCriteriaCreateDraft) throws
    -> NotesSmartFolderBuiltInCriteriaCreateWriteResult
  {
    try writer.createSmartFolderBuiltInCriteria(draft)
  }

  func updateSmartFolderBuiltInCriteria(_ draft: NotesSmartFolderBuiltInCriteriaUpdateDraft) throws
    -> NotesSmartFolderBuiltInCriteriaUpdateWriteResult
  {
    try writer.updateSmartFolderBuiltInCriteria(draft)
  }

  func duplicateSmartFolder(_ draft: NotesSmartFolderDuplicateDraft) throws -> NotesSmartFolderDuplicateWriteResult {
    try writer.duplicateSmartFolder(draft)
  }

  func copySmartFolderCriteria(_ draft: NotesSmartFolderCriteriaCopyDraft) throws
    -> NotesSmartFolderCriteriaCopyWriteResult
  {
    try writer.copySmartFolderCriteria(draft)
  }

  func importSmartFolderCriteria(_ draft: NotesSmartFolderCriteriaImportDraft) throws
    -> NotesSmartFolderCriteriaImportWriteResult
  {
    try writer.importSmartFolderCriteria(draft)
  }

  func renameSmartFolder(_ draft: NotesSmartFolderRenameDraft) throws -> NotesSmartFolderRecord {
    try writer.renameSmartFolder(draft)
  }

  func deleteSmartFolder(_ draft: NotesSmartFolderDeleteDraft) throws -> Bool {
    try writer.deleteSmartFolder(draft)
  }

  func convertFolderToSmartFolder(_ draft: NotesSmartFolderFolderConversionDraft) throws
    -> NotesSmartFolderFolderConversionWriteResult
  {
    try writer.convertFolderToSmartFolder(draft)
  }

  func readBodyStructure(noteID id: String) throws -> NotesBodyStructureRecord {
    try reader.readBodyStructure(noteID: id)
  }

  func readInlineSelection(noteID: String, paragraphIDSHA256: String?, ordinal: Int?,
    text: String, occurrence: Int?) throws -> NotesBodyInlineSelectionReadback {
    try reader.readInlineSelection(noteID: noteID, paragraphIDSHA256: paragraphIDSHA256,
      ordinal: ordinal, text: text, occurrence: occurrence)
  }

  func listTables(noteID id: String) throws -> [NotesBodyTableRecord] {
    try reader.listTables(noteID: id)
  }

  func readTableCell(noteID id: String, tableOrdinal: Int, row: Int, column: Int) throws
    -> NotesBodyTableCellRecord
  {
    try reader.readTableCell(noteID: id, tableOrdinal: tableOrdinal, row: row, column: column)
  }

  func listMathResults(noteID id: String) throws -> [NotesBodyMathResultRecord] {
    try reader.listMathResults(noteID: id)
  }

  func readMathResultsPreference(noteID id: String) throws -> NotesBodyMathResultsPreferenceRecord {
    try reader.readMathResultsPreference(noteID: id)
  }

  func scanMathExpression(_ draft: NotesBodyMathExpressionScanDraft) throws
    -> NotesBodyMathExpressionScanRecord
  {
    try reader.scanMathExpression(draft)
  }

  func readFolderMoveImpact(_ draft: NotesFolderMoveDraft) throws -> NotesFolderMoveImpactRecord {
    try reader.readFolderMoveImpact(draft)
  }

  func listCollapsibleSections(noteID id: String) throws -> [NotesBodyCollapsibleSectionRecord] {
    try reader.listCollapsibleSections(noteID: id)
  }

  func addChecklistItem(_ draft: NotesBodyChecklistAddDraft) throws -> NotesBodyChecklistAddWriteResult {
    try writer.addChecklistItem(draft)
  }

  func setChecklistItemState(_ draft: NotesBodyChecklistSetDraft) throws -> NotesBodyChecklistSetWriteResult {
    try writer.setChecklistItemState(draft)
  }

  func setAllChecklistItemStates(_ draft: NotesBodyChecklistSetAllDraft) throws
    -> NotesBodyChecklistSetAllWriteResult
  {
    try writer.setAllChecklistItemStates(draft)
  }

  func sortChecklistItems(_ draft: NotesBodyChecklistSortDraft) throws -> NotesBodyChecklistSortWriteResult {
    try writer.sortChecklistItems(draft)
  }

  func convertParagraphToChecklistItem(_ draft: NotesBodyChecklistConvertDraft) throws
    -> NotesBodyChecklistConvertWriteResult
  {
    try writer.convertParagraphToChecklistItem(draft)
  }

  func convertParagraphRangeToChecklistItems(_ draft: NotesBodyChecklistConvertRangeDraft) throws
    -> NotesBodyChecklistConvertRangeWriteResult
  {
    try writer.convertParagraphRangeToChecklistItems(draft)
  }

  func reorderChecklistItem(_ draft: NotesBodyChecklistReorderDraft) throws
    -> NotesBodyChecklistReorderWriteResult
  {
    try writer.reorderChecklistItem(draft)
  }

  func indentChecklistItem(_ draft: NotesBodyChecklistIndentDraft) throws
    -> NotesBodyChecklistIndentWriteResult
  {
    try writer.indentChecklistItem(draft)
  }

  func deleteChecklistItem(_ draft: NotesBodyChecklistDeleteDraft) throws
    -> NotesBodyChecklistDeleteWriteResult
  {
    try writer.deleteChecklistItem(draft)
  }

  func addListItem(_ draft: NotesBodyListAddDraft) throws -> NotesBodyListAddWriteResult {
    try writer.addListItem(draft)
  }

  func convertParagraphToListItem(_ draft: NotesBodyListConvertDraft) throws
    -> NotesBodyListConvertWriteResult
  {
    try writer.convertParagraphToListItem(draft)
  }

  func convertParagraphRangeToListItems(_ draft: NotesBodyListConvertRangeDraft) throws
    -> NotesBodyListConvertRangeWriteResult
  {
    try writer.convertParagraphRangeToListItems(draft)
  }

  func setListItemStyle(_ draft: NotesBodyListSetStyleDraft) throws -> NotesBodyListSetStyleWriteResult {
    try writer.setListItemStyle(draft)
  }

  func reorderListItem(_ draft: NotesBodyListReorderDraft) throws
    -> NotesBodyListReorderWriteResult
  {
    try writer.reorderListItem(draft)
  }

  func indentListItem(_ draft: NotesBodyListIndentDraft) throws
    -> NotesBodyListIndentWriteResult
  {
    try writer.indentListItem(draft)
  }

  func deleteListItem(_ draft: NotesBodyListDeleteDraft) throws
    -> NotesBodyListDeleteWriteResult
  {
    try writer.deleteListItem(draft)
  }

  func insertTextInListItem(_ draft: NotesBodyListTextInsertDraft) throws
    -> NotesBodyListTextInsertWriteResult
  {
    try writer.insertTextInListItem(draft)
  }

  func endList(_ draft: NotesBodyListEndDraft) throws -> NotesBodyListEndWriteResult {
    try writer.endList(draft)
  }

  func createTable(_ draft: NotesBodyTableCreateDraft) throws -> NotesBodyTableCreateWriteResult {
    try writer.createTable(draft)
  }

  func importTable(_ draft: NotesBodyTableImportDraft) throws -> NotesBodyTableImportWriteResult {
    try writer.importTable(draft)
  }

  func updateTableCell(_ draft: NotesBodyTableUpdateDraft) throws -> NotesBodyTableUpdateWriteResult {
    try writer.updateTableCell(draft)
  }

  func deleteTable(_ draft: NotesBodyTableDeleteDraft) throws -> NotesBodyTableDeleteWriteResult {
    try writer.deleteTable(draft)
  }

  func convertTableToText(_ draft: NotesBodyTableConvertToTextDraft) throws
    -> NotesBodyTableConvertToTextWriteResult
  {
    try writer.convertTableToText(draft)
  }

  func convertTextToTable(_ draft: NotesBodyTableConvertFromTextDraft) throws
    -> NotesBodyTableConvertFromTextWriteResult
  {
    try writer.convertTextToTable(draft)
  }

  func copyTable(_ draft: NotesBodyTableCopyDraft) throws -> NotesBodyTableCopyWriteResult {
    try writer.copyTable(draft)
  }

  func moveTable(_ draft: NotesBodyTableMoveDraft) throws -> NotesBodyTableMoveWriteResult {
    try writer.moveTable(draft)
  }

  func changeTableStructure(_ draft: NotesBodyTableStructureDraft) throws -> NotesBodyTableStructureWriteResult {
    try writer.changeTableStructure(draft)
  }

  func formatTableRange(_ draft: NotesBodyTableFormatDraft) throws -> NotesBodyTableFormatWriteResult {
    try writer.formatTableRange(draft)
  }

  func insertMathResult(_ draft: NotesBodyMathInsertDraft) throws -> NotesBodyMathInsertWriteResult {
    try writer.insertMathResult(draft)
  }

  func updateMathResult(_ draft: NotesBodyMathUpdateDraft) throws -> NotesBodyMathUpdateWriteResult {
    try writer.updateMathResult(draft)
  }

  func setMathVariable(_ draft: NotesBodyMathVariableSetDraft) throws -> NotesBodyMathVariableSetWriteResult {
    try writer.setMathVariable(draft)
  }

  func updateMathVariable(_ draft: NotesBodyMathVariableUpdateDraft) throws
    -> NotesBodyMathVariableUpdateWriteResult
  {
    try writer.updateMathVariable(draft)
  }

  func setMathResultsPreference(_ draft: NotesBodyMathResultsPreferenceDraft) throws
    -> NotesBodyMathResultsPreferenceWriteResult
  {
    try writer.setMathResultsPreference(draft)
  }

  func setCollapsibleSectionState(_ draft: NotesBodyCollapsibleSetDraft) throws
    -> NotesBodyCollapsibleSetWriteResult
  {
    try writer.setCollapsibleSectionState(draft)
  }

  func setParagraphStyle(_ draft: NotesBodyParagraphStyleDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  {
    try writer.setParagraphStyle(draft)
  }

  func setParagraphAlignment(_ draft: NotesBodyParagraphAlignmentDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  {
    try writer.setParagraphAlignment(draft)
  }

  func setParagraphBlockQuote(_ draft: NotesBodyParagraphQuoteDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  {
    try writer.setParagraphBlockQuote(draft)
  }

  func setInlineFormat(_ draft: NotesBodyInlineFormatDraft) throws
    -> NotesBodyInlineFormatWriteResult
  {
    try writer.setInlineFormat(draft)
  }

  func setInlineForegroundColor(_ draft: NotesBodyInlineColorDraft) throws
    -> NotesBodyInlineColorWriteResult
  {
    try writer.setInlineForegroundColor(draft)
  }

  func setInlineHighlightColor(_ draft: NotesBodyInlineColorDraft) throws
    -> NotesBodyInlineColorWriteResult
  {
    try writer.setInlineHighlightColor(draft)
  }

  func setInlineFont(_ draft: NotesBodyInlineFontDraft) throws
    -> NotesBodyInlineFormatWriteResult
  {
    try writer.setInlineFont(draft)
  }

  func resolveParagraphAnchor(noteID id: String, paragraphIDSHA256: String) throws -> NotesParagraphAnchorResolution {
    try reader.resolveParagraphAnchor(noteID: id, paragraphIDSHA256: paragraphIDSHA256)
  }

  func readNoteState(noteID id: String) throws -> NotesNoteStateRecord {
    try reader.readNoteState(noteID: id)
  }

  func setSharedNoteAlertsHidden(_ draft: NotesSharedNoteAlertsMutationDraft) throws
    -> NotesSharedNoteAlertsWriteResult
  {
    try reader.setSharedNoteAlertsHidden(draft)
  }

  func closeLockedSession(_ draft: NotesLockedSessionCloseDraft) throws
    -> NotesLockedSessionCloseWriteResult
  {
    try reader.closeLockedSession(draft)
  }

  func setNoteLockState(_ draft: NotesNoteLockMutationDraft) throws
    -> NotesNoteLockMutationWriteResult
  {
    try writer.setNoteLockState(draft)
  }

  func unlockNote(_ draft: NotesNoteUnlockDraft) throws
    -> NotesNoteUnlockWriteResult
  {
    try writer.unlockNote(draft)
  }

  func readCollaborationLink(_ draft: NotesCollaborationLinkDraft) throws
    -> NotesCollaborationLinkReadResult
  {
    try reader.readCollaborationLink(draft)
  }

  func readCollaborationParticipants(_ draft: NotesCollaborationParticipantsDraft) throws
    -> NotesCollaborationParticipantsReadResult
  {
    try reader.readCollaborationParticipants(draft)
  }

  func setCollaborationParticipantPermission(_ draft: NotesCollaborationPermissionMutationDraft) throws
    -> NotesCollaborationPermissionWriteResult
  {
    try writer.setCollaborationParticipantPermission(draft)
  }

  func shareCollaboration(_ draft: NotesCollaborationShareMutationDraft) throws
    -> NotesCollaborationShareWriteResult
  {
    try writer.shareCollaboration(draft)
  }

  func setCollaborationAccessScope(_ draft: NotesCollaborationAccessScopeMutationDraft) throws
    -> NotesCollaborationAccessScopeWriteResult
  {
    try writer.setCollaborationAccessScope(draft)
  }

  func stopSharing(_ draft: NotesCollaborationStopSharingDraft) throws
    -> NotesCollaborationStopSharingWriteResult
  {
    try writer.stopSharing(draft)
  }

  func setCollaborationInvitePolicy(_ draft: NotesCollaborationAllowInvitesDraft) throws
    -> NotesCollaborationAllowInvitesWriteResult
  {
    try writer.setCollaborationInvitePolicy(draft)
  }

  func removeSelfFromCollaboration(_ draft: NotesCollaborationSelfRemovalDraft) throws
    -> NotesCollaborationSelfRemovalWriteResult
  {
    try writer.removeSelfFromCollaboration(draft)
  }

  func removeCollaborationParticipant(_ draft: NotesCollaborationParticipantRemovalDraft) throws
    -> NotesCollaborationParticipantRemovalWriteResult
  {
    try writer.removeCollaborationParticipant(draft)
  }

  func insertParticipantMention(_ draft: NotesCollaborationMentionDraft) throws
    -> NotesCollaborationMentionWriteResult
  {
    try writer.insertParticipantMention(draft)
  }

  func readNoteActivity(noteID id: String) throws -> NotesNoteActivityRecord {
    try reader.readNoteActivity(noteID: id)
  }

  func readSettings(account: String?) throws -> NotesSettingsReadEvidence {
    try reader.readSettings(account: account)
  }

  func setNoteListSort(_ draft: NotesSettingsSortMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setNoteListSort(draft)
  }

  func setDefaultNewNoteStyle(_ draft: NotesSettingsParagraphStyleMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setDefaultNewNoteStyle(draft)
  }

  func setDefaultAccount(_ draft: NotesSettingsDefaultAccountMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setDefaultAccount(draft)
  }

  func setGroupNotesByDate(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setGroupNotesByDate(draft)
  }

  func setDateHeadersPreference(_ draft: NotesSettingsDateHeadersMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setDateHeadersPreference(draft)
  }

  func setQuickNoteResumeLast(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setQuickNoteResumeLast(draft)
  }

  func setMentionNotifications(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setMentionNotifications(draft)
  }

  func setDefaultTextSize(_ draft: NotesSettingsTextSizeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setDefaultTextSize(draft)
  }

  func setOnMyMacAccountEnabled(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setOnMyMacAccountEnabled(draft)
  }

  func setChecklistAutoSort(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setChecklistAutoSort(draft)
  }

  func setTouchIDPreference(_ draft: NotesSettingsAccountBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setTouchIDPreference(draft)
  }

  func setCustomPassphrase(_ draft: NotesSettingsPassphraseMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setCustomPassphrase(draft)
  }

  func changeCustomPassphrase(_ draft: NotesSettingsPassphraseChangeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.changeCustomPassphrase(draft)
  }

  func setLockedNotesMethod(_ draft: NotesSettingsLockedNotesMethodMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    try reader.setLockedNotesMethod(draft)
  }

  func exportNotePDF(noteID id: String) throws -> NotesNotePDFExportSource {
    try reader.exportNotePDF(noteID: id)
  }

  func exportNoteMarkdown(noteID id: String, includeAttachments: Bool) throws -> NotesNoteMarkdownExportSource {
    try reader.exportNoteMarkdown(noteID: id, includeAttachments: includeAttachments)
  }

  func exportNoteHTML(
    noteID id: String,
    includeAttachments: Bool,
    includeAttachmentResources: Bool
  ) throws -> NotesNoteHTMLExportSource {
    try reader.exportNoteHTML(
      noteID: id,
      includeAttachments: includeAttachments,
      includeAttachmentResources: includeAttachmentResources
    )
  }

  func exportNoteRTF(noteID id: String) throws -> NotesNoteRTFExportSource {
    try reader.exportNoteRTF(noteID: id)
  }

  func exportNoteRTFD(noteID id: String) throws -> NotesNoteRTFDExportSource {
    try reader.exportNoteRTFD(noteID: id)
  }

  func exportUnlockedLockedContent(_ draft: NotesLockedContentExportDraft) throws
    -> NotesLockedContentExportSource
  {
    try reader.exportUnlockedLockedContent(draft)
  }

  func importRichText(_ draft: NotesRichImportDraft) throws -> NotesRichImportResult {
    try writer.importRichText(draft)
  }

  func importMarkdown(_ draft: NotesMarkdownImportDraft) throws -> NotesMarkdownImportResult {
    try writer.importMarkdown(draft)
  }

  func replaceRichText(_ draft: NotesRichReplaceDraft) throws -> NotesRichReplaceResult {
    try writer.replaceRichText(draft)
  }

  func importENEX(_ draft: NotesENEXImportDraft) throws -> NotesENEXImportResult {
    try writer.importENEX(draft)
  }

  func addTag(_ tag: String, toNoteID id: String) throws -> NotesTagMutationWriteResult {
    try writer.addTag(tag, toNoteID: id)
  }

  func removeTag(_ tag: String, fromNoteID id: String) throws -> NotesTagMutationWriteResult {
    try writer.removeTag(tag, fromNoteID: id)
  }

  func convertTagToText(_ draft: NotesTagConvertToTextDraft) throws -> NotesTagConvertToTextWriteResult {
    try writer.convertTagToText(draft)
  }

  func renameTag(_ draft: NotesTagRenameDraft) throws -> NotesTagRenameWriteResult {
    try writer.renameTag(draft)
  }

  func deleteTag(_ draft: NotesTagDeleteDraft) throws -> NotesTagDeleteWriteResult {
    try writer.deleteTag(draft)
  }

  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    try writer.createNote(draft)
  }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    try writer.createFolder(draft)
  }

  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    try writer.renameFolder(draft)
  }

  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    try writer.moveFolder(draft)
  }

  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    try writer.deleteFolder(draft)
  }

  func purgeFolder(_ draft: NotesFolderPurgeDraft) throws -> Bool {
    try writer.purgeFolder(draft)
  }

  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    try writer.sortFolder(draft)
  }

  func reorderFolder(_ draft: NotesFolderReorderDraft) throws -> NotesFolderRecord {
    try writer.reorderFolder(draft)
  }

  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    try writer.setFolderDateHeaders(draft)
  }

  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    try writer.updateNote(id: id, patch: patch)
  }

  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    try writer.moveNote(draft)
  }

  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    try writer.copyNote(draft)
  }

  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    try reader.readRestorableNote(id: id)
  }

  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    try reader.listRestorableNotes(limit: limit)
  }

  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    try writer.restoreNote(draft)
  }

  func deleteNote(id: String) throws -> Bool {
    try writer.deleteNote(id: id)
  }

  func purgeNote(id: String) throws -> Bool {
    try writer.purgeNote(id: id)
  }

  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    try writer.setNotePinned(id: id, pinned: pinned)
  }
}
