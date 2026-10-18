import Foundation
import Utility

extension NotesCommand {

  func smartFolderCreateDraft(_ options: CLIOptions) throws -> NotesSmartFolderCreateDraft {
    let name = try normalizedOption("name", options: options)
    let account = try accountIdentity(selector: try requiredOption("account", options: options))
    let requestedTags = try normalizedSmartFolderTagSelectors(options)
    let tagMatch = try normalizedSmartFolderTagSelectionMatch(options, tagCount: requestedTags.count)
    let smartFolders = try smartFolderReader().listSmartFolders(account: account.name, limit: 2_000)
    guard !smartFolders.contains(where: {
      $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        && $0.accountName.localizedCaseInsensitiveCompare(account.name) == .orderedSame
    }) else {
      throw CLIError(
        code: .validationError,
        message: "A Notes Smart Folder with that name already exists in the selected account.",
        details: [
          "name_sha256": sha256Hex(name),
          "account_sha256": sha256Hex(account.name),
        ]
      )
    }

    let tagReader = try tagReader()
    let tags = try tagReader.listTags(account: account.name, limit: 2_000)
    let tagSelection = try smartFolderTagSelectionInput(
      requestedTags: requestedTags,
      tags: tags,
      accountName: account.name,
      tagOperator: tagMatch.tagOperator,
      tagReader: tagReader
    )
    return NotesSmartFolderCreateDraft(
      name: name,
      accountID: account.id,
      accountName: account.name,
      tagDisplayText: tagSelection.displayTexts[0],
      tagStandardizedContent: tagSelection.standardizedContents[0],
      tagDisplayTexts: tagSelection.displayTexts,
      tagStandardizedContents: tagSelection.standardizedContents,
      tagMatch: tagMatch.match,
      tagOperator: tagMatch.tagOperator,
      matchedTagCount: tagSelection.matchedTagCount,
      matchingNoteCount: tagSelection.matchingNoteCount
    )
  }

  private struct SmartFolderTagSelectionInput {
    var displayTexts: [String]
    var standardizedContents: [String]
    var matchedTagCount: Int
    var matchingNoteCount: Int
  }

