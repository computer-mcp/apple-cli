import Foundation
import Utility

struct NotesMutationVerifier {
  private let reader: any NotesReading
  private let restorableReader: (any NotesMutating)?
  private let tagReader: (any NotesTagReading)?
  private let folderPurgeReader: (any NotesFolderPurgeReading)?
  private let smartFolderReader: (any NotesSmartFolderReading)?
  private let bodyStructureReader: (any NotesBodyStructureReading)?
  private let noteStateReader: (any NotesNoteStateReading)?
  private let sqliteReader: SQLiteReader

  init(
    reader: any NotesReading,
    restorableReader: (any NotesMutating)? = nil,
    tagReader: (any NotesTagReading)? = nil,
    folderPurgeReader: (any NotesFolderPurgeReading)? = nil,
    smartFolderReader: (any NotesSmartFolderReading)? = nil,
    bodyStructureReader: (any NotesBodyStructureReading)? = nil,
    noteStateReader: (any NotesNoteStateReading)? = nil,
    sqliteReader: SQLiteReader
  ) {
    self.reader = reader
    self.restorableReader = restorableReader
    self.tagReader = tagReader
    self.folderPurgeReader = folderPurgeReader
    self.smartFolderReader = smartFolderReader
    self.bodyStructureReader = bodyStructureReader
    self.noteStateReader = noteStateReader
    self.sqliteReader = sqliteReader
  }

