import Foundation
import Utility

extension RemindersSQLiteReader {
  func relatedObjects(
    storePath: String,
    reminderPrimaryKey: Int64
  ) throws -> [RemindersPrivateObjectDebugRecord] {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        select
          o.Z_PK as primary_key,
          case
            when o.ZREMINDER = \(reminderPrimaryKey) then 'reminder'
            when o.ZREMINDER1 = \(reminderPrimaryKey) then 'reminder1'
            when o.ZREMINDER2 = \(reminderPrimaryKey) then 'reminder2'
            when o.ZREMINDER3 = \(reminderPrimaryKey) then 'reminder3'
            when o.ZREMINDER4 = \(reminderPrimaryKey) then 'reminder4'
            when o.ZREMINDER5 = \(reminderPrimaryKey) then 'reminder5'
            else 'unknown'
          end as relation,
          coalesce(o.ZUTI, '') as uti,
          coalesce(o.ZURL, '') as url,
          coalesce(o.ZFILENAME, '') as file_name,
          coalesce(h.ZNAME, '') as tag_name,
          coalesce(h.ZCANONICALNAME, '') as tag_canonical_name,
          o.ZASSIGNEE as assignee_primary_key,
          o.ZASSIGNEDDATE as assigned_date,
          coalesce(o.ZPERSONID, '') as person_id,
          coalesce(o.ZCONTACTLABEL, '') as contact_label,
          coalesce(o.ZCKASSIGNEEIDENTIFIER, '') as assignee_identifier,
          coalesce(o.ZSHAREDTOMEREMINDERCKIDENTIFIER, '') as shared_to_me_identifier
        from ZREMCDOBJECT o
        left join ZREMCDHASHTAGLABEL h on h.Z_PK = o.ZHASHTAGLABEL
        where o.ZREMINDER = \(reminderPrimaryKey)
           or o.ZREMINDER1 = \(reminderPrimaryKey)
           or o.ZREMINDER2 = \(reminderPrimaryKey)
           or o.ZREMINDER3 = \(reminderPrimaryKey)
           or o.ZREMINDER4 = \(reminderPrimaryKey)
           or o.ZREMINDER5 = \(reminderPrimaryKey)
        order by o.Z_PK;
        """
    )

    return rows.compactMap { row in
      guard let primaryKey = int64Value(row["primary_key"]) else {
        return nil
      }
      return RemindersPrivateObjectDebugRecord(
        storePath: storePath,
        primaryKey: primaryKey,
        relation: stringValue(row["relation"]) ?? "unknown",
        uti: emptyToNil(stringValue(row["uti"])),
        url: emptyToNil(stringValue(row["url"])),
        fileName: emptyToNil(stringValue(row["file_name"])),
        tagName: emptyToNil(stringValue(row["tag_name"])),
        tagCanonicalName: emptyToNil(stringValue(row["tag_canonical_name"])),
        assigneePrimaryKey: int64Value(row["assignee_primary_key"]),
        assignedAtRaw: doubleValue(row["assigned_date"]),
        personId: emptyToNil(stringValue(row["person_id"])),
        contactLabel: emptyToNil(stringValue(row["contact_label"])),
        assigneeIdentifier: emptyToNil(stringValue(row["assignee_identifier"])),
        sharedToMeReminderIdentifier: emptyToNil(stringValue(row["shared_to_me_identifier"]))
      )
    }
  }

  func sectionRecord(
    _ row: [String: Any],
    list: ReminderListRecord
  ) -> ReminderSectionRecord? {
    guard
      let primaryKey = int64Value(row["primary_key"]),
      let title = emptyToNil(stringValue(row["title"]))
    else {
      return nil
    }

    return ReminderSectionRecord(
      id: sectionID(listId: list.id, title: title, primaryKey: primaryKey),
      listId: list.id,
      listTitle: list.title,
      title: title
    )
  }

  func sectionRecordWithOrdering(
    _ row: [String: Any],
    list: ReminderListRecord
  ) -> PrivateSectionOrderingCandidate? {
    guard
      let primaryKey = int64Value(row["primary_key"]),
      let record = sectionRecord(row, list: list)
    else {
      return nil
    }

    let sectionIdentifier =
      emptyToNil(stringValue(row["section_ck_identifier"]))
      ?? uuidStringFromSQLiteHex(stringValue(row["section_identifier_hex"]))
    return PrivateSectionOrderingCandidate(
      record: record,
      sectionIdentifier: sectionIdentifier,
      orderingIdentifiers: sectionOrderingIdentifiers(
        stringValue(row["section_ordering_json"])
      ),
      fallbackPrimaryKey: primaryKey
    )
  }

  func orderedSectionRecords(
    _ sections: [PrivateSectionOrderingCandidate]
  ) -> [ReminderSectionRecord] {
    guard
      let orderingIdentifiers = sections.first(where: { !$0.orderingIdentifiers.isEmpty })?
        .orderingIdentifiers
    else {
      return sections.sorted { $0.fallbackPrimaryKey < $1.fallbackPrimaryKey }.map(\.record)
    }

    let orderingIndex = Dictionary(
      uniqueKeysWithValues: orderingIdentifiers.enumerated().map {
        (normalizedIdentifier($0.element), $0.offset)
      }
    )

    return sections.sorted { lhs, rhs in
      let lhsIndex = lhs.sectionIdentifier.map { orderingIndex[normalizedIdentifier($0)] } ?? nil
      let rhsIndex = rhs.sectionIdentifier.map { orderingIndex[normalizedIdentifier($0)] } ?? nil
      switch (lhsIndex, rhsIndex) {
      case (let lhs?, let rhs?) where lhs != rhs:
        return lhs < rhs
      case (_?, nil):
        return true
      case (nil, _?):
        return false
      default:
        return lhs.fallbackPrimaryKey < rhs.fallbackPrimaryKey
      }
    }.map(\.record)
  }

  func sectionOrderingIdentifiers(_ json: String?) -> [String] {
    guard let json = emptyToNil(json),
      let data = json.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let identifiers = object["orderedIdentifiers"] as? [String]
    else {
      return []
    }
    return identifiers
  }

  func sectionID(listId: String, title: String, primaryKey: Int64) -> String {
    let idPayload = [
      listId,
      title,
      "\(primaryKey)",
    ].joined(separator: "|")

    return "section-\(String(sha256Hex(idPayload).prefix(12)))"
  }

  func sectionMembership(
    storePath: String,
    reminderPrimaryKey: Int64
  ) throws -> ReminderPrivateSectionState? {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        with list_memberships as (
          select
            Z_PK as list_primary_key,
            coalesce(
              nullif(ZCKIDENTIFIER, ''),
              nullif(ZEXTERNALIDENTIFIER, ''),
              nullif(ZNAME, ''),
              ''
            ) as list_identifier,
            cast(ZMEMBERSHIPSOFREMINDERSINSECTIONSASDATA as text) as membership_json
          from ZREMCDBASELIST
          where ZMEMBERSHIPSOFREMINDERSINSECTIONSASDATA is not null
            and (ZMARKEDFORDELETION is null or ZMARKEDFORDELETION = 0)
            and json_valid(cast(ZMEMBERSHIPSOFREMINDERSINSECTIONSASDATA as text))
        )
        select
          s.Z_PK as section_primary_key,
          coalesce(s.ZDISPLAYNAME, '') as section_title,
          coalesce(l.list_identifier, '') as list_identifier,
          l.list_primary_key as list_primary_key
        from ZREMCDREMINDER r
        join list_memberships l on l.list_primary_key = r.ZLIST
        join json_each(l.membership_json, '$.memberships') membership
        join ZREMCDBASESECTION s on s.ZLIST = l.list_primary_key
          and (
            s.ZCKIDENTIFIER = json_extract(membership.value, '$.groupID')
            or s.ZIDENTIFIER = json_extract(membership.value, '$.groupID')
            or s.ZCANONICALNAME = json_extract(membership.value, '$.groupID')
            or s.ZEXTERNALIDENTIFIER = json_extract(membership.value, '$.groupID')
          )
        where r.Z_PK = \(reminderPrimaryKey)
          and (
            r.ZCKIDENTIFIER = json_extract(membership.value, '$.memberID')
            or r.ZDACALENDARITEMUNIQUEIDENTIFIER = json_extract(membership.value, '$.memberID')
            or r.ZEXTERNALIDENTIFIER = json_extract(membership.value, '$.memberID')
          )
          and (s.ZMARKEDFORDELETION is null or s.ZMARKEDFORDELETION = 0)
        order by section_primary_key
        limit 1;
        """
    )

