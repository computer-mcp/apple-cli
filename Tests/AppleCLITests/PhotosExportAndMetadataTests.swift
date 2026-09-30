import CoreGraphics
import Darwin
import Foundation
import ImageIO
import PhotosCLI
import SQLite3
import Testing
import UniformTypeIdentifiers
import Utility

@Suite
struct PhotosExportAndMetadataTests {
  @Test func photosExportCopiesSnapshotOriginalsAndWritesReport() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export", isDirectory: true)
    let stateDB = fixture.root.appendingPathComponent("export-state.json")
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--destination", destination.path,
          "--state-db", stateDB.path,
          "--dry-run",
          "--json",
        ])))

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--destination", destination.path,
          "--state-db", stateDB.path,
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["exported"] as? Int == 2)
    #expect(data?["missing"] as? Int == 0)
    #expect(Set(data?["exportedUUIDs"] as? [String] ?? []) == Set(["asset-1", "asset-2"]))
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0001.JPG").path))
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0002.JPG").path))
    #expect(
      FileManager.default.fileExists(
        atPath: destination.appendingPathComponent("IMG_0002_edited.jpeg").path))
    #expect(
      FileManager.default.fileExists(
        atPath: destination.appendingPathComponent("IMG_0002_4.DNG").path))
    #expect(
      FileManager.default.fileExists(
        atPath: destination.appendingPathComponent("photos-export-report.json").path))
    #expect(FileManager.default.fileExists(atPath: stateDB.path))

    let report = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "report", "--state-db", stateDB.path, "--json",
        ])))
    let reportObject = try photosTestJSONObject(report.stdout ?? "")
    let reportData = reportObject["data"] as? [String: Any]
    let firstRunID = try #require(reportData?["runID"] as? String)
    #expect(firstRunID.isEmpty == false)
    #expect(reportData?["exported"] as? Int == 2)
    #expect(reportData?["skipped"] as? Int == 0)
    #expect(reportData?["missing"] as? Int == 0)
    #expect((reportData?["errors"] as? [String]) == [])

    let secondDestination = fixture.root.appendingPathComponent("export-second", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", secondDestination.path,
          "--state-db", stateDB.path,
          "--dry-run",
          "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", secondDestination.path,
          "--state-db", stateDB.path,
          "--allow-external-dispatch", "--json",
        ])))

    let stateObject = try photosTestJSONObject(
      String(contentsOf: stateDB, encoding: .utf8)
    )
    let runs = stateObject["runs"] as? [[String: Any]]
    #expect(stateObject["schemaVersion"] as? Int == 1)
    #expect(runs?.count == 2)
    #expect(stateObject["lastRunID"] as? String == runs?.last?["runID"] as? String)

    let firstReport = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "report", "--state-db", stateDB.path, "--run-id", firstRunID, "--json",
        ])))
    let firstReportObject = try photosTestJSONObject(firstReport.stdout ?? "")
    let firstReportData = firstReportObject["data"] as? [String: Any]
    #expect(firstReportData?["runID"] as? String == firstRunID)
    #expect(firstReportData?["exported"] as? Int == 2)

    let latestReport = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "report", "--state-db", stateDB.path, "--json",
        ])))
    let latestObject = try photosTestJSONObject(latestReport.stdout ?? "")
    let latestData = latestObject["data"] as? [String: Any]
    #expect(latestData?["runID"] as? String == runs?.last?["runID"] as? String)
    #expect(latestData?["exported"] as? Int == 1)
  }

  @Test func photosExportRunsStrongGatedPostLifecycleHooks() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-post-hooks", isDirectory: true)
    let functionMarker = fixture.root.appendingPathComponent("post-function.txt")
    let commandMarker = fixture.root.appendingPathComponent("post-command.json")
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let functionMarkerLiteral = try photosSwiftStringLiteral(functionMarker.path)
    let source = """
      import Foundation

      struct Photo: Codable {
        var uuid: String
      }

      struct ExportPlan: Codable {
        var destination: String
      }

      struct Input: Codable {
        var category: String
        var photos: [Photo]
        var exportPlan: ExportPlan?
        var context: [String: String]
      }

      struct Output: Codable {
        var accepted: Bool
        var values: [String: String]
        var messages: [String]
      }

      let input = try JSONDecoder().decode(
        Input.self,
        from: FileHandle.standardInput.readDataToEndOfFile()
      )
      let marker = [
        input.category,
        input.photos.map(\\.uuid).joined(separator: ","),
        input.context["exported"] ?? "",
        input.exportPlan?.destination ?? ""
      ].joined(separator: "|")
      try marker.write(
        to: URL(fileURLWithPath: \(functionMarkerLiteral)),
        atomically: true,
        encoding: .utf8
      )
      let output = Output(
        accepted: true,
        values: ["exported": input.context["exported"] ?? ""],
        messages: []
      )
      FileHandle.standardOutput.write(try JSONEncoder().encode(output))
      """
    let postCommand = "cat > \(photosShellQuote(commandMarker.path))"

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--source", source,
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--source", source,
          "--command", postCommand,
          "--category", "export",
          "--allow-eval",
          "--allow-post-command",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["post_function_source_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["post_command_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["post_timeout_seconds"] as? String == "10")
    #expect(summary?["post_output_cap"] as? String == "65536")

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--source", source,
          "--command", postCommand,
          "--category", "export",
          "--allow-eval",
          "--allow-post-command",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))

    let functionText = try String(contentsOf: functionMarker, encoding: .utf8)
    #expect(functionText == "export|asset-1|1|\(destination.path)")
    let commandText = try String(contentsOf: commandMarker, encoding: .utf8)
    #expect(commandText.contains(#""category":"export""#))
    #expect(commandText.contains(#""exported":"1""#))
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0001.JPG").path)
    )
  }

  @Test func photosExportCleanupDeletesStaleFilesAndHonorsKeepRules() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-cleanup", isDirectory: true)
    let staleFile = destination.appendingPathComponent("old.txt")
    let nestedDirectory = destination.appendingPathComponent("nested", isDirectory: true)
    let nestedStaleFile = nestedDirectory.appendingPathComponent("remove.txt")
    let keepFile = destination.appendingPathComponent("keep.txt")
    let manualKeepFile = destination.appendingPathComponent("manual.keep")
    let dotFile = destination.appendingPathComponent(".osxphotos_keep")
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    try FileManager.default.createDirectory(at: nestedDirectory, withIntermediateDirectories: true)
    try "old".write(to: staleFile, atomically: true, encoding: .utf8)
    try "nested".write(to: nestedStaleFile, atomically: true, encoding: .utf8)
    try "keep.txt\n".write(to: dotFile, atomically: true, encoding: .utf8)
    try "keep".write(to: keepFile, atomically: true, encoding: .utf8)
    try "manual".write(to: manualKeepFile, atomically: true, encoding: .utf8)

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--cleanup",
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--cleanup",
          "--allow-cleanup",
          "--keep", "manual.keep",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect(summary?["cleanup"] as? String == "true")
    #expect((summary?["cleanup_keep_sha256"] as? String)?.isEmpty == false)
    let expectedStalePath = photosResolvedPath(staleFile)
    let expectedNestedStalePath = photosResolvedPath(nestedStaleFile)
    let expectedNestedDirectoryPath = photosResolvedPath(nestedDirectory)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--cleanup",
          "--allow-cleanup",
          "--keep", "manual.keep",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let cleanup = data?["cleanup"] as? [String: Any]
    let deletedFiles = cleanup?["deletedFiles"] as? [String]
    let deletedDirectories = cleanup?["deletedDirectories"] as? [String]

    #expect(data?["exported"] as? Int == 1)
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0001.JPG").path)
    )
    #expect(FileManager.default.fileExists(atPath: staleFile.path) == false)
    #expect(FileManager.default.fileExists(atPath: nestedStaleFile.path) == false)
    #expect(FileManager.default.fileExists(atPath: nestedDirectory.path) == false)
    #expect(FileManager.default.fileExists(atPath: keepFile.path))
    #expect(FileManager.default.fileExists(atPath: manualKeepFile.path))
    #expect(FileManager.default.fileExists(atPath: dotFile.path))
    #expect(deletedFiles?.contains(expectedStalePath) == true)
    #expect(deletedFiles?.contains(expectedNestedStalePath) == true)
    #expect(deletedDirectories?.contains(expectedNestedDirectoryPath) == true)
  }

  @Test func photosExportCleanupCommandRunsBeforeCleanup() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-cleanup-command", isDirectory: true)
    let staleFile = destination.appendingPathComponent("stale-command.txt")
    let marker = fixture.root.appendingPathComponent("cleanup-command.log")
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let cleanupCommand =
      "printf '%s\\n' {filepath|shell_quote} >> \(photosShellQuote(marker.path))"

    try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
    try "stale".write(to: staleFile, atomically: true, encoding: .utf8)

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--cleanup-command", cleanupCommand,
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--cleanup",
          "--allow-cleanup",
          "--cleanup-command", cleanupCommand,
          "--allow-post-command",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["cleanup_command_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["post_timeout_seconds"] as? String == "10")
    #expect(summary?["post_output_cap"] as? String == "65536")
    let expectedStalePath = photosResolvedPath(staleFile)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--cleanup",
          "--allow-cleanup",
          "--cleanup-command", cleanupCommand,
          "--allow-post-command",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let cleanup = data?["cleanup"] as? [String: Any]
    let commandRuns = cleanup?["commandRuns"] as? [[String: Any]]
    let firstRun = try #require(commandRuns?.first)
    let markerContents = try String(contentsOf: marker, encoding: .utf8)

    #expect(FileManager.default.fileExists(atPath: staleFile.path) == false)
    #expect(markerContents.contains(expectedStalePath))
    #expect(firstRun["path"] as? String == expectedStalePath)
    #expect(firstRun["exitCode"] as? Int == 0)
    #expect((firstRun["command"] as? String)?.contains(photosShellQuote(expectedStalePath)) == true)
  }

  @Test func photosExportWritesExifMetadataToExportedResourcesBehindStrongGate() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-exiftool", isDirectory: true)
    let marker = fixture.root.appendingPathComponent("export-exiftool-args.txt")
    let exiftool = try makePhotosFakeExiftool(root: fixture.root, marker: marker)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["metadata_fields_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["metadata_exiftool_path_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["post_timeout_seconds"] as? String == "10")
    #expect(summary?["post_output_cap"] as? String == "65536")

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let metadataWrites = data?["metadataWrites"] as? [[String: Any]]
    let firstWrite = try #require(metadataWrites?.first)
    let exportedPath = destination.appendingPathComponent("IMG_0001.JPG").path
    let markerContents = try String(contentsOf: marker, encoding: .utf8)

    #expect(firstWrite["path"] as? String == exportedPath)
    #expect(firstWrite["exitCode"] as? Int == 0)
    #expect((firstWrite["fields"] as? [String]) == ["XMP:Title=Beach"])
    #expect(markerContents.contains("-XMP:Title=Beach"))
    #expect(markerContents.contains("-overwrite_original"))
    #expect(markerContents.contains(exportedPath))
  }

  @Test func photosExportWritesFinderTagsAndXattrsToExportedResourcesBehindStrongGate() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-file-metadata", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--finder-tag-template", "{keywords}",
          "--xattr-template", "org.apple-cli.title={title}",
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--finder-tag-template", "{keywords}",
          "--xattr-template", "org.apple-cli.title={title}",
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["metadata_finder_tag_templates_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["metadata_xattr_templates_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["post_timeout_seconds"] as? String == "10")
    #expect(summary?["post_output_cap"] as? String == "65536")

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--using-originals",
          "--finder-tag-template", "{keywords}",
          "--xattr-template", "org.apple-cli.title={title}",
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let exportedFile = destination.appendingPathComponent("IMG_0001.JPG")
    let fileMetadataWrites = data?["fileMetadataWrites"] as? [[String: Any]]
    let firstWrite = try #require(fileMetadataWrites?.first)

    #expect(firstWrite["path"] as? String == exportedFile.path)
    #expect(firstWrite["resourceKind"] as? String == "original")
    #expect(firstWrite["finderTags"] as? [String] == ["travel", "beach"])
    #expect(firstWrite["xattrs"] as? [String] == ["org.apple-cli.title"])

    let title = String(
      data: try photosReadXattr(path: exportedFile.path, name: "org.apple-cli.title"),
      encoding: .utf8
    )
    #expect(title == "Beach")

    let tagData = try photosReadXattr(
      path: exportedFile.path,
      name: "com.apple.metadata:_kMDItemUserTags"
    )
    let finderTagValues =
      try PropertyListSerialization.propertyList(from: tagData, options: [], format: nil) as? [String]
    #expect(finderTagValues == ["travel\n0", "beach\n0"])
  }

  @Test func photosExportStateAppliesUpdateOnlyNewForceUpdateAndSignatures() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-stateful", isDirectory: true)
    let stateDB = fixture.root.appendingPathComponent("export-stateful.json")
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    func executedExport(_ extraArguments: [String]) throws -> [String: Any] {
      let commonArguments =
        [
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
        ] + extraArguments
      _ = try #require(
        try command.run(
          options: CLIOptionsFixture.parse(commonArguments + ["--dry-run", "--json"])))
      let executed = try #require(
        try command.run(
          options: CLIOptionsFixture.parse(
            commonArguments + ["--allow-external-dispatch", "--json"])))
      let object = try photosTestJSONObject(executed.stdout ?? "")
      return try #require(object["data"] as? [String: Any])
    }

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--update",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--state-db", stateDB.path,
          "--only-new",
          "--dry-run",
          "--json",
        ]))
    }

    let first = try executedExport(["--state-db", stateDB.path])
    let exportedFile = destination.appendingPathComponent("IMG_0001.JPG")
    let firstExportedContents = try String(contentsOf: exportedFile, encoding: .utf8)
    #expect(first["exported"] as? Int == 1)
    #expect(firstExportedContents == "one")

    let initialState = try photosTestJSONObject(String(contentsOf: stateDB, encoding: .utf8))
    let initialRuns = try #require(initialState["runs"] as? [[String: Any]])
    let initialResources = try #require(initialRuns.first?["resources"] as? [[String: Any]])
    #expect(initialResources.count == 1)
    #expect(initialResources.first?["uuid"] as? String == "asset-1")
    #expect(initialResources.first?["kind"] as? String == "original")

    let unchangedUpdate = try executedExport(["--state-db", stateDB.path, "--update"])
    #expect(unchangedUpdate["exported"] as? Int == 0)
    #expect(unchangedUpdate["skipped"] as? Int == 1)

    try "user-edited".write(to: exportedFile, atomically: true, encoding: .utf8)
    let destinationSignatureUpdate = try executedExport(["--state-db", stateDB.path, "--update"])
    let destinationSignatureContents = try String(contentsOf: exportedFile, encoding: .utf8)
    #expect(destinationSignatureUpdate["exported"] as? Int == 1)
    #expect(destinationSignatureContents == "one")

    try "user-edited".write(to: exportedFile, atomically: true, encoding: .utf8)
    let ignoredSignatureUpdate = try executedExport([
      "--state-db", stateDB.path, "--update", "--ignore-signature",
    ])
    let ignoredSignatureContents = try String(contentsOf: exportedFile, encoding: .utf8)
    #expect(ignoredSignatureUpdate["exported"] as? Int == 0)
    #expect(ignoredSignatureUpdate["skipped"] as? Int == 1)
    #expect(ignoredSignatureContents == "user-edited")

    let onlyNew = try executedExport(["--state-db", stateDB.path, "--update", "--only-new"])
    #expect(onlyNew["exported"] as? Int == 0)
    #expect(onlyNew["skipped"] as? Int == 1)

    let sourceFile = fixture.originals.appendingPathComponent("IMG_0001.JPG")
    try "source-changed".write(to: sourceFile, atomically: true, encoding: .utf8)
    let sourceSignatureUpdate = try executedExport(["--state-db", stateDB.path, "--update"])
    let sourceSignatureContents = try String(contentsOf: exportedFile, encoding: .utf8)
    #expect(sourceSignatureUpdate["exported"] as? Int == 1)
    #expect(sourceSignatureContents == "source-changed")

    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      """
      UPDATE ZASSET SET ZTITLE = 'Changed Beach' WHERE ZUUID = 'asset-1';
      UPDATE ZADDITIONALASSETATTRIBUTES SET ZTITLE = 'Changed Beach' WHERE ZASSET = 1;
      """
    )

    let metadataChangeWithoutForce = try executedExport(["--state-db", stateDB.path, "--update"])
    #expect(metadataChangeWithoutForce["exported"] as? Int == 0)
    #expect(metadataChangeWithoutForce["skipped"] as? Int == 1)
    let metadataChangeWithForce = try executedExport([
      "--state-db", stateDB.path, "--force-update",
    ])
    #expect(metadataChangeWithForce["exported"] as? Int == 1)

    let templatedStateDB = fixture.root.appendingPathComponent("export-template-state.json")
    let templatedDestination = fixture.root.appendingPathComponent(
      "export-template-stateful",
      isDirectory: true
    )
    func executedTemplatedExport(_ extraArguments: [String]) throws -> [String: Any] {
      let commonArguments =
        [
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", templatedDestination.path,
          "--signature-template", "{uuid}",
        ] + extraArguments
      _ = try #require(
        try command.run(
          options: CLIOptionsFixture.parse(commonArguments + ["--dry-run", "--json"])))
      let executed = try #require(
        try command.run(
          options: CLIOptionsFixture.parse(
            commonArguments + ["--allow-external-dispatch", "--json"])))
      let object = try photosTestJSONObject(executed.stdout ?? "")
      return try #require(object["data"] as? [String: Any])
    }

    _ = try executedTemplatedExport(["--state-db", templatedStateDB.path])
    try photosTestSQLiteExec(
      handle,
      """
      UPDATE ZASSET SET ZTITLE = 'Template Ignored Title' WHERE ZUUID = 'asset-1';
      UPDATE ZADDITIONALASSETATTRIBUTES SET ZTITLE = 'Template Ignored Title' WHERE ZASSET = 1;
      """
    )
    let templatedForceUpdate = try executedTemplatedExport([
      "--state-db", templatedStateDB.path, "--force-update",
    ])
    #expect(templatedForceUpdate["exported"] as? Int == 0)
    #expect(templatedForceUpdate["skipped"] as? Int == 1)
  }

  @Test func photosLibrariesCompareReportsNormalizedDifferences() throws {
    let fixture = try makePhotosBackendFixture()
    let comparisonLibrary = fixture.root.appendingPathComponent(
      "Comparison.photoslibrary",
      isDirectory: true
    )
    try FileManager.default.copyItem(at: fixture.library, to: comparisonLibrary)
    let comparisonDatabase = comparisonLibrary.appendingPathComponent("database/Photos.sqlite")
    var handle: OpaquePointer?
    guard sqlite3_open(comparisonDatabase.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      """
      UPDATE ZASSET SET ZTITLE = 'Changed Beach' WHERE ZUUID = 'asset-1';
      UPDATE ZADDITIONALASSETATTRIBUTES SET ZTITLE = 'Changed Beach' WHERE ZASSET = 1;
      DELETE FROM ZASSET WHERE ZUUID = 'asset-3';
      """
    )

    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let output = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "libraries", "compare",
          "--library", fixture.library.path,
          "--other-library", comparisonLibrary.path,
          "--json",
        ])))
    let object = try photosTestJSONObject(output.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let onlyInA = data?["onlyInA"] as? [[String: Any]]
    let different = data?["different"] as? [[String: Any]]
    let firstDifferent = try #require(different?.first)

    #expect(data?["comparedCount"] as? Int == 3)
    #expect(data?["differenceCount"] as? Int == 2)
    #expect(onlyInA?.first?["uuid"] as? String == "asset-3")
    #expect(firstDifferent["uuidA"] as? String == "asset-1")
    #expect(firstDifferent["uuidB"] as? String == "asset-1")
    #expect((firstDifferent["differences"] as? [String])?.contains("title") == true)
  }

  @Test func photosExportRawPairingFlagsControlOriginalAndRawCopies() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    let skipRawDestination = fixture.root.appendingPathComponent("export-skip-raw", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", skipRawDestination.path,
          "--skip-raw",
          "--dry-run",
          "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", skipRawDestination.path,
          "--skip-raw",
          "--allow-external-dispatch", "--json",
        ])))

    #expect(
      FileManager.default.fileExists(
        atPath: skipRawDestination.appendingPathComponent("IMG_0002.JPG").path))
    #expect(
      FileManager.default.fileExists(
        atPath: skipRawDestination.appendingPathComponent("IMG_0002_4.DNG").path) == false)

    let rawOnlyDestination = fixture.root.appendingPathComponent("export-raw-only", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", rawOnlyDestination.path,
          "--skip-raw-jpeg",
          "--dry-run",
          "--json",
        ])))
    let rawOnlyExecuted = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", rawOnlyDestination.path,
          "--skip-raw-jpeg",
          "--allow-external-dispatch", "--json",
        ])))
    let rawOnlyObject = try photosTestJSONObject(rawOnlyExecuted.stdout ?? "")
    let rawOnlyData = rawOnlyObject["data"] as? [String: Any]

    #expect(rawOnlyData?["exported"] as? Int == 1)
    #expect(
      FileManager.default.fileExists(
        atPath: rawOnlyDestination.appendingPathComponent("IMG_0002.JPG").path) == false)
    #expect(
      FileManager.default.fileExists(
        atPath: rawOnlyDestination.appendingPathComponent("IMG_0002_4.DNG").path))
  }

  @Test func photosExportPlannerAppliesSkipFilters() throws {
    let fixture = try makePhotosBackendFixture()
    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      "UPDATE ZASSET SET ZKINDSUBTYPE = 2 WHERE ZUUID = 'asset-1';"
    )

    let skipUUIDFile = fixture.root.appendingPathComponent("skip-uuids.txt")
    try "# skip file\nasset-2\n".write(to: skipUUIDFile, atomically: true, encoding: .utf8)

    let command = PhotosCommand(backend: PhotosCompositeBackend())

    func executedExport(_ arguments: [String], destinationName: String) throws -> [String: Any] {
      let destination = fixture.root.appendingPathComponent(destinationName, isDirectory: true)
      let commonArguments =
        [
          "exports", "export",
          "--library", fixture.library.path,
          "--destination", destination.path,
        ] + arguments
      _ = try #require(
        try command.run(
          options: CLIOptionsFixture.parse(commonArguments + ["--dry-run", "--json"])))
      let executed = try #require(
        try command.run(
          options: CLIOptionsFixture.parse(
            commonArguments + ["--allow-external-dispatch", "--json"])))
      let object = try photosTestJSONObject(executed.stdout ?? "")
      return try #require(object["data"] as? [String: Any])
    }

    let skipUUIDData = try executedExport(
      [
        "--album", "album-travel", "--skip-uuid", "asset-1", "--skip-uuid-from-file",
        skipUUIDFile.path,
      ],
      destinationName: "export-skip-uuid"
    )
    #expect(skipUUIDData["exported"] as? Int == 0)
    #expect(skipUUIDData["skipped"] as? Int == 2)
    #expect(Set(skipUUIDData["skippedUUIDs"] as? [String] ?? []) == Set(["asset-1", "asset-2"]))

    let skipBurstData = try executedExport(
      ["--album", "album-travel", "--skip-bursts"],
      destinationName: "export-skip-bursts"
    )
    #expect(skipBurstData["exported"] as? Int == 1)
    #expect(skipBurstData["skipped"] as? Int == 1)
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-bursts/IMG_0001.JPG"
        ).path))
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-bursts/IMG_0002.JPG"
        ).path) == false)

    let skipLiveData = try executedExport(
      ["--album", "album-travel", "--skip-live"],
      destinationName: "export-skip-live"
    )
    #expect(skipLiveData["exported"] as? Int == 2)
    #expect(skipLiveData["skipped"] as? Int == 1)
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-live/IMG_0001.JPG"
        ).path))
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-live/IMG_0001.mov"
        ).path) == false)

    let skipEditedData = try executedExport(
      ["--album", "album-travel", "--skip-edited"],
      destinationName: "export-skip-edited"
    )
    #expect(skipEditedData["exported"] as? Int == 2)
    #expect(skipEditedData["skipped"] as? Int == 1)
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-edited/IMG_0002.JPG"
        ).path))
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-edited/IMG_0002_edited.jpeg"
        ).path) == false)

    let skipOriginalData = try executedExport(
      ["--uuid", "asset-2", "--skip-original-if-edited"],
      destinationName: "export-skip-original-if-edited"
    )
    #expect(skipOriginalData["exported"] as? Int == 1)
    #expect(skipOriginalData["skipped"] as? Int == 1)
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-original-if-edited/IMG_0002.JPG"
        ).path) == false)
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-original-if-edited/IMG_0002_4.DNG"
        ).path) == false)
    #expect(
      FileManager.default.fileExists(
        atPath: fixture.root.appendingPathComponent(
          "export-skip-original-if-edited/IMG_0002_edited.jpeg"
        ).path))
  }

  @Test func photosExportRejectsConflictingSkipFilters() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let destination = fixture.root.appendingPathComponent("export-conflict", isDirectory: true)

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", destination.path,
          "--skip-raw",
          "--skip-raw-jpeg",
          "--dry-run",
          "--json",
        ]))
    }

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", destination.path,
          "--skip-edited",
          "--skip-original-if-edited",
          "--dry-run",
          "--json",
        ]))
    }

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--export-by-date",
          "--directory-template", "{year}",
          "--dry-run",
          "--json",
        ]))
    }
  }

  @Test func photosExportOverwriteAndRetryOptionsControlConflictBehavior() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", fixture.root.appendingPathComponent("retry-wait-only").path,
          "--retry-wait-seconds", "1",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", fixture.root.appendingPathComponent("retry-too-large").path,
          "--retry-count", "6",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", fixture.root.appendingPathComponent("retry-nas").path,
          "--retry-count", "1",
          "--retry-nas-alias", "/tmp/NAS.alias",
          "--dry-run",
          "--json",
        ]))
    }

    let suffixDestination = fixture.root.appendingPathComponent("export-suffix", isDirectory: true)
    try FileManager.default.createDirectory(at: suffixDestination, withIntermediateDirectories: true)
    let suffixExisting = suffixDestination.appendingPathComponent("IMG_0001.JPG")
    try "existing".write(to: suffixExisting, atomically: true, encoding: .utf8)

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", suffixDestination.path,
          "--dry-run",
          "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", suffixDestination.path,
          "--allow-external-dispatch", "--json",
        ])))

    let suffixedFile = suffixDestination.appendingPathComponent("IMG_0001-2.JPG")
    let suffixExistingContents = try String(contentsOf: suffixExisting, encoding: .utf8)
    let suffixedFileContents = try String(contentsOf: suffixedFile, encoding: .utf8)
    #expect(suffixExistingContents == "existing")
    #expect(suffixedFileContents == "one")

    let overwriteDestination = fixture.root.appendingPathComponent(
      "export-overwrite",
      isDirectory: true
    )
    try FileManager.default.createDirectory(
      at: overwriteDestination, withIntermediateDirectories: true)
    let overwriteExisting = overwriteDestination.appendingPathComponent("IMG_0001.JPG")
    try "existing".write(to: overwriteExisting, atomically: true, encoding: .utf8)

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", overwriteDestination.path,
          "--overwrite",
          "--retry-count", "1",
          "--retry-wait-seconds", "0",
          "--dry-run",
          "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", overwriteDestination.path,
          "--overwrite",
          "--retry-count", "2",
          "--retry-wait-seconds", "0",
          "--allow-external-dispatch", "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", overwriteDestination.path,
          "--overwrite",
          "--retry-count", "1",
          "--retry-wait-seconds", "0",
          "--allow-external-dispatch", "--json",
        ])))

    let overwriteContents = try String(contentsOf: overwriteExisting, encoding: .utf8)
    #expect(overwriteContents == "one")
    #expect(
      FileManager.default.fileExists(
        atPath: overwriteDestination.appendingPathComponent("IMG_0001-2.JPG").path) == false)
  }

  @Test func photosExportAppliesFilenameAndDirectoryTemplatesWithCollisionSuffixes() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-templates", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--destination", destination.path,
          "--directory-template", "{year}/{album}",
          "--filename-template", "{title}.{ext}",
          "--dry-run",
          "--json",
        ])))

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--destination", destination.path,
          "--directory-template", "{year}/{album}",
          "--filename-template", "{title}.{ext}",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let exportDirectory = destination.appendingPathComponent("2024/Travel", isDirectory: true)

    #expect(data?["exported"] as? Int == 2)
    #expect(
      FileManager.default.fileExists(atPath: exportDirectory.appendingPathComponent("Beach.JPG").path)
    )
    #expect(
      FileManager.default.fileExists(
        atPath: exportDirectory.appendingPathComponent("Beach-2.JPG").path))
    #expect(
      FileManager.default.fileExists(
        atPath: exportDirectory.appendingPathComponent("Beach.DNG").path))
  }

  @Test func photosExportAppliesCurrentNameDateFoldersAndTouchFile() throws {
    let fixture = try makePhotosBackendFixture()
    let renamedOriginal = fixture.originals.appendingPathComponent("ORIGINAL_0001.JPG")
    try FileManager.default.moveItem(
      at: fixture.originals.appendingPathComponent("IMG_0001.JPG"),
      to: renamedOriginal
    )
    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      "UPDATE ZASSET SET original_path = '\(renamedOriginal.path)' WHERE ZUUID = 'asset-1';"
    )

    let item = try #require(
      try PhotosLibrarySnapshotBackend()
        .listMediaItems(query: PhotosQuery(libraryPath: fixture.library.path, uuids: ["asset-1"]))
        .first
    )
    let date = try #require(item.date)
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
    let year = String(calendar.component(.year, from: date))
    let month = String(format: "%02d", calendar.component(.month, from: date))
    let day = String(format: "%02d", calendar.component(.day, from: date))

    let destination = fixture.root.appendingPathComponent("export-layout", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--current-name",
          "--export-by-date",
          "--touch-file",
          "--dry-run",
          "--json",
        ])))
    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--current-name",
          "--export-by-date",
          "--touch-file",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let exportedURL = destination.appendingPathComponent(
      "\(year)/\(month)/\(day)/IMG_0001.JPG"
    )
    let sourceNameURL = destination.appendingPathComponent(
      "\(year)/\(month)/\(day)/ORIGINAL_0001.JPG"
    )
    let attributes = try FileManager.default.attributesOfItem(atPath: exportedURL.path)
    let modificationDate = try #require(attributes[.modificationDate] as? Date)

    #expect(data?["exported"] as? Int == 1)
    #expect(FileManager.default.fileExists(atPath: exportedURL.path))
    #expect(FileManager.default.fileExists(atPath: sourceNameURL.path) == false)
    #expect(abs(modificationDate.timeIntervalSince(date)) < 1.5)
  }

  @Test func photosExportUsingOriginalsReportsMissingOriginalWithoutAppFallback() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent(
      "export-missing-original", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-3",
          "--destination", destination.path,
          "--using-originals",
          "--dry-run",
          "--json",
        ])))

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-3",
          "--destination", destination.path,
          "--using-originals",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["exported"] as? Int == 0)
    #expect(data?["missing"] as? Int == 1)
    #expect(data?["missingUUIDs"] as? [String] == ["asset-3"])
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("missing.mov").path)
        == false)
  }

  @Test func photosExportPreviewAndPreviewIfMissingUseDerivativeResources() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let previewDestination = fixture.root.appendingPathComponent("export-preview", isDirectory: true)

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", previewDestination.path,
          "--preview",
          "--preview-suffix", "_small",
          "--dry-run",
          "--json",
        ])))
    let changedPreviewDestination = fixture.root.appendingPathComponent(
      "export-preview-changed", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", changedPreviewDestination.path,
          "--preview",
          "--preview-suffix", "_changed",
          "--allow-external-dispatch", "--json",
        ])))
    #expect(
      FileManager.default.fileExists(
        atPath: changedPreviewDestination.appendingPathComponent("IMG_0001_changed.jpeg").path))

    let previewExecuted = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", previewDestination.path,
          "--preview",
          "--preview-suffix", "_small",
          "--allow-external-dispatch", "--json",
        ])))
    let previewObject = try photosTestJSONObject(previewExecuted.stdout ?? "")
    let previewData = previewObject["data"] as? [String: Any]
    #expect(previewData?["exported"] as? Int == 1)
    #expect(previewData?["missing"] as? Int == 0)
    #expect(
      FileManager.default.fileExists(
        atPath: previewDestination.appendingPathComponent("IMG_0001.JPG").path))
    #expect(
      FileManager.default.fileExists(
        atPath: previewDestination.appendingPathComponent("IMG_0001_small.jpeg").path))

    let previewReportURL = try #require(previewData?["reportPath"] as? String)
    let previewReportObject = try photosTestJSONObject(
      String(contentsOfFile: previewReportURL, encoding: .utf8)
    )
    let resources = try #require(previewReportObject["resources"] as? [[String: Any]])
    #expect(Set(resources.compactMap { $0["kind"] as? String }) == ["original", "preview"])

    let fallbackDestination = fixture.root.appendingPathComponent(
      "export-preview-if-missing", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-3",
          "--destination", fallbackDestination.path,
          "--preview-if-missing",
          "--preview-suffix", "",
          "--dry-run",
          "--json",
        ])))
    let fallbackExecuted = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-3",
          "--destination", fallbackDestination.path,
          "--preview-if-missing",
          "--preview-suffix", "",
          "--allow-external-dispatch", "--json",
        ])))
    let fallbackObject = try photosTestJSONObject(fallbackExecuted.stdout ?? "")
    let fallbackData = fallbackObject["data"] as? [String: Any]

    #expect(fallbackData?["exported"] as? Int == 1)
    #expect(fallbackData?["missing"] as? Int == 0)
    #expect(
      FileManager.default.fileExists(
        atPath: fallbackDestination.appendingPathComponent("IMG_0003.jpeg").path))
    #expect(
      FileManager.default.fileExists(
        atPath: fallbackDestination.appendingPathComponent("missing.mov").path) == false)
  }

  @Test func photosExportEditedRendersUseRenderResourcesAndSuffixDigest() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-edited-render", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", destination.path,
          "--skip-raw",
          "--edited-suffix", "_adjusted",
          "--dry-run",
          "--json",
        ])))
    let defaultSuffixDestination = fixture.root.appendingPathComponent(
      "export-edited-render-default", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", defaultSuffixDestination.path,
          "--skip-raw",
          "--allow-external-dispatch", "--json",
        ])))
    #expect(
      FileManager.default.fileExists(
        atPath: defaultSuffixDestination.appendingPathComponent("IMG_0002_edited.jpeg").path))

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", destination.path,
          "--skip-raw",
          "--edited-suffix", "_adjusted",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["exported"] as? Int == 1)
    #expect(data?["missing"] as? Int == 0)
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0002.JPG").path))
    #expect(
      FileManager.default.fileExists(
        atPath: destination.appendingPathComponent("IMG_0002_adjusted.jpeg").path))

    let reportPath = try #require(data?["reportPath"] as? String)
    let reportObject = try photosTestJSONObject(String(contentsOfFile: reportPath, encoding: .utf8))
    let resources = try #require(reportObject["resources"] as? [[String: Any]])
    #expect(Set(resources.compactMap { $0["kind"] as? String }) == ["original", "edited_render"])
  }

  @Test func photosExportLivePhotoMoviesUsePairedMovieResources() throws {
    let fixture = try makePhotosBackendFixture()
    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      """
      UPDATE ZASSET SET ZKINDSUBTYPE = 2 WHERE ZUUID IN ('asset-1', 'asset-2');
      """
    )

    let destination = fixture.root.appendingPathComponent("export-live-photo", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--dry-run",
          "--json",
        ])))
    let skipLiveDestination = fixture.root.appendingPathComponent(
      "export-live-photo-skip-live", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", skipLiveDestination.path,
          "--skip-live",
          "--allow-external-dispatch", "--json",
        ])))
    #expect(
      FileManager.default.fileExists(
        atPath: skipLiveDestination.appendingPathComponent("IMG_0001.mov").path) == false)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--destination", destination.path,
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["exported"] as? Int == 1)
    #expect(data?["missing"] as? Int == 0)
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0001.JPG").path))
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0001.mov").path))

    let reportPath = try #require(data?["reportPath"] as? String)
    let reportObject = try photosTestJSONObject(String(contentsOfFile: reportPath, encoding: .utf8))
    let resources = try #require(reportObject["resources"] as? [[String: Any]])
    #expect(Set(resources.compactMap { $0["kind"] as? String }) == ["original", "live_photo_movie"])

    let dump = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "dump",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--json",
        ])))
    let dumpObject = try photosTestJSONObject(dump.stdout ?? "")
    let dumpData = try #require(dumpObject["data"] as? [String: Any])
    let dumpItems = try #require(dumpData["items"] as? [[String: Any]])
    #expect(dumpItems.first?["livePhoto"] as? Bool == true)
    #expect((dumpItems.first?["pathLivePhoto"] as? String)?.hasSuffix("IMG_0001_3.mov") == true)

    let editedDestination = fixture.root.appendingPathComponent(
      "export-edited-live-photo", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", editedDestination.path,
          "--skip-original-if-edited",
          "--skip-raw",
          "--dry-run",
          "--json",
        ])))
    let editedExecuted = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", editedDestination.path,
          "--skip-original-if-edited",
          "--skip-raw",
          "--allow-external-dispatch", "--json",
        ])))
    let editedObject = try photosTestJSONObject(editedExecuted.stdout ?? "")
    let editedData = editedObject["data"] as? [String: Any]
    #expect(editedData?["exported"] as? Int == 1)
    #expect(editedData?["missing"] as? Int == 0)
    #expect(
      FileManager.default.fileExists(
        atPath: editedDestination.appendingPathComponent("IMG_0002_edited.jpeg").path))
    #expect(
      FileManager.default.fileExists(
        atPath: editedDestination.appendingPathComponent("IMG_0002_edited.mov").path))
  }

  @Test func photosExportAAESidecarsUseAdjustmentResources() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("export-aae", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", destination.path,
          "--skip-raw",
          "--export-aae",
          "--dry-run",
          "--json",
        ])))
    let noAAEDestination = fixture.root.appendingPathComponent("export-no-aae", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", noAAEDestination.path,
          "--skip-raw",
          "--allow-external-dispatch", "--json",
        ])))
    #expect(
      FileManager.default.fileExists(atPath: noAAEDestination.appendingPathComponent("IMG_0002.AAE").path)
        == false)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--destination", destination.path,
          "--skip-raw",
          "--export-aae",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["exported"] as? Int == 1)
    #expect(data?["missing"] as? Int == 0)
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0002.JPG").path))
    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0002.AAE").path))
    #expect(
      FileManager.default.fileExists(
        atPath: destination.appendingPathComponent("IMG_0002_O.AAE").path))

    let reportPath = try #require(data?["reportPath"] as? String)
    let reportObject = try photosTestJSONObject(String(contentsOfFile: reportPath, encoding: .utf8))
    let resources = try #require(reportObject["resources"] as? [[String: Any]])
    #expect(
      Set(resources.compactMap { $0["kind"] as? String })
        == ["original", "edited_render", "aae", "original_aae"])
  }

  @Test func photosExportConvertsNonJPEGImagesWithQualityAndOrientation() throws {
    let fixture = try makePhotosBackendFixture()
    let pngSource = fixture.originals.appendingPathComponent("IMG_0004.png")
    try photosWriteTestImage(to: pngSource, type: .png)
    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      """
      INSERT INTO ZASSET
        (
          Z_PK, ZUUID, ZFILENAME, ZTITLE, ZDESCRIPTION, ZFAVORITE, ZHIDDEN, ZKIND,
          ZCLOUDBATCHPUBLISHDATE, ZCLOUDASSETGUID, ZADDEDDATE, ZUNIFORMTYPEIDENTIFIER,
          ZWIDTH, ZHEIGHT, ZKEYWORDS, ZPERSONS, ZALBUMS, ZLATITUDE, ZLONGITUDE, date,
          original_path, file_size, ZKINDSUBTYPE, ZHDRTYPE, ZCUSTOMRENDEREDVALUE,
          ZHASADJUSTMENTS, ZADJUSTMENTSSTATE, ZDEPTHTYPE, ZDEPTHSTATES,
          ZSAVEDASSETTYPE, ZORIGINALRESOURCECHOICE, ZCAMERACAPTUREDEVICE
        )
      VALUES
        (4, 'asset-4', 'IMG_0004.PNG', 'PNG original', '', 0, 0, 0, '', '', 735091765,
         'public.png', 1, 1, '', '', '', '', '', '1700000003',
         '\(pngSource.path)', '0', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      INSERT INTO ZADDITIONALASSETATTRIBUTES
        (Z_PK, ZASSET, ZORIGINALFILENAME, ZTITLE, ZUNMANAGEDADJUSTMENT)
      VALUES (33, 4, 'IMG_0004.PNG', 'PNG original', NULL);
      """
    )
    let destination = fixture.root.appendingPathComponent("export-jpeg", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-4",
          "--destination", destination.path,
          "--convert-to-jpeg",
          "--jpeg-quality", "0.75",
          "--jpeg-extension", "jpg",
          "--fix-orientation",
          "--dry-run",
          "--json",
        ])))
    let defaultQualityDestination = fixture.root.appendingPathComponent(
      "export-jpeg-default-quality", isDirectory: true)
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-4",
          "--destination", defaultQualityDestination.path,
          "--convert-to-jpeg",
          "--jpeg-extension", "jpg",
          "--fix-orientation",
          "--allow-external-dispatch", "--json",
        ])))
    #expect(
      FileManager.default.fileExists(
        atPath: defaultQualityDestination.appendingPathComponent("IMG_0004.jpg").path))

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "exports", "export",
          "--library", fixture.library.path,
          "--uuid", "asset-4",
          "--destination", destination.path,
          "--convert-to-jpeg",
          "--jpeg-quality", "0.75",
          "--jpeg-extension", "jpg",
          "--fix-orientation",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let exportedFile = destination.appendingPathComponent("IMG_0004.jpg")

    #expect(data?["exported"] as? Int == 1)
    #expect(data?["missing"] as? Int == 0)
    #expect(FileManager.default.fileExists(atPath: exportedFile.path))
    let imageSource = try #require(CGImageSourceCreateWithURL(exportedFile as CFURL, nil))
    #expect(CGImageSourceGetType(imageSource) as String? == UTType.jpeg.identifier)

    let reportPath = try #require(data?["reportPath"] as? String)
    let reportObject = try photosTestJSONObject(String(contentsOfFile: reportPath, encoding: .utf8))
    let resources = try #require(reportObject["resources"] as? [[String: Any]])
    #expect(resources.count == 1)
    #expect(resources.first?["kind"] as? String == "converted_jpeg")
    #expect(resources.first?["path"] as? String == exportedFile.path)
  }

  @Test func photosSidecarWritesPerItemJSONFromSnapshotRecords() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("sidecars", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--format", "json",
          "--destination", destination.path,
          "--dry-run",
          "--json",
        ])))

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--format", "json",
          "--destination", destination.path,
          "--allow-external-dispatch", "--json",
        ])))

    #expect(
      FileManager.default.fileExists(atPath: destination.appendingPathComponent("IMG_0001.json").path)
    )
    let sidecar = try String(
      contentsOf: destination.appendingPathComponent("IMG_0001.json"),
      encoding: .utf8
    )
    #expect(sidecar.contains("asset-1"))
  }

  @Test func photosSidecarWritesXMPAndTemplateSidecarsFromSnapshotRecords() throws {
    let fixture = try makePhotosBackendFixture()
    let xmpDestination = fixture.root.appendingPathComponent("xmp-sidecars", isDirectory: true)
    let templateDestination = fixture.root.appendingPathComponent(
      "template-sidecars",
      isDirectory: true
    )
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--format", "xmp",
          "--destination", xmpDestination.path,
          "--template", "{title|upper}",
          "--dry-run",
          "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--format", "xmp",
          "--destination", xmpDestination.path,
          "--template", "{title|upper}",
          "--allow-external-dispatch", "--json",
        ])))

    let xmp = try String(
      contentsOf: xmpDestination.appendingPathComponent("IMG_0001.xmp"),
      encoding: .utf8
    )
    #expect(xmp.contains("<photos:uuid>asset-1</photos:uuid>"))
    #expect(xmp.contains("<dc:title>Beach</dc:title>"))
    #expect(xmp.contains("<rdf:li>beach</rdf:li>"))
    #expect(xmp.contains("<rdf:li>Ana</rdf:li>"))
    #expect(xmp.contains("<photos:template>BEACH</photos:template>"))

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--format", "template",
          "--destination", templateDestination.path,
          "--template", "{title|upper}-{keywords|sort|join(+)}",
          "--dry-run",
          "--json",
        ])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--format", "template",
          "--destination", templateDestination.path,
          "--template", "{title|upper}-{keywords|sort|join(+)}",
          "--allow-external-dispatch", "--json",
        ])))

    let rendered = try String(
      contentsOf: templateDestination.appendingPathComponent("IMG_0001.txt"),
      encoding: .utf8
    )
    #expect(rendered == "BEACH-beach+travel")
  }

  @Test func photosTemplateSidecarRequiresTemplateBeforeDryRun() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("template-sidecars", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sidecar",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--format", "template",
          "--destination", destination.path,
          "--dry-run",
          "--json",
        ]))
    }
  }

  @Test func photosExifReportReadsImportedSnapshotMetadataWithoutExiftool() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    let output = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--json",
        ])))
    let object = try photosTestJSONObject(output.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = data?["items"] as? [[String: Any]]
    let first = try #require(items?.first)
    let values = first["values"] as? [String: String]

    #expect(first["uuid"] as? String == "asset-1")
    #expect(values?["camera_make"] == "Apple")
    #expect(values?["camera_model"] == "iPhone 14 Pro")
    #expect(values?["iso"] == "160")
  }

  @Test func photosTemplateRenderUsesNormalizedSnapshotFields() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    let output = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template",
          "{uuid}|{filename}|{title}|{keywords}|{person}|{media_type}|{year}|{favorite}|{width}|{latitude}|{longitude}|{altitude}|{ext}",
          "--json",
        ])))
    let object = try photosTestJSONObject(output.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let rendered = data?["rendered"] as? [String]

    #expect(
      rendered == [
        "asset-1|IMG_0001.JPG|Beach|travel,beach|Ana|image|2024|true|4032|37.3318|-122.0312|15.5|JPG"
      ])
  }

  @Test func photosTemplateRenderAppliesFiltersDefaultsAndConditionals() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    let output = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template",
          "{title|upper}|{keywords|sort|join(+)}|{labels,nolabel}|{favorite?fav,plain}|{width >= 4000?wide,narrow}|{keywords|filter(startswith be)}",
          "--json",
        ])))
    let object = try photosTestJSONObject(output.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let rendered = data?["rendered"] as? [String]

    #expect(rendered == ["BEACH|beach+travel|nolabel|fav|wide|beach"])
  }

  @Test func photosExifWithDestinationWritesDoctorGatedPlanWithoutExiftool() throws {
    let fixture = try makePhotosBackendFixture()
    let destination = fixture.root.appendingPathComponent("exif-plan", isDirectory: true)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "XMP:Title=Beach",
          "--destination", destination.path,
          "--dry-run",
          "--json",
        ])))

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "XMP:Title=Beach",
          "--destination", destination.path,
          "--allow-external-dispatch", "--json",
        ])))

    let planURL = destination.appendingPathComponent("photos-exif-plan.json")
    #expect(FileManager.default.fileExists(atPath: planURL.path))
    let plan = try String(contentsOf: planURL, encoding: .utf8)
    #expect(plan.contains("XMP:Title=Beach"))
  }

  @Test func photosExifDestructiveMetadataUsesExplicitExiftoolPathBehindStrongGate() throws {
    let fixture = try makePhotosBackendFixture()
    let marker = fixture.root.appendingPathComponent("metadata-exiftool-args.txt")
    let exiftool = try makePhotosFakeExiftool(root: fixture.root, marker: marker)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["fields_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["exiftool_path_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["timeout_seconds"] as? String == "10")
    #expect(summary?["output_cap"] as? String == "65536")

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))
    let markerContents = try String(contentsOf: marker, encoding: .utf8)
    let originalPath = fixture.originals.appendingPathComponent("IMG_0001.JPG").path

    #expect(markerContents.contains("-XMP:Title=Beach"))
    #expect(markerContents.contains("-overwrite_original"))
    #expect(markerContents.contains(originalPath))
  }

  @Test func photosPushExifDerivesPhotosMetadataBehindStrongGate() throws {
    let fixture = try makePhotosBackendFixture()
    let marker = fixture.root.appendingPathComponent("push-exiftool-args.txt")
    let exiftool = try makePhotosFakeExiftool(root: fixture.root, marker: marker)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "all",
          "--exiftool-path", exiftool.path,
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "all",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect(summary?["fields"] as? String == "all")
    #expect((summary?["fields_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["derived_fields_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["target_paths_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["exiftool_path_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["item_count"] as? String == "1")
    #expect(summary?["write_count"] as? String == "1")
    #expect(summary?["timeout_seconds"] as? String == "10")
    #expect(summary?["output_cap"] as? String == "65536")

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "all",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let first = try #require(records?.first)
    let fields = first["fields"] as? [String]
    let originalPath = fixture.originals.appendingPathComponent("IMG_0001.JPG").path

    #expect(data?["submitted"] as? Int == 1)
    #expect(first["uuid"] as? String == "asset-1")
    #expect(first["path"] as? String == originalPath)
    #expect(fields?.contains("XMP:Title=Beach") == true)
    #expect(fields?.contains("IPTC:Keywords=travel,beach") == true)
    #expect(fields?.contains("XMP:PersonInImage=Ana") == true)
    #expect(fields?.contains("EXIF:GPSLatitude=37.3318") == true)
    #expect(fields?.contains("EXIF:GPSLongitude=-122.0312") == true)
    #expect(fields?.contains("XMP:Rating=5") == true)

    let markerContents = try String(contentsOf: marker, encoding: .utf8)
    #expect(markerContents.contains("-XMP:Title=Beach"))
    #expect(markerContents.contains("-XMP:Description=At the beach"))
    #expect(markerContents.contains("-IPTC:Caption-Abstract=At the beach"))
    #expect(markerContents.contains("-IPTC:Keywords=travel,beach"))
    #expect(markerContents.contains("-XMP:Subject=travel,beach"))
    #expect(markerContents.contains("-XMP:PersonInImage=Ana"))
    #expect(markerContents.contains("-EXIF:DateTimeOriginal="))
    #expect(markerContents.contains("-EXIF:CreateDate="))
    #expect(markerContents.contains("-XMP:CreateDate="))
    #expect(markerContents.contains("-EXIF:GPSLatitude=37.3318"))
    #expect(markerContents.contains("-EXIF:GPSLongitude=-122.0312"))
    #expect(markerContents.contains("-EXIF:GPSAltitude=15.5"))
    #expect(markerContents.contains("-XMP:Rating=5"))
    #expect(markerContents.contains("-overwrite_original"))
    #expect(markerContents.contains(originalPath))

    let changed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "title",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--timeout-seconds", "10",
          "--output-cap", "65536",
          "--allow-external-dispatch", "--json",
        ])))
    let changedObject = try photosTestJSONObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]
    #expect(changedData?["submitted"] as? Int == 1)
  }

  @Test func photosPushExifRejectsImplicitRawAndInLibraryTargets() throws {
    let fixture = try makePhotosBackendFixture()
    let marker = fixture.root.appendingPathComponent("push-exiftool-args.txt")
    let exiftool = try makePhotosFakeExiftool(root: fixture.root, marker: marker)
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--field", "title",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "XMP:Title=Beach",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--dry-run",
          "--json",
        ]))
    }

    let nonExecutableTool = fixture.root.appendingPathComponent("not-executable-exiftool")
    try Data("not executable".utf8).write(to: nonExecutableTool)
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "title",
          "--exiftool-path", nonExecutableTool.path,
          "--allow-destructive-metadata",
          "--dry-run",
          "--json",
        ]))
    }

    let inLibraryOriginal = fixture.library.appendingPathComponent(
      "originals/a/in-library.jpg")
    try Data("in-library".utf8).write(to: inLibraryOriginal)
    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    let escapedPath = inLibraryOriginal.path.replacingOccurrences(of: "'", with: "''")
    try photosTestSQLiteExec(
      handle,
      "UPDATE ZASSET SET original_path = '\(escapedPath)' WHERE ZUUID = 'asset-1';"
    )
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "push-exif",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--field", "title",
          "--exiftool-path", exiftool.path,
          "--allow-destructive-metadata",
          "--dry-run",
          "--json",
        ]))
    }
  }
}

