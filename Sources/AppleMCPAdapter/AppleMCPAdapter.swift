import Darwin
import Foundation
import MCP
import Utility

public struct CLIProcessResult: Codable, Equatable, Sendable {
  public var target: String
  public var arguments: [String]
  public var exitCode: Int32
  public var stdout: String
  public var stderr: String

  public init(target: String, arguments: [String], exitCode: Int32, stdout: String, stderr: String)
  {
    self.target = target
    self.arguments = arguments
    self.exitCode = exitCode
    self.stdout = stdout
    self.stderr = stderr
  }
}

public protocol CLIProcessRunning: Sendable {
  func run(target: String, arguments: [String], timeoutSeconds: Int) async throws -> CLIProcessResult
}

public struct CLIProcessRunner: CLIProcessRunning {
  private let binDirectory: URL?
  private let environment: [String: String]

  public init(
    binDirectory: URL? = nil, environment: [String: String] = ProcessInfo.processInfo.environment
  ) {
    self.binDirectory = binDirectory
    self.environment = environment
  }

  public func run(target: String, arguments: [String], timeoutSeconds: Int) async throws
    -> CLIProcessResult
  {
    let executable = try executablePath()
    let commandArguments = [target] + arguments
    let subprocessResult: CLISubprocessResult
    do {
      subprocessResult = try await CLISubprocess.runAsync(
        .path(executable.path),
        arguments: commandArguments,
        timeoutSeconds: timeoutSeconds
      )
    } catch let error as CancellationError {
      throw error
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(
        code: .backendUnavailable,
        message: "`apple` CLI could not be started.",
        details: ["target": target]
      )
    }
    return CLIProcessResult(
      target: target,
      arguments: commandArguments,
      exitCode: subprocessResult.exitCode,
      stdout: subprocessResult.stdout,
      stderr: subprocessResult.stderr
    )
  }

  private func executablePath() throws -> URL {
    if let binDirectory {
      return binDirectory.appendingPathComponent("apple")
    }
    if let override = environment["APPLE_CLI_BIN_DIR"], !override.isEmpty {
      return URL(fileURLWithPath: override).appendingPathComponent("apple")
    }
    var size: UInt32 = 0
    _ = _NSGetExecutablePath(nil, &size)
    guard size > 0 else {
      throw CLIError(code: .backendUnavailable, message: "Could not locate the running MCP executable.")
    }
    var buffer = [CChar](repeating: 0, count: Int(size))
    guard _NSGetExecutablePath(&buffer, &size) == 0 else {
      throw CLIError(code: .backendUnavailable, message: "Could not locate the running MCP executable.")
    }
    let pathBytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
    return URL(fileURLWithPath: String(decoding: pathBytes, as: UTF8.self))
      .resolvingSymlinksInPath()
      .deletingLastPathComponent()
      .appendingPathComponent("apple")
  }
}

public struct CLIToolRunPayload: Codable, Equatable, Sendable {
  public var target: String
  public var exitCode: Int32
  public var ok: Bool
  public var stdout: String
  public var stderr: String
}

public struct CLITargetListPayload: Codable, Equatable, Sendable {
  public var targets: [String]
}

public struct CLICommandCatalogOption: Codable, Equatable, Sendable {
  public var names: [String]
  public var valueName: String?
  public var valueRequired: Bool
  public var valueType: String
  public var description: String

  public init(names: [String], valueName: String?, description: String) {
    self.names = names
    self.valueName = valueName
    self.valueRequired = valueName != nil
    self.valueType = inferredCatalogOptionValueType(names: names, valueName: valueName)
    self.description = description
  }
}

public struct CLICommandCatalogInputProperty: Codable, Equatable, Sendable {
  public var type: String
  public var cliNames: [String]
  public var valueName: String?
  public var valueRequired: Bool
  public var description: String
  public var cliArgumentKind: String

  public init(option: CLICommandCatalogOption) {
    self.type = option.valueType
    self.cliNames = option.names
    self.valueName = option.valueName
    self.valueRequired = option.valueRequired
    self.description = option.description
    self.cliArgumentKind = option.valueRequired ? "option" : "flag"
  }
}

public struct CLICommandCatalogInputSchema: Codable, Equatable, Sendable {
  public var type: String
  public var additionalProperties: Bool
  public var required: [String]
  public var properties: [String: CLICommandCatalogInputProperty]
  public var cliArgumentOrder: [String]

