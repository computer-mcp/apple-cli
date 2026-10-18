import AppKit
import CoreFoundation
import Darwin
import Foundation
import Utility

public protocol TCCFrameworkManaging: Sendable {
  func probe() -> TCCFrameworkProbe
  func add(service: TCCServiceInfo, bundleIdentifier: String) throws -> TCCOperationResult
  func reset(service: TCCServiceInfo, bundleIdentifier: String) throws -> TCCOperationResult
}

public struct TCCPrivateFrameworkBackend: TCCFrameworkManaging {
  public static let frameworkPath = "/System/Library/PrivateFrameworks/TCC.framework/TCC"

  public init() {}

  public func probe() -> TCCFrameworkProbe {
    let handle = dlopen(Self.frameworkPath, RTLD_LAZY)
    defer {
      if let handle {
        dlclose(handle)
      }
    }

    let symbols = [
      "TCCAccessSetForBundle": handle.flatMap { dlsym($0, "TCCAccessSetForBundle") } != nil,
      "TCCAccessResetForBundle": handle.flatMap { dlsym($0, "TCCAccessResetForBundle") } != nil,
    ]
    var diagnostics: [String] = []
    if handle == nil {
      if let error = dlerror() {
        diagnostics.append(String(cString: error))
      } else {
        diagnostics.append("dlopen failed without dlerror detail.")
      }
    }
    if symbols.values.contains(false) {
      diagnostics.append("Private TCC.framework symbols are not available with this OS/runtime.")
    }

    return TCCFrameworkProbe(
      frameworkPath: Self.frameworkPath,
      available: handle != nil && symbols.values.allSatisfy { $0 },
      symbols: symbols,
      sipStatus: csrutilStatus(),
      amfiStatus: "not_verified_by_cli; private framework writes may be blocked by AMFI",
      entitlementStatus: "not_verified_by_cli; private framework symbols may require private entitlement",
      diagnostics: diagnostics
    )
  }

  public func add(service: TCCServiceInfo, bundleIdentifier: String) throws -> TCCOperationResult {
    try callPrivateBundleFunction(
      symbolName: "TCCAccessSetForBundle",
      operation: "tcc.framework.add",
      service: service,
      bundleIdentifier: bundleIdentifier
    )
  }

  public func reset(service: TCCServiceInfo, bundleIdentifier: String) throws -> TCCOperationResult {
    try callPrivateBundleFunction(
      symbolName: "TCCAccessResetForBundle",
      operation: "tcc.framework.reset",
      service: service,
      bundleIdentifier: bundleIdentifier
    )
  }

  private func callPrivateBundleFunction(
    symbolName: String,
    operation: String,
    service: TCCServiceInfo,
    bundleIdentifier: String
  ) throws -> TCCOperationResult {
    let probe = probe()
    guard probe.available, probe.symbols[symbolName] == true else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.privateFrameworkBackendUnavailable(),
        details: [
          "symbol": symbolName,
          "framework": probe.frameworkPath,
          "diagnostics": probe.diagnostics.joined(separator: "\n"),
        ]
      )
    }
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
      throw CLIError(
        code: .notFound,
        message: "Bundle identifier could not be resolved by Launch Services.",
        details: ["bundle_id": bundleIdentifier]
      )
    }
    guard let bundle = CFBundleCreate(kCFAllocatorDefault, url as CFURL) else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.privateFrameworkBundleCouldNotBeCreated(),
        details: ["bundle_id": bundleIdentifier, "path": url.path]
      )
    }

    guard let handle = dlopen(Self.frameworkPath, RTLD_LAZY) else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.privateFrameworkCouldNotBeOpened(),
        details: ["framework": Self.frameworkPath]
      )
    }
    defer { dlclose(handle) }

    guard let symbol = dlsym(handle, symbolName) else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.privateFrameworkSymbolCouldNotBeResolved(),
        details: ["symbol": symbolName]
      )
    }

    typealias TCCBundleFunction = @convention(c) (CFString, CFBundle) -> Void
    let function = unsafeBitCast(symbol, to: TCCBundleFunction.self)
    function(service.rawName as CFString, bundle)

    return TCCOperationResult(
      operation: operation,
      changed: nil,
      service: service.rawName,
      client: bundleIdentifier,
      affectedRows: 0,
      backend: "TCC.framework",
      attempted: true,
      verification: .unverified
    )
  }

  private func csrutilStatus() -> String {
    do {
      let result = try CLISubprocess.run(
        .path("/usr/bin/csrutil"),
        arguments: ["status"],
        timeoutSeconds: 5,
        outputLimit: 16_000
      )
      return (result.stdout + result.stderr)
        .trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      return "not_verified_by_cli"
    }
  }
}
