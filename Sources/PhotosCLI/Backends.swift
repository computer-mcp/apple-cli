import Foundation
import Utility

public struct PhotosCompositeBackend: PhotosAutomating {
  private let snapshotBackend: PhotosLibrarySnapshotBackend
  private let hookBackend: PhotosHookBackend
  private let fileBackend: PhotosFileBackend
  private let appleScriptBackend: PhotosAppleScriptBackend

  public init(
    snapshotBackend: PhotosLibrarySnapshotBackend = PhotosLibrarySnapshotBackend(),
    hookBackend: PhotosHookBackend = PhotosHookBackend(),
    fileBackend: PhotosFileBackend = PhotosFileBackend(),
    appleScriptBackend: PhotosAppleScriptBackend = PhotosAppleScriptBackend()
  ) {
    self.snapshotBackend = snapshotBackend
    self.hookBackend = hookBackend
    self.fileBackend = fileBackend
    self.appleScriptBackend = appleScriptBackend
  }

  public func listLibraries() throws -> [PhotosLibraryRecord] {
    try snapshotBackend.listLibraries()
  }

  public func libraryInfo(path: String?) throws -> PhotosLibraryRecord {
    try snapshotBackend.libraryInfo(path: path)
  }

  public func databaseInfo(path: String?) throws -> PhotosLibraryRecord {
    try snapshotBackend.databaseInfo(path: path)
  }

  public func compareLibraries(
    libraryA: String?,
    libraryB: String,
    signatureTemplate: String?
  ) throws -> PhotosLibraryCompareReport {
    let resolvedLibraryA: String
    if let libraryA {
      resolvedLibraryA = libraryA
    } else {
      resolvedLibraryA = try snapshotBackend.libraryInfo(path: nil).path
    }
    let itemsA = try snapshotBackend.listMediaItems(
      query: PhotosQuery(libraryPath: libraryA, limit: nil)
    )
    let itemsB = try snapshotBackend.listMediaItems(
      query: PhotosQuery(libraryPath: libraryB, limit: nil)
    )
    return photosCompareLibraries(
      libraryA: resolvedLibraryA,
      libraryB: libraryB,
      itemsA: itemsA,
      itemsB: itemsB,
      signatureTemplate: signatureTemplate
    )
  }

  public func openLibrary(path: String) throws -> Bool {
    try appleScriptBackend.openLibrary(path: path)
  }

  public func backupLibrary(path: String?, destination: String) throws -> Bool {
    try fileBackend.backupLibrary(
      source: try snapshotBackend.resolveLibraryPath(path),
      destination: destination
    )
  }

  public func listAlbums(query: PhotosQuery) throws -> [PhotosAlbumRecord] {
    try snapshotBackend.listAlbums(query: query)
  }

  public func readAlbum(idOrName: String, query: PhotosQuery, includeItems: Bool) throws
    -> PhotosAlbumRecord
  {
    try snapshotBackend.readAlbum(idOrName: idOrName, query: query, includeItems: includeItems)
  }

  public func createAlbum(name: String, parentFolderID: String?) throws -> PhotosAlbumRecord {
    try appleScriptBackend.createAlbum(name: name, parentFolderID: parentFolderID)
  }

  public func deleteAlbum(idOrName: String) throws -> Bool {
    try appleScriptBackend.deleteAlbum(idOrName: idOrName)
  }

  public func addItemsToAlbum(albumIDOrName: String, itemUUIDs: [String]) throws -> Bool {
    try appleScriptBackend.addItemsToAlbum(albumIDOrName: albumIDOrName, itemUUIDs: itemUUIDs)
  }

  public func listFolders(query: PhotosQuery) throws -> [PhotosFolderRecord] {
    try snapshotBackend.listFolders(query: query)
  }

  public func readFolder(idOrName: String, query: PhotosQuery, includeChildren: Bool) throws
    -> PhotosFolderRecord
  {
    try snapshotBackend.readFolder(
      idOrName: idOrName, query: query, includeChildren: includeChildren)
  }

  public func createFolder(name: String, parentFolderID: String?) throws -> PhotosFolderRecord {
    try appleScriptBackend.createFolder(name: name, parentFolderID: parentFolderID)
  }

