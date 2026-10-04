import Foundation

public struct MapsPlaceRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var address: String?
  public var latitude: Double?
  public var longitude: Double?
  public var mapsURL: String
  public var nativeIdentifier: String?
  public var phoneNumber: String?
  public var website: String?
  public var category: String?
  public var timeZone: String?

  public init(
    id: String,
    name: String,
    address: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    mapsURL: String,
    nativeIdentifier: String? = nil,
    phoneNumber: String? = nil,
    website: String? = nil,
    category: String? = nil,
    timeZone: String? = nil
  ) {
    self.id = id
    self.name = name
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.mapsURL = mapsURL
    self.nativeIdentifier = nativeIdentifier
    self.phoneNumber = phoneNumber
    self.website = website
    self.category = category
    self.timeZone = timeZone
  }
}

public struct MapsPlacesResponse: Codable, Equatable, Sendable {
  public var places: [MapsPlaceRecord]
  public var returnedByService: Int
  public var truncated: Bool

  public init(places: [MapsPlaceRecord], returnedByService: Int, truncated: Bool) {
    self.places = places
    self.returnedByService = returnedByService
    self.truncated = truncated
  }
}

public enum MapsSearchKind: String, Codable, Sendable {
  case all, poi, address
}

public struct MapsSearchRegion: Equatable, Sendable {
  public var latitude: Double
  public var longitude: Double
  public var spanMeters: Double
}

public struct MapsSearchRequest: Equatable, Sendable {
  public var query: String
  public var kind: MapsSearchKind
  public var region: MapsSearchRegion?
  public var limit: Int
}

public enum MapsPlaceSelection: Equatable, Sendable {
  case identifier(String)
  case coordinate(latitude: Double, longitude: Double, name: String?)
}

public struct MapsPlaceResponse: Codable, Equatable, Sendable {
  public var place: MapsPlaceRecord
}

public struct MapsFavoriteRecord: Codable, Equatable, Sendable {
  public var id: String
  public var customName: String?
  public var placeName: String?
  public var address: String?
  public var latitude: Double?
  public var longitude: Double?
  public var hidden: Bool
  public var position: Int
  public var createdAt: Date?
  public var modifiedAt: Date?

  public init(
    id: String, customName: String? = nil, placeName: String? = nil, address: String? = nil,
    latitude: Double? = nil, longitude: Double? = nil, hidden: Bool, position: Int,
    createdAt: Date? = nil, modifiedAt: Date? = nil
  ) {
    self.id = id
    self.customName = customName
    self.placeName = placeName
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.hidden = hidden
    self.position = position
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
  }
}

public struct MapsFavoritesResponse: Codable, Equatable, Sendable {
  public var favorites: [MapsFavoriteRecord]
  public var limit: Int
  public var hasMore: Bool
  public var offset: Int
  public var nextOffset: Int?

  public init(
    favorites: [MapsFavoriteRecord], limit: Int, hasMore: Bool, offset: Int = 0,
    nextOffset: Int? = nil
  ) {
    self.favorites = favorites
    self.limit = limit
    self.hasMore = hasMore
    self.offset = offset
    self.nextOffset = nextOffset
  }
}

public struct MapsRouteEndpoint: Codable, Equatable, Sendable {
  public var id: String
  public var query: String?
  public var name: String?
  public var latitude: Double?
  public var longitude: Double?

  public init(
    id: String,
    query: String? = nil,
    name: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil
  ) {
    self.id = id
    self.query = query
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }
}

public struct MapsDirectionsPreview: Codable, Equatable, Sendable {
  public var source: String?
  public var destination: String
  public var mode: String
  public var mapsURL: String
  public var externalAction: Bool
  public var sourceEndpoint: MapsRouteEndpoint?
  public var destinationEndpoint: MapsRouteEndpoint

  public init(
    source: String?,
    destination: String,
    mode: String,
    mapsURL: String,
    externalAction: Bool,
    sourceEndpoint: MapsRouteEndpoint? = nil,
    destinationEndpoint: MapsRouteEndpoint
  ) {
    self.source = source
    self.destination = destination
    self.mode = mode
    self.mapsURL = mapsURL
    self.externalAction = externalAction
    self.sourceEndpoint = sourceEndpoint
    self.destinationEndpoint = destinationEndpoint
  }
}

public struct MapsDirectionsResponse: Codable, Equatable, Sendable {
  public var directions: MapsDirectionsPreview
}

public enum MapsTransportMode: String, Codable, Sendable {
  case driving, walking, transit, cycling
}

public struct MapsDirectionsRequest: Equatable, Sendable {
  public var source: MapsRouteEndpoint
  public var destination: MapsRouteEndpoint
  public var mode: MapsTransportMode
  public var alternatives: Bool
  public var departure: Date?
  public var arrival: Date?
  public var limit: Int
}

public struct MapsCoordinate: Codable, Equatable, Sendable {
  public var latitude: Double
  public var longitude: Double
}

public struct MapsRouteStep: Codable, Equatable, Sendable {
  public var instructions: String
  public var notice: String?
  public var distanceMeters: Double
  public var mode: String
}

public struct MapsRouteRecord: Codable, Equatable, Sendable {
  public var name: String
  public var distanceMeters: Double
  public var expectedTravelTimeSeconds: Double
  public var mode: String
  public var advisoryNotices: [String]
  public var hasTolls: Bool
  public var hasHighways: Bool
  public var steps: [MapsRouteStep]
  public var stepCount: Int
  public var stepsTruncated: Bool
  public var polyline: [MapsCoordinate]
  public var polylinePointCount: Int
  public var polylineTruncated: Bool
}

public struct MapsRoutesResponse: Codable, Equatable, Sendable {
  public var source: MapsPlaceRecord
  public var destination: MapsPlaceRecord
  public var mode: MapsTransportMode
  public var routes: [MapsRouteRecord]
  public var returnedByService: Int
  public var truncated: Bool
}

public struct MapsETAResponse: Codable, Equatable, Sendable {
  public var source: MapsPlaceRecord
  public var destination: MapsPlaceRecord
  public var mode: MapsTransportMode
  public var distanceMeters: Double
  public var expectedTravelTimeSeconds: Double
  public var expectedDeparture: Date
  public var expectedArrival: Date
}

public struct MapsOpenResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var mapsURL: String
}
