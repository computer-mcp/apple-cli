import Darwin
import Foundation
import ObjectiveC.runtime
import Utility

struct NotesRuntimeReadinessResult: Equatable, Sendable {
  var frameworks: [NotesRuntimeFrameworkLoadResult]
  var classes: [NotesRuntimeClassProbeResult]

  var failedFrameworks: [NotesRuntimeFrameworkLoadResult] {
    frameworks.filter { !$0.loaded }
  }

  var missingClasses: [NotesRuntimeClassProbeResult] {
    classes.filter { !$0.available }
  }

  var missingSelectors: [String] {
    classes.flatMap { classResult in
      classResult.missingSelectors.map { "\(classResult.className).\($0)" }
    }
  }

  var deferredSelectors: [String] {
    classes.flatMap { result in result.deferredSelectors.map { "\(result.className).\($0)" } }
  }

  var isReady: Bool {
    failedFrameworks.isEmpty && missingClasses.isEmpty && missingSelectors.isEmpty && deferredSelectors.isEmpty
  }
}

struct NotesRuntimeFrameworkLoadResult: Equatable, Sendable {
  var name: String
  var path: String
  var loaded: Bool
  var error: String?
}

struct NotesRuntimeClassProbeResult: Equatable, Sendable {
  var className: String
  var available: Bool
  var requiredSelectors: [String]
  var missingSelectors: [String]
  var deferredSelectors: [String] = []
}

struct NotesRuntimeReadinessProbe: Sendable {
  func run() -> NotesRuntimeReadinessResult {
    let frameworks = Self.frameworks.map(loadFramework)
    let accessors = NotesManagedAccessorProbe.installedModel()
    let classes = Self.classes.map { probeClass($0, accessors: accessors) }
    return NotesRuntimeReadinessResult(frameworks: frameworks, classes: classes)
  }

  private func loadFramework(_ framework: FrameworkDefinition) -> NotesRuntimeFrameworkLoadResult {
    let handle = dlopen(framework.path, RTLD_NOW | RTLD_LOCAL)
    guard handle != nil else {
      let error = dlerror().map { String(cString: $0) } ?? "dlopen failed without detail."
      return NotesRuntimeFrameworkLoadResult(
        name: framework.name,
        path: framework.path,
        loaded: false,
        error: error
      )
    }

    return NotesRuntimeFrameworkLoadResult(
      name: framework.name,
      path: framework.path,
      loaded: true,
      error: nil
    )
  }

  private func probeClass(_ definition: ClassDefinition, accessors: NotesManagedAccessorProbe) -> NotesRuntimeClassProbeResult {
    guard let loadedClass = NSClassFromString(definition.name) else {
      return NotesRuntimeClassProbeResult(
        className: definition.name,
        available: false,
        requiredSelectors: definition.instanceSelectors,
        missingSelectors: definition.instanceSelectors
      )
    }

    let unresolved = definition.instanceSelectors.filter { selectorName in
      class_getInstanceMethod(loadedClass, NSSelectorFromString(selectorName)) == nil
    }
    let deferred = unresolved.filter { accessors.isDeferred(loadedClass, selector: $0) }
    let missingSelectors = unresolved.filter { !deferred.contains($0) }

    return NotesRuntimeClassProbeResult(
      className: definition.name,
      available: true,
      requiredSelectors: definition.instanceSelectors,
      missingSelectors: missingSelectors, deferredSelectors: deferred
    )
  }

  private struct FrameworkDefinition: Sendable {
    var name: String
    var path: String
  }

  private struct ClassDefinition: Sendable {
    var name: String
    var instanceSelectors: [String]
  }

  private static let frameworks: [FrameworkDefinition] = [
    framework("NotesSupport"),
    framework("NotesHTML"),
    framework("NotesShared"),
    framework("NotesUI"),
    framework("NotesEditor"),
    framework("NotesPreviewKit"),
  ]

