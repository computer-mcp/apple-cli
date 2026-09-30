import AppKit
import CoreLocation
import CryptoKit
import Foundation
import Utility

public struct CoreLocationMapsBackend: MapsReading {
  public init() {}

  public func searchPlaces(query: String, limit: Int) throws -> [MapsPlaceRecord] {
    let placemarks = try geocode(query)
    return try placemarks.prefix(limit).map { try placeRecord($0, fallbackName: query) }
  }

  public func readPlace(latitude: Double, longitude: Double, name: String?) throws
    -> MapsPlaceRecord
  {
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let placemarks = try reverseGeocode(location)
    if let placemark = placemarks.first {
      return try placeRecord(placemark, fallbackName: name ?? "\(latitude),\(longitude)")
    }

    return try coordinatePlace(latitude: latitude, longitude: longitude, name: name)
  }

  private func geocode(_ query: String) throws -> [CLPlacemark] {
    let geocoder = CLGeocoder()
    let semaphore = DispatchSemaphore(value: 0)
    let box = LockedBox<Result<[CLPlacemark], Error>?>(nil)

    geocoder.geocodeAddressString(query) { placemarks, error in
      if let error {
        box.set(.failure(error))
      } else {
        box.set(.success(placemarks ?? []))
      }
      semaphore.signal()
    }

    guard semaphore.wait(timeout: .now() + .seconds(10)) == .success else {
      geocoder.cancelGeocode()
      throw CLIError(code: .timeout, message: "Maps place search timed out.")
    }

    return try mapGeocodeResult(box.value())
  }

  private func reverseGeocode(_ location: CLLocation) throws -> [CLPlacemark] {
    let geocoder = CLGeocoder()
    let semaphore = DispatchSemaphore(value: 0)
    let box = LockedBox<Result<[CLPlacemark], Error>?>(nil)

    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error {
        box.set(.failure(error))
      } else {
        box.set(.success(placemarks ?? []))
      }
      semaphore.signal()
    }

    guard semaphore.wait(timeout: .now() + .seconds(10)) == .success else {
      geocoder.cancelGeocode()
      throw CLIError(code: .timeout, message: "Maps place read timed out.")
    }

    return try mapGeocodeResult(box.value())
  }
}

public struct NSWorkspaceMapsOpener: MapsOpening {
  public init() {}

  public func open(_ url: URL) throws -> Bool {
    NSWorkspace.shared.open(url)
  }
}

private final class LockedBox<Value>: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: Value

  init(_ storage: Value) {
    self.storage = storage
  }

  func set(_ value: Value) {
    lock.lock()
    storage = value
    lock.unlock()
  }

  func value() -> Value {
    lock.lock()
    defer { lock.unlock() }
    return storage
  }
}
