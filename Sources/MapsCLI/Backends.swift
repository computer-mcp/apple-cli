import AppKit
import CoreLocation
import Foundation
import MapKit
import Utility

public struct MapKitMapsBackend: MapsReading, MapsRouting {
  public init() {}

  public func searchPlaces(_ request: MapsSearchRequest) throws -> MapsPlacesResponse {
    let items = try searchItems(request, deadline: MapsDeadline(seconds: 10))
    return MapsPlacesResponse(
      places: try items.prefix(request.limit).map {
        try placeRecord($0, fallbackName: request.query)
      },
      returnedByService: items.count, truncated: items.count > request.limit)
  }

  public func readPlace(_ selection: MapsPlaceSelection) throws -> MapsPlaceRecord {
    switch selection {
    case .identifier(let identifier):
      let item = try serviceItem(identifier: identifier, deadline: MapsDeadline(seconds: 10))
      return try placeRecord(item, fallbackName: "Place")
    case .coordinate(let latitude, let longitude, let name):
      let location = CLLocation(latitude: latitude, longitude: longitude)
      let placemarks = try reverseGeocode(location)
      if let placemark = placemarks.first {
        return try placeRecord(placemark, fallbackName: name ?? "\(latitude),\(longitude)")
      }
      return try coordinatePlace(latitude: latitude, longitude: longitude, name: name)
    }
  }

  func serviceItem(identifier: String, deadline: MapsDeadline) throws -> MKMapItem {
    guard #available(macOS 15, *) else {
      throw CLIError(
        code: .unsupportedOperation, message: "Native place ID lookup requires macOS 15 or newer.")
    }
    guard let nativeID = MKMapItem.Identifier(rawValue: identifier) else {
      throw CLIError(code: .validationError, message: "The native place identifier is invalid.")
    }
    let request = MKMapItemRequest(mapItemIdentifier: nativeID)
    let item: MKMapItem = try waitForMapsCallback(
      deadline: deadline, phase: "place_read", cancel: { request.cancel() },
      start: { finish in
        request.getMapItem { item, error in
          finish(nativeMapsResponse(item, error: error, phase: "place_read"))
        }
      })
    guard mapsSavedTextMatches(item.identifier?.rawValue, identifier) else {
      throw CLIError(
        code: .backendUnavailable, message: "Maps returned another native place identifier.")
    }
    return item
  }

  private func searchItems(_ request: MapsSearchRequest, deadline: MapsDeadline) throws
    -> [MKMapItem]
  {
    let native = MKLocalSearch.Request()
    native.naturalLanguageQuery = request.query
    switch request.kind {
    case .all: native.resultTypes = [.address, .pointOfInterest]
    case .poi: native.resultTypes = .pointOfInterest
    case .address: native.resultTypes = .address
    }
    if let region = request.region {
      native.region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude),
        latitudinalMeters: region.spanMeters, longitudinalMeters: region.spanMeters)
    }
    let search = MKLocalSearch(request: native)
    do {
      let response: MKLocalSearch.Response = try waitForMapsCallback(
        deadline: deadline, phase: "place_search", cancel: { search.cancel() },
        start: { finish in
          search.start { response, error in
            finish(nativeMapsResponse(response, error: error, phase: "place_search"))
          }
        })
      return response.mapItems
    } catch let error as CLIError where error.code == .notFound {
      return []
    }
  }

  private func reverseGeocode(_ location: CLLocation) throws -> [CLPlacemark] {
    let geocoder = CLGeocoder()
    return try waitForMapsCallback(
      deadline: MapsDeadline(seconds: 10), phase: "reverse_geocode",
      cancel: { geocoder.cancelGeocode() },
      start: { finish in
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
          do {
            if let error {
              finish(.success(try mapGeocodeResult(.failure(error))))
            } else if let placemarks {
              finish(.success(placemarks))
            } else {
              finish(
                .failure(
                  CLIError(
                    code: .backendUnavailable, message: "Maps geocoding returned no response.")
                ))
            }
          } catch { finish(.failure(error)) }
        }
      })
  }

  private func endpointItem(_ endpoint: MapsRouteEndpoint, label: String, deadline: MapsDeadline)
    throws -> MKMapItem
  {
    if let latitude = endpoint.latitude, let longitude = endpoint.longitude {
      return coordinateMapItem(latitude: latitude, longitude: longitude, name: endpoint.name)
    }
    let query = endpoint.query ?? ""
    let items = try searchItems(
      MapsSearchRequest(query: query, kind: .all, limit: 50), deadline: deadline)
    return try uniqueMapItem(items, label: label)
  }

  private func nativeRequest(_ request: MapsDirectionsRequest, deadline: MapsDeadline) throws
    -> MKDirections.Request
  {
    let native = MKDirections.Request()
    native.source = try endpointItem(request.source, label: "from", deadline: deadline)
    native.destination = try endpointItem(request.destination, label: "to", deadline: deadline)
    native.transportType = request.mode.nativeType
    native.requestsAlternateRoutes = request.alternatives
    if let departure = request.departure { native.departureDate = departure }
    if let arrival = request.arrival { native.arrivalDate = arrival }
    return native
  }

  public func calculateDirections(_ request: MapsDirectionsRequest) throws -> MapsRoutesResponse {
    if request.mode == .transit {
      throw CLIError(code: .unsupportedOperation, message: "MapKit supports transit ETA only.")
    }
    let deadline = MapsDeadline(seconds: 25)
    let directions = MKDirections(request: try nativeRequest(request, deadline: deadline))
    let response: MKDirections.Response = try waitForMapsCallback(
      deadline: deadline, phase: "directions_calculate", cancel: { directions.cancel() },
      start: { finish in
        directions.calculate { response, error in
          finish(nativeMapsResponse(response, error: error, phase: "directions_calculate"))
        }
      })
    guard !response.routes.isEmpty else {
      throw CLIError(
        code: .notFound, message: "No route was returned for these endpoints and mode.")
    }
    for route in response.routes {
      try requireTransportType(route.transportType, mode: request.mode)
    }
    return MapsRoutesResponse(
      source: try placeRecord(response.source, fallbackName: request.source.displayValue),
      destination: try placeRecord(
        response.destination, fallbackName: request.destination.displayValue),
      mode: request.mode, routes: response.routes.prefix(request.limit).map(routeRecord),
      returnedByService: response.routes.count, truncated: response.routes.count > request.limit)
  }

  public func calculateETA(_ request: MapsDirectionsRequest) throws -> MapsETAResponse {
    let deadline = MapsDeadline(seconds: 25)
    let directions = MKDirections(request: try nativeRequest(request, deadline: deadline))
    let response: MKDirections.ETAResponse = try waitForMapsCallback(
      deadline: deadline, phase: "directions_eta", cancel: { directions.cancel() },
      start: { finish in
        directions.calculateETA { response, error in
          finish(nativeMapsResponse(response, error: error, phase: "directions_eta"))
        }
      })
    try requireTransportType(response.transportType, mode: request.mode)
    return MapsETAResponse(
      source: try placeRecord(response.source, fallbackName: request.source.displayValue),
      destination: try placeRecord(
        response.destination, fallbackName: request.destination.displayValue),
      mode: request.mode, distanceMeters: response.distance,
      expectedTravelTimeSeconds: response.expectedTravelTime,
      expectedDeparture: response.expectedDepartureDate,
      expectedArrival: response.expectedArrivalDate)
  }
}

public struct NSWorkspaceMapsOpener: MapsOpening {
  public init() {}

  public func open(_ url: URL) throws -> Bool {
    NSWorkspace.shared.open(url)
  }
}
