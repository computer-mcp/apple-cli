import AppKit
import CoreLocation
import CryptoKit
import Foundation
import Utility

public struct MapsCommand: Sendable {
  private let reader: any MapsReading
  private let opener: any MapsOpening
  private let target = "maps"

  public init(
    reader: any MapsReading = CoreLocationMapsBackend(),
    opener: any MapsOpening = NSWorkspaceMapsOpener()
  ) {
    self.reader = reader
    self.opener = opener
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["places", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query"])
      let query = try requiredOption("query", options: options)
      guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
        throw CLIError(
          code: .validationError,
          message: "`--query` must contain at least 2 non-whitespace characters.")
      }
      let places = try reader.searchPlaces(query: query, limit: try commandLimit(options))
      return try result(
        MapsPlacesResponse(places: places), human: placesHumanOutput(places), options: options)
    case ["places", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["latitude", "longitude", "name"])
      let latitude = try coordinateOption("latitude", options: options)
      let longitude = try coordinateOption("longitude", options: options)
      let place = try reader.readPlace(
        latitude: latitude, longitude: longitude, name: options.targetOption("name"))
      return try result(
        MapsPlaceResponse(place: place), human: placeHumanOutput(place), options: options)
    case ["directions", "preview"]:
      try validateReadOnly(options)
      try validateTargetOptions(
        options,
        allowedOptions: [
          "from",
          "from-latitude",
          "from-longitude",
          "from-name",
          "to",
          "to-latitude",
          "to-longitude",
          "to-name",
          "mode",
        ]
      )
      let preview = try directionsPreview(options)
      return try result(
        MapsDirectionsResponse(directions: preview), human: directionsHumanOutput(preview),
        options: options)
    case ["maps", "open"]:
      try validateTargetOptions(options, allowedOptions: ["url"])
      let url = try validatedMapsURL(requiredOption("url", options: options))
      return try open(url, options: options)
    default:
      return nil
    }
  }

  private func open(_ url: URL, options: CLIOptions) throws -> CLICommandResult {
    let operation = "maps.open"
    let scopeDigest = "maps-url:\(sha256Hex(url.absoluteString))"
    let summary = ["url": url.absoluteString]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "Opening Maps dispatches to Maps.app and requires `--allow-external-dispatch`."
    )

    let submitted = try opener.open(url)
    return try result(
      MapsOpenResult(operation: operation, submitted: submitted, mapsURL: url.absoluteString),
      human: "maps.open submitted=\(submitted)",
      options: options
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
