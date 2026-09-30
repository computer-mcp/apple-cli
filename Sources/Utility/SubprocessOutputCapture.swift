import Darwin
import Foundation

struct SubprocessOutputCapture {
  let fd: Int32
  var bytes: [UInt8] = []
  var eof = false

  init(handle: FileHandle) throws {
    fd = handle.fileDescriptor
    let flags = fcntl(fd, F_GETFL)
    guard flags >= 0, fcntl(fd, F_SETFL, flags | O_NONBLOCK) == 0 else {
      throw Self.ioError("configure output pipe")
    }
  }

  static func poll(
    stdout: inout Self, stderr: inout Self, limit: Int, waitMilliseconds: Int32
  ) throws -> Bool {
    var descriptors = [
      pollfd(fd: stdout.eof ? -1 : stdout.fd, events: Int16(POLLIN), revents: 0),
      pollfd(fd: stderr.eof ? -1 : stderr.fd, events: Int16(POLLIN), revents: 0),
    ]
    let ready = Darwin.poll(&descriptors, nfds_t(descriptors.count), waitMilliseconds)
    guard ready >= 0 || errno == EINTR else { throw ioError("poll") }
    if ready > 0 {
      if descriptors[0].revents != 0 { try stdout.drain(limit: limit) }
      if descriptors[1].revents != 0 { try stderr.drain(limit: limit) }
    }
    return ready > 0
  }

  private mutating func drain(limit: Int) throws {
    // A bounded read per iteration prevents either stream starving the other.
    let remaining = limit - bytes.count
    let count = remaining >= 8_192 ? 8_192 : remaining + 1
    var buffer = [UInt8](repeating: 0, count: count)
    let received = buffer.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, count) }
    if received == 0 {
      eof = true
    } else if received > 0 {
      guard received <= remaining else { throw CLISubprocess.outputLimitError(limit) }
      bytes.append(contentsOf: buffer.prefix(received))
    } else if errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR {
      throw Self.ioError("read output pipe")
    }
  }

  private static func ioError(_ operation: String) -> CLIError {
    CLIError(code: .backendUnavailable, message: "Subprocess IO failed.",
      details: ["operation": operation, "errno": "\(errno)"])
  }
}
