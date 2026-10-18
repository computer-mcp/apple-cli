public protocol ClipboardAccessing: Sendable {
  func types() throws -> ClipboardTypesResponse
  func readString(preferredType: String?, maxBytes: Int) throws -> ClipboardReadResponse
  func readItems(preferredType: String?, limit: Int, maxBytes: Int) throws -> ClipboardItemsResponse
  func writeText(_ text: String, ifChangeCount: Int?, maxBytes: Int, currentHostOnly: Bool) throws
    -> ClipboardChange
  func writeItems(
    _ items: [ClipboardItem], ifChangeCount: Int?, maxBytes: Int, currentHostOnly: Bool
  ) throws
    -> ClipboardChange
  func clear(ifChangeCount: Int?) throws -> ClipboardChange
}
