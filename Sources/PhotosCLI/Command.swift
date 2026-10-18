import Foundation
import Utility

public struct PhotosCommand: Sendable {
  private let backend: any PhotosAutomating
  private let target = "photos"

  public init(backend: any PhotosAutomating = PhotosCompositeBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["libraries", "list"]:
      try validateRead(options, allowedOptions: ["library"])
      let libraries = try backend.listLibraries()
      return try result(
        PhotosLibrariesResponse(libraries: libraries),
        human: libraries.map { "\($0.name)\t\($0.path)" }.joined(separator: "\n"),
        options: options
      )
    case ["libraries", "info"]:
      try validateRead(options, allowedOptions: ["library"])
      let library = try backend.libraryInfo(path: options.targetOption("library"))
      return try result(
        PhotosLibraryResponse(library: library), human: library.path, options: options)
    case ["libraries", "compare"]:
      try validateRead(options, allowedOptions: ["library", "other-library", "signature-template"])
      let otherLibrary = try photosRequiredOption("other-library", options: options)
      let report = try backend.compareLibraries(
        libraryA: options.targetOption("library"),
        libraryB: otherLibrary,
        signatureTemplate: options.targetOption("signature-template")
      )
      return try result(
        report,
        human:
          "compared=\(report.comparedCount)\tdifferences=\(report.differenceCount)\tsame=\(report.same.count)",
        options: options
      )
    case ["libraries", "open"]:
      try validateDryRunCommand(options, allowedOptions: ["library"])
      let path = try photosRequiredOption("library", options: options)
      try requireExternalDispatch(options, operation: "photos.libraries.open")
      return try dryRunPayload(
        operation: "photos.libraries.open",
        scope: "photos-library-open",
        summary: ["library_sha256": photosSHA256Hex(path)],
        options: options
      ) {
        PhotosActionResult(
          operation: "photos.libraries.open",
          submitted: try backend.openLibrary(path: path),
          summaryFields: ["library_sha256": photosSHA256Hex(path)]
        )
      }
    case ["libraries", "backup"]:
      try validateDryRunCommand(options, allowedOptions: ["library", "destination"])
      let destination = try photosRequiredOption("destination", options: options)
      let summary = [
        "library_sha256": photosSHA256Hex(options.targetOption("library") ?? "system"),
        "destination_sha256": photosSHA256Hex(destination),
      ]
      return try dryRunPayload(
        operation: "photos.libraries.backup",
        scope: "photos-library-backup",
        summary: summary,
        options: options
      ) {
        PhotosActionResult(
          operation: "photos.libraries.backup",
          submitted: try backend.backupLibrary(
            path: options.targetOption("library"), destination: destination),
          summaryFields: summary
        )
      }

    case ["albums", "list"]:
      try validateRead(options, allowedOptions: queryOptions)
      let query = try photosQuery(from: options)
      let albums = try backend.listAlbums(query: query)
      return try result(
        PhotosAlbumsResponse(albums: albums),
        human: albums.map { "\($0.id)\t\($0.name)" }.joined(separator: "\n"),
        options: options
      )
    case ["albums", "read"]:
      try validateRead(
        options, allowedOptions: ["album", "album-id", "include", "max-bytes", "library"])
      let query = try photosQuery(from: options)
      let album = try backend.readAlbum(
        idOrName: photosSelector(options, name: "album", idName: "album-id"),
        query: query,
        includeItems: try photosIncludeOptions(options, allowed: ["items"]).contains("items")
      )
      return try result(PhotosAlbumResponse(album: album), human: album.name, options: options)
    case ["albums", "create"]:
      try validateDryRunCommand(options, allowedOptions: ["name", "folder-id"])
      let name = try photosRequiredOption("name", options: options)
      return try dryRunPayload(
        operation: "photos.albums.create",
        scope: "photos-album-create",
        summary: [
          "name_sha256": photosSHA256Hex(name),
          "folder_id": options.targetOption("folder-id") ?? "",
        ],
        options: options
      ) {
        let album = try backend.createAlbum(
          name: name, parentFolderID: options.targetOption("folder-id"))
        return PhotosAlbumResponse(album: album)
      }
    case ["albums", "delete"]:
      try validateDryRunCommand(options, allowedOptions: ["album", "album-id"])
      let selector = try photosSelector(options, name: "album", idName: "album-id")
      return try dryRunAction(
        operation: "photos.albums.delete",
        scope: "photos-album-delete",
        summary: ["album_selector": selector],
        options: options
      ) {
        try backend.deleteAlbum(idOrName: selector)
      }
    case ["albums", "add-items"]:
      try validateDryRunCommand(options, allowedOptions: ["album", "album-id", "uuid"])
      let selector = try photosSelector(options, name: "album", idName: "album-id")
      let uuids = try photosRequiredList("uuid", options: options)
      return try dryRunAction(
        operation: "photos.albums.add-items",
        scope: "photos-album-add-items",
        summary: [
          "album_selector": selector,
          "uuid_sha256": photosSHA256Hex(uuids.joined(separator: ",")),
        ],
        options: options
      ) {
        try backend.addItemsToAlbum(albumIDOrName: selector, itemUUIDs: uuids)
      }

    case ["folders", "list"]:
      try validateRead(options, allowedOptions: queryOptions)
      let query = try photosQuery(from: options)
      let folders = try backend.listFolders(query: query)
      return try result(
        PhotosFoldersResponse(folders: folders),
        human: folders.map { "\($0.id)\t\($0.name)" }.joined(separator: "\n"),
        options: options
      )
    case ["folders", "read"]:
      try validateRead(
        options, allowedOptions: ["folder", "folder-id", "include", "max-bytes", "library"])
      let query = try photosQuery(from: options)
      let folder = try backend.readFolder(
        idOrName: photosSelector(options, name: "folder", idName: "folder-id"),
        query: query,
        includeChildren: try photosIncludeOptions(options, allowed: ["children"]).contains(
          "children")
      )
      return try result(PhotosFolderResponse(folder: folder), human: folder.name, options: options)
    case ["folders", "create"]:
      try validateDryRunCommand(options, allowedOptions: ["name", "folder-id"])
      let name = try photosRequiredOption("name", options: options)
      return try dryRunPayload(
        operation: "photos.folders.create",
        scope: "photos-folder-create",
        summary: [
          "name_sha256": photosSHA256Hex(name),
          "parent_folder_id": options.targetOption("folder-id") ?? "",
        ],
        options: options
      ) {
        let folder = try backend.createFolder(
          name: name, parentFolderID: options.targetOption("folder-id"))
        return PhotosFolderResponse(folder: folder)
      }
    case ["folders", "delete"]:
      try validateDryRunCommand(options, allowedOptions: ["folder", "folder-id"])
      let selector = try photosSelector(options, name: "folder", idName: "folder-id")
      return try dryRunAction(
        operation: "photos.folders.delete",
        scope: "photos-folder-delete",
        summary: ["folder_selector": selector],
        options: options
      ) {
        try backend.deleteFolder(idOrName: selector)
      }

    case ["media-items", "list"]:
      try validateRead(options, allowedOptions: queryOptions)
      let query = try photosQuery(from: options)
      let items = try backend.listMediaItems(query: query)
      return try mediaItemsResult(items, query: query, options: options)
    case ["media-items", "search"]:
      try validateRead(options, allowedOptions: queryOptions.union(["query"]))
      let query = try photosQuery(from: options)
      let items = try backend.searchMediaItems(query: query)
      return try mediaItemsResult(items, query: query, options: options)
    case ["media-items", "read"]:
      try validateRead(options, allowedOptions: ["uuid", "include", "max-bytes", "library"])
      let uuid = try photosSingleUUID(options)
      let query = PhotosQuery(
        libraryPath: options.targetOption("library"),
        uuids: [uuid],
        limit: 2
      )
      let item = try backend.readMediaItem(
        uuid: uuid,
        query: query,
        include: try photosIncludeOptions(
          options, allowed: ["metadata", "sidecars", "albums", "faces"]),
        maxBytes: try photosMaxBytes(options)
      )
      return try result(PhotosMediaItemResponse(item: item), human: item.filename, options: options)
    case ["media-items", "dump"]:
      try validateRead(options, allowedOptions: queryOptions.union(["max-bytes"]))
      let query = try photosQuery(from: options)
      let maxBytes = try photosMaxBytes(options)
      let items = try backend.searchMediaItems(query: query)
      let records = items.map { photosDumpRecord(for: $0, maxBytes: maxBytes) }
      return try result(
        PhotosMediaItemsDumpResponse(query: query, items: records),
        human: photosDumpCSV(records),
        options: options
      )
    case ["media-items", "inspect"]:
      try validateRead(options, allowedOptions: queryOptions.union(["max-bytes"]))
      let query = try photosQuery(from: options)
      let maxBytes = try photosMaxBytes(options)
      let item = try photosSingleInspectionItem(
        try backend.searchMediaItems(query: query),
        query: query
      )
      let dump = photosDumpRecord(for: item, maxBytes: maxBytes)
      return try result(
        PhotosMediaItemInspectionResponse(query: query, item: item, dump: dump),
        human: photosInspectionText(item: item, dump: dump),
        options: options
      )
    case ["media-items", "update"]:
      try validateDryRunCommand(
        options,
        allowedOptions: [
          "library", "uuid", "uuid-from-file", "album", "folder", "filename", "original-path",
          "media-type", "date-from", "date-to", "year", "date-added-from", "date-added-to",
          "added-after", "added-before", "added-in-last", "title", "description", "keyword",
          "add-keyword", "date", "location", "album-id", "state-db",
        ],
        allowedFlags: ["favorite", "clear-favorite", "hidden", "selected"]
      )
      let query = try photosUpdateSelectionQuery(from: options)
      try photosRequireUpdateSelector(query)
      let fields = try photosMutationFields(options)
      guard !fields.isEmpty else {
        throw CLIError(
          code: .validationError, message: "At least one media item field is required.")
      }
      if options.targetOption("state-db") != nil, fields["album-id"] != nil {
        throw CLIError(
          code: .validationError,
          message:
            "`--state-db` undo tracking for `media-items update` does not cover album membership changes."
        )
      }
      if options.targetOption("state-db") != nil, !photosUpdateQuerySupportsUndo(query) {
        throw CLIError(
          code: .validationError,
          message:
            "`--state-db` undo tracking for `media-items update` requires exactly one explicit `--uuid` selector."
        )
      }
      var summary = [
        "fields_sha256": photosSHA256Hex(photosCanonicalDictionary(fields))
      ]
      summary.merge(photosQuerySummary(query), uniquingKeysWith: { _, new in new })
      if let stateDB = options.targetOption("state-db") {
        summary["state_db_sha256"] = photosSHA256Hex(stateDB)
      }
      return try dryRunPayload(
        operation: "photos.media-items.update",
        scope: "photos-media-item-update",
        summary: summary,
        options: options
      ) {
        let selectedItems: [PhotosMediaItemRecord]
        if options.targetOption("state-db") != nil {
          let uuid = try photosSingleUpdateUndoUUID(query)
          selectedItems = [
            try backend.readMediaItem(
              uuid: uuid,
              query: PhotosQuery(libraryPath: query.libraryPath, uuids: [uuid]),
              include: [],
              maxBytes: try photosMaxBytes(options)
            )
          ]
        } else {
          selectedItems = try backend.searchMediaItems(query: query)
        }
        var updatedItems: [PhotosMediaItemRecord] = []
        var undoIDs: [String] = []
        for item in selectedItems {
          let resolvedFields = try photosResolvedMutationFields(fields, for: item)
          let previousFields: [String: String]?
          if options.targetOption("state-db") != nil {
            previousFields = try photosUndoFields(from: item, changedFields: resolvedFields)
          } else {
            previousFields = nil
          }
          let updated = try backend.updateMediaItem(uuid: item.uuid, fields: resolvedFields)
          updatedItems.append(updated)
          if let stateDB = options.targetOption("state-db") {
            let undoID = try photosAppendMediaItemUndoEntry(
              stateDBPath: stateDB,
              uuid: item.uuid,
              previousFields: previousFields ?? [:],
              updatedFields: resolvedFields
            )
            undoIDs.append(undoID)
          }
        }
        return PhotosMediaItemsUpdateResponse(items: updatedItems, query: query, undoIDs: undoIDs)
      }
    case ["media-items", "undo"]:
      try validateDryRunCommand(options, allowedOptions: ["state-db", "undo-id"])
      let stateDB = try photosRequiredOption("state-db", options: options)
      let entry = try photosMediaItemUndoEntry(
        stateDBPath: stateDB,
        undoID: options.targetOption("undo-id")
      )
      return try dryRunPayload(
        operation: "photos.media-items.undo",
        scope: "photos-media-item-undo",
        summary: [
          "state_db_sha256": photosSHA256Hex(stateDB),
          "undo_id": entry.id,
          "uuid": entry.uuid,
          "fields_sha256": photosSHA256Hex(photosCanonicalDictionary(entry.previousFields)),
        ],
        options: options
      ) {
        let item = try backend.updateMediaItem(uuid: entry.uuid, fields: entry.previousFields)
        return PhotosMediaItemResponse(item: item, undoID: entry.id)
      }
    case ["media-items", "duplicate"]:
      try validateDryRunCommand(options, allowedOptions: ["uuid"])
      let uuid = try photosSingleUUID(options)
      return try dryRunPayload(
        operation: "photos.media-items.duplicate",
        scope: "photos-media-item-duplicate",
        summary: ["uuid": uuid],
        options: options
      ) {
        let item = try backend.duplicateMediaItem(uuid: uuid)
        return PhotosMediaItemResponse(item: item)
      }

    case ["selection", "list"]:
      try validateRead(options, allowedOptions: ["library"])
      let items = try backend.listSelection(limit: options.limit)
      return try mediaItemsResult(items, query: nil, options: options)

    case ["imports", "import"]:
      try validateDryRunCommand(
        options,
        allowedOptions: ["path", "album", "album-id", "folder", "folder-id"],
        allowedFlags: ["skip-check-duplicates"]
      )
      let importPlan = try photosImportPathPlan(options: options)
      let albumID = options.targetOption("album-id")
      let album = options.targetOption("album")
      let folder = options.targetOption("folder-id") ?? options.targetOption("folder")
      if folder != nil, albumID != nil {
        throw CLIError(
          code: .validationError,
          message: "`--folder`/`--folder-id` cannot be combined with `--album-id`; use `--album` so the target album can be resolved inside the folder."
        )
      }
      if folder != nil, album == nil {
        throw CLIError(
          code: .validationError,
          message: "`--folder`/`--folder-id` requires `--album` for import placement."
        )
      }
      let skipDuplicateCheck = options.hasTargetFlag("skip-check-duplicates")
      return try dryRunPayload(
        operation: "photos.imports.import",
        scope: "photos-import",
        summary: [
          "input_paths_sha256": photosSHA256Hex(importPlan.inputPaths.joined(separator: "\n")),
          "paths_sha256": photosSHA256Hex(importPlan.paths.joined(separator: "\n")),
          "groups_sha256": photosSHA256Hex(importPlan.groupSummary),
          "path_count": "\(importPlan.paths.count)",
          "group_count": "\(importPlan.groups.count)",
          "skip_duplicate_check": skipDuplicateCheck ? "true" : "false",
          "album": albumID ?? album ?? "",
          "album_sha256": photosSHA256Hex(albumID ?? album ?? ""),
          "folder": folder ?? "",
          "folder_sha256": photosSHA256Hex(folder ?? ""),
        ],
        options: options
      ) {
        let targetAlbum = try resolveImportAlbumSelector(
          albumID: albumID,
          albumName: album,
          folderIDOrName: folder
        )
        let imported = try backend.importItems(
          paths: importPlan.paths,
          albumIDOrName: targetAlbum,
          skipDuplicateCheck: skipDuplicateCheck
        )
        return PhotosMediaItemsResponse(items: imported, query: nil)
      }

    case ["exports", "export"]:
      try validateDryRunCommand(
        options,
        allowedOptions: queryOptions.union([
          "destination", "format", "filename-template", "directory-template", "state-db",
          "signature-template", "skip-uuid", "skip-uuid-from-file", "retry-count",
          "retry-wait-seconds", "retry-nas-alias", "add-exported-to-album",
          "add-skipped-to-album", "add-missing-to-album", "keep", "cleanup-command",
          "cleanup-command-error", "preview-suffix", "edited-suffix", "jpeg-quality",
          "jpeg-extension", "field", "exiftool-path", "finder-tag-template", "xattr-template",
          "source", "source-file", "command", "category", "timeout-seconds", "output-cap",
        ]),
        allowedFlags: [
          "using-originals", "current-name", "export-by-date", "touch-file", "skip-edited",
          "skip-original-if-edited", "skip-bursts", "skip-live", "skip-raw", "skip-raw-jpeg",
          "update", "force-update", "only-new", "ignore-signature", "overwrite", "preview",
          "preview-if-missing", "export-aae", "convert-to-jpeg", "fix-orientation", "cleanup",
          "allow-cleanup", "allow-eval", "allow-post-command", "allow-destructive-metadata",
        ]
      )
      if options.hasTargetFlag("export-by-date")
        && options.targetOption("directory-template") != nil
      {
        throw CLIError(
          code: .validationError,
          message: "`--export-by-date` cannot be combined with `--directory-template`."
        )
      }
      try validatePhotosExclusiveFlags("skip-raw", "skip-raw-jpeg", options: options)
      try validatePhotosExclusiveFlags("skip-edited", "skip-original-if-edited", options: options)
      try validatePhotosExclusiveFlags("update", "force-update", options: options)
      let usesExportState =
        options.hasTargetFlag("update")
        || options.hasTargetFlag("force-update")
        || options.hasTargetFlag("only-new")
        || options.hasTargetFlag("ignore-signature")
      if options.hasTargetFlag("only-new")
        && !options.hasTargetFlag("update")
        && !options.hasTargetFlag("force-update")
      {
        throw CLIError(
          code: .validationError,
          message: "`--only-new` must be combined with `--update` or `--force-update`."
        )
      }
      if options.hasTargetFlag("ignore-signature")
        && !options.hasTargetFlag("update")
        && !options.hasTargetFlag("force-update")
      {
        throw CLIError(
          code: .validationError,
          message: "`--ignore-signature` must be combined with `--update` or `--force-update`."
        )
      }
      if usesExportState, (options.targetOption("state-db") ?? "").isEmpty {
        throw CLIError(
          code: .validationError,
          message:
            "`--update`, `--force-update`, `--only-new`, and `--ignore-signature` require `--state-db`."
        )
      }
      let retryCount = try photosOptionalNonNegativeInt("retry-count", options: options) ?? 0
      guard retryCount <= 5 else {
        throw CLIError(code: .validationError, message: "`--retry-count` cannot exceed 5.")
      }
      let retryWaitSeconds =
        try photosOptionalNonNegativeInt("retry-wait-seconds", options: options) ?? 0
      guard retryWaitSeconds <= 60 else {
        throw CLIError(code: .validationError, message: "`--retry-wait-seconds` cannot exceed 60.")
      }
      if options.targetOption("retry-wait-seconds") != nil, retryCount == 0 {
        throw CLIError(
          code: .validationError,
          message: "`--retry-wait-seconds` requires `--retry-count` greater than 0."
        )
      }
      if options.targetOption("retry-nas-alias") != nil {
        throw CLIError(
          code: .validationError,
          message:
            "`--retry-nas-alias` is not supported; mount the destination first and use `--retry-count` / `--retry-wait-seconds` for bounded file retries."
        )
      }
      let addExportedToAlbum = try photosOptionalTargetOption(
        "add-exported-to-album", options: options)
      let addSkippedToAlbum = try photosOptionalTargetOption(
        "add-skipped-to-album", options: options)
      let addMissingToAlbum = try photosOptionalTargetOption(
        "add-missing-to-album", options: options)
      let hasCleanup = options.hasTargetFlag("cleanup")
      let keepRules = photosListOption("keep", options: options)
      let cleanupCommands = photosListOption("cleanup-command", options: options)
      let hasCleanupCommand = !cleanupCommands.isEmpty
      let metadataFields = photosListOption("field", options: options)
      let finderTagTemplates = photosRepeatedOption("finder-tag-template", options: options)
      let xattrTemplates = photosRepeatedOption("xattr-template", options: options)
      let hasExifMetadataWrite = !metadataFields.isEmpty
      let hasFileMetadataWrite = !finderTagTemplates.isEmpty || !xattrTemplates.isEmpty
      let hasMetadataWrite = hasExifMetadataWrite || hasFileMetadataWrite
      if hasCleanup {
        try photosRequireFlag("allow-cleanup", options: options)
      } else if options.hasTargetFlag("allow-cleanup") {
        throw CLIError(
          code: .validationError,
          message: "`--allow-cleanup` on export requires `--cleanup`."
        )
      }
      if !keepRules.isEmpty && !hasCleanup && !hasCleanupCommand {
        throw CLIError(
          code: .validationError,
          message: "`--keep` requires `--cleanup` or `--cleanup-command`."
        )
      }
      if hasCleanupCommand {
        try photosRequireFlag("allow-post-command", options: options)
      }
      if hasMetadataWrite {
        try photosRequireFlag("allow-destructive-metadata", options: options)
        if hasExifMetadataWrite {
          _ = try photosRequiredOption("exiftool-path", options: options)
        }
        for template in xattrTemplates {
          try validatePhotosXattrTemplate(template)
        }
      } else {
        if options.hasTargetFlag("allow-destructive-metadata") {
          throw CLIError(
            code: .validationError,
            message:
              "`--allow-destructive-metadata` on export requires `--field`, `--finder-tag-template`, or `--xattr-template`."
          )
        }
      }
      if !hasExifMetadataWrite {
        if options.targetOption("exiftool-path") != nil {
          throw CLIError(
            code: .validationError,
            message: "`--exiftool-path` on export requires `--field`."
          )
        }
      }
      let cleanupCommandError = options.targetOption("cleanup-command-error") ?? ""
      if !cleanupCommandError.isEmpty {
        guard hasCleanupCommand else {
          throw CLIError(
            code: .validationError,
            message: "`--cleanup-command-error` requires `--cleanup-command`."
          )
        }
        guard cleanupCommandError == "continue" || cleanupCommandError == "break" else {
          throw CLIError(
            code: .validationError,
            message: "`--cleanup-command-error` must be `continue` or `break`."
          )
        }
      }
      let convertToJPEG = options.hasTargetFlag("convert-to-jpeg")
      let jpegQuality = try photosOptionalDouble("jpeg-quality", options: options) ?? 1.0
      guard (0.0...1.0).contains(jpegQuality) else {
        throw CLIError(
          code: .validationError,
          message: "`--jpeg-quality` must be between 0.0 and 1.0."
        )
      }
      let jpegExtension = try photosJPEGExtension(options.targetOption("jpeg-extension") ?? "jpeg")
      if !convertToJPEG {
        if options.targetOption("jpeg-quality") != nil {
          throw CLIError(
            code: .validationError,
            message: "`--jpeg-quality` requires `--convert-to-jpeg`."
          )
        }
        if options.targetOption("jpeg-extension") != nil {
          throw CLIError(
            code: .validationError,
            message: "`--jpeg-extension` requires `--convert-to-jpeg`."
          )
        }
        if options.hasTargetFlag("fix-orientation") {
          throw CLIError(
            code: .validationError,
            message: "`--fix-orientation` requires `--convert-to-jpeg`."
          )
        }
      }
      let hasPostFunctionSource =
        options.targetOption("source") != nil || options.targetOption("source-file") != nil
      let hasPostCommand = options.targetOption("command") != nil
      if hasPostFunctionSource {
        try photosRequireFlag("allow-eval", options: options)
      } else if options.hasTargetFlag("allow-eval") {
        throw CLIError(
          code: .validationError,
          message: "`--allow-eval` on export requires `--source` or `--source-file`."
        )
      }
      if hasPostCommand || hasCleanupCommand {
        try photosRequireFlag("allow-post-command", options: options)
      } else if options.hasTargetFlag("allow-post-command") {
        throw CLIError(
          code: .validationError,
          message:
            "`--allow-post-command` on export requires `--command` or `--cleanup-command`."
        )
      }
      if options.targetOption("category") != nil && !hasPostFunctionSource && !hasPostCommand {
        throw CLIError(
          code: .validationError,
          message: "`--category` on export requires `--source`, `--source-file`, or `--command`."
        )
      }
      let destination = try photosRequiredOption("destination", options: options)
      let query = try photosQuery(from: options)
      let skipUUIDs = try photosSkipUUIDList(options: options)
      let directoryTemplate =
        options.hasTargetFlag("export-by-date")
        ? "{year}/{month}/{day}"
        : options.targetOption("directory-template") ?? ""
      let stateDB = options.targetOption("state-db") ?? ""
      let skipUUIDPayload = skipUUIDs.joined(separator: "\n")
      var exportOptions: [String: String] = [
        "format": options.targetOption("format") ?? "",
        "filename_template": options.targetOption("filename-template") ?? "",
        "directory_template": directoryTemplate,
        "signature_template": options.targetOption("signature-template") ?? "",
        "state_db": stateDB,
        "state_db_sha256": photosSHA256Hex(stateDB),
        "retry_count": String(retryCount),
        "retry_wait_seconds": String(retryWaitSeconds),
        "cleanup_keep": keepRules.joined(separator: "\n"),
        "cleanup_keep_sha256": photosSHA256Hex(keepRules.joined(separator: "\n")),
        "cleanup_command": cleanupCommands.joined(separator: "\n"),
        "cleanup_command_sha256": photosSHA256Hex(cleanupCommands.joined(separator: "\n")),
        "cleanup_command_error": cleanupCommandError,
        "cleanup_timeout_seconds": String(try photosTimeoutSeconds(options)),
        "cleanup_output_cap": String(try photosOutputCap(options)),
        "metadata_fields": metadataFields.joined(separator: "\n"),
        "metadata_fields_sha256": photosSHA256Hex(metadataFields.joined(separator: "\n")),
        "metadata_exiftool_path": options.targetOption("exiftool-path") ?? "",
        "metadata_exiftool_path_sha256": photosSHA256Hex(
          options.targetOption("exiftool-path") ?? ""
        ),
        "metadata_finder_tag_templates": finderTagTemplates.joined(separator: "\n"),
        "metadata_finder_tag_templates_sha256": photosSHA256Hex(
          finderTagTemplates.joined(separator: "\n")
        ),
        "metadata_xattr_templates": xattrTemplates.joined(separator: "\n"),
        "metadata_xattr_templates_sha256": photosSHA256Hex(
          xattrTemplates.joined(separator: "\n")
        ),
        "metadata_timeout_seconds": String(try photosTimeoutSeconds(options)),
        "metadata_output_cap": String(try photosOutputCap(options)),
        "preview_suffix": options.targetOption("preview-suffix") ?? "_preview",
        "edited_suffix": options.targetOption("edited-suffix") ?? "_edited",
        "jpeg_quality": String(jpegQuality),
        "jpeg_extension": jpegExtension,
        "skip_uuids": skipUUIDPayload,
        "skip_uuids_sha256": photosSHA256Hex(skipUUIDPayload),
        "add_exported_to_album": addExportedToAlbum ?? "",
        "add_exported_to_album_sha256": photosSHA256Hex(addExportedToAlbum ?? ""),
        "add_skipped_to_album": addSkippedToAlbum ?? "",
        "add_skipped_to_album_sha256": photosSHA256Hex(addSkippedToAlbum ?? ""),
        "add_missing_to_album": addMissingToAlbum ?? "",
        "add_missing_to_album_sha256": photosSHA256Hex(addMissingToAlbum ?? ""),
      ]
      let exportFlags = [
        "using_originals": "using-originals",
        "current_name": "current-name",
        "export_by_date": "export-by-date",
        "touch_file": "touch-file",
        "skip_edited": "skip-edited",
        "skip_original_if_edited": "skip-original-if-edited",
        "skip_bursts": "skip-bursts",
        "skip_live": "skip-live",
        "skip_raw": "skip-raw",
        "skip_raw_jpeg": "skip-raw-jpeg",
        "update": "update",
        "force_update": "force-update",
        "only_new": "only-new",
        "ignore_signature": "ignore-signature",
        "overwrite": "overwrite",
        "preview": "preview",
        "preview_if_missing": "preview-if-missing",
        "export_aae": "export-aae",
        "convert_to_jpeg": "convert-to-jpeg",
        "fix_orientation": "fix-orientation",
        "cleanup": "cleanup",
      ]
      for (optionName, flagName) in exportFlags {
        exportOptions[optionName] = options.hasTargetFlag(flagName) ? "true" : "false"
      }
      var postSummary: [String: String] = [:]
      if hasPostFunctionSource || hasPostCommand || hasCleanup || hasCleanupCommand
        || hasMetadataWrite
      {
        let postCategory = options.targetOption("category") ?? "export"
        let postTimeoutSeconds = try photosTimeoutSeconds(options)
        let postOutputCap = try photosOutputCap(options)
        exportOptions["post_category"] = postCategory
        exportOptions["post_timeout_seconds"] = String(postTimeoutSeconds)
        exportOptions["post_output_cap"] = String(postOutputCap)
        postSummary["gate"] = PhotosGate.strongGate.rawValue
        postSummary["post_category"] = postCategory
        postSummary["post_timeout_seconds"] = String(postTimeoutSeconds)
        postSummary["post_output_cap"] = String(postOutputCap)
      }
      if hasPostFunctionSource {
        let source = try photosHookSource(options)
        exportOptions["post_function_source"] = source
        let sourceHash = photosSHA256Hex(source)
        exportOptions["post_function_source_sha256"] = sourceHash
        postSummary["post_function_source_sha256"] = sourceHash
      }
      if hasPostCommand {
        let command = try photosRequiredOption("command", options: options)
        exportOptions["post_command"] = command
        let commandHash = photosSHA256Hex(command)
        exportOptions["post_command_sha256"] = commandHash
        postSummary["post_command_sha256"] = commandHash
      }
      if hasCleanup || hasCleanupCommand {
        postSummary["cleanup"] = hasCleanup ? "true" : "false"
        postSummary["cleanup_keep_sha256"] = exportOptions["cleanup_keep_sha256"] ?? ""
        postSummary["cleanup_command_sha256"] = exportOptions["cleanup_command_sha256"] ?? ""
      }
      if hasMetadataWrite {
        if hasExifMetadataWrite {
          postSummary["metadata_fields_sha256"] = exportOptions["metadata_fields_sha256"] ?? ""
          postSummary["metadata_exiftool_path_sha256"] =
            exportOptions["metadata_exiftool_path_sha256"] ?? ""
        }
        if hasFileMetadataWrite {
          postSummary["metadata_finder_tag_templates_sha256"] =
            exportOptions["metadata_finder_tag_templates_sha256"] ?? ""
          postSummary["metadata_xattr_templates_sha256"] =
            exportOptions["metadata_xattr_templates_sha256"] ?? ""
        }
      }
      let plan = PhotosExportPlan(query: query, destination: destination, options: exportOptions)
      var summary = photosQuerySummary(query).merging([
        "destination_sha256": photosSHA256Hex(destination),
        "options_sha256": photosSHA256Hex(photosCanonicalDictionary(exportOptions)),
      ]) { current, _ in current }
      if addExportedToAlbum != nil {
        summary["add_exported_to_album_sha256"] =
          exportOptions["add_exported_to_album_sha256"] ?? ""
      }
      if addSkippedToAlbum != nil {
        summary["add_skipped_to_album_sha256"] =
          exportOptions["add_skipped_to_album_sha256"] ?? ""
      }
      if addMissingToAlbum != nil {
        summary["add_missing_to_album_sha256"] =
          exportOptions["add_missing_to_album_sha256"] ?? ""
      }
      return try dryRunPayload(
        operation: "photos.exports.export",
        scope: "photos-export",
        summary: summary.merging(postSummary) { current, _ in current },
        options: options
      ) {
        var result = try backend.exportItems(plan: plan)
        let albumAdds = try postExportAlbumAdds(for: result, plan: plan)
        if !albumAdds.isEmpty {
          result.albumAdds = albumAdds
        }
        return result
      }
    case ["exports", "report"]:
      try validateRead(options, allowedOptions: ["state-db", "run-id"])
      let report = try backend.exportReport(
        stateDB: options.targetOption("state-db"), runID: options.targetOption("run-id"))
      return try result(
        report, human: "\(report.runID)\texported=\(report.exported)", options: options)

    case ["metadata", "keywords"], ["metadata", "persons"], ["metadata", "places"],
      ["metadata", "labels"]:
      try validateRead(options, allowedOptions: queryOptions)
      let kind = options.positionals[1]
      let aggregate = try backend.metadataValues(kind: kind, query: try photosQuery(from: options))
      return try result(
        PhotosMetadataValuesResponse(
          kind: kind, values: aggregate.values, counts: aggregate.counts),
        human: aggregate.values.joined(separator: "\n"),
        options: options
      )
    case ["metadata", "sidecar"]:
      try validateDryRunCommand(
        options, allowedOptions: queryOptions.union(["format", "destination", "template"]))
      let format = try photosRequiredOption("format", options: options)
      let destination = try photosRequiredOption("destination", options: options)
      let template = options.targetOption("template")
      let normalizedFormat = format.lowercased()
      guard ["json", "xmp", "template"].contains(normalizedFormat) else {
        throw CLIError(
          code: .validationError,
          message: "Photos sidecar format must be `json`, `xmp`, or `template`."
        )
      }
      if normalizedFormat == "template", template == nil {
        throw CLIError(
          code: .validationError,
          message: "Photos template sidecars require `--template`."
        )
      }
      let query = try photosQuery(from: options)
      return try dryRunAction(
        operation: "photos.metadata.sidecar",
        scope: "photos-sidecar",
        summary: photosQuerySummary(query).merging([
          "format": format,
          "destination_sha256": photosSHA256Hex(destination),
          "template_sha256": template.map(photosSHA256Hex) ?? "",
        ]) { current, _ in current },
        options: options
      ) {
        try backend.writeSidecar(
          format: format,
          query: query,
          destination: destination,
          template: template
        )
      }
    case ["metadata", "exif"]:
      let fields = photosRepeatedOption("field", options: options)
      if fields.isEmpty, options.targetOption("destination") == nil {
        try validateRead(options, allowedOptions: queryOptions)
        let query = try photosQuery(from: options)
        let items = try backend.searchMediaItems(query: query)
        let reportItems = items.map {
          PhotosExifItemReport(uuid: $0.uuid, filename: $0.filename, values: $0.exif)
        }
        return try result(
          PhotosExifReportResponse(query: query, items: reportItems),
          human: photosExifReportHuman(reportItems),
          options: options
        )
      }
      try validateDryRunCommand(
        options,
        allowedOptions: queryOptions.union([
          "field", "destination", "exiftool-path", "timeout-seconds", "output-cap",
        ]),
        allowedFlags: ["allow-destructive-metadata"]
      )
      let writeFields = try photosRequiredList("field", options: options)
      let destructiveMetadata = options.targetOption("destination") == nil
      if destructiveMetadata {
        try photosRequireFlag("allow-destructive-metadata", options: options)
        _ = try photosRequiredOption("exiftool-path", options: options)
      } else {
        if options.targetOption("exiftool-path") != nil {
          throw CLIError(
            code: .validationError,
            message:
              "`--exiftool-path` requires `--allow-destructive-metadata` and no `--destination`."
          )
        }
        if options.targetOption("timeout-seconds") != nil
          || options.targetOption("output-cap") != nil
        {
          throw CLIError(
            code: .validationError,
            message:
              "`--timeout-seconds` and `--output-cap` require destructive EXIF metadata writes."
          )
        }
      }
      let query = try photosQuery(from: options)
      return try dryRunAction(
        operation: "photos.metadata.exif",
        scope: destructiveMetadata
          ? "photos-exif-strong-gate" : "photos-exif",
        summary: photosQuerySummary(query).merging([
          "fields_sha256": photosSHA256Hex(writeFields.joined(separator: ",")),
          "destination_sha256": photosSHA256Hex(options.targetOption("destination") ?? ""),
          "exiftool_path_sha256": photosSHA256Hex(options.targetOption("exiftool-path") ?? ""),
          "timeout_seconds": destructiveMetadata ? "\(try photosTimeoutSeconds(options))" : "",
          "output_cap": destructiveMetadata ? "\(try photosOutputCap(options))" : "",
          "gate": destructiveMetadata
            ? PhotosGate.strongGate.rawValue : PhotosGate.dryRun.rawValue,
        ]) { current, _ in current },
        options: options
      ) {
        try backend.writeExif(
          fields: writeFields,
          query: query,
          destination: options.targetOption("destination"),
          exiftoolPath: options.targetOption("exiftool-path"),
          timeoutSeconds: try photosTimeoutSeconds(options),
          outputCap: try photosOutputCap(options)
        )
      }
    case ["metadata", "push-exif"]:
      return try metadataPushExif(options)
    case ["metadata", "timewarp"]:
      return try metadataTimewarp(options)
    case ["metadata", "add-locations"]:
      return try metadataAddLocations(options)
    case ["metadata", "sync"]:
      return try metadataSync(options)

    case ["database", "query"]:
      let rawSQL = options.targetOption("raw-sql")
      if rawSQL != nil {
        try validateStrongGate(
          options,
          allowFlag: "allow-raw-sql",
          allowedOptions: queryOptions.union(["raw-sql", "timeout-seconds", "output-cap"]),
          allowedFlags: ["allow-raw-sql"]
        )
        let sql = try photosRequiredOption("raw-sql", options: options)
        let query = try photosQuery(from: options)
        return try dryRunPayload(
          operation: "photos.database.raw-sql",
          scope: "photos-raw-sql-read-diagnostic",
          summary: photosQuerySummary(query).merging([
            "gate": PhotosGate.strongGate.rawValue,
            "sql_sha256": photosSHA256Hex(sql),
            "timeout_seconds": "\(try photosTimeoutSeconds(options))",
            "output_cap": "\(try photosOutputCap(options))",
          ]) { current, _ in current },
          options: options
        ) {
          let rows = try backend.queryDatabase(query: query, rawSQL: sql)
          return PhotosDatabaseQueryResponse(query: query, rows: rows)
        }
      }
      try validateRead(
        options,
        allowedOptions: queryOptions.union(["raw-sql", "timeout-seconds", "output-cap"]),
        allowedFlags: ["allow-raw-sql"]
      )
      let query = try photosQuery(from: options)
      let rows = try backend.queryDatabase(query: query, rawSQL: nil)
      return try result(
        PhotosDatabaseQueryResponse(query: query, rows: rows),
        human: rows.map { $0.description }.joined(separator: "\n"),
        options: options
      )
    case ["database", "grep"]:
      try validateStrongGate(
        options,
        allowFlag: "allow-database-grep",
        allowedOptions: ["library", "pattern", "timeout-seconds", "output-cap"],
        allowedFlags: ["allow-database-grep", "ignore-case"]
      )
      let pattern = try photosRequiredOption("pattern", options: options)
      let query = PhotosQuery(
        libraryPath: options.targetOption("library"),
        ignoreCase: options.hasTargetFlag("ignore-case"),
        limit: options.limit
      )
      return try dryRunPayload(
        operation: "photos.database.grep",
        scope: "photos-database-grep-diagnostic",
        summary: [
          "library_sha256": photosSHA256Hex(options.targetOption("library") ?? "system"),
          "pattern_sha256": photosSHA256Hex(pattern),
          "ignore_case": options.hasTargetFlag("ignore-case") ? "true" : "false",
          "timeout_seconds": "\(try photosTimeoutSeconds(options))",
          "output_cap": "\(try photosOutputCap(options))",
        ],
        options: options
      ) {
        let matches = try backend.grepDatabase(
          query: query,
          pattern: pattern,
          ignoreCase: options.hasTargetFlag("ignore-case"),
          timeoutSeconds: try photosTimeoutSeconds(options),
          outputCap: try photosOutputCap(options)
        )
        return PhotosDatabaseGrepResponse(
          query: query,
          patternSHA256: photosSHA256Hex(pattern),
          matches: matches
        )
      }
    case ["database", "debug-dump"]:
      try validateStrongGate(
        options,
        allowFlag: "allow-database-debug-dump",
        allowedOptions: queryOptions.union(["dump", "timeout-seconds", "output-cap"]),
        allowedFlags: queryFlags.union(["allow-database-debug-dump"])
      )
      let sections = try photosRequiredList("dump", options: options).map {
        $0.lowercased()
      }
      let query = try photosQuery(from: options)
      let timeoutSeconds = try photosTimeoutSeconds(options)
      let outputCap = try photosOutputCap(options)
      return try dryRunPayload(
        operation: "photos.database.debug-dump",
        scope: "photos-database-debug-dump-diagnostic",
        summary: photosQuerySummary(query).merging([
          "gate": PhotosGate.strongGate.rawValue,
          "sections_sha256": photosSHA256Hex(sections.joined(separator: ",")),
          "timeout_seconds": "\(timeoutSeconds)",
          "output_cap": "\(outputCap)",
        ]) { current, _ in current },
        options: options
      ) {
        let dumpSections = try backend.debugDumpDatabase(
          query: query,
          sections: sections,
          timeoutSeconds: timeoutSeconds,
          outputCap: outputCap
        )
        return PhotosDatabaseDebugDumpResponse(query: query, sections: dumpSections)
      }
    case ["database", "orphans"]:
      try validateStrongGate(
        options,
        allowFlag: "allow-database-orphans",
        allowedOptions: ["library", "timeout-seconds", "output-cap"],
        allowedFlags: ["allow-database-orphans"]
      )
      let query = PhotosQuery(libraryPath: options.targetOption("library"))
      let timeoutSeconds = try photosTimeoutSeconds(options)
      let outputCap = try photosOutputCap(options)
      return try dryRunPayload(
        operation: "photos.database.orphans",
        scope: "photos-database-orphans-diagnostic",
        summary: [
          "gate": PhotosGate.strongGate.rawValue,
          "library_sha256": photosSHA256Hex(options.targetOption("library") ?? "system"),
          "timeout_seconds": "\(timeoutSeconds)",
          "output_cap": "\(outputCap)",
        ],
        options: options
      ) {
        try backend.findDatabaseOrphans(
          query: query,
          timeoutSeconds: timeoutSeconds,
          outputCap: outputCap
        )
      }
    case ["database", "info"]:
      try validateRead(options, allowedOptions: ["library"])
      let library = try backend.databaseInfo(path: options.targetOption("library"))
      return try result(
        PhotosLibraryResponse(library: library),
        human: photosDatabaseInfoHuman(library),
        options: options
      )
    case ["database", "write"]:
      throw photosProofFailed(
        "photos database write",
        reason: "Direct Photos database writes are not production behavior.")

    case ["templates", "render"]:
      let hasTemplateHook =
        options.targetOption("source") != nil || options.targetOption("source-file") != nil
      if hasTemplateHook {
        try validateStrongGate(
          options,
          allowFlag: "allow-eval",
          allowedOptions: queryOptions.union([
            "template", "max-bytes", "source", "source-file", "timeout-seconds", "output-cap",
          ]),
          allowedFlags: queryFlags.union(["allow-eval"])
        )
        let template = try photosRequiredOption("template", options: options)
        let source = try photosHookSource(options)
        let query = try photosQuery(from: options)
        let timeoutSeconds = try photosTimeoutSeconds(options)
        let outputCap = try photosOutputCap(options)
        let summary = photosQuerySummary(query).merging([
          "gate": PhotosGate.strongGate.rawValue,
          "source_sha256": photosSHA256Hex(source),
          "timeout_seconds": "\(timeoutSeconds)",
          "output_cap": "\(outputCap)",
          "template_sha256": photosSHA256Hex(template),
        ]) { current, _ in current }
        return try dryRunPayload(
          operation: "photos.templates.render",
          scope: "photos-template-render-hook",
          summary: summary,
          options: options
        ) {
          let items = try backend.searchMediaItems(query: query)
          let rendered = try items.map { item in
            let output = try backend.runHook(
              kind: "template",
              source: source,
              input: PhotoHookInput(
                category: "template",
                photos: [item],
                context: photosQuerySummary(query)
              ),
              timeoutSeconds: timeoutSeconds,
              outputCap: outputCap
            )
            return photosRenderTemplate(
              template,
              item: item,
              additionalValues: photosTemplateHookValues(output.values)
            )
          }
          return PhotosTemplateRenderResponse(rendered: rendered)
        }
      }
      try validateRead(options, allowedOptions: queryOptions.union(["template", "max-bytes"]))
      let rendered = try backend.renderTemplate(
        template: try photosRequiredOption("template", options: options),
        query: try photosQuery(from: options)
      )
      return try result(
        PhotosTemplateRenderResponse(rendered: rendered),
        human: rendered.joined(separator: "\n"),
        options: options
      )

    case ["hooks", "template"], ["hooks", "query"], ["hooks", "post"]:
      try validateStrongGate(
        options,
        allowFlag: "allow-eval",
        allowedOptions: queryOptions.union([
          "source", "source-file", "timeout-seconds", "output-cap",
        ]),
        allowedFlags: queryFlags.union(["allow-eval"])
      )
      let kind = options.positionals[1]
      let source = try photosHookSource(options)
      let query = try photosQuery(from: options)
      let summary = photosQuerySummary(query).merging([
        "gate": PhotosGate.strongGate.rawValue,
        "source_sha256": photosSHA256Hex(source),
        "timeout_seconds": "\(try photosTimeoutSeconds(options))",
        "output_cap": "\(try photosOutputCap(options))",
      ]) { current, _ in current }
      if kind == "query" {
        return try dryRunPayload(
          operation: "photos.hooks.\(kind)",
          scope: "photos-hook-\(kind)",
          summary: summary,
          options: options
        ) {
          let items = try backend.searchMediaItems(query: query)
          var accepted: [PhotosMediaItemRecord] = []
          for item in items {
            let output = try backend.runHook(
              kind: kind,
              source: source,
              input: PhotoHookInput(
                category: kind,
                photos: [item],
                context: photosQuerySummary(query)
              ),
              timeoutSeconds: try photosTimeoutSeconds(options),
              outputCap: try photosOutputCap(options)
            )
            if output.accepted {
              accepted.append(item)
            }
          }
          return PhotosMediaItemsResponse(items: accepted, query: query)
        }
      }
      return try dryRunPayload(
        operation: "photos.hooks.\(kind)",
        scope: "photos-hook-\(kind)",
        summary: summary,
        options: options
      ) {
        try backend.runHook(
          kind: kind,
          source: source,
          input: PhotoHookInput(category: kind, photos: [], context: photosQuerySummary(query)),
          timeoutSeconds: try photosTimeoutSeconds(options),
          outputCap: try photosOutputCap(options)
        )
      }
    case ["post-commands", "run"]:
      try validateStrongGate(
        options,
        allowFlag: "allow-post-command",
        allowedOptions: queryOptions.union(["category", "command", "timeout-seconds", "output-cap"]
        ),
        allowedFlags: ["allow-post-command"]
      )
      let command = try photosRequiredOption("command", options: options)
      let category = try photosRequiredOption("category", options: options)
      let query = try photosQuery(from: options)
      let input = PhotoHookInput(category: category, photos: [], context: photosQuerySummary(query))
      return try dryRunPayload(
        operation: "photos.post-commands.run",
        scope: "photos-post-command",
        summary: photosQuerySummary(query).merging([
          "gate": PhotosGate.strongGate.rawValue,
          "category": category,
          "command_sha256": photosSHA256Hex(command),
          "timeout_seconds": "\(try photosTimeoutSeconds(options))",
          "output_cap": "\(try photosOutputCap(options))",
        ]) { current, _ in current },
        options: options
      ) {
        try backend.runPostCommand(
          command: command,
          category: category,
          input: input,
          timeoutSeconds: try photosTimeoutSeconds(options),
          outputCap: try photosOutputCap(options)
        )
      }

    case ["slideshow", "status"], ["slideshow", "running"]:
      try validateRead(options, allowedOptions: [])
      let running = try backend.slideshowRunning()
      return try result(
        PhotosSlideshowStatus(running: running),
        human: "running: \(running)",
        options: options
      )
    case ["slideshow", "start"], ["slideshow", "stop"], ["slideshow", "next"],
      ["slideshow", "previous"], ["slideshow", "pause"], ["slideshow", "resume"]:
      try validateDryRunCommand(options, allowedOptions: queryOptions)
      let action = options.positionals[1]
      let query = try photosQuery(from: options)
      try requireExternalDispatch(options, operation: "photos.slideshow.\(action)")
      return try dryRunPayload(
        operation: "photos.slideshow.\(action)",
        scope: "photos-slideshow-\(action)",
        summary: photosQuerySummary(query),
        options: options
      ) {
        PhotosActionResult(
          operation: "photos.slideshow.\(action)",
          submitted: try backend.slideshow(action: action, query: query),
          summaryFields: photosQuerySummary(query)
        )
      }
    case ["show", "spotlight"]:
      try validateDryRunCommand(options, allowedOptions: ["uuid", "path", "library"])
      let selector: String
      if let path = options.targetOption("path") {
        selector = path
      } else {
        selector = try photosSingleUUID(options)
      }
      try requireExternalDispatch(options, operation: "photos.show.spotlight")
      return try dryRunPayload(
        operation: "photos.show.spotlight",
        scope: "photos-show-spotlight",
        summary: ["selector_sha256": photosSHA256Hex(selector)],
        options: options
      ) {
        PhotosActionResult(
          operation: "photos.show.spotlight",
          submitted: try backend.showSpotlight(selector: selector),
          summaryFields: ["selector_sha256": photosSHA256Hex(selector)]
        )
      }
    default:
      return nil
    }
  }

  private var queryOptions: Set<String> {
    [
      "library", "album", "album-id", "folder", "folder-id", "uuid", "uuid-from-file",
      "keyword", "person",
      "title", "description", "filename", "original-path", "place", "location", "label",
      "regex", "regex-field", "uti", "trait", "not-trait", "media-type", "date-from",
      "date-to", "year", "from-time", "to-time",
      "date-added-from", "date-added-to", "added-after", "added-before", "added-in-last",
      "min-size", "max-size", "favorite", "hidden", "shared", "icloud", "incloud",
      "syndicated", "saved-to-library", "shared-moment", "shared-library", "in-album",
      "has-comment", "has-likes", "edited", "external-edit", "duplicate", "missing", "exif",
    ]
  }

  private var queryFlags: Set<String> {
    [
      "favorite", "not-favorite", "no-keyword", "no-title", "no-description", "only-photos",
      "has-location", "no-location", "no-place", "only-movies", "hidden", "not-hidden", "shared",
      "not-shared", "icloud", "not-icloud", "incloud", "not-incloud", "syndicated",
      "not-syndicated", "saved-to-library", "not-saved-to-library", "shared-moment",
      "not-shared-moment", "shared-library", "not-shared-library", "has-comment", "no-comment",
      "has-likes", "no-likes", "in-album", "not-in-album", "edited", "not-edited",
      "external-edit", "not-external-edit", "duplicate", "not-duplicate", "missing",
      "not-missing", "selected", "ignore-case", "newest-first", "allow-raw-sql",
    ]
  }

  private func validateRead(
    _ options: CLIOptions,
    allowedOptions: Set<String>,
    allowedFlags: Set<String>? = nil
  ) throws {
    try validatePhotosReadOnly(options)
    try validatePhotosTargetOptions(
      options, allowedOptions: allowedOptions, allowedFlags: allowedFlags ?? queryFlags)
    try validatePhotosQueryFlagPairs(options)
    try validatePhotosQueryValues(options)
  }

  private func validateDryRunCommand(
    _ options: CLIOptions,
    allowedOptions: Set<String>,
    allowedFlags: Set<String> = []
  ) throws {
    try validatePhotosTargetOptions(
      options, allowedOptions: allowedOptions, allowedFlags: allowedFlags)
    try validatePhotosDryRunIntent(
      options, description: options.positionals.joined(separator: " "))
  }

  private func validateStrongGate(
    _ options: CLIOptions,
    allowFlag: String,
    allowedOptions: Set<String>,
    allowedFlags: Set<String>
  ) throws {
    try validatePhotosTargetOptions(
      options, allowedOptions: allowedOptions, allowedFlags: allowedFlags)
    try photosRequireFlag(allowFlag, options: options)
    try validatePhotosDryRunIntent(
      options, description: options.positionals.joined(separator: " "))
  }

  private func requireExternalDispatch(_ options: CLIOptions, operation: String) throws {
    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message:
        "`\(operation)` dispatches work to Photos.app or another system service. Pass `--allow-external-dispatch` to execute."
    )
  }

  private func dryRunAction(
    operation: String,
    scope: String,
    summary: [String: String],
    options: CLIOptions,
    submit: () throws -> Bool
  ) throws -> CLICommandResult {
    try dryRunPayload(operation: operation, scope: scope, summary: summary, options: options)
    {
      PhotosActionResult(operation: operation, submitted: try submit(), summaryFields: summary)
    }
  }

  private func postExportAlbumAdds(
    for result: PhotosExportResult,
    plan: PhotosExportPlan
  ) throws -> [PhotosExportAlbumAddRecord] {
    let categories: [(name: String, option: String, uuids: [String])] = [
      ("exported", "add_exported_to_album", result.exportedUUIDs ?? []),
      ("skipped", "add_skipped_to_album", result.skippedUUIDs ?? []),
      ("missing", "add_missing_to_album", result.missingUUIDs ?? []),
    ]
    var records: [PhotosExportAlbumAddRecord] = []
    for category in categories {
      guard let album = photosNonEmptyPlanOption(category.option, in: plan.options) else {
        continue
      }
      let itemUUIDs = photosUniqueStable(category.uuids)
      let albumCreated = try ensurePostExportAlbum(album, query: plan.query)
      let submitted =
        itemUUIDs.isEmpty
        ? (submitted: false, albumCreated: false)
        : try addItemsToPostExportAlbum(
          album,
          itemUUIDs: itemUUIDs,
          alreadyCreated: albumCreated
        )
      records.append(
        PhotosExportAlbumAddRecord(
          category: category.name,
          album: album,
          itemUUIDs: itemUUIDs,
          submitted: submitted.submitted,
          albumCreated: albumCreated || submitted.albumCreated
        ))
    }
    return records
  }

  private func ensurePostExportAlbum(_ album: String, query: PhotosQuery) throws -> Bool {
    do {
      _ = try backend.readAlbum(idOrName: album, query: query, includeItems: false)
      return false
    } catch let error as CLIError where error.code == .notFound {
      _ = try backend.createAlbum(name: album, parentFolderID: nil)
      return true
    }
  }

  private func resolveImportAlbumSelector(
    albumID: String?,
    albumName: String?,
    folderIDOrName: String?
  ) throws -> String? {
    if let albumID, !albumID.isEmpty {
      return albumID
    }
    guard let albumName, !albumName.isEmpty else {
      return nil
    }
    guard let folderIDOrName, !folderIDOrName.isEmpty else {
      return albumName
    }

    let folder = try backend.readFolder(
      idOrName: folderIDOrName,
      query: PhotosQuery(),
      includeChildren: true
    )
    if let existing = folder.childAlbums?.first(where: { album in
      album.id == albumName || album.name == albumName
    }) {
      return existing.id
    }
    let created = try backend.createAlbum(name: albumName, parentFolderID: folder.id)
    return created.id
  }

  private func addItemsToPostExportAlbum(
    _ album: String,
    itemUUIDs: [String],
    alreadyCreated: Bool
  ) throws -> (submitted: Bool, albumCreated: Bool) {
    do {
      return (try backend.addItemsToAlbum(albumIDOrName: album, itemUUIDs: itemUUIDs), false)
    } catch let error as CLIError where error.code == .notFound && !alreadyCreated {
      _ = try backend.createAlbum(name: album, parentFolderID: nil)
      return (try backend.addItemsToAlbum(albumIDOrName: album, itemUUIDs: itemUUIDs), true)
    }
  }

  private func photosUniqueStable(_ values: [String]) -> [String] {
    var seen: Set<String> = []
    var result: [String] = []
    for value in values where seen.insert(value).inserted {
      result.append(value)
    }
    return result
  }

  private func dryRunPayload<Payload: Encodable>(
    operation: String,
    scope: String,
    summary: [String: String],
    options: CLIOptions,
    submit: () throws -> Payload
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validatePhotosDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .persistentAction,
          notes: ["Target-specific `--allow-*` flags still apply before execution."]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    return try result(try submit(), human: "\(operation) submitted", options: options)
  }

  private func mediaItemsResult(
    _ items: [PhotosMediaItemRecord],
    query: PhotosQuery?,
    options: CLIOptions
  ) throws -> CLICommandResult {
    try result(
      PhotosMediaItemsResponse(items: items, query: query),
      human: items.map { "\($0.uuid)\t\($0.filename)" }.joined(separator: "\n"),
      options: options
    )
  }

  private func metadataPushExif(_ options: CLIOptions) throws -> CLICommandResult {
    try validateStrongGate(
      options,
      allowFlag: "allow-destructive-metadata",
      allowedOptions: queryOptions.union([
        "field", "exiftool-path", "timeout-seconds", "output-cap",
      ]),
      allowedFlags: queryFlags.union(["allow-destructive-metadata"])
    )
    let requestedFields = try photosPushExifRequestedFields(options)
    let exiftoolPath = try photosRequiredExecutableOption("exiftool-path", options: options)
    let query = try photosQuery(from: options)
    try photosRequireExplicitMutationSelector(query, commandName: "metadata push-exif")
    let selectedItems = try backend.searchMediaItems(query: query)
    guard !selectedItems.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "No Photos media items matched the `metadata push-exif` selector."
      )
    }
    let plannedRecords = try photosPushExifPlannedRecords(
      items: selectedItems,
      requestedFields: requestedFields,
      query: query
    )
    let summary = try photosPushExifSummary(
      query: query,
      requestedFields: requestedFields,
      plannedRecords: plannedRecords,
      exiftoolPath: exiftoolPath,
      timeoutSeconds: photosTimeoutSeconds(options),
      outputCap: photosOutputCap(options)
    )
    return try dryRunPayload(
      operation: "photos.metadata.push-exif",
      scope: "photos-push-exif-strong-gate",
      summary: summary,
      options: options
    ) {
      try photosSubmitPushExif(
        plannedRecords,
        query: query,
        exiftoolPath: exiftoolPath,
        timeoutSeconds: try photosTimeoutSeconds(options),
        outputCap: try photosOutputCap(options)
      )
    }
  }

  private func photosSubmitPushExif(
    _ plannedRecords: [PhotosPushExifPlannedRecord],
    query: PhotosQuery,
    exiftoolPath: String,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosPushExifReport {
    var records: [PhotosPushExifRecord] = []
    for record in plannedRecords {
      guard !record.fields.isEmpty else {
        records.append(
          PhotosPushExifRecord(
            uuid: record.item.uuid,
            filename: record.item.filename,
            path: record.path,
            fields: [],
            submitted: false,
            skippedReason: "no selected Photos metadata is present"
          ))
        continue
      }
      _ = try backend.writeExif(
        fields: record.fields,
        query: PhotosQuery(libraryPath: query.libraryPath, uuids: [record.item.uuid]),
        destination: nil,
        exiftoolPath: exiftoolPath,
        timeoutSeconds: timeoutSeconds,
        outputCap: outputCap
      )
      records.append(
        PhotosPushExifRecord(
          uuid: record.item.uuid,
          filename: record.item.filename,
          path: record.path,
          fields: record.fields,
          submitted: true
        ))
    }
    return PhotosPushExifReport(
      operation: "photos.metadata.push-exif",
      query: query,
      records: records
    )
  }

  private func metadataTimewarp(_ options: CLIOptions) throws -> CLICommandResult {
    try validateStrongGate(
      options,
      allowFlag: "allow-destructive-metadata",
      allowedOptions: queryOptions.union([
        "set-date", "date-delta-seconds", "timezone-offset-seconds", "timeout-seconds",
        "output-cap",
      ]),
      allowedFlags: queryFlags.union(["allow-destructive-metadata"])
    )
    let setDate = options.targetOption("set-date")
    let deltaSeconds = try photosOptionalSignedInt("date-delta-seconds", options: options)
    let timeZoneOffsetSeconds = try photosOptionalSignedInt(
      "timezone-offset-seconds", options: options)
    if setDate != nil, deltaSeconds != nil {
      throw CLIError(
        code: .validationError,
        message: "`--set-date` cannot be combined with `--date-delta-seconds`."
      )
    }
    guard setDate != nil || deltaSeconds != nil || timeZoneOffsetSeconds != nil else {
      throw CLIError(
        code: .validationError,
        message:
          "`metadata timewarp` requires `--set-date`, `--date-delta-seconds`, or `--timezone-offset-seconds`."
      )
    }
    let normalizedSetDate = try setDate.map { try photosValidatedISODateString($0) }
    let query = try photosQuery(from: options)
    let summary = photosQuerySummary(query).merging([
      "gate": PhotosGate.strongGate.rawValue,
      "set_date_sha256": normalizedSetDate.map(photosSHA256Hex) ?? "",
      "date_delta_seconds": deltaSeconds.map(String.init) ?? "",
      "timezone_offset_seconds": timeZoneOffsetSeconds.map(String.init) ?? "",
      "timeout_seconds": "\(try photosTimeoutSeconds(options))",
      "output_cap": "\(try photosOutputCap(options))",
    ]) { current, _ in current }
    return try dryRunPayload(
      operation: "photos.metadata.timewarp",
      scope: "photos-metadata-timewarp",
      summary: summary,
      options: options
    ) {
      let items = try backend.searchMediaItems(query: query)
      let itemFields = try items.map { item in
        (
          item: item,
          fields: try photosTimewarpFields(
            for: item,
            setDate: normalizedSetDate,
            deltaSeconds: deltaSeconds,
            timeZoneOffsetSeconds: timeZoneOffsetSeconds
          ),
          skippedReason: nil as String?
        )
      }
      return try metadataMutationReport(
        operation: "photos.metadata.timewarp",
        query: query,
        sourceSHA256: nil,
        itemFields: itemFields,
        submit: true
      )
    }
  }

  private func metadataAddLocations(_ options: CLIOptions) throws -> CLICommandResult {
    try validateStrongGate(
      options,
      allowFlag: "allow-destructive-metadata",
      allowedOptions: queryOptions.union([
        "set-location", "track-file", "max-match-seconds", "timeout-seconds", "output-cap",
      ]),
      allowedFlags: queryFlags.union(["allow-destructive-metadata"])
    )
    let setLocation = options.targetOption("set-location")
    let trackFile = options.targetOption("track-file")
    if (setLocation == nil) == (trackFile == nil) {
      throw CLIError(
        code: .validationError,
        message:
          "`metadata add-locations` requires exactly one of `--set-location` or `--track-file`."
      )
    }
    let normalizedLocation = try setLocation.map(photosValidatedLocationString)
    let trackText = try trackFile.map(photosReadUTF8File)
    let trackPoints = try trackText.map(photosTrackPoints)
    let maxMatchSeconds =
      try photosOptionalNonNegativeInt("max-match-seconds", options: options)
      ?? 300
    guard maxMatchSeconds <= 86_400 else {
      throw CLIError(
        code: .validationError,
        message: "`--max-match-seconds` cannot exceed 86400."
      )
    }
    let query = try photosQuery(from: options)
    let summary = photosQuerySummary(query).merging([
      "gate": PhotosGate.strongGate.rawValue,
      "set_location_sha256": normalizedLocation.map(photosSHA256Hex) ?? "",
      "track_file_sha256": trackFile.map(photosSHA256Hex) ?? "",
      "track_content_sha256": trackText.map(photosSHA256Hex) ?? "",
      "max_match_seconds": "\(maxMatchSeconds)",
      "timeout_seconds": "\(try photosTimeoutSeconds(options))",
      "output_cap": "\(try photosOutputCap(options))",
    ]) { current, _ in current }
    return try dryRunPayload(
      operation: "photos.metadata.add-locations",
      scope: "photos-metadata-add-locations",
      summary: summary,
      options: options
    ) {
      let items = try backend.searchMediaItems(query: query)
      let itemFields = items.map { item in
        photosLocationMutationFields(
          for: item,
          explicitLocation: normalizedLocation,
          trackPoints: trackPoints ?? [],
          maxMatchSeconds: maxMatchSeconds
        )
      }
      return try metadataMutationReport(
        operation: "photos.metadata.add-locations",
        query: query,
        sourceSHA256: trackText.map(photosSHA256Hex),
        itemFields: itemFields,
        submit: true
      )
    }
  }

  private func metadataSync(_ options: CLIOptions) throws -> CLICommandResult {
    let reportOnly = options.hasTargetFlag("report-only")
    let allowedOptions = queryOptions.union([
      "source-file", "field", "timeout-seconds", "output-cap",
    ])
    let allowedFlags = queryFlags.union(["allow-destructive-metadata", "report-only"])
    if reportOnly {
      try validateRead(
        options,
        allowedOptions: allowedOptions.subtracting(["timeout-seconds", "output-cap"]),
        allowedFlags: queryFlags.union(["report-only"])
      )
    } else {
      try validateStrongGate(
        options,
        allowFlag: "allow-destructive-metadata",
        allowedOptions: allowedOptions,
        allowedFlags: allowedFlags.subtracting(["report-only"])
      )
    }
    let sourceFile = try photosRequiredOption("source-file", options: options)
    let sourceText = try photosReadUTF8File(sourceFile)
    let sourceRecords = try photosSyncSourceRecords(sourceText)
    let requestedFields = try photosSyncFields(photosListOption("field", options: options))
    let query = try photosQuery(from: options)
    let sourceSHA256 = photosSHA256Hex(sourceText)
    if reportOnly {
      let items = try backend.searchMediaItems(query: query)
      let itemFields = photosSyncMutationFields(
        items: items,
        sourceRecords: sourceRecords,
        fields: requestedFields
      )
      return try result(
        try metadataMutationReport(
          operation: "photos.metadata.sync",
          query: query,
          sourceSHA256: sourceSHA256,
          itemFields: itemFields,
          submit: false
        ),
        human: "photos.metadata.sync planned=\(itemFields.count)",
        options: options
      )
    }
    let summary = photosQuerySummary(query).merging([
      "gate": PhotosGate.strongGate.rawValue,
      "source_file_sha256": photosSHA256Hex(sourceFile),
      "source_content_sha256": sourceSHA256,
      "fields_sha256": photosSHA256Hex(requestedFields.joined(separator: ",")),
      "timeout_seconds": "\(try photosTimeoutSeconds(options))",
      "output_cap": "\(try photosOutputCap(options))",
    ]) { current, _ in current }
    return try dryRunPayload(
      operation: "photos.metadata.sync",
      scope: "photos-metadata-sync",
      summary: summary,
      options: options
    ) {
      let items = try backend.searchMediaItems(query: query)
      let itemFields = photosSyncMutationFields(
        items: items,
        sourceRecords: sourceRecords,
        fields: requestedFields
      )
      return try metadataMutationReport(
        operation: "photos.metadata.sync",
        query: query,
        sourceSHA256: sourceSHA256,
        itemFields: itemFields,
        submit: true
      )
    }
  }

  private func metadataMutationReport(
    operation: String,
    query: PhotosQuery,
    sourceSHA256: String?,
    itemFields: [(item: PhotosMediaItemRecord, fields: [String: String], skippedReason: String?)],
    submit: Bool
  ) throws -> PhotosMetadataMutationReport {
    var records: [PhotosMetadataMutationRecord] = []
    for itemField in itemFields {
      let skippedReason =
        itemField.skippedReason
        ?? (itemField.fields.isEmpty ? "no metadata fields selected" : nil)
      if submit, skippedReason == nil {
        _ = try backend.updateMediaItem(uuid: itemField.item.uuid, fields: itemField.fields)
        records.append(
          PhotosMetadataMutationRecord(
            uuid: itemField.item.uuid,
            filename: itemField.item.filename,
            fields: itemField.fields,
            submitted: true
          ))
      } else {
        records.append(
          PhotosMetadataMutationRecord(
            uuid: itemField.item.uuid,
            filename: itemField.item.filename,
            fields: itemField.fields,
            submitted: false,
            skippedReason: skippedReason ?? "report-only"
          ))
      }
    }
    return PhotosMetadataMutationReport(
      operation: operation,
      query: query,
      sourceSHA256: sourceSHA256,
      records: records
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }
    return CLICommandResult(stdout: human)
  }
}

