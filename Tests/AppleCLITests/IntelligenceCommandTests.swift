import IntelligenceCLI
import Foundation
import Testing
import Utility

@Suite
struct IntelligenceCommandTests {
  @Test func intelligenceEnableAnswerScopeUsesRiskFlagAndPatchesTempRoot() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }

    let command = IntelligenceCommand()
    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--state-dir", root.appendingPathComponent("state").path,
          "--patch-scope", "answer",
          "--skip-lock",
          "--allow-system-cache-write",
          "--json",
        ])))

    let data = try intelligenceData(result.stdout ?? "")
    #expect(data["operation"] as? String == "intelligence.enable")
    #expect(data["changed"] as? Bool == true)
    let state = try #require(data["state"] as? [String: Any])
    #expect(state["manifestPath"] as? String != nil)

    let eligibility = try readPlist(root.appendingPathComponent("private/var/db/eligibilityd/eligibility.plist"))
    let greymatter = try #require(eligibility["OS_ELIGIBILITY_DOMAIN_GREYMATTER"] as? [String: Any])
    let foundation = try #require(eligibility["OS_ELIGIBILITY_DOMAIN_FOUNDATION_MODELS"] as? [String: Any])
    #expect(greymatter["os_eligibility_answer_t"] as? Int == 4)
    #expect(foundation["os_eligibility_answer_t"] as? Int == 4)
    let status = try #require(greymatter["status"] as? [String: Any])
    #expect(status["OS_ELIGIBILITY_INPUT_COUNTRY_BILLING"] as? Int == 3)
    #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("state/latest.json").path))
  }

  @Test func intelligenceEnableDefaultsToComprehensivePatchScope() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }

    let command = IntelligenceCommand()
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--skip-lock",
          "--allow-system-cache-write",
          "--json",
        ])))

    let eligibility = try readPlist(root.appendingPathComponent("private/var/db/eligibilityd/eligibility.plist"))
    let greymatter = try #require(eligibility["OS_ELIGIBILITY_DOMAIN_GREYMATTER"] as? [String: Any])
    let greymatterStatus = try #require(greymatter["status"] as? [String: Any])
    #expect(greymatterStatus["OS_ELIGIBILITY_INPUT_COUNTRY_BILLING"] as? Int == 2)
    #expect(greymatterStatus["OS_ELIGIBILITY_INPUT_DEVICE_REGION_CODE"] as? Int == 2)
    let calcium = try #require(eligibility["OS_ELIGIBILITY_DOMAIN_CALCIUM"] as? [String: Any])
    let calciumStatus = try #require(calcium["status"] as? [String: Any])
    #expect(calciumStatus["OS_ELIGIBILITY_INPUT_DEVICE_REGION_CODE"] as? Int == 2)
  }

  @Test func intelligenceEnableRejectsMissingRiskFlagAndReturnsDryRunPayload() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--skip-lock",
        ]))
      Issue.record("Expected enable without --allow-system-cache-write to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["failure"] == "missing_risk_flag")
      #expect(error.details["required_flag"] == "allow-system-cache-write")
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--dry-run",
          "--json",
        ])))
    let data = try intelligenceData(dryRun.stdout ?? "")
    #expect(data["mode"] as? String == "dry-run")
    #expect(data["operation"] as? String == "intelligence.enable")
    let requirements = try #require(data["requirements"] as? [String: Any])
    #expect(requirements["allowFlags"] as? [String] == ["--allow-system-cache-write"])
  }

  @Test func intelligenceEnableRejectsUnknownOption() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()
    let invalidArguments = [
      [
        "intelligence", "enable",
        "--root", root.path,
        "--unsupported-intelligence-option", "value",
        "--allow-system-cache-write",
      ],
    ]

    for arguments in invalidArguments {
      do {
        _ = try command.run(options: CLIOptionsFixture.parse(arguments))
        Issue.record("Expected unsupported intelligence option to be rejected: \(arguments).")
      } catch let error as CLIError {
        #expect(error.code == .validationError)
        #expect(error.details["failure"] == "unsupported_option")
      }
    }
  }

  @Test func intelligenceReadOnlyCommandsRejectMutationSafetyInputs() throws {
    let command = IntelligenceCommand()
    let invalidReadOnlyArguments = [
      (["intelligence", "support", "--dry-run"], "dry_run_rejected_for_read_only"),
      (["intelligence", "support", "--allow-system-cache-write"], "read_only_risk_flags_rejected"),
    ]

    for (arguments, failure) in invalidReadOnlyArguments {
      do {
        _ = try command.run(options: CLIOptionsFixture.parse(arguments))
        Issue.record("Expected read-only intelligence command to reject \(arguments).")
      } catch let error as CLIError {
        #expect(error.code == .validationError)
        #expect(error.details["failure"] == failure)
      }
    }
  }

  @Test func intelligenceSupportAssessmentFlagsUnprovenOSBoundaries() throws {
    let supported = intelligenceSupportAssessment(macos: "26.4", machine: "arm64")
    #expect(supported.warnings.isEmpty)
    #expect(supported.recommendedCommands.contains("apple intelligence doctor"))

    let twentySixFive = intelligenceSupportAssessment(macos: "26.5", machine: "arm64")
    #expect(twentySixFive.warnings.contains { $0.contains("macOS 26.5") })

    let future = intelligenceSupportAssessment(macos: "27.0", machine: "arm64")
    #expect(future.warnings.contains { $0.contains("newer than 26.x") })

    let unparsable = intelligenceSupportAssessment(macos: "not-a-version", machine: "arm64")
    #expect(unparsable.warnings.contains { $0.contains("could not be parsed") })

    let intel = intelligenceSupportAssessment(macos: "26.4", machine: "x86_64")
    #expect(intel.warnings.contains { $0.contains("Apple silicon") })
  }

  @Test func intelligenceDoesNotExposePlanOrRuntimeDistillCommand() throws {
    let command = IntelligenceCommand()
    if let result = try command.run(options: CLIOptionsFixture.parse(["intelligence", "plan", "--json"])) {
      Issue.record("Expected intelligence plan to stay outside this target: \(result.stdout ?? "")")
    }
    if let result = try command.run(options: CLIOptionsFixture.parse(["intelligence", "distill", "--json"])) {
      Issue.record("Expected intelligence distill to stay outside the runtime CLI surface: \(result.stdout ?? "")")
    }
  }

  @Test func intelligenceVerifyReadsPatchedDomains() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--patch-scope", "answer",
          "--skip-lock",
          "--allow-system-cache-write",
        ])))

    let verify = try #require(
      try command.run(options: CLIOptionsFixture.parse(["intelligence", "verify", "--root", root.path, "--json"])))
    let data = try intelligenceData(verify.stdout ?? "")
    let domains = try #require(data["domains"] as? [[String: Any]])
    let greymatter = try #require(
      domains.first { ($0["domain"] as? String) == "OS_ELIGIBILITY_DOMAIN_GREYMATTER" })
    #expect(greymatter["matchesExpected"] as? Bool == true)
  }

  @Test func intelligenceEnableCanRewriteCountryCache() throws {
    let root = try makeIntelligenceRoot(includeCountry: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()
    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--eligibility-country", "us",
          "--skip-lock",
          "--allow-system-cache-write",
          "--json",
        ])))

    let country = try readPlist(root.appendingPathComponent("private/var/db/com.apple.countryd/countryCodeCache.plist"))
    #expect(try intelligenceCountryArchiveCodes(country) == ["US"])
    #expect(try intelligenceCountryArchiveCodes(country, branch: "LastKnownCombinedEstimate") == ["CN"])
    #expect(try intelligenceCountryArchiveCodes(country, branch: "LocalEstimates") == ["CN"])
    let objects = try #require(country["$objects"] as? [Any])
    #expect(objects[4] as? String == "CN")
    #expect(objects[11] as? String == "JP")
    let unrelated = try #require(objects[21] as? [String: Any])
    #expect(unrelated["CountryCode"] as? String == "GB")
    #expect(unrelated["NonCountryTwoLetter"] as? String == "CA")
    #expect(unrelated["Region"] as? String == "LL/A")
    #expect(unrelated["Language"] as? String == "en")
    let metadata = try #require(country["metadata"] as? [String: Any])
    #expect(metadata["billingCountry"] as? String == "CA")
    #expect(metadata["Other"] as? String == "JP")
    let data = try intelligenceData(result.stdout ?? "")
    let warnings = try #require(data["warnings"] as? [String])
    #expect(warnings.contains { $0.contains("iPhone Mirroring") })
    let actions = try #require(data["actions"] as? [[String: Any]])
    let countryAction = try #require(actions.first { ($0["kind"] as? String) == "countryRewrite" })
    #expect(countryAction["subsystem"] as? String == "countryd")
  }

  @Test func intelligenceResetCacheDeletesKnownPlistsWithRiskFlag() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "reset-cache",
          "--root", root.path,
          "--skip-lock",
          "--allow-cache-reset",
          "--json",
        ])))

    #expect(
      !FileManager.default.fileExists(
        atPath: root.appendingPathComponent("private/var/db/eligibilityd/eligibility.plist").path))
    #expect(
      !FileManager.default.fileExists(
        atPath: root.appendingPathComponent("private/var/db/os_eligibility/eligibility.plist").path))
  }

  @Test func intelligenceRollbackRestoresLatestStateAndRejectsTraversal() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--skip-lock",
          "--allow-system-cache-write",
          "--json",
        ])))

    var eligibility = try readPlist(root.appendingPathComponent("private/var/db/eligibilityd/eligibility.plist"))
    var greymatter = try #require(eligibility["OS_ELIGIBILITY_DOMAIN_GREYMATTER"] as? [String: Any])
    #expect(greymatter["os_eligibility_answer_t"] as? Int == 4)

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "rollback",
          "--root", root.path,
          "--state", "latest",
          "--skip-lock",
          "--allow-system-cache-write",
        ])))
    eligibility = try readPlist(root.appendingPathComponent("private/var/db/eligibilityd/eligibility.plist"))
    greymatter = try #require(eligibility["OS_ELIGIBILITY_DOMAIN_GREYMATTER"] as? [String: Any])
    #expect(greymatter["os_eligibility_answer_t"] as? Int == 1)

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "rollback",
          "--root", root.path,
          "--state", "../state.json",
          "--allow-system-cache-write",
        ]))
      Issue.record("Expected rollback path traversal state to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    }
  }

  @Test func intelligenceServiceInstallWritesLaunchDaemonThatInvokesSwiftCLI() throws {
    let root = try makeIntelligenceRoot()
    defer { try? FileManager.default.removeItem(at: root) }
    let command = IntelligenceCommand()
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "service", "install",
          "--root", root.path,
          "--timeout", "7",
          "--lldb-path", "/bin/echo",
          "--allow-debug-attach",
          "--allow-persistent-service",
          "--json",
        ])))

    let plist = root.appendingPathComponent("Library/LaunchDaemons/io.github.computer-mcp.apple-cli.intelligence.recompute.plist")
    let launchDaemon = try readPlist(plist)
    #expect(launchDaemon["Label"] as? String == "io.github.computer-mcp.apple-cli.intelligence.recompute")
    let args = try #require(launchDaemon["ProgramArguments"] as? [String])
    #expect(args.dropFirst() == [
      "intelligence",
      "recompute",
      "--allow-debug-attach",
      "--timeout",
      "7",
      "--json",
      "--lldb-path",
      "/bin/echo",
    ])
    #expect(args.first?.isEmpty == false)
  }

  @Test func intelligenceRecomputeRequiresDebugFlagAndCanUseExplicitLLDBPath() throws {
    let command = IntelligenceCommand()
    do {
      _ = try command.run(options: CLIOptionsFixture.parse(["intelligence", "recompute", "--timeout", "1"]))
      Issue.record("Expected recompute without --allow-debug-attach to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["failure"] == "missing_risk_flag")
      #expect(error.details["required_flag"] == "allow-debug-attach")
    }

    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "recompute",
          "--timeout", "1",
          "--skip-restart",
          "--lldb-path", "/bin/echo",
          "--allow-debug-attach",
          "--json",
        ])))
    let data = try intelligenceData(result.stdout ?? "")
    #expect(data["operation"] as? String == "intelligence.recompute")
    #expect(data["status"] as? String == "succeeded")
    let actions = try #require(data["actions"] as? [[String: Any]])
    #expect(actions.contains { ($0["kind"] as? String) == "debugPreflight" })
    let refresh = try #require(actions.first { ($0["kind"] as? String) == "debugAttach" })
    #expect(refresh["stdout"] as? String == [
      "--batch", "-o", "process attach --name eligibilityd",
      "-o", "expression (void) [[EligibilityEngine sharedInstance] recomputeAllDomainAnswers]",
      "-o", "process detach", "-o", "quit",
    ].joined(separator: " "))

    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "recompute",
          "--timeout", "1",
          "--lldb-path", "/definitely/not/lldb",
          "--allow-debug-attach",
        ]))
      Issue.record("Expected invalid lldb path to be rejected during preflight.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
      #expect(error.details["failure"] == "lldb_path_not_executable")
    }
  }

  @Test func intelligencePreflightRejectsUnwritableMutationRoot() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("apple-cli-intelligence-readonly-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer {
      try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: root.path)
      try? FileManager.default.removeItem(at: root)
    }
    try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: root.path)

    let command = IntelligenceCommand()
    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "intelligence", "enable",
          "--root", root.path,
          "--create-missing",
          "--skip-lock",
          "--allow-system-cache-write",
        ]))
      Issue.record("Expected unwritable intelligence root to be refused before mutation.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["failure"] == "target_path_parent_not_writable")
    }
  }
}

