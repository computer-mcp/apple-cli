import Darwin
import Foundation
import Subprocess

#if canImport(System)
  import System
#else
  import SystemPackage
#endif

public struct CLISubprocessResult: Equatable, Sendable {
  public var exitCode: Int32
  public var stdout: String
  public var stderr: String

  public init(exitCode: Int32, stdout: String, stderr: String) {
    self.exitCode = exitCode
    self.stdout = stdout
    self.stderr = stderr
  }
}

public struct CLISubprocess: Sendable {
  public enum Executable: Sendable {
    case name(String)
    case path(String)

    fileprivate var subprocessExecutable: Subprocess.Executable {
      switch self {
      case .name(let name):
        return .name(name)
      case .path(let path):
        return .path(FilePath(path))
      }
    }
  }

  public static func run(
    _ executable: Executable,
    arguments: [String],
    timeoutSeconds: Int? = nil,
    outputLimit: Int = 1_048_576
  ) throws -> CLISubprocessResult {
    try validate(timeoutSeconds: timeoutSeconds, outputLimit: outputLimit)
    let path = try executable.subprocessExecutable.resolveExecutablePath(in: .inherit)
    return try SynchronousSubprocess.run(
      path: path.string, arguments: arguments,
      timeoutSeconds: timeoutSeconds, outputLimit: outputLimit
    )
  }

  public static func runAsync(
    _ executable: Executable,
    arguments: [String],
    timeoutSeconds: Int? = nil,
    outputLimit: Int = 1_048_576
  ) async throws -> CLISubprocessResult {
    try validate(timeoutSeconds: timeoutSeconds, outputLimit: outputLimit)
    try Task.checkCancellation()
    let stdout = Pipe()
    let stderr = Pipe()
    defer {
      try? stdout.fileHandleForReading.close()
      try? stdout.fileHandleForWriting.close()
      try? stderr.fileHandleForReading.close()
      try? stderr.fileHandleForWriting.close()
    }
    var platformOptions = PlatformOptions()
    platformOptions.processGroupID = 0
    let record = try await Subprocess.run(
      executable.subprocessExecutable,
      arguments: Subprocess.Arguments(arguments),
      platformOptions: platformOptions,
      output: .fileDescriptor(FileDescriptor(rawValue: stdout.fileHandleForWriting.fileDescriptor),
        closeAfterSpawningProcess: false),
      error: .fileDescriptor(FileDescriptor(rawValue: stderr.fileHandleForWriting.fileDescriptor),
        closeAfterSpawningProcess: false)
    ) { execution in
      let pid = execution.processIdentifier.value
      return try await withTaskCancellationHandler {
        // These readers are caller-owned, so cleanup can close them even when
        // a descendant escapes the group and keeps its writer open.
        defer {
          try? stdout.fileHandleForReading.close()
          try? stderr.fileHandleForReading.close()
        }
        do {
          try stdout.fileHandleForWriting.close()
          try stderr.fileHandleForWriting.close()
          var output = try SubprocessOutputCapture(handle: stdout.fileHandleForReading)
          var error = try SubprocessOutputCapture(handle: stderr.fileHandleForReading)
          let deadline = timeoutSeconds.map { ContinuousClock.now.advanced(by: .seconds($0)) }
          var drainageDeadline: ContinuousClock.Instant?
          var terminated = false
          while !terminated || !output.eof || !error.eof {
            try Task.checkCancellation()
            if let deadline, let timeoutSeconds, .now >= deadline { throw timeoutError(timeoutSeconds) }
            if !terminated {
              // Observe exit without reaping: the SDK owns waitpid after the body returns.
              var status = siginfo_t()
              let result = waitid(P_PID, id_t(pid), &status, WEXITED | WNOHANG | WNOWAIT)
              guard result == 0 || errno == EINTR else {
                throw CLIError(code: .backendUnavailable, message: "Could not observe subprocess termination.")
              }
              if result == 0, status.si_pid == pid {
                terminated = true
                drainageDeadline = .now.advanced(by: .seconds(1))
              }
            }
            if let drainageDeadline, .now >= drainageDeadline { throw drainageError() }
            let ready = try SubprocessOutputCapture.poll(
              stdout: &output, stderr: &error, limit: outputLimit, waitMilliseconds: 0)
            if ready { await Task.yield() } else { try await Task.sleep(for: .milliseconds(25)) }
          }
          try Task.checkCancellation()
          return (
            stdout: String(decoding: output.bytes, as: UTF8.self),
            stderr: String(decoding: error.bytes, as: UTF8.self)
          )
        } catch {
          // The SDK starts this execution in its own group (processGroupID=0).
          _ = kill(-pid, SIGKILL)
          throw error
        }
      } onCancel: {
        _ = kill(-pid, SIGKILL)
      }
    }
    try Task.checkCancellation()
    return CLISubprocessResult(
      exitCode: exitCode(from: record.terminationStatus),
      stdout: record.value.stdout,
      stderr: record.value.stderr
    )
  }

  private static func validate(timeoutSeconds: Int?, outputLimit: Int) throws {
    if let timeoutSeconds, !(1...(Int.max / 1_000_000_000)).contains(timeoutSeconds) {
      throw CLIError(code: .validationError, message: "Subprocess timeout must be a positive, representable duration.")
    }
    guard outputLimit >= 0 else {
      throw CLIError(code: .validationError, message: "Subprocess output limit must be nonnegative.")
    }
  }

  static func timeoutError(_ seconds: Int) -> CLIError {
    CLIError(code: .timeout, message: "Timed out while running subprocess.",
      details: ["timeout_seconds": "\(seconds)"])
  }

  static func outputLimitError(_ limit: Int) -> CLIError {
    CLIError(code: .backendUnavailable, message: "Subprocess output exceeded the configured byte limit.",
      details: ["output_limit": "\(limit)"])
  }

  static func drainageError() -> CLIError {
    CLIError(code: .backendUnavailable, message: "Subprocess exited but its output pipes remained open.")
  }

  private static func exitCode(from status: TerminationStatus) -> Int32 {
    switch status {
    case .exited(let code):
      return Int32(code)
    #if !os(Windows)
      case .signaled(let signal):
        return 128 + Int32(signal)
    #endif
    }
  }
}
