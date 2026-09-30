import Darwin
import Foundation

enum SynchronousSubprocess {
  static func run(
    path: String, arguments: [String], timeoutSeconds: Int?, outputLimit: Int
  ) throws -> CLISubprocessResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = arguments
    process.standardInput = FileHandle.nullDevice
    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr
    defer {
      try? stdout.fileHandleForReading.close()
      try? stdout.fileHandleForWriting.close()
      try? stderr.fileHandleForReading.close()
      try? stderr.fileHandleForWriting.close()
    }

    var output = try SubprocessOutputCapture(handle: stdout.fileHandleForReading)
    var error = try SubprocessOutputCapture(handle: stderr.fileHandleForReading)
    try process.run()
    try? stdout.fileHandleForWriting.close()
    try? stderr.fileHandleForWriting.close()
    let pid = process.processIdentifier
    // Foundation normally creates a child group. Verify ownership before group signals.
    let ownsGroup = getpgid(pid) == pid && pid != getpgrp()
    let deadline = timeoutSeconds.map { ProcessInfo.processInfo.systemUptime + Double($0) }
    var drainageDeadline: Double?

    do {
      while process.isRunning || !output.eof || !error.eof {
        let now = ProcessInfo.processInfo.systemUptime
        if let deadline, let timeoutSeconds, now >= deadline {
          throw CLISubprocess.timeoutError(timeoutSeconds)
        }
        if !process.isRunning {
          if drainageDeadline == nil { drainageDeadline = now + 1 }
          if let drainageDeadline, now >= drainageDeadline { throw CLISubprocess.drainageError() }
        }
        _ = try SubprocessOutputCapture.poll(
          stdout: &output, stderr: &error, limit: outputLimit, waitMilliseconds: 25)
      }
    } catch {
      terminate(process, ownsGroup: ownsGroup)
      throw error
    }
    process.waitUntilExit()
    let status = process.terminationStatus
    return CLISubprocessResult(
      exitCode: process.terminationReason == .uncaughtSignal ? 128 + status : status,
      stdout: String(decoding: output.bytes, as: UTF8.self),
      stderr: String(decoding: error.bytes, as: UTF8.self)
    )
  }

  private static func terminate(_ process: Process, ownsGroup: Bool) {
    let pid = process.processIdentifier
    let recipient = ownsGroup ? -pid : pid
    if ownsGroup || process.isRunning { _ = kill(recipient, SIGTERM) }
    let grace = ProcessInfo.processInfo.systemUptime + 0.25
    while ProcessInfo.processInfo.systemUptime < grace,
      process.isRunning || (ownsGroup && kill(recipient, 0) == 0)
    {
      usleep(10_000)
    }
    if ownsGroup || process.isRunning { _ = kill(recipient, SIGKILL) }
    process.waitUntilExit()
  }

}
