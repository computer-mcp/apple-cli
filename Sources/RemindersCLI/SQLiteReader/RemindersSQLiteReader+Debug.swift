import Foundation
import Utility

extension RemindersSQLiteReader {
  public func debugStore(scope: String) throws -> RemindersStoreDebugResponse {
    let normalizedScope =
      scope.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      ? "summary"
      : scope.trimmingCharacters(in: .whitespacesAndNewlines)
    let supportedScopes: Set<String> = [
      "summary", "schema", "links", "attachments", "assignments", "lists", "reminders",
      "sections", "tags",
    ]
    guard supportedScopes.contains(normalizedScope) else {
      throw CLIError(
        code: .validationError,
        message:
          "`--scope` must be one of: summary, schema, links, attachments, assignments, lists, reminders, sections, tags."
      )
    }

    let container = remindersContainerURL
    let stores = remindersStoresURL
    let containerExists = directoryExists(container)
    let storesExists = directoryExists(stores)
    let files = storesExists ? sqliteStoreFiles(in: stores) : []
    var warnings: [String] = []
    if !containerExists {
      warnings.append("Reminders group container was not found.")
    }
    if containerExists, !storesExists {
      warnings.append("Reminders SQLite store directory was not found.")
    }
    if storesExists, files.isEmpty {
      warnings.append("No Reminders Data-*.sqlite store files were found.")
    }

    var schemaTables: [RemindersStoreSchemaTableRecord] = []
    var objectSummaries: [RemindersPrivateObjectSummaryRecord] = []
    var lists: [RemindersPrivateListDebugRecord] = []
    var reminders: [RemindersPrivateReminderDebugRecord] = []
    var sections: [RemindersPrivateSectionDebugRecord] = []
    var tags: [RemindersPrivateTagDebugRecord] = []

    for file in files where file.isReadable {
      do {
        switch normalizedScope {
        case "schema":
          schemaTables.append(contentsOf: try storeSchemaTables(storePath: file.path))
        case "links":
          objectSummaries.append(contentsOf: try privateObjectSummaries(storePath: file.path))
        case "attachments", "assignments":
          objectSummaries.append(
            contentsOf: try privateObjectSummaries(storePath: file.path, scope: normalizedScope)
          )
        case "lists":
          lists.append(contentsOf: try privateLists(storePath: file.path))
        case "reminders":
          reminders.append(contentsOf: try privateReminders(storePath: file.path))
        case "sections":
          sections.append(contentsOf: try privateSections(storePath: file.path))
        case "tags":
          tags.append(contentsOf: try privateTags(storePath: file.path))
        default:
          break
        }
      } catch {
        warnings.append("\(file.path): \(error)")
      }
    }

    return RemindersStoreDebugResponse(
      scope: normalizedScope,
      containerPath: container.path,
      storesPath: stores.path,
      containerExists: containerExists,
      storesDirectoryExists: storesExists,
      sqliteFiles: files,
      schemaTables: schemaTables,
      objectSummaries: objectSummaries,
      lists: lists,
      reminders: reminders,
      sections: sections,
      tags: tags,
      warnings: warnings
    )
  }

