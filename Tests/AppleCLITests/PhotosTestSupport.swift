import CoreGraphics
import Foundation
import ImageIO
import SQLite3
import UniformTypeIdentifiers

struct PhotosBackendFixture {
  var root: URL
  var library: URL
  var database: URL
  var originals: URL
}

func makePhotosBackendFixture() throws -> PhotosBackendFixture {
  let root = try photosTestTemporaryDirectory()
  let library = root.appendingPathComponent("Fixture.photoslibrary", isDirectory: true)
  let databaseDirectory = library.appendingPathComponent("database", isDirectory: true)
  let originals = root.appendingPathComponent("originals", isDirectory: true)
  let sharedDirectory = library.appendingPathComponent(
    "resources/cloudsharing/data/cloud-dir/asset-2", isDirectory: true)
  let derivativesDirectory = library.appendingPathComponent(
    "resources/derivatives/a", isDirectory: true)
  let rendersDirectory = library.appendingPathComponent("resources/renders/a", isDirectory: true)
  let libraryOriginalsDirectory = library.appendingPathComponent("originals/a", isDirectory: true)
  try FileManager.default.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
  try FileManager.default.createDirectory(at: originals, withIntermediateDirectories: true)
  try FileManager.default.createDirectory(at: sharedDirectory, withIntermediateDirectories: true)
  try FileManager.default.createDirectory(
    at: derivativesDirectory, withIntermediateDirectories: true)
  try FileManager.default.createDirectory(at: rendersDirectory, withIntermediateDirectories: true)
  try FileManager.default.createDirectory(
    at: libraryOriginalsDirectory, withIntermediateDirectories: true)

  let beach1 = originals.appendingPathComponent("IMG_0001.JPG")
  let beach2 = originals.appendingPathComponent("IMG_0002.JPG")
  let sharedBeach2 = sharedDirectory.appendingPathComponent("IMG_0002.JPG")
  let rawBeach2 = sharedDirectory.appendingPathComponent("IMG_0002_4.DNG")
  let previewBeach1 = derivativesDirectory.appendingPathComponent("asset-1_4_5005_c.jpeg")
  let previewMissing3 = derivativesDirectory.appendingPathComponent("asset-3_4_5005_c.jpeg")
  let editedBeach2 = rendersDirectory.appendingPathComponent("asset-2_1_201_a.jpeg")
  let liveBeach1 = originals.appendingPathComponent("IMG_0001_3.mov")
  let editedLiveBeach2 = rendersDirectory.appendingPathComponent("asset-2_2_100_a.mov")
  let adjustmentBeach2 = rendersDirectory.appendingPathComponent("asset-2.plist")
  let originalAdjustmentBeach2 = libraryOriginalsDirectory.appendingPathComponent("asset-2_5.aae")
  try Data("one".utf8).write(to: beach1)
  try Data("two".utf8).write(to: beach2)
  try Data("two-shared".utf8).write(to: sharedBeach2)
  try Data("two-raw".utf8).write(to: rawBeach2)
  try Data("one-preview".utf8).write(to: previewBeach1)
  try Data("three-preview".utf8).write(to: previewMissing3)
  try Data("two-edited-render".utf8).write(to: editedBeach2)
  try Data("one-live-movie".utf8).write(to: liveBeach1)
  try Data("two-edited-live-movie".utf8).write(to: editedLiveBeach2)
  try Data("adjustment".utf8).write(to: adjustmentBeach2)
  try Data("original-adjustment".utf8).write(to: originalAdjustmentBeach2)

  let database = databaseDirectory.appendingPathComponent("Photos.sqlite")
  var handle: OpaquePointer?
  guard sqlite3_open(database.path, &handle) == SQLITE_OK else {
    throw PhotosTestSupportError.sqliteOpen
  }
  defer { sqlite3_close(handle) }
  try photosTestSQLiteExec(
    handle,
    """
    CREATE TABLE ZASSET (
      Z_PK INTEGER PRIMARY KEY,
      ZUUID TEXT,
      ZFILENAME TEXT,
      ZDIRECTORY TEXT,
      ZTITLE TEXT,
      ZDESCRIPTION TEXT,
      ZFAVORITE INTEGER,
      ZHIDDEN INTEGER,
      ZKIND INTEGER,
      ZCLOUDBATCHPUBLISHDATE TEXT,
      ZCLOUDASSETGUID TEXT,
      ZCLOUDLOCALSTATE INTEGER,
      ZMOMENTSHARE INTEGER,
      ZACTIVELIBRARYSCOPEPARTICIPATIONSTATE INTEGER,
      ZADDEDDATE REAL,
      ZUNIFORMTYPEIDENTIFIER TEXT,
      ZWIDTH INTEGER,
      ZHEIGHT INTEGER,
      ZKEYWORDS TEXT,
      ZPERSONS TEXT,
      ZALBUMS TEXT,
      ZLATITUDE TEXT,
      ZLONGITUDE TEXT,
      ZALTITUDE TEXT,
      date TEXT,
      original_path TEXT,
      file_size TEXT,
      ZKINDSUBTYPE INTEGER,
      ZHDRTYPE INTEGER,
      ZCUSTOMRENDEREDVALUE INTEGER,
      ZHASADJUSTMENTS INTEGER,
      ZADJUSTMENTSSTATE INTEGER,
      ZDEPTHTYPE INTEGER,
      ZDEPTHSTATES INTEGER,
      ZSAVEDASSETTYPE INTEGER,
      ZORIGINALRESOURCECHOICE INTEGER,
      ZCAMERACAPTUREDEVICE INTEGER,
      ZAVALANCHEUUID TEXT,
      ZAVALANCHEPICKTYPE INTEGER
    );
    CREATE TABLE ZGENERICALBUM (
      Z_PK INTEGER PRIMARY KEY,
      ZUUID TEXT,
      ZTITLE TEXT,
      ZKIND INTEGER,
      ZPARENTFOLDER INTEGER,
      ZTRASHEDSTATE INTEGER
    );
    CREATE TABLE ZADDITIONALASSETATTRIBUTES (
      Z_PK INTEGER PRIMARY KEY,
      ZASSET INTEGER,
      ZORIGINALFILENAME TEXT,
      ZTITLE TEXT,
      ZUNMANAGEDADJUSTMENT INTEGER,
      ZSYNDICATIONHISTORY INTEGER,
      ZSYNDICATIONIDENTIFIER TEXT
    );
    CREATE TABLE ZEXTENDEDATTRIBUTES (
      ZASSET INTEGER,
      ZISO INTEGER,
      ZFLASHFIRED INTEGER,
      ZMETERINGMODE INTEGER,
      ZSAMPLERATE INTEGER,
      ZTRACKFORMAT INTEGER,
      ZWHITEBALANCE INTEGER,
      ZAPERTURE REAL,
      ZBITRATE REAL,
      ZDURATION REAL,
      ZEXPOSUREBIAS REAL,
      ZFOCALLENGTH REAL,
      ZFPS REAL,
      ZLATITUDE REAL,
      ZLONGITUDE REAL,
      ZSHUTTERSPEED REAL,
      ZCAMERAMAKE TEXT,
      ZCAMERAMODEL TEXT,
      ZCODEC TEXT,
      ZLENSMODEL TEXT,
      ZDATECREATED REAL,
      ZTIMEZONEOFFSET INTEGER,
      ZTIMEZONENAME TEXT
    );
    CREATE TABLE ZUNMANAGEDADJUSTMENT (
      Z_PK INTEGER PRIMARY KEY,
      ZADJUSTMENTFORMATIDENTIFIER TEXT
    );
    CREATE TABLE Z_1ASSETS (
      Z_1ALBUMS INTEGER,
      Z_3ASSETS INTEGER,
      Z_FOK_3ASSETS INTEGER
    );
    CREATE TABLE ZINTERNALRESOURCE (
      ZASSET INTEGER,
      ZLOCALAVAILABILITY INTEGER,
      ZDATASTORESUBTYPE INTEGER,
      ZCOMPACTUTI TEXT
    );
    CREATE TABLE ZCLOUDSHAREDALBUMINVITATIONRECORD (
      ZINVITEEHASHEDPERSONID TEXT,
      ZINVITEEFIRSTNAME TEXT,
      ZINVITEELASTNAME TEXT,
      ZINVITEEFULLNAME TEXT
    );
    CREATE TABLE ZCLOUDSHAREDCOMMENT (
      ZISLIKE INTEGER,
      ZCOMMENTDATE REAL,
      ZCOMMENTTEXT TEXT,
      ZCOMMENTERHASHEDPERSONID TEXT,
      ZISMYCOMMENT INTEGER,
      ZCOMMENTEDASSET INTEGER,
      ZLIKEDASSET INTEGER
    );
    INSERT INTO ZASSET
      (
        Z_PK, ZUUID, ZFILENAME, ZDIRECTORY, ZTITLE, ZDESCRIPTION, ZFAVORITE, ZHIDDEN, ZKIND,
        ZCLOUDBATCHPUBLISHDATE, ZCLOUDASSETGUID, ZCLOUDLOCALSTATE, ZMOMENTSHARE,
        ZACTIVELIBRARYSCOPEPARTICIPATIONSTATE, ZADDEDDATE, ZUNIFORMTYPEIDENTIFIER,
        ZWIDTH, ZHEIGHT, ZKEYWORDS, ZPERSONS, ZALBUMS, ZLATITUDE, ZLONGITUDE, ZALTITUDE,
        date, original_path, file_size, ZKINDSUBTYPE, ZHDRTYPE, ZCUSTOMRENDEREDVALUE,
        ZHASADJUSTMENTS, ZADJUSTMENTSSTATE, ZDEPTHTYPE, ZDEPTHSTATES,
        ZSAVEDASSETTYPE, ZORIGINALRESOURCECHOICE, ZCAMERACAPTUREDEVICE,
        ZAVALANCHEUUID, ZAVALANCHEPICKTYPE
      )
    VALUES
      (1, 'asset-1', 'IMG_0001.JPG', '', 'Beach', 'At the beach', 1, 0, 0, '', 'cloud-guid-1', 3, NULL, 0, 735091765, 'public.jpeg', 4032, 3024, 'travel,beach', 'Ana', '', '37.3318', '-122.0312', '15.5', '1700000000', '\(beach1.path)', '3', 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, NULL, NULL),
      (2, 'asset-2', 'IMG_0002.JPG', 'cloud-dir/asset-2', 'Beach', 'Duplicate title', 0, 0, 0, '735096923.060401', 'cloud-guid-2', 3, 42, 1, 735096923, 'public.heic', 4032, 3024, 'duplicate', 'Ben', '', '37.3318', '-122.0312', '15.5', '1700000001', '', '3', 0, 3, 0, 1, 1, 0, 0, 0, 1, 0, 'burst-1', 8),
      (3, 'asset-3', 'IMG_0003.MOV', '', '', '', 0, 1, 1, '', '', 0, NULL, 0, 735097923, 'public.mpeg-4', 1920, 1080, '', '', '', '', '', '', '1700000002', '\(originals.appendingPathComponent("missing.mov").path)', '0', 103, 0, 0, 0, 0, 0, 0, 10, 0, 1, NULL, NULL);
    INSERT INTO ZUNMANAGEDADJUSTMENT (Z_PK, ZADJUSTMENTFORMATIDENTIFIER)
    VALUES (20, 'com.apple.Photos.externalEdit');
    INSERT INTO ZADDITIONALASSETATTRIBUTES (
      Z_PK, ZASSET, ZORIGINALFILENAME, ZTITLE, ZUNMANAGEDADJUSTMENT,
      ZSYNDICATIONHISTORY, ZSYNDICATIONIDENTIFIER
    )
    VALUES
      (30, 1, 'IMG_0001.JPG', 'Beach', NULL, NULL, NULL),
      (31, 2, 'IMG_0002.JPG', 'Beach', 20, 1, 'syndicated-asset-2'),
      (32, 3, 'IMG_0003.MOV', NULL, NULL, NULL, NULL);
    INSERT INTO ZEXTENDEDATTRIBUTES (
      ZASSET, ZISO, ZFLASHFIRED, ZMETERINGMODE, ZSAMPLERATE, ZTRACKFORMAT,
      ZWHITEBALANCE, ZAPERTURE, ZBITRATE, ZDURATION, ZEXPOSUREBIAS, ZFOCALLENGTH,
      ZFPS, ZLATITUDE, ZLONGITUDE, ZSHUTTERSPEED, ZCAMERAMAKE, ZCAMERAMODEL,
      ZCODEC, ZLENSMODEL, ZDATECREATED, ZTIMEZONEOFFSET, ZTIMEZONENAME
    )
    VALUES
      (1, 160, 0, 5, NULL, NULL, 0, 2.2, NULL, NULL, 0.0, 4.15, NULL, NULL,
       NULL, 0.001, 'Apple', 'iPhone 14 Pro', NULL, 'iPhone 14 Pro back camera',
       735091765, 0, 'UTC'),
      (2, 320, 1, 3, NULL, NULL, 0, 1.8, NULL, NULL, 0.0, 6.86, NULL, NULL,
       NULL, 0.002, 'Canon', 'Canon R5', NULL, 'RF 24-70mm F2.8',
       735096923, 0, 'UTC');
    INSERT INTO ZINTERNALRESOURCE (
      ZASSET, ZLOCALAVAILABILITY, ZDATASTORESUBTYPE, ZCOMPACTUTI
    )
    VALUES
      (1, 1, 1, NULL),
      (2, 1, 1, 'dyn.ah62d4rv4ge80y6dfq6'),
      (2, -1, 3, NULL),
      (2, 1, 17, 'com.adobe.raw-image'),
      (3, 1, 1, NULL);
    INSERT INTO ZCLOUDSHAREDALBUMINVITATIONRECORD (
      ZINVITEEHASHEDPERSONID, ZINVITEEFIRSTNAME, ZINVITEELASTNAME, ZINVITEEFULLNAME
    )
    VALUES
      ('commenter-hash', 'Ana', 'Ng', 'Ana Ng'),
      ('liker-hash', 'Ben', 'Kay', 'Ben Kay');
    INSERT INTO ZCLOUDSHAREDCOMMENT (
      ZISLIKE, ZCOMMENTDATE, ZCOMMENTTEXT, ZCOMMENTERHASHEDPERSONID, ZISMYCOMMENT,
      ZCOMMENTEDASSET, ZLIKEDASSET
    )
    VALUES
      (0, 735100000, 'Great beach', 'commenter-hash', 0, 1, NULL),
      (1, 735100010, '', 'liker-hash', 1, NULL, 2);
    INSERT INTO ZGENERICALBUM (Z_PK, ZUUID, ZTITLE, ZKIND, ZPARENTFOLDER, ZTRASHEDSTATE)
    VALUES
      (10, 'album-travel', 'Travel', 2, 12, 0),
      (11, 'folder-trips', 'Trips', 4000, NULL, 0),
      (12, 'folder-sub', 'SubFolder', 4000, 11, 0);
    INSERT INTO Z_1ASSETS (Z_1ALBUMS, Z_3ASSETS, Z_FOK_3ASSETS)
    VALUES (10, 1, 1), (10, 2, 2);
    """
  )

  return PhotosBackendFixture(
    root: root, library: library, database: database, originals: originals)
}

