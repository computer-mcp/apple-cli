import ContactsCLI
import CryptoKit
import Foundation
import Testing
import Utility

@Suite
struct ContactsCommandTests {
  @Test func contactsSearchReturnsJSONResults() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "search",
      "--query",
      "Ada",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    #expect(object["ok"] as? Bool == true)

    let data = object["data"] as? [String: Any]
    let contacts = data?["contacts"] as? [[String: Any]]
    #expect(contacts?.count == 1)
    #expect(contacts?.first?["displayName"] as? String == "Ada Lovelace")
  }

  @Test func contactsSearchRequiresNonTrivialQuery() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse(["contacts", "search", "--query", "a", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDuplicatesByEmailReturnsBoundedGroups() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts", "duplicates", "--field", "email", "--limit", "1", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let groups = data?["duplicateGroups"] as? [[String: Any]]
    let group = groups?.first
    let contacts = group?["contacts"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(groups?.count == 1)
    #expect(group?["field"] as? String == "email")
    #expect(group?["value"] as? String == "ada@example.com")
    #expect(group?["matchCount"] as? Int == 2)
    #expect((group?["normalizedValueHash"] as? String)?.isEmpty == false)
    #expect(contacts?.map { $0["id"] as? String } == ["contact-ada", "contact-ada-alt"])
  }

  @Test func contactsDuplicatesRejectsUnknownField() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts", "duplicates", "--field", "nickname", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected duplicate detection with unknown field to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDuplicatesRejectsDryRunOptions() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts", "duplicates", "--field", "email", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected duplicate detection to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsReadMissingIdReturnsNotFound() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse(["contacts", "read", "--id", "missing", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing contact to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsExportRequiresAllowArtifactActionBeforeLookup() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--id",
      "contact-ada",
      "--format",
      "vcard",
      "--output",
      destination,
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected contact export execution to throw before lookup.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(FileManager.default.fileExists(atPath: destination) == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsExportDryRunAndAllowFlagExecutesVCard() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--id",
      "contact-ada",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(summary?["id"] as? String == "contact-ada")
    #expect(summary?["format"] as? String == "vcard")
    #expect(summary?["destination_path"] as? String == destination)
    #expect((summary?["vcard_sha256"] as? String)?.isEmpty == false)
    #expect(FileManager.default.fileExists(atPath: destination) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--id",
      "contact-ada",
      "--format",
      "vcard",
      "--output",
      destination,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let content = try String(contentsOfFile: destination, encoding: .utf8)

    #expect(executedData?["operation"] as? String == "contacts.export")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["contactID"] as? String == "contact-ada")
    #expect(executedData?["destinationPath"] as? String == destination)
    #expect(content.contains("BEGIN:VCARD"))
    #expect(content.contains("FN:Ada Lovelace"))
    #expect(backend.exportedIDs == ["contact-ada", "contact-ada"])
  }

  @Test func contactsExportAllowExecutionUsesCurrentDestination() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let originalDestination = temporaryVCardPath()
    let changedDestination = temporaryVCardPath()
    defer {
      try? FileManager.default.removeItem(atPath: originalDestination)
      try? FileManager.default.removeItem(atPath: changedDestination)
    }
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--id",
      "contact-ada",
      "--format",
      "vcard",
      "--output",
      originalDestination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--id",
      "contact-ada",
      "--format",
      "vcard",
      "--output",
      changedDestination,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
    #expect(FileManager.default.fileExists(atPath: originalDestination) == false)
    #expect(FileManager.default.fileExists(atPath: changedDestination) == true)
  }

  @Test func contactsBulkExportRequiresAllowArtifactActionBeforeLookup() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--ids",
      "contact-ada,contact-grace",
      "--format",
      "vcard",
      "--output",
      destination,
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected bulk contact export execution to throw before lookup.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(FileManager.default.fileExists(atPath: destination) == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsBulkExportDryRunAndAllowFlagExecutesVCard() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--ids",
      "contact-ada,contact-grace",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(summary?["ids"] as? String == "contact-ada,contact-grace")
    #expect(summary?["contact_count"] as? String == "2")
    #expect(summary?["format"] as? String == "vcard")
    #expect((summary?["vcard_sha256"] as? String)?.isEmpty == false)
    #expect(FileManager.default.fileExists(atPath: destination) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--ids",
      "contact-ada,contact-grace",
      "--format",
      "vcard",
      "--output",
      destination,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let content = try String(contentsOfFile: destination, encoding: .utf8)

    #expect(executedData?["operation"] as? String == "contacts.export_many")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["contactIDs"] as? [String] == ["contact-ada", "contact-grace"])
    #expect(executedData?["contactCount"] as? Int == 2)
    #expect(executedData?["destinationPath"] as? String == destination)
    #expect(content.contains("FN:Ada Lovelace"))
    #expect(content.contains("FN:Grace Hopper"))
    #expect(backend.exportedIDs == ["contact-ada", "contact-grace", "contact-ada", "contact-grace"])
  }

  @Test func contactsBulkExportAllowExecutionUsesCurrentIDs() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--ids",
      "contact-ada,contact-grace",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--ids",
      "contact-grace,contact-ada",
      "--format",
      "vcard",
      "--output",
      destination,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
    #expect(FileManager.default.fileExists(atPath: destination))
  }

  @Test func contactsBulkExportRejectsDuplicateIDs() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--ids",
      "contact-ada,contact-ada",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected duplicate bulk contact export IDs to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsAllExportRequiresAllowArtifactActionBeforeEnumeration() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--all",
      "--limit",
      "2",
      "--format",
      "vcard",
      "--output",
      destination,
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected all contact export execution to throw before enumeration.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(FileManager.default.fileExists(atPath: destination) == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsAllExportDryRunAndAllowFlagExecutesVCard() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--all",
      "--limit",
      "2",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "contacts.export_all")
    #expect(summary?["ids"] as? String == "contact-ada,contact-grace")
    #expect(summary?["contact_count"] as? String == "2")
    #expect((summary?["vcard_sha256"] as? String)?.isEmpty == false)
    #expect(FileManager.default.fileExists(atPath: destination) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--all",
      "--limit",
      "2",
      "--format",
      "vcard",
      "--output",
      destination,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let content = try String(contentsOfFile: destination, encoding: .utf8)

    #expect(executedData?["operation"] as? String == "contacts.export_all")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["contactIDs"] as? [String] == ["contact-ada", "contact-grace"])
    #expect(executedData?["contactCount"] as? Int == 2)
    #expect(content.contains("FN:Ada Lovelace"))
    #expect(content.contains("FN:Grace Hopper"))
    #expect(backend.exportAllLimits == [2, 2])
    #expect(backend.exportedIDs == ["contact-ada", "contact-grace", "contact-ada", "contact-grace"])
  }

  @Test func contactsAllExportRefusesOverLimitStore() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--all",
      "--limit",
      "1",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected bounded all contact export to reject stores over --limit.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.exportAllLimits == [1])
      #expect(backend.exportedIDs.isEmpty)
      #expect(FileManager.default.fileExists(atPath: destination) == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsAllExportRequiresExplicitLimit() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let destination = temporaryVCardPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "export",
      "--all",
      "--format",
      "vcard",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected all contact export without explicit --limit to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.exportAllLimits.isEmpty)
      #expect(FileManager.default.fileExists(atPath: destination) == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsImportRequiresAllowExternalDispatchBeforeFileRead() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let source = temporaryVCardPath()
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "2",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected contact import execution to throw before file read.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.previewedImportByteCounts.isEmpty)
      #expect(backend.importedImportByteCounts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsImportDryRunAndAllowFlagExecutesVCard() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let source = temporaryVCardPath()
    try sampleImportVCard().write(toFile: source, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: source) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "2",
      "--on-duplicate",
      "create-new",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(dryRunData?["operation"] as? String == "contacts.import")
    #expect(summary?["source_path"] as? String == source)
    #expect(summary?["contact_count"] as? String == "2")
    #expect(summary?["format"] as? String == "vcard")
    #expect(summary?["limit"] as? String == "2")
    #expect(summary?["on_duplicate"] as? String == "create-new")
    #expect(summary?["importable_count"] as? String == "2")
    #expect(summary?["skipped_count"] as? String == "0")
    #expect((summary?["source_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["contact_identity_hash"] as? String)?.isEmpty == false)
    #expect((dryRun.stdout ?? "").contains("grace@example.com") == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "2",
      "--on-duplicate",
      "create-new",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let contacts = executedData?["contacts"] as? [[String: Any]]

    #expect(executedData?["operation"] as? String == "contacts.import")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["contactCount"] as? Int == 2)
    #expect(executedData?["duplicatePolicy"] as? String == "create-new")
    #expect(contacts?.map { $0["displayName"] as? String } == ["Ada Lovelace", "Grace Hopper"])
    #expect(backend.previewedImportByteCounts.count == 2)
    #expect(backend.importedImportByteCounts.count == 1)
  }

  @Test func contactsImportFailPolicyRefusesDuplicatesBeforeDryRun() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let source = temporaryVCardPath()
    try sampleImportVCard().write(toFile: source, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: source) }

    let options = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "2",
      "--on-duplicate",
      "fail",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected duplicate import fail policy to reject before issuing dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["duplicate_contact_count"] == "1")
      #expect(backend.importedImportByteCounts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsImportSkipExistingImportsOnlyNonDuplicates() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let source = temporaryVCardPath()
    try sampleImportVCard(extraName: "Katherine Johnson").write(
      toFile: source, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: source) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "3",
      "--on-duplicate",
      "skip-existing",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]

    #expect(summary?["on_duplicate"] as? String == "skip-existing")
    #expect(summary?["contact_count"] as? String == "3")
    #expect(summary?["importable_count"] as? String == "2")
    #expect(summary?["skipped_count"] as? String == "1")
    #expect(summary?["duplicate_count"] as? String == "1")
    #expect((summary?["duplicate_identity_hash"] as? String)?.isEmpty == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "3",
      "--on-duplicate",
      "skip-existing",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let contacts = executedData?["contacts"] as? [[String: Any]]
    let skipped = executedData?["skippedDuplicates"] as? [[String: Any]]

    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["contactCount"] as? Int == 2)
    #expect(executedData?["skippedCount"] as? Int == 1)
    #expect(executedData?["duplicatePolicy"] as? String == "skip-existing")
    #expect(contacts?.map { $0["displayName"] as? String } == ["Ada Lovelace", "Katherine Johnson"])
    #expect(skipped?.count == 1)
    #expect(backend.importedImportByteCounts.count == 1)
  }

  @Test func contactsImportAllowExecutionUsesCurrentFile() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let source = temporaryVCardPath()
    try sampleImportVCard().write(toFile: source, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: source) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "2",
      "--on-duplicate",
      "create-new",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    try sampleImportVCard(extraName: "Katherine Johnson").write(
      toFile: source, atomically: true, encoding: .utf8)
    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "3",
      "--on-duplicate",
      "create-new",
      "--allow-external-dispatch",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let executedData = try jsonObject(executed.stdout ?? "")["data"] as? [String: Any]
    #expect(executedData?["contactCount"] as? Int == 3)
  }

  @Test func contactsImportRequiresExplicitLimit() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let source = temporaryVCardPath()
    try sampleImportVCard().write(toFile: source, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: source) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected contact import without explicit --limit to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.previewedImportByteCounts.isEmpty)
      #expect(backend.importedImportByteCounts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsImportRequiresExplicitDuplicatePolicy() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let source = temporaryVCardPath()
    try sampleImportVCard().write(toFile: source, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: source) }
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "import",
      "--file",
      source,
      "--format",
      "vcard",
      "--limit",
      "2",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected contact import without explicit duplicate policy to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.previewedImportByteCounts.isEmpty)
      #expect(backend.importedImportByteCounts.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsFrameworkBackendPreviewsVCardImportWithoutAuthorization() throws {
    let data = Data(sampleImportVCard().utf8)
    let preview = try ContactsFrameworkBackend().previewContactImport(
      data: data, limit: 2, duplicatePolicy: .createNew)

    #expect(preview.contacts.map(\.displayName) == ["Ada Lovelace", "Grace Hopper"])
    #expect(preview.contacts.first?.emailAddresses == ["ada@example.com"])
  }

  @Test func contactGroupsListHonorsLimit() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse(["groups", "list", "--limit", "1", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let groups = data?["groups"] as? [[String: Any]]

    #expect(groups?.count == 1)
    #expect(groups?.first?["name"] as? String == "Team")
  }

  @Test func contactGroupMembersReturnsJSONResults() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "groups", "members", "--id", "group-team", "--limit", "1", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let group = data?["group"] as? [String: Any]
    let contacts = data?["contacts"] as? [[String: Any]]

    #expect(group?["id"] as? String == "group-team")
    #expect(group?["name"] as? String == "Team")
    #expect(contacts?.count == 1)
    #expect(contacts?.first?["id"] as? String == "contact-ada")
  }

  @Test func contactGroupMembersMissingGroupReturnsNotFound() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse(["groups", "members", "--id", "missing", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing contact group to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactGroupMembersRejectsMutationDryRunOptions() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "groups", "members", "--id", "group-team", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected group members read command to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactGroupAddMemberExecutionResolvesIdentityLookup() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "groups",
      "add-member",
      "--group-id",
      "missing",
      "--contact-id",
      "missing",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record(
        "Expected contact group add-member execution to throw before identity lookup.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactGroupAddMemberDryRunAndAllowFlagExecutesMembership() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "groups",
      "add-member",
      "--group-id",
      "group-vendors",
      "--contact-id",
      "contact-ada",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["group_id"] as? String == "group-vendors")
    #expect(summary?["contact_id"] as? String == "contact-ada")
    #expect(summary?["current_member"] as? String == "false")

    let executeOptions = try CLIOptionsFixture.parse([
      "groups",
      "add-member",
      "--group-id",
      "group-vendors",
      "--contact-id",
      "contact-ada",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let group = executedData?["group"] as? [String: Any]
    let contact = executedData?["contact"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "groups.add-member")
    #expect(group?["id"] as? String == "group-vendors")
    #expect(contact?["id"] as? String == "contact-ada")
    #expect(backend.addedMemberships == ["group-vendors:contact-ada"])
    #expect(backend.groupMembers["group-vendors"]?.contains("contact-ada") == true)
  }

  @Test func contactGroupRemoveMemberDryRunAndAllowFlagExecutesMembership() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "groups",
      "remove-member",
      "--group-id",
      "group-team",
      "--contact-id",
      "contact-ada",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["current_member"] as? String == "true")

    let executeOptions = try CLIOptionsFixture.parse([
      "groups",
      "remove-member",
      "--group-id",
      "group-team",
      "--contact-id",
      "contact-ada",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "groups.remove-member")
    #expect(backend.removedMemberships == ["group-team:contact-ada"])
    #expect(backend.groupMembers["group-team"]?.contains("contact-ada") == false)
  }

  @Test func contactGroupAddMemberAllowExecutionUsesCurrentMembership() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "groups",
      "add-member",
      "--group-id",
      "group-vendors",
      "--contact-id",
      "contact-ada",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    backend.groupMembers["group-vendors", default: []].insert("contact-ada")

    let executeOptions = try CLIOptionsFixture.parse([
      "groups",
      "add-member",
      "--group-id",
      "group-vendors",
      "--contact-id",
      "contact-ada",
      "--allow-external-dispatch",
      "--json",
    ])

    #expect(throws: CLIError.self) {
      try command.run(options: executeOptions)
    }
  }

  @Test func contactGroupAddMemberRejectsExistingMemberDryRun() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "groups",
      "add-member",
      "--group-id",
      "group-team",
      "--contact-id",
      "contact-ada",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected existing contact group member to reject add-member dry run.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsCreateExecutesWithoutDryRun() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "create",
      "--given-name",
      "Grace",
      "--family-name",
      "Hopper",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let data = try jsonObject(result.stdout ?? "")["data"] as? [String: Any]
    #expect(data?["operation"] as? String == "contacts.create")
  }

  @Test func contactsUpdateExecutionResolvesIdentityLookup() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "missing",
      "--job-title",
      "Chief Scientist",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected contact update execution to throw before identity lookup.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteExecutionResolvesIdentityLookup() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse(["contacts", "delete", "--id", "missing", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected contact delete execution to throw before identity lookup.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsCreateDryRunAndExecutionCreatesDraft() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "create",
      "--given-name",
      "Grace",
      "--family-name",
      "Hopper",
      "--email",
      "grace@example.com",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "create",
      "--given-name",
      "Grace",
      "--family-name",
      "Hopper",
      "--email",
      "grace@example.com",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let contact = executedData?["contact"] as? [String: Any]

    #expect(contact?["id"] as? String == "contact-created")
    #expect(backend.createdDrafts.map(\.givenName) == ["Grace"])
  }

  @Test func contactsUpdateDryRunAndExecutionAppliesPatch() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--job-title",
      "Chief Scientist",
      "--clear-phone",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--job-title",
      "Chief Scientist",
      "--clear-phone",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let contact = executedData?["contact"] as? [String: Any]

    #expect(contact?["jobTitle"] as? String == "Chief Scientist")
    #expect(backend.updatedPatches["contact-ada"]?.clearPhone == true)
  }

  @Test func contactsUpdateAllowExecutionUsesCurrentPatch() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--job-title",
      "Chief Scientist",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--job-title",
      "Different title",
      "--allow-external-dispatch",
      "--json",
    ])

    let changed = try #require(try command.run(options: changedOptions))
    let changedData = try jsonObject(changed.stdout ?? "")["data"] as? [String: Any]
    let changedContact = changedData?["contact"] as? [String: Any]
    #expect(changedContact?["jobTitle"] as? String == "Different title")
  }

  @Test func contactsUpdateEmailLabelPreservesOtherValues() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--email",
      "ada-home-new@example.com",
      "--email-label",
      "home",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]
    #expect(summary?["email_label"] as? String == "home")

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--email",
      "ada-home-new@example.com",
      "--email-label",
      "home",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let contact = executedData?["contact"] as? [String: Any]

    #expect(
      contact?["emailAddresses"] as? [String] == ["ada-home-new@example.com", "ada-work@example.com"])
    #expect(contact?["emailLabels"] as? [String] == ["home", "work"])
    #expect(backend.updatedPatches["contact-ada"]?.emailLabel == "home")
  }

  @Test func contactsUpdateClearPhoneLabelPreservesOtherValues() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--clear-phone",
      "--phone-label",
      "mobile",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--clear-phone",
      "--phone-label",
      "mobile",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let contact = executedData?["contact"] as? [String: Any]

    #expect(contact?["phoneNumbers"] as? [String] == ["+15550199"])
    #expect(contact?["phoneLabels"] as? [String] == ["work"])
    #expect(backend.updatedPatches["contact-ada"]?.phoneLabel == "mobile")
  }

  @Test func contactsUpdateAllowExecutionUsesCurrentLabelMetadata() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--email",
      "ada-home-new@example.com",
      "--email-label",
      "home",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.adaEmailLabels = ["other", "work"]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--email",
      "ada-home-new@example.com",
      "--email-label",
      "home",
      "--allow-external-dispatch",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let executedData = try jsonObject(executed.stdout ?? "")["data"] as? [String: Any]
    let executedContact = executedData?["contact"] as? [String: Any]
    #expect(executedContact?["emailLabels"] as? [String] == ["other", "work", "home"])
  }

  @Test func contactsUpdateLabelRequiresMatchingValueOrClear() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "update",
      "--id",
      "contact-ada",
      "--email-label",
      "home",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected label-only update to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteDryRunAndAllowFlagExecutesContact() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts", "delete", "--id", "contact-ada", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--id",
      "contact-ada",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["deletedID"] as? String == "contact-ada")
    #expect(backend.deletedIDs == ["contact-ada"])
  }

  @Test func contactsBulkDeleteExecutesWithoutDryRun() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-grace",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let data = try jsonObject(result.stdout ?? "")["data"] as? [String: Any]
    #expect(data?["deletedCount"] as? Int == 2)
  }

  @Test func contactsBulkDeleteDryRunAndExecutionDeletesContacts() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-grace",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(data?["operation"] as? String == "contacts.delete-many")
    #expect(summary?["ids"] as? String == "contact-ada,contact-grace")
    #expect(summary?["contact_count"] as? String == "2")
    #expect((summary?["identity_hash"] as? String)?.isEmpty == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-grace",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "contacts.delete-many")
    #expect(executedData?["contactIDs"] as? [String] == ["contact-ada", "contact-grace"])
    #expect(executedData?["deletedCount"] as? Int == 2)
    #expect(backend.deletedIDs == ["contact-ada", "contact-grace"])
  }

  @Test func contactsBulkDeleteAllowExecutionUsesCurrentIDs() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-grace",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-grace,contact-ada",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
    #expect(backend.deletedIDs == ["contact-grace", "contact-ada"])
  }

  @Test func contactsBulkDeleteAllowExecutionUsesCurrentIdentity() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-grace",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.adaEmailLabels = ["other", "work"]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-grace",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))
    #expect(backend.deletedIDs == ["contact-ada", "contact-grace"])
  }

  @Test func contactsBulkDeleteRejectsDuplicateIDs() throws {
    let command = ContactsCommand(backend: FakeContactsBackend())
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "delete",
      "--ids",
      "contact-ada,contact-ada",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected duplicate bulk contact delete IDs to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteMatchingRequiresAllowDestructiveSelectionBeforeSearch() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected delete-matching execution to throw before search.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.deletedIDs.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteMatchingRequiresExplicitLimitBeforeSearch() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected delete-matching without explicit limit to throw before search.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.contactSearchQueries.isEmpty)
      #expect(backend.deletedIDs.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteMatchingRejectsBroadQueryBeforeSearch() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ad",
      "--limit",
      "5",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected broad delete-matching query to throw before search.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.contactSearchQueries.isEmpty)
      #expect(backend.deletedIDs.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteMatchingDryRunAndAllowFlagExecutesQuery() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(data?["operation"] as? String == "contacts.delete-matching")
    #expect(summary?["query"] as? String == "Ada")
    #expect(summary?["limit"] as? String == "5")
    #expect(summary?["ids"] as? String == "contact-ada")
    #expect(summary?["contact_count"] as? String == "1")
    #expect((summary?["identity_hash"] as? String)?.isEmpty == false)
    #expect(backend.deletedIDs.isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--allow-destructive-selection",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "contacts.delete-matching")
    #expect(executedData?["contactIDs"] as? [String] == ["contact-ada"])
    #expect(executedData?["deletedCount"] as? Int == 1)
    #expect(backend.deletedIDs == ["contact-ada"])
    #expect(backend.contactSearchQueries.map(\.limit) == [6, 6])
  }

  @Test func contactsDeleteMatchingRefusesOverLimitCandidates() throws {
    let backend = FakeContactsBackend()
    backend.extraSearchSummaries = [
      ContactSummary(id: "contact-grace", displayName: "Ada Grace")
    ]
    let command = ContactsCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "1",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected delete-matching over explicit limit to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.deletedIDs.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func contactsDeleteMatchingAllowExecutionUsesCurrentCandidates() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.extraSearchSummaries = [
      ContactSummary(id: "contact-grace", displayName: "Ada Grace")
    ]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--allow-destructive-selection",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))
    #expect(backend.deletedIDs == ["contact-ada", "contact-grace"])
  }

  @Test func contactsDeleteMatchingAllowExecutionUsesCurrentCandidateIdentity() throws {
    let backend = FakeContactsBackend()
    let command = ContactsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.adaEmailLabels = ["other", "work"]

    let executeOptions = try CLIOptionsFixture.parse([
      "contacts",
      "delete-matching",
      "--query",
      "Ada",
      "--limit",
      "5",
      "--allow-destructive-selection",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))
    #expect(backend.deletedIDs == ["contact-ada"])
  }
}

