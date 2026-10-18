import Foundation
import Utility

extension RemindersSQLiteReader {
  func storeSchemaTables(storePath: String) throws -> [RemindersStoreSchemaTableRecord] {
    let tableRows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select name
        from sqlite_master
        where type = 'table'
          and (name like 'ZREMCD%' or name like 'ZREMCK%')
        order by name;
        """
    )

    return try tableRows.compactMap { row in
      guard let tableName = stringValue(row["name"]) else {
        return nil
      }
      let columnRows = try sqliteJSONRows(
        storePath: storePath,
        sql: "pragma table_info(\(sqliteIdentifier(tableName)));"
      )
      let columns = columnRows.compactMap { stringValue($0["name"]) }
      return RemindersStoreSchemaTableRecord(
        storePath: storePath,
        tableName: tableName,
        columnCount: columns.count,
        columns: columns
      )
    }
  }

  func privateObjectSummaries(
    storePath: String,
    scope: String = "links"
  ) throws -> [RemindersPrivateObjectSummaryRecord] {
    let predicate = privateObjectSummaryPredicate(scope: scope)
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          coalesce(ZUTI, '') as uti,
          case
            when ZREMINDER is not null then 'reminder'
            when ZREMINDER1 is not null then 'reminder1'
            when ZREMINDER2 is not null then 'reminder2'
            when ZREMINDER3 is not null then 'reminder3'
            when ZREMINDER4 is not null then 'reminder4'
            when ZREMINDER5 is not null then 'reminder5'
            when ZHASHTAGLABEL is not null then 'hashtag'
            when ZLIST is not null then 'list'
            else 'unknown'
          end as relation,
          count(*) as count,
          sum(case when coalesce(ZURL, '') <> '' then 1 else 0 end) as url_count,
          sum(case when coalesce(ZFILENAME, '') <> '' then 1 else 0 end) as file_name_count,
          sum(
            case
              when ZASSIGNEE is not null
                or ZASSIGNEDDATE is not null
                or coalesce(ZPERSONID, '') <> ''
                or coalesce(ZCONTACTLABEL, '') <> ''
                or coalesce(ZCKASSIGNEEIDENTIFIER, '') <> ''
                or coalesce(ZSHAREDTOMEREMINDERCKIDENTIFIER, '') <> ''
              then 1 else 0
            end
          ) as assignment_count,
          sum(case when coalesce(ZCKASSIGNEEIDENTIFIER, '') <> '' then 1 else 0 end)
            as assignee_identifier_count
        from ZREMCDOBJECT
        \(predicate)
        group by relation, uti
        order by count desc, relation, uti
        limit 200;
        """
    )

    return rows.compactMap { row in
      guard let count = intValue(row["count"]) else {
        return nil
      }
      return RemindersPrivateObjectSummaryRecord(
        storePath: storePath,
        uti: emptyToNil(stringValue(row["uti"])),
        relation: stringValue(row["relation"]) ?? "unknown",
        count: count,
        urlCount: intValue(row["url_count"]) ?? 0,
        fileNameCount: intValue(row["file_name_count"]) ?? 0,
        assignmentCount: intValue(row["assignment_count"]) ?? 0,
        assigneeIdentifierCount: intValue(row["assignee_identifier_count"]) ?? 0
      )
    }
  }

  func privateObjectSummaryPredicate(scope: String) -> String {
    switch scope {
    case "attachments":
      return """
        where (
          coalesce(ZUTI, '') <> ''
          or coalesce(ZURL, '') <> ''
          or coalesce(ZFILENAME, '') <> ''
        )
        and not (
          coalesce(ZUTI, '') = 'public.url'
          and coalesce(ZURL, '') <> ''
          and coalesce(ZFILENAME, '') = ''
        )
        """
    case "assignments":
      return """
        where ZASSIGNEE is not null
           or ZASSIGNEDDATE is not null
           or coalesce(ZPERSONID, '') <> ''
           or coalesce(ZCONTACTLABEL, '') <> ''
           or coalesce(ZCKASSIGNEEIDENTIFIER, '') <> ''
           or coalesce(ZSHAREDTOMEREMINDERCKIDENTIFIER, '') <> ''
        """
    default:
      return ""
    }
  }
}
