import Foundation
import Utility

public struct TCCCommand: Sendable {
  private let database: TCCDatabaseBackend
  private let identity: any TCCIdentityReading
  private let resetRunner: any TCCResetRunning
  private let framework: any TCCFrameworkManaging
  private let access: any TCCAccessChecking
  private let target = "tcc"

  public init(
    database: TCCDatabaseBackend = TCCDatabaseBackend(),
    identity: any TCCIdentityReading = TCCIdentityReader(),
    resetRunner: any TCCResetRunning = TCCTccutilResetRunner(),
    framework: any TCCFrameworkManaging = TCCPrivateFrameworkBackend(),
    access: any TCCAccessChecking = TCCPublicAccessBackend()
  ) {
    self.database = database
    self.identity = identity
    self.resetRunner = resetRunner
    self.framework = framework
    self.access = access
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["services", "list"]:
      try tccValidateReadOnly(options)
      return try tccResult(
        TCCServicesResponse(services: TCCServiceCatalog.services),
        human: TCCServiceCatalog.services.map(\.rawName).joined(separator: "\n"),
        options: options
      )
    case ["database", "info"]:
      try tccValidateReadOnly(options, allowedOptions: ["scope", "database"])
      let infos = database.databaseInfos(
        scope: try tccScope(options, default: .both),
        overridePath: options.targetOption("database")
      )
      return try tccResult(
        TCCDatabaseInfoResponse(databases: infos),
        human: infosHuman(infos),
        options: options
      )
    case ["database", "digest"]:
      try tccValidateReadOnly(options, allowedOptions: ["scope", "database"])
      let infos = database.databaseInfos(
        scope: try tccScope(options, default: .both),
        overridePath: options.targetOption("database")
      )
      return try tccResult(
        TCCDatabaseDigestResponse(digests: infos),
        human: infos.map { "\($0.scope.rawValue): \($0.digest ?? "unavailable") \($0.path)" }
          .joined(separator: "\n"),
        options: options
      )
    case ["identity", "read"]:
      return try readIdentity(options)
    case ["identity", "resolve"]:
      try tccValidateReadOnly(options, allowedOptions: ["client"])
      let client = try TCCServiceCatalog.client(
        from: try requiredOption("client", options: options),
        explicitType: nil
      )
      return try tccResult(
        TCCClientResponse(client: client),
        human: "\(client.clientTypeName.rawValue): \(client.client)",
        options: options
      )
    case ["framework", "probe"]:
      try tccValidateReadOnly(options)
      let probe = framework.probe()
      return try tccResult(
        TCCFrameworkProbeResponse(probe: probe),
        human: probe.available
          ? TCCWording.privateFrameworkAvailable()
          : TCCWording.privateFrameworkUnavailable(),
        options: options
      )
    default:
      break
    }

    if options.positionals.count >= 3, Array(options.positionals.prefix(2)) == ["services", "read"] {
      try tccValidateReadOnly(options)
      let service = try TCCServiceCatalog.resolve(options.positionals[2])
      return try tccResult(
        TCCServiceResponse(service: service),
        human: "\(service.rawName) (\(service.canonical ? "canonical" : "unknown-raw"))",
        options: options
      )
    }

    if options.positionals.count >= 2, Array(options.positionals.prefix(2)) == ["records", "list"] {
      return try recordsList(options)
    }

    if options.positionals.count >= 4, Array(options.positionals.prefix(2)) == ["records", "read"] {
      return try recordsRead(options)
    }

    if options.positionals.count >= 2,
      options.positionals[0] == "records",
      let operation = TCCRecordsOperation(rawValue: options.positionals[1])
    {
      return try recordsMutation(operation: operation, options: options)
    }

    if options.positionals.count >= 1, options.positionals[0] == "doctor" {
      return try doctor(options)
    }

    if options.positionals.count >= 2, options.positionals[0] == "access" {
      return try accessCommand(options)
    }

    if options.positionals.count >= 2, options.positionals[0] == "reset" {
      return try reset(options)
    }

