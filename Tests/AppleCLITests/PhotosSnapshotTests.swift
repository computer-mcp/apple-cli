import Foundation
import PhotosCLI
import SQLite3
import Testing
import Utility

@Suite
struct PhotosSnapshotTests {
  @Test func photosSnapshotBackendReadsSyntheticPhotosLibrary() throws {
    let fixture = try makePhotosLibraryFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "list", "--library", fixture.library.path, "--keyword", "travel", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosSnapshotJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = data?["items"] as? [[String: Any]]

    #expect(items?.count == 1)
    #expect(items?.first?["uuid"] as? String == "asset-1")
    #expect(items?.first?["filename"] as? String == "IMG_0001.JPG")
    #expect(FileManager.default.fileExists(atPath: fixture.database.path))
  }

  @Test func photosMediaItemIDUsesUUIDBackedLocalShape() throws {
    let fixture = try makePhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let items = try backend.listMediaItems(query: PhotosQuery(libraryPath: fixture.library.path))
    let item = try #require(items.first)
    #expect(item.uuid == "asset-1")
    #expect(item.id == "photos-media-item:asset-1")

    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "read",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--json",
        ])))
    let object = try photosSnapshotJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let readItem = try #require(data?["item"] as? [String: Any])

    #expect(readItem["uuid"] as? String == "asset-1")
    #expect(readItem["id"] as? String == "photos-media-item:asset-1")
  }

  @Test func photosSnapshotBackendRejectsMissingDatabase() throws {
    let root = try temporaryDirectory()
    let library = root.appendingPathComponent("Empty.photoslibrary", isDirectory: true)
    try FileManager.default.createDirectory(at: library, withIntermediateDirectories: true)
    let backend = PhotosLibrarySnapshotBackend()

    do {
      _ = try backend.listMediaItems(query: PhotosQuery(libraryPath: library.path))
      Issue.record("Expected missing Photos database to fail.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosLibraryInfoRejectsMissingExplicitLibrary() throws {
    let root = try temporaryDirectory()
    let missingLibrary = root.appendingPathComponent("Missing.photoslibrary", isDirectory: true)
    let backend = PhotosLibrarySnapshotBackend()

    do {
      _ = try backend.libraryInfo(path: missingLibrary.path)
      Issue.record("Expected missing explicit Photos library to fail.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
      #expect(error.details["path"] == missingLibrary.path)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func photosLibraryDiscoveryMatchesOsxphotosSourcesAndDefaultOrder() throws {
    let home = try temporaryDirectory()
    let pictures = home.appendingPathComponent("Pictures", isDirectory: true)
    let external = home.appendingPathComponent("External", isDirectory: true)
    let indexed = home.appendingPathComponent("Indexed", isDirectory: true)
    try FileManager.default.createDirectory(at: pictures, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: indexed, withIntermediateDirectories: true)

    let defaultLibrary = pictures.appendingPathComponent(
      "Photos Library.photoslibrary", isDirectory: true)
    let otherPicturesLibrary = pictures.appendingPathComponent(
      "Other.photoslibrary", isDirectory: true)
    let lastLibrary = external.appendingPathComponent("Last.photoslibrary", isDirectory: true)
    let systemLibrary = external.appendingPathComponent("System.photoslibrary", isDirectory: true)
    let spotlightLibrary = indexed.appendingPathComponent(
      "Spotlight.photoslibrary", isDirectory: true)

    for library in [
      defaultLibrary, otherPicturesLibrary, lastLibrary, systemLibrary, spotlightLibrary,
    ] {
      try FileManager.default.createDirectory(at: library, withIntermediateDirectories: true)
    }

    try writePropertyList(
      ["SystemLibraryPath": systemLibrary.path],
      to: home.appendingPathComponent(
        "Library/Containers/com.apple.photolibraryd/Data/Library/Preferences/com.apple.photolibraryd.plist"
      )
    )
    let bookmark = try lastLibrary.bookmarkData(
      options: [],
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    )
    try writePropertyList(
      ["IPXDefaultLibraryURLBookmark": bookmark],
      to: home.appendingPathComponent(
        "Library/Containers/com.apple.Photos/Data/Library/Preferences/com.apple.Photos.plist"
      )
    )

    let backend = PhotosLibrarySnapshotBackend(
      homeDirectory: home,
      spotlightLibraryPaths: {
        [
          spotlightLibrary.path,
          defaultLibrary.path + "/",
        ]
      }
    )

    let libraries = try backend.listLibraries()
    let paths = libraries.map(\.path)

    #expect(paths.contains(defaultLibrary.path))
    #expect(paths.contains(otherPicturesLibrary.path))
    #expect(paths.contains(lastLibrary.path))
    #expect(paths.contains(systemLibrary.path))
    #expect(paths.contains(spotlightLibrary.path))
    #expect(paths.filter { $0 == defaultLibrary.path }.count == 1)
    #expect(libraries.first(where: { $0.path == systemLibrary.path })?.isSystemLibrary == true)
    #expect(libraries.first(where: { $0.path == lastLibrary.path })?.isLastOpenedLibrary == true)
    #expect(try backend.libraryInfo(path: nil).path == lastLibrary.path)
  }

  @Test func photosSnapshotQueriesUseResolvedDefaultLibrary() throws {
    let fixture = try makePhotosBackendFixture()
    let home = try temporaryDirectory()
    let external = home.appendingPathComponent("External", isDirectory: true)
    let lastLibrary = external.appendingPathComponent("Last.photoslibrary", isDirectory: true)
    try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
    try FileManager.default.copyItem(at: fixture.library, to: lastLibrary)
    try writePropertyList(
      ["IPXDefaultLibraryPath": lastLibrary.path],
      to: home.appendingPathComponent(
        "Library/Containers/com.apple.Photos/Data/Library/Preferences/com.apple.Photos.plist"
      )
    )
    let backend = PhotosLibrarySnapshotBackend(
      homeDirectory: home,
      spotlightLibraryPaths: { [] }
    )

    let items = try backend.listMediaItems(query: PhotosQuery())

    #expect(items.map(\.uuid) == ["asset-1", "asset-2", "asset-3"])
  }

  @Test func photosSnapshotBackendReadsModernDatabaseVersionMetadata() throws {
    let fixture = try makePhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let library = try backend.databaseInfo(path: fixture.library.path)

    #expect(library.databasePath == fixture.database.path)
    #expect(library.databaseVersion == "5001")
    #expect(library.modelVersion == "13703")
    #expect(library.photosVersion == "5")
  }

  @Test func photosLibraryInfoReadsSnapshotCounts() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let library = try backend.libraryInfo(path: fixture.library.path)
    let counts = try #require(library.counts)

    #expect(library.databasePath == fixture.database.path)
    #expect(counts["all"] == 3)
    #expect(counts["all_photos"] == 2)
    #expect(counts["all_videos"] == 1)
    #expect(counts["all_photos_app"] == 1)
    #expect(counts["photos"] == 1)
    #expect(counts["videos"] == 0)
    #expect(counts["hidden"] == 1)
    #expect(counts["hidden_videos"] == 1)
    #expect(counts["favorite"] == 1)
    #expect(counts["cloud_asset"] == 1)
    #expect(counts["incloud"] == 1)
    #expect(counts["shared"] == 1)
    #expect(counts["syndicated"] == 1)
    #expect(counts["syndicated_saved_to_library"] == 1)
    #expect(counts["shared_library"] == 1)
    #expect(counts["shared_moment"] == 1)
    #expect(counts["missing"] == 1)
    #expect(counts["location"] == 2)
    #expect(counts["has_raw"] == 1)
    #expect(counts["has_keywords"] == 2)
    #expect(counts["has_title"] == 2)
    #expect(counts["has_caption"] == 2)
    #expect(counts["persons_count"] == 2)
    #expect(counts["keywords_count"] == 3)
    #expect(counts["albums_count"] == 1)
    #expect(counts["folders"] == 2)
  }

  @Test func photosSnapshotBackendAggregatesMetadataCounts() throws {
    let fixture = try makePhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let keywords = try backend.metadataValues(
      kind: "keywords",
      query: PhotosQuery(libraryPath: fixture.library.path)
    )
    let places = try backend.metadataValues(
      kind: "places",
      query: PhotosQuery(libraryPath: fixture.library.path)
    )

    #expect(keywords.counts["travel"] == 1)
    #expect(keywords.counts["beach"] == 1)
    #expect(keywords.values == ["beach", "travel"])
    #expect(places.counts["_UNKNOWN_"] == 1)
    #expect(places.values == ["_UNKNOWN_"])
  }

  @Test func photosSnapshotBackendNormalizesAlbumAndFolderContainers() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let albums = try backend.listAlbums(query: PhotosQuery(libraryPath: fixture.library.path))
    let folders = try backend.listFolders(query: PhotosQuery(libraryPath: fixture.library.path))

    #expect(albums.map(\.id) == ["album-travel"])
    #expect(albums.first?.name == "Travel")
    #expect(albums.first?.parentID == "folder-sub")
    #expect(albums.first?.itemCount == 2)
    #expect(folders.map(\.id) == ["folder-trips", "folder-sub"])
    #expect(folders.map(\.name) == ["Trips", "SubFolder"])
    #expect(folders.first(where: { $0.id == "folder-trips" })?.parentID == nil)
    #expect(folders.first(where: { $0.id == "folder-sub" })?.parentID == "folder-trips")
  }

  @Test func photosSnapshotBackendReadsSharedAlbumCountsAndSelectors() throws {
    let fixture = try makePhotosBackendFixture()
    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      """
      INSERT INTO ZGENERICALBUM (Z_PK, ZUUID, ZTITLE, ZKIND, ZPARENTFOLDER, ZTRASHEDSTATE)
      VALUES (13, 'album-shared', 'Shared Trip', 1505, NULL, 0);
      INSERT INTO Z_1ASSETS (Z_1ALBUMS, Z_3ASSETS, Z_FOK_3ASSETS)
      VALUES (13, 2, 2);
      """
    )

    let backend = PhotosLibrarySnapshotBackend()
    let albums = try backend.listAlbums(query: PhotosQuery(libraryPath: fixture.library.path))
    let sharedAlbum = try #require(albums.first(where: { $0.id == "album-shared" }))

    #expect(sharedAlbum.name == "Shared Trip")
    #expect(sharedAlbum.specialKind == "shared")
    #expect(sharedAlbum.itemCount == 1)

    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let output = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "search",
          "--library", fixture.library.path,
          "--album", "Shared Trip",
          "--json",
        ])))
    let object = try photosSnapshotJSONObject(output.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = try #require(data?["items"] as? [[String: Any]])

    #expect(items.map { $0["uuid"] as? String }.compactMap { $0 } == ["asset-2"])
  }

  @Test func photosAlbumAndFolderReadIncludeTypedElementChildren() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    let albumOutput = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "albums", "read",
          "--library", fixture.library.path,
          "--album-id", "album-travel",
          "--include", "items",
          "--json",
        ])))
    let albumObject = try photosSnapshotJSONObject(albumOutput.stdout ?? "")
    let albumData = albumObject["data"] as? [String: Any]
    let album = try #require(albumData?["album"] as? [String: Any])
    let mediaItems = try #require(album["mediaItems"] as? [[String: Any]])

    #expect(album["id"] as? String == "album-travel")
    #expect(album["parentID"] as? String == "folder-sub")
    #expect(
      mediaItems.map { $0["uuid"] as? String }.compactMap { $0 }.sorted() == [
        "asset-1", "asset-2",
      ])

    let rootFolderOutput = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "folders", "read",
          "--library", fixture.library.path,
          "--folder-id", "folder-trips",
          "--include", "children",
          "--json",
        ])))
    let rootFolderObject = try photosSnapshotJSONObject(rootFolderOutput.stdout ?? "")
    let rootFolderData = rootFolderObject["data"] as? [String: Any]
    let rootFolder = try #require(rootFolderData?["folder"] as? [String: Any])
    let childFolders = try #require(rootFolder["childFolders"] as? [[String: Any]])
    let childContainers = try #require(rootFolder["childContainers"] as? [[String: Any]])

    #expect(childFolders.map { $0["id"] as? String }.compactMap { $0 } == ["folder-sub"])
    #expect(childContainers.map { $0["kind"] as? String }.compactMap { $0 } == ["folder"])

    let nestedFolderOutput = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "folders", "read",
          "--library", fixture.library.path,
          "--folder-id", "folder-sub",
          "--include", "children",
          "--json",
        ])))
    let nestedFolderObject = try photosSnapshotJSONObject(nestedFolderOutput.stdout ?? "")
    let nestedFolderData = nestedFolderObject["data"] as? [String: Any]
    let nestedFolder = try #require(nestedFolderData?["folder"] as? [String: Any])
    let childAlbums = try #require(nestedFolder["childAlbums"] as? [[String: Any]])

    #expect(childAlbums.map { $0["id"] as? String }.compactMap { $0 } == ["album-travel"])
  }

  @Test func photosSDEFElementRowsUseSnapshotSemanticProjection() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    let searchOutput = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "search",
          "--library", fixture.library.path,
          "--title", "Beach",
          "--person", "Ana",
          "--json",
        ])))
    let searchObject = try photosSnapshotJSONObject(searchOutput.stdout ?? "")
    let searchData = searchObject["data"] as? [String: Any]
    let searchItems = try #require(searchData?["items"] as? [[String: Any]])
    let searchQuery = try #require(searchData?["query"] as? [String: Any])
    let item = try #require(searchItems.first)

    #expect(searchItems.count == 1)
    #expect(searchQuery["titles"] as? [String] == ["Beach"])
    #expect(searchQuery["persons"] as? [String] == ["Ana"])
    #expect(item["id"] as? String == "photos-media-item:asset-1")
    #expect(item["uuid"] as? String == "asset-1")
    #expect(item["title"] as? String == "Beach")
    #expect(item["description"] as? String == "At the beach")
    #expect(item["favorite"] as? Bool == true)
    #expect(item["keywords"] as? [String] == ["travel", "beach"])
    #expect(item["persons"] as? [String] == ["Ana"])
    #expect(item["albumPaths"] as? [String] == ["Trips/SubFolder/Travel"])
    #expect(item["folderPaths"] as? [String] == ["Trips/SubFolder"])

    let albumOutput = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "albums", "read",
          "--library", fixture.library.path,
          "--album-id", "album-travel",
          "--include", "items",
          "--json",
        ])))
    let albumObject = try photosSnapshotJSONObject(albumOutput.stdout ?? "")
    let albumData = albumObject["data"] as? [String: Any]
    let album = try #require(albumData?["album"] as? [String: Any])
    let albumItems = try #require(album["mediaItems"] as? [[String: Any]])

    #expect(album["id"] as? String == "album-travel")
    #expect(album["name"] as? String == "Travel")
    #expect(album["parentID"] as? String == "folder-sub")
    #expect(album["itemCount"] as? Int == 2)
    #expect(
      albumItems.map { $0["id"] as? String }.compactMap { $0 }.sorted() == [
        "photos-media-item:asset-1",
        "photos-media-item:asset-2",
      ])

    let folderOutput = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "folders", "read",
          "--library", fixture.library.path,
          "--folder-id", "folder-sub",
          "--include", "children",
          "--json",
        ])))
    let folderObject = try photosSnapshotJSONObject(folderOutput.stdout ?? "")
    let folderData = folderObject["data"] as? [String: Any]
    let folder = try #require(folderData?["folder"] as? [String: Any])
    let childContainers = try #require(folder["childContainers"] as? [[String: Any]])
    let childAlbums = try #require(folder["childAlbums"] as? [[String: Any]])

    #expect(folder["id"] as? String == "folder-sub")
    #expect(folder["name"] as? String == "SubFolder")
    #expect(folder["parentID"] as? String == "folder-trips")
    #expect(childContainers.map { $0["id"] as? String }.compactMap { $0 } == ["album-travel"])
    #expect(childContainers.map { $0["kind"] as? String }.compactMap { $0 } == ["album"])
    #expect(childContainers.map { $0["parentID"] as? String }.compactMap { $0 } == ["folder-sub"])
    #expect(childAlbums.map { $0["id"] as? String }.compactMap { $0 } == ["album-travel"])
  }

  @Test func photosSnapshotBackendGrepsReadOnlySnapshotWithRegexAndCaps() throws {
    let fixture = try makePhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let matches = try backend.grepDatabase(
      query: PhotosQuery(libraryPath: fixture.library.path, limit: 1),
      pattern: "beach",
      ignoreCase: true,
      timeoutSeconds: 10,
      outputCap: 8
    )

    #expect(matches.count == 1)
    #expect(matches.first?.column == "ZTITLE")
    #expect(matches.first?.value == "Beach")
    #expect(matches.first?.truncated == false)
  }

  @Test func photosCompositeBackendDebugDumpsStructuredSnapshotSections() throws {
    let fixture = try makePhotosLibraryFixture()
    let backend = PhotosCompositeBackend()

    let sections = try backend.debugDumpDatabase(
      query: PhotosQuery(libraryPath: fixture.library.path),
      sections: ["photos", "keywords"],
      timeoutSeconds: 10,
      outputCap: 1024
    )

    #expect(sections.map(\.name) == ["photos", "keywords"])
    #expect(sections.first?.records.first?["uuid"] == "asset-1")
    #expect(sections.first?.records.first?["filename"] == "IMG_0001.JPG")
    #expect(sections.last?.records.map { $0["value"] ?? "" }.sorted() == ["beach", "travel"])
  }

  @Test func photosCompositeBackendFindsDatabaseOrphansFromReadOnlySnapshot() throws {
    let fixture = try makePhotosBackendFixture()
    let orphanDirectory = fixture.library.appendingPathComponent("originals/z", isDirectory: true)
    try FileManager.default.createDirectory(at: orphanDirectory, withIntermediateDirectories: true)
    let orphanFile = orphanDirectory.appendingPathComponent("ORPHAN.JPG")
    try Data("orphan".utf8).write(to: orphanFile)

    let backend = PhotosCompositeBackend()
    let report = try backend.findDatabaseOrphans(
      query: PhotosQuery(libraryPath: fixture.library.path),
      timeoutSeconds: 10,
      outputCap: 65_536
    )

    let packageOrphan = try #require(
      report.records.first { $0.relativePath == "originals/z/ORPHAN.JPG" })
    #expect(packageOrphan.kind == "package_file_unreferenced")
    #expect(packageOrphan.resourceKind == "original")
    #expect(
      URL(fileURLWithPath: packageOrphan.path).standardizedFileURL.path
        == orphanFile.standardizedFileURL.path)
    #expect(
      packageOrphan.reason
        == "library package resource file is not referenced by a normalized media record")

    let missingOriginal = try #require(
      report.records.first { $0.kind == "database_missing_file" && $0.uuid == "asset-3" })
    #expect(missingOriginal.resourceKind == "original")
    #expect(missingOriginal.filename == "IMG_0003.MOV")
    #expect(report.truncated == false)
  }

  @Test func photosSnapshotBackendReadsLegacyDatabaseVersionMetadata() throws {
    let fixture = try makeLegacyPhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let library = try backend.databaseInfo(path: fixture.library.path)

    #expect(library.databasePath == fixture.database.path)
    #expect(library.databaseVersion == "3301")
    #expect(library.modelVersion == nil)
    #expect(library.photosVersion == "3")
  }

  @Test func photosSnapshotBackendNormalizesPhotosDatabaseSemantics() throws {
    let fixture = try makePhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()
    let directItems = try backend.listMediaItems(
      query: PhotosQuery(libraryPath: fixture.library.path))
    #expect(directItems.first?.width == 4032)
    #expect(directItems.first?.height == 3024)

    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "list", "--library", fixture.library.path, "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosSnapshotJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = try #require(data?["items"] as? [[String: Any]])
    let item = try #require(items.first)

    #expect(items.count == 1)
    #expect(item["uuid"] as? String == "asset-1")
    #expect(item["filename"] as? String == "IMG_0001.JPG")
    #expect(item["mediaType"] as? String == "image")
    #expect(item["width"] as? Int == 4032)
    #expect(item["height"] as? Int == 3024)
    #expect(item["date"] as? String == "2024-04-18T00:09:25Z")
    #expect(item["description"] as? String == "At the beach")
    #expect(item["keywords"] as? [String] == ["beach", "travel"])
    #expect(item["location"] == nil)
  }

  @Test func photosMediaItemsReadUsesExplicitLibrarySnapshot() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let output = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "read",
          "--library", fixture.library.path,
          "--uuid", "asset-2",
          "--json",
        ])))
    let object = try photosSnapshotJSONObject(output.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let item = try #require(data?["item"] as? [String: Any])

    #expect(item["uuid"] as? String == "asset-2")
    #expect(item["filename"] as? String == "IMG_0002.JPG")
  }

  @Test func photosMediaItemsInspectReportsAmbiguousFilenameAndPathSelectors() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "inspect",
          "--library", fixture.library.path,
          "--filename", "IMG_000",
          "--json",
        ]))
      Issue.record("Expected ambiguous filename selector to throw.")
    } catch let error as CLIError {
      #expect(error.code == .ambiguousIdentity)
      #expect(error.details["filename"] == "IMG_000")
      #expect(error.details["matches"] == "3")
    }

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "media-items", "inspect",
          "--library", fixture.library.path,
          "--original-path", "originals",
          "--json",
        ]))
      Issue.record("Expected ambiguous original path selector to throw.")
    } catch let error as CLIError {
      #expect(error.code == .ambiguousIdentity)
      #expect(error.details["original_path_sha256"] != nil)
      #expect(Int(error.details["matches"] ?? "0", radix: 10) ?? 0 >= 2)
    }
  }

  @Test func photosMediaItemsDumpUsesSnapshotNormalizedFields() throws {
    let fixture = try makePhotosLibraryFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "dump", "--library", fixture.library.path, "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosSnapshotJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = try #require(data?["items"] as? [[String: Any]])
    let item = try #require(items.first)

    #expect(item["uuid"] as? String == "asset-1")
    #expect(item["filename"] as? String == "IMG_0001.JPG")
    #expect(item["originalFilename"] as? String == "IMG_0001.JPG")
    #expect(item["title"] as? String == "Beach")
    #expect(item["description"] as? String == "At the beach")
    #expect(item["favorite"] as? Bool == true)
    #expect(item["isPhoto"] as? Bool == true)
  }

  @Test func photosMediaItemsInspectUsesSnapshotNormalizedFields() throws {
    let fixture = try makePhotosLibraryFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let options = try CLIOptionsFixture.parse([
      "media-items", "inspect", "--library", fixture.library.path, "--uuid", "asset-1", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try photosSnapshotJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let item = data?["item"] as? [String: Any]
    let dump = data?["dump"] as? [String: Any]

    #expect(item?["uuid"] as? String == "asset-1")
    #expect(item?["title"] as? String == "Beach")
    #expect(dump?["filename"] as? String == "IMG_0001.JPG")
    #expect(dump?["description"] as? String == "At the beach")
  }

  @Test func photosSnapshotBackendReadsLegacyKeywordJoin() throws {
    let fixture = try makeLegacyPhotosLibraryFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let items = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        keyword: "Kids"
      ))

    #expect(items.map(\.uuid) == ["legacy-asset-1"])
    #expect(items.first?.keywords == ["Kids"])
    #expect(items.first?.persons == ["Katie"])
    #expect(items.first?.iCloud == true)

    let personItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        person: "Katie"
      ))

    #expect(personItems.map(\.uuid) == ["legacy-asset-1"])
  }
}

