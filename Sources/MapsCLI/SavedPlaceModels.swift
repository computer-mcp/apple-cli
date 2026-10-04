import Foundation

public struct MapsSavedListRequest: Equatable, Sendable {
  public var limit: Int
  public var offset: Int
  public init(limit: Int = 20, offset: Int = 0) {
    self.limit = limit
    self.offset = offset
  }
}

public struct MapsFavoriteResponse: Codable, Equatable, Sendable {
  public var favorite: MapsFavoriteRecord
}

public struct MapsCollectionRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String?
  public var description: String?
  public var imageURL: String?
  public var position: Int
  public var reportedPlaceCount: Int
  public var createdAt: Date?
  public var modifiedAt: Date?

  public init(
    id: String, title: String? = nil, description: String? = nil, imageURL: String? = nil,
    position: Int, reportedPlaceCount: Int, createdAt: Date? = nil, modifiedAt: Date? = nil
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.imageURL = imageURL
    self.position = position
    self.reportedPlaceCount = reportedPlaceCount
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
  }
}

public struct MapsCollectionsResponse: Codable, Equatable, Sendable {
  public var collections: [MapsCollectionRecord]
  public var limit: Int
  public var offset: Int
  public var hasMore: Bool
  public var nextOffset: Int?
}

public struct MapsCollectionResponse: Codable, Equatable, Sendable {
  public var collection: MapsCollectionRecord
}

public enum MapsCollectionItemKind: String, Codable, Sendable {
  case place, transit
}

public struct MapsCollectionItemRecord: Codable, Equatable, Sendable {
  public var id: String
  public var kind: MapsCollectionItemKind
  public var nativeIdentifier: String?
  public var customName: String?
  public var placeName: String?
  public var address: String?
  public var latitude: Double?
  public var longitude: Double?
  public var category: String?
  public var note: String?
  public var transitLineIdentifier: String?
  public var position: Int
  public var createdAt: Date?
  public var modifiedAt: Date?

  public init(
    id: String, kind: MapsCollectionItemKind, customName: String? = nil, placeName: String? = nil,
    address: String? = nil, latitude: Double? = nil, longitude: Double? = nil,
    category: String? = nil, note: String? = nil, transitLineIdentifier: String? = nil,
    position: Int, createdAt: Date? = nil, modifiedAt: Date? = nil,
    nativeIdentifier: String? = nil
  ) {
    self.id = id
    self.kind = kind
    self.nativeIdentifier = nativeIdentifier
    self.customName = customName
    self.placeName = placeName
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.category = category
    self.note = note
    self.transitLineIdentifier = transitLineIdentifier
    self.position = position
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
  }
}

public struct MapsCollectionItemsResponse: Codable, Equatable, Sendable {
  public var collection: MapsCollectionRecord
  public var items: [MapsCollectionItemRecord]
  public var limit: Int
  public var offset: Int
  public var hasMore: Bool
  public var nextOffset: Int?
}
