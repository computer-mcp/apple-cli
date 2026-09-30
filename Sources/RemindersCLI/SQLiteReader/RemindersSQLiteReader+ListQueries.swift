import Foundation
import Utility

extension RemindersSQLiteReader {
  func privateLists(
    storePath: String,
    list: ReminderListRecord? = nil
  ) throws -> [RemindersPrivateListDebugRecord] {
    let columns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDBASELIST")
    let optionalColumns = [
      optionalSQLiteColumn(
        "ZSHOULDAUTOCATEGORIZEITEMS",
        alias: "should_auto_categorize_items",
        columns: columns,
        tableAlias: "l"
      ),
      optionalSQLiteColumn(
        "ZSHOULDSUGGESTCONVERSIONTOGROCERYLIST",
        alias: "should_suggest_conversion_to_grocery_list",
        columns: columns,
        tableAlias: "l"
      ),
      optionalSQLiteTextColumn(
        "ZGROCERYLOCALEID",
        alias: "grocery_locale_id",
        columns: columns,
        tableAlias: "l"
      ),
      optionalSQLiteColumn(
        "ZCACHEDGROCERYITEMSCOUNT",
        alias: "cached_grocery_items_count",
        columns: columns,
        tableAlias: "l"
      ),
      optionalSQLiteLengthColumn(
        "ZFILTERDATA",
        alias: "filter_data_length",
        columns: columns,
        tableAlias: "l"
      ),
      optionalSQLiteLengthColumn(
        "ZAUTOCATEGORIZATIONLOCALCORRECTIONSASDATA",
        alias: "auto_categorization_local_corrections_length",
        columns: columns,
        tableAlias: "l"
      ),
      optionalSQLiteLengthColumn(
        "ZMEMBERSHIPSOFREMINDERSINPREDEFINEDGROCERYSECTIONSASDATA",
        alias: "grocery_section_memberships_length",
        columns: columns,
        tableAlias: "l"
      ),
    ].joined(separator: ",\n          ")
    let parentReference = privateListParentReferenceExpression(columns: columns, tableAlias: "l")
    let childListCount = privateListChildCountExpression(
      columns: columns,
      groupPredicate: "coalesce(child.ZISGROUP, 0) = 0"
    )
    let childGroupCount = privateListChildCountExpression(
      columns: columns,
      groupPredicate: "coalesce(child.ZISGROUP, 0) <> 0"
    )
    let predicate: String
    let notDeleted = privateListNotDeletedPredicate(columns: columns, tableAlias: "l")
    if let list {
      predicate = """
        where \(notDeleted)
          and (
            l.ZCKIDENTIFIER = \(sqliteStringLiteral(list.id))
            or l.ZEXTERNALIDENTIFIER = \(sqliteStringLiteral(list.id))
            or l.ZNAME = \(sqliteStringLiteral(list.title))
          )
        """
    } else {
      predicate = "where \(notDeleted)"
    }
    let showingLargeAttachments = optionalSQLiteColumn(
      "ZSHOWINGLARGEATTACHMENTS",
      alias: "showing_large_attachments",
      columns: columns,
      tableAlias: "l"
    )
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          l.Z_PK as primary_key,
          coalesce(l.ZCKIDENTIFIER, '') as ck_identifier,
          coalesce(l.ZEXTERNALIDENTIFIER, '') as external_identifier,
          coalesce(l.ZNAME, '') as title,
          coalesce(l.ZSMARTLISTTYPE, '') as smart_list_type,
          l.ZSHOULDCATEGORIZEGROCERYITEMS as should_categorize_grocery,
          l.ZISGROUP as is_group,
          \(parentReference) as parent_list_primary_key,
          coalesce(parent.ZCKIDENTIFIER, '') as parent_ck_identifier,
          coalesce(parent.ZEXTERNALIDENTIFIER, '') as parent_external_identifier,
          coalesce(parent.ZNAME, '') as parent_title,
          parent.ZISGROUP as parent_is_group,
          \(childListCount) as child_list_count,
          \(childGroupCount) as child_group_count,
          l.ZISPINNEDBYCURRENTUSER as is_pinned,
          l.ZPINNEDDATE as pinned_date,
          l.ZDADISPLAYORDER as display_order,
          coalesce(l.ZSORTINGSTYLE, '') as sorting_style,
          \(showingLargeAttachments),
          case when l.ZCOLOR is not null and length(l.ZCOLOR) > 0 then 1 else 0 end as has_color,
          length(l.ZCOLOR) as color_length,
          \(optionalColumns)
        from ZREMCDBASELIST l
        left join ZREMCDBASELIST parent on parent.Z_PK = \(parentReference)
        \(predicate)
        order by l.Z_PK
        limit 500;
        """
    )

    return rows.compactMap { row in
      guard let primaryKey = int64Value(row["primary_key"]) else {
        return nil
      }
      let state = privateListState(row)
      return RemindersPrivateListDebugRecord(
        storePath: storePath,
        primaryKey: primaryKey,
        ckIdentifier: emptyToNil(stringValue(row["ck_identifier"])),
        externalIdentifier: emptyToNil(stringValue(row["external_identifier"])),
        title: emptyToNil(stringValue(row["title"])),
        smartListType: emptyToNil(stringValue(row["smart_list_type"])),
        shouldAutoCategorizeItems: boolValue(row["should_auto_categorize_items"]),
        shouldCategorizeGroceryItems: boolValue(row["should_categorize_grocery"]),
        shouldSuggestConversionToGroceryList: boolValue(
          row["should_suggest_conversion_to_grocery_list"]),
        groceryLocaleIdentifier: emptyToNil(stringValue(row["grocery_locale_id"])),
        cachedGroceryItemsCount: intValue(row["cached_grocery_items_count"]),
        isGroup: boolValue(row["is_group"]),
        parentListPrimaryKey: int64Value(row["parent_list_primary_key"]),
        parentListIdentifier: emptyToNil(stringValue(row["parent_ck_identifier"]))
          ?? emptyToNil(stringValue(row["parent_external_identifier"])),
        parentListTitle: emptyToNil(stringValue(row["parent_title"])),
        parentListIsGroup: boolValue(row["parent_is_group"]),
        childListCount: intValue(row["child_list_count"]) ?? 0,
        childGroupCount: intValue(row["child_group_count"]) ?? 0,
        listType: state?.listType,
        isPinned: state?.isPinned,
        pinnedDateRaw: state?.pinnedDateRaw,
        displayOrder: state?.displayOrder,
        sortingStyle: state?.sortingStyle,
        showingLargeAttachments: state?.showingLargeAttachments,
        hasColor: state?.hasColor,
        colorLengthBytes: state?.colorLengthBytes,
        filterDataLengthBytes: intValue(row["filter_data_length"]),
        autoCategorizationLocalCorrectionsLengthBytes: intValue(
          row["auto_categorization_local_corrections_length"]),
        grocerySectionMembershipsLengthBytes: intValue(row["grocery_section_memberships_length"])
      )
    }
  }

  func tableColumnNames(storePath: String, tableName: String) throws -> Set<String> {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: "pragma table_info(\(sqliteIdentifier(tableName)));"
    )
    return Set(rows.compactMap { stringValue($0["name"]) })
  }

  func optionalSQLiteColumn(
    _ column: String,
    alias: String,
    columns: Set<String>,
    tableAlias: String? = nil
  ) -> String {
    if columns.contains(column) {
      return "\(sqliteColumnReference(column, tableAlias: tableAlias)) as \(alias)"
    }
    return "null as \(alias)"
  }

  func optionalSQLiteTextColumn(
    _ column: String,
    alias: String,
    columns: Set<String>,
    tableAlias: String? = nil
  ) -> String {
    if columns.contains(column) {
      return "coalesce(\(sqliteColumnReference(column, tableAlias: tableAlias)), '') as \(alias)"
    }
    return "null as \(alias)"
  }

  func optionalSQLiteLengthColumn(
    _ column: String,
    alias: String,
    columns: Set<String>,
    tableAlias: String? = nil
  ) -> String {
    if columns.contains(column) {
      return "length(\(sqliteColumnReference(column, tableAlias: tableAlias))) as \(alias)"
    }
    return "null as \(alias)"
  }

  func sqliteColumnReference(_ column: String, tableAlias: String?) -> String {
    guard let tableAlias else {
      return column
    }
    return "\(tableAlias).\(column)"
  }

  func privateListNotDeletedPredicate(
    columns: Set<String>,
    tableAlias: String? = nil
  ) -> String {
    guard columns.contains("ZMARKEDFORDELETION") else {
      return "1 = 1"
    }
    let reference = sqliteColumnReference("ZMARKEDFORDELETION", tableAlias: tableAlias)
    return "(\(reference) is null or \(reference) = 0)"
  }

  func privateListParentReferenceExpression(
    columns: Set<String>,
    tableAlias: String
  ) -> String {
    let candidates = ["ZPARENTLIST", "ZPARENTLIST1", "Z_FOK_PARENTLIST", "Z_FOK_PARENTLIST1"]
      .filter { columns.contains($0) }
      .map { "\(tableAlias).\($0)" }
    switch candidates.count {
    case 0:
      return "null"
    case 1:
      return candidates[0]
    default:
      return "coalesce(\(candidates.joined(separator: ", ")))"
    }
  }

  func privateListChildCountExpression(
    columns: Set<String>,
    groupPredicate: String
  ) -> String {
    guard columns.contains("ZPARENTLIST") || columns.contains("ZPARENTLIST1") else {
      return "0"
    }
    let childParentReference = privateListParentReferenceExpression(
      columns: columns,
      tableAlias: "child"
    )
    let childNotDeleted = privateListNotDeletedPredicate(columns: columns, tableAlias: "child")
    return """
      (
            select count(*)
            from ZREMCDBASELIST child
            where \(childParentReference) = l.Z_PK
              and \(childNotDeleted)
              and \(groupPredicate)
          )
      """
  }
}
