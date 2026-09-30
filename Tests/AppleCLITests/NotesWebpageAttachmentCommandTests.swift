import Foundation
import NotesCLI
import Testing
import Utility

@Suite
struct NotesWebpageAttachmentCommandTests {
  @Test func dryRunAndExecutionVerifyPreviewFamily() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let urlString = "https://example.com/brief"

    let dryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments",
      "add-webpage",
      "--id",
      "note-2",
      "--url",
      urlString,
      "--dry-run",
      "--json",
    ])))
    let dryRunObject = try notesWebpageAttachmentJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let requirements = dryRunData?["requirements"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "notes.attachments.add-webpage")
    #expect(requirements?["allowFlags"] as? [String] == [])
    #expect(summary?["id"] as? String == "note-2")
    #expect(summary?["url"] as? String == urlString)
    #expect(summary?["url_sha256"] != nil)
    #expect(summary?["scheme"] as? String == "https")
    #expect(summary?["host"] as? String == "example.com")
    #expect(summary?["attachment_family"] as? String == "webpage_preview")
    #expect(implementation.webpageAttachmentAddDrafts.isEmpty)

    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments",
      "add-webpage",
      "--id",
      "note-2",
      "--url",
      urlString,
      "--json",
    ])))
    let executedObject = try notesWebpageAttachmentJSONObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let preview = executedData?["webpagePreview"] as? [String: Any]
    let verification = executedData?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]]

    #expect(executedData?["operation"] as? String == "notes.attachments.add-webpage")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["noteID"] as? String == "note-2")
    #expect(executedData?["attachmentFamily"] as? String == "webpage_preview")
    #expect(preview?["kind"] as? String == "url")
    #expect(preview?["urlString"] as? String == urlString)
    #expect(preview?["urlScheme"] as? String == "https")
    #expect(verification?["operation"] as? String == "notes.attachments.add-webpage")
    #expect(verification?["verified"] as? Bool == true)
    #expect(
      checks?.contains {
        $0["name"] as? String == "link_metadata_readback"
          && $0["actualBool"] as? Bool == true
      } == true)
    #expect(
      checks?.contains {
        $0["name"] as? String == "attachment_metadata_readback"
          && $0["actualBool"] as? Bool == true
      } == true)
    #expect(
      checks?.contains {
        $0["name"] as? String == "attachment_family"
          && $0["actualBool"] as? Bool == true
      } == true)
    #expect(implementation.webpageAttachmentAddDrafts.map(\.urlString) == [urlString])

    let updatedURLString = "https://example.com/brief-updated"
    let updateDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments",
      "update-webpage",
      "--id",
      "note-2",
      "--attachment",
      "webpage-added-1",
      "--url",
      updatedURLString,
      "--dry-run",
      "--json",
    ])))
    let updateDryRunObject = try notesWebpageAttachmentJSONObject(updateDryRun.stdout ?? "")
    let updateDryRunData = updateDryRunObject["data"] as? [String: Any]
    let updateRequirements = updateDryRunData?["requirements"] as? [String: Any]
    let updateSummary = updateDryRunData?["normalizedArguments"] as? [String: Any]

    #expect(updateDryRunData?["operation"] as? String == "notes.attachments.update-webpage")
    #expect(updateRequirements?["allowFlags"] as? [String] == [])
    #expect(updateSummary?["id"] as? String == "note-2")
    #expect(updateSummary?["attachment"] as? String == "webpage-added-1")
    #expect(updateSummary?["requested_attachment"] as? String == "webpage-added-1")
    #expect(updateSummary?["url"] as? String == updatedURLString)
    #expect(updateSummary?["attachment_family"] as? String == "webpage_preview")
    #expect(implementation.webpageAttachmentUpdateDrafts.isEmpty)

    let updateExecuted = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments",
      "update-webpage",
      "--id",
      "note-2",
      "--attachment",
      "webpage-added-1",
      "--url",
      updatedURLString,
      "--json",
    ])))
    let updateExecutedObject = try notesWebpageAttachmentJSONObject(updateExecuted.stdout ?? "")
    let updateExecutedData = updateExecutedObject["data"] as? [String: Any]
    let oldPreview = updateExecutedData?["oldWebpagePreview"] as? [String: Any]
    let updatedPreview = updateExecutedData?["webpagePreview"] as? [String: Any]
    let updateVerification = updateExecutedData?["verification"] as? [String: Any]
    let updateChecks = updateVerification?["checks"] as? [[String: Any]]

    #expect(updateExecutedData?["operation"] as? String == "notes.attachments.update-webpage")
    #expect(updateExecutedData?["changed"] as? Bool == true)
    #expect(updateExecutedData?["noteID"] as? String == "note-2")
    #expect(updateExecutedData?["attachmentFamily"] as? String == "webpage_preview")
    #expect(oldPreview?["urlString"] as? String == urlString)
    #expect(updatedPreview?["urlString"] as? String == updatedURLString)
    #expect(updateVerification?["operation"] as? String == "notes.attachments.update-webpage")
    #expect(updateVerification?["verified"] as? Bool == true)
    #expect(
      updateChecks?.contains {
        $0["name"] as? String == "old_url_replaced"
          && $0["actualBool"] as? Bool == true
      } == true)
    #expect(
      updateChecks?.contains {
        $0["name"] as? String == "attachment_metadata_readback"
          && $0["actualBool"] as? Bool == true
      } == true)
    #expect(
      updateChecks?.contains {
        $0["name"] as? String == "attachment_family"
          && $0["actualBool"] as? Bool == true
      } == true)
    #expect(implementation.webpageAttachmentUpdateDrafts.map(\.urlString) == [updatedURLString])
    #expect(implementation.linkUpdateDrafts.isEmpty)

    let mapURLString = "https://maps.apple.com/?q=Apple%20Park"
    let mapExecuted = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "attachments",
      "add-webpage",
      "--id",
      "note-2",
      "--url",
      mapURLString,
      "--json",
    ])))
    let mapExecutedObject = try notesWebpageAttachmentJSONObject(mapExecuted.stdout ?? "")
    let mapExecutedData = mapExecutedObject["data"] as? [String: Any]
    #expect(mapExecutedData?["attachmentFamily"] as? String == "map_preview")
  }

  @Test func rejectsNonWebURL() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments",
      "add-webpage",
      "--id",
      "note-2",
      "--url",
      "file:///Users/example/private.html",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected non-web webpage attachment URL to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(implementation.webpageAttachmentAddDrafts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func rejectsNonWebpageAttachmentUpdateTarget() throws {
    let implementation = TestNotesImplementation()
    _ = try implementation.addAttachment(
      NotesAttachmentAddDraft(
        noteID: "note-2",
        filename: "Ordinary.txt",
        sourcePath: "/tmp/Ordinary.txt",
        data: Data("ordinary attachment".utf8)
      )
    )
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "attachments",
      "update-webpage",
      "--id",
      "note-2",
      "--attachment",
      "attachment-added-1",
      "--url",
      "https://example.com/not-a-preview",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected non-webpage attachment update target to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("webpage preview"))
      #expect(implementation.webpageAttachmentUpdateDrafts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private func notesWebpageAttachmentJSONObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    Issue.record("Expected JSON object.")
    return [:]
  }
  return object
}