private final class FakeContactsBackend: ContactsReading, ContactsMutating, @unchecked Sendable {
  var createdDrafts: [ContactCreateDraft] = []
  var updatedPatches: [String: ContactPatch] = [:]
  var deletedIDs: [String] = []
  var addedMemberships: [String] = []
  var removedMemberships: [String] = []
  var exportedIDs: [String] = []
  var exportAllLimits: [Int] = []
  var previewedImportByteCounts: [Int] = []
  var importedImportByteCounts: [Int] = []
  var contactSearchQueries: [ContactSearchQuery] = []
  var extraSearchSummaries: [ContactSummary] = []
  var adaEmailAddresses = ["ada-home@example.com", "ada-work@example.com"]
  var adaEmailLabels = ["home", "work"]
  var adaPhoneNumbers = ["+15550100", "+15550199"]
  var adaPhoneLabels = ["mobile", "work"]
  var groupMembers: [String: Set<String>] = [
    "group-team": ["contact-ada", "contact-grace"],
    "group-vendors": [],
  ]

  func searchContacts(_ query: ContactSearchQuery) throws -> [ContactSummary] {
    contactSearchQueries.append(query)
    let contacts =
      ["contact-ada", "contact-grace"].compactMap(contactSummary) + extraSearchSummaries
    return
      contacts
      .filter { contactMatches($0, query: query.query) }
      .prefix(query.limit)
      .map { $0 }
  }