  private static let classes: [ClassDefinition] = [
    ClassDefinition(
      name: "ICArchiveReader",
      instanceSelectors: [
        "initWithSourceURL:destinationURL:",
        "unarchiveSourcePath:toDestinationPath:error:",
      ]
    ),
    ClassDefinition(
      name: "ICArchiveWriter",
      instanceSelectors: [
        "initWithDestinationURL:baseURL:",
        "writeURLs:error:",
      ]
    ),
    ClassDefinition(
      name: "ICAttachment",
      instanceSelectors: []
    ),
    ClassDefinition(
      name: "ICFolder",
      instanceSelectors: [
        "visibleNotesInFolder",
        "smartFolderQuery",
        "smartFolderQueryJSON",
        "setSmartFolderQueryJSON:",
      ]
    ),
    ClassDefinition(
      name: "ICNote",
      instanceSelectors: [
        "creationDate",
        "modificationDate",
        "noteAsPlainTextWithoutTitle",
      ]
    ),
    ClassDefinition(
      name: "ICNoteContext",
      instanceSelectors: []
    ),
    ClassDefinition(
      name: "ICSearchQuery",
      instanceSelectors: [
        "rankingQueries",
        "modernResultsOnly",
      ]
    ),
    ClassDefinition(
      name: "_TtC11NotesShared16NotesDataManager",
      instanceSelectors: []
    ),
  ]

  private static func framework(_ name: String) -> FrameworkDefinition {
    FrameworkDefinition(
      name: name,
      path: "/System/Library/PrivateFrameworks/\(name).framework/\(name)"
    )
  }
}

func notesRuntimeReadinessDoctorCheck() -> CLIDoctorCheck {
  let result = NotesRuntimeReadinessProbe().run()
  let loadedFrameworks = result.frameworks.filter { $0.loaded }.map(\.name).sorted()
  let failedFrameworks = result.failedFrameworks.map(\.name).sorted()
  let availableClasses = result.classes.filter { $0.available }.map(\.className).sorted()
  let missingClasses = result.missingClasses.map(\.className).sorted()
  let missingSelectors = result.missingSelectors.sorted()

  var details: [String: String] = [
    "framework_count": "\(result.frameworks.count)",
    "loaded_frameworks": loadedFrameworks.joined(separator: ","),
    "failed_frameworks": failedFrameworks.joined(separator: ","),
    "required_class_count": "\(result.classes.count)",
    "available_classes": availableClasses.joined(separator: ","),
    "missing_classes": missingClasses.joined(separator: ","),
    "missing_selectors": missingSelectors.joined(separator: ","),
    "deferred_model_accessors": result.deferredSelectors.sorted().joined(separator: ","),
  ]

  for framework in result.failedFrameworks {
    if let error = framework.error {
      details["error_\(framework.name)"] = error
    }
  }

  return CLIDoctorCheck(
    name: "notes_runtime_readiness",
    status: result.isReady ? .ok : .warning,
    message: result.isReady
      ? "Notes framework modules runtime-load and key NotesShared/NotesSupport classes are registered."
      : result.failedFrameworks.isEmpty && result.missingClasses.isEmpty && result.missingSelectors.isEmpty
        ? "Notes classes and model properties are present; deferred Core Data accessors require operation-context verification."
        : "Notes runtime readiness is incomplete; default Notes commands require framework module readiness.",
    details: details
  )
}

struct NotesWriteCapabilityProbeResult: Equatable, Sendable {
  var selectors: [NotesWriteCapabilitySelectorProbeResult]

  var missingSelectors: [NotesWriteCapabilitySelectorProbeResult] {
    selectors.filter { !$0.available }
  }

  var missingRequiredSelectors: [NotesWriteCapabilitySelectorProbeResult] {
    selectors.filter { $0.required && !$0.available }
  }

  var isReady: Bool {
    missingRequiredSelectors.isEmpty
  }
}

struct NotesWriteCapabilitySelectorProbeResult: Equatable, Sendable {
  var owner: String
  var selector: String
  var kind: String
  var required: Bool
  var available: Bool
}

struct NotesWriteCapabilityProbe: Sendable {
  func run() -> NotesWriteCapabilityProbeResult {
    let frameworkProbe = NotesRuntimeReadinessProbe()
    _ = frameworkProbe.run()

    return NotesWriteCapabilityProbeResult(
      selectors: Self.selectors.map(probeSelector)
    )
  }

  private func probeSelector(_ selector: SelectorDefinition)
    -> NotesWriteCapabilitySelectorProbeResult
  {
    guard let loadedClass = NSClassFromString(selector.owner) else {
      return NotesWriteCapabilitySelectorProbeResult(
        owner: selector.owner,
        selector: selector.name,
        kind: selector.kind.rawValue,
        required: selector.required,
        available: false
      )
    }

    let runtimeSelector = NSSelectorFromString(selector.name)
    let available =
      switch selector.kind {
      case .class:
        class_getClassMethod(loadedClass, runtimeSelector) != nil
      case .instance:
        class_getInstanceMethod(loadedClass, runtimeSelector) != nil
      }

    return NotesWriteCapabilitySelectorProbeResult(
      owner: selector.owner,
      selector: selector.name,
      kind: selector.kind.rawValue,
      required: selector.required,
      available: available
    )
  }

