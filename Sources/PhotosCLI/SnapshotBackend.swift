import Foundation
import SQLite3
import UniformTypeIdentifiers
import Utility

public struct PhotosLibrarySnapshotBackend: @unchecked Sendable {
  private let fileManager: FileManager
  private let homeDirectory: URL
  private let spotlightLibraryPaths: @Sendable () throws -> [String]

  public init(
    fileManager: FileManager = .default,
    homeDirectory: URL? = nil,
    spotlightLibraryPaths: (@Sendable () throws -> [String])? = nil
  ) {
    self.fileManager = fileManager
    self.homeDirectory = homeDirectory ?? fileManager.homeDirectoryForCurrentUser
    self.spotlightLibraryPaths =
      spotlightLibraryPaths ?? PhotosLibrarySnapshotBackend.defaultSpotlightLibraryPaths
  }

  public func listLibraries() throws -> [PhotosLibraryRecord] {
    var paths: [String] = []
    let pictures = picturesDirectory()
    if let entries = try? fileManager.contentsOfDirectory(
      at: pictures,
      includingPropertiesForKeys: [.isDirectoryKey],
      options: [.skipsHiddenFiles]
    ) {
      paths.append(
        contentsOf:
          entries
          .filter { $0.pathExtension == "photoslibrary" }
          .map(\.path)
      )
    }

    if let last = lastOpenedLibraryPath() {
      paths.append(last)
    }

    if let system = systemLibraryPath() {
      paths.append(system)
    }

    paths.append(defaultPicturesLibraryPath())
    paths.append(contentsOf: (try? spotlightLibraryPaths()) ?? [])

    let discovered = uniqueLibraryPaths(paths)
    let system = systemLibraryPath()
    let last = lastOpenedLibraryPath()
    return discovered.map {
      record(for: $0, isSystem: $0 == system, isLastOpened: $0 == last)
    }
  }

  public func libraryInfo(path: String?) throws -> PhotosLibraryRecord {
    let resolved = try resolveLibraryPath(path)
    return (try? recordWithDatabaseInfo(for: resolved, isSystem: isSystemLibraryPath(resolved)))
      ?? record(
        for: resolved,
        isSystem: isSystemLibraryPath(resolved),
        isLastOpened: resolved == lastOpenedLibraryPath()
      )
  }

  public func databaseInfo(path: String?) throws -> PhotosLibraryRecord {
    let resolved = try resolveLibraryPath(path)
    return try recordWithDatabaseInfo(for: resolved, isSystem: isSystemLibraryPath(resolved))
  }

  public func resolveLibraryPath(_ path: String?) throws -> String {
    if let path, !path.isEmpty {
      let resolved = NSString(string: path).expandingTildeInPath
      try validateExplicitLibraryPath(resolved)
      return resolved
    }

    for candidate in [lastOpenedLibraryPath(), systemLibraryPath(), defaultPicturesLibraryPath()] {
      if let candidate, isLibraryPackage(candidate) {
        return candidate
      }
    }

    if let first = try listLibraries().first {
      return first.path
    }
    throw CLIError(
      code: .notFound,
      message: "No Photos library was found. Pass `--library` with an explicit .photoslibrary path."
    )
  }

  private func validateExplicitLibraryPath(_ path: String) throws {
    let url = URL(fileURLWithPath: path)
    guard url.pathExtension == "photoslibrary" else {
      throw CLIError(
        code: .validationError,
        message: "`--library` must point to a .photoslibrary package.",
        details: ["path": path]
      )
    }

    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue
    else {
      throw CLIError(
        code: .notFound,
        message: "Photos library was not found.",
        details: ["path": path]
      )
    }
  }

  public func listAlbums(query: PhotosQuery) throws -> [PhotosAlbumRecord] {
    try withReadOnlySnapshot(query.libraryPath) { database in
      guard try database.tableExists("ZGENERICALBUM") else {
        return []
      }
      let columns = try database.columns(in: "ZGENERICALBUM")
      let metadataByPK = try genericAlbumMetadataByPK(database: database)
      let membershipCounts = try albumMembershipCountsByAlbumPK(database: database)
      let rows = try database.selectRows(
        table: "ZGENERICALBUM", columns: columns, limit: query.limit)
      return
        rows
        .filter { photosIsVisibleContainer($0) && photosIsAlbumRow($0) }
        .map { row in
          PhotosAlbumRecord(
            id: row["ZUUID"] ?? row["Z_PK"] ?? row["id"] ?? "",
            name: row["ZTITLE"] ?? row["ZNAME"] ?? row["name"] ?? "Untitled Album",
            parentID: photosParentContainerID(from: row, metadataByPK: metadataByPK),
            itemCount: row["ZCACHEDCOUNT"].flatMap(Int.init)
              ?? row["Z_PK"].flatMap { membershipCounts[$0] },
            specialKind: photosAlbumSpecialKind(row)
          )
        }
    }
  }

  public func readAlbum(idOrName: String, query: PhotosQuery, includeItems: Bool) throws
    -> PhotosAlbumRecord
  {
    let albums = try listAlbums(query: PhotosQuery(libraryPath: query.libraryPath, limit: 5000))
    guard var album = albums.first(where: { $0.id == idOrName || $0.name == idOrName }) else {
      throw CLIError(code: .notFound, message: "Photos album was not found.")
    }
    if includeItems {
      let items = try listMediaItems(
        query: PhotosQuery(libraryPath: query.libraryPath, album: album.id, limit: query.limit)
      )
      album.mediaItems = items
      album.itemCount = items.count
    }
    return album
  }

  public func listFolders(query: PhotosQuery) throws -> [PhotosFolderRecord] {
    try withReadOnlySnapshot(query.libraryPath) { database in
      guard try database.tableExists("ZGENERICALBUM") else {
        return []
      }
      let columns = try database.columns(in: "ZGENERICALBUM")
      let metadataByPK = try genericAlbumMetadataByPK(database: database)
      let rows = try database.selectRows(
        table: "ZGENERICALBUM", columns: columns, limit: query.limit)
      return
        rows
        .filter { photosIsVisibleContainer($0) && photosIsFolderRow($0) }
        .map { row in
          PhotosFolderRecord(
            id: row["ZUUID"] ?? row["Z_PK"] ?? "",
            name: row["ZTITLE"] ?? row["ZNAME"] ?? "Untitled Folder",
            parentID: photosParentContainerID(from: row, metadataByPK: metadataByPK),
            childCount: row["ZCACHEDCOUNT"].flatMap(Int.init)
          )
        }
    }
  }

  public func readFolder(idOrName: String, query: PhotosQuery, includeChildren: Bool) throws
    -> PhotosFolderRecord
  {
    let lookupQuery = PhotosQuery(libraryPath: query.libraryPath, limit: 5000)
    let folders = try listFolders(query: lookupQuery)
    guard var folder = folders.first(where: { $0.id == idOrName || $0.name == idOrName }) else {
      throw CLIError(code: .notFound, message: "Photos folder was not found.")
    }
    if includeChildren {
      let albums = try listAlbums(query: lookupQuery).filter { $0.parentID == folder.id }
      let childFolders = folders.filter { $0.parentID == folder.id }
      let limitedAlbums = photosLimit(albums, limit: query.limit)
      let limitedFolders = photosLimit(
        childFolders, limit: query.limit.map { max(0, $0 - limitedAlbums.count) })
      folder.childAlbums = limitedAlbums
      folder.childFolders = limitedFolders
      folder.childContainers =
        limitedFolders.map {
          PhotosContainerRecord(id: $0.id, name: $0.name, kind: "folder", parentID: $0.parentID)
        }
        + limitedAlbums.map {
          PhotosContainerRecord(id: $0.id, name: $0.name, kind: "album", parentID: $0.parentID)
        }
      folder.childCount = (folder.childContainers ?? []).count
    }
    return folder
  }

  public func listMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    try withReadOnlySnapshot(query.libraryPath) { database in
      let rows: [[String: String]]
      if try database.tableExists("ZASSET") {
        rows = try mediaItemRows(database: database, assetTable: "ZASSET")
      } else if try database.tableExists("ZGENERICASSET") {
        rows = try mediaItemRows(database: database, assetTable: "ZGENERICASSET")
      } else if try database.tableExists("RKVersion") {
        rows = try legacyMediaItemRows(database: database)
      } else {
        rows = []
      }
      return photosApplyQuery(
        query: query, to: rows.map { mediaItem(from: $0, libraryPath: database.libraryPath) })
    }
  }

  public func readMediaItem(uuid: String, query: PhotosQuery) throws -> PhotosMediaItemRecord {
    var readQuery = query
    readQuery.uuids = [uuid]
    readQuery.limit = 2
    let items = try listMediaItems(query: readQuery)
    guard let item = items.first else {
      throw CLIError(code: .notFound, message: "Photos media item was not found.")
    }
    guard items.count == 1 else {
      throw CLIError(code: .ambiguousIdentity, message: "Photos media item identity is ambiguous.")
    }
    return item
  }

  public func metadataValues(kind: String, query: PhotosQuery) throws -> PhotosMetadataAggregate {
    if photosMetadataQueryIsUnfiltered(query) {
      switch kind {
      case "keywords":
        return photosMetadataAggregate(counts: try keywordCounts(libraryPath: query.libraryPath))
      case "persons":
        return photosMetadataAggregate(counts: try personCounts(libraryPath: query.libraryPath))
      default:
        break
      }
    }

    let items = try listMediaItems(query: query)
    var counts: [String: Int] = [:]
    switch kind {
    case "keywords":
      for item in items {
        for value in Set(item.keywords) {
          counts[value, default: 0] += 1
        }
      }
    case "persons":
      for item in items {
        for value in item.persons {
          counts[value, default: 0] += 1
        }
      }
    case "labels":
      for item in items {
        for value in Set(item.labels) {
          counts[value, default: 0] += 1
        }
      }
    case "places":
      for item in items {
        let value =
          item.hasPlace
          ? firstNonEmpty(item.placeName) ?? photosUnknownPlaceName
          : photosUnknownPlaceName
        counts[value, default: 0] += 1
      }
    default:
      break
    }
    return photosMetadataAggregate(counts: counts)
  }

  public func queryDatabase(query: PhotosQuery, rawSQL: String?) throws -> [[String: String]] {
    try withReadOnlySnapshot(query.libraryPath) { database in
      if let rawSQL {
        try validateRawReadOnlySQL(rawSQL)
        return try database.rawRows(sql: rawSQL, limit: query.limit)
      }
      return try listMediaItems(query: query).map { item in
        [
          "uuid": item.uuid,
          "filename": item.filename,
          "title": item.title ?? "",
          "media_type": item.mediaType,
        ]
      }
    }
  }

  public func grepDatabase(
    query: PhotosQuery,
    pattern: String,
    ignoreCase: Bool,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseGrepMatch] {
    try withReadOnlySnapshot(query.libraryPath) { database in
      try database.grep(
        pattern: pattern,
        ignoreCase: ignoreCase,
        limit: query.limit,
        timeoutSeconds: timeoutSeconds,
        outputCap: outputCap
      )
    }
  }

  public func findDatabaseOrphans(
    query: PhotosQuery,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosDatabaseOrphansReport {
    try withReadOnlySnapshot(query.libraryPath) { database in
      let rows: [[String: String]]
      if try database.tableExists("ZASSET") {
        rows = try mediaItemRows(database: database, assetTable: "ZASSET")
      } else if try database.tableExists("ZGENERICASSET") {
        rows = try mediaItemRows(database: database, assetTable: "ZGENERICASSET")
      } else if try database.tableExists("RKVersion") {
        rows = try legacyMediaItemRows(database: database)
      } else {
        rows = []
      }
      let items = rows.map { mediaItem(from: $0, libraryPath: database.libraryPath) }
      return try photosDatabaseOrphansReport(
        query: query,
        libraryPath: database.libraryPath,
        items: items,
        fileManager: fileManager,
        timeoutSeconds: timeoutSeconds,
        outputCap: outputCap
      )
    }
  }

  private func keywordCounts(libraryPath: String?) throws -> [String: Int] {
    try withReadOnlySnapshot(libraryPath) { database in
      let membership =
        try database.tableExists("ZKEYWORD")
        ? keywordMembershipByAssetPK(database: database)
        : legacyKeywordMembershipByVersionID(database: database)
      var counts = photosCounts(from: membership.values.flatMap { $0 })
      if try database.tableExists("ZKEYWORD") {
        for value in try allModernKeywordNames(database: database) where counts[value] == nil {
          counts[value] = 0
        }
      }
      return counts
    }
  }

  private func personCounts(libraryPath: String?) throws -> [String: Int] {
    try withReadOnlySnapshot(libraryPath) { database in
      let membership =
        try database.tableExists("ZPERSON")
        ? personMembershipByAssetPK(database: database)
        : legacyPersonMembershipByVersionID(database: database)
      return photosCounts(from: membership.values.flatMap { $0 })
    }
  }

  private func allModernKeywordNames(database: SQLiteReadOnlyDatabase) throws -> [String] {
    let columns = Set(try database.columns(in: "ZKEYWORD"))
    let titleColumn =
      columns.contains("ZTITLE") ? "ZTITLE" : columns.contains("name") ? "name" : nil
    guard let titleColumn else {
      return []
    }
    return try database.rawRows(
      sql: "SELECT \(quotedIdentifier(titleColumn)) AS value FROM ZKEYWORD"
    )
    .compactMap { normalizedString($0["value"]) }
    .filter { !$0.isEmpty }
  }

  private func withReadOnlySnapshot<T>(
    _ path: String?, _ body: (SQLiteReadOnlyDatabase) throws -> T
  )
    throws -> T
  {
    let libraryPath = try resolveLibraryPath(path)
    let sourceDB = try photosDatabasePath(in: libraryPath)
    let snapshotURL = try copyDatabaseSnapshot(sourceDB)
    let database = try SQLiteReadOnlyDatabase(path: snapshotURL.path, libraryPath: libraryPath)
    defer { database.close() }
    return try body(database)
  }

  private func record(for path: String, isSystem: Bool, isLastOpened: Bool) -> PhotosLibraryRecord {
    let url = URL(fileURLWithPath: path)
    return PhotosLibraryRecord(
      id: "photos-library:\(photosSHA256Hex(path))",
      name: url.deletingPathExtension().lastPathComponent,
      path: path,
      version: nil,
      isSystemLibrary: isSystem,
      isLastOpenedLibrary: isLastOpened
    )
  }

  private func recordWithDatabaseInfo(for path: String, isSystem: Bool) throws
    -> PhotosLibraryRecord
  {
    let sourceDB = try photosDatabasePath(in: path)
    let snapshotURL = try copyDatabaseSnapshot(sourceDB)
    let database = try SQLiteReadOnlyDatabase(path: snapshotURL.path, libraryPath: path)
    defer { database.close() }

    let metadata = try photosDatabaseMetadata(database: database, sourcePath: sourceDB.path)
    let url = URL(fileURLWithPath: path)
    return PhotosLibraryRecord(
      id: "photos-library:\(photosSHA256Hex(path))",
      name: url.deletingPathExtension().lastPathComponent,
      path: path,
      version: metadata.photosVersion,
      isSystemLibrary: isSystem,
      isLastOpenedLibrary: path == lastOpenedLibraryPath(),
      databasePath: metadata.databasePath,
      databaseVersion: metadata.databaseVersion,
      modelVersion: metadata.modelVersion,
      photosVersion: metadata.photosVersion,
      counts: try libraryInfoCounts(database: database)
    )
  }

  private func libraryInfoCounts(database: SQLiteReadOnlyDatabase) throws -> [String: Int] {
    let rows: [[String: String]]
    if try database.tableExists("ZASSET") {
      rows = try mediaItemRows(database: database, assetTable: "ZASSET")
    } else if try database.tableExists("ZGENERICASSET") {
      rows = try mediaItemRows(database: database, assetTable: "ZGENERICASSET")
    } else if try database.tableExists("RKVersion") {
      rows = try legacyMediaItemRows(database: database)
    } else {
      rows = []
    }

    let items = rows.map { mediaItem(from: $0, libraryPath: database.libraryPath) }
    let photos = items.filter { $0.mediaType == "image" }
    let videos = items.filter { $0.mediaType == "video" }
    let appVisible = items.filter(photosCountsAsPhotosAppTotal)
    let appPhotos = appVisible.filter { $0.mediaType == "image" }
    let appVideos = appVisible.filter { $0.mediaType == "video" }
    let cloudAssets = items.filter {
      !($0.shared ?? false)
        && !($0.sharedMoment ?? false)
        && !(($0.syndicated ?? false) && $0.savedToLibrary != true)
        && ($0.iCloud ?? false)
    }

    var counts: [String: Int] = [
      "all": items.count,
      "all_photos": photos.count,
      "all_videos": videos.count,
      "all_photos_app": appVisible.count,
      "photos": appPhotos.count,
      "videos": appVideos.count,
    ]

    let hidden = items.filter(\.hidden)
    counts["hidden"] = hidden.count
    counts["hidden_photos"] = hidden.filter { $0.mediaType == "image" }.count
    counts["hidden_videos"] = hidden.filter { $0.mediaType == "video" }.count

    let missing = items.filter(photosItemMissing)
    counts["missing"] = missing.count
    counts["missing_photos"] = missing.filter { $0.mediaType == "image" }.count
    counts["missing_videos"] = missing.filter { $0.mediaType == "video" }.count

    counts["cloud_asset"] = cloudAssets.count
    counts["incloud"] = cloudAssets.filter { photosMatchesInCloud($0, expected: true) }.count
    counts["not_incloud"] = cloudAssets.filter { photosMatchesInCloud($0, expected: false) }.count
    counts["not_downloaded"] = cloudAssets.filter(photosItemMissing).count

    let references = items.filter { $0.traits.contains("reference") }
    counts["isreference"] = references.count
    counts["isreference_photos"] = references.filter { $0.mediaType == "image" }.count
    counts["isreference_videos"] = references.filter { $0.mediaType == "video" }.count

    let sharedLibrary = items.filter { $0.sharedLibrary ?? false }
    counts["shared_library"] = sharedLibrary.count
    counts["shared_library_photos"] = sharedLibrary.filter { $0.mediaType == "image" }.count
    counts["shared_library_videos"] = sharedLibrary.filter { $0.mediaType == "video" }.count

    let shared = items.filter { $0.shared ?? false }
    counts["shared"] = shared.count
    counts["shared_photos"] = shared.filter { $0.mediaType == "image" }.count
    counts["shared_videos"] = shared.filter { $0.mediaType == "video" }.count
    counts["shared_moment"] =
      items.filter { ($0.shared ?? false) && ($0.sharedMoment ?? false) }
      .count

    let syndicated = items.filter { $0.syndicated ?? false }
    counts["syndicated"] = syndicated.count
    counts["syndicated_saved_to_library"] = syndicated.filter { $0.savedToLibrary == true }.count
    counts["syndicated_not_saved_to_library"] =
      syndicated.filter { $0.savedToLibrary != true }
      .count

    let favorite = items.filter(\.favorite)
    counts["favorite"] = favorite.count
    counts["favorite_photos"] = favorite.filter { $0.mediaType == "image" }.count
    counts["favorite_videos"] = favorite.filter { $0.mediaType == "video" }.count

    let edited = items.filter(\.edited)
    counts["hasadjustments"] = edited.count
    counts["hasadjustments_photos"] = edited.filter { $0.mediaType == "image" }.count
    counts["hasadjustments_videos"] = edited.filter { $0.mediaType == "video" }.count
    counts["external_edit"] = items.filter(\.externalEdit).count

    counts["location"] = items.filter { $0.location != nil }.count
    counts["reverse_geo"] = items.filter(\.hasPlace).count
    counts["no_location"] = appVisible.filter { $0.location == nil }.count

    counts["burst"] = items.filter { $0.traits.contains("burst") }.count
    counts["live"] = items.filter { $0.traits.contains("live") }.count
    counts["hdr"] = items.filter { $0.traits.contains("hdr") }.count
    counts["selfie"] = items.filter { $0.traits.contains("selfie") }.count
    counts["panorama"] = items.filter { $0.traits.contains("panorama") }.count
    counts["slow_mo"] = items.filter { $0.traits.contains("slow-mo") }.count
    counts["time_lapse"] = items.filter { $0.traits.contains("time-lapse") }.count
    counts["screenshot"] = items.filter { $0.traits.contains("screenshot") }.count
    counts["screen_recording"] = items.filter { $0.traits.contains("screen-recording") }.count
    counts["portrait"] = items.filter { $0.traits.contains("portrait") }.count

    counts["has_raw"] = items.filter { $0.rawPath != nil }.count
    counts["is_raw"] = items.filter { $0.rawOriginal == true || $0.traits.contains("raw") }.count

    counts["has_keywords"] = items.filter { !$0.keywords.isEmpty }.count
    counts["no_keywords"] = items.filter { $0.keywords.isEmpty }.count
    counts["has_title"] = items.filter { !($0.title ?? "").isEmpty }.count
    counts["no_title"] = items.filter { ($0.title ?? "").isEmpty }.count
    counts["has_caption"] = items.filter { !($0.description ?? "").isEmpty }.count
    counts["no_caption"] = items.filter { ($0.description ?? "").isEmpty }.count
    counts["has_ai_labels"] = appVisible.filter { !$0.labels.isEmpty }.count
    counts["no_ai_labels"] = appVisible.filter { $0.labels.isEmpty }.count
    counts["has_persons"] = appPhotos.filter { !$0.persons.isEmpty }.count
    counts["no_persons"] = appPhotos.filter { $0.persons.isEmpty }.count
    counts["persons_count"] = Set(items.flatMap(\.persons).filter { !$0.isEmpty }).count
    counts["keywords_count"] = try libraryKeywordCount(database: database, items: items)
    counts["albums_count"] = try libraryAlbumCount(database: database, shared: false)
    counts["shared_albums"] = try libraryAlbumCount(database: database, shared: true)
    counts["folders"] = try libraryFolderCount(database: database)
    counts["detected_faces"] = try libraryFaceCount(database: database, manual: false)
    counts["manual_faces"] = try libraryFaceCount(database: database, manual: true)
    counts["import_groups"] = try libraryImportGroupCount(database: database)
    counts["moments"] = try libraryMomentCount(database: database, items: items)
    counts["non_analyzed"] = try libraryNonAnalyzedCount(database: database)
    counts["analyzed"] = max(0, appVisible.count - (counts["non_analyzed"] ?? 0))
    counts["in_trash"] = try libraryTrashCount(database: database)

    return counts
  }

  private func libraryKeywordCount(
    database: SQLiteReadOnlyDatabase,
    items: [PhotosMediaItemRecord]
  ) throws -> Int {
    if try database.tableExists("ZKEYWORD") {
      return Set(try allModernKeywordNames(database: database)).count
    }
    if try database.tableExists("RKKeyword") {
      let columns = Set(try database.columns(in: "RKKeyword"))
      guard let nameColumn = firstAvailableColumn(["name", "displayName"], in: columns) else {
        return 0
      }
      return Set(
        try database.rawRows(
          sql: """
            SELECT \(quotedIdentifier(nameColumn)) AS "value"
            FROM "RKKeyword"
            WHERE \(quotedIdentifier(nameColumn)) IS NOT NULL
              AND \(quotedIdentifier(nameColumn)) != ''
            """
        )
        .compactMap { normalizedString($0["value"]) }
      ).count
    }
    return Set(items.flatMap(\.keywords).filter { !$0.isEmpty }).count
  }

  private func libraryAlbumCount(database: SQLiteReadOnlyDatabase, shared: Bool) throws -> Int {
    if try database.tableExists("ZGENERICALBUM") {
      let rows = try database.selectRows(
        table: "ZGENERICALBUM",
        columns: try database.columns(in: "ZGENERICALBUM"),
        limit: nil
      )
      return rows.filter {
        photosIsVisibleContainer($0)
          && photosIsAlbumRow($0)
          && ((photosAlbumSpecialKind($0) == "shared") == shared)
      }.count
    }
    if try database.tableExists("RKAlbum") {
      let columns = Set(try database.columns(in: "RKAlbum"))
      let trashSQL =
        columns.contains("isInTrash")
        ? #" AND ("isInTrash" IS NULL OR "isInTrash" = 0)"# : ""
      let typeSQL =
        columns.contains("albumType")
        ? #" AND ("albumType" IS NULL OR "albumType" = 1)"# : ""
      return shared
        ? 0
        : try countRows(database: database, table: "RKAlbum", whereSQL: "1=1\(trashSQL)\(typeSQL)")
    }
    return 0
  }

  private func libraryFolderCount(database: SQLiteReadOnlyDatabase) throws -> Int {
    if try database.tableExists("ZGENERICALBUM") {
      let rows = try database.selectRows(
        table: "ZGENERICALBUM",
        columns: try database.columns(in: "ZGENERICALBUM"),
        limit: nil
      )
      return rows.filter { photosIsVisibleContainer($0) && photosIsFolderRow($0) }.count
    }
    if try database.tableExists("RKFolder") {
      return try countRows(database: database, table: "RKFolder")
    }
    return 0
  }

  private func libraryFaceCount(database: SQLiteReadOnlyDatabase, manual: Bool) throws -> Int {
    if try database.tableExists("ZDETECTEDFACE") {
      let columns = Set(try database.columns(in: "ZDETECTEDFACE"))
      guard columns.contains("ZMANUAL") else {
        return manual ? 0 : try countRows(database: database, table: "ZDETECTEDFACE")
      }
      return try countRows(
        database: database,
        table: "ZDETECTEDFACE",
        whereSQL: #""ZMANUAL" = \#(manual ? 1 : 0)"#
      )
    }
    if try database.tableExists("RKFace") {
      let columns = Set(try database.columns(in: "RKFace"))
      guard let manualColumn = firstAvailableColumn(["manual", "isManual"], in: columns) else {
        return manual ? 0 : try countRows(database: database, table: "RKFace")
      }
      return try countRows(
        database: database,
        table: "RKFace",
        whereSQL: "\(quotedIdentifier(manualColumn)) = \(manual ? 1 : 0)"
      )
    }
    return 0
  }

  private func libraryImportGroupCount(database: SQLiteReadOnlyDatabase) throws -> Int {
    for table in ["ZIMPORTSESSION", "ZIMPORTGROUP", "RKImportGroup"]
    where try database.tableExists(table) {
      return try countRows(database: database, table: table)
    }
    return 0
  }

  private func libraryMomentCount(
    database: SQLiteReadOnlyDatabase,
    items: [PhotosMediaItemRecord]
  ) throws -> Int {
    if try database.tableExists("ZMOMENT") {
      return try countRows(database: database, table: "ZMOMENT")
    }
    return items.contains { $0.sharedMoment == true } ? 1 : 0
  }

  private func libraryNonAnalyzedCount(database: SQLiteReadOnlyDatabase) throws -> Int {
    for table in ["ZASSET", "ZGENERICASSET"] where try database.tableExists(table) {
      let columns = Set(try database.columns(in: table))
      guard columns.contains("ZANALYSISSTATEMODIFICATIONDATE") else {
        continue
      }
      let hiddenSQL =
        columns.contains("ZHIDDEN") ? #" AND ("ZHIDDEN" IS NULL OR "ZHIDDEN" = 0)"# : ""
      return try countRows(
        database: database,
        table: table,
        whereSQL: #""ZANALYSISSTATEMODIFICATIONDATE" IS NULL\#(hiddenSQL)"#
      )
    }
    return 0
  }

  private func libraryTrashCount(database: SQLiteReadOnlyDatabase) throws -> Int {
    for (table, column) in [("ZASSET", "ZTRASHEDSTATE"), ("ZGENERICASSET", "ZTRASHEDSTATE")]
    where try database.tableExists(table) {
      let columns = Set(try database.columns(in: table))
      guard columns.contains(column) else {
        continue
      }
      return try countRows(
        database: database,
        table: table,
        whereSQL: #"\#(quotedIdentifier(column)) IS NOT NULL AND \#(quotedIdentifier(column)) != 0"#
      )
    }
    if try database.tableExists("RKVersion") {
      let columns = Set(try database.columns(in: "RKVersion"))
      guard columns.contains("isInTrash") else {
        return 0
      }
      return try countRows(
        database: database,
        table: "RKVersion",
        whereSQL: #""isInTrash" IS NOT NULL AND "isInTrash" != 0"#
      )
    }
    return 0
  }

  private func countRows(
    database: SQLiteReadOnlyDatabase,
    table: String,
    whereSQL: String? = nil
  ) throws -> Int {
    let whereClause = whereSQL.map { " WHERE \($0)" } ?? ""
    return try database.rawRows(
      sql: #"SELECT COUNT(*) AS "count" FROM \#(quotedIdentifier(table))\#(whereClause)"#,
      limit: 1
    ).first?["count"].flatMap(Int.init) ?? 0
  }

  private func isSystemLibraryPath(_ path: String) -> Bool {
    path == systemLibraryPath() || path == defaultPicturesLibraryPath()
  }

  private func picturesDirectory() -> URL {
    homeDirectory.appendingPathComponent("Pictures")
  }

  private func defaultPicturesLibraryPath() -> String {
    picturesDirectory().appendingPathComponent("Photos Library.photoslibrary").path
  }

  private func isLibraryPackage(_ path: String) -> Bool {
    let resolved = normalizedLibraryPath(path)
    guard URL(fileURLWithPath: resolved).pathExtension == "photoslibrary" else {
      return false
    }
    var isDirectory: ObjCBool = false
    return fileManager.fileExists(atPath: resolved, isDirectory: &isDirectory)
      && isDirectory.boolValue
  }

  private func uniqueLibraryPaths(_ paths: [String]) -> [String] {
    var seen: Set<String> = []
    return
      paths
      .map(normalizedLibraryPath)
      .filter { isLibraryPackage($0) }
      .sorted()
      .filter { seen.insert($0).inserted }
  }

  private func normalizedLibraryPath(_ path: String) -> String {
    let expanded = NSString(string: path).expandingTildeInPath
    return NSString(string: expanded).standardizingPath
  }

  private func systemLibraryPath() -> String? {
    let plistURL =
      homeDirectory
      .appendingPathComponent("Library/Containers/com.apple.photolibraryd/Data/Library/Preferences")
      .appendingPathComponent("com.apple.photolibraryd.plist")
    guard let plist = propertyList(at: plistURL),
      let path = plist["SystemLibraryPath"] as? String,
      !path.isEmpty
    else {
      return nil
    }
    return normalizedLibraryPath(path)
  }

  private func lastOpenedLibraryPath() -> String? {
    let plistURL =
      homeDirectory
      .appendingPathComponent("Library/Containers/com.apple.Photos/Data/Library/Preferences")
      .appendingPathComponent("com.apple.Photos.plist")
    guard let plist = propertyList(at: plistURL) else {
      return nil
    }

    if let path = plist["IPXDefaultLibraryPath"] as? String, !path.isEmpty {
      return normalizedLibraryPath(path)
    }

    guard let bookmark = plist["IPXDefaultLibraryURLBookmark"] as? Data else {
      return nil
    }

    var isStale = false
    guard
      let url = try? URL(
        resolvingBookmarkData: bookmark,
        options: [.withoutUI],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
    else {
      return nil
    }
    return normalizedLibraryPath(url.path)
  }

  private func propertyList(at url: URL) -> [String: Any]? {
    guard let data = try? Data(contentsOf: url) else {
      return nil
    }
    return (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil))
      as? [String: Any]
  }

  private static func defaultSpotlightLibraryPaths() throws -> [String] {
    guard let result = try? CLISubprocess.run(
      .path("/usr/bin/mdfind"), arguments: ["-onlyin", "/", "-name", ".photoslibrary"],
      timeoutSeconds: 2), result.exitCode == 0
    else { return [] }
    return result.stdout.split(whereSeparator: \.isNewline).map(String.init)
  }

  private func photosDatabasePath(in libraryPath: String) throws -> URL {
    let root = URL(fileURLWithPath: libraryPath)
    let candidates = [
      root.appendingPathComponent("database/Photos.sqlite"),
      root.appendingPathComponent("database/photos.db"),
      root.appendingPathComponent("Photos.sqlite"),
      root.appendingPathComponent("database/Library.apdb"),
    ]
    let existing = candidates.filter { fileManager.fileExists(atPath: $0.path) }
    guard let found = existing.first(where: containsPhotosDataTables) ?? existing.first else {
      throw CLIError(
        code: .notFound,
        message: "Photos library database was not found.",
        details: ["library": libraryPath]
      )
    }
    return found
  }

  private func containsPhotosDataTables(_ url: URL) -> Bool {
    var handle: OpaquePointer?
    guard sqlite3_open_v2(url.path, &handle, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
      if let handle {
        sqlite3_close(handle)
      }
      return false
    }
    defer { sqlite3_close(handle) }

    var statement: OpaquePointer?
    defer { sqlite3_finalize(statement) }
    let sql = """
      SELECT name FROM sqlite_master
      WHERE type = 'table' AND name IN ('ZASSET', 'ZGENERICASSET', 'RKVersion')
      LIMIT 1
      """
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
      return false
    }
    return sqlite3_step(statement) == SQLITE_ROW
  }

  private func copyDatabaseSnapshot(_ source: URL) throws -> URL {
    let temp = fileManager.temporaryDirectory
      .appendingPathComponent("apple-cli-photos-\(UUID().uuidString)", isDirectory: true)
    try fileManager.createDirectory(at: temp, withIntermediateDirectories: true)
    let destination = temp.appendingPathComponent(source.lastPathComponent)
    try fileManager.copyItem(at: source, to: destination)
    for suffix in ["-wal", "-shm"] {
      let sidecar = URL(fileURLWithPath: source.path + suffix)
      if fileManager.fileExists(atPath: sidecar.path) {
        try fileManager.copyItem(
          at: sidecar,
          to: URL(fileURLWithPath: destination.path + suffix)
        )
      }
    }
    return destination
  }
}

