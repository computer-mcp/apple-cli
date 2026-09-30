import FinderCLI
import Foundation
import Testing
import Utility

@Suite
struct FinderCommandTests {
  @Test func finderItemsListReturnsJSON() throws {
    let command = FinderCommand(backend: FakeFinderBackend())
    let options = try CLIOptionsFixture.parse(["items", "list", "--path", "/tmp/example", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = data?["items"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(items?.first?["name"] as? String == "Project")
  }

  @Test func finderSearchRequiresNonTrivialQuery() throws {
    let command = FinderCommand(backend: FakeFinderBackend())
    let options = try CLIOptionsFixture.parse([
      "items", "search", "--path", "/tmp/example", "--query", "a", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short Finder query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderMetadataMissingPathReturnsNotFound() throws {
    let command = FinderCommand(backend: FakeFinderBackend())
    let options = try CLIOptionsFixture.parse([
      "items", "metadata", "--path", "/tmp/missing", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing Finder item to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderReadOnlyCommandsRejectDryRuns() throws {
    let command = FinderCommand(backend: FakeFinderBackend())
    let options = try CLIOptionsFixture.parse([
      "items",
      "list",
      "--path",
      "/tmp/example",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only Finder command to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderOpenRequiresAllowExternalDispatch() throws {
    let actions = FakeFinderActions()
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: actions)
    let options = try CLIOptionsFixture.parse([
      "items", "open", "--path", "/tmp/example/Project", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder open execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderOpenDryRunAndAllowFlagExecutesPath() throws {
    let actions = FakeFinderActions()
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items", "open", "--path", "/tmp/example/Project", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "open",
      "--path",
      "/tmp/example/Project",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["submitted"] as? Bool == true)
    #expect(actions.openedPaths == ["/tmp/example/Project"])
  }

  @Test func finderRevealAllowExecutionUsesCurrentPath() throws {
    let actions = FakeFinderActions()
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items", "reveal", "--path", "/tmp/example/Project", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "items",
      "reveal",
      "--path",
      "/tmp/example/Other",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
    #expect(actions.revealedPaths == ["/tmp/example/Other"])
  }

  @Test func finderMoveRequiresAllowArtifactAction() throws {
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items",
      "move",
      "--path",
      "/tmp/example/Other",
      "--to",
      "/tmp/example/Moved",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder move execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderMoveDryRunAndAllowFlagExecutesDestination() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "move",
      "--path",
      "/tmp/example/Other",
      "--to",
      "/tmp/example/Moved",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "move",
      "--path",
      "/tmp/example/Other",
      "--to",
      "/tmp/example/Moved",
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["destinationPath"] as? String == "/tmp/example/Moved")
    #expect(
      backend.movedItems.map { "\($0.0)->\($0.1)" } == ["/tmp/example/Other->/tmp/example/Moved"])
  }

  @Test func finderMoveAllowExecutionUsesCurrentDestination() throws {
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "move",
      "--path",
      "/tmp/example/Other",
      "--to",
      "/tmp/example/Moved",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "items",
      "move",
      "--path",
      "/tmp/example/Other",
      "--to",
      "/tmp/example/Different",
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
  }

  @Test func finderTagsSetDryRunAndAllowFlagExecutesTags() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "tags",
      "set",
      "--path",
      "/tmp/example/Other",
      "--tags",
      "Work,Important",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "tags",
      "set",
      "--path",
      "/tmp/example/Other",
      "--tags",
      "Work,Important",
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let item = executedData?["item"] as? [String: Any]

    #expect(item?["tags"] as? [String] == ["Work", "Important"])
    #expect(backend.taggedItems == ["/tmp/example/Other": ["Work", "Important"]])
  }

  @Test func finderTagsAllowExecutionUsesCurrentTags() throws {
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "tags",
      "add",
      "--path",
      "/tmp/example/Other",
      "--tags",
      "Blue",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "items",
      "tags",
      "add",
      "--path",
      "/tmp/example/Other",
      "--tags",
      "Green",
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
  }

  @Test func finderTrashDryRunAndAllowFlagExecutesItem() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items", "trash", "--path", "/tmp/example/Other", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "trash",
      "--path",
      "/tmp/example/Other",
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["changed"] as? Bool == true)
    #expect(backend.trashedItems == ["/tmp/example/Other"])
  }

  @Test func finderDeleteRequiresAllowArtifactActionBeforePathLookup() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items",
      "delete",
      "--path",
      "/tmp/example/Other",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder delete execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.deletedFiles.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderDeleteDryRunAndAllowFlagExecutesFile() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items", "delete", "--path", "/tmp/example/Other", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: String]

    #expect(summary?["path"] == "/tmp/example/Other")
    #expect(summary?["item_type"] == "regular_file")
    #expect(summary?["permanent"] == "true")

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "delete",
      "--path",
      "/tmp/example/Other",
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "finder.delete_file")
    #expect(executedData?["changed"] as? Bool == true)
    #expect(backend.deletedFiles == ["/tmp/example/Other"])
  }

  @Test func finderDeleteAllowExecutionUsesCurrentFileIdentity() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items", "delete", "--path", "/tmp/example/Other", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    backend.taggedItems["/tmp/example/Other"] = ["Drifted"]

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "delete",
      "--path",
      "/tmp/example/Other",
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))
    #expect(backend.deletedFiles == ["/tmp/example/Other"])
  }

  @Test func finderDeleteRejectsDirectories() throws {
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items", "delete", "--path", "/tmp/example/Project", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder delete directory to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderDeleteRejectsRecursiveFlagBeforeLookup() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items",
      "delete",
      "--path",
      "/tmp/example/Project",
      "--recursive",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder recursive delete flag to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(backend.metadataReads.isEmpty)
      #expect(backend.deletedFiles.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderWriteTextRequiresAllowArtifactActionBeforePathLookup() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items",
      "write-text",
      "--path",
      "/tmp/example/New.txt",
      "--text",
      "Private body",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder write-text execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.writtenText.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderWriteTextDryRunAndAllowFlagExecutesContent() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "write-text",
      "--path",
      "/tmp/example/New.txt",
      "--text",
      "Private body",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: String]

    #expect(summary?["path"] == "/tmp/example/New.txt")
    #expect(summary?["content_bytes"] == "12")
    #expect(summary?["overwrite"] == "false")
    #expect(summary?.values.contains("Private body") == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "write-text",
      "--path",
      "/tmp/example/New.txt",
      "--text",
      "Private body",
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let item = executedData?["item"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "finder.write_text")
    #expect(item?["path"] as? String == "/tmp/example/New.txt")
    #expect(backend.writtenText == ["/tmp/example/New.txt": "Private body"])
  }

  @Test func finderWriteTextAllowExecutionUsesCurrentContent() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "write-text",
      "--path",
      "/tmp/example/New.txt",
      "--text",
      "Original body",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedOptions = try CLIOptionsFixture.parse([
      "items",
      "write-text",
      "--path",
      "/tmp/example/New.txt",
      "--text",
      "Changed body",
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedOptions))
    #expect(backend.writtenText == ["/tmp/example/New.txt": "Changed body"])
  }

  @Test func finderOverwriteTextRequiresAllowArtifactActionBeforePathLookup() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Other",
      "--text",
      "Replacement",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder overwrite-text execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.overwrittenText.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderOverwriteTextDryRunAndAllowFlagExecutesContent() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Other",
      "--text",
      "Replacement",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: String]