  private struct SelectorDefinition: Sendable {
    var owner: String
    var name: String
    var kind: SelectorKind
    var required: Bool = true
  }

  private enum SelectorKind: String, Sendable {
    case `class`
    case instance
  }

  private static let selectors: [SelectorDefinition] = [
    SelectorDefinition(
      owner: "ICNote",
      name: "newNoteWithString:inFolder:error:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "newNoteWithAttributedString:inFolder:error:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "duplicateNote:intoFolder:isPasswordProtected:removeOriginalNote:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "noteWithIdentifier:includeDeleted:context:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "appendAttributedString:error:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "textStorage",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "beginEditing",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "didChangeNoteText",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "endEditing",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "markForDeletion",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "purgeNote:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "changePinStatusIfPossible",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "isPinned",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "isPinnable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "isDeletedOrInTrash",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "unmarkForDeletion",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "isMovable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "isDuplicatable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "primitiveFolder",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "setPrimitiveFolder:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "setAccount:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "ensureHashtagsExistInDestinationAccount",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "save",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "newFolderInAccount:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "newFolderInParentFolder:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "isTitleValid:account:parentFolder:error:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "canAddSubfolder",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "isRenamable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "isTitleValid:error:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "setTitle:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "setDateForLastTitleModification:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "updateChangeCountWithReason:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "isMovable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "setParent:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "setAccount:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "setParentModificationDate:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "isDeletable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "markForDeletion",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "setMarkedForDeletion:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "isDeletedOrInTrash",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "isDeletable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "markForDeletion",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "supportsRenaming",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "setTitle:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "setUserTitle:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "attachmentDidChange",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICAttachment",
      name: "persistPendingChanges",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICNote",
      name: "addURLAttachmentWithURL:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "newLinkAttachmentToNote:fromNote:parentAttachment:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "newLinkAttachmentToNote:paragraphID:paragraphName:fromNote:parentAttachment:",
      kind: .class
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "isLinkAttachment",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "isParagraphLinkAttachment",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "isInternalParagraphLinkAttachment",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "isVisible",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "isDeletable",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "markedForDeletion",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "markForDeletion",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "setTokenContentIdentifier:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "setAltText:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "markDisplayTextNeedsUpdate",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICInlineAttachment",
      name: "changeLinkDestinationFromNote:toNote:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "ICNoteContext",
      name: "save:",
      kind: .instance
    ),
    SelectorDefinition(
      owner: "ICFolder",
      name: "newNoteInContext:",
      kind: .instance,
      required: false
    ),
    SelectorDefinition(
      owner: "NSManagedObjectContext",
      name: "ic_save",
      kind: .instance,
      required: true
    ),
  ]
}

