import AppKit
import Contacts
import CryptoKit
import Foundation
import Utility

public struct FaceTimeCommand: Sendable {
  private let resolver: any FaceTimeResolving
  private let caller: any FaceTimeCalling
  private let target = "facetime"

  public init(
    resolver: any FaceTimeResolving = ContactsFaceTimeResolver(),
    caller: any FaceTimeCalling = NSWorkspaceFaceTimeCaller()
  ) {
    self.resolver = resolver
    self.caller = caller
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["contacts", "resolve"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query"])
      let query = try requiredOption("query", options: options)
      guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
        throw CLIError(
          code: .validationError,
          message: "`--query` must contain at least 2 non-whitespace characters.")
      }
      let contacts = try resolver.resolveContacts(query: query, limit: try commandLimit(options))
      return try result(
        FaceTimeContactsResponse(contacts: contacts),
        human: contactsHumanOutput(contacts),
        options: options
      )
    case ["calls", "prepare"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["handle", "kind"])
      let preview = try callPreview(options)
      return try result(
        FaceTimeCallResponse(call: preview),
        human: callHumanOutput(preview),
        options: options
      )
    case ["calls", "start"]:
      try validateTargetOptions(options, allowedOptions: ["handle", "kind"])
      let preview = try callPreview(options)
      return try start(preview, options: options)
    default:
      return nil
    }
  }

  private func start(_ preview: FaceTimeCallPreview, options: CLIOptions) throws -> CLICommandResult
  {
    let operation = "calls.start"
    let summary = callSummary(preview)

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: "facetime-call-start",
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "FaceTime call start dispatches to FaceTime and requires `--allow-external-dispatch`."
    )

    let submitted = try caller.startCall(preview)
    return try result(
      FaceTimeCallResult(operation: operation, submitted: submitted, url: preview.url),
      human: "calls.start submitted=\(submitted)",
      options: options
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
