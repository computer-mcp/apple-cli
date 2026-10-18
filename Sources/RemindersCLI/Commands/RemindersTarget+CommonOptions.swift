import ArgumentParser
import Utility

struct RemindersReadSharedOptions: ParsableArguments, Sendable {
  @Flag(help: "Emit the stable JSON envelope.")
  var json = false

  @Flag(help: "Pretty-print JSON output.")
  var pretty = false

  @Flag(help: "Emit additional diagnostics where supported.")
  var verbose = false

  @Option(help: "Output cap for list/search style reads.")
  var limit: Int?

  var shared: CLISharedOptions {
    CLISharedOptions(json: json, pretty: pretty, verbose: verbose, limit: limit)
  }
}

struct RemindersNoTargetOptions: ParsableArguments, Sendable {
  var targetOptions: RemindersTargetOptions { RemindersTargetOptions() }
}

struct RemindersTitleOptions: ParsableArguments, Sendable {
  @Option(help: "New title.")
  var title: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(title: title) }
}

struct RemindersListOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title.")
  var list: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(list: list) }
}

struct RemindersGroupOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list group ID or exact title.")
  var group: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(group: group) }
}

struct RemindersGroupTitleOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list group ID or exact title.")
  var group: String?

  @Option(help: "New group title.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(title: title, group: group)
  }
}

struct RemindersListGroupOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title.")
  var list: String?

  @Option(help: "Reminder list group ID or exact title.")
  var group: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, group: group)
  }
}
struct RemindersIDOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.")
  var id: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(id: id) }
}
struct RemindersCompleteOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.")
  var id: String?

  @Option(
    name: .customLong("completed-at"),
    help: "Completion timestamp as an ISO-8601 date-time, for example 2021-01-02T03:04:05Z."
  )
  var completedAt: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id, completedAt: completedAt)
  }
}
struct RemindersDoctorStoreOptions: ParsableArguments, Sendable {
  @Option(
    help:
      "Read-only SQLite scope: summary, lists, reminders, sections, tags, attachments, or assignments."
  )
  var scope: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(scope: scope) }
}