    return rows.compactMap(sectionState).first
  }

  func mergeSectionMemberships(
    storePath: String,
    idList: String,
    ids: [String],
    statesByID: inout [String: ReminderPrivateState]
  ) throws {
    let rows = try sqliteJSONRows(
      storePath: storePath,
      sql: """
        with list_memberships as (
          select
            Z_PK as list_primary_key,
            coalesce(
              nullif(ZCKIDENTIFIER, ''),
              nullif(ZEXTERNALIDENTIFIER, ''),
              nullif(ZNAME, ''),
              ''
            ) as list_identifier,
            cast(ZMEMBERSHIPSOFREMINDERSINSECTIONSASDATA as text) as membership_json
          from ZREMCDBASELIST
          where ZMEMBERSHIPSOFREMINDERSINSECTIONSASDATA is not null
            and (ZMARKEDFORDELETION is null or ZMARKEDFORDELETION = 0)
            and json_valid(cast(ZMEMBERSHIPSOFREMINDERSINSECTIONSASDATA as text))
        )
        select
          coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, '') as calendar_item_id,
          coalesce(r.ZCKIDENTIFIER, '') as ck_identifier,
          coalesce(r.ZEXTERNALIDENTIFIER, '') as external_identifier,
          s.Z_PK as section_primary_key,
          coalesce(s.ZDISPLAYNAME, '') as section_title,
          coalesce(l.list_identifier, '') as list_identifier,
          l.list_primary_key as list_primary_key
        from ZREMCDREMINDER r
        join list_memberships l on l.list_primary_key = r.ZLIST
        join json_each(l.membership_json, '$.memberships') membership
        join ZREMCDBASESECTION s on s.ZLIST = l.list_primary_key
          and (
            s.ZCKIDENTIFIER = json_extract(membership.value, '$.groupID')
            or s.ZIDENTIFIER = json_extract(membership.value, '$.groupID')
            or s.ZCANONICALNAME = json_extract(membership.value, '$.groupID')
            or s.ZEXTERNALIDENTIFIER = json_extract(membership.value, '$.groupID')
          )
        where (
            r.ZDACALENDARITEMUNIQUEIDENTIFIER in (\(idList))
            or r.ZCKIDENTIFIER in (\(idList))
            or r.ZEXTERNALIDENTIFIER in (\(idList))
          )
          and (
            r.ZCKIDENTIFIER = json_extract(membership.value, '$.memberID')
            or r.ZDACALENDARITEMUNIQUEIDENTIFIER = json_extract(membership.value, '$.memberID')
            or r.ZEXTERNALIDENTIFIER = json_extract(membership.value, '$.memberID')
          )
          and (s.ZMARKEDFORDELETION is null or s.ZMARKEDFORDELETION = 0)
        order by section_primary_key;
        """
    )

    for row in rows {
      guard let section = sectionState(row) else {
        continue
      }
      for key in [
        stringValue(row["calendar_item_id"]),
        stringValue(row["ck_identifier"]),
        stringValue(row["external_identifier"]),
      ].compactMap(emptyToNil) where ids.contains(key) {
        var state = statesByID[key] ?? ReminderPrivateState()
        state.sectionId = section.id
        state.sectionTitle = section.title
        state.sectionPrimaryKey = section.primaryKey
        statesByID[key] = state
      }
    }
  }

  func sectionState(_ row: [String: Any]) -> ReminderPrivateSectionState? {
    guard
      let primaryKey = int64Value(row["section_primary_key"]),
      let title = emptyToNil(stringValue(row["section_title"]))
    else {
      return nil
    }

    let listIdentifier =
      emptyToNil(stringValue(row["list_identifier"]))
      ?? int64Value(row["list_primary_key"]).map { "list-\($0)" }
      ?? "list"
    return ReminderPrivateSectionState(
      id: sectionID(listId: listIdentifier, title: title, primaryKey: primaryKey),
      primaryKey: primaryKey,
      title: title
    )
  }
}