    #expect(summary?["path"] == "/tmp/example/Other")
    #expect(summary?["content_bytes"] == "11")
    #expect(summary?["overwrite"] == "true")
    #expect(summary?.values.contains("Replacement") == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Other",
      "--text",
      "Replacement",
      "--allow-artifact-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let item = executedData?["item"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "finder.overwrite_text")
    #expect(item?["path"] as? String == "/tmp/example/Other")
    #expect(backend.overwrittenText == ["/tmp/example/Other": "Replacement"])
  }

  @Test func finderOverwriteTextAllowExecutionUsesCurrentContentOrIdentity() throws {
    let backend = FakeFinderBackend()
    let command = FinderCommand(backend: backend, externalActions: FakeFinderActions())
    let dryRunOptions = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Other",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let changedContentOptions = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Other",
      "--text",
      "Changed",
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedContentOptions))
    #expect(backend.overwrittenText == ["/tmp/example/Other": "Changed"])

    backend.taggedItems["/tmp/example/Other"] = ["Drifted"]
    let changedIdentityOptions = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Other",
      "--text",
      "Original",
      "--allow-artifact-action",
      "--json",
    ])

    _ = try #require(try command.run(options: changedIdentityOptions))
    #expect(backend.overwrittenText == ["/tmp/example/Other": "Original"])
  }

  @Test func finderOverwriteTextRejectsDirectories() throws {
    let command = FinderCommand(backend: FakeFinderBackend(), externalActions: FakeFinderActions())
    let options = try CLIOptionsFixture.parse([
      "items",
      "overwrite-text",
      "--path",
      "/tmp/example/Project",
      "--text",
      "Replacement",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Finder overwrite-text directory to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func finderBackendListsDirectChildrenWithoutReadingContent() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let file = root.appendingPathComponent("Project.txt")
    let hidden = root.appendingPathComponent(".hidden")
    try "private file body".write(to: file, atomically: true, encoding: .utf8)
    try "hidden".write(to: hidden, atomically: true, encoding: .utf8)

    let backend = FileManagerFinderBackend()
    let items = try backend.listItems(path: root.path, includeHidden: false, limit: 10)

    #expect(items.map(\.name) == ["Project.txt"])
    #expect(items.first?.isRegularFile == true)
    #expect(items.first?.size == Int64("private file body".utf8.count))
  }

  @Test func finderBackendSearchesBoundedDirectChildren() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    try "one".write(to: root.appendingPathComponent("Alpha.txt"), atomically: true, encoding: .utf8)
    try "two".write(to: root.appendingPathComponent("Beta.txt"), atomically: true, encoding: .utf8)

    let backend = FileManagerFinderBackend()
    let items = try backend.searchItems(
      path: root.path, query: "alp", includeHidden: false, limit: 10)

    #expect(items.map(\.name) == ["Alpha.txt"])
  }

  @Test func fileManagerFinderBackendMovesItemWithinTemporaryDirectory() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let source = root.appendingPathComponent("Source.txt")
    let destination = root.appendingPathComponent("Moved.txt")
    try "temporary".write(to: source, atomically: true, encoding: .utf8)

    let backend = FileManagerFinderBackend()
    let moved = try backend.moveItem(path: source.path, to: destination.path)

    #expect(moved.path == destination.path)
    #expect(FileManager.default.fileExists(atPath: source.path) == false)
    #expect(FileManager.default.fileExists(atPath: destination.path) == true)
  }

  @Test func fileManagerFinderBackendSetsFinderTagsOnTemporaryFile() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let file = root.appendingPathComponent("Tagged.txt")
    try "temporary".write(to: file, atomically: true, encoding: .utf8)

    let backend = FileManagerFinderBackend()
    let tagged = try backend.setTags(path: file.path, tags: ["Blue", "Important"])

    #expect(tagged.tags == ["Blue", "Important"])
  }

  @Test func fileManagerFinderBackendWritesTextFileWithoutOverwriting() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let file = root.appendingPathComponent("Created.txt")
    let backend = FileManagerFinderBackend()
    let created = try backend.writeTextFile(path: file.path, text: "temporary text")

    #expect(created.path == file.path)
    #expect(created.isRegularFile == true)
    #expect(try String(contentsOf: file, encoding: .utf8) == "temporary text")

    do {
      _ = try backend.writeTextFile(path: file.path, text: "replacement")
      Issue.record("Expected Finder text write to reject existing destination.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func fileManagerFinderBackendDeletesOnlyRegularFiles() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let file = root.appendingPathComponent("DeleteMe.txt")
    let directory = root.appendingPathComponent("Directory")
    let linkTarget = root.appendingPathComponent("Target.txt")
    let symlink = root.appendingPathComponent("Link.txt")
    try "temporary".write(to: file, atomically: true, encoding: .utf8)
    try "target".write(to: linkTarget, atomically: true, encoding: .utf8)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: linkTarget)

    let backend = FileManagerFinderBackend()
    let deleted = try backend.deleteFile(path: file.path)

    #expect(deleted == true)
    #expect(FileManager.default.fileExists(atPath: file.path) == false)

    do {
      _ = try backend.deleteFile(path: directory.path)
      Issue.record("Expected Finder file delete to reject directories.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    do {
      _ = try backend.deleteFile(path: symlink.path)
      Issue.record("Expected Finder file delete to reject symlinks.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(FileManager.default.fileExists(atPath: linkTarget.path) == true)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func fileManagerFinderBackendOverwritesOnlyRegularTextFiles() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let file = root.appendingPathComponent("Existing.txt")
    let directory = root.appendingPathComponent("Directory")
    let linkTarget = root.appendingPathComponent("Target.txt")
    let symlink = root.appendingPathComponent("Link.txt")
    try "old".write(to: file, atomically: true, encoding: .utf8)
    try "target".write(to: linkTarget, atomically: true, encoding: .utf8)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: linkTarget)

    let backend = FileManagerFinderBackend()
    let overwritten = try backend.overwriteTextFile(path: file.path, text: "new")

    #expect(overwritten.path == file.path)
    #expect(overwritten.isRegularFile == true)
    #expect(try String(contentsOf: file, encoding: .utf8) == "new")

    do {
      _ = try backend.overwriteTextFile(path: directory.path, text: "replacement")
      Issue.record("Expected Finder text overwrite to reject directories.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    do {
      _ = try backend.overwriteTextFile(path: symlink.path, text: "replacement")
      Issue.record("Expected Finder text overwrite to reject symlinks.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(try String(contentsOf: linkTarget, encoding: .utf8) == "target")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private final class FakeFinderBackend: FinderReading, FinderMutating, @unchecked Sendable {
  var metadataReads: [String] = []
  var movedItems: [(String, String)] = []
  var trashedItems: [String] = []
  var deletedFiles: [String] = []
  var taggedItems: [String: [String]] = [:]
  var writtenText: [String: String] = [:]
  var overwrittenText: [String: String] = [:]

  func listItems(path: String, includeHidden: Bool, limit: Int) throws -> [FinderItemRecord] {
    finderItems().prefix(limit).map { $0 }
  }

  func searchItems(path: String, query: String, includeHidden: Bool, limit: Int) throws
    -> [FinderItemRecord]
  {
    finderItems()
      .filter { $0.name.localizedCaseInsensitiveContains(query) }
      .prefix(limit)
      .map { $0 }
  }

  func readMetadata(path: String) throws -> FinderItemRecord? {
    metadataReads.append(path)
    guard path != "/tmp/missing" else {
      return nil
    }
    if path == "/tmp/example" {
      return FinderItemRecord(
        path: "/tmp/example",
        name: "example",
        isDirectory: true,
        isRegularFile: false,
        isSymbolicLink: false
      )
    }
    if let text = writtenText[path] {
      return FinderItemRecord(
        path: path,
        name: URL(fileURLWithPath: path).lastPathComponent,
        isDirectory: false,
        isRegularFile: true,
        isSymbolicLink: false,
        size: Int64(text.utf8.count)
      )
    }
    if let text = overwrittenText[path] {
      return FinderItemRecord(
        path: path,
        name: URL(fileURLWithPath: path).lastPathComponent,
        isDirectory: false,
        isRegularFile: true,
        isSymbolicLink: false,
        size: Int64(text.utf8.count),
        tags: taggedItems[path] ?? []
      )
    }
    if var item = finderItems().first(where: { $0.path == path }) {
      item.tags = taggedItems[path] ?? item.tags
      return item
    }
    return nil
  }

  func moveItem(path: String, to destinationPath: String) throws -> FinderItemRecord {
    movedItems.append((path, destinationPath))
    return FinderItemRecord(
      path: destinationPath,
      name: URL(fileURLWithPath: destinationPath).lastPathComponent,
      isDirectory: false,
      isRegularFile: true,
      isSymbolicLink: false,
      tags: taggedItems[path] ?? []
    )
  }

  func trashItem(path: String) throws -> Bool {
    trashedItems.append(path)
    return true
  }

  func deleteFile(path: String) throws -> Bool {
    deletedFiles.append(path)
    return true
  }

  func setTags(path: String, tags: [String]) throws -> FinderItemRecord {
    taggedItems[path] = tags
    guard var item = try readMetadata(path: path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }
    item.tags = tags
    return item
  }

  func writeTextFile(path: String, text: String) throws -> FinderItemRecord {
    guard try readMetadata(path: path) == nil else {
      throw CLIError(
        code: .validationError, message: "Destination path already exists.", details: ["path": path]
      )
    }
    writtenText[path] = text
    return FinderItemRecord(
      path: path,
      name: URL(fileURLWithPath: path).lastPathComponent,
      isDirectory: false,
      isRegularFile: true,
      isSymbolicLink: false,
      size: Int64(text.utf8.count)
    )
  }

  func overwriteTextFile(path: String, text: String) throws -> FinderItemRecord {
    guard var item = try readMetadata(path: path) else {
      throw CLIError(
        code: .notFound, message: "Finder item was not found.", details: ["path": path])
    }
    guard item.isRegularFile, !item.isDirectory, !item.isSymbolicLink else {
      throw CLIError(
        code: .validationError,
        message: "`items overwrite-text` only supports single regular files.",
        details: ["path": path])
    }
    overwrittenText[path] = text
    item.size = Int64(text.utf8.count)
    return item
  }

  private func finderItems() -> [FinderItemRecord] {
    [
      FinderItemRecord(
        path: "/tmp/example/Project",
        name: "Project",
        isDirectory: true,
        isRegularFile: false,
        isSymbolicLink: false
      ),
      FinderItemRecord(
        path: "/tmp/example/Other",
        name: "Other",
        isDirectory: false,
        isRegularFile: true,
        isSymbolicLink: false
      ),
    ]
  }
}

private final class FakeFinderActions: FinderExternalActioning, @unchecked Sendable {
  var openedPaths: [String] = []
  var revealedPaths: [String] = []

  func open(path: String) throws -> Bool {
    openedPaths.append(path)
    return true
  }

  func reveal(path: String) throws -> Bool {
    revealedPaths.append(path)
    return true
  }
}

private func temporaryDirectory() throws -> URL {
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-finder-tests")
    .appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw FinderCommandTestError.notObject
  }
  return object
}

private enum FinderCommandTestError: Error {
  case notObject
}