  func findDuplicateContacts(_ query: ContactDuplicateQuery) throws -> [ContactDuplicateGroup] {
    let group = ContactDuplicateGroup(
      field: query.field,
      value: query.field == "phone" ? "+15550100" : "ada@example.com",
      normalizedValueHash: "duplicate-hash",
      matchCount: 2,
      contacts: [
        ContactSummary(
          id: "contact-ada",
          displayName: "Ada Lovelace",
          organizationName: "Analytical Engines",
          emailAddresses: adaEmailAddresses,
          phoneNumbers: adaPhoneNumbers,
          emailLabels: adaEmailLabels,
          phoneLabels: adaPhoneLabels
        ),
        ContactSummary(
          id: "contact-ada-alt",
          displayName: "Ada Byron",
          organizationName: "Analytical Engines",
          emailAddresses: ["ADA@example.com"],
          phoneNumbers: ["(555) 0100"]
        ),
      ]
    )
    return query.limit > 0 ? [group] : []
  }

  func readContact(id: String) throws -> ContactDetail? {
    if id == "contact-grace" {
      return ContactDetail(
        id: "contact-grace",
        displayName: "Grace Hopper",
        givenName: "Grace",
        familyName: "Hopper",
        organizationName: "Navy",
        jobTitle: "Computer Scientist",
        emailAddresses: ["grace@example.com"],
        phoneNumbers: ["+15550101"],
        emailLabels: ["work"],
        phoneLabels: ["mobile"]
      )
    }
    guard id == "contact-ada" else {
      return nil
    }

    return ContactDetail(
      id: "contact-ada",
      displayName: "Ada Lovelace",
      givenName: "Ada",
      familyName: "Lovelace",
      organizationName: "Analytical Engines",
      jobTitle: "Mathematician",
      emailAddresses: adaEmailAddresses,
      phoneNumbers: adaPhoneNumbers,
      emailLabels: adaEmailLabels,
      phoneLabels: adaPhoneLabels
    )
  }

