import Foundation
import Utility

extension RemindersSQLiteReader {
  func privateReminderIDs(
    tagName: String,
    storePath: String
  ) throws -> [String] {
    let objectColumns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDOBJECT")
    let reminderColumns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDREMINDER")
    let relationPredicate = privateObjectReminderRelationPredicate(objectColumns: objectColumns)
    guard relationPredicate != "0 = 1" else {
      return []
    }

    let objectMarkedForDeletion =
      objectColumns.contains("ZMARKEDFORDELETION")
      ? "(o.ZMARKEDFORDELETION is null or o.ZMARKEDFORDELETION = 0)"
      : "1 = 1"
    let reminderMarkedForDeletion =
      reminderColumns.contains("ZMARKEDFORDELETION")
      ? "(r.ZMARKEDFORDELETION is null or r.ZMARKEDFORDELETION = 0)"
      : "1 = 1"
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select distinct
          \(optionalSQLiteTextColumn(
            "ZDACALENDARITEMUNIQUEIDENTIFIER",
            alias: "calendar_item_id",
            columns: reminderColumns,
            tableAlias: "r"
          )),
          \(optionalSQLiteTextColumn(
            "ZCKIDENTIFIER",
            alias: "ck_identifier",
            columns: reminderColumns,
            tableAlias: "r"
          )),
          \(optionalSQLiteTextColumn(
            "ZEXTERNALIDENTIFIER",
            alias: "external_identifier",
            columns: reminderColumns,
            tableAlias: "r"
          ))
        from ZREMCDOBJECT o
        join ZREMCDHASHTAGLABEL h on h.Z_PK = o.ZHASHTAGLABEL
        join ZREMCDREMINDER r on \(relationPredicate)
        where o.ZHASHTAGLABEL is not null
          and (
            lower(coalesce(h.ZNAME, '')) = lower(\(sqliteStringLiteral(tagName)))
            or lower(coalesce(h.ZCANONICALNAME, '')) = lower(\(sqliteStringLiteral(tagName)))
          )
          and \(objectMarkedForDeletion)
          and \(reminderMarkedForDeletion)
        order by calendar_item_id, ck_identifier, external_identifier;
        """
    )

    var ids: Set<String> = []
    for row in rows {
      for id in [
        stringValue(row["calendar_item_id"]),
        stringValue(row["ck_identifier"]),
        stringValue(row["external_identifier"]),
      ].compactMap(emptyToNil) {
        ids.insert(id)
        break
      }
    }
    return ids.sorted()
  }

  func privateObjectReminderRelationPredicate(objectColumns: Set<String>) -> String {
    let relations = [
      "ZREMINDER",
      "ZREMINDER1",
      "ZREMINDER2",
      "ZREMINDER3",
      "ZREMINDER4",
      "ZREMINDER5",
    ].filter { objectColumns.contains($0) }

    guard !relations.isEmpty else {
      return "0 = 1"
    }

    return
      relations
      .map { "r.Z_PK = o.\($0)" }
      .joined(separator: " or ")
  }

  func privateTags(storePath: String) throws -> [RemindersPrivateTagDebugRecord] {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          h.Z_PK as primary_key,
          coalesce(h.ZNAME, '') as name,
          coalesce(h.ZCANONICALNAME, '') as canonical_name,
          coalesce(h.ZACCOUNTIDENTIFIER, '') as account_identifier,
          count(o.Z_PK) as related_object_count,
          sum(
            case
              when o.ZREMINDER is not null
                or o.ZREMINDER1 is not null
                or o.ZREMINDER2 is not null
                or o.ZREMINDER3 is not null
                or o.ZREMINDER4 is not null
                or o.ZREMINDER5 is not null
              then 1 else 0
            end
          ) as reminder_reference_count
        from ZREMCDHASHTAGLABEL h
        left join ZREMCDOBJECT o on o.ZHASHTAGLABEL = h.Z_PK
        group by h.Z_PK, h.ZNAME, h.ZCANONICALNAME, h.ZACCOUNTIDENTIFIER
        order by h.ZCANONICALNAME, h.ZNAME, h.Z_PK
        limit 500;
        """
    )

    return rows.compactMap { row in
      guard let primaryKey = int64Value(row["primary_key"]) else {
        return nil
      }
      return RemindersPrivateTagDebugRecord(
        storePath: storePath,
        primaryKey: primaryKey,
        name: emptyToNil(stringValue(row["name"])),
        canonicalName: emptyToNil(stringValue(row["canonical_name"])),
        accountIdentifier: emptyToNil(stringValue(row["account_identifier"])),
        relatedObjectCount: intValue(row["related_object_count"]) ?? 0,
        reminderReferenceCount: intValue(row["reminder_reference_count"]) ?? 0
      )
    }
  }
}
