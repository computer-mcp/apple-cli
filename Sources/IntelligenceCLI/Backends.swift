import CryptoKit
import Foundation
import Utility

public protocol IntelligenceSystemActionRunning: Sendable {
  func run(
    _ executable: CLISubprocess.Executable,
    arguments: [String],
    timeout: Int,
    kind: String,
    path: String?,
    mechanism: IntelligenceMechanism
  ) -> IntelligenceActionResult
}

public struct IntelligenceSubprocessRunner: IntelligenceSystemActionRunning {
  public init() {}

  public func run(
    _ executable: CLISubprocess.Executable,
    arguments: [String],
    timeout: Int,
    kind: String,
    path: String?,
    mechanism: IntelligenceMechanism
  ) -> IntelligenceActionResult {
    let command = ([executableDescription(executable)] + arguments).joined(separator: " ")
    do {
      let result = try CLISubprocess.run(executable, arguments: arguments, timeoutSeconds: timeout)
      return IntelligenceActionResult(
        kind: kind,
        status: result.exitCode == 0 ? "succeeded" : "failed",
        path: path,
        mechanism: mechanism.rawValue,
        exitCode: result.exitCode,
        stdout: trimmed(result.stdout),
        stderr: trimmed(result.stderr),
        detail: command
      )
    } catch {
      let failure = (error as? CLIError)?.message ?? "The subprocess failed unexpectedly."
      return IntelligenceActionResult(
        kind: kind,
        status: "failed",
        path: path,
        mechanism: mechanism.rawValue,
        exitCode: nil,
        stdout: nil,
        stderr: nil,
        detail: "\(command): \(failure)"
      )
    }
  }
}

public struct IntelligenceBackend {
  private let fileManager: FileManager
  private let systemRunner: any IntelligenceSystemActionRunning
  private let cacheWriter: any IntelligenceCacheFileWriting

  public init(
    fileManager: FileManager = .default,
    systemRunner: any IntelligenceSystemActionRunning = IntelligenceSubprocessRunner()
  ) {
    self.fileManager = fileManager
    self.systemRunner = systemRunner
    self.cacheWriter = IntelligenceAtomicCacheWriter()
  }

  init(
    fileManager: FileManager = .default,
    systemRunner: any IntelligenceSystemActionRunning = IntelligenceSubprocessRunner(),
    cacheWriter: any IntelligenceCacheFileWriting
  ) {
    self.fileManager = fileManager
    self.systemRunner = systemRunner
    self.cacheWriter = cacheWriter
  }

  public func support() -> IntelligenceSupportAssessment {
    let facts = hostFacts()
    return intelligenceSupportAssessment(macos: facts.macos, machine: facts.machine)
  }

  public func doctor(paths: IntelligencePaths) -> IntelligenceDoctorReport {
    let facts = hostFacts()
    return IntelligenceDoctorReport(
      host: facts,
      support: intelligenceSupportAssessment(macos: facts.macos, machine: facts.machine),
      files: [
        "eligibility": fileStatus(paths.eligibilityPlist),
        "os_eligibility": fileStatus(paths.osEligibilityPlist),
        "countryd": fileStatus(paths.countrydPlist),
      ],
      stateDir: paths.stateDir,
      service: [
        "launchdaemon": fileStatus(paths.servicePlist),
      ]
    )
  }

  public func verify(paths: IntelligencePaths) throws -> IntelligenceVerifyResult {
    let rules = intelligenceRules(patchScope: .comprehensive)
    let domains = rules.map { rule -> IntelligenceDomainStatus in
      let target = targetPath(for: rule.file, paths: paths)
      do {
        let plist = try loadPlist(target)
        let lookup = nestedValue(plist, keyPath: rule.keyPath)
        let value = lookup.value.map(stringify)
        return IntelligenceDomainStatus(
          domain: rule.domain.rawValue,
          file: target,
          key: rule.keyPath.joined(separator: ":"),
          found: lookup.found,
          value: value,
          expected: "\(rule.value)",
          matchesExpected: value == "\(rule.value)"
        )
      } catch {
        return IntelligenceDomainStatus(
          domain: rule.domain.rawValue,
          file: target,
          key: rule.keyPath.joined(separator: ":"),
          found: false,
          value: nil,
          expected: "\(rule.value)",
          matchesExpected: nil
        )
      }
    }
    let warnings =
      domains.contains { $0.matchesExpected != true }
      ? ["One or more known eligibility cache values are missing or not at the expected value."]
      : []
    return IntelligenceVerifyResult(domains: domains, warnings: warnings)
  }