  public func deleteFolder(idOrName: String) throws -> Bool {
    try appleScriptBackend.deleteFolder(idOrName: idOrName)
  }

  public func listMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    try mediaItems(matching: query)
  }

  public func searchMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    try mediaItems(matching: query)
  }

  public func readMediaItem(uuid: String, query: PhotosQuery, include: Set<String>, maxBytes: Int)
    throws
    -> PhotosMediaItemRecord
  {
    try snapshotBackend.readMediaItem(uuid: uuid, query: query)
  }

  public func updateMediaItem(uuid: String, fields: [String: String]) throws
    -> PhotosMediaItemRecord
  {
    try appleScriptBackend.updateMediaItem(uuid: uuid, fields: fields)
  }

  public func duplicateMediaItem(uuid: String) throws -> PhotosMediaItemRecord {
    try appleScriptBackend.duplicateMediaItem(uuid: uuid)
  }

  public func listSelection(limit: Int?) throws -> [PhotosMediaItemRecord] {
    try appleScriptBackend.listSelection(limit: limit)
  }

  public func importItems(paths: [String], albumIDOrName: String?, skipDuplicateCheck: Bool) throws
    -> [PhotosMediaItemRecord]
  {
    try appleScriptBackend.importItems(
      paths: paths,
      albumIDOrName: albumIDOrName,
      skipDuplicateCheck: skipDuplicateCheck
    )
  }

  public func exportItems(plan: PhotosExportPlan) throws -> PhotosExportResult {
    let items = try mediaItems(matching: plan.query)
    let fileResult = try fileBackend.exportItems(items: items, plan: plan)
    if fileResult.missing == 0 || items.isEmpty || plan.options["using_originals"] == "true" {
      try runExportLifecycleHooks(plan: plan, items: items, result: fileResult)
      return fileResult
    }
    let appResult = try appleScriptBackend.exportItems(
      uuids: items.map(\.uuid),
      destination: plan.destination,
      usingOriginals: plan.options["using_originals"] == "true"
    )
    try runExportLifecycleHooks(plan: plan, items: items, result: appResult)
    return appResult
  }

  public func exportReport(stateDB: String?, runID: String?) throws -> PhotosExportReport {
    try fileBackend.exportReport(stateDB: stateDB, runID: runID)
  }

  public func metadataValues(kind: String, query: PhotosQuery) throws -> PhotosMetadataAggregate {
    if query.selected {
      return photosMetadataAggregate(kind: kind, items: try mediaItems(matching: query))
    }
    return try snapshotBackend.metadataValues(kind: kind, query: query)
  }

  public func writeSidecar(
    format: String,
    query: PhotosQuery,
    destination: String,
    template: String?
  ) throws -> Bool {
    try fileBackend.writeSidecar(
      format: format,
      items: try mediaItems(matching: query),
      query: query,
      destination: destination,
      template: template
    )
  }

  public func writeExif(
    fields: [String],
    query: PhotosQuery,
    destination: String?,
    exiftoolPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> Bool {
    try fileBackend.writeExifPlan(
      fields: fields,
      items: try mediaItems(matching: query),
      query: query,
      destination: destination,
      exiftoolPath: exiftoolPath,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
  }

  public func queryDatabase(query: PhotosQuery, rawSQL: String?) throws -> [[String: String]] {
    if rawSQL == nil, query.selected {
      return try mediaItems(matching: query).map { item in
        [
          "uuid": item.uuid,
          "filename": item.filename,
          "title": item.title ?? "",
          "media_type": item.mediaType,
        ]
      }
    }
    return try snapshotBackend.queryDatabase(query: query, rawSQL: rawSQL)
  }

  public func grepDatabase(
    query: PhotosQuery,
    pattern: String,
    ignoreCase: Bool,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseGrepMatch] {
    try snapshotBackend.grepDatabase(
      query: query,
      pattern: pattern,
      ignoreCase: ignoreCase,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
  }

  public func debugDumpDatabase(
    query: PhotosQuery,
    sections: [String],
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseDebugDumpSection] {
    let deadline = Date().addingTimeInterval(TimeInterval(timeoutSeconds))
    return try sections.map { section in
      try photosCheckDebugDumpDeadline(deadline, timeoutSeconds: timeoutSeconds)
      let normalized = section.lowercased()
      switch normalized {
      case "photos":
        let records = try mediaItems(matching: query).map {
          photosDebugRecord(for: $0, outputCap: outputCap)
        }
        return PhotosDatabaseDebugDumpSection(
          name: normalized,
          records: records.map(\.values),
          truncated: records.contains { $0.truncated }
        )
      case "albums":
        let records = try snapshotBackend.listAlbums(query: query).map {
          photosDebugRecord(for: $0, outputCap: outputCap)
        }
        return PhotosDatabaseDebugDumpSection(
          name: normalized,
          records: records.map(\.values),
          truncated: records.contains { $0.truncated }
        )
      case "folders":
        let records = try snapshotBackend.listFolders(query: query).map {
          photosDebugRecord(for: $0, outputCap: outputCap)
        }
        return PhotosDatabaseDebugDumpSection(
          name: normalized,
          records: records.map(\.values),
          truncated: records.contains { $0.truncated }
        )
      case "keywords", "persons", "places", "labels":
        let aggregate = try metadataValues(kind: normalized, query: query)
        let records = aggregate.values.map { value in
          photosCappedRecord(
            [
              "value": value,
              "count": "\(aggregate.counts[value] ?? 0)",
            ], outputCap: outputCap)
        }
        return PhotosDatabaseDebugDumpSection(
          name: normalized,
          records: records.map(\.values),
          truncated: records.contains { $0.truncated }
        )
      default:
        throw CLIError(
          code: .validationError,
          message: "Unsupported Photos debug-dump section.",
          details: ["section": section]
        )
      }
    }
  }

  public func findDatabaseOrphans(
    query: PhotosQuery,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosDatabaseOrphansReport {
    try snapshotBackend.findDatabaseOrphans(
      query: query,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
  }

  public func renderTemplate(template: String, query: PhotosQuery) throws -> [String] {
    let items = try mediaItems(matching: query)
    return items.map { item in
      photosRenderTemplate(template, item: item)
    }
  }

  public func runHook(
    kind: String, source: String, input: PhotoHookInput, timeoutSeconds: Int, outputCap: Int
  )
    throws -> PhotoHookOutput
  {
    try hookBackend.runHook(
      kind: kind,
      source: source,
      input: input,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
  }

  public func runPostCommand(
    command: String,
    category: String,
    input: PhotoHookInput,
    timeoutSeconds: Int,
    outputCap: Int
  )
    throws -> PhotosActionResult
  {
    try hookBackend.runPostCommand(
      command: command,
      category: category,
      input: input,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
  }

  public func slideshowRunning() throws -> Bool {
    try appleScriptBackend.slideshowRunning()
  }

  public func slideshow(action: String, query: PhotosQuery) throws -> Bool {
    try appleScriptBackend.slideshow(action: action, query: query)
  }

  public func showSpotlight(selector: String) throws -> Bool {
    try appleScriptBackend.showSpotlight(selector: selector)
  }

  private func mediaItems(matching query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    if query.selected {
      return photosApplyQuery(query: query, to: try appleScriptBackend.listSelection(limit: nil))
    }
    return try snapshotBackend.listMediaItems(query: query)
  }

  private func runExportLifecycleHooks(
    plan: PhotosExportPlan,
    items: [PhotosMediaItemRecord],
    result: PhotosExportResult
  ) throws {
    let postFunctionSource = photosNonEmptyExportOption("post_function_source", in: plan.options)
    let postCommand = photosNonEmptyExportOption("post_command", in: plan.options)
    guard postFunctionSource != nil || postCommand != nil else {
      return
    }

    let timeoutSeconds = try photosExportLifecycleIntOption(
      "post_timeout_seconds",
      in: plan.options,
      defaultValue: 10,
      maximum: 300
    )
    let outputCap = try photosExportLifecycleIntOption(
      "post_output_cap",
      in: plan.options,
      defaultValue: 64 * 1024,
      maximum: 4 * 1024 * 1024
    )
    let category = photosNonEmptyExportOption("post_category", in: plan.options) ?? "export"
    var hookPlanOptions = plan.options
    hookPlanOptions.removeValue(forKey: "post_function_source")
    hookPlanOptions.removeValue(forKey: "post_command")
    let input = PhotoHookInput(
      category: category,
      photos: items,
      exportPlan: PhotosExportPlan(
        query: plan.query,
        destination: plan.destination,
        options: hookPlanOptions
      ),
      context: [
        "destination": result.destination,
        "exported": String(result.exported),
        "missing": String(result.missing),
        "report_path": result.reportPath ?? "",
        "skipped": String(result.skipped),
      ]
    )

    if let postFunctionSource {
      _ = try hookBackend.runHook(
        kind: "post",
        source: postFunctionSource,
        input: input,
        timeoutSeconds: timeoutSeconds,
        outputCap: outputCap
      )
    }
    if let postCommand {
      _ = try hookBackend.runPostCommand(
        command: postCommand,
        category: category,
        input: input,
        timeoutSeconds: timeoutSeconds,
        outputCap: outputCap
      )
    }
  }
}

private func photosNonEmptyExportOption(_ name: String, in options: [String: String]) -> String? {
  guard let value = options[name]?.trimmingCharacters(in: .whitespacesAndNewlines),
    !value.isEmpty
  else {
    return nil
  }
  return value
}

private func photosExportLifecycleIntOption(
  _ name: String,
  in options: [String: String],
  defaultValue: Int,
  maximum: Int
) throws -> Int {
  guard let rawValue = photosNonEmptyExportOption(name, in: options) else {
    return defaultValue
  }
  let flagName = "--\(name.replacingOccurrences(of: "_", with: "-"))"
  let parsed = try photosPositiveInt(rawValue, flag: flagName)
  guard parsed <= maximum else {
    throw CLIError(
      code: .validationError,
      message: "`\(flagName)` cannot exceed \(maximum)."
    )
  }
  return parsed
}

private func photosMetadataAggregate(
  kind: String,
  items: [PhotosMediaItemRecord]
) -> PhotosMetadataAggregate {
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
        ? item.placeName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "_UNKNOWN_"
        : "_UNKNOWN_"
      counts[value.isEmpty ? "_UNKNOWN_" : value, default: 0] += 1
    }
  default:
    break
  }
  let values = counts.keys.sorted { left, right in
    left.localizedStandardCompare(right) == .orderedAscending
  }
  return PhotosMetadataAggregate(values: values, counts: counts)
}

private func photosDebugRecord(
  for item: PhotosMediaItemRecord,
  outputCap: Int
) -> PhotosDebugRecord {
  photosCappedRecord(
    [
      "uuid": item.uuid,
      "filename": item.filename,
      "title": item.title ?? "",
      "description": item.description ?? "",
      "media_type": item.mediaType,
      "favorite": "\(item.favorite)",
      "hidden": "\(item.hidden)",
      "date": item.date.map { ISO8601DateFormatter().string(from: $0) } ?? "",
      "date_added": item.dateAdded.map { ISO8601DateFormatter().string(from: $0) } ?? "",
      "keywords": item.keywords.joined(separator: ","),
      "persons": item.persons.joined(separator: ","),
      "albums": item.albumIDs.joined(separator: ","),
      "folders": item.folderPaths.joined(separator: ","),
      "traits": item.traits.joined(separator: ","),
    ], outputCap: outputCap)
}

private func photosDebugRecord(
  for album: PhotosAlbumRecord,
  outputCap: Int
) -> PhotosDebugRecord {
  photosCappedRecord(
    [
      "id": album.id,
      "name": album.name,
      "parent_id": album.parentID ?? "",
      "item_count": album.itemCount.map(String.init) ?? "",
    ], outputCap: outputCap)
}

private func photosDebugRecord(
  for folder: PhotosFolderRecord,
  outputCap: Int
) -> PhotosDebugRecord {
  photosCappedRecord(
    [
      "id": folder.id,
      "name": folder.name,
      "parent_id": folder.parentID ?? "",
      "child_count": folder.childCount.map(String.init) ?? "",
    ], outputCap: outputCap)
}

private struct PhotosDebugRecord {
  var values: [String: String]
  var truncated: Bool
}

private func photosCappedRecord(
  _ record: [String: String],
  outputCap: Int
) -> PhotosDebugRecord {
  var truncated = false
  let values = record.mapValues { value in
    let capped = photosTruncate(value, maxBytes: outputCap)
    truncated = truncated || capped.1
    return capped.0
  }
  return PhotosDebugRecord(values: values, truncated: truncated)
}

private func photosCheckDebugDumpDeadline(_ deadline: Date, timeoutSeconds: Int) throws {
  guard Date() <= deadline else {
    throw CLIError(
      code: .timeout,
      message: "Photos database debug dump timed out.",
      details: ["timeout_seconds": "\(timeoutSeconds)"]
    )
  }
}

private func photosCompareLibraries(
  libraryA: String,
  libraryB: String,
  itemsA: [PhotosMediaItemRecord],
  itemsB: [PhotosMediaItemRecord],
  signatureTemplate: String?
) -> PhotosLibraryCompareReport {
  let groupedA = Dictionary(grouping: itemsA) {
    photosCompareSignature($0, template: signatureTemplate)
  }
  let groupedB = Dictionary(grouping: itemsB) {
    photosCompareSignature($0, template: signatureTemplate)
  }
  let signatures = Set(groupedA.keys).union(groupedB.keys).sorted()

  var onlyInA: [PhotosLibraryCompareEntry] = []
  var onlyInB: [PhotosLibraryCompareEntry] = []
  var same: [PhotosLibraryComparePair] = []
  var different: [PhotosLibraryComparePair] = []

  for signature in signatures {
    var remainingA = (groupedA[signature] ?? []).sorted { $0.uuid < $1.uuid }
    var remainingB = (groupedB[signature] ?? []).sorted { $0.uuid < $1.uuid }

    if remainingB.isEmpty {
      onlyInA += remainingA.map { photosCompareEntry($0, signature: signature) }
      continue
    }
    if remainingA.isEmpty {
      onlyInB += remainingB.map { photosCompareEntry($0, signature: signature) }
      continue
    }

    for itemA in remainingA {
      if let matchIndex = remainingB.firstIndex(where: { $0.uuid == itemA.uuid }) {
        let itemB = remainingB.remove(at: matchIndex)
        let pair = photosComparePair(itemA, itemB, signature: signature)
        if pair.differences.isEmpty {
          same.append(pair)
        } else {
          different.append(pair)
        }
      }
    }
    remainingA.removeAll { itemA in
      same.contains { $0.uuidA == itemA.uuid && $0.signature == signature }
        || different.contains { $0.uuidA == itemA.uuid && $0.signature == signature }
    }

    while !remainingA.isEmpty && !remainingB.isEmpty {
      let itemA = remainingA.removeFirst()
      let itemB = remainingB.removeFirst()
      let pair = photosComparePair(itemA, itemB, signature: signature)
      if pair.differences.isEmpty {
        same.append(pair)
      } else {
        different.append(pair)
      }
    }

    onlyInA += remainingA.map { photosCompareEntry($0, signature: signature) }
    onlyInB += remainingB.map { photosCompareEntry($0, signature: signature) }
  }

  return PhotosLibraryCompareReport(
    libraryA: libraryA,
    libraryB: libraryB,
    onlyInA: onlyInA.sorted { $0.signature < $1.signature },
    onlyInB: onlyInB.sorted { $0.signature < $1.signature },
    same: same.sorted { $0.signature < $1.signature },
    different: different.sorted { $0.signature < $1.signature }
  )
}

private func photosCompareSignature(_ item: PhotosMediaItemRecord, template: String?) -> String {
  if let template, !template.isEmpty {
    return photosRenderTemplate(template, item: item)
  }
  return [
    item.filename.lowercased(),
    item.date.map { ISO8601DateFormatter().string(from: $0) } ?? "",
    item.width.map(String.init) ?? "",
    item.height.map(String.init) ?? "",
    item.fileSize.map(String.init) ?? "",
    item.originalUTI ?? item.uti ?? "",
    item.mediaType,
  ].joined(separator: "|")
}

private func photosCompareEntry(
  _ item: PhotosMediaItemRecord,
  signature: String
) -> PhotosLibraryCompareEntry {
  PhotosLibraryCompareEntry(uuid: item.uuid, filename: item.filename, signature: signature)
}

private func photosComparePair(
  _ itemA: PhotosMediaItemRecord,
  _ itemB: PhotosMediaItemRecord,
  signature: String
) -> PhotosLibraryComparePair {
  PhotosLibraryComparePair(
    uuidA: itemA.uuid,
    uuidB: itemB.uuid,
    filename: itemA.filename,
    signature: signature,
    differences: photosCompareDifferences(itemA, itemB)
  )
}

private func photosCompareDifferences(
  _ a: PhotosMediaItemRecord,
  _ b: PhotosMediaItemRecord
) -> [String] {
  var differences: [String] = []
  photosCompare(a.title, b.title, "title", into: &differences)
  photosCompare(a.description, b.description, "description", into: &differences)
  photosCompare(a.mediaType, b.mediaType, "media_type", into: &differences)
  photosCompare(a.date, b.date, "date", into: &differences)
  photosCompare(a.dateAdded, b.dateAdded, "date_added", into: &differences)
  photosCompare(a.favorite, b.favorite, "favorite", into: &differences)
  photosCompare(a.hidden, b.hidden, "hidden", into: &differences)
  photosCompare(a.edited, b.edited, "edited", into: &differences)
  photosCompare(a.externalEdit, b.externalEdit, "external_edit", into: &differences)
  photosCompare(a.width, b.width, "width", into: &differences)
  photosCompare(a.height, b.height, "height", into: &differences)
  photosCompare(a.fileSize, b.fileSize, "size", into: &differences)
  photosCompare(a.originalUTI ?? a.uti, b.originalUTI ?? b.uti, "uti", into: &differences)
  photosCompare(a.keywords.sorted(), b.keywords.sorted(), "keywords", into: &differences)
  photosCompare(a.persons.sorted(), b.persons.sorted(), "persons", into: &differences)
  photosCompare(a.albumIDs.sorted(), b.albumIDs.sorted(), "albums", into: &differences)
  photosCompare(a.folderPaths.sorted(), b.folderPaths.sorted(), "folders", into: &differences)
  photosCompare(a.placeNames.sorted(), b.placeNames.sorted(), "places", into: &differences)
  photosCompare(a.labels.sorted(), b.labels.sorted(), "labels", into: &differences)
  photosCompare(a.traits.sorted(), b.traits.sorted(), "traits", into: &differences)
  photosCompare(a.missingState, b.missingState, "missing", into: &differences)
  return differences
}

private func photosCompare<T: Equatable>(_ a: T, _ b: T, _ name: String, into out: inout [String]) {
  if a != b {
    out.append(name)
  }
}

public struct PhotosUnavailableBackend: PhotosAutomating {
  public init() {}

  public func listLibraries() throws -> [PhotosLibraryRecord] { throw unavailable() }
  public func libraryInfo(path: String?) throws -> PhotosLibraryRecord { throw unavailable() }
  public func databaseInfo(path: String?) throws -> PhotosLibraryRecord { throw unavailable() }
  public func compareLibraries(
    libraryA: String?,
    libraryB: String,
    signatureTemplate: String?
  ) throws -> PhotosLibraryCompareReport {
    throw unavailable()
  }
  public func openLibrary(path: String) throws -> Bool { throw unavailable() }
  public func backupLibrary(path: String?, destination: String) throws -> Bool {
    throw unavailable()
  }
  public func listAlbums(query: PhotosQuery) throws -> [PhotosAlbumRecord] { throw unavailable() }
  public func readAlbum(idOrName: String, query: PhotosQuery, includeItems: Bool) throws
    -> PhotosAlbumRecord
  {
    throw unavailable()
  }
  public func createAlbum(name: String, parentFolderID: String?) throws -> PhotosAlbumRecord {
    throw unavailable()
  }
  public func deleteAlbum(idOrName: String) throws -> Bool { throw unavailable() }
  public func addItemsToAlbum(albumIDOrName: String, itemUUIDs: [String]) throws -> Bool {
    throw unavailable()
  }
  public func listFolders(query: PhotosQuery) throws -> [PhotosFolderRecord] { throw unavailable() }
  public func readFolder(idOrName: String, query: PhotosQuery, includeChildren: Bool) throws
    -> PhotosFolderRecord
  {
    throw unavailable()
  }
  public func createFolder(name: String, parentFolderID: String?) throws -> PhotosFolderRecord {
    throw unavailable()
  }
  public func deleteFolder(idOrName: String) throws -> Bool { throw unavailable() }
  public func listMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    throw unavailable()
  }
  public func searchMediaItems(query: PhotosQuery) throws -> [PhotosMediaItemRecord] {
    throw unavailable()
  }
  public func readMediaItem(uuid: String, query: PhotosQuery, include: Set<String>, maxBytes: Int)
    throws
    -> PhotosMediaItemRecord
  {
    throw unavailable()
  }
  public func updateMediaItem(uuid: String, fields: [String: String]) throws
    -> PhotosMediaItemRecord
  {
    throw unavailable()
  }
  public func duplicateMediaItem(uuid: String) throws -> PhotosMediaItemRecord {
    throw unavailable()
  }
  public func listSelection(limit: Int?) throws -> [PhotosMediaItemRecord] { throw unavailable() }
  public func importItems(paths: [String], albumIDOrName: String?, skipDuplicateCheck: Bool) throws
    -> [PhotosMediaItemRecord]
  {
    throw unavailable()
  }
  public func exportItems(plan: PhotosExportPlan) throws -> PhotosExportResult {
    throw unavailable()
  }
  public func exportReport(stateDB: String?, runID: String?) throws -> PhotosExportReport {
    throw unavailable()
  }
  public func metadataValues(kind: String, query: PhotosQuery) throws -> PhotosMetadataAggregate {
    throw unavailable()
  }
  public func writeSidecar(
    format: String,
    query: PhotosQuery,
    destination: String,
    template: String?
  ) throws -> Bool {
    throw unavailable()
  }
  public func writeExif(
    fields: [String],
    query: PhotosQuery,
    destination: String?,
    exiftoolPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> Bool {
    throw unavailable()
  }
  public func queryDatabase(query: PhotosQuery, rawSQL: String?) throws -> [[String: String]] {
    throw unavailable()
  }
  public func grepDatabase(
    query: PhotosQuery,
    pattern: String,
    ignoreCase: Bool,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseGrepMatch] {
    throw unavailable()
  }
  public func debugDumpDatabase(
    query: PhotosQuery,
    sections: [String],
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosDatabaseDebugDumpSection] {
    throw unavailable()
  }
  public func findDatabaseOrphans(
    query: PhotosQuery,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosDatabaseOrphansReport {
    throw unavailable()
  }
  public func renderTemplate(template: String, query: PhotosQuery) throws -> [String] {
    throw unavailable()
  }
  public func runHook(
    kind: String, source: String, input: PhotoHookInput, timeoutSeconds: Int, outputCap: Int
  )
    throws -> PhotoHookOutput
  {
    throw unavailable()
  }
  public func runPostCommand(
    command: String,
    category: String,
    input: PhotoHookInput,
    timeoutSeconds: Int,
    outputCap: Int
  )
    throws -> PhotosActionResult
  {
    throw unavailable()
  }
  public func slideshowRunning() throws -> Bool { throw unavailable() }
  public func slideshow(action: String, query: PhotosQuery) throws -> Bool { throw unavailable() }
  public func showSpotlight(selector: String) throws -> Bool { throw unavailable() }

  public func unavailable() -> CLIError {
    CLIError(
      code: .backendUnavailable,
      message: "Photos backend implementation is planned but not wired yet.",
      details: ["target": "photos", "phase": "command-contract"]
    )
  }
}
