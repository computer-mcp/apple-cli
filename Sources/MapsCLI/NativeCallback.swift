import Foundation
import Utility

struct MapsDeadline {
  let uptime: TimeInterval
  init(seconds: TimeInterval) { uptime = ProcessInfo.processInfo.systemUptime + seconds }
}

// MapKit delivers on the main queue. A synchronous CLI must keep that queue runnable.
// Invoke from the CLI entrypoint or a worker, rather than blocking an active MainActor job.
func waitForMapsCallback<Value>(
  deadline: MapsDeadline, phase: String, cancel: () -> Void,
  start: (@escaping @Sendable (Result<Value, any Error>) -> Void) -> Void
) throws -> Value {
  let box = MapsCallbackBox<Value>()
  guard deadline.uptime > ProcessInfo.processInfo.systemUptime else {
    throw CLIError(code: .timeout, message: "Maps request timed out.", details: ["phase": phase])
  }
  start { box.finish($0) }
  while ProcessInfo.processInfo.systemUptime < deadline.uptime {
    if let result = box.take() { return try result.get() }
    let remaining = deadline.uptime - ProcessInfo.processInfo.systemUptime
    if remaining <= 0 { break }
    let slice = min(0.02, remaining)
    if Thread.isMainThread {
      _ = RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: slice))
    } else {
      box.wait(seconds: slice)
    }
  }
  if let result = box.close() { return try result.get() }
  cancel()
  throw CLIError(code: .timeout, message: "Maps request timed out.", details: ["phase": phase])
}

private final class MapsCallbackBox<Value>: @unchecked Sendable {
  private let condition = NSCondition()
  private var result: Result<Value, any Error>?
  private var closed = false

  func finish(_ value: Result<Value, any Error>) {
    condition.lock()
    defer { condition.unlock() }
    guard !closed, result == nil else { return }
    result = value
    condition.signal()
  }

  func take() -> Result<Value, any Error>? {
    condition.lock()
    defer { condition.unlock() }
    guard let result else { return nil }
    closed = true
    return result
  }

  func wait(seconds: TimeInterval) {
    condition.lock()
    defer { condition.unlock() }
    if result == nil, !closed { _ = condition.wait(until: Date(timeIntervalSinceNow: seconds)) }
  }

  func close() -> Result<Value, any Error>? {
    condition.lock()
    defer { condition.unlock() }
    closed = true
    return result
  }
}
