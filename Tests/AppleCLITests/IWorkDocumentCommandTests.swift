import Foundation
import KeynoteCLI
import PagesCLI
import Testing
import Utility

@Suite
struct IWorkDocumentCommandTests {
  @Test func pagesDocumentsListReturnsJSON() throws {
    let command = PagesCommand(backend: FakePagesBackend())
    let options = try CLIOptionsFixture.parse(["documents", "list", "--path", ".", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let documents = data?["documents"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(documents?.first?["name"] as? String == "Report.pages")
  }

  @Test func pagesDocumentsSearchRequiresNonTrivialQuery() throws {
    let command = PagesCommand(backend: FakePagesBackend())
    let options = try CLIOptionsFixture.parse([
      "documents", "search", "--path", ".", "--query", "a", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func pagesReadOnlyCommandsRejectDryRuns() throws {
    let command = PagesCommand(backend: FakePagesBackend())
    let options = try CLIOptionsFixture.parse([
      "documents", "list", "--path", ".", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only Pages command to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func pagesOpenRequiresAllowExternalDispatch() throws {
    let command = PagesCommand(backend: FakePagesBackend(), externalActions: FakePagesActions())
    let options = try CLIOptionsFixture.parse([
      "documents", "open", "--path", "/tmp/Report.pages", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Pages open execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func pagesOpenDryRunAndAllowFlagExecutesPath() throws {
    let actions = FakePagesActions()
    let command = PagesCommand(backend: FakePagesBackend(), externalActions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents", "open", "--path", "/tmp/Report.pages", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "open",
      "--path",
      "/tmp/Report.pages",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["submitted"] as? Bool == true)
    #expect(actions.openedPaths == ["/tmp/Report.pages"])
  }

  @Test func pagesExportRequiresAllowArtifactActionBeforeDocumentLookup() throws {
    let command = PagesCommand(backend: FakePagesBackend(), externalActions: FakePagesActions())
    let options = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Missing.pages",
      "--format",
      "pdf",
      "--to",
      "/tmp/Missing.pdf",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Pages export execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func pagesExportDryRunAndAllowFlagExecutesDestination() throws {
    let root = try temporaryIWorkScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Report.pdf").path
    let backend = FakePagesBackend()
    let command = PagesCommand(backend: backend, externalActions: FakePagesActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Report.pages",
      "--format",
      "pdf",
      "--to",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Report.pages",
      "--format",
      "pdf",
      "--to",
      destination,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["destinationPath"] as? String == destination)
    #expect(
      backend.exportedDocuments.map { "\($0.0)->\($0.2)" } == ["/tmp/Report.pages->\(destination)"])
  }

  @Test func pagesThumbnailExportDryRunAndAllowFlagExecutesDestination() throws {
    let root = try temporaryIWorkScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Report.jpg").path
    let backend = FakePagesBackend()
    let command = PagesCommand(backend: backend, externalActions: FakePagesActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Report.pages",
      "--format",
      "thumbnail",
      "--to",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["format"] as? String == "thumbnail")

    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Report.pages",
      "--format",
      "thumbnail",
      "--to",
      destination,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["format"] as? String == "thumbnail")
    #expect(backend.exportedDocuments.map { "\($0.1)->\($0.2)" } == ["thumbnail->\(destination)"])
  }

  @Test func pagesExportAllowExecutionUsesCurrentFormat() throws {
    let root = try temporaryIWorkScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Report.pdf").path
    let command = PagesCommand(backend: FakePagesBackend(), externalActions: FakePagesActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Report.pages",
      "--format",
      "pdf",
      "--to",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Report.pages",
      "--format",
      "thumbnail",
      "--to",
      destination,
      "--allow-artifact-action",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["format"] as? String == "thumbnail")
  }

  @Test func pagesPackageExportDryRunAndAllowFlagExecutesPackage() throws {
    let root = try temporaryIWorkRoot(documentName: "Report.pages")
    defer { try? FileManager.default.removeItem(at: root) }
    let document = root.appendingPathComponent("Report.pages")
    try Data("pages-data".utf8).write(to: document.appendingPathComponent("Data.txt"))
    let destination = root.appendingPathComponent("ReportCopy.pages")
    let command = PagesCommand(
      backend: FileManagerPagesBackend(), externalActions: FakePagesActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      document.path,
      "--format",
      "package",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["format"] as? String == "package")
    #expect(FileManager.default.fileExists(atPath: destination.path) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      document.path,
      "--format",
      "package",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["format"] as? String == "package")
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("QuickLook/Preview.pdf"))
        == Data("preview".utf8))
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("Data.txt")) == Data("pages-data".utf8))
  }

  @Test func pagesPackageExportRejectsDestinationInsideSource() throws {
    let root = try temporaryIWorkRoot(documentName: "Report.pages")
    defer { try? FileManager.default.removeItem(at: root) }
    let document = root.appendingPathComponent("Report.pages")
    let destination = document.appendingPathComponent("Nested.pages")
    let command = PagesCommand(
      backend: FileManagerPagesBackend(), externalActions: FakePagesActions())
    let options = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      document.path,
      "--format",
      "package",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Pages package export inside source to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func fileManagerPagesBackendListsDirectDocumentsAndPreviewMetadata() throws {
    let root = try temporaryIWorkRoot(documentName: "Report.pages")
    defer { try? FileManager.default.removeItem(at: root) }

    let backend = FileManagerPagesBackend()
    let documents = try backend.listDocuments(path: root.path, limit: 10)
    let read = try #require(
      try backend.readDocument(path: root.appendingPathComponent("Report.pages").path))

    #expect(documents.count == 1)
    #expect(documents.first?.name == "Report.pages")
    #expect(read.quickLookPreviewPath?.hasSuffix("Preview.pdf") == true)
  }

  @Test func fileManagerPagesBackendExportsQuickLookPreviewPDF() throws {
    let root = try temporaryIWorkRoot(documentName: "Report.pages")
    defer { try? FileManager.default.removeItem(at: root) }

    let document = root.appendingPathComponent("Report.pages")
    let destination = root.appendingPathComponent("Report.pdf")
    let backend = FileManagerPagesBackend()
    let result = try backend.exportDocument(path: document.path, format: "pdf", to: destination.path)

    #expect(result.destinationPath == destination.path)
    #expect(try Data(contentsOf: destination) == Data("preview".utf8))
  }

  @Test func fileManagerPagesBackendExportsQuickLookThumbnail() throws {
    let root = try temporaryIWorkRoot(documentName: "Report.pages")
    defer { try? FileManager.default.removeItem(at: root) }

    let document = root.appendingPathComponent("Report.pages")
    let destination = root.appendingPathComponent("Report.jpg")
    let backend = FileManagerPagesBackend()
    let result = try backend.exportDocument(
      path: document.path, format: "thumbnail", to: destination.path)

    #expect(result.destinationPath == destination.path)
    #expect(result.format == "thumbnail")
    #expect(try Data(contentsOf: destination) == Data("thumbnail".utf8))
  }

  @Test func keynotePresentationsListReturnsJSON() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend())
    let options = try CLIOptionsFixture.parse(["presentations", "list", "--path", ".", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let presentations = data?["presentations"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(presentations?.first?["name"] as? String == "Deck.key")
  }

  @Test func keynoteSlidesListReturnsJSON() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend())
    let options = try CLIOptionsFixture.parse(["slides", "list", "--path", "/tmp/Deck.key", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let presentation = data?["presentation"] as? [String: Any]
    let slides = data?["slides"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(presentation?["name"] as? String == "Deck.key")
    #expect(slides?.map { $0["index"] as? Int } == [1, 2])
    #expect(slides?.first?["previewPath"] as? String == "/tmp/Deck.key/QuickLook/Slide 1.jpg")
  }

  @Test func keynotePresentationsSearchRequiresNonTrivialQuery() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend())
    let options = try CLIOptionsFixture.parse([
      "presentations", "search", "--path", ".", "--query", "a", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func keynoteReadOnlyCommandsRejectDryRuns() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend())
    let options = try CLIOptionsFixture.parse([
      "presentations", "list", "--path", ".", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only Keynote command to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func keynoteSlidesListRejectsDryRuns() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend())
    let options = try CLIOptionsFixture.parse([
      "slides", "list", "--path", "/tmp/Deck.key", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Keynote slides list to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func keynoteSlidesExportRequiresAllowArtifactActionBeforeLookup() throws {
    let backend = FakeKeynoteBackend()
    let command = KeynoteCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      "/tmp/Missing.key",
      "--format",
      "images",
      "--to",
      "/tmp/MissingSlides",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Keynote slides export execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.listSlidesPaths.isEmpty)
      #expect(backend.readPresentationPaths.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func keynoteSlidesExportDryRunAndAllowFlagExecutesImages() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }
    let presentation = root.appendingPathComponent("Deck.key", isDirectory: true)
    try addKeynoteSlidePreviewFiles(to: presentation)
    let destination = root.appendingPathComponent("DeckSlides")
    let command = KeynoteCommand(backend: FileManagerKeynoteBackend())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      presentation.path,
      "--format",
      "images",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["slides"] as? String == "2")
    #expect(FileManager.default.fileExists(atPath: destination.path) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      presentation.path,
      "--format",
      "images",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let files = executedData?["files"] as? [[String: Any]]

    #expect(executedData?["exportedSlideCount"] as? Int == 2)
    #expect(files?.compactMap { $0["index"] as? Int } == [1, 2])
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("slide-001.jpg"))
        == Data("slide-1".utf8))
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("slide-002.png"))
        == Data("slide-2".utf8))
  }

  @Test func keynoteSlidesExportAllowExecutionUsesCurrentDestination() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }
    let presentation = root.appendingPathComponent("Deck.key", isDirectory: true)
    try addKeynoteSlidePreviewFiles(to: presentation)
    let destination = root.appendingPathComponent("DeckSlides")
    let changedDestination = root.appendingPathComponent("OtherSlides")
    let command = KeynoteCommand(backend: FileManagerKeynoteBackend())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      presentation.path,
      "--format",
      "images",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    let executeOptions = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      presentation.path,
      "--format",
      "images",
      "--to",
      changedDestination.path,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(FileManager.default.fileExists(atPath: destination.path) == false)
    #expect(
      try Data(contentsOf: changedDestination.appendingPathComponent("slide-001.jpg"))
        == Data("slide-1".utf8))
  }

  @Test func keynoteSlidesExportAllowExecutionUsesCurrentSlideArtifacts() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }
    let presentation = root.appendingPathComponent("Deck.key", isDirectory: true)
    let quickLook = try addKeynoteSlidePreviewFiles(to: presentation)
    let destination = root.appendingPathComponent("DeckSlides")
    let command = KeynoteCommand(backend: FileManagerKeynoteBackend())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      presentation.path,
      "--format",
      "images",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    try Data("changed-slide-1".utf8).write(to: quickLook.appendingPathComponent("Slide 1.jpg"))
    let executeOptions = try CLIOptionsFixture.parse([
      "slides",
      "export",
      "--path",
      presentation.path,
      "--format",
      "images",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(
      try Data(contentsOf: destination.appendingPathComponent("slide-001.jpg"))
        == Data("changed-slide-1".utf8))
  }

  @Test func keynoteOpenRequiresAllowExternalDispatch() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend(), externalActions: FakeKeynoteActions())
    let options = try CLIOptionsFixture.parse([
      "presentations", "open", "--path", "/tmp/Deck.key", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Keynote open execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func keynoteOpenAllowExecutionUsesCurrentPath() throws {
    let command = KeynoteCommand(backend: FakeKeynoteBackend(), externalActions: FakeKeynoteActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "presentations", "open", "--path", "/tmp/Deck.key", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "presentations",
      "open",
      "--path",
      "/tmp/Other.key",
      "--allow-artifact-action",
      "--json",
    ])

    do {
      _ = try command.run(options: changedOptions)
      Issue.record("Expected changed Keynote path to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func keynoteExportAllowExecutionUsesCurrentDestination() throws {
    let root = try temporaryIWorkScratchRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Deck.pdf").path
    let changedDestination = root.appendingPathComponent("Other.pdf").path
    let command = KeynoteCommand(backend: FakeKeynoteBackend(), externalActions: FakeKeynoteActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      "/tmp/Deck.key",
      "--format",
      "pdf",
      "--to",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      "/tmp/Deck.key",
      "--format",
      "pdf",
      "--to",
      changedDestination,
      "--allow-artifact-action",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["destinationPath"] as? String == changedDestination)
  }

  @Test func keynoteThumbnailExportDryRunAndAllowFlagExecutesDestination() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }
    let presentation = root.appendingPathComponent("Deck.key")
    let destination = root.appendingPathComponent("Deck.jpg")
    let command = KeynoteCommand(
      backend: FileManagerKeynoteBackend(), externalActions: FakeKeynoteActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      presentation.path,
      "--format",
      "thumbnail",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["format"] as? String == "thumbnail")
    #expect(FileManager.default.fileExists(atPath: destination.path) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      presentation.path,
      "--format",
      "thumbnail",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["format"] as? String == "thumbnail")
    #expect(try Data(contentsOf: destination) == Data("thumbnail".utf8))
  }

  @Test func keynotePackageExportDryRunAndAllowFlagExecutesPackage() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }
    let presentation = root.appendingPathComponent("Deck.key")
    try Data("keynote-data".utf8).write(to: presentation.appendingPathComponent("Data.txt"))
    let destination = root.appendingPathComponent("DeckCopy.key")
    let command = KeynoteCommand(
      backend: FileManagerKeynoteBackend(), externalActions: FakeKeynoteActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      presentation.path,
      "--format",
      "package",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["format"] as? String == "package")
    #expect(FileManager.default.fileExists(atPath: destination.path) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      presentation.path,
      "--format",
      "package",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["format"] as? String == "package")
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("QuickLook/Preview.pdf"))
        == Data("preview".utf8))
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("Data.txt"))
        == Data("keynote-data".utf8))
  }

  @Test func keynotePackageExportRejectsDestinationInsideSource() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }
    let presentation = root.appendingPathComponent("Deck.key")
    let destination = presentation.appendingPathComponent("Nested.key")
    let command = KeynoteCommand(
      backend: FileManagerKeynoteBackend(), externalActions: FakeKeynoteActions())
    let options = try CLIOptionsFixture.parse([
      "presentations",
      "export",
      "--path",
      presentation.path,
      "--format",
      "package",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Keynote package export inside source to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func fileManagerKeynoteBackendListsDirectPresentationsAndPreviewMetadata() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }

    let backend = FileManagerKeynoteBackend()
    let presentations = try backend.listPresentations(path: root.path, limit: 10)
    let read = try #require(
      try backend.readPresentation(path: root.appendingPathComponent("Deck.key").path))

    #expect(presentations.count == 1)
    #expect(presentations.first?.name == "Deck.key")
    #expect(read.quickLookPreviewPath?.hasSuffix("Preview.pdf") == true)
  }

  @Test func fileManagerKeynoteBackendListsQuickLookSlidePreviews() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }

    let presentation = root.appendingPathComponent("Deck.key", isDirectory: true)
    let quickLook = presentation.appendingPathComponent("QuickLook", isDirectory: true)
    FileManager.default.createFile(
      atPath: quickLook.appendingPathComponent("Slide 2.png").path,
      contents: Data("slide-2".utf8)
    )
    FileManager.default.createFile(
      atPath: quickLook.appendingPathComponent("Slide 1.jpg").path,
      contents: Data("slide-1".utf8)
    )
    FileManager.default.createFile(
      atPath: quickLook.appendingPathComponent("Thumbnail.jpg").path,
      contents: Data("thumbnail".utf8)
    )

    let backend = FileManagerKeynoteBackend()
    let response = try #require(try backend.listSlides(path: presentation.path, limit: 10))

    #expect(response.presentation.name == "Deck.key")
    #expect(response.slides.map(\.index) == [1, 2])
    #expect(response.slides.first?.previewPath?.hasSuffix("Slide 1.jpg") == true)
    #expect(response.slides.last?.previewPath?.hasSuffix("Slide 2.png") == true)
  }

  @Test func fileManagerKeynoteBackendExportsQuickLookPreviewPDF() throws {
    let root = try temporaryIWorkRoot(documentName: "Deck.key")
    defer { try? FileManager.default.removeItem(at: root) }

    let presentation = root.appendingPathComponent("Deck.key")
    let destination = root.appendingPathComponent("Deck.pdf")
    let backend = FileManagerKeynoteBackend()
    let result = try backend.exportPresentation(
      path: presentation.path, format: "pdf", to: destination.path)

    #expect(result.destinationPath == destination.path)
    #expect(try Data(contentsOf: destination) == Data("preview".utf8))
  }
}

