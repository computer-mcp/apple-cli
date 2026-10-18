import AppleMCPAdapter
import Darwin
import Foundation
import MCP
import Testing
import Utility

#if canImport(System)
  import System
#else
  @preconcurrency import SystemPackage
#endif

@Suite
struct AppleMCPAdapterTests {
  @Test func mcpAdapterListsOnlyAcceptedTargets() async throws {
    let adapter = AppleMCPAdapter(runner: FakeMCPRunner())
    let result = try await adapter.callTool(name: "apple_cli_list_targets", arguments: [:])
    let object = try #require(result.structuredContent?.objectValue)
    let targetValues = try #require(object["targets"]?.arrayValue)
    let targets = targetValues.compactMap { $0.stringValue }

    #expect(result.isError == false)
    #expect(targets.count == 19)
    #expect(targets.contains("notes"))
    #expect(targets.contains("safari"))
    #expect(targets.contains("photos"))
    #expect(targets.contains("notifications"))
    #expect(targets.contains("intelligence"))
    #expect(targets.contains("tcc"))
    #expect(!targets.contains("apple-cli-mcp"))
  }

  @Test func mcpAdapterToolSchemasUseCanonicalTargetEnum() async throws {
    let delay = CLICommandCatalogOption(
      names: ["--delay-seconds"], valueName: "<delay-seconds>", description: "One-time delay.")
    #expect(delay.valueType == "integer")
    let offset = CLICommandCatalogOption(
      names: ["--offset"], valueName: "offset", description: "Number of items to skip.")
    #expect(offset.valueType == "integer")
    let adapter = AppleMCPAdapter(runner: FakeMCPRunner())
    let tools = adapter.tools()
    let runTool = try #require(tools.first { $0.name == "apple_cli_run" })
    let schema = try #require(runTool.inputSchema.objectValue)
    let properties = try #require(schema["properties"]?.objectValue)
    let target = try #require(properties["target"]?.objectValue)
    let targetEnumValues = try #require(target["enum"]?.arrayValue)
    let targetEnum = targetEnumValues.compactMap { $0.stringValue }

    #expect(targetEnum.count == 19)
    #expect(targetEnum.contains("calendar"))
    #expect(targetEnum.contains("safari"))
    #expect(targetEnum.contains("photos"))
    #expect(targetEnum.contains("intelligence"))
    #expect(targetEnum.contains("tcc"))
    let description = try #require(runTool.description)
    #expect(description.contains("dry-run"))
    #expect(description.contains("--allow-*"))
    #expect(description.contains("target-local safety policy"))
    #expect(runTool.annotations.readOnlyHint == false)
    #expect(runTool.annotations.destructiveHint == true)
  }

