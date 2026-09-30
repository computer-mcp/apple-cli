import Foundation
import PhotosCLI
import Testing
import Utility

@Suite
struct PhotosCommandTests {
  @Test func photosLibrariesListReturnsJSON() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse(["libraries", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let libraries = data?["libraries"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(data?["count"] as? Int == 1)
    #expect(libraries?.first?["name"] as? String == "System Library")
    #expect(
      libraries?.first?["path"] as? String == "/Users/example/Pictures/Photos Library.photoslibrary")
  }

  @Test func photosListResponsesReturnStableCounts() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())

    let albumsResult = try #require(
      try command.run(options: CLIOptionsFixture.parse(["albums", "list", "--json"])))
    let albumsObject = try photosJSONObject(albumsResult.stdout ?? "")
    let albumsData = albumsObject["data"] as? [String: Any]
    #expect(albumsData?["count"] as? Int == 1)

    let foldersResult = try #require(
      try command.run(options: CLIOptionsFixture.parse(["folders", "list", "--json"])))
    let foldersObject = try photosJSONObject(foldersResult.stdout ?? "")
    let foldersData = foldersObject["data"] as? [String: Any]
    #expect(foldersData?["count"] as? Int == 1)

    let mediaItemsResult = try #require(
      try command.run(options: CLIOptionsFixture.parse(["media-items", "list", "--json"])))
    let mediaItemsObject = try photosJSONObject(mediaItemsResult.stdout ?? "")
    let mediaItemsData = mediaItemsObject["data"] as? [String: Any]
    #expect(mediaItemsData?["count"] as? Int == 1)
  }

  @Test func photosDatabaseInfoReturnsVersionMetadata() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "database", "info", "--library", "/tmp/Test.photoslibrary", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let library = data?["library"] as? [String: Any]

    #expect(object["ok"] as? Bool == true)
    #expect(library?["databaseVersion"] as? String == "5001")
    #expect(library?["modelVersion"] as? String == "13703")
    #expect(library?["photosVersion"] as? String == "5")
  }

  @Test func photosLibraryInfoReturnsTypedCounts() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "libraries", "info", "--library", "/tmp/Test.photoslibrary", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let library = data?["library"] as? [String: Any]
    let counts = library?["counts"] as? [String: Int]

    #expect(object["ok"] as? Bool == true)
    #expect(library?["path"] as? String == "/tmp/Test.photoslibrary")
    #expect(counts?["all"] == 3)
    #expect(counts?["photos"] == 2)
    #expect(counts?["videos"] == 1)
  }

  @Test func photosMetadataValuesReturnCounts() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse(["metadata", "keywords", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let counts = data?["counts"] as? [String: Int]

    #expect(data?["values"] as? [String] == ["travel"])
    #expect(counts?["travel"] == 1)
  }

  @Test func photosAppBundleMetadataCheckReadsNameAndVersion() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-tests-\(UUID().uuidString)", isDirectory: true)
    let contents = root.appendingPathComponent("Photos.app/Contents", isDirectory: true)
    try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }

    let info: [String: String] = [
      "CFBundleIdentifier": "com.apple.Photos",
      "CFBundleName": "Photos",
      "CFBundleShortVersionString": "11.0",
      "CFBundleVersion": "710.42.101",
      "CFBundlePackageType": "APPL",
    ]
    let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
    try data.write(to: contents.appendingPathComponent("Info.plist"))

    let check = photosAppBundleMetadataCheck(
      appPath: contents.deletingLastPathComponent().path)

    #expect(check.name == "photos_app_metadata")
    #expect(check.status == .ok)
    #expect(check.details["name"] == "Photos")
    #expect(check.details["version"] == "11.0")
    #expect(check.details["build"] == "710.42.101")
    #expect(check.details["bundle_identifier"] == "com.apple.Photos")
  }

  @Test func photosMediaItemsSearchMapsTypedQuery() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--keyword", "travel", "--person", "Ana", "--media-type", "image",
      "--favorite", "--year", "2024", "--from-time", "00:00", "--to-time", "00:30", "--limit",
      "5", "--place", "Maui", "--place", "Wailea", "--regex", "Beach", "--regex-field", "title",
      "--edited", "--external-edit", "--added-after", "2024-01-01", "--added-before",
      "2025-01-01", "--added-in-last", "10000d", "--has-location", "--ignore-case",
      "--has-comment", "--has-likes", "--exif", "EXIF:Make=Apple", "--exif", "LensModel iPhone",
      "--newest-first", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let query = data?["query"] as? [String: Any]

    #expect(query?["keywords"] as? [String] == ["travel"])
    #expect(query?["persons"] as? [String] == ["Ana"])
    #expect(query?["favorite"] as? Bool == true)
    #expect(query?["limit"] as? Int == 5)
    #expect(backend.lastQuery?.keywords == ["travel"])
    #expect(backend.lastQuery?.years == [2024])
    #expect(backend.lastQuery?.timeFrom == "00:00")
    #expect(backend.lastQuery?.timeTo == "00:30")
    #expect(backend.lastQuery?.places == ["Maui", "Wailea"])
    #expect(backend.lastQuery?.regex == "Beach")
    #expect(backend.lastQuery?.regexFields == ["title"])
    #expect(backend.lastQuery?.ignoreCase == true)
    #expect(backend.lastQuery?.newestFirst == true)
    #expect(backend.lastQuery?.edited == true)
    #expect(backend.lastQuery?.externalEdit == true)
    #expect(backend.lastQuery?.addedAfter == "2024-01-01")
    #expect(backend.lastQuery?.addedBefore == "2025-01-01")
    #expect(backend.lastQuery?.addedInLast == "10000d")
    #expect(backend.lastQuery?.hasLocation == true)
    #expect(backend.lastQuery?.hasComment == true)
    #expect(backend.lastQuery?.hasLikes == true)
    #expect(
      backend.lastQuery?.exif == [
        PhotosExifPredicate(tag: "EXIF:Make", value: "Apple"),
        PhotosExifPredicate(tag: "LensModel", value: "iPhone"),
      ])
  }

  @Test func photosMediaItemsSearchReadsUUIDsFromFile() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-tests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let file = root.appendingPathComponent("uuids.txt")
    try """
    # comment
    asset-2

    asset-3
    asset-2
    """.write(to: file, atomically: true, encoding: .utf8)

    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--uuid", "asset-1", "--uuid-from-file", file.path, "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.uuids == ["asset-1", "asset-2", "asset-3"])
  }

  @Test func photosMediaItemsSearchNormalizesStandardUUIDSelectors() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-tests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let file = root.appendingPathComponent("uuids.txt")
    try """
    # comment
    1eb2b765-0765-43ba-a90c-0d0580e6172c
    opaque-local-id
    """.write(to: file, atomically: true, encoding: .utf8)

    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search",
      "--uuid", "3dd2c897-f19e-4ca6-8c22-b027d5a71907",
      "--uuid-from-file", file.path,
      "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(
      backend.lastQuery?.uuids == [
        "3DD2C897-F19E-4CA6-8C22-B027D5A71907",
        "1EB2B765-0765-43BA-A90C-0D0580E6172C",
        "opaque-local-id",
      ])
  }

  @Test func photosMediaItemsSearchKeepsRepeatedTextSelectors() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search",
      "--keyword", "travel", "--keyword", "family",
      "--person", "Ana", "--person", "Ben",
      "--title", "Beach", "--title", "Pumpkin",
      "--description", "Vacation", "--description", "Dinner",
      "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.keywords == ["travel", "family"])
    #expect(backend.lastQuery?.persons == ["Ana", "Ben"])
    #expect(backend.lastQuery?.titles == ["Beach", "Pumpkin"])
    #expect(backend.lastQuery?.descriptions == ["Vacation", "Dinner"])
  }

  @Test func photosMediaItemsSearchKeepsRepeatedAlbumAndFolderSelectors() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search",
      "--album", "Trips/SubFolder/Travel",
      "--album", "Travel//2025",
      "--folder", "Trips/SubFolder",
      "--folder", "Archive//2025",
      "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.albums == ["Trips/SubFolder/Travel", "Travel//2025"])
    #expect(backend.lastQuery?.album == "Trips/SubFolder/Travel")
    #expect(backend.lastQuery?.folders == ["Trips/SubFolder", "Archive//2025"])
    #expect(backend.lastQuery?.folder == "Trips/SubFolder")
  }

  @Test func photosMediaItemsSearchRejectsMissingUUIDFile() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let missingPath = FileManager.default.temporaryDirectory
      .appendingPathComponent("missing-uuids-\(UUID().uuidString).txt")
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--uuid-from-file", missingPath.path, "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing UUID file to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchMapsNegativeBooleanFilters() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--not-favorite", "--not-hidden", "--not-shared", "--not-icloud",
      "--not-incloud", "--not-syndicated", "--not-saved-to-library", "--not-shared-moment",
      "--not-shared-library", "--not-in-album", "--not-edited", "--not-external-edit",
      "--not-duplicate", "--not-missing",
      "--no-keyword", "--no-title", "--no-description", "--no-place", "--no-location",
      "--no-comment", "--no-likes",
      "--only-movies", "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.favorite == false)
    #expect(backend.lastQuery?.hidden == false)
    #expect(backend.lastQuery?.shared == false)
    #expect(backend.lastQuery?.iCloud == false)
    #expect(backend.lastQuery?.inCloud == false)
    #expect(backend.lastQuery?.syndicated == false)
    #expect(backend.lastQuery?.savedToLibrary == false)
    #expect(backend.lastQuery?.sharedMoment == false)
    #expect(backend.lastQuery?.sharedLibrary == false)
    #expect(backend.lastQuery?.inAlbum == false)
    #expect(backend.lastQuery?.edited == false)
    #expect(backend.lastQuery?.externalEdit == false)
    #expect(backend.lastQuery?.duplicate == false)
    #expect(backend.lastQuery?.missing == false)
    #expect(backend.lastQuery?.noKeyword == true)
    #expect(backend.lastQuery?.noTitle == true)
    #expect(backend.lastQuery?.noDescription == true)
    #expect(backend.lastQuery?.noPlace == true)
    #expect(backend.lastQuery?.hasLocation == false)
    #expect(backend.lastQuery?.hasComment == false)
    #expect(backend.lastQuery?.hasLikes == false)
    #expect(backend.lastQuery?.mediaType == "video")
  }

  @Test func photosMediaItemsSearchMapsSelectedScope() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--selected", "--limit", "5", "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.selected == true)
    #expect(backend.lastQuery?.limit == 5)
  }

  @Test func photosMediaItemsDumpReturnsFlatTypedRecords() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "dump", "--keyword", "travel", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = data?["items"] as? [[String: Any]]

    #expect(items?.first?["uuid"] as? String == "11111111-1111-1111-1111-111111111111")
    #expect(items?.first?["filename"] as? String == "IMG_0001.JPG")
    #expect(items?.first?["originalFilename"] as? String == "IMG_0001.JPG")
    #expect(items?.first?["favorite"] as? Bool == true)
    #expect(items?.first?["isPhoto"] as? Bool == true)
    #expect(items?.first?["hasRaw"] as? Bool == true)
    #expect(items?.first?["utiRaw"] as? String == "com.adobe.raw-image")
    #expect(items?.first?["pathRaw"] as? String == "/tmp/IMG_0001_4.DNG")
    #expect(backend.lastQuery?.keywords == ["travel"])
  }

  @Test func photosMediaItemsInspectReturnsItemAndDumpRecord() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "inspect", "--uuid", "11111111-1111-1111-1111-111111111111", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let item = data?["item"] as? [String: Any]
    let dump = data?["dump"] as? [String: Any]

    #expect(item?["uuid"] as? String == "11111111-1111-1111-1111-111111111111")
    #expect(dump?["filename"] as? String == "IMG_0001.JPG")
    #expect(dump?["isPhoto"] as? Bool == true)
    #expect(backend.lastQuery?.uuids == ["11111111-1111-1111-1111-111111111111"])
  }

  @Test func photosMediaItemsReadBindsExplicitLibraryToUUIDLookup() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "read",
      "--library", "/tmp/Explicit.photoslibrary",
      "--uuid", "11111111-1111-1111-1111-111111111111",
      "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.libraryPath == "/tmp/Explicit.photoslibrary")
    #expect(backend.lastQuery?.uuids == ["11111111-1111-1111-1111-111111111111"])
    #expect(backend.lastQuery?.limit == 2)
  }

  @Test func photosMediaItemsSearchMapsRepeatedFilenameSelectors() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "media-items", "search",
      "--filename", "IMG_0001",
      "--filename", "IMG_0002",
      "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.lastQuery?.filenames == ["IMG_0001", "IMG_0002"])
    #expect(backend.lastQuery?.filename == "IMG_0001")
  }

  @Test func photosMediaItemsSearchRejectsConflictingBooleanFilters() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--edited", "--not-edited", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected conflicting boolean filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsConflictingLocationPresenceFilters() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--has-location", "--no-location", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected conflicting location presence filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsConflictingTextPresenceFilters() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--place", "Maui", "--no-place", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected conflicting text filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsConflictingCommentLikeFilters() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--has-comment", "--no-comment", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected conflicting comment filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsConflictingMediaTypeAliases() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--media-type", "image", "--only-movies", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected conflicting media type aliases to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsInvalidTimeFilter() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--from-time", "25:00", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected invalid time filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsInvalidRegexFilter() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--regex", "[", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected invalid regex filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemsSearchRejectsInvalidAddedInLastFilter() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "search", "--added-in-last", "tomorrow-ish", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected invalid relative date-added filters to fail validation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosReadOnlyCommandRejectsDryRunOptions() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse(["media-items", "list", "--dry-run", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Photos read-only command to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosLibraryOpenRequiresAllowFlagBeforeBackend() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "libraries", "open", "--library", "/tmp/Test.photoslibrary", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Photos library open to require --allow-external-dispatch.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.openedLibraries.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosLibraryOpenDryRunAndAllowFlagExecutesOpen() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "libraries", "open", "--library", "/tmp/Test.photoslibrary", "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "libraries", "open", "--library", "/tmp/Test.photoslibrary", "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["operation"] as? String == "photos.libraries.open")
    #expect(backend.openedLibraries == ["/tmp/Test.photoslibrary"])
  }

  @Test func photosHookRequiresAllowFlagBeforeDryRun() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "hooks", "query", "--source", "print(\"{}\")", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Photos hook to require allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["gate"] == "strong-gate")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosHookDryRunAndAllowFlagExecutesSource() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "hooks", "query", "--source", "print(\"{}\")", "--allow-eval", "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "hooks", "query", "--source", "print(\"{}\")", "--allow-eval", "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = data?["items"] as? [[String: Any]]

    #expect(items?.first?["uuid"] as? String == "11111111-1111-1111-1111-111111111111")
    #expect(backend.hookRuns == ["query"])
  }

  @Test func photosRawSQLRequiresAllowFlagAndRunsWithAllowFlag() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "database", "query", "--raw-sql", "select * from ZASSET", "--json",
        ]))
      Issue.record("Expected raw SQL diagnostic to require --allow-raw-sql.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["gate"] == "strong-gate")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "database", "query", "--raw-sql", "select * from ZASSET", "--allow-raw-sql", "--json",
        ])))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let rows = data?["rows"] as? [[String: Any]]
    #expect(rows?.first?["uuid"] as? String == "11111111-1111-1111-1111-111111111111")
  }

  @Test func photosDatabaseGrepRequiresAllowFlagBeforeDryRun() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "database", "grep", "--pattern", "Beach", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected database grep to require allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["gate"] == "strong-gate")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosDatabaseGrepDryRunAndAllowFlagExecutesPattern() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "database", "grep", "--pattern", "Beach", "--allow-database-grep", "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "database", "grep", "--pattern", "Beach", "--allow-database-grep", "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let matches = data?["matches"] as? [[String: Any]]

    #expect(matches?.first?["table"] as? String == "ZASSET")
    #expect(backend.databaseGrepPatterns == ["Beach"])
  }

  @Test func photosDatabaseDebugDumpRequiresAllowFlagBeforeDryRun() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "database", "debug-dump", "--dump", "photos", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected database debug dump to require allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["gate"] == "strong-gate")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosDatabaseDebugDumpDryRunAndAllowFlagExecutesSections() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "database", "debug-dump", "--dump", "photos", "--allow-database-debug-dump",
      "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "database", "debug-dump", "--dump", "photos", "--allow-database-debug-dump",
      "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let sections = data?["sections"] as? [[String: Any]]
    let records = sections?.first?["records"] as? [[String: Any]]

    #expect(sections?.first?["name"] as? String == "photos")
    #expect(records?.first?["uuid"] as? String == "11111111-1111-1111-1111-111111111111")
    #expect(backend.databaseDebugDumpSections == [["photos"]])
  }

  @Test func photosDatabaseOrphansRequiresAllowFlagBeforeDryRun() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse([
      "database", "orphans", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected database orphans diagnostic to require allow flag.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["gate"] == "strong-gate")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosDatabaseOrphansDryRunAndAllowFlagExecutesLibrary() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "database", "orphans",
      "--library", "/tmp/Test.photoslibrary",
      "--allow-database-orphans",
      "--dry-run",
      "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))
    let executedOptions = try CLIOptionsFixture.parse([
      "database", "orphans",
      "--library", "/tmp/Test.photoslibrary",
      "--allow-database-orphans",
      "--allow-external-dispatch", "--json",
    ])

    let executed = try #require(try command.run(options: executedOptions))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]

    #expect(records?.first?["kind"] as? String == "package_file_unreferenced")
    #expect(records?.first?["relativePath"] as? String == "originals/o/orphan.jpg")
    #expect(backend.databaseOrphansRuns.map(\.libraryPath) == ["/tmp/Test.photoslibrary"])

    let changed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "database", "orphans",
          "--library", "/tmp/Test.photoslibrary",
          "--output-cap", "128",
          "--allow-database-orphans",
          "--allow-external-dispatch", "--json",
        ])))
    let changedObject = try photosJSONObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]
    let changedRecords = changedData?["records"] as? [[String: Any]]
    #expect(changedRecords?.first?["kind"] as? String == "package_file_unreferenced")
  }

  @Test func photosDatabaseWriteIsProofFailed() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let options = try CLIOptionsFixture.parse(["database", "write", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected direct database write proof failure.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(error.details["proof_status"] == "proof-failed")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosSlideshowStatusReadsBoundedRunningState() throws {
    let backend = FakePhotosBackend()
    backend.slideshowRunningValue = true
    let command = PhotosCommand(backend: backend)

    let result = try #require(
      try command.run(options: CLIOptionsFixture.parse(["slideshow", "status", "--json"])))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(object["ok"] as? Bool == true)
    #expect(data?["running"] as? Bool == true)
    #expect(backend.slideshowRunningReads == 1)

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "slideshow", "running", "--dry-run", "--json",
        ]))
      Issue.record("Expected slideshow status read to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosSlideshowActionsSubmitStateCommandsWithTypedSelectors() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)

    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "slideshow", "start",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--allow-external-dispatch",
          "--json",
        ])))
    let object = try photosJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let summary = data?["summaryFields"] as? [String: Any]

    #expect(data?["operation"] as? String == "photos.slideshow.start")
    #expect(data?["submitted"] as? Bool == true)
    #expect((summary?["uuid_sha256"] as? String)?.isEmpty == false)
    #expect(backend.slideshowActions.first?.action == "start")
    #expect(backend.slideshowActions.first?.query.uuids == ["11111111-1111-1111-1111-111111111111"])
  }

  @Test func photosImportGroupsRelatedFilesAndBindsDuplicatePolicyAndFolderPlacement() throws {
    let backend = FakePhotosBackend()
    backend.folderChildAlbums = []
    let command = PhotosCommand(backend: backend)
    let root = try photosTestTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let original = root.appendingPathComponent("IMG_0102.JPG")
    let raw = root.appendingPathComponent("IMG_0102.DNG")
    let movie = root.appendingPathComponent("IMG_0102.MOV")
    let aae = root.appendingPathComponent("IMG_0102.AAE")
    let edited = root.appendingPathComponent("IMG_0102_edited.JPG")
    let other = root.appendingPathComponent("IMG_0103.JPG")
    for url in [original, raw, movie, aae, edited, other] {
      try Data("fixture".utf8).write(to: url)
    }

    let baseArguments = [
      "imports", "import",
      "--path", edited.path,
      "--path", movie.path,
      "--path", original.path,
      "--path", raw.path,
      "--path", aae.path,
      "--path", other.path,
      "--path", original.path,
      "--album", "Imported",
      "--folder-id", "folder:1",
      "--skip-check-duplicates",
    ]

    let dryRun = try #require(
      try command.run(options: CLIOptionsFixture.parse(baseArguments + ["--dry-run", "--json"])))
    let dryRunObject = try photosJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["group_count"] as? String == "2")
    #expect(summary?["path_count"] as? String == "6")
    #expect(summary?["skip_duplicate_check"] as? String == "true")
    #expect((summary?["groups_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["folder_sha256"] as? String)?.isEmpty == false)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(
          baseArguments + ["--allow-external-dispatch", "--json"])))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = data?["items"] as? [[String: Any]]

    #expect(items?.first?["uuid"] as? String == "11111111-1111-1111-1111-111111111111")
    #expect(backend.createdAlbums == ["Imported"])
    #expect(backend.createdAlbumParents == ["folder:1"])
    #expect(backend.importCalls.first?.albumIDOrName == "album:new")
    #expect(backend.importCalls.first?.skipDuplicateCheck == true)
    #expect(
      backend.importCalls.first?.paths == [
        original.path,
        raw.path,
        movie.path,
        aae.path,
        edited.path,
        other.path,
      ])

    let changedBackend = FakePhotosBackend()
    changedBackend.folderChildAlbums = []
    let changedCommand = PhotosCommand(backend: changedBackend)
    _ = try #require(
      try changedCommand.run(
        options: CLIOptionsFixture.parse([
          "imports", "import",
          "--path", original.path,
          "--album", "Imported",
          "--folder-id", "folder:1",
          "--allow-external-dispatch", "--json",
        ])))
    #expect(changedBackend.importCalls.first?.paths == [original.path])
    #expect(changedBackend.importCalls.first?.skipDuplicateCheck == false)
  }

  @Test func photosImportRejectsMissingPathAndInvalidFolderPlacement() throws {
    let command = PhotosCommand(backend: FakePhotosBackend())
    let root = try photosTestTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let path = root.appendingPathComponent("IMG_0001.JPG")
    try Data("fixture".utf8).write(to: path)

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "imports", "import",
          "--path", root.appendingPathComponent("missing.jpg").path,
          "--dry-run",
          "--json",
        ]))
      Issue.record("Expected missing import path to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "imports", "import",
          "--path", path.path,
          "--folder-id", "folder:1",
          "--dry-run",
          "--json",
        ]))
      Issue.record("Expected folder placement without album to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "imports", "import",
          "--path", path.path,
          "--album-id", "album:1",
          "--folder-id", "folder:1",
          "--dry-run",
          "--json",
        ]))
      Issue.record("Expected folder placement with album id to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosMediaItemUpdateWritesUndoStateAndUndoRestoresTrackedFields() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let root = try photosTestTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let stateDB = root.appendingPathComponent("media-item-undo.json")
    let uuid = "11111111-1111-1111-1111-111111111111"

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--uuid", uuid,
          "--title", "City",
          "--keyword", "night,city",
          "--state-db", stateDB.path,
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect((summary?["state_db_sha256"] as? String)?.isEmpty == false)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--uuid", uuid,
          "--title", "City",
          "--keyword", "night,city",
          "--state-db", stateDB.path,
          "--allow-external-dispatch", "--json",
        ])))
    let executedObject = try photosJSONObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let undoID = try #require(executedData?["undoID"] as? String)
    #expect(FileManager.default.fileExists(atPath: stateDB.path))
    #expect(backend.mediaItemUpdateCalls.first?["title"] == "City")
    #expect(backend.mediaItemUpdateCalls.first?["keyword"] == "night,city")

    let undoDryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "undo",
          "--state-db", stateDB.path,
          "--undo-id", undoID,
          "--dry-run",
          "--json",
        ])))
    let undoDryRunObject = try photosJSONObject(undoDryRun.stdout ?? "")
    let undoDryRunData = undoDryRunObject["data"] as? [String: Any]
    let undoSummary = undoDryRunData?["normalizedArguments"] as? [String: Any]
    #expect(undoSummary?["undo_id"] as? String == undoID)
    #expect(undoSummary?["uuid"] as? String == uuid)

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "undo",
          "--state-db", stateDB.path,
          "--undo-id", undoID,
          "--allow-external-dispatch", "--json",
        ])))
    #expect(backend.mediaItemUpdateCalls.last?["title"] == "Beach")
    #expect(backend.mediaItemUpdateCalls.last?["keyword"] == "travel")

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--uuid", uuid,
          "--album-id", "album:1",
          "--state-db", stateDB.path,
          "--dry-run",
          "--json",
        ]))
    }
  }

  @Test func photosMediaItemUpdateBatchesMutableFieldsAndAlbumMembership() throws {
    let firstUUID = "11111111-1111-1111-1111-111111111111"
    let secondUUID = "22222222-2222-2222-2222-222222222222"
    let backend = FakePhotosBackend()
    backend.mediaItems = [
      PhotosMediaItemRecord(
        id: "asset:1",
        uuid: firstUUID,
        filename: "IMG_0001.JPG",
        title: "Beach",
        description: "Old caption",
        mediaType: "image",
        date: Date(timeIntervalSince1970: 1_700_000_000),
        favorite: true,
        keywords: ["travel"],
        albumIDs: ["album:1"],
        location: PhotosLocationRecord(latitude: 20.0, longitude: -156.0)
      ),
      PhotosMediaItemRecord(
        id: "asset:2",
        uuid: secondUUID,
        filename: "IMG_0002.JPG",
        title: "Forest",
        description: "Old forest",
        mediaType: "image",
        date: Date(timeIntervalSince1970: 1_700_000_100),
        favorite: true,
        keywords: ["forest", "travel"],
        albumIDs: ["album:1"]
      ),
    ]
    let command = PhotosCommand(backend: backend)
    let baseArguments = [
      "media-items", "update",
      "--uuid", firstUUID,
      "--uuid", secondUUID,
      "--description", "Batch caption",
      "--add-keyword", "travel",
      "--add-keyword", "night",
      "--clear-favorite",
      "--date", "2024-01-02T03:04:05Z",
      "--location", "37.3317,-122.0301",
      "--album-id", "album:new",
    ]

    let dryRun = try #require(
      try command.run(options: CLIOptionsFixture.parse(baseArguments + ["--dry-run", "--json"])))
    let dryRunObject = try photosJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect((summary?["fields_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["uuid_sha256"] as? String)?.isEmpty == false)

    let changedBackend = FakePhotosBackend()
    changedBackend.mediaItems = backend.mediaItems
    let changedCommand = PhotosCommand(backend: changedBackend)
    _ = try #require(
      try changedCommand.run(
        options: CLIOptionsFixture.parse(
          baseArguments + ["--add-keyword", "city", "--allow-external-dispatch", "--json"])))
    #expect(changedBackend.mediaItemUpdateCalls[0]["keyword"] == "travel,night,city")
    #expect(changedBackend.mediaItemUpdateCalls[1]["keyword"] == "forest,travel,night,city")

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(baseArguments + ["--allow-external-dispatch", "--json"])))
    let object = try photosJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    #expect(data?["count"] as? Int == 2)
    #expect(backend.lastQuery?.uuids == [firstUUID, secondUUID])
    #expect(backend.mediaItemUpdateCalls.count == 2)
    #expect(backend.mediaItemUpdateCalls[0]["description"] == "Batch caption")
    #expect(backend.mediaItemUpdateCalls[0]["keyword"] == "travel,night")
    #expect(backend.mediaItemUpdateCalls[1]["keyword"] == "forest,travel,night")
    #expect(backend.mediaItemUpdateCalls[0]["favorite"] == "false")
    #expect(backend.mediaItemUpdateCalls[0]["date"] == "2024-01-02T03:04:05.000Z")
    #expect(backend.mediaItemUpdateCalls[0]["location"] == "37.3317,-122.0301")
    #expect(backend.mediaItemUpdateCalls[0]["album-id"] == "album:new")
    #expect(backend.mediaItems?.allSatisfy { $0.albumIDs.contains("album:new") } == true)
    #expect(backend.mediaItems?.allSatisfy { $0.favorite == false } == true)
  }

  @Test func photosMediaItemUpdateRequiresExplicitSelectorAndRejectsAmbiguousMutationOptions()
    throws
  {
    let command = PhotosCommand(backend: FakePhotosBackend())

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--title", "No selector",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--keyword", "replace",
          "--add-keyword", "merge",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--favorite",
          "--clear-favorite",
          "--dry-run",
          "--json",
        ]))
    }
    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "update",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--uuid", "22222222-2222-2222-2222-222222222222",
          "--title", "Two",
          "--state-db", "/tmp/photos-update-state.json",
          "--dry-run",
          "--json",
        ]))
    }
  }

  @Test func photosMetadataTimewarpRequiresStrongGateAndUpdatesDates() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let args = [
      "metadata", "timewarp",
      "--uuid", "11111111-1111-1111-1111-111111111111",
      "--set-date", "2024-01-02T03:04:05Z",
      "--allow-destructive-metadata",
      "--timeout-seconds", "3",
      "--output-cap", "1024",
    ]

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "timewarp",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--set-date", "2024-01-02T03:04:05Z",
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(options: CLIOptionsFixture.parse(args + ["--dry-run", "--json"])))
    let dryRunObject = try photosJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["set_date_sha256"] as? String)?.isEmpty == false)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(args + ["--allow-external-dispatch", "--json"])))
    let executedObject = try photosJSONObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    #expect(executedData?["updated"] as? Int == 1)
    #expect(backend.mediaItemUpdateCalls.first?["date"] == "2024-01-02T03:04:05.000Z")

    let changed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "timewarp",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--set-date", "2024-01-02T03:04:06Z",
          "--allow-destructive-metadata",
          "--timeout-seconds", "3",
          "--output-cap", "1024",
          "--allow-external-dispatch", "--json",
        ])))
    let changedObject = try photosJSONObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]
    #expect(changedData?["updated"] as? Int == 1)
    #expect(backend.mediaItemUpdateCalls.last?["date"] == "2024-01-02T03:04:06.000Z")
  }

  @Test func photosMetadataAddLocationsMatchesTrackBehindStrongGate() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let root = try photosTestTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let track = root.appendingPathComponent("track.json")
    try """
    [
      {"date":"2023-11-14T22:13:20Z","latitude":37.3317,"longitude":-122.0301}
    ]
    """.write(to: track, atomically: true, encoding: .utf8)
    let args = [
      "metadata", "add-locations",
      "--uuid", "11111111-1111-1111-1111-111111111111",
      "--track-file", track.path,
      "--max-match-seconds", "60",
      "--allow-destructive-metadata",
    ]

    let dryRun = try #require(
      try command.run(options: CLIOptionsFixture.parse(args + ["--dry-run", "--json"])))
    let dryRunObject = try photosJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect((summary?["track_content_sha256"] as? String)?.isEmpty == false)

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(args + ["--allow-external-dispatch", "--json"])))
    let executedObject = try photosJSONObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let records = executedData?["records"] as? [[String: Any]]
    #expect(executedData?["updated"] as? Int == 1)
    #expect(records?.first?["submitted"] as? Bool == true)
    #expect(backend.mediaItemUpdateCalls.first?["location"] == "37.3317,-122.0301")
  }

  @Test func photosMetadataSyncSupportsReportOnlyAndDryRunBoundWrites() throws {
    let backend = FakePhotosBackend()
    let command = PhotosCommand(backend: backend)
    let root = try photosTestTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let source = root.appendingPathComponent("sync.json")
    try """
    {
      "11111111-1111-1111-1111-111111111111": {
        "title": "Synced Beach",
        "favorite": false,
        "location": "48.8584,2.2945"
      }
    }
    """.write(to: source, atomically: true, encoding: .utf8)
    let report = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "metadata", "sync",
          "--uuid", "11111111-1111-1111-1111-111111111111",
          "--source-file", source.path,
          "--field", "title",
          "--field", "location",
          "--report-only",
          "--json",
        ])))
    let reportObject = try photosJSONObject(report.stdout ?? "")
    let reportData = reportObject["data"] as? [String: Any]
    #expect(reportData?["planned"] as? Int == 1)
    #expect(reportData?["updated"] as? Int == 0)
    #expect(backend.mediaItemUpdateCalls.isEmpty)

    let args = [
      "metadata", "sync",
      "--uuid", "11111111-1111-1111-1111-111111111111",
      "--source-file", source.path,
      "--field", "title",
      "--field", "location",
      "--allow-destructive-metadata",
    ]
    _ = try #require(
      try command.run(options: CLIOptionsFixture.parse(args + ["--dry-run", "--json"])))

    try """
    {
      "11111111-1111-1111-1111-111111111111": {
        "title": "Changed",
        "location": "48.8584,2.2945"
      }
    }
    """.write(to: source, atomically: true, encoding: .utf8)
    let changed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(args + ["--allow-external-dispatch", "--json"])))
    let changedObject = try photosJSONObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]
    #expect(changedData?["updated"] as? Int == 1)
    #expect(backend.mediaItemUpdateCalls.last?["title"] == "Changed")

    backend.mediaItemUpdateCalls.removeAll()
    try """
    {
      "11111111-1111-1111-1111-111111111111": {
        "title": "Synced Beach",
        "location": "48.8584,2.2945"
      }
    }
    """.write(to: source, atomically: true, encoding: .utf8)
    _ = try #require(
      try command.run(options: CLIOptionsFixture.parse(args + ["--dry-run", "--json"])))
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(args + ["--allow-external-dispatch", "--json"])))
    #expect(backend.mediaItemUpdateCalls.first?["title"] == "Synced Beach")
    #expect(backend.mediaItemUpdateCalls.first?["location"] == "48.8584,2.2945")
  }

  @Test func photosExportAddsResultCategoriesToAlbumsBehindDryRun() throws {
    let backend = FakePhotosBackend()
    backend.exportResult = PhotosExportResult(
      exported: 2,
      skipped: 1,
      missing: 1,
      destination: "/tmp/export",
      exportedUUIDs: ["export-1", "export-2", "export-1"],
      skippedUUIDs: ["skip-1"],
      missingUUIDs: ["missing-1"]
    )
    backend.missingAlbumNames = ["Exported", "Skipped", "Missing"]
    let command = PhotosCommand(backend: backend)
    let args = [
      "exports", "export",
      "--destination", "/tmp/export",
      "--add-exported-to-album", "Exported",
      "--add-skipped-to-album", "Skipped",
      "--add-missing-to-album", "Missing",
    ]

    let dryRun = try #require(
      try command.run(options: CLIOptionsFixture.parse(args + ["--dry-run", "--json"])))
    let dryRunObject = try photosJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect((summary?["add_exported_to_album_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["add_skipped_to_album_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["add_missing_to_album_sha256"] as? String)?.isEmpty == false)
    #expect(backend.albumAddCalls.isEmpty)

    let changedBackend = FakePhotosBackend()
    changedBackend.exportResult = backend.exportResult
    changedBackend.missingAlbumNames = ["Exported", "Skipped", "Changed"]
    let changedCommand = PhotosCommand(backend: changedBackend)
    _ = try #require(
      try changedCommand.run(
        options: CLIOptionsFixture.parse(
          [
            "exports", "export",
            "--destination", "/tmp/export",
            "--add-exported-to-album", "Exported",
            "--add-skipped-to-album", "Skipped",
            "--add-missing-to-album", "Changed",
            "--allow-external-dispatch", "--json",
          ])))
    #expect(changedBackend.albumAddCalls[2].albumIDOrName == "Changed")

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse(args + ["--allow-external-dispatch", "--json"])))
    #expect(backend.albumAddCalls.count == 3)
    #expect(backend.createdAlbums == ["Exported", "Skipped", "Missing"])
    #expect(backend.albumAddCalls[0].albumIDOrName == "Exported")
    #expect(backend.albumAddCalls[0].itemUUIDs == ["export-1", "export-2"])
    #expect(backend.albumAddCalls[1].albumIDOrName == "Skipped")
    #expect(backend.albumAddCalls[1].itemUUIDs == ["skip-1"])
    #expect(backend.albumAddCalls[2].albumIDOrName == "Missing")
    #expect(backend.albumAddCalls[2].itemUUIDs == ["missing-1"])

    let executedObject = try photosJSONObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let albumAdds = try #require(executedData?["albumAdds"] as? [[String: Any]])
    #expect(albumAdds.count == 3)
    #expect(albumAdds.allSatisfy { $0["albumCreated"] as? Bool == true })
    #expect(
      Set(albumAdds.compactMap { $0["category"] as? String })
        == Set(["exported", "skipped", "missing"]))
  }
}

