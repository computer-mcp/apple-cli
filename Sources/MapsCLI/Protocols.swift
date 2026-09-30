import AppKit
import CoreLocation
import CryptoKit
import Foundation
import Utility

public protocol MapsReading: Sendable {
  func searchPlaces(query: String, limit: Int) throws -> [MapsPlaceRecord]
  func readPlace(latitude: Double, longitude: Double, name: String?) throws -> MapsPlaceRecord
}

public protocol MapsOpening: Sendable {
  func open(_ url: URL) throws -> Bool
}