  public func enable(
    paths: IntelligencePaths,
    patchScope: IntelligencePatchScope,
    eligibilityCountry: String?,
    createMissing: Bool,
    skipLock: Bool
  ) throws -> IntelligenceOperationResult {
    let rules = intelligenceRules(patchScope: patchScope)
    let preparation = try prepareEnable(
      paths: paths, rules: rules, country: eligibilityCountry, createMissing: createMissing)
    let writes = preparation.writes
    for write in writes { try write.requireOriginal() }
    let targets = writes.map(\.path)
    let snapshots = Dictionary(uniqueKeysWithValues: writes.compactMap { write in
      write.originalData.map { (write.path, $0) }
    })
    let state = try createBackupState(
      paths: paths, targets: Array(snapshots.keys),
      metadata: [
        "operation": "intelligence.enable", "patch_scope": patchScope.rawValue,
        "eligibility_country": eligibilityCountry ?? "",
      ], snapshots: snapshots)
    for write in writes { try write.requireOriginal() }

    var actions = state.actions + preparation.skippedActions
    let unlock = lockActions(targets, unlock: true, skipLock: skipLock)
    actions.append(contentsOf: unlock)
    var warnings: [String] = eligibilityCountry == nil ? [] : [
      "Changing the eligibility country cache may affect iPhone Mirroring expectations; pair iPhone Mirroring before changing the eligibility country when that workflow matters."
    ]
    var attempted: [IntelligencePreparedCacheWrite] = []
    var activePath: String?
    do {
      guard !unlock.contains(where: { $0.status == "failed" }) else {
        throw CLIError(code: .unsafeMutationRefused, message: "Eligibility cache unlock failed.")
      }
      for write in writes {
        activePath = write.path
        try write.requireOriginal()
        if write.updatedData != write.originalData {
          try fileManager.createDirectory(
            at: URL(fileURLWithPath: write.path).deletingLastPathComponent(),
            withIntermediateDirectories: true)
          attempted.append(write)
          try cacheWriter.write(write.updatedData, to: URL(fileURLWithPath: write.path))
        }
        try write.verifyReadback(Data(contentsOf: URL(fileURLWithPath: write.path)))
        actions.append(contentsOf: write.actions)
      }
      // Confirm the group again: a daemon can replace an earlier file during a later write.
      for write in writes {
        activePath = write.path
        try write.verifyReadback(Data(contentsOf: URL(fileURLWithPath: write.path)))
      }
    } catch {
      actions.append(IntelligenceActionResult(
        kind: "cacheWrite", status: "failed", path: activePath,
        mechanism: IntelligenceMechanism.directPlistPatch.rawValue,
        detail: (error as? CLIError)?.message ?? "Cache write or readback failed."))
      for write in attempted.reversed() {
        do {
          if try write.matchesOriginal() { continue }
          // Only restore bytes still attributable to this operation; preserve a concurrent writer.
          guard try Data(contentsOf: URL(fileURLWithPath: write.path)) == write.updatedData else {
            actions.append(IntelligenceActionResult(
              kind: "rollbackRestore", status: "unconfirmed", path: write.path,
              mechanism: IntelligenceMechanism.rollbackRestore.rawValue,
              detail: "Current bytes differ from this operation's write; automatic restore was refused."))
            warnings.append("A cache changed concurrently; inspect the backup before manual rollback.")
            continue
          }
          if let original = write.originalData {
            try cacheWriter.write(original, to: URL(fileURLWithPath: write.path))
          } else {
            try fileManager.removeItem(atPath: write.path)
          }
          guard try write.matchesOriginal() else {
            throw CLIError(code: .backendUnavailable, message: "Cache rollback readback failed.")
          }
          actions.append(IntelligenceActionResult(
            kind: "rollbackRestore", status: "restored", path: write.path,
            mechanism: IntelligenceMechanism.rollbackRestore.rawValue))
        } catch {
          actions.append(IntelligenceActionResult(
            kind: "rollbackRestore", status: "failed", path: write.path,
            mechanism: IntelligenceMechanism.rollbackRestore.rawValue,
            detail: "Automatic restore could not be confirmed; inspect the saved backup."))
        }
      }
      actions.append(contentsOf: lockActions(targets, unlock: false, skipLock: skipLock))
      let remainingChanges = attempted.contains { (try? $0.matchesOriginal()) != true }
      return operationResult(
        operation: "intelligence.enable", actions: actions, state: state.state,
        warnings: warnings, changed: remainingChanges)
    }
    actions.append(contentsOf: lockActions(targets, unlock: false, skipLock: skipLock))
    return operationResult(
      operation: "intelligence.enable", actions: actions, state: state.state,
      warnings: warnings, changed: writes.contains { $0.originalData != $0.updatedData })
  }

