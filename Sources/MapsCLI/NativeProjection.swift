import CoreLocation
import Foundation
import MapKit
import Utility

func coordinateMapItem(latitude: Double, longitude: Double, name: String?) -> MKMapItem {
  let item: MKMapItem
  if #available(macOS 26, *) {
    item = MKMapItem(location: CLLocation(latitude: latitude, longitude: longitude), address: nil)
  } else {
    item = MKMapItem(
      placemark: MKPlacemark(
        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
  }
  item.name = name
  return item
}

func placeRecord(_ item: MKMapItem, fallbackName: String) throws -> MapsPlaceRecord {
  let coordinate: CLLocationCoordinate2D
  let address: String?
  if #available(macOS 26, *) {
    coordinate = item.location.coordinate
    address = item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true)
  } else {
    coordinate = item.placemark.coordinate
    address = formattedAddress(item.placemark)
  }
  var record = try coordinatePlace(
    latitude: coordinate.latitude, longitude: coordinate.longitude,
    name: item.name ?? fallbackName, address: address)
  if #available(macOS 15, *), let identifier = item.identifier {
    record.nativeIdentifier = identifier.rawValue
    record.id = "maps-item:\(identifier.rawValue)"
  }
  record.phoneNumber = item.phoneNumber
  record.website = item.url?.absoluteString
  record.category = item.pointOfInterestCategory?.rawValue
  record.timeZone = item.timeZone?.identifier
  return record
}

func uniqueMapItem(_ items: [MKMapItem], label: String) throws -> MKMapItem {
  guard let item = items.first else {
    throw CLIError(
      code: .notFound, message: "The route endpoint could not be resolved.",
      details: ["endpoint": label])
  }
  guard items.count == 1 else {
    throw CLIError(
      code: .ambiguousIdentity,
      message:
        "The route endpoint matches multiple places. Search and select explicit coordinates.",
      details: ["endpoint": label, "candidate_count": String(items.count)])
  }
  return item
}

func nativeMapsResponse<Value>(_ response: Value?, error: (any Error)?, phase: String) -> Result<
  Value, any Error
> {
  if let error {
    let native = error as NSError
    let missing =
      native.domain == MKErrorDomain
      && [
        Int(MKError.Code.placemarkNotFound.rawValue), Int(MKError.Code.directionsNotFound.rawValue),
      ].contains(native.code)
    var details = CLIError.diagnosticDetails(for: error)
    details["phase"] = phase
    return .failure(
      CLIError(
        code: missing ? .notFound : .backendUnavailable,
        message: missing
          ? "Maps returned no matching place or route." : "Maps service request failed.",
        details: details))
  }
  guard let response else {
    return .failure(
      CLIError(
        code: .backendUnavailable, message: "Maps service returned no response.",
        details: ["phase": phase]))
  }
  return .success(response)
}

extension MapsTransportMode {
  var nativeType: MKDirectionsTransportType {
    switch self {
    case .driving: .automobile
    case .walking: .walking
    case .transit: .transit
    case .cycling: .cycling
    }
  }
}

func transportName(_ type: MKDirectionsTransportType) -> String {
  switch type {
  case .automobile: "driving"
  case .walking: "walking"
  case .transit: "transit"
  case .cycling: "cycling"
  default: "unknown:\(type.rawValue)"
  }
}

func requireTransportType(_ type: MKDirectionsTransportType, mode: MapsTransportMode) throws {
  guard type == mode.nativeType else {
    throw CLIError(
      code: .backendUnavailable, message: "Maps returned a different transport mode.",
      details: [
        "requested_mode": mode.rawValue, "returned_mode": transportName(type),
      ])
  }
}

func routeRecord(_ route: MKRoute) -> MapsRouteRecord {
  let pointCount = route.polyline.pointCount
  let cap = min(pointCount, 20_000)
  var coordinates = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: cap)
  if cap > 0 {
    route.polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: cap))
  }
  return MapsRouteRecord(
    name: route.name, distanceMeters: route.distance,
    expectedTravelTimeSeconds: route.expectedTravelTime,
    mode: transportName(route.transportType), advisoryNotices: route.advisoryNotices,
    hasTolls: route.hasTolls, hasHighways: route.hasHighways,
    steps: route.steps.prefix(2_000).map {
      MapsRouteStep(
        instructions: $0.instructions, notice: $0.notice, distanceMeters: $0.distance,
        mode: transportName($0.transportType))
    }, stepCount: route.steps.count, stepsTruncated: route.steps.count > 2_000,
    polyline: coordinates.map { MapsCoordinate(latitude: $0.latitude, longitude: $0.longitude) },
    polylinePointCount: pointCount, polylineTruncated: pointCount > cap)
}
