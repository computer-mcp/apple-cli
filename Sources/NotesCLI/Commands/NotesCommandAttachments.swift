import Foundation
import Utility

extension NotesCommand {
  func runAttachments(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["attachments", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "account", "folder", "family"])
      let id = options.targetOption("id")
      if id?.isEmpty == false && options.targetOption("folder")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for `attachments list`."
        )
      }
      if id?.isEmpty == false && options.targetOption("account")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for `attachments list`."
        )
      }
      let familyFilter = try attachmentListFamilyFilter(options)
      if let id, !id.isEmpty {
        let attachments = attachmentListFilteredAttachments(
          try attachmentReader().listAttachments(
            noteID: id,
            limit: try commandLimit(options)
          ),
          familyFilter: familyFilter
        )
        return try result(
          NotesAttachmentsResponse(noteID: id, attachments: attachments),
          human: attachments.map { attachment in
            [
              attachment.id,
              attachment.title ?? "",
              attachment.typeUTI ?? "",
              attachment.fileSizeBytes.map(String.init) ?? "",
            ].joined(separator: "\t")
          }.joined(separator: "\n"),
          options: options
        )
      }
      let collection = try attachmentListCollectionRecords(options, familyFilter: familyFilter)
      let familyCounts = attachmentListFamilyCounts(collection.records)
      let verification = verifyAttachmentListCollection(
        records: collection.records,
        scannedNoteCount: collection.scannedNoteCount,
        familyFilter: familyFilter,
        familyCounts: familyCounts
      )
      return try result(
        NotesAttachmentCollectionResponse(
          account: options.targetOption("account"),
          folder: options.targetOption("folder"),
          family: familyFilter?.canonicalName,
          scannedNoteCount: collection.scannedNoteCount,
          familyCounts: familyCounts,
          notes: collection.records,
          verification: verification
        ),
        human: collection.records.flatMap { record in
          record.attachments.map { attachment in
            [
              record.note.id,
              attachment.id,
              attachment.title ?? "",
              attachment.typeUTI ?? "",
              attachment.fileSizeBytes.map(String.init) ?? "",
            ].joined(separator: "\t")
          }
        }.joined(separator: "\n"),
        options: options
      )
    case ["attachments", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "id", "account", "folder", "family"])
      return try searchAttachmentMetadata(options)
    case ["attachments", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account", "folder"])
      let records = try attachmentAuditRecords(options)
      let summary = attachmentAuditSummary(records)
      let verification = verifyAttachmentAudit(records: records, summary: summary)
      return try result(
        NotesAttachmentAuditResponse(
          account: options.targetOption("account"),
          folder: options.targetOption("folder"),
          summary: summary,
          records: records,
          verification: verification
        ),
        human: [
          "notes: \(summary.noteCount)",
          "attachments: \(summary.attachmentCount)",
          "visible: \(summary.visibleAttachmentCount)",
          "families: \(summary.familyCounts.map { "\($0.name)=\($0.count)" }.joined(separator: ","))",
        ].joined(separator: "\t"),
        options: options
      )
    case ["attachments", "workflow", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try attachmentWorkflowAudit(options)
    case ["attachments", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "file", "files", "name"])
      try validateMutationIntent(options)
      let draft = try attachmentAddDraft(options)
      if draft.attachments.count > 1 {
        return try mutation(
          operation: "notes.attachments.add",
          scopeDigest: attachmentAddBatchScopeDigest(draft),
          summary: attachmentAddBatchSummary(draft),
          options: options
        ) {
          let mutator = try attachmentMutator()
          var itemResults: [NotesAttachmentAddBatchItemResult] = []
          var verificationInputs: [
            (draft: NotesAttachmentAddDraft, write: NotesAttachmentAddWriteResult, verification: NotesMutationVerificationReport)
          ] = []
          for attachment in draft.attachments {
            let write = try mutator.addAttachment(attachment)
            let verification = try verifyAttachmentAdd(
              draft: attachment,
              result: write,
              operation: "notes.attachments.add"
            )
            guard verification.verified else {
              throw CLIError(
                code: .internalError,
                message: "Notes attachment add verification failed.",
                details: artifactVerificationFailureDetails(
                  operation: "notes.attachments.add",
                  verification: verification
                )
              )
            }
            itemResults.append(
              NotesAttachmentAddBatchItemResult(
                filename: attachment.filename,
                attachment: write.attachment,
                byteCount: attachment.data.count,
                sha256: sha256Hex(attachment.data),
                verification: verification
              )
            )
            verificationInputs.append((attachment, write, verification))
          }
          let verification = try verifyAttachmentAddBatch(
            draft: draft,
            results: verificationInputs,
            operation: "notes.attachments.add"
          )
          guard verification.verified else {
            throw CLIError(
              code: .internalError,
              message: "Notes attachment add batch verification failed.",
              details: artifactVerificationFailureDetails(
                operation: "notes.attachments.add",
                verification: verification
              )
            )
          }
          return NotesAttachmentAddBatchResult(
            operation: "notes.attachments.add",
            changed: true,
            noteID: draft.noteID,
            attachmentCount: itemResults.count,
            totalByteCount: attachmentAddTotalByteCount(draft.attachments),
            aggregateSHA256: attachmentAddAggregateSHA256(draft.attachments),
            attachments: itemResults.map(\.attachment),
            items: itemResults,
            verification: verification
          )
        }
      }
      let attachment = try singleAttachmentAddDraft(draft)
      return try mutation(
        operation: "notes.attachments.add",
        scopeDigest: attachmentAddScopeDigest(attachment),
        summary: attachmentAddSummary(attachment),
        options: options
      ) {
        let write = try attachmentMutator().addAttachment(attachment)
        let verification = try verifyAttachmentAdd(
          draft: attachment,
          result: write,
          operation: "notes.attachments.add"
        )
        let result = NotesAttachmentAddResult(
          operation: "notes.attachments.add",
          changed: true,
          noteID: write.noteID,
          attachment: write.attachment,
          byteCount: attachment.data.count,
          sha256: sha256Hex(attachment.data),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes attachment add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.attachments.add",
              verification: verification
            )
          )
        }
        return result
      }
    case ["attachments", "copy"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "target", "name"])
      try validateMutationIntent(options)
      let draft = try attachmentCopyDraft(options)
      return try mutation(
        operation: "notes.attachments.copy",
        scopeDigest: attachmentCopyScopeDigest(draft),
        summary: attachmentCopySummary(draft),
        options: options
      ) {
        let addDraft = NotesAttachmentAddDraft(
          noteID: draft.targetNoteID,
          filename: draft.filename,
          sourcePath: "notes://attachment/\(sha256Hex(draft.sourceAttachment.id))",
          data: draft.data
        )
        let write = try attachmentMutator().addAttachment(addDraft)
        let addVerification = try verifyAttachmentAdd(
          draft: addDraft,
          result: write,
          operation: "notes.attachments.copy"
        )
        let verification = try verifyAttachmentCopy(
          draft: draft,
          result: write,
          addVerification: addVerification
        )
        let result = NotesAttachmentCopyResult(
          operation: "notes.attachments.copy",
          changed: true,
          sourceNoteIDSHA256: sha256Hex(draft.sourceNoteID),
          targetNoteID: write.noteID,
          targetNoteIDSHA256: sha256Hex(write.noteID),
          sourceAttachmentIDSHA256: sha256Hex(draft.sourceAttachment.id),
          attachment: write.attachment,
          filename: draft.filename,
          byteCount: draft.data.count,
          sha256: sha256Hex(draft.data),
          verification: verification
        )
        return try verifiedAttachmentCopyResult(result)
      }
    case ["attachments", "add-webpage"]:
      try validateTargetOptions(options, allowedOptions: ["id", "url"])
      try validateMutationIntent(options)
      let draft = try webpageAttachmentAddDraft(options)
      return try mutation(
        operation: "notes.attachments.add-webpage",
        scopeDigest: webpageAttachmentAddScopeDigest(draft),
        summary: webpageAttachmentAddSummary(draft),
        options: options
      ) {
        let write = try linkMutator().addWebpageAttachment(draft)
        let verification = try verifyWebpageAttachmentAdd(
          draft: draft,
          result: write,
          operation: "notes.attachments.add-webpage"
        )
        let result = NotesWebpageAttachmentAddResult(
          operation: "notes.attachments.add-webpage",
          changed: true,
          noteID: write.noteID,
          webpagePreview: write.link,
          urlSHA256: sha256Hex(draft.urlString),
          attachmentFamily: webpagePreviewFamily(urlString: draft.urlString),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes webpage attachment add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.attachments.add-webpage",
              verification: verification
            )
          )
        }
        return result
      }
    case ["attachments", "update-webpage"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "url"])
      try validateMutationIntent(options)
      let draft = try webpageAttachmentUpdateDraft(options)
      return try mutation(
        operation: "notes.attachments.update-webpage",
        scopeDigest: webpageAttachmentUpdateScopeDigest(draft),
        summary: webpageAttachmentUpdateSummary(draft),
        options: options
      ) {
        let write = try linkMutator().updateWebpageAttachment(draft)
        let verification = try verifyWebpageAttachmentUpdate(
          draft: draft,
          result: write,
          operation: "notes.attachments.update-webpage"
        )
        let result = NotesWebpageAttachmentUpdateResult(
          operation: "notes.attachments.update-webpage",
          changed: write.changed,
          noteID: write.noteID,
          oldWebpagePreview: write.oldLink,
          webpagePreview: write.link,
          oldURLSHA256: write.oldLink.urlString.map(sha256Hex) ?? write.oldLink.urlSHA256,
          urlSHA256: sha256Hex(draft.urlString),
          attachmentFamily: webpagePreviewFamily(urlString: draft.urlString),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes webpage attachment update verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.attachments.update-webpage",
              verification: verification
            )
          )
        }
        return result
      }
    case ["attachments", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "name"])
      try validateMutationIntent(options)
      let draft = try attachmentRenameDraft(options, operation: "notes.attachments.rename")
      return try mutation(
        operation: "notes.attachments.rename",
        scopeDigest: attachmentRenameScopeDigest(draft),
        summary: attachmentRenameSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().renameAttachment(draft)
        let verification = try verifyAttachmentRename(
          draft: draft,
          result: write,
          operation: "notes.attachments.rename"
        )
        let result = NotesAttachmentRenameResult(
          operation: "notes.attachments.rename",
          changed: write.changed,
          noteID: write.noteID,
          oldAttachment: write.oldAttachment,
          attachment: write.attachment,
          oldNameSHA256: (write.oldAttachment.title ?? write.oldAttachment.mediaFilename).map(sha256Hex),
          nameSHA256: sha256Hex(draft.name),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes attachment rename verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.attachments.rename",
              verification: verification
            )
          )
        }
        return result
      }
    case ["attachments", "audio", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try audioWorkflowAudit(options)
    case ["attachments", "audio", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "name"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.audio.rename"
      let draft = try attachmentRenameDraft(
        options,
        operation: operation,
        requiredFamily: "audio_recording"
      )
      return try mutation(
        operation: operation,
        scopeDigest: attachmentRenameScopeDigest(draft),
        summary: attachmentRenameSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().renameAttachment(draft)
        let verification = try verifyAttachmentRename(
          draft: draft,
          result: write,
          operation: operation,
          requiredFamily: "audio_recording"
        )
        let result = NotesAttachmentRenameResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          oldAttachment: write.oldAttachment,
          attachment: write.attachment,
          oldNameSHA256: (write.oldAttachment.title ?? write.oldAttachment.mediaFilename).map(sha256Hex),
          nameSHA256: sha256Hex(draft.name),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes audio attachment rename verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "remove"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      try validateMutationIntent(options)
      let draft = try attachmentRemoveDraft(options, operation: "notes.attachments.remove")
      return try mutation(
        operation: "notes.attachments.remove",
        scopeDigest: attachmentRemoveScopeDigest(draft),
        summary: attachmentRemoveSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().removeAttachment(draft)
        let verification = try verifyAttachmentRemove(
          draft: draft,
          result: write,
          operation: "notes.attachments.remove"
        )
        let result = NotesAttachmentRemoveResult(
          operation: "notes.attachments.remove",
          changed: write.changed,
          noteID: write.noteID,
          attachment: write.attachment,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes attachment remove verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.attachments.remove",
              verification: verification
            )
          )
        }
        return result
      }
    case ["attachments", "audio", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.audio.delete"
      let draft = try attachmentRemoveDraft(
        options,
        operation: operation,
        requiredFamily: "audio_recording"
      )
      return try mutation(
        operation: operation,
        scopeDigest: attachmentRemoveScopeDigest(draft),
        summary: attachmentRemoveSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().removeAttachment(draft)
        let verification = try verifyAttachmentRemove(
          draft: draft,
          result: write,
          operation: operation,
          requiredFamily: "audio_recording"
        )
        let result = NotesAttachmentRemoveResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachment: write.attachment,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes audio attachment delete verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "export"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesAttachmentExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes attachment export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try attachmentReader().exportAttachment(noteID: id, attachmentID: attachmentID)
      return try exportAttachment(
        source,
        requestedAttachmentID: attachmentID,
        destinationPath: destinationPath,
        options: options
      )
    case ["attachments", "audio", "save"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesAttachmentExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes audio attachment save writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try attachmentReader().exportAttachment(noteID: id, attachmentID: attachmentID)
      try validateAttachmentFamily(
        source.attachment,
        expectedFamily: "audio_recording",
        operation: "notes.attachments.audio.save"
      )
      return try exportAttachment(
        source,
        requestedAttachmentID: attachmentID,
        destinationPath: destinationPath,
        options: options,
        operation: "notes.attachments.audio.save",
        requiredFamily: "audio_recording",
        artifactMessage: "Notes audio attachment save writes a filesystem artifact and requires `--allow-artifact-action`."
      )
    case ["attachments", "export-pdf"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesPDFExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes attachment PDF export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try attachmentReader().exportAttachmentPDF(noteID: id, attachmentID: attachmentID)
      return try exportAttachmentPDF(
        source,
        requestedAttachmentID: attachmentID,
        destinationPath: destinationPath,
        options: options
      )
    case ["attachments", "pdf", "inspect"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let source = try attachmentReader().inspectAttachmentScanPDF(noteID: id, attachmentID: attachmentID)
      return try inspectAttachmentScanPDF(
        source,
        requestedAttachmentID: attachmentID,
        operation: "notes.attachments.pdf.inspect",
        acceptedFamilies: ["pdf", "scanned_document"],
        options: options
      )
    case ["attachments", "pdf", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "id", "account", "folder"])
      return try searchAttachmentPDFText(options)
    case ["attachments", "scan", "inspect"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let source = try attachmentReader().inspectAttachmentScanPDF(noteID: id, attachmentID: attachmentID)
      return try inspectAttachmentScanPDF(
        source,
        requestedAttachmentID: attachmentID,
        operation: "notes.attachments.scan.inspect",
        acceptedFamilies: ["scanned_document"],
        options: options
      )
    case ["attachments", "scan", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "id", "account", "folder"])
      return try searchAttachmentSearchableText(
        options,
        family: NotesAttachmentSearchableTextSearchFamily(
          operation: "notes.attachments.scan.search",
          contentFamily: "scanned_document",
          includedFamilies: ["scanned_document"],
          searchedContentKinds: [
            "searchable_text",
            "searchable_text_without_title",
            "model_searchable_text",
            "location_searchable_text",
            "note_searchable_text",
            "additional_indexable_text",
            "text_content_in_note",
          ]
        ))
    case ["attachments", "image", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "id", "account", "folder"])
      return try searchAttachmentSearchableText(
        options,
        family: NotesAttachmentSearchableTextSearchFamily(
          operation: "notes.attachments.image.search",
          contentFamily: "photo_image",
          includedFamilies: ["photo_image"],
          searchedContentKinds: [
            "searchable_text",
            "searchable_text_without_title",
            "model_searchable_text",
            "location_searchable_text",
            "note_searchable_text",
            "additional_indexable_text",
            "text_content_in_note",
          ]
        ))
    case ["attachments", "image", "description", "get"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "attachment"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let source = try attachmentReader().readAttachmentImageDescription(noteID: id, attachmentID: attachmentID)
      return try readAttachmentImageDescription(source, requestedAttachmentID: attachmentID, options: options)
    case ["attachments", "image", "description", "set"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "description"])
      try validateMutationIntent(options)
      let draft = try attachmentImageDescriptionDraft(options)
      return try mutation(
        operation: "notes.attachments.image.description.set",
        scopeDigest: attachmentImageDescriptionScopeDigest(draft),
        summary: attachmentImageDescriptionSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().setAttachmentImageDescription(draft)
        let verification = try verifyAttachmentImageDescriptionSet(draft: draft, result: write)
        return attachmentImageDescriptionResult(
          operation: "notes.attachments.image.description.set",
          changed: write.changed,
          source: write.source,
          requestedAttachmentID: draft.attachmentID,
          previousSource: write.oldSource,
          verification: verification
        )
      }
    case ["attachments", "image", "crop"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "attachment", "top-left", "top-right", "bottom-right", "bottom-left"]
      )
      try validateMutationIntent(options)
      let operation = "notes.attachments.image.crop"
      let draft = try attachmentImageCropDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentImageCropScopeDigest(draft),
        summary: attachmentImageCropSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().cropImageAttachment(draft)
        let verification = try verifyAttachmentImageCrop(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentImageCropResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.source.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.source.attachment.title,
          typeUTI: write.source.attachment.typeUTI,
          mediaFilename: write.source.attachment.mediaFilename,
          attachmentFamily: attachmentAuditFamily(write.source.attachment),
          requestedCropRectSHA256: write.requestedCropRectSHA256,
          cropPointCount: 4,
          beforeImageDataByteCount: write.oldSource.dataByteCount,
          afterImageDataByteCount: write.source.dataByteCount,
          beforeImageDataSHA256: write.oldSource.dataSHA256,
          afterImageDataSHA256: write.source.dataSHA256,
          sourceKind: write.sourceKind,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes image crop verification failed.",
            details: [
              "operation": operation,
              "failed_checks": verification.checks
                .filter { $0.status == "failed" }
                .map(\.name)
                .joined(separator: ","),
              "target_id_sha256": verification.targetIDSHA256,
            ]
          )
        }
        return result
      }
    case ["attachments", "image", "rotate"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "by", "direction"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.image.rotate"
      let draft = try attachmentImageRotateDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentImageRotateScopeDigest(draft),
        summary: attachmentImageRotateSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().rotateImageAttachment(draft)
        let verification = try verifyAttachmentImageRotate(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentImageRotateResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.source.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.source.attachment.title,
          typeUTI: write.source.attachment.typeUTI,
          mediaFilename: write.source.attachment.mediaFilename,
          attachmentFamily: attachmentAuditFamily(write.source.attachment),
          rotationDeltaDegrees: write.rotationDeltaDegrees,
          beforeImageDataByteCount: write.oldSource.dataByteCount,
          afterImageDataByteCount: write.source.dataByteCount,
          beforeImageDataSHA256: write.oldSource.dataSHA256,
          afterImageDataSHA256: write.source.dataSHA256,
          sourceKind: write.sourceKind,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes image rotation verification failed.",
            details: [
              "operation": operation,
              "failed_checks": verification.checks
                .filter { $0.status == "failed" }
                .map(\.name)
                .joined(separator: ","),
              "target_id_sha256": verification.targetIDSHA256,
            ]
          )
        }
        return result
      }
    case ["attachments", "image", "objects"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "query"])
      let sourceNoteID = try requiredOption("id", options: options)
      let requestedAttachmentID = try requiredOption("attachment", options: options)
      let source = try attachmentReader().readAttachmentImageObjects(
        noteID: sourceNoteID,
        attachmentID: requestedAttachmentID
      )
      let family = attachmentAuditFamily(source.attachment)
      guard family == "photo_image" else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Notes image object classification requires a photo/image attachment.",
          details: [
            "operation": "notes.attachments.image.objects",
            "attachment_id_sha256": sha256Hex(source.attachment.id),
            "attachment_family": family,
            "supported_family": "photo_image",
          ]
        )
      }
      let query = try attachmentImageObjectQuery(options)
      let queryMatchCount = query.map {
        source.classificationSummaryText?.range(
          of: $0,
          options: [.caseInsensitive, .diacriticInsensitive]
        ) == nil ? 0 : 1
      }
      let verification = verifyAttachmentImageObjects(
        source: source,
        attachmentFamily: family,
        query: query,
        queryMatchCount: queryMatchCount,
        operation: "notes.attachments.image.objects"
      )
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes image object classification verification failed.",
          details: artifactVerificationFailureDetails(
            operation: "notes.attachments.image.objects",
            verification: verification
          )
        )
      }
      return try result(
        NotesAttachmentImageObjectResult(
          operation: "notes.attachments.image.objects",
          changed: false,
          noteID: source.noteID,
          attachmentID: source.attachment.id,
          requestedAttachmentID: requestedAttachmentID,
          title: source.attachment.title,
          typeUTI: source.attachment.typeUTI,
          mediaFilename: source.attachment.mediaFilename,
          attachmentFamily: family,
          classificationSummaryPresent: source.classificationSummaryText != nil,
          classificationSummaryByteCount: source.classificationSummaryText.map { $0.utf8.count },
          classificationSummarySHA256: source.classificationSummaryText.map(sha256Hex),
          classificationSummaryVersion: source.classificationSummaryVersion,
          queryByteCount: query.map { $0.utf8.count },
          querySHA256: query.map(sha256Hex),
          queryMatchCount: queryMatchCount,
          sourceKind: source.sourceKind,
          backendCalls: source.backendCalls,
          verification: verification
        ),
        human: [
          "attachment_id: \(source.attachment.id)",
          "classification_summary_present: \(source.classificationSummaryText != nil)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["attachments", "drawing", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "id", "account", "folder"])
      return try searchAttachmentSearchableText(
        options,
        family: NotesAttachmentSearchableTextSearchFamily(
          operation: "notes.attachments.drawing.search",
          contentFamily: "drawing_or_sketch",
          includedFamilies: ["drawing_or_sketch"],
          searchedContentKinds: [
            "searchable_text",
            "searchable_text_without_title",
            "model_searchable_text",
            "location_searchable_text",
            "note_searchable_text",
            "additional_indexable_text",
            "text_content_in_note",
          ]
        ))
    case ["attachments", "recognized-text", "generate"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "family", "output"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      let familyFilter = try attachmentRecognizedTextExportFamilyFilter(options)
      try validateNotesAttachmentRecognizedTextExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message:
            "Notes recognized text generation writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try attachmentRecognizedTextGenerationInput(
        noteID: id,
        attachmentID: attachmentID,
        familyFilter: familyFilter
      )
      return try generateAttachmentRecognizedText(
        source,
        requestedAttachmentID: attachmentID,
        destinationPath: destinationPath,
        options: options
      )
    case ["attachments", "recognized-text", "export"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output", "family"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      let familyFilter = try attachmentRecognizedTextExportFamilyFilter(options)
      try validateNotesAttachmentRecognizedTextExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes recognized text export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try attachmentReader().readAttachmentSearchableText(noteID: id, attachmentID: attachmentID)
      return try exportAttachmentRecognizedText(
        source,
        requestedAttachmentID: attachmentID,
        familyFilter: familyFilter,
        destinationPath: destinationPath,
        options: options
      )
    case ["attachments", "recognized-text", "index"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "family"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let familyFilter = try attachmentRecognizedTextExportFamilyFilter(options)
      let draft = try attachmentRecognizedTextIndexDraft(
        noteID: id,
        attachmentID: attachmentID,
        familyFilter: familyFilter
      )
      return try indexAttachmentRecognizedText(draft, options: options)
    case ["attachments", "scan", "capture"]:
      try validateTargetOptions(options, allowedOptions: ["id", "name"])
      _ = try requiredOption("id", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.scan.capture",
        capability: "scan_capture",
        appleCapability: "scan_capture",
        delegatedSurface: "continuity_camera_scan_capture"
      )
    case ["attachments", "scan", "crop"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "attachment", "top-left", "top-right", "bottom-right", "bottom-left"]
      )
      try validateMutationIntent(options)
      let operation = "notes.attachments.scan.crop"
      let draft = try attachmentScanCropDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentScanCropScopeDigest(draft),
        summary: attachmentScanCropSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().cropScanAttachment(draft)
        let verification = try verifyAttachmentScanCrop(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentScanCropResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          requestedCropQuadSHA256: write.requestedCropQuadSHA256,
          beforeCroppingQuadSHA256: write.oldInspection.croppingQuadSHA256,
          afterCroppingQuadSHA256: write.inspection.croppingQuadSHA256,
          cropPointCount: 4,
          pageCount: write.inspection.pdfPageCount ?? write.inspection.scannedDocumentsMetadataCount,
          sourceKind: write.sourceKind,
          pdfDataSHA256: write.inspection.pdfDataSHA256,
          scannedDocumentsMetadataSHA256: write.inspection.scannedDocumentsMetadataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes scan attachment crop verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "scan", "rotate"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "by", "direction"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.scan.rotate"
      let draft = try attachmentScanRotateDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentScanRotateScopeDigest(draft),
        summary: attachmentScanRotateSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().rotateScanAttachment(draft)
        let verification = try verifyAttachmentScanRotate(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentScanRotateResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          rotationDeltaDegrees: write.rotationDeltaDegrees,
          beforeOrientation: write.oldInspection.orientation,
          afterOrientation: write.inspection.orientation,
          beforeOrientationSHA256: write.oldInspection.orientationSHA256,
          afterOrientationSHA256: write.inspection.orientationSHA256,
          sourceKind: write.sourceKind,
          pdfDataSHA256: write.inspection.pdfDataSHA256,
          croppingQuadSHA256: write.inspection.croppingQuadSHA256,
          scannedDocumentsMetadataSHA256: write.inspection.scannedDocumentsMetadataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes scan attachment rotation verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "scan", "filter"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "style"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.scan.filter"
      let draft = try attachmentScanFilterDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentScanFilterScopeDigest(draft),
        summary: attachmentScanFilterSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().filterScanAttachment(draft)
        let verification = try verifyAttachmentScanFilter(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentScanFilterResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          style: write.style,
          filterType: write.filterType,
          beforeImageFilterType: write.oldInspection.imageFilterType,
          afterImageFilterType: write.inspection.imageFilterType,
          beforeImageFilterTypeSHA256: write.oldInspection.imageFilterTypeSHA256,
          afterImageFilterTypeSHA256: write.inspection.imageFilterTypeSHA256,
          sourceKind: write.sourceKind,
          pdfDataSHA256: write.inspection.pdfDataSHA256,
          croppingQuadSHA256: write.inspection.croppingQuadSHA256,
          scannedDocumentsMetadataSHA256: write.inspection.scannedDocumentsMetadataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes scan attachment filter verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "scan", "page", "move"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "from", "to"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.scan.page.move"
      let draft = try attachmentScanPageMoveDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentScanPageMoveScopeDigest(draft),
        summary: attachmentScanPageMoveSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().moveScanPage(draft)
        let verification = try verifyAttachmentScanPageMove(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentScanPageMoveResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          fromPage: write.fromPage,
          toPage: write.toPage,
          beforePageCount: write.oldInspection.pdfPageCount ?? write.oldInspection.scannedDocumentsMetadataCount,
          afterPageCount: write.inspection.pdfPageCount ?? write.inspection.scannedDocumentsMetadataCount,
          sourceKind: write.sourceKind,
          beforePDFDataSHA256: write.oldInspection.pdfDataSHA256,
          afterPDFDataSHA256: write.inspection.pdfDataSHA256,
          beforeScannedDocumentsMetadataSHA256: write.oldInspection.scannedDocumentsMetadataSHA256,
          afterScannedDocumentsMetadataSHA256: write.inspection.scannedDocumentsMetadataSHA256,
          croppingQuadSHA256: write.inspection.croppingQuadSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes scan page move verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "scan", "page", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "ordinal"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.scan.page.delete"
      let draft = try attachmentScanPageDeleteDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentScanPageDeleteScopeDigest(draft),
        summary: attachmentScanPageDeleteSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().deleteScanPage(draft)
        let verification = try verifyAttachmentScanPageDelete(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentScanPageDeleteResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          page: write.page,
          beforePageCount: write.oldInspection.pdfPageCount ?? write.oldInspection.scannedDocumentsMetadataCount,
          afterPageCount: write.inspection.pdfPageCount ?? write.inspection.scannedDocumentsMetadataCount,
          sourceKind: write.sourceKind,
          beforePDFDataSHA256: write.oldInspection.pdfDataSHA256,
          afterPDFDataSHA256: write.inspection.pdfDataSHA256,
          beforeScannedDocumentsMetadataSHA256: write.oldInspection.scannedDocumentsMetadataSHA256,
          afterScannedDocumentsMetadataSHA256: write.inspection.scannedDocumentsMetadataSHA256,
          croppingQuadSHA256: write.inspection.croppingQuadSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes scan page delete verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "pdf", "page", "rotate"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "ordinal", "by", "direction"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.pdf.page.rotate"
      let draft = try attachmentPDFPageRotateDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentPDFPageRotateScopeDigest(draft),
        summary: attachmentPDFPageRotateSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().rotatePDFPage(draft)
        let verification = try verifyAttachmentPDFPageRotate(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentPDFPageRotateResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          page: write.page,
          rotationDeltaDegrees: write.rotationDeltaDegrees,
          beforePageRotation: write.beforePageRotation,
          afterPageRotation: write.afterPageRotation,
          beforePageCount: write.oldInspection.pdfPageCount,
          afterPageCount: write.inspection.pdfPageCount,
          sourceKind: write.sourceKind,
          beforePDFDataSHA256: write.oldInspection.pdfDataSHA256,
          afterPDFDataSHA256: write.inspection.pdfDataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes PDF page rotation verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "pdf", "page", "move"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "from", "to"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.pdf.page.move"
      let draft = try attachmentPDFPageMoveDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentPDFPageMoveScopeDigest(draft),
        summary: attachmentPDFPageMoveSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().movePDFPage(draft)
        let verification = try verifyAttachmentPDFPageMove(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentPDFPageMoveResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          fromPage: write.fromPage,
          toPage: write.toPage,
          beforePageCount: write.oldInspection.pdfPageCount,
          afterPageCount: write.inspection.pdfPageCount,
          sourceKind: write.sourceKind,
          beforePDFDataSHA256: write.oldInspection.pdfDataSHA256,
          afterPDFDataSHA256: write.inspection.pdfDataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes PDF page move verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "pdf", "page", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "ordinal"])
      try validateMutationIntent(options)
      let operation = "notes.attachments.pdf.page.delete"
      let draft = try attachmentPDFPageDeleteDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentPDFPageDeleteScopeDigest(draft),
        summary: attachmentPDFPageDeleteSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().deletePDFPage(draft)
        let verification = try verifyAttachmentPDFPageDelete(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentPDFPageDeleteResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          page: write.page,
          beforePageCount: write.oldInspection.pdfPageCount,
          afterPageCount: write.inspection.pdfPageCount,
          sourceKind: write.sourceKind,
          beforePDFDataSHA256: write.oldInspection.pdfDataSHA256,
          afterPDFDataSHA256: write.inspection.pdfDataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes PDF page delete verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "pdf", "crop"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "attachment", "ordinal", "top-left", "top-right", "bottom-right", "bottom-left"]
      )
      try validateMutationIntent(options)
      let operation = "notes.attachments.pdf.crop"
      let draft = try attachmentPDFCropDraft(options, operation: operation)
      return try mutation(
        operation: operation,
        scopeDigest: attachmentPDFCropScopeDigest(draft),
        summary: attachmentPDFCropSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().cropPDF(draft)
        let verification = try verifyAttachmentPDFCrop(
          draft: draft,
          result: write,
          operation: operation
        )
        let result = NotesAttachmentPDFCropResult(
          operation: operation,
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.inspection.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.inspection.attachment.title,
          typeUTI: write.inspection.attachment.typeUTI,
          mediaFilename: write.inspection.attachment.mediaFilename,
          attachmentFamily: attachmentScanPDFInspectionFamily(write.inspection),
          page: write.page,
          requestedCropRectSHA256: write.requestedCropRectSHA256,
          cropPointCount: 4,
          beforePageCount: write.oldInspection.pdfPageCount,
          afterPageCount: write.inspection.pdfPageCount,
          sourceKind: write.sourceKind,
          beforePDFDataSHA256: write.oldInspection.pdfDataSHA256,
          afterPDFDataSHA256: write.inspection.pdfDataSHA256,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes PDF crop verification failed.",
            details: artifactVerificationFailureDetails(operation: operation, verification: verification)
          )
        }
        return result
      }
    case ["attachments", "pdf", "edit"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "file"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw rejectedAttachmentCapabilityError(
        operation: "notes.attachments.pdf.edit",
        capability: "pdf_content_edit",
        appleCapability: "pdf_content_edit",
        productLimit: "pdf_content_edit_not_official_notes_capability"
      )
    case ["attachments", "audio", "record"]:
      try validateTargetOptions(options, allowedOptions: ["id", "name"])
      _ = try requiredOption("id", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.audio.record",
        capability: "audio_recording_generation",
        appleCapability: "audio_record",
        delegatedSurface: "notes_app_audio_recording_ui"
      )
    case ["attachments", "audio", "transcribe"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.audio.transcribe",
        capability: "audio_transcription_generation",
        appleCapability: "audio_transcribe",
        delegatedSurface: "device_transcription_service"
      )
    case ["attachments", "audio", "edit"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "file"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.audio.edit",
        capability: "audio_recording_edit",
        appleCapability: "audio_recording_append",
        delegatedSurface: "notes_app_audio_recording_append_ui"
      )
    case ["attachments", "audio", "edit-transcript"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "file", "content"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw rejectedAttachmentCapabilityError(
        operation: "notes.attachments.audio.edit-transcript",
        capability: "audio_transcript_edit",
        appleCapability: "audio_transcript_edit",
        productLimit: "audio_transcript_edit_not_official_notes_capability"
      )
    case ["attachments", "audio", "transcript"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output", "content"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let contentKind = try attachmentAudioTranscriptContentKind(options)
      let output = options.targetOption("output")
      let destinationPath = output.map(standardizedAbsolutePath(_:))
      if let destinationPath {
        try validateNotesAttachmentAudioTranscriptExportDestination(destinationPath)
        if !options.dryRun {
          try CLISafety.requireFlag(
            "allow-artifact-action",
            in: options,
            category: .artifactAction,
            message: "Notes audio transcript export writes a filesystem artifact and requires `--allow-artifact-action`."
          )
        }
      } else {
        try validateReadOnly(options)
      }
      let source = try attachmentReader().readAttachmentAudioTranscript(noteID: id, attachmentID: attachmentID)
      guard let destinationPath else {
        return try readAttachmentAudioTranscript(
          source,
          requestedAttachmentID: attachmentID,
          options: options
        )
      }
      return try exportAttachmentAudioTranscript(
        source,
        requestedAttachmentID: attachmentID,
        contentKind: contentKind,
        destinationPath: destinationPath,
        options: options
      )
    case ["attachments", "audio", "copy-transcript"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "target", "content", "scope"])
      try validateMutationIntent(options)
      return try copyAttachmentAudioTranscript(options: options)
    case ["attachments", "audio", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "account", "folder", "id", "content"])
      let query = try attachmentAudioTranscriptSearchQuery(options)
      let contentKinds = try attachmentAudioTranscriptSearchContentKinds(options)
      return try searchAttachmentAudioTranscripts(query: query, contentKinds: contentKinds, options: options)
    case ["attachments", "markup", "inspect"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "output"])
      let id = try requiredOption("id", options: options)
      let attachmentID = try requiredOption("attachment", options: options)
      let output = options.targetOption("output")
      let destinationPath = output.map(standardizedAbsolutePath(_:))
      if let destinationPath {
        try validateNotesAttachmentMarkupExportDestination(destinationPath)
        if !options.dryRun {
          try CLISafety.requireFlag(
            "allow-artifact-action",
            in: options,
            category: .artifactAction,
            message: "Notes attachment Markup model export writes a filesystem artifact and requires `--allow-artifact-action`."
          )
        }
      } else {
        try validateReadOnly(options)
      }
      let source = try attachmentReader().inspectAttachmentMarkup(noteID: id, attachmentID: attachmentID)
      return try inspectAttachmentMarkup(
        source,
        requestedAttachmentID: attachmentID,
        destinationPath: destinationPath,
        options: options
      )
    case ["attachments", "markup", "add-shape"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "shape"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("shape", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.add-shape",
        capability: "semantic_markup_element_creation",
        appleCapability: "markup_shape",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "add-text"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "text"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("text", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.add-text",
        capability: "semantic_markup_element_creation",
        appleCapability: "markup_text_box",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "add-signature"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "signature"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("signature", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.add-signature",
        capability: "semantic_markup_element_creation",
        appleCapability: "markup_signature",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "highlight"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "page", "selection"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.highlight",
        capability: "semantic_markup_element_creation",
        appleCapability: "markup_highlight_selection",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "sketch"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "file"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.sketch",
        capability: "semantic_markup_element_creation",
        appleCapability: "markup_sketch",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "draw"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "file"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.draw",
        capability: "semantic_markup_element_creation",
        appleCapability: "markup_draw",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "shape-style"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "style"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("style", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.shape-style",
        capability: "semantic_markup_style_and_color",
        appleCapability: "markup_shape_style",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "border-color"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "color"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("color", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.border-color",
        capability: "semantic_markup_style_and_color",
        appleCapability: "markup_border_color",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "fill-color"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "color"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("color", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.fill-color",
        capability: "semantic_markup_style_and_color",
        appleCapability: "markup_fill_color",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "text-style"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "style", "color"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      _ = try requiredOption("style", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.text-style",
        capability: "semantic_markup_text_style",
        appleCapability: "markup_text_style",
        delegatedSurface: "notes_app_markup_tool_palette"
      )
    case ["attachments", "markup", "annotate"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "device"])
      _ = try requiredOption("id", options: options)
      _ = try requiredOption("attachment", options: options)
      throw delegatedAttachmentCapabilityError(
        operation: "notes.attachments.markup.annotate",
        capability: "continuity_markup_annotate",
        appleCapability: "markup_annotate_nearby_device",
        delegatedSurface: "continuity_markup_nearby_device_ui"
      )
    case ["attachments", "markup", "edit"]:
      try validateTargetOptions(options, allowedOptions: ["id", "attachment", "file"])
      try validateMutationIntent(options)
      let draft = try attachmentMarkupEditDraft(options)
      return try mutation(
        operation: "notes.attachments.markup.edit",
        scopeDigest: attachmentMarkupEditScopeDigest(draft),
        summary: attachmentMarkupEditSummary(draft),
        options: options
      ) {
        let write = try attachmentMutator().applyAttachmentMarkup(draft)
        let verification = try verifyAttachmentMarkupEdit(
          draft: draft,
          result: write,
          operation: "notes.attachments.markup.edit"
        )
        let markupHash = sha256Hex(draft.data)
        let result = NotesAttachmentMarkupEditResult(
          operation: "notes.attachments.markup.edit",
          changed: write.changed,
          noteID: write.noteID,
          attachmentID: write.attachment.id,
          requestedAttachmentID: draft.attachmentID,
          title: write.attachment.title,
          typeUTI: write.attachment.typeUTI,
          mediaFilename: write.attachment.mediaFilename,
          attachmentFamily: attachmentAuditFamily(write.attachment),
          markupModelByteCount: draft.data.count,
          markupModelSHA256: markupHash,
          sourcePath: draft.sourcePath,
          sourceKind: "ICMarkupUtilities.applyMarkupModelData",
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes attachment Markup edit verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.attachments.markup.edit",
              verification: verification
            )
          )
        }
        return result
      }    default:
      return nil
    }
  }

  struct NotesAttachmentListFamilyFilter: Sendable {
    var canonicalName: String
    var includedFamilies: Set<String>
  }

  private func attachmentAuditRecords(_ options: CLIOptions) throws -> [NotesAttachmentAuditRecord] {
    let notes = try listVisibleNotes(options, limit: try commandLimit(options))
    let reader = try attachmentReader()
    return try notes.map { note in
      let attachments = try reader.listAttachments(noteID: note.id, limit: 2_000)
      return attachmentAuditRecord(noteID: note.id, attachments: attachments)
    }
  }

  private func attachmentListCollectionRecords(
    _ options: CLIOptions,
    familyFilter: NotesAttachmentListFamilyFilter?
  ) throws -> (records: [NotesAttachmentCollectionNoteRecord], scannedNoteCount: Int) {
    let notes = try listVisibleNotes(options, limit: try commandLimit(options))
    let reader = try attachmentReader()
    let records = try notes.compactMap { note -> NotesAttachmentCollectionNoteRecord? in
      let attachments = attachmentListFilteredAttachments(
        try reader.listAttachments(noteID: note.id, limit: 2_000)
          .filter { $0.isDeletedOrInTrash != true },
        familyFilter: familyFilter
      )
      guard !attachments.isEmpty else {
        return nil
      }
      return NotesAttachmentCollectionNoteRecord(
        note: note,
        noteIDSHA256: sha256Hex(note.id),
        attachments: attachments
      )
    }
    return (records, notes.count)
  }

  func attachmentListFamilyFilter(_ options: CLIOptions) throws -> NotesAttachmentListFamilyFilter? {
    guard let raw = options.targetOption("family")?.trimmingCharacters(in: .whitespacesAndNewlines),
      !raw.isEmpty
    else {
      return nil
    }
    let normalized = raw
      .lowercased()
      .replacingOccurrences(of: "_", with: "-")
      .replacingOccurrences(of: " ", with: "-")
    let stripped = normalized.hasPrefix("attachment-")
      ? String(normalized.dropFirst("attachment-".count))
      : normalized
    let filter: NotesAttachmentListFamilyFilter?
    switch stripped {
    case "photo-video", "photos-video", "photo-videos", "photos-videos", "photo-and-video",
      "photos-and-videos":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "photo-video",
        includedFamilies: ["photo_image", "video"]
      )
    case "photo", "photos", "image", "images", "photo-image", "photos-images":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "photo-image",
        includedFamilies: ["photo_image"]
      )
    case "video", "videos":
      filter = NotesAttachmentListFamilyFilter(canonicalName: "video", includedFamilies: ["video"])
    case "scan", "scans", "scanned-document", "scanned-documents":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "scanned-document",
        includedFamilies: ["scanned_document"]
      )
    case "map", "maps", "map-preview", "map-previews":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "map-preview",
        includedFamilies: ["map_preview"]
      )
    case "website", "websites", "webpage", "webpages", "webpage-preview", "webpage-previews":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "webpage-preview",
        includedFamilies: ["webpage_preview"]
      )
    case "pdf", "pdfs":
      filter = NotesAttachmentListFamilyFilter(canonicalName: "pdf", includedFamilies: ["pdf"])
    case "audio", "audios", "audio-recording", "audio-recordings":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "audio-recording",
        includedFamilies: ["audio_recording"]
      )
    case "drawing", "drawings", "sketch", "sketches", "drawing-sketch", "drawing-or-sketch",
      "drawings-sketches":
      filter = NotesAttachmentListFamilyFilter(
        canonicalName: "drawing-or-sketch",
        includedFamilies: ["drawing_or_sketch"]
      )
    case "file", "files", "document", "documents":
      filter = NotesAttachmentListFamilyFilter(canonicalName: "file", includedFamilies: ["file"])
    case "unknown":
      filter = NotesAttachmentListFamilyFilter(canonicalName: "unknown", includedFamilies: ["unknown"])
    default:
      filter = nil
    }
    guard let filter else {
      throw CLIError(
        code: .validationError,
        message: "Unsupported attachment family for `attachments list`.",
        details: [
          "family_sha256": sha256Hex(raw),
          "supported_families":
            "photo-video,photo-image,video,scanned-document,map-preview,webpage-preview,pdf,audio-recording,drawing-or-sketch,file,unknown",
        ]
      )
    }
    return filter
  }

  func attachmentListFilteredAttachments(
    _ attachments: [NotesAttachmentRecord],
    familyFilter: NotesAttachmentListFamilyFilter?
  ) -> [NotesAttachmentRecord] {
    guard let familyFilter else {
      return attachments
    }
    return attachments.filter { attachment in
      familyFilter.includedFamilies.contains(attachmentAuditFamily(attachment))
    }
  }

  private func attachmentListFamilyCounts(
    _ records: [NotesAttachmentCollectionNoteRecord]
  ) -> [NotesAttachmentAuditCount] {
    attachmentAuditCounts(records.flatMap { record in
      record.attachments.map(attachmentAuditFamily)
    })
  }

  private func verifyAttachmentListCollection(
    records: [NotesAttachmentCollectionNoteRecord],
    scannedNoteCount: Int,
    familyFilter: NotesAttachmentListFamilyFilter?,
    familyCounts: [NotesAttachmentAuditCount]
  ) -> NotesMutationVerificationReport {
    let attachmentCount = records.reduce(0) { $0 + $1.attachmentCount }
    let notesWithAttachmentsCount = records.filter { !$0.attachments.isEmpty }.count
    let familyCountTotal = familyCounts.reduce(0) { $0 + $1.count }
    let checks = [
      verificationBoolCheck(
        name: "scanned_note_count_bounded",
        expected: true,
        actual: scannedNoteCount >= records.count && scannedNoteCount <= 500
      ),
      verificationBoolCheck(
        name: "notes_with_attachments_count_matches",
        expected: true,
        actual: notesWithAttachmentsCount == records.count
      ),
      verificationBoolCheck(
        name: "attachment_count_matches",
        expected: true,
        actual: attachmentCount == records.reduce(0) { $0 + $1.attachments.count }
      ),
      verificationBoolCheck(
        name: "visible_attachment_records_only",
        expected: true,
        actual: records.flatMap(\.attachments).allSatisfy { $0.isDeletedOrInTrash != true }
      ),
      verificationBoolCheck(
        name: "family_counts_accounted",
        expected: true,
        actual: familyCountTotal == attachmentCount
      ),
      verificationBoolCheck(
        name: "family_filter_applied",
        expected: true,
        actual: familyFilter.map { filter in
          records.flatMap(\.attachments).allSatisfy {
            filter.includedFamilies.contains(attachmentAuditFamily($0))
          }
        } ?? true
      ),
      verificationBoolCheck(
        name: "metadata_only_batch_read",
        expected: true,
        actual: true
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.attachments.list.collection",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_attachment_metadata_batch_readback",
      targetIDSHA256: sha256Hex(records.map(\.noteIDSHA256).joined(separator: "\n")),
      checks: checks
    )
  }

  private func attachmentAuditRecord(
    noteID: String,
    attachments: [NotesAttachmentRecord]
  ) -> NotesAttachmentAuditRecord {
    let visible = attachments.filter { $0.isDeletedOrInTrash != true }
    let familyCounts = attachmentAuditCounts(visible.map(attachmentAuditFamily))
    let filenameExtensionCounts = attachmentAuditCounts(
      visible.compactMap(attachmentAuditFilenameExtension)
    )
    let attachmentTypeCounts = attachmentAuditCounts(
      visible.compactMap { $0.attachmentType.map(String.init) }
    )
    return NotesAttachmentAuditRecord(
      noteIDSHA256: sha256Hex(noteID),
      attachmentCount: attachments.count,
      visibleAttachmentCount: visible.count,
      deletedOrTrashAttachmentCount: attachments.count - visible.count,
      inlineAttachmentCount: visible.filter { $0.isInline }.count,
      mediaBackedAttachmentCount: visible.filter(attachmentAuditHasMediaEvidence).count,
      knownByteCountAttachmentCount: visible.filter { $0.fileSizeBytes != nil }.count,
      totalKnownByteCount: visible.reduce(Int64(0)) { $0 + max(0, $1.fileSizeBytes ?? 0) },
      rawUTIHashCount: visible.filter { $0.typeUTI?.isEmpty == false }.count,
      pdfOrScanMarkupCandidateCount: visible.filter(attachmentAuditIsPDFOrScanMarkupCandidate).count,
      familyCounts: familyCounts,
      filenameExtensionCounts: filenameExtensionCounts,
      attachmentTypeCounts: attachmentTypeCounts
    )
  }

  private func attachmentAuditSummary(_ records: [NotesAttachmentAuditRecord]) -> NotesAttachmentAuditSummary {
    let familyCounts = attachmentAuditMergedCounts(records.flatMap(\.familyCounts))
    let filenameExtensionCounts = attachmentAuditMergedCounts(records.flatMap(\.filenameExtensionCounts))
    let attachmentTypeCounts = attachmentAuditMergedCounts(records.flatMap(\.attachmentTypeCounts))
    return NotesAttachmentAuditSummary(
      noteCount: records.count,
      notesWithAttachmentsCount: records.filter { $0.attachmentCount > 0 }.count,
      attachmentCount: records.reduce(0) { $0 + $1.attachmentCount },
      visibleAttachmentCount: records.reduce(0) { $0 + $1.visibleAttachmentCount },
      deletedOrTrashAttachmentCount: records.reduce(0) { $0 + $1.deletedOrTrashAttachmentCount },
      inlineAttachmentCount: records.reduce(0) { $0 + $1.inlineAttachmentCount },
      mediaBackedAttachmentCount: records.reduce(0) { $0 + $1.mediaBackedAttachmentCount },
      knownByteCountAttachmentCount: records.reduce(0) { $0 + $1.knownByteCountAttachmentCount },
      totalKnownByteCount: records.reduce(Int64(0)) { $0 + $1.totalKnownByteCount },
      rawUTIHashCount: records.reduce(0) { $0 + $1.rawUTIHashCount },
      pdfOrScanMarkupCandidateCount: records.reduce(0) { $0 + $1.pdfOrScanMarkupCandidateCount },
      familyCounts: familyCounts,
      filenameExtensionCounts: filenameExtensionCounts,
      attachmentTypeCounts: attachmentTypeCounts,
      supportedReadFamilies: [
        "audio_recording_metadata",
        "drawing_sketch_metadata",
        "file_attachment_metadata",
        "image_photo_metadata",
        "pdf_metadata",
        "scan_metadata",
        "video_metadata",
        "map_preview_metadata",
        "webpage_preview_metadata",
        "image_object_understanding",
      ],
      delegatedWorkflowFamilies: [
        "audio_recording_generation",
        "audio_recording_edit",
        "audio_transcription_generation",
        "scan_capture",
      ],
      gatedMutationFamilies: [
        "attachment_transform_update",
        "semantic_markup_element_edit",
      ]
    )
  }

  private func verifyAttachmentAudit(
    records: [NotesAttachmentAuditRecord],
    summary: NotesAttachmentAuditSummary
  ) -> NotesMutationVerificationReport {
    let familyTotal = summary.familyCounts.reduce(0) { $0 + $1.count }
    let extensionTotal = summary.filenameExtensionCounts.reduce(0) { $0 + $1.count }
    let typeTotal = summary.attachmentTypeCounts.reduce(0) { $0 + $1.count }
    let expectedDelegatedFamilies = [
      "audio_recording_generation",
      "audio_recording_edit",
      "audio_transcription_generation",
      "scan_capture",
    ]
    let expectedGatedFamilies = [
      "attachment_transform_update",
      "semantic_markup_element_edit",
    ]
    var checks = [
      verificationBoolCheck(
        name: "audit_record_count_matches",
        expected: true,
        actual: summary.noteCount == records.count
      ),
      verificationBoolCheck(
        name: "attachment_count_matches",
        expected: true,
        actual: summary.attachmentCount == records.reduce(0) { $0 + $1.attachmentCount }
      ),
      verificationBoolCheck(
        name: "visible_attachment_count_matches",
        expected: true,
        actual: summary.visibleAttachmentCount == records.reduce(0) { $0 + $1.visibleAttachmentCount }
      ),
      verificationBoolCheck(
        name: "family_counts_accounted",
        expected: true,
        actual: familyTotal == summary.visibleAttachmentCount
      ),
      verificationBoolCheck(
        name: "filename_extensions_bounded",
        expected: true,
        actual: extensionTotal <= summary.visibleAttachmentCount
      ),
      verificationBoolCheck(
        name: "attachment_type_counts_bounded",
        expected: true,
        actual: typeTotal <= summary.visibleAttachmentCount
      ),
      verificationBoolCheck(
        name: "raw_uti_values_hidden",
        expected: true,
        actual: summary.rawUTIHashCount <= summary.visibleAttachmentCount
      ),
      verificationBoolCheck(
        name: "privacy_surface_limited_to_attachment_accounting",
        expected: true,
        actual: true
      ),
    ]
    for family in expectedDelegatedFamilies {
      checks.append(
        verificationBoolCheck(
          name: "\(family)_delegated",
          expected: true,
          actual: summary.delegatedWorkflowFamilies.contains(family)
        )
      )
    }
    for family in expectedGatedFamilies {
      checks.append(
        verificationBoolCheck(
          name: "\(family)_gated",
          expected: true,
          actual: summary.gatedMutationFamilies.contains(family)
        )
      )
    }
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.attachments.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_attachment_metadata_batch_readback",
      targetIDSHA256: sha256Hex(records.map(\.noteIDSHA256).joined(separator: "\n")),
      checks: checks
    )
  }

  func attachmentAuditFamily(_ attachment: NotesAttachmentRecord) -> String {
    let uti = attachment.typeUTI?.lowercased() ?? ""
    let title = attachment.title?.lowercased() ?? ""
    let filename = attachment.mediaFilename?.lowercased() ?? ""
    let ext = attachmentAuditFilenameExtension(attachment) ?? ""
    let hints = "\(uti) \(title) \(filename) \(ext)"

    if attachmentAuditHintMatches(hints, anyOf: ["scan", "scanned"]) {
      return "scanned_document"
    }
    if attachmentAuditHintMatches(hints, anyOf: ["audio", "sound", "recording", "m4a", "mp3", "wav", "aiff", "caf"]) {
      return "audio_recording"
    }
    if uti.contains("pdf") || ext == "pdf" {
      return "pdf"
    }
    if attachmentAuditHintMatches(hints, anyOf: ["drawing", "sketch"]) {
      return "drawing_or_sketch"
    }
    if uti.contains("movie") || uti.contains("video") || ["mov", "mp4", "m4v"].contains(ext) {
      return "video"
    }
    if uti.contains("image") || ["heic", "jpeg", "jpg", "png", "gif", "tiff", "webp"].contains(ext) {
      return "photo_image"
    }
    if attachment.isInline && attachmentAuditHintMatches(hints, anyOf: ["map", "maps"]) {
      return "map_preview"
    }
    if attachment.isInline
      && attachmentAuditHintMatches(hints, anyOf: ["url", "web", "website", "html", "safari", "webloc"])
    {
      return "webpage_preview"
    }
    if !uti.isEmpty || !ext.isEmpty || attachment.fileSizeBytes != nil || attachment.mediaFilename != nil {
      return "file"
    }
    return "unknown"
  }

  private func attachmentAuditIsPDFOrScanMarkupCandidate(_ attachment: NotesAttachmentRecord) -> Bool {
    let family = attachmentAuditFamily(attachment)
    return family == "pdf" || family == "scanned_document"
  }

  func attachmentAuditSupportsMarkupModelApply(_ attachment: NotesAttachmentRecord) -> Bool {
    let family = attachmentAuditFamily(attachment)
    return family == "pdf" || family == "scanned_document" || family == "photo_image"
  }

  private func attachmentAuditHasMediaEvidence(_ attachment: NotesAttachmentRecord) -> Bool {
    attachment.mediaFilename?.isEmpty == false || attachment.fileSizeBytes != nil
  }

  private func attachmentAuditFilenameExtension(_ attachment: NotesAttachmentRecord) -> String? {
    let candidate = attachment.mediaFilename ?? attachment.title
    guard let candidate, !candidate.isEmpty else {
      return nil
    }
    let ext = (candidate as NSString).pathExtension.lowercased()
    guard !ext.isEmpty, ext.count <= 12 else {
      return nil
    }
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789")
    guard ext.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
      return nil
    }
    return ext
  }

  private func attachmentAuditHintMatches(_ value: String, anyOf needles: [String]) -> Bool {
    needles.contains { value.contains($0) }
  }

  private func attachmentAuditCounts(_ values: [String]) -> [NotesAttachmentAuditCount] {
    var counts: [String: Int] = [:]
    for value in values where !value.isEmpty {
      counts[value, default: 0] += 1
    }
    return counts
      .map { NotesAttachmentAuditCount(name: $0.key, count: $0.value) }
      .sorted {
        if $0.count != $1.count {
          return $0.count > $1.count
        }
        return $0.name < $1.name
      }
  }

  private func attachmentAuditMergedCounts(
    _ counts: [NotesAttachmentAuditCount]
  ) -> [NotesAttachmentAuditCount] {
    var merged: [String: Int] = [:]
    for count in counts {
      merged[count.name, default: 0] += count.count
    }
    return attachmentAuditCounts(merged.flatMap { name, count in Array(repeating: name, count: count) })
  }

  private func attachmentAddDraft(_ options: CLIOptions) throws -> NotesAttachmentAddBatchDraft {
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
        operation: "notes.attachments.add"
      )
    }

    let singleFilePath = options.targetOption("file")
    let fileList = try options.targetOption("files").map(notesAttachmentAddFileList)
    if singleFilePath != nil && fileList != nil {
      throw CLIError(
        code: .validationError,
        message: "`attachments add` accepts either `--file` or `--files`, not both."
      )
    }
    guard let paths = fileList ?? singleFilePath.map({ [$0] }) else {
      throw CLIError(
        code: .validationError,
        message: "`attachments add` requires either `--file` or `--files`."
      )
    }

    let sources = try notesAttachmentAddFileSources(
      paths: paths,
      name: options.targetOption("name")
    )
    return NotesAttachmentAddBatchDraft(
      noteID: note.id,
      attachments: sources.map { source in
        NotesAttachmentAddDraft(
          noteID: note.id,
          filename: source.filename,
          sourcePath: source.path,
          data: source.data
        )
      }
    )
  }

  private func singleAttachmentAddDraft(_ draft: NotesAttachmentAddBatchDraft) throws -> NotesAttachmentAddDraft {
    guard let attachment = draft.attachments.first, draft.attachments.count == 1 else {
      throw CLIError(
        code: .internalError,
        message: "Expected one attachment add draft.",
        details: ["attachment_count": "\(draft.attachments.count)"]
      )
    }
    return attachment
  }

  private func attachmentCopyDraft(_ options: CLIOptions) throws -> NotesAttachmentCopyDraft {
    let sourceNoteID = try requiredOption("id", options: options)
    let targetNoteID = try requiredOption("target", options: options)
    guard let sourceNote = try implementation.readNote(id: sourceNoteID) else {
      throw CLIError(
        code: .notFound,
        message: "Source note was not found.",
        details: ["id_sha256": sha256Hex(sourceNoteID)]
      )
    }
    guard let targetNote = try implementation.readNote(id: targetNoteID) else {
      throw CLIError(
        code: .notFound,
        message: "Target note was not found.",
        details: ["target_sha256": sha256Hex(targetNoteID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateAttachmentMutationState(
        try stateReader.readNoteState(noteID: targetNote.id),
        operation: "notes.attachments.copy"
      )
    }
    let requestedAttachmentID = try requiredOption("attachment", options: options)
    let source = try attachmentReader().exportAttachment(
      noteID: sourceNote.id,
      attachmentID: requestedAttachmentID
    )
    let filename = try normalizedNotesAttachmentFilename(
      options.targetOption("name")
        ?? source.attachment.mediaFilename
        ?? source.attachment.title
        ?? "attachment"
    )
    return NotesAttachmentCopyDraft(
      sourceNoteID: source.noteID,
      requestedAttachmentID: requestedAttachmentID,
      targetNoteID: targetNote.id,
      filename: filename,
      data: source.data,
      sourceAttachment: source.attachment
    )
  }

  private func webpageAttachmentAddDraft(_ options: CLIOptions) throws -> NotesLinkAddDraft {
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
        operation: "notes.attachments.add-webpage"
      )
    }

    let url = try normalizedWebURL(try requiredOption("url", options: options))
    return NotesLinkAddDraft(noteID: note.id, url: url, urlString: url.absoluteString)
  }

  private func webpageAttachmentUpdateDraft(_ options: CLIOptions) throws -> NotesLinkUpdateDraft {
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
        operation: "notes.attachments.update-webpage"
      )
    }

    let requestedAttachment = try requiredOption("attachment", options: options)
    let attachmentMatches = try attachmentReader().listAttachments(noteID: note.id, limit: 2_000)
      .filter { attachmentRecordMatches($0, selector: requestedAttachment) }
    guard let attachment = attachmentMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Attachment selector did not match any attachment on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
        ]
      )
    }
    guard attachmentMatches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Attachment selector matched multiple attachments on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
          "match_count": "\(attachmentMatches.count)",
        ]
      )
    }
    let attachmentFamily = attachmentAuditFamily(attachment)
    guard attachmentAuditIsWebpageOrMapPreview(attachment) else {
      throw CLIError(
        code: .validationError,
        message: "Notes webpage attachment update requires a webpage preview or map attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
          "attachment_family": attachmentFamily,
        ]
      )
    }

    let linkMatches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { webpageAttachmentRecordMatches(attachment, link: $0) }
    guard let link = linkMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Webpage attachment link metadata was not found on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
        ]
      )
    }
    guard linkMatches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Webpage attachment selector matched multiple link records on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
          "match_count": "\(linkMatches.count)",
        ]
      )
    }
    try validateWebURLLinkUpdateTarget(link, noteID: note.id, requestedLinkID: requestedAttachment)

    let url = try normalizedWebURL(try requiredOption("url", options: options))
    let normalizedCurrent = normalizedLinkURLForMatching(link.urlString)
    let normalizedTarget = normalizedLinkURLForMatching(url.absoluteString)
    guard normalizedCurrent != normalizedTarget else {
      throw CLIError(
        code: .validationError,
        message: "Notes webpage attachment update requires a changed http or https URL.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(requestedAttachment),
          "url_sha256": sha256Hex(url.absoluteString),
        ]
      )
    }

    return NotesLinkUpdateDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedAttachment,
      link: link,
      url: url,
      urlString: url.absoluteString
    )
  }

  private func attachmentRenameDraft(
    _ options: CLIOptions,
    operation: String,
    requiredFamily: String? = nil
  ) throws -> NotesAttachmentRenameDraft {
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
        message: "Notes attachment rename target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachment.id),
        ]
      )
    }
    try validateAttachmentFamily(attachment, expectedFamily: requiredFamily, operation: operation)

    let name = try validatedAttachmentName(try requiredOption("name", options: options))
    let currentDisplayName = attachment.title ?? attachment.mediaFilename
    guard currentDisplayName != name else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment rename requires a changed name.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachment.id),
          "name_sha256": sha256Hex(name),
        ]
      )
    }

    return NotesAttachmentRenameDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: attachment,
      name: name
    )
  }

  private func attachmentRemoveDraft(
    _ options: CLIOptions,
    operation: String,
    requiredFamily: String? = nil
  ) throws -> NotesAttachmentRemoveDraft {
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
        message: "Notes attachment remove target must be a visible attachment.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "attachment_sha256": sha256Hex(attachment.id),
        ]
      )
    }
    try validateAttachmentFamily(attachment, expectedFamily: requiredFamily, operation: operation)
    return NotesAttachmentRemoveDraft(
      noteID: note.id,
      attachmentID: requestedAttachment,
      attachment: attachment
    )
  }

  private func validateAttachmentFamily(
    _ attachment: NotesAttachmentRecord,
    expectedFamily: String?,
    operation: String
  ) throws {
    guard let expectedFamily else { return }
    let actualFamily = attachmentAuditFamily(attachment)
    guard actualFamily == expectedFamily else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment command requires an attachment in the expected media family.",
        details: [
          "operation": operation,
          "expected_family": expectedFamily,
          "actual_family": actualFamily,
          "attachment_sha256": sha256Hex(attachment.id),
        ]
      )
    }
  }

  private func validatedAttachmentName(_ value: String) throws -> String {
    let name = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment name must not be empty.",
        details: ["field": "name"]
      )
    }
    guard name.count <= 255 else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment name must be 255 characters or fewer.",
        details: ["field": "name", "max_length": "255"]
      )
    }
    let disallowed = CharacterSet(charactersIn: "/\0").union(.newlines)
    guard name.rangeOfCharacter(from: disallowed) == nil else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment name must not contain path separators, NUL, or newlines.",
        details: ["field": "name"]
      )
    }
    return name
  }

  func validateAttachmentMutationState(_ state: NotesNoteStateRecord, operation: String) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes attachment mutation target must be a visible non-trash note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isPasswordProtected == false, state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes attachment mutation remains gated.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isSharedReadOnly == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes attachment mutation target must be editable.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
  }

  private func attachmentAddSummary(_ draft: NotesAttachmentAddDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "source_path": draft.sourcePath,
      "filename": draft.filename,
      "byte_count": "\(draft.data.count)",
      "sha256": sha256Hex(draft.data),
    ]
  }

  private func attachmentAddScopeDigest(_ draft: NotesAttachmentAddDraft) -> String {
    let fields = [
      draft.noteID,
      draft.sourcePath,
      draft.filename,
      "\(draft.data.count)",
      sha256Hex(draft.data),
    ].joined(separator: "|")
    return "notes-attachment-add:\(sha256Hex(fields))"
  }

  private func attachmentAddBatchSummary(_ draft: NotesAttachmentAddBatchDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "source_count": "\(draft.attachments.count)",
      "filenames": draft.attachments.map(\.filename).joined(separator: ","),
      "total_byte_count": "\(attachmentAddTotalByteCount(draft.attachments))",
      "aggregate_sha256": attachmentAddAggregateSHA256(draft.attachments),
      "source_paths_sha256": sha256Hex(draft.attachments.map(\.sourcePath).joined(separator: "|")),
    ]
  }

  private func attachmentAddBatchScopeDigest(_ draft: NotesAttachmentAddBatchDraft) -> String {
    let fields = [
      draft.noteID,
      "\(draft.attachments.count)",
      "\(attachmentAddTotalByteCount(draft.attachments))",
      attachmentAddAggregateSHA256(draft.attachments),
      draft.attachments.map(\.sourcePath).joined(separator: "|"),
    ].joined(separator: "|")
    return "notes-attachment-add-batch:\(sha256Hex(fields))"
  }

  private func attachmentCopySummary(_ draft: NotesAttachmentCopyDraft) -> [String: String] {
    [
      "source_note_id_sha256": sha256Hex(draft.sourceNoteID),
      "source_attachment_id_sha256": sha256Hex(draft.sourceAttachment.id),
      "requested_attachment_sha256": sha256Hex(draft.requestedAttachmentID),
      "target_note_id": draft.targetNoteID,
      "target_note_id_sha256": sha256Hex(draft.targetNoteID),
      "filename_sha256": sha256Hex(draft.filename),
      "byte_count": "\(draft.data.count)",
      "sha256": sha256Hex(draft.data),
    ]
  }

  private func attachmentCopyScopeDigest(_ draft: NotesAttachmentCopyDraft) -> String {
    let fields = [
      draft.sourceNoteID,
      draft.requestedAttachmentID,
      draft.sourceAttachment.id,
      draft.targetNoteID,
      draft.filename,
      "\(draft.data.count)",
      sha256Hex(draft.data),
    ].joined(separator: "|")
    return "notes-attachment-copy:\(sha256Hex(fields))"
  }

  private func attachmentAddTotalByteCount(_ drafts: [NotesAttachmentAddDraft]) -> Int {
    drafts.reduce(0) { $0 + $1.data.count }
  }

  private func attachmentAddAggregateSHA256(_ drafts: [NotesAttachmentAddDraft]) -> String {
    let fields = drafts.map { draft in
      [
        draft.filename,
        "\(draft.data.count)",
        sha256Hex(draft.data),
      ].joined(separator: ":")
    }.joined(separator: "|")
    return sha256Hex(fields)
  }

  private func webpageAttachmentAddSummary(_ draft: NotesLinkAddDraft) -> [String: String] {
    let components = URLComponents(url: draft.url, resolvingAgainstBaseURL: false)
    return [
      "id": draft.noteID,
      "url": draft.urlString,
      "url_sha256": sha256Hex(draft.urlString),
      "scheme": components?.scheme ?? "",
      "host": components?.host ?? "",
      "attachment_family": webpagePreviewFamily(urlString: draft.urlString),
    ]
  }

  private func webpageAttachmentAddScopeDigest(_ draft: NotesLinkAddDraft) -> String {
    let fields = [
      draft.noteID,
      draft.urlString,
      sha256Hex(draft.urlString),
      webpagePreviewFamily(urlString: draft.urlString),
    ].joined(separator: "|")
    return "notes-webpage-attachment-add:\(sha256Hex(fields))"
  }

  private func webpageAttachmentUpdateSummary(_ draft: NotesLinkUpdateDraft) -> [String: String] {
    let components = URLComponents(url: draft.url, resolvingAgainstBaseURL: false)
    return [
      "id": draft.noteID,
      "attachment": draft.link.id,
      "requested_attachment": draft.requestedLinkID,
      "requested_attachment_sha256": sha256Hex(draft.requestedLinkID),
      "link": draft.link.id,
      "old_url_sha256": draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256 ?? "",
      "old_scheme": draft.link.urlScheme ?? "",
      "url": draft.urlString,
      "url_sha256": sha256Hex(draft.urlString),
      "scheme": components?.scheme ?? "",
      "host": components?.host ?? "",
      "attachment_family": webpagePreviewFamily(urlString: draft.urlString),
    ]
  }

  private func webpageAttachmentUpdateScopeDigest(_ draft: NotesLinkUpdateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      sha256Hex(draft.requestedLinkID),
      draft.link.urlString ?? "",
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      draft.urlString,
      sha256Hex(draft.urlString),
      webpagePreviewFamily(urlString: draft.urlString),
    ].joined(separator: "|")
    return "notes-webpage-attachment-update:\(sha256Hex(fields))"
  }

  private func attachmentRenameSummary(_ draft: NotesAttachmentRenameDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "old_name": draft.attachment.title ?? draft.attachment.mediaFilename ?? "",
      "old_name_sha256": (draft.attachment.title ?? draft.attachment.mediaFilename).map(sha256Hex) ?? "",
      "name": draft.name,
      "name_sha256": sha256Hex(draft.name),
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  private func attachmentRenameScopeDigest(_ draft: NotesAttachmentRenameDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
      draft.name,
      sha256Hex(draft.name),
    ].joined(separator: "|")
    return "notes-attachment-rename:\(sha256Hex(fields))"
  }

  private func attachmentRemoveSummary(_ draft: NotesAttachmentRemoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "attachment": draft.attachment.id,
      "requested_attachment": draft.attachmentID,
      "title": draft.attachment.title ?? "",
      "type_uti": draft.attachment.typeUTI ?? "",
      "media_filename": draft.attachment.mediaFilename ?? "",
    ]
  }

  private func attachmentRemoveScopeDigest(_ draft: NotesAttachmentRemoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.attachment.id,
      draft.attachmentID,
      draft.attachment.contentIdentifier ?? "",
      draft.attachment.mediaFilename ?? "",
      draft.attachment.title ?? "",
    ].joined(separator: "|")
    return "notes-attachment-remove:\(sha256Hex(fields))"
  }

  func verifyAttachmentAdd(
    draft: NotesAttachmentAddDraft,
    result: NotesAttachmentAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let metadataPresent = attachmentReadback.contains { attachmentRecordMatches($0, result.attachment) }
    let filenamePreserved =
      result.attachment.mediaFilename == draft.filename || result.attachment.title == draft.filename
    let exported = try? attachmentReader().exportAttachment(
      noteID: result.noteID,
      attachmentID: result.attachment.id
    )
    let exportedData = exported?.data ?? Data()
    let expectedSHA256 = sha256Hex(draft.data)
    let actualSHA256 = sha256Hex(exportedData)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "filename",
        status: filenamePreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: filenamePreserved
      ),
      NotesVerificationCheckRecord(
        name: "attachment_export_readback",
        status: exported != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: exported != nil
      ),
      NotesVerificationCheckRecord(
        name: "byte_count",
        status: exportedData.count == draft.data.count ? "passed" : "failed",
        expectedLength: draft.data.count,
        actualLength: exportedData.count
      ),
      NotesVerificationCheckRecord(
        name: "sha256",
        status: actualSHA256 == expectedSHA256 ? "passed" : "failed",
        expectedSHA256: expectedSHA256,
        actualSHA256: actualSHA256
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
      evidenceLevel: "private_framework_attachment_write+attachment_export_hash+note_readback",
      targetIDSHA256: sha256Hex(result.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentCopy(
    draft: NotesAttachmentCopyDraft,
    result: NotesAttachmentAddWriteResult,
    addVerification: NotesMutationVerificationReport
  ) throws -> NotesMutationVerificationReport {
    let targetReadback = try implementation.readNote(id: result.noteID) != nil
    let selectedAttachmentMatches =
      draft.sourceAttachment.id == draft.requestedAttachmentID
        || draft.sourceAttachment.contentIdentifier == draft.requestedAttachmentID
        || draft.sourceAttachment.mediaFilename == draft.requestedAttachmentID
        || draft.sourceAttachment.title == draft.requestedAttachmentID
    var checks = addVerification.checks
    checks.append(
      NotesVerificationCheckRecord(
        name: "attachment_add_verification",
        status: addVerification.verified ? "passed" : "failed",
        expectedBool: true,
        actualBool: addVerification.verified
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "source_attachment_selected",
        status: selectedAttachmentMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedAttachmentMatches
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "source_byte_count",
        status: draft.data.count > 0 ? "passed" : "failed",
        expectedBool: true,
        actualBool: draft.data.count > 0
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "target_note_readback",
        status: targetReadback ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetReadback
      ))
    return NotesMutationVerificationReport(
      verifier: "notes_attachment_copy_v1",
      operation: "notes.attachments.copy",
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_export+private_framework_attachment_write+attachment_export_hash+note_readback",
      targetIDSHA256: sha256Hex(result.attachment.id),
      checks: checks,
      warnings: addVerification.warnings
    )
  }

  func attachmentRecordMatches(
    _ lhs: NotesAttachmentRecord,
    _ rhs: NotesAttachmentRecord
  ) -> Bool {
    lhs.id == rhs.id
      || lhs.id == rhs.contentIdentifier
      || rhs.id == lhs.contentIdentifier
      || (lhs.contentIdentifier != nil && lhs.contentIdentifier == rhs.contentIdentifier)
  }

  func attachmentRecordMatches(_ record: NotesAttachmentRecord, selector: String) -> Bool {
    [
      record.id,
      record.contentIdentifier,
      record.mediaFilename,
      record.title,
    ].compactMap { $0 }
      .contains { $0 == selector }
  }

  private func verifyAttachmentRename(
    draft: NotesAttachmentRenameDraft,
    result: NotesAttachmentRenameWriteResult,
    operation: String,
    requiredFamily: String? = nil
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let updated = attachmentReadback.first {
      attachmentRecordMatches($0, result.attachment) || attachmentRecordMatches($0, draft.attachment)
    }
    let identityPreserved = updated != nil
    let titleReadback = updated?.title == draft.name
    let oldDisplayName = draft.attachment.title ?? draft.attachment.mediaFilename
    let oldNameReplaced = oldDisplayName == nil || updated?.title != oldDisplayName
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    var checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: identityPreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: identityPreserved
      ),
      NotesVerificationCheckRecord(
        name: "attachment_title",
        status: titleReadback ? "passed" : "failed",
        expectedSHA256: sha256Hex(draft.name),
        actualSHA256: updated?.title.map(sha256Hex)
      ),
      NotesVerificationCheckRecord(
        name: "old_title_replaced",
        status: oldNameReplaced ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldNameReplaced
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    if let requiredFamily {
      let actualFamily = updated.map(attachmentAuditFamily(_:))
      checks.append(
        NotesVerificationCheckRecord(
          name: "attachment_family",
          status: actualFamily == requiredFamily ? "passed" : "failed",
          expectedBool: true,
          actualBool: actualFamily == requiredFamily
        )
      )
    }
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: requiredFamily == nil
        ? "private_framework_attachment_rename+attachment_metadata_readback+note_readback"
        : "private_framework_attachment_rename+attachment_metadata_readback+note_readback+attachment_family",
      targetIDSHA256: sha256Hex(result.attachment.id),
      checks: checks
    )
  }

  private func verifyAttachmentRemove(
    draft: NotesAttachmentRemoveDraft,
    result: NotesAttachmentRemoveWriteResult,
    operation: String,
    requiredFamily: String? = nil
  ) throws -> NotesMutationVerificationReport {
    let attachmentReadback = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let metadataAbsent = !attachmentReadback.contains {
      attachmentRecordMatches($0, result.attachment) || attachmentRecordMatches($0, draft.attachment)
    }
    let exportAbsent = try attachmentExportAbsent(noteID: result.noteID, attachmentID: result.attachment.id)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    var checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_absence",
        status: metadataAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataAbsent
      ),
      NotesVerificationCheckRecord(
        name: "attachment_export_absence",
        status: exportAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: exportAbsent
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    if let requiredFamily {
      let actualFamily = attachmentAuditFamily(result.attachment)
      checks.append(
        NotesVerificationCheckRecord(
          name: "attachment_family",
          status: actualFamily == requiredFamily ? "passed" : "failed",
          expectedBool: true,
          actualBool: actualFamily == requiredFamily
        )
      )
    }
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: requiredFamily == nil
        ? "private_framework_attachment_remove+attachment_absence+note_readback"
        : "private_framework_attachment_remove+attachment_absence+note_readback+attachment_family",
      targetIDSHA256: sha256Hex(result.attachment.id),
      checks: checks
    )
  }

  private func attachmentExportAbsent(noteID: String, attachmentID: String) throws -> Bool {
    do {
      _ = try attachmentReader().exportAttachment(noteID: noteID, attachmentID: attachmentID)
      return false
    } catch let error as CLIError where error.code == .notFound {
      return true
    } catch {
      return false
    }
  }

  func exportAttachment(
    _ source: NotesAttachmentExportSource,
    requestedAttachmentID: String,
    destinationPath: String,
    options: CLIOptions,
    operation: String = "notes.attachments.export",
    requiredFamily: String? = nil,
    artifactMessage: String = "Notes attachment export writes a filesystem artifact and requires `--allow-artifact-action`."
  ) throws -> CLICommandResult {
    let dataHash = sha256Hex(source.data)
    let summary = attachmentExportSummary(
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
          scope: attachmentExportScopeDigest(source: source, destinationPath: destinationPath, operation: operation),
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
      message: artifactMessage
    )

    try writeNotesAttachmentExport(source.data, to: destinationPath)
    let verification = try verifyAttachmentExport(
      source: source,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      operation: operation,
      requiredFamily: requiredFamily
    )
    let result = NotesAttachmentExportResult(
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
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func attachmentExportSummary(
    source: NotesAttachmentExportSource,
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
      "attachment_family": attachmentAuditFamily(source.attachment),
    ]
  }

  private func attachmentExportScopeDigest(
    source: NotesAttachmentExportSource,
    destinationPath: String,
    operation: String = "notes.attachments.export"
  ) -> String {
    let fields = [
      operation,
      source.noteID,
      source.attachment.id,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
    ].joined(separator: "|")
    return "\(operation):\(sha256Hex(fields))"
  }

  private func gatedAttachmentCapabilityError(
    operation: String,
    capability: String,
    appleCapability: String,
    futureGate: String
  ) -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message:
        "Notes \(appleCapability.replacingOccurrences(of: "_", with: " ")) is gated until private-framework attachment/media operation proof and verifier readback are accepted.",
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": "gated",
        "future_gate": futureGate,
        "required_implementation": "typed_private_notes_framework",
        "required_verifier": "private_framework_attachment_readback+media_operation_delta",
        "backend_calls": "none",
      ]
    )
  }

  private func delegatedAttachmentCapabilityError(
    operation: String,
    capability: String,
    appleCapability: String,
    delegatedSurface: String
  ) -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message:
        "Notes \(appleCapability.replacingOccurrences(of: "_", with: " ")) is delegated to a Notes.app or system UI surface and is not a direct Notes private-framework CLI operation.",
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": "delegated",
        "delegated_surface": delegatedSurface,
        "required_implementation": "delegated_notes_app_or_system_surface",
        "required_verifier": "delegated_ui_or_system_accounting",
        "backend_calls": "none",
      ]
    )
  }

  private func rejectedAttachmentCapabilityError(
    operation: String,
    capability: String,
    appleCapability: String,
    productLimit: String
  ) -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message:
        "Notes \(appleCapability.replacingOccurrences(of: "_", with: " ")) is rejected because it is not an Apple Notes product capability.",
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": "rejected",
        "product_limit": productLimit,
        "required_implementation": "not_applicable",
        "required_verifier": "official_product_limitation_accounting",
        "backend_calls": "none",
      ]
    )
  }

  private func attachmentWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.attachments.workflow.audit"
    let records = notesAttachmentWorkflowAuditRecords()
    let summary = notesAttachmentWorkflowAuditSummary(records)
    let verification = verifyAttachmentWorkflowAudit(records: records, summary: summary)
    let response = NotesAttachmentWorkflowAuditResponse(
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

  private func notesAttachmentWorkflowAuditRecords() -> [NotesAttachmentWorkflowAuditRecord] {
    struct AttachmentWorkflowAuditItem {
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
      AttachmentWorkflowAuditItem(
        family: "attachment_note_metadata",
        guideSection: "View attachments in a note",
        status: "supported",
        appleCapability: "view_attachments_in_one_note",
        command: "attachments list --id NOTE_ID",
        mechanism: "typed_private_notes_framework_attachment_metadata_reader",
        requiredImplementation: "ICNote attachment metadata readback",
        requiredVerifier: "private_attachment_metadata_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "metadata_only_without_attachment_bytes_or_note_body",
        reason: "The accepted note-scoped attachment list returns identifiers, family metadata, names, hashes, and byte counts without attachment bytes or note body text."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachment_collection_metadata",
        guideSection: "View attachments from all your notes",
        status: "supported",
        appleCapability: "view_attachments_browser_categories",
        command: "attachments list [--account ACCOUNT] [--folder FOLDER] [--family FAMILY]",
        mechanism: "typed_private_notes_framework_attachment_collection_reader",
        requiredImplementation: "bounded visible-note attachment metadata scan",
        requiredVerifier: "private_attachment_family_count_readback+bounded_scan",
        safetyGate: "bounded-read",
        privacyBoundary: "source_note_summaries_without_note_bodies_or_attachment_bytes",
        reason: "The accepted collection reader covers Attachments Browser-style family grouping with bounded scans and privacy-safe source note summaries."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachment_family_accounting",
        guideSection: "Add photos, PDFs, and more / View attachments",
        status: "supported",
        appleCapability: "account_for_attachment_families",
        command: "attachments audit [--account ACCOUNT] [--folder FOLDER]",
        mechanism: "typed_private_notes_framework_attachment_audit_reader",
        requiredImplementation: "private attachment metadata family classification",
        requiredVerifier: "private_attachment_family_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_raw_uti_values_without_bytes",
        reason: "The accepted attachment audit accounts for photos, videos, scans, PDFs, drawings, audio, maps, webpage previews, files, and unknown families."
      ),
      AttachmentWorkflowAuditItem(
        family: "local_file_photo_video_add",
        guideSection: "Add photos and files from your Mac",
        status: "supported",
        appleCapability: "add_photos_videos_pdfs_and_files_from_mac",
        command: "attachments add --id NOTE_ID --file PATH | --files PATHS",
        mechanism: "typed_private_notes_framework_attachment_writer",
        requiredImplementation: "private attachment writer for local files",
        requiredVerifier: "private_attachment_metadata_readback+content_hash_accounting",
        safetyGate: "dry-run/readback",
        privacyBoundary: "source_path_hashes_and_attachment_hashes_without_file_bytes",
        reason: "The accepted attachment writer adds one or a bounded batch of explicit local files, including photos, videos, PDFs, and generic files, with hash-only evidence."
      ),
      AttachmentWorkflowAuditItem(
        family: "webpage_map_preview_add",
        guideSection: "Add items directly from another app",
        status: "supported",
        appleCapability: "add_webpage_or_map_preview_attachment",
        command: "attachments add-webpage --id NOTE_ID --url URL",
        mechanism: "typed_private_notes_framework_url_preview_writer",
        requiredImplementation: "private URL attachment writer plus preview metadata readback",
        requiredVerifier: "private_link_metadata_readback+webpage_preview_attachment_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "public_web_url_only_for_explicit_preview_url",
        reason: "The accepted webpage/map preview writer creates one explicit URL preview attachment and verifies both link and attachment metadata readback."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachment_save_export",
        guideSection: "View attachments from all your notes",
        status: "supported",
        appleCapability: "save_exportable_attachment",
        command: "attachments export --id NOTE_ID --attachment ATTACHMENT_ID --output PATH",
        mechanism: "typed_private_notes_framework_attachment_exporter",
        requiredImplementation: "private media bytes read plus command-layer artifact writer",
        requiredVerifier: "artifact_hash+attachment_metadata_readback",
        safetyGate: "allow-artifact-action/readback",
        privacyBoundary: "artifact_hashes_without_printing_attachment_bytes_or_source_paths",
        reason: "The accepted raw attachment export writes only an explicitly requested artifact and verifies byte count, SHA-256, and source metadata."
      ),
      AttachmentWorkflowAuditItem(
        family: "pdf_scan_pdf_export",
        guideSection: "View a PDF or scanned document",
        status: "supported",
        appleCapability: "save_or_open_pdf_scan_as_pdf_artifact",
        command: "attachments export-pdf --id NOTE_ID --attachment ATTACHMENT_ID --output PATH",
        mechanism: "typed_private_notes_framework_pdf_scan_exporter",
        requiredImplementation: "private PDF media bytes/fallback/generated PDF data",
        requiredVerifier: "pdf_header+artifact_hash+attachment_metadata_readback",
        safetyGate: "allow-artifact-action/readback",
        privacyBoundary: "artifact_hashes_without_pdf_text_scan_images_or_media_paths",
        reason: "The accepted PDF export path can export existing PDF, scanned document, or generated/fallback paper attachments as verified PDF artifacts."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachment_rename",
        guideSection: "Rename a PDF or scanned document / View attachments",
        status: "supported",
        appleCapability: "rename_attachment",
        command: "attachments rename --id NOTE_ID --attachment ATTACHMENT_ID --name NAME",
        mechanism: "typed_private_notes_framework_attachment_title_writer",
        requiredImplementation: "ICAttachment title/userTitle mutation",
        requiredVerifier: "private_attachment_title_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "new_title_only_no_attachment_bytes",
        reason: "The accepted title writer renames one selected attachment, including PDF and scanned-document attachments, with title readback."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachment_name_search",
        guideSection: "View attachments in a note",
        status: "supported",
        appleCapability: "search_attachment_by_name",
        command: "attachments search --query QUERY [--family FAMILY]",
        mechanism: "typed_private_notes_framework_attachment_metadata_search",
        requiredImplementation: "bounded visible-note attachment metadata scan",
        requiredVerifier: "query_hash+metadata_match_readback+bounded_scan",
        safetyGate: "bounded-read",
        privacyBoundary: "query_hash_without_attachment_bytes_or_note_bodies",
        reason: "The accepted metadata search covers finding attachments by name/type/family without printing note bodies or attachment bytes."
      ),
      AttachmentWorkflowAuditItem(
        family: "pdf_scan_text_search",
        guideSection: "View a PDF or scanned document",
        status: "supported",
        appleCapability: "search_pdf_or_scanned_document_text",
        command: "attachments pdf search --query QUERY",
        mechanism: "typed_private_notes_framework_pdf_bytes_reader+PDFKit",
        requiredImplementation: "private PDF bytes plus PDFKit text extraction",
        requiredVerifier: "pdfkit_text_hash+query_hash+bounded_scan",
        safetyGate: "bounded-read",
        privacyBoundary: "text_hashes_without_printing_extracted_pdf_text",
        reason: "The accepted PDF text search reads private PDF bytes and reports hash/count evidence for searchable PDF/scanned-document text."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_model_inspect",
        guideSection: "Mark up attachments",
        status: "supported",
        appleCapability: "inspect_existing_markup_model",
        command: "attachments markup inspect --id NOTE_ID --attachment ATTACHMENT_ID [--output PATH]",
        mechanism: "typed_private_notes_framework_markup_model_reader",
        requiredImplementation: "ICMarkupUtilities.markupModelDataFromData",
        requiredVerifier: "markup_model_hash+attachment_metadata_readback",
        safetyGate: "bounded-read/allow-artifact-action",
        privacyBoundary: "markup_model_hashes_without_attachment_pixels_or_model_bytes",
        reason: "The accepted Markup inspect path reads one PDF, scan, or image Markup model and reports only presence, byte count, and hash unless artifact export is explicitly allowed."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_model_apply",
        guideSection: "Mark up attachments",
        status: "supported",
        appleCapability: "apply_existing_markup_model",
        command: "attachments markup edit --id NOTE_ID --attachment ATTACHMENT_ID --file MODEL",
        mechanism: "typed_private_notes_framework_markup_model_writer",
        requiredImplementation: "ICMarkupUtilities.applyMarkupModelData",
        requiredVerifier: "markup_model_readback+attachment_metadata_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "markup_model_hashes_without_model_bytes_or_attachment_pixels",
        reason: "The accepted Markup apply path writes a user-provided Markup model to one selected PDF, scan, or image attachment and verifies hash readback."
      ),
      AttachmentWorkflowAuditItem(
        family: "photo_library_picker",
        guideSection: "Add photos from your photo library",
        status: "delegated",
        appleCapability: "choose_photo_or_video_from_photos_library_picker",
        command: "Notes.app attachment toolbar / Photos picker",
        mechanism: "delegated_user_facing_photos_picker",
        requiredImplementation: "Notes.app Photos picker UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The Photos library picker is a user-facing Photos/Notes UI surface; the CLI supports explicit local file attachment import instead."
      ),
      AttachmentWorkflowAuditItem(
        family: "drag_drop_import",
        guideSection: "Add photos and files from your Mac",
        status: "delegated",
        appleCapability: "drag_photo_or_file_from_photos_finder_or_desktop",
        command: "macOS drag-and-drop into Notes.app",
        mechanism: "delegated_user_facing_drag_drop_surface",
        requiredImplementation: "Notes.app drag/drop interaction",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Drag-and-drop is transient AppKit UI input; the CLI uses explicit file path arguments for the same persisted attachment result."
      ),
      AttachmentWorkflowAuditItem(
        family: "continuity_insert_photo_scan_sketch",
        guideSection: "Add photos and files from your iPhone or iPad",
        status: "delegated",
        appleCapability: "take_photo_scan_document_or_add_sketch_from_nearby_device",
        command: "Notes.app File > Insert from iPhone or iPad",
        mechanism: "delegated_continuity_camera_surface",
        requiredImplementation: "Continuity Camera / nearby-device UI",
        requiredVerifier: "delegated_continuity_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Nearby-device capture and sketch insertion depend on Continuity and device UI rather than a local Notes model write owned by the CLI."
      ),
      AttachmentWorkflowAuditItem(
        family: "emoji_symbols_picker",
        guideSection: "Add emoji to your notes",
        status: "delegated",
        appleCapability: "insert_emoji_or_symbol",
        command: "macOS Character Viewer / Emoji & Symbols",
        mechanism: "delegated_system_text_input_surface",
        requiredImplementation: "macOS text input and Character Viewer",
        requiredVerifier: "delegated_text_input_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Emoji insertion is system text input; existing note body text writers cover explicit text changes, not the picker UI."
      ),
      AttachmentWorkflowAuditItem(
        family: "genmoji_creation",
        guideSection: "Add emoji to your notes",
        status: "delegated",
        appleCapability: "create_custom_genmoji",
        command: "Apple Intelligence Genmoji UI",
        mechanism: "delegated_apple_intelligence_surface",
        requiredImplementation: "Apple Intelligence Genmoji generation",
        requiredVerifier: "delegated_system_intelligence_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Genmoji generation is an Apple Intelligence system feature and is not a Notes private attachment API path."
      ),
      AttachmentWorkflowAuditItem(
        family: "share_sheet_to_notes",
        guideSection: "Add items directly from another app",
        status: "delegated",
        appleCapability: "share_item_or_selection_from_another_app_to_notes",
        command: "macOS Share sheet > Notes",
        mechanism: "delegated_system_share_extension_surface",
        requiredImplementation: "system share extension dispatch",
        requiredVerifier: "delegated_external_dispatch_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Share sheet capture depends on another app and system extension dispatch; the CLI accepts explicit files or URLs instead."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachments_browser_window_ui",
        guideSection: "View attachments from all your notes",
        status: "delegated",
        appleCapability: "show_or_hide_attachments_browser_window",
        command: "Notes.app View > Show/Hide Attachments Browser",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app Attachments Browser UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Opening and customizing the Attachments Browser is a Notes.app window/UI behavior; the CLI exposes equivalent metadata collections."
      ),
      AttachmentWorkflowAuditItem(
        family: "quick_look_preview",
        guideSection: "View attachments from all your notes / View attachments in a note",
        status: "delegated",
        appleCapability: "preview_attachment_with_quick_look",
        command: "macOS Quick Look / Space bar",
        mechanism: "delegated_quick_look_surface",
        requiredImplementation: "QLPreviewPanel / system preview UI",
        requiredVerifier: "delegated_preview_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Quick Look previewing is a system UI surface; CLI artifact export covers explicit bytes when requested."
      ),
      AttachmentWorkflowAuditItem(
        family: "open_default_app",
        guideSection: "Open an attachment in its default app / View a PDF or scanned document",
        status: "delegated",
        appleCapability: "open_attachment_in_default_app_or_preview",
        command: "Notes.app double-click / Open Attachment",
        mechanism: "delegated_external_app_dispatch_surface",
        requiredImplementation: "LaunchServices open default application",
        requiredVerifier: "delegated_external_dispatch_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Opening the attachment in Preview or another default app is external dispatch; the CLI keeps persisted export and dispatch concerns separate."
      ),
      AttachmentWorkflowAuditItem(
        family: "attachment_view_size_ui",
        guideSection: "View attachments in a note / View a PDF or scanned document",
        status: "delegated",
        appleCapability: "change_attachment_view_size",
        command: "Notes.app View As / Attachment View",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app attachment view preference/UI state",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Small/medium/large attachment display is a Notes.app viewing preference, not attachment data owned by the CLI."
      ),
      AttachmentWorkflowAuditItem(
        family: "pdf_scan_page_navigation_ui",
        guideSection: "View a PDF or scanned document",
        status: "delegated",
        appleCapability: "navigate_pdf_or_scan_pages_and_thumbnails",
        command: "Notes.app PDF/scan page UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app page navigation surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Swipe/page-thumbnail navigation is transient UI state; persisted scan page ordering and ordinary PDF page editing are tracked separately as semantic CLI commands."
      ),
      AttachmentWorkflowAuditItem(
        family: "share_attachment_external",
        guideSection: "View attachments from all your notes",
        status: "delegated",
        appleCapability: "share_attachment_with_another_app",
        command: "Notes.app Share attachment",
        mechanism: "delegated_system_share_surface",
        requiredImplementation: "system share sheet external dispatch",
        requiredVerifier: "delegated_external_dispatch_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Sharing an attachment to another app is external dispatch; the CLI can export bytes but does not silently invoke share targets."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_ui_tool_palette",
        guideSection: "Mark up attachments",
        status: "delegated",
        appleCapability: "use_markup_tool_palette_and_touch_bar",
        command: "Markup UI tools / Touch Bar",
        mechanism: "delegated_markup_ui_surface",
        requiredImplementation: "Markup extension interactive tool palette",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Interactive Markup tool selection, Touch Bar controls, and pinch zoom are user-facing Markup surfaces; model import/export is the accepted CLI data path, while semantic tool operations and Continuity annotate are accounted separately."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_extension_enablement",
        guideSection: "Mark up attachments",
        status: "delegated",
        appleCapability: "enable_markup_extension_in_system_settings",
        command: "System Settings > Login Items & Extensions > Actions > Markup",
        mechanism: "delegated_system_settings_surface",
        requiredImplementation: "macOS extension management UI",
        requiredVerifier: "delegated_system_settings_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Enabling the Markup extension is a macOS system setting, not a Notes private framework mutation."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_continuity_annotate",
        guideSection: "Mark up attachments",
        status: "delegated",
        appleCapability: "annotate_attachment_with_nearby_iphone_or_ipad",
        command: "attachments markup annotate --id NOTE_ID --attachment ATTACHMENT_ID [--device DEVICE]",
        mechanism: "delegated_continuity_markup_surface",
        requiredImplementation: "Continuity Markup nearby-device annotation UI",
        requiredVerifier: "delegated_continuity_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls_or_device_identifiers",
        reason: "Apple's Annotate tool uses a nearby iPhone or iPad Continuity UI. The CLI exposes a delegated no-implementation boundary instead of pretending to own device selection, stylus input, or live drawing data through the Notes private data model."
      ),
      AttachmentWorkflowAuditItem(
        family: "scan_capture",
        guideSection: "Add photos and files from your iPhone or iPad",
        status: "delegated",
        appleCapability: "capture_new_scanned_document",
        command: "Notes.app File > Insert from iPhone or iPad > Scan Documents",
        mechanism: "delegated_continuity_camera_surface",
        requiredImplementation: "Continuity Camera / nearby-device scan capture UI",
        requiredVerifier: "delegated_continuity_accounting",
        safetyGate: "none",
        privacyBoundary: "no_camera_image_bytes_or_local_device_identifiers",
        reason: "Apple's scan-capture workflow is a nearby-device Continuity Camera capture surface. The CLI supports persisted scan metadata and scan page edits after the attachment exists, but it does not own camera or device-capture UI through the Notes private data model."
      ),
      AttachmentWorkflowAuditItem(
        family: "scan_crop",
        guideSection: "Crop a PDF or scanned document",
        status: "supported",
        appleCapability: "crop_scanned_document",
        command: "attachments scan crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left X,Y --top-right X,Y --bottom-right X,Y --bottom-left X,Y",
        mechanism: "typed_private_notes_framework_scan_crop_writer",
        requiredImplementation: "ICAttachment.croppingQuad scalar writes plus ICDocCamScannedDocumentEditor.setQuad/private save path",
        requiredVerifier: "private_scan_crop_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "no_scan_image_bytes_or_crop_geometry_leakage",
        reason: "The accepted scan crop path mutates one selected scanned-document crop quad and verifies private crop metadata hash delta without printing crop geometry, scan images, PDF text, or attachment bytes. Ordinary PDF crop is supported separately; arbitrary PDF content editing is rejected as a product non-capability."
      ),
      AttachmentWorkflowAuditItem(
        family: "scan_rotate",
        guideSection: "Rotate a PDF or scanned document",
        status: "supported",
        appleCapability: "rotate_scanned_document",
        command: "attachments scan rotate --id NOTE_ID --attachment ATTACHMENT_ID --by DEGREES",
        mechanism: "typed_private_notes_framework_scan_orientation_writer",
        requiredImplementation: "ICDocCamScannedDocumentEditor.setOrientation plus private save path",
        requiredVerifier: "private_scan_orientation_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "orientation_delta_and_hashes_without_scan_image_bytes",
        reason: "The accepted scan rotation path mutates one selected scanned-document orientation and verifies private orientation readback without printing scan images, PDF text, or attachment bytes."
      ),
      AttachmentWorkflowAuditItem(
        family: "scan_filter",
        guideSection: "Apply a filter to a scanned document",
        status: "supported",
        appleCapability: "apply_filter_to_scanned_document",
        command: "attachments scan filter --id NOTE_ID --attachment ATTACHMENT_ID --style STYLE",
        mechanism: "typed_private_notes_framework_scan_filter_writer",
        requiredImplementation: "ICDocCamScannedDocumentEditor.applyFilter plus private save path",
        requiredVerifier: "private_scan_filter_type_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "filter_type_hashes_without_scan_image_bytes",
        reason: "The accepted scan filter path mutates one selected scanned-document filter type and verifies private imageFilterType readback without printing scan images, PDF text, or attachment bytes."
      ),
      AttachmentWorkflowAuditItem(
        family: "scan_page_order_edit",
        guideSection: "View a PDF or scanned document",
        status: "supported",
        appleCapability: "reorder_or_delete_scanned_document_pages",
        command: "attachments scan page move/delete --id NOTE_ID --attachment ATTACHMENT_ID",
        mechanism: "typed_private_notes_framework_scan_page_writer",
        requiredImplementation: "ICDocCamScannedDocumentEditor.movePageFromIndex/deletePagesAtIndexes plus private save path",
        requiredVerifier: "private_scan_page_count_and_order_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "page_counts_and_hashes_without_page_images_or_pdf_text",
        reason: "The accepted scan page path moves or deletes one scanned-document page and verifies page count plus PDF/scan metadata hash readback without printing scan images, PDF text, or attachment bytes."
      ),
      AttachmentWorkflowAuditItem(
        family: "pdf_crop",
        guideSection: "Crop a PDF or scanned document",
        status: "supported",
        appleCapability: "crop_pdf_page",
        command: "attachments pdf crop --id NOTE_ID --attachment ATTACHMENT_ID --ordinal PAGE --top-left X,Y --top-right X,Y --bottom-right X,Y --bottom-left X,Y",
        mechanism: "typed_private_notes_framework_pdf_direct_media_crop_writer",
        requiredImplementation: "ICMedia.writeData plus PDFKit PDFPage cropBox",
        requiredVerifier: "private_pdf_crop_hash_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "pdf_crop_hash_without_pdf_text_or_bytes_or_crop_geometry",
        reason: "The accepted ordinary PDF crop path changes one page crop box in a directly writable media PDF and verifies PDF page-count preservation plus PDF hash delta without printing crop geometry, PDF text, page images, attachment bytes, or local media paths."
      ),
      AttachmentWorkflowAuditItem(
        family: "pdf_content_edit",
        guideSection: "Manage PDFs and scanned documents / Mark up attachments",
        status: "rejected",
        appleCapability: "pdf_content_edit",
        command: "attachments pdf edit --id NOTE_ID --attachment ATTACHMENT_ID",
        mechanism: "apple_product_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_limitation_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Apple's Notes guide exposes PDF/scan crop, filter, rotate, rename, and Markup workflows; it does not expose arbitrary PDF content editing inside Notes. The CLI supports the official PDF page operations and Markup model apply separately, while this broad semantic command is rejected instead of remaining as private-framework work."
      ),
      AttachmentWorkflowAuditItem(
        family: "pdf_page_order_edit",
        guideSection: "View a PDF or scanned document",
        status: "supported",
        appleCapability: "rotate_reorder_or_delete_pdf_pages",
        command: "attachments pdf page rotate/move/delete --id NOTE_ID --attachment ATTACHMENT_ID",
        mechanism: "typed_private_notes_framework_pdf_page_writer",
        requiredImplementation: "ICMedia.writeData plus PDFKit page rotation/move/delete",
        requiredVerifier: "private_pdf_page_count_rotation_and_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "page_order_hashes_without_page_images_or_text",
        reason: "The accepted PDF page path rotates, moves, or deletes one page in a directly writable media PDF and verifies PDF page count, rotation, and hash deltas without printing PDF text, page images, attachment bytes, or local media paths."
      ),
      AttachmentWorkflowAuditItem(
        family: "scanned_document_ocr_search",
        guideSection: "View a PDF or scanned document",
        status: "supported",
        appleCapability: "search_image_only_scanned_document_text",
        command: "attachments scan search --query QUERY",
        mechanism: "typed_private_notes_framework_attachment_searchable_text_reader",
        requiredImplementation: "ICAttachment/ICAttachmentModel searchableTextContent readback",
        requiredVerifier: "private_attachment_searchable_text_readback+query_hash+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "ocr_text_hash_without_scan_images_or_raw_text",
        reason: "The accepted scan search path reads existing private searchable/indexable text from scanned-document attachments and reports hashes/counts only; scan capture is delegated to the Continuity Camera surface under attachments scan capture, while recognized text artifact export/generation and selected-attachment search indexing are supported separately by attachments recognized-text export, attachments recognized-text generate, and attachments recognized-text index."
      ),
      AttachmentWorkflowAuditItem(
        family: "image_drawing_handwriting_content_search",
        guideSection: "View attachments in a note",
        status: "supported",
        appleCapability: "search_image_drawing_or_handwriting_content",
        command: "attachments image search; attachments drawing search",
        mechanism: "typed_private_notes_framework_attachment_searchable_text_reader",
        requiredImplementation: "ICAttachment/ICAttachmentModel searchableTextContent readback",
        requiredVerifier: "private_attachment_searchable_text_readback+query_hash+privacy_boundary",
        safetyGate: "bounded-read",
        privacyBoundary: "visual_match_hash_without_image_or_drawing_bytes",
        reason: "The accepted image and drawing search commands read existing private searchable/indexable text and report hashes/counts only; image classification summary readback is supported separately by attachments image objects, while recognized text artifact generation and selected-attachment search indexing are supported by attachments recognized-text generate and attachments recognized-text index."
      ),
      AttachmentWorkflowAuditItem(
        family: "recognized_text_export",
        guideSection: "View a PDF or scanned document / View attachments in a note",
        status: "supported",
        appleCapability: "export_generate_or_index_recognized_text",
        command: "attachments recognized-text export|generate --id NOTE_ID --attachment ATTACHMENT_ID --output PATH; attachments recognized-text index --id NOTE_ID --attachment ATTACHMENT_ID",
        mechanism: "typed_private_notes_framework_attachment_searchable_text_reader+private_attachment_media_reader+dynamic_vision_artifact_writer+notes_corespotlight_reindexer",
        requiredImplementation: "ICAttachment/ICAttachmentModel searchableTextContent readback, private attachment media/PDF bytes plus command-layer text artifact writer, or ICCDCSIReindexer object-URI reindexing",
        requiredVerifier: "private_attachment_searchable_text_or_media_readback+artifact_hash+attachment_family+corespotlight_reindexer_completion",
        safetyGate: "allow-artifact-action/readback; allow-persistent-action/readback",
        privacyBoundary: "artifact_hash_or_object_uri_hash_without_printing_recognized_text_pixels_or_raw_core_data_uri",
        reason: "The accepted recognized-text paths write either existing private searchable/recognized text or generated OCR text from private attachment media/PDF bytes to an explicit `.txt` artifact with readback hash verification, and can reindex one selected scan/image/drawing attachment through the private CoreSpotlight reindexer with object-URI hash evidence. Image classification summary readback is supported separately by attachments image objects."
      ),
      AttachmentWorkflowAuditItem(
        family: "image_description_alt_text",
        guideSection: "Mark up attachments",
        status: "supported",
        appleCapability: "enter_view_or_edit_image_description",
        command: "attachments image description get/set --id NOTE_ID --attachment ATTACHMENT_ID",
        mechanism: "typed_private_notes_framework_inline_attachment_alt_text_reader_writer",
        requiredImplementation: "ICInlineAttachment.altText read/write for inline image-family attachments",
        requiredVerifier: "private_image_description_hash_readback+privacy_boundary",
        safetyGate: "DryRun payload / readback verified",
        privacyBoundary: "description_hash_without_image_pixels_or_raw_description",
        reason: "The accepted image-description slice maps Apple's Markup Image Description workflow to inline attachment alt-text metadata exposed by `ICInlineAttachment.altText`. The commands read or set one selected inline image-family attachment, verify private readback, and report only description byte counts and hashes. They do not perform OCR or broader semantic Markup editing; image classification summary readback is supported separately by attachments image objects."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_semantic_element_creation",
        guideSection: "Mark up attachments",
        status: "delegated",
        appleCapability: "create_shapes_signatures_text_highlights_and_drawings_semantically",
        command: "attachments markup add-shape|add-text|add-signature|highlight|sketch|draw",
        mechanism: "delegated_markup_pencilkit_tool_palette",
        requiredImplementation: "Notes.app Markup/PencilKit/PaperKit interactive tool palette",
        requiredVerifier: "delegated_markup_ui_accounting+complete_markup_model_apply_boundary",
        safetyGate: "delegated-ui",
        privacyBoundary: "markup_element_hashes_without_pixels_or_signature_data",
        reason: "The CLI supports complete Markup model inspection/export/apply through accepted private utilities. Individual shape, text, signature, highlight, sketch, and draw tools are interactive Markup/PencilKit surfaces rather than stable Notes data-layer writers, so the semantic tool commands delegate explicitly instead of pretending to wait for an element-level private writer."
      ),
      AttachmentWorkflowAuditItem(
        family: "markup_style_and_color",
        guideSection: "Mark up attachments",
        status: "delegated",
        appleCapability: "change_shape_style_border_color_fill_color_and_text_style",
        command: "attachments markup shape-style|border-color|fill-color|text-style",
        mechanism: "delegated_markup_pencilkit_style_palette",
        requiredImplementation: "Notes.app Markup/PencilKit/PaperKit interactive style palette",
        requiredVerifier: "delegated_markup_ui_accounting+complete_markup_model_apply_boundary",
        safetyGate: "delegated-ui",
        privacyBoundary: "style_and_color_hashes_without_pixels_or_raw_text",
        reason: "Apple exposes Shape Style, Border Color, Fill Color, and Text Style through the interactive Markup tool palette. The CLI supports complete Markup model apply/readback; individual style/color tool manipulation delegates to that UI surface because it is not a stable Notes private-framework data operation."
      ),
      AttachmentWorkflowAuditItem(
        family: "image_crop_rotate",
        guideSection: "Mark up attachments",
        status: "supported",
        appleCapability: "crop_or_rotate_image_attachment",
        command: "attachments image crop|rotate --id NOTE_ID --attachment ATTACHMENT_ID",
        mechanism: "typed_private_notes_framework_image_direct_media_transform_writer",
        requiredImplementation: "ICMedia.writeData plus ImageIO/CoreGraphics image crop/rotate",
        requiredVerifier: "private_image_media_hash_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "image_transform_hashes_without_pixels_or_crop_geometry",
        reason: "The accepted image transform path crops or rotates one selected photo/image attachment by rewriting direct private media bytes with ImageIO/CoreGraphics and verifies byte-count plus SHA-256 delta readback without printing image pixels, attachment bytes, or crop geometry."
      ),
      AttachmentWorkflowAuditItem(
        family: "exchange_attachment_unavailable",
        guideSection: "Add photos, PDFs, and more",
        status: "rejected",
        appleCapability: "attach_files_maps_or_webpage_previews_in_exchange_notes",
        command: "not accepted for Exchange Notes accounts",
        mechanism: "apple_account_provider_limitation",
        requiredImplementation: "none",
        requiredVerifier: "official_provider_limitation_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that Exchange Notes accounts cannot attach files, map locations, or webpage previews; this is an account-provider limitation, not pending private framework work."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesAttachmentWorkflowAuditRecord(
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

  private func notesAttachmentWorkflowAuditSummary(
    _ records: [NotesAttachmentWorkflowAuditRecord]
  ) -> NotesAttachmentWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesAttachmentWorkflowAuditSummary(
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

  private func verifyAttachmentWorkflowAudit(
    records: [NotesAttachmentWorkflowAuditRecord],
    summary: NotesAttachmentWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let rejected = Set(summary.rejectedWorkflowFamilies)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "attachment_read_and_add_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "attachment_note_metadata", "attachment_collection_metadata",
            "attachment_family_accounting", "local_file_photo_video_add",
            "webpage_map_preview_add",
          ]
        )
      ),
      verificationBoolCheck(
        name: "attachment_export_rename_search_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "attachment_save_export", "pdf_scan_pdf_export", "attachment_rename", "pdf_crop",
            "pdf_page_order_edit", "attachment_name_search", "pdf_scan_text_search",
            "scanned_document_ocr_search", "image_drawing_handwriting_content_search",
            "recognized_text_export", "image_description_alt_text",
          ]
        )
      ),
      verificationBoolCheck(
        name: "image_direct_media_transform_supported",
        expected: true,
        actual: supported.contains("image_crop_rotate")
      ),
      verificationBoolCheck(
        name: "markup_model_scan_edit_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "markup_model_inspect", "markup_model_apply", "scan_rotate", "scan_filter",
            "scan_crop", "scan_page_order_edit",
          ]
        )
      ),
      verificationBoolCheck(
        name: "ui_system_and_external_surfaces_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "photo_library_picker", "drag_drop_import", "continuity_insert_photo_scan_sketch",
            "emoji_symbols_picker", "genmoji_creation", "share_sheet_to_notes",
            "attachments_browser_window_ui", "quick_look_preview", "open_default_app",
            "attachment_view_size_ui", "pdf_scan_page_navigation_ui", "share_attachment_external",
            "markup_ui_tool_palette", "markup_extension_enablement", "markup_continuity_annotate",
            "scan_capture", "markup_semantic_element_creation", "markup_style_and_color",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_attachment_workflow_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "provider_limitation_rejected",
        expected: true,
        actual: rejected.contains("exchange_attachment_unavailable")
      ),
      verificationBoolCheck(
        name: "pdf_content_edit_non_capability_rejected",
        expected: true,
        actual: rejected.contains("pdf_content_edit")
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
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.attachments.workflow.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.attachments.workflow.audit"),
      checks: checks
    )
  }

  private func verifyAttachmentAddBatch(
    draft: NotesAttachmentAddBatchDraft,
    results: [
      (draft: NotesAttachmentAddDraft, write: NotesAttachmentAddWriteResult, verification: NotesMutationVerificationReport)
    ],
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let noteStillPresent = try implementation.readNote(id: draft.noteID) != nil
    let totalByteCount = attachmentAddTotalByteCount(draft.attachments)
    let actualByteCount = results.reduce(0) { $0 + $1.draft.data.count }
    let uniqueAttachmentIDs = Set(results.map { $0.write.attachment.id }).count
    let targetNotePreserved = results.allSatisfy { $0.write.noteID == draft.noteID }
    let perAttachmentVerified = results.allSatisfy { $0.verification.verified }
    let checks = [
      NotesVerificationCheckRecord(
        name: "attachment_count",
        status: results.count == draft.attachments.count ? "passed" : "failed",
        expectedLength: draft.attachments.count,
        actualLength: results.count
      ),
      NotesVerificationCheckRecord(
        name: "unique_attachment_results",
        status: uniqueAttachmentIDs == results.count ? "passed" : "failed",
        expectedLength: results.count,
        actualLength: uniqueAttachmentIDs
      ),
      NotesVerificationCheckRecord(
        name: "total_byte_count",
        status: actualByteCount == totalByteCount ? "passed" : "failed",
        expectedLength: totalByteCount,
        actualLength: actualByteCount
      ),
      NotesVerificationCheckRecord(
        name: "per_attachment_verifications",
        status: perAttachmentVerified ? "passed" : "failed",
        expectedBool: true,
        actualBool: perAttachmentVerified
      ),
      NotesVerificationCheckRecord(
        name: "target_note_preserved",
        status: targetNotePreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetNotePreserved
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
      evidenceLevel: "private_framework_attachment_add_batch+per_attachment_export_hash+note_readback",
      targetIDSHA256: sha256Hex(draft.noteID),
      checks: checks
    )
  }

  private func verifyWebpageAttachmentAdd(
    draft: NotesLinkAddDraft,
    result: NotesLinkAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let matchingLink = linkReadback.first { linkRecordMatches($0, urlString: draft.urlString) }
    let attachments = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let matchingAttachment = attachments.first {
      webpageAttachmentRecordMatches($0, link: result.link)
    }
    let webpageFamilyPresent = attachments.contains(where: attachmentAuditIsWebpageOrMapPreview)
    let metadataPresent = matchingLink != nil
    let kindIsURL = matchingLink?.kind == "url"
    let schemeIsWeb = matchingLink.map { $0.urlScheme == "http" || $0.urlScheme == "https" } ?? false
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsURL ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsURL
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeIsWeb ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeIsWeb
      ),
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: matchingAttachment != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: matchingAttachment != nil
      ),
      NotesVerificationCheckRecord(
        name: "attachment_family",
        status: webpageFamilyPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: webpageFamilyPresent
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
      evidenceLevel: "private_framework_webpage_attachment_write+link_metadata_readback+attachment_family_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyWebpageAttachmentUpdate(
    draft: NotesLinkUpdateDraft,
    result: NotesLinkUpdateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkVerification = try verifyLinkUpdate(
      draft: draft,
      result: result,
      operation: operation
    )
    let attachments = try attachmentReader().listAttachments(noteID: result.noteID, limit: 2_000)
    let matchingAttachment = attachments.first {
      webpageAttachmentRecordMatches($0, link: result.link)
    }
    let webpageFamilyPresent = attachments.contains(where: attachmentAuditIsWebpageOrMapPreview)
    let checks = linkVerification.checks + [
      NotesVerificationCheckRecord(
        name: "attachment_metadata_readback",
        status: matchingAttachment != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: matchingAttachment != nil
      ),
      NotesVerificationCheckRecord(
        name: "attachment_family",
        status: webpageFamilyPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: webpageFamilyPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_webpage_attachment_update+link_metadata_readback+attachment_family_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks,
      warnings: linkVerification.warnings
    )
  }

  private func webpageAttachmentRecordMatches(_ attachment: NotesAttachmentRecord, link: NotesLinkRecord) -> Bool {
    if attachment.id == link.id {
      return true
    }
    if let contentIdentifier = attachment.contentIdentifier,
      let tokenContentIdentifierSHA256 = link.tokenContentIdentifierSHA256,
      sha256Hex(contentIdentifier) == tokenContentIdentifierSHA256
    {
      return true
    }
    guard attachmentAuditIsWebpageOrMapPreview(attachment) else {
      return false
    }
    return attachment.title == link.displayText
      || attachment.title == link.altText
  }

  private func attachmentAuditIsWebpageOrMapPreview(_ attachment: NotesAttachmentRecord) -> Bool {
    let family = attachmentAuditFamily(attachment)
    return family == "webpage_preview" || family == "map_preview"
  }

  private func webpagePreviewFamily(urlString: String) -> String {
    let value = urlString.lowercased()
    if value.contains("maps.apple.") || value.contains("://maps.") || value.contains("/maps") {
      return "map_preview"
    }
    return "webpage_preview"
  }

  private func verifyAttachmentExport(
    source: NotesAttachmentExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String,
    requiredFamily: String? = nil
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let readback = try attachmentReader().listAttachments(noteID: source.noteID, limit: 2_000)
    let attachmentStillPresent = readback.contains { attachment in
      attachment.id == source.attachment.id
        || (source.attachment.contentIdentifier != nil
          && attachment.contentIdentifier == source.attachment.contentIdentifier)
    }
    var checks = [
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
        name: "attachment_metadata_readback",
        status: attachmentStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentStillPresent
      ),
    ]
    if let requiredFamily {
      let actualFamily = attachmentAuditFamily(source.attachment)
      checks.append(
        NotesVerificationCheckRecord(
          name: "attachment_family",
          status: actualFamily == requiredFamily ? "passed" : "failed",
          expectedBool: true,
          actualBool: actualFamily == requiredFamily
        )
      )
    }
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: requiredFamily == nil
        ? "private_framework_attachment_readback+artifact_hash"
        : "private_framework_attachment_readback+artifact_hash+attachment_family",
      targetIDSHA256: sha256Hex(source.attachment.id),
      checks: checks
    )
  }

  func attachmentReader() throws -> any NotesAttachmentReading {
    guard let attachmentReader = implementation as? any NotesAttachmentReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes attachment commands require a private-framework attachment reader.",
        details: [
          "capability": "attachments",
          "required_module": "NotesShared",
        ]
      )
    }
    return attachmentReader
  }

  func attachmentMutator() throws -> any NotesAttachmentMutating {
    guard let attachmentMutator = implementation as? any NotesAttachmentMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes attachment mutations require a private-framework attachment writer.",
        details: [
          "capability": "attachments_mutation",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return attachmentMutator
  }

  private func verifiedAttachmentCopyResult(_ result: NotesAttachmentCopyResult) throws -> NotesAttachmentCopyResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment copy verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }
}