private final class FakePhotosBackend: PhotosAutomating, @unchecked Sendable {
  var openedLibraries: [String] = []
  var hookRuns: [String] = []
  var databaseGrepPatterns: [String] = []
  var databaseDebugDumpSections: [[String]] = []
  var databaseOrphansRuns: [PhotosQuery] = []
  var slideshowRunningValue = false
  var slideshowRunningReads = 0
  var slideshowActions: [(action: String, query: PhotosQuery)] = []
  var mediaItemUpdateCalls: [[String: String]] = []
  var albumAddCalls: [(albumIDOrName: String, itemUUIDs: [String])] = []
  var importCalls: [(paths: [String], albumIDOrName: String?, skipDuplicateCheck: Bool)] = []
  var createdAlbums: [String] = []
  var createdAlbumParents: [String?] = []
  var missingAlbumNames: Set<String> = []
  var folderChildAlbums: [PhotosAlbumRecord]? = [
    PhotosAlbumRecord(id: "album:1", name: "Travel", parentID: "folder:1")
  ]
  var mediaItems: [PhotosMediaItemRecord]?
  var exportResult: PhotosExportResult?
  var lastQuery: PhotosQuery?

  func listLibraries() throws -> [PhotosLibraryRecord] {
    [
      PhotosLibraryRecord(
        id: "library:system",
        name: "System Library",
        path: "/Users/example/Pictures/Photos Library.photoslibrary",
        version: "10.0",
        isSystemLibrary: true
      )
    ]
  }

