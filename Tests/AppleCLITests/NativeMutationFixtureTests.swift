import Foundation
import NotesCLI
import ReminderKit
@testable import RemindersCLI
import Testing
import Utility

@Suite(.serialized)
struct NativeMutationFixtureTests {
  @Test(.enabled(
    if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_NOTES_MUTATION_TESTS"] == "1",
    "Requires a configured, dedicated Notes fixture folder and explicit mutation opt-in."
  ))
  func notesSaveFormatAndColdReadback() throws {
    let run = try NativeFixtureRun(target: "notes", operation: "format")
    try run.requireEmptyContainer()
    let body = "  literal 👩🏽‍💻 e\u{301} [] \\ quote\"\nUnchanged second paragraph.\n\n"
    try run.withCleanup { run in
      let created = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "create", "--folder", run.scope.containerID,
          "--title", run.ledger.intentTitle, "--body", body], key: "note")
      try run.register(id: created.id, title: created.title, containerID: run.scope.containerID)
      try run.evidence.record("created", value: created)
      let before = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("before", value: before)
      try #require(before.title == run.ledger.intentTitle)
      try #require(before.body == body)
      for format in ["bold", "strikethrough"] {
        try run.requireOwnedObject(created.id)
        _ = try run.command("format-" + format, ["notes", "body", "inline", "format", "--id", created.id,
          "--ordinal", "2", "--text", "literal 👩🏽‍💻 e\u{301}", "--format", format, "--state", "on"])
      }
      try run.requireOwnedObject(created.id)
      let repeatedBold = try run.command("repeat-bold", ["notes", "body", "inline", "format", "--id", created.id,
        "--ordinal", "2", "--text", "literal 👩🏽‍💻 e\u{301}", "--format", "bold", "--state", "on"])
      try #require(repeatedBold["changed"] as? Bool == false)
      let after = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("after", value: after)
      var preserved = after
      preserved.updatedAt = before.updatedAt
      try #require(preserved == before)
      let structure = try run.cli.decode(NotesBodyStructureRecord.self,
        arguments: ["notes", "body", "structure", "--id", created.id], key: "structure")
      try run.evidence.record("structure", value: structure)
      let bold = try #require(structure.boldRunCount)
      let strikethrough = try #require(structure.strikethroughRunCount)
      try #require(bold > 0)
      try #require(strikethrough > 0)
      let output = run.ledgerURL.deletingLastPathComponent().appendingPathComponent("native.html")
      try run.requireOwnedObject(created.id)
      _ = try run.command("export-html", ["notes", "export", "html", "--id", created.id, "--output", output.path,
        "--allow-artifact-action"])
      let html = try String(contentsOf: output, encoding: .utf8)
      try #require(html.range(of: "<s(?:\\s|>)|<del(?:\\s|>)|<strike(?:\\s|>)|text-decoration[^;\"}]*line-through",
        options: [.regularExpression, .caseInsensitive]) != nil)
      let bodyEvidence = try NativeNotesBodyEvidence.capture(structure, note: after)
      try run.evidence.record("body-styles-before-rename", value: bodyEvidence)

      let newTitle = run.manifest.marker + " / renamed 👩🏽‍💻 e\u{301}"
      try run.requireOwnedObject(created.id)
      try run.ledger.beginRename(id: created.id, title: newTitle)
      try run.ledger.persist(to: run.ledgerURL)
      _ = try run.command("rename", ["notes", "update", "--id", created.id, "--title", newTitle])
      let renamed = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("renamed", value: renamed)
      try #require(renamed.title == newTitle)
      try run.ledger.completeRename(id: created.id, title: renamed.title)
      try run.ledger.persist(to: run.ledgerURL)
      preserved = renamed
      preserved.title = before.title
      preserved.updatedAt = before.updatedAt
      try #require(preserved == before)
      let renamedStructure = try run.cli.decode(NotesBodyStructureRecord.self,
        arguments: ["notes", "body", "structure", "--id", created.id], key: "structure")
      try run.evidence.record("renamed-structure", value: renamedStructure)
      let renamedBodyEvidence = try NativeNotesBodyEvidence.capture(renamedStructure, note: renamed)
      try run.evidence.record("body-styles-after-rename", value: renamedBodyEvidence)
      try #require(renamedBodyEvidence == bodyEvidence)
      let nativeAnchors = try #require(structure.paragraphAnchors)
      let renamedAnchors = try #require(renamedStructure.paragraphAnchors)
      try #require(renamedAnchors.map(\.idSHA256) == nativeAnchors.map(\.idSHA256))
      try #require(structure.headingCount == 1)
      try #require(renamedStructure.headingCount == 1)
      let styles = try #require(structure.styleCounts)
      let renamedStyles = try #require(renamedStructure.styleCounts)
      try #require(renamedStyles == styles)
      try run.requireOwnedObject(created.id)
      let repeatedRename = try run.command("repeat-rename", ["notes", "update", "--id", created.id, "--title", newTitle])
      try #require(repeatedRename["changed"] as? Bool == false)
      let repeated = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("repeat-rename-readback", value: repeated)
      try #require(repeated == renamed)
      let renamedOutput = run.ledgerURL.deletingLastPathComponent().appendingPathComponent("renamed.html")
      _ = try run.command("renamed-export-html", ["notes", "export", "html", "--id", created.id,
        "--output", renamedOutput.path, "--allow-artifact-action"])
      let renamedHTML = try String(contentsOf: renamedOutput, encoding: .utf8)
      try #require(renamedHTML.range(of: "<s(?:\\s|>)|<del(?:\\s|>)|<strike(?:\\s|>)|text-decoration[^;\"}]*line-through",
        options: [.regularExpression, .caseInsensitive]) != nil)

      let replacement = "  Replaced 😀\n\nSecond e\u{301}.\n\n"
      try run.requireOwnedObject(created.id)
      _ = try run.command("replace-body", ["notes", "update", "--id", created.id, "--body", replacement])
      let replaced = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("replaced-body", value: replaced)
      try #require(replaced.body?.utf8.elementsEqual(replacement.utf8) == true)
      preserved = replaced
      preserved.body = renamed.body
      preserved.updatedAt = renamed.updatedAt
      try #require(preserved == renamed)
      let replacementStructure = try run.cli.decode(NotesBodyStructureRecord.self,
        arguments: ["notes", "body", "structure", "--id", created.id], key: "structure")
      try run.evidence.record("replacement-structure", value: replacementStructure)
      try #require(replacementStructure.headingCount == 1)
      let replacementAnchors = try #require(replacementStructure.paragraphAnchors)
      try #require(replacementAnchors.map(\.idSHA256) == nativeAnchors.map(\.idSHA256))
      let replacementEvidence = try NativeNotesBodyEvidence.capture(replacementStructure, note: replaced)
      try run.evidence.record("replacement-body-styles", value: replacementEvidence)
      for record in replacementEvidence.inlineFormats {
        let object = try #require(JSONSerialization.jsonObject(with: Data(record.utf8)) as? [String: Any])
        try #require(object["format"] as? String != "bold")
        try #require(object["format"] as? String != "strikethrough")
      }

      try run.requireOwnedObject(created.id)
      _ = try run.command("clear-body", ["notes", "update", "--id", created.id, "--body", ""])
      let cleared = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("cleared-body", value: cleared)
      try #require(cleared.body == "")
      preserved = cleared
      preserved.body = replaced.body
      preserved.updatedAt = replaced.updatedAt
      try #require(preserved == replaced)

      let combinedTitle = run.manifest.marker + " / combined 😀"
      try run.requireOwnedObject(created.id)
      try run.ledger.beginRename(id: created.id, title: combinedTitle)
      try run.ledger.persist(to: run.ledgerURL)
      _ = try run.command("replace-title-body", ["notes", "update", "--id", created.id,
        "--title", combinedTitle, "--body", replacement])
      let combined = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("combined-title-body", value: combined)
      try #require(combined.title == combinedTitle)
      try #require(combined.body?.utf8.elementsEqual(replacement.utf8) == true)
      try run.ledger.completeRename(id: created.id, title: combined.title)
      try run.ledger.persist(to: run.ledgerURL)
      preserved = combined
      preserved.title = cleared.title
      preserved.body = cleared.body
      preserved.updatedAt = cleared.updatedAt
      try #require(preserved == cleared)
      let combinedStructure = try run.cli.decode(NotesBodyStructureRecord.self,
        arguments: ["notes", "body", "structure", "--id", created.id], key: "structure")
      try run.evidence.record("combined-structure", value: combinedStructure)
      try #require(combinedStructure.headingCount == 1)
      let combinedAnchors = try #require(combinedStructure.paragraphAnchors)
      try #require(combinedAnchors.map(\.idSHA256) == nativeAnchors.map(\.idSHA256))
      try run.requireOwnedObject(created.id)
      let repeatedCombinedTitle = try run.command("repeat-combined-title", ["notes", "update", "--id", created.id,
        "--title", combinedTitle])
      try #require(repeatedCombinedTitle["changed"] as? Bool == false)
      let afterRepeatedCombinedTitle = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try #require(afterRepeatedCombinedTitle == combined)
      let subsequentBody = "\n  Subsequent 😀 e\u{301}\n\n"
      _ = try run.command("replace-after-combined", ["notes", "update", "--id", created.id, "--body", subsequentBody])
      let subsequent = try run.cli.decode(NotesNoteDetail.self,
        arguments: ["notes", "read", "--id", created.id], key: "note")
      try run.evidence.record("subsequent-body", value: subsequent)
      try #require(subsequent.body?.utf8.elementsEqual(subsequentBody.utf8) == true)
      preserved = subsequent
      preserved.body = combined.body
      preserved.updatedAt = combined.updatedAt
      try #require(preserved == combined)
    }
  }

  @Test(.enabled(
    if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_REMINDERS_MUTATION_TESTS"] == "1",
    "Requires a configured, dedicated Reminders fixture list and explicit mutation opt-in."
  ))
  func remindersCompletionHistoryAndColdReadback() throws {
    let run = try NativeFixtureRun(target: "reminders", operation: "completion")
    try run.requireEmptyContainer()
    try run.withCleanup { run in
      let created = try run.cli.decode(ReminderDetail.self,
        arguments: ["reminders", "create", "--list", run.scope.containerID,
          "--title", run.ledger.intentTitle, "--notes", "Unchanged 👩🏽‍💻 e\u{301}", "--priority", "5"], key: "reminder")
      try run.register(id: created.id, title: created.title, containerID: created.listId)
      try run.evidence.record("created", value: created)
      let before = try run.readReminder(created.id)
      try run.evidence.record("before", value: before)
      try run.requireOwnedObject(created.id)
      _ = try run.command("complete", ["reminders", "complete", "--id", created.id,
        "--completed-at", "2021-01-02T03:04:05Z"])
      let completed = try run.readReminder(created.id)
      try run.evidence.record("completed", value: completed)
      try #require(completed.isCompleted)
      try #require(completed.completedAt == "2021-01-02T03:04:05Z")
      var preserved = completed
      preserved.isCompleted = before.isCompleted
      preserved.completedAt = before.completedAt
      preserved.modifiedAt = before.modifiedAt
      try #require(preserved == before)
      try run.requireOwnedObject(created.id)
      let repeated = try run.command("repeat-complete", ["reminders", "complete", "--id", created.id])
      try #require(repeated["changed"] as? Bool == false)
      let retried = try run.readReminder(created.id)
      try run.evidence.record("retried", value: retried)
      try #require(retried == completed)
      try run.requireOwnedObject(created.id)
      _ = try run.command("correct-completion", ["reminders", "complete", "--id", created.id,
        "--completed-at", "2022-02-03T04:05:06Z"])
      let corrected = try run.readReminder(created.id)
      try run.evidence.record("after", value: corrected)
      try #require(corrected.completedAt == "2022-02-03T04:05:06Z")
      preserved = corrected
      preserved.completedAt = completed.completedAt
      preserved.modifiedAt = completed.modifiedAt
      try #require(preserved == completed)
    }
  }
}