private struct PhotosDatabaseMetadata {
  var databasePath: String
  var databaseVersion: String?
  var modelVersion: String?
  var photosVersion: String?
}

private func photosDatabaseMetadata(database: SQLiteReadOnlyDatabase, sourcePath: String) throws
  -> PhotosDatabaseMetadata
{
  let tables = Set(try database.tableNames())
  let databaseVersion: String?
  if tables.contains("LiGlobals") {
    databaseVersion =
      try database.rawRows(
        sql: "SELECT value FROM LiGlobals WHERE keyPath = ? LIMIT 1",
        bindings: ["libraryVersion"],
        limit: 1
      ).first?["value"]
  } else if tables.contains("Z_METADATA") {
    databaseVersion = "5001"
  } else {
    databaseVersion = nil
  }

  let modelVersion =
    tables.contains("Z_METADATA") ? try photosModelVersion(database: database) : nil
  return PhotosDatabaseMetadata(
    databasePath: sourcePath,
    databaseVersion: databaseVersion,
    modelVersion: modelVersion,
    photosVersion: photosVersion(databaseVersion: databaseVersion, modelVersion: modelVersion)
  )
}

private func photosModelVersion(database: SQLiteReadOnlyDatabase) throws -> String? {
  let rows = try database.rawRows(
    sql: "SELECT hex(Z_PLIST) AS plist_hex FROM Z_METADATA ORDER BY Z_VERSION DESC LIMIT 1",
    limit: 1
  )
  guard let hex = rows.first?["plist_hex"], let data = dataFromHex(hex) else {
    return nil
  }
  guard
    let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
      as? [String: Any],
    let value = plist["PLModelVersion"]
  else {
    return nil
  }
  return String(describing: value)
}

private func photosVersion(databaseVersion: String?, modelVersion: String?) -> String? {
  if let databaseVersion, let numeric = Int(databaseVersion) {
    switch numeric {
    case 2622: return "2"
    case 3301: return "3"
    case 4016, 4025: return "4"
    default: break
    }
  }

  guard let modelVersion, let model = Int(modelVersion) else {
    return nil
  }
  switch model {
  case 13_000...13_999: return "5"
  case 14_000...14_999: return "6"
  case 15_000...15_999: return "7"
  case 16_000...16_999: return "8"
  case 17_000...17_599: return "9"
  case 17_600...17_999: return "9.6"
  case 18_000...18_200: return "9.9"
  case 18_201...18_999: return "10"
  case 19_063...19_319: return "11"
  case 19_320...19_999: return "11.1"
  default: return nil
  }
}

private func mediaItem(from row: [String: String], libraryPath: String) -> PhotosMediaItemRecord {
  let pk = row["Z_PK"] ?? row["id"] ?? row["ID"] ?? UUID().uuidString
  let uuid = row["ZUUID"] ?? row["ZCLOUDGUID"] ?? row["uuid"] ?? pk
  let filename =
    firstNonEmpty(row["ZORIGINALFILENAME"], row["ZFILENAME"], row["filename"], uuid) ?? uuid
  let createdDateValue = firstNonEmpty(row["ZDATECREATED"], row["ZADDEDDATE"])
  let createdDate =
    photosDate(from: createdDateValue)
    ?? unixDate(from: firstNonEmpty(row["date"]))
  let timeZoneOffsetSeconds =
    photosDateUsesDefaultFallback(createdDateValue)
    ? nil
    : intValue(firstNonEmpty(row["ZTIMEZONEOFFSET"], row["imageTimeZoneOffsetSeconds"]))
  let uti = normalizedString(row["ZUNIFORMTYPEIDENTIFIER"] ?? row["uti"])
  let originalPath = photosOriginalPath(from: row, libraryPath: libraryPath)
  let rawPath = photosRawPath(from: row, originalPath: originalPath)
  let shared = nonEmpty(row["ZCLOUDBATCHPUBLISHDATE"]) == true
  let syndicated = nonEmpty(row["ZSYNDICATIONIDENTIFIER"]) == true
  let savedToLibrary = photosSyndicationSavedState(from: row)
  let sharedMoment = truthyDatabaseValue(row["ZMOMENTSHARE"]) == true
  let type = mediaType(from: row)
  let edited = editedState(from: row)
  let traits = mediaTraits(from: row)
  let livePhoto = traits.contains("live")
  let missing = row["ZMISSING"].map(bool(from:))
  let databaseFileSize =
    row["ZFILESIZE"].flatMap(Int64.init)
    ?? row["ZORIGINALFILESIZE"].flatMap(Int64.init)
    ?? row["file_size"].flatMap(Int64.init)
  let originalFileSize =
    originalPath
    .flatMap { path in FileManager.default.fileExists(atPath: path) ? photosFileSize(path) : nil }
  return PhotosMediaItemRecord(
    id: "photos-media-item:\(uuid)",
    uuid: uuid,
    filename: filename,
    title: firstNonEmpty(row["ZTITLE"], row["ZNAME"], row["title"]),
    description: firstNonEmpty(row["ZLONGDESCRIPTION"], row["ZDESCRIPTION"], row["description"]),
    mediaType: type,
    date: createdDate,
    dateAdded: photosDate(from: firstNonEmpty(row["ZADDEDDATE"])),
    timeZoneOffsetSeconds: timeZoneOffsetSeconds,
    favorite: bool(from: row["ZFAVORITE"] ?? row["favorite"]),
    hidden: bool(from: row["ZHIDDEN"] ?? row["hidden"]),
    keywords: internalList(row["ZKEYWORDS"] ?? row["keywords"]),
    labels: internalList(row["ZLABELS"] ?? row["labels"]),
    persons: internalList(row["ZPERSONS"] ?? row["persons"]),
    albumIDs: internalList(row["ZALBUMS"] ?? row["albums"]),
    albumPaths: internalList(row["ZALBUMPATHS"] ?? row["album_paths"]),
    folderPaths: internalList(row["ZFOLDERS"] ?? row["folders"]),
    originalPath: originalPath,
    width: row["ZWIDTH"].flatMap(Int.init) ?? row["width"].flatMap(Int.init),
    height: row["ZHEIGHT"].flatMap(Int.init) ?? row["height"].flatMap(Int.init),
    fileSize: databaseFileSize ?? originalFileSize,
    location: location(from: row),
    hasPlace: bool(from: row["ZHASPLACE"]),
    placeName: firstNonEmpty(row["ZPLACENAME"]),
    placeNames: internalList(row["ZPLACENAMES"]),
    comments: photosCommentRecords(from: row["ZCOMMENTSJSON"]),
    likes: photosLikeRecords(from: row["ZLIKESJSON"]),
    uti: uti,
    originalUTI: photosOriginalUTI(
      from: row,
      filename: filename,
      originalPath: originalPath,
      currentUTI: uti
    ),
    shared: shared,
    iCloud: nonEmpty(row["ZCLOUDASSETGUID"]),
    inCloud: photosInCloudState(from: row),
    syndicated: syndicated,
    savedToLibrary: savedToLibrary,
    sharedMoment: sharedMoment,
    sharedLibrary: truthyDatabaseValue(row["ZACTIVELIBRARYSCOPEPARTICIPATIONSTATE"]),
    missingState: missing,
    edited: edited,
    externalEdit: externalEditState(from: row),
    traits: traits,
    rawPath: rawPath,
    rawUTI: photosRawUTI(from: row, rawPath: rawPath),
    rawOriginal: photosRawOriginalState(from: row),
    editedPath: photosEditedRenderPath(
      uuid: uuid,
      libraryPath: libraryPath,
      mediaType: type,
      uti: uti,
      edited: edited
    ),
    livePhotoMoviePath: photosLivePhotoMoviePath(
      uuid: uuid,
      filename: filename,
      originalPath: originalPath,
      libraryPath: libraryPath,
      shared: shared,
      sharedMoment: sharedMoment,
      syndicated: syndicated,
      savedToLibrary: savedToLibrary,
      live: livePhoto,
      missing: missing
    ),
    editedLivePhotoMoviePath: photosEditedLivePhotoMoviePath(
      uuid: uuid,
      libraryPath: libraryPath,
      live: livePhoto,
      edited: edited
    ),
    previewPaths: photosPreviewPaths(
      uuid: uuid,
      libraryPath: libraryPath,
      mediaType: type,
      shared: shared,
      sharedMoment: sharedMoment,
      syndicated: syndicated,
      savedToLibrary: savedToLibrary
    ),
    adjustmentPath: photosAdjustmentPath(
      uuid: uuid,
      libraryPath: libraryPath,
      edited: edited
    ),
    originalAdjustmentPath: photosOriginalAdjustmentPath(uuid: uuid, libraryPath: libraryPath),
    exif: photosExifMetadata(from: row)
  )
}

