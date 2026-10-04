import Foundation
import Utility

extension RemindersSQLiteReader {
  func listType(_ row: [String: Any]) -> String? {
    if let isGroup = boolValue(row["is_group"]), isGroup {
      return nil
    }
    if emptyToNil(stringValue(row["smart_list_type"])) != nil {
      return "smart"
    }
    if let grocery = boolValue(row["should_categorize_grocery"]), grocery {
      return "shopping"
    }
    return "standard"
  }

  func privateListState(
    _ row: [String: Any],
    orderingIndexes: [String: Int] = [:]
  ) -> PrivateListState? {
    guard let listType = listType(row) else {
      return nil
    }
    let colorLength = intValue(row["color_length"])
    return PrivateListState(
      listType: listType,
      smartListType: emptyToNil(stringValue(row["smart_list_type"])),
      isPinned: boolValue(row["is_pinned"]),
      pinnedDateRaw: doubleValue(row["pinned_date"]),
      displayOrder: privateListDisplayOrder(row: row, orderingIndexes: orderingIndexes),
      sortingStyle: emptyToNil(stringValue(row["sorting_style"])),
      showingLargeAttachments: boolValue(row["showing_large_attachments"]),
      hasColor: colorLength.map { $0 > 0 } ?? boolValue(row["has_color"]),
      colorLengthBytes: colorLength
    )
  }

  func applyPrivateListState(_ state: PrivateListState, to list: inout ReminderListRecord) {
    list.listType = list.listType ?? state.listType
    list.smartListType = list.smartListType ?? state.smartListType
    list.isPinned = list.isPinned ?? state.isPinned
    list.displayOrder = list.displayOrder ?? state.displayOrder
    list.sortingStyle = list.sortingStyle ?? state.sortingStyle
    list.showingLargeAttachments = list.showingLargeAttachments ?? state.showingLargeAttachments
    list.hasColor = list.hasColor ?? state.hasColor
  }

  func privateListIdentifierKey(_ identifier: String) -> String {
    if let url = URL(string: identifier), url.scheme == "x-apple-reminderkit",
      ["REMCDList", "REMCDSmartList"].contains(url.host ?? ""),
      url.pathComponents.count == 2, UUID(uuidString: url.lastPathComponent) != nil
    {
      return url.lastPathComponent.lowercased()
    }
    return identifier.lowercased()
  }

  func deduplicateSections(
    _ sections: [ReminderSectionRecord]
  ) -> [ReminderSectionRecord] {
    var seen: Set<String> = []
    var result: [ReminderSectionRecord] = []
    for section in sections {
      let key = "\(section.listId)|\(section.title)"
      if seen.insert(key).inserted {
        result.append(section)
      }
    }
    return result
  }
}