  @Test func mcpRemindersSurfaceStaysCliDerivedAndBackendNeutral() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)
    let tools = adapter.tools()
    let toolNames = tools.map(\.name)
    let toolText = tools.map {
      "\($0.name) \($0.title ?? "") \($0.description ?? "")"
    }.joined(separator: "\n")
    let runTool = try #require(tools.first { $0.name == "apple_cli_run" })
    let schema = try #require(runTool.inputSchema.objectValue)
    let properties = try #require(schema["properties"]?.objectValue)
    let target = try #require(properties["target"]?.objectValue)
    let targetEnumValues = try #require(target["enum"]?.arrayValue)
    let targetEnum = targetEnumValues.compactMap { $0.stringValue }

    #expect(
      toolNames == [
        "apple_cli_list_targets",
        "apple_cli_doctor",
        "apple_cli_status",
        "apple_cli_help",
        "apple_cli_command_catalog",
        "apple_cli_run",
      ])
    #expect(targetEnum.contains("reminders"))
    #expect(properties["arguments"] != nil)

    for forbidden in [
      "reminderkit",
      "private",
      "backend",
      "app-doctor",
      "app_doctor",
      "accessibility",
      "ax",
      "debug",
    ] {
      #expect(
        !toolText.localizedCaseInsensitiveContains(forbidden),
        "MCP tool surface should not expose Reminders backend/private namespace: \(forbidden)"
      )
    }

    _ = try await adapter.callTool(
      name: "apple_cli_doctor",
      arguments: ["target": .string("reminders")]
    )

    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "reminders", arguments: ["doctor", "--json"], timeoutSeconds: 30)
      ])
  }

  @Test func mcpDoctorMapsToExactCliCommand() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    _ = try await adapter.callTool(
      name: "apple_cli_doctor",
      arguments: ["target": .string("calendar")]
    )

    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "calendar", arguments: ["doctor", "--json"], timeoutSeconds: 30)
      ])
  }

  @Test func mcpStatusMapsToExactTargetStatusCommand() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    _ = try await adapter.callTool(
      name: "apple_cli_status",
      arguments: ["target": .string("notes"), "timeoutSeconds": .int(9)]
    )

    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "notes", arguments: ["--json"], timeoutSeconds: 9)
      ])
  }

  @Test func mcpHelpMapsToNotesSubcommandHelpWithoutJSONAppend() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    _ = try await adapter.callTool(
      name: "apple_cli_help",
      arguments: [
        "target": .string("notes"),
        "arguments": .array([.string("attachments"), .string("export-pdf")]),
        "timeoutSeconds": .int(11),
      ]
    )

    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "notes",
          arguments: ["attachments", "export-pdf", "--help"],
          timeoutSeconds: 11
        )
      ])
  }

  @Test func mcpHelpPreservesExplicitNotesRestoreAllHelpFlag() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    _ = try await adapter.callTool(
      name: "apple_cli_help",
      arguments: [
        "target": .string("notes"),
        "arguments": .array([.string("restore-all"), .string("--help")]),
      ]
    )

    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "notes", arguments: ["restore-all", "--help"], timeoutSeconds: 30)
      ])
  }

  @Test func mcpCommandCatalogDiscoversNotesSettingsFromCliHelp() async throws {
    let runner = FakeMCPRunner()
    runner.helpOutputs = [
      "notes --help": """
      USAGE: apple notes <subcommand>

      OPTIONS:
        -h, --help

      SUBCOMMANDS:
        state
        settings                Read and update the app's settings,
                                including notification preferences.
        smart-folders

        See 'apple help notes <subcommand>' for detailed help.
      """,
      "notes state --help": """
      USAGE: apple notes state <subcommand>

      SUBCOMMANDS:
        read
        audit
        activity
        change-password
      """,
      "notes settings --help": """
      USAGE: apple notes settings <subcommand>

      SUBCOMMANDS:
        read
        audit
        sort
        new-note-style
        default-account
        group-by-date
        quick-note-resume
        checklist-sort
        mention-notifications
        on-my-mac
        text-size
        locked-notes
        change-password
        reset-password
        touch-id
        view-layout
        link-highlight-color
        notifications
        widgets
        password
      """,
      "notes smart-folders --help": """
      USAGE: apple notes smart-folders <subcommand>

      SUBCOMMANDS:
        list
        reasoning
      """,
    ]
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_command_catalog",
      arguments: [
        "target": .string("notes"),
        "maxDepth": .int(1),
        "timeoutSeconds": .int(19),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)
    let commands = try #require(object["commands"]?.arrayValue)

    #expect(result.isError == false)
    #expect(object["target"]?.stringValue == "notes")
    #expect(object["maxDepth"]?.intValue == 1)
    #expect(object["truncated"]?.boolValue == false)
    #expect(commands.count == 4)

    let root = try #require(commands[0].objectValue)
    let rootPath = try #require(root["path"]?.arrayValue).compactMap { $0.stringValue }
    let rootSubcommands = try #require(root["subcommands"]?.arrayValue).compactMap {
      $0.stringValue
    }
    #expect(rootPath.isEmpty)
    #expect(rootSubcommands == ["state", "settings", "smart-folders"])
    let rootOptions = try #require(root["options"]?.arrayValue)
    let helpOption = try #require(rootOptions.first?.objectValue)
    #expect(helpOption["names"]?.arrayValue?.compactMap { $0.stringValue } == ["-h", "--help"])
    #expect(helpOption["valueRequired"]?.boolValue == false)

    let settings = try #require(commands[2].objectValue)
    let settingsPath = try #require(settings["path"]?.arrayValue).compactMap { $0.stringValue }
    let settingsSubcommands = try #require(settings["subcommands"]?.arrayValue).compactMap {
      $0.stringValue
    }
    #expect(settingsPath == ["settings"])
    #expect(
      settingsSubcommands == [
        "read", "audit", "sort", "new-note-style", "default-account", "group-by-date",
        "quick-note-resume",
        "checklist-sort", "mention-notifications", "on-my-mac", "text-size", "locked-notes",
        "change-password", "reset-password", "touch-id", "view-layout", "link-highlight-color",
        "notifications", "widgets", "password",
      ])

    let state = try #require(commands[1].objectValue)
    let stateSubcommands = try #require(state["subcommands"]?.arrayValue).compactMap {
      $0.stringValue
    }
    #expect(stateSubcommands.contains("activity"))
    #expect(stateSubcommands.contains("change-password"))
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "notes", arguments: ["--help"], timeoutSeconds: 19),
        FakeMCPRunner.Call(target: "notes", arguments: ["state", "--help"], timeoutSeconds: 19),
        FakeMCPRunner.Call(target: "notes", arguments: ["settings", "--help"], timeoutSeconds: 19),
        FakeMCPRunner.Call(
          target: "notes", arguments: ["smart-folders", "--help"], timeoutSeconds: 19),
      ])
  }

  @Test func mcpCommandCatalogIncludesCliDerivedOptionsForDeepNotesCommands() async throws {
    let runner = FakeMCPRunner()
    runner.helpOutputs = [
      "notes --help": """
      USAGE: apple notes <subcommand>

      SUBCOMMANDS:
        attachments
      """,
      "notes attachments --help": """
      USAGE: apple notes attachments <subcommand>

      SUBCOMMANDS:
        audio
      """,
      "notes attachments audio --help": """
      USAGE: apple notes attachments audio <subcommand>

      SUBCOMMANDS:
        save
      """,
      "notes attachments audio save --help": """
      USAGE: apple notes attachments audio save --id <id> --attachment <attachment> --output <output>

      OPTIONS:
        --id <id>                 Note identifier.
        --attachment <attachment> Audio attachment selector.
        --output <output>         Destination audio file path.
                                  Negative values such as
                                  -1 are description text.
        --allow-artifact-action Allow a command to create, overwrite, move, or remove
                                filesystem artifacts.
        --dry-run Run validation and resolution for a mutation, then
                  stop before side effects.
        --json                    Emit JSON output.
        -h, --help                Show help information.
      """,
    ]
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_command_catalog",
      arguments: [
        "target": .string("notes"),
        "maxDepth": .int(3),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)
    let commands = try #require(object["commands"]?.arrayValue)
    let save = try #require(
      commands.compactMap(\.objectValue).first {
        $0["path"]?.arrayValue?.compactMap { $0.stringValue }
          == ["attachments", "audio", "save"]
      })
    let options = try #require(save["options"]?.arrayValue).compactMap { $0.objectValue }
    let inputSchema = try #require(save["inputSchema"]?.objectValue)
    let schemaProperties = try #require(inputSchema["properties"]?.objectValue)
    let schemaRequired = try #require(inputSchema["required"]?.arrayValue).compactMap {
      $0.stringValue
    }
    let schemaOrder = try #require(inputSchema["cliArgumentOrder"]?.arrayValue).compactMap {
      $0.stringValue
    }

    #expect(result.isError == false)
    #expect(options.count == 7)
    #expect(inputSchema["type"]?.stringValue == "object")
    #expect(inputSchema["additionalProperties"]?.boolValue == false)
    #expect(schemaRequired == ["id", "attachment", "output"])
    #expect(
      schemaOrder == [
        "id",
        "attachment",
        "output",
        "allow-artifact-action",
        "dry-run",
        "json",
        "help",
      ])

    let idOption = try #require(
      options.first {
        $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["--id"]
      })
    #expect(idOption["valueName"]?.stringValue == "id")
    #expect(idOption["valueRequired"]?.boolValue == true)
    #expect(idOption["valueType"]?.stringValue == "string")
    #expect(idOption["description"]?.stringValue == "Note identifier.")
    let idProperty = try #require(schemaProperties["id"]?.objectValue)
    #expect(idProperty["type"]?.stringValue == "string")
    #expect(idProperty["cliArgumentKind"]?.stringValue == "option")
    #expect(idProperty["cliNames"]?.arrayValue?.compactMap { $0.stringValue } == ["--id"])

    let outputOption = try #require(
      options.first {
        $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["--output"]
      })
    #expect(outputOption["valueName"]?.stringValue == "output")
    #expect(
      outputOption["description"]?.stringValue
        == "Destination audio file path. Negative values such as -1 are description text.")

    let allowOption = try #require(
      options.first {
        $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["--allow-artifact-action"]
      })
    #expect(allowOption["valueName"] == nil)
    #expect(allowOption["valueRequired"]?.boolValue == false)
    #expect(allowOption["valueType"]?.stringValue == "boolean")
    let allowProperty = try #require(schemaProperties["allow-artifact-action"]?.objectValue)
    #expect(allowProperty["type"]?.stringValue == "boolean")
    #expect(allowProperty["cliArgumentKind"]?.stringValue == "flag")
    #expect(
      allowOption["description"]?.stringValue
        == "Allow a command to create, overwrite, move, or remove filesystem artifacts."
    )

    let dryRunOption = try #require(
      options.first {
        $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["--dry-run"]
      })
    #expect(
      dryRunOption["description"]?.stringValue
        == "Run validation and resolution for a mutation, then stop before side effects."
    )

    let helpOption = try #require(
      options.first {
        $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["-h", "--help"]
      })
    #expect(helpOption["description"]?.stringValue == "Show help information.")
    let helpProperty = try #require(schemaProperties["help"]?.objectValue)
    #expect(helpProperty["type"]?.stringValue == "boolean")
    #expect(
      helpProperty["cliNames"]?.arrayValue?.compactMap { $0.stringValue } == ["-h", "--help"])
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "notes", arguments: ["--help"], timeoutSeconds: 30),
        FakeMCPRunner.Call(
          target: "notes", arguments: ["attachments", "--help"], timeoutSeconds: 30),
        FakeMCPRunner.Call(
          target: "notes",
          arguments: ["attachments", "audio", "--help"],
          timeoutSeconds: 30
        ),
        FakeMCPRunner.Call(
          target: "notes",
          arguments: ["attachments", "audio", "save", "--help"],
          timeoutSeconds: 30
        ),
      ])
  }

  @Test(.timeLimit(.minutes(1)))
  func mcpClientRoundTripsThroughServerAndPreservesCatalogSchemasAndRunSafety() async throws {
    let runner = FakeMCPRunner()
    runner.helpOutputs = [
      "notes --help": """
      USAGE: apple notes <subcommand>

      SUBCOMMANDS:
        attachments
      """,
      "notes attachments --help": """
      USAGE: apple notes attachments <subcommand>

      SUBCOMMANDS:
        audio
      """,
      "notes attachments audio --help": """
      USAGE: apple notes attachments audio <subcommand>

      SUBCOMMANDS:
        save
      """,
      "notes attachments audio save --help": """
      USAGE: apple notes attachments audio save --id <id> --attachment <attachment> --output <output> [--dry-run]

      OPTIONS:
        --id <id>                 Note identifier.
        --attachment <attachment> Audio attachment selector.
        --output <output>         Destination audio file path.
        --allow-artifact-action Allow a command to create, overwrite, move, or remove
                                filesystem artifacts.
        --dry-run Run validation and resolution for a mutation, then
                  stop before side effects.
        --json                    Emit JSON output.
        -h, --help                Show help information.
      """,
    ]
    let adapter = AppleMCPAdapter(runner: runner)
    let server = await AppleMCPServerFactory.makeServer(adapter: adapter)
    let (clientTransport, serverTransport) = await InMemoryTransport.createConnectedPair()
    let client = Client(name: "apple-cli-tests", version: "1.0")

    try await server.start(transport: serverTransport)
    let initializeResult = try await client.connect(transport: clientTransport)
    #expect(initializeResult.serverInfo.name == "apple-cli-mcp")
    #expect(initializeResult.serverInfo.version == CLIVersion.current)
    #expect(initializeResult.capabilities.tools != nil)

    let (tools, _) = try await client.listTools()
    #expect(
      tools.map(\.name) == [
        "apple_cli_list_targets",
        "apple_cli_doctor",
        "apple_cli_status",
        "apple_cli_help",
        "apple_cli_command_catalog",
        "apple_cli_run",
      ])

    let catalogContext: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_command_catalog",
      arguments: [
        "target": .string("notes"),
        "maxDepth": .int(3),
        "timeoutSeconds": .int(8),
      ]
    )
    let catalogResult = try await catalogContext.value
    #expect(catalogResult.isError == false)
    let catalogObject = try #require(catalogResult.structuredContent?.objectValue)
    let commands = try #require(catalogObject["commands"]?.arrayValue)
    let saveCommand = try #require(
      commands.compactMap(\.objectValue).first {
        $0["path"]?.arrayValue?.compactMap { $0.stringValue }
          == ["attachments", "audio", "save"]
      })
    let saveSchema = try #require(saveCommand["inputSchema"]?.objectValue)
    let required = try #require(saveSchema["required"]?.arrayValue).compactMap {
      $0.stringValue
    }
    let properties = try #require(saveSchema["properties"]?.objectValue)
    let allowArtifact = try #require(properties["allow-artifact-action"]?.objectValue)

    #expect(required == ["id", "attachment", "output"])
    #expect(allowArtifact["type"]?.stringValue == "boolean")
    #expect(allowArtifact["cliArgumentKind"]?.stringValue == "flag")

    let runContext: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("notes"),
        "arguments": .array([
          .string("attachments"),
          .string("audio"),
          .string("save"),
          .string("--id"),
          .string("note-1"),
          .string("--attachment"),
          .string("audio-1"),
          .string("--output"),
          .string("/tmp/audio.m4a"),
          .string("--dry-run"),
          .string("--allow-artifact-action"),
        ]),
        "timeoutSeconds": .int(9),
      ]
    )
    let runResult = try await runContext.value
    #expect(runResult.isError == false)
    let runObject = try #require(runResult.structuredContent?.objectValue)
    #expect(runObject["ok"]?.boolValue == true)
    #expect(
      runner.calls.last
        == FakeMCPRunner.Call(
          target: "notes",
          arguments: [
            "attachments",
            "audio",
            "save",
            "--id",
            "note-1",
            "--attachment",
            "audio-1",
            "--output",
            "/tmp/audio.m4a",
            "--dry-run",
            "--allow-artifact-action",
            "--json",
          ],
          timeoutSeconds: 9
        ))

    await server.stop()
    await client.disconnect()
  }

  @Test func mcpCommandCatalogRespectsCommandLimitBeforeProcessLaunchExpansion() async throws {
    let runner = FakeMCPRunner()
    runner.helpOutputs = [
      "notes --help": """
      USAGE: apple notes <subcommand>

      SUBCOMMANDS:
        state
        settings
      """
    ]
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_command_catalog",
      arguments: [
        "target": .string("notes"),
        "maxCommands": .int(1),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)
    let commands = try #require(object["commands"]?.arrayValue)

    #expect(result.isError == false)
    #expect(object["truncated"]?.boolValue == true)
    #expect(commands.count == 1)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "notes", arguments: ["--help"], timeoutSeconds: 30)
      ])
  }

  @Test func mcpRunAppendsJSONAndPreservesDryRunArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("notes"),
        "arguments": .array([
          .string("create"),
          .string("--folder"),
          .string("Work"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(12),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "notes",
          arguments: [
            "create",
            "--folder",
            "Work",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 12
        )
      ])
  }

  @Test func mcpRunDoesNotCopyPrivateRequestArgumentsIntoResponses() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)
    let requests = [
      ["create", "--body", "private-body-canary", "--dry-run"],
      [
        "settings", "locked-notes", "--account", "account-canary", "--scope", "custom",
        "--passphrase-file", "/tmp/private-passphrase-canary", "--hint", "private-hint-canary",
        "--dry-run",
      ],
    ]

    for arguments in requests {
      let result = try await adapter.callTool(
        name: "apple_cli_run",
        arguments: [
          "target": .string("notes"),
          "arguments": .array(arguments.map(Value.string)),
        ]
      )
      let object = try #require(result.structuredContent?.objectValue)
      let response = String(decoding: try JSONEncoder().encode(result), as: UTF8.self)

      #expect(result.isError == false)
      #expect(object["target"]?.stringValue == "notes")
      #expect(object["exitCode"]?.intValue == 0)
      #expect(object["stdout"]?.stringValue?.contains("stub") == true)
      #expect(object["arguments"] == nil)
      for privateValue in arguments.filter({ $0.contains("canary") }) {
        #expect(!response.contains(privateValue))
      }
      #expect(
        runner.calls.last
          == FakeMCPRunner.Call(
            target: "notes", arguments: arguments + ["--json"], timeoutSeconds: 30))
    }
  }

  @Test func mcpUnexpectedRunnerErrorsDoNotExposePrivateDescriptions() async throws {
    let error = NSError(
      domain: "SyntheticRunnerFailure", code: 42,
      userInfo: [NSLocalizedDescriptionKey: "private-error-canary /tmp/private-path-canary"])
    let adapter = AppleMCPAdapter(runner: FailingMCPRunner(error: error))
    let result = try await adapter.callTool(
      name: "apple_cli_status", arguments: ["target": .string("notes")])
    let object = try #require(result.structuredContent?.objectValue)
    let payload = try #require(object["error"]?.objectValue)
    let response = String(decoding: try JSONEncoder().encode(result), as: UTF8.self)

    #expect(result.isError == true)
    #expect(payload["code"]?.stringValue == CLIErrorCode.internalError.rawValue)
    #expect(!response.contains("private-error-canary"))
    #expect(!response.contains("private-path-canary"))
  }

  @Test func mcpTypedRunnerErrorsPreserveRecoveryDetails() async throws {
    let adapter = AppleMCPAdapter(
      runner: FailingMCPRunner(
        error: CLIError(
          code: .unsafeMutationRefused, message: "Explicit authorization is required.",
          details: ["required_flag": "allow-persistent-action"])))
    let result = try await adapter.callTool(
      name: "apple_cli_status", arguments: ["target": .string("notes")])
    let object = try #require(result.structuredContent?.objectValue)
    let payload = try #require(object["error"]?.objectValue)

    #expect(result.isError == true)
    #expect(payload["code"]?.stringValue == CLIErrorCode.unsafeMutationRefused.rawValue)
    #expect(payload["message"]?.stringValue == "Explicit authorization is required.")
    #expect(
      payload["details"]?.objectValue?["required_flag"]?.stringValue == "allow-persistent-action")
  }

  @Test func mcpRunPreservesNotesBodyCollapsibleDryRunArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("notes"),
        "arguments": .array([
          .string("body"),
          .string("collapsible"),
          .string("set"),
          .string("--id"),
          .string("note-123"),
          .string("--ordinal"),
          .string("2"),
          .string("--state"),
          .string("toggle"),
          .string("--dry-run"),
        ]),
        "timeoutSeconds": .int(17),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "notes",
          arguments: [
            "body",
            "collapsible",
            "set",
            "--id",
            "note-123",
            "--ordinal",
            "2",
            "--state",
            "toggle",
            "--dry-run",
            "--json",
          ],
          timeoutSeconds: 17
        )
      ])
  }

  @Test func mcpRunPreservesPhotosPostHookStrongGateArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("photos"),
        "arguments": .array([
          .string("exports"),
          .string("export"),
          .string("--destination"),
          .string("/tmp/photos-export"),
          .string("--source"),
          .string("print(\"post\")"),
          .string("--command"),
          .string("cat"),
          .string("--allow-eval"),
          .string("--allow-post-command"),
          .string("--timeout-seconds"),
          .string("7"),
          .string("--output-cap"),
          .string("1024"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(13),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "photos",
          arguments: [
            "exports",
            "export",
            "--destination",
            "/tmp/photos-export",
            "--source",
            "print(\"post\")",
            "--command",
            "cat",
            "--allow-eval",
            "--allow-post-command",
            "--timeout-seconds",
            "7",
            "--output-cap",
            "1024",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 13
        )
      ])
  }

  @Test func mcpRunPreservesPhotosCleanupStrongGateArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("photos"),
        "arguments": .array([
          .string("exports"),
          .string("export"),
          .string("--destination"),
          .string("/tmp/photos-export"),
          .string("--cleanup"),
          .string("--allow-cleanup"),
          .string("--keep"),
          .string("manual.keep"),
          .string("--cleanup-command"),
          .string("printf '%s\\n' {filepath|shell_quote}"),
          .string("--allow-post-command"),
          .string("--timeout-seconds"),
          .string("7"),
          .string("--output-cap"),
          .string("1024"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(13),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "photos",
          arguments: [
            "exports",
            "export",
            "--destination",
            "/tmp/photos-export",
            "--cleanup",
            "--allow-cleanup",
            "--keep",
            "manual.keep",
            "--cleanup-command",
            "printf '%s\\n' {filepath|shell_quote}",
            "--allow-post-command",
            "--timeout-seconds",
            "7",
            "--output-cap",
            "1024",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 13
        )
      ])
  }

  @Test func mcpRunPreservesPhotosMetadataStrongGateArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("photos"),
        "arguments": .array([
          .string("metadata"),
          .string("sync"),
          .string("--uuid"),
          .string("11111111-1111-1111-1111-111111111111"),
          .string("--source-file"),
          .string("/tmp/photos-sync.json"),
          .string("--field"),
          .string("title"),
          .string("--field"),
          .string("location"),
          .string("--allow-destructive-metadata"),
          .string("--timeout-seconds"),
          .string("7"),
          .string("--output-cap"),
          .string("1024"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(13),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "photos",
          arguments: [
            "metadata",
            "sync",
            "--uuid",
            "11111111-1111-1111-1111-111111111111",
            "--source-file",
            "/tmp/photos-sync.json",
            "--field",
            "title",
            "--field",
            "location",
            "--allow-destructive-metadata",
            "--timeout-seconds",
            "7",
            "--output-cap",
            "1024",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 13
        )
      ])
  }

  @Test func mcpRunPreservesPhotosMediaItemBatchUpdateDryRunArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("photos"),
        "arguments": .array([
          .string("media-items"),
          .string("update"),
          .string("--uuid"),
          .string("11111111-1111-1111-1111-111111111111"),
          .string("--uuid"),
          .string("22222222-2222-2222-2222-222222222222"),
          .string("--description"),
          .string("Batch caption"),
          .string("--add-keyword"),
          .string("night"),
          .string("--clear-favorite"),
          .string("--album-id"),
          .string("album:new"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(13),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "photos",
          arguments: [
            "media-items",
            "update",
            "--uuid",
            "11111111-1111-1111-1111-111111111111",
            "--uuid",
            "22222222-2222-2222-2222-222222222222",
            "--description",
            "Batch caption",
            "--add-keyword",
            "night",
            "--clear-favorite",
            "--album-id",
            "album:new",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 13
        )
      ])
  }

  @Test func mcpRunPreservesPhotosImportDryRunArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("photos"),
        "arguments": .array([
          .string("imports"),
          .string("import"),
          .string("--path"),
          .string("/tmp/IMG_0102.JPG"),
          .string("--path"),
          .string("/tmp/IMG_0102_edited.JPG"),
          .string("--album"),
          .string("Imported"),
          .string("--folder-id"),
          .string("folder:1"),
          .string("--skip-check-duplicates"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(13),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "photos",
          arguments: [
            "imports",
            "import",
            "--path",
            "/tmp/IMG_0102.JPG",
            "--path",
            "/tmp/IMG_0102_edited.JPG",
            "--album",
            "Imported",
            "--folder-id",
            "folder:1",
            "--skip-check-duplicates",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 13
        )
      ])
  }

  @Test func mcpRunPreservesPhotosPushExifStrongGateArguments() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("photos"),
        "arguments": .array([
          .string("metadata"),
          .string("push-exif"),
          .string("--uuid"),
          .string("11111111-1111-1111-1111-111111111111"),
          .string("--field"),
          .string("all"),
          .string("--exiftool-path"),
          .string("/tmp/fake-exiftool"),
          .string("--allow-destructive-metadata"),
          .string("--timeout-seconds"),
          .string("7"),
          .string("--output-cap"),
          .string("1024"),
          .string("--allow-external-dispatch"),
        ]),
        "timeoutSeconds": .int(13),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)

    #expect(result.isError == false)
    #expect(object["ok"]?.boolValue == true)
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(
          target: "photos",
          arguments: [
            "metadata",
            "push-exif",
            "--uuid",
            "11111111-1111-1111-1111-111111111111",
            "--field",
            "all",
            "--exiftool-path",
            "/tmp/fake-exiftool",
            "--allow-destructive-metadata",
            "--timeout-seconds",
            "7",
            "--output-cap",
            "1024",
            "--allow-external-dispatch",
            "--json",
          ],
          timeoutSeconds: 13
        )
      ])
  }

  @Test func mcpRunRejectsUnknownTargetsBeforeProcessLaunch() async throws {
    let runner = FakeMCPRunner()
    let adapter = AppleMCPAdapter(runner: runner)

    let result = try await adapter.callTool(
      name: "apple_cli_run",
      arguments: [
        "target": .string("apple-cli-mcp"),
        "arguments": .array([.string("--json")]),
      ]
    )
    let object = try #require(result.structuredContent?.objectValue)
    let error = try #require(object["error"]?.objectValue)

    #expect(result.isError == true)
    #expect(error["code"]?.stringValue == CLIErrorCode.validationError.rawValue)
    #expect(runner.calls.isEmpty)
  }
}

