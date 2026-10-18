public enum CLIDiagnosticLevel: String, Codable, Equatable, Sendable {
  case debug
  case info
  case warning
  case error
}

public struct CLIDiagnostic: Codable, Equatable, Sendable {
  public var level: CLIDiagnosticLevel
  public var message: String

  public init(level: CLIDiagnosticLevel, message: String) {
    self.level = level
    self.message = message
  }
}

public struct CLIDiagnosticBuffer: Equatable, Sendable {
  public private(set) var entries: [CLIDiagnostic]

  public init(entries: [CLIDiagnostic] = []) {
    self.entries = entries
  }

  public mutating func append(_ level: CLIDiagnosticLevel, _ message: String) {
    entries.append(CLIDiagnostic(level: level, message: message))
  }

  public func renderStderr() -> String {
    entries
      .map { "\($0.level.rawValue): \($0.message)" }
      .joined(separator: "\n")
  }
}