func notesWriteCapabilityDoctorCheck() -> CLIDoctorCheck {
  let result = NotesWriteCapabilityProbe().run()
  let availableSelectors = result.selectors
    .filter { $0.available }
    .map { "\($0.owner).\($0.selector)" }
    .sorted()
  let missingSelectors = result.missingSelectors
    .map { "\($0.owner).\($0.selector)" }
    .sorted()
  let missingRequiredSelectors = result.missingRequiredSelectors
    .map { "\($0.owner).\($0.selector)" }
    .sorted()

  return CLIDoctorCheck(
    name: "notes_write_capability",
    status: result.isReady ? .ok : .warning,
    message: result.isReady
      ? "Notes write capability selectors are present; no write was executed."
      : "Notes write capability selectors are incomplete; write promotion remains gated.",
    details: [
      "mode": "probe_only",
      "write_access": "none",
      "candidate_selector_count": "\(result.selectors.count)",
      "required_selector_count": "\(result.selectors.filter { $0.required }.count)",
      "available_selectors": availableSelectors.joined(separator: ","),
      "missing_selectors": missingSelectors.joined(separator: ","),
      "missing_required_selectors": missingRequiredSelectors.joined(separator: ","),
      "candidate_create_path": "ICNote.newNoteWithString:inFolder:error:",
      "candidate_move_path": "ICNote.primitiveFolder + ICNote.setAccount:",
      "candidate_copy_path": "ICNote.duplicateNote:intoFolder:isPasswordProtected:removeOriginalNote:",
      "candidate_restore_path": "ICNote.noteWithIdentifier:includeDeleted:context: + ICNote.unmarkForDeletion",
      "candidate_folder_create_path": "ICFolder.newFolderInAccount: / ICFolder.newFolderInParentFolder:",
      "candidate_folder_rename_path": "ICFolder.isRenamable + ICFolder.setTitle:",
      "candidate_folder_move_path": "ICFolder.isMovable + ICFolder.setParent:",
      "candidate_folder_delete_path": "ICFolder.isDeletable + ICFolder.markForDeletion",
      "candidate_attachment_remove_path": "ICAttachment.isDeletable + ICAttachment.markForDeletion",
      "candidate_attachment_rename_path": "ICAttachment.supportsRenaming + ICAttachment.setTitle:",
      "candidate_link_add_path": "ICNote.addURLAttachmentWithURL:",
      "candidate_app_link_add_path": "ICNote.addURLAttachmentWithURL:",
      "candidate_file_link_add_path": "ICNote.addURLAttachmentWithURL:",
      "candidate_note_link_add_path": "ICInlineAttachment.newLinkAttachmentToNote:fromNote:parentAttachment:",
      "candidate_paragraph_link_add_path":
        "ICInlineAttachment.newLinkAttachmentToNote:paragraphID:paragraphName:fromNote:parentAttachment:",
      "candidate_note_link_update_path": "ICInlineAttachment.changeLinkDestinationFromNote:toNote:",
      "candidate_paragraph_link_update_path":
        "ICAppURLUtilities.appURLForNote:paragraphID: + ICInlineAttachment.changeLinkDestinationFromNote:toNote: + ICInlineAttachment.setTokenContentIdentifier:",
      "candidate_link_remove_path": "ICInlineAttachment.isLinkAttachment + ICInlineAttachment.isDeletable + ICInlineAttachment.markForDeletion",
      "candidate_app_link_remove_path": "ICInlineAttachment.isLinkAttachment + ICInlineAttachment.isDeletable + ICInlineAttachment.markForDeletion",
      "candidate_note_link_remove_path": "ICInlineAttachment.isLinkAttachment + ICInlineAttachment.isDeletable + ICInlineAttachment.markForDeletion",
      "candidate_paragraph_link_remove_path":
        "ICInlineAttachment.isParagraphLinkAttachment/isInternalParagraphLinkAttachment + ICInlineAttachment.isDeletable + ICInlineAttachment.markForDeletion",
      "candidate_link_update_path":
        "ICInlineAttachment.setTokenContentIdentifier: + ICInlineAttachment.setAltText: + ICInlineAttachment.markDisplayTextNeedsUpdate",
      "candidate_app_link_update_path":
        "ICInlineAttachment.setTokenContentIdentifier: + ICInlineAttachment.setAltText: + ICInlineAttachment.markDisplayTextNeedsUpdate",
      "candidate_file_link_update_path":
        "ICInlineAttachment.setTokenContentIdentifier: + ICInlineAttachment.setAltText: + ICInlineAttachment.markDisplayTextNeedsUpdate",
      "candidate_save_path": "ICNoteContext.save: or NSManagedObjectContext.ic_save",
      "candidate_delete_path": "ICNote.markForDeletion",
      "candidate_purge_path": "ICNote.noteWithIdentifier:includeDeleted:context: + ICNote.purgeNote:",
      "candidate_pin_path": "ICNote.isPinned/isPinnable + ICNote.changePinStatusIfPossible",
    ]
  )
}

struct NotesRichCapabilityProbeResult: Equatable, Sendable {
  var candidates: [NotesRichCapabilityCandidateProbeResult]

  var families: [String] {
    Array(Set(candidates.map(\.family))).sorted()
  }

  var missingCandidates: [NotesRichCapabilityCandidateProbeResult] {
    candidates.filter { !$0.available && !$0.deferred }
  }

  var missingRequiredCandidates: [NotesRichCapabilityCandidateProbeResult] {
    candidates.filter { $0.required && !$0.available && !$0.deferred }
  }

  var deferredCandidates: [NotesRichCapabilityCandidateProbeResult] {
    candidates.filter { $0.deferred }
  }

  var isReady: Bool {
    missingRequiredCandidates.isEmpty && !deferredCandidates.contains { $0.required }
  }
}

struct NotesRichCapabilityCandidateProbeResult: Equatable, Sendable {
  var family: String
  var owner: String
  var selector: String?
  var kind: String
  var required: Bool
  var available: Bool
  var deferred: Bool = false

  var label: String {
    if let selector {
      return "\(family):\(owner).\(selector)"
    }
    return "\(family):\(owner)"
  }
}

