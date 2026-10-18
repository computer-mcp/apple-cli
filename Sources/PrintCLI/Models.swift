import CryptoKit
import Foundation
import Utility

public struct PrinterRecord: Codable, Equatable, Sendable {
  public var name: String
  public var state: String
  public var isEnabled: Bool?
  public var isDefault: Bool
  public var deviceURI: String?

  public init(
    name: String,
    state: String,
    isEnabled: Bool? = nil,
    isDefault: Bool = false,
    deviceURI: String? = nil
  ) {
    self.name = name
    self.state = state
    self.isEnabled = isEnabled
    self.isDefault = isDefault
    self.deviceURI = deviceURI
  }
}

public struct PrintJobRecord: Codable, Equatable, Sendable {
  public var id: String
  public var printerName: String
  public var owner: String?
  public var sizeBytes: Int?
  public var submittedAtText: String?

  public init(
    id: String,
    printerName: String,
    owner: String? = nil,
    sizeBytes: Int? = nil,
    submittedAtText: String? = nil
  ) {
    self.id = id
    self.printerName = printerName
    self.owner = owner
    self.sizeBytes = sizeBytes
    self.submittedAtText = submittedAtText
  }
}

public struct PrintersResponse: Codable, Equatable, Sendable {
  public var printers: [PrinterRecord]
}

public struct PrinterResponse: Codable, Equatable, Sendable {
  public var printer: PrinterRecord
}

public struct PrintJobsResponse: Codable, Equatable, Sendable {
  public var jobs: [PrintJobRecord]
}
