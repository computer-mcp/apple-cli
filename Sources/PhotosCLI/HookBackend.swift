import Foundation
import Utility

public struct PhotosHookBackend: Sendable {
  public init() {}

  public func runHook(
    kind: String,
    source: String,
    input: PhotoHookInput,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotoHookOutput {
    let sourceText = try resolveSource(source)
    let inputData = try CLIJSONData.encode(input)
    let output = try runProcess(
      executable: "/usr/bin/swift",
      arguments: ["-e", sourceText],
      stdin: inputData,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
    do {
      return try JSONDecoder().decode(PhotoHookOutput.self, from: output.stdout)
    } catch {
      throw CLIError(
        code: .validationError,
        message: "Swift eval hook did not emit valid PhotoHookOutput JSON.",
        details: CLIError.diagnosticDetails(for: error).merging(["hook": kind]) { _, new in new }
      )
    }
  }

  public func runPostCommand(
    command: String,
    category: String,
    input: PhotoHookInput,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosActionResult {
    let inputData = try CLIJSONData.encode(input)
    _ = try runProcess(
      executable: "/bin/zsh",
      arguments: ["-lc", command],
      stdin: inputData,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
    return PhotosActionResult(
      operation: "photos.post-commands.run",
      submitted: true,
      summaryFields: ["category": category]
    )
  }

  private func resolveSource(_ source: String) throws -> String {
    if source.hasPrefix("file:") {
      let path = String(source.dropFirst("file:".count))
      return try String(contentsOfFile: path, encoding: .utf8)
    }
    return source
  }
}

private struct ProcessOutput {
  var stdout: Data
  var stderr: Data
}

private func runProcess(
  executable: String,
  arguments: [String],
  stdin: Data,
  timeoutSeconds: Int,
  outputCap: Int
) throws -> ProcessOutput {
  let result: CLISubprocessBytesResult
  do {
    result = try CLISubprocess.runBytes(
      .path(executable), arguments: arguments, input: stdin,
      timeoutSeconds: timeoutSeconds, outputLimit: outputCap)
  } catch let error as CLIError
    where error.code == .backendUnavailable && error.details["output_limit"] != nil
  {
    throw CLIError(
      code: .validationError, message: "Photos hook subprocess exceeded output cap.",
      details: ["output_cap": "\(outputCap)"])
  }
  guard result.exitCode == 0 else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Photos hook subprocess failed.",
      details: ["termination_status": "\(result.exitCode)"])
  }
  return ProcessOutput(stdout: result.stdout, stderr: result.stderr)
}

private enum CLIJSONData {
  static func encode(_ value: Encodable) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(value)
  }
}