private func photosDatabaseOrphansReport(
  query: PhotosQuery,
  libraryPath: String,
  items: [PhotosMediaItemRecord],
  fileManager: FileManager,
  timeoutSeconds: Int,
  outputCap: Int
) throws -> PhotosDatabaseOrphansReport {
  let deadline = Date().addingTimeInterval(TimeInterval(timeoutSeconds))
  var collector = PhotosDatabaseOrphanCollector(outputCap: outputCap)
  let referencedResources = items.flatMap(photosReferencedResources)
  let referencedPaths = Set(referencedResources.map { photosStandardizedPath($0.path) })

  for resource in referencedResources {
    if Date() > deadline {
      collector.truncated = true
      break
    }
    guard !fileManager.fileExists(atPath: resource.path) else {
      continue
    }
    collector.append(
      PhotosDatabaseOrphanRecord(
        kind: "database_missing_file",
        resourceKind: resource.kind,
        path: resource.path,
        relativePath: photosRelativePath(resource.path, in: libraryPath),
        uuid: resource.uuid,
        filename: resource.filename,
        reason: "database record references a file that is not present"
      )
    )
  }

  for filePath in photosPackageResourceFilePaths(
    libraryPath: libraryPath,
    fileManager: fileManager,
    deadline: deadline,
    truncated: &collector.truncated
  ) {
    if Date() > deadline {
      collector.truncated = true
      break
    }
    guard !collector.truncated else {
      break
    }
    let standardized = photosStandardizedPath(filePath)
    guard !referencedPaths.contains(standardized) else {
      continue
    }
    collector.append(
      PhotosDatabaseOrphanRecord(
        kind: "package_file_unreferenced",
        resourceKind: photosResourceKind(forPath: filePath, libraryPath: libraryPath),
        path: filePath,
        relativePath: photosRelativePath(filePath, in: libraryPath),
        reason: "library package resource file is not referenced by a normalized media record"
      )
    )
  }

  return PhotosDatabaseOrphansReport(
    query: query,
    libraryPath: libraryPath,
    records: collector.records,
    truncated: collector.truncated
  )
}

private struct PhotosReferencedResource {
  var kind: String
  var path: String
  var uuid: String
  var filename: String
}

private struct PhotosDatabaseOrphanCollector {
  var outputCap: Int
  var records: [PhotosDatabaseOrphanRecord] = []
  var usedBytes = 0
  var truncated = false

  mutating func append(_ record: PhotosDatabaseOrphanRecord) {
    guard !truncated else {
      return
    }
    let estimatedBytes =
      record.kind.utf8.count + record.resourceKind.utf8.count + record.path.utf8.count
      + (record.relativePath?.utf8.count ?? 0) + (record.uuid?.utf8.count ?? 0)
      + (record.filename?.utf8.count ?? 0) + record.reason.utf8.count
    if usedBytes + estimatedBytes > outputCap {
      truncated = true
      return
    }
    usedBytes += estimatedBytes
    records.append(record)
  }
}

private func photosReferencedResources(_ item: PhotosMediaItemRecord) -> [PhotosReferencedResource]
{
  var resources: [PhotosReferencedResource] = []
  func append(_ kind: String, _ path: String?) {
    guard let path = normalizedString(path), !path.isEmpty else {
      return
    }
    resources.append(
      PhotosReferencedResource(
        kind: kind,
        path: path,
        uuid: item.uuid,
        filename: item.filename
      )
    )
  }
  append("original", item.originalPath)
  append("raw", item.rawPath)
  append("edited_render", item.editedPath)
  append("live_photo_movie", item.livePhotoMoviePath)
  append("edited_live_photo_movie", item.editedLivePhotoMoviePath)
  append("adjustment", item.adjustmentPath)
  append("original_adjustment", item.originalAdjustmentPath)
  for previewPath in item.previewPaths {
    append("preview", previewPath)
  }
  return resources
}

private func photosPackageResourceFilePaths(
  libraryPath: String,
  fileManager: FileManager,
  deadline: Date,
  truncated: inout Bool
) -> [String] {
  let libraryURL = URL(fileURLWithPath: libraryPath)
  let roots = [
    libraryURL.appendingPathComponent("originals", isDirectory: true),
    libraryURL.appendingPathComponent("resources", isDirectory: true),
  ]
  var paths: [String] = []
  for root in roots where fileManager.fileExists(atPath: root.path) {
    guard
      let enumerator = fileManager.enumerator(
        at: root,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
      )
    else {
      continue
    }
    for case let url as URL in enumerator {
      if Date() > deadline {
        truncated = true
        return paths.sorted()
      }
      let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
      if values?.isRegularFile == true {
        paths.append(url.path)
      }
    }
  }
  return paths.sorted()
}

private func photosStandardizedPath(_ path: String) -> String {
  URL(fileURLWithPath: path).standardizedFileURL.path
}

private func photosRelativePath(_ path: String, in libraryPath: String) -> String? {
  let standardizedPath = photosStandardizedPath(path)
  let library = photosStandardizedPath(libraryPath)
  guard standardizedPath.hasPrefix(library + "/") else {
    return nil
  }
  return String(standardizedPath.dropFirst(library.count + 1))
}

private func photosResourceKind(forPath path: String, libraryPath: String) -> String {
  guard let relativePath = photosRelativePath(path, in: libraryPath) else {
    return "resource"
  }
  if relativePath.hasPrefix("originals/") {
    return "original"
  }
  if relativePath.hasPrefix("resources/renders/") {
    return "render"
  }
  if relativePath.hasPrefix("resources/derivatives/") {
    return "derivative"
  }
  if relativePath.hasPrefix("resources/cloudsharing/") {
    return "shared_resource"
  }
  return "resource"
}

private func photosCommentRecords(from json: String?) -> [PhotosCommentRecord] {
  photosSharedReactionPayloads(from: json).compactMap { payload in
    guard let text = payload.text, !text.isEmpty else {
      return nil
    }
    return PhotosCommentRecord(
      date: payload.dateSeconds.map(Date.init(timeIntervalSinceReferenceDate:)),
      user: payload.user,
      isMine: payload.isMine,
      text: text
    )
  }
}

private func photosLikeRecords(from json: String?) -> [PhotosLikeRecord] {
  photosSharedReactionPayloads(from: json).map { payload in
    PhotosLikeRecord(
      date: payload.dateSeconds.map(Date.init(timeIntervalSinceReferenceDate:)),
      user: payload.user,
      isMine: payload.isMine
    )
  }
}

private func photosSharedReactionPayloads(from json: String?) -> [PhotosSharedReactionPayload] {
  guard let json, !json.isEmpty, let data = json.data(using: .utf8) else {
    return []
  }
  return (try? JSONDecoder().decode([PhotosSharedReactionPayload].self, from: data)) ?? []
}

