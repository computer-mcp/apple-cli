import Foundation
import PhotosCLI
import SQLite3
import Testing

@Suite
struct PhotosQueryTests {
  @Test func photosQueryMatchesAlbumDateLocationAndMissingSemantics() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let oldestFirstItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path
      ))
    #expect(oldestFirstItems.map(\.uuid) == ["asset-1", "asset-2", "asset-3"])

    let newestFirstItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        newestFirst: true
      ))
    #expect(newestFirstItems.map(\.uuid) == ["asset-3", "asset-2", "asset-1"])

    let limitedNewestFirstItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        newestFirst: true,
        limit: 1
      ))
    #expect(limitedNewestFirstItems.map(\.uuid) == ["asset-3"])

    let albumItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        album: "album-travel",
        location: "37.3318",
        dateFrom: "2023-11-14",
        limit: 10
      ))
    #expect(albumItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])
    let locatedItem = try #require(albumItems.first(where: { $0.uuid == "asset-1" }))
    #expect(locatedItem.location?.latitude == 37.3318)
    #expect(locatedItem.location?.longitude == -122.0312)
    #expect(locatedItem.location?.altitude == 15.5)

    let hasLocationItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hasLocation: true
      ))
    #expect(hasLocationItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let noLocationItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hasLocation: false
      ))
    #expect(noLocationItems.map { $0.uuid } == ["asset-3"])

    let commentedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hasComment: true
      ))
    #expect(commentedItems.map { $0.uuid } == ["asset-1"])
    #expect(commentedItems.first?.comments.first?.text == "Great beach")
    #expect(commentedItems.first?.comments.first?.user == "Ana Ng")
    #expect(commentedItems.first?.comments.first?.isMine == false)

    let noCommentItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hasComment: false
      ))
    #expect(noCommentItems.map { $0.uuid }.sorted() == ["asset-2", "asset-3"])

    let likedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hasLikes: true
      ))
    #expect(likedItems.map { $0.uuid } == ["asset-2"])
    #expect(likedItems.first?.likes.first?.user == "Ben Kay")
    #expect(likedItems.first?.likes.first?.isMine == true)

    let noLikesItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hasLikes: false
      ))
    #expect(noLikesItems.map { $0.uuid }.sorted() == ["asset-1", "asset-3"])

    let folderItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        folder: "Trips/SubFolder",
        limit: 10
      ))
    #expect(folderItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])
    #expect(folderItems.first?.folderPaths == ["Trips/SubFolder"])

    var handle: OpaquePointer?
    guard sqlite3_open(fixture.database.path, &handle) == SQLITE_OK else {
      throw PhotosTestSupportError.sqliteOpen
    }
    defer { sqlite3_close(handle) }
    try photosTestSQLiteExec(
      handle,
      """
      INSERT INTO ZGENERICALBUM (Z_PK, ZUUID, ZTITLE, ZKIND, ZPARENTFOLDER, ZTRASHEDSTATE)
      VALUES
        (30, 'album-family', 'Family', 2, NULL, 0),
        (31, 'album-slash', 'Travel/2025', 2, NULL, 0);
      INSERT INTO Z_1ASSETS (Z_1ALBUMS, Z_3ASSETS, Z_FOK_3ASSETS)
      VALUES (30, 3, 3), (31, 3, 3);
      """
    )

    let repeatedAlbumItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        albums: ["Trips/SubFolder/Travel", "Family"],
        limit: 10
      ))
    #expect(repeatedAlbumItems.map(\.uuid).sorted() == ["asset-1", "asset-2", "asset-3"])

    let bareNestedAlbumItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        album: "Travel",
        limit: 10
      ))
    #expect(bareNestedAlbumItems.map(\.uuid) == [])

    let albumPathItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        album: "Trips/SubFolder/Travel",
        limit: 10
      ))
    #expect(albumPathItems.map(\.uuid).sorted() == ["asset-1", "asset-2"])

    let escapedAlbumItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        album: "Travel//2025",
        limit: 10
      ))
    #expect(escapedAlbumItems.map(\.uuid) == ["asset-3"])

    let inAlbumItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        inAlbum: true
      ))
    #expect(inAlbumItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2", "asset-3"])

    let notInAlbumItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        inAlbum: false
      ))
    #expect(notInAlbumItems.map { $0.uuid } == [])

    let editedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        edited: true
      ))
    #expect(editedItems.map { $0.uuid } == ["asset-2"])

    let notEditedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        edited: false
      ))
    #expect(notEditedItems.map { $0.uuid }.sorted() == ["asset-1", "asset-3"])

    let externalEditItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        externalEdit: true
      ))
    #expect(externalEditItems.map { $0.uuid } == ["asset-2"])

    let noKeywordItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        noKeyword: true,
        noTitle: true,
        noDescription: true
      ))
    #expect(noKeywordItems.map { $0.uuid } == ["asset-3"])

    let caseSensitiveKeywordItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        keyword: "TRAVEL"
      ))
    #expect(caseSensitiveKeywordItems.isEmpty)

    let ignoreCaseKeywordItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        keyword: "TRAVEL",
        ignoreCase: true
      ))
    #expect(ignoreCaseKeywordItems.map { $0.uuid } == ["asset-1"])

    let repeatedKeywordItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        keywords: ["travel", "duplicate"]
      ))
    #expect(repeatedKeywordItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let partialKeywordItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        keyword: "trav"
      ))
    #expect(partialKeywordItems.isEmpty)

    let repeatedPersonItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        persons: ["Ana", "Ben"]
      ))
    #expect(repeatedPersonItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let repeatedTitleItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        titles: ["Beach", "Missing title"]
      ))
    #expect(repeatedTitleItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let repeatedDescriptionItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        descriptions: ["beach", "Duplicate"]
      ))
    #expect(repeatedDescriptionItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let missingItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        missing: true
      ))
    #expect(missingItems.map { $0.uuid } == ["asset-3"])

    let notMissingItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        missing: false
      ))
    #expect(notMissingItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])
  }

  @Test func photosQueryMatchesImportedExifPredicates() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let appleItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        ignoreCase: true,
        exif: [PhotosExifPredicate(tag: "EXIF:Make", value: "apple")]
      ))
    #expect(appleItems.map { $0.uuid } == ["asset-1"])
    #expect(appleItems.first?.exif["camera_model"] == "iPhone 14 Pro")

    let canonItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        exif: [PhotosExifPredicate(tag: "Make", value: "Canon")]
      ))
    #expect(canonItems.map(\.uuid) == ["asset-2"])

    let lensItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        exif: [PhotosExifPredicate(tag: "LensModel", value: "24-70")]
      ))
    #expect(lensItems.map(\.uuid) == ["asset-2"])

    let isoItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        exif: [PhotosExifPredicate(tag: "ISO", value: "160")]
      ))
    #expect(isoItems.map(\.uuid) == ["asset-1"])

    let noMatch = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        exif: [PhotosExifPredicate(tag: "Make", value: "Nikon")]
      ))
    #expect(noMatch.isEmpty)
  }

  @Test func photosQueryDuplicateSemanticsUseReferenceSignature() throws {
    let fixture = try makePhotosBackendFixture()
    let duplicate = fixture.originals.appendingPathComponent("IMG_0004.JPG")
    try Data("dup".utf8).write(to: duplicate)
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
        (4, 'asset-4', 'IMG_0004.JPG', 'Different title', '', 0, 0, 0, '', '', 735091765,
         'public.jpeg', 4032, 3024, '', '', '', '37.3318', '-122.0312', '1700000000',
         '\(duplicate.path)', '3', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      INSERT INTO ZADDITIONALASSETATTRIBUTES (Z_PK, ZASSET, ZORIGINALFILENAME, ZTITLE, ZUNMANAGEDADJUSTMENT)
      VALUES (33, 4, 'IMG_0004.JPG', 'Different title', NULL);
      """
    )
    let backend = PhotosLibrarySnapshotBackend()

    let duplicates = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        duplicate: true
      ))

    #expect(duplicates.map { $0.uuid }.sorted() == ["asset-1", "asset-4"])

    let nonDuplicates = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        duplicate: false
      ))

    #expect(nonDuplicates.map { $0.uuid }.sorted() == ["asset-2", "asset-3"])
  }

  @Test func photosOriginalUTIPrefersOriginalResourceFilenameForRAWAssets() throws {
    let fixture = try makePhotosBackendFixture()
    let raw = fixture.originals.appendingPathComponent("RAW_ONLY.DNG")
    let pairedRaw = fixture.originals.appendingPathComponent("PAIR.CR2")
    try Data("raw".utf8).write(to: raw)
    try Data("paired-raw".utf8).write(to: pairedRaw)
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
        (4, 'asset-raw', 'RAW_ONLY.DNG', 'RAW only', '', 0, 0, 0, '', '', 735091765,
         'public.jpeg', 6000, 4000, '', '', '', '', '', '1700000000',
         '\(raw.path)', '3', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        (5, 'asset-paired-jpeg', 'PAIR.JPG', 'RAW+JPEG pair', '', 0, 0, 0, '', '', 735091765,
         'public.jpeg', 6000, 4000, '', '', '', '', '', '1700000000',
         '\(pairedRaw.path)', '3', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      INSERT INTO ZADDITIONALASSETATTRIBUTES (
        Z_PK, ZASSET, ZORIGINALFILENAME, ZTITLE, ZUNMANAGEDADJUSTMENT
      )
      VALUES
        (33, 4, 'RAW_ONLY.DNG', 'RAW only', NULL),
        (34, 5, 'PAIR.JPG', 'RAW+JPEG pair', NULL);
      INSERT INTO ZINTERNALRESOURCE (
        ZASSET, ZLOCALAVAILABILITY, ZDATASTORESUBTYPE, ZCOMPACTUTI
      )
      VALUES
        (4, 1, 1, 'public.jpeg'),
        (5, 1, 1, 'com.canon.cr2-raw-image');
      """
    )
    let backend = PhotosLibrarySnapshotBackend()

    let item = try #require(
      try backend.listMediaItems(
        query: PhotosQuery(libraryPath: fixture.library.path, uuids: ["asset-raw"])
      ).first)
    #expect(item.uti == "public.jpeg")
    #expect(item.originalUTI == "com.adobe.raw-image")

    let pairedItem = try #require(
      try backend.listMediaItems(
        query: PhotosQuery(libraryPath: fixture.library.path, uuids: ["asset-paired-jpeg"])
      ).first)
    #expect(pairedItem.uti == "public.jpeg")
    #expect(pairedItem.originalUTI == "public.jpeg")

    let rawMatches = try backend.listMediaItems(
      query: PhotosQuery(libraryPath: fixture.library.path, uti: "raw-image"))
    #expect(rawMatches.map(\.uuid).contains("asset-raw"))
    #expect(!rawMatches.map(\.uuid).contains("asset-paired-jpeg"))

    let jpegMatches = try backend.listMediaItems(
      query: PhotosQuery(libraryPath: fixture.library.path, uti: "public.jpeg"))
    #expect(!jpegMatches.map(\.uuid).contains("asset-raw"))
    #expect(jpegMatches.map(\.uuid).contains("asset-paired-jpeg"))
  }

  @Test func photosQueryMatchesSharedICloudAndMediaTypeSemantics() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let sharedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        shared: true
      ))
    #expect(sharedItems.map { $0.uuid } == ["asset-2"])

    let iCloudItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        iCloud: true
      ))
    #expect(iCloudItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let inCloudItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        inCloud: true
      ))
    #expect(inCloudItems.map { $0.uuid } == ["asset-1"])

    let syndicatedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        syndicated: true,
        savedToLibrary: true,
        sharedMoment: true,
        sharedLibrary: true
      ))
    #expect(syndicatedItems.map { $0.uuid } == ["asset-2"])

    let videos = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        mediaType: "video"
      ))
    #expect(videos.map { $0.uuid } == ["asset-3"])

    let notSharedItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        shared: false,
        iCloud: false
      ))
    #expect(notSharedItems.map { $0.uuid } == ["asset-3"])

    let notInCloudItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        inCloud: false,
        syndicated: false,
        sharedMoment: false,
        sharedLibrary: false
      ))
    #expect(notInCloudItems.map { $0.uuid } == ["asset-3"])

    let notHiddenItems = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        hidden: false
      ))
    #expect(notHiddenItems.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])
  }

  @Test func photosQueryMatchesFilenamePathDateAddedUTIAndSizeSemantics() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let filenameMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        filename: "0002"
      ))
    #expect(filenameMatches.map { $0.uuid } == ["asset-2"])

    let pathMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        originalPath: "IMG_0001"
      ))
    #expect(pathMatches.map { $0.uuid } == ["asset-1"])

    let addedMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        dateAddedFrom: "2024-04-18",
        dateAddedTo: "2024-04-19"
      ))
    #expect(addedMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-2", "asset-3"])

    let addedAfterMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        addedAfter: "2024-04-18T01:00:00Z"
      ))
    #expect(addedAfterMatches.map { $0.uuid }.sorted() == ["asset-2", "asset-3"])

    let addedBeforeMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        addedBefore: "2024-04-18T01:00:00Z"
      ))
    #expect(addedBeforeMatches.map { $0.uuid } == ["asset-1"])

    let addedInLastMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        addedInLast: "10000d"
      ))
    #expect(addedInLastMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-2", "asset-3"])

    let yearMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        years: [2024],
        timeFrom: "00:00",
        timeTo: "00:30"
      ))
    #expect(yearMatches.map { $0.uuid } == ["asset-1"])

    let exclusiveDateUpperBound = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        dateTo: "2024-04-18T00:09:25Z"
      ))
    #expect(exclusiveDateUpperBound.isEmpty)

    let exclusiveTimeUpperBound = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        timeTo: "00:09:25"
      ))
    #expect(exclusiveTimeUpperBound.isEmpty)

    let jpegMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        uti: "jpeg",
        minSize: 1,
        maxSize: 3
      ))
    #expect(jpegMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])
    #expect(jpegMatches.first(where: { $0.uuid == "asset-2" })?.uti == "public.heic")
    #expect(jpegMatches.first(where: { $0.uuid == "asset-2" })?.originalUTI == "public.jpeg")
    #expect(jpegMatches.first(where: { $0.uuid == "asset-1" })?.width == 4032)
    #expect(jpegMatches.first(where: { $0.uuid == "asset-1" })?.height == 3024)
    #expect(jpegMatches.first(where: { $0.uuid == "asset-1" })?.fileSize == 3)

    let regexTitleMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        regex: #"^Bea"#,
        regexFields: ["title"]
      ))
    #expect(regexTitleMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let regexCaseSensitiveMiss = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        regex: #"^bea"#,
        regexFields: ["title"]
      ))
    #expect(regexCaseSensitiveMiss.isEmpty)

    let regexIgnoreCaseMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        regex: #"^bea"#,
        regexFields: ["title"],
        ignoreCase: true
      ))
    #expect(regexIgnoreCaseMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])

    let regexFolderMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        regex: "SubFolder",
        regexFields: ["folder"]
      ))
    #expect(regexFolderMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-2"])
  }

  @Test func photosQueryMatchesMediaTraitSemantics() throws {
    let fixture = try makePhotosBackendFixture()
    let backend = PhotosLibrarySnapshotBackend()

    let panoramaMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        traits: ["panorama"]
      ))
    #expect(panoramaMatches.map { $0.uuid } == ["asset-1"])
    #expect(panoramaMatches.first?.traits.contains("portrait") == true)

    let notPanoramaMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        excludedTraits: ["panorama"]
      ))
    #expect(notPanoramaMatches.map { $0.uuid }.sorted() == ["asset-2", "asset-3"])

    let screenRecordingReferenceMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        traits: ["screen-recording", "reference"]
      ))
    #expect(screenRecordingReferenceMatches.map { $0.uuid } == ["asset-3"])

    let rawMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        traits: ["raw", "hdr"]
      ))
    #expect(rawMatches.map { $0.uuid } == ["asset-2"])
    #expect(rawMatches.first?.rawOriginal == true)
    #expect(rawMatches.first?.rawUTI == "com.adobe.raw-image")
    #expect(rawMatches.first?.rawPath?.hasSuffix("IMG_0002_4.DNG") == true)

    let burstMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        traits: ["burst"]
      ))
    #expect(burstMatches.map { $0.uuid } == ["asset-2"])

    let notBurstMatches = try backend.listMediaItems(
      query: PhotosQuery(
        libraryPath: fixture.library.path,
        excludedTraits: ["burst"]
      ))
    #expect(notBurstMatches.map { $0.uuid }.sorted() == ["asset-1", "asset-3"])
  }
}