private final class NativeFixtureRun {
  let manifest: NativeFixtureManifest
  let target: String
  let scope: NativeFixtureManifest.Scope
  let cli: NativeFixtureCLI
  let ledgerURL: URL
  let evidence: NativeFixtureEvidence
  var ledger: NativeFixtureLedger

  init(target: String, operation: String) throws {
    manifest = try NativeFixtureManifest.load(environment: ProcessInfo.processInfo.environment,
      target: target, host: nativeFixtureCurrentHost())
    self.target = target
    scope = try manifest.scope(target)
    ledgerURL = try nativeFixtureLedgerURL(manifest: manifest, target: target)
    evidence = NativeFixtureEvidence(runID: manifest.runID, target: target,
      directory: ledgerURL.deletingLastPathComponent())
    cli = nativeFixturePackageCLI().recording(to: evidence)
    ledger = NativeFixtureLedger(runID: manifest.runID, target: target, containerID: scope.containerID,
      marker: manifest.marker, intentTitle: manifest.marker + " / " + operation)
    try ledger.persist(to: ledgerURL)
    try evidence.record("manifest", value: manifest)
  }

  func requireContainer() throws {
    let app = target == "notes" ? "Notes" : "Reminders"
    guard let bundle = Bundle(path: "/System/Applications/\(app).app"),
      bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String == scope.appVersion,
      bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String == scope.appBuild
    else { throw NativeFixtureManifest.refused("fixture_app_version_mismatch") }
    if target == "notes" {
      let folders = try cli.decode([NotesFolderRecord].self,
        arguments: ["notes", "folders", "list", "--account", scope.accountID, "--limit", "500"], key: "folders")
      guard let folder = folders.first(where: { $0.id == scope.containerID }), folder.name == manifest.marker,
        folder.supportsEditingNotes == true, folder.isSharedViaICloud == false,
        folder.isSharedReadOnly == false, folder.isDefault == false, folder.isTrash == false,
        folder.isSystemFolder == false, folder.isSmartFolder == false, folder.childFolderCount == 0
      else { throw NativeFixtureManifest.refused("notes_container_not_dedicated") }
    } else {
      let lists = try cli.decode([ReminderListRecord].self,
        arguments: ["reminders", "lists", "list"], key: "lists")
      guard let list = lists.first(where: { $0.id == scope.containerID }), list.title == manifest.marker,
        list.sourceId == scope.accountID, list.allowsContentModifications,
        list.listType == "standard"
      else { throw NativeFixtureManifest.refused("reminders_container_not_dedicated") }
      let store = try coreReminderKitStore(operation: "test.fixture-scope")
      let native = try coreResolveList(store: store, selector: scope.containerID, operation: "test.fixture-scope")
      for selector in ["isShared", "isSharedToMe"] {
        try ReminderKitRuntimeMethod(owner: "REMList", selector: selector, returnType: "B")
          .require(operation: "test.fixture-scope", receiver: native)
      }
      guard !native.isShared, !native.isSharedToMe else {
        throw NativeFixtureManifest.refused("reminders_shared_container")
      }
    }
  }

