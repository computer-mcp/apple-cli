import Foundation
import Utility

extension NotesCommand {
  func runTags(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["tags", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try tagWorkflowAudit(options)
    case ["tags", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let tags = try tagReader().listTags(
        account: options.targetOption("account"), limit: try commandLimit(options))
      return try result(
        NotesTagsResponse(tags: tags),
        human: tags.map { tag in
          let count = tag.visibleUseCount.map(String.init) ?? ""
          return "\(tag.id)\t\(tag.accountName)\t\(tag.displayText)\t\(count)"
        }.joined(separator: "\n"),
        options: options
      )
    case ["tags", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["tag", "tags", "include-tags", "exclude-tags", "mode"])
      let response = try tagSearchResponse(options)
      return try result(
        response,
        human: response.notes.map { "\($0.id)\t\($0.folderName)\t\($0.title)" }.joined(separator: "\n"),
        options: options
      )
    case ["tags", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "tag"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let tag = try normalizedTagOption(options)
      return try mutation(
        operation: "notes.tags.add",
        scopeDigest: tagMutationScopeDigest(note: identity.note, tag: tag, action: "add"),
        summary: tagMutationSummary(note: identity.note, tag: tag, action: "add"),
        options: options
      ) {
        let write = try tagMutator().addTag(tag, toNoteID: identity.note.id)
        let verification = try mutationVerifier().verifyTagMembership(
          operation: "notes.tags.add",
          before: identity.note,
          tag: write.tag,
          expectedPresent: true,
          changed: write.changed,
          resultNote: write.note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.tags.add", changed: write.changed, note: write.note,
            tag: write.tag, deletedID: nil, verification: verification))
      }
    case ["tags", "remove"]:
      try validateTargetOptions(options, allowedOptions: ["id", "tag"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let tag = try normalizedTagOption(options)
      return try mutation(
        operation: "notes.tags.remove",
        scopeDigest: tagMutationScopeDigest(note: identity.note, tag: tag, action: "remove"),
        summary: tagMutationSummary(note: identity.note, tag: tag, action: "remove"),
        options: options
      ) {
        let write = try tagMutator().removeTag(tag, fromNoteID: identity.note.id)
        let verification = try mutationVerifier().verifyTagMembership(
          operation: "notes.tags.remove",
          before: identity.note,
          tag: write.tag,
          expectedPresent: false,
          changed: write.changed,
          resultNote: write.note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.tags.remove", changed: write.changed, note: write.note,
            tag: write.tag, deletedID: nil, verification: verification))
      }
    case ["tags", "convert-to-text"]:
      try validateTargetOptions(options, allowedOptions: ["id", "tag"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let draft = try tagConvertToTextDraft(options, note: identity.note)
      return try mutation(
        operation: "notes.tags.convert-to-text",
        scopeDigest: tagConvertToTextScopeDigest(draft),
        summary: tagConvertToTextSummary(draft, note: identity.note),
        options: options,
        dryRunNotes: [
          "Execution removes the selected private hashtag token and verifies body plaintext hash preservation."
        ]
      ) {
        let write = try tagMutator().convertTagToText(draft)
        let verification = try mutationVerifier().verifyTagConvertToText(
          operation: "notes.tags.convert-to-text",
          before: identity.note,
          draft: draft,
          result: write
        )
        var outputNote = write.note
        outputNote.body = nil
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.tags.convert-to-text",
            changed: write.changed,
            note: outputNote,
            tag: write.tag,
            deletedID: nil,
            verification: verification
          ))
      }
    case ["tags", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["tag", "name"], allowedFlags: ["allow-merge"])
      try validateMutationIntent(options)
      let draft = try tagRenameDraft(options)
      let beforeAffectedNotes = try tagReader().readNotes(tag: draft.currentStandardizedContent, limit: 2_000)
      let beforeSmartFolderTagCriteria = try smartFolderTagCriteriaSnapshots(
        tag: draft.currentStandardizedContent)
      return try mutation(
        operation: "notes.tags.rename",
        scopeDigest: tagRenameScopeDigest(draft),
        summary: tagRenameSummary(draft),
        options: options
      ) {
        let write = try tagMutator().renameTag(draft)
        let verification = try mutationVerifier().verifyTagRename(
          operation: "notes.tags.rename",
          draft: draft,
          beforeAffectedNotes: beforeAffectedNotes,
          beforeSmartFolderTagCriteria: beforeSmartFolderTagCriteria,
          result: write
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.tags.rename",
            changed: write.changed,
            note: nil,
            tag: write.tag,
            affectedNoteCount: write.affectedNotes.count,
            deletedID: nil,
            verification: verification
          ))
      }
    case ["tags", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["tag", "tags"])
      try validateMutationIntent(options)
      if options.targetOption("tags") != nil {
        return try tagBatchDeleteMutation(options)
      }
      let draft = try tagDeleteDraft(options)
      let beforeAffectedNotes = try tagReader().readNotes(tag: draft.standardizedContent, limit: 2_000)
      let beforeSmartFolderTagCriteria = try smartFolderTagCriteriaSnapshots(
        tag: draft.standardizedContent)
      return try mutation(
        operation: "notes.tags.delete",
        scopeDigest: tagDeleteScopeDigest(draft),
        summary: tagDeleteSummary(draft),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection"],
        dryRunNotes: [
          "Execution checks private Smart Folder cascade impact before removing tag usage."
        ]
      ) {
        let write = try tagMutator().deleteTag(draft)
        let verification = try mutationVerifier().verifyTagDelete(
          operation: "notes.tags.delete",
          draft: draft,
          beforeAffectedNotes: beforeAffectedNotes,
          beforeSmartFolderTagCriteria: beforeSmartFolderTagCriteria,
          result: write
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.tags.delete",
            changed: write.changed,
            note: nil,
            tag: write.tag,
            affectedNoteCount: write.affectedNotes.count,
            deletedID: write.tag.id,
            verification: verification
          ))
      }    default:
      return nil
    }
  }