private struct PhotosPushExifPlannedRecord {
  var item: PhotosMediaItemRecord
  var path: String
  var fields: [String]
}

private enum PhotosPushExifField: String, CaseIterable {
  case all
  case keywords
  case location
  case faces
  case persons
  case datetime
  case title
  case description
  case favorite
}

private func photosPushExifRequestedFields(_ options: CLIOptions) throws -> [String] {
  let accepted = Set(PhotosPushExifField.allCases.map(\.rawValue))
  var fields: [String] = []
  var seen: Set<String> = []
  for value in try photosRequiredList("field", options: options) {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard accepted.contains(normalized) else {
      throw CLIError(
        code: .validationError,
        message:
          "`metadata push-exif --field` must be one of: \(accepted.sorted().joined(separator: ", "))."
      )
    }
    if seen.insert(normalized).inserted {
      fields.append(normalized)
    }
  }
  return fields
}

private func photosPushExifPlannedRecords(
  items: [PhotosMediaItemRecord],
  requestedFields: [String],
  query: PhotosQuery
) throws -> [PhotosPushExifPlannedRecord] {
  try items.map { item in
    PhotosPushExifPlannedRecord(
      item: item,
      path: try photosPushExifWritableOriginalPath(for: item, query: query),
      fields: photosPushExifFields(for: item, requestedFields: requestedFields)
    )
  }
}