  public init(
    required: [String],
    properties: [String: CLICommandCatalogInputProperty],
    cliArgumentOrder: [String]
  ) {
    self.type = "object"
    self.additionalProperties = false
    self.required = required
    self.properties = properties
    self.cliArgumentOrder = cliArgumentOrder
  }
}

public struct CLICommandCatalogEntry: Codable, Equatable, Sendable {
  public var path: [String]
  public var usage: String?
  public var subcommands: [String]
  public var options: [CLICommandCatalogOption]
  public var inputSchema: CLICommandCatalogInputSchema

  public init(
    path: [String],
    usage: String?,
    subcommands: [String],
    options: [CLICommandCatalogOption] = [],
    inputSchema: CLICommandCatalogInputSchema? = nil
  ) {
    self.path = path
    self.usage = usage
    self.subcommands = subcommands
    self.options = options
    self.inputSchema =
      inputSchema ?? commandCatalogInputSchema(usage: usage, options: options)
  }
}

private func inferredCatalogOptionValueType(names: [String], valueName: String?) -> String {
  guard let valueName else {
    return "boolean"
  }
  let normalizedNames = names
    .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "-")).lowercased() }
  let normalizedValueName = valueName.lowercased()
  let tokens = Set(normalizedNames + [normalizedValueName])
  let integerTokens: Set<String> = [
    "amount",
    "column",
    "count",
    "duration",
    "from-ordinal",
    "index",
    "limit",
    "max-commands",
    "max-depth",
    "occurrence",
    "ordinal",
    "relative-amount",
    "row",
    "size",
    "timeout",
    "timeout-seconds",
    "to-ordinal",
  ]
  if !tokens.isDisjoint(with: integerTokens) {
    return "integer"
  }
  return "string"
}

private func commandCatalogInputSchema(
  usage: String?,
  options: [CLICommandCatalogOption]
) -> CLICommandCatalogInputSchema {
  var properties: [String: CLICommandCatalogInputProperty] = [:]
  var order: [String] = []
  var required: [String] = []

  for option in options {
    let propertyName = commandCatalogPropertyName(for: option)
    guard !propertyName.isEmpty, properties[propertyName] == nil else {
      continue
    }
    properties[propertyName] = CLICommandCatalogInputProperty(option: option)
    order.append(propertyName)
    if let usage, option.names.contains(where: { optionNameIsRequired($0, in: usage) }) {
      required.append(propertyName)
    }
  }

  return CLICommandCatalogInputSchema(
    required: required,
    properties: properties,
    cliArgumentOrder: order
  )
}

private func commandCatalogPropertyName(for option: CLICommandCatalogOption) -> String {
  let name = option.names.first { $0.hasPrefix("--") } ?? option.names.first ?? ""
  return name.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
}

private func optionNameIsRequired(_ name: String, in usage: String) -> Bool {
  var searchRange = usage.startIndex..<usage.endIndex
  while let range = usage.range(of: name, range: searchRange) {
    defer { searchRange = range.upperBound..<usage.endIndex }
    guard optionNameHasBoundary(in: usage, range: range) else {
      continue
    }
    guard bracketDepth(in: usage, before: range.lowerBound) == 0 else {
      continue
    }
    return true
  }
  return false
}

private func optionNameHasBoundary(in text: String, range: Range<String.Index>) -> Bool {
  if range.lowerBound > text.startIndex {
    let previous = text[text.index(before: range.lowerBound)]
    guard previous.isWhitespace || previous == "[" || previous == "|" || previous == "(" else {
      return false
    }
  }
  guard range.upperBound < text.endIndex else {
    return true
  }
  let next = text[range.upperBound]
  return next.isWhitespace || next == "=" || next == "]" || next == "|" || next == ")"
}

private func bracketDepth(in text: String, before index: String.Index) -> Int {
  var depth = 0
  var cursor = text.startIndex
  while cursor < index {
    if text[cursor] == "[" {
      depth += 1
    } else if text[cursor] == "]", depth > 0 {
      depth -= 1
    }
    cursor = text.index(after: cursor)
  }
  return depth
}