  func libraryInfo(path: String?) throws -> PhotosLibraryRecord {
    PhotosLibraryRecord(
      id: "library:system",
      name: "System Library",
      path: path ?? "/Users/example/Pictures/Photos Library.photoslibrary",
      version: "10.0",
      isSystemLibrary: true,
      counts: ["all": 3, "photos": 2, "videos": 1]
    )
  }

  func databaseInfo(path: String?) throws -> PhotosLibraryRecord {
    PhotosLibraryRecord(
      id: "library:system",
      name: "System Library",
      path: path ?? "/Users/example/Pictures/Photos Library.photoslibrary",
      version: "5",
      isSystemLibrary: true,
      databasePath: "/Users/example/Pictures/Photos Library.photoslibrary/database/Photos.sqlite",
      databaseVersion: "5001",
      modelVersion: "13703",
      photosVersion: "5"
    )
  }

  func compareLibraries(libraryA: String?, libraryB: String, signatureTemplate: String?) throws
    -> PhotosLibraryCompareReport
  {
    PhotosLibraryCompareReport(
      libraryA: libraryA ?? "/Users/example/Pictures/Photos Library.photoslibrary",
      libraryB: libraryB,
      same: [
        PhotosLibraryComparePair(
          uuidA: sampleItem.uuid,
          uuidB: sampleItem.uuid,
          filename: sampleItem.filename,
          signature: signatureTemplate ?? sampleItem.filename
        )
      ]
    )
  }

