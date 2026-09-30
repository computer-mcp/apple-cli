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
        details: ["hook": kind, "error": String(describing: error)]
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
  let process = Process()
  process.executableURL = URL(fileURLWithPath: executable)
  process.arguments = arguments

  let inputPipe = Pipe()
  let outputPipe = Pipe()
  let errorPipe = Pipe()
  process.standardInput = inputPipe
  process.standardOutput = outputPipe
  process.standardError = errorPipe

  try process.run()
  inputPipe.fileHandleForWriting.write(stdin)
  try inputPipe.fileHandleForWriting.close()

  let deadline = Date().addingTimeInterval(TimeInterval(timeoutSeconds))
  while process.isRunning, Date() < deadline {
    usleep(10_000)
  }
  if process.isRunning {
    process.terminate()
    throw CLIError(code: .timeout, message: "Photos hook subprocess timed out.")
  }

  let stdout = outputPipe.fileHandleForReading.readDataToEndOfFile()
  let stderr = errorPipe.fileHandleForReading.readDataToEndOfFile()
  guard stdout.count <= outputCap, stderr.count <= outputCap else {
    throw CLIError(
      code: .validationError,
      message: "Photos hook subprocess exceeded output cap.",
      details: ["output_cap": "\(outputCap)"]
    )
  }
  guard process.terminationStatus == 0 else {
    let message = String(data: stderr, encoding: .utf8) ?? "Photos hook subprocess failed."
    throw CLIError(
      code: .backendUnavailable,
      message: message.trimmingCharacters(in: .whitespacesAndNewlines),
      details: ["termination_status": "\(process.terminationStatus)"]
    )
  }
  return ProcessOutput(stdout: stdout, stderr: stderr)
}

private enum CLIJSONData {
  static func encode(_ value: Encodable) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(value)
  }
}