struct NotesRichCapabilityProbe: Sendable {
  func run() -> NotesRichCapabilityProbeResult {
    let frameworkProbe = NotesRuntimeReadinessProbe()
    _ = frameworkProbe.run()

    let accessors = NotesManagedAccessorProbe.installedModel()
    return NotesRichCapabilityProbeResult(
      candidates: Self.candidates.map { probeCandidate($0, accessors: accessors) }
    )
  }

  private func probeCandidate(_ candidate: CandidateDefinition, accessors: NotesManagedAccessorProbe)
    -> NotesRichCapabilityCandidateProbeResult
  {
    guard let loadedClass = NSClassFromString(candidate.owner) else {
      return result(candidate, available: false)
    }

    guard let selectorName = candidate.selector else {
      return result(candidate, available: true)
    }

    let runtimeSelector = NSSelectorFromString(selectorName)
    let available =
      switch candidate.kind {
      case .classPresence:
        true
      case .classMethod:
        class_getClassMethod(loadedClass, runtimeSelector) != nil
      case .instanceMethod:
        class_getInstanceMethod(loadedClass, runtimeSelector) != nil
      }

    let deferred = !available && candidate.kind == .instanceMethod
      && accessors.isDeferred(loadedClass, selector: selectorName)
    return result(candidate, available: available, deferred: deferred)
  }

  private func result(_ candidate: CandidateDefinition, available: Bool, deferred: Bool = false)
    -> NotesRichCapabilityCandidateProbeResult
  {
    NotesRichCapabilityCandidateProbeResult(
      family: candidate.family,
      owner: candidate.owner,
      selector: candidate.selector,
      kind: candidate.kind.rawValue,
      required: candidate.required,
      available: available, deferred: deferred
    )
  }

  private struct CandidateDefinition: Sendable {
    var family: String
    var owner: String
    var selector: String?
    var kind: CandidateKind
    var required: Bool = true
  }

  private enum CandidateKind: String, Sendable {
    case classPresence = "class"
    case classMethod = "class_method"
    case instanceMethod = "instance_method"
  }