  func openLibrary(path: String) throws -> Bool {
    openedLibraries.append(path)
    return true
  }

  func backupLibrary(path: String?, destination: String) throws -> Bool { true }

  func listAlbums(query: PhotosQuery) throws -> [PhotosAlbumRecord] {
    lastQuery = query
    return [PhotosAlbumRecord(id: "album:1", name: "Travel", itemCount: 1)]
  }

  func readAlbum(idOrName: String, query: PhotosQuery, includeItems: Bool) throws
    -> PhotosAlbumRecord
  {
    if missingAlbumNames.contains(idOrName) {
      throw CLIError(code: .notFound, message: "Photos album was not found.")
    }
    return PhotosAlbumRecord(
      id: idOrName,
      name: "Travel",
      itemCount: includeItems ? 1 : nil,
      mediaItems: includeItems ? [sampleItem] : nil
    )
  }

  func createAlbum(name: String, parentFolderID: String?) throws -> PhotosAlbumRecord {
    createdAlbums.append(name)
    createdAlbumParents.append(parentFolderID)
    return PhotosAlbumRecord(id: "album:new", name: name, parentID: parentFolderID)
  }

  func deleteAlbum(idOrName: String) throws -> Bool { true }
  func addItemsToAlbum(albumIDOrName: String, itemUUIDs: [String]) throws -> Bool {
    albumAddCalls.append((albumIDOrName: albumIDOrName, itemUUIDs: itemUUIDs))
    return true
  }