func photosTestTemporaryDirectory() throws -> URL {
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-tests-\(UUID().uuidString)", isDirectory: true)
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}

func photosTestSQLiteExec(_ handle: OpaquePointer?, _ sql: String) throws {
  var error: UnsafeMutablePointer<CChar>?
  guard sqlite3_exec(handle, sql, nil, nil, &error) == SQLITE_OK else {
    let message = error.map { String(cString: $0) } ?? "sqlite error"
    sqlite3_free(error)
    throw PhotosTestSupportError.sqliteExec(message)
  }
}

func photosTestJSONObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw PhotosTestSupportError.notObject
  }
  return object
}

func photosWriteTestImage(to url: URL, type: UTType) throws {
  let colorSpace = CGColorSpaceCreateDeviceRGB()
  let pixels: [UInt8] = [
    255, 0, 0, 255,
    0, 255, 0, 255,
    0, 0, 255, 255,
    255, 255, 0, 255,
  ]
  let data = Data(pixels)
  guard let provider = CGDataProvider(data: data as CFData) else {
    throw PhotosTestSupportError.imageWriteFailed
  }
  let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
  guard
    let image = CGImage(
      width: 2,
      height: 2,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: 8,
      space: colorSpace,
      bitmapInfo: bitmapInfo,
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  else {
    throw PhotosTestSupportError.imageWriteFailed
  }
  guard
    let destination = CGImageDestinationCreateWithURL(
      url as CFURL,
      type.identifier as CFString,
      1,
      nil
    )
  else {
    throw PhotosTestSupportError.imageWriteFailed
  }
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw PhotosTestSupportError.imageWriteFailed
  }
}

func writePropertyList(_ object: [String: Any], to url: URL) throws {
  let directory = url.deletingLastPathComponent()
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  let data = try PropertyListSerialization.data(
    fromPropertyList: object, format: .binary, options: 0)
  try data.write(to: url)
}

enum PhotosTestSupportError: Error {
  case notObject
  case sqliteOpen
  case sqliteExec(String)
  case imageWriteFailed
}
