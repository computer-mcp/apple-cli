import Foundation

public struct CLISuccessEnvelope<Payload: Encodable>: Encodable {
  public let ok = true
  public var data: Payload
  public var meta: [String: String]
  public var warnings: [String]

  public init(
    data: Payload,
    meta: [String: String] = [:],
    warnings: [String] = []
  ) {
    self.data = data
    self.meta = meta
    self.warnings = warnings
  }

  private enum CodingKeys: String, CodingKey {
    case ok
    case data
    case meta
    case warnings
  }
}

public struct CLIErrorEnvelope: Encodable {
  public let ok = false
  public var error: CLIErrorPayload
  public var meta: [String: String]
  public var warnings: [String]

  public init(
    error: CLIErrorPayload,
    meta: [String: String] = [:],
    warnings: [String] = []
  ) {
    self.error = error
    self.meta = meta
    self.warnings = warnings
  }

  private enum CodingKeys: String, CodingKey {
    case ok
    case error
    case meta
    case warnings
  }
}

public enum CLIJSON {
  public static func encodeString(_ value: Encodable, pretty: Bool = false) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(value)

    guard let string = String(data: data, encoding: .utf8) else {
      throw CLIError(code: .internalError, message: "Failed to encode UTF-8 JSON output.")
    }

    return string
  }
}