    if options.positionals.count >= 4, Array(options.positionals.prefix(2)) == ["framework", "add"] {
      return try frameworkMutation(operation: "add", options: options)
    }
    if options.positionals.count >= 4, Array(options.positionals.prefix(2)) == ["framework", "reset"] {
      return try frameworkMutation(operation: "reset", options: options)
    }

    return nil
  }

  private func readIdentity(_ options: CLIOptions) throws -> CLICommandResult {
    try tccValidateReadOnly(options, allowedOptions: ["path", "bundle-id"], allowedFlags: ["self"])
    let selectorCount =
      (tccBoolFlag(options, "self") ? 1 : 0)
      + (options.targetOption("path") == nil ? 0 : 1)
      + (options.targetOption("bundle-id") == nil ? 0 : 1)
    guard selectorCount == 1 else {
      throw CLIError(
        code: .validationError,
        message: "`identity read` requires exactly one of `--self`, `--path`, or `--bundle-id`."
      )
    }
    let identityRecord: TCCCodeIdentity
    if tccBoolFlag(options, "self") {
      identityRecord = try identity.readSelfIdentity()
    } else if let path = options.targetOption("path") {
      identityRecord = try identity.readPathIdentity(path)
    } else {
      identityRecord = try identity.readBundleIdentity(try requiredOption("bundle-id", options: options))
    }
    return try tccResult(
      TCCIdentityResponse(identity: identityRecord),
      human: identityHuman(identityRecord),
      options: options
    )
  }

  private func recordsList(_ options: CLIOptions) throws -> CLICommandResult {
    try tccValidateReadOnly(options, allowedOptions: ["scope", "database", "client-type"])
    let service = try tccOptionalPositional(options, at: 2).map { try TCCServiceCatalog.resolve($0) }
    let client = try tccOptionalPositional(options, at: 3).map {
      try TCCServiceCatalog.client(from: $0, explicitType: options.targetOption("client-type"))
    }
    let limit = try tccPositiveLimit(options)
    let query = try database.recordQuery(
      scope: try tccScope(options, default: .both),
      overridePath: options.targetOption("database"),
      service: service,
      client: client,
      limit: limit + 1
    )
    let records = query.records
    let truncated = records.count > limit
    let bounded = Array(records.prefix(limit))
    return try tccResult(
      TCCRecordsResponse(records: bounded, truncated: truncated, issues: query.issues),
      human: recordsHuman(bounded, issues: query.issues),
      options: options
    )
  }

  private func recordsRead(_ options: CLIOptions) throws -> CLICommandResult {
    try tccValidateReadOnly(options, allowedOptions: ["scope", "database", "client-type"])
    let scope = try tccScope(options, default: .user)
    guard scope != .both else {
      throw CLIError(code: .validationError, message: "`records read` requires `--scope user` or `--scope system`.")
    }
    let service = try TCCServiceCatalog.resolve(try tccRequiredPositional(options, at: 2, name: "SERVICE"))
    let client = try TCCServiceCatalog.client(
      from: try tccRequiredPositional(options, at: 3, name: "CLIENT"),
      explicitType: options.targetOption("client-type")
    )
    let records = try database.records(
      scope: scope,
      overridePath: options.targetOption("database"),
      service: service,
      client: client,
      limit: 2
    )
    return try tccResult(
      TCCRecordResponse(record: records.first),
      human: records.first.map { recordsHuman([$0]) } ?? "No matching TCC record.",
      options: options
    )
  }

  private func recordsMutation(operation: TCCRecordsOperation, options: CLIOptions) throws -> CLICommandResult {
    try tccValidateTargetOptions(
      options,
      allowedOptions: ["scope", "database", "backup-dir", "client-type"],
      allowedFlags: ["allow-private-tcc-db-write", "allow-unknown-tcc-service"]
    )
    guard tccBoolFlag(options, "allow-private-tcc-db-write") else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.privateDatabaseWritesRequireAllowFlag()
      )
    }
    let service = try TCCServiceCatalog.resolve(
      try tccRequiredPositional(options, at: 2, name: "SERVICE"),
      allowUnknownRawService: tccBoolFlag(options, "allow-unknown-tcc-service"),
      writeOperation: true
    )
    let client = try TCCServiceCatalog.client(
      from: try tccRequiredPositional(options, at: 3, name: "CLIENT"),
      explicitType: options.targetOption("client-type")
    )
    let context = try database.databaseMutationContext(
      operation: operation,
      scope: try tccScope(options, default: .user),
      overridePath: options.targetOption("database"),
      backupDir: options.targetOption("backup-dir"),
      backupPathOverride: nil,
      service: service,
      client: client
    )
    return try strongMutation(
      context: databaseDryRunContext(context),
      summary: databaseSummary(context),
      intendedDiff: context.intendedDiff,
      currentRowHash: context.currentRowHash,
      backupPath: context.backupPath,
      options: options
    ) {
      try database.performMutation(context)
    }
  }

  private func doctor(_ options: CLIOptions) throws -> CLICommandResult {
    try tccValidateReadOnly(options, allowedOptions: ["for-target", "scope", "database", "client-type"])
    let forTarget = options.targetOption("for-target")
    let service = try tccOptionalPositional(options, at: 1).map { try TCCServiceCatalog.resolve($0) }
    let client = try tccOptionalPositional(options, at: 2).map {
      try TCCServiceCatalog.client(from: $0, explicitType: options.targetOption("client-type"))
    }
    let mapping = try forTarget.map { target -> TCCDoctorTargetMapping in
      guard let mapping = TCCServiceCatalog.services(forTarget: target) else {
        throw CLIError(
          code: .validationError,
          message: "Unknown target for TCC doctor.",
          details: ["target": target]
        )
      }
      return mapping
    }
    let checks = tccDoctorChecks(service: service, client: client, forTarget: mapping, options: options)
    let report = CLIDoctorReport(target: mapping?.target ?? target, checks: checks)
    return try tccResult(
      TCCDoctorResponse(report: report, targetMapping: mapping),
      human: doctorHuman(report),
      options: options,
      exitCode: report.exitCode
    )
  }

  private func accessCommand(_ options: CLIOptions) throws -> CLICommandResult {
    switch options.positionals {
    case let values where values.count == 3 && values[1] == "preflight":
      try tccValidateReadOnly(options)
      let service = try TCCServiceCatalog.resolve(values[2])
      let result = try access.preflight(service: service)
      return try tccResult(result, human: accessHuman(result), options: options)
    case let values where values.count == 3 && values[1] == "request":
      try tccValidateTargetOptions(options, allowedFlags: ["allow-tcc-prompt"])
      guard tccBoolFlag(options, "allow-tcc-prompt") else {
        throw CLIError(
          code: .unsafeMutationRefused,
          message: TCCWording.promptRequestRequiresAllowFlag()
        )
      }
      if options.dryRun {
        throw CLIError(
          code: .unsafeMutationRefused,
          message: TCCWording.accessRequestDoesNotUseDryRun()
        )
      }
      let service = try TCCServiceCatalog.resolve(values[2])
      let result = try access.request(service: service)
      return try tccResult(result, human: accessHuman(result), options: options)
    default:
      return try nilCommand(options)
    }
  }

  private func reset(_ options: CLIOptions) throws -> CLICommandResult {
    try tccValidateTargetOptions(options, allowedFlags: ["allow-tcc-reset"])
    guard tccBoolFlag(options, "allow-tcc-reset") else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.resetRequiresAllowFlag()
      )
    }
    if options.dryRun {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.resetDoesNotUseDryRun()
      )
    }
    let service = try TCCServiceCatalog.resolve(
      try tccRequiredPositional(options, at: 1, name: "SERVICE"),
      allowUnknownRawService: true
    )
    let client = tccOptionalPositional(options, at: 2)
    let result = try resetRunner.reset(service: service, client: client)
    return try tccResult(result, human: "tccutil reset \(service.suffix) \(client ?? "")", options: options)
  }

  private func frameworkMutation(operation: String, options: CLIOptions) throws -> CLICommandResult {
    try tccValidateTargetOptions(
      options,
      allowedFlags: ["allow-private-tcc-framework-write", "allow-unknown-tcc-service"]
    )
    guard tccBoolFlag(options, "allow-private-tcc-framework-write") else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: TCCWording.privateFrameworkWritesRequireAllowFlag()
      )
    }
    let service = try TCCServiceCatalog.resolve(
      try tccRequiredPositional(options, at: 2, name: "SERVICE"),
      allowUnknownRawService: tccBoolFlag(options, "allow-unknown-tcc-service"),
      writeOperation: true
    )
    let bundleID = try tccRequiredPositional(options, at: 3, name: "BUNDLE_ID")
    let summary = [
      "backend": "TCC.framework",
      "operation": "tcc.framework.\(operation)",
      "service": service.rawName,
      "bundle_id": bundleID,
    ]
    let dryRunContext = tccDryRunContext(
      operation: "tcc.framework.\(operation)",
      scope: "framework:\(service.rawName):\(bundleID)",
      summary: summary
    )
    return try strongMutation(
      context: dryRunContext,
      summary: summary,
      intendedDiff: ["action": operation, "service": service.rawName, "bundle_id": bundleID],
      currentRowHash: "not_applicable",
      backupPath: nil,
      options: options
    ) {
      switch operation {
      case "add":
        return try framework.add(service: service, bundleIdentifier: bundleID)
      case "reset":
        return try framework.reset(service: service, bundleIdentifier: bundleID)
      default:
        throw CLIError(code: .internalError, message: "Unknown framework operation.")
      }
    }
  }

  private func strongMutation(
    context: TCCDryRunContext,
    summary: [String: String],
    intendedDiff: [String: String],
    currentRowHash: String,
    backupPath: String?,
    options: CLIOptions,
    commit: () throws -> TCCOperationResult
  ) throws -> CLICommandResult {
    if options.dryRun {
      var dryRunSummary = summary
      dryRunSummary["current_row_sha256"] = currentRowHash
      if let backupPath {
        dryRunSummary["backup_path"] = backupPath
      }
      for (key, value) in intendedDiff {
        dryRunSummary["diff.\(key)"] = value
      }
      return try tccResult(
        CLISafety.dryRun(
          target: target,
          operation: context.operation,
          summary: dryRunSummary,
          scope: context.scope,
          category: .riskBoundSystemAction,
          notes: ["Target-specific TCC `--allow-*` flags still apply before execution."]
        ),
        human: "dry-run: \(context.operation)",
        options: options
      )
    }

    return try tccResult(try commit(), human: "\(context.operation) executed", options: options)
  }

  private func databaseDryRunContext(_ context: TCCDatabaseMutationContext) -> TCCDryRunContext {
    let summary = databaseSummary(context)
    return tccDryRunContext(
      operation: context.operation.operationName,
      scope:
        "\(context.scope.rawValue):\(context.databasePath):\(context.service.rawName):\(context.client.client):\(context.client.clientType):\(context.operation.rawValue)",
      summary: summary
    )
  }

  private func databaseSummary(_ context: TCCDatabaseMutationContext) -> [String: String] {
    [
      "backend": "tcc-db",
      "scope": context.scope.rawValue,
      "db_path": context.databasePath,
      "schema_digest": context.databaseInfo.digest ?? "",
      "schema_columns": context.databaseInfo.schemaColumns.joined(separator: ","),
      "service": context.service.rawName,
      "client": context.client.client,
      "client_type": "\(context.client.clientType)",
      "current_row_hash": context.currentRowHash,
      "backup_path": context.backupPath,
      "operation": context.operation.operationName,
    ]
  }

  private func tccDoctorChecks(
    service: TCCServiceInfo?,
    client: TCCClientInfo?,
    forTarget mapping: TCCDoctorTargetMapping?,
    options: CLIOptions
  ) -> [CLIDoctorCheck] {
    var checks: [CLIDoctorCheck] = []
    let infos = database.databaseInfos(
      scope: (try? tccScope(options, default: .both)) ?? .both,
      overridePath: options.targetOption("database")
    )
    checks.append(contentsOf: infos.map { info in
      CLIDoctorCheck(
        name: "tcc_db_\(info.scope.rawValue)",
        status: info.readable ? .ok : (info.exists ? .permissionDenied : .warning),
        message: info.readable
          ? TCCWording.databaseIsReadable()
          : TCCWording.databaseIsNotReadable(),
        details: [
          "path": info.path,
          "digest": info.digest ?? "",
          "columns": info.schemaColumns.joined(separator: ","),
          "error": info.error ?? "",
        ]
      )
    })
    if let service {
      checks.append(
        CLIDoctorCheck(
          name: "service",
          status: service.canonical ? .ok : .warning,
          message: service.canonical
            ? TCCWording.serviceIsInCatalog()
            : TCCWording.rawServiceIsNotInCatalog(),
          details: ["service": service.rawName, "public_api_route": service.publicAPIRoute ?? ""]
        ))
    }
    if let client {
      checks.append(
        CLIDoctorCheck(
          name: "client_identity",
          status: .ok,
          message: TCCWording.clientIdentityParsed(),
          details: [
            "client": client.client,
            "client_type": "\(client.clientType)",
            "client_type_name": client.clientTypeName.rawValue,
          ]
        ))
    }
    if let mapping {
      checks.append(
        CLIDoctorCheck(
          name: "for_target",
          status: .ok,
          message: TCCWording.targetMappingResolved(),
          details: [
            "target": mapping.target,
            "services": mapping.services.joined(separator: ","),
            "public_api_routes": mapping.publicAPIRoutes.joined(separator: "\n"),
            "notes": mapping.notes.joined(separator: "\n"),
            "delegated_command": "apple tcc doctor --for-target \(mapping.target)",
          ]
        ))
    }
    return checks
  }

  private func infosHuman(_ infos: [TCCDatabaseInfo]) -> String {
    infos.map { info in
      "\(info.scope.rawValue): \(info.readable ? "readable" : "not-readable") \(info.path) digest=\(info.digest ?? "unavailable")"
    }.joined(separator: "\n")
  }

  private func recordsHuman(
    _ records: [TCCScopedAccessRecord],
    issues: [TCCDatabaseIssue] = []
  ) -> String {
    var lines: [String] = []
    if records.isEmpty {
      lines.append("No matching TCC records.")
    } else {
      lines.append(contentsOf: records.map { item in
      "\(item.scope.rawValue): \(item.record.service) \(item.record.client) \(item.record.authValueDescription ?? item.record.allowed.map { $0 == 0 ? "denied" : "allowed" } ?? "unknown") \(item.record.rowHash)"
      })
    }
    lines.append(
      contentsOf: issues.map {
        "issue \($0.scope.rawValue): \($0.code.rawValue) \($0.path) \($0.message)"
      })
    return lines.joined(separator: "\n")
  }

  private func identityHuman(_ identity: TCCCodeIdentity) -> String {
    [
      "path: \(identity.path ?? "")",
      "bundle_id: \(identity.bundleIdentifier ?? "")",
      "codesign_id: \(identity.codesignIdentifier ?? "")",
      "team_id: \(identity.teamIdentifier ?? "")",
      "cdhash: \(identity.cdHash ?? "")",
      "signature: \(identity.signatureKind)",
    ].joined(separator: "\n")
  }

  private func accessHuman(_ response: TCCAccessCheckResponse) -> String {
    "\(response.service.rawName): \(response.granted.map { $0 ? "granted" : "not-granted" } ?? "unknown") via \(response.route)"
  }

  private func doctorHuman(_ report: CLIDoctorReport) -> String {
    var lines = ["\(report.target) doctor: \(report.status.rawValue)"]
    lines.append(contentsOf: report.checks.map { "- \($0.name): \($0.status.rawValue) - \($0.message)" })
    return lines.joined(separator: "\n")
  }

  private func requiredOption(_ name: String, options: CLIOptions) throws -> String {
    guard let value = options.targetOption(name), !value.isEmpty else {
      throw CLIError(code: .validationError, message: "`--\(name)` is required.")
    }
    return value
  }

  private func nilCommand(_ options: CLIOptions) throws -> CLICommandResult {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Unsupported TCC command.",
      details: ["command": options.positionals.joined(separator: " ")]
    )
  }
}