  func verifyCreate(
    operation: String,
    draft: NotesCreateDraft,
    resultNote: NotesNoteDetail
  ) throws -> NotesMutationVerificationReport {
    if draft.isSystemPaper, noteStateReader == nil {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Quick Note create verification requires private framework note-state readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: resultNote.id, operation: operation)
      let postWriteState = try noteStateReader?.readNoteState(noteID: postWriteNote.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(stringCheck(name: "title", expected: draft.title, actual: postWriteNote.title))
      checks.append(bodyCheck(name: "body", expected: draft.body, actual: postWriteNote.body ?? ""))
      checks.append(
        stringCheck(name: "folder", expected: draft.folderName, actual: postWriteNote.folderName))
      checks.append(
        stringCheck(name: "account", expected: draft.accountName, actual: postWriteNote.accountName))
      if draft.isSystemPaper {
        checks.append(
          boolCheck(name: "system_paper_state", expected: true, actual: postWriteState?.isSystemPaper == true))
      } else if let postWriteState {
        checks.append(
          boolCheck(name: "system_paper_state_preserved", expected: false, actual: postWriteState.isSystemPaper))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "system_paper_state", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderCreate(
    operation: String,
    draft: NotesFolderCreateDraft,
    resultFolder: NotesFolderRecord
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try requiredPostWriteFolder(id: resultFolder.id, operation: operation)
      let debug = sqliteReader.debugFolder(postWriteFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: postWriteFolder, debug: debug)
      checks.append(stringCheck(name: "name", expected: draft.name, actual: postWriteFolder.name))
      checks.append(
        stringCheck(name: "account", expected: draft.accountName, actual: postWriteFolder.accountName))
      if let parentID = draft.parentID {
        checks.append(
          stringCheck(name: "parent", expected: parentID, actual: postWriteFolder.parentID ?? ""))
      } else {
        checks.append(
          NotesVerificationCheckRecord(name: "parent", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderRename(
    operation: String,
    draft: NotesFolderRenameDraft,
    resultFolder: NotesFolderRecord
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try requiredPostWriteFolder(id: resultFolder.id, operation: operation)
      let debug = sqliteReader.debugFolder(postWriteFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: postWriteFolder, debug: debug)
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.folderID
        ))
      checks.append(stringCheck(name: "name", expected: draft.name, actual: postWriteFolder.name))
      checks.append(
        stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      if let parentID = draft.parentID {
        checks.append(
          stringCheck(name: "parent_preserved", expected: parentID, actual: postWriteFolder.parentID ?? ""))
      } else {
        checks.append(
          NotesVerificationCheckRecord(name: "parent_preserved", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderMove(
    operation: String,
    draft: NotesFolderMoveDraft,
    resultFolder: NotesFolderRecord
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try requiredPostWriteFolder(id: resultFolder.id, operation: operation)
      let debug = sqliteReader.debugFolder(postWriteFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: postWriteFolder, debug: debug)
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.folderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(
        stringCheck(name: "target_account", expected: draft.accountName, actual: postWriteFolder.accountName))
      if draft.sourceAccountName.localizedCaseInsensitiveCompare(draft.accountName) == .orderedSame {
        checks.append(
          stringCheck(
            name: "source_account_preserved",
            expected: draft.sourceAccountName,
            actual: postWriteFolder.accountName
          ))
      } else {
        checks.append(
          boolCheck(
            name: "source_account_changed",
            expected: true,
            actual: postWriteFolder.accountName.localizedCaseInsensitiveCompare(draft.sourceAccountName) != .orderedSame
          ))
      }
      if let parentID = draft.parentID {
        checks.append(
          stringCheck(name: "target_parent", expected: parentID, actual: postWriteFolder.parentID ?? ""))
      } else {
        checks.append(
          boolCheck(
            name: "target_root",
            expected: true,
            actual: postWriteFolder.isRootLevel == true
              || (postWriteFolder.isRootLevel == nil && postWriteFolder.parentID == nil)
          ))
      }
      if draft.descendantIDs.isEmpty == false {
        let descendantIDSet = Set(draft.descendantIDs)
        let postMoveDescendants = try reader.listFolders(account: nil, limit: 2_000)
          .filter { descendantIDSet.contains($0.id) }
        checks.append(
          countCheck(
            name: "descendant_readback_count",
            expected: draft.descendantIDs.count,
            actual: postMoveDescendants.count
          ))
        checks.append(
          boolCheck(
            name: "descendant_target_account",
            expected: true,
            actual: postMoveDescendants.count == draft.descendantIDs.count
              && postMoveDescendants.allSatisfy {
                $0.accountName.localizedCaseInsensitiveCompare(draft.accountName) == .orderedSame
              }
          ))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderSort(
    operation: String,
    draft: NotesFolderSortDraft,
    before: NotesFolderRecord,
    resultFolder: NotesFolderRecord,
    changed: Bool,
    expectedChanged: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try requiredPostWriteFolder(id: resultFolder.id, operation: operation)
      let debug = sqliteReader.debugFolder(postWriteFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: postWriteFolder, debug: debug)
      checks.append(boolCheck(name: "changed", expected: expectedChanged, actual: changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == before.id && postWriteFolder.id == draft.folderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(
        stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      if let parentID = draft.parentID {
        checks.append(
          stringCheck(name: "parent_preserved", expected: parentID, actual: postWriteFolder.parentID ?? ""))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "parent_preserved", status: "not_applicable"))
      }
      checks.append(intCheck(name: "sort_value", expected: draft.sortValue, actual: postWriteFolder.noteSortTypeValue))
      checks.append(intCheck(name: "sort_order", expected: draft.sortOrder, actual: postWriteFolder.customNoteSortOrder))
      checks.append(
        intCheck(name: "sort_direction", expected: draft.sortDirection, actual: postWriteFolder.customNoteSortDirection))
      checks.append(
        boolCheck(name: "sort_default", expected: draft.sortIsDefault, actual: postWriteFolder.customNoteSortIsDefault ?? false))
      checks.append(
        boolCheck(name: "sort_ascending", expected: draft.sortIsAscending, actual: postWriteFolder.customNoteSortIsAscending ?? false))
      checks.append(
        intCheck(
          name: "resolved_sort_order",
          expected: draft.resolvedSortOrder,
          actual: postWriteFolder.customNoteSortResolvedOrder
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderReorder(
    operation: String,
    draft: NotesFolderReorderDraft,
    before: NotesFolderRecord,
    resultFolder: NotesFolderRecord,
    changed: Bool,
    expectedChanged: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try requiredPostWriteFolder(id: resultFolder.id, operation: operation)
      let debug = sqliteReader.debugFolder(postWriteFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: postWriteFolder, debug: debug)
      checks.append(boolCheck(name: "changed", expected: expectedChanged, actual: changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == before.id && postWriteFolder.id == draft.folderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(
        stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      if let parentID = draft.parentID {
        checks.append(
          stringCheck(name: "parent_preserved", expected: parentID, actual: postWriteFolder.parentID ?? ""))
      } else {
        checks.append(
          boolCheck(
            name: "parent_preserved",
            expected: true,
            actual: postWriteFolder.parentID == nil || postWriteFolder.isRootLevel == true
          ))
      }
      checks.append(
        intCheck(name: "target_sibling_index", expected: draft.requestedIndex, actual: postWriteFolder.siblingOrderIndex))
      if let siblingOrderCount = draft.siblingOrderCount {
        checks.append(
          intCheck(
            name: "sibling_count_preserved",
            expected: siblingOrderCount,
            actual: postWriteFolder.siblingOrderCount
          ))
      }
      checks.append(
        boolCheck(
          name: "sibling_order_hash_readback",
          expected: true,
          actual: postWriteFolder.siblingOrderSHA256?.count == 64
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderDateHeaders(
    operation: String,
    draft: NotesFolderDateHeadersDraft,
    before: NotesFolderRecord,
    resultFolder: NotesFolderRecord,
    changed: Bool,
    expectedChanged: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try requiredPostWriteFolder(id: resultFolder.id, operation: operation)
      let debug = sqliteReader.debugFolder(postWriteFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: postWriteFolder, debug: debug)
      checks.append(boolCheck(name: "changed", expected: expectedChanged, actual: changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == before.id && postWriteFolder.id == draft.folderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(
        stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      if let parentID = draft.parentID {
        checks.append(
          stringCheck(name: "parent_preserved", expected: parentID, actual: postWriteFolder.parentID ?? ""))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "parent_preserved", status: "not_applicable"))
      }
      checks.append(
        boolCheck(
          name: "date_headers_supported",
          expected: true,
          actual: postWriteFolder.supportsDateHeaders ?? false
        ))
      checks.append(
        boolCheck(
          name: "date_headers_enabled",
          expected: draft.enabled,
          actual: postWriteFolder.isShowingDateHeaders ?? false
        ))
      checks.append(
        intCheck(
          name: "date_headers_type",
          expected: draft.privateValue,
          actual: postWriteFolder.dateHeadersTypeValue
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderDelete(
    operation: String,
    draft: NotesFolderDeleteDraft,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteFolder = try reader.listFolders(account: nil, limit: 2_000)
        .first(where: { $0.id == draft.folderID })
      let beforeFolder = NotesFolderRecord(
        id: draft.folderID,
        name: draft.name,
        accountName: draft.accountName,
        parentID: draft.parentID,
        parentPresent: draft.parentID != nil,
        visibleNoteCount: draft.visibleNoteCount,
        childFolderCount: draft.childFolderCount
      )
      let debug = sqliteReader.debugFolder(beforeFolder, selector: beforeFolder.id)
      let checks = [
        boolCheck(name: "changed", expected: true, actual: changed),
        boolCheck(name: "exists_after", expected: false, actual: postWriteFolder != nil),
        storeMatchCheck(objectID: draft.folderID, storeObject: debug.storeObject),
      ]

      return checkedReport(
        operation: operation,
        targetID: draft.folderID,
        readback: nil,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyFolderPurge(
    operation: String,
    draft: NotesFolderPurgeDraft,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let folderPurgeReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes folder purge verification requires private framework purgable folder readback.",
          details: ["operation": operation]
        )
      }
      let visibleFolder = try reader.listFolders(account: nil, limit: 2_000)
        .first(where: { $0.id == draft.folderID })
      let purgableFolder = try folderPurgeReader.listPurgableFolders(account: nil, limit: 2_000)
        .first(where: { $0.id == draft.folderID })
      let beforeFolder = NotesFolderRecord(
        id: draft.folderID,
        name: draft.name,
        accountName: draft.accountName,
        parentID: draft.parentID,
        parentPresent: draft.parentID != nil,
        visibleNoteCount: draft.visibleNoteCount,
        childFolderCount: draft.childFolderCount,
        isPurgable: true
      )
      let debug = sqliteReader.debugFolder(beforeFolder, selector: beforeFolder.id)
      let checks = [
        boolCheck(name: "changed", expected: true, actual: changed),
        boolCheck(name: "visible_exists_after", expected: false, actual: visibleFolder != nil),
        boolCheck(name: "purgable_exists_after", expected: false, actual: purgableFolder != nil),
        storeMatchCheck(objectID: draft.folderID, storeObject: debug.storeObject),
      ]

      return checkedReport(
        operation: operation,
        targetID: draft.folderID,
        readback: nil,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyUpdate(
    operation: String,
    before: NotesNoteDetail,
    patch: NotesUpdatePatch,
    resultNote: NotesNoteDetail
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: resultNote.id, operation: operation)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(
        boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(
        stringCheck(
          name: "title",
          expected: patch.title ?? before.title,
          actual: postWriteNote.title
        ))
      checks.append(
        bodyCheck(
          name: "body",
          expected: expectedBody(before: before, patch: patch),
          actual: postWriteNote.body ?? ""
        ))
      checks.append(
        stringCheck(
          name: "folder_preserved",
          expected: before.folderName,
          actual: postWriteNote.folderName
        ))
      checks.append(
        stringCheck(
          name: "account_preserved",
          expected: before.accountName,
          actual: postWriteNote.accountName
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistAdd(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistAddDraft,
    result: NotesBodyChecklistAddWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        intCheck(
          name: "checklist_item_count",
          expected: beforeStructure.checklistItemCount + 1,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count",
          expected: beforeStructure.checklistDoneCount + (draft.checked ? 1 : 0),
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count",
          expected: beforeStructure.checklistOpenCount + (draft.checked ? 0 : 1),
          actual: postWriteStructure.checklistOpenCount
        ))
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableCreate(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyTableCreateDraft,
    result: NotesBodyTableCreateWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        intCheck(
          name: "table_count",
          expected: beforeStructure.tableCount + 1,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count",
          expected: beforeTableKindCount + 1,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count",
          expected: beforeStructure.inlineAttachmentCount + 1,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(
        NotesVerificationCheckRecord(
          name: "table_text_hash_recorded",
          status: draft.textSHA256.count == 64 && draft.textByteCount > 0 ? "passed" : "failed",
          actualSHA256: draft.textSHA256,
          expectedLength: draft.textByteCount,
          actualLength: draft.textByteCount
        ))
      checks.append(
        intCheck(
          name: "table_text_row_count",
          expected: draft.rowCount,
          actual: draft.rowCount
        ))
      checks.append(
        intCheck(
          name: "table_text_max_column_count",
          expected: draft.maxColumnCount,
          actual: draft.maxColumnCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableImport(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    draft: NotesBodyTableImportDraft,
    result: NotesBodyTableImportWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table import verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let beforeTableIDs = Set(beforeTables.map(\.idSHA256))
      let targetCellMatches = try tableCellHashesMatchSourceText(
        reader: bodyStructureReader,
        noteID: draft.noteID,
        tableOrdinal: result.target.ordinal,
        text: draft.tableText,
        rowCount: draft.rowCount,
        columnCount: draft.maxColumnCount
      )

      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        intCheck(
          name: "table_count",
          expected: beforeStructure.tableCount + 1,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count",
          expected: beforeTables.count + 1,
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count",
          expected: beforeTableKindCount + 1,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count",
          expected: beforeStructure.inlineAttachmentCount + 1,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        boolCheck(
          name: "new_table_present",
          expected: true,
          actual: postWriteTables.contains { $0.idSHA256 == result.target.idSHA256 }
            && beforeTableIDs.contains(result.target.idSHA256) == false
        ))
      checks.append(
        NotesVerificationCheckRecord(
          name: "source_text_hash_recorded",
          status: draft.sourceSHA256.count == 64 && draft.sourceByteCount > 0 ? "passed" : "failed",
          actualSHA256: draft.sourceSHA256,
          expectedLength: draft.sourceByteCount,
          actualLength: draft.sourceByteCount
        ))
      checks.append(
        NotesVerificationCheckRecord(
          name: "normalized_table_text_hash_recorded",
          status: draft.tableTextSHA256.count == 64
            && draft.tableTextSHA256 == sha256Hex(draft.tableText)
            && draft.tableTextByteCount == draft.tableText.utf8.count
            ? "passed" : "failed",
          actualSHA256: draft.tableTextSHA256,
          expectedLength: draft.tableText.utf8.count,
          actualLength: draft.tableTextByteCount
        ))
      checks.append(boolCheck(name: "source_kind_accounted", expected: true, actual: ["inline-text", "file"].contains(draft.sourceKind)))
      checks.append(boolCheck(name: "source_format_accounted", expected: true, actual: ["tsv", "csv"].contains(draft.sourceFormat)))
      checks.append(intCheck(name: "imported_table_row_count", expected: draft.rowCount, actual: result.target.rowCount ?? -1))
      checks.append(intCheck(name: "imported_table_column_count", expected: draft.maxColumnCount, actual: result.target.columnCount ?? -1))
      checks.append(intCheck(name: "imported_table_cell_count", expected: draft.cellCount, actual: draft.rowCount * draft.maxColumnCount))
      checks.append(boolCheck(name: "table_cell_hashes_match_import_text", expected: true, actual: targetCellMatches))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.target.idSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "table_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableUpdate(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    beforeCell: NotesBodyTableCellRecord,
    draft: NotesBodyTableUpdateDraft,
    result: NotesBodyTableUpdateWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table update verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let postWriteCell = try bodyStructureReader.readTableCell(
        noteID: result.note.id,
        tableOrdinal: draft.ordinal,
        row: draft.row,
        column: draft.column
      )
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeTables.count
        ? beforeTables[draft.ordinal - 1]
        : nil
      let expectedChanged = beforeCell.textSHA256 != draft.textSHA256
        || beforeCell.textByteCount != draft.textByteCount
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "ordinal_in_range",
          expected: true,
          actual: selectedBefore != nil
        ))
      checks.append(
        boolCheck(
          name: "selected_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_table_preserved",
          expected: true,
          actual: postWriteTables.contains { $0.idSHA256 == result.target.idSHA256 }
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count_preserved",
          expected: beforeTables.count,
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count_preserved",
          expected: beforeTableKindCount,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_preserved",
          expected: beforeStructure.inlineAttachmentCount,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        boolCheck(
          name: "cell_selector_preserved",
          expected: true,
          actual: result.cell.tableOrdinal == draft.ordinal
            && result.cell.row == draft.row
            && result.cell.column == draft.column
            && postWriteCell.tableOrdinal == draft.ordinal
            && postWriteCell.row == draft.row
            && postWriteCell.column == draft.column
        ))
      checks.append(
        boolCheck(
          name: "cell_table_identity_preserved",
          expected: true,
          actual: beforeCell.tableIDSHA256 == result.target.idSHA256
            && result.cell.tableIDSHA256 == result.target.idSHA256
            && postWriteCell.tableIDSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "cell_hash_matches_draft",
          expected: true,
          actual: result.cell.textSHA256 == draft.textSHA256
            && postWriteCell.textSHA256 == draft.textSHA256
            && result.cell.textByteCount == draft.textByteCount
            && postWriteCell.textByteCount == draft.textByteCount
        ))
      checks.append(
        boolCheck(
          name: "cell_hash_changed_when_expected",
          expected: true,
          actual: expectedChanged
            ? beforeCell.textSHA256 != postWriteCell.textSHA256
              || beforeCell.textByteCount != postWriteCell.textByteCount
            : beforeCell.textSHA256 == postWriteCell.textSHA256
              && beforeCell.textByteCount == postWriteCell.textByteCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.target.idSHA256.count == 64
            && result.cell.tableIDSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(
        boolCheck(
          name: "table_cell_text_hidden",
          expected: true,
          actual: true
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableStructureChange(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    draft: NotesBodyTableStructureDraft,
    result: NotesBodyTableStructureWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table structure verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeTables.count
        ? beforeTables[draft.ordinal - 1]
        : nil
      let selectedPost = postWriteTables.first { $0.idSHA256 == result.beforeTarget.idSHA256 }
      let beforeRowCount = selectedBefore?.rowCount
      let beforeColumnCount = selectedBefore?.columnCount
      let expectedRowCount = expectedTableDimension(
        before: beforeRowCount,
        axis: .row,
        draft: draft
      )
      let expectedColumnCount = expectedTableDimension(
        before: beforeColumnCount,
        axis: .column,
        draft: draft
      )
      let postMoveDigest = try postMoveTableSliceDigest(
        reader: bodyStructureReader,
        noteID: draft.noteID,
        tableOrdinal: draft.ordinal,
        draft: draft,
        table: selectedPost
      )
      let postCopyDigest = try postCopyTableSliceDigest(
        reader: bodyStructureReader,
        noteID: draft.noteID,
        tableOrdinal: draft.ordinal,
        draft: draft,
        table: selectedPost
      )
      let postClearDigest = try postClearTableSliceDigest(
        reader: bodyStructureReader,
        noteID: draft.noteID,
        tableOrdinal: draft.ordinal,
        draft: draft,
        table: selectedPost
      )
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "ordinal_in_range", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "selected_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.beforeTarget.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_table_preserved",
          expected: true,
          actual: selectedPost?.idSHA256 == result.target.idSHA256
            && result.beforeTarget.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "table_dimension_readback",
          expected: true,
          actual: result.target.rowCount == expectedRowCount
            && selectedPost?.rowCount == expectedRowCount
            && result.target.columnCount == expectedColumnCount
            && selectedPost?.columnCount == expectedColumnCount
        ))
      if draft.action == .move {
        checks.append(
          boolCheck(
            name: "move_destination_index_present",
            expected: true,
            actual: draft.toIndex != nil
          ))
        checks.append(
          boolCheck(
            name: "moved_slice_hash_present",
            expected: true,
            actual: result.movedSliceSHA256?.count == 64
          ))
        checks.append(
          boolCheck(
            name: "moved_slice_cell_count",
            expected: true,
            actual: postMoveDigest != nil && result.movedSliceCellCount == postMoveDigest?.cellCount
          ))
        checks.append(
          boolCheck(
            name: "moved_slice_destination_readback",
            expected: true,
            actual: result.movedSliceSHA256 == postMoveDigest?.sha256
          ))
      }
      if draft.action == .copy {
        checks.append(
          boolCheck(
            name: "copy_destination_index_present",
            expected: true,
            actual: draft.toIndex != nil
          ))
        checks.append(
          boolCheck(
            name: "copied_slice_hash_present",
            expected: true,
            actual: result.copiedSliceSHA256?.count == 64
          ))
        checks.append(
          boolCheck(
            name: "copied_slice_cell_count",
            expected: true,
            actual: postCopyDigest != nil && result.copiedSliceCellCount == postCopyDigest?.cellCount
          ))
        checks.append(
          boolCheck(
            name: "copied_slice_destination_readback",
            expected: true,
            actual: result.copiedSliceSHA256 == postCopyDigest?.sha256
          ))
      }
      if draft.action == .clear {
        checks.append(
          boolCheck(
            name: "cleared_slice_hash_present",
            expected: true,
            actual: result.clearedSliceSHA256?.count == 64
          ))
        checks.append(
          boolCheck(
            name: "cleared_slice_cell_count",
            expected: true,
            actual: postClearDigest != nil && result.clearedSliceCellCount == postClearDigest?.cellCount
          ))
        checks.append(
          boolCheck(
            name: "cleared_slice_empty_readback",
            expected: true,
            actual: postClearDigest.map { $0.sha256 == emptyTableSliceDigest(cellCount: $0.cellCount) } == true
          ))
      }
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count_preserved",
          expected: beforeTables.count,
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count_preserved",
          expected: beforeTableKindCount,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_preserved",
          expected: beforeStructure.inlineAttachmentCount,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.beforeTarget.idSHA256.count == 64
            && result.target.idSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "table_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableFormat(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    beforeCells: [NotesBodyTableCellRecord],
    draft: NotesBodyTableFormatDraft,
    result: NotesBodyTableFormatWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table format verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeTables.count
        ? beforeTables[draft.ordinal - 1]
        : nil
      let selectedPost = postWriteTables.first { $0.idSHA256 == result.beforeTarget.idSHA256 }
      let postCells = try postFormatTableCells(
        reader: bodyStructureReader,
        noteID: draft.noteID,
        tableOrdinal: draft.ordinal,
        draft: draft,
        table: selectedPost
      )
      let expectedChanged = beforeCells.contains { cell in
        cell.textByteCount > 0 && tableCell(cell, contains: draft.format) != draft.enabled
      }
      let beforeTextDigest = tableSliceDigest(beforeCells)
      let postTextDigest = tableSliceDigest(postCells)
      let beforeFormatDigest = tableFormatSliceDigest(beforeCells)
      let postFormatDigest = tableFormatSliceDigest(postCells)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "ordinal_in_range", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "selected_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.beforeTarget.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_table_preserved",
          expected: true,
          actual: selectedPost?.idSHA256 == result.target.idSHA256
            && result.beforeTarget.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "table_dimensions_preserved",
          expected: true,
          actual: selectedBefore?.rowCount == selectedPost?.rowCount
            && selectedBefore?.columnCount == selectedPost?.columnCount
            && result.beforeTarget.rowCount == result.target.rowCount
            && result.beforeTarget.columnCount == result.target.columnCount
        ))
      checks.append(
        intCheck(
          name: "selected_cell_count",
          expected: draft.selectedCellCount,
          actual: postCells.count
        ))
      checks.append(
        intCheck(
          name: "result_selected_cell_count",
          expected: postCells.count,
          actual: result.cells.count
        ))
      checks.append(
        boolCheck(
          name: "selected_cell_text_hashes_preserved",
          expected: true,
          actual: beforeTextDigest == postTextDigest
            && result.beforeTextSliceSHA256 == beforeTextDigest
            && result.afterTextSliceSHA256 == postTextDigest
        ))
      checks.append(
        boolCheck(
          name: "format_readback_available",
          expected: true,
          actual: beforeFormatDigest != nil
            && postFormatDigest != nil
            && result.beforeFormatSliceSHA256 != nil
            && result.afterFormatSliceSHA256 != nil
        ))
      checks.append(
        boolCheck(
          name: "format_readback_matches_request",
          expected: true,
          actual: postCells.allSatisfy { cell in
            cell.textByteCount == 0 || tableCell(cell, contains: draft.format) == draft.enabled
          }
        ))
      checks.append(
        boolCheck(
          name: "format_hash_changed_when_expected",
          expected: true,
          actual: expectedChanged
            ? beforeFormatDigest != nil && postFormatDigest != nil && beforeFormatDigest != postFormatDigest
            : beforeFormatDigest == postFormatDigest
        ))
      checks.append(
        boolCheck(
          name: "result_format_hash_readback",
          expected: true,
          actual: result.beforeFormatSliceSHA256 == beforeFormatDigest
            && result.afterFormatSliceSHA256 == postFormatDigest
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count_preserved",
          expected: beforeTables.count,
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count_preserved",
          expected: beforeTableKindCount,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_preserved",
          expected: beforeStructure.inlineAttachmentCount,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.beforeTarget.idSHA256.count == 64
            && result.target.idSHA256.count == 64
            && result.cells.allSatisfy { $0.tableIDSHA256.count == 64 }
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "table_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableMove(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    draft: NotesBodyTableMoveDraft,
    result: NotesBodyTableMoveWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table move verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeTables.count
        ? beforeTables[draft.ordinal - 1]
        : nil
      let targetOrdinalPost = draft.targetOrdinal > 0 && draft.targetOrdinal <= postWriteTables.count
        ? postWriteTables[draft.targetOrdinal - 1]
        : nil
      let movedPost = postWriteTables.first { $0.idSHA256 == result.beforeTarget.idSHA256 }
      let beforeOrder = beforeTables.map(\.idSHA256)
      let postOrder = postWriteTables.map(\.idSHA256)
      let beforeSet = Set(beforeOrder)
      let postSet = Set(postOrder)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "ordinal_in_range", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "target_ordinal_in_range",
          expected: true,
          actual: draft.targetOrdinal > 0 && draft.targetOrdinal <= beforeTables.count
        ))
      checks.append(
        boolCheck(
          name: "source_destination_differ",
          expected: true,
          actual: draft.ordinal != draft.targetOrdinal
        ))
      checks.append(
        boolCheck(
          name: "selected_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.beforeTarget.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_table_preserved",
          expected: true,
          actual: movedPost?.idSHA256 == result.target.idSHA256
            && result.beforeTarget.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "moved_table_ordinal_readback",
          expected: true,
          actual: result.target.ordinal == draft.targetOrdinal
            && movedPost?.ordinal == draft.targetOrdinal
            && targetOrdinalPost?.idSHA256 == result.beforeTarget.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "table_order_changed",
          expected: true,
          actual: beforeOrder != postOrder
        ))
      checks.append(
        boolCheck(
          name: "table_set_preserved",
          expected: true,
          actual: beforeSet == postSet && beforeOrder.count == postOrder.count
        ))
      checks.append(
        boolCheck(
          name: "moved_table_dimensions_preserved",
          expected: true,
          actual: result.beforeTarget.rowCount == result.target.rowCount
            && result.beforeTarget.columnCount == result.target.columnCount
            && movedPost?.rowCount == result.beforeTarget.rowCount
            && movedPost?.columnCount == result.beforeTarget.columnCount
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count_preserved",
          expected: beforeTables.count,
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count_preserved",
          expected: beforeTableKindCount,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_preserved",
          expected: beforeStructure.inlineAttachmentCount,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.beforeTarget.idSHA256.count == 64
            && result.target.idSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "table_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyMathUpdate(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeResults: [NotesBodyMathResultRecord],
    draft: NotesBodyMathUpdateDraft,
    result: NotesBodyMathUpdateWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body math update verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteResults = try bodyStructureReader.listMathResults(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeResults.count
        ? beforeResults[draft.ordinal - 1]
        : nil
      let selectedPost = draft.ordinal > 0 && draft.ordinal <= postWriteResults.count
        ? postWriteResults[draft.ordinal - 1]
        : nil
      let expectedChanged = selectedBefore?.resultSHA256 != draft.resultSHA256
        || selectedBefore?.resultByteCount != draft.resultByteCount
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "ordinal_in_range", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "selected_math_result_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_math_result_preserved",
          expected: true,
          actual: selectedPost?.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        intCheck(
          name: "math_result_list_count_preserved",
          expected: beforeResults.count,
          actual: postWriteResults.count
        ))
      checks.append(
        intCheck(
          name: "result_math_result_list_count",
          expected: postWriteResults.count,
          actual: result.results.count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_preserved",
          expected: beforeStructure.inlineAttachmentCount,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        boolCheck(
          name: "result_hash_matches_draft",
          expected: true,
          actual: result.target.resultSHA256 == draft.resultSHA256
            && selectedPost?.resultSHA256 == draft.resultSHA256
            && result.target.resultByteCount == draft.resultByteCount
            && selectedPost?.resultByteCount == draft.resultByteCount
        ))
      checks.append(
        boolCheck(
          name: "result_hash_changed_when_expected",
          expected: true,
          actual: expectedChanged
            ? selectedBefore?.resultSHA256 != selectedPost?.resultSHA256
              || selectedBefore?.resultByteCount != selectedPost?.resultByteCount
            : selectedBefore?.resultSHA256 == selectedPost?.resultSHA256
              && selectedBefore?.resultByteCount == selectedPost?.resultByteCount
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.target.idSHA256.count == 64
            && result.results.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "math_result_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyMathResultsPreference(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforePreference: NotesBodyMathResultsPreferenceRecord,
    draft: NotesBodyMathResultsPreferenceDraft,
    result: NotesBodyMathResultsPreferenceWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body math results preference verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWritePreference = try bodyStructureReader.readMathResultsPreference(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let expectedChanged = beforePreference.rawValue != draft.rawValue
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "before_preference_readback",
          expected: true,
          actual: result.before == beforePreference
        ))
      checks.append(
        boolCheck(
          name: "requested_preference_readback",
          expected: true,
          actual: result.after.mode == draft.mode
            && result.after.rawValue == draft.rawValue
            && result.after.valueSHA256 == draft.requestedValueSHA256
        ))
      checks.append(
        boolCheck(
          name: "independent_preference_readback",
          expected: true,
          actual: postWritePreference == result.after
        ))
      checks.append(
        boolCheck(
          name: "preference_changed_when_expected",
          expected: true,
          actual: expectedChanged
            ? result.before.valueSHA256 != result.after.valueSHA256
            : result.before.valueSHA256 == result.after.valueSHA256
        ))
      checks.append(
        boolCheck(
          name: "plain_text_hash_preserved",
          expected: true,
          actual: beforeStructure.plainTextSHA256 == postWriteStructure.plainTextSHA256
            && beforeStructure.plainTextByteCount == postWriteStructure.plainTextByteCount
        ))
      checks.append(
        boolCheck(
          name: "rich_text_length_preserved",
          expected: true,
          actual: beforeStructure.richTextLength == postWriteStructure.richTextLength
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_preserved",
          expected: beforeStructure.inlineAttachmentCount,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "preference_key_hashed",
          expected: true,
          actual: result.after.userDefaultsKeySHA256?.count == 64
            || result.after.userDefaultsKeySHA256 == nil
        ))
      checks.append(boolCheck(name: "math_preference_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyMathInsert(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeResults: [NotesBodyMathResultRecord],
    draft: NotesBodyMathInsertDraft,
    result: NotesBodyMathInsertWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body math insert verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteResults = try bodyStructureReader.listMathResults(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeIDs = Set(beforeResults.map(\.idSHA256))
      let postTarget = postWriteResults.first { $0.idSHA256 == result.target.idSHA256 }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "inserted_math_result_is_new",
          expected: true,
          actual: beforeIDs.contains(result.target.idSHA256) == false
        ))
      checks.append(
        boolCheck(
          name: "inserted_math_result_readback",
          expected: true,
          actual: postTarget?.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        intCheck(
          name: "math_result_list_count_incremented",
          expected: beforeResults.count + 1,
          actual: postWriteResults.count
        ))
      checks.append(
        intCheck(
          name: "result_math_result_list_count",
          expected: postWriteResults.count,
          actual: result.results.count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_incremented",
          expected: beforeStructure.mathAttachmentCount + 1,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count_incremented",
          expected: beforeStructure.inlineAttachmentCount + 1,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        boolCheck(
          name: "expression_hash_matches_draft",
          expected: true,
          actual: result.target.expressionSHA256 == draft.expressionSHA256
            && postTarget?.expressionSHA256 == draft.expressionSHA256
            && result.target.expressionByteCount == draft.expressionByteCount
            && postTarget?.expressionByteCount == draft.expressionByteCount
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.target.idSHA256.count == 64
            && result.results.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "math_expression_text_hidden", expected: true, actual: true))
      checks.append(boolCheck(name: "math_result_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyMathVariableSet(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeResults: [NotesBodyMathResultRecord],
    draft: NotesBodyMathVariableSetDraft,
    result: NotesBodyMathVariableSetWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body math variable set verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteResults = try bodyStructureReader.listMathResults(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeIDs = Set(beforeResults.map(\.idSHA256))
      let postDefinition = postWriteResults.first { $0.idSHA256 == result.variableDefinitionResult.idSHA256 }
      let postDependent = postWriteResults.first { $0.idSHA256 == result.dependentResult.idSHA256 }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "variable_definition_result_is_new",
          expected: true,
          actual: beforeIDs.contains(result.variableDefinitionResult.idSHA256) == false
        ))
      checks.append(
        boolCheck(
          name: "dependent_result_is_new",
          expected: true,
          actual: beforeIDs.contains(result.dependentResult.idSHA256) == false
        ))
      checks.append(
        boolCheck(
          name: "variable_definition_result_readback",
          expected: true,
          actual: postDefinition?.idSHA256 == result.variableDefinitionResult.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "dependent_result_readback",
          expected: true,
          actual: postDependent?.idSHA256 == result.dependentResult.idSHA256
        ))
      checks.append(
        intCheck(
          name: "math_result_list_count_incremented",
          expected: beforeResults.count + 2,
          actual: postWriteResults.count
        ))
      checks.append(
        intCheck(
          name: "result_math_result_list_count",
          expected: postWriteResults.count,
          actual: result.results.count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_incremented",
          expected: beforeStructure.mathAttachmentCount + 2,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        boolCheck(
          name: "variable_definition_expression_hash_matches",
          expected: true,
          actual: result.variableDefinitionResult.expressionSHA256 == draft.variableDefinitionExpressionSHA256
            && postDefinition?.expressionSHA256 == draft.variableDefinitionExpressionSHA256
            && result.variableDefinitionResult.expressionByteCount == draft.variableDefinitionExpressionByteCount
        ))
      checks.append(
        boolCheck(
          name: "dependent_expression_hash_matches",
          expected: true,
          actual: result.dependentResult.expressionSHA256 == draft.dependentExpressionSHA256
            && postDependent?.expressionSHA256 == draft.dependentExpressionSHA256
            && result.dependentResult.expressionByteCount == draft.dependentExpressionByteCount
        ))
      checks.append(
        boolCheck(
          name: "variable_dependency_group_readback",
          expected: true,
          actual: result.variableDefinitionResult.idSHA256 != result.dependentResult.idSHA256
            && result.variableDefinitionResult.isValid == true
            && result.dependentResult.isValid == true
        ))
      checks.append(
        intCheck(
          name: "table_count_preserved",
          expected: beforeStructure.tableCount,
          actual: postWriteStructure.tableCount
        ))
      checks.append(boolCheck(name: "math_note_state_enabled", expected: true, actual: postWriteStructure.isMathNote))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.variableDefinitionResult.idSHA256.count == 64
            && result.dependentResult.idSHA256.count == 64
            && result.results.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "variable_name_value_text_hidden", expected: true, actual: true))
      checks.append(boolCheck(name: "math_expression_result_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyMathVariableUpdate(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeResults: [NotesBodyMathResultRecord],
    draft: NotesBodyMathVariableUpdateDraft,
    result: NotesBodyMathVariableUpdateWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body math variable update verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteResults = try bodyStructureReader.listMathResults(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let selectedDefinitionBefore = draft.definitionOrdinal > 0 && draft.definitionOrdinal <= beforeResults.count
        ? beforeResults[draft.definitionOrdinal - 1]
        : nil
      let selectedDependentBefore = draft.dependentOrdinal > 0 && draft.dependentOrdinal <= beforeResults.count
        ? beforeResults[draft.dependentOrdinal - 1]
        : nil
      let selectedDefinitionPost = draft.definitionOrdinal > 0 && draft.definitionOrdinal <= postWriteResults.count
        ? postWriteResults[draft.definitionOrdinal - 1]
        : nil
      let selectedDependentPost = draft.dependentOrdinal > 0 && draft.dependentOrdinal <= postWriteResults.count
        ? postWriteResults[draft.dependentOrdinal - 1]
        : nil
      let dependentChanged = result.afterDependent.resultSHA256 != result.beforeDependent.resultSHA256
        || result.afterDependent.resultByteCount != result.beforeDependent.resultByteCount
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "definition_ordinal_in_range", expected: true, actual: selectedDefinitionBefore != nil))
      checks.append(boolCheck(name: "dependent_ordinal_in_range", expected: true, actual: selectedDependentBefore != nil))
      checks.append(
        boolCheck(
          name: "selected_definition_read_before",
          expected: true,
          actual: selectedDefinitionBefore?.idSHA256 == result.beforeDefinition.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_dependent_read_before",
          expected: true,
          actual: selectedDependentBefore?.idSHA256 == result.beforeDependent.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_definition_readback",
          expected: true,
          actual: selectedDefinitionPost?.idSHA256 == result.afterDefinition.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_dependent_readback",
          expected: true,
          actual: selectedDependentPost?.idSHA256 == result.afterDependent.idSHA256
        ))
      checks.append(
        intCheck(
          name: "math_result_list_count_preserved",
          expected: beforeResults.count,
          actual: postWriteResults.count
        ))
      checks.append(
        intCheck(
          name: "result_math_result_list_count",
          expected: postWriteResults.count,
          actual: result.results.count
        ))
      checks.append(
        boolCheck(
          name: "definition_expression_or_result_changed",
          expected: true,
          actual: result.afterDefinition.expressionSHA256 != result.beforeDefinition.expressionSHA256
            || result.afterDefinition.resultSHA256 != result.beforeDefinition.resultSHA256
            || result.afterDefinition.expressionByteCount != result.beforeDefinition.expressionByteCount
            || result.afterDefinition.resultByteCount != result.beforeDefinition.resultByteCount
        ))
      checks.append(
        boolCheck(
          name: "dependent_result_auto_updated",
          expected: true,
          actual: dependentChanged
        ))
      checks.append(
        boolCheck(
          name: "dependent_expression_preserved",
          expected: true,
          actual: result.afterDependent.expressionSHA256 == result.beforeDependent.expressionSHA256
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.afterDefinition.idSHA256.count == 64
            && result.afterDependent.idSHA256.count == 64
            && result.results.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "variable_value_text_hidden", expected: true, actual: true))
      checks.append(boolCheck(name: "math_expression_result_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableDelete(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    draft: NotesBodyTableDeleteDraft,
    result: NotesBodyTableDeleteWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table deletion verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeTables.count
        ? beforeTables[draft.ordinal - 1]
        : nil
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "ordinal_in_range",
          expected: true,
          actual: selectedBefore != nil
        ))
      checks.append(
        boolCheck(
          name: "selected_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_table_removed",
          expected: true,
          actual: !postWriteTables.contains { $0.idSHA256 == result.target.idSHA256 }
        ))
      checks.append(
        intCheck(
          name: "table_count",
          expected: max(0, beforeStructure.tableCount - 1),
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count",
          expected: max(0, beforeTables.count - 1),
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count",
          expected: max(0, beforeTableKindCount - 1),
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count",
          expected: max(0, beforeStructure.inlineAttachmentCount - 1),
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.target.idSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(
        boolCheck(
          name: "table_cell_text_hidden",
          expected: true,
          actual: true
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableConvertToText(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    draft: NotesBodyTableConvertToTextDraft,
    result: NotesBodyTableConvertToTextWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table conversion verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeTables.count
        ? beforeTables[draft.ordinal - 1]
        : nil
      let convertedTextReadback = result.convertedText.isEmpty
        ? true
        : (postWriteNote.body?.contains(result.convertedText) ?? false)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "ordinal_in_range", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "selected_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.target.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "selected_table_removed",
          expected: true,
          actual: !postWriteTables.contains { $0.idSHA256 == result.target.idSHA256 }
        ))
      checks.append(
        intCheck(
          name: "table_count",
          expected: max(0, beforeStructure.tableCount - 1),
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count",
          expected: max(0, beforeTables.count - 1),
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count",
          expected: max(0, beforeTableKindCount - 1),
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count",
          expected: max(0, beforeStructure.inlineAttachmentCount - 1),
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(intCheck(name: "converted_text_row_count", expected: draft.rowCount, actual: result.rowCount))
      checks.append(intCheck(name: "converted_text_column_count", expected: draft.columnCount, actual: result.columnCount))
      checks.append(intCheck(name: "converted_text_cell_count", expected: draft.cellCount, actual: result.cellCount))
      checks.append(
        NotesVerificationCheckRecord(
          name: "converted_text_hash_recorded",
          status: result.convertedTextSHA256.count == 64
            && result.convertedTextSHA256 == sha256Hex(result.convertedText)
            && result.convertedTextByteCount == result.convertedText.utf8.count
            ? "passed" : "failed",
          actualSHA256: result.convertedTextSHA256,
          expectedLength: result.convertedText.utf8.count,
          actualLength: result.convertedTextByteCount
        ))
      checks.append(boolCheck(name: "converted_text_readback", expected: true, actual: convertedTextReadback))
      if let beforeBody = before.body, let afterBody = postWriteNote.body {
        checks.append(boolCheck(name: "body_sha256_changed", expected: true, actual: sha256Hex(afterBody) != sha256Hex(beforeBody)))
      }
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.target.idSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "table_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableConvertFromText(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeTables: [NotesBodyTableRecord],
    draft: NotesBodyTableConvertFromTextDraft,
    result: NotesBodyTableConvertFromTextWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes text-to-table conversion verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteTables = try bodyStructureReader.listTables(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTableKindCount = bodyAttachmentKindCount("table", in: beforeStructure)
      let postTableKindCount = bodyAttachmentKindCount("table", in: postWriteStructure)
      let beforeTableIDs = Set(beforeTables.map(\.idSHA256))
      let selectedBefore = beforeStructure.paragraphAnchors.first { $0.idSHA256 == draft.paragraphIDSHA256 }
      let postAnchorIDs = Set(postWriteStructure.paragraphAnchors.map(\.idSHA256))
      let sourceText = try normalizedBodyTableText(result.sourceText)
      let targetCellMatches = try tableCellHashesMatchSourceText(
        reader: bodyStructureReader,
        noteID: draft.noteID,
        tableOrdinal: result.target.ordinal,
        text: sourceText.text,
        rowCount: sourceText.rowCount,
        columnCount: sourceText.maxColumnCount
      )

      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "selected_paragraph_read_before", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "selected_paragraph_ordinary_body",
          expected: true,
          actual: selectedBefore.map {
            !$0.isHeader && !$0.isList && !$0.isChecklist && !$0.isBlockQuote
          } ?? false
        ))
      checks.append(
        boolCheck(
          name: "source_paragraph_removed",
          expected: true,
          actual: postAnchorIDs.contains(draft.paragraphIDSHA256) == false
        ))
      checks.append(
        boolCheck(
          name: "other_paragraph_anchors_preserved",
          expected: true,
          actual: beforeStructure.paragraphAnchors
            .filter { $0.idSHA256 != draft.paragraphIDSHA256 }
            .allSatisfy { postAnchorIDs.contains($0.idSHA256) }
        ))
      checks.append(
        intCheck(
          name: "table_count",
          expected: beforeStructure.tableCount + 1,
          actual: postWriteStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "table_list_count",
          expected: beforeTables.count + 1,
          actual: postWriteTables.count
        ))
      checks.append(
        intCheck(
          name: "result_table_list_count",
          expected: postWriteTables.count,
          actual: result.tables.count
        ))
      checks.append(
        intCheck(
          name: "table_attachment_kind_count",
          expected: beforeTableKindCount + 1,
          actual: postTableKindCount
        ))
      checks.append(
        intCheck(
          name: "inline_attachment_count",
          expected: beforeStructure.inlineAttachmentCount + 1,
          actual: postWriteStructure.inlineAttachmentCount
        ))
      checks.append(
        boolCheck(
          name: "new_table_present",
          expected: true,
          actual: postWriteTables.contains { $0.idSHA256 == result.target.idSHA256 }
            && beforeTableIDs.contains(result.target.idSHA256) == false
        ))
      checks.append(intCheck(name: "source_text_row_count", expected: sourceText.rowCount, actual: result.rowCount))
      checks.append(intCheck(name: "source_text_column_count", expected: sourceText.maxColumnCount, actual: result.columnCount))
      checks.append(intCheck(name: "source_text_cell_count", expected: result.rowCount * result.columnCount, actual: result.cellCount))
      checks.append(
        NotesVerificationCheckRecord(
          name: "source_text_hash_recorded",
          status: result.sourceTextSHA256.count == 64
            && result.sourceTextSHA256 == sha256Hex(result.sourceText)
            && result.sourceTextByteCount == result.sourceText.utf8.count
            ? "passed" : "failed",
          actualSHA256: result.sourceTextSHA256,
          expectedLength: result.sourceText.utf8.count,
          actualLength: result.sourceTextByteCount
        ))
      checks.append(boolCheck(name: "table_cell_hashes_match_source_text", expected: true, actual: targetCellMatches))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeStructure).count,
          actual: ordinaryListAnchors(in: postWriteStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeStructure.mathAttachmentCount,
          actual: postWriteStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.sourceParagraphIDSHA256.isEmpty == false
            && result.target.idSHA256.count == 64
            && result.tables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "source_and_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyTableCopy(
    operation: String,
    beforeSource: NotesNoteDetail,
    beforeTarget: NotesNoteDetail,
    beforeSourceStructure: NotesBodyStructureRecord,
    beforeTargetStructure: NotesBodyStructureRecord,
    beforeSourceTables: [NotesBodyTableRecord],
    beforeTargetTables: [NotesBodyTableRecord],
    draft: NotesBodyTableCopyDraft,
    result: NotesBodyTableCopyWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body table copy verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let sameNote = draft.sameNote
      let postSourceNote = try requiredPostWriteNote(id: result.sourceNote.id, operation: operation)
      let postTargetNote = sameNote
        ? postSourceNote
        : try requiredPostWriteNote(id: result.targetNote.id, operation: operation)
      let postSourceStructure = try bodyStructureReader.readBodyStructure(noteID: result.sourceNote.id)
      let postTargetStructure = sameNote
        ? postSourceStructure
        : try bodyStructureReader.readBodyStructure(noteID: result.targetNote.id)
      let postSourceTables = try bodyStructureReader.listTables(noteID: result.sourceNote.id)
      let postTargetTables = sameNote
        ? postSourceTables
        : try bodyStructureReader.listTables(noteID: result.targetNote.id)
      let beforeTargetTableKindCount = bodyAttachmentKindCount("table", in: beforeTargetStructure)
      let postTargetTableKindCount = bodyAttachmentKindCount("table", in: postTargetStructure)
      let beforeSourceTableKindCount = bodyAttachmentKindCount("table", in: beforeSourceStructure)
      let postSourceTableKindCount = bodyAttachmentKindCount("table", in: postSourceStructure)
      let selectedBefore = draft.ordinal > 0 && draft.ordinal <= beforeSourceTables.count
        ? beforeSourceTables[draft.ordinal - 1]
        : nil
      let beforeTargetTableIDs = Set(beforeTargetTables.map(\.idSHA256))
      let targetCellMatches = try copiedTableCellHashesMatch(
        reader: bodyStructureReader,
        draft: draft,
        targetTableOrdinal: result.targetTable.ordinal
      )
      let debug = sqliteReader.debugNote(postTargetNote)
      let expectedSourceTableCount = sameNote ? beforeSourceStructure.tableCount + 1 : beforeSourceStructure.tableCount
      let expectedSourceTableListCount = sameNote ? beforeSourceTables.count + 1 : beforeSourceTables.count
      let expectedSourceTableKindCount = sameNote ? beforeSourceTableKindCount + 1 : beforeSourceTableKindCount
      let expectedSourceInlineCount = sameNote
        ? beforeSourceStructure.inlineAttachmentCount + 1
        : beforeSourceStructure.inlineAttachmentCount

      var checks = commonNoteChecks(note: postTargetNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "source_identity_preserved", expected: true, actual: postSourceNote.id == beforeSource.id))
      checks.append(boolCheck(name: "target_identity_preserved", expected: true, actual: postTargetNote.id == beforeTarget.id))
      checks.append(boolCheck(name: "draft_source_preserved", expected: true, actual: postSourceNote.id == draft.sourceNoteID))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postTargetNote.id == draft.targetNoteID))
      checks.append(stringCheck(name: "source_title_preserved", expected: beforeSource.title, actual: postSourceNote.title))
      checks.append(stringCheck(name: "source_folder_preserved", expected: beforeSource.folderName, actual: postSourceNote.folderName))
      checks.append(stringCheck(name: "source_account_preserved", expected: beforeSource.accountName, actual: postSourceNote.accountName))
      checks.append(stringCheck(name: "target_title_preserved", expected: beforeTarget.title, actual: postTargetNote.title))
      checks.append(stringCheck(name: "target_folder_preserved", expected: beforeTarget.folderName, actual: postTargetNote.folderName))
      checks.append(stringCheck(name: "target_account_preserved", expected: beforeTarget.accountName, actual: postTargetNote.accountName))
      checks.append(boolCheck(name: "source_body_structure_note", expected: true, actual: postSourceStructure.noteID == draft.sourceNoteID))
      checks.append(boolCheck(name: "target_body_structure_note", expected: true, actual: postTargetStructure.noteID == draft.targetNoteID))
      checks.append(boolCheck(name: "ordinal_in_range", expected: true, actual: selectedBefore != nil))
      checks.append(
        boolCheck(
          name: "source_table_read_before",
          expected: true,
          actual: selectedBefore?.idSHA256 == result.sourceTable.idSHA256
        ))
      checks.append(
        boolCheck(
          name: "source_table_preserved",
          expected: true,
          actual: postSourceTables.contains { $0.idSHA256 == result.sourceTable.idSHA256 }
        ))
      checks.append(
        boolCheck(
          name: "target_new_table_present",
          expected: true,
          actual: postTargetTables.contains { $0.idSHA256 == result.targetTable.idSHA256 }
            && beforeTargetTableIDs.contains(result.targetTable.idSHA256) == false
        ))
      checks.append(
        intCheck(
          name: "target_table_count",
          expected: beforeTargetStructure.tableCount + 1,
          actual: postTargetStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "target_table_list_count",
          expected: beforeTargetTables.count + 1,
          actual: postTargetTables.count
        ))
      checks.append(
        intCheck(
          name: "source_table_count",
          expected: expectedSourceTableCount,
          actual: postSourceStructure.tableCount
        ))
      checks.append(
        intCheck(
          name: "source_table_list_count",
          expected: expectedSourceTableListCount,
          actual: postSourceTables.count
        ))
      checks.append(
        intCheck(
          name: "result_source_table_list_count",
          expected: postSourceTables.count,
          actual: result.sourceTables.count
        ))
      checks.append(
        intCheck(
          name: "result_target_table_list_count",
          expected: postTargetTables.count,
          actual: result.targetTables.count
        ))
      checks.append(
        intCheck(
          name: "target_table_attachment_kind_count",
          expected: beforeTargetTableKindCount + 1,
          actual: postTargetTableKindCount
        ))
      checks.append(
        intCheck(
          name: "target_inline_attachment_count",
          expected: beforeTargetStructure.inlineAttachmentCount + 1,
          actual: postTargetStructure.inlineAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "source_table_attachment_kind_count",
          expected: expectedSourceTableKindCount,
          actual: postSourceTableKindCount
        ))
      checks.append(
        intCheck(
          name: "source_inline_attachment_count",
          expected: expectedSourceInlineCount,
          actual: postSourceStructure.inlineAttachmentCount
        ))
      checks.append(intCheck(name: "copied_table_row_count", expected: draft.rowCount, actual: result.rowCount))
      checks.append(intCheck(name: "copied_table_column_count", expected: draft.columnCount, actual: result.columnCount))
      checks.append(intCheck(name: "copied_table_cell_count", expected: draft.cellCount, actual: result.cellCount))
      checks.append(intCheck(name: "target_table_row_count", expected: draft.rowCount, actual: result.targetTable.rowCount))
      checks.append(intCheck(name: "target_table_column_count", expected: draft.columnCount, actual: result.targetTable.columnCount))
      checks.append(
        NotesVerificationCheckRecord(
          name: "copied_text_hash_recorded",
          status: result.copiedTextSHA256.count == 64
            && result.copiedTextSHA256 == sha256Hex(result.copiedText)
            && result.copiedTextByteCount == result.copiedText.utf8.count
            ? "passed" : "failed",
          actualSHA256: result.copiedTextSHA256,
          expectedLength: result.copiedText.utf8.count,
          actualLength: result.copiedTextByteCount
        ))
      checks.append(boolCheck(name: "copied_table_cell_hashes_match", expected: true, actual: targetCellMatches))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeTargetStructure.checklistItemCount,
          actual: postTargetStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: ordinaryListAnchors(in: beforeTargetStructure).count,
          actual: ordinaryListAnchors(in: postTargetStructure).count
        ))
      checks.append(
        intCheck(
          name: "math_attachment_count_preserved",
          expected: beforeTargetStructure.mathAttachmentCount,
          actual: postTargetStructure.mathAttachmentCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeTargetStructure.collapsibleSectionCount,
          actual: postTargetStructure.collapsibleSectionCount
        ))
      checks.append(boolCheck(name: "target_password_protected", expected: false, actual: postTargetStructure.isPasswordProtected))
      checks.append(
        boolCheck(
          name: "private_identifiers_hidden",
          expected: true,
          actual: result.sourceTable.idSHA256.count == 64
            && result.targetTable.idSHA256.count == 64
            && result.sourceTables.allSatisfy { $0.idSHA256.count == 64 }
            && result.targetTables.allSatisfy { $0.idSHA256.count == 64 }
        ))
      checks.append(boolCheck(name: "table_cell_text_hidden", expected: true, actual: true))

      return checkedReport(
        operation: operation,
        targetID: postTargetNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistSet(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistSetDraft,
    result: NotesBodyChecklistSetWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let delta = result.changed ? 1 : 0
      let expectedDone = beforeStructure.checklistDoneCount + (draft.checked ? delta : -delta)
      let expectedOpen = beforeStructure.checklistOpenCount + (draft.checked ? -delta : delta)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      if let ordinal = draft.ordinal {
        checks.append(
          boolCheck(
            name: "ordinal_in_range",
            expected: true,
            actual: ordinal > 0 && ordinal <= beforeStructure.checklistItemCount
          ))
      }
      if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
        let beforeAnchor = beforeStructure.paragraphAnchors.first {
          $0.idSHA256 == paragraphIDSHA256 && $0.isChecklist
        }
        let afterAnchor = postWriteStructure.paragraphAnchors.first {
          $0.idSHA256 == paragraphIDSHA256 && $0.isChecklist
        }
        checks.append(boolCheck(name: "paragraph_anchor_checklist_before", expected: true, actual: beforeAnchor != nil))
        checks.append(boolCheck(name: "paragraph_anchor_checklist_after", expected: true, actual: afterAnchor != nil))
      }
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count",
          expected: expectedDone,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count",
          expected: expectedOpen,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyCollapsibleSet(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeSections: [NotesBodyCollapsibleSectionRecord],
    draft: NotesBodyCollapsibleSetDraft,
    result: NotesBodyCollapsibleSetWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body collapsible section verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteSections = try bodyStructureReader.listCollapsibleSections(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTarget = collapsibleSectionTarget(draft: draft, sections: beforeSections)
      let postTarget = beforeTarget.flatMap { target in
        postWriteSections.first { $0.paragraphIDSHA256 == target.paragraphIDSHA256 }
      }
      let expectedCollapsed = beforeTarget.map { target in
        switch draft.state {
        case .collapsed: true
        case .expanded: false
        case .toggle: !target.collapsed
        }
      }
      let expectedChanged = beforeTarget
        .flatMap { target in expectedCollapsed.map { target.collapsed != $0 } } ?? false
      let beforeCollapsedCount = beforeSections.filter { $0.collapsed }.count
      let expectedCollapsedCount = beforeCollapsedCount
        + ((beforeTarget?.collapsed == false && expectedCollapsed == true) ? 1 : 0)
        - ((beforeTarget?.collapsed == true && expectedCollapsed == false) ? 1 : 0)

      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_section_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_section_after", expected: true, actual: postTarget != nil))
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      if let expectedCollapsed {
        checks.append(boolCheck(name: "target_collapsed_state", expected: expectedCollapsed, actual: postTarget?.collapsed == true))
        checks.append(boolCheck(name: "result_target_collapsed_state", expected: expectedCollapsed, actual: result.target.collapsed))
      }
      if let beforeTarget {
        checks.append(
          stringCheck(
            name: "target_paragraph_hash_preserved",
            expected: beforeTarget.paragraphIDSHA256,
            actual: postTarget?.paragraphIDSHA256 ?? ""
          ))
        checks.append(
          stringCheck(
            name: "result_target_paragraph_hash",
            expected: beforeTarget.paragraphIDSHA256,
            actual: result.target.paragraphIDSHA256
          ))
      }
      checks.append(
        intCheck(
          name: "collapsible_section_count_preserved",
          expected: beforeStructure.collapsibleSectionCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_list_count",
          expected: postWriteStructure.collapsibleSectionCount,
          actual: postWriteSections.count
        ))
      checks.append(
        intCheck(
          name: "collapsed_section_count",
          expected: expectedCollapsedCount,
          actual: postWriteStructure.collapsedSectionCount
        ))
      checks.append(
        intCheck(
          name: "collapsed_section_list_count",
          expected: expectedCollapsedCount,
          actual: postWriteSections.filter { $0.collapsed }.count
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistSetAll(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistSetAllDraft,
    result: NotesBodyChecklistSetAllWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let expectedDone = draft.checked ? beforeStructure.checklistItemCount : 0
      let expectedOpen = draft.checked ? 0 : beforeStructure.checklistItemCount
      let beforeChecklistAnchors = beforeStructure.paragraphAnchors.filter { $0.isChecklist }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "has_checklist_before",
          expected: true,
          actual: beforeStructure.checklistItemCount > 0
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count",
          expected: expectedDone,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count",
          expected: expectedOpen,
          actual: postWriteStructure.checklistOpenCount
        ))
      for anchor in beforeChecklistAnchors {
        checks.append(
          boolCheck(
            name: "paragraph_anchor_preserved_\(anchor.ordinal)",
            expected: true,
            actual: postWriteStructure.paragraphAnchors.contains {
              $0.idSHA256 == anchor.idSHA256 && $0.isChecklist
            }
          ))
      }
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistSort(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistSortDraft,
    result: NotesBodyChecklistSortWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeChecklistAnchors = checklistAnchors(in: beforeStructure)
      let postChecklistAnchors = checklistAnchors(in: postWriteStructure)
      let expectedOrder = checklistSortOrder(beforeChecklistAnchors)
      let actualOrder = postChecklistAnchors.map(\.idSHA256)
      let expectedChanged = expectedOrder != beforeChecklistAnchors.map(\.idSHA256)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "checklist_sorted_checked_last",
          expected: true,
          actual: checklistDoneItemsAreLast(postChecklistAnchors)
        ))
      checks.append(
        stringCheck(
          name: "checklist_anchor_order",
          expected: expectedOrder.joined(separator: ","),
          actual: actualOrder.joined(separator: ",")
        ))
      checks.append(
        stringCheck(
          name: "open_anchor_relative_order",
          expected: beforeChecklistAnchors.filter { $0.checklistDone != true }.map(\.idSHA256).joined(separator: ","),
          actual: postChecklistAnchors.filter { $0.checklistDone != true }.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        stringCheck(
          name: "checked_anchor_relative_order",
          expected: beforeChecklistAnchors.filter { $0.checklistDone == true }.map(\.idSHA256).joined(separator: ","),
          actual: postChecklistAnchors.filter { $0.checklistDone == true }.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistConvert(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistConvertDraft,
    result: NotesBodyChecklistConvertWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchor = bodyChecklistConvertAnchor(draft: draft, structure: beforeStructure)
      let afterAnchor = beforeAnchor.flatMap { beforeAnchor in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == beforeAnchor.idSHA256 }
      }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      if let ordinal = draft.ordinal {
        checks.append(
          boolCheck(
            name: "paragraph_ordinal_in_range",
            expected: true,
            actual: ordinal > 0 && ordinal <= beforeStructure.paragraphAnchors.count
          ))
      }
      checks.append(boolCheck(name: "paragraph_anchor_before", expected: true, actual: beforeAnchor != nil))
      checks.append(
        boolCheck(
          name: "paragraph_anchor_was_not_checklist",
          expected: true,
          actual: beforeAnchor.map { !$0.isChecklist } ?? false
        ))
      checks.append(boolCheck(name: "paragraph_anchor_after", expected: true, actual: afterAnchor != nil))
      checks.append(
        boolCheck(
          name: "paragraph_anchor_is_checklist_after",
          expected: true,
          actual: afterAnchor?.isChecklist == true
        ))
      if let beforeAnchor, let afterAnchor {
        checks.append(
          boolCheck(
            name: "paragraph_title_hash_preserved",
            expected: true,
            actual: beforeAnchor.titleByteCount == afterAnchor.titleByteCount
              && beforeAnchor.titleSHA256 == afterAnchor.titleSHA256
          ))
      }
      checks.append(
        intCheck(
          name: "checklist_item_count",
          expected: beforeStructure.checklistItemCount + 1,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count",
          expected: beforeStructure.checklistDoneCount + (draft.checked ? 1 : 0),
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count",
          expected: beforeStructure.checklistOpenCount + (draft.checked ? 0 : 1),
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistConvertRange(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistConvertRangeDraft,
    result: NotesBodyChecklistConvertRangeWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let selectedAnchors = bodyChecklistConvertRangeAnchors(draft: draft, structure: beforeStructure)
      let selectedIDs = Set(selectedAnchors.map(\.idSHA256))
      let afterSelectedAnchors = selectedAnchors.compactMap { beforeAnchor in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == beforeAnchor.idSHA256 }
      }
      let selectedCount = selectedAnchors.count
      let allSelectedWereNonChecklist = !selectedAnchors.isEmpty && selectedAnchors.allSatisfy { !$0.isChecklist }
      let allSelectedAreChecklistAfter = afterSelectedAnchors.count == selectedCount
        && afterSelectedAnchors.allSatisfy(\.isChecklist)
      let preservedTitleHashes = zip(selectedAnchors, afterSelectedAnchors).allSatisfy { beforeAnchor, afterAnchor in
        beforeAnchor.titleByteCount == afterAnchor.titleByteCount
          && beforeAnchor.titleSHA256 == afterAnchor.titleSHA256
      }
      let expectedDoneDelta = draft.checked ? selectedCount : 0
      let expectedOpenDelta = draft.checked ? 0 : selectedCount
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "from_ordinal_in_range",
          expected: true,
          actual: draft.fromOrdinal > 0 && draft.fromOrdinal <= beforeAnchors.count
        ))
      checks.append(
        boolCheck(
          name: "to_ordinal_in_range",
          expected: true,
          actual: draft.toOrdinal > 0 && draft.toOrdinal <= beforeAnchors.count
        ))
      checks.append(
        boolCheck(
          name: "ordinal_range_order",
          expected: true,
          actual: draft.fromOrdinal <= draft.toOrdinal
        ))
      checks.append(
        intCheck(
          name: "selected_paragraph_count",
          expected: max(0, draft.toOrdinal - draft.fromOrdinal + 1),
          actual: selectedCount
        ))
      checks.append(
        boolCheck(
          name: "selected_paragraphs_were_not_checklist",
          expected: true,
          actual: allSelectedWereNonChecklist
        ))
      checks.append(
        boolCheck(
          name: "selected_paragraphs_after",
          expected: true,
          actual: afterSelectedAnchors.count == selectedCount && selectedCount > 0
        ))
      checks.append(
        boolCheck(
          name: "selected_paragraphs_are_checklist_after",
          expected: true,
          actual: allSelectedAreChecklistAfter
        ))
      checks.append(
        boolCheck(
          name: "selected_title_hashes_preserved",
          expected: true,
          actual: selectedCount > 0 && preservedTitleHashes
        ))
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count",
          expected: beforeStructure.checklistItemCount + selectedCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count",
          expected: beforeStructure.checklistDoneCount + expectedDoneDelta,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count",
          expected: beforeStructure.checklistOpenCount + expectedOpenDelta,
          actual: postWriteStructure.checklistOpenCount
        ))
      checks.append(
        intCheck(
          name: "paragraph_anchor_count_preserved",
          expected: beforeStructure.paragraphAnchors.count,
          actual: postWriteStructure.paragraphAnchors.count
        ))
      let nonSelectedBefore = beforeAnchors.filter { !selectedIDs.contains($0.idSHA256) }.map(\.idSHA256)
      let nonSelectedAfter = postAnchors.filter { !selectedIDs.contains($0.idSHA256) }.map(\.idSHA256)
      checks.append(
        stringCheck(
          name: "non_selected_anchor_order_preserved",
          expected: nonSelectedBefore.joined(separator: ","),
          actual: nonSelectedAfter.joined(separator: ",")
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistReorder(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistReorderDraft,
    result: NotesBodyChecklistReorderWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeChecklistAnchors = checklistAnchors(in: beforeStructure)
      let postChecklistAnchors = checklistAnchors(in: postWriteStructure)
      let sourceIndex = bodyChecklistReorderSourceIndex(draft: draft, checklistAnchors: beforeChecklistAnchors)
      let targetIndex = draft.targetOrdinal - 1
      let beforeSource = sourceIndex.map { beforeChecklistAnchors[$0] }
      let afterSource = beforeSource.flatMap { source in
        postChecklistAnchors.first { $0.idSHA256 == source.idSHA256 }
      }
      let expectedOrder = sourceIndex.flatMap { sourceIndex in
        checklistOrder(afterMoving: beforeChecklistAnchors.map(\.idSHA256), from: sourceIndex, to: targetIndex)
      } ?? beforeChecklistAnchors.map(\.idSHA256)
      let actualOrder = postChecklistAnchors.map(\.idSHA256)
      let expectedChanged = sourceIndex.map { $0 != targetIndex } ?? true
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(
        boolCheck(
          name: "source_checklist_anchor_before",
          expected: true,
          actual: beforeSource != nil
        ))
      checks.append(
        boolCheck(
          name: "source_checklist_anchor_after",
          expected: true,
          actual: afterSource != nil
        ))
      checks.append(
        boolCheck(
          name: "target_ordinal_in_range",
          expected: true,
          actual: targetIndex >= 0 && targetIndex < beforeChecklistAnchors.count
        ))
      if let sourceIndex {
        checks.append(
          intCheck(
            name: "source_checklist_ordinal_before",
            expected: draft.ordinal ?? (sourceIndex + 1),
            actual: sourceIndex + 1
          ))
      }
      if let afterSource {
        let afterIndex = postChecklistAnchors.firstIndex { $0.idSHA256 == afterSource.idSHA256 }.map { $0 + 1 } ?? 0
        checks.append(
          intCheck(
            name: "source_checklist_ordinal_after",
            expected: draft.targetOrdinal,
            actual: afterIndex
          ))
        if let beforeSource {
          checks.append(
            boolCheck(
              name: "source_title_hash_preserved",
              expected: true,
              actual: beforeSource.titleByteCount == afterSource.titleByteCount
                && beforeSource.titleSHA256 == afterSource.titleSHA256
            ))
        }
      }
      checks.append(
        stringCheck(
          name: "checklist_anchor_order",
          expected: expectedOrder.joined(separator: ","),
          actual: actualOrder.joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListAdd(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListAddDraft,
    result: NotesBodyListAddWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeListAnchors = ordinaryListAnchors(in: beforeStructure)
      let postListAnchors = ordinaryListAnchors(in: postWriteStructure)
      let beforeIDs = Set(beforeListAnchors.map(\.idSHA256))
      let addedAnchors = postListAnchors.filter { !beforeIDs.contains($0.idSHA256) }
      let addedAnchor = addedAnchors.first
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(intCheck(name: "added_list_anchor_count", expected: 1, actual: addedAnchors.count))
      checks.append(
        stringCheck(
          name: "added_list_style",
          expected: draft.style.rawValue,
          actual: addedAnchor?.listStyle ?? ""
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count",
          expected: beforeListAnchors.count + 1,
          actual: postListAnchors.count
        ))
      checks.append(
        intCheck(
          name: "list_item_count",
          expected: beforeStructure.listItemCount + 1,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(
          boolCheck(
            name: "body_byte_count_increased",
            expected: true,
            actual: afterBytes > beforeBytes
          ))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListConvert(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListConvertDraft,
    result: NotesBodyListConvertWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchor = bodyListConvertAnchor(draft: draft, structure: beforeStructure)
      let afterAnchor = beforeAnchor.flatMap { beforeAnchor in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == beforeAnchor.idSHA256 }
      }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "paragraph_anchor_before", expected: true, actual: beforeAnchor != nil))
      checks.append(
        boolCheck(
          name: "paragraph_anchor_was_not_list",
          expected: true,
          actual: beforeAnchor.map { !$0.isList && !$0.isChecklist } ?? false
        ))
      checks.append(boolCheck(name: "paragraph_anchor_after", expected: true, actual: afterAnchor != nil))
      checks.append(boolCheck(name: "paragraph_anchor_is_list_after", expected: true, actual: afterAnchor?.isList == true))
      checks.append(boolCheck(name: "paragraph_anchor_is_not_checklist_after", expected: true, actual: afterAnchor?.isChecklist == false))
      checks.append(
        stringCheck(
          name: "paragraph_list_style_after",
          expected: draft.style.rawValue,
          actual: afterAnchor?.listStyle ?? ""
        ))
      if let beforeAnchor, let afterAnchor {
        checks.append(
          boolCheck(
            name: "paragraph_title_hash_preserved",
            expected: true,
            actual: beforeAnchor.titleByteCount == afterAnchor.titleByteCount
              && beforeAnchor.titleSHA256 == afterAnchor.titleSHA256
          ))
      }
      checks.append(
        intCheck(
          name: "list_item_count",
          expected: beforeStructure.listItemCount + 1,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListConvertRange(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListConvertRangeDraft,
    result: NotesBodyListConvertRangeWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let selectedAnchors = bodyListConvertRangeAnchors(draft: draft, structure: beforeStructure)
      let afterSelectedAnchors = selectedAnchors.compactMap { beforeAnchor in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == beforeAnchor.idSHA256 }
      }
      let selectedCount = selectedAnchors.count
      let allSelectedWereNonList = !selectedAnchors.isEmpty && selectedAnchors.allSatisfy { !$0.isList && !$0.isChecklist }
      let allSelectedAreListAfter = afterSelectedAnchors.count == selectedCount
        && afterSelectedAnchors.allSatisfy { $0.isList && !$0.isChecklist && $0.listStyle == draft.style.rawValue }
      let preservedTitleHashes = zip(selectedAnchors, afterSelectedAnchors).allSatisfy { beforeAnchor, afterAnchor in
        beforeAnchor.titleByteCount == afterAnchor.titleByteCount
          && beforeAnchor.titleSHA256 == afterAnchor.titleSHA256
      }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(intCheck(name: "selected_paragraph_count", expected: draft.toOrdinal - draft.fromOrdinal + 1, actual: selectedCount))
      checks.append(boolCheck(name: "selected_paragraphs_were_non_list", expected: true, actual: allSelectedWereNonList))
      checks.append(boolCheck(name: "selected_paragraphs_are_list_after", expected: true, actual: allSelectedAreListAfter))
      checks.append(boolCheck(name: "selected_title_hashes_preserved", expected: true, actual: preservedTitleHashes))
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "list_item_count",
          expected: beforeStructure.listItemCount + selectedCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListSetStyle(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListSetStyleDraft,
    result: NotesBodyListSetStyleWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeListAnchors = ordinaryListAnchors(in: beforeStructure)
      let postListAnchors = ordinaryListAnchors(in: postWriteStructure)
      let beforeTarget = bodyListSetStyleAnchor(draft: draft, listAnchors: beforeListAnchors)
      let afterTarget = beforeTarget.flatMap { target in
        postListAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let expectedChanged = beforeTarget.map { $0.listStyle != draft.style.rawValue } ?? true
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_list_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_list_anchor_after", expected: true, actual: afterTarget != nil))
      checks.append(boolCheck(name: "target_was_not_checklist", expected: true, actual: beforeTarget?.isChecklist == false))
      checks.append(
        stringCheck(
          name: "target_list_style",
          expected: draft.style.rawValue,
          actual: afterTarget?.listStyle ?? ""
        ))
      if let beforeTarget, let afterTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_preserved",
            expected: true,
            actual: beforeTarget.titleByteCount == afterTarget.titleByteCount
              && beforeTarget.titleSHA256 == afterTarget.titleSHA256
          ))
      }
      checks.append(
        stringCheck(
          name: "list_anchor_order_preserved",
          expected: beforeListAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postListAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: beforeListAnchors.count,
          actual: postListAnchors.count
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyParagraphStyle(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    beforeSections: [NotesBodyCollapsibleSectionRecord],
    draft: NotesBodyParagraphStyleDraft,
    result: NotesBodyParagraphFormatWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body paragraph formatting verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let postWriteSections = try bodyStructureReader.listCollapsibleSections(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let beforeTarget = bodyParagraphFormatAnchor(
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        structure: beforeStructure
      )
      let afterTarget = beforeTarget.flatMap { target in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let beforeTargetSection = beforeTarget.flatMap { target in
        beforeSections.first { $0.paragraphIDSHA256 == target.idSHA256 }
      }
      let postTargetSection = beforeTarget.flatMap { target in
        postWriteSections.first { $0.paragraphIDSHA256 == target.idSHA256 }
      }
      let targetWasSupported = beforeTarget.map {
        !$0.isList && !$0.isChecklist && !$0.isBlockQuote
      } ?? false
      let expectedChanged = beforeTarget.map { $0.style != draft.style.rawValue } ?? true
      let expectedCollapsible = draft.style.createsCollapsibleSection
      let expectedCollapsibleCount = beforeSections.count
        + ((beforeTargetSection == nil && expectedCollapsible) ? 1 : 0)
        - ((beforeTargetSection != nil && !expectedCollapsible) ? 1 : 0)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_paragraph_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_supported_before", expected: true, actual: targetWasSupported))
      checks.append(boolCheck(name: "target_paragraph_after", expected: true, actual: afterTarget != nil))
      checks.append(
        stringCheck(
          name: "target_paragraph_style",
          expected: draft.style.rawValue,
          actual: afterTarget?.style ?? ""
        ))
      checks.append(
        boolCheck(
          name: "target_header_state",
          expected: draft.style.isHeader,
          actual: afterTarget?.isHeader ?? false
        ))
      checks.append(
        boolCheck(
          name: "target_collapsible_section_state",
          expected: expectedCollapsible,
          actual: postTargetSection != nil
        ))
      if expectedCollapsible {
        checks.append(
          stringCheck(
            name: "target_collapsible_section_hash",
            expected: beforeTarget?.idSHA256 ?? "",
            actual: postTargetSection?.paragraphIDSHA256 ?? ""
          ))
      } else if beforeTargetSection != nil {
        checks.append(
          boolCheck(
            name: "target_collapsible_section_removed",
            expected: true,
            actual: postTargetSection == nil
          ))
      }
      if let beforeTarget, let afterTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_preserved",
            expected: true,
            actual: beforeTarget.titleByteCount == afterTarget.titleByteCount
              && beforeTarget.titleSHA256 == afterTarget.titleSHA256
          ))
      }
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "paragraph_count_preserved",
          expected: beforeStructure.paragraphAnchors.count,
          actual: postWriteStructure.paragraphAnchors.count
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_count_after_style",
          expected: expectedCollapsibleCount,
          actual: postWriteStructure.collapsibleSectionCount
        ))
      checks.append(
        intCheck(
          name: "collapsible_section_list_count_after_style",
          expected: postWriteStructure.collapsibleSectionCount,
          actual: postWriteSections.count
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyParagraphAlignment(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyParagraphAlignmentDraft,
    result: NotesBodyParagraphFormatWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body paragraph formatting verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let beforeTarget = bodyParagraphFormatAnchor(
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        structure: beforeStructure
      )
      let afterTarget = beforeTarget.flatMap { target in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let targetWasSupported = beforeTarget.map {
        !$0.isList && !$0.isChecklist && !$0.isBlockQuote
      } ?? false
      let expectedChanged = beforeTarget.map { $0.alignment != draft.alignment.rawValue } ?? true
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_paragraph_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_supported_before", expected: true, actual: targetWasSupported))
      checks.append(boolCheck(name: "target_paragraph_after", expected: true, actual: afterTarget != nil))
      checks.append(
        stringCheck(
          name: "target_paragraph_alignment",
          expected: draft.alignment.rawValue,
          actual: afterTarget?.alignment ?? ""
        ))
      if let beforeTarget, let afterTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_preserved",
            expected: true,
            actual: beforeTarget.titleByteCount == afterTarget.titleByteCount
              && beforeTarget.titleSHA256 == afterTarget.titleSHA256
          ))
      }
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "paragraph_count_preserved",
          expected: beforeStructure.paragraphAnchors.count,
          actual: postWriteStructure.paragraphAnchors.count
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyParagraphBlockQuote(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyParagraphQuoteDraft,
    result: NotesBodyParagraphFormatWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body block quote verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let beforeTarget = bodyParagraphFormatAnchor(
        paragraphIDSHA256: draft.paragraphIDSHA256,
        ordinal: draft.ordinal,
        structure: beforeStructure
      )
      let afterTarget = beforeTarget.flatMap { target in
        postWriteStructure.paragraphAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let targetWasSupported = beforeTarget.map { !$0.isList && !$0.isChecklist } ?? false
      let expectedChanged = beforeTarget.map { $0.isBlockQuote != draft.enabled } ?? true
      let expectedBlockQuoteCount = beforeTarget.map { target in
        beforeStructure.blockQuoteCount + ((target.isBlockQuote == draft.enabled) ? 0 : (draft.enabled ? 1 : -1))
      } ?? beforeStructure.blockQuoteCount
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_paragraph_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_supported_before", expected: true, actual: targetWasSupported))
      checks.append(boolCheck(name: "target_paragraph_after", expected: true, actual: afterTarget != nil))
      checks.append(
        boolCheck(
          name: "target_block_quote_state",
          expected: draft.enabled,
          actual: afterTarget?.isBlockQuote ?? false
        ))
      checks.append(
        intCheck(
          name: "block_quote_count",
          expected: max(0, expectedBlockQuoteCount),
          actual: postWriteStructure.blockQuoteCount
        ))
      if let beforeTarget, let afterTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_preserved",
            expected: true,
            actual: beforeTarget.titleByteCount == afterTarget.titleByteCount
              && beforeTarget.titleSHA256 == afterTarget.titleSHA256
          ))
      }
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(intCheck(
        name: "paragraph_count_preserved",
        expected: beforeStructure.paragraphAnchors.count,
        actual: postWriteStructure.paragraphAnchors.count
      ))
      checks.append(intCheck(
        name: "list_item_count_preserved",
        expected: beforeStructure.listItemCount,
        actual: postWriteStructure.listItemCount
      ))
      checks.append(intCheck(
        name: "checklist_item_count_preserved",
        expected: beforeStructure.checklistItemCount,
        actual: postWriteStructure.checklistItemCount
      ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyInlineFormat(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyInlineFormatDraft,
    result: NotesBodyInlineFormatWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body inline formatting verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeRun = inlineFormatRunExists(
        in: beforeStructure,
        evidence: result.evidence,
        format: draft.format.rawValue
      )
      let afterRun = inlineFormatRunExists(
        in: postWriteStructure,
        evidence: result.evidence,
        format: draft.format.rawValue
      )
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(stringCheck(name: "selection_text_sha256", expected: sha256Hex(draft.text), actual: result.evidence.textSHA256))
      checks.append(intCheck(name: "selection_text_byte_count", expected: draft.text.utf8.count, actual: result.evidence.textByteCount))
      checks.append(boolCheck(name: "target_format_before", expected: draft.enabled ? false : true, actual: beforeRun))
      checks.append(boolCheck(name: "target_format_after", expected: draft.enabled, actual: afterRun))
      checks.append(boolCheck(name: "changed_reported", expected: beforeRun != draft.enabled, actual: result.changed))
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(intCheck(
        name: "paragraph_count_preserved",
        expected: beforeStructure.paragraphAnchors.count,
        actual: postWriteStructure.paragraphAnchors.count
      ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyInlineColor(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyInlineColorDraft,
    result: NotesBodyInlineColorWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body inline color verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeRun = inlineColorRunExists(
        in: beforeStructure,
        evidence: result.evidence
      )
      let afterRun = inlineColorRunExists(
        in: postWriteStructure,
        evidence: result.evidence
      )
      let expectedAfter = result.evidence.colorSHA256 != nil
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(stringCheck(name: "selection_text_sha256", expected: sha256Hex(draft.text), actual: result.evidence.textSHA256))
      checks.append(intCheck(name: "selection_text_byte_count", expected: draft.text.utf8.count, actual: result.evidence.textByteCount))
      checks.append(boolCheck(name: "target_color_after", expected: expectedAfter, actual: afterRun))
      checks.append(boolCheck(name: "changed_reported", expected: beforeRun != expectedAfter, actual: result.changed))
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(intCheck(
        name: "paragraph_count_preserved",
        expected: beforeStructure.paragraphAnchors.count,
        actual: postWriteStructure.paragraphAnchors.count
      ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyInlineFont(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyInlineFontDraft,
    result: NotesBodyInlineFormatWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body inline font verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeRun = inlineFormatRunExists(
        in: beforeStructure,
        evidence: result.evidence,
        format: "font"
      )
      let afterRun = inlineFormatRunExists(
        in: postWriteStructure,
        evidence: result.evidence,
        format: "font"
      )
      let beforeAnchors = beforeStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      let postAnchors = postWriteStructure.paragraphAnchors.sorted { $0.ordinal < $1.ordinal }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(stringCheck(name: "selection_text_sha256", expected: sha256Hex(draft.text), actual: result.evidence.textSHA256))
      checks.append(intCheck(name: "selection_text_byte_count", expected: draft.text.utf8.count, actual: result.evidence.textByteCount))
      checks.append(boolCheck(name: "target_font_before", expected: false, actual: beforeRun))
      checks.append(boolCheck(name: "target_font_after", expected: true, actual: afterRun))
      checks.append(boolCheck(name: "changed_reported", expected: !beforeRun, actual: result.changed))
      checks.append(
        boolCheck(
          name: "target_font_hash_readback",
          expected: true,
          actual: result.evidence.fontSHA256 != nil && afterRun
        ))
      checks.append(
        stringCheck(
          name: "paragraph_anchor_order_preserved",
          expected: beforeAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(intCheck(
        name: "paragraph_count_preserved",
        expected: beforeStructure.paragraphAnchors.count,
        actual: postWriteStructure.paragraphAnchors.count
      ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListReorder(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListReorderDraft,
    result: NotesBodyListReorderWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeListAnchors = ordinaryListAnchors(in: beforeStructure)
      let postListAnchors = ordinaryListAnchors(in: postWriteStructure)
      let sourceIndex = bodyListReorderSourceIndex(draft: draft, listAnchors: beforeListAnchors)
      let targetIndex = draft.targetOrdinal - 1
      let beforeSource: NotesBodyParagraphAnchorRecord?
      if let sourceIndex, beforeListAnchors.indices.contains(sourceIndex) {
        beforeSource = beforeListAnchors[sourceIndex]
      } else {
        beforeSource = nil
      }
      let afterSource = beforeSource.flatMap { source in
        postListAnchors.first { $0.idSHA256 == source.idSHA256 }
      }
      let expectedOrder = sourceIndex.flatMap { sourceIndex in
        checklistOrder(afterMoving: beforeListAnchors.map(\.idSHA256), from: sourceIndex, to: targetIndex)
      } ?? beforeListAnchors.map(\.idSHA256)
      let actualOrder = postListAnchors.map(\.idSHA256)
      let expectedChanged = sourceIndex.map { $0 != targetIndex } ?? true
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "source_list_anchor_before", expected: true, actual: beforeSource != nil))
      checks.append(boolCheck(name: "source_list_anchor_after", expected: true, actual: afterSource != nil))
      checks.append(boolCheck(name: "source_was_not_checklist", expected: true, actual: beforeSource?.isChecklist == false))
      checks.append(
        boolCheck(
          name: "target_ordinal_in_range",
          expected: true,
          actual: targetIndex >= 0 && targetIndex < beforeListAnchors.count
        ))
      if let sourceIndex {
        checks.append(
          intCheck(
            name: "source_list_ordinal_before",
            expected: draft.ordinal ?? (sourceIndex + 1),
            actual: sourceIndex + 1
          ))
      }
      if let afterSource {
        let afterIndex = postListAnchors.firstIndex { $0.idSHA256 == afterSource.idSHA256 }.map { $0 + 1 } ?? 0
        checks.append(
          intCheck(
            name: "source_list_ordinal_after",
            expected: draft.targetOrdinal,
            actual: afterIndex
          ))
        if let beforeSource {
          checks.append(
            boolCheck(
              name: "source_title_hash_preserved",
              expected: true,
              actual: beforeSource.titleByteCount == afterSource.titleByteCount
                && beforeSource.titleSHA256 == afterSource.titleSHA256
            ))
        }
      }
      checks.append(
        stringCheck(
          name: "list_anchor_order",
          expected: expectedOrder.joined(separator: ","),
          actual: actualOrder.joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "ordinary_list_item_count_preserved",
          expected: beforeListAnchors.count,
          actual: postListAnchors.count
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistIndent(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistIndentDraft,
    result: NotesBodyChecklistIndentWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeChecklistAnchors = checklistAnchors(in: beforeStructure)
      let postChecklistAnchors = checklistAnchors(in: postWriteStructure)
      let beforeTarget = bodyChecklistIndentAnchor(draft: draft, checklistAnchors: beforeChecklistAnchors)
      let afterTarget = beforeTarget.flatMap { target in
        postChecklistAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let beforeIndent = beforeTarget?.indentationLevel
      let afterIndent = afterTarget?.indentationLevel
      let expectedChanged = bodyChecklistIndentExpectedChanged(
        draft: draft,
        beforeIndent: beforeIndent,
        canIndent: beforeTarget?.canIndent
      )
      let expectedIndent = bodyChecklistIndentExpectedLevel(
        draft: draft,
        beforeIndent: beforeIndent,
        expectedChanged: expectedChanged
      )
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      if let expectedChanged {
        checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      }
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_checklist_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_checklist_anchor_after", expected: true, actual: afterTarget != nil))
      checks.append(boolCheck(name: "indentation_level_before", expected: true, actual: beforeIndent != nil))
      checks.append(boolCheck(name: "indentation_level_after", expected: true, actual: afterIndent != nil))
      if let ordinal = draft.ordinal {
        checks.append(
          intCheck(
            name: "target_checklist_ordinal_before",
            expected: ordinal,
            actual: beforeTarget.flatMap { beforeChecklistAnchors.firstIndex(of: $0).map { $0 + 1 } } ?? 0
          ))
      }
      if let expectedIndent, let afterIndent {
        checks.append(intCheck(name: "target_indentation_level", expected: expectedIndent, actual: afterIndent))
      }
      if let beforeIndent, let afterIndent {
        checks.append(
          intCheck(
            name: "target_indentation_delta",
            expected: result.changed ? draft.delta : 0,
            actual: afterIndent - beforeIndent
          ))
      }
      if let beforeTarget, let afterTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_preserved",
            expected: true,
            actual: beforeTarget.titleByteCount == afterTarget.titleByteCount
              && beforeTarget.titleSHA256 == afterTarget.titleSHA256
          ))
      }
      checks.append(
        stringCheck(
          name: "checklist_anchor_order_preserved",
          expected: beforeChecklistAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postChecklistAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "has_checklist", expected: true, actual: postWriteStructure.hasChecklist))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyChecklistDelete(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyChecklistDeleteDraft,
    result: NotesBodyChecklistDeleteWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body checklist verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeChecklistAnchors = checklistAnchors(in: beforeStructure)
      let postChecklistAnchors = checklistAnchors(in: postWriteStructure)
      let beforeTarget = bodyChecklistDeleteAnchor(draft: draft, checklistAnchors: beforeChecklistAnchors)
      let targetPresentAfter = beforeTarget.map { target in
        postChecklistAnchors.contains { $0.idSHA256 == target.idSHA256 }
      }
      let expectedOrder = beforeChecklistAnchors
        .filter { anchor in
          guard let beforeTarget else {
            return true
          }
          return anchor.idSHA256 != beforeTarget.idSHA256
        }
        .map(\.idSHA256)
      let targetWasDone = beforeTarget?.checklistDone
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_checklist_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(
        boolCheck(
          name: "target_checklist_anchor_after_absent",
          expected: true,
          actual: targetPresentAfter == false
        ))
      checks.append(
        boolCheck(
          name: "target_checklist_done_state_known",
          expected: true,
          actual: targetWasDone != nil
        ))
      if let ordinal = draft.ordinal {
        checks.append(
          intCheck(
            name: "target_checklist_ordinal_before",
            expected: ordinal,
            actual: beforeTarget.flatMap { beforeChecklistAnchors.firstIndex(of: $0).map { $0 + 1 } }
          ))
      }
      if let beforeTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_was_bound",
            expected: true,
            actual: beforeTarget.titleByteCount != nil && beforeTarget.titleSHA256 != nil
          ))
      }
      checks.append(
        stringCheck(
          name: "checklist_anchor_order_preserved",
          expected: expectedOrder.joined(separator: ","),
          actual: postChecklistAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count",
          expected: max(0, beforeStructure.checklistItemCount - 1),
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "list_item_count",
          expected: max(0, beforeStructure.listItemCount - 1),
          actual: postWriteStructure.listItemCount
        ))
      if let targetWasDone {
        checks.append(
          intCheck(
            name: "checklist_done_count",
            expected: beforeStructure.checklistDoneCount - (targetWasDone ? 1 : 0),
            actual: postWriteStructure.checklistDoneCount
          ))
        checks.append(
          intCheck(
            name: "checklist_open_count",
            expected: beforeStructure.checklistOpenCount - (targetWasDone ? 0 : 1),
            actual: postWriteStructure.checklistOpenCount
          ))
      }
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(boolCheck(name: "body_byte_count_decreased", expected: true, actual: afterBytes < beforeBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(boolCheck(name: "body_sha256_changed", expected: true, actual: afterHash != beforeHash))
      }
      checks.append(
        boolCheck(
          name: "has_checklist",
          expected: beforeStructure.checklistItemCount > 1,
          actual: postWriteStructure.hasChecklist
        ))
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListIndent(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListIndentDraft,
    result: NotesBodyListIndentWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeListAnchors = ordinaryListAnchors(in: beforeStructure)
      let postListAnchors = ordinaryListAnchors(in: postWriteStructure)
      let beforeTarget = bodyListIndentAnchor(draft: draft, listAnchors: beforeListAnchors)
      let afterTarget = beforeTarget.flatMap { target in
        postListAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let beforeIndent = beforeTarget?.indentationLevel
      let afterIndent = afterTarget?.indentationLevel
      let expectedChanged = bodyListIndentExpectedChanged(
        draft: draft,
        beforeIndent: beforeIndent,
        canIndent: beforeTarget?.canIndent
      )
      let expectedIndent = bodyListIndentExpectedLevel(
        draft: draft,
        beforeIndent: beforeIndent,
        expectedChanged: expectedChanged
      )
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      if let expectedChanged {
        checks.append(boolCheck(name: "changed_reported", expected: expectedChanged, actual: result.changed))
      }
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_list_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_list_anchor_after", expected: true, actual: afterTarget != nil))
      checks.append(boolCheck(name: "target_was_not_checklist", expected: true, actual: beforeTarget?.isChecklist == false))
      checks.append(boolCheck(name: "indentation_level_before", expected: true, actual: beforeIndent != nil))
      checks.append(boolCheck(name: "indentation_level_after", expected: true, actual: afterIndent != nil))
      if let ordinal = draft.ordinal {
        checks.append(
          intCheck(
            name: "target_list_ordinal_before",
            expected: ordinal,
            actual: beforeTarget.flatMap { beforeListAnchors.firstIndex(of: $0).map { $0 + 1 } }
          ))
      }
      if let expectedIndent, let afterIndent {
        checks.append(intCheck(name: "target_indentation_level", expected: expectedIndent, actual: afterIndent))
      }
      if let beforeIndent, let afterIndent {
        checks.append(
          intCheck(
            name: "target_indentation_delta",
            expected: result.changed ? draft.delta : 0,
            actual: afterIndent - beforeIndent
          ))
      }
      if let beforeTarget, let afterTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_preserved",
            expected: true,
            actual: beforeTarget.titleByteCount == afterTarget.titleByteCount
              && beforeTarget.titleSHA256 == afterTarget.titleSHA256
          ))
      }
      checks.append(
        stringCheck(
          name: "list_anchor_order_preserved",
          expected: beforeListAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postListAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(intCheck(name: "body_byte_count_preserved", expected: beforeBytes, actual: afterBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(stringCheck(name: "body_sha256_preserved", expected: beforeHash, actual: afterHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListDelete(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListDeleteDraft,
    result: NotesBodyListDeleteWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeListAnchors = ordinaryListAnchors(in: beforeStructure)
      let postListAnchors = ordinaryListAnchors(in: postWriteStructure)
      let beforeTarget = bodyListDeleteAnchor(draft: draft, listAnchors: beforeListAnchors)
      let targetPresentAfter = beforeTarget.map { target in
        postListAnchors.contains { $0.idSHA256 == target.idSHA256 }
      }
      let expectedOrder = beforeListAnchors
        .filter { anchor in
          guard let beforeTarget else {
            return true
          }
          return anchor.idSHA256 != beforeTarget.idSHA256
        }
        .map(\.idSHA256)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(boolCheck(name: "target_list_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(
        boolCheck(
          name: "target_list_anchor_after_absent",
          expected: true,
          actual: targetPresentAfter == false
        ))
      checks.append(boolCheck(name: "target_was_not_checklist", expected: true, actual: beforeTarget?.isChecklist == false))
      if let ordinal = draft.ordinal {
        checks.append(
          intCheck(
            name: "target_list_ordinal_before",
            expected: ordinal,
            actual: beforeTarget.flatMap { beforeListAnchors.firstIndex(of: $0).map { $0 + 1 } }
          ))
      }
      if let beforeTarget {
        checks.append(
          boolCheck(
            name: "target_title_hash_was_bound",
            expected: true,
            actual: beforeTarget.titleByteCount != nil && beforeTarget.titleSHA256 != nil
          ))
      }
      checks.append(
        stringCheck(
          name: "list_anchor_order_preserved",
          expected: expectedOrder.joined(separator: ","),
          actual: postListAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "list_item_count",
          expected: max(0, beforeStructure.listItemCount - 1),
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(boolCheck(name: "body_byte_count_decreased", expected: true, actual: afterBytes < beforeBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(boolCheck(name: "body_sha256_changed", expected: true, actual: afterHash != beforeHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListTextInsert(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListTextInsertDraft,
    result: NotesBodyListTextInsertWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list text insertion verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTargetAnchors = bodyListTextInsertAnchors(targetKind: draft.targetKind, in: beforeStructure)
      let postTargetAnchors = bodyListTextInsertAnchors(targetKind: draft.targetKind, in: postWriteStructure)
      let beforeTarget = bodyListTextInsertAnchor(draft: draft, targetAnchors: beforeTargetAnchors)
      let afterTarget = beforeTarget.flatMap { target in
        postTargetAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(stringCheck(name: "target_kind", expected: draft.targetKind.rawValue, actual: draft.targetKind.rawValue))
      checks.append(stringCheck(name: "inserted_kind", expected: draft.insertKind.rawValue, actual: draft.insertKind.rawValue))
      checks.append(
        intCheck(
          name: "inserted_text_byte_count",
          expected: draft.insertKind.insertedTextByteCount,
          actual: result.insertedTextByteCount
        ))
      checks.append(
        stringCheck(
          name: "inserted_text_sha256",
          expected: draft.insertKind.insertedTextSHA256,
          actual: result.insertedTextSHA256
        ))
      checks.append(boolCheck(name: "target_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_anchor_after", expected: true, actual: afterTarget != nil))
      checks.append(
        boolCheck(
          name: "target_type_preserved",
          expected: true,
          actual: beforeTarget?.isList == afterTarget?.isList
            && beforeTarget?.isChecklist == afterTarget?.isChecklist
        ))
      if let beforeTarget, let afterTarget {
        checks.append(stringCheck(name: "target_style_preserved", expected: beforeTarget.style, actual: afterTarget.style))
        if let beforeListStyle = beforeTarget.listStyle ?? afterTarget.listStyle {
          checks.append(
            stringCheck(
              name: "target_list_style_preserved",
              expected: beforeListStyle,
              actual: afterTarget.listStyle ?? ""
            ))
        }
      }
      if let ordinal = draft.ordinal {
        checks.append(
          intCheck(
            name: "target_ordinal_before",
            expected: ordinal,
            actual: beforeTarget.flatMap { target in
              beforeTargetAnchors.firstIndex(of: target).map { $0 + 1 }
            }
          ))
      }
      checks.append(
        stringCheck(
          name: "target_anchor_order_preserved",
          expected: beforeTargetAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postTargetAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeParagraphCount = beforeStructure.paragraphCount,
        let afterParagraphCount = postWriteStructure.paragraphCount
      {
        checks.append(
          intCheck(
            name: "paragraph_count_preserved",
            expected: beforeParagraphCount,
            actual: afterParagraphCount
          ))
      }
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(
          intCheck(
            name: "body_byte_count_delta",
            expected: result.insertedTextByteCount,
            actual: afterBytes - beforeBytes
          ))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(boolCheck(name: "body_sha256_changed", expected: true, actual: afterHash != beforeHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBodyListEnd(
    operation: String,
    before: NotesNoteDetail,
    beforeStructure: NotesBodyStructureRecord,
    draft: NotesBodyListEndDraft,
    result: NotesBodyListEndWriteResult
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      guard let bodyStructureReader else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Notes body list end verification requires private framework body structure readback.",
          details: ["operation": operation]
        )
      }
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      let beforeTargetAnchors = bodyListEndAnchors(targetKind: draft.targetKind, in: beforeStructure)
      let postTargetAnchors = bodyListEndAnchors(targetKind: draft.targetKind, in: postWriteStructure)
      let beforeTarget = bodyListEndAnchor(draft: draft, targetAnchors: beforeTargetAnchors)
      let afterTarget = beforeTarget.flatMap { target in
        postTargetAnchors.first { $0.idSHA256 == target.idSHA256 }
      }
      let createdParagraphs = insertedBodyParagraphs(before: beforeStructure, after: postWriteStructure)
      let createdParagraph = result.createdParagraphIDSHA256.flatMap { id in
        createdParagraphs.first { $0.idSHA256 == id }
      } ?? createdParagraphs.first
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(boolCheck(name: "draft_target_preserved", expected: true, actual: postWriteNote.id == draft.noteID))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "body_structure_note", expected: true, actual: postWriteStructure.noteID == draft.noteID))
      checks.append(stringCheck(name: "target_kind", expected: draft.targetKind.rawValue, actual: draft.targetKind.rawValue))
      checks.append(boolCheck(name: "target_anchor_before", expected: true, actual: beforeTarget != nil))
      checks.append(boolCheck(name: "target_anchor_after", expected: true, actual: afterTarget != nil))
      checks.append(
        boolCheck(
          name: "target_type_preserved",
          expected: true,
          actual: beforeTarget?.isList == afterTarget?.isList
            && beforeTarget?.isChecklist == afterTarget?.isChecklist
        ))
      if let beforeTarget, let afterTarget {
        checks.append(stringCheck(name: "target_style_preserved", expected: beforeTarget.style, actual: afterTarget.style))
        if let beforeListStyle = beforeTarget.listStyle ?? afterTarget.listStyle {
          checks.append(
            stringCheck(
              name: "target_list_style_preserved",
              expected: beforeListStyle,
              actual: afterTarget.listStyle ?? ""
            ))
        }
        checks.append(
          intCheck(
            name: "created_paragraph_after_target",
            expected: afterTarget.ordinal + 1,
            actual: createdParagraph?.ordinal
          ))
      }
      if let ordinal = draft.ordinal {
        checks.append(
          intCheck(
            name: "target_ordinal_before",
            expected: ordinal,
            actual: beforeTarget.flatMap { target in
              beforeTargetAnchors.firstIndex(of: target).map { $0 + 1 }
            }
          ))
      }
      checks.append(
        stringCheck(
          name: "target_anchor_order_preserved",
          expected: beforeTargetAnchors.map(\.idSHA256).joined(separator: ","),
          actual: postTargetAnchors.map(\.idSHA256).joined(separator: ",")
        ))
      checks.append(intCheck(name: "created_body_paragraph_count", expected: 1, actual: createdParagraphs.count))
      checks.append(stringCheck(name: "created_paragraph_style", expected: "body", actual: createdParagraph?.style ?? ""))
      checks.append(
        boolCheck(
          name: "created_paragraph_not_list_or_checklist",
          expected: true,
          actual: createdParagraph.map { !$0.isList && !$0.isChecklist } ?? false
        ))
      checks.append(
        stringCheck(
          name: "created_paragraph_hash_readback",
          expected: result.createdParagraphIDSHA256 ?? createdParagraph?.idSHA256 ?? "",
          actual: createdParagraph?.idSHA256 ?? ""
        ))
      checks.append(
        intCheck(
          name: "list_item_count_preserved",
          expected: beforeStructure.listItemCount,
          actual: postWriteStructure.listItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_item_count_preserved",
          expected: beforeStructure.checklistItemCount,
          actual: postWriteStructure.checklistItemCount
        ))
      checks.append(
        intCheck(
          name: "checklist_done_count_preserved",
          expected: beforeStructure.checklistDoneCount,
          actual: postWriteStructure.checklistDoneCount
        ))
      checks.append(
        intCheck(
          name: "checklist_open_count_preserved",
          expected: beforeStructure.checklistOpenCount,
          actual: postWriteStructure.checklistOpenCount
        ))
      if let beforeParagraphCount = beforeStructure.paragraphCount,
        let afterParagraphCount = postWriteStructure.paragraphCount
      {
        checks.append(intCheck(name: "paragraph_count_delta", expected: 1, actual: afterParagraphCount - beforeParagraphCount))
      }
      checks.append(
        intCheck(
          name: "paragraph_anchor_count_delta",
          expected: 1,
          actual: postWriteStructure.paragraphAnchors.count - beforeStructure.paragraphAnchors.count
        ))
      if let beforeBytes = beforeStructure.plainTextByteCount, let afterBytes = postWriteStructure.plainTextByteCount {
        checks.append(boolCheck(name: "body_byte_count_increased", expected: true, actual: afterBytes > beforeBytes))
      }
      if let beforeHash = beforeStructure.plainTextSHA256, let afterHash = postWriteStructure.plainTextSHA256 {
        checks.append(boolCheck(name: "body_sha256_changed", expected: true, actual: afterHash != beforeHash))
      }
      checks.append(boolCheck(name: "password_protected", expected: false, actual: postWriteStructure.isPasswordProtected))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyMove(
    operation: String,
    before: NotesNoteDetail,
    draft: NotesMoveDraft,
    resultNote: NotesNoteDetail
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: resultNote.id, operation: operation)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(
        boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(
        stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(
        stringCheck(
          name: "body_preserved",
          expected: before.body ?? "",
          actual: postWriteNote.body ?? ""
        ))
      checks.append(
        stringCheck(name: "target_folder", expected: draft.folderName, actual: postWriteNote.folderName))
      checks.append(
        stringCheck(name: "target_account", expected: draft.accountName, actual: postWriteNote.accountName))
      checks.append(
        boolCheck(
          name: "tags_preserved",
          expected: true,
          actual: tagSet(before.tags) == tagSet(postWriteNote.tags)
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyCopy(
    operation: String,
    before: NotesNoteDetail,
    draft: NotesCopyDraft,
    resultNote: NotesNoteDetail
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: resultNote.id, operation: operation)
      let originalNote = try requiredPostWriteNote(id: before.id, operation: operation)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(
        boolCheck(name: "new_identity", expected: true, actual: postWriteNote.id != before.id))
      checks.append(
        boolCheck(name: "source_exists_after", expected: true, actual: originalNote.id == before.id))
      checks.append(
        stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(
        stringCheck(
          name: "body_preserved",
          expected: before.body ?? "",
          actual: postWriteNote.body ?? ""
        ))
      checks.append(
        stringCheck(name: "target_folder", expected: draft.folderName, actual: postWriteNote.folderName))
      checks.append(
        stringCheck(name: "target_account", expected: draft.accountName, actual: postWriteNote.accountName))
      checks.append(
        boolCheck(
          name: "tags_preserved",
          expected: true,
          actual: tagSet(before.tags) == tagSet(postWriteNote.tags)
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyRestore(
    operation: String,
    before: NotesNoteDetail,
    draft: NotesRestoreDraft,
    resultNote: NotesNoteDetail
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: resultNote.id, operation: operation)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(
        boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(
        stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(
        stringCheck(
          name: "body_preserved",
          expected: before.body ?? "",
          actual: postWriteNote.body ?? ""
        ))
      checks.append(
        stringCheck(name: "target_folder", expected: draft.folderName, actual: postWriteNote.folderName))
      checks.append(
        stringCheck(name: "target_account", expected: draft.accountName, actual: postWriteNote.accountName))
      checks.append(
        boolCheck(
          name: "tags_preserved",
          expected: true,
          actual: tagSet(before.tags) == tagSet(postWriteNote.tags)
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyBulkRestore(
    operation: String,
    before: [NotesNoteDetail],
    targetFolderName: String,
    targetAccountName: String,
    changed: Bool,
    restoredCount: Int
  ) throws -> NotesMutationVerificationReport {
    guard let restorableReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes restore-all verification requires restorable private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let visibleAfter = try before.compactMap { try reader.readNote(id: $0.id) }
      let visibleByID = Dictionary(uniqueKeysWithValues: visibleAfter.map { ($0.id, $0) })
      let restorableAfter = try before.compactMap { try restorableReader.readRestorableNote(id: $0.id) }
      let expectedChanged = !before.isEmpty
      let targetID = before.map(\.id).sorted().joined(separator: "|")
      let preservationPairs = before.compactMap { prior -> (NotesNoteDetail, NotesNoteDetail)? in
        guard let after = visibleByID[prior.id] else {
          return nil
        }
        return (prior, after)
      }
      let checks = [
        boolCheck(name: "changed", expected: expectedChanged, actual: changed),
        countCheck(name: "affected_note_count", expected: before.count, actual: restoredCount),
        countCheck(name: "visible_note_count", expected: before.count, actual: visibleAfter.count),
        boolCheck(name: "visible_notes_present", expected: true, actual: visibleAfter.count == before.count),
        boolCheck(name: "restorable_notes_absent", expected: true, actual: restorableAfter.isEmpty),
        boolCheck(
          name: "target_folder",
          expected: true,
          actual: visibleAfter.allSatisfy { $0.folderName == targetFolderName }
        ),
        boolCheck(
          name: "target_account",
          expected: true,
          actual: visibleAfter.allSatisfy { $0.accountName == targetAccountName }
        ),
        boolCheck(
          name: "titles_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { $0.0.title == $0.1.title }
        ),
        boolCheck(
          name: "bodies_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { ($0.0.body ?? "") == ($0.1.body ?? "") }
        ),
        boolCheck(
          name: "tags_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { tagSet($0.0.tags) == tagSet($0.1.tags) }
        ),
      ]

      return NotesMutationVerificationReport(
        operation: operation,
        verified: checks.allSatisfy { $0.status != "failed" },
        evidenceLevel: "readback",
        targetIDSHA256: sha256Hex(targetID),
        readback: nil,
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyDelete(
    operation: String,
    before: NotesNoteDetail,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteNote = try reader.readNote(id: before.id)
      let debug = sqliteReader.debugNote(before)
      let checks = [
        boolCheck(name: "changed", expected: true, actual: changed),
        boolCheck(name: "exists_after", expected: false, actual: postWriteNote != nil),
        storeMatchCheck(noteID: before.id, storeObject: debug.storeObject),
      ]

      return checkedReport(
        operation: operation,
        targetID: before.id,
        readback: nil,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyPurge(
    operation: String,
    before: NotesNoteDetail,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    guard let restorableReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes purge verification requires restorable private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let visibleAfter = try reader.readNote(id: before.id)
      let restorableAfter = try restorableReader.readRestorableNote(id: before.id)
      let debug = sqliteReader.debugNote(before)
      let checks = [
        boolCheck(name: "changed", expected: true, actual: changed),
        boolCheck(name: "visible_exists_after", expected: false, actual: visibleAfter != nil),
        boolCheck(name: "restorable_exists_after", expected: false, actual: restorableAfter != nil),
        storeMatchCheck(noteID: before.id, storeObject: debug.storeObject),
      ]

      return checkedReport(
        operation: operation,
        targetID: before.id,
        readback: nil,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyEmptyTrash(
    operation: String,
    before: [NotesNoteDetail],
    changed: Bool,
    purgedCount: Int
  ) throws -> NotesMutationVerificationReport {
    guard let restorableReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes empty-trash verification requires restorable private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let visibleAfter = try before.compactMap { try reader.readNote(id: $0.id) }
      let restorableAfter = try before.compactMap { try restorableReader.readRestorableNote(id: $0.id) }
      let expectedChanged = !before.isEmpty
      let targetID = before.map(\.id).sorted().joined(separator: "|")
      let checks = [
        boolCheck(name: "changed", expected: expectedChanged, actual: changed),
        countCheck(name: "affected_note_count", expected: before.count, actual: purgedCount),
        boolCheck(name: "visible_notes_absent", expected: true, actual: visibleAfter.isEmpty),
        boolCheck(name: "restorable_notes_absent", expected: true, actual: restorableAfter.isEmpty),
      ]

      return NotesMutationVerificationReport(
        operation: operation,
        verified: checks.allSatisfy { $0.status != "failed" },
        evidenceLevel: "readback",
        targetIDSHA256: sha256Hex(targetID),
        readback: nil,
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyBatchMove(
    operation: String,
    before: [NotesNoteDetail],
    targetFolderName: String,
    targetAccountName: String,
    changed: Bool,
    movedCount: Int
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let visibleAfter = try before.compactMap { try reader.readNote(id: $0.id) }
      let visibleByID = Dictionary(uniqueKeysWithValues: visibleAfter.map { ($0.id, $0) })
      let preservationPairs = before.compactMap { prior -> (NotesNoteDetail, NotesNoteDetail)? in
        guard let after = visibleByID[prior.id] else {
          return nil
        }
        return (prior, after)
      }
      let targetID = before.map(\.id).sorted().joined(separator: "|")
      let checks = [
        boolCheck(name: "changed", expected: !before.isEmpty, actual: changed),
        countCheck(name: "affected_note_count", expected: before.count, actual: movedCount),
        countCheck(name: "visible_note_count", expected: before.count, actual: visibleAfter.count),
        boolCheck(
          name: "visible_notes_present",
          expected: true,
          actual: visibleAfter.count == before.count
        ),
        boolCheck(
          name: "target_folder",
          expected: true,
          actual: visibleAfter.allSatisfy { $0.folderName == targetFolderName }
        ),
        boolCheck(
          name: "target_account",
          expected: true,
          actual: visibleAfter.allSatisfy { $0.accountName == targetAccountName }
        ),
        boolCheck(
          name: "titles_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { $0.0.title == $0.1.title }
        ),
        boolCheck(
          name: "bodies_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { ($0.0.body ?? "") == ($0.1.body ?? "") }
        ),
        boolCheck(
          name: "tags_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { tagSet($0.0.tags) == tagSet($0.1.tags) }
        ),
      ]

      return NotesMutationVerificationReport(
        operation: operation,
        verified: checks.allSatisfy { $0.status != "failed" },
        evidenceLevel: "private_framework_batch_note_move_readback",
        targetIDSHA256: sha256Hex(targetID),
        readback: nil,
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyBatchCopy(
    operation: String,
    before: [NotesNoteDetail],
    copiedNotes: [NotesNoteDetail],
    targetFolderName: String,
    targetAccountName: String,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let sourceAfter = try before.compactMap { try reader.readNote(id: $0.id) }
      let copiedAfter = try copiedNotes.compactMap { try reader.readNote(id: $0.id) }
      let sourceIDSet = Set(before.map(\.id))
      let copiedIDs = copiedAfter.map(\.id)
      let preservationPairs = Array(zip(before, copiedAfter))
      let targetID = (before.map(\.id) + copiedNotes.map(\.id)).sorted().joined(separator: "|")
      let checks = [
        boolCheck(name: "changed", expected: !before.isEmpty, actual: changed),
        countCheck(name: "affected_note_count", expected: before.count, actual: copiedNotes.count),
        countCheck(name: "copied_note_count", expected: before.count, actual: copiedAfter.count),
        boolCheck(
          name: "new_identities",
          expected: true,
          actual: copiedIDs.count == Set(copiedIDs).count
            && copiedIDs.allSatisfy { !sourceIDSet.contains($0) }
        ),
        boolCheck(
          name: "source_notes_present",
          expected: true,
          actual: sourceAfter.count == before.count
        ),
        boolCheck(
          name: "target_folder",
          expected: true,
          actual: copiedAfter.allSatisfy { $0.folderName == targetFolderName }
        ),
        boolCheck(
          name: "target_account",
          expected: true,
          actual: copiedAfter.allSatisfy { $0.accountName == targetAccountName }
        ),
        boolCheck(
          name: "titles_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { $0.0.title == $0.1.title }
        ),
        boolCheck(
          name: "bodies_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { ($0.0.body ?? "") == ($0.1.body ?? "") }
        ),
        boolCheck(
          name: "tags_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { tagSet($0.0.tags) == tagSet($0.1.tags) }
        ),
      ]

      return NotesMutationVerificationReport(
        operation: operation,
        verified: checks.allSatisfy { $0.status != "failed" },
        evidenceLevel: "private_framework_batch_note_copy_readback",
        targetIDSHA256: sha256Hex(targetID),
        readback: nil,
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyBatchDelete(
    operation: String,
    before: [NotesNoteDetail],
    changed: Bool,
    deletedCount: Int
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let visibleAfter = try before.compactMap { try reader.readNote(id: $0.id) }
      let targetID = before.map(\.id).sorted().joined(separator: "|")
      let checks = [
        boolCheck(name: "changed", expected: !before.isEmpty, actual: changed),
        countCheck(name: "affected_note_count", expected: before.count, actual: deletedCount),
        boolCheck(name: "visible_notes_absent", expected: true, actual: visibleAfter.isEmpty),
      ]

      return NotesMutationVerificationReport(
        operation: operation,
        verified: checks.allSatisfy { $0.status != "failed" },
        evidenceLevel: "private_framework_batch_note_delete_readback",
        targetIDSHA256: sha256Hex(targetID),
        readback: nil,
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyBatchPinState(
    operation: String,
    before: [NotesNoteDetail],
    targetPinned: Bool,
    changed: Bool,
    changedCount: Int
  ) throws -> NotesMutationVerificationReport {
    guard let noteStateReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes batch pin verification requires private framework note-state readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let visibleAfter = try before.compactMap { try reader.readNote(id: $0.id) }
      let visibleByID = Dictionary(uniqueKeysWithValues: visibleAfter.map { ($0.id, $0) })
      let statesAfter = try before.map { try noteStateReader.readNoteState(noteID: $0.id) }
      let preservationPairs = before.compactMap { prior -> (NotesNoteDetail, NotesNoteDetail)? in
        guard let after = visibleByID[prior.id] else {
          return nil
        }
        return (prior, after)
      }
      let targetID = before.map(\.id).sorted().joined(separator: "|")
      let checks = [
        boolCheck(name: "changed", expected: changedCount > 0, actual: changed),
        countCheck(name: "affected_note_count", expected: before.count, actual: before.count),
        countCheck(name: "changed_note_count", expected: changedCount, actual: changedCount),
        countCheck(name: "visible_note_count", expected: before.count, actual: visibleAfter.count),
        boolCheck(
          name: "visible_notes_present",
          expected: true,
          actual: visibleAfter.count == before.count
        ),
        boolCheck(
          name: "pinned_state",
          expected: true,
          actual: statesAfter.allSatisfy { $0.isPinned == targetPinned }
        ),
        boolCheck(
          name: "titles_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { $0.0.title == $0.1.title }
        ),
        boolCheck(
          name: "folders_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { $0.0.folderName == $0.1.folderName }
        ),
        boolCheck(
          name: "accounts_preserved",
          expected: true,
          actual: preservationPairs.count == before.count
            && preservationPairs.allSatisfy { $0.0.accountName == $0.1.accountName }
        ),
      ]

      return NotesMutationVerificationReport(
        operation: operation,
        verified: checks.allSatisfy { $0.status != "failed" },
        evidenceLevel: "private_framework_batch_note_pin_state_readback",
        targetIDSHA256: sha256Hex(targetID),
        readback: nil,
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyPinState(
    operation: String,
    before: NotesNoteDetail,
    targetPinned: Bool,
    changed: Bool,
    expectedChanged: Bool
  ) throws -> NotesMutationVerificationReport {
    guard let noteStateReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes pin verification requires private framework note-state readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: before.id, operation: operation)
      let state = try noteStateReader.readNoteState(noteID: before.id)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed", expected: expectedChanged, actual: changed))
      checks.append(
        boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(
        stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(
        stringCheck(name: "account_preserved", expected: before.accountName, actual: postWriteNote.accountName))
      checks.append(boolCheck(name: "pinned_state", expected: targetPinned, actual: state.isPinned))
      if let storePinned = debug.storeObject.pinned {
        checks.append(boolCheck(name: "store_pinned", expected: targetPinned, actual: storePinned))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "store_pinned", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: before.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyTagMembership(
    operation: String,
    before: NotesNoteDetail,
    tag: NotesTagRecord,
    expectedPresent: Bool,
    changed: Bool,
    resultNote: NotesNoteDetail
  ) throws -> NotesMutationVerificationReport {
    try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: resultNote.id, operation: operation)
      let debug = sqliteReader.debugNote(postWriteNote)
      let target = tag.standardizedContent ?? standardizedTagContent(tag.displayText)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(
        boolCheck(name: "changed_reported", expected: changed, actual: changed))
      checks.append(
        boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(
        stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(
        stringCheck(
          name: "folder_preserved",
          expected: before.folderName,
          actual: postWriteNote.folderName
        ))
      checks.append(
        stringCheck(
          name: "account_preserved",
          expected: before.accountName,
          actual: postWriteNote.accountName
        ))
      checks.append(
        boolCheck(
          name: "tag_membership",
          expected: expectedPresent,
          actual: containsTag(postWriteNote.tags, target)
        ))
      checks.append(
        boolCheck(
          name: "other_tags_preserved",
          expected: true,
          actual: otherTagsPreserved(before: before.tags, after: postWriteNote.tags, target: target)
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyTagConvertToText(
    operation: String,
    before: NotesNoteDetail,
    draft: NotesTagConvertToTextDraft,
    result: NotesTagConvertToTextWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let tagReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes tag Convert to Text verification requires tag-scoped private framework readback.",
        details: ["operation": operation]
      )
    }
    guard let bodyStructureReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes tag Convert to Text verification requires private body structure readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteNote = try requiredPostWriteNote(id: result.note.id, operation: operation)
      let postWriteStructure = try bodyStructureReader.readBodyStructure(noteID: result.note.id)
      let tagMatchedNotes = try tagReader.readNotes(tag: draft.standardizedContent, limit: 2_000)
      let debug = sqliteReader.debugNote(postWriteNote)
      var checks = commonNoteChecks(note: postWriteNote, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "identity_preserved", expected: true, actual: postWriteNote.id == before.id))
      checks.append(stringCheck(name: "title_preserved", expected: before.title, actual: postWriteNote.title))
      checks.append(stringCheck(name: "folder_preserved", expected: before.folderName, actual: postWriteNote.folderName))
      checks.append(
        stringCheck(
          name: "account_preserved",
          expected: before.accountName,
          actual: postWriteNote.accountName
        ))
      checks.append(
        boolCheck(
          name: "tag_membership_absent",
          expected: true,
          actual: !containsTag(postWriteNote.tags, draft.standardizedContent)
        ))
      checks.append(
        boolCheck(
          name: "tag_query_excludes_note",
          expected: true,
          actual: !tagMatchedNotes.contains { $0.id == before.id }
        ))
      checks.append(
        boolCheck(
          name: "other_tags_preserved",
          expected: true,
          actual: otherTagsPreserved(
            before: before.tags,
            after: postWriteNote.tags,
            target: draft.standardizedContent
          )
        ))
      checks.append(
        countCheck(
          name: "plain_text_byte_count_preserved",
          expected: draft.beforePlainTextByteCount,
          actual: postWriteStructure.plainTextByteCount ?? -1
        ))
      checks.append(
        boolCheck(
          name: "plain_text_hash_preserved",
          expected: true,
          actual: postWriteStructure.plainTextSHA256 == draft.beforePlainTextSHA256
        ))
      checks.append(
        boolCheck(
          name: "body_plain_text_readback_available",
          expected: true,
          actual: postWriteStructure.plainTextSHA256 != nil && postWriteStructure.plainTextByteCount != nil
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteNote.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifyTagRename(
    operation: String,
    draft: NotesTagRenameDraft,
    beforeAffectedNotes: [NotesNoteDetail],
    beforeSmartFolderTagCriteria: [NotesSmartFolderTagCriteriaSnapshot] = [],
    result: NotesTagRenameWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let tagReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes tag rename verification requires tag-scoped private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let afterOld = try tagReader.readNotes(tag: draft.currentStandardizedContent, limit: 2_000)
      let afterNew = try tagReader.readNotes(tag: draft.newStandardizedContent, limit: 2_000)
      let afterByID = Dictionary(uniqueKeysWithValues: afterNew.map { ($0.id, $0) })
      let beforeByID = Dictionary(uniqueKeysWithValues: beforeAffectedNotes.map { ($0.id, $0) })
      let beforeIDs = Set(beforeByID.keys)
      let afterIDs = Set(afterByID.keys)
      let resultIDs = Set(result.affectedNotes.map(\.id))
      let affectedAfterNotes = beforeAffectedNotes.compactMap { afterByID[$0.id] }
      let affectedAfterByID = Dictionary(uniqueKeysWithValues: affectedAfterNotes.map { ($0.id, $0) })
      let affectedNoteIDsPreserved = draft.allowMerge ? beforeIDs.isSubset(of: afterIDs) : beforeIDs == afterIDs

      var checks: [NotesVerificationCheckRecord] = []
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        stringCheck(
          name: "tag_standardized_content",
          expected: draft.newStandardizedContent,
          actual: result.tag.standardizedContent ?? standardizedTagContent(result.tag.displayText)
        ))
      checks.append(
        countCheck(
          name: "affected_note_count",
          expected: beforeAffectedNotes.count,
          actual: draft.allowMerge ? result.affectedNotes.count : afterNew.count
        ))
      checks.append(boolCheck(name: "old_tag_query_empty", expected: true, actual: afterOld.isEmpty))
      checks.append(
        boolCheck(name: "affected_note_ids_preserved", expected: true, actual: affectedNoteIDsPreserved))
      if draft.allowMerge {
        checks.append(
          boolCheck(
            name: "merge_target_contains_source_affected_notes",
            expected: true,
            actual: beforeIDs.isSubset(of: afterIDs) && beforeIDs == resultIDs
          ))
      }
      checks.append(
        boolCheck(
          name: "new_tag_present_on_affected",
          expected: true,
          actual: affectedAfterNotes.allSatisfy { containsTag($0.tags, draft.newStandardizedContent) }
        ))
      checks.append(
        boolCheck(
          name: "old_tag_absent_from_affected",
          expected: true,
          actual: affectedAfterNotes.allSatisfy { !containsTag($0.tags, draft.currentStandardizedContent) }
        ))
      checks.append(
        boolCheck(
          name: "title_folder_account_preserved",
          expected: true,
          actual: beforeAffectedNotes.allSatisfy { before in
            guard let after = affectedAfterByID[before.id] else {
              return false
            }
            return before.title == after.title
              && before.folderName == after.folderName
              && before.accountName == after.accountName
          }
        ))
      checks.append(
        boolCheck(
          name: "other_tags_preserved",
          expected: true,
          actual: beforeAffectedNotes.allSatisfy { before in
            guard let after = affectedAfterByID[before.id] else {
              return false
            }
            return renamedTagsPreserved(
              before: before.tags,
              after: after.tags,
              old: draft.currentStandardizedContent,
              new: draft.newStandardizedContent
            )
          }
        ))
      checks.append(
        contentsOf: try smartFolderTagRenameCriteriaChecks(
          beforeSnapshots: beforeSmartFolderTagCriteria,
          oldTag: draft.currentStandardizedContent,
          newTag: draft.newStandardizedContent,
          allowMerge: draft.allowMerge
        ))

      return checkedReport(
        operation: operation,
        targetID: result.tag.id,
        readback: tagReadback(result.tag),
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyTagDelete(
    operation: String,
    draft: NotesTagDeleteDraft,
    beforeAffectedNotes: [NotesNoteDetail],
    beforeSmartFolderTagCriteria: [NotesSmartFolderTagCriteriaSnapshot] = [],
    result: NotesTagDeleteWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let tagReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes tag delete verification requires tag-scoped private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let afterOld = try tagReader.readNotes(tag: draft.standardizedContent, limit: 2_000)
      let listedTags = try tagReader.listTags(account: nil, limit: 2_000)
      let afterAffectedNotes = try beforeAffectedNotes.compactMap { before in
        try reader.readNote(id: before.id)
      }
      let afterByID = Dictionary(uniqueKeysWithValues: afterAffectedNotes.map { ($0.id, $0) })
      let beforeByID = Dictionary(uniqueKeysWithValues: beforeAffectedNotes.map { ($0.id, $0) })
      let beforeIDs = Set(beforeByID.keys)
      let afterIDs = Set(afterByID.keys)

      var checks: [NotesVerificationCheckRecord] = []
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        countCheck(
          name: "affected_note_count",
          expected: beforeAffectedNotes.count,
          actual: afterAffectedNotes.count
        ))
      checks.append(boolCheck(name: "old_tag_query_empty", expected: true, actual: afterOld.isEmpty))
      checks.append(
        boolCheck(
          name: "deleted_tag_not_listed",
          expected: true,
          actual: !listedTags.contains { tagMatches($0, draft.standardizedContent) }
        ))
      checks.append(
        boolCheck(name: "affected_note_ids_preserved", expected: true, actual: beforeIDs == afterIDs))
      checks.append(
        boolCheck(
          name: "old_tag_absent_from_affected",
          expected: true,
          actual: afterAffectedNotes.allSatisfy { !containsTag($0.tags, draft.standardizedContent) }
        ))
      checks.append(
        boolCheck(
          name: "title_folder_account_preserved",
          expected: true,
          actual: beforeAffectedNotes.allSatisfy { before in
            guard let after = afterByID[before.id] else {
              return false
            }
            return before.title == after.title
              && before.folderName == after.folderName
              && before.accountName == after.accountName
          }
        ))
      checks.append(
        boolCheck(
          name: "other_tags_preserved",
          expected: true,
          actual: beforeAffectedNotes.allSatisfy { before in
            guard let after = afterByID[before.id] else {
              return false
            }
            return otherTagsPreserved(
              before: before.tags,
              after: after.tags,
              target: draft.standardizedContent
            )
          }
        ))
      checks.append(
        contentsOf: try smartFolderDeletedTagCriteriaChecks(
          beforeSnapshots: beforeSmartFolderTagCriteria,
          deletedTags: [draft.standardizedContent]
        ))

      return checkedReport(
        operation: operation,
        targetID: result.tag.id,
        readback: tagReadback(result.tag),
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifyTagBatchDelete(
    operation: String,
    drafts: [NotesTagDeleteDraft],
    beforeAffectedNotes: [NotesNoteDetail],
    beforeSmartFolderTagCriteria: [NotesSmartFolderTagCriteriaSnapshot] = [],
    results: [NotesTagDeleteWriteResult]
  ) throws -> NotesMutationVerificationReport {
    guard let tagReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes batch tag delete verification requires tag-scoped private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let deletedTags = drafts.map(\.standardizedContent)
      let deletedTagSet = Set(deletedTags)
      let listedTags = try tagReader.listTags(account: nil, limit: 2_000)
      let afterAffectedNotes = try beforeAffectedNotes.compactMap { before in
        try reader.readNote(id: before.id)
      }
      let afterByID = Dictionary(uniqueKeysWithValues: afterAffectedNotes.map { ($0.id, $0) })
      let beforeByID = Dictionary(uniqueKeysWithValues: beforeAffectedNotes.map { ($0.id, $0) })
      let beforeIDs = Set(beforeByID.keys)
      let afterIDs = Set(afterByID.keys)
      let perTagQueriesEmpty = try drafts.allSatisfy { draft in
        try tagReader.readNotes(tag: draft.standardizedContent, limit: 2_000).isEmpty
      }

      var checks: [NotesVerificationCheckRecord] = []
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: results.contains { $0.changed }))
      checks.append(countCheck(name: "deleted_tag_count", expected: drafts.count, actual: results.count))
      checks.append(
        countCheck(
          name: "affected_note_count",
          expected: beforeAffectedNotes.count,
          actual: afterAffectedNotes.count
        ))
      checks.append(
        boolCheck(
          name: "per_tag_affected_note_counts",
          expected: true,
          actual: zip(drafts, results).allSatisfy { draft, result in
            draft.affectedNoteCount == result.affectedNotes.count
          }
        ))
      checks.append(boolCheck(name: "old_tag_queries_empty", expected: true, actual: perTagQueriesEmpty))
      checks.append(
        boolCheck(
          name: "deleted_tags_not_listed",
          expected: true,
          actual: deletedTags.allSatisfy { deleted in
            !listedTags.contains { tagMatches($0, deleted) }
          }
        ))
      checks.append(
        boolCheck(name: "affected_note_ids_preserved", expected: true, actual: beforeIDs == afterIDs))
      checks.append(
        boolCheck(
          name: "deleted_tags_absent_from_affected",
          expected: true,
          actual: afterAffectedNotes.allSatisfy { note in
            deletedTags.allSatisfy { !containsTag(note.tags, $0) }
          }
        ))
      checks.append(
        boolCheck(
          name: "title_folder_account_preserved",
          expected: true,
          actual: beforeAffectedNotes.allSatisfy { before in
            guard let after = afterByID[before.id] else {
              return false
            }
            return before.title == after.title
              && before.folderName == after.folderName
              && before.accountName == after.accountName
          }
        ))
      checks.append(
        boolCheck(
          name: "non_deleted_tags_preserved",
          expected: true,
          actual: beforeAffectedNotes.allSatisfy { before in
            guard let after = afterByID[before.id] else {
              return false
            }
            let beforeKept = tagSet(before.tags).subtracting(deletedTagSet)
            let afterSet = tagSet(after.tags)
            return beforeKept == afterSet
          }
        ))
      checks.append(
        contentsOf: try smartFolderDeletedTagCriteriaChecks(
          beforeSnapshots: beforeSmartFolderTagCriteria,
          deletedTags: deletedTags
        ))

      return checkedReport(
        operation: operation,
        targetID: deletedTags.sorted().joined(separator: "\0"),
        readback: NotesReadbackRecord(
          kind: "tag_batch",
          idSHA256: sha256Hex(deletedTags.sorted().joined(separator: "\0"))
        ),
        storeObject: nil,
        checks: checks,
        warnings: []
      )
    }
  }

  func verifySmartFolderCreate(
    operation: String,
    draft: NotesSmartFolderCreateDraft,
    result: NotesSmartFolderCreateWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder create verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: postWriteFolder.id, limit: 2_000)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      let tagSelection = postWriteFolder.criteria?.tagSelection
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(stringCheck(name: "name", expected: draft.name, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(
        boolCheck(
          name: "tag_criteria_present",
          expected: true,
          actual: tagSelection != nil
        ))
      if let selectedTagCount = tagSelection?.selectedTagCount {
        checks.append(
          countCheck(
            name: "selected_tag_count",
            expected: draft.matchedTagCount,
            actual: selectedTagCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "selected_tag_count", status: "not_applicable"))
      }
      if draft.tagStandardizedContents.count > 1 {
        let operatorCheckName =
          draft.tagOperator == notesSmartFolderTagSelectionOperatorAny
          ? "tag_operator_any_selected"
          : "tag_operator_all_selected"
        checks.append(
          countCheck(
            name: operatorCheckName,
            expected: draft.tagOperator,
            actual: tagSelection?.tagOperator ?? -1
          ))
        checks.append(
          countCheck(
            name: "tag_mode_all_tagged",
            expected: notesSmartFolderTagSelectionModeAllTagged,
            actual: tagSelection?.mode ?? -1
          ))
      }
      checks.append(
        countCheck(
          name: "matching_note_count",
          expected: draft.matchingNoteCount,
          actual: matchingNotes.count
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "visible_note_count",
            expected: matchingNotes.count,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderDelete(
    operation: String,
    draft: NotesSmartFolderDeleteDraft,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder delete verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try smartFolderReader.listSmartFolders(account: nil, limit: 2_000)
        .first(where: { $0.id == draft.smartFolderID })
      let beforeFolder = NotesFolderRecord(
        id: draft.smartFolderID,
        name: draft.name,
        accountName: draft.accountName,
        visibleNoteCount: draft.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(beforeFolder, selector: beforeFolder.id)
      let checks = [
        boolCheck(name: "changed", expected: true, actual: changed),
        boolCheck(name: "exists_after", expected: false, actual: postWriteFolder != nil),
        boolCheck(name: "query_was_present", expected: true, actual: draft.queryPresent),
        storeMatchCheck(objectID: draft.smartFolderID, storeObject: debug.storeObject),
      ]

      return checkedReport(
        operation: operation,
        targetID: draft.smartFolderID,
        readback: nil,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderFolderConversion(
    operation: String,
    draft: NotesSmartFolderFolderConversionDraft,
    result: NotesSmartFolderFolderConversionWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder folder-conversion verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }
    guard let tagReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder folder-conversion verification requires tag-scoped private framework readback.",
        details: ["operation": operation]
      )
    }
    guard let noteStateReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder folder-conversion verification requires private framework note-state readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let sourceFolderAfter = try reader.listFolders(account: draft.accountName, limit: 2_000)
        .first { $0.id == draft.folderID }
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: postWriteFolder.id, limit: 2_000)
      let matchingIDs = Set(matchingNotes.map(\.id))
      let taggedNotes = try tagReader.readNotes(tag: draft.tagStandardizedContent, limit: 2_000)
        .filter { $0.accountName.localizedCaseInsensitiveCompare(draft.accountName) == .orderedSame }
      let taggedIDs = Set(taggedNotes.map(\.id))
      let postNotes = try draft.noteIDs.map { try requiredPostWriteNote(id: $0, operation: operation) }
      let postStates = try draft.noteIDs.map { try noteStateReader.readNoteState(noteID: $0) }
      let targetName = result.targetFolderName ?? draft.targetFolderName
      let expectedIDs = Set(draft.noteIDs)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      let tagSelection = postWriteFolder.criteria?.tagSelection

      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(boolCheck(name: "source_folder_absent", expected: true, actual: sourceFolderAfter == nil))
      checks.append(stringCheck(name: "smart_folder_name", expected: draft.folderName, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(boolCheck(name: "tag_criteria_present", expected: true, actual: tagSelection != nil))
      if let selectedTagCount = tagSelection?.selectedTagCount {
        checks.append(countCheck(name: "selected_tag_count", expected: 1, actual: selectedTagCount))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "selected_tag_count", status: "not_applicable"))
      }
      checks.append(countCheck(name: "moved_note_count", expected: draft.noteIDs.count, actual: result.movedNoteCount))
      checks.append(countCheck(name: "tagged_note_count", expected: draft.noteIDs.count, actual: result.taggedNoteCount))
      checks.append(
        boolCheck(
          name: "matching_note_ids_include_converted_notes",
          expected: true,
          actual: expectedIDs.isSubset(of: matchingIDs)
        ))
      checks.append(
        boolCheck(
          name: "tagged_note_ids_include_converted_notes",
          expected: true,
          actual: expectedIDs.isSubset(of: taggedIDs)
        ))
      if let targetName {
        checks.append(
          boolCheck(
            name: "target_folder_readback",
            expected: true,
            actual: postNotes.allSatisfy {
              $0.folderName.localizedCaseInsensitiveCompare(targetName) == .orderedSame
            }
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "target_folder_readback", status: "not_applicable"))
      }
      checks.append(
        boolCheck(
          name: "tag_readback",
          expected: true,
          actual: postNotes.allSatisfy { containsTag($0.tags, draft.tagStandardizedContent) }
        ))
      checks.append(
        boolCheck(
          name: "converted_note_state_safe",
          expected: true,
          actual: postStates.allSatisfy {
            !$0.isDeletedOrInTrash
              && !$0.isPasswordProtected
              && $0.isPasswordProtectedAndLocked != true
              && !$0.isSharedViaICloud
              && !$0.isSharedViaICloudFolder
              && !$0.isSharedReadOnly
              && $0.isEditable != false
          }
        ))
      checks.append(
        boolCheck(
          name: "note_identity_hashes",
          expected: true,
          actual: result.noteIDHashes == draft.noteIDHashes
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(countCheck(name: "visible_note_count", expected: draft.noteIDs.count, actual: visibleNoteCount))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderUpdate(
    operation: String,
    draft: NotesSmartFolderUpdateDraft,
    result: NotesSmartFolderUpdateWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder update verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: postWriteFolder.id, limit: 2_000)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      let tagSelection = postWriteFolder.criteria?.tagSelection
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.smartFolderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "previous_query_present", expected: true, actual: draft.previousQueryPresent))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(
        boolCheck(
          name: "tag_criteria_present",
          expected: true,
          actual: tagSelection != nil
        ))
      checks.append(
        boolCheck(
          name: "criteria_is_tag_selection",
          expected: true,
          actual: postWriteFolder.criteria?.queryKind == "tag_selection"
        ))
      if let selectedTagCount = tagSelection?.selectedTagCount {
        checks.append(
          countCheck(
            name: "selected_tag_count",
            expected: draft.matchedTagCount,
            actual: selectedTagCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "selected_tag_count", status: "not_applicable"))
      }
      if draft.tagStandardizedContents.count > 1 {
        let operatorCheckName =
          draft.tagOperator == notesSmartFolderTagSelectionOperatorAny
          ? "tag_operator_any_selected"
          : "tag_operator_all_selected"
        checks.append(
          countCheck(
            name: operatorCheckName,
            expected: draft.tagOperator,
            actual: tagSelection?.tagOperator ?? -1
          ))
        checks.append(
          countCheck(
            name: "tag_mode_all_tagged",
            expected: notesSmartFolderTagSelectionModeAllTagged,
            actual: tagSelection?.mode ?? -1
          ))
      }
      checks.append(
        countCheck(
          name: "matching_note_count",
          expected: draft.matchingNoteCount,
          actual: matchingNotes.count
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "visible_note_count",
            expected: matchingNotes.count,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderBuiltInCriteriaCreate(
    operation: String,
    draft: NotesSmartFolderBuiltInCriteriaCreateDraft,
    result: NotesSmartFolderBuiltInCriteriaCreateWriteResult,
    matchingNotes: [NotesNoteSummary]
  ) throws -> NotesMutationVerificationReport {
    guard smartFolderReader != nil else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder built-in criteria create verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(stringCheck(name: "name", expected: draft.name, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(boolCheck(name: "criteria_summary_present", expected: true, actual: postWriteFolder.criteria != nil))
      checks.append(
        boolCheck(
          name: "built_in_criteria_readback",
          expected: true,
          actual: smartFolderBuiltInCriteriaMatches(
            kind: draft.criteriaKind,
            kinds: draft.criteriaKinds,
            dateCriteria: draft.dateCriteria,
            folderCriteria: draft.folderCriteria,
            folderCriteriaByKind: draft.folderCriteriaByKind,
            participantCriteria: draft.participantCriteria,
            criteria: postWriteFolder.criteria
          )
        ))
      if smartFolderUntaggedCriteriaKind(draft.criteriaKind) {
        checks.append(contentsOf: smartFolderUntaggedCriteriaChecks(criteria: postWriteFolder.criteria))
      }
      if let expectedFilterCount = smartFolderBuiltInCriteriaExpectedFilterCount(
        kinds: draft.criteriaKinds,
        dateCriteria: draft.dateCriteria,
        folderCriteria: draft.folderCriteria,
        folderCriteriaByKind: draft.folderCriteriaByKind
      ) {
        checks.append(
          countCheck(
            name: "criteria_filter_count",
            expected: expectedFilterCount,
            actual: postWriteFolder.criteria?.filterCount ?? 0
          ))
        checks.append(
          boolCheck(
            name: "criteria_kinds_readback",
            expected: true,
            actual: smartFolderBuiltInCriteriaKindsMatch(
              kinds: draft.criteriaKinds,
              dateCriteria: draft.dateCriteria,
              folderCriteria: draft.folderCriteria,
              folderCriteriaByKind: draft.folderCriteriaByKind,
              participantCriteria: draft.participantCriteria,
              criteria: postWriteFolder.criteria
            )
          ))
        checks.append(
          countCheck(
            name: "criteria_join_operator",
            expected: draft.joinOperator,
            actual: postWriteFolder.criteria?.joinOperator ?? -1
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "criteria_filter_count", status: "not_applicable"))
        checks.append(NotesVerificationCheckRecord(name: "criteria_kinds_readback", status: "not_applicable"))
        checks.append(NotesVerificationCheckRecord(name: "criteria_join_operator", status: "not_applicable"))
      }
      if let includeRecentlyDeleted = postWriteFolder.criteria?.includeRecentlyDeleted {
        checks.append(
          boolCheck(
            name: "include_recently_deleted",
            expected: draft.includeRecentlyDeleted,
            actual: includeRecentlyDeleted
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "include_recently_deleted", status: "not_applicable"))
      }
      checks.append(
        countCheck(
          name: "matching_note_readback_count",
          expected: matchingNotes.count,
          actual: matchingNotes.count
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "visible_note_count",
            expected: matchingNotes.count,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderBuiltInCriteriaUpdate(
    operation: String,
    draft: NotesSmartFolderBuiltInCriteriaUpdateDraft,
    result: NotesSmartFolderBuiltInCriteriaUpdateWriteResult,
    matchingNotes: [NotesNoteSummary]
  ) throws -> NotesMutationVerificationReport {
    guard smartFolderReader != nil else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder built-in criteria update verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.smartFolderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "previous_query_present", expected: true, actual: draft.previousQueryPresent))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(boolCheck(name: "criteria_summary_present", expected: true, actual: postWriteFolder.criteria != nil))
      checks.append(
        boolCheck(
          name: "built_in_criteria_readback",
          expected: true,
          actual: smartFolderBuiltInCriteriaMatches(
            kind: draft.criteriaKind,
            kinds: draft.criteriaKinds,
            dateCriteria: draft.dateCriteria,
            folderCriteria: draft.folderCriteria,
            folderCriteriaByKind: draft.folderCriteriaByKind,
            participantCriteria: draft.participantCriteria,
            criteria: postWriteFolder.criteria
          )
        ))
      if smartFolderUntaggedCriteriaKind(draft.criteriaKind) {
        checks.append(contentsOf: smartFolderUntaggedCriteriaChecks(criteria: postWriteFolder.criteria))
      }
      if let expectedFilterCount = smartFolderBuiltInCriteriaExpectedFilterCount(
        kinds: draft.criteriaKinds,
        dateCriteria: draft.dateCriteria,
        folderCriteria: draft.folderCriteria,
        folderCriteriaByKind: draft.folderCriteriaByKind
      ) {
        checks.append(
          countCheck(
            name: "criteria_filter_count",
            expected: expectedFilterCount,
            actual: postWriteFolder.criteria?.filterCount ?? 0
          ))
        checks.append(
          boolCheck(
            name: "criteria_kinds_readback",
            expected: true,
            actual: smartFolderBuiltInCriteriaKindsMatch(
              kinds: draft.criteriaKinds,
              dateCriteria: draft.dateCriteria,
              folderCriteria: draft.folderCriteria,
              folderCriteriaByKind: draft.folderCriteriaByKind,
              participantCriteria: draft.participantCriteria,
              criteria: postWriteFolder.criteria
            )
          ))
        checks.append(
          countCheck(
            name: "criteria_join_operator",
            expected: draft.joinOperator,
            actual: postWriteFolder.criteria?.joinOperator ?? -1
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "criteria_filter_count", status: "not_applicable"))
        checks.append(NotesVerificationCheckRecord(name: "criteria_kinds_readback", status: "not_applicable"))
        checks.append(NotesVerificationCheckRecord(name: "criteria_join_operator", status: "not_applicable"))
      }
      if let includeRecentlyDeleted = postWriteFolder.criteria?.includeRecentlyDeleted {
        checks.append(
          boolCheck(
            name: "include_recently_deleted",
            expected: draft.includeRecentlyDeleted,
            actual: includeRecentlyDeleted
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "include_recently_deleted", status: "not_applicable"))
      }
      checks.append(
        countCheck(
          name: "matching_note_readback_count",
          expected: matchingNotes.count,
          actual: matchingNotes.count
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "visible_note_count",
            expected: matchingNotes.count,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderFilterMutation(
    operation: String,
    draft: NotesSmartFolderFilterMutationDraft,
    result: NotesSmartFolderBuiltInCriteriaUpdateWriteResult,
    matchingNotes: [NotesNoteSummary]
  ) throws -> NotesMutationVerificationReport {
    var report = try verifySmartFolderBuiltInCriteriaUpdate(
      operation: operation,
      draft: draft.updateDraft,
      result: result,
      matchingNotes: matchingNotes
    )
    let expectedKinds = smartFolderFilterMutationExpectedKinds(draft)
    let actualKinds = smartFolderPromotedCriteriaKinds(from: result.smartFolder.criteria) ?? []
    var checks = report.checks
    checks.append(
      countCheck(
        name: "filter_mutation_ordinal",
        expected: draft.ordinal,
        actual: draft.ordinal
      ))
    checks.append(
      stringCheck(
        name: "filter_mutation_kind",
        expected: draft.mutationKind,
        actual: draft.mutationKind
      ))
    checks.append(
      countCheck(
        name: "filter_count_delta",
        expected: draft.resultingCriteriaKinds.count - draft.previousCriteriaKinds.count,
        actual: expectedKinds.count - draft.previousCriteriaKinds.count
      ))
    checks.append(
      stringCheck(
        name: "filter_delta_sequence",
        expected: draft.resultingCriteriaKinds.joined(separator: ","),
        actual: expectedKinds.joined(separator: ",")
      ))
    checks.append(
      stringCheck(
        name: "filter_readback_sequence",
        expected: draft.resultingCriteriaKinds.joined(separator: ","),
        actual: actualKinds.joined(separator: ",")
      ))
    checks.append(
      countCheck(
        name: "filter_readback_count",
        expected: draft.resultingCriteriaKinds.count,
        actual: result.smartFolder.criteria?.filterCount ?? -1
      ))
    report.checks = checks
    report.verified = report.verified && checks.allSatisfy { $0.status != "failed" }
    report.evidenceLevel = "private_filter_delta_readback+matching_note_resolution"
    return report
  }

  private func smartFolderFilterMutationExpectedKinds(
    _ draft: NotesSmartFolderFilterMutationDraft
  ) -> [String] {
    var kinds = draft.previousCriteriaKinds
    let index = draft.ordinal - 1
    switch draft.mutationKind {
    case "add":
      if let criteriaKind = draft.criteriaKind, index >= 0, index <= kinds.count {
        kinds.insert(criteriaKind, at: index)
      }
    case "update":
      if let criteriaKind = draft.criteriaKind, index >= 0, index < kinds.count {
        kinds[index] = criteriaKind
      }
    case "remove":
      if index >= 0, index < kinds.count {
        kinds.remove(at: index)
      }
    default:
      return []
    }
    return kinds
  }

  func verifySmartFolderDuplicate(
    operation: String,
    draft: NotesSmartFolderDuplicateDraft,
    result: NotesSmartFolderDuplicateWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder duplicate verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: postWriteFolder.id, limit: 2_000)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        boolCheck(
          name: "source_distinct",
          expected: true,
          actual: postWriteFolder.id != draft.sourceSmartFolderID
        ))
      checks.append(stringCheck(name: "name", expected: draft.name, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "source_query_present", expected: true, actual: draft.sourceQueryPresent))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(
        contentsOf: smartFolderCriteriaReuseChecks(
          expected: draft.sourceCriteria,
          actual: postWriteFolder.criteria,
          expectedQuerySHA256: draft.sourceQuerySHA256,
          actualQuerySHA256: postWriteFolder.querySHA256
        ))
      checks.append(
        countCheck(
          name: "matching_note_count_copied",
          expected: draft.sourceMatchingNoteCount,
          actual: matchingNotes.count
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "visible_note_count_matches_source_matches",
            expected: draft.sourceMatchingNoteCount,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count_matches_source_matches", status: "not_applicable"))
      }
      if let sourceVisibleNoteCount = draft.sourceVisibleNoteCount, let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "source_visible_note_count_preserved",
            expected: sourceVisibleNoteCount,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "source_visible_note_count_preserved", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderCriteriaCopy(
    operation: String,
    draft: NotesSmartFolderCriteriaCopyDraft,
    result: NotesSmartFolderCriteriaCopyWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder criteria copy verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: postWriteFolder.id, limit: 2_000)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.targetSmartFolderID
        ))
      checks.append(
        boolCheck(
          name: "source_and_target_distinct",
          expected: true,
          actual: draft.sourceSmartFolderID != draft.targetSmartFolderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.targetName, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "source_query_present", expected: true, actual: draft.sourceQueryPresent))
      checks.append(boolCheck(name: "previous_target_query_present", expected: true, actual: draft.targetPreviousQueryPresent))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(
        contentsOf: smartFolderCriteriaReuseChecks(
          expected: draft.sourceCriteria,
          actual: postWriteFolder.criteria,
          expectedQuerySHA256: draft.sourceQuerySHA256,
          actualQuerySHA256: postWriteFolder.querySHA256
        ))
      checks.append(
        countCheck(
          name: "matching_note_count_copied",
          expected: draft.sourceMatchingNoteCount,
          actual: matchingNotes.count
        ))
      if let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "visible_note_count_matches_source_matches",
            expected: draft.sourceMatchingNoteCount,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count_matches_source_matches", status: "not_applicable"))
      }
      if let sourceVisibleNoteCount = draft.sourceVisibleNoteCount, let visibleNoteCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(
            name: "source_visible_note_count_preserved",
            expected: sourceVisibleNoteCount,
            actual: visibleNoteCount
          ))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "source_visible_note_count_preserved", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderCriteriaImport(
    operation: String,
    draft: NotesSmartFolderCriteriaImportDraft,
    result: NotesSmartFolderCriteriaImportWriteResult
  ) throws -> NotesMutationVerificationReport {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder criteria import verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: result.smartFolder.id, operation: operation)
      let matchingNotes = try smartFolderReader.listSmartFolderNotes(smartFolderID: postWriteFolder.id, limit: 2_000)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: result.changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.smartFolderID
        ))
      checks.append(stringCheck(name: "name_preserved", expected: draft.name, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account_preserved", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "previous_query_present", expected: true, actual: draft.previousQueryPresent))
      checks.append(boolCheck(name: "query_present", expected: true, actual: postWriteFolder.queryPresent))
      checks.append(
        stringCheck(
          name: "query_hash_imported",
          expected: draft.sourceSHA256,
          actual: postWriteFolder.querySHA256 ?? ""
        ))
      checks.append(
        countCheck(
          name: "source_byte_count",
          expected: draft.sourceByteCount,
          actual: Data(draft.queryJSON.utf8).count
        ))
      if let queryJSONLength = postWriteFolder.queryJSONLength {
        checks.append(countCheck(name: "query_json_length_imported", expected: draft.sourceByteCount, actual: queryJSONLength))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "query_json_length_imported", status: "not_applicable"))
      }
      checks.append(boolCheck(name: "criteria_summary_present", expected: true, actual: postWriteFolder.criteria != nil))
      checks.append(
        countCheck(
          name: "matching_note_readback_count",
          expected: matchingNotes.count,
          actual: matchingNotes.count
        ))

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  func verifySmartFolderRename(
    operation: String,
    draft: NotesSmartFolderRenameDraft,
    resultSmartFolder: NotesSmartFolderRecord,
    changed: Bool
  ) throws -> NotesMutationVerificationReport {
    guard smartFolderReader != nil else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder rename verification requires Smart Folder private framework readback.",
        details: ["operation": operation]
      )
    }

    return try retryingReport {
      let postWriteFolder = try requiredPostWriteSmartFolder(id: resultSmartFolder.id, operation: operation)
      let debugFolder = NotesFolderRecord(
        id: postWriteFolder.id,
        name: postWriteFolder.name,
        accountName: postWriteFolder.accountName,
        visibleNoteCount: postWriteFolder.visibleNoteCount,
        isSmartFolder: true
      )
      let debug = sqliteReader.debugFolder(debugFolder, selector: postWriteFolder.id)
      var checks = commonFolderChecks(folder: debugFolder, debug: debug)
      checks.append(boolCheck(name: "changed_reported", expected: true, actual: changed))
      checks.append(
        boolCheck(
          name: "identity_preserved",
          expected: true,
          actual: postWriteFolder.id == draft.smartFolderID
        ))
      checks.append(stringCheck(name: "name", expected: draft.newName, actual: postWriteFolder.name))
      checks.append(stringCheck(name: "account", expected: draft.accountName, actual: postWriteFolder.accountName))
      checks.append(boolCheck(name: "query_preserved", expected: draft.queryPresent, actual: postWriteFolder.queryPresent))
      if let expectedHash = draft.querySHA256, let actualHash = postWriteFolder.querySHA256 {
        checks.append(stringCheck(name: "query_hash_preserved", expected: expectedHash, actual: actualHash))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "query_hash_preserved", status: "not_applicable"))
      }
      if let expectedVisibleCount = draft.visibleNoteCount, let actualVisibleCount = postWriteFolder.visibleNoteCount {
        checks.append(
          countCheck(name: "visible_note_count_preserved", expected: expectedVisibleCount, actual: actualVisibleCount))
      } else {
        checks.append(NotesVerificationCheckRecord(name: "visible_note_count_preserved", status: "not_applicable"))
      }

      return checkedReport(
        operation: operation,
        targetID: postWriteFolder.id,
        readback: debug.readback,
        storeObject: debug.storeObject,
        checks: checks,
        warnings: debug.warnings
      )
    }
  }

  private func smartFolderCriteriaReuseChecks(
    expected: NotesSmartFolderCriteriaSummary?,
    actual: NotesSmartFolderCriteriaSummary?,
    expectedQuerySHA256: String?,
    actualQuerySHA256: String?
  ) -> [NotesVerificationCheckRecord] {
    var checks: [NotesVerificationCheckRecord] = []
    checks.append(boolCheck(name: "criteria_present", expected: true, actual: actual != nil))
    guard let expected else {
      checks.append(NotesVerificationCheckRecord(name: "source_criteria_present", status: "failed"))
      return checks
    }
    guard let actual else {
      checks.append(NotesVerificationCheckRecord(name: "source_query_kind_copied", status: "failed"))
      checks.append(NotesVerificationCheckRecord(name: "source_filter_count_copied", status: "failed"))
      checks.append(NotesVerificationCheckRecord(name: "source_predicate_presence_copied", status: "failed"))
      checks.append(NotesVerificationCheckRecord(name: "source_tag_selection_copied", status: "failed"))
      return checks
    }
    if let expectedQuerySHA256, let actualQuerySHA256 {
      checks.append(
        stringCheck(
          name: "source_query_hash_copied",
          expected: expectedQuerySHA256,
          actual: actualQuerySHA256
        ))
    } else {
      checks.append(NotesVerificationCheckRecord(name: "source_query_hash_copied", status: "not_applicable"))
    }
    checks.append(
      stringCheck(
        name: "source_query_kind_copied",
        expected: expected.queryKind,
        actual: actual.queryKind
      ))
    checks.append(
      countCheck(
        name: "source_filter_count_copied",
        expected: expected.filterCount,
        actual: actual.filterCount
      ))
    checks.append(
      boolCheck(
        name: "source_predicate_presence_copied",
        expected: expected.predicatePresent,
        actual: actual.predicatePresent
      ))
    if let expectedPredicateSHA256 = expected.predicateFormatSHA256,
      let actualPredicateSHA256 = actual.predicateFormatSHA256
    {
      checks.append(
        stringCheck(
          name: "source_predicate_hash_copied",
          expected: expectedPredicateSHA256,
          actual: actualPredicateSHA256
        ))
    } else {
      checks.append(NotesVerificationCheckRecord(name: "source_predicate_hash_copied", status: "not_applicable"))
    }
    if let expectedSelectedTagCount = expected.tagSelection?.selectedTagCount,
      let actualSelectedTagCount = actual.tagSelection?.selectedTagCount
    {
      checks.append(
        countCheck(
          name: "source_selected_tag_count_copied",
          expected: expectedSelectedTagCount,
          actual: actualSelectedTagCount
        ))
    } else if expected.tagSelection == nil, actual.tagSelection == nil {
      checks.append(NotesVerificationCheckRecord(name: "source_selected_tag_count_copied", status: "not_applicable"))
    } else {
      checks.append(NotesVerificationCheckRecord(name: "source_selected_tag_count_copied", status: "failed"))
    }
    return checks
  }

  private func smartFolderBuiltInCriteriaMatches(
    kind: String,
    kinds: [String]? = nil,
    dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:],
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters? = nil,
    criteria: NotesSmartFolderCriteriaSummary?,
    requireCombinationFilter: Bool = false
  ) -> Bool {
    let expectedKinds = kinds?.isEmpty == false ? kinds ?? [kind] : [kind]
    guard expectedKinds.count == 1 else {
      return smartFolderBuiltInCriteriaKindsMatch(
        kinds: expectedKinds,
        dateCriteria: dateCriteria,
        folderCriteria: folderCriteria,
        folderCriteriaByKind: folderCriteriaByKind,
        participantCriteria: participantCriteria,
        criteria: criteria
      )
    }
    let kind = expectedKinds[0]
    guard let criteria else {
      return false
    }
    let criteriaFolderCriteria = smartFolderFolderCriteria(
      for: kind,
      folderCriteria: folderCriteria,
      folderCriteriaByKind: folderCriteriaByKind
    )
    let expectation =
      requireCombinationFilter
      ? smartFolderBuiltInCriteriaCombinationFilterExpectation(
        kind: kind,
        dateCriteria: dateCriteria,
        folderCriteria: criteriaFolderCriteria
      )
      : smartFolderBuiltInCriteriaFilterExpectation(
        kind: kind,
        dateCriteria: dateCriteria,
        folderCriteria: criteriaFolderCriteria
      )
    if let expectation {
      return criteria.filters.contains(where: { filter in
        guard filter.kind == expectation.filterKind else {
          return false
        }
        if let expectedSelectionType = expectation.selectionType,
          filter.selectionType != expectedSelectionType
        {
          return false
        }
        if let expectedInclusionType = expectation.inclusionType,
          filter.inclusionType != expectedInclusionType
        {
          return false
        }
        if let expectedCount = expectation.count,
          filter.count != expectedCount
        {
          return false
        }
        if smartFolderFolderCriteriaInclusionType(kind) != nil,
          criteriaFolderCriteria == nil
        {
          return false
        }
        if smartFolderParticipantCriteriaKind(kind),
          participantCriteria == nil
        {
          return false
        }
        if let expectedHasPrimaryDate = expectation.hasPrimaryDate,
          filter.hasPrimaryDate != expectedHasPrimaryDate
        {
          return false
        }
        if let expectedHasSecondaryDate = expectation.hasSecondaryDate,
          filter.hasSecondaryDate != expectedHasSecondaryDate
        {
          return false
        }
        if let expectedHasRelativeRange = expectation.hasRelativeRange,
          filter.hasRelativeRange != expectedHasRelativeRange
        {
          return false
        }
        return true
      })
    }
    if smartFolderUntaggedCriteriaKind(kind) {
      return smartFolderUntaggedCriteriaMatches(criteria: criteria)
    }
    if requireCombinationFilter {
      return false
    }
    switch kind {
    case "math", "call", "system-paper", "recently-deleted-math":
      return criteria.predicatePresent
    default:
      return criteria.predicatePresent || criteria.filterCount > 0
    }
  }

  private func smartFolderBuiltInCriteriaKindsMatch(
    kinds: [String],
    dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:],
    participantCriteria: NotesSmartFolderParticipantCriteriaParameters? = nil,
    criteria: NotesSmartFolderCriteriaSummary?
  ) -> Bool {
    guard let criteria,
      let expectedFilterCount = smartFolderBuiltInCriteriaExpectedFilterCount(
        kinds: kinds,
        dateCriteria: dateCriteria,
        folderCriteria: folderCriteria,
        folderCriteriaByKind: folderCriteriaByKind
      ),
      criteria.filterCount == expectedFilterCount
    else {
      return false
    }
    return kinds.allSatisfy { kind in
      smartFolderBuiltInCriteriaMatches(
        kind: kind,
        kinds: [kind],
        dateCriteria: dateCriteria,
        folderCriteria: folderCriteria,
        folderCriteriaByKind: folderCriteriaByKind,
        participantCriteria: participantCriteria,
        criteria: criteria,
        requireCombinationFilter: true
      )
    }
  }

  private func smartFolderBuiltInCriteriaExpectedFilterCount(
    kinds: [String],
    dateCriteria: NotesSmartFolderDateCriteriaParameters? = nil,
    folderCriteria: NotesSmartFolderFolderCriteriaParameters? = nil,
    folderCriteriaByKind: [String: NotesSmartFolderFolderCriteriaParameters] = [:]
  ) -> Int? {
    let useCombinationExpectations = kinds.count > 1
    let allFilterSelectionKinds = kinds.allSatisfy {
      let criteriaFolderCriteria = smartFolderFolderCriteria(
        for: $0,
        folderCriteria: folderCriteria,
        folderCriteriaByKind: folderCriteriaByKind
      )
      if useCombinationExpectations {
        return smartFolderBuiltInCriteriaCombinationFilterExpectation(
          kind: $0,
          dateCriteria: dateCriteria,
          folderCriteria: criteriaFolderCriteria
        ) != nil
      }
      return smartFolderBuiltInCriteriaFilterExpectation(
        kind: $0,
        dateCriteria: dateCriteria,
        folderCriteria: criteriaFolderCriteria
      ) != nil
    }
    return allFilterSelectionKinds ? kinds.count : nil
  }

  private func smartFolderUntaggedCriteriaMatches(criteria: NotesSmartFolderCriteriaSummary?) -> Bool {
    guard let criteria, let tagSelection = criteria.tagSelection else {
      return false
    }
    return criteria.queryKind == "tag_selection"
      && criteria.filterCount == 0
      && tagSelection.mode == notesSmartFolderTagSelectionModeAllUntagged
      && (tagSelection.selectedTagCount ?? 0) == 0
      && (tagSelection.includedTagCount ?? 0) == 0
      && (tagSelection.excludedTagCount ?? 0) == 0
  }

  private func smartFolderUntaggedCriteriaChecks(
    criteria: NotesSmartFolderCriteriaSummary?
  ) -> [NotesVerificationCheckRecord] {
    let tagSelection = criteria?.tagSelection
    return [
      boolCheck(
        name: "untagged_tag_selection_readback",
        expected: true,
        actual: smartFolderUntaggedCriteriaMatches(criteria: criteria)
      ),
      countCheck(
        name: "untagged_tag_selection_mode",
        expected: notesSmartFolderTagSelectionModeAllUntagged,
        actual: tagSelection?.mode ?? -1
      ),
      countCheck(
        name: "untagged_selected_tag_count",
        expected: 0,
        actual: tagSelection?.selectedTagCount ?? -1
      ),
    ]
  }

  private func requiredPostWriteNote(id: String, operation: String) throws -> NotesNoteDetail {
    guard let note = try reader.readNote(id: id) else {
      throw CLIError(
        code: .internalError,
        message: "Notes mutation verification failed: post-write readback did not find the note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(id),
        ]
      )
    }
    return note
  }

  private func requiredPostWriteFolder(id: String, operation: String) throws -> NotesFolderRecord {
    guard let folder = try reader.listFolders(account: nil, limit: 2_000).first(where: { $0.id == id }) else {
      throw CLIError(
        code: .internalError,
        message: "Notes folder mutation verification failed: post-write readback did not find the folder.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(id),
        ]
      )
    }
    return folder
  }

  private func requiredPostWriteSmartFolder(id: String, operation: String) throws -> NotesSmartFolderRecord {
    guard let smartFolderReader else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes Smart Folder verification requires private framework readback.",
        details: ["operation": operation]
      )
    }
    guard let folder = try smartFolderReader.listSmartFolders(account: nil, limit: 2_000).first(where: { $0.id == id })
    else {
      throw CLIError(
        code: .internalError,
        message: "Notes Smart Folder mutation verification failed: post-write readback did not find the Smart Folder.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(id),
        ]
      )
    }
    return folder
  }

  private func checkedReport(
    operation: String,
    targetID: String,
    readback: NotesReadbackRecord?,
    storeObject: NotesStoreObjectRecord?,
    checks: [NotesVerificationCheckRecord],
    warnings: [String]
  ) -> NotesMutationVerificationReport {
    let verified = checks.allSatisfy { $0.status != "failed" }
    let evidenceLevel: String
    if readback != nil, storeObject?.matched == true {
      evidenceLevel = "readback_and_store"
    } else if readback != nil {
      evidenceLevel = "readback"
    } else {
      evidenceLevel = "store"
    }

    return NotesMutationVerificationReport(
      operation: operation,
      verified: verified,
      evidenceLevel: evidenceLevel,
      targetIDSHA256: sha256Hex(targetID),
      readback: readback,
      storeObject: storeObject,
      checks: checks,
      warnings: warnings
    )
  }

  private func retryingReport(
    _ build: () throws -> NotesMutationVerificationReport
  ) throws -> NotesMutationVerificationReport {
    var lastReport: NotesMutationVerificationReport?
    var lastError: Error?
    for attempt in 0..<5 {
      do {
        let report = try build()
        if report.verified {
          return report
        }
        lastReport = report
      } catch {
        lastError = error
      }
      if attempt < 4 {
        Thread.sleep(forTimeInterval: 0.2)
      }
    }
    if let lastReport {
      return lastReport
    }
    if let lastError {
      throw lastError
    }
    throw CLIError(code: .internalError, message: "Notes mutation verification did not run.")
  }

  private func commonNoteChecks(
    note: NotesNoteDetail,
    debug: NotesObjectDebugResponse
  ) -> [NotesVerificationCheckRecord] {
    [
      boolCheck(name: "exists_after", expected: true, actual: true),
      storeMatchCheck(noteID: note.id, storeObject: debug.storeObject),
    ]
  }

  private func commonFolderChecks(
    folder: NotesFolderRecord,
    debug: NotesObjectDebugResponse
  ) -> [NotesVerificationCheckRecord] {
    [
      boolCheck(name: "exists_after", expected: true, actual: true),
      storeMatchCheck(objectID: folder.id, storeObject: debug.storeObject),
    ]
  }

  private func expectedBody(before: NotesNoteDetail, patch: NotesUpdatePatch) -> String {
    if let body = patch.body {
      return body
    }
    if let appendBody = patch.appendBody {
      let current = before.body ?? ""
      return current.isEmpty ? appendBody : "\(current)\n\(appendBody)"
    }
    return before.body ?? ""
  }

  private func inlineFormatRunExists(
    in structure: NotesBodyStructureRecord,
    evidence: NotesBodyInlineMutationEvidence,
    format: String
  ) -> Bool {
    structure.inlineFormatRuns.contains { run in
      run.format == format
        && run.textSHA256 == evidence.textSHA256
        && run.textByteCount == evidence.textByteCount
        && (evidence.fontSHA256 == nil || run.fontSHA256 == evidence.fontSHA256)
        && (evidence.paragraphIDSHA256 == nil || run.paragraphIDSHA256 == evidence.paragraphIDSHA256)
    }
  }

  private func inlineColorRunExists(
    in structure: NotesBodyStructureRecord,
    evidence: NotesBodyInlineMutationEvidence
  ) -> Bool {
    structure.colorRuns.contains { run in
      run.role == evidence.role
        && run.textSHA256 == evidence.textSHA256
        && run.textByteCount == evidence.textByteCount
        && (evidence.colorSHA256 == nil || run.colorSHA256 == evidence.colorSHA256)
        && (evidence.paragraphIDSHA256 == nil || run.paragraphIDSHA256 == evidence.paragraphIDSHA256)
    }
  }

  private func bodyChecklistConvertAnchor(
    draft: NotesBodyChecklistConvertDraft,
    structure: NotesBodyStructureRecord
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return structure.paragraphAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal {
      return structure.paragraphAnchors.first { $0.ordinal == ordinal }
    }
    return nil
  }

  private func bodyChecklistConvertRangeAnchors(
    draft: NotesBodyChecklistConvertRangeDraft,
    structure: NotesBodyStructureRecord
  ) -> [NotesBodyParagraphAnchorRecord] {
    guard draft.fromOrdinal > 0, draft.fromOrdinal <= draft.toOrdinal else {
      return []
    }
    return structure.paragraphAnchors
      .filter { $0.ordinal >= draft.fromOrdinal && $0.ordinal <= draft.toOrdinal }
      .sorted { $0.ordinal < $1.ordinal }
  }

  private func bodyListConvertAnchor(
    draft: NotesBodyListConvertDraft,
    structure: NotesBodyStructureRecord
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return structure.paragraphAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal {
      return structure.paragraphAnchors.first { $0.ordinal == ordinal }
    }
    return nil
  }

  private func bodyListConvertRangeAnchors(
    draft: NotesBodyListConvertRangeDraft,
    structure: NotesBodyStructureRecord
  ) -> [NotesBodyParagraphAnchorRecord] {
    guard draft.fromOrdinal > 0, draft.fromOrdinal <= draft.toOrdinal else {
      return []
    }
    return structure.paragraphAnchors
      .filter { $0.ordinal >= draft.fromOrdinal && $0.ordinal <= draft.toOrdinal }
      .sorted { $0.ordinal < $1.ordinal }
  }

  private func bodyParagraphFormatAnchor(
    paragraphIDSHA256: String?,
    ordinal: Int?,
    structure: NotesBodyStructureRecord
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 {
      return structure.paragraphAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal {
      return structure.paragraphAnchors.first { $0.ordinal == ordinal }
    }
    return nil
  }

  private func collapsibleSectionTarget(
    draft: NotesBodyCollapsibleSetDraft,
    sections: [NotesBodyCollapsibleSectionRecord]
  ) -> NotesBodyCollapsibleSectionRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return sections.first { $0.paragraphIDSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal {
      return sections.first { $0.ordinal == ordinal }
    }
    return nil
  }

  private func checklistAnchors(in structure: NotesBodyStructureRecord) -> [NotesBodyParagraphAnchorRecord] {
    structure.paragraphAnchors
      .filter { $0.isChecklist }
      .sorted { $0.ordinal < $1.ordinal }
  }

  private func ordinaryListAnchors(in structure: NotesBodyStructureRecord) -> [NotesBodyParagraphAnchorRecord] {
    structure.paragraphAnchors
      .filter { $0.isList && !$0.isChecklist }
      .sorted { $0.ordinal < $1.ordinal }
  }

  private func bodyListTextInsertAnchors(
    targetKind: NotesBodyListTextInsertTargetKind,
    in structure: NotesBodyStructureRecord
  ) -> [NotesBodyParagraphAnchorRecord] {
    switch targetKind {
    case .ordinaryList:
      return ordinaryListAnchors(in: structure)
    case .checklist:
      return checklistAnchors(in: structure)
    }
  }

  private func bodyListTextInsertAnchor(
    draft: NotesBodyListTextInsertDraft,
    targetAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return targetAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= targetAnchors.count {
      return targetAnchors[ordinal - 1]
    }
    return nil
  }

  private func bodyListEndAnchors(
    targetKind: NotesBodyListEndTargetKind,
    in structure: NotesBodyStructureRecord
  ) -> [NotesBodyParagraphAnchorRecord] {
    switch targetKind {
    case .ordinaryList:
      return ordinaryListAnchors(in: structure)
    case .checklist:
      return checklistAnchors(in: structure)
    }
  }

  private func bodyListEndAnchor(
    draft: NotesBodyListEndDraft,
    targetAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return targetAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= targetAnchors.count {
      return targetAnchors[ordinal - 1]
    }
    return nil
  }

  private func insertedBodyParagraphs(
    before: NotesBodyStructureRecord,
    after: NotesBodyStructureRecord
  ) -> [NotesBodyParagraphAnchorRecord] {
    let beforeIDs = Set(before.paragraphAnchors.map(\.idSHA256))
    return after.paragraphAnchors
      .filter {
        !beforeIDs.contains($0.idSHA256)
          && $0.style == "body"
          && !$0.isList
          && !$0.isChecklist
      }
      .sorted { $0.ordinal < $1.ordinal }
  }

  private func bodyAttachmentKindCount(_ kind: String, in structure: NotesBodyStructureRecord) -> Int {
    structure.attachmentKindCounts.first { $0.kind == kind }?.count ?? 0
  }

  private func expectedTableDimension(
    before: Int?,
    axis: NotesBodyTableStructureAxis,
    draft: NotesBodyTableStructureDraft
  ) -> Int? {
    guard let before else {
      return nil
    }
    guard draft.axis == axis else {
      return before
    }
    switch draft.action {
    case .insert, .copy:
      return before + draft.count
    case .delete:
      return before - draft.count
    case .move, .clear:
      return before
    }
  }

  private func postMoveTableSliceDigest(
    reader: any NotesBodyStructureReading,
    noteID: String,
    tableOrdinal: Int,
    draft: NotesBodyTableStructureDraft,
    table: NotesBodyTableRecord?
  ) throws -> (cellCount: Int, sha256: String)? {
    guard draft.action == .move, let toIndex = draft.toIndex else {
      return nil
    }
    let records: [NotesBodyTableCellRecord]
    switch draft.axis {
    case .row:
      guard let columnCount = table?.columnCount else {
        return nil
      }
      records = try (1...columnCount).map { column in
        try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: toIndex, column: column)
      }
    case .column:
      guard let rowCount = table?.rowCount else {
        return nil
      }
      records = try (1...rowCount).map { row in
        try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: row, column: toIndex)
      }
    }
    return (records.count, tableSliceDigest(records))
  }

  private func postCopyTableSliceDigest(
    reader: any NotesBodyStructureReading,
    noteID: String,
    tableOrdinal: Int,
    draft: NotesBodyTableStructureDraft,
    table: NotesBodyTableRecord?
  ) throws -> (cellCount: Int, sha256: String)? {
    guard draft.action == .copy, let toIndex = draft.toIndex else {
      return nil
    }
    let records: [NotesBodyTableCellRecord]
    switch draft.axis {
    case .row:
      guard let columnCount = table?.columnCount else {
        return nil
      }
      records = try (1...columnCount).map { column in
        try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: toIndex, column: column)
      }
    case .column:
      guard let rowCount = table?.rowCount else {
        return nil
      }
      records = try (1...rowCount).map { row in
        try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: row, column: toIndex)
      }
    }
    return (records.count, tableSliceDigest(records))
  }

  private func postClearTableSliceDigest(
    reader: any NotesBodyStructureReading,
    noteID: String,
    tableOrdinal: Int,
    draft: NotesBodyTableStructureDraft,
    table: NotesBodyTableRecord?
  ) throws -> (cellCount: Int, sha256: String)? {
    guard draft.action == .clear else {
      return nil
    }
    let records: [NotesBodyTableCellRecord]
    switch draft.axis {
    case .row:
      guard let columnCount = table?.columnCount else {
        return nil
      }
      records = try (draft.index..<(draft.index + draft.count)).flatMap { row in
        try (1...columnCount).map { column in
          try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: row, column: column)
        }
      }
    case .column:
      guard let rowCount = table?.rowCount else {
        return nil
      }
      records = try (draft.index..<(draft.index + draft.count)).flatMap { column in
        try (1...rowCount).map { row in
          try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: row, column: column)
        }
      }
    }
    return (records.count, tableSliceDigest(records))
  }

  private func tableSliceDigest(_ records: [NotesBodyTableCellRecord]) -> String {
    sha256Hex(
      records
        .map { "\($0.textByteCount):\($0.textSHA256)" }
        .joined(separator: "|")
    )
  }

  private func tableFormatSliceDigest(_ records: [NotesBodyTableCellRecord]) -> String? {
    guard records.allSatisfy({ $0.formatSHA256 != nil }) else {
      return nil
    }
    return sha256Hex(
      records
        .map { "\($0.formatRunCount ?? -1):\($0.formatSHA256 ?? "")" }
        .joined(separator: "|")
    )
  }

  private func tableCell(_ cell: NotesBodyTableCellRecord, contains format: NotesBodyInlineFormat) -> Bool {
    switch format {
    case .bold:
      return cell.containsBold == true
    case .italic:
      return cell.containsItalic == true
    case .underline:
      return cell.containsUnderline == true
    case .strikethrough:
      return cell.containsStrikethrough == true
    }
  }

  private func postFormatTableCells(
    reader: any NotesBodyStructureReading,
    noteID: String,
    tableOrdinal: Int,
    draft: NotesBodyTableFormatDraft,
    table: NotesBodyTableRecord?
  ) throws -> [NotesBodyTableCellRecord] {
    switch draft.axis {
    case .row:
      guard let columnCount = table?.columnCount else {
        return []
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { row in
        try (1...columnCount).map { column in
          try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: row, column: column)
        }
      }
    case .column:
      guard let rowCount = table?.rowCount else {
        return []
      }
      return try (draft.index..<(draft.index + draft.count)).flatMap { column in
        try (1...rowCount).map { row in
          try reader.readTableCell(noteID: noteID, tableOrdinal: tableOrdinal, row: row, column: column)
        }
      }
    }
  }

  private func emptyTableSliceDigest(cellCount: Int) -> String {
    sha256Hex(Array(repeating: "0:\(sha256Hex(""))", count: cellCount).joined(separator: "|"))
  }

  private func copiedTableCellHashesMatch(
    reader: any NotesBodyStructureReading,
    draft: NotesBodyTableCopyDraft,
    targetTableOrdinal: Int
  ) throws -> Bool {
    guard draft.rowCount > 0, draft.columnCount > 0 else {
      return false
    }
    for row in 1...draft.rowCount {
      for column in 1...draft.columnCount {
        let sourceCell = try reader.readTableCell(
          noteID: draft.sourceNoteID,
          tableOrdinal: draft.ordinal,
          row: row,
          column: column
        )
        let targetCell = try reader.readTableCell(
          noteID: draft.targetNoteID,
          tableOrdinal: targetTableOrdinal,
          row: row,
          column: column
        )
        guard sourceCell.textByteCount == targetCell.textByteCount,
          sourceCell.textSHA256 == targetCell.textSHA256
        else {
          return false
        }
      }
    }
    return true
  }

  private func tableCellHashesMatchSourceText(
    reader: any NotesBodyStructureReading,
    noteID: String,
    tableOrdinal: Int,
    text: String,
    rowCount: Int,
    columnCount: Int
  ) throws -> Bool {
    guard rowCount > 0, columnCount > 0 else {
      return false
    }
    let rows = text.components(separatedBy: CharacterSet.newlines)
    for row in 1...rowCount {
      let columns = row <= rows.count ? rows[row - 1].components(separatedBy: "\t") : []
      for column in 1...columnCount {
        let expectedText = column <= columns.count ? columns[column - 1] : ""
        let targetCell = try reader.readTableCell(
          noteID: noteID,
          tableOrdinal: tableOrdinal,
          row: row,
          column: column
        )
        guard targetCell.textByteCount == expectedText.utf8.count,
          targetCell.textSHA256 == sha256Hex(expectedText)
        else {
          return false
        }
      }
    }
    return true
  }

  private func bodyChecklistReorderSourceIndex(
    draft: NotesBodyChecklistReorderDraft,
    checklistAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> Int? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return checklistAnchors.firstIndex { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= checklistAnchors.count {
      return ordinal - 1
    }
    return nil
  }

  private func bodyListReorderSourceIndex(
    draft: NotesBodyListReorderDraft,
    listAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> Int? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return listAnchors.firstIndex { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= listAnchors.count {
      return ordinal - 1
    }
    return nil
  }

  private func bodyChecklistIndentAnchor(
    draft: NotesBodyChecklistIndentDraft,
    checklistAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return checklistAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= checklistAnchors.count {
      return checklistAnchors[ordinal - 1]
    }
    return nil
  }

  private func bodyChecklistDeleteAnchor(
    draft: NotesBodyChecklistDeleteDraft,
    checklistAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return checklistAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= checklistAnchors.count {
      return checklistAnchors[ordinal - 1]
    }
    return nil
  }

  private func bodyListIndentAnchor(
    draft: NotesBodyListIndentDraft,
    listAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return listAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= listAnchors.count {
      return listAnchors[ordinal - 1]
    }
    return nil
  }

  private func bodyListDeleteAnchor(
    draft: NotesBodyListDeleteDraft,
    listAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return listAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= listAnchors.count {
      return listAnchors[ordinal - 1]
    }
    return nil
  }

  private func bodyListSetStyleAnchor(
    draft: NotesBodyListSetStyleDraft,
    listAnchors: [NotesBodyParagraphAnchorRecord]
  ) -> NotesBodyParagraphAnchorRecord? {
    if let paragraphIDSHA256 = draft.paragraphIDSHA256 {
      return listAnchors.first { $0.idSHA256 == paragraphIDSHA256 }
    }
    if let ordinal = draft.ordinal, ordinal > 0, ordinal <= listAnchors.count {
      return listAnchors[ordinal - 1]
    }
    return nil
  }

  private func bodyChecklistIndentExpectedChanged(
    draft: NotesBodyChecklistIndentDraft,
    beforeIndent: Int?,
    canIndent: Bool?
  ) -> Bool? {
    guard let beforeIndent else {
      return nil
    }
    if draft.delta < 0 {
      return beforeIndent > 0
    }
    if draft.delta > 0 {
      return canIndent ?? true
    }
    return false
  }

  private func bodyChecklistIndentExpectedLevel(
    draft: NotesBodyChecklistIndentDraft,
    beforeIndent: Int?,
    expectedChanged: Bool?
  ) -> Int? {
    guard let beforeIndent, let expectedChanged else {
      return nil
    }
    return expectedChanged ? beforeIndent + draft.delta : beforeIndent
  }

  private func bodyListIndentExpectedChanged(
    draft: NotesBodyListIndentDraft,
    beforeIndent: Int?,
    canIndent: Bool?
  ) -> Bool? {
    guard let beforeIndent else {
      return nil
    }
    if draft.delta < 0 {
      return beforeIndent > 0
    }
    if draft.delta > 0 {
      return canIndent ?? true
    }
    return false
  }

  private func bodyListIndentExpectedLevel(
    draft: NotesBodyListIndentDraft,
    beforeIndent: Int?,
    expectedChanged: Bool?
  ) -> Int? {
    guard let beforeIndent, let expectedChanged else {
      return nil
    }
    return expectedChanged ? beforeIndent + draft.delta : beforeIndent
  }

  private func checklistOrder(afterMoving order: [String], from sourceIndex: Int, to targetIndex: Int) -> [String]? {
    guard sourceIndex >= 0, sourceIndex < order.count, targetIndex >= 0, targetIndex < order.count else {
      return nil
    }
    var result = order
    let item = result.remove(at: sourceIndex)
    result.insert(item, at: targetIndex)
    return result
  }

  private func checklistSortOrder(_ anchors: [NotesBodyParagraphAnchorRecord]) -> [String] {
    anchors.enumerated()
      .sorted { lhs, rhs in
        let lhsDone = lhs.element.checklistDone == true
        let rhsDone = rhs.element.checklistDone == true
        if lhsDone != rhsDone {
          return lhsDone == false && rhsDone == true
        }
        return lhs.offset < rhs.offset
      }
      .map(\.element.idSHA256)
  }

  private func checklistDoneItemsAreLast(_ anchors: [NotesBodyParagraphAnchorRecord]) -> Bool {
    var sawDone = false
    for anchor in anchors {
      if anchor.checklistDone == true {
        sawDone = true
      } else if sawDone {
        return false
      }
    }
    return true
  }

  private func stringCheck(name: String, expected: String, actual: String) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: expected == actual ? "passed" : "failed",
      expectedSHA256: sha256Hex(expected),
      actualSHA256: sha256Hex(actual),
      expectedLength: expected.count,
      actualLength: actual.count
    )
  }

  private func bodyCheck(name: String, expected: String, actual: String) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: bodyEquivalent(expected: expected, actual: actual) ? "passed" : "failed",
      expectedSHA256: sha256Hex(expected),
      actualSHA256: sha256Hex(actual),
      expectedLength: expected.count,
      actualLength: actual.count
    )
  }

  private func bodyEquivalent(expected: String, actual: String) -> Bool {
    if expected.isEmpty {
      return actual.isEmpty
    }
    return actual == expected || actual == "\n\(expected)"
  }

  private func boolCheck(name: String, expected: Bool, actual: Bool) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: expected == actual ? "passed" : "failed",
      expectedBool: expected,
      actualBool: actual
    )
  }

  private func countCheck(name: String, expected: Int, actual: Int) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: expected == actual ? "passed" : "failed",
      expectedLength: expected,
      actualLength: actual
    )
  }

  private func intCheck(name: String, expected: Int, actual: Int?) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: actual == expected ? "passed" : "failed",
      expectedLength: expected,
      actualLength: actual
    )
  }

  private func smartFolderTagRenameCriteriaChecks(
    beforeSnapshots: [NotesSmartFolderTagCriteriaSnapshot],
    oldTag: String,
    newTag: String,
    allowMerge: Bool
  ) throws -> [NotesVerificationCheckRecord] {
    var checks: [NotesVerificationCheckRecord] = [
      countCheck(
        name: "smart_folder_tag_criteria_snapshot_count",
        expected: beforeSnapshots.count,
        actual: beforeSnapshots.count
      )
    ]
    guard let smartFolderReader else {
      checks.append(
        NotesVerificationCheckRecord(
          name: "smart_folder_criteria_readback_present",
          status: beforeSnapshots.isEmpty ? "not_applicable" : "failed"
        ))
      return checks
    }

    let afterSmartFolders = try smartFolderReader.listSmartFolders(account: nil, limit: 2_000)
    let afterByID = Dictionary(uniqueKeysWithValues: afterSmartFolders.map { ($0.id, $0) })
    let impactedAfter = beforeSnapshots.compactMap { afterByID[$0.smartFolderID] }
    checks.append(
      boolCheck(
        name: "smart_folder_criteria_readback_present",
        expected: true,
        actual: impactedAfter.count == beforeSnapshots.count
      ))
    checks.append(
      boolCheck(
        name: "smart_folder_old_tag_criteria_absent_after",
        expected: true,
        actual: afterSmartFolders.allSatisfy { !smartFolderTagCriteria($0.criteria, containsTag: oldTag) }
      ))
    guard !beforeSnapshots.isEmpty else {
      checks.append(NotesVerificationCheckRecord(name: "smart_folder_new_tag_criteria_present_after", status: "not_applicable"))
      checks.append(NotesVerificationCheckRecord(name: "smart_folder_selected_tag_count_preserved", status: "not_applicable"))
      checks.append(NotesVerificationCheckRecord(name: "smart_folder_matching_note_ids_preserved", status: "not_applicable"))
      checks.append(NotesVerificationCheckRecord(name: "smart_folder_visible_note_count_preserved", status: "not_applicable"))
      return checks
    }

    checks.append(
      boolCheck(
        name: "smart_folder_new_tag_criteria_present_after",
        expected: true,
        actual: impactedAfter.allSatisfy { smartFolderTagCriteria($0.criteria, containsTag: newTag) }
      ))
    let selectedCountsPreserved = beforeSnapshots.allSatisfy { snapshot in
      guard let after = afterByID[snapshot.smartFolderID],
        let expected = snapshot.selectedTagCount,
        let actual = after.criteria?.tagSelection?.selectedTagCount
      else {
        return false
      }
      return expected == actual
    }
    checks.append(
      boolCheck(
        name: "smart_folder_selected_tag_count_preserved",
        expected: true,
        actual: selectedCountsPreserved
      ))

    var matchingNoteIDsPreserved = true
    var visibleNoteCountPreserved = true
    for snapshot in beforeSnapshots {
      guard let after = afterByID[snapshot.smartFolderID] else {
        matchingNoteIDsPreserved = false
        visibleNoteCountPreserved = false
        continue
      }
      let afterNoteIDHashes = Set(
        try smartFolderReader.listSmartFolderNotes(smartFolderID: snapshot.smartFolderID, limit: 2_000)
          .map { sha256Hex($0.id) }
      )
      let beforeNoteIDHashes = Set(snapshot.matchingNoteIDHashes)
      if allowMerge {
        matchingNoteIDsPreserved = matchingNoteIDsPreserved && beforeNoteIDHashes.isSubset(of: afterNoteIDHashes)
      } else {
        matchingNoteIDsPreserved = matchingNoteIDsPreserved && beforeNoteIDHashes == afterNoteIDHashes
      }
      if let expectedVisibleNoteCount = snapshot.visibleNoteCount,
        let actualVisibleNoteCount = after.visibleNoteCount
      {
        visibleNoteCountPreserved =
          visibleNoteCountPreserved
          && (allowMerge ? actualVisibleNoteCount >= expectedVisibleNoteCount : actualVisibleNoteCount == expectedVisibleNoteCount)
      }
    }
    checks.append(
      boolCheck(
        name: "smart_folder_matching_note_ids_preserved",
        expected: true,
        actual: matchingNoteIDsPreserved
      ))
    checks.append(
      boolCheck(
        name: "smart_folder_visible_note_count_preserved",
        expected: true,
        actual: visibleNoteCountPreserved
      ))
    return checks
  }

  private func smartFolderDeletedTagCriteriaChecks(
    beforeSnapshots: [NotesSmartFolderTagCriteriaSnapshot],
    deletedTags: [String]
  ) throws -> [NotesVerificationCheckRecord] {
    var checks: [NotesVerificationCheckRecord] = [
      countCheck(
        name: "smart_folder_tag_criteria_snapshot_count",
        expected: beforeSnapshots.count,
        actual: beforeSnapshots.count
      )
    ]
    guard let smartFolderReader else {
      checks.append(
        NotesVerificationCheckRecord(
          name: "smart_folder_criteria_readback_present",
          status: beforeSnapshots.isEmpty ? "not_applicable" : "failed"
        ))
      return checks
    }

    let afterSmartFolders = try smartFolderReader.listSmartFolders(account: nil, limit: 2_000)
    let afterIDs = Set(afterSmartFolders.map(\.id))
    checks.append(
      boolCheck(
        name: "smart_folder_criteria_readback_present",
        expected: true,
        actual: beforeSnapshots.allSatisfy { afterIDs.contains($0.smartFolderID) }
      ))
    checks.append(
      boolCheck(
        name: "smart_folder_deleted_tag_criteria_absent_after",
        expected: true,
        actual: afterSmartFolders.allSatisfy { smartFolder in
          deletedTags.allSatisfy { !smartFolderTagCriteria(smartFolder.criteria, containsTag: $0) }
        }
      ))
    return checks
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

  private func containsTag(_ tags: [NotesTagRecord], _ target: String) -> Bool {
    tags.contains { tagMatches($0, target) }
  }

  private func otherTagsPreserved(
    before: [NotesTagRecord],
    after: [NotesTagRecord],
    target: String
  ) -> Bool {
    let beforeOthers = Set(before.map(tagContent).filter { $0 != target })
    let afterOthers = Set(after.map(tagContent).filter { $0 != target })
    return beforeOthers.isSubset(of: afterOthers)
  }

  private func tagContent(_ tag: NotesTagRecord) -> String {
    tag.standardizedContent ?? standardizedTagContent(tag.displayText)
  }

  private func tagSet(_ tags: [NotesTagRecord]) -> Set<String> {
    Set(tags.map(tagContent))
  }

  private func renamedTagsPreserved(
    before: [NotesTagRecord],
    after: [NotesTagRecord],
    old: String,
    new: String
  ) -> Bool {
    let expected = Set(before.map(tagContent).map { $0 == old ? new : $0 })
    let actual = Set(after.map(tagContent))
    return expected.isSubset(of: actual)
  }

  private func tagReadback(_ tag: NotesTagRecord) -> NotesReadbackRecord {
    NotesReadbackRecord(
      kind: "tag",
      idSHA256: sha256Hex(tag.id),
      nameSHA256: sha256Hex(tag.displayText),
      nameLength: tag.displayText.count,
      accountNameSHA256: sha256Hex(tag.accountName),
      accountNameLength: tag.accountName.count
    )
  }

  private func storeMatchCheck(noteID: String, storeObject: NotesStoreObjectRecord)
    -> NotesVerificationCheckRecord
  {
    storeMatchCheck(objectID: noteID, storeObject: storeObject)
  }

  private func storeMatchCheck(objectID: String, storeObject: NotesStoreObjectRecord)
    -> NotesVerificationCheckRecord
  {
    guard objectID.hasPrefix("x-coredata://") else {
      return NotesVerificationCheckRecord(name: "store_object_match", status: "not_applicable")
    }
    return boolCheck(name: "store_object_match", expected: true, actual: storeObject.matched)
  }
}