private struct FailingMCPRunner: CLIProcessRunning {
  var error: any Error

  func run(target: String, arguments: [String], timeoutSeconds: Int) async throws
    -> CLIProcessResult
  {
    throw error
  }
}

private final class FakeMCPRunner: CLIProcessRunning, @unchecked Sendable {
  struct Call: Equatable, Sendable {
    var target: String
    var arguments: [String]
    var timeoutSeconds: Int
  }

  // The lock owns both fixture configuration and observations across SDK handlers.
  private let lock = NSLock()
  private var recordedCalls: [Call] = []
  private var configuredHelp: [String: String] = [:]

  var calls: [Call] { lock.withLock { recordedCalls } }
  var helpOutputs: [String: String] {
    get { lock.withLock { configuredHelp } }
    set { lock.withLock { configuredHelp = newValue } }
  }

  func run(target: String, arguments: [String], timeoutSeconds: Int) async throws
    -> CLIProcessResult
  {
    lock.withLock { result(target: target, arguments: arguments, timeoutSeconds: timeoutSeconds) }
  }

  private func result(target: String, arguments: [String], timeoutSeconds: Int) -> CLIProcessResult
  {
    recordedCalls.append(Call(target: target, arguments: arguments, timeoutSeconds: timeoutSeconds))
    if arguments.contains("--help") || arguments.contains("-h") {
      let key = ([target] + arguments).joined(separator: " ")
      return CLIProcessResult(
        target: target,
        arguments: arguments,
        exitCode: 0,
        stdout: configuredHelp[key] ?? "USAGE: apple \(target)\n",
        stderr: ""
      )
    }
    return CLIProcessResult(
      target: target,
      arguments: arguments,
      exitCode: 0,
      stdout: #"{"meta":{"target":"\#(target)"},"ok":true,"warnings":[],"data":{"stub":true}}"#,
      stderr: ""
    )
  }
}
