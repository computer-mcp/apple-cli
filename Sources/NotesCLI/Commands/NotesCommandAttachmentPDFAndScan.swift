import Foundation
#if canImport(PDFKit)
import PDFKit
#endif
import Utility

extension NotesCommand {

  func attachmentScanPDFInspectionFamily(_ source: NotesAttachmentScanPDFInspectionSource) -> String {
    let baseFamily = attachmentAuditFamily(source.attachment)
    if baseFamily == "scanned_document"
      || source.scannedDocumentsMetadataPresent
      || source.docCamPDFVersion != nil
      || source.croppingQuadPresent && baseFamily == "pdf"
    {
      return "scanned_document"
    }
    if baseFamily == "pdf" || source.pdfDataSHA256 != nil {
      return "pdf"
    }
    return baseFamily
  }

  func attachmentScanRotateDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentScanRotateDraft {
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
    let source = try attachmentReader().inspectAttachmentScanPDF(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    guard attachmentFamily == "scanned_document" else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan rotation requires a scanned-document attachment.",
        details: [
          "operation": operation,
          "expected_family": "scanned_document",
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard source.attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan rotation target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }

    let delta = try normalizedScanRotationDelta(options)
    let targetOrientation = try scanRotationTargetOrientation(
      before: source.orientation,
      deltaDegrees: delta
    )
    if let before = source.orientation, before == targetOrientation {
      throw CLIError(
        code: .validationError,
        message: "Notes scan rotation requires a changed orientation.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "orientation_sha256": sha256Hex("\(before)"),
        ]
      )
    }
    return NotesAttachmentScanRotateDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      beforeOrientation: source.orientation,
      targetOrientation: targetOrientation,
      rotationDeltaDegrees: delta
    )
  }

  func attachmentScanCropDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentScanCropDraft {
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
    let source = try attachmentReader().inspectAttachmentScanPDF(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    guard attachmentFamily == "scanned_document" else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan crop requires a scanned-document attachment.",
        details: [
          "operation": operation,
          "expected_family": "scanned_document",
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard source.attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan crop target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    let quad = try normalizedScanCropQuad(options: options, operation: operation)
    return NotesAttachmentScanCropDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      topLeft: quad.topLeft,
      topRight: quad.topRight,
      bottomRight: quad.bottomRight,
      bottomLeft: quad.bottomLeft,
      requestedCropQuadSHA256: quad.sha256,
      beforeCroppingQuadSHA256: source.croppingQuadSHA256,
      pageCount: source.pdfPageCount ?? source.scannedDocumentsMetadataCount
    )
  }

  func attachmentScanFilterDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentScanFilterDraft {
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
    let source = try attachmentReader().inspectAttachmentScanPDF(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    guard attachmentFamily == "scanned_document" else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan filter requires a scanned-document attachment.",
        details: [
          "operation": operation,
          "expected_family": "scanned_document",
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard source.attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan filter target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }

    let (style, filterType) = try normalizedScanFilterStyle(options)
    if let before = source.imageFilterType, before == filterType {
      throw CLIError(
        code: .validationError,
        message: "Notes scan filter requires a changed filter style.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "filter_type_sha256": sha256Hex("\(before)"),
        ]
      )
    }
    return NotesAttachmentScanFilterDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      style: style,
      filterType: filterType,
      beforeImageFilterType: source.imageFilterType
    )
  }

  func attachmentScanPageMoveDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentScanPageMoveDraft {
    let (note, requestedAttachment, source) = try scanPageEditSource(options, operation: operation)
    let pageCount = try scanPageEditCount(source, operation: operation)
    guard pageCount >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page move requires a multi-page scanned document.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
    let fromPage = try requiredPositiveIntOption("from", options: options, operation: operation)
    let toPage = try requiredPositiveIntOption("to", options: options, operation: operation)
    try validateScanPageOrdinal(fromPage, pageCount: pageCount, option: "from", source: source, operation: operation)
    try validateScanPageOrdinal(toPage, pageCount: pageCount, option: "to", source: source, operation: operation)
    guard fromPage != toPage else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page move requires different source and destination pages.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_sha256": sha256Hex("\(fromPage)"),
        ]
      )
    }
    return NotesAttachmentScanPageMoveDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      fromPage: fromPage,
      toPage: toPage,
      pageCount: pageCount
    )
  }

  func attachmentScanPageDeleteDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentScanPageDeleteDraft {
    let (note, requestedAttachment, source) = try scanPageEditSource(options, operation: operation)
    let pageCount = try scanPageEditCount(source, operation: operation)
    guard pageCount >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page delete refuses to remove the only page.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
    let page = try requiredPositiveIntOption("ordinal", options: options, operation: operation)
    try validateScanPageOrdinal(page, pageCount: pageCount, option: "ordinal", source: source, operation: operation)
    return NotesAttachmentScanPageDeleteDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      page: page,
      pageCount: pageCount
    )
  }

  func attachmentPDFPageRotateDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentPDFPageRotateDraft {
    let (note, requestedAttachment, source) = try pdfPageEditSource(options, operation: operation)
    let pageCount = try pdfPageEditCount(source, operation: operation)
    let page = try requiredPositiveIntOption("ordinal", options: options, operation: operation)
    try validatePDFPageOrdinal(page, pageCount: pageCount, option: "ordinal", source: source, operation: operation)
    let delta = try normalizedPDFRotationDelta(options)
    let beforeRotation = try pdfPageRotation(
      noteID: note.id,
      attachmentID: requestedAttachment,
      page: page,
      operation: operation
    )
    let targetRotation = normalizedPDFPageRotation(beforeRotation + delta)
    guard beforeRotation != targetRotation else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page rotation requires a changed page rotation.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_sha256": sha256Hex("\(page)"),
        ]
      )
    }
    return NotesAttachmentPDFPageRotateDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      page: page,
      pageCount: pageCount,
      beforePageRotation: beforeRotation,
      targetPageRotation: targetRotation,
      rotationDeltaDegrees: delta,
      beforePDFDataSHA256: source.pdfDataSHA256
    )
  }

  func attachmentPDFPageMoveDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentPDFPageMoveDraft {
    let (note, requestedAttachment, source) = try pdfPageEditSource(options, operation: operation)
    let pageCount = try pdfPageEditCount(source, operation: operation)
    guard pageCount >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page move requires a multi-page PDF attachment.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
    let fromPage = try requiredPositiveIntOption("from", options: options, operation: operation)
    let toPage = try requiredPositiveIntOption("to", options: options, operation: operation)
    try validatePDFPageOrdinal(fromPage, pageCount: pageCount, option: "from", source: source, operation: operation)
    try validatePDFPageOrdinal(toPage, pageCount: pageCount, option: "to", source: source, operation: operation)
    guard fromPage != toPage else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page move requires different source and destination pages.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_sha256": sha256Hex("\(fromPage)"),
        ]
      )
    }
    return NotesAttachmentPDFPageMoveDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      fromPage: fromPage,
      toPage: toPage,
      pageCount: pageCount,
      beforePDFDataSHA256: source.pdfDataSHA256
    )
  }

  func attachmentPDFPageDeleteDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentPDFPageDeleteDraft {
    let (note, requestedAttachment, source) = try pdfPageEditSource(options, operation: operation)
    let pageCount = try pdfPageEditCount(source, operation: operation)
    guard pageCount >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page delete refuses to remove the only page.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
    let page = try requiredPositiveIntOption("ordinal", options: options, operation: operation)
    try validatePDFPageOrdinal(page, pageCount: pageCount, option: "ordinal", source: source, operation: operation)
    return NotesAttachmentPDFPageDeleteDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      page: page,
      pageCount: pageCount,
      beforePDFDataSHA256: source.pdfDataSHA256
    )
  }

  func attachmentPDFCropDraft(
    _ options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentPDFCropDraft {
    let (note, requestedAttachment, source) = try pdfPageEditSource(options, operation: operation)
    let pageCount = try pdfPageEditCount(source, operation: operation)
    let page = try requiredPositiveIntOption("ordinal", options: options, operation: operation)
    try validatePDFPageOrdinal(page, pageCount: pageCount, option: "ordinal", source: source, operation: operation)
    let rect = try normalizedImageCropRect(options: options, operation: operation)
    return NotesAttachmentPDFCropDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: source.attachment,
      page: page,
      pageCount: pageCount,
      topLeft: rect.topLeft,
      topRight: rect.topRight,
      bottomRight: rect.bottomRight,
      bottomLeft: rect.bottomLeft,
      requestedCropRectSHA256: rect.sha256,
      beforePDFDataSHA256: source.pdfDataSHA256
    )
  }

  private func pdfPageEditSource(
    _ options: CLIOptions,
    operation: String
  ) throws -> (note: NotesNoteDetail, requestedAttachment: String, source: NotesAttachmentScanPDFInspectionSource) {
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
    let source = try attachmentReader().inspectAttachmentScanPDF(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    guard attachmentFamily == "pdf" else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page edit requires a PDF attachment.",
        details: [
          "operation": operation,
          "expected_family": "pdf",
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard source.pdfSourceKind == "media_pdf" else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page edit requires direct writable PDF media bytes.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "pdf_source_kind": source.pdfSourceKind ?? "",
          "required_source_kind": "media_pdf",
        ]
      )
    }
    guard source.attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page edit target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    return (note, requestedAttachment, source)
  }

  private func pdfPageEditCount(
    _ source: NotesAttachmentScanPDFInspectionSource,
    operation: String
  ) throws -> Int {
    guard let pageCount = source.pdfPageCount else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page edit requires PDF page-count readback evidence.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard pageCount > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page edit requires at least one readable page.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
    return pageCount
  }

  private func validatePDFPageOrdinal(
    _ page: Int,
    pageCount: Int,
    option: String,
    source: NotesAttachmentScanPDFInspectionSource,
    operation: String
  ) throws {
    guard page >= 1 && page <= pageCount else {
      throw CLIError(
        code: .validationError,
        message: "`--\(option)` must identify an existing PDF page.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_sha256": sha256Hex("\(page)"),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
  }

  private func normalizedPDFRotationDelta(_ options: CLIOptions) throws -> Int {
    return try normalizedAttachmentRotationDelta(options, commandName: "attachments pdf page rotate")
  }

  func normalizedAttachmentRotationDelta(_ options: CLIOptions, commandName: String) throws -> Int {
    let by = options.targetOption("by")
    let direction = options.targetOption("direction")
    guard by != nil || direction != nil else {
      throw CLIError(
        code: .validationError,
        message: "`\(commandName)` requires either `--by` or `--direction`.",
        details: ["allowed": "by,direction"]
      )
    }
    guard !(by != nil && direction != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--by` and `--direction` cannot be used together.",
        details: ["allowed": "by,direction"]
      )
    }
    if let by {
      let trimmed = by.trimmingCharacters(in: .whitespacesAndNewlines)
      guard let degrees = Int(trimmed), [-270, -180, -90, 90, 180, 270].contains(degrees) else {
        throw CLIError(
          code: .validationError,
          message: "`--by` must be one of -270, -180, -90, 90, 180, or 270 degrees.",
          details: ["allowed": "-270,-180,-90,90,180,270"]
        )
      }
      return degrees
    }
    switch try normalizedOption("direction", options: options).lowercased() {
    case "right", "clockwise", "cw":
      return 90
    case "left", "counterclockwise", "counter-clockwise", "ccw":
      return -90
    default:
      throw CLIError(
        code: .validationError,
        message: "`--direction` must be left, right, clockwise, counterclockwise, cw, or ccw.",
        details: ["allowed": "left,right,clockwise,counterclockwise,cw,ccw"]
      )
    }
  }

  private func normalizedPDFPageRotation(_ value: Int) -> Int {
    ((value % 360) + 360) % 360
  }

  private func pdfPageRotation(
    noteID: String,
    attachmentID: String,
    page: Int,
    operation: String
  ) throws -> Int {
    #if canImport(PDFKit)
    let source = try attachmentReader().exportAttachmentPDF(noteID: noteID, attachmentID: attachmentID)
    guard source.sourceKind == "media_pdf" else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page edit requires direct writable PDF media bytes.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "pdf_source_kind": source.sourceKind,
          "required_source_kind": "media_pdf",
        ]
      )
    }
    guard let document = PDFDocument(data: source.data),
      let pdfPage = document.page(at: page - 1)
    else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF page rotation requires PDFKit page readback.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_sha256": sha256Hex("\(page)"),
        ]
      )
    }
    return normalizedPDFPageRotation(pdfPage.rotation)
    #else
    throw CLIError(
      code: .unsupportedOperation,
      message: "PDFKit is unavailable for Notes PDF page rotation.",
      details: ["operation": operation]
    )
    #endif
  }

  private func scanPageEditSource(
    _ options: CLIOptions,
    operation: String
  ) throws -> (note: NotesNoteDetail, requestedAttachment: String, source: NotesAttachmentScanPDFInspectionSource) {
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
    let source = try attachmentReader().inspectAttachmentScanPDF(
      noteID: note.id,
      attachmentID: requestedAttachment
    )
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    guard attachmentFamily == "scanned_document" else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page edit requires a scanned-document attachment.",
        details: [
          "operation": operation,
          "expected_family": "scanned_document",
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard source.attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page edit target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    return (note, requestedAttachment, source)
  }

  private func scanPageEditCount(
    _ source: NotesAttachmentScanPDFInspectionSource,
    operation: String
  ) throws -> Int {
    guard let pageCount = source.pdfPageCount ?? source.scannedDocumentsMetadataCount else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page edit requires page-count readback evidence.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    guard pageCount > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan page edit requires at least one readable page.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
    return pageCount
  }

  private func validateScanPageOrdinal(
    _ page: Int,
    pageCount: Int,
    option: String,
    source: NotesAttachmentScanPDFInspectionSource,
    operation: String
  ) throws {
    guard page >= 1 && page <= pageCount else {
      throw CLIError(
        code: .validationError,
        message: "`--\(option)` must identify an existing scan page.",
        details: [
          "operation": operation,
          "attachment_sha256": sha256Hex(source.attachment.id),
          "page_sha256": sha256Hex("\(page)"),
          "page_count_sha256": sha256Hex("\(pageCount)"),
        ]
      )
    }
  }

  func normalizedScanCropQuad(
    options: CLIOptions,
    operation: String
  ) throws -> (
    topLeft: NotesAttachmentScanCropPoint,
    topRight: NotesAttachmentScanCropPoint,
    bottomRight: NotesAttachmentScanCropPoint,
    bottomLeft: NotesAttachmentScanCropPoint,
    sha256: String
  ) {
    let topLeft = try normalizedScanCropPoint("top-left", options: options, operation: operation)
    let topRight = try normalizedScanCropPoint("top-right", options: options, operation: operation)
    let bottomRight = try normalizedScanCropPoint("bottom-right", options: options, operation: operation)
    let bottomLeft = try normalizedScanCropPoint("bottom-left", options: options, operation: operation)
    let points = [topLeft, topRight, bottomRight, bottomLeft]
    let shifted = Array(points.dropFirst()) + [points[0]]
    let area = abs(zip(points, shifted).reduce(0.0) { partial, pair in
      partial + pair.0.x * pair.1.y - pair.1.x * pair.0.y
    }) / 2.0
    guard area > 0.000001 else {
      throw CLIError(
        code: .validationError,
        message: "Notes scan crop requires a non-empty crop quadrilateral.",
        details: [
          "operation": operation,
          "crop_quad_sha256": sha256Hex(scanCropQuadCanonicalString(
            topLeft: topLeft,
            topRight: topRight,
            bottomRight: bottomRight,
            bottomLeft: bottomLeft
          )),
        ]
      )
    }
    let canonical = scanCropQuadCanonicalString(
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft
    )
    return (topLeft, topRight, bottomRight, bottomLeft, sha256Hex(canonical))
  }

  func normalizedPDFCropRect(
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
    let cropsPage =
      quad.topLeft.x > tolerance
      || quad.topLeft.y > tolerance
      || quad.topRight.x < 1.0 - tolerance
      || quad.bottomLeft.y < 1.0 - tolerance
    guard isAxisAligned, hasOrderedEdges, cropsPage else {
      throw CLIError(
        code: .validationError,
        message: "Notes PDF crop requires a non-full-page axis-aligned normalized crop rectangle.",
        details: [
          "operation": operation,
          "crop_rect_sha256": quad.sha256,
        ]
      )
    }
    return quad
  }

  private func normalizedScanCropPoint(
    _ name: String,
    options: CLIOptions,
    operation: String
  ) throws -> NotesAttachmentScanCropPoint {
    let raw = try requiredOption(name, options: options)
    let parts = raw.split(separator: ",", omittingEmptySubsequences: false)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard parts.count == 2,
      let x = Double(parts[0]),
      let y = Double(parts[1]),
      x.isFinite,
      y.isFinite,
      (0.0...1.0).contains(x),
      (0.0...1.0).contains(y)
    else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be a normalized crop point in `x,y` form with values from 0 through 1.",
        details: [
          "operation": operation,
          "\(name)_sha256": sha256Hex(raw),
        ]
      )
    }
    return NotesAttachmentScanCropPoint(x: x, y: y)
  }

  private func scanCropQuadCanonicalString(
    topLeft: NotesAttachmentScanCropPoint,
    topRight: NotesAttachmentScanCropPoint,
    bottomRight: NotesAttachmentScanCropPoint,
    bottomLeft: NotesAttachmentScanCropPoint
  ) -> String {
    [
      "tl:\(scanCropCoordinate(topLeft.x)),\(scanCropCoordinate(topLeft.y))",
      "tr:\(scanCropCoordinate(topRight.x)),\(scanCropCoordinate(topRight.y))",
      "br:\(scanCropCoordinate(bottomRight.x)),\(scanCropCoordinate(bottomRight.y))",
      "bl:\(scanCropCoordinate(bottomLeft.x)),\(scanCropCoordinate(bottomLeft.y))",
    ].joined(separator: "|")
  }

  private func scanCropCoordinate(_ value: Double) -> String {
    String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), value)
  }

  private func normalizedScanFilterStyle(_ options: CLIOptions) throws -> (style: String, filterType: Int) {
    let raw = try requiredOption("style", options: options)
    let normalized = raw
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
      .replacingOccurrences(of: "_", with: "-")
      .replacingOccurrences(of: " ", with: "-")
    switch normalized {
    case "color", "colour":
      return ("color", 0)
    case "grayscale", "greyscale", "gray", "grey":
      return ("grayscale", 1)
    case "black-and-white", "black-white", "blackwhite", "bw", "b-w":
      return ("black-and-white", 2)
    case "photo", "original":
      return ("photo", 3)
    default:
      throw CLIError(
        code: .validationError,
        message: "`attachments scan filter --style` must be color, grayscale, black-and-white, or photo.",
        details: [
          "style_sha256": sha256Hex(raw),
          "allowed": "color,grayscale,black-and-white,photo",
        ]
      )
    }
  }

  private func normalizedScanRotationDelta(_ options: CLIOptions) throws -> Int {
    return try normalizedAttachmentRotationDelta(options, commandName: "attachments scan rotate")
  }

  private func scanRotationTargetOrientation(before: Int?, deltaDegrees: Int) throws -> Int {
    let steps = ((deltaDegrees / 90) % 4 + 4) % 4
    guard steps > 0 else {
      throw CLIError(code: .validationError, message: "Scan rotation delta must not be zero.")
    }
    let uiCycle = [0, 3, 1, 2]
    let cgCycle = [1, 6, 3, 8]
    let base = before ?? 0
    if let index = uiCycle.firstIndex(of: base) {
      return uiCycle[(index + steps) % uiCycle.count]
    }
    if let index = cgCycle.firstIndex(of: base) {
      return cgCycle[(index + steps) % cgCycle.count]
    }
    if base % 90 == 0 {
      return ((base + deltaDegrees) % 360 + 360) % 360
    }
    throw CLIError(
      code: .validationError,
      message: "Notes scan rotation found an unsupported private orientation value.",
      details: [
        "orientation_sha256": sha256Hex("\(base)"),
        "required": "non_mirrored_image_orientation_or_degree_step",
      ]
    )
  }

  func attachmentScanRotateSummary(_ draft: NotesAttachmentScanRotateDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "rotation_delta_degrees": "\(draft.rotationDeltaDegrees)",
      "before_orientation": draft.beforeOrientation.map(String.init) ?? "",
      "before_orientation_sha256": draft.beforeOrientation.map { sha256Hex("\($0)") } ?? "",
      "target_orientation": "\(draft.targetOrientation)",
      "target_orientation_sha256": sha256Hex("\(draft.targetOrientation)"),
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentScanRotateScopeDigest(_ draft: NotesAttachmentScanRotateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.rotationDeltaDegrees)",
      draft.beforeOrientation.map(String.init) ?? "",
      "\(draft.targetOrientation)",
    ].joined(separator: "|")
    return "notes-attachment-scan-rotate:\(sha256Hex(fields))"
  }

  func attachmentScanCropSummary(_ draft: NotesAttachmentScanCropDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "crop_point_count": "4",
      "requested_crop_quad_sha256": draft.requestedCropQuadSHA256,
      "before_cropping_quad_sha256": draft.beforeCroppingQuadSHA256 ?? "",
      "page_count": draft.pageCount.map(String.init) ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentScanCropScopeDigest(_ draft: NotesAttachmentScanCropDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      draft.requestedCropQuadSHA256,
      draft.beforeCroppingQuadSHA256 ?? "",
      draft.pageCount.map(String.init) ?? "",
    ].joined(separator: "|")
    return "notes-attachment-scan-crop:\(sha256Hex(fields))"
  }

  func attachmentScanFilterSummary(_ draft: NotesAttachmentScanFilterDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "style": draft.style,
      "style_sha256": sha256Hex(draft.style),
      "filter_type": "\(draft.filterType)",
      "before_image_filter_type": draft.beforeImageFilterType.map(String.init) ?? "",
      "before_image_filter_type_sha256": draft.beforeImageFilterType.map { sha256Hex("\($0)") } ?? "",
      "target_image_filter_type_sha256": sha256Hex("\(draft.filterType)"),
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentScanFilterScopeDigest(_ draft: NotesAttachmentScanFilterDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      draft.style,
      "\(draft.filterType)",
      draft.beforeImageFilterType.map(String.init) ?? "",
    ].joined(separator: "|")
    return "notes-attachment-scan-filter:\(sha256Hex(fields))"
  }

  func attachmentScanPageMoveSummary(_ draft: NotesAttachmentScanPageMoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "from_page": "\(draft.fromPage)",
      "to_page": "\(draft.toPage)",
      "page_count": "\(draft.pageCount)",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentScanPageMoveScopeDigest(_ draft: NotesAttachmentScanPageMoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.fromPage)",
      "\(draft.toPage)",
      "\(draft.pageCount)",
    ].joined(separator: "|")
    return "notes-attachment-scan-page-move:\(sha256Hex(fields))"
  }

  func attachmentScanPageDeleteSummary(_ draft: NotesAttachmentScanPageDeleteDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "page": "\(draft.page)",
      "page_count": "\(draft.pageCount)",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentScanPageDeleteScopeDigest(_ draft: NotesAttachmentScanPageDeleteDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.page)",
      "\(draft.pageCount)",
    ].joined(separator: "|")
    return "notes-attachment-scan-page-delete:\(sha256Hex(fields))"
  }

  func attachmentPDFCropSummary(_ draft: NotesAttachmentPDFCropDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "page": "\(draft.page)",
      "page_count": "\(draft.pageCount)",
      "crop_point_count": "4",
      "requested_crop_rect_sha256": draft.requestedCropRectSHA256,
      "before_pdf_data_sha256": draft.beforePDFDataSHA256 ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentPDFCropScopeDigest(_ draft: NotesAttachmentPDFCropDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.page)",
      "\(draft.pageCount)",
      draft.requestedCropRectSHA256,
      draft.beforePDFDataSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-attachment-pdf-crop:\(sha256Hex(fields))"
  }

  func attachmentPDFPageRotateSummary(_ draft: NotesAttachmentPDFPageRotateDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "page": "\(draft.page)",
      "page_count": "\(draft.pageCount)",
      "rotation_delta_degrees": "\(draft.rotationDeltaDegrees)",
      "before_page_rotation": "\(draft.beforePageRotation)",
      "target_page_rotation": "\(draft.targetPageRotation)",
      "before_pdf_data_sha256": draft.beforePDFDataSHA256 ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentPDFPageRotateScopeDigest(_ draft: NotesAttachmentPDFPageRotateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.page)",
      "\(draft.pageCount)",
      "\(draft.rotationDeltaDegrees)",
      "\(draft.beforePageRotation)",
      "\(draft.targetPageRotation)",
      draft.beforePDFDataSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-attachment-pdf-page-rotate:\(sha256Hex(fields))"
  }

  func attachmentPDFPageMoveSummary(_ draft: NotesAttachmentPDFPageMoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "from_page": "\(draft.fromPage)",
      "to_page": "\(draft.toPage)",
      "page_count": "\(draft.pageCount)",
      "before_pdf_data_sha256": draft.beforePDFDataSHA256 ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentPDFPageMoveScopeDigest(_ draft: NotesAttachmentPDFPageMoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.fromPage)",
      "\(draft.toPage)",
      "\(draft.pageCount)",
      draft.beforePDFDataSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-attachment-pdf-page-move:\(sha256Hex(fields))"
  }

  func attachmentPDFPageDeleteSummary(_ draft: NotesAttachmentPDFPageDeleteDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": attachmentAuditFamily(draft.attachment),
      "page": "\(draft.page)",
      "page_count": "\(draft.pageCount)",
      "before_pdf_data_sha256": draft.beforePDFDataSHA256 ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  func attachmentPDFPageDeleteScopeDigest(_ draft: NotesAttachmentPDFPageDeleteDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      "\(draft.page)",
      "\(draft.pageCount)",
      draft.beforePDFDataSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-attachment-pdf-page-delete:\(sha256Hex(fields))"
  }

  func verifyAttachmentScanRotate(
    draft: NotesAttachmentScanRotateDraft,
    result: NotesAttachmentScanRotateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let attachmentPresent = updated != nil
    let beforeHashMatches =
      draft.beforeOrientation == nil
        ? result.oldInspection.orientationSHA256 == nil
        : result.oldInspection.orientationSHA256 == sha256Hex("\(draft.beforeOrientation ?? 0)")
    let afterHashMatches =
      result.inspection.orientationSHA256 == sha256Hex("\(draft.targetOrientation)")
    let targetOrientationReadback = result.inspection.orientation == draft.targetOrientation
    let beforeChanged =
      draft.beforeOrientation == nil
        ? result.inspection.orientation != nil
        : result.inspection.orientation != draft.beforeOrientation
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let scanMetadataAccounting =
      result.inspection.scannedDocumentsMetadataSHA256 == nil
        || result.inspection.scannedDocumentsMetadataSHA256?.count == 64
    let cropMetadataAccounting =
      result.inspection.croppingQuadSHA256 == nil
        || result.inspection.croppingQuadSHA256?.count == 64
    let pdfHashAccounting =
      result.inspection.pdfDataSHA256 == nil || result.inspection.pdfDataSHA256?.count == 64
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
        status: attachmentPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPresent
      ),
      NotesVerificationCheckRecord(
        name: "scanned_document_family",
        status: attachmentFamily == "scanned_document" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "scanned_document"
      ),
      NotesVerificationCheckRecord(
        name: "before_orientation_hash",
        status: beforeHashMatches ? "passed" : "failed",
        expectedSHA256: draft.beforeOrientation.map { sha256Hex("\($0)") },
        actualSHA256: result.oldInspection.orientationSHA256
      ),
      NotesVerificationCheckRecord(
        name: "after_orientation_hash",
        status: afterHashMatches ? "passed" : "failed",
        expectedSHA256: sha256Hex("\(draft.targetOrientation)"),
        actualSHA256: result.inspection.orientationSHA256
      ),
      NotesVerificationCheckRecord(
        name: "target_orientation_readback",
        status: targetOrientationReadback ? "passed" : "failed",
        expectedSHA256: sha256Hex("\(draft.targetOrientation)"),
        actualSHA256: result.inspection.orientation.map { sha256Hex("\($0)") }
      ),
      NotesVerificationCheckRecord(
        name: "orientation_delta_readback",
        status: beforeChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: beforeChanged
      ),
      NotesVerificationCheckRecord(
        name: "scan_metadata_hash_accounting",
        status: scanMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: scanMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "crop_metadata_hash_accounting",
        status: cropMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: cropMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_accounting",
        status: pdfHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashAccounting
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
      evidenceLevel: "private_framework_scan_orientation_writer+pdf_scan_metadata_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentScanCrop(
    draft: NotesAttachmentScanCropDraft,
    result: NotesAttachmentScanCropWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let attachmentPresent = updated != nil
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let beforeCount = result.oldInspection.pdfPageCount ?? result.oldInspection.scannedDocumentsMetadataCount
    let afterCount = result.inspection.pdfPageCount ?? result.inspection.scannedDocumentsMetadataCount
    let pageCountPreserved = beforeCount == afterCount
    let beforeHash = result.oldInspection.croppingQuadSHA256
    let afterHash = result.inspection.croppingQuadSHA256
    let cropHashChanged = beforeHash != nil && afterHash != nil && beforeHash != afterHash
    let cropHashAccounting = afterHash?.count == 64
    let requestedHashAccounting = result.requestedCropQuadSHA256.count == 64
    let scanMetadataAccounting =
      result.inspection.scannedDocumentsMetadataSHA256 == nil
        || result.inspection.scannedDocumentsMetadataSHA256?.count == 64
    let pdfHashAccounting =
      result.inspection.pdfDataSHA256 == nil || result.inspection.pdfDataSHA256?.count == 64
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
        status: attachmentPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPresent
      ),
      NotesVerificationCheckRecord(
        name: "scanned_document_family",
        status: attachmentFamily == "scanned_document" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "scanned_document"
      ),
      NotesVerificationCheckRecord(
        name: "requested_crop_hash_accounting",
        status: requestedHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: requestedHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "crop_metadata_hash_accounting",
        status: cropHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: cropHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "crop_hash_delta",
        status: cropHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: cropHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "page_count_preserved",
        status: pageCountPreserved ? "passed" : "failed",
        expectedLength: beforeCount,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "scan_metadata_hash_accounting",
        status: scanMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: scanMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_accounting",
        status: pdfHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashAccounting
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
      evidenceLevel: "private_framework_scan_crop_writer+crop_metadata_delta_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentScanFilter(
    draft: NotesAttachmentScanFilterDraft,
    result: NotesAttachmentScanFilterWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let attachmentPresent = updated != nil
    let beforeHashMatches =
      draft.beforeImageFilterType == nil
        ? result.oldInspection.imageFilterTypeSHA256 == nil
        : result.oldInspection.imageFilterTypeSHA256 == sha256Hex("\(draft.beforeImageFilterType ?? 0)")
    let afterHashMatches =
      result.inspection.imageFilterTypeSHA256 == sha256Hex("\(draft.filterType)")
    let targetFilterReadback = result.inspection.imageFilterType == draft.filterType
    let beforeChanged =
      draft.beforeImageFilterType == nil
        ? result.inspection.imageFilterType != nil
        : result.inspection.imageFilterType != draft.beforeImageFilterType
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let scanMetadataAccounting =
      result.inspection.scannedDocumentsMetadataSHA256 == nil
        || result.inspection.scannedDocumentsMetadataSHA256?.count == 64
    let cropMetadataAccounting =
      result.inspection.croppingQuadSHA256 == nil
        || result.inspection.croppingQuadSHA256?.count == 64
    let pdfHashAccounting =
      result.inspection.pdfDataSHA256 == nil || result.inspection.pdfDataSHA256?.count == 64
    let imageFilterHashAccounting =
      result.inspection.imageFilterTypeSHA256 == nil || result.inspection.imageFilterTypeSHA256?.count == 64
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
        status: attachmentPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPresent
      ),
      NotesVerificationCheckRecord(
        name: "scanned_document_family",
        status: attachmentFamily == "scanned_document" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "scanned_document"
      ),
      NotesVerificationCheckRecord(
        name: "before_filter_type_hash",
        status: beforeHashMatches ? "passed" : "failed",
        expectedSHA256: draft.beforeImageFilterType.map { sha256Hex("\($0)") },
        actualSHA256: result.oldInspection.imageFilterTypeSHA256
      ),
      NotesVerificationCheckRecord(
        name: "after_filter_type_hash",
        status: afterHashMatches ? "passed" : "failed",
        expectedSHA256: sha256Hex("\(draft.filterType)"),
        actualSHA256: result.inspection.imageFilterTypeSHA256
      ),
      NotesVerificationCheckRecord(
        name: "target_filter_type_readback",
        status: targetFilterReadback ? "passed" : "failed",
        expectedSHA256: sha256Hex("\(draft.filterType)"),
        actualSHA256: result.inspection.imageFilterType.map { sha256Hex("\($0)") }
      ),
      NotesVerificationCheckRecord(
        name: "filter_delta_readback",
        status: beforeChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: beforeChanged
      ),
      NotesVerificationCheckRecord(
        name: "scan_metadata_hash_accounting",
        status: scanMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: scanMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "crop_metadata_hash_accounting",
        status: cropMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: cropMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_accounting",
        status: pdfHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "image_filter_type_hash_accounting",
        status: imageFilterHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: imageFilterHashAccounting
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
      evidenceLevel: "private_framework_scan_filter_writer+pdf_scan_metadata_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentScanPageMove(
    draft: NotesAttachmentScanPageMoveDraft,
    result: NotesAttachmentScanPageMoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let beforeCount = result.oldInspection.pdfPageCount ?? result.oldInspection.scannedDocumentsMetadataCount
    let afterCount = result.inspection.pdfPageCount ?? result.inspection.scannedDocumentsMetadataCount
    let pageOrderChanged = scanPageMutationHashChanged(result.oldInspection, result.inspection)
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = scanPageCommonChecks(
      result: result.inspection,
      attachmentPresent: updated != nil,
      attachmentFamily: attachmentFamily,
      noteStillPresent: noteStillPresent
    ) + [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "page_count_preserved",
        status: beforeCount == draft.pageCount && afterCount == draft.pageCount ? "passed" : "failed",
        expectedLength: draft.pageCount,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "page_order_hash_delta",
        status: pageOrderChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: pageOrderChanged
      ),
      NotesVerificationCheckRecord(
        name: "from_page_readback",
        status: result.fromPage == draft.fromPage ? "passed" : "failed",
        expectedLength: draft.fromPage,
        actualLength: result.fromPage
      ),
      NotesVerificationCheckRecord(
        name: "to_page_readback",
        status: result.toPage == draft.toPage ? "passed" : "failed",
        expectedLength: draft.toPage,
        actualLength: result.toPage
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_scan_page_move_writer+pdf_scan_metadata_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentScanPageDelete(
    draft: NotesAttachmentScanPageDeleteDraft,
    result: NotesAttachmentScanPageDeleteWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let beforeCount = result.oldInspection.pdfPageCount ?? result.oldInspection.scannedDocumentsMetadataCount
    let afterCount = result.inspection.pdfPageCount ?? result.inspection.scannedDocumentsMetadataCount
    let pageHashChanged = scanPageMutationHashChanged(result.oldInspection, result.inspection)
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = scanPageCommonChecks(
      result: result.inspection,
      attachmentPresent: updated != nil,
      attachmentFamily: attachmentFamily,
      noteStillPresent: noteStillPresent
    ) + [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "page_count_decremented",
        status: beforeCount == draft.pageCount && afterCount == draft.pageCount - 1 ? "passed" : "failed",
        expectedLength: draft.pageCount - 1,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "page_delete_hash_delta",
        status: pageHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: pageHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "deleted_page_readback",
        status: result.page == draft.page ? "passed" : "failed",
        expectedLength: draft.page,
        actualLength: result.page
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_scan_page_delete_writer+pdf_scan_metadata_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  private func scanPageCommonChecks(
    result: NotesAttachmentScanPDFInspectionSource,
    attachmentPresent: Bool,
    attachmentFamily: String,
    noteStillPresent: Bool
  ) -> [NotesVerificationCheckRecord] {
    let scanMetadataAccounting =
      result.scannedDocumentsMetadataSHA256 == nil
        || result.scannedDocumentsMetadataSHA256?.count == 64
    let cropMetadataAccounting =
      result.croppingQuadSHA256 == nil || result.croppingQuadSHA256?.count == 64
    let pdfHashAccounting =
      result.pdfDataSHA256 == nil || result.pdfDataSHA256?.count == 64
    return [
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPresent
      ),
      NotesVerificationCheckRecord(
        name: "scanned_document_family",
        status: attachmentFamily == "scanned_document" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "scanned_document"
      ),
      NotesVerificationCheckRecord(
        name: "scan_metadata_hash_accounting",
        status: scanMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: scanMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "crop_metadata_hash_accounting",
        status: cropMetadataAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: cropMetadataAccounting
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_accounting",
        status: pdfHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
  }

  private func scanPageMutationHashChanged(
    _ before: NotesAttachmentScanPDFInspectionSource,
    _ after: NotesAttachmentScanPDFInspectionSource
  ) -> Bool {
    let scanMetadataChanged =
      before.scannedDocumentsMetadataSHA256 != nil
      && after.scannedDocumentsMetadataSHA256 != nil
      && before.scannedDocumentsMetadataSHA256 != after.scannedDocumentsMetadataSHA256
    let pdfDataChanged =
      before.pdfDataSHA256 != nil
      && after.pdfDataSHA256 != nil
      && before.pdfDataSHA256 != after.pdfDataSHA256
    return scanMetadataChanged || pdfDataChanged
  }

  func verifyAttachmentPDFCrop(
    draft: NotesAttachmentPDFCropDraft,
    result: NotesAttachmentPDFCropWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let beforeCount = result.oldInspection.pdfPageCount
    let afterCount = result.inspection.pdfPageCount
    let pdfHashChanged = pdfPageMutationHashChanged(result.oldInspection, result.inspection)
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let requestedCropHashAccounting = result.requestedCropRectSHA256.count == 64
    let checks = pdfPageCommonChecks(
      result: result.inspection,
      attachmentPresent: updated != nil,
      attachmentFamily: attachmentFamily,
      noteStillPresent: noteStillPresent
    ) + [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "page_count_preserved",
        status: beforeCount == draft.pageCount && afterCount == draft.pageCount ? "passed" : "failed",
        expectedLength: draft.pageCount,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "pdf_crop_hash_delta",
        status: pdfHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "page_readback",
        status: result.page == draft.page ? "passed" : "failed",
        expectedLength: draft.page,
        actualLength: result.page
      ),
      NotesVerificationCheckRecord(
        name: "requested_crop_hash_accounting",
        status: requestedCropHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: requestedCropHashAccounting
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_crop_writer+pdf_hash_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentPDFPageRotate(
    draft: NotesAttachmentPDFPageRotateDraft,
    result: NotesAttachmentPDFPageRotateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let beforeCount = result.oldInspection.pdfPageCount
    let afterCount = result.inspection.pdfPageCount
    let pdfHashChanged = pdfPageMutationHashChanged(result.oldInspection, result.inspection)
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = pdfPageCommonChecks(
      result: result.inspection,
      attachmentPresent: updated != nil,
      attachmentFamily: attachmentFamily,
      noteStillPresent: noteStillPresent
    ) + [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "page_count_preserved",
        status: beforeCount == draft.pageCount && afterCount == draft.pageCount ? "passed" : "failed",
        expectedLength: draft.pageCount,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_delta",
        status: pdfHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "page_readback",
        status: result.page == draft.page ? "passed" : "failed",
        expectedLength: draft.page,
        actualLength: result.page
      ),
      NotesVerificationCheckRecord(
        name: "before_page_rotation_readback",
        status: result.beforePageRotation == draft.beforePageRotation ? "passed" : "failed",
        expectedLength: draft.beforePageRotation,
        actualLength: result.beforePageRotation
      ),
      NotesVerificationCheckRecord(
        name: "target_page_rotation_readback",
        status: result.afterPageRotation == draft.targetPageRotation ? "passed" : "failed",
        expectedLength: draft.targetPageRotation,
        actualLength: result.afterPageRotation
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_page_rotation_writer+pdf_hash_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentPDFPageMove(
    draft: NotesAttachmentPDFPageMoveDraft,
    result: NotesAttachmentPDFPageMoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let beforeCount = result.oldInspection.pdfPageCount
    let afterCount = result.inspection.pdfPageCount
    let pdfHashChanged = pdfPageMutationHashChanged(result.oldInspection, result.inspection)
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = pdfPageCommonChecks(
      result: result.inspection,
      attachmentPresent: updated != nil,
      attachmentFamily: attachmentFamily,
      noteStillPresent: noteStillPresent
    ) + [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "page_count_preserved",
        status: beforeCount == draft.pageCount && afterCount == draft.pageCount ? "passed" : "failed",
        expectedLength: draft.pageCount,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "pdf_page_order_hash_delta",
        status: pdfHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "from_page_readback",
        status: result.fromPage == draft.fromPage ? "passed" : "failed",
        expectedLength: draft.fromPage,
        actualLength: result.fromPage
      ),
      NotesVerificationCheckRecord(
        name: "to_page_readback",
        status: result.toPage == draft.toPage ? "passed" : "failed",
        expectedLength: draft.toPage,
        actualLength: result.toPage
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_page_move_writer+pdf_hash_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  func verifyAttachmentPDFPageDelete(
    draft: NotesAttachmentPDFPageDeleteDraft,
    result: NotesAttachmentPDFPageDeleteWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.inspection.attachment)
        || attachmentRecordMatches($0, draft.attachment)
    }
    let beforeCount = result.oldInspection.pdfPageCount
    let afterCount = result.inspection.pdfPageCount
    let pdfHashChanged = pdfPageMutationHashChanged(result.oldInspection, result.inspection)
    let attachmentFamily = attachmentScanPDFInspectionFamily(result.inspection)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = pdfPageCommonChecks(
      result: result.inspection,
      attachmentPresent: updated != nil,
      attachmentFamily: attachmentFamily,
      noteStillPresent: noteStillPresent
    ) + [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "page_count_decremented",
        status: beforeCount == draft.pageCount && afterCount == draft.pageCount - 1 ? "passed" : "failed",
        expectedLength: draft.pageCount - 1,
        actualLength: afterCount
      ),
      NotesVerificationCheckRecord(
        name: "pdf_page_delete_hash_delta",
        status: pdfHashChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashChanged
      ),
      NotesVerificationCheckRecord(
        name: "deleted_page_readback",
        status: result.page == draft.page ? "passed" : "failed",
        expectedLength: draft.page,
        actualLength: result.page
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_page_delete_writer+pdf_hash_readback+privacy_hash",
      targetIDSHA256: sha256Hex(result.inspection.attachment.id),
      checks: checks
    )
  }

  private func pdfPageCommonChecks(
    result: NotesAttachmentScanPDFInspectionSource,
    attachmentPresent: Bool,
    attachmentFamily: String,
    noteStillPresent: Bool
  ) -> [NotesVerificationCheckRecord] {
    let pdfHashAccounting = result.pdfDataSHA256?.count == 64
    let pageCountAccounting = (result.pdfPageCount ?? 0) > 0
    return [
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPresent
      ),
      NotesVerificationCheckRecord(
        name: "pdf_family",
        status: attachmentFamily == "pdf" ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentFamily == "pdf"
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_accounting",
        status: pdfHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "pdf_page_count_accounting",
        status: pageCountAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pageCountAccounting
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
  }

  private func pdfPageMutationHashChanged(
    _ before: NotesAttachmentScanPDFInspectionSource,
    _ after: NotesAttachmentScanPDFInspectionSource
  ) -> Bool {
    before.pdfDataSHA256 != nil
      && after.pdfDataSHA256 != nil
      && before.pdfDataSHA256 != after.pdfDataSHA256
  }

  func exportAttachmentPDF(
    _ source: NotesAttachmentPDFExportSource,
    requestedAttachmentID: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.export-pdf"
    let dataHash = sha256Hex(source.data)
    let summary = attachmentPDFExportSummary(
      source: source,
      requestedAttachmentID: requestedAttachmentID,
      destinationPath: destinationPath,
      dataHash: dataHash
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: attachmentPDFExportScopeDigest(source: source, destinationPath: destinationPath),
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "Notes attachment PDF export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeNotesPDFExport(source.data, to: destinationPath)
    let verification = try verifyAttachmentPDFExport(
      source: source,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      operation: operation
    )
    let result = NotesAttachmentPDFExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      destinationPath: destinationPath,
      byteCount: source.data.count,
      sha256: dataHash,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      sourceKind: source.sourceKind,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment PDF export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  func inspectAttachmentScanPDF(
    _ source: NotesAttachmentScanPDFInspectionSource,
    requestedAttachmentID: String,
    operation: String,
    acceptedFamilies: Set<String>,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    guard acceptedFamilies.contains(attachmentFamily) else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment inspection requires a PDF or scanned-document attachment.",
        details: [
          "operation": operation,
          "expected_family": acceptedFamilies.sorted().joined(separator: ","),
          "actual_family": attachmentFamily,
          "attachment_sha256": sha256Hex(source.attachment.id),
        ]
      )
    }
    let verification = try verifyAttachmentScanPDFInspection(
      source: source,
      operation: operation,
      acceptedFamilies: acceptedFamilies
    )
    let result = NotesAttachmentScanPDFInspectionResult(
      operation: operation,
      changed: false,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      requestedAttachmentID: requestedAttachmentID,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      attachmentFamily: attachmentFamily,
      pdfDataByteCount: source.pdfDataByteCount,
      pdfDataSHA256: source.pdfDataSHA256,
      pdfPageCount: source.pdfPageCount,
      pdfSourceKind: source.pdfSourceKind,
      croppingQuadPresent: source.croppingQuadPresent,
      croppingQuadSHA256: source.croppingQuadSHA256,
      scannedDocumentsMetadataPresent: source.scannedDocumentsMetadataPresent,
      scannedDocumentsMetadataCount: source.scannedDocumentsMetadataCount,
      scannedDocumentsMetadataSHA256: source.scannedDocumentsMetadataSHA256,
      docCamPDFVersion: source.docCamPDFVersion,
      orientation: source.orientation,
      orientationSHA256: source.orientationSHA256,
      imageFilterType: source.imageFilterType,
      imageFilterTypeSHA256: source.imageFilterTypeSHA256,
      sourceKinds: source.sourceKinds,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes PDF/scan attachment inspection verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) read", options: options)
  }

  private func attachmentPDFExportSummary(
    source: NotesAttachmentPDFExportSource,
    requestedAttachmentID: String,
    destinationPath: String,
    dataHash: String
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "requested_attachment": requestedAttachmentID,
      "destination_path": destinationPath,
      "byte_count": "\(source.data.count)",
      "sha256": dataHash,
      "title": source.attachment.title ?? "",
      "type_uti": source.attachment.typeUTI ?? "",
      "media_filename": source.attachment.mediaFilename ?? "",
      "source_kind": source.sourceKind,
    ]
  }

  private func attachmentPDFExportScopeDigest(
    source: NotesAttachmentPDFExportSource,
    destinationPath: String
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
      source.sourceKind,
    ].joined(separator: "|")
    return "notes-attachment-pdf-export:\(sha256Hex(fields))"
  }

  private func verifyAttachmentPDFExport(
    source: NotesAttachmentPDFExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let pdfHeader = fileData.count >= 4 && fileData.prefix(4) == Data("%PDF".utf8)
    let sourceKindReadback = [
      "media_pdf",
      "fallback_pdf_crypto",
      "paper_bundle_fallback_pdf",
      "doccam_generated_pdf",
    ].contains(source.sourceKind)
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "byte_count",
        status: fileData.count == source.data.count ? "passed" : "failed",
        expectedLength: source.data.count,
        actualLength: fileData.count
      ),
      NotesVerificationCheckRecord(
        name: "sha256",
        status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
      ),
      NotesVerificationCheckRecord(
        name: "pdf_header",
        status: pdfHeader ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHeader
      ),
      NotesVerificationCheckRecord(
        name: "pdf_source_kind",
        status: sourceKindReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceKindReadback
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_pdf_media_fallback_or_generated+artifact_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentScanPDFInspection(
    source: NotesAttachmentScanPDFInspectionSource,
    operation: String,
    acceptedFamilies: Set<String>
  ) throws -> NotesMutationVerificationReport {
    let attachmentFamily = attachmentScanPDFInspectionFamily(source)
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    let pdfHashAccounting =
      source.pdfDataByteCount == nil && source.pdfDataSHA256 == nil
        || (source.pdfDataByteCount ?? -1) >= 0 && source.pdfDataSHA256?.count == 64
    let metadataHashAccounting =
      source.croppingQuadSHA256 == nil || source.croppingQuadSHA256?.count == 64
    let scanMetadataHashAccounting =
      source.scannedDocumentsMetadataSHA256 == nil || source.scannedDocumentsMetadataSHA256?.count == 64
    let orientationHashAccounting =
      source.orientationSHA256 == nil || source.orientationSHA256?.count == 64
    let imageFilterTypeHashAccounting =
      source.imageFilterTypeSHA256 == nil || source.imageFilterTypeSHA256?.count == 64
    let hasInspectionEvidence =
      source.pdfDataSHA256 != nil
        || source.croppingQuadSHA256 != nil
        || source.scannedDocumentsMetadataSHA256 != nil
        || source.docCamPDFVersion != nil
        || source.orientationSHA256 != nil
        || source.imageFilterTypeSHA256 != nil
        || !source.sourceKinds.isEmpty
    let checks = [
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "accepted_attachment_family",
        status: acceptedFamilies.contains(attachmentFamily) ? "passed" : "failed",
        expectedBool: true,
        actualBool: acceptedFamilies.contains(attachmentFamily)
      ),
      NotesVerificationCheckRecord(
        name: "private_inspection_source",
        status: hasInspectionEvidence ? "passed" : "failed",
        expectedBool: true,
        actualBool: hasInspectionEvidence
      ),
      NotesVerificationCheckRecord(
        name: "pdf_hash_accounting",
        status: pdfHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "crop_metadata_hash_accounting",
        status: metadataHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "scan_metadata_hash_accounting",
        status: scanMetadataHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: scanMetadataHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "orientation_hash_accounting",
        status: orientationHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: orientationHashAccounting
      ),
      NotesVerificationCheckRecord(
        name: "image_filter_type_hash_accounting",
        status: imageFilterTypeHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: imageFilterTypeHashAccounting
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_scan_metadata_readback+privacy_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }
}