private func photosPushExifSummary(
  query: PhotosQuery,
  requestedFields: [String],
  plannedRecords: [PhotosPushExifPlannedRecord],
  exiftoolPath: String,
  timeoutSeconds: Int,
  outputCap: Int
) throws -> [String: String] {
  let requestedFieldsText = requestedFields.joined(separator: ",")
  let derivedFieldsText =
    plannedRecords
    .map { "\($0.item.uuid)\t\($0.path)\t\($0.fields.joined(separator: "\t"))" }
    .joined(separator: "\n")
  let targetPathsText = plannedRecords.map(\.path).joined(separator: "\n")
  var summary = photosQuerySummary(query)
  summary.merge(
    [
      "gate": PhotosGate.strongGate.rawValue,
      "fields": requestedFieldsText,
      "fields_sha256": photosSHA256Hex(requestedFieldsText),
      "derived_fields_sha256": photosSHA256Hex(derivedFieldsText),
      "target_paths_sha256": photosSHA256Hex(targetPathsText),
      "exiftool_path_sha256": photosSHA256Hex(exiftoolPath),
      "item_count": "\(plannedRecords.count)",
      "write_count": "\(plannedRecords.filter { !$0.fields.isEmpty }.count)",
      "timeout_seconds": "\(timeoutSeconds)",
      "output_cap": "\(outputCap)",
    ],
    uniquingKeysWith: { current, _ in current }
  )
  return summary
}

