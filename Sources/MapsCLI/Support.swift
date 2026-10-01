import AppKit
import CoreLocation
import CryptoKit
import Foundation
import Utility

func mapGeocodeResult(_ result: Result<[CLPlacemark], Error>?) throws -> [CLPlacemark] {
  switch result {
  case .success(let placemarks):
    return placemarks
  case .failure(let error as CLError) where error.code == .network:
    throw CLIError(
      code: .backendUnavailable, message: "Maps geocoding network service is unavailable.")
  case .failure(let error):
    throw CLIError(
      code: .backendUnavailable, message: "Maps geocoding failed.",
      details: CLIError.diagnosticDetails(for: error))
  case nil:
    throw CLIError(code: .backendUnavailable, message: "Maps geocoding did not return a result.")
  }
}

func placeRecord(_ placemark: CLPlacemark, fallbackName: String) throws -> MapsPlaceRecord {
  guard let location = placemark.location?.coordinate else {
    return try queryPlace(name: placemark.name ?? fallbackName, query: fallbackName)
  }

  let name = placemark.name ?? fallbackName
  return try coordinatePlace(
    latitude: location.latitude,
    longitude: location.longitude,
    name: name,
    address: formattedAddress(placemark)
  )
}

func coordinatePlace(latitude: Double, longitude: Double, name: String?, address: String? = nil)
  throws -> MapsPlaceRecord
{
  let title =
    name?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "\(latitude),\(longitude)"
  let mapsURL = try mapsURL(query: title, latitude: latitude, longitude: longitude)
  let identity = "\(title)|\(address ?? "")|\(latitude)|\(longitude)"
  return MapsPlaceRecord(
    id: "maps-place:\(sha256Hex(identity))",
    name: title,
    address: address,
    latitude: latitude,
    longitude: longitude,
    mapsURL: mapsURL.absoluteString
  )
}

func queryPlace(name: String, query: String) throws -> MapsPlaceRecord {
  let url = try mapsURL(query: query, latitude: nil, longitude: nil)
  return MapsPlaceRecord(
    id: "maps-query:\(sha256Hex(query.lowercased()))",
    name: name,
    mapsURL: url.absoluteString
  )
}

func directionsPreview(_ options: CLIOptions) throws -> MapsDirectionsPreview {
  guard
    let destinationEndpoint = try routeEndpoint(
      queryOption: "to",
      latitudeOption: "to-latitude",
      longitudeOption: "to-longitude",
      nameOption: "to-name",
      required: true,
      options: options
    )
  else {
    throw CLIError(
      code: .validationError,
      message: "`--to` or `--to-latitude` with `--to-longitude` is required."
    )
  }
  let sourceEndpoint = try routeEndpoint(
    queryOption: "from",
    latitudeOption: "from-latitude",
    longitudeOption: "from-longitude",
    nameOption: "from-name",
    required: false,
    options: options
  )
  let mode = try directionsMode(options)
  let url = try directionsURL(source: sourceEndpoint, destination: destinationEndpoint, mode: mode)
  return MapsDirectionsPreview(
    source: sourceEndpoint?.displayValue,
    destination: destinationEndpoint.displayValue,
    mode: mode,
    mapsURL: url.absoluteString,
    externalAction: false,
    sourceEndpoint: sourceEndpoint,
    destinationEndpoint: destinationEndpoint
  )
}

func directionsMode(_ options: CLIOptions) throws -> String {
  let mode = options.targetOption("mode") ?? "driving"
  guard ["driving", "walking", "transit"].contains(mode) else {
    throw CLIError(
      code: .validationError, message: "`--mode` must be `driving`, `walking`, or `transit`.")
  }
  return mode
}

func mapsURL(query: String, latitude: Double?, longitude: Double?) throws -> URL {
  var components = URLComponents()
  components.scheme = "maps"
  components.queryItems = [URLQueryItem(name: "q", value: query)]
  if let latitude, let longitude {
    components.queryItems?.append(URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"))
  }

  guard let url = components.url else {
    throw CLIError(code: .validationError, message: "Failed to construct Maps URL.")
  }
  return url
}

func directionsURL(source: MapsRouteEndpoint?, destination: MapsRouteEndpoint, mode: String) throws
  -> URL
{
  var components = URLComponents()
  components.scheme = "maps"
  var queryItems = [
    URLQueryItem(name: "daddr", value: destination.addressValue),
    URLQueryItem(name: "dirflg", value: modeFlag(mode)),
  ]
  if let source {
    queryItems.append(URLQueryItem(name: "saddr", value: source.addressValue))
  }
  components.queryItems = queryItems

  guard let url = components.url else {
    throw CLIError(code: .validationError, message: "Failed to construct Maps directions URL.")
  }
  return url
}

func validatedMapsURL(_ value: String) throws -> URL {
  guard let url = URL(string: value), url.scheme == "maps" else {
    throw CLIError(
      code: .validationError,
      message: "`--url` must be a `maps:` URL generated or accepted by this CLI.")
  }
  return url
}

func modeFlag(_ mode: String) -> String {
  switch mode {
  case "walking":
    return "w"
  case "transit":
    return "r"
  default:
    return "d"
  }
}

func formattedAddress(_ placemark: CLPlacemark) -> String? {
  [
    placemark.subThoroughfare,
    placemark.thoroughfare,
    placemark.locality,
    placemark.administrativeArea,
    placemark.postalCode,
    placemark.country,
  ]
  .compactMap { $0?.nilIfEmpty }
  .joined(separator: ", ")
  .nilIfEmpty
}

func validateReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation or external-action commands."
    )
  }
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateTargetOptions(_ options: CLIOptions, allowedOptions: Set<String>) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if !unknownOptions.isEmpty || !options.targetFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(options.targetFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name),
    !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }
  return value
}

