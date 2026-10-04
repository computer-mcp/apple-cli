import Foundation
import Utility

extension NotesCommand {
  func runImportExport(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["notes", "import", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["file"])
      let records = try importAuditRecords(options)
      let summary = importAuditSummary(records: records)
      let verification = verifyImportAudit(records: records, summary: summary)
      return try result(
        NotesImportAuditResponse(
          summary: summary,
          records: records,
          verification: verification
        ),
        human: [
          "source_kind: \(summary.sourceKind)",
          "scanned_items: \(summary.scannedItemCount)",
          "supported_text: \(summary.supportedTextCount)",
          "supported_markdown: \(summary.supportedMarkdownCount)",
          "supported_rich_formats: \(summary.supportedRichFormatCount)",
          "supported_enex: \(summary.supportedENEXCount)",
          "gated_enex: \(summary.gatedENEXCount)",
          "unsupported: \(summary.unsupportedCount)",
          "gated_imports: \(summary.gatedImportFamilies.joined(separator: ","))",
        ].joined(separator: "\n"),
        options: options
      )
    case ["notes", "import", "folder"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "file", "name"])
      try validateMutationIntent(options)
      let importDraft = try folderImportDraft(options)
      return try mutation(
        operation: "notes.import.folder",
        scopeDigest: folderImportScopeDigest(importDraft),
        summary: folderImportSummary(importDraft),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection"],
        dryRunNotes: folderImportDryRunNotes(importDraft)
      ) {
        return try verifiedFolderImportResult(try importFolder(importDraft))
      }
    case ["notes", "import", "markdown"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["folder", "file", "title"],
        allowedFlags: ["include-attachments"]
      )
      try validateMutationIntent(options)
      let importDraft = try markdownImportDraft(options)
      return try mutation(
        operation: "notes.import.markdown",
        scopeDigest: markdownImportScopeDigest(importDraft),
        summary: markdownImportSummary(importDraft),
        options: options
      ) {
        return try importMarkdown(importDraft)
      }
    case ["notes", "import", "rtf"]:
      return try importRichText(options, format: .rtf)
    case ["notes", "import", "rtfd"]:
      return try importRichText(options, format: .rtfd)
    case ["notes", "import", "html"]:
      return try importRichText(options, format: .html)
    case ["notes", "import", "enex"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "file"])
      try validateMutationIntent(options)
      let importDraft = try enexImportDraft(options)
      return try mutation(
        operation: "notes.import.enex",
        scopeDigest: enexImportScopeDigest(importDraft),
        summary: enexImportSummary(importDraft),
        options: options,
        dryRunNotes: enexImportDryRunNotes(importDraft)
      ) {
        try validateExecutableENEXImport(importDraft.source)
        return try verifiedENEXImportResult(try enexImporter().importENEX(importDraft))
      }
    case ["notes", "import", "text"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "file", "title"])
      try validateMutationIntent(options)
      let importDraft = try textImportDraft(options)
      return try mutation(
        operation: "notes.import.text",
        scopeDigest: textImportScopeDigest(importDraft),
        summary: textImportSummary(importDraft),
        options: options
      ) {
        let note = try implementation.createNote(importDraft.draft)
        let verification = try mutationVerifier().verifyCreate(
          operation: "notes.import.text",
          draft: importDraft.draft,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.import.text", changed: true, note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "replace", "markdown"]:
      return try replaceRichText(options, source: .markdown)
    case ["notes", "replace", "html"]:
      return try replaceRichText(options, source: .rich(.html))
    case ["notes", "replace", "rtf"]:
      return try replaceRichText(options, source: .rich(.rtf))
    case ["notes", "replace", "rtfd"]:
      return try replaceRichText(options, source: .rich(.rtfd))
    case ["notes", "export", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      return try exportAudit(options)
    case ["notes", "export", "pdf"]:
      try validateTargetOptions(options, allowedOptions: ["id", "output"])
      let id = try requiredOption("id", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesPDFExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes PDF export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try noteExporter().exportNotePDF(noteID: id)
      return try exportNotePDF(source, destinationPath: destinationPath, options: options)
    case ["notes", "export", "markdown"]:
      try validateTargetOptions(
        options, allowedOptions: ["id", "output"], allowedFlags: ["include-attachments"])
      let id = try requiredOption("id", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      let includeAttachments = options.hasTargetFlag("include-attachments")
      try validateNotesMarkdownExportDestination(destinationPath, includeAttachments: includeAttachments)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message:
            includeAttachments
              ? "Notes Markdown export writes a filesystem package and requires `--allow-artifact-action`."
              : "Notes Markdown export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try noteExporter().exportNoteMarkdown(
        noteID: id,
        includeAttachments: includeAttachments
      )
      return try exportNoteMarkdown(source, destinationPath: destinationPath, options: options)
    case ["notes", "export", "html"]:
      try validateTargetOptions(
        options, allowedOptions: ["id", "output"], allowedFlags: ["include-attachments"])
      let id = try requiredOption("id", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      let includeAttachments = options.hasTargetFlag("include-attachments")
      try validateNotesHTMLExportDestination(destinationPath, includeAttachments: includeAttachments)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message:
            notesHTMLExportDestinationIsPackage(destinationPath)
              ? "Notes HTML export writes a filesystem package and requires `--allow-artifact-action`."
              : "Notes HTML export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try noteExporter().exportNoteHTML(
        noteID: id,
        includeAttachments: includeAttachments,
        includeAttachmentResources: notesHTMLExportDestinationIsPackage(destinationPath)
      )
      return try exportNoteHTML(source, destinationPath: destinationPath, options: options)
    case ["notes", "export", "rtf"]:
      try validateTargetOptions(options, allowedOptions: ["id", "output"])
      let id = try requiredOption("id", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesRTFExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes RTF export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let source = try noteExporter().exportNoteRTF(noteID: id)
      return try exportNoteRTF(source, destinationPath: destinationPath, options: options)
    case ["notes", "export", "rtfd"]:
      try validateTargetOptions(options, allowedOptions: ["id", "output"])
      let id = try requiredOption("id", options: options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesRTFDExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Notes RTFD export writes a filesystem package and requires `--allow-artifact-action`."
        )
      }
      let source = try noteExporter().exportNoteRTFD(noteID: id)
      return try exportNoteRTFD(source, destinationPath: destinationPath, options: options)
    case ["notes", "print"]:
      try validateTargetOptions(options, allowedOptions: ["id", "printer"])
      let id = try requiredOption("id", options: options)
      let printerName = try printDispatcher.validatePrinter(name: try requiredOption("printer", options: options))
      let source = try noteExporter().exportNotePDF(noteID: id)
      return try printNote(source, printerName: printerName, options: options)
    case ["notes", "open-in-pages"], ["notes", "open-pages"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let source = try noteExporter().exportNoteRTFD(noteID: id)
      return try openNoteInPages(source, options: options)    default:
      return nil
    }
  }

  private enum NotesRichReplaceCommandSource {
    case markdown
    case rich(NotesRichImportFormat)
  }

  private func validateRichReplaceMutationState(_ state: NotesNoteStateRecord, operation: String) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes rich replace target must be a visible non-trash note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isPasswordProtected == false, state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes rich replace remains gated.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isEditable == true, state.isSharedReadOnly == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes rich replace target must be editable.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
  }

  private func markdownImportDraft(_ options: CLIOptions) throws -> NotesMarkdownImportDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    let source = try markdownSource(
      path: try requiredOption("file", options: options),
      includeAttachments: options.hasTargetFlag("include-attachments")
    )
    let title =
      try options.targetOption("title").map { value in
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
          throw CLIError(code: .validationError, message: "`--title` must not be empty.")
        }
        return trimmed
      } ?? markdownTitle(source)

    return NotesMarkdownImportDraft(
      draft: NotesCreateDraft(
        folderId: folder.id,
        folderName: folder.name,
        accountName: folder.accountName,
        title: title,
        body: source.body
      ),
      source: source
    )
  }

  private func importMarkdown(_ importDraft: NotesMarkdownImportDraft) throws -> NotesMarkdownImportResult {
    let imported = try markdownImporter().importMarkdown(importDraft)
    let note = imported.note

    var attachmentResults: [NotesMarkdownImportAttachmentResult] = []
    if importDraft.source.resources.isEmpty == false {
      let mutator = try attachmentMutator()
      for resource in importDraft.source.resources {
        let attachmentDraft = NotesAttachmentAddDraft(
          noteID: note.id,
          filename: resource.filename,
          sourcePath: resource.sourcePath,
          data: resource.data
        )
        let write = try mutator.addAttachment(attachmentDraft)
        let attachmentVerification = try verifyAttachmentAdd(
          draft: attachmentDraft,
          result: write,
          operation: "notes.import.markdown.attachment"
        )
        attachmentResults.append(
          NotesMarkdownImportAttachmentResult(
            relativePath: resource.relativePath,
            filename: resource.filename,
            byteCount: resource.byteCount,
            sha256: sha256Hex(resource.data),
            attachment: write.attachment,
            verification: attachmentVerification
          ))
      }
    }

    let verification = markdownImportVerification(
      importDraft: importDraft,
      note: note,
      importVerification: imported.verification,
      attachmentResults: attachmentResults
    )
    return try verifiedMarkdownImportResult(
      NotesMarkdownImportResult(
        operation: imported.operation,
        changed: imported.changed,
        note: note,
        isPackage: importDraft.source.isPackage,
        markdownRelativePath: importDraft.source.markdownRelativePath,
        sourceByteCount: importDraft.source.byteCount,
        sourceSHA256: sha256Hex(importDraft.source.body),
        resourceCount: importDraft.source.resources.count,
        packageFileCount: importDraft.source.packageFileCount,
        packageTotalByteCount: importDraft.source.packageTotalByteCount,
        packageTreeSHA256: importDraft.source.packageTreeSHA256,
        semanticSummary: importDraft.source.semanticSummary,
        importedPlainTextLength: imported.importedPlainTextLength,
        importedPlainTextSHA256: imported.importedPlainTextSHA256,
        attributedRunCount: imported.attributedRunCount,
        attachments: attachmentResults,
        verification: verification
      ))
  }

  private func importRichText(
    _ options: CLIOptions,
    format: NotesRichImportFormat
  ) throws -> CLICommandResult {
    try validateTargetOptions(
      options,
      allowedOptions: ["folder", "file", "title"],
      allowedFlags: format == .html ? ["include-attachments"] : []
    )
    try validateMutationIntent(options)
    let importDraft = try richImportDraft(options, format: format)
    return try mutation(
      operation: "notes.import.\(format.rawValue)",
      scopeDigest: richImportScopeDigest(importDraft),
      summary: richImportSummary(importDraft),
      options: options
    ) {
      return try importRichText(importDraft)
    }
  }

  private func richImportDraft(
    _ options: CLIOptions,
    format: NotesRichImportFormat
  ) throws -> NotesRichImportDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    let source = try richImportSource(
      path: try requiredOption("file", options: options),
      format: format,
      includeAttachments: format == .html && options.hasTargetFlag("include-attachments")
    )
    let title =
      try options.targetOption("title").map { value in
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
          throw CLIError(code: .validationError, message: "`--title` must not be empty.")
        }
        return trimmed
      } ?? richImportTitle(source)

    return NotesRichImportDraft(
      draft: NotesCreateDraft(
        folderId: folder.id,
        folderName: folder.name,
        accountName: folder.accountName,
        title: title,
        body: ""
      ),
      source: source
    )
  }

  private func importRichText(_ importDraft: NotesRichImportDraft) throws -> NotesRichImportResult {
    let imported = try richImporter().importRichText(importDraft)
    let note = imported.note

    var attachmentResults: [NotesRichImportAttachmentResult] = []
    if importDraft.source.resources.isEmpty == false {
      let mutator = try attachmentMutator()
      for resource in importDraft.source.resources {
        let attachmentDraft = NotesAttachmentAddDraft(
          noteID: note.id,
          filename: resource.filename,
          sourcePath: resource.sourcePath,
          data: resource.data
        )
        let write = try mutator.addAttachment(attachmentDraft)
        let attachmentVerification = try verifyAttachmentAdd(
          draft: attachmentDraft,
          result: write,
          operation: "notes.import.html.attachment"
        )
        attachmentResults.append(
          NotesRichImportAttachmentResult(
            relativePath: resource.relativePath,
            filename: resource.filename,
            byteCount: resource.byteCount,
            sha256: sha256Hex(resource.data),
            attachment: write.attachment,
            verification: attachmentVerification
          ))
      }
    }

    let verification = richImportVerification(
      importDraft: importDraft,
      note: note,
      importVerification: imported.verification,
      attachmentResults: attachmentResults
    )
    return try verifiedRichImportResult(
      NotesRichImportResult(
        operation: imported.operation,
        changed: imported.changed,
        note: note,
        formatFamily: imported.formatFamily,
        sourceByteCount: importDraft.source.byteCount,
        sourceSHA256: importDraft.source.data.map(sha256Hex),
        importedPlainTextLength: imported.importedPlainTextLength,
        importedPlainTextSHA256: imported.importedPlainTextSHA256,
        attributedRunCount: imported.attributedRunCount,
        attachmentRunCount: imported.attachmentRunCount,
        htmlRelativePath: importDraft.source.htmlRelativePath,
        resourceCount: importDraft.source.resources.count,
        packageFileCount: importDraft.source.packageFileCount,
        packageResourceFileCount: importDraft.source.packageResourceFileCount,
        packageTotalByteCount: importDraft.source.packageTotalByteCount,
        packageTreeSHA256: importDraft.source.packageTreeSHA256,
        attachments: attachmentResults,
        verification: verification
      ))
  }

  private func replaceRichText(
    _ options: CLIOptions,
    source: NotesRichReplaceCommandSource
  ) throws -> CLICommandResult {
    switch source {
    case .markdown:
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "file", "title"],
        allowedFlags: ["include-attachments"]
      )
    case .rich(let format):
      try validateTargetOptions(
        options,
        allowedOptions: ["id", "file", "title"],
        allowedFlags: format == .html ? ["include-attachments"] : []
      )
    }
    try validateMutationIntent(options)
    let draft = try richReplaceDraft(options, source: source)
    let operation = "notes.replace.\(draft.source.formatFamily)"
    return try mutation(
      operation: operation,
      scopeDigest: richReplaceScopeDigest(draft),
      summary: richReplaceSummary(draft),
      options: options,
      dryRunNotes: richReplaceDryRunNotes(draft)
    ) {
      return try verifiedRichReplaceResult(try richReplacer().replaceRichText(draft))
    }
  }

  private func richReplaceDraft(
    _ options: CLIOptions,
    source: NotesRichReplaceCommandSource
  ) throws -> NotesRichReplaceDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateRichReplaceMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.replace.\(richReplaceFormatFamily(source))"
      )
    }

    let title =
      try options.targetOption("title").map { value in
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
          throw CLIError(code: .validationError, message: "`--title` must not be empty.")
        }
        return trimmed
      } ?? note.title
    let file = try requiredOption("file", options: options)
    let replaceSource: NotesRichReplaceSource
    switch source {
    case .markdown:
      replaceSource = .markdown(
        try markdownSource(
          path: file,
          includeAttachments: options.hasTargetFlag("include-attachments")
        )
      )
    case .rich(let format):
      replaceSource = .rich(
        try richImportSource(
          path: file,
          format: format,
          includeAttachments: format == .html && options.hasTargetFlag("include-attachments")
        )
      )
    }
    return NotesRichReplaceDraft(noteID: note.id, title: title, source: replaceSource)
  }

  private func richReplaceFormatFamily(_ source: NotesRichReplaceCommandSource) -> String {
    switch source {
    case .markdown:
      return "markdown"
    case .rich(let format):
      return format.rawValue
    }
  }

  private func richReplaceDryRunNotes(_ draft: NotesRichReplaceDraft) -> [String] {
    var notes = [
      "Execution replaces the selected note body in place through private Notes rich text storage and keeps the note identity.",
    ]
    if draft.source.resourceCount > 0 {
      notes.append("Execution imports local package resources as Notes attachments and verifies attachment export hashes.")
      notes.append("Execution places matched Markdown/HTML inline resources at their source body positions.")
    }
    return notes
  }

  private func enexImportDraft(_ options: CLIOptions) throws -> NotesENEXImportDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    let source = try enexImportSource(path: try requiredOption("file", options: options))
    return NotesENEXImportDraft(
      folderID: folder.id,
      folderName: folder.name,
      accountName: folder.accountName,
      source: source
    )
  }

  private func enexImportDryRunNotes(_ importDraft: NotesENEXImportDraft) -> [String] {
    var notes = [
      "ENEX execution imports notes, preserves supported tag membership, and imports decoded resources as Notes attachments through private Notes writes.",
    ]
    if importDraft.source.resourceCount > 0 {
      notes.append("Execution verifies ENEX resource attachment export hashes after import.")
    }
    if importDraft.source.inlineResourceReferenceCount > 0 {
      notes.append(
        "Execution verifies ENEX inline media references match decoded resources before import and are inserted at their body positions."
      )
    }
    if importDraft.source.normalizedTagCount > 0 {
      notes.append("Execution normalizes whitespace-bearing ENEX tags to single-word Notes tags and verifies tag membership readback.")
    }
    if importDraft.source.unmatchedInlineResourceReferenceCount > 0 {
      notes.append("Execution will refuse this ENEX until every inline media reference can be matched to a decoded resource.")
    }
    if importDraft.source.createdDateCount > 0 || importDraft.source.updatedDateCount > 0 {
      notes.append("Execution verifies ENEX created/updated date readback when date fields are present.")
    }
    return notes
  }

  private func folderImportDraft(_ options: CLIOptions) throws -> NotesFolderImportDraft {
    let parentFolder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateCanCreateSubfolder(parentFolder)
    let source = try folderImportSource(path: try requiredOption("file", options: options))
    let importRootFolderName = try normalizedNotesFolderImportName(
      options.targetOption("name") ?? source.name
    )
    return NotesFolderImportDraft(
      parentFolderID: parentFolder.id,
      parentFolderName: parentFolder.name,
      accountName: parentFolder.accountName,
      importRootFolderName: importRootFolderName,
      source: source
    )
  }

  private func folderImportDryRunNotes(_ importDraft: NotesFolderImportDraft) -> [String] {
    [
      "Execution creates the supported source directory structure under the selected Notes folder.",
      "Execution imports TXT, Markdown, Markdown package, RTF, RTFD, HTML, and ENEX files with their existing private-framework verifiers.",
      "Dry-run and execution output use path/name hashes and do not print local source paths, file names, imported bodies, or resource bytes.",
    ]
  }

  private func importFolder(_ draft: NotesFolderImportDraft) throws -> NotesFolderImportResult {
    let operation = "notes.import.folder"
    var foldersByRelativePath: [String: NotesFolderRecord] = [:]
    var folderResults: [NotesFolderImportFolderResult] = []
    var fileResults: [NotesFolderImportFileResult] = []
    var folderVerificationReports: [NotesMutationVerificationReport] = []

    let rootFolderDraft = NotesFolderCreateDraft(
      name: draft.importRootFolderName,
      accountID: nil,
      accountName: draft.accountName,
      parentID: draft.parentFolderID,
      parentName: draft.parentFolderName
    )
    let rootFolder = try implementation.createFolder(rootFolderDraft)
    let rootVerification = try mutationVerifier().verifyFolderCreate(
      operation: "notes.import.folder.folder",
      draft: rootFolderDraft,
      resultFolder: rootFolder
    )
    folderVerificationReports.append(rootVerification)
    foldersByRelativePath[""] = rootFolder
    folderResults.append(
      NotesFolderImportFolderResult(
        ordinal: 1,
        relativePathSHA256: sha256Hex(""),
        folderIDSHA256: sha256Hex(rootFolder.id),
        nameSHA256: sha256Hex(rootFolder.name),
        nameLength: (rootFolder.name as NSString).length,
        depth: 0,
        verification: rootVerification
      ))

    for directory in draft.source.directories {
      guard let parent = foldersByRelativePath[directory.parentRelativePath] else {
        throw CLIError(
          code: .internalError,
          message: "Folder import parent resolution failed.",
          details: ["relative_path_sha256": sha256Hex(directory.relativePath)]
        )
      }
      let folderDraft = NotesFolderCreateDraft(
        name: directory.name,
        accountID: nil,
        accountName: parent.accountName,
        parentID: parent.id,
        parentName: parent.name
      )
      let folder = try implementation.createFolder(folderDraft)
      let verification = try mutationVerifier().verifyFolderCreate(
        operation: "notes.import.folder.folder",
        draft: folderDraft,
        resultFolder: folder
      )
      folderVerificationReports.append(verification)
      folderResults.append(
        NotesFolderImportFolderResult(
          ordinal: directory.ordinal + 1,
          relativePathSHA256: sha256Hex(directory.relativePath),
          parentRelativePathSHA256: sha256Hex(directory.parentRelativePath),
          folderIDSHA256: sha256Hex(folder.id),
          nameSHA256: sha256Hex(folder.name),
          nameLength: (folder.name as NSString).length,
          depth: directory.relativePath.split(separator: "/").count,
          verification: verification
        ))
      foldersByRelativePath[directory.relativePath] = folder
    }

    for file in draft.source.files {
      guard let folder = foldersByRelativePath[file.directoryRelativePath] else {
        throw CLIError(
          code: .internalError,
          message: "Folder import target folder resolution failed.",
          details: ["relative_path_sha256": sha256Hex(file.relativePath)]
        )
      }
      fileResults.append(try importFolderFile(file, into: folder))
    }

    let importedNoteCount = fileResults.reduce(0) { $0 + $1.importedNoteCount }
    let resourceCount = fileResults.reduce(0) { $0 + $1.resourceCount }
    let checks = [
      NotesVerificationCheckRecord(
        name: "source_tree_supported",
        status: "passed",
        expectedBool: true,
        actualBool: true
      ),
      NotesVerificationCheckRecord(
        name: "created_folder_count",
        status: folderResults.count == draft.source.directoryCount + 1 ? "passed" : "failed",
        expectedLength: draft.source.directoryCount + 1,
        actualLength: folderResults.count
      ),
      NotesVerificationCheckRecord(
        name: "imported_file_count",
        status: fileResults.count == draft.source.fileCount ? "passed" : "failed",
        expectedLength: draft.source.fileCount,
        actualLength: fileResults.count
      ),
      NotesVerificationCheckRecord(
        name: "imported_note_count",
        status: importedNoteCount == draft.source.importedNoteCount ? "passed" : "failed",
        expectedLength: draft.source.importedNoteCount,
        actualLength: importedNoteCount
      ),
      NotesVerificationCheckRecord(
        name: "resource_count",
        status: resourceCount == draft.source.resourceCount ? "passed" : "failed",
        expectedLength: draft.source.resourceCount,
        actualLength: resourceCount
      ),
      NotesVerificationCheckRecord(
        name: "folder_create_verifications",
        status: folderVerificationReports.allSatisfy(\.verified) ? "passed" : "failed",
        expectedBool: true,
        actualBool: folderVerificationReports.allSatisfy(\.verified)
      ),
      NotesVerificationCheckRecord(
        name: "file_import_verifications",
        status: fileResults.allSatisfy(\.verification.verified) ? "passed" : "failed",
        expectedBool: true,
        actualBool: fileResults.allSatisfy(\.verification.verified)
      ),
      NotesVerificationCheckRecord(
        name: "privacy_surface_limited_to_hashes",
        status: (folderResults.allSatisfy { $0.relativePathSHA256.count == 64 }
          && fileResults.allSatisfy { $0.relativePathSHA256.count == 64 }) ? "passed" : "failed",
        expectedBool: true,
        actualBool: folderResults.allSatisfy { $0.relativePathSHA256.count == 64 }
          && fileResults.allSatisfy { $0.relativePathSHA256.count == 64 }
      ),
    ]
    let verification = NotesMutationVerificationReport(
      verifier: "notes_folder_import_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_folder_create+supported_import_writers+note_readback",
      targetIDSHA256: sha256Hex(
        (folderResults.map(\.folderIDSHA256) + fileResults.map(\.noteIDsSHA256)).joined(separator: "\n")
      ),
      checks: checks,
      warnings: folderVerificationReports.flatMap(\.warnings) + fileResults.flatMap(\.verification.warnings)
    )
    return NotesFolderImportResult(
      operation: operation,
      changed: importedNoteCount > 0 || !folderResults.isEmpty,
      sourcePathSHA256: sha256Hex(draft.source.path),
      sourceNameSHA256: sha256Hex(draft.source.name),
      sourceTreeSHA256: draft.source.treeSHA256,
      sourceTotalByteCount: draft.source.totalByteCount,
      createdFolderCount: folderResults.count,
      sourceDirectoryCount: draft.source.directoryCount,
      importedFileCount: fileResults.count,
      importedNoteCount: importedNoteCount,
      resourceCount: resourceCount,
      formatFamilyCounts: draft.source.formatFamilyCounts,
      folders: folderResults,
      files: fileResults,
      verification: verification
    )
  }

  private func importFolderFile(
    _ file: NotesFolderImportFileSource,
    into folder: NotesFolderRecord
  ) throws -> NotesFolderImportFileResult {
    switch file.formatFamily {
    case "txt":
      guard let source = file.text else {
        throw folderImportMissingSource(file)
      }
      let draft = NotesCreateDraft(
        folderId: folder.id,
        folderName: folder.name,
        accountName: folder.accountName,
        title: textImportTitle(source),
        body: source.body
      )
      let note = try implementation.createNote(draft)
      let verification = try mutationVerifier().verifyCreate(
        operation: "notes.import.folder.text",
        draft: draft,
        resultNote: note
      )
      return folderImportFileResult(file, noteIDs: [note.id], verification: verification)
    case "markdown", "markdown_package":
      guard let source = file.markdown else {
        throw folderImportMissingSource(file)
      }
      let draft = NotesMarkdownImportDraft(
        draft: NotesCreateDraft(
          folderId: folder.id,
          folderName: folder.name,
          accountName: folder.accountName,
          title: markdownTitle(source),
          body: source.body
        ),
        source: source
      )
      let result = try importMarkdown(draft)
      return folderImportFileResult(
        file,
        noteIDs: [result.note.id],
        resourceCount: result.resourceCount,
        verification: result.verification
      )
    case "rtf", "rtfd", "html":
      guard let source = file.rich else {
        throw folderImportMissingSource(file)
      }
      let draft = NotesRichImportDraft(
        draft: NotesCreateDraft(
          folderId: folder.id,
          folderName: folder.name,
          accountName: folder.accountName,
          title: richImportTitle(source),
          body: ""
        ),
        source: source
      )
      let result = try verifiedRichImportResult(try richImporter().importRichText(draft))
      return folderImportFileResult(
        file,
        noteIDs: [result.note.id],
        resourceCount: result.attachmentRunCount,
        verification: result.verification
      )
    case "enex":
      guard let source = file.enex else {
        throw folderImportMissingSource(file)
      }
      let draft = NotesENEXImportDraft(
        folderID: folder.id,
        folderName: folder.name,
        accountName: folder.accountName,
        source: source
      )
      try validateExecutableENEXImport(source)
      let result = try verifiedENEXImportResult(try enexImporter().importENEX(draft))
      return folderImportFileResult(
        file,
        noteIDs: result.importedNotes.map(\.note.id),
        resourceCount: result.resourceCount,
        verification: result.verification
      )
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Folder import encountered an unsupported file family.",
        details: [
          "relative_path_sha256": sha256Hex(file.relativePath),
          "format_family": file.formatFamily,
        ]
      )
    }
  }

  private func folderImportFileResult(
    _ file: NotesFolderImportFileSource,
    noteIDs: [String],
    resourceCount: Int = 0,
    verification: NotesMutationVerificationReport
  ) -> NotesFolderImportFileResult {
    NotesFolderImportFileResult(
      ordinal: file.ordinal,
      relativePathSHA256: sha256Hex(file.relativePath),
      folderRelativePathSHA256: file.directoryRelativePath.isEmpty
        ? nil
        : sha256Hex(file.directoryRelativePath),
      formatFamily: file.formatFamily,
      sourceByteCount: file.byteCount,
      importedNoteCount: noteIDs.count,
      resourceCount: resourceCount,
      noteIDsSHA256: sha256Hex(noteIDs.joined(separator: "\n")),
      verification: verification
    )
  }

  private func folderImportMissingSource(_ file: NotesFolderImportFileSource) -> CLIError {
    CLIError(
      code: .internalError,
      message: "Folder import source payload was missing.",
      details: [
        "relative_path_sha256": sha256Hex(file.relativePath),
        "format_family": file.formatFamily,
      ]
    )
  }

  private func markdownImportVerification(
    importDraft: NotesMarkdownImportDraft,
    note: NotesNoteDetail,
    importVerification: NotesMutationVerificationReport,
    attachmentResults: [NotesMarkdownImportAttachmentResult]
  ) -> NotesMutationVerificationReport {
    let noteReadback = try? implementation.readNote(id: note.id)
    let allAttachmentVerificationsPassed = attachmentResults.allSatisfy { $0.verification.verified }
    var checks = importVerification.checks
    checks.append(
      NotesVerificationCheckRecord(
        name: "semantic_import_verification",
        status: importVerification.verified ? "passed" : "failed",
        expectedBool: true,
        actualBool: importVerification.verified
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteReadback != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteReadback != nil
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "package_mode",
        status: importDraft.source.isPackage ? "passed" : "not_applicable",
        expectedBool: importDraft.source.isPackage ? true : nil,
        actualBool: importDraft.source.isPackage ? true : nil
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "resource_count",
        status: attachmentResults.count == importDraft.source.resources.count ? "passed" : "failed",
        expectedLength: importDraft.source.resources.count,
        actualLength: attachmentResults.count
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "package_resource_count",
        status: importDraft.source.isPackage
          ? (attachmentResults.count == importDraft.source.resources.count ? "passed" : "failed")
          : "not_applicable",
        expectedLength: importDraft.source.isPackage ? importDraft.source.resources.count : nil,
        actualLength: importDraft.source.isPackage ? attachmentResults.count : nil
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "semantic_markdown_counting",
        status: importDraft.source.semanticSummary.headingCount > 0
          || importDraft.source.semanticSummary.listItemCount > 0
          || importDraft.source.semanticSummary.blockQuoteLineCount > 0
          || importDraft.source.semanticSummary.linkReferenceCount > 0
          || importDraft.source.semanticSummary.imageReferenceCount > 0
          || importDraft.source.semanticSummary.fencedCodeBlockCount > 0
          ? "passed" : "not_applicable",
        expectedBool: nil,
        actualBool: true
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "attachment_verifications",
        status: allAttachmentVerificationsPassed ? "passed" : "failed",
        expectedBool: true,
        actualBool: allAttachmentVerificationsPassed
      ))

    let warnings = importVerification.warnings
      + attachmentResults.flatMap { $0.verification.warnings }
    return NotesMutationVerificationReport(
      verifier: "notes_markdown_import_v1",
      operation: "notes.import.markdown",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: importDraft.source.resources.isEmpty == false
        ? "private_framework_markdown_semantic_import+attachment_write+attachment_export_hash+note_readback"
        : "private_framework_markdown_semantic_import+note_readback",
      targetIDSHA256: sha256Hex(note.id),
      readback: importVerification.readback,
      storeObject: importVerification.storeObject,
      checks: checks,
      warnings: warnings
    )
  }

  private func richImportVerification(
    importDraft: NotesRichImportDraft,
    note: NotesNoteDetail,
    importVerification: NotesMutationVerificationReport,
    attachmentResults: [NotesRichImportAttachmentResult]
  ) -> NotesMutationVerificationReport {
    let noteReadback = try? implementation.readNote(id: note.id)
    let allAttachmentVerificationsPassed = attachmentResults.allSatisfy { $0.verification.verified }
    let isHTMLPackage = importDraft.source.format == .html && importDraft.source.htmlRelativePath != nil
    var checks = importVerification.checks
    checks.append(
      NotesVerificationCheckRecord(
        name: "rich_import_verification",
        status: importVerification.verified ? "passed" : "failed",
        expectedBool: true,
        actualBool: importVerification.verified
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteReadback != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteReadback != nil
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "html_package_mode",
        status: isHTMLPackage ? "passed" : "not_applicable",
        expectedBool: isHTMLPackage ? true : nil,
        actualBool: isHTMLPackage ? true : nil
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "html_package_main_file",
        status: isHTMLPackage ? "passed" : "not_applicable",
        expectedBool: isHTMLPackage ? true : nil,
        actualBool: isHTMLPackage ? importDraft.source.htmlRelativePath != nil : nil
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "package_resource_count",
        status: attachmentResults.count == importDraft.source.resources.count ? "passed" : "failed",
        expectedLength: importDraft.source.resources.count,
        actualLength: attachmentResults.count
      ))
    checks.append(
      NotesVerificationCheckRecord(
        name: "attachment_verifications",
        status: allAttachmentVerificationsPassed ? "passed" : "failed",
        expectedBool: true,
        actualBool: allAttachmentVerificationsPassed
      ))

    let warnings = importVerification.warnings
      + attachmentResults.flatMap { $0.verification.warnings }
    return NotesMutationVerificationReport(
      verifier: "notes_rich_import_v1",
      operation: "notes.import.\(importDraft.source.format.rawValue)",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: importDraft.source.resources.isEmpty
        ? importVerification.evidenceLevel
        : "private_framework_rich_text_import+text_storage_write+attachment_write+attachment_export_hash+note_readback",
      targetIDSHA256: sha256Hex(note.id),
      readback: importVerification.readback,
      storeObject: importVerification.storeObject,
      checks: checks,
      warnings: warnings
    )
  }

  private func textImportDraft(_ options: CLIOptions) throws -> NotesTextImportDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    let source = try textImportSource(path: try requiredOption("file", options: options))
    let title =
      try options.targetOption("title").map { value in
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
          throw CLIError(code: .validationError, message: "`--title` must not be empty.")
        }
        return trimmed
      } ?? textImportTitle(source)

    return NotesTextImportDraft(
      draft: NotesCreateDraft(
        folderId: folder.id,
        folderName: folder.name,
        accountName: folder.accountName,
        title: title,
        body: source.body
      ),
      source: source
    )
  }

  private func exportAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.export.audit"
    let noteID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: noteID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(noteID)]
      )
    }
    let state = try noteStateReader().readNoteState(noteID: noteID)
    let selectedNoteStatus = notesExportAuditSelectedNoteStatus(state)
    let records = notesExportAuditRecords(selectedNoteStatus: selectedNoteStatus)
    let summary = notesExportAuditSummary(records: records, state: state, selectedNoteStatus: selectedNoteStatus)
    let verification = verifyExportAudit(records: records, summary: summary, note: note)
    let response = NotesExportAuditResponse(
      operation: operation,
      changed: false,
      noteIDSHA256: sha256Hex(note.id),
      titleSHA256: sha256Hex(note.title),
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "selected_note_status: \(summary.selectedNoteStatus), supported_records: \(summary.supportedRecordCount), delegated_records: \(summary.delegatedRecordCount), gated_records: \(summary.gatedRecordCount), rejected_records: \(summary.rejectedRecordCount)",
      options: options
    )
  }

  private func notesExportAuditSelectedNoteStatus(_ state: NotesNoteStateRecord) -> String {
    if state.isDeletedOrInTrash || state.folderIsTrash == true {
      return "gated_deleted_or_trash"
    }
    if state.isPasswordProtectedAndLocked == true {
      return "gated_locked_password_protected"
    }
    if state.isPasswordProtected && state.isPasswordProtectedAndLocked == false {
      return "eligible_session_unlocked_password_protected"
    }
    if state.isPasswordProtected {
      return "gated_password_protected"
    }
    if state.needsCloudFetch == true {
      return "gated_needs_cloud_fetch"
    }
    if state.isUnsupported == true {
      return "gated_unsupported_note_state"
    }
    return "eligible"
  }

  private func notesExportAuditRecords(selectedNoteStatus: String) -> [NotesExportAuditRecord] {
    let ordinaryArtifactExportEligible = selectedNoteStatus == "eligible"
      || selectedNoteStatus == "eligible_session_unlocked_password_protected"
    let ordinaryDispatchEligible = selectedNoteStatus == "eligible"
      || selectedNoteStatus == "eligible_session_unlocked_password_protected"
    let lockedContentExportEligible = selectedNoteStatus == "eligible_session_unlocked_password_protected"
      || selectedNoteStatus == "gated_locked_password_protected"
    let acceptedRecords: [(String, String, String, String, Bool, Bool, String)] = [
      (
        "pdf", "notes export pdf", "supported", "file", true, false,
        "`notes export pdf` exports one visible note through the private PDF path, including session-unlocked password-protected notes."
      ),
      (
        "markdown", "notes export markdown", "supported", "file", true, false,
        "`notes export markdown` exports one visible note as a Markdown file, including session-unlocked password-protected notes."
      ),
      (
        "markdown_package", "notes export markdown --include-attachments", "supported", "package", true, false,
        "`notes export markdown --include-attachments` exports a verified Markdown resource package, including session-unlocked password-protected notes."
      ),
      (
        "html", "notes export html", "supported", "file", true, false,
        "`notes export html` exports one visible note as a single HTML file, including session-unlocked password-protected notes."
      ),
      (
        "html_package", "notes export html --include-attachments", "supported", "package", true, false,
        "`notes export html --include-attachments` exports a verified HTML resource package, including session-unlocked password-protected notes."
      ),
      (
        "rtf", "notes export rtf", "supported", "file", true, false,
        "`notes export rtf` exports one visible note as RTF, including session-unlocked password-protected notes."
      ),
      (
        "rtfd", "notes export rtfd", "supported", "package", true, false,
        "`notes export rtfd` exports one visible note as a verified RTFD package, including session-unlocked password-protected notes."
      ),
      (
        "print_dispatch", "notes print", "delegated", "external_dispatch", false, true,
        "`notes print` uses the private PDF path, then delegates submission to the system print service, including session-unlocked password-protected notes."
      ),
      (
        "pages_handoff", "notes open-in-pages", "delegated", "external_dispatch", false, true,
        "`notes open-in-pages` uses the private RTFD path, then delegates handoff to Pages, including session-unlocked password-protected notes."
      ),
    ]

    var records = acceptedRecords.enumerated().map { index, item in
      let eligibleForNoteState = item.3 == "external_dispatch"
        ? ordinaryDispatchEligible
        : ordinaryArtifactExportEligible
      let gatedByNote = !eligibleForNoteState
      let reason: String
      if gatedByNote {
        reason =
          "Selected note is \(selectedNoteStatus); export and dispatch commands require visible local content from a non-password-protected or session-unlocked password-protected note."
      } else {
        reason = item.6
      }
      return NotesExportAuditRecord(
        ordinal: index + 1,
        formatFamily: item.0,
        command: item.1,
        exportStatus: gatedByNote ? "gated_note_state" : item.2,
        artifactKind: item.3,
        requiresArtifactAction: item.4,
        requiresExternalDispatch: item.5,
        noteStateGate: gatedByNote ? selectedNoteStatus : nil,
        reason: reason
      )
    }

    let selectedNoteExportEligible = ordinaryArtifactExportEligible
    let lockedContentExportReason: String
    if selectedNoteStatus == "gated_locked_password_protected" {
      lockedContentExportReason =
        "Still-locked content export is supported when execution supplies a passphrase source; the command authenticates through private `ICAuthenticationState` and writes only the explicit `.txt` artifact."
    } else if lockedContentExportEligible {
      lockedContentExportReason =
        "Session-unlocked locked-content export is supported through private plaintext readback and an explicit `.txt` artifact gate."
    } else {
      lockedContentExportReason =
        "Locked-content export requires a selected password-protected note that is already unlocked in the current Notes session."
    }
    let residualRecords: [(String, String, String, String, String, Bool)] = [
      (
        "locked_note_export",
        "notes state export-locked-content",
        itemStatus(
          supportedWhen: lockedContentExportEligible,
          gatedNoteStatus: selectedNoteStatus
        ),
        lockedContentExportEligible ? "file" : "capability_gap",
        lockedContentExportReason,
        lockedContentExportEligible
      ),
      (
        "package_resource_preservation",
        "notes export markdown --include-attachments; notes export html --include-attachments; notes export rtfd",
        itemStatus(
          supportedWhen: selectedNoteExportEligible,
          gatedNoteStatus: selectedNoteStatus
        ),
        selectedNoteExportEligible ? "package" : "capability_gap",
        selectedNoteExportEligible
          ? "Accepted package exporters preserve selected-note resources through verified Markdown, HTML, and RTFD package tree hashes without writing artifacts during audit."
          : "Package resource preservation requires visible local content from a non-password-protected or session-unlocked password-protected note.",
        selectedNoteExportEligible
      ),
      (
        "unbounded_conversion_fidelity",
        "none",
        "rejected",
        "non_capability",
        "The current Apple Notes guide exposes PDF export, Markdown export, Pages handoff, print, and import formats; it does not promise a perfect round-trip conversion contract for every private rich-body or media edge case. The CLI verifies each accepted export artifact family instead of keeping this unbounded residual as gated work.",
        false
      ),
    ]
    records.append(
      contentsOf: residualRecords.enumerated().map { index, item in
        NotesExportAuditRecord(
          ordinal: acceptedRecords.count + index + 1,
          formatFamily: item.0,
          command: item.1,
          exportStatus: item.2,
          artifactKind: item.3,
          requiresArtifactAction: item.5,
          requiresExternalDispatch: false,
          noteStateGate: item.2 == "gated_note_state" ? selectedNoteStatus : nil,
          reason: item.4
        )
      }
    )
    return records
  }

  private func itemStatus(supportedWhen supported: Bool, gatedNoteStatus: String) -> String {
    if supported {
      return "supported"
    }
    if gatedNoteStatus.hasPrefix("gated_") {
      return "gated_note_state"
    }
    return "gated"
  }

  private func notesExportAuditSummary(
    records: [NotesExportAuditRecord],
    state: NotesNoteStateRecord,
    selectedNoteStatus: String
  ) -> NotesExportAuditSummary {
    NotesExportAuditSummary(
      selectedNoteStatus: selectedNoteStatus,
      noteIsDeletedOrInTrash: state.isDeletedOrInTrash || state.folderIsTrash == true,
      noteIsPasswordProtected: state.isPasswordProtected,
      noteIsPasswordProtectedAndLocked: state.isPasswordProtectedAndLocked,
      noteIsEditable: state.isEditable,
      noteIsSharedReadOnly: state.isSharedReadOnly,
      supportedRecordCount: records.filter { $0.exportStatus == "supported" }.count,
      delegatedRecordCount: records.filter { $0.exportStatus == "delegated" }.count,
      gatedRecordCount: records.filter { $0.exportStatus == "gated" || $0.exportStatus == "gated_note_state" }.count,
      rejectedRecordCount: records.filter { $0.exportStatus == "rejected" }.count,
      artifactActionRequired: records.contains {
        $0.requiresArtifactAction && ($0.exportStatus == "supported" || $0.exportStatus == "delegated")
      },
      externalDispatchRequired: records.contains {
        $0.requiresExternalDispatch && $0.exportStatus == "delegated"
      },
      supportedExportFamilies: records.filter { $0.exportStatus == "supported" }.map(\.formatFamily).sorted(),
      delegatedExportFamilies: records.filter { $0.exportStatus == "delegated" }.map(\.formatFamily).sorted(),
      gatedExportFamilies: records
        .filter { $0.exportStatus == "gated" || $0.exportStatus == "gated_note_state" }
        .map(\.formatFamily)
        .sorted(),
      rejectedExportFamilies: records
        .filter { $0.exportStatus == "rejected" }
        .map(\.formatFamily)
        .sorted()
    )
  }

  private func importAuditRecords(_ options: CLIOptions) throws -> [NotesImportAuditRecord] {
    let path = standardizedAbsolutePath(try requiredOption("file", options: options))
    let root = URL(fileURLWithPath: path).standardizedFileURL
    let limit = try commandLimit(options)
    var isDirectory = ObjCBool(false)
    guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory) else {
      throw CLIError(
        code: .notFound,
        message: "Import audit source was not found.",
        details: ["path_sha256": sha256Hex(root.path)]
      )
    }

    var urls = [root]
    if isDirectory.boolValue {
      let resourceKeys: Set<URLResourceKey> = [
        .isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey,
      ]
      guard
        let enumerator = FileManager.default.enumerator(
          at: root,
          includingPropertiesForKeys: Array(resourceKeys),
          options: [.skipsHiddenFiles],
          errorHandler: nil
        )
      else {
        return [try importAuditRecord(url: root, ordinal: 1)]
      }
      var children: [URL] = []
      for case let child as URL in enumerator {
        let standardizedChild = child.standardizedFileURL
        children.append(standardizedChild)
        if ["rtfd", "mdpkg", "markdownpackage"].contains(standardizedChild.pathExtension.lowercased()) {
          enumerator.skipDescendants()
        }
      }
      urls.append(
        contentsOf: children.sorted {
          $0.path.localizedStandardCompare($1.path) == .orderedAscending
        }
      )
    }

    return try urls.prefix(max(1, limit)).enumerated().map { index, url in
      try importAuditRecord(url: url, ordinal: index + 1)
    }
  }

  private func importAuditRecord(url: URL, ordinal: Int) throws -> NotesImportAuditRecord {
    let standardized = url.standardizedFileURL
    let values = try standardized.resourceValues(forKeys: [
      .isDirectoryKey, .isRegularFileKey, .fileSizeKey,
    ])
    let isDirectory = values.isDirectory == true
    let isRegularFile = values.isRegularFile == true
    let ext = standardized.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let extensionName = ext.isEmpty ? nil : ext
    let family = notesImportAuditFamily(extensionName: ext, isDirectory: isDirectory)
    let status = notesImportAuditStatus(family: family, url: standardized, isRegularFile: isRegularFile)
    return NotesImportAuditRecord(
      ordinal: ordinal,
      sourceKind: isDirectory ? "directory" : (isRegularFile ? "file" : "other"),
      pathSHA256: sha256Hex(standardized.path),
      nameSHA256: sha256Hex(standardized.lastPathComponent),
      extensionName: extensionName,
      byteCount: isRegularFile ? values.fileSize : nil,
      formatFamily: family,
      importStatus: status,
      reason: notesImportAuditReason(family: family, status: status),
      isDirectory: isDirectory
    )
  }

  private func notesImportAuditFamily(extensionName ext: String, isDirectory: Bool) -> String {
    switch ext {
    case "txt", "text":
      return "txt"
    case "md", "markdown":
      return "markdown"
    case "mdpkg", "markdownpackage":
      return "markdown_package"
    case "rtf":
      return "rtf"
    case "rtfd":
      return "rtfd"
    case "html", "htm":
      return "html"
    case "htmlpkg", "htmlpackage":
      return "html_package"
    case "enex":
      return "enex"
    default:
      return isDirectory ? "folder" : "unsupported"
    }
  }

  private func notesImportAuditStatus(family: String, url: URL, isRegularFile: Bool) -> String {
    switch family {
    case "txt":
      return "supported"
    case "markdown":
      return "supported_basic"
    case "markdown_package":
      return "supported_package"
    case "rtf", "rtfd", "html":
      return "supported_rich"
    case "html_package":
      return "supported_html_package"
    case "enex":
      guard isRegularFile else {
        return "gated_enex_parse"
      }
      do {
        let source = try enexImportSource(path: url.path)
        if source.unsupportedTagCount > 0 {
          return "gated_enex_parse"
        }
        if source.normalizedTagCount > 0 {
          return "supported_enex_normalized_tags"
        }
        return "supported_enex"
      } catch {
        return "gated_enex_parse"
      }
    case "folder":
      return "supported_folder_structure"
    default:
      return "unsupported"
    }
  }

  private func notesImportAuditReason(family: String, status: String) -> String {
    switch (family, status) {
    case ("txt", _):
      return "`notes import text` is the accepted UTF-8 TXT import path."
    case ("markdown", _):
      return "`notes import markdown` is accepted as basic text import."
    case ("markdown_package", _):
      return "`notes import markdown --include-attachments` accepts the CLI Markdown package shape."
    case ("rtf", _), ("html", _):
      return "`notes import rtf` and `notes import html` are accepted rich single-file import paths."
    case ("html_package", _):
      return "`notes import html --include-attachments` accepts the CLI HTML package shape."
    case ("rtfd", _):
      return "`notes import rtfd` is the accepted rich package import path with package tree verification."
    case ("enex", "supported_enex"):
      return "`notes import enex` accepts ENEX notes with supported tag and attachment resource preservation."
    case ("enex", "supported_enex_normalized_tags"):
      return "`notes import enex` normalizes whitespace-bearing ENEX tags to single-word Notes tags with membership readback."
    case ("enex", _):
      return "ENEX import is gated for this file until parser/readback proof accepts it."
    case ("folder", "supported_folder_structure"):
      return "`notes import folder` accepts bounded directory trees and preserves supported folder structure."
    case ("folder", _):
      return "Folder import is gated for this directory shape until folder reconstruction proof accepts it."
    default:
      return "This file family is not an accepted Notes import format."
    }
  }

  private func importAuditSummary(records: [NotesImportAuditRecord]) -> NotesImportAuditSummary {
    let root = records.first
    let folderImportRequested = root?.isDirectory == true
      && root?.formatFamily != "markdown_package"
      && root?.formatFamily != "html_package"
      && root?.formatFamily != "rtfd"
    return NotesImportAuditSummary(
      sourceKind: root?.sourceKind ?? "missing",
      scannedItemCount: records.count,
      regularFileCount: records.filter { $0.sourceKind == "file" }.count,
      directoryCount: records.filter { $0.isDirectory }.count,
      supportedTextCount: records.filter { $0.formatFamily == "txt" }.count,
      supportedMarkdownCount: records.filter { $0.formatFamily == "markdown" }.count,
      supportedMarkdownPackageCount: records.filter { $0.formatFamily == "markdown_package" }.count,
      supportedRichFormatCount: records.filter {
        $0.importStatus == "supported_rich" || $0.importStatus == "supported_html_package"
      }.count,
      gatedRichFormatCount: records.filter { $0.importStatus == "gated_rich_format" }.count,
      supportedENEXCount: records.filter { $0.importStatus.hasPrefix("supported_enex") }.count,
      gatedENEXCount: records.filter { $0.importStatus.hasPrefix("gated_enex") }.count,
      unsupportedCount: records.filter { $0.importStatus == "unsupported" }.count,
      folderImportRequested: folderImportRequested,
      preserveFolderStructureStatus: folderImportRequested ? "supported" : "not_applicable",
      enexTagImportStatus: records.contains { $0.importStatus == "supported_enex_normalized_tags" }
        ? "supported_normalized"
        : (records.contains { $0.formatFamily == "enex" } ? "supported" : "not_applicable"),
      supportedImportFamilies: [
        "enex_attachment_resources",
        "enex_normalized_tags",
        "enex_resource_free",
        "enex_inline_resource_reference_accounting",
        "enex_inline_resource_placement",
        "folder_preserve_structure",
        "markdown_semantic",
        "markdown_package_resources",
        "markdown_relative_resources",
        "html",
        "html_package_resources",
        "rtf",
        "rtfd",
        "txt",
      ],
      gatedImportFamilies: []
    )
  }

  private func verifyExportAudit(
    records: [NotesExportAuditRecord],
    summary: NotesExportAuditSummary,
    note: NotesNoteDetail
  ) -> NotesMutationVerificationReport {
    let acceptedRecordFamilies = records
      .filter { $0.artifactKind == "file" || $0.artifactKind == "package" || $0.artifactKind == "external_dispatch" }
      .map(\.formatFamily)
    let selectedNoteEligible = summary.selectedNoteStatus == "eligible"
    let sessionUnlockedProtected = summary.selectedNoteStatus == "eligible_session_unlocked_password_protected"
    let lockedProtectedWithPassphrase = summary.selectedNoteStatus == "gated_locked_password_protected"
    let ordinaryContentEligible = selectedNoteEligible || sessionUnlockedProtected
    let lockedContentExportEligible = sessionUnlockedProtected || lockedProtectedWithPassphrase
    let acceptedExecutionRecords = records.filter {
      $0.formatFamily != "locked_note_export"
        && ($0.artifactKind == "file" || $0.artifactKind == "package" || $0.artifactKind == "external_dispatch")
    }
    let expectedGatedByNoteStatus: Bool
    if ordinaryContentEligible {
      expectedGatedByNoteStatus = acceptedExecutionRecords.allSatisfy {
        $0.exportStatus == "supported" || $0.exportStatus == "delegated"
      }
    } else {
      expectedGatedByNoteStatus = acceptedExecutionRecords.allSatisfy { $0.exportStatus == "gated_note_state" }
    }
    let dispatchShouldBeDelegated = ordinaryContentEligible
    let delegatedDispatchAccounted = dispatchShouldBeDelegated
      ? summary.delegatedExportFamilies.contains("print_dispatch")
        && summary.delegatedExportFamilies.contains("pages_handoff")
        && records.contains { $0.formatFamily == "print_dispatch" && $0.requiresExternalDispatch }
        && records.contains { $0.formatFamily == "pages_handoff" && $0.requiresExternalDispatch }
      : summary.delegatedExportFamilies.isEmpty
        && records.contains { $0.formatFamily == "print_dispatch" && $0.requiresExternalDispatch }
        && records.contains { $0.formatFamily == "pages_handoff" && $0.requiresExternalDispatch }
    let artifactActionAccounted: Bool
    if selectedNoteEligible {
      artifactActionAccounted = summary.artifactActionRequired
        && records.contains { $0.exportStatus == "supported" && $0.requiresArtifactAction && $0.artifactKind == "file" }
        && records.contains { $0.exportStatus == "supported" && $0.requiresArtifactAction && $0.artifactKind == "package" }
    } else if sessionUnlockedProtected {
      artifactActionAccounted = summary.artifactActionRequired
        && records.contains { $0.exportStatus == "supported" && $0.requiresArtifactAction && $0.artifactKind == "file" }
        && records.contains { $0.exportStatus == "supported" && $0.requiresArtifactAction && $0.artifactKind == "package" }
        && records.contains {
          $0.formatFamily == "locked_note_export"
            && $0.exportStatus == "supported"
            && $0.requiresArtifactAction
            && $0.artifactKind == "file"
        }
    } else if lockedProtectedWithPassphrase {
      artifactActionAccounted = summary.artifactActionRequired
        && records.contains {
          $0.formatFamily == "locked_note_export"
            && $0.exportStatus == "supported"
            && $0.requiresArtifactAction
            && $0.artifactKind == "file"
        }
    } else {
      artifactActionAccounted = summary.artifactActionRequired == false
    }
    let lockedContentExpectedStatus: String
    if lockedContentExportEligible {
      lockedContentExpectedStatus = "supported"
    } else if selectedNoteEligible {
      lockedContentExpectedStatus = "gated"
    } else {
      lockedContentExpectedStatus = "gated_note_state"
    }
    let checks = [
      verificationBoolCheck(
        name: "export_record_count_matches",
        expected: true,
        actual: records.count
          == summary.supportedRecordCount + summary.delegatedRecordCount + summary.gatedRecordCount
          + summary.rejectedRecordCount
      ),
      verificationBoolCheck(
        name: "official_export_print_pages_accounted",
        expected: true,
        actual: acceptedRecordFamilies.contains("pdf")
          && acceptedRecordFamilies.contains("markdown")
          && acceptedRecordFamilies.contains("markdown_package")
          && acceptedRecordFamilies.contains("print_dispatch")
          && acceptedRecordFamilies.contains("pages_handoff")
      ),
      verificationBoolCheck(
        name: "private_export_formats_accounted",
        expected: true,
        actual: acceptedRecordFamilies.contains("html")
          && acceptedRecordFamilies.contains("html_package")
          && acceptedRecordFamilies.contains("rtf")
          && acceptedRecordFamilies.contains("rtfd")
      ),
      verificationBoolCheck(
        name: "delegated_dispatch_accounted",
        expected: true,
        actual: delegatedDispatchAccounted
      ),
      verificationBoolCheck(
        name: "residual_export_families_accounted",
        expected: true,
        actual: (lockedContentExportEligible
          ? summary.supportedExportFamilies.contains("locked_note_export")
          : summary.gatedExportFamilies.contains("locked_note_export"))
          && (ordinaryContentEligible
            ? summary.supportedExportFamilies.contains("package_resource_preservation")
            : summary.gatedExportFamilies.contains("package_resource_preservation"))
          && summary.rejectedExportFamilies.contains("unbounded_conversion_fidelity")
          && records.contains {
            $0.formatFamily == "locked_note_export"
              && $0.exportStatus == lockedContentExpectedStatus
          }
      ),
      verificationBoolCheck(
        name: "selected_note_state_accounted",
        expected: true,
        actual: expectedGatedByNoteStatus
      ),
      verificationBoolCheck(
        name: "artifact_action_gates_accounted",
        expected: true,
        actual: artifactActionAccounted
      ),
      verificationBoolCheck(
        name: "privacy_surface_limited_to_hashes",
        expected: true,
        actual: sha256Hex(note.id).count == 64
          && sha256Hex(note.title).count == 64
          && records.allSatisfy { !$0.reason.contains(note.title) && !$0.command.contains(note.id) }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.export.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_note_state_readback+apple_notes_export_family_accounting",
      targetIDSHA256: sha256Hex(note.id),
      checks: checks
    )
  }

  private func verifyImportAudit(
    records: [NotesImportAuditRecord],
    summary: NotesImportAuditSummary
  ) -> NotesMutationVerificationReport {
    let notPromotedFamilyStatus = "gated"
    let checks = [
      verificationBoolCheck(
        name: "audit_record_count_matches",
        expected: true,
        actual: summary.scannedItemCount == records.count
      ),
      verificationBoolCheck(
        name: "supported_import_families_accounted",
        expected: true,
        actual: summary.supportedImportFamilies.contains("txt")
          && summary.supportedImportFamilies.contains("markdown_semantic")
          && summary.supportedImportFamilies.contains("markdown_package_resources")
          && summary.supportedImportFamilies.contains("markdown_relative_resources")
          && summary.supportedImportFamilies.contains("rtf")
          && summary.supportedImportFamilies.contains("rtfd")
          && summary.supportedImportFamilies.contains("html")
          && summary.supportedImportFamilies.contains("html_package_resources")
          && summary.supportedImportFamilies.contains("enex_attachment_resources")
          && summary.supportedImportFamilies.contains("enex_normalized_tags")
          && summary.supportedImportFamilies.contains("enex_resource_free")
          && summary.supportedImportFamilies.contains("enex_inline_resource_reference_accounting")
          && summary.supportedImportFamilies.contains("enex_inline_resource_placement")
          && summary.supportedImportFamilies.contains("folder_preserve_structure")
      ),
      verificationBoolCheck(
        name: "official_import_formats_accounted",
        expected: true,
        actual: ["rtf", "rtfd", "html"].allSatisfy { summary.supportedImportFamilies.contains($0) }
          && summary.supportedImportFamilies.contains("html_package_resources")
          && summary.supportedImportFamilies.contains("enex_attachment_resources")
          && summary.supportedImportFamilies.contains("enex_normalized_tags")
          && summary.supportedImportFamilies.contains("enex_resource_free")
          && summary.supportedImportFamilies.contains("enex_inline_resource_reference_accounting")
          && summary.supportedImportFamilies.contains("enex_inline_resource_placement")
          && summary.supportedImportFamilies.contains("folder_preserve_structure")
      ),
      verificationBoolCheck(
        name: "folder_preserve_structure_accounted",
        expected: true,
        actual: summary.supportedImportFamilies.contains("folder_preserve_structure")
          && summary.preserveFolderStructureStatus != notPromotedFamilyStatus
      ),
      verificationBoolCheck(
        name: "enex_tag_import_accounted",
        expected: true,
        actual: summary.enexTagImportStatus == "not_applicable"
          || summary.enexTagImportStatus == "supported"
          || summary.enexTagImportStatus == "supported_normalized"
      ),
      verificationBoolCheck(
        name: "privacy_surface_limited_to_hashes",
        expected: true,
        actual: records.allSatisfy {
          $0.pathSHA256.count == 64 && $0.nameSHA256.count == 64
        }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.import.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "filesystem_import_preflight+apple_notes_import_family_accounting",
      targetIDSHA256: sha256Hex(records.map(\.pathSHA256).joined(separator: "\n")),
      checks: checks
    )
  }

  private func exportNotePDF(
    _ source: NotesNotePDFExportSource,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.export.pdf"
    let dataHash = sha256Hex(source.data)
    let summary = notePDFExportSummary(
      source: source,
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
          scope: notePDFExportScopeDigest(source: source, destinationPath: destinationPath),
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
      message: "Notes PDF export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeNotesPDFExport(source.data, to: destinationPath)
    let verification = try verifyNotePDFExport(
      source: source,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      operation: operation
    )
    let result = NotesNotePDFExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      destinationPath: destinationPath,
      byteCount: source.data.count,
      sha256: dataHash,
      title: source.title,
      isPasswordProtected: source.isPasswordProtected,
      isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes PDF export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func notePDFExportSummary(
    source: NotesNotePDFExportSource,
    destinationPath: String,
    dataHash: String
  ) -> [String: String] {
    var summary = [
      "id": source.noteID,
      "destination_path": destinationPath,
      "byte_count": "\(source.data.count)",
      "sha256": dataHash,
      "title": source.title ?? "",
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    return summary
  }

  private func notePDFExportScopeDigest(
    source: NotesNotePDFExportSource,
    destinationPath: String
  ) -> String {
    let fields = [
      source.noteID,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
    ].joined(separator: "|")
    return "notes-pdf-export:\(sha256Hex(fields))"
  }

  private func verifyNotePDFExport(
    source: NotesNotePDFExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let pdfHeader = fileData.count >= 4 && fileData.prefix(4) == Data("%PDF".utf8)
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
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
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_generation+artifact_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func exportNoteHTML(
    _ source: NotesNoteHTMLExportSource,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.export.html"
    let dataHash = sha256Hex(source.data)
    let isPackage = notesHTMLExportDestinationIsPackage(destinationPath)
    let packageFiles = isPackage ? try notesHTMLPackageFiles(source) : []
    let packageTreeSHA256 = isPackage ? notesHTMLPackageTreeSHA256(packageFiles) : nil
    let summary = noteHTMLExportSummary(
      source: source,
      destinationPath: destinationPath,
      dataHash: dataHash,
      isPackage: isPackage,
      packageFiles: packageFiles,
      packageTreeSHA256: packageTreeSHA256
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: noteHTMLExportScopeDigest(
            source: source,
            destinationPath: destinationPath,
            isPackage: isPackage,
            packageFiles: packageFiles,
            packageTreeSHA256: packageTreeSHA256
          ),
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
      message:
        isPackage
          ? "Notes HTML export writes a filesystem package and requires `--allow-artifact-action`."
          : "Notes HTML export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    let verification: NotesMutationVerificationReport
    if isPackage {
      let expectedTreeSHA256 = packageTreeSHA256 ?? notesHTMLPackageTreeSHA256(packageFiles)
      try writeNotesHTMLPackageExport(packageFiles, to: destinationPath)
      verification = try verifyNoteHTMLPackageExport(
        source: source,
        expectedFiles: packageFiles,
        destinationPath: destinationPath,
        expectedTreeSHA256: expectedTreeSHA256,
        operation: operation
      )
    } else {
      try writeNotesHTMLExport(source.data, to: destinationPath)
      verification = try verifyNoteHTMLExport(
        source: source,
        destinationPath: destinationPath,
        expectedSHA256: dataHash,
        operation: operation
      )
    }
    let result = NotesNoteHTMLExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      destinationPath: destinationPath,
      byteCount: source.data.count,
      sha256: dataHash,
      title: source.title,
      includesAttachments: source.includesAttachments,
      attachmentCount: source.attachmentCount,
      isPackage: isPackage,
      fileCount: isPackage ? packageFiles.count : nil,
      totalByteCount: isPackage ? notesHTMLPackageTotalByteCount(packageFiles) : nil,
      treeSHA256: packageTreeSHA256,
      htmlRelativePath: isPackage ? source.htmlRelativePath : nil,
      isPasswordProtected: source.isPasswordProtected,
      isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes HTML export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func exportNoteMarkdown(
    _ source: NotesNoteMarkdownExportSource,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.export.markdown"
    let dataHash = sha256Hex(source.data)
    let packageFiles = source.includesAttachments ? try notesMarkdownPackageFiles(source) : []
    let packageTreeSHA256 = source.includesAttachments ? notesMarkdownPackageTreeSHA256(packageFiles) : nil
    let summary = noteMarkdownExportSummary(
      source: source,
      destinationPath: destinationPath,
      dataHash: dataHash,
      packageFiles: packageFiles,
      packageTreeSHA256: packageTreeSHA256
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: noteMarkdownExportScopeDigest(
            source: source,
            destinationPath: destinationPath,
            packageFiles: packageFiles,
            packageTreeSHA256: packageTreeSHA256
          ),
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
      message:
        source.includesAttachments
          ? "Notes Markdown export writes a filesystem package and requires `--allow-artifact-action`."
          : "Notes Markdown export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    let verification: NotesMutationVerificationReport
    if source.includesAttachments {
      let expectedTreeSHA256 = packageTreeSHA256 ?? notesMarkdownPackageTreeSHA256(packageFiles)
      try writeNotesMarkdownPackageExport(packageFiles, to: destinationPath)
      verification = try verifyNoteMarkdownPackageExport(
        source: source,
        expectedFiles: packageFiles,
        destinationPath: destinationPath,
        expectedTreeSHA256: expectedTreeSHA256,
        operation: operation
      )
    } else {
      try writeNotesMarkdownExport(source.data, to: destinationPath)
      verification = try verifyNoteMarkdownExport(
        source: source,
        destinationPath: destinationPath,
        expectedSHA256: dataHash,
        operation: operation
      )
    }
    let result = NotesNoteMarkdownExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      destinationPath: destinationPath,
      byteCount: source.data.count,
      sha256: dataHash,
      title: source.title,
      includesAttachments: source.includesAttachments,
      attachmentCount: source.attachmentCount,
      isPackage: source.includesAttachments,
      fileCount: source.includesAttachments ? packageFiles.count : nil,
      totalByteCount: source.includesAttachments ? notesMarkdownPackageTotalByteCount(packageFiles) : nil,
      treeSHA256: packageTreeSHA256,
      markdownRelativePath: source.includesAttachments ? source.markdownRelativePath : nil,
      isPasswordProtected: source.isPasswordProtected,
      isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes Markdown export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func noteMarkdownExportSummary(
    source: NotesNoteMarkdownExportSource,
    destinationPath: String,
    dataHash: String,
    packageFiles: [NotesNoteMarkdownExportFile],
    packageTreeSHA256: String?
  ) -> [String: String] {
    var summary = [
      "id": source.noteID,
      "destination_path": destinationPath,
      "byte_count": "\(source.data.count)",
      "sha256": dataHash,
      "title": source.title ?? "",
      "includes_attachments": source.includesAttachments ? "true" : "false",
      "attachment_count": "\(source.attachmentCount)",
      "is_package": source.includesAttachments ? "true" : "false",
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    if source.includesAttachments {
      summary["file_count"] = "\(packageFiles.count)"
      summary["total_byte_count"] = "\(notesMarkdownPackageTotalByteCount(packageFiles))"
      summary["tree_sha256"] = packageTreeSHA256 ?? notesMarkdownPackageTreeSHA256(packageFiles)
      summary["markdown_relative_path"] = source.markdownRelativePath
    }
    return summary
  }

  private func noteMarkdownExportScopeDigest(
    source: NotesNoteMarkdownExportSource,
    destinationPath: String,
    packageFiles: [NotesNoteMarkdownExportFile],
    packageTreeSHA256: String?
  ) -> String {
    let fields = [
      source.noteID,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
      source.includesAttachments ? "include-attachments" : "single-file",
      "\(source.attachmentCount)",
      source.markdownRelativePath,
      "\(packageFiles.count)",
      packageTreeSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-markdown-export:\(sha256Hex(fields))"
  }

  private func verifyNoteMarkdownExport(
    source: NotesNoteMarkdownExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let validMarkdown = notesMarkdownDataIsValid(fileData)
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
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
        name: "markdown_utf8",
        status: validMarkdown ? "passed" : "failed",
        expectedBool: true,
        actualBool: validMarkdown
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_markdown_generation+artifact_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func verifyNoteMarkdownPackageExport(
    source: NotesNoteMarkdownExportSource,
    expectedFiles: [NotesNoteMarkdownExportFile],
    destinationPath: String,
    expectedTreeSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    var isDirectory = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory)
    let files = exists && isDirectory.boolValue ? try readNotesMarkdownPackageExportFiles(at: destination.path) : []
    let actualTreeSHA256 = notesMarkdownPackageTreeSHA256(files)
    let markdownValid = notesMarkdownPackageContainsMarkdownFile(files)
    let resourceCount = files.filter { $0.relativePath.hasPrefix("Resources/") }.count
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let totalByteCount = notesMarkdownPackageTotalByteCount(files)
    let expectedTotalByteCount = notesMarkdownPackageTotalByteCount(expectedFiles)
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
    let attachmentPolicyPreserved =
      source.includesAttachments && resourceCount == source.resourceFiles.count
      && source.resourceFiles.count == source.attachmentCount
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "destination_is_directory",
        status: isDirectory.boolValue ? "passed" : "failed",
        expectedBool: true,
        actualBool: isDirectory.boolValue
      ),
      NotesVerificationCheckRecord(
        name: "file_count",
        status: files.count == expectedFiles.count ? "passed" : "failed",
        expectedLength: expectedFiles.count,
        actualLength: files.count
      ),
      NotesVerificationCheckRecord(
        name: "total_byte_count",
        status: totalByteCount == expectedTotalByteCount ? "passed" : "failed",
        expectedLength: expectedTotalByteCount,
        actualLength: totalByteCount
      ),
      NotesVerificationCheckRecord(
        name: "tree_sha256",
        status: actualTreeSHA256 == expectedTreeSHA256 ? "passed" : "failed",
        expectedSHA256: expectedTreeSHA256,
        actualSHA256: actualTreeSHA256
      ),
      NotesVerificationCheckRecord(
        name: "markdown_utf8",
        status: markdownValid ? "passed" : "failed",
        expectedBool: true,
        actualBool: markdownValid
      ),
      NotesVerificationCheckRecord(
        name: "attachment_resource_count",
        status: resourceCount == source.attachmentCount ? "passed" : "failed",
        expectedLength: source.attachmentCount,
        actualLength: resourceCount
      ),
      NotesVerificationCheckRecord(
        name: "markdown_attachment_policy",
        status: attachmentPolicyPreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPolicyPreserved
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_markdown_generation+resource_package_tree_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func noteHTMLExportSummary(
    source: NotesNoteHTMLExportSource,
    destinationPath: String,
    dataHash: String,
    isPackage: Bool,
    packageFiles: [NotesNoteHTMLExportFile],
    packageTreeSHA256: String?
  ) -> [String: String] {
    var summary = [
      "id": source.noteID,
      "destination_path": destinationPath,
      "byte_count": "\(source.data.count)",
      "sha256": dataHash,
      "title": source.title ?? "",
      "includes_attachments": source.includesAttachments ? "true" : "false",
      "attachment_count": "\(source.attachmentCount)",
      "is_package": isPackage ? "true" : "false",
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    if isPackage {
      summary["file_count"] = "\(packageFiles.count)"
      summary["total_byte_count"] = "\(notesHTMLPackageTotalByteCount(packageFiles))"
      summary["tree_sha256"] = packageTreeSHA256 ?? notesHTMLPackageTreeSHA256(packageFiles)
      summary["html_relative_path"] = source.htmlRelativePath
    }
    return summary
  }

  private func noteHTMLExportScopeDigest(
    source: NotesNoteHTMLExportSource,
    destinationPath: String,
    isPackage: Bool,
    packageFiles: [NotesNoteHTMLExportFile],
    packageTreeSHA256: String?
  ) -> String {
    let fields = [
      source.noteID,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
      source.includesAttachments ? "include-attachments" : "single-file",
      "\(source.attachmentCount)",
      isPackage ? "package" : "single-file",
      source.htmlRelativePath,
      "\(packageFiles.count)",
      packageTreeSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-html-export:\(sha256Hex(fields))"
  }

  private func verifyNoteHTMLExport(
    source: NotesNoteHTMLExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let htmlMarker = notesHTMLDataHasMarker(fileData)
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let attachmentPolicyPreserved = source.includesAttachments || source.attachmentCount == 0
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
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
        name: "html_marker",
        status: htmlMarker ? "passed" : "failed",
        expectedBool: true,
        actualBool: htmlMarker
      ),
      NotesVerificationCheckRecord(
        name: "html_attachment_policy",
        status: attachmentPolicyPreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPolicyPreserved
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_html_generation+artifact_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func verifyNoteHTMLPackageExport(
    source: NotesNoteHTMLExportSource,
    expectedFiles: [NotesNoteHTMLExportFile],
    destinationPath: String,
    expectedTreeSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    var isDirectory = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory)
    let files = exists && isDirectory.boolValue ? try readNotesHTMLPackageExportFiles(at: destination.path) : []
    let actualTreeSHA256 = notesHTMLPackageTreeSHA256(files)
    let htmlValid = notesHTMLPackageContainsHTMLFile(files)
    let resourceCount = files.filter { $0.relativePath.hasPrefix("Resources/") }.count
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let totalByteCount = notesHTMLPackageTotalByteCount(files)
    let expectedTotalByteCount = notesHTMLPackageTotalByteCount(expectedFiles)
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
    let attachmentPolicyPreserved =
      source.includesAttachments && resourceCount == source.resourceFiles.count
      && source.resourceFiles.count == source.attachmentCount
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "destination_is_directory",
        status: isDirectory.boolValue ? "passed" : "failed",
        expectedBool: true,
        actualBool: isDirectory.boolValue
      ),
      NotesVerificationCheckRecord(
        name: "file_count",
        status: files.count == expectedFiles.count ? "passed" : "failed",
        expectedLength: expectedFiles.count,
        actualLength: files.count
      ),
      NotesVerificationCheckRecord(
        name: "total_byte_count",
        status: totalByteCount == expectedTotalByteCount ? "passed" : "failed",
        expectedLength: expectedTotalByteCount,
        actualLength: totalByteCount
      ),
      NotesVerificationCheckRecord(
        name: "tree_sha256",
        status: actualTreeSHA256 == expectedTreeSHA256 ? "passed" : "failed",
        expectedSHA256: expectedTreeSHA256,
        actualSHA256: actualTreeSHA256
      ),
      NotesVerificationCheckRecord(
        name: "html_marker",
        status: htmlValid ? "passed" : "failed",
        expectedBool: true,
        actualBool: htmlValid
      ),
      NotesVerificationCheckRecord(
        name: "attachment_resource_count",
        status: resourceCount == source.attachmentCount ? "passed" : "failed",
        expectedLength: source.attachmentCount,
        actualLength: resourceCount
      ),
      NotesVerificationCheckRecord(
        name: "html_attachment_policy",
        status: attachmentPolicyPreserved ? "passed" : "failed",
        expectedBool: true,
        actualBool: attachmentPolicyPreserved
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_html_generation+resource_package_tree_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func exportNoteRTF(
    _ source: NotesNoteRTFExportSource,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.export.rtf"
    let dataHash = sha256Hex(source.data)
    let summary = noteRTFExportSummary(
      source: source,
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
          scope: noteRTFExportScopeDigest(source: source, destinationPath: destinationPath),
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
      message: "Notes RTF export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeNotesRTFExport(source.data, to: destinationPath)
    let verification = try verifyNoteRTFExport(
      source: source,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      operation: operation
    )
    let result = NotesNoteRTFExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      destinationPath: destinationPath,
      byteCount: source.data.count,
      sha256: dataHash,
      title: source.title,
      isPasswordProtected: source.isPasswordProtected,
      isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes RTF export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func noteRTFExportSummary(
    source: NotesNoteRTFExportSource,
    destinationPath: String,
    dataHash: String
  ) -> [String: String] {
    var summary = [
      "id": source.noteID,
      "destination_path": destinationPath,
      "byte_count": "\(source.data.count)",
      "sha256": dataHash,
      "title": source.title ?? "",
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    return summary
  }

  private func noteRTFExportScopeDigest(
    source: NotesNoteRTFExportSource,
    destinationPath: String
  ) -> String {
    let fields = [
      source.noteID,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
    ].joined(separator: "|")
    return "notes-rtf-export:\(sha256Hex(fields))"
  }

  private func verifyNoteRTFExport(
    source: NotesNoteRTFExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let rtfHeader = notesRTFDataHasHeader(fileData)
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
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
        name: "rtf_header",
        status: rtfHeader ? "passed" : "failed",
        expectedBool: true,
        actualBool: rtfHeader
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_rtfd_filewrapper_rtf_member+artifact_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func exportNoteRTFD(
    _ source: NotesNoteRTFDExportSource,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.export.rtfd"
    let files = try normalizedNotesRTFDExportFiles(source.files)
    let totalByteCount = notesRTFDTotalByteCount(files)
    let treeSHA256 = notesRTFDTreeSHA256(files)
    let summary = noteRTFDExportSummary(
      source: source,
      files: files,
      destinationPath: destinationPath,
      treeSHA256: treeSHA256
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: noteRTFDExportScopeDigest(
            source: source,
            files: files,
            destinationPath: destinationPath
          ),
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
      message: "Notes RTFD export writes a filesystem package and requires `--allow-artifact-action`."
    )

    try writeNotesRTFDExport(files, to: destinationPath)
    let verification = try verifyNoteRTFDExport(
      source: source,
      expectedFiles: files,
      destinationPath: destinationPath,
      expectedTreeSHA256: treeSHA256,
      operation: operation
    )
    let result = NotesNoteRTFDExportResult(
      operation: operation,
      changed: true,
      noteID: source.noteID,
      destinationPath: destinationPath,
      fileCount: files.count,
      totalByteCount: totalByteCount,
      treeSHA256: treeSHA256,
      title: source.title,
      isPasswordProtected: source.isPasswordProtected,
      isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
      verification: verification
    )
    guard verification.verified else {
      var details = artifactVerificationFailureDetails(operation: operation, verification: verification)
      details["expected_file_paths"] = files.map(\.relativePath).sorted().joined(separator: ",")
      if let actualFiles = try? readNotesRTFDExportFiles(at: destinationPath) {
        details["actual_file_paths"] = actualFiles.map(\.relativePath).sorted().joined(separator: ",")
      }
      throw CLIError(
        code: .internalError,
        message: "Notes RTFD export verification failed.",
        details: details
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func noteRTFDExportSummary(
    source: NotesNoteRTFDExportSource,
    files: [NotesNoteRTFDExportFile],
    destinationPath: String,
    treeSHA256: String
  ) -> [String: String] {
    var summary = [
      "id": source.noteID,
      "destination_path": destinationPath,
      "file_count": "\(files.count)",
      "total_byte_count": "\(notesRTFDTotalByteCount(files))",
      "tree_sha256": treeSHA256,
      "title": source.title ?? "",
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    return summary
  }

  private func noteRTFDExportScopeDigest(
    source: NotesNoteRTFDExportSource,
    files: [NotesNoteRTFDExportFile],
    destinationPath: String
  ) -> String {
    let fields = [
      source.noteID,
      destinationPath,
      "\(files.count)",
      "\(notesRTFDTotalByteCount(files))",
      notesRTFDTreeSHA256(files),
    ].joined(separator: "|")
    return "notes-rtfd-export:\(sha256Hex(fields))"
  }

  private func verifyNoteRTFDExport(
    source: NotesNoteRTFDExportSource,
    expectedFiles: [NotesNoteRTFDExportFile],
    destinationPath: String,
    expectedTreeSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory)
    let actualFiles = exists && isDirectory.boolValue
      ? try readNotesRTFDExportFiles(at: destination.path)
      : []
    let actualTreeSHA256 = notesRTFDTreeSHA256(actualFiles)
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let containsRTF = notesRTFDContainsRTFFile(actualFiles)
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
    let checks = [
      NotesVerificationCheckRecord(
        name: "destination_exists",
        status: exists ? "passed" : "failed",
        expectedBool: true,
        actualBool: exists
      ),
      NotesVerificationCheckRecord(
        name: "destination_is_directory",
        status: isDirectory.boolValue ? "passed" : "failed",
        expectedBool: true,
        actualBool: isDirectory.boolValue
      ),
      NotesVerificationCheckRecord(
        name: "file_count",
        status: actualFiles.count == expectedFiles.count ? "passed" : "failed",
        expectedLength: expectedFiles.count,
        actualLength: actualFiles.count
      ),
      NotesVerificationCheckRecord(
        name: "total_byte_count",
        status: notesRTFDTotalByteCount(actualFiles) == notesRTFDTotalByteCount(expectedFiles)
          ? "passed" : "failed",
        expectedLength: notesRTFDTotalByteCount(expectedFiles),
        actualLength: notesRTFDTotalByteCount(actualFiles)
      ),
      NotesVerificationCheckRecord(
        name: "tree_sha256",
        status: actualTreeSHA256 == expectedTreeSHA256 ? "passed" : "failed",
        expectedSHA256: expectedTreeSHA256,
        actualSHA256: actualTreeSHA256
      ),
      NotesVerificationCheckRecord(
        name: "rtf_member",
        status: containsRTF ? "passed" : "failed",
        expectedBool: true,
        actualBool: containsRTF
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "session_unlocked_password_protected_export_boundary",
        status: protectedStateAccepted ? "passed" : "failed",
        expectedBool: true,
        actualBool: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_rtfd_filewrapper+artifact_tree_hash+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func openNoteInPages(
    _ source: NotesNoteRTFDExportSource,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.open-in-pages"
    let files = try normalizedNotesRTFDExportFiles(source.files)
    let totalByteCount = notesRTFDTotalByteCount(files)
    let treeSHA256 = notesRTFDTreeSHA256(files)
    var summary: [String: String] = [
      "id": source.noteID,
      "title": source.title ?? "",
      "application": "Pages",
      "file_count": "\(files.count)",
      "total_byte_count": "\(totalByteCount)",
      "tree_sha256": treeSHA256,
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    let scope = "notes-open-in-pages:\(sha256Hex("\(source.noteID)|\(files.count)|\(totalByteCount)|\(treeSHA256)"))"

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "Notes open in Pages dispatches a staged RTFD package to Pages and requires `--allow-external-dispatch`."
    )

    let dispatch = try pagesDispatcher.openRTFDPackage(files, suggestedTitle: source.title ?? source.noteID)
    let verification = try notesPagesOpenVerification(
      source: source,
      expectedFiles: files,
      dispatch: dispatch
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes open in Pages verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }

    return try result(
      NotesPagesOpenResult(
        operation: operation,
        submitted: true,
        noteID: source.noteID,
        title: source.title,
        isPasswordProtected: source.isPasswordProtected,
        isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
        applicationName: dispatch.applicationName,
        fileCount: files.count,
        totalByteCount: totalByteCount,
        treeSHA256: treeSHA256,
        stagedPackagePathSHA256: dispatch.stagedPackagePathSHA256,
        verification: verification
      ),
      human: "\(operation) submitted=true",
      options: options
    )
  }

  private func notesPagesOpenVerification(
    source: NotesNoteRTFDExportSource,
    expectedFiles: [NotesNoteRTFDExportFile],
    dispatch: NotesPagesOpenDispatchRecord
  ) throws -> NotesMutationVerificationReport {
    let expectedTotalByteCount = notesRTFDTotalByteCount(expectedFiles)
    let expectedTreeSHA256 = notesRTFDTreeSHA256(expectedFiles)
    let noteStillPresent = try implementation.readNote(id: source.noteID) != nil
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
    let checks = [
      verificationBoolCheck(
        name: "application_pages",
        expected: true,
        actual: dispatch.applicationName == "Pages"
      ),
      verificationBoolCheck(
        name: "staged_path_hash",
        expected: true,
        actual: dispatch.stagedPackagePathSHA256.count == 64
      ),
      NotesVerificationCheckRecord(
        name: "file_count",
        status: dispatch.fileCount == expectedFiles.count ? "passed" : "failed",
        expectedLength: expectedFiles.count,
        actualLength: dispatch.fileCount
      ),
      NotesVerificationCheckRecord(
        name: "total_byte_count",
        status: dispatch.totalByteCount == expectedTotalByteCount ? "passed" : "failed",
        expectedLength: expectedTotalByteCount,
        actualLength: dispatch.totalByteCount
      ),
      NotesVerificationCheckRecord(
        name: "tree_sha256",
        status: dispatch.treeSHA256 == expectedTreeSHA256 ? "passed" : "failed",
        expectedSHA256: expectedTreeSHA256,
        actualSHA256: dispatch.treeSHA256
      ),
      verificationBoolCheck(
        name: "rtf_member",
        expected: true,
        actual: notesRTFDContainsRTFFile(expectedFiles)
      ),
      verificationBoolCheck(
        name: "session_unlocked_password_protected_external_dispatch_boundary",
        expected: true,
        actual: protectedStateAccepted
      ),
      verificationBoolCheck(
        name: "note_readback",
        expected: true,
        actual: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_write_v1",
      operation: "notes.open-in-pages",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_rtfd_filewrapper+rtfd_tree_hash+external_pages_dispatch+note_readback",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func printNote(
    _ source: NotesNotePDFExportSource,
    printerName: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.print"
    let pdfSHA256 = sha256Hex(source.data)
    var summary: [String: String] = [
      "note_id": source.noteID,
      "title": source.title ?? "",
      "printer": printerName,
      "pdf_byte_count": "\(source.data.count)",
      "pdf_sha256": pdfSHA256,
      "is_password_protected": source.isPasswordProtected ? "true" : "false",
    ]
    if let locked = source.isPasswordProtectedAndLocked {
      summary["is_password_protected_and_locked"] = locked ? "true" : "false"
    }
    let scope = "notes-print:\(sha256Hex("\(source.noteID)|\(printerName)|\(source.data.count)|\(pdfSHA256)"))"

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "Notes printing submits to the system print service and requires `--allow-external-dispatch`."
    )

    let jobID = try printDispatcher.submitPDF(
      source.data,
      suggestedFilename: source.title ?? source.noteID,
      printerName: printerName
    )
    let verification = notesPrintVerification(
      source: source,
      printerName: printerName,
      jobID: jobID,
      pdfSHA256: pdfSHA256
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes print verification failed.",
        details: [
          "operation": operation,
          "target_id_sha256": verification.targetIDSHA256,
          "failed_checks": verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
        ]
      )
    }
    return try result(
      NotesPrintSubmissionResult(
        operation: operation,
        submitted: true,
        noteID: source.noteID,
        title: source.title,
        isPasswordProtected: source.isPasswordProtected,
        isPasswordProtectedAndLocked: source.isPasswordProtectedAndLocked,
        printerName: printerName,
        jobID: jobID,
        pdfByteCount: source.data.count,
        pdfSHA256: pdfSHA256,
        verification: verification
      ),
      human: "\(operation) submitted=true",
      options: options
    )
  }

  private func notesPrintVerification(
    source: NotesNotePDFExportSource,
    printerName: String,
    jobID: String,
    pdfSHA256: String
  ) -> NotesMutationVerificationReport {
    let pdfHeader = source.data.count >= 4 && source.data.prefix(4) == Data("%PDF".utf8)
    let protectedStateAccepted = source.isPasswordProtected == false
      || source.isPasswordProtectedAndLocked == false
    let checks = [
      NotesVerificationCheckRecord(
        name: "pdf_header",
        status: pdfHeader ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfHeader
      ),
      NotesVerificationCheckRecord(
        name: "pdf_byte_count",
        status: source.data.isEmpty ? "failed" : "passed",
        expectedLength: 1,
        actualLength: source.data.count
      ),
      NotesVerificationCheckRecord(
        name: "pdf_sha256",
        status: pdfSHA256.isEmpty ? "failed" : "passed",
        actualSHA256: pdfSHA256
      ),
      NotesVerificationCheckRecord(
        name: "printer",
        status: printerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          ? "failed" : "passed"
      ),
      NotesVerificationCheckRecord(
        name: "print_job_id",
        status: jobID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          ? "failed" : "passed"
      ),
      verificationBoolCheck(
        name: "session_unlocked_password_protected_external_dispatch_boundary",
        expected: true,
        actual: protectedStateAccepted
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_print_v1",
      operation: "notes.print",
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_pdf_generation+external_print_dispatch",
      targetIDSHA256: sha256Hex(source.noteID),
      checks: checks
    )
  }

  private func noteExporter() throws -> any NotesNoteExporting {
    guard let noteExporter = implementation as? any NotesNoteExporting else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes export commands require a private-framework note exporter.",
        details: [
          "capability": "note_export",
          "required_module": "NotesEditor,NotesUI",
        ]
      )
    }
    return noteExporter
  }

  private func richImporter() throws -> any NotesRichImporting {
    guard let richImporter = implementation as? any NotesRichImporting else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes rich import commands require a private-framework rich import writer.",
        details: [
          "capability": "rich_import",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return richImporter
  }

  private func richReplacer() throws -> any NotesRichReplacing {
    guard let richReplacer = implementation as? any NotesRichReplacing else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes rich replace commands require a private-framework rich text writer.",
        details: [
          "capability": "rich_replace",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return richReplacer
  }

  private func markdownImporter() throws -> any NotesMarkdownImporting {
    guard let markdownImporter = implementation as? any NotesMarkdownImporting else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Markdown import commands require a private-framework Markdown semantic import writer.",
        details: [
          "capability": "markdown_semantic_import",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return markdownImporter
  }

  private func enexImporter() throws -> any NotesENEXImporting {
    guard let enexImporter = implementation as? any NotesENEXImporting else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes ENEX import commands require a private-framework ENEX import writer.",
        details: [
          "capability": "enex_import",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return enexImporter
  }

  private func verifiedMarkdownImportResult(_ result: NotesMarkdownImportResult) throws
    -> NotesMarkdownImportResult
  {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes Markdown import verification failed.",
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

  private func verifiedRichImportResult(_ result: NotesRichImportResult) throws -> NotesRichImportResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes rich import verification failed.",
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

  private func verifiedRichReplaceResult(_ result: NotesRichReplaceResult) throws -> NotesRichReplaceResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes rich replace verification failed.",
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

  private func verifiedENEXImportResult(_ result: NotesENEXImportResult) throws -> NotesENEXImportResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes ENEX import verification failed.",
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

  private func verifiedFolderImportResult(_ result: NotesFolderImportResult) throws -> NotesFolderImportResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes folder import verification failed.",
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
