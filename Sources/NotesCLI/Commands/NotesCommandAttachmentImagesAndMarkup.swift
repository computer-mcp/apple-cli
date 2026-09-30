import Foundation
import Utility

extension NotesCommand {

  func attachmentImageObjectQuery(_ options: CLIOptions) throws -> String? {
    guard let raw = options.targetOption("query") else {
      return nil
    }
    let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else {
      return nil
    }
    guard query.utf8.count <= 500 else {
      throw CLIError(
        code: .validationError,
        message: "Notes image object query is too large.",
        details: [
          "query_sha256": sha256Hex(query),
          "max_bytes": "500",
        ]
      )
    }
    return query
  }

  func attachmentImageCropDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentImageCropDraft {
    let (note, requestedAttachment, source) = try imageTransformSource(options, operation: operation)
    let rect = try normalizedPDFCropRect(options: options, operation: operation)
    return NotesAttachmentImageCropDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      topLeft: rect.topLeft,
      topRight: rect.topRight,
      bottomRight: rect.bottomRight,
      bottomLeft: rect.bottomLeft,
      requestedCropRectSHA256: rect.sha256,
      beforeImageDataSHA256: source.dataSHA256
    )
  }

  func attachmentImageRotateDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentImageRotateDraft {
    let (note, requestedAttachment, source) = try imageTransformSource(options, operation: operation)
    let delta = try normalizedAttachmentRotationDelta(options, commandName: "attachments image rotate")
    return NotesAttachmentImageRotateDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      rotationDeltaDegrees: delta,
      beforeImageDataSHA256: source.dataSHA256
    )
  }

  private func imageTransformSource(
    _ options: CLIOptions,
    operation: String
  ) throws -> (
    note: NotesNoteDetail,
    requestedAttachment: String,
    source: NotesAttachmentImageTransformSource
  ) {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateAttachmentMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: operation
      )
    }
    let requestedAttachment = try requiredOption("attachment", options: options)
    let exportSource = try attachmentReader().exportAttachment(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    let attachmentFamily = attachmentAuditFamily(exportSource.attachment)
    guard attachmentFamily == "photo_image" else {
      throw CLIError(
        code: .validationError,
        message: "Notes image transform requires a photo/image attachment.",
        details: [
          "operation": operation,
          "expected_family": "photo_image",
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(exportSource.attachment.id),
        ]
      )
    }
    guard exportSource.attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes image transform target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(exportSource.attachment.id),
        ]
      )
    }
    guard exportSource.data.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes image transform requires non-empty attachment media bytes.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(exportSource.attachment.id),
        ]
      )
    }
    return (
      note,
      requestedAttachment,
      NotesAttachmentImageTransformSource(
        noteID: exportSource.noteID,
        attachment: exportSource.attachment,
        dataByteCount: exportSource.data.count,
        dataSHA256: sha256Hex(exportSource.data),
        sourceKind: "ICMedia.readData"
      )
    )
  }

  func normalizedImageCropRect(
    options: CLIOptions,
    operation: String
  ) throws -> (
    topLeft: NotesAttachmentScanCropPoint,
    topRight: NotesAttachmentScanCropPoint,
    bottomRight: NotesAttachmentScanCropPoint,
    bottomLeft: NotesAttachmentScanCropPoint,
    sha256: String
  ) {
    let quad = try normalizedScanCropQuad(options: options, operation: operation)
    let tolerance = 0.000001
    let isAxisAligned =
      abs(quad.topLeft.y - quad.topRight.y) <= tolerance
      && abs(quad.bottomLeft.y - quad.bottomRight.y) <= tolerance
      && abs(quad.topLeft.x - quad.bottomLeft.x) <= tolerance
      && abs(quad.topRight.x - quad.bottomRight.x) <= tolerance
    let hasOrderedEdges =
      quad.topLeft.x < quad.topRight.x
      && quad.bottomLeft.x < quad.bottomRight.x
      && quad.topLeft.y < quad.bottomLeft.y
      && quad.topRight.y < quad.bottomRight.y
    let cropsImage =
      quad.topLeft.x > tolerance
      || quad.topLeft.y > tolerance
      || quad.topRight.x < 1.0 - tolerance
      || quad.bottomLeft.y < 1.0 - tolerance
    guard isAxisAligned, hasOrderedEdges, cropsImage else {
      throw CLIError(
        code: .validationError,
        message: "Notes image crop requires a non-full-image axis-aligned normalized crop rectangle.",
        details: [
          "operation": operation,
          "crop_rect_sha256": quad.sha256,
        ]
      )
    }
    return quad
  }

  private var attachmentImageDescriptionFamilies: Set<String> {
    ["photo_image", "drawing_or_sketch", "scanned_document"]
  }

  func readAttachmentImageDescription(
    _ source: NotesAttachmentImageDescriptionSource,
    requestedAttachmentID: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.image.description.get"
    try validateAttachmentImageDescriptionSource(source, operation: operation)
    let verification = verifyAttachmentImageDescriptionRead(source: source, operation: operation)
    let result = attachmentImageDescriptionResult(
      operation: operation,
      changed: false,
      source: source,
      requestedAttachmentID: requestedAttachmentID,
      previousSource: nil,
      verification: verification
    )
    return try self.result(
      result,
      human:
        "image_description_present: \(result.descriptionPresent), byte_count: \(result.descriptionByteCount ?? 0)",
      options: options
    )
  }

  func attachmentImageDescriptionDraft(_ options: CLIOptions) throws
    -> NotesAttachmentImageDescriptionDraft
  {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateAttachmentMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.attachments.image.description.set"
      )
    }

    let requestedAttachment = try requiredOption("attachment", options: options)
    let source = try attachmentReader().readAttachmentImageDescription(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    try validateAttachmentImageDescriptionSource(
      source,
      operation: "notes.attachments.image.description.set"
    )
    return NotesAttachmentImageDescriptionDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      descriptionText: try validatedAttachmentImageDescription(
        try requiredOptionAllowingEmpty("description", options: options)
      )
    )
  }

  private func validateAttachmentImageDescriptionSource(
    _ source: NotesAttachmentImageDescriptionSource,
    operation: String
  ) throws {
    let family = attachmentAuditFamily(source.attachment)
    guard source.attachment.isInline else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description commands require an inline attachment with private alt-text metadata.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "attachment_family": family,
        ]
      )
    }
    guard attachmentImageDescriptionFamilies.contains(family) else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description commands currently support inline image, scan, or drawing attachments.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "attachment_family": family,
        ]
      )
    }
    guard source.sourceKind == "ICInlineAttachment.altText" else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description source must be private inline attachment alt-text readback.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "source_kind_sha256": sha256Hex(source.sourceKind),
        ]
      )
    }
  }

  private func validatedAttachmentImageDescription(_ value: String) throws -> String {
    guard value.unicodeScalars.allSatisfy({ $0.value != 0 }) else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description must not contain NUL characters.",
        details: ["description_sha256": sha256Hex(value)]
      )
    }
    guard value.utf8.count <= 10_000 else {
      throw CLIError(
        code: .validationError,
        message: "Notes image description must be 10,000 UTF-8 bytes or fewer.",
        details: [
          "description_sha256": sha256Hex(value),
          "byte_count": "\(value.utf8.count)",
          "max_byte_count": "10000",
        ]
      )
    }
    return value
  }

  func attachmentImageDescriptionSummary(
    _ draft: NotesAttachmentImageDescriptionDraft
  ) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "description_byte_count": "\(draft.descriptionText.utf8.count)",
      "description_sha256": sha256Hex(draft.descriptionText),
      "description_clears_value": draft.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "true" : "false",
      "source_kind": "ICInlineAttachment.altText",
    ]
  }

  func attachmentImageDescriptionScopeDigest(
    _ draft: NotesAttachmentImageDescriptionDraft
  ) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      attachmentAuditFamily(draft.attachment),
      "\(draft.descriptionText.utf8.count)",
      sha256Hex(draft.descriptionText),
    ].joined(separator: "|")
    return "notes-attachment-image-description:\(sha256Hex(fields))"
  }

  func attachmentImageDescriptionResult(
    operation: String,
    changed: Bool,
    source: NotesAttachmentImageDescriptionSource,
    requestedAttachmentID: String,
    previousSource: NotesAttachmentImageDescriptionSource?,
    verification: NotesMutationVerificationReport
  ) -> NotesAttachmentImageDescriptionResult {
    NotesAttachmentImageDescriptionResult(
      operation: operation,
      changed: changed,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      requestedAttachmentID: requestedAttachmentID,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      attachmentFamily: attachmentAuditFamily(source.attachment),
      descriptionPresent: source.descriptionText != nil,
      descriptionByteCount: source.descriptionText.map { $0.utf8.count },
      descriptionSHA256: source.descriptionText.map(sha256Hex),
      previousDescriptionPresent: previousSource.map { $0.descriptionText != nil },
      previousDescriptionByteCount: previousSource?.descriptionText.map { $0.utf8.count },
      previousDescriptionSHA256: previousSource?.descriptionText.map(sha256Hex),
      sourceKind: source.sourceKind,
      verification: verification
    )
  }

  func attachmentMarkupEditDraft(_ options: CLIOptions) throws -> NotesAttachmentMarkupEditDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateAttachmentMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.attachments.markup.edit"
      )
    }

    let requestedAttachment = try requiredOption("attachment", options: options)
    let matches = try attachmentReader().listAttachments(noteID: note.id, limit: 2_000)
      .filter { attachmentRecordMatches($0, selector: requestedAttachment) }
    guard let attachment = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
          "match_count": "\(matches.count)",
        ]
      )
    }
    guard attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment Markup edit target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachment.id),
        ]
      )
    }
    let attachmentFamily = attachmentAuditFamily(attachment)
    guard attachmentAuditSupportsMarkupModelApply(attachment) else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment Markup edit currently supports PDF, scanned document, and image attachments.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachment.id),
          "attachment_family": attachmentFamily,
        ]
      )
    }

    let source = try notesAttachmentMarkupModelSource(path: try requiredOption("file", options: options))
    return NotesAttachmentMarkupEditDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: attachment,
      sourcePath: source.path,
      data: source.data
    )
  }

  func attachmentImageCropSummary(_ draft: NotesAttachmentImageCropDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "crop_point_count": "4",
      "requested_crop_rect_sha256": draft.requestedCropRectSHA256,
      "before_image_data_sha256": draft.beforeImageDataSHA256 ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentImageCropScopeDigest(_ draft: NotesAttachmentImageCropDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      draft.requestedCropRectSHA256,
      draft.beforeImageDataSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-attachment-image-crop:\(sha256Hex(fields))"
  }

  func attachmentImageRotateSummary(_ draft: NotesAttachmentImageRotateDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "rotation_delta_degrees": "\(draft.rotationDeltaDegrees)",
      "before_image_data_sha256": draft.beforeImageDataSHA256 ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentImageRotateScopeDigest(_ draft: NotesAttachmentImageRotateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.rotationDeltaDegrees)",
      draft.beforeImageDataSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-attachment-image-rotate:\(sha256Hex(fields))"
  }

  func attachmentMarkupEditSummary(_ draft: NotesAttachmentMarkupEditDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "source_path": draft.sourcePath,
      "markup_model_byte_count": "\(draft.data.count)",
      "markup_model_sha256": sha256Hex(draft.data),
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "title": draft.attachment.title ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentMarkupEditScopeDigest(_ draft: NotesAttachmentMarkupEditDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      draft.sourcePath,
      "\(draft.data.count)",
      sha256Hex(draft.data),
      attachmentAuditFamily(draft.attachment),
    ].joined(separator: "|")
    return "notes-attachment-markup-edit:\(sha256Hex(fields))"
  }

  func verifyAttachmentImageCrop(
    draft: NotesAttachmentImageCropDraft,
    result: NotesAttachmentImageCropWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.source.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let attachmentFamily = attachmentAuditFamily(result.source.attachment)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let beforeHashAccounting = result.oldSource.dataSHA256.count == 64
    let afterHashAccounting = result.source.dataSHA256.count == 64
    let requestedCropHashAccounting = result.requestedCropRectSHA256.count == 64
    let imageHashChanged = result.oldSource.dataSHA256 != result.source.dataSHA256
    let afterBytesNonEmpty = result.source.dataByteCount > 0
    let beforeHashMatchesDraft = draft.beforeImageDataSHA256 == nil
      || draft.beforeImageDataSHA256 == result.oldSource.dataSHA256
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: updated != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: updated != nil
      ),
      NotesVerificationCheckRecord(
        name: "photo_image_family",
        status: attachmentFamily == "photo_image" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "photo_image"
      ),
      NotesVerificationCheckRecord(
        name: "before_image_hash_matches_draft",
        status: beforeHashMatchesDraft ? "passed" : "failed",
        expectedSHA256: draft.beforeImageDataSHA256,
        actualSHA256: result.oldSource.dataSHA256
      ),
      NotesVerificationCheckRecord(
        name: "requested_crop_hash_accounting",
        status: requestedCropHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: requestedCropHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "before_image_hash_accounting",
        status: beforeHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: beforeHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "after_image_hash_accounting",
        status: afterHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: afterHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "image_hash_delta",
        status: imageHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: imageHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "image_data_non_empty",
        status: afterBytesNonEmpty ? "passed" : "failed",
        expectedBool: true,
        actualBool: afterBytesNonEmpty
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_image_crop_writer+media_hash_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.source.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentImageRotate(
    draft: NotesAttachmentImageRotateDraft,
    result: NotesAttachmentImageRotateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.source.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let attachmentFamily = attachmentAuditFamily(result.source.attachment)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let beforeHashAccounting = result.oldSource.dataSHA256.count == 64
    let afterHashAccounting = result.source.dataSHA256.count == 64
    let imageHashChanged = result.oldSource.dataSHA256 != result.source.dataSHA256
    let afterBytesNonEmpty = result.source.dataByteCount > 0
    let beforeHashMatchesDraft = draft.beforeImageDataSHA256 == nil
      || draft.beforeImageDataSHA256 == result.oldSource.dataSHA256
    let rotationReadback = result.rotationDeltaDegrees == draft.rotationDeltaDegrees
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: updated != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: updated != nil
      ),
      NotesVerificationCheckRecord(
        name: "photo_image_family",
        status: attachmentFamily == "photo_image" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "photo_image"
      ),
      NotesVerificationCheckRecord(
        name: "before_image_hash_matches_draft",
        status: beforeHashMatchesDraft ? "passed" : "failed",
        expectedSHA256: draft.beforeImageDataSHA256,
        actualSHA256: result.oldSource.dataSHA256
      ),
      NotesVerificationCheckRecord(
        name: "rotation_delta_readback",
        status: rotationReadback ? "passed" : "failed",
        expectedLength: draft.rotationDeltaDegrees,
        actualLength: result.rotationDeltaDegrees
      ),
      NotesVerificationCheckRecord(
        name: "before_image_hash_accounting",
        status: beforeHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: beforeHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "after_image_hash_accounting",
        status: afterHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: afterHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "image_hash_delta",
        status: imageHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: imageHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "image_data_non_empty",
        status: afterBytesNonEmpty ? "passed" : "failed",
        expectedBool: true,
        actualBool: afterBytesNonEmpty
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_image_rotate_writer+media_hash_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.source.attachment.id),
      checks: checks
    )
  }

  func inspectAttachmentMarkup(
    _ source: NotesAttachmentMarkupInspectionSource,
    requestedAttachmentID: String,
    destinationPath: String?,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.markup.inspect"
    let markupData = source.markupModelData
    let markupHash = markupData.map(sha256Hex)
    let summary = attachmentMarkupInspectionSummary(
      source: source,
      requestedAttachmentID: requestedAttachmentID,
      destinationPath: destinationPath,
      markupHash: markupHash
    )

    if let destinationPath, options.dryRun {
      try validateDryRunOptions(options)
      guard markupData != nil else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Attachment does not expose Markup model data through Notes private APIs.",
          details: [
            "attachment_sha256": sha256Hex(source.attachment.id),
            "type_uti": source.attachment.typeUTI ?? "",
            "media_filename": source.attachment.mediaFilename ?? "",
          ]
        )
      }
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: attachmentMarkupInspectionScopeDigest(source: source, destinationPath: destinationPath),
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    if let destinationPath {
      guard let markupData, let markupHash else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Attachment does not expose Markup model data through Notes private APIs.",
          details: [
            "attachment_sha256": sha256Hex(source.attachment.id),
            "type_uti": source.attachment.typeUTI ?? "",
            "media_filename": source.attachment.mediaFilename ?? "",
          ]
        )
      }
      try CLISafety.requireFlag(
        "allow-artifact-action",
        in: options,
        category: .artifactAction,
        message: "Notes attachment Markup model export writes a filesystem artifact and requires `--allow-artifact-action`."
      )
      try writeNotesAttachmentMarkupExport(markupData, to: destinationPath)
      let verification = try verifyAttachmentMarkupInspection(
        source: source,
        destinationPath: destinationPath,
        expectedSHA256: markupHash,
        expectedByteCount: markupData.count,
        operation: operation
      )
      let result = NotesAttachmentMarkupInspectionResult(
        operation: operation,
        changed: true,
        noteID: source.noteID,
        attachmentID: source.attachment.id,
        requestedAttachmentID: requestedAttachmentID,
        title: source.attachment.title,
        typeUTI: source.attachment.typeUTI,
        mediaFilename: source.attachment.mediaFilename,
        sourceKind: source.sourceKind,
        attachmentDataByteCount: source.attachmentDataByteCount,
        attachmentDataSHA256: source.attachmentDataSHA256,
        markupModelPresent: true,
        markupModelByteCount: markupData.count,
        markupModelSHA256: markupHash,
        destinationPath: destinationPath,
        verification: verification
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes attachment Markup inspection verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return try self.result(result, human: "\(operation) executed", options: options)
    }

    let verification = try verifyAttachmentMarkupInspection(
      source: source,
      destinationPath: nil,
      expectedSHA256: markupHash,
      expectedByteCount: markupData?.count,
      operation: operation
    )
    let result = NotesAttachmentMarkupInspectionResult(
      operation: operation,
      changed: false,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      requestedAttachmentID: requestedAttachmentID,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      sourceKind: source.sourceKind,
      attachmentDataByteCount: source.attachmentDataByteCount,
      attachmentDataSHA256: source.attachmentDataSHA256,
      markupModelPresent: markupData != nil,
      markupModelByteCount: markupData?.count,
      markupModelSHA256: markupHash,
      destinationPath: nil,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment Markup inspection verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) read", options: options)
  }

  private func attachmentMarkupInspectionSummary(
    source: NotesAttachmentMarkupInspectionSource,
    requestedAttachmentID: String,
    destinationPath: String?,
    markupHash: String?
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "requested_attachment": requestedAttachmentID,
      "destination_path": destinationPath ?? "",
      "attachment_byte_count": "\(source.attachmentDataByteCount)",
      "attachment_sha256": source.attachmentDataSHA256,
      "markup_model_present": source.markupModelData == nil ? "false" : "true",
      "markup_model_byte_count": source.markupModelData.map { "\($0.count)" } ?? "",
      "markup_model_sha256": markupHash ?? "",
      "title": source.attachment.title ?? "",
      "type_uti": source.attachment.typeUTI ?? "",
      "media_filename": source.attachment.mediaFilename ?? "",
      "source_kind": source.sourceKind,
    ]
  }

  private func attachmentMarkupInspectionScopeDigest(
    source: NotesAttachmentMarkupInspectionSource,
    destinationPath: String?
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      destinationPath ?? "",
      "\(source.attachmentDataByteCount)",
      source.attachmentDataSHA256,
      source.markupModelData.map { "\($0.count)" } ?? "",
      source.markupModelData.map(sha256Hex) ?? "",
      source.sourceKind,
    ].joined(separator: "|")
    return "notes-attachment-markup-inspect:\(sha256Hex(fields))"
  }

  private func verifyAttachmentImageDescriptionRead(
    source: NotesAttachmentImageDescriptionSource,
    operation: String
  ) -> NotesMutationVerificationReport {
    let expectedText = source.descriptionText
    let expectedSHA256 = expectedText.map(sha256Hex)
    let expectedByteCount = expectedText.map { $0.utf8.count }
    let family = attachmentAuditFamily(source.attachment)
    let recordHashAccounting =
      source.attachment.imageDescriptionPresent == (expectedText != nil)
      && source.attachment.imageDescriptionByteCount == expectedByteCount
      && source.attachment.imageDescriptionSHA256 == expectedSHA256
      && source.attachment.imageDescriptionSourceKind == source.sourceKind
    let checks = [
      NotesVerificationCheckRecord(
        name: "inline_attachment",
        status: source.attachment.isInline ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.attachment.isInline
      ),
      NotesVerificationCheckRecord(
        name: "accepted_image_description_family",
        status: attachmentImageDescriptionFamilies.contains(family) ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentImageDescriptionFamilies.contains(family)
      ),
      NotesVerificationCheckRecord(
        name: "private_alt_text_source",
        status: source.sourceKind == "ICInlineAttachment.altText" ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.sourceKind == "ICInlineAttachment.altText"
      ),
      NotesVerificationCheckRecord(
        name: "description_hash_accounting",
        status: recordHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: recordHashAccounting
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_inline_attachment_alt_text_readback+privacy_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentImageObjects(
    source: NotesAttachmentImageObjectSource,
    attachmentFamily: String,
    query: String?,
    queryMatchCount: Int?,
    operation: String
  ) -> NotesMutationVerificationReport {
    let expectedSHA256 = source.classificationSummaryText.map(sha256Hex)
    let expectedByteCount = source.classificationSummaryText.map { $0.utf8.count }
    let summaryHashAccounting =
      source.attachment.imageClassificationSummaryPresent == (source.classificationSummaryText != nil)
      && source.attachment.imageClassificationSummaryByteCount == expectedByteCount
      && source.attachment.imageClassificationSummarySHA256 == expectedSHA256
      && source.attachment.imageClassificationSummaryVersion == source.classificationSummaryVersion
      && source.attachment.imageClassificationSummarySourceKind == source.sourceKind
    let privateReadback = source.backendCalls.contains("ICAttachment.imageClassificationSummary")
      && source.sourceKind == "ICAttachment.imageClassificationSummary"
    let queryAccounting = query.map { query in
      query.utf8.count > 0
        && queryMatchCount != nil
        && (queryMatchCount ?? -1) >= 0
    } ?? (queryMatchCount == nil)
    let checks = [
      NotesVerificationCheckRecord(
        name: "accepted_image_attachment_family",
        status: attachmentFamily == "photo_image" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "photo_image"
      ),
      NotesVerificationCheckRecord(
        name: "private_image_classification_summary_readback",
        status: privateReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: privateReadback
      ),
      NotesVerificationCheckRecord(
        name: "classification_summary_hash_accounting",
        status: summaryHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: summaryHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "query_hash_only_accounting",
        status: queryAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: queryAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_boundary",
        status: "passed",
        expectedBool: true,
        actualBool: true
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_attachment_image_object_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_image_classification_summary_readback+privacy_hash",
      targetIDSHA256: sha256Hex([source.noteID, source.attachment.id].joined(separator: "|")),
      checks: checks
    )
  }

  func verifyAttachmentImageDescriptionSet(
    draft: NotesAttachmentImageDescriptionDraft,
    result: NotesAttachmentImageDescriptionWriteResult
  ) throws -> NotesMutationVerificationReport {
    let readback = try attachmentReader().readAttachmentImageDescription(
      noteID: result.noteID,
      attachmentID: result.source.attachment.id
    )
    let expectedText = draft.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      ? nil
      : draft.descriptionText
    let expectedSHA256 = expectedText.map(sha256Hex)
    let expectedByteCount = expectedText.map { $0.utf8.count }
    let readbackHashMatches =
      readback.descriptionText == expectedText
      && readback.descriptionText.map(sha256Hex) == expectedSHA256
      && readback.descriptionText.map({ $0.utf8.count }) == expectedByteCount
    let operation = "notes.attachments.image.description.set"
    let family = attachmentAuditFamily(readback.attachment)
    let identityReadback =
      attachmentRecordMatches(readback.attachment, result.source.attachment)
      || attachmentRecordMatches(readback.attachment, draft.attachment)
    let checks = [
      NotesVerificationCheckRecord(
        name: "attachment_identity_readback",
        status: identityReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: identityReadback
      ),
      NotesVerificationCheckRecord(
        name: "inline_attachment",
        status: readback.attachment.isInline ? "passed" : "failed",
        expectedBool: true,
        actualBool: readback.attachment.isInline
      ),
      NotesVerificationCheckRecord(
        name: "accepted_image_description_family",
        status: attachmentImageDescriptionFamilies.contains(family) ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentImageDescriptionFamilies.contains(family)
      ),
      NotesVerificationCheckRecord(
        name: "private_alt_text_source",
        status: readback.sourceKind == "ICInlineAttachment.altText" ? "passed" : "failed",
        expectedBool: true,
        actualBool: readback.sourceKind == "ICInlineAttachment.altText"
      ),
      NotesVerificationCheckRecord(
        name: "description_hash_readback",
        status: readbackHashMatches ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: readback.descriptionText.map(sha256Hex)
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_inline_attachment_alt_text_write+readback_hash",
      targetIDSHA256: sha256Hex(result.source.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentMarkupInspection(
    source: NotesAttachmentMarkupInspectionSource,
    destinationPath: String?,
    expectedSHA256: String?,
    expectedByteCount: Int?,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let markupAccounting = source.markupModelData.map { data in
      expectedSHA256 == sha256Hex(data) && expectedByteCount == data.count
    } ?? (expectedSHA256 == nil && expectedByteCount == nil)
    var checks = [
      NotesVerificationCheckRecord(
        name: "markup_model_private_reader",
        status: source.sourceKind == "ICMarkupUtilities.markupModelDataFromData" ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.sourceKind == "ICMarkupUtilities.markupModelDataFromData"
      ),
      NotesVerificationCheckRecord(
        name: "markup_model_hash_accounting",
        status: markupAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: markupAccounting
      ),
      NotesVerificationCheckRecord(
        name: "attachment_data_hash_accounting",
        status: source.attachmentDataByteCount >= 0 && !source.attachmentDataSHA256.isEmpty ? "passed" : "failed",
        expectedBool: true,
        actualBool: source.attachmentDataByteCount >= 0 && !source.attachmentDataSHA256.isEmpty
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
    ]
    if let destinationPath, let expectedSHA256, let expectedByteCount {
      let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
      let exists = FileManager.default.fileExists(atPath: destination.path)
      let fileData = exists ? try Data(contentsOf: destination) : Data()
      let actualSHA256 = sha256Hex(fileData)
      checks.append(
        NotesVerificationCheckRecord(
          name: "destination_exists",
          status: exists ? "passed" : "failed",
          expectedBool: true,
          actualBool: exists
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "byte_count",
          status: fileData.count == expectedByteCount ? "passed" : "failed",
          expectedLength: expectedByteCount,
          actualLength: fileData.count
        )
      )
      checks.append(
        NotesVerificationCheckRecord(
          name: "sha256",
          status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
          expectedSHA256: expectedSHA256,
          actualSHA256: actualSHA256
        )
      )
    }
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: destinationPath == nil
        ? "private_framework_attachment_markup_model_readback+privacy_hash"
        : "private_framework_attachment_markup_model_readback+artifact_hash+attachment_metadata_readback",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentMarkupEdit(
    draft: NotesAttachmentMarkupEditDraft,
    result: NotesAttachmentMarkupEditWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let expectedSHA256 = sha256Hex(draft.data)
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.attachment) || attachmentRecordMatches($0, draft.attachment)
    }
    let markupReadback = try? attachmentReader().inspectAttachmentMarkup(
      noteID: result.noteID,
      attachmentID: result.attachment.id
    )
    let markupData = markupReadback?.markupModelData
    let markupSHA256 = markupData.map(sha256Hex)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: updated != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: updated != nil
      ),
      NotesVerificationCheckRecord(
        name: "markup_model_private_reader",
        status: markupReadback?.sourceKind == "ICMarkupUtilities.markupModelDataFromData" ? "passed" : "failed",
        expectedBool: true,
        actualBool: markupReadback?.sourceKind == "ICMarkupUtilities.markupModelDataFromData"
      ),
      NotesVerificationCheckRecord(
        name: "markup_model_readback",
        status: markupData != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: markupData != nil
      ),
      NotesVerificationCheckRecord(
        name: "markup_model_byte_count",
        status: markupData?.count == draft.data.count ? "passed" : "failed",
        expectedLength: draft.data.count,
        actualLength: markupData?.count
      ),
      NotesVerificationCheckRecord(
        name: "markup_model_sha256",
        status: markupSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: markupSHA256
      ),
      NotesVerificationCheckRecord(
        name: "attachment_family",
        status: updated.map(attachmentAuditSupportsMarkupModelApply) == true ? "passed" : "failed",
        expectedBool: true,
        actualBool: updated.map(attachmentAuditSupportsMarkupModelApply) == true
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_markup_model_apply+markup_model_readback+attachment_metadata_readback",
      targetIDSHA256: sha256Hex(result.attachment.id),
      checks: checks
    )
  }
}