  private static let candidates: [CandidateDefinition] = [
    CandidateDefinition(family: "attachments", owner: "ICAttachment", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "attachments", owner: "ICNote", selector: "attachmentsInOrder", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICNote", selector: "addAttachmentWithFileURL:", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICNote", selector: "addAttachmentWithData:filename:", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "isDeletedOrInTrash", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "isDeletable", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "markForDeletion", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "supportsRenaming", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "setTitle:", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "setUserTitle:", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "attachmentDidChange", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "persistPendingChanges", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "typeUTI", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachment", selector: "media", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "attachments", owner: "ICMedia", selector: "writeDataFromFileURL:error:", kind: .instanceMethod),
    CandidateDefinition(
      family: "attachments", owner: "ICAttachmentInsertionController", selector: "addAttachment:", kind: .instanceMethod,
      required: false),

    CandidateDefinition(family: "links", owner: "ICInlineAttachment", selector: nil, kind: .classPresence),
    CandidateDefinition(family: "links", owner: "ICLinkTextAttachment", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "newLinkAttachmentWithURL:name:currentNote:",
      kind: .classMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "newLinkAttachmentToNote:fromNote:parentAttachment:",
      kind: .classMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment",
      selector: "newLinkAttachmentToNote:paragraphID:paragraphName:fromNote:parentAttachment:", kind: .classMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment",
      selector: "enumerateLinksToNote:batchSize:visibleOnly:saveAfterBatch:context:usingBlock:", kind: .classMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "changeLinkDestinationFromNote:toNote:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICNote", selector: "addURLAttachmentWithURL:", kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "isLinkAttachment", kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "isParagraphLinkAttachment", kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "isInternalParagraphLinkAttachment",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "isVisible", kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "isDeletable", kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "markedForDeletion", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "links", owner: "ICInlineAttachment", selector: "markForDeletion", kind: .instanceMethod),
    CandidateDefinition(
      family: "links", owner: "ICAttachment", selector: "retrieveLinkMetadata", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "links", owner: "ICAttachment", selector: "persistLinkMetadata:", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "links", owner: "ICLinkConverter", selector: "initWithInsertionController:", kind: .instanceMethod,
      required: false),

    CandidateDefinition(family: "tags", owner: "ICHashtag", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "tags", owner: "ICHashtag", selector: "allVisibleHashtagsInContext:", kind: .classMethod),
    CandidateDefinition(
      family: "tags", owner: "ICHashtag", selector: "hashtagWithDisplayText:account:createIfNecessary:",
      kind: .classMethod),
    CandidateDefinition(
      family: "tags", owner: "ICHashtag", selector: "renameHashtagsWithStandardizedContent:newDisplayText:context:",
      kind: .classMethod),
    CandidateDefinition(
      family: "tags", owner: "ICHashtag", selector: "canRenameTagWithNewDisplayText:", kind: .instanceMethod),
    CandidateDefinition(
      family: "tags", owner: "ICHashtag", selector: "removeUsage", kind: .instanceMethod),
    CandidateDefinition(
      family: "tags", owner: "ICFolder", selector: "smartFoldersThatWillBeDeletedAfterDeletingHashtags:",
      kind: .classMethod),
    CandidateDefinition(
      family: "tags", owner: "ICInlineAttachment",
      selector: "createHashtagAttachmentIfApplicableWithHashtagText:creatingHashtagIfNecessary:note:parentAttachment:",
      kind: .classMethod),
    CandidateDefinition(family: "tags", owner: "ICTagSelection", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "tags", owner: "ICTagSelection", selector: "initWithManagedObjectContext:", kind: .instanceMethod),
    CandidateDefinition(
      family: "tags", owner: "ICTagSelection", selector: "dataRepresentation", kind: .instanceMethod,
      required: false),

    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "smartFolderWithQuery:account:", kind: .classMethod),
    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "smartFolderWithQuery:titleComponents:account:",
      kind: .classMethod),
    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "visibleSmartFoldersForHashtagStandardizedContent:account:",
      kind: .classMethod),
    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "isSmartFolder", kind: .instanceMethod),
    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "smartFolderQuery", kind: .instanceMethod),
    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "smartFolderQueryJSON", kind: .instanceMethod),
    CandidateDefinition(
      family: "smart_folders", owner: "ICFolder", selector: "setSmartFolderQueryJSON:", kind: .instanceMethod),
    CandidateDefinition(family: "smart_folders", owner: "ICVirtualSmartFolderItemIdentifier", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "smart_folders", owner: "ICVirtualSmartFolderItemIdentifier", selector: "query", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "smart_folders", owner: "ICTagSelection", selector: "smartFolderTitle", kind: .instanceMethod,
      required: false),

    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "isPasswordProtected", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "attributedString", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "noteAsPlainTextWithoutTitle", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "allNoteTextInlineAttachments", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "hasChecklist", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "hasChecklistInProgress", kind: .instanceMethod,
      required: false),
    CandidateDefinition(
      family: "body_structure", owner: "ICNote", selector: "isMathNote", kind: .instanceMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTTParagraphStyle", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "style", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "alignment", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "isChecklist", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "isList", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "isHeader", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "isBlockQuote", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "todo", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "uuid", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle", selector: "mutableCopy", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle",
      selector: "paragraphStyleAlignmentForTextAlignment:", kind: .classMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTParagraphStyle",
      selector: "textAlignmentForParagraphStyleAlignment:", kind: .classMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTTMutableParagraphStyle", selector: nil, kind: .classPresence),
    CandidateDefinition(family: "body_structure", owner: "ICTextStyle", selector: nil, kind: .classPresence),
    CandidateDefinition(family: "body_structure", owner: "ICTextStyle", selector: "ttStyle", kind: .instanceMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTextStyle", selector: "titleStyle", kind: .classMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTextStyle", selector: "headingStyle", kind: .classMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTextStyle", selector: "subheadingStyle", kind: .classMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTextStyle", selector: "bodyStyle", kind: .classMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTTTodo", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTTodo", selector: "done", kind: .instanceMethod),
    CandidateDefinition(
      family: "body_structure", owner: "ICTTTodo", selector: "todoWithDone:", kind: .instanceMethod),
    CandidateDefinition(family: "body_structure", owner: "ICTable", selector: nil, kind: .classPresence, required: false),
    CandidateDefinition(
      family: "body_structure", owner: "ICTableTextAttachment", selector: nil, kind: .classPresence,
      required: false),
    CandidateDefinition(
      family: "body_structure", owner: "ICCalculateResultTextAttachment", selector: nil, kind: .classPresence,
      required: false),
    CandidateDefinition(
      family: "body_structure", owner: "ICCalculateGraphExpressionTextAttachment", selector: nil,
      kind: .classPresence, required: false),

    CandidateDefinition(family: "body_table_mutation", owner: "ICTable", selector: nil, kind: .classPresence, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "setAttributedString:columnIndex:rowIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "stringForColumnIndex:rowIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "mergeableStringForColumnID:rowID:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "insertRows:atIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "insertColumns:atIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "removeRowAtIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "removeColumnAtIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "moveRowAtIndex:toIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "moveColumnAtIndex:toIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "identifierForRowAtIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "identifierForColumnAtIndex:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "undoablyRemoveContentsOfRow:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTable", selector: "undoablyRemoveContentsOfColumn:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTableTextAttachment", selector: nil, kind: .classPresence,
      required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTableTextAttachment",
      selector: "fixAttachmentForAttributedString:range:forPlainText:forStandardizedText:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTableColumnTextStorage", selector: nil, kind: .classPresence,
      required: false),
    CandidateDefinition(
      family: "body_table_mutation", owner: "ICTableColumnTextStorage",
      selector: "initWithTable:columnID:replicaID:", kind: .instanceMethod, required: false),

    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateDocumentController", selector: nil,
      kind: .classPresence, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateDocumentController", selector: "initWithNote:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateDocumentController",
      selector: "updateAffectingChangeCounts:", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateDocumentController",
      selector: "formatExpressionsInAttributedString:range:textStorageOffset:skipStaleExpressions:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateRecognitionController", selector: nil,
      kind: .classPresence, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateRecognitionController", selector: "initWithNote:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateRecognitionController", selector: "didInsertString:atRange:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateRecognitionController", selector: "insertResultAtRange:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateRecognitionController",
      selector: "commitPreviewedResultAtRange:asLiteral:", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateResultTextAttachment", selector: nil,
      kind: .classPresence, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateResultTextAttachment", selector: "expression",
      kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateResultTextAttachment",
      selector: "expressionRangeInTextStorage", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateResultTextAttachment",
      selector: "calculateDocumentController", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICCalculateGraphExpressionTextAttachment", selector: nil,
      kind: .classPresence, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICInlineAttachment",
      selector: "updateCalculateResult:isRightToLeft:", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "body_math_mutation", owner: "ICInlineAttachment",
      selector: "isCalculateResultAttachment", kind: .instanceMethod, required: false),

    CandidateDefinition(
      family: "archive_import_export", owner: "ICArchiveReader", selector: "initWithSourceURL:destinationURL:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICArchiveReader", selector: "unarchiveSourcePath:toDestinationPath:error:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICArchiveWriter", selector: "initWithDestinationURL:baseURL:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICArchiveWriter", selector: "open:", kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICArchiveWriter", selector: "writeURLs:error:", kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICArchiveWriter", selector: "finish:", kind: .instanceMethod),
    CandidateDefinition(family: "archive_import_export", owner: "ICMPrintController", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMPrintController", selector: "initWithNote:frame:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMPrintController", selector: "PDFRepresentation",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMarkdownRepresentation", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMarkdownRepresentation",
      selector: "createMarkdownStringFrom:context:rangeMapping:", kind: .classMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMarkdownRepresentation",
      selector: "attributedMarkdownStringFromPlainMarkdown:error:", kind: .classMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMarkdownRepresentation",
      selector: "attributedStringFromPossibleMarkdown:fallback:", kind: .classMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMarkdownString", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICMarkdownString",
      selector: "stringWithMarkdownStylesFromAttributedString:withContext:", kind: .classMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICNote", selector: "htmlStringWithAttachments:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICNote", selector: "htmlStringWithHTMLAttachments",
      kind: .instanceMethod, required: false),
    CandidateDefinition(family: "archive_import_export", owner: "ICShareNoteExporter", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICShareNoteExporter", selector: "fileWrapperForNote:",
      kind: .instanceMethod),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICShareNoteExporter", selector: "exportRTFDFileFromNote:",
      kind: .instanceMethod, required: false),
    CandidateDefinition(family: "archive_import_export", owner: "ICNotesImporterClient", selector: nil, kind: .classPresence),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICNotesImporterClient",
      selector: "archiveEvernoteNotesFromFileURL:completionBlock:", kind: .instanceMethod, required: false),
    CandidateDefinition(
      family: "archive_import_export", owner: "ICNotesImporterClient",
      selector: "countEvernoteNotesFromFileURL:completionBlock:", kind: .instanceMethod, required: false),
  ]
}