  public func debugItem(reminder: ReminderDetail) throws -> RemindersItemDebugResponse {
    let store = try debugStore(scope: "summary")
    var matches: [RemindersPrivateReminderDebugRecord] = []
    var warnings = store.warnings

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
              r.Z_PK as primary_key,
              coalesce(r.ZDACALENDARITEMUNIQUEIDENTIFIER, '') as calendar_item_id,
              coalesce(r.ZCKIDENTIFIER, '') as ck_identifier,
              coalesce(r.ZEXTERNALIDENTIFIER, '') as external_identifier,
              coalesce(r.ZTITLE, '') as title,
              r.ZLIST as list_primary_key,
              coalesce(l.ZCKIDENTIFIER, '') as list_identifier,
              coalesce(l.ZNAME, '') as list_title,
              coalesce(r.ZICSURL, '') as ics_url,
              r.ZFLAGGED as flagged,
              \(urgentExpression) as urgent,
              \(messagingContactHandlesExpression) as has_messaging_contact_handles,
              \(messagingContactHandlesLengthExpression) as messaging_contact_handles_length,
              r.ZCOMPLETED as completed
            from ZREMCDREMINDER r
            left join ZREMCDBASELIST l on l.Z_PK = r.ZLIST
            where r.ZDACALENDARITEMUNIQUEIDENTIFIER = \(sqliteStringLiteral(reminder.id))
               or r.ZCKIDENTIFIER = \(sqliteStringLiteral(reminder.id))
            order by r.Z_PK;
            """
        )

        for row in rows {
          guard let primaryKey = int64Value(row["primary_key"]) else {
            continue
          }
          let objects = try relatedObjects(storePath: file.path, reminderPrimaryKey: primaryKey)
          let section: ReminderPrivateSectionState?
          do {
            section = try sectionMembership(storePath: file.path, reminderPrimaryKey: primaryKey)
          } catch {
            section = nil
            warnings.append("\(file.path): \(error)")
          }
          let subtask: ReminderPrivateSubtaskState?
          do {
            subtask = try subtaskState(storePath: file.path, reminderPrimaryKey: primaryKey)
          } catch {
            subtask = nil
            warnings.append("\(file.path): \(error)")
          }
          matches.append(
            RemindersPrivateReminderDebugRecord(
              storePath: file.path,
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
              parentReminderId: subtask?.parentId,
              parentReminderTitle: subtask?.parentTitle,
              subtaskCount: subtask?.subtaskCount ?? 0,
              messagingContactHandles: messagingContactHandles(
                hasEvidence: boolValue(row["has_messaging_contact_handles"]) == true,
                lengthBytes: intValue(row["messaging_contact_handles_length"])
              ),
              relatedObjectCount: objects.count,
              objects: objects
            )
          )
        }
      } catch {
        warnings.append("\(file.path): \(error)")
      }
    }

    if matches.isEmpty {
      warnings.append(
        "No Reminders SQLite row matched the ReminderKit-compatible reminder identifier.")
    }

    let visibleURLObjects = matches.flatMap(\.objects).filter { object in
      object.uti == "public.url" && object.url != nil
    }
    let attachmentObjects = matches.flatMap(\.objects).filter { object in
      attachmentRecord(object) != nil
    }
    let assignmentObjects = matches.flatMap(\.objects).filter { object in
      assignmentRecord(object) != nil
    }
    let messagingContactHandles = matches.flatMap(\.messagingContactHandles)

    return RemindersItemDebugResponse(
      reminder: reminder,
      privateStoreMatches: matches,
      visibleURLObjects: visibleURLObjects,
      attachmentObjects: attachmentObjects,
      assignmentObjects: assignmentObjects,
      messagingContactHandles: messagingContactHandles,
      warnings: warnings
    )
  }

  public func debugList(list: ReminderListRecord) throws -> RemindersListDebugResponse {
    let store = try debugStore(scope: "summary")
    var matches: [RemindersPrivateListDebugRecord] = []
    var sections: [RemindersPrivateSectionDebugRecord] = []
    var warnings = store.warnings

    for file in store.sqliteFiles where file.isReadable {
      do {
        let listRows = try privateLists(storePath: file.path, list: list)
        let listPrimaryKeys = listRows.map(\.primaryKey)
        matches.append(contentsOf: listRows)

        if !listPrimaryKeys.isEmpty {
          sections.append(
            contentsOf: try privateSections(storePath: file.path, listPrimaryKeys: listPrimaryKeys)
          )
        }
      } catch {
        warnings.append("\(file.path): \(error)")
      }
    }

    if matches.isEmpty {
      warnings.append(
        "No Reminders SQLite list row matched the ReminderKit-compatible list identity.")
    }

    return RemindersListDebugResponse(
      list: list,
      privateStoreMatches: matches,
      sections: sections,
      warnings: warnings
    )
  }
}
