import Foundation
import Utility

extension NotesCommand {
  func runFolders(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["folders", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let folders = try implementation.listFolders(
        account: options.targetOption("account"), limit: try commandLimit(options))
      let incompleteFolders = folderCompletenessWarnings(folders)
      return try result(
        NotesFoldersResponse(folders: folders, incompleteFolders: incompleteFolders),
        human: folders.map { folder in
          [
            folder.id,
            folder.accountName,
            folder.name,
            folder.parentID ?? "",
            folder.depth.map(String.init) ?? "",
            folder.visibleNoteCount.map(String.init) ?? "",
            folder.childFolderCount.map(String.init) ?? "",
          ].joined(separator: "\t")
        }.joined(separator: "\n"),
        options: options
      )
    case ["folders", "move-impact"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["folder", "parent", "account"])
      let draft = try folderMoveDraft(options)
      let impact = try folderMoveImpactReader().readFolderMoveImpact(draft)
      let verification = verifyFolderMoveImpact(impact, draft: draft)
      return try result(
        NotesFolderMoveImpactResponse(
          operation: "notes.folders.move-impact",
          changed: false,
          impact: impact,
          verification: verification
        ),
        human:
          "shared_review: \(impact.requiresSharedPermissionReview), cross_account_fidelity_review: \(impact.requiresCrossAccountFidelityReview), decision_type: \(impact.decisionType), backend_calls: \(impact.backendCalls.joined(separator: ","))",
        options: options
      )
    case ["folders", "workflow", "audit"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try foldersWorkflowAudit(options)
    case ["folders", "create"]:
      try validateTargetOptions(options, allowedOptions: ["name", "account", "parent"])
      try validateMutationIntent(options)
      let draft = try folderCreateDraft(options)
      return try mutation(
        operation: "notes.folders.create",
        scopeDigest: folderCreateScopeDigest(draft),
        summary: folderCreateSummary(draft),
        options: options
      ) {
        let folder = try implementation.createFolder(draft)
        let verification = try mutationVerifier().verifyFolderCreate(
          operation: "notes.folders.create",
          draft: draft,
          resultFolder: folder
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.create",
            changed: true,
            folder: folder,
            verification: verification
          ))
      }
    case ["folders", "rename"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "name"])
      try validateMutationIntent(options)
      let draft = try folderRenameDraft(options)
      return try mutation(
        operation: "notes.folders.rename",
        scopeDigest: folderRenameScopeDigest(draft),
        summary: folderRenameSummary(draft),
        options: options
      ) {
        let folder = try implementation.renameFolder(draft)
        let verification = try mutationVerifier().verifyFolderRename(
          operation: "notes.folders.rename",
          draft: draft,
          resultFolder: folder
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.rename",
            changed: true,
            folder: folder,
            verification: verification
          ))
      }
    case ["folders", "move"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "parent", "account"])
      try validateMutationIntent(options)
      let draft = try folderMoveDraft(options)
      return try mutation(
        operation: "notes.folders.move",
        scopeDigest: folderMoveScopeDigest(draft),
        summary: folderMoveSummary(draft),
        options: options
      ) {
        let folder = try implementation.moveFolder(draft)
        let verification = try mutationVerifier().verifyFolderMove(
          operation: "notes.folders.move",
          draft: draft,
          resultFolder: folder
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.move",
            changed: true,
            folder: folder,
            verification: verification
          ))
      }
    case ["folders", "sort"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "by", "direction"])
      try validateMutationIntent(options)
      let (current, draft) = try folderSortDraft(options)
      let expectedChanged = !folderSortMatches(current, draft: draft)
      return try mutation(
        operation: "notes.folders.sort",
        scopeDigest: folderSortScopeDigest(draft),
        summary: folderSortSummary(draft, current: current),
        options: options
      ) {
        let folder =
          expectedChanged
          ? try implementation.sortFolder(draft)
          : current
        let verification = try mutationVerifier().verifyFolderSort(
          operation: "notes.folders.sort",
          draft: draft,
          before: current,
          resultFolder: folder,
          changed: expectedChanged,
          expectedChanged: expectedChanged
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.sort",
            changed: expectedChanged,
            folder: folder,
            verification: verification
          ))
      }
    case ["folders", "reorder"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "before", "after"])
      try validateMutationIntent(options)
      let (current, draft) = try folderReorderDraft(options)
      let expectedChanged = current.siblingOrderIndex != draft.requestedIndex
      return try mutation(
        operation: "notes.folders.reorder",
        scopeDigest: folderReorderScopeDigest(draft),
        summary: folderReorderSummary(draft, current: current),
        options: options
      ) {
        let folder =
          expectedChanged
          ? try implementation.reorderFolder(draft)
          : current
        let verification = try mutationVerifier().verifyFolderReorder(
          operation: "notes.folders.reorder",
          draft: draft,
          before: current,
          resultFolder: folder,
          changed: expectedChanged,
          expectedChanged: expectedChanged
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.reorder",
            changed: expectedChanged,
            folder: folder,
            verification: verification
          ))
      }
    case ["folders", "date-headers"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "enabled"])
      try validateMutationIntent(options)
      let (current, draft) = try folderDateHeadersDraft(options)
      let expectedChanged = current.isShowingDateHeaders != draft.enabled
      return try mutation(
        operation: "notes.folders.date-headers",
        scopeDigest: folderDateHeadersScopeDigest(draft),
        summary: folderDateHeadersSummary(draft, current: current),
        options: options
      ) {
        let folder =
          expectedChanged
          ? try implementation.setFolderDateHeaders(draft)
          : current
        let verification = try mutationVerifier().verifyFolderDateHeaders(
          operation: "notes.folders.date-headers",
          draft: draft,
          before: current,
          resultFolder: folder,
          changed: expectedChanged,
          expectedChanged: expectedChanged
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.date-headers",
            changed: expectedChanged,
            folder: folder,
            verification: verification
          ))
      }
    case ["folders", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["folder"])
      try validateMutationIntent(options)
      let draft = try folderDeleteDraft(options)
      return try mutation(
        operation: "notes.folders.delete",
        scopeDigest: folderDeleteScopeDigest(draft),
        summary: folderDeleteSummary(draft),
        options: options
      ) {
        let changed = try implementation.deleteFolder(draft)
        let verification = try mutationVerifier().verifyFolderDelete(
          operation: "notes.folders.delete",
          draft: draft,
          changed: changed
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.delete",
            changed: changed,
            deletedID: draft.folderID,
            verification: verification
          ))
      }
    case ["folders", "purge"]:
      try validateTargetOptions(options, allowedOptions: ["folder"])
      try validateMutationIntent(options)
      let draft = try folderPurgeDraft(options)
      return try mutation(
        operation: "notes.folders.purge",
        scopeDigest: folderPurgeScopeDigest(draft),
        summary: folderPurgeSummary(draft),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection"],
        dryRunNotes: [
          "Execution permanently removes one folder that is already purgable."
        ]
      ) {
        let changed = try folderPurgeWriter().purgeFolder(draft)
        let verification = try mutationVerifier().verifyFolderPurge(
          operation: "notes.folders.purge",
          draft: draft,
          changed: changed
        )
        return try verifiedFolderMutationResult(
          NotesFolderMutationResult(
            operation: "notes.folders.purge",
            changed: changed,
            deletedID: draft.folderID,
            verification: verification
          ))
      }    default:
      return nil
    }
  }

  private func folderCreateDraft(_ options: CLIOptions) throws -> NotesFolderCreateDraft {
    let name = try normalizedOption("name", options: options)

    if let parentSelector = options.targetOption("parent") {
      let parent = try folderIdentity(selector: parentSelector)
      try validateCanCreateSubfolder(parent)
      let account = try options.targetOption("account").map(accountIdentity)
      if let account,
        account.name.localizedCaseInsensitiveCompare(parent.accountName) != .orderedSame
      {
        throw CLIError(
          code: .validationError,
          message: "`--account` must match the selected parent folder account.",
          details: [
            "account_sha256": sha256Hex(account.name),
            "parent_account_sha256": sha256Hex(parent.accountName),
          ]
        )
      }
      return NotesFolderCreateDraft(
        name: name,
        accountID: account?.id,
        accountName: parent.accountName,
        parentID: parent.id,
        parentName: parent.name
      )
    }

    let account = try accountIdentity(selector: try requiredOption("account", options: options))
    return NotesFolderCreateDraft(
      name: name,
      accountID: account.id,
      accountName: account.name
    )
  }

  private func folderRenameDraft(_ options: CLIOptions) throws -> NotesFolderRenameDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateRenamableFolder(folder)
    let name = try normalizedOption("name", options: options)
    guard name != folder.name else {
      throw CLIError(
        code: .validationError,
        message: "New Notes folder name must differ from the current name.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    return NotesFolderRenameDraft(
      folderID: folder.id,
      currentName: folder.name,
      accountName: folder.accountName,
      parentID: folder.parentID,
      name: name
    )
  }

  private func folderMoveDraft(_ options: CLIOptions) throws -> NotesFolderMoveDraft {
    let source = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateMovableFolder(source)
    let parentSelector = try normalizedOptionalOption("parent", options: options)
    let accountSelector = try normalizedOptionalOption("account", options: options)
    guard (parentSelector == nil) != (accountSelector == nil) else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder move requires exactly one destination: `--parent` or `--account`."
      )
    }
    let folders = try implementation.listFolders(account: nil, limit: 2_000)
    let descendantIDs = folderDescendantIDs(of: source.id, folders: folders)

    if let accountSelector {
      let account = try accountIdentity(selector: accountSelector)
      let sameAccount = source.accountName.localizedCaseInsensitiveCompare(account.name) == .orderedSame
      guard !(sameAccount && isRootLevelFolder(source)) else {
        throw CLIError(
          code: .validationError,
          message: "Notes folder is already at the selected account root.",
          details: ["folder_id_sha256": sha256Hex(source.id)]
        )
      }
      return NotesFolderMoveDraft(
        folderID: source.id,
        name: source.name,
        accountName: account.name,
        sourceAccountName: source.accountName,
        accountID: account.id,
        currentParentID: source.parentID,
        descendantIDs: descendantIDs
      )
    }

    let parent = try folderIdentity(selector: parentSelector ?? "")
    try validateCanCreateSubfolder(parent)
    guard source.id != parent.id else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder cannot be moved under itself.",
        details: ["folder_id_sha256": sha256Hex(source.id)]
      )
    }
    guard source.parentID != parent.id else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder is already under the selected parent.",
        details: ["folder_id_sha256": sha256Hex(source.id)]
      )
    }
    guard !isFolder(parent.id, descendantOf: source.id, folders: folders) else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder cannot be moved under one of its descendants.",
        details: ["folder_id_sha256": sha256Hex(source.id)]
      )
    }
    return NotesFolderMoveDraft(
      folderID: source.id,
      name: source.name,
      accountName: parent.accountName,
      sourceAccountName: source.accountName,
      currentParentID: source.parentID,
      parentID: parent.id,
      parentName: parent.name,
      descendantIDs: descendantIDs
    )
  }

  private func folderDeleteDraft(_ options: CLIOptions) throws -> NotesFolderDeleteDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateDeletableFolder(folder)
    return NotesFolderDeleteDraft(
      folderID: folder.id,
      name: folder.name,
      accountName: folder.accountName,
      parentID: folder.parentID,
      visibleNoteCount: folder.visibleNoteCount,
      childFolderCount: folder.childFolderCount
    )
  }

  private func folderPurgeDraft(_ options: CLIOptions) throws -> NotesFolderPurgeDraft {
    let folder = try purgableFolderIdentity(selector: try requiredOption("folder", options: options))
    try validatePurgableFolder(folder)
    return NotesFolderPurgeDraft(
      folderID: folder.id,
      name: folder.name,
      accountName: folder.accountName,
      parentID: folder.parentID,
      visibleNoteCount: folder.visibleNoteCount,
      childFolderCount: folder.childFolderCount
    )
  }

  private func folderSortDraft(_ options: CLIOptions) throws -> (NotesFolderRecord, NotesFolderSortDraft) {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateSortableFolder(folder)
    let sortBy = try normalizedFolderSortBy(try normalizedOption("by", options: options))
    let sortOrder = folderSortOrder(sortBy)
    let direction = try normalizedFolderSortDirection(
      try normalizedOptionalOption("direction", options: options),
      sortBy: sortBy
    )
    let sortDirection = folderSortDirection(direction)
    let isDefault = sortBy == "default"
    let sortValue = isDefault ? 0 : sortOrder * 10 + sortDirection
    let isAscending = sortDirection == 0
    let resolvedOrder = isDefault ? 1 : sortOrder
    return (
      folder,
      NotesFolderSortDraft(
        folderID: folder.id,
        name: folder.name,
        accountName: folder.accountName,
        parentID: folder.parentID,
        by: sortBy,
        direction: direction,
        sortOrder: sortOrder,
        sortDirection: sortDirection,
        sortValue: sortValue,
        sortIsDefault: isDefault,
        sortIsAscending: isAscending,
        resolvedSortOrder: resolvedOrder
      )
    )
  }

  private func folderReorderDraft(_ options: CLIOptions) throws -> (NotesFolderRecord, NotesFolderReorderDraft) {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateReorderableFolder(folder)
    let before = try normalizedOptionalOption("before", options: options)
    let after = try normalizedOptionalOption("after", options: options)
    guard (before == nil) != (after == nil) else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder reorder requires exactly one placement option: `--before` or `--after`."
      )
    }
    let placement = before == nil ? "after" : "before"
    let reference = try folderIdentity(selector: before ?? after ?? "")
    try validateReorderableFolder(reference)
    guard reference.id != folder.id else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder reorder reference must be a different folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    guard sameSidebarOrderParent(folder, reference) else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder reorder requires source and reference folders in the same sidebar parent.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "reference_folder_id_sha256": sha256Hex(reference.id),
        ]
      )
    }

    let siblings = try sidebarOrderSiblings(for: folder)
    let siblingIDs = siblings.map(\.id)
    guard let currentIndex = siblingIDs.firstIndex(of: folder.id),
      let referenceIndex = siblingIDs.firstIndex(of: reference.id)
    else {
      throw CLIError(
        code: .validationError,
        message: "Notes folder reorder could not resolve the selected sibling order.",
        details: [
          "folder_id_sha256": sha256Hex(folder.id),
          "reference_folder_id_sha256": sha256Hex(reference.id),
        ]
      )
    }
    var requestedIndex = referenceIndex + (placement == "after" ? 1 : 0)
    if currentIndex < requestedIndex {
      requestedIndex -= 1
    }
    requestedIndex = max(0, min(requestedIndex, max(0, siblings.count - 1)))

    return (
      folder,
      NotesFolderReorderDraft(
        folderID: folder.id,
        name: folder.name,
        accountName: folder.accountName,
        parentID: folder.parentID,
        referenceFolderID: reference.id,
        referenceName: reference.name,
        placement: placement,
        requestedIndex: requestedIndex,
        currentIndex: currentIndex,
        siblingOrderCount: siblings.count
      )
    )
  }

  private func folderDateHeadersDraft(
    _ options: CLIOptions
  ) throws -> (NotesFolderRecord, NotesFolderDateHeadersDraft) {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateDateHeadersFolder(folder)
    let enabled = try normalizedBoolOption("enabled", options: options)
    return (
      folder,
      NotesFolderDateHeadersDraft(
        folderID: folder.id,
        name: folder.name,
        accountName: folder.accountName,
        parentID: folder.parentID,
        enabled: enabled,
        privateValue: notesDateHeadersPrivateValue(enabled: enabled)
      )
    )
  }

  func normalizedFolderSortBy(_ raw: String) throws -> String {
    switch raw.lowercased() {
    case "default":
      return "default"
    case "date-edited", "edited", "modified", "modification-date", "date-modified":
      return "date-edited"
    case "date-created", "created", "creation-date":
      return "date-created"
    case "title", "name":
      return "title"
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes folder sort field.",
        details: ["allowed": "default,date-edited,date-created,title"]
      )
    }
  }

  func normalizedFolderSortDirection(_ raw: String?, sortBy: String) throws -> String {
    if sortBy == "default" {
      guard raw == nil else {
        throw CLIError(
          code: .validationError,
          message: "`--direction` is not accepted when `--by default` is used."
        )
      }
      return "default"
    }

    let value = raw?.lowercased()
    if sortBy == "title" {
      switch value {
      case nil, "ascending", "asc", "a-z":
        return "ascending"
      case "descending", "desc", "z-a":
        return "descending"
      default:
        throw CLIError(
          code: .validationError,
          message: "Title folder sort direction must be `ascending` or `descending`.",
          details: ["allowed": "ascending,descending"]
        )
      }
    }

    switch value {
    case nil, "newest-first", "newest":
      return "newest-first"
    case "oldest-first", "oldest":
      return "oldest-first"
    default:
      throw CLIError(
        code: .validationError,
        message: "Date folder sort direction must be `newest-first` or `oldest-first`.",
        details: ["allowed": "newest-first,oldest-first"]
      )
    }
  }

  func folderSortOrder(_ sortBy: String) -> Int {
    switch sortBy {
    case "date-edited":
      return 1
    case "date-created":
      return 2
    case "title":
      return 3
    default:
      return 0
    }
  }

  func folderSortDirection(_ direction: String) -> Int {
    switch direction {
    case "oldest-first", "descending":
      return 1
    default:
      return 0
    }
  }

  private func folderSortMatches(_ folder: NotesFolderRecord, draft: NotesFolderSortDraft) -> Bool {
    if draft.sortIsDefault {
      return folder.noteSortTypeValue == 0 || folder.customNoteSortIsDefault == true
    }
    if folder.noteSortTypeValue == draft.sortValue {
      return true
    }
    return folder.customNoteSortOrder == draft.sortOrder
      && folder.customNoteSortDirection == draft.sortDirection
  }

  private func sameSidebarOrderParent(_ lhs: NotesFolderRecord, _ rhs: NotesFolderRecord) -> Bool {
    lhs.accountName.localizedCaseInsensitiveCompare(rhs.accountName) == .orderedSame
      && lhs.parentID == rhs.parentID
      && lhs.isRootLevel == rhs.isRootLevel
  }

  private func sidebarOrderSiblings(for folder: NotesFolderRecord) throws -> [NotesFolderRecord] {
    try implementation.listFolders(account: folder.accountName, limit: 2_000)
      .filter {
        $0.accountName.localizedCaseInsensitiveCompare(folder.accountName) == .orderedSame
          && $0.parentID == folder.parentID
          && $0.isRootLevel == folder.isRootLevel
          && $0.isTrash != true
          && $0.isSystemFolder != true
      }
      .enumerated()
      .sorted { lhs, rhs in
        let lhsOrder = lhs.element.siblingOrderIndex ?? lhs.offset
        let rhsOrder = rhs.element.siblingOrderIndex ?? rhs.offset
        if lhsOrder != rhsOrder {
          return lhsOrder < rhsOrder
        }
        return lhs.element.name.localizedStandardCompare(rhs.element.name) == .orderedAscending
      }
      .map(\.element)
  }

  func validateEditableConcreteFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true {
      throw CLIError(
        code: .validationError,
        message: "Notes lifecycle target must be an editable non-trash folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.isSmartFolder == true || folder.isSystemFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes move target must be an editable concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.supportsEditingNotes == false || folder.isSharedReadOnly == true
      || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes move target is read-only.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  func validateCanCreateSubfolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSmartFolder == true || folder.isSystemFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes subfolder parent must be an editable concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.canAddSubfolder == false || folder.supportsEditingNotes == false
      || folder.isSharedReadOnly == true || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes subfolder parent does not allow adding subfolders.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateRenamableFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSmartFolder == true || folder.isSystemFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes folder rename target must be an editable concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.isRenamable == false || folder.supportsEditingNotes == false
      || folder.isSharedReadOnly == true || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder cannot be renamed.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateMovableFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSmartFolder == true || folder.isSystemFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes folder move source must be an editable concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.isMovable == false || folder.supportsEditingNotes == false
      || folder.isSharedReadOnly == true || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder cannot be moved.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateDeletableFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSmartFolder == true || folder.isSystemFolder == true
      || folder.isDefault == true
    {
      throw CLIError(
        code: .validationError,
        message: "Notes folder delete target must be a user-deletable concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.isDeletable == false || folder.supportsEditingNotes == false
      || folder.isSharedReadOnly == true || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder cannot be deleted.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validatePurgableFolder(_ folder: NotesFolderRecord) throws {
    if folder.isPurgable == false || folder.isTrash == true || folder.isSmartFolder == true
      || folder.isSystemFolder == true || folder.isDefault == true
    {
      throw CLIError(
        code: .validationError,
        message: "Notes folder purge target must be an already-deleted purgable concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateSortableFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSystemFolder == true || folder.isSmartFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes folder sort target must be a sortable folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.supportsCustomNoteSortType == false {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes folder does not support folder-specific sort customization.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.supportsEditingNotes == false || folder.isSharedReadOnly == true
      || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder sort target is read-only.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateReorderableFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSystemFolder == true || folder.isSmartFolder == true
      || folder.isDefault == true
    {
      throw CLIError(
        code: .validationError,
        message: "Notes folder reorder target must be a user-visible sidebar folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.supportsEditingNotes == false || folder.isSharedReadOnly == true
      || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder reorder target is read-only.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    guard folder.siblingOrderIndex != nil, folder.siblingOrderCount != nil,
      folder.siblingOrderSHA256?.count == 64
    else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes folder reorder requires private sibling-order readback.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func validateDateHeadersFolder(_ folder: NotesFolderRecord) throws {
    if folder.isTrash == true || folder.isSystemFolder == true || folder.isSmartFolder == true {
      throw CLIError(
        code: .validationError,
        message: "Notes folder date-header target must be a concrete folder.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.supportsDateHeaders == false {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Notes folder does not support folder-specific date-header customization.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
    if folder.supportsEditingNotes == false || folder.isSharedReadOnly == true
      || folder.isSubfolderOfReadOnlyFolder == true
    {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes folder date-header target is read-only.",
        details: ["folder_id_sha256": sha256Hex(folder.id)]
      )
    }
  }

  private func isRootLevelFolder(_ folder: NotesFolderRecord) -> Bool {
    folder.isRootLevel == true || (folder.isRootLevel == nil && (folder.parentID == nil || folder.depth == 0))
  }

  private func isFolder(
    _ candidateID: String,
    descendantOf ancestorID: String,
    folders: [NotesFolderRecord]
  ) -> Bool {
    let parents = Dictionary(uniqueKeysWithValues: folders.map { ($0.id, $0.parentID) })
    var current = parents[candidateID].flatMap { $0 }
    var seen = Set<String>()
    while let parentID = current {
      if parentID == ancestorID {
        return true
      }
      guard seen.insert(parentID).inserted else {
        return false
      }
      current = parents[parentID].flatMap { $0 }
    }
    return false
  }

  private func folderDescendantIDs(of ancestorID: String, folders: [NotesFolderRecord]) -> [String] {
    folders
      .filter { $0.id != ancestorID && isFolder($0.id, descendantOf: ancestorID, folders: folders) }
      .map(\.id)
      .sorted()
  }

  func folderIdentity(selector: String) throws -> NotesFolderRecord {
    let folders = try implementation.listFolders(account: nil, limit: 500)
    if let match = folders.first(where: { $0.id == selector }) {
      return match
    }

    let titleMatches = folders.filter {
      $0.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity, message: "Folder selector matched multiple Notes folders.",
        details: ["folder": selector])
    }

    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound, message: "Folder selector did not match any Notes folder.",
        details: ["folder": selector])
    }
    return match
  }

  private func purgableFolderIdentity(selector: String) throws -> NotesFolderRecord {
    let folders = try folderPurgeReader().listPurgableFolders(account: nil, limit: 500)
    if let match = folders.first(where: { $0.id == selector }) {
      return match
    }

    let titleMatches = folders.filter {
      $0.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Purgable folder selector matched multiple Notes folders.",
        details: ["folder": selector])
    }

    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Folder selector did not match any purgable Notes folder.",
        details: ["folder_sha256": sha256Hex(selector)])
    }
    return match
  }

  func folderIdentity(selector: String, accountName: String) throws -> NotesFolderRecord {
    let folders = try implementation.listFolders(account: accountName, limit: 2_000)
    if let match = folders.first(where: { $0.id == selector }) {
      return match
    }

    let titleMatches = folders.filter {
      $0.name.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Folder selector matched multiple Notes folders in the selected account.",
        details: ["folder": selector]
      )
    }

    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound,
        message: "Folder selector did not match any Notes folder in the selected account.",
        details: ["folder": selector]
      )
    }
    return match
  }

  private func foldersWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.folders.workflow.audit"
    let records = notesFoldersWorkflowAuditRecords()
    let summary = notesFoldersWorkflowAuditSummary(records)
    let verification = verifyFoldersWorkflowAudit(records: records, summary: summary)
    let response = NotesFoldersWorkflowAuditResponse(
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

  private func notesFoldersWorkflowAuditRecords() -> [NotesFoldersWorkflowAuditRecord] {
    struct FoldersWorkflowAuditItem {
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
      FoldersWorkflowAuditItem(
        family: "folder_hierarchy_listing",
        guideSection: "About accounts and folders / Organize folders",
        status: "supported",
        appleCapability: "view_account_folder_hierarchy",
        command: "folders list",
        mechanism: "typed_private_notes_framework_folder_reader",
        requiredImplementation: "ICFolder hierarchy metadata readback",
        requiredVerifier: "private_folder_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "folder_metadata_only_without_note_bodies",
        reason: "`folders list` reads account, parent, depth, type, visible-note count, child count, and capability metadata without reading note bodies."
      ),
      FoldersWorkflowAuditItem(
        family: "system_folder_metadata_accounting",
        guideSection: "About accounts and folders / Automatically created folders",
        status: "supported",
        appleCapability: "account_for_quick_notes_math_notes_shared_all_notes_and_recently_deleted",
        command: "folders list",
        mechanism: "typed_private_notes_framework_system_folder_reader",
        requiredImplementation: "ICFolder system-folder metadata readback",
        requiredVerifier: "private_system_folder_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "system_folder_names_and_capability_flags_only",
        reason: "System folders are listed as read-only metadata and capability flags instead of being treated as editable user folders."
      ),
      FoldersWorkflowAuditItem(
        family: "concrete_folder_create",
        guideSection: "Add and remove folders / Create a folder",
        status: "supported",
        appleCapability: "create_folder",
        command: "folders create --name NAME --account ACCOUNT",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolder create under account root",
        requiredVerifier: "notes_folder_mutation_v1+folder_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "folder_selector_metadata_without_note_content",
        reason: "Creating one concrete root folder is accepted with dry-run output and private folder readback."
      ),
      FoldersWorkflowAuditItem(
        family: "subfolder_create",
        guideSection: "Add and remove folders / Create a folder",
        status: "supported",
        appleCapability: "create_subfolder",
        command: "folders create --name NAME --parent FOLDER",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolder create under editable parent",
        requiredVerifier: "notes_folder_mutation_v1+parent_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "parent_selector_metadata_without_note_content",
        reason: "Creating one concrete subfolder under an editable parent is accepted with parent placement verification."
      ),
      FoldersWorkflowAuditItem(
        family: "folder_rename",
        guideSection: "Add and remove folders / Rename or move a folder",
        status: "supported",
        appleCapability: "rename_folder",
        command: "folders rename --folder FOLDER --name NAME",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolder title mutation",
        requiredVerifier: "notes_folder_mutation_v1+identity_preservation",
        safetyGate: "DryRun payload",
        privacyBoundary: "folder_identity_hash_and_new_name_only",
        reason: "Renaming one editable concrete folder is accepted with identity-preserving private readback."
      ),
      FoldersWorkflowAuditItem(
        family: "folder_parent_move",
        guideSection: "Add and remove folders / Rename or move a folder",
        status: "supported",
        appleCapability: "move_folder_to_parent_or_account_root",
        command: "folders move --folder FOLDER --parent PARENT; folders move --folder FOLDER --account ACCOUNT",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolder parent/account placement mutation",
        requiredVerifier: "notes_folder_mutation_v1+placement_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "folder_and_account_metadata_without_note_bodies",
        reason: "Moving one editable concrete folder under an editable parent or account root is accepted with placement and bounded descendant account readback."
      ),
      FoldersWorkflowAuditItem(
        family: "note_move_to_folder",
        guideSection: "Add and remove folders / Move or copy notes",
        status: "supported",
        appleCapability: "move_note_to_folder",
        command: "move --id NOTE_ID --folder FOLDER",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "ICNote folder/account placement mutation",
        requiredVerifier: "notes_mutation_v1+note_folder_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "note_identity_and_folder_metadata_without_note_body",
        reason: "Moving one selected visible note to a concrete folder is accepted with private note placement readback."
      ),
      FoldersWorkflowAuditItem(
        family: "note_copy_to_folder",
        guideSection: "Add and remove folders / Move or copy notes",
        status: "supported",
        appleCapability: "copy_note_to_folder",
        command: "copy --id NOTE_ID --folder FOLDER",
        mechanism: "typed_private_notes_framework_note_writer",
        requiredImplementation: "ICNote copy/create in target folder",
        requiredVerifier: "notes_mutation_v1+copied_note_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "source_target_identity_hashes_without_note_body",
        reason: "Copying one selected visible note to a concrete folder is accepted with copied-note readback and privacy-safe identity evidence."
      ),
      FoldersWorkflowAuditItem(
        family: "folder_delete_recently_deleted",
        guideSection: "Add and remove folders / Delete a folder",
        status: "supported",
        appleCapability: "delete_folder_to_recently_deleted",
        command: "folders delete --folder FOLDER",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolder delete with Notes Recently Deleted semantics",
        requiredVerifier: "notes_folder_mutation_v1+visible_absence_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "folder_identity_hash_without_note_body_output",
        reason: "Deleting one user-deletable concrete folder is accepted through Notes' Recently Deleted semantics."
      ),
      FoldersWorkflowAuditItem(
        family: "folder_sort_per_folder",
        guideSection: "About accounts and folders / Sort notes in a folder",
        status: "supported",
        appleCapability: "change_folder_specific_note_sort",
        command: "folders sort --folder FOLDER --by FIELD [--direction DIRECTION]",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolderCustomNoteSortType mutation",
        requiredVerifier: "notes_folder_mutation_v1+sort_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "sort_metadata_without_note_bodies",
        reason: "Changing one folder's custom note sort is accepted when the folder advertises custom sort support."
      ),
      FoldersWorkflowAuditItem(
        family: "deleted_folder_hard_purge",
        guideSection: "Add and remove folders / Delete a folder",
        status: "supported",
        appleCapability: "permanently_delete_already_deleted_folder",
        command: "folders purge --folder FOLDER --allow-destructive-selection",
        mechanism: "typed_private_notes_framework_folder_writer",
        requiredImplementation: "ICFolder.purgableFoldersFetchRequest plus ICFolder.purgeFolder",
        requiredVerifier: "notes_folder_mutation_v1+visible_and_purgable_absence_readback",
        safetyGate: "--allow-destructive-selection",
        privacyBoundary: "deleted_folder_identity_hash_without_note_content",
        reason: "Hard purge is accepted only for already-deleted purgable concrete folders behind destructive-selection approval."
      ),
      FoldersWorkflowAuditItem(
        family: "sidebar_show_hide_ui",
        guideSection: "Add and remove folders / Show accounts and folders",
        status: "delegated",
        appleCapability: "show_or_hide_folder_sidebar",
        command: "Notes.app View > Show Folders",
        mechanism: "delegated_notes_app_window_ui",
        requiredImplementation: "Notes.app sidebar UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Showing or hiding the folders sidebar is a Notes.app window preference, not a persisted Notes model mutation owned by the CLI."
      ),
      FoldersWorkflowAuditItem(
        family: "account_folder_disclosure_ui",
        guideSection: "Add and remove folders / Show accounts and folders",
        status: "delegated",
        appleCapability: "expand_or_collapse_account_folder_list",
        command: "Notes.app account Show/Hide disclosure",
        mechanism: "delegated_notes_app_sidebar_ui",
        requiredImplementation: "Notes.app sidebar disclosure state",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Account disclosure controls are local sidebar UI state; CLI folder reads expose hierarchy directly."
      ),
      FoldersWorkflowAuditItem(
        family: "sidebar_resize_ui",
        guideSection: "Add and remove folders / Show accounts and folders",
        status: "delegated",
        appleCapability: "resize_folder_sidebar",
        command: "Notes.app sidebar drag resize",
        mechanism: "delegated_notes_app_window_ui",
        requiredImplementation: "Notes.app window layout state",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Sidebar sizing is window/UI behavior and has no Notes data-model effect for the CLI to implement."
      ),
      FoldersWorkflowAuditItem(
        family: "file_menu_folder_creation_ui",
        guideSection: "Add and remove folders / Create a folder",
        status: "delegated",
        appleCapability: "create_folder_from_file_menu",
        command: "Notes.app File > New Folder",
        mechanism: "delegated_notes_app_menu_ui",
        requiredImplementation: "Notes.app File menu UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The File menu route is UI affordance coverage; the semantic CLI create command owns the data operation."
      ),
      FoldersWorkflowAuditItem(
        family: "folder_contextual_more_button_ui",
        guideSection: "Add and remove folders / Rename or move a folder",
        status: "delegated",
        appleCapability: "open_folder_more_menu",
        command: "Notes.app folder More/context menu",
        mechanism: "delegated_notes_app_context_menu_ui",
        requiredImplementation: "Notes.app contextual menu UI",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Context menus are Notes.app UI routes; CLI implements the underlying semantic operations directly."
      ),
      FoldersWorkflowAuditItem(
        family: "drag_and_drop_note_folder_ui",
        guideSection: "Add and remove folders / Move or copy notes",
        status: "delegated",
        appleCapability: "drag_notes_or_folders_in_sidebar",
        command: "Notes.app drag-and-drop",
        mechanism: "delegated_notes_app_drag_drop_ui",
        requiredImplementation: "Notes.app drag-and-drop interaction",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Drag-and-drop is an interaction route; CLI exposes explicit move/copy/folder move commands instead."
      ),
      FoldersWorkflowAuditItem(
        family: "shared_folder_move_permission_delta",
        guideSection: "Add and remove folders / Rename or move a folder",
        status: "supported",
        appleCapability: "move_shared_folder_with_permission_change_warning",
        command: "folders move-impact --folder FOLDER --parent PARENT|--account ACCOUNT; folders move --folder FOLDER ...",
        mechanism: "typed_private_notes_framework_move_decision_preflight",
        requiredImplementation: "ICMoveDecision shared-object and destination-account impact readback",
        requiredVerifier: "private_move_decision+shared_permission_review_flag",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_counts_booleans_without_names_participants_note_bodies_or_object_uris",
        reason: "Shared-folder move impact is supported as a read-only private preflight: `folders move-impact` reports whether Notes' private move decision requires shared-permission review without printing participant identifiers or note content."
      ),
      FoldersWorkflowAuditItem(
        family: "custom_sidebar_folder_order",
        guideSection: "About accounts and folders / Organize folders",
        status: "supported",
        appleCapability: "manually_reorder_user_folders",
        command: "folders reorder --folder FOLDER --before|--after SIBLING",
        mechanism: "typed_private_notes_framework_sidebar_order_writer",
        requiredImplementation: "ICNoteContainer.subFolderIdentifiersOrderedSet+ICCRTombstoneOrderedSet.safeMoveObjectFromIndex:toIndex:",
        requiredVerifier: "private_folder_order_readback",
        safetyGate: "DryRun payload",
        privacyBoundary: "folder_order_metadata_only",
        reason: "Manual sidebar order is supported through private sibling-order readback, ordered-set move mutation, and hash-only order verification."
      ),
      FoldersWorkflowAuditItem(
        family: "cross_account_format_attachment_preservation",
        guideSection: "About accounts and folders / Move notes or folders between accounts",
        status: "supported",
        appleCapability: "preserve_formatting_and_attachments_when_moving_between_accounts",
        command: "folders move-impact --folder FOLDER --account ACCOUNT; move/copy/folders move with readback",
        mechanism: "typed_private_notes_framework_move_decision_preflight_plus_existing_move_readback",
        requiredImplementation: "ICMoveDecision cross-account, locked-object, unsupported-object, and attachment-risk readback",
        requiredVerifier: "private_move_decision+hash_only_fidelity_risk_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_counts_booleans_without_names_note_bodies_attachment_bytes_or_object_uris",
        reason: "Apple documents cross-account formatting and attachment loss as a risk rather than a guaranteed preservation capability. The CLI now supports private preflight risk accounting through `folders move-impact` and keeps existing move/copy readback separate from any unsupported fidelity guarantee."
      ),
      FoldersWorkflowAuditItem(
        family: "auto_created_folder_mutations",
        guideSection: "About accounts and folders / Automatically created folders",
        status: "rejected",
        appleCapability: "rename_delete_move_or_share_auto_created_folders",
        command: "none",
        mechanism: "apple_product_system_folder_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "system_folder_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that automatically created folders cannot be renamed, deleted, moved, or shared."
      ),
      FoldersWorkflowAuditItem(
        family: "subfolder_under_all_or_notes",
        guideSection: "Add and remove folders / Create a folder",
        status: "rejected",
        appleCapability: "create_subfolder_under_all_account_or_notes",
        command: "none",
        mechanism: "apple_product_folder_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "folder_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that users cannot add subfolders to All [account] or Notes."
      ),
      FoldersWorkflowAuditItem(
        family: "move_notes_to_all_account_folder",
        guideSection: "Add and remove folders / Move or copy notes",
        status: "rejected",
        appleCapability: "move_notes_to_all_account_folder",
        command: "none",
        mechanism: "apple_product_folder_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "folder_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that notes cannot be moved to All [account]."
      ),
      FoldersWorkflowAuditItem(
        family: "recently_deleted_unavailable_for_unsupported_accounts",
        guideSection: "About accounts and folders / Recently Deleted",
        status: "rejected",
        appleCapability: "recently_deleted_for_every_account_type",
        command: "none",
        mechanism: "apple_product_provider_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "provider_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that Recently Deleted may be absent for some non-upgraded iCloud or non-iCloud accounts."
      ),
      FoldersWorkflowAuditItem(
        family: "shared_note_cross_account_move",
        guideSection: "About accounts and folders / Move notes or folders between accounts",
        status: "rejected",
        appleCapability: "move_shared_icloud_notes_to_other_accounts",
        command: "none",
        mechanism: "apple_product_collaboration_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "collaboration_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents that shared iCloud notes can only be moved or copied within the same iCloud account."
      ),
      FoldersWorkflowAuditItem(
        family: "locked_note_unpermitted_account_move",
        guideSection: "About accounts and folders / Move notes or folders between accounts",
        status: "rejected",
        appleCapability: "move_locked_notes_to_any_account",
        command: "none",
        mechanism: "apple_product_lock_limitation",
        requiredImplementation: "not_applicable",
        requiredVerifier: "locked_note_limitation_accounting",
        safetyGate: nil,
        privacyBoundary: "no_backend_calls",
        reason: "Apple limits locked-note moves or copies to iCloud and On My Mac folders, with authentication constraints."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesFoldersWorkflowAuditRecord(
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

  private func notesFoldersWorkflowAuditSummary(
    _ records: [NotesFoldersWorkflowAuditRecord]
  ) -> NotesFoldersWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesFoldersWorkflowAuditSummary(
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

  private func verifyFoldersWorkflowAudit(
    records: [NotesFoldersWorkflowAuditRecord],
    summary: NotesFoldersWorkflowAuditSummary
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
        name: "official_folder_sections_accounted",
        expected: true,
        actual: guideSectionSet.contains("About accounts and folders")
          && guideSectionSet.contains("Add and remove folders")
          && guideSectionSet.contains("Create a folder")
          && guideSectionSet.contains("Rename or move a folder")
          && guideSectionSet.contains("Move or copy notes")
          && guideSectionSet.contains("Delete a folder")
      ),
      verificationBoolCheck(
        name: "private_folder_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "folder_hierarchy_listing", "system_folder_metadata_accounting",
            "concrete_folder_create", "subfolder_create", "folder_rename",
            "folder_parent_move", "note_move_to_folder", "note_copy_to_folder",
            "folder_delete_recently_deleted", "folder_sort_per_folder",
            "deleted_folder_hard_purge", "custom_sidebar_folder_order",
            "shared_folder_move_permission_delta", "cross_account_format_attachment_preservation",
          ]
        )
      ),
      verificationBoolCheck(
        name: "folder_ui_workflows_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "sidebar_show_hide_ui", "account_folder_disclosure_ui", "sidebar_resize_ui",
            "file_menu_folder_creation_ui", "folder_contextual_more_button_ui",
            "drag_and_drop_note_folder_ui",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_folder_semantics_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "folder_product_limitations_rejected",
        expected: true,
        actual: rejected.isSuperset(
          of: [
            "auto_created_folder_mutations", "subfolder_under_all_or_notes",
            "move_notes_to_all_account_folder",
            "recently_deleted_unavailable_for_unsupported_accounts",
            "shared_note_cross_account_move", "locked_note_unpermitted_account_move",
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
      operation: "notes.folders.workflow.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.folders.workflow.audit"),
      checks: checks
    )
  }

  private func verifyFolderMoveImpact(
    _ impact: NotesFolderMoveImpactRecord,
    draft: NotesFolderMoveDraft
  ) -> NotesMutationVerificationReport {
    let expectedCrossAccount =
      draft.sourceAccountName.localizedCaseInsensitiveCompare(draft.accountName) != .orderedSame
    let expectedSharedReview = impact.hasSharedObjectsNotFromDestinationAccount
      || impact.sharedObjectCount > 0
      || impact.sharedObjectNotFromDestinationFolderCount > 0
      || impact.ownedSharedRootObjectCount > 0
      || impact.joinedSharedRootObjectCount > 0
      || impact.readWriteSharedSubObjectCount > 0
      || impact.readOnlySharedSubObjectCount > 0
    let expectedFidelityReview = expectedCrossAccount
      || impact.hasLockedNotesNotFromDestinationAccount
      || impact.privateModernNoteWithAttachmentsCount > 0
      || impact.unsupportedObjectCount > 0
    let checks = [
      verificationBoolCheck(
        name: "source_folder_hash_matches",
        expected: true,
        actual: impact.sourceFolderIDSHA256 == sha256Hex(draft.folderID)
      ),
      verificationBoolCheck(
        name: "source_account_hash_matches",
        expected: true,
        actual: impact.sourceAccountSHA256 == sha256Hex(draft.sourceAccountName)
      ),
      verificationBoolCheck(
        name: "destination_account_hash_matches",
        expected: true,
        actual: impact.destinationAccountSHA256 == sha256Hex(draft.accountName)
      ),
      verificationBoolCheck(
        name: "cross_account_flag_matches",
        expected: expectedCrossAccount,
        actual: impact.crossAccountMove
      ),
      verificationBoolCheck(
        name: "private_move_decision_called",
        expected: true,
        actual: impact.sourceKind == "ICMoveDecision.initWithSourceObjects:destination:"
          && impact.backendCalls.contains("ICMoveDecision.initWithSourceObjects:destination:")
      ),
      verificationBoolCheck(
        name: "source_object_set_hashed",
        expected: true,
        actual: impact.sourceObjectSetSHA256.isEmpty == false
      ),
      verificationBoolCheck(
        name: "shared_permission_review_semantics",
        expected: expectedSharedReview,
        actual: impact.requiresSharedPermissionReview
      ),
      verificationBoolCheck(
        name: "cross_account_fidelity_review_semantics",
        expected: expectedFidelityReview,
        actual: impact.requiresCrossAccountFidelityReview
      ),
      verificationBoolCheck(
        name: "privacy_boundary_recorded",
        expected: true,
        actual: impact.privacyBoundary.contains("without_names")
          && impact.privacyBoundary.contains("object_uris")
      ),
    ]
    var warnings: [String] = []
    if impact.requiresSharedPermissionReview {
      warnings.append("shared_permission_review_required")
    }
    if impact.requiresCrossAccountFidelityReview {
      warnings.append("cross_account_fidelity_review_required")
    }
    return NotesMutationVerificationReport(
      verifier: "notes_folder_move_impact_v1",
      operation: "notes.folders.move-impact",
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_move_decision+hash_only_permission_and_fidelity_risk_accounting",
      targetIDSHA256: impact.sourceFolderIDSHA256,
      checks: checks,
      warnings: warnings
    )
  }

  func folderPurgeReader() throws -> any NotesFolderPurgeReading {
    guard let reader = implementation as? any NotesFolderPurgeReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes folder purge requires a private-framework purgable folder reader.",
        details: [
          "capability": "folder_purge",
          "required_module": "NotesShared",
        ]
      )
    }
    return reader
  }

  private func folderMoveImpactReader() throws -> any NotesFolderMoveImpactReading {
    guard let reader = implementation as? any NotesFolderMoveImpactReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes folder move impact requires a private-framework move decision reader.",
        details: [
          "capability": "folder_move_impact",
          "required_module": "NotesUI.ICMoveDecision",
        ]
      )
    }
    return reader
  }

  private func folderPurgeWriter() throws -> any NotesFolderPurging {
    guard let writer = implementation as? any NotesFolderPurging else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes folder purge requires a private-framework folder purge writer.",
        details: [
          "capability": "folder_purge",
          "required_module": "NotesShared",
        ]
      )
    }
    return writer
  }

  private func verifiedFolderMutationResult(_ result: NotesFolderMutationResult) throws
    -> NotesFolderMutationResult
  {
    guard let verification = result.verification, verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes folder mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification?.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ",") ?? "missing_verification",
          "target_id_sha256": result.verification?.targetIDSHA256
            ?? result.folder.map { sha256Hex($0.id) }
            ?? result.deletedID.map(sha256Hex)
            ?? "",
        ]
      )
    }
    return result
  }

  private func folderCompletenessWarnings(_ folders: [NotesFolderRecord])
    -> [NotesFolderCompletenessWarning]
  {
    let directChildCounts = Dictionary(grouping: folders.compactMap { folder -> String? in
      guard let parentID = folder.parentID else {
        return nil
      }
      return parentID
    }, by: { $0 }).mapValues(\.count)

    return folders.compactMap { folder in
      guard let expected = folder.childFolderCount else {
        return nil
      }
      let returned = directChildCounts[folder.id] ?? 0
      guard expected != returned else {
        return nil
      }
      return NotesFolderCompletenessWarning(
        folderID: folder.id,
        expectedChildFolderCount: expected,
        returnedChildFolderCount: returned
      )
    }
  }
}