  public func resetCache(paths: IntelligencePaths, kickstart: Bool, skipLock: Bool) throws
    -> IntelligenceOperationResult
  {
    let targets = [paths.eligibilityPlist, paths.osEligibilityPlist]
    let state = try createBackupState(
      paths: paths,
      targets: targets.filter { fileManager.fileExists(atPath: $0) },
      metadata: ["operation": "intelligence.reset-cache", "kickstart": "\(kickstart)"]
    )
    var actions = state.actions
    actions.append(contentsOf: lockActions(targets, unlock: true, skipLock: skipLock))
    for target in targets {
      if fileManager.fileExists(atPath: target) {
        try fileManager.removeItem(atPath: target)
        actions.append(
          IntelligenceActionResult(
            kind: "cacheDelete",
            status: "removed",
            path: target,
            mechanism: IntelligenceMechanism.cacheReset.rawValue
          ))
      } else {
        actions.append(
          IntelligenceActionResult(
            kind: "cacheDelete",
            status: "missing",
            path: target,
            mechanism: IntelligenceMechanism.cacheReset.rawValue
          ))
      }
    }
    if kickstart {
      guard paths.root == "/" else {
        throw intelligenceError(
          code: .unsafeMutationRefused,
          failure: .systemRootOnlyFlag,
          details: ["flag": "kickstart", "root": paths.root]
        )
      }
      actions.append(
        systemRunner.run(
          .path("/bin/launchctl"),
          arguments: ["kickstart", "-k", "system/com.apple.eligibilityd"],
          timeout: 10,
          kind: "kickstart",
          path: "system/com.apple.eligibilityd",
          mechanism: .cacheReset
        ))
    }
    return operationResult(operation: "intelligence.reset-cache", actions: actions, state: state.state)
  }

  public func unlock(paths: IntelligencePaths) -> IntelligenceOperationResult {
    let targets = [paths.eligibilityPlist, paths.osEligibilityPlist, paths.countrydPlist]
    let actions = lockActions(targets, unlock: true, skipLock: false)
    return operationResult(operation: "intelligence.unlock", actions: actions, state: nil, rollback: nil)
  }