  func containerObjects() throws -> [(id: String, title: String)] {
    try requireContainer()
    if target == "notes" {
      let items = try cli.decode([NotesNoteSummary].self,
        arguments: ["notes", "list", "--account", scope.accountID,
          "--folder", scope.containerID, "--limit", "9"], key: "notes")
      return items.map { ($0.id, $0.title) }
    }
    let items = try cli.decode([ReminderSummary].self,
      arguments: ["reminders", "list", "--list", scope.containerID, "--status", "all", "--limit", "9"], key: "reminders")
    return items.map { ($0.id, $0.title) }
  }

  func requireEmptyContainer() throws {
    do {
      let items = try containerObjects()
      try evidence.record("container-before", value: items.map { ["id": $0.id, "title": $0.title] })
      guard items.isEmpty else { throw NativeFixtureManifest.refused("fixture_container_not_empty") }
    } catch {
      ledger.recordOperationFailure(error)
      try ledger.persist(to: ledgerURL)
      throw error
    }
  }

  func command(_ phase: String, _ arguments: [String]) throws -> [String: Any] {
    let data = try cli.data(arguments)
    try evidence.recordJSON(phase, value: ["arguments": arguments, "data": data])
    return data
  }

  func register(id: String, title: String, containerID: String) throws {
    try ledger.register(id: id, title: title, containerID: containerID)
    try ledger.persist(to: ledgerURL)
    try requireOwnedObject(id)
  }