private final class FakePagesBackend: PagesReading, PagesExporting, @unchecked Sendable {
  var exportedDocuments: [(String, String, String)] = []

  func listDocuments(path: String, limit: Int) throws -> [PagesDocumentRecord] {
    documents().prefix(limit).map { $0 }
  }

  func searchDocuments(path: String, query: String, limit: Int) throws -> [PagesDocumentRecord] {
    documents().filter { $0.name.localizedCaseInsensitiveContains(query) }.prefix(limit).map { $0 }
  }

  func readDocument(path: String) throws -> PagesDocumentRecord? {
    documents().first { $0.path == path }
  }

  func exportDocument(path: String, format: String, to destinationPath: String) throws
    -> PagesExportResult
  {
    exportedDocuments.append((path, format, destinationPath))
    return PagesExportResult(
      operation: "pages.export",
      changed: true,
      sourcePath: path,
      destinationPath: destinationPath,
      format: format
    )
  }

  private func documents() -> [PagesDocumentRecord] {
    [
      PagesDocumentRecord(
        path: "/tmp/Report.pages",
        name: "Report.pages",
        isPackage: true,
        quickLookPreviewPath: "/tmp/Report.pages/QuickLook/Preview.pdf"
      ),
      PagesDocumentRecord(
        path: "/tmp/Other.pages",
        name: "Other.pages",
        isPackage: true,
        quickLookPreviewPath: "/tmp/Other.pages/QuickLook/Preview.pdf"
      ),
    ]
  }
}

