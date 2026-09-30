import Foundation
import Utility

public struct IntelligenceCommand {
  private let backend: IntelligenceBackend
  private let target = "intelligence"

  public init(backend: IntelligenceBackend = IntelligenceBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["intelligence", "support"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let support = backend.support()
      return try result(support, human: renderSupport(support), options: options)

    case ["intelligence", "doctor"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["root", "state-dir"])
      let report = backend.doctor(paths: intelligencePaths(options: options))
      return try result(report, human: renderDoctor(report), options: options)

    case ["intelligence", "verify"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["root", "state-dir"])
      let verify = try backend.verify(paths: intelligencePaths(options: options))
      return try result(verify, human: renderVerify(verify), options: options)

    case ["intelligence", "enable"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["root", "state-dir", "patch-scope", "eligibility-country"],
        allowedFlags: ["create-missing", "skip-lock", "allow-system-cache-write"]
      )
      try requireRiskFlag(
        "allow-system-cache-write",
        options: options,
        operation: "intelligence enable"
      )
      let paths = intelligencePaths(options: options)
      let patchScope = try patchScopeOption(options)
      let eligibilityCountry = try validatedCountryCode(options.targetOption("eligibility-country"))
      let preflightTargets = enablePreflightTargets(
        paths: paths,
        patchScope: patchScope,
        eligibilityCountry: eligibilityCountry
      )
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.enable",
          summary: [
            "root": paths.root,
            "state_dir": paths.stateDir,
            "patch_scope": patchScope.rawValue,
            "eligibility_country": eligibilityCountry ?? "",
            "target_count": "\(preflightTargets.count)",
          ],
          allowFlags: ["--allow-system-cache-write"],
          options: options
        )
      }
      try preflightSystemCacheWrite(
        paths: paths,
        targets: preflightTargets,
        createMissing: boolFlag("create-missing", options: options),
        operation: "intelligence enable"
      )
      let result = try backend.enable(
        paths: paths,
        patchScope: patchScope,
        eligibilityCountry: eligibilityCountry,
        createMissing: boolFlag("create-missing", options: options),
        skipLock: boolFlag("skip-lock", options: options)
      )
      return try operationResult(result, options: options)

