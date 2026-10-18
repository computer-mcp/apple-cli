import Foundation

public protocol MapsReading: Sendable {
  func searchPlaces(_ request: MapsSearchRequest) throws -> MapsPlacesResponse
  func readPlace(_ selection: MapsPlaceSelection) throws -> MapsPlaceRecord
}

public protocol MapsRouting: Sendable {
  func calculateDirections(_ request: MapsDirectionsRequest) throws -> MapsRoutesResponse
  func calculateETA(_ request: MapsDirectionsRequest) throws -> MapsETAResponse
}

public protocol MapsFavoritesReading: Sendable {
  func listFavorites(_ request: MapsSavedListRequest) throws -> MapsFavoritesResponse
  func readFavorite(id: UUID) throws -> MapsFavoriteRecord
}

public protocol MapsCollectionsReading: Sendable {
  func listCollections(_ request: MapsSavedListRequest) throws -> MapsCollectionsResponse
  func readCollection(id: UUID) throws -> MapsCollectionRecord
  func readCollectionItem(id: UUID) throws -> MapsCollectionItemRecord
  func listCollectionItems(id: UUID, request: MapsSavedListRequest) throws
    -> MapsCollectionItemsResponse
}

public protocol MapsCollectionsWriting: Sendable {
  func createCollectionPlace(collection: MapsCollectionRecord, draft: MapsCollectionPlaceDraft)
    throws
    -> MapsCollectionMutationResult
  func createCollection(_ draft: MapsCollectionDraft) throws -> MapsCollectionMutationResult
  func updateCollection(current: MapsCollectionRecord, patch: MapsCollectionPatch) throws
    -> MapsCollectionMutationResult
  func deleteCollection(current: MapsCollectionRecord) throws -> MapsCollectionMutationResult
  func setCollectionMembership(
    collection: MapsCollectionRecord, item: MapsCollectionItemRecord, linked: Bool
  ) throws -> MapsCollectionMutationResult
}

public protocol MapsOpening: Sendable {
  func open(_ url: URL) throws -> Bool
}
