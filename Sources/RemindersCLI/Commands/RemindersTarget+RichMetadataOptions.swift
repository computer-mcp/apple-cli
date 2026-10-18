import ArgumentParser
import Utility

struct RemindersTagTitleOptions: ParsableArguments, Sendable {
  @Option(help: "Existing tag label.")
  var tag: String?

  @Option(help: "New tag label.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(title: title, tag: tag)
  }
}

struct RemindersTagOptions: ParsableArguments, Sendable {
  @Option(help: "Tag label.")
  var tag: String?

  var targetOptions: RemindersTargetOptions { RemindersTargetOptions(tag: tag) }
}

struct RemindersSectionCreateOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title.")
  var list: String?

  @Option(help: "Section title.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, title: title)
  }
}

struct RemindersSectionMutationOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title.")
  var list: String?

  @Option(help: "Section ID or exact title.")
  var section: String?

  @Option(help: "New section title. Used by rename.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, title: title, section: section)
  }
}

struct RemindersSectionReorderOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder list ID or exact title.")
  var list: String?

  @Option(help: "Section ID or exact title to move.")
  var section: String?

  @Option(help: "Place the section before this section ID or exact title.")
  var before: String?

  @Option(help: "Place the section after this section ID or exact title.")
  var after: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(list: list, section: section, before: before, after: after)
  }
}

struct RemindersSubtaskCreateOptions: ParsableArguments, Sendable {
  @Option(name: .customLong("parent-id"), help: "Parent reminder ID.")
  var parentId: String?

  @Option(help: "Title for the new subtask reminder.")
  var title: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(parentId: parentId, title: title)
  }
}

struct RemindersSubtaskMoveOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID to reparent.")
  var id: String?

  @Option(name: .customLong("parent-id"), help: "New parent reminder ID.")
  var parentId: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id, parentId: parentId)
  }
}

struct RemindersAttachmentAddOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.")
  var id: String?

  @Option(help: "Readable local file path to attach.")
  var file: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id, file: file)
  }
}

struct RemindersAttachmentRemoveOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.")
  var id: String?

  @Option(help: "Attachment identifier, filename, or exact attachment label.")
  var attachment: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id, attachment: attachment)
  }
}

struct RemindersAssignmentAssignOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.")
  var id: String?

  @Option(help: "Shared-list assignee selector.")
  var assignee: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id, assignee: assignee)
  }
}

struct RemindersAssignmentUnassignOptions: ParsableArguments, Sendable {
  @Option(help: "Reminder ID.")
  var id: String?

  @Option(help: "Assignment selector. Omit only when the reminder has one current assignment.")
  var assignment: String?

  var targetOptions: RemindersTargetOptions {
    RemindersTargetOptions(id: id, assignment: assignment)
  }
}