public struct CLICommandCatalogPayload: Codable, Equatable, Sendable {
  public var target: String
  public var maxDepth: Int
  public var maxCommands: Int
  public var truncated: Bool
  public var commands: [CLICommandCatalogEntry]

  public init(
    target: String,
    maxDepth: Int,
    maxCommands: Int,
    truncated: Bool,
    commands: [CLICommandCatalogEntry]
  ) {
    self.target = target
    self.maxDepth = maxDepth
    self.maxCommands = maxCommands
    self.truncated = truncated
    self.commands = commands
  }
}

public struct AppleMCPAdapter: Sendable {
  public static let canonicalTargets = [
    "notes",
    "calendar",
    "reminders",
    "contacts",
    "mail",
    "messages",
    "maps",
    "finder",
    "numbers",
    "pages",
    "keynote",
    "facetime",
    "safari",
    "photos",
    "print",
    "clipboard",
    "notifications",
    "intelligence",
    "tcc",
  ]

  private let runner: any CLIProcessRunning

  public init(runner: any CLIProcessRunning = CLIProcessRunner()) {
    self.runner = runner
  }

  public func tools() -> [Tool] {
    [
      Tool(
        name: "apple_cli_list_targets",
        title: "List apple-cli Targets",
        description: "List the accepted apple-cli Apple app/domain/system CLI targets.",
        inputSchema: .object([
          "type": .string("object"),
          "additionalProperties": .bool(false),
          "properties": .object([:]),
        ]),
        annotations: readOnlyAnnotations()
      ),
      Tool(
        name: "apple_cli_doctor",
        title: "Run apple-cli Doctor",
        description:
          "Run `doctor --json` for one accepted CLI target. This is read-only and preserves the target's permission diagnostics.",
        inputSchema: targetSchema(required: ["target"]),
        annotations: readOnlyAnnotations()
      ),
      Tool(
        name: "apple_cli_status",
        title: "Run apple-cli Target Status",
        description:
          "Run `<target> --json` for one accepted CLI target. This is read-only and returns the canonical target status envelope.",
        inputSchema: targetSchema(required: ["target"]),
        annotations: readOnlyAnnotations()
      ),
      Tool(
        name: "apple_cli_help",
        title: "Read apple-cli Help",
        description:
          "Read help for one accepted CLI target or target subcommand path. The adapter appends `--help` unless supplied.",
        inputSchema: helpSchema(),
        annotations: readOnlyAnnotations()
      ),
      Tool(
        name: "apple_cli_command_catalog",
        title: "Discover apple-cli Command Catalog",
        description:
          "Build a CLI-derived command catalog for one accepted target by recursively reading `--help` output and parsing subcommands plus options. This is read-only and does not expose hidden adapter behavior.",
        inputSchema: catalogSchema(),
        annotations: readOnlyAnnotations()
      ),
      Tool(
        name: "apple_cli_run",
        title: "Run apple-cli Command",
        description:
          "Run one accepted CLI target with explicit CLI arguments. The adapter appends `--json` unless supplied; preserve target-local safety policy by using `--dry-run` for previews and adding specific `--allow-*` flags only when the user explicitly authorized that risk.",
        inputSchema: runSchema(),
        annotations: Tool.Annotations(
          readOnlyHint: false,
          destructiveHint: true,
          idempotentHint: false,
          openWorldHint: true
        )
      ),
    ]
  }

  public func callTool(name: String, arguments: [String: Value]) async throws -> CallTool.Result {
    do {
      let structured = try await callToolStructured(name: name, arguments: arguments)
      return toolResult(structured)
    } catch let error as CancellationError {
      throw error
    } catch let error as CLIError {
      return toolResult(errorStructuredContent(error))
    } catch {
      return toolResult(
        errorStructuredContent(
          CLIError(code: .internalError, message: "The CLI adapter failed unexpectedly.")
        )
      )
    }
  }