func coordinateOption(_ name: String, options: CLIOptions) throws -> Double {
  let value = try requiredOption(name, options: options)
  guard let coordinate = Double(value) else {
    throw CLIError(code: .validationError, message: "`--\(name)` must be a numeric coordinate.")
  }
  if name.hasSuffix("latitude"), !(-90...90).contains(coordinate) {
    throw CLIError(code: .validationError, message: "`--\(name)` must be between -90 and 90.")
  }
  if name.hasSuffix("longitude"), !(-180...180).contains(coordinate) {
    throw CLIError(code: .validationError, message: "`--\(name)` must be between -180 and 180.")
  }
  return coordinate
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 10
  guard limit <= 50 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 50 for Maps read commands.")
  }
  return limit
}

func placesHumanOutput(_ places: [MapsPlaceRecord]) -> String {
  places.map { "\($0.id)\t\($0.name)\t\($0.mapsURL)" }.joined(separator: "\n")
}

func placeHumanOutput(_ place: MapsPlaceRecord) -> String {
  [
    "id: \(place.id)",
    "name: \(place.name)",
    "address: \(place.address ?? "-")",
    "url: \(place.mapsURL)",
  ].joined(separator: "\n")
}

func directionsHumanOutput(_ preview: MapsDirectionsPreview) -> String {
  [
    "from: \(preview.source ?? "-")",
    "to: \(preview.destination)",
    "mode: \(preview.mode)",
    "url: \(preview.mapsURL)",
  ].joined(separator: "\n")
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func routeEndpoint(
  queryOption: String,
  latitudeOption: String,
  longitudeOption: String,
  nameOption: String,
  required: Bool,
  options: CLIOptions
) throws -> MapsRouteEndpoint? {
  let query = options.targetOption(queryOption)?.trimmingCharacters(in: .whitespacesAndNewlines)
    .nilIfEmpty
  let latitudeText = options.targetOption(latitudeOption)
  let longitudeText = options.targetOption(longitudeOption)
  let name = options.targetOption(nameOption)?.trimmingCharacters(in: .whitespacesAndNewlines)
    .nilIfEmpty
  let hasCoordinateOption = latitudeText != nil || longitudeText != nil

  if query != nil, hasCoordinateOption {
    throw CLIError(
      code: .validationError,
      message:
        "`--\(queryOption)` cannot be combined with `--\(latitudeOption)` or `--\(longitudeOption)`."
    )
  }

  if let query {
    return MapsRouteEndpoint(
      id: "maps-route-query:\(sha256Hex(query.lowercased()))",
      query: query
    )
  }

  if hasCoordinateOption {
    guard latitudeText != nil, longitudeText != nil else {
      throw CLIError(
        code: .validationError,
        message: "`--\(latitudeOption)` and `--\(longitudeOption)` must be supplied together."
      )
    }
    let latitude = try coordinateOption(latitudeOption, options: options)
    let longitude = try coordinateOption(longitudeOption, options: options)
    let identity = "\(coordinateString(latitude)),\(coordinateString(longitude))|\(name ?? "")"
    return MapsRouteEndpoint(
      id: "maps-route-coordinate:\(sha256Hex(identity))",
      name: name,
      latitude: latitude,
      longitude: longitude
    )
  }

  if name != nil {
    throw CLIError(
      code: .validationError,
      message: "`--\(nameOption)` requires `--\(latitudeOption)` and `--\(longitudeOption)`."
    )
  }

  if required {
    throw CLIError(
      code: .validationError,
      message:
        "`--\(queryOption)` or `--\(latitudeOption)` with `--\(longitudeOption)` is required."
    )
  }

  return nil
}

func coordinateString(_ value: Double) -> String {
  String(format: "%.6f", value)
}

extension MapsRouteEndpoint {
  var addressValue: String {
    if let latitude, let longitude {
      return "\(coordinateString(latitude)),\(coordinateString(longitude))"
    }
    return query ?? name ?? ""
  }

  var displayValue: String {
    if let name {
      return name
    }
    return addressValue
  }
}

extension String {
  var nilIfEmpty: String? {
    isEmpty ? nil : self
  }
}