  func exportContact(id: String) throws -> ContactExportPayload? {
    guard let contact = try readContact(id: id) else {
      return nil
    }
    exportedIDs.append(id)
    let vCard = """
      BEGIN:VCARD
      VERSION:3.0
      FN:\(contact.displayName)
      EMAIL:\(contact.emailAddresses.first ?? "")
      END:VCARD

      """
    return ContactExportPayload(contact: contact, data: Data(vCard.utf8))
  }

  func exportAllContacts(limit: Int) throws -> [ContactExportPayload] {
    exportAllLimits.append(limit)
    let ids = ["contact-ada", "contact-grace"]
    guard ids.count <= limit else {
      throw CLIError(
        code: .validationError,
        message:
          "Contact export matched more than `--limit` contacts. Increase `--limit` up to 500 or use explicit `--ids`.",
        details: ["limit": "\(limit)"]
      )
    }
    return try ids.map { id in
      guard let payload = try exportContact(id: id) else {
        throw CLIError(code: .notFound, message: "Contact was not found.", details: ["id": id])
      }
      return payload
    }
  }

  func previewContactImport(
    data: Data,
    limit: Int,
    duplicatePolicy: ContactImportDuplicatePolicy
  ) throws -> ContactImportPreview {
    previewedImportByteCounts.append(data.count)
    let contacts = try importedContacts(from: data, limit: limit)
    let duplicates = duplicatePolicy == .createNew ? [] : importDuplicates(for: contacts)
    return ContactImportPreview(
      contacts: contacts, duplicatePolicy: duplicatePolicy, duplicates: duplicates)
  }

