import ArgumentParser
import Utility

public struct MapsTarget: ParsableCommand {
  public static let targetName = "maps"
  public static let targetStatus =
    "Implemented: native places, saved favorites, collection management, routes, ETA, link previews, and gated Maps open."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "maps",
    abstract:
      "Search places, manage saved collections, read favorites, calculate routes and ETA, or open Maps.",
    version: CLIVersion.current,
    subcommands: [
      Places.self, Favorites.self, Collections.self, Directions.self, Open.self, Doctor.self,
    ]
  )

  @OptionGroup public var shared: CLISharedOptions
  public init() {}

  public mutating func run() throws {
    try CLICommandOutput.writeStatus(
      target: Self.targetName,
      status: Self.targetStatus,
      implemented: Self.isImplemented,
      json: shared.json,
      pretty: shared.pretty
    )
  }

  public struct Places: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "places",
      subcommands: [Search.self, Read.self]
    )
    public init() {}

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["places", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsSearchOptions
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["places", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsReadOptions
      public init() {}
    }
  }

  public struct Favorites: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "favorites", subcommands: [List.self, Read.self])
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "list", abstract: "Read saved favorites from the current Maps store.")
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsSavedListOptions
      public static let positionals = ["favorites", "list"]
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["favorites", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsSavedReadOptions
      public init() {}
    }
  }

  public struct Collections: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "collections",
      subcommands: [List.self, Read.self, Create.self, Update.self, Delete.self, Places.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["collections", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsSavedListOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["collections", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsSavedReadOptions
      public init() {}
    }
    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["collections", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsCollectionCreateOptions
      public init() {}
    }
    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update")
      public static let positionals = ["collections", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsCollectionUpdateOptions
      public init() {}
    }
    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["collections", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsSavedReadOptions
      public init() {}
    }
    public struct Places: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "places", subcommands: [List.self, Create.self, Add.self, Remove.self])
      public init() {}
      public struct List: Leaf {
        public static let configuration = CommandConfiguration(commandName: "list")
        public static let positionals = ["collections", "places", "list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: MapsCollectionItemsOptions
        public init() {}
      }
      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "add", abstract: "Link an existing saved collection item to this collection."
        )
        public static let positionals = ["collections", "places", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: MapsCollectionMembershipOptions
        public init() {}
      }
      public struct Create: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "create",
          abstract: "Save a native place or explicit coordinate to a collection."
        )
        public static let positionals = ["collections", "places", "create"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: MapsCollectionPlaceCreateOptions
        public init() {}
      }
      public struct Remove: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "remove",
          abstract: "Remove an item from this collection, preserving other memberships.")
        public static let positionals = ["collections", "places", "remove"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: MapsCollectionMembershipOptions
        public init() {}
      }
    }
  }

  public struct Directions: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "directions",
      subcommands: [Preview.self, Calculate.self, ETA.self]
    )
    public init() {}

    public struct Preview: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "preview",
        abstract: "Build a directions link without contacting Maps services.")
      public static let positionals = ["directions", "preview"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsPreviewOptions
      public init() {}
    }

    public struct Calculate: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "calculate",
        abstract: "Calculate driving, walking or cycling routes with steps and geometry.")
      public static let positionals = ["directions", "calculate"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsCalculateOptions
      public init() {}
    }

    public struct ETA: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "eta", abstract: "Request travel time and distance, including transit ETA.")
      public static let positionals = ["directions", "eta"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: MapsETAOptions
      public init() {}
    }
  }

  public struct Open: Leaf {
    public static let configuration = CommandConfiguration(commandName: "open")
    public static let positionals = ["maps", "open"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: MapsOpenOptions
    public init() {}
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: MapsTarget.targetName,
        checks: mapsDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension MapsTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try MapsCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Command is documented but this target backend is not implemented yet.",
          details: [
            "target": targetName,
            "command": options.positionals.joined(separator: " "),
          ]
        )
      }

      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(
        error, target: targetName, json: options.json, pretty: options.pretty)
    } catch {
      try CLICommandOutput.write(
        CLIError.unexpected(error, verbose: options.verbose),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }

  public protocol Leaf: ParsableCommand {
    associatedtype TargetOptions: MapsCommandOptions
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: TargetOptions { get }
  }
}