  private func callToolStructured(name: String, arguments: [String: Value]) async throws -> Value {
    switch name {
    case "apple_cli_list_targets":
      return try encodedValue(CLITargetListPayload(targets: Self.canonicalTargets))
    case "apple_cli_doctor":
      let target = try targetArgument(arguments)
      return try await run(
        target: target, arguments: ["doctor", "--json"], timeoutSeconds: timeoutArgument(arguments))
    case "apple_cli_status":
      let target = try targetArgument(arguments)
      return try await run(target: target, arguments: ["--json"], timeoutSeconds: timeoutArgument(arguments))
    case "apple_cli_help":
      let target = try targetArgument(arguments)
      return try await run(
        target: target, arguments: helpArguments(arguments), timeoutSeconds: timeoutArgument(arguments))
    case "apple_cli_command_catalog":
      let target = try targetArgument(arguments)
      return try await commandCatalog(
        target: target,
        maxDepth: try boundedIntArgument(
          arguments, name: "maxDepth", defaultValue: 2, bounds: 0...4),
        maxCommands: try boundedIntArgument(
          arguments, name: "maxCommands", defaultValue: 80, bounds: 1...200),
        timeoutSeconds: timeoutArgument(arguments)
      )
    case "apple_cli_run":
      let target = try targetArgument(arguments)
      let cliArguments = try cliArguments(arguments)
      return try await run(
        target: target, arguments: cliArguments, timeoutSeconds: timeoutArgument(arguments))
    default:
      throw CLIError(
        code: .unsupportedOperation, message: "Unknown MCP tool.", details: ["tool": name])
    }
  }

  private func run(target: String, arguments: [String], timeoutSeconds: Int) async throws -> Value {
    let result = try await runner.run(
      target: target, arguments: arguments, timeoutSeconds: timeoutSeconds)
    return try encodedValue(
      CLIToolRunPayload(
        target: result.target,
        exitCode: result.exitCode,
        ok: result.exitCode == 0,
        stdout: result.stdout,
        stderr: result.stderr
      )
    )
  }

  private func commandCatalog(
    target: String,
    maxDepth: Int,
    maxCommands: Int,
    timeoutSeconds: Int
  ) async throws -> Value {
    var queue: [[String]] = [[]]
    var commands: [CLICommandCatalogEntry] = []
    var truncated = false

    while !queue.isEmpty {
      if commands.count >= maxCommands {
        truncated = true
        break
      }

      let path = queue.removeFirst()
      let helpArguments = path + ["--help"]
      let result = try await runner.run(
        target: target,
        arguments: helpArguments,
        timeoutSeconds: timeoutSeconds
      )
      guard result.exitCode == 0 else {
        throw CLIError(
          code: .backendUnavailable,
          message: "CLI help command failed while building the command catalog.",
          details: [
            "target": target,
            "path": path.joined(separator: " "),
            "exit_code": "\(result.exitCode)",
          ]
        )
      }

      let parsed = parseHelp(result.stdout)
      commands.append(
        CLICommandCatalogEntry(
          path: path,
          usage: parsed.usage,
          subcommands: parsed.subcommands,
          options: parsed.options
        ))

      if path.count < maxDepth {
        for subcommand in parsed.subcommands {
          if commands.count + queue.count >= maxCommands {
            truncated = true
            break
          }
          queue.append(path + [subcommand])
        }
      }
    }

    return try encodedValue(
      CLICommandCatalogPayload(
        target: target,
        maxDepth: maxDepth,
        maxCommands: maxCommands,
        truncated: truncated,
        commands: commands
      ))
  }

  private func targetArgument(_ arguments: [String: Value]) throws -> String {
    guard let target = arguments["target"]?.stringValue else {
      throw CLIError(code: .validationError, message: "Missing required MCP argument `target`.")
    }
    guard Self.canonicalTargets.contains(target) else {
      throw CLIError(
        code: .validationError, message: "Unsupported CLI target.", details: ["target": target])
    }
    return target
  }

  private func timeoutArgument(_ arguments: [String: Value]) throws -> Int {
    let timeout = arguments["timeoutSeconds"]?.intValue ?? 30
    guard (1...120).contains(timeout) else {
      throw CLIError(code: .validationError, message: "`timeoutSeconds` must be between 1 and 120.")
    }
    return timeout
  }

  private func boundedIntArgument(
    _ arguments: [String: Value],
    name: String,
    defaultValue: Int,
    bounds: ClosedRange<Int>
  ) throws -> Int {
    let value = arguments[name]?.intValue ?? defaultValue
    guard bounds.contains(value) else {
      throw CLIError(
        code: .validationError,
        message: "`\(name)` must be between \(bounds.lowerBound) and \(bounds.upperBound).")
    }
    return value
  }

