import ArgumentParser
import Utility

extension CalendarTarget {
  public struct Sources: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "sources", subcommands: [List.self, Read.self])
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["sources", "list"]
      @OptionGroup public var shared: CLISharedOptions
      public var targetOptions: CalendarTargetOptions { .init() }
      public init() {}
    }

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["sources", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: CalendarIdentityOptions
      public init() {}
    }
  }
}

extension CalendarTarget.Calendars {
  public struct Read: CalendarTarget.Leaf {
    public static let configuration = CommandConfiguration(commandName: "read")
    public static let positionals = ["calendars", "read"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: CalendarIdentityOptions
    public init() {}
  }

  public struct Create: CalendarTarget.Leaf {
    public static let configuration = CommandConfiguration(commandName: "create")
    public static let positionals = ["calendars", "create"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: CalendarCreateOptions
    public init() {}
  }

  public struct Update: CalendarTarget.Leaf {
    public static let configuration = CommandConfiguration(commandName: "update")
    public static let positionals = ["calendars", "update"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: CalendarUpdateOptions
    public init() {}
  }

  public struct Delete: CalendarTarget.Leaf {
    public static let configuration = CommandConfiguration(commandName: "delete")
    public static let positionals = ["calendars", "delete"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: CalendarIdentityOptions
    public init() {}
  }
}

public struct CalendarIdentityOptions: CalendarCommandOptions, Sendable {
  @Option(help: "Native source or calendar ID.") public var id: String
  public init() {}
  public var cliTargetOptions: [String: String] { ["id": id] }
}

public struct CalendarListOptions: CalendarCommandOptions, Sendable {
  @Option(help: "Only include calendars belonging to this source ID.") public var source: String?
  public init() {}
  public var cliTargetOptions: [String: String] { CLITargetOptionBuilder.options([("source", source)]) }
}

public struct CalendarCreateOptions: CalendarCommandOptions, Sendable {
  @Option(help: "Source ID returned by sources list.") public var source: String
  @Option public var title: String
  @Option(help: "Color in #RRGGBB or #RRGGBBAA form.") public var color: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([("source", source), ("title", title), ("color", color)])
  }
}

public struct CalendarUpdateOptions: CalendarCommandOptions, Sendable {
  @Option(help: "Native calendar ID.") public var id: String
  @Option public var title: String?
  @Option(help: "Color in #RRGGBB or #RRGGBBAA form.") public var color: String?
  public init() {}
  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([("id", id), ("title", title), ("color", color)])
  }
}