private func photosPushExifWritableOriginalPath(
  for item: PhotosMediaItemRecord,
  query: PhotosQuery
) throws -> String {
  guard let originalPath = item.originalPath, !originalPath.isEmpty else {
    throw CLIError(
      code: .notFound,
      message: "Photos item has no writable original file for EXIF metadata.",
      details: ["uuid": item.uuid]
    )
  }
  let path = URL(fileURLWithPath: originalPath).standardizedFileURL.path
  guard FileManager.default.fileExists(atPath: path) else {
    throw CLIError(
      code: .notFound,
      message: "Photos item original file does not exist for EXIF metadata.",
      details: ["uuid": item.uuid, "path": path]
    )
  }
  if photosPathIsInsidePhotosLibrary(path, libraryPath: query.libraryPath) {
    throw CLIError(
      code: .unsafeMutationRefused,
      message: "Refusing to write EXIF metadata inside a .photoslibrary package.",
      details: ["uuid": item.uuid, "path": path]
    )
  }
  return path
}

private func photosPathIsInsidePhotosLibrary(_ path: String, libraryPath: String?) -> Bool {
  let standardizedPath = URL(fileURLWithPath: path).standardizedFileURL.path
  if let libraryPath {
    let standardizedLibrary = URL(fileURLWithPath: libraryPath).standardizedFileURL.path
    if standardizedPath == standardizedLibrary
      || standardizedPath.hasPrefix("\(standardizedLibrary)/")
    {
      return true
    }
  }
  return standardizedPath.split(separator: "/").contains { $0.hasSuffix(".photoslibrary") }
}

