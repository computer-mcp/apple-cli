import Foundation
import Utility

extension NotesCommand {
  func runReadSearch(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["notes", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account", "folder"])
      let notes = try listVisibleNotes(options, limit: try commandLimit(options))
      return try result(
        NotesListResponse(notes: notes),
        human: notes.map { "\($0.id)\t\($0.folderName)\t\($0.title)" }.joined(separator: "\n"),
        options: options
      )
    case ["notes", "search", "audit"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try searchAudit(options)
    case ["notes", "search", "natural-language"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "folder", "account"])
      return try searchNaturalLanguage(options)
    case ["notes", "search", "attachment-content"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "folder", "id", "account", "family"])
      return try searchAttachmentContent(options)
    case ["notes", "search", "locked-title"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "folder", "account"])
      let query = try notesSearchQuery(options)
      let notes = try searchLockedTitleNotes(options, query: query)
      return try result(
        NotesListResponse(notes: notes),
        human: notes.map { "\($0.id)\t\($0.folderName)\t\($0.title)" }.joined(separator: "\n"),
        options: options
      )
    case ["notes", "search"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(
        options,
        allowedOptions: ["query", "folder", "id", "account", "scope"],
        allowedFlags: ["include-recently-deleted"]
      )
      let query = try notesSearchQuery(options)
      let scope = try notesSearchScope(options)
      let notes: [NotesNoteSummary]
      switch scope {
      case "text":
        notes = try searchTextNotes(options, query: query)
      case "attachment-name":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "attachment_name_search",
          appleCapability: "search_attachment_filenames",
          futureGate: "supported_by_attachments_search",
          requiredImplementation: "apple notes attachments search --query QUERY [--folder FOLDER|--id NOTE_ID]",
          requiredVerifier: "notes.attachments.search metadata_only_batch_readback"
        )
      case "audio-transcript":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "audio_transcript_search",
          appleCapability: "search_existing_audio_transcripts",
          futureGate: "supported_by_attachments_audio_search",
          requiredImplementation: "apple notes attachments audio search --query QUERY [--folder FOLDER|--id NOTE_ID]",
          requiredVerifier: "private_audio_document_readback+privacy_hash_accounting"
        )
      case "pdf-content":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "pdf_text_search",
          appleCapability: "search_pdf_text",
          futureGate: "supported_by_attachments_pdf_search",
          requiredImplementation: "apple notes attachments pdf search --query QUERY [--folder FOLDER|--id NOTE_ID]",
          requiredVerifier: "private_attachment_pdf_readback+pdfkit_text_hash_accounting"
        )
      case "suggested":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "suggested_searches",
          appleCapability: "suggested_searches",
          futureGate: "semantic_commands_cover_suggested_search_families",
          requiredImplementation: "state audit/read, smart-folders notes/criteria, tags search, attachments list/audit",
          requiredVerifier: "capability_specific_readback_for_selected_suggested_family"
        )
      case "natural-language":
        return try searchNaturalLanguage(options)
      case "attachment-content":
        return try searchAttachmentContent(options)
      case "locked-title":
        notes = try searchLockedTitleNotes(options, query: query)
      case "scanned-document-text":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "scanned_document_ocr_search",
          appleCapability: "scanned_document_ocr_text_search",
          futureGate: "supported_by_attachments_scan_search",
          requiredImplementation: "apple notes attachments scan search --query QUERY [--folder FOLDER|--id NOTE_ID]",
          requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary"
        )
      case "image-content":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "image_content_search",
          appleCapability: "image_text_object_search",
          futureGate: "supported_by_attachments_image_search",
          requiredImplementation: "apple notes attachments image search --query QUERY [--folder FOLDER|--id NOTE_ID]",
          requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary"
        )
      case "drawing-content", "handwriting":
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "delegated",
          capability: "drawing_handwriting_search",
          appleCapability: scope == "handwriting" ? "handwriting_search" : "drawing_search",
          futureGate: "supported_by_attachments_drawing_search",
          requiredImplementation: "apple notes attachments drawing search --query QUERY [--folder FOLDER|--id NOTE_ID]",
          requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary"
        )
      default:
        throw notesSearchBoundaryError(
          query: query,
          scope: scope,
          status: "gated",
          capability: "attachment_content_search",
          appleCapability: scope,
          futureGate: "private_notes_attachment_content_index_readback",
          requiredImplementation: "typed_private_notes_framework_attachment_content_search",
          requiredVerifier: "private_framework_attachment_content_readback+privacy_hash_accounting"
        )
      }
      return try result(
        NotesListResponse(notes: notes),
        human: notes.map { "\($0.id)\t\($0.folderName)\t\($0.title)" }.joined(separator: "\n"),
        options: options
      )
    case ["notes", "index"], ["notes", "semantic-search"]:
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes index and RAG-adjacent workflows are outside the notes CLI contract.",
        details: ["command": options.positionals.joined(separator: " ")]
      )
    case ["notes", "read"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "title", "folder"])
      let note = try resolveRead(options)
      return try result(
        NotesReadResponse(note: note),
        human: noteHumanOutput(note),
        options: options
      )    default:
      return nil
    }
  }

  private func searchAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.search.audit"
    let records = notesSearchAuditRecords()
    let summary = notesSearchAuditSummary(records)
    let verification = verifySearchAudit(records: records, summary: summary)
    let response = NotesSearchAuditResponse(
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

  private func notesSearchAuditRecords() -> [NotesSearchAuditRecord] {
    struct SearchAuditItem {
      var family: String
      var scope: String
      var status: String
      var appleCapability: String
      var command: String
      var mechanism: String
      var requiredImplementation: String
      var requiredVerifier: String
      var queryRequired: Bool
      var privacyBoundary: String
      var reason: String
    }

    let items = [
      SearchAuditItem(
        family: "visible_text",
        scope: "text",
        status: "supported",
        appleCapability: "search_note_body_and_title",
        command: "notes search --query QUERY [--folder FOLDER] [--scope text]",
        mechanism: "typed_private_notes_framework_visible_note_search",
        requiredImplementation: "NotesShared visible-note title/body summary search",
        requiredVerifier: "private_framework_search_result_readback+body_redaction_checks",
        queryRequired: true,
        privacyBoundary: "returns_note_summaries_only",
        reason: "Accepted default Notes text search uses the private visible-note title/body summary path."
      ),
      SearchAuditItem(
        family: "account_scoped_text",
        scope: "text",
        status: "supported",
        appleCapability: "search_in_specific_account",
        command: "notes search --account ACCOUNT --query QUERY [--folder FOLDER] [--scope text]",
        mechanism: "typed_private_notes_framework_account_scoped_search",
        requiredImplementation: "NotesShared account-scoped visible-note search",
        requiredVerifier: "private_framework_account_scoped_search_readback+selector_hash_accounting",
        queryRequired: true,
        privacyBoundary: "does_not_print_raw_account_or_note_body",
        reason: "Accepted account-scoped text search limits visible-note search to one selected account."
      ),
      SearchAuditItem(
        family: "single_note_text",
        scope: "text",
        status: "supported",
        appleCapability: "search_in_specific_note",
        command: "notes search --id NOTE_ID --query QUERY [--scope text]",
        mechanism: "typed_private_notes_framework_single_note_readback",
        requiredImplementation: "private note read plus command-layer title/body match",
        requiredVerifier: "selected_note_readback+body_redaction_checks",
        queryRequired: true,
        privacyBoundary: "returns_selected_note_summary_only",
        reason: "Accepted single-note text search reads one selected note and returns only a summary when matched."
      ),
      SearchAuditItem(
        family: "attachment_name",
        scope: "attachment-name",
        status: "delegated",
        appleCapability: "search_attachment_filenames",
        command: "notes attachments search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_attachment_metadata_command",
        requiredImplementation: "attachments search metadata-only private reader",
        requiredVerifier: "notes.attachments.search metadata_only_batch_readback",
        queryRequired: true,
        privacyBoundary: "query_hash_and_metadata_only",
        reason: "`notes search --scope attachment-name` delegates to the accepted attachment metadata search command."
      ),
      SearchAuditItem(
        family: "pdf_content",
        scope: "pdf-content",
        status: "delegated",
        appleCapability: "search_pdf_text",
        command: "notes attachments pdf search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_pdf_attachment_command",
        requiredImplementation: "private PDF bytes plus PDFKit text hash accounting",
        requiredVerifier: "private_attachment_pdf_readback+pdfkit_text_hash_accounting",
        queryRequired: true,
        privacyBoundary: "does_not_print_pdf_text_or_raw_query",
        reason: "`notes search --scope pdf-content` delegates to the accepted PDF attachment text search command."
      ),
      SearchAuditItem(
        family: "audio_transcript",
        scope: "audio-transcript",
        status: "delegated",
        appleCapability: "search_existing_audio_transcripts",
        command: "notes attachments audio search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_audio_transcript_command",
        requiredImplementation: "private audio-document transcript/summary readback",
        requiredVerifier: "private_audio_document_readback+privacy_hash_accounting",
        queryRequired: true,
        privacyBoundary: "does_not_print_transcript_text_or_raw_query",
        reason: "`notes search --scope audio-transcript` delegates to the accepted existing-audio transcript search command."
      ),
      SearchAuditItem(
        family: "suggested_searches",
        scope: "suggested",
        status: "delegated",
        appleCapability: "suggested_searches",
        command: "notes state audit/read, smart-folders notes/criteria, tags search, attachments list/audit",
        mechanism: "semantic_notes_family_commands",
        requiredImplementation: "capability-specific semantic commands for selected suggested families",
        requiredVerifier: "capability_specific_readback_for_selected_suggested_family",
        queryRequired: false,
        privacyBoundary: "family_specific_hash_or_count_accounting",
        reason: "Suggested searches are accounted through accepted semantic commands instead of one opaque search parser."
      ),
      SearchAuditItem(
        family: "siri_search",
        scope: "siri",
        status: "delegated",
        appleCapability: "siri_notes_search",
        command: "system Siri surface",
        mechanism: "delegated_system_surface",
        requiredImplementation: "macos_siri_route",
        requiredVerifier: "delegated_siri_accounting",
        queryRequired: true,
        privacyBoundary: "no_backend_calls",
        reason: "Siri query execution belongs to the system Siri surface, not the Notes private-framework CLI writer."
      ),
      SearchAuditItem(
        family: "spotlight_search",
        scope: "spotlight",
        status: "delegated",
        appleCapability: "spotlight_notes_results",
        command: "system Spotlight surface",
        mechanism: "delegated_system_surface",
        requiredImplementation: "macos_spotlight_route",
        requiredVerifier: "delegated_spotlight_accounting",
        queryRequired: true,
        privacyBoundary: "no_backend_calls",
        reason: "Spotlight result ranking and dispatch belong to the macOS Spotlight surface."
      ),
      SearchAuditItem(
        family: "natural_language",
        scope: "natural-language",
        status: "supported",
        appleCapability: "natural_language_search",
        command: "notes search natural-language --query QUERY",
        mechanism: "typed_private_notes_framework_natural_language_search",
        requiredImplementation: "ICSearchQueryOperation performNLSearch with private NL query readback",
        requiredVerifier: "private_framework_nl_query_readback+search_result_note_mapping+query_hash_accounting",
        queryRequired: true,
        privacyBoundary: "query_hash_and_note_summaries_without_note_bodies",
        reason: "`notes search natural-language --query QUERY` runs Notes' private natural-language search operation, maps private search results back to note summaries, and reports query hash/accounting evidence without printing the raw query or note bodies."
      ),
      SearchAuditItem(
        family: "scanned_document_ocr",
        scope: "scanned-document-text",
        status: "delegated",
        appleCapability: "scanned_document_ocr_text_search",
        command: "notes attachments scan search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_attachment_searchable_text_command",
        requiredImplementation: "typed private attachment searchable/indexable text reader",
        requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary",
        queryRequired: true,
        privacyBoundary: "does_not_print_scan_images_or_raw_recognized_text",
        reason: "`notes search --scope scanned-document-text` delegates to the accepted scan attachment searchable-text search command."
      ),
      SearchAuditItem(
        family: "image_content",
        scope: "image-content",
        status: "delegated",
        appleCapability: "image_text_object_search",
        command: "notes attachments image search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_attachment_searchable_text_command",
        requiredImplementation: "typed private attachment searchable/indexable text reader",
        requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary",
        queryRequired: true,
        privacyBoundary: "does_not_print_image_bytes_or_raw_recognized_text",
        reason: "`notes search --scope image-content` delegates to the accepted image attachment searchable-text search command; image classification summary readback is supported separately by `attachments image objects`."
      ),
      SearchAuditItem(
        family: "drawing_content",
        scope: "drawing-content",
        status: "delegated",
        appleCapability: "drawing_search",
        command: "notes attachments drawing search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_attachment_searchable_text_command",
        requiredImplementation: "typed private attachment searchable/indexable text reader",
        requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary",
        queryRequired: true,
        privacyBoundary: "does_not_print_drawing_bytes_or_raw_recognized_text",
        reason: "`notes search --scope drawing-content` delegates to the accepted drawing attachment searchable-text search command."
      ),
      SearchAuditItem(
        family: "handwriting",
        scope: "handwriting",
        status: "delegated",
        appleCapability: "handwritten_text_search",
        command: "notes attachments drawing search --query QUERY [--folder FOLDER|--id NOTE_ID]",
        mechanism: "semantic_notes_attachment_searchable_text_command",
        requiredImplementation: "typed private attachment searchable/indexable text reader",
        requiredVerifier: "private_attachment_searchable_text_readback+query_hash_accounting+privacy_boundary",
        queryRequired: true,
        privacyBoundary: "does_not_print_handwriting_or_raw_recognized_text",
        reason: "`notes search --scope handwriting` delegates to the accepted drawing attachment searchable-text search command."
      ),
      SearchAuditItem(
        family: "attachment_content",
        scope: "attachment-content",
        status: "supported",
        appleCapability: "composite_attachment_content_search",
        command: "notes search attachment-content --query QUERY [--folder FOLDER|--id NOTE_ID] [--family FAMILY]",
        mechanism: "semantic_private_attachment_content_composite",
        requiredImplementation: "private attachment metadata, PDF text, audio transcript, and searchable-text readers",
        requiredVerifier: "private_framework_attachment_content_composite_readback+privacy_hash_accounting",
        queryRequired: true,
        privacyBoundary: "does_not_print_raw_attachment_text_or_raw_query",
        reason: "`notes search attachment-content --query QUERY` is accepted as a composite over private-backed metadata, PDF text, existing audio transcript, and scan/image/drawing searchable-text slices; recognized-text artifact generation, selected-attachment search indexing, natural-language search, and image classification summary readback are supported separately."
      ),
      SearchAuditItem(
        family: "recently_deleted_search",
        scope: "recently-deleted",
        status: "supported",
        appleCapability: "recently_deleted_notes_included_in_search",
        command: "notes search --query QUERY --include-recently-deleted",
        mechanism: "typed_private_notes_framework_restorable_note_search",
        requiredImplementation: "restore-only private restorable-note reader plus visible-note text search",
        requiredVerifier: "private_visible_and_restorable_search_readback+body_redaction_checks",
        queryRequired: true,
        privacyBoundary: "returns_note_summaries_only_without_deleted_note_bodies",
        reason: "Recently Deleted inclusion is accepted through restore-only private note readback merged with visible text search while returning only note summaries."
      ),
      SearchAuditItem(
        family: "locked_note_title_only",
        scope: "locked-title",
        status: "supported",
        appleCapability: "locked_note_title_only_search",
        command: "notes search locked-title --query QUERY",
        mechanism: "typed_private_notes_framework_locked_title_search",
        requiredImplementation: "private visible-note summary listing plus private note-state readback",
        requiredVerifier: "locked_title_only_readback+locked_body_non_disclosure",
        queryRequired: true,
        privacyBoundary: "returns_locked_note_summaries_only_without_body_matching",
        reason: "`notes search locked-title --query QUERY` uses private visible-note summaries and note-state readback to match password-protected or locked notes by title only."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesSearchAuditRecord(
        ordinal: index + 1,
        searchFamily: item.family,
        scope: item.scope,
        status: item.status,
        appleCapability: item.appleCapability,
        command: item.command,
        implementationMechanism: item.mechanism,
        requiredImplementation: item.requiredImplementation,
        requiredVerifier: item.requiredVerifier,
        queryRequired: item.queryRequired,
        backendCalls: "none",
        privacyBoundary: item.privacyBoundary,
        reason: item.reason
      )
    }
  }

  private func notesSearchAuditSummary(_ records: [NotesSearchAuditRecord]) -> NotesSearchAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesSearchAuditSummary(
      supportedRecordCount: supported.count,
      delegatedRecordCount: delegated.count,
      gatedRecordCount: gated.count,
      rejectedRecordCount: rejected.count,
      queryRequiredForExecution: records.contains { $0.queryRequired },
      auditRequiresQuery: false,
      backendCalls: "none",
      supportedSearchFamilies: supported.map(\.searchFamily),
      delegatedSearchFamilies: delegated.map(\.searchFamily),
      gatedSearchFamilies: gated.map(\.searchFamily),
      rejectedSearchFamilies: rejected.map(\.searchFamily)
    )
  }

  private func verifySearchAudit(
    records: [NotesSearchAuditRecord],
    summary: NotesSearchAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedSearchFamilies)
    let delegated = Set(summary.delegatedSearchFamilies)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "text_search_surfaces_supported",
        expected: true,
        actual: supported.isSuperset(of: ["visible_text", "account_scoped_text", "single_note_text"])
      ),
      verificationBoolCheck(
        name: "delegated_semantic_searches_accounted",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "attachment_name", "pdf_content", "audio_transcript", "suggested_searches",
            "scanned_document_ocr", "image_content", "drawing_content", "handwriting",
          ]
        )
      ),
      verificationBoolCheck(
        name: "delegated_system_searches_accounted",
        expected: true,
        actual: delegated.isSuperset(of: ["siri_search", "spotlight_search"])
      ),
      verificationBoolCheck(
        name: "visual_searchable_text_searches_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: ["scanned_document_ocr", "image_content", "drawing_content", "handwriting"]
        )
      ),
      verificationBoolCheck(
        name: "natural_language_search_supported",
        expected: true,
        actual: supported.contains("natural_language")
      ),
      verificationBoolCheck(
        name: "composite_attachment_content_search_supported",
        expected: true,
        actual: supported.contains("attachment_content")
      ),
      verificationBoolCheck(
        name: "recently_deleted_search_supported",
        expected: true,
        actual: supported.contains("recently_deleted_search")
      ),
      verificationBoolCheck(
        name: "locked_note_title_search_supported",
        expected: true,
        actual: supported.contains("locked_note_title_only")
      ),
      verificationBoolCheck(
        name: "audit_has_no_query_input",
        expected: false,
        actual: summary.auditRequiresQuery
      ),
      verificationBoolCheck(
        name: "backend_calls_none",
        expected: true,
        actual: summary.backendCalls == "none" && records.allSatisfy { $0.backendCalls == "none" }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.search.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.search.audit"),
      checks: checks
    )
  }

  func notesSearchQuery(_ options: CLIOptions) throws -> String {
    let query = try requiredOption("query", options: options)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard query.count >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "`--query` must contain at least 2 non-whitespace characters."
      )
    }
    return query
  }

  private func notesSearchScope(_ options: CLIOptions) throws -> String {
    let raw = options.targetOption("scope")?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let raw, !raw.isEmpty else {
      return "text"
    }
    let normalized = raw
      .lowercased()
      .replacingOccurrences(of: "_", with: "-")
      .replacingOccurrences(of: " ", with: "-")
    let aliases = [
      "default": "text",
      "text": "text",
      "note-text": "text",
      "notes-text": "text",
      "title-body": "text",
      "body-title": "text",
      "attachment-name": "attachment-name",
      "attachment-names": "attachment-name",
      "attachment-filename": "attachment-name",
      "attachment-filenames": "attachment-name",
      "attachment-metadata": "attachment-name",
      "filename": "attachment-name",
      "filenames": "attachment-name",
      "audio": "audio-transcript",
      "audio-transcript": "audio-transcript",
      "audio-transcripts": "audio-transcript",
      "transcript": "audio-transcript",
      "transcripts": "audio-transcript",
      "suggested": "suggested",
      "suggested-search": "suggested",
      "suggested-searches": "suggested",
      "natural-language": "natural-language",
      "nl": "natural-language",
      "attachment-content": "attachment-content",
      "attachments-content": "attachment-content",
      "locked": "locked-title",
      "locked-title": "locked-title",
      "locked-note-title": "locked-title",
      "locked-notes-title": "locked-title",
      "pdf": "pdf-content",
      "pdf-content": "pdf-content",
      "pdf-text": "pdf-content",
      "drawing": "drawing-content",
      "drawings": "drawing-content",
      "drawing-content": "drawing-content",
      "handwriting": "handwriting",
      "handwritten": "handwriting",
      "image": "image-content",
      "images": "image-content",
      "image-content": "image-content",
      "image-text": "image-content",
      "image-objects": "image-content",
      "scanned-document": "scanned-document-text",
      "scanned-documents": "scanned-document-text",
      "scanned-document-text": "scanned-document-text",
      "scan-text": "scanned-document-text",
      "scan-ocr": "scanned-document-text",
      "ocr": "scanned-document-text",
    ]
    guard let scope = aliases[normalized] else {
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes search scope.",
        details: [
          "scope_sha256": sha256Hex(raw),
          "supported_scopes":
            "text,attachment-name,audio-transcript,suggested,natural-language,attachment-content,locked-title,pdf-content,drawing-content,handwriting,image-content,scanned-document-text",
        ]
      )
    }
    return scope
  }

  func listVisibleNotes(_ options: CLIOptions, limit: Int) throws -> [NotesNoteSummary] {
    let account = options.targetOption("account")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let folder = options.targetOption("folder")
    guard let account, !account.isEmpty else {
      return try implementation.listNotes(folder: folder, limit: limit)
    }
    guard let lister = implementation as? any NotesAccountScopedListing else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes account-scoped visible-note selection requires a private-framework account-scoped list reader.",
        details: [
          "operation": options.positionals.joined(separator: "."),
          "capability": "account_scoped_visible_note_selection",
          "status": "gated",
          "required_implementation": "typed_private_notes_framework_account_scoped_note_listing",
          "required_verifier": "private_framework_account_scoped_note_selection_readback+privacy_boundary",
          "backend_calls": "none",
        ]
      )
    }
    return try lister.listNotes(account: account, folder: folder, limit: limit)
  }

  private func searchTextNotes(_ options: CLIOptions, query: String) throws -> [NotesNoteSummary] {
    let id = options.targetOption("id")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let account = options.targetOption("account")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let includeRecentlyDeleted = options.hasTargetFlag("include-recently-deleted")
    if let id, !id.isEmpty {
      if options.targetOption("folder")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for Notes text search."
        )
      }
      if let account, !account.isEmpty {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for Notes text search."
        )
      }
      guard let note = try implementation.readNote(id: id) else {
        if includeRecentlyDeleted,
          let restorableNote = try restorableReader().readRestorableNote(id: id)
        {
          return noteTextMatches(restorableNote, query: query) ? [noteSummary(restorableNote)] : []
        }
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(id)]
        )
      }
      let state = try noteSearchState(noteID: note.id)
      return noteTextMatches(note, query: query, state: state) ? [noteSummary(note)] : []
    }
    let limit = try commandLimit(options)
    let visibleNotes: [NotesNoteSummary]
    if let account, !account.isEmpty {
      guard let searcher = implementation as? any NotesAccountScopedSearching else {
        throw notesSearchBoundaryError(
          query: query,
          scope: "account",
          status: "gated",
          capability: "account_scoped_notes_search",
          appleCapability: "search_in_specific_account",
          futureGate: "private_framework_account_scoped_search_readback",
          requiredImplementation: "typed_private_notes_framework_account_scoped_search",
          requiredVerifier: "private_framework_account_scoped_search_readback+privacy_boundary"
        )
      }
      visibleNotes = try searcher.searchNotes(
        query: query,
        account: account,
        folder: options.targetOption("folder"),
        limit: limit
      )
    } else {
      visibleNotes = try implementation.searchNotes(
        query: query,
        folder: options.targetOption("folder"),
        limit: limit
      )
    }
    guard includeRecentlyDeleted else {
      return visibleNotes
    }
    let restorableNotes = try searchRestorableNotes(
      query: query,
      account: account,
      folder: options.targetOption("folder")
    )
    return mergedSearchNotes(visible: visibleNotes, restorable: restorableNotes, limit: limit)
  }

  private func searchNaturalLanguage(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.search.natural-language"
    let query = try notesSearchQuery(options)
    if let id = options.targetOption("id"), !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      throw CLIError(
        code: .validationError,
        message: "`--id` is not supported for Notes natural-language search; use account/folder scope or ordinary single-note text search."
      )
    }
    guard let searcher = implementation as? any NotesNaturalLanguageSearching else {
      throw notesSearchBoundaryError(
        query: query,
        scope: "natural-language",
        status: "gated",
        capability: "natural_language_notes_search",
        appleCapability: "natural_language_search",
        futureGate: "private_notes_search_parser_or_semantic_query_readback",
        requiredImplementation: "typed_private_notes_framework_search_parser",
        requiredVerifier: "private_framework_search_result_readback+query_intent_accounting",
        operation: operation
      )
    }
    let evidence = try searcher.searchNaturalLanguageNotes(
      query: query,
      account: options.targetOption("account"),
      folder: options.targetOption("folder"),
      limit: try commandLimit(options)
    )
    let verification = verifyNaturalLanguageSearch(evidence)
    let response = NotesNaturalLanguageSearchResponse(
      operation: operation,
      changed: false,
      evidence: evidence,
      verification: verification
    )
    return try result(
      response,
      human: evidence.notes.map { "\($0.id)\t\($0.folderName)\t\($0.title)" }.joined(separator: "\n"),
      options: options
    )
  }

  private func verifyNaturalLanguageSearch(
    _ evidence: NotesNaturalLanguageSearchEvidence
  ) -> NotesMutationVerificationReport {
    let checks = [
      verificationBoolCheck(
        name: "private_nl_query_created",
        expected: true,
        actual: evidence.privateNLQueryPresent
      ),
      verificationBoolCheck(
        name: "result_accounting",
        expected: true,
        actual: evidence.rawResultCount >= evidence.mappedNoteCount
          && evidence.skippedResultCount == evidence.rawResultCount - evidence.mappedNoteCount
          && evidence.notes.count == evidence.mappedNoteCount
      ),
      verificationBoolCheck(
        name: "limit_respected",
        expected: true,
        actual: evidence.notes.count <= evidence.limit
      ),
      verificationBoolCheck(
        name: "query_hash_privacy",
        expected: true,
        actual: evidence.querySHA256.count == 64 && evidence.queryByteCount > 0
      ),
      verificationBoolCheck(
        name: "note_summary_privacy",
        expected: true,
        actual: evidence.notes.allSatisfy { !$0.id.isEmpty && !$0.title.isEmpty }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.search.natural-language",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "typed_private_ICSearchQueryOperation+natural_language_query_readback+note_summary_mapping",
      targetIDSHA256: evidence.querySHA256,
      checks: checks
    )
  }

  private func searchLockedTitleNotes(_ options: CLIOptions, query: String) throws -> [NotesNoteSummary] {
    let id = options.targetOption("id")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let account = options.targetOption("account")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let folder = options.targetOption("folder")?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let id, !id.isEmpty {
      if let account, !account.isEmpty {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for locked-title Notes search."
        )
      }
      if let folder, !folder.isEmpty {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for locked-title Notes search."
        )
      }
    }

    let limit = try commandLimit(options)
    let stateReader = try noteStateReader()
    let candidates = try listVisibleNotes(options, limit: 2_000)
    let selectedCandidates: [NotesNoteSummary]
    if let id, !id.isEmpty {
      selectedCandidates = candidates.filter { $0.id == id || sha256Hex($0.id) == id }
      guard !selectedCandidates.isEmpty else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(id)]
        )
      }
    } else {
      selectedCandidates = candidates
    }

    return try selectedCandidates
      .filter { note in
        let state = try stateReader.readNoteState(noteID: note.id)
        return noteSearchTreatsAsLocked(state)
          && noteTitleMatches(note.title, query: query)
      }
      .sorted(by: compareSearchNotes)
      .prefix(limit)
      .map { $0 }
  }

  private func noteTextMatches(
    _ note: NotesNoteDetail,
    query: String,
    state: NotesNoteStateRecord? = nil
  ) -> Bool {
    guard !noteTitleMatches(note.title, query: query) else {
      return true
    }
    if let state, noteSearchTreatsAsLocked(state) {
      return false
    }
    return (note.body ?? "").range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
  }

  private func noteTitleMatches(_ title: String, query: String) -> Bool {
    title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
  }

  private func noteSearchTreatsAsLocked(_ state: NotesNoteStateRecord) -> Bool {
    state.isPasswordProtected || state.isPasswordProtectedAndLocked == true
  }

  private func noteSearchState(noteID id: String) throws -> NotesNoteStateRecord? {
    guard let stateReader = implementation as? any NotesNoteStateReading else {
      return nil
    }
    return try stateReader.readNoteState(noteID: id)
  }

  private func searchRestorableNotes(
    query: String,
    account: String?,
    folder: String?
  ) throws -> [NotesNoteSummary] {
    try restorableReader().listRestorableNotes(limit: 2_000)
      .filter { note in
        notesSelectorMatches(note.accountName, selector: account)
          && notesSelectorMatches(note.folderName, selector: folder)
          && noteTextMatches(note, query: query)
      }
      .map(noteSummary)
  }

  private func mergedSearchNotes(
    visible: [NotesNoteSummary],
    restorable: [NotesNoteSummary],
    limit: Int
  ) -> [NotesNoteSummary] {
    var byID: [String: NotesNoteSummary] = [:]
    for note in visible + restorable where byID[note.id] == nil {
      byID[note.id] = note
    }
    return Array(byID.values)
      .sorted(by: compareSearchNotes)
      .prefix(limit)
      .map { $0 }
  }

  private func compareSearchNotes(_ lhs: NotesNoteSummary, _ rhs: NotesNoteSummary) -> Bool {
    switch (lhs.updatedAt, rhs.updatedAt) {
    case let (left?, right?) where left != right:
      return left > right
    case (_?, nil):
      return true
    case (nil, _?):
      return false
    default:
      let titleOrder = lhs.title.localizedStandardCompare(rhs.title)
      if titleOrder != .orderedSame {
        return titleOrder == .orderedAscending
      }
      return lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
    }
  }

  private func notesSelectorMatches(_ value: String, selector: String?) -> Bool {
    guard let selector = selector?.trimmingCharacters(in: .whitespacesAndNewlines), !selector.isEmpty else {
      return true
    }
    return value.localizedCaseInsensitiveCompare(selector) == .orderedSame
      || value == selector
      || sha256Hex(value) == selector
  }

  private func notesSearchBoundaryError(
    query: String,
    scope: String,
    status: String,
    capability: String,
    appleCapability: String,
    futureGate: String,
    requiredImplementation: String,
    requiredVerifier: String,
    operation: String = "notes.search"
  ) -> CLIError {
    let message: String
    switch status {
    case "delegated":
      message = "Notes search scope `\(scope)` is delegated to an existing semantic Notes command."
    default:
      message = "Notes search scope `\(scope)` is gated until capability-specific private-framework search proof is accepted."
    }
    return CLIError(
      code: .unsupportedOperation,
      message: message,
      details: [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "scope": scope,
        "status": status,
        "future_gate": futureGate,
        "required_implementation": requiredImplementation,
        "required_verifier": requiredVerifier,
        "query_sha256": sha256Hex(query),
        "query_byte_count": "\(Data(query.utf8).count)",
        "backend_calls": "none",
      ]
    )
  }
}