    case ["intelligence", "reset-cache"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["root", "state-dir"],
        allowedFlags: ["kickstart", "skip-lock", "allow-cache-reset"]
      )
      try requireRiskFlag(
        "allow-cache-reset",
        options: options,
        operation: "intelligence reset-cache"
      )
      let paths = intelligencePaths(options: options)
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.reset-cache",
          summary: [
            "root": paths.root,
            "state_dir": paths.stateDir,
            "kickstart": "\(boolFlag("kickstart", options: options))",
          ],
          allowFlags: ["--allow-cache-reset"],
          options: options
        )
      }
      try preflightSystemCacheWrite(
        paths: paths,
        targets: [paths.eligibilityPlist, paths.osEligibilityPlist],
        createMissing: false,
        operation: "intelligence reset-cache"
      )
      let result = try backend.resetCache(
        paths: paths,
        kickstart: boolFlag("kickstart", options: options),
        skipLock: boolFlag("skip-lock", options: options)
      )
      return try operationResult(result, options: options)

    case ["intelligence", "rollback"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["root", "state-dir", "state"],
        allowedFlags: ["skip-lock", "allow-system-cache-write"]
      )
      try requireRiskFlag(
        "allow-system-cache-write",
        options: options,
        operation: "intelligence rollback"
      )
      let paths = intelligencePaths(options: options)
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.rollback",
          summary: [
            "root": paths.root,
            "state_dir": paths.stateDir,
            "state": options.targetOption("state") ?? "latest",
          ],
          allowFlags: ["--allow-system-cache-write"],
          options: options
        )
      }
      try preflightSystemCacheWrite(
        paths: paths,
        targets: [],
        createMissing: false,
        operation: "intelligence rollback"
      )
      let result = try backend.rollback(
        paths: paths,
        stateID: options.targetOption("state") ?? "latest",
        skipLock: boolFlag("skip-lock", options: options)
      )
      return try operationResult(result, options: options)

    case ["intelligence", "unlock"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["root", "state-dir"],
        allowedFlags: ["allow-system-cache-write"]
      )
      try requireRiskFlag(
        "allow-system-cache-write",
        options: options,
        operation: "intelligence unlock"
      )
      let paths = intelligencePaths(options: options)
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.unlock",
          summary: [
            "root": paths.root,
            "state_dir": paths.stateDir,
            "target_count": "3",
          ],
          allowFlags: ["--allow-system-cache-write"],
          options: options
        )
      }
      try preflightSystemCacheWrite(
        paths: paths,
        targets: [paths.eligibilityPlist, paths.osEligibilityPlist, paths.countrydPlist],
        createMissing: false,
        operation: "intelligence unlock"
      )
      let result = backend.unlock(paths: paths)
      return try operationResult(result, options: options)

    case ["intelligence", "recompute"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["timeout", "lldb-path"],
        allowedFlags: ["skip-restart", "allow-debug-attach"]
      )
      try requireRiskFlag(
        "allow-debug-attach",
        options: options,
        operation: "intelligence recompute"
      )
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.recompute",
          summary: [
            "timeout": "\(intOption("timeout", options: options, default: 60))",
            "skip_restart": "\(boolFlag("skip-restart", options: options))",
            "lldb_path": options.targetOption("lldb-path") ?? "",
          ],
          allowFlags: ["--allow-debug-attach"],
          options: options
        )
      }
      try preflightDebugAttach(lldbPath: options.targetOption("lldb-path"))
      let result = try backend.recompute(
        timeout: intOption("timeout", options: options, default: 60),
        skipRestart: boolFlag("skip-restart", options: options),
        lldbPath: options.targetOption("lldb-path")
      )
      return try operationResult(result, options: options)

    case ["intelligence", "service", "install"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["root", "state-dir", "timeout", "lldb-path"],
        allowedFlags: ["load", "allow-debug-attach", "allow-persistent-service"]
      )
      try requireRiskFlag(
        "allow-debug-attach",
        options: options,
        operation: "intelligence service install"
      )
      try requireRiskFlag(
        "allow-persistent-service",
        options: options,
        operation: "intelligence service install"
      )
      let paths = intelligencePaths(options: options)
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.service.install",
          summary: [
            "root": paths.root,
            "state_dir": paths.stateDir,
            "service_plist": paths.servicePlist,
            "load": "\(boolFlag("load", options: options))",
          ],
          category: .persistentAction,
          allowFlags: ["--allow-debug-attach", "--allow-persistent-service"],
          options: options
        )
      }
      try preflightDebugAttach(lldbPath: options.targetOption("lldb-path"))
      try preflightSystemCacheWrite(
        paths: paths,
        targets: [paths.servicePlist],
        createMissing: true,
        operation: "intelligence service install"
      )
      let result = try backend.installService(
        paths: paths,
        timeout: intOption("timeout", options: options, default: 60),
        lldbPath: options.targetOption("lldb-path"),
        load: boolFlag("load", options: options)
      )
      return try operationResult(result, options: options)

    case ["intelligence", "service", "uninstall"]:
      try validateTargetOptions(
        options,
        allowedOptions: ["root", "state-dir"],
        allowedFlags: ["unload", "allow-persistent-service"]
      )
      try requireRiskFlag(
        "allow-persistent-service",
        options: options,
        operation: "intelligence service uninstall"
      )
      let paths = intelligencePaths(options: options)
      if options.dryRun {
        return try dryRunResult(
          operation: "intelligence.service.uninstall",
          summary: [
            "root": paths.root,
            "state_dir": paths.stateDir,
            "service_plist": paths.servicePlist,
            "unload": "\(boolFlag("unload", options: options))",
          ],
          category: .persistentAction,
          allowFlags: ["--allow-persistent-service"],
          options: options
        )
      }
      try preflightSystemCacheWrite(
        paths: paths,
        targets: [paths.servicePlist],
        createMissing: false,
        operation: "intelligence service uninstall"
      )
      let result = try backend.uninstallService(
        paths: paths,
        unload: boolFlag("unload", options: options)
      )
      return try operationResult(result, options: options)

    default:
      return nil
    }
  }

  private func operationResult(_ payload: IntelligenceOperationResult, options: CLIOptions) throws
    -> CLICommandResult
  {
    try result(
      payload,
      human: intelligenceOperationCommand(payload.operation, result: payload),
      options: options
    )
  }

  private func dryRunResult(
    operation: String,
    summary: [String: String],
    category: CLISafetyCategory = .riskBoundSystemAction,
    allowFlags: [String],
    options: CLIOptions
  ) throws -> CLICommandResult {
    try result(
      CLISafety.dryRun(
        target: target,
        operation: operation,
        summary: summary,
        scope: operation,
        category: category,
        allowFlags: allowFlags
      ),
      human: "dry-run: \(operation)",
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

  private func renderDoctor(_ report: IntelligenceDoctorReport) -> String {
    [
      "intelligence doctor",
      "eligibility plist: \(report.files["eligibility"]?.exists == true ? "present" : "missing")",
      "os eligibility plist: \(report.files["os_eligibility"]?.exists == true ? "present" : "missing")",
      "countryd plist: \(report.files["countryd"]?.exists == true ? "present" : "missing")",
      "service plist: \(report.service["launchdaemon"]?.exists == true ? "present" : "missing")",
    ].joined(separator: "\n")
  }

  private func renderSupport(_ support: IntelligenceSupportAssessment) -> String {
    var lines = ["intelligence support"]
    if !support.recommendedCommands.isEmpty {
      lines.append("recommended commands:")
      lines.append(contentsOf: support.recommendedCommands.map { "- \($0)" })
    }
    if !support.warnings.isEmpty {
      lines.append("warnings:")
      lines.append(contentsOf: support.warnings.map { "- \($0)" })
    }
    return lines.joined(separator: "\n")
  }

  private func renderVerify(_ result: IntelligenceVerifyResult) -> String {
    result.domains
      .map { "\($0.domain): \($0.value ?? "missing") expected=\($0.expected ?? "")" }
      .joined(separator: "\n")
  }
}

private func enablePreflightTargets(
  paths: IntelligencePaths,
  patchScope: IntelligencePatchScope,
  eligibilityCountry: String?
) -> [String] {
  var targets = Array(
    Set(
      intelligenceRules(patchScope: patchScope).map { rule in
        switch rule.file {
        case .eligibility:
          return paths.eligibilityPlist
        case .osEligibility:
          return paths.osEligibilityPlist
        case .countryd:
          return paths.countrydPlist
        }
      }
    )
  ).sorted()
  if eligibilityCountry != nil {
    targets.append(paths.countrydPlist)
  }
  return targets
}