private func photosPushExifFields(
  for item: PhotosMediaItemRecord,
  requestedFields: [String]
) -> [String] {
  var fields: [String] = []
  func wants(_ field: PhotosPushExifField) -> Bool {
    requestedFields.contains(PhotosPushExifField.all.rawValue)
      || requestedFields.contains(field.rawValue)
  }
  func append(_ field: String) {
    guard !field.isEmpty, !fields.contains(field) else {
      return
    }
    fields.append(field)
  }

  if wants(.title), let title = photosPushExifNonEmpty(item.title) {
    append("XMP:Title=\(title)")
  }
  if wants(.description), let description = photosPushExifNonEmpty(item.description) {
    append("XMP:Description=\(description)")
    append("IPTC:Caption-Abstract=\(description)")
  }
  if wants(.keywords), !item.keywords.isEmpty {
    let keywords = item.keywords.joined(separator: ",")
    append("IPTC:Keywords=\(keywords)")
    append("XMP:Subject=\(keywords)")
  }
  if wants(.persons) || wants(.faces), !item.persons.isEmpty {
    append("XMP:PersonInImage=\(item.persons.joined(separator: ","))")
  }
  if wants(.datetime), let date = item.date {
    let exifDate = photosPushExifDateTimeOriginalString(date)
    append("EXIF:DateTimeOriginal=\(exifDate)")
    append("EXIF:CreateDate=\(exifDate)")
    append("XMP:CreateDate=\(photosPushExifISODateString(date))")
  }
  if wants(.location), let location = item.location {
    append("EXIF:GPSLatitude=\(location.latitude)")
    append("EXIF:GPSLongitude=\(location.longitude)")
    if let altitude = location.altitude {
      append("EXIF:GPSAltitude=\(altitude)")
    }
  }
  if wants(.favorite) {
    append("XMP:Rating=\(item.favorite ? 5 : 0)")
  }
  return fields
}

