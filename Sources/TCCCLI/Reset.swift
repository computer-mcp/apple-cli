import Foundation
import Utility

public protocol TCCResetRunning: Sendable {
  func reset(service: TCCServiceInfo, client: String?) throws -> TCCOperationResult
}

public struct TCCTccutilResetRunner: TCCResetRunning {
  public init() {}

  public func reset(service: TCCServiceInfo, client: String?) throws -> TCCOperationResult {
    var arguments = ["reset", TCCServiceCatalog.rawNameForTccutil(service)]
    if let client, !client.isEmpty {
      arguments.append(client)
    }

    let result = try CLISubprocess.run(
      .path("/usr/bin/tccutil"),
      arguments: arguments,
      timeoutSeconds: 30,
      outputLimit: 128_000
    )
    guard result.exitCode == 0 else {
      throw CLIError(
        code: .backendUnavailable,
        message: TCCWording.tccutilResetFailed(),
        details: [
          "argv": (["/usr/bin/tccutil"] + arguments).joined(separator: "\u{1f}"),
          "exit_code": "\(result.exitCode)",
          "stderr": result.stderr,
        ]
      )
    }

    return TCCOperationResult(
      operation: "tcc.reset",
      changed: true,
      service: service.rawName,
      client: client,
      affectedRows: 0,
      backend: "/usr/bin/tccutil",
    )
  }
}
