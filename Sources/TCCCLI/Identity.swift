import AppKit
import Foundation
import Utility

public protocol TCCIdentityReading: Sendable {
  func readSelfIdentity() throws -> TCCCodeIdentity
  func readPathIdentity(_ path: String) throws -> TCCCodeIdentity
  func readBundleIdentity(_ bundleIdentifier: String) throws -> TCCCodeIdentity
}

public struct TCCIdentityReader: TCCIdentityReading {
  public init() {}

  public func readSelfIdentity() throws -> TCCCodeIdentity {
    guard let first = CommandLine.arguments.first, !first.isEmpty else {
      throw CLIError(code: .backendUnavailable, message: "Current executable path is unavailable.")
    }
    return try readPathIdentity(URL(fileURLWithPath: first).standardizedFileURL.path)
  }

  public func readPathIdentity(_ path: String) throws -> TCCCodeIdentity {
    let expanded = NSString(string: path).expandingTildeInPath
    guard FileManager.default.fileExists(atPath: expanded) else {
      throw CLIError(
        code: .notFound,
        message: "Identity path does not exist.",
        details: ["path": expanded]
      )
    }

    let bundle = bundleContaining(path: expanded)
    let bundleIdentifier = bundle?.bundleIdentifier
    let codesign = codesignMetadata(path: expanded)
    let signatureKind = signatureKind(from: codesign)
    return TCCCodeIdentity(
      input: path,
      path: expanded,
      bundleIdentifier: bundleIdentifier,
      codesignIdentifier: codesign["Identifier"],
      cdHash: codesign["CDHash"],
      teamIdentifier: codesign["TeamIdentifier"],
      signatureKind: signatureKind,
      infoPlistBinding: codesign["Info.plist"] ?? infoPlistBinding(for: bundle),
      resolvedBy: "path"
    )
  }

  public func readBundleIdentity(_ bundleIdentifier: String) throws -> TCCCodeIdentity {
    guard !bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw CLIError(code: .validationError, message: "Bundle identifier must not be empty.")
    }
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
      throw CLIError(
        code: .notFound,
        message: "Bundle identifier could not be resolved by Launch Services.",
        details: ["bundle_id": bundleIdentifier]
      )
    }
    var identity = try readPathIdentity(url.path)
    identity.input = bundleIdentifier
    identity.resolvedBy = "bundle_id"
    if identity.bundleIdentifier == nil {
      identity.bundleIdentifier = bundleIdentifier
    }
    return identity
  }

  private func bundleContaining(path: String) -> Bundle? {
    var url = URL(fileURLWithPath: path)
    if url.pathExtension == "app" {
      return Bundle(url: url)
    }
    for _ in 0..<8 {
      if url.pathExtension == "app", let bundle = Bundle(url: url) {
        return bundle
      }
      let parent = url.deletingLastPathComponent()
      if parent.path == url.path {
        break
      }
      url = parent
    }
    return Bundle(url: URL(fileURLWithPath: path))
  }

  private func codesignMetadata(path: String) -> [String: String] {
    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(
        .path("/usr/bin/codesign"),
        arguments: ["-dv", "--verbose=4", path],
        timeoutSeconds: 10,
        outputLimit: 256_000
      )
    } catch {
      return ["Signature": "unavailable"]
    }

    var metadata: [String: String] = [:]
    let lines = (result.stderr + "\n" + result.stdout).split(separator: "\n")
    for line in lines {
      guard let equals = line.firstIndex(of: "=") else {
        continue
      }
      let key = String(line[..<equals]).trimmingCharacters(in: .whitespacesAndNewlines)
      let value = String(line[line.index(after: equals)...]).trimmingCharacters(in: .whitespacesAndNewlines)
      if !key.isEmpty {
        metadata[key] = value
      }
    }
    if metadata.isEmpty, result.exitCode != 0 {
      metadata["Signature"] = "unsigned_or_unreadable"
    }
    return metadata
  }

  private func signatureKind(from metadata: [String: String]) -> String {
    if let authority = metadata["Authority"], !authority.isEmpty {
      if authority.localizedCaseInsensitiveContains("Developer ID") {
        return "developer_id"
      }
      if authority.localizedCaseInsensitiveContains("Apple") {
        return "apple"
      }
      return "certificate"
    }
    if let signature = metadata["Signature"], !signature.isEmpty {
      return signature
    }
    if metadata["TeamIdentifier"] != nil {
      return "signed"
    }
    return "unknown"
  }

  private func infoPlistBinding(for bundle: Bundle?) -> String? {
    guard let bundle else {
      return nil
    }
    let executable = bundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String ?? ""
    let identifier = bundle.bundleIdentifier ?? ""
    if executable.isEmpty, identifier.isEmpty {
      return nil
    }
    return "bundle_id=\(identifier);executable=\(executable)"
  }
}