private func photosSwiftStringLiteral(_ value: String) throws -> String {
  var result = "\""
  for scalar in value.unicodeScalars {
    switch scalar {
    case "\\":
      result += "\\\\"
    case "\"":
      result += "\\\""
    case "\n":
      result += "\\n"
    case "\r":
      result += "\\r"
    case "\t":
      result += "\\t"
    default:
      result.unicodeScalars.append(scalar)
    }
  }
  result += "\""
  return result
}

private func photosShellQuote(_ value: String) -> String {
  "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
}

private func makePhotosFakeExiftool(root: URL, marker: URL) throws -> URL {
  let exiftool = root.appendingPathComponent("fake-exiftool")
  let source = """
    #!/bin/sh
    printf '%s\\n' "$@" >> \(photosShellQuote(marker.path))
    exit 0
    """
  try source.write(to: exiftool, atomically: true, encoding: .utf8)
  chmod(exiftool.path, 0o755)
  return exiftool
}

private func photosReadXattr(path: String, name: String) throws -> Data {
  let size = getxattr(path, name, nil, 0, 0, 0)
  guard size >= 0 else {
    throw CLIError(
      code: .notFound,
      message: "Expected xattr was not found.",
      details: ["path": path, "attribute": name, "errno": "\(errno)"]
    )
  }
  var data = Data(count: size)
  let readSize = data.withUnsafeMutableBytes { bytes in
    getxattr(path, name, bytes.baseAddress, size, 0, 0)
  }
  guard readSize == size else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Failed to read xattr.",
      details: ["path": path, "attribute": name, "errno": "\(errno)"]
    )
  }
  return data
}

private func photosResolvedPath(_ url: URL) -> String {
  let standardized = url.standardizedFileURL
  if let resolved = photosRealPath(standardized) {
    return resolved
  }
  if let resolvedParent = photosRealPath(standardized.deletingLastPathComponent()) {
    return URL(fileURLWithPath: resolvedParent)
      .appendingPathComponent(standardized.lastPathComponent)
      .path
  }
  return standardized.path
}

private func photosRealPath(_ url: URL) -> String? {
  url.withUnsafeFileSystemRepresentation { representation in
    guard let representation, let resolved = realpath(representation, nil) else {
      return nil
    }
    defer { free(resolved) }
    return String(cString: resolved)
  }
}