  public func rollback(paths: IntelligencePaths, stateID: String, skipLock: Bool) throws
    -> IntelligenceOperationResult
  {
    let selected = try selectedStateManifest(paths: paths, stateID: stateID)
    let data = try Data(contentsOf: URL(fileURLWithPath: selected.manifestPath))
    let manifest = try JSONDecoder().decode(IntelligenceStateManifest.self, from: data)
    try validateManifestConfinement(manifest, manifestPath: selected.manifestPath, paths: paths)

    let restoreData = try manifest.backups.map { row in
      let data = try Data(contentsOf: URL(fileURLWithPath: row.backup))
      let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
      guard digest == row.sha256 else {
        throw intelligenceError(
          code: .unsafeMutationRefused, failure: .backupDigestMismatch, details: ["path": row.backup])
      }
      return (row, data)
    }

    let targets = manifest.backups.map(\.target)
    var actions = lockActions(targets, unlock: true, skipLock: skipLock)
    guard !actions.contains(where: { $0.status == "failed" }) else {
      throw CLIError(code: .unsafeMutationRefused, message: "Eligibility cache unlock failed.")
    }
    for (row, data) in restoreData {
      try fileManager.createDirectory(
        at: URL(fileURLWithPath: row.target).deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try cacheWriter.write(data, to: URL(fileURLWithPath: row.target))
      guard try Data(contentsOf: URL(fileURLWithPath: row.target)) == data else {
        throw intelligenceError(
          code: .backendUnavailable, failure: .cacheVerificationFailed, details: ["path": row.target])
      }
      actions.append(
        IntelligenceActionResult(
          kind: "rollbackRestore",
          status: "restored",
          path: row.target,
          current: row.backup,
          mechanism: IntelligenceMechanism.rollbackRestore.rawValue
        ))
    }
    actions.append(contentsOf: lockActions(targets, unlock: false, skipLock: skipLock))
    let state = IntelligenceOperationState(
      id: manifest.id,
      manifestPath: selected.manifestPath,
      backupCount: manifest.backups.count
    )
    return operationResult(operation: "intelligence.rollback", actions: actions, state: state, rollback: nil)
  }

  public func recompute(timeout: Int, skipRestart: Bool, lldbPath: String?) throws
    -> IntelligenceOperationResult
  {
    var actions: [IntelligenceActionResult] = []
    if !skipRestart {
      actions.append(
        systemRunner.run(
          .path("/bin/launchctl"),
          arguments: ["kickstart", "-k", "system/com.apple.eligibilityd"],
          timeout: 10,
          kind: "kickstart",
          path: "system/com.apple.eligibilityd",
          mechanism: .debugRecompute
        ))
    }

    actions.append(eligibilitydPreflightAction())

    let lldb = try resolvedLLDB(lldbPath)
    actions.append(
      systemRunner.run(
        .path(lldb),
        arguments: [
          "--batch",
          "-o", "process attach --name eligibilityd",
          "-o", "expression (void) [[EligibilityEngine sharedInstance] recomputeAllDomainAnswers]",
          "-o", "process detach",
          "-o", "quit",
        ],
        timeout: timeout,
        kind: "debugAttach",
        path: lldb,
        mechanism: .debugRecompute
      ))
    return operationResult(operation: "intelligence.recompute", actions: actions, state: nil, rollback: nil)
  }

  public func installService(paths: IntelligencePaths, timeout: Int, lldbPath: String?, load: Bool) throws
    -> IntelligenceOperationResult
  {
    if let lldbPath {
      _ = try resolvedLLDB(lldbPath)
    }
    let targets = [paths.servicePlist].filter { fileManager.fileExists(atPath: $0) }
    let state = try createBackupState(
      paths: paths,
      targets: targets,
      metadata: [
        "operation": "intelligence.service.install",
        "timeout": "\(timeout)",
        "lldb_path": lldbPath ?? "",
        "load": "\(load)",
      ]
    )

    var actions = state.actions
    try fileManager.createDirectory(
      at: URL(fileURLWithPath: paths.servicePlist).deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    let plistExists = fileManager.fileExists(atPath: paths.servicePlist)
    try writePlist(
      servicePlistPayload(
        appleExecutablePath: currentAppleExecutablePath(),
        timeout: timeout,
        lldbPath: lldbPath
      ),
      to: paths.servicePlist,
      binary: false
    )
    try fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: paths.servicePlist)
    actions.append(
      IntelligenceActionResult(
        kind: "serviceInstall",
        status: plistExists ? "changed" : "created",
        path: paths.servicePlist,
        mechanism: IntelligenceMechanism.persistentService.rawValue
      ))

    if load {
      guard paths.root == "/" else {
        throw intelligenceError(
          code: .unsafeMutationRefused,
          failure: .systemRootOnlyFlag,
          details: ["flag": "load", "root": paths.root]
        )
      }
      actions.append(
        systemRunner.run(
          .path("/bin/launchctl"),
          arguments: ["load", "-w", paths.servicePlist],
          timeout: 10,
          kind: "serviceLoad",
          path: paths.servicePlist,
          mechanism: .persistentService
        ))
    }
    return operationResult(operation: "intelligence.service.install", actions: actions, state: state.state)
  }

  public func uninstallService(paths: IntelligencePaths, unload: Bool) throws -> IntelligenceOperationResult {
    let targets = [paths.servicePlist].filter { fileManager.fileExists(atPath: $0) }
    let state = try createBackupState(
      paths: paths,
      targets: targets,
      metadata: ["operation": "intelligence.service.uninstall", "unload": "\(unload)"]
    )
    var actions = state.actions
    if unload {
      guard paths.root == "/" else {
        throw intelligenceError(
          code: .unsafeMutationRefused,
          failure: .systemRootOnlyFlag,
          details: ["flag": "unload", "root": paths.root]
        )
      }
      actions.append(
        systemRunner.run(
          .path("/bin/launchctl"),
          arguments: ["unload", "-w", paths.servicePlist],
          timeout: 10,
          kind: "serviceUnload",
          path: paths.servicePlist,
          mechanism: .persistentService
        ))
    }
    if fileManager.fileExists(atPath: paths.servicePlist) {
      try fileManager.removeItem(atPath: paths.servicePlist)
      actions.append(
        IntelligenceActionResult(
          kind: "serviceUninstall",
          status: "removed",
          path: paths.servicePlist,
          mechanism: IntelligenceMechanism.persistentService.rawValue
        ))
    } else {
      actions.append(
        IntelligenceActionResult(
          kind: "serviceUninstall",
          status: "missing",
          path: paths.servicePlist,
          mechanism: IntelligenceMechanism.persistentService.rawValue
        ))
    }
    return operationResult(operation: "intelligence.service.uninstall", actions: actions, state: state.state)
  }

  private func targetPath(for file: IntelligenceCacheFile, paths: IntelligencePaths) -> String {
    switch file {
    case .eligibility:
      return paths.eligibilityPlist
    case .osEligibility:
      return paths.osEligibilityPlist
    case .countryd:
      return paths.countrydPlist
    }
  }

  private func prepareEnable(
    paths: IntelligencePaths, rules: [IntelligencePatchRule], country: String?, createMissing: Bool
  ) throws -> (writes: [IntelligencePreparedCacheWrite], skippedActions: [IntelligenceActionResult]) {
    var countryWrite: IntelligencePreparedCacheWrite?
    if let country {
      guard fileManager.fileExists(atPath: paths.countrydPlist) else {
        throw intelligenceError(
          code: .unsafeMutationRefused, failure: .countryCacheMissing,
          details: ["path": paths.countrydPlist])
      }
      let data = try Data(contentsOf: URL(fileURLWithPath: paths.countrydPlist))
      let rewrite = try IntelligenceCountryCacheRewrite(data: data, country: country)
      countryWrite = IntelligencePreparedCacheWrite(
        path: paths.countrydPlist, originalData: data, updatedData: rewrite.updatedData,
        actions: [IntelligenceActionResult(
          kind: "countryRewrite", status: rewrite.changedEstimateCount > 0 ? "changed" : "unchanged",
          path: paths.countrydPlist, current: country,
          mechanism: IntelligenceMechanism.countryCacheRewrite.rawValue,
          detail: "changed_estimates=\(rewrite.changedEstimateCount); verification=verified",
          subsystem: "countryd")], countryRewrite: rewrite)
    }
    var writes: [IntelligencePreparedCacheWrite] = []
    var skipped: [IntelligenceActionResult] = []
    let grouped = Dictionary(grouping: rules, by: { targetPath(for: $0.file, paths: paths) })
    for (path, patchRules) in grouped.sorted(by: { $0.key < $1.key }) {
      let exists = fileManager.fileExists(atPath: path)
      if !exists && !createMissing {
        skipped += patchRules.map {
          IntelligenceActionResult(
            kind: "plistPatch", status: "missing", path: path, domain: $0.domain.rawValue,
            key: $0.keyPath.joined(separator: ":"), current: "\($0.value)", mechanism: $0.mechanism.rawValue)
        }
        continue
      }
      let original = exists ? try Data(contentsOf: URL(fileURLWithPath: path)) : nil
      let plist: NSMutableDictionary
      if let original {
        guard let dictionary = try PropertyListSerialization.propertyList(
          from: original, options: [], format: nil) as? [String: Any]
        else {
          throw intelligenceError(
            code: .validationError, failure: .plistRootNotDictionary, details: ["path": path])
        }
        plist = NSMutableDictionary(dictionary: dictionary)
      } else { plist = NSMutableDictionary() }
      var actions: [IntelligenceActionResult] = exists ? [] : [IntelligenceActionResult(
        kind: "plistCreate", status: "created", path: path,
        mechanism: IntelligenceMechanism.directPlistPatch.rawValue)]
      for rule in patchRules {
        actions.append(setNested(
          plist, keyPath: rule.keyPath, value: rule.value, createMissing: createMissing,
          path: path, domain: rule.domain.rawValue, mechanism: rule.mechanism))
      }
      let data: Data
      if let original, !actions.contains(where: { $0.status == "changed" }) { data = original }
      else { data = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0) }
      writes.append(IntelligencePreparedCacheWrite(
        path: path, originalData: original, updatedData: data, actions: actions, countryRewrite: nil))
    }
    if let countryWrite { writes.append(countryWrite) }
    return (writes, skipped)
  }

