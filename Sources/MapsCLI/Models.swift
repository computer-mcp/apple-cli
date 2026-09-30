import AppKit
import CoreLocation
import CryptoKit
import Foundation
import Utility

public struct MapsPlaceRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var address: String?
  public var latitude: Double?
  public var longitude: Double?
  public var mapsURL: String

  public init(
    id: String,
    name: String,
    address: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    mapsURL: String
  ) {
    self.id = id
    self.name = name
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.mapsURL = mapsURL
  }
}

public struct MapsPlacesResponse: Codable, Equatable, Sendable {
  public var places: [MapsPlaceRecord]
}

public struct MapsPlaceResponse: Codable, Equatable, Sendable {
  public var place: MapsPlaceRecord
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


public struct MapsOpenResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var mapsURL: String
}
