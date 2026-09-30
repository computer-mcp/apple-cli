import Foundation
import Utility

extension NotesCommand {
  func runBodyFormatting(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["body", "structure"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let structure = try bodyStructureReader().readBodyStructure(noteID: id)
      return try result(
        NotesBodyStructureResponse(noteID: id, structure: structure),
        human: [
          "note_id: \(structure.noteID)",
          "plain_text_bytes: \(structure.plainTextByteCount.map(String.init) ?? "")",
          "paragraphs: \(structure.paragraphCount.map(String.init) ?? "")",
          "checklist_items: \(structure.checklistItemCount)",
          "tables: \(structure.tableCount)",
          "collapsible_sections: \(structure.collapsibleSectionCount)",
          "collapsed_sections: \(structure.collapsedSectionCount)",
          "math_attachments: \(structure.mathAttachmentCount)",
          "inline_attachments: \(structure.inlineAttachmentCount)",
          "inline_format_runs: \(structure.inlineFormatRunCount)",
          "highlight_runs: \(structure.highlightRunCount)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["body", "surfaces"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let structure = try bodyStructureReader().readBodyStructure(noteID: id)
      let summary = bodySurfaceSummary(structure)
      let surfaces = bodySurfaceFamilies(structure)
      let verification = verifyBodySurfaces(
        structure: structure,
        summary: summary,
        surfaces: surfaces
      )
      return try result(
        NotesBodySurfacesResponse(
          noteID: structure.noteID,
          summary: summary,
          surfaces: surfaces,
          verification: verification
        ),
        human: [
          "note_id: \(structure.noteID)",
          "tables: \(summary.tableCount)",
          "collapsible_sections: \(summary.collapsibleSectionCount)",
          "collapsed_sections: \(summary.collapsedSectionCount)",
          "math_attachments: \(summary.mathAttachmentCount)",
          "gated_mutations: \(summary.gatedMutationFamilies.joined(separator: ","))",
        ].joined(separator: "\n"),
        options: options
      )
    case ["body", "format", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try bodyFormatAudit(options)
    case ["body", "math", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try bodyMathWorkflowAudit(options)
    case ["body", "collapsible", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let structure = try bodyStructureReader().readBodyStructure(noteID: id)
      let sections = try bodyStructureReader().listCollapsibleSections(noteID: id)
      let verification = verifyBodyCollapsibleSections(
        structure: structure,
        sections: sections
      )
      return try result(
        NotesBodyCollapsibleSectionsResponse(
          noteID: id,
          sections: sections,
          structure: structure,
          verification: verification
        ),
        human: [
          "note_id: \(id)",
          "collapsible_sections: \(sections.count)",
          "collapsed_sections: \(sections.filter { $0.collapsed }.count)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["body", "table", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let structure = try bodyStructureReader().readBodyStructure(noteID: id)
      let tables = try bodyStructureReader().listTables(noteID: id)
      let verification = verifyBodyTables(structure: structure, tables: tables)
      return try result(
        NotesBodyTablesResponse(
          noteID: id,
          tables: tables,
          structure: structure,
          verification: verification
        ),
        human: [
          "note_id: \(id)",
          "tables: \(tables.count)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["body", "math", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let structure = try bodyStructureReader().readBodyStructure(noteID: id)
      let results = try bodyStructureReader().listMathResults(noteID: id)
      let verification = verifyBodyMathResults(structure: structure, results: results)
      return try result(
        NotesBodyMathResultsResponse(
          noteID: id,
          results: results,
          structure: structure,
          verification: verification
        ),
        human: [
          "note_id: \(id)",
          "math_results: \(results.count)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["body", "math", "verify-expression"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["text"])
      let draft = try bodyMathExpressionScanDraft(options)
      let scan = try bodyMathExpressionScanner().scanMathExpression(draft)
      let verification = verifyBodyMathExpressionScan(scan, operation: "notes.body.math.verify-expression")
      guard verification.verified else {
        throw CLIError(
          code: .internalError,
          message: "Notes body math expression verification failed.",
          details: artifactVerificationFailureDetails(
            operation: "notes.body.math.verify-expression",
            verification: verification
          )
        )
      }
      return try result(
        NotesBodyMathExpressionScanResponse(
          operation: "notes.body.math.verify-expression",
          changed: false,
          scan: scan,
          verification: verification
        ),
        human: [
          "expression_sha256: \(scan.expressionSHA256)",
          "recognized: \(scan.recognized)",
          "source: \(scan.sourceKind)",
        ].joined(separator: "\n"),
        options: options
      )
    case ["body", "math", "results"]:
      try validateTargetOptions(options, allowedOptions: ["id", "mode"])
      try validateMutationIntent(options)
      let draft = try bodyMathResultsPreferenceDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let structureReader = try bodyStructureReader()
      let beforeStructure = try structureReader.readBodyStructure(noteID: draft.noteID)
      let beforePreference = try structureReader.readMathResultsPreference(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.math.results",
        scopeDigest: bodyMathResultsPreferenceScopeDigest(draft),
        summary: bodyMathResultsPreferenceSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution changes one selected note's Math Results display behavior through the private Notes math preference path.",
          "Output verifies private preference readback without printing note body, expression, or result text.",
        ]
      ) {
        let write = try bodyMutator().setMathResultsPreference(draft)
        let verification = try mutationVerifier().verifyBodyMathResultsPreference(
          operation: "notes.body.math.results",
          before: before,
          beforeStructure: beforeStructure,
          beforePreference: beforePreference,
          draft: draft,
          result: write
        )
        return try verifiedBodyMathResultsPreferenceMutationResult(
          NotesBodyMathResultsPreferenceResult(
            operation: "notes.body.math.results",
            changed: write.changed,
            note: noteSummary(write.note),
            before: write.before,
            after: write.after,
            requestedMode: draft.mode,
            requestedRawValue: draft.rawValue,
            requestedValueSHA256: draft.requestedValueSHA256,
            verification: verification
          ))
      }
    case ["body", "collapsible", "set"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "state"])
      try validateMutationIntent(options)
      let draft = try bodyCollapsibleSetDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeSections = try bodyStructureReader().listCollapsibleSections(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.collapsible.set",
        scopeDigest: bodyCollapsibleSetScopeDigest(draft),
        summary: bodyCollapsibleSetSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setCollapsibleSectionState(draft)
        let verification = try mutationVerifier().verifyBodyCollapsibleSet(
          operation: "notes.body.collapsible.set",
          before: before,
          beforeStructure: beforeStructure,
          beforeSections: beforeSections,
          draft: draft,
          result: write
        )
        return try verifiedBodyCollapsibleMutationResult(
          NotesBodyCollapsibleSetMutationResult(
            operation: "notes.body.collapsible.set",
            changed: write.changed,
            note: noteSummary(write.note),
            target: write.target,
            sections: write.sections,
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "paragraph", "style"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "style"])
      try validateMutationIntent(options)
      let draft = try bodyParagraphStyleDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeSections = try bodyStructureReader().listCollapsibleSections(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.paragraph.style",
        scopeDigest: bodyParagraphStyleScopeDigest(draft),
        summary: bodyParagraphStyleSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setParagraphStyle(draft)
        let verification = try mutationVerifier().verifyBodyParagraphStyle(
          operation: "notes.body.paragraph.style",
          before: before,
          beforeStructure: beforeStructure,
          beforeSections: beforeSections,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.paragraph.style",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "paragraph", "align"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "alignment"])
      try validateMutationIntent(options)
      let draft = try bodyParagraphAlignmentDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.paragraph.align",
        scopeDigest: bodyParagraphAlignmentScopeDigest(draft),
        summary: bodyParagraphAlignmentSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setParagraphAlignment(draft)
        let verification = try mutationVerifier().verifyBodyParagraphAlignment(
          operation: "notes.body.paragraph.align",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.paragraph.align",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "paragraph", "quote"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "state"])
      try validateMutationIntent(options)
      let draft = try bodyParagraphQuoteDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.paragraph.quote",
        scopeDigest: bodyParagraphQuoteScopeDigest(draft),
        summary: bodyParagraphQuoteSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setParagraphBlockQuote(draft)
        let verification = try mutationVerifier().verifyBodyParagraphBlockQuote(
          operation: "notes.body.paragraph.quote",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.paragraph.quote",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "inline", "format"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "text", "occurrence", "format", "state"])
      try validateMutationIntent(options)
      let draft = try bodyInlineFormatDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.inline.format",
        scopeDigest: bodyInlineFormatScopeDigest(draft),
        summary: bodyInlineFormatSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setInlineFormat(draft)
        let verification = try mutationVerifier().verifyBodyInlineFormat(
          operation: "notes.body.inline.format",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.inline.format",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "inline", "color"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "text", "occurrence", "color"])
      try validateMutationIntent(options)
      let draft = try bodyInlineColorDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.inline.color",
        scopeDigest: bodyInlineColorScopeDigest(draft, role: "foreground"),
        summary: bodyInlineColorSummary(draft, role: "foreground"),
        options: options
      ) {
        let write = try bodyMutator().setInlineForegroundColor(draft)
        let verification = try mutationVerifier().verifyBodyInlineColor(
          operation: "notes.body.inline.color",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.inline.color",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "inline", "highlight"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "text", "occurrence", "color"])
      try validateMutationIntent(options)
      let draft = try bodyInlineColorDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.inline.highlight",
        scopeDigest: bodyInlineColorScopeDigest(draft, role: "highlight"),
        summary: bodyInlineColorSummary(draft, role: "highlight"),
        options: options
      ) {
        let write = try bodyMutator().setInlineHighlightColor(draft)
        let verification = try mutationVerifier().verifyBodyInlineColor(
          operation: "notes.body.inline.highlight",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.inline.highlight",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "inline", "font"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "text", "occurrence", "family", "size"])
      try validateMutationIntent(options)
      let draft = try bodyInlineFontDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.inline.font",
        scopeDigest: bodyInlineFontScopeDigest(draft),
        summary: bodyInlineFontSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setInlineFont(draft)
        let verification = try mutationVerifier().verifyBodyInlineFont(
          operation: "notes.body.inline.font",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.inline.font",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "text"], allowedFlags: ["checked"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistAddDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.add",
        scopeDigest: bodyChecklistAddScopeDigest(draft),
        summary: bodyChecklistAddSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().addChecklistItem(draft)
        let verification = try mutationVerifier().verifyBodyChecklistAdd(
          operation: "notes.body.checklist.add",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.add",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "set"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "state"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistSetDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.set",
        scopeDigest: bodyChecklistSetScopeDigest(draft),
        summary: bodyChecklistSetSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setChecklistItemState(draft)
        let verification = try mutationVerifier().verifyBodyChecklistSet(
          operation: "notes.body.checklist.set",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.set",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "set-all"]:
      try validateTargetOptions(options, allowedOptions: ["id", "state"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistSetAllDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.set-all",
        scopeDigest: bodyChecklistSetAllScopeDigest(draft),
        summary: bodyChecklistSetAllSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setAllChecklistItemStates(draft)
        let verification = try mutationVerifier().verifyBodyChecklistSetAll(
          operation: "notes.body.checklist.set-all",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.set-all",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "sort"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistSortDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.sort",
        scopeDigest: bodyChecklistSortScopeDigest(draft),
        summary: bodyChecklistSortSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().sortChecklistItems(draft)
        let verification = try mutationVerifier().verifyBodyChecklistSort(
          operation: "notes.body.checklist.sort",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.sort",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "convert"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "state"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistConvertDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.convert",
        scopeDigest: bodyChecklistConvertScopeDigest(draft),
        summary: bodyChecklistConvertSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().convertParagraphToChecklistItem(draft)
        let verification = try mutationVerifier().verifyBodyChecklistConvert(
          operation: "notes.body.checklist.convert",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.convert",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "convert-range"]:
      try validateTargetOptions(options, allowedOptions: ["id", "from-ordinal", "to-ordinal", "state"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistConvertRangeDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.convert-range",
        scopeDigest: bodyChecklistConvertRangeScopeDigest(draft),
        summary: bodyChecklistConvertRangeSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().convertParagraphRangeToChecklistItems(draft)
        let verification = try mutationVerifier().verifyBodyChecklistConvertRange(
          operation: "notes.body.checklist.convert-range",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.convert-range",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "reorder"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "to-ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistReorderDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.reorder",
        scopeDigest: bodyChecklistReorderScopeDigest(draft),
        summary: bodyChecklistReorderSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().reorderChecklistItem(draft)
        let verification = try mutationVerifier().verifyBodyChecklistReorder(
          operation: "notes.body.checklist.reorder",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.reorder",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "indent"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "by"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistIndentDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.indent",
        scopeDigest: bodyChecklistIndentScopeDigest(draft),
        summary: bodyChecklistIndentSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().indentChecklistItem(draft)
        let verification = try mutationVerifier().verifyBodyChecklistIndent(
          operation: "notes.body.checklist.indent",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.indent",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyChecklistDeleteDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.delete",
        scopeDigest: bodyChecklistDeleteScopeDigest(draft),
        summary: bodyChecklistDeleteSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().deleteChecklistItem(draft)
        let verification = try mutationVerifier().verifyBodyChecklistDelete(
          operation: "notes.body.checklist.delete",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.checklist.delete",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "checklist", "line-break"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListTextInsertDraft(
        options,
        targetKind: .checklist,
        insertKind: .lineBreak,
        commandName: "body checklist line-break"
      )
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.line-break",
        scopeDigest: bodyListTextInsertScopeDigest(draft),
        summary: bodyListTextInsertSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().insertTextInListItem(draft)
        let verification = try mutationVerifier().verifyBodyListTextInsert(
          operation: "notes.body.checklist.line-break",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyListTextInsertMutationResult(
          NotesBodyListTextInsertMutationResult(
            operation: "notes.body.checklist.line-break",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            targetKind: draft.targetKind,
            insertedKind: draft.insertKind,
            insertedTextByteCount: write.insertedTextByteCount,
            insertedTextSHA256: write.insertedTextSHA256,
            verification: verification
          ))
      }
    case ["body", "checklist", "end"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListEndDraft(
        options,
        targetKind: .checklist,
        commandName: "body checklist end"
      )
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.checklist.end",
        scopeDigest: bodyListEndScopeDigest(draft),
        summary: bodyListEndSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().endList(draft)
        let verification = try mutationVerifier().verifyBodyListEnd(
          operation: "notes.body.checklist.end",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyListEndMutationResult(
          NotesBodyListEndMutationResult(
            operation: "notes.body.checklist.end",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            targetKind: draft.targetKind,
            createdParagraphStyle: write.createdParagraphStyle,
            createdParagraphIDSHA256: write.createdParagraphIDSHA256,
            verification: verification
          ))
      }
    case ["body", "list", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "text", "style"])
      try validateMutationIntent(options)
      let draft = try bodyListAddDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.add",
        scopeDigest: bodyListAddScopeDigest(draft),
        summary: bodyListAddSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().addListItem(draft)
        let verification = try mutationVerifier().verifyBodyListAdd(
          operation: "notes.body.list.add",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.add",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "convert"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "style"])
      try validateMutationIntent(options)
      let draft = try bodyListConvertDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.convert",
        scopeDigest: bodyListConvertScopeDigest(draft),
        summary: bodyListConvertSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().convertParagraphToListItem(draft)
        let verification = try mutationVerifier().verifyBodyListConvert(
          operation: "notes.body.list.convert",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.convert",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "convert-range"]:
      try validateTargetOptions(options, allowedOptions: ["id", "from-ordinal", "to-ordinal", "style"])
      try validateMutationIntent(options)
      let draft = try bodyListConvertRangeDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.convert-range",
        scopeDigest: bodyListConvertRangeScopeDigest(draft),
        summary: bodyListConvertRangeSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().convertParagraphRangeToListItems(draft)
        let verification = try mutationVerifier().verifyBodyListConvertRange(
          operation: "notes.body.list.convert-range",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.convert-range",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "set-style"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "style"])
      try validateMutationIntent(options)
      let draft = try bodyListSetStyleDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.set-style",
        scopeDigest: bodyListSetStyleScopeDigest(draft),
        summary: bodyListSetStyleSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().setListItemStyle(draft)
        let verification = try mutationVerifier().verifyBodyListSetStyle(
          operation: "notes.body.list.set-style",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.set-style",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "indent"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "by"])
      try validateMutationIntent(options)
      let draft = try bodyListIndentDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.indent",
        scopeDigest: bodyListIndentScopeDigest(draft),
        summary: bodyListIndentSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().indentListItem(draft)
        let verification = try mutationVerifier().verifyBodyListIndent(
          operation: "notes.body.list.indent",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.indent",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "reorder"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "to-ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListReorderDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.reorder",
        scopeDigest: bodyListReorderScopeDigest(draft),
        summary: bodyListReorderSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().reorderListItem(draft)
        let verification = try mutationVerifier().verifyBodyListReorder(
          operation: "notes.body.list.reorder",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.reorder",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListDeleteDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.delete",
        scopeDigest: bodyListDeleteScopeDigest(draft),
        summary: bodyListDeleteSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().deleteListItem(draft)
        let verification = try mutationVerifier().verifyBodyListDelete(
          operation: "notes.body.list.delete",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyChecklistMutationResult(
          NotesBodyChecklistMutationResult(
            operation: "notes.body.list.delete",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            verification: verification
          ))
      }
    case ["body", "list", "line-break"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListTextInsertDraft(
        options,
        targetKind: .ordinaryList,
        insertKind: .lineBreak,
        commandName: "body list line-break"
      )
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.line-break",
        scopeDigest: bodyListTextInsertScopeDigest(draft),
        summary: bodyListTextInsertSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().insertTextInListItem(draft)
        let verification = try mutationVerifier().verifyBodyListTextInsert(
          operation: "notes.body.list.line-break",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyListTextInsertMutationResult(
          NotesBodyListTextInsertMutationResult(
            operation: "notes.body.list.line-break",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            targetKind: draft.targetKind,
            insertedKind: draft.insertKind,
            insertedTextByteCount: write.insertedTextByteCount,
            insertedTextSHA256: write.insertedTextSHA256,
            verification: verification
          ))
      }
    case ["body", "list", "tab"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListTextInsertDraft(
        options,
        targetKind: .ordinaryList,
        insertKind: .tab,
        commandName: "body list tab"
      )
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.tab",
        scopeDigest: bodyListTextInsertScopeDigest(draft),
        summary: bodyListTextInsertSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().insertTextInListItem(draft)
        let verification = try mutationVerifier().verifyBodyListTextInsert(
          operation: "notes.body.list.tab",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyListTextInsertMutationResult(
          NotesBodyListTextInsertMutationResult(
            operation: "notes.body.list.tab",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            targetKind: draft.targetKind,
            insertedKind: draft.insertKind,
            insertedTextByteCount: write.insertedTextByteCount,
            insertedTextSHA256: write.insertedTextSHA256,
            verification: verification
          ))
      }
    case ["body", "list", "end"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyListEndDraft(
        options,
        targetKind: .ordinaryList,
        commandName: "body list end"
      )
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.list.end",
        scopeDigest: bodyListEndScopeDigest(draft),
        summary: bodyListEndSummary(draft),
        options: options
      ) {
        let write = try bodyMutator().endList(draft)
        let verification = try mutationVerifier().verifyBodyListEnd(
          operation: "notes.body.list.end",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyListEndMutationResult(
          NotesBodyListEndMutationResult(
            operation: "notes.body.list.end",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            targetKind: draft.targetKind,
            createdParagraphStyle: write.createdParagraphStyle,
            createdParagraphIDSHA256: write.createdParagraphIDSHA256,
            verification: verification
          ))
      }
    case ["body", "table", "create"]:
      try validateTargetOptions(options, allowedOptions: ["id", "text"])
      try validateMutationIntent(options)
      let draft = try bodyTableCreateDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.table.create",
        scopeDigest: bodyTableCreateScopeDigest(draft),
        summary: bodyTableCreateSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution appends one Notes table attachment from tab/newline-delimited text.",
          "Output hashes table text and verifies private body structure readback without printing table cell text.",
        ]
      ) {
        let write = try bodyMutator().createTable(draft)
        let verification = try mutationVerifier().verifyBodyTableCreate(
          operation: "notes.body.table.create",
          before: before,
          beforeStructure: beforeStructure,
          draft: draft,
          result: write
        )
        return try verifiedBodyTableMutationResult(
          NotesBodyTableCreateResult(
            operation: "notes.body.table.create",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            tableTextByteCount: draft.textByteCount,
            tableTextSHA256: draft.textSHA256,
            tableRowCount: draft.rowCount,
            tableMaxColumnCount: draft.maxColumnCount,
            verification: verification
          ))
      }
    case ["body", "table", "import"]:
      try validateTargetOptions(options, allowedOptions: ["id", "text", "file", "format"])
      try validateMutationIntent(options)
      let draft = try bodyTableImportDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeTables = try bodyStructureReader().listTables(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.table.import",
        scopeDigest: bodyTableImportScopeDigest(draft),
        summary: bodyTableImportSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution appends one Notes table attachment from explicit external TSV/CSV table text.",
          "Output hashes source and normalized table text, verifies private body/table readback, and does not print table cell text or local file paths.",
        ]
      ) {
        let write = try bodyMutator().importTable(draft)
        let verification = try mutationVerifier().verifyBodyTableImport(
          operation: "notes.body.table.import",
          before: before,
          beforeStructure: beforeStructure,
          beforeTables: beforeTables,
          draft: draft,
          result: write
        )
        return try verifiedBodyTableMutationResult(
          NotesBodyTableImportResult(
            operation: "notes.body.table.import",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            target: write.target,
            tables: write.tables,
            sourceKind: draft.sourceKind,
            sourceFormat: draft.sourceFormat,
            sourceByteCount: draft.sourceByteCount,
            sourceSHA256: draft.sourceSHA256,
            tableTextByteCount: draft.tableTextByteCount,
            tableTextSHA256: draft.tableTextSHA256,
            rowCount: draft.rowCount,
            columnCount: draft.maxColumnCount,
            cellCount: draft.cellCount,
            verification: verification
          ))
      }
    case ["body", "table", "update"]:
      try validateTargetOptions(options, allowedOptions: ["id", "ordinal", "row", "column", "text"])
      try validateMutationIntent(options)
      let draft = try bodyTableUpdateDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeTables = try bodyStructureReader().listTables(noteID: draft.noteID)
      let beforeCell = try bodyStructureReader().readTableCell(
        noteID: draft.noteID,
        tableOrdinal: draft.ordinal,
        row: draft.row,
        column: draft.column
      )
      return try mutation(
        operation: "notes.body.table.update",
        scopeDigest: bodyTableUpdateScopeDigest(draft),
        summary: bodyTableUpdateSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution replaces one Notes table cell selected by table ordinal, row, and column.",
          "Output hashes cell text and verifies private body structure/table readback without printing table cell text.",
        ]
      ) {
        let write = try bodyMutator().updateTableCell(draft)
        let verification = try mutationVerifier().verifyBodyTableUpdate(
          operation: "notes.body.table.update",
          before: before,
          beforeStructure: beforeStructure,
          beforeTables: beforeTables,
          beforeCell: beforeCell,
          draft: draft,
          result: write
        )
        return try verifiedBodyTableMutationResult(
          NotesBodyTableUpdateResult(
            operation: "notes.body.table.update",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            target: write.target,
            cell: write.cell,
            tables: write.tables,
            verification: verification
          ))
      }
      case ["body", "table", "delete"]:
        try validateTargetOptions(options, allowedOptions: ["id", "ordinal"])
        try validateMutationIntent(options)
        let draft = try bodyTableDeleteDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeTables = try bodyStructureReader().listTables(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.table.delete",
        scopeDigest: bodyTableDeleteScopeDigest(draft),
        summary: bodyTableDeleteSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution removes one Notes table attachment selected by privacy-safe ordinal.",
          "Output verifies private body structure and table selector readback without printing table cell text.",
        ]
      ) {
        let write = try bodyMutator().deleteTable(draft)
        let verification = try mutationVerifier().verifyBodyTableDelete(
          operation: "notes.body.table.delete",
          before: before,
          beforeStructure: beforeStructure,
          beforeTables: beforeTables,
          draft: draft,
          result: write
        )
        return try verifiedBodyTableMutationResult(
          NotesBodyTableDeleteResult(
            operation: "notes.body.table.delete",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            target: write.target,
            tables: write.tables,
              verification: verification
            ))
        }
      case ["body", "table", "convert-to-text"]:
        try validateTargetOptions(options, allowedOptions: ["id", "ordinal"])
        try validateMutationIntent(options)
        let noteID = try requiredOption("id", options: options)
        let ordinal = try normalizedPositiveIntOption("ordinal", options: options)
        guard let before = try implementation.readNote(id: noteID) else {
          throw CLIError(
            code: .notFound,
            message: "Note was not found.",
            details: ["id_sha256": sha256Hex(noteID)]
          )
        }
        let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: noteID)
        let beforeTables = try bodyStructureReader().listTables(noteID: noteID)
        let draft = try bodyTableConvertToTextDraft(noteID: noteID, ordinal: ordinal, tables: beforeTables)
        return try mutation(
          operation: "notes.body.table.convert-to-text",
          scopeDigest: bodyTableConvertToTextScopeDigest(draft),
          summary: bodyTableConvertToTextSummary(draft),
          options: options,
          dryRunNotes: [
            "Execution replaces one Notes table attachment with tab/newline-delimited plain text in the note body.",
            "Output hashes converted text and verifies private body/table readback without printing table cell text.",
          ]
        ) {
          let write = try bodyMutator().convertTableToText(draft)
          let verification = try mutationVerifier().verifyBodyTableConvertToText(
            operation: "notes.body.table.convert-to-text",
            before: before,
            beforeStructure: beforeStructure,
            beforeTables: beforeTables,
            draft: draft,
            result: write
          )
          return try verifiedBodyTableMutationResult(
            NotesBodyTableConvertToTextResult(
              operation: "notes.body.table.convert-to-text",
              changed: write.changed,
              note: noteSummary(write.note),
              structure: write.structure,
              target: write.target,
              tables: write.tables,
              convertedTextByteCount: write.convertedTextByteCount,
              convertedTextSHA256: write.convertedTextSHA256,
              rowCount: write.rowCount,
              columnCount: write.columnCount,
              cellCount: write.cellCount,
              verification: verification
            ))
        }
      case ["body", "table", "convert-from-text"]:
        try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal"])
        try validateMutationIntent(options)
        let noteID = try requiredOption("id", options: options)
        guard let before = try implementation.readNote(id: noteID) else {
          throw CLIError(
            code: .notFound,
            message: "Note was not found.",
            details: ["id_sha256": sha256Hex(noteID)]
          )
        }
        let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: noteID)
        let beforeTables = try bodyStructureReader().listTables(noteID: noteID)
        let draft = try bodyTableConvertFromTextDraft(
          noteID: noteID,
          options: options,
          structure: beforeStructure
        )
        return try mutation(
          operation: "notes.body.table.convert-from-text",
          scopeDigest: bodyTableConvertFromTextScopeDigest(draft),
          summary: bodyTableConvertFromTextSummary(draft),
          options: options,
          dryRunNotes: [
            "Execution replaces one ordinary body paragraph selected by privacy-safe paragraph hash or ordinal with a Notes table attachment.",
            "Output hashes the source paragraph text and verifies private body/table readback without printing paragraph or cell text.",
          ]
        ) {
          let write = try bodyMutator().convertTextToTable(draft)
          let verification = try mutationVerifier().verifyBodyTableConvertFromText(
            operation: "notes.body.table.convert-from-text",
            before: before,
            beforeStructure: beforeStructure,
            beforeTables: beforeTables,
            draft: draft,
            result: write
          )
          return try verifiedBodyTableMutationResult(
            NotesBodyTableConvertFromTextResult(
              operation: "notes.body.table.convert-from-text",
              changed: write.changed,
              note: noteSummary(write.note),
              structure: write.structure,
              target: write.target,
              tables: write.tables,
              sourceParagraphIDSHA256: write.sourceParagraphIDSHA256,
              sourceTextByteCount: write.sourceTextByteCount,
              sourceTextSHA256: write.sourceTextSHA256,
              rowCount: write.rowCount,
              columnCount: write.columnCount,
              cellCount: write.cellCount,
              verification: verification
            ))
        }
      case ["body", "table", "copy"]:
        try validateTargetOptions(options, allowedOptions: ["id", "ordinal", "target"])
        try validateMutationIntent(options)
        let sourceNoteID = try requiredOption("id", options: options)
        let targetNoteID = try normalizedOptionalOption("target", options: options) ?? sourceNoteID
        let ordinal = try normalizedPositiveIntOption("ordinal", options: options)
        guard let beforeSource = try implementation.readNote(id: sourceNoteID) else {
          throw CLIError(
            code: .notFound,
            message: "Source note was not found.",
            details: ["id_sha256": sha256Hex(sourceNoteID)]
          )
        }
        let beforeTarget: NotesNoteDetail
        if sourceNoteID == targetNoteID {
          beforeTarget = beforeSource
        } else {
          guard let target = try implementation.readNote(id: targetNoteID) else {
            throw CLIError(
              code: .notFound,
              message: "Target note was not found.",
              details: ["id_sha256": sha256Hex(targetNoteID)]
            )
          }
          beforeTarget = target
        }
        let beforeSourceStructure = try bodyStructureReader().readBodyStructure(noteID: sourceNoteID)
        let beforeTargetStructure = sourceNoteID == targetNoteID
          ? beforeSourceStructure
          : try bodyStructureReader().readBodyStructure(noteID: targetNoteID)
        let beforeSourceTables = try bodyStructureReader().listTables(noteID: sourceNoteID)
        let beforeTargetTables = sourceNoteID == targetNoteID
          ? beforeSourceTables
          : try bodyStructureReader().listTables(noteID: targetNoteID)
        let draft = try bodyTableCopyDraft(
          sourceNoteID: sourceNoteID,
          targetNoteID: targetNoteID,
          ordinal: ordinal,
          tables: beforeSourceTables
        )
        return try mutation(
          operation: "notes.body.table.copy",
          scopeDigest: bodyTableCopyScopeDigest(draft),
          summary: bodyTableCopySummary(draft),
          options: options,
          dryRunNotes: [
            "Execution copies one Notes table selected by privacy-safe ordinal and appends it to the target note.",
            "Output hashes copied table text and verifies private table cell readback without printing table cell text.",
          ]
        ) {
          let write = try bodyMutator().copyTable(draft)
          let verification = try mutationVerifier().verifyBodyTableCopy(
            operation: "notes.body.table.copy",
            beforeSource: beforeSource,
            beforeTarget: beforeTarget,
            beforeSourceStructure: beforeSourceStructure,
            beforeTargetStructure: beforeTargetStructure,
            beforeSourceTables: beforeSourceTables,
            beforeTargetTables: beforeTargetTables,
            draft: draft,
            result: write
          )
          return try verifiedBodyTableMutationResult(
            NotesBodyTableCopyResult(
              operation: "notes.body.table.copy",
              changed: write.changed,
              sourceNote: noteSummary(write.sourceNote),
              targetNote: noteSummary(write.targetNote),
              sourceStructure: write.sourceStructure,
              targetStructure: write.targetStructure,
              sourceTable: write.sourceTable,
              targetTable: write.targetTable,
              sourceTables: write.sourceTables,
              targetTables: write.targetTables,
              copiedTextByteCount: write.copiedTextByteCount,
              copiedTextSHA256: write.copiedTextSHA256,
              rowCount: write.rowCount,
              columnCount: write.columnCount,
              cellCount: write.cellCount,
              verification: verification
            ))
        }
      case ["body", "table", "move"]:
        try validateTargetOptions(options, allowedOptions: ["id", "ordinal", "to-ordinal"])
        try validateMutationIntent(options)
        let noteID = try requiredOption("id", options: options)
        let ordinal = try normalizedPositiveIntOption("ordinal", options: options)
        let targetOrdinal = try normalizedPositiveIntOption("to-ordinal", options: options)
        guard let before = try implementation.readNote(id: noteID) else {
          throw CLIError(
            code: .notFound,
            message: "Note was not found.",
            details: ["id_sha256": sha256Hex(noteID)]
          )
        }
        let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: noteID)
        let beforeTables = try bodyStructureReader().listTables(noteID: noteID)
        let draft = try bodyTableMoveDraft(
          noteID: noteID,
          ordinal: ordinal,
          targetOrdinal: targetOrdinal,
          tables: beforeTables
        )
        return try mutation(
          operation: "notes.body.table.move",
          scopeDigest: bodyTableMoveScopeDigest(draft),
          summary: bodyTableMoveSummary(draft),
          options: options,
          dryRunNotes: [
            "Execution reorders one whole Notes table attachment by privacy-safe table ordinal.",
            "Output verifies private table order readback without printing table cell text.",
          ]
        ) {
          let write = try bodyMutator().moveTable(draft)
          let verification = try mutationVerifier().verifyBodyTableMove(
            operation: "notes.body.table.move",
            before: before,
            beforeStructure: beforeStructure,
            beforeTables: beforeTables,
            draft: draft,
            result: write
          )
          return try verifiedBodyTableMutationResult(
            NotesBodyTableMoveResult(
              operation: "notes.body.table.move",
              changed: write.changed,
              note: noteSummary(write.note),
              structure: write.structure,
              ordinal: draft.ordinal,
              targetOrdinal: draft.targetOrdinal,
              beforeTarget: write.beforeTarget,
              target: write.target,
              tables: write.tables,
              verification: verification
            ))
        }
      case ["body", "table", "rows", "format"],
        ["body", "table", "columns", "format"]:
        try validateTargetOptions(options, allowedOptions: ["id", "ordinal", "index", "count", "format", "style", "state"])
        try validateMutationIntent(options)
        let noteID = try requiredOption("id", options: options)
        guard let before = try implementation.readNote(id: noteID) else {
          throw CLIError(
            code: .notFound,
            message: "Note was not found.",
            details: ["id_sha256": sha256Hex(noteID)]
          )
        }
	        let structureReader = try bodyStructureReader()
        let beforeStructure = try structureReader.readBodyStructure(noteID: noteID)
        let beforeTables = try structureReader.listTables(noteID: noteID)
        let draft = try bodyTableFormatDraft(path: options.positionals, options: options, tables: beforeTables)
        let beforeCells = try bodyTableFormatCells(draft, tables: beforeTables, reader: structureReader)
        let operation = bodyTableFormatOperationName(draft)
        return try mutation(
          operation: operation,
          scopeDigest: bodyTableFormatScopeDigest(draft),
          summary: bodyTableFormatSummary(draft),
          options: options,
          dryRunNotes: [
            "Execution applies or clears one inline style over existing text in a selected Notes table row or column range.",
            "Output verifies private table cell text and format readback without printing table cell text.",
          ]
        ) {
          let write = try bodyMutator().formatTableRange(draft)
          let verification = try mutationVerifier().verifyBodyTableFormat(
            operation: operation,
            before: before,
            beforeStructure: beforeStructure,
            beforeTables: beforeTables,
            beforeCells: beforeCells,
            draft: draft,
            result: write
          )
          return try verifiedBodyTableMutationResult(
            NotesBodyTableFormatResult(
              operation: operation,
              changed: write.changed,
              note: noteSummary(write.note),
              structure: write.structure,
              axis: draft.axis,
              index: draft.index,
              count: draft.count,
              format: draft.format,
              enabled: draft.enabled,
              selectedCellCount: draft.selectedCellCount,
              beforeTarget: write.beforeTarget,
              target: write.target,
              cells: write.cells,
              tables: write.tables,
              beforeTextSliceSHA256: write.beforeTextSliceSHA256,
              afterTextSliceSHA256: write.afterTextSliceSHA256,
              beforeFormatSliceSHA256: write.beforeFormatSliceSHA256,
              afterFormatSliceSHA256: write.afterFormatSliceSHA256,
              verification: verification
            ))
        }
      case ["body", "table", "rows", "insert"],
        ["body", "table", "rows", "delete"],
        ["body", "table", "rows", "move"],
        ["body", "table", "rows", "copy"],
        ["body", "table", "rows", "clear"],
        ["body", "table", "columns", "insert"],
        ["body", "table", "columns", "delete"],
        ["body", "table", "columns", "move"],
        ["body", "table", "columns", "copy"],
        ["body", "table", "columns", "clear"]:
        let usesDestination = ["move", "copy"].contains(options.positionals.last ?? "")
        try validateTargetOptions(options, allowedOptions: usesDestination
          ? ["id", "ordinal", "index", "to"]
          : ["id", "ordinal", "index", "count"])
        try validateMutationIntent(options)
        let draft = try bodyTableStructureDraft(path: options.positionals, options: options)
        let operation = bodyTableStructureOperationName(draft)
        guard let before = try implementation.readNote(id: draft.noteID) else {
          throw CLIError(
            code: .notFound,
            message: "Note was not found.",
            details: ["id_sha256": sha256Hex(draft.noteID)]
          )
        }
        let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
        let beforeTables = try bodyStructureReader().listTables(noteID: draft.noteID)
        return try mutation(
          operation: operation,
          scopeDigest: bodyTableStructureScopeDigest(draft),
          summary: bodyTableStructureSummary(draft),
          options: options,
          dryRunNotes: [
            "Execution changes one Notes table's row or column structure selected by table ordinal and index.",
            "Output verifies private table readback without printing table cell text.",
          ]
        ) {
          let write = try bodyMutator().changeTableStructure(draft)
          let verification = try mutationVerifier().verifyBodyTableStructureChange(
            operation: operation,
            before: before,
            beforeStructure: beforeStructure,
            beforeTables: beforeTables,
            draft: draft,
            result: write
          )
          return try verifiedBodyTableStructureMutationResult(
            NotesBodyTableStructureResult(
              operation: operation,
              changed: write.changed,
              note: noteSummary(write.note),
              structure: write.structure,
              axis: draft.axis,
              action: draft.action,
              index: draft.index,
              toIndex: draft.toIndex,
              count: draft.count,
              beforeTarget: write.beforeTarget,
              target: write.target,
              tables: write.tables,
              movedSliceCellCount: write.movedSliceCellCount,
              movedSliceSHA256: write.movedSliceSHA256,
              copiedSliceCellCount: write.copiedSliceCellCount,
              copiedSliceSHA256: write.copiedSliceSHA256,
              clearedSliceCellCount: write.clearedSliceCellCount,
              clearedSliceSHA256: write.clearedSliceSHA256,
              verification: verification
            ))
        }
    case ["body", "math", "insert"]:
      try validateTargetOptions(options, allowedOptions: ["id", "paragraph", "ordinal", "text"])
      try validateMutationIntent(options)
      let draft = try bodyMathInsertDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeResults = try bodyStructureReader().listMathResults(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.math.insert",
        scopeDigest: bodyMathInsertScopeDigest(draft),
        summary: bodyMathInsertSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution inserts one Notes-recognized math expression and result attachment.",
          "Output verifies private math result readback without printing expression or result text.",
        ]
      ) {
        let write = try bodyMutator().insertMathResult(draft)
        let verification = try mutationVerifier().verifyBodyMathInsert(
          operation: "notes.body.math.insert",
          before: before,
          beforeStructure: beforeStructure,
          beforeResults: beforeResults,
          draft: draft,
          result: write
        )
        return try verifiedBodyMathInsertMutationResult(
          NotesBodyMathInsertResult(
            operation: "notes.body.math.insert",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            target: write.target,
            results: write.results,
            placement: draft.paragraphIDSHA256 != nil ? "after_paragraph" : draft.ordinal != nil ? "after_ordinal" : "append",
            expressionByteCount: draft.expressionByteCount,
            expressionSHA256: draft.expressionSHA256,
            verification: verification
          ))
      }
    case ["body", "math", "update"]:
      try validateTargetOptions(options, allowedOptions: ["id", "ordinal", "text"])
      try validateMutationIntent(options)
      let draft = try bodyMathUpdateDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeResults = try bodyStructureReader().listMathResults(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.math.update",
        scopeDigest: bodyMathUpdateScopeDigest(draft),
        summary: bodyMathUpdateSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution updates one existing Notes math result attachment selected by privacy-safe ordinal.",
          "Output verifies private math result readback without printing expression or result text.",
        ]
      ) {
        let write = try bodyMutator().updateMathResult(draft)
        let verification = try mutationVerifier().verifyBodyMathUpdate(
          operation: "notes.body.math.update",
          before: before,
          beforeStructure: beforeStructure,
          beforeResults: beforeResults,
          draft: draft,
          result: write
        )
        return try verifiedBodyMathMutationResult(
          NotesBodyMathUpdateResult(
            operation: "notes.body.math.update",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            target: write.target,
            results: write.results,
            verification: verification
          ))
      }
    case ["body", "math", "variable", "set"]:
      try validateTargetOptions(options, allowedOptions: ["id", "name", "value", "expression", "paragraph", "ordinal"])
      try validateMutationIntent(options)
      let draft = try bodyMathVariableSetDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeResults = try bodyStructureReader().listMathResults(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.math.variable.set",
        scopeDigest: bodyMathVariableSetScopeDigest(draft),
        summary: bodyMathVariableSetSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution inserts one Notes math variable definition and one dependent expression through the private Notes calculate path.",
          "Output verifies private math readback without printing variable names, values, expressions, results, or note text.",
        ]
      ) {
        let write = try bodyMutator().setMathVariable(draft)
        let verification = try mutationVerifier().verifyBodyMathVariableSet(
          operation: "notes.body.math.variable.set",
          before: before,
          beforeStructure: beforeStructure,
          beforeResults: beforeResults,
          draft: draft,
          result: write
        )
        return try verifiedBodyMathVariableSetMutationResult(
          NotesBodyMathVariableSetResult(
            operation: "notes.body.math.variable.set",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            variableDefinitionResult: write.variableDefinitionResult,
            dependentResult: write.dependentResult,
            results: write.results,
            placement: draft.paragraphIDSHA256 != nil ? "after_paragraph" : draft.ordinal != nil ? "after_ordinal" : "append",
            variableNameByteCount: draft.variableNameByteCount,
            variableNameSHA256: draft.variableNameSHA256,
            variableValueByteCount: draft.variableValueByteCount,
            variableValueSHA256: draft.variableValueSHA256,
            variableDefinitionExpressionByteCount: draft.variableDefinitionExpressionByteCount,
            variableDefinitionExpressionSHA256: draft.variableDefinitionExpressionSHA256,
            dependentExpressionByteCount: draft.dependentExpressionByteCount,
            dependentExpressionSHA256: draft.dependentExpressionSHA256,
            verification: verification
          ))
      }
    case ["body", "math", "variable", "update"]:
      try validateTargetOptions(options, allowedOptions: ["id", "definition-ordinal", "dependent-ordinal", "value"])
      try validateMutationIntent(options)
      let draft = try bodyMathVariableUpdateDraft(options)
      guard let before = try implementation.readNote(id: draft.noteID) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(draft.noteID)]
        )
      }
      let beforeStructure = try bodyStructureReader().readBodyStructure(noteID: draft.noteID)
      let beforeResults = try bodyStructureReader().listMathResults(noteID: draft.noteID)
      return try mutation(
        operation: "notes.body.math.variable.update",
        scopeDigest: bodyMathVariableUpdateScopeDigest(draft),
        summary: bodyMathVariableUpdateSummary(draft),
        options: options,
        dryRunNotes: [
          "Execution updates one selected Notes math variable definition and requires dependent-result readback through the private Notes calculate path.",
          "Output verifies the automatic dependent-result delta without printing variable values, expressions, results, or note text.",
        ]
      ) {
        let write = try bodyMutator().updateMathVariable(draft)
        let verification = try mutationVerifier().verifyBodyMathVariableUpdate(
          operation: "notes.body.math.variable.update",
          before: before,
          beforeStructure: beforeStructure,
          beforeResults: beforeResults,
          draft: draft,
          result: write
        )
        return try verifiedBodyMathVariableUpdateMutationResult(
          NotesBodyMathVariableUpdateResult(
            operation: "notes.body.math.variable.update",
            changed: write.changed,
            note: noteSummary(write.note),
            structure: write.structure,
            beforeDefinition: write.beforeDefinition,
            afterDefinition: write.afterDefinition,
            beforeDependent: write.beforeDependent,
            afterDependent: write.afterDependent,
            results: write.results,
            requestedValueByteCount: draft.variableValueByteCount,
            requestedValueSHA256: draft.variableValueSHA256,
            verification: verification
          ))
      }    default:
      return nil
    }
  }

  private func bodyChecklistAddDraft(_ options: CLIOptions) throws -> NotesBodyChecklistAddDraft {
    NotesBodyChecklistAddDraft(
      noteID: try requiredOption("id", options: options),
      text: try normalizedOption("text", options: options),
      checked: options.hasTargetFlag("checked")
    )
  }

  private func bodyCollapsibleSetDraft(_ options: CLIOptions) throws -> NotesBodyCollapsibleSetDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body collapsible set"
    )
    return NotesBodyCollapsibleSetDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      state: try normalizedCollapsibleStateOption("state", options: options)
    )
  }

  private func bodyChecklistSetDraft(_ options: CLIOptions) throws -> NotesBodyChecklistSetDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body checklist set` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyChecklistSetDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      checked: try normalizedChecklistStateOption("state", options: options)
    )
  }

  private func bodyChecklistSetAllDraft(_ options: CLIOptions) throws -> NotesBodyChecklistSetAllDraft {
    NotesBodyChecklistSetAllDraft(
      noteID: try requiredOption("id", options: options),
      checked: try normalizedChecklistStateOption("state", options: options)
    )
  }

  private func bodyChecklistSortDraft(_ options: CLIOptions) throws -> NotesBodyChecklistSortDraft {
    NotesBodyChecklistSortDraft(noteID: try requiredOption("id", options: options))
  }

  private func bodyChecklistConvertDraft(_ options: CLIOptions) throws -> NotesBodyChecklistConvertDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body checklist convert` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyChecklistConvertDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      checked: try normalizedChecklistStateOption("state", options: options)
    )
  }

  private func bodyChecklistConvertRangeDraft(_ options: CLIOptions) throws -> NotesBodyChecklistConvertRangeDraft {
    let fromOrdinal = try normalizedPositiveIntOption("from-ordinal", options: options)
    let toOrdinal = try normalizedPositiveIntOption("to-ordinal", options: options)
    guard fromOrdinal <= toOrdinal else {
      throw CLIError(
        code: .validationError,
        message: "`--from-ordinal` must be less than or equal to `--to-ordinal`."
      )
    }
    return NotesBodyChecklistConvertRangeDraft(
      noteID: try requiredOption("id", options: options),
      fromOrdinal: fromOrdinal,
      toOrdinal: toOrdinal,
      checked: try normalizedChecklistStateOption("state", options: options)
    )
  }

  private func bodyChecklistReorderDraft(_ options: CLIOptions) throws -> NotesBodyChecklistReorderDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body checklist reorder` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyChecklistReorderDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      targetOrdinal: try normalizedPositiveIntOption("to-ordinal", options: options)
    )
  }

  private func bodyChecklistIndentDraft(_ options: CLIOptions) throws -> NotesBodyChecklistIndentDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body checklist indent` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyChecklistIndentDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      delta: try normalizedChecklistIndentDeltaOption("by", options: options)
    )
  }

  private func bodyChecklistDeleteDraft(_ options: CLIOptions) throws -> NotesBodyChecklistDeleteDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body checklist delete` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyChecklistDeleteDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal
    )
  }

  private func bodyListReorderDraft(_ options: CLIOptions) throws -> NotesBodyListReorderDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body list reorder` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyListReorderDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      targetOrdinal: try normalizedPositiveIntOption("to-ordinal", options: options)
    )
  }

  private func bodyListAddDraft(_ options: CLIOptions) throws -> NotesBodyListAddDraft {
    NotesBodyListAddDraft(
      noteID: try requiredOption("id", options: options),
      text: try normalizedOption("text", options: options),
      style: try normalizedListStyleOption("style", options: options)
    )
  }

  private func bodyListConvertDraft(_ options: CLIOptions) throws -> NotesBodyListConvertDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body list convert` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyListConvertDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      style: try normalizedListStyleOption("style", options: options)
    )
  }

  private func bodyListConvertRangeDraft(_ options: CLIOptions) throws -> NotesBodyListConvertRangeDraft {
    let fromOrdinal = try normalizedPositiveIntOption("from-ordinal", options: options)
    let toOrdinal = try normalizedPositiveIntOption("to-ordinal", options: options)
    guard fromOrdinal <= toOrdinal else {
      throw CLIError(
        code: .validationError,
        message: "`--from-ordinal` must be less than or equal to `--to-ordinal`."
      )
    }
    return NotesBodyListConvertRangeDraft(
      noteID: try requiredOption("id", options: options),
      fromOrdinal: fromOrdinal,
      toOrdinal: toOrdinal,
      style: try normalizedListStyleOption("style", options: options)
    )
  }

  private func bodyListSetStyleDraft(_ options: CLIOptions) throws -> NotesBodyListSetStyleDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body list set-style` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyListSetStyleDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      style: try normalizedListStyleOption("style", options: options)
    )
  }

  private func bodyListIndentDraft(_ options: CLIOptions) throws -> NotesBodyListIndentDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body list indent` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyListIndentDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      delta: try normalizedChecklistIndentDeltaOption("by", options: options)
    )
  }

  private func bodyListDeleteDraft(_ options: CLIOptions) throws -> NotesBodyListDeleteDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`body list delete` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    return NotesBodyListDeleteDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal
    )
  }

  private func bodyListTextInsertDraft(
    _ options: CLIOptions,
    targetKind: NotesBodyListTextInsertTargetKind,
    insertKind: NotesBodyListTextInsertKind,
    commandName: String
  ) throws -> NotesBodyListTextInsertDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(paragraph: paragraph, ordinal: ordinal, commandName: commandName)
    guard targetKind == .ordinaryList || insertKind == .lineBreak else {
      throw CLIError(
        code: .validationError,
        message: "`\(commandName)` does not support checklist tab insertion.",
        details: ["allowed": "line-break"]
      )
    }
    return NotesBodyListTextInsertDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      targetKind: targetKind,
      insertKind: insertKind
    )
  }

  private func bodyListEndDraft(
    _ options: CLIOptions,
    targetKind: NotesBodyListEndTargetKind,
    commandName: String
  ) throws -> NotesBodyListEndDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(paragraph: paragraph, ordinal: ordinal, commandName: commandName)
    return NotesBodyListEndDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      targetKind: targetKind
    )
  }

  private func bodyParagraphStyleDraft(_ options: CLIOptions) throws -> NotesBodyParagraphStyleDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body paragraph style"
    )
    return NotesBodyParagraphStyleDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      style: try normalizedParagraphStyleOption("style", options: options)
    )
  }

  private func bodyParagraphAlignmentDraft(_ options: CLIOptions) throws -> NotesBodyParagraphAlignmentDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body paragraph align"
    )
    return NotesBodyParagraphAlignmentDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      alignment: try normalizedParagraphAlignmentOption("alignment", options: options)
    )
  }

  private func bodyParagraphQuoteDraft(_ options: CLIOptions) throws -> NotesBodyParagraphQuoteDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body paragraph quote"
    )
    return NotesBodyParagraphQuoteDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      enabled: try normalizedInlineStateOption("state", options: options)
    )
  }

  private func bodyInlineFormatDraft(_ options: CLIOptions) throws -> NotesBodyInlineFormatDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body inline format"
    )
    return NotesBodyInlineFormatDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      text: try normalizedOption("text", options: options),
      occurrence: try options.targetOption("occurrence").map { _ in
        try normalizedPositiveIntOption("occurrence", options: options)
      },
      format: try normalizedInlineFormatOption("format", options: options),
      enabled: try normalizedInlineStateOption("state", options: options)
    )
  }

  private func bodyInlineColorDraft(_ options: CLIOptions) throws -> NotesBodyInlineColorDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body inline color"
    )
    return NotesBodyInlineColorDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      text: try normalizedOption("text", options: options),
      occurrence: try options.targetOption("occurrence").map { _ in
        try normalizedPositiveIntOption("occurrence", options: options)
      },
      color: try normalizedInlineColorOption("color", options: options)
    )
  }

  private func bodyInlineFontDraft(_ options: CLIOptions) throws -> NotesBodyInlineFontDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body inline font"
    )
    return NotesBodyInlineFontDraft(
      noteID: try requiredOption("id", options: options),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal,
      text: try normalizedOption("text", options: options),
      occurrence: try options.targetOption("occurrence").map { _ in
        try normalizedPositiveIntOption("occurrence", options: options)
      },
      family: try normalizedOption("family", options: options),
      pointSize: try normalizedFontPointSizeOption("size", options: options)
    )
  }

  func validateParagraphSelector(
    paragraph: String?,
    ordinal: Int?,
    commandName: String
  ) throws {
    guard paragraph != nil || ordinal != nil else {
      throw CLIError(
        code: .validationError,
        message: "`\(commandName)` requires either `--paragraph` or `--ordinal`.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["allowed": "paragraph,ordinal"]
      )
    }
  }

  func validateOptionalParagraphSelector(
    paragraph: String?,
    ordinal: Int?,
    commandName: String
  ) throws {
    guard !(paragraph != nil && ordinal != nil) else {
      throw CLIError(
        code: .validationError,
        message: "`--paragraph` and `--ordinal` cannot be used together.",
        details: ["command": commandName, "allowed": "paragraph,ordinal"]
      )
    }
  }

  private func normalizedCollapsibleStateOption(_ name: String, options: CLIOptions) throws
    -> NotesBodyCollapsibleState
  {
    let value = try normalizedOption(name, options: options).lowercased()
    guard let state = NotesBodyCollapsibleState(rawValue: value) else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be \(NotesBodyCollapsibleState.allowedDescription).",
        details: ["allowed": NotesBodyCollapsibleState.allowedDescription]
      )
    }
    return state
  }

  func normalizedFontPointSizeOption(_ name: String, options: CLIOptions) throws -> Double {
    let value = try normalizedOption(name, options: options)
    guard let size = Double(value), size.isFinite, size >= 1, size <= 288 else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be a font point size from 1 through 288."
      )
    }
    return size
  }

  private func normalizedChecklistIndentDeltaOption(_ name: String, options: CLIOptions) throws -> Int {
    let value = try normalizedOption(name, options: options)
    guard let integer = Int(value), [-1, 1].contains(integer) else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be 1 or -1 for checklist indentation."
      )
    }
    return integer
  }

  private func normalizedChecklistStateOption(_ name: String, options: CLIOptions) throws -> Bool {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "checked", "done", "complete", "completed", "true", "yes", "on", "1":
      return true
    case "open", "unchecked", "todo", "incomplete", "false", "no", "off", "0":
      return false
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be checked or open.",
        details: ["allowed": "checked,open"]
      )
    }
  }

  private func normalizedListStyleOption(_ name: String, options: CLIOptions) throws -> NotesBodyListStyle {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "bulleted", "bullet", "unordered", "ul":
      return .bulleted
    case "dashed", "dash":
      return .dashed
    case "numbered", "number", "ordered", "ol":
      return .numbered
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be \(NotesBodyListStyle.allowedDescription).",
        details: ["allowed": NotesBodyListStyle.allowedDescription]
      )
    }
  }

  func normalizedParagraphStyleOption(_ name: String, options: CLIOptions) throws -> NotesBodyParagraphStyle {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "title":
      return .title
    case "heading", "header":
      return .heading
    case "subheading", "sub-heading", "subhead":
      return .subheading
    case "body", "paragraph":
      return .body
    case "monostyled", "mono", "monospace", "fixed-width", "fixedwidth", "fixed":
      return .monostyled
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be \(NotesBodyParagraphStyle.allowedDescription).",
        details: ["allowed": NotesBodyParagraphStyle.allowedDescription]
      )
    }
  }

  private func normalizedParagraphAlignmentOption(
    _ name: String,
    options: CLIOptions
  ) throws -> NotesBodyParagraphAlignment {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "left":
      return .left
    case "center", "centre", "middle":
      return .center
    case "right":
      return .right
    case "justified", "justify":
      return .justified
    case "natural", "default":
      return .natural
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be \(NotesBodyParagraphAlignment.allowedDescription).",
        details: ["allowed": NotesBodyParagraphAlignment.allowedDescription]
      )
    }
  }

  func normalizedInlineFormatOption(_ name: String, options: CLIOptions) throws -> NotesBodyInlineFormat {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "bold", "b":
      return .bold
    case "italic", "italics", "i":
      return .italic
    case "underline", "underlined", "u":
      return .underline
    case "strikethrough", "strike", "s":
      return .strikethrough
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be \(NotesBodyInlineFormat.allowedDescription).",
        details: ["allowed": NotesBodyInlineFormat.allowedDescription]
      )
    }
  }

  func normalizedInlineStateOption(_ name: String, options: CLIOptions) throws -> Bool {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "on", "enabled", "enable", "true", "yes", "1", "checked", "apply":
      return true
    case "off", "disabled", "disable", "false", "no", "0", "open", "clear", "remove":
      return false
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be on or off.",
        details: ["allowed": "on,off"]
      )
    }
  }

  private func normalizedInlineColorOption(_ name: String, options: CLIOptions) throws -> String? {
    let value = try normalizedOption(name, options: options)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard value.isEmpty == false else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be a named color, #RRGGBB, #RRGGBBAA, or none.",
        details: ["allowed": "named-color,#RRGGBB,#RRGGBBAA,none"]
      )
    }
    switch value.lowercased() {
    case "none", "clear", "remove", "off":
      return nil
    default:
      return value
    }
  }

  private func gatedBodyCapabilityError(
    operation: String,
    capability: String,
    appleCapability: String,
    futureGate: String
  ) -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message:
        "Notes \(appleCapability.replacingOccurrences(of: "_", with: " ")) is gated until private-framework body mutation proof and verifier readback are accepted.",
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": "gated",
        "future_gate": futureGate,
        "required_implementation": "typed_private_notes_framework",
        "required_verifier": "private_framework_body_readback+mutation_delta",
        "backend_calls": "none",
      ]
    )
  }

  private func bodySurfaceSummary(_ structure: NotesBodyStructureRecord) -> NotesBodySurfaceSummary {
    let supportedReadFamilies = structure.isPasswordProtected
      ? []
      : ["collapsible_section_count", "collapsible_section_state", "math_surface_count", "table_count", "table_selector_list"]
    var gatedReadFamilies: [String] = []
    if structure.isPasswordProtected {
      gatedReadFamilies.append("password_protected_body_surface_counts")
    }
    return NotesBodySurfaceSummary(
      tableCount: structure.tableCount,
      collapsibleSectionCount: structure.collapsibleSectionCount,
      collapsedSectionCount: structure.collapsedSectionCount,
      mathAttachmentCount: structure.mathAttachmentCount,
      inlineAttachmentCount: structure.inlineAttachmentCount,
      isMathNote: structure.isMathNote,
      supportedReadFamilies: supportedReadFamilies.sorted(),
      supportedMutationFamilies: structure.isPasswordProtected
        ? []
        : [
          "collapsible_section_create_update",
          "collapsible_section_state",
            "math_result_insert",
            "math_result_update",
            "table_copy",
            "table_convert_from_text",
            "table_convert_to_text",
            "table_create",
            "table_delete",
            "table_move",
            "table_structure_edit",
          "table_update",
        ],
      gatedReadFamilies: gatedReadFamilies.sorted(),
      gatedMutationFamilies: []
    )
  }

  private func bodySurfaceFamilies(_ structure: NotesBodyStructureRecord) -> [NotesBodySurfaceFamilyRecord] {
    let countedStatus = structure.isPasswordProtected ? "unavailable_password_protected" : "counted"
    return [
      NotesBodySurfaceFamilyRecord(
          family: "table",
          readbackStatus: countedStatus,
          mutationStatus: structure.isPasswordProtected
            ? "unavailable_password_protected"
            : "create_update_delete_copy_move_convert_to_text_convert_from_text_structure_supported",
          count: structure.isPasswordProtected ? nil : structure.tableCount,
          evidenceFields: [
            "body_structure.attachmentKindCounts.table",
            "body_structure.tableCount",
            "private_table_copy_supported",
            "private_table_convert_from_text_supported",
            "private_table_convert_to_text_supported",
            "private_table_create_supported",
            "private_table_move_supported",
            "private_table_structure_edit_supported",
            "private_table_update_supported",
          "private_table_delete_supported",
        ]
      ),
      NotesBodySurfaceFamilyRecord(
        family: "math_result",
        readbackStatus: countedStatus,
        mutationStatus: structure.isPasswordProtected
          ? "unavailable_password_protected"
          : "insert_update_supported",
        count: structure.isPasswordProtected ? nil : structure.mathAttachmentCount,
        evidenceFields: [
          "body_structure.attachmentKindCounts.math",
          "body_structure.isMathNote",
          "body_structure.mathAttachmentCount",
          "private_math_result_insert_supported",
          "private_math_result_update_supported",
        ]
      ),
      NotesBodySurfaceFamilyRecord(
        family: "collapsible_section",
        readbackStatus: countedStatus,
        mutationStatus: structure.isPasswordProtected
          ? "unavailable_password_protected"
          : "state_and_create_update_supported",
        count: structure.isPasswordProtected ? nil : structure.collapsibleSectionCount,
        evidenceFields: [
          "body_structure.collapsibleSectionCount",
          "body_structure.collapsedSectionCount",
          "private_collapsible_section_state_readback",
        ]
      ),
    ]
  }

  private func verifyBodySurfaces(
    structure: NotesBodyStructureRecord,
    summary: NotesBodySurfaceSummary,
    surfaces: [NotesBodySurfaceFamilyRecord]
  ) -> NotesMutationVerificationReport {
    let tableSurface = surfaces.first { $0.family == "table" }
    let mathSurface = surfaces.first { $0.family == "math_result" }
    let collapsibleSurface = surfaces.first { $0.family == "collapsible_section" }
    let expectedGatedMutations: [String] = []
    let expectedSupportedMutations = structure.isPasswordProtected
      ? []
      : [
        "collapsible_section_create_update",
        "collapsible_section_state",
          "math_result_insert",
          "math_result_update",
          "table_copy",
          "table_convert_from_text",
          "table_convert_to_text",
          "table_create",
          "table_delete",
          "table_move",
        "table_structure_edit",
        "table_update",
      ]
    var checks = [
      verificationBoolCheck(
        name: "table_surface_accounted",
        expected: true,
        actual: summary.tableCount == structure.tableCount
          && (structure.isPasswordProtected || tableSurface?.count == structure.tableCount)
      ),
      verificationBoolCheck(
        name: "math_surface_accounted",
        expected: true,
        actual: summary.mathAttachmentCount == structure.mathAttachmentCount
          && summary.isMathNote == structure.isMathNote
          && (structure.isPasswordProtected || mathSurface?.count == structure.mathAttachmentCount)
      ),
      verificationBoolCheck(
        name: "collapsible_section_surface_accounted",
        expected: true,
        actual: summary.collapsibleSectionCount == structure.collapsibleSectionCount
          && summary.collapsedSectionCount == structure.collapsedSectionCount
          && summary.collapsedSectionCount <= summary.collapsibleSectionCount
          && (structure.isPasswordProtected || collapsibleSurface?.count == structure.collapsibleSectionCount)
      ),
    ]
    for mutation in expectedSupportedMutations {
      checks.append(
        verificationBoolCheck(
          name: "\(mutation)_supported",
          expected: true,
          actual: summary.supportedMutationFamilies.contains(mutation)
        )
      )
    }
    for mutation in expectedGatedMutations {
      checks.append(
        verificationBoolCheck(
          name: "\(mutation)_gated",
          expected: true,
          actual: summary.gatedMutationFamilies.contains(mutation)
        )
      )
    }
    let warnings = structure.isPasswordProtected
      ? ["password_protected_body_surface_counts_unavailable"]
      : []
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.body.surfaces",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_body_structure_surface_readback",
      targetIDSHA256: sha256Hex(structure.noteID),
      checks: checks,
      warnings: warnings
    )
  }

  private func bodyFormatAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.body.format.audit"
    let records = notesBodyFormatAuditRecords()
    let summary = notesBodyFormatAuditSummary(records)
    let verification = verifyBodyFormatAudit(records: records, summary: summary)
    let response = NotesBodyFormatAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_records: \(summary.supportedRecordCount), delegated_records: \(summary.delegatedRecordCount), gated_records: \(summary.gatedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesBodyFormatAuditRecords() -> [NotesBodyFormatAuditRecord] {
    struct BodyFormatAuditItem {
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
      BodyFormatAuditItem(
        family: "inline_emphasis",
        guideSection: "Format and highlight text",
        status: "supported",
        appleCapability: "bold_italic_underline_strikethrough_text",
        command: "body inline format --id NOTE_ID --paragraph HASH --style bold|italic|underline|strikethrough",
        mechanism: "typed_private_notes_framework_inline_attribute_writer",
        requiredImplementation: "ICTT text-storage inline emphasis mutation",
        requiredVerifier: "private_inline_run_readback+body_hash_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "does_not_print_selected_text_or_body",
        reason: "The accepted inline format writer verifies selected-text hashes and target run readback without printing note content."
      ),
      BodyFormatAuditItem(
        family: "inline_text_color",
        guideSection: "Format and highlight text",
        status: "supported",
        appleCapability: "change_text_color",
        command: "body inline color --id NOTE_ID --paragraph HASH --color COLOR",
        mechanism: "typed_private_notes_framework_inline_attribute_writer",
        requiredImplementation: "private inline foreground-color mutation",
        requiredVerifier: "private_color_run_readback+body_hash_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "does_not_print_selected_text_or_body",
        reason: "The accepted inline color writer records color-family evidence and verifier readback without dumping raw body text."
      ),
      BodyFormatAuditItem(
        family: "inline_highlight_color",
        guideSection: "Format and highlight text",
        status: "supported",
        appleCapability: "highlight_text_and_choose_highlight_color",
        command: "body inline highlight --id NOTE_ID --paragraph HASH --color COLOR",
        mechanism: "typed_private_notes_framework_inline_attribute_writer",
        requiredImplementation: "private inline highlight attribute mutation",
        requiredVerifier: "private_highlight_run_readback+body_hash_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "does_not_print_selected_text_or_body",
        reason: "The accepted highlight writer covers highlight application and color selection with privacy-safe run evidence."
      ),
      BodyFormatAuditItem(
        family: "inline_font_family",
        guideSection: "Format and highlight text",
        status: "supported",
        appleCapability: "change_text_font",
        command: "body inline font --id NOTE_ID --paragraph HASH --style FONT",
        mechanism: "typed_private_notes_framework_inline_font_writer",
        requiredImplementation: "private inline font-family mutation",
        requiredVerifier: "private_font_hash_readback+body_hash_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "font_hashes_without_selected_text",
        reason: "The accepted inline font writer hashes font evidence and verifies target runs without exposing selected text."
      ),
      BodyFormatAuditItem(
        family: "inline_font_size",
        guideSection: "Format and highlight text",
        status: "supported",
        appleCapability: "change_text_size",
        command: "body inline font --id NOTE_ID --paragraph HASH --size SIZE",
        mechanism: "typed_private_notes_framework_inline_font_writer",
        requiredImplementation: "private inline font-size mutation",
        requiredVerifier: "private_font_hash_readback+size_bounds",
        safetyGate: "dry-run/readback",
        privacyBoundary: "font_size_hashes_without_selected_text",
        reason: "The accepted inline font writer supports bounded size changes with hashed verifier evidence."
      ),
      BodyFormatAuditItem(
        family: "paragraph_style",
        guideSection: "Change paragraph styles and text alignment",
        status: "supported",
        appleCapability: "apply_title_heading_subheading_body_monostyled_style",
        command: "body paragraph style --id NOTE_ID --paragraph HASH --style title|heading|subheading|body|monostyled",
        mechanism: "typed_private_notes_framework_paragraph_style_writer",
        requiredImplementation: "ICTT paragraph style mutation plus ICTextStyle.fixedWidthStyle for Monostyled",
        requiredVerifier: "private_paragraph_style_readback+anchor_order_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_text",
        reason: "Paragraph style changes, including Apple's Monostyled style, are accepted with style readback, anchor preservation, and body hash evidence."
      ),
      BodyFormatAuditItem(
        family: "default_new_note_style",
        guideSection: "Change paragraph styles and text alignment",
        status: "supported",
        appleCapability: "change_new_notes_start_with_style",
        command: "settings new-note-style --style STYLE",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private default paragraph-style setting mutation",
        requiredVerifier: "notes_settings_mutation_v1+style_hash_readback",
        safetyGate: "allow-persistent-action/readback",
        privacyBoundary: "style_hash_without_raw_default_value",
        reason: "The accepted settings writer updates the default new-note paragraph style with hash-only readback."
      ),
      BodyFormatAuditItem(
        family: "text_alignment",
        guideSection: "Change paragraph styles and text alignment",
        status: "supported",
        appleCapability: "change_text_alignment",
        command: "body paragraph align --id NOTE_ID --paragraph HASH --alignment left|center|right|natural",
        mechanism: "typed_private_notes_framework_paragraph_style_writer",
        requiredImplementation: "private paragraph alignment mutation",
        requiredVerifier: "private_paragraph_alignment_readback+anchor_order_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_text",
        reason: "Paragraph alignment is accepted with target alignment readback and no raw paragraph text output."
      ),
      BodyFormatAuditItem(
        family: "collapsible_section_create",
        guideSection: "Collapse sections and headings",
        status: "supported",
        appleCapability: "create_collapsible_heading_or_subheading_section",
        command: "body paragraph style --style heading|subheading",
        mechanism: "typed_private_notes_framework_paragraph_style_writer",
        requiredImplementation: "heading/subheading promotion through paragraph style mutation",
        requiredVerifier: "private_collapsible_section_readback+anchor_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "section_hashes_without_heading_text",
        reason: "Heading/subheading promotion is accepted and feeds the existing collapsible-section state reader."
      ),
      BodyFormatAuditItem(
        family: "collapsible_section_state_read",
        guideSection: "Collapse sections and headings",
        status: "supported",
        appleCapability: "list_collapsible_section_state",
        command: "body collapsible list --id NOTE_ID",
        mechanism: "typed_private_notes_framework_outline_state_reader",
        requiredImplementation: "ICOutlineController/ICOutlineState readback",
        requiredVerifier: "private_collapsible_section_state_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "section_hashes_without_heading_text",
        reason: "The accepted collapsible list reader returns state and hashes without section text."
      ),
      BodyFormatAuditItem(
        family: "collapsible_section_collapse_expand",
        guideSection: "Collapse sections and headings",
        status: "supported",
        appleCapability: "collapse_or_expand_section",
        command: "body collapsible set --id NOTE_ID --paragraph HASH --state collapsed|expanded|toggle",
        mechanism: "typed_private_notes_framework_outline_state_writer",
        requiredImplementation: "ICOutlineState mutation",
        requiredVerifier: "private_collapsible_section_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "section_hashes_without_heading_text",
        reason: "The accepted collapsible set writer verifies collapsed/expanded state without printing heading or body text."
      ),
      BodyFormatAuditItem(
        family: "ordinary_list_add",
        guideSection: "Add a list",
        status: "supported",
        appleCapability: "add_bulleted_dashed_numbered_list_item",
        command: "body list add --id NOTE_ID --style bullet|dash|numbered",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list item insertion",
        requiredVerifier: "private_list_anchor_readback+style_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "list_item_hashes_without_text",
        reason: "The accepted ordinary-list add path can create list items with supported list styles and verifier readback."
      ),
      BodyFormatAuditItem(
        family: "ordinary_list_style_change",
        guideSection: "Add a list",
        status: "supported",
        appleCapability: "change_bulleted_dashed_numbered_list_style",
        command: "body list set-style --id NOTE_ID --paragraph HASH --style bullet|dash|numbered",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list style mutation",
        requiredVerifier: "private_list_style_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "list_item_hashes_without_text",
        reason: "The accepted list style writer switches among the official ordinary list styles with style readback."
      ),
      BodyFormatAuditItem(
        family: "ordinary_list_indent_outdent",
        guideSection: "Change a list",
        status: "supported",
        appleCapability: "increase_or_decrease_list_level",
        command: "body list indent --id NOTE_ID --paragraph HASH --ordinal N",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list indentation mutation",
        requiredVerifier: "private_list_indentation_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "list_item_hashes_without_text",
        reason: "The accepted list indentation writer supports level changes with bounded delta and readback evidence."
      ),
      BodyFormatAuditItem(
        family: "ordinary_list_reorder",
        guideSection: "Change a list",
        status: "supported",
        appleCapability: "move_list_item_up_or_down",
        command: "body list reorder --id NOTE_ID --paragraph HASH --to-ordinal N",
        mechanism: "typed_private_notes_framework_list_writer",
        requiredImplementation: "private ordinary-list reorder mutation",
        requiredVerifier: "private_list_anchor_order_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "list_item_hashes_without_text",
        reason: "The accepted list reorder writer verifies anchor order without printing list item text."
      ),
      BodyFormatAuditItem(
        family: "checklist_add",
        guideSection: "Add a list / Change a checklist",
        status: "supported",
        appleCapability: "add_checklist_item",
        command: "body checklist add --id NOTE_ID",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private checklist item insertion",
        requiredVerifier: "private_checklist_count_and_anchor_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "checklist_hashes_without_text",
        reason: "The accepted checklist add writer covers new checklist item creation with count and anchor readback."
      ),
      BodyFormatAuditItem(
        family: "checklist_convert",
        guideSection: "Change a checklist",
        status: "supported",
        appleCapability: "convert_paragraphs_to_checklist",
        command: "body checklist convert; body checklist convert-range",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private paragraph-to-checklist conversion",
        requiredVerifier: "private_checklist_anchor_conversion_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hashes_without_text",
        reason: "Single-paragraph and range checklist conversion are accepted with anchor conversion evidence."
      ),
      BodyFormatAuditItem(
        family: "checklist_set_one",
        guideSection: "Change a checklist",
        status: "supported",
        appleCapability: "check_or_uncheck_one_item",
        command: "body checklist set --id NOTE_ID --paragraph HASH --state checked|unchecked|toggle",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private checklist state mutation",
        requiredVerifier: "private_checklist_item_state_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "checklist_hashes_without_text",
        reason: "The accepted checklist set writer verifies target item state without printing checklist item text."
      ),
      BodyFormatAuditItem(
        family: "checklist_set_all",
        guideSection: "Change a checklist",
        status: "supported",
        appleCapability: "check_or_uncheck_all_items",
        command: "body checklist set-all --id NOTE_ID --state checked|unchecked|toggle",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private checklist batch state mutation",
        requiredVerifier: "private_checklist_open_done_count_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "checklist_hashes_without_text",
        reason: "The accepted checklist set-all writer verifies checked/open counts for the bounded checklist target."
      ),
      BodyFormatAuditItem(
        family: "checklist_auto_sort_setting",
        guideSection: "Change a checklist",
        status: "supported",
        appleCapability: "automatically_sort_checked_items",
        command: "settings checklist-sort --enabled true|false",
        mechanism: "typed_private_notes_framework_settings_writer",
        requiredImplementation: "private checklist auto-sort preference mutation",
        requiredVerifier: "notes_settings_mutation_v1+bool_readback",
        safetyGate: "allow-persistent-action/readback",
        privacyBoundary: "boolean_only_no_account_values",
        reason: "The accepted settings writer updates automatic checked-item sorting with boolean readback."
      ),
      BodyFormatAuditItem(
        family: "checklist_reorder",
        guideSection: "Change a checklist",
        status: "supported",
        appleCapability: "reorder_checklist_items",
        command: "body checklist reorder --id NOTE_ID --paragraph HASH --to-ordinal N",
        mechanism: "typed_private_notes_framework_checklist_writer",
        requiredImplementation: "private checklist item reorder mutation",
        requiredVerifier: "private_checklist_anchor_order_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "checklist_hashes_without_text",
        reason: "The accepted checklist reorder writer verifies checklist anchor order without item text."
      ),
      BodyFormatAuditItem(
        family: "table_create",
        guideSection: "Add a table",
        status: "supported",
        appleCapability: "add_table",
        command: "body table create --id NOTE_ID --text TSV",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "ICNote.addTableAttachmentWithText",
        requiredVerifier: "private_table_count_dimension_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "cell_hashes_without_cell_text",
        reason: "The accepted table create writer appends a table and verifies table count and dimensions."
      ),
      BodyFormatAuditItem(
        family: "table_cell_update",
        guideSection: "Add a table",
        status: "supported",
        appleCapability: "type_or_paste_text_in_table_cell",
        command: "body table update --id NOTE_ID --ordinal N --row R --column C --text TEXT",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "ICTable.setAttributedString:columnIndex:rowIndex:",
        requiredVerifier: "private_table_cell_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "cell_hashes_without_cell_text",
        reason: "The accepted table update writer replaces one selected cell with hash-only verifier evidence."
      ),
      BodyFormatAuditItem(
        family: "table_convert_to_text",
        guideSection: "Convert text to a table",
        status: "supported",
        appleCapability: "convert_table_back_to_text",
        command: "body table convert-to-text --id NOTE_ID --ordinal N",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "ICTable string extraction plus ICNote textStorage replacement",
        requiredVerifier: "private_table_absence_and_body_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_hashes_without_cell_text",
        reason: "The accepted table convert-to-text writer verifies table removal and body hash changes without printing cell text."
      ),
      BodyFormatAuditItem(
        family: "table_row_column_insert_delete",
        guideSection: "Manage rows and columns",
        status: "supported",
        appleCapability: "add_or_remove_table_rows_or_columns",
        command: "body table rows insert/delete; body table columns insert/delete",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table row/column structure mutation",
        requiredVerifier: "private_table_dimension_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_dimension_hashes_without_cell_text",
        reason: "Row and column insertion/deletion are accepted with dimension and structure readback."
      ),
      BodyFormatAuditItem(
        family: "table_row_column_move_copy_clear",
        guideSection: "Manage rows and columns",
        status: "supported",
        appleCapability: "move_copy_or_clear_table_rows_or_columns",
        command: "body table rows move/copy/clear; body table columns move/copy/clear",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "private table row/column move/copy/clear mutation",
        requiredVerifier: "private_table_dimension_and_cell_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_hashes_without_cell_text",
        reason: "Row and column move/copy/clear are accepted with structure and cell-hash verification."
      ),
      BodyFormatAuditItem(
        family: "touch_bar_list_checklist",
        guideSection: "Add a list / Add a table",
        status: "delegated",
        appleCapability: "use_touch_bar_formatting_controls",
        command: "macOS Touch Bar / Notes.app UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_touch_bar_control_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Touch Bar controls are a Notes.app/macOS interaction surface, not persisted Notes data behavior owned by the CLI."
      ),
      BodyFormatAuditItem(
        family: "keyboard_shortcuts_and_menu_ui",
        guideSection: "Format notes / Add lists / Add a table",
        status: "delegated",
        appleCapability: "use_format_menu_and_keyboard_shortcuts",
        command: "Notes.app Format/Edit menu and keyboard shortcuts",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_menu_keyboard_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The CLI exposes semantic commands; menu clicks and keyboard shortcut dispatch stay in the user-facing app."
      ),
      BodyFormatAuditItem(
        family: "table_keyboard_navigation_selection",
        guideSection: "Add a table / Manage rows and columns",
        status: "delegated",
        appleCapability: "navigate_and_select_table_cells_rows_columns",
        command: "Notes.app table focus and selection UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_table_selection_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Keyboard navigation and drag selection are transient UI state, while semantic table mutations are accepted separately."
      ),
      BodyFormatAuditItem(
        family: "typing_suggestions",
        guideSection: "Add a table",
        status: "delegated",
        appleCapability: "use_typing_suggestions_in_table_cells",
        command: "macOS text input suggestions",
        mechanism: "delegated_system_text_input_surface",
        requiredImplementation: "system_text_input_route",
        requiredVerifier: "delegated_text_input_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Typing suggestions are a system text-input feature and are not a Notes private data mutation."
      ),
      BodyFormatAuditItem(
        family: "list_end_to_paragraph",
        guideSection: "Change a list",
        status: "supported",
        appleCapability: "end_list_and_add_new_paragraph",
        command: "body list end --id NOTE_ID --paragraph HASH; body checklist end --id NOTE_ID --paragraph HASH",
        mechanism: "typed_private_notes_framework_list_end_writer",
        requiredImplementation: "private list/checklist body-paragraph insertion",
        requiredVerifier: "private_list_target_preservation_and_created_body_paragraph_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "does_not_print_list_item_or_paragraph_text",
        reason: "The accepted list/checklist end writer preserves the target item and verifies one new ordinary body paragraph without printing item or paragraph text."
      ),
      BodyFormatAuditItem(
        family: "list_soft_return",
        guideSection: "Change a list",
        status: "supported",
        appleCapability: "add_soft_return_inside_list_item",
        command: "body list line-break --id NOTE_ID --paragraph HASH; body checklist line-break --id NOTE_ID --paragraph HASH",
        mechanism: "typed_private_notes_framework_list_text_storage_writer",
        requiredImplementation: "private list/checklist item text-storage line-separator mutation",
        requiredVerifier: "private_body_structure_list_text_insert_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "does_not_print_list_item_text",
        reason: "Soft returns inside list and checklist items are accepted through bounded text-storage mutation and body-structure readback."
      ),
      BodyFormatAuditItem(
        family: "table_move",
        guideSection: "Add a table",
        status: "supported",
        appleCapability: "move_table_to_new_location",
        command: "body table move --id NOTE_ID --ordinal N --to-ordinal M",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "ICNote.textStorage table attachment attributed-run reorder",
        requiredVerifier: "private_table_order_readback+table_set_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "table_hashes_without_cell_text",
        reason: "Whole-table movement by table ordinal is accepted with private table order readback and no table cell text output."
      ),
	      BodyFormatAuditItem(
	        family: "table_row_column_formatting",
	        guideSection: "Manage rows and columns",
	        status: "supported",
	        appleCapability: "apply_formatting_to_table_row_or_column",
	        command: "body table rows format --id NOTE_ID --ordinal N --index I [--count C] --format bold|italic|underline|strikethrough; body table columns format --id NOTE_ID --ordinal N --index I [--count C] --format bold|italic|underline|strikethrough",
	        mechanism: "typed_private_notes_framework_table_cell_range_format_writer",
	        requiredImplementation: "typed_private_notes_framework_table_cell_range_format_writer",
	        requiredVerifier: "private_table_range_format_readback+text_hash_preservation",
	        safetyGate: "dry-run/readback",
	        privacyBoundary: "cell_text_hashes_and_format_hashes_without_cell_text",
	        reason: "Row and column inline style ranges are accepted through private table cell attributed-string mutation with per-cell text-hash preservation and format readback."
	      ),
      BodyFormatAuditItem(
        family: "text_selection_to_table",
        guideSection: "Convert text to a table",
        status: "supported",
        appleCapability: "convert_selected_text_to_table",
        command: "body table convert-from-text --id NOTE_ID --paragraph HASH",
        mechanism: "typed_private_notes_framework_table_writer",
        requiredImplementation: "ICNote.addTableAttachmentWithText plus ICNote.textStorage paragraph replacement",
        requiredVerifier: "private_source_paragraph_absence_and_table_cell_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "source_text_hashes_without_text",
        reason: "The accepted selected-text conversion replaces one ordinary body paragraph with a private Notes table and verifies source paragraph removal, table dimensions, and cell hashes without printing source text."
      ),
      BodyFormatAuditItem(
        family: "external_table_paste_conversion",
        guideSection: "Add a table",
        status: "supported",
        appleCapability: "paste_table_from_other_app",
        command: "body table import --id NOTE_ID (--text TSV|--file PATH) [--format tsv|csv]",
        mechanism: "typed_private_notes_framework_external_table_import_writer",
        requiredImplementation: "ICNote.addTableAttachmentWithText plus explicit TSV/CSV input normalization",
        requiredVerifier: "private_table_import_fidelity_readback+cell_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "source_hashes_without_cell_text_or_local_file_paths",
        reason: "The CLI supports the persisted conversion equivalent of pasting an external table by importing explicit TSV or CSV table text, normalizing it to Notes table input, and verifying row, column, and cell-hash readback without printing source cell text or local file paths. The menu/keyboard paste interaction itself remains a delegated UI route."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesBodyFormatAuditRecord(
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

  private func notesBodyFormatAuditSummary(
    _ records: [NotesBodyFormatAuditRecord]
  ) -> NotesBodyFormatAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesBodyFormatAuditSummary(
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

  private func verifyBodyFormatAudit(
    records: [NotesBodyFormatAuditRecord],
    summary: NotesBodyFormatAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "inline_formatting_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "inline_emphasis", "inline_text_color", "inline_highlight_color",
            "inline_font_family", "inline_font_size",
          ]
        )
      ),
      verificationBoolCheck(
        name: "paragraph_and_collapsible_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "paragraph_style", "default_new_note_style", "text_alignment",
            "collapsible_section_create", "collapsible_section_state_read",
            "collapsible_section_collapse_expand",
          ]
        )
      ),
      verificationBoolCheck(
        name: "list_and_checklist_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "ordinary_list_add", "ordinary_list_style_change", "ordinary_list_indent_outdent",
            "ordinary_list_reorder", "checklist_add", "checklist_convert", "checklist_set_one",
            "checklist_set_all", "checklist_auto_sort_setting", "checklist_reorder",
            "list_end_to_paragraph", "list_soft_return",
          ]
        )
      ),
      verificationBoolCheck(
        name: "table_structure_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "table_create", "table_cell_update", "table_convert_to_text",
            "text_selection_to_table", "table_move", "table_row_column_insert_delete",
            "table_row_column_move_copy_clear", "table_row_column_formatting",
            "external_table_paste_conversion",
          ]
        )
      ),
      verificationBoolCheck(
        name: "ui_interactions_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "touch_bar_list_checklist", "keyboard_shortcuts_and_menu_ui",
            "table_keyboard_navigation_selection", "typing_suggestions",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_format_semantics_gated",
        expected: true,
        actual: gated.isEmpty
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
      operation: "notes.body.format.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.body.format.audit"),
      checks: checks
    )
  }

  private func verifyBodyCollapsibleSections(
    structure: NotesBodyStructureRecord,
    sections: [NotesBodyCollapsibleSectionRecord]
  ) -> NotesMutationVerificationReport {
    let collapsedCount = sections.filter { $0.collapsed }.count
    let checks = [
      verificationBoolCheck(
        name: "collapsible_section_count",
        expected: true,
        actual: sections.count == structure.collapsibleSectionCount
      ),
      verificationBoolCheck(
        name: "collapsed_section_count",
        expected: true,
        actual: collapsedCount == structure.collapsedSectionCount
      ),
      verificationBoolCheck(
        name: "section_ordinals_are_stable",
        expected: true,
        actual: sections.enumerated().allSatisfy { index, section in section.ordinal == index + 1 }
      ),
      verificationBoolCheck(
        name: "section_paragraph_hashes_present",
        expected: true,
        actual: sections.allSatisfy { !$0.paragraphIDSHA256.isEmpty }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.body.collapsible.list",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_outline_controller_section_readback",
      targetIDSHA256: sha256Hex(structure.noteID),
      checks: checks,
      warnings: structure.isPasswordProtected ? ["password_protected_body_surface_counts_unavailable"] : []
    )
  }

  func bodyStructureReader() throws -> any NotesBodyStructureReading {
    guard let bodyStructureReader = implementation as? any NotesBodyStructureReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes body structure commands require a private-framework body reader.",
        details: [
          "capability": "body_structure",
          "required_module": "NotesShared",
        ]
      )
    }
    return bodyStructureReader
  }

  private func bodyMutator() throws -> any NotesBodyMutating {
    guard let bodyMutator = implementation as? any NotesBodyMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes body mutation commands require a private-framework body writer.",
        details: [
          "capability": "body_mutation",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return bodyMutator
  }

  private func verifiedBodyChecklistMutationResult(
    _ result: NotesBodyChecklistMutationResult
  ) throws -> NotesBodyChecklistMutationResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body checklist mutation verification failed.",
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

  private func verifiedBodyListTextInsertMutationResult(
    _ result: NotesBodyListTextInsertMutationResult
  ) throws -> NotesBodyListTextInsertMutationResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body list text insertion verification failed.",
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

  private func verifiedBodyListEndMutationResult(
    _ result: NotesBodyListEndMutationResult
  ) throws -> NotesBodyListEndMutationResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body list end verification failed.",
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

  private func verifiedBodyCollapsibleMutationResult(
    _ result: NotesBodyCollapsibleSetMutationResult
  ) throws -> NotesBodyCollapsibleSetMutationResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body collapsible section mutation verification failed.",
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