  private func cliArguments(_ arguments: [String: Value]) throws -> [String] {
    guard let values = arguments["arguments"]?.arrayValue else {
      throw CLIError(code: .validationError, message: "Missing required MCP argument `arguments`.")
    }
    var cliArguments: [String] = []
    for value in values {
      guard let string = value.stringValue else {
        throw CLIError(code: .validationError, message: "`arguments` must contain only strings.")
      }
      cliArguments.append(string)
    }
    if !cliArguments.contains("--json") {
      cliArguments.append("--json")
    }
    return cliArguments
  }

  private func helpArguments(_ arguments: [String: Value]) throws -> [String] {
    let values = arguments["arguments"]?.arrayValue ?? []
    var cliArguments: [String] = []
    for value in values {
      guard let string = value.stringValue else {
        throw CLIError(code: .validationError, message: "`arguments` must contain only strings.")
      }
      cliArguments.append(string)
    }
    if !cliArguments.contains("--help") && !cliArguments.contains("-h") {
      cliArguments.append("--help")
    }
    return cliArguments
  }

  private func targetSchema(required: [String]) -> Value {
    .object([
      "type": .string("object"),
      "additionalProperties": .bool(false),
      "required": .array(required.map(Value.string)),
      "properties": .object([
        "target": .object([
          "type": .string("string"),
          "enum": .array(Self.canonicalTargets.map(Value.string)),
        ]),
        "timeoutSeconds": .object([
          "type": .string("integer"),
          "minimum": .int(1),
          "maximum": .int(120),
          "default": .int(30),
        ]),
      ]),
    ])
  }

  private func runSchema() -> Value {
    var schema = targetSchema(required: ["target", "arguments"])
    guard case .object(var root) = schema, case .object(var properties) = root["properties"] else {
      return schema
    }
    properties["arguments"] = .object([
      "type": .string("array"),
      "items": .object(["type": .string("string")]),
      "description": .string("CLI positionals and options. `--json` is appended when omitted."),
    ])
    root["properties"] = .object(properties)
    schema = .object(root)
    return schema
  }

  private func helpSchema() -> Value {
    var schema = targetSchema(required: ["target"])
    guard case .object(var root) = schema, case .object(var properties) = root["properties"] else {
      return schema
    }
    properties["arguments"] = .object([
      "type": .string("array"),
      "items": .object(["type": .string("string")]),
      "description": .string("Optional target subcommand path to inspect. `--help` is appended when omitted."),
      "default": .array([]),
    ])
    root["properties"] = .object(properties)
    schema = .object(root)
    return schema
  }

  private func catalogSchema() -> Value {
    var schema = targetSchema(required: ["target"])
    guard case .object(var root) = schema, case .object(var properties) = root["properties"] else {
      return schema
    }
    properties["maxDepth"] = .object([
      "type": .string("integer"),
      "minimum": .int(0),
      "maximum": .int(4),
      "default": .int(2),
      "description": .string("Maximum subcommand depth to inspect from CLI help."),
    ])
    properties["maxCommands"] = .object([
      "type": .string("integer"),
      "minimum": .int(1),
      "maximum": .int(200),
      "default": .int(80),
      "description": .string("Maximum command help pages to inspect before truncating."),
    ])
    root["properties"] = .object(properties)
    schema = .object(root)
    return schema
  }

  private func parseHelp(_ text: String) -> (
    usage: String?,
    subcommands: [String],
    options: [CLICommandCatalogOption]
  ) {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    let usage = lines.first { $0.hasPrefix("USAGE:") }
    var subcommands: [String] = []
    var options: [CLICommandCatalogOption] = []
    var readingSubcommands = false
    var readingOptions = false
    var currentOptionIndex: Int?

    for line in lines {
      let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
      if trimmed == "OPTIONS:" {
        readingOptions = true
        readingSubcommands = false
        currentOptionIndex = nil
        continue
      }
      if trimmed == "SUBCOMMANDS:" {
        readingSubcommands = true
        readingOptions = false
        currentOptionIndex = nil
        continue
      }
      if isHelpSectionHeader(trimmed) {
        readingSubcommands = false
        readingOptions = false
        currentOptionIndex = nil
        continue
      }
      if readingOptions {
        if trimmed.isEmpty {
          currentOptionIndex = nil
          continue
        }
        if let option = parseOptionLine(trimmed) {
          options.append(option)
          currentOptionIndex = options.indices.last
          continue
        }
        if let currentOptionIndex, !trimmed.hasPrefix("See ") {
          let existing = options[currentOptionIndex].description
          options[currentOptionIndex].description = [existing, trimmed]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        }
        continue
      }
      guard readingSubcommands else {
        continue
      }
      if trimmed.isEmpty {
        if !subcommands.isEmpty {
          readingSubcommands = false
        }
        continue
      }
      if trimmed.hasPrefix("See ") {
        readingSubcommands = false
        continue
      }
      guard let name = trimmed.split(separator: " ", maxSplits: 1).first else {
        continue
      }
      let subcommand = String(name)
      if !subcommand.hasPrefix("-") {
        subcommands.append(subcommand)
      }
    }

    return (usage, subcommands, options)
  }

