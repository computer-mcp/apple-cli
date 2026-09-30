import ArgumentParser
import Utility

extension RemindersTarget {
  public struct Lists: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "lists",
      subcommands: [
        List.self, Icons.self, Groups.self, Smart.self, Create.self, Update.self, Reorder.self,
        Delete.self,
      ])
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List Reminders lists with read-only metadata enrichment."
      )
      public static let positionals = ["lists", "list"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersNoTargetOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a standard Reminders list.",
        discussion: "Use --dry-run to preview the list creation before executing."
      )
      public static let positionals = ["lists", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersListCreateOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update list title, appearance, type, pinning, or sorting.",
        discussion: """
          Examples:
            apple reminders lists update --list "Japan Shopping" --type shopping --dry-run --json
            apple reminders lists update --list Today --color '#0A84FF' --icon shopping2 --dry-run --json
            apple reminders lists icons list --json
          """
      )
      public static let positionals = ["lists", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersListUpdateOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Reorder: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "reorder",
        abstract: "Move a list before or after another list in the Reminders sidebar."
      )
      public static let positionals = ["lists", "reorder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersListReorderOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a Reminders list with dry-run preview."
      )
      public static let positionals = ["lists", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersListOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Icons: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "icons",
        subcommands: [List.self]
      )
      public init() {}

      public struct List: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "list",
          abstract: "List supported Reminders list icon badge tokens."
        )
        public static let positionals = ["lists", "icons", "list"]
        @OptionGroup var sharedOptions: RemindersReadSharedOptions
        public var shared: CLISharedOptions { sharedOptions.shared }
        @OptionGroup var options: RemindersNoTargetOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }
    }

    public struct Smart: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "smart",
        subcommands: [Create.self, Update.self, Convert.self, Delete.self]
      )
      public init() {}

      public struct Create: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "create",
          abstract: "Create a custom Smart List with bounded semantic criteria."
        )
        public static let positionals = ["lists", "smart", "create"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersSmartListCreateOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Update: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "update",
          abstract: "Replace supported criteria for a custom Smart List."
        )
        public static let positionals = ["lists", "smart", "update"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersSmartListUpdateOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Convert: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "convert",
          abstract: "Convert a standard list into a custom Smart List when safe."
        )
        public static let positionals = ["lists", "smart", "convert"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersListOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "delete",
          abstract: "Delete a custom Smart List with dry-run preview."
        )
        public static let positionals = ["lists", "smart", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersListOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }
    }

    public struct Groups: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "groups",
        subcommands: [
          List.self, Create.self, Rename.self, Delete.self, MoveList.self, RemoveList.self,
        ]
      )
      public init() {}

      public struct List: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "list",
          abstract: "List Reminders sidebar groups from read-only SQLite evidence."
        )
        public static let positionals = ["lists", "groups", "list"]
        @OptionGroup var sharedOptions: RemindersReadSharedOptions
        public var shared: CLISharedOptions { sharedOptions.shared }
        @OptionGroup var options: RemindersNoTargetOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Create: Leaf {
        public static let configuration = CommandConfiguration(commandName: "create")
        public static let positionals = ["lists", "groups", "create"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTitleOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Rename: Leaf {
        public static let configuration = CommandConfiguration(commandName: "rename")
        public static let positionals = ["lists", "groups", "rename"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersGroupTitleOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(commandName: "delete")
        public static let positionals = ["lists", "groups", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersGroupOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct MoveList: Leaf {
        public static let configuration = CommandConfiguration(commandName: "move-list")
        public static let positionals = ["lists", "groups", "move-list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersListGroupOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct RemoveList: Leaf {
        public static let configuration = CommandConfiguration(commandName: "remove-list")
        public static let positionals = ["lists", "groups", "remove-list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersListOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }
    }
  }

  public struct Tags: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "tags",
      subcommands: [List.self, Rename.self, Delete.self])
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List tag labels found in read-only Reminders SQLite evidence."
      )
      public static let positionals = ["tags", "list"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersNoTargetOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Rename: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rename")
      public static let positionals = ["tags", "rename"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTagTitleOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["tags", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTagOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }
  }

  public struct Sections: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "sections",
      subcommands: [List.self, Create.self, Rename.self, Delete.self, Reorder.self])
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List sections for one Reminders list."
      )
      public static let positionals = ["sections", "list"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersListOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["sections", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersSectionCreateOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Rename: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rename")
      public static let positionals = ["sections", "rename"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersSectionMutationOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["sections", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersSectionMutationOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Reorder: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reorder")
      public static let positionals = ["sections", "reorder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersSectionReorderOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }
  }

  public struct Subtasks: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "subtasks", subcommands: [Create.self, Move.self, Promote.self])
    public init() {}

    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["subtasks", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersSubtaskCreateOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Move: Leaf {
      public static let configuration = CommandConfiguration(commandName: "move")
      public static let positionals = ["subtasks", "move"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersSubtaskMoveOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Promote: Leaf {
      public static let configuration = CommandConfiguration(commandName: "promote")
      public static let positionals = ["subtasks", "promote"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersIDOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }
  }

  public struct Attachments: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "attachments", subcommands: [Add.self, Remove.self])
    public init() {}

    public struct Add: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Attach a readable local file to a reminder.",
        discussion: "Supports --dry-run; execution verifies attachment evidence read-only."
      )
      public static let positionals = ["attachments", "add"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersAttachmentAddOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Remove: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove")
      public static let positionals = ["attachments", "remove"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersAttachmentRemoveOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }
  }

  public struct Assignments: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "assignments", subcommands: [Assign.self, Unassign.self])
    public init() {}

    public struct Assign: Leaf {
      public static let configuration = CommandConfiguration(commandName: "assign")
      public static let positionals = ["assignments", "assign"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersAssignmentAssignOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Unassign: Leaf {
      public static let configuration = CommandConfiguration(commandName: "unassign")
      public static let positionals = ["assignments", "unassign"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersAssignmentUnassignOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }
  }

  public struct Templates: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "templates",
      abstract: "Manage Reminders list templates.",
      subcommands: [
        List.self, Save.self, CreateList.self, Update.self, Replace.self, Sections.self, Items.self,
        Delete.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List saved Reminders templates."
      )
      public static let positionals = ["templates", "list"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersNoTargetOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Save: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "save",
        abstract: "Save a Reminders list as an official Reminders template.",
        discussion: """
          Examples:
            apple reminders templates save --list "Trip Checklist" --title "Trip Checklist" --dry-run --json
            apple reminders templates save --list "Trip Checklist" --title "Trip Checklist" --include-completed --dry-run --json
          """
      )
      public static let positionals = ["templates", "save"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTemplateSaveOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct CreateList: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "create-list",
        abstract: "Create a Reminders list from a saved template.",
        discussion: """
          Example:
            apple reminders templates create-list --template "Trip Checklist" --title "Japan Trip" --dry-run --json
          """
      )
      public static let positionals = ["templates", "create-list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTemplateCreateListOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a saved Reminders template's title or appearance.",
        discussion: """
          Examples:
            apple reminders templates update --template "Trip Checklist" --title "Travel Checklist" --dry-run --json
            apple reminders templates update --template "Trip Checklist" --color '#0A84FF' --icon airplane --dry-run --json
          """
      )
      public static let positionals = ["templates", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTemplateUpdateOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Replace: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "replace",
        abstract: "Replace a saved template's content from a Reminders list.",
        discussion: """
          Example:
            apple reminders templates replace --template "Trip Checklist" --list "Trip Checklist Draft" --dry-run --json
          """
      )
      public static let positionals = ["templates", "replace"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTemplateReplaceOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a saved Reminders template."
      )
      public static let positionals = ["templates", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup var options: RemindersTemplateOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Sections: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "sections",
        abstract: "Edit sections inside a saved Reminders template.",
        subcommands: [List.self, Add.self, Rename.self, Delete.self, Reorder.self]
      )
      public init() {}

      public struct List: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "list",
          abstract: "List sections inside a saved Reminders template."
        )
        public static let positionals = ["templates", "sections", "list"]
        @OptionGroup var sharedOptions: RemindersReadSharedOptions
        public var shared: CLISharedOptions { sharedOptions.shared }
        @OptionGroup var options: RemindersTemplateOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "add",
          abstract: "Add a section directly to a saved Reminders template."
        )
        public static let positionals = ["templates", "sections", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateSectionCreateOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Rename: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "rename",
          abstract: "Rename a section directly inside a saved Reminders template."
        )
        public static let positionals = ["templates", "sections", "rename"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateSectionMutationOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "delete",
          abstract: "Delete a section directly from a saved Reminders template."
        )
        public static let positionals = ["templates", "sections", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateSectionMutationOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Reorder: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "reorder",
          abstract: "Move a section before or after another section inside a saved template."
        )
        public static let positionals = ["templates", "sections", "reorder"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateSectionReorderOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }
    }

    public struct Items: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "items",
        abstract: "Edit saved reminder items inside a Reminders template.",
        subcommands: [Add.self, Update.self, Delete.self, Attachments.self, Subtasks.self]
      )
      public init() {}

      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "add",
          abstract: "Add an item directly to a saved Reminders template."
        )
        public static let positionals = ["templates", "items", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateItemCreateOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Update: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "update",
          abstract: "Update a saved reminder item inside a Reminders template."
        )
        public static let positionals = ["templates", "items", "update"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateItemUpdateOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(
          commandName: "delete",
          abstract: "Delete a saved reminder item from a Reminders template."
        )
        public static let positionals = ["templates", "items", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup var options: RemindersTemplateItemOptions
        public var targetOptions: RemindersTargetOptions { options.targetOptions }
        public init() {}
      }

      public struct Attachments: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "attachments",
          abstract: "Edit file and image attachments on saved template items.",
          subcommands: [Add.self, Remove.self]
        )
        public init() {}

        public struct Add: Leaf {
          public static let configuration = CommandConfiguration(
            commandName: "add",
            abstract: "Attach a readable local file to a saved template item."
          )
          public static let positionals = ["templates", "items", "attachments", "add"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup var options: RemindersAttachmentAddOptions
          public var targetOptions: RemindersTargetOptions { options.targetOptions }
          public init() {}
        }

        public struct Remove: Leaf {
          public static let configuration = CommandConfiguration(
            commandName: "remove",
            abstract: "Remove one file or image attachment from a saved template item."
          )
          public static let positionals = ["templates", "items", "attachments", "remove"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup var options: RemindersAttachmentRemoveOptions
          public var targetOptions: RemindersTargetOptions { options.targetOptions }
          public init() {}
        }
      }

      public struct Subtasks: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "subtasks",
          abstract: "Edit parent-child hierarchy inside saved template items.",
          subcommands: [Create.self, Move.self, Promote.self]
        )
        public init() {}

        public struct Create: Leaf {
          public static let configuration = CommandConfiguration(
            commandName: "create",
            abstract: "Create a saved template item as a subtask."
          )
          public static let positionals = ["templates", "items", "subtasks", "create"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup var options: RemindersSubtaskCreateOptions
          public var targetOptions: RemindersTargetOptions { options.targetOptions }
          public init() {}
        }

        public struct Move: Leaf {
          public static let configuration = CommandConfiguration(
            commandName: "move",
            abstract: "Move a saved template item under another saved template item."
          )
          public static let positionals = ["templates", "items", "subtasks", "move"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup var options: RemindersSubtaskMoveOptions
          public var targetOptions: RemindersTargetOptions { options.targetOptions }
          public init() {}
        }

        public struct Promote: Leaf {
          public static let configuration = CommandConfiguration(
            commandName: "promote",
            abstract: "Promote a saved template subtask item to the template root."
          )
          public static let positionals = ["templates", "items", "subtasks", "promote"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup var options: RemindersIDOptions
          public var targetOptions: RemindersTargetOptions { options.targetOptions }
          public init() {}
        }
      }
    }
  }

  public struct List: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "list",
      abstract: "List reminders with optional list, status, and due-date filters."
    )
    public static let positionals = ["reminders", "list"]
    @OptionGroup var sharedOptions: RemindersReadSharedOptions
    public var shared: CLISharedOptions { sharedOptions.shared }
    @OptionGroup var options: RemindersListReadOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Search: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "search",
      abstract: "Search reminders by text with optional list/status/due filters."
    )
    public static let positionals = ["reminders", "search"]
    @OptionGroup var sharedOptions: RemindersReadSharedOptions
    public var shared: CLISharedOptions { sharedOptions.shared }
    @OptionGroup var options: RemindersSearchOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Read: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "read",
      abstract: "Read one reminder by ID."
    )
    public static let positionals = ["reminders", "read"]
    @OptionGroup var sharedOptions: RemindersReadSharedOptions
    public var shared: CLISharedOptions { sharedOptions.shared }
    @OptionGroup var options: RemindersIDOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Create: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "create",
      abstract: "Create a reminder in a list.",
      discussion: """
        Examples:
          apple reminders create --list Today --title "Follow up" --dry-run --json
          apple reminders create --list Today --title "Weekly review" --due 2026-07-01 --repeat weekly --repeat-days-of-week mon --dry-run --json
        """
    )
    public static let positionals = ["reminders", "create"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersCreateOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Update: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "update",
      abstract: "Update one reminder's fields, tags, section, URL, or triggers.",
      discussion: """
        Examples:
          apple reminders update --id REMINDER_ID --title "Buy tea" --dry-run --json
          apple reminders update --id REMINDER_ID --url https://example.com --dry-run --json
          apple reminders update --id REMINDER_ID --tags travel,food --dry-run --json
        """
    )
    public static let positionals = ["reminders", "update"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersUpdateOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Complete: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "complete",
      abstract: "Mark one reminder complete.",
      discussion: """
        Examples:
          apple reminders complete --id REMINDER_ID --json
          apple reminders complete --id REMINDER_ID --completed-at 2021-01-02T03:04:05Z --json
        """
    )
    public static let positionals = ["reminders", "complete"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersCompleteOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Uncomplete: Leaf {
    public static let configuration = CommandConfiguration(commandName: "uncomplete")
    public static let positionals = ["reminders", "uncomplete"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersIDOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct CompleteMany: Leaf {
    public static let configuration = CommandConfiguration(commandName: "complete-many")
    public static let positionals = ["reminders", "complete-many"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersIDsOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct UncompleteMany: Leaf {
    public static let configuration = CommandConfiguration(commandName: "uncomplete-many")
    public static let positionals = ["reminders", "uncomplete-many"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersIDsOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct CompleteMatching: Leaf {
    public static let configuration = CommandConfiguration(commandName: "complete-matching")
    public static let positionals = ["reminders", "complete-matching"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersMatchingOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct UncompleteMatching: Leaf {
    public static let configuration = CommandConfiguration(commandName: "uncomplete-matching")
    public static let positionals = ["reminders", "uncomplete-matching"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersMatchingOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct Delete: Leaf {
    public static let configuration = CommandConfiguration(commandName: "delete")
    public static let positionals = ["reminders", "delete"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersIDOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }
  public struct CleanupCompleted: Leaf {
    public static let configuration = CommandConfiguration(commandName: "cleanup-completed")
    public static let positionals = ["reminders", "cleanup-completed"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup var options: RemindersCleanupCompletedOptions
    public var targetOptions: RemindersTargetOptions { options.targetOptions }
    public init() {}
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "doctor",
      abstract: "Reminders readiness and read-only diagnostic checks.",
      subcommands: [Item.self, List.self, Store.self]
    )
    @OptionGroup var sharedOptions: RemindersReadSharedOptions
    public init() {}

    public mutating func run() throws {
      let shared = sharedOptions.shared
      try CLICommandOutput.writeDoctor(
        target: RemindersTarget.targetName,
        checks: remindersDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }

    public struct Item: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "item",
        abstract: "Inspect read-only private-SQLite evidence for one reminder."
      )
      public static let positionals = ["doctor", "item"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersIDOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Inspect read-only private-SQLite evidence for one list."
      )
      public static let positionals = ["doctor", "list"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersListOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }

    public struct Store: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "store",
        abstract: "Inspect read-only Reminders SQLite summary or scoped evidence."
      )
      public static let positionals = ["doctor", "store"]
      @OptionGroup var sharedOptions: RemindersReadSharedOptions
      public var shared: CLISharedOptions { sharedOptions.shared }
      @OptionGroup var options: RemindersDoctorStoreOptions
      public var targetOptions: RemindersTargetOptions { options.targetOptions }
      public init() {}
    }
  }
}
