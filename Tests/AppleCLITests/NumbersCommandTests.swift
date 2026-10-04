import Foundation
import NumbersCLI
import Testing
import Utility

@Suite
struct NumbersCommandTests {
  @Test func numbersDocumentsListReturnsJSON() throws {
    let command = NumbersCommand(backend: FakeNumbersBackend())
    let options = try CLIOptionsFixture.parse(["documents", "list", "--path", ".", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let documents = data?["documents"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(documents?.first?["name"] as? String == "Budget.numbers")
  }

  @Test func numbersDocumentsSearchRequiresNonTrivialQuery() throws {
    let command = NumbersCommand(backend: FakeNumbersBackend())
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

  @Test func numbersDocumentReadMissingReturnsNotFound() throws {
    let command = NumbersCommand(backend: FakeNumbersBackend())
    let options = try CLIOptionsFixture.parse([
      "documents", "read", "--path", "Missing.numbers", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing document to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersSheetsListReturnsSheetAndTableMetadata() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "sheets", "list", "--path", "/tmp/Budget.numbers", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let document = data?["document"] as? [String: Any]
    let sheets = data?["sheets"] as? [[String: Any]]
    let firstTables = sheets?.first?["tables"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(document?["name"] as? String == "Budget.numbers")
    #expect(sheets?.map { $0["name"] as? String } == ["Summary", "Detail"])
    #expect(firstTables?.first?["name"] as? String == "Budget")
    #expect(firstTables?.first?["rowCount"] as? Int == 3)
  }

  @Test func numbersTablesReadReturnsBoundedRows() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "tables",
      "read",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--limit",
      "2",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let table = data?["table"] as? [String: Any]
    let rows = table?["rows"] as? [[String: Any]]

    #expect(table?["sheetName"] as? String == "Summary")
    #expect(table?["tableName"] as? String == "Budget")
    #expect(table?["rowCount"] as? Int == 3)
    #expect(table?["columnCount"] as? Int == 2)
    #expect(rows?.count == 2)
    #expect(rows?.first?["values"] as? [String] == ["Category", "Amount"])
  }

  @Test func numbersTablesReadMissingReturnsNotFound() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "tables",
      "read",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Missing",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing Numbers table to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersReadOnlyCommandsRejectDryRuns() throws {
    let command = NumbersCommand(backend: FakeNumbersBackend())
    let options = try CLIOptionsFixture.parse([
      "documents",
      "list",
      "--path",
      ".",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only Numbers command to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersContentReadOnlyCommandsRejectDryRuns() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "sheets",
      "list",
      "--path",
      "/tmp/Budget.numbers",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only Numbers content command to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersOpenRequiresAllowExternalDispatch() throws {
    let command = NumbersCommand(backend: FakeNumbersBackend(), externalActions: FakeNumbersActions())
    let options = try CLIOptionsFixture.parse([
      "documents", "open", "--path", "/tmp/Budget.numbers", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Numbers open execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersOpenDryRunAndAllowFlagExecutesPath() throws {
    let actions = FakeNumbersActions()
    let command = NumbersCommand(backend: FakeNumbersBackend(), externalActions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents", "open", "--path", "/tmp/Budget.numbers", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "open",
      "--path",
      "/tmp/Budget.numbers",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["submitted"] as? Bool == true)
    #expect(actions.openedPaths == ["/tmp/Budget.numbers"])
  }

  @Test func numbersOpenAllowExecutionUsesCurrentPath() throws {
    let actions = FakeNumbersActions()
    let command = NumbersCommand(backend: FakeNumbersBackend(), externalActions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents", "open", "--path", "/tmp/Budget.numbers", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "documents",
      "open",
      "--path",
      "/tmp/Other.numbers",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(actions.openedPaths == ["/tmp/Other.numbers"])
  }

  @Test func numbersExportRequiresAllowArtifactActionBeforeDocumentLookup() throws {
    let command = NumbersCommand(backend: FakeNumbersBackend(), externalActions: FakeNumbersActions())
    let options = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Missing.numbers",
      "--format",
      "pdf",
      "--to",
      "/tmp/Missing.pdf",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Numbers export execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersExportDryRunAndAllowFlagExecutesDestination() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.pdf").path
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, externalActions: FakeNumbersActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Budget.numbers",
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
      "/tmp/Budget.numbers",
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
      backend.exportedDocuments.map { "\($0.0)->\($0.2)" } == ["/tmp/Budget.numbers->\(destination)"])
  }

  @Test func numbersExportAllowExecutionUsesCurrentDestination() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.pdf").path
    let changedDestination = root.appendingPathComponent("Other.pdf").path
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, externalActions: FakeNumbersActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      "/tmp/Budget.numbers",
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
      "/tmp/Budget.numbers",
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
    #expect(
      backend.exportedDocuments.map { "\($0.0)->\($0.2)" }
        == ["/tmp/Budget.numbers->\(changedDestination)"])
  }

  @Test func numbersThumbnailExportDryRunAndAllowFlagExecutesDestination() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let document = root.appendingPathComponent("Budget.numbers", isDirectory: true)
    let quickLook = document.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: quickLook, withIntermediateDirectories: true)
    try Data("numbers-preview".utf8).write(to: quickLook.appendingPathComponent("Preview.pdf"))
    try Data("numbers-thumbnail".utf8).write(to: quickLook.appendingPathComponent("Thumbnail.jpg"))
    let destination = root.appendingPathComponent("Budget.jpg")
    let command = NumbersCommand(
      backend: FileManagerNumbersBackend(),
      contentBackend: FakeNumbersBackend(),
      externalActions: FakeNumbersActions()
    )
    let dryRunOptions = try CLIOptionsFixture.parse([
      "documents",
      "export",
      "--path",
      document.path,
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
      "documents",
      "export",
      "--path",
      document.path,
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
    #expect(try Data(contentsOf: destination) == Data("numbers-thumbnail".utf8))
  }

  @Test func numbersPackageExportDryRunAndAllowFlagExecutesPackage() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let document = root.appendingPathComponent("Budget.numbers", isDirectory: true)
    let quickLook = document.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: quickLook, withIntermediateDirectories: true)
    try Data("numbers-preview".utf8).write(to: quickLook.appendingPathComponent("Preview.pdf"))
    try Data("numbers-data".utf8).write(to: document.appendingPathComponent("Data.txt"))
    let destination = root.appendingPathComponent("BudgetCopy.numbers")
    let command = NumbersCommand(
      backend: FileManagerNumbersBackend(),
      contentBackend: FakeNumbersBackend(),
      externalActions: FakeNumbersActions()
    )
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
        == Data("numbers-preview".utf8))
    #expect(
      try Data(contentsOf: destination.appendingPathComponent("Data.txt"))
        == Data("numbers-data".utf8))
  }

  @Test func numbersPackageExportRejectsDestinationInsideSource() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let document = root.appendingPathComponent("Budget.numbers", isDirectory: true)
    try FileManager.default.createDirectory(at: document, withIntermediateDirectories: true)
    let destination = document.appendingPathComponent("Nested.numbers")
    let command = NumbersCommand(
      backend: FileManagerNumbersBackend(),
      contentBackend: FakeNumbersBackend(),
      externalActions: FakeNumbersActions()
    )
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
      Issue.record("Expected Numbers package export inside source to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersTableExportRequiresAllowArtifactActionBeforeLookup() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Missing.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      "/tmp/Missing.csv",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Numbers table export execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.readDocumentPaths.isEmpty)
      #expect(backend.readTables.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersTableExportDryRunAndAllowFlagExecutesCSV() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.csv")
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]
    #expect(summary?["sha256"] as? String != nil)
    #expect(FileManager.default.fileExists(atPath: destination.path) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["destinationPath"] as? String == destination.path)
    #expect(executedData?["format"] as? String == "csv")
    #expect(executedData?["exportedRowCount"] as? Int == 3)
    #expect(
      try String(contentsOf: destination, encoding: .utf8)
        == "Category,Amount\nTravel,120\nMeals,80\n")
  }

  @Test func numbersTableExportDryRunAndAllowFlagExecutesTSV() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.tsv")
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "tsv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["format"] as? String == "tsv")
    #expect(summary?["sha256"] as? String != nil)
    #expect(FileManager.default.fileExists(atPath: destination.path) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "tsv",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["destinationPath"] as? String == destination.path)
    #expect(executedData?["format"] as? String == "tsv")
    #expect(executedData?["exportedRowCount"] as? Int == 3)
    #expect(
      try String(contentsOf: destination, encoding: .utf8)
        == "Category\tAmount\nTravel\t120\nMeals\t80\n")
  }

  @Test func numbersTableExportValidatesFormatExtension() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.csv")
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "tsv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected TSV export to require a .tsv destination.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(FileManager.default.fileExists(atPath: destination.path) == false)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersTableExportAllowExecutionUsesCurrentDestination() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.csv")
    let changedDestination = root.appendingPathComponent("Other.csv")
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      changedDestination.path,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(FileManager.default.fileExists(atPath: destination.path) == false)
    #expect(FileManager.default.fileExists(atPath: changedDestination.path))
  }

  @Test func numbersTableExportAllowExecutionUsesCurrentTableContent() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.csv")
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.tableRows[1] = NumbersTableRow(index: 2, values: ["Travel", "999"])

    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(
      try String(contentsOf: destination, encoding: .utf8)
        == "Category,Amount\nTravel,999\nMeals,80\n")
  }

  @Test func numbersTableExportEscapesCSVValues() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.csv")
    let backend = FakeNumbersBackend()
    backend.tableRows = [
      NumbersTableRow(index: 1, values: ["Name", "Note"]),
      NumbersTableRow(index: 2, values: ["Travel, Meals", "He said \"yes\""]),
    ]
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "csv",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(
      try String(contentsOf: destination, encoding: .utf8)
        == "Name,Note\n\"Travel, Meals\",\"He said \"\"yes\"\"\"\n")
  }

  @Test func numbersTableExportEscapesTSVValues() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("Budget.tsv")
    let backend = FakeNumbersBackend()
    backend.tableRows = [
      NumbersTableRow(index: 1, values: ["Name", "Note"]),
      NumbersTableRow(index: 2, values: ["Travel\tMeals", "He said \"yes\""]),
    ]
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "tsv",
      "--to",
      destination.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "export",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--format",
      "tsv",
      "--to",
      destination.path,
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(
      try String(contentsOf: destination, encoding: .utf8)
        == "Name\tNote\n\"Travel\tMeals\"\t\"He said \"\"yes\"\"\"\n")
  }

  @Test func numbersTableSetCellRequiresAllowPersistentActionBeforeLookup() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let options = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Missing.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "2",
      "--column",
      "2",
      "--value",
      "125",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Numbers table cell write execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.readDocumentPaths.isEmpty)
      #expect(backend.readCells.isEmpty)
      #expect(backend.writtenCells.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func numbersTableSetCellDryRunAndAllowFlagExecutesCell() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "2",
      "--column",
      "2",
      "--value",
      "125",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["row"] as? String == "2")
    #expect(summary?["column"] as? String == "2")
    #expect(summary?["value_sha256"] as? String != nil)
    #expect(dryRun.stdout?.contains("125") == false)
    #expect(backend.writtenCells.isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "2",
      "--column",
      "2",
      "--value",
      "125",
      "--allow-persistent-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["changed"] as? Bool == true)
    #expect(executedData?["row"] as? Int == 2)
    #expect(executedData?["column"] as? Int == 2)
    #expect(executed.stdout?.contains("125") == false)
    #expect(backend.tableRows[1].values[1] == "125")
    #expect(backend.writtenCells.count == 1)
  }

  @Test func numbersTableSetCellAllowExecutionUsesCurrentCellContent() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "2",
      "--column",
      "2",
      "--value",
      "125",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.tableRows[1] = NumbersTableRow(index: 2, values: ["Travel", "999"])

    let executeOptions = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "2",
      "--column",
      "2",
      "--value",
      "125",
      "--allow-persistent-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.tableRows[1].values[1] == "125")
    #expect(backend.writtenCells.count == 1)
  }

  @Test func numbersCellWriteReplacesFormulaWithMatchingDisplayValue() throws {
    let backend = FakeNumbersBackend()
    backend.tableRows[1].values[1] = "125"
    backend.cellValueType = .number
    backend.cellRawValue = "125"
    backend.cellFormula = "=120+5"
    let result = try #require(try NumbersCommand(backend: backend, contentBackend: backend).run(
      options: numbersCellWriteOptions("125")))
    let data = try #require(try jsonObject(result.stdout ?? "")["data"] as? [String: Any])

    #expect(backend.writtenCells.count == 1)
    #expect(backend.cellValueType == .text)
    #expect(backend.cellFormula == "")
    #expect(data["changed"] as? Bool == true)
    #expect(data["verified"] as? Bool == true)
  }

  @Test func numbersCellWriteSkipsOnlyMatchingLiteralText() throws {
    let valueTypes: [NumbersCellValueType?] = [.text, .number, .boolean, .date, nil]
    for valueType in valueTypes {
      let backend = FakeNumbersBackend()
      let value = valueType == .boolean ? "false"
        : valueType == .date ? "2021-01-02T03:04:05Z" : "125"
      backend.tableRows[1].values[1] = value
      backend.cellValueType = valueType
      backend.cellRawValue = value
      let result = try #require(try NumbersCommand(backend: backend, contentBackend: backend).run(
        options: numbersCellWriteOptions(value)))
      let data = try #require(try jsonObject(result.stdout ?? "")["data"] as? [String: Any])

      #expect(backend.writtenCells.count == (valueType == .text ? 0 : 1))
      #expect(data["changed"] as? Bool == (valueType != .text))
      #expect(data["verified"] as? Bool == true)
    }
  }

  @Test func numbersCellWriteDoesNotTrustFormattedTextAsActualText() throws {
    let backend = FakeNumbersBackend()
    backend.tableRows[1].values[1] = "125"
    backend.cellValueType = .text
    backend.cellRawValue = "0125"
    _ = try #require(try NumbersCommand(backend: backend, contentBackend: backend).run(
      options: numbersCellWriteOptions("125")))

    #expect(backend.writtenCells.count == 1)
    #expect(backend.cellRawValue == "125")
  }

  @Test func numbersCellWriteFailsIfPersistenceOrReadbackIsUnproven() throws {
    for scenario in ["not-persisted", "formula-retained", "missing-readback", "unknown-metadata"] {
      let backend = FakeNumbersBackend()
      switch scenario {
      case "not-persisted": backend.persistsCellWrites = false
      case "formula-retained":
        backend.cellFormula = "=100+20"
        backend.keepsFormulaAfterWrite = true
      case "missing-readback": backend.readbackIsMissing = true
      default: backend.providesCellMetadata = false
      }
      do {
        _ = try NumbersCommand(backend: backend, contentBackend: backend).run(
          options: numbersCellWriteOptions("125"))
        Issue.record("Unproven Numbers writes must fail: \(scenario).")
      } catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
        #expect(error.details["mutation_may_have_occurred"] == "true")
        #expect(error.details["verification"] == "unconfirmed")
        #expect(backend.writtenCells.count == 1)
      }
    }
  }

  @Test func numbersCellWriteDoesNotRetryAnUnknownOutcome() throws {
    for code in [CLIErrorCode.timeout, .backendUnavailable, .permissionDenied, .unsafeMutationRefused] {
      let backend = FakeNumbersBackend()
      backend.cellWriteError = CLIError(code: code, message: "Fixture failure.")
      do {
        _ = try NumbersCommand(backend: backend, contentBackend: backend).run(
          options: numbersCellWriteOptions("125"))
        Issue.record("A failed cell write must propagate its outcome.")
      } catch let error as CLIError {
        #expect(error.code == code)
        #expect(backend.writtenCells.count == 1)
        if code == .timeout || code == .backendUnavailable {
          #expect(error.details["mutation_may_have_occurred"] == "true")
          #expect(error.details["retry_guidance"] == "inspect_document_before_retrying")
        } else {
          #expect(error.details["mutation_may_have_occurred"] == nil)
        }
      }
    }
  }

  @Test func numbersTableSetCellRejectsFormulaAndOutOfBoundsCell() throws {
    let backend = FakeNumbersBackend()
    let command = NumbersCommand(backend: backend, contentBackend: backend)
    let formulaOptions = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "2",
      "--column",
      "2",
      "--value",
      "=SUM(1, 2)",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: formulaOptions)
      Issue.record("Expected formula-looking Numbers cell value to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    let outOfBoundsOptions = try CLIOptionsFixture.parse([
      "tables",
      "set-cell",
      "--path",
      "/tmp/Budget.numbers",
      "--sheet",
      "Summary",
      "--table",
      "Budget",
      "--row",
      "9",
      "--column",
      "2",
      "--value",
      "125",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: outOfBoundsOptions)
      Issue.record("Expected out-of-bounds Numbers cell to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func fileManagerNumbersBackendListsDirectDocumentsAndPreviewMetadata() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }

    let document = root.appendingPathComponent("Budget.numbers", isDirectory: true)
    let quickLook = document.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: quickLook, withIntermediateDirectories: true)
    FileManager.default.createFile(
      atPath: quickLook.appendingPathComponent("Preview.pdf").path,
      contents: Data("preview".utf8)
    )
    FileManager.default.createFile(
      atPath: root.appendingPathComponent("Notes.txt").path,
      contents: Data("ignore".utf8)
    )

    let backend = FileManagerNumbersBackend()
    let documents = try backend.listDocuments(path: root.path, limit: 10)
    let read = try #require(try backend.readDocument(path: document.path))

    #expect(documents.count == 1)
    #expect(documents.first?.name == "Budget.numbers")
    #expect(read.quickLookPreviewPath?.hasSuffix("Preview.pdf") == true)
  }

  @Test func fileManagerNumbersBackendExportsQuickLookPreviewPDF() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }

    let document = root.appendingPathComponent("Budget.numbers", isDirectory: true)
    let quickLook = document.appendingPathComponent("QuickLook", isDirectory: true)
    try FileManager.default.createDirectory(at: quickLook, withIntermediateDirectories: true)
    let preview = quickLook.appendingPathComponent("Preview.pdf")
    try Data("numbers-preview".utf8).write(to: preview)

    let destination = root.appendingPathComponent("Budget.pdf")
    let backend = FileManagerNumbersBackend()
    let result = try backend.exportDocument(path: document.path, format: "pdf", to: destination.path)

    #expect(result.destinationPath == destination.path)
    #expect(try Data(contentsOf: destination) == Data("numbers-preview".utf8))
  }
}

