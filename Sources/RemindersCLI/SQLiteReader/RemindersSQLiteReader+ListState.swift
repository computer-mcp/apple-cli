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
    list.listType = state.listType
    list.smartListType = state.smartListType
    list.isPinned = state.isPinned
    list.displayOrder = state.displayOrder
    list.sortingStyle = state.sortingStyle
    list.showingLargeAttachments = state.showingLargeAttachments
    list.hasColor = state.hasColor
  }

  func privateListRecord(
    row: [String: Any],
    storePath: String,
    state: PrivateListState
  ) -> ReminderListRecord? {
    guard let title = emptyToNil(stringValue(row["title"])) else {
      return nil
    }
    let id =
      emptyToNil(stringValue(row["ck_identifier"]))
      ?? emptyToNil(stringValue(row["external_identifier"]))
      ?? int64Value(row["primary_key"]).map {
        "private-list:\(String(sha256Hex("\(storePath)|\($0)|\(title)").prefix(12)))"
      }
    guard let id else {
      return nil
    }
    return ReminderListRecord(
      id: id,
      title: title,
      sourceId: "",
      sourceTitle: "",
      allowsContentModifications: true,
      listType: state.listType,
      smartListType: state.smartListType,
      isPinned: state.isPinned,
      displayOrder: state.displayOrder,
      sortingStyle: state.sortingStyle,
      showingLargeAttachments: state.showingLargeAttachments,
      hasColor: state.hasColor
    )
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