  private func createBackupState(
    paths: IntelligencePaths,
    targets: [String],
    metadata: [String: String],
    snapshots: [String: Data]? = nil
  ) throws -> (state: IntelligenceOperationState?, actions: [IntelligenceActionResult]) {
    let stateID = backupID()
    let backupDir = URL(fileURLWithPath: paths.stateDir)
      .appendingPathComponent("backups")
      .appendingPathComponent(stateID)
    try fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)

    var entries: [IntelligenceBackupEntry] = []
    var actions: [IntelligenceActionResult] = []
    for target in targets.sorted() {
      guard fileManager.fileExists(atPath: target) else { continue }
      let relative = relativePath(target, root: paths.root)
      let destination = backupDir.appendingPathComponent(relative)
      try fileManager.createDirectory(
        at: destination.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      if fileManager.fileExists(atPath: destination.path) {
        try fileManager.removeItem(at: destination)
      }
      if let snapshot = snapshots?[target] {
        try snapshot.write(to: destination, options: .atomic)
      } else {
        try fileManager.copyItem(atPath: target, toPath: destination.path)
      }
      let digest = try sha256Hex(path: destination.path)
      entries.append(IntelligenceBackupEntry(target: target, backup: destination.path, sha256: digest))
      actions.append(
        IntelligenceActionResult(
          kind: "backupCreate",
          status: "created",
          path: destination.path,
          previous: target,
          current: digest,
          mechanism: IntelligenceMechanism.backupState.rawValue
        ))
    }

    let manifest = IntelligenceStateManifest(
      id: stateID,
      createdAt: isoTimestamp(),
      root: paths.root,
      metadata: metadata,
      backups: entries
    )
    let manifestPath = backupDir.appendingPathComponent("state.json").path
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(manifest).write(to: URL(fileURLWithPath: manifestPath))
    let latest = LatestState(id: stateID, manifestPath: manifestPath)
    try fileManager.createDirectory(at: URL(fileURLWithPath: paths.stateDir), withIntermediateDirectories: true)
    try encoder.encode(latest).write(
      to: URL(fileURLWithPath: paths.stateDir).appendingPathComponent("latest.json")
    )

    return (
      IntelligenceOperationState(id: stateID, manifestPath: manifestPath, backupCount: entries.count),
      actions
    )
  }

  private func selectedStateManifest(paths: IntelligencePaths, stateID: String) throws
    -> (id: String, manifestPath: String)
  {
    let stateRoot = URL(fileURLWithPath: paths.stateDir).standardizedFileURL.path
    if stateID == "latest" {
      let latestPath = URL(fileURLWithPath: stateRoot).appendingPathComponent("latest.json").path
      let latest = try JSONDecoder().decode(
        LatestState.self,
        from: Data(contentsOf: URL(fileURLWithPath: latestPath))
      )
      let manifestPath = URL(fileURLWithPath: latest.manifestPath).standardizedFileURL.path
      guard isPath(manifestPath, inside: stateRoot) else {
        throw intelligenceError(
          code: .unsafeMutationRefused,
          failure: .latestStateEscapesStateDir,
          details: ["manifest_path": manifestPath, "state_dir": stateRoot]
        )
      }
      return (latest.id, manifestPath)
    }

    guard isValidStateID(stateID) else {
      throw intelligenceError(
        code: .validationError,
        failure: .invalidStateID,
        details: ["state": stateID]
      )
    }
    let manifestPath = URL(fileURLWithPath: stateRoot)
      .appendingPathComponent("backups")
      .appendingPathComponent(stateID)
      .appendingPathComponent("state.json")
      .standardizedFileURL
      .path
    guard isPath(manifestPath, inside: stateRoot) else {
      throw intelligenceError(
        code: .unsafeMutationRefused,
        failure: .stateEscapesStateDir,
        details: ["manifest_path": manifestPath, "state_dir": stateRoot]
      )
    }
    return (stateID, manifestPath)
  }