private final class FakePagesActions: PagesExternalActioning, @unchecked Sendable {
  var openedPaths: [String] = []

  func open(path: String) throws -> Bool {
    openedPaths.append(path)
    return true
  }
}

private final class FakeKeynoteBackend: KeynoteReading, KeynoteExporting, @unchecked Sendable {
  var readPresentationPaths: [String] = []
  var listSlidesPaths: [String] = []

  func listPresentations(path: String, limit: Int) throws -> [KeynotePresentationRecord] {
    presentations().prefix(limit).map { $0 }
  }

  func searchPresentations(path: String, query: String, limit: Int) throws
    -> [KeynotePresentationRecord]
  {
    presentations().filter { $0.name.localizedCaseInsensitiveContains(query) }.prefix(limit).map {
      $0
    }
  }

  func readPresentation(path: String) throws -> KeynotePresentationRecord? {
    readPresentationPaths.append(path)
    return presentations().first { $0.path == path }
  }

  func listSlides(path: String, limit: Int) throws -> KeynoteSlidesResponse? {
    listSlidesPaths.append(path)
    guard let presentation = try readPresentation(path: path) else {
      return nil
    }
    let slides = [
      KeynoteSlideRecord(
        presentationPath: presentation.path,
        index: 1,
        id: "slide-1",
        previewPath: "/tmp/Deck.key/QuickLook/Slide 1.jpg"
      ),
      KeynoteSlideRecord(
        presentationPath: presentation.path,
        index: 2,
        id: "slide-2",
        previewPath: "/tmp/Deck.key/QuickLook/Slide 2.jpg"
      ),
    ].prefix(limit)
    return KeynoteSlidesResponse(presentation: presentation, slides: Array(slides))
  }

