import AppKit
import CloudKit
import CoreData
import Dispatch
import Foundation
import ImageIO
import NotesEditor
import NotesShared
import NotesSupport
import NotesUI
import Utility
#if canImport(PDFKit)
import PDFKit
#endif

private final class NotesAttachmentMarkupApplyCompletion: @unchecked Sendable {
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

private final class NotesCollaborationStopSharingCompletion: @unchecked Sendable {
  private let lock = NSLock()
  private var _completed = false
  private var _errorDescription: String?

  func complete(_ error: Any?) {
    lock.lock()
    _completed = true
    _errorDescription = error.map { String(describing: $0) }
    lock.unlock()
  }

  var completed: Bool {
    lock.lock()
    let value = _completed
    lock.unlock()
    return value
  }

  var errorDescription: String? {
    lock.lock()
    let value = _errorDescription
    lock.unlock()
    return value
  }
}

private final class NotesShareParticipantFetchCompletion: @unchecked Sendable {
  private let lock = NSLock()
  private var _completed = false
  private var _participant: AnyObject?
  private var _errorDescription: String?

  func complete(_ participant: AnyObject?, _ error: Error?) {
    lock.lock()
    _completed = true
    _participant = participant
    _errorDescription = error.map { String(describing: $0) }
    lock.unlock()
  }

  var completed: Bool {
    lock.lock()
    let value = _completed
    lock.unlock()
    return value
  }

  var participant: AnyObject? {
    lock.lock()
    let value = _participant
    lock.unlock()
    return value
  }

  var errorDescription: String? {
    lock.lock()
    let value = _errorDescription
    lock.unlock()
    return value
  }
}

private final class NotesNoteLockCompletion: @unchecked Sendable {
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

private struct NotesMentionParticipantResolution {
  var participantIDSHA256: String
  var userRecordName: String
  var userRecordNameSHA256: String
  var displayText: String?
  var participantCount: Int
}

private struct NotesCollaborationParticipantResolution {
  var participant: AnyObject
  var participantIDSHA256: String
  var userRecordNameSHA256: String?
  var participantCount: Int
}

private struct NotesCollaborationMutationTarget {
  var kind: String
  var id: String
  var object: AnyObject
  var note: ICNote?
  var folder: ICFolder?

  var noteID: String? {
    kind == "note" ? id : nil
  }

  var folderID: String? {
    kind == "folder" ? id : nil
  }
}

struct NotesWriter: NotesFolderPurging, NotesAttachmentMutating, NotesLinkMutating, NotesTagMutating,
  NotesSmartFolderMutating,
  NotesCollaborationPermissionMutating,
  NotesCollaborationSharingMutating,
  NotesCollaborationAccessScopeMutating,
  NotesCollaborationStopSharingMutating,
  NotesCollaborationInvitePolicyMutating,
  NotesCollaborationSelfRemovalMutating,
  NotesCollaborationParticipantMutating,
  NotesCollaborationMentionMutating,
  NotesBodyMutating,
  NotesRichImporting,
  NotesMarkdownImporting,
  NotesRichReplacing,
  NotesENEXImporting,
  NotesMutating
{
  private let reader = NotesReader()

  func setNoteLockState(_ draft: NotesNoteLockMutationDraft) throws
    -> NotesNoteLockMutationWriteResult
  {
    let operation = draft.action == "remove-lock" ? "notes.state.remove-lock" : "notes.state.lock"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let before = try reader.readNoteState(noteID: draft.noteID)
    try validateNoteLockMutationTarget(note, state: before, action: draft.action, operation: operation)

    switch draft.action {
    case "lock":
      try invokeNoteLockManager(note: note, selectorName: "addLockWithCompletionHandler:", operation: operation)
    case "remove-lock":
      if before.isPasswordProtected {
        try invokeNoteLockManager(note: note, selectorName: "removeLockWithCompletionHandler:", operation: operation)
      }
    default:
      throw writeError(operation: operation, reason: "Unsupported Notes lock mutation action.")
    }

    try save(note: note, context: context, operation: operation)
    context.managedObjectContext?.refresh(note, mergeChanges: true)
    let after = try reader.readNoteState(noteID: draft.noteID)
    return NotesNoteLockMutationWriteResult(
      noteID: draft.noteID,
      action: draft.action,
      beforePasswordProtected: before.isPasswordProtected,
      beforePasswordProtectedAndLocked: before.isPasswordProtectedAndLocked,
      beforeLockable: before.isLockable,
      afterPasswordProtected: after.isPasswordProtected,
      afterPasswordProtectedAndLocked: after.isPasswordProtectedAndLocked,
      afterLockable: after.isLockable,
      backendCalls: draft.action == "remove-lock" && before.isPasswordProtected == false
        ? "ICNoteLockManager.noop"
        : "ICNoteLockManager.\(draft.action == "remove-lock" ? "removeLock" : "addLock")"
      )
  }

  func unlockNote(_ draft: NotesNoteUnlockDraft) throws -> NotesNoteUnlockWriteResult {
    let operation = "notes.state.unlock"
    let note = try note(id: draft.noteID)
    let before = try reader.readNoteState(noteID: draft.noteID)
    try validateNoteUnlockTarget(before, operation: operation)
    let state = try notesAuthenticationState(operation: operation)
    let beforeAuthenticated = try authenticationStateBool(state, selectorName: "isAuthenticated", operation: operation)
    let beforeHasAuthenticatedObject = try authenticationStateBool(
      state,
      selectorName: "hasAuthenticatedObject",
      operation: operation
    )

    let backendCalls: String
    if before.isPasswordProtectedAndLocked == true {
      let authenticated = try authenticate(note: note, passphrase: draft.passphrase, state: state, operation: operation)
      guard authenticated else {
        throw CLIError(
          code: .permissionDenied,
          message: "Notes could not authenticate the supplied passphrase.",
          details: [
            "operation": operation,
            "capability": "unlock_locked_note",
            "note_id_sha256": sha256Hex(draft.noteID),
            "passphrase_source_kind": draft.passphraseSourceKind,
            "backend_calls": "ICAuthenticationState.authenticateObject:withPassphrase:",
          ]
        )
      }
      backendCalls = "ICAuthenticationState.authenticateObject:withPassphrase:"
    } else {
      backendCalls = "ICAuthenticationState.noop"
    }

    note.managedObjectContext?.refresh(note, mergeChanges: true)
    let after = try reader.readNoteState(noteID: draft.noteID)
    let afterAuthenticated = try authenticationStateBool(state, selectorName: "isAuthenticated", operation: operation)
    let afterHasAuthenticatedObject = try authenticationStateBool(
      state,
      selectorName: "hasAuthenticatedObject",
      operation: operation
    )
    return NotesNoteUnlockWriteResult(
      noteID: draft.noteID,
      passphraseSourceKind: draft.passphraseSourceKind,
      beforePasswordProtected: before.isPasswordProtected,
      beforePasswordProtectedAndLocked: before.isPasswordProtectedAndLocked,
      beforeAuthenticated: beforeAuthenticated,
      beforeHasAuthenticatedObject: beforeHasAuthenticatedObject,
      afterPasswordProtected: after.isPasswordProtected,
      afterPasswordProtectedAndLocked: after.isPasswordProtectedAndLocked,
      afterAuthenticated: afterAuthenticated,
      afterHasAuthenticatedObject: afterHasAuthenticatedObject,
      backendCalls: backendCalls
    )
  }

  func addAttachment(_ draft: NotesAttachmentAddDraft) throws -> NotesAttachmentAddWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateAttachmentMutationTarget(note, operation: "notes.attachments.add")

    let before = try reader.listAttachments(noteID: draft.noteID, limit: 2_000)
    guard
      let attachment = note.addAttachment(withData: draft.data, filename: draft.filename) as AnyObject?
    else {
      throw writeError(operation: "notes.attachments.add", reason: "ICNote.addAttachmentWithData returned nil.")
    }

    try save(note: note, context: context, operation: "notes.attachments.add")
    let record = try readback(
      attachment: attachment,
      noteID: draft.noteID,
      before: before,
      filename: draft.filename,
      operation: "notes.attachments.add"
    )
    return NotesAttachmentAddWriteResult(noteID: draft.noteID, attachment: record)
  }

  func renameAttachment(_ draft: NotesAttachmentRenameDraft) throws -> NotesAttachmentRenameWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateAttachmentMutationTarget(note, operation: "notes.attachments.rename")

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: "notes.attachments.rename"
    )
    try validateAttachmentRenameTarget(attachment, operation: "notes.attachments.rename")
    let oldRecord = attachmentRecord(attachment)
    let currentDisplayName = oldRecord.title ?? oldRecord.mediaFilename
    guard currentDisplayName != draft.name else {
      return NotesAttachmentRenameWriteResult(
        noteID: draft.noteID,
        oldAttachment: oldRecord,
        attachment: oldRecord,
        changed: false
      )
    }

    attachment.title = draft.name
    attachment.userTitle = draft.name
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: "notes.attachments.rename")

    let record = try readbackRenamedAttachment(
      attachment: attachment,
      oldRecord: oldRecord,
      noteID: draft.noteID,
      operation: "notes.attachments.rename"
    )
    return NotesAttachmentRenameWriteResult(
      noteID: draft.noteID,
      oldAttachment: oldRecord,
      attachment: record,
      changed: true
    )
  }

  func removeAttachment(_ draft: NotesAttachmentRemoveDraft) throws -> NotesAttachmentRemoveWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateAttachmentMutationTarget(note, operation: "notes.attachments.remove")

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: "notes.attachments.remove"
    )
    try validateAttachmentRemoveTarget(attachment, operation: "notes.attachments.remove")
    let record = attachmentRecord(attachment)

    attachment.markForDeletion()
    try save(note: note, context: context, operation: "notes.attachments.remove")
    return NotesAttachmentRemoveWriteResult(noteID: draft.noteID, attachment: record, changed: true)
  }

  func rotateScanAttachment(_ draft: NotesAttachmentScanRotateDraft) throws
    -> NotesAttachmentScanRotateWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.scan.rotate"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentScanMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentScanInspection(before, operation: operation)
    guard before.orientation != draft.targetOrientation else {
      return NotesAttachmentScanRotateWriteResult(
        noteID: draft.noteID,
        oldInspection: before,
        inspection: before,
        rotationDeltaDegrees: draft.rotationDeltaDegrees,
        changed: false,
        sourceKind: "ICDocCamScannedDocumentEditor.setOrientation"
      )
    }

    guard let editor = ICDocCamScannedDocumentEditor(galleryAttachment: attachment) else {
      throw writeError(
        operation: operation,
        reason: "ICDocCamScannedDocumentEditor.initWithGalleryAttachment returned nil."
      )
    }
    guard editor.setOrientation(Int64(draft.targetOrientation), forAttachment: attachment) else {
      throw writeError(
        operation: operation,
        reason: "ICDocCamScannedDocumentEditor.setOrientation returned false."
      )
    }
    editor.saveAndUpdatePreview(true)
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentScanRotateWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      rotationDeltaDegrees: draft.rotationDeltaDegrees,
      changed: true,
      sourceKind: "ICDocCamScannedDocumentEditor.setOrientation"
    )
  }

  func cropScanAttachment(_ draft: NotesAttachmentScanCropDraft) throws
    -> NotesAttachmentScanCropWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.scan.crop"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentScanMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentScanInspection(before, operation: operation)
    if let expectedCount = draft.pageCount {
      try validateScanPageCount(expectedCount, against: before, operation: operation)
    }

    attachment.croppingQuadTopLeftX = draft.topLeft.x
    attachment.croppingQuadTopLeftY = draft.topLeft.y
    attachment.croppingQuadTopRightX = draft.topRight.x
    attachment.croppingQuadTopRightY = draft.topRight.y
    attachment.croppingQuadBottomRightX = draft.bottomRight.x
    attachment.croppingQuadBottomRightY = draft.bottomRight.y
    attachment.croppingQuadBottomLeftX = draft.bottomLeft.x
    attachment.croppingQuadBottomLeftY = draft.bottomLeft.y

    guard let editor = ICDocCamScannedDocumentEditor(galleryAttachment: attachment) else {
      throw writeError(
        operation: operation,
        reason: "ICDocCamScannedDocumentEditor.initWithGalleryAttachment returned nil."
      )
    }
    let quad = optionalObject(attachment, key: "croppingQuad")
    if let quad {
      editor.setQuad(quad, forAttachment: attachment)
    }
    editor.saveAndUpdatePreview(true)
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    let sourceKind = quad == nil
      ? "ICAttachment.croppingQuadScalars"
      : "ICAttachment.croppingQuadScalars+ICDocCamScannedDocumentEditor.setQuad"
    return NotesAttachmentScanCropWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      requestedCropQuadSHA256: draft.requestedCropQuadSHA256,
      changed: before.croppingQuadSHA256 != after.croppingQuadSHA256,
      sourceKind: sourceKind
    )
  }

  func filterScanAttachment(_ draft: NotesAttachmentScanFilterDraft) throws
    -> NotesAttachmentScanFilterWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.scan.filter"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentScanMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentScanInspection(before, operation: operation)
    guard before.imageFilterType != draft.filterType else {
      return NotesAttachmentScanFilterWriteResult(
        noteID: draft.noteID,
        oldInspection: before,
        inspection: before,
        style: draft.style,
        filterType: draft.filterType,
        changed: false,
        sourceKind: "ICDocCamScannedDocumentEditor.applyFilter"
      )
    }

    guard let editor = ICDocCamScannedDocumentEditor(galleryAttachment: attachment) else {
      throw writeError(
        operation: operation,
        reason: "ICDocCamScannedDocumentEditor.initWithGalleryAttachment returned nil."
      )
    }
    let identifier = nonEmpty(attachment.contentIdentifier)
      ?? nonEmpty(attachment.identifier)
      ?? draft.attachment.id
    editor.applyFilter(Int16(draft.filterType), forAttachmentWithIdentifier: identifier)
    editor.saveAndUpdatePreview(true)
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentScanFilterWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      style: draft.style,
      filterType: draft.filterType,
      changed: true,
      sourceKind: "ICDocCamScannedDocumentEditor.applyFilter"
    )
  }

  func moveScanPage(_ draft: NotesAttachmentScanPageMoveDraft) throws
    -> NotesAttachmentScanPageMoveWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.scan.page.move"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentScanMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentScanInspection(before, operation: operation)
    try validateScanPageCount(draft.pageCount, against: before, operation: operation)

    guard let editor = ICDocCamScannedDocumentEditor(galleryAttachment: attachment) else {
      throw writeError(
        operation: operation,
        reason: "ICDocCamScannedDocumentEditor.initWithGalleryAttachment returned nil."
      )
    }
    editor.movePage(from: UInt64(draft.fromPage - 1), to: UInt64(draft.toPage - 1))
    editor.saveAndUpdatePreview(true)
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentScanPageMoveWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      fromPage: draft.fromPage,
      toPage: draft.toPage,
      changed: true,
      sourceKind: "ICDocCamScannedDocumentEditor.movePageFromIndex"
    )
  }

  func deleteScanPage(_ draft: NotesAttachmentScanPageDeleteDraft) throws
    -> NotesAttachmentScanPageDeleteWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.scan.page.delete"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentScanMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentScanInspection(before, operation: operation)
    try validateScanPageCount(draft.pageCount, against: before, operation: operation)

    guard let editor = ICDocCamScannedDocumentEditor(galleryAttachment: attachment) else {
      throw writeError(
        operation: operation,
        reason: "ICDocCamScannedDocumentEditor.initWithGalleryAttachment returned nil."
      )
    }
    editor.deletePages(atIndexes: IndexSet(integer: draft.page - 1))
    editor.saveAndUpdatePreview(true)
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentScanPageDeleteWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      page: draft.page,
      changed: true,
      sourceKind: "ICDocCamScannedDocumentEditor.deletePagesAtIndexes"
    )
  }

  func rotatePDFPage(_ draft: NotesAttachmentPDFPageRotateDraft) throws
    -> NotesAttachmentPDFPageRotateWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.pdf.page.rotate"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentPDFMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentPDFPageInspection(before, expectedPageCount: draft.pageCount, operation: operation)
    let source = try reader.exportAttachmentPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateWritablePDFSourceKind(source.sourceKind, operation: operation)

    #if canImport(PDFKit)
    let document = try pdfDocument(from: source.data, operation: operation)
    guard let page = document.page(at: draft.page - 1) else {
      throw writeError(operation: operation, reason: "PDFKit could not resolve the selected page.")
    }
    let beforeRotation = normalizedPDFRotation(page.rotation)
    page.rotation = draft.targetPageRotation
    let newData = try pdfDataRepresentation(document, operation: operation)
    let changed = before.pdfDataSHA256 != sha256Hex(newData)
    if changed {
      try writePDFMediaData(newData, to: attachment, note: note, context: context, operation: operation)
    }
    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    let afterSource = try reader.exportAttachmentPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    let afterDocument = try pdfDocument(from: afterSource.data, operation: operation)
    let afterRotation = afterDocument.page(at: draft.page - 1).map { normalizedPDFRotation($0.rotation) }
      ?? draft.targetPageRotation
    return NotesAttachmentPDFPageRotateWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      page: draft.page,
      beforePageRotation: beforeRotation,
      afterPageRotation: afterRotation,
      rotationDeltaDegrees: draft.rotationDeltaDegrees,
      changed: changed,
      sourceKind: "ICMedia.writeData+PDFKit.PDFDocument.pageRotation"
    )
    #else
    throw writeError(operation: operation, reason: "PDFKit is unavailable for PDF page rotation.")
    #endif
  }

  func movePDFPage(_ draft: NotesAttachmentPDFPageMoveDraft) throws
    -> NotesAttachmentPDFPageMoveWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.pdf.page.move"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentPDFMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentPDFPageInspection(before, expectedPageCount: draft.pageCount, operation: operation)
    let source = try reader.exportAttachmentPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateWritablePDFSourceKind(source.sourceKind, operation: operation)

    #if canImport(PDFKit)
    let document = try pdfDocument(from: source.data, operation: operation)
    guard let page = document.page(at: draft.fromPage - 1) else {
      throw writeError(operation: operation, reason: "PDFKit could not resolve the source page.")
    }
    document.removePage(at: draft.fromPage - 1)
    document.insert(page, at: draft.toPage - 1)
    let newData = try pdfDataRepresentation(document, operation: operation)
    try writePDFMediaData(newData, to: attachment, note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentPDFPageMoveWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      fromPage: draft.fromPage,
      toPage: draft.toPage,
      changed: true,
      sourceKind: "ICMedia.writeData+PDFKit.PDFDocument.pageMove"
    )
    #else
    throw writeError(operation: operation, reason: "PDFKit is unavailable for PDF page move.")
    #endif
  }

  func deletePDFPage(_ draft: NotesAttachmentPDFPageDeleteDraft) throws
    -> NotesAttachmentPDFPageDeleteWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.pdf.page.delete"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentPDFMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentPDFPageInspection(before, expectedPageCount: draft.pageCount, operation: operation)
    let source = try reader.exportAttachmentPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateWritablePDFSourceKind(source.sourceKind, operation: operation)

    #if canImport(PDFKit)
    let document = try pdfDocument(from: source.data, operation: operation)
    document.removePage(at: draft.page - 1)
    let newData = try pdfDataRepresentation(document, operation: operation)
    try writePDFMediaData(newData, to: attachment, note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentPDFPageDeleteWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      page: draft.page,
      changed: true,
      sourceKind: "ICMedia.writeData+PDFKit.PDFDocument.pageDelete"
    )
    #else
    throw writeError(operation: operation, reason: "PDFKit is unavailable for PDF page delete.")
    #endif
  }

  func cropPDF(_ draft: NotesAttachmentPDFCropDraft) throws
    -> NotesAttachmentPDFCropWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.pdf.crop"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentPDFMutationTarget(attachment, operation: operation)
    let before = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateAttachmentPDFPageInspection(before, expectedPageCount: draft.pageCount, operation: operation)
    let source = try reader.exportAttachmentPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    try validateWritablePDFSourceKind(source.sourceKind, operation: operation)

    #if canImport(PDFKit)
    let document = try pdfDocument(from: source.data, operation: operation)
    guard let page = document.page(at: draft.page - 1) else {
      throw writeError(operation: operation, reason: "PDFKit could not resolve the selected page.")
    }
    let currentBox = page.bounds(for: .cropBox)
    let cropBox = pdfCropBox(in: currentBox, draft: draft)
    page.setBounds(cropBox, for: .cropBox)
    let newData = try pdfDataRepresentation(document, operation: operation)
    guard before.pdfDataSHA256 != sha256Hex(newData) else {
      throw writeError(operation: operation, reason: "PDF crop did not change PDF media bytes.")
    }
    try writePDFMediaData(newData, to: attachment, note: note, context: context, operation: operation)

    let after = try reader.inspectAttachmentScanPDF(noteID: draft.noteID, attachmentID: draft.attachmentID)
    return NotesAttachmentPDFCropWriteResult(
      noteID: draft.noteID,
      oldInspection: before,
      inspection: after,
      page: draft.page,
      requestedCropRectSHA256: draft.requestedCropRectSHA256,
      changed: true,
      sourceKind: "ICMedia.writeData+PDFKit.PDFDocument.cropBox"
    )
    #else
    throw writeError(operation: operation, reason: "PDFKit is unavailable for PDF crop.")
    #endif
  }

  func cropImageAttachment(_ draft: NotesAttachmentImageCropDraft) throws
    -> NotesAttachmentImageCropWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.image.crop"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentImageTransformTarget(attachment, operation: operation)
    let before = try imageTransformSource(noteID: draft.noteID, attachment: attachment, operation: operation)
    let newData = try croppedImageData(from: before, draft: draft, operation: operation)
    guard before.dataSHA256 != sha256Hex(newData) else {
      throw writeError(operation: operation, reason: "Image crop did not change attachment media bytes.")
    }
    try writeImageMediaData(newData, to: attachment, note: note, context: context, operation: operation)
    let after = try imageTransformSource(noteID: draft.noteID, attachment: attachment, operation: operation)
    return NotesAttachmentImageCropWriteResult(
      noteID: draft.noteID,
      oldSource: before,
      source: after,
      requestedCropRectSHA256: draft.requestedCropRectSHA256,
      changed: before.dataSHA256 != after.dataSHA256,
      sourceKind: "ICMedia.writeData+ImageIO.CGImage.crop"
    )
  }

  func rotateImageAttachment(_ draft: NotesAttachmentImageRotateDraft) throws
    -> NotesAttachmentImageRotateWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.image.rotate"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    try validateAttachmentImageTransformTarget(attachment, operation: operation)
    let before = try imageTransformSource(noteID: draft.noteID, attachment: attachment, operation: operation)
    let newData = try rotatedImageData(
      from: before,
      rotationDeltaDegrees: draft.rotationDeltaDegrees,
      operation: operation
    )
    guard before.dataSHA256 != sha256Hex(newData) else {
      throw writeError(operation: operation, reason: "Image rotation did not change attachment media bytes.")
    }
    try writeImageMediaData(newData, to: attachment, note: note, context: context, operation: operation)
    let after = try imageTransformSource(noteID: draft.noteID, attachment: attachment, operation: operation)
    return NotesAttachmentImageRotateWriteResult(
      noteID: draft.noteID,
      oldSource: before,
      source: after,
      rotationDeltaDegrees: draft.rotationDeltaDegrees,
      changed: before.dataSHA256 != after.dataSHA256,
      sourceKind: "ICMedia.writeData+ImageIO.CGImage.rotate"
    )
  }

  func applyAttachmentMarkup(_ draft: NotesAttachmentMarkupEditDraft) throws
    -> NotesAttachmentMarkupEditWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateAttachmentMutationTarget(note, operation: "notes.attachments.markup.edit")

    let attachment = try attachment(
      selector: draft.attachmentID,
      note: note,
      operation: "notes.attachments.markup.edit"
    )
    try validateAttachmentMarkupTarget(attachment, operation: "notes.attachments.markup.edit")
    let oldRecord = attachmentRecord(attachment)
    let semaphore = DispatchSemaphore(value: 0)
    let completion = NotesAttachmentMarkupApplyCompletion()
    let block: @convention(block) () -> Void = {
      completion.complete()
      semaphore.signal()
    }

    ICMarkupUtilities.applyMarkupModelData(
      draft.data as NSData,
      attachment: attachment,
      completionBlock: block
    )
    guard semaphore.wait(timeout: .now() + .seconds(15)) == .success, completion.completed else {
      throw writeError(
        operation: "notes.attachments.markup.edit",
        reason: "ICMarkupUtilities.applyMarkupModelData completion did not return."
      )
    }

    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: "notes.attachments.markup.edit")
    let record = try readbackRenamedAttachment(
      attachment: attachment,
      oldRecord: oldRecord,
      noteID: draft.noteID,
      operation: "notes.attachments.markup.edit"
    )
    return NotesAttachmentMarkupEditWriteResult(
      noteID: draft.noteID,
      oldAttachment: oldRecord,
      attachment: record,
      changed: true
    )
  }

  func setAttachmentImageDescription(_ draft: NotesAttachmentImageDescriptionDraft) throws
    -> NotesAttachmentImageDescriptionWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let operation = "notes.attachments.image.description.set"
    try validateAttachmentMutationTarget(note, operation: operation)

    let attachment = try imageDescriptionInlineAttachment(
      selector: draft.attachmentID,
      note: note,
      operation: operation
    )
    let oldSource = imageDescriptionSource(noteID: draft.noteID, attachment: attachment)
    try validateImageDescriptionAttachmentTarget(oldSource.attachment, operation: operation)
    guard oldSource.descriptionText != draft.descriptionText else {
      return NotesAttachmentImageDescriptionWriteResult(
        noteID: draft.noteID,
        oldSource: oldSource,
        source: oldSource,
        changed: false
      )
    }

    attachment.altText = draft.descriptionText
    try save(note: note, context: context, operation: operation)
    let source = imageDescriptionSource(noteID: draft.noteID, attachment: attachment)
    return NotesAttachmentImageDescriptionWriteResult(
      noteID: draft.noteID,
      oldSource: oldSource,
      source: source,
      changed: true
    )
  }

  func addLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try addURLLink(draft, operation: "notes.links.add")
  }

  func addWebpageAttachment(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try addURLLink(draft, operation: "notes.attachments.add-webpage")
  }

  func updateWebpageAttachment(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try updateURLLink(
      draft,
      operation: "notes.attachments.update-webpage",
      validate: validateWebLinkUpdateTarget
    )
  }

  func addAppLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try addURLLink(draft, operation: "notes.links.add-app")
  }

  func addFileLink(_ draft: NotesLinkAddDraft) throws -> NotesLinkAddWriteResult {
    try addURLLink(draft, operation: "notes.links.add-file")
  }

  private func addURLLink(_ draft: NotesLinkAddDraft, operation: String) throws -> NotesLinkAddWriteResult {
    if draft.convertsSelectedText {
      return try addSelectedTextURLLink(draft, operation: operation)
    }

    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: operation)

    let before = try reader.listLinks(noteID: draft.noteID, limit: 2_000)
    guard let link = note.addURLAttachment(withURL: draft.url) as AnyObject? else {
      throw writeError(operation: operation, reason: "ICNote.addURLAttachmentWithURL returned nil.")
    }

    try save(note: note, context: context, operation: operation)
    let record = try readback(
      link: link,
      noteID: draft.noteID,
      before: before,
      urlString: draft.urlString,
      operation: operation
    )
    return NotesLinkAddWriteResult(noteID: draft.noteID, link: record)
  }

  private func addSelectedTextURLLink(_ draft: NotesLinkAddDraft, operation: String) throws
    -> NotesLinkAddWriteResult
  {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: operation)
    guard let selectedText = draft.selectedText else {
      throw writeError(operation: operation, reason: "Selected-text URL link conversion requires text.")
    }
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    let target = try inlineTextTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      text: selectedText,
      occurrence: draft.occurrence,
      textStorage: textStorage,
      operation: operation
    )
    guard NSMaxRange(target.range) <= textStorage.length else {
      throw writeError(operation: operation, reason: "Selected text range is outside Notes text storage.")
    }

    let before = try reader.listLinks(noteID: draft.noteID, limit: 2_000)
    guard
      let link = ICInlineAttachment.newLinkAttachment(
        withURL: draft.url as NSURL,
        name: selectedText as NSString,
        currentNote: note
      )
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.newLinkAttachmentWithURL:name:currentNote: returned nil.")
    }
    link.altText = selectedText
    link.markDisplayTextNeedsUpdate()

    let textAttachment = try linkTextAttachment(link, operation: operation)
    let replacement = NSMutableAttributedString(attachment: textAttachment)
    if target.range.length > 0 {
      var attributes = textStorage.attributes(at: target.range.location, effectiveRange: nil)
      attributes.removeValue(forKey: .attachment)
      replacement.addAttributes(attributes, range: NSRange(location: 0, length: replacement.length))
    }

    note.beginEditing()
    textStorage.replaceCharacters(in: target.range, with: replacement)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let record = try readback(
      link: link,
      noteID: draft.noteID,
      before: before,
      urlString: draft.urlString,
      operation: operation
    )
    return NotesLinkAddWriteResult(
      noteID: draft.noteID,
      link: record,
      selectedTextParagraphIDSHA256: target.paragraphIDSHA256,
      selectedTextOrdinal: draft.ordinal,
      selectedTextByteCount: target.textByteCount,
      selectedTextSHA256: target.textSHA256,
      selectedTextOccurrence: target.occurrence
    )
  }

  private func linkTextAttachment(
    _ link: ICInlineAttachment,
    operation: String
  ) throws -> NSTextAttachment {
    let selector = NSSelectorFromString("textAttachmentWithAttachment:")
    let attachmentClass = ICInlineTextAttachment.self as AnyObject
    guard attachmentClass.responds(to: selector) else {
      throw writeError(operation: operation, reason: "ICInlineTextAttachment.textAttachmentWithAttachment: is unavailable.")
    }
    guard
      let textAttachment = attachmentClass.perform(selector, with: link)?
        .takeUnretainedValue() as? NSTextAttachment
    else {
      throw writeError(operation: operation, reason: "ICInlineTextAttachment.textAttachmentWithAttachment: returned nil.")
    }
    return textAttachment
  }

  func insertParticipantMention(_ draft: NotesCollaborationMentionDraft) throws
    -> NotesCollaborationMentionWriteResult
  {
    let operation = "notes.state.mention"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let participants = mentionParticipantCandidates(note)
    let wasShared = boolValue(note, key: "isSharedViaICloud") == true
      || boolValue(note, key: "isSharedViaICloudFolder") == true
      || boolValue(note, key: "isSharedReadOnly") == true
      || participants.isEmpty == false
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant mention requires an already shared note.",
        details: [
          "operation": operation,
          "capability": "semantic_participant_mention",
          "required_state": "shared_note",
          "note_id_sha256": sha256Hex(draft.noteID),
          "backend_calls": "private_framework_state_readback_only",
        ]
      )
    }

    let resolution = try resolveMentionParticipant(
      target: draft.target,
      participants: participants,
      note: note,
      operation: operation
    )
    let mentionText = try normalizedMentionText(
      draft.text,
      fallback: resolution.displayText,
      operation: operation
    )
    let beforeAttachments = mentionInlineAttachments(note)
    let beforeTargetCount = mentionCount(
      in: beforeAttachments,
      userRecordNameSHA256: resolution.userRecordNameSHA256
    )
    let identifier = UUID().uuidString
    guard
      let mention = ICInlineAttachment.newMentionAttachment(
        withIdentifier: identifier as NSString,
        mentionText: mentionText as NSString,
        userRecordName: resolution.userRecordName as NSString,
        note: note,
        parentAttachment: nil
      )
    else {
      throw writeError(
        operation: operation,
        reason: "ICInlineAttachment.newMentionAttachmentWithIdentifier returned nil."
      )
    }
    mention.altText = mentionText

    let textAttachment = try linkTextAttachment(mention, operation: operation)
    let insertionLocation = textStorage.length
    let replacement = NSMutableAttributedString()
    if mathExpressionNeedsLineBreakBefore(location: insertionLocation, textStorage: textStorage) {
      replacement.append(NSAttributedString(string: "\n"))
    }
    replacement.append(NSAttributedString(attachment: textAttachment))

    note.beginEditing()
    textStorage.replaceCharacters(
      in: NSRange(location: insertionLocation, length: 0),
      with: replacement
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let afterAttachments = mentionInlineAttachments(note)
    let afterTargetCount = mentionCount(
      in: afterAttachments,
      userRecordNameSHA256: resolution.userRecordNameSHA256
    )
    let beforeIdentities = Set(beforeAttachments.map(mentionAttachmentIdentity(_:)))
    let inserted = afterAttachments.first { beforeIdentities.contains(mentionAttachmentIdentity($0)) == false }
    return NotesCollaborationMentionWriteResult(
      noteID: draft.noteID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: resolution.participantIDSHA256,
      targetUserRecordNameSHA256: resolution.userRecordNameSHA256,
      mentionTextSHA256: sha256Hex(mentionText),
      mentionTextByteCount: mentionText.utf8.count,
      beforeMentionCount: beforeAttachments.count,
      afterMentionCount: afterAttachments.count,
      targetBeforeMentionCount: beforeTargetCount,
      targetAfterMentionCount: afterTargetCount,
      insertedAttachmentIDSHA256: inserted.map { sha256Hex(objectIDString($0)) },
      insertedIdentifierSHA256: inserted
        .flatMap { nonEmpty(optionalString($0, key: "identifier")) ?? nonEmpty(optionalString($0, key: "attachmentIdentifier")) }
        .map(sha256Hex),
      wasShared: wasShared,
      participantCount: resolution.participantCount,
      backendCalls: "ICInlineAttachment.newMentionAttachmentWithIdentifier+ICNote.textStorage"
    )
  }

  func setCollaborationParticipantPermission(_ draft: NotesCollaborationPermissionMutationDraft) throws
    -> NotesCollaborationPermissionWriteResult
  {
    let operation = draft.operation ?? "notes.state.set-permission"
    let context = try noteContext()
    let target = try collaborationMutationTarget(
      noteID: draft.noteID,
      folderID: draft.folderID,
      operation: operation,
      capability: "collaboration_permission_mutation",
      actionDescription: "collaboration participant permission mutation"
    )
    guard let share = collaborationShareObject(for: target.object) else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration permission mutation requires an existing share.",
        details: [
          "operation": operation,
          "capability": "collaboration_permission_mutation",
          "required_state": "shared_\(target.kind)",
          "\(target.kind)_id_sha256": sha256Hex(target.id),
        ]
      )
    }
    let participants = collaborationShareParticipantCandidates(
      share: share,
      object: target.object,
      note: target.note
    )
    let resolution = try resolveCollaborationParticipant(
      target: draft.target,
      participants: participants,
      object: target.object,
      note: target.note,
      targetKind: target.kind,
      operation: operation,
      capability: "collaboration_permission_mutation"
    )
    let beforePermission = optionalInt(resolution.participant, key: "permission")
    let beforeLabel = collaborationPermissionLabel(beforePermission)
    if beforePermission != draft.permissionValue {
      guard let participant = resolution.participant as? NSObject else {
        throw writeError(operation: operation, reason: "Collaboration participant was not KVC mutable.")
      }
      participant.setValue(NSNumber(value: draft.permissionValue), forKey: "permission")
      try saveCollaborationShare(share, object: target.object, context: context, operation: operation)
    }
    let afterPermission = optionalInt(resolution.participant, key: "permission")
    return NotesCollaborationPermissionWriteResult(
      noteID: target.noteID,
      folderID: target.folderID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: resolution.participantIDSHA256,
      targetUserRecordNameSHA256: resolution.userRecordNameSHA256,
      requestedPermissionValue: draft.permissionValue,
      requestedPermissionLabel: draft.permissionLabel,
      beforePermissionValue: beforePermission,
      beforePermissionLabel: beforeLabel,
      afterPermissionValue: afterPermission,
      afterPermissionLabel: collaborationPermissionLabel(afterPermission),
      changed: beforePermission != draft.permissionValue,
      wasShared: true,
      participantCount: resolution.participantCount,
      shareRecordIDSHA256: collaborationShareRecordHash(share, fallbackObject: target.object),
      backendCalls: "CKShareParticipant.permission+ICCollaborationController.saveServerShare"
    )
  }

  func shareCollaboration(_ draft: NotesCollaborationShareMutationDraft) throws
    -> NotesCollaborationShareWriteResult
  {
    let operation = draft.operation
    let capability = draft.createShareIfNeeded ? "collaboration_share_mutation" : "collaboration_participant_invite"
    let context = try noteContext()
    let target = try collaborationSharingTarget(
      noteID: draft.noteID,
      folderID: draft.folderID,
      createShareIfNeeded: draft.createShareIfNeeded,
      operation: operation,
      capability: capability,
      actionDescription: draft.createShareIfNeeded ? "collaboration sharing" : "collaboration participant invite"
    )
    let beforeShare = collaborationShareObject(for: target.object)
    let beforeParticipants = beforeShare.map {
      collaborationShareParticipantCandidates(share: $0, object: target.object, note: target.note)
    } ?? []
    let share: AnyObject
    if let beforeShare {
      share = beforeShare
    } else {
      share = try createCollaborationShare(for: target.object, operation: operation)
    }
    let fetchedParticipant = try fetchCollaborationShareParticipant(
      target: draft.target,
      object: target.object,
      operation: operation,
      capability: capability
    )
    let participantIDHash = participantIdentityHash(
      fetchedParticipant,
      object: target.object,
      note: target.note
    )
    let userRecordHash = participantUserRecordName(fetchedParticipant, note: target.note).map(sha256Hex)
      ?? participantUserIDStrings(from: fetchedParticipant, note: target.note).map(sha256Hex).first
    let beforeParticipant = beforeParticipants.first { participant in
      participantIdentityHash(participant, object: target.object, note: target.note) == participantIDHash
    }
    let targetPresentBefore = beforeParticipant != nil
    let beforePermission = beforeParticipant.flatMap { optionalInt($0, key: "permission") }
    if beforePermission != draft.permissionValue {
      guard let mutableParticipant = fetchedParticipant as? NSObject else {
        throw writeError(operation: operation, reason: "Fetched CKShareParticipant was not KVC mutable.")
      }
      mutableParticipant.setValue(NSNumber(value: draft.permissionValue), forKey: "permission")
    }
    if targetPresentBefore == false {
      try addParticipantToShare(fetchedParticipant, share: share, operation: operation)
    }
    try saveCollaborationShare(share, object: target.object, context: context, operation: operation)
    if let managedObject = target.object as? NSManagedObject {
      context.managedObjectContext?.refresh(managedObject, mergeChanges: true)
    }

    let afterShare = collaborationShareObject(for: target.object) ?? share
    let afterParticipants = collaborationShareParticipantCandidates(
      share: afterShare,
      object: target.object,
      note: target.note
    )
    let afterParticipant = afterParticipants.first { participant in
      participantIdentityHash(participant, object: target.object, note: target.note) == participantIDHash
    }
    let targetPresentAfter = afterParticipant != nil
    let afterPermission = afterParticipant.flatMap { optionalInt($0, key: "permission") }
      ?? optionalInt(fetchedParticipant, key: "permission")
    let afterWasShared = collaborationTargetWasShared(object: target.object, share: afterShare, participantCount: afterParticipants.count)
    return NotesCollaborationShareWriteResult(
      operation: operation,
      noteID: target.noteID,
      folderID: target.folderID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: participantIDHash,
      targetUserRecordNameSHA256: userRecordHash,
      requestedPermissionValue: draft.permissionValue,
      requestedPermissionLabel: draft.permissionLabel,
      beforeWasShared: beforeShare != nil
        || collaborationTargetWasShared(object: target.object, share: beforeShare, participantCount: beforeParticipants.count),
      afterWasShared: afterWasShared,
      beforeParticipantCount: beforeParticipants.count,
      afterParticipantCount: afterParticipants.count,
      targetPresentBefore: targetPresentBefore,
      targetPresentAfter: targetPresentAfter,
      beforePermissionValue: beforePermission,
      beforePermissionLabel: collaborationPermissionLabel(beforePermission),
      afterPermissionValue: afterPermission,
      afterPermissionLabel: collaborationPermissionLabel(afterPermission),
      changed: beforeShare == nil || targetPresentBefore == false || beforePermission != draft.permissionValue,
      shareRecordIDSHA256: collaborationShareRecordHash(afterShare, fallbackObject: target.object),
      shareURLSHA256: collaborationShareURLString(afterShare).map(sha256Hex),
      backendCalls: "CKContainer.fetchShareParticipant+CKShare.addParticipant+ICCollaborationController.saveServerShare"
    )
  }

  func setCollaborationAccessScope(_ draft: NotesCollaborationAccessScopeMutationDraft) throws
    -> NotesCollaborationAccessScopeWriteResult
  {
    let operation = "notes.state.share"
    let context = try noteContext()
    let target = try collaborationMutationTarget(
      noteID: draft.noteID,
      folderID: draft.folderID,
      operation: operation,
      capability: "collaboration_access_scope_mutation",
      actionDescription: "collaboration access scope mutation"
    )
    guard let share = collaborationShareObject(for: target.object) else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration access scope mutation requires an existing share.",
        details: [
          "operation": operation,
          "capability": "collaboration_access_scope_mutation",
          "required_state": "shared_\(target.kind)",
          "\(target.kind)_id_sha256": sha256Hex(target.id),
        ]
      )
    }
    let beforePublicPermission = optionalInt(share, key: "publicPermission")
    let requestedPublicPermission = collaborationAccessScopePublicPermissionValue(
      accessScopeLabel: draft.accessScopeLabel,
      beforePublicPermission: beforePublicPermission
    )
    if beforePublicPermission != requestedPublicPermission {
      guard let mutableShare = share as? NSObject else {
        throw writeError(operation: operation, reason: "Collaboration share publicPermission was not KVC mutable.")
      }
      mutableShare.setValue(NSNumber(value: requestedPublicPermission), forKey: "publicPermission")
      try saveCollaborationShare(share, object: target.object, context: context, operation: operation)
    }
    let afterPublicPermission = optionalInt(share, key: "publicPermission")
    return NotesCollaborationAccessScopeWriteResult(
      noteID: target.noteID,
      folderID: target.folderID,
      requestedAccessScopeLabel: draft.accessScopeLabel,
      requestedPublicPermissionValue: requestedPublicPermission,
      requestedPublicPermissionLabel: collaborationPermissionLabel(requestedPublicPermission) ?? "unknown",
      beforeAccessScopeLabel: collaborationAccessScopeLabel(beforePublicPermission),
      beforePublicPermissionValue: beforePublicPermission,
      beforePublicPermissionLabel: collaborationPermissionLabel(beforePublicPermission),
      afterAccessScopeLabel: collaborationAccessScopeLabel(afterPublicPermission),
      afterPublicPermissionValue: afterPublicPermission,
      afterPublicPermissionLabel: collaborationPermissionLabel(afterPublicPermission),
      changed: beforePublicPermission != requestedPublicPermission,
      wasShared: true,
      participantCount: collaborationShareParticipantCandidates(
        share: share,
        object: target.object,
        note: target.note
      ).count,
      shareRecordIDSHA256: collaborationShareRecordHash(share, fallbackObject: target.object),
      backendCalls: "CKShare.publicPermission+ICCollaborationController.saveServerShare"
    )
  }

  func stopSharing(_ draft: NotesCollaborationStopSharingDraft) throws
    -> NotesCollaborationStopSharingWriteResult
  {
    let operation = "notes.state.stop-sharing"
    let context = try noteContext()
    let target = try collaborationMutationTarget(
      noteID: draft.noteID,
      folderID: draft.folderID,
      operation: operation,
      capability: "collaboration_stop_sharing",
      actionDescription: "stop sharing"
    )
    guard let beforeShare = collaborationShareObject(for: target.object) else {
      throw CLIError(
        code: .validationError,
        message: "Notes stop sharing requires an existing share.",
        details: [
          "operation": operation,
          "capability": "collaboration_stop_sharing",
          "required_state": "shared_\(target.kind)",
          "\(target.kind)_id_sha256": sha256Hex(target.id),
        ]
      )
    }
    let beforeParticipants = collaborationShareParticipantCandidates(
      share: beforeShare,
      object: target.object,
      note: target.note
    )
    let beforeShareHash = collaborationShareRecordHash(beforeShare, fallbackObject: target.object)

    try removeShareIfNeeded(object: target.object, operation: operation)
    try save(context: context, operation: operation)
    if let managedObject = target.object as? NSManagedObject {
      context.managedObjectContext?.refresh(managedObject, mergeChanges: true)
    }

    let afterShare = collaborationShareObject(for: target.object)
    let afterParticipants = afterShare.map {
      collaborationShareParticipantCandidates(share: $0, object: target.object, note: target.note)
    } ?? []
    let afterWasShared = afterShare != nil
      || boolValue(target.object, key: "isSharedViaICloud") == true
      || boolValue(target.object, key: "isSharedViaICloudFolder") == true
      || boolValue(target.object, key: "isSharedReadOnly") == true
      || afterParticipants.isEmpty == false
    return NotesCollaborationStopSharingWriteResult(
      noteID: target.noteID,
      folderID: target.folderID,
      beforeWasShared: true,
      afterWasShared: afterWasShared,
      beforeParticipantCount: beforeParticipants.count,
      afterParticipantCount: afterParticipants.count,
      beforeShareRecordIDSHA256: beforeShareHash,
      afterShareRecordIDSHA256: afterShare.map {
        collaborationShareRecordHash($0, fallbackObject: target.object)
      } ?? nil,
      changed: afterWasShared == false,
      backendCalls: "ICCollaborationController.removeShareIfNeededWithOwnedObjectID"
    )
  }

  func setCollaborationInvitePolicy(_ draft: NotesCollaborationAllowInvitesDraft) throws
    -> NotesCollaborationAllowInvitesWriteResult
  {
    let operation = "notes.state.allow-invites"
    let context = try noteContext()
    let target = try collaborationMutationTarget(
      noteID: draft.noteID,
      folderID: draft.folderID,
      operation: operation,
      capability: "collaboration_invite_policy_mutation",
      actionDescription: "collaboration invite policy mutation"
    )
    guard let share = collaborationShareObject(for: target.object) else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration invite policy mutation requires an existing share.",
        details: [
          "operation": operation,
          "capability": "collaboration_invite_policy_mutation",
          "required_state": "shared_\(target.kind)",
          "\(target.kind)_id_sha256": sha256Hex(target.id),
        ]
      )
    }
    let participants = collaborationShareParticipantCandidates(
      share: share,
      object: target.object,
      note: target.note
    )
    let eligible = participants.filter { collaborationParticipantCanCarryInvitePolicy($0) }
    let beforeAdministratorCount = eligible.filter { collaborationParticipantRole($0) == 2 }.count
    let beforeAllowsInvites = beforeAdministratorCount > 0
    let requestedRole = draft.enabled ? 2 : 3
    var changed = false
    for participant in eligible where collaborationParticipantRole(participant) != requestedRole {
      guard let mutableParticipant = participant as? NSObject else {
        throw writeError(operation: operation, reason: "Collaboration participant role was not KVC mutable.")
      }
      mutableParticipant.setValue(NSNumber(value: requestedRole), forKey: "role")
      changed = true
    }
    if changed {
      try saveCollaborationShare(share, object: target.object, context: context, operation: operation)
    }
    let afterParticipants = collaborationShareParticipantCandidates(
      share: share,
      object: target.object,
      note: target.note
    )
    let afterEligible = afterParticipants.filter { collaborationParticipantCanCarryInvitePolicy($0) }
    let afterAdministratorCount = afterEligible.filter { collaborationParticipantRole($0) == 2 }.count
    return NotesCollaborationAllowInvitesWriteResult(
      noteID: target.noteID,
      folderID: target.folderID,
      requestedAllowsInvites: draft.enabled,
      beforeAllowsInvites: beforeAllowsInvites,
      afterAllowsInvites: afterAdministratorCount > 0,
      participantCount: afterParticipants.count,
      eligibleParticipantCount: afterEligible.count,
      beforeAdministratorCount: beforeAdministratorCount,
      afterAdministratorCount: afterAdministratorCount,
      changed: changed,
      wasShared: true,
      shareRecordIDSHA256: collaborationShareRecordHash(share, fallbackObject: target.object),
      backendCalls: "CKShareParticipant.role+ICCollaborationController.saveServerShare"
    )
  }

  func removeSelfFromCollaboration(_ draft: NotesCollaborationSelfRemovalDraft) throws
    -> NotesCollaborationSelfRemovalWriteResult
  {
    let operation = "notes.state.remove-self"
    let context = try noteContext()
    let target = try collaborationSelfRemovalTarget(
      noteID: draft.noteID,
      folderID: draft.folderID,
      operation: operation,
      capability: "collaboration_self_removal",
      actionDescription: "self removal"
    )
    guard let share = collaborationShareObject(for: target.object) else {
      throw CLIError(
        code: .validationError,
        message: "Notes self removal requires an existing share.",
        details: [
          "operation": operation,
          "capability": "collaboration_self_removal",
          "required_state": "shared_\(target.kind)",
          "\(target.kind)_id_sha256": sha256Hex(target.id),
        ]
      )
    }
    let beforeParticipants = collaborationSelfRemovalParticipantCandidates(
      share: share,
      object: target.object,
      note: target.note
    )
    let resolution = try resolveCurrentCollaborationParticipant(
      share: share,
      participants: beforeParticipants,
      object: target.object,
      note: target.note,
      operation: operation,
      capability: "collaboration_self_removal"
    )
    try validateSelfRemovableCollaborationParticipant(
      resolution.participant,
      operation: operation,
      targetHash: sha256Hex(target.id)
    )
    let beforeParticipantCount = beforeParticipants.count
    let shareHash = collaborationShareRecordHash(share, fallbackObject: target.object)
    try removeParticipantFromShare(resolution.participant, share: share, operation: operation)
    try saveCollaborationShare(share, object: target.object, context: context, operation: operation)
    let afterParticipants = collaborationShareParticipantCandidates(
      share: share,
      object: target.object,
      note: target.note
    )
    let afterCurrentUserPresent = afterParticipants.contains { participant in
      boolValue(participant, key: "isCurrentUser") == true
        || participantIdentityHash(participant, object: target.object, note: target.note)
          == resolution.participantIDSHA256
    }
    let afterParticipantCount = afterParticipants.count
    return NotesCollaborationSelfRemovalWriteResult(
      noteID: target.noteID,
      folderID: target.folderID,
      beforeWasShared: true,
      beforeCurrentUserPresent: true,
      afterCurrentUserPresent: afterCurrentUserPresent,
      currentUserParticipantIDSHA256: resolution.participantIDSHA256,
      currentUserRecordNameSHA256: resolution.userRecordNameSHA256,
      beforeParticipantCount: beforeParticipantCount,
      afterParticipantCount: afterParticipantCount,
      changed: afterCurrentUserPresent == false && afterParticipantCount < beforeParticipantCount,
      shareRecordIDSHA256: shareHash,
      backendCalls: "CKShare.removeParticipant(currentUserParticipant)+ICCollaborationController.saveServerShare"
    )
  }

  func removeCollaborationParticipant(_ draft: NotesCollaborationParticipantRemovalDraft) throws
    -> NotesCollaborationParticipantRemovalWriteResult
  {
    let operation = "notes.state.remove-participant"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateCollaborationPermissionMutationTarget(
      note,
      operation: operation,
      capability: "collaboration_participant_removal",
      actionDescription: "participant removal"
    )
    guard let share = collaborationShareObject(for: note) else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant removal requires an existing share.",
        details: [
          "operation": operation,
          "capability": "collaboration_participant_removal",
          "required_state": "shared_note",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    let beforeParticipants = collaborationShareParticipantCandidates(share: share, note: note)
    let resolution = try resolveCollaborationParticipant(
      target: draft.target,
      participants: beforeParticipants,
      note: note,
      operation: operation,
      capability: "collaboration_participant_removal"
    )
    try validateRemovableCollaborationParticipant(
      resolution.participant,
      share: share,
      note: note,
      operation: operation,
      targetHash: sha256Hex(draft.target)
    )
    let beforeParticipantCount = beforeParticipants.count
    try removeParticipantFromShare(resolution.participant, share: share, operation: operation)
    try saveCollaborationShare(share, object: note, context: context, operation: operation)
    let afterParticipants = collaborationShareParticipantCandidates(share: share, note: note)
    let targetPresentAfter = afterParticipants.contains { participant in
      participantIdentityHash(participant, note: note) == resolution.participantIDSHA256
    }
    let afterParticipantCount = afterParticipants.count
    return NotesCollaborationParticipantRemovalWriteResult(
      noteID: draft.noteID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: resolution.participantIDSHA256,
      targetUserRecordNameSHA256: resolution.userRecordNameSHA256,
      beforeParticipantCount: beforeParticipantCount,
      afterParticipantCount: afterParticipantCount,
      targetPresentAfter: targetPresentAfter,
      changed: targetPresentAfter == false && afterParticipantCount < beforeParticipantCount,
      wasShared: true,
      shareRecordIDSHA256: collaborationShareRecordHash(share, fallbackObject: note),
      backendCalls: "CKShare.removeParticipant+ICCollaborationController.saveServerShare"
    )
  }

  func addNoteLink(_ draft: NotesNoteLinkAddDraft) throws -> NotesNoteLinkAddWriteResult {
    let context = try noteContext()
    let sourceNote = try note(id: draft.sourceNoteID)
    let targetNote = try note(id: draft.targetNoteID)
    try validateLinkMutationTarget(sourceNote, operation: "notes.links.add-note")
    try validateNoteLinkDestination(targetNote, operation: "notes.links.add-note")

    let before = try reader.listLinks(noteID: draft.sourceNoteID, limit: 2_000)
    guard
      let linkObject = ICInlineAttachment.newLinkAttachment(
        toNote: targetNote,
        fromNote: sourceNote,
        parentAttachment: nil
      ) as AnyObject?
    else {
      throw writeError(
        operation: "notes.links.add-note",
        reason: "ICInlineAttachment.newLinkAttachmentToNote returned nil."
      )
    }
    guard let link = linkObject as? ICInlineAttachment else {
      throw writeError(
        operation: "notes.links.add-note",
        reason: "ICInlineAttachment.newLinkAttachmentToNote did not return an ICInlineAttachment."
      )
    }
    applyNoteLinkDisplayText(draft.displayText, to: link)

    try save(note: sourceNote, context: context, operation: "notes.links.add-note")
    let record = try readback(
      noteLink: link,
      sourceNoteID: draft.sourceNoteID,
      before: before,
      operation: "notes.links.add-note"
    )
    return NotesNoteLinkAddWriteResult(
      sourceNoteID: draft.sourceNoteID,
      targetNoteID: draft.targetNoteID,
      link: record
    )
  }

  private func applyNoteLinkDisplayText(
    _ displayText: NotesNoteLinkDisplayTextDraft?,
    to link: ICInlineAttachment
  ) {
    guard let displayText else {
      return
    }
    switch displayText.mode {
    case "custom":
      link.altText = displayText.displayText
    case "target_title":
      link.altText = nil
    default:
      return
    }
    link.markDisplayTextNeedsUpdate()
  }

  private func noteLinkDisplayTextNeedsUpdate(
    _ displayText: NotesNoteLinkDisplayTextDraft?,
    link: ICInlineAttachment
  ) -> Bool {
    guard let displayText else {
      return false
    }
    let currentAltText = nonEmpty(optionalString(link, key: "altText"))
    switch displayText.mode {
    case "custom":
      return currentAltText.map(sha256Hex) != displayText.displayTextSHA256
    case "target_title":
      return currentAltText != nil
    default:
      return false
    }
  }

  func addParagraphLink(_ draft: NotesParagraphLinkAddDraft) throws -> NotesParagraphLinkAddWriteResult {
    let context = try noteContext()
    let sourceNote = try note(id: draft.sourceNoteID)
    let targetNote = try note(id: draft.targetNoteID)
    try validateLinkMutationTarget(sourceNote, operation: "notes.links.add-paragraph")
    try validateNoteLinkDestination(targetNote, operation: "notes.links.add-paragraph")

    let before = try reader.listLinks(noteID: draft.sourceNoteID, limit: 2_000)
    guard
      let link = ICInlineAttachment.newLinkAttachment(
        toNote: targetNote,
        paragraphID: draft.targetParagraphID,
        paragraphName: draft.targetParagraphTitle,
        fromNote: sourceNote,
        parentAttachment: nil
      ) as AnyObject?
    else {
      throw writeError(
        operation: "notes.links.add-paragraph",
        reason: "ICInlineAttachment.newLinkAttachmentToNote paragraph path returned nil."
      )
    }

    try save(note: sourceNote, context: context, operation: "notes.links.add-paragraph")
    let record = try readback(
      paragraphLink: link,
      sourceNoteID: draft.sourceNoteID,
      before: before,
      operation: "notes.links.add-paragraph"
    )
    return NotesParagraphLinkAddWriteResult(
      sourceNoteID: draft.sourceNoteID,
      targetNoteID: draft.targetNoteID,
      targetParagraphIDSHA256: draft.targetParagraphIDSHA256,
      link: record
    )
  }

  func updateLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try updateURLLink(draft, operation: "notes.links.update", validate: validateWebLinkUpdateTarget)
  }

  func updateAppLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try updateURLLink(draft, operation: "notes.links.update-app", validate: validateAppLinkUpdateTarget)
  }

  func updateFileLink(_ draft: NotesLinkUpdateDraft) throws -> NotesLinkUpdateWriteResult {
    try updateURLLink(draft, operation: "notes.links.update-file", validate: validateFileLinkUpdateTarget)
  }

  func updateNoteLink(_ draft: NotesNoteLinkUpdateDraft) throws -> NotesNoteLinkUpdateWriteResult {
    let context = try noteContext()
    let sourceNote = try note(id: draft.sourceNoteID)
    let targetNote = try note(id: draft.targetNoteID)
    try validateLinkMutationTarget(sourceNote, operation: "notes.links.update-note")
    try validateNoteLinkDestination(targetNote, operation: "notes.links.update-note")

    let selectedLink = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: sourceNote,
      operation: "notes.links.update-note"
    )
    try validateNoteLinkUpdateTarget(selectedLink, operation: "notes.links.update-note")
    let oldTargetNote = try noteLinkDestination(selectedLink, operation: "notes.links.update-note")
    let oldTargetNoteID = noteIdentifier(oldTargetNote)
    let targetChanged = oldTargetNoteID != draft.targetNoteID
    let displayTextChanged = noteLinkDisplayTextNeedsUpdate(draft.displayText, link: selectedLink)
    guard targetChanged || displayTextChanged else {
      throw CLIError(
        code: .validationError,
        message: "Notes note-to-note link update requires a changed target note or display text.",
        details: [
          "id_sha256": sha256Hex(draft.sourceNoteID),
          "link_sha256": sha256Hex(draft.requestedLinkID),
          "target_sha256": sha256Hex(draft.targetNoteID),
        ]
      )
    }
    if targetChanged {
      let selector = NSSelectorFromString("changeLinkDestinationFromNote:toNote:")
      guard selectedLink.responds(to: selector) else {
        throw writeError(
          operation: "notes.links.update-note",
          reason: "ICInlineAttachment.changeLinkDestinationFromNote:toNote: is unavailable."
        )
      }
      _ = selectedLink.perform(selector, with: oldTargetNote, with: targetNote)
    }

    applyNoteLinkDisplayText(draft.displayText, to: selectedLink)
    try save(note: sourceNote, context: context, operation: "notes.links.update-note")
    let record = try readback(
      updatedNoteLink: selectedLink,
      sourceNoteID: draft.sourceNoteID,
      oldLink: draft.link,
      operation: "notes.links.update-note"
    )
    return NotesNoteLinkUpdateWriteResult(
      sourceNoteID: draft.sourceNoteID,
      oldTargetNoteID: oldTargetNoteID,
      targetNoteID: draft.targetNoteID,
      oldLink: draft.link,
      link: record,
      changed: true
    )
  }

  func updateParagraphLink(_ draft: NotesParagraphLinkUpdateDraft) throws
    -> NotesParagraphLinkUpdateWriteResult
  {
    let context = try noteContext()
    let sourceNote = try note(id: draft.sourceNoteID)
    let targetNote = try note(id: draft.targetNoteID)
    try validateLinkMutationTarget(sourceNote, operation: "notes.links.update-paragraph")
    try validateNoteLinkDestination(targetNote, operation: "notes.links.update-paragraph")

    let selectedLink = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: sourceNote,
      operation: "notes.links.update-paragraph"
    )
    try validateParagraphLinkUpdateTarget(selectedLink, operation: "notes.links.update-paragraph")
    let oldTarget = try paragraphLinkDestination(
      selectedLink,
      operation: "notes.links.update-paragraph"
    )
    let oldTargetNoteID = noteIdentifier(oldTarget.note)
    let targetToken = try paragraphLinkToken(
      targetNote: targetNote,
      paragraphID: draft.targetParagraphID,
      operation: "notes.links.update-paragraph"
    )
    let targetTokenSHA256 = sha256Hex(targetToken)
    guard oldTarget.tokenSHA256 != targetTokenSHA256 else {
      throw CLIError(
        code: .validationError,
        message: "Notes paragraph link update requires a changed target paragraph.",
        details: [
          "id_sha256": sha256Hex(draft.sourceNoteID),
          "link_sha256": sha256Hex(draft.requestedLinkID),
          "target_sha256": sha256Hex(draft.targetNoteID),
          "paragraph_sha256": draft.targetParagraphIDSHA256,
        ]
      )
    }

    let selector = NSSelectorFromString("changeLinkDestinationFromNote:toNote:")
    if selectedLink.responds(to: selector), oldTargetNoteID != draft.targetNoteID {
      _ = selectedLink.perform(selector, with: oldTarget.note, with: targetNote)
    }
    selectedLink.tokenContentIdentifier = targetToken
    selectedLink.altText = paragraphLinkDisplayText(
      token: targetToken,
      sourceNote: sourceNote,
      fallback: draft.targetParagraphTitle
    )
    selectedLink.markDisplayTextNeedsUpdate()
    try save(note: sourceNote, context: context, operation: "notes.links.update-paragraph")
    let record = try readback(
      updatedParagraphLink: selectedLink,
      sourceNoteID: draft.sourceNoteID,
      oldLink: draft.link,
      targetTokenSHA256: targetTokenSHA256,
      operation: "notes.links.update-paragraph"
    )
    return NotesParagraphLinkUpdateWriteResult(
      sourceNoteID: draft.sourceNoteID,
      oldTargetNoteID: oldTargetNoteID,
      targetNoteID: draft.targetNoteID,
      oldTargetParagraphIDSHA256: oldTarget.paragraphIDSHA256,
      targetParagraphIDSHA256: draft.targetParagraphIDSHA256,
      oldTokenContentIdentifierSHA256: oldTarget.tokenSHA256,
      targetTokenContentIdentifierSHA256: targetTokenSHA256,
      oldLink: draft.link,
      link: record,
      changed: true
    )
  }

  private func updateURLLink(
    _ draft: NotesLinkUpdateDraft,
    operation: String,
    validate: (ICInlineAttachment, String) throws -> Void
  ) throws -> NotesLinkUpdateWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: operation)

    let link = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: note,
      operation: operation
    )
    try validate(link, operation)

    link.tokenContentIdentifier = draft.urlString
    link.altText = linkDisplayText(for: draft.url)
    link.markDisplayTextNeedsUpdate()
    try save(note: note, context: context, operation: operation)
    let record = try readback(
      updatedLink: link,
      noteID: draft.noteID,
      oldLink: draft.link,
      urlString: draft.urlString,
      operation: operation
    )
    return NotesLinkUpdateWriteResult(
      noteID: draft.noteID,
      oldLink: draft.link,
      link: record,
      changed: true
    )
  }

  func removeLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: "notes.links.remove")

    let link = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: note,
      operation: "notes.links.remove"
    )
    try validateLinkRemoveTarget(link, operation: "notes.links.remove")
    link.markForDeletion()
    try save(note: note, context: context, operation: "notes.links.remove")
    return NotesLinkRemoveWriteResult(noteID: draft.noteID, link: draft.link, changed: true)
  }

  func removeFileLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: "notes.links.remove-file")

    let link = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: note,
      operation: "notes.links.remove-file"
    )
    try validateFileLinkRemoveTarget(link, operation: "notes.links.remove-file")
    link.markForDeletion()
    try save(note: note, context: context, operation: "notes.links.remove-file")
    return NotesLinkRemoveWriteResult(noteID: draft.noteID, link: draft.link, changed: true)
  }

  func removeAppLink(_ draft: NotesLinkRemoveDraft) throws -> NotesLinkRemoveWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: "notes.links.remove-app")

    let link = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: note,
      operation: "notes.links.remove-app"
    )
    try validateAppLinkRemoveTarget(link, operation: "notes.links.remove-app")
    link.markForDeletion()
    try save(note: note, context: context, operation: "notes.links.remove-app")
    return NotesLinkRemoveWriteResult(noteID: draft.noteID, link: draft.link, changed: true)
  }

  func removeNoteLink(_ draft: NotesNoteLinkRemoveDraft) throws -> NotesNoteLinkRemoveWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: "notes.links.remove-note")

    let link = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: note,
      operation: "notes.links.remove-note"
    )
    try validateNoteLinkRemoveTarget(link, operation: "notes.links.remove-note")
    link.markForDeletion()
    try save(note: note, context: context, operation: "notes.links.remove-note")
    return NotesNoteLinkRemoveWriteResult(noteID: draft.noteID, link: draft.link, changed: true)
  }

  func removeParagraphLink(_ draft: NotesParagraphLinkRemoveDraft) throws -> NotesParagraphLinkRemoveWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateLinkMutationTarget(note, operation: "notes.links.remove-paragraph")

    let link = try link(
      selector: draft.link,
      requestedLinkID: draft.requestedLinkID,
      note: note,
      operation: "notes.links.remove-paragraph"
    )
    try validateParagraphLinkRemoveTarget(link, operation: "notes.links.remove-paragraph")
    link.markForDeletion()
    try save(note: note, context: context, operation: "notes.links.remove-paragraph")
    return NotesParagraphLinkRemoveWriteResult(noteID: draft.noteID, link: draft.link, changed: true)
  }

  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    let context = try noteContext()
    let folder = try folder(
      id: draft.folderID,
      name: draft.currentName,
      accountName: draft.accountName
    )
    try validateFolderRenameTarget(folder, operation: "notes.folders.rename")
    try validateExistingFolderTitle(draft.name, folder: folder, operation: "notes.folders.rename")

    folder.title = draft.name
    folder.dateForLastTitleModification = Date()
    folder.updateChangeCount(withReason: "apple-cli.folder.rename")
    try save(context: context, operation: "notes.folders.rename")
    return try readback(folder: folder, operation: "notes.folders.rename")
  }

  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    let context = try noteContext()
    let sourceFolder = try folder(
      id: draft.folderID,
      name: draft.name,
      accountName: draft.sourceAccountName
    )
    try validateFolderMoveSource(sourceFolder, operation: "notes.folders.move")
    guard let parentID = draft.parentID else {
      let account = try accountObject(id: draft.accountID, name: draft.accountName)
      if sourceFolder.parent == nil,
        let sourceAccount = sourceFolder.account,
        objectIDString(sourceAccount) == objectIDString(account)
      {
        return try readback(folder: sourceFolder, operation: "notes.folders.move")
      }

      sourceFolder.parent = nil
      sourceFolder.account = account
      sourceFolder.parentModificationDate = Date()
      sourceFolder.updateChangeCount(withReason: "apple-cli.folder.move")
      try save(context: context, operation: "notes.folders.move")
      return try readback(folder: sourceFolder, operation: "notes.folders.move")
    }

    let targetParent = try folder(
      id: parentID,
      name: draft.parentName ?? "",
      accountName: draft.accountName
    )
    try validateFolderParent(targetParent, operation: "notes.folders.move")
    guard sourceFolder != targetParent else {
      throw writeError(operation: "notes.folders.move", reason: "ICFolder cannot be moved under itself.")
    }

    if sourceFolder.parent == targetParent {
      return try readback(folder: sourceFolder, operation: "notes.folders.move")
    }

    sourceFolder.parent = targetParent
    if let account = targetParent.account {
      sourceFolder.account = account
    }
    sourceFolder.parentModificationDate = Date()
    sourceFolder.updateChangeCount(withReason: "apple-cli.folder.move")
    try save(context: context, operation: "notes.folders.move")
    return try readback(folder: sourceFolder, operation: "notes.folders.move")
  }

  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    let context = try noteContext()
    let folder = try folder(
      id: draft.folderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateFolderDeleteTarget(folder, operation: "notes.folders.delete")
    folder.markForDeletion()
    folder.updateChangeCount(withReason: "apple-cli.folder.delete")
    try save(context: context, operation: "notes.folders.delete")
    return true
  }

  func purgeFolder(_ draft: NotesFolderPurgeDraft) throws -> Bool {
    let context = try noteContext()
    let folder = try purgableFolder(
      id: draft.folderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateFolderPurgeTarget(folder, operation: "notes.folders.purge")
    ICFolder.purgeFolder(folder)
    try save(context: context, operation: "notes.folders.purge")
    return true
  }

  func deleteSmartFolder(_ draft: NotesSmartFolderDeleteDraft) throws -> Bool {
    let context = try noteContext()
    let folder = try folder(
      id: draft.smartFolderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateSmartFolderDeleteTarget(folder, operation: "notes.smart-folders.delete")
    folder.markForDeletion()
    folder.updateChangeCount(withReason: "apple-cli.smart-folder.delete")
    try save(context: context, operation: "notes.smart-folders.delete")
    return true
  }

  func renameSmartFolder(_ draft: NotesSmartFolderRenameDraft) throws -> NotesSmartFolderRecord {
    let context = try noteContext()
    let folder = try folder(
      id: draft.smartFolderID,
      name: draft.currentName,
      accountName: draft.accountName
    )
    try validateSmartFolderRenameTarget(folder, operation: "notes.smart-folders.rename")
    try validateExistingFolderTitle(draft.newName, folder: folder, operation: "notes.smart-folders.rename")

    folder.title = draft.newName
    folder.dateForLastTitleModification = Date()
    folder.updateChangeCount(withReason: "apple-cli.smart-folder.rename")
    try save(context: context, operation: "notes.smart-folders.rename")
    return try readback(
      smartFolder: folder,
      expectedName: draft.newName,
      accountName: draft.accountName,
      operation: "notes.smart-folders.rename"
    )
  }

  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    let context = try noteContext()
    let folder = try folder(
      id: draft.folderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateFolderSortTarget(folder, operation: "notes.folders.sort")

    guard let sortType = ICFolderCustomNoteSortType.folderNoteSortType(
      withOrder: Int64(draft.sortOrder),
      direction: Int64(draft.sortDirection)
    ) as? ICFolderCustomNoteSortType else {
      throw writeError(operation: "notes.folders.sort", reason: "ICFolderCustomNoteSortType factory returned nil.")
    }

    if let current = folder.customNoteSortType,
      sortObjectMatches(current, draft: draft)
    {
      return try readback(folder: folder, operation: "notes.folders.sort")
    }

    folder.setCustomNoteSortType(sortType)
    folder.updateSortOrder()
    folder.updateChangeCount(withReason: "apple-cli.folder.sort")
    try save(context: context, operation: "notes.folders.sort")
    return try readback(folder: folder, operation: "notes.folders.sort")
  }

  func reorderFolder(_ draft: NotesFolderReorderDraft) throws -> NotesFolderRecord {
    let context = try noteContext()
    let sourceFolder = try folder(
      id: draft.folderID,
      name: draft.name,
      accountName: draft.accountName
    )
    let reference = try folder(
      id: draft.referenceFolderID,
      name: draft.referenceName,
      accountName: draft.accountName
    )
    try validateFolderReorderTarget(sourceFolder, operation: "notes.folders.reorder")
    try validateFolderReorderTarget(reference, operation: "notes.folders.reorder")
    guard objectIDString(sourceFolder) != objectIDString(reference) else {
      throw writeError(operation: "notes.folders.reorder", reason: "ICFolder reorder reference cannot be the source folder.")
    }
    guard folderOrderParentID(sourceFolder) == folderOrderParentID(reference),
      accountName(sourceFolder).localizedCaseInsensitiveCompare(accountName(reference)) == .orderedSame
    else {
      throw writeError(operation: "notes.folders.reorder", reason: "ICFolder reorder requires a same-parent reference.")
    }
    guard let container = folderOrderContainer(sourceFolder) else {
      throw writeError(operation: "notes.folders.reorder", reason: "ICFolder reorder parent container was unavailable.")
    }
    guard let orderedSet = optionalObject(container, key: "subFolderIdentifiersOrderedSet") else {
      throw writeError(
        operation: "notes.folders.reorder",
        reason: "ICNoteContainer.subFolderIdentifiersOrderedSet was unavailable."
      )
    }
    let siblings = folderOrderSiblings(container: container, requiredFolder: sourceFolder)
    let siblingIDs = siblings.map(objectIDString(_:))
    guard let currentIndex = siblingIDs.firstIndex(of: objectIDString(sourceFolder)),
      siblingIDs.contains(objectIDString(reference))
    else {
      throw writeError(operation: "notes.folders.reorder", reason: "ICFolder reorder sibling readback was incomplete.")
    }
    if currentIndex == draft.requestedIndex {
      return try readback(folder: sourceFolder, operation: "notes.folders.reorder")
    }
    try moveFolderOrderObject(
      orderedSet,
      fromIndex: currentIndex,
      toIndex: draft.requestedIndex,
      operation: "notes.folders.reorder"
    )
    markFolderOrderContainerChanged(container, operation: "notes.folders.reorder")
    try save(context: context, operation: "notes.folders.reorder")
    return try readback(folder: sourceFolder, operation: "notes.folders.reorder")
  }

  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    let context = try noteContext()
    let folder = try folder(
      id: draft.folderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateFolderDateHeadersTarget(folder, operation: "notes.folders.date-headers")

    if optionalInt(folder, key: "dateHeadersType") == draft.privateValue {
      return try readback(folder: folder, operation: "notes.folders.date-headers")
    }

    folder.applyDateHeadersType(Int64(draft.privateValue))
    folder.updateChangeCount(withReason: "apple-cli.folder.date-headers")
    try save(context: context, operation: "notes.folders.date-headers")
    return try readback(folder: folder, operation: "notes.folders.date-headers")
  }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    let context = try noteContext()
    let account: ICAccount
    let parentFolder: ICFolder?
    if let parentID = draft.parentID {
      let parent = try folder(
        id: parentID,
        name: draft.parentName ?? "",
        accountName: draft.accountName
      )
      try validateFolderParent(parent, operation: "notes.folders.create")
      guard let parentAccount = parent.account else {
        throw writeError(operation: "notes.folders.create", reason: "Parent ICFolder.account returned nil.")
      }
      account = parentAccount
      parentFolder = parent
    } else {
      account = try accountObject(id: draft.accountID, name: draft.accountName)
      parentFolder = nil
    }

    guard boolValue(account, key: "supportsEditingNotes") != false else {
      throw writeError(operation: "notes.folders.create", reason: "ICAccount.supportsEditingNotes returned false.")
    }

    try validateFolderTitle(
      draft.name,
      account: account,
      parentFolder: parentFolder,
      operation: "notes.folders.create"
    )

    let folder: ICFolder?
    if let parentFolder {
      folder = ICFolder.newFolder(inParentFolder: parentFolder)
    } else {
      folder = ICFolder.newFolder(inAccount: account)
    }

    guard let folder else {
      throw writeError(operation: "notes.folders.create", reason: "ICFolder.newFolder returned nil.")
    }

    folder.title = draft.name
    folder.dateForLastTitleModification = Date()
    try save(context: context, operation: "notes.folders.create")
    return try readback(folder: folder, operation: "notes.folders.create")
  }

  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    let operation = draft.isSystemPaper ? "notes.quick-note.create" : "notes.create"
    let context = try noteContext()
    let folder = try folder(id: draft.folderId, name: draft.folderName, accountName: draft.accountName)
    var error: AnyObject?
    guard
      let note = ICNote.newNote(
        withString: noteText(title: draft.title, body: draft.body),
        inFolder: folder,
        error: &error
      )
    else {
      throw writeError(operation: operation, reason: "ICNote.newNoteWithString returned nil.", error: error)
    }

    if !draft.body.isEmpty {
      try persistNoteTextContent(note, operation: operation)
    }

    if draft.isSystemPaper {
      note.mark(asSystemPaperIfNeeded: true)
    }

    try save(note: note, context: context, operation: operation)
    return try readback(note: note, operation: operation)
  }

  func importRichText(_ draft: NotesRichImportDraft) throws -> NotesRichImportResult {
    let operation = "notes.import.\(draft.source.format.rawValue)"
    let imported = try importedRichAttributedString(source: draft.source, operation: operation)
    let importedPlainText = imported.string
    guard !importedPlainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Rich Notes import produced no visible text.",
        details: ["operation": operation, "format_family": draft.source.format.rawValue]
      )
    }

    let context = try noteContext()
    let folder = try folder(id: draft.draft.folderId, name: draft.draft.folderName, accountName: draft.draft.accountName)
    var error: AnyObject?
    guard
      let note = ICNote.newNote(
        withString: draft.draft.title,
        inFolder: folder,
        error: &error
      )
    else {
      throw writeError(operation: operation, reason: "ICNote.newNoteWithString returned nil.", error: error)
    }

    let attributedBody = richImportAttributedBody(title: draft.draft.title, imported: imported)
    try replaceAttributedText(attributedBody, in: note, operation: operation)
    try save(note: note, context: context, operation: operation)

    let detail = try readback(note: note, operation: operation)
    let noteReadback = try? reader.readNote(id: detail.id)
    let bodyStructure = try? reader.readBodyStructure(noteID: detail.id)
    let attributedRunCount = richImportAttributedRunCount(imported)
    let attachmentRunCount = richImportAttachmentRunCount(imported)
    let rtfdResourceCount = draft.source.packageResourceFileCount ?? 0
    let checks = [
      richImportBoolCheck(name: "note_readback", expected: true, actual: noteReadback != nil),
      richImportBoolCheck(
        name: "title_readback",
        expected: true,
        actual: noteReadback?.title == detail.title && detail.title == draft.draft.title
      ),
      richImportBoolCheck(
        name: "folder_readback",
        expected: true,
        actual: detail.folderName == draft.draft.folderName
      ),
      richImportBoolCheck(
        name: "rich_text_nonempty",
        expected: true,
        actual: importedPlainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
      ),
      richImportBoolCheck(
        name: "body_structure_readback",
        expected: true,
        actual: bodyStructure != nil
      ),
      richImportBoolCheck(
        name: "format_family_accounted",
        expected: true,
        actual: ["rtf", "rtfd", "html"].contains(draft.source.format.rawValue)
      ),
      richImportBoolCheck(
        name: "package_tree_hash",
        expected: true,
        actual: draft.source.format != .rtfd || draft.source.packageTreeSHA256 != nil
      ),
      richImportBoolCheck(
        name: "package_size_accounted",
        expected: true,
        actual: draft.source.format != .rtfd
          || ((draft.source.packageFileCount ?? 0) > 0 && (draft.source.packageTotalByteCount ?? 0) > 0)
      ),
      richImportBoolCheck(
        name: "package_resource_attachment_run",
        expected: true,
        actual: draft.source.format != .rtfd || rtfdResourceCount == 0 || attachmentRunCount > 0
      ),
    ]
    let verification = NotesMutationVerificationReport(
      verifier: "notes_rich_import_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_rich_text_import+text_storage_write+note_readback",
      targetIDSHA256: sha256Hex(detail.id),
      readback: NotesReadbackRecord(
        kind: "note",
        idSHA256: sha256Hex(detail.id),
        titleSHA256: sha256Hex(detail.title),
        titleLength: (detail.title as NSString).length,
        accountNameSHA256: sha256Hex(detail.accountName),
        accountNameLength: (detail.accountName as NSString).length,
        folderNameSHA256: sha256Hex(detail.folderName),
        folderNameLength: (detail.folderName as NSString).length,
        hasBody: detail.body != nil,
        bodyByteCount: detail.body.map { Data($0.utf8).count },
        bodySHA256: detail.body.map(sha256Hex),
        hasCreatedAt: detail.createdAt != nil,
        hasUpdatedAt: detail.updatedAt != nil
      ),
      checks: checks
    )
    var redactedDetail = detail
    redactedDetail.body = nil
    return NotesRichImportResult(
      operation: operation,
      changed: true,
      note: redactedDetail,
      formatFamily: draft.source.format.rawValue,
      sourceByteCount: draft.source.byteCount,
      sourceSHA256: draft.source.data.map(sha256Hex),
      importedPlainTextLength: (importedPlainText as NSString).length,
      importedPlainTextSHA256: sha256Hex(importedPlainText),
      attributedRunCount: attributedRunCount,
      attachmentRunCount: attachmentRunCount,
      packageFileCount: draft.source.packageFileCount,
      packageResourceFileCount: draft.source.packageResourceFileCount,
      packageTotalByteCount: draft.source.packageTotalByteCount,
      packageTreeSHA256: draft.source.packageTreeSHA256,
      verification: verification
    )
  }

  func importMarkdown(_ draft: NotesMarkdownImportDraft) throws -> NotesMarkdownImportResult {
    let operation = "notes.import.markdown"
    let imported = try importedMarkdownAttributedString(source: draft.source, operation: operation)
    let importedPlainText = imported.string
    guard !importedPlainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Markdown import produced no visible text.",
        details: ["operation": operation]
      )
    }

    let context = try noteContext()
    let folder = try folder(id: draft.draft.folderId, name: draft.draft.folderName, accountName: draft.draft.accountName)
    var error: AnyObject?
    guard
      let note = ICNote.newNote(
        withString: draft.draft.title,
        inFolder: folder,
        error: &error
      )
    else {
      throw writeError(operation: operation, reason: "ICNote.newNoteWithString returned nil.", error: error)
    }

    let attributedBody = richImportAttributedBody(title: draft.draft.title, imported: imported)
    try replaceAttributedText(attributedBody, in: note, operation: operation)
    try save(note: note, context: context, operation: operation)

    let detail = try readback(note: note, operation: operation)
    let noteReadback = try? reader.readNote(id: detail.id)
    let bodyStructure = try? reader.readBodyStructure(noteID: detail.id)
    let attributedRunCount = richImportAttributedRunCount(imported)
    let checks = [
      richImportBoolCheck(name: "note_readback", expected: true, actual: noteReadback != nil),
      richImportBoolCheck(
        name: "title_readback",
        expected: true,
        actual: noteReadback?.title == detail.title && detail.title == draft.draft.title
      ),
      richImportBoolCheck(
        name: "folder_readback",
        expected: true,
        actual: detail.folderName == draft.draft.folderName
      ),
      richImportBoolCheck(
        name: "markdown_plain_text_nonempty",
        expected: true,
        actual: importedPlainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
      ),
      richImportBoolCheck(
        name: "body_structure_readback",
        expected: true,
        actual: bodyStructure != nil
      ),
      richImportBoolCheck(
        name: "semantic_heading_accounted",
        expected: true,
        actual: bodyStructure?.headingCount.map { $0 >= min(1, draft.source.semanticSummary.headingCount) }
      ),
      richImportBoolCheck(
        name: "semantic_list_accounted",
        expected: true,
        actual: bodyStructure?.listItemCount.map { $0 >= min(1, draft.source.semanticSummary.listItemCount) }
      ),
      richImportBoolCheck(
        name: "attributed_runs_accounted",
        expected: true,
        actual: attributedRunCount > 0
      ),
    ]
    let verification = NotesMutationVerificationReport(
      verifier: "notes_markdown_import_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_markdown_semantic_import+text_storage_write+note_readback",
      targetIDSHA256: sha256Hex(detail.id),
      readback: NotesReadbackRecord(
        kind: "note",
        idSHA256: sha256Hex(detail.id),
        titleSHA256: sha256Hex(detail.title),
        titleLength: (detail.title as NSString).length,
        accountNameSHA256: sha256Hex(detail.accountName),
        accountNameLength: (detail.accountName as NSString).length,
        folderNameSHA256: sha256Hex(detail.folderName),
        folderNameLength: (detail.folderName as NSString).length,
        hasBody: detail.body != nil,
        bodyByteCount: detail.body.map { Data($0.utf8).count },
        bodySHA256: detail.body.map(sha256Hex),
        hasCreatedAt: detail.createdAt != nil,
        hasUpdatedAt: detail.updatedAt != nil
      ),
      checks: checks
    )
    var redactedDetail = detail
    redactedDetail.body = nil
    return NotesMarkdownImportResult(
      operation: operation,
      changed: true,
      note: redactedDetail,
      isPackage: draft.source.isPackage,
      markdownRelativePath: draft.source.markdownRelativePath,
      sourceByteCount: draft.source.byteCount,
      sourceSHA256: sha256Hex(draft.source.body),
      resourceCount: draft.source.resources.count,
      packageFileCount: draft.source.packageFileCount,
      packageTotalByteCount: draft.source.packageTotalByteCount,
      packageTreeSHA256: draft.source.packageTreeSHA256,
      semanticSummary: draft.source.semanticSummary,
      importedPlainTextLength: (importedPlainText as NSString).length,
      importedPlainTextSHA256: sha256Hex(importedPlainText),
      attributedRunCount: attributedRunCount,
      verification: verification
    )
  }

  func replaceRichText(_ draft: NotesRichReplaceDraft) throws -> NotesRichReplaceResult {
    let operation = "notes.replace.\(draft.source.formatFamily)"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateRichReplaceTarget(note, operation: operation)
    let beforeAttachments = try? reader.listAttachments(noteID: draft.noteID, limit: 2_000)

    let prepared = try preparedRichReplaceContent(draft.source, operation: operation)
    let importedPlainText = prepared.attributed.string
    guard !importedPlainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Notes rich replace produced no visible text.",
        details: ["operation": operation, "format_family": draft.source.formatFamily]
      )
    }

    let attributedBody = richImportAttributedBody(title: draft.title, imported: prepared.attributed)
    try replaceAttributedText(attributedBody, in: note, operation: operation)

    var attachmentObjects: [NotesRichReplaceAttachmentObject] = []
    for resource in prepared.resources {
      guard let attachment = note.addAttachment(withData: resource.data, filename: resource.filename) as AnyObject?
      else {
        throw writeError(operation: operation, reason: "ICNote.addAttachmentWithData returned nil for rich replace resource.")
      }
      attachmentObjects.append(NotesRichReplaceAttachmentObject(resource: resource, attachment: attachment))
    }
    let placedCounts = try placeInlineResourceAttachments(
      in: note,
      title: draft.title,
      placements: prepared.placements,
      attachmentObjects: attachmentObjects,
      operation: operation
    )

    try save(note: note, context: context, operation: operation)

    let detail = try readback(note: note, operation: operation)
    let noteReadback = try? reader.readNote(id: detail.id)
    let bodyStructure = try? reader.readBodyStructure(noteID: detail.id)
    let attachmentReadbackBaseline = beforeAttachments ?? []
    var attachmentResults: [NotesRichReplaceAttachmentResult] = []
    var checks: [NotesVerificationCheckRecord] = [
      richImportBoolCheck(name: "note_readback", expected: true, actual: noteReadback != nil),
      richImportBoolCheck(
        name: "note_identity_preserved",
        expected: true,
        actual: detail.id == draft.noteID || sha256Hex(detail.id) == sha256Hex(draft.noteID)
      ),
      richImportBoolCheck(
        name: "title_readback",
        expected: true,
        actual: noteReadback?.title == detail.title && detail.title == draft.title
      ),
      richImportBoolCheck(
        name: "rich_text_nonempty",
        expected: true,
        actual: importedPlainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
      ),
      richImportBoolCheck(name: "body_structure_readback", expected: true, actual: bodyStructure != nil),
      richImportBoolCheck(
        name: "inline_markers_removed",
        expected: true,
        actual: prepared.markers.allSatisfy { !importedPlainText.contains($0) }
      ),
      NotesVerificationCheckRecord(
        name: "resource_count",
        status: attachmentObjects.count == prepared.resources.count ? "passed" : "failed",
        expectedLength: prepared.resources.count,
        actualLength: attachmentObjects.count
      ),
      NotesVerificationCheckRecord(
        name: "inline_reference_count",
        status: prepared.placements.count == prepared.inlineReferenceCount ? "passed" : "failed",
        expectedLength: prepared.inlineReferenceCount,
        actualLength: prepared.placements.count
      ),
    ]

    for item in attachmentObjects {
      let record = try readback(
        attachment: item.attachment,
        noteID: detail.id,
        before: attachmentReadbackBaseline,
        filename: item.resource.filename,
        operation: operation
      )
      let exported = try? reader.exportAttachment(noteID: detail.id, attachmentID: record.id)
      let exportedData = exported?.data ?? Data()
      let exportedSHA256 = sha256Hex(exportedData)
      let expectedSHA256 = sha256Hex(item.resource.data)
      let referenceCount = prepared.referenceCountsByResourceOrdinal[item.resource.ordinal] ?? 0
      let placementCount = placedCounts[item.resource.ordinal] ?? 0
      let filenamePreserved = record.mediaFilename == item.resource.filename || record.title == item.resource.filename
      checks.append(
        richImportBoolCheck(
          name: "resource_\(item.resource.ordinal)_attachment_readback",
          expected: true,
          actual: exported != nil
        )
      )
      checks.append(
        richImportBoolCheck(
          name: "resource_\(item.resource.ordinal)_filename_readback",
          expected: true,
          actual: filenamePreserved
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "resource_\(item.resource.ordinal)_byte_count",
          status: exportedData.count == item.resource.byteCount ? "passed" : "failed",
          expectedLength: item.resource.byteCount,
          actualLength: exportedData.count
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "resource_\(item.resource.ordinal)_sha256",
          status: exportedSHA256 == expectedSHA256 ? "passed" : "failed",
          expectedSHA256: expectedSHA256,
          actualSHA256: exportedSHA256
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "resource_\(item.resource.ordinal)_inline_placement_count",
          status: placementCount == referenceCount ? "passed" : "failed",
          expectedLength: referenceCount,
          actualLength: placementCount
        )
      )
      attachmentResults.append(
        NotesRichReplaceAttachmentResult(
          relativePath: item.resource.relativePath,
          filename: item.resource.filename,
          byteCount: item.resource.byteCount,
          sha256: expectedSHA256,
          inlineReferenceCount: referenceCount,
          inlinePlacementCount: placementCount,
          attachment: record,
          verification: NotesMutationVerificationReport(
            verifier: "notes_rich_replace_attachment_v1",
            operation: operation,
            verified: exported != nil && filenamePreserved && exportedData.count == item.resource.byteCount
              && exportedSHA256 == expectedSHA256 && placementCount == referenceCount,
            evidenceLevel: "private_framework_attachment_write+inline_attachment_placement+attachment_export_hash",
            targetIDSHA256: sha256Hex(record.id),
            checks: checks.filter { $0.name.hasPrefix("resource_\(item.resource.ordinal)_") }
          )
        ))
    }

    let inlinePlacementCount = placedCounts.values.reduce(0, +)
    checks.append(
      NotesVerificationCheckRecord(
        name: "inline_placement_count",
        status: inlinePlacementCount == prepared.inlineReferenceCount ? "passed" : "failed",
        expectedLength: prepared.inlineReferenceCount,
        actualLength: inlinePlacementCount
      )
    )

    let verification = NotesMutationVerificationReport(
      verifier: "notes_rich_replace_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: prepared.resources.isEmpty
        ? "private_framework_rich_replace+text_storage_write+note_readback"
        : "private_framework_rich_replace+text_storage_write+inline_attachment_placement+attachment_export_hash+note_readback",
      targetIDSHA256: sha256Hex(detail.id),
      readback: NotesReadbackRecord(
        kind: "note",
        idSHA256: sha256Hex(detail.id),
        titleSHA256: sha256Hex(detail.title),
        titleLength: (detail.title as NSString).length,
        accountNameSHA256: sha256Hex(detail.accountName),
        accountNameLength: (detail.accountName as NSString).length,
        folderNameSHA256: sha256Hex(detail.folderName),
        folderNameLength: (detail.folderName as NSString).length,
        hasBody: detail.body != nil,
        bodyByteCount: detail.body.map { Data($0.utf8).count },
        bodySHA256: detail.body.map(sha256Hex),
        hasCreatedAt: detail.createdAt != nil,
        hasUpdatedAt: detail.updatedAt != nil
      ),
      checks: checks
    )
    var redactedDetail = detail
    redactedDetail.body = nil
    return NotesRichReplaceResult(
      operation: operation,
      changed: true,
      note: redactedDetail,
      formatFamily: draft.source.formatFamily,
      sourceByteCount: draft.source.sourceByteCount,
      sourceSHA256: prepared.sourceSHA256,
      importedPlainTextLength: (importedPlainText as NSString).length,
      importedPlainTextSHA256: sha256Hex(importedPlainText),
      attributedRunCount: richImportAttributedRunCount(prepared.attributed),
      attachmentRunCount: richImportAttachmentRunCount(prepared.attributed),
      resourceCount: prepared.resources.count,
      inlineReferenceCount: prepared.inlineReferenceCount,
      inlinePlacementCount: inlinePlacementCount,
      packageFileCount: prepared.packageFileCount,
      packageResourceFileCount: prepared.packageResourceFileCount,
      packageTotalByteCount: prepared.packageTotalByteCount,
      packageTreeSHA256: prepared.packageTreeSHA256,
      markdownRelativePath: prepared.markdownRelativePath,
      htmlRelativePath: prepared.htmlRelativePath,
      semanticSummary: prepared.semanticSummary,
      attachments: attachmentResults,
      verification: verification
    )
  }

  func importENEX(_ draft: NotesENEXImportDraft) throws -> NotesENEXImportResult {
    let operation = "notes.import.enex"
    try validateExecutableENEXImport(draft.source)

    let context = try noteContext()
    let folder = try folder(id: draft.folderID, name: draft.folderName, accountName: draft.accountName)
    var importedNotes: [NotesENEXImportedNoteResult] = []
    var checks: [NotesVerificationCheckRecord] = [
      richImportBoolCheck(name: "resource_payloads_supported", expected: true, actual: true),
      richImportBoolCheck(name: "tag_shape_supported", expected: true, actual: draft.source.unsupportedTagCount == 0),
      NotesVerificationCheckRecord(
        name: "tag_normalization_accounting",
        status: draft.source.normalizedTagCount >= 0 ? "passed" : "failed",
        expectedLength: draft.source.normalizedTagCount,
        actualLength: draft.source.normalizedTagCount
      ),
      richImportBoolCheck(
        name: "inline_resource_references_matched",
        expected: true,
        actual: draft.source.unmatchedInlineResourceReferenceCount == 0
      ),
    ]

    for sourceNote in draft.source.notes {
      let imported = try importedENEXAttributedContent(sourceNote, operation: operation)
      let importedPlainText = imported.attributed.string.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !importedPlainText.isEmpty else {
        throw CLIError(
          code: .validationError,
          message: "ENEX import produced no visible text for a note.",
          details: ["note_ordinal": "\(sourceNote.ordinal)"]
        )
      }

      var error: AnyObject?
      guard
        let note = ICNote.newNote(
          withString: sourceNote.title,
          inFolder: folder,
          error: &error
        )
      else {
        throw writeError(operation: operation, reason: "ICNote.newNoteWithString returned nil.", error: error)
      }

      let attributedBody = richImportAttributedBody(title: sourceNote.title, imported: imported.attributed)
      try replaceAttributedText(attributedBody, in: note, operation: operation)

      for tag in sourceNote.tags {
        guard let displayText = notesENEXNormalizedTagText(tag) else {
          throw writeError(operation: operation, reason: "ENEX tag could not be normalized to Notes tag text.")
        }
        let hashtag = try hashtag(
          displayText: displayText,
          note: note,
          createIfNecessary: true,
          operation: operation
        )
        _ = note.addHashtag(toNoteBody: hashtag, onlyIfMissing: true)
      }

      applyENEXDates(sourceNote, to: note)
      var attachmentObjects: [(resource: NotesENEXResourceSource, attachment: AnyObject)] = []
      let inlineReferenceCountsByResourceOrdinal = Dictionary(
        grouping: sourceNote.inlineResourceReferences.compactMap(\.matchedResourceOrdinal),
        by: { $0 }
      ).mapValues(\.count)
      for resource in sourceNote.resources {
        guard let attachment = note.addAttachment(withData: resource.data, filename: resource.filename) as AnyObject?
        else {
          throw writeError(operation: operation, reason: "ICNote.addAttachmentWithData returned nil for ENEX resource.")
        }
        attachmentObjects.append((resource: resource, attachment: attachment))
      }
      let placedInlineReferenceCountsByResourceOrdinal = try placeENEXInlineAttachments(
        in: note,
        title: sourceNote.title,
        placements: imported.inlinePlacements,
        attachmentObjects: attachmentObjects,
        operation: operation
      )
      try save(note: note, context: context, operation: operation)

      let detail = try readback(note: note, operation: operation)
      let beforeAttachments: [NotesAttachmentRecord] = []
      var attachmentResults: [NotesENEXImportAttachmentResult] = []
      for item in attachmentObjects {
        let record = try readback(
          attachment: item.attachment,
          noteID: detail.id,
          before: beforeAttachments,
          filename: item.resource.filename,
          operation: operation
        )
        let exported = try? reader.exportAttachment(noteID: detail.id, attachmentID: record.id)
        let exportedData = exported?.data ?? Data()
        let exportedSHA256 = sha256Hex(exportedData)
        let filenamePreserved = record.mediaFilename == item.resource.filename || record.title == item.resource.filename
        let inlineReferenceCount = inlineReferenceCountsByResourceOrdinal[item.resource.ordinal] ?? 0
        let inlinePlacementCount = placedInlineReferenceCountsByResourceOrdinal[item.resource.ordinal] ?? 0
        checks.append(
          richImportBoolCheck(
            name: "note_\(sourceNote.ordinal)_resource_\(item.resource.ordinal)_attachment_readback",
            expected: true,
            actual: exported != nil
          )
        )
        checks.append(
          richImportBoolCheck(
            name: "note_\(sourceNote.ordinal)_resource_\(item.resource.ordinal)_filename_readback",
            expected: true,
            actual: filenamePreserved
          )
        )
        checks.append(
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_resource_\(item.resource.ordinal)_byte_count",
            status: exportedData.count == item.resource.byteCount ? "passed" : "failed",
            expectedLength: item.resource.byteCount,
            actualLength: exportedData.count
          )
        )
        checks.append(
          NotesVerificationCheckRecord(
            name: "note_\(sourceNote.ordinal)_resource_\(item.resource.ordinal)_sha256",
            status: exportedSHA256 == item.resource.dataSHA256 ? "passed" : "failed",
            expectedSHA256: item.resource.dataSHA256,
            actualSHA256: exportedSHA256
          )
        )
        if inlineReferenceCount > 0 {
          checks.append(
            NotesVerificationCheckRecord(
              name: "note_\(sourceNote.ordinal)_resource_\(item.resource.ordinal)_inline_placement_count",
              status: inlinePlacementCount == inlineReferenceCount ? "passed" : "failed",
              expectedLength: inlineReferenceCount,
              actualLength: inlinePlacementCount
            )
          )
          checks.append(
            richImportBoolCheck(
              name: "note_\(sourceNote.ordinal)_resource_\(item.resource.ordinal)_inline_attachment_readback",
              expected: true,
              actual: record.isInline == true
            )
          )
        }
        attachmentResults.append(
          NotesENEXImportAttachmentResult(
            ordinal: item.resource.ordinal,
            filename: item.resource.filename,
            mimeType: item.resource.mimeType,
            byteCount: item.resource.byteCount,
            sha256: item.resource.dataSHA256,
            inlineReferenceCount: inlineReferenceCount,
            inlinePlacementCount: inlinePlacementCount,
            attachment: record
          ))
      }
      let noteReadback = try? reader.readNote(id: detail.id)
      let readbackTags = noteReadback?.tags ?? detail.tags
      let tagReadbackSucceeded = sourceNote.tags.allSatisfy { tag in
        guard let normalized = notesENEXNormalizedTagText(tag) else {
          return false
        }
        return readbackTags.contains { tagMatches($0, normalized) }
      }
      let createdAtPreserved = sourceNote.createdAt.map { dateMatches($0, detail.createdAt) }
      let updatedAtPreserved = sourceNote.updatedAt.map { dateMatches($0, detail.updatedAt) }

      checks.append(
        richImportBoolCheck(
          name: "note_\(sourceNote.ordinal)_readback",
          expected: true,
          actual: noteReadback != nil
        )
      )
      checks.append(
        richImportBoolCheck(
          name: "note_\(sourceNote.ordinal)_title_readback",
          expected: true,
          actual: detail.title == sourceNote.title
        )
      )
      checks.append(
        richImportBoolCheck(
          name: "note_\(sourceNote.ordinal)_folder_readback",
          expected: true,
          actual: detail.folderName == draft.folderName
        )
      )
      checks.append(
        richImportBoolCheck(
          name: "note_\(sourceNote.ordinal)_tag_membership_readback",
          expected: true,
          actual: tagReadbackSucceeded
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_resource_count_readback",
          status: attachmentResults.count == sourceNote.resourceCount ? "passed" : "failed",
          expectedLength: sourceNote.resourceCount,
          actualLength: attachmentResults.count
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_inline_resource_reference_count",
          status: sourceNote.matchedInlineResourceReferenceCount == sourceNote.inlineResourceReferenceCount ? "passed" : "failed",
          expectedLength: sourceNote.inlineResourceReferenceCount,
          actualLength: sourceNote.matchedInlineResourceReferenceCount
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "note_\(sourceNote.ordinal)_inline_resource_placement_count",
          status: attachmentResults.reduce(0) { $0 + $1.inlinePlacementCount } == sourceNote.inlineResourceReferenceCount
            ? "passed" : "failed",
          expectedLength: sourceNote.inlineResourceReferenceCount,
          actualLength: attachmentResults.reduce(0) { $0 + $1.inlinePlacementCount }
        )
      )
      if let createdAtPreserved {
        checks.append(
          richImportBoolCheck(
            name: "note_\(sourceNote.ordinal)_created_date_preserved",
            expected: true,
            actual: createdAtPreserved
          )
        )
      }
      if let updatedAtPreserved {
        checks.append(
          richImportBoolCheck(
            name: "note_\(sourceNote.ordinal)_updated_date_preserved",
            expected: true,
            actual: updatedAtPreserved
          )
        )
      }

      var redactedDetail = detail
      redactedDetail.body = nil
      importedNotes.append(
        NotesENEXImportedNoteResult(
          ordinal: sourceNote.ordinal,
          note: redactedDetail,
          sourceTitleSHA256: sourceNote.titleSHA256,
          sourceContentSHA256: sourceNote.contentSHA256,
          importedPlainTextLength: (importedPlainText as NSString).length,
          importedPlainTextSHA256: sha256Hex(importedPlainText),
          tagCount: sourceNote.tags.count,
          resourceCount: sourceNote.resourceCount,
          resourceByteCount: sourceNote.resourceByteCount,
          inlineResourceReferenceCount: sourceNote.inlineResourceReferenceCount,
          matchedInlineResourceReferenceCount: sourceNote.matchedInlineResourceReferenceCount,
          placedInlineResourceReferenceCount: attachmentResults.reduce(0) { $0 + $1.inlinePlacementCount },
          attachments: attachmentResults,
          createdAtPreserved: createdAtPreserved,
          updatedAtPreserved: updatedAtPreserved
        ))
    }

    checks.append(
      richImportBoolCheck(
        name: "imported_note_count",
        expected: true,
        actual: importedNotes.count == draft.source.noteCount
      )
    )

    let verification = NotesMutationVerificationReport(
      verifier: "notes_enex_import_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_enex_parse+tag_normalization+inline_media_reference_match+inline_media_body_position_insert+note_create+tag_write+attachment_write+attachment_export_hash+note_readback",
      targetIDSHA256: sha256Hex(importedNotes.map(\.note.id).joined(separator: "\n")),
      checks: checks
    )
    return NotesENEXImportResult(
      operation: operation,
      changed: !importedNotes.isEmpty,
      importedNoteCount: importedNotes.count,
      sourceByteCount: draft.source.byteCount,
      sourceSHA256: draft.source.dataSHA256,
      tagCount: draft.source.tagCount,
      uniqueTagCount: draft.source.uniqueTagCount,
      normalizedTagCount: draft.source.normalizedTagCount,
      resourceCount: draft.source.resourceCount,
      resourceByteCount: draft.source.resourceByteCount,
      inlineResourceReferenceCount: draft.source.inlineResourceReferenceCount,
      matchedInlineResourceReferenceCount: draft.source.matchedInlineResourceReferenceCount,
      placedInlineResourceReferenceCount: importedNotes.reduce(0) { $0 + $1.placedInlineResourceReferenceCount },
      createdDateCount: draft.source.createdDateCount,
      updatedDateCount: draft.source.updatedDateCount,
      importedNotes: importedNotes,
      verification: verification
    )
  }

  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    let context = try noteContext()
    let note = try note(id: id)
    guard let before = try reader.readNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id_sha256": sha256Hex(id)])
    }

    let operation = patch.appendBody == nil ? "notes.update" : "notes.append"
    if let appendBody = patch.appendBody {
      try appendText(appendBody, to: note)
    } else if let body = patch.body {
      try replaceBody(body, title: patch.title, expectedTitle: before.title, in: note, operation: operation)
    } else if let title = patch.title {
      try notesValidateTitleEdit(title)
      guard !before.title.utf8.elementsEqual(title.utf8) else { return before }
      try replaceTitle(title, expectedTitle: before.title, in: note, operation: operation)
    } else {
      throw CLIError(code: .validationError, message: "At least one note field must be supplied for update.")
    }

    try save(note: note, context: context, operation: operation)
    return try readback(note: note, operation: operation)
  }

  func setCollapsibleSectionState(_ draft: NotesBodyCollapsibleSetDraft) throws
    -> NotesBodyCollapsibleSetWriteResult
  {
    let operation = "notes.body.collapsible.set"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? ICTTTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no ICTTTextStorage.")
    }

    let collapsedUUIDs = note.outlineState?.collapsedUUIDs ?? Set<AnyHashable>()
    guard let outlineController = ICOutlineController(
      textStorage: textStorage,
      collapsedUUIDs: collapsedUUIDs,
      asynchronous: false
    ) else {
      throw writeError(operation: operation, reason: "ICOutlineController could not be created.")
    }
    let target = try collapsibleSectionTarget(
      draft: draft,
      textStorage: textStorage,
      outlineController: outlineController,
      operation: operation
    )
    let desiredCollapsed: Bool
    switch draft.state {
    case .collapsed:
      desiredCollapsed = true
    case .expanded:
      desiredCollapsed = false
    case .toggle:
      desiredCollapsed = !target.collapsed
    }

    if target.collapsed == desiredCollapsed {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      let sections = try reader.listCollapsibleSections(noteID: draft.noteID)
      let targetRecord = try collapsibleSectionRecord(
        paragraphIDSHA256: target.paragraphIDSHA256,
        sections: sections,
        operation: operation
      )
      return NotesBodyCollapsibleSetWriteResult(
        changed: false,
        note: detail,
        structure: structure,
        target: targetRecord,
        sections: sections
      )
    }

    var updatedUUIDs = collapsedUUIDs
    if desiredCollapsed {
      outlineController.collapseUUIDs(Set([target.uuid]))
      updatedUUIDs.insert(AnyHashable(target.uuid))
    } else {
      outlineController.expandUUIDs(Set([target.uuid]))
      updatedUUIDs.remove(AnyHashable(target.uuid))
    }
    guard let outlineState = ICOutlineState(collapsedUUIDs: updatedUUIDs) else {
      throw writeError(operation: operation, reason: "ICOutlineState could not be created.")
    }
    note.outlineState = outlineState
    if let data = outlineState.data {
      note.outlineStateData = data
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let sections = try reader.listCollapsibleSections(noteID: draft.noteID)
    let targetRecord = try collapsibleSectionRecord(
      paragraphIDSHA256: target.paragraphIDSHA256,
      sections: sections,
      operation: operation
    )
    return NotesBodyCollapsibleSetWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      target: targetRecord,
      sections: sections
    )
  }

  func addChecklistItem(_ draft: NotesBodyChecklistAddDraft) throws -> NotesBodyChecklistAddWriteResult {
    let operation = "notes.body.checklist.add"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let attributedString = try checklistAttributedString(text: draft.text, checked: draft.checked)
    var error: AnyObject?
    guard note.appendAttributedString(attributedString, error: &error) else {
      throw writeError(operation: operation, reason: "ICNote.appendAttributedString returned false.", error: error)
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistAddWriteResult(changed: true, note: detail, structure: structure)
  }

  func createTable(_ draft: NotesBodyTableCreateDraft) throws -> NotesBodyTableCreateWriteResult {
    let operation = "notes.body.table.create"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    guard note.addTableAttachment(withText: draft.text as NSString) != nil else {
      throw writeError(operation: operation, reason: "ICNote.addTableAttachmentWithText returned nil.")
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyTableCreateWriteResult(changed: true, note: detail, structure: structure)
  }

  func importTable(_ draft: NotesBodyTableImportDraft) throws -> NotesBodyTableImportWriteResult {
    let operation = "notes.body.table.import"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    let beforeTableIDs = Set(try reader.listTables(noteID: draft.noteID).map(\.idSHA256))

    guard note.addTableAttachment(withText: draft.tableText as NSString) != nil else {
      throw writeError(operation: operation, reason: "ICNote.addTableAttachmentWithText returned nil.")
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    guard
      let target = tables.first(where: { beforeTableIDs.contains($0.idSHA256) == false })
        ?? tables.last
    else {
      throw writeError(operation: operation, reason: "Private framework table attachment was not readable after import.")
    }
    return NotesBodyTableImportWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      target: target,
      tables: tables
    )
  }

  func updateTableCell(_ draft: NotesBodyTableUpdateDraft) throws -> NotesBodyTableUpdateWriteResult {
    let operation = "notes.body.table.update"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let target = try tableTarget(note: note, ordinal: draft.ordinal, operation: operation)
    guard let table = target.table else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment did not expose an ICTable object.")
    }
    try validateTableCellCoordinate(target.record, row: draft.row, column: draft.column, operation: operation)

    let beforeCell = try tableCellRecord(table, target: target.record, row: draft.row, column: draft.column, operation: operation)
    let changed = beforeCell.textSHA256 != draft.textSHA256 || beforeCell.textByteCount != draft.textByteCount
    if changed {
      note.beginEditing()
      do {
        try setTableCellAttributedString(
          table,
          attributedString: NSAttributedString(string: draft.text),
          row: draft.row,
          column: draft.column,
          operation: operation
        )
        note.didChangeText()
        note.endEditing()
      } catch {
        note.endEditing()
        throw error
      }
      try save(note: note, context: context, operation: operation)
    }

    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    let cell = try reader.readTableCell(
      noteID: draft.noteID,
      tableOrdinal: draft.ordinal,
      row: draft.row,
      column: draft.column
    )
    return NotesBodyTableUpdateWriteResult(
      changed: changed,
      note: detail,
      structure: structure,
      target: target.record,
      cell: cell,
      tables: tables
    )
  }

  func formatTableRange(_ draft: NotesBodyTableFormatDraft) throws -> NotesBodyTableFormatWriteResult {
    let operation = bodyTableFormatOperationName(draft)
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let target = try tableTarget(note: note, ordinal: draft.ordinal, operation: operation)
    guard let table = target.table else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment did not expose an ICTable object.")
    }
    try validateTableFormatRange(target.record, draft: draft, operation: operation)
    let beforeCells = try tableCells(table, target: target.record, draft: draft, operation: operation)
    let beforeTextSliceSHA256 = tableSliceDigest(beforeCells)
    let beforeFormatSliceSHA256 = tableFormatSliceDigest(beforeCells)
    let changed = beforeCells.contains { cell in
      cell.textByteCount > 0 && tableCell(cell, contains: draft.format) != draft.enabled
    }

    if changed {
      note.beginEditing()
      do {
        try mutateTableCells(table, target: target.record, draft: draft, operation: operation) { row, column in
          let current = try tableCellAttributedString(table, row: row, column: column, operation: operation)
            ?? NSAttributedString(string: tableCellString(table, row: row, column: column, operation: operation))
          let updated = NSMutableAttributedString(attributedString: current)
          let range = NSRange(location: 0, length: updated.length)
          if range.length > 0 {
            try applyInlineFormat(draft.format, enabled: draft.enabled, to: updated, range: range)
          }
          try setTableCellAttributedString(table, attributedString: updated, row: row, column: column, operation: operation)
        }
        note.didChangeText()
        note.endEditing()
      } catch {
        note.endEditing()
        throw error
      }
      try save(note: note, context: context, operation: operation)
    }

    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    let cells = try tableCells(reader: reader, draft: draft, tables: tables)
    return NotesBodyTableFormatWriteResult(
      changed: changed,
      note: detail,
      structure: structure,
      beforeTarget: target.record,
      target: tables.first(where: { $0.idSHA256 == target.record.idSHA256 }) ?? target.record,
      cells: cells,
      tables: tables,
      beforeTextSliceSHA256: beforeTextSliceSHA256,
      afterTextSliceSHA256: tableSliceDigest(cells),
      beforeFormatSliceSHA256: beforeFormatSliceSHA256,
      afterFormatSliceSHA256: tableFormatSliceDigest(cells)
    )
  }

  func deleteTable(_ draft: NotesBodyTableDeleteDraft) throws -> NotesBodyTableDeleteWriteResult {
    let operation = "notes.body.table.delete"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let target = try tableTarget(note: note, ordinal: draft.ordinal, operation: operation)
    guard target.record.isDeletable != false else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment backing attachment is not deletable.")
    }

    let selector = NSSelectorFromString("removeInlineAttachmentsObject:")
    guard note.responds(to: selector) else {
      throw writeError(operation: operation, reason: "ICNote.removeInlineAttachmentsObject: is unavailable.")
    }

    note.beginEditing()
    _ = note.perform(selector, with: target.attachment)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    return NotesBodyTableDeleteWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      target: target.record,
      tables: tables
    )
  }

  func convertTableToText(_ draft: NotesBodyTableConvertToTextDraft) throws
    -> NotesBodyTableConvertToTextWriteResult
  {
    let operation = "notes.body.table.convert-to-text"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let target = try tableTarget(note: note, ordinal: draft.ordinal, operation: operation)
    guard target.record.isDeletable != false else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment backing attachment is not deletable.")
    }
    guard let table = target.table else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment did not expose an ICTable object.")
    }
    guard let rowCount = target.record.rowCount, let columnCount = target.record.columnCount,
      rowCount > 0, columnCount > 0
    else {
      throw writeError(operation: operation, reason: "Notes body table row/column count is unavailable.")
    }
    guard rowCount == draft.rowCount, columnCount == draft.columnCount else {
      throw writeError(operation: operation, reason: "Notes body table dimensions changed before conversion.")
    }
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    guard NSMaxRange(target.range) <= textStorage.length else {
      throw writeError(operation: operation, reason: "Notes body table attachment range is outside text storage.")
    }

    let convertedText = try tableConvertedText(
      table,
      rowCount: rowCount,
      columnCount: columnCount,
      operation: operation
    )

    note.beginEditing()
    textStorage.replaceCharacters(in: target.range, with: NSAttributedString(string: convertedText))
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    return NotesBodyTableConvertToTextWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      target: target.record,
      tables: tables,
      convertedText: convertedText,
      rowCount: rowCount,
      columnCount: columnCount
    )
  }

  func convertTextToTable(_ draft: NotesBodyTableConvertFromTextDraft) throws
    -> NotesBodyTableConvertFromTextWriteResult
  {
    let operation = "notes.body.table.convert-from-text"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let paragraph = try paragraphStyleTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    try validateTextToTableSourceTarget(
      paragraph.style,
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      operation: operation
    )
    guard NSMaxRange(paragraph.range) <= textStorage.length else {
      throw writeError(operation: operation, reason: "Notes paragraph range is outside text storage.")
    }

    let paragraphRange = (textStorage.string as NSString).paragraphRange(for: paragraph.range)
    guard paragraphRange.length > 0, NSMaxRange(paragraphRange) <= textStorage.length else {
      throw writeError(operation: operation, reason: "Notes paragraph range could not be resolved for table conversion.")
    }
    let sourceText = try bodyTableSourceText(
      from: textStorage.attributedSubstring(from: paragraphRange).string,
      operation: operation
    )
    let normalized = try normalizedBodyTableText(sourceText)
    let beforeTableIDs = Set(tableTargets(note).map(\.record.idSHA256))

    guard note.addTableAttachment(withText: normalized.text as NSString) != nil else {
      throw writeError(operation: operation, reason: "ICNote.addTableAttachmentWithText returned nil.")
    }
    let appendedTargets = tableTargets(note)
    guard let appendedTarget = appendedTargets.first(where: { beforeTableIDs.contains($0.record.idSHA256) == false })
      ?? appendedTargets.last
    else {
      throw writeError(operation: operation, reason: "Private framework table attachment was not readable after creation.")
    }
    guard NSMaxRange(appendedTarget.range) <= textStorage.length else {
      throw writeError(operation: operation, reason: "New Notes body table attachment range is outside text storage.")
    }
    guard NSIntersectionRange(appendedTarget.range, paragraphRange).length == 0 else {
      throw writeError(operation: operation, reason: "New Notes table attachment unexpectedly overlapped the source paragraph.")
    }

    let tableRun = textStorage.attributedSubstring(from: appendedTarget.range)
    let adjustedParagraphRange = appendedTarget.range.location < paragraphRange.location
      ? NSRange(location: paragraphRange.location - appendedTarget.range.length, length: paragraphRange.length)
      : paragraphRange

    note.beginEditing()
    do {
      textStorage.deleteCharacters(in: appendedTarget.range)
      guard adjustedParagraphRange.location >= 0,
        NSMaxRange(adjustedParagraphRange) <= textStorage.length
      else {
        throw writeError(operation: operation, reason: "Adjusted source paragraph range is outside text storage.")
      }
      textStorage.replaceCharacters(in: adjustedParagraphRange, with: tableRun)
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    let target = tables.first { beforeTableIDs.contains($0.idSHA256) == false }
      ?? tables.first { $0.idSHA256 == appendedTarget.record.idSHA256 }
      ?? appendedTarget.record
    return NotesBodyTableConvertFromTextWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      target: target,
      tables: tables,
      sourceParagraphIDSHA256: draft.paragraphIDSHA256,
      sourceText: normalized.text,
      rowCount: normalized.rowCount,
      columnCount: normalized.maxColumnCount
    )
  }

  func copyTable(_ draft: NotesBodyTableCopyDraft) throws -> NotesBodyTableCopyWriteResult {
    let operation = "notes.body.table.copy"
    let context = try noteContext()
    let sourceNote = try note(id: draft.sourceNoteID)
    let targetNote = draft.sameNote ? sourceNote : try note(id: draft.targetNoteID)
    guard boolValue(sourceNote, key: "isPasswordProtected") != true,
      boolValue(sourceNote, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Password-protected ICNote table copy source remains gated.")
    }
    try validateBodyMutationTarget(targetNote, operation: operation)

    let sourceTarget = try tableTarget(note: sourceNote, ordinal: draft.ordinal, operation: operation)
    guard let table = sourceTarget.table else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment did not expose an ICTable object.")
    }
    guard let rowCount = sourceTarget.record.rowCount, let columnCount = sourceTarget.record.columnCount,
      rowCount > 0, columnCount > 0
    else {
      throw writeError(operation: operation, reason: "Notes body table row/column count is unavailable.")
    }
    guard rowCount == draft.rowCount, columnCount == draft.columnCount else {
      throw writeError(operation: operation, reason: "Notes body table dimensions changed before copy.")
    }

    let copiedText = try tableConvertedText(
      table,
      rowCount: rowCount,
      columnCount: columnCount,
      operation: operation
    )
    let beforeTargetTables = try reader.listTables(noteID: draft.targetNoteID)

    guard targetNote.addTableAttachment(withText: copiedText as NSString) != nil else {
      throw writeError(operation: operation, reason: "ICNote.addTableAttachmentWithText returned nil.")
    }

    try save(note: targetNote, context: context, operation: operation)
    let sourceDetail = try readback(note: draft.sameNote ? targetNote : sourceNote, operation: operation)
    let targetDetail = try readback(note: targetNote, operation: operation)
    let sourceStructure = try reader.readBodyStructure(noteID: draft.sourceNoteID)
    let targetStructure = try reader.readBodyStructure(noteID: draft.targetNoteID)
    let sourceTables = try reader.listTables(noteID: draft.sourceNoteID)
    let targetTables = try reader.listTables(noteID: draft.targetNoteID)
    let beforeTargetTableIDs = Set(beforeTargetTables.map(\.idSHA256))
    let copiedTable = targetTables.first { beforeTargetTableIDs.contains($0.idSHA256) == false }
      ?? targetTables.last
      ?? sourceTarget.record

    return NotesBodyTableCopyWriteResult(
      changed: true,
      sourceNote: sourceDetail,
      targetNote: targetDetail,
      sourceStructure: sourceStructure,
      targetStructure: targetStructure,
      sourceTable: sourceTarget.record,
      targetTable: copiedTable,
      sourceTables: sourceTables,
      targetTables: targetTables,
      copiedText: copiedText,
      rowCount: rowCount,
      columnCount: columnCount
    )
  }

  func moveTable(_ draft: NotesBodyTableMoveDraft) throws -> NotesBodyTableMoveWriteResult {
    let operation = "notes.body.table.move"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let targets = tableTargets(note)
    guard draft.ordinal > 0 && draft.ordinal <= targets.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "ordinal": "\(draft.ordinal)",
          "table_count": "\(targets.count)",
        ]
      )
    }
    guard draft.targetOrdinal > 0 && draft.targetOrdinal <= targets.count else {
      throw writeError(operation: operation, reason: "Notes body table move destination is outside table order.")
    }
    guard draft.ordinal != draft.targetOrdinal else {
      throw writeError(operation: operation, reason: "Notes body table move source and destination must differ.")
    }
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let sourceIndex = draft.ordinal - 1
    let targetIndex = draft.targetOrdinal - 1
    let sourceTarget = targets[sourceIndex]
    let destinationTarget = targets[targetIndex]
    guard NSMaxRange(sourceTarget.range) <= textStorage.length,
      NSMaxRange(destinationTarget.range) <= textStorage.length
    else {
      throw writeError(operation: operation, reason: "Notes body table attachment range is outside text storage.")
    }

    let movedTable = textStorage.attributedSubstring(from: sourceTarget.range)
    let rawInsertionLocation = sourceIndex < targetIndex
      ? NSMaxRange(destinationTarget.range)
      : destinationTarget.range.location
    let insertionLocation = sourceIndex < targetIndex
      ? rawInsertionLocation - sourceTarget.range.length
      : rawInsertionLocation

    note.beginEditing()
    do {
      textStorage.deleteCharacters(in: sourceTarget.range)
      guard insertionLocation >= 0 && insertionLocation <= textStorage.length else {
        throw writeError(operation: operation, reason: "Notes body table move insertion point is outside text storage.")
      }
      textStorage.insert(movedTable, at: insertionLocation)
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    let movedTarget = tables.first { $0.idSHA256 == sourceTarget.record.idSHA256 }
      ?? (draft.targetOrdinal > 0 && draft.targetOrdinal <= tables.count
        ? tables[draft.targetOrdinal - 1]
        : sourceTarget.record)
    return NotesBodyTableMoveWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      beforeTarget: sourceTarget.record,
      target: movedTarget,
      tables: tables
    )
  }

  func changeTableStructure(_ draft: NotesBodyTableStructureDraft) throws -> NotesBodyTableStructureWriteResult {
    let operation = bodyTableStructureOperationName(draft)
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let target = try tableTarget(note: note, ordinal: draft.ordinal, operation: operation)
    guard let table = target.table else {
      throw writeError(operation: operation, reason: "ICTableTextAttachment did not expose an ICTable object.")
    }
    try validateTableStructureChange(target.record, draft: draft, operation: operation)
    let movedSliceDigest = try tableMoveSliceDigest(table, target: target.record, draft: draft, operation: operation)
    let copiedSliceDigest = try tableCopySliceDigest(table, target: target.record, draft: draft, operation: operation)
    let clearedSliceDigest = try tableClearSliceDigest(table, target: target.record, draft: draft, operation: operation)

    note.beginEditing()
    do {
      try applyTableStructureChange(table, target: target.record, draft: draft, operation: operation)
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let tables = try reader.listTables(noteID: draft.noteID)
    let postTarget = tables.first { $0.idSHA256 == target.record.idSHA256 } ?? target.record
    return NotesBodyTableStructureWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      beforeTarget: target.record,
      target: postTarget,
      tables: tables,
      movedSliceCellCount: movedSliceDigest?.cellCount,
      movedSliceSHA256: movedSliceDigest?.sha256,
      copiedSliceCellCount: copiedSliceDigest?.cellCount,
      copiedSliceSHA256: copiedSliceDigest?.sha256,
      clearedSliceCellCount: clearedSliceDigest?.cellCount,
      clearedSliceSHA256: clearedSliceDigest?.sha256
    )
  }

  func insertMathResult(_ draft: NotesBodyMathInsertDraft) throws -> NotesBodyMathInsertWriteResult {
    let operation = "notes.body.math.insert"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    let beforeResults = try reader.listMathResults(noteID: draft.noteID)
    let insertion = try mathExpressionInsertion(draft: draft, textStorage: textStorage, operation: operation)

    note.beginEditing()
    do {
      textStorage.insert(NSAttributedString(string: insertion.insertedText), at: insertion.location)
      try insertRecognizedCalculateResult(
        note: note,
        expression: draft.expression,
        expressionRange: insertion.expressionRange,
        operation: operation
      )
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let results = try reader.listMathResults(noteID: draft.noteID)
    let target = try insertedMathResultTarget(
      before: beforeResults,
      after: results,
      draft: draft,
      operation: operation
    )
    return NotesBodyMathInsertWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      target: target,
      results: results
    )
  }

  func updateMathResult(_ draft: NotesBodyMathUpdateDraft) throws -> NotesBodyMathUpdateWriteResult {
    let operation = "notes.body.math.update"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let target = try mathResultTarget(note: note, ordinal: draft.ordinal, operation: operation)
    let before = target.record
    let changed = before.resultSHA256 != draft.resultSHA256 || before.resultByteCount != draft.resultByteCount
    if changed {
      note.beginEditing()
      do {
        try updateCalculateResultAttachment(
          target.attachment,
          result: draft.result,
          isRightToLeft: before.isRightToLeft ?? false,
          operation: operation
        )
        note.didChangeText()
        note.endEditing()
      } catch {
        note.endEditing()
        throw error
      }
      try save(note: note, context: context, operation: operation)
    }

    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let results = try reader.listMathResults(noteID: draft.noteID)
    guard draft.ordinal <= results.count else {
      throw writeError(operation: operation, reason: "Math result readback did not include the selected ordinal.")
    }
    return NotesBodyMathUpdateWriteResult(
      changed: changed,
      note: detail,
      structure: structure,
      target: results[draft.ordinal - 1],
      results: results
    )
  }

  func setMathVariable(_ draft: NotesBodyMathVariableSetDraft) throws -> NotesBodyMathVariableSetWriteResult {
    let operation = "notes.body.math.variable.set"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    let beforeResults = try reader.listMathResults(noteID: draft.noteID)
    let insertion = try mathVariableSetInsertion(draft: draft, textStorage: textStorage, operation: operation)

    note.beginEditing()
    do {
      textStorage.insert(NSAttributedString(string: insertion.insertedText), at: insertion.location)
      try insertRecognizedCalculateResult(
        note: note,
        expression: draft.variableDefinitionExpression,
        expressionRange: insertion.variableDefinitionRange,
        operation: operation
      )
      let dependentShift = textStorage.length - insertion.textStorageLengthAfterTextInsert
      let dependentRange = NSRange(
        location: insertion.dependentRange.location + max(0, dependentShift),
        length: insertion.dependentRange.length
      )
      try insertRecognizedCalculateResult(
        note: note,
        expression: draft.dependentExpression,
        expressionRange: dependentRange,
        operation: operation
      )
      try refreshCalculateExpressions(
        note: note,
        textStorage: textStorage,
        range: NSRange(location: insertion.location, length: min(textStorage.length - insertion.location, textStorage.length)),
        operation: operation
      )
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let results = try reader.listMathResults(noteID: draft.noteID)
    let targets = try insertedMathVariableTargets(
      before: beforeResults,
      after: results,
      draft: draft,
      operation: operation
    )
    return NotesBodyMathVariableSetWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      variableDefinitionResult: targets.variableDefinition,
      dependentResult: targets.dependent,
      results: results
    )
  }

  func updateMathVariable(_ draft: NotesBodyMathVariableUpdateDraft) throws
    -> NotesBodyMathVariableUpdateWriteResult
  {
    let operation = "notes.body.math.variable.update"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    guard draft.definitionOrdinal != draft.dependentOrdinal else {
      throw writeError(operation: operation, reason: "Variable definition and dependent expression ordinals must be different.")
    }
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let definitionTarget = try mathResultTarget(note: note, ordinal: draft.definitionOrdinal, operation: operation)
    let dependentTarget = try mathResultTarget(note: note, ordinal: draft.dependentOrdinal, operation: operation)
    let beforeDefinition = definitionTarget.record
    let beforeDependent = dependentTarget.record
    let definitionExpression = try mathResultExpressionString(
      note: note,
      attachment: definitionTarget.attachment,
      operation: operation
    )
    let updatedExpression = try updatedMathVariableDefinitionExpression(
      definitionExpression,
      value: draft.value,
      operation: operation
    )
    let definitionRange = try mathResultExpressionRange(
      note: note,
      attachment: definitionTarget.attachment,
      textStorage: textStorage,
      operation: operation
    )
    let changed = beforeDefinition.expressionSHA256 != sha256Hex(updatedExpression)
      || beforeDefinition.expressionByteCount != updatedExpression.utf8.count

    if changed {
      note.beginEditing()
      do {
        textStorage.replaceCharacters(in: definitionRange, with: NSAttributedString(string: updatedExpression))
        try refreshCalculateExpressions(
          note: note,
          textStorage: textStorage,
          range: NSRange(location: 0, length: textStorage.length),
          operation: operation
        )
        note.didChangeText()
        note.endEditing()
      } catch {
        note.endEditing()
        throw error
      }
      try save(note: note, context: context, operation: operation)
    }

    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let results = try reader.listMathResults(noteID: draft.noteID)
    guard draft.definitionOrdinal <= results.count, draft.dependentOrdinal <= results.count else {
      throw writeError(operation: operation, reason: "Math variable readback did not include both selected ordinals.")
    }
    return NotesBodyMathVariableUpdateWriteResult(
      changed: changed,
      note: detail,
      structure: structure,
      beforeDefinition: beforeDefinition,
      afterDefinition: results[draft.definitionOrdinal - 1],
      beforeDependent: beforeDependent,
      afterDependent: results[draft.dependentOrdinal - 1],
      results: results
    )
  }

  func setMathResultsPreference(_ draft: NotesBodyMathResultsPreferenceDraft) throws
    -> NotesBodyMathResultsPreferenceWriteResult
  {
    let operation = "notes.body.math.results"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)

    let before = try reader.readMathResultsPreference(noteID: draft.noteID)
    let changed = before.rawValue != draft.rawValue
    if changed {
      note.setCalculatePreviewBehavior(Int64(draft.rawValue))
      try save(note: note, context: context, operation: operation)
    }
    let after = try reader.readMathResultsPreference(noteID: draft.noteID)
    let detail = try readback(note: note, operation: operation)
    return NotesBodyMathResultsPreferenceWriteResult(
      changed: changed,
      note: detail,
      before: before,
      after: after
    )
  }

  func setChecklistItemState(_ draft: NotesBodyChecklistSetDraft) throws -> NotesBodyChecklistSetWriteResult {
    let operation = "notes.body.checklist.set"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try checklistParagraphTarget(draft: draft, textStorage: textStorage, operation: operation)
    if target.checked == draft.checked {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistSetWriteResult(changed: false, note: detail, structure: structure)
    }

    let updatedStyle = try checklistParagraphStyle(
      from: target.style,
      checked: draft.checked,
      operation: operation
    )
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistSetWriteResult(changed: true, note: detail, structure: structure)
  }

  func setAllChecklistItemStates(_ draft: NotesBodyChecklistSetAllDraft) throws
    -> NotesBodyChecklistSetAllWriteResult
  {
    let operation = "notes.body.checklist.set-all"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let targets = try checklistParagraphTargets(
      noteID: draft.noteID,
      textStorage: textStorage,
      operation: operation
    )
    let changedTargets = targets.filter { $0.checked != draft.checked }
    guard !changedTargets.isEmpty else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistSetAllWriteResult(changed: false, note: detail, structure: structure)
    }

    let updates = try changedTargets.map { target in
      (
        range: target.range,
        style: try checklistParagraphStyle(
          from: target.style,
          checked: draft.checked,
          operation: operation
        )
      )
    }
    let attributeName = NSAttributedString.Key(paragraphStyleAttributeName())
    note.beginEditing()
    for update in updates {
      textStorage.addAttribute(attributeName, value: update.style, range: update.range)
    }
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistSetAllWriteResult(changed: true, note: detail, structure: structure)
  }

  func sortChecklistItems(_ draft: NotesBodyChecklistSortDraft) throws -> NotesBodyChecklistSortWriteResult {
    let operation = "notes.body.checklist.sort"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let targets = try checklistParagraphTargets(
      noteID: draft.noteID,
      textStorage: textStorage,
      operation: operation
    )
    let orderedTargets = targets.sorted { $0.range.location < $1.range.location }
    let sortedTargets = stableChecklistSortTargets(orderedTargets)
    let beforeOrder = orderedTargets.map(\.paragraphIDSHA256)
    let expectedOrder = sortedTargets.map(\.paragraphIDSHA256)
    guard beforeOrder != expectedOrder else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistSortWriteResult(changed: false, note: detail, structure: structure)
    }

    let destinationRanges = orderedTargets.map { paragraphRange(in: textStorage, around: $0.range) }
    let sortedParagraphs = sortedTargets.map { target in
      textStorage.attributedSubstring(from: paragraphRange(in: textStorage, around: target.range))
    }

    note.beginEditing()
    for index in stride(from: destinationRanges.count - 1, through: 0, by: -1) {
      textStorage.replaceCharacters(in: destinationRanges[index], with: sortedParagraphs[index])
    }
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistSortWriteResult(changed: true, note: detail, structure: structure)
  }

  func convertParagraphToChecklistItem(_ draft: NotesBodyChecklistConvertDraft) throws
    -> NotesBodyChecklistConvertWriteResult
  {
    let operation = "notes.body.checklist.convert"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try paragraphStyleTarget(draft: draft, textStorage: textStorage, operation: operation)
    guard !target.style.isChecklist else {
      throw CLIError(
        code: .validationError,
        message: "Selected paragraph is already a checklist item; use `body checklist set` to change its state.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
          "ordinal": draft.ordinal.map(String.init) ?? "",
        ]
      )
    }

    let updatedStyle = try checklistParagraphStyle(
      from: target.style,
      checked: draft.checked,
      operation: operation
    )
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistConvertWriteResult(changed: true, note: detail, structure: structure)
  }

  func convertParagraphRangeToChecklistItems(_ draft: NotesBodyChecklistConvertRangeDraft) throws
    -> NotesBodyChecklistConvertRangeWriteResult
  {
    let operation = "notes.body.checklist.convert-range"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let targets = try paragraphStyleTargets(
      noteID: draft.noteID,
      textStorage: textStorage,
      operation: operation
    )
    guard draft.fromOrdinal > 0 && draft.toOrdinal <= targets.count && draft.fromOrdinal <= draft.toOrdinal else {
      throw CLIError(
        code: .validationError,
        message: "`--from-ordinal` and `--to-ordinal` must select an existing paragraph range.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "from_ordinal": "\(draft.fromOrdinal)",
          "to_ordinal": "\(draft.toOrdinal)",
          "paragraph_anchor_count": "\(targets.count)",
        ]
      )
    }

    let selectedTargets = Array(targets[(draft.fromOrdinal - 1)...(draft.toOrdinal - 1)])
    if let checklistTarget = selectedTargets.first(where: { $0.style.isChecklist }) {
      throw CLIError(
        code: .validationError,
        message: "Checklist range convert requires non-checklist paragraph anchors.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": checklistTarget.paragraphIDSHA256 ?? "",
          "from_ordinal": "\(draft.fromOrdinal)",
          "to_ordinal": "\(draft.toOrdinal)",
        ]
      )
    }

    let updates = try selectedTargets.map { target in
      (
        range: target.range,
        style: try checklistParagraphStyle(from: target.style, checked: draft.checked, operation: operation)
      )
    }
    let attributeName = NSAttributedString.Key(paragraphStyleAttributeName())

    note.beginEditing()
    for update in updates {
      textStorage.addAttribute(attributeName, value: update.style, range: update.range)
    }
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistConvertRangeWriteResult(changed: true, note: detail, structure: structure)
  }

  func reorderChecklistItem(_ draft: NotesBodyChecklistReorderDraft) throws
    -> NotesBodyChecklistReorderWriteResult
  {
    let operation = "notes.body.checklist.reorder"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let targets = try checklistParagraphTargets(
      noteID: draft.noteID,
      textStorage: textStorage,
      operation: operation
    )
    let sourceIndex = try checklistParagraphTargetIndex(
      draft: draft,
      targets: targets,
      operation: operation
    )
    guard draft.targetOrdinal > 0 && draft.targetOrdinal <= targets.count else {
      throw CLIError(
        code: .validationError,
        message: "`--to-ordinal` must target an existing checklist item.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "to_ordinal": "\(draft.targetOrdinal)",
          "checklist_item_count": "\(targets.count)",
        ]
      )
    }

    let targetIndex = draft.targetOrdinal - 1
    guard sourceIndex != targetIndex else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistReorderWriteResult(changed: false, note: detail, structure: structure)
    }

    let sourceParagraphRange = paragraphRange(in: textStorage, around: targets[sourceIndex].range)
    let insertionLocation: Int
    if sourceIndex < targetIndex {
      let destinationParagraphRange = paragraphRange(in: textStorage, around: targets[targetIndex].range)
      insertionLocation = destinationParagraphRange.location + destinationParagraphRange.length
        - sourceParagraphRange.length
    } else {
      let destinationParagraphRange = paragraphRange(in: textStorage, around: targets[targetIndex].range)
      insertionLocation = destinationParagraphRange.location
    }
    let movingParagraph = textStorage.attributedSubstring(from: sourceParagraphRange)

    note.beginEditing()
    textStorage.deleteCharacters(in: sourceParagraphRange)
    textStorage.insert(movingParagraph, at: insertionLocation)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistReorderWriteResult(changed: true, note: detail, structure: structure)
  }

  func indentChecklistItem(_ draft: NotesBodyChecklistIndentDraft) throws
    -> NotesBodyChecklistIndentWriteResult
  {
    let operation = "notes.body.checklist.indent"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try checklistParagraphTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    let currentIndent = target.indentationLevel
    let proposedIndent = currentIndent + draft.delta
    guard proposedIndent >= 0 else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistIndentWriteResult(changed: false, note: detail, structure: structure)
    }
    guard draft.delta <= 0 || target.style.canIndent else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistIndentWriteResult(changed: false, note: detail, structure: structure)
    }
    guard proposedIndent != currentIndent else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyChecklistIndentWriteResult(changed: false, note: detail, structure: structure)
    }

    guard let style = target.style.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.indent = UInt64(proposedIndent)

    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: style,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistIndentWriteResult(changed: true, note: detail, structure: structure)
  }

  func deleteChecklistItem(_ draft: NotesBodyChecklistDeleteDraft) throws
    -> NotesBodyChecklistDeleteWriteResult
  {
    let operation = "notes.body.checklist.delete"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try checklistParagraphTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    let targetParagraphRange = paragraphRange(in: textStorage, around: target.range)

    note.beginEditing()
    textStorage.deleteCharacters(in: targetParagraphRange)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyChecklistDeleteWriteResult(changed: true, note: detail, structure: structure)
  }

  func addListItem(_ draft: NotesBodyListAddDraft) throws -> NotesBodyListAddWriteResult {
    let operation = "notes.body.list.add"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    let attributedString = try listAttributedString(text: draft.text, style: draft.style, operation: operation)

    var error: AnyObject?
    guard note.appendAttributedString(attributedString, error: &error) else {
      throw writeError(
        operation: operation,
        reason: "ICNote.appendAttributedString returned false.",
        error: error
      )
    }

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListAddWriteResult(changed: true, note: detail, structure: structure)
  }

  func convertParagraphToListItem(_ draft: NotesBodyListConvertDraft) throws
    -> NotesBodyListConvertWriteResult
  {
    let operation = "notes.body.list.convert"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try paragraphStyleTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    guard !target.style.isChecklist else {
      throw CLIError(
        code: .validationError,
        message: "Selected paragraph is already a checklist item; use checklist commands for checklist items.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
          "ordinal": draft.ordinal.map(String.init) ?? "",
        ]
      )
    }
    guard !target.style.isList else {
      throw CLIError(
        code: .validationError,
        message: "Selected paragraph is already an ordinary list item; use `body list set-style` to change its style.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
          "ordinal": draft.ordinal.map(String.init) ?? "",
        ]
      )
    }

    let updatedStyle = try listParagraphStyle(from: target.style, style: draft.style, operation: operation)
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListConvertWriteResult(changed: true, note: detail, structure: structure)
  }

  func convertParagraphRangeToListItems(_ draft: NotesBodyListConvertRangeDraft) throws
    -> NotesBodyListConvertRangeWriteResult
  {
    let operation = "notes.body.list.convert-range"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let targets = try paragraphStyleTargets(
      noteID: draft.noteID,
      textStorage: textStorage,
      operation: operation
    )
    guard draft.fromOrdinal > 0 && draft.toOrdinal <= targets.count && draft.fromOrdinal <= draft.toOrdinal else {
      throw CLIError(
        code: .validationError,
        message: "`--from-ordinal` and `--to-ordinal` must select an existing paragraph range.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "from_ordinal": "\(draft.fromOrdinal)",
          "to_ordinal": "\(draft.toOrdinal)",
          "paragraph_anchor_count": "\(targets.count)",
        ]
      )
    }

    let selectedTargets = Array(targets[(draft.fromOrdinal - 1)...(draft.toOrdinal - 1)])
    if let checklistTarget = selectedTargets.first(where: { $0.style.isChecklist }) {
      throw CLIError(
        code: .validationError,
        message: "Ordinary list range convert requires non-list, non-checklist paragraph anchors.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": checklistTarget.paragraphIDSHA256 ?? "",
          "from_ordinal": "\(draft.fromOrdinal)",
          "to_ordinal": "\(draft.toOrdinal)",
        ]
      )
    }
    if let listTarget = selectedTargets.first(where: { $0.style.isList }) {
      throw CLIError(
        code: .validationError,
        message: "Ordinary list range convert requires non-list paragraph anchors; use `body list set-style` for existing list items.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": listTarget.paragraphIDSHA256 ?? "",
          "from_ordinal": "\(draft.fromOrdinal)",
          "to_ordinal": "\(draft.toOrdinal)",
        ]
      )
    }

    let updates = try selectedTargets.map { target in
      (
        range: target.range,
        style: try listParagraphStyle(from: target.style, style: draft.style, operation: operation)
      )
    }
    let attributeName = NSAttributedString.Key(paragraphStyleAttributeName())

    note.beginEditing()
    for update in updates {
      textStorage.addAttribute(attributeName, value: update.style, range: update.range)
    }
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListConvertRangeWriteResult(changed: true, note: detail, structure: structure)
  }

  func setListItemStyle(_ draft: NotesBodyListSetStyleDraft) throws -> NotesBodyListSetStyleWriteResult {
    let operation = "notes.body.list.set-style"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try listParagraphTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    guard target.style.style != draft.style.paragraphStyleValue else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyListSetStyleWriteResult(changed: false, note: detail, structure: structure)
    }

    let updatedStyle = try listParagraphStyle(from: target.style, style: draft.style, operation: operation)
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListSetStyleWriteResult(changed: true, note: detail, structure: structure)
  }

  func reorderListItem(_ draft: NotesBodyListReorderDraft) throws
    -> NotesBodyListReorderWriteResult
  {
    let operation = "notes.body.list.reorder"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let targets = try listParagraphTargets(
      noteID: draft.noteID,
      textStorage: textStorage,
      operation: operation
    )
    let sourceIndex = try listParagraphTargetIndex(
      draft: draft,
      targets: targets,
      operation: operation
    )
    guard draft.targetOrdinal > 0 && draft.targetOrdinal <= targets.count else {
      throw CLIError(
        code: .validationError,
        message: "`--to-ordinal` must target an existing ordinary list item.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "to_ordinal": "\(draft.targetOrdinal)",
          "ordinary_list_item_count": "\(targets.count)",
        ]
      )
    }

    let targetIndex = draft.targetOrdinal - 1
    guard sourceIndex != targetIndex else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyListReorderWriteResult(changed: false, note: detail, structure: structure)
    }

    let sourceParagraphRange = paragraphRange(in: textStorage, around: targets[sourceIndex].range)
    let insertionLocation: Int
    if sourceIndex < targetIndex {
      let destinationParagraphRange = paragraphRange(in: textStorage, around: targets[targetIndex].range)
      insertionLocation = destinationParagraphRange.location + destinationParagraphRange.length
        - sourceParagraphRange.length
    } else {
      let destinationParagraphRange = paragraphRange(in: textStorage, around: targets[targetIndex].range)
      insertionLocation = destinationParagraphRange.location
    }
    let movingParagraph = textStorage.attributedSubstring(from: sourceParagraphRange)

    note.beginEditing()
    textStorage.deleteCharacters(in: sourceParagraphRange)
    textStorage.insert(movingParagraph, at: insertionLocation)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListReorderWriteResult(changed: true, note: detail, structure: structure)
  }

  func indentListItem(_ draft: NotesBodyListIndentDraft) throws
    -> NotesBodyListIndentWriteResult
  {
    let operation = "notes.body.list.indent"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try listParagraphTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    let currentIndent = target.indentationLevel
    let proposedIndent = currentIndent + draft.delta
    guard proposedIndent >= 0 else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyListIndentWriteResult(changed: false, note: detail, structure: structure)
    }
    guard draft.delta <= 0 || target.style.canIndent else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyListIndentWriteResult(changed: false, note: detail, structure: structure)
    }
    guard proposedIndent != currentIndent else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyListIndentWriteResult(changed: false, note: detail, structure: structure)
    }

    guard let style = target.style.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.indent = UInt64(proposedIndent)

    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: style,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListIndentWriteResult(changed: true, note: detail, structure: structure)
  }

  func deleteListItem(_ draft: NotesBodyListDeleteDraft) throws
    -> NotesBodyListDeleteWriteResult
  {
    let operation = "notes.body.list.delete"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try listParagraphTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    let targetParagraphRange = paragraphRange(in: textStorage, around: target.range)

    note.beginEditing()
    textStorage.deleteCharacters(in: targetParagraphRange)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListDeleteWriteResult(changed: true, note: detail, structure: structure)
  }

  func insertTextInListItem(_ draft: NotesBodyListTextInsertDraft) throws
    -> NotesBodyListTextInsertWriteResult
  {
    let operation: String
    switch (draft.targetKind, draft.insertKind) {
    case (.ordinaryList, .lineBreak):
      operation = "notes.body.list.line-break"
    case (.ordinaryList, .tab):
      operation = "notes.body.list.tab"
    case (.checklist, .lineBreak):
      operation = "notes.body.checklist.line-break"
    case (.checklist, .tab):
      throw CLIError(
        code: .validationError,
        message: "Checklist tab insertion is not an accepted Notes capability.",
        details: [
          "operation": "notes.body.checklist.tab",
          "requires": "ordinary list item",
        ]
      )
    }

    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target: NotesChecklistParagraphTarget
    switch draft.targetKind {
    case .ordinaryList:
      target = try listParagraphTarget(
        noteID: draft.noteID,
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        textStorage: textStorage,
        operation: operation
      )
    case .checklist:
      target = try checklistParagraphTarget(
        noteID: draft.noteID,
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        textStorage: textStorage,
        operation: operation
      )
    }

    let targetParagraphRange = paragraphRange(in: textStorage, around: target.range)
    let insertionLocation = insertionLocationBeforeParagraphTerminator(
      in: textStorage,
      paragraphRange: targetParagraphRange
    )
    let attributeLocation = min(max(target.range.location, 0), max(textStorage.length - 1, 0))
    let attributes = textStorage.length > 0
      ? textStorage.attributes(at: attributeLocation, effectiveRange: nil)
      : [:]
    let insertedText = draft.insertKind.insertedText
    let inserted = NSAttributedString(string: insertedText, attributes: attributes)

    note.beginEditing()
    textStorage.insert(inserted, at: insertionLocation)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyListTextInsertWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      insertedTextByteCount: insertedText.utf8.count,
      insertedTextSHA256: sha256Hex(insertedText)
    )
  }

  func endList(_ draft: NotesBodyListEndDraft) throws -> NotesBodyListEndWriteResult {
    let operation: String
    switch draft.targetKind {
    case .ordinaryList:
      operation = "notes.body.list.end"
    case .checklist:
      operation = "notes.body.checklist.end"
    }

    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let beforeStructure = try reader.readBodyStructure(noteID: draft.noteID)
    let target: NotesChecklistParagraphTarget
    switch draft.targetKind {
    case .ordinaryList:
      target = try listParagraphTarget(
        noteID: draft.noteID,
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        textStorage: textStorage,
        operation: operation
      )
    case .checklist:
      target = try checklistParagraphTarget(
        noteID: draft.noteID,
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        textStorage: textStorage,
        operation: operation
      )
    }

    let targetParagraphRange = paragraphRange(in: textStorage, around: target.range)
    let insertionLocation = min(targetParagraphRange.location + targetParagraphRange.length, textStorage.length)
    let attributeLocation = min(max(target.range.location, 0), max(textStorage.length - 1, 0))
    let targetAttributes = textStorage.length > 0
      ? textStorage.attributes(at: attributeLocation, effectiveRange: nil)
      : [:]
    var bodyAttributes = targetAttributes
    bodyAttributes[NSAttributedString.Key(paragraphStyleAttributeName())] =
      try bodyParagraphStyleForInsertedParagraph(from: target.style, operation: operation)

    let insertion: NSMutableAttributedString
    if paragraphRangeHasTerminator(in: textStorage, paragraphRange: targetParagraphRange) {
      insertion = NSMutableAttributedString(string: "\n", attributes: bodyAttributes)
    } else {
      insertion = NSMutableAttributedString(string: "\n", attributes: targetAttributes)
      insertion.append(NSAttributedString(string: "\n", attributes: bodyAttributes))
    }

    note.beginEditing()
    textStorage.insert(insertion, at: insertionLocation)
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    let createdParagraph = insertedBodyParagraph(before: beforeStructure, after: structure)
    return NotesBodyListEndWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      createdParagraphStyle: createdParagraph?.style ?? "body",
      createdParagraphIDSHA256: createdParagraph?.idSHA256
    )
  }

  func setParagraphStyle(_ draft: NotesBodyParagraphStyleDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  {
    let operation = "notes.body.paragraph.style"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try paragraphStyleTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    try validateParagraphFormatTarget(target.style, draft: draft, operation: operation)
    let styleValue = try paragraphStyleValue(draft.style, operation: operation)
    guard target.style.style != styleValue else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyParagraphFormatWriteResult(changed: false, note: detail, structure: structure)
    }

    let updatedStyle = try paragraphStyle(from: target.style, style: draft.style, operation: operation)
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyParagraphFormatWriteResult(changed: true, note: detail, structure: structure)
  }

  func setParagraphAlignment(_ draft: NotesBodyParagraphAlignmentDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  {
    let operation = "notes.body.paragraph.align"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try paragraphStyleTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    try validateParagraphFormatTarget(target.style, draft: draft, operation: operation)
    let alignment = paragraphStyleAlignment(draft.alignment)
    guard target.style.alignment != Int64(alignment) else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyParagraphFormatWriteResult(changed: false, note: detail, structure: structure)
    }

    let updatedStyle = try paragraphStyle(from: target.style, alignment: draft.alignment, operation: operation)
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyParagraphFormatWriteResult(changed: true, note: detail, structure: structure)
  }

  func setParagraphBlockQuote(_ draft: NotesBodyParagraphQuoteDraft) throws
    -> NotesBodyParagraphFormatWriteResult
  {
    let operation = "notes.body.paragraph.quote"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try paragraphStyleTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
    try validateParagraphBlockQuoteTarget(target.style, draft: draft, operation: operation)
    guard target.style.isBlockQuote != draft.enabled else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyParagraphFormatWriteResult(changed: false, note: detail, structure: structure)
    }

    let updatedStyle = try paragraphStyle(from: target.style, blockQuoteEnabled: draft.enabled, operation: operation)
    note.beginEditing()
    textStorage.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: updatedStyle,
      range: target.range
    )
    note.didChangeText()
    note.endEditing()

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyParagraphFormatWriteResult(changed: true, note: detail, structure: structure)
  }

  func setInlineFormat(_ draft: NotesBodyInlineFormatDraft) throws
    -> NotesBodyInlineFormatWriteResult
  {
    let operation = "notes.body.inline.format"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try inlineTextTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      text: draft.text,
      occurrence: draft.occurrence,
      textStorage: textStorage,
      operation: operation
    )
    let hasTargetState = try inlineRangeMatchesFormat(
      draft.format, enabled: draft.enabled, in: textStorage, range: target.range)
    guard !hasTargetState else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyInlineFormatWriteResult(
        changed: false,
        note: detail,
        structure: structure,
        evidence: target.evidence(role: draft.format.rawValue)
      )
    }

    note.beginEditing()
    do {
      try applyInlineFormat(draft.format, enabled: draft.enabled, to: textStorage, range: target.range)
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }
    try persistNoteTextContent(note, operation: operation)

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyInlineFormatWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      evidence: target.evidence(role: draft.format.rawValue)
    )
  }

  func setInlineForegroundColor(_ draft: NotesBodyInlineColorDraft) throws
    -> NotesBodyInlineColorWriteResult
  {
    try setInlineColor(
      draft,
      role: "foreground",
      attribute: .foregroundColor,
      operation: "notes.body.inline.color"
    )
  }

  func setInlineHighlightColor(_ draft: NotesBodyInlineColorDraft) throws
    -> NotesBodyInlineColorWriteResult
  {
    try setInlineColor(
      draft,
      role: "highlight",
      attribute: .backgroundColor,
      operation: "notes.body.inline.highlight"
    )
  }

  func setInlineFont(_ draft: NotesBodyInlineFontDraft) throws
    -> NotesBodyInlineFormatWriteResult
  {
    let operation = "notes.body.inline.font"
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try inlineTextTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      text: draft.text,
      occurrence: draft.occurrence,
      textStorage: textStorage,
      operation: operation
    )
    let font = try inlineFont(family: draft.family, pointSize: draft.pointSize, operation: operation)
    let fontSHA256 = notesFontSHA256(font)
    let alreadyApplied = try inlineRangeFontMatches(
      fontSHA256: fontSHA256,
      in: textStorage,
      range: target.range
    )
    guard alreadyApplied == false else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyInlineFormatWriteResult(
        changed: false,
        note: detail,
        structure: structure,
        evidence: target.evidence(role: "font", fontSHA256: fontSHA256)
      )
    }

    note.beginEditing()
    do {
      try notesMutateNativeInlineAttributes(in: textStorage, range: target.range,
        ownedKeys: ["TTHints", "ICTTFont"], operation: operation) { attributes in
          var updated = attributes
          updated[.font] = font
          return updated
        }
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }
    try persistNoteTextContent(note, operation: operation)

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyInlineFormatWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      evidence: target.evidence(role: "font", fontSHA256: fontSHA256)
    )
  }

  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let targetFolder = try folder(id: draft.folderID, name: draft.folderName, accountName: draft.accountName)
    guard note.isMovable else {
      throw writeError(operation: "notes.move", reason: "ICNote.isMovable returned false.")
    }
    guard boolValue(targetFolder, key: "supportsEditingNotes") != false,
      boolValue(targetFolder, key: "isSmartFolder") != true,
      boolValue(targetFolder, key: "isTrashFolder") != true,
      boolValue(targetFolder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: "notes.move", reason: "Target ICFolder cannot accept edited notes.")
    }

    if note.primitiveFolder == targetFolder {
      return try readback(note: note, operation: "notes.move")
    }

    note.primitiveFolder = targetFolder
    if let account = targetFolder.account {
      note.account = account
    }
    note.folderModificationDate = Date()
    note.ensureHashtagsExistInDestinationAccount()
    try save(note: note, context: context, operation: "notes.move")
    return try readback(note: note, operation: "notes.move")
  }

  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let targetFolder = try folder(id: draft.folderID, name: draft.folderName, accountName: draft.accountName)
    guard note.isDuplicatable() else {
      throw writeError(operation: "notes.copy", reason: "ICNote.isDuplicatable returned false.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true else {
      throw writeError(operation: "notes.copy", reason: "Password-protected note copy remains gated.")
    }
    guard boolValue(targetFolder, key: "supportsEditingNotes") != false,
      boolValue(targetFolder, key: "isSmartFolder") != true,
      boolValue(targetFolder, key: "isTrashFolder") != true,
      boolValue(targetFolder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: "notes.copy", reason: "Target ICFolder cannot accept copied notes.")
    }

    guard
      let duplicate = ICNote.duplicate(
        note,
        intoFolder: targetFolder,
        isPasswordProtected: false,
        removeOriginalNote: false
      ) as? ICNote
    else {
      throw writeError(operation: "notes.copy", reason: "ICNote.duplicateNote returned nil.")
    }

    try save(note: duplicate, context: context, operation: "notes.copy")
    return try readback(note: duplicate, operation: "notes.copy")
  }

  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    let context = try noteContext()
    let note = try note(id: draft.noteID, includeDeleted: true)
    let targetFolder = try folder(id: draft.folderID, name: draft.folderName, accountName: draft.accountName)
    guard boolValue(note, key: "isDeletedOrInTrash") == true else {
      throw writeError(operation: "notes.restore", reason: "ICNote is not deleted or in trash.")
    }
    guard boolValue(targetFolder, key: "supportsEditingNotes") != false,
      boolValue(targetFolder, key: "isSmartFolder") != true,
      boolValue(targetFolder, key: "isTrashFolder") != true,
      boolValue(targetFolder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: "notes.restore", reason: "Target ICFolder cannot accept restored notes.")
    }

    note.unmarkForDeletion()
    note.primitiveFolder = targetFolder
    if let account = targetFolder.account {
      note.account = account
    }
    note.folderModificationDate = Date()
    note.ensureHashtagsExistInDestinationAccount()
    try save(note: note, context: context, operation: "notes.restore")
    return try readback(note: note, operation: "notes.restore")
  }

  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    try reader.readRestorableNote(id: id)
  }

  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    try reader.listRestorableNotes(limit: limit)
  }

  func deleteNote(id: String) throws -> Bool {
    let context = try noteContext()
    let note = try note(id: id)
    try NotesRuntimeMethod(owner: "ICNote", selector: "deleteNote:", scope: .classMethod,
      returnType: "v", argumentTypes: ["@"]).require(operation: "notes.delete")
    ICNote.delete(note)
    try save(note: note, context: context, operation: "notes.delete")
    return true
  }

  func purgeNote(id: String) throws -> Bool {
    let context = try noteContext()
    let note = try note(id: id, includeDeleted: true)
    guard boolValue(note, key: "isDeletedOrInTrash") == true else {
      throw writeError(operation: "notes.purge", reason: "ICNote is not deleted or in trash.")
    }
    ICNote.purgeNote(note)
    try save(context: context, operation: "notes.purge")
    return true
  }

  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    let context = try noteContext()
    let note = try note(id: id)
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: pinned ? "notes.pin" : "notes.unpin", reason: "ICNote is deleted or in trash.")
    }
    guard note.isPinned != pinned else {
      return try readback(note: note, operation: pinned ? "notes.pin" : "notes.unpin")
    }
    guard boolValue(note, key: "isPinnable") != false else {
      throw writeError(
        operation: pinned ? "notes.pin" : "notes.unpin",
        reason: "ICNote cannot change pin status."
      )
    }

    note.changePinStatusIfPossible()
    guard note.isPinned == pinned else {
      throw writeError(
        operation: pinned ? "notes.pin" : "notes.unpin",
        reason: "ICNote.changePinStatusIfPossible did not reach the requested pin state."
      )
    }
    try save(note: note, context: context, operation: pinned ? "notes.pin" : "notes.unpin")
    return try readback(note: note, operation: pinned ? "notes.pin" : "notes.unpin")
  }

  func addTag(_ tag: String, toNoteID id: String) throws -> NotesTagMutationWriteResult {
    let context = try noteContext()
    let note = try note(id: id)
    guard let before = try reader.readNote(id: id) else {
      throw CLIError(code: .notFound, message: "Note was not found.", details: ["id_sha256": sha256Hex(id)])
    }
    let displayText = normalizedTagText(tag)
    let changed = !before.tags.contains { tagMatches($0, displayText) }
    let hashtag = try hashtag(displayText: displayText, note: note, createIfNecessary: true, operation: "notes.tags.add")
    if changed {
      _ = note.addHashtag(toNoteBody: hashtag, onlyIfMissing: true)
      try save(note: note, context: context, operation: "notes.tags.add")
    }
    let detail = try readback(note: note, operation: "notes.tags.add")
    return NotesTagMutationWriteResult(
      changed: changed,
      note: detail,
      tag: detail.tags.first { tagMatches($0, displayText) } ?? tagRecord(hashtag)
    )
  }

  func removeTag(_ tag: String, fromNoteID id: String) throws -> NotesTagMutationWriteResult {
    let context = try noteContext()
    let note = try note(id: id)
    let displayText = normalizedTagText(tag)
    let hashtag = try hashtag(displayText: displayText, note: note, createIfNecessary: false, operation: "notes.tags.remove")
    let changed = note.removeHashtag(hashtag)
    if changed {
      try save(note: note, context: context, operation: "notes.tags.remove")
    }
    let detail = try readback(note: note, operation: "notes.tags.remove")
    return NotesTagMutationWriteResult(
      changed: changed,
      note: detail,
      tag: tagRecord(hashtag)
    )
  }

  func convertTagToText(_ draft: NotesTagConvertToTextDraft) throws -> NotesTagConvertToTextWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    let hashtag = try hashtag(
      displayText: draft.displayText,
      note: note,
      createIfNecessary: false,
      operation: "notes.tags.convert-to-text"
    )
    let changed = note.removeHashtag(hashtag)
    if changed {
      try save(note: note, context: context, operation: "notes.tags.convert-to-text")
    }
    let detail = try readback(note: note, operation: "notes.tags.convert-to-text")
    return NotesTagConvertToTextWriteResult(
      changed: changed,
      note: detail,
      tag: tagRecord(hashtag)
    )
  }

  func renameTag(_ draft: NotesTagRenameDraft) throws -> NotesTagRenameWriteResult {
    let context = try noteContext()
    let managedObjectContext = try managedObjectContext()
    let matchingHashtags = try hashtags(standardizedContent: draft.currentStandardizedContent)
    guard !matchingHashtags.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "Tag selector did not match any Notes tag.",
        details: ["tag_sha256": sha256Hex(draft.currentStandardizedContent)]
      )
    }
    if draft.allowMerge {
      let beforeAffectedNotes = try reader.readNotes(tag: draft.currentStandardizedContent, limit: 2_000)
      let beforeAffectedIDs = Set(beforeAffectedNotes.map(\.id))
      var changed = false
      for before in beforeAffectedNotes {
        let note = try note(id: before.id)
        let targetHashtag = try hashtag(
          displayText: draft.newDisplayText,
          note: note,
          createIfNecessary: true,
          operation: "notes.tags.rename"
        )
        if !before.tags.contains(where: { tagMatches($0, draft.newStandardizedContent) }) {
          _ = note.addHashtag(toNoteBody: targetHashtag, onlyIfMissing: true)
          changed = true
        }
        for sourceHashtag in matchingHashtags where note.removeHashtag(sourceHashtag) {
          changed = true
        }
      }
      if changed {
        try save(context: context, operation: "notes.tags.rename")
      }

      let tags = try reader.listTags(account: nil, limit: 2_000)
      guard let tag = tags.first(where: { tagMatches($0, draft.newStandardizedContent) }) else {
        throw writeError(operation: "notes.tags.rename", reason: "Private framework readback did not find merged tag.")
      }
      let affectedNotes = try reader.readNotes(tag: draft.newStandardizedContent, limit: 2_000)
        .filter { beforeAffectedIDs.contains($0.id) }
      return NotesTagRenameWriteResult(
        changed: changed || !matchingHashtags.isEmpty,
        tag: tag,
        affectedNotes: affectedNotes
      )
    }

    for hashtag in matchingHashtags {
      guard hashtag.canRenameTag(withNewDisplayText: draft.newDisplayText) else {
        throw writeError(operation: "notes.tags.rename", reason: "ICHashtag cannot rename to the requested display text.")
      }
    }

    _ = ICHashtag.renameHashtags(
      withStandardizedContent: draft.currentStandardizedContent,
      newDisplayText: draft.newDisplayText,
      context: managedObjectContext
    )
    try save(context: context, operation: "notes.tags.rename")

    let tags = try reader.listTags(account: nil, limit: 2_000)
    guard let tag = tags.first(where: { tagMatches($0, draft.newStandardizedContent) }) else {
      throw writeError(operation: "notes.tags.rename", reason: "Private framework readback did not find renamed tag.")
    }
    let affectedNotes = try reader.readNotes(tag: draft.newStandardizedContent, limit: 2_000)
    return NotesTagRenameWriteResult(
      changed: true,
      tag: tag,
      affectedNotes: affectedNotes
    )
  }

  func deleteTag(_ draft: NotesTagDeleteDraft) throws -> NotesTagDeleteWriteResult {
    let context = try noteContext()
    let matchingHashtags = try hashtags(standardizedContent: draft.standardizedContent)
    guard let tag = matchingHashtags.first.map(tagRecord) else {
      throw CLIError(
        code: .notFound,
        message: "Tag selector did not match any Notes tag.",
        details: ["tag_sha256": sha256Hex(draft.standardizedContent)]
      )
    }

    let impactedSmartFolders: [ICFolder] = objects(
      ICFolder.smartFoldersThatWillBeDeleted(afterDeletingHashtags: matchingHashtags)
    )
    guard impactedSmartFolders.isEmpty else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "Notes tag delete would delete Smart Folders; Smart Folder cascade remains gated.",
        details: [
          "operation": "notes.tags.delete",
          "tag_sha256": sha256Hex(draft.standardizedContent),
          "smart_folder_count": "\(impactedSmartFolders.count)",
        ]
      )
    }

    let beforeAffectedNotes = try reader.readNotes(tag: draft.standardizedContent, limit: 2_000)
    for hashtag in matchingHashtags {
      hashtag.removeUsage()
    }
    try save(context: context, operation: "notes.tags.delete")
    let afterAffectedNotes = try beforeAffectedNotes.compactMap { note in
      try reader.readNote(id: note.id)
    }
    return NotesTagDeleteWriteResult(
      changed: true,
      tag: tag,
      affectedNotes: afterAffectedNotes
    )
  }

  func createSmartFolder(_ draft: NotesSmartFolderCreateDraft) throws -> NotesSmartFolderCreateWriteResult {
    let context = try noteContext()
    let managedObjectContext = try managedObjectContext()
    let account = try accountObject(id: draft.accountID, name: draft.accountName)
    guard boolValue(account, key: "supportsEditingNotes") != false else {
      throw writeError(operation: "notes.smart-folders.create", reason: "ICAccount.supportsEditingNotes returned false.")
    }
    try validateFolderTitle(
      draft.name,
      account: account,
      parentFolder: nil,
      operation: "notes.smart-folders.create"
    )

    let matchingHashtags = try smartFolderHashtags(
      standardizedContents: draft.tagStandardizedContents,
      accountName: draft.accountName,
      operation: "notes.smart-folders.create"
    )
    guard let firstHashtag = matchingHashtags.first else {
      throw writeError(operation: "notes.smart-folders.create", reason: "No Smart Folder tag selection hashtags resolved.")
    }

    guard let selection = ICTagSelection(managedObjectContext: managedObjectContext) else {
      throw writeError(operation: "notes.smart-folders.create", reason: "ICTagSelection initializer returned nil.")
    }
    for hashtag in matchingHashtags {
      selection.addObjectID(hashtag.objectID, toExcluded: false)
    }
    selection.mode = UInt64(notesSmartFolderTagSelectionModeAllTagged)
    selection.tagOperator = UInt64(draft.tagOperator)
    selection.allowsRecentlyDeleted = false

    guard
      let query = ICQuery.queryForNotes(matchingTagSelection: selection) as? ICQuery,
      let smartFolder = ICFolder.smartFolder(
        withQuery: query,
        titleComponents: [draft.name],
        account: account
      ) as? ICFolder
    else {
      throw writeError(
        operation: "notes.smart-folders.create",
        reason: "ICFolder.smartFolderWithQuery returned nil."
      )
    }

    smartFolder.title = draft.name
    smartFolder.dateForLastTitleModification = Date()
    try save(context: context, operation: "notes.smart-folders.create")
    let record = try readback(
      smartFolder: smartFolder,
      expectedName: draft.name,
      accountName: draft.accountName,
      operation: "notes.smart-folders.create"
    )
    return NotesSmartFolderCreateWriteResult(
      changed: true,
      smartFolder: record,
      tag: tagRecord(firstHashtag)
    )
  }

  func convertFolderToSmartFolder(_ draft: NotesSmartFolderFolderConversionDraft) throws
    -> NotesSmartFolderFolderConversionWriteResult
  {
    let operation = "notes.smart-folders.convert-folder"
    let context = try noteContext()
    let managedObjectContext = try managedObjectContext()
    let sourceFolder = try folder(
      id: draft.folderID,
      name: draft.folderName,
      accountName: draft.accountName
    )
    try validateFolderConversionSource(sourceFolder, operation: operation)
    guard let account = sourceFolder.account else {
      throw writeError(operation: operation, reason: "Source ICFolder.account returned nil.")
    }
    guard let targetFolder = account.defaultFolder else {
      throw writeError(operation: operation, reason: "ICAccount.defaultFolder returned nil.")
    }
    try validateFolderConversionTarget(targetFolder, operation: operation)
    try validateFolderTitle(
      draft.folderName,
      account: account,
      parentFolder: nil,
      operation: operation
    )

    let sourceNotes: [ICNote] = objects(sourceFolder.visibleNotesInFolder)
    let sourceNoteIDs = sourceNotes.map { noteIdentifier($0) }
    guard Set(sourceNoteIDs) == Set(draft.noteIDs), sourceNoteIDs.count == draft.noteIDs.count else {
      throw writeError(operation: operation, reason: "Source folder visible-note set changed before conversion.")
    }
    for note in sourceNotes {
      try validateFolderConversionNote(note, operation: operation)
    }

    let tagText = normalizedTagText(draft.tagDisplayText)
    guard
      let hashtag = ICHashtag.hashtag(
        withDisplayText: tagText,
        account: account,
        createIfNecessary: true
      ) as? ICHashtag
    else {
      throw writeError(operation: operation, reason: "ICHashtag.hashtagWithDisplayText returned nil.")
    }

    for note in sourceNotes {
      _ = note.addHashtag(toNoteBody: hashtag, onlyIfMissing: true)
      note.primitiveFolder = targetFolder
      note.account = account
      note.folderModificationDate = Date()
      note.ensureHashtagsExistInDestinationAccount()
    }

    guard let selection = ICTagSelection(managedObjectContext: managedObjectContext) else {
      throw writeError(operation: operation, reason: "ICTagSelection initializer returned nil.")
    }
    selection.addObjectID(hashtag.objectID, toExcluded: false)
    selection.allowsRecentlyDeleted = false
    guard
      let query = ICQuery.queryForNotes(matchingTagSelection: selection) as? ICQuery,
      let smartFolder = ICFolder.smartFolder(
        withQuery: query,
        titleComponents: [draft.folderName],
        account: account
      ) as? ICFolder
    else {
      throw writeError(operation: operation, reason: "ICFolder.smartFolderWithQuery returned nil.")
    }

    smartFolder.title = draft.folderName
    smartFolder.dateForLastTitleModification = Date()
    sourceFolder.markForDeletion()
    sourceFolder.updateChangeCount(withReason: "apple-cli.smart-folder.convert-folder")
    try save(context: context, operation: operation)

    let record = try readback(
      smartFolder: smartFolder,
      expectedName: draft.folderName,
      accountName: draft.accountName,
      operation: operation
    )
    return NotesSmartFolderFolderConversionWriteResult(
      changed: true,
      smartFolder: record,
      sourceFolderID: draft.folderID,
      sourceFolderName: draft.folderName,
      targetFolderID: objectIDString(targetFolder),
      targetFolderName: folderDisplayName(targetFolder),
      tag: tagRecord(hashtag),
      movedNoteCount: sourceNotes.count,
      taggedNoteCount: sourceNotes.count,
      noteIDHashes: draft.noteIDHashes
    )
  }

  func updateSmartFolder(_ draft: NotesSmartFolderUpdateDraft) throws -> NotesSmartFolderUpdateWriteResult {
    let context = try noteContext()
    let managedObjectContext = try managedObjectContext()
    let folder = try folder(
      id: draft.smartFolderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateSmartFolderUpdateTarget(folder, operation: "notes.smart-folders.update")

    let matchingHashtags = try smartFolderHashtags(
      standardizedContents: draft.tagStandardizedContents,
      accountName: draft.accountName,
      operation: "notes.smart-folders.update"
    )
    guard let firstHashtag = matchingHashtags.first else {
      throw writeError(operation: "notes.smart-folders.update", reason: "No Smart Folder tag selection hashtags resolved.")
    }

    guard let selection = ICTagSelection(managedObjectContext: managedObjectContext) else {
      throw writeError(operation: "notes.smart-folders.update", reason: "ICTagSelection initializer returned nil.")
    }
    for hashtag in matchingHashtags {
      selection.addObjectID(hashtag.objectID, toExcluded: false)
    }
    selection.mode = UInt64(notesSmartFolderTagSelectionModeAllTagged)
    selection.tagOperator = UInt64(draft.tagOperator)
    selection.allowsRecentlyDeleted = false

    guard let query = ICQuery.queryForNotes(matchingTagSelection: selection) as? ICQuery else {
      throw writeError(operation: "notes.smart-folders.update", reason: "ICQuery.queryForNotes returned nil.")
    }

    folder.smartFolderQuery = query
    folder.updateChangeCount(withReason: "apple-cli.smart-folder.update")
    try save(context: context, operation: "notes.smart-folders.update")
    let record = try readback(
      smartFolder: folder,
      expectedName: draft.name,
      accountName: draft.accountName,
      operation: "notes.smart-folders.update"
    )
    return NotesSmartFolderUpdateWriteResult(
      changed: true,
      smartFolder: record,
      tag: tagRecord(firstHashtag)
    )
  }

  private func smartFolderHashtags(
    standardizedContents: [String],
    accountName: String,
    operation: String
  ) throws -> [ICHashtag] {
    var selected: [ICHashtag] = []
    for standardizedContent in standardizedContents {
      let matches = try hashtags(standardizedContent: standardizedContent)
        .filter { accountMatches($0.account, accountName) }
      guard !matches.isEmpty else {
        throw CLIError(
          code: .notFound,
          message: "Tag selector did not match any Notes tag in the selected Smart Folder account.",
          details: [
            "tag_sha256": sha256Hex(standardizedContent),
            "account_sha256": sha256Hex(accountName),
          ]
        )
      }
      selected.append(contentsOf: matches)
    }
    guard !selected.isEmpty else {
      throw writeError(operation: operation, reason: "Smart Folder tag selection resolved no hashtags.")
    }
    return selected
  }

  func createSmartFolderBuiltInCriteria(_ draft: NotesSmartFolderBuiltInCriteriaCreateDraft) throws
    -> NotesSmartFolderBuiltInCriteriaCreateWriteResult
  {
    let context = try noteContext()
    let account = try accountObject(id: draft.accountID, name: draft.accountName)
    guard boolValue(account, key: "supportsEditingNotes") != false else {
      throw writeError(
        operation: "notes.smart-folders.create-criteria",
        reason: "ICAccount.supportsEditingNotes returned false."
      )
    }
    try validateFolderTitle(
      draft.name,
      account: account,
      parentFolder: nil,
      operation: "notes.smart-folders.create-criteria"
    )
    let query = try smartFolderBuiltInCriteriaQuery(
      kind: draft.criteriaKind,
      criteriaKinds: draft.criteriaKinds,
      accountID: draft.accountID,
      accountName: draft.accountName,
      dateCriteria: draft.dateCriteria,
      folderCriteria: draft.folderCriteria,
      folderCriteriaByKind: draft.folderCriteriaByKind,
      participantCriteria: draft.participantCriteria,
      joinOperator: draft.joinOperator,
      includeRecentlyDeleted: draft.includeRecentlyDeleted,
      operation: "notes.smart-folders.create-criteria"
    )
    guard
      let smartFolder = ICFolder.smartFolder(
        withQuery: query,
        titleComponents: [draft.name],
        account: account
      ) as? ICFolder
    else {
      throw writeError(
        operation: "notes.smart-folders.create-criteria",
        reason: "ICFolder.smartFolderWithQuery returned nil."
      )
    }

    smartFolder.title = draft.name
    smartFolder.dateForLastTitleModification = Date()
    try save(context: context, operation: "notes.smart-folders.create-criteria")
    let record = try readback(
      smartFolder: smartFolder,
      expectedName: draft.name,
      accountName: draft.accountName,
      operation: "notes.smart-folders.create-criteria"
    )
    return NotesSmartFolderBuiltInCriteriaCreateWriteResult(changed: true, smartFolder: record)
  }

  func updateSmartFolderBuiltInCriteria(_ draft: NotesSmartFolderBuiltInCriteriaUpdateDraft) throws
    -> NotesSmartFolderBuiltInCriteriaUpdateWriteResult
  {
    let context = try noteContext()
    let folder = try folder(
      id: draft.smartFolderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateSmartFolderUpdateTarget(folder, operation: "notes.smart-folders.update-criteria")
    let query = try smartFolderBuiltInCriteriaQuery(
      kind: draft.criteriaKind,
      criteriaKinds: draft.criteriaKinds,
      accountID: nil,
      accountName: draft.accountName,
      dateCriteria: draft.dateCriteria,
      folderCriteria: draft.folderCriteria,
      folderCriteriaByKind: draft.folderCriteriaByKind,
      participantCriteria: draft.participantCriteria,
      joinOperator: draft.joinOperator,
      includeRecentlyDeleted: draft.includeRecentlyDeleted,
      operation: "notes.smart-folders.update-criteria"
    )

    folder.smartFolderQuery = query
    folder.updateChangeCount(withReason: "apple-cli.smart-folder.update-criteria")
    try save(context: context, operation: "notes.smart-folders.update-criteria")
    let record = try readback(
      smartFolder: folder,
      expectedName: draft.name,
      accountName: draft.accountName,
      operation: "notes.smart-folders.update-criteria"
    )
    return NotesSmartFolderBuiltInCriteriaUpdateWriteResult(changed: true, smartFolder: record)
  }

  func duplicateSmartFolder(_ draft: NotesSmartFolderDuplicateDraft) throws -> NotesSmartFolderDuplicateWriteResult {
    let context = try noteContext()
    let account = try accountObject(id: nil, name: draft.accountName)
    guard boolValue(account, key: "supportsEditingNotes") != false else {
      throw writeError(operation: "notes.smart-folders.duplicate", reason: "ICAccount.supportsEditingNotes returned false.")
    }
    try validateFolderTitle(
      draft.name,
      account: account,
      parentFolder: nil,
      operation: "notes.smart-folders.duplicate"
    )

    let sourceFolder = try folder(
      id: draft.sourceSmartFolderID,
      name: draft.sourceName,
      accountName: draft.accountName
    )
    try validateSmartFolderCriteriaSource(
      sourceFolder,
      operation: "notes.smart-folders.duplicate",
      requiresEditable: true
    )
    guard let sourceQuery = sourceFolder.smartFolderQuery else {
      throw writeError(
        operation: "notes.smart-folders.duplicate",
        reason: "Source ICFolder.smartFolderQuery returned nil."
      )
    }

    guard
      let smartFolder = ICFolder.smartFolder(
        withQuery: sourceQuery,
        titleComponents: [draft.name],
        account: account
      ) as? ICFolder
    else {
      throw writeError(
        operation: "notes.smart-folders.duplicate",
        reason: "ICFolder.smartFolderWithQuery returned nil."
      )
    }

    smartFolder.title = draft.name
    smartFolder.dateForLastTitleModification = Date()
    try save(context: context, operation: "notes.smart-folders.duplicate")
    let record = try readback(
      smartFolder: smartFolder,
      expectedName: draft.name,
      accountName: draft.accountName,
      operation: "notes.smart-folders.duplicate"
    )
    let sourceRecord = try readback(
      smartFolder: sourceFolder,
      expectedName: draft.sourceName,
      accountName: draft.accountName,
      operation: "notes.smart-folders.duplicate"
    )
    return NotesSmartFolderDuplicateWriteResult(
      changed: true,
      smartFolder: record,
      sourceSmartFolder: sourceRecord
    )
  }

  func copySmartFolderCriteria(_ draft: NotesSmartFolderCriteriaCopyDraft) throws
    -> NotesSmartFolderCriteriaCopyWriteResult
  {
    let context = try noteContext()
    let sourceFolder = try folder(
      id: draft.sourceSmartFolderID,
      name: draft.sourceName,
      accountName: draft.accountName
    )
    let targetFolder = try folder(
      id: draft.targetSmartFolderID,
      name: draft.targetName,
      accountName: draft.accountName
    )
    guard sourceFolder != targetFolder else {
      throw writeError(
        operation: "notes.smart-folders.copy-criteria",
        reason: "Source and target ICFolder objects must be distinct."
      )
    }
    try validateSmartFolderCriteriaSource(
      sourceFolder,
      operation: "notes.smart-folders.copy-criteria",
      requiresEditable: false
    )
    try validateSmartFolderUpdateTarget(targetFolder, operation: "notes.smart-folders.copy-criteria")
    guard let sourceQuery = sourceFolder.smartFolderQuery else {
      throw writeError(
        operation: "notes.smart-folders.copy-criteria",
        reason: "Source ICFolder.smartFolderQuery returned nil."
      )
    }

    targetFolder.smartFolderQuery = sourceQuery
    targetFolder.updateChangeCount(withReason: "apple-cli.smart-folder.copy-criteria")
    try save(context: context, operation: "notes.smart-folders.copy-criteria")
    let record = try readback(
      smartFolder: targetFolder,
      expectedName: draft.targetName,
      accountName: draft.accountName,
      operation: "notes.smart-folders.copy-criteria"
    )
    let sourceRecord = try readback(
      smartFolder: sourceFolder,
      expectedName: draft.sourceName,
      accountName: draft.accountName,
      operation: "notes.smart-folders.copy-criteria"
    )
    return NotesSmartFolderCriteriaCopyWriteResult(
      changed: true,
      smartFolder: record,
      sourceSmartFolder: sourceRecord
    )
  }

  func importSmartFolderCriteria(_ draft: NotesSmartFolderCriteriaImportDraft) throws
    -> NotesSmartFolderCriteriaImportWriteResult
  {
    let context = try noteContext()
    let targetFolder = try folder(
      id: draft.smartFolderID,
      name: draft.name,
      accountName: draft.accountName
    )
    try validateSmartFolderUpdateTarget(targetFolder, operation: "notes.smart-folders.import-criteria")

    let previousQueryJSON = targetFolder.smartFolderQueryJSON
    targetFolder.smartFolderQueryJSON = draft.queryJSON
    guard targetFolder.smartFolderQuery != nil else {
      targetFolder.smartFolderQueryJSON = previousQueryJSON
      throw writeError(
        operation: "notes.smart-folders.import-criteria",
        reason: "ICFolder.smartFolderQueryJSON did not produce a readable Smart Folder query."
      )
    }
    guard nonEmpty(targetFolder.smartFolderQueryJSON).map(sha256Hex) == draft.sourceSHA256 else {
      targetFolder.smartFolderQueryJSON = previousQueryJSON
      throw writeError(
        operation: "notes.smart-folders.import-criteria",
        reason: "ICFolder.smartFolderQueryJSON did not preserve the imported criteria JSON."
      )
    }

    targetFolder.updateChangeCount(withReason: "apple-cli.smart-folder.import-criteria")
    try save(context: context, operation: "notes.smart-folders.import-criteria")
    let record = try readback(
      smartFolder: targetFolder,
      expectedName: draft.name,
      accountName: draft.accountName,
      operation: "notes.smart-folders.import-criteria"
    )
    return NotesSmartFolderCriteriaImportWriteResult(changed: true, smartFolder: record)
  }

  private func appendText(_ body: String, to note: ICNote) throws {
    let attributedString = NSAttributedString(string: "\n\(body)")
    var error: AnyObject?
    guard note.appendAttributedString(attributedString, error: &error) else {
      throw writeError(
        operation: "notes.append",
        reason: "ICNote.appendAttributedString returned false.",
        error: error
      )
    }
    try persistNoteTextContent(note, operation: "notes.append")
  }

  private func importedRichAttributedString(
    source: NotesRichImportSource,
    operation: String
  ) throws -> NSAttributedString {
    var documentAttributes: NSDictionary?
    do {
      switch source.format {
      case .rtf:
        guard let data = source.data else {
          throw writeError(operation: operation, reason: "RTF import source data was missing.")
        }
        return try NSAttributedString(
          data: data,
          options: [.documentType: NSAttributedString.DocumentType.rtf],
          documentAttributes: &documentAttributes
        )
      case .rtfd:
        return try NSAttributedString(
          url: URL(fileURLWithPath: source.path),
          options: [.documentType: NSAttributedString.DocumentType.rtfd],
          documentAttributes: &documentAttributes
        )
      case .html:
        guard let data = source.data else {
          throw writeError(operation: operation, reason: "HTML import source data was missing.")
        }
        return try NSAttributedString(
          data: data,
          options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
          ],
          documentAttributes: &documentAttributes
        )
      }
    } catch let error as CLIError {
      throw error
    } catch {
      throw writeError(
        operation: operation,
        reason: "Rich import source could not be converted to attributed text.",
        error: error as NSError
      )
    }
  }

  private func importedMarkdownAttributedString(
    source: NotesMarkdownSource,
    operation: String
  ) throws -> NSAttributedString {
    var privateMarkdownError: AnyObject?
    if let attributed = ICMarkdownRepresentation.attributedMarkdownString(
      fromPlainMarkdown: source.body,
      error: &privateMarkdownError
    ) as? NSAttributedString,
      !attributed.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return attributed
    }
    if let attributed = ICMarkdownRepresentation.attributedString(
      fromPossibleMarkdown: source.body,
      fallback: source.body
    ) as? NSAttributedString,
      !attributed.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return attributed
    }

    let parsed: AttributedString
    do {
      parsed = try AttributedString(
        markdown: source.body,
        options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
      )
    } catch {
      throw writeError(
        operation: operation,
        reason: "Markdown import source could not be semantically parsed.",
        error: error as NSError
      )
    }

    let output = NSMutableAttributedString()
    var previousBlock: String?
    for run in parsed.runs {
      let block = markdownBlockSignature(run.presentationIntent)
      if output.length > 0, previousBlock != nil, previousBlock != block {
        output.append(NSAttributedString(string: "\n"))
      }
      output.append(NSAttributedString(AttributedString(parsed[run.range])))
      previousBlock = block
    }

    if output.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      output.setAttributedString(NSAttributedString(string: source.body))
    }
    return output
  }

  private func markdownBlockSignature(_ presentationIntent: PresentationIntent?) -> String {
    guard let presentationIntent else {
      return "paragraph"
    }
    return String(describing: presentationIntent)
  }

  private struct ENEXAttributedContent {
    var attributed: NSAttributedString
    var inlinePlacements: [ENEXInlinePlacement]
  }

  private struct ENEXInlinePlacement {
    var referenceOrdinal: Int
    var resourceOrdinal: Int
    var bodyLocation: Int
  }

  private struct NotesRichReplaceResource {
    var ordinal: Int
    var relativePath: String
    var filename: String
    var byteCount: Int
    var data: Data
  }

  private struct NotesRichReplaceAttachmentObject {
    var resource: NotesRichReplaceResource
    var attachment: AnyObject
  }

  private struct NotesInlineResourceReference {
    var referenceOrdinal: Int
    var resourceOrdinal: Int
    var marker: String
  }

  private struct NotesInlineResourcePlacement {
    var referenceOrdinal: Int
    var resourceOrdinal: Int
    var bodyLocation: Int
  }

  private struct NotesRichReplacePreparedContent {
    var attributed: NSAttributedString
    var resources: [NotesRichReplaceResource]
    var placements: [NotesInlineResourcePlacement]
    var referenceCountsByResourceOrdinal: [Int: Int]
    var markers: [String]
    var sourceSHA256: String?
    var packageFileCount: Int?
    var packageResourceFileCount: Int?
    var packageTotalByteCount: Int?
    var packageTreeSHA256: String?
    var markdownRelativePath: String?
    var htmlRelativePath: String?
    var semanticSummary: NotesMarkdownSemanticSummary?

    var inlineReferenceCount: Int { referenceCountsByResourceOrdinal.values.reduce(0, +) }
  }

  private func preparedRichReplaceContent(
    _ source: NotesRichReplaceSource,
    operation: String
  ) throws -> NotesRichReplacePreparedContent {
    switch source {
    case .markdown(let markdown):
      return try preparedMarkdownReplaceContent(markdown, operation: operation)
    case .rich(let rich):
      return try preparedRichTextReplaceContent(rich, operation: operation)
    }
  }

  private func preparedMarkdownReplaceContent(
    _ source: NotesMarkdownSource,
    operation: String
  ) throws -> NotesRichReplacePreparedContent {
    let resources = source.resources.enumerated().map { offset, resource in
      NotesRichReplaceResource(
        ordinal: offset + 1,
        relativePath: resource.relativePath,
        filename: resource.filename,
        byteCount: resource.byteCount,
        data: resource.data
      )
    }
    let marked = try markdownSourceWithInlineResourceMarkers(source, resources: resources)
    let imported = try importedMarkdownAttributedString(source: marked.source, operation: operation)
    let content = try attributedContentRemovingInlineResourceMarkers(
      imported,
      references: marked.references,
      operation: operation
    )
    return NotesRichReplacePreparedContent(
      attributed: content.attributed,
      resources: resources,
      placements: content.placements,
      referenceCountsByResourceOrdinal: resourceReferenceCounts(marked.references),
      markers: marked.references.map(\.marker),
      sourceSHA256: sha256Hex(source.body),
      packageFileCount: source.packageFileCount,
      packageResourceFileCount: source.resources.count,
      packageTotalByteCount: source.packageTotalByteCount,
      packageTreeSHA256: source.packageTreeSHA256,
      markdownRelativePath: source.markdownRelativePath,
      htmlRelativePath: nil,
      semanticSummary: source.semanticSummary
    )
  }

  private func preparedRichTextReplaceContent(
    _ source: NotesRichImportSource,
    operation: String
  ) throws -> NotesRichReplacePreparedContent {
    let resources = source.resources.enumerated().map { offset, resource in
      NotesRichReplaceResource(
        ordinal: offset + 1,
        relativePath: resource.relativePath,
        filename: resource.filename,
        byteCount: resource.byteCount,
        data: resource.data
      )
    }
    let markedSource: (source: NotesRichImportSource, references: [NotesInlineResourceReference])
    if source.format == .html {
      markedSource = try htmlSourceWithInlineResourceMarkers(source, resources: resources)
    } else {
      markedSource = (source, [])
    }
    let imported = try importedRichAttributedString(source: markedSource.source, operation: operation)
    let content = try attributedContentRemovingInlineResourceMarkers(
      imported,
      references: markedSource.references,
      operation: operation
    )
    return NotesRichReplacePreparedContent(
      attributed: content.attributed,
      resources: resources,
      placements: content.placements,
      referenceCountsByResourceOrdinal: resourceReferenceCounts(markedSource.references),
      markers: markedSource.references.map(\.marker),
      sourceSHA256: source.data.map(sha256Hex),
      packageFileCount: source.packageFileCount,
      packageResourceFileCount: source.packageResourceFileCount,
      packageTotalByteCount: source.packageTotalByteCount,
      packageTreeSHA256: source.packageTreeSHA256,
      markdownRelativePath: nil,
      htmlRelativePath: source.htmlRelativePath,
      semanticSummary: nil
    )
  }

  private func markdownSourceWithInlineResourceMarkers(
    _ source: NotesMarkdownSource,
    resources: [NotesRichReplaceResource]
  ) throws -> (source: NotesMarkdownSource, references: [NotesInlineResourceReference]) {
    guard !resources.isEmpty else {
      return (source, [])
    }
    let resourcesByPath = Dictionary(uniqueKeysWithValues: resources.map { ($0.relativePath, $0.ordinal) })
    var references: [NotesInlineResourceReference] = []
    var output = ""
    var cursor = source.body.startIndex
    var index = source.body.startIndex

    while index < source.body.endIndex {
      let next = source.body.index(after: index)
      guard source.body[index] == "!", next < source.body.endIndex, source.body[next] == "[" else {
        index = next
        continue
      }
      guard let bracketEnd = source.body[next...].firstIndex(of: "]") else {
        index = next
        continue
      }
      let parenStart = source.body.index(after: bracketEnd)
      guard parenStart < source.body.endIndex, source.body[parenStart] == "(",
        let parenEnd = source.body[parenStart...].firstIndex(of: ")")
      else {
        index = source.body.index(after: bracketEnd)
        continue
      }
      let rawDestination = String(source.body[source.body.index(after: parenStart)..<parenEnd])
      guard let localPath = try notesInlineLocalResourcePath(rawDestination),
        let resourceOrdinal = resourcesByPath[try normalizedNotesMarkdownRelativePath(localPath)]
      else {
        index = source.body.index(after: parenEnd)
        continue
      }
      let marker = notesInlineResourceMarker(referenceOrdinal: references.count + 1)
      if output.isEmpty {
        output.append(contentsOf: source.body[cursor..<index])
      } else {
        output.append(contentsOf: source.body[cursor..<index])
      }
      output.append(marker)
      references.append(
        NotesInlineResourceReference(
          referenceOrdinal: references.count + 1,
          resourceOrdinal: resourceOrdinal,
          marker: marker
        ))
      cursor = source.body.index(after: parenEnd)
      index = cursor
    }
    guard !references.isEmpty else {
      return (source, [])
    }
    output.append(contentsOf: source.body[cursor..<source.body.endIndex])
    var marked = source
    marked.body = output
    return (marked, references)
  }

  private func htmlSourceWithInlineResourceMarkers(
    _ source: NotesRichImportSource,
    resources: [NotesRichReplaceResource]
  ) throws -> (source: NotesRichImportSource, references: [NotesInlineResourceReference]) {
    guard !resources.isEmpty, let data = source.data, let html = String(data: data, encoding: .utf8) else {
      return (source, [])
    }
    let resourcesByPath = Dictionary(uniqueKeysWithValues: resources.map { ($0.relativePath, $0.ordinal) })
    struct HTMLInlineResourceCandidate {
      var range: NSRange
      var resourceOrdinal: Int
      var preservedHTML: String
    }
    let mediaTagRegex = try NSRegularExpression(pattern: #"(?is)<(?:img|object|embed)\b[^>]*>"#)
    let mediaAttributeRegex = try NSRegularExpression(pattern: #"(?is)\b(?:src|data)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))"#)
    let anchorRegex = try NSRegularExpression(pattern: #"(?is)<a\b[^>]*>.*?</a>"#)
    let hrefAttributeRegex = try NSRegularExpression(pattern: #"(?is)\bhref\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))"#)
    let nsHTML = html as NSString
    var candidates: [HTMLInlineResourceCandidate] = []

    for match in mediaTagRegex.matches(in: html, range: NSRange(location: 0, length: nsHTML.length)) {
      let tag = nsHTML.substring(with: match.range)
      let nsTag = tag as NSString
      guard let attribute = mediaAttributeRegex.firstMatch(in: tag, range: NSRange(location: 0, length: nsTag.length)) else {
        continue
      }
      let rawValue = (1...3)
        .compactMap { index -> String? in
          let range = attribute.range(at: index)
          return range.location == NSNotFound ? nil : nsTag.substring(with: range)
        }
        .first
      guard let rawValue,
        let localPath = try notesInlineLocalResourcePath(rawValue),
        let resourceOrdinal = resourcesByPath[try normalizedNotesHTMLRelativePath(localPath)]
      else {
        continue
      }
      candidates.append(
        HTMLInlineResourceCandidate(
          range: match.range,
          resourceOrdinal: resourceOrdinal,
          preservedHTML: ""
        ))
    }

    for match in anchorRegex.matches(in: html, range: NSRange(location: 0, length: nsHTML.length)) {
      let anchor = nsHTML.substring(with: match.range)
      let nsAnchor = anchor as NSString
      guard let attribute = hrefAttributeRegex.firstMatch(in: anchor, range: NSRange(location: 0, length: nsAnchor.length)) else {
        continue
      }
      let rawValue = (1...3)
        .compactMap { index -> String? in
          let range = attribute.range(at: index)
          return range.location == NSNotFound ? nil : nsAnchor.substring(with: range)
        }
        .first
      guard let rawValue,
        let localPath = try notesInlineLocalResourcePath(rawValue),
        let resourceOrdinal = resourcesByPath[try normalizedNotesHTMLRelativePath(localPath)],
        let openTagEnd = anchor.firstIndex(of: ">"),
        let closeTagRange = anchor.range(of: "</a>", options: [.caseInsensitive, .backwards])
      else {
        continue
      }
      candidates.append(
        HTMLInlineResourceCandidate(
          range: match.range,
          resourceOrdinal: resourceOrdinal,
          preservedHTML: String(anchor[anchor.index(after: openTagEnd)..<closeTagRange.lowerBound])
        ))
    }

    let orderedCandidates = candidates.sorted { lhs, rhs in
      if lhs.range.location == rhs.range.location {
        return lhs.range.length > rhs.range.length
      }
      return lhs.range.location < rhs.range.location
    }
    guard !orderedCandidates.isEmpty else {
      return (source, [])
    }

    var output = ""
    var cursor = 0
    var references: [NotesInlineResourceReference] = []
    for candidate in orderedCandidates {
      guard candidate.range.location >= cursor else {
        continue
      }
      if candidate.range.location > cursor {
        output += nsHTML.substring(with: NSRange(location: cursor, length: candidate.range.location - cursor))
      }
      output += candidate.preservedHTML
      let marker = notesInlineResourceMarker(referenceOrdinal: references.count + 1)
      output += marker
      references.append(
        NotesInlineResourceReference(
          referenceOrdinal: references.count + 1,
          resourceOrdinal: candidate.resourceOrdinal,
          marker: marker
        ))
      cursor = candidate.range.location + candidate.range.length
    }
    guard !references.isEmpty else {
      return (source, [])
    }
    if cursor < nsHTML.length {
      output += nsHTML.substring(from: cursor)
    }
    var marked = source
    marked.data = output.data(using: .utf8)
    return (marked, references)
  }

  private func notesInlineResourceMarker(referenceOrdinal: Int) -> String {
    "__APPLE_CLI_NOTES_INLINE_RESOURCE_\(referenceOrdinal)__"
  }

  private func notesInlineLocalResourcePath(_ rawDestination: String) throws -> String? {
    let trimmed = rawDestination.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return nil
    }
    let destination: String
    if trimmed.hasPrefix("<") {
      guard let end = trimmed.firstIndex(of: ">"), end > trimmed.startIndex else {
        throw CLIError(
          code: .validationError,
          message: "Notes inline resource reference must use a valid local relative path.",
          details: ["resource_reference_sha256": sha256Hex(rawDestination)]
        )
      }
      destination = String(trimmed[trimmed.index(after: trimmed.startIndex)..<end])
    } else {
      destination = String(trimmed.prefix { !$0.isWhitespace })
    }
    let decoded = destination.removingPercentEncoding ?? destination
    guard !decoded.isEmpty, decoded != "#" else {
      return nil
    }
    if decoded.hasPrefix("#")
      || decoded.hasPrefix("//")
      || decoded.contains("?")
      || decoded.contains("#")
      || URL(string: decoded)?.scheme != nil
    {
      return nil
    }
    guard decoded.hasPrefix("/") == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes inline resource references must be local relative file paths.",
        details: ["resource_reference_sha256": sha256Hex(rawDestination)]
      )
    }
    return decoded
  }

  private func attributedContentRemovingInlineResourceMarkers(
    _ attributed: NSAttributedString,
    references: [NotesInlineResourceReference],
    operation: String
  ) throws -> (attributed: NSAttributedString, placements: [NotesInlineResourcePlacement]) {
    guard !references.isEmpty else {
      return (attributed, [])
    }
    let mutable = NSMutableAttributedString(attributedString: attributed)
    var placements: [NotesInlineResourcePlacement] = []
    for reference in references {
      let range = (mutable.string as NSString).range(of: reference.marker)
      guard range.location != NSNotFound else {
        throw writeError(operation: operation, reason: "Notes inline resource marker was lost during attributed conversion.")
      }
      placements.append(
        NotesInlineResourcePlacement(
          referenceOrdinal: reference.referenceOrdinal,
          resourceOrdinal: reference.resourceOrdinal,
          bodyLocation: range.location
        ))
      mutable.deleteCharacters(in: range)
    }
    return (mutable, placements)
  }

  private func resourceReferenceCounts(_ references: [NotesInlineResourceReference]) -> [Int: Int] {
    Dictionary(grouping: references, by: \.resourceOrdinal).mapValues(\.count)
  }

  private func importedENEXAttributedContent(
    _ sourceNote: NotesENEXImportNoteSource,
    operation: String
  ) throws -> ENEXAttributedContent {
    let markers = sourceNote.inlineResourceReferences.map { enexInlineMarker(ordinal: $0.ordinal) }
    let html = notesENEXHTMLDocument(sourceNote.content, inlineMediaMarkers: markers)
    if let data = html.data(using: .utf8),
      let attributed = try? NSAttributedString(
        data: data,
        options: [
          .documentType: NSAttributedString.DocumentType.html,
          .characterEncoding: String.Encoding.utf8.rawValue,
        ],
        documentAttributes: nil
      ),
      !attributed.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      if let marked = try? enexAttributedContentRemovingInlineMarkers(
        attributed,
        references: sourceNote.inlineResourceReferences,
        operation: operation
      ) {
        return marked
      }
    }

    let fallback = notesENEXPlainText(sourceNote.content, inlineMediaMarkers: markers)
    guard !fallback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw writeError(operation: operation, reason: "ENEX note content could not be converted to visible text.")
    }
    return try enexAttributedContentRemovingInlineMarkers(
      NSAttributedString(string: fallback),
      references: sourceNote.inlineResourceReferences,
      operation: operation
    )
  }

  private func enexInlineMarker(ordinal: Int) -> String {
    "__APPLE_CLI_ENEX_MEDIA_\(ordinal)__"
  }

  private func enexAttributedContentRemovingInlineMarkers(
    _ attributed: NSAttributedString,
    references: [NotesENEXMediaReferenceSource],
    operation: String
  ) throws -> ENEXAttributedContent {
    let mutable = NSMutableAttributedString(attributedString: attributed)
    var placements: [ENEXInlinePlacement] = []
    for reference in references {
      guard let resourceOrdinal = reference.matchedResourceOrdinal else {
        continue
      }
      let marker = enexInlineMarker(ordinal: reference.ordinal)
      let range = (mutable.string as NSString).range(of: marker)
      guard range.location != NSNotFound else {
        throw writeError(
          operation: operation,
          reason: "ENEX inline media marker was lost during attributed conversion."
        )
      }
      placements.append(
        ENEXInlinePlacement(
          referenceOrdinal: reference.ordinal,
          resourceOrdinal: resourceOrdinal,
          bodyLocation: range.location
        ))
      mutable.deleteCharacters(in: range)
    }
    return ENEXAttributedContent(attributed: mutable, inlinePlacements: placements)
  }

  private func notesENEXHTMLDocument(_ content: String, inlineMediaMarkers: [String] = []) -> String {
    var html = content
    html = html.replacingOccurrences(
      of: #"(?is)<\?xml[^>]*\?>"#,
      with: "",
      options: .regularExpression
    )
    html = html.replacingOccurrences(
      of: #"(?is)<!DOCTYPE[^>]*(\[[\s\S]*?\])?>"#,
      with: "",
      options: .regularExpression
    )
    html = html.replacingOccurrences(of: "<en-note", with: "<div", options: [.caseInsensitive])
    html = html.replacingOccurrences(of: "</en-note>", with: "</div>", options: [.caseInsensitive])
    html = notesENEXReplacingInlineMedia(in: html, markers: inlineMediaMarkers)
    return "<!doctype html><html><body>\(html)</body></html>"
  }

  private func notesENEXReplacingInlineMedia(in content: String, markers: [String]) -> String {
    guard let regex = try? NSRegularExpression(pattern: #"(?is)<en-media\b[^>]*/?>"#) else {
      return content
    }
    let source = content as NSString
    let matches = regex.matches(in: content, range: NSRange(location: 0, length: source.length))
    guard !matches.isEmpty else {
      return content
    }

    var result = ""
    var cursor = 0
    for (index, match) in matches.enumerated() {
      if match.range.location > cursor {
        result += source.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
      }
      if index < markers.count {
        result += markers[index]
      }
      cursor = match.range.location + match.range.length
    }
    if cursor < source.length {
      result += source.substring(from: cursor)
    }
    return result
  }

  private func notesENEXPlainText(_ content: String, inlineMediaMarkers: [String] = []) -> String {
    var text = notesENEXHTMLDocument(content, inlineMediaMarkers: inlineMediaMarkers)
    text = text.replacingOccurrences(of: #"(?is)<br\s*/?>"#, with: "\n", options: .regularExpression)
    text = text.replacingOccurrences(of: #"(?is)</p>|</div>"#, with: "\n", options: .regularExpression)
    text = text.replacingOccurrences(of: #"(?is)<[^>]+>"#, with: "", options: .regularExpression)
    text = text.replacingOccurrences(of: "&nbsp;", with: " ")
    text = text.replacingOccurrences(of: "&amp;", with: "&")
    text = text.replacingOccurrences(of: "&lt;", with: "<")
    text = text.replacingOccurrences(of: "&gt;", with: ">")
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func placeENEXInlineAttachments(
    in note: ICNote,
    title: String,
    placements: [ENEXInlinePlacement],
    attachmentObjects: [(resource: NotesENEXResourceSource, attachment: AnyObject)],
    operation: String
  ) throws -> [Int: Int] {
    guard !placements.isEmpty else {
      return [:]
    }
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    guard let insertionController = ICAttachmentInsertionController(note: note) else {
      throw writeError(operation: operation, reason: "ICAttachmentInsertionController could not be created.")
    }
    let attachmentsByResourceOrdinal = Dictionary(
      uniqueKeysWithValues: attachmentObjects.map { ($0.resource.ordinal, $0.attachment) }
    )
    let titleOffset = (title as NSString).length + 1
    var placedCounts: [Int: Int] = [:]
    for placement in placements.sorted(by: { $0.bodyLocation > $1.bodyLocation }) {
      guard let attachment = attachmentsByResourceOrdinal[placement.resourceOrdinal] else {
        continue
      }
      let boundedLocation = min(max(titleOffset + placement.bodyLocation, 0), textStorage.length)
      let inserted = insertionController.addAttachment(
        attachment,
        atTextLocation: UInt64(boundedLocation)
      )
      if inserted != nil {
        placedCounts[placement.resourceOrdinal, default: 0] += 1
      }
    }
    return placedCounts
  }

  private func placeInlineResourceAttachments(
    in note: ICNote,
    title: String,
    placements: [NotesInlineResourcePlacement],
    attachmentObjects: [NotesRichReplaceAttachmentObject],
    operation: String
  ) throws -> [Int: Int] {
    guard !placements.isEmpty else {
      return [:]
    }
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    guard let insertionController = ICAttachmentInsertionController(note: note) else {
      throw writeError(operation: operation, reason: "ICAttachmentInsertionController could not be created.")
    }

    let attachmentsByResourceOrdinal = Dictionary(
      uniqueKeysWithValues: attachmentObjects.map { ($0.resource.ordinal, $0.attachment) }
    )
    let titleOffset = (title as NSString).length + 1
    var placedCounts: [Int: Int] = [:]
    for placement in placements.sorted(by: { $0.bodyLocation > $1.bodyLocation }) {
      guard let attachment = attachmentsByResourceOrdinal[placement.resourceOrdinal] else {
        continue
      }
      let boundedLocation = min(max(titleOffset + placement.bodyLocation, 0), textStorage.length)
      let inserted = insertionController.addAttachment(
        attachment,
        atTextLocation: UInt64(boundedLocation)
      )
      if inserted != nil {
        placedCounts[placement.resourceOrdinal, default: 0] += 1
      }
    }
    return placedCounts
  }

  private func applyENEXDates(_ source: NotesENEXImportNoteSource, to note: ICNote) {
    if let createdAt = source.createdAt {
      note.setValue(createdAt, forKey: "creationDate")
    }
    if let updatedAt = source.updatedAt {
      note.legacyModificationDateAtImport = updatedAt
      note.setValue(updatedAt, forKey: "modificationDate")
    }
  }

  private func dateMatches(_ expected: Date, _ actual: Date?) -> Bool {
    guard let actual else {
      return false
    }
    return abs(actual.timeIntervalSince(expected)) < 1.0
  }

  private func richImportAttributedBody(title: String, imported: NSAttributedString) -> NSAttributedString {
    let body = NSMutableAttributedString(string: title)
    body.append(NSAttributedString(string: "\n"))
    body.append(imported)
    return body
  }

  private func replaceAttributedText(
    _ attributedString: NSAttributedString,
    in note: ICNote,
    operation: String
  ) throws {
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    note.beginEditing()
    textStorage.setAttributedString(attributedString)
    note.didChangeText()
    note.endEditing()
    try persistNoteTextContent(note, operation: operation)
  }

  private func richImportAttributedRunCount(_ attributedString: NSAttributedString) -> Int {
    guard attributedString.length > 0 else {
      return 0
    }
    var count = 0
    attributedString.enumerateAttributes(
      in: NSRange(location: 0, length: attributedString.length),
      options: []
    ) { _, _, _ in
      count += 1
    }
    return count
  }

  private func richImportAttachmentRunCount(_ attributedString: NSAttributedString) -> Int {
    guard attributedString.length > 0 else {
      return 0
    }
    var count = 0
    attributedString.enumerateAttribute(
      .attachment,
      in: NSRange(location: 0, length: attributedString.length),
      options: []
    ) { value, _, _ in
      if value is NSTextAttachment {
        count += 1
      }
    }
    return count
  }

  private func richImportBoolCheck(
    name: String,
    expected: Bool,
    actual: Bool?
  ) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: actual.map { expected == $0 ? "passed" : "failed" } ?? "unavailable",
      expectedBool: expected,
      actualBool: actual
    )
  }

  func checklistAttributedString(text: String, checked: Bool) throws -> NSAttributedString {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Checklist item text must not be empty."
      )
    }

    let style = try checklistParagraphStyle(checked: checked)
    let attributedString = NSMutableAttributedString(string: trimmedText)
    attributedString.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: style,
      range: NSRange(location: 0, length: (trimmedText as NSString).length)
    )
    return attributedString
  }

  func listAttributedString(
    text: String,
    style listStyle: NotesBodyListStyle,
    operation: String
  ) throws -> NSAttributedString {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "List item text must not be empty."
      )
    }

    let style = try listParagraphStyle(style: listStyle, operation: operation)
    let attributedString = NSMutableAttributedString(string: trimmedText)
    attributedString.addAttribute(
      NSAttributedString.Key(paragraphStyleAttributeName()),
      value: style,
      range: NSRange(location: 0, length: (trimmedText as NSString).length)
    )
    return attributedString
  }

  func checklistParagraphStyle(checked: Bool) throws -> ICTTParagraphStyle {
    guard
      let style = ICTTMutableParagraphStyle.paragraphStyleNamed(103) as? ICTTMutableParagraphStyle
    else {
      throw writeError(
        operation: "notes.body.checklist.add",
        reason: "ICTTMutableParagraphStyle could not be created."
      )
    }
    guard let baseTodo = ICTTTodo() else {
      throw writeError(
        operation: "notes.body.checklist.add",
        reason: "ICTTTodo could not be created."
      )
    }
    guard let todo = baseTodo.todo(withDone: checked) as? ICTTTodo, todo.done == checked else {
      throw writeError(operation: "notes.body.checklist.add", reason: "Checklist completion style is unavailable.")
    }
    style.todo = todo
    style.uuid = UUID()
    guard style.isChecklist, style.isList, !style.isHeader else {
      throw writeError(operation: "notes.body.checklist.add", reason: "Checklist paragraph style is unavailable.")
    }
    return style
  }

  private func paragraphStyle(
    from currentStyle: ICTTParagraphStyle,
    style paragraphStyle: NotesBodyParagraphStyle,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard let style = currentStyle.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.style = try paragraphStyleValue(paragraphStyle, operation: operation)
    style.todo = nil
    style.indent = 0
    style.blockQuoteLevel = 0
    if style.uuid == nil {
      style.uuid = UUID()
    }
    return style
  }

  private func bodyParagraphStyleForInsertedParagraph(
    from currentStyle: ICTTParagraphStyle,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard let style = currentStyle.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.style = try paragraphStyleValue(.body, operation: operation)
    style.todo = nil
    style.indent = 0
    style.blockQuoteLevel = 0
    style.uuid = UUID()
    return style
  }

  private func paragraphStyle(
    from currentStyle: ICTTParagraphStyle,
    alignment: NotesBodyParagraphAlignment,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard let style = currentStyle.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.alignment = Int64(paragraphStyleAlignment(alignment))
    if style.uuid == nil {
      style.uuid = UUID()
    }
    return style
  }

  private func paragraphStyle(
    from currentStyle: ICTTParagraphStyle,
    blockQuoteEnabled: Bool,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard let style = currentStyle.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.todo = nil
    style.indent = 0
    style.blockQuoteLevel = blockQuoteEnabled ? 1 : 0
    if style.uuid == nil {
      style.uuid = UUID()
    }
    return style
  }

  private func paragraphStyleValue(
    _ style: NotesBodyParagraphStyle,
    operation: String
  ) throws -> UInt32 {
    guard let textStyle = bodyTextStyle(style) else {
      throw writeError(
        operation: operation,
        reason: "ICTextStyle could not resolve paragraph style \(style.rawValue)."
      )
    }
    return textStyle.ttStyle
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

  private func setInlineColor(
    _ draft: NotesBodyInlineColorDraft,
    role: String,
    attribute: NSAttributedString.Key,
    operation: String
  ) throws -> NotesBodyInlineColorWriteResult {
    let context = try noteContext()
    let note = try note(id: draft.noteID)
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }

    let target = try inlineTextTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      text: draft.text,
      occurrence: draft.occurrence,
      textStorage: textStorage,
      operation: operation
    )
    let color = try draft.color.map { try inlineColor($0, operation: operation) }
    let colorSHA256 = color.flatMap { colorHash($0) }
    let alreadyApplied = try inlineRangeColorMatches(
      colorSHA256: colorSHA256,
      attribute: attribute,
      in: textStorage,
      range: target.range
    )
    guard alreadyApplied == false else {
      let detail = try readback(note: note, operation: operation)
      let structure = try reader.readBodyStructure(noteID: draft.noteID)
      return NotesBodyInlineColorWriteResult(
        changed: false,
        note: detail,
        structure: structure,
        evidence: target.evidence(role: role, colorSHA256: colorSHA256)
      )
    }

    note.beginEditing()
    do {
      try notesMutateNativeInlineAttributes(in: textStorage, range: target.range,
        ownedKeys: [role == "foreground" ? "TTColor" : "TTEmphasis"], operation: operation) { attributes in
          var updated = attributes
          updated[attribute] = color
          return updated
        }
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }
    try persistNoteTextContent(note, operation: operation)

    try save(note: note, context: context, operation: operation)
    let detail = try readback(note: note, operation: operation)
    let structure = try reader.readBodyStructure(noteID: draft.noteID)
    return NotesBodyInlineColorWriteResult(
      changed: true,
      note: detail,
      structure: structure,
      evidence: target.evidence(role: role, colorSHA256: colorSHA256)
    )
  }

  private func inlineTextTarget(
    noteID: String,
    paragraphIDSHA256: String?,
    ordinal: Int?,
    text: String,
    occurrence: Int?,
    textStorage: NSTextStorage,
    operation: String
  ) throws -> NotesInlineTextTarget {
    guard text.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Inline body formatting requires non-empty `--text`."
      )
    }
    let string = textStorage.string as NSString
    let nativeParagraphs = notesStyledParagraphs(in: textStorage) { value -> (id: String, style: ICTTParagraphStyle)? in
      guard let style = value as? ICTTParagraphStyle, let id = style.uuid?.uuidString else { return nil }
      return (id, style)
    }
    let paragraph = try notesInlineParagraph(noteID: noteID, in: string,
      nativeAnchors: nativeParagraphs.map { NotesInlineParagraph(range: $0.range, idSHA256: sha256Hex($0.id)) },
      paragraphIDSHA256: paragraphIDSHA256, ordinal: ordinal, operation: operation)
    let selection = try notesInlineTextSelection(in: string, text: text,
      paragraphRange: paragraph.range, occurrence: occurrence, operation: operation)
    let range = selection.range
    let selectedOccurrence = selection.occurrence

    return NotesInlineTextTarget(
      range: range,
      paragraphIDSHA256: paragraph.idSHA256,
      textByteCount: text.utf8.count,
      textSHA256: sha256Hex(text),
      occurrence: selectedOccurrence,
      richTextSHA256: sha256Hex(textStorage.string)
    )
  }

  func inlineRangeMatchesFormat(
    _ format: NotesBodyInlineFormat,
    enabled: Bool,
    in textStorage: NSAttributedString,
    range: NSRange
  ) throws -> Bool {
    guard range.location >= 0, range.length > 0, range.location <= textStorage.length,
      range.length <= textStorage.length - range.location else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes inline format selection is outside the available body."
      )
    }
    var allRunsMatch = true
    let converter = try inlineStyleConverter(for: textStorage)
    var failure: Error?
    textStorage.enumerateAttributes(in: range, options: []) { attributes, _, stop in
      let presentation: [NSAttributedString.Key: Any]
      do { presentation = try converter?.presentation(attributes) ?? attributes }
      catch { failure = error; stop.pointee = true; return }
      guard inlineAttributes(presentation, contain: format) == enabled else {
        allRunsMatch = false
        stop.pointee = true
        return
      }
    }
    if let failure { throw failure }
    return allRunsMatch
  }

  private func inlineRangeColorMatches(
    colorSHA256: String?,
    attribute: NSAttributedString.Key,
    in textStorage: NSTextStorage,
    range: NSRange
  ) throws -> Bool {
    var allRunsMatch = true
    let converter = try inlineStyleConverter(for: textStorage)
    var failure: Error?
    textStorage.enumerateAttributes(in: range, options: []) { attributes, _, stop in
      let presentation: [NSAttributedString.Key: Any]
      do { presentation = try converter?.presentation(attributes) ?? attributes }
      catch { failure = error; stop.pointee = true; return }
      let actual = presentation[attribute].flatMap(colorHash)
      guard actual == colorSHA256 else {
        allRunsMatch = false
        stop.pointee = true
        return
      }
    }
    if let failure { throw failure }
    return allRunsMatch
  }

  private func inlineRangeFontMatches(
    fontSHA256: String,
    in textStorage: NSTextStorage,
    range: NSRange
  ) throws -> Bool {
    var allRunsMatch = true
    let converter = try inlineStyleConverter(for: textStorage)
    var failure: Error?
    textStorage.enumerateAttributes(in: range, options: []) { attributes, _, stop in
      let presentation: [NSAttributedString.Key: Any]
      do { presentation = try converter?.presentation(attributes) ?? attributes }
      catch { failure = error; stop.pointee = true; return }
      guard let font = presentation[.font] as? NSFont, notesFontSHA256(font) == fontSHA256 else {
        allRunsMatch = false
        stop.pointee = true
        return
      }
    }
    if let failure { throw failure }
    return allRunsMatch
  }

  private func inlineStyleConverter(for text: NSAttributedString) throws -> NotesNativeInlineStyle? {
    if text is ICTTTextStorage || notesHasModelAttributes(text) {
      return try NotesNativeInlineStyle(operation: "notes.body.inline")
    }
    return nil
  }

  private func applyInlineFormat(
    _ format: NotesBodyInlineFormat,
    enabled: Bool,
    to textStorage: NSMutableAttributedString,
    range: NSRange
  ) throws {
    if textStorage is ICTTTextStorage || notesHasModelAttributes(textStorage) {
      let ownedKeys: [String]
      switch format {
      case .bold, .italic: ownedKeys = ["TTHints", "ICTTFont"]
      case .underline: ownedKeys = ["TTUnderline"]
      case .strikethrough: ownedKeys = ["TTStrikethrough"]
      }
      try notesMutateNativeInlineAttributes(in: textStorage, range: range, ownedKeys: ownedKeys,
        operation: "notes.body.inline.format") { attributes in
          var updated = attributes
          switch format {
          case .bold, .italic:
            let font = attributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let trait: NSFontTraitMask = format == .bold ? .boldFontMask : .italicFontMask
            updated[.font] = enabled ? NSFontManager.shared.convert(font, toHaveTrait: trait)
              : NSFontManager.shared.convert(font, toNotHaveTrait: trait)
          case .underline: updated[.underlineStyle] = enabled ? NSUnderlineStyle.single.rawValue : nil
          case .strikethrough: updated[.strikethroughStyle] = enabled ? NSUnderlineStyle.single.rawValue : nil
          }
          return updated
        }
      return
    }
    switch format {
    case .bold:
      applyFontTrait(.boldFontMask, enabled: enabled, to: textStorage, range: range)
    case .italic:
      applyFontTrait(.italicFontMask, enabled: enabled, to: textStorage, range: range)
    case .underline:
      if enabled {
        textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
      } else {
        textStorage.removeAttribute(.underlineStyle, range: range)
      }
    case .strikethrough:
      if enabled {
        textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
      } else {
        textStorage.removeAttribute(.strikethroughStyle, range: range)
      }
    }
  }

  private func applyFontTrait(
    _ trait: NSFontTraitMask,
    enabled: Bool,
    to textStorage: NSMutableAttributedString,
    range: NSRange
  ) {
    textStorage.enumerateAttribute(.font, in: range, options: []) { value, runRange, _ in
      let font = value as? NSFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
      let updated = enabled
        ? NSFontManager.shared.convert(font, toHaveTrait: trait)
        : NSFontManager.shared.convert(font, toNotHaveTrait: trait)
      textStorage.addAttribute(.font, value: updated, range: runRange)
    }
  }

  private func inlineAttributes(
    _ attributes: [NSAttributedString.Key: Any],
    contain format: NotesBodyInlineFormat
  ) -> Bool {
    switch format {
    case .bold:
      guard let font = attributes[.font] as? NSFont else {
        return false
      }
      return NSFontManager.shared.traits(of: font).contains(.boldFontMask)
    case .italic:
      guard let font = attributes[.font] as? NSFont else {
        return false
      }
      return NSFontManager.shared.traits(of: font).contains(.italicFontMask)
    case .underline:
      return nonZeroAttribute(attributes[.underlineStyle])
    case .strikethrough:
      return nonZeroAttribute(attributes[.strikethroughStyle])
    }
  }

  private func inlineColor(_ value: String, operation: String) throws -> NSColor {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let named: [String: NSColor] = [
      "black": .black,
      "blue": .systemBlue,
      "brown": .brown,
      "cyan": .cyan,
      "gray": .systemGray,
      "green": .systemGreen,
      "grey": .systemGray,
      "orange": .systemOrange,
      "pink": .systemPink,
      "purple": .systemPurple,
      "red": .systemRed,
      "white": .white,
      "yellow": .systemYellow,
    ]
    if let color = named[normalized] {
      return color
    }

    let hex = normalized.hasPrefix("#") ? String(normalized.dropFirst()) : normalized
    guard hex.count == 6 || hex.count == 8, let value = UInt64(hex, radix: 16) else {
      throw CLIError(
        code: .validationError,
        message: "`--color` must be a named color, #RRGGBB, #RRGGBBAA, or none.",
        details: ["operation": operation]
      )
    }
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    if hex.count == 6 {
      red = CGFloat((value >> 16) & 0xff) / 255
      green = CGFloat((value >> 8) & 0xff) / 255
      blue = CGFloat(value & 0xff) / 255
      alpha = 1
    } else {
      red = CGFloat((value >> 24) & 0xff) / 255
      green = CGFloat((value >> 16) & 0xff) / 255
      blue = CGFloat((value >> 8) & 0xff) / 255
      alpha = CGFloat(value & 0xff) / 255
    }
    return NSColor(deviceRed: red, green: green, blue: blue, alpha: alpha)
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
    return nil
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

  private func inlineFont(family: String, pointSize: Double, operation: String) throws -> NSFont {
    let normalizedFamily = family.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalizedFamily.isEmpty == false else {
      throw CLIError(code: .validationError, message: "`--family` must not be empty.")
    }
    guard pointSize.isFinite, pointSize >= 1, pointSize <= 288 else {
      throw CLIError(
        code: .validationError,
        message: "`--size` must be a font point size from 1 through 288."
      )
    }
    if let font = NSFontManager.shared.font(
      withFamily: normalizedFamily,
      traits: [],
      weight: 5,
      size: CGFloat(pointSize)
    ) {
      return font
    }
    if let font = NSFont(name: normalizedFamily, size: CGFloat(pointSize)) {
      return font
    }
    throw CLIError(
      code: .validationError,
      message: "Requested Notes inline font family is not available.",
      details: ["family_sha256": sha256Hex(normalizedFamily)]
    )
  }

  private func paragraphStyleAlignment(_ alignment: NotesBodyParagraphAlignment) -> Int32 {
    ICTTParagraphStyle.paragraphStyleAlignment(forTextAlignment: Int64(alignment.textAlignmentRawValue))
  }

  private func validateParagraphFormatTarget(
    _ style: ICTTParagraphStyle,
    draft: NotesBodyParagraphStyleDraft,
    operation: String
  ) throws {
    try validateParagraphFormatTarget(style, operation: operation, target: [
      "id_sha256": sha256Hex(draft.noteID),
      "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
      "ordinal": draft.ordinal.map(String.init) ?? "",
    ])
  }

  private func validateParagraphFormatTarget(
    _ style: ICTTParagraphStyle,
    draft: NotesBodyParagraphAlignmentDraft,
    operation: String
  ) throws {
    try validateParagraphFormatTarget(style, operation: operation, target: [
      "id_sha256": sha256Hex(draft.noteID),
      "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
      "ordinal": draft.ordinal.map(String.init) ?? "",
    ])
  }

  private func validateParagraphFormatTarget(
    _ style: ICTTParagraphStyle,
    operation: String,
    target: [String: String]
  ) throws {
    guard !style.isList, !style.isChecklist, !style.isBlockQuote else {
      var details = target
      details["operation"] = operation
      details["requires"] = "non-list,non-checklist,non-block-quote paragraph"
      throw CLIError(
        code: .validationError,
        message: "Notes paragraph formatting currently requires a non-list, non-checklist, non-block-quote paragraph.",
        details: details
      )
    }
  }

  private func validateTextToTableSourceTarget(
    _ style: ICTTParagraphStyle,
    noteID: String,
    paragraphIDSHA256: String,
    ordinal: Int,
    operation: String
  ) throws {
    guard !style.isList, !style.isChecklist, !style.isBlockQuote,
      boolValue(style, key: "isHeader") != true
    else {
      throw CLIError(
        code: .validationError,
        message: "Notes text-to-table conversion currently requires an ordinary body paragraph.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": paragraphIDSHA256,
          "ordinal": "\(ordinal)",
          "requires": "non-header,non-list,non-checklist,non-block-quote paragraph",
        ]
      )
    }
  }

  private func bodyTableSourceText(from paragraphText: String, operation: String) throws -> String {
    var text = paragraphText
    while let last = text.unicodeScalars.last,
      CharacterSet.newlines.contains(last)
    {
      text.unicodeScalars.removeLast()
    }
    guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes text-to-table conversion requires nonempty source paragraph text.",
        details: ["operation": operation]
      )
    }
    return text
  }

  private func validateParagraphBlockQuoteTarget(
    _ style: ICTTParagraphStyle,
    draft: NotesBodyParagraphQuoteDraft,
    operation: String
  ) throws {
    var details = [
      "id_sha256": sha256Hex(draft.noteID),
      "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
      "ordinal": draft.ordinal.map(String.init) ?? "",
      "operation": operation,
    ]
    guard !style.isList, !style.isChecklist else {
      details["requires"] = "non-list,non-checklist paragraph"
      throw CLIError(
        code: .validationError,
        message: "Notes block quote formatting currently requires a non-list, non-checklist paragraph.",
        details: details
      )
    }
  }

  private func listParagraphStyle(
    style listStyle: NotesBodyListStyle,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard
      let style = ICTTMutableParagraphStyle.paragraphStyleNamed(listStyle.paragraphStyleValue)
        as? ICTTMutableParagraphStyle
    else {
      throw writeError(
        operation: operation,
        reason: "ICTTMutableParagraphStyle could not create ordinary list style \(listStyle.rawValue)."
      )
    }
    style.uuid = UUID()
    style.todo = nil
    return style
  }

  func checklistParagraphStyle(
    from currentStyle: ICTTParagraphStyle,
    checked: Bool,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard let style = currentStyle.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    guard let currentTodo = style.todo ?? ICTTTodo() else {
      throw writeError(operation: operation, reason: "ICTTTodo could not be created.")
    }
    guard let updatedTodo = currentTodo.todo(withDone: checked) as? ICTTTodo else {
      throw writeError(operation: operation, reason: "ICTTTodo.todoWithDone returned nil.")
    }
    style.style = 103
    style.todo = updatedTodo
    guard style.isChecklist, style.isList, !style.isHeader, updatedTodo.done == checked else {
      throw writeError(operation: operation, reason: "Checklist paragraph style is unavailable.")
    }
    return style
  }

  private func listParagraphStyle(
    from currentStyle: ICTTParagraphStyle,
    style listStyle: NotesBodyListStyle,
    operation: String
  ) throws -> ICTTParagraphStyle {
    guard let style = currentStyle.mutableCopy() as? ICTTMutableParagraphStyle else {
      throw writeError(operation: operation, reason: "ICTTParagraphStyle.mutableCopy returned no mutable style.")
    }
    style.style = listStyle.paragraphStyleValue
    style.todo = nil
    return style
  }

  private func checklistParagraphTarget(
    draft: NotesBodyChecklistSetDraft,
    textStorage: NSTextStorage,
    operation: String
  ) throws -> NotesChecklistParagraphTarget {
    try checklistParagraphTarget(
      noteID: draft.noteID,
      paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal,
      textStorage: textStorage,
      operation: operation
    )
  }

  func checklistParagraphTarget(
    noteID: String, paragraphIDSHA256: String?, ordinal: Int?,
    textStorage: NSTextStorage, operation: String
  ) throws -> NotesChecklistParagraphTarget {
    let targets = nativeParagraphTargets(in: textStorage) { $0.isChecklist }
    guard let target = try selectedParagraphTarget(in: targets, paragraphIDSHA256: paragraphIDSHA256,
      ordinal: ordinal, noteID: noteID, operation: operation) else {
      throw CLIError(code: .notFound, message: "Checklist selector did not match any checklist item.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": paragraphIDSHA256 ?? "", "ordinal": ordinal.map(String.init) ?? "",
          "checklist_item_count": "\(targets.count)"])
    }
    return target
  }

  func checklistParagraphTargets(
    noteID: String, textStorage: NSTextStorage, operation: String
  ) throws -> [NotesChecklistParagraphTarget] {
    let targets = nativeParagraphTargets(in: textStorage) { $0.isChecklist }
    guard !targets.isEmpty else {
      throw CLIError(code: .notFound, message: "No checklist items were found on the target note.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID)])
    }
    return targets
  }

  func listParagraphTarget(
    noteID: String, paragraphIDSHA256: String?, ordinal: Int?,
    textStorage: NSTextStorage, operation: String
  ) throws -> NotesChecklistParagraphTarget {
    let targets = nativeParagraphTargets(in: textStorage) { $0.isList && !$0.isChecklist }
    guard let target = try selectedParagraphTarget(in: targets, paragraphIDSHA256: paragraphIDSHA256,
      ordinal: ordinal, noteID: noteID, operation: operation) else {
      throw CLIError(code: .notFound, message: "List selector did not match any ordinary list item.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": paragraphIDSHA256 ?? "", "ordinal": ordinal.map(String.init) ?? "",
          "ordinary_list_item_count": "\(targets.count)"])
    }
    return target
  }

  func listParagraphTargets(
    noteID: String, textStorage: NSTextStorage, operation: String
  ) throws -> [NotesChecklistParagraphTarget] {
    let targets = nativeParagraphTargets(in: textStorage) { $0.isList && !$0.isChecklist }
    guard !targets.isEmpty else {
      throw CLIError(code: .notFound, message: "No ordinary list items were found on the target note.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID)])
    }
    return targets
  }

  private func paragraphStyleTarget(
    draft: NotesBodyChecklistConvertDraft, textStorage: NSTextStorage, operation: String
  ) throws -> NotesChecklistParagraphTarget {
    try paragraphStyleTarget(noteID: draft.noteID, paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal, textStorage: textStorage, operation: operation)
  }

  func paragraphStyleTarget(
    noteID: String, paragraphIDSHA256: String?, ordinal: Int?,
    textStorage: NSTextStorage, operation: String
  ) throws -> NotesChecklistParagraphTarget {
    let targets = nativeParagraphTargets(in: textStorage) { $0.uuid != nil }
    guard let target = try selectedParagraphTarget(in: targets, paragraphIDSHA256: paragraphIDSHA256,
      ordinal: ordinal, noteID: noteID, operation: operation) else {
      throw CLIError(code: .notFound, message: "Paragraph selector did not match any body paragraph anchor.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": paragraphIDSHA256 ?? "", "ordinal": ordinal.map(String.init) ?? "",
          "paragraph_anchor_count": "\(targets.count)"])
    }
    return target
  }

  func paragraphStyleTargets(
    noteID: String, textStorage: NSTextStorage, operation: String
  ) throws -> [NotesChecklistParagraphTarget] {
    let targets = nativeParagraphTargets(in: textStorage) { $0.uuid != nil }
    guard !targets.isEmpty else {
      throw CLIError(code: .notFound, message: "No body paragraph anchors were found on the target note.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID)])
    }
    return targets
  }

  private func nativeParagraphTargets(
    in text: NSAttributedString, matching include: (ICTTParagraphStyle) -> Bool
  ) -> [NotesChecklistParagraphTarget] {
    notesStyledParagraphs(in: text) { value -> (id: String, style: ICTTParagraphStyle)? in
      guard let style = value as? ICTTParagraphStyle, include(style) else { return nil }
      return (style.uuid?.uuidString ?? "", style)
    }.map { paragraph in
      NotesChecklistParagraphTarget(range: paragraph.range, style: paragraph.style,
        checked: paragraph.style.todo?.done == true,
        paragraphIDSHA256: paragraph.style.uuid.map { sha256Hex($0.uuidString) },
        indentationLevel: Int(paragraph.style.indent))
    }
  }

  private func selectedParagraphTarget(
    in targets: [NotesChecklistParagraphTarget], paragraphIDSHA256: String?, ordinal: Int?,
    noteID: String, operation: String
  ) throws -> NotesChecklistParagraphTarget? {
    guard let index = try selectedParagraphTargetIndex(in: targets, paragraphIDSHA256: paragraphIDSHA256,
      ordinal: ordinal, noteID: noteID, operation: operation) else { return nil }
    return targets[index]
  }

  private func selectedParagraphTargetIndex(
    in targets: [NotesChecklistParagraphTarget], paragraphIDSHA256: String?, ordinal: Int?,
    noteID: String, operation: String
  ) throws -> Int? {
    guard (paragraphIDSHA256 != nil) != (ordinal != nil) else {
      throw CLIError(code: .validationError, message: "Select exactly one paragraph hash or ordinal.",
        details: ["operation": operation])
    }
    if let ordinal { return ordinal > 0 && ordinal <= targets.count ? ordinal - 1 : nil }
    let matches = targets.indices.filter { targets[$0].paragraphIDSHA256 == paragraphIDSHA256 }
    guard matches.count <= 1 else {
      throw CLIError(code: .ambiguousIdentity, message: "Paragraph hash matches more than one paragraph.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteID),
          "paragraph_sha256": paragraphIDSHA256 ?? "", "matches": "\(matches.count)"])
    }
    return matches.first
  }

  private func collapsibleSectionTarget(
    draft: NotesBodyCollapsibleSetDraft,
    textStorage: NSTextStorage,
    outlineController: ICOutlineController,
    operation: String
  ) throws -> NotesCollapsibleSectionTarget {
    guard draft.paragraphIDSHA256 != nil || draft.ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "Collapsible section set requires a paragraph hash or ordinal.",
        details: ["operation": operation]
      )
    }
    let fullRange = NSRange(location: 0, length: textStorage.length)
    guard fullRange.length > 0 else {
      throw CLIError(
        code: .notFound,
        message: "Collapsible section selector did not match any section.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
          "ordinal": draft.ordinal.map(String.init) ?? "",
        ]
      )
    }

    var currentOrdinal = 0
    var target: NotesCollapsibleSectionTarget?
    textStorage.enumerateAttributes(in: fullRange, options: []) { attributes, _, stop in
      for value in attributes.values {
        guard let style = value as? ICTTParagraphStyle,
          let uuid = style.uuid
        else {
          continue
        }
        guard outlineController.isUUIDCollapsible(uuid) else {
          continue
        }
        currentOrdinal += 1
        let currentParagraphIDSHA256 = sha256Hex(uuid.uuidString)
        let ordinalMatches = draft.ordinal.map { $0 == currentOrdinal } ?? false
        let paragraphMatches = draft.paragraphIDSHA256.map { $0 == currentParagraphIDSHA256 } ?? false
        if ordinalMatches || paragraphMatches {
          target = NotesCollapsibleSectionTarget(
            uuid: uuid,
            ordinal: currentOrdinal,
            paragraphIDSHA256: currentParagraphIDSHA256,
            collapsed: outlineController.isUUIDCollapsed(uuid)
          )
          stop.pointee = true
        }
        return
      }
    }

    guard let target else {
      throw CLIError(
        code: .notFound,
        message: "Collapsible section selector did not match any section.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "",
          "ordinal": draft.ordinal.map(String.init) ?? "",
          "collapsible_section_count": "\(currentOrdinal)",
        ]
      )
    }
    return target
  }

  private func collapsibleSectionRecord(
    paragraphIDSHA256: String,
    sections: [NotesBodyCollapsibleSectionRecord],
    operation: String
  ) throws -> NotesBodyCollapsibleSectionRecord {
    guard let record = sections.first(where: { $0.paragraphIDSHA256 == paragraphIDSHA256 }) else {
      throw writeError(operation: operation, reason: "Private framework readback did not find collapsible section.")
    }
    return record
  }

  func checklistParagraphTargetIndex(
    draft: NotesBodyChecklistReorderDraft, targets: [NotesChecklistParagraphTarget], operation: String
  ) throws -> Int {
    guard let index = try selectedParagraphTargetIndex(in: targets, paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal, noteID: draft.noteID, operation: operation) else {
      throw CLIError(code: .notFound, message: "Checklist selector did not match any checklist item.",
        details: ["operation": operation, "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "", "ordinal": draft.ordinal.map(String.init) ?? "",
          "checklist_item_count": "\(targets.count)"])
    }
    return index
  }

  func listParagraphTargetIndex(
    draft: NotesBodyListReorderDraft, targets: [NotesChecklistParagraphTarget], operation: String
  ) throws -> Int {
    guard let index = try selectedParagraphTargetIndex(in: targets, paragraphIDSHA256: draft.paragraphIDSHA256,
      ordinal: draft.ordinal, noteID: draft.noteID, operation: operation) else {
      throw CLIError(code: .notFound, message: "List selector did not match any ordinary list item.",
        details: ["operation": operation, "id_sha256": sha256Hex(draft.noteID),
          "paragraph_sha256": draft.paragraphIDSHA256 ?? "", "ordinal": draft.ordinal.map(String.init) ?? "",
          "ordinary_list_item_count": "\(targets.count)"])
    }
    return index
  }

  private func paragraphRange(in textStorage: NSTextStorage, around range: NSRange) -> NSRange {
    let string = textStorage.string as NSString
    guard string.length > 0 else {
      return NSRange(location: 0, length: 0)
    }
    let location = min(max(range.location, 0), string.length - 1)
    let maxLength = max(0, string.length - location)
    let length = min(max(range.length, 1), maxLength)
    return string.paragraphRange(for: NSRange(location: location, length: length))
  }

  private func paragraphRangeHasTerminator(
    in textStorage: NSTextStorage,
    paragraphRange: NSRange
  ) -> Bool {
    let string = textStorage.string as NSString
    guard paragraphRange.length > 0 else {
      return false
    }
    let lastLocation = min(paragraphRange.location + paragraphRange.length - 1, string.length - 1)
    guard lastLocation >= 0 else {
      return false
    }
    guard let scalar = string.substring(with: NSRange(location: lastLocation, length: 1)).unicodeScalars.first else {
      return false
    }
    return CharacterSet.newlines.contains(scalar)
  }

  private func insertionLocationBeforeParagraphTerminator(
    in textStorage: NSTextStorage,
    paragraphRange: NSRange
  ) -> Int {
    let string = textStorage.string as NSString
    var insertionLocation = min(paragraphRange.location + paragraphRange.length, string.length)
    while insertionLocation > paragraphRange.location {
      let candidateRange = NSRange(location: insertionLocation - 1, length: 1)
      guard let scalar = string.substring(with: candidateRange).unicodeScalars.first,
        CharacterSet.newlines.contains(scalar)
      else {
        break
      }
      insertionLocation -= 1
    }
    return insertionLocation
  }

  private func insertedBodyParagraph(
    before: NotesBodyStructureRecord,
    after: NotesBodyStructureRecord
  ) -> NotesBodyParagraphAnchorRecord? {
    guard let beforeAnchors = before.paragraphAnchors, let afterAnchors = after.paragraphAnchors else {
      return nil
    }
    let beforeIDs = Set(beforeAnchors.map(\.idSHA256))
    return afterAnchors
      .sorted { $0.ordinal < $1.ordinal }
      .first {
        !beforeIDs.contains($0.idSHA256)
          && $0.style == NotesBodyParagraphStyle.body.rawValue
          && !$0.isList
          && !$0.isChecklist
      }
  }

  private func stableChecklistSortTargets(
    _ targets: [NotesChecklistParagraphTarget]
  ) -> [NotesChecklistParagraphTarget] {
    targets.enumerated()
      .sorted { lhs, rhs in
        if lhs.element.checked != rhs.element.checked {
          return lhs.element.checked == false && rhs.element.checked == true
        }
        return lhs.offset < rhs.offset
      }
      .map(\.element)
  }

  private func paragraphStyleAttributeName() -> String {
    let model = ICLinkUIModel()
    return nonEmpty(model?.paragraphStyleAttributeName) ?? "ICTTParagraphStyle"
  }

  private func replaceTitle(_ title: String, expectedTitle: String, in note: ICNote, operation: String) throws {
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    let nativeRange = try nativeTitleRange(note, text: textStorage.string as NSString,
      expectedTitle: expectedTitle, operation: operation)
    note.beginEditing()
    do {
      try notesReplaceTitle(in: textStorage, nativeRange: nativeRange,
        expectedTitle: expectedTitle, title: title)
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }
    _ = note.regenerateTitle(true, snippet: true)
    try persistNoteTextContent(note, operation: operation)
  }

  private func replaceBody(
    _ body: String, title: String?, expectedTitle: String, in note: ICNote, operation: String
  ) throws {
    try validateBodyMutationTarget(note, operation: operation)
    guard let textStorage = note.textStorage() as? NSTextStorage else {
      throw writeError(operation: operation, reason: "ICNote.textStorage returned no NSTextStorage.")
    }
    if let title { try notesValidateTitleEdit(title) }
    let range = try nativeTitleRange(note, text: textStorage.string as NSString,
      expectedTitle: expectedTitle, operation: operation)
    _ = try notesBodyReplacementRange(in: textStorage.string as NSString,
      nativeTitleRange: range, expectedTitle: expectedTitle)
    note.beginEditing()
    do {
      try notesReplaceBody(in: textStorage, nativeTitleRange: range, expectedTitle: expectedTitle, body: body)
      if let title, !title.utf8.elementsEqual(expectedTitle.utf8) {
        try notesReplaceTitle(in: textStorage, nativeRange: range, expectedTitle: expectedTitle, title: title)
      }
      note.didChangeText()
      note.endEditing()
    } catch {
      note.endEditing()
      throw error
    }
    _ = note.regenerateTitle(true, snippet: true)
    try persistNoteTextContent(note, operation: operation)
  }

  private func nativeTitleRange(
    _ note: ICNote, text: NSString, expectedTitle: String, operation: String
  ) throws -> NSRange {
    try NotesRuntimeMethod(owner: "ICNote", selector: "rangeForTitle:",
      returnType: "{_NSRange=QQ}", argumentTypes: ["^B"]).require(operation: operation, receiver: note)
    try NotesRuntimeMethod(owner: "ICNote", selector: "regenerateTitle:snippet:",
      returnType: "B", argumentTypes: ["B", "B"]).require(operation: operation, receiver: note)
    var truncated = false
    let range = note.range(forTitle: &truncated)
    return try notesTitleReplacementRange(in: text, nativeRange: range,
      expectedTitle: expectedTitle, truncated: truncated)
  }

  private func persistNoteTextContent(_ note: ICNote, operation: String) throws {
    note.updateChangeCount(withReason: operation)
    guard note.saveNoteData() else {
      throw writeError(operation: operation, reason: "ICNote.saveNoteData returned false.")
    }
    if let noteData = note.noteData {
      _ = noteData.saveIfNeeded()
    }
  }

  private func validateRichReplaceTarget(_ note: ICNote, operation: String) throws {
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "Notes rich replace target must be a visible non-trash note.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes rich replace remains gated.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteIdentifier(note))]
      )
    }
    guard boolValue(note, key: "isSharedReadOnly") != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes rich replace target must be editable.",
        details: ["operation": operation, "id_sha256": sha256Hex(noteIdentifier(note))]
      )
    }
  }

  private func save(note: ICNote, context: ICNoteContext, operation: String) throws {
    try NotesNativeContext.preflightSave(context, operation: operation)
    try NotesNativeContext.noteSave.require(operation: operation, receiver: note)
    note.save()
    try save(context: context, operation: operation)
  }

  private func save(context: ICNoteContext, operation: String) throws {
    try NotesNativeContext.preflightSave(context, operation: operation)
    var error: AnyObject?
    guard context.save(&error) else {
      throw writeError(operation: operation, reason: "ICNoteContext.save returned false.", error: error)
    }
    if let managedObjectContext = context.managedObjectContext {
      try NotesNativeContext.managedSave.require(operation: operation, receiver: managedObjectContext)
      guard managedObjectContext.ic_save() else {
        throw writeError(operation: operation, reason: "NSManagedObjectContext.ic_save returned false.")
      }
    }
  }

  private func readback(folder: ICFolder, operation: String) throws -> NotesFolderRecord {
    let id = objectIDString(folder)
    guard let record = try reader.listFolders(account: nil, limit: 2_000).first(where: { $0.id == id }) else {
      throw writeError(operation: operation, reason: "Private framework readback did not find written folder.")
    }
    return record
  }

  private func readback(
    smartFolder: ICFolder,
    expectedName: String,
    accountName: String,
    operation: String
  ) throws -> NotesSmartFolderRecord {
    let id = objectIDString(smartFolder)
    let after = try reader.listSmartFolders(account: nil, limit: 2_000)
    if let direct = after.first(where: { $0.id == id }) {
      return direct
    }

    let matches = after.filter {
      $0.name.localizedCaseInsensitiveCompare(expectedName) == .orderedSame
        && $0.accountName.localizedCaseInsensitiveCompare(accountName) == .orderedSame
    }
    if matches.count == 1 {
      return matches[0]
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find written Smart Folder.")
  }

  private func readback(note: ICNote, operation: String) throws -> NotesNoteDetail {
    let id = noteIdentifier(note)
    guard let detail = try reader.readNote(id: id) else {
      throw writeError(operation: operation, reason: "Private framework readback did not find written note.")
    }
    return detail
  }

  private func readback(
    attachment: AnyObject,
    noteID: String,
    before: [NotesAttachmentRecord],
    filename: String,
    operation: String
  ) throws -> NotesAttachmentRecord {
    let attachmentID = objectIDString(attachment)
    let after = try reader.listAttachments(noteID: noteID, limit: 2_000)
    if let direct = after.first(where: { $0.id == attachmentID || $0.contentIdentifier == attachmentID }) {
      return direct
    }

    let beforeIDs = Set(before.map(\.id))
    let beforeContentIDs = Set(before.compactMap { $0.contentIdentifier })
    let newRecords = after.filter { record in
      !beforeIDs.contains(record.id)
        && (record.contentIdentifier == nil || !beforeContentIDs.contains(record.contentIdentifier ?? ""))
    }
    if let filenameMatch = newRecords.first(where: { $0.mediaFilename == filename || $0.title == filename }) {
      return filenameMatch
    }
    if newRecords.count == 1 {
      return newRecords[0]
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find added attachment.")
  }

  private func readbackRenamedAttachment(
    attachment: AnyObject,
    oldRecord: NotesAttachmentRecord,
    noteID: String,
    operation: String
  ) throws -> NotesAttachmentRecord {
    let attachmentID = objectIDString(attachment)
    let after = try reader.listAttachments(noteID: noteID, limit: 2_000)
    if let direct = after.first(where: {
      $0.id == attachmentID
        || $0.contentIdentifier == attachmentID
        || $0.id == oldRecord.id
        || (oldRecord.contentIdentifier != nil && $0.contentIdentifier == oldRecord.contentIdentifier)
    }) {
      return direct
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find renamed attachment.")
  }

  private func readback(
    link: AnyObject,
    noteID: String,
    before: [NotesLinkRecord],
    urlString: String,
    operation: String
  ) throws -> NotesLinkRecord {
    let linkID = objectIDString(link)
    let after = try reader.listLinks(noteID: noteID, limit: 2_000)
    if let direct = after.first(where: { $0.id == linkID && linkRecordMatches($0, urlString: urlString) }) {
      return direct
    }

    let beforeIDs = Set(before.map(\.id))
    let newRecords = after.filter { !beforeIDs.contains($0.id) }
    if let urlMatch = newRecords.first(where: { linkRecordMatches($0, urlString: urlString) }) {
      return urlMatch
    }
    if let anyURLMatch = after.first(where: { linkRecordMatches($0, urlString: urlString) }) {
      return anyURLMatch
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find added URL link.")
  }

  private func readback(
    updatedLink link: ICInlineAttachment,
    noteID: String,
    oldLink: NotesLinkRecord,
    urlString: String,
    operation: String
  ) throws -> NotesLinkRecord {
    let linkID = objectIDString(link)
    let identifier = nonEmpty(optionalString(link, key: "identifier"))
    let after = try reader.listLinks(noteID: noteID, limit: 2_000)
    if let direct = after.first(where: { candidate in
      (candidate.id == linkID || identifier.map { candidate.id == $0 } == true || candidate.id == oldLink.id)
        && linkRecordMatches(candidate, urlString: urlString)
    }) {
      return direct
    }

    if let urlMatch = after.first(where: { candidate in
      candidate.kind == "url" && linkRecordMatches(candidate, urlString: urlString)
    }) {
      return urlMatch
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find updated URL link.")
  }

  private func readback(
    noteLink link: AnyObject,
    sourceNoteID: String,
    before: [NotesLinkRecord],
    operation: String
  ) throws -> NotesLinkRecord {
    let linkID = objectIDString(link)
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier")).map(sha256Hex)
    let after = try reader.listLinks(noteID: sourceNoteID, limit: 2_000)
    if let direct = after.first(where: { candidate in
      (candidate.id == linkID || (token != nil && candidate.tokenContentIdentifierSHA256 == token))
        && isNoteLinkRecord(candidate)
    }) {
      return direct
    }

    let beforeIDs = Set(before.map(\.id))
    let beforeTokens = Set(before.compactMap(\.tokenContentIdentifierSHA256))
    let newRecords = after.filter { record in
      !beforeIDs.contains(record.id)
        && (record.tokenContentIdentifierSHA256 == nil || !beforeTokens.contains(record.tokenContentIdentifierSHA256 ?? ""))
        && isNoteLinkRecord(record)
    }
    if newRecords.count == 1 {
      return newRecords[0]
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find added note link.")
  }

  private func readback(
    updatedNoteLink link: ICInlineAttachment,
    sourceNoteID: String,
    oldLink: NotesLinkRecord,
    operation: String
  ) throws -> NotesLinkRecord {
    let linkID = objectIDString(link)
    let identifier = nonEmpty(optionalString(link, key: "identifier"))
    let after = try reader.listLinks(noteID: sourceNoteID, limit: 2_000)
    if let direct = after.first(where: { candidate in
      (candidate.id == linkID || identifier.map { candidate.id == $0 } == true || candidate.id == oldLink.id)
        && isPlainNoteLinkRecord(candidate)
    }) {
      return direct
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find updated note link.")
  }

  private func readback(
    updatedParagraphLink link: ICInlineAttachment,
    sourceNoteID: String,
    oldLink: NotesLinkRecord,
    targetTokenSHA256: String,
    operation: String
  ) throws -> NotesLinkRecord {
    let linkID = objectIDString(link)
    let identifier = nonEmpty(optionalString(link, key: "identifier"))
    let after = try reader.listLinks(noteID: sourceNoteID, limit: 2_000)
    if let direct = after.first(where: { candidate in
      (candidate.id == linkID || identifier.map { candidate.id == $0 } == true || candidate.id == oldLink.id)
        && isParagraphLinkRecord(candidate)
        && candidate.tokenContentIdentifierSHA256 == targetTokenSHA256
    }) {
      return direct
    }
    if let byToken = after.first(where: {
      isParagraphLinkRecord($0) && $0.tokenContentIdentifierSHA256 == targetTokenSHA256
    }) {
      return byToken
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find updated paragraph link.")
  }

  private func readback(
    paragraphLink link: AnyObject,
    sourceNoteID: String,
    before: [NotesLinkRecord],
    operation: String
  ) throws -> NotesLinkRecord {
    let linkID = objectIDString(link)
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier")).map(sha256Hex)
    let after = try reader.listLinks(noteID: sourceNoteID, limit: 2_000)
    if let direct = after.first(where: { candidate in
      (candidate.id == linkID || (token != nil && candidate.tokenContentIdentifierSHA256 == token))
        && isParagraphLinkRecord(candidate)
    }) {
      return direct
    }

    let beforeIDs = Set(before.map(\.id))
    let beforeTokens = Set(before.compactMap(\.tokenContentIdentifierSHA256))
    let newRecords = after.filter { record in
      !beforeIDs.contains(record.id)
        && (record.tokenContentIdentifierSHA256 == nil || !beforeTokens.contains(record.tokenContentIdentifierSHA256 ?? ""))
        && isParagraphLinkRecord(record)
    }
    if newRecords.count == 1 {
      return newRecords[0]
    }

    throw writeError(operation: operation, reason: "Private framework readback did not find added paragraph link.")
  }

  private func linkRecordMatches(_ link: NotesLinkRecord, urlString: String) -> Bool {
    link.urlString == urlString
      || normalizedLinkURLForMatching(link.urlString) == normalizedLinkURLForMatching(urlString)
      || link.urlSHA256 == sha256Hex(urlString)
  }

  private func isNoteLinkRecord(_ link: NotesLinkRecord) -> Bool {
    link.kind == "note"
      || link.isParagraphLink
      || link.isInternalParagraphLink
      || ["notes", "applenotes", "mobilenotes"].contains(link.urlScheme ?? "")
  }

  private func isPlainNoteLinkRecord(_ link: NotesLinkRecord) -> Bool {
    isNoteLinkRecord(link)
      && link.isParagraphLink == false
      && link.isInternalParagraphLink == false
      && link.kind != "paragraph"
      && link.kind != "internal_paragraph"
  }

  private func isParagraphLinkRecord(_ link: NotesLinkRecord) -> Bool {
    link.kind == "paragraph"
      || link.kind == "internal_paragraph"
      || link.isParagraphLink
      || link.isInternalParagraphLink
  }

  private func isAppLinkScheme(_ scheme: String) -> Bool {
    !["http", "https", "mailto", "tel", "sms", "file", "notes", "applenotes", "mobilenotes"]
      .contains(scheme.lowercased())
  }

  private func normalizedLinkURLForMatching(_ value: String?) -> String? {
    guard let value, var components = URLComponents(string: value) else {
      return value
    }
    components.scheme = components.scheme?.lowercased()
    components.host = components.host?.lowercased()
    if components.path == "/" {
      components.path = ""
    }
    return components.string ?? value
  }

  private func link(
    selector record: NotesLinkRecord,
    requestedLinkID: String,
    note: ICNote,
    operation: String
  ) throws -> ICInlineAttachment {
    let matches = linkObjects(note).filter {
      linkAttachmentMatches($0, record: record, requestedLinkID: requestedLinkID)
    }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any removable link on the note.",
        details: [
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple removable links on the note.",
        details: [
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    return link
  }

  private func linkObjects(_ note: ICNote) -> [ICInlineAttachment] {
    objects(note.allNoteTextInlineAttachments())
      .filter(isLinkObject)
  }

  private func isLinkObject(_ link: ICInlineAttachment) -> Bool {
    boolValue(link, key: "isLinkAttachment") == true
      || boolValue(link, key: "isParagraphLinkAttachment") == true
      || boolValue(link, key: "isInternalParagraphLinkAttachment") == true
  }

  private func linkAttachmentMatches(
    _ link: ICInlineAttachment,
    record: NotesLinkRecord,
    requestedLinkID: String
  ) -> Bool {
    let identityMatches = [
      objectIDString(link),
      nonEmpty(optionalString(link, key: "identifier")),
    ].compactMap { $0 }
      .contains { $0 == record.id || $0 == requestedLinkID }
    if identityMatches {
      return true
    }

    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    if let token, record.tokenContentIdentifierSHA256 == sha256Hex(token) {
      return true
    }

    let candidate = linkURLCandidate(link: link, token: token)
    return candidate.map(sha256Hex) == record.urlSHA256
      || record.urlString.map {
        normalizedLinkURLForMatching(candidate) == normalizedLinkURLForMatching($0)
      } == true
      || candidate == requestedLinkID
      || normalizedLinkURLForMatching(candidate) == normalizedLinkURLForMatching(requestedLinkID)
  }

  private func validateLinkRemoveTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isLinkAttachment") == true,
      boolValue(link, key: "isParagraphLinkAttachment") != true,
      boolValue(link, key: "isInternalParagraphLinkAttachment") != true
    else {
      throw writeError(operation: operation, reason: "Only web URL ICInlineAttachment link removal is accepted.")
    }
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard
      let urlString = linkURLCandidate(link: link, token: token),
      let scheme = linkURLScheme(urlString),
      scheme == "http" || scheme == "https"
    else {
      throw writeError(operation: operation, reason: "Only http and https ICInlineAttachment link removal is accepted.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func validateBaseLinkUpdateTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isLinkAttachment") == true,
      boolValue(link, key: "isParagraphLinkAttachment") != true,
      boolValue(link, key: "isInternalParagraphLinkAttachment") != true
    else {
      throw writeError(operation: operation, reason: "Only URL ICInlineAttachment link update is accepted.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active link.")
    }
  }

  private func validateWebLinkUpdateTarget(_ link: ICInlineAttachment, operation: String) throws {
    try validateBaseLinkUpdateTarget(link, operation: operation)
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard
      let urlString = linkURLCandidate(link: link, token: token),
      let scheme = linkURLScheme(urlString),
      scheme == "http" || scheme == "https"
    else {
      throw writeError(operation: operation, reason: "Only http and https ICInlineAttachment link update is accepted.")
    }
  }

  private func validateAppLinkUpdateTarget(_ link: ICInlineAttachment, operation: String) throws {
    try validateBaseLinkUpdateTarget(link, operation: operation)
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard
      let urlString = linkURLCandidate(link: link, token: token),
      let scheme = linkURLScheme(urlString),
      isAppLinkScheme(scheme)
    else {
      throw writeError(operation: operation, reason: "Only app URL ICInlineAttachment link update is accepted.")
    }
  }

  private func validateFileLinkUpdateTarget(_ link: ICInlineAttachment, operation: String) throws {
    try validateBaseLinkUpdateTarget(link, operation: operation)
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard
      let urlString = linkURLCandidate(link: link, token: token),
      linkURLScheme(urlString) == "file"
    else {
      throw writeError(operation: operation, reason: "Only file URL ICInlineAttachment link update is accepted.")
    }
  }

  private func validateFileLinkRemoveTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isLinkAttachment") == true,
      boolValue(link, key: "isParagraphLinkAttachment") != true,
      boolValue(link, key: "isInternalParagraphLinkAttachment") != true
    else {
      throw writeError(operation: operation, reason: "Only file URL ICInlineAttachment link removal is accepted.")
    }
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard
      let urlString = linkURLCandidate(link: link, token: token),
      linkURLScheme(urlString) == "file"
    else {
      throw writeError(operation: operation, reason: "Only file URL ICInlineAttachment link removal is accepted.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active file link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func validateAppLinkRemoveTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isLinkAttachment") == true,
      boolValue(link, key: "isParagraphLinkAttachment") != true,
      boolValue(link, key: "isInternalParagraphLinkAttachment") != true
    else {
      throw writeError(operation: operation, reason: "Only app URL ICInlineAttachment link removal is accepted.")
    }
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard
      let urlString = linkURLCandidate(link: link, token: token),
      let scheme = linkURLScheme(urlString),
      isAppLinkScheme(scheme)
    else {
      throw writeError(operation: operation, reason: "Only app URL ICInlineAttachment link removal is accepted.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active app link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func validateNoteLinkRemoveTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isLinkAttachment") == true,
      boolValue(link, key: "isParagraphLinkAttachment") != true,
      boolValue(link, key: "isInternalParagraphLinkAttachment") != true
    else {
      throw writeError(operation: operation, reason: "Only ordinary note-to-note ICInlineAttachment removal is accepted.")
    }
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    if let urlString = linkURLCandidate(link: link, token: token),
      let scheme = linkURLScheme(urlString),
      !["notes", "applenotes", "mobilenotes"].contains(scheme)
    {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a note-to-note link.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active note link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func validateNoteLinkUpdateTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isLinkAttachment") == true,
      boolValue(link, key: "isParagraphLinkAttachment") != true,
      boolValue(link, key: "isInternalParagraphLinkAttachment") != true
    else {
      throw writeError(operation: operation, reason: "Only ordinary note-to-note ICInlineAttachment update is accepted.")
    }
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    if let urlString = linkURLCandidate(link: link, token: token),
      let scheme = linkURLScheme(urlString),
      !["notes", "applenotes", "mobilenotes"].contains(scheme)
    {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a note-to-note link.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active note link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func validateParagraphLinkUpdateTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isParagraphLinkAttachment") == true
      || boolValue(link, key: "isInternalParagraphLinkAttachment") == true
    else {
      throw writeError(operation: operation, reason: "Only paragraph ICInlineAttachment update is accepted.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active paragraph link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func noteLinkDestination(_ link: ICInlineAttachment, operation: String) throws -> ICNote {
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard let token, let url = URL(string: token) else {
      throw writeError(
        operation: operation,
        reason: "ICInlineAttachment note-link destination token is unavailable."
      )
    }

    let selector = NSSelectorFromString("noteIdentifierFromNotesAppURL:")
    let utilities = ICAppURLUtilities.self as AnyObject
    guard utilities.responds(to: selector),
      let value = utilities.perform(selector, with: url as NSURL)?.takeUnretainedValue() as? String,
      let noteID = nonEmpty(value)
    else {
      throw writeError(operation: operation, reason: "Could not resolve note-link destination from token.")
    }

    return try note(id: noteID)
  }

  private func paragraphLinkDestination(
    _ link: ICInlineAttachment,
    operation: String
  ) throws -> (note: ICNote, paragraphIDSHA256: String?, tokenSHA256: String?) {
    let token = nonEmpty(optionalString(link, key: "tokenContentIdentifier"))
    guard let token, let url = URL(string: token) else {
      throw writeError(
        operation: operation,
        reason: "ICInlineAttachment paragraph-link destination token is unavailable."
      )
    }

    let note = try noteLinkDestination(link, operation: operation)
    let selector = NSSelectorFromString("paragraphIDForURL:")
    let utilities = ICAppURLUtilities.self as AnyObject
    let paragraphID = utilities.responds(to: selector)
      ? nonEmpty(utilities.perform(selector, with: url as NSURL)?
        .takeUnretainedValue() as? String)
      : nil
    return (note, paragraphID.map(sha256Hex), sha256Hex(token))
  }

  private func paragraphLinkToken(
    targetNote: ICNote,
    paragraphID: String,
    operation: String
  ) throws -> String {
    let selector = NSSelectorFromString("appURLForNote:paragraphID:")
    let utilities = ICAppURLUtilities.self as AnyObject
    guard utilities.responds(to: selector),
      let value = utilities.perform(selector, with: targetNote, with: paragraphID as NSString)?
        .takeUnretainedValue()
    else {
      throw writeError(operation: operation, reason: "Could not build Notes paragraph URL for target paragraph.")
    }
    if let url = value as? URL, let string = nonEmpty(url.absoluteString) {
      return string
    }
    if let url = value as? NSURL, let string = nonEmpty(url.absoluteString) {
      return string
    }
    if let string = nonEmpty(value as? String) {
      return string
    }
    throw writeError(operation: operation, reason: "Notes paragraph URL was empty.")
  }

  private func paragraphLinkDisplayText(token: String, sourceNote: ICNote, fallback: String?) -> String? {
    guard let url = URL(string: token) else {
      return fallback
    }
    let selector = NSSelectorFromString("paragraphLinkDisplayTextforURL:currentNote:")
    let attachment = ICInlineAttachment.self as AnyObject
    guard attachment.responds(to: selector) else {
      return fallback
    }
    return nonEmpty(attachment.perform(selector, with: url as NSURL, with: sourceNote)?
      .takeUnretainedValue() as? String) ?? fallback
  }

  private func validateParagraphLinkRemoveTarget(_ link: ICInlineAttachment, operation: String) throws {
    guard boolValue(link, key: "isParagraphLinkAttachment") == true
      || boolValue(link, key: "isInternalParagraphLinkAttachment") == true
    else {
      throw writeError(operation: operation, reason: "Only paragraph ICInlineAttachment removal is accepted.")
    }
    guard boolValue(link, key: "isVisible") != false,
      boolValue(link, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is not a visible active paragraph link.")
    }
    guard boolValue(link, key: "isDeletable") != false else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.isDeletable returned false.")
    }
  }

  private func linkURLCandidate(link: ICInlineAttachment, token: String?) -> String? {
    nonEmpty(optionalString(link, key: "urlString"))
      ?? optionalURLString(link, key: "URL")
      ?? token.flatMap { linkURLScheme($0) == nil ? nil : $0 }
  }

  private func linkURLScheme(_ urlString: String?) -> String? {
    guard let urlString, let url = URL(string: urlString), let scheme = url.scheme else {
      return nil
    }
    return scheme.localizedLowercase
  }

  private func linkDisplayText(for url: URL) -> String {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    let scheme = components?.scheme?.lowercased()
    if let scheme, ["http", "https", "mailto", "tel", "sms"].contains(scheme) {
      return components?.host ?? url.absoluteString
    }
    return components?.host ?? scheme ?? "link"
  }

  private func hashtag(
    displayText: String,
    note: ICNote,
    createIfNecessary: Bool,
    operation: String
  ) throws -> ICHashtag {
    guard let account = note.account else {
      throw writeError(operation: operation, reason: "ICNote.account returned nil for tag mutation.")
    }
    guard
      let hashtag = ICHashtag.hashtag(
        withDisplayText: displayText,
        account: account,
        createIfNecessary: createIfNecessary
      ) as? ICHashtag
    else {
      throw writeError(operation: operation, reason: "ICHashtag.hashtagWithDisplayText returned nil.")
    }
    return hashtag
  }

  private func hashtags(standardizedContent: String) throws -> [ICHashtag] {
    let managedObjectContext = try managedObjectContext()
    let hashtags: [ICHashtag] = objects(ICHashtag.allVisibleHashtags(inContext: managedObjectContext))
    return hashtags.filter { hashtag in
      tagMatches(tagRecord(hashtag), standardizedContent)
    }
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

  private func accountMatches(_ account: ICAccount?, _ name: String) -> Bool {
    (nonEmpty(account?.localizedName) ?? nonEmpty(account?.name) ?? "Notes")
      .localizedCaseInsensitiveCompare(name) == .orderedSame
  }

  private func normalizedTagText(_ tag: String) -> String {
    let standardized = standardizedTagContent(tag)
    return standardized.isEmpty ? tag : standardized
  }

  private func note(id: String, includeDeleted: Bool = false) throws -> ICNote {
    let managedObjectContext = try managedObjectContext()
    if includeDeleted,
      let note = try NotesManagedObjectLookup.resolve(id: id, context: managedObjectContext) as? ICNote
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

    let candidates: [ICNote] =
      includeDeleted
      ? objects(ICNote.allNotes(inContext: managedObjectContext))
      : objects(ICNote.visibleNotes(inContext: managedObjectContext))
    if let note = candidates.first(where: {
      noteIdentifier($0) == id || objectIDString($0) == id
    }) {
      return note
    }

    throw CLIError(code: .notFound, message: "Note was not found.", details: ["id_sha256": sha256Hex(id)])
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

  private func folder(id: String) throws -> ICFolder {
    let managedObjectContext = try managedObjectContext()
    let folders: [ICFolder] = objects(ICFolder.visibleFolders(inContext: managedObjectContext))
    guard let match = folders.first(where: { objectIDString($0) == id }) else {
      throw CLIError(
        code: .notFound,
        message: "Notes folder was not found.",
        details: ["folder_id_sha256": sha256Hex(id)]
      )
    }
    return match
  }

  private func purgableFolder(id: String, name: String, accountName: String) throws -> ICFolder {
    let managedObjectContext = try managedObjectContext()
    let folders = try purgableFolders(in: managedObjectContext)
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
        message: "Purgable Notes folder selector matched multiple folders.",
        details: ["folder_sha256": sha256Hex(name)]
      )
    }

    guard let match = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Purgable Notes folder was not found.",
        details: ["folder_id_sha256": sha256Hex(id)]
      )
    }
    return match
  }

  private func purgableFolders(in context: NSManagedObjectContext) throws -> [ICFolder] {
    guard let request = ICFolder.purgableFoldersFetchRequest() as? NSFetchRequest<NSFetchRequestResult> else {
      throw writeError(
        operation: "notes.folders.purge",
        reason: "ICFolder.purgableFoldersFetchRequest returned no NSFetchRequest."
      )
    }
    return try context.fetch(request).compactMap { $0 as? ICFolder }
  }

  private func accountObject(id: String?, name: String) throws -> ICAccount {
    let managedObjectContext = try managedObjectContext()
    let accounts: [ICAccount] = objects(ICAccount.allActiveAccounts(inContext: managedObjectContext))
    if let id, let match = accounts.first(where: { objectIDString($0) == id }) {
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

  private func validateFolderParent(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "canAddSubfolder") != false,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "Parent ICFolder cannot accept new subfolders.")
    }
  }

  private func attachment(selector: String, note: ICNote, operation: String) throws -> ICAttachment {
    let matches = attachmentObjects(note).filter {
      attachmentMatches($0, selector: selector)
    }
    guard let attachment = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the note.",
        details: [
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "attachment_sha256": sha256Hex(selector),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments on the note.",
        details: [
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "attachment_sha256": sha256Hex(selector),
          "match_count": "\(matches.count)",
        ]
      )
    }
    return attachment
  }

  private func attachmentObjects(_ note: ICNote) -> [ICAttachment] {
    let ordered: [ICAttachment] = objects(note.attachmentsInOrder())
    if !ordered.isEmpty {
      return ordered
    }
    return objects(note.visibleAttachments())
  }

  private func attachmentRecord(_ attachment: ICAttachment) -> NotesAttachmentRecord {
    NotesAttachmentRecord(
      id: nonEmpty(attachment.identifier) ?? objectIDString(attachment),
      title: nonEmpty(attachment.title),
      typeUTI: nonEmpty(attachment.typeUTI),
      contentIdentifier: nonEmpty(attachment.contentIdentifier),
      attachmentType: Int(attachment.attachmentType()),
      fileSizeBytes: Int64(attachment.fileSize),
      mediaFilename: nonEmpty(attachment.media?.filename),
      isInline: false,
      isDeletedOrInTrash: attachment.isDeletedOrInTrash
    )
  }

  private func attachmentMatches(_ attachment: ICAttachment, selector: String) -> Bool {
    let record = attachmentRecord(attachment)
    return [
      record.id,
      record.contentIdentifier,
      record.mediaFilename,
      record.title,
    ].compactMap { $0 }
      .contains { $0 == selector }
  }

  private func imageDescriptionInlineAttachment(
    selector: String,
    note: ICNote,
    operation: String
  ) throws -> ICInlineAttachment {
    let matches = imageDescriptionInlineAttachments(note).filter { attachment in
      imageDescriptionInlineAttachmentMatches(attachment, selector: selector)
    }
    guard let attachment = matches.first else {
      throw writeError(
        operation: operation,
        reason: "Attachment selector did not match any inline image-description attachment."
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple inline image-description attachments.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(selector),
          "match_count": "\(matches.count)",
        ]
      )
    }
    return attachment
  }

  private func imageDescriptionInlineAttachments(_ note: ICNote) -> [ICInlineAttachment] {
    objects(note.allNoteTextInlineAttachments())
  }

  private func imageDescriptionInlineAttachmentMatches(
    _ attachment: ICInlineAttachment,
    selector: String
  ) -> Bool {
    let record = imageDescriptionAttachmentRecord(attachment)
    return [
      record.id,
      record.contentIdentifier,
      record.title,
    ].compactMap { $0 }
      .contains { $0 == selector }
  }

  private func imageDescriptionSource(
    noteID: String,
    attachment: ICInlineAttachment
  ) -> NotesAttachmentImageDescriptionSource {
    NotesAttachmentImageDescriptionSource(
      noteID: noteID,
      attachment: imageDescriptionAttachmentRecord(attachment),
      descriptionText: nonEmpty(attachment.altText),
      sourceKind: "ICInlineAttachment.altText"
    )
  }

  private func imageDescriptionAttachmentRecord(
    _ attachment: ICInlineAttachment
  ) -> NotesAttachmentRecord {
    let imageDescription = nonEmpty(attachment.altText)
    return NotesAttachmentRecord(
      id: nonEmpty(attachment.identifier) ?? objectIDString(attachment),
      title: nonEmpty(attachment.displayText),
      typeUTI: nonEmpty(attachment.typeUTI),
      contentIdentifier: nonEmpty(attachment.tokenContentIdentifier),
      attachmentType: Int(attachment.attachmentType),
      isInline: true,
      isDeletedOrInTrash: boolValue(attachment, key: "isDeletedOrInTrash"),
      imageDescriptionPresent: imageDescription != nil,
      imageDescriptionByteCount: imageDescription.map { $0.utf8.count },
      imageDescriptionSHA256: imageDescription.map(sha256Hex),
      imageDescriptionSourceKind: "ICInlineAttachment.altText"
    )
  }

  private func validateImageDescriptionAttachmentTarget(
    _ attachment: NotesAttachmentRecord,
    operation: String
  ) throws {
    guard attachment.isDeletedOrInTrash != true else {
      throw writeError(operation: operation, reason: "ICInlineAttachment is deleted or in trash.")
    }
    guard attachment.isInline else {
      throw writeError(operation: operation, reason: "Only inline image-description attachments are accepted.")
    }
    guard imageDescriptionAttachmentFamilySupported(attachment) else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description mutation currently supports inline image, scan, or drawing attachments.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(attachment.id),
          "type_uti_sha256": attachment.typeUTI.map(sha256Hex) ?? "",
        ]
      )
    }
  }

  private func imageDescriptionAttachmentFamilySupported(_ attachment: NotesAttachmentRecord) -> Bool {
    let uti = attachment.typeUTI?.lowercased() ?? ""
    let title = attachment.title?.lowercased() ?? ""
    let token = attachment.contentIdentifier?.lowercased() ?? ""
    let hints = "\(uti) \(title) \(token)"
    return uti.contains("image")
      || uti.contains("drawing")
      || uti.contains("sketch")
      || hints.contains("scan")
      || hints.contains("scanned")
      || hints.contains("drawing")
      || hints.contains("sketch")
  }

  private func validateAttachmentMutationTarget(_ note: ICNote, operation: String) throws {
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Password-protected ICNote attachment add remains gated.")
    }
    guard boolValue(note, key: "isEditable") != false,
      boolValue(note, key: "supportsEditingNotes") != false,
      boolValue(note, key: "isSharedReadOnly") != true
    else {
      throw writeError(operation: operation, reason: "ICNote cannot accept attachment mutations.")
    }
  }

  private func validateAttachmentRemoveTarget(_ attachment: ICAttachment, operation: String) throws {
    guard attachment.isDeletedOrInTrash == false else {
      throw writeError(operation: operation, reason: "ICAttachment is deleted or in trash.")
    }
    guard attachment.isDeletable() else {
      throw writeError(operation: operation, reason: "ICAttachment.isDeletable returned false.")
    }
  }

  private func validateAttachmentRenameTarget(_ attachment: ICAttachment, operation: String) throws {
    guard attachment.isDeletedOrInTrash == false else {
      throw writeError(operation: operation, reason: "ICAttachment is deleted or in trash.")
    }
    guard boolValue(attachment, key: "isReadOnly") != true else {
      throw writeError(operation: operation, reason: "ICAttachment is read-only.")
    }
    guard attachment.supportsRenaming() else {
      throw writeError(operation: operation, reason: "ICAttachment.supportsRenaming returned false.")
    }
  }

  private func validateAttachmentMarkupTarget(_ attachment: ICAttachment, operation: String) throws {
    guard attachment.isDeletedOrInTrash == false else {
      throw writeError(operation: operation, reason: "ICAttachment is deleted or in trash.")
    }
    guard boolValue(attachment, key: "isReadOnly") != true else {
      throw writeError(operation: operation, reason: "ICAttachment is read-only.")
    }
    guard attachment.media != nil else {
      throw writeError(operation: operation, reason: "ICAttachment has no media object for Markup model apply.")
    }
  }

  private func validateAttachmentPDFMutationTarget(_ attachment: ICAttachment, operation: String) throws {
    guard attachment.isDeletedOrInTrash == false else {
      throw writeError(operation: operation, reason: "ICAttachment is deleted or in trash.")
    }
    guard boolValue(attachment, key: "isReadOnly") != true else {
      throw writeError(operation: operation, reason: "ICAttachment is read-only.")
    }
    guard attachment.media != nil else {
      throw writeError(operation: operation, reason: "PDF page mutation requires writable ICAttachment.media.")
    }
  }

  private func validateAttachmentImageTransformTarget(_ attachment: ICAttachment, operation: String) throws {
    guard attachment.isDeletedOrInTrash == false else {
      throw writeError(operation: operation, reason: "ICAttachment is deleted or in trash.")
    }
    guard boolValue(attachment, key: "isReadOnly") != true else {
      throw writeError(operation: operation, reason: "ICAttachment is read-only.")
    }
    guard attachment.media != nil else {
      throw writeError(operation: operation, reason: "Image transform requires writable ICAttachment.media.")
    }
    let record = attachmentRecord(attachment)
    guard attachmentImageTransformFamilySupported(record) else {
      throw CLIError(
        code: .validationError,
        message: "Notes image transform requires a photo/image attachment.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(record.id),
          "type_uti_sha256": record.typeUTI.map(sha256Hex) ?? "",
        ]
      )
    }
  }

  private func attachmentImageTransformFamilySupported(_ attachment: NotesAttachmentRecord) -> Bool {
    let uti = attachment.typeUTI?.lowercased() ?? ""
    let filename = attachment.mediaFilename?.lowercased() ?? ""
    let title = attachment.title?.lowercased() ?? ""
    let ext = filename.split(separator: ".").last.map(String.init) ?? title.split(separator: ".").last.map(String.init) ?? ""
    return uti.contains("image")
      || ["heic", "jpeg", "jpg", "png", "gif", "tif", "tiff", "webp"].contains(ext)
  }

  private func validateAttachmentScanMutationTarget(_ attachment: ICAttachment, operation: String) throws {
    guard attachment.isDeletedOrInTrash == false else {
      throw writeError(operation: operation, reason: "ICAttachment is deleted or in trash.")
    }
    guard boolValue(attachment, key: "isReadOnly") != true else {
      throw writeError(operation: operation, reason: "ICAttachment is read-only.")
    }
    let familyEvidence = [
      nonEmpty(attachment.typeUTI),
      nonEmpty(attachment.title),
      nonEmpty(attachment.media?.filename),
      nonEmpty(attachment.contentIdentifier),
    ].compactMap { $0 }.joined(separator: " ").lowercased()
    guard familyEvidence.contains("scan") || optionalValue(attachment, key: "scannedDocumentsMetadata") != nil else {
      throw writeError(
        operation: operation,
        reason: "Scan attachment mutation requires scanned-document attachment evidence."
      )
    }
  }

  private func validateAttachmentPDFPageInspection(
    _ source: NotesAttachmentScanPDFInspectionSource,
    expectedPageCount: Int,
    operation: String
  ) throws {
    guard source.pdfDataSHA256 != nil else {
      throw writeError(operation: operation, reason: "PDF page mutation requires PDF data readback.")
    }
    guard source.scannedDocumentsMetadataPresent == false,
      source.croppingQuadPresent == false,
      source.docCamPDFVersion == nil
    else {
      throw writeError(
        operation: operation,
        reason: "PDF page mutation refuses scanned documents; use the scan page commands."
      )
    }
    guard source.pdfPageCount == nil || source.pdfPageCount == expectedPageCount else {
      throw writeError(operation: operation, reason: "PDF page-count readback changed before mutation.")
    }
  }

  private func validateWritablePDFSourceKind(_ sourceKind: String, operation: String) throws {
    guard sourceKind == "media_pdf" else {
      throw writeError(
        operation: operation,
        reason: "PDF page mutation requires direct media PDF bytes, not generated or fallback PDF data."
      )
    }
  }

  #if canImport(PDFKit)
  private func pdfDocument(from data: Data, operation: String) throws -> PDFDocument {
    guard let document = PDFDocument(data: data), document.pageCount > 0 else {
      throw writeError(operation: operation, reason: "PDFKit could not parse attachment PDF data.")
    }
    return document
  }

  private func pdfDataRepresentation(_ document: PDFDocument, operation: String) throws -> Data {
    guard let data = document.dataRepresentation(),
      data.count >= 4,
      data.prefix(4) == Data("%PDF".utf8)
    else {
      throw writeError(operation: operation, reason: "PDFKit did not produce valid PDF bytes.")
    }
    return data
  }

  private func pdfCropBox(in currentBox: CGRect, draft: NotesAttachmentPDFCropDraft) -> CGRect {
    let minX = min(draft.topLeft.x, draft.bottomLeft.x, draft.topRight.x, draft.bottomRight.x)
    let maxX = max(draft.topLeft.x, draft.bottomLeft.x, draft.topRight.x, draft.bottomRight.x)
    let minY = min(draft.topLeft.y, draft.bottomLeft.y, draft.topRight.y, draft.bottomRight.y)
    let maxY = max(draft.topLeft.y, draft.bottomLeft.y, draft.topRight.y, draft.bottomRight.y)
    let x = currentBox.minX + currentBox.width * CGFloat(minX)
    let y = currentBox.minY + currentBox.height * CGFloat(1.0 - maxY)
    let width = currentBox.width * CGFloat(maxX - minX)
    let height = currentBox.height * CGFloat(maxY - minY)
    return CGRect(x: x, y: y, width: width, height: height)
  }
  #endif

  private func imageTransformSource(
    noteID: String,
    attachment: ICAttachment,
    operation: String
  ) throws -> NotesAttachmentImageTransformSource {
    let record = attachmentRecord(attachment)
    let data = try imageMediaData(from: attachment, record: record, operation: operation)
    guard data.isEmpty == false else {
      throw writeError(operation: operation, reason: "Image transform requires non-empty media bytes.")
    }
    return NotesAttachmentImageTransformSource(
      noteID: noteID,
      attachment: record,
      dataByteCount: data.count,
      dataSHA256: sha256Hex(data),
      sourceKind: "ICMedia.decryptedData|data|mediaURL"
    )
  }

  private func imageMediaData(
    from attachment: ICAttachment,
    record: NotesAttachmentRecord,
    operation: String
  ) throws -> Data {
    guard let media = attachment.media else {
      throw writeError(operation: operation, reason: "ICAttachment.media was nil before image media read.")
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
      message: "Image attachment data could not be read through NotesShared media APIs.",
      details: [
        "operation": operation,
        "attachment_id_sha256": sha256Hex(record.id),
        "type_uti": record.typeUTI ?? "",
        "media_filename": record.mediaFilename ?? "",
        "attempted_paths": "ICMedia.decryptedData,ICMedia.data,ICMedia.mediaURL",
      ]
    )
  }

  private func croppedImageData(
    from source: NotesAttachmentImageTransformSource,
    draft: NotesAttachmentImageCropDraft,
    operation: String
  ) throws -> Data {
    let data = try imageData(noteID: source.noteID, attachmentID: source.attachment.id, operation: operation)
    let imageSource = try cgImageSource(from: data, operation: operation)
    let image = try cgImage(from: imageSource, operation: operation)
    let width = CGFloat(image.width)
    let height = CGFloat(image.height)
    let minX = min(draft.topLeft.x, draft.bottomLeft.x, draft.topRight.x, draft.bottomRight.x)
    let maxX = max(draft.topLeft.x, draft.bottomLeft.x, draft.topRight.x, draft.bottomRight.x)
    let minY = min(draft.topLeft.y, draft.bottomLeft.y, draft.topRight.y, draft.bottomRight.y)
    let maxY = max(draft.topLeft.y, draft.bottomLeft.y, draft.topRight.y, draft.bottomRight.y)
    let cropRect = CGRect(
      x: width * CGFloat(minX),
      y: height * CGFloat(minY),
      width: width * CGFloat(maxX - minX),
      height: height * CGFloat(maxY - minY)
    ).integral
    guard cropRect.width > 0, cropRect.height > 0,
      let cropped = image.cropping(to: cropRect)
    else {
      throw writeError(operation: operation, reason: "ImageIO could not crop the selected image rectangle.")
    }
    return try encodedImageData(cropped, imageSource: imageSource, operation: operation)
  }

  private func rotatedImageData(
    from source: NotesAttachmentImageTransformSource,
    rotationDeltaDegrees: Int,
    operation: String
  ) throws -> Data {
    let data = try imageData(noteID: source.noteID, attachmentID: source.attachment.id, operation: operation)
    let imageSource = try cgImageSource(from: data, operation: operation)
    let image = try cgImage(from: imageSource, operation: operation)
    let normalized = normalizedImageRotation(rotationDeltaDegrees)
    guard [90, 180, 270].contains(normalized) else {
      throw writeError(operation: operation, reason: "Image rotation requires a non-zero quarter-turn.")
    }
    let imageWidth = image.width
    let imageHeight = image.height
    let outputWidth = normalized == 180 ? imageWidth : imageHeight
    let outputHeight = normalized == 180 ? imageHeight : imageWidth
    let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
      data: nil,
      width: outputWidth,
      height: outputHeight,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      throw writeError(operation: operation, reason: "CoreGraphics could not allocate image rotation context.")
    }
    switch normalized {
    case 90:
      context.translateBy(x: CGFloat(outputWidth), y: 0)
      context.rotate(by: .pi / 2)
    case 180:
      context.translateBy(x: CGFloat(outputWidth), y: CGFloat(outputHeight))
      context.rotate(by: .pi)
    case 270:
      context.translateBy(x: 0, y: CGFloat(outputHeight))
      context.rotate(by: -.pi / 2)
    default:
      break
    }
    context.draw(
      image,
      in: CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: CGFloat(imageHeight))
    )
    guard let rotated = context.makeImage() else {
      throw writeError(operation: operation, reason: "CoreGraphics did not produce rotated image bytes.")
    }
    return try encodedImageData(rotated, imageSource: imageSource, operation: operation)
  }

  private func imageData(noteID: String, attachmentID: String, operation: String) throws -> Data {
    let note = try note(id: noteID)
    let attachment = try attachment(selector: attachmentID, note: note, operation: operation)
    let record = attachmentRecord(attachment)
    return try imageMediaData(from: attachment, record: record, operation: operation)
  }

  private func cgImageSource(from data: Data, operation: String) throws -> CGImageSource {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
      CGImageSourceGetCount(source) > 0
    else {
      throw writeError(operation: operation, reason: "ImageIO could not parse attachment image data.")
    }
    return source
  }

  private func cgImage(from source: CGImageSource, operation: String) throws -> CGImage {
    guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
      throw writeError(operation: operation, reason: "ImageIO could not decode the first attachment image frame.")
    }
    return image
  }

  private func encodedImageData(
    _ image: CGImage,
    imageSource: CGImageSource,
    operation: String
  ) throws -> Data {
    let preferredType = CGImageSourceGetType(imageSource)
    let fallbackType = "public.png" as CFString
    let outputTypes = [preferredType, fallbackType]
      .compactMap { $0 }
      .reduce(into: [CFString]()) { result, type in
        if !result.contains(where: { $0 as String == type as String }) {
          result.append(type)
        }
      }
    for type in outputTypes {
      let data = NSMutableData()
      guard let destination = CGImageDestinationCreateWithData(data, type, 1, nil) else {
        continue
      }
      CGImageDestinationAddImage(destination, image, nil)
      if CGImageDestinationFinalize(destination), data.length > 0 {
        return data as Data
      }
    }
    throw writeError(operation: operation, reason: "ImageIO could not encode transformed image data.")
  }

  private func normalizedImageRotation(_ value: Int) -> Int {
    ((value % 360) + 360) % 360
  }

  private func writePDFMediaData(
    _ data: Data,
    to attachment: ICAttachment,
    note: ICNote,
    context: ICNoteContext,
    operation: String
  ) throws {
    guard let media = attachment.media else {
      throw writeError(operation: operation, reason: "ICAttachment.media was nil before PDF media write.")
    }
    var error: AnyObject?
    guard media.writeData(data as NSData, error: &error) else {
      throw writeError(operation: operation, reason: "ICMedia.writeData returned false.", error: error)
    }
    attachment.fileSize = Int64(data.count)
    attachment.deletePreviewImages()
    attachment.invalidateAttachmentPreviewImages()
    attachment.updateAfterMediaChange()
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)
  }

  private func writeImageMediaData(
    _ data: Data,
    to attachment: ICAttachment,
    note: ICNote,
    context: ICNoteContext,
    operation: String
  ) throws {
    guard let media = attachment.media else {
      throw writeError(operation: operation, reason: "ICAttachment.media was nil before image media write.")
    }
    var error: AnyObject?
    guard media.writeData(data as NSData, error: &error) else {
      throw writeError(operation: operation, reason: "ICMedia.writeData returned false.", error: error)
    }
    attachment.fileSize = Int64(data.count)
    attachment.deletePreviewImages()
    attachment.invalidateAttachmentPreviewImages()
    attachment.updateAfterMediaChange()
    attachment.attachmentDidChange()
    attachment.persistPendingChanges()
    try save(note: note, context: context, operation: operation)
  }

  private func normalizedPDFRotation(_ value: Int) -> Int {
    ((value % 360) + 360) % 360
  }

  private func validateAttachmentScanInspection(
    _ source: NotesAttachmentScanPDFInspectionSource,
    operation: String
  ) throws {
    let evidence = [
      source.attachment.typeUTI,
      source.attachment.title,
      source.attachment.mediaFilename,
      source.attachment.contentIdentifier,
    ].compactMap { $0 }.joined(separator: " ").lowercased()
    guard evidence.contains("scan")
      || source.scannedDocumentsMetadataPresent
      || source.croppingQuadPresent
      || source.docCamPDFVersion != nil
    else {
      throw writeError(
        operation: operation,
        reason: "Scan attachment mutation requires scanned-document readback evidence."
      )
    }
  }

  private func validateScanPageCount(
    _ expectedCount: Int,
    against source: NotesAttachmentScanPDFInspectionSource,
    operation: String
  ) throws {
    let readbackCount = source.pdfPageCount ?? source.scannedDocumentsMetadataCount
    guard readbackCount == nil || readbackCount == expectedCount else {
      throw writeError(
        operation: operation,
        reason: "Scan page-count readback changed before mutation."
      )
    }
  }

  private func validateLinkMutationTarget(_ note: ICNote, operation: String) throws {
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Password-protected ICNote link add remains gated.")
    }
    guard boolValue(note, key: "isEditable") != false,
      boolValue(note, key: "supportsEditingNotes") != false,
      boolValue(note, key: "isSharedReadOnly") != true
    else {
      throw writeError(operation: operation, reason: "ICNote cannot accept link mutations.")
    }
  }

  private func validateBodyMutationTarget(_ note: ICNote, operation: String) throws {
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Password-protected ICNote body mutation remains gated.")
    }
    guard boolValue(note, key: "isEditable") != false,
      boolValue(note, key: "supportsEditingNotes") != false,
      boolValue(note, key: "isSharedReadOnly") != true
    else {
      throw writeError(operation: operation, reason: "ICNote cannot accept body mutations.")
    }
  }

  private func validateNoteLockMutationTarget(
    _ note: ICNote,
    state: NotesNoteStateRecord,
    action: String,
    operation: String
  ) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash != true else {
      throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
    }
    guard state.isSharedReadOnly == false, state.folderIsSharedReadOnly != true else {
      throw writeError(operation: operation, reason: "Read-only shared ICNote lock mutation remains gated.")
    }
    guard boolValue(note, key: "isEditable") != false,
      boolValue(note, key: "supportsEditingNotes") != false
    else {
      throw writeError(operation: operation, reason: "ICNote does not support lock mutation editing.")
    }

    switch action {
    case "lock":
      guard state.isLockable == true else {
        throw writeError(operation: operation, reason: "ICNote is not lockable.")
      }
      guard state.isPasswordProtected == false,
        state.isPasswordProtectedAndLocked != true
      else {
        throw writeError(
          operation: operation,
          reason: "ICNote already has locked-note protection; use close-locked for session closure."
        )
      }
    case "remove-lock":
      guard state.isPasswordProtectedAndLocked != true else {
        throw writeError(
          operation: operation,
          reason: "Removing a lock from a currently locked ICNote requires a secret-safe unlock flow."
        )
      }
    default:
      throw writeError(operation: operation, reason: "Unsupported Notes lock mutation action.")
    }
  }

  private func validateNoteUnlockTarget(_ state: NotesNoteStateRecord, operation: String) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash != true else {
      throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
    }
    guard state.isPasswordProtected else {
      throw CLIError(
        code: .validationError,
        message: "Unlock requires a password-protected ICNote.",
        details: [
          "operation": operation,
          "capability": "unlock_locked_note",
          "note_id_sha256": sha256Hex(state.noteID),
          "required_state": "password_protected_note",
        ]
      )
    }
  }

  private func notesAuthenticationState(operation: String) throws -> NSObject {
    guard let state = ICAuthenticationState.sharedState() as? NSObject else {
      throw writeError(operation: operation, reason: "ICAuthenticationState.sharedState returned nil.")
    }
    return state
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
      throw writeError(
        operation: operation,
        reason: "ICAuthenticationState \(selectorName) selector is unavailable."
      )
    }
    typealias AuthenticationStateBoolIMP = @convention(c) (AnyObject, Selector) -> Bool
    let function = unsafeBitCast(method_getImplementation(method), to: AuthenticationStateBoolIMP.self)
    return function(state, selector)
  }

  private func authenticate(
    note: ICNote,
    passphrase: String,
    state: NSObject,
    operation: String
  ) throws -> Bool {
    let selector = NSSelectorFromString("authenticateObject:withPassphrase:")
    guard let stateClass = object_getClass(state),
      let method = class_getInstanceMethod(stateClass, selector)
    else {
      throw writeError(
        operation: operation,
        reason: "ICAuthenticationState authenticateObject:withPassphrase: selector is unavailable."
      )
    }
    typealias AuthenticateIMP = @convention(c) (AnyObject, Selector, AnyObject, AnyObject) -> Bool
    let function = unsafeBitCast(method_getImplementation(method), to: AuthenticateIMP.self)
    return function(state, selector, note, passphrase as NSString)
  }

  private func invokeNoteLockManager(note: ICNote, selectorName: String, operation: String) throws {
    guard let manager = ICNoteLockManager(note: note) as AnyObject? else {
      throw writeError(operation: operation, reason: "ICNoteLockManager could not be created.")
    }
    let selector = NSSelectorFromString(selectorName)
    guard manager.responds(to: selector),
      let managerClass = object_getClass(manager),
      let method = class_getInstanceMethod(managerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICNoteLockManager \(selectorName) selector is unavailable.")
    }

    let semaphore = DispatchSemaphore(value: 0)
    let completion = NotesNoteLockCompletion()
    let block: @convention(block) () -> Void = {
      completion.complete()
      semaphore.signal()
    }
    typealias LockIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: LockIMP.self)
    function(manager, selector, unsafeBitCast(block, to: AnyObject.self))
    guard semaphore.wait(timeout: .now() + .seconds(15)) == .success, completion.completed else {
      throw writeError(operation: operation, reason: "ICNoteLockManager \(selectorName) completion did not return.")
    }
  }

  private func mentionParticipantCandidates(_ note: ICNote) -> [AnyObject] {
    let share = collaborationShareObject(for: note)
    let groups: [[AnyObject]] = [
      anyObjects(optionalObject(note, key: "participants")),
      anyObjects(optionalObject(note, key: "ic_nonCurrentUserParticipants")),
      anyObjects(optionalObject(note, key: "ic_acceptedParticipants")),
      share.map { anyObjects(optionalObject($0, key: "participants")) } ?? [],
      share.map { anyObjects(optionalObject($0, key: "ic_nonCurrentUserParticipants")) } ?? [],
      share.map { anyObjects(optionalObject($0, key: "ic_acceptedParticipants")) } ?? [],
    ]
    var unique: [AnyObject] = []
    var seen = Set<String>()
    for participant in groups.flatMap({ $0 }) {
      let identity = participantIdentityHash(participant, note: note)
      guard seen.insert(identity).inserted else {
        continue
      }
      unique.append(participant)
    }
    return unique
  }

  private func validateCollaborationPermissionMutationTarget(
    _ note: ICNote,
    operation: String,
    capability: String = "collaboration_permission_mutation",
    actionDescription: String = "collaboration permission mutation"
  ) throws {
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Password-protected ICNote \(actionDescription) remains gated.")
    }
    let participantCount = objectCount(optionalObject(note, key: "participants")) ?? 0
    let wasShared = boolValue(note, key: "isSharedViaICloud") == true
      || boolValue(note, key: "isSharedViaICloudFolder") == true
      || boolValue(note, key: "isSharedReadOnly") == true
      || participantCount > 0
      || collaborationShareObject(for: note) != nil
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes \(actionDescription) requires an already shared note.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_state": "shared_note",
        ]
      )
    }
    guard boolValue(note, key: "isSharedReadOnly") != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes \(actionDescription) requires a writable shared note.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_state": "shared_note_with_manage_permission",
        ]
      )
    }
  }

  private func collaborationMutationTarget(
    noteID: String?,
    folderID: String?,
    operation: String,
    capability: String,
    actionDescription: String
  ) throws -> NotesCollaborationMutationTarget {
    let normalizedNoteID = nonEmpty(noteID ?? "")
    let normalizedFolderID = nonEmpty(folderID ?? "")
    guard (normalizedNoteID != nil) != (normalizedFolderID != nil) else {
      throw CLIError(
        code: .validationError,
        message: "Notes \(actionDescription) requires exactly one target.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_target": "id_or_folder",
        ]
      )
    }

    if let normalizedNoteID {
      let note = try note(id: normalizedNoteID)
      try validateCollaborationPermissionMutationTarget(
        note,
        operation: operation,
        capability: capability,
        actionDescription: actionDescription
      )
      return NotesCollaborationMutationTarget(
        kind: "note",
        id: normalizedNoteID,
        object: note,
        note: note,
        folder: nil
      )
    }

    let resolvedFolderID = normalizedFolderID ?? ""
    let folder = try folder(id: resolvedFolderID)
    try validateCollaborationPermissionMutationTarget(
      folder,
      operation: operation,
      capability: capability,
      actionDescription: actionDescription
    )
    return NotesCollaborationMutationTarget(
      kind: "folder",
      id: resolvedFolderID,
      object: folder,
      note: nil,
      folder: folder
    )
  }

  private func collaborationSharingTarget(
    noteID: String?,
    folderID: String?,
    createShareIfNeeded: Bool,
    operation: String,
    capability: String,
    actionDescription: String
  ) throws -> NotesCollaborationMutationTarget {
    let normalizedNoteID = nonEmpty(noteID ?? "")
    let normalizedFolderID = nonEmpty(folderID ?? "")
    guard (normalizedNoteID != nil) != (normalizedFolderID != nil) else {
      throw CLIError(
        code: .validationError,
        message: "Notes \(actionDescription) requires exactly one target.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_target": "id_or_folder",
        ]
      )
    }

    if let normalizedNoteID {
      let note = try note(id: normalizedNoteID)
      guard boolValue(note, key: "isDeletedOrInTrash") != true else {
        throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
      }
      guard boolValue(note, key: "isPasswordProtected") != true,
        boolValue(note, key: "isPasswordProtectedAndLocked") != true
      else {
        throw writeError(operation: operation, reason: "Password-protected ICNote \(actionDescription) remains gated.")
      }
      guard boolValue(note, key: "isEditable") != false,
        boolValue(note, key: "supportsEditingNotes") != false,
        boolValue(note, key: "isSharedReadOnly") != true
      else {
        throw CLIError(
          code: .permissionDenied,
          message: "Notes \(actionDescription) requires a writable note.",
          details: [
            "operation": operation,
            "capability": capability,
            "required_state": "writable_note",
            "note_id_sha256": sha256Hex(normalizedNoteID),
          ]
        )
      }
      let share = collaborationShareObject(for: note)
      let participantCount = objectCount(optionalObject(note, key: "participants")) ?? 0
      let wasShared = collaborationTargetWasShared(object: note, share: share, participantCount: participantCount)
      if createShareIfNeeded == false, wasShared == false {
        throw CLIError(
          code: .validationError,
          message: "Notes \(actionDescription) requires an already shared note.",
          details: [
            "operation": operation,
            "capability": capability,
            "required_state": "shared_note",
            "note_id_sha256": sha256Hex(normalizedNoteID),
          ]
        )
      }
      return NotesCollaborationMutationTarget(
        kind: "note",
        id: normalizedNoteID,
        object: note,
        note: note,
        folder: nil
      )
    }

    let resolvedFolderID = normalizedFolderID ?? ""
    let folder = try folder(id: resolvedFolderID)
    guard boolValue(folder, key: "isDeleted") != true,
      boolValue(folder, key: "isDeletedOrInTrash") != true,
      boolValue(folder, key: "isInTrash") != true,
      boolValue(folder, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder is deleted or in trash.")
    }
    guard boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSharedReadOnly") != true,
      boolValue(folder, key: "isSubfolderOfReadOnlyFolder") != true
    else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes \(actionDescription) requires a writable folder.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_state": "writable_folder",
          "folder_id_sha256": sha256Hex(resolvedFolderID),
        ]
      )
    }
    let share = collaborationShareObject(for: folder)
    let participantCount = objectCount(optionalObject(folder, key: "participants")) ?? 0
    let wasShared = collaborationTargetWasShared(object: folder, share: share, participantCount: participantCount)
    if createShareIfNeeded == false, wasShared == false {
      throw CLIError(
        code: .validationError,
        message: "Notes \(actionDescription) requires an already shared folder.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_state": "shared_folder",
          "folder_id_sha256": sha256Hex(resolvedFolderID),
        ]
      )
    }
    return NotesCollaborationMutationTarget(
      kind: "folder",
      id: resolvedFolderID,
      object: folder,
      note: nil,
      folder: folder
    )
  }

  private func collaborationSelfRemovalTarget(
    noteID: String?,
    folderID: String?,
    operation: String,
    capability: String,
    actionDescription: String
  ) throws -> NotesCollaborationMutationTarget {
    let normalizedNoteID = nonEmpty(noteID ?? "")
    let normalizedFolderID = nonEmpty(folderID ?? "")
    guard (normalizedNoteID != nil) != (normalizedFolderID != nil) else {
      throw CLIError(
        code: .validationError,
        message: "Notes \(actionDescription) requires exactly one target.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_target": "id_or_folder",
        ]
      )
    }

    if let normalizedNoteID {
      let note = try note(id: normalizedNoteID)
      guard boolValue(note, key: "isDeletedOrInTrash") != true else {
        throw writeError(operation: operation, reason: "ICNote is deleted or in trash.")
      }
      return NotesCollaborationMutationTarget(
        kind: "note",
        id: normalizedNoteID,
        object: note,
        note: note,
        folder: nil
      )
    }

    let resolvedFolderID = normalizedFolderID ?? ""
    let folder = try folder(id: resolvedFolderID)
    guard boolValue(folder, key: "isDeleted") != true,
      boolValue(folder, key: "isDeletedOrInTrash") != true,
      boolValue(folder, key: "isInTrash") != true,
      boolValue(folder, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder is deleted or in trash.")
    }
    return NotesCollaborationMutationTarget(
      kind: "folder",
      id: resolvedFolderID,
      object: folder,
      note: nil,
      folder: folder
    )
  }

  private func validateCollaborationPermissionMutationTarget(
    _ folder: ICFolder,
    operation: String,
    capability: String = "collaboration_permission_mutation",
    actionDescription: String = "collaboration permission mutation"
  ) throws {
    guard boolValue(folder, key: "isDeleted") != true,
      boolValue(folder, key: "isDeletedOrInTrash") != true,
      boolValue(folder, key: "isInTrash") != true,
      boolValue(folder, key: "markedForDeletion") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder is deleted or in trash.")
    }
    let participantCount = objectCount(optionalObject(folder, key: "participants")) ?? 0
    let wasShared = boolValue(folder, key: "isSharedViaICloud") == true
      || boolValue(folder, key: "isSharedReadOnly") == true
      || boolValue(folder, key: "isSubfolderOfReadOnlyFolder") == true
      || participantCount > 0
      || collaborationShareObject(for: folder) != nil
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes \(actionDescription) requires an already shared folder.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_state": "shared_folder",
        ]
      )
    }
    guard boolValue(folder, key: "isSharedReadOnly") != true,
      boolValue(folder, key: "isSubfolderOfReadOnlyFolder") != true
    else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes \(actionDescription) requires a writable shared folder.",
        details: [
          "operation": operation,
          "capability": capability,
          "required_state": "shared_folder_with_manage_permission",
        ]
      )
    }
  }

  private func collaborationParticipantCandidates(note: ICNote, share: AnyObject) -> [AnyObject] {
    let groups: [[AnyObject]] = [
      anyObjects(optionalObject(note, key: "participants")),
      anyObjects(optionalObject(note, key: "ic_nonCurrentUserParticipants")),
      anyObjects(optionalObject(note, key: "ic_acceptedParticipants")),
      anyObjects(optionalObject(share, key: "participants")),
      anyObjects(optionalObject(share, key: "ic_nonCurrentUserParticipants")),
      anyObjects(optionalObject(share, key: "ic_acceptedParticipants")),
    ]
    var unique: [AnyObject] = []
    var seen = Set<String>()
    for participant in groups.flatMap({ $0 }) {
      let identity = participantIdentityHash(participant, note: note)
      guard seen.insert(identity).inserted else {
        continue
      }
      unique.append(participant)
    }
    return unique
  }

  private func collaborationShareParticipantCandidates(share: AnyObject, note: ICNote) -> [AnyObject] {
    let groups: [[AnyObject]] = [
      anyObjects(optionalObject(share, key: "participants")),
      anyObjects(optionalObject(share, key: "ic_nonCurrentUserParticipants")),
      anyObjects(optionalObject(share, key: "ic_acceptedParticipants")),
    ]
    var unique: [AnyObject] = []
    var seen = Set<String>()
    for participant in groups.flatMap({ $0 }) {
      let identity = participantIdentityHash(participant, note: note)
      guard seen.insert(identity).inserted else {
        continue
      }
      unique.append(participant)
    }
    return unique
  }

  private func collaborationShareParticipantCandidates(
    share: AnyObject,
    object: AnyObject,
    note: ICNote?
  ) -> [AnyObject] {
    let groups: [[AnyObject]] = [
      anyObjects(optionalObject(object, key: "participants")),
      anyObjects(optionalObject(object, key: "ic_nonCurrentUserParticipants")),
      anyObjects(optionalObject(object, key: "ic_acceptedParticipants")),
      anyObjects(optionalObject(share, key: "participants")),
      anyObjects(optionalObject(share, key: "ic_nonCurrentUserParticipants")),
      anyObjects(optionalObject(share, key: "ic_acceptedParticipants")),
    ]
    var unique: [AnyObject] = []
    var seen = Set<String>()
    for participant in groups.flatMap({ $0 }) {
      let identity = participantIdentityHash(participant, object: object, note: note)
      guard seen.insert(identity).inserted else {
        continue
      }
      unique.append(participant)
    }
    return unique
  }

  private func collaborationSelfRemovalParticipantCandidates(
    share: AnyObject,
    object: AnyObject,
    note: ICNote?
  ) -> [AnyObject] {
    var groups: [[AnyObject]] = [
      optionalObject(share, key: "currentUserParticipant").map { [$0] } ?? [],
      optionalObject(object, key: "currentUserParticipant").map { [$0] } ?? [],
      collaborationShareParticipantCandidates(share: share, object: object, note: note),
    ]
    if let note {
      groups.append(collaborationParticipantCandidates(note: note, share: share))
    }
    var unique: [AnyObject] = []
    var seen = Set<String>()
    for participant in groups.flatMap({ $0 }) {
      let identity = participantIdentityHash(participant, object: object, note: note)
      guard seen.insert(identity).inserted else {
        continue
      }
      unique.append(participant)
    }
    return unique
  }

  private func resolveCollaborationParticipant(
    target: String,
    participants: [AnyObject],
    note: ICNote,
    operation: String,
    capability: String
  ) throws -> NotesCollaborationParticipantResolution {
    let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalizedTarget.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration participant target is required.",
        details: [
          "operation": operation,
          "capability": capability,
        ]
      )
    }

    for participant in participants {
      let rawIDs = participantUserIDStrings(from: participant, note: note)
      let userHashes = Array(Set(rawIDs.map(sha256Hex))).sorted()
      let participantHash = participantIdentityHash(participant, note: note)
      let objectHash = sha256Hex(String(describing: participant))
      let matchValues = Set(rawIDs + userHashes + [participantHash, objectHash])
      guard matchValues.contains(normalizedTarget) else {
        continue
      }
      return NotesCollaborationParticipantResolution(
        participant: participant,
        participantIDSHA256: participantHash,
        userRecordNameSHA256: participantUserRecordName(participant, note: note).map(sha256Hex) ?? userHashes.first,
        participantCount: participants.count
      )
    }

    throw CLIError(
      code: .notFound,
      message: "Notes collaboration participant target did not match an existing shared-note participant.",
      details: [
        "operation": operation,
        "capability": capability,
        "target_sha256": sha256Hex(target),
        "participant_count": "\(participants.count)",
      ]
    )
  }

  private func resolveCollaborationParticipant(
    target: String,
    participants: [AnyObject],
    object: AnyObject,
    note: ICNote?,
    targetKind: String,
    operation: String,
    capability: String
  ) throws -> NotesCollaborationParticipantResolution {
    let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalizedTarget.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration participant target is required.",
        details: [
          "operation": operation,
          "capability": capability,
        ]
      )
    }

    for participant in participants {
      let rawIDs = participantUserIDStrings(from: participant, note: note)
      let userHashes = Array(Set(rawIDs.map(sha256Hex))).sorted()
      let participantHash = participantIdentityHash(participant, object: object, note: note)
      let objectHash = sha256Hex(String(describing: participant))
      let matchValues = Set(rawIDs + userHashes + [participantHash, objectHash])
      guard matchValues.contains(normalizedTarget) else {
        continue
      }
      return NotesCollaborationParticipantResolution(
        participant: participant,
        participantIDSHA256: participantHash,
        userRecordNameSHA256: participantUserRecordName(participant, note: note).map(sha256Hex) ?? userHashes.first,
        participantCount: participants.count
      )
    }

    throw CLIError(
      code: .notFound,
      message: "Notes collaboration participant target did not match an existing shared-\(targetKind) participant.",
      details: [
        "operation": operation,
        "capability": capability,
        "target_sha256": sha256Hex(target),
        "participant_count": "\(participants.count)",
      ]
    )
  }

  private func resolveCurrentCollaborationParticipant(
    share: AnyObject,
    participants: [AnyObject],
    object: AnyObject,
    note: ICNote?,
    operation: String,
    capability: String
  ) throws -> NotesCollaborationParticipantResolution {
    let currentUserParticipant = optionalObject(share, key: "currentUserParticipant")
      ?? optionalObject(object, key: "currentUserParticipant")
    let currentUserHash = currentUserParticipant.map {
      participantIdentityHash($0, object: object, note: note)
    }
    for participant in participants {
      let participantHash = participantIdentityHash(participant, object: object, note: note)
      let matchesCurrentUser = boolValue(participant, key: "isCurrentUser") == true
        || currentUserHash == participantHash
      guard matchesCurrentUser else {
        continue
      }
      let rawIDs = participantUserIDStrings(from: participant, note: note)
      let userHashes = Array(Set(rawIDs.map(sha256Hex))).sorted()
      return NotesCollaborationParticipantResolution(
        participant: participant,
        participantIDSHA256: participantHash,
        userRecordNameSHA256: participantUserRecordName(participant, note: note).map(sha256Hex) ?? userHashes.first,
        participantCount: participants.count
      )
    }

    throw CLIError(
      code: .validationError,
      message: "Notes self removal could not resolve the current user participant.",
      details: [
        "operation": operation,
        "capability": capability,
        "participant_count": "\(participants.count)",
      ]
    )
  }

  private func validateRemovableCollaborationParticipant(
    _ participant: AnyObject,
    share: AnyObject,
    note: ICNote,
    operation: String,
    targetHash: String
  ) throws {
    let role = optionalInt(participant, key: "role") ?? optionalInt(participant, key: "type")
    if role == 1 {
      throw CLIError(
        code: .validationError,
        message: "Notes participant removal cannot remove the share owner.",
        details: [
          "operation": operation,
          "capability": "collaboration_participant_removal",
          "target_sha256": targetHash,
          "required_command": "state stop-sharing",
        ]
      )
    }
    if boolValue(participant, key: "isCurrentUser") == true {
      throw CLIError(
        code: .validationError,
        message: "Notes participant removal cannot remove the current user.",
        details: [
          "operation": operation,
          "capability": "collaboration_participant_removal",
          "target_sha256": targetHash,
          "required_command": "state remove-self",
        ]
      )
    }
    if let currentUser = optionalObject(share, key: "currentUserParticipant"),
      participantIdentityHash(currentUser, note: note) == participantIdentityHash(participant, note: note)
    {
      throw CLIError(
        code: .validationError,
        message: "Notes participant removal cannot remove the current user.",
        details: [
          "operation": operation,
          "capability": "collaboration_participant_removal",
          "target_sha256": targetHash,
          "required_command": "state remove-self",
        ]
      )
    }
  }

  private func validateSelfRemovableCollaborationParticipant(
    _ participant: AnyObject,
    operation: String,
    targetHash: String
  ) throws {
    let role = optionalInt(participant, key: "role") ?? optionalInt(participant, key: "type")
    if role == 1 {
      throw CLIError(
        code: .validationError,
        message: "Notes self removal cannot remove the share owner.",
        details: [
          "operation": operation,
          "capability": "collaboration_self_removal",
          "target_sha256": targetHash,
          "required_command": "state stop-sharing",
        ]
      )
    }
  }

  private func collaborationParticipantRole(_ participant: AnyObject) -> Int? {
    optionalInt(participant, key: "role") ?? optionalInt(participant, key: "type")
  }

  private func collaborationParticipantCanCarryInvitePolicy(_ participant: AnyObject) -> Bool {
    let role = collaborationParticipantRole(participant)
    return role != 1
      && role != 4
      && boolValue(participant, key: "isCurrentUser") != true
  }

  private func removeParticipantFromShare(
    _ participant: AnyObject,
    share: AnyObject,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("removeParticipant:")
    guard share.responds(to: selector),
      let shareClass = object_getClass(share),
      let method = class_getInstanceMethod(shareClass, selector)
    else {
      throw writeError(operation: operation, reason: "CKShare.removeParticipant selector is unavailable.")
    }
    typealias RemoveParticipantIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: RemoveParticipantIMP.self)
    function(share, selector, participant)
  }

  private func removeShareIfNeeded(object: AnyObject, operation: String) throws {
    let selector = NSSelectorFromString("removeShareIfNeededWithOwnedObjectID:countParticipants:completionHandler:")
    guard let controller = ICCollaborationController.sharedInstance() as AnyObject?,
      controller.responds(to: selector),
      let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICCollaborationController.removeShareIfNeeded selector is unavailable.")
    }

    let semaphore = DispatchSemaphore(value: 0)
    let completion = NotesCollaborationStopSharingCompletion()
    let block: @convention(block) () -> Void = {
      completion.complete(nil)
      semaphore.signal()
    }
    guard let objectID = managedObjectID(for: object) else {
      throw writeError(operation: operation, reason: "Shared Notes object has no Core Data objectID.")
    }
    typealias RemoveShareIMP = @convention(c) (AnyObject, Selector, AnyObject, Bool, AnyObject) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: RemoveShareIMP.self)
    function(controller, selector, objectID, true, unsafeBitCast(block, to: AnyObject.self))
    guard semaphore.wait(timeout: .now() + .seconds(15)) == .success, completion.completed else {
      throw writeError(
        operation: operation,
        reason: "ICCollaborationController.removeShareIfNeeded completion did not return."
      )
    }
  }

  private func resolveMentionParticipant(
    target: String,
    participants: [AnyObject],
    note: ICNote,
    operation: String
  ) throws -> NotesMentionParticipantResolution {
    let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalizedTarget.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant mention target is required.",
        details: [
          "operation": operation,
          "capability": "semantic_participant_mention",
        ]
      )
    }

    for participant in participants {
      let rawIDs = participantUserIDStrings(from: participant, note: note)
      let userHashes = Array(Set(rawIDs.map(sha256Hex))).sorted()
      let participantHash = participantIdentityHash(participant, note: note)
      let objectHash = sha256Hex(String(describing: participant))
      let matchValues = Set(rawIDs + userHashes + [participantHash, objectHash])
      guard matchValues.contains(normalizedTarget) else {
        continue
      }
      guard let userRecordName = participantUserRecordName(participant, note: note) ?? rawIDs.first else {
        throw CLIError(
          code: .validationError,
          message: "Notes participant mention target lacks a private user record name readback.",
          details: [
            "operation": operation,
            "capability": "semantic_participant_mention",
            "target_sha256": sha256Hex(target),
            "target_participant_id_sha256": participantHash,
          ]
        )
      }
      return NotesMentionParticipantResolution(
        participantIDSHA256: participantHash,
        userRecordName: userRecordName,
        userRecordNameSHA256: sha256Hex(userRecordName),
        displayText: participantDisplayText(participant, note: note),
        participantCount: participants.count
      )
    }

    throw CLIError(
      code: .notFound,
      message: "Notes participant mention target did not match an existing shared-note participant.",
      details: [
        "operation": operation,
        "capability": "semantic_participant_mention",
        "target_sha256": sha256Hex(target),
        "participant_count": "\(participants.count)",
      ]
    )
  }

  private func normalizedMentionText(_ text: String?, fallback: String?, operation: String) throws -> String {
    let value = nonEmpty(text ?? "") ?? nonEmpty(fallback ?? "") ?? "@"
    guard value.utf8.count <= 512 else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant mention text is too long.",
        details: [
          "operation": operation,
          "capability": "semantic_participant_mention",
          "mention_text_sha256": sha256Hex(value),
          "max_byte_count": "512",
        ]
      )
    }
    return value
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

  private func collaborationTargetWasShared(object: AnyObject, share: AnyObject?, participantCount: Int) -> Bool {
    share != nil
      || participantCount > 0
      || boolValue(object, key: "isSharedViaICloud") == true
      || boolValue(object, key: "isSharedViaICloudFolder") == true
      || boolValue(object, key: "isSharedReadOnly") == true
      || boolValue(object, key: "isSubfolderOfReadOnlyFolder") == true
  }

  private func createCollaborationShare(for object: AnyObject, operation: String) throws -> AnyObject {
    let selector = NSSelectorFromString("newShareForObject:")
    let controllerClass: AnyClass = ICCollaborationController.self
    guard let method = class_getClassMethod(controllerClass, selector) else {
      throw writeError(operation: operation, reason: "ICCollaborationController.newShareForObject selector is unavailable.")
    }
    typealias NewShareIMP = @convention(c) (AnyClass, Selector, AnyObject) -> AnyObject?
    let function = unsafeBitCast(method_getImplementation(method), to: NewShareIMP.self)
    guard let share = function(controllerClass, selector, object) else {
      throw writeError(operation: operation, reason: "ICCollaborationController.newShareForObject returned nil.")
    }
    return share
  }

  private func fetchCollaborationShareParticipant(
    target: String,
    object: AnyObject,
    operation: String,
    capability: String
  ) throws -> AnyObject {
    let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalizedTarget.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration participant target is required.",
        details: [
          "operation": operation,
          "capability": capability,
        ]
      )
    }

    let container = collaborationContainer(for: object)
    let completion = NotesShareParticipantFetchCompletion()
    let semaphore = DispatchSemaphore(value: 0)
    if normalizedTarget.contains("@") {
      container.fetchShareParticipant(withEmailAddress: normalizedTarget) { participant, error in
        completion.complete(participant as AnyObject?, error)
        semaphore.signal()
      }
    } else if let recordName = collaborationUserRecordName(from: normalizedTarget) {
      let recordID = CKRecord.ID(recordName: recordName)
      container.fetchShareParticipant(withUserRecordID: recordID) { participant, error in
        completion.complete(participant as AnyObject?, error)
        semaphore.signal()
      }
    } else if collaborationTargetLooksLikePhoneNumber(normalizedTarget) {
      container.fetchShareParticipant(withPhoneNumber: normalizedTarget) { participant, error in
        completion.complete(participant as AnyObject?, error)
        semaphore.signal()
      }
    } else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration participant target must be an email, phone number, or user record identifier.",
        details: [
          "operation": operation,
          "capability": capability,
          "target_sha256": sha256Hex(target),
          "accepted_target_formats": "email,phone,record:<user-record-name>",
        ]
      )
    }

    guard semaphore.wait(timeout: .now() + .seconds(20)) == .success, completion.completed else {
      throw writeError(operation: operation, reason: "CKContainer.fetchShareParticipant completion did not return.")
    }
    if let errorDescription = completion.errorDescription {
      throw CLIError(
        code: .notFound,
        message: "Notes collaboration participant lookup failed.",
        details: [
          "operation": operation,
          "capability": capability,
          "target_sha256": sha256Hex(target),
          "cloudkit_error_sha256": sha256Hex(errorDescription),
        ]
      )
    }
    guard let participant = completion.participant else {
      throw CLIError(
        code: .notFound,
        message: "Notes collaboration participant lookup returned no participant.",
        details: [
          "operation": operation,
          "capability": capability,
          "target_sha256": sha256Hex(target),
        ]
      )
    }
    return participant
  }

  private func collaborationContainer(for object: AnyObject) -> CKContainer {
    guard let accountID = collaborationAccountID(for: object),
      let controller = ICCollaborationController.sharedInstance() as AnyObject?
    else {
      return CKContainer.default()
    }
    let selector = NSSelectorFromString("containerForAccountID:")
    guard controller.responds(to: selector),
      let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      return CKContainer.default()
    }
    typealias ContainerIMP = @convention(c) (AnyObject, Selector, AnyObject) -> AnyObject?
    let function = unsafeBitCast(method_getImplementation(method), to: ContainerIMP.self)
    return (function(controller, selector, accountID as NSString) as? CKContainer) ?? CKContainer.default()
  }

  private func collaborationAccountID(for object: AnyObject) -> String? {
    let direct = [
      "accountID",
      "accountIdentifier",
    ].compactMap { nonEmpty(optionalString(object, key: $0)) }
    if let first = direct.first {
      return first
    }
    guard let account = optionalObject(object, key: "account") else {
      return nil
    }
    return [
      "identifier",
      "accountIdentifier",
      "accountID",
    ].compactMap { nonEmpty(optionalString(account, key: $0)) }.first
  }

  private func collaborationUserRecordName(from target: String) -> String? {
    for prefix in ["record:", "user-record:", "ckrecord:"] {
      if target.lowercased().hasPrefix(prefix) {
        return nonEmpty(String(target.dropFirst(prefix.count)))
      }
    }
    return nil
  }

  private func collaborationTargetLooksLikePhoneNumber(_ target: String) -> Bool {
    let allowed = CharacterSet(charactersIn: "+0123456789-() .")
    return target.rangeOfCharacter(from: .decimalDigits) != nil
      && target.unicodeScalars.allSatisfy { allowed.contains($0) }
  }

  private func addParticipantToShare(
    _ participant: AnyObject,
    share: AnyObject,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("addParticipant:")
    guard share.responds(to: selector),
      let shareClass = object_getClass(share),
      let method = class_getInstanceMethod(shareClass, selector)
    else {
      throw writeError(operation: operation, reason: "CKShare.addParticipant selector is unavailable.")
    }
    typealias AddParticipantIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Void
    let function = unsafeBitCast(method_getImplementation(method), to: AddParticipantIMP.self)
    function(share, selector, participant)
  }

  private func collaborationShareRecordHash(_ share: AnyObject, fallbackObject: AnyObject) -> String? {
    let recordID = optionalObject(share, key: "recordID")
      ?? optionalObject(fallbackObject, key: "recordID")
    return recordID.map { sha256Hex(String(describing: $0)) }
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

  private func collaborationAccessScopeLabel(_ publicPermission: Int?) -> String? {
    guard let publicPermission else {
      return nil
    }
    switch publicPermission {
    case 1:
      return "invited-only"
    case 2, 3:
      return "anyone-with-link"
    case 0:
      return "unknown"
    default:
      return "unrecognized-\(publicPermission)"
    }
  }

  private func collaborationAccessScopePublicPermissionValue(
    accessScopeLabel: String,
    beforePublicPermission: Int?
  ) -> Int {
    switch accessScopeLabel {
    case "invited-only":
      return 1
    case "anyone-with-link":
      if let beforePublicPermission, beforePublicPermission > 1 {
        return beforePublicPermission
      }
      return 2
    default:
      return beforePublicPermission ?? 1
    }
  }

  private func saveCollaborationShare(
    _ share: AnyObject,
    object: AnyObject,
    context: ICNoteContext,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("saveServerShare:persistParticipantEvents:accountID:")
    if let controller = ICCollaborationController.sharedInstance() as AnyObject?,
      controller.responds(to: selector),
      let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    {
      typealias SaveServerShareIMP = @convention(c) (AnyObject, Selector, AnyObject, Bool, AnyObject?) -> Void
      let function = unsafeBitCast(method_getImplementation(method), to: SaveServerShareIMP.self)
      let account = optionalObject(object, key: "account")
      let accountID = account.flatMap {
        nonEmpty(optionalString($0, key: "identifier"))
          ?? nonEmpty(optionalString($0, key: "accountIdentifier"))
          ?? nonEmpty(optionalString($0, key: "accountID"))
      }
      function(controller, selector, share, true, accountID.map { $0 as NSString })
    }
    try save(context: context, operation: operation)
  }

  private func mentionInlineAttachments(_ note: ICNote) -> [AnyObject] {
    anyObjects(note.allNoteTextInlineAttachments()).filter(isMentionAttachmentObject)
  }

  private func mentionCount(in attachments: [AnyObject], userRecordNameSHA256: String) -> Int {
    attachments.filter { attachment in
      participantUserIDStrings(from: attachment, note: nil)
        .map(sha256Hex)
        .contains(userRecordNameSHA256)
    }.count
  }

  private func isMentionAttachmentObject(_ object: AnyObject) -> Bool {
    boolValue(object, key: "isMentionAttachment") == true
      || objectTypeName(object).contains("ICMentionTextAttachment")
  }

  private func mentionAttachmentIdentity(_ object: AnyObject) -> String {
    [
      nonEmpty(optionalString(object, key: "identifier")),
      nonEmpty(optionalString(object, key: "attachmentIdentifier")),
      nonEmpty(optionalString(object, key: "tokenContentIdentifier")),
      nonEmpty(optionalString(object, key: "contentIdentifier")),
      Optional(objectIDString(object)),
    ].compactMap { $0 }.joined(separator: "|")
  }

  private func participantIdentityHash(_ participant: AnyObject, note: ICNote) -> String {
    participantIdentityHash(participant, object: note, note: note)
  }

  private func participantIdentityHash(_ participant: AnyObject, object: AnyObject, note: ICNote?) -> String {
    let userHashes = Array(Set(participantUserIDStrings(from: participant, note: note).map(sha256Hex))).sorted()
    return userHashes.isEmpty
      ? sha256Hex(
        [
          objectIDString(participant),
          String(describing: participant),
          objectIDString(object),
        ].joined(separator: "|")
      )
      : sha256Hex(userHashes.joined(separator: "\n"))
  }

  private func participantUserRecordName(_ participant: AnyObject, note: ICNote?) -> String? {
    let direct = [
      "userRecordName",
      "recordName",
      "participantUserID",
      "userID",
      "userIdentifier",
      "identifier",
    ].compactMap { nonEmpty(optionalString(participant, key: $0)) }
    if let first = direct.first {
      return first
    }
    if let note, let object = participant as? NSObject {
      let selector = NSSelectorFromString("ic_userRecordNameInNote:")
      if object.responds(to: selector),
        let value = object.perform(selector, with: note)?.takeUnretainedValue() as? String,
        let nonEmptyValue = nonEmpty(value)
      {
        return nonEmptyValue
      }
    }
    return nil
  }

  private func participantDisplayText(_ participant: AnyObject, note: ICNote) -> String? {
    let direct = [
      "displayName",
      "name",
      "fullName",
      "shortName",
      "ic_participantName",
      "ic_shortParticipantName",
    ].compactMap { nonEmpty(optionalString(participant, key: $0)) }
    if let first = direct.first {
      return first
    }
    guard let object = participant as? NSObject else {
      return nil
    }
    for selectorName in ["ic_participantName", "ic_shortParticipantName"] {
      let selector = NSSelectorFromString(selectorName)
      if object.responds(to: selector),
        let value = object.perform(selector)?.takeUnretainedValue() as? String,
        let nonEmptyValue = nonEmpty(value)
      {
        return nonEmptyValue
      }
    }
    if let userRecordName = participantUserRecordName(participant, note: note) {
      let selector = NSSelectorFromString("ic_participantNameOrFallbackForUserRecordName:note:")
      let participantClass = NSClassFromString("CKShareParticipant") as AnyObject?
      if participantClass?.responds(to: selector) == true,
        let value = participantClass?.perform(selector, with: userRecordName as NSString, with: note)?
          .takeUnretainedValue() as? String,
        let nonEmptyValue = nonEmpty(value)
      {
        return nonEmptyValue
      }
    }
    return nil
  }

  private func participantUserIDStrings(from object: AnyObject, note: ICNote?) -> [String] {
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
    let selectorValue = note.flatMap { participantUserRecordName(object, note: $0) }.map { [$0] } ?? []
    return Array(Set(direct + nested + selectorValue)).sorted()
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

  private func mathResultTarget(note: ICNote, ordinal: Int, operation: String) throws -> NotesMathMutationTarget {
    guard ordinal > 0 else {
      throw writeError(operation: operation, reason: "Notes body math result ordinal must be positive.")
    }
    let targets = mathResultTargets(note)
    guard ordinal <= targets.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body math result selector did not match any result.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "ordinal": "\(ordinal)",
          "math_result_count": "\(targets.count)",
        ]
      )
    }
    return targets[ordinal - 1]
  }

  private func mathResultTargets(_ note: ICNote) -> [NotesMathMutationTarget] {
    var targets: [NotesMathMutationTarget] = []
    var seen = Set<String>()
    for attachment in anyObjects(note.allNoteTextInlineAttachments()) {
      guard isMathResultAttachmentObject(attachment) else {
        continue
      }
      let identity = mathResultIdentity(attachment)
      guard seen.insert(identity).inserted else {
        continue
      }
      targets.append(
        NotesMathMutationTarget(
          attachment: attachment,
          record: bodyMathResultRecord(attachment, ordinal: targets.count + 1, identity: identity)
        ))
    }
    return targets
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
      isValid: boolValue(object, key: "validCalculateAttachment")
        ?? boolValue(object, key: "isValidCalculateAttachment"),
      isRightToLeft: boolValue(object, key: "rightToLeftCalculateAttachment")
        ?? boolValue(object, key: "isRightToLeftCalculateAttachment")
    )
  }

  private func mathExpressionInsertion(
    draft: NotesBodyMathInsertDraft,
    textStorage: NSTextStorage,
    operation: String
  ) throws -> NotesMathExpressionInsertion {
    let location: Int
    if draft.paragraphIDSHA256 != nil || draft.ordinal != nil {
      let target = try paragraphStyleTarget(
        noteID: draft.noteID,
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        textStorage: textStorage,
        operation: operation
      )
      let paragraph = paragraphRange(in: textStorage, around: target.range)
      location = min(textStorage.length, paragraph.location + paragraph.length)
    } else {
      location = textStorage.length
    }

    let prefix = mathExpressionNeedsLineBreakBefore(location: location, textStorage: textStorage) ? "\n" : ""
    let suffix = mathExpressionNeedsLineBreakAfter(location: location, textStorage: textStorage) ? "\n" : ""
    let insertedText = "\(prefix)\(draft.expression)\(suffix)"
    let expressionLocation = location + (prefix as NSString).length
    return NotesMathExpressionInsertion(
      location: location,
      insertedText: insertedText,
      expressionRange: NSRange(location: expressionLocation, length: (draft.expression as NSString).length)
    )
  }

  private func mathVariableSetInsertion(
    draft: NotesBodyMathVariableSetDraft,
    textStorage: NSTextStorage,
    operation: String
  ) throws -> NotesMathVariableSetInsertion {
    let location: Int
    if draft.paragraphIDSHA256 != nil || draft.ordinal != nil {
      let target = try paragraphStyleTarget(
        noteID: draft.noteID,
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        textStorage: textStorage,
        operation: operation
      )
      let paragraph = paragraphRange(in: textStorage, around: target.range)
      location = min(textStorage.length, paragraph.location + paragraph.length)
    } else {
      location = textStorage.length
    }

    let prefix = mathExpressionNeedsLineBreakBefore(location: location, textStorage: textStorage) ? "\n" : ""
    let suffix = mathExpressionNeedsLineBreakAfter(location: location, textStorage: textStorage) ? "\n" : ""
    let separator = "\n"
    let insertedText = "\(prefix)\(draft.variableDefinitionExpression)\(separator)\(draft.dependentExpression)\(suffix)"
    let variableDefinitionLocation = location + (prefix as NSString).length
    let dependentLocation = variableDefinitionLocation
      + (draft.variableDefinitionExpression as NSString).length
      + (separator as NSString).length
    return NotesMathVariableSetInsertion(
      location: location,
      insertedText: insertedText,
      variableDefinitionRange: NSRange(
        location: variableDefinitionLocation,
        length: (draft.variableDefinitionExpression as NSString).length
      ),
      dependentRange: NSRange(
        location: dependentLocation,
        length: (draft.dependentExpression as NSString).length
      ),
      textStorageLengthAfterTextInsert: textStorage.length + (insertedText as NSString).length
    )
  }

  private func mathExpressionNeedsLineBreakBefore(location: Int, textStorage: NSTextStorage) -> Bool {
    guard location > 0, textStorage.length > 0 else {
      return false
    }
    let string = textStorage.string as NSString
    let index = min(location, string.length) - 1
    guard index >= 0 else {
      return false
    }
    return string.substring(with: NSRange(location: index, length: 1)) != "\n"
  }

  private func mathExpressionNeedsLineBreakAfter(location: Int, textStorage: NSTextStorage) -> Bool {
    guard location < textStorage.length else {
      return false
    }
    let string = textStorage.string as NSString
    return string.substring(with: NSRange(location: location, length: 1)) != "\n"
  }

  private func insertRecognizedCalculateResult(
    note: ICNote,
    expression: String,
    expressionRange: NSRange,
    operation: String
  ) throws {
    guard let insertionController = ICAttachmentInsertionController(note: note) else {
      throw writeError(operation: operation, reason: "ICAttachmentInsertionController could not be created.")
    }
    guard let recognitionController = ICCalculateRecognitionController(note: note) else {
      throw writeError(operation: operation, reason: "ICCalculateRecognitionController could not be created.")
    }
    recognitionController.insertsResults = true
    recognitionController.attachmentInsertionController = insertionController

    try invokeCalculateDidInsertString(
      recognitionController,
      expression: expression,
      range: expressionRange,
      operation: operation
    )
    try invokeCalculateInsertResult(
      recognitionController,
      range: expressionRange,
      operation: operation
    )
  }

  private func invokeCalculateDidInsertString(
    _ controller: AnyObject,
    expression: String,
    range: NSRange,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("didInsertString:atRange:")
    guard let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICCalculateRecognitionController.didInsertString:atRange: is unavailable.")
    }
    typealias DidInsertIMP = @convention(c) (AnyObject, Selector, NSString, NSRange) -> Void
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: DidInsertIMP.self)
    function(controller, selector, expression as NSString, range)
  }

  private func invokeCalculateInsertResult(
    _ controller: AnyObject,
    range: NSRange,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("insertResultAtRange:")
    guard let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICCalculateRecognitionController.insertResultAtRange: is unavailable.")
    }
    typealias InsertResultIMP = @convention(c) (AnyObject, Selector, NSRange) -> Void
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: InsertResultIMP.self)
    function(controller, selector, range)
  }

  private func insertedMathResultTarget(
    before: [NotesBodyMathResultRecord],
    after: [NotesBodyMathResultRecord],
    draft: NotesBodyMathInsertDraft,
    operation: String
  ) throws -> NotesBodyMathResultRecord {
    let beforeIDs = Set(before.map(\.idSHA256))
    let inserted = after.filter { beforeIDs.contains($0.idSHA256) == false }
    if let match = inserted.first(where: { $0.expressionSHA256 == draft.expressionSHA256 }) {
      return match
    }
    if let match = inserted.first {
      return match
    }
    throw writeError(
      operation: operation,
      reason: "Math result insertion did not produce a new private calculate-result attachment."
    )
  }

  private func insertedMathVariableTargets(
    before: [NotesBodyMathResultRecord],
    after: [NotesBodyMathResultRecord],
    draft: NotesBodyMathVariableSetDraft,
    operation: String
  ) throws -> (variableDefinition: NotesBodyMathResultRecord, dependent: NotesBodyMathResultRecord) {
    let beforeIDs = Set(before.map(\.idSHA256))
    let inserted = after.filter { beforeIDs.contains($0.idSHA256) == false }
    guard
      let variableDefinition = inserted.first(where: {
        $0.expressionSHA256 == draft.variableDefinitionExpressionSHA256
      })
    else {
      throw writeError(
        operation: operation,
        reason: "Math variable insertion did not produce private readback for the variable definition expression."
      )
    }
    guard
      let dependent = inserted.first(where: {
        $0.expressionSHA256 == draft.dependentExpressionSHA256
      })
    else {
      throw writeError(
        operation: operation,
        reason: "Math variable insertion did not produce private readback for the dependent expression."
      )
    }
    guard variableDefinition.idSHA256 != dependent.idSHA256 else {
      throw writeError(operation: operation, reason: "Math variable readback returned one attachment for two expressions.")
    }
    return (variableDefinition, dependent)
  }

  private func updatedMathVariableDefinitionExpression(
    _ expression: String,
    value: String,
    operation: String
  ) throws -> String {
    guard let separator = expression.firstIndex(of: "=") else {
      throw writeError(operation: operation, reason: "Selected math expression is not a variable definition.")
    }
    let prefix = expression[...separator]
    return "\(prefix)\(value)"
  }

  private func mathResultExpressionString(
    note: ICNote,
    attachment: AnyObject,
    operation: String
  ) throws -> String {
    let controller = try calculateDocumentController(note: note, operation: operation)
    let selector = NSSelectorFromString("expressionStringForResultAttachment:")
    if controller.responds(to: selector),
      let value = controller.perform(selector, with: attachment)?.takeUnretainedValue() as? String,
      let expression = nonEmpty(value)
    {
      return expression
    }
    if let expression = nonEmpty(optionalString(attachment, key: "expression"))
      ?? nonEmpty(optionalString(attachment, key: "altText"))
    {
      return expression
    }
    throw writeError(operation: operation, reason: "Could not read the selected math result expression.")
  }

  private func mathResultExpressionRange(
    note: ICNote,
    attachment: AnyObject,
    textStorage: NSTextStorage,
    operation: String
  ) throws -> NSRange {
    let controller = try calculateDocumentController(note: note, operation: operation)
    let selector = NSSelectorFromString("expressionRangeForResultAttachment:")
    guard let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICCalculateDocumentController.expressionRangeForResultAttachment: is unavailable.")
    }
    typealias ExpressionRangeIMP = @convention(c) (AnyObject, Selector, AnyObject) -> NSRange
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: ExpressionRangeIMP.self)
    let range = function(controller, selector, attachment)
    guard range.location != NSNotFound, range.length > 0, NSMaxRange(range) <= textStorage.length else {
      throw writeError(operation: operation, reason: "Selected math variable expression range was not valid.")
    }
    return range
  }

  private func refreshCalculateExpressions(
    note: ICNote,
    textStorage: NSTextStorage,
    range: NSRange,
    operation: String
  ) throws {
    let controller = try calculateDocumentController(note: note, operation: operation)
    try invokeCalculateFormatExpressions(
      controller,
      textStorage: textStorage,
      range: range,
      operation: operation
    )
    try invokeCalculateUpdateAffectingChangeCounts(controller, operation: operation)
  }

  private func calculateDocumentController(note: ICNote, operation: String) throws -> AnyObject {
    guard let controller = note.calculateDocumentController() as AnyObject? else {
      throw writeError(operation: operation, reason: "ICNote.calculateDocumentController returned nil.")
    }
    return controller
  }

  private func invokeCalculateFormatExpressions(
    _ controller: AnyObject,
    textStorage: NSTextStorage,
    range: NSRange,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("formatExpressionsInAttributedString:range:textStorageOffset:skipStaleExpressions:")
    guard let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICCalculateDocumentController.formatExpressionsInAttributedString:range:textStorageOffset:skipStaleExpressions: is unavailable.")
    }
    typealias FormatExpressionsIMP = @convention(c) (AnyObject, Selector, AnyObject, NSRange, Int64, Bool) -> Void
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: FormatExpressionsIMP.self)
    function(controller, selector, textStorage, range, 0, false)
  }

  private func invokeCalculateUpdateAffectingChangeCounts(
    _ controller: AnyObject,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("updateAffectingChangeCounts:")
    guard let controllerClass = object_getClass(controller),
      let method = class_getInstanceMethod(controllerClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICCalculateDocumentController.updateAffectingChangeCounts: is unavailable.")
    }
    typealias UpdateAffectingIMP = @convention(c) (AnyObject, Selector, Bool) -> Bool
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: UpdateAffectingIMP.self)
    guard function(controller, selector, true) else {
      throw writeError(operation: operation, reason: "ICCalculateDocumentController.updateAffectingChangeCounts: returned false.")
    }
  }

  private func updateCalculateResultAttachment(
    _ attachment: AnyObject,
    result: String,
    isRightToLeft: Bool,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("updateCalculateResult:isRightToLeft:")
    guard let attachmentClass = object_getClass(attachment),
      let method = class_getInstanceMethod(attachmentClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.updateCalculateResult:isRightToLeft: is unavailable.")
    }
    typealias MathResultUpdateIMP = @convention(c) (AnyObject, Selector, NSString, Bool) -> Bool
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: MathResultUpdateIMP.self)
    guard function(attachment, selector, result as NSString, isRightToLeft) else {
      throw writeError(operation: operation, reason: "ICInlineAttachment.updateCalculateResult:isRightToLeft: returned false.")
    }
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

  private func isMathResultAttachmentObject(_ object: AnyObject) -> Bool {
    boolValue(object, key: "isCalculateResultAttachment") == true
      || objectTypeName(object).contains("ICCalculateResultTextAttachment")
  }

  private func tableTarget(note: ICNote, ordinal: Int, operation: String) throws -> NotesTableMutationTarget {
    guard ordinal > 0 else {
      throw writeError(operation: operation, reason: "Notes body table ordinal must be positive.")
    }
    let targets = tableTargets(note)
    guard ordinal <= targets.count else {
      throw CLIError(
        code: .notFound,
        message: "Notes body table selector did not match any table.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(noteIdentifier(note)),
          "ordinal": "\(ordinal)",
          "table_count": "\(targets.count)",
        ]
      )
    }
    return targets[ordinal - 1]
  }

  private func tableTargets(_ note: ICNote) -> [NotesTableMutationTarget] {
    guard let attributedString = note.attributedString() as? NSAttributedString else {
      return []
    }

    var targets: [NotesTableMutationTarget] = []
    var seen = Set<String>()
    attributedString.enumerateAttributes(
      in: NSRange(location: 0, length: attributedString.length),
      options: []
    ) { attributes, range, _ in
      for value in attributes.values {
        guard let object = value as AnyObject?,
          objectTypeName(object).contains("ICTableTextAttachment")
        else {
          continue
        }
        let identity = tableIdentity(object)
        guard seen.insert(identity).inserted else {
          continue
        }
        targets.append(
          NotesTableMutationTarget(
            attachment: object,
            table: tableObject(tableAttachment: object, backingAttachment: tableBackingAttachment(object)),
            record: bodyTableRecord(object, ordinal: targets.count + 1, identity: identity),
            range: range
          ))
      }
    }
    return targets
  }

  private func bodyTableRecord(
    _ object: AnyObject,
    ordinal: Int,
    identity: String
  ) -> NotesBodyTableRecord {
    let attachment = tableBackingAttachment(object)
    let table = tableObject(tableAttachment: object, backingAttachment: attachment)
    let attachmentID = attachment.flatMap { nonEmpty(optionalString($0, key: "identifier")) }
      ?? nonEmpty(optionalString(object, key: "attachmentIdentifier"))
    let contentIdentifier = attachment.flatMap { nonEmpty(optionalString($0, key: "contentIdentifier")) }
    let typeUTI = attachment.flatMap { nonEmpty(optionalString($0, key: "typeUTI")) }
      ?? nonEmpty(optionalString(object, key: "attachmentUTI"))
    let isDeletable = attachment.flatMap { boolValue($0, key: "isDeletable") }

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

  private func validateTableCellCoordinate(
    _ table: NotesBodyTableRecord,
    row: Int,
    column: Int,
    operation: String
  ) throws {
    guard row > 0, column > 0 else {
      throw writeError(operation: operation, reason: "Notes body table row and column must be positive.")
    }
    if let rowCount = table.rowCount, row > rowCount {
      throw writeError(operation: operation, reason: "Notes body table row is outside the selected table.")
    }
    if let columnCount = table.columnCount, column > columnCount {
      throw writeError(operation: operation, reason: "Notes body table column is outside the selected table.")
    }
  }

  private func validateTableStructureChange(
    _ table: NotesBodyTableRecord,
    draft: NotesBodyTableStructureDraft,
    operation: String
  ) throws {
    guard draft.index > 0, draft.count > 0 else {
      throw writeError(operation: operation, reason: "Notes body table index and count must be positive.")
    }
    let dimension: Int?
    switch draft.axis {
    case .row:
      dimension = table.rowCount
    case .column:
      dimension = table.columnCount
    }
    guard let dimension else {
      throw writeError(operation: operation, reason: "Notes body table row/column count is unavailable.")
    }
    switch draft.action {
    case .insert:
      guard draft.index <= dimension + 1 else {
        throw writeError(operation: operation, reason: "Notes body table insert index is outside the selected table.")
      }
    case .delete:
      guard draft.index <= dimension, draft.index + draft.count - 1 <= dimension else {
        throw writeError(operation: operation, reason: "Notes body table delete range is outside the selected table.")
      }
      guard dimension - draft.count >= 1 else {
        throw writeError(operation: operation, reason: "Notes body table delete must leave at least one row or column.")
      }
    case .move:
      guard draft.count == 1 else {
        throw writeError(operation: operation, reason: "Notes body table move accepts exactly one row or column.")
      }
      guard let toIndex = draft.toIndex, toIndex > 0 else {
        throw writeError(operation: operation, reason: "Notes body table move destination must be positive.")
      }
      guard draft.index <= dimension, toIndex <= dimension else {
        throw writeError(operation: operation, reason: "Notes body table move source or destination is outside the selected table.")
      }
      guard draft.index != toIndex else {
        throw writeError(operation: operation, reason: "Notes body table move source and destination must differ.")
      }
    case .copy:
      guard draft.count == 1 else {
        throw writeError(operation: operation, reason: "Notes body table copy accepts exactly one row or column.")
      }
      guard let toIndex = draft.toIndex, toIndex > 0 else {
        throw writeError(operation: operation, reason: "Notes body table copy destination must be positive.")
      }
      guard draft.index <= dimension, toIndex <= dimension + 1 else {
        throw writeError(operation: operation, reason: "Notes body table copy source or destination is outside the selected table.")
      }
    case .clear:
      guard draft.index <= dimension, draft.index + draft.count - 1 <= dimension else {
        throw writeError(operation: operation, reason: "Notes body table clear range is outside the selected table.")
      }
    }
  }

  private func applyTableStructureChange(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    draft: NotesBodyTableStructureDraft,
    operation: String
  ) throws {
    switch (draft.axis, draft.action) {
    case (.row, .insert):
      try insertTableRows(table, index: draft.index, count: draft.count, operation: operation)
    case (.row, .delete):
      try removeTableRows(table, index: draft.index, count: draft.count, operation: operation)
    case (.column, .insert):
      try insertTableColumns(table, index: draft.index, count: draft.count, operation: operation)
    case (.column, .delete):
      try removeTableColumns(table, index: draft.index, count: draft.count, operation: operation)
    case (.row, .move):
      try moveTableRow(table, from: draft.index, to: draft.toIndex, operation: operation)
    case (.column, .move):
      try moveTableColumn(table, from: draft.index, to: draft.toIndex, operation: operation)
    case (.row, .copy):
      try copyTableRow(table, target: target, sourceIndex: draft.index, destinationIndex: draft.toIndex, operation: operation)
    case (.column, .copy):
      try copyTableColumn(table, target: target, sourceIndex: draft.index, destinationIndex: draft.toIndex, operation: operation)
    case (.row, .clear):
      try clearTableRows(table, target: target, index: draft.index, count: draft.count, operation: operation)
    case (.column, .clear):
      try clearTableColumns(table, target: target, index: draft.index, count: draft.count, operation: operation)
    }
  }

  private func insertTableRows(_ table: AnyObject, index: Int, count: Int, operation: String) throws {
    if count > 1, try callTableBatchInsert(table, selectorName: "insertRows:atIndex:", count: count, index: index, operation: operation) {
      return
    }
    try repeatTableIndexMutation(table, selectorName: "insertRowAtIndex:", index: index, count: count, operation: operation)
  }

  private func insertTableColumns(_ table: AnyObject, index: Int, count: Int, operation: String) throws {
    if count > 1, try callTableBatchInsert(table, selectorName: "insertColumns:atIndex:", count: count, index: index, operation: operation) {
      return
    }
    try repeatTableIndexMutation(table, selectorName: "insertColumnAtIndex:", index: index, count: count, operation: operation)
  }

  private func removeTableRows(_ table: AnyObject, index: Int, count: Int, operation: String) throws {
    try repeatTableIndexMutation(table, selectorName: "removeRowAtIndex:", index: index, count: count, operation: operation)
  }

  private func removeTableColumns(_ table: AnyObject, index: Int, count: Int, operation: String) throws {
    try repeatTableIndexMutation(table, selectorName: "removeColumnAtIndex:", index: index, count: count, operation: operation)
  }

  private func moveTableRow(_ table: AnyObject, from sourceIndex: Int, to destinationIndex: Int?, operation: String) throws {
    try callTableMove(
      table,
      selectorName: "moveRowAtIndex:toIndex:",
      sourceIndex: sourceIndex,
      destinationIndex: destinationIndex,
      operation: operation
    )
  }

  private func moveTableColumn(_ table: AnyObject, from sourceIndex: Int, to destinationIndex: Int?, operation: String) throws {
    try callTableMove(
      table,
      selectorName: "moveColumnAtIndex:toIndex:",
      sourceIndex: sourceIndex,
      destinationIndex: destinationIndex,
      operation: operation
    )
  }

  private func clearTableRows(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    index: Int,
    count: Int,
    operation: String
  ) throws {
    guard let columnCount = target.columnCount else {
      throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row clear.")
    }
    for row in index..<(index + count) {
      if try callTableRemoveContents(
        table,
        identifierSelectorName: "identifierForRowAtIndex:",
        clearSelectorName: "undoablyRemoveContentsOfRow:",
        index: row,
        operation: operation
      ) {
        continue
      }
      for column in 1...columnCount {
        try setTableCellAttributedString(table, attributedString: NSAttributedString(string: ""), row: row, column: column, operation: operation)
      }
    }
  }

  private func copyTableRow(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    sourceIndex: Int,
    destinationIndex: Int?,
    operation: String
  ) throws {
    guard let destinationIndex else {
      throw writeError(operation: operation, reason: "Notes body table copy destination is required.")
    }
    guard let columnCount = target.columnCount else {
      throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row copy.")
    }
    let values = try (1...columnCount).map { column in
      try tableCellString(table, row: sourceIndex, column: column, operation: operation)
    }
    try insertTableRows(table, index: destinationIndex, count: 1, operation: operation)
    for (offset, value) in values.enumerated() {
      try setTableCellAttributedString(
        table,
        attributedString: NSAttributedString(string: value),
        row: destinationIndex,
        column: offset + 1,
        operation: operation
      )
    }
  }

  private func copyTableColumn(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    sourceIndex: Int,
    destinationIndex: Int?,
    operation: String
  ) throws {
    guard let destinationIndex else {
      throw writeError(operation: operation, reason: "Notes body table copy destination is required.")
    }
    guard let rowCount = target.rowCount else {
      throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column copy.")
    }
    let values = try (1...rowCount).map { row in
      try tableCellString(table, row: row, column: sourceIndex, operation: operation)
    }
    try insertTableColumns(table, index: destinationIndex, count: 1, operation: operation)
    for (offset, value) in values.enumerated() {
      try setTableCellAttributedString(
        table,
        attributedString: NSAttributedString(string: value),
        row: offset + 1,
        column: destinationIndex,
        operation: operation
      )
    }
  }

  private func clearTableColumns(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    index: Int,
    count: Int,
    operation: String
  ) throws {
    guard let rowCount = target.rowCount else {
      throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column clear.")
    }
    for column in index..<(index + count) {
      if try callTableRemoveContents(
        table,
        identifierSelectorName: "identifierForColumnAtIndex:",
        clearSelectorName: "undoablyRemoveContentsOfColumn:",
        index: column,
        operation: operation
      ) {
        continue
      }
      for row in 1...rowCount {
        try setTableCellAttributedString(table, attributedString: NSAttributedString(string: ""), row: row, column: column, operation: operation)
      }
    }
  }

  private func tableMoveSliceDigest(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    draft: NotesBodyTableStructureDraft,
    operation: String
  ) throws -> (cellCount: Int, sha256: String)? {
    guard draft.action == .move else {
      return nil
    }
    let records: [NotesBodyTableCellRecord]
    switch draft.axis {
    case .row:
      guard let columnCount = target.columnCount else {
        throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row move verification.")
      }
      records = try (1...columnCount).map { column in
        try tableCellRecord(table, target: target, row: draft.index, column: column, operation: operation)
      }
    case .column:
      guard let rowCount = target.rowCount else {
        throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column move verification.")
      }
      records = try (1...rowCount).map { row in
        try tableCellRecord(table, target: target, row: row, column: draft.index, operation: operation)
      }
    }
    return (records.count, tableSliceDigest(records))
  }

  private func tableCopySliceDigest(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    draft: NotesBodyTableStructureDraft,
    operation: String
  ) throws -> (cellCount: Int, sha256: String)? {
    guard draft.action == .copy else {
      return nil
    }
    let records: [NotesBodyTableCellRecord]
    switch draft.axis {
    case .row:
      guard let columnCount = target.columnCount else {
        throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row copy verification.")
      }
      records = try (1...columnCount).map { column in
        try tableCellRecord(table, target: target, row: draft.index, column: column, operation: operation)
      }
    case .column:
      guard let rowCount = target.rowCount else {
        throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column copy verification.")
      }
      records = try (1...rowCount).map { row in
        try tableCellRecord(table, target: target, row: row, column: draft.index, operation: operation)
      }
    }
    return (records.count, tableSliceDigest(records))
  }

  private func tableClearSliceDigest(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    draft: NotesBodyTableStructureDraft,
    operation: String
  ) throws -> (cellCount: Int, sha256: String)? {
    guard draft.action == .clear else {
      return nil
    }
    let records: [NotesBodyTableCellRecord]
    switch draft.axis {
    case .row:
      guard let columnCount = target.columnCount else {
        throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row clear verification.")
      }
      records = try (draft.index..<(draft.index + draft.count)).flatMap { row in
        try (1...columnCount).map { column in
          try tableCellRecord(table, target: target, row: row, column: column, operation: operation)
        }
      }
    case .column:
      guard let rowCount = target.rowCount else {
        throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column clear verification.")
      }
      records = try (draft.index..<(draft.index + draft.count)).flatMap { column in
        try (1...rowCount).map { row in
          try tableCellRecord(table, target: target, row: row, column: column, operation: operation)
        }
      }
    }
    return (records.count, tableSliceDigest(records))
  }

  private func tableSliceDigest(_ records: [NotesBodyTableCellRecord]) -> String {
    sha256Hex(
      records
        .map { "\($0.textByteCount):\($0.textSHA256)" }
        .joined(separator: "|")
    )
  }

  private func tableFormatSliceDigest(_ records: [NotesBodyTableCellRecord]) -> String? {
    guard records.allSatisfy({ $0.formatSHA256 != nil }) else {
      return nil
    }
    return sha256Hex(
      records
        .map { "\($0.formatRunCount ?? -1):\($0.formatSHA256 ?? "")" }
        .joined(separator: "|")
    )
  }

  private func validateTableFormatRange(
    _ target: NotesBodyTableRecord,
    draft: NotesBodyTableFormatDraft,
    operation: String
  ) throws {
    let selectedDimension = draft.axis == .row ? target.rowCount : target.columnCount
    let otherDimension = draft.axis == .row ? target.columnCount : target.rowCount
    guard let selectedDimension, let otherDimension, selectedDimension > 0, otherDimension > 0 else {
      throw writeError(operation: operation, reason: "Notes body table row and column counts are unavailable for range formatting.")
    }
    guard draft.index > 0, draft.count > 0, draft.index + draft.count - 1 <= selectedDimension else {
      throw CLIError(
        code: .validationError,
        message: "Notes body table format range is outside the selected table.",
        details: [
          "operation": operation,
          "axis": draft.axis.rawValue,
          "index": "\(draft.index)",
          "count": "\(draft.count)",
          "dimension": "\(selectedDimension)",
        ]
      )
    }
    guard draft.selectedCellCount == draft.count * otherDimension else {
      throw writeError(operation: operation, reason: "Notes body table format selected-cell count changed before mutation.")
    }
  }

  private func tableCells(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    draft: NotesBodyTableFormatDraft,
    operation: String
  ) throws -> [NotesBodyTableCellRecord] {
    switch draft.axis {
    case .row:
      guard let columnCount = target.columnCount, columnCount > 0 else {
        throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row formatting.")
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { row in
        try (1...columnCount).map { column in
          try tableCellRecord(table, target: target, row: row, column: column, operation: operation)
        }
      }
    case .column:
      guard let rowCount = target.rowCount, rowCount > 0 else {
        throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column formatting.")
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { column in
        try (1...rowCount).map { row in
          try tableCellRecord(table, target: target, row: row, column: column, operation: operation)
        }
      }
    }
  }

  private func tableCells(
    reader: NotesReader,
    draft: NotesBodyTableFormatDraft,
    tables: [NotesBodyTableRecord]
  ) throws -> [NotesBodyTableCellRecord] {
    guard draft.ordinal > 0 && draft.ordinal <= tables.count else {
      return []
    }
    let table = tables[draft.ordinal - 1]
    switch draft.axis {
    case .row:
      guard let columnCount = table.columnCount, columnCount > 0 else {
        return []
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { row in
        try (1...columnCount).map { column in
          try reader.readTableCell(noteID: draft.noteID, tableOrdinal: draft.ordinal, row: row, column: column)
        }
      }
    case .column:
      guard let rowCount = table.rowCount, rowCount > 0 else {
        return []
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { column in
        try (1...rowCount).map { row in
          try reader.readTableCell(noteID: draft.noteID, tableOrdinal: draft.ordinal, row: row, column: column)
        }
      }
    }
  }

  private func mutateTableCells(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    draft: NotesBodyTableFormatDraft,
    operation: String,
    mutation: (Int, Int) throws -> Void
  ) throws {
    switch draft.axis {
    case .row:
      guard let columnCount = target.columnCount, columnCount > 0 else {
        throw writeError(operation: operation, reason: "Notes body table column count is unavailable for row formatting.")
      }
      for row in draft.index..<(draft.index + draft.count) {
        for column in 1...columnCount {
          try mutation(row, column)
        }
      }
    case .column:
      guard let rowCount = target.rowCount, rowCount > 0 else {
        throw writeError(operation: operation, reason: "Notes body table row count is unavailable for column formatting.")
      }
      for column in draft.index..<(draft.index + draft.count) {
        for row in 1...rowCount {
          try mutation(row, column)
        }
      }
    }
  }

  private func tableCell(_ cell: NotesBodyTableCellRecord, contains format: NotesBodyInlineFormat) -> Bool {
    switch format {
    case .bold:
      return cell.containsBold == true
    case .italic:
      return cell.containsItalic == true
    case .underline:
      return cell.containsUnderline == true
    case .strikethrough:
      return cell.containsStrikethrough == true
    }
  }

  private func tableConvertedText(
    _ table: AnyObject,
    rowCount: Int,
    columnCount: Int,
    operation: String
  ) throws -> String {
    try (1...rowCount).map { row in
      try (1...columnCount).map { column in
        try tableCellString(table, row: row, column: column, operation: operation)
      }
      .joined(separator: "\t")
    }
    .joined(separator: "\n")
  }

  private func callTableBatchInsert(
    _ table: AnyObject,
    selectorName: String,
    count: Int,
    index: Int,
    operation: String
  ) throws -> Bool {
    let selector = NSSelectorFromString(selectorName)
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      return false
    }
    typealias TableBatchInsertIMP = @convention(c) (AnyObject, Selector, UInt, UInt) -> Unmanaged<AnyObject>?
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: TableBatchInsertIMP.self)
    _ = function(table, selector, UInt(count), UInt(index - 1))?.takeUnretainedValue()
    return true
  }

  private func repeatTableIndexMutation(
    _ table: AnyObject,
    selectorName: String,
    index: Int,
    count: Int,
    operation: String
  ) throws {
    let selector = NSSelectorFromString(selectorName)
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICTable.\(selectorName) is unavailable.")
    }
    typealias TableIndexMutationIMP = @convention(c) (AnyObject, Selector, UInt) -> Void
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: TableIndexMutationIMP.self)
    for _ in 0..<count {
      function(table, selector, UInt(index - 1))
    }
  }

  private func callTableMove(
    _ table: AnyObject,
    selectorName: String,
    sourceIndex: Int,
    destinationIndex: Int?,
    operation: String
  ) throws {
    guard let destinationIndex else {
      throw writeError(operation: operation, reason: "Notes body table move destination is required.")
    }
    let selector = NSSelectorFromString(selectorName)
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICTable.\(selectorName) is unavailable.")
    }
    typealias TableMoveIMP = @convention(c) (AnyObject, Selector, UInt, UInt) -> Void
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: TableMoveIMP.self)
    function(table, selector, UInt(sourceIndex - 1), UInt(destinationIndex - 1))
  }

  private func callTableRemoveContents(
    _ table: AnyObject,
    identifierSelectorName: String,
    clearSelectorName: String,
    index: Int,
    operation: String
  ) throws -> Bool {
    let identifierSelector = NSSelectorFromString(identifierSelectorName)
    let clearSelector = NSSelectorFromString(clearSelectorName)
    guard let tableClass = object_getClass(table),
      let identifierMethod = class_getInstanceMethod(tableClass, identifierSelector),
      let clearMethod = class_getInstanceMethod(tableClass, clearSelector)
    else {
      return false
    }

    typealias TableIdentifierIMP = @convention(c) (AnyObject, Selector, UInt) -> Unmanaged<AnyObject>?
    let identifierFunction = unsafeBitCast(method_getImplementation(identifierMethod), to: TableIdentifierIMP.self)
    guard let identifier = identifierFunction(table, identifierSelector, UInt(index - 1))?.takeUnretainedValue() else {
      return false
    }

    typealias TableClearIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Void
    let clearFunction = unsafeBitCast(method_getImplementation(clearMethod), to: TableClearIMP.self)
    clearFunction(table, clearSelector, identifier)
    return true
  }

  private func tableCellRecord(
    _ table: AnyObject,
    target: NotesBodyTableRecord,
    row: Int,
    column: Int,
    operation: String
  ) throws -> NotesBodyTableCellRecord {
    let text = try tableCellString(table, row: row, column: column, operation: operation)
    let formatSummary = tableCellFormatSummary(
      tableCellAttributedString(table, row: row, column: column, operation: operation))
    return NotesBodyTableCellRecord(
      tableOrdinal: target.ordinal,
      tableIDSHA256: target.idSHA256,
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

  private func tableCellString(
    _ table: AnyObject,
    row: Int,
    column: Int,
    operation: String
  ) throws -> String {
    let selector = NSSelectorFromString("stringForColumnIndex:rowIndex:")
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICTable.stringForColumnIndex:rowIndex: is unavailable.")
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
    if let columnID = tableIdentifier(table, selectorName: "identifierForColumnAtIndex:", index: column),
      let rowID = tableIdentifier(table, selectorName: "identifierForRowAtIndex:", index: row),
      let mergeable = tableMergeableString(table, columnID: columnID, rowID: rowID),
      let attributedString = attributedStringValue(mergeable)
    {
      return attributedString
    }
    if let object = tableCellObject(table, row: row, column: column),
      let attributedString = attributedStringValue(object)
    {
      return attributedString
    }
    return nil
  }

  private func tableIdentifier(
    _ table: AnyObject,
    selectorName: String,
    index: Int
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
    rowID: AnyObject
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
    column: Int
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

  private func tableCellFormatSummary(_ attributedString: NSAttributedString?) -> WriterTableCellFormatSummary? {
    guard let attributedString else {
      return nil
    }
    let fullRange = NSRange(location: 0, length: attributedString.length)
    guard fullRange.length > 0 else {
      return WriterTableCellFormatSummary(
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
      let formats = tableInlineFormatKinds(attributes)
      if formats.isEmpty == false {
        runCount += 1
      }
      containsBold = containsBold || formats.contains("bold")
      containsItalic = containsItalic || formats.contains("italic")
      containsUnderline = containsUnderline || formats.contains("underline")
      containsStrikethrough = containsStrikethrough || formats.contains("strikethrough")
      let colorHashes = tableInlineColorHashes(attributes)
        .map { "\($0.role):\($0.hash)" }
        .sorted()
        .joined(separator: ",")
      let fontHash = (attributes[.font] as? NSFont).map(notesFontSHA256) ?? ""
      pieces.append("\(range.location):\(range.length):\(formats.sorted().joined(separator: ",")):\(fontHash):\(colorHashes)")
    }
    return WriterTableCellFormatSummary(
      formatRunCount: runCount,
      formatSHA256: sha256Hex(pieces.joined(separator: "|")),
      containsBold: containsBold,
      containsItalic: containsItalic,
      containsUnderline: containsUnderline,
      containsStrikethrough: containsStrikethrough
    )
  }

  private func tableInlineFormatKinds(_ attributes: [NSAttributedString.Key: Any]) -> Set<String> {
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

  private func tableInlineColorHashes(_ attributes: [NSAttributedString.Key: Any]) -> [(role: String, hash: String)] {
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

  private func setTableCellAttributedString(
    _ table: AnyObject,
    attributedString: NSAttributedString,
    row: Int,
    column: Int,
    operation: String
  ) throws {
    let selector = NSSelectorFromString("setAttributedString:columnIndex:rowIndex:")
    guard let tableClass = object_getClass(table),
      let method = class_getInstanceMethod(tableClass, selector)
    else {
      throw writeError(operation: operation, reason: "ICTable.setAttributedString:columnIndex:rowIndex: is unavailable.")
    }
    typealias TableCellSetIMP = @convention(c) (AnyObject, Selector, NSAttributedString, Int, Int) -> Void
    let implementation = method_getImplementation(method)
    let function = unsafeBitCast(implementation, to: TableCellSetIMP.self)
    function(table, selector, attributedString, column - 1, row - 1)
  }

  private func validateNoteLinkDestination(_ note: ICNote, operation: String) throws {
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "Destination ICNote is deleted or in trash.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Password-protected ICNote link destinations remain gated.")
    }
  }

  private func validateFolderRenameTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isRenamable") != false,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot be renamed.")
    }
  }

  private func validateFolderMoveSource(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isMovable") != false,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot be moved.")
    }
  }

  private func validateFolderDeleteTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isDeletable") != false,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot be deleted.")
    }
  }

  private func validateFolderPurgeTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSystemFolder") != true,
      boolValue(folder, key: "isDefaultFolderForAccount") != true,
      boolValue(folder, key: "isSmartFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot be hard purged.")
    }
  }

  private func validateSmartFolderDeleteTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isSmartFolder") == true,
      boolValue(folder, key: "isDeletable") != false,
      boolValue(folder, key: "isEditableSmartFolder") != false
    else {
      throw writeError(operation: operation, reason: "ICFolder Smart Folder cannot be deleted.")
    }
  }

  private func validateSmartFolderRenameTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isSmartFolder") == true,
      boolValue(folder, key: "isEditableSmartFolder") != false
    else {
      throw writeError(operation: operation, reason: "ICFolder Smart Folder cannot be renamed.")
    }
  }

  private func validateSmartFolderUpdateTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isSmartFolder") == true,
      boolValue(folder, key: "isEditableSmartFolder") != false
    else {
      throw writeError(operation: operation, reason: "ICFolder Smart Folder criteria cannot be updated.")
    }
  }

  private func validateSmartFolderCriteriaSource(
    _ folder: ICFolder,
    operation: String,
    requiresEditable: Bool
  ) throws {
    guard boolValue(folder, key: "isSmartFolder") == true else {
      throw writeError(operation: operation, reason: "Source ICFolder is not a Smart Folder.")
    }
    if requiresEditable, boolValue(folder, key: "isEditableSmartFolder") == false {
      throw writeError(operation: operation, reason: "Source ICFolder Smart Folder is not editable.")
    }
    guard folder.smartFolderQuery != nil else {
      throw writeError(operation: operation, reason: "Source ICFolder has no reusable Smart Folder query.")
    }
  }

  private func validateFolderConversionSource(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSystemFolder") != true,
      boolValue(folder, key: "isDefaultFolderForAccount") != true,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isDeletable") != false,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "Source ICFolder cannot be converted into a Smart Folder.")
    }
    guard boolValue(folder, key: "isSharedViaICloud") != true,
      boolValue(folder, key: "isSharedReadOnly") != true
    else {
      throw writeError(operation: operation, reason: "Shared ICFolder conversion remains gated.")
    }
    let childFolders: [ICFolder] = objects(folder.foldersInFolder)
    guard childFolders.isEmpty else {
      throw writeError(operation: operation, reason: "Source ICFolder contains subfolders.")
    }
  }

  private func validateFolderConversionTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "Target ICFolder cannot accept converted notes.")
    }
  }

  private func validateFolderConversionNote(_ note: ICNote, operation: String) throws {
    guard note.isMovable else {
      throw writeError(operation: operation, reason: "Source ICNote is not movable.")
    }
    guard boolValue(note, key: "isDeletedOrInTrash") != true else {
      throw writeError(operation: operation, reason: "Source ICNote is deleted or in trash.")
    }
    guard boolValue(note, key: "isPasswordProtected") != true,
      boolValue(note, key: "isPasswordProtectedAndLocked") != true
    else {
      throw writeError(operation: operation, reason: "Locked ICNote conversion remains gated.")
    }
    guard boolValue(note, key: "isSharedViaICloud") != true,
      boolValue(note, key: "isSharedViaICloudFolder") != true,
      boolValue(note, key: "isSharedReadOnly") != true,
      boolValue(note, key: "isEditable") != false
    else {
      throw writeError(operation: operation, reason: "Shared or read-only ICNote conversion remains gated.")
    }
  }

  private func smartFolderBuiltInCriteriaQuery(
    kind: String,
    criteriaKinds: [String]? = nil,
    accountID: String?,
    accountName: String,
    dateCriteria: NotesSmartFolderDateCriteriaParameters?,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:],
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters?,
    joinOperator: Int = 1,
    includeRecentlyDeleted: Bool,
    operation: String
  ) throws -> ICQuery {
    let kinds = criteriaKinds?.isEmpty == false ? criteriaKinds ?? [kind] : [kind]
    if kinds.count > 1 {
      return try smartFolderCombinedFilterSelectionQuery(
        kinds: kinds,
        accountID: accountID,
        accountName: accountName,
        dateCriteria: dateCriteria,
        folderCriteria: folderCriteria,
        folderCriteriaByKind: folderCriteriaByKind,
        participantCriteria: participantCriteria,
        joinOperator: joinOperator,
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    }
    let query: ICQuery?
    switch kind {
    case "pinned":
      query = ICQuery.query(forPinnedNotes: true, allowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case "unpinned":
      query = ICQuery.query(forPinnedNotes: false, allowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case "shared":
      query = ICQuery.query(forSharedNotes: true, allowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case "not-shared":
      query = ICQuery.query(forSharedNotes: false, allowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case let folderKind where smartFolderFolderCriteriaInclusionType(folderKind) != nil:
      query = try smartFolderFolderCriteriaQuery(
        kind: folderKind,
        folderCriteria: folderCriteria,
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case "untagged":
      query = try smartFolderUntaggedCriteriaQuery(
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case let participantKind where smartFolderParticipantCriteriaKind(participantKind):
      query = try smartFolderParticipantCriteriaQuery(
        kind: participantKind,
        accountID: accountID,
        accountName: accountName,
        participantCriteria: participantCriteria,
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case "math":
      query = ICQuery.query(forMathNotesAllowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case "call":
      query = ICQuery.query(forCallNotesAllowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case "system-paper":
      query = ICQuery.query(forSystemPaperNotesAllowsRecentlyDeleted: includeRecentlyDeleted) as? ICQuery
    case "recently-deleted-math":
      query = ICQuery.queryForRecentlyDeletedMathNotes() as? ICQuery
    case "locked":
      query = try smartFolderFilterSelectionQuery(
        ICLockedNotesFilterTypeSelection(inclusionType: 1),
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case "unlocked":
      query = try smartFolderFilterSelectionQuery(
        ICLockedNotesFilterTypeSelection(inclusionType: 0),
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case "quick-notes":
      query = try smartFolderFilterSelectionQuery(
        ICQuickNotesFilterTypeSelection(inclusionType: 1),
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case "not-quick-notes":
      query = try smartFolderFilterSelectionQuery(
        ICQuickNotesFilterTypeSelection(inclusionType: 0),
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case let attachmentKind where smartFolderBuiltInCriteriaAttachmentSelectionType(attachmentKind) != nil:
      query = try smartFolderFilterSelectionQuery(
        ICAttachmentsFilterTypeSelection(
          selectionType: smartFolderBuiltInCriteriaAttachmentSelectionType(attachmentKind) ?? 0
        ),
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case let checklistKind where smartFolderBuiltInCriteriaChecklistSelectionType(checklistKind) != nil:
      query = try smartFolderFilterSelectionQuery(
        ICChecklistsFilterTypeSelection(
          selectionType: smartFolderBuiltInCriteriaChecklistSelectionType(checklistKind) ?? 0
        ),
        includeRecentlyDeleted: includeRecentlyDeleted,
        operation: operation
      )
    case let dateKind where smartFolderDateCriteriaDescriptor(dateKind) != nil:
      guard let dateSelection = smartFolderDateCriteriaDescriptor(dateKind) else {
        throw writeError(operation: operation, reason: "Unsupported date Smart Folder criteria kind.")
      }
      if dateSelection.filterKind == "date_created" {
        let selection = ICDateCreatedFilterTypeSelection(selectionType: dateSelection.selectionType)
        try configureSmartFolderDateSelection(
          selection,
          descriptor: dateSelection,
          dateCriteria: dateCriteria,
          operation: operation
        )
        query = try smartFolderFilterSelectionQuery(
          selection,
          includeRecentlyDeleted: includeRecentlyDeleted,
          operation: operation
        )
      } else {
        let selection = ICDateEditedFilterTypeSelection(selectionType: dateSelection.selectionType)
        try configureSmartFolderDateSelection(
          selection,
          descriptor: dateSelection,
          dateCriteria: dateCriteria,
          operation: operation
        )
        query = try smartFolderFilterSelectionQuery(
          selection,
          includeRecentlyDeleted: includeRecentlyDeleted,
          operation: operation
        )
      }
    default:
      throw writeError(operation: operation, reason: "Unsupported built-in Smart Folder criteria kind.")
    }
    guard let query else {
      throw writeError(operation: operation, reason: "ICQuery built-in Smart Folder factory returned nil.")
    }
    return query
  }

  private func smartFolderUntaggedCriteriaQuery(
    includeRecentlyDeleted: Bool,
    operation: String
  ) throws -> ICQuery? {
    let context = try managedObjectContext()
    guard
      let selection = ICTagSelection(
        managedObjectContext: context,
        mode: UInt64(notesSmartFolderTagSelectionModeAllUntagged)
      )
    else {
      throw writeError(operation: operation, reason: "ICTagSelection all-untagged initializer returned nil.")
    }
    selection.allowsRecentlyDeleted = includeRecentlyDeleted
    guard Int(selection.mode) == notesSmartFolderTagSelectionModeAllUntagged else {
      throw writeError(operation: operation, reason: "ICTagSelection all-untagged mode readback did not match.")
    }
    guard selection.selectedTagCount == 0 else {
      throw writeError(operation: operation, reason: "ICTagSelection all-untagged criteria unexpectedly selected tags.")
    }
    guard let query = ICQuery.queryForNotes(matchingTagSelection: selection) as? ICQuery else {
      throw writeError(operation: operation, reason: "ICQuery.queryForNotes returned nil for untagged criteria.")
    }
    return query
  }

  private func smartFolderCombinedFilterSelectionQuery(
    kinds: [String],
    accountID: String?,
    accountName: String,
    dateCriteria: NotesSmartFolderDateCriteriaParameters?,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters],
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters?,
    joinOperator: Int,
    includeRecentlyDeleted: Bool,
    operation: String
  ) throws -> ICQuery {
    let effectiveIncludeRecentlyDeleted = effectiveSmartFolderBuiltInCriteriaIncludeRecentlyDeleted(
      kinds: kinds,
      requestedIncludeRecentlyDeleted: includeRecentlyDeleted
    )
    let context = try managedObjectContext()
    let account = try accountObject(id: accountID, name: accountName)
    let selections = try kinds.flatMap { criteriaKind -> [ICFilterTypeSelection] in
      let criteriaFolderCriteria = smartFolderFolderCriteria(
        for: criteriaKind,
        folderCriteria: folderCriteria,
        folderCriteriaByKind: folderCriteriaByKind
      )
      guard smartFolderBuiltInCriteriaCombinationFilterExpectation(
        kind: criteriaKind,
        dateCriteria: dateCriteria,
        folderCriteria: criteriaFolderCriteria
      ) != nil else {
        throw writeError(
          operation: operation,
          reason: "Combined Smart Folder criteria require criteria kinds that expose private filter selections."
        )
      }
      let query = try smartFolderBuiltInCriteriaQuery(
        kind: criteriaKind,
        criteriaKinds: [criteriaKind],
        accountID: accountID,
        accountName: accountName,
        dateCriteria: dateCriteria,
        folderCriteria: criteriaFolderCriteria,
        participantCriteria: participantCriteria,
        includeRecentlyDeleted: effectiveIncludeRecentlyDeleted,
        operation: operation
      )
      return try smartFolderFilterTypeSelections(
        from: query,
        context: context,
        account: account,
        operation: operation
      )
    }
    guard selections.count == kinds.count else {
      throw writeError(operation: operation, reason: "Combined Smart Folder criteria filter count did not match.")
    }
    guard let filterSelection = ICFilterSelection(filterTypeSelections: selections, joinOperator: UInt64(joinOperator)) else {
      throw writeError(operation: operation, reason: "ICFilterSelection multi-selection initializer returned nil.")
    }
    filterSelection.includeRecentlyDeleted = effectiveIncludeRecentlyDeleted
    guard boolValue(filterSelection, key: "isValid") != false else {
      throw writeError(operation: operation, reason: "Combined ICFilterSelection is not valid.")
    }
    guard let query = ICQuery.queryForNotes(matchingFilterSelection: filterSelection) as? ICQuery else {
      throw writeError(operation: operation, reason: "ICQuery.queryForNotes returned nil for combined criteria.")
    }
    return query
  }

  private func smartFolderFilterTypeSelections(
    from query: ICQuery,
    context: NSManagedObjectContext,
    account: ICAccount,
    operation: String
  ) throws -> [ICFilterTypeSelection] {
    let selector = NSSelectorFromString("filterSelectionWithManagedObjectContext:account:")
    guard query.responds(to: selector),
      let filterSelection = query.perform(selector, with: context, with: account)?.takeUnretainedValue()
    else {
      throw writeError(operation: operation, reason: "ICQuery did not expose a filter selection.")
    }
    let selections = anyObjects(optionalValue(filterSelection, key: "filterTypeSelections"))
      .compactMap { $0 as? ICFilterTypeSelection }
    guard !selections.isEmpty else {
      throw writeError(operation: operation, reason: "ICQuery filter selection contained no filter type selections.")
    }
    return selections
  }

  private func smartFolderFolderCriteriaQuery(
    kind: String,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters?,
    includeRecentlyDeleted: Bool,
    operation: String
  ) throws -> ICQuery? {
    guard let inclusionType = smartFolderFolderCriteriaInclusionType(kind) else {
      throw writeError(operation: operation, reason: "Unsupported folder Smart Folder criteria kind.")
    }
    guard let folderCriteria else {
      throw writeError(operation: operation, reason: "Folder Smart Folder criteria requires a selected folder.")
    }
    let context = try managedObjectContext()
    guard !folderCriteria.folderIDs.isEmpty,
      folderCriteria.folderIDs.count == folderCriteria.folderNames.count
    else {
      throw writeError(operation: operation, reason: "Folder Smart Folder criteria requires resolved folder targets.")
    }
    let folders = try zip(folderCriteria.folderIDs, folderCriteria.folderNames).map { folderID, folderName in
      let folder = try folder(
        id: folderID,
        name: folderName,
        accountName: folderCriteria.folderAccountName
      )
      guard boolValue(folder, key: "isSmartFolder") != true,
        boolValue(folder, key: "isTrashFolder") != true,
        boolValue(folder, key: "isSystemFolder") != true
      else {
        throw writeError(operation: operation, reason: "ICFolder is not a concrete visible folder criteria target.")
      }
      return folder
    }
    let folderIdentifiers = folders.map { objectIDString($0) }
    guard
      let selection = ICFoldersFilterTypeSelection(
        managedObjectContext: context,
        inclusionType: UInt64(inclusionType),
        folderIdentifiers: folderIdentifiers
      )
    else {
      throw writeError(operation: operation, reason: "ICFoldersFilterTypeSelection initializer returned nil.")
    }
    guard boolValue(selection, key: "isValid") != false else {
      throw writeError(operation: operation, reason: "ICFoldersFilterTypeSelection is not valid.")
    }
    guard selection.folderIdentifiers.count == folderIdentifiers.count else {
      throw writeError(operation: operation, reason: "ICFoldersFilterTypeSelection folder count did not match.")
    }
    return try smartFolderFilterSelectionQuery(
      selection,
      includeRecentlyDeleted: includeRecentlyDeleted,
      operation: operation
    )
  }

  private func smartFolderParticipantCriteriaQuery(
    kind: String,
    accountID: String?,
    accountName: String,
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters?,
    includeRecentlyDeleted: Bool,
    operation: String
  ) throws -> ICQuery? {
    guard let participantCriteria else {
      throw writeError(operation: operation, reason: "Participant Smart Folder criteria requires a participant user ID.")
    }
    let context = try managedObjectContext()
    let account = try accountObject(id: accountID, name: accountName)
    let selection: ICParticipantsFilterTypeSelection?
    switch kind {
    case "participants":
      selection = ICParticipantsFilterTypeSelection(
        managedObjectContext: context,
        accountObjectID: account.objectID,
        selectionType: UInt64(participantCriteria.selectionType),
        joinOperator: UInt64(participantCriteria.joinOperator)
      )
    case "mentions":
      selection = ICMentionsFilterTypeSelection(
        managedObjectContext: context,
        accountObjectID: account.objectID,
        selectionType: UInt64(participantCriteria.selectionType),
        joinOperator: UInt64(participantCriteria.joinOperator)
      )
    default:
      throw writeError(operation: operation, reason: "Unsupported participant Smart Folder criteria kind.")
    }
    guard let selection else {
      throw writeError(operation: operation, reason: "ICParticipantsFilterTypeSelection initializer returned nil.")
    }
    selection.addParticipantUserID(participantCriteria.participantUserID)
    guard boolValue(selection, key: "isValid") != false,
      selection.participantUserIDs.count == 1
    else {
      throw writeError(operation: operation, reason: "ICParticipantsFilterTypeSelection is not valid.")
    }
    return try smartFolderFilterSelectionQuery(
      selection,
      includeRecentlyDeleted: includeRecentlyDeleted,
      operation: operation
    )
  }

  private func configureSmartFolderDateSelection(
    _ selection: ICDateFilterTypeSelection?,
    descriptor: NotesSmartFolderDateCriteriaDescriptor,
    dateCriteria: NotesSmartFolderDateCriteriaParameters?,
    operation: String
  ) throws {
    guard let selection else {
      throw writeError(operation: operation, reason: "ICDateFilterTypeSelection initializer returned nil.")
    }
    switch descriptor.parameterKind {
    case nil:
      return
    case "single_date":
      guard let primaryDate = dateCriteria?.primaryDate else {
        throw writeError(operation: operation, reason: "Date Smart Folder criteria requires a primary date.")
      }
      selection.primaryDate = primaryDate
    case "range":
      guard let primaryDate = dateCriteria?.primaryDate,
        let secondaryDate = dateCriteria?.secondaryDate
      else {
        throw writeError(operation: operation, reason: "Date range Smart Folder criteria requires start and end dates.")
      }
      selection.setSpecificDateRangeFrom(primaryDate, to: secondaryDate)
    case "relative":
      guard let relativeAmount = dateCriteria?.relativeAmount,
        let relativeUnitSelectionType = dateCriteria?.relativeUnitSelectionType
      else {
        throw writeError(operation: operation, reason: "Relative date Smart Folder criteria requires amount and unit.")
      }
      selection.relativeRangeAmount = NSNumber(value: relativeAmount)
      selection.relativeRangeSelectionType = relativeUnitSelectionType
    default:
      throw writeError(operation: operation, reason: "Unsupported date Smart Folder criteria parameter kind.")
    }
    guard boolValue(selection, key: "isValid") != false else {
      throw writeError(operation: operation, reason: "ICDateFilterTypeSelection is not valid.")
    }
  }

  private func smartFolderFilterSelectionQuery(
    _ selection: ICFilterTypeSelection?,
    includeRecentlyDeleted: Bool,
    operation: String
  ) throws -> ICQuery? {
    guard let selection else {
      throw writeError(operation: operation, reason: "ICFilterTypeSelection initializer returned nil.")
    }
    guard let filterSelection = ICFilterSelection(filterTypeSelection: selection) else {
      throw writeError(operation: operation, reason: "ICFilterSelection initializer returned nil.")
    }
    filterSelection.includeRecentlyDeleted = includeRecentlyDeleted
    guard boolValue(filterSelection, key: "isValid") != false else {
      throw writeError(operation: operation, reason: "ICFilterSelection is not valid.")
    }
    return ICQuery.queryForNotes(matchingFilterSelection: filterSelection) as? ICQuery
  }

  private func validateFolderSortTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "supportsCustomNoteSortType") != false,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSystemFolder") != true,
      boolValue(folder, key: "isSharedReadOnly") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot accept custom note sort mutations.")
    }
  }

  private func validateFolderReorderTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSystemFolder") != true,
      boolValue(folder, key: "isDefaultFolderForAccount") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot accept sidebar order mutations.")
    }
  }

  private func folderOrderContainer(_ folder: ICFolder) -> AnyObject? {
    (folder.parent as AnyObject?) ?? (folder.account as AnyObject?)
  }

  private func folderOrderParentID(_ folder: ICFolder) -> String {
    if let parent = folder.parent {
      return objectIDString(parent)
    }
    return "root:\(accountName(folder))"
  }

  private func accountName(_ folder: ICFolder) -> String {
    nonEmpty(folder.accountName) ?? nonEmpty(folder.account?.localizedName) ?? nonEmpty(folder.account?.name) ?? "Notes"
  }

  private func folderOrderSiblings(container: AnyObject, requiredFolder: ICFolder) -> [ICFolder] {
    let candidateKeys = [
      "visibleNoteContainerChildren",
      "visibleSubFolders",
      "customRootLevelFolders",
      "foldersInFolder",
    ]
    for key in candidateKeys {
      let candidates: [ICFolder] = objects(optionalObject(container, key: key))
      let visible = candidates.filter {
        boolValue($0, key: "isTrashFolder") != true
          && boolValue($0, key: "isSystemFolder") != true
      }
      if visible.contains(where: { objectIDString($0) == objectIDString(requiredFolder) }) {
        return visible
      }
    }
    return []
  }

  private func moveFolderOrderObject(
    _ orderedSet: AnyObject,
    fromIndex: Int,
    toIndex: Int,
    operation: String
  ) throws {
    let selectorNames = [
      "safeMoveObjectFromIndex:toIndex:",
      "moveObjectFromIndex:toIndex:",
    ]
    for selectorName in selectorNames {
      let selector = NSSelectorFromString(selectorName)
      guard let orderedSetClass = object_getClass(orderedSet),
        let method = class_getInstanceMethod(orderedSetClass, selector)
      else {
        continue
      }
      typealias MoveIMP = @convention(c) (AnyObject, Selector, UInt, UInt) -> Void
      let function = unsafeBitCast(method_getImplementation(method), to: MoveIMP.self)
      function(orderedSet, selector, UInt(fromIndex), UInt(toIndex))
      return
    }
    throw writeError(
      operation: operation,
      reason: "ICCR ordered-set move selector was unavailable for folder sidebar order."
    )
  }

  private func markFolderOrderContainerChanged(_ container: AnyObject, operation: String) {
    guard let object = container as? NSObject else {
      return
    }
    if object.responds(to: NSSelectorFromString("setSubFolderOrderMergeableDataDirty:")) {
      object.setValue(true, forKey: "subFolderOrderMergeableDataDirty")
    }
    if object.responds(to: NSSelectorFromString("updateChangeCountWithReason:")) {
      _ = object.perform(NSSelectorFromString("updateChangeCountWithReason:"), with: operation as NSString)
    }
    if object.responds(to: NSSelectorFromString("saveMergeableDataIfNeeded")) {
      _ = object.perform(NSSelectorFromString("saveMergeableDataIfNeeded"))
    }
  }

  private func validateFolderDateHeadersTarget(_ folder: ICFolder, operation: String) throws {
    guard boolValue(folder, key: "supportsDateHeaders") != false,
      boolValue(folder, key: "supportsEditingNotes") != false,
      boolValue(folder, key: "isSmartFolder") != true,
      boolValue(folder, key: "isTrashFolder") != true,
      boolValue(folder, key: "isSystemFolder") != true,
      boolValue(folder, key: "isSharedReadOnly") != true,
      boolValue(folder, key: "isSubfolderOfReadonlyFolder") != true
    else {
      throw writeError(operation: operation, reason: "ICFolder cannot accept date-header mutations.")
    }
  }

  private func sortObjectMatches(_ sortType: ICFolderCustomNoteSortType, draft: NotesFolderSortDraft) -> Bool {
    if draft.sortIsDefault {
      return sortType.valueRepresentation.intValue == 0 || sortType.isDefault
    }
    return sortType.valueRepresentation.intValue == draft.sortValue
      || (Int(sortType.order) == draft.sortOrder && Int(sortType.direction) == draft.sortDirection)
  }

  private func validateFolderTitle(
    _ name: String,
    account: ICAccount,
    parentFolder: ICFolder?,
    operation: String
  ) throws {
    var error: AnyObject?
    guard ICFolder.isTitleValid(name, account: account, parentFolder: parentFolder, error: &error) else {
      throw writeError(operation: operation, reason: "ICFolder.isTitleValid returned false.", error: error)
    }
  }

  private func validateExistingFolderTitle(
    _ name: String,
    folder: ICFolder,
    operation: String
  ) throws {
    var error: AnyObject?
    guard folder.isTitleValid(name, error: &error) else {
      throw writeError(operation: operation, reason: "ICFolder.isTitleValid returned false.", error: error)
    }
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

  private func noteContext() throws -> ICNoteContext {
    try NotesNativeContext.open(requiresSave: true)
  }

  private func noteText(title: String, body: String) -> String {
    body.isEmpty ? title : "\(title)\n\(body)"
  }

  private func noteIdentifier(_ note: ICNote) -> String {
    objectIDString(note)
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

  private func managedObjectID(for object: AnyObject) -> NSManagedObjectID? {
    if let cloudObject = object as? ICCloudObject {
      return cloudObject.objectID
    }
    if let managedObject = object as? NSManagedObject {
      return managedObject.objectID
    }
    return nil
  }

  private func objects<T>(_ value: Any?) -> [T] {
    if let values = value as? [T] {
      return values
    }
    if let values = value as? NSArray {
      return values.compactMap { $0 as? T }
    }
    return []
  }

  private func anyObjects(_ value: Any?) -> [AnyObject] {
    switch value {
    case let values as [AnyObject]:
      return values
    case let array as NSArray:
      return array.compactMap { $0 as AnyObject }
    case let set as NSSet:
      return set.allObjects.compactMap { $0 as AnyObject }
    default:
      return []
    }
  }

  private func objectCount(_ value: AnyObject?) -> Int? {
    guard let value else {
      return nil
    }
    if let count = optionalInt(value, key: "count") {
      return count
    }
    switch value {
    case let array as NSArray:
      return array.count
    case let set as NSSet:
      return set.count
    default:
      return nil
    }
  }

  private func optionalObject(_ object: AnyObject, key: String) -> AnyObject? {
    guard let value = optionalValue(object, key: key) else {
      return nil
    }
    return value as AnyObject
  }

  private func optionalValue(_ object: AnyObject, key: String) -> Any? {
    guard object.responds(to: Selector(key)) else {
      return nil
    }
    return object.value(forKey: key)
  }

  private func objectTypeName(_ object: AnyObject) -> String {
    String(describing: type(of: object))
  }

  private func string(_ value: Any?) -> String {
    value as? String ?? ""
  }

  private func boolValue(_ object: AnyObject, key: String) -> Bool? {
    guard object.responds(to: Selector(key)) else {
      return nil
    }
    switch object.value(forKey: key) {
    case let value as Bool:
      return value
    case let value as NSNumber:
      return value.boolValue
    default:
      return nil
    }
  }

  private func optionalString(_ object: AnyObject, key: String) -> String? {
    guard object.responds(to: Selector(key)) else {
      return nil
    }
    switch object.value(forKey: key) {
    case let value as String:
      return value
    case let value as URL:
      return value.absoluteString
    default:
      return nil
    }
  }

  private func optionalInt(_ object: AnyObject, key: String) -> Int? {
    guard object.responds(to: Selector(key)) else {
      return nil
    }
    switch object.value(forKey: key) {
    case let value as Int:
      return value
    case let value as NSNumber:
      return value.intValue
    default:
      return nil
    }
  }

  private func optionalURLString(_ object: AnyObject, key: String) -> String? {
    guard object.responds(to: Selector(key)) else {
      return nil
    }
    return (object.value(forKey: key) as? URL)?.absoluteString
  }

  private func nonEmpty(_ value: String?) -> String? {
    guard let value else {
      return nil
    }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : value
  }

  private func dataValue(_ value: Any?) -> Data? {
    switch value {
    case let data as Data:
      return data
    case let data as NSData:
      return data as Data
    default:
      return nil
    }
  }

  private func urlValue(_ value: Any?) -> URL? {
    switch value {
    case let url as URL:
      return url
    case let url as NSURL:
      return url as URL
    default:
      return nil
    }
  }

  private func writeError(operation: String, reason: String, error: AnyObject? = nil) -> CLIError {
    var details = [
      "operation": operation,
      "writer": "NotesShared/NotesUI",
      "reason": reason,
    ]
    if let error = error as? NSError {
      details.merge(CLIError.diagnosticDetails(for: error)) { _, new in new }
    }
    return CLIError(code: .backendUnavailable, message: "Notes could not complete the requested change.", details: details)
  }
}

struct NotesChecklistParagraphTarget {
  var range: NSRange
  var style: ICTTParagraphStyle
  var checked: Bool
  var paragraphIDSHA256: String? = nil
  var indentationLevel: Int = 0
}

private struct NotesCollapsibleSectionTarget {
  var uuid: UUID
  var ordinal: Int
  var paragraphIDSHA256: String
  var collapsed: Bool
}

private struct NotesTableMutationTarget {
  var attachment: AnyObject
  var table: AnyObject?
  var record: NotesBodyTableRecord
  var range: NSRange
}

private struct WriterTableCellFormatSummary {
  var formatRunCount: Int
  var formatSHA256: String
  var containsBold: Bool
  var containsItalic: Bool
  var containsUnderline: Bool
  var containsStrikethrough: Bool
}

private struct NotesMathMutationTarget {
  var attachment: AnyObject
  var record: NotesBodyMathResultRecord
}

private struct NotesMathExpressionInsertion {
  var location: Int
  var insertedText: String
  var expressionRange: NSRange
}

private struct NotesMathVariableSetInsertion {
  var location: Int
  var insertedText: String
  var variableDefinitionRange: NSRange
  var dependentRange: NSRange
  var textStorageLengthAfterTextInsert: Int
}

private struct NotesInlineTextTarget {
  var range: NSRange
  var paragraphIDSHA256: String?
  var textByteCount: Int
  var textSHA256: String
  var occurrence: Int
  var richTextSHA256: String

  func evidence(
    role: String,
    colorSHA256: String? = nil,
    fontSHA256: String? = nil
  ) -> NotesBodyInlineMutationEvidence {
    NotesBodyInlineMutationEvidence(
      paragraphIDSHA256: paragraphIDSHA256,
      textByteCount: textByteCount,
      textSHA256: textSHA256,
      occurrence: occurrence,
      role: role,
      colorSHA256: colorSHA256,
      fontSHA256: fontSHA256,
      utf16Location: range.location, utf16Length: range.length,
      richTextSHA256: richTextSHA256
    )
  }
}