private struct PhotosLibraryFixture {
  var root: URL
  var library: URL
  var database: URL
}

private func makePhotosLibraryFixture() throws -> PhotosLibraryFixture {
  let root = try temporaryDirectory()
  let library = root.appendingPathComponent("Fixture.photoslibrary", isDirectory: true)
  let databaseDirectory = library.appendingPathComponent("database", isDirectory: true)
  try FileManager.default.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
  let database = databaseDirectory.appendingPathComponent("Photos.sqlite")

  var handle: OpaquePointer?
  guard sqlite3_open(database.path, &handle) == SQLITE_OK else {
    throw PhotosSnapshotTestError.sqliteOpen
  }
  defer { sqlite3_close(handle) }
  try sqliteExec(
    handle,
    """
    CREATE TABLE ZASSET (
      Z_PK INTEGER PRIMARY KEY,
      ZUUID TEXT,
      ZFILENAME TEXT,
      ZTITLE TEXT,
      ZFAVORITE INTEGER,
      ZHIDDEN INTEGER,
      ZTRASHEDSTATE INTEGER,
      ZKIND INTEGER,
      ZWIDTH INTEGER,
      ZHEIGHT INTEGER,
      ZDATECREATED REAL,
      ZLATITUDE REAL,
      ZLONGITUDE REAL,
      ZKEYWORDS TEXT,
      ZPERSONS TEXT
    );
    CREATE TABLE ZADDITIONALASSETATTRIBUTES (
      Z_PK INTEGER PRIMARY KEY,
      ZASSET INTEGER,
      ZORIGINALFILENAME TEXT,
      ZTITLE TEXT,
      ZASSETDESCRIPTION INTEGER
    );
    CREATE TABLE ZASSETDESCRIPTION (
      Z_PK INTEGER PRIMARY KEY,
      ZASSETATTRIBUTES INTEGER,
      ZLONGDESCRIPTION TEXT
    );
    CREATE TABLE ZKEYWORD (
      Z_PK INTEGER PRIMARY KEY,
      ZTITLE TEXT
    );
    CREATE TABLE Z_1KEYWORDS (
      Z_1ASSETATTRIBUTES INTEGER,
      Z_40KEYWORDS INTEGER
    );
    INSERT INTO ZASSET
      (
        Z_PK, ZUUID, ZFILENAME, ZTITLE, ZFAVORITE, ZHIDDEN, ZTRASHEDSTATE, ZKIND, ZWIDTH,
        ZHEIGHT, ZDATECREATED, ZLATITUDE, ZLONGITUDE, ZKEYWORDS, ZPERSONS
      )
    VALUES
      (
        1, 'asset-1', 'asset-storage-name.JPG', 'Beach', 1, 0, 0, 0, 4032, 3024,
        735091765, -180, -180, '', 'Ana'
      ),
      (
        2, 'asset-trash', 'TRASH.JPG', 'Deleted', 0, 0, 1, 0, 4032, 3024,
        735091765, -180, -180, '', ''
      );
    INSERT INTO ZADDITIONALASSETATTRIBUTES
      (Z_PK, ZASSET, ZORIGINALFILENAME, ZTITLE, ZASSETDESCRIPTION)
    VALUES
      (1, 1, 'IMG_0001.JPG', 'Beach', 1),
      (2, 2, 'TRASH.JPG', 'Deleted', NULL);
    INSERT INTO ZASSETDESCRIPTION (Z_PK, ZASSETATTRIBUTES, ZLONGDESCRIPTION)
    VALUES (1, 1, 'At the beach');
    INSERT INTO ZKEYWORD (Z_PK, ZTITLE)
    VALUES (1, 'travel'), (2, 'beach');
    INSERT INTO Z_1KEYWORDS (Z_1ASSETATTRIBUTES, Z_40KEYWORDS)
    VALUES (1, 1), (1, 2);
    """
  )
  try insertModelMetadata(handle, modelVersion: "13703")

  return PhotosLibraryFixture(root: root, library: library, database: database)
}