func makeIntelligenceRoot(includeCountry: Bool = false) throws -> URL {
  let root = FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-intelligence-\(UUID().uuidString)", isDirectory: true)
  try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
  try writePlist(
    [
      "OS_ELIGIBILITY_DOMAIN_GREYMATTER": [
        "os_eligibility_answer_t": 1,
        "status": [
          "OS_ELIGIBILITY_INPUT_COUNTRY_BILLING": 3,
          "OS_ELIGIBILITY_INPUT_DEVICE_AND_SIRI_LANGUAGE_MATCH": 3,
          "OS_ELIGIBILITY_INPUT_DEVICE_REGION_CODE": 3,
          "OS_ELIGIBILITY_INPUT_EXTERNAL_BOOT_DRIVE": 3,
        ],
      ],
      "OS_ELIGIBILITY_DOMAIN_FOUNDATION_MODELS": ["os_eligibility_answer_t": 1],
      "OS_ELIGIBILITY_DOMAIN_CALCIUM": [
        "status": ["OS_ELIGIBILITY_INPUT_DEVICE_REGION_CODE": 3]
      ],
    ],
    to: root.appendingPathComponent("private/var/db/eligibilityd/eligibility.plist")
  )
  try writePlist(
    [
      "OS_ELIGIBILITY_DOMAIN_STRONTIUM": ["os_eligibility_answer_t": 1],
    ],
    to: root.appendingPathComponent("private/var/db/os_eligibility/eligibility.plist")
  )
  if includeCountry {
    try writePlist(
      intelligenceCountryArchiveFixture(),
      to: root.appendingPathComponent("private/var/db/com.apple.countryd/countryCodeCache.plist")
    )
  }
  return root
}

private func writePlist(_ value: [String: Any], to url: URL) throws {
  try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
  let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
  try data.write(to: url)
}

private func readPlist(_ url: URL) throws -> [String: Any] {
  let data = try Data(contentsOf: url)
  return try #require(PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any])
}

private func intelligenceData(_ json: String) throws -> [String: Any] {
  let object = try intelligenceJSONObject(json)
  return try #require(object["data"] as? [String: Any])
}

private func intelligenceJSONObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}
