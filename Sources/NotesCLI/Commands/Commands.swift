import ArgumentParser
import Utility

public struct NotesTarget: ParsableCommand {
  public static let targetName = "notes"
  public static let targetStatus =
    "Implemented: Notes accounts, folders, tags, notes, attachments, search, and supported editing workflows."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "notes",
    abstract: "Notes accounts, folders, tags, note reads, search, and dry-run writes.",
    version: CLIVersion.current,
    subcommands: [
      Accounts.self, Folders.self, SmartFolders.self, Tags.self, Attachments.self, Links.self,
      Body.self, State.self, Settings.self, Guide.self, Workflow.self, QuickNote.self, List.self, Search.self, Index.self, SemanticSearch.self, Read.self, Create.self,
      Import.self, Replace.self, Export.self, Print.self, OpenInPages.self, Update.self, Append.self, Move.self, Copy.self,
      Restore.self, RestoreAll.self, Delete.self, Purge.self, EmptyTrash.self, Pin.self, Unpin.self, Batch.self, Doctor.self,
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

  public struct Accounts: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "accounts",
      subcommands: [List.self, Workflow.self, Add.self, Remove.self, Enable.self, Disable.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["accounts", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Workflow: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "workflow",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["accounts", "workflow", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Add: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add")
      public static let positionals = ["accounts", "add"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Remove: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove")
      public static let positionals = ["accounts", "remove"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Enable: Leaf {
      public static let configuration = CommandConfiguration(commandName: "enable")
      public static let positionals = ["accounts", "enable"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Disable: Leaf {
      public static let configuration = CommandConfiguration(commandName: "disable")
      public static let positionals = ["accounts", "disable"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Folders: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "folders",
      subcommands: [
        List.self, Workflow.self, Create.self, Rename.self, Move.self, MoveImpact.self, Delete.self, Purge.self, Sort.self,
        Reorder.self, DateHeaders.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["folders", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Workflow: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "workflow",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["folders", "workflow", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["folders", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Rename: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rename")
      public static let positionals = ["folders", "rename"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Move: Leaf {
      public static let configuration = CommandConfiguration(commandName: "move")
      public static let positionals = ["folders", "move"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct MoveImpact: Leaf {
      public static let configuration = CommandConfiguration(commandName: "move-impact")
      public static let positionals = ["folders", "move-impact"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["folders", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Purge: Leaf {
      public static let configuration = CommandConfiguration(commandName: "purge")
      public static let positionals = ["folders", "purge"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Sort: Leaf {
      public static let configuration = CommandConfiguration(commandName: "sort")
      public static let positionals = ["folders", "sort"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Reorder: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reorder")
      public static let positionals = ["folders", "reorder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct DateHeaders: Leaf {
      public static let configuration = CommandConfiguration(commandName: "date-headers")
      public static let positionals = ["folders", "date-headers"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct SmartFolders: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "smart-folders",
      subcommands: [
        List.self, Notes.self, Criteria.self, Explain.self, Reasoning.self, Audit.self, Workflow.self, Filters.self,
        Create.self, Update.self, CreateCriteria.self, UpdateCriteria.self, Duplicate.self, CopyCriteria.self, ExportCriteria.self,
        ImportCriteria.self, Rename.self, Delete.self, ConvertFolder.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["smart-folders", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Notes: Leaf {
      public static let configuration = CommandConfiguration(commandName: "notes")
      public static let positionals = ["smart-folders", "notes"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Criteria: Leaf {
      public static let configuration = CommandConfiguration(commandName: "criteria")
      public static let positionals = ["smart-folders", "criteria"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Explain: Leaf {
      public static let configuration = CommandConfiguration(commandName: "explain")
      public static let positionals = ["smart-folders", "explain"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Reasoning: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reasoning")
      public static let positionals = ["smart-folders", "reasoning"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["smart-folders", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Workflow: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "workflow",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["smart-folders", "workflow", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Filters: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "filters",
        subcommands: [Audit.self, Add.self, Update.self, Remove.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["smart-folders", "filters", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add")
        public static let positionals = ["smart-folders", "filters", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Update: Leaf {
        public static let configuration = CommandConfiguration(commandName: "update")
        public static let positionals = ["smart-folders", "filters", "update"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Remove: Leaf {
        public static let configuration = CommandConfiguration(commandName: "remove")
        public static let positionals = ["smart-folders", "filters", "remove"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["smart-folders", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update")
      public static let positionals = ["smart-folders", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct CreateCriteria: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create-criteria")
      public static let positionals = ["smart-folders", "create-criteria"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct UpdateCriteria: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update-criteria")
      public static let positionals = ["smart-folders", "update-criteria"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Duplicate: Leaf {
      public static let configuration = CommandConfiguration(commandName: "duplicate")
      public static let positionals = ["smart-folders", "duplicate"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct CopyCriteria: Leaf {
      public static let configuration = CommandConfiguration(commandName: "copy-criteria")
      public static let positionals = ["smart-folders", "copy-criteria"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ExportCriteria: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export-criteria")
      public static let positionals = ["smart-folders", "export-criteria"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ImportCriteria: Leaf {
      public static let configuration = CommandConfiguration(commandName: "import-criteria")
      public static let positionals = ["smart-folders", "import-criteria"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Rename: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rename")
      public static let positionals = ["smart-folders", "rename"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["smart-folders", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ConvertFolder: Leaf {
      public static let configuration = CommandConfiguration(commandName: "convert-folder")
      public static let positionals = ["smart-folders", "convert-folder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Tags: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "tags",
      subcommands: [List.self, Search.self, Audit.self, Add.self, Remove.self, ConvertToText.self, Rename.self, Delete.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["tags", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["tags", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["tags", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Add: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add")
      public static let positionals = ["tags", "add"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Remove: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove")
      public static let positionals = ["tags", "remove"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ConvertToText: Leaf {
      public static let configuration = CommandConfiguration(commandName: "convert-to-text")
      public static let positionals = ["tags", "convert-to-text"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Rename: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rename")
      public static let positionals = ["tags", "rename"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["tags", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Attachments: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "attachments",
      subcommands: [
        List.self, Search.self, Audit.self, Workflow.self, Add.self, Copy.self, AddWebpage.self, UpdateWebpage.self, Rename.self,
        Remove.self, Export.self, ExportPDF.self, Scan.self, PDF.self, Image.self, Drawing.self, RecognizedText.self,
        Audio.self, Markup.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["attachments", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Search: Leaf {
      public static let configuration = CommandConfiguration(commandName: "search")
      public static let positionals = ["attachments", "search"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["attachments", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Workflow: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "workflow",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["attachments", "workflow", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Add: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add")
      public static let positionals = ["attachments", "add"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Copy: Leaf {
      public static let configuration = CommandConfiguration(commandName: "copy")
      public static let positionals = ["attachments", "copy"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AddWebpage: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-webpage")
      public static let positionals = ["attachments", "add-webpage"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct UpdateWebpage: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update-webpage")
      public static let positionals = ["attachments", "update-webpage"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Rename: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rename")
      public static let positionals = ["attachments", "rename"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Remove: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove")
      public static let positionals = ["attachments", "remove"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Export: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export")
      public static let positionals = ["attachments", "export"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ExportPDF: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export-pdf")
      public static let positionals = ["attachments", "export-pdf"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Scan: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "scan",
        subcommands: [Search.self, Inspect.self, Capture.self, Crop.self, Rotate.self, Filter.self, Page.self]
      )
      public init() {}

      public struct Search: Leaf {
        public static let configuration = CommandConfiguration(commandName: "search")
        public static let positionals = ["attachments", "scan", "search"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Inspect: Leaf {
        public static let configuration = CommandConfiguration(commandName: "inspect")
        public static let positionals = ["attachments", "scan", "inspect"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Capture: Leaf {
        public static let configuration = CommandConfiguration(commandName: "capture")
        public static let positionals = ["attachments", "scan", "capture"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Crop: Leaf {
        public static let configuration = CommandConfiguration(commandName: "crop")
        public static let positionals = ["attachments", "scan", "crop"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Rotate: Leaf {
        public static let configuration = CommandConfiguration(commandName: "rotate")
        public static let positionals = ["attachments", "scan", "rotate"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Filter: Leaf {
        public static let configuration = CommandConfiguration(commandName: "filter")
        public static let positionals = ["attachments", "scan", "filter"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Page: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "page",
          subcommands: [Move.self, Delete.self]
        )
        public init() {}

        public struct Move: Leaf {
          public static let configuration = CommandConfiguration(commandName: "move")
          public static let positionals = ["attachments", "scan", "page", "move"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Delete: Leaf {
          public static let configuration = CommandConfiguration(commandName: "delete")
          public static let positionals = ["attachments", "scan", "page", "delete"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }
      }
    }

      public struct PDF: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "pdf",
        subcommands: [Search.self, Inspect.self, Crop.self, Page.self, Edit.self]
        )
        public init() {}

      public struct Search: Leaf {
        public static let configuration = CommandConfiguration(commandName: "search")
        public static let positionals = ["attachments", "pdf", "search"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Inspect: Leaf {
        public static let configuration = CommandConfiguration(commandName: "inspect")
        public static let positionals = ["attachments", "pdf", "inspect"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Crop: Leaf {
        public static let configuration = CommandConfiguration(commandName: "crop")
        public static let positionals = ["attachments", "pdf", "crop"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Page: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "page",
          subcommands: [Rotate.self, Move.self, Delete.self]
        )
        public init() {}

        public struct Rotate: Leaf {
          public static let configuration = CommandConfiguration(commandName: "rotate")
          public static let positionals = ["attachments", "pdf", "page", "rotate"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Move: Leaf {
          public static let configuration = CommandConfiguration(commandName: "move")
          public static let positionals = ["attachments", "pdf", "page", "move"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Delete: Leaf {
          public static let configuration = CommandConfiguration(commandName: "delete")
          public static let positionals = ["attachments", "pdf", "page", "delete"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }
      }

      public struct Edit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "edit")
        public static let positionals = ["attachments", "pdf", "edit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Image: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "image",
        subcommands: [Search.self, Description.self, Crop.self, Rotate.self, Objects.self]
      )
      public init() {}

      public struct Search: Leaf {
        public static let configuration = CommandConfiguration(commandName: "search")
        public static let positionals = ["attachments", "image", "search"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Description: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "description",
          subcommands: [Get.self, Set.self]
        )
        public init() {}

        public struct Get: Leaf {
          public static let configuration = CommandConfiguration(commandName: "get")
          public static let positionals = ["attachments", "image", "description", "get"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Set: Leaf {
          public static let configuration = CommandConfiguration(commandName: "set")
          public static let positionals = ["attachments", "image", "description", "set"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }
      }

      public struct Objects: Leaf {
        public static let configuration = CommandConfiguration(commandName: "objects")
        public static let positionals = ["attachments", "image", "objects"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Crop: Leaf {
        public static let configuration = CommandConfiguration(commandName: "crop")
        public static let positionals = ["attachments", "image", "crop"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Rotate: Leaf {
        public static let configuration = CommandConfiguration(commandName: "rotate")
        public static let positionals = ["attachments", "image", "rotate"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Drawing: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "drawing",
        subcommands: [Search.self]
      )
      public init() {}

      public struct Search: Leaf {
        public static let configuration = CommandConfiguration(commandName: "search")
        public static let positionals = ["attachments", "drawing", "search"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct RecognizedText: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "recognized-text",
        subcommands: [Generate.self, Export.self, Index.self]
      )
      public init() {}

      public struct Generate: Leaf {
        public static let configuration = CommandConfiguration(commandName: "generate")
        public static let positionals = ["attachments", "recognized-text", "generate"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Export: Leaf {
        public static let configuration = CommandConfiguration(commandName: "export")
        public static let positionals = ["attachments", "recognized-text", "export"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Index: Leaf {
        public static let configuration = CommandConfiguration(commandName: "index")
        public static let positionals = ["attachments", "recognized-text", "index"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Audio: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "audio",
        subcommands: [
          Audit.self, Record.self, Rename.self, Save.self, Delete.self, Transcribe.self,
          Edit.self, EditTranscript.self, Transcript.self, CopyTranscript.self, Search.self,
        ]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["attachments", "audio", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Record: Leaf {
        public static let configuration = CommandConfiguration(commandName: "record")
        public static let positionals = ["attachments", "audio", "record"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Transcribe: Leaf {
        public static let configuration = CommandConfiguration(commandName: "transcribe")
        public static let positionals = ["attachments", "audio", "transcribe"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Edit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "edit")
        public static let positionals = ["attachments", "audio", "edit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct EditTranscript: Leaf {
        public static let configuration = CommandConfiguration(commandName: "edit-transcript")
        public static let positionals = ["attachments", "audio", "edit-transcript"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Rename: Leaf {
        public static let configuration = CommandConfiguration(commandName: "rename")
        public static let positionals = ["attachments", "audio", "rename"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Save: Leaf {
        public static let configuration = CommandConfiguration(commandName: "save")
        public static let positionals = ["attachments", "audio", "save"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(commandName: "delete")
        public static let positionals = ["attachments", "audio", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Transcript: Leaf {
        public static let configuration = CommandConfiguration(commandName: "transcript")
        public static let positionals = ["attachments", "audio", "transcript"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct CopyTranscript: Leaf {
        public static let configuration = CommandConfiguration(commandName: "copy-transcript")
        public static let positionals = ["attachments", "audio", "copy-transcript"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Search: Leaf {
        public static let configuration = CommandConfiguration(commandName: "search")
        public static let positionals = ["attachments", "audio", "search"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Markup: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "markup",
        subcommands: [
          Inspect.self, Edit.self, AddShape.self, AddText.self, AddSignature.self,
          Highlight.self, Sketch.self, Draw.self, ShapeStyle.self, BorderColor.self,
          FillColor.self, TextStyle.self, Annotate.self,
        ]
      )
      public init() {}

      public struct Inspect: Leaf {
        public static let configuration = CommandConfiguration(commandName: "inspect")
        public static let positionals = ["attachments", "markup", "inspect"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Edit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "edit")
        public static let positionals = ["attachments", "markup", "edit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct AddShape: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add-shape")
        public static let positionals = ["attachments", "markup", "add-shape"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct AddText: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add-text")
        public static let positionals = ["attachments", "markup", "add-text"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct AddSignature: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add-signature")
        public static let positionals = ["attachments", "markup", "add-signature"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Highlight: Leaf {
        public static let configuration = CommandConfiguration(commandName: "highlight")
        public static let positionals = ["attachments", "markup", "highlight"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Sketch: Leaf {
        public static let configuration = CommandConfiguration(commandName: "sketch")
        public static let positionals = ["attachments", "markup", "sketch"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Draw: Leaf {
        public static let configuration = CommandConfiguration(commandName: "draw")
        public static let positionals = ["attachments", "markup", "draw"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct ShapeStyle: Leaf {
        public static let configuration = CommandConfiguration(commandName: "shape-style")
        public static let positionals = ["attachments", "markup", "shape-style"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct BorderColor: Leaf {
        public static let configuration = CommandConfiguration(commandName: "border-color")
        public static let positionals = ["attachments", "markup", "border-color"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct FillColor: Leaf {
        public static let configuration = CommandConfiguration(commandName: "fill-color")
        public static let positionals = ["attachments", "markup", "fill-color"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct TextStyle: Leaf {
        public static let configuration = CommandConfiguration(commandName: "text-style")
        public static let positionals = ["attachments", "markup", "text-style"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Annotate: Leaf {
        public static let configuration = CommandConfiguration(commandName: "annotate")
        public static let positionals = ["attachments", "markup", "annotate"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }
  }

  public struct Links: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "links",
      subcommands: [
        List.self, Audit.self, Backlinks.self, Resolve.self, Add.self, AddApp.self, AddFile.self, AddNote.self, AddParagraph.self, Update.self,
        UpdateApp.self, UpdateFile.self, UpdateNote.self, UpdateParagraph.self, Remove.self, RemoveApp.self, RemoveNote.self, RemoveParagraph.self,
        RemoveFile.self,
      ]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["links", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["links", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Backlinks: Leaf {
      public static let configuration = CommandConfiguration(commandName: "backlinks")
      public static let positionals = ["links", "backlinks"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Resolve: Leaf {
      public static let configuration = CommandConfiguration(commandName: "resolve")
      public static let positionals = ["links", "resolve"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Add: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add")
      public static let positionals = ["links", "add"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AddApp: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-app")
      public static let positionals = ["links", "add-app"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AddFile: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-file")
      public static let positionals = ["links", "add-file"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AddNote: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-note")
      public static let positionals = ["links", "add-note"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AddParagraph: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-paragraph")
      public static let positionals = ["links", "add-paragraph"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Update: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update")
      public static let positionals = ["links", "update"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct UpdateApp: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update-app")
      public static let positionals = ["links", "update-app"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct UpdateFile: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update-file")
      public static let positionals = ["links", "update-file"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct UpdateNote: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update-note")
      public static let positionals = ["links", "update-note"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct UpdateParagraph: Leaf {
      public static let configuration = CommandConfiguration(commandName: "update-paragraph")
      public static let positionals = ["links", "update-paragraph"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Remove: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove")
      public static let positionals = ["links", "remove"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveApp: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-app")
      public static let positionals = ["links", "remove-app"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveNote: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-note")
      public static let positionals = ["links", "remove-note"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveParagraph: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-paragraph")
      public static let positionals = ["links", "remove-paragraph"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveFile: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-file")
      public static let positionals = ["links", "remove-file"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

    public struct Body: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "body",
      subcommands: [
        Structure.self, Surfaces.self, Format.self, Collapsible.self, Paragraph.self, Inline.self, Checklist.self,
        List.self, Table.self, Math.self,
      ]
    )
    public init() {}

    public struct Structure: Leaf {
      public static let configuration = CommandConfiguration(commandName: "structure")
      public static let positionals = ["body", "structure"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Surfaces: Leaf {
      public static let configuration = CommandConfiguration(commandName: "surfaces")
      public static let positionals = ["body", "surfaces"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Format: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "format",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["body", "format", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Collapsible: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "collapsible",
        subcommands: [List.self, Set.self]
      )
      public init() {}

      public struct List: Leaf {
        public static let configuration = CommandConfiguration(commandName: "list")
        public static let positionals = ["body", "collapsible", "list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Set: Leaf {
        public static let configuration = CommandConfiguration(commandName: "set")
        public static let positionals = ["body", "collapsible", "set"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Paragraph: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "paragraph",
        subcommands: [Style.self, Align.self, Quote.self]
      )
      public init() {}

      public struct Style: Leaf {
        public static let configuration = CommandConfiguration(commandName: "style")
        public static let positionals = ["body", "paragraph", "style"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Align: Leaf {
        public static let configuration = CommandConfiguration(commandName: "align")
        public static let positionals = ["body", "paragraph", "align"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Quote: Leaf {
        public static let configuration = CommandConfiguration(commandName: "quote")
        public static let positionals = ["body", "paragraph", "quote"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Inline: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "inline",
        subcommands: [Format.self, Color.self, Highlight.self, Font.self]
      )
      public init() {}

      public struct Format: Leaf {
        public static let configuration = CommandConfiguration(commandName: "format")
        public static let positionals = ["body", "inline", "format"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Color: Leaf {
        public static let configuration = CommandConfiguration(commandName: "color")
        public static let positionals = ["body", "inline", "color"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Highlight: Leaf {
        public static let configuration = CommandConfiguration(commandName: "highlight")
        public static let positionals = ["body", "inline", "highlight"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Font: Leaf {
        public static let configuration = CommandConfiguration(commandName: "font")
        public static let positionals = ["body", "inline", "font"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

      public struct Checklist: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "checklist",
        subcommands: [
          Add.self, Set.self, SetAll.self, Sort.self, Convert.self, ConvertRange.self, Reorder.self, Indent.self,
          Delete.self, LineBreak.self, End.self,
        ]
      )
      public init() {}

      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add")
        public static let positionals = ["body", "checklist", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Set: Leaf {
        public static let configuration = CommandConfiguration(commandName: "set")
        public static let positionals = ["body", "checklist", "set"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct SetAll: Leaf {
        public static let configuration = CommandConfiguration(commandName: "set-all")
        public static let positionals = ["body", "checklist", "set-all"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Sort: Leaf {
        public static let configuration = CommandConfiguration(commandName: "sort")
        public static let positionals = ["body", "checklist", "sort"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Convert: Leaf {
        public static let configuration = CommandConfiguration(commandName: "convert")
        public static let positionals = ["body", "checklist", "convert"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct ConvertRange: Leaf {
        public static let configuration = CommandConfiguration(commandName: "convert-range")
        public static let positionals = ["body", "checklist", "convert-range"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Reorder: Leaf {
        public static let configuration = CommandConfiguration(commandName: "reorder")
        public static let positionals = ["body", "checklist", "reorder"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Indent: Leaf {
        public static let configuration = CommandConfiguration(commandName: "indent")
        public static let positionals = ["body", "checklist", "indent"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(commandName: "delete")
        public static let positionals = ["body", "checklist", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct LineBreak: Leaf {
        public static let configuration = CommandConfiguration(commandName: "line-break")
        public static let positionals = ["body", "checklist", "line-break"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct End: Leaf {
        public static let configuration = CommandConfiguration(commandName: "end")
        public static let positionals = ["body", "checklist", "end"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct List: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "list",
        subcommands: [
          Add.self, Convert.self, ConvertRange.self, SetStyle.self, Reorder.self, Indent.self, Delete.self,
          LineBreak.self, Tab.self, End.self,
        ]
      )
      public init() {}

      public struct Add: Leaf {
        public static let configuration = CommandConfiguration(commandName: "add")
        public static let positionals = ["body", "list", "add"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Convert: Leaf {
        public static let configuration = CommandConfiguration(commandName: "convert")
        public static let positionals = ["body", "list", "convert"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct ConvertRange: Leaf {
        public static let configuration = CommandConfiguration(commandName: "convert-range")
        public static let positionals = ["body", "list", "convert-range"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct SetStyle: Leaf {
        public static let configuration = CommandConfiguration(commandName: "set-style")
        public static let positionals = ["body", "list", "set-style"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Reorder: Leaf {
        public static let configuration = CommandConfiguration(commandName: "reorder")
        public static let positionals = ["body", "list", "reorder"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Indent: Leaf {
        public static let configuration = CommandConfiguration(commandName: "indent")
        public static let positionals = ["body", "list", "indent"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(commandName: "delete")
        public static let positionals = ["body", "list", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct LineBreak: Leaf {
        public static let configuration = CommandConfiguration(commandName: "line-break")
        public static let positionals = ["body", "list", "line-break"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Tab: Leaf {
        public static let configuration = CommandConfiguration(commandName: "tab")
        public static let positionals = ["body", "list", "tab"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct End: Leaf {
        public static let configuration = CommandConfiguration(commandName: "end")
        public static let positionals = ["body", "list", "end"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Table: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "table",
        subcommands: [
          List.self, Create.self, Import.self, Update.self, Delete.self, ConvertToText.self, ConvertFromText.self, Copy.self, Move.self,
          Rows.self, Columns.self,
        ]
      )
      public init() {}

      public struct List: Leaf {
        public static let configuration = CommandConfiguration(commandName: "list")
        public static let positionals = ["body", "table", "list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Create: Leaf {
        public static let configuration = CommandConfiguration(commandName: "create")
        public static let positionals = ["body", "table", "create"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Import: Leaf {
        public static let configuration = CommandConfiguration(commandName: "import")
        public static let positionals = ["body", "table", "import"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Update: Leaf {
        public static let configuration = CommandConfiguration(commandName: "update")
        public static let positionals = ["body", "table", "update"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Delete: Leaf {
        public static let configuration = CommandConfiguration(commandName: "delete")
        public static let positionals = ["body", "table", "delete"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct ConvertToText: Leaf {
        public static let configuration = CommandConfiguration(commandName: "convert-to-text")
        public static let positionals = ["body", "table", "convert-to-text"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct ConvertFromText: Leaf {
        public static let configuration = CommandConfiguration(commandName: "convert-from-text")
        public static let positionals = ["body", "table", "convert-from-text"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Copy: Leaf {
        public static let configuration = CommandConfiguration(commandName: "copy")
        public static let positionals = ["body", "table", "copy"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Move: Leaf {
        public static let configuration = CommandConfiguration(commandName: "move")
        public static let positionals = ["body", "table", "move"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Rows: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "rows",
          subcommands: [Insert.self, Delete.self, Move.self, Copy.self, Clear.self, Format.self]
        )
        public init() {}

        public struct Insert: Leaf {
          public static let configuration = CommandConfiguration(commandName: "insert")
          public static let positionals = ["body", "table", "rows", "insert"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Delete: Leaf {
          public static let configuration = CommandConfiguration(commandName: "delete")
          public static let positionals = ["body", "table", "rows", "delete"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Move: Leaf {
          public static let configuration = CommandConfiguration(commandName: "move")
          public static let positionals = ["body", "table", "rows", "move"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Copy: Leaf {
          public static let configuration = CommandConfiguration(commandName: "copy")
          public static let positionals = ["body", "table", "rows", "copy"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Clear: Leaf {
          public static let configuration = CommandConfiguration(commandName: "clear")
          public static let positionals = ["body", "table", "rows", "clear"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Format: Leaf {
          public static let configuration = CommandConfiguration(commandName: "format")
          public static let positionals = ["body", "table", "rows", "format"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }
      }

      public struct Columns: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "columns",
          subcommands: [Insert.self, Delete.self, Move.self, Copy.self, Clear.self, Format.self]
        )
        public init() {}

        public struct Insert: Leaf {
          public static let configuration = CommandConfiguration(commandName: "insert")
          public static let positionals = ["body", "table", "columns", "insert"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Delete: Leaf {
          public static let configuration = CommandConfiguration(commandName: "delete")
          public static let positionals = ["body", "table", "columns", "delete"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Move: Leaf {
          public static let configuration = CommandConfiguration(commandName: "move")
          public static let positionals = ["body", "table", "columns", "move"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Copy: Leaf {
          public static let configuration = CommandConfiguration(commandName: "copy")
          public static let positionals = ["body", "table", "columns", "copy"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Clear: Leaf {
          public static let configuration = CommandConfiguration(commandName: "clear")
          public static let positionals = ["body", "table", "columns", "clear"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Format: Leaf {
          public static let configuration = CommandConfiguration(commandName: "format")
          public static let positionals = ["body", "table", "columns", "format"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }
      }
    }

    public struct Math: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "math",
        subcommands: [
          Audit.self, List.self, VerifyExpression.self, Results.self, Insert.self, Update.self, Variable.self,
        ]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["body", "math", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct List: Leaf {
        public static let configuration = CommandConfiguration(commandName: "list")
        public static let positionals = ["body", "math", "list"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct VerifyExpression: Leaf {
        public static let configuration = CommandConfiguration(commandName: "verify-expression")
        public static let positionals = ["body", "math", "verify-expression"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Results: Leaf {
        public static let configuration = CommandConfiguration(commandName: "results")
        public static let positionals = ["body", "math", "results"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Insert: Leaf {
        public static let configuration = CommandConfiguration(commandName: "insert")
        public static let positionals = ["body", "math", "insert"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Update: Leaf {
        public static let configuration = CommandConfiguration(commandName: "update")
        public static let positionals = ["body", "math", "update"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }

      public struct Variable: ParsableCommand {
        public static let configuration = CommandConfiguration(
          commandName: "variable",
          subcommands: [Set.self, Update.self]
        )
        public init() {}

        public struct Set: Leaf {
          public static let configuration = CommandConfiguration(commandName: "set")
          public static let positionals = ["body", "math", "variable", "set"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }

        public struct Update: Leaf {
          public static let configuration = CommandConfiguration(commandName: "update")
          public static let positionals = ["body", "math", "variable", "update"]
          @OptionGroup public var shared: CLISharedOptions
          @OptionGroup public var targetOptions: NotesTargetOptions
          public init() {}
        }
      }
    }
  }

  public struct State: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "state",
      subcommands: [
        Read.self, Audit.self, Lockability.self, Collaboration.self, Security.self, Lock.self, Unlock.self,
        RemoveLock.self, CloseLocked.self, ExportLockedContent.self, Share.self, ShareFolder.self, StopSharing.self, Invite.self,
        RemoveParticipant.self, SetPermission.self, AllowInvites.self, CopyLink.self, Participants.self, RemoveSelf.self,
        HideAlerts.self, Mention.self, Activity.self, FolderPermission.self, ChangePassword.self,
      ]
    )
    public init() {}

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["state", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["state", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Lockability: Leaf {
      public static let configuration = CommandConfiguration(commandName: "lockability")
      public static let positionals = ["state", "lockability"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Collaboration: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "collaboration",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["state", "collaboration", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Security: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "security",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["state", "security", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }

    public struct Lock: Leaf {
      public static let configuration = CommandConfiguration(commandName: "lock")
      public static let positionals = ["state", "lock"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Unlock: Leaf {
      public static let configuration = CommandConfiguration(commandName: "unlock")
      public static let positionals = ["state", "unlock"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveLock: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-lock")
      public static let positionals = ["state", "remove-lock"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct CloseLocked: Leaf {
      public static let configuration = CommandConfiguration(commandName: "close-locked")
      public static let positionals = ["state", "close-locked"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ExportLockedContent: Leaf {
      public static let configuration = CommandConfiguration(commandName: "export-locked-content")
      public static let positionals = ["state", "export-locked-content"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Share: Leaf {
      public static let configuration = CommandConfiguration(commandName: "share")
      public static let positionals = ["state", "share"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ShareFolder: Leaf {
      public static let configuration = CommandConfiguration(commandName: "share-folder")
      public static let positionals = ["state", "share-folder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct StopSharing: Leaf {
      public static let configuration = CommandConfiguration(commandName: "stop-sharing")
      public static let positionals = ["state", "stop-sharing"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Invite: Leaf {
      public static let configuration = CommandConfiguration(commandName: "invite")
      public static let positionals = ["state", "invite"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveParticipant: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-participant")
      public static let positionals = ["state", "remove-participant"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct SetPermission: Leaf {
      public static let configuration = CommandConfiguration(commandName: "set-permission")
      public static let positionals = ["state", "set-permission"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AllowInvites: Leaf {
      public static let configuration = CommandConfiguration(commandName: "allow-invites")
      public static let positionals = ["state", "allow-invites"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct CopyLink: Leaf {
      public static let configuration = CommandConfiguration(commandName: "copy-link")
      public static let positionals = ["state", "copy-link"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Participants: Leaf {
      public static let configuration = CommandConfiguration(commandName: "participants")
      public static let positionals = ["state", "participants"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RemoveSelf: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-self")
      public static let positionals = ["state", "remove-self"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct HideAlerts: Leaf {
      public static let configuration = CommandConfiguration(commandName: "hide-alerts")
      public static let positionals = ["state", "hide-alerts"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Mention: Leaf {
      public static let configuration = CommandConfiguration(commandName: "mention")
      public static let positionals = ["state", "mention"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Activity: Leaf {
      public static let configuration = CommandConfiguration(commandName: "activity")
      public static let positionals = ["state", "activity"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct FolderPermission: Leaf {
      public static let configuration = CommandConfiguration(commandName: "folder-permission")
      public static let positionals = ["state", "folder-permission"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ChangePassword: Leaf {
      public static let configuration = CommandConfiguration(commandName: "change-password")
      public static let positionals = ["state", "change-password"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

    public struct Settings: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "settings",
      subcommands: [
        Read.self, Audit.self, Sort.self, NewNoteStyle.self, DefaultAccount.self, GroupByDate.self,
        QuickNoteResume.self, ChecklistSort.self, MentionNotifications.self, OnMyMac.self,
        TextSize.self, LockedNotes.self, ChangePassword.self, ResetPassword.self, TouchID.self,
        ViewLayout.self, LinkHighlightColor.self, Notifications.self, Widgets.self, Password.self,
      ]
    )
    public init() {}

    public struct Read: Leaf {
      public static let configuration = CommandConfiguration(commandName: "read")
      public static let positionals = ["settings", "read"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["settings", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Sort: Leaf {
      public static let configuration = CommandConfiguration(commandName: "sort")
      public static let positionals = ["settings", "sort"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct NewNoteStyle: Leaf {
      public static let configuration = CommandConfiguration(commandName: "new-note-style")
      public static let positionals = ["settings", "new-note-style"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct DefaultAccount: Leaf {
      public static let configuration = CommandConfiguration(commandName: "default-account")
      public static let positionals = ["settings", "default-account"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct GroupByDate: Leaf {
      public static let configuration = CommandConfiguration(commandName: "group-by-date")
      public static let positionals = ["settings", "group-by-date"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct QuickNoteResume: Leaf {
      public static let configuration = CommandConfiguration(commandName: "quick-note-resume")
      public static let positionals = ["settings", "quick-note-resume"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ChecklistSort: Leaf {
      public static let configuration = CommandConfiguration(commandName: "checklist-sort")
      public static let positionals = ["settings", "checklist-sort"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct MentionNotifications: Leaf {
      public static let configuration = CommandConfiguration(commandName: "mention-notifications")
      public static let positionals = ["settings", "mention-notifications"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct OnMyMac: Leaf {
      public static let configuration = CommandConfiguration(commandName: "on-my-mac")
      public static let positionals = ["settings", "on-my-mac"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct TextSize: Leaf {
      public static let configuration = CommandConfiguration(commandName: "text-size")
      public static let positionals = ["settings", "text-size"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct LockedNotes: Leaf {
      public static let configuration = CommandConfiguration(commandName: "locked-notes")
      public static let positionals = ["settings", "locked-notes"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ChangePassword: Leaf {
      public static let configuration = CommandConfiguration(commandName: "change-password")
      public static let positionals = ["settings", "change-password"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ResetPassword: Leaf {
      public static let configuration = CommandConfiguration(commandName: "reset-password")
      public static let positionals = ["settings", "reset-password"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct TouchID: Leaf {
      public static let configuration = CommandConfiguration(commandName: "touch-id")
      public static let positionals = ["settings", "touch-id"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ViewLayout: Leaf {
      public static let configuration = CommandConfiguration(commandName: "view-layout")
      public static let positionals = ["settings", "view-layout"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct LinkHighlightColor: Leaf {
      public static let configuration = CommandConfiguration(commandName: "link-highlight-color")
      public static let positionals = ["settings", "link-highlight-color"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Notifications: Leaf {
      public static let configuration = CommandConfiguration(commandName: "notifications")
      public static let positionals = ["settings", "notifications"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Widgets: Leaf {
      public static let configuration = CommandConfiguration(commandName: "widgets")
      public static let positionals = ["settings", "widgets"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Password: Leaf {
      public static let configuration = CommandConfiguration(commandName: "password")
      public static let positionals = ["settings", "password"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct List: Leaf {
    public static let configuration = CommandConfiguration(commandName: "list")
    public static let positionals = ["notes", "list"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Guide: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "guide",
      subcommands: [Audit.self]
    )
    public init() {}

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["notes", "guide", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Workflow: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "workflow",
      subcommands: [Audit.self, Shortcuts.self]
    )
    public init() {}

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["notes", "workflow", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Shortcuts: ParsableCommand {
      public static let configuration = CommandConfiguration(
        commandName: "shortcuts",
        subcommands: [Audit.self]
      )
      public init() {}

      public struct Audit: Leaf {
        public static let configuration = CommandConfiguration(commandName: "audit")
        public static let positionals = ["notes", "workflow", "shortcuts", "audit"]
        @OptionGroup public var shared: CLISharedOptions
        @OptionGroup public var targetOptions: NotesTargetOptions
        public init() {}
      }
    }
  }

  public struct QuickNote: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "quick-note",
      subcommands: [Create.self]
    )
    public init() {}

    public struct Create: Leaf {
      public static let configuration = CommandConfiguration(commandName: "create")
      public static let positionals = ["notes", "quick-note", "create"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Search: Leaf {
    public static let configuration = CommandConfiguration(
      commandName: "search",
      subcommands: [Audit.self, NaturalLanguage.self, AttachmentContent.self, LockedTitle.self]
    )
    public static let positionals = ["notes", "search"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["notes", "search", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct NaturalLanguage: Leaf {
      public static let configuration = CommandConfiguration(commandName: "natural-language")
      public static let positionals = ["notes", "search", "natural-language"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct AttachmentContent: Leaf {
      public static let configuration = CommandConfiguration(commandName: "attachment-content")
      public static let positionals = ["notes", "search", "attachment-content"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct LockedTitle: Leaf {
      public static let configuration = CommandConfiguration(commandName: "locked-title")
      public static let positionals = ["notes", "search", "locked-title"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Index: Leaf {
    public static let configuration = CommandConfiguration(commandName: "index")
    public static let positionals = ["notes", "index"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct SemanticSearch: Leaf {
    public static let configuration = CommandConfiguration(commandName: "semantic-search")
    public static let positionals = ["notes", "semantic-search"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Read: Leaf {
    public static let configuration = CommandConfiguration(commandName: "read")
    public static let positionals = ["notes", "read"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Create: Leaf {
    public static let configuration = CommandConfiguration(commandName: "create")
    public static let positionals = ["notes", "create"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Import: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "import",
      subcommands: [Audit.self, Folder.self, Text.self, Markdown.self, RTF.self, RTFD.self, HTML.self, ENEX.self]
    )
    public init() {}

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["notes", "import", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Folder: Leaf {
      public static let configuration = CommandConfiguration(commandName: "folder")
      public static let positionals = ["notes", "import", "folder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Text: Leaf {
      public static let configuration = CommandConfiguration(commandName: "text")
      public static let positionals = ["notes", "import", "text"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Markdown: Leaf {
      public static let configuration = CommandConfiguration(commandName: "markdown")
      public static let positionals = ["notes", "import", "markdown"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RTF: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rtf")
      public static let positionals = ["notes", "import", "rtf"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RTFD: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rtfd")
      public static let positionals = ["notes", "import", "rtfd"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct HTML: Leaf {
      public static let configuration = CommandConfiguration(commandName: "html")
      public static let positionals = ["notes", "import", "html"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct ENEX: Leaf {
      public static let configuration = CommandConfiguration(commandName: "enex")
      public static let positionals = ["notes", "import", "enex"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Export: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "export",
      subcommands: [Audit.self, PDF.self, Markdown.self, HTML.self, RTF.self, RTFD.self]
    )
    public init() {}

    public struct Audit: Leaf {
      public static let configuration = CommandConfiguration(commandName: "audit")
      public static let positionals = ["notes", "export", "audit"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct PDF: Leaf {
      public static let configuration = CommandConfiguration(commandName: "pdf")
      public static let positionals = ["notes", "export", "pdf"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct HTML: Leaf {
      public static let configuration = CommandConfiguration(commandName: "html")
      public static let positionals = ["notes", "export", "html"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Markdown: Leaf {
      public static let configuration = CommandConfiguration(commandName: "markdown")
      public static let positionals = ["notes", "export", "markdown"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RTF: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rtf")
      public static let positionals = ["notes", "export", "rtf"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RTFD: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rtfd")
      public static let positionals = ["notes", "export", "rtfd"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Replace: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "replace",
      subcommands: [Markdown.self, HTML.self, RTF.self, RTFD.self]
    )
    public init() {}

    public struct Markdown: Leaf {
      public static let configuration = CommandConfiguration(commandName: "markdown")
      public static let positionals = ["notes", "replace", "markdown"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct HTML: Leaf {
      public static let configuration = CommandConfiguration(commandName: "html")
      public static let positionals = ["notes", "replace", "html"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RTF: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rtf")
      public static let positionals = ["notes", "replace", "rtf"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RTFD: Leaf {
      public static let configuration = CommandConfiguration(commandName: "rtfd")
      public static let positionals = ["notes", "replace", "rtfd"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Print: Leaf {
    public static let configuration = CommandConfiguration(commandName: "print")
    public static let positionals = ["notes", "print"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct OpenInPages: Leaf {
    public static let configuration = CommandConfiguration(commandName: "open-in-pages")
    public static let positionals = ["notes", "open-in-pages"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Update: Leaf {
    public static let configuration = CommandConfiguration(commandName: "update")
    public static let positionals = ["notes", "update"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Append: Leaf {
    public static let configuration = CommandConfiguration(commandName: "append")
    public static let positionals = ["notes", "append"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Move: Leaf {
    public static let configuration = CommandConfiguration(commandName: "move")
    public static let positionals = ["notes", "move"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Copy: Leaf {
    public static let configuration = CommandConfiguration(commandName: "copy")
    public static let positionals = ["notes", "copy"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Restore: Leaf {
    public static let configuration = CommandConfiguration(commandName: "restore")
    public static let positionals = ["notes", "restore"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct RestoreAll: Leaf {
    public static let configuration = CommandConfiguration(commandName: "restore-all")
    public static let positionals = ["notes", "restore-all"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Delete: Leaf {
    public static let configuration = CommandConfiguration(commandName: "delete")
    public static let positionals = ["notes", "delete"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Purge: Leaf {
    public static let configuration = CommandConfiguration(commandName: "purge")
    public static let positionals = ["notes", "purge"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct EmptyTrash: Leaf {
    public static let configuration = CommandConfiguration(commandName: "empty-trash")
    public static let positionals = ["notes", "empty-trash"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Pin: Leaf {
    public static let configuration = CommandConfiguration(commandName: "pin")
    public static let positionals = ["notes", "pin"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Unpin: Leaf {
    public static let configuration = CommandConfiguration(commandName: "unpin")
    public static let positionals = ["notes", "unpin"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: NotesTargetOptions
    public init() {}
  }

  public struct Batch: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "batch",
      subcommands: [Pin.self, Unpin.self, Move.self, Copy.self, Delete.self]
    )
    public init() {}

    public struct Pin: Leaf {
      public static let configuration = CommandConfiguration(commandName: "pin")
      public static let positionals = ["notes", "batch", "pin"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Unpin: Leaf {
      public static let configuration = CommandConfiguration(commandName: "unpin")
      public static let positionals = ["notes", "batch", "unpin"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Move: Leaf {
      public static let configuration = CommandConfiguration(commandName: "move")
      public static let positionals = ["notes", "batch", "move"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Copy: Leaf {
      public static let configuration = CommandConfiguration(commandName: "copy")
      public static let positionals = ["notes", "batch", "copy"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Delete: Leaf {
      public static let configuration = CommandConfiguration(commandName: "delete")
      public static let positionals = ["notes", "batch", "delete"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "doctor",
      abstract: "Notes readiness and read-only diagnostic checks.",
      subcommands: [Store.self, Note.self, Folder.self, Account.self, WriteLab.self, RichLab.self]
    )
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: NotesTarget.targetName,
        checks: notesDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }

    public struct Store: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "store",
        abstract: "Inspect read-only Notes store and index evidence."
      )
      public static let positionals = ["doctor", "store"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Note: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "note",
        abstract: "Inspect read-only private-framework and store evidence for one note."
      )
      public static let positionals = ["doctor", "note"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Folder: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "folder",
        abstract: "Inspect read-only private-framework and store evidence for one folder."
      )
      public static let positionals = ["doctor", "folder"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct Account: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "account",
        abstract: "Inspect read-only private-framework and store evidence for one account."
      )
      public static let positionals = ["doctor", "account"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct WriteLab: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "write-lab",
        abstract: "Probe private Notes write selectors without executing a write."
      )
      public static let positionals = ["doctor", "write-lab"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }

    public struct RichLab: Leaf {
      public static let configuration = CommandConfiguration(
        commandName: "rich-lab",
        abstract: "Probe private Notes rich capability candidates without executing a write."
      )
      public static let positionals = ["doctor", "rich-lab"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: NotesTargetOptions
      public init() {}
    }
  }
}

extension NotesTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try NotesCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Command is documented but this target implementation is not implemented yet.",
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
    var targetOptions: NotesTargetOptions { get }
  }
}

extension NotesTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try NotesTarget.runCommand(options: options)
  }
}

public struct NotesTargetOptions: ParsableArguments, Sendable {
  @Option public var account: String?
  @Option public var provider: String?
  @Option public var folder: String?
  @Option public var parent: String?
  @Option public var name: String?
  @Option public var query: String?
  @Option public var id: String?
  @Option public var ids: String?
  @Option public var title: String?
  @Option public var body: String?
  @Option public var text: String?
  @Option public var description: String?
  @Option public var format: String?
  @Option public var family: String?
  @Option public var criteria: String?
  @Option public var match: String?
  @Option(name: .customLong("criteria-folder")) public var criteriaFolder: String?
  @Option(name: .customLong("include-criteria-folder")) public var includeCriteriaFolder: String?
  @Option(name: .customLong("exclude-criteria-folder")) public var excludeCriteriaFolder: String?
  @Option public var date: String?
  @Option(name: .customLong("start-date")) public var startDate: String?
  @Option(name: .customLong("end-date")) public var endDate: String?
  @Option(name: .customLong("relative-amount")) public var relativeAmount: String?
  @Option(name: .customLong("relative-unit")) public var relativeUnit: String?
  @Option(name: .customLong("participant-user-id")) public var participantUserID: String?
  @Option public var size: String?
  @Option public var color: String?
  @Option public var style: String?
  @Option public var alignment: String?
  @Option public var tag: String?
  @Option public var tags: String?
  @Option(name: .customLong("include-tags")) public var includeTags: String?
  @Option(name: .customLong("exclude-tags")) public var excludeTags: String?
  @Option public var mode: String?
  @Option public var attachment: String?
  @Option(name: .customLong("top-left")) public var topLeft: String?
  @Option(name: .customLong("top-right")) public var topRight: String?
  @Option(name: .customLong("bottom-right")) public var bottomRight: String?
  @Option(name: .customLong("bottom-left")) public var bottomLeft: String?
  @Option public var file: String?
  @Option public var files: String?
  @Option public var output: String?
  @Option public var content: String?
  @Option public var printer: String?
  @Option public var scope: String?
  @Option public var url: String?
  @Option public var link: String?
  @Option public var target: String?
  @Option public var paragraph: String?
  @Option public var by: String?
  @Option public var direction: String?
  @Option public var enabled: String?
  @Option public var from: String?
  @Option public var to: String?
  @Option public var hint: String?
  @Option(name: .customLong("passphrase-env")) public var passphraseEnv: String?
  @Option(name: .customLong("passphrase-file")) public var passphraseFile: String?
  @Option(name: .customLong("old-passphrase-env")) public var oldPassphraseEnv: String?
  @Option(name: .customLong("old-passphrase-file")) public var oldPassphraseFile: String?
  @Option(name: .customLong("new-passphrase-env")) public var newPassphraseEnv: String?
  @Option(name: .customLong("new-passphrase-file")) public var newPassphraseFile: String?
  @Option public var page: String?
  @Option public var selection: String?
  @Option public var device: String?
  @Option public var shape: String?
  @Option public var signature: String?
  @Option public var ordinal: String?
  @Option public var row: String?
  @Option public var column: String?
  @Option public var occurrence: String?
  @Option public var fromOrdinal: String?
  @Option public var toOrdinal: String?
  @Option public var state: String?
  @Flag public var checked = false
  @Flag public var includeAttachments = false
  @Flag public var includeRecentlyDeleted = false
  @Flag(name: .customLong("allow-merge")) public var allowMerge = false
  @Flag(name: .customLong("use-note-title")) public var useNoteTitle = false
  @Flag(name: .customLong("passphrase-stdin")) public var passphraseStdin = false
  @Flag(name: .customLong("old-passphrase-stdin")) public var oldPassphraseStdin = false
  @Flag(name: .customLong("new-passphrase-stdin")) public var newPassphraseStdin = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("account", account),
      ("provider", provider),
      ("folder", folder),
      ("parent", parent),
      ("name", name),
      ("query", query),
      ("id", id),
      ("title", title),
      ("body", body),
      ("text", text),
      ("description", description),
      ("format", format),
      ("family", family),
      ("criteria", criteria),
      ("match", match),
      ("criteria-folder", criteriaFolder),
      ("include-criteria-folder", includeCriteriaFolder),
      ("exclude-criteria-folder", excludeCriteriaFolder),
      ("date", date),
      ("start-date", startDate),
      ("end-date", endDate),
      ("relative-amount", relativeAmount),
      ("relative-unit", relativeUnit),
      ("participant-user-id", participantUserID),
      ("size", size),
      ("color", color),
      ("style", style),
      ("alignment", alignment),
      ("tag", tag),
      ("tags", tags),
      ("include-tags", includeTags),
      ("exclude-tags", excludeTags),
      ("mode", mode),
      ("attachment", attachment),
      ("top-left", topLeft),
      ("top-right", topRight),
      ("bottom-right", bottomRight),
      ("bottom-left", bottomLeft),
      ("file", file),
      ("files", files),
      ("output", output),
      ("content", content),
      ("printer", printer),
      ("scope", scope),
      ("url", url),
      ("link", link),
      ("target", target),
      ("paragraph", paragraph),
      ("by", by),
      ("direction", direction),
      ("enabled", enabled),
      ("from", from),
      ("to", to),
      ("hint", hint),
      ("passphrase-env", passphraseEnv),
      ("passphrase-file", passphraseFile),
      ("old-passphrase-env", oldPassphraseEnv),
      ("old-passphrase-file", oldPassphraseFile),
      ("new-passphrase-env", newPassphraseEnv),
      ("new-passphrase-file", newPassphraseFile),
      ("page", page),
      ("selection", selection),
      ("shape", shape),
      ("signature", signature),
      ("ordinal", ordinal),
      ("row", row),
      ("column", column),
      ("occurrence", occurrence),
      ("from-ordinal", fromOrdinal),
      ("to-ordinal", toOrdinal),
      ("state", state),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("checked", checked),
      ("include-attachments", includeAttachments),
      ("include-recently-deleted", includeRecentlyDeleted),
      ("allow-merge", allowMerge),
      ("use-note-title", useNoteTitle),
      ("passphrase-stdin", passphraseStdin),
      ("old-passphrase-stdin", oldPassphraseStdin),
      ("new-passphrase-stdin", newPassphraseStdin),
    ])
  }
}

public func notesDoctorChecks() -> [CLIDoctorCheck] {
  var checks = [
    .localPathExists(
      name: "notes_app",
      path: "/System/Applications/Notes.app",
      presentMessage: "Notes app bundle is present.",
      missingMessage: "Notes app bundle was not found at the expected system path."
    ),
    notesStoreDoctorCheck(),
    notesImplementationDoctorCheck(),
    notesRuntimeReadinessDoctorCheck(),
    notesWriteCapabilityDoctorCheck(),
    notesRichCapabilityDoctorCheck(),
  ]

  if notesReadParityDoctorCheckEnabled() {
    checks.append(notesReadParityDoctorCheck())
  }

  return checks
}

private func notesImplementationDoctorCheck() -> CLIDoctorCheck {
  CLIDoctorCheck(
    name: "notes_implementation",
    status: .ok,
    message: "Notes production implementation is active.",
    details: [
      "private_frameworks_linked": "true",
      "writer_modules": "NotesShared/NotesUI",
      "parity_reader": "read_only",
    ]
  )
}
