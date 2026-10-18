import ArgumentParser
import Utility

struct RemindersListCreateOptions: ParsableArguments, Sendable {
  @Option(help: "Title for the new list.")
  var title: String?

  @Option(help: "Reminder source ID or title. Defaults to the ReminderKit default account.")
  var source: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(source: source, title: title)
  }
}

struct RemindersListUpdateOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title.")
  var list: String?

  @Option(help: "New list title.")
  var title: String?

  @Option(help: "List type: standard or shopping.")
  var type: String?

  @Option(help: "Reminders color name or hex value such as blue or #0A84FF.")
  var color: String?

  @Option(
    help:
      "Reminders native list badge token, such as shopping2. Use `lists icons list` to enumerate.")
  var icon: String?

  @Option(help: "Pinned state: true or false.")
  var pinned: String?

  @Option(help: "Sorting style such as manual, due-date, creation-date, priority, or title.")
  var sort: String?

  @Option(
    name: .customLong("show-large-attachments"),
    help: "Show image attachments as large previews: true or false.")
  var showLargeAttachments: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(
      list: list,
      title: title,
      type: type,
      color: color,
      icon: icon,
      pinned: pinned,
      sort: sort,
      showLargeAttachments: showLargeAttachments
    )
  }
}

struct RemindersListReorderOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title to move.")
  var list: String?

  @Option(help: "Place the list before this list ID or exact title.")
  var before: String?

  @Option(help: "Place the list after this list ID or exact title.")
  var after: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, before: before, after: after)
  }
}

struct RemindersSmartListCreateOptions: ParsableArguments, Sendable {
  @Option(help: "Title for the new Smart List.")
  var title: String?

  @Option(help: "Reminder source ID or title. Defaults to the ReminderKit default account.")
  var source: String?

  @Option(
    help: "Smart List criterion token, for example tags:travel, flagged:true, or priority:high.")
  var criteria: String?

  @Option(help: "Criteria match mode when multiple criteria are supplied: all or any.")
  var match: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(source: source, title: title, criteria: criteria, match: match)
  }
}

struct RemindersSmartListUpdateOptions: ParsableArguments, Sendable {
  @Option(help: "Custom Smart List ID or exact title.")
  var list: String?

  @Option(help: "Replacement Smart List criterion token.")
  var criteria: String?

  @Option(help: "Criteria match mode when multiple criteria are supplied: all or any.")
  var match: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, criteria: criteria, match: match)
  }
}
