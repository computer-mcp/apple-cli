import Foundation
import Utility

extension RemindersSQLiteReader {
  func templateItemIDs(templateID: String, limit: Int) throws -> [String] {
    guard let templateUUID = UUID(uuidString: URL(string: templateID)?.lastPathComponent ?? ""),
      limit > 0
    else {
      throw CLIError(code: .validationError, message: "Template item lookup requires valid identities and a positive limit.")
    }
    let files = sqliteStoreFiles(in: remindersStoresURL)
    guard !files.isEmpty, files.allSatisfy(\.isReadable) else {
      throw CLIError(code: .backendUnavailable, message: "The Reminders template item index is unavailable.")
    }
    let templateHex = templateUUID.uuidString.replacingOccurrences(of: "-", with: "")
    var matches: [(path: String, key: Int64)] = []
    for file in files {
      let rows = try sqliteJSONRows(storePath: file.path, sql: """
        select t.Z_PK as template_key
        from ZREMCDTEMPLATE t
        where t.ZIDENTIFIER = X'\(templateHex)'
          and t.ZMARKEDFORDELETION = 0
        limit 2;
        """)
      for row in rows {
        guard let key = int64Value(row["template_key"]) else {
          throw CLIError(code: .backendUnavailable, message: "The Reminders template item index has an invalid identity.")
        }
        matches.append((file.path, key))
      }
    }
    guard matches.count == 1, let match = matches.first else {
      throw CLIError(code: .backendUnavailable,
        message: "The Reminders template item index could not identify the selected template uniquely.",
        details: ["template_id": templateID, "match_count": String(matches.count)])
    }
    let rows = try sqliteJSONRows(storePath: match.path, sql: """
      select hex(ZIDENTIFIER) as identifier
      from ZREMCDSAVEDREMINDER
      where ZTEMPLATE = \(match.key) and ZMARKEDFORDELETION = 0
      order by Z_PK
      limit \(limit);
      """)
    let ids = try rows.map { row -> String in
      guard let identifier = uuidStringFromSQLiteHex(stringValue(row["identifier"])),
        let uuid = UUID(uuidString: identifier)
      else {
        throw CLIError(code: .backendUnavailable, message: "The Reminders template item index has an invalid item identity.")
      }
      return uuid.uuidString
    }
    guard Set(ids).count == ids.count else {
      throw CLIError(code: .backendUnavailable, message: "The Reminders template item index has duplicate item identities.")
    }
    return ids
  }

  func privateReminders(storePath: String) throws -> [RemindersPrivateReminderDebugRecord] {
    let reminderColumns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDREMINDER")
    let urgentExpression =
      reminderColumns.contains("ZISURGENTSTATEENABLEDFORCURRENTUSER")
      ? "r.ZISURGENTSTATEENABLEDFORCURRENTUSER"
      : "NULL"
    let messagingContactHandlesExpression =
      reminderColumns.contains("ZCONTACTHANDLES")
      ? "case when r.ZCONTACTHANDLES is not null and length(r.ZCONTACTHANDLES) > 0 then 1 else 0 end"
      : "0"
    let messagingContactHandlesLengthExpression =
      reminderColumns.contains("ZCONTACTHANDLES")
      ? "length(r.ZCONTACTHANDLES)"
      : "NULL"
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          r.Z_PK as primary_key,
          coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, '') as calendar_item_id,
          coalesce(r.ZCKIDENTIFIER, '') as ck_identifier,
          coalesce(r.ZEXTERNALIDENTIFIER, '') as external_identifier,
          coalesce(r.ZTITLE, '') as title,
          r.ZLIST as list_primary_key,
          coalesce(l.ZCKIDENTIFIER, l.ZEXTERNALIDENTIFIER, '') as list_identifier,
          coalesce(l.ZNAME, '') as list_title,
          coalesce(r.ZICSURL, '') as ics_url,
          r.ZFLAGGED as flagged,
          \(urgentExpression) as urgent,
          \(messagingContactHandlesExpression) as has_messaging_contact_handles,
          \(messagingContactHandlesLengthExpression) as messaging_contact_handles_length,
          r.ZCOMPLETED as completed,
          (
            select count(*)
            from ZREMCDOBJECT o
            where o.ZREMINDER = r.Z_PK
               or o.ZREMINDER1 = r.Z_PK
               or o.ZREMINDER2 = r.Z_PK
               or o.ZREMINDER3 = r.Z_PK
               or o.ZREMINDER4 = r.Z_PK
               or o.ZREMINDER5 = r.Z_PK
          ) as related_object_count
        from ZREMCDREMINDER r
        left join ZREMCDBASELIST l on l.Z_PK = r.ZLIST
        order by r.Z_PK
        limit 500;
        """
    )

    return rows.compactMap { row in
      guard let primaryKey = int64Value(row["primary_key"]) else {
        return nil
      }
      let section =
        (try? sectionMembership(storePath: storePath, reminderPrimaryKey: primaryKey)) ?? nil
      let subtask = try? subtaskState(storePath: storePath, reminderPrimaryKey: primaryKey)
      return RemindersPrivateReminderDebugRecord(
        storePath: storePath,
        primaryKey: primaryKey,
        calendarItemIdentifier: emptyToNil(stringValue(row["calendar_item_id"])),
        ckIdentifier: emptyToNil(stringValue(row["ck_identifier"])),
        externalIdentifier: emptyToNil(stringValue(row["external_identifier"])),
        title: emptyToNil(stringValue(row["title"])),
        listPrimaryKey: int64Value(row["list_primary_key"]),
        listIdentifier: emptyToNil(stringValue(row["list_identifier"])),
        listTitle: emptyToNil(stringValue(row["list_title"])),
        icsURL: emptyToNil(stringValue(row["ics_url"])),
        flagged: boolValue(row["flagged"]),
        isUrgent: boolValue(row["urgent"]),
        completed: boolValue(row["completed"]),
        sectionId: section?.id,
        sectionTitle: section?.title,
        subtaskRelationshipAvailable: subtask != nil,
        parentReminderId: subtask?.parentId,
        parentReminderTitle: subtask?.parentTitle,
        subtaskCount: subtask?.subtaskCount ?? 0,
        messagingContactHandles: messagingContactHandles(
          hasEvidence: boolValue(row["has_messaging_contact_handles"]) == true,
          lengthBytes: intValue(row["messaging_contact_handles_length"])
        ),
        relatedObjectCount: intValue(row["related_object_count"]) ?? 0,
        objects: []
      )
    }
  }
}
