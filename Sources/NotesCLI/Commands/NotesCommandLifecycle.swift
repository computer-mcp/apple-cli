import Foundation
import Utility

extension NotesCommand {
  func runLifecycle(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["notes", "quick-note", "create"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "title", "body"])
      try validateMutationIntent(options)
      let draft = try createDraft(options, isSystemPaper: true)
      return try mutation(
        operation: "notes.quick-note.create",
        scopeDigest: createScopeDigest(draft),
        summary: [
          "folder_id": draft.folderId,
          "folder": draft.folderName,
          "account": draft.accountName,
          "title": draft.title,
          "body_sha256": sha256Hex(draft.body),
          "system_paper": "true",
        ],
        options: options
      ) {
        let note = try implementation.createNote(draft)
        let verification = try mutationVerifier().verifyCreate(
          operation: "notes.quick-note.create",
          draft: draft,
          resultNote: note
        )
        let state = try noteStateReader().readNoteState(noteID: note.id)
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.quick-note.create", changed: true, note: note, state: state,
            deletedID: nil, verification: verification))
      }
    case ["notes", "create"]:
      try validateTargetOptions(options, allowedOptions: ["folder", "title", "body"])
      try validateMutationIntent(options)
      let draft = try createDraft(options)
      return try mutation(
        operation: "notes.create",
        scopeDigest: createScopeDigest(draft),
        summary: [
          "folder_id": draft.folderId,
          "folder": draft.folderName,
          "account": draft.accountName,
          "title": draft.title,
          "body_sha256": sha256Hex(draft.body),
        ],
        options: options
      ) {
        let note = try implementation.createNote(draft)
        let verification = try mutationVerifier().verifyCreate(
          operation: "notes.create",
          draft: draft,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.create", changed: true, note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "update"]:
      try validateTargetOptions(options, allowedOptions: ["id", "title", "body"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let patch = try updatePatch(options)
      return try mutation(
        operation: "notes.update",
        scopeDigest: updateScopeDigest(current: identity.note, patch: patch),
        summary: updateSummary(current: identity.note, patch: patch),
        options: options
      ) {
        let note = try implementation.updateNote(id: identity.note.id, patch: patch)
        let verification = try mutationVerifier().verifyUpdate(
          operation: "notes.update",
          before: identity.note,
          patch: patch,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.update",
            changed: patch.body != nil || !note.title.utf8.elementsEqual(identity.note.title.utf8),
            note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "append"]:
      try validateTargetOptions(options, allowedOptions: ["id", "body"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let patch = try appendPatch(options)
      return try mutation(
        operation: "notes.append",
        scopeDigest: updateScopeDigest(current: identity.note, patch: patch),
        summary: updateSummary(current: identity.note, patch: patch),
        options: options
      ) {
        let note = try implementation.updateNote(id: identity.note.id, patch: patch)
        let verification = try mutationVerifier().verifyUpdate(
          operation: "notes.append",
          before: identity.note,
          patch: patch,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.append", changed: true, note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "move"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let draft = try moveDraft(note: identity.note, options: options)
      return try mutation(
        operation: "notes.move",
        scopeDigest: moveScopeDigest(current: identity.note, draft: draft),
        summary: moveSummary(current: identity.note, draft: draft),
        options: options
      ) {
        let note = try implementation.moveNote(draft)
        let verification = try mutationVerifier().verifyMove(
          operation: "notes.move",
          before: identity.note,
          draft: draft,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.move", changed: true, note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "copy"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      let draft = try copyDraft(note: identity.note, options: options)
      return try mutation(
        operation: "notes.copy",
        scopeDigest: copyScopeDigest(current: identity.note, draft: draft),
        summary: copySummary(current: identity.note, draft: draft),
        options: options
      ) {
        let note = try implementation.copyNote(draft)
        let verification = try mutationVerifier().verifyCopy(
          operation: "notes.copy",
          before: identity.note,
          draft: draft,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.copy", changed: true, note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "restore"]:
      try validateTargetOptions(options, allowedOptions: ["id", "folder"])
      try validateMutationIntent(options)
      let identity = try restoreMutationIdentity(options)
      let draft = try restoreDraft(note: identity.note, options: options)
      return try mutation(
        operation: "notes.restore",
        scopeDigest: restoreScopeDigest(current: identity.note, draft: draft),
        summary: restoreSummary(current: identity.note, draft: draft),
        options: options
      ) {
        let note = try implementation.restoreNote(draft)
        let verification = try mutationVerifier().verifyRestore(
          operation: "notes.restore",
          before: identity.note,
          draft: draft,
          resultNote: note
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.restore", changed: true, note: note, deletedID: nil,
            verification: verification))
      }
    case ["notes", "restore-all"]:
      try validateTargetOptions(options, allowedOptions: ["folder"])
      try validateMutationIntent(options)
      let targetFolder = try folderIdentity(selector: try requiredOption("folder", options: options))
      try validateEditableConcreteFolder(targetFolder)
      let notes = try restoreAllTargets()
      return try mutation(
        operation: "notes.restore-all",
        scopeDigest: restoreAllScopeDigest(notes: notes, targetFolder: targetFolder),
        summary: restoreAllSummary(notes: notes, targetFolder: targetFolder),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection"],
        dryRunNotes: [
          "Execution restores every currently discoverable note in Recently Deleted into the selected folder."
        ]
      ) {
        var restoredIDHashes: [String] = []
        for note in notes {
          _ = try implementation.restoreNote(
            NotesRestoreDraft(
              noteID: note.id,
              folderID: targetFolder.id,
              folderName: targetFolder.name,
              accountName: targetFolder.accountName
            )
          )
          restoredIDHashes.append(sha256Hex(note.id))
        }
        let verification = try mutationVerifier().verifyBulkRestore(
          operation: "notes.restore-all",
          before: notes,
          targetFolderName: targetFolder.name,
          targetAccountName: targetFolder.accountName,
          changed: !restoredIDHashes.isEmpty,
          restoredCount: restoredIDHashes.count
        )
        return try verifiedBulkMutationResult(
          NotesBulkMutationResult(
            operation: "notes.restore-all",
            changed: !restoredIDHashes.isEmpty,
            affectedNoteCount: restoredIDHashes.count,
            restoredIDHashes: restoredIDHashes.sorted(),
            targetFolderName: targetFolder.name,
            targetAccountName: targetFolder.accountName,
            verification: verification
          ))
      }
    case ["notes", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let identity = try noteMutationIdentity(options)
      return try mutation(
        operation: "notes.delete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let changed = try implementation.deleteNote(id: identity.note.id)
        let verification = try mutationVerifier().verifyDelete(
          operation: "notes.delete",
          before: identity.note,
          changed: changed
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.delete", changed: changed, note: nil, deletedID: identity.note.id,
            verification: verification))
      }
    case ["notes", "purge"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let identity = try restoreMutationIdentity(options)
      return try mutation(
        operation: "notes.purge",
        scopeDigest: purgeScopeDigest(current: identity.note),
        summary: purgeSummary(current: identity.note),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection"],
        dryRunNotes: [
          "Execution permanently removes one note that is already in Recently Deleted."
        ]
      ) {
        let changed = try implementation.purgeNote(id: identity.note.id)
        let verification = try mutationVerifier().verifyPurge(
          operation: "notes.purge",
          before: identity.note,
          changed: changed
        )
        return try verifiedMutationResult(
          NotesMutationResult(
            operation: "notes.purge", changed: changed, note: nil, deletedID: identity.note.id,
            verification: verification))
      }
    case ["notes", "empty-trash"]:
      try validateTargetOptions(options, allowedOptions: [])
      try validateMutationIntent(options)
      let notes = try emptyTrashTargets()
      return try mutation(
        operation: "notes.empty-trash",
        scopeDigest: emptyTrashScopeDigest(notes: notes),
        summary: emptyTrashSummary(notes: notes),
        options: options,
        category: .destructiveSelection,
        allowFlags: ["--allow-destructive-selection"],
        dryRunNotes: [
          "Execution permanently removes every currently discoverable note in Recently Deleted."
        ]
      ) {
        var deletedIDHashes: [String] = []
        for note in notes {
          if try implementation.purgeNote(id: note.id) {
            deletedIDHashes.append(sha256Hex(note.id))
          }
        }
        let verification = try mutationVerifier().verifyEmptyTrash(
          operation: "notes.empty-trash",
          before: notes,
          changed: !deletedIDHashes.isEmpty,
          purgedCount: deletedIDHashes.count
        )
        return try verifiedBulkMutationResult(
          NotesBulkMutationResult(
            operation: "notes.empty-trash",
            changed: !deletedIDHashes.isEmpty,
            affectedNoteCount: deletedIDHashes.count,
            deletedIDHashes: deletedIDHashes.sorted(),
            verification: verification
          ))
      }
    case ["notes", "pin"]:
      return try pinMutation(options, targetPinned: true)
    case ["notes", "unpin"]:
      return try pinMutation(options, targetPinned: false)
    case ["notes", "batch", "pin"]:
      return try batchPinMutation(options, targetPinned: true)
    case ["notes", "batch", "unpin"]:
      return try batchPinMutation(options, targetPinned: false)
    case ["notes", "batch", "move"]:
      return try batchMoveMutation(options)
    case ["notes", "batch", "copy"]:
      return try batchCopyMutation(options)
    case ["notes", "batch", "delete"]:
      return try batchDeleteMutation(options)    default:
      return nil
    }
  }

  private func pinMutation(_ options: CLIOptions, targetPinned: Bool) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["id"])
    try validateMutationIntent(options)
    let operation = targetPinned ? "notes.pin" : "notes.unpin"
    let identity = try noteMutationIdentity(options)
    let stateReader = try noteStateReader()
    let beforeState = try stateReader.readNoteState(noteID: identity.note.id)
    let expectedChanged = beforeState.isPinned != targetPinned
    if expectedChanged, beforeState.isPinnable == false {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Note cannot change pin status.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(identity.note.id),
        ]
      )
    }

    return try mutation(
      operation: operation,
      scopeDigest: pinScopeDigest(current: identity.note, targetPinned: targetPinned),
      summary: pinSummary(
        current: identity.note,
        state: beforeState,
        targetPinned: targetPinned
      ),
      options: options
    ) {
      let note =
        expectedChanged
        ? try implementation.setNotePinned(id: identity.note.id, pinned: targetPinned)
        : identity.note
      let verification = try mutationVerifier().verifyPinState(
        operation: operation,
        before: identity.note,
        targetPinned: targetPinned,
        changed: expectedChanged,
        expectedChanged: expectedChanged
      )
      let finalState = try stateReader.readNoteState(noteID: identity.note.id)
      return try verifiedMutationResult(
        NotesMutationResult(
          operation: operation,
          changed: expectedChanged,
          note: note,
          state: finalState,
          verification: verification
        ))
    }
  }

  private func batchMoveMutation(_ options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["ids", "folder"])
    try validateMutationIntent(options)
    let identities = try batchNoteMutationIdentities(options)
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateEditableConcreteFolder(folder)
    let notes = identities.map(\.note)
    let drafts = notes.map {
      NotesMoveDraft(
        noteID: $0.id,
        folderID: folder.id,
        folderName: folder.name,
        accountName: folder.accountName
      )
    }
    let operation = "notes.batch.move"
    return try mutation(
      operation: operation,
      scopeDigest: batchLifecycleScopeDigest(action: "move", notes: notes, target: folder.id),
      summary: batchLifecycleSummary(
        notes: notes,
        action: "move",
        targetFolderName: folder.name,
        targetAccountName: folder.accountName
      ),
      options: options,
      dryRunNotes: [
        "Execution moves every selected visible note to the selected editable folder."
      ]
    ) {
      var movedNotes: [NotesNoteDetail] = []
      for draft in drafts {
        movedNotes.append(try implementation.moveNote(draft))
      }
      let verification = try mutationVerifier().verifyBatchMove(
        operation: operation,
        before: notes,
        targetFolderName: folder.name,
        targetAccountName: folder.accountName,
        changed: !movedNotes.isEmpty,
        movedCount: movedNotes.count
      )
      return try verifiedBulkMutationResult(
        NotesBulkMutationResult(
          operation: operation,
          changed: !movedNotes.isEmpty,
          affectedNoteCount: movedNotes.count,
          affectedIDHashes: notes.map { sha256Hex($0.id) }.sorted(),
          targetFolderName: folder.name,
          targetAccountName: folder.accountName,
          verification: verification
        ))
    }
  }

  private func batchCopyMutation(_ options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["ids", "folder"])
    try validateMutationIntent(options)
    let identities = try batchNoteMutationIdentities(options)
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateEditableConcreteFolder(folder)
    let notes = identities.map(\.note)
    let drafts = try notes.map { note -> NotesCopyDraft in
      guard note.body != nil else {
        throw CLIError(
          code: .permissionDenied,
          message: "Notes batch copy requires readable note content; locked or protected notes remain gated.",
          details: ["id_sha256": sha256Hex(note.id)]
        )
      }
      return NotesCopyDraft(
        noteID: note.id,
        folderID: folder.id,
        folderName: folder.name,
        accountName: folder.accountName
      )
    }
    let operation = "notes.batch.copy"
    return try mutation(
      operation: operation,
      scopeDigest: batchLifecycleScopeDigest(action: "copy", notes: notes, target: folder.id),
      summary: batchLifecycleSummary(
        notes: notes,
        action: "copy",
        targetFolderName: folder.name,
        targetAccountName: folder.accountName
      ),
      options: options,
      dryRunNotes: [
        "Execution copies every selected visible note into the selected editable folder."
      ]
    ) {
      var copiedNotes: [NotesNoteDetail] = []
      for draft in drafts {
        copiedNotes.append(try implementation.copyNote(draft))
      }
      let verification = try mutationVerifier().verifyBatchCopy(
        operation: operation,
        before: notes,
        copiedNotes: copiedNotes,
        targetFolderName: folder.name,
        targetAccountName: folder.accountName,
        changed: !copiedNotes.isEmpty
      )
      return try verifiedBulkMutationResult(
        NotesBulkMutationResult(
          operation: operation,
          changed: !copiedNotes.isEmpty,
          affectedNoteCount: copiedNotes.count,
          affectedIDHashes: notes.map { sha256Hex($0.id) }.sorted(),
          createdIDHashes: copiedNotes.map { sha256Hex($0.id) }.sorted(),
          targetFolderName: folder.name,
          targetAccountName: folder.accountName,
          verification: verification
        ))
    }
  }

  private func batchDeleteMutation(_ options: CLIOptions) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["ids"])
    try validateMutationIntent(options)
    let identities = try batchNoteMutationIdentities(options)
    let notes = identities.map(\.note)
    let operation = "notes.batch.delete"
    return try mutation(
      operation: operation,
      scopeDigest: batchLifecycleScopeDigest(action: "delete", notes: notes),
      summary: batchLifecycleSummary(notes: notes, action: "delete"),
      options: options,
      category: .destructiveSelection,
      allowFlags: ["--allow-destructive-selection"],
      dryRunNotes: [
        "Execution deletes every selected visible note to the provider's normal deleted-note destination."
      ]
    ) {
      var deletedIDHashes: [String] = []
      for identity in identities {
        if try implementation.deleteNote(id: identity.note.id) {
          deletedIDHashes.append(sha256Hex(identity.note.id))
        }
      }
      let verification = try mutationVerifier().verifyBatchDelete(
        operation: operation,
        before: notes,
        changed: !deletedIDHashes.isEmpty,
        deletedCount: deletedIDHashes.count
      )
      return try verifiedBulkMutationResult(
        NotesBulkMutationResult(
          operation: operation,
          changed: !deletedIDHashes.isEmpty,
          affectedNoteCount: deletedIDHashes.count,
          affectedIDHashes: notes.map { sha256Hex($0.id) }.sorted(),
          deletedIDHashes: deletedIDHashes.sorted(),
          verification: verification
        ))
    }
  }

  private func batchPinMutation(_ options: CLIOptions, targetPinned: Bool) throws -> CLICommandResult {
    try validateTargetOptions(options, allowedOptions: ["ids"])
    try validateMutationIntent(options)
    let identities = try batchNoteMutationIdentities(options)
    let notes = identities.map(\.note)
    let stateReader = try noteStateReader()
    let states = try notes.map { try stateReader.readNoteState(noteID: $0.id) }
    let operation = targetPinned ? "notes.batch.pin" : "notes.batch.unpin"
    for (note, state) in zip(notes, states) where state.isPinned != targetPinned && state.isPinnable == false {
      throw CLIError(
        code: .unsupportedOperation,
        message: "One selected note cannot change pin status.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(note.id),
        ]
      )
    }
    let changedCount = states.filter { $0.isPinned != targetPinned }.count
    return try mutation(
      operation: operation,
      scopeDigest: batchLifecycleScopeDigest(
        action: targetPinned ? "pin" : "unpin",
        notes: notes,
        target: String(targetPinned)
      ),
      summary: batchLifecycleSummary(
        notes: notes,
        action: targetPinned ? "pin" : "unpin",
        targetPinned: targetPinned,
        changedCount: changedCount
      ),
      options: options,
      dryRunNotes: [
        "Execution changes the pinned state for each selected visible note whose current state differs."
      ]
    ) {
      for (identity, state) in zip(identities, states) where state.isPinned != targetPinned {
        _ = try implementation.setNotePinned(id: identity.note.id, pinned: targetPinned)
      }
      let verification = try mutationVerifier().verifyBatchPinState(
        operation: operation,
        before: notes,
        targetPinned: targetPinned,
        changed: changedCount > 0,
        changedCount: changedCount
      )
      return try verifiedBulkMutationResult(
        NotesBulkMutationResult(
          operation: operation,
          changed: changedCount > 0,
          affectedNoteCount: notes.count,
          affectedIDHashes: notes.map { sha256Hex($0.id) }.sorted(),
          targetPinned: targetPinned,
          verification: verification
        ))
    }
  }

  private func batchNoteMutationIdentities(_ options: CLIOptions) throws -> [NotesMutationIdentity] {
    try batchNoteIDs(options).map { try noteMutationIdentity(id: $0) }
  }

  private func batchNoteIDs(_ options: CLIOptions) throws -> [String] {
    let raw = try normalizedOption("ids", options: options)
    let ids = raw
      .components(separatedBy: CharacterSet(charactersIn: ",\n"))
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    guard ids.count >= 2 else {
      throw CLIError(
        code: .validationError,
        message: "`--ids` must include at least two comma-separated note IDs.",
        details: ["required_count": "2"]
      )
    }
    var seen = Set<String>()
    for id in ids {
      guard seen.insert(id).inserted else {
        throw CLIError(
          code: .validationError,
          message: "`--ids` must not contain duplicate note IDs.",
          details: ["duplicate_id_sha256": sha256Hex(id)]
        )
      }
    }
    return ids
  }

  private func batchLifecycleScopeDigest(
    action: String,
    notes: [NotesNoteDetail],
    target: String? = nil
  ) -> String {
    let noteScope = notes.map(noteIdentityScopeDigest).sorted().joined(separator: "|")
    let targetScope = target.map { "|\($0)" } ?? ""
    return "notes-batch-\(action):\(sha256Hex(noteScope + targetScope))"
  }

  private func batchLifecycleSummary(
    notes: [NotesNoteDetail],
    action: String,
    targetFolderName: String? = nil,
    targetAccountName: String? = nil,
    targetPinned: Bool? = nil,
    changedCount: Int? = nil
  ) -> [String: String] {
    var summary = [
      "action": action,
      "note_count": "\(notes.count)",
      "note_ids_sha256": sha256Hex(notes.map(\.id).sorted().joined(separator: "|")),
      "body_set_sha256": sha256Hex(notes.map { $0.body ?? "" }.joined(separator: "|")),
    ]
    if let targetFolderName {
      summary["target_folder"] = targetFolderName
    }
    if let targetAccountName {
      summary["target_account"] = targetAccountName
    }
    if let targetPinned {
      summary["target_pinned"] = String(targetPinned)
    }
    if let changedCount {
      summary["changed_note_count"] = "\(changedCount)"
    }
    return summary
  }

  private func createDraft(_ options: CLIOptions, isSystemPaper: Bool = false) throws -> NotesCreateDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    let title = try normalizedOption("title", options: options)
    try notesValidateTitleEdit(title)
    return NotesCreateDraft(
      folderId: folder.id,
      folderName: folder.name,
      accountName: folder.accountName,
      title: title,
      body: options.targetOption("body") ?? "",
      isSystemPaper: isSystemPaper
    )
  }

  func restorableReader() -> any NotesRestorableReading {
    implementation
  }

  private func updatePatch(_ options: CLIOptions) throws -> NotesUpdatePatch {
    let patch = NotesUpdatePatch(
      title: try normalizedOptionalOption("title", options: options),
      body: options.targetOption("body")
    )
    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError, message: "At least one note field must be supplied for update.")
    }
    if let title = patch.title { try notesValidateTitleEdit(title) }
    return patch
  }

  private func appendPatch(_ options: CLIOptions) throws -> NotesUpdatePatch {
    let body = try requiredOption("body", options: options)
    guard !body.isEmpty else {
      throw CLIError(code: .validationError, message: "`--body` must not be empty for append.")
    }
    return NotesUpdatePatch(appendBody: body)
  }

  private func moveDraft(note: NotesNoteDetail, options: CLIOptions) throws -> NotesMoveDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateEditableConcreteFolder(folder)
    return NotesMoveDraft(
      noteID: note.id,
      folderID: folder.id,
      folderName: folder.name,
      accountName: folder.accountName
    )
  }

  private func copyDraft(note: NotesNoteDetail, options: CLIOptions) throws -> NotesCopyDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateEditableConcreteFolder(folder)
    guard note.body != nil else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes copy requires readable note content; locked or protected notes remain gated.",
        details: ["id_sha256": sha256Hex(note.id)]
      )
    }
    return NotesCopyDraft(
      noteID: note.id,
      folderID: folder.id,
      folderName: folder.name,
      accountName: folder.accountName
    )
  }

  private func restoreDraft(note: NotesNoteDetail, options: CLIOptions) throws -> NotesRestoreDraft {
    let folder = try folderIdentity(selector: try requiredOption("folder", options: options))
    try validateEditableConcreteFolder(folder)
    return NotesRestoreDraft(
      noteID: note.id,
      folderID: folder.id,
      folderName: folder.name,
      accountName: folder.accountName
    )
  }

  func noteMutationIdentity(_ options: CLIOptions) throws -> NotesMutationIdentity {
    let id = try requiredOption("id", options: options)
    return try noteMutationIdentity(id: id)
  }

  func noteMutationIdentity(id: String) throws -> NotesMutationIdentity {
    guard let note = try implementation.readNote(id: id) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    return NotesMutationIdentity(
      note: note,
      scopeDigest: noteIdentityScopeDigest(note),
      summaryFields: [
        "id": note.id,
        "title": note.title,
        "folder": note.folderName,
        "account": note.accountName,
        "body_sha256": sha256Hex(note.body ?? ""),
      ]
    )
  }

  private func restoreMutationIdentity(_ options: CLIOptions) throws -> NotesMutationIdentity {
    let id = try requiredOption("id", options: options)
    guard let note = try implementation.readRestorableNote(id: id) else {
      throw CLIError(
        code: .notFound,
        message: "Restorable note was not found.",
        details: ["id_sha256": sha256Hex(id)]
      )
    }

    return NotesMutationIdentity(
      note: note,
      scopeDigest: noteIdentityScopeDigest(note),
      summaryFields: [
        "id": note.id,
        "title": note.title,
        "folder": note.folderName,
        "account": note.accountName,
        "body_sha256": sha256Hex(note.body ?? ""),
      ]
    )
  }

  private func emptyTrashTargets() throws -> [NotesNoteDetail] {
    let limit = 2_001
    let notes = try implementation.listRestorableNotes(limit: limit)
    guard notes.count < limit else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "Notes empty-trash matched more notes than the bounded safety limit.",
        details: [
          "operation": "notes.empty-trash",
          "restorable_note_count_lower_bound": "\(limit)",
          "max_supported": "2000",
        ]
      )
    }
    return notes
  }

  private func restoreAllTargets() throws -> [NotesNoteDetail] {
    let limit = 2_001
    let notes = try implementation.listRestorableNotes(limit: limit)
    guard notes.count < limit else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "Notes restore-all matched more notes than the bounded safety limit.",
        details: [
          "operation": "notes.restore-all",
          "restorable_note_count_lower_bound": "\(limit)",
          "max_supported": "2000",
        ]
      )
    }
    return notes
  }

  func verifiedMutationResult(_ result: NotesMutationResult) throws -> NotesMutationResult {
    guard let verification = result.verification, verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification?.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ",") ?? "missing_verification",
          "target_id_sha256": result.verification?.targetIDSHA256
            ?? result.note.map { sha256Hex($0.id) }
            ?? result.deletedID.map(sha256Hex)
            ?? "",
        ]
      )
    }
    return result
  }

  private func verifiedBulkMutationResult(_ result: NotesBulkMutationResult) throws
    -> NotesBulkMutationResult
  {
    guard let verification = result.verification, verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes bulk mutation verification failed.",
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