  func importContacts(
    data: Data,
    limit: Int,
    duplicatePolicy: ContactImportDuplicatePolicy
  ) throws -> ContactImportExecution {
    importedImportByteCounts.append(data.count)
    let contacts = try importedContacts(from: data, limit: limit)
    let duplicates = duplicatePolicy == .createNew ? [] : importDuplicates(for: contacts)
    if duplicatePolicy == .fail, !duplicates.isEmpty {
      throw CLIError(code: .validationError, message: "Contact import matched existing contacts.")
    }
    let skippedIndexes = Set(duplicates.map(\.importedIndex))
    let imported =
      duplicatePolicy == .skipExisting
      ? contacts.enumerated().filter { !skippedIndexes.contains($0.offset) }.map(\.element)
      : contacts
    return ContactImportExecution(contacts: imported, skippedDuplicates: duplicates)
  }

  func listGroups(limit: Int) throws -> [ContactGroupRecord] {
    [
      ContactGroupRecord(id: "group-team", name: "Team"),
      ContactGroupRecord(id: "group-vendors", name: "Vendors"),
    ]
    .prefix(limit)
    .map { $0 }
  }

  func listGroupMembers(groupID: String, limit: Int) throws -> ContactGroupMembersResponse? {
    let groups = try listGroups(limit: 50)
    guard let group = groups.first(where: { $0.id == groupID }) else {
      return nil
    }

    let members = groupMembers[groupID, default: []]
      .compactMap(contactSummary)
      .sorted {
        $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
      }

    return ContactGroupMembersResponse(
      group: group,
      contacts: Array(members.prefix(limit))
    )
  }

