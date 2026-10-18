import Foundation
import Utility

extension RemindersSQLiteReader {
  func privateSections(storePath: String) throws -> [RemindersPrivateSectionDebugRecord] {
    let sectionColumns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDBASESECTION")
    let listReference = privateSectionListReferenceExpression(sectionColumns: sectionColumns)
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          s.Z_PK as primary_key,
          coalesce(s.ZDISPLAYNAME, '') as display_name,
          \(listReference) as list_primary_key,
          coalesce(l.ZCKIDENTIFIER, '') as list_ck_identifier,
          coalesce(l.ZEXTERNALIDENTIFIER, '') as list_external_identifier,
          coalesce(l.ZNAME, '') as list_title,
          coalesce(l.ZSMARTLISTTYPE, '') as smart_list_type,
          l.ZSHOULDCATEGORIZEGROCERYITEMS as should_categorize_grocery,
          l.ZISGROUP as is_group,
          s.ZMARKEDFORDELETION as marked_for_deletion
        from ZREMCDBASESECTION s
        left join ZREMCDBASELIST l on l.Z_PK = \(listReference)
        order by \(listReference), s.ZDISPLAYNAME, s.Z_PK
        limit 500;
        """
    )

    return rows.compactMap { privateSectionRecord(row: $0, storePath: storePath) }
  }

  func privateSections(
    storePath: String,
    listPrimaryKeys: [Int64]
  ) throws -> [RemindersPrivateSectionDebugRecord] {
    let ids = Array(Set(listPrimaryKeys)).sorted().map(String.init).joined(separator: ",")
    guard !ids.isEmpty else {
      return []
    }

    let sectionColumns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDBASESECTION")
    let listReference = privateSectionListReferenceExpression(sectionColumns: sectionColumns)
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          s.Z_PK as primary_key,
          coalesce(s.ZDISPLAYNAME, '') as display_name,
          \(listReference) as list_primary_key,
          coalesce(l.ZCKIDENTIFIER, '') as list_ck_identifier,
          coalesce(l.ZEXTERNALIDENTIFIER, '') as list_external_identifier,
          coalesce(l.ZNAME, '') as list_title,
          coalesce(l.ZSMARTLISTTYPE, '') as smart_list_type,
          l.ZSHOULDCATEGORIZEGROCERYITEMS as should_categorize_grocery,
          l.ZISGROUP as is_group,
          s.ZMARKEDFORDELETION as marked_for_deletion
        from ZREMCDBASESECTION s
        left join ZREMCDBASELIST l on l.Z_PK = \(listReference)
        where \(listReference) in (\(ids))
        order by \(listReference), s.ZDISPLAYNAME, s.Z_PK;
        """
    )

    return rows.compactMap { privateSectionRecord(row: $0, storePath: storePath) }
  }

  func privateSectionListReferenceExpression(sectionColumns: Set<String>) -> String {
    if sectionColumns.contains("ZSMARTLIST") {
      return "coalesce(s.ZLIST, s.ZSMARTLIST)"
    }
    return "s.ZLIST"
  }

  func privateSectionRecord(
    row: [String: Any],
    storePath: String
  ) -> RemindersPrivateSectionDebugRecord? {
    guard let primaryKey = int64Value(row["primary_key"]) else {
      return nil
    }
    let listIdentifier =
      emptyToNil(stringValue(row["list_ck_identifier"]))
      ?? emptyToNil(stringValue(row["list_external_identifier"]))
    let listTitle = emptyToNil(stringValue(row["list_title"]))
    let smartListType = emptyToNil(stringValue(row["smart_list_type"]))
    let shouldCategorizeGrocery = boolValue(row["should_categorize_grocery"])
    let hasListEvidence =
      listIdentifier != nil || listTitle != nil || smartListType != nil
      || shouldCategorizeGrocery != nil || boolValue(row["is_group"]) != nil
    return RemindersPrivateSectionDebugRecord(
      storePath: storePath,
      primaryKey: primaryKey,
      displayName: emptyToNil(stringValue(row["display_name"])),
      listPrimaryKey: int64Value(row["list_primary_key"]),
      listIdentifier: listIdentifier,
      listTitle: listTitle,
      listType: hasListEvidence ? listType(row) : nil,
      listSmartListType: smartListType,
      listShouldCategorizeGroceryItems: shouldCategorizeGrocery,
      markedForDeletion: boolValue(row["marked_for_deletion"])
    )
  }
}