private func mediaItemRows(database: SQLiteReadOnlyDatabase, assetTable: String) throws -> [[String:
  String]]
{
  let assetColumns = Set(try database.columns(in: assetTable))
  guard try database.tableExists("ZADDITIONALASSETATTRIBUTES") else {
    var rows = try database.selectRows(table: assetTable, columns: Array(assetColumns), limit: nil)
      .filter { !isTrashedAsset($0, hasTrashedState: assetColumns.contains("ZTRASHEDSTATE")) }
    let albumMembership = try assetMembershipByAssetPK(database: database)
    let keywordMembership = try keywordMembershipByAssetPK(database: database)
    let personMembership = try personMembershipByAssetPK(database: database)
    let labelMembership = try searchInfoLabelsByUUID(libraryPath: database.libraryPath)
    let originalUTI = try originalUTIByAssetPK(database: database)
    let rawResources = try rawResourceMetadataByAssetPK(database: database)
    let missingState = try resourceMissingStateByAssetPK(database: database)
    let commentMembership = try commentLikeMembershipByUUID(
      database: database, assetTable: assetTable)
    for index in rows.indices {
      if let pk = rows[index]["Z_PK"], let membership = albumMembership[pk] {
        if !membership.albums.isEmpty {
          rows[index]["ZALBUMS"] = membership.albums.joined(separator: internalListSeparator)
        }
        if !membership.albumPaths.isEmpty {
          rows[index]["ZALBUMPATHS"] = membership.albumPaths.joined(
            separator: internalListSeparator)
        }
        if !membership.folderPaths.isEmpty {
          rows[index]["ZFOLDERS"] = membership.folderPaths.joined(separator: internalListSeparator)
        }
      }
      if let pk = rows[index]["Z_PK"], let keywords = keywordMembership[pk], !keywords.isEmpty {
        rows[index]["ZKEYWORDS"] = keywords.joined(separator: internalListSeparator)
      }
      if let pk = rows[index]["Z_PK"], let persons = personMembership[pk], !persons.isEmpty {
        rows[index]["ZPERSONS"] = persons.joined(separator: internalListSeparator)
      }
      if let uuid = rows[index]["ZUUID"], let labels = labelMembership[uuid], !labels.isEmpty {
        rows[index]["ZLABELS"] = labels.joined(separator: internalListSeparator)
      }
      if let pk = rows[index]["Z_PK"], let uti = originalUTI[pk] {
        rows[index]["ZORIGINALUTI"] = uti
      }
      if let pk = rows[index]["Z_PK"], let rawResource = rawResources[pk] {
        rows[index]["ZHASRAW"] = "1"
        if let uti = rawResource.uti {
          rows[index]["ZRAWUTI"] = uti
        }
        if let path = rawResource.path {
          rows[index]["ZRAWPATH"] = path
        }
      }
      if let pk = rows[index]["Z_PK"], let missing = missingState[pk] {
        rows[index]["ZMISSING"] = missing ? "1" : "0"
      }
      if let uuid = rows[index]["ZUUID"], let membership = commentMembership[uuid] {
        rows[index]["ZCOMMENTSJSON"] = photosEncodeSharedReactionPayloads(membership.comments)
        rows[index]["ZLIKESJSON"] = photosEncodeSharedReactionPayloads(membership.likes)
      }
    }
    return rows
  }

  let additionalColumns = Set(try database.columns(in: "ZADDITIONALASSETATTRIBUTES"))
  let asset = { (column: String) in
    optionalColumn(tableAlias: "asset", column: column, alias: column, available: assetColumns)
  }
  let additional = { (column: String) in
    optionalColumn(
      tableAlias: "additional", column: column, alias: column, available: additionalColumns)
  }
  let hasExifTable = try database.tableExists("ZEXTENDEDATTRIBUTES")
  let exifColumns = hasExifTable ? Set(try database.columns(in: "ZEXTENDEDATTRIBUTES")) : []
  let exif = { (column: String, alias: String) in
    optionalColumn(tableAlias: "exif", column: column, alias: alias, available: exifColumns)
  }
  let hasCloudMasterJoin =
    try database.tableExists("ZCLOUDMASTER")
    && assetColumns.contains("ZMASTER")
    && Set(try database.columns(in: "ZCLOUDMASTER")).contains("ZCLOUDLOCALSTATE")
  let cloudLocalStateSelect =
    hasCloudMasterJoin
    ? #"cloudMaster."ZCLOUDLOCALSTATE" AS "ZCLOUDLOCALSTATE""#
    : asset("ZCLOUDLOCALSTATE")
  let cloudMasterJoin =
    hasCloudMasterJoin
    ? #"LEFT JOIN "ZCLOUDMASTER" AS cloudMaster ON cloudMaster."Z_PK" = asset."ZMASTER""#
    : ""
  let exifJoin =
    hasExifTable && exifColumns.contains("ZASSET")
    ? #"LEFT JOIN "ZEXTENDEDATTRIBUTES" AS exif ON exif."ZASSET" = asset."Z_PK""#
    : ""
  let select = [
    asset("Z_PK"),
    asset("ZUUID"),
    asset("ZFILENAME"),
    asset("ZDESCRIPTION"),
    asset("ZDATECREATED"),
    asset("ZADDEDDATE"),
    asset("ZMODIFICATIONDATE"),
    asset("ZCLOUDBATCHPUBLISHDATE"),
    asset("ZFAVORITE"),
    asset("ZHIDDEN"),
    asset("ZKIND"),
    asset("ZKINDSUBTYPE"),
    asset("ZHDRTYPE"),
    asset("ZCUSTOMRENDEREDVALUE"),
    asset("ZHASADJUSTMENTS"),
    asset("ZADJUSTMENTSSTATE"),
    asset("ZADJUSTMENTTIMESTAMP"),
    asset("ZDEPTHTYPE"),
    asset("ZDEPTHSTATES"),
    asset("ZSAVEDASSETTYPE"),
    asset("ZORIGINALRESOURCECHOICE"),
    asset("ZAVALANCHEUUID"),
    asset("ZAVALANCHEPICKTYPE"),
    asset("ZWIDTH"),
    asset("ZHEIGHT"),
    asset("ZFILESIZE"),
    asset("ZLATITUDE"),
    asset("ZLONGITUDE"),
    asset("ZALTITUDE"),
    asset("ZKEYWORDS"),
    asset("ZPERSONS"),
    asset("ZALBUMS"),
    asset("ZTRASHEDSTATE"),
    asset("ZVISIBILITYSTATE"),
    asset("ZCLOUDASSETGUID"),
    cloudLocalStateSelect,
    asset("ZMOMENTSHARE"),
    asset("ZACTIVELIBRARYSCOPEPARTICIPATIONSTATE"),
    asset("ZDIRECTORY"),
    asset("ZUNIFORMTYPEIDENTIFIER"),
    asset("date"),
    asset("original_path"),
    asset("file_size"),
    additional("ZORIGINALFILENAME"),
    additional("ZTITLE"),
    additional("ZORIGINALFILESIZE"),
    additional("ZORIGINALWIDTH"),
    additional("ZORIGINALHEIGHT"),
    additional("ZTIMEZONEOFFSET"),
    additional("ZTIMEZONENAME"),
    additional("ZCAMERACAPTUREDEVICE"),
    additional("ZUNMANAGEDADJUSTMENT"),
    additional("ZSYNDICATIONHISTORY"),
    additional("ZSYNDICATIONIDENTIFIER"),
    reverseLocationDataHexSelect(additionalColumns: additionalColumns),
    try assetDescriptionSelect(database: database, additionalColumns: additionalColumns),
    try adjustmentFormatIdentifierSelect(database: database, additionalColumns: additionalColumns),
    exif("ZISO", "ZEXIFISO"),
    exif("ZFLASHFIRED", "ZEXIFFLASHFIRED"),
    exif("ZMETERINGMODE", "ZEXIFMETERINGMODE"),
    exif("ZSAMPLERATE", "ZEXIFSAMPLERATE"),
    exif("ZTRACKFORMAT", "ZEXIFTRACKFORMAT"),
    exif("ZWHITEBALANCE", "ZEXIFWHITEBALANCE"),
    exif("ZAPERTURE", "ZEXIFAPERTURE"),
    exif("ZBITRATE", "ZEXIFBITRATE"),
    exif("ZDURATION", "ZEXIFDURATION"),
    exif("ZEXPOSUREBIAS", "ZEXIFEXPOSUREBIAS"),
    exif("ZFOCALLENGTH", "ZEXIFFOCALLENGTH"),
    exif("ZFPS", "ZEXIFFPS"),
    exif("ZLATITUDE", "ZEXIFLATITUDE"),
    exif("ZLONGITUDE", "ZEXIFLONGITUDE"),
    exif("ZSHUTTERSPEED", "ZEXIFSHUTTERSPEED"),
    exif("ZCAMERAMAKE", "ZEXIFCAMERAMAKE"),
    exif("ZCAMERAMODEL", "ZEXIFCAMERAMODEL"),
    exif("ZCODEC", "ZEXIFCODEC"),
    exif("ZLENSMODEL", "ZEXIFLENSMODEL"),
    exif("ZDATECREATED", "ZEXIFDATECREATED"),
    exif("ZTIMEZONEOFFSET", "ZEXIFTIMEZONEOFFSET"),
    exif("ZTIMEZONENAME", "ZEXIFTIMEZONENAME"),
  ].joined(separator: ", ")

  var filters: [String] = []
  if assetColumns.contains("ZTRASHEDSTATE") {
    filters.append(#"(asset."ZTRASHEDSTATE" IS NULL OR asset."ZTRASHEDSTATE" = 0)"#)
  }
  if assetColumns.contains("ZAVALANCHEUUID"), assetColumns.contains("ZAVALANCHEPICKTYPE") {
    filters.append(
      #"(asset."ZAVALANCHEUUID" IS NULL OR asset."ZAVALANCHEPICKTYPE" IS NULL OR asset."ZAVALANCHEPICKTYPE" = 0 OR (asset."ZAVALANCHEPICKTYPE" & 8) != 0 OR (asset."ZAVALANCHEPICKTYPE" & 16) != 0)"#
    )
  }
  let whereSQL = filters.isEmpty ? "" : "WHERE " + filters.joined(separator: " AND ")
  var rows = try database.rawRows(
    sql: """
      SELECT \(select)
      FROM \(quotedIdentifier(assetTable)) AS asset
      LEFT JOIN "ZADDITIONALASSETATTRIBUTES" AS additional
        ON additional."ZASSET" = asset."Z_PK"
      \(cloudMasterJoin)
      \(exifJoin)
      \(try assetDescriptionJoin(database: database, additionalColumns: additionalColumns))
      \(try adjustmentJoin(database: database, additionalColumns: additionalColumns))
      \(whereSQL)
      ORDER BY asset."ZUUID"
      """
  )
  let albumMembership = try assetMembershipByAssetPK(database: database)
  let keywordMembership = try keywordMembershipByAssetPK(database: database)
  let personMembership = try personMembershipByAssetPK(database: database)
  let labelMembership = try searchInfoLabelsByUUID(libraryPath: database.libraryPath)
  let rawResources = try rawResourceMetadataByAssetPK(database: database)
  let originalUTI = try originalUTIByAssetPK(database: database)
  let missingState = try resourceMissingStateByAssetPK(database: database)
  let commentMembership = try commentLikeMembershipByUUID(
    database: database, assetTable: assetTable)
  for index in rows.indices {
    if let pk = rows[index]["Z_PK"], let membership = albumMembership[pk] {
      if !membership.albums.isEmpty {
        rows[index]["ZALBUMS"] = membership.albums.joined(separator: internalListSeparator)
      }
      if !membership.albumPaths.isEmpty {
        rows[index]["ZALBUMPATHS"] = membership.albumPaths.joined(separator: internalListSeparator)
      }
      if !membership.folderPaths.isEmpty {
        rows[index]["ZFOLDERS"] = membership.folderPaths.joined(separator: internalListSeparator)
      }
    }
    if let pk = rows[index]["Z_PK"], let keywords = keywordMembership[pk], !keywords.isEmpty {
      rows[index]["ZKEYWORDS"] = keywords.joined(separator: internalListSeparator)
    }
    if let pk = rows[index]["Z_PK"], let persons = personMembership[pk], !persons.isEmpty {
      rows[index]["ZPERSONS"] = persons.joined(separator: internalListSeparator)
    }
    if let uuid = rows[index]["ZUUID"], let labels = labelMembership[uuid], !labels.isEmpty {
      rows[index]["ZLABELS"] = labels.joined(separator: internalListSeparator)
    }
    if let place = photosModernPlaceValues(hex: rows[index]["ZREVERSELOCATIONDATAHEX"]) {
      rows[index]["ZHASPLACE"] = place.hasPlace ? "1" : "0"
      rows[index]["ZPLACENAME"] = place.displayName ?? ""
      rows[index]["ZPLACENAMES"] = place.names.joined(separator: internalListSeparator)
    }
    if let pk = rows[index]["Z_PK"], let rawResource = rawResources[pk] {
      rows[index]["ZHASRAW"] = "1"
      if let uti = rawResource.uti {
        rows[index]["ZRAWUTI"] = uti
      }
      if let path = rawResource.path {
        rows[index]["ZRAWPATH"] = path
      }
    }
    if let pk = rows[index]["Z_PK"], let uti = originalUTI[pk] {
      rows[index]["ZORIGINALUTI"] = uti
    }
    if let pk = rows[index]["Z_PK"], let missing = missingState[pk] {
      rows[index]["ZMISSING"] = missing ? "1" : "0"
    }
    if let uuid = rows[index]["ZUUID"], let membership = commentMembership[uuid] {
      rows[index]["ZCOMMENTSJSON"] = photosEncodeSharedReactionPayloads(membership.comments)
      rows[index]["ZLIKESJSON"] = photosEncodeSharedReactionPayloads(membership.likes)
    }
  }
  return rows
}

private func legacyMediaItemRows(database: SQLiteReadOnlyDatabase) throws -> [[String: String]] {
  guard try database.tableExists("RKMaster") else {
    return []
  }
  let versionColumns = Set(try database.columns(in: "RKVersion"))
  let masterColumns = Set(try database.columns(in: "RKMaster"))
  let hasImportGroup = try database.tableExists("RKImportGroup")
  let importGroupColumns = hasImportGroup ? Set(try database.columns(in: "RKImportGroup")) : []
  let cloudAssetGuidSelect = legacyCloudAssetGuidSelect(
    versionColumns: versionColumns,
    masterColumns: masterColumns
  )
  var rows = try database.rawRows(
    sql: """
      SELECT
        version."modelId" AS "Z_PK",
        version."uuid" AS "ZUUID",
        version."fileName" AS "ZFILENAME",
        CASE
          WHEN version."subType" = 16 AND version."nonRawMasterUuid" IS NOT NULL
            THEN nonRawMaster."originalFileName"
          ELSE master."originalFileName"
        END AS "ZORIGINALFILENAME",
        version."name" AS "ZTITLE",
        version."extendedDescription" AS "ZDESCRIPTION",
        version."imageDate" AS "ZDATECREATED",
        \(optionalColumn(
          tableAlias: "version",
          column: "imageTimeZoneOffsetSeconds",
          alias: "ZTIMEZONEOFFSET",
          available: versionColumns
        )),
        \(optionalColumn(
          tableAlias: "version",
          column: "imageTimeZoneName",
          alias: "ZTIMEZONENAME",
          available: versionColumns
        )),
        \(optionalColumn(
          tableAlias: "importGroup",
          column: "importDate",
          alias: "ZADDEDDATE",
          available: importGroupColumns
        )),
        version."isFavorite" AS "ZFAVORITE",
        version."isHidden" AS "ZHIDDEN",
        version."adjustmentUuid" AS "ZADJUSTMENTUUID",
        CASE version."type" WHEN 8 THEN 1 ELSE 0 END AS "ZKIND",
        version."subType" AS "ZKINDSUBTYPE",
        version."specialType" AS "ZSPECIALTYPE",
        version."burstUuid" AS "ZAVALANCHEUUID",
        version."burstPickType" AS "ZAVALANCHEPICKTYPE",
        \(optionalColumn(
          tableAlias: "version",
          column: "hasAdjustments",
          alias: "ZHASADJUSTMENTS",
          available: versionColumns
        )),
        \(optionalColumn(
          tableAlias: "version",
          column: "selfPortrait",
          alias: "ZCAMERACAPTUREDEVICE",
          available: versionColumns
        )),
        \(optionalColumn(
          tableAlias: "master",
          column: "fileIsReference",
          alias: "ZISREFERENCE",
          available: masterColumns
        )),
        CASE WHEN version."specialType" = 7 THEN 1 ELSE NULL END AS "ZHASRAW",
        version."processedWidth" AS "ZWIDTH",
        version."processedHeight" AS "ZHEIGHT",
        master."fileSize" AS "ZFILESIZE",
        version."latitude" AS "ZLATITUDE",
        version."longitude" AS "ZLONGITUDE",
        version."isInTrash" AS "ZTRASHEDSTATE",
        version."showInLibrary" AS "ZVISIBILITYSTATE",
        \(cloudAssetGuidSelect),
        master."imagePath" AS "ZORIGINALPATH",
        CASE
          WHEN version."subType" = 16 AND version."nonRawMasterUuid" IS NOT NULL
            THEN nonRawMaster."UTI"
          ELSE master."UTI"
        END AS "ZUNIFORMTYPEIDENTIFIER"
      FROM "RKVersion" AS version
      LEFT JOIN "RKMaster" AS master
        ON master."uuid" = version."masterUuid"
      LEFT JOIN "RKMaster" AS nonRawMaster
        ON nonRawMaster."uuid" = version."nonRawMasterUuid"
      \(legacyImportGroupJoin(enabled: hasImportGroup))
      WHERE (version."isInTrash" IS NULL OR version."isInTrash" = 0)
        AND (
          version."burstUuid" IS NULL OR
          version."burstPickType" IS NULL OR
          version."burstPickType" = 0 OR
          (version."burstPickType" & 8) != 0 OR
          (version."burstPickType" & 16) != 0
        )
      ORDER BY version."uuid"
      """
  )
  let albumMembership = try legacyAssetMembershipByVersionID(database: database)
  let keywordMembership = try legacyKeywordMembershipByVersionID(database: database)
  let personMembership = try legacyPersonMembershipByVersionID(database: database)
  let adjustmentFormats = try legacyAdjustmentFormatByUUID(database: database)
  let inCloudByUUID = try legacyInCloudByUUID(database: database)
  let placeValues = try legacyPlaceValuesByVersionID(database: database)
  for index in rows.indices {
    if let pk = rows[index]["Z_PK"], let membership = albumMembership[pk] {
      if !membership.albums.isEmpty {
        rows[index]["ZALBUMS"] = membership.albums.joined(separator: internalListSeparator)
      }
      if !membership.albumPaths.isEmpty {
        rows[index]["ZALBUMPATHS"] = membership.albumPaths.joined(separator: internalListSeparator)
      }
      if !membership.folderPaths.isEmpty {
        rows[index]["ZFOLDERS"] = membership.folderPaths.joined(separator: internalListSeparator)
      }
    }
    if let pk = rows[index]["Z_PK"], let keywords = keywordMembership[pk], !keywords.isEmpty {
      rows[index]["ZKEYWORDS"] = keywords.joined(separator: internalListSeparator)
    }
    if let pk = rows[index]["Z_PK"], let persons = personMembership[pk], !persons.isEmpty {
      rows[index]["ZPERSONS"] = persons.joined(separator: internalListSeparator)
    }
    if let adjustmentUUID = firstNonEmpty(rows[index]["ZADJUSTMENTUUID"]),
      let adjustmentFormat = adjustmentFormats[adjustmentUUID]
    {
      rows[index]["ZADJUSTMENTFORMATIDENTIFIER"] = adjustmentFormat
    }
    if let uuid = rows[index]["ZUUID"], let inCloud = inCloudByUUID[uuid] {
      rows[index]["ZINCLOUD"] = inCloud ? "1" : "0"
    }
    if let pk = rows[index]["Z_PK"], let place = placeValues[pk] {
      rows[index]["ZHASPLACE"] = place.hasPlace ? "1" : "0"
      rows[index]["ZPLACENAME"] = place.displayName ?? ""
      rows[index]["ZPLACENAMES"] = place.names.joined(separator: internalListSeparator)
    }
  }
  return rows
}

private func legacyCloudAssetGuidSelect(
  versionColumns: Set<String>,
  masterColumns: Set<String>
) -> String {
  let stateExpression: String
  if masterColumns.contains("cloudLibraryState") {
    stateExpression = #"master."cloudLibraryState""#
  } else if versionColumns.contains("cloudLibraryState") {
    stateExpression = #"version."cloudLibraryState""#
  } else {
    return #"NULL AS "ZCLOUDASSETGUID""#
  }

  let cloudIdentifierExpression =
    versionColumns.contains("cloudIdentifier")
    ? #"NULLIF(version."cloudIdentifier", '')"#
    : "NULL"

  return """
    CASE
      WHEN \(stateExpression) IS NOT NULL AND \(stateExpression) != 0
        THEN COALESCE(\(cloudIdentifierExpression), version."uuid")
      ELSE NULL
    END AS "ZCLOUDASSETGUID"
    """
}

private func legacyInCloudByUUID(database: SQLiteReadOnlyDatabase) throws -> [String: Bool] {
  guard try database.tableExists("RKCloudResource"),
    try database.tableExists("RKMaster"),
    try database.tableExists("RKVersion")
  else {
    return [:]
  }

  let cloudColumns = Set(try database.columns(in: "RKCloudResource"))
  let masterColumns = Set(try database.columns(in: "RKMaster"))
  let versionColumns = Set(try database.columns(in: "RKVersion"))
  guard cloudColumns.contains("fingerprint"),
    cloudColumns.contains("available"),
    masterColumns.contains("fingerprint"),
    masterColumns.contains("uuid"),
    versionColumns.contains("uuid"),
    versionColumns.contains("masterUuid")
  else {
    return [:]
  }

  let rows = try database.rawRows(
    sql: """
      SELECT
        version."uuid" AS "uuid",
        cloud."available" AS "available"
      FROM "RKCloudResource" AS cloud
      INNER JOIN "RKMaster" AS master
        ON master."fingerprint" = cloud."fingerprint"
      INNER JOIN "RKVersion" AS version
        ON version."masterUuid" = master."uuid"
      """
  )
  var result: [String: Bool] = [:]
  for row in rows {
    guard let uuid = firstNonEmpty(row["uuid"]) else {
      continue
    }
    result[uuid] = intValue(row["available"]) == 1
  }
  return result
}

private struct PhotosPlaceValues {
  var hasPlace: Bool
  var displayName: String?
  var names: [String]
}

private struct PhotosPlaceComponent {
  var name: String
  var type: Int
  var area: Double
}

private func legacyPlaceValuesByVersionID(database: SQLiteReadOnlyDatabase) throws -> [String:
  PhotosPlaceValues]
{
  guard try database.tableExists("RKPlace"), try database.tableExists("RKPlaceForVersion") else {
    return [:]
  }
  let rows = try database.rawRows(
    sql: """
      SELECT
        placeForVersion."versionId" AS "version_id",
        place."defaultName" AS "name",
        place."type" AS "type",
        place."area" AS "area"
      FROM "RKPlaceForVersion" AS placeForVersion
      JOIN "RKPlace" AS place
        ON place."modelID" = placeForVersion."placeId"
      WHERE place."defaultName" IS NOT NULL AND place."defaultName" != ''
      """
  )
  var grouped: [String: [PhotosPlaceComponent]] = [:]
  for row in rows {
    guard let versionID = firstNonEmpty(row["version_id"]),
      let name = firstNonEmpty(row["name"]),
      let type = intValue(row["type"])
    else {
      continue
    }
    grouped[versionID, default: []].append(
      PhotosPlaceComponent(
        name: name,
        type: type,
        area: Double(firstNonEmpty(row["area"]) ?? "") ?? 0
      )
    )
  }
  return grouped.mapValues(legacyPlaceValues(from:))
}

private func legacyPlaceValues(from components: [PhotosPlaceComponent]) -> PhotosPlaceValues {
  let grouped = Dictionary(grouping: components, by: \.type)
  func sortedNames(for type: Int) -> [String] {
    (grouped[type] ?? [])
      .sorted { $0.area < $1.area }
      .map(\.name)
  }

  let country = sortedNames(for: 1)
  let stateProvince = sortedNames(for: 2)
  let subAdministrativeArea = sortedNames(for: 4)
  let city = sortedNames(for: 16)
  let bodyOfWater = sortedNames(for: 44)
  let areaOfInterest = sortedNames(for: 45)
  let names =
    country + stateProvince + subAdministrativeArea + city + areaOfInterest + bodyOfWater

  var displayParts: [String] = []
  if let firstArea = areaOfInterest.first {
    displayParts.append(firstArea)
    if let firstCity = city.first {
      displayParts.append(firstCity)
    }
  } else if let firstCity = city.first {
    displayParts.append(firstCity)
    if let firstState = stateProvince.first {
      displayParts.append(firstState)
    }
  } else if let firstState = stateProvince.first {
    displayParts.append(firstState)
  }
  if let firstCountry = country.first {
    displayParts.append(firstCountry)
  }

  return PhotosPlaceValues(
    hasPlace: true,
    displayName: displayParts.isEmpty ? nil : displayParts.joined(separator: ", "),
    names: names
  )
}

private func photosModernPlaceValues(hex: String?) -> PhotosPlaceValues? {
  guard let hex, let data = dataFromHex(hex), !data.isEmpty,
    let archive = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
      as? [String: Any],
    let objects = archive["$objects"] as? [Any],
    let top = archive["$top"] as? [String: Any],
    let root = keyedArchiveObject(top["root"], objects: objects) as? [String: Any],
    let mapItem = keyedArchiveObject(root["mapItem"], objects: objects) as? [String: Any],
    let sortedPlaceInfos = keyedArchiveObject(mapItem["sortedPlaceInfos"], objects: objects)
      as? [String: Any],
    let placeUIDs = sortedPlaceInfos["NS.objects"] as? [Any]
  else {
    return nil
  }

  var components: [PhotosPlaceComponent] = []
  for placeUID in placeUIDs {
    guard let place = keyedArchiveObject(placeUID, objects: objects) as? [String: Any],
      let name = keyedArchiveString(place["name"], objects: objects),
      let type = keyedArchiveInt(place["placeType"], objects: objects)
    else {
      continue
    }
    components.append(
      PhotosPlaceComponent(
        name: name,
        type: type,
        area: keyedArchiveDouble(place["area"], objects: objects) ?? 0
      )
    )
  }

  guard !components.isEmpty else {
    return PhotosPlaceValues(hasPlace: true, displayName: nil, names: [])
  }
  return modernPlaceValues(from: components)
}

private func modernPlaceValues(from components: [PhotosPlaceComponent]) -> PhotosPlaceValues {
  let grouped = Dictionary(grouping: components, by: \.type)
  func sortedNames(for type: Int) -> [String] {
    (grouped[type] ?? [])
      .sorted { $0.area < $1.area }
      .map(\.name)
  }

  let namesByType = (0..<18).map(sortedNames(for:))
  let bodyOfWater = sortedNames(for: 7) + sortedNames(for: 9)
  let names = namesByType.flatMap { $0 } + bodyOfWater
  let displayParts = [8, 11, 4, 2, 1, 9, 7].compactMap { namesByType[$0].first }

  return PhotosPlaceValues(
    hasPlace: true,
    displayName: displayParts.isEmpty ? nil : displayParts.joined(separator: ", "),
    names: names
  )
}

private func keyedArchiveObject(_ value: Any?, objects: [Any]) -> Any? {
  guard let index = keyedArchiveUIDIndex(value), objects.indices.contains(index) else {
    return nil
  }
  return objects[index]
}

private func keyedArchiveString(_ value: Any?, objects: [Any]) -> String? {
  if let string = value as? String {
    return normalizedString(string)
  }
  return normalizedString(keyedArchiveObject(value, objects: objects) as? String)
}

private func keyedArchiveInt(_ value: Any?, objects: [Any]) -> Int? {
  if let number = value as? NSNumber {
    return number.intValue
  }
  return (keyedArchiveObject(value, objects: objects) as? NSNumber)?.intValue
}

private func keyedArchiveDouble(_ value: Any?, objects: [Any]) -> Double? {
  if let number = value as? NSNumber {
    return number.doubleValue
  }
  return (keyedArchiveObject(value, objects: objects) as? NSNumber)?.doubleValue
}

private func keyedArchiveUIDIndex(_ value: Any?) -> Int? {
  guard let value else {
    return nil
  }
  if let number = value as? NSNumber {
    return number.intValue
  }
  let description = String(describing: value)
  guard let range = description.range(of: "value = ") else {
    return nil
  }
  let suffix = description[range.upperBound...]
  let digits = suffix.prefix { $0.isNumber }
  return digits.isEmpty ? nil : Int(digits)
}

private func dataFromHex(_ value: String) -> Data? {
  let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard text.count.isMultiple(of: 2) else {
    return nil
  }
  var bytes: [UInt8] = []
  var index = text.startIndex
  while index < text.endIndex {
    let next = text.index(index, offsetBy: 2)
    guard let byte = UInt8(text[index..<next], radix: 16) else {
      return nil
    }
    bytes.append(byte)
    index = next
  }
  return Data(bytes)
}

private struct AssetMembership {
  var albums: [String]
  var albumPaths: [String]
  var folderPaths: [String]
}

private struct AlbumMetadata {
  var pk: String
  var uuid: String?
  var title: String?
  var parentPK: String?
  var kind: Int?
  var isTrashed: Bool
}

private func assetMembershipByAssetPK(database: SQLiteReadOnlyDatabase) throws -> [String:
  AssetMembership]
{
  guard try database.tableExists("ZGENERICALBUM") else {
    return [:]
  }

  let albumColumns = Set(try database.columns(in: "ZGENERICALBUM"))
  var albumFilters: [String] = []
  if albumColumns.contains("ZTRASHEDSTATE") {
    albumFilters.append(#"(album."ZTRASHEDSTATE" IS NULL OR album."ZTRASHEDSTATE" = 0)"#)
  }
  if albumColumns.contains("ZKIND") {
    albumFilters.append(#"(album."ZKIND" IS NULL OR album."ZKIND" != 1508)"#)
  }
  let albumFilter = albumFilters.isEmpty ? "" : "WHERE " + albumFilters.joined(separator: " AND ")
  let albumMetadata = try genericAlbumMetadataByPK(database: database)
  let tables = try database.tableNames()
  for table in tables where table.hasPrefix("Z_") && table.hasSuffix("ASSETS") {
    let columns = try database.columns(in: table)
    guard
      let albumColumn = columns.first(where: {
        $0.range(of: #"^Z_\d+ALBUMS$"#, options: .regularExpression) != nil
      }),
      let assetColumn = columns.first(where: {
        $0.range(of: #"^Z_\d+ASSETS$"#, options: .regularExpression) != nil
      })
    else {
      continue
    }

    let rows = try database.rawRows(
      sql: """
        SELECT
          membership.\(quotedIdentifier(assetColumn)) AS "asset_pk",
          album."Z_PK" AS "album_pk",
          album."ZUUID" AS "album_uuid",
          album."ZTITLE" AS "album_title"
        FROM \(quotedIdentifier(table)) AS membership
        JOIN "ZGENERICALBUM" AS album
          ON album."Z_PK" = membership.\(quotedIdentifier(albumColumn))
        \(albumFilter)
        """
    )
    return groupedMembership(rows, albumMetadata: albumMetadata)
  }
  return [:]
}

private func albumMembershipCountsByAlbumPK(database: SQLiteReadOnlyDatabase) throws
  -> [String: Int]
{
  guard try database.tableExists("ZGENERICALBUM") else {
    return [:]
  }

  let albumColumns = Set(try database.columns(in: "ZGENERICALBUM"))
  var albumFilters: [String] = []
  if albumColumns.contains("ZTRASHEDSTATE") {
    albumFilters.append(#"(album."ZTRASHEDSTATE" IS NULL OR album."ZTRASHEDSTATE" = 0)"#)
  }
  if albumColumns.contains("ZKIND") {
    albumFilters.append(#"(album."ZKIND" IS NULL OR album."ZKIND" != 1508)"#)
  }
  let albumFilter = albumFilters.isEmpty ? "" : "WHERE " + albumFilters.joined(separator: " AND ")
  let tables = try database.tableNames()
  for table in tables where table.hasPrefix("Z_") && table.hasSuffix("ASSETS") {
    let columns = try database.columns(in: table)
    guard
      let albumColumn = columns.first(where: {
        $0.range(of: #"^Z_\d+ALBUMS$"#, options: .regularExpression) != nil
      }),
      let assetColumn = columns.first(where: {
        $0.range(of: #"^Z_\d+ASSETS$"#, options: .regularExpression) != nil
      })
    else {
      continue
    }

    let rows = try database.rawRows(
      sql: """
        SELECT
          membership.\(quotedIdentifier(albumColumn)) AS "album_pk",
          COUNT(DISTINCT membership.\(quotedIdentifier(assetColumn))) AS "item_count"
        FROM \(quotedIdentifier(table)) AS membership
        JOIN "ZGENERICALBUM" AS album
          ON album."Z_PK" = membership.\(quotedIdentifier(albumColumn))
        \(albumFilter)
        GROUP BY membership.\(quotedIdentifier(albumColumn))
        """
    )
    return Dictionary(
      uniqueKeysWithValues: rows.compactMap { row in
        guard let albumPK = normalizedString(row["album_pk"]), !albumPK.isEmpty,
          let count = row["item_count"].flatMap(Int.init)
        else {
          return nil
        }
        return (albumPK, count)
      }
    )
  }
  return [:]
}

private func keywordMembershipByAssetPK(database: SQLiteReadOnlyDatabase) throws -> [String:
  [String]]
{
  guard try database.tableExists("ZKEYWORD"),
    try database.tableExists("ZADDITIONALASSETATTRIBUTES")
  else {
    return [:]
  }

  let tables = try database.tableNames()
  for table in tables where table.hasPrefix("Z_") && table.uppercased().contains("KEYWORDS") {
    let columns = try database.columns(in: table)
    guard
      let assetAttributesColumn = columns.first(where: {
        $0.range(of: #"^Z_\d+ASSETATTRIBUTES$"#, options: .regularExpression) != nil
      }),
      let keywordColumn = columns.first(where: {
        $0.range(of: #"^Z_\d+KEYWORDS$"#, options: .regularExpression) != nil
      })
    else {
      continue
    }

    let rows = try database.rawRows(
      sql: """
        SELECT
          additional."ZASSET" AS "asset_pk",
          keyword."ZTITLE" AS "keyword"
        FROM \(quotedIdentifier(table)) AS keywordJoin
        JOIN "ZADDITIONALASSETATTRIBUTES" AS additional
          ON additional."Z_PK" = keywordJoin.\(quotedIdentifier(assetAttributesColumn))
        JOIN "ZKEYWORD" AS keyword
          ON keyword."Z_PK" = keywordJoin.\(quotedIdentifier(keywordColumn))
        WHERE keyword."ZTITLE" IS NOT NULL AND keyword."ZTITLE" != ''
        """
    )
    return groupedKeywords(rows)
  }

  return [:]
}

private func personMembershipByAssetPK(database: SQLiteReadOnlyDatabase) throws -> [String:
  [String]]
{
  guard try database.tableExists("ZPERSON"), try database.tableExists("ZDETECTEDFACE") else {
    return [:]
  }

  let personColumns = Set(try database.columns(in: "ZPERSON"))
  let faceColumns = Set(try database.columns(in: "ZDETECTEDFACE"))
  guard
    let assetColumn = firstAvailableColumn(
      ["ZASSETFORFACE", "ZASSET", "ZASSETFORTEMPORALDETECTEDFACES"],
      in: faceColumns
    ),
    let personColumn = firstAvailableColumn(
      ["ZPERSONFORFACE", "ZPERSON", "ZPERSONFORTEMPORALDETECTEDFACES"],
      in: faceColumns
    )
  else {
    return [:]
  }
  let nameColumn = firstAvailableColumn(["ZFULLNAME", "ZDISPLAYNAME"], in: personColumns)

  let personExpression: String
  if let nameColumn {
    personExpression =
      #"COALESCE(NULLIF(person.\#(quotedIdentifier(nameColumn)), ''), '_UNKNOWN_')"#
  } else {
    personExpression = #"'_UNKNOWN_'"#
  }

  let rows = try database.rawRows(
    sql: """
      SELECT
        face.\(quotedIdentifier(assetColumn)) AS "asset_pk",
        \(personExpression) AS "person"
      FROM "ZDETECTEDFACE" AS face
      JOIN "ZPERSON" AS person
        ON person."Z_PK" = face.\(quotedIdentifier(personColumn))
      WHERE face.\(quotedIdentifier(assetColumn)) IS NOT NULL
      """
  )
  return groupedPeople(rows)
}

private func legacyAssetMembershipByVersionID(database: SQLiteReadOnlyDatabase) throws -> [String:
  AssetMembership]
{
  guard try database.tableExists("RKAlbumVersion"), try database.tableExists("RKAlbum") else {
    return [:]
  }
  let folders = try legacyFolderMetadataByUUID(database: database)
  let rows = try database.rawRows(
    sql: """
      SELECT
        albumVersion."versionId" AS "asset_pk",
        album."folderUuid" AS "folder_uuid",
        album."uuid" AS "album_uuid",
        album."name" AS "album_title"
      FROM "RKAlbumVersion" AS albumVersion
      JOIN "RKAlbum" AS album
        ON album."modelId" = albumVersion."albumId"
      WHERE (album."isInTrash" IS NULL OR album."isInTrash" = 0)
        AND (album."albumType" IS NULL OR album."albumType" = 1)
      """
  )
  return groupedLegacyMembership(rows, folders: folders)
}

private func legacyKeywordMembershipByVersionID(database: SQLiteReadOnlyDatabase) throws -> [String:
  [String]]
{
  guard try database.tableExists("RKKeywordForVersion"),
    try database.tableExists("RKKeyword")
  else {
    return [:]
  }
  let rows = try database.rawRows(
    sql: """
      SELECT
        keywordForVersion."versionId" AS "asset_pk",
        keyword."name" AS "keyword"
      FROM "RKKeywordForVersion" AS keywordForVersion
      JOIN "RKKeyword" AS keyword
        ON keyword."modelId" = keywordForVersion."keywordId"
      WHERE keyword."name" IS NOT NULL AND keyword."name" != ''
      """
  )
  return groupedKeywords(rows)
}

private func legacyPersonMembershipByVersionID(database: SQLiteReadOnlyDatabase) throws -> [String:
  [String]]
{
  guard try database.tableExists("RKPerson"),
    try database.tableExists("RKFace"),
    try database.tableExists("RKVersion")
  else {
    return [:]
  }
  let personColumns = Set(try database.columns(in: "RKPerson"))
  let faceColumns = Set(try database.columns(in: "RKFace"))
  let versionColumns = Set(try database.columns(in: "RKVersion"))
  guard
    let personPKColumn = firstAvailableColumn(["modelID", "modelId"], in: personColumns),
    let facePersonColumn = firstAvailableColumn(["personID", "personId"], in: faceColumns),
    let faceImageColumn = firstAvailableColumn(["ImageModelId", "imageModelId"], in: faceColumns),
    let versionPKColumn = firstAvailableColumn(["modelID", "modelId"], in: versionColumns)
  else {
    return [:]
  }
  let nameColumn = firstAvailableColumn(["name", "displayName"], in: personColumns)
  let personExpression: String
  if let nameColumn {
    personExpression =
      #"COALESCE(NULLIF(person.\#(quotedIdentifier(nameColumn)), ''), '_UNKNOWN_')"#
  } else {
    personExpression = #"'_UNKNOWN_'"#
  }

  let rows = try database.rawRows(
    sql: """
      SELECT
        version.\(quotedIdentifier(versionPKColumn)) AS "asset_pk",
        \(personExpression) AS "person"
      FROM "RKFace" AS face
      JOIN "RKPerson" AS person
        ON person.\(quotedIdentifier(personPKColumn)) = face.\(quotedIdentifier(facePersonColumn))
      JOIN "RKVersion" AS version
        ON version.\(quotedIdentifier(versionPKColumn)) = face.\(quotedIdentifier(faceImageColumn))
      """
  )
  return groupedPeople(rows)
}

private struct PhotosSharedReactionPayload: Codable {
  var dateSeconds: Double?
  var user: String?
  var isMine: Bool
  var text: String?
}

private struct PhotosSharedReactionMembership {
  var comments: [PhotosSharedReactionPayload] = []
  var likes: [PhotosSharedReactionPayload] = []
}

private func commentLikeMembershipByUUID(
  database: SQLiteReadOnlyDatabase,
  assetTable: String
) throws -> [String: PhotosSharedReactionMembership] {
  guard try database.tableExists("ZCLOUDSHAREDCOMMENT") else {
    return [:]
  }
  let commentColumns = Set(try database.columns(in: "ZCLOUDSHAREDCOMMENT"))
  let assetColumns = Set(try database.columns(in: assetTable))
  guard assetColumns.contains("Z_PK"), assetColumns.contains("ZUUID"),
    commentColumns.contains("ZISLIKE"),
    commentColumns.contains("ZCOMMENTDATE"),
    commentColumns.contains("ZCOMMENTERHASHEDPERSONID"),
    commentColumns.contains("ZISMYCOMMENT")
  else {
    return [:]
  }

  var joinPredicates: [String] = []
  if commentColumns.contains("ZCOMMENTEDASSET") {
    joinPredicates.append(#"asset."Z_PK" = comment."ZCOMMENTEDASSET""#)
  }
  if commentColumns.contains("ZLIKEDASSET") {
    joinPredicates.append(#"asset."Z_PK" = comment."ZLIKEDASSET""#)
  }
  guard !joinPredicates.isEmpty else {
    return [:]
  }

  let userNames = try sharedCommentUserNamesByPersonID(database: database)
  let rows = try database.rawRows(
    sql: """
      SELECT
        asset."ZUUID" AS "uuid",
        comment."ZISLIKE" AS "is_like",
        comment."ZCOMMENTDATE" AS "date_seconds",
        \(optionalColumn(
          tableAlias: "comment",
          column: "ZCOMMENTTEXT",
          alias: "text",
          available: commentColumns
        )),
        comment."ZCOMMENTERHASHEDPERSONID" AS "person_id",
        comment."ZISMYCOMMENT" AS "is_mine"
      FROM "ZCLOUDSHAREDCOMMENT" AS comment
      JOIN \(quotedIdentifier(assetTable)) AS asset
        ON \(joinPredicates.joined(separator: " OR "))
      """
  )

  var grouped: [String: PhotosSharedReactionMembership] = [:]
  for row in rows {
    guard let uuid = normalizedString(row["uuid"]), !uuid.isEmpty else {
      continue
    }
    let personID = normalizedString(row["person_id"])
    let payload = PhotosSharedReactionPayload(
      dateSeconds: doubleValue(row["date_seconds"]),
      user: personID.flatMap { userNames[$0] },
      isMine: bool(from: row["is_mine"]),
      text: normalizedString(row["text"])
    )
    var membership = grouped[uuid] ?? PhotosSharedReactionMembership()
    if bool(from: row["is_like"]) {
      membership.likes.append(payload)
    } else if payload.text?.isEmpty == false {
      membership.comments.append(payload)
    }
    grouped[uuid] = membership
  }

  return grouped.mapValues { membership in
    PhotosSharedReactionMembership(
      comments: membership.comments.sorted(by: photosSharedReactionSort),
      likes: membership.likes.sorted(by: photosSharedReactionSort)
    )
  }
}

private func sharedCommentUserNamesByPersonID(database: SQLiteReadOnlyDatabase) throws -> [String:
  String]
{
  var rows: [[String: String]] = []
  if try database.tableExists("ZCLOUDSHAREDALBUMINVITATIONRECORD") {
    let columns = Set(try database.columns(in: "ZCLOUDSHAREDALBUMINVITATIONRECORD"))
    if columns.contains("ZINVITEEHASHEDPERSONID") {
      rows += try database.rawRows(
        sql: sharedCommentPersonSelect(
          table: "ZCLOUDSHAREDALBUMINVITATIONRECORD",
          idColumn: "ZINVITEEHASHEDPERSONID",
          firstColumn: "ZINVITEEFIRSTNAME",
          lastColumn: "ZINVITEELASTNAME",
          fullColumn: "ZINVITEEFULLNAME",
          available: columns
        ))
    }
  }
  if try database.tableExists("ZGENERICALBUM") {
    let columns = Set(try database.columns(in: "ZGENERICALBUM"))
    if columns.contains("ZCLOUDOWNERHASHEDPERSONID") {
      rows += try database.rawRows(
        sql: sharedCommentPersonSelect(
          table: "ZGENERICALBUM",
          idColumn: "ZCLOUDOWNERHASHEDPERSONID",
          firstColumn: "ZCLOUDOWNERFIRSTNAME",
          lastColumn: "ZCLOUDOWNERLASTNAME",
          fullColumn: "ZCLOUDOWNERFULLNAME",
          available: columns
        ))
    }
  }

  var names: [String: String] = [:]
  for row in rows {
    guard let id = normalizedString(row["person_id"]), !id.isEmpty else {
      continue
    }
    let fullName = firstNonEmpty(
      row["full_name"],
      [normalizedString(row["first_name"]), normalizedString(row["last_name"])]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    )
    if let fullName, !fullName.isEmpty {
      names[id] = fullName
    }
  }
  return names
}

private func sharedCommentPersonSelect(
  table: String,
  idColumn: String,
  firstColumn: String,
  lastColumn: String,
  fullColumn: String,
  available: Set<String>
) -> String {
  """
  SELECT DISTINCT
    person.\(quotedIdentifier(idColumn)) AS "person_id",
    \(optionalColumn(tableAlias: "person", column: firstColumn, alias: "first_name", available: available)),
    \(optionalColumn(tableAlias: "person", column: lastColumn, alias: "last_name", available: available)),
    \(optionalColumn(tableAlias: "person", column: fullColumn, alias: "full_name", available: available))
  FROM \(quotedIdentifier(table)) AS person
  """
}

private func photosSharedReactionSort(
  _ lhs: PhotosSharedReactionPayload,
  _ rhs: PhotosSharedReactionPayload
) -> Bool {
  (lhs.dateSeconds ?? 0) < (rhs.dateSeconds ?? 0)
}

private func photosEncodeSharedReactionPayloads(_ payloads: [PhotosSharedReactionPayload])
  -> String
{
  guard !payloads.isEmpty else {
    return ""
  }
  let encoder = JSONEncoder()
  guard let data = try? encoder.encode(payloads) else {
    return ""
  }
  return String(decoding: data, as: UTF8.self)
}

private func groupedKeywords(_ rows: [[String: String]]) -> [String: [String]] {
  var grouped: [String: Set<String>] = [:]
  for row in rows {
    guard let assetPK = normalizedString(row["asset_pk"]), !assetPK.isEmpty,
      let keyword = normalizedString(row["keyword"]), !keyword.isEmpty
    else {
      continue
    }
    var values = grouped[assetPK] ?? []
    values.insert(keyword)
    grouped[assetPK] = values
  }
  return grouped.mapValues { $0.sorted() }
}

private func groupedPeople(_ rows: [[String: String]]) -> [String: [String]] {
  var grouped: [String: [String]] = [:]
  for row in rows {
    guard let assetPK = normalizedString(row["asset_pk"]), !assetPK.isEmpty,
      let person = normalizedString(row["person"]), !person.isEmpty
    else {
      continue
    }
    var values = grouped[assetPK] ?? []
    values.append(person)
    grouped[assetPK] = values
  }
  return grouped.mapValues { $0.sorted() }
}

private func groupedMembership(
  _ rows: [[String: String]],
  albumMetadata: [String: AlbumMetadata]
) -> [String: AssetMembership] {
  var membership: [String: Set<String>] = [:]
  var albumPathMembership: [String: Set<String>] = [:]
  var folderMembership: [String: Set<String>] = [:]
  for row in rows {
    guard let assetPK = row["asset_pk"], !assetPK.isEmpty else {
      continue
    }
    var values = membership[assetPK] ?? []
    for key in ["album_uuid", "album_title"] {
      if let value = normalizedString(row[key]), !value.isEmpty {
        values.insert(value)
      }
    }
    membership[assetPK] = values
    if let albumPK = row["album_pk"] {
      let folderPath = folderPath(forAlbumPK: albumPK, metadataByPK: albumMetadata)
      if let albumTitle = normalizedString(row["album_title"]), !albumTitle.isEmpty {
        var albumPathValues = albumPathMembership[assetPK] ?? []
        if let folderPath, !folderPath.isEmpty {
          albumPathValues.insert("\(folderPath)/\(albumTitle)")
        } else {
          albumPathValues.insert(albumTitle)
        }
        albumPathMembership[assetPK] = albumPathValues
      }
      if let folderPath, !folderPath.isEmpty {
        var folderValues = folderMembership[assetPK] ?? []
        folderValues.insert(folderPath)
        folderMembership[assetPK] = folderValues
      }
    }
  }
  return groupedAssetMembership(
    albums: membership, albumPaths: albumPathMembership, folderPaths: folderMembership)
}

private func groupedLegacyMembership(
  _ rows: [[String: String]],
  folders: [String: LegacyFolderMetadata]
) -> [String: AssetMembership] {
  var membership: [String: Set<String>] = [:]
  var albumPathMembership: [String: Set<String>] = [:]
  var folderMembership: [String: Set<String>] = [:]
  for row in rows {
    guard let assetPK = row["asset_pk"], !assetPK.isEmpty else {
      continue
    }
    var values = membership[assetPK] ?? []
    for key in ["album_uuid", "album_title"] {
      if let value = normalizedString(row[key]), !value.isEmpty {
        values.insert(value)
      }
    }
    membership[assetPK] = values

    if let albumTitle = normalizedString(row["album_title"]), !albumTitle.isEmpty {
      var albumPathValues = albumPathMembership[assetPK] ?? []
      if let folderUUID = normalizedString(row["folder_uuid"]),
        let folderPath = legacyFolderPath(for: folderUUID, folders: folders),
        !folderPath.isEmpty
      {
        albumPathValues.insert("\(folderPath)/\(albumTitle)")
      } else {
        albumPathValues.insert(albumTitle)
      }
      albumPathMembership[assetPK] = albumPathValues
    }

    if let folderUUID = normalizedString(row["folder_uuid"]),
      let folderPath = legacyFolderPath(for: folderUUID, folders: folders),
      !folderPath.isEmpty
    {
      var folderValues = folderMembership[assetPK] ?? []
      folderValues.insert(folderPath)
      folderMembership[assetPK] = folderValues
    }
  }
  return groupedAssetMembership(
    albums: membership, albumPaths: albumPathMembership, folderPaths: folderMembership)
}

private func groupedAssetMembership(
  albums: [String: Set<String>],
  albumPaths: [String: Set<String>],
  folderPaths: [String: Set<String>]
) -> [String: AssetMembership] {
  var result: [String: AssetMembership] = [:]
  for assetPK in Set(albums.keys).union(albumPaths.keys).union(folderPaths.keys) {
    result[assetPK] = AssetMembership(
      albums: albums[assetPK]?.sorted() ?? [],
      albumPaths: albumPaths[assetPK]?.sorted() ?? [],
      folderPaths: folderPaths[assetPK]?.sorted() ?? []
    )
  }
  return result
}

private func genericAlbumMetadataByPK(database: SQLiteReadOnlyDatabase) throws -> [String:
  AlbumMetadata]
{
  let columns = Set(try database.columns(in: "ZGENERICALBUM"))
  let album = { (column: String) in
    optionalColumn(tableAlias: "album", column: column, alias: column, available: columns)
  }
  let rows = try database.rawRows(
    sql: """
      SELECT
        album."Z_PK" AS "Z_PK",
        \(album("ZUUID")),
        \(album("ZTITLE")),
        \(album("ZPARENTFOLDER")),
        \(album("ZKIND")),
        \(album("ZTRASHEDSTATE"))
      FROM "ZGENERICALBUM" AS album
      """
  )
  return Dictionary(
    uniqueKeysWithValues: rows.compactMap { row in
      guard let pk = normalizedString(row["Z_PK"]), !pk.isEmpty else {
        return nil
      }
      return (
        pk,
        AlbumMetadata(
          pk: pk,
          uuid: normalizedString(row["ZUUID"]),
          title: normalizedString(row["ZTITLE"]),
          parentPK: normalizedString(row["ZPARENTFOLDER"]),
          kind: row["ZKIND"].flatMap(Int.init),
          isTrashed: bool(from: row["ZTRASHEDSTATE"])
        )
      )
    })
}

private func photosIsVisibleContainer(_ row: [String: String]) -> Bool {
  !bool(from: row["ZTRASHEDSTATE"])
}

private func photosIsAlbumRow(_ row: [String: String]) -> Bool {
  guard let kind = row["ZKIND"].flatMap(Int.init) else {
    return true
  }
  return kind == 2 || kind == 1505
}

private func photosAlbumSpecialKind(_ row: [String: String]) -> String? {
  switch row["ZKIND"].flatMap(Int.init) {
  case 1505:
    return "shared"
  default:
    return nil
  }
}

private func photosIsFolderRow(_ row: [String: String]) -> Bool {
  row["ZKIND"].flatMap(Int.init) == 4000
}

private func photosParentContainerID(
  from row: [String: String],
  metadataByPK: [String: AlbumMetadata]
) -> String? {
  guard let parentPK = normalizedString(row["ZPARENTFOLDER"]), !parentPK.isEmpty else {
    return nil
  }
  return metadataByPK[parentPK]?.uuid ?? parentPK
}

private func photosLimit<T>(_ values: [T], limit: Int?) -> [T] {
  guard let limit else {
    return values
  }
  return Array(values.prefix(max(0, limit)))
}

private func folderPath(
  forAlbumPK albumPK: String,
  metadataByPK: [String: AlbumMetadata]
) -> String? {
  guard let album = metadataByPK[albumPK] else {
    return nil
  }
  var folderNames: [String] = []
  var currentPK = album.parentPK
  var seen: Set<String> = []
  while let pk = currentPK, !pk.isEmpty, !seen.contains(pk), let folder = metadataByPK[pk] {
    seen.insert(pk)
    if isUserFolder(folder), let title = folder.title, !title.isEmpty {
      folderNames.append(title)
    }
    currentPK = folder.parentPK
  }
  let path = folderNames.reversed().joined(separator: "/")
  return path.isEmpty ? nil : path
}

private func isUserFolder(_ metadata: AlbumMetadata) -> Bool {
  !metadata.isTrashed
    && metadata.title?.isEmpty == false
    && (metadata.kind == 4000 || metadata.kind == 2 || metadata.kind == 3999)
}

private struct LegacyFolderMetadata {
  var uuid: String
  var name: String?
  var parentUUID: String?
}

private func legacyAdjustmentFormatByUUID(database: SQLiteReadOnlyDatabase) throws -> [String:
  String]
{
  guard try database.tableExists("RKAdjustmentData") else {
    return [:]
  }
  let columns = Set(try database.columns(in: "RKAdjustmentData"))
  guard columns.contains("uuid"), columns.contains("format") else {
    return [:]
  }
  let rows = try database.rawRows(
    sql: """
      SELECT "uuid" AS "uuid", "format" AS "format"
      FROM "RKAdjustmentData"
      WHERE "format" IS NOT NULL AND "format" != ''
      """
  )
  var formats: [String: String] = [:]
  for row in rows {
    guard let uuid = firstNonEmpty(row["uuid"]), let format = firstNonEmpty(row["format"]) else {
      continue
    }
    formats[uuid] = format
  }
  return formats
}

private func legacyFolderMetadataByUUID(database: SQLiteReadOnlyDatabase) throws -> [String:
  LegacyFolderMetadata]
{
  guard try database.tableExists("RKFolder") else {
    return [:]
  }
  let rows = try database.rawRows(
    sql: """
      SELECT
        folder."uuid" AS "uuid",
        folder."name" AS "name",
        folder."parentFolderUuid" AS "parent_uuid"
      FROM "RKFolder" AS folder
      WHERE (folder."isInTrash" IS NULL OR folder."isInTrash" = 0)
      """
  )
  return Dictionary(
    uniqueKeysWithValues: rows.compactMap { row in
      guard let uuid = normalizedString(row["uuid"]), !uuid.isEmpty else {
        return nil
      }
      return (
        uuid,
        LegacyFolderMetadata(
          uuid: uuid,
          name: normalizedString(row["name"]),
          parentUUID: normalizedString(row["parent_uuid"])
        )
      )
    })
}

private func legacyFolderPath(for folderUUID: String, folders: [String: LegacyFolderMetadata])
  -> String?
{
  var names: [String] = []
  var currentUUID: String? = folderUUID
  var seen: Set<String> = []
  while let uuid = currentUUID, !uuid.isEmpty, !seen.contains(uuid), let folder = folders[uuid] {
    seen.insert(uuid)
    if let name = folder.name, !name.isEmpty, !isSystemFolderName(name), !isSystemFolderUUID(uuid) {
      names.append(name)
    }
    currentUUID = folder.parentUUID
  }
  let path = names.reversed().joined(separator: "/")
  return path.isEmpty ? nil : path
}

private func isSystemFolderName(_ value: String) -> Bool {
  [
    "AllProjectsItem",
    "LibraryFolder",
    "TopLevelAlbums",
    "TopLevelKeepsakes",
    "TopLevelSlideshows",
    "Trash",
    "mediaTypesFolder",
  ].contains(value)
}

private func isSystemFolderUUID(_ value: String) -> Bool {
  [
    "AllProjectsItem",
    "LibraryFolder",
    "MediaTypesSmartAlbums",
    "TopLevelAlbums",
    "TopLevelKeepsakes",
    "TopLevelSlideshows",
    "TrashFolder",
  ].contains(value)
}

private struct PhotosRawResourceMetadata {
  var uti: String?
  var path: String?
}

private func rawResourceMetadataByAssetPK(database: SQLiteReadOnlyDatabase) throws -> [String:
  PhotosRawResourceMetadata]
{
  guard try database.tableExists("ZINTERNALRESOURCE") else {
    return [:]
  }
  let columns = Set(try database.columns(in: "ZINTERNALRESOURCE"))
  guard columns.contains("ZASSET"), columns.contains("ZDATASTORESUBTYPE") else {
    return [:]
  }

  let utiExpression: String
  let utiJoin: String
  if columns.contains("ZCOMPACTUTI") {
    utiExpression = #"resource."ZCOMPACTUTI""#
    utiJoin = ""
  } else if columns.contains("ZUNIFORMTYPEIDENTIFIER") {
    if try database.tableExists("ZUNIFORMTYPEIDENTIFIER"),
      try database.columns(in: "ZUNIFORMTYPEIDENTIFIER").contains("ZIDENTIFIER")
    {
      utiExpression = #"COALESCE(identifier."ZIDENTIFIER", resource."ZUNIFORMTYPEIDENTIFIER")"#
      utiJoin = """
        LEFT JOIN "ZUNIFORMTYPEIDENTIFIER" AS identifier
          ON identifier."Z_PK" = resource."ZUNIFORMTYPEIDENTIFIER"
        """
    } else {
      utiExpression = #"resource."ZUNIFORMTYPEIDENTIFIER""#
      utiJoin = ""
    }
  } else {
    utiExpression = "NULL"
    utiJoin = ""
  }

  let pathSelects = [
    optionalColumn(
      tableAlias: "resource", column: "ZFILEURL", alias: "raw_path", available: columns),
    optionalColumn(
      tableAlias: "resource", column: "ZPATH", alias: "raw_path_alt", available: columns),
    optionalColumn(
      tableAlias: "resource", column: "ZORIGINALPATH", alias: "raw_original_path",
      available: columns),
  ]

  var filters = [#"resource."ZDATASTORESUBTYPE" = 17"#]
  if columns.contains("ZTRASHEDSTATE") {
    filters.append(#"(resource."ZTRASHEDSTATE" IS NULL OR resource."ZTRASHEDSTATE" = 0)"#)
  }

  let rows = try database.rawRows(
    sql: """
      SELECT
        resource."ZASSET" AS "asset_pk",
        \(utiExpression) AS "raw_uti",
        \(pathSelects.joined(separator: ", "))
      FROM "ZINTERNALRESOURCE" AS resource
      \(utiJoin)
      WHERE \(filters.joined(separator: " AND "))
      """
  )

  var result: [String: PhotosRawResourceMetadata] = [:]
  for row in rows {
    guard let assetPK = normalizedString(row["asset_pk"]) else {
      continue
    }
    let uti = stableUTI(firstNonEmpty(row["raw_uti"]))
    let path = firstNonEmpty(row["raw_path"], row["raw_path_alt"], row["raw_original_path"])
    result[assetPK] = PhotosRawResourceMetadata(uti: uti, path: path)
  }
  return result
}

private func originalUTIByAssetPK(database: SQLiteReadOnlyDatabase) throws -> [String: String] {
  guard try database.tableExists("ZINTERNALRESOURCE") else {
    return [:]
  }
  let columns = Set(try database.columns(in: "ZINTERNALRESOURCE"))
  guard columns.contains("ZASSET"), columns.contains("ZDATASTORESUBTYPE") else {
    return [:]
  }

  let utiExpression: String
  let utiJoin: String
  if columns.contains("ZCOMPACTUTI") {
    utiExpression = #"resource."ZCOMPACTUTI""#
    utiJoin = ""
  } else if columns.contains("ZUNIFORMTYPEIDENTIFIER") {
    if try database.tableExists("ZUNIFORMTYPEIDENTIFIER"),
      try database.columns(in: "ZUNIFORMTYPEIDENTIFIER").contains("ZIDENTIFIER")
    {
      utiExpression = #"COALESCE(identifier."ZIDENTIFIER", resource."ZUNIFORMTYPEIDENTIFIER")"#
      utiJoin = """
        LEFT JOIN "ZUNIFORMTYPEIDENTIFIER" AS identifier
          ON identifier."Z_PK" = resource."ZUNIFORMTYPEIDENTIFIER"
        """
    } else {
      utiExpression = #"resource."ZUNIFORMTYPEIDENTIFIER""#
      utiJoin = ""
    }
  } else {
    return [:]
  }

  var filters = [#"resource."ZDATASTORESUBTYPE" = 1"#]
  if columns.contains("ZTRASHEDSTATE") {
    filters.append(#"(resource."ZTRASHEDSTATE" IS NULL OR resource."ZTRASHEDSTATE" = 0)"#)
  }
  let rows = try database.rawRows(
    sql: """
      SELECT
        resource."ZASSET" AS "asset_pk",
        \(utiExpression) AS "original_uti"
      FROM "ZINTERNALRESOURCE" AS resource
      \(utiJoin)
      WHERE \(filters.joined(separator: " AND "))
      """
  )

  var result: [String: String] = [:]
  for row in rows {
    guard let assetPK = normalizedString(row["asset_pk"]),
      let uti = stableUTI(row["original_uti"])
    else {
      continue
    }
    result[assetPK] = uti
  }
  return result
}

private func resourceMissingStateByAssetPK(database: SQLiteReadOnlyDatabase) throws -> [String:
  Bool]
{
  guard try database.tableExists("ZINTERNALRESOURCE") else {
    return [:]
  }
  let columns = Set(try database.columns(in: "ZINTERNALRESOURCE"))
  guard columns.contains("ZASSET"),
    columns.contains("ZLOCALAVAILABILITY"),
    columns.contains("ZDATASTORESUBTYPE")
  else {
    return [:]
  }

  var filters = [#"resource."ZDATASTORESUBTYPE" IN (1, 3)"#]
  if columns.contains("ZTRASHEDSTATE") {
    filters.append(#"(resource."ZTRASHEDSTATE" IS NULL OR resource."ZTRASHEDSTATE" = 0)"#)
  }
  let rows = try database.rawRows(
    sql: """
      SELECT
        resource."ZASSET" AS "asset_pk",
        resource."ZLOCALAVAILABILITY" AS "local_availability",
        resource."ZDATASTORESUBTYPE" AS "resource_subtype"
      FROM "ZINTERNALRESOURCE" AS resource
      WHERE \(filters.joined(separator: " AND "))
      """
  )

  var states: [String: ResourceMissingState] = [:]
  for row in rows {
    guard let assetPK = normalizedString(row["asset_pk"]),
      let subtype = row["resource_subtype"].flatMap(Int.init)
    else {
      continue
    }
    let isMissing = (row["local_availability"].flatMap(Int.init) ?? 0) != 1
    var state = states[assetPK] ?? ResourceMissingState()
    if subtype == 1 {
      state.originalResourceMissing.append(isMissing)
    } else if subtype == 3 {
      state.sharedOrDerivativeResourceMissing.append(isMissing)
    }
    states[assetPK] = state
  }
  return states.mapValues(\.missing)
}

private struct ResourceMissingState {
  var originalResourceMissing: [Bool] = []
  var sharedOrDerivativeResourceMissing: [Bool] = []

  var missing: Bool {
    if !originalResourceMissing.isEmpty {
      return !originalResourceMissing.contains(false)
    }
    return !sharedOrDerivativeResourceMissing.contains(false)
  }
}

private func searchInfoLabelsByUUID(libraryPath: String) throws -> [String: [String]] {
  let searchDatabase = URL(fileURLWithPath: libraryPath)
    .appendingPathComponent("database/search/psi.sqlite")
  guard FileManager.default.fileExists(atPath: searchDatabase.path) else {
    return [:]
  }

  let snapshotURL = try copySQLiteSnapshot(searchDatabase)
  let database = try SQLiteReadOnlyDatabase(path: snapshotURL.path, libraryPath: libraryPath)
  defer { database.close() }

  guard try database.tableExists("ga"),
    try database.tableExists("groups"),
    try database.tableExists("assets")
  else {
    return [:]
  }

  let rows = try database.rawRows(
    sql: """
      SELECT
        assets."uuid_0" AS "uuid_0",
        assets."uuid_1" AS "uuid_1",
        groups."content_string" AS "label"
      FROM "ga" AS ga
      JOIN "groups" AS groups
        ON groups."rowid" = ga."groupid"
      JOIN "assets" AS assets
        ON ga."assetid" = assets."rowid"
      WHERE groups."category" IN (1500, 2024)
      """
  )

  var labelsByUUID: [String: Set<String>] = [:]
  for row in rows {
    guard let uuid = photosSearchUUID(uuid0: row["uuid_0"], uuid1: row["uuid_1"]),
      let label = normalizedString(row["label"]?.replacingOccurrences(of: "\0", with: ""))
    else {
      continue
    }
    var labels = labelsByUUID[uuid] ?? []
    labels.insert(label)
    labelsByUUID[uuid] = labels
  }
  return labelsByUUID.mapValues { $0.sorted() }
}

private func copySQLiteSnapshot(_ source: URL) throws -> URL {
  let temp = FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-sqlite-\(UUID().uuidString)", isDirectory: true)
  try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
  let destination = temp.appendingPathComponent(source.lastPathComponent)
  try FileManager.default.copyItem(at: source, to: destination)
  for suffix in ["-wal", "-shm"] {
    let sidecar = URL(fileURLWithPath: source.path + suffix)
    if FileManager.default.fileExists(atPath: sidecar.path) {
      try FileManager.default.copyItem(
        at: sidecar,
        to: URL(fileURLWithPath: destination.path + suffix)
      )
    }
  }
  return destination
}

private func photosSearchUUID(uuid0: String?, uuid1: String?) -> String? {
  guard let uuid0, let uuid1, let first = Int64(uuid0), let second = Int64(uuid1) else {
    return nil
  }
  let bytes = littleEndianBytes(first) + littleEndianBytes(second)
  guard bytes.count == 16 else {
    return nil
  }
  return UUID(
    uuid: (
      bytes[0], bytes[1], bytes[2], bytes[3],
      bytes[4], bytes[5],
      bytes[6], bytes[7],
      bytes[8], bytes[9],
      bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
    )
  ).uuidString.uppercased()
}

private func littleEndianBytes(_ value: Int64) -> [UInt8] {
  let bits = UInt64(bitPattern: value)
  return (0..<8).map { index in
    UInt8((bits >> (index * 8)) & 0xff)
  }
}

private func legacyImportGroupJoin(enabled: Bool) -> String {
  guard enabled else {
    return ""
  }
  return """
    LEFT JOIN "RKImportGroup" AS importGroup
      ON importGroup."uuid" = master."importGroupUuid"
    """
}

private func optionalColumn(
  tableAlias: String,
  column: String,
  alias: String,
  available: Set<String>
) -> String {
  if available.contains(column) {
    return #"\#(tableAlias)."\#(column)" AS "\#(alias)""#
  }
  return #"NULL AS "\#(alias)""#
}

private func firstAvailableColumn(_ candidates: [String], in available: Set<String>) -> String? {
  candidates.first { candidate in
    available.contains(candidate)
  }
}

private func adjustmentFormatIdentifierSelect(
  database: SQLiteReadOnlyDatabase,
  additionalColumns: Set<String>
) throws -> String {
  guard additionalColumns.contains("ZUNMANAGEDADJUSTMENT"),
    try database.tableExists("ZUNMANAGEDADJUSTMENT"),
    try database.columns(in: "ZUNMANAGEDADJUSTMENT").contains("ZADJUSTMENTFORMATIDENTIFIER")
  else {
    return #"NULL AS "ZADJUSTMENTFORMATIDENTIFIER""#
  }
  return #"adjustment."ZADJUSTMENTFORMATIDENTIFIER" AS "ZADJUSTMENTFORMATIDENTIFIER""#
}

private func assetDescriptionSelect(
  database: SQLiteReadOnlyDatabase,
  additionalColumns: Set<String>
) throws -> String {
  guard additionalColumns.contains("ZASSETDESCRIPTION"),
    try database.tableExists("ZASSETDESCRIPTION"),
    try database.columns(in: "ZASSETDESCRIPTION").contains("ZLONGDESCRIPTION")
  else {
    return #"NULL AS "ZLONGDESCRIPTION""#
  }
  return #"assetDescription."ZLONGDESCRIPTION" AS "ZLONGDESCRIPTION""#
}

private func reverseLocationDataHexSelect(additionalColumns: Set<String>) -> String {
  guard additionalColumns.contains("ZREVERSELOCATIONDATA") else {
    return #"NULL AS "ZREVERSELOCATIONDATAHEX""#
  }
  return #"hex(additional."ZREVERSELOCATIONDATA") AS "ZREVERSELOCATIONDATAHEX""#
}

private func assetDescriptionJoin(
  database: SQLiteReadOnlyDatabase,
  additionalColumns: Set<String>
) throws -> String {
  guard additionalColumns.contains("ZASSETDESCRIPTION"),
    try database.tableExists("ZASSETDESCRIPTION"),
    try database.columns(in: "ZASSETDESCRIPTION").contains("ZLONGDESCRIPTION")
  else {
    return ""
  }
  return """
    LEFT JOIN "ZASSETDESCRIPTION" AS assetDescription
      ON assetDescription."Z_PK" = additional."ZASSETDESCRIPTION"
    """
}

private func adjustmentJoin(
  database: SQLiteReadOnlyDatabase,
  additionalColumns: Set<String>
) throws -> String {
  guard additionalColumns.contains("ZUNMANAGEDADJUSTMENT"),
    try database.tableExists("ZUNMANAGEDADJUSTMENT"),
    try database.columns(in: "ZUNMANAGEDADJUSTMENT").contains("ZADJUSTMENTFORMATIDENTIFIER")
  else {
    return ""
  }
  return """
    LEFT JOIN "ZUNMANAGEDADJUSTMENT" AS adjustment
      ON adjustment."Z_PK" = additional."ZUNMANAGEDADJUSTMENT"
    """
}

private func isTrashedAsset(_ row: [String: String], hasTrashedState: Bool) -> Bool {
  hasTrashedState && (row["ZTRASHEDSTATE"].flatMap(Int.init) ?? 0) != 0
}

func photosApplyQuery(query: PhotosQuery, to items: [PhotosMediaItemRecord])
  -> [PhotosMediaItemRecord]
{
  var filtered = items.filter { item in
    matches(item, query: query)
  }

  if let duplicate = query.duplicate {
    let duplicateKeys = Dictionary(grouping: filtered, by: duplicateKey)
      .filter { key, values in !key.isEmpty && values.count > 1 }
      .map(\.key)
    filtered = filtered.filter { item in
      duplicate
        ? duplicateKeys.contains(duplicateKey(item)) : !duplicateKeys.contains(duplicateKey(item))
    }
  }

  filtered = photosSortedForQuery(filtered, newestFirst: query.newestFirst)

  if let limit = query.limit, filtered.count > limit {
    filtered = Array(filtered.prefix(limit))
  }

  return filtered
}

private func photosSortedForQuery(
  _ items: [PhotosMediaItemRecord],
  newestFirst: Bool
) -> [PhotosMediaItemRecord] {
  items.sorted { left, right in
    let leftDate = left.date ?? photosDefaultSortDate
    let rightDate = right.date ?? photosDefaultSortDate
    if leftDate != rightDate {
      return newestFirst ? leftDate > rightDate : leftDate < rightDate
    }

    let leftAdded = left.dateAdded ?? photosDefaultSortDate
    let rightAdded = right.dateAdded ?? photosDefaultSortDate
    if leftAdded != rightAdded {
      return newestFirst ? leftAdded > rightAdded : leftAdded < rightAdded
    }

    return newestFirst ? left.uuid > right.uuid : left.uuid < right.uuid
  }
}

private let photosDefaultSortDate = Date(timeIntervalSince1970: 0)
private let photosUnknownPlaceName = "_UNKNOWN_"

private func photosMetadataAggregate(counts: [String: Int]) -> PhotosMetadataAggregate {
  let values = counts.sorted { left, right in
    if left.value != right.value {
      return left.value > right.value
    }
    return left.key.localizedStandardCompare(right.key) == .orderedAscending
  }
  .map(\.key)
  return PhotosMetadataAggregate(values: values, counts: counts)
}

private func photosCounts(from values: [String]) -> [String: Int] {
  var counts: [String: Int] = [:]
  for value in values where !value.isEmpty {
    counts[value, default: 0] += 1
  }
  return counts
}

private func photosMetadataQueryIsUnfiltered(_ query: PhotosQuery) -> Bool {
  query.albums.isEmpty
    && query.folders.isEmpty
    && query.uuids.isEmpty
    && query.keywords.isEmpty
    && query.persons.isEmpty
    && query.titles.isEmpty
    && query.descriptions.isEmpty
    && !query.noKeyword
    && !query.noTitle
    && !query.noDescription
    && query.filenames.isEmpty
    && query.originalPath == nil
    && query.places.isEmpty
    && !query.noPlace
    && query.location == nil
    && query.hasLocation == nil
    && query.label == nil
    && query.regex == nil
    && query.regexFields.isEmpty
    && query.uti == nil
    && query.mediaType == nil
    && query.dateFrom == nil
    && query.dateTo == nil
    && query.years.isEmpty
    && query.timeFrom == nil
    && query.timeTo == nil
    && query.dateAddedFrom == nil
    && query.dateAddedTo == nil
    && query.addedAfter == nil
    && query.addedBefore == nil
    && query.addedInLast == nil
    && query.minSize == nil
    && query.maxSize == nil
    && query.traits.isEmpty
    && query.excludedTraits.isEmpty
    && query.favorite == nil
    && query.hidden == nil
    && query.shared == nil
    && query.iCloud == nil
    && query.inCloud == nil
    && query.syndicated == nil
    && query.savedToLibrary == nil
    && query.sharedMoment == nil
    && query.sharedLibrary == nil
    && query.hasComment == nil
    && query.hasLikes == nil
    && query.inAlbum == nil
    && query.edited == nil
    && query.externalEdit == nil
    && query.duplicate == nil
    && query.missing == nil
    && query.exif.isEmpty
    && !query.selected
}

private func matches(_ item: PhotosMediaItemRecord, query: PhotosQuery) -> Bool {
  if !query.uuids.isEmpty, !query.uuids.contains(item.uuid) {
    return false
  }
  if !query.albums.isEmpty,
    !photosMatchesAnyAlbumSelector(
      item: item, selectors: query.albums, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if !query.folders.isEmpty,
    !photosMatchesAnyFolderSelector(
      item: item, selectors: query.folders, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if !query.keywords.isEmpty,
    !photosListContainsAny(item.keywords, query.keywords, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if query.noKeyword, !item.keywords.isEmpty {
    return false
  }
  if !query.persons.isEmpty,
    !photosListContainsAny(item.persons, query.persons, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if !query.titles.isEmpty,
    !photosContainsAny(item.title ?? "", query.titles, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if query.noTitle, !(item.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
    return false
  }
  if !query.descriptions.isEmpty,
    !photosContainsAny(item.description ?? "", query.descriptions, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if query.noDescription,
    !(item.description?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
  {
    return false
  }
  if !query.filenames.isEmpty,
    !photosContainsAny(item.filename, query.filenames, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if let originalPath = query.originalPath,
    !photosContains(item.originalPath ?? "", originalPath, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if let uti = query.uti,
    !photosContains(item.originalUTI ?? item.uti ?? "", uti, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if let mediaType = query.mediaType, item.mediaType != mediaType {
    return false
  }
  if !query.places.isEmpty,
    !query.places.allSatisfy({ needle in
      photosPlaceValues(for: item).contains { value in
        photosContains(value, needle, ignoreCase: query.ignoreCase)
      }
    })
  {
    return false
  }
  if query.noPlace, item.hasPlace {
    return false
  }
  if let location = query.location,
    !photosContains(
      item.location.map { "\($0.latitude),\($0.longitude)" } ?? "",
      location,
      ignoreCase: query.ignoreCase
    )
  {
    return false
  }
  if let hasLocation = query.hasLocation, (item.location != nil) != hasLocation {
    return false
  }
  if let label = query.label,
    !photosListContainsAny(item.labels, [label], ignoreCase: query.ignoreCase)
  {
    return false
  }
  if let regex = query.regex,
    !matchesRegex(item, pattern: regex, fields: query.regexFields, ignoreCase: query.ignoreCase)
  {
    return false
  }
  if let dateFrom = query.dateFrom, let minimum = queryDate(dateFrom),
    item.date.map({ $0 < minimum }) ?? true
  {
    return false
  }
  if let dateTo = query.dateTo, let maximum = queryDate(dateTo),
    item.date.map({ $0 >= maximum }) ?? true
  {
    return false
  }
  if !query.years.isEmpty {
    guard let date = item.date,
      query.years.contains(calendarYear(for: date, offsetSeconds: item.timeZoneOffsetSeconds))
    else {
      return false
    }
  }
  if query.timeFrom != nil || query.timeTo != nil {
    guard let date = item.date,
      matchesTimeOfDay(
        date,
        offsetSeconds: item.timeZoneOffsetSeconds,
        from: query.timeFrom,
        to: query.timeTo
      )
    else {
      return false
    }
  }
  if let dateAddedFrom = query.dateAddedFrom, let minimum = queryDate(dateAddedFrom),
    item.dateAdded.map({ $0 < minimum }) ?? true
  {
    return false
  }
  if let dateAddedTo = query.dateAddedTo, let maximum = queryDate(dateAddedTo),
    item.dateAdded.map({ $0 >= maximum }) ?? true
  {
    return false
  }
  if let addedAfter = query.addedAfter, let minimum = queryDate(addedAfter),
    item.dateAdded.map({ $0 <= minimum }) ?? true
  {
    return false
  }
  if let addedBefore = query.addedBefore, let maximum = queryDate(addedBefore),
    item.dateAdded.map({ $0 >= maximum }) ?? true
  {
    return false
  }
  if let addedInLast = query.addedInLast,
    let seconds = photosTimeInterval(from: addedInLast)
  {
    let minimum = Date().addingTimeInterval(-seconds)
    if item.dateAdded.map({ $0 <= minimum }) ?? true {
      return false
    }
  }
  if let favorite = query.favorite, item.favorite != favorite {
    return false
  }
  if let hidden = query.hidden, item.hidden != hidden {
    return false
  }
  if let shared = query.shared, (item.shared ?? false) != shared {
    return false
  }
  if let iCloud = query.iCloud, (item.iCloud ?? false) != iCloud {
    return false
  }
  if let inCloud = query.inCloud,
    !photosMatchesInCloud(item, expected: inCloud)
  {
    return false
  }
  if let syndicated = query.syndicated, (item.syndicated ?? false) != syndicated {
    return false
  }
  if let savedToLibrary = query.savedToLibrary,
    !photosMatchesSavedToLibrary(item, expected: savedToLibrary)
  {
    return false
  }
  if let sharedMoment = query.sharedMoment, (item.sharedMoment ?? false) != sharedMoment {
    return false
  }
  if let sharedLibrary = query.sharedLibrary, (item.sharedLibrary ?? false) != sharedLibrary {
    return false
  }
  if let hasComment = query.hasComment, (!item.comments.isEmpty) != hasComment {
    return false
  }
  if let hasLikes = query.hasLikes, (!item.likes.isEmpty) != hasLikes {
    return false
  }
  if let inAlbum = query.inAlbum, item.albumIDs.isEmpty == inAlbum {
    return false
  }
  if let edited = query.edited, item.edited != edited {
    return false
  }
  if let externalEdit = query.externalEdit, item.externalEdit != externalEdit {
    return false
  }
  if let missing = query.missing {
    let missingState = photosItemMissing(item)
    if missingState != missing {
      return false
    }
  }
  if let minSize = query.minSize, item.fileSize.map({ $0 < minSize }) ?? true {
    return false
  }
  if let maxSize = query.maxSize, item.fileSize.map({ $0 > maxSize }) ?? true {
    return false
  }
  let itemTraits = Set(item.traits)
  if query.traits.contains(where: { !itemTraits.contains($0) }) {
    return false
  }
  if query.excludedTraits.contains(where: { itemTraits.contains($0) }) {
    return false
  }
  if !query.exif.isEmpty,
    !query.exif.contains(where: {
      photosExifMatches(item: item, predicate: $0, ignoreCase: query.ignoreCase)
    })
  {
    return false
  }
  return true
}

private func photosExifMatches(
  item: PhotosMediaItemRecord,
  predicate: PhotosExifPredicate,
  ignoreCase: Bool
) -> Bool {
  let values = photosExifLookupValues(for: item, tag: predicate.tag)
  guard !values.isEmpty else {
    return false
  }
  if ignoreCase {
    let needle = predicate.value.lowercased()
    return values.contains { value in
      value.lowercased().contains(needle)
    }
  }
  return values.contains { value in
    value.contains(predicate.value)
  }
}

private func photosExifLookupValues(for item: PhotosMediaItemRecord, tag: String) -> [String] {
  let aliases = photosExifAliases(for: tag)
  return aliases.compactMap { alias in
    item.exif[alias]
  }
}

private func photosExifAliases(for tag: String) -> [String] {
  let normalized = photosNormalizeExifTag(tag)
  let groupedName = normalized.split(separator: ":").last.map(String.init) ?? normalized
  let known: [String: [String]] = [
    "make": ["camera_make"],
    "model": ["camera_model"],
    "lensmodel": ["lens_model"],
    "lens_model": ["lens_model"],
    "iso": ["iso"],
    "flashfired": ["flash_fired"],
    "flash_fired": ["flash_fired"],
    "meteringmode": ["metering_mode"],
    "metering_mode": ["metering_mode"],
    "samplerate": ["sample_rate"],
    "sample_rate": ["sample_rate"],
    "trackformat": ["track_format"],
    "track_format": ["track_format"],
    "whitebalance": ["white_balance"],
    "white_balance": ["white_balance"],
    "aperture": ["aperture"],
    "fnumber": ["aperture"],
    "bitrate": ["bit_rate"],
    "bit_rate": ["bit_rate"],
    "duration": ["duration"],
    "exposurebias": ["exposure_bias"],
    "exposure_bias": ["exposure_bias"],
    "focallength": ["focal_length"],
    "focal_length": ["focal_length"],
    "fps": ["fps"],
    "latitude": ["latitude"],
    "longitude": ["longitude"],
    "shutterspeed": ["shutter_speed"],
    "shutter_speed": ["shutter_speed"],
    "codec": ["codec"],
    "datecreated": ["date_created"],
    "date_created": ["date_created"],
    "timezoneoffset": ["timezone_offset"],
    "timezone_offset": ["timezone_offset"],
    "timezonename": ["timezone_name"],
    "timezone_name": ["timezone_name"],
  ]
  var aliases = [normalized, groupedName]
  if let mapped = known[groupedName] {
    aliases.append(contentsOf: mapped)
  }
  if let mapped = known[normalized] {
    aliases.append(contentsOf: mapped)
  }
  var seen: Set<String> = []
  return aliases.filter { alias in
    guard !seen.contains(alias) else {
      return false
    }
    seen.insert(alias)
    return true
  }
}

private func photosNormalizeExifTag(_ tag: String) -> String {
  tag.trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
    .replacingOccurrences(of: " ", with: "")
    .replacingOccurrences(of: "-", with: "_")
}

private func photosMatchesInCloud(_ item: PhotosMediaItemRecord, expected: Bool) -> Bool {
  let inCloud = item.inCloud ?? false
  let shared = item.shared ?? false
  return expected ? (inCloud && !shared) : (!inCloud && !shared)
}

private func photosCountsAsPhotosAppTotal(_ item: PhotosMediaItemRecord) -> Bool {
  !(item.shared ?? false)
    && !(item.sharedMoment ?? false)
    && !item.hidden
    && !((item.syndicated ?? false) && item.savedToLibrary != true)
}

private func photosMatchesSavedToLibrary(_ item: PhotosMediaItemRecord, expected: Bool) -> Bool {
  guard item.syndicated == true else {
    return false
  }
  let saved = item.savedToLibrary ?? false
  return expected ? saved : !saved
}

private func photosItemMissing(_ item: PhotosMediaItemRecord) -> Bool {
  if item.missingState == true {
    return true
  }
  guard let originalPath = item.originalPath else {
    return true
  }
  return !FileManager.default.fileExists(atPath: originalPath)
}

private func duplicateKey(_ item: PhotosMediaItemRecord) -> String {
  [
    item.fileSize.map(String.init) ?? "<nil>",
    item.date.map(photosDuplicateDateComponent) ?? "<nil>",
    item.height.map(String.init) ?? "<nil>",
    item.width.map(String.init) ?? "<nil>",
    item.uti ?? "<nil>",
    item.edited ? "1" : "0",
  ].joined(separator: internalListSeparator)
}

private func photosDuplicateDateComponent(_ date: Date) -> String {
  String(format: "%.6f", date.timeIntervalSinceReferenceDate)
}

private func photosInCloudState(from row: [String: String]) -> Bool? {
  if let explicit = row["ZINCLOUD"] {
    return bool(from: explicit)
  }
  guard let localState = intValue(row["ZCLOUDLOCALSTATE"]) else {
    return nil
  }
  return localState == 3
}

private func photosSyndicationSavedState(from row: [String: String]) -> Bool? {
  guard nonEmpty(row["ZSYNDICATIONIDENTIFIER"]) == true else {
    return nil
  }
  return truthyDatabaseValue(row["ZSYNDICATIONHISTORY"])
}

private func truthyDatabaseValue(_ value: String?) -> Bool? {
  guard let value, !value.isEmpty else {
    return nil
  }
  if let integer = Int(value) {
    return integer != 0
  }
  return true
}

private func nonEmpty(_ value: String?) -> Bool? {
  guard let value else {
    return nil
  }
  return !value.isEmpty
}

private func queryDate(_ value: String) -> Date? {
  if let date = ISO8601DateFormatter().date(from: value) {
    return date
  }
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter.date(from: value)
}

private func calendarYear(for date: Date, offsetSeconds: Int?) -> Int {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar.component(.year, from: date.addingTimeInterval(TimeInterval(offsetSeconds ?? 0)))
}

private func matchesTimeOfDay(
  _ date: Date,
  offsetSeconds: Int?,
  from fromValue: String?,
  to toValue: String?
) -> Bool {
  let seconds = secondsSinceStartOfDay(
    date.addingTimeInterval(TimeInterval(offsetSeconds ?? 0))
  )
  let from = fromValue.flatMap(parseTimeOfDay)
  let to = toValue.flatMap(parseTimeOfDay)
  switch (from, to) {
  case (let from?, let to?):
    if from <= to {
      return seconds >= from && seconds < to
    }
    return seconds >= from || seconds < to
  case (let from?, nil):
    return seconds >= from
  case (nil, let to?):
    return seconds < to
  case (nil, nil):
    return true
  }
}

private func matchesRegex(
  _ item: PhotosMediaItemRecord,
  pattern: String,
  fields: [String],
  ignoreCase: Bool
) -> Bool {
  guard
    let expression = try? NSRegularExpression(
      pattern: pattern,
      options: ignoreCase ? [.caseInsensitive] : []
    )
  else {
    return false
  }
  let requestedFields =
    fields.isEmpty
    ? [
      "uuid", "filename", "title", "description", "keyword", "person", "album", "folder",
      "media-type", "uti", "trait",
    ]
    : fields
  return regexValues(item, fields: requestedFields).contains { value in
    let range = NSRange(value.startIndex..<value.endIndex, in: value)
    return expression.firstMatch(in: value, range: range) != nil
  }
}

private func photosContains(_ value: String, _ needle: String, ignoreCase: Bool) -> Bool {
  ignoreCase ? value.localizedCaseInsensitiveContains(needle) : value.contains(needle)
}

private func photosContainsAny(_ value: String, _ needles: [String], ignoreCase: Bool) -> Bool {
  needles.contains { photosContains(value, $0, ignoreCase: ignoreCase) }
}

private func photosListContainsAny(_ values: [String], _ needles: [String], ignoreCase: Bool)
  -> Bool
{
  values.contains { value in
    needles.contains { needle in
      ignoreCase ? value.localizedCaseInsensitiveCompare(needle) == .orderedSame : value == needle
    }
  }
}

private func photosMatchesAnyAlbumSelector(
  item: PhotosMediaItemRecord,
  selectors: [String],
  ignoreCase: Bool
) -> Bool {
  selectors.contains { selector in
    photosMatchesAlbumSelector(item: item, selector: selector, ignoreCase: ignoreCase)
  }
}

private func photosMatchesAlbumSelector(
  item: PhotosMediaItemRecord,
  selector: String,
  ignoreCase: Bool
) -> Bool {
  let components = photosPathSelectorComponents(selector)
  guard components.count > 1 else {
    let value = components.first ?? selector
    return photosListContainsAny(item.albumPaths, [value], ignoreCase: ignoreCase)
      || photosMatchesAlbumIdentifierSelector(item: item, selector: value, ignoreCase: ignoreCase)
  }

  let albumPath = components.joined(separator: "/")
  return photosListPathContainsAny(item.albumPaths, [albumPath], ignoreCase: ignoreCase)
}

private func photosMatchesAlbumIdentifierSelector(
  item: PhotosMediaItemRecord,
  selector: String,
  ignoreCase: Bool
) -> Bool {
  guard photosListContainsAny(item.albumIDs, [selector], ignoreCase: ignoreCase) else {
    return false
  }
  return !item.albumPaths.contains { path in
    let basename = photosPathSelectorComponents(path).last ?? path
    return ignoreCase
      ? basename.localizedCaseInsensitiveCompare(selector) == .orderedSame : basename == selector
  }
}

private func photosMatchesAnyFolderSelector(
  item: PhotosMediaItemRecord,
  selectors: [String],
  ignoreCase: Bool
) -> Bool {
  selectors.contains { selector in
    let folderPath = photosPathSelectorComponents(selector).joined(separator: "/")
    return photosListPathContainsAny(item.folderPaths, [folderPath], ignoreCase: ignoreCase)
  }
}

private func photosListPathContainsAny(_ values: [String], _ needles: [String], ignoreCase: Bool)
  -> Bool
{
  values.contains { value in
    needles.contains { needle in
      if ignoreCase {
        return value.localizedCaseInsensitiveCompare(needle) == .orderedSame
          || value.localizedCaseInsensitiveContains(needle)
      }
      return value == needle || value.contains(needle)
    }
  }
}

private func photosPathSelectorComponents(_ selector: String) -> [String] {
  var components: [String] = []
  var current = ""
  var index = selector.startIndex

  while index < selector.endIndex {
    let character = selector[index]
    if character == "/" {
      let next = selector.index(after: index)
      if next < selector.endIndex, selector[next] == "/" {
        current.append("/")
        index = selector.index(after: next)
      } else {
        components.append(current)
        current = ""
        index = next
      }
    } else {
      current.append(character)
      index = selector.index(after: index)
    }
  }

  components.append(current)
  return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
}

private func photosPlaceValues(for item: PhotosMediaItemRecord) -> [String] {
  var values = item.placeNames
  if let placeName = item.placeName, !placeName.isEmpty {
    values.append(placeName)
  }
  return values.filter { !$0.isEmpty }
}

private func regexValues(_ item: PhotosMediaItemRecord, fields: [String]) -> [String] {
  var values: [String] = []
  for field in fields {
    switch field {
    case "uuid":
      values.append(item.uuid)
    case "filename":
      values.append(item.filename)
    case "title":
      values.append(item.title ?? "")
    case "description":
      values.append(item.description ?? "")
    case "keyword":
      values.append(contentsOf: item.keywords)
    case "person":
      values.append(contentsOf: item.persons)
    case "album":
      values.append(contentsOf: item.albumIDs)
    case "folder":
      values.append(contentsOf: item.folderPaths)
    case "media-type":
      values.append(item.mediaType)
    case "uti":
      values.append(item.originalUTI ?? item.uti ?? "")
    case "trait":
      values.append(contentsOf: item.traits)
    default:
      continue
    }
  }
  return values.filter { !$0.isEmpty }
}

private func secondsSinceStartOfDay(_ date: Date) -> Int {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  let components = calendar.dateComponents([.hour, .minute, .second], from: date)
  return (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
}

private func parseTimeOfDay(_ value: String) -> Int? {
  let parts = value.split(separator: ":").compactMap { Int($0) }
  guard parts.count == 2 || parts.count == 3 else {
    return nil
  }
  let hour = parts[0]
  let minute = parts[1]
  let second = parts.count == 3 ? parts[2] : 0
  guard (0..<24).contains(hour), (0..<60).contains(minute), (0..<60).contains(second) else {
    return nil
  }
  return hour * 3600 + minute * 60 + second
}

private func validateRawReadOnlySQL(_ sql: String) throws {
  let lowered = sql.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  guard lowered.hasPrefix("select") || lowered.hasPrefix("with") || lowered.hasPrefix("pragma")
  else {
    throw CLIError(code: .validationError, message: "Raw SQL diagnostics are read-only.")
  }
  let forbidden = [
    "insert ", "update ", "delete ", "drop ", "alter ", "attach ", "detach ", "vacuum", "replace ",
  ]
  if forbidden.contains(where: { lowered.contains($0) }) {
    throw CLIError(
      code: .validationError, message: "Raw SQL diagnostics cannot mutate or attach databases.")
  }
}

private func mediaType(from row: [String: String]) -> String {
  if let value = row["ZKIND"].flatMap(Int.init) {
    return value == 1 ? "video" : "image"
  }
  return row["media_type"] ?? "image"
}

private func photosPreviewPaths(
  uuid: String,
  libraryPath: String,
  mediaType: String,
  shared: Bool,
  sharedMoment: Bool,
  syndicated: Bool,
  savedToLibrary: Bool?
) -> [String] {
  guard let directory = uuid.first.map(String.init) else {
    return []
  }
  let library = URL(fileURLWithPath: libraryPath)
  var candidates: [URL] = []

  if shared {
    candidates += [
      library
        .appendingPathComponent("resources/cloudsharing/resources/derivatives/masters")
        .appendingPathComponent(directory)
        .appendingPathComponent("\(uuid)_4_5005_c.jpeg"),
      library
        .appendingPathComponent("scopes/cloudsharing/resources/derivatives/masters")
        .appendingPathComponent(directory)
        .appendingPathComponent("\(uuid)_4_5005_c.jpeg"),
    ]
  }

  if sharedMoment {
    candidates.append(
      library
        .appendingPathComponent("scopes/momentshared/resources/derivatives/masters")
        .appendingPathComponent(directory)
        .appendingPathComponent("\(uuid)_4_5005_c.jpeg")
    )
  } else if syndicated && savedToLibrary != true {
    candidates.append(
      library
        .appendingPathComponent("scopes/syndication/resources/derivatives/masters")
        .appendingPathComponent(directory)
        .appendingPathComponent("\(uuid)_4_5005_c.jpeg")
    )
  }

  candidates += photosFilesByPrefix(
    in: library.appendingPathComponent("resources/derivatives").appendingPathComponent(directory),
    prefix: uuid,
    ignoredExtension: "thm"
  )
  candidates.append(
    library
      .appendingPathComponent("resources/derivatives/masters")
      .appendingPathComponent(directory)
      .appendingPathComponent("\(uuid)_4_5005_c.jpeg")
  )

  var paths: [String] = []
  var seen = Set<String>()
  for candidate in candidates {
    guard FileManager.default.fileExists(atPath: candidate.path),
      seen.insert(candidate.path).inserted
    else {
      continue
    }
    paths.append(candidate.path)
  }

  paths.sort { lhs, rhs in
    let lhsSize = photosFileSize(lhs)
    let rhsSize = photosFileSize(rhs)
    if lhsSize == rhsSize {
      return lhs < rhs
    }
    return lhsSize > rhsSize
  }

  if mediaType == "image", paths.count > 1, photosPathHasMovieExtension(paths[0]) {
    paths.swapAt(0, 1)
  }
  return paths
}

private func photosFilesByPrefix(
  in directory: URL,
  prefix: String,
  ignoredExtension: String
) -> [URL] {
  guard
    let entries = try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
      options: [.skipsHiddenFiles]
    )
  else {
    return []
  }

  return entries.filter { url in
    guard url.lastPathComponent.hasPrefix(prefix),
      url.pathExtension.lowercased() != ignoredExtension
    else {
      return false
    }
    let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
    return values?.isRegularFile == true
  }
}

private func photosFileSize(_ path: String) -> Int64 {
  let attributes = try? FileManager.default.attributesOfItem(atPath: path)
  return (attributes?[.size] as? NSNumber)?.int64Value ?? 0
}

private func photosPathHasMovieExtension(_ path: String) -> Bool {
  ["mov", "mp4", "m4v"].contains(URL(fileURLWithPath: path).pathExtension.lowercased())
}

private func photosEditedRenderPath(
  uuid: String,
  libraryPath: String,
  mediaType: String,
  uti: String?,
  edited: Bool
) -> String? {
  guard edited, let directory = uuid.first.map(String.init) else {
    return nil
  }
  let renderDirectory = URL(fileURLWithPath: libraryPath)
    .appendingPathComponent("resources/renders")
    .appendingPathComponent(directory)
  let candidates: [String]
  if mediaType == "video" {
    candidates = ["\(uuid)_2_0_a.mov"]
  } else if uti == "public.heic" {
    candidates = [
      "\(uuid)_1_201_a.heic",
      "\(uuid)_1_201_a.jpeg",
      "\(uuid)_1_201_a.jpg",
    ]
  } else {
    candidates = [
      "\(uuid)_1_201_a.jpeg",
      "\(uuid)_1_201_a.jpg",
      "\(uuid)_1_201_a.heic",
      "\(uuid)_1_201_a.png",
      "\(uuid)_1_201_a.tif",
      "\(uuid)_1_201_a.tiff",
    ]
  }
  return
    candidates
    .map { renderDirectory.appendingPathComponent($0).path }
    .first { FileManager.default.fileExists(atPath: $0) }
}

private func photosLivePhotoMoviePath(
  uuid: String,
  filename: String,
  originalPath: String?,
  libraryPath: String,
  shared: Bool,
  sharedMoment: Bool,
  syndicated: Bool,
  savedToLibrary: Bool?,
  live: Bool,
  missing: Bool?
) -> String? {
  guard live, missing != true else {
    return nil
  }

  var candidates: [URL] = []
  if let originalPath {
    let originalURL = URL(fileURLWithPath: originalPath)
    let originalDirectory = originalURL.deletingLastPathComponent()
    let originalStem = originalURL.deletingPathExtension().lastPathComponent
    if shared {
      candidates.append(originalURL.deletingPathExtension().appendingPathExtension("MOV"))
      candidates.append(originalURL.deletingPathExtension().appendingPathExtension("mov"))
    }
    candidates.append(originalDirectory.appendingPathComponent("\(originalStem)_3.mov"))
    candidates.append(originalDirectory.appendingPathComponent("\(originalStem)_3.MOV"))
  }

  guard let directory = uuid.first.map(String.init) else {
    return candidates.first { FileManager.default.fileExists(atPath: $0.path) }?.path
  }

  let library = URL(fileURLWithPath: libraryPath)
  let currentStem = URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent
  candidates.append(
    library
      .appendingPathComponent("originals")
      .appendingPathComponent(directory)
      .appendingPathComponent("\(uuid)_3.mov")
  )
  candidates.append(
    library
      .appendingPathComponent("originals")
      .appendingPathComponent(directory)
      .appendingPathComponent("\(uuid)_3.MOV")
  )

  if syndicated && savedToLibrary != true {
    candidates.append(
      library
        .appendingPathComponent("scopes/syndication/originals")
        .appendingPathComponent(directory)
        .appendingPathComponent("\(currentStem)_3.mov")
    )
  }
  if sharedMoment {
    candidates.append(
      library
        .appendingPathComponent("scopes/momentshared/originals")
        .appendingPathComponent(directory)
        .appendingPathComponent("\(currentStem)_3.mov")
    )
  }

  return candidates.first { FileManager.default.fileExists(atPath: $0.path) }?.path
}

private func photosEditedLivePhotoMoviePath(
  uuid: String,
  libraryPath: String,
  live: Bool,
  edited: Bool
) -> String? {
  guard live, edited, let directory = uuid.first.map(String.init) else {
    return nil
  }
  let renderDirectory = URL(fileURLWithPath: libraryPath)
    .appendingPathComponent("resources/renders")
    .appendingPathComponent(directory)
  let candidates = [
    "\(uuid)_2_100_a.mov",
    "\(uuid)_2_100_a.MOV",
  ]
  return
    candidates
    .map { renderDirectory.appendingPathComponent($0).path }
    .first { FileManager.default.fileExists(atPath: $0) }
}

private func photosAdjustmentPath(uuid: String, libraryPath: String, edited: Bool) -> String? {
  guard edited, let directory = uuid.first.map(String.init) else {
    return nil
  }
  let path = URL(fileURLWithPath: libraryPath)
    .appendingPathComponent("resources/renders")
    .appendingPathComponent(directory)
    .appendingPathComponent("\(uuid).plist")
    .path
  return FileManager.default.fileExists(atPath: path) ? path : nil
}

private func photosOriginalAdjustmentPath(uuid: String, libraryPath: String) -> String? {
  guard let directory = uuid.first.map(String.init) else {
    return nil
  }
  let candidates = [
    URL(fileURLWithPath: libraryPath)
      .appendingPathComponent("originals")
      .appendingPathComponent(directory)
      .appendingPathComponent("\(uuid)_5.aae"),
    URL(fileURLWithPath: libraryPath)
      .appendingPathComponent("originals")
      .appendingPathComponent(directory)
      .appendingPathComponent("\(uuid)_5.AAE"),
  ]
  return candidates.first { FileManager.default.fileExists(atPath: $0.path) }?.path
}

private func photosOriginalUTI(
  from row: [String: String],
  filename: String,
  originalPath: String?,
  currentUTI: String?
) -> String? {
  photosUTIForFilename(filename)
    ?? originalPath.flatMap(photosUTIForFilename)
    ?? stableUTI(row["ZORIGINALUTI"])
    ?? stableUTI(currentUTI)
}

private func photosRawPath(from row: [String: String], originalPath: String?) -> String? {
  guard photosHasRawResource(row), bool(from: row["ZMISSING"]) == false else {
    return nil
  }
  if let explicit = firstNonEmpty(row["ZRAWPATH"], row["raw_path"]) {
    let expanded = NSString(string: explicit).expandingTildeInPath
    if expanded.hasPrefix("/"), FileManager.default.fileExists(atPath: expanded) {
      return expanded
    }
    if let originalPath {
      let candidate = URL(fileURLWithPath: originalPath)
        .deletingLastPathComponent()
        .appendingPathComponent(expanded)
      if FileManager.default.fileExists(atPath: candidate.path) {
        return candidate.path
      }
    }
  }
  guard let originalPath else {
    return nil
  }
  let originalURL = URL(fileURLWithPath: originalPath)
  let directory = originalURL.deletingLastPathComponent()
  let stem = originalURL.deletingPathExtension().lastPathComponent
  guard
    let entries = try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles]
    )
  else {
    return nil
  }
  let rawExtensions = photosRawExtensions(rawUTI: firstNonEmpty(row["ZRAWUTI"], row["UTI_raw"]))
  let matchingURL = entries.sorted { $0.lastPathComponent < $1.lastPathComponent }.first { url in
    let name = url.deletingPathExtension().lastPathComponent
    let ext = url.pathExtension.lowercased()
    guard rawExtensions.contains(ext) else {
      return false
    }
    return name == stem || name.hasPrefix("\(stem)_4")
  }
  return matchingURL?.path
}

private func photosRawUTI(from row: [String: String], rawPath: String?) -> String? {
  if let rawUTI = stableUTI(firstNonEmpty(row["ZRAWUTI"], row["UTI_raw"])) {
    return rawUTI
  }
  if let rawPath {
    return photosUTIForFilename(rawPath)
  }
  return nil
}

private func photosRawOriginalState(from row: [String: String]) -> Bool? {
  guard photosHasRawResource(row) else {
    return nil
  }
  return intValue(row["ZORIGINALRESOURCECHOICE"]) == 1
}

private func photosHasRawResource(_ row: [String: String]) -> Bool {
  bool(from: row["ZHASRAW"]) || intValue(row["ZORIGINALRESOURCECHOICE"]) == 1
}

private func photosRawExtensions(rawUTI: String?) -> Set<String> {
  var values: Set<String> = [
    "3fr", "arw", "cr2", "cr3", "dcr", "dng", "erf", "fff", "iiq", "k25", "kdc",
    "mef", "mos", "mrw", "nef", "nrw", "orf", "pef", "raf", "raw", "rw2", "rwl",
    "sr2", "srf", "srw", "x3f",
  ]
  if let rawUTI,
    let type = UTType(rawUTI),
    let preferredExtension = type.preferredFilenameExtension
  {
    values.insert(preferredExtension.lowercased())
  }
  return values
}

private func photosUTIForFilename(_ filename: String) -> String? {
  let pathExtension = URL(fileURLWithPath: filename).pathExtension
  guard !pathExtension.isEmpty else {
    return nil
  }
  let normalizedExtension = pathExtension.lowercased()
  if let known = photosKnownExtensionUTIs[normalizedExtension] {
    return known
  }
  return stableUTI(UTType(filenameExtension: normalizedExtension)?.identifier)
}

private let photosKnownExtensionUTIs: [String: String] = [
  "arw": "com.sony.arw-raw-image",
  "cr2": "com.canon.cr2-raw-image",
  "dng": "com.adobe.raw-image",
  "gif": "com.compuserve.gif",
  "heic": "public.heic",
  "heif": "public.heif",
  "jpeg": "public.jpeg",
  "jpg": "public.jpeg",
  "jpe": "public.jpeg",
  "m4v": "com.apple.m4v-video",
  "mov": "com.apple.quicktime-movie",
  "mp4": "public.mpeg-4",
  "nef": "com.nikon.raw-image",
  "orf": "com.olympus.raw-image",
  "png": "public.png",
  "raf": "com.fuji.raw-image",
  "rw2": "com.panasonic.raw-image",
  "tif": "public.tiff",
  "tiff": "public.tiff",
]

private func mediaTraits(from row: [String: String]) -> [String] {
  var traits: Set<String> = []
  let subtype = intValue(row["ZKINDSUBTYPE"])
  let specialType = intValue(row["ZSPECIALTYPE"])
  let rendered = intValue(row["ZCUSTOMRENDEREDVALUE"])
  let hdrType = intValue(row["ZHDRTYPE"])
  let depthType = intValue(row["ZDEPTHTYPE"])
  let depthState = intValue(row["ZDEPTHSTATES"])
  let cameraCaptureDevice = intValue(row["ZCAMERACAPTUREDEVICE"])
  let savedAssetType = intValue(row["ZSAVEDASSETTYPE"])
  let originalResourceChoice = intValue(row["ZORIGINALRESOURCECHOICE"])

  if subtype == 2 || specialType == 5 || specialType == 8 {
    traits.insert("live")
  }
  if firstNonEmpty(row["ZAVALANCHEUUID"]) != nil {
    traits.insert("burst")
  }
  if subtype == 1 || specialType == 1 || rendered == 6 {
    traits.insert("panorama")
  }
  if subtype == 10 || specialType == 6 {
    traits.insert("screenshot")
  }
  if subtype == 101 || specialType == 2 {
    traits.insert("slow-mo")
  }
  if subtype == 102 || specialType == 3 {
    traits.insert("time-lapse")
  }
  if subtype == 103 {
    traits.insert("screen-recording")
  }
  if hdrType == 3 || rendered == 3 || specialType == 4 || specialType == 8 {
    traits.insert("hdr")
  }
  if nonZero(depthType) || nonZero(depthState) || specialType == 9 {
    traits.insert("portrait")
  }
  if cameraCaptureDevice == 1 {
    traits.insert("selfie")
  }
  if savedAssetType == 10 || bool(from: row["ZISREFERENCE"]) {
    traits.insert("reference")
  }
  if bool(from: row["ZHASRAW"]) || originalResourceChoice == 1 {
    traits.insert("raw")
  }
  return traits.sorted()
}

private func photosExifMetadata(from row: [String: String]) -> [String: String] {
  let mappings: [(String, String)] = [
    ("iso", "ZEXIFISO"),
    ("flash_fired", "ZEXIFFLASHFIRED"),
    ("metering_mode", "ZEXIFMETERINGMODE"),
    ("sample_rate", "ZEXIFSAMPLERATE"),
    ("track_format", "ZEXIFTRACKFORMAT"),
    ("white_balance", "ZEXIFWHITEBALANCE"),
    ("aperture", "ZEXIFAPERTURE"),
    ("bit_rate", "ZEXIFBITRATE"),
    ("duration", "ZEXIFDURATION"),
    ("exposure_bias", "ZEXIFEXPOSUREBIAS"),
    ("focal_length", "ZEXIFFOCALLENGTH"),
    ("fps", "ZEXIFFPS"),
    ("latitude", "ZEXIFLATITUDE"),
    ("longitude", "ZEXIFLONGITUDE"),
    ("shutter_speed", "ZEXIFSHUTTERSPEED"),
    ("camera_make", "ZEXIFCAMERAMAKE"),
    ("camera_model", "ZEXIFCAMERAMODEL"),
    ("codec", "ZEXIFCODEC"),
    ("lens_model", "ZEXIFLENSMODEL"),
    ("date_created", "ZEXIFDATECREATED"),
    ("timezone_offset", "ZEXIFTIMEZONEOFFSET"),
    ("timezone_name", "ZEXIFTIMEZONENAME"),
  ]
  var metadata: [String: String] = [:]
  for (name, column) in mappings {
    guard let value = firstNonEmpty(row[column]) else {
      continue
    }
    metadata[name] = value
  }
  return metadata
}

private func editedState(from row: [String: String]) -> Bool {
  if let hasAdjustments = intValue(row["ZHASADJUSTMENTS"]) {
    return hasAdjustments != 0
  }
  if let adjustmentsState = intValue(row["ZADJUSTMENTSSTATE"]) {
    return adjustmentsState != 0
  }
  if let hasAdjustments = intValue(row["hasadjustments"]) {
    return hasAdjustments != 0
  }
  if bool(from: row["edited"]) {
    return true
  }
  return nonEmpty(row["ZADJUSTMENTTIMESTAMP"]) == true
}

private func externalEditState(from row: [String: String]) -> Bool {
  if let value = normalizedString(row["external_edit"]) {
    return ["1", "true", "yes"].contains(value.lowercased())
  }
  return normalizedString(row["ZADJUSTMENTFORMATIDENTIFIER"]) == "com.apple.Photos.externalEdit"
}

private func intValue(_ value: String?) -> Int? {
  guard let value, !value.isEmpty else {
    return nil
  }
  return Int(value)
}

private func doubleValue(_ value: String?) -> Double? {
  guard let value, !value.isEmpty else {
    return nil
  }
  return Double(value)
}

private func nonZero(_ value: Int?) -> Bool {
  guard let value else {
    return false
  }
  return value != 0
}

private func bool(from value: String?) -> Bool {
  guard let value else {
    return false
  }
  return ["1", "true", "yes"].contains(value.lowercased())
}

private func csv(_ value: String?) -> [String] {
  guard let value, !value.isEmpty else {
    return []
  }
  return value.split(separator: ",").compactMap {
    normalizedString($0.trimmingCharacters(in: .whitespacesAndNewlines))
  }
}

private func internalList(_ value: String?) -> [String] {
  guard let value, !value.isEmpty else {
    return []
  }
  if value.contains(internalListSeparator) {
    return value.split(separator: Character(internalListSeparator)).compactMap {
      normalizedString($0.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  return csv(value)
}

private let internalListSeparator = "\u{1F}"

private func normalizedString(_ value: String?) -> String? {
  guard let value else {
    return nil
  }
  return (value as NSString).precomposedStringWithCanonicalMapping
}

private func isIntegerOnly(_ value: String) -> Bool {
  !value.isEmpty && value.allSatisfy(\.isNumber)
}

private func stableUTI(_ value: String?) -> String? {
  guard let value = firstNonEmpty(value), !isIntegerOnly(value) else {
    return nil
  }
  return value.lowercased().hasPrefix("dyn.") ? nil : value
}

private func firstNonEmpty(_ values: String?...) -> String? {
  for value in values {
    if let normalized = normalizedString(value), !normalized.isEmpty {
      return normalized
    }
  }
  return nil
}

private func photosDate(from value: String?) -> Date? {
  guard let value, let seconds = Double(value) else {
    return nil
  }
  let date = Date(timeIntervalSinceReferenceDate: seconds)
  guard photosDateFitsGregorianRange(date) else {
    return photosDefaultSortDate
  }
  return date
}

private func photosDateUsesDefaultFallback(_ value: String?) -> Bool {
  guard let value, let seconds = Double(value) else {
    return false
  }
  return !photosDateFitsGregorianRange(Date(timeIntervalSinceReferenceDate: seconds))
}

private func photosDateFitsGregorianRange(_ date: Date) -> Bool {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
  let year = calendar.component(.year, from: date)
  return (1...9999).contains(year)
}

private func photosOriginalPath(from row: [String: String], libraryPath: String) -> String? {
  let explicit = firstNonEmpty(
    row["ZORIGINALPATH"],
    row["ZFULLSIZEJPEGURL"],
    row["ZFILEURL"],
    row["path"],
    row["original_path"]
  )
  let directoryPath = firstNonEmpty(row["ZDIRECTORY"])
  let directoryFilename = firstNonEmpty(row["ZFILENAME"], row["filename"], row["ZORIGINALFILENAME"])
  let value: String?
  if let explicit {
    value = explicit
  } else if let directoryPath, let directoryFilename {
    if directoryPath.hasPrefix("/") {
      value = URL(fileURLWithPath: directoryPath).appendingPathComponent(directoryFilename).path
    } else {
      value =
        "\(directoryPath.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/\(directoryFilename)"
    }
  } else {
    value = nil
  }
  guard let value else { return nil }

  let expanded = NSString(string: value).expandingTildeInPath
  if expanded.hasPrefix("/") {
    return expanded
  }

  let library = URL(fileURLWithPath: libraryPath)
  let relative = expanded.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  var candidates: [URL] = []
  if nonEmpty(row["ZCLOUDBATCHPUBLISHDATE"]) == true,
    let directoryPath,
    let directoryFilename
  {
    let sharedDirectory = directoryPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    let sharedFilename =
      mediaType(from: row) == "video"
      ? "\(firstNonEmpty(row["ZUUID"], row["uuid"]) ?? directoryFilename).medium.MP4"
      : directoryFilename
    let sharedRelative =
      sharedDirectory.isEmpty ? sharedFilename : "\(sharedDirectory)/\(sharedFilename)"
    candidates.append(
      contentsOf: [
        library.appendingPathComponent("resources/cloudsharing/data")
          .appendingPathComponent(sharedRelative),
        library.appendingPathComponent("scopes/cloudsharing/data")
          .appendingPathComponent(sharedRelative),
      ]
    )
  }
  candidates.append(contentsOf: [
    library.appendingPathComponent(relative),
    library.appendingPathComponent("Masters").appendingPathComponent(relative),
    library.appendingPathComponent("Originals").appendingPathComponent(relative),
    library.appendingPathComponent("originals").appendingPathComponent(relative),
  ])
  if let existing = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) {
    return existing.path
  }
  return library.appendingPathComponent(relative).path
}

private func unixDate(from value: String?) -> Date? {
  guard let value, let seconds = Double(value) else {
    return nil
  }
  return Date(timeIntervalSince1970: seconds)
}

private func location(from row: [String: String]) -> PhotosLocationRecord? {
  guard let latitude = (row["ZLATITUDE"] ?? row["latitude"]).flatMap(Double.init),
    let longitude = (row["ZLONGITUDE"] ?? row["longitude"]).flatMap(Double.init)
  else {
    return nil
  }
  guard !(latitude == -180 && longitude == -180) else {
    return nil
  }
  return PhotosLocationRecord(
    latitude: latitude,
    longitude: longitude,
    altitude: (row["ZALTITUDE"] ?? row["altitude"]).flatMap(Double.init)
  )
}

private final class SQLiteReadOnlyDatabase {
  let libraryPath: String
  let databasePath: String
  private var handle: OpaquePointer?

  init(path: String, libraryPath: String) throws {
    self.libraryPath = libraryPath
    self.databasePath = path
    let openTarget: String
    let flags: Int32
    if FileManager.default.fileExists(atPath: path + "-wal")
      || FileManager.default.fileExists(atPath: path + "-shm")
    {
      openTarget = path
      flags = SQLITE_OPEN_READONLY
    } else {
      openTarget = "\(URL(fileURLWithPath: path).absoluteString)?mode=ro&immutable=1"
      flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_URI
    }
    let result = sqlite3_open_v2(openTarget, &handle, flags, nil)
    guard result == SQLITE_OK else {
      let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown sqlite error"
      throw CLIError(
        code: .backendUnavailable,
        message: "Failed to open Photos database snapshot read-only.",
        details: ["sqlite_error": message]
      )
    }
  }

  func close() {
    if let handle {
      sqlite3_close(handle)
      self.handle = nil
    }
  }

  func tableExists(_ table: String) throws -> Bool {
    let rows = try rawRows(
      sql: "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      bindings: [table],
      limit: 1
    )
    return !rows.isEmpty
  }

  func columns(in table: String) throws -> [String] {
    try rawRows(sql: "PRAGMA table_info(\(quotedIdentifier(table)))")
      .compactMap { $0["name"] }
  }

  func tableNames() throws -> [String] {
    try rawRows(sql: "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
      .compactMap { $0["name"] }
  }

  func selectRows(table: String, columns: [String], limit: Int?) throws -> [[String: String]] {
    guard !columns.isEmpty else {
      return []
    }
    let columnSQL = columns.map(quotedIdentifier).joined(separator: ", ")
    let limitSQL = limit.map { " LIMIT \(max(1, $0))" } ?? ""
    return try rawRows(sql: "SELECT \(columnSQL) FROM \(quotedIdentifier(table))\(limitSQL)")
  }

  func rawRows(sql: String, bindings: [String] = [], limit: Int? = nil) throws -> [[String: String]]
  {
    guard let handle else {
      throw CLIError(code: .internalError, message: "SQLite database is closed.")
    }
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
      throw sqliteError(handle, message: "Failed to prepare Photos database query.", sql: sql)
    }
    defer { sqlite3_finalize(statement) }

    for (index, binding) in bindings.enumerated() {
      sqlite3_bind_text(statement, Int32(index + 1), binding, -1, SQLITE_TRANSIENT)
    }

    var rows: [[String: String]] = []
    while sqlite3_step(statement) == SQLITE_ROW {
      var row: [String: String] = [:]
      for columnIndex in 0..<sqlite3_column_count(statement) {
        let name = String(cString: sqlite3_column_name(statement, columnIndex))
        if let value = sqlite3_column_text(statement, columnIndex) {
          row[name] = String(cString: value)
        } else {
          row[name] = ""
        }
      }
      rows.append(row)
      if let limit, rows.count >= limit {
        break
      }
    }
    return rows
  }

  func grep(
    pattern: String,
    ignoreCase: Bool,
    limit: Int?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseGrepMatch] {
    let expression: NSRegularExpression
    do {
      expression = try NSRegularExpression(
        pattern: pattern,
        options: ignoreCase ? [.caseInsensitive] : []
      )
    } catch {
      throw CLIError(
        code: .validationError,
        message: "`--pattern` must be a valid regular expression.",
        details: CLIError.diagnosticDetails(for: error)
      )
    }

    guard let handle else {
      throw CLIError(code: .internalError, message: "SQLite database is closed.")
    }

    let deadline = Date().addingTimeInterval(TimeInterval(timeoutSeconds))
    var matches: [PhotosDatabaseGrepMatch] = []
    for table in try tableNames() {
      try checkGrepDeadline(deadline, timeoutSeconds: timeoutSeconds)
      let sql = "SELECT * FROM \(quotedIdentifier(table))"
      var statement: OpaquePointer?
      guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK else {
        throw sqliteError(handle, message: "Failed to prepare Photos database grep.", sql: sql)
      }
      defer { sqlite3_finalize(statement) }

      var rowNumber = 0
      while true {
        try checkGrepDeadline(deadline, timeoutSeconds: timeoutSeconds)
        let step = sqlite3_step(statement)
        if step == SQLITE_DONE {
          break
        }
        guard step == SQLITE_ROW else {
          throw sqliteError(handle, message: "Failed to scan Photos database grep.", sql: sql)
        }

        for columnIndex in 0..<sqlite3_column_count(statement) {
          let type = sqlite3_column_type(statement, columnIndex)
          guard type != SQLITE_NULL, type != SQLITE_BLOB else {
            continue
          }
          guard let valuePointer = sqlite3_column_text(statement, columnIndex) else {
            continue
          }
          let value = String(cString: valuePointer)
          guard !value.isEmpty else {
            continue
          }
          let range = NSRange(value.startIndex..<value.endIndex, in: value)
          guard expression.firstMatch(in: value, range: range) != nil else {
            continue
          }
          let truncated = photosTruncate(value, maxBytes: outputCap)
          matches.append(
            PhotosDatabaseGrepMatch(
              table: table,
              column: String(cString: sqlite3_column_name(statement, columnIndex)),
              rowID: "\(rowNumber)",
              value: truncated.0,
              truncated: truncated.1
            )
          )
          if let limit, matches.count >= limit {
            return matches
          }
        }
        rowNumber += 1
      }
    }

    return matches
  }

  private func sqliteError(_ handle: OpaquePointer, message: String, sql: String? = nil) -> CLIError
  {
    var details = ["sqlite_error": String(cString: sqlite3_errmsg(handle))]
    if let sql {
      details["sql_sha256"] = photosSHA256Hex(sql)
    }
    return CLIError(
      code: .backendUnavailable,
      message: message,
      details: details
    )
  }
}

private func quotedIdentifier(_ value: String) -> String {
  "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
}

private func checkGrepDeadline(_ deadline: Date, timeoutSeconds: Int) throws {
  guard Date() <= deadline else {
    throw CLIError(
      code: .timeout,
      message: "Photos database grep timed out.",
      details: ["timeout_seconds": "\(timeoutSeconds)"]
    )
  }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