  func contactForMutation(id: String) throws -> ContactDetail? {
    try readContact(id: id)
  }

  func groupForMutation(id: String) throws -> ContactGroupRecord? {
    try listGroups(limit: 50).first { $0.id == id }
  }

  func isContact(_ contactID: String, memberOfGroup groupID: String) throws -> Bool {
    groupMembers[groupID, default: []].contains(contactID)
  }

  func createContact(_ draft: ContactCreateDraft) throws -> ContactDetail {
    createdDrafts.append(draft)
    return ContactDetail(
      id: "contact-created",
      displayName: [draft.givenName, draft.familyName].filter { !$0.isEmpty }.joined(
        separator: " "),
      givenName: draft.givenName,
      familyName: draft.familyName,
      organizationName: draft.organizationName,
      jobTitle: draft.jobTitle,
      emailAddresses: draft.emailAddress.map { [$0] } ?? [],
      phoneNumbers: draft.phoneNumber.map { [$0] } ?? [],
      emailLabels: draft.emailAddress == nil ? [] : [draft.emailLabel ?? "work"],
      phoneLabels: draft.phoneNumber == nil ? [] : [draft.phoneLabel ?? "mobile"]
    )
  }

  func updateContact(id: String, patch: ContactPatch) throws -> ContactDetail {
    updatedPatches[id] = patch
    guard var contact = try readContact(id: id) else {
      throw CLIError(code: .notFound, message: "Contact was not found.", details: ["id": id])
    }

    if let givenName = patch.givenName {
      contact.givenName = givenName
    }
    if let familyName = patch.familyName {
      contact.familyName = familyName
    }
    contact.displayName = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(
      separator: " ")
    if let organizationName = patch.organizationName {
      contact.organizationName = organizationName
    } else if patch.clearOrganization {
      contact.organizationName = nil
    }
    if let jobTitle = patch.jobTitle {
      contact.jobTitle = jobTitle
    } else if patch.clearJobTitle {
      contact.jobTitle = nil
    }
    if let emailAddress = patch.emailAddress {
      if let emailLabel = patch.emailLabel {
        replaceLabeledValue(
          values: &contact.emailAddresses, labels: &contact.emailLabels, label: emailLabel,
          value: emailAddress)
      } else {
        contact.emailAddresses = [emailAddress]
        contact.emailLabels = ["work"]
      }
    } else if patch.clearEmail {
      if let emailLabel = patch.emailLabel {
        removeLabeledValues(
          values: &contact.emailAddresses, labels: &contact.emailLabels, label: emailLabel)
      } else {
        contact.emailAddresses = []
        contact.emailLabels = []
      }
    }
    if let phoneNumber = patch.phoneNumber {
      if let phoneLabel = patch.phoneLabel {
        replaceLabeledValue(
          values: &contact.phoneNumbers, labels: &contact.phoneLabels, label: phoneLabel,
          value: phoneNumber)
      } else {
        contact.phoneNumbers = [phoneNumber]
        contact.phoneLabels = ["mobile"]
      }
    } else if patch.clearPhone {
      if let phoneLabel = patch.phoneLabel {
        removeLabeledValues(
          values: &contact.phoneNumbers, labels: &contact.phoneLabels, label: phoneLabel)
      } else {
        contact.phoneNumbers = []
        contact.phoneLabels = []
      }
    }
    return contact
  }

