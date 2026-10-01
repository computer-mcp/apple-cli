import ArgumentParser
import EventKit
import Utility

public struct CalendarTarget: ParsableCommand {
  public static let targetName = "calendar"
  public static let targetStatus =
    "Implemented: EventKit calendar/event read-search, bounded recurring occurrences, attendee metadata, availability/statistics paths, dry-run previewed iCalendar export, and dry-run previewed event create/update/delete with basic relative/absolute alarms and recurrence rules."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "calendar",
    abstract: "Calendar and event workflows.",
    version: CLIVersion.current,
    subcommands: [Calendars.self, Events.self, Availability.self, Doctor.self]
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

  public struct Calendars: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "calendars",
      subcommands: [List.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["calendars", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
  }

  public struct Events: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "events",
      subcommands: [
        List.self, Search.self, Read.self, Occurrences.self, Stats.self, Export.self, Create.self,
        Update.self, Delete.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["events", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["events", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["events", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Occurrences: Leaf {
      public static let configuration = CommandConfiguration(commandName: "occurrences")
      public static let positionals = ["events", "occurrences"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Stats: Leaf {
      public static let configuration = CommandConfiguration(commandName: "stats")
      public static let positionals = ["events", "stats"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["events", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["events", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update")
      public static let positionals = ["events", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["events", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
  }

  public struct Availability: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "availability",
      subcommands: [Check.self]
    )
    public init() {}

    public struct Check: Leaf {
      public static let configuration = CommandConfiguration(commandName: "check")
      public static let positionals = ["availability", "check"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: CalendarTarget.targetName,
        checks: calendarDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension CalendarTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try CalendarCommand().run(options: options) else {
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
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: CalendarTargetOptions { get }
  }
}

extension CalendarTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try CalendarTarget.runCommand(options: options)
  }
}

public struct CalendarTargetOptions: ParsableArguments, Sendable {
  @Option public var from: String?
  @Option public var to: String?
  @Option public var calendar: String?
  @Option public var query: String?
  @Option public var id: String?
  @Option public var format: String?
  @Option public var output: String?
  @Option public var title: String?
  @Option public var start: String?
  @Option public var end: String?
  @Option public var location: String?
  @Option public var notes: String?
  @Option(name: .customLong("alarm-minutes-before")) public var alarmMinutesBefore: String?
  @Option(name: .customLong("alarm-at")) public var alarmAt: String?
  @Option(name: .customLong("recurrence-frequency")) public var recurrenceFrequency: String?
  @Option(name: .customLong("recurrence-interval")) public var recurrenceInterval: String?
  @Option(name: .customLong("recurrence-count")) public var recurrenceCount: String?
  @Option(name: .customLong("recurrence-until")) public var recurrenceUntil: String?
  @Flag(name: .customLong("all-day")) public var allDay = false
  @Flag public var timed = false
  @Flag(name: .customLong("clear-location")) public var clearLocation = false
  @Flag(name: .customLong("clear-notes")) public var clearNotes = false
  @Flag(name: .customLong("clear-alarms")) public var clearAlarms = false
  @Flag(name: .customLong("clear-recurrence")) public var clearRecurrence = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("from", from),
      ("to", to),
      ("calendar", calendar),
      ("query", query),
      ("id", id),
      ("format", format),
      ("output", output),
      ("title", title),
      ("start", start),
      ("end", end),
      ("location", location),
      ("notes", notes),
      ("alarm-minutes-before", alarmMinutesBefore),
      ("alarm-at", alarmAt),
      ("recurrence-frequency", recurrenceFrequency),
      ("recurrence-interval", recurrenceInterval),
      ("recurrence-count", recurrenceCount),
      ("recurrence-until", recurrenceUntil),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("all-day", allDay),
      ("timed", timed),
      ("clear-location", clearLocation),
      ("clear-notes", clearNotes),
      ("clear-alarms", clearAlarms),
      ("clear-recurrence", clearRecurrence),
    ])
  }
}

public func calendarDoctorChecks() -> [CLIDoctorCheck] {
  [
    eventKitAuthorizationCheck(
      entityType: .event,
      name: "eventkit_calendar_authorization",
      grantedMessage: CLIPermissionWording.accessGranted("Calendar"),
      notDeterminedMessage: CLIPermissionWording.accessNotRequested("Calendar")
    ),
    CLIDoctorCheck(
      name: "eventkit_read_backend",
      status: .ok,
      message:
        "Calendar EventKit read/search/occurrences/attendee-metadata/availability/statistics/export commands are implemented."
    ),
    CLIDoctorCheck(
      name: "eventkit_mutation_backend",
      status: .ok,
      message:
        "Calendar EventKit event create/update/delete commands are dry-run previewed, including basic relative/absolute alarms and recurrence rules."
    ),
  ]
}

public func eventKitAuthorizationCheck(
  entityType: EKEntityType,
  name: String,
  grantedMessage: String,
  notDeterminedMessage: String
) -> CLIDoctorCheck {
  let status = EKEventStore.authorizationStatus(for: entityType)
  let details = ["authorization_status": String(describing: status)]

  switch status {
  case .fullAccess:
    return CLIDoctorCheck(name: name, status: .ok, message: grantedMessage, details: details)
  case .writeOnly:
    return CLIDoctorCheck(
      name: name,
      status: .permissionDenied,
      message: CLIPermissionWording.fullAccessRequired(
        "EventKit", operation: "read/search commands"),
      details: details
    )
  case .authorized:
    return CLIDoctorCheck(name: name, status: .ok, message: grantedMessage, details: details)
  case .denied, .restricted:
    return CLIDoctorCheck(
      name: name,
      status: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted("EventKit"),
      details: details
    )
  case .notDetermined:
    return CLIDoctorCheck(
      name: name,
      status: .warning,
      message: notDeterminedMessage,
      details: details
    )
  @unknown default:
    return CLIDoctorCheck(
      name: name,
      status: .warning,
      message: CLIPermissionWording.unknownAuthorizationStatus("EventKit"),
      details: details
    )
  }
}