extension MapsTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try MapsTarget.runCommand(options: options)
  }
}

public protocol MapsCommandOptions: ParsableArguments {
  var cliTargetOptions: [String: String] { get }
  var cliTargetFlags: Set<String> { get }
}

extension MapsCommandOptions {
  public var cliTargetFlags: Set<String> { [] }
}

public struct MapsSearchOptions: MapsCommandOptions, Sendable {
  @Option(help: "Address or point of interest, at least two characters.") public var query: String
  @Option(help: "Search result kind: all (default), poi, or address.") public var kind: String?
  @Option(
    name: .customLong("region-latitude"),
    help: "Explicit search region center latitude; requires longitude.") public var regionLatitude:
    String?
  @Option(
    name: .customLong("region-longitude"),
    help: "Explicit search region center longitude; requires latitude.") public var regionLongitude:
    String?
  @Option(
    name: .customLong("region-span-meters"),
    help:
      "Region width and height in meters, default 10000. This biases search; it is not a distance filter."
  ) public var regionSpanMeters: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("query", query), ("kind", kind), ("region-latitude", regionLatitude),
      ("region-longitude", regionLongitude), ("region-span-meters", regionSpanMeters),
    ])
  }
}

public struct MapsSavedListOptions: MapsCommandOptions, Sendable {
  @Option(help: "Number of saved items to skip, from 0 to 1000000; default 0.") public var offset:
    Int?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([("offset", offset.map(String.init))])
  }
}

public struct MapsCollectionCreateOptions: MapsCommandOptions, Sendable {
  @Option(help: "Collection title.") public var title: String
  @Option(help: "Optional description; text is stored as supplied.") public var description: String?
  @Option(help: "Optional maps-collection: UUID for a recoverable create request.") public var id:
    String?
  @Option(
    help: ArgumentHelp(
      "Native nonnegative position; defaults to after the last collection.", valueName: "index"))
  public var position: Int?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("title", title), ("description", description), ("id", id),
      ("position", position.map(String.init)),
    ])
  }
}

public struct MapsCollectionUpdateOptions: MapsCommandOptions, Sendable {
  @Option(help: "Native maps-collection: UUID.") public var id: String
  @Option public var title: String?
  @Option public var description: String?
  @Flag(help: "Clear the stored description.") public var clearDescription = false
  @Option(help: ArgumentHelp("Native nonnegative position.", valueName: "index")) public
    var position: Int?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("id", id), ("title", title), ("description", description),
      ("position", position.map(String.init)),
    ])
  }
  public var cliTargetFlags: Set<String> { clearDescription ? ["clear-description"] : [] }
}

public struct MapsCollectionMembershipOptions: MapsCommandOptions, Sendable {
  @Option(help: "Native maps-collection: UUID.") public var id: String
  @Option(help: "Native maps-collection-item: UUID from a collection member list.") public var item:
    String
  public init() {}
  public var cliTargetOptions: [String: String] { ["id": id, "item": item] }
}

public struct MapsCollectionPlaceCreateOptions: MapsCommandOptions, Sendable {
  @Option(help: "Native maps-collection: UUID.") public var id: String
  @Option(help: "Optional maps-collection-item: UUID for a recoverable create request.") public
    var item: String?
  @Option(help: "Native maps-item: identifier returned by search; requires macOS 15 or newer.")
  public var place: String?
  @Option(help: "Explicit latitude; requires longitude and excludes --place.") public var latitude:
    String?
  @Option(help: "Explicit longitude; requires latitude and excludes --place.") public var longitude:
    String?
  @Option(help: "Optional custom name, stored as supplied.") public var name: String?
  @Option(help: "Optional note, stored as supplied.") public var note: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("id", id), ("item", item), ("place", place), ("latitude", latitude),
      ("longitude", longitude), ("name", name), ("note", note),
    ])
  }
}