private func photosPushExifNonEmpty(_ value: String?) -> String? {
  guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
    !trimmed.isEmpty
  else {
    return nil
  }
  return trimmed
}

private func photosPushExifDateTimeOriginalString(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
  return formatter.string(from: date)
}

private func photosPushExifISODateString(_ date: Date) -> String {
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  return formatter.string(from: date)
}

private func photosRequiredExecutableOption(_ name: String, options: CLIOptions) throws -> String {
  let path = try photosRequiredOption(name, options: options)
  guard FileManager.default.isExecutableFile(atPath: path) else {
    throw CLIError(
      code: .backendUnavailable,
      message: "`--\(name)` must point to an executable file.",
      details: ["tool": path]
    )
  }
  return path
}

private func photosRequireExplicitMutationSelector(
  _ query: PhotosQuery,
  commandName: String
) throws {
  let hasSelector =
    query.selected
    || !query.albums.isEmpty
    || !query.folders.isEmpty
    || !query.uuids.isEmpty
    || !query.keywords.isEmpty
    || !query.persons.isEmpty
    || !query.titles.isEmpty
    || !query.descriptions.isEmpty
    || query.noKeyword
    || query.noTitle
    || query.noDescription
    || !query.filenames.isEmpty
    || query.originalPath != nil
    || !query.places.isEmpty
    || query.noPlace
    || query.location != nil
    || query.hasLocation != nil
    || query.label != nil
    || query.regex != nil
    || !query.regexFields.isEmpty
    || query.uti != nil
    || query.mediaType != nil
    || query.dateFrom != nil
    || query.dateTo != nil
    || !query.years.isEmpty
    || query.timeFrom != nil
    || query.timeTo != nil
    || query.dateAddedFrom != nil
    || query.dateAddedTo != nil
    || query.addedAfter != nil
    || query.addedBefore != nil
    || query.addedInLast != nil
    || query.minSize != nil
    || query.maxSize != nil
    || !query.traits.isEmpty
    || !query.excludedTraits.isEmpty
    || query.favorite != nil
    || query.hidden != nil
    || query.shared != nil
    || query.iCloud != nil
    || query.inCloud != nil
    || query.syndicated != nil
    || query.savedToLibrary != nil
    || query.sharedMoment != nil
    || query.sharedLibrary != nil
    || query.hasComment != nil
    || query.hasLikes != nil
    || query.inAlbum != nil
    || query.edited != nil
    || query.externalEdit != nil
    || query.duplicate != nil
    || query.missing != nil
    || !query.exif.isEmpty
  guard hasSelector else {
    throw CLIError(
      code: .validationError,
      message:
        "`\(commandName)` requires `--uuid`, `--uuid-from-file`, `--selected`, or an explicit query selector."
    )
  }
}

private struct PhotosTrackPoint {
  var date: Date
  var location: String
}

private func photosOptionalSignedInt(_ name: String, options: CLIOptions) throws -> Int? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  guard let parsed = Int(value) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` requires an integer value."
    )
  }
  return parsed
}

private func photosValidatedISODateString(_ value: String, optionName: String = "set-date") throws
  -> String
{
  let fractional = ISO8601DateFormatter()
  fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = fractional.date(from: value) {
    return fractional.string(from: date)
  }
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime]
  guard let date = formatter.date(from: value) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(optionName)` requires an ISO-8601 date with timezone."
    )
  }
  return fractional.string(from: date)
}

private func photosTimewarpFields(
  for item: PhotosMediaItemRecord,
  setDate: String?,
  deltaSeconds: Int?,
  timeZoneOffsetSeconds: Int?
) throws -> [String: String] {
  if let setDate {
    return ["date": setDate]
  }
  guard var date = item.date else {
    throw CLIError(
      code: .validationError,
      message: "Cannot timewarp item `\(item.uuid)` because it has no date."
    )
  }
  if let deltaSeconds {
    date = date.addingTimeInterval(TimeInterval(deltaSeconds))
  }
  if let timeZoneOffsetSeconds {
    let currentOffset = item.timeZoneOffsetSeconds ?? 0
    date = date.addingTimeInterval(TimeInterval(timeZoneOffsetSeconds - currentOffset))
  }
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  return ["date": formatter.string(from: date)]
}

private func photosValidatedLocationString(_ value: String) throws -> String {
  let parts = value.split(separator: ",", omittingEmptySubsequences: false)
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
  guard parts.count == 2,
    let latitude = Double(parts[0]),
    let longitude = Double(parts[1]),
    latitude.isFinite,
    longitude.isFinite,
    (-90.0...90.0).contains(latitude),
    (-180.0...180.0).contains(longitude)
  else {
    throw CLIError(
      code: .validationError,
      message: "Location values must be `latitude,longitude` within valid coordinate ranges."
    )
  }
  return "\(latitude),\(longitude)"
}

private func photosReadUTF8File(_ path: String) throws -> String {
  let url = URL(fileURLWithPath: path)
  do {
    return try String(contentsOf: url, encoding: .utf8)
  } catch {
    throw CLIError(
      code: .validationError,
      message: "Could not read UTF-8 file at `\(path)`.",
      details: CLIError.diagnosticDetails(for: error)
    )
  }
}

