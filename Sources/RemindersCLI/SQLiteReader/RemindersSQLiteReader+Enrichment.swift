import Foundation
import Utility

extension RemindersSQLiteReader {
  public func listGroups() throws -> [ReminderListGroupRecord] {
    let debug = try debugStore(scope: "lists")
    return debug.lists
      .filter { $0.isGroup == true }
      .compactMap { row in
        guard let title = row.title ?? row.ckIdentifier ?? row.externalIdentifier else {
          return nil
        }
        let id = row.ckIdentifier ?? row.externalIdentifier ?? "private:\(row.primaryKey)"
        return ReminderListGroupRecord(
          id: id,
          title: title,
          childListCount: row.childListCount,
          childGroupCount: row.childGroupCount
        )
      }
      .sorted { lhs, rhs in
        lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
      }
  }

  public func enrichLists(_ lists: [ReminderListRecord]) throws -> [ReminderListRecord] {
    let store = try debugStore(scope: "summary")
    var statesByListID: [String: PrivateListState] = [:]
    var statesByTitle: [String: [PrivateListState]] = [:]
    var privateListRecords: [ReminderListRecord] = []

    for file in store.sqliteFiles where file.isReadable {
      do {
        let columns = try tableColumnNames(storePath: file.path, tableName: "ZREMCDBASELIST")
        let orderingIndexes = privateListOrderingIndexes(storePath: file.path)
        let notDeleted = privateListNotDeletedPredicate(columns: columns)
        let showingLargeAttachments = optionalSQLiteColumn(
          "ZSHOWINGLARGEATTACHMENTS",
          alias: "showing_large_attachments",
          columns: columns
        )
        let rows = try sqliteJSONRows(
          storePath: file.path,
          sql: """
            select
              Z_PK as primary_key,
              coalesce(ZCKIDENTIFIER, '') as ck_identifier,
              coalesce(ZEXTERNALIDENTIFIER, '') as external_identifier,
              coalesce(ZNAME, '') as title,
              coalesce(ZSMARTLISTTYPE, '') as smart_list_type,
              ZSHOULDCATEGORIZEGROCERYITEMS as should_categorize_grocery,
              ZISGROUP as is_group,
              ZISPINNEDBYCURRENTUSER as is_pinned,
              ZPINNEDDATE as pinned_date,
              ZDADISPLAYORDER as display_order,
              coalesce(ZSORTINGSTYLE, '') as sorting_style,
              \(showingLargeAttachments),
              case when ZCOLOR is not null and length(ZCOLOR) > 0 then 1 else 0 end as has_color,
              length(ZCOLOR) as color_length
            from ZREMCDBASELIST
            where \(notDeleted)
            order by Z_PK;
            """
        )
        for row in rows {
          guard let state = privateListState(row, orderingIndexes: orderingIndexes) else {
            continue
          }
          if let privateRecord = privateListRecord(row: row, storePath: file.path, state: state) {
            privateListRecords.append(privateRecord)
          }
          if let ckIdentifier = emptyToNil(stringValue(row["ck_identifier"])) {
            statesByListID[ckIdentifier] = state
          }
          if let externalIdentifier = emptyToNil(stringValue(row["external_identifier"])) {
            statesByListID[externalIdentifier] = state
          }
          if let title = emptyToNil(stringValue(row["title"])) {
            statesByTitle[title.lowercased(), default: []].append(state)
          }
        }
      } catch {
        continue
      }
    }

    var enrichedLists = lists.map { list in
      var enriched = list
      let titleStates = statesByTitle[list.title.lowercased()] ?? []
      let titleState = titleStates.count == 1 ? titleStates.first : nil
      if let state = statesByListID[list.id] ?? titleState {
        applyPrivateListState(state, to: &enriched)
      }
      return enriched
    }
    var existingIDs = Set(enrichedLists.map(\.id))
    var existingTitleTypes = Set(
      enrichedLists.map { "\($0.title.lowercased())|\($0.listType ?? "")" }
    )
    for privateRecord in privateListRecords {
      let titleType = "\(privateRecord.title.lowercased())|\(privateRecord.listType ?? "")"
      guard !existingIDs.contains(privateRecord.id), !existingTitleTypes.contains(titleType) else {
        continue
      }
      enrichedLists.append(privateRecord)
      existingIDs.insert(privateRecord.id)
      existingTitleTypes.insert(titleType)
    }
    return enrichedLists
  }

