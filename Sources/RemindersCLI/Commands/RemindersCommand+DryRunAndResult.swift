import Foundation
import Utility

extension RemindersCommand {
  func mutation<Payload: Encodable>(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    commit: () throws -> Payload
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    if operation.contains("matching") || operation.contains("cleanup") {
      try CLISafety.requireFlag(
        "allow-destructive-selection",
        in: options,
        category: .destructiveSelection,
        message:
          "\(operation) mutates a dynamically selected reminder set and requires `--allow-destructive-selection`."
      )
    }

    return try result(try commit(), human: "\(operation) executed", options: options)
  }

  func requireDestructiveSelectionIfExecuting(
    _ options: CLIOptions,
    operation: String
  ) throws {
    guard !options.dryRun else { return }
    try CLISafety.requireFlag(
      "allow-destructive-selection",
      in: options,
      category: .destructiveSelection,
      message:
        "\(operation) mutates a dynamically selected reminder set and requires `--allow-destructive-selection`."
    )
  }

  func reminderQuery(options: CLIOptions, searchText: String?) throws -> ReminderQuery {
    let dueFrom = try optionalDateBoundary(options.targetOption("due-from"), role: .lower)
    let dueTo = try optionalDateBoundary(options.targetOption("due-to"), role: .upper)

    if let dueFrom, let dueTo, dueFrom >= dueTo {
      throw CLIError(
        code: .validationError,
        message: "`--due-from` must be earlier than `--due-to`."
      )
    }

    return ReminderQuery(
      listSelector: options.targetOption("list"),
      completion: try completionFilter(options.targetOption("status")),
      dueFrom: dueFrom,
      dueTo: dueTo,
      searchText: searchText,
      limit: try commandLimit(options)
    )
  }

  func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
