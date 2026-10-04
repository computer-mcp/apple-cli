import Foundation
import Utility

extension NotesCommand {
  func runSmartFolders(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["smart-folders", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let smartFolders = try smartFolderReader().listSmartFolders(
        account: options.targetOption("account"),
        limit: try commandLimit(options)
      )
      return try result(
        NotesSmartFoldersResponse(smartFolders: smartFolders),
        human: smartFolders.map { folder in
          [
            folder.id,
            folder.accountName,
            folder.name,
            folder.visibleNoteCount.map(String.init) ?? "",
          ].joined(separator: "\t")
        }.joined(separator: "\n"),
        options: options
      )
    case ["smart-folders", "notes"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["folder", "account"])
      let smartFolder = try smartFolderIdentity(
        selector: try requiredOption("folder", options: options),
        account: options.targetOption("account")
      )
      let notes = try smartFolderReader().listSmartFolderNotes(
        smartFolderID: smartFolder.id,
        limit: try commandLimit(options)
      )
      return try result(
        NotesSmartFolderNotesResponse(
          smartFolder: smartFolder,
          notes: notes,
          visibleNoteCount: smartFolder.visibleNoteCount
        ),
        human: notes.map { note in
          [
            note.id,
            note.accountName,
            note.folderName,
            note.title,
          ].joined(separator: "\t")
        }.joined(separator: "\n"),
        options: options
      )
    case ["smart-folders", "criteria"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["folder", "account"])
      let smartFolder = try smartFolderIdentity(
        selector: try requiredOption("folder", options: options),
        account: options.targetOption("account")
      )
      let notes = try smartFolderReader().listSmartFolderNotes(
        smartFolderID: smartFolder.id,
        limit: try commandLimit(options)
      )
      let verification = try verifySmartFolderCriteria(smartFolder: smartFolder, notes: notes)
      return try result(
        NotesSmartFolderCriteriaResponse(
          smartFolder: smartFolder,
          criteria: smartFolder.criteria,
          notes: notes,
          visibleNoteCount: smartFolder.visibleNoteCount,
          verification: verification
        ),
        human: [
          smartFolder.id,
          smartFolder.accountName,
          smartFolder.name,
          smartFolder.criteria?.queryKind ?? "",
          String(notes.count),
          smartFolder.visibleNoteCount.map(String.init) ?? "",
        ].joined(separator: "\t"),
        options: options
      )
    case ["smart-folders", "explain"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["folder", "account"])
      let smartFolder = try smartFolderIdentity(
        selector: try requiredOption("folder", options: options),
        account: options.targetOption("account")
      )
      let notes = try smartFolderReader().listSmartFolderNotes(
        smartFolderID: smartFolder.id,
        limit: try commandLimit(options)
      )
      let explanation = smartFolderCriteriaExplanation(smartFolder.criteria)
      let verification = try verifySmartFolderCriteriaExplanation(
        smartFolder: smartFolder,
        notes: notes,
        explanation: explanation
      )
      return try result(
        NotesSmartFolderCriteriaExplanationResponse(
          smartFolder: smartFolder,
          criteria: smartFolder.criteria,
          explanation: explanation,
          notes: notes,
          visibleNoteCount: smartFolder.visibleNoteCount,
          verification: verification
        ),
        human: [
          smartFolder.id,
          smartFolder.accountName,
          smartFolder.name,
          explanation.queryKind,
          String(explanation.filterCount),
          String(explanation.multiCondition),
          String(notes.count),
          smartFolder.visibleNoteCount.map(String.init) ?? "",
        ].joined(separator: "\t"),
        options: options
      )
    case ["smart-folders", "reasoning"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["folder", "account"])
      let smartFolder = try smartFolderIdentity(
        selector: try requiredOption("folder", options: options),
        account: options.targetOption("account")
      )
      let notes = try smartFolderReader().listSmartFolderNotes(
        smartFolderID: smartFolder.id,
        limit: try commandLimit(options)
      )
      let explanation = smartFolderCriteriaExplanation(smartFolder.criteria)
      let matches = try self.smartFolderMatchReasonRecords(
        notes: notes,
        criteria: smartFolder.criteria,
        explanation: explanation
      )
      let verification = try self.verifySmartFolderMatchReasoning(
        smartFolder: smartFolder,
        notes: notes,
        explanation: explanation,
        matches: matches
      )
      return try result(
        NotesSmartFolderMatchReasoningResponse(
          smartFolder: smartFolder,
          criteria: smartFolder.criteria,
          explanation: explanation,
          matches: matches,
          visibleNoteCount: smartFolder.visibleNoteCount,
          verification: verification
        ),
        human: matches.map { match in
          [
            match.note.id,
            match.note.accountName,
            match.note.folderName,
            match.note.title,
            match.matchStatus,
            match.criteriaFamilies.joined(separator: ","),
          ].joined(separator: "\t")
        }.joined(separator: "\n"),
        options: options
      )
    case ["smart-folders", "audit"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let smartFolders = try smartFolderReader().listSmartFolders(
        account: options.targetOption("account"),
        limit: try commandLimit(options)
      )
      let records = smartFolders.map { smartFolder in
        NotesSmartFolderCriteriaAuditRecord(
          smartFolder: smartFolder,
          explanation: smartFolderCriteriaExplanation(smartFolder.criteria)
        )
      }
      let summary = smartFolderCriteriaAuditSummary(records)
      let verification = verifySmartFolderCriteriaAudit(records: records, summary: summary)
      return try result(
        NotesSmartFolderCriteriaAuditResponse(
          summary: summary,
          records: records,
          verification: verification
        ),
        human: [
          "smart_folders: \(summary.smartFolderCount)",
          "criteria_summaries: \(summary.criteriaSummaryCount)",
          "multi_condition: \(summary.multiConditionCount)",
          "raw_value_hashes: \(summary.rawValueHashCount)",
          "gated_mutations: \(summary.gatedMutationFamilies.joined(separator: ","))",
        ].joined(separator: "\n"),
        options: options
      )
    case ["smart-folders", "workflow", "audit"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try smartFolderWorkflowAudit(options)
    case ["smart-folders", "filters", "audit"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try smartFolderFilterCatalogAudit(options)
    case ["smart-folders", "filters", "add"]:
      _ = try validateSmartFolderFilterMutationOptions(
        options,
        requiresCriteria: true,
        requiresOrdinal: false
      )
      return try smartFolderFilterMutation(
        mutationKind: "add",
        operation: "notes.smart-folders.filters.add",
        appleCapability: "add_smart_folder_filter",
        options: options
      )
    case ["smart-folders", "filters", "update"]:
      _ = try validateSmartFolderFilterMutationOptions(
        options,
        requiresCriteria: true,
        requiresOrdinal: true
      )
      return try smartFolderFilterMutation(
        mutationKind: "update",
        operation: "notes.smart-folders.filters.update",
        appleCapability: "change_smart_folder_filter",
        options: options
      )
    case ["smart-folders", "filters", "remove"]:
      _ = try validateSmartFolderFilterMutationOptions(
        options,
        requiresCriteria: false,
        requiresOrdinal: true
      )
      return try smartFolderFilterMutation(
        mutationKind: "remove",
        operation: "notes.smart-folders.filters.remove",
        appleCapability: "remove_smart_folder_filter",
        options: options
      )
    case ["smart-folders", "export-criteria"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account", "output"])
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateNotesSmartFolderCriteriaExportDestination(destinationPath)
      let smartFolder = try smartFolderIdentity(
        selector: try requiredOption("folder", options: options),
        account: options.targetOption("account")
      )
      let source = try smartFolderReader().exportSmartFolderCriteria(smartFolderID: smartFolder.id)
      return try exportSmartFolderCriteria(source, destinationPath: destinationPath, options: options)
    case ["smart-folders", "create"]:
      try validateTargetOptions(options, allowedOptions: ["name", "account", "tag", "match"])
      try validateMutationIntent(options)
      let draft = try smartFolderCreateDraft(options)
      return try mutation(
        operation: "notes.smart-folders.create",
        scopeDigest: smartFolderCreateScopeDigest(draft),
        summary: smartFolderCreateSummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().createSmartFolder(draft)
        let verification = try mutationVerifier().verifySmartFolderCreate(
          operation: "notes.smart-folders.create",
          draft: draft,
          result: write
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.create",
            changed: write.changed,
            smartFolder: write.smartFolder,
            tag: write.tag,
            matchingNoteCount: draft.matchingNoteCount,
            verification: verification
          ))
      }
    case ["smart-folders", "update"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account", "tag", "match"])
      try validateMutationIntent(options)
      let draft = try smartFolderUpdateDraft(options)
      return try mutation(
        operation: "notes.smart-folders.update",
        scopeDigest: smartFolderUpdateScopeDigest(draft),
        summary: smartFolderUpdateSummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().updateSmartFolder(draft)
        let verification = try mutationVerifier().verifySmartFolderUpdate(
          operation: "notes.smart-folders.update",
          draft: draft,
          result: write
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.update",
            changed: write.changed,
            smartFolder: write.smartFolder,
            tag: write.tag,
            matchingNoteCount: draft.matchingNoteCount,
            verification: verification
          ))
      }
    case ["smart-folders", "create-criteria"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "name", "account", "criteria", "match", "criteria-folder", "include-criteria-folder", "exclude-criteria-folder",
          "date", "start-date", "end-date", "relative-amount", "relative-unit", "participant-user-id",
        ],
        allowedFlags: ["include-recently-deleted"]
      )
      try validateMutationIntent(options)
      let draft = try smartFolderBuiltInCriteriaCreateDraft(options)
      return try mutation(
        operation: "notes.smart-folders.create-criteria",
        scopeDigest: smartFolderBuiltInCriteriaCreateScopeDigest(draft),
        summary: smartFolderBuiltInCriteriaCreateSummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().createSmartFolderBuiltInCriteria(draft)
        let notes = try smartFolderReader().listSmartFolderNotes(
          smartFolderID: write.smartFolder.id,
          limit: 2_000
        )
        let verification = try mutationVerifier().verifySmartFolderBuiltInCriteriaCreate(
          operation: "notes.smart-folders.create-criteria",
          draft: draft,
          result: write,
          matchingNotes: notes
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.create-criteria",
            changed: write.changed,
            smartFolder: write.smartFolder,
            criteriaKind: draft.criteriaKind,
            criteriaKinds: draft.criteriaKinds,
            matchingNoteCount: notes.count,
            verification: verification
          ))
      }
    case ["smart-folders", "update-criteria"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "folder", "account", "criteria", "match", "criteria-folder", "include-criteria-folder", "exclude-criteria-folder",
          "date", "start-date", "end-date", "relative-amount", "relative-unit", "participant-user-id",
        ],
        allowedFlags: ["include-recently-deleted"]
      )
      try validateMutationIntent(options)
      let draft = try smartFolderBuiltInCriteriaUpdateDraft(options)
      return try mutation(
        operation: "notes.smart-folders.update-criteria",
        scopeDigest: smartFolderBuiltInCriteriaUpdateScopeDigest(draft),
        summary: smartFolderBuiltInCriteriaUpdateSummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().updateSmartFolderBuiltInCriteria(draft)
        let notes = try smartFolderReader().listSmartFolderNotes(
          smartFolderID: write.smartFolder.id,
          limit: 2_000
        )
        let verification = try mutationVerifier().verifySmartFolderBuiltInCriteriaUpdate(
          operation: "notes.smart-folders.update-criteria",
          draft: draft,
          result: write,
          matchingNotes: notes
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.update-criteria",
            changed: write.changed,
            smartFolder: write.smartFolder,
            criteriaKind: draft.criteriaKind,
            criteriaKinds: draft.criteriaKinds,
            matchingNoteCount: notes.count,
            verification: verification
          ))
      }
    case ["smart-folders", "duplicate"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account", "name"])
      try validateMutationIntent(options)
      let draft = try smartFolderDuplicateDraft(options)
      return try mutation(
        operation: "notes.smart-folders.duplicate",
        scopeDigest: smartFolderDuplicateScopeDigest(draft),
        summary: smartFolderDuplicateSummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().duplicateSmartFolder(draft)
        let verification = try mutationVerifier().verifySmartFolderDuplicate(
          operation: "notes.smart-folders.duplicate",
          draft: draft,
          result: write
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.duplicate",
            changed: write.changed,
            smartFolder: write.smartFolder,
            sourceSmartFolder: write.sourceSmartFolder,
            matchingNoteCount: draft.sourceMatchingNoteCount,
            sourceMatchingNoteCount: draft.sourceMatchingNoteCount,
            verification: verification
          ))
      }
    case ["smart-folders", "copy-criteria"]:
      try validateTargetOptions(options, allowedOptions: ["from", "to", "account"])
      try validateMutationIntent(options)
      let draft = try smartFolderCriteriaCopyDraft(options)
      return try mutation(
        operation: "notes.smart-folders.copy-criteria",
        scopeDigest: smartFolderCriteriaCopyScopeDigest(draft),
        summary: smartFolderCriteriaCopySummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().copySmartFolderCriteria(draft)
        let verification = try mutationVerifier().verifySmartFolderCriteriaCopy(
          operation: "notes.smart-folders.copy-criteria",
          draft: draft,
          result: write
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.copy-criteria",
            changed: write.changed,
            smartFolder: write.smartFolder,
            sourceSmartFolder: write.sourceSmartFolder,
            matchingNoteCount: draft.sourceMatchingNoteCount,
            sourceMatchingNoteCount: draft.sourceMatchingNoteCount,
            verification: verification
          ))
      }
    case ["smart-folders", "import-criteria"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account", "file"])
      try validateMutationIntent(options)
      let draft = try smartFolderCriteriaImportDraft(options)
      return try mutation(
        operation: "notes.smart-folders.import-criteria",
        scopeDigest: smartFolderCriteriaImportScopeDigest(draft),
        summary: smartFolderCriteriaImportSummary(draft),
        options: options
      ) {
        let write = try smartFolderMutator().importSmartFolderCriteria(draft)
        let verification = try mutationVerifier().verifySmartFolderCriteriaImport(
          operation: "notes.smart-folders.import-criteria",
          draft: draft,
          result: write
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.import-criteria",
            changed: write.changed,
            smartFolder: write.smartFolder,
            sourceByteCount: draft.sourceByteCount,
            sourceSHA256: draft.sourceSHA256,
            verification: verification
          ))
      }
    case ["smart-folders", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account", "name"])
      try validateMutationIntent(options)
      let draft = try smartFolderRenameDraft(options)
      return try mutation(
        operation: "notes.smart-folders.rename",
        scopeDigest: smartFolderRenameScopeDigest(draft),
        summary: smartFolderRenameSummary(draft),
        options: options
      ) {
        let smartFolder = try smartFolderMutator().renameSmartFolder(draft)
        let verification = try mutationVerifier().verifySmartFolderRename(
          operation: "notes.smart-folders.rename",
          draft: draft,
          resultSmartFolder: smartFolder,
          changed: true
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.rename",
            changed: true,
            smartFolder: smartFolder,
            verification: verification
          ))
      }
    case ["smart-folders", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account"])
      try validateMutationIntent(options)
      let draft = try smartFolderDeleteDraft(options)
      return try mutation(
        operation: "notes.smart-folders.delete",
        scopeDigest: smartFolderDeleteScopeDigest(draft),
        summary: smartFolderDeleteSummary(draft),
        options: options
      ) {
        let changed = try smartFolderMutator().deleteSmartFolder(draft)
        let verification = try mutationVerifier().verifySmartFolderDelete(
          operation: "notes.smart-folders.delete",
          draft: draft,
          changed: changed
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.delete",
            changed: changed,
            deletedID: draft.smartFolderID,
            verification: verification
          ))
      }
    case ["smart-folders", "convert-folder"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "account"])
      try validateMutationIntent(options)
      let draft = try smartFolderFolderConversionDraft(options)
      return try mutation(
        operation: "notes.smart-folders.convert-folder",
        scopeDigest: smartFolderFolderConversionScopeDigest(draft),
        summary: smartFolderFolderConversionSummary(draft),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection", "--allow-persistent-action"],
        dryRunNotes: [
          "Execution converts one concrete folder into a Smart Folder.",
          "Execution moves the selected folder's notes to the account default Notes folder.",
          "Execution tags moved notes with the original folder name and removes the original folder.",
          "This operation follows Apple's irreversible conversion semantics and cannot be undone by the CLI.",
        ]
      ) {
        let write = try smartFolderMutator().convertFolderToSmartFolder(draft)
        let verification = try mutationVerifier().verifySmartFolderFolderConversion(
          operation: "notes.smart-folders.convert-folder",
          draft: draft,
          result: write
        )
        return try verifiedSmartFolderMutationResult(
          NotesSmartFolderMutationResult(
            operation: "notes.smart-folders.convert-folder",
            changed: write.changed,
            smartFolder: write.smartFolder,
            tag: write.tag,
            matchingNoteCount: write.movedNoteCount,
            convertedFolderID: write.sourceFolderID,
            convertedFolderName: write.sourceFolderName,
            targetFolderID: write.targetFolderID,
            targetFolderName: write.targetFolderName,
            movedNoteCount: write.movedNoteCount,
            taggedNoteCount: write.taggedNoteCount,
            noteIDHashes: write.noteIDHashes,
            verification: verification
          ))
      }    default:
      return nil
    }
  }

  func smartFolderIdentity(selector: String, account: String?) throws -> NotesSmartFolderRecord {
    let smartFolders = try smartFolderReader().listSmartFolders(account: account, limit: 2_000)
    if let match = smartFolders.first(where: { $0.id == selector }) {
      return match
    }

    let nameMatches = smartFolders.filter {
      $0.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if nameMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Smart Folder selector matched multiple Notes Smart Folders.",
        details: ["smart_folder_sha256": sha256Hex(selector)]
      )
    }

    guard let match = nameMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Smart Folder selector did not match any Notes Smart Folder.",
        details: ["smart_folder_sha256": sha256Hex(selector)]
      )
    }
    return match
  }

  private func smartFolderCriteriaAuditSummary(
    _ records: [NotesSmartFolderCriteriaAuditRecord]
  ) -> NotesSmartFolderCriteriaAuditSummary {
    var filterKindCounts: [String: Int] = [:]
    var supportedReadFamilies = Set<String>()
    var gatedMutationFamilies = Set<String>()
    var rawValueHashCount = 0
    for record in records {
      for family in record.explanation.supportedReadFamilies {
        supportedReadFamilies.insert(family)
      }
      for family in record.explanation.gatedMutationFamilies {
        gatedMutationFamilies.insert(family)
      }
      for filter in record.explanation.filters {
        filterKindCounts[filter.kind, default: 0] += 1
        if filter.rawValueSHA256 != nil {
          rawValueHashCount += 1
        }
      }
    }
    return NotesSmartFolderCriteriaAuditSummary(
      smartFolderCount: records.count,
      queryPresentCount: records.filter { $0.smartFolder.queryPresent }.count,
      criteriaSummaryCount: records.filter { $0.smartFolder.criteria != nil }.count,
      editableCount: records.filter { $0.smartFolder.isEditable == true }.count,
      multiConditionCount: records.filter { $0.explanation.multiCondition }.count,
      predicateHashCount: records.filter { $0.explanation.predicateHashPresent }.count,
      tagSelectionCount: records.filter { $0.explanation.tagSelectionPresent }.count,
      rawValueHashCount: rawValueHashCount,
      filterKindCounts: filterKindCounts
        .map { NotesSmartFolderCriteriaAuditKindCount(kind: $0.key, count: $0.value) }
        .sorted { $0.kind.localizedStandardCompare($1.kind) == .orderedAscending },
      supportedReadFamilies: supportedReadFamilies.sorted(),
      gatedMutationFamilies: gatedMutationFamilies.sorted()
    )
  }

  private func smartFolderWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.smart-folders.workflow.audit"
    let records = notesSmartFolderWorkflowAuditRecords()
    let summary = notesSmartFolderWorkflowAuditSummary(records)
    let verification = verifySmartFolderWorkflowAudit(records: records, summary: summary)
    let response = NotesSmartFolderWorkflowAuditResponse(
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

  private func smartFolderFilterCatalogAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.smart-folders.filters.audit"
    let records = notesSmartFolderFilterCatalogAuditRecords()
    let summary = notesSmartFolderFilterCatalogAuditSummary(records)
    let verification = verifySmartFolderFilterCatalogAudit(records: records, summary: summary)
    let response = NotesSmartFolderFilterCatalogAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_filter_records: \(summary.supportedRecordCount), gated_filter_records: \(summary.gatedRecordCount), rejected_filter_records: \(summary.rejectedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesSmartFolderFilterCatalogAuditRecords() -> [NotesSmartFolderFilterCatalogAuditRecord] {
    let supported = [
      smartFolderSelectedTagCatalogItem(),
      smartFolderSelectedMultiTagCatalogItem(),
      smartFolderSelectedAnyTagCatalogItem(),
    ]
      + notesSmartFolderBuiltInCriteriaKinds.map {
      smartFolderSupportedCriteriaCatalogItem(kind: $0)
    }
    let rejected = smartFolderRejectedCriteriaCatalogItems()
    return (supported + rejected).enumerated().map { index, item in
      NotesSmartFolderFilterCatalogAuditRecord(
        ordinal: index + 1,
        filterFamily: item.filterFamily,
        criteriaKind: item.criteriaKind,
        appleFilter: item.appleFilter,
        valueShape: item.valueShape,
        status: item.status,
        command: item.command,
        implementationMechanism: item.implementationMechanism,
        requiredImplementation: item.requiredImplementation,
        requiredVerifier: item.requiredVerifier,
        combinationSupport: item.combinationSupport,
        backendCalls: "none",
        privacyBoundary: item.privacyBoundary,
        reason: item.reason
      )
    }
  }

  private struct SmartFolderFilterCatalogItem {
    var filterFamily: String
    var criteriaKind: String
    var appleFilter: String
    var valueShape: String
    var status: String
    var command: String
    var implementationMechanism: String
    var requiredImplementation: String
    var requiredVerifier: String
    var combinationSupport: String
    var privacyBoundary: String
    var reason: String
  }

  private func smartFolderSelectedTagCatalogItem() -> SmartFolderFilterCatalogItem {
    SmartFolderFilterCatalogItem(
      filterFamily: "tags",
      criteriaKind: "tag-selected-single",
      appleFilter: "Tags",
      valueShape: "one_existing_tag",
      status: "supported",
      command: "smart-folders create/update --tag TAG",
      implementationMechanism: "typed_private_notes_framework_tag_selection_query",
      requiredImplementation: "ICTagSelection+ICQuery.queryForNotes(matchingTagSelection:)+ICFolder.smartFolderWithQuery",
      requiredVerifier: "private_tag_selection_readback+matching_note_resolution",
      combinationSupport: "single_tag_command_only",
      privacyBoundary: "tag_selector_and_tag_hashes_without_note_bodies",
      reason: "Single selected-tag Smart Folder create/update is accepted with private tag-selection readback."
    )
  }

  private func smartFolderSelectedMultiTagCatalogItem() -> SmartFolderFilterCatalogItem {
    SmartFolderFilterCatalogItem(
      filterFamily: "tags",
      criteriaKind: "tag-selected-multiple",
      appleFilter: "Tags",
      valueShape: "multiple_selected_tags_all_operator",
      status: "supported",
      command: "smart-folders create/update --tag TAG[,TAG...]",
      implementationMechanism: "typed_private_notes_framework_multi_tag_selection_query",
      requiredImplementation: "ICTagSelection.addObjectID+mode=all_tagged+tagOperator=all+ICQuery.queryForNotes(matchingTagSelection:)",
      requiredVerifier: "private_multi_tag_selection_operator_mode_readback+matching_note_resolution",
      combinationSupport: "single_tag_selection_query",
      privacyBoundary: "tag_selector_hashes_without_raw_private_values_or_note_bodies",
      reason: "Multiple selected tags are accepted for Smart Folder create/update through explicit All-selected-tags private tag-selection readback."
    )
  }

  private func smartFolderSelectedAnyTagCatalogItem() -> SmartFolderFilterCatalogItem {
    SmartFolderFilterCatalogItem(
      filterFamily: "tags",
      criteriaKind: "tag-selected-multiple-any",
      appleFilter: "Tags",
      valueShape: "multiple_selected_tags_any_operator",
      status: "supported",
      command: "smart-folders create/update --tag TAG[,TAG...] --match any",
      implementationMechanism: "typed_private_notes_framework_multi_tag_any_selection_query",
      requiredImplementation: "ICTagSelection.addObjectID+mode=all_tagged+tagOperator=any+ICQuery.queryForNotes(matchingTagSelection:)",
      requiredVerifier: "private_multi_tag_selection_operator_mode_readback+matching_note_resolution",
      combinationSupport: "single_tag_selection_query",
      privacyBoundary: "tag_selector_hashes_without_raw_private_values_or_note_bodies",
      reason: "Multiple selected tags are accepted for Smart Folder create/update through explicit Any-selected-tags private tag-selection readback."
    )
  }

  private func smartFolderSupportedCriteriaCatalogItem(kind: String) -> SmartFolderFilterCatalogItem {
    let metadata = smartFolderSupportedCriteriaCatalogMetadata(kind: kind)
    return SmartFolderFilterCatalogItem(
      filterFamily: metadata.filterFamily,
      criteriaKind: kind,
      appleFilter: metadata.appleFilter,
      valueShape: metadata.valueShape,
      status: "supported",
      command: metadata.command,
      implementationMechanism: metadata.implementationMechanism,
      requiredImplementation: metadata.requiredImplementation,
      requiredVerifier: metadata.requiredVerifier,
      combinationSupport: metadata.combinationSupport,
      privacyBoundary: metadata.privacyBoundary,
      reason: metadata.reason
    )
  }

  private func smartFolderSupportedCriteriaCatalogMetadata(kind: String) -> (
    filterFamily: String,
    appleFilter: String,
    valueShape: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    combinationSupport: String,
    privacyBoundary: String,
    reason: String
  ) {
    if smartFolderUntaggedCriteriaKind(kind) {
      return (
        "tags",
        "Tags",
        "untagged_notes_only",
        "smart-folders create-criteria/update-criteria --criteria untagged",
        "typed_private_notes_framework_tag_selection_mode_query",
        "ICTagSelection.mode=all_untagged+ICQuery.queryForNotes(matchingTagSelection:)",
        "private_tag_selection_mode_readback+matching_note_resolution",
        "single_only",
        "tag_absence_counts_without_note_bodies_or_tag_text",
        "Untagged Notes Only is accepted through private tag-selection mode readback."
      )
    }
    if let descriptor = smartFolderDateCriteriaDescriptor(kind) {
      let family = descriptor.filterKind == "date_created" ? "date_created" : "date_edited"
      let appleFilter = descriptor.filterKind == "date_created" ? "Date Created" : "Date Edited"
      let valueShape = descriptor.parameterKind ?? "relative_builtin_range"
      return (
        family,
        appleFilter,
        valueShape,
        "smart-folders create-criteria/update-criteria --criteria \(kind)",
        "typed_private_notes_framework_date_filter_selection",
        "ICDateFilterTypeSelection+ICFilterSelection+ICQuery.queryForNotes(matchingFilterSelection:)",
        "private_date_filter_readback+matching_note_resolution",
        "all_any_supported_with_promoted_filters",
        "date_parameters_and_hashes_without_note_content",
        "Created/edited date criteria are accepted with private date selection and parameter readback."
      )
    }
    if smartFolderFolderCriteriaInclusionType(kind) != nil {
      return (
        "folders",
        "Folder",
        kind == "folder" ? "selected_folders" : "excluded_folders",
        "smart-folders create-criteria/update-criteria --criteria \(kind) --criteria-folder FOLDER",
        "typed_private_notes_framework_folder_filter_selection",
        "ICFoldersFilterTypeSelection.folderIdentifiers+ICFilterSelection",
        "private_folder_filter_readback+matching_note_resolution",
        "all_any_supported_with_promoted_filters",
        "folder_identifier_hashes_without_folder_contents_or_note_bodies",
        "Folder and Not Folder criteria are accepted with private folder-object and matching-note readback."
      )
    }
    if smartFolderParticipantCriteriaKind(kind) {
      return (
        kind,
        kind == "participants" ? "Participants" : "Mentions",
        "one_opaque_participant_user_id",
        "smart-folders create-criteria/update-criteria --criteria \(kind) --participant-user-id USER_ID",
        "typed_private_notes_framework_participant_mention_filter_selection",
        kind == "participants" ? "ICParticipantsFilterTypeSelection" : "ICMentionsFilterTypeSelection",
        "private_participant_or_mention_hash_readback+matching_note_resolution",
        "all_any_supported_with_promoted_filters",
        "participant_user_hashes_without_names_handles_or_mention_text",
        "Selected participant and mentioned-participant filters are accepted with opaque user identifiers hashed in output."
      )
    }
    if smartFolderBuiltInCriteriaAttachmentSelectionType(kind) != nil {
      return (
        "attachments",
        "Attachments",
        kind,
        "smart-folders create-criteria/update-criteria --criteria \(kind)",
        "typed_private_notes_framework_attachment_filter_selection",
        "ICAttachmentsFilterTypeSelection+ICFilterSelection",
        "private_attachment_filter_readback+matching_note_resolution",
        "all_any_supported_with_promoted_filters",
        "attachment_family_counts_without_attachment_bytes_or_note_bodies",
        "Attachment presence and attachment-family criteria are accepted with private filter readback."
      )
    }
    if smartFolderBuiltInCriteriaChecklistSelectionType(kind) != nil {
      return (
        "checklists",
        "Checklists",
        kind,
        "smart-folders create-criteria/update-criteria --criteria \(kind)",
        "typed_private_notes_framework_checklist_filter_selection",
        "ICChecklistFilterTypeSelection+ICFilterSelection",
        "private_checklist_filter_readback+matching_note_resolution",
        "all_any_supported_with_promoted_filters",
        "checklist_counts_without_checklist_text_or_note_bodies",
        "Checklist presence/state criteria are accepted with private filter readback."
      )
    }
    switch kind {
    case "pinned", "unpinned":
      return smartFolderBooleanCatalogMetadata(
        kind: kind,
        filterFamily: "pin_state",
        appleFilter: "Pinned",
        privateType: "ICPinnedNotesFilterTypeSelection",
        valueShape: kind == "pinned" ? "is_pinned" : "is_not_pinned"
      )
    case "shared", "not-shared":
      return smartFolderBooleanCatalogMetadata(
        kind: kind,
        filterFamily: "share_state",
        appleFilter: "Shared",
        privateType: "ICSharedNotesFilterTypeSelection",
        valueShape: kind == "shared" ? "is_shared" : "is_not_shared"
      )
    case "locked", "unlocked":
      return smartFolderBooleanCatalogMetadata(
        kind: kind,
        filterFamily: "lock_state",
        appleFilter: "Locked",
        privateType: "ICPasswordProtectedNotesFilterTypeSelection",
        valueShape: kind == "locked" ? "is_locked" : "is_unlocked"
      )
    case "quick-notes", "not-quick-notes":
      return smartFolderBooleanCatalogMetadata(
        kind: kind,
        filterFamily: "quick_notes",
        appleFilter: "Quick Notes",
        privateType: "ICQuickNotesFilterTypeSelection",
        valueShape: kind == "quick-notes" ? "is_quick_note" : "is_not_quick_note"
      )
    case "math", "call", "system-paper", "recently-deleted-math":
      return (
        "special_note_kind",
        smartFolderSpecialCriteriaAppleFilter(kind),
        kind,
        "smart-folders create-criteria/update-criteria --criteria \(kind)",
        "typed_private_notes_framework_query_factory",
        "ICQuery factory for \(kind)",
        "private_query_factory_criteria_readback+matching_note_resolution",
        "all_any_supported_with_promoted_filters",
        "criteria_kind_and_counts_without_note_bodies",
        "Special note-kind criteria are accepted through typed private query factories and readback."
      )
    default:
      return (
        "unknown",
        "Unknown",
        kind,
        "none",
        "semantic_gated_boundary",
        "not_applicable",
        "not_applicable",
        "not_supported",
        "no_backend_calls",
        "Unknown criteria kinds are not accepted."
      )
    }
  }

  private func smartFolderBooleanCatalogMetadata(
    kind: String,
    filterFamily: String,
    appleFilter: String,
    privateType: String,
    valueShape: String
  ) -> (
    filterFamily: String,
    appleFilter: String,
    valueShape: String,
    command: String,
    implementationMechanism: String,
    requiredImplementation: String,
    requiredVerifier: String,
    combinationSupport: String,
    privacyBoundary: String,
    reason: String
  ) {
    (
      filterFamily,
      appleFilter,
      valueShape,
      "smart-folders create-criteria/update-criteria --criteria \(kind)",
      "typed_private_notes_framework_filter_selection",
      "\(privateType)+ICFilterSelection+ICQuery.queryForNotes(matchingFilterSelection:)",
      "private_filter_kind_inclusion_readback+matching_note_resolution",
      "all_any_supported_with_promoted_filters",
      "state_counts_without_note_bodies_or_private_objects",
      "\(appleFilter) criteria are accepted with private inclusion-state readback."
    )
  }

  private func smartFolderSpecialCriteriaAppleFilter(_ kind: String) -> String {
    switch kind {
    case "math":
      return "Math"
    case "call":
      return "Call"
    case "system-paper":
      return "Quick Note / System Paper"
    case "recently-deleted-math":
      return "Recently Deleted Math"
    default:
      return "Special Note Kind"
    }
  }

  private func smartFolderRejectedCriteriaCatalogItems() -> [SmartFolderFilterCatalogItem] {
    [
      SmartFolderFilterCatalogItem(
        filterFamily: "tags",
        criteriaKind: "tag-unsupported-operator-mode",
        appleFilter: "Tags",
        valueShape: "unsupported_operator_or_mode",
        status: "rejected",
        command: "smart-folders filters add/update --folder FOLDER --criteria tags --mode MODE",
        implementationMechanism: "apple_product_or_private_catalog_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_boundary_accounting",
        combinationSupport: "not_supported",
        privacyBoundary: "operator_mode_codes_without_raw_tag_values",
        reason: "Tag operators and modes beyond accepted All-selected-tags, Any-selected-tags, and All Untagged are not current Apple Notes guide capabilities; the CLI rejects them instead of counting them as unfinished private-framework work."
      ),
      SmartFolderFilterCatalogItem(
        filterFamily: "tags",
        criteriaKind: "tag-missing-private-hints",
        appleFilter: "Tags",
        valueShape: "criteria_without_private_tag_hints",
        status: "rejected",
        command: "smart-folders filters update --folder FOLDER --ordinal N --criteria tags",
        implementationMechanism: "private_catalog_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_boundary_accounting",
        combinationSupport: "not_supported",
        privacyBoundary: "tag_hashes_without_tag_text_or_note_bodies",
        reason: "A missing private hint is an implementation evidence shape, not a user-visible Apple Notes filter capability. Existing unreconstructable filters remain protected by runtime gates, but the catalog audit rejects this as a product baseline item."
      ),
      SmartFolderFilterCatalogItem(
        filterFamily: "participants",
        criteriaKind: "participant-identity-without-private-hash",
        appleFilter: "Participants",
        valueShape: "identity_comparison_without_hash",
        status: "rejected",
        command: "smart-folders filters update --folder FOLDER --ordinal N --criteria participants --participant-user-id USER_ID",
        implementationMechanism: "privacy_boundary_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_boundary_accounting",
        combinationSupport: "not_supported",
        privacyBoundary: "no_participant_names_handles_or_raw_ids",
        reason: "Participant identity comparison without private hash evidence would require raw identifiers; that is not an accepted Apple Notes CLI capability. Supported participant filters require opaque user IDs with hash-only evidence."
      ),
      SmartFolderFilterCatalogItem(
        filterFamily: "mentions",
        criteriaKind: "mention-object-bound-without-private-hash",
        appleFilter: "Mentions",
        valueShape: "mentioned_participant_object_comparison_without_hash",
        status: "rejected",
        command: "smart-folders filters update --folder FOLDER --ordinal N --criteria mentions --participant-user-id USER_ID",
        implementationMechanism: "privacy_boundary_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_boundary_accounting",
        combinationSupport: "not_supported",
        privacyBoundary: "no_mention_text_participant_names_handles_or_raw_ids",
        reason: "Mention object comparison without stable private hash evidence would require raw participant or mention data; that is not an accepted Apple Notes CLI capability. Supported mention filters require opaque user IDs with hash-only evidence."
      ),
      SmartFolderFilterCatalogItem(
        filterFamily: "raw_object_bound",
        criteriaKind: "raw-value-or-object-bound-filter",
        appleFilter: "Any private filter with raw object value",
        valueShape: "raw_value_or_object_reference",
        status: "rejected",
        command: "smart-folders filters add/update --folder FOLDER --criteria KIND [--ordinal N]",
        implementationMechanism: "private_catalog_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_boundary_accounting",
        combinationSupport: "not_supported",
        privacyBoundary: "hashes_only_without_raw_private_values",
        reason: "Raw private criteria values and object references are not Apple Notes guide capabilities. The CLI supports reviewed semantic value shapes and rejects raw/object-bound catalog entries instead of promising raw private filter mutation."
      ),
      SmartFolderFilterCatalogItem(
        filterFamily: "os_filter_catalog",
        criteriaKind: "unreviewed-os-filter-type",
        appleFilter: "Future or OS-specific filter",
        valueShape: "unknown_private_filter_type",
        status: "rejected",
        command: "smart-folders filters audit",
        implementationMechanism: "future_or_unknown_os_catalog_non_capability",
        requiredImplementation: "not_applicable",
        requiredVerifier: "official_product_boundary_accounting",
        combinationSupport: "not_supported",
        privacyBoundary: "filter_kind_names_without_user_data",
        reason: "Future or unknown OS-specific filter types are not current Apple Notes guide capabilities. They must be reviewed in a future catalog refresh before entering the CLI promise."
      ),
    ]
  }

  private func notesSmartFolderFilterCatalogAuditSummary(
    _ records: [NotesSmartFolderFilterCatalogAuditRecord]
  ) -> NotesSmartFolderFilterCatalogAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesSmartFolderFilterCatalogAuditSummary(
      supportedRecordCount: supported.count,
      gatedRecordCount: gated.count,
      rejectedRecordCount: rejected.count,
      auditRequiresSelector: false,
      backendCalls: "none",
      supportedFilterFamilies: Array(Set(supported.map(\.filterFamily))).sorted(),
      gatedFilterFamilies: Array(Set(gated.map(\.filterFamily))).sorted(),
      supportedCriteriaKinds: supported.map(\.criteriaKind),
      gatedCriteriaKinds: gated.map(\.criteriaKind)
    )
  }

  private func verifySmartFolderFilterCatalogAudit(
    records: [NotesSmartFolderFilterCatalogAuditRecord],
    summary: NotesSmartFolderFilterCatalogAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedCriteriaKinds)
    let gated = Set(summary.gatedCriteriaKinds)
    let rejected = Set(records.filter { $0.status == "rejected" }.map(\.criteriaKind))
    let families = Set(summary.supportedFilterFamilies)
    let expectedSupportedKinds = Set([
      "tag-selected-single", "tag-selected-multiple", "tag-selected-multiple-any",
    ] + notesSmartFolderBuiltInCriteriaKinds)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "supported_criteria_match_writer_modules_catalog",
        expected: true,
        actual: supported == expectedSupportedKinds
      ),
      verificationBoolCheck(
        name: "official_example_filter_families_accounted",
        expected: true,
        actual: families.isSuperset(of: ["tags", "mentions", "checklists", "date_created", "date_edited"])
      ),
      verificationBoolCheck(
        name: "installed_filter_family_tail_accounted",
        expected: true,
        actual: families.isSuperset(
          of: [
            "attachments", "folders", "participants", "pin_state", "share_state", "lock_state",
            "quick_notes", "special_note_kind",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_filter_catalog_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "tag_catalog_residuals_rejected",
        expected: true,
        actual: rejected.isSuperset(
          of: [
            "tag-unsupported-operator-mode", "tag-missing-private-hints",
          ]
        )
      ),
      verificationBoolCheck(
        name: "object_identity_catalog_residuals_rejected",
        expected: true,
        actual: rejected.isSuperset(
          of: [
            "participant-identity-without-private-hash", "mention-object-bound-without-private-hash",
            "raw-value-or-object-bound-filter",
          ]
        )
      ),
      verificationBoolCheck(
        name: "os_filter_refresh_catalog_residual_rejected",
        expected: true,
        actual: rejected.contains("unreviewed-os-filter-type")
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
      verificationBoolCheck(
        name: "no_raw_private_values_required",
        expected: true,
        actual: records.allSatisfy { !$0.privacyBoundary.contains("raw_private_values") || $0.privacyBoundary.contains("without_raw_private_values") }
      ),
    ]
    return NotesMutationVerificationReport(
      operation: "notes.smart-folders.filters.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "filter_catalog_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.smart-folders.filters.audit"),
      checks: checks
    )
  }

  private func notesSmartFolderWorkflowAuditRecords() -> [NotesSmartFolderWorkflowAuditRecord] {
    struct SmartFolderWorkflowAuditItem {
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
      SmartFolderWorkflowAuditItem(
        family: "smart_folder_metadata_listing",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "supported",
        appleCapability: "view_existing_smart_folders",
        command: "smart-folders list [--account ACCOUNT]",
        mechanism: "typed_private_notes_framework_smart_folder_reader",
        requiredImplementation: "private ICFolder smart-folder metadata readback",
        requiredVerifier: "private_smart_folder_metadata_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "smart_folder_ids_names_and_counts_only_without_note_bodies",
        reason: "`smart-folders list` reads Smart Folder metadata and visible-note counts without fetching note bodies."
      ),
      SmartFolderWorkflowAuditItem(
        family: "smart_folder_matching_notes",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "supported",
        appleCapability: "view_notes_referenced_by_smart_folder",
        command: "smart-folders notes --folder FOLDER [--account ACCOUNT]",
        mechanism: "typed_private_notes_framework_smart_folder_note_reader",
        requiredImplementation: "private Smart Folder matching-note collection readback",
        requiredVerifier: "private_smart_folder_matching_note_summary_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "note_summaries_without_note_bodies",
        reason: "Smart Folders contain references to notes; the accepted notes reader returns only matching note summaries."
      ),
      SmartFolderWorkflowAuditItem(
        family: "criteria_read_explain_reasoning_audit",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "inspect_smart_folder_criteria_and_matching_reasoning",
        command: "smart-folders criteria; smart-folders explain; smart-folders reasoning; smart-folders audit",
        mechanism: "typed_private_notes_framework_smart_folder_criteria_reader",
        requiredImplementation: "private criteria summary and matching-note reasoning readback",
        requiredVerifier: "private_criteria_summary+matching_note_reasoning_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "criteria_hashes_counts_and_semantic_families_without_raw_criteria_json",
        reason: "The accepted criteria readers account for query kind, filter families, matching notes, and gated criteria gaps without printing raw criteria."
      ),
      SmartFolderWorkflowAuditItem(
        family: "tag_criteria_create_update",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "create_or_edit_smart_folder_by_tags",
        command: "smart-folders create/update --tag TAG[,TAG...] [--match all|any]",
        mechanism: "typed_private_notes_framework_tag_smart_folder_writer",
        requiredImplementation: "private tag Smart Folder create/update path",
        requiredVerifier: "private_smart_folder_tag_criteria_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "tag_selector_and_tag_hashes_without_note_bodies",
        reason: "Single/multi-tag Smart Folder create/update is accepted with All-selected-tags or Any-selected-tags operator readback, Smart Folder identity, criteria, and matching-note readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "date_created_edited_criteria",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "create_or_edit_smart_folder_by_created_or_edited_date",
        command: "smart-folders create-criteria/update-criteria --criteria created-*|edited-*",
        mechanism: "typed_private_notes_framework_date_filter_selection_writer",
        requiredImplementation: "private date-created/date-edited filter selections",
        requiredVerifier: "private_date_filter_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "date_parameters_and_hashes_without_note_content",
        reason: "Promoted created/edited date criteria are accepted with private date-parameter and matching-note readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "checklist_criteria",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "create_or_edit_smart_folder_by_checklist_state",
        command: "smart-folders create-criteria/update-criteria --criteria checklists|incomplete-checklists|completed-checklists|no-checklists",
        mechanism: "typed_private_notes_framework_checklist_filter_selection_writer",
        requiredImplementation: "private checklist filter selections",
        requiredVerifier: "private_checklist_filter_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "checklist_counts_without_checklist_text",
        reason: "Promoted checklist criteria cover checklist presence and checked/incomplete/completed/no-checklist selections."
      ),
      SmartFolderWorkflowAuditItem(
        family: "mention_participant_criteria",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "create_or_edit_smart_folder_by_mentions_or_participants",
        command: "smart-folders create-criteria/update-criteria --criteria mentions|participants --participant-user-id USER_ID",
        mechanism: "typed_private_notes_framework_participant_mention_filter_writer",
        requiredImplementation: "private participant and mention filter selections",
        requiredVerifier: "private_participant_or_mention_hash_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "participant_user_hashes_without_names_handles_or_mention_text",
        reason: "Selected participant and mentioned-participant criteria are accepted with opaque user identifiers hashed in output."
      ),
      SmartFolderWorkflowAuditItem(
        family: "promoted_all_rule_combination",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "create_or_edit_multiple_rule_all_scope_for_promoted_criteria",
        command: "smart-folders create-criteria/update-criteria --criteria KIND,KIND",
        mechanism: "typed_private_notes_framework_filter_selection_combination_writer",
        requiredImplementation: "private AND filter-selection/query-factory combinations",
        requiredVerifier: "private_filter_count_kind_and_matching_note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "filter_kind_counts_without_raw_filter_values",
        reason: "Comma-separated promoted criteria create an all-rules combination and verify filter-count and filter-kind readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "promoted_filter_edit",
        guideSection: "Use Smart Folders / Edit a Smart Folder",
        status: "supported",
        appleCapability: "change_add_or_remove_promoted_smart_folder_filters",
        command: "smart-folders update-criteria; smart-folders copy-criteria; smart-folders import-criteria",
        mechanism: "typed_private_notes_framework_smart_folder_criteria_writer",
        requiredImplementation: "private full-criteria replacement for promoted or imported criteria",
        requiredVerifier: "private_criteria_replacement_readback",
        safetyGate: "dry-run/readback or --allow-artifact-action",
        privacyBoundary: "criteria_hashes_without_raw_values_except_explicit_artifact",
        reason: "Promoted criteria can be replaced as a whole, and raw criteria import/copy is accepted with explicit artifact or source readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "smart_folder_name_change",
        guideSection: "Use Smart Folders / Edit a Smart Folder",
        status: "supported",
        appleCapability: "rename_smart_folder",
        command: "smart-folders rename --folder FOLDER --name NAME",
        mechanism: "typed_private_notes_framework_smart_folder_writer",
        requiredImplementation: "private Smart Folder rename path",
        requiredVerifier: "private_smart_folder_identity_name_and_query_preservation_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "selector_and_new_name_hashes_without_note_content",
        reason: "Renaming one editable Smart Folder is accepted while preserving its query and matching-note accounting."
      ),
      SmartFolderWorkflowAuditItem(
        family: "delete_smart_folder_reference_only",
        guideSection: "Use Smart Folders / Delete a Smart Folder",
        status: "supported",
        appleCapability: "delete_smart_folder_without_deleting_referenced_notes",
        command: "smart-folders delete --folder FOLDER",
        mechanism: "typed_private_notes_framework_smart_folder_writer",
        requiredImplementation: "private Smart Folder delete path",
        requiredVerifier: "private_smart_folder_absence+matching_note_preservation_boundary",
        safetyGate: "dry-run/readback",
        privacyBoundary: "smart_folder_selector_hash_without_referenced_note_content",
        reason: "Deleting a Smart Folder is accepted as Smart Folder removal only; referenced notes remain outside the deletion target."
      ),
      SmartFolderWorkflowAuditItem(
        family: "file_menu_creation_ui",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "delegated",
        appleCapability: "create_smart_folder_through_file_menu_or_make_into_smart_folder_checkbox",
        command: "Notes.app File menu UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_menu_route",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The CLI owns semantic create commands; menu clicks and checkbox UI remain Notes.app interaction surfaces."
      ),
      SmartFolderWorkflowAuditItem(
        family: "contextual_more_button_ui",
        guideSection: "Use Smart Folders / Edit a Smart Folder / Delete a Smart Folder",
        status: "delegated",
        appleCapability: "edit_or_delete_smart_folder_through_control_click_or_more_button",
        command: "Notes.app sidebar contextual UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_sidebar_contextual_route",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Control-click and More-button interactions are UI routes over semantic operations that are supported separately."
      ),
      SmartFolderWorkflowAuditItem(
        family: "sidebar_visibility_ui",
        guideSection: "Use Smart Folders / Convert a folder into a Smart Folder",
        status: "delegated",
        appleCapability: "show_folders_sidebar_before_selecting_folder",
        command: "Notes.app View > Show Folders",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_sidebar_visibility_route",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Showing or hiding the Notes sidebar is transient app UI state, not persisted Notes data."
      ),
      SmartFolderWorkflowAuditItem(
        family: "sidebar_drag_reorder",
        guideSection: "Use Smart Folders / Edit a Smart Folder",
        status: "delegated",
        appleCapability: "move_smart_folder_in_sidebar_by_dragging",
        command: "Notes.app sidebar drag UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_sidebar_drag_route",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Pointer drag reordering in the sidebar is a user-facing UI operation until a persisted private sort-order path is proven."
      ),
      SmartFolderWorkflowAuditItem(
        family: "folder_to_smart_folder_conversion",
        guideSection: "Use Smart Folders / Convert a folder into a Smart Folder",
        status: "supported",
        appleCapability: "convert_existing_folder_into_smart_folder",
        command: "smart-folders convert-folder --folder FOLDER [--account ACCOUNT]",
        mechanism: "typed_private_notes_framework_folder_to_smart_folder_conversion_writer",
        requiredImplementation: "ICFolder.visibleNotesInFolder+ICNote.primitiveFolder+ICHashtag+ICTagSelection+ICQuery+ICFolder.smartFolderWithQuery+ICFolder.markForDeletion",
        requiredVerifier: "private_smart_folder_creation+source_folder_absence+note_move_tag_readback",
        safetyGate: "--allow-destructive-selection + --allow-persistent-action",
        privacyBoundary: "must_hash_folder_note_and_tag_values_without_note_bodies",
        reason: "Folder conversion is irreversible, moves notes to Notes, tags them with the folder name, creates the matching Smart Folder, and removes the source folder with dedicated safety gates and verifier proof."
      ),
      SmartFolderWorkflowAuditItem(
        family: "multi_rule_any_scope",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "supported",
        appleCapability: "choose_any_rule_scope_for_multiple_rules",
        command: "smart-folders create-criteria/update-criteria --criteria KIND,KIND --match any",
        mechanism: "typed_private_notes_framework_filter_selection_join_operator_writer",
        requiredImplementation: "ICFilterSelection.initWithFilterTypeSelections_joinOperator",
        requiredVerifier: "private_join_operator_readback+matching_note_resolution",
        safetyGate: nil,
        privacyBoundary: "criteria_kind_and_join_operator_hashes_without_raw_values",
        reason: "Promoted comma-separated private filter-selection criteria can now write `ICFilterSelection.joinOperator` 0 for Any/OR scope and verify the join operator plus matching-note count by private Smart Folder readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "untagged_notes_only_criteria",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "supported",
        appleCapability: "create_smart_folder_for_untagged_notes_only",
        command: "smart-folders create-criteria/update-criteria --criteria untagged",
        mechanism: "typed_private_notes_framework_tag_selection_mode_writer",
        requiredImplementation: "ICTagSelection.initWithManagedObjectContext_mode+ICQuery.queryForNotes_matchingTagSelection",
        requiredVerifier: "private_tag_selection_mode_readback+matching_note_resolution",
        safetyGate: nil,
        privacyBoundary: "tag_absence_counts_without_note_bodies_or_tag_text",
        reason: "Promoted Untagged Notes Only criteria use private `ICTagSelection.mode` 2 (All Untagged) with selected-tag count 0 and matching-note readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "filter_menu_catalog_accounting",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "cover_every_filter_popup_option_and_value_shape",
        command: "smart-folders filters audit",
        mechanism: "command_layer_private_filter_catalog_accounting",
        requiredImplementation: "target-owned Smart Folder filter catalog derived from accepted private criteria writers plus rejected private-catalog residuals",
        requiredVerifier: "filter_catalog_record_count+supported_kind_set+rejected_residual_accounting",
        safetyGate: nil,
        privacyBoundary: "filter_catalog_hashes_without_raw_private_values",
        reason: "The filter catalog audit now accounts for supported private criteria kinds and rejected non-guide private catalog residuals without reading notes or Smart Folders."
      ),
      SmartFolderWorkflowAuditItem(
        family: "arbitrary_filter_add",
        guideSection: "Use Smart Folders / Create a Smart Folder / Edit a Smart Folder",
        status: "supported",
        appleCapability: "add_any_filter_popup_rule",
        command: "smart-folders filters add --folder FOLDER --criteria KIND [--ordinal N]",
        mechanism: "typed_private_notes_framework_filter_delta_rewrite",
        requiredImplementation: "private promoted-filter criteria reconstruction plus full criteria rewrite",
        requiredVerifier: "private_per_filter_delta_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "filter_catalog_hashes_without_raw_private_values",
        reason: "Promoted filter-selection criteria can be inserted at one ordinal by reconstructing the current private filter list, rewriting the full criteria, and verifying the resulting ordinal sequence plus matching-note readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "arbitrary_filter_update",
        guideSection: "Use Smart Folders / Edit a Smart Folder",
        status: "supported",
        appleCapability: "change_any_filter_popup_rule",
        command: "smart-folders filters update --folder FOLDER --ordinal N --criteria KIND",
        mechanism: "typed_private_notes_framework_filter_delta_rewrite",
        requiredImplementation: "private promoted-filter criteria reconstruction plus full criteria rewrite",
        requiredVerifier: "private_per_filter_delta_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "filter_catalog_hashes_without_raw_private_values",
        reason: "Promoted filter-selection criteria can be replaced at one ordinal by reconstructing the current private filter list, rewriting the full criteria, and verifying the resulting ordinal sequence plus matching-note readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "arbitrary_filter_remove",
        guideSection: "Use Smart Folders / Edit a Smart Folder",
        status: "supported",
        appleCapability: "remove_any_filter_popup_rule",
        command: "smart-folders filters remove --folder FOLDER --ordinal N",
        mechanism: "typed_private_notes_framework_filter_delta_rewrite",
        requiredImplementation: "private promoted-filter criteria reconstruction plus full criteria rewrite",
        requiredVerifier: "private_per_filter_delta_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "filter_catalog_hashes_without_raw_private_values",
        reason: "Promoted filter-selection criteria can be removed at one ordinal by reconstructing the current private filter list, rejecting empty-filter results, rewriting the full criteria, and verifying the resulting ordinal sequence plus matching-note readback."
      ),
      SmartFolderWorkflowAuditItem(
        family: "smart_folder_locking",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "rejected",
        appleCapability: "lock_a_smart_folder",
        command: "none",
        mechanism: "apple_product_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "product_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that Smart Folders cannot be locked."
      ),
      SmartFolderWorkflowAuditItem(
        family: "smart_folder_subfolder_nesting",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "rejected",
        appleCapability: "turn_smart_folder_into_subfolder",
        command: "none",
        mechanism: "apple_product_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "product_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that Smart Folders cannot be turned into subfolders."
      ),
      SmartFolderWorkflowAuditItem(
        family: "smart_folder_sharing",
        guideSection: "Use Smart Folders / Create a Smart Folder",
        status: "rejected",
        appleCapability: "share_a_smart_folder",
        command: "none",
        mechanism: "apple_product_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "product_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that Smart Folders cannot be shared, though they can reference shared notes."
      ),
      SmartFolderWorkflowAuditItem(
        family: "ineligible_folder_conversion",
        guideSection: "Use Smart Folders / Convert a folder into a Smart Folder",
        status: "rejected",
        appleCapability: "convert_shared_locked_or_subfolder_containing_folder",
        command: "none",
        mechanism: "apple_product_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "product_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that folders cannot be converted when they are shared, contain locked or shared notes, or have a subfolder."
      ),
      SmartFolderWorkflowAuditItem(
        family: "empty_filter_smart_folder",
        guideSection: "Use Smart Folders / Edit a Smart Folder",
        status: "rejected",
        appleCapability: "save_smart_folder_with_no_filters",
        command: "none",
        mechanism: "apple_product_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "product_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that a Smart Folder must have at least one filter."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesSmartFolderWorkflowAuditRecord(
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

  private func notesSmartFolderWorkflowAuditSummary(
    _ records: [NotesSmartFolderWorkflowAuditRecord]
  ) -> NotesSmartFolderWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesSmartFolderWorkflowAuditSummary(
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

  private func verifySmartFolderWorkflowAudit(
    records: [NotesSmartFolderWorkflowAuditRecord],
    summary: NotesSmartFolderWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let rejected = Set(summary.rejectedWorkflowFamilies)
    let guideSections = records.flatMap { $0.guideSection.components(separatedBy: " / ") }
    let guideSectionSet = Set(guideSections)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "official_page_sections_accounted",
        expected: true,
        actual: guideSectionSet.contains("Use Smart Folders")
          && guideSectionSet.contains("Create a Smart Folder")
          && guideSectionSet.contains("Convert a folder into a Smart Folder")
          && guideSectionSet.contains("Edit a Smart Folder")
          && guideSectionSet.contains("Delete a Smart Folder")
      ),
      verificationBoolCheck(
        name: "private_smart_folder_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "smart_folder_metadata_listing", "smart_folder_matching_notes",
            "criteria_read_explain_reasoning_audit", "tag_criteria_create_update",
            "date_created_edited_criteria", "checklist_criteria", "mention_participant_criteria",
            "promoted_all_rule_combination", "multi_rule_any_scope", "untagged_notes_only_criteria", "promoted_filter_edit",
            "smart_folder_name_change", "delete_smart_folder_reference_only",
            "folder_to_smart_folder_conversion", "filter_menu_catalog_accounting",
            "arbitrary_filter_add", "arbitrary_filter_update", "arbitrary_filter_remove",
          ]
        )
      ),
      verificationBoolCheck(
        name: "ui_workflows_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "file_menu_creation_ui", "contextual_more_button_ui", "sidebar_visibility_ui",
            "sidebar_drag_reorder",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_workflow_semantics_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "product_limitations_rejected",
        expected: true,
        actual: rejected.isSuperset(
          of: [
            "smart_folder_locking", "smart_folder_subfolder_nesting", "smart_folder_sharing",
            "ineligible_folder_conversion", "empty_filter_smart_folder",
          ]
        )
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
      verificationBoolCheck(
        name: "privacy_boundaries_recorded",
        expected: true,
        actual: records.allSatisfy { !$0.privacyBoundary.isEmpty }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.smart-folders.workflow.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.smart-folders.workflow.audit"),
      checks: checks
    )
  }

  private func verifySmartFolderCriteriaAudit(
    records: [NotesSmartFolderCriteriaAuditRecord],
    summary: NotesSmartFolderCriteriaAuditSummary
  ) -> NotesMutationVerificationReport {
    let rawValueHashCount = records.flatMap(\.explanation.filters)
      .filter { $0.rawValueSHA256 != nil }
      .count
    let checks = [
      verificationBoolCheck(
        name: "audit_record_count_matches",
        expected: true,
        actual: summary.smartFolderCount == records.count
      ),
      verificationBoolCheck(
        name: "criteria_summary_count_matches",
        expected: true,
        actual: summary.criteriaSummaryCount == records.filter { $0.smartFolder.criteria != nil }.count
      ),
      verificationBoolCheck(
        name: "multi_condition_count_matches",
        expected: true,
        actual: summary.multiConditionCount == records.filter { $0.explanation.multiCondition }.count
      ),
      verificationBoolCheck(
        name: "raw_value_hashes_accounted",
        expected: true,
        actual: summary.rawValueHashCount == rawValueHashCount
      ),
      verificationBoolCheck(
        name: "user_editable_criteria_construction_gated",
        expected: true,
        actual: records.isEmpty || summary.gatedMutationFamilies.contains("user_editable_criteria_construction")
      ),
      verificationBoolCheck(
        name: "missing_criteria_summaries_accounted",
        expected: true,
        actual: records
          .filter { $0.smartFolder.criteria == nil }
          .allSatisfy { $0.explanation.queryKind == "unavailable" }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.smart-folders.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_smart_folder_criteria_audit",
      targetIDSHA256: sha256Hex(records.map(\.smartFolder.id).joined(separator: "\n")),
      checks: checks,
      warnings: summary.criteriaSummaryCount == summary.smartFolderCount ? [] : ["criteria_summary_unavailable"]
    )
  }

  func smartFolderReader() throws -> any NotesSmartFolderReading {
    guard let smartFolderReader = implementation as? any NotesSmartFolderReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder commands require a private-framework Smart Folder reader.",
        details: [
          "capability": "smart_folders",
          "required_module": "NotesShared",
        ]
      )
    }
    return smartFolderReader
  }
}
