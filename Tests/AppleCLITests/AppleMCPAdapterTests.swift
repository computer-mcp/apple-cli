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

    #expect(toolNames == [
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
        FakeMCPRunner.Call(target: "reminders", arguments: ["doctor", "--json"], timeoutSeconds: 30)
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
        FakeMCPRunner.Call(target: "notes", arguments: ["restore-all", "--help"], timeoutSeconds: 30)
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
          settings
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
    let rootSubcommands = try #require(root["subcommands"]?.arrayValue).compactMap { $0.stringValue }
    #expect(rootPath.isEmpty)
    #expect(rootSubcommands == ["state", "settings", "smart-folders"])
    let rootOptions = try #require(root["options"]?.arrayValue)
    let helpOption = try #require(rootOptions.first?.objectValue)
    #expect(helpOption["names"]?.arrayValue?.compactMap { $0.stringValue } == ["-h", "--help"])
    #expect(helpOption["valueRequired"]?.boolValue == false)

    let settings = try #require(commands[2].objectValue)
    let settingsPath = try #require(settings["path"]?.arrayValue).compactMap { $0.stringValue }
    let settingsSubcommands = try #require(settings["subcommands"]?.arrayValue).compactMap { $0.stringValue }
    #expect(settingsPath == ["settings"])
    #expect(settingsSubcommands == [
      "read", "audit", "sort", "new-note-style", "default-account", "group-by-date", "quick-note-resume",
      "checklist-sort", "mention-notifications", "on-my-mac", "text-size", "locked-notes",
      "change-password", "reset-password", "touch-id", "view-layout", "link-highlight-color",
      "notifications", "widgets", "password",
    ])

    let state = try #require(commands[1].objectValue)
    let stateSubcommands = try #require(state["subcommands"]?.arrayValue).compactMap { $0.stringValue }
    #expect(stateSubcommands.contains("activity"))
    #expect(stateSubcommands.contains("change-password"))
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "notes", arguments: ["--help"], timeoutSeconds: 19),
        FakeMCPRunner.Call(target: "notes", arguments: ["state", "--help"], timeoutSeconds: 19),
        FakeMCPRunner.Call(target: "notes", arguments: ["settings", "--help"], timeoutSeconds: 19),
        FakeMCPRunner.Call(target: "notes", arguments: ["smart-folders", "--help"], timeoutSeconds: 19),
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
    #expect(schemaOrder == [
      "id",
      "attachment",
      "output",
      "allow-artifact-action",
      "dry-run",
      "json",
      "help",
    ])

    let idOption = try #require(options.first {
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

    let outputOption = try #require(options.first {
      $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["--output"]
    })
    #expect(outputOption["valueName"]?.stringValue == "output")
    #expect(outputOption["description"]?.stringValue == "Destination audio file path.")

    let allowOption = try #require(options.first {
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

    let dryRunOption = try #require(options.first {
      $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["--dry-run"]
    })
    #expect(
      dryRunOption["description"]?.stringValue
        == "Run validation and resolution for a mutation, then stop before side effects."
    )

    let helpOption = try #require(options.first {
      $0["names"]?.arrayValue?.compactMap { $0.stringValue } == ["-h", "--help"]
    })
    #expect(helpOption["description"]?.stringValue == "Show help information.")
    let helpProperty = try #require(schemaProperties["help"]?.objectValue)
    #expect(helpProperty["type"]?.stringValue == "boolean")
    #expect(helpProperty["cliNames"]?.arrayValue?.compactMap { $0.stringValue } == ["-h", "--help"])
    #expect(
      runner.calls == [
        FakeMCPRunner.Call(target: "notes", arguments: ["--help"], timeoutSeconds: 30),
        FakeMCPRunner.Call(target: "notes", arguments: ["attachments", "--help"], timeoutSeconds: 30),
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
    #expect(tools.map(\.name) == [
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

  @Test(.timeLimit(.minutes(1)))
  func mcpStdioExecutableBlackBoxRunsCliThroughSdkClient() async throws {
    let installation = try stagedMCPInstallation(separateCLI: false)
    defer { try? FileManager.default.removeItem(at: installation.root) }
    let process = Process()
    let stdin = Pipe()
    let stdout = Pipe()
    let stderr = Pipe()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["apple-cli-mcp", "stdio"]
    process.currentDirectoryURL = installation.root
    var environment = ProcessInfo.processInfo.environment
    environment.removeValue(forKey: "APPLE_CLI_BIN_DIR")
    let aliases = installation.root.appendingPathComponent("aliases", isDirectory: true)
    try FileManager.default.createDirectory(at: aliases, withIntermediateDirectories: false)
    try FileManager.default.createSymbolicLink(
      at: aliases.appendingPathComponent("apple-cli-mcp"), withDestinationURL: installation.server)
    environment["PATH"] = aliases.path + ":/usr/bin:/bin"
    process.environment = environment
    process.standardInput = stdin
    process.standardOutput = stdout
    process.standardError = stderr

    try process.run()
    defer {
      if process.isRunning {
        process.terminate()
      }
      process.waitUntilExit()
      try? stdin.fileHandleForWriting.close()
      try? stdout.fileHandleForReading.close()
      try? stderr.fileHandleForReading.close()
    }

    let transport = StdioTransport(
      input: FileDescriptor(rawValue: stdout.fileHandleForReading.fileDescriptor),
      output: FileDescriptor(rawValue: stdin.fileHandleForWriting.fileDescriptor)
    )
    let client = Client(name: "apple-cli-stdio-tests", version: "1.0")
    let initializeResult = try await client.connect(transport: transport)

    #expect(initializeResult.serverInfo.name == "apple-cli-mcp")
    #expect(initializeResult.serverInfo.version == CLIVersion.current)
    #expect(initializeResult.capabilities.tools != nil)

    let (tools, _) = try await client.listTools()
    #expect(tools.map(\.name) == [
      "apple_cli_list_targets",
      "apple_cli_doctor",
      "apple_cli_status",
      "apple_cli_help",
      "apple_cli_command_catalog",
      "apple_cli_run",
    ])

    let listTargets: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_list_targets",
      arguments: [:]
    )
    let result = try await listTargets.value
    #expect(result.isError == false)
    let object = try #require(result.structuredContent?.objectValue)
    let targets = try #require(object["targets"]?.arrayValue).compactMap { $0.stringValue }
    #expect(targets.contains("notes"))
    #expect(targets.contains("reminders"))
    #expect(!targets.contains("apple-cli-mcp"))

    let help: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_help", arguments: ["target": .string("notes")]
    )
    let helpResult = try await help.value
    let helpPayload = try #require(helpResult.structuredContent?.objectValue)
    #expect(helpResult.isError == false)
    #expect(helpPayload["exitCode"]?.intValue == 0)
    #expect(helpPayload["stdout"]?.stringValue?.contains("USAGE: apple notes") == true)

    let preview: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_run", arguments: ["target": .string("notifications"),
        "arguments": .array([.string("preview"), .string("--title"), .string("release-test"),
          .string("--body"), .string("preview")])]
    )
    let previewResult = try await preview.value
    #expect(previewResult.isError == false)
    #expect(previewResult.structuredContent?.objectValue?["exitCode"]?.intValue == 0)

    await client.disconnect()
  }

  @Test(.timeLimit(.minutes(1)))
  func mcpHTTPExecutableBlackBoxRunsCliThroughSdkClient() async throws {
    guard #available(macOS 14.0, *) else {
      return
    }

    let installation = try stagedMCPInstallation(separateCLI: true)
    defer { try? FileManager.default.removeItem(at: installation.root) }
    let port = try availableLoopbackPort()
    let path = "/mcp-test-\(UUID().uuidString)"
    let endpoint = try #require(URL(string: "http://127.0.0.1:\(port)\(path)"))
    let process = Process()
    let stdout = Pipe()
    let stderr = Pipe()
    process.executableURL = installation.server
    process.currentDirectoryURL = installation.root
    var environment = ProcessInfo.processInfo.environment
    environment["APPLE_CLI_BIN_DIR"] = installation.cliDirectory.path
    process.environment = environment
    process.arguments = [
      "serve",
      "http",
      "--host",
      "127.0.0.1",
      "--port",
      "\(port)",
      "--path",
      path,
      "--session-timeout-seconds",
      "30",
      "--max-sessions",
      "2",
    ]
    process.standardOutput = stdout
    process.standardError = stderr

    try process.run()
    defer {
      if process.isRunning {
        process.terminate()
      }
      process.waitUntilExit()
      try? stdout.fileHandleForReading.close()
      try? stderr.fileHandleForReading.close()
    }

    try await waitForHTTPServer(endpoint: endpoint, process: process, timeoutSeconds: 8)

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 5
    configuration.timeoutIntervalForResource = 10
    let transport = HTTPClientTransport(
      endpoint: endpoint,
      configuration: configuration,
      streaming: false,
      logger: nil
    )
    let client = Client(name: "apple-cli-http-tests", version: "1.0")
    let initializeResult = try await client.connect(transport: transport)

    #expect(initializeResult.serverInfo.name == "apple-cli-mcp")
    #expect(initializeResult.serverInfo.version == CLIVersion.current)
    #expect(initializeResult.capabilities.tools != nil)

    let (tools, _) = try await client.listTools()
    #expect(tools.map(\.name) == [
      "apple_cli_list_targets",
      "apple_cli_doctor",
      "apple_cli_status",
      "apple_cli_help",
      "apple_cli_command_catalog",
      "apple_cli_run",
    ])

    let listTargets: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_list_targets",
      arguments: [:]
    )
    let result = try await listTargets.value
    #expect(result.isError == false)
    let object = try #require(result.structuredContent?.objectValue)
    let targets = try #require(object["targets"]?.arrayValue).compactMap { $0.stringValue }
    #expect(targets.contains("notes"))
    #expect(targets.contains("reminders"))
    #expect(!targets.contains("apple-cli-mcp"))

    let help: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_help", arguments: ["target": .string("notes")]
    )
    let helpResult = try await help.value
    let helpPayload = try #require(helpResult.structuredContent?.objectValue)
    #expect(helpResult.isError == false)
    #expect(helpPayload["exitCode"]?.intValue == 0)
    #expect(helpPayload["stdout"]?.stringValue?.contains("USAGE: apple notes") == true)

    let preview: RequestContext<CallTool.Result> = try await client.callTool(
      name: "apple_cli_run", arguments: ["target": .string("notifications"),
        "arguments": .array([.string("preview"), .string("--title"), .string("release-test"),
          .string("--body"), .string("preview")])]
    )
    let previewResult = try await preview.value
    #expect(previewResult.isError == false)
    #expect(previewResult.structuredContent?.objectValue?["exitCode"]?.intValue == 0)

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
        """,
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

private func stagedMCPInstallation(separateCLI: Bool) throws -> (root: URL, server: URL, cliDirectory: URL) {
  let source = try appleMCPExecutablePath().resolvingSymlinksInPath()
  let manager = FileManager.default
  let root = manager.temporaryDirectory.appendingPathComponent("apple-cli-install-test-\(UUID().uuidString)")
  let bin = root.appendingPathComponent("bin")
  let cliDirectory = separateCLI ? root.appendingPathComponent("cli-bin") : bin
  do {
    try manager.createDirectory(at: bin, withIntermediateDirectories: true)
    if separateCLI { try manager.createDirectory(at: cliDirectory, withIntermediateDirectories: true) }
    let server = bin.appendingPathComponent("apple-cli-mcp")
    try manager.copyItem(at: source, to: server)
    let cli = ProcessInfo.processInfo.environment["APPLE_CLI_BIN"].map { URL(fileURLWithPath: $0) }
      ?? source.deletingLastPathComponent().appendingPathComponent("apple")
    try manager.copyItem(at: cli, to: cliDirectory.appendingPathComponent("apple"))
    for (executable, destination) in [(source, bin), (cli.resolvingSymlinksInPath(), cliDirectory)] {
      let libraries = try manager.contentsOfDirectory(
        at: executable.deletingLastPathComponent(), includingPropertiesForKeys: nil
      ).filter { $0.lastPathComponent.hasPrefix("libswift") && $0.pathExtension == "dylib" }
      for library in libraries {
        let copy = destination.appendingPathComponent(library.lastPathComponent)
        if manager.fileExists(atPath: copy.path) {
          #expect(try Data(contentsOf: library) == Data(contentsOf: copy))
        } else {
          try manager.copyItem(at: library, to: copy)
        }
      }
    }
    return (root, server, cliDirectory)
  } catch {
    try? manager.removeItem(at: root)
    throw error
  }
}

private func appleMCPExecutablePath() throws -> URL {
  let fileManager = FileManager.default
  var candidates: [URL] = []

  if let override = ProcessInfo.processInfo.environment["APPLE_CLI_MCP_BIN"],
    !override.isEmpty
  {
    candidates.append(URL(fileURLWithPath: override))
  }

  if let testExecutable = CommandLine.arguments.first,
    testExecutable.contains("/")
  {
    var directory = URL(fileURLWithPath: testExecutable)
    for _ in 0..<8 {
      directory.deleteLastPathComponent()
      candidates.append(directory.appendingPathComponent("apple-cli-mcp"))
    }
  }

  let packageRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
  candidates.append(packageRoot.appendingPathComponent(".build/debug/apple-cli-mcp"))
  candidates.append(
    packageRoot.appendingPathComponent(".build/arm64-apple-macosx/debug/apple-cli-mcp")
  )

  var seen: Set<String> = []
  var searched: [String] = []
  for candidate in candidates {
    let path = candidate.standardizedFileURL.path
    guard seen.insert(path).inserted else {
      continue
    }
    searched.append(path)
    if fileManager.isExecutableFile(atPath: path) {
      return URL(fileURLWithPath: path)
    }
  }

  throw CLIError(
    code: .backendUnavailable,
    message: "apple-cli-mcp executable was not found for black-box MCP stdio validation.",
    details: ["searched": searched.joined(separator: "\n")]
  )
}

private func availableLoopbackPort() throws -> Int {
  let descriptor = socket(AF_INET, SOCK_STREAM, 0)
  guard descriptor >= 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Could not allocate a loopback socket for MCP HTTP validation.",
      details: ["errno": "\(errno)"]
    )
  }
  defer { close(descriptor) }

  var reuseAddress: Int32 = 1
  _ = setsockopt(
    descriptor,
    SOL_SOCKET,
    SO_REUSEADDR,
    &reuseAddress,
    socklen_t(MemoryLayout<Int32>.size)
  )

  var address = sockaddr_in()
  address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
  address.sin_family = sa_family_t(AF_INET)
  address.sin_port = in_port_t(0).bigEndian
  address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

  let bindResult = withUnsafePointer(to: &address) { pointer in
    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
      Darwin.bind(descriptor, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
    }
  }
  guard bindResult == 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Could not bind a loopback socket for MCP HTTP validation.",
      details: ["errno": "\(errno)"]
    )
  }

  var boundAddress = sockaddr_in()
  var length = socklen_t(MemoryLayout<sockaddr_in>.size)
  let nameResult = withUnsafeMutablePointer(to: &boundAddress) { pointer in
    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
      getsockname(descriptor, sockaddrPointer, &length)
    }
  }
  guard nameResult == 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Could not read the allocated MCP HTTP validation port.",
      details: ["errno": "\(errno)"]
    )
  }

  return Int(in_port_t(bigEndian: boundAddress.sin_port))
}

private func waitForHTTPServer(endpoint: URL, process: Process, timeoutSeconds: TimeInterval)
  async throws
{
  let deadline = Date().addingTimeInterval(timeoutSeconds)
  let configuration = URLSessionConfiguration.ephemeral
  configuration.timeoutIntervalForRequest = 0.5
  configuration.timeoutIntervalForResource = 0.5
  let session = URLSession(configuration: configuration)
  defer { session.invalidateAndCancel() }

  var lastError: String?
  while Date() < deadline {
    if !process.isRunning {
      throw CLIError(
        code: .backendUnavailable,
        message: "apple-cli-mcp HTTP process exited before accepting connections.",
        details: ["endpoint": endpoint.absoluteString, "exitStatus": "\(process.terminationStatus)"]
      )
    }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "GET"
    request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
    do {
      let (_, response) = try await session.data(for: request)
      if let httpResponse = response as? HTTPURLResponse,
        (200...499).contains(httpResponse.statusCode)
      {
        return
      }
    } catch {
      lastError = String(describing: error)
    }

    try await Task.sleep(nanoseconds: 100_000_000)
  }

  throw CLIError(
    code: .backendUnavailable,
    message: "Timed out waiting for apple-cli-mcp HTTP validation server.",
    details: [
      "endpoint": endpoint.absoluteString,
      "lastError": lastError ?? "none",
    ]
  )
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

  func run(target: String, arguments: [String], timeoutSeconds: Int) async throws -> CLIProcessResult {
    lock.withLock { result(target: target, arguments: arguments, timeoutSeconds: timeoutSeconds) }
  }

  private func result(target: String, arguments: [String], timeoutSeconds: Int) -> CLIProcessResult {
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