  public func enrichReminders(_ reminders: [ReminderSummary]) throws -> [ReminderSummary] {
    guard !reminders.isEmpty else {
      return reminders
    }

    let privateStates = try privateStateByReminderID(reminders.map(\.id))
    return reminders.map { reminder in
      var enriched = reminder
      if let privateState = privateStates[reminder.id] {
        enriched.tags = privateState.tags
        enriched.isFlagged = privateState.isFlagged
        enriched.isUrgent = privateState.isUrgent
        enriched.url = privateState.visibleURL ?? reminder.url
        enriched.sectionTitle = privateState.sectionTitle
        if let sectionTitle = privateState.sectionTitle,
          let sectionPrimaryKey = privateState.sectionPrimaryKey
        {
          enriched.sectionId = sectionID(
            listId: reminder.listId,
            title: sectionTitle,
            primaryKey: sectionPrimaryKey
          )
        } else {
          enriched.sectionId = privateState.sectionId
        }
        enriched.parentReminderId = privateState.parentReminderId
        enriched.parentReminderTitle = privateState.parentReminderTitle
        enriched.subtaskCount = privateState.subtaskCount
        enriched.attachments = privateState.attachments
        enriched.assignments = privateState.assignments
        enriched.messagingContactHandles = privateState.messagingContactHandles
        if let repeatRule = privateState.repeatRule {
          enriched.repeatRule = repeatRule
        }
      }
      return enriched
    }
  }

  public func enrichReminder(_ reminder: ReminderDetail) throws -> ReminderDetail {
    let privateStates = try privateStateByReminderID([reminder.id])
    var enriched = reminder
    if let privateState = privateStates[reminder.id] {
      enriched.tags = privateState.tags
      enriched.isFlagged = privateState.isFlagged
      enriched.isUrgent = privateState.isUrgent
      enriched.url = privateState.visibleURL ?? reminder.url
      enriched.sectionTitle = privateState.sectionTitle
      if let sectionTitle = privateState.sectionTitle,
        let sectionPrimaryKey = privateState.sectionPrimaryKey
      {
        enriched.sectionId = sectionID(
          listId: reminder.listId,
          title: sectionTitle,
          primaryKey: sectionPrimaryKey
        )
      } else {
        enriched.sectionId = privateState.sectionId
      }
      enriched.parentReminderId = privateState.parentReminderId
      enriched.parentReminderTitle = privateState.parentReminderTitle
      enriched.subtaskCount = privateState.subtaskCount
      enriched.attachments = privateState.attachments
      enriched.assignments = privateState.assignments
      enriched.messagingContactHandles = privateState.messagingContactHandles
      if let repeatRule = privateState.repeatRule {
        enriched.repeatRule = repeatRule
      }
    }
    return enriched
  }