private func makeLegacyPhotosLibraryFixture() throws -> PhotosLibraryFixture {
  let root = try temporaryDirectory()
  let library = root.appendingPathComponent("Legacy.photoslibrary", isDirectory: true)
  let databaseDirectory = library.appendingPathComponent("database", isDirectory: true)
  try FileManager.default.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
  let database = databaseDirectory.appendingPathComponent("photos.db")

  var handle: OpaquePointer?
  guard sqlite3_open(database.path, &handle) == SQLITE_OK else {
    throw PhotosSnapshotTestError.sqliteOpen
  }
  defer { sqlite3_close(handle) }
  try sqliteExec(
    handle,
    """
    CREATE TABLE RKVersion (
      modelId INTEGER PRIMARY KEY,
      uuid TEXT,
      fileName TEXT,
      cloudIdentifier TEXT,
      masterUuid TEXT,
      nonRawMasterUuid TEXT,
      name TEXT,
      extendedDescription TEXT,
      imageDate REAL,
      isFavorite INTEGER,
      isHidden INTEGER,
      adjustmentUuid TEXT,
      type INTEGER,
      subType INTEGER,
      specialType INTEGER,
      processedWidth INTEGER,
      processedHeight INTEGER,
      latitude REAL,
      longitude REAL,
      isInTrash INTEGER,
      showInLibrary INTEGER,
      burstUuid TEXT,
      burstPickType INTEGER
    );
    CREATE TABLE RKMaster (
      uuid TEXT PRIMARY KEY,
      originalFileName TEXT,
      fileSize INTEGER,
      imagePath TEXT,
      UTI TEXT,
      cloudLibraryState INTEGER
    );
    CREATE TABLE RKKeyword (
      modelId INTEGER PRIMARY KEY,
      name TEXT
    );
    CREATE TABLE RKKeywordForVersion (
      versionId INTEGER,
      keywordId INTEGER
    );
    CREATE TABLE RKPerson (
      modelId INTEGER PRIMARY KEY,
      uuid TEXT,
      name TEXT,
      faceCount INTEGER,
      displayName TEXT,
      representativeFaceId INTEGER
    );
    CREATE TABLE RKFace (
      modelId INTEGER PRIMARY KEY,
      uuid TEXT,
      personId INTEGER,
      imageModelId INTEGER
    );
    CREATE TABLE LiGlobals (
      keyPath TEXT,
      value TEXT
    );
    INSERT INTO RKMaster (uuid, originalFileName, fileSize, imagePath, UTI, cloudLibraryState)
    VALUES ('master-1', 'IMG_LEGACY.JPG', 12, '/tmp/IMG_LEGACY.JPG', 'public.jpeg', 40);
    INSERT INTO RKVersion (
      modelId, uuid, fileName, cloudIdentifier, masterUuid, nonRawMasterUuid, name, extendedDescription,
      imageDate, isFavorite, isHidden, adjustmentUuid, type, subType, specialType,
      processedWidth, processedHeight, latitude, longitude, isInTrash, showInLibrary,
      burstUuid, burstPickType
    )
    VALUES (
      1, 'legacy-asset-1', 'IMG_LEGACY.JPG', 'legacy-cloud-id', 'master-1', NULL, 'Legacy', '',
      735091765, 0, 0, NULL, 0, 0, 0, 4032, 3024, -180, -180, 0, 1, NULL, 0
    );
    INSERT INTO RKKeyword (modelId, name) VALUES (10, 'Kids');
    INSERT INTO RKKeywordForVersion (versionId, keywordId) VALUES (1, 10);
    INSERT INTO RKPerson (modelId, uuid, name, faceCount, displayName, representativeFaceId)
    VALUES (20, 'person-katie', 'Katie', 1, 'Katie', 30);
    INSERT INTO RKFace (modelId, uuid, personId, imageModelId)
    VALUES (30, 'face-katie', 20, 1);
    INSERT INTO LiGlobals (keyPath, value) VALUES ('libraryVersion', '3301');
    """
  )

  return PhotosLibraryFixture(root: root, library: library, database: database)
}