  func exportPresentation(path: String, format: String, to destinationPath: String) throws
    -> KeynoteExportResult
  {
    KeynoteExportResult(
      operation: "keynote.export",
      changed: true,
      sourcePath: path,
      destinationPath: destinationPath,
      format: format
    )
  }

  private func presentations() -> [KeynotePresentationRecord] {
    [
      KeynotePresentationRecord(
        path: "/tmp/Deck.key",
        name: "Deck.key",
        isPackage: true,
        quickLookPreviewPath: "/tmp/Deck.key/QuickLook/Preview.pdf"
      ),
      KeynotePresentationRecord(
        path: "/tmp/Other.key",
        name: "Other.key",
        isPackage: true,
        quickLookPreviewPath: "/tmp/Other.key/QuickLook/Preview.pdf"
      ),
    ]
  }
}

private final class FakeKeynoteActions: KeynoteExternalActioning, @unchecked Sendable {
  var openedPaths: [String] = []

  func open(path: String) throws -> Bool {
    openedPaths.append(path)
    return true
  }
}

private func temporaryIWorkRoot(documentName: String) throws -> URL {
  let root = try temporaryIWorkScratchRoot()
  let document = root.appendingPathComponent(documentName, isDirectory: true)
  let quickLook = document.appendingPathComponent("QuickLook", isDirectory: true)
  try FileManager.default.createDirectory(at: quickLook, withIntermediateDirectories: true)
  FileManager.default.createFile(
    atPath: quickLook.appendingPathComponent("Preview.pdf").path,
    contents: Data("preview".utf8)
  )
  FileManager.default.createFile(
    atPath: quickLook.appendingPathComponent("Thumbnail.jpg").path,
    contents: Data("thumbnail".utf8)
  )
  FileManager.default.createFile(
    atPath: root.appendingPathComponent("Notes.txt").path,
    contents: Data("ignore".utf8)
  )
  return root
}

@discardableResult
private func addKeynoteSlidePreviewFiles(to presentation: URL) throws -> URL {
  let quickLook = presentation.appendingPathComponent("QuickLook", isDirectory: true)
  try FileManager.default.createDirectory(at: quickLook, withIntermediateDirectories: true)
  try Data("slide-2".utf8).write(to: quickLook.appendingPathComponent("Slide 2.png"))
  try Data("slide-1".utf8).write(to: quickLook.appendingPathComponent("Slide 1.jpg"))
  try Data("thumbnail".utf8).write(to: quickLook.appendingPathComponent("Thumbnail.jpg"))
  return quickLook
}

private func temporaryIWorkScratchRoot() throws -> URL {
  let root = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString, isDirectory: true)
  try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
  return root
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw IWorkDocumentCommandTestError.notObject
  }
  return object
}

private enum IWorkDocumentCommandTestError: Error {
  case notObject
}