  private func isHelpSectionHeader(_ trimmed: String) -> Bool {
    !trimmed.isEmpty && trimmed.hasSuffix(":") && trimmed.uppercased() == trimmed
  }

  private func parseOptionLine(_ trimmed: String) -> CLICommandCatalogOption? {
    guard trimmed.hasPrefix("-") else {
      return nil
    }

    let (declaration, description) = splitOptionDeclarationAndDescription(trimmed)
    if description.isEmpty {
      let parsed = parseCompactOptionLine(declaration)
      if !parsed.names.isEmpty {
        return CLICommandCatalogOption(
          names: parsed.names,
          valueName: parsed.valueName,
          description: parsed.description
        )
      }
    }

    var names: [String] = []
    var valueName: String?
    var recoveredDescriptions: [String] = []

    for rawPart in declaration.split(separator: ",", omittingEmptySubsequences: true) {
      let parsed = parseOptionDeclarationPart(String(rawPart))
      guard let name = parsed.name else {
        continue
      }
      names.append(name)
      if valueName == nil {
        valueName = parsed.valueName
      }
      if !parsed.description.isEmpty {
        recoveredDescriptions.append(parsed.description)
      }
    }

    guard !names.isEmpty else {
      return nil
    }
    let resolvedDescription =
      description.isEmpty ? recoveredDescriptions.joined(separator: " ") : description
    return CLICommandCatalogOption(
      names: names,
      valueName: valueName,
      description: resolvedDescription
    )
  }

  private func parseCompactOptionLine(_ line: String) -> (
    names: [String],
    valueName: String?,
    description: String
  ) {
    let tokens = line
      .split(whereSeparator: { $0 == " " || $0 == "\t" })
      .map(String.init)
    var names: [String] = []
    var valueName: String?
    var descriptionTokens: [String] = []
    var index = 0

    while index < tokens.count {
      var token = tokens[index]
      let hasTrailingComma = token.hasSuffix(",")
      if hasTrailingComma {
        token.removeLast()
      }

      guard token.hasPrefix("-") else {
        descriptionTokens = Array(tokens[index...])
        break
      }

      var name = token
      if let equals = token.firstIndex(of: "=") {
        name = String(token[..<equals])
        let start = token.index(after: equals)
        let value = leadingOptionValue(in: String(token[start...]))
        if valueName == nil {
          valueName = value.valueName
        }
        if !value.remainder.isEmpty {
          descriptionTokens.append(value.remainder)
        }
      }
      names.append(name)
      index += 1

      if index < tokens.count {
        let value = leadingOptionValue(in: tokens[index])
        if let parsedValueName = value.valueName {
          if valueName == nil {
            valueName = parsedValueName
          }
          if !value.remainder.isEmpty {
            descriptionTokens.append(value.remainder)
          }
          index += 1
        }
      }

      if hasTrailingComma {
        continue
      }
      if index < tokens.count {
        descriptionTokens.append(contentsOf: tokens[index...])
      }
      break
    }

    return (names, valueName, descriptionTokens.joined(separator: " "))
  }