  func readReminder(_ id: String) throws -> ReminderDetail {
    try cli.decode(ReminderDetail.self, arguments: ["reminders", "read", "--id", id], key: "reminder")
  }

  @discardableResult func requireOwnedObject(_ id: String) throws -> NativeFixtureLedger.Object {
    let items = try containerObjects()
    guard let item = items.first(where: { $0.id == id }) else {
      throw NativeFixtureManifest.refused("fixture_object_not_in_container")
    }
    try ledger.requireOwned(id: id, title: item.title, containerID: scope.containerID)
    for item in items {
      try ledger.requireOwned(id: item.id, title: item.title, containerID: scope.containerID)
    }
    return NativeFixtureLedger.Object(id: item.id, title: item.title, containerID: scope.containerID)
  }

  func purgeOwnedTrashedNote(_ item: NativeFixtureLedger.Object, index: Int) throws {
    try NativeNoteFixtureCleanup.purge(item, ledger: ledger, cli: cli) { arguments, data in
      try evidence.recordJSON("cleanup-purge-\(index)", value: ["arguments": arguments, "data": data])
    }
  }

  func withCleanup(_ operation: (NativeFixtureRun) throws -> Void) throws {
    var operationError: (any Error)?
    ledger.status = "running"
    try ledger.persist(to: ledgerURL)
    do { try operation(self) } catch {
      operationError = error
      ledger.recordOperationFailure(error)
    }
    do {
      if ledger.objects.isEmpty {
        let candidates = try containerObjects().filter { $0.title == ledger.intentTitle }
        guard candidates.count <= 1 else { throw NativeFixtureManifest.refused("creation_identity_ambiguous") }
        for item in candidates { try register(id: item.id, title: item.title, containerID: scope.containerID) }
      }
      for (index, item) in ledger.objects.enumerated() where !item.cleaned {
        let current = try requireOwnedObject(item.id)
        _ = try command("cleanup-delete-\(index + 1)", [target, "delete", "--id", item.id])
        guard try !containerObjects().contains(where: { $0.id == item.id }) else {
          throw NativeFixtureManifest.refused("cleanup_readback_failed")
        }
        if target == "notes" {
          try purgeOwnedTrashedNote(current, index: index + 1)
        } else {
          guard try cli.dataOrNotFound([target, "read", "--id", item.id]) == nil else {
            throw NativeFixtureManifest.refused("deleted_reminder_readback_failed")
          }
        }
        try ledger.markCleaned(item.id)
        try ledger.persist(to: ledgerURL)
      }
      try evidence.record("container-after", value: try containerObjects().map { ["id": $0.id, "title": $0.title] })
      ledger.status = operationError == nil ? "completed" : "operation_failed"
      try ledger.persist(to: ledgerURL)
    } catch {
      ledger.recordCleanupFailure(error)
      try ledger.persist(to: ledgerURL)
      throw error
    }
    if let operationError { throw operationError }
  }
}

struct NativeNoteFixtureCleanup {
  static func purge(_ item: NativeFixtureLedger.Object, ledger: NativeFixtureLedger,
    cli: NativeFixtureCLI, record: ([String], [String: Any]) throws -> Void = { _, _ in }) throws {
    try ledger.requireOwned(id: item.id, title: item.title, containerID: item.containerID)
    let search = ["notes", "search", "--id", item.id, "--query", item.title,
      "--include-recently-deleted", "--limit", "9"]
    let data = try cli.data(search)
    guard let notes = data["notes"] as? [[String: Any]], notes.count == 1,
      notes[0]["id"] as? String == item.id, notes[0]["title"] as? String == item.title
    else { throw NativeFixtureManifest.refused("trashed_note_identity_unverified") }
    let arguments = ["notes", "purge", "--id", item.id, "--allow-destructive-selection"]
    let result = try cli.data(arguments)
    try record(arguments, result)
    if let after = try cli.dataOrNotFound(search) {
      guard let remaining = after["notes"] as? [[String: Any]], remaining.isEmpty else {
        throw NativeFixtureManifest.refused("purge_readback_failed")
      }
    }
  }
}