  func deleteContact(id: String) throws -> Bool {
    deletedIDs.append(id)
    return true
  }

  func deleteContacts(ids: [String]) throws -> [String] {
    deletedIDs.append(contentsOf: ids)
    return ids
  }

  func addContact(id: String, toGroupID groupID: String) throws -> Bool {
    addedMemberships.append("\(groupID):\(id)")
    groupMembers[groupID, default: []].insert(id)
    return true
  }

  func removeContact(id: String, fromGroupID groupID: String) throws -> Bool {
    removedMemberships.append("\(groupID):\(id)")
    groupMembers[groupID, default: []].remove(id)
    return true
  }

  private func contactSummary(id: String) -> ContactSummary? {
    switch id {
    case "contact-ada":
      return ContactSummary(
        id: "contact-ada",
        displayName: "Ada Lovelace",
        organizationName: "Analytical Engines",
        emailAddresses: adaEmailAddresses,
        phoneNumbers: adaPhoneNumbers,
        emailLabels: adaEmailLabels,
        phoneLabels: adaPhoneLabels
      )
    case "contact-grace":
      return ContactSummary(id: "contact-grace", displayName: "Grace Hopper")
    default:
      return nil
    }
  }

  private func contactMatches(_ contact: ContactSummary, query: String) -> Bool {
    let searchable =
      [
        contact.displayName,
        contact.organizationName ?? "",
      ] + contact.emailAddresses + contact.phoneNumbers
    return searchable.contains {
      $0.localizedCaseInsensitiveContains(query)
    }
  }

