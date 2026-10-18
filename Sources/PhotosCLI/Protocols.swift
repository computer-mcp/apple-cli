import Foundation

public protocol PhotosAutomating: Sendable {
  func listLibraries() throws -> [PhotosLibraryRecord]
  func libraryInfo(path: String?) throws -> PhotosLibraryRecord
  func databaseInfo(path: String?) throws -> PhotosLibraryRecord
  func compareLibraries(libraryA: String?, libraryB: String, signatureTemplate: String?) throws
    -> PhotosLibraryCompareReport
  func openLibrary(path: String) throws -> Bool
  func backupLibrary(path: String?, destination: String) throws -> Bool

  func listAlbums(query: PhotosQuery) throws -> [PhotosAlbumRecord]
  func readAlbum(idOrName: String, query: PhotosQuery, includeItems: Bool) throws
    -> PhotosAlbumRecord
  func createAlbum(name: String, parentFolderID: String?) throws -> PhotosAlbumRecord
  func deleteAlbum(idOrName: String) throws -> Bool
  func addItemsToAlbum(albumIDOrName: String, itemUUIDs: [String]) throws -> Bool

  func listFolders(query: PhotosQuery) throws -> [PhotosFolderRecord]
  func readFolder(idOrName: String, query: PhotosQuery, includeChildren: Bool) throws
    -> PhotosFolderRecord
  func createFolder(name: String, parentFolderID: String?) throws -> PhotosFolderRecord
  func deleteFolder(idOrName: String) throws -> Bool

  func listMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord]
  func searchMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord]
  func readMediaItem(uuid: String, query: PhotosQuery, include: Set<String>, maxBytes: Int) throws
    -> PhotosMediaItemRecord
  func updateMediaItem(uuid: String, fields: [String: String]) throws -> PhotosMediaItemRecord
  func duplicateMediaItem(uuid: String) throws -> PhotosMediaItemRecord
  func listSelection(limit: Int?) throws -> [PhotosMediaItemRecord]

  func importItems(paths: [String], albumIDOrName: String?, skipDuplicateCheck: Bool) throws
    -> [PhotosMediaItemRecord]
  func exportItems(plan: PhotosExportPlan) throws -> PhotosExportResult
  func exportReport(stateDB: String?, runID: String?) throws -> PhotosExportReport

  func metadataValues(kind: String, query: PhotosQuery) throws -> PhotosMetadataAggregate
  func writeSidecar(format: String, query: PhotosQuery, destination: String, template: String?)
    throws -> Bool
  func writeExif(
    fields: [String],
    query: PhotosQuery,
    destination: String?,
    exiftoolPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> Bool

  func queryDatabase(query: PhotosQuery, rawSQL: String?) throws -> [[String: String]]
  func grepDatabase(
    query: PhotosQuery,
    pattern: String,
    ignoreCase: Bool,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseGrepMatch]
  func debugDumpDatabase(
    query: PhotosQuery,
    sections: [String],
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseDebugDumpSection]
  func findDatabaseOrphans(
    query: PhotosQuery,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosDatabaseOrphansReport
  func renderTemplate(template: String, query: PhotosQuery) throws -> [String]
  func runHook(
    kind: String, source: String, input: PhotoHookInput, timeoutSeconds: Int, outputCap: Int
  )
    throws -> PhotoHookOutput
  func runPostCommand(
    command: String,
    category: String,
    input: PhotoHookInput,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosActionResult

  func slideshowRunning() throws -> Bool
  func slideshow(action: String, query: PhotosQuery) throws -> Bool
  func showSpotlight(selector: String) throws -> Bool
}