  private func validateManifestConfinement(
    _ manifest: IntelligenceStateManifest,
    manifestPath: String,
    paths: IntelligencePaths
  ) throws {
    let stateRoot = URL(fileURLWithPath: paths.stateDir).standardizedFileURL.path
    guard manifest.root == paths.root else {
      throw intelligenceError(
        code: .unsafeMutationRefused,
        failure: .stateRootMismatch,
        details: ["state_root": manifest.root, "requested_root": paths.root]
      )
    }
    guard isPath(manifestPath, inside: stateRoot) else {
      throw intelligenceError(
        code: .unsafeMutationRefused,
        failure: .manifestEscapesStateDir,
        details: ["manifest_path": manifestPath, "state_dir": stateRoot]
      )
    }
    for row in manifest.backups {
      guard isPath(row.target, inside: paths.root) else {
        throw intelligenceError(
          code: .unsafeMutationRefused,
          failure: .rollbackTargetEscapesRoot,
          details: ["target": row.target]
        )
      }
      guard isPath(row.backup, inside: stateRoot) else {
        throw intelligenceError(
          code: .unsafeMutationRefused,
          failure: .rollbackBackupEscapesStateDir,
          details: ["backup": row.backup]
        )
      }
    }
  }

  private func lockActions(_ targets: [String], unlock: Bool, skipLock: Bool) -> [IntelligenceActionResult] {
    if skipLock {
      return targets.map {
        IntelligenceActionResult(
          kind: unlock ? "unlock" : "lock",
          status: "skipped",
          path: $0,
          mechanism: IntelligenceMechanism.directPlistPatch.rawValue
        )
      }
    }
    return targets.flatMap { target -> [IntelligenceActionResult] in
      guard fileManager.fileExists(atPath: target) else { return [] }
      if unlock {
        return [
          systemRunner.run(
            .path("/bin/chmod"),
            arguments: ["u+w", target],
            timeout: 10,
            kind: "unlock",
            path: target,
            mechanism: .directPlistPatch
          ),
          systemRunner.run(
            .path("/usr/bin/chflags"),
            arguments: ["nouchg", target],
            timeout: 10,
            kind: "unlock",
            path: target,
            mechanism: .directPlistPatch
          ),
        ]
      }
      return [
        systemRunner.run(
          .path("/bin/chmod"),
          arguments: ["444", target],
          timeout: 10,
          kind: "lock",
          path: target,
          mechanism: .directPlistPatch
        ),
        systemRunner.run(
          .path("/usr/bin/chflags"),
          arguments: ["uchg", target],
          timeout: 10,
          kind: "lock",
          path: target,
          mechanism: .directPlistPatch
        ),
      ]
    }
  }

  private func hostFacts() -> IntelligenceHostFacts {
    return IntelligenceHostFacts(
      macos: readCommand(.path("/usr/bin/sw_vers"), ["-productVersion"]),
      macosBuild: readCommand(.path("/usr/bin/sw_vers"), ["-buildVersion"]),
      machine: readCommand(.path("/usr/bin/uname"), ["-m"]) ?? "unknown",
      sip: readCommand(.path("/usr/bin/csrutil"), ["status"]),
      bootArgs: readCommand(.path("/usr/sbin/nvram"), ["boot-args"]),
      lldbPath: try? resolvedLLDB(nil)
    )
  }

  private func fileStatus(_ path: String) -> IntelligenceFileStatus {
    let exists = fileManager.fileExists(atPath: path)
    guard exists else {
      return IntelligenceFileStatus(path: path, exists: false, readablePlist: false, readError: nil)
    }
    do {
      _ = try loadPlist(path)
      return IntelligenceFileStatus(path: path, exists: true, readablePlist: true, readError: nil)
    } catch {
      return IntelligenceFileStatus(
        path: path,
        exists: true,
        readablePlist: false,
        readError: (error as? CLIError)?.message ?? "Could not read the property list."
      )
    }
  }