  public func listSections(list: ReminderListRecord) throws -> [ReminderSectionRecord] {
    let store = try debugStore(scope: "summary")
    var sections: [ReminderSectionRecord] = []
    var queryErrors: [String] = []

    for file in store.sqliteFiles where file.isReadable {
      do {
        let rows = try sqliteJSONRows(
          storePath: file.path,
          sql: """
            select
              s.Z_PK as primary_key,
              coalesce(s.ZDISPLAYNAME, '') as title,
              coalesce(s.ZCKIDENTIFIER, '') as section_ck_identifier,
              coalesce(hex(s.ZIDENTIFIER), '') as section_identifier_hex,
              coalesce(cast(l.ZSECTIONIDSORDERINGASDATA as text), '') as section_ordering_json,
              coalesce(l.ZCKIDENTIFIER, '') as list_ck_identifier,
              coalesce(l.ZEXTERNALIDENTIFIER, '') as list_external_identifier,
              coalesce(l.ZNAME, '') as list_title
            from ZREMCDBASESECTION s
            join ZREMCDBASELIST l on l.Z_PK = s.ZLIST
            where (s.ZMARKEDFORDELETION is null or s.ZMARKEDFORDELETION = 0)
              and (
                l.ZCKIDENTIFIER = \(sqliteStringLiteral(list.id))
                or l.ZEXTERNALIDENTIFIER = \(sqliteStringLiteral(list.id))
                or l.ZNAME = \(sqliteStringLiteral(list.title))
              )
            order by s.Z_PK;
            """
        )
        let sectionRows = rows.compactMap { sectionRecordWithOrdering($0, list: list) }
        sections.append(contentsOf: orderedSectionRecords(sectionRows))
      } catch {
        queryErrors.append("\(file.path): \(error)")
      }
    }

    if sections.isEmpty, !queryErrors.isEmpty {
      throw CLIError(
        code: .backendUnavailable,
        message: "Read-only Reminders section query failed.",
        details: ["errors": queryErrors.joined(separator: "\n")]
      )
    }

    return deduplicateSections(sections)
  }

  public func listTags() throws -> [ReminderTagRecord] {
    let debug = try debugStore(scope: "tags")
    return debug.tags
      .compactMap(semanticTagRecord)
      .sorted {
        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
      }
  }

  public func reminderIDs(tagName: String) throws -> [String] {
    let tagName = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !tagName.isEmpty else {
      return []
    }

    let store = try debugStore(scope: "summary")
    var ids: Set<String> = []
    var errors: [Error] = []

    for file in store.sqliteFiles where file.isReadable {
      do {
        ids.formUnion(try privateReminderIDs(tagName: tagName, storePath: file.path))
      } catch {
        errors.append(error)
      }
    }

    if ids.isEmpty, let error = errors.first {
      throw error
    }

    return ids.sorted()
  }

  func semanticTagRecord(_ tag: RemindersPrivateTagDebugRecord) -> ReminderTagRecord? {
    guard let name = tag.name ?? tag.canonicalName else {
      return nil
    }
    let idPayload = [
      tag.storePath,
      tag.accountIdentifier ?? "",
      "\(tag.primaryKey)",
    ].joined(separator: "|")
    return ReminderTagRecord(
      id: "reminders-tag:\(sha256Hex(idPayload))",
      name: name,
      canonicalName: tag.canonicalName,
      relatedObjectCount: tag.relatedObjectCount,
      reminderReferenceCount: tag.reminderReferenceCount
    )
  }

