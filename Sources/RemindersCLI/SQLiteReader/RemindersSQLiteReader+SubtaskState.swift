import Foundation
import Utility

extension RemindersSQLiteReader {
  func subtaskState(
    storePath: String,
    reminderPrimaryKey: Int64
  ) throws -> ReminderPrivateSubtaskState {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          coalesce(
            nullif(parent.ZDACALENDARITEMUNIQUEIDENTIFIER, ''),
            nullif(parent.ZCKIDENTIFIER, ''),
            nullif(parent.ZEXTERNALIDENTIFIER, ''),
            nullif(r.ZCKPARENTREMINDERIDENTIFIER, ''),
            ''
          ) as parent_id,
          coalesce(parent.ZTITLE, '') as parent_title,
          (
            select count(*)
            from ZREMCDREMINDER child
            where child.ZPARENTREMINDER = r.Z_PK
               or (
                coalesce(child.ZCKPARENTREMINDERIDENTIFIER, '') <> ''
                and child.ZCKPARENTREMINDERIDENTIFIER in (
                  coalesce(r.ZCKIDENTIFIER, ''),
                  coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, ''),
                  coalesce(r.ZEXTERNALIDENTIFIER, '')
                )
              )
          ) as subtask_count
        from ZREMCDREMINDER r
        left join ZREMCDREMINDER parent on (
          parent.Z_PK = r.ZPARENTREMINDER
          or (
            coalesce(r.ZCKPARENTREMINDERIDENTIFIER, '') <> ''
            and (
              parent.ZCKIDENTIFIER = r.ZCKPARENTREMINDERIDENTIFIER
              or parent.ZDACALENDARITEMUNIQUEIDENTIFIER = r.ZCKPARENTREMINDERIDENTIFIER
              or parent.ZEXTERNALIDENTIFIER = r.ZCKPARENTREMINDERIDENTIFIER
            )
          )
        )
        where r.Z_PK = \(reminderPrimaryKey)
        limit 1;
        """
    )

    return rows.compactMap(subtaskState).first ?? ReminderPrivateSubtaskState()
  }

  func mergeSubtaskRelationships(
    storePath: String,
    idList: String,
    ids: [String],
    statesByID: inout [String: ReminderPrivateState]
  ) throws {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, '') as calendar_item_id,
          coalesce(r.ZCKIDENTIFIER, '') as ck_identifier,
          coalesce(r.ZEXTERNALIDENTIFIER, '') as external_identifier,
          coalesce(
            nullif(parent.ZDACALENDARITEMUNIQUEIDENTIFIER, ''),
            nullif(parent.ZCKIDENTIFIER, ''),
            nullif(parent.ZEXTERNALIDENTIFIER, ''),
            nullif(r.ZCKPARENTREMINDERIDENTIFIER, ''),
            ''
          ) as parent_id,
          coalesce(parent.ZTITLE, '') as parent_title,
          (
            select count(*)
            from ZREMCDREMINDER child
            where child.ZPARENTREMINDER = r.Z_PK
               or (
                coalesce(child.ZCKPARENTREMINDERIDENTIFIER, '') <> ''
                and child.ZCKPARENTREMINDERIDENTIFIER in (
                  coalesce(r.ZCKIDENTIFIER, ''),
                  coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, ''),
                  coalesce(r.ZEXTERNALIDENTIFIER, '')
                )
              )
          ) as subtask_count
        from ZREMCDREMINDER r
        left join ZREMCDREMINDER parent on (
          parent.Z_PK = r.ZPARENTREMINDER
          or (
            coalesce(r.ZCKPARENTREMINDERIDENTIFIER, '') <> ''
            and (
              parent.ZCKIDENTIFIER = r.ZCKPARENTREMINDERIDENTIFIER
              or parent.ZDACALENDARITEMUNIQUEIDENTIFIER = r.ZCKPARENTREMINDERIDENTIFIER
              or parent.ZEXTERNALIDENTIFIER = r.ZCKPARENTREMINDERIDENTIFIER
            )
          )
        )
        where r.ZDACALENDARITEMUNIQUEIDENTIFIER in (\(idList))
           or r.ZCKIDENTIFIER in (\(idList))
           or r.ZEXTERNALIDENTIFIER in (\(idList))
        order by r.Z_PK;
        """
    )

    for row in rows {
      let subtask = subtaskState(row)
      for key in [
        stringValue(row["calendar_item_id"]),
        stringValue(row["ck_identifier"]),
        stringValue(row["external_identifier"]),
      ].compactMap(emptyToNil) where ids.contains(key) {
        var state = statesByID[key] ?? ReminderPrivateState()
        state.parentReminderId = subtask.parentId
        state.parentReminderTitle = subtask.parentTitle
        state.subtaskCount = subtask.subtaskCount
        statesByID[key] = state
      }
    }
  }

  func subtaskState(_ row: [String: Any]) -> ReminderPrivateSubtaskState {
    ReminderPrivateSubtaskState(
      parentId: emptyToNil(stringValue(row["parent_id"])),
      parentTitle: emptyToNil(stringValue(row["parent_title"])),
      subtaskCount: intValue(row["subtask_count"]) ?? 0
    )
  }

  func mergeHourlyRepeatRules(
    storePath: String,
    idList: String,
    ids: [String],
    statesByID: inout [String: ReminderPrivateState]
  ) throws {
    let objectColumns = try tableColumnNames(storePath: storePath, tableName: "ZREMCDOBJECT")
    guard objectColumns.contains("ZFREQUENCY"),
      objectColumns.contains("ZINTERVAL"),
      objectColumns.contains("ZREMINDER4")
    else {
      return
    }

    let occurrenceCountExpression =
      objectColumns.contains("ZOCCURRENCECOUNT")
      ? "rr.ZOCCURRENCECOUNT"
      : "NULL"
    let endDateExpression =
      objectColumns.contains("ZENDDATE")
      ? "rr.ZENDDATE"
      : "NULL"
    let entityPredicate = objectColumns.contains("Z_ENT") ? "and rr.Z_ENT = 34" : ""
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, '') as calendar_item_id,
          coalesce(r.ZCKIDENTIFIER, '') as ck_identifier,
          coalesce(r.ZEXTERNALIDENTIFIER, '') as external_identifier,
          rr.ZFREQUENCY as repeat_frequency,
          rr.ZINTERVAL as repeat_interval,
          \(occurrenceCountExpression) as repeat_occurrence_count,
          \(endDateExpression) as repeat_end_date
        from ZREMCDREMINDER r
        join ZREMCDOBJECT rr on rr.ZREMINDER4 = r.Z_PK
        where (
            r.ZDACALENDARITEMUNIQUEIDENTIFIER in (\(idList))
            or r.ZCKIDENTIFIER in (\(idList))
            or r.ZEXTERNALIDENTIFIER in (\(idList))
          )
          and (rr.ZMARKEDFORDELETION is null or rr.ZMARKEDFORDELETION = 0)
          \(entityPredicate)
          and rr.ZFREQUENCY = 4
        order by rr.Z_PK;
        """
    )

    for row in rows {
      guard let repeatRule = hourlyRepeatRule(row) else {
        continue
      }
      for key in [
        stringValue(row["calendar_item_id"]),
        stringValue(row["ck_identifier"]),
        stringValue(row["external_identifier"]),
      ].compactMap(emptyToNil) where ids.contains(key) {
        var state = statesByID[key] ?? ReminderPrivateState()
        state.repeatRule = repeatRule
        statesByID[key] = state
      }
    }
  }

  func hourlyRepeatRule(_ row: [String: Any]) -> ReminderRepeatRule? {
    guard intValue(row["repeat_frequency"]) == 4 else {
      return nil
    }
    let interval = max(intValue(row["repeat_interval"]) ?? 1, 1)
    let occurrenceCount = intValue(row["repeat_occurrence_count"]).flatMap { count in
      count > 0 ? count : nil
    }
    let until = doubleValue(row["repeat_end_date"]).map {
      Date(timeIntervalSinceReferenceDate: $0)
    }
    return ReminderRepeatRule(
      frequency: "hourly",
      interval: interval,
      occurrenceCount: occurrenceCount,
      until: until
    )
  }
}