  private func operationResult(
    operation: String,
    actions: [IntelligenceActionResult],
    state: IntelligenceOperationState?,
    rollback: IntelligenceRollbackHint? = nil,
    warnings: [String] = [],
    changed changedOverride: Bool? = nil
  ) -> IntelligenceOperationResult {
    let status: IntelligenceOperationStatus
    if actions.contains(where: { $0.status == "failed" }) {
      status = .failed
    } else if actions.contains(where: { ["missing", "skipped"].contains($0.status) }) {
      status = .partial
    } else {
      status = .succeeded
    }
    let changedStatuses = Set(["changed", "created", "removed", "restored", "copied"])
    let changed = changedOverride ?? actions.contains { $0.kind != "backupCreate" && changedStatuses.contains($0.status) }
    let rollbackHint =
      rollback
      ?? state.map {
        IntelligenceRollbackHint(
          state: $0.id,
          command: "apple intelligence rollback --state \($0.id) --allow-system-cache-write"
        )
      }
    return IntelligenceOperationResult(
      operation: operation,
      status: status,
      changed: changed,
      actions: actions,
      state: state,
      rollback: rollbackHint,
      warnings: warnings
    )
  }
}

public func intelligenceSupportAssessment(macos: String?, machine: String) -> IntelligenceSupportAssessment {
  var warnings: [String] = []
  let commands = [
    "apple intelligence doctor",
    "apple intelligence verify",
    "apple intelligence enable --patch-scope comprehensive --allow-system-cache-write",
  ]
  if machine != "arm64" {
    warnings.append("Current Apple Intelligence local-cache workflows are expected to be useful only on Apple silicon hosts.")
  }
  if let version = parseVersion(macos) {
    if version.major == 26, version.minor >= 5 {
      warnings.append(
        "macOS 26.5 and newer 26.x releases are not proven by this product's inspected eligibility evidence; treat system cache writes as high-risk research."
      )
    } else if version.major > 26 {
      warnings.append(
        "macOS versions newer than 26.x are not covered by this product's inspected eligibility evidence; do not apply without fresh research."
      )
    }
  } else {
    warnings.append("macOS version could not be parsed.")
  }
  return IntelligenceSupportAssessment(
    recommendedCommands: commands,
    warnings: warnings
  )
}

private func eligibilitydPreflightAction() -> IntelligenceActionResult {
  let pid = readCommand(.path("/usr/bin/pgrep"), ["eligibilityd"])
  return IntelligenceActionResult(
    kind: "debugPreflight",
    status: pid == nil ? "unavailable" : "available",
    path: "eligibilityd",
    mechanism: IntelligenceMechanism.debugRecompute.rawValue,
    detail: pid.map { "pid=\($0)" } ?? "eligibilityd process was not visible before debug attach"
  )
}

private struct LatestState: Codable {
  var id: String
  var manifestPath: String
}

private func parseVersion(_ string: String?) -> (major: Int, minor: Int, patch: Int)? {
  guard let string else { return nil }
  let parts = string.split(separator: ".").compactMap { Int($0) }
  guard let major = parts.first else { return nil }
  return (major, parts.dropFirst().first ?? 0, parts.dropFirst(2).first ?? 0)
}

private func readCommand(_ executable: CLISubprocess.Executable, _ arguments: [String]) -> String? {
  guard let result = try? CLISubprocess.run(executable, arguments: arguments, timeoutSeconds: 3),
    result.exitCode == 0
  else {
    return nil
  }
  return trimmed(result.stdout)
}

