import Foundation
import Utility

extension NotesCommand {

  func normalizedBoolOption(_ name: String, options: CLIOptions) throws -> Bool {
    let value = try normalizedOption(name, options: options).lowercased()
    switch value {
    case "true", "yes", "on", "1":
      return true
    case "false", "no", "off", "0":
      return false
    default:
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be true or false.",
        details: ["allowed": "true,false"]
      )
    }
  }

  func normalizedPositiveInt(_ raw: String, option: String) throws -> Int {
    let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let intValue = Int(value), intValue > 0 else {
      throw CLIError(
        code: .validationError,
        message: "`--\(option)` must be a positive integer.",
        details: ["option": option, "value_sha256": sha256Hex(value)]
      )
    }
    return intValue
  }

  func requiredPositiveIntOption(
    _ name: String,
    options: CLIOptions,
    operation: String
  ) throws -> Int {
    let raw = try requiredOption(name, options: options)
    guard let value = Int(raw.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be a positive integer.",
        details: [
          "operation": operation,
          "\(name)_sha256": sha256Hex(raw),
        ]
      )
    }
    return value
  }

  func normalizedPositiveIntOption(_ name: String, options: CLIOptions) throws -> Int {
    let value = try normalizedOption(name, options: options)
    guard let integer = Int(value), integer > 0 else {
      throw CLIError(
        code: .validationError,
        message: "`--\(name)` must be a positive integer."
      )
    }
    return integer
  }

  func artifactVerificationFailureDetails(
    operation: String,
    verification: NotesMutationVerificationReport
  ) -> [String: String] {
    let failed = verification.checks.filter { $0.status == "failed" }
    return [
      "operation": operation,
      "failed_checks": failed.map(\.name).joined(separator: ","),
      "failed_check_details": failed.map(verificationCheckDetail).joined(separator: ","),
      "target_id_sha256": verification.targetIDSHA256,
    ]
  }

  private func verificationCheckDetail(_ check: NotesVerificationCheckRecord) -> String {
    let expected =
      check.expectedSHA256 ?? check.expectedLength.map(String.init) ?? check.expectedBool.map(String.init) ?? ""
    let actual =
      check.actualSHA256 ?? check.actualLength.map(String.init) ?? check.actualBool.map(String.init) ?? ""
    return [check.name, expected, actual].joined(separator: ":")
  }

  func stableUniqueStrings(_ values: [String]) -> [String] {
    var seen: Set<String> = []
    var result: [String] = []
    for value in values where seen.insert(value).inserted {
      result.append(value)
    }
    return result
  }

  func validateExactlyOneTargetOption(
    _ names: [String],
    options: CLIOptions,
    commandName: String
  ) throws {
    let present = names.filter { name in
      (options.targetOption(name) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    guard present.count == 1 else {
      throw CLIError(
        code: .validationError,
        message: "`\(commandName)` requires exactly one of \(names.map { "--\($0)" }.joined(separator: " or ")).",
        details: [
          "required_selector_count": "1",
          "accepted_selectors": names.joined(separator: ","),
          "provided_selector_count": "\(present.count)",
        ]
      )
    }
  }

  func verificationBoolCheck(
    name: String,
    expected: Bool,
    actual: Bool
  ) -> NotesVerificationCheckRecord {
    NotesVerificationCheckRecord(
      name: name,
      status: expected == actual ? "passed" : "failed",
      expectedBool: expected,
      actualBool: actual
    )
  }

  func privacySafeTextSearchMatchCount(text: String, query: String) -> Int {
    var count = 0
    var searchRange: Range<String.Index>? = text.startIndex..<text.endIndex
    while let range = text.range(
      of: query,
      options: [.caseInsensitive, .diacriticInsensitive],
      range: searchRange
    ) {
      count += 1
      searchRange = range.upperBound..<text.endIndex
    }
    return count
  }

  func mutation<Result: Encodable>(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    category: CLISafetyCategory = .ordinaryMutation,
    allowFlags: [String] = [],
    dryRunNotes: [String] = [],
    commit: () throws -> Result
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: category,
          allowFlags: allowFlags,
          notes: dryRunNotes
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    for flag in allowFlags {
      let normalizedFlag = flag.hasPrefix("--") ? String(flag.dropFirst(2)) : flag
      try CLISafety.requireFlag(
        normalizedFlag,
        in: options,
        category: category,
        message: "\(operation) mutates a dynamically selected Notes set and requires `--\(normalizedFlag)`."
      )
    }

    return try result(try commit(), human: "\(operation) executed", options: options)
  }

  func mutationVerifier() -> NotesMutationVerifier {
    NotesMutationVerifier(
      reader: implementation,
      restorableReader: implementation,
      tagReader: implementation as? any NotesTagReading,
      folderPurgeReader: implementation as? any NotesFolderPurgeReading,
      smartFolderReader: implementation as? any NotesSmartFolderReading,
      bodyStructureReader: implementation as? any NotesBodyStructureReading,
      noteStateReader: implementation as? any NotesNoteStateReading,
      sqliteReader: sqliteReader
    )
  }

  func resolveRead(_ options: CLIOptions) throws -> NotesNoteDetail {
    if let id = options.targetOption("id") {
      guard let note = try implementation.readNote(id: id) else {
        throw CLIError(code: .notFound, message: "Note was not found.", details: ["id": id])
      }
      return note
    }

    let title = try requiredOption("title", options: options)
    let matches = try implementation.readNotesByTitle(
      title,
      folder: options.targetOption("folder"),
      limit: 2
    )

    if matches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity,
        message: "Note title matched multiple notes; use `--id`.",
        details: ["title": title]
      )
    }

    guard let note = matches.first else {
      throw CLIError(
        code: .notFound, message: "Note title did not match any note.", details: ["title": title])
    }

    return note
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