private func insertModelMetadata(_ handle: OpaquePointer?, modelVersion: String) throws {
  try sqliteExec(
    handle,
    """
    CREATE TABLE Z_METADATA (
      Z_VERSION INTEGER,
      Z_PLIST BLOB
    );
    """
  )
  let plist = try PropertyListSerialization.data(
    fromPropertyList: ["PLModelVersion": modelVersion],
    format: .binary,
    options: 0
  )
  var statement: OpaquePointer?
  guard
    sqlite3_prepare_v2(
      handle,
      "INSERT INTO Z_METADATA (Z_VERSION, Z_PLIST) VALUES (?, ?)",
      -1,
      &statement,
      nil
    ) == SQLITE_OK
  else {
    throw PhotosSnapshotTestError.sqliteExec("failed to prepare Z_METADATA insert")
  }
  defer { sqlite3_finalize(statement) }
  sqlite3_bind_int(statement, 1, 1)
  try plist.withUnsafeBytes { buffer in
    guard
      sqlite3_bind_blob(statement, 2, buffer.baseAddress, Int32(buffer.count), SQLITE_TRANSIENT)
        == SQLITE_OK
    else {
      throw PhotosSnapshotTestError.sqliteExec("failed to bind Z_METADATA plist")
    }
  }
  guard sqlite3_step(statement) == SQLITE_DONE else {
    throw PhotosSnapshotTestError.sqliteExec("failed to insert Z_METADATA plist")
  }
}

private func sqliteExec(_ handle: OpaquePointer?, _ sql: String) throws {
  var error: UnsafeMutablePointer<CChar>?
  guard sqlite3_exec(handle, sql, nil, nil, &error) == SQLITE_OK else {
    let message = error.map { String(cString: $0) } ?? "sqlite error"
    sqlite3_free(error)
    throw PhotosSnapshotTestError.sqliteExec(message)
  }
}

private func temporaryDirectory() throws -> URL {
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-tests-\(UUID().uuidString)", isDirectory: true)
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}

private func photosSnapshotJSONObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw PhotosSnapshotTestError.notObject
  }
  return object
}

private enum PhotosSnapshotTestError: Error {
  case notObject
  case sqliteOpen
  case sqliteExec(String)
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
