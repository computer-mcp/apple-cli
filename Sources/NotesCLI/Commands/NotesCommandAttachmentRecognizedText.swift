import Foundation
import Utility

extension NotesCommand {

  func attachmentRecognizedTextExportFamilyFilter(_ options: CLIOptions) throws -> NotesAttachmentListFamilyFilter? {
    guard options.targetOption("family")?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
      return nil
    }
    let filter = try attachmentListFamilyFilter(options)
    guard let filter else {
      return nil
    }
    let accepted = attachmentRecognizedTextExportFamilies
    guard filter.includedFamilies.isSubset(of: accepted) else {
      throw CLIError(
        code: .validationError,
        message: "Notes recognized text export supports only scan, image, or drawing attachment families.",
        details: [
          "family": filter.canonicalName,
          "supported_families": "scanned-document,photo-image,drawing-or-sketch",
        ]
      )
    }
    return filter
  }

  private func validateRecognizedTextExportAttachmentFamily(
    _ actualFamily: String,
    familyFilter: NotesAttachmentListFamilyFilter?,
    operation: String
  ) throws {
    guard attachmentRecognizedTextExportFamilies.contains(actualFamily) else {
      throw CLIError(
        code: .validationError,
        message: "Notes recognized text export requires a scanned-document, image, or drawing attachment.",
        details: [
          "operation": operation,
          "actual_family": actualFamily,
          "supported_families": "scanned_document,photo_image,drawing_or_sketch",
        ]
      )
    }
    guard familyFilter?.includedFamilies.contains(actualFamily) ?? true else {
      throw CLIError(
        code: .validationError,
        message: "Notes recognized text export attachment did not match the requested family.",
        details: [
          "operation": operation,
          "requested_family": familyFilter?.canonicalName ?? "",
          "actual_family": actualFamily,
        ]
      )
    }
  }

  func exportAttachmentRecognizedText(
    _ source: NotesAttachmentSearchableTextSource,
    requestedAttachmentID: String,
    familyFilter: NotesAttachmentListFamilyFilter?,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.recognized-text.export"
    let family = attachmentAuditFamily(source.attachment)
    try validateRecognizedTextExportAttachmentFamily(
      family,
      familyFilter: familyFilter,
      operation: operation
    )
    let data = try attachmentRecognizedTextExportData(source.content)
    let dataHash = sha256Hex(data)
    let summary = attachmentRecognizedTextExportSummary(
      source: source,
      requestedAttachmentID: requestedAttachmentID,
      family: family,
      destinationPath: destinationPath,
      dataHash: dataHash,
      byteCount: data.count
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: attachmentRecognizedTextExportScopeDigest(
            source: source,
            family: family,
            destinationPath: destinationPath,
            dataHash: dataHash,
            byteCount: data.count
          ),
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try writeNotesAttachmentRecognizedTextExport(data, to: destinationPath)
    let verification = try verifyAttachmentRecognizedTextExport(
      source: source,
      family: family,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      expectedByteCount: data.count,
      operation: operation
    )
    let result = NotesAttachmentRecognizedTextExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      family: family,
      contentKinds: attachmentRecognizedTextContentKinds(source.content),
      sourceKinds: attachmentRecognizedTextSourceKinds(source.content),
      destinationPath: destinationPath,
      byteCount: data.count,
      sha256: dataHash,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes recognized text export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  func generateAttachmentRecognizedText(
    _ source: NotesAttachmentRecognizedTextGenerationInput,
    requestedAttachmentID: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.recognized-text.generate"
    let generation = try recognizedTextGenerator.generateRecognizedText(from: source)
    let data = try attachmentRecognizedTextGeneratedData(generation)
    let dataHash = sha256Hex(data)
    let sourceHash = sha256Hex(source.data)
    let summary = attachmentRecognizedTextGenerateSummary(
      source: source,
      generation: generation,
      requestedAttachmentID: requestedAttachmentID,
      destinationPath: destinationPath,
      dataHash: dataHash,
      byteCount: data.count,
      sourceHash: sourceHash
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: attachmentRecognizedTextGenerateScopeDigest(
            source: source,
            generation: generation,
            destinationPath: destinationPath,
            dataHash: dataHash,
            byteCount: data.count,
            sourceHash: sourceHash
          ),
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try writeNotesAttachmentRecognizedTextExport(data, to: destinationPath)
    let verification = try verifyAttachmentRecognizedTextGenerate(
      source: source,
      generation: generation,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      expectedByteCount: data.count,
      expectedSourceSHA256: sourceHash,
      operation: operation
    )
    let result = NotesAttachmentRecognizedTextGenerateResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      attachmentID: source.attachment.id,
      requestedAttachmentID: requestedAttachmentID,
      title: source.attachment.title,
      typeUTI: source.attachment.typeUTI,
      mediaFilename: source.attachment.mediaFilename,
      family: source.attachmentFamily,
      sourceKind: source.sourceKind,
      recognitionSourceKind: generation.sourceKind,
      usesPDFExport: source.usesPDFExport,
      sourceByteCount: source.data.count,
      sourceSHA256: sourceHash,
      destinationPath: destinationPath,
      byteCount: data.count,
      sha256: dataHash,
      pageCount: generation.pageCount,
      observationCount: generation.observationCount,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes recognized text generation verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  func indexAttachmentRecognizedText(
    _ draft: NotesAttachmentSearchIndexDraft,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.attachments.recognized-text.index"
    return try mutation(
      operation: operation,
      scopeDigest: attachmentRecognizedTextIndexScopeDigest(draft),
      summary: attachmentRecognizedTextIndexSummary(draft),
      options: options,
      category: .persistentAction,
      allowFlags: ["--allow-persistent-action"]
    ) {
      let write = try attachmentSearchIndexMutator().reindexAttachmentSearchableText(draft)
      let verification = verifyAttachmentRecognizedTextIndex(
        draft: draft,
        result: write,
        operation: operation
      )
      let result = NotesAttachmentSearchIndexResult(
        operation: operation,
        changed: true,
        noteID: write.noteID,
        attachmentID: write.attachment.id,
        requestedAttachmentID: draft.attachmentID,
        title: write.attachment.title,
        typeUTI: write.attachment.typeUTI,
        mediaFilename: write.attachment.mediaFilename,
        family: write.attachmentFamily,
        objectIDURISHA256: write.objectIDURISHA256,
        backendCalls: write.backendCalls,
        completionStatus: write.completionStatus,
        sourceKind: write.sourceKind,
        verification: verification
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes recognized text search index verification failed.",
          details: artifactVerificationFailureDetails(operation: operation, verification: verification)
        )
      }
      return result
    }
  }

  private var attachmentRecognizedTextExportFamilies: Set<String> {
    ["scanned_document", "photo_image", "drawing_or_sketch"]
  }

  func attachmentRecognizedTextGenerationInput(
    noteID: String,
    attachmentID: String,
    familyFilter: NotesAttachmentListFamilyFilter?
  ) throws -> NotesAttachmentRecognizedTextGenerationInput {
    let reader = try attachmentReader()
    let rawSource = try? reader.exportAttachment(noteID: noteID, attachmentID: attachmentID)
    if let rawSource {
      let family = attachmentAuditFamily(rawSource.attachment)
      try validateRecognizedTextExportAttachmentFamily(
        family,
        familyFilter: familyFilter,
        operation: "notes.attachments.recognized-text.generate"
      )
      if family == "scanned_document",
        let pdfSource = try? reader.exportAttachmentPDF(noteID: noteID, attachmentID: rawSource.attachment.id)
      {
        return NotesAttachmentRecognizedTextGenerationInput(
          noteID: pdfSource.noteID,
          attachment: pdfSource.attachment,
          attachmentFamily: family,
          data: pdfSource.data,
          sourceKind: pdfSource.sourceKind,
          usesPDFExport: true
        )
      }
      return NotesAttachmentRecognizedTextGenerationInput(
        noteID: rawSource.noteID,
        attachment: rawSource.attachment,
        attachmentFamily: family,
        data: rawSource.data,
        sourceKind: "NotesAttachmentReading.exportAttachment",
        usesPDFExport: false
      )
    }

    let pdfSource = try reader.exportAttachmentPDF(noteID: noteID, attachmentID: attachmentID)
    let family = attachmentAuditFamily(pdfSource.attachment)
    try validateRecognizedTextExportAttachmentFamily(
      family,
      familyFilter: familyFilter,
      operation: "notes.attachments.recognized-text.generate"
    )
    return NotesAttachmentRecognizedTextGenerationInput(
      noteID: pdfSource.noteID,
      attachment: pdfSource.attachment,
      attachmentFamily: family,
      data: pdfSource.data,
      sourceKind: pdfSource.sourceKind,
      usesPDFExport: true
    )
  }

  func attachmentRecognizedTextIndexDraft(
    noteID: String,
    attachmentID: String,
    familyFilter: NotesAttachmentListFamilyFilter?
  ) throws -> NotesAttachmentSearchIndexDraft {
    guard let note = try implementation.readNote(id: noteID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(noteID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateAttachmentSearchIndexState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.attachments.recognized-text.index"
      )
    }
    let matches = try attachmentReader().listAttachments(noteID: note.id, limit: 2_000)
      .filter { attachmentRecordMatches($0, selector: attachmentID) }
    guard let attachment = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachmentID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachmentID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    guard attachment.isDeletedOrInTrash != true else {
      throw CLIError(
        code: .validationError,
        message: "Notes recognized text search indexing requires a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachmentID),
        ]
      )
    }
    let family = attachmentAuditFamily(attachment)
    try validateRecognizedTextExportAttachmentFamily(
      family,
      familyFilter: familyFilter,
      operation: "notes.attachments.recognized-text.index"
    )
    return NotesAttachmentSearchIndexDraft(
      noteID: note.id,
      attachmentID: attachmentID,
      attachment: attachment,
      attachmentFamily: family
    )
  }

  private func validateAttachmentSearchIndexState(
    _ state: NotesNoteStateRecord,
    operation: String
  ) throws {
    if state.isDeletedOrInTrash {
      throw CLIError(
        code: .validationError,
        message: "Notes recognized text search indexing requires a visible note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    if state.isPasswordProtectedAndLocked == true {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes recognized text search indexing requires an unlocked note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    let needsCloudFetch = state.needsCloudFetch == true
    let isUnsupported = state.isUnsupported == true
    if needsCloudFetch || isUnsupported {
      throw CLIError(
        code: .validationError,
        message: "Notes recognized text search indexing requires a locally available supported note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
          "needs_cloud_fetch": "\(needsCloudFetch)",
          "is_unsupported": "\(isUnsupported)",
        ]
      )
    }
  }

  private func attachmentRecognizedTextExportSummary(
    source: NotesAttachmentSearchableTextSource,
    requestedAttachmentID: String,
    family: String,
    destinationPath: String,
    dataHash: String,
    byteCount: Int
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "requested_attachment": requestedAttachmentID,
      "destination_path": destinationPath,
      "attachment_family": family,
      "byte_count": "\(byteCount)",
      "sha256": dataHash,
      "content_kinds": attachmentRecognizedTextContentKinds(source.content).joined(separator: ","),
      "source_kinds": attachmentRecognizedTextSourceKinds(source.content).joined(separator: ","),
      "title": source.attachment.title ?? "",
      "type_uti": source.attachment.typeUTI ?? "",
      "media_filename": source.attachment.mediaFilename ?? "",
    ]
  }

  private func attachmentRecognizedTextIndexSummary(
    _ draft: NotesAttachmentSearchIndexDraft
  ) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "attachment_family": draft.attachmentFamily,
      "title": draft.attachment.title ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
      "backend_calls": "ICCDCSIReindexer.reindexSearchableItemsWithObjectIDURIs",
    ]
  }

  private func attachmentRecognizedTextGenerateSummary(
    source: NotesAttachmentRecognizedTextGenerationInput,
    generation: NotesAttachmentRecognizedTextGeneration,
    requestedAttachmentID: String,
    destinationPath: String,
    dataHash: String,
    byteCount: Int,
    sourceHash: String
  ) -> [String: String] {
    [
      "id": source.noteID,
      "attachment": source.attachment.id,
      "requested_attachment": requestedAttachmentID,
      "destination_path": destinationPath,
      "attachment_family": source.attachmentFamily,
      "source_kind": source.sourceKind,
      "recognition_source_kind": generation.sourceKind,
      "uses_pdf_export": source.usesPDFExport ? "true" : "false",
      "source_byte_count": "\(source.data.count)",
      "source_sha256": sourceHash,
      "byte_count": "\(byteCount)",
      "sha256": dataHash,
      "page_count": generation.pageCount.map(String.init) ?? "",
      "observation_count": "\(generation.observationCount)",
      "title": source.attachment.title ?? "",
      "type_uti": source.attachment.typeUTI ?? "",
      "media_filename": source.attachment.mediaFilename ?? "",
    ]
  }

  private func attachmentRecognizedTextExportScopeDigest(
    source: NotesAttachmentSearchableTextSource,
    family: String,
    destinationPath: String,
    dataHash: String,
    byteCount: Int
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      family,
      destinationPath,
      "\(byteCount)",
      dataHash,
      attachmentRecognizedTextContentKinds(source.content).joined(separator: ","),
      attachmentRecognizedTextSourceKinds(source.content).joined(separator: ","),
    ].joined(separator: "|")
    return "notes-attachment-recognized-text-export:\(sha256Hex(fields))"
  }

  private func attachmentRecognizedTextGenerateScopeDigest(
    source: NotesAttachmentRecognizedTextGenerationInput,
    generation: NotesAttachmentRecognizedTextGeneration,
    destinationPath: String,
    dataHash: String,
    byteCount: Int,
    sourceHash: String
  ) -> String {
    let fields = [
      source.noteID,
      source.attachment.id,
      source.attachmentFamily,
      destinationPath,
      "\(byteCount)",
      dataHash,
      "\(source.data.count)",
      sourceHash,
      source.sourceKind,
      generation.sourceKind,
      generation.pageCount.map(String.init) ?? "",
      "\(generation.observationCount)",
    ].joined(separator: "|")
    return "notes-attachment-recognized-text-generate:\(sha256Hex(fields))"
  }

  private func attachmentRecognizedTextIndexScopeDigest(
    _ draft: NotesAttachmentSearchIndexDraft
  ) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachmentFamily,
      draft.attachment.typeUTI ?? "",
      draft.attachment.mediaFilename ?? "",
    ].joined(separator: "|")
    return "notes-attachment-recognized-text-index:\(sha256Hex(fields))"
  }

  private func attachmentRecognizedTextContentKinds(
    _ content: [NotesAttachmentSearchableTextContentSource]
  ) -> [String] {
    stableUniqueStrings(content.map(\.kind))
  }

  private func attachmentRecognizedTextSourceKinds(
    _ content: [NotesAttachmentSearchableTextContentSource]
  ) -> [String] {
    stableUniqueStrings(content.map(\.sourceKind))
  }

  private func attachmentRecognizedTextExportData(
    _ content: [NotesAttachmentSearchableTextContentSource]
  ) throws -> Data {
    var seen: Set<String> = []
    var chunks: [String] = []
    for item in content {
      let text = item.text.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !text.isEmpty else {
        continue
      }
      guard seen.insert(sha256Hex(text)).inserted else {
        continue
      }
      chunks.append(text)
    }
    guard !chunks.isEmpty else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment does not expose non-empty recognized text through Notes private APIs."
      )
    }
    return Data(chunks.joined(separator: "\n\n").utf8)
  }

  private func attachmentRecognizedTextGeneratedData(
    _ generation: NotesAttachmentRecognizedTextGeneration
  ) throws -> Data {
    let text = generation.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Recognized text generation produced no non-empty text."
      )
    }
    return Data(text.utf8)
  }

  private var attachmentRecognizedTextExportAllowedSourceKinds: Set<String> {
    [
      "ICAttachment.searchableTextContent",
      "ICAttachment.searchableTextContentWithoutTitle",
      "ICAttachment.attachmentModel.searchableTextContent",
      "ICAttachment.attachmentModel.searchableTextContentForLocation",
      "ICAttachment.attachmentModel.searchableTextContentInNote",
      "ICAttachment.attachmentModel.additionalIndexableTextContentInNote",
      "ICAttachment.attachmentModel.textContentInNote",
    ]
  }

  private func verifyAttachmentRecognizedTextExport(
    source: NotesAttachmentSearchableTextSource,
    family: String,
    destinationPath: String,
    expectedSHA256: String,
    expectedByteCount: Int,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let readback = try attachmentReader().readAttachmentSearchableText(
      noteID: source.noteID,
      attachmentID: source.attachment.id
    )
    let readbackData = try attachmentRecognizedTextExportData(readback.content)
    let readbackFamily = attachmentAuditFamily(readback.attachment)
    let readbackSHA256 = sha256Hex(readbackData)
    let contentKinds = attachmentRecognizedTextContentKinds(readback.content)
    let sourceKinds = attachmentRecognizedTextSourceKinds(readback.content)
    let sourceKindsSupported = Set(sourceKinds).isSubset(of: attachmentRecognizedTextExportAllowedSourceKinds)
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "byte_count",
        status: fileData.count == expectedByteCount ? "passed" : "failed",
        expectedLength: expectedByteCount,
        actualLength: fileData.count
      ),
      NotesVerificationCheckRecord(
        name: "sha256",
        status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
      ),
      NotesVerificationCheckRecord(
        name: "private_searchable_text_readback",
        status: readbackSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: readbackSHA256
      ),
      NotesVerificationCheckRecord(
        name: "attachment_family",
        status: readbackFamily == family && attachmentRecognizedTextExportFamilies.contains(readbackFamily)
          ? "passed"
          : "failed",
        expectedBool: true,
        actualBool: readbackFamily == family && attachmentRecognizedTextExportFamilies.contains(readbackFamily)
      ),
      NotesVerificationCheckRecord(
        name: "content_kind_accounting",
        status: contentKinds.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: !contentKinds.isEmpty
      ),
      NotesVerificationCheckRecord(
        name: "source_kind_supported",
        status: sourceKindsSupported ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceKindsSupported
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_searchable_text_readback+artifact_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentRecognizedTextGenerate(
    source: NotesAttachmentRecognizedTextGenerationInput,
    generation: NotesAttachmentRecognizedTextGeneration,
    destinationPath: String,
    expectedSHA256: String,
    expectedByteCount: Int,
    expectedSourceSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let readback = try attachmentRecognizedTextGenerationReadback(source)
    let readbackFamily = attachmentAuditFamily(readback.attachment)
    let readbackSHA256 = sha256Hex(readback.data)
    let generatedData = try attachmentRecognizedTextGeneratedData(generation)
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "byte_count",
        status: fileData.count == expectedByteCount ? "passed" : "failed",
        expectedLength: expectedByteCount,
        actualLength: fileData.count
      ),
      NotesVerificationCheckRecord(
        name: "sha256",
        status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
      ),
      NotesVerificationCheckRecord(
        name: "generated_text_non_empty",
        status: generatedData.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: !generatedData.isEmpty
      ),
      NotesVerificationCheckRecord(
        name: "private_attachment_media_readback",
        status: readbackSHA256 == expectedSourceSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSourceSHA256,
        actualSHA256: readbackSHA256
      ),
      NotesVerificationCheckRecord(
        name: "attachment_family",
        status: readbackFamily == source.attachmentFamily
          && attachmentRecognizedTextExportFamilies.contains(readbackFamily)
          ? "passed"
          : "failed",
        expectedBool: true,
        actualBool: readbackFamily == source.attachmentFamily
          && attachmentRecognizedTextExportFamilies.contains(readbackFamily)
      ),
      NotesVerificationCheckRecord(
        name: "recognition_observation_count",
        status: generation.observationCount > 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: generation.observationCount > 0
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_media_readback+vision_text_artifact_hash",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  private func attachmentRecognizedTextGenerationReadback(
    _ source: NotesAttachmentRecognizedTextGenerationInput
  ) throws -> NotesAttachmentRecognizedTextGenerationInput {
    let reader = try attachmentReader()
    if source.usesPDFExport {
      let readback = try reader.exportAttachmentPDF(
        noteID: source.noteID,
        attachmentID: source.attachment.id
      )
      return NotesAttachmentRecognizedTextGenerationInput(
        noteID: readback.noteID,
        attachment: readback.attachment,
        attachmentFamily: attachmentAuditFamily(readback.attachment),
        data: readback.data,
        sourceKind: readback.sourceKind,
        usesPDFExport: true
      )
    }
    let readback = try reader.exportAttachment(noteID: source.noteID, attachmentID: source.attachment.id)
    return NotesAttachmentRecognizedTextGenerationInput(
      noteID: readback.noteID,
      attachment: readback.attachment,
      attachmentFamily: attachmentAuditFamily(readback.attachment),
      data: readback.data,
      sourceKind: "NotesAttachmentReading.exportAttachment",
      usesPDFExport: false
    )
  }

  private func verifyAttachmentRecognizedTextIndex(
    draft: NotesAttachmentSearchIndexDraft,
    result: NotesAttachmentSearchIndexWriteResult,
    operation: String
  ) -> NotesMutationVerificationReport {
    let expectedImplementationCall = "ICCDCSIReindexer.reindexSearchableItemsWithObjectIDURIs"
    let implementationCallAccepted = result.backendCalls.contains(expectedImplementationCall)
    let completionAccepted = result.completionStatus == "completed"
    let familyAccepted = result.attachmentFamily == draft.attachmentFamily
      && attachmentRecognizedTextExportFamilies.contains(result.attachmentFamily)
    let attachmentPreserved = result.attachment.id == draft.attachment.id
    let checks = [
      NotesVerificationCheckRecord(
        name: "attachment_identity_preserved",
        status: attachmentPreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPreserved
      ),
      NotesVerificationCheckRecord(
        name: "attachment_family_supported",
        status: familyAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: familyAccepted
      ),
      NotesVerificationCheckRecord(
        name: "object_id_uri_hash_present",
        status: result.objectIDURISHA256.isEmpty ? "failed" : "passed",
        expectedBool: true,
        actualBool: !result.objectIDURISHA256.isEmpty
      ),
      NotesVerificationCheckRecord(
        name: "private_reindexer_call",
        status: implementationCallAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: implementationCallAccepted
      ),
      NotesVerificationCheckRecord(
        name: "completion_status",
        status: completionAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: completionAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_corespotlight_reindexer+object_uri_hash",
      targetIDSHA256: sha256Hex(result.attachment.id),
      checks: checks
    )
  }

  private func attachmentSearchIndexMutator() throws -> any NotesAttachmentSearchIndexMutating {
    guard let attachmentSearchIndexMutator = implementation as? any NotesAttachmentSearchIndexMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes recognized text search indexing requires a private-framework CoreSpotlight reindexer.",
        details: [
          "capability": "attachment_search_index_mutation",
          "required_module": "NotesSupport.ICCDCSIReindexer",
        ]
      )
    }
    return attachmentSearchIndexMutator
  }
}
