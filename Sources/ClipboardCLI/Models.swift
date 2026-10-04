import Foundation

public struct ClipboardReadItem: Codable, Equatable, Sendable {
  public var type: String
  public var value: String

  public init(type: String, value: String) {
    self.type = type
    self.value = value
  }
}

public struct ClipboardTypesResponse: Codable, Equatable, Sendable {
  public var types: [String]
  public var changeCount: Int

  public init(types: [String], changeCount: Int) {
    self.types = types
    self.changeCount = changeCount
  }
}

public struct ClipboardReadResponse: Codable, Equatable, Sendable {
  public var item: ClipboardReadItem?
  public var sensitive: Bool
  public var changeCount: Int

  public init(item: ClipboardReadItem?, changeCount: Int) {
    self.item = item
    sensitive = true
    self.changeCount = changeCount
  }
}

public struct ClipboardRepresentation: Codable, Equatable, Sendable {
  public var type: String
  public var data: Data?

  public init(type: String, data: Data?) {
    self.type = type
    self.data = data
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case data = "dataBase64"
  }
}

public struct ClipboardItem: Codable, Equatable, Sendable {
  public var ordinal: Int?
  public var representations: [ClipboardRepresentation]

  public init(representations: [ClipboardRepresentation], ordinal: Int? = nil) {
    self.ordinal = ordinal
    self.representations = representations
  }
}

public struct ClipboardItemsResponse: Codable, Equatable, Sendable {
  public var items: [ClipboardItem]
  public var changeCount: Int
  public var totalItems: Int
  public var totalBytes: Int
  public var truncated: Bool
  public var filtered: Bool
  public var sensitive: Bool

  public init(
    items: [ClipboardItem], changeCount: Int, totalItems: Int, totalBytes: Int,
    truncated: Bool, filtered: Bool
  ) {
    self.items = items
    self.changeCount = changeCount
    self.totalItems = totalItems
    self.totalBytes = totalBytes
    self.truncated = truncated
    self.filtered = filtered
    sensitive = true
  }
}

public struct ClipboardChange: Codable, Equatable, Sendable {
  public var changed: Bool
  public var changeCount: Int

  public init(changed: Bool, changeCount: Int) {
    self.changed = changed
    self.changeCount = changeCount
  }
}

public struct ClipboardMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var changeCount: Int
}