  private func parseOptionDeclarationPart(_ rawPart: String) -> (
    name: String?,
    valueName: String?,
    description: String
  ) {
    let part = rawPart.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !part.isEmpty else {
      return (nil, nil, "")
    }

    let token: String
    let remainder: String
    if let separator = part.firstIndex(where: { $0 == " " || $0 == "\t" }) {
      token = String(part[..<separator])
      let start = part.index(after: separator)
      remainder = String(part[start...]).trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      token = part
      remainder = ""
    }

    let name: String
    let attachedRemainder: String
    if let equals = token.firstIndex(of: "=") {
      name = String(token[..<equals])
      let start = token.index(after: equals)
      attachedRemainder = String(token[start...]).trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      name = token
      attachedRemainder = remainder
    }

    guard name.hasPrefix("-") else {
      return (nil, nil, "")
    }

    let value = leadingOptionValue(in: attachedRemainder)
    return (
      name,
      value.valueName,
      value.remainder
    )
  }

  private func splitOptionDeclarationAndDescription(_ line: String) -> (
    declaration: String,
    description: String
  ) {
    let normalized = line.replacingOccurrences(of: "\t", with: "  ")
    var spaceRunStart: String.Index?
    var spaceRunCount = 0

    for index in normalized.indices {
      if normalized[index] == " " {
        if spaceRunCount == 0 {
          spaceRunStart = index
        }
        spaceRunCount += 1
        if spaceRunCount >= 2, let spaceRunStart {
          let descriptionStart = normalized.index(after: index)
          return (
            String(normalized[..<spaceRunStart])
              .trimmingCharacters(in: .whitespacesAndNewlines),
            String(normalized[descriptionStart...])
              .trimmingCharacters(in: .whitespacesAndNewlines)
          )
        }
      } else {
        spaceRunStart = nil
        spaceRunCount = 0
      }
    }

    return (
      normalized.trimmingCharacters(in: .whitespacesAndNewlines),
      ""
    )
  }

  private func leadingOptionValue(in text: String) -> (valueName: String?, remainder: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.first == "<", let close = trimmed.firstIndex(of: ">") else {
      return (nil, trimmed)
    }
    let start = trimmed.index(after: trimmed.startIndex)
    let value = String(trimmed[start..<close]).trimmingCharacters(in: .whitespacesAndNewlines)
    let remainderStart = trimmed.index(after: close)
    let remainder = String(trimmed[remainderStart...])
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return (value.isEmpty ? nil : value, remainder)
  }

  private func readOnlyAnnotations() -> Tool.Annotations {
    Tool.Annotations(
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false
    )
  }

  private func toolResult(_ structured: Value) -> CallTool.Result {
    let object = structured.objectValue ?? [:]
    let ok = object["ok"]?.boolValue ?? true
    let stdout = object["stdout"]?.stringValue ?? ""
    let stderr = object["stderr"]?.stringValue ?? ""
    let text = !stdout.isEmpty ? stdout : (!stderr.isEmpty ? stderr : compactJSONString(structured))
    return CallTool.Result(
      content: [.text(text: text, annotations: nil, _meta: nil)],
      structuredContent: Optional.some(structured),
      isError: !ok
    )
  }

  private func errorStructuredContent(_ error: CLIError) -> Value {
    let envelope = CLIErrorEnvelope(
      error: error.payload,
      meta: ["target": "apple-cli-mcp"]
    )
    return (try? encodedValue(envelope))
      ?? .object([
        "ok": .bool(false),
        "error": .object([
          "code": .string(error.code.rawValue),
          "message": .string(error.message),
        ]),
        "meta": .object(["target": .string("apple-cli-mcp")]),
        "warnings": .array([]),
      ])
  }
}

public enum AppleMCPServerFactory {
  public static func makeServer(
    adapter: AppleMCPAdapter = AppleMCPAdapter(),
    name: String = "apple-cli-mcp",
    version: String = CLIVersion.current
  ) async -> Server {
    let server = Server(
      name: name,
      version: version,
      capabilities: .init(tools: .init())
    )

    await server.withMethodHandler(ListTools.self) { _ in
      ListTools.Result(tools: adapter.tools())
    }

    await server.withMethodHandler(CallTool.self) { params in
      try await adapter.callTool(name: params.name, arguments: params.arguments ?? [:])
    }

    return server
  }
}

private func encodedValue(_ value: some Encodable) throws -> Value {
  let data = try JSONEncoder().encode(value)
  return try JSONDecoder().decode(Value.self, from: data)
}

private func compactJSONString(_ value: Value) -> String {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.sortedKeys]
  guard let data = try? encoder.encode(value), let text = String(data: data, encoding: .utf8)
  else {
    return "{}"
  }
  return text
}
