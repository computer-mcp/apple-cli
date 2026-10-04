import Foundation
import Utility

public struct MapsCommand: Sendable {
  private let reader: any MapsReading
  private let opener: any MapsOpening
  private let router: any MapsRouting
  private let favorites: any MapsFavoritesReading
  let collections: any MapsCollectionsReading
  let collectionWriter: any MapsCollectionsWriting
  private let target = "maps"

  public init(
    reader: any MapsReading = MapKitMapsBackend(),
    opener: any MapsOpening = NSWorkspaceMapsOpener(),
    router: any MapsRouting = MapKitMapsBackend(),
    favorites: any MapsFavoritesReading = MapsSyncSavedPlacesBackend(),
    collections: any MapsCollectionsReading = MapsSyncSavedPlacesBackend(),
    collectionWriter: any MapsCollectionsWriting = MapsSyncSavedPlacesBackend()
  ) {
    self.reader = reader
    self.opener = opener
    self.router = router
    self.favorites = favorites
    self.collections = collections
    self.collectionWriter = collectionWriter
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    if let mutation = try runCollectionMutation(options) { return mutation }
    switch options.positionals {
    case ["favorites", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["offset"])
      let response = try favorites.listFavorites(savedListRequest(options))
      let human = response.favorites.map {
        "\($0.id) \($0.customName ?? $0.placeName ?? "")"
      }.joined(separator: "\n")
      return try result(response, human: human, options: options)
    case ["favorites", "read"]:
      try validateSavedRead(options)
      let record = try favorites.readFavorite(id: savedIdentifier(options, kind: .favorite))
      return try result(
        MapsFavoriteResponse(favorite: record),
        human: "\(record.id) \(record.customName ?? record.placeName ?? "")", options: options)
    case ["collections", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["offset"])
      let response = try collections.listCollections(savedListRequest(options))
      return try result(
        response,
        human: response.collections.map { "\($0.id) \($0.title ?? "")" }.joined(separator: "\n"),
        options: options)
    case ["collections", "read"]:
      try validateSavedRead(options)
      let record = try collections.readCollection(id: savedIdentifier(options, kind: .collection))
      return try result(
        MapsCollectionResponse(collection: record), human: "\(record.id) \(record.title ?? "")",
        options: options)
    case ["collections", "places", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "offset"])
      let response = try collections.listCollectionItems(
        id: savedIdentifier(options, kind: .collection), request: savedListRequest(options))
      return try result(
        response,
        human: response.items.map {
          "\($0.id) \($0.customName ?? $0.placeName ?? $0.transitLineIdentifier ?? "")"
        }.joined(separator: "\n"), options: options)
    case ["places", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(
        options,
        allowedOptions: [
          "query", "kind", "region-latitude", "region-longitude", "region-span-meters",
        ])
      let response = try reader.searchPlaces(searchRequest(options))
      return try result(response, human: placesHumanOutput(response.places), options: options)
    case ["places", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "latitude", "longitude", "name"])
      let place = try reader.readPlace(placeSelection(options))
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
    case ["directions", "calculate"], ["directions", "eta"]:
      try validateReadOnly(options)
      let eta = options.positionals.last == "eta"
      try validateTargetOptions(
        options,
        allowedOptions: [
          "from", "from-latitude", "from-longitude", "from-name",
          "to", "to-latitude", "to-longitude", "to-name", "mode", "departure", "arrival",
        ], allowedFlags: eta ? [] : ["alternatives"])
      let request = try directionsRequest(options, eta: eta)
      if eta {
        let response = try router.calculateETA(request)
        return try result(response, human: etaHumanOutput(response), options: options)
      }
      let response = try router.calculateDirections(request)
      return try result(response, human: routesHumanOutput(response), options: options)
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

  func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