private func sha256Hex(path: String) throws -> String {
  let data = try Data(contentsOf: URL(fileURLWithPath: path))
  return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private func loadPlist(_ path: String) throws -> Any {
  let data = try Data(contentsOf: URL(fileURLWithPath: path))
  return try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
}

private func writePlist(_ plist: Any, to path: String, binary: Bool) throws {
  let format: PropertyListSerialization.PropertyListFormat = binary ? .binary : .xml
  let data = try PropertyListSerialization.data(fromPropertyList: plist, format: format, options: 0)
  try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

private func nestedValue(_ plist: Any, keyPath: [String]) -> (found: Bool, value: Any?) {
  var node: Any? = plist
  for key in keyPath {
    if let dict = node as? [String: Any] {
      node = dict[key]
    } else if let dict = node as? NSDictionary {
      node = dict[key]
    } else {
      return (false, nil)
    }
    if node == nil {
      return (false, nil)
    }
  }
  return (true, node)
}

private func setNested(
  _ root: NSMutableDictionary,
  keyPath: [String],
  value: Int,
  createMissing: Bool,
  path: String,
  domain: String,
  mechanism: IntelligenceMechanism
) -> IntelligenceActionResult {
  var node = root
  for key in keyPath.dropLast() {
    if let child = node[key] as? NSMutableDictionary {
      node = child
    } else if let child = node[key] as? [String: Any] {
      let mutable = NSMutableDictionary(dictionary: child)
      node[key] = mutable
      node = mutable
    } else if let child = node[key] as? NSDictionary {
      let mutable = NSMutableDictionary(dictionary: child)
      node[key] = mutable
      node = mutable
    } else if createMissing {
      let mutable = NSMutableDictionary()
      node[key] = mutable
      node = mutable
    } else {
      return IntelligenceActionResult(
        kind: "plistPatch",
        status: "skipped",
        path: path,
        domain: domain,
        key: keyPath.joined(separator: ":"),
        current: "\(value)",
        mechanism: mechanism.rawValue
      )
    }
  }
  guard let leaf = keyPath.last else {
    return IntelligenceActionResult(kind: "plistPatch", status: "skipped", path: path, mechanism: mechanism.rawValue)
  }
  if node[leaf] == nil && !createMissing {
    return IntelligenceActionResult(
      kind: "plistPatch",
      status: "skipped",
      path: path,
      domain: domain,
      key: keyPath.joined(separator: ":"),
      current: "\(value)",
      mechanism: mechanism.rawValue
    )
  }
  let old = node[leaf].map(stringify)
  node[leaf] = value
  return IntelligenceActionResult(
    kind: "plistPatch",
    status: old == "\(value)" ? "unchanged" : "changed",
    path: path,
    domain: domain,
    key: keyPath.joined(separator: ":"),
    previous: old,
    current: "\(value)",
    mechanism: mechanism.rawValue
  )
}

private func stringify(_ value: Any) -> String {
  if let value = value as? String { return value }
  if let value = value as? NSNumber { return value.stringValue }
  return String(describing: value)
}

private func backupID() -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyyMMdd-HHmmss"
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  return "\(formatter.string(from: Date()))-\(UUID().uuidString.prefix(8))"
}

private func isoTimestamp() -> String {
  ISO8601DateFormatter().string(from: Date())
}

private func relativePath(_ path: String, root: String) -> String {
  if root != "/", path.hasPrefix(root + "/") {
    return String(path.dropFirst(root.count + 1))
  }
  return path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
}

private func resolvedLLDB(_ explicit: String?) throws -> String {
  if let explicit, !explicit.isEmpty {
    let normalized = URL(fileURLWithPath: explicit).standardizedFileURL.path
    guard FileManager.default.fileExists(atPath: normalized), FileManager.default.isExecutableFile(atPath: normalized) else {
      throw intelligenceError(
        code: .notFound,
        failure: .lldbPathNotExecutable,
        details: ["lldb_path": normalized]
      )
    }
    return normalized
  }
  if let xcrun = readCommand(.path("/usr/bin/xcrun"), ["--find", "lldb"]), !xcrun.isEmpty {
    return xcrun
  }
  if let which = readCommand(.path("/usr/bin/which"), ["lldb"]), !which.isEmpty {
    return which
  }
  throw intelligenceError(code: .notFound, failure: .lldbNotFound)
}

private func servicePlistPayload(
  appleExecutablePath: String,
  timeout: Int,
  lldbPath: String?
) -> [String: Any] {
  var arguments = [
    appleExecutablePath,
    "intelligence",
    "recompute",
    "--allow-debug-attach",
    "--timeout",
    "\(timeout)",
    "--json",
  ]
  if let lldbPath, !lldbPath.isEmpty {
    arguments.append(contentsOf: ["--lldb-path", lldbPath])
  }
  return [
    "Label": IntelligencePaths.serviceLabel,
    "ProgramArguments": arguments,
    "RunAtLoad": true,
    "KeepAlive": false,
  ]
}

private func isPath(_ path: String, inside root: String) -> Bool {
  let normalizedPath = URL(fileURLWithPath: path).standardizedFileURL.path
  let normalizedRoot = URL(fileURLWithPath: root).standardizedFileURL.path
  if normalizedRoot == "/" {
    return normalizedPath.hasPrefix("/")
  }
  return normalizedPath == normalizedRoot || normalizedPath.hasPrefix(normalizedRoot + "/")
}

private func isValidStateID(_ stateID: String) -> Bool {
  guard !stateID.isEmpty else { return false }
  let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
  return stateID.rangeOfCharacter(from: allowed.inverted) == nil
    && !stateID.contains("..")
    && !stateID.contains("/")
}

private func executableDescription(_ executable: CLISubprocess.Executable) -> String {
  switch executable {
  case .name(let name): return name
  case .path(let path): return path
  }
}

private func trimmed(_ value: String) -> String {
  value.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func currentAppleExecutablePath() -> String {
  guard let raw = CommandLine.arguments.first, !raw.isEmpty else {
    return "/usr/local/bin/apple"
  }
  if raw.hasPrefix("/") {
    return URL(fileURLWithPath: raw).standardizedFileURL.path
  }
  if raw.contains("/") {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    return cwd.appendingPathComponent(raw).standardizedFileURL.path
  }
  if let found = readCommand(.path("/usr/bin/which"), [raw]), !found.isEmpty {
    return found
  }
  return "/usr/local/bin/apple"
}

extension IntelligenceActionResult {
  fileprivate func with(domain: String?, key: String?) -> IntelligenceActionResult {
    IntelligenceActionResult(
      kind: kind,
      status: status,
      path: path,
      domain: domain ?? self.domain,
      key: key ?? self.key,
      previous: previous,
      current: current,
      mechanism: mechanism,
      exitCode: exitCode,
      stdout: stdout,
      stderr: stderr,
      detail: detail,
      subsystem: subsystem
    )
  }
}
