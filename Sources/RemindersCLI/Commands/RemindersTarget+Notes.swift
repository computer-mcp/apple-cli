import ArgumentParser
import Utility

extension RemindersTarget {
  public struct Notes: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "notes",
      abstract: "Read and format reminder notes.", subcommands: [Read.self, Format.self, ListStyle.self])
    public init() {}

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read",
        abstract: "Read notes text, formatting ranges, links, and list styles.")
      public static let positionals = ["notes", "read"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @Option(help: "Reminder ID.") var id: String
      public var targetOptions: RemindersTargetOptions { .init(id: id) }
      public init() {}
    }

    public struct Format: Leaf {
      public static let configuration = CommandConfiguration(commandName: "format",
        abstract: "Set one inline format while preserving other note content and formatting.")
      public static let positionals = ["notes", "format"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var selection: RemindersNotesSelectionOptions
      @Option(help: "Format: bold, italic, underline, or strikethrough.") var format: String
      @Option(help: "Requested format state: on or off.") var state: String
      public var targetOptions: RemindersTargetOptions {
        var result = selection.targetOptions
        result.format = format
        result.state = state
        return result
      }
      public init() {}
    }

    public struct ListStyle: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list-style",
        abstract: "Set the list style of whole paragraphs containing the selected text.")
      public static let positionals = ["notes", "list-style"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var selection: RemindersNotesSelectionOptions
      @Option(help: "Paragraph style: plain, bulleted, dashed, or numbered.") var style: String
      public var targetOptions: RemindersTargetOptions {
        var result = selection.targetOptions
        result.style = style
        return result
      }
      public init() {}
    }
  }
}

struct RemindersNotesSelectionOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.") var id: String
  @Option(help: "Literal text to select; omit to select all notes.") var text: String?
  @Option(help: "One-based occurrence when literal text repeats.") var occurrence: Int?

  var targetOptions: RemindersTargetOptions {
    var result = RemindersTargetOptions(id: id)
    result.text = text
    result.occurrence = occurrence.map(String.init)
    return result
  }
}
