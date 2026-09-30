import Foundation
#if canImport(PDFKit)
import PDFKit
#endif
import Utility

extension NotesCommand {

  private struct NotesAttachmentPDFTextExtraction: Sendable {
    var text: String
    var textSourceKind: String
    var pageCount: Int
  }

  struct NotesAttachmentSearchableTextSearchFamily: Sendable {
    var operation: String
    var contentFamily: String
    var includedFamilies: Set<String>
    var searchedContentKinds: [String]
  }

  private func gatedAttachmentSearchCapabilityError(
    options: CLIOptions,
    operation: String,
    capability: String,
    appleCapability: String,
    futureGate: String,
    requiredImplementation: String,
    requiredVerifier: String
  ) throws -> CLIError {
    let query = try attachmentMetadataSearchQuery(options)
    var details = try attachmentSearchBoundarySelectorDetails(options)
    details.merge(
      [
        "operation": operation,
        "capability": capability,
        "apple_notes_capability": appleCapability,
        "status": "gated",
        "future_gate": futureGate,
        "required_implementation": requiredImplementation,
        "required_verifier": requiredVerifier,
        "query_sha256": sha256Hex(query),
        "query_byte_count": "\(Data(query.utf8).count)",
        "backend_calls": "none",
      ],
      uniquingKeysWith: { _, new in new }
    )
    return CLIError(
      code: .unsupportedOperation,
      message:
        "Notes \(appleCapability.replacingOccurrences(of: "_", with: " ")) is gated until a typed private Notes search/index path and privacy-preserving verifier readback are accepted.",
      details: details
    )
  }