func notesRichCapabilityDoctorCheck() -> CLIDoctorCheck {
  let result = NotesRichCapabilityProbe().run()
  let availableCandidates = result.candidates
    .filter { $0.available }
    .map(\.label)
    .sorted()
  let missingCandidates = result.missingCandidates
    .map(\.label)
    .sorted()
  let missingRequiredCandidates = result.missingRequiredCandidates
    .map(\.label)
    .sorted()

  var details: [String: String] = [
    "mode": "probe_only",
    "write_access": "none",
    "accepted_capability":
      "body_structure,body_collapsible_list,body_collapsible_set,body_collapsible_create_update,body_paragraph_style,body_paragraph_align,body_paragraph_quote,body_inline_format,body_inline_color,body_inline_highlight,body_inline_font,body_checklist_add,body_checklist_set,body_checklist_set_all,body_checklist_sort,body_checklist_convert,body_checklist_convert_range,body_checklist_reorder,body_checklist_indent,body_checklist_delete,body_list_add,body_list_convert,body_list_convert_range,body_list_set_style,body_list_reorder,body_list_indent,body_list_delete,body_table_list,body_table_create,body_table_import,body_table_update,body_table_delete,body_table_convert_to_text,body_table_convert_from_text,body_table_copy,body_table_move,body_table_structure_edit,body_math_list,body_math_insert,body_math_update",
    "gated_future_capability": "none",
    "families": result.families.joined(separator: ","),
    "family_count": "\(result.families.count)",
    "candidate_count": "\(result.candidates.count)",
    "deferred_model_accessors": result.deferredCandidates.map(\.label).sorted().joined(separator: ","),
    "required_candidate_count": "\(result.candidates.filter { $0.required }.count)",
    "available_candidate_count": "\(availableCandidates.count)",
    "missing_candidate_count": "\(missingCandidates.count)",
    "available_candidates": availableCandidates.joined(separator: ","),
    "missing_candidates": missingCandidates.joined(separator: ","),
    "missing_required_candidates": missingRequiredCandidates.joined(separator: ","),
    "candidate_backlink_path": "ICInlineAttachment.enumerateLinksToNote:batchSize:visibleOnly:saveAfterBatch:context:usingBlock:",
    "candidate_markdown_export_path":
      "ICMarkdownRepresentation.createMarkdownStringFrom:context:rangeMapping: + ICMarkdownString.stringWithMarkdownStylesFromAttributedString:withContext:",
    "candidate_table_create_path": "ICNote.addTableAttachmentWithText:",
    "candidate_table_delete_path": "ICNote.removeInlineAttachmentsObject: + ICTableTextAttachment",
    "candidate_table_mutation_path":
      "ICTable + ICTableTextAttachment + ICTable.setAttributedString:columnIndex:rowIndex:",
    "candidate_table_copy_path": "ICTable.stringForColumnIndex:rowIndex: + ICNote.addTableAttachmentWithText:",
    "candidate_table_move_path": "ICNote.textStorage attributed table attachment run reorder",
      "candidate_table_structure_path": "ICTable.insertRows:atIndex: + ICTable.insertColumns:atIndex: + ICTable.removeRowAtIndex: + ICTable.removeColumnAtIndex: + ICTable.moveRowAtIndex:toIndex: + ICTable.moveColumnAtIndex:toIndex:",
      "candidate_table_clear_path": "ICTable.identifierForRowAtIndex: + ICTable.identifierForColumnAtIndex: + ICTable.undoablyRemoveContentsOfRow: + ICTable.undoablyRemoveContentsOfColumn:",
      "candidate_table_convert_to_text_path":
        "ICTable.stringForColumnIndex:rowIndex: + ICNote.textStorage.replaceCharacters(in:with:)",
      "candidate_table_convert_from_text_path":
        "ICNote.addTableAttachmentWithText: + ICNote.textStorage paragraph replacement",
      "candidate_math_update_path": "ICInlineAttachment.updateCalculateResult:isRightToLeft:",
    "candidate_math_insert_path": "ICCalculateRecognitionController.insertResultAtRange:",
  ]

  for family in result.families {
    let candidates = result.candidates.filter { $0.family == family }
    details["family_\(family)_candidate_count"] = "\(candidates.count)"
    details["family_\(family)_available_count"] = "\(candidates.filter { $0.available }.count)"
    details["family_\(family)_missing_required"] = candidates
      .filter { $0.required && !$0.available && !$0.deferred }
      .map(\.label)
      .sorted()
      .joined(separator: ",")
  }

  return CLIDoctorCheck(
    name: "notes_rich_capability",
    status: result.isReady ? .ok : .warning,
    message: result.isReady
      ? "Notes private rich capability candidates are present; no rich write was executed."
      : result.missingRequiredCandidates.isEmpty
        ? "Notes rich candidates include deferred Core Data accessors; operation-context verification is required."
        : "Notes private rich capability candidates are incomplete; required API readiness is not established.",
    details: details
  )
}