  private func normalizedSmartFolderTagSelectors(_ options: CLIOptions) throws -> [String] {
    _ = try requiredOption("tag", options: options)
    let selectors = try normalizedTagListOption(named: "tag", options: options)
    guard !selectors.isEmpty else {
      throw CLIError(code: .validationError, message: "`--tag` must contain at least one tag.")
    }
    guard selectors.count <= 16 else {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folder tag selection supports at most 16 tags per command.",
        details: ["max_tag_count": "16"]
      )
    }
    var seen = Set<String>()
    var duplicates: [String] = []
    for selector in selectors {
      let standardized = standardizedTagContent(selector)
      if !seen.insert(standardized).inserted {
        duplicates.append(sha256Hex(standardized))
      }
    }
    guard duplicates.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folder tag selection cannot contain duplicate tags.",
        details: ["duplicate_tag_sha256": duplicates.joined(separator: ",")]
      )
    }
    return selectors
  }

  private func normalizedSmartFolderTagSelectionMatch(
    _ options: CLIOptions,
    tagCount: Int
  ) throws -> (match: String, tagOperator: Int) {
    guard let raw = try normalizedOptionalOption("match", options: options) else {
      return ("all", notesSmartFolderTagSelectionOperatorAll)
    }
    let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "_", with: "-")
      .localizedLowercase
    switch value {
    case "all", "and":
      return ("all", notesSmartFolderTagSelectionOperatorAll)
    case "any", "or":
      guard tagCount > 1 else {
        throw CLIError(
          code: .validationError,
          message: "Smart Folder `--match any` requires multiple tags.",
          details: [
            "tag_count": "\(tagCount)",
            "required_tag_count": "2",
          ]
        )
      }
      return ("any", notesSmartFolderTagSelectionOperatorAny)
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Smart Folder tag match mode.",
        details: [
          "match_sha256": sha256Hex(value),
          "supported": "all,any",
        ]
      )
    }
  }

  private func smartFolderTagSelectionInput(
    requestedTags: [String],
    tags: [NotesTagRecord],
    accountName: String,
    tagOperator: Int,
    tagReader: any NotesTagReading
  ) throws -> SmartFolderTagSelectionInput {
    var displayTexts: [String] = []
    var standardizedContents: [String] = []
    var matchedTagCount = 0
    for requestedTag in requestedTags {
      let requestedStandardized = standardizedTagContent(requestedTag)
      let matchingTags = tags.filter { tagMatches($0, requestedTag) }
      guard let firstMatch = matchingTags.first else {
        throw CLIError(
          code: .notFound,
          message: "Tag selector did not match any Notes tag in the selected account.",
          details: [
            "tag_sha256": sha256Hex(requestedStandardized),
            "account_sha256": sha256Hex(accountName),
          ]
        )
      }
      displayTexts.append(firstMatch.displayText)
      standardizedContents.append(firstMatch.standardizedContent ?? requestedStandardized)
      matchedTagCount += matchingTags.count
    }
    let matchingNoteCount = try smartFolderTagSelectionMatchingNoteCount(
      standardizedContents: standardizedContents,
      accountName: accountName,
      tagOperator: tagOperator,
      tagReader: tagReader
    )
    return SmartFolderTagSelectionInput(
      displayTexts: displayTexts,
      standardizedContents: standardizedContents,
      matchedTagCount: matchedTagCount,
      matchingNoteCount: matchingNoteCount
    )
  }

  private func smartFolderTagSelectionMatchingNoteCount(
    standardizedContents: [String],
    accountName: String,
    tagOperator: Int,
    tagReader: any NotesTagReading
  ) throws -> Int {
    var matchingIDs: Set<String>?
    for standardizedContent in standardizedContents {
      let noteIDs = Set(try tagReader.readNotes(tag: standardizedContent, limit: 2_000)
        .filter { $0.accountName.localizedCaseInsensitiveCompare(accountName) == .orderedSame }
        .map(\.id))
      if tagOperator == notesSmartFolderTagSelectionOperatorAny {
        matchingIDs = matchingIDs.map { $0.union(noteIDs) } ?? noteIDs
      } else {
        matchingIDs = matchingIDs.map { $0.intersection(noteIDs) } ?? noteIDs
      }
    }
    return matchingIDs?.count ?? 0
  }

  func smartFolderDeleteDraft(_ options: CLIOptions) throws -> NotesSmartFolderDeleteDraft {
    let smartFolder = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateDeletableSmartFolder(smartFolder)
    return NotesSmartFolderDeleteDraft(
      smartFolderID: smartFolder.id,
      name: smartFolder.name,
      accountName: smartFolder.accountName,
      queryPresent: smartFolder.queryPresent,
      visibleNoteCount: smartFolder.visibleNoteCount
    )
  }

  private func validateConvertibleSmartFolderSource(_ folder: NotesFolderRecord) throws {
    let blocked = folder.isTrash == true
      || folder.isSmartFolder == true
      || folder.isSystemFolder == true
      || folder.isDefault == true
    guard !blocked else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder conversion requires a user-created concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    guard folder.isSharedViaICloud != true,
      folder.isSharedReadOnly != true,
      folder.isSubfolderOfReadOnlyFolder != true,
      folder.supportsEditingNotes != false,
      folder.isDeletable != false
    else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder conversion cannot convert shared, read-only, or non-deletable folders.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  func smartFolderFolderConversionDraft(_ options: CLIOptions) throws
    -> NotesSmartFolderFolderConversionDraft
  {
    let folderSelector = try requiredOption("folder", options: options)
    let accountName = try options.targetOption("account")
      .map { try accountIdentity(selector: $0).name }
    let folder = try accountName
      .map { try folderIdentity(selector: folderSelector, accountName: $0) }
      ?? folderIdentity(selector: folderSelector)
    try validateConvertibleSmartFolderSource(folder)

    let accountFolders = try implementation.listFolders(account: folder.accountName, limit: 2_000)
    let childFolderCount = folder.childFolderCount
      ?? accountFolders.filter { $0.parentID == folder.id }.count
    guard childFolderCount == 0 else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder conversion requires a folder with no subfolders.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "child_folder_count": "\(childFolderCount)",
        ]
      )
    }

    let notes = try convertibleFolderNotes(folder)
    if let visibleNoteCount = folder.visibleNoteCount, visibleNoteCount > notes.count {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes folder conversion requires complete bounded note selection.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "visible_note_count": "\(visibleNoteCount)",
          "loaded_note_count": "\(notes.count)",
          "status": "gated",
        ]
      )
    }
    if folder.visibleNoteCount == nil, notes.count >= 2_000 {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes folder conversion requires complete bounded note selection.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "loaded_note_count": "\(notes.count)",
          "status": "gated",
        ]
      )
    }

    let stateReader = try noteStateReader()
    let blockedStates = try notes.compactMap { note -> NotesNoteStateRecord? in
      let state = try stateReader.readNoteState(noteID: note.id)
      let shared = state.isSharedViaICloud || state.isSharedViaICloudFolder || state.isSharedReadOnly
        || (state.participantCount ?? 0) > 0
      let blocked = state.isDeletedOrInTrash || state.folderIsTrash == true
        || state.isPasswordProtected || state.isPasswordProtectedAndLocked == true
        || shared || state.isEditable == false
      return blocked ? state : nil
    }
    guard blockedStates.isEmpty else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder conversion cannot include locked, shared, deleted, or read-only notes.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "blocked_note_count": "\(blockedStates.count)",
          "blocked_note_hashes": blockedStates.map { sha256Hex($0.noteID) }.joined(separator: ","),
        ]
      )
    }

    let existingSmartFolders = try smartFolderReader().listSmartFolders(account: folder.accountName, limit: 2_000)
    guard !existingSmartFolders.contains(where: {
      $0.name.localizedCaseInsensitiveCompare(folder.name) == .orderedSame
    }) else {
      throw CLIError(
        code: .validationError,
        message: "A Notes Smart Folder with the source folder name already exists in the selected account.",
        details: [
          "folder_name_sha256": sha256Hex(folder.name),
          "account_sha256": sha256Hex(folder.accountName),
        ]
      )
    }

    let defaultFolder = accountFolders.first {
      $0.isDefault == true
        && $0.accountName.localizedCaseInsensitiveCompare(folder.accountName) == .orderedSame
    }
    return NotesSmartFolderFolderConversionDraft(
      folderID: folder.id,
      folderName: folder.name,
      accountName: folder.accountName,
      parentID: folder.parentID,
      visibleNoteCount: folder.visibleNoteCount ?? notes.count,
      childFolderCount: childFolderCount,
      noteIDs: notes.map(\.id),
      tagDisplayText: folder.name,
      tagStandardizedContent: standardizedTagContent(folder.name),
      targetFolderID: defaultFolder?.id,
      targetFolderName: defaultFolder?.name
    )
  }

  private func convertibleFolderNotes(_ folder: NotesFolderRecord) throws -> [NotesNoteSummary] {
    guard let lister = implementation as? any NotesAccountScopedListing else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes folder conversion requires account-scoped private note listing.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "capability": "account_scoped_visible_note_selection",
          "status": "gated",
          "required_implementation": "typed_private_notes_framework_account_scoped_note_listing",
        ]
      )
    }
    return try lister.listNotes(account: folder.accountName, folder: folder.name, limit: 2_000)
      .filter {
        $0.accountName.localizedCaseInsensitiveCompare(folder.accountName) == .orderedSame
          && $0.folderName.localizedCaseInsensitiveCompare(folder.name) == .orderedSame
      }
  }

  func smartFolderUpdateDraft(_ options: CLIOptions) throws -> NotesSmartFolderUpdateDraft {
    let smartFolder = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateEditableSmartFolder(smartFolder, operation: "updated")
    let requestedTags = try normalizedSmartFolderTagSelectors(options)
    let tagMatch = try normalizedSmartFolderTagSelectionMatch(options, tagCount: requestedTags.count)
    let tagReader = try tagReader()
    let tags = try tagReader.listTags(account: smartFolder.accountName, limit: 2_000)
    let tagSelection = try smartFolderTagSelectionInput(
      requestedTags: requestedTags,
      tags: tags,
      accountName: smartFolder.accountName,
      tagOperator: tagMatch.tagOperator,
      tagReader: tagReader
    )
    return NotesSmartFolderUpdateDraft(
      smartFolderID: smartFolder.id,
      name: smartFolder.name,
      accountName: smartFolder.accountName,
      previousQueryPresent: smartFolder.queryPresent,
      previousQuerySHA256: smartFolder.querySHA256,
      previousVisibleNoteCount: smartFolder.visibleNoteCount,
      tagDisplayText: tagSelection.displayTexts[0],
      tagStandardizedContent: tagSelection.standardizedContents[0],
      tagDisplayTexts: tagSelection.displayTexts,
      tagStandardizedContents: tagSelection.standardizedContents,
      tagMatch: tagMatch.match,
      tagOperator: tagMatch.tagOperator,
      matchedTagCount: tagSelection.matchedTagCount,
      matchingNoteCount: tagSelection.matchingNoteCount
    )
  }

  func smartFolderBuiltInCriteriaCreateDraft(_ options: CLIOptions) throws
    -> NotesSmartFolderBuiltInCriteriaCreateDraft
  {
    let name = try normalizedOption("name", options: options)
    let account = try accountIdentity(selector: try requiredOption("account", options: options))
    let criteriaKinds = try normalizedSmartFolderBuiltInCriteriaList(try requiredOption("criteria", options: options))
    let criteriaKind = criteriaKinds.joined(separator: ",")
    let criteriaMatch = try normalizedSmartFolderBuiltInCriteriaMatch(options.targetOption("match"))
    let requestedIncludeRecentlyDeleted = options.hasTargetFlag("include-recently-deleted")
    let dateCriteria = try smartFolderDateCriteriaParameters(
      kind: smartFolderDateCriteriaReferenceKind(criteriaKinds: criteriaKinds, options: options),
      options: options
    )
    let folderCriteriaByKind = try smartFolderFolderCriteriaParametersByKind(
      kinds: criteriaKinds,
      accountName: account.name,
      options: options
    )
    let folderCriteria = criteriaKinds.compactMap { folderCriteriaByKind[$0] }.first
    let participantCriteria = try smartFolderParticipantCriteriaParameters(kind: criteriaKinds[0], options: options)
    try validateSmartFolderBuiltInCriteriaOptions(
      kinds: criteriaKinds,
      includeRecentlyDeleted: requestedIncludeRecentlyDeleted
    )
    try validateSmartFolderBuiltInCriteriaMatch(kinds: criteriaKinds, match: criteriaMatch.match)
    let includeRecentlyDeleted = effectiveSmartFolderBuiltInCriteriaIncludeRecentlyDeleted(
      kinds: criteriaKinds,
      requestedIncludeRecentlyDeleted: requestedIncludeRecentlyDeleted
    )
    try validateSmartFolderDateCriteriaParameters(kinds: criteriaKinds, dateCriteria: dateCriteria)
    try validateSmartFolderFolderCriteriaParameters(
      kinds: criteriaKinds,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: folderCriteriaByKind
    )
    try validateSmartFolderParticipantCriteriaParameters(kinds: criteriaKinds, participantCriteria: participantCriteria)
    let smartFolders = try smartFolderReader().listSmartFolders(account: account.name, limit: 2_000)
    guard !smartFolders.contains(where: {
      $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        && $0.accountName.localizedCaseInsensitiveCompare(account.name) == .orderedSame
    }) else {
      throw CLIError(
        code: .validationError,
        message: "A Notes Smart Folder with that name already exists in the selected account.",
        details: [
          "name_sha256": sha256Hex(name),
          "account_sha256": sha256Hex(account.name),
        ]
      )
    }
    return NotesSmartFolderBuiltInCriteriaCreateDraft(
      name: name,
      accountID: account.id,
      accountName: account.name,
      criteriaKind: criteriaKind,
      criteriaKinds: criteriaKinds,
      criteriaMatch: criteriaMatch.match,
      joinOperator: criteriaMatch.joinOperator,
      includeRecentlyDeleted: includeRecentlyDeleted,
      dateCriteria: dateCriteria,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: folderCriteriaByKind,
      participantCriteria: participantCriteria
    )
  }

  func smartFolderBuiltInCriteriaUpdateDraft(_ options: CLIOptions) throws
    -> NotesSmartFolderBuiltInCriteriaUpdateDraft
  {
    let smartFolder = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateEditableSmartFolder(smartFolder, operation: "updated with built-in criteria")
    let criteriaKinds = try normalizedSmartFolderBuiltInCriteriaList(try requiredOption("criteria", options: options))
    let criteriaKind = criteriaKinds.joined(separator: ",")
    let criteriaMatch = try normalizedSmartFolderBuiltInCriteriaMatch(options.targetOption("match"))
    let requestedIncludeRecentlyDeleted = options.hasTargetFlag("include-recently-deleted")
    let dateCriteria = try smartFolderDateCriteriaParameters(
      kind: smartFolderDateCriteriaReferenceKind(criteriaKinds: criteriaKinds, options: options),
      options: options
    )
    let folderCriteriaByKind = try smartFolderFolderCriteriaParametersByKind(
      kinds: criteriaKinds,
      accountName: smartFolder.accountName,
      options: options
    )
    let folderCriteria = criteriaKinds.compactMap { folderCriteriaByKind[$0] }.first
    let participantCriteria = try smartFolderParticipantCriteriaParameters(kind: criteriaKinds[0], options: options)
    try validateSmartFolderBuiltInCriteriaOptions(
      kinds: criteriaKinds,
      includeRecentlyDeleted: requestedIncludeRecentlyDeleted
    )
    try validateSmartFolderBuiltInCriteriaMatch(kinds: criteriaKinds, match: criteriaMatch.match)
    let includeRecentlyDeleted = effectiveSmartFolderBuiltInCriteriaIncludeRecentlyDeleted(
      kinds: criteriaKinds,
      requestedIncludeRecentlyDeleted: requestedIncludeRecentlyDeleted
    )
    try validateSmartFolderDateCriteriaParameters(kinds: criteriaKinds, dateCriteria: dateCriteria)
    try validateSmartFolderFolderCriteriaParameters(
      kinds: criteriaKinds,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: folderCriteriaByKind
    )
    try validateSmartFolderParticipantCriteriaParameters(kinds: criteriaKinds, participantCriteria: participantCriteria)
    return NotesSmartFolderBuiltInCriteriaUpdateDraft(
      smartFolderID: smartFolder.id,
      name: smartFolder.name,
      accountName: smartFolder.accountName,
      previousQueryPresent: smartFolder.queryPresent,
      previousQuerySHA256: smartFolder.querySHA256,
      previousVisibleNoteCount: smartFolder.visibleNoteCount,
      criteriaKind: criteriaKind,
      criteriaKinds: criteriaKinds,
      criteriaMatch: criteriaMatch.match,
      joinOperator: criteriaMatch.joinOperator,
      includeRecentlyDeleted: includeRecentlyDeleted,
      dateCriteria: dateCriteria,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: folderCriteriaByKind,
      participantCriteria: participantCriteria
    )
  }

  private struct NotesSmartFolderFilterMutationResolvedParameters {
    var dateCriteria: NotesSmartFolderDateCriteriaParameters?
    var folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters]
    var participantCriteria: NotesSmartFolderParticipantCriteriaParameters?

    init(
      dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
      folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:],
      participantCriteria: NotesSmartFolderParticipantCriteriaParameters? = nil
    ) {
      self.dateCriteria = dateCriteria
      self.folderCriteriaByKind = folderCriteriaByKind
      self.participantCriteria = participantCriteria
    }
  }

  func smartFolderFilterMutation(
    mutationKind: String,
    operation: String,
    appleCapability: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    try validateMutationIntent(options)
    let draft = try smartFolderFilterMutationDraft(
      mutationKind: mutationKind,
      operation: operation,
      appleCapability: appleCapability,
      options: options
    )
    return try mutation(
      operation: operation,
      scopeDigest: smartFolderFilterMutationScopeDigest(draft),
      summary: smartFolderFilterMutationSummary(draft),
      options: options
    ) {
      let write = try smartFolderMutator().updateSmartFolderBuiltInCriteria(draft.updateDraft)
      let notes = try smartFolderReader().listSmartFolderNotes(
        smartFolderID: write.smartFolder.id,
        limit: 2_000
      )
      let verification = try mutationVerifier().verifySmartFolderFilterMutation(
        operation: operation,
        draft: draft,
        result: write,
        matchingNotes: notes
      )
      return try verifiedSmartFolderMutationResult(
        NotesSmartFolderMutationResult(
          operation: operation,
          changed: write.changed,
          smartFolder: write.smartFolder,
          criteriaKind: draft.updateDraft.criteriaKind,
          criteriaKinds: draft.resultingCriteriaKinds,
          matchingNoteCount: notes.count,
          verification: verification
        ))
    }
  }

  private func smartFolderFilterMutationDraft(
    mutationKind: String,
    operation: String,
    appleCapability: String,
    options: CLIOptions
  ) throws -> NotesSmartFolderFilterMutationDraft {
    let smartFolder = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateEditableSmartFolder(smartFolder, operation: "updated by filter mutation")
    try validateReusableSmartFolderCriteria(smartFolder, operation: "updated by filter mutation")
    guard let criteria = smartFolder.criteria,
      let previousKinds = smartFolderPromotedCriteriaKinds(from: criteria)
    else {
      throw smartFolderFilterMutationReconstructionError(
        operation: operation,
        appleCapability: appleCapability,
        smartFolderID: smartFolder.id,
        reason: "existing_criteria_not_promoted_filter_selection"
      )
    }

    let criteriaKind = try smartFolderFilterMutationCriteriaKind(
      mutationKind: mutationKind,
      operation: operation,
      appleCapability: appleCapability,
      smartFolderID: smartFolder.id,
      options: options
    )
    let ordinal = try smartFolderFilterMutationOrdinal(
      mutationKind: mutationKind,
      providedOrdinal: options.targetOption("ordinal"),
      previousCount: previousKinds.count,
      operation: operation,
      smartFolderID: smartFolder.id
    )
    let resultingKinds = try smartFolderFilterMutationResultingKinds(
      mutationKind: mutationKind,
      ordinal: ordinal,
      criteriaKind: criteriaKind,
      previousKinds: previousKinds,
      operation: operation,
      smartFolderID: smartFolder.id
    )

    let criteriaMatch = try smartFolderFilterMutationMatch(
      options: options,
      currentJoinOperator: criteria.joinOperator,
      resultingCriteriaCount: resultingKinds.count
    )
    let requestedIncludeRecentlyDeleted = options.hasTargetFlag("include-recently-deleted")
    try validateSmartFolderBuiltInCriteriaOptions(
      kinds: resultingKinds,
      includeRecentlyDeleted: requestedIncludeRecentlyDeleted
    )
    try validateSmartFolderBuiltInCriteriaMatch(kinds: resultingKinds, match: criteriaMatch.match)
    let includeRecentlyDeleted = effectiveSmartFolderBuiltInCriteriaIncludeRecentlyDeleted(
      kinds: resultingKinds,
      requestedIncludeRecentlyDeleted: requestedIncludeRecentlyDeleted || (criteria.includeRecentlyDeleted ?? false)
    )
    let parameters = try smartFolderFilterMutationParameters(
      mutationKind: mutationKind,
      ordinal: ordinal,
      criteriaKind: criteriaKind,
      previousFilters: criteria.filters,
      resultingKinds: resultingKinds,
      accountName: smartFolder.accountName,
      operation: operation,
      appleCapability: appleCapability,
      smartFolderID: smartFolder.id,
      options: options
    )
    let folderCriteria = resultingKinds.compactMap { parameters.folderCriteriaByKind[$0] }.first
    let updateDraft = NotesSmartFolderBuiltInCriteriaUpdateDraft(
      smartFolderID: smartFolder.id,
      name: smartFolder.name,
      accountName: smartFolder.accountName,
      previousQueryPresent: smartFolder.queryPresent,
      previousQuerySHA256: smartFolder.querySHA256,
      previousVisibleNoteCount: smartFolder.visibleNoteCount,
      criteriaKind: resultingKinds.joined(separator: ","),
      criteriaKinds: resultingKinds,
      criteriaMatch: criteriaMatch.match,
      joinOperator: criteriaMatch.joinOperator,
      includeRecentlyDeleted: includeRecentlyDeleted,
      dateCriteria: parameters.dateCriteria,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: parameters.folderCriteriaByKind,
      participantCriteria: parameters.participantCriteria
    )
    return NotesSmartFolderFilterMutationDraft(
      mutationKind: mutationKind,
      ordinal: ordinal,
      criteriaKind: criteriaKind,
      previousCriteriaKinds: previousKinds,
      resultingCriteriaKinds: resultingKinds,
      updateDraft: updateDraft
    )
  }

  private func smartFolderFilterMutationCriteriaKind(
    mutationKind: String,
    operation: String,
    appleCapability: String,
    smartFolderID: String,
    options: CLIOptions
  ) throws -> String? {
    guard mutationKind != "remove" else {
      try validateSmartFolderFilterRemoveHasNoCriteriaOptions(options)
      return nil
    }
    let kinds = try normalizedSmartFolderBuiltInCriteriaList(try requiredOption("criteria", options: options))
    guard kinds.count == 1, let kind = kinds.first else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder filter mutation accepts exactly one promoted criteria kind.",
        details: [
          "operation": operation,
          "criteria_count": "\(kinds.count)",
        ]
      )
    }
    guard smartFolderBuiltInCriteriaCombinationFilterExpectation(kind: kind) != nil else {
      throw smartFolderFilterMutationReconstructionError(
        operation: operation,
        appleCapability: appleCapability,
        smartFolderID: smartFolderID,
        reason: "criteria_kind_not_representable_as_private_filter_selection"
      )
    }
    return kind
  }

  private func validateSmartFolderFilterRemoveHasNoCriteriaOptions(_ options: CLIOptions) throws {
    let disallowed = [
      "criteria", "match", "tag", "tags", "include-tags", "exclude-tags", "mode",
      "criteria-folder", "include-criteria-folder", "exclude-criteria-folder", "date",
      "start-date", "end-date", "relative-amount", "relative-unit", "participant-user-id",
    ].filter { options.targetOption($0) != nil }
    guard disallowed.isEmpty, !options.hasTargetFlag("include-recently-deleted") else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder filter removal only accepts a target folder and filter ordinal.",
        details: [
          "operation": "notes.smart-folders.filters.remove",
          "unsupported_options": disallowed.map { "--\($0)" }.joined(separator: ","),
          "unsupported_flags": options.hasTargetFlag("include-recently-deleted") ? "--include-recently-deleted" : "",
        ]
      )
    }
  }

  private func smartFolderFilterMutationOrdinal(
    mutationKind: String,
    providedOrdinal: String?,
    previousCount: Int,
    operation: String,
    smartFolderID: String
  ) throws -> Int {
    let ordinal = try providedOrdinal.map { try normalizedPositiveInt($0, option: "ordinal") }
    switch mutationKind {
    case "add":
      let resolved = ordinal ?? (previousCount + 1)
      guard resolved >= 1, resolved <= previousCount + 1 else {
        throw smartFolderFilterMutationOrdinalError(
          operation: operation,
          smartFolderID: smartFolderID,
          ordinal: resolved,
          validRange: "1...\(previousCount + 1)"
        )
      }
      return resolved
    case "update", "remove":
      guard let ordinal else {
        throw CLIError(
          code: .validationError,
          message: "Smart Folder filter \(mutationKind) requires `--ordinal N`.",
          details: ["operation": operation, "required_option": "ordinal"]
        )
      }
      guard ordinal >= 1, ordinal <= previousCount else {
        throw smartFolderFilterMutationOrdinalError(
          operation: operation,
          smartFolderID: smartFolderID,
          ordinal: ordinal,
          validRange: "1...\(previousCount)"
        )
      }
      return ordinal
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Smart Folder filter mutation kind.",
        details: ["operation": operation, "mutation_kind": mutationKind]
      )
    }
  }

  private func smartFolderFilterMutationOrdinalError(
    operation: String,
    smartFolderID: String,
    ordinal: Int,
    validRange: String
  ) -> CLIError {
    CLIError(
      code: .validationError,
      message: "Smart Folder filter ordinal is outside the current filter list.",
      details: [
        "operation": operation,
        "smart_folder_id_sha256": sha256Hex(smartFolderID),
        "ordinal": "\(ordinal)",
        "valid_range": validRange,
      ]
    )
  }

  private func smartFolderFilterMutationResultingKinds(
    mutationKind: String,
    ordinal: Int,
    criteriaKind: String?,
    previousKinds: [String],
    operation: String,
    smartFolderID: String
  ) throws -> [String] {
    var resultingKinds = previousKinds
    let index = ordinal - 1
    switch mutationKind {
    case "add":
      guard let criteriaKind else {
        throw CLIError(code: .validationError, message: "Missing Smart Folder filter criteria.", details: ["operation": operation])
      }
      resultingKinds.insert(criteriaKind, at: index)
    case "update":
      guard let criteriaKind else {
        throw CLIError(code: .validationError, message: "Missing Smart Folder filter criteria.", details: ["operation": operation])
      }
      resultingKinds[index] = criteriaKind
    case "remove":
      resultingKinds.remove(at: index)
    default:
      throw CLIError(code: .validationError, message: "Unsupported Smart Folder filter mutation kind.", details: ["operation": operation])
    }
    guard !resultingKinds.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folders must keep at least one filter.",
        details: [
          "operation": operation,
          "smart_folder_id_sha256": sha256Hex(smartFolderID),
          "apple_product_limit": "empty_filter_smart_folder",
        ]
      )
    }
    guard Set(resultingKinds).count == resultingKinds.count else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder filter mutation would create duplicate criteria kinds.",
        details: [
          "operation": operation,
          "criteria_kinds": resultingKinds.joined(separator: ","),
        ]
      )
    }
    return resultingKinds
  }

  private func smartFolderFilterMutationMatch(
    options: CLIOptions,
    currentJoinOperator: Int?,
    resultingCriteriaCount: Int
  ) throws -> (match: String, joinOperator: Int) {
    if let requested = options.targetOption("match") {
      return try normalizedSmartFolderBuiltInCriteriaMatch(requested)
    }
    guard resultingCriteriaCount > 1 else {
      return ("all", 1)
    }
    if currentJoinOperator == 0 {
      return ("any", 0)
    }
    return ("all", 1)
  }

  private func smartFolderFilterMutationParameters(
    mutationKind: String,
    ordinal: Int,
    criteriaKind: String?,
    previousFilters: [NotesSmartFolderCriteriaFilter],
    resultingKinds: [String],
    accountName: String,
    operation: String,
    appleCapability: String,
    smartFolderID: String,
    options: CLIOptions
  ) throws -> NotesSmartFolderFilterMutationResolvedParameters {
    let newParameters = try criteriaKind.map {
      try smartFolderFilterMutationNewParameters(
        kind: $0,
        accountName: accountName,
        options: options
      )
    }
    var resolved = NotesSmartFolderFilterMutationResolvedParameters()
    for index in resultingKinds.indices {
      let kind = resultingKinds[index]
      let sourceFilter = smartFolderFilterMutationSourceFilter(
        mutationKind: mutationKind,
        ordinal: ordinal,
        previousFilters: previousFilters,
        resultingIndex: index
      )
      let parameters: NotesSmartFolderFilterMutationResolvedParameters
      if sourceFilter == nil, let newParameters {
        parameters = newParameters
      } else if let sourceFilter {
        parameters = try smartFolderFilterMutationExistingParameters(
          kind: kind,
          filter: sourceFilter,
          accountName: accountName,
          operation: operation,
          appleCapability: appleCapability,
          smartFolderID: smartFolderID
        )
      } else {
        parameters = NotesSmartFolderFilterMutationResolvedParameters()
      }
      try mergeSmartFolderFilterMutationParameters(
        parameters,
        into: &resolved,
        operation: operation,
        smartFolderID: smartFolderID
      )
    }
    return resolved
  }

  private func smartFolderFilterMutationSourceFilter(
    mutationKind: String,
    ordinal: Int,
    previousFilters: [NotesSmartFolderCriteriaFilter],
    resultingIndex: Int
  ) -> NotesSmartFolderCriteriaFilter? {
    let mutationIndex = ordinal - 1
    switch mutationKind {
    case "add":
      if resultingIndex == mutationIndex {
        return nil
      }
      return previousFilters[resultingIndex < mutationIndex ? resultingIndex : resultingIndex - 1]
    case "update":
      if resultingIndex == mutationIndex {
        return nil
      }
      return previousFilters[resultingIndex]
    case "remove":
      return previousFilters[resultingIndex < mutationIndex ? resultingIndex : resultingIndex + 1]
    default:
      return nil
    }
  }

  private func smartFolderFilterMutationNewParameters(
    kind: String,
    accountName: String,
    options: CLIOptions
  ) throws -> NotesSmartFolderFilterMutationResolvedParameters {
    let dateCriteria = try smartFolderDateCriteriaParameters(kind: kind, options: options)
    try validateSmartFolderDateCriteriaParameters(kind: kind, dateCriteria: dateCriteria)
    let folderCriteriaByKind = try smartFolderFolderCriteriaParametersByKind(
      kinds: [kind],
      accountName: accountName,
      options: options
    )
    let folderCriteria = folderCriteriaByKind[kind]
    try validateSmartFolderFolderCriteriaParameters(kind: kind, folderCriteria: folderCriteria)
    let participantCriteria = try smartFolderParticipantCriteriaParameters(kind: kind, options: options)
    try validateSmartFolderParticipantCriteriaParameters(kind: kind, participantCriteria: participantCriteria)
    return NotesSmartFolderFilterMutationResolvedParameters(
      dateCriteria: dateCriteria,
      folderCriteriaByKind: folderCriteriaByKind,
      participantCriteria: participantCriteria
    )
  }

  private func smartFolderFilterMutationExistingParameters(
    kind: String,
    filter: NotesSmartFolderCriteriaFilter,
    accountName: String,
    operation: String,
    appleCapability: String,
    smartFolderID: String
  ) throws -> NotesSmartFolderFilterMutationResolvedParameters {
    if let dateCriteria = try smartFolderFilterMutationExistingDateCriteria(
      kind: kind,
      filter: filter,
      operation: operation,
      appleCapability: appleCapability,
      smartFolderID: smartFolderID
    ) {
      return NotesSmartFolderFilterMutationResolvedParameters(dateCriteria: dateCriteria)
    }
    if smartFolderFolderCriteriaInclusionType(kind) != nil {
      let folderCriteria = try smartFolderFilterMutationExistingFolderCriteria(
        kind: kind,
        filter: filter,
        accountName: accountName,
        operation: operation,
        appleCapability: appleCapability,
        smartFolderID: smartFolderID
      )
      return NotesSmartFolderFilterMutationResolvedParameters(folderCriteriaByKind: [kind: folderCriteria])
    }
    if smartFolderParticipantCriteriaKind(kind) {
      throw smartFolderFilterMutationReconstructionError(
        operation: operation,
        appleCapability: appleCapability,
        smartFolderID: smartFolderID,
        reason: "preserved_participant_or_mention_filter_requires_raw_private_user_id"
      )
    }
    return NotesSmartFolderFilterMutationResolvedParameters()
  }

  private func smartFolderFilterMutationExistingDateCriteria(
    kind: String,
    filter: NotesSmartFolderCriteriaFilter,
    operation: String,
    appleCapability: String,
    smartFolderID: String
  ) throws -> NotesSmartFolderDateCriteriaParameters? {
    guard let descriptor = smartFolderDateCriteriaDescriptor(kind) else {
      return nil
    }
    switch descriptor.parameterKind {
    case nil:
      return nil
    case "single_date":
      guard let primaryDate = filter.primaryDate else {
        throw smartFolderFilterMutationReconstructionError(
          operation: operation,
          appleCapability: appleCapability,
          smartFolderID: smartFolderID,
          reason: "preserved_date_filter_missing_primary_date"
        )
      }
      return NotesSmartFolderDateCriteriaParameters(primaryDate: primaryDate)
    case "range":
      guard let primaryDate = filter.primaryDate, let secondaryDate = filter.secondaryDate else {
        throw smartFolderFilterMutationReconstructionError(
          operation: operation,
          appleCapability: appleCapability,
          smartFolderID: smartFolderID,
          reason: "preserved_date_range_filter_missing_bounds"
        )
      }
      return NotesSmartFolderDateCriteriaParameters(primaryDate: primaryDate, secondaryDate: secondaryDate)
    case "relative":
      guard let relativeAmount = filter.relativeRangeAmount,
        let relativeRangeSelectionType = filter.relativeRangeSelectionType
      else {
        throw smartFolderFilterMutationReconstructionError(
          operation: operation,
          appleCapability: appleCapability,
          smartFolderID: smartFolderID,
          reason: "preserved_relative_date_filter_missing_range"
        )
      }
      return NotesSmartFolderDateCriteriaParameters(
        relativeAmount: relativeAmount,
        relativeUnit: smartFolderFilterMutationRelativeUnit(selectionType: relativeRangeSelectionType),
        relativeUnitSelectionType: UInt64(relativeRangeSelectionType)
      )
    default:
      return nil
    }
  }

  private func smartFolderFilterMutationRelativeUnit(selectionType: Int) -> String {
    switch selectionType {
    case 1:
      return "hours"
    case 2:
      return "days"
    case 3:
      return "weeks"
    case 4:
      return "months"
    case 5:
      return "years"
    default:
      return "unknown"
    }
  }

  private func smartFolderFilterMutationExistingFolderCriteria(
    kind: String,
    filter: NotesSmartFolderCriteriaFilter,
    accountName: String,
    operation: String,
    appleCapability: String,
    smartFolderID: String
  ) throws -> NotesSmartFolderFolderCriteriaParameters {
    guard filter.count == nil || filter.count == 1,
      let folderID = filter.folderID,
      !folderID.isEmpty
    else {
      throw smartFolderFilterMutationReconstructionError(
        operation: operation,
        appleCapability: appleCapability,
        smartFolderID: smartFolderID,
        reason: "preserved_folder_filter_requires_single_private_folder_identifier"
      )
    }
    let folder = try folderIdentity(selector: folderID, accountName: accountName)
    try validateSmartFolderFolderCriteriaTarget(folder, accountName: accountName)
    guard let inclusionType = smartFolderFolderCriteriaInclusionType(kind) else {
      throw smartFolderFilterMutationReconstructionError(
        operation: operation,
        appleCapability: appleCapability,
        smartFolderID: smartFolderID,
        reason: "preserved_folder_filter_missing_inclusion_type"
      )
    }
    return NotesSmartFolderFolderCriteriaParameters(
      folderID: folder.id,
      folderName: folder.name,
      folderAccountName: folder.accountName,
      requestedFolder: folder.id,
      inclusionType: inclusionType
    )
  }

  private func mergeSmartFolderFilterMutationParameters(
    _ source: NotesSmartFolderFilterMutationResolvedParameters,
    into target: inout NotesSmartFolderFilterMutationResolvedParameters,
    operation: String,
    smartFolderID: String
  ) throws {
    if let dateCriteria = source.dateCriteria {
      if let existing = target.dateCriteria, existing != dateCriteria {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Smart Folder filter mutation cannot preserve multiple distinct parameterized date filters yet.",
          details: [
            "operation": operation,
            "smart_folder_id_sha256": sha256Hex(smartFolderID),
            "status": "gated",
            "required_verifier": "per_date_filter_parameter_readback",
          ]
        )
      }
      target.dateCriteria = dateCriteria
    }
    for (kind, folderCriteria) in source.folderCriteriaByKind {
      target.folderCriteriaByKind[kind] = folderCriteria
    }
    if let participantCriteria = source.participantCriteria {
      if let existing = target.participantCriteria, existing != participantCriteria {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Smart Folder filter mutation cannot write multiple distinct participant filters in one criteria rewrite yet.",
          details: [
            "operation": operation,
            "smart_folder_id_sha256": sha256Hex(smartFolderID),
            "status": "gated",
            "required_verifier": "per_participant_filter_identity_readback",
          ]
        )
      }
      target.participantCriteria = participantCriteria
    }
  }

  private func smartFolderFilterMutationReconstructionError(
    operation: String,
    appleCapability: String,
    smartFolderID: String,
    reason: String
  ) -> CLIError {
    CLIError(
      code: .unsupportedOperation,
      message: "Notes Smart Folder filter mutation is gated for criteria that cannot be reconstructed from private readback.",
      details: [
        "operation": operation,
        "capability": "smart_folder_promoted_filter_mutation",
        "apple_notes_capability": appleCapability,
        "status": "gated",
        "future_gate": "raw_or_object_bound_filter_reconstruction",
        "required_implementation": "typed_private_notes_framework_filter_selection_reconstruction",
        "required_verifier": "private_per_filter_delta_readback+matching_note_resolution",
        "smart_folder_id_sha256": sha256Hex(smartFolderID),
        "reason": reason,
      ]
    )
  }

  private func smartFolderFolderCriteriaParametersByKind(
    kinds: [String],
    accountName: String,
    options: CLIOptions
  ) throws -> [String: NotesSmartFolderFolderCriteriaParameters] {
    let genericFolderValue = try normalizedOptionalOption("criteria-folder", options: options)
    let includeFolderValue = try normalizedOptionalOption("include-criteria-folder", options: options)
    let excludeFolderValue = try normalizedOptionalOption("exclude-criteria-folder", options: options)
    let folderKinds = kinds.filter { smartFolderFolderCriteriaInclusionType($0) != nil }
    let providedOptionNames = [
      genericFolderValue.map { _ in "criteria-folder" },
      includeFolderValue.map { _ in "include-criteria-folder" },
      excludeFolderValue.map { _ in "exclude-criteria-folder" },
    ].compactMap { $0 }

    guard !folderKinds.isEmpty else {
      guard providedOptionNames.isEmpty else {
        throw CLIError(
          code: .validationError,
          message: "Smart Folder folder criteria options require a folder-based criteria kind.",
          details: [
            "criteria": kinds.joined(separator: ","),
            "options": providedOptionNames.joined(separator: ","),
          ]
        )
      }
      return [:]
    }

    if let includeFolderValue, !folderKinds.contains("folder") {
      throw CLIError(
        code: .validationError,
        message: "`--include-criteria-folder` requires the `folder` criteria kind.",
        details: [
          "criteria": kinds.joined(separator: ","),
          "criteria_folder_sha256": sha256Hex(includeFolderValue),
        ]
      )
    }
    if let excludeFolderValue, !folderKinds.contains("not-folder") {
      throw CLIError(
        code: .validationError,
        message: "`--exclude-criteria-folder` requires the `not-folder` criteria kind.",
        details: [
          "criteria": kinds.joined(separator: ","),
          "criteria_folder_sha256": sha256Hex(excludeFolderValue),
        ]
      )
    }

    guard folderKinds.count == 1 || genericFolderValue == nil else {
      throw CLIError(
        code: .validationError,
        message: "`--criteria-folder` is ambiguous when one command includes both folder and not-folder criteria.",
        details: [
          "criteria": folderKinds.joined(separator: ","),
          "required_options": "include-criteria-folder,exclude-criteria-folder",
        ]
      )
    }

    var criteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:]
    for kind in folderKinds {
      let requestedFolderValue: String?
      switch kind {
      case "folder":
        requestedFolderValue = includeFolderValue ?? genericFolderValue
      case "not-folder":
        requestedFolderValue = excludeFolderValue ?? genericFolderValue
      default:
        requestedFolderValue = genericFolderValue
      }
      guard let requestedFolderValue else {
        let requiredOption =
          folderKinds.count == 1
          ? "criteria-folder"
          : (kind == "folder" ? "include-criteria-folder" : "exclude-criteria-folder")
        throw CLIError(
          code: .validationError,
          message: "Smart Folder folder criteria requires `--criteria-folder FOLDER[,FOLDER...]` or the matching include/exclude folder option.",
          details: [
            "criteria": kind,
            "required_option": requiredOption,
          ]
        )
      }
      criteriaByKind[kind] = try smartFolderFolderCriteriaParameters(
        kind: kind,
        accountName: accountName,
        requestedFolderValue: requestedFolderValue
      )
    }
    return criteriaByKind
  }

  private func smartFolderFolderCriteriaParameters(
    kind: String,
    accountName: String,
    requestedFolderValue: String
  ) throws -> NotesSmartFolderFolderCriteriaParameters {
    let requestedFolders = try normalizedSmartFolderCriteriaFolderSelectors(requestedFolderValue)
    guard let inclusionType = smartFolderFolderCriteriaInclusionType(kind) else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria options require a folder-based criteria kind.",
        details: ["criteria": kind]
      )
    }
    var folders: [NotesFolderRecord] = []
    for requestedFolder in requestedFolders {
      let folder = try folderIdentity(selector: requestedFolder, accountName: accountName)
      try validateSmartFolderFolderCriteriaTarget(folder, accountName: accountName)
      folders.append(folder)
    }
    let duplicateFolderCount = folders.count - Set(folders.map(\.id)).count
    guard duplicateFolderCount == 0 else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria cannot contain duplicate folder targets.",
        details: [
          "criteria_folder_sha256": sha256Hex(requestedFolderValue),
          "duplicate_folder_count": "\(duplicateFolderCount)",
        ]
      )
    }
    guard let firstFolder = folders.first else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria requires at least one folder target.",
        details: ["criteria_folder_sha256": sha256Hex(requestedFolderValue)]
      )
    }
    return NotesSmartFolderFolderCriteriaParameters(
      folderID: firstFolder.id,
      folderName: firstFolder.name,
      folderAccountName: firstFolder.accountName,
      requestedFolder: requestedFolderValue,
      inclusionType: inclusionType,
      folderIDs: folders.map(\.id),
      folderNames: folders.map(\.name),
      requestedFolders: requestedFolders
    )
  }

  private func normalizedSmartFolderCriteriaFolderSelectors(_ raw: String) throws -> [String] {
    let selectors = raw.split(separator: ",", omittingEmptySubsequences: false)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard selectors.allSatisfy({ !$0.isEmpty }) else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria list cannot contain empty folder entries.",
        details: ["criteria_folder_sha256": sha256Hex(raw)]
      )
    }
    guard Set(selectors).count == selectors.count else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder folder criteria list cannot contain duplicate folder entries.",
        details: ["criteria_folder_sha256": sha256Hex(raw)]
      )
    }
    return selectors
  }

  private func smartFolderParticipantCriteriaParameters(
    kind: String,
    options: CLIOptions
  ) throws -> NotesSmartFolderParticipantCriteriaParameters? {
    guard let rawUserID = try normalizedOptionalOption("participant-user-id", options: options) else {
      return nil
    }
    let participantUserID = try normalizedSmartFolderParticipantUserID(rawUserID)
    return NotesSmartFolderParticipantCriteriaParameters(participantUserID: participantUserID)
  }

  private func normalizedSmartFolderParticipantUserID(_ raw: String) throws -> String {
    let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder participant criteria requires a non-empty participant user ID.",
        details: ["participant_user_id_sha256": sha256Hex(value)]
      )
    }
    guard value.count <= 512 else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder participant user ID is too long.",
        details: [
          "participant_user_id_sha256": sha256Hex(value),
          "max_length": "512",
        ]
      )
    }
    guard value.unicodeScalars.allSatisfy({ $0.value != 0 && !CharacterSet.newlines.contains($0) }) else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder participant user ID cannot contain NUL or newline characters.",
        details: ["participant_user_id_sha256": sha256Hex(value)]
      )
    }
    return value
  }

  private func smartFolderDateCriteriaParameters(
    kind: String,
    options: CLIOptions
  ) throws -> NotesSmartFolderDateCriteriaParameters? {
    let date = try normalizedOptionalOption("date", options: options)
    let startDate = try normalizedOptionalOption("start-date", options: options)
    let endDate = try normalizedOptionalOption("end-date", options: options)
    let relativeAmountText = try normalizedOptionalOption("relative-amount", options: options)
    let relativeUnitText = try normalizedOptionalOption("relative-unit", options: options)
    guard
      date != nil || startDate != nil || endDate != nil || relativeAmountText != nil || relativeUnitText != nil
        || smartFolderDateCriteriaDescriptor(kind)?.parameterKind != nil
    else {
      return nil
    }

    switch smartFolderDateCriteriaDescriptor(kind)?.parameterKind {
    case "single_date":
      guard let date else {
        return NotesSmartFolderDateCriteriaParameters(
          startDateText: startDate,
          endDateText: endDate,
          relativeAmount: relativeAmountText.flatMap(Int.init),
          relativeUnit: relativeUnitText
        )
      }
      let parsed = try parseNotesSmartFolderCriteriaDate(date, optionName: "date")
      return NotesSmartFolderDateCriteriaParameters(
        primaryDate: parsed.date,
        dateText: parsed.text,
        startDateText: startDate,
        endDateText: endDate,
        relativeAmount: relativeAmountText.flatMap(Int.init),
        relativeUnit: relativeUnitText
      )
    case "range":
      guard let startDate, let endDate else {
        return NotesSmartFolderDateCriteriaParameters(
          dateText: date,
          startDateText: startDate,
          endDateText: endDate,
          relativeAmount: relativeAmountText.flatMap(Int.init),
          relativeUnit: relativeUnitText
        )
      }
      let parsedStart = try parseNotesSmartFolderCriteriaDate(startDate, optionName: "start-date")
      let parsedEnd = try parseNotesSmartFolderCriteriaDate(endDate, optionName: "end-date")
      return NotesSmartFolderDateCriteriaParameters(
        primaryDate: parsedStart.date,
        secondaryDate: notesSmartFolderCriteriaEndOfDay(parsedEnd.date),
        dateText: date,
        startDateText: parsedStart.text,
        endDateText: parsedEnd.text,
        relativeAmount: relativeAmountText.flatMap(Int.init),
        relativeUnit: relativeUnitText
      )
    case "relative":
      let amount = relativeAmountText.flatMap(Int.init)
      let unit = try relativeUnitText.map(normalizedNotesSmartFolderDateCriteriaUnit)
      return NotesSmartFolderDateCriteriaParameters(
        dateText: date,
        startDateText: startDate,
        endDateText: endDate,
        relativeAmount: amount,
        relativeUnit: unit?.unit,
        relativeUnitSelectionType: unit?.selectionType
      )
    case nil:
      if date != nil || startDate != nil || endDate != nil || relativeAmountText != nil || relativeUnitText != nil {
        return NotesSmartFolderDateCriteriaParameters(
          dateText: date,
          startDateText: startDate,
          endDateText: endDate,
          relativeAmount: relativeAmountText.flatMap(Int.init),
          relativeUnit: relativeUnitText
        )
      }
      return nil
    default:
      return nil
    }
  }

  private func smartFolderDateCriteriaReferenceKind(criteriaKinds: [String], options: CLIOptions) -> String {
    let hasDateOptions =
      options.targetOption("date") != nil || options.targetOption("start-date") != nil
      || options.targetOption("end-date") != nil || options.targetOption("relative-amount") != nil
      || options.targetOption("relative-unit") != nil
    if hasDateOptions,
      let parameterized = criteriaKinds.first(where: { smartFolderDateCriteriaDescriptor($0)?.parameterKind != nil })
    {
      return parameterized
    }
    if let dateKind = criteriaKinds.first(where: { smartFolderDateCriteriaDescriptor($0) != nil }) {
      return dateKind
    }
    return criteriaKinds[0]
  }

  func smartFolderDuplicateDraft(_ options: CLIOptions) throws -> NotesSmartFolderDuplicateDraft {
    let source = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateEditableSmartFolder(source, operation: "duplicated")
    try validateReusableSmartFolderCriteria(source, operation: "duplicated")
    let name = try normalizedOption("name", options: options)
    guard source.name.localizedCaseInsensitiveCompare(name) != .orderedSame else {
      throw CLIError(
        code: .validationError,
        message: "New Notes Smart Folder name must differ from the source name.",
        details: ["smart_folder_id_sha256": sha256Hex(source.id)]
      )
    }
    let accountSmartFolders = try smartFolderReader().listSmartFolders(account: source.accountName, limit: 2_000)
    guard !accountSmartFolders.contains(where: {
      $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
    }) else {
      throw CLIError(
        code: .validationError,
        message: "A Notes Smart Folder with that name already exists in the selected account.",
        details: [
          "name_sha256": sha256Hex(name),
          "account_sha256": sha256Hex(source.accountName),
        ]
      )
    }
    let matchingNotes = try smartFolderReader().listSmartFolderNotes(
      smartFolderID: source.id,
      limit: 2_000
    )
    return NotesSmartFolderDuplicateDraft(
      sourceSmartFolderID: source.id,
      sourceName: source.name,
      name: name,
      accountName: source.accountName,
      sourceQueryPresent: source.queryPresent,
      sourceQuerySHA256: source.querySHA256,
      sourceVisibleNoteCount: source.visibleNoteCount,
      sourceCriteria: source.criteria,
      sourceMatchingNoteCount: matchingNotes.count
    )
  }

  func smartFolderCriteriaCopyDraft(_ options: CLIOptions) throws -> NotesSmartFolderCriteriaCopyDraft {
    let account = options.targetOption("account")
    let source = try smartFolderIdentity(
      selector: try requiredOption("from", options: options),
      account: account
    )
    let target = try smartFolderIdentity(
      selector: try requiredOption("to", options: options),
      account: account
    )
    guard source.id != target.id else {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folder criteria copy requires distinct source and target Smart Folders.",
        details: ["smart_folder_id_sha256": sha256Hex(source.id)]
      )
    }
    guard source.accountName.localizedCaseInsensitiveCompare(target.accountName) == .orderedSame else {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folder criteria copy requires source and target Smart Folders in the same account.",
        details: [
          "source_account_sha256": sha256Hex(source.accountName),
          "target_account_sha256": sha256Hex(target.accountName),
        ]
      )
    }
    try validateReusableSmartFolderCriteria(source, operation: "copied")
    try validateEditableSmartFolder(target, operation: "updated")
    let matchingNotes = try smartFolderReader().listSmartFolderNotes(
      smartFolderID: source.id,
      limit: 2_000
    )
    return NotesSmartFolderCriteriaCopyDraft(
      sourceSmartFolderID: source.id,
      sourceName: source.name,
      targetSmartFolderID: target.id,
      targetName: target.name,
      accountName: target.accountName,
      sourceQueryPresent: source.queryPresent,
      sourceQuerySHA256: source.querySHA256,
      sourceVisibleNoteCount: source.visibleNoteCount,
      sourceCriteria: source.criteria,
      sourceMatchingNoteCount: matchingNotes.count,
      targetPreviousQueryPresent: target.queryPresent,
      targetPreviousQuerySHA256: target.querySHA256,
      targetPreviousVisibleNoteCount: target.visibleNoteCount
    )
  }

  func smartFolderCriteriaImportDraft(_ options: CLIOptions) throws -> NotesSmartFolderCriteriaImportDraft {
    let smartFolder = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateEditableSmartFolder(smartFolder, operation: "updated from imported criteria")
    let sourcePath = standardizedAbsolutePath(try requiredOption("file", options: options))
    let source = try smartFolderCriteriaImportSource(path: sourcePath)
    guard smartFolder.querySHA256 != source.sha256 else {
      throw CLIError(
        code: .validationError,
        message: "Imported Smart Folder criteria matches the target's current criteria.",
        details: [
          "smart_folder_id_sha256": sha256Hex(smartFolder.id),
          "source_sha256": source.sha256,
        ]
      )
    }
    return NotesSmartFolderCriteriaImportDraft(
      smartFolderID: smartFolder.id,
      name: smartFolder.name,
      accountName: smartFolder.accountName,
      previousQueryPresent: smartFolder.queryPresent,
      previousQuerySHA256: smartFolder.querySHA256,
      previousVisibleNoteCount: smartFolder.visibleNoteCount,
      sourcePath: sourcePath,
      queryJSON: source.queryJSON,
      sourceByteCount: source.data.count,
      sourceSHA256: source.sha256
    )
  }

  private func smartFolderCriteriaImportSource(path: String) throws
    -> (queryJSON: String, data: Data, sha256: String)
  {
    let url = URL(fileURLWithPath: path).standardizedFileURL
    guard url.pathExtension.localizedCaseInsensitiveCompare("json") == .orderedSame else {
      throw CLIError(
        code: .validationError,
        message: "`--file` must point to a `.json` Smart Folder criteria artifact.",
        details: ["path_sha256": sha256Hex(url.path)]
      )
    }
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      isDirectory.boolValue == false
    else {
      throw CLIError(
        code: .notFound,
        message: "Smart Folder criteria import file was not found.",
        details: ["path_sha256": sha256Hex(url.path)]
      )
    }
    let data = try Data(contentsOf: url)
    guard !data.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder criteria import file is empty.",
        details: ["path_sha256": sha256Hex(url.path)]
      )
    }
    guard data.count <= 1_000_000 else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder criteria import file is too large.",
        details: ["byte_count": "\(data.count)", "max_byte_count": "1000000"]
      )
    }
    guard let queryJSON = String(data: data, encoding: .utf8),
      queryJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder criteria import file must be UTF-8 JSON.",
        details: ["path_sha256": sha256Hex(url.path)]
      )
    }
    let json: Any
    do {
      json = try JSONSerialization.jsonObject(with: data)
    } catch {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder criteria import file must be valid JSON.",
        details: ["path_sha256": sha256Hex(url.path)]
      )
    }
    guard json is [String: Any] || json is [Any] else {
      throw CLIError(
        code: .validationError,
        message: "Smart Folder criteria import file must contain a JSON object or array.",
        details: ["path_sha256": sha256Hex(url.path)]
      )
    }
    return (queryJSON, data, sha256Hex(data))
  }

  func smartFolderRenameDraft(_ options: CLIOptions) throws -> NotesSmartFolderRenameDraft {
    let smartFolder = try smartFolderIdentity(
      selector: try requiredOption("folder", options: options),
      account: options.targetOption("account")
    )
    try validateEditableSmartFolder(smartFolder, operation: "renamed")
    let name = try normalizedOption("name", options: options)
    guard smartFolder.name.localizedCaseInsensitiveCompare(name) != .orderedSame else {
      throw CLIError(
        code: .validationError,
        message: "New Notes Smart Folder name must differ from the current name.",
        details: ["smart_folder_id_sha256": sha256Hex(smartFolder.id)]
      )
    }
    let accountSmartFolders = try smartFolderReader().listSmartFolders(account: smartFolder.accountName, limit: 2_000)
    guard !accountSmartFolders.contains(where: {
      $0.id != smartFolder.id
        && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
    }) else {
      throw CLIError(
        code: .validationError,
        message: "A Notes Smart Folder with that name already exists in the selected account.",
        details: [
          "name_sha256": sha256Hex(name),
          "account_sha256": sha256Hex(smartFolder.accountName),
        ]
      )
    }
    return NotesSmartFolderRenameDraft(
      smartFolderID: smartFolder.id,
      currentName: smartFolder.name,
      newName: name,
      accountName: smartFolder.accountName,
      queryPresent: smartFolder.queryPresent,
      querySHA256: smartFolder.querySHA256,
      visibleNoteCount: smartFolder.visibleNoteCount
    )
  }

  private func validateSmartFolderFolderCriteriaTarget(
    _ folder: NotesFolderRecord,
    accountName: String
  ) throws {
    if folder.accountName.localizedCaseInsensitiveCompare(accountName) != .orderedSame {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folder folder criteria must target a folder in the selected account.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "account_sha256": sha256Hex(accountName),
        ]
      )
    }
    if folder.isSmartFolder == true || folder.isTrash == true || folder.isSystemFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes Smart Folder folder criteria target must be a concrete visible folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateDeletableSmartFolder(_ folder: NotesSmartFolderRecord) throws {
    if folder.isEditable == false || folder.isDeletable == false {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes Smart Folder cannot be deleted.",
        details: ["smart_folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateEditableSmartFolder(_ folder: NotesSmartFolderRecord, operation: String) throws {
    if folder.isEditable == false {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes Smart Folder cannot be \(operation).",
        details: ["smart_folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateReusableSmartFolderCriteria(_ folder: NotesSmartFolderRecord, operation: String) throws {
    guard folder.queryPresent else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes Smart Folder criteria cannot be \(operation) because no private query was found.",
        details: ["smart_folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    guard let criteria = folder.criteria else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes Smart Folder criteria cannot be \(operation) because no criteria summary was available.",
        details: ["smart_folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    guard criteria.queryKind != "query_json" else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes Smart Folder raw-only criteria reuse remains gated.",
        details: ["smart_folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  func exportSmartFolderCriteria(
    _ source: NotesSmartFolderCriteriaExportSource,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "notes.smart-folders.export-criteria"
    let dataHash = sha256Hex(source.data)
    let summary = smartFolderCriteriaExportSummary(
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
          scope: smartFolderCriteriaExportScopeDigest(source: source, destinationPath: destinationPath),
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
      message: "Notes Smart Folder criteria export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeNotesSmartFolderCriteriaExport(source.data, to: destinationPath)
    let verification = try verifySmartFolderCriteriaExport(
      source: source,
      destinationPath: destinationPath,
      expectedSHA256: dataHash,
      operation: operation
    )
    let result = NotesSmartFolderCriteriaExportResult(
      operation: operation,
      changed: true,
      smartFolder: source.smartFolder,
      destinationPath: destinationPath,
      byteCount: source.data.count,
      sha256: dataHash,
      verification: verification
    )
    guard verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes Smart Folder criteria export verification failed.",
        details: artifactVerificationFailureDetails(operation: operation, verification: verification)
      )
    }
    return try self.result(result, human: "\(operation) executed", options: options)
  }

  private func smartFolderCriteriaExportSummary(
    source: NotesSmartFolderCriteriaExportSource,
    destinationPath: String,
    dataHash: String
  ) -> [String: String] {
    [
      "smart_folder_id": source.smartFolder.id,
      "name": source.smartFolder.name,
      "account": source.smartFolder.accountName,
      "destination_path": destinationPath,
      "byte_count": "\(source.data.count)",
      "sha256": dataHash,
      "query_present": source.smartFolder.queryPresent ? "true" : "false",
    ]
  }

  private func smartFolderCriteriaExportScopeDigest(
    source: NotesSmartFolderCriteriaExportSource,
    destinationPath: String
  ) -> String {
    let fields = [
      source.smartFolder.id,
      source.smartFolder.accountName,
      destinationPath,
      "\(source.data.count)",
      sha256Hex(source.data),
    ].joined(separator: "|")
    return "notes-smart-folder-criteria-export:\(sha256Hex(fields))"
  }

  private func verifySmartFolderCriteriaExport(
    source: NotesSmartFolderCriteriaExportSource,
    destinationPath: String,
    expectedSHA256: String,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
    let exists = FileManager.default.fileExists(atPath: destination.path)
    let fileData = exists ? try Data(contentsOf: destination) : Data()
    let actualSHA256 = sha256Hex(fileData)
    let jsonReadable = (try? JSONSerialization.jsonObject(with: fileData)) != nil
    let readback = try smartFolderReader().listSmartFolders(account: source.smartFolder.accountName, limit: 2_000)
      .first { $0.id == source.smartFolder.id }
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
        name: "json_artifact_readable",
        status: jsonReadable ? "passed" : "failed",
        expectedBool: true,
        actualBool: jsonReadable
      ),
      NotesVerificationCheckRecord(
        name: "smart_folder_readback",
        status: readback != nil ? "passed" : "failed",
        expectedBool: true,
        actualBool: readback != nil
      ),
      NotesVerificationCheckRecord(
        name: "source_query_present",
        status: readback?.queryPresent == true ? "passed" : "failed",
        expectedBool: true,
        actualBool: readback?.queryPresent == true
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_smart_folder_query_json+artifact_hash+smart_folder_readback",
      targetIDSHA256: sha256Hex(source.smartFolder.id),
      checks: checks
    )
  }

  func validateSmartFolderFilterMutationOptions(
    _ options: CLIOptions,
    requiresCriteria: Bool,
    requiresOrdinal: Bool
  ) throws -> Int? {
    try validateTargetOptions(
      options,
      allowedOptions: [
        "folder", "account", "criteria", "ordinal", "match", "tag", "tags", "include-tags",
        "exclude-tags", "mode", "criteria-folder", "include-criteria-folder",
        "exclude-criteria-folder", "date", "start-date", "end-date", "relative-amount",
        "relative-unit", "participant-user-id",
      ],
      allowedFlags: ["include-recently-deleted"]
    )
    _ = try normalizedOption("folder", options: options)
    if requiresCriteria {
      _ = try normalizedOption("criteria", options: options)
    }
    let optionalSelectors = [
      "account", "criteria", "match", "tag", "tags", "include-tags", "exclude-tags", "mode",
      "criteria-folder", "include-criteria-folder", "exclude-criteria-folder", "date",
      "start-date", "end-date", "relative-amount", "relative-unit", "participant-user-id",
    ]
    for selector in optionalSelectors where options.targetOption(selector) != nil {
      _ = try normalizedOptionalOption(selector, options: options)
    }
    if requiresOrdinal || options.targetOption("ordinal") != nil {
      return try normalizedPositiveIntOption("ordinal", options: options)
    }
    return nil
  }

  func smartFolderMutator() throws -> any NotesSmartFolderMutating {
    guard let smartFolderMutator = implementation as? any NotesSmartFolderMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder mutations require a private-framework Smart Folder writer.",
        details: [
          "capability": "smart_folders_mutation",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return smartFolderMutator
  }

  func verifiedSmartFolderMutationResult(_ result: NotesSmartFolderMutationResult) throws
    -> NotesSmartFolderMutationResult
  {
    guard let verification = result.verification, verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes Smart Folder mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification?.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ",") ?? "missing_verification",
          "target_id_sha256": result.verification?.targetIDSHA256
            ?? result.smartFolder.map { sha256Hex($0.id) }
            ?? result.deletedID.map(sha256Hex)
            ?? "",
        ]
      )
    }
    return result
  }
}