private func photosTrackPoints(_ text: String) throws -> [PhotosTrackPoint] {
  let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--track-file` is empty.")
  }
  if let data = trimmed.data(using: .utf8),
    let json = try? JSONSerialization.jsonObject(with: data)
  {
    return try photosTrackPoints(fromJSON: json)
  }
  return try trimmed.split(whereSeparator: \.isNewline).map { line in
    let parts = line.split(separator: ",", omittingEmptySubsequences: false)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard parts.count >= 3 else {
      throw CLIError(
        code: .validationError,
        message: "Track CSV rows must be `date,latitude,longitude`."
      )
    }
    return PhotosTrackPoint(
      date: try photosDateFromISO(parts[0], flag: "--track-file"),
      location: try photosValidatedLocationString("\(parts[1]),\(parts[2])")
    )
  }
}

private func photosTrackPoints(fromJSON json: Any) throws -> [PhotosTrackPoint] {
  let rawPoints: [Any]
  if let points = json as? [Any] {
    rawPoints = points
  } else if let object = json as? [String: Any], let points = object["points"] as? [Any] {
    rawPoints = points
  } else {
    throw CLIError(
      code: .validationError,
      message: "Track JSON must be an array or an object with a `points` array."
    )
  }
  return try rawPoints.map { point in
    guard let object = point as? [String: Any] else {
      throw CLIError(code: .validationError, message: "Track points must be JSON objects.")
    }
    let dateText = (object["date"] ?? object["timestamp"]).map(photosSyncString)
    let latitudeText = (object["latitude"] ?? object["lat"]).map(photosSyncString)
    let longitudeText = (object["longitude"] ?? object["lon"]).map(photosSyncString)
    guard let dateText, let latitudeText, let longitudeText else {
      throw CLIError(
        code: .validationError,
        message: "Track points require date, latitude, and longitude."
      )
    }
    return PhotosTrackPoint(
      date: try photosDateFromISO(dateText, flag: "--track-file"),
      location: try photosValidatedLocationString("\(latitudeText),\(longitudeText)")
    )
  }
}

private func photosDateFromISO(_ value: String, flag: String) throws -> Date {
  let fractional = ISO8601DateFormatter()
  fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
  if let date = fractional.date(from: value) {
    return date
  }
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime]
  guard let date = formatter.date(from: value) else {
    throw CLIError(
      code: .validationError,
      message: "`\(flag)` requires ISO-8601 dates with timezone."
    )
  }
  return date
}

private func photosLocationMutationFields(
  for item: PhotosMediaItemRecord,
  explicitLocation: String?,
  trackPoints: [PhotosTrackPoint],
  maxMatchSeconds: Int
) -> (item: PhotosMediaItemRecord, fields: [String: String], skippedReason: String?) {
  if let explicitLocation {
    return (item, ["location": explicitLocation], nil)
  }
  guard let itemDate = item.date else {
    return (item, [:], "missing item date for track match")
  }
  guard
    let match = trackPoints.min(by: {
      abs($0.date.timeIntervalSince(itemDate)) < abs($1.date.timeIntervalSince(itemDate))
    })
  else {
    return (item, [:], "empty track")
  }
  let difference = abs(match.date.timeIntervalSince(itemDate))
  guard difference <= TimeInterval(maxMatchSeconds) else {
    return (item, [:], "no track point within max-match-seconds")
  }
  return (item, ["location": match.location], nil)
}

private func photosSyncSourceRecords(_ text: String) throws -> [String: [String: String]] {
  guard let data = text.data(using: .utf8) else {
    throw CLIError(code: .validationError, message: "`--source-file` must be UTF-8 JSON.")
  }
  let json: Any
  do {
    json = try JSONSerialization.jsonObject(with: data)
  } catch {
    throw CLIError(
      code: .validationError,
      message: "`metadata sync --source-file` must contain JSON."
    )
  }
  if let array = json as? [[String: Any]] {
    return try photosSyncSourceRecords(fromArray: array)
  }
  if let object = json as? [String: Any], let records = object["records"] as? [[String: Any]] {
    return try photosSyncSourceRecords(fromArray: records)
  }
  if let object = json as? [String: Any] {
    var mapped: [String: [String: String]] = [:]
    for (uuid, value) in object {
      guard let fields = value as? [String: Any] else {
        continue
      }
      mapped[uuid] = photosSyncFieldStrings(fields)
    }
    if !mapped.isEmpty {
      return mapped
    }
  }
  throw CLIError(
    code: .validationError,
    message: "`metadata sync --source-file` must contain records with UUID keys."
  )
}

private func photosSyncSourceRecords(fromArray array: [[String: Any]]) throws
  -> [String: [String: String]]
{
  var mapped: [String: [String: String]] = [:]
  for record in array {
    guard let uuid = record["uuid"].map(photosSyncString), !uuid.isEmpty else {
      throw CLIError(code: .validationError, message: "Sync records require `uuid`.")
    }
    var fields = record
    fields.removeValue(forKey: "uuid")
    if let nested = fields["fields"] as? [String: Any] {
      fields.removeValue(forKey: "fields")
      fields.merge(nested) { current, _ in current }
    }
    mapped[uuid] = photosSyncFieldStrings(fields)
  }
  return mapped
}

private func photosSyncFieldStrings(_ fields: [String: Any]) -> [String: String] {
  var result: [String: String] = [:]
  for (key, value) in fields {
    result[key] = photosSyncString(value)
  }
  return result
}

private func photosSyncString(_ value: Any) -> String {
  switch value {
  case let string as String:
    return string
  case let bool as Bool:
    return bool ? "true" : "false"
  case let number as NSNumber:
    return number.stringValue
  case let array as [Any]:
    return array.map(photosSyncString).joined(separator: ",")
  default:
    return String(describing: value)
  }
}

private func photosSyncFields(_ requested: [String]) throws -> [String] {
  let allowed = Set(["title", "description", "keyword", "favorite", "date", "location"])
  let fields = requested.isEmpty ? Array(allowed).sorted() : requested
  let invalid = fields.filter { !allowed.contains($0) }
  if !invalid.isEmpty {
    throw CLIError(
      code: .validationError,
      message: "Unsupported metadata sync field.",
      details: ["fields": invalid.joined(separator: ",")]
    )
  }
  return fields
}

private func photosSyncMutationFields(
  items: [PhotosMediaItemRecord],
  sourceRecords: [String: [String: String]],
  fields: [String]
) -> [(item: PhotosMediaItemRecord, fields: [String: String], skippedReason: String?)] {
  items.map { item in
    guard let source = sourceRecords[item.uuid] else {
      return (item, [:], "no source record")
    }
    var selected: [String: String] = [:]
    for field in fields {
      if let value = source[field], !value.isEmpty {
        selected[field] = value
      }
    }
    return (item, selected, selected.isEmpty ? "no selected source fields" : nil)
  }
}

private func photosSelector(_ options: CLIOptions, name: String, idName: String) throws -> String {
  if let id = options.targetOption(idName), !id.isEmpty {
    return id
  }
  return try photosRequiredOption(name, options: options)
}

private func photosSingleUUID(_ options: CLIOptions) throws -> String {
  let uuids = photosListOption("uuid", options: options)
  guard uuids.count == 1, let uuid = uuids.first else {
    throw CLIError(code: .validationError, message: "`--uuid` must specify exactly one item.")
  }
  return uuid
}

private func photosRequiredList(_ name: String, options: CLIOptions) throws -> [String] {
  let values = photosListOption(name, options: options)
  guard !values.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }
  return values
}

private struct PhotosImportPathPlan {
  var inputPaths: [String]
  var groups: [PhotosImportPathGroup]

  var paths: [String] {
    groups.flatMap(\.paths)
  }

  var groupSummary: String {
    groups
      .map { group in
        [
          photosImportEscape(group.key),
          group.kinds.map(photosImportEscape).joined(separator: ","),
          group.paths.map(photosImportEscape).joined(separator: "\t"),
        ].joined(separator: "\t")
      }
      .joined(separator: "\n")
  }
}

private struct PhotosImportPathGroup {
  var key: String
  var kinds: [String]
  var paths: [String]
}

private func photosImportPathPlan(options: CLIOptions) throws -> PhotosImportPathPlan {
  let rawPaths = try photosRequiredList("path", options: options)
  var inputPaths: [String] = []
  var seenPaths: Set<String> = []
  let fileManager = FileManager.default
  for rawPath in rawPaths {
    let path = URL(fileURLWithPath: (rawPath as NSString).expandingTildeInPath)
      .standardizedFileURL.path
    guard seenPaths.insert(path).inserted else {
      continue
    }
    var isDirectory = ObjCBool(false)
    guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
      throw CLIError(
        code: .notFound,
        message: "Import path was not found.",
        details: ["path": path]
      )
    }
    inputPaths.append(path)
  }

  var groupsByKey: [String: [String]] = [:]
  for path in inputPaths {
    groupsByKey[photosImportGroupKey(path), default: []].append(path)
  }

  let groups = groupsByKey.map { key, paths in
    let sortedPaths = paths.sorted { lhs, rhs in
      photosImportPathSortKey(lhs) < photosImportPathSortKey(rhs)
    }
    return PhotosImportPathGroup(
      key: key,
      kinds: photosImportKinds(for: sortedPaths),
      paths: sortedPaths
    )
  }
  .sorted { lhs, rhs in
    guard let lhsPath = lhs.paths.first, let rhsPath = rhs.paths.first else {
      return lhs.key < rhs.key
    }
    return photosImportPathSortKey(lhsPath) < photosImportPathSortKey(rhsPath)
  }

  return PhotosImportPathPlan(inputPaths: inputPaths, groups: groups)
}

private func photosImportGroupKey(_ path: String) -> String {
  let url = URL(fileURLWithPath: path)
  var isDirectory = ObjCBool(false)
  if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
    isDirectory.boolValue
  {
    return "directory:\(url.path.lowercased())"
  }

  let parent = url.deletingLastPathComponent().standardizedFileURL.path.lowercased()
  var stem = url.deletingPathExtension().lastPathComponent.lowercased()
  stem = photosImportNormalizeEditedStem(stem)
  if stem.hasSuffix("_edited") {
    stem.removeLast("_edited".count)
  }
  if url.pathExtension.lowercased() == "aae" {
    if stem.hasSuffix("_o") {
      stem.removeLast("_o".count)
    }
    stem = stem.replacingOccurrences(
      of: #"^(.+_)o([0-9]{4}.*)$"#,
      with: "$1$2",
      options: .regularExpression
    )
  }
  stem = stem.replacingOccurrences(
    of: #"^(.+_)e([0-9]{4}.*)$"#,
    with: "$1$2",
    options: .regularExpression
  )
  stem = photosImportStripIncrementSuffix(stem)
  return "\(parent)/\(stem)"
}

private func photosImportPathSortKey(_ path: String) -> String {
  let url = URL(fileURLWithPath: path)
  let stem = url.deletingPathExtension().lastPathComponent.lowercased()
  let baseName = stem.split(separator: "_", maxSplits: 1).first.map(String.init) ?? stem
  return [
    url.deletingLastPathComponent().standardizedFileURL.path.lowercased(),
    baseName,
    String(format: "%08d", stem.count),
    String(format: "%02d", photosImportKindPriority(photosImportKind(path))),
    url.lastPathComponent.lowercased(),
  ].joined(separator: "|")
}

private func photosImportKinds(for paths: [String]) -> [String] {
  var seen: Set<String> = []
  var kinds: [String] = []
  for kind in paths.map(photosImportKind) where seen.insert(kind).inserted {
    kinds.append(kind)
  }
  return kinds
}

private func photosImportKind(_ path: String) -> String {
  var isDirectory = ObjCBool(false)
  if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
    isDirectory.boolValue
  {
    return "directory"
  }
  let url = URL(fileURLWithPath: path)
  let stem = url.deletingPathExtension().lastPathComponent.lowercased()
  let ext = url.pathExtension.lowercased()
  if photosImportIsEditedStem(stem) {
    return "edited"
  }
  if ext == "aae" {
    return "aae"
  }
  if photosImportRawExtensions.contains(ext) {
    return "raw"
  }
  if photosImportVideoExtensions.contains(ext) {
    return "video"
  }
  if photosImportImageExtensions.contains(ext) {
    return "image"
  }
  return "file"
}

private func photosImportKindPriority(_ kind: String) -> Int {
  switch kind {
  case "image": 0
  case "raw": 1
  case "video": 2
  case "aae": 3
  case "edited": 4
  case "directory": 5
  default: 6
  }
}

private let photosImportImageExtensions: Set<String> = [
  "jpg", "jpeg", "heic", "heif", "png", "tif", "tiff",
]
private let photosImportRawExtensions: Set<String> = [
  "dng", "raw", "cr2", "cr3", "nef", "arw", "orf", "rw2", "raf", "pef",
]
private let photosImportVideoExtensions: Set<String> = [
  "mov", "mp4", "m4v",
]

private func photosImportIsEditedStem(_ stem: String) -> Bool {
  photosImportNormalizeEditedStem(stem).hasSuffix("_edited")
    || stem.range(of: #"^.+_e[0-9]{4}.*$"#, options: .regularExpression) != nil
}

private func photosImportNormalizeEditedStem(_ stem: String) -> String {
  let middleIncrement = stem.replacingOccurrences(
    of: #"^(.+?)(\s+\([0-9]+\))?_edited$"#,
    with: "$1_edited",
    options: .regularExpression
  )
  if middleIncrement != stem {
    return middleIncrement
  }
  return stem.replacingOccurrences(
    of: #"^(.+?)_edited(\s+\([0-9]+\))$"#,
    with: "$1_edited",
    options: .regularExpression
  )
}

private func photosImportStripIncrementSuffix(_ stem: String) -> String {
  stem.replacingOccurrences(
    of: #"\s+\([0-9]+\)$"#,
    with: "",
    options: .regularExpression
  )
}

private func photosImportEscape(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\t", with: "\\t")
    .replacingOccurrences(of: "\n", with: "\\n")
}

private func photosUpdateSelectionQuery(from options: CLIOptions) throws -> PhotosQuery {
  PhotosQuery(
    libraryPath: options.targetOption("library"),
    albums: photosRepeatedOption("album", options: options),
    folders: photosRepeatedOption("folder", options: options),
    uuids: try photosUUIDList(options: options),
    filenames: photosRepeatedOption("filename", options: options),
    originalPath: options.targetOption("original-path"),
    mediaType: options.targetOption("media-type"),
    dateFrom: options.targetOption("date-from"),
    dateTo: options.targetOption("date-to"),
    years: photosListOption("year", options: options).compactMap(Int.init),
    dateAddedFrom: options.targetOption("date-added-from"),
    dateAddedTo: options.targetOption("date-added-to"),
    addedAfter: options.targetOption("added-after"),
    addedBefore: options.targetOption("added-before"),
    addedInLast: options.targetOption("added-in-last"),
    selected: options.hasTargetFlag("selected"),
    limit: options.limit
  )
}

private func photosRequireUpdateSelector(_ query: PhotosQuery) throws {
  let hasSelector =
    query.selected
    || !query.uuids.isEmpty
    || !query.albums.isEmpty
    || !query.folders.isEmpty
    || !query.filenames.isEmpty
    || query.originalPath != nil
    || query.mediaType != nil
    || query.dateFrom != nil
    || query.dateTo != nil
    || !query.years.isEmpty
    || query.dateAddedFrom != nil
    || query.dateAddedTo != nil
    || query.addedAfter != nil
    || query.addedBefore != nil
    || query.addedInLast != nil
  guard hasSelector else {
    throw CLIError(
      code: .validationError,
      message:
        "`media-items update` requires `--uuid`, `--uuid-from-file`, `--selected`, or an explicit query selector."
    )
  }
}

private func photosUpdateQuerySupportsUndo(_ query: PhotosQuery) -> Bool {
  query.uuids.count == 1
    && !query.selected
    && query.albums.isEmpty
    && query.folders.isEmpty
    && query.filenames.isEmpty
    && query.originalPath == nil
    && query.mediaType == nil
    && query.dateFrom == nil
    && query.dateTo == nil
    && query.years.isEmpty
    && query.dateAddedFrom == nil
    && query.dateAddedTo == nil
    && query.addedAfter == nil
    && query.addedBefore == nil
    && query.addedInLast == nil
}

private func photosSingleUpdateUndoUUID(_ query: PhotosQuery) throws -> String {
  guard photosUpdateQuerySupportsUndo(query), let uuid = query.uuids.first else {
    throw CLIError(
      code: .validationError,
      message: "`--state-db` undo tracking requires exactly one explicit `--uuid` selector."
    )
  }
  return uuid
}

private func photosMutationFields(_ options: CLIOptions) throws -> [String: String] {
  var fields: [String: String] = [:]
  for name in ["title", "description", "album-id"] {
    if let value = options.targetOption(name) {
      fields[name] = value
    }
  }
  let keywords = photosListOption("keyword", options: options)
  let addedKeywords = photosListOption("add-keyword", options: options)
  if !keywords.isEmpty && !addedKeywords.isEmpty {
    throw CLIError(
      code: .validationError,
      message: "`--keyword` and `--add-keyword` cannot be used together."
    )
  }
  if !keywords.isEmpty {
    fields["keyword"] = keywords.joined(separator: ",")
  }
  if !addedKeywords.isEmpty {
    fields["add-keyword"] = addedKeywords.joined(separator: ",")
  }
  if let date = options.targetOption("date") {
    fields["date"] = try photosValidatedISODateString(date, optionName: "date")
  }
  if let location = options.targetOption("location") {
    fields["location"] = try photosValidatedLocationString(location)
  }
  if options.hasTargetFlag("favorite") && options.hasTargetFlag("clear-favorite") {
    throw CLIError(
      code: .validationError,
      message: "`--favorite` and `--clear-favorite` cannot be used together."
    )
  }
  if options.hasTargetFlag("favorite") {
    fields["favorite"] = "true"
  }
  if options.hasTargetFlag("clear-favorite") {
    fields["favorite"] = "false"
  }
  if options.hasTargetFlag("hidden") {
    fields["hidden"] = "true"
  }
  return fields
}

private func photosResolvedMutationFields(
  _ fields: [String: String],
  for item: PhotosMediaItemRecord
) throws -> [String: String] {
  var resolved = fields
  if let additions = fields["add-keyword"] {
    var keywords = item.keywords
    for keyword in photosMutationList(additions) where !keywords.contains(keyword) {
      keywords.append(keyword)
    }
    resolved["keyword"] = keywords.joined(separator: ",")
    resolved.removeValue(forKey: "add-keyword")
  }
  return resolved
}

private func photosMutationList(_ value: String) -> [String] {
  value
    .split(whereSeparator: { $0 == "," || $0 == "\n" })
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
}

private struct PhotosMediaItemUndoDatabase: Codable {
  var schemaVersion: Int = 1
  var entries: [PhotosMediaItemUndoEntry] = []
}

private struct PhotosMediaItemUndoEntry: Codable {
  var id: String
  var createdAt: Date
  var uuid: String
  var previousFields: [String: String]
  var updatedFields: [String: String]
}

private func photosUndoFields(
  from item: PhotosMediaItemRecord,
  changedFields: [String: String]
) throws -> [String: String] {
  var fields: [String: String] = [:]
  for key in changedFields.keys.sorted() {
    switch key {
    case "title":
      fields[key] = item.title ?? ""
    case "description":
      fields[key] = item.description ?? ""
    case "keyword":
      fields[key] = item.keywords.joined(separator: ",")
    case "favorite":
      fields[key] = item.favorite ? "true" : "false"
    case "hidden":
      fields[key] = item.hidden ? "true" : "false"
    case "date":
      guard let date = item.date else {
        throw CLIError(
          code: .validationError,
          message: "Cannot record undo for `--date` because the media item has no previous date."
        )
      }
      fields[key] = ISO8601DateFormatter().string(from: date)
    case "location":
      guard let location = item.location else {
        throw CLIError(
          code: .validationError,
          message:
            "Cannot record undo for `--location` because the media item has no previous location."
        )
      }
      fields[key] = "\(location.latitude),\(location.longitude)"
    default:
      break
    }
  }
  return fields
}

private func photosAppendMediaItemUndoEntry(
  stateDBPath: String,
  uuid: String,
  previousFields: [String: String],
  updatedFields: [String: String]
) throws -> String {
  let url = URL(fileURLWithPath: stateDBPath)
  var database = try photosReadMediaItemUndoDatabase(at: url)
  let entry = PhotosMediaItemUndoEntry(
    id: UUID().uuidString.lowercased(),
    createdAt: Date(),
    uuid: uuid,
    previousFields: previousFields,
    updatedFields: updatedFields
  )
  database.entries.append(entry)
  try FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  let data = try JSONEncoder().encode(database)
  try data.write(to: url, options: .atomic)
  return entry.id
}

private func photosMediaItemUndoEntry(
  stateDBPath: String,
  undoID: String?
) throws -> PhotosMediaItemUndoEntry {
  let database = try photosReadMediaItemUndoDatabase(at: URL(fileURLWithPath: stateDBPath))
  let entry: PhotosMediaItemUndoEntry?
  if let undoID, !undoID.isEmpty {
    entry = database.entries.last { $0.id == undoID }
  } else {
    entry = database.entries.last
  }
  guard let entry else {
    throw CLIError(
      code: .validationError,
      message: "No media item undo entry was found in `--state-db`."
    )
  }
  guard !entry.previousFields.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "The selected media item undo entry has no restorable fields."
    )
  }
  return entry
}

private func photosReadMediaItemUndoDatabase(at url: URL) throws -> PhotosMediaItemUndoDatabase {
  guard FileManager.default.fileExists(atPath: url.path) else {
    return PhotosMediaItemUndoDatabase()
  }
  let data = try Data(contentsOf: url)
  return try JSONDecoder().decode(PhotosMediaItemUndoDatabase.self, from: data)
}

private func photosDatabaseInfoHuman(_ library: PhotosLibraryRecord) -> String {
  [
    ("Database path", library.databasePath),
    ("Photos version", library.photosVersion),
    ("DB version", library.databaseVersion),
    ("Model version", library.modelVersion),
  ]
  .compactMap { label, value in value.map { "\(label): \($0)" } }
  .joined(separator: "\n")
}

private func photosExifReportHuman(_ items: [PhotosExifItemReport]) -> String {
  items
    .flatMap { item in
      item.values.sorted { $0.key < $1.key }.map { key, value in
        "\(item.uuid)\t\(key)=\(value)"
      }
    }
    .joined(separator: "\n")
}

private func photosDumpRecord(
  for item: PhotosMediaItemRecord,
  maxBytes: Int
) -> PhotosMediaItemDumpRecord {
  let traits = Set(item.traits)
  return PhotosMediaItemDumpRecord(
    uuid: item.uuid,
    filename: photosDumpRequiredText(item.filename, maxBytes: maxBytes),
    originalFilename: photosDumpRequiredText(item.filename, maxBytes: maxBytes),
    date: photosDumpDate(item.date),
    description: photosDumpText(item.description, maxBytes: maxBytes),
    title: photosDumpText(item.title, maxBytes: maxBytes),
    keywords: item.keywords.map { photosDumpRequiredText($0, maxBytes: maxBytes) },
    albums: item.albumIDs.map { photosDumpRequiredText($0, maxBytes: maxBytes) },
    persons: item.persons.map { photosDumpRequiredText($0, maxBytes: maxBytes) },
    path: photosDumpText(item.originalPath, maxBytes: maxBytes),
    isMissing: item.missingState ?? (item.originalPath == nil),
    hasAdjustments: item.edited,
    externalEdit: item.externalEdit,
    favorite: item.favorite,
    hidden: item.hidden,
    shared: item.shared,
    latitude: item.location?.latitude,
    longitude: item.location?.longitude,
    pathEdited: photosDumpText(item.editedPath, maxBytes: maxBytes),
    isPhoto: item.mediaType == "image",
    isMovie: item.mediaType == "video",
    uti: photosDumpText(item.uti, maxBytes: maxBytes),
    burst: traits.contains("burst"),
    livePhoto: traits.contains("live"),
    pathLivePhoto: photosDumpText(item.livePhotoMoviePath, maxBytes: maxBytes),
    isCloudAsset: item.iCloud,
    inCloud: item.inCloud,
    dateModified: nil,
    portrait: traits.contains("portrait"),
    screenshot: traits.contains("screenshot"),
    screenRecording: traits.contains("screen-recording"),
    slowMo: traits.contains("slow-mo"),
    timeLapse: traits.contains("time-lapse"),
    hdr: traits.contains("hdr"),
    selfie: traits.contains("selfie"),
    panorama: traits.contains("panorama"),
    hasRaw: traits.contains("raw"),
    utiRaw: photosDumpText(item.rawUTI, maxBytes: maxBytes),
    pathRaw: photosDumpText(item.rawPath, maxBytes: maxBytes),
    inTrash: false
  )
}

private func photosSingleInspectionItem(
  _ items: [PhotosMediaItemRecord],
  query: PhotosQuery
) throws -> PhotosMediaItemRecord {
  if items.count == 1, let item = items.first {
    return item
  }
  if items.isEmpty {
    throw CLIError(
      code: .notFound,
      message: "Photos media item was not found.",
      details: photosQuerySummary(query)
    )
  }
  throw CLIError(
    code: .ambiguousIdentity,
    message: "Photos media item identity is ambiguous.",
    details: photosQuerySummary(query).merging(["matches": "\(items.count)"]) { current, _ in
      current
    }
  )
}

private func photosInspectionText(
  item: PhotosMediaItemRecord,
  dump: PhotosMediaItemDumpRecord
) -> String {
  [
    "UUID: \(item.uuid)",
    "Filename: \(item.filename)",
    "Type: \(item.mediaType)",
    "Date: \(dump.date ?? "-")",
    "Title: \(item.title ?? "-")",
    "Description: \(item.description ?? "-")",
    "Keywords: \(item.keywords.isEmpty ? "-" : item.keywords.joined(separator: ", "))",
    "Persons: \(item.persons.isEmpty ? "-" : item.persons.joined(separator: ", "))",
    "Albums: \(item.albumIDs.isEmpty ? "-" : item.albumIDs.joined(separator: ", "))",
    "Path: \(item.originalPath ?? "-")",
  ].joined(separator: "\n")
}

private func photosDumpText(_ value: String?, maxBytes: Int) -> String? {
  guard let value else {
    return nil
  }
  return photosDumpRequiredText(value, maxBytes: maxBytes)
}

private func photosDumpRequiredText(_ value: String, maxBytes: Int) -> String {
  return photosTruncate(value, maxBytes: maxBytes).0
}

private func photosDumpDate(_ date: Date?) -> String? {
  date.map { ISO8601DateFormatter().string(from: $0) }
}

private func photosDumpCSV(_ records: [PhotosMediaItemDumpRecord]) throws -> String {
  let columns = PhotosMediaItemDumpRecord.CodingKeys.allCases.map(\.rawValue).sorted()
  let values = try records.map { record in
    let data = try JSONEncoder().encode(record)
    guard let fields = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw CLIError(code: .internalError, message: "Photos could not serialize the dump record.")
    }
    return try columns.map { column -> String in
      guard let value = fields[column] else { return "" }
      if let text = value as? String { return text }
      if let entries = value as? [String] { return entries.joined(separator: ", ") }
      let scalar = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
      return String(decoding: scalar, as: UTF8.self)
    }
  }
  let rows = [columns] + values
  return rows.map { row in
    row.map(photosCSVField).joined(separator: ",")
  }.joined(separator: "\n")
}

private func photosCSVField(_ value: String) -> String {
  if value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r") {
    return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
  }
  return value
}

private func photosHookSource(_ options: CLIOptions) throws -> String {
  if let source = options.targetOption("source"), !source.isEmpty {
    return source
  }
  if let path = options.targetOption("source-file"), !path.isEmpty {
    return try String(contentsOfFile: path, encoding: .utf8)
  }
  throw CLIError(code: .validationError, message: "`--source` or `--source-file` is required.")
}

private func photosOptionalTargetOption(_ name: String, options: CLIOptions) throws -> String? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  return trimmed
}

private func photosNonEmptyPlanOption(_ name: String, in options: [String: String]) -> String? {
  guard let value = options[name]?.trimmingCharacters(in: .whitespacesAndNewlines),
    !value.isEmpty
  else {
    return nil
  }
  return value
}

private func photosCanonicalDictionary(_ values: [String: String]) -> String {
  values.sorted { $0.key < $1.key }
    .map { "\($0.key)=\($0.value)" }
    .joined(separator: "|")
}

private func validatePhotosXattrTemplate(_ value: String) throws {
  guard let separator = value.firstIndex(of: "="), separator > value.startIndex else {
    throw CLIError(
      code: .validationError,
      message: "`--xattr-template` must use `name=template`."
    )
  }
  let name = String(value[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
  try validatePhotosXattrName(name)
}

private func validatePhotosXattrName(_ name: String) throws {
  guard !name.isEmpty, name.count <= 128,
    name.range(of: #"^[A-Za-z0-9._:-]+$"#, options: .regularExpression) != nil
  else {
    throw CLIError(
      code: .validationError,
      message: "Photos xattr names may contain only letters, digits, `.`, `_`, `:`, and `-`."
    )
  }
  if name == "com.apple.quarantine" {
    throw CLIError(
      code: .validationError,
      message: "`com.apple.quarantine` is not an accepted Photos metadata xattr target."
    )
  }
}