public struct MapsSavedReadOptions: MapsCommandOptions, Sendable {
  @Option(help: "Native maps-favorite: or maps-collection: UUID from the corresponding list.")
  public var id: String
  public init() {}
  public var cliTargetOptions: [String: String] { ["id": id] }
}

public struct MapsCollectionItemsOptions: MapsCommandOptions, Sendable {
  @Option(help: "Native maps-collection: UUID from collections list.") public var id: String
  @OptionGroup public var page: MapsSavedListOptions
  public init() {}
  public var cliTargetOptions: [String: String] {
    page.cliTargetOptions.merging(["id": id]) { _, id in id }
  }
}

public struct MapsReadOptions: MapsCommandOptions, Sendable {
  @Option(help: "Native maps-item: identifier from search, requires macOS 15 or newer.") public
    var id: String?
  @Option public var latitude: String?
  @Option public var longitude: String?
  @Option public var name: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("id", id), ("latitude", latitude), ("longitude", longitude), ("name", name),
    ])
  }
}

public struct MapsEndpointOptions: ParsableArguments, Sendable {
  @Option public var from: String?
  @Option(name: .customLong("from-latitude")) public var fromLatitude: String?
  @Option(name: .customLong("from-longitude")) public var fromLongitude: String?
  @Option(name: .customLong("from-name")) public var fromName: String?
  @Option public var to: String?
  @Option(name: .customLong("to-latitude")) public var toLatitude: String?
  @Option(name: .customLong("to-longitude")) public var toLongitude: String?
  @Option(name: .customLong("to-name")) public var toName: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("from", from),
      ("from-latitude", fromLatitude),
      ("from-longitude", fromLongitude),
      ("from-name", fromName),
      ("to", to),
      ("to-latitude", toLatitude),
      ("to-longitude", toLongitude),
      ("to-name", toName),
    ])
  }
}

public struct MapsPreviewOptions: MapsCommandOptions, Sendable {
  @OptionGroup public var endpoints: MapsEndpointOptions
  @Option(help: "driving (default), walking, or transit.") public var mode: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    endpoints.cliTargetOptions.merging(CLITargetOptionBuilder.options([("mode", mode)])) {
      _, value in value
    }
  }
}

public struct MapsRouteOptions: ParsableArguments, Sendable {
  @OptionGroup public var endpoints: MapsEndpointOptions
  @Option(help: "driving (default), walking, cycling, or transit (ETA only).") public var mode:
    String?
  @Option(help: "Departure time as ISO 8601 with time zone; exclusive with arrival.") public
    var departure: String?
  @Option(help: "Arrival time as ISO 8601 with time zone; exclusive with departure.") public
    var arrival: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    endpoints.cliTargetOptions.merging(
      CLITargetOptionBuilder.options([
        ("mode", mode), ("departure", departure), ("arrival", arrival),
      ])
    ) { _, value in value }
  }
}

public struct MapsCalculateOptions: MapsCommandOptions, Sendable {
  @OptionGroup public var route: MapsRouteOptions
  @Flag(help: "Ask Maps for alternative routes; availability depends on the service.") public
    var alternatives = false
  public init() {}
  public var cliTargetOptions: [String: String] { route.cliTargetOptions }
  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([("alternatives", alternatives)])
  }
}

public struct MapsETAOptions: MapsCommandOptions, Sendable {
  @OptionGroup public var route: MapsRouteOptions
  public init() {}
  public var cliTargetOptions: [String: String] { route.cliTargetOptions }
}

public struct MapsOpenOptions: MapsCommandOptions, Sendable {
  @Option(help: "A maps: URL.") public var url: String
  public init() {}
  public var cliTargetOptions: [String: String] { ["url": url] }
}

public func mapsDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "maps_app",
      path: "/System/Applications/Maps.app",
      presentMessage: "Maps app bundle is present.",
      missingMessage: "Maps app bundle was not found at the expected system path."
    ),
    CLIDoctorCheck(
      name: "maps_backend",
      status: .ok,
      message:
        "MapKit place search, native place ID lookup, routes and ETA are implemented; requests depend on network and regional service availability. Doctor does not make network requests."
    ),
  ]
}
