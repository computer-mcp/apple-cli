import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

public protocol FinderReading: Sendable {
  func listItems(path: String, includeHidden: Bool, limit: Int) throws -> [FinderItemRecord]
  func searchItems(path: String, query: String, includeHidden: Bool, limit: Int) throws
    -> [FinderItemRecord]
  func readMetadata(path: String) throws -> FinderItemRecord?
}

public protocol FinderMutating: Sendable {
  func moveItem(path: String, to destinationPath: String) throws -> FinderItemRecord
  func trashItem(path: String) throws -> Bool
  func deleteFile(path: String) throws -> Bool
  func setTags(path: String, tags: [String]) throws -> FinderItemRecord
  func writeTextFile(path: String, text: String) throws -> FinderItemRecord
  func overwriteTextFile(path: String, text: String) throws -> FinderItemRecord
}

public protocol FinderExternalActioning: Sendable {
  func open(path: String) throws -> Bool
  func reveal(path: String) throws -> Bool
}
