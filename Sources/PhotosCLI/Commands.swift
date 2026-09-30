import ArgumentParser
import Utility

public struct PhotosTarget: ParsableCommand {
  public static let targetName = "photos"
  public static let targetStatus =
    "Implemented: Photos libraries, albums, media items, exports, metadata, SDEF actions, and gated hooks."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "photos",
    abstract: "Photos libraries, albums, media items, exports, metadata, and gated hooks.",
    version: CLIVersion.current,
    subcommands: [
      Libraries.self, Albums.self, Folders.self, MediaItems.self, Selection.self, Imports.self,
      Exports.self, Metadata.self, Database.self, Templates.self, Hooks.self, PostCommands.self,
      Slideshow.self, Show.self, Doctor.self,
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

  public struct Libraries: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "libraries",
      subcommands: [List.self, Info.self, Compare.self, Open.self, Backup.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["libraries", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Info: Leaf {
      public static let configuration = CommandConfiguration(commandName: "info")
      public static let positionals = ["libraries", "info"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Compare: Leaf {
      public static let configuration = CommandConfiguration(commandName: "compare")
      public static let positionals = ["libraries", "compare"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Open: Leaf {
      public static let configuration = CommandConfiguration(commandName: "open")
      public static let positionals = ["libraries", "open"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Backup: Leaf {
      public static let configuration = CommandConfiguration(commandName: "backup")
      public static let positionals = ["libraries", "backup"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Albums: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "albums",
      subcommands: [List.self, Read.self, Create.self, Delete.self, AddItems.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["albums", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["albums", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["albums", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["albums", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct AddItems: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-items")
      public static let positionals = ["albums", "add-items"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Folders: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "folders", subcommands: [List.self, Read.self, Create.self, Delete.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["folders", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["folders", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["folders", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["folders", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct MediaItems: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "media-items",
      subcommands: [
        List.self, Search.self, Read.self, Dump.self, Inspect.self, Update.self, Undo.self,
        Duplicate.self,
      ]
    )
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["media-items", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["media-items", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["media-items", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Dump: Leaf {
      public static let configuration = CommandConfiguration(commandName: "dump")
      public static let positionals = ["media-items", "dump"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Inspect: Leaf {
      public static let configuration = CommandConfiguration(commandName: "inspect")
      public static let positionals = ["media-items", "inspect"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update")
      public static let positionals = ["media-items", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Undo: Leaf {
      public static let configuration = CommandConfiguration(commandName: "undo")
      public static let positionals = ["media-items", "undo"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Duplicate: Leaf {
      public static let configuration = CommandConfiguration(commandName: "duplicate")
      public static let positionals = ["media-items", "duplicate"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Selection: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "selection", subcommands: [List.self])
    public init() {}
    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["selection", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Imports: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "imports", subcommands: [Import.self])
    public init() {}
    public struct Import: Leaf {
      public static let configuration = CommandConfiguration(commandName: "import")
      public static let positionals = ["imports", "import"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Exports: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "exports", subcommands: [Export.self, Report.self])
    public init() {}
    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["exports", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Report: Leaf {
      public static let configuration = CommandConfiguration(commandName: "report")
      public static let positionals = ["exports", "report"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Metadata: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "metadata",
      subcommands: [
        Keywords.self, Persons.self, Places.self, Labels.self, Sidecar.self, Exif.self,
        PushExif.self, Timewarp.self, AddLocations.self, Sync.self,
      ]
    )
    public init() {}
    public struct Keywords: Leaf {
      public static let configuration = CommandConfiguration(commandName: "keywords")
      public static let positionals = ["metadata", "keywords"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Persons: Leaf {
      public static let configuration = CommandConfiguration(commandName: "persons")
      public static let positionals = ["metadata", "persons"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Places: Leaf {
      public static let configuration = CommandConfiguration(commandName: "places")
      public static let positionals = ["metadata", "places"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Labels: Leaf {
      public static let configuration = CommandConfiguration(commandName: "labels")
      public static let positionals = ["metadata", "labels"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Sidecar: Leaf {
      public static let configuration = CommandConfiguration(commandName: "sidecar")
      public static let positionals = ["metadata", "sidecar"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Exif: Leaf {
      public static let configuration = CommandConfiguration(commandName: "exif")
      public static let positionals = ["metadata", "exif"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct PushExif: Leaf {
      public static let configuration = CommandConfiguration(commandName: "push-exif")
      public static let positionals = ["metadata", "push-exif"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Timewarp: Leaf {
      public static let configuration = CommandConfiguration(commandName: "timewarp")
      public static let positionals = ["metadata", "timewarp"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct AddLocations: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-locations")
      public static let positionals = ["metadata", "add-locations"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Sync: Leaf {
      public static let configuration = CommandConfiguration(commandName: "sync")
      public static let positionals = ["metadata", "sync"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Database: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "database",
      subcommands: [Info.self, Query.self, Grep.self, DebugDump.self, Orphans.self, Write.self])
    public init() {}
    public struct Info: Leaf {
      public static let configuration = CommandConfiguration(commandName: "info")
      public static let positionals = ["database", "info"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Query: Leaf {
      public static let configuration = CommandConfiguration(commandName: "query")
      public static let positionals = ["database", "query"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Grep: Leaf {
      public static let configuration = CommandConfiguration(commandName: "grep")
      public static let positionals = ["database", "grep"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct DebugDump: Leaf {
      public static let configuration = CommandConfiguration(commandName: "debug-dump")
      public static let positionals = ["database", "debug-dump"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Orphans: Leaf {
      public static let configuration = CommandConfiguration(commandName: "orphans")
      public static let positionals = ["database", "orphans"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Write: Leaf {
      public static let configuration = CommandConfiguration(commandName: "write")
      public static let positionals = ["database", "write"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Templates: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "templates", subcommands: [Render.self])
    public init() {}
    public struct Render: Leaf {
      public static let configuration = CommandConfiguration(commandName: "render")
      public static let positionals = ["templates", "render"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Hooks: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "hooks", subcommands: [Template.self, Query.self, Post.self])
    public init() {}
    public struct Template: Leaf {
      public static let configuration = CommandConfiguration(commandName: "template")
      public static let positionals = ["hooks", "template"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Query: Leaf {
      public static let configuration = CommandConfiguration(commandName: "query")
      public static let positionals = ["hooks", "query"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Post: Leaf {
      public static let configuration = CommandConfiguration(commandName: "post")
      public static let positionals = ["hooks", "post"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct PostCommands: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "post-commands", subcommands: [Run.self])
    public init() {}
    public struct Run: Leaf {
      public static let configuration = CommandConfiguration(commandName: "run")
      public static let positionals = ["post-commands", "run"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Slideshow: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "slideshow",
      subcommands: [
        Status.self, Running.self, Start.self, Stop.self, Next.self, Previous.self, Pause.self,
        Resume.self,
      ]
    )
    public init() {}
    public struct Status: Leaf {
      public static let configuration = CommandConfiguration(commandName: "status")
      public static let positionals = ["slideshow", "status"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Running: Leaf {
      public static let configuration = CommandConfiguration(commandName: "running")
      public static let positionals = ["slideshow", "running"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Start: Leaf {
      public static let configuration = CommandConfiguration(commandName: "start")
      public static let positionals = ["slideshow", "start"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Stop: Leaf {
      public static let configuration = CommandConfiguration(commandName: "stop")
      public static let positionals = ["slideshow", "stop"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Next: Leaf {
      public static let configuration = CommandConfiguration(commandName: "next")
      public static let positionals = ["slideshow", "next"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Previous: Leaf {
      public static let configuration = CommandConfiguration(commandName: "previous")
      public static let positionals = ["slideshow", "previous"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Pause: Leaf {
      public static let configuration = CommandConfiguration(commandName: "pause")
      public static let positionals = ["slideshow", "pause"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
    public struct Resume: Leaf {
      public static let configuration = CommandConfiguration(commandName: "resume")
      public static let positionals = ["slideshow", "resume"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Show: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "show", subcommands: [Spotlight.self])
    public init() {}
    public struct Spotlight: Leaf {
      public static let configuration = CommandConfiguration(commandName: "spotlight")
      public static let positionals = ["show", "spotlight"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: PhotosTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}
    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: PhotosTarget.targetName,
        checks: photosDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension PhotosTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try PhotosCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Command is documented but this target backend is not implemented yet.",
          details: ["target": targetName, "command": options.positionals.joined(separator: " ")]
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
        CLIError(
          code: .internalError,
          message: "Unhandled CLI error.",
          details: ["error": String(describing: error)]
        ),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }

  public protocol Leaf: ParsableCommand {
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: PhotosTargetOptions { get }
  }
}

extension PhotosTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try PhotosTarget.runCommand(options: options)
  }
}

public struct PhotosTargetOptions: ParsableArguments, Sendable {
  @Option public var library: String?
  @Option(name: .customLong("other-library")) public var otherLibrary: String?
  @Option public var album: [String] = []
  @Option(name: .customLong("album-id")) public var albumID: String?
  @Option public var folder: [String] = []
  @Option(name: .customLong("folder-id")) public var folderID: String?
  @Option public var uuid: [String] = []
  @Option(name: .customLong("uuid-from-file")) public var uuidFromFile: String?
  @Option(name: .customLong("skip-uuid")) public var skipUUID: [String] = []
  @Option(name: .customLong("skip-uuid-from-file")) public var skipUUIDFromFile: String?
  @Option public var name: String?
  @Option public var destination: String?
  @Option public var path: [String] = []
  @Option public var include: [String] = []
  @Option(name: .customLong("max-bytes")) public var maxBytes: Int?
  @Option public var query: String?
  @Option public var keyword: [String] = []
  @Option(name: .customLong("add-keyword")) public var addKeyword: [String] = []
  @Option public var person: [String] = []
  @Option public var title: [String] = []
  @Option(name: .customLong("description")) public var descriptionText: [String] = []
  @Option public var filename: [String] = []
  @Option(name: .customLong("original-path")) public var originalPath: String?
  @Option public var place: [String] = []
  @Option public var location: String?
  @Option public var label: String?
  @Option public var regex: String?
  @Option(name: .customLong("regex-field")) public var regexField: [String] = []
  @Flag(name: .customLong("ignore-case")) public var ignoreCase = false
  @Flag(name: .customLong("newest-first")) public var newestFirst = false
  @Option public var uti: String?
  @Option public var trait: [String] = []
  @Option(name: .customLong("not-trait")) public var notTrait: [String] = []
  @Option(name: .customLong("media-type")) public var mediaType: String?
  @Option(name: .customLong("date-from")) public var dateFrom: String?
  @Option(name: .customLong("date-to")) public var dateTo: String?
  @Option public var year: [Int] = []
  @Option(name: .customLong("from-time")) public var fromTime: String?
  @Option(name: .customLong("to-time")) public var toTime: String?
  @Option(name: .customLong("date-added-from")) public var dateAddedFrom: String?
  @Option(name: .customLong("date-added-to")) public var dateAddedTo: String?
  @Option public var date: String?
  @Option(name: .customLong("added-after")) public var addedAfter: String?
  @Option(name: .customLong("added-before")) public var addedBefore: String?
  @Option(name: .customLong("added-in-last")) public var addedInLast: String?
  @Option(name: .customLong("min-size")) public var minSize: Int64?
  @Option(name: .customLong("max-size")) public var maxSize: Int64?
  @Option public var exif: [String] = []
  @Option public var format: String?
  @Option(name: .customLong("filename-template")) public var filenameTemplate: String?
  @Option(name: .customLong("directory-template")) public var directoryTemplate: String?
  @Option(name: .customLong("state-db")) public var stateDB: String?
  @Option(name: .customLong("run-id")) public var runID: String?
  @Option(name: .customLong("undo-id")) public var undoID: String?
  @Option(name: .customLong("retry-count")) public var retryCount: Int?
  @Option(name: .customLong("retry-wait-seconds")) public var retryWaitSeconds: Int?
  @Option(name: .customLong("retry-nas-alias")) public var retryNASAlias: String?
  @Option(name: .customLong("add-exported-to-album")) public var addExportedToAlbum: String?
  @Option(name: .customLong("add-skipped-to-album")) public var addSkippedToAlbum: String?
  @Option(name: .customLong("add-missing-to-album")) public var addMissingToAlbum: String?
  @Option public var keep: [String] = []
  @Option(name: .customLong("cleanup-command")) public var cleanupCommand: [String] = []
  @Option(name: .customLong("cleanup-command-error")) public var cleanupCommandError: String?
  @Option(name: .customLong("preview-suffix")) public var previewSuffix: String?
  @Option(name: .customLong("edited-suffix")) public var editedSuffix: String?
  @Option(name: .customLong("jpeg-quality")) public var jpegQuality: Double?
  @Option(name: .customLong("jpeg-extension")) public var jpegExtension: String?
  @Option(name: .customLong("exiftool-path")) public var exiftoolPath: String?
  @Option public var field: [String] = []
  @Option(name: .customLong("set-date")) public var setDate: String?
  @Option(name: .customLong("date-delta-seconds")) public var dateDeltaSeconds: Int?
  @Option(name: .customLong("timezone-offset-seconds")) public var timezoneOffsetSeconds: Int?
  @Option(name: .customLong("set-location")) public var setLocation: String?
  @Option(name: .customLong("track-file")) public var trackFile: String?
  @Option(name: .customLong("max-match-seconds")) public var maxMatchSeconds: Int?
  @Option(name: .customLong("finder-tag-template")) public var finderTagTemplate: [String] = []
  @Option(name: .customLong("xattr-template")) public var xattrTemplate: [String] = []
  @Option(name: .customLong("raw-sql")) public var rawSQL: String?
  @Option public var pattern: String?
  @Option public var dump: [String] = []
  @Option public var template: String?
  @Option(name: .customLong("signature-template")) public var signatureTemplate: String?
  @Option public var source: String?
  @Option(name: .customLong("source-file")) public var sourceFile: String?
  @Option(name: .customLong("timeout-seconds")) public var timeoutSeconds: Int?
  @Option(name: .customLong("output-cap")) public var outputCap: Int?
  @Option public var category: String?
  @Option public var command: String?

  @Flag public var favorite = false
  @Flag(name: .customLong("clear-favorite")) public var clearFavorite = false
  @Flag(name: .customLong("not-favorite")) public var notFavorite = false
  @Flag(name: .customLong("no-keyword")) public var noKeyword = false
  @Flag(name: .customLong("no-title")) public var noTitle = false
  @Flag(name: .customLong("no-description")) public var noDescription = false
  @Flag(name: .customLong("has-location")) public var hasLocation = false
  @Flag(name: .customLong("no-location")) public var noLocation = false
  @Flag(name: .customLong("no-place")) public var noPlace = false
  @Flag(name: .customLong("only-photos")) public var onlyPhotos = false
  @Flag(name: .customLong("only-movies")) public var onlyMovies = false
  @Flag public var hidden = false
  @Flag(name: .customLong("not-hidden")) public var notHidden = false
  @Flag public var shared = false
  @Flag(name: .customLong("not-shared")) public var notShared = false
  @Flag(name: .customLong("icloud")) public var iCloud = false
  @Flag(name: .customLong("not-icloud")) public var notICloud = false
  @Flag(name: .customLong("incloud")) public var inCloud = false
  @Flag(name: .customLong("not-incloud")) public var notInCloud = false
  @Flag public var syndicated = false
  @Flag(name: .customLong("not-syndicated")) public var notSyndicated = false
  @Flag(name: .customLong("saved-to-library")) public var savedToLibrary = false
  @Flag(name: .customLong("not-saved-to-library")) public var notSavedToLibrary = false
  @Flag(name: .customLong("shared-moment")) public var sharedMoment = false
  @Flag(name: .customLong("not-shared-moment")) public var notSharedMoment = false
  @Flag(name: .customLong("shared-library")) public var sharedLibrary = false
  @Flag(name: .customLong("not-shared-library")) public var notSharedLibrary = false
  @Flag(name: .customLong("has-comment")) public var hasComment = false
  @Flag(name: .customLong("no-comment")) public var noComment = false
  @Flag(name: .customLong("has-likes")) public var hasLikes = false
  @Flag(name: .customLong("no-likes")) public var noLikes = false
  @Flag(name: .customLong("in-album")) public var inAlbum = false
  @Flag(name: .customLong("not-in-album")) public var notInAlbum = false
  @Flag public var edited = false
  @Flag(name: .customLong("not-edited")) public var notEdited = false
  @Flag(name: .customLong("external-edit")) public var externalEdit = false
  @Flag(name: .customLong("not-external-edit")) public var notExternalEdit = false
  @Flag public var duplicate = false
  @Flag(name: .customLong("not-duplicate")) public var notDuplicate = false
  @Flag public var missing = false
  @Flag(name: .customLong("not-missing")) public var notMissing = false
  @Flag public var selected = false
  @Flag(name: .customLong("skip-check-duplicates")) public var skipCheckDuplicates = false
  @Flag(name: .customLong("using-originals")) public var usingOriginals = false
  @Flag(name: .customLong("current-name")) public var currentName = false
  @Flag(name: .customLong("export-by-date")) public var exportByDate = false
  @Flag(name: .customLong("touch-file")) public var touchFile = false
  @Flag(name: .customLong("skip-edited")) public var skipEdited = false
  @Flag(name: .customLong("skip-original-if-edited")) public var skipOriginalIfEdited = false
  @Flag(name: .customLong("skip-bursts")) public var skipBursts = false
  @Flag(name: .customLong("skip-live")) public var skipLive = false
  @Flag(name: .customLong("skip-raw")) public var skipRaw = false
  @Flag(name: .customLong("skip-raw-jpeg")) public var skipRawJPEG = false
  @Flag public var update = false
  @Flag(name: .customLong("force-update")) public var forceUpdate = false
  @Flag(name: .customLong("only-new")) public var onlyNew = false
  @Flag(name: .customLong("ignore-signature")) public var ignoreSignature = false
  @Flag public var overwrite = false
  @Flag public var preview = false
  @Flag(name: .customLong("preview-if-missing")) public var previewIfMissing = false
  @Flag(name: .customLong("export-aae")) public var exportAAE = false
  @Flag(name: .customLong("convert-to-jpeg")) public var convertToJPEG = false
  @Flag(name: .customLong("fix-orientation")) public var fixOrientation = false
  @Flag public var cleanup = false
  @Flag(name: .customLong("allow-cleanup")) public var allowCleanup = false
  @Flag(name: .customLong("allow-eval")) public var allowEval = false
  @Flag(name: .customLong("allow-post-command")) public var allowPostCommand = false
  @Flag(name: .customLong("allow-raw-sql")) public var allowRawSQL = false
  @Flag(name: .customLong("allow-database-grep")) public var allowDatabaseGrep = false
  @Flag(name: .customLong("allow-database-debug-dump")) public var allowDatabaseDebugDump = false
  @Flag(name: .customLong("allow-database-orphans")) public var allowDatabaseOrphans = false
  @Flag(name: .customLong("allow-destructive-metadata")) public var allowDestructiveMetadata = false
  @Flag(name: .customLong("allow-hidden-sdef")) public var allowHiddenSDEF = false
  @Flag(name: .customLong("report-only")) public var reportOnly = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("library", library),
      ("other-library", otherLibrary),
      ("album", album.isEmpty ? nil : album.joined(separator: "\n")),
      ("album-id", albumID),
      ("folder", folder.isEmpty ? nil : folder.joined(separator: "\n")),
      ("folder-id", folderID),
      ("uuid", uuid.isEmpty ? nil : uuid.joined(separator: ",")),
      ("uuid-from-file", uuidFromFile),
      ("skip-uuid", skipUUID.isEmpty ? nil : skipUUID.joined(separator: ",")),
      ("skip-uuid-from-file", skipUUIDFromFile),
      ("name", name),
      ("destination", destination),
      ("path", path.isEmpty ? nil : path.joined(separator: "\n")),
      ("include", include.isEmpty ? nil : include.joined(separator: ",")),
      ("max-bytes", maxBytes.map(String.init)),
      ("query", query),
      ("keyword", keyword.isEmpty ? nil : keyword.joined(separator: "\n")),
      ("add-keyword", addKeyword.isEmpty ? nil : addKeyword.joined(separator: "\n")),
      ("person", person.isEmpty ? nil : person.joined(separator: "\n")),
      ("title", title.isEmpty ? nil : title.joined(separator: "\n")),
      ("description", descriptionText.isEmpty ? nil : descriptionText.joined(separator: "\n")),
      ("filename", filename.isEmpty ? nil : filename.joined(separator: "\n")),
      ("original-path", originalPath),
      ("place", place.isEmpty ? nil : place.joined(separator: "\n")),
      ("location", location),
      ("label", label),
      ("regex", regex),
      ("regex-field", regexField.isEmpty ? nil : regexField.joined(separator: ",")),
      ("uti", uti),
      ("trait", trait.isEmpty ? nil : trait.joined(separator: ",")),
      ("not-trait", notTrait.isEmpty ? nil : notTrait.joined(separator: ",")),
      ("media-type", mediaType),
      ("date-from", dateFrom),
      ("date-to", dateTo),
      ("year", year.isEmpty ? nil : year.map(String.init).joined(separator: ",")),
      ("from-time", fromTime),
      ("to-time", toTime),
      ("date-added-from", dateAddedFrom),
      ("date-added-to", dateAddedTo),
      ("date", date),
      ("added-after", addedAfter),
      ("added-before", addedBefore),
      ("added-in-last", addedInLast),
      ("min-size", minSize.map(String.init)),
      ("max-size", maxSize.map(String.init)),
      ("exif", exif.isEmpty ? nil : exif.joined(separator: "\n")),
      ("format", format),
      ("filename-template", filenameTemplate),
      ("directory-template", directoryTemplate),
      ("state-db", stateDB),
      ("run-id", runID),
      ("undo-id", undoID),
      ("retry-count", retryCount.map(String.init)),
      ("retry-wait-seconds", retryWaitSeconds.map(String.init)),
      ("retry-nas-alias", retryNASAlias),
      ("add-exported-to-album", addExportedToAlbum),
      ("add-skipped-to-album", addSkippedToAlbum),
      ("add-missing-to-album", addMissingToAlbum),
      ("keep", keep.isEmpty ? nil : keep.joined(separator: "\n")),
      ("cleanup-command", cleanupCommand.isEmpty ? nil : cleanupCommand.joined(separator: "\n")),
      ("cleanup-command-error", cleanupCommandError),
      ("preview-suffix", previewSuffix),
      ("edited-suffix", editedSuffix),
      ("jpeg-quality", jpegQuality.map { String($0) }),
      ("jpeg-extension", jpegExtension),
      ("exiftool-path", exiftoolPath),
      ("field", field.isEmpty ? nil : field.joined(separator: ",")),
      ("set-date", setDate),
      ("date-delta-seconds", dateDeltaSeconds.map(String.init)),
      ("timezone-offset-seconds", timezoneOffsetSeconds.map(String.init)),
      ("set-location", setLocation),
      ("track-file", trackFile),
      ("max-match-seconds", maxMatchSeconds.map(String.init)),
      (
        "finder-tag-template",
        finderTagTemplate.isEmpty ? nil : finderTagTemplate.joined(separator: "\n")
      ),
      ("xattr-template", xattrTemplate.isEmpty ? nil : xattrTemplate.joined(separator: "\n")),
      ("raw-sql", rawSQL),
      ("pattern", pattern),
      ("dump", dump.isEmpty ? nil : dump.joined(separator: ",")),
      ("template", template),
      ("signature-template", signatureTemplate),
      ("source", source),
      ("source-file", sourceFile),
      ("timeout-seconds", timeoutSeconds.map(String.init)),
      ("output-cap", outputCap.map(String.init)),
      ("category", category),
      ("command", command),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("favorite", favorite),
      ("clear-favorite", clearFavorite),
      ("not-favorite", notFavorite),
      ("no-keyword", noKeyword),
      ("no-title", noTitle),
      ("no-description", noDescription),
      ("has-location", hasLocation),
      ("no-location", noLocation),
      ("no-place", noPlace),
      ("only-photos", onlyPhotos),
      ("only-movies", onlyMovies),
      ("hidden", hidden),
      ("not-hidden", notHidden),
      ("shared", shared),
      ("not-shared", notShared),
      ("icloud", iCloud),
      ("not-icloud", notICloud),
      ("incloud", inCloud),
      ("not-incloud", notInCloud),
      ("syndicated", syndicated),
      ("not-syndicated", notSyndicated),
      ("saved-to-library", savedToLibrary),
      ("not-saved-to-library", notSavedToLibrary),
      ("shared-moment", sharedMoment),
      ("not-shared-moment", notSharedMoment),
      ("shared-library", sharedLibrary),
      ("not-shared-library", notSharedLibrary),
      ("has-comment", hasComment),
      ("no-comment", noComment),
      ("has-likes", hasLikes),
      ("no-likes", noLikes),
      ("in-album", inAlbum),
      ("not-in-album", notInAlbum),
      ("ignore-case", ignoreCase),
      ("newest-first", newestFirst),
      ("edited", edited),
      ("not-edited", notEdited),
      ("external-edit", externalEdit),
      ("not-external-edit", notExternalEdit),
      ("duplicate", duplicate),
      ("not-duplicate", notDuplicate),
      ("missing", missing),
      ("not-missing", notMissing),
      ("selected", selected),
      ("skip-check-duplicates", skipCheckDuplicates),
      ("using-originals", usingOriginals),
      ("current-name", currentName),
      ("export-by-date", exportByDate),
      ("touch-file", touchFile),
      ("skip-edited", skipEdited),
      ("skip-original-if-edited", skipOriginalIfEdited),
      ("skip-bursts", skipBursts),
      ("skip-live", skipLive),
      ("skip-raw", skipRaw),
      ("skip-raw-jpeg", skipRawJPEG),
      ("update", update),
      ("force-update", forceUpdate),
      ("only-new", onlyNew),
      ("ignore-signature", ignoreSignature),
      ("overwrite", overwrite),
      ("preview", preview),
      ("preview-if-missing", previewIfMissing),
      ("export-aae", exportAAE),
      ("convert-to-jpeg", convertToJPEG),
      ("fix-orientation", fixOrientation),
      ("cleanup", cleanup),
      ("allow-cleanup", allowCleanup),
      ("allow-eval", allowEval),
      ("allow-post-command", allowPostCommand),
      ("allow-raw-sql", allowRawSQL),
      ("allow-database-grep", allowDatabaseGrep),
      ("allow-database-debug-dump", allowDatabaseDebugDump),
      ("allow-database-orphans", allowDatabaseOrphans),
      ("allow-destructive-metadata", allowDestructiveMetadata),
      ("allow-hidden-sdef", allowHiddenSDEF),
      ("report-only", reportOnly),
    ])
  }
}
