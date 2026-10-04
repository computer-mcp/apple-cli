import Foundation
import Utility

extension NotesCommand {
  func runLinks(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["links", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let links = try linkReader().listLinks(
        noteID: id,
        limit: try commandLimit(options)
      )
      return try result(
        NotesLinksResponse(noteID: id, links: links),
        human: links.map { link in
          [
            link.id,
            link.kind,
            link.displayText ?? "",
            link.urlString ?? link.urlScheme ?? "",
          ].joined(separator: "\t")
        }.joined(separator: "\n"),
        options: options
      )
    case ["links", "audit"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      return try linkWorkflowAudit(options)
    case ["links", "backlinks"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      let backlinks = try linkReader().listBacklinks(
        noteID: id,
        limit: try commandLimit(options)
      )
      return try result(
        NotesBacklinksResponse(noteID: id, backlinks: backlinks),
        human: backlinks.map { backlink in
          [
            backlink.sourceNote.id,
            backlink.sourceNote.title,
            backlink.link.id,
            backlink.link.kind,
            backlink.link.displayText ?? "",
            backlink.link.urlString ?? backlink.link.urlScheme ?? "",
          ].joined(separator: "\t")
        }.joined(separator: "\n"),
        options: options
      )
    case ["links", "resolve"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "link"])
      let id = try requiredOption("id", options: options)
      let linkID = try requiredOption("link", options: options)
      let resolution = try linkReader().resolveLink(noteID: id, linkID: linkID)
      let verification = try verifyLinkResolution(resolution)
      return try result(
        NotesLinkResolutionResponse(
          noteID: resolution.noteID,
          requestedLinkID: resolution.requestedLinkID,
          link: resolution.link,
          destination: resolution.destination,
          verification: verification
        ),
        human: [
          resolution.noteID,
          resolution.link.id,
          resolution.link.kind,
          resolution.destination.kind,
          resolution.destination.targetNoteID
            ?? resolution.destination.publicURLString
            ?? resolution.destination.urlScheme
            ?? "",
        ].joined(separator: "\t"),
        options: options
      )
    case ["links", "add"]:
      try validateTargetOptions(options, allowedOptions: ["id", "url", "paragraph", "ordinal", "text", "occurrence"])
      try validateMutationIntent(options)
      let draft = try linkAddDraft(options)
      return try mutation(
        operation: "notes.links.add",
        scopeDigest: linkAddScopeDigest(draft),
        summary: linkAddSummary(draft),
        options: options
      ) {
        let write = try linkMutator().addLink(draft)
        let verification = try verifyLinkAdd(
          draft: draft,
          result: write,
          operation: "notes.links.add"
        )
        let result = NotesLinkAddResult(
          operation: "notes.links.add",
          changed: true,
          noteID: write.noteID,
          link: linkAddResultRecord(write.link, draft: draft),
          urlSHA256: sha256Hex(draft.urlString),
          selectedTextConverted: draft.convertsSelectedText,
          selectedTextParagraphIDSHA256: write.selectedTextParagraphIDSHA256,
          selectedTextOrdinal: write.selectedTextOrdinal,
          selectedTextByteCount: write.selectedTextByteCount,
          selectedTextSHA256: write.selectedTextSHA256,
          selectedTextOccurrence: write.selectedTextOccurrence,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes link add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.add",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "add-app"]:
      try validateTargetOptions(options, allowedOptions: ["id", "url", "paragraph", "ordinal", "text", "occurrence"])
      try validateMutationIntent(options)
      let draft = try appLinkAddDraft(options)
      return try mutation(
        operation: "notes.links.add-app",
        scopeDigest: appLinkAddScopeDigest(draft),
        summary: appLinkAddSummary(draft),
        options: options
      ) {
        let write = try linkMutator().addAppLink(draft)
        let verification = try verifyAppLinkAdd(
          draft: draft,
          result: write,
          operation: "notes.links.add-app"
        )
        let result = NotesLinkAddResult(
          operation: "notes.links.add-app",
          changed: true,
          noteID: write.noteID,
          link: linkAddResultRecord(write.link, draft: draft),
          urlSHA256: sha256Hex(draft.urlString),
          selectedTextConverted: draft.convertsSelectedText,
          selectedTextParagraphIDSHA256: write.selectedTextParagraphIDSHA256,
          selectedTextOrdinal: write.selectedTextOrdinal,
          selectedTextByteCount: write.selectedTextByteCount,
          selectedTextSHA256: write.selectedTextSHA256,
          selectedTextOccurrence: write.selectedTextOccurrence,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes app link add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.add-app",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "add-file"]:
      try validateTargetOptions(options, allowedOptions: ["id", "file", "paragraph", "ordinal", "text", "occurrence"])
      try validateMutationIntent(options)
      let draft = try fileLinkAddDraft(options)
      return try mutation(
        operation: "notes.links.add-file",
        scopeDigest: fileLinkAddScopeDigest(draft),
        summary: fileLinkAddSummary(draft),
        options: options
      ) {
        let write = try linkMutator().addFileLink(draft)
        let verification = try verifyFileLinkAdd(
          draft: draft,
          result: write,
          operation: "notes.links.add-file"
        )
        let result = NotesLinkAddResult(
          operation: "notes.links.add-file",
          changed: true,
          noteID: write.noteID,
          link: linkAddResultRecord(write.link, draft: draft),
          urlSHA256: sha256Hex(draft.urlString),
          selectedTextConverted: draft.convertsSelectedText,
          selectedTextParagraphIDSHA256: write.selectedTextParagraphIDSHA256,
          selectedTextOrdinal: write.selectedTextOrdinal,
          selectedTextByteCount: write.selectedTextByteCount,
          selectedTextSHA256: write.selectedTextSHA256,
          selectedTextOccurrence: write.selectedTextOccurrence,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes file link add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.add-file",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "add-note"]:
      try validateTargetOptions(options, allowedOptions: ["id", "target", "text"], allowedFlags: ["use-note-title"])
      try validateMutationIntent(options)
      let draft = try noteLinkAddDraft(options)
      return try mutation(
        operation: "notes.links.add-note",
        scopeDigest: noteLinkAddScopeDigest(draft),
        summary: noteLinkAddSummary(draft),
        options: options
      ) {
        let write = try linkMutator().addNoteLink(draft)
        let verification = try verifyNoteLinkAdd(
          draft: draft,
          result: write,
          operation: "notes.links.add-note"
        )
        let result = NotesNoteLinkAddResult(
          operation: "notes.links.add-note",
          changed: true,
          noteID: write.sourceNoteID,
          targetNoteID: write.targetNoteID,
          targetNoteIDSHA256: sha256Hex(write.targetNoteID),
          displayTextMode: draft.displayText?.mode,
          displayTextSHA256: draft.displayText?.displayTextSHA256,
          displayTextByteCount: draft.displayText?.displayTextByteCount,
          displayTextSourceKind: draft.displayText?.sourceKind,
          link: noteLinkResultRecord(write.link, displayText: draft.displayText),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes note link add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.add-note",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "add-paragraph"]:
      try validateTargetOptions(options, allowedOptions: ["id", "target", "paragraph"])
      try validateMutationIntent(options)
      let draft = try paragraphLinkAddDraft(options)
      return try mutation(
        operation: "notes.links.add-paragraph",
        scopeDigest: paragraphLinkAddScopeDigest(draft),
        summary: paragraphLinkAddSummary(draft),
        options: options
      ) {
        let write = try linkMutator().addParagraphLink(draft)
        let verification = try verifyParagraphLinkAdd(
          draft: draft,
          result: write,
          operation: "notes.links.add-paragraph"
        )
        let result = NotesParagraphLinkAddResult(
          operation: "notes.links.add-paragraph",
          changed: true,
          noteID: write.sourceNoteID,
          targetNoteID: write.targetNoteID,
          targetNoteIDSHA256: sha256Hex(write.targetNoteID),
          targetParagraphIDSHA256: write.targetParagraphIDSHA256,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes paragraph link add verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.add-paragraph",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "update"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link", "url"])
      try validateMutationIntent(options)
      let draft = try linkUpdateDraft(options)
      return try mutation(
        operation: "notes.links.update",
        scopeDigest: linkUpdateScopeDigest(draft),
        summary: linkUpdateSummary(draft),
        options: options
      ) {
        let write = try linkMutator().updateLink(draft)
        let verification = try verifyLinkUpdate(
          draft: draft,
          result: write,
          operation: "notes.links.update"
        )
        let result = NotesLinkUpdateResult(
          operation: "notes.links.update",
          changed: write.changed,
          noteID: write.noteID,
          oldLink: write.oldLink,
          link: write.link,
          oldURLSHA256: write.oldLink.urlString.map(sha256Hex) ?? write.oldLink.urlSHA256,
          urlSHA256: sha256Hex(draft.urlString),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes link update verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.update",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "update-app"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link", "url"])
      try validateMutationIntent(options)
      let draft = try appLinkUpdateDraft(options)
      return try mutation(
        operation: "notes.links.update-app",
        scopeDigest: appLinkUpdateScopeDigest(draft),
        summary: appLinkUpdateSummary(draft),
        options: options
      ) {
        let write = try linkMutator().updateAppLink(draft)
        let verification = try verifyAppLinkUpdate(
          draft: draft,
          result: write,
          operation: "notes.links.update-app"
        )
        let result = NotesLinkUpdateResult(
          operation: "notes.links.update-app",
          changed: write.changed,
          noteID: write.noteID,
          oldLink: write.oldLink,
          link: write.link,
          oldURLSHA256: write.oldLink.urlString.map(sha256Hex) ?? write.oldLink.urlSHA256,
          urlSHA256: sha256Hex(draft.urlString),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes app link update verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.update-app",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "update-file"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link", "file"])
      try validateMutationIntent(options)
      let draft = try fileLinkUpdateDraft(options)
      return try mutation(
        operation: "notes.links.update-file",
        scopeDigest: fileLinkUpdateScopeDigest(draft),
        summary: fileLinkUpdateSummary(draft),
        options: options
      ) {
        let write = try linkMutator().updateFileLink(draft)
        let verification = try verifyFileLinkUpdate(
          draft: draft,
          result: write,
          operation: "notes.links.update-file"
        )
        let result = NotesLinkUpdateResult(
          operation: "notes.links.update-file",
          changed: write.changed,
          noteID: write.noteID,
          oldLink: write.oldLink,
          link: write.link,
          oldURLSHA256: write.oldLink.urlString.map(sha256Hex) ?? write.oldLink.urlSHA256,
          urlSHA256: sha256Hex(draft.urlString),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes file link update verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.update-file",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "update-note"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link", "target", "text"], allowedFlags: ["use-note-title"])
      try validateMutationIntent(options)
      let draft = try noteLinkUpdateDraft(options)
      return try mutation(
        operation: "notes.links.update-note",
        scopeDigest: noteLinkUpdateScopeDigest(draft),
        summary: noteLinkUpdateSummary(draft),
        options: options
      ) {
        let write = try linkMutator().updateNoteLink(draft)
        let verification = try verifyNoteLinkUpdate(
          draft: draft,
          result: write,
          operation: "notes.links.update-note"
        )
        let result = NotesNoteLinkUpdateResult(
          operation: "notes.links.update-note",
          changed: write.changed,
          noteID: write.sourceNoteID,
          oldTargetNoteIDSHA256: sha256Hex(write.oldTargetNoteID),
          targetNoteID: write.targetNoteID,
          targetNoteIDSHA256: sha256Hex(write.targetNoteID),
          displayTextMode: draft.displayText?.mode,
          displayTextSHA256: draft.displayText?.displayTextSHA256,
          displayTextByteCount: draft.displayText?.displayTextByteCount,
          displayTextSourceKind: draft.displayText?.sourceKind,
          oldLink: noteLinkResultRecord(write.oldLink, displayText: draft.displayText),
          link: noteLinkResultRecord(write.link, displayText: draft.displayText),
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes note link update verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.update-note",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "update-paragraph"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link", "target", "paragraph"])
      try validateMutationIntent(options)
      let draft = try paragraphLinkUpdateDraft(options)
      return try mutation(
        operation: "notes.links.update-paragraph",
        scopeDigest: paragraphLinkUpdateScopeDigest(draft),
        summary: paragraphLinkUpdateSummary(draft),
        options: options
      ) {
        let write = try linkMutator().updateParagraphLink(draft)
        let verification = try verifyParagraphLinkUpdate(
          draft: draft,
          result: write,
          operation: "notes.links.update-paragraph"
        )
        let result = NotesParagraphLinkUpdateResult(
          operation: "notes.links.update-paragraph",
          changed: write.changed,
          noteID: write.sourceNoteID,
          oldTargetNoteIDSHA256: sha256Hex(write.oldTargetNoteID),
          targetNoteID: write.targetNoteID,
          targetNoteIDSHA256: sha256Hex(write.targetNoteID),
          oldTargetParagraphIDSHA256: write.oldTargetParagraphIDSHA256,
          targetParagraphIDSHA256: write.targetParagraphIDSHA256,
          oldTokenContentIdentifierSHA256: write.oldTokenContentIdentifierSHA256,
          targetTokenContentIdentifierSHA256: write.targetTokenContentIdentifierSHA256,
          oldLink: write.oldLink,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes paragraph link update verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.update-paragraph",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "remove"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link"])
      try validateMutationIntent(options)
      let draft = try linkRemoveDraft(options)
      return try mutation(
        operation: "notes.links.remove",
        scopeDigest: linkRemoveScopeDigest(draft),
        summary: linkRemoveSummary(draft),
        options: options
      ) {
        let write = try linkMutator().removeLink(draft)
        let verification = try verifyLinkRemove(
          draft: draft,
          result: write,
          operation: "notes.links.remove"
        )
        let result = NotesLinkRemoveResult(
          operation: "notes.links.remove",
          changed: write.changed,
          noteID: write.noteID,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes link remove verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.remove",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "remove-app"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link"])
      try validateMutationIntent(options)
      let draft = try appLinkRemoveDraft(options)
      return try mutation(
        operation: "notes.links.remove-app",
        scopeDigest: appLinkRemoveScopeDigest(draft),
        summary: appLinkRemoveSummary(draft),
        options: options
      ) {
        let write = try linkMutator().removeAppLink(draft)
        let verification = try verifyAppLinkRemove(
          draft: draft,
          result: write,
          operation: "notes.links.remove-app"
        )
        let result = NotesLinkRemoveResult(
          operation: "notes.links.remove-app",
          changed: write.changed,
          noteID: write.noteID,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes app link remove verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.remove-app",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "remove-file"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link"])
      try validateMutationIntent(options)
      let draft = try fileLinkRemoveDraft(options)
      return try mutation(
        operation: "notes.links.remove-file",
        scopeDigest: fileLinkRemoveScopeDigest(draft),
        summary: fileLinkRemoveSummary(draft),
        options: options
      ) {
        let write = try linkMutator().removeFileLink(draft)
        let verification = try verifyFileLinkRemove(
          draft: draft,
          result: write,
          operation: "notes.links.remove-file"
        )
        let result = NotesLinkRemoveResult(
          operation: "notes.links.remove-file",
          changed: write.changed,
          noteID: write.noteID,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes file link remove verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.remove-file",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "remove-note"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link"])
      try validateMutationIntent(options)
      let draft = try noteLinkRemoveDraft(options)
      return try mutation(
        operation: "notes.links.remove-note",
        scopeDigest: noteLinkRemoveScopeDigest(draft),
        summary: noteLinkRemoveSummary(draft),
        options: options
      ) {
        let write = try linkMutator().removeNoteLink(draft)
        let verification = try verifyNoteLinkRemove(
          draft: draft,
          result: write,
          operation: "notes.links.remove-note"
        )
        let result = NotesNoteLinkRemoveResult(
          operation: "notes.links.remove-note",
          changed: write.changed,
          noteID: write.noteID,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes note link remove verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.remove-note",
              verification: verification
            )
          )
        }
        return result
      }
    case ["links", "remove-paragraph"]:
      try validateTargetOptions(options, allowedOptions: ["id", "link"])
      try validateMutationIntent(options)
      let draft = try paragraphLinkRemoveDraft(options)
      return try mutation(
        operation: "notes.links.remove-paragraph",
        scopeDigest: paragraphLinkRemoveScopeDigest(draft),
        summary: paragraphLinkRemoveSummary(draft),
        options: options
      ) {
        let write = try linkMutator().removeParagraphLink(draft)
        let verification = try verifyParagraphLinkRemove(
          draft: draft,
          result: write,
          operation: "notes.links.remove-paragraph"
        )
        let result = NotesParagraphLinkRemoveResult(
          operation: "notes.links.remove-paragraph",
          changed: write.changed,
          noteID: write.noteID,
          link: write.link,
          verification: verification
        )
        guard verification.verified else {
          throw CLIError(
            code: .internalError,
            message: "Notes paragraph link remove verification failed.",
            details: artifactVerificationFailureDetails(
              operation: "notes.links.remove-paragraph",
              verification: verification
            )
          )
        }
        return result
      }    default:
      return nil
    }
  }

  private func linkAddDraft(_ options: CLIOptions) throws -> NotesLinkAddDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.add"
      )
    }

    let url = try normalizedWebURL(try requiredOption("url", options: options))
    let selection = try linkSelectedTextOptions(options, commandName: "links add")
    return NotesLinkAddDraft(
      noteID: note.id,
      url: url,
      urlString: url.absoluteString,
      paragraphIDSHA256: selection.paragraphIDSHA256,
      ordinal: selection.ordinal,
      selectedText: selection.text,
      occurrence: selection.occurrence
    )
  }

  private func appLinkAddDraft(_ options: CLIOptions) throws -> NotesLinkAddDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.add-app"
      )
    }

    let url = try normalizedAppURL(try requiredOption("url", options: options))
    let selection = try linkSelectedTextOptions(options, commandName: "links add-app")
    return NotesLinkAddDraft(
      noteID: note.id,
      url: url,
      urlString: url.absoluteString,
      paragraphIDSHA256: selection.paragraphIDSHA256,
      ordinal: selection.ordinal,
      selectedText: selection.text,
      occurrence: selection.occurrence
    )
  }

  private func fileLinkAddDraft(_ options: CLIOptions) throws -> NotesLinkAddDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.add-file"
      )
    }

    let source = try notesFileLinkSource(path: try requiredOption("file", options: options))
    let selection = try linkSelectedTextOptions(options, commandName: "links add-file")
    return NotesLinkAddDraft(
      noteID: note.id,
      url: source.url,
      urlString: source.urlString,
      sourceKind: source.kind,
      paragraphIDSHA256: selection.paragraphIDSHA256,
      ordinal: selection.ordinal,
      selectedText: selection.text,
      occurrence: selection.occurrence
    )
  }

  private func linkSelectedTextOptions(
    _ options: CLIOptions,
    commandName: String
  ) throws -> (paragraphIDSHA256: String?, ordinal: Int?, text: String?, occurrence: Int?) {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    let text = try options.targetOption("text").map { _ in
      try normalizedOption("text", options: options)
    }
    let occurrence = try options.targetOption("occurrence").map { _ in
      try normalizedPositiveIntOption("occurrence", options: options)
    }
    let usesSelection = paragraph != nil || ordinal != nil || text != nil || occurrence != nil
    guard usesSelection else {
      return (nil, nil, nil, nil)
    }
    guard text != nil else {
      throw CLIError(
        code: .validationError,
        message: "`\(commandName)` selected-text mode requires `--text`.",
        details: ["required": "text", "allowed": "paragraph,ordinal,text,occurrence"]
      )
    }
    try validateParagraphSelector(paragraph: paragraph, ordinal: ordinal, commandName: commandName)
    return (paragraph, ordinal, text, occurrence)
  }

  private func noteLinkAddDraft(_ options: CLIOptions) throws -> NotesNoteLinkAddDraft {
    let requestedSourceID = try requiredOption("id", options: options)
    guard let sourceNote = try implementation.readNote(id: requestedSourceID) else {
      throw CLIError(
        code: .notFound,
        message: "Source note was not found.",
        details: ["id_sha256": sha256Hex(requestedSourceID)]
      )
    }

    let requestedTargetID = try requiredOption("target", options: options)
    guard let targetNote = try implementation.readNote(id: requestedTargetID) else {
      throw CLIError(
        code: .notFound,
        message: "Target note was not found.",
        details: ["target_sha256": sha256Hex(requestedTargetID)]
      )
    }

    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: sourceNote.id),
        operation: "notes.links.add-note"
      )
      try validateNoteLinkDestinationState(
        try stateReader.readNoteState(noteID: targetNote.id),
        operation: "notes.links.add-note"
      )
    }

    return NotesNoteLinkAddDraft(
      sourceNoteID: sourceNote.id,
      targetNoteID: targetNote.id,
      requestedTargetNoteID: requestedTargetID,
      displayText: try noteLinkDisplayTextDraft(options, targetNote: targetNote)
    )
  }

  private func noteLinkDisplayTextDraft(
    _ options: CLIOptions,
    targetNote: NotesNoteDetail
  ) throws -> NotesNoteLinkDisplayTextDraft? {
    let requestedUseNoteTitle = options.targetFlags.contains("use-note-title")
    let customText = try normalizedOptionalOption("text", options: options)
    guard customText == nil || !requestedUseNoteTitle else {
      throw CLIError(
        code: .validationError,
        message: "`--text` and `--use-note-title` are mutually exclusive.",
        details: ["options": "--text,--use-note-title"]
      )
    }

    if let customText {
      return NotesNoteLinkDisplayTextDraft(
        mode: "custom",
        displayText: customText,
        displayTextSHA256: sha256Hex(customText),
        displayTextByteCount: customText.utf8.count,
        sourceKind: "ICInlineAttachment.altText"
      )
    }

    guard requestedUseNoteTitle else {
      return nil
    }

    return NotesNoteLinkDisplayTextDraft(
      mode: "target_title",
      displayTextSHA256: sha256Hex(targetNote.title),
      displayTextByteCount: targetNote.title.utf8.count,
      sourceKind: "ICInlineAttachment.displayText"
    )
  }

  private func paragraphLinkAddDraft(_ options: CLIOptions) throws -> NotesParagraphLinkAddDraft {
    let requestedSourceID = try requiredOption("id", options: options)
    guard let sourceNote = try implementation.readNote(id: requestedSourceID) else {
      throw CLIError(
        code: .notFound,
        message: "Source note was not found.",
        details: ["id_sha256": sha256Hex(requestedSourceID)]
      )
    }

    let requestedTargetID = try requiredOption("target", options: options)
    guard let targetNote = try implementation.readNote(id: requestedTargetID) else {
      throw CLIError(
        code: .notFound,
        message: "Target note was not found.",
        details: ["target_sha256": sha256Hex(requestedTargetID)]
      )
    }

    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: sourceNote.id),
        operation: "notes.links.add-paragraph"
      )
      try validateNoteLinkDestinationState(
        try stateReader.readNoteState(noteID: targetNote.id),
        operation: "notes.links.add-paragraph"
      )
    }

    let requestedParagraph = try requiredOption("paragraph", options: options)
    let resolution = try paragraphAnchorResolver().resolveParagraphAnchor(
      noteID: targetNote.id,
      paragraphIDSHA256: requestedParagraph
    )
    return NotesParagraphLinkAddDraft(
      sourceNoteID: sourceNote.id,
      targetNoteID: targetNote.id,
      requestedTargetNoteID: requestedTargetID,
      targetParagraphID: resolution.paragraphID,
      requestedTargetParagraphIDSHA256: requestedParagraph,
      targetParagraphIDSHA256: resolution.anchor.idSHA256,
      targetParagraphTitle: resolution.title
    )
  }

  private func linkUpdateDraft(_ options: CLIOptions) throws -> NotesLinkUpdateDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.update"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateWebURLLinkUpdateTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)

    let url = try normalizedWebURL(try requiredOption("url", options: options))
    let normalizedCurrent = normalizedLinkURLForMatching(link.urlString)
    let normalizedTarget = normalizedLinkURLForMatching(url.absoluteString)
    guard normalizedCurrent != normalizedTarget else {
      throw CLIError(
        code: .validationError,
        message: "Notes link update requires a changed http or https URL.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "url_sha256": sha256Hex(url.absoluteString),
        ]
      )
    }

    return NotesLinkUpdateDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link,
      url: url,
      urlString: url.absoluteString
    )
  }

  private func appLinkUpdateDraft(_ options: CLIOptions) throws -> NotesLinkUpdateDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.update-app"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateAppURLLinkUpdateTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)

    let url = try normalizedAppURL(try requiredOption("url", options: options))
    let newURLSHA256 = sha256Hex(url.absoluteString)
    let oldURLSHA256 = link.urlString.map(sha256Hex) ?? link.urlSHA256
    let normalizedCurrent = normalizedLinkURLForMatching(link.urlString)
    let normalizedTarget = normalizedLinkURLForMatching(url.absoluteString)
    guard oldURLSHA256 != newURLSHA256 && normalizedCurrent != normalizedTarget else {
      throw CLIError(
        code: .validationError,
        message: "Notes app link update requires a changed app URL.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "url_sha256": newURLSHA256,
        ]
      )
    }

    return NotesLinkUpdateDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link,
      url: url,
      urlString: url.absoluteString
    )
  }

  private func fileLinkUpdateDraft(_ options: CLIOptions) throws -> NotesLinkUpdateDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.update-file"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateFileURLLinkUpdateTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)

    let source = try notesFileLinkSource(path: try requiredOption("file", options: options))
    let newURLSHA256 = sha256Hex(source.urlString)
    let oldURLSHA256 = link.urlString.map(sha256Hex) ?? link.urlSHA256
    let normalizedCurrent = normalizedLinkURLForMatching(link.urlString)
    let normalizedTarget = normalizedLinkURLForMatching(source.urlString)
    guard oldURLSHA256 != newURLSHA256 && normalizedCurrent != normalizedTarget else {
      throw CLIError(
        code: .validationError,
        message: "Notes file link update requires a changed file URL.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "url_sha256": newURLSHA256,
        ]
      )
    }

    return NotesLinkUpdateDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link,
      url: source.url,
      urlString: source.urlString,
      sourceKind: source.kind
    )
  }

  private func noteLinkUpdateDraft(_ options: CLIOptions) throws -> NotesNoteLinkUpdateDraft {
    let requestedSourceID = try requiredOption("id", options: options)
    guard let sourceNote = try implementation.readNote(id: requestedSourceID) else {
      throw CLIError(
        code: .notFound,
        message: "Source note was not found.",
        details: ["id_sha256": sha256Hex(requestedSourceID)]
      )
    }

    let requestedTargetID = try requiredOption("target", options: options)
    guard let targetNote = try implementation.readNote(id: requestedTargetID) else {
      throw CLIError(
        code: .notFound,
        message: "Target note was not found.",
        details: ["target_sha256": sha256Hex(requestedTargetID)]
      )
    }

    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: sourceNote.id),
        operation: "notes.links.update-note"
      )
      try validateNoteLinkDestinationState(
        try stateReader.readNoteState(noteID: targetNote.id),
        operation: "notes.links.update-note"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: sourceNote.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(sourceNote.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(sourceNote.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validatePlainNoteLinkUpdateTarget(link, noteID: sourceNote.id, requestedLinkID: requestedLinkID)

    return NotesNoteLinkUpdateDraft(
      sourceNoteID: sourceNote.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link,
      targetNoteID: targetNote.id,
      requestedTargetNoteID: requestedTargetID,
      displayText: try noteLinkDisplayTextDraft(options, targetNote: targetNote)
    )
  }

  private func paragraphLinkUpdateDraft(_ options: CLIOptions) throws -> NotesParagraphLinkUpdateDraft {
    let requestedSourceID = try requiredOption("id", options: options)
    guard let sourceNote = try implementation.readNote(id: requestedSourceID) else {
      throw CLIError(
        code: .notFound,
        message: "Source note was not found.",
        details: ["id_sha256": sha256Hex(requestedSourceID)]
      )
    }

    let requestedTargetID = try requiredOption("target", options: options)
    guard let targetNote = try implementation.readNote(id: requestedTargetID) else {
      throw CLIError(
        code: .notFound,
        message: "Target note was not found.",
        details: ["target_sha256": sha256Hex(requestedTargetID)]
      )
    }

    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: sourceNote.id),
        operation: "notes.links.update-paragraph"
      )
      try validateNoteLinkDestinationState(
        try stateReader.readNoteState(noteID: targetNote.id),
        operation: "notes.links.update-paragraph"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: sourceNote.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(sourceNote.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(sourceNote.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateParagraphLinkUpdateTarget(link, noteID: sourceNote.id, requestedLinkID: requestedLinkID)

    let requestedParagraph = try requiredOption("paragraph", options: options)
    let resolution = try paragraphAnchorResolver().resolveParagraphAnchor(
      noteID: targetNote.id,
      paragraphIDSHA256: requestedParagraph
    )
    return NotesParagraphLinkUpdateDraft(
      sourceNoteID: sourceNote.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link,
      targetNoteID: targetNote.id,
      requestedTargetNoteID: requestedTargetID,
      targetParagraphID: resolution.paragraphID,
      requestedTargetParagraphIDSHA256: requestedParagraph,
      targetParagraphIDSHA256: resolution.anchor.idSHA256,
      targetParagraphTitle: resolution.title
    )
  }

  private func linkRemoveDraft(_ options: CLIOptions) throws -> NotesLinkRemoveDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.remove"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateWebURLLinkRemoveTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)
    return NotesLinkRemoveDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link
    )
  }

  private func appLinkRemoveDraft(_ options: CLIOptions) throws -> NotesLinkRemoveDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.remove-app"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateAppURLLinkRemoveTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)
    return NotesLinkRemoveDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link
    )
  }

  private func fileLinkRemoveDraft(_ options: CLIOptions) throws -> NotesLinkRemoveDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.remove-file"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateFileURLLinkRemoveTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)
    return NotesLinkRemoveDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link
    )
  }

  private func noteLinkRemoveDraft(_ options: CLIOptions) throws -> NotesNoteLinkRemoveDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.remove-note"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validatePlainNoteLinkRemoveTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)
    return NotesNoteLinkRemoveDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link
    )
  }

  private func paragraphLinkRemoveDraft(_ options: CLIOptions) throws -> NotesParagraphLinkRemoveDraft {
    let requestedID = try requiredOption("id", options: options)
    guard let note = try implementation.readNote(id: requestedID) else {
      throw CLIError(
        code: .notFound,
        message: "Note was not found.",
        details: ["id_sha256": sha256Hex(requestedID)]
      )
    }
    if let stateReader = implementation as? any NotesNoteStateReading {
      try validateLinkMutationState(
        try stateReader.readNoteState(noteID: note.id),
        operation: "notes.links.remove-paragraph"
      )
    }

    let requestedLinkID = try requiredOption("link", options: options)
    let matches = try linkReader().listLinks(noteID: note.id, limit: 2_000)
      .filter { linkRecordMatches($0, selector: requestedLinkID) }
    guard let link = matches.first else {
      throw CLIError(
        code: .notFound,
        message: "Link selector did not match any link on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
        ]
      )
    }
    guard matches.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Link selector matched multiple links on the note.",
        details: [
          "id_sha256": sha256Hex(note.id),
          "link_sha256": sha256Hex(requestedLinkID),
          "match_count": "\(matches.count)",
        ]
      )
    }
    try validateParagraphLinkRemoveTarget(link, noteID: note.id, requestedLinkID: requestedLinkID)
    return NotesParagraphLinkRemoveDraft(
      noteID: note.id,
      linkID: link.id,
      requestedLinkID: requestedLinkID,
      link: link
    )
  }

  func normalizedWebURL(_ value: String) throws -> URL {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, var components = URLComponents(string: trimmed) else {
      throw CLIError(code: .validationError, message: "`--url` must be a valid http or https URL.")
    }
    let scheme = components.scheme?.lowercased()
    guard scheme == "http" || scheme == "https" else {
      throw CLIError(
        code: .validationError,
        message: "`--url` must use http or https for Notes link add.",
        details: ["scheme": scheme ?? ""]
      )
    }
    guard let host = components.host, !host.isEmpty else {
      throw CLIError(code: .validationError, message: "`--url` must include a host.")
    }
    components.scheme = scheme
    components.host = host.lowercased()
    guard let url = components.url else {
      throw CLIError(code: .validationError, message: "`--url` must be a valid http or https URL.")
    }
    return url
  }

  private func normalizedAppURL(_ value: String) throws -> URL {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, var components = URLComponents(string: trimmed) else {
      throw CLIError(code: .validationError, message: "`--url` must be a valid app URL.")
    }
    let scheme = components.scheme?.lowercased()
    guard let scheme, isAppLinkScheme(scheme) else {
      throw CLIError(
        code: .validationError,
        message: "`--url` must use a supported non-web, non-file app URL scheme for Notes app links.",
        details: ["scheme": scheme ?? ""]
      )
    }
    components.scheme = scheme
    guard let url = components.url else {
      throw CLIError(code: .validationError, message: "`--url` must be a valid app URL.")
    }
    return url
  }

  private func validateLinkMutationState(_ state: NotesNoteStateRecord, operation: String) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes link mutation target must be a visible non-trash note.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isPasswordProtected == false, state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes link mutation remains gated.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isSharedReadOnly == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes link mutation target must be editable.",
        details: [
          "operation": operation,
          "id_sha256": sha256Hex(state.noteID),
        ]
      )
    }
  }

  private func validateNoteLinkDestinationState(_ state: NotesNoteStateRecord, operation: String) throws {
    guard state.isDeletedOrInTrash == false, state.folderIsTrash == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes link destination must be a visible non-trash note.",
        details: [
          "operation": operation,
          "target_sha256": sha256Hex(state.noteID),
        ]
      )
    }
    guard state.isPasswordProtected == false, state.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Password-protected Notes link destinations remain gated.",
        details: [
          "operation": operation,
          "target_sha256": sha256Hex(state.noteID),
        ]
      )
    }
  }

  private func linkAddSummary(_ draft: NotesLinkAddDraft) -> [String: String] {
    let components = URLComponents(url: draft.url, resolvingAgainstBaseURL: false)
    var summary = [
      "id": draft.noteID,
      "url": draft.urlString,
      "url_sha256": sha256Hex(draft.urlString),
      "scheme": components?.scheme ?? "",
      "host": components?.host ?? "",
    ]
    addLinkSelectedTextSummary(draft, to: &summary)
    return summary
  }

  private func linkAddScopeDigest(_ draft: NotesLinkAddDraft) -> String {
    let selectedTextHash = draft.selectedText.map(sha256Hex) ?? ""
    let selectedTextByteCount = draft.selectedText.map { selected in
      String(selected.utf8.count)
    } ?? ""
    let fields = [
      draft.noteID,
      draft.urlString,
      sha256Hex(draft.urlString),
      draft.paragraphIDSHA256 ?? "",
      draft.ordinal.map(String.init) ?? "",
      selectedTextHash,
      selectedTextByteCount,
      draft.occurrence.map(String.init) ?? "",
    ].joined(separator: "|")
    return "notes-link-add:\(sha256Hex(fields))"
  }

  private func appLinkAddSummary(_ draft: NotesLinkAddDraft) -> [String: String] {
    let components = URLComponents(url: draft.url, resolvingAgainstBaseURL: false)
    var summary = [
      "id": draft.noteID,
      "url_sha256": sha256Hex(draft.urlString),
      "scheme": components?.scheme ?? "",
      "host_sha256": components?.host.map(sha256Hex) ?? "",
    ]
    addLinkSelectedTextSummary(draft, to: &summary)
    return summary
  }

  private func appLinkAddScopeDigest(_ draft: NotesLinkAddDraft) -> String {
    let selectedTextHash = draft.selectedText.map(sha256Hex) ?? ""
    let selectedTextByteCount = draft.selectedText.map { selected in
      String(selected.utf8.count)
    } ?? ""
    let fields = [
      draft.noteID,
      sha256Hex(draft.urlString),
      draft.url.scheme ?? "",
      draft.paragraphIDSHA256 ?? "",
      draft.ordinal.map(String.init) ?? "",
      selectedTextHash,
      selectedTextByteCount,
      draft.occurrence.map(String.init) ?? "",
    ].joined(separator: "|")
    return "notes-app-link-add:\(sha256Hex(fields))"
  }

  private func fileLinkSourceKind(_ url: URL) -> String {
    url.hasDirectoryPath ? "directory" : "file"
  }

  private func fileLinkAddSummary(_ draft: NotesLinkAddDraft) -> [String: String] {
    var summary = [
      "id": draft.noteID,
      "file_url_sha256": sha256Hex(draft.urlString),
      "path_sha256": sha256Hex(draft.url.path),
      "file_kind": draft.sourceKind ?? fileLinkSourceKind(draft.url),
      "scheme": draft.url.scheme ?? "",
    ]
    addLinkSelectedTextSummary(draft, to: &summary)
    return summary
  }

  private func fileLinkAddScopeDigest(_ draft: NotesLinkAddDraft) -> String {
    let selectedTextHash = draft.selectedText.map(sha256Hex) ?? ""
    let selectedTextByteCount = draft.selectedText.map { selected in
      String(selected.utf8.count)
    } ?? ""
    let fields = [
      draft.noteID,
      sha256Hex(draft.urlString),
      sha256Hex(draft.url.path),
      draft.sourceKind ?? fileLinkSourceKind(draft.url),
      draft.url.scheme ?? "",
      draft.paragraphIDSHA256 ?? "",
      draft.ordinal.map(String.init) ?? "",
      selectedTextHash,
      selectedTextByteCount,
      draft.occurrence.map(String.init) ?? "",
    ].joined(separator: "|")
    return "notes-file-link-add:\(sha256Hex(fields))"
  }

  private func addLinkSelectedTextSummary(
    _ draft: NotesLinkAddDraft,
    to summary: inout [String: String]
  ) {
    guard let selectedText = draft.selectedText else {
      summary["mode"] = "append"
      return
    }
    summary["mode"] = "selected_text"
    summary["selected_text_sha256"] = sha256Hex(selectedText)
    summary["selected_text_byte_count"] = "\(selectedText.utf8.count)"
    summary["selected_text_paragraph_sha256"] = draft.paragraphIDSHA256 ?? ""
    summary["selected_text_ordinal"] = draft.ordinal.map(String.init) ?? ""
    summary["selected_text_occurrence"] = draft.occurrence.map(String.init) ?? ""
  }

  private func linkAddResultRecord(
    _ record: NotesLinkRecord,
    draft: NotesLinkAddDraft
  ) -> NotesLinkRecord {
    guard draft.convertsSelectedText else {
      return record
    }
    var redacted = record
    redacted.displayText = nil
    redacted.altText = nil
    return redacted
  }

  private func noteLinkResultRecord(
    _ record: NotesLinkRecord,
    displayText: NotesNoteLinkDisplayTextDraft?
  ) -> NotesLinkRecord {
    guard displayText != nil else {
      return record
    }
    var redacted = record
    redacted.displayText = nil
    redacted.altText = nil
    return redacted
  }

  private func verifyLinkResolution(_ resolution: NotesLinkResolutionRecord) throws
    -> NotesMutationVerificationReport
  {
    let sourceReadback = try implementation.readNote(id: resolution.noteID) != nil
    let linkReadback = try linkReader().listLinks(noteID: resolution.noteID, limit: 2_000)
    let selectedLink = linkReadback.first { linkRecordMatches($0, resolution.link) }
    let selectedLinkReadback = selectedLink != nil
    let selectedLinkIdentity = selectedLink.map { linkRecordMatches($0, resolution.link) } ?? false

    var checks: [NotesVerificationCheckRecord] = [
      verificationBoolCheck(name: "source_note_readback", expected: true, actual: sourceReadback),
      verificationBoolCheck(name: "selected_link_readback", expected: true, actual: selectedLinkReadback),
      verificationBoolCheck(name: "selected_link_identity", expected: true, actual: selectedLinkIdentity),
      verificationBoolCheck(name: "destination_kind", expected: true, actual: !resolution.destination.kind.isEmpty),
      verificationBoolCheck(name: "destination_resolved", expected: true, actual: resolution.destination.resolved),
    ]

    if let targetNoteID = resolution.destination.targetNoteID {
      let targetReadback = try implementation.readNote(id: targetNoteID) != nil
      checks.append(verificationBoolCheck(name: "target_note_readback", expected: true, actual: targetReadback))

      if isNoteLinkRecord(resolution.link) {
        let backlinks = try linkReader().listBacklinks(noteID: targetNoteID, limit: 2_000)
        checks.append(
          verificationBoolCheck(
            name: "target_backlink_readback",
            expected: true,
            actual: backlinksContainSourceAndLink(backlinks, sourceNoteID: resolution.noteID, link: resolution.link)
          )
        )
      } else {
        checks.append(NotesVerificationCheckRecord(name: "target_backlink_readback", status: "not_applicable"))
      }
    } else if isNoteLinkRecord(resolution.link) {
      checks.append(verificationBoolCheck(name: "target_note_readback", expected: true, actual: false))
      checks.append(verificationBoolCheck(name: "target_backlink_readback", expected: true, actual: false))
    } else {
      checks.append(NotesVerificationCheckRecord(name: "target_note_readback", status: "not_applicable"))
      checks.append(NotesVerificationCheckRecord(name: "target_backlink_readback", status: "not_applicable"))
    }

    if isParagraphLinkRecord(resolution.link) {
      checks.append(
        verificationBoolCheck(
          name: "target_paragraph_hash",
          expected: true,
          actual: resolution.destination.targetParagraphIDSHA256 != nil
        )
      )
    } else {
      checks.append(NotesVerificationCheckRecord(name: "target_paragraph_hash", status: "not_applicable"))
    }

    if isNoteLinkRecord(resolution.link) {
      checks.append(
        verificationBoolCheck(
          name: "raw_internal_token_hidden",
          expected: true,
          actual: resolution.destination.rawInternalTokenHidden
        )
      )
    } else {
      checks.append(NotesVerificationCheckRecord(name: "raw_internal_token_hidden", status: "not_applicable"))
    }

    if resolution.destination.kind == "app" || resolution.destination.kind == "file" {
      checks.append(
        verificationBoolCheck(
          name: "raw_url_hidden",
          expected: true,
          actual: resolution.destination.rawURLHidden
        )
      )
    } else {
      checks.append(NotesVerificationCheckRecord(name: "raw_url_hidden", status: "not_applicable"))
    }

    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.links.resolve",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_link_resolution+link_metadata_readback+destination_readback",
      targetIDSHA256: sha256Hex("\(resolution.noteID)|\(resolution.link.id)"),
      checks: checks,
      warnings: resolution.destination.warnings
    )
  }

  private func linkWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.links.audit"
    let records = notesLinkWorkflowAuditRecords()
    let summary = notesLinkWorkflowAuditSummary(records)
    let verification = verifyLinkWorkflowAudit(records: records, summary: summary)
    let response = NotesLinkWorkflowAuditResponse(
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

  private func notesLinkWorkflowAuditRecords() -> [NotesLinkWorkflowAuditRecord] {
    struct LinkWorkflowAuditItem {
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
      LinkWorkflowAuditItem(
        family: "link_metadata_list",
        guideSection: "Add links / Edit and remove links",
        status: "supported",
        appleCapability: "inspect_existing_links_in_a_note",
        command: "links list --id NOTE_ID",
        mechanism: "typed_private_notes_framework_link_metadata_reader",
        requiredImplementation: "ICNote.allNoteTextInlineAttachments link metadata readback",
        requiredVerifier: "private_link_metadata_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "hashes_file_app_and_internal_urls_without_note_body",
        reason: "The accepted link metadata reader enumerates inline link attachments and hides raw file, app, and internal Notes tokens."
      ),
      LinkWorkflowAuditItem(
        family: "link_destination_resolve",
        guideSection: "Add links",
        status: "supported",
        appleCapability: "quickly_access_webpages_notes_or_app_content",
        command: "links resolve --id NOTE_ID --link LINK_ID",
        mechanism: "typed_private_notes_framework_link_destination_resolver",
        requiredImplementation: "ICAppURLUtilities note/paragraph resolution plus private link metadata",
        requiredVerifier: "private_selected_link_readback+destination_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "public_web_urls_only_raw_internal_file_app_urls_hidden",
        reason: "The accepted resolver verifies one selected destination while keeping raw internal tokens, app URLs, file URLs, paragraph titles, and note bodies private."
      ),
      LinkWorkflowAuditItem(
        family: "webpage_link_add",
        guideSection: "Link to a webpage",
        status: "supported",
        appleCapability: "add_webpage_url_link",
        command: "links add --id NOTE_ID --url https://example.com",
        mechanism: "typed_private_notes_framework_web_url_link_writer",
        requiredImplementation: "ICNote.addURLAttachmentWithURL",
        requiredVerifier: "private_link_metadata_readback+note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "prints_public_web_url_only_for_explicit_web_link",
        reason: "The accepted web-link writer adds one explicit http/https URL link and verifies link metadata and note readback."
      ),
      LinkWorkflowAuditItem(
        family: "note_link_add",
        guideSection: "Link to another note",
        status: "supported",
        appleCapability: "add_link_to_another_note",
        command: "links add-note --id SOURCE_NOTE_ID --target TARGET_NOTE_ID",
        mechanism: "typed_private_notes_framework_note_link_writer",
        requiredImplementation: "ICInlineAttachment.newLinkAttachmentToNote:fromNote:parentAttachment:",
        requiredVerifier: "private_note_link_metadata_readback+target_note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "target_identity_hash_without_target_title_body_or_internal_token",
        reason: "The accepted note-link writer creates one internal note link and verifies source and target readback without printing target note content."
      ),
      LinkWorkflowAuditItem(
        family: "paragraph_note_link",
        guideSection: "Link to another note",
        status: "supported",
        appleCapability: "add_link_to_a_specific_note_anchor",
        command: "links add-paragraph --id SOURCE_NOTE_ID --target TARGET_NOTE_ID --paragraph PARAGRAPH_ID_SHA256",
        mechanism: "typed_private_notes_framework_paragraph_link_writer",
        requiredImplementation: "ICInlineAttachment.newLinkAttachmentToNote:paragraphID:paragraphName:fromNote:parentAttachment:",
        requiredVerifier: "private_paragraph_anchor_hash_readback+link_metadata_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "paragraph_hash_without_raw_uuid_title_or_body",
        reason: "The accepted paragraph-link writer resolves target paragraph anchors by hash and verifies the paragraph destination without exposing raw paragraph identifiers."
      ),
      LinkWorkflowAuditItem(
        family: "app_link_add",
        guideSection: "Link to an app",
        status: "supported",
        appleCapability: "add_link_to_content_in_supported_apps",
        command: "links add-app --id NOTE_ID --url APP_SCHEME_URL",
        mechanism: "typed_private_notes_framework_app_url_link_writer",
        requiredImplementation: "ICNote.addURLAttachmentWithURL",
        requiredVerifier: "private_app_link_metadata_readback+raw_url_absence",
        safetyGate: "dry-run/readback",
        privacyBoundary: "app_url_scheme_and_hash_only",
        reason: "The accepted app-link writer adds one explicit non-web, non-file app URL while exposing only scheme and hash evidence."
      ),
      LinkWorkflowAuditItem(
        family: "link_edit",
        guideSection: "Edit and remove links",
        status: "supported",
        appleCapability: "edit_existing_link_destination",
        command: "links update|update-app|update-file|update-note|update-paragraph",
        mechanism: "typed_private_notes_framework_inline_link_updater",
        requiredImplementation: "ICInlineAttachment tokenContentIdentifier/altText/changeLinkDestination mutations",
        requiredVerifier: "private_selected_link_identity+old_new_destination_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "hashes_raw_app_file_internal_destinations",
        reason: "The accepted update commands retarget selected web, app, file, note, and paragraph links with selected-link identity and destination readback."
      ),
      LinkWorkflowAuditItem(
        family: "link_remove",
        guideSection: "Edit and remove links",
        status: "supported",
        appleCapability: "remove_existing_link",
        command: "links remove|remove-app|remove-file|remove-note|remove-paragraph",
        mechanism: "typed_private_notes_framework_inline_link_remover",
        requiredImplementation: "ICInlineAttachment.isDeletable plus markForDeletion",
        requiredVerifier: "private_selected_link_absence_readback+note_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "does_not_print_raw_app_file_or_internal_link_tokens",
        reason: "The accepted remove commands delete one selected link after kind-specific validation and verify selected-link absence."
      ),
      LinkWorkflowAuditItem(
        family: "backlink_read",
        guideSection: "Link to another note",
        status: "supported",
        appleCapability: "inspect_notes_that_link_to_this_note",
        command: "links backlinks --id TARGET_NOTE_ID",
        mechanism: "typed_private_notes_framework_backlink_reader",
        requiredImplementation: "ICInlineAttachment.enumerateLinksToNote",
        requiredVerifier: "private_backlink_metadata_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "source_note_summaries_without_bodies_or_internal_tokens",
        reason: "The accepted backlink reader returns incoming link metadata and source summaries without printing note bodies or raw internal link URLs."
      ),
      LinkWorkflowAuditItem(
        family: "edit_menu_keyboard_ui",
        guideSection: "Link to a webpage / Link to another note / Edit and remove links",
        status: "delegated",
        appleCapability: "use_edit_add_link_command_k_or_context_menu",
        command: "Notes.app Edit menu, Command-K, toolbar, and context menu",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_link_menu_and_shortcut_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Menu commands, toolbar clicks, keyboard shortcuts, and context menus are transient Notes.app UI surfaces; the CLI exposes semantic link commands instead."
      ),
      LinkWorkflowAuditItem(
        family: "smart_links_substitution",
        guideSection: "Link to a webpage",
        status: "delegated",
        appleCapability: "turn_on_smart_links_and_auto_convert_typed_urls",
        command: "Notes.app Edit > Substitutions > Smart Links",
        mechanism: "delegated_notes_app_text_input_surface",
        requiredImplementation: "notes_app_smart_links_substitution",
        requiredVerifier: "delegated_text_input_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Automatic typed-URL conversion and the Smart Links checkbox are text-input/UI behavior, not a persisted Notes model mutation owned by the CLI."
      ),
      LinkWorkflowAuditItem(
        family: "note_link_typeahead_ui",
        guideSection: "Link to another note",
        status: "delegated",
        appleCapability: "type_double_greater_than_to_show_matching_notes",
        command: "Notes.app >> note suggestion UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_note_link_suggestion_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The >> typeahead picker is a Notes.app suggestion surface; `links add-note` owns the semantic target-note mutation."
      ),
      LinkWorkflowAuditItem(
        family: "active_app_link_capture_ui",
        guideSection: "Link to an app",
        status: "delegated",
        appleCapability: "capture_link_from_currently_active_supported_app",
        command: "Notes.app toolbar Add Link from active app",
        mechanism: "delegated_inter_app_ui_surface",
        requiredImplementation: "notes_app_active_app_link_capture",
        requiredVerifier: "delegated_inter_app_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Capturing a URL from the currently active app crosses app focus and inter-app UI state; the CLI accepts an explicit app URL instead."
      ),
      LinkWorkflowAuditItem(
        family: "quick_note_link_thumbnail",
        guideSection: "Link to an app",
        status: "delegated",
        appleCapability: "show_quick_note_thumbnail_when_returning_to_linked_content",
        command: "Quick Note / linked app UI",
        mechanism: "delegated_quick_note_ui_surface",
        requiredImplementation: "notes_app_quick_note_return_thumbnail",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "The thumbnail shown when returning to linked app content is a Notes.app/Quick Note UI behavior rather than a CLI data mutation."
      ),
      LinkWorkflowAuditItem(
        family: "link_color_appearance",
        guideSection: "Change the color of links",
        status: "delegated",
        appleCapability: "change_link_color_through_macos_appearance_settings",
        command: "System Settings > Appearance; settings link-highlight-color",
        mechanism: "delegated_macos_appearance_surface",
        requiredImplementation: "macos_accent_and_highlight_color_settings",
        requiredVerifier: "delegated_system_settings_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Apple documents link color as a macOS Appearance setting applied across apps, so the Notes CLI reports it as a delegated system surface."
      ),
      LinkWorkflowAuditItem(
        family: "legacy_os_visibility",
        guideSection: "Link to another note",
        status: "delegated",
        appleCapability: "notes_with_note_links_may_be_hidden_on_older_macos",
        command: "Apple ecosystem compatibility",
        mechanism: "delegated_platform_compatibility_surface",
        requiredImplementation: "macos_notes_version_compatibility",
        requiredVerifier: "delegated_compatibility_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Visibility on older OS versions is a platform compatibility concern outside local Notes private-framework mutation semantics."
      ),
      LinkWorkflowAuditItem(
        family: "selected_text_to_link",
        guideSection: "Link to a webpage",
        status: "supported",
        appleCapability: "turn_selected_note_text_into_a_webpage_app_or_file_link",
        command: "links add|add-app|add-file --id NOTE_ID --paragraph HASH --text TEXT --url URL",
        mechanism: "typed_private_notes_framework_selected_text_url_link_writer",
        requiredImplementation: "ICInlineAttachment.newLinkAttachmentWithURL:name:currentNote: plus ICNote.textStorage range replacement",
        requiredVerifier: "private_selected_text_hash_display_readback+link_metadata_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "selected_text_hash_without_text_body_or_range_leakage",
        reason: "The accepted selected-text URL link writer converts one selected text occurrence in a selected paragraph into a web, app, or file URL link, verifies display-text hash and link metadata readback, and redacts the selected text in command JSON."
      ),
      LinkWorkflowAuditItem(
        family: "custom_link_text_title_sync",
        guideSection: "Link to another note",
        status: "supported",
        appleCapability: "choose_use_note_title_or_custom_link_text",
        command: "links add-note|update-note --id SOURCE_NOTE_ID --target TARGET_NOTE_ID [--text TEXT|--use-note-title]",
        mechanism: "typed_private_notes_framework_note_link_display_text_writer",
        requiredImplementation: "ICInlineAttachment.altText plus markDisplayTextNeedsUpdate for custom text and title-derived display refresh",
        requiredVerifier: "private_link_display_text_hash_readback+custom_alt_text_absence_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "link_text_hash_without_target_title_or_body",
        reason: "The accepted note-link commands now support fixed custom display text and title-derived display text with hash-only readback evidence and redacted command JSON."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesLinkWorkflowAuditRecord(
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

  private func notesLinkWorkflowAuditSummary(
    _ records: [NotesLinkWorkflowAuditRecord]
  ) -> NotesLinkWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesLinkWorkflowAuditSummary(
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

  private func verifyLinkWorkflowAudit(
    records: [NotesLinkWorkflowAuditRecord],
    summary: NotesLinkWorkflowAuditSummary
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
        name: "web_note_app_links_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "webpage_link_add", "note_link_add", "paragraph_note_link", "app_link_add",
            "selected_text_to_link", "custom_link_text_title_sync",
          ]
        )
      ),
      verificationBoolCheck(
        name: "link_readback_supported",
        expected: true,
        actual: supported.isSuperset(
          of: ["link_metadata_list", "link_destination_resolve", "backlink_read"]
        )
      ),
      verificationBoolCheck(
        name: "link_edit_remove_supported",
        expected: true,
        actual: supported.isSuperset(of: ["link_edit", "link_remove"])
      ),
      verificationBoolCheck(
        name: "ui_and_system_surfaces_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "edit_menu_keyboard_ui", "smart_links_substitution", "note_link_typeahead_ui",
            "active_app_link_capture_ui", "quick_note_link_thumbnail",
            "link_color_appearance", "legacy_os_visibility",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_link_semantics_gated",
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
      operation: "notes.links.audit",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.links.audit"),
      checks: checks
    )
  }

  private func noteLinkAddSummary(_ draft: NotesNoteLinkAddDraft) -> [String: String] {
    var summary = [
      "id": draft.sourceNoteID,
      "target": draft.targetNoteID,
      "requested_target_sha256": sha256Hex(draft.requestedTargetNoteID),
      "target_sha256": sha256Hex(draft.targetNoteID),
    ]
    addNoteLinkDisplayTextSummary(draft.displayText, to: &summary)
    return summary
  }

  private func noteLinkAddScopeDigest(_ draft: NotesNoteLinkAddDraft) -> String {
    let fields = [
      draft.sourceNoteID,
      draft.targetNoteID,
      draft.requestedTargetNoteID,
      sha256Hex(draft.targetNoteID),
      draft.displayText?.mode ?? "",
      draft.displayText?.displayTextSHA256 ?? "",
      draft.displayText.map { "\($0.displayTextByteCount)" } ?? "",
      draft.displayText?.sourceKind ?? "",
    ].joined(separator: "|")
    return "notes-note-link-add:\(sha256Hex(fields))"
  }

  private func addNoteLinkDisplayTextSummary(
    _ displayText: NotesNoteLinkDisplayTextDraft?,
    to summary: inout [String: String]
  ) {
    guard let displayText else {
      return
    }
    summary["display_text_mode"] = displayText.mode
    summary["display_text_sha256"] = displayText.displayTextSHA256
    summary["display_text_byte_count"] = "\(displayText.displayTextByteCount)"
    summary["display_text_source_kind"] = displayText.sourceKind
  }

  private func paragraphLinkAddSummary(_ draft: NotesParagraphLinkAddDraft) -> [String: String] {
    [
      "id": draft.sourceNoteID,
      "target": draft.targetNoteID,
      "requested_target_sha256": sha256Hex(draft.requestedTargetNoteID),
      "target_sha256": sha256Hex(draft.targetNoteID),
      "requested_paragraph_sha256": draft.requestedTargetParagraphIDSHA256,
      "target_paragraph_sha256": draft.targetParagraphIDSHA256,
    ]
  }

  private func paragraphLinkAddScopeDigest(_ draft: NotesParagraphLinkAddDraft) -> String {
    let fields = [
      draft.sourceNoteID,
      draft.targetNoteID,
      sha256Hex(draft.requestedTargetNoteID),
      draft.targetParagraphIDSHA256,
    ].joined(separator: "|")
    return "notes-paragraph-link-add:\(sha256Hex(fields))"
  }

  private func linkUpdateSummary(_ draft: NotesLinkUpdateDraft) -> [String: String] {
    let components = URLComponents(url: draft.url, resolvingAgainstBaseURL: false)
    return [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "old_url_sha256": draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256 ?? "",
      "old_scheme": draft.link.urlScheme ?? "",
      "url": draft.urlString,
      "url_sha256": sha256Hex(draft.urlString),
      "scheme": components?.scheme ?? "",
      "host": components?.host ?? "",
    ]
  }

  private func appLinkUpdateSummary(_ draft: NotesLinkUpdateDraft) -> [String: String] {
    let components = URLComponents(url: draft.url, resolvingAgainstBaseURL: false)
    return [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "old_url_sha256": draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256 ?? "",
      "old_scheme": draft.link.urlScheme ?? "",
      "url_sha256": sha256Hex(draft.urlString),
      "scheme": components?.scheme ?? "",
      "host_sha256": components?.host.map(sha256Hex) ?? "",
    ]
  }

  private func appLinkUpdateScopeDigest(_ draft: NotesLinkUpdateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      sha256Hex(draft.requestedLinkID),
      draft.link.urlSHA256 ?? draft.link.urlString.map(sha256Hex) ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      sha256Hex(draft.urlString),
      draft.url.scheme ?? "",
    ].joined(separator: "|")
    return "notes-app-link-update:\(sha256Hex(fields))"
  }

  private func fileLinkUpdateSummary(_ draft: NotesLinkUpdateDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "old_url_sha256": draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256 ?? "",
      "old_scheme": draft.link.urlScheme ?? "",
      "file_url_sha256": sha256Hex(draft.urlString),
      "path_sha256": sha256Hex(draft.url.path),
      "file_kind": draft.sourceKind ?? fileLinkSourceKind(draft.url),
      "scheme": draft.url.scheme ?? "",
    ]
  }

  private func fileLinkUpdateScopeDigest(_ draft: NotesLinkUpdateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      sha256Hex(draft.requestedLinkID),
      draft.link.urlSHA256 ?? draft.link.urlString.map(sha256Hex) ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      sha256Hex(draft.urlString),
      sha256Hex(draft.url.path),
      draft.sourceKind ?? fileLinkSourceKind(draft.url),
      draft.url.scheme ?? "",
    ].joined(separator: "|")
    return "notes-file-link-update:\(sha256Hex(fields))"
  }

  private func noteLinkUpdateSummary(_ draft: NotesNoteLinkUpdateDraft) -> [String: String] {
    var summary = [
      "id": draft.sourceNoteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "old_token_sha256": draft.link.tokenContentIdentifierSHA256 ?? "",
      "target": draft.targetNoteID,
      "requested_target_sha256": sha256Hex(draft.requestedTargetNoteID),
      "target_sha256": sha256Hex(draft.targetNoteID),
    ]
    addNoteLinkDisplayTextSummary(draft.displayText, to: &summary)
    return summary
  }

  private func noteLinkUpdateScopeDigest(_ draft: NotesNoteLinkUpdateDraft) -> String {
    let fields = [
      draft.sourceNoteID,
      draft.link.id,
      sha256Hex(draft.requestedLinkID),
      draft.link.tokenContentIdentifierSHA256 ?? "",
      draft.targetNoteID,
      sha256Hex(draft.requestedTargetNoteID),
      draft.displayText?.mode ?? "",
      draft.displayText?.displayTextSHA256 ?? "",
      draft.displayText.map { "\($0.displayTextByteCount)" } ?? "",
      draft.displayText?.sourceKind ?? "",
    ].joined(separator: "|")
    return "notes-note-link-update:\(sha256Hex(fields))"
  }

  private func paragraphLinkUpdateSummary(_ draft: NotesParagraphLinkUpdateDraft) -> [String: String] {
    [
      "id": draft.sourceNoteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "old_token_sha256": draft.link.tokenContentIdentifierSHA256 ?? "",
      "target": draft.targetNoteID,
      "requested_target_sha256": sha256Hex(draft.requestedTargetNoteID),
      "target_sha256": sha256Hex(draft.targetNoteID),
      "requested_paragraph_sha256": draft.requestedTargetParagraphIDSHA256,
      "target_paragraph_sha256": draft.targetParagraphIDSHA256,
    ]
  }

  private func paragraphLinkUpdateScopeDigest(_ draft: NotesParagraphLinkUpdateDraft) -> String {
    let fields = [
      draft.sourceNoteID,
      draft.link.id,
      sha256Hex(draft.requestedLinkID),
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      draft.targetNoteID,
      sha256Hex(draft.requestedTargetNoteID),
      draft.targetParagraphIDSHA256,
      draft.requestedTargetParagraphIDSHA256,
    ].joined(separator: "|")
    return "notes-paragraph-link-update:\(sha256Hex(fields))"
  }

  private func linkUpdateScopeDigest(_ draft: NotesLinkUpdateDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      draft.requestedLinkID,
      draft.link.urlString ?? "",
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      draft.urlString,
      sha256Hex(draft.urlString),
    ].joined(separator: "|")
    return "notes-link-update:\(sha256Hex(fields))"
  }

  private func linkRemoveSummary(_ draft: NotesLinkRemoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "url_sha256": draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256 ?? "",
      "scheme": draft.link.urlScheme ?? "",
    ]
  }

  private func linkRemoveScopeDigest(_ draft: NotesLinkRemoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      draft.requestedLinkID,
      draft.link.urlString ?? "",
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-link-remove:\(sha256Hex(fields))"
  }

  private func appLinkRemoveSummary(_ draft: NotesLinkRemoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "url_sha256": draft.link.urlSHA256 ?? "",
      "scheme": draft.link.urlScheme ?? "",
      "token_sha256": draft.link.tokenContentIdentifierSHA256 ?? "",
    ]
  }

  private func appLinkRemoveScopeDigest(_ draft: NotesLinkRemoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      draft.requestedLinkID,
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      draft.link.urlScheme ?? "",
    ].joined(separator: "|")
    return "notes-app-link-remove:\(sha256Hex(fields))"
  }

  private func fileLinkRemoveSummary(_ draft: NotesLinkRemoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "url_sha256": draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256 ?? "",
      "scheme": draft.link.urlScheme ?? "",
      "type_uti": draft.link.typeUTI ?? "",
    ]
  }

  private func fileLinkRemoveScopeDigest(_ draft: NotesLinkRemoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      draft.requestedLinkID,
      draft.link.urlString ?? "",
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      draft.link.typeUTI ?? "",
    ].joined(separator: "|")
    return "notes-file-link-remove:\(sha256Hex(fields))"
  }

  private func noteLinkRemoveSummary(_ draft: NotesNoteLinkRemoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "token_sha256": draft.link.tokenContentIdentifierSHA256 ?? "",
      "scheme": draft.link.urlScheme ?? "",
    ]
  }

  private func noteLinkRemoveScopeDigest(_ draft: NotesNoteLinkRemoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      draft.requestedLinkID,
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
    ].joined(separator: "|")
    return "notes-note-link-remove:\(sha256Hex(fields))"
  }

  private func paragraphLinkRemoveSummary(_ draft: NotesParagraphLinkRemoveDraft) -> [String: String] {
    [
      "id": draft.noteID,
      "link": draft.link.id,
      "requested_link": draft.requestedLinkID,
      "requested_link_sha256": sha256Hex(draft.requestedLinkID),
      "kind": draft.link.kind,
      "token_sha256": draft.link.tokenContentIdentifierSHA256 ?? "",
      "scheme": draft.link.urlScheme ?? "",
      "paragraph": "\(draft.link.isParagraphLink)",
      "internal_paragraph": "\(draft.link.isInternalParagraphLink)",
    ]
  }

  private func paragraphLinkRemoveScopeDigest(_ draft: NotesParagraphLinkRemoveDraft) -> String {
    let fields = [
      draft.noteID,
      draft.link.id,
      draft.requestedLinkID,
      draft.link.urlSHA256 ?? "",
      draft.link.tokenContentIdentifierSHA256 ?? "",
      "\(draft.link.isParagraphLink)",
      "\(draft.link.isInternalParagraphLink)",
    ].joined(separator: "|")
    return "notes-paragraph-link-remove:\(sha256Hex(fields))"
  }

  private func verifyLinkAdd(
    draft: NotesLinkAddDraft,
    result: NotesLinkAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let matchingLink = linkReadback.first { linkRecordMatches($0, urlString: draft.urlString) }
    let metadataPresent = matchingLink != nil
    let kindIsURL = matchingLink?.kind == "url"
    let schemeIsWeb = matchingLink.map { $0.urlScheme == "http" || $0.urlScheme == "https" } ?? false
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    var checks = [
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsURL ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsURL
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeIsWeb ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeIsWeb
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    checks.append(contentsOf: selectedTextLinkAddChecks(draft: draft, result: result, matchingLink: matchingLink))
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: draft.convertsSelectedText
        ? "private_framework_selected_text_url_link_write+link_metadata_readback+display_text_hash_readback+note_readback"
        : "private_framework_link_write+link_metadata_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyAppLinkAdd(
    draft: NotesLinkAddDraft,
    result: NotesLinkAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let expectedURLSHA256 = sha256Hex(draft.urlString)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
      ?? linkReadback.first { isAppLinkRecord($0) && $0.urlSHA256 == expectedURLSHA256 }
    let metadataPresent = matchingLink != nil
    let kindIsApp = matchingLink.map(isAppLinkRecord) ?? false
    let schemeMatches = matchingLink?.urlScheme == draft.url.scheme
    let urlHashMatches = matchingLink?.urlSHA256 == expectedURLSHA256
    let rawURLHidden = matchingLink?.urlString == nil
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    var checks = [
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsApp ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsApp
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeMatches
      ),
      NotesVerificationCheckRecord(
        name: "url_hash",
        status: urlHashMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: urlHashMatches
      ),
      NotesVerificationCheckRecord(
        name: "raw_url_hidden",
        status: rawURLHidden ? "passed" : "failed",
        expectedBool: true,
        actualBool: rawURLHidden
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    checks.append(contentsOf: selectedTextLinkAddChecks(draft: draft, result: result, matchingLink: matchingLink))
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: draft.convertsSelectedText
        ? "private_framework_selected_text_app_link_write+link_metadata_readback+display_text_hash_readback+note_readback"
        : "private_framework_app_link_write+link_metadata_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyFileLinkAdd(
    draft: NotesLinkAddDraft,
    result: NotesLinkAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let expectedURLSHA256 = sha256Hex(draft.urlString)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
      ?? linkReadback.first { isFileLinkRecord($0) && $0.urlSHA256 == expectedURLSHA256 }
    let metadataPresent = matchingLink != nil
    let kindIsFile = matchingLink.map(isFileLinkRecord) ?? false
    let schemeMatches = matchingLink?.urlScheme == "file"
    let urlHashMatches = matchingLink?.urlSHA256 == expectedURLSHA256
    let rawURLHidden = matchingLink?.urlString == nil
    let sourceKindKnown = ["file", "directory"].contains(draft.sourceKind ?? fileLinkSourceKind(draft.url))
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    var checks = [
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsFile ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsFile
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeMatches
      ),
      NotesVerificationCheckRecord(
        name: "url_hash",
        status: urlHashMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: urlHashMatches
      ),
      NotesVerificationCheckRecord(
        name: "raw_url_hidden",
        status: rawURLHidden ? "passed" : "failed",
        expectedBool: true,
        actualBool: rawURLHidden
      ),
      NotesVerificationCheckRecord(
        name: "source_kind",
        status: sourceKindKnown ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceKindKnown
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    checks.append(contentsOf: selectedTextLinkAddChecks(draft: draft, result: result, matchingLink: matchingLink))
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: draft.convertsSelectedText
        ? "private_framework_selected_text_file_link_write+link_metadata_readback+display_text_hash_readback+note_readback"
        : "private_framework_file_link_write+link_metadata_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func selectedTextLinkAddChecks(
    draft: NotesLinkAddDraft,
    result: NotesLinkAddWriteResult,
    matchingLink: NotesLinkRecord?
  ) -> [NotesVerificationCheckRecord] {
    guard let selectedText = draft.selectedText else {
      return []
    }
    let expectedHash = sha256Hex(selectedText)
    let actualDisplayHash = [
      result.link.displayText,
      result.link.altText,
      matchingLink?.displayText,
      matchingLink?.altText,
    ].compactMap { value -> String? in
      guard let value, value.isEmpty == false else {
        return nil
      }
      return sha256Hex(value)
    }
      .first { $0 == expectedHash }
    let paragraphMatches = draft.paragraphIDSHA256.map { $0 == result.selectedTextParagraphIDSHA256 }
      ?? (draft.ordinal == nil || result.selectedTextParagraphIDSHA256?.isEmpty == false)
    let ordinalMatches = draft.ordinal.map { $0 == result.selectedTextOrdinal }
      ?? true
    let occurrence = result.selectedTextOccurrence
    return [
      NotesVerificationCheckRecord(
        name: "selected_text_byte_count",
        status: result.selectedTextByteCount == selectedText.utf8.count ? "passed" : "failed",
        expectedLength: selectedText.utf8.count,
        actualLength: result.selectedTextByteCount
      ),
      NotesVerificationCheckRecord(
        name: "selected_text_hash",
        status: result.selectedTextSHA256 == expectedHash ? "passed" : "failed",
        expectedSHA256: expectedHash,
        actualSHA256: result.selectedTextSHA256
      ),
      NotesVerificationCheckRecord(
        name: "selected_text_display_hash_readback",
        status: actualDisplayHash == expectedHash ? "passed" : "failed",
        expectedSHA256: expectedHash,
        actualSHA256: actualDisplayHash
      ),
      NotesVerificationCheckRecord(
        name: "selected_text_paragraph_evidence",
        status: paragraphMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: paragraphMatches
      ),
      NotesVerificationCheckRecord(
        name: "selected_text_ordinal_evidence",
        status: ordinalMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: ordinalMatches
      ),
      NotesVerificationCheckRecord(
        name: "selected_text_occurrence",
        status: occurrence.map { $0 > 0 } == true ? "passed" : "failed",
        expectedBool: true,
        actualBool: occurrence.map { $0 > 0 } ?? false
      ),
    ]
  }

  private func noteLinkDisplayTextChecks(
    displayText: NotesNoteLinkDisplayTextDraft?,
    resultLink: NotesLinkRecord,
    matchingLink: NotesLinkRecord?
  ) -> [NotesVerificationCheckRecord] {
    guard let displayText else {
      return []
    }
    let values = linkDisplayTextValues(resultLink, matchingLink)
    let hashes = values.map(sha256Hex)
    let hashMatches = hashes.contains(displayText.displayTextSHA256)
    let customAltTextAbsent = [resultLink.altText, matchingLink?.altText].allSatisfy { value in
      guard let value else {
        return true
      }
      return value.isEmpty
    }

    switch displayText.mode {
    case "custom":
      return [
        NotesVerificationCheckRecord(
          name: "custom_display_text_hash_readback",
          status: hashMatches ? "passed" : "failed",
          expectedSHA256: displayText.displayTextSHA256,
          actualSHA256: hashes.first
        ),
        NotesVerificationCheckRecord(
          name: "display_text_source_kind",
          status: displayText.sourceKind == "ICInlineAttachment.altText" ? "passed" : "failed",
          expectedBool: true,
          actualBool: displayText.sourceKind == "ICInlineAttachment.altText"
        ),
      ]
    case "target_title":
      return [
        NotesVerificationCheckRecord(
          name: "target_title_display_hash_readback",
          status: hashMatches ? "passed" : "failed",
          expectedSHA256: displayText.displayTextSHA256,
          actualSHA256: hashes.first
        ),
        NotesVerificationCheckRecord(
          name: "custom_alt_text_absent",
          status: customAltTextAbsent ? "passed" : "failed",
          expectedBool: true,
          actualBool: customAltTextAbsent
        ),
        NotesVerificationCheckRecord(
          name: "display_text_source_kind",
          status: displayText.sourceKind == "ICInlineAttachment.displayText" ? "passed" : "failed",
          expectedBool: true,
          actualBool: displayText.sourceKind == "ICInlineAttachment.displayText"
        ),
      ]
    default:
      return [
        NotesVerificationCheckRecord(
          name: "display_text_mode",
          status: "failed",
          expectedBool: true,
          actualBool: false
        )
      ]
    }
  }

  private func linkDisplayTextValues(
    _ resultLink: NotesLinkRecord,
    _ matchingLink: NotesLinkRecord?
  ) -> [String] {
    [resultLink.displayText, resultLink.altText, matchingLink?.displayText, matchingLink?.altText]
      .compactMap { value -> String? in
        guard let value, !value.isEmpty else {
          return nil
        }
        return value
      }
  }

  private func verifyNoteLinkAdd(
    draft: NotesNoteLinkAddDraft,
    result: NotesNoteLinkAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.sourceNoteID, limit: 2_000)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
    let metadataPresent = matchingLink != nil
    let kindIsNoteLink = matchingLink.map(isNoteLinkRecord) ?? false
    let sourceStillPresent = try implementation.readNote(id: result.sourceNoteID) != nil
    let targetStillPresent = try implementation.readNote(id: result.targetNoteID) != nil
    let targetMatchesDraft = result.targetNoteID == draft.targetNoteID
    var checks = [
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsNoteLink ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsNoteLink
      ),
      NotesVerificationCheckRecord(
        name: "source_note_readback",
        status: sourceStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_note_readback",
        status: targetStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_identity",
        status: targetMatchesDraft ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetMatchesDraft
      ),
    ]
    checks.append(contentsOf: noteLinkDisplayTextChecks(
      displayText: draft.displayText,
      resultLink: result.link,
      matchingLink: matchingLink
    ))
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: draft.displayText == nil
        ? "private_framework_note_link_write+link_metadata_readback+source_target_readback"
        : "private_framework_note_link_write+link_display_text_hash_readback+source_target_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyParagraphLinkAdd(
    draft: NotesParagraphLinkAddDraft,
    result: NotesParagraphLinkAddWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.sourceNoteID, limit: 2_000)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
    let metadataPresent = matchingLink != nil
    let kindIsParagraphLink = matchingLink.map(isParagraphLinkRecord) ?? false
    let sourceStillPresent = try implementation.readNote(id: result.sourceNoteID) != nil
    let targetStillPresent = try implementation.readNote(id: result.targetNoteID) != nil
    let targetMatchesDraft = result.targetNoteID == draft.targetNoteID
    let paragraphMatchesDraft = result.targetParagraphIDSHA256 == draft.targetParagraphIDSHA256
    let checks = [
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsParagraphLink ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsParagraphLink
      ),
      NotesVerificationCheckRecord(
        name: "source_note_readback",
        status: sourceStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_note_readback",
        status: targetStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_identity",
        status: targetMatchesDraft ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetMatchesDraft
      ),
      NotesVerificationCheckRecord(
        name: "target_paragraph_identity",
        status: paragraphMatchesDraft ? "passed" : "failed",
        expectedBool: true,
        actualBool: paragraphMatchesDraft
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_paragraph_link_write+anchor_hash_resolution+link_metadata_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  func verifyLinkUpdate(
    draft: NotesLinkUpdateDraft,
    result: NotesLinkUpdateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let expectedURLSHA256 = sha256Hex(draft.urlString)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
      ?? linkReadback.first { linkRecordMatches($0, urlString: draft.urlString) }
    let metadataPresent = matchingLink != nil
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let kindIsURL = matchingLink?.kind == "url"
    let schemeIsWeb = matchingLink.map { $0.urlScheme == "http" || $0.urlScheme == "https" } ?? false
    let urlHashMatches = matchingLink?.urlSHA256 == expectedURLSHA256
      || matchingLink.map { linkRecordMatches($0, urlString: draft.urlString) } == true
    let oldURLReplaced = matchingLink.map { updated in
      let oldHash = draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256
      guard let oldHash else {
        return true
      }
      let rawChanged: Bool
      if updated.urlString != nil || draft.link.urlString != nil {
        rawChanged =
          normalizedLinkURLForMatching(updated.urlString) != normalizedLinkURLForMatching(draft.link.urlString)
      } else {
        rawChanged = true
      }
      return updated.urlSHA256 != oldHash
        && rawChanged
    } ?? false
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsURL ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsURL
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeIsWeb ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeIsWeb
      ),
      NotesVerificationCheckRecord(
        name: "url_hash",
        status: urlHashMatches ? "passed" : "failed",
        expectedSHA256: expectedURLSHA256,
        actualSHA256: matchingLink?.urlSHA256
      ),
      NotesVerificationCheckRecord(
        name: "old_url_replaced",
        status: oldURLReplaced ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldURLReplaced
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_link_update+link_metadata_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyAppLinkUpdate(
    draft: NotesLinkUpdateDraft,
    result: NotesLinkUpdateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let expectedURLSHA256 = sha256Hex(draft.urlString)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
      ?? linkReadback.first { isAppLinkRecord($0) && $0.urlSHA256 == expectedURLSHA256 }
    let metadataPresent = matchingLink != nil
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let kindIsApp = matchingLink.map(isAppLinkRecord) ?? false
    let schemeMatches = matchingLink?.urlScheme == draft.url.scheme
    let urlHashMatches = matchingLink?.urlSHA256 == expectedURLSHA256
    let rawURLHidden = matchingLink?.urlString == nil
    let oldURLReplaced = matchingLink.map { updated in
      let oldHash = draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256
      guard let oldHash else {
        return true
      }
      let rawChanged: Bool
      if updated.urlString != nil || draft.link.urlString != nil {
        rawChanged =
          normalizedLinkURLForMatching(updated.urlString) != normalizedLinkURLForMatching(draft.link.urlString)
      } else {
        rawChanged = true
      }
      return updated.urlSHA256 != oldHash
        && rawChanged
    } ?? false
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsApp ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsApp
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeMatches
      ),
      NotesVerificationCheckRecord(
        name: "url_hash",
        status: urlHashMatches ? "passed" : "failed",
        expectedSHA256: expectedURLSHA256,
        actualSHA256: matchingLink?.urlSHA256
      ),
      NotesVerificationCheckRecord(
        name: "raw_url_hidden",
        status: rawURLHidden ? "passed" : "failed",
        expectedBool: true,
        actualBool: rawURLHidden
      ),
      NotesVerificationCheckRecord(
        name: "old_url_replaced",
        status: oldURLReplaced ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldURLReplaced
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_app_link_update+link_metadata_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyFileLinkUpdate(
    draft: NotesLinkUpdateDraft,
    result: NotesLinkUpdateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let expectedURLSHA256 = sha256Hex(draft.urlString)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
      ?? linkReadback.first { isFileLinkRecord($0) && $0.urlSHA256 == expectedURLSHA256 }
    let metadataPresent = matchingLink != nil
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let kindIsFile = matchingLink.map(isFileLinkRecord) ?? false
    let schemeMatches = matchingLink?.urlScheme == "file"
    let urlHashMatches = matchingLink?.urlSHA256 == expectedURLSHA256
    let rawURLHidden = matchingLink?.urlString == nil
    let sourceKindKnown = ["file", "directory"].contains(draft.sourceKind ?? fileLinkSourceKind(draft.url))
    let oldURLReplaced = matchingLink.map { updated in
      let oldHash = draft.link.urlString.map(sha256Hex) ?? draft.link.urlSHA256
      guard let oldHash else {
        return true
      }
      let rawChanged: Bool
      if updated.urlString != nil || draft.link.urlString != nil {
        rawChanged =
          normalizedLinkURLForMatching(updated.urlString) != normalizedLinkURLForMatching(draft.link.urlString)
      } else {
        rawChanged = true
      }
      return updated.urlSHA256 != oldHash
        && rawChanged
    } ?? false
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_readback",
        status: metadataPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsFile ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsFile
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeMatches
      ),
      NotesVerificationCheckRecord(
        name: "url_hash",
        status: urlHashMatches ? "passed" : "failed",
        expectedSHA256: expectedURLSHA256,
        actualSHA256: matchingLink?.urlSHA256
      ),
      NotesVerificationCheckRecord(
        name: "raw_url_hidden",
        status: rawURLHidden ? "passed" : "failed",
        expectedBool: true,
        actualBool: rawURLHidden
      ),
      NotesVerificationCheckRecord(
        name: "source_kind",
        status: sourceKindKnown ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceKindKnown
      ),
      NotesVerificationCheckRecord(
        name: "old_url_replaced",
        status: oldURLReplaced ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldURLReplaced
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_file_link_update+link_metadata_readback+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyNoteLinkUpdate(
    draft: NotesNoteLinkUpdateDraft,
    result: NotesNoteLinkUpdateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.sourceNoteID, limit: 2_000)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
    let selectedLinkPresent = matchingLink != nil
    let selectedLinkMatches = linkRecordMatches(result.oldLink, result.link)
    let kindIsNoteLink = matchingLink.map(isPlainNoteLinkRecord) ?? false
    let sourceStillPresent = try implementation.readNote(id: result.sourceNoteID) != nil
    let targetStillPresent = try implementation.readNote(id: result.targetNoteID) != nil
    let targetMatchesDraft = result.targetNoteID == draft.targetNoteID
    let targetChanged = result.oldTargetNoteID != result.targetNoteID
    let targetBacklinks = try linkReader().listBacklinks(noteID: result.targetNoteID, limit: 2_000)
    let targetBacklinkPresent = backlinksContainSourceAndLink(
      targetBacklinks,
      sourceNoteID: result.sourceNoteID,
      link: result.link
    )
    let oldTargetBacklinkAbsent: Bool
    if targetChanged {
      let oldTargetBacklinks = try linkReader().listBacklinks(noteID: result.oldTargetNoteID, limit: 2_000)
      oldTargetBacklinkAbsent = !backlinksContainSourceAndLink(
        oldTargetBacklinks,
        sourceNoteID: result.sourceNoteID,
        link: result.oldLink
      )
    } else {
      oldTargetBacklinkAbsent = true
    }
    let displayTextChecks = noteLinkDisplayTextChecks(
      displayText: draft.displayText,
      resultLink: result.link,
      matchingLink: matchingLink
    )
    let displayTextVerified = draft.displayText != nil
      && displayTextChecks.allSatisfy { $0.status == "passed" }
    let targetOrDisplayChanged = targetChanged || displayTextVerified
    var checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_readback",
        status: selectedLinkPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsNoteLink ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsNoteLink
      ),
      NotesVerificationCheckRecord(
        name: "source_note_readback",
        status: sourceStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_note_readback",
        status: targetStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_identity",
        status: targetMatchesDraft ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetMatchesDraft
      ),
      NotesVerificationCheckRecord(
        name: "target_or_display_text_changed",
        status: targetOrDisplayChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetOrDisplayChanged
      ),
      NotesVerificationCheckRecord(
        name: "target_backlink_readback",
        status: targetBacklinkPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetBacklinkPresent
      ),
      NotesVerificationCheckRecord(
        name: "old_target_backlink_absence",
        status: oldTargetBacklinkAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldTargetBacklinkAbsent
      ),
    ]
    checks.append(contentsOf: displayTextChecks)
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: draft.displayText == nil
        ? "private_framework_note_link_update+link_metadata_readback+backlink_readback"
        : "private_framework_note_link_update+link_display_text_hash_readback+backlink_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyParagraphLinkUpdate(
    draft: NotesParagraphLinkUpdateDraft,
    result: NotesParagraphLinkUpdateWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.sourceNoteID, limit: 2_000)
    let matchingLink = linkReadback.first { linkRecordMatches($0, result.link) }
      ?? linkReadback.first {
        isParagraphLinkRecord($0)
          && $0.tokenContentIdentifierSHA256 == result.targetTokenContentIdentifierSHA256
      }
    let selectedLinkPresent = matchingLink != nil
    let selectedLinkMatches = linkRecordMatches(result.oldLink, result.link)
    let kindIsParagraphLink = matchingLink.map(isParagraphLinkRecord) ?? false
    let sourceStillPresent = try implementation.readNote(id: result.sourceNoteID) != nil
    let targetStillPresent = try implementation.readNote(id: result.targetNoteID) != nil
    let oldTargetStillPresent = try implementation.readNote(id: result.oldTargetNoteID) != nil
    let targetMatchesDraft = result.targetNoteID == draft.targetNoteID
    let paragraphMatchesDraft = result.targetParagraphIDSHA256 == draft.targetParagraphIDSHA256
    let tokenHashMatches = matchingLink?.tokenContentIdentifierSHA256 == result.targetTokenContentIdentifierSHA256
    let oldTokenReplaced = result.oldTokenContentIdentifierSHA256.map {
      $0 != result.targetTokenContentIdentifierSHA256
    } ?? true
    let targetChanged = result.oldTargetNoteID != result.targetNoteID
      || result.oldTargetParagraphIDSHA256 != result.targetParagraphIDSHA256
      || oldTokenReplaced
    let targetBacklinks = try linkReader().listBacklinks(noteID: result.targetNoteID, limit: 2_000)
    let targetBacklinkPresent = backlinksContainSourceAndLink(
      targetBacklinks,
      sourceNoteID: result.sourceNoteID,
      link: result.link
    )
    let oldTargetBacklinkAbsent: Bool
    if result.oldTargetNoteID == result.targetNoteID {
      oldTargetBacklinkAbsent = true
    } else {
      let oldTargetBacklinks = try linkReader().listBacklinks(noteID: result.oldTargetNoteID, limit: 2_000)
      oldTargetBacklinkAbsent = !backlinksContainSourceAndLink(
        oldTargetBacklinks,
        sourceNoteID: result.sourceNoteID,
        link: result.oldLink
      )
    }
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_readback",
        status: selectedLinkPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindIsParagraphLink ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindIsParagraphLink
      ),
      NotesVerificationCheckRecord(
        name: "source_note_readback",
        status: sourceStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: sourceStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "old_target_note_readback",
        status: oldTargetStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldTargetStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_note_readback",
        status: targetStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "target_identity",
        status: targetMatchesDraft ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetMatchesDraft
      ),
      NotesVerificationCheckRecord(
        name: "target_paragraph_identity",
        status: paragraphMatchesDraft ? "passed" : "failed",
        expectedBool: true,
        actualBool: paragraphMatchesDraft
      ),
      NotesVerificationCheckRecord(
        name: "target_token_hash",
        status: tokenHashMatches ? "passed" : "failed",
        expectedSHA256: result.targetTokenContentIdentifierSHA256,
        actualSHA256: matchingLink?.tokenContentIdentifierSHA256
      ),
      NotesVerificationCheckRecord(
        name: "old_token_replaced",
        status: oldTokenReplaced ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldTokenReplaced
      ),
      NotesVerificationCheckRecord(
        name: "target_changed",
        status: targetChanged ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetChanged
      ),
      NotesVerificationCheckRecord(
        name: "target_backlink_readback",
        status: targetBacklinkPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: targetBacklinkPresent
      ),
      NotesVerificationCheckRecord(
        name: "old_target_backlink_absence",
        status: oldTargetBacklinkAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: oldTargetBacklinkAbsent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_paragraph_link_update+anchor_hash_resolution+link_metadata_readback+backlink_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyLinkRemove(
    draft: NotesLinkRemoveDraft,
    result: NotesLinkRemoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let metadataAbsent = !linkReadback.contains { linkRecordMatches($0, result.link) }
    let kindWasURL = result.link.kind == "url"
    let schemeWasWeb = result.link.urlScheme == "http" || result.link.urlScheme == "https"
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_absence",
        status: metadataAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataAbsent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindWasURL ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindWasURL
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeWasWeb ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeWasWeb
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_inline_link_remove+link_absence+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyAppLinkRemove(
    draft: NotesLinkRemoveDraft,
    result: NotesLinkRemoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let metadataAbsent = !linkReadback.contains { linkRecordMatches($0, result.link) }
    let kindWasApp = isAppLinkRecord(result.link)
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_absence",
        status: metadataAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataAbsent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindWasApp ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindWasApp
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_app_link_remove+link_absence+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyFileLinkRemove(
    draft: NotesLinkRemoveDraft,
    result: NotesLinkRemoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let metadataAbsent = !linkReadback.contains { linkRecordMatches($0, result.link) }
    let kindWasURL = result.link.kind == "url"
    let schemeWasFile = result.link.urlScheme == "file"
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_absence",
        status: metadataAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataAbsent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindWasURL ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindWasURL
      ),
      NotesVerificationCheckRecord(
        name: "url_scheme",
        status: schemeWasFile ? "passed" : "failed",
        expectedBool: true,
        actualBool: schemeWasFile
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_file_link_remove+link_absence+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyNoteLinkRemove(
    draft: NotesNoteLinkRemoveDraft,
    result: NotesNoteLinkRemoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let metadataAbsent = !linkReadback.contains { linkRecordMatches($0, result.link) }
    let kindWasNoteLink = isPlainNoteLinkRecord(result.link)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_absence",
        status: metadataAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataAbsent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindWasNoteLink ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindWasNoteLink
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_note_link_remove+link_absence+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func verifyParagraphLinkRemove(
    draft: NotesParagraphLinkRemoveDraft,
    result: NotesParagraphLinkRemoveWriteResult,
    operation: String
  ) throws -> NotesMutationVerificationReport {
    let linkReadback = try linkReader().listLinks(noteID: result.noteID, limit: 2_000)
    let metadataAbsent = !linkReadback.contains { linkRecordMatches($0, result.link) }
    let kindWasParagraphLink = isParagraphLinkRecord(result.link)
    let noteStillPresent = try implementation.readNote(id: result.noteID) != nil
    let selectedLinkMatches = linkRecordMatches(draft.link, result.link)
    let checks = [
      NotesVerificationCheckRecord(
        name: "changed",
        status: result.changed ? "passed" : "failed",
        expectedBool: true,
        actualBool: result.changed
      ),
      NotesVerificationCheckRecord(
        name: "link_metadata_absence",
        status: metadataAbsent ? "passed" : "failed",
        expectedBool: true,
        actualBool: metadataAbsent
      ),
      NotesVerificationCheckRecord(
        name: "link_kind",
        status: kindWasParagraphLink ? "passed" : "failed",
        expectedBool: true,
        actualBool: kindWasParagraphLink
      ),
      NotesVerificationCheckRecord(
        name: "note_readback",
        status: noteStillPresent ? "passed" : "failed",
        expectedBool: true,
        actualBool: noteStillPresent
      ),
      NotesVerificationCheckRecord(
        name: "selected_link_identity",
        status: selectedLinkMatches ? "passed" : "failed",
        expectedBool: true,
        actualBool: selectedLinkMatches
      ),
    ]
    return NotesMutationVerificationReport(
      operation: operation,
      verified: checks.allSatisfy { $0.status == "passed" },
      evidenceLevel: "private_framework_paragraph_link_remove+link_absence+note_readback",
      targetIDSHA256: sha256Hex(result.link.id),
      checks: checks
    )
  }

  private func validateWebURLLinkRemoveTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard link.kind == "url",
      link.isParagraphLink == false,
      link.isInternalParagraphLink == false,
      link.urlString != nil,
      link.urlScheme == "http" || link.urlScheme == "https"
    else {
      throw CLIError(
        code: .validationError,
        message: "Only http or https URL link removal is currently supported.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
        ]
      )
    }
  }

  func validateWebURLLinkUpdateTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard link.kind == "url",
      link.isParagraphLink == false,
      link.isInternalParagraphLink == false,
      link.urlString != nil,
      link.urlScheme == "http" || link.urlScheme == "https"
    else {
      throw CLIError(
        code: .validationError,
        message: "Only http or https URL link update is currently supported.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
        ]
      )
    }
  }

  private func validateAppURLLinkRemoveTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isAppLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only app URL link removal is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
        ]
      )
    }
  }

  private func validateAppURLLinkUpdateTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isAppLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only app URL link update is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
        ]
      )
    }
  }

  private func validateFileURLLinkUpdateTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isFileLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only file URL link update is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
        ]
      )
    }
  }

  private func validateFileURLLinkRemoveTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard link.kind == "url",
      link.isParagraphLink == false,
      link.isInternalParagraphLink == false,
      link.urlScheme == "file"
    else {
      throw CLIError(
        code: .validationError,
        message: "Only file URL link removal is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
        ]
      )
    }
  }

  private func validatePlainNoteLinkRemoveTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isPlainNoteLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only ordinary note-to-note link removal is currently supported.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
          "paragraph": "\(link.isParagraphLink)",
          "internal_paragraph": "\(link.isInternalParagraphLink)",
        ]
      )
    }
  }

  private func validatePlainNoteLinkUpdateTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isPlainNoteLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only ordinary note-to-note link update is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
          "paragraph": "\(link.isParagraphLink)",
          "internal_paragraph": "\(link.isInternalParagraphLink)",
        ]
      )
    }
  }

  private func validateParagraphLinkRemoveTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isParagraphLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only paragraph note-link removal is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
          "paragraph": "\(link.isParagraphLink)",
          "internal_paragraph": "\(link.isInternalParagraphLink)",
        ]
      )
    }
  }

  private func validateParagraphLinkUpdateTarget(
    _ link: NotesLinkRecord,
    noteID: String,
    requestedLinkID: String
  ) throws {
    guard isParagraphLinkRecord(link) else {
      throw CLIError(
        code: .validationError,
        message: "Only paragraph note-link update is currently supported by this command.",
        details: [
          "id_sha256": sha256Hex(noteID),
          "link_sha256": sha256Hex(requestedLinkID),
          "link_kind": link.kind,
          "scheme": link.urlScheme ?? "",
          "paragraph": "\(link.isParagraphLink)",
          "internal_paragraph": "\(link.isInternalParagraphLink)",
        ]
      )
    }
  }

  func linkRecordMatches(_ link: NotesLinkRecord, urlString: String) -> Bool {
    link.urlString == urlString
      || normalizedLinkURLForMatching(link.urlString) == normalizedLinkURLForMatching(urlString)
      || link.urlSHA256 == sha256Hex(urlString)
  }

  func linkRecordMatches(_ link: NotesLinkRecord, selector: String) -> Bool {
    [
      link.id,
      link.displayText,
      link.altText,
      link.urlString,
      link.urlSHA256,
      link.tokenContentIdentifierSHA256,
    ].compactMap { $0 }
      .contains { $0 == selector }
      || normalizedLinkURLForMatching(link.urlString) == normalizedLinkURLForMatching(selector)
  }

  func linkRecordMatches(_ lhs: NotesLinkRecord, _ rhs: NotesLinkRecord) -> Bool {
    lhs.id == rhs.id
      || (lhs.tokenContentIdentifierSHA256 != nil
        && lhs.tokenContentIdentifierSHA256 == rhs.tokenContentIdentifierSHA256)
  }

  private func backlinksContainSourceAndLink(
    _ backlinks: [NotesBacklinkRecord],
    sourceNoteID: String,
    link: NotesLinkRecord
  ) -> Bool {
    backlinks.contains { backlink in
      backlink.sourceNote.id == sourceNoteID
        && linkRecordMatches(backlink.link, link)
    }
  }

  private func isNoteLinkRecord(_ link: NotesLinkRecord) -> Bool {
    link.kind == "note"
      || link.isParagraphLink
      || link.isInternalParagraphLink
      || ["notes", "applenotes", "mobilenotes"].contains(link.urlScheme ?? "")
  }

  private func isPlainNoteLinkRecord(_ link: NotesLinkRecord) -> Bool {
    (link.kind == "note" || ["notes", "applenotes", "mobilenotes"].contains(link.urlScheme ?? ""))
      && link.isParagraphLink == false
      && link.isInternalParagraphLink == false
  }

  private func isParagraphLinkRecord(_ link: NotesLinkRecord) -> Bool {
    link.kind == "paragraph"
      || link.kind == "internal_paragraph"
      || link.isParagraphLink
      || link.isInternalParagraphLink
  }

  private func isAppLinkRecord(_ link: NotesLinkRecord) -> Bool {
    link.kind == "app"
      || link.urlScheme.map(isAppLinkScheme) == true
  }

  private func isFileLinkRecord(_ link: NotesLinkRecord) -> Bool {
    link.kind == "url"
      && link.urlScheme == "file"
      && link.isParagraphLink == false
      && link.isInternalParagraphLink == false
  }

  private func isAppLinkScheme(_ scheme: String) -> Bool {
    !["http", "https", "mailto", "tel", "sms", "file", "notes", "applenotes", "mobilenotes"]
      .contains(scheme.lowercased())
  }

  func normalizedLinkURLForMatching(_ value: String?) -> String? {
    guard let value, var components = URLComponents(string: value) else {
      return value
    }
    components.scheme = components.scheme?.lowercased()
    components.host = components.host?.lowercased()
    if components.path == "/" {
      components.path = ""
    }
    return components.string ?? value
  }

  func linkReader() throws -> any NotesLinkReading {
    guard let linkReader = implementation as? any NotesLinkReading else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes link commands require a private-framework link reader.",
        details: [
          "capability": "links",
          "required_module": "NotesShared",
        ]
      )
    }
    return linkReader
  }

  func linkMutator() throws -> any NotesLinkMutating {
    guard let linkMutator = implementation as? any NotesLinkMutating else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes link mutations require a private-framework link writer.",
        details: [
          "capability": "links_mutation",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return linkMutator
  }

  private func paragraphAnchorResolver() throws -> any NotesParagraphAnchorResolving {
    guard let paragraphAnchorResolver = implementation as? any NotesParagraphAnchorResolving else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes paragraph link commands require a private-framework paragraph anchor resolver.",
        details: [
          "capability": "paragraph_links",
          "required_module": "NotesShared/NotesUI",
        ]
      )
    }
    return paragraphAnchorResolver
  }
}
