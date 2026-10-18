import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

public struct FinderItemRecord: Codable, Equatable, Sendable {
  public var path: String
  public var name: String
  public var isDirectory: Bool
  public var isRegularFile: Bool
  public var isSymbolicLink: Bool
  public var size: Int64?
  public var modifiedAt: Date?
  public var tags: [String]

  public init(
    path: String,
    name: String,
    isDirectory: Bool,
    isRegularFile: Bool,
    isSymbolicLink: Bool,
    size: Int64? = nil,
    modifiedAt: Date? = nil,
    tags: [String] = []
  ) {
    self.path = path
    self.name = name
    self.isDirectory = isDirectory
    self.isRegularFile = isRegularFile
    self.isSymbolicLink = isSymbolicLink
    self.size = size
    self.modifiedAt = modifiedAt
    self.tags = tags
  }
}

public struct FinderItemsResponse: Codable, Equatable, Sendable {
  public var items: [FinderItemRecord]
}

public struct FinderMetadataResponse: Codable, Equatable, Sendable {
  public var item: FinderItemRecord
}

public struct FinderMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var sourcePath: String
  public var destinationPath: String?
  public var item: FinderItemRecord?
}
