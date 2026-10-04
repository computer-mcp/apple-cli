import Foundation
import Utility

public struct MapsSyncSavedPlacesBackend: MapsFavoritesReading, MapsCollectionsReading {
  public init() {}

  public func listFavorites(_ request: MapsSavedListRequest) throws -> MapsFavoritesResponse {
    let values = try list(.favorite, request: request)
    let runtime = try MapsSavedRuntime()
    let records = try values.prefix(request.limit).map(runtime.favoriteRecord)
    try requireUnique(records.map(\.id))
    let more = values.count > request.limit
    return MapsFavoritesResponse(
      favorites: records, limit: request.limit, hasMore: more,
      offset: request.offset, nextOffset: more ? request.offset + records.count : nil)
  }

  public func readFavorite(id: UUID) throws -> MapsFavoriteRecord {
    let runtime = try MapsSavedRuntime()
    let value = try read(.favorite, id: id)
    let record = try runtime.favoriteRecord(value)
    try requireSelected(record.id, kind: .favorite, uuid: id)
    return record
  }

  public func listCollections(_ request: MapsSavedListRequest) throws -> MapsCollectionsResponse {
    let values = try list(.collection, request: request)
    let runtime = try MapsSavedRuntime()
    let records = try values.prefix(request.limit).map(runtime.collectionRecord)
    try requireUnique(records.map(\.id))
    let more = values.count > request.limit
    return MapsCollectionsResponse(
      collections: records, limit: request.limit,
      offset: request.offset, hasMore: more, nextOffset: more ? request.offset + records.count : nil
    )
  }

  public func readCollection(id: UUID) throws -> MapsCollectionRecord {
    let runtime = try MapsSavedRuntime()
    let record = try runtime.collectionRecord(read(.collection, id: id))
    try requireSelected(record.id, kind: .collection, uuid: id)
    return record
  }

  public func readCollectionItem(id: UUID) throws -> MapsCollectionItemRecord {
    let runtime = try MapsSavedRuntime()
    let record = try runtime.collectionItemRecord(read(.collectionItem, id: id))
    try requireSelected(record.id, kind: .collectionItem, uuid: id)
    return record
  }

  public func listCollectionItems(id: UUID, request: MapsSavedListRequest) throws
    -> MapsCollectionItemsResponse
  {
    try validateSavedListRequest(request)
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 10)
    let store = try runtime.defaultStore(deadline: deadline)
    let parent = try selected(
      .collection, id: id, runtime: runtime, store: store, deadline: deadline)
    let collection = try runtime.collectionRecord(parent)
    try requireSelected(collection.id, kind: .collection, uuid: id)
    let options = try runtime.queryOptions(
      limit: request.limit + 1, offset: request.offset,
      predicate: NSPredicate(format: "ANY collections.identifier == %@", id as NSUUID))
    let values = try runtime.fetch(
      kind: .collectionItem, store: store, options: options, deadline: deadline)
    try requireBound(values, limit: request.limit + 1)
    let records = try values.prefix(request.limit).map(runtime.collectionItemRecord)
    try requireUnique(records.map(\.id))
    let more = values.count > request.limit
    return MapsCollectionItemsResponse(
      collection: collection, items: records, limit: request.limit,
      offset: request.offset, hasMore: more, nextOffset: more ? request.offset + records.count : nil
    )
  }

  private func list(_ kind: MapsSavedKind, request: MapsSavedListRequest) throws -> [AnyObject] {
    try validateSavedListRequest(request)
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 10)
    let store = try runtime.defaultStore(deadline: deadline)
    let options = try runtime.queryOptions(limit: request.limit + 1, offset: request.offset)
    let values = try runtime.fetch(kind: kind, store: store, options: options, deadline: deadline)
    try requireBound(values, limit: request.limit + 1)
    return values
  }

  private func read(_ kind: MapsSavedKind, id: UUID) throws -> AnyObject {
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 10)
    let store = try runtime.defaultStore(deadline: deadline)
    return try selected(kind, id: id, runtime: runtime, store: store, deadline: deadline)
  }

  func selected(
    _ kind: MapsSavedKind, id: UUID, runtime: MapsSavedRuntime,
    store: AnyObject, deadline: MapsDeadline
  ) throws -> AnyObject {
    let options = try runtime.queryOptions(
      limit: 2,
      predicate: NSPredicate(format: "identifier == %@", id as NSUUID))
    let values = try runtime.fetch(kind: kind, store: store, options: options, deadline: deadline)
    try requireBound(values, limit: 2)
    let handle = kind.idPrefix + id.uuidString.lowercased()
    guard let value = values.first else {
      throw CLIError(
        code: .notFound, message: "The saved Maps item was not found.", details: ["id": handle])
    }
    guard values.count == 1 else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Multiple saved Maps items have the selected identifier.", details: ["id": handle])
    }
    return value
  }

  func requireBound(_ values: [AnyObject], limit: Int) throws {
    guard values.count <= limit else {
      throw CLIError(
        code: .backendUnavailable,
        message: "The native saved Maps query did not honor its range.")
    }
  }

  func requireUnique(_ ids: [String]) throws {
    guard Set(ids).count == ids.count else {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "The saved Maps batch contains duplicate identifiers.")
    }
  }

  func requireSelected(_ handle: String, kind: MapsSavedKind, uuid: UUID) throws {
    guard handle == kind.idPrefix + uuid.uuidString.lowercased() else {
      throw CLIError(
        code: .backendUnavailable, message: "The native query returned another saved Maps item.")
    }
  }
}