  private func importedContacts(from data: Data, limit: Int) throws -> [ContactDetail] {
    guard let text = String(data: data, encoding: .utf8) else {
      throw CLIError(code: .validationError, message: "vCard import file could not be parsed.")
    }
    let cards =
      text
      .components(separatedBy: "BEGIN:VCARD")
      .dropFirst()
      .map { "BEGIN:VCARD" + $0 }
    guard cards.count <= limit else {
      throw CLIError(
        code: .validationError,
        message: "vCard import file contains more contacts than `--limit`.",
        details: ["limit": "\(limit)", "contact_count": "\(cards.count)"]
      )
    }

    return cards.enumerated().map { index, card in
      let fullName = vCardValue("FN", in: card) ?? "Imported Contact \(index + 1)"
      let email = vCardValue("EMAIL", in: card)
      let parts = fullName.split(separator: " ", maxSplits: 1).map(String.init)
      return ContactDetail(
        id: "imported-\(index + 1)",
        displayName: fullName,
        givenName: parts.first ?? "",
        familyName: parts.count > 1 ? parts[1] : "",
        organizationName: nil,
        jobTitle: nil,
        emailAddresses: email.map { [$0] } ?? [],
        phoneNumbers: [],
        emailLabels: email == nil ? [] : ["work"],
        phoneLabels: []
      )
    }
  }

  private func importDuplicates(for imported: [ContactDetail]) -> [ContactImportDuplicate] {
    let existing = ["contact-ada", "contact-grace"].compactMap { try? readContact(id: $0) }
    var duplicates: [ContactImportDuplicate] = []
    for (index, contact) in imported.enumerated() {
      for importedEmail in contact.emailAddresses {
        let normalized = importedEmail.lowercased()
        for existingContact in existing
        where existingContact.emailAddresses.map({ $0.lowercased() }).contains(normalized) {
          let key = "email:\(normalized)"
          duplicates.append(
            ContactImportDuplicate(
              importedIndex: index,
              existingID: existingContact.id,
              matchKind: "email",
              matchValueHash: fakeSHA256(key)
            )
          )
        }
      }
      for importedPhone in contact.phoneNumbers {
        let digits = importedPhone.filter(\.isNumber)
        for existingContact in existing
        where existingContact.phoneNumbers.map({ $0.filter(\.isNumber) }).contains(digits) {
          let key = "phone:\(digits)"
          duplicates.append(
            ContactImportDuplicate(
              importedIndex: index,
              existingID: existingContact.id,
              matchKind: "phone",
              matchValueHash: fakeSHA256(key)
            )
          )
        }
      }
    }
    return duplicates
  }

  private func replaceLabeledValue(
    values: inout [String], labels: inout [String], label: String, value: String
  ) {
    if let index = labels.firstIndex(of: label) {
      values[index] = value
    } else {
      values.append(value)
      labels.append(label)
    }
  }

  private func removeLabeledValues(values: inout [String], labels: inout [String], label: String) {
    let kept = values.enumerated().filter { index, _ in
      index >= labels.count || labels[index] != label
    }
    values = kept.map(\.element)
    labels = kept.map { index, _ in index < labels.count ? labels[index] : "" }
  }
}

private func vCardValue(_ key: String, in card: String) -> String? {
  for line in card.components(separatedBy: .newlines) {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("\(key):") {
      return String(trimmed.dropFirst(key.count + 1))
    }
    if trimmed.hasPrefix("\(key);"), let colon = trimmed.firstIndex(of: ":") {
      return String(trimmed[trimmed.index(after: colon)...])
    }
  }
  return nil
}

private func fakeSHA256(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw ContactsCommandTestError.notObject
  }
  return object
}

private func temporaryVCardPath() -> String {
  FileManager.default.temporaryDirectory
    .appendingPathComponent("contact-export-\(UUID().uuidString).vcf")
    .standardizedFileURL
    .path
}

private func sampleImportVCard(extraName: String? = nil) -> String {
  var cards = [
    """
    BEGIN:VCARD
    VERSION:3.0
    FN:Ada Lovelace
    EMAIL:ada@example.com
    END:VCARD
    """,
    """
    BEGIN:VCARD
    VERSION:3.0
    FN:Grace Hopper
    EMAIL:grace@example.com
    END:VCARD
    """,
  ]
  if let extraName {
    cards.append(
      """
      BEGIN:VCARD
      VERSION:3.0
      FN:\(extraName)
      EMAIL:extra@example.com
      END:VCARD
      """
    )
  }
  return cards.joined(separator: "\n") + "\n"
}

private enum ContactsCommandTestError: Error {
  case notObject
}