  func listFolders(query: PhotosQuery) throws -> [PhotosFolderRecord] {
    [PhotosFolderRecord(id: "folder:1", name: "Trips", childCount: 1)]
  }

  func readFolder(idOrName: String, query: PhotosQuery, includeChildren: Bool) throws
    -> PhotosFolderRecord
  {
    PhotosFolderRecord(
      id: idOrName,
      name: "Trips",
      childCount: includeChildren ? 1 : nil,
      childContainers: includeChildren
        ? [PhotosContainerRecord(id: "album:1", name: "Travel", kind: "album", parentID: idOrName)]
        : nil,
      childAlbums: includeChildren ? folderChildAlbums : nil
    )
  }

  func createFolder(name: String, parentFolderID: String?) throws -> PhotosFolderRecord {
    PhotosFolderRecord(id: "folder:new", name: name, parentID: parentFolderID)
  }

  func deleteFolder(idOrName: String) throws -> Bool { true }

  func listMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    lastQuery = query
    return mediaItems ?? [sampleItem]
  }

  func searchMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    lastQuery = query
    let candidates = mediaItems ?? [sampleItem]
    guard !query.uuids.isEmpty else {
      return candidates
    }
    let wanted = Set(query.uuids)
    return candidates.filter { wanted.contains($0.uuid) }
  }

  func readMediaItem(uuid: String, query: PhotosQuery, include: Set<String>, maxBytes: Int) throws
    -> PhotosMediaItemRecord
  {
    lastQuery = query
    return mediaItems?.first { $0.uuid == uuid } ?? sampleItem
  }

  func updateMediaItem(uuid: String, fields: [String: String]) throws -> PhotosMediaItemRecord {
    mediaItemUpdateCalls.append(fields)
    var item = mediaItems?.first { $0.uuid == uuid } ?? sampleItem
    if let title = fields["title"] {
      item.title = title
    }
    if let description = fields["description"] {
      item.description = description
    }
    if let keyword = fields["keyword"] {
      item.keywords = photosCommandTestList(keyword)
    }
    if let favorite = fields["favorite"] {
      item.favorite = favorite == "true"
    }
    if let date = fields["date"], let parsedDate = ISO8601DateFormatter().date(from: date) {
      item.date = parsedDate
    }
    if let location = fields["location"] {
      let parts = photosCommandTestList(location)
      if parts.count == 2, let latitude = Double(parts[0]), let longitude = Double(parts[1]) {
        item.location = PhotosLocationRecord(latitude: latitude, longitude: longitude)
      }
    }
    if let albumID = fields["album-id"], !item.albumIDs.contains(albumID) {
      item.albumIDs.append(albumID)
    }
    if var mediaItems {
      if let index = mediaItems.firstIndex(where: { $0.uuid == uuid }) {
        mediaItems[index] = item
      } else {
        mediaItems.append(item)
      }
      self.mediaItems = mediaItems
    }
    return item
  }

  func duplicateMediaItem(uuid: String) throws -> PhotosMediaItemRecord { sampleItem }
  func listSelection(limit: Int?) throws -> [PhotosMediaItemRecord] { [sampleItem] }

  func importItems(paths: [String], albumIDOrName: String?, skipDuplicateCheck: Bool) throws
    -> [PhotosMediaItemRecord]
  {
    importCalls.append(
      (paths: paths, albumIDOrName: albumIDOrName, skipDuplicateCheck: skipDuplicateCheck))
    return [sampleItem]
  }

  func exportItems(plan: PhotosExportPlan) throws -> PhotosExportResult {
    var result = exportResult ?? PhotosExportResult(exported: 1, destination: plan.destination)
    result.destination = plan.destination
    return result
  }

  func exportReport(stateDB: String?, runID: String?) throws -> PhotosExportReport {
    PhotosExportReport(runID: runID ?? "run:1", exported: 1)
  }

  func metadataValues(kind: String, query: PhotosQuery) throws -> PhotosMetadataAggregate {
    PhotosMetadataAggregate(values: ["travel"], counts: ["travel": 1])
  }

  func writeSidecar(format: String, query: PhotosQuery, destination: String, template: String?)
    throws
    -> Bool
  { true }
  func writeExif(
    fields: [String],
    query: PhotosQuery,
    destination: String?,
    exiftoolPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> Bool { true }

  func queryDatabase(query: PhotosQuery, rawSQL: String?) throws -> [[String: String]] {
    [["uuid": sampleItem.uuid, "filename": sampleItem.filename]]
  }

  func grepDatabase(
    query: PhotosQuery,
    pattern: String,
    ignoreCase: Bool,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseGrepMatch] {
    databaseGrepPatterns.append(pattern)
    return [
      PhotosDatabaseGrepMatch(
        table: "ZASSET",
        column: "ZTITLE",
        rowID: "0",
        value: "Beach"
      )
    ]
  }

  func debugDumpDatabase(
    query: PhotosQuery,
    sections: [String],
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseDebugDumpSection] {
    databaseDebugDumpSections.append(sections)
    return sections.map { section in
      PhotosDatabaseDebugDumpSection(
        name: section,
        records: [
          [
            "uuid": sampleItem.uuid,
            "filename": sampleItem.filename,
          ]
        ]
      )
    }
  }

  func findDatabaseOrphans(
    query: PhotosQuery,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosDatabaseOrphansReport {
    databaseOrphansRuns.append(query)
    return PhotosDatabaseOrphansReport(
      query: query,
      libraryPath: query.libraryPath ?? "/Users/example/Pictures/Photos Library.photoslibrary",
      records: [
        PhotosDatabaseOrphanRecord(
          kind: "package_file_unreferenced",
          resourceKind: "original",
          path: "/Users/example/Pictures/Photos Library.photoslibrary/originals/o/orphan.jpg",
          relativePath: "originals/o/orphan.jpg",
          reason: "library package resource file is not referenced by a normalized media record"
        )
      ]
    )
  }

  func renderTemplate(template: String, query: PhotosQuery) throws -> [String] {
    ["IMG_0001.JPG"]
  }

  func runHook(
    kind: String, source: String, input: PhotoHookInput, timeoutSeconds: Int, outputCap: Int
  )
    throws -> PhotoHookOutput
  {
    hookRuns.append(kind)
    return PhotoHookOutput(accepted: true, values: ["kind": kind])
  }

  func runPostCommand(
    command: String,
    category: String,
    input: PhotoHookInput,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosActionResult {
    PhotosActionResult(operation: "photos.post-commands.run", submitted: true)
  }

  func slideshowRunning() throws -> Bool {
    slideshowRunningReads += 1
    return slideshowRunningValue
  }

  func slideshow(action: String, query: PhotosQuery) throws -> Bool {
    slideshowActions.append((action: action, query: query))
    return true
  }
  func showSpotlight(selector: String) throws -> Bool { true }

  private var sampleItem: PhotosMediaItemRecord {
    PhotosMediaItemRecord(
      id: "asset:1",
      uuid: "11111111-1111-1111-1111-111111111111",
      filename: "IMG_0001.JPG",
      title: "Beach",
      mediaType: "image",
      date: Date(timeIntervalSince1970: 1_700_000_000),
      timeZoneOffsetSeconds: 0,
      favorite: true,
      keywords: ["travel"],
      persons: ["Ana"],
      albumIDs: ["album:1"],
      location: PhotosLocationRecord(latitude: 20.0, longitude: -156.0),
      traits: ["raw"],
      rawPath: "/tmp/IMG_0001_4.DNG",
      rawUTI: "com.adobe.raw-image",
      rawOriginal: true
    )
  }
}

private func photosJSONObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw PhotosCommandTestError.notObject
  }
  return object
}

private func photosCommandTestList(_ value: String) -> [String] {
  value
    .split(whereSeparator: { $0 == "," || $0 == "\n" })
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
}

private enum PhotosCommandTestError: Error {
  case notObject
}