  func privateStateByReminderID(_ ids: [String]) throws -> [String: ReminderPrivateState] {
    let ids = Array(Set(ids.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
      .sorted()
    guard !ids.isEmpty else {
      return [:]
    }

    let store = try debugStore(scope: "summary")
    let idList = ids.map(sqliteStringLiteral).joined(separator: ",")
    var statesByID: [String: ReminderPrivateState] = [:]

    for file in store.sqliteFiles where file.isReadable {
      do {
        let reminderColumns = try tableColumnNames(
          storePath: file.path, tableName: "ZREMCDREMINDER")
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
          storePath: file.path,
          sql: """
            select
              coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, '') as calendar_item_id,
              coalesce(r.ZCKIDENTIFIER, '') as ck_identifier,
              coalesce(r.ZEXTERNALIDENTIFIER, '') as external_identifier,
              r.ZFLAGGED as flagged,
              \(urgentExpression) as urgent,
              \(messagingContactHandlesExpression) as has_messaging_contact_handles,
              \(messagingContactHandlesLengthExpression) as messaging_contact_handles_length,
              coalesce(o.Z_PK, 0) as object_primary_key,
              coalesce(o.ZUTI, '') as object_uti,
              coalesce(o.ZURL, '') as object_url,
              coalesce(o.ZFILENAME, '') as object_file_name,
              coalesce(h.ZNAME, h.ZCANONICALNAME, '') as tag_name,
              o.ZASSIGNEDDATE as object_assigned_date,
              coalesce(o.ZPERSONID, '') as object_person_id,
              coalesce(o.ZCONTACTLABEL, '') as object_contact_label,
              coalesce(o.ZCKASSIGNEEIDENTIFIER, '') as object_assignee_identifier
            from ZREMCDREMINDER r
            left join ZREMCDOBJECT o on (
              (o.ZHASHTAGLABEL is not null
                or coalesce(o.ZUTI, '') <> ''
                or coalesce(o.ZURL, '') <> ''
                or coalesce(o.ZFILENAME, '') <> ''
                or o.ZASSIGNEE is not null
                or o.ZASSIGNEDDATE is not null
                or coalesce(o.ZPERSONID, '') <> ''
                or coalesce(o.ZCONTACTLABEL, '') <> ''
                or coalesce(o.ZCKASSIGNEEIDENTIFIER, '') <> '')
              and (
                r.Z_PK = o.ZREMINDER
                or r.Z_PK = o.ZREMINDER1
                or r.Z_PK = o.ZREMINDER2
                or r.Z_PK = o.ZREMINDER3
                or r.Z_PK = o.ZREMINDER4
                or r.Z_PK = o.ZREMINDER5
              )
            )
            left join ZREMCDHASHTAGLABEL h on h.Z_PK = o.ZHASHTAGLABEL
            where r.ZDACALENDARITEMUNIQUEIDENTIFIER in (\(idList))
               or r.ZCKIDENTIFIER in (\(idList))
               or r.ZEXTERNALIDENTIFIER in (\(idList))
            order by tag_name, object_primary_key;
            """
        )
        for row in rows {
          for key in [
            stringValue(row["calendar_item_id"]),
            stringValue(row["ck_identifier"]),
            stringValue(row["external_identifier"]),
          ].compactMap(emptyToNil) where ids.contains(key) {
            var state = statesByID[key] ?? ReminderPrivateState()
            if let flagged = boolValue(row["flagged"]) {
              state.isFlagged = flagged
            }
            if let urgent = boolValue(row["urgent"]) {
              state.isUrgent = urgent
            }
            if boolValue(row["has_messaging_contact_handles"]) == true {
              state.messagingContactHandles = [
                ReminderMessagingContactRecord(
                  lengthBytes: intValue(row["messaging_contact_handles_length"])
                )
              ]
            }
            if let tagName = emptyToNil(stringValue(row["tag_name"])) {
              state.tagSet.insert(tagName)
            }
            if stringValue(row["object_uti"]) == "public.url",
              let visibleURL = emptyToNil(stringValue(row["object_url"])),
              !state.visibleURLs.contains(visibleURL)
            {
              state.visibleURLs.append(visibleURL)
            }
            if let attachment = attachmentRecord(
              uti: emptyToNil(stringValue(row["object_uti"])),
              url: emptyToNil(stringValue(row["object_url"])),
              fileName: emptyToNil(stringValue(row["object_file_name"]))
            ), !state.attachments.contains(attachment) {
              state.attachments.append(attachment)
            }
            if let assignment = assignmentRecord(
              personId: emptyToNil(stringValue(row["object_person_id"])),
              contactLabel: emptyToNil(stringValue(row["object_contact_label"])),
              assigneeIdentifier: emptyToNil(stringValue(row["object_assignee_identifier"])),
              assignedAtRaw: doubleValue(row["object_assigned_date"])
            ), !state.assignments.contains(assignment) {
              state.assignments.append(assignment)
            }
            statesByID[key] = state
          }
        }
        do {
          try mergeSectionMemberships(
            storePath: file.path,
            idList: idList,
            ids: ids,
            statesByID: &statesByID
          )
        } catch {
          continue
        }
        do {
          try mergeSubtaskRelationships(
            storePath: file.path,
            idList: idList,
            ids: ids,
            statesByID: &statesByID
          )
        } catch {
          continue
        }
        do {
          try mergeHourlyRepeatRules(
            storePath: file.path,
            idList: idList,
            ids: ids,
            statesByID: &statesByID
          )
        } catch {
          continue
        }
      } catch {
        continue
      }
    }

    return statesByID.mapValues { $0.normalized() }
  }
}
