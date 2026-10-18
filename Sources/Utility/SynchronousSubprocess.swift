import Darwin
import Foundation

enum SynchronousSubprocess {
  static func run(
    path: String, arguments: [String], input: Data?, timeoutSeconds: Int?, outputLimit: Int
  ) throws -> CLISubprocessBytesResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = arguments
    let stdin = input.map { _ in Pipe() }
    process.standardInput = stdin?.fileHandleForReading ?? FileHandle.nullDevice
    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr
    defer {
      try? stdin?.fileHandleForReading.close()
      try? stdin?.fileHandleForWriting.close()
      try? stdout.fileHandleForReading.close()
      try? stdout.fileHandleForWriting.close()
      try? stderr.fileHandleForReading.close()
      try? stderr.fileHandleForWriting.close()
    }

    var output = try SubprocessOutputCapture(handle: stdout.fileHandleForReading)
    var error = try SubprocessOutputCapture(handle: stderr.fileHandleForReading)
    var inputWriter: SubprocessInputWriter?
    if let stdin, let input {
      inputWriter = try SubprocessInputWriter(handle: stdin.fileHandleForWriting, bytes: input)
    }
    try process.run()
    try? stdin?.fileHandleForReading.close()
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
        try inputWriter?.writeAvailable()
        if inputWriter?.completed == true {
          try? stdin?.fileHandleForWriting.close()
          inputWriter = nil
        }
        _ = try SubprocessOutputCapture.poll(
          stdout: &output, stderr: &error, limit: outputLimit, waitMilliseconds: 25,
          inputDescriptor: inputWriter?.fd)
      }
    } catch {
      terminate(process, ownsGroup: ownsGroup)
      throw error
    }
    process.waitUntilExit()
    let status = process.terminationStatus
    return CLISubprocessBytesResult(
      exitCode: process.terminationReason == .uncaughtSignal ? 128 + status : status,
      stdout: Data(output.bytes),
      stderr: Data(error.bytes)
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

private struct SubprocessInputWriter {
  let fd: Int32
  let bytes: Data
  private var offset = 0
  var completed: Bool { offset == bytes.count }

  init(handle: FileHandle, bytes: Data) throws {
    fd = handle.fileDescriptor
    self.bytes = bytes
    let flags = fcntl(fd, F_GETFL)
    // The child may close stdin early; EPIPE must not signal the CLI process.
    guard flags >= 0, fcntl(fd, F_SETFL, flags | O_NONBLOCK) == 0,
      fcntl(fd, F_SETNOSIGPIPE, 1) == 0
    else {
      throw Self.ioError()
    }
  }

  mutating func writeAvailable() throws {
    guard !completed else { return }
    let count = min(8_192, bytes.count - offset)
    let written = bytes.withUnsafeBytes {
      Darwin.write(fd, $0.baseAddress?.advanced(by: offset), count)
    }
    if written > 0 {
      offset += written
    } else if written < 0 {
      switch errno {
      case EPIPE:
        offset = bytes.count
      case EAGAIN, EINTR:
        break
      default:
        throw Self.ioError()
      }
    }
  }

  private static func ioError() -> CLIError {
    CLIError(code: .backendUnavailable, message: "Subprocess input IO failed.",
      details: ["errno": "\(errno)"])
  }
}
