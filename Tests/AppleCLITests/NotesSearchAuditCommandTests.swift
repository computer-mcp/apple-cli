import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes search audit command")
struct NotesSearchAuditCommandTests {
  @Test func searchAuditAccountsForOfficialSearchFamiliesWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "audit", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let summary = try #require(data["summary"] as? [String: Any])
    let records = try #require(data["records"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = verification["checks"] as? [[String: Any]] ?? []
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let byFamily = Dictionary(
      uniqueKeysWithValues: records.compactMap { record -> (String, [String: Any])? in
        guard let family = record["searchFamily"] as? String else {
          return nil
        }
        return (family, record)
      })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.search.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 17)
    #expect(summary["supportedRecordCount"] as? Int == 7)
    #expect(summary["delegatedRecordCount"] as? Int == 10)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresQuery"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["visible_text"]?["status"] as? String == "supported")
    #expect(byFamily["account_scoped_text"]?["status"] as? String == "supported")
    #expect(byFamily["single_note_text"]?["status"] as? String == "supported")
    #expect(byFamily["attachment_name"]?["status"] as? String == "delegated")
    #expect(byFamily["pdf_content"]?["status"] as? String == "delegated")
    #expect(byFamily["audio_transcript"]?["status"] as? String == "delegated")
    #expect(byFamily["siri_search"]?["status"] as? String == "delegated")
    #expect(byFamily["spotlight_search"]?["status"] as? String == "delegated")
    #expect(byFamily["natural_language"]?["status"] as? String == "supported")
    #expect(byFamily["scanned_document_ocr"]?["status"] as? String == "delegated")
    #expect(byFamily["image_content"]?["status"] as? String == "delegated")
    #expect(byFamily["drawing_content"]?["status"] as? String == "delegated")
    #expect(byFamily["handwriting"]?["status"] as? String == "delegated")
    #expect(byFamily["attachment_content"]?["status"] as? String == "supported")
    #expect(byFamily["recently_deleted_search"]?["status"] as? String == "supported")
    #expect(byFamily["locked_note_title_only"]?["status"] as? String == "supported")
    #expect(byFamily["natural_language"]?["command"] as? String == "notes search natural-language --query QUERY")
    #expect(
      byFamily["attachment_content"]?["command"] as? String
        == "notes search attachment-content --query QUERY [--folder FOLDER|--id NOTE_ID] [--family FAMILY]"
    )
    #expect(byFamily["locked_note_title_only"]?["command"] as? String == "notes search locked-title --query QUERY")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("text_search_surfaces_supported"))
    #expect(checkNames.contains("delegated_semantic_searches_accounted"))
    #expect(checkNames.contains("delegated_system_searches_accounted"))
    #expect(checkNames.contains("visual_searchable_text_searches_delegated"))
    #expect(checkNames.contains("natural_language_search_supported"))
    #expect(checkNames.contains("composite_attachment_content_search_supported"))
    #expect(checkNames.contains("recently_deleted_search_supported"))
    #expect(checkNames.contains("locked_note_title_search_supported"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Launch") == false)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.accountListQueries.isEmpty)
    #expect(implementation.createdDrafts.isEmpty)
    #expect(implementation.updatedPatches.isEmpty)
  }

  @Test func searchAuditRejectsQueryInputAndDoesNotSearch() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "notes", "search", "audit", "--query", "Launch", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected search audit to reject query input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["options"] == "--query")
      #expect(error.details.values.contains("Launch") == false)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
      #expect(implementation.createdDrafts.isEmpty)
    }
  }

  @Test func searchNaturalLanguageRunsPrivateSearchSurfaceWithoutRawQueryLeakage() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let query = "Find invoices from June"
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "natural-language", "--query", query, "--folder", "Work", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let notes = data["notes"] as? [[String: Any]] ?? []
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = verification["checks"] as? [[String: Any]] ?? []

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.search.natural-language")
    #expect(data["changed"] as? Bool == false)
    #expect(data["querySHA256"] as? String == sha256Hex(query))
    #expect(data["queryByteCount"] as? Int == Data(query.utf8).count)
    #expect(data["privateNLQueryPresent"] as? Bool == true)
    #expect(data["privateNLQueryClassName"] as? String == "ICSearchResultsQuery")
    #expect(verification["verified"] as? Bool == true)
    #expect(
      checks.contains {
        $0["name"] as? String == "private_nl_query_created"
          && $0["actualBool"] as? Bool == true
      })
    #expect((result.stdout ?? "").contains(query) == false)
    #expect(notes.allSatisfy { $0["body"] == nil })
    #expect(implementation.naturalLanguageSearchQueries == ["Find invoices from June||Work|50"])
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
    #expect(implementation.accountListQueries.isEmpty)
  }

  @Test func attachmentContentSearchUsesCompositePrivateSlicesWithoutRawContentLeakage() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let query = "remodel"

    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "attachment-content", "--account", "iCloud", "--query", query, "--limit", "10",
      "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let matches = try #require(data["matches"] as? [[String: Any]])
    let slices = Set(matches.compactMap { $0["slice"] as? String })
    let componentSummaries = try #require(data["componentSummaries"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let stdout = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.search.attachment-content")
    #expect(data["changed"] as? Bool == false)
    #expect(data["account"] as? String == "iCloud")
    #expect(data["querySHA256"] as? String == sha256Hex(query))
    #expect((data["searchedSlices"] as? [String]) == ["metadata", "pdf_text", "audio_transcript", "searchable_text"])
    #expect(componentSummaries.count == 4)
    #expect(slices.contains("pdf_text"))
    #expect(data["matchedAttachmentCount"] as? Int == 1)
    #expect(verification["verified"] as? Bool == true)
    #expect(
      checks.contains {
        $0["name"] as? String == "privacy_hash_accounting"
          && $0["actualBool"] as? Bool == true
      })
    #expect(stdout.contains(query) == false)
    #expect(stdout.contains("Private PDF remodel plan") == false)
    #expect(stdout.contains("Ada: Ship") == false)
    #expect(stdout.contains("Transcript readback") == false)

    let audioQuery = "generation gated"
    let audioResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "attachment-content", "--account", "iCloud", "--query", audioQuery, "--limit", "10",
      "--json",
    ])))
    let audioObject = try jsonObject(audioResult.stdout ?? "")
    let audioData = try #require(audioObject["data"] as? [String: Any])
    let audioMatches = try #require(audioData["matches"] as? [[String: Any]])
    let audioSlices = Set(audioMatches.compactMap { $0["slice"] as? String })

    #expect(audioObject["ok"] as? Bool == true)
    #expect(audioData["querySHA256"] as? String == sha256Hex(audioQuery))
    #expect(audioSlices.contains("audio_transcript"))
    #expect(audioResult.stdout?.contains(audioQuery) == false)
    #expect(audioResult.stdout?.contains("Team agreed") == false)

    let image = implementation.seedSearchableTextAttachment(
      id: "attachment-image-composite",
      title: "Diagram.png",
      typeUTI: "public.png",
      mediaFilename: "Diagram.png",
      text: "Composite visual evidence lives in the private searchable text index."
    )
    let imageResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "attachment-content", "--family", "photo-image", "--query", "visual evidence",
      "--json",
    ])))
    let imageObject = try jsonObject(imageResult.stdout ?? "")
    let imageData = try #require(imageObject["data"] as? [String: Any])
    let imageMatches = try #require(imageData["matches"] as? [[String: Any]])

    #expect(imageObject["ok"] as? Bool == true)
    #expect(imageData["family"] as? String == "photo-image")
    #expect(imageMatches.first?["slice"] as? String == "searchable_text")
    #expect(implementation.searchableTextLookups.contains("note-1:\(image.id)"))
    #expect((imageResult.stdout ?? "").contains("Composite visual evidence") == false)

    let scoped = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "--scope", "attachment-content", "--query", query, "--limit", "10", "--json",
    ])))
    let scopedObject = try jsonObject(scoped.stdout ?? "")
    let scopedData = try #require(scopedObject["data"] as? [String: Any])
    #expect(scopedObject["ok"] as? Bool == true)
    #expect(scopedData["operation"] as? String == "notes.search.attachment-content")
  }

  @Test func existingSearchLeafStillRunsVisibleTextSearch() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "notes", "search", "--query", "Plan", "--limit", "50", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let notes = data["notes"] as? [[String: Any]] ?? []

    #expect(object["ok"] as? Bool == true)
    #expect(notes.first?["title"] as? String == "Plan")
    #expect(implementation.searchQueries == ["Plan||50"])
    #expect(implementation.accountSearchQueries.isEmpty)
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