private final class FakeNumbersBackend: NumbersReading, NumbersExporting, NumbersContentReading,
  NumbersContentWriting, @unchecked Sendable
{
  var exportedDocuments: [(String, String, String)] = []
  var readDocumentPaths: [String] = []
  var readTables: [(String, String, String, Int)] = []
  var readCells: [(String, String, String, Int, Int)] = []
  var writtenCells: [(String, String, String, Int, Int, String)] = []
  var cellValueType: NumbersCellValueType? = .text
  var cellRawValue: String?
  var cellFormula: String? = ""
  var providesCellMetadata = true
  var cellWriteError: CLIError?
  var persistsCellWrites = true
  var keepsFormulaAfterWrite = false
  var readbackIsMissing = false
  var tableRows = [
    NumbersTableRow(index: 1, values: ["Category", "Amount"]),
    NumbersTableRow(index: 2, values: ["Travel", "120"]),
    NumbersTableRow(index: 3, values: ["Meals", "80"]),
  ]

  func listDocuments(path: String, limit: Int) throws -> [NumbersDocumentRecord] {
    documents().prefix(limit).map { $0 }
  }

  func searchDocuments(path: String, query: String, limit: Int) throws -> [NumbersDocumentRecord] {
    documents()
      .filter { $0.name.localizedCaseInsensitiveContains(query) }
      .prefix(limit)
      .map { $0 }
  }

  func readDocument(path: String) throws -> NumbersDocumentRecord? {
    readDocumentPaths.append(path)
    return documents().first { $0.path == path }
  }

  func exportDocument(path: String, format: String, to destinationPath: String) throws
    -> NumbersExportResult
  {
    exportedDocuments.append((path, format, destinationPath))
    return NumbersExportResult(
      operation: "numbers.export",
      changed: true,
      sourcePath: path,
      destinationPath: destinationPath,
      format: format
    )
  }

  func listSheets(path: String) throws -> [NumbersSheetRecord] {
    [
      NumbersSheetRecord(
        index: 1,
        name: "Summary",
        tables: [
          NumbersTableSummary(index: 1, name: "Budget", rowCount: 3, columnCount: 2)
        ]
      ),
      NumbersSheetRecord(
        index: 2,
        name: "Detail",
        tables: [
          NumbersTableSummary(index: 1, name: "Transactions", rowCount: 2, columnCount: 3)
        ]
      ),
    ]
  }

  func readTable(path: String, sheet: String, table: String, limit: Int) throws
    -> NumbersTableRecord?
  {
    readTables.append((path, sheet, table, limit))
    guard path == "/tmp/Budget.numbers", sheet == "Summary", table == "Budget" else {
      return nil
    }

    return NumbersTableRecord(
      sheetName: sheet,
      tableName: table,
      rowCount: tableRows.count,
      columnCount: 2,
      rows: tableRows.prefix(limit).map { $0 }
    )
  }

  func readCell(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> NumbersCellRecord?
  {
    readCells.append((path, sheet, table, row, column))
    if readbackIsMissing && !writtenCells.isEmpty { return nil }
    guard
      path == "/tmp/Budget.numbers",
      sheet == "Summary",
      table == "Budget",
      tableRows.indices.contains(row - 1),
      tableRows[row - 1].values.indices.contains(column - 1)
    else {
      return nil
    }

    return NumbersCellRecord(
      sheetName: sheet,
      tableName: table,
      row: row,
      column: column,
      rowCount: tableRows.count,
      columnCount: 2,
      value: tableRows[row - 1].values[column - 1],
      rawValue: providesCellMetadata ? (cellRawValue ?? tableRows[row - 1].values[column - 1]) : nil,
      valueType: providesCellMetadata ? cellValueType : nil,
      formula: providesCellMetadata ? cellFormula : nil
    )
  }

  func readRange(path: String, sheet: String, table: String, range: String) throws -> [[String]] {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers range and formula operations are not supported by the current CLI contract."
    )
  }

  func getFormula(path: String, sheet: String, table: String, row: Int, column: Int) throws
    -> String
  {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers range and formula operations are not supported by the current CLI contract."
    )
  }

  func setCellText(path: String, sheet: String, table: String, row: Int, column: Int, value: String)
    throws
  {
    writtenCells.append((path, sheet, table, row, column, value))
    if let cellWriteError { throw cellWriteError }
    guard
      path == "/tmp/Budget.numbers",
      sheet == "Summary",
      table == "Budget",
      tableRows.indices.contains(row - 1),
      tableRows[row - 1].values.indices.contains(column - 1)
    else {
      throw CLIError(code: .notFound, message: "Numbers cell was not found.")
    }
    if persistsCellWrites {
      tableRows[row - 1].values[column - 1] = value
      cellRawValue = value
      cellValueType = .text
      if !keepsFormulaAfterWrite { cellFormula = "" }
    }
  }

  func setRangeText(
    path: String, sheet: String, table: String, startRow: Int, startColumn: Int, values: [[String]]
  ) throws {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers range and formula operations are not supported by the current CLI contract."
    )
  }

  func clearRange(path: String, sheet: String, table: String, range: String) throws {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers range and formula operations are not supported by the current CLI contract."
    )
  }

  func setFormula(
    path: String, sheet: String, table: String, row: Int, column: Int, formula: String
  ) throws {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Numbers range and formula operations are not supported by the current CLI contract."
    )
  }

  private func documents() -> [NumbersDocumentRecord] {
    [
      NumbersDocumentRecord(
        path: "/tmp/Budget.numbers",
        name: "Budget.numbers",
        isPackage: true,
        quickLookPreviewPath: "/tmp/Budget.numbers/QuickLook/Preview.pdf"
      ),
      NumbersDocumentRecord(
        path: "/tmp/Other.numbers",
        name: "Other.numbers",
        isPackage: true,
        quickLookPreviewPath: "/tmp/Other.numbers/QuickLook/Preview.pdf"
      ),
    ]
  }
}

private final class FakeNumbersActions: NumbersExternalActioning, @unchecked Sendable {
  var openedPaths: [String] = []

  func open(path: String) throws -> Bool {
    openedPaths.append(path)
    return true
  }
}

private func temporaryDirectory() throws -> URL {
  let url = FileManager.default.temporaryDirectory.appendingPathComponent(
    UUID().uuidString, isDirectory: true)
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw NumbersCommandTestError.notObject
  }
  return object
}

private func numbersCellWriteOptions(_ value: String) throws -> CLIOptions {
  try CLIOptionsFixture.parse([
    "tables", "set-cell", "--path", "/tmp/Budget.numbers", "--sheet", "Summary", "--table", "Budget",
    "--row", "2", "--column", "2", "--value", value, "--allow-persistent-action", "--json",
  ])
}

private enum NumbersCommandTestError: Error {
  case notObject
}