  private func tagRenameDraft(_ options: CLIOptions) throws -> NotesTagRenameDraft {
    let currentTag = try normalizedTagOption(options)
    let newTag = try normalizedTagOption(named: "name", options: options)
    let currentStandardized = standardizedTagContent(currentTag)
    let newStandardized = standardizedTagContent(newTag)
    guard currentStandardized != newStandardized else {
      throw CLIError(
        code: .validationError,
        message: "New Notes tag name must differ from the current tag name.",
        details: ["tag_sha256": sha256Hex(currentStandardized)]
      )
    }

    let tagReader = try tagReader()
    let tags = try tagReader.listTags(account: nil, limit: 2_000)
    let matchingTags = tags.filter { tagMatches($0, currentTag) }
    guard !matchingTags.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "Tag selector did not match any Notes tag.",
        details: ["tag_sha256": sha256Hex(currentStandardized)]
      )
    }
    let targetMatchingTags = tags.filter { tagMatches($0, newTag) }
    let allowMerge = options.hasTargetFlag("allow-merge")
    guard targetMatchingTags.isEmpty || allowMerge else {
      throw CLIError(
        code: .validationError,
        message: "Notes tag rename into an existing tag requires `--allow-merge`.",
        details: [
          "from_tag_sha256": sha256Hex(currentStandardized),
          "to_tag_sha256": sha256Hex(newStandardized),
          "required_flag": "--allow-merge",
        ]
      )
    }

    let affectedNotes = try tagReader.readNotes(tag: currentStandardized, limit: 2_000)
    return NotesTagRenameDraft(
      currentDisplayText: matchingTags[0].displayText,
      currentStandardizedContent: matchingTags[0].standardizedContent ?? currentStandardized,
      newDisplayText: newTag,
      newStandardizedContent: newStandardized,
      matchedTagCount: matchingTags.count,
      targetMatchedTagCount: targetMatchingTags.count,
      affectedNoteCount: affectedNotes.count,
      allowMerge: allowMerge
    )
  }

  private func tagSearchResponse(_ options: CLIOptions) throws -> NotesTagSearchResponse {
    let mode = try tagSearchMode(options)
    let limit = try commandLimit(options)
    let includedSelectors = try tagSearchIncludedSelectors(options)
    let excludedSelectors = try normalizedTagListOption(named: "exclude-tags", options: options)
    let includedStandardized = try uniqueStandardizedTagSelectors(
      includedSelectors,
      optionName: "tag"
    )
    let excludedStandardized = try uniqueStandardizedTagSelectors(
      excludedSelectors,
      optionName: "exclude-tags"
    )
    try validateTagSearchSelectorCounts(included: includedStandardized, excluded: excludedStandardized)
    let overlap = Set(includedStandardized).intersection(excludedStandardized)
    guard overlap.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Notes tag search cannot include and exclude the same tag.",
        details: ["tag_sha256": overlap.sorted().map(sha256Hex).joined(separator: ",")]
      )
    }

    let tagReader = try tagReader()
    let knownTags = try tagReader.listTags(account: nil, limit: 2_000)
    let includedTags = try resolveTagSearchSelectors(
      includedStandardized,
      knownTags: knownTags,
      optionName: "tag"
    )
    let excludedTags = try resolveTagSearchSelectors(
      excludedStandardized,
      knownTags: knownTags,
      optionName: "exclude-tags"
    )
    let includedTagSet = Set(includedTags.map { $0.standardizedContent })
    let excludedTagSet = Set(excludedTags.map { $0.standardizedContent })

    var candidatesByID: [String: NotesNoteDetail] = [:]
    for tag in includedTags {
      let notes = try tagReader.readNotes(tag: tag.standardizedContent, limit: 2_000)
      for note in notes {
        candidatesByID[note.id] = note
      }
    }

    let candidates = candidatesByID.values.sorted { lhs, rhs in
      lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
    }
    let filtered = candidates.filter { note in
      let tagSet = noteTagContentSet(note)
      let includeMatched: Bool
      switch mode {
      case .all:
        includeMatched = includedTagSet.isSubset(of: tagSet)
      case .any:
        includeMatched = !includedTagSet.isDisjoint(with: tagSet)
      }
      return includeMatched && excludedTagSet.isDisjoint(with: tagSet)
    }
    let summaries = filtered.prefix(limit).map(noteSummary)

    return NotesTagSearchResponse(
      notes: summaries,
      mode: mode,
      includedTagCount: includedTags.count,
      excludedTagCount: excludedTags.count,
      includedTagSHA256: includedTags.map { sha256Hex($0.standardizedContent) },
      excludedTagSHA256: excludedTags.map { sha256Hex($0.standardizedContent) },
      scannedNoteCount: candidates.count,
      returnedNoteCount: summaries.count,
      limit: limit
    )
  }

  private func tagSearchIncludedSelectors(_ options: CLIOptions) throws -> [String] {
    var selectors: [String] = []
    if options.targetOption("tag") != nil {
      selectors.append(try normalizedTagOption(options))
    }
    selectors.append(contentsOf: try normalizedTagListOption(named: "tags", options: options))
    selectors.append(contentsOf: try normalizedTagListOption(named: "include-tags", options: options))
    guard !selectors.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "`tags search` requires `--tag`, `--tags`, or `--include-tags`.",
        details: ["allowed": "tag,tags,include-tags"]
      )
    }
    return selectors
  }

  func normalizedTagListOption(named name: String, options: CLIOptions) throws -> [String] {
    guard let raw = options.targetOption(name) else {
      return []
    }
    let parts = raw.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
    var tags: [String] = []
    for part in parts {
      let withoutPrefix = part.hasPrefix("#") ? String(part.dropFirst()) : part
      let trimmed = withoutPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else {
        throw CLIError(
          code: .validationError,
          message: "`--\(name)` must contain comma-separated non-empty tags."
        )
      }
      guard trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
        throw CLIError(code: .validationError, message: "`--\(name)` tags must not contain whitespace.")
      }
      tags.append(trimmed)
    }
    return tags
  }

  private func uniqueStandardizedTagSelectors(_ selectors: [String], optionName: String) throws -> [String] {
    var seen = Set<String>()
    var values: [String] = []
    for selector in selectors {
      let standardized = standardizedTagContent(selector)
      guard !standardized.isEmpty else {
        throw CLIError(code: .validationError, message: "`--\(optionName)` must not contain empty tags.")
      }
      guard seen.insert(standardized).inserted else {
        continue
      }
      values.append(standardized)
    }
    return values
  }

  private func validateTagSearchSelectorCounts(included: [String], excluded: [String]) throws {
    guard included.count <= 16 else {
      throw CLIError(
        code: .validationError,
        message: "Notes tag search supports at most 16 included tags per command.",
        details: ["max_tag_count": "16"]
      )
    }
    guard excluded.count <= 16 else {
      throw CLIError(
        code: .validationError,
        message: "Notes tag search supports at most 16 excluded tags per command.",
        details: ["max_tag_count": "16"]
      )
    }
  }

  private func tagSearchMode(_ options: CLIOptions) throws -> NotesTagSearchMode {
    guard let raw = options.targetOption("mode") else {
      return .all
    }
    guard let mode = NotesTagSearchMode(rawValue: raw.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase) else {
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes tag search mode.",
        details: ["allowed": NotesTagSearchMode.allowedDescription]
      )
    }
    return mode
  }

  private func resolveTagSearchSelectors(
    _ selectors: [String],
    knownTags: [NotesTagRecord],
    optionName: String
  ) throws -> [(record: NotesTagRecord, standardizedContent: String)] {
    try selectors.map { selector in
      guard let match = knownTags.first(where: { tagMatches($0, selector) }) else {
        throw CLIError(
          code: .notFound,
          message: "Tag selector did not match any Notes tag.",
          details: [
            "option": optionName,
            "tag_sha256": sha256Hex(selector),
          ]
        )
      }
      return (record: match, standardizedContent: match.standardizedContent ?? selector)
    }
  }

  private func noteTagContentSet(_ note: NotesNoteDetail) -> Set<String> {
    Set(note.tags.map { tag in
      standardizedTagContent(tag.standardizedContent ?? tag.displayText)
    })
  }

  private func tagDeleteDraft(_ options: CLIOptions) throws -> NotesTagDeleteDraft {
    guard options.targetOption("tags") == nil else {
      throw CLIError(
        code: .validationError,
        message: "`tags delete` accepts either `--tag` or `--tags`, not both.",
        details: ["allowed": "tag,tags"]
      )
    }
    let requestedTag = try normalizedTagOption(options)
    return try tagDeleteDraft(for: requestedTag)
  }

  private func tagConvertToTextDraft(_ options: CLIOptions, note: NotesNoteDetail) throws
    -> NotesTagConvertToTextDraft
  {
    let requestedTag = try normalizedTagOption(options)
    let requestedStandardized = standardizedTagContent(requestedTag)
    let tagReader = try tagReader()
    let tags = try tagReader.listTags(account: nil, limit: 2_000)
    let matchingTags = tags.filter { tagMatches($0, requestedTag) }
    guard let firstMatch = matchingTags.first else {
      throw CLIError(
        code: .notFound,
        message: "Tag selector did not match any Notes tag.",
        details: ["tag_sha256": sha256Hex(requestedStandardized)]
      )
    }

    let standardized = firstMatch.standardizedContent ?? requestedStandardized
    let presentOnNote = note.tags.contains { tagMatches($0, standardized) }
    guard presentOnNote else {
      throw CLIError(
        code: .notFound,
        message: "Tag selector did not match the selected Notes note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "tag_sha256": sha256Hex(standardized),
        ]
      )
    }

    let bodyStructure = try bodyStructureReader().readBodyStructure(noteID: note.id)
    guard let plainTextByteCount = bodyStructure.plainTextByteCount,
      let plainTextSHA256 = bodyStructure.plainTextSHA256
    else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes tag Convert to Text requires private body plaintext readback before mutation.",
        details: [
          "status": "gated",
          "id_sha256": sha256Hex(note.id),
          "tag_sha256": sha256Hex(standardized),
          "required_implementation": "typed_private_notes_framework_tag_token_text_rewrite",
          "required_verifier": "body_text_hash_preservation+tag_membership_absence",
        ]
      )
    }

    return NotesTagConvertToTextDraft(
      noteID: note.id,
      displayText: firstMatch.displayText,
      standardizedContent: standardized,
      matchedTagCount: matchingTags.count,
      wasPresentOnNote: presentOnNote,
      beforePlainTextByteCount: plainTextByteCount,
      beforePlainTextSHA256: plainTextSHA256
    )
  }

  private func tagDeleteDraft(for requestedTag: String) throws -> NotesTagDeleteDraft {
    let requestedStandardized = standardizedTagContent(requestedTag)
    let tagReader = try tagReader()
    let tags = try tagReader.listTags(account: nil, limit: 2_000)
    let matchingTags = tags.filter { tagMatches($0, requestedTag) }
    guard let firstMatch = matchingTags.first else {
      throw CLIError(
        code: .notFound,
        message: "Tag selector did not match any Notes tag.",
        details: ["tag_sha256": sha256Hex(requestedStandardized)]
      )
    }

    let standardized = firstMatch.standardizedContent ?? requestedStandardized
    let affectedNotes = try tagReader.readNotes(tag: standardized, limit: 2_000)
    return NotesTagDeleteDraft(
      displayText: firstMatch.displayText,
      standardizedContent: standardized,
      matchedTagCount: matchingTags.count,
      affectedNoteCount: affectedNotes.count
    )
  }

  private func tagBatchDeleteMutation(_ options: CLIOptions) throws -> CLICommandResult {
    let drafts = try tagBatchDeleteDrafts(options)
    let beforeAffectedNotes = try tagBatchDeleteAffectedNotes(drafts)
    let beforeSmartFolderTagCriteria = try smartFolderTagCriteriaSnapshots(tags: drafts.map(\.standardizedContent))
    return try mutation(
      operation: "notes.tags.delete.batch",
      scopeDigest: tagBatchDeleteScopeDigest(drafts: drafts, affectedNotes: beforeAffectedNotes),
      summary: tagBatchDeleteSummary(drafts: drafts, affectedNotes: beforeAffectedNotes),
      options: options,
      category: .destructiveSelection,
      allowFlags: ["--allow-destructive-selection"],
      dryRunNotes: [
        "Execution checks private Smart Folder cascade impact before removing every selected tag usage."
      ]
    ) {
      let mutator = try tagMutator()
      var writes: [NotesTagDeleteWriteResult] = []
      for draft in drafts {
        writes.append(try mutator.deleteTag(draft))
      }
      let verification = try mutationVerifier().verifyTagBatchDelete(
        operation: "notes.tags.delete.batch",
        drafts: drafts,
        beforeAffectedNotes: beforeAffectedNotes,
        beforeSmartFolderTagCriteria: beforeSmartFolderTagCriteria,
        results: writes
      )
      return try verifiedTagBatchDeleteResult(
        NotesTagBatchDeleteResult(
          operation: "notes.tags.delete.batch",
          changed: writes.contains { $0.changed },
          deletedTagCount: drafts.count,
          affectedNoteCount: beforeAffectedNotes.count,
          deletedTagHashes: drafts.map { sha256Hex($0.standardizedContent) },
          deletedTagIDHashes: writes.map { sha256Hex($0.tag.id) },
          affectedNoteIDHashes: beforeAffectedNotes.map { sha256Hex($0.id) },
          perTagAffectedNoteCounts: drafts.map(\.affectedNoteCount),
          verification: verification
        ))
    }
  }

  private func tagBatchDeleteDrafts(_ options: CLIOptions) throws -> [NotesTagDeleteDraft] {
    guard options.targetOption("tag") == nil else {
      throw CLIError(
        code: .validationError,
        message: "`tags delete` accepts either `--tag` or `--tags`, not both.",
        details: ["allowed": "tag,tags"]
      )
    }
    let requestedTags = try normalizedTagListOption(named: "tags", options: options)
    guard requestedTags.count >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "`tags delete --tags` requires at least two tags.",
        details: ["min_tag_count": "2"]
      )
    }
    guard requestedTags.count <= 16 else {
      throw CLIError(
        code: .validationError,
        message: "`tags delete --tags` supports at most 16 tags per command.",
        details: ["max_tag_count": "16"]
      )
    }

    var seen = Set<String>()
    var drafts: [NotesTagDeleteDraft] = []
    for tag in requestedTags {
      let standardized = standardizedTagContent(tag)
      guard seen.insert(standardized).inserted else {
        throw CLIError(
          code: .validationError,
          message: "`tags delete --tags` requires unique tags.",
          details: ["duplicate_tag_sha256": sha256Hex(standardized)]
        )
      }
      drafts.append(try tagDeleteDraft(for: tag))
    }
    return drafts
  }

  private func tagBatchDeleteAffectedNotes(_ drafts: [NotesTagDeleteDraft]) throws -> [NotesNoteDetail] {
    let tagReader = try tagReader()
    var notesByID: [String: NotesNoteDetail] = [:]
    for draft in drafts {
      let notes = try tagReader.readNotes(tag: draft.standardizedContent, limit: 2_000)
      for note in notes {
        notesByID[note.id] = note
      }
    }
    return notesByID.values.sorted { lhs, rhs in
      lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
    }
  }

  private func smartFolderTagCriteriaSnapshots(
    tags standardizedTags: [String]
  ) throws -> [NotesSmartFolderTagCriteriaSnapshot] {
    var snapshotsBySmartFolderID: [String: NotesSmartFolderTagCriteriaSnapshot] = [:]
    for tag in Set(standardizedTags) {
      for snapshot in try smartFolderTagCriteriaSnapshots(tag: tag) {
        snapshotsBySmartFolderID[snapshot.smartFolderID] = snapshot
      }
    }
    return snapshotsBySmartFolderID.values.sorted { lhs, rhs in
      lhs.smartFolderID.localizedStandardCompare(rhs.smartFolderID) == .orderedAscending
    }
  }

  private func smartFolderTagCriteriaSnapshots(
    tag standardizedTag: String
  ) throws -> [NotesSmartFolderTagCriteriaSnapshot] {
    let smartFolderReader = try smartFolderReader()
    let smartFolders = try smartFolderReader.listSmartFolders(account: nil, limit: 2_000)
    var snapshots: [NotesSmartFolderTagCriteriaSnapshot] = []
    for smartFolder in smartFolders
      where smartFolderTagCriteria(smartFolder.criteria, containsTag: standardizedTag)
    {
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: smartFolder.id, limit: 2_000)
      let matchingNoteIDHashes = matchingNotes.map { sha256Hex($0.id) }.sorted()
      let tagSelection = smartFolder.criteria?.tagSelection
      snapshots.append(
        NotesSmartFolderTagCriteriaSnapshot(
          smartFolderID: smartFolder.id,
          queryPresent: smartFolder.queryPresent,
          selectedTagCount: tagSelection?.selectedTagCount,
          tagIdentifiersSHA256: tagSelection?.tagIdentifiersSHA256,
          displayTextsSHA256: tagSelection?.displayTextsSHA256,
          matchingNoteIDHashes: matchingNoteIDHashes,
          matchingNoteCount: matchingNoteIDHashes.count,
          visibleNoteCount: smartFolder.visibleNoteCount
        ))
    }
    return snapshots.sorted { lhs, rhs in
      lhs.smartFolderID.localizedStandardCompare(rhs.smartFolderID) == .orderedAscending
    }
  }

  private func smartFolderTagCriteria(
    _ criteria: NotesSmartFolderCriteriaSummary?,
    containsTag standardizedTag: String
  ) -> Bool {
    smartFolderTagCriteriaDisplayTexts(criteria)
      .contains { standardizedTagContent($0) == standardizedTag }
  }

  private func smartFolderTagCriteriaDisplayTexts(
    _ criteria: NotesSmartFolderCriteriaSummary?
  ) -> [String] {
    guard let tagSelection = criteria?.tagSelection else {
      return []
    }
    return [
      tagSelection.displayTexts ?? [],
      tagSelection.includedDisplayTexts ?? [],
      tagSelection.excludedDisplayTexts ?? [],
    ].flatMap { $0 }
  }

  private func tagWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.tags.audit"
    let records = notesTagWorkflowAuditRecords()
    let summary = notesTagWorkflowAuditSummary(records)
    let verification = verifyTagWorkflowAudit(records: records, summary: summary)
    let response = NotesTagWorkflowAuditResponse(
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

  private func notesTagWorkflowAuditRecords() -> [NotesTagWorkflowAuditRecord] {
    struct TagWorkflowAuditItem {
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
      TagWorkflowAuditItem(
        family: "tag_metadata_list",
        guideSection: "Add tags to notes",
        status: "supported",
        appleCapability: "show_tags_section_sidebar",
        command: "tags list [--account ACCOUNT]",
        mechanism: "typed_private_notes_framework_tag_reader",
        requiredImplementation: "ICHashtag metadata listing",
        requiredVerifier: "private_tag_metadata_readback+bounded_account_filter",
        safetyGate: "bounded-read",
        privacyBoundary: "tag_metadata_without_note_bodies",
        reason: "The accepted tag list exposes the Tags sidebar-style metadata surface without reading note bodies."
      ),
      TagWorkflowAuditItem(
        family: "single_tag_note_search",
        guideSection: "Search by tags",
        status: "supported",
        appleCapability: "search_notes_by_one_tag",
        command: "tags search --tag TAG",
        mechanism: "typed_private_notes_framework_tag_reader",
        requiredImplementation: "ICHashtag note membership readback",
        requiredVerifier: "tag_selector_hash+matching_note_summary_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "note_summaries_without_note_bodies",
        reason: "The accepted tag search returns bounded note summaries for one selected tag."
      ),
      TagWorkflowAuditItem(
        family: "note_tag_add",
        guideSection: "Add tags to notes",
        status: "supported",
        appleCapability: "add_tag_to_one_note",
        command: "tags add --id NOTE_ID --tag TAG",
        mechanism: "typed_private_notes_framework_tag_writer",
        requiredImplementation: "ICNote.addHashtag(toNoteBody:onlyIfMissing:)",
        requiredVerifier: "tag_membership_readback+note_identity_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "tag_value_and_note_metadata_without_note_body",
        reason: "The accepted private writer adds one tag to one editable note and verifies membership readback."
      ),
      TagWorkflowAuditItem(
        family: "note_tag_remove_membership",
        guideSection: "Remove a tag",
        status: "supported",
        appleCapability: "remove_tag_membership_from_one_note",
        command: "tags remove --id NOTE_ID --tag TAG",
        mechanism: "typed_private_notes_framework_tag_writer",
        requiredImplementation: "ICNote.removeHashtag",
        requiredVerifier: "tag_membership_readback+other_tag_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "tag_value_and_note_metadata_without_note_body",
        reason: "The accepted private writer removes one tag membership and preserves other tags; Apple Convert to Text is supported separately with body plaintext hash readback."
      ),
      TagWorkflowAuditItem(
        family: "tag_rename_single_non_merge",
        guideSection: "Rename a tag",
        status: "supported",
        appleCapability: "rename_one_tag_to_new_name",
        command: "tags rename --tag OLD --name NEW",
        mechanism: "typed_private_notes_framework_tag_writer",
        requiredImplementation: "ICHashtag.renameHashtags",
        requiredVerifier: "old_tag_empty+new_tag_affected_note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "tag_hashes_and_affected_note_counts_without_note_bodies",
        reason: "The accepted rename path verifies affected note preservation for a rename to a non-existing target tag."
      ),
      TagWorkflowAuditItem(
        family: "tag_delete_single",
        guideSection: "Remove a tag",
        status: "supported",
        appleCapability: "delete_one_tag_from_all_notes",
        command: "tags delete --tag TAG --allow-destructive-selection",
        mechanism: "typed_private_notes_framework_tag_writer",
        requiredImplementation: "ICHashtag delete with Smart Folder cascade preflight",
        requiredVerifier: "old_tag_empty+tag_list_absence+affected_note_readback",
        safetyGate: "allow-destructive-selection/readback",
        privacyBoundary: "tag_hashes_and_affected_note_counts_without_note_bodies",
        reason: "The accepted delete path removes one tag after cascade preflight and verifies the old tag is no longer listed or found on affected notes."
      ),
      TagWorkflowAuditItem(
        family: "suggested_tag_picker",
        guideSection: "Add tags to notes",
        status: "delegated",
        appleCapability: "choose_from_suggested_tags",
        command: "Notes.app tag suggestion UI",
        mechanism: "delegated_user_facing_notes_and_reminders_suggestion_surface",
        requiredImplementation: "Notes.app editor suggestions",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Suggested tags combine editor UI state and existing Notes/Reminders tags; the CLI accepts explicit tag values instead."
      ),
      TagWorkflowAuditItem(
        family: "sidebar_click_tag_selection_ui",
        guideSection: "Search by tags",
        status: "delegated",
        appleCapability: "click_tags_in_sidebar",
        command: "Notes.app Tags sidebar UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "Notes.app sidebar selection",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Clicking tags and managing sidebar selection is transient Notes.app UI state; semantic results are tracked separately."
      ),
      TagWorkflowAuditItem(
        family: "shared_note_tag_adoption_ui",
        guideSection: "Add tags to notes / Rename a tag",
        status: "delegated",
        appleCapability: "participant_add_dimmed_shared_tag_to_own_tags",
        command: "Notes.app shared-note tag context menu",
        mechanism: "delegated_collaboration_ui_surface",
        requiredImplementation: "Notes.app participant tag adoption UI",
        requiredVerifier: "delegated_collaboration_accounting",
        safetyGate: "none",
        privacyBoundary: "no_participant_identifiers_or_note_bodies",
        reason: "Adopting a dimmed shared-note tag is participant-specific collaboration UI behavior, not a direct Notes private-framework CLI mutation."
      ),
      TagWorkflowAuditItem(
        family: "multi_tag_all_any_search",
        guideSection: "Search by tags",
        status: "supported",
        appleCapability: "search_by_multiple_tags_all_or_any",
        command: "tags search --tags TAGS --mode all|any",
        mechanism: "typed_private_notes_framework_tag_reader",
        requiredImplementation: "ICHashtag note membership readback plus private note tag readback filtering",
        requiredVerifier: "multi_tag_match_readback+mode_accounting+note_summary_privacy",
        safetyGate: "bounded-read",
        privacyBoundary: "tag_hashes_and_note_summaries_without_note_bodies",
        reason: "The accepted tag search now resolves multiple selected tags, uses private tag-scoped note reads, applies All/Any membership filtering from private note tag readback, and returns note summaries only."
      ),
      TagWorkflowAuditItem(
        family: "tag_exclusion_search",
        guideSection: "Search by tags",
        status: "supported",
        appleCapability: "exclude_notes_that_include_deselected_tag",
        command: "tags search --include-tags TAGS --exclude-tags TAGS --mode all|any",
        mechanism: "typed_private_notes_framework_tag_reader",
        requiredImplementation: "ICHashtag note membership readback plus private note tag exclusion filtering",
        requiredVerifier: "include_exclude_tag_membership_readback+note_summary_privacy",
        safetyGate: "bounded-read",
        privacyBoundary: "tag_hashes_and_note_summaries_without_note_bodies",
        reason: "The accepted tag search now supports include/exclude tag sets and filters matched private note summaries by private note tag readback without printing note bodies."
      ),
      TagWorkflowAuditItem(
        family: "rename_merge_existing_tag",
        guideSection: "Rename a tag",
        status: "supported",
        appleCapability: "rename_tag_to_existing_tag_for_grouping",
        command: "tags rename --tag OLD --name EXISTING --allow-merge",
        mechanism: "typed_private_notes_framework_tag_merge_writer",
        requiredImplementation: "private tag add/remove merge over affected source-tag notes",
        requiredVerifier: "source_tag_empty+target_tag_membership_readback+source_note_identity_preservation",
        safetyGate: "dry-run/readback/allow-merge",
        privacyBoundary: "tag_hashes_and_affected_note_counts_without_note_bodies",
        reason: "The accepted merge rename path requires explicit `--allow-merge`, adds the existing target tag to affected source-tag notes through private tag membership APIs, removes the source tag, and verifies source note preservation without printing note bodies."
      ),
      TagWorkflowAuditItem(
        family: "smart_folder_tag_update_readback",
        guideSection: "Rename a tag / Remove a tag",
        status: "supported",
        appleCapability: "rename_or_delete_updates_smart_folders_that_use_tag",
        command: "tags rename/delete with Smart Folder criteria readback",
        mechanism: "typed_private_notes_framework_smart_folder_tag_criteria_readback",
        requiredImplementation: "private Smart Folder criteria summary readback after tag rename/delete",
        requiredVerifier: "old_tag_criteria_absence+new_tag_criteria_presence+matching_note_hash_preservation",
        safetyGate: "dry-run/readback/allow-destructive-selection",
        privacyBoundary: "criteria_hashes_without_raw_query_json_by_default",
        reason: "The accepted tag rename/delete verifier snapshots impacted private Smart Folder tag criteria, verifies old tag criteria absence after mutation, verifies renamed tag criteria presence and matching note hash preservation, and keeps criteria JSON out of normal output."
      ),
      TagWorkflowAuditItem(
        family: "multi_tag_delete",
        guideSection: "Remove a tag",
        status: "supported",
        appleCapability: "delete_multiple_tags",
        command: "tags delete --tags TAGS --allow-destructive-selection",
        mechanism: "typed_private_notes_framework_batch_tag_delete",
        requiredImplementation: "private tag delete path with batch selection gating",
        requiredVerifier: "per_tag_cascade_preflight+batch_affected_note_readback",
        safetyGate: "dry-run/allow-destructive-selection/readback",
        privacyBoundary: "tag_hashes_and_affected_note_counts_without_note_bodies",
        reason: "The accepted batch delete command requires at least two explicit unique tags, keeps batch tag evidence hash-only, reuses the typed private single-tag delete path including Smart Folder cascade preflight, and verifies every affected note after execution."
      ),
      TagWorkflowAuditItem(
        family: "convert_tag_to_plain_text",
        guideSection: "Remove a tag",
        status: "supported",
        appleCapability: "convert_tag_token_to_plain_text",
        command: "tags convert-to-text --id NOTE_ID --tag TAG",
        mechanism: "typed_private_notes_framework_tag_body_text_writer",
        requiredImplementation: "ICNote.removeHashtag plus private body plaintext readback",
        requiredVerifier: "body_text_hash_preservation+tag_membership_absence",
        safetyGate: "dry-run/readback",
        privacyBoundary: "body_hashes_without_note_body_text",
        reason: "The accepted Convert to Text command removes one selected private hashtag token and verifies plaintext body byte-count/hash preservation plus tag membership absence without printing note body text."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesTagWorkflowAuditRecord(
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

  private func notesTagWorkflowAuditSummary(
    _ records: [NotesTagWorkflowAuditRecord]
  ) -> NotesTagWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesTagWorkflowAuditSummary(
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

  private func verifyTagWorkflowAudit(
    records: [NotesTagWorkflowAuditRecord],
    summary: NotesTagWorkflowAuditSummary
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
        name: "tag_read_search_supported",
        expected: true,
        actual: supported.isSuperset(
          of: ["tag_metadata_list", "single_tag_note_search", "multi_tag_all_any_search", "tag_exclusion_search"]
        )
      ),
      verificationBoolCheck(
        name: "tag_membership_mutations_supported",
        expected: true,
        actual: supported.isSuperset(of: ["note_tag_add", "note_tag_remove_membership"])
      ),
      verificationBoolCheck(
        name: "tag_convert_to_text_supported",
        expected: true,
        actual: supported.contains("convert_tag_to_plain_text")
      ),
      verificationBoolCheck(
        name: "tag_rename_delete_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "tag_rename_single_non_merge",
            "rename_merge_existing_tag",
            "smart_folder_tag_update_readback",
            "tag_delete_single",
            "multi_tag_delete",
          ]
        )
      ),
      verificationBoolCheck(
        name: "tag_ui_and_shared_surfaces_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: ["suggested_tag_picker", "sidebar_click_tag_selection_ui", "shared_note_tag_adoption_ui"]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_tag_semantics_gated",
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
      operation: "notes.tags.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.tags.audit"),
      checks: checks
    )
  }

  func tagReader() throws -> any NotesTagReading {
    guard let tagReader = implementation as? any NotesTagReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes tag commands require a private-framework tag reader.",
        details: [
          "capability": "tags",
          "required_module": "NotesShared",
        ]
      )
    }
    return tagReader
  }

  private func tagMutator() throws -> any NotesTagMutating {
    guard let tagMutator = implementation as? any NotesTagMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes tag mutations require a private-framework tag writer.",
        details: [
          "capability": "tags",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return tagMutator
  }

  private func verifiedTagBatchDeleteResult(_ result: NotesTagBatchDeleteResult) throws
    -> NotesTagBatchDeleteResult
  {
    guard let verification = result.verification, verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes batch tag delete verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification?.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ",") ?? "missing_verification",
          "target_id_sha256": result.verification?.targetIDSHA256 ?? "",
        ]
      )
    }
    return result
  }
}