  private func attachmentSearchBoundarySelectorDetails(_ options: CLIOptions) throws -> [String: String] {
    let noteID = options.targetOption("id")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let account = options.targetOption("account")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let folder = options.targetOption("folder")?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let noteID, !noteID.isEmpty {
      if let folder, !folder.isEmpty {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for attachment search."
        )
      }
      if let account, !account.isEmpty {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for attachment search."
        )
      }
      return [
        "selector_scope": "note",
        "note_id_sha256": sha256Hex(noteID),
      ]
    }
    var details: [String: String] = [
      "selector_scope": "all_visible",
    ]
    if let account, !account.isEmpty {
      details["selector_scope"] = folder?.isEmpty == false ? "account_folder" : "account"
      details["account_sha256"] = sha256Hex(account)
    }
    if let folder, !folder.isEmpty {
      if account?.isEmpty != false {
        details["selector_scope"] = "folder"
      }
      details["folder_sha256"] = sha256Hex(folder)
    }
    return details
  }

  func searchAttachmentContent(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.search.attachment-content"
    let query = try notesSearchQuery(options)
    let limit = try commandLimit(options)
    let familyFilter = try attachmentListFamilyFilter(options)
    let notes = try attachmentContentSearchNotes(options, limit: limit)
    let reader = try attachmentReader()
    var scannedAttachmentCount = 0
    var filteredAttachmentCount = 0
    var metadataMatchedCount = 0
    var scannedPDFAttachmentCount = 0
    var skippedPDFAttachmentCount = 0
    var pdfMatchedCount = 0
    var scannedAudioAttachmentCount = 0
    var skippedAudioAttachmentCount = 0
    var audioMatchedCount = 0
    var scannedSearchableTextAttachmentCount = 0
    var skippedSearchableTextAttachmentCount = 0
    var searchableTextMatchedCount = 0
    var matches: [NotesAttachmentContentSearchMatch] = []

    for note in notes {
      let visibleAttachments = try reader.listAttachments(noteID: note.id, limit: 2_000)
        .filter { $0.isDeletedOrInTrash != true }
      scannedAttachmentCount += visibleAttachments.count
      let attachments = attachmentListFilteredAttachments(visibleAttachments, familyFilter: familyFilter)
      filteredAttachmentCount += attachments.count

      for attachment in attachments {
        let family = attachmentAuditFamily(attachment)
        let noteIDSHA256 = sha256Hex(note.id)

        let matchedFields = attachmentMetadataSearchMatchedFields(attachment, query: query)
        if !matchedFields.isEmpty && matches.count < limit {
          metadataMatchedCount += 1
          matches.append(
            NotesAttachmentContentSearchMatch(
              note: note,
              noteIDSHA256: noteIDSHA256,
              attachment: attachment,
              family: family,
              slice: "metadata",
              sourceKind: "ICAttachment.metadata",
              matchedFields: matchedFields
            ))
        }

        if attachmentPDFTextSearchFamilies.contains(family) {
          scannedPDFAttachmentCount += 1
          if matches.count < limit {
            do {
              let source = try reader.exportAttachmentPDF(noteID: note.id, attachmentID: attachment.id)
              let extraction = try attachmentPDFTextExtraction(data: source.data)
              let matchCount = privacySafeTextSearchMatchCount(text: extraction.text, query: query)
              if matchCount > 0 {
                pdfMatchedCount += 1
                matches.append(
                  NotesAttachmentContentSearchMatch(
                    note: note,
                    noteIDSHA256: noteIDSHA256,
                    attachment: source.attachment,
                    family: family,
                    slice: "pdf_text",
                    sourceKind: extraction.textSourceKind,
                    artifactSourceKind: source.sourceKind,
                    artifactByteCount: source.data.count,
                    artifactSHA256: sha256Hex(source.data),
                    pageCount: extraction.pageCount,
                    contentMatches: [
                      NotesAttachmentContentSearchContentMatch(
                        kind: "pdf_text",
                        sourceKind: extraction.textSourceKind,
                        byteCount: Data(extraction.text.utf8).count,
                        sha256: sha256Hex(extraction.text),
                        matchCount: matchCount
                      ),
                    ]
                  ))
              }
            } catch {
              skippedPDFAttachmentCount += 1
            }
          }
        }

        if family == "audio_recording" {
          scannedAudioAttachmentCount += 1
          if matches.count < limit {
            do {
              let source = try reader.readAttachmentAudioTranscript(noteID: note.id, attachmentID: attachment.id)
              let contentMatches = attachmentAudioTranscriptSearchContentMatches(
                source,
                query: query,
                contentKinds: attachmentContentAudioSearchContentKinds
              ).map { content in
                NotesAttachmentContentSearchContentMatch(
                  kind: content.kind,
                  sourceKind: source.sourceKind,
                  byteCount: content.byteCount,
                  sha256: content.sha256,
                  matchCount: content.matchCount,
                  version: content.version
                )
              }
              if !contentMatches.isEmpty {
                audioMatchedCount += 1
                matches.append(
                  NotesAttachmentContentSearchMatch(
                    note: note,
                    noteIDSHA256: noteIDSHA256,
                    attachment: source.attachment,
                    family: family,
                    slice: "audio_transcript",
                    sourceKind: source.sourceKind,
                    contentMatches: contentMatches
                  ))
              }
            } catch {
              skippedAudioAttachmentCount += 1
            }
          }
        }

        if attachmentContentSearchableTextFamilies.contains(family) {
          scannedSearchableTextAttachmentCount += 1
          if matches.count < limit {
            do {
              let source = try reader.readAttachmentSearchableText(noteID: note.id, attachmentID: attachment.id)
              let contentMatches = searchableTextSearchContentMatches(source.content, query: query).map { content in
                NotesAttachmentContentSearchContentMatch(
                  kind: content.kind,
                  sourceKind: content.sourceKind,
                  byteCount: content.byteCount,
                  sha256: content.sha256,
                  matchCount: content.matchCount
                )
              }
              if !contentMatches.isEmpty {
                searchableTextMatchedCount += 1
                matches.append(
                  NotesAttachmentContentSearchMatch(
                    note: note,
                    noteIDSHA256: noteIDSHA256,
                    attachment: source.attachment,
                    family: family,
                    slice: "searchable_text",
                    sourceKind: "ICAttachment.searchableTextContent",
                    contentMatches: contentMatches
                  ))
              }
            } catch {
              skippedSearchableTextAttachmentCount += 1
            }
          }
        }

        if matches.count >= limit {
          break
        }
      }
      if matches.count >= limit {
        break
      }
    }

    let searchedSlices = attachmentContentSearchedSlices
    let componentSummaries = [
      NotesAttachmentContentSearchComponentSummary(
        slice: "metadata",
        sourceKind: "ICAttachment.metadata",
        scannedAttachmentCount: filteredAttachmentCount,
        skippedAttachmentCount: 0,
        matchedAttachmentCount: metadataMatchedCount,
        searchedContentKinds: attachmentMetadataSearchFieldNames()
      ),
      NotesAttachmentContentSearchComponentSummary(
        slice: "pdf_text",
        sourceKind: "PDFKit.PDFDocument.string",
        scannedAttachmentCount: scannedPDFAttachmentCount,
        skippedAttachmentCount: skippedPDFAttachmentCount,
        matchedAttachmentCount: pdfMatchedCount,
        searchedContentKinds: ["pdf_text"]
      ),
      NotesAttachmentContentSearchComponentSummary(
        slice: "audio_transcript",
        sourceKind: "ICAttachment.audioModel.audioDocument",
        scannedAttachmentCount: scannedAudioAttachmentCount,
        skippedAttachmentCount: skippedAudioAttachmentCount,
        matchedAttachmentCount: audioMatchedCount,
        searchedContentKinds: attachmentContentAudioSearchContentKinds
      ),
      NotesAttachmentContentSearchComponentSummary(
        slice: "searchable_text",
        sourceKind: "ICAttachment.searchableTextContent",
        scannedAttachmentCount: scannedSearchableTextAttachmentCount,
        skippedAttachmentCount: skippedSearchableTextAttachmentCount,
        matchedAttachmentCount: searchableTextMatchedCount,
        searchedContentKinds: attachmentContentSearchableTextContentKinds
      ),
    ]
    let verification = verifyAttachmentContentSearch(
      query: query,
      familyFilter: familyFilter,
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      searchedSlices: searchedSlices,
      componentSummaries: componentSummaries,
      matches: matches,
      operation: operation
    )
    let response = NotesAttachmentContentSearchResponse(
      operation: operation,
      querySHA256: sha256Hex(query),
      queryByteCount: Data(query.utf8).count,
      account: options.targetOption("account"),
      folder: options.targetOption("folder"),
      family: familyFilter?.canonicalName,
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      searchedSlices: searchedSlices,
      componentSummaries: componentSummaries,
      matches: matches,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment content search verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try result(
      response,
      human: matches.map { match in
        [
          match.note.id,
          match.attachment.id,
          match.family,
          match.slice,
          "\(match.matchCount)",
        ].joined(separator: "\t")
      }.joined(separator: "\n"),
      options: options
    )
  }

  func searchAttachmentMetadata(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.attachments.search"
    let query = try attachmentMetadataSearchQuery(options)
    let limit = try commandLimit(options)
    let familyFilter = try attachmentListFamilyFilter(options)
    let notes = try attachmentMetadataSearchNotes(options, limit: limit)
    let reader = try attachmentReader()
    var scannedAttachmentCount = 0
    var matches: [NotesAttachmentSearchMatch] = []
    for note in notes {
      let attachments = attachmentListFilteredAttachments(
        try reader.listAttachments(noteID: note.id, limit: 2_000)
          .filter { $0.isDeletedOrInTrash != true },
        familyFilter: familyFilter
      )
      scannedAttachmentCount += attachments.count
      for attachment in attachments {
        let matchedFields = attachmentMetadataSearchMatchedFields(attachment, query: query)
        guard !matchedFields.isEmpty else {
          continue
        }
        matches.append(
          NotesAttachmentSearchMatch(
            note: note,
            noteIDSHA256: sha256Hex(note.id),
            attachment: attachment,
            family: attachmentAuditFamily(attachment),
            matchedFields: matchedFields
          ))
        if matches.count >= limit {
          break
        }
      }
      if matches.count >= limit {
        break
      }
    }
    let searchedFields = attachmentMetadataSearchFieldNames()
    let verification = verifyAttachmentMetadataSearch(
      query: query,
      familyFilter: familyFilter,
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      searchedFields: searchedFields,
      matches: matches,
      operation: operation
    )
    let response = NotesAttachmentSearchResponse(
      operation: operation,
      querySHA256: sha256Hex(query),
      queryByteCount: Data(query.utf8).count,
      account: options.targetOption("account"),
      folder: options.targetOption("folder"),
      family: familyFilter?.canonicalName,
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      searchedFields: searchedFields,
      matches: matches,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment metadata search verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try result(
      response,
      human: matches.map { match in
        [
          match.note.id,
          match.attachment.id,
          match.family,
          match.attachment.title ?? "",
          match.matchedFields.joined(separator: ","),
        ].joined(separator: "\t")
      }.joined(separator: "\n"),
      options: options
    )
  }

  func searchAttachmentPDFText(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.attachments.pdf.search"
    let query = try attachmentMetadataSearchQuery(options)
    let limit = try commandLimit(options)
    let notes = try attachmentMetadataSearchNotes(options, limit: limit)
    let reader = try attachmentReader()
    var scannedAttachmentCount = 0
    var scannedPDFAttachmentCount = 0
    var skippedPDFAttachmentCount = 0
    var matches: [NotesAttachmentPDFTextSearchMatch] = []

    for note in notes {
      let attachments = try reader.listAttachments(noteID: note.id, limit: 2_000)
        .filter { $0.isDeletedOrInTrash != true }
      scannedAttachmentCount += attachments.count

      for attachment in attachments {
        let family = attachmentAuditFamily(attachment)
        guard attachmentPDFTextSearchFamilies.contains(family) else {
          continue
        }
        scannedPDFAttachmentCount += 1

        guard
          let source = try? reader.exportAttachmentPDF(noteID: note.id, attachmentID: attachment.id),
          let extraction = try? attachmentPDFTextExtraction(data: source.data)
        else {
          skippedPDFAttachmentCount += 1
          continue
        }

        let matchCount = privacySafeTextSearchMatchCount(text: extraction.text, query: query)
        guard matchCount > 0 else {
          continue
        }

        matches.append(
          NotesAttachmentPDFTextSearchMatch(
            note: note,
            noteIDSHA256: sha256Hex(note.id),
            attachment: source.attachment,
            family: family,
            pdfSourceKind: source.sourceKind,
            textSourceKind: extraction.textSourceKind,
            pageCount: extraction.pageCount,
            pdfByteCount: source.data.count,
            pdfSHA256: sha256Hex(source.data),
            textByteCount: Data(extraction.text.utf8).count,
            textSHA256: sha256Hex(extraction.text),
            matchCount: matchCount
          ))
        if matches.count >= limit {
          break
        }
      }
      if matches.count >= limit {
        break
      }
    }

    let verification = verifyAttachmentPDFTextSearch(
      query: query,
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      scannedPDFAttachmentCount: scannedPDFAttachmentCount,
      skippedPDFAttachmentCount: skippedPDFAttachmentCount,
      matches: matches,
      operation: operation
    )
    let response = NotesAttachmentPDFTextSearchResponse(
      operation: operation,
      querySHA256: sha256Hex(query),
      queryByteCount: Data(query.utf8).count,
      account: options.targetOption("account"),
      folder: options.targetOption("folder"),
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      scannedPDFAttachmentCount: scannedPDFAttachmentCount,
      skippedPDFAttachmentCount: skippedPDFAttachmentCount,
      searchedContentKinds: ["pdf_text"],
      matches: matches,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment PDF text search verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try result(
      response,
      human: matches.map { match in
        [
          match.note.id,
          match.attachment.id,
          match.family,
          match.pdfSourceKind,
          "\(match.matchCount)",
        ].joined(separator: "\t")
      }.joined(separator: "\n"),
      options: options
    )
  }

  func searchAttachmentSearchableText(
    _ options: CLIOptions,
    family: NotesAttachmentSearchableTextSearchFamily
  ) throws -> CLICommandResult {
    let query = try attachmentMetadataSearchQuery(options)
    let limit = try commandLimit(options)
    let notes = try attachmentMetadataSearchNotes(options, limit: limit)
    let reader = try attachmentReader()
    var scannedAttachmentCount = 0
    var scannedCandidateAttachmentCount = 0
    var skippedCandidateAttachmentCount = 0
    var matches: [NotesAttachmentSearchableTextSearchMatch] = []

    for note in notes {
      let attachments = try reader.listAttachments(noteID: note.id, limit: 2_000)
        .filter { $0.isDeletedOrInTrash != true }
      scannedAttachmentCount += attachments.count

      for attachment in attachments {
        let auditFamily = attachmentAuditFamily(attachment)
        guard family.includedFamilies.contains(auditFamily) else {
          continue
        }
        scannedCandidateAttachmentCount += 1

        guard let source = try? reader.readAttachmentSearchableText(noteID: note.id, attachmentID: attachment.id) else {
          skippedCandidateAttachmentCount += 1
          continue
        }
        let contentMatches = searchableTextSearchContentMatches(source.content, query: query)
        guard !contentMatches.isEmpty else {
          continue
        }

        matches.append(
          NotesAttachmentSearchableTextSearchMatch(
            note: note,
            noteIDSHA256: sha256Hex(note.id),
            attachment: source.attachment,
            family: auditFamily,
            contentMatches: contentMatches
          ))
        if matches.count >= limit {
          break
        }
      }
      if matches.count >= limit {
        break
      }
    }

    let verification = verifyAttachmentSearchableTextSearch(
      query: query,
      family: family,
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      scannedCandidateAttachmentCount: scannedCandidateAttachmentCount,
      skippedCandidateAttachmentCount: skippedCandidateAttachmentCount,
      matches: matches
    )
    let response = NotesAttachmentSearchableTextSearchResponse(
      operation: family.operation,
      querySHA256: sha256Hex(query),
      queryByteCount: Data(query.utf8).count,
      contentFamily: family.contentFamily,
      account: options.targetOption("account"),
      folder: options.targetOption("folder"),
      scannedNoteCount: notes.count,
      scannedAttachmentCount: scannedAttachmentCount,
      scannedCandidateAttachmentCount: scannedCandidateAttachmentCount,
      skippedCandidateAttachmentCount: skippedCandidateAttachmentCount,
      searchedContentKinds: family.searchedContentKinds,
      matches: matches,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes attachment searchable text search verification failed.",
        details: artifactVerificationFailureDetails(operation: family.operation, verification: verification)
      )
    }
    return try result(
      response,
      human: matches.map { match in
        [
          match.note.id,
          match.attachment.id,
          match.family,
          "\(match.matchCount)",
        ].joined(separator: "\t")
      }.joined(separator: "\n"),
      options: options
    )
  }

  private func attachmentMetadataSearchNotes(_ options: CLIOptions, limit: Int) throws -> [NotesNoteSummary] {
    if let id = options.targetOption("id"), !id.isEmpty {
      if options.targetOption("folder")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for attachment search."
        )
      }
      if options.targetOption("account")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for attachment search."
        )
      }
      return [
        NotesNoteSummary(
          id: id,
          title: "",
          folderName: "",
          accountName: ""
        ),
      ]
    }
    return try listVisibleNotes(options, limit: limit)
  }

  private func attachmentContentSearchNotes(_ options: CLIOptions, limit: Int) throws -> [NotesNoteSummary] {
    if let id = options.targetOption("id")?.trimmingCharacters(in: .whitespacesAndNewlines), !id.isEmpty {
      if options.targetOption("folder")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--folder` cannot be combined for attachment search."
        )
      }
      if options.targetOption("account")?.isEmpty == false {
        throw CLIError(
          code: .validationError,
          message: "`--id` and `--account` cannot be combined for attachment search."
        )
      }
      guard let note = try implementation.readNote(id: id) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(id)]
        )
      }
      return [noteSummary(note)]
    }
    return try listVisibleNotes(options, limit: limit)
  }

  private func attachmentMetadataSearchQuery(_ options: CLIOptions) throws -> String {
    let query = try requiredOption("query", options: options).trimmingCharacters(in: .whitespacesAndNewlines)
    guard query.count >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "`--query` must contain at least 2 non-whitespace characters."
      )
    }
    return query
  }

  private func attachmentMetadataSearchFieldNames() -> [String] {
    ["title", "media_filename", "content_identifier", "type_uti", "attachment_type", "family"]
  }

  private func attachmentMetadataSearchMatchedFields(
    _ attachment: NotesAttachmentRecord,
    query: String
  ) -> [String] {
    let fields: [(String, String)] = [
      ("title", attachment.title ?? ""),
      ("media_filename", attachment.mediaFilename ?? ""),
      ("content_identifier", attachment.contentIdentifier ?? ""),
      ("type_uti", attachment.typeUTI ?? ""),
      ("attachment_type", attachment.attachmentType.map(String.init) ?? ""),
      ("family", attachmentAuditFamily(attachment)),
    ]
    return fields.compactMap { name, value in
      attachmentMetadataSearchMatches(value, query: query) ? name : nil
    }
  }

  private func attachmentMetadataSearchMatches(_ value: String, query: String) -> Bool {
    value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
  }

  private var attachmentContentSearchedSlices: [String] {
    ["metadata", "pdf_text", "audio_transcript", "searchable_text"]
  }

  private var attachmentContentAudioSearchContentKinds: [String] {
    ["transcript", "summary", "topline-summary"]
  }

  private var attachmentContentSearchableTextFamilies: Set<String> {
    ["scanned_document", "photo_image", "drawing_or_sketch"]
  }

  private var attachmentContentSearchableTextContentKinds: [String] {
    ["model_searchable_text", "note_searchable_text", "searchable_text", "searchable_text_without_title"]
  }

  private var attachmentPDFTextSearchFamilies: Set<String> {
    ["pdf", "scanned_document"]
  }

  private func attachmentPDFTextExtraction(data: Data) throws -> NotesAttachmentPDFTextExtraction {
    let pdfHeader = data.count >= 4 && data.prefix(4) == Data("%PDF".utf8)
    let pdfEOF = data.range(of: Data("%%EOF".utf8), options: [], in: data.startIndex..<data.endIndex) != nil
    guard pdfHeader && pdfEOF else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment PDF data is not a complete searchable PDF document.",
        details: ["pdf_data_sha256": sha256Hex(data)]
      )
    }
    #if canImport(PDFKit)
    guard let document = PDFDocument(data: data) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment PDF data could not be parsed for text search.",
        details: ["pdf_data_sha256": sha256Hex(data)]
      )
    }
    let pageCount = document.pageCount
    let text = (0..<pageCount)
      .compactMap { document.page(at: $0)?.string }
      .joined(separator: "\n")
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Attachment PDF data did not expose searchable text.",
        details: [
          "pdf_data_sha256": sha256Hex(data),
          "page_count": "\(pageCount)",
        ]
      )
    }
    return NotesAttachmentPDFTextExtraction(
      text: text,
      textSourceKind: "PDFKit.PDFDocument.string",
      pageCount: pageCount
    )
    #else
    throw CLIError(
      code: .unsupportedOperation,
      message: "PDFKit is unavailable for Notes attachment PDF text search.",
      details: ["required_framework": "PDFKit"]
    )
    #endif
  }

  private func searchableTextSearchContentMatches(
    _ content: [NotesAttachmentSearchableTextContentSource],
    query: String
  ) -> [NotesAttachmentSearchableTextSearchContentMatch] {
    content.compactMap { item in
      let matchCount = privacySafeTextSearchMatchCount(text: item.text, query: query)
      guard matchCount > 0 else {
        return nil
      }
      return NotesAttachmentSearchableTextSearchContentMatch(
        kind: item.kind,
        sourceKind: item.sourceKind,
        byteCount: Data(item.text.utf8).count,
        sha256: sha256Hex(item.text),
        matchCount: matchCount
      )
    }
  }

  private func verifyAttachmentSearchableTextSearch(
    query: String,
    family: NotesAttachmentSearchableTextSearchFamily,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    scannedCandidateAttachmentCount: Int,
    skippedCandidateAttachmentCount: Int,
    matches: [NotesAttachmentSearchableTextSearchMatch]
  ) -> NotesMutationVerificationReport {
    let allowedSourceKinds = Set([
      "ICAttachment.searchableTextContent",
      "ICAttachment.searchableTextContentWithoutTitle",
      "ICAttachment.attachmentModel.searchableTextContent",
      "ICAttachment.attachmentModel.searchableTextContentForLocation",
      "ICAttachment.attachmentModel.searchableTextContentInNote",
      "ICAttachment.attachmentModel.additionalIndexableTextContentInNote",
      "ICAttachment.attachmentModel.textContentInNote",
    ])
    let boundedScan = scannedNoteCount <= 500 && matches.count <= 500
    let candidateScanAccounting =
      scannedAttachmentCount >= scannedCandidateAttachmentCount
        && scannedCandidateAttachmentCount >= matches.count + skippedCandidateAttachmentCount
    let familyFilterApplied = matches.allSatisfy { family.includedFamilies.contains($0.family) }
    let privacyHashAccounting = matches.allSatisfy { match in
      !match.contentMatches.isEmpty && match.matchCount > 0
        && match.contentMatches.allSatisfy { content in
          family.searchedContentKinds.contains(content.kind)
            || content.kind == "searchable_text"
            || content.kind == "searchable_text_without_title"
        }
        && match.contentMatches.allSatisfy { content in
          allowedSourceKinds.contains(content.sourceKind)
            && content.byteCount > 0
            && content.sha256.count == 64
            && content.matchCount > 0
        }
    }
    let checks = [
      verificationBoolCheck(
        name: "query_hash_accounting",
        expected: true,
        actual: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
      ),
      verificationBoolCheck(
        name: "bounded_scan",
        expected: true,
        actual: boundedScan
      ),
      verificationBoolCheck(
        name: "candidate_attachment_scan_accounting",
        expected: true,
        actual: candidateScanAccounting
      ),
      verificationBoolCheck(
        name: "attachment_family_filter_applied",
        expected: true,
        actual: familyFilterApplied
      ),
      verificationBoolCheck(
        name: "privacy_hash_accounting",
        expected: true,
        actual: privacyHashAccounting
      ),
    ]
    let targetFields = [
      sha256Hex(query),
      family.contentFamily,
      "\(scannedNoteCount)",
      "\(scannedCandidateAttachmentCount)",
      matches.map { $0.attachment.id }.joined(separator: ","),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: family.operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_searchable_text_readback+privacy_hash+bounded_scan",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func verifyAttachmentPDFTextSearch(
    query: String,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    scannedPDFAttachmentCount: Int,
    skippedPDFAttachmentCount: Int,
    matches: [NotesAttachmentPDFTextSearchMatch],
    operation: String
  ) -> NotesMutationVerificationReport {
    let allowedPDFSourceKinds = Set([
      "media_pdf",
      "fallback_pdf_crypto",
      "paper_bundle_fallback_pdf",
      "doccam_generated_pdf",
    ])
    let boundedScan = scannedNoteCount <= 500 && matches.count <= 500
    let pdfScanAccounting =
      scannedAttachmentCount >= scannedPDFAttachmentCount
        && scannedPDFAttachmentCount >= matches.count + skippedPDFAttachmentCount
    let privacyHashAccounting = matches.allSatisfy { match in
      attachmentPDFTextSearchFamilies.contains(match.family)
        && allowedPDFSourceKinds.contains(match.pdfSourceKind)
        && match.textSourceKind == "PDFKit.PDFDocument.string"
        && match.pageCount > 0
        && match.pdfByteCount > 0
        && !match.pdfSHA256.isEmpty
        && match.textByteCount > 0
        && !match.textSHA256.isEmpty
        && match.matchCount > 0
    }
    let checks = [
      NotesVerificationCheckRecord(
        name: "query_hash_accounting",
        status: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 ? "passed" : "failed",
        expectedBool: true,
        actualBool: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
      ),
      NotesVerificationCheckRecord(
        name: "bounded_scan",
        status: boundedScan ? "passed" : "failed",
        expectedBool: true,
        actualBool: boundedScan
      ),
      NotesVerificationCheckRecord(
        name: "pdf_attachment_scan_accounting",
        status: pdfScanAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: pdfScanAccounting
      ),
      NotesVerificationCheckRecord(
        name: "privacy_hash_accounting",
        status: privacyHashAccounting ? "passed" : "failed",
        expectedBool: true,
        actualBool: privacyHashAccounting
      ),
    ]
    let targetFields = [
      sha256Hex(query),
      "\(scannedNoteCount)",
      "\(scannedPDFAttachmentCount)",
      matches.map { $0.attachment.id }.joined(separator: ","),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_attachment_pdf_readback+pdfkit_text_hash+bounded_scan",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func verifyAttachmentMetadataSearch(
    query: String,
    familyFilter: NotesAttachmentListFamilyFilter?,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    searchedFields: [String],
    matches: [NotesAttachmentSearchMatch],
    operation: String
  ) -> NotesMutationVerificationReport {
    let allowedFields = Set(attachmentMetadataSearchFieldNames())
    let fieldAccounting = !searchedFields.isEmpty && Set(searchedFields).isSubset(of: allowedFields)
      && matches.allSatisfy { match in
        !match.matchedFields.isEmpty
          && Set(match.matchedFields).isSubset(of: allowedFields)
          && match.matchCount == match.matchedFields.count
      }
    let familyFilterApplied = familyFilter.map { filter in
      matches.allSatisfy { filter.includedFamilies.contains($0.family) }
    } ?? true
    let visibleOnly = matches.allSatisfy { $0.attachment.isDeletedOrInTrash != true }
    let boundedScan = scannedNoteCount <= 500 && matches.count <= 500
    let attachmentScanAccounting = scannedAttachmentCount >= matches.count
    let checks = [
      verificationBoolCheck(
        name: "query_hash_accounting",
        expected: true,
        actual: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
      ),
      verificationBoolCheck(
        name: "bounded_scan",
        expected: true,
        actual: boundedScan
      ),
      verificationBoolCheck(
        name: "attachment_scan_accounting",
        expected: true,
        actual: attachmentScanAccounting
      ),
      verificationBoolCheck(
        name: "metadata_field_accounting",
        expected: true,
        actual: fieldAccounting
      ),
      verificationBoolCheck(
        name: "visible_attachment_records_only",
        expected: true,
        actual: visibleOnly
      ),
      verificationBoolCheck(
        name: "family_filter_applied",
        expected: true,
        actual: familyFilterApplied
      ),
      verificationBoolCheck(
        name: "metadata_only_batch_read",
        expected: true,
        actual: true
      ),
    ]
    let targetFields = [
      sha256Hex(query),
      familyFilter?.canonicalName ?? "all",
      matches.map { $0.attachment.id }.joined(separator: ","),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_attachment_metadata_search+privacy_hash+bounded_scan",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func verifyAttachmentContentSearch(
    query: String,
    familyFilter: NotesAttachmentListFamilyFilter?,
    scannedNoteCount: Int,
    scannedAttachmentCount: Int,
    searchedSlices: [String],
    componentSummaries: [NotesAttachmentContentSearchComponentSummary],
    matches: [NotesAttachmentContentSearchMatch],
    operation: String
  ) -> NotesMutationVerificationReport {
    let allowedSlices = Set(attachmentContentSearchedSlices)
    let allowedMetadataFields = Set(attachmentMetadataSearchFieldNames())
    let allowedPDFSourceKinds = Set([
      "media_pdf",
      "fallback_pdf_crypto",
      "paper_bundle_fallback_pdf",
      "doccam_generated_pdf",
    ])
    let allowedSearchableTextSourceKinds = Set([
      "ICAttachment.searchableTextContent",
      "ICAttachment.searchableTextContentWithoutTitle",
      "ICAttachment.attachmentModel.searchableTextContent",
      "ICAttachment.attachmentModel.searchableTextContentForLocation",
      "ICAttachment.attachmentModel.searchableTextContentInNote",
      "ICAttachment.attachmentModel.additionalIndexableTextContentInNote",
      "ICAttachment.attachmentModel.textContentInNote",
    ])
    let searchedSliceAccounting = Set(searchedSlices) == allowedSlices
      && Set(componentSummaries.map(\.slice)) == allowedSlices
    let componentScanAccounting = componentSummaries.allSatisfy { summary in
      allowedSlices.contains(summary.slice)
        && summary.scannedAttachmentCount >= 0
        && summary.skippedAttachmentCount >= 0
        && summary.matchedAttachmentCount >= 0
        && summary.scannedAttachmentCount >= summary.skippedAttachmentCount
        && summary.scannedAttachmentCount >= summary.matchedAttachmentCount
        && summary.scannedAttachmentCount <= scannedAttachmentCount
    }
    let familyFilterApplied = familyFilter.map { filter in
      matches.allSatisfy { filter.includedFamilies.contains($0.family) }
    } ?? true
    let privacyHashAccounting = matches.allSatisfy { match in
      guard allowedSlices.contains(match.slice),
        match.noteIDSHA256.count == 64,
        !match.attachment.id.isEmpty,
        match.matchCount > 0
      else {
        return false
      }
      switch match.slice {
      case "metadata":
        return match.sourceKind == "ICAttachment.metadata"
          && !match.matchedFields.isEmpty
          && Set(match.matchedFields).isSubset(of: allowedMetadataFields)
          && match.contentMatches.isEmpty
      case "pdf_text":
        return attachmentPDFTextSearchFamilies.contains(match.family)
          && match.sourceKind == "PDFKit.PDFDocument.string"
          && match.artifactSourceKind.map { allowedPDFSourceKinds.contains($0) } == true
          && (match.artifactByteCount ?? 0) > 0
          && match.artifactSHA256?.count == 64
          && (match.pageCount ?? 0) > 0
          && contentMatchesHavePrivacyHashes(match.contentMatches, allowedSourceKinds: ["PDFKit.PDFDocument.string"])
      case "audio_transcript":
        return match.family == "audio_recording"
          && match.sourceKind == "ICAttachment.audioModel.audioDocument"
          && contentMatchesHavePrivacyHashes(
            match.contentMatches,
            allowedSourceKinds: ["ICAttachment.audioModel.audioDocument"],
            allowedKinds: Set(attachmentContentAudioSearchContentKinds)
          )
      case "searchable_text":
        return attachmentContentSearchableTextFamilies.contains(match.family)
          && match.sourceKind == "ICAttachment.searchableTextContent"
          && contentMatchesHavePrivacyHashes(
            match.contentMatches,
            allowedSourceKinds: allowedSearchableTextSourceKinds
          )
      default:
        return false
      }
    }
    let checks = [
      verificationBoolCheck(
        name: "query_hash_accounting",
        expected: true,
        actual: query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
      ),
      verificationBoolCheck(
        name: "searched_slice_accounting",
        expected: true,
        actual: searchedSliceAccounting
      ),
      verificationBoolCheck(
        name: "component_scan_accounting",
        expected: true,
        actual: componentScanAccounting
      ),
      verificationBoolCheck(
        name: "family_filter_applied",
        expected: true,
        actual: familyFilterApplied
      ),
      verificationBoolCheck(
        name: "privacy_hash_accounting",
        expected: true,
        actual: privacyHashAccounting
      ),
      verificationBoolCheck(
        name: "bounded_scan",
        expected: true,
        actual: scannedNoteCount <= 500 && matches.count <= 500
      ),
    ]
    let targetFields = [
      sha256Hex(query),
      familyFilter?.canonicalName ?? "all",
      "\(scannedNoteCount)",
      "\(scannedAttachmentCount)",
      matches.map { "\($0.slice):\($0.attachment.id)" }.joined(separator: ","),
    ].joined(separator: "|")
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_attachment_content_composite_readback+privacy_hash+bounded_scan",
      targetIDSHA256: sha256Hex(targetFields),
      checks: checks
    )
  }

  private func contentMatchesHavePrivacyHashes(
    _ contentMatches: [NotesAttachmentContentSearchContentMatch],
    allowedSourceKinds: Set<String>,
    allowedKinds: Set<String>? = nil
  ) -> Bool {
    !contentMatches.isEmpty
      && contentMatches.allSatisfy { content in
        allowedSourceKinds.contains(content.sourceKind)
          && (allowedKinds.map { $0.contains(content.kind) } ?? true)
          && content.byteCount > 0
          && content.sha256.count == 64
          && content.matchCount > 0
      }
  }
}
