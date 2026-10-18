import CryptoKit
import Dispatch
import Foundation
import Utility

func listsHumanOutput(_ lists: [ReminderListRecord]) -> String {
  lists
    .map {
      let fields: [String] = [
        $0.id,
        $0.title,
        $0.sourceTitle,
        $0.listType ?? "-",
        $0.smartListType ?? "-",
        $0.isPinned.map(String.init) ?? "-",
        $0.displayOrder.map(String.init) ?? "-",
        $0.sortingStyle ?? "-",
        $0.showingLargeAttachments.map(String.init) ?? "-",
        $0.color ?? "-",
        $0.hasColor.map(String.init) ?? "-",
      ]
      return fields.joined(separator: "\t")
    }
    .joined(separator: "\n")
}

func reminderListGroupsHumanOutput(_ groups: [ReminderListGroupRecord]) -> String {
  groups
    .map {
      [
        $0.id,
        $0.title,
        "\($0.childListCount)",
        "\($0.childGroupCount)",
      ].joined(separator: "\t")
    }
    .joined(separator: "\n")
}

func reminderListIconsHumanOutput(_ icons: [ReminderListIconRecord]) -> String {
  icons
    .map {
      [
        $0.token,
        $0.category,
        $0.assetName,
        $0.kind,
      ].joined(separator: "\t")
    }
    .joined(separator: "\n")
}

func reminderTemplatesHumanOutput(_ templates: [ReminderTemplateRecord]) -> String {
  templates
    .map {
      [
        $0.id,
        $0.title,
        $0.sourceTitle,
        $0.sourceListTitle ?? "-",
        $0.sortingStyle ?? "-",
        $0.showingLargeAttachments.map(String.init) ?? "-",
        $0.color ?? "-",
        $0.hasColor.map(String.init) ?? "-",
      ].joined(separator: "\t")
    }
    .joined(separator: "\n")
}

func reminderTemplateSectionsHumanOutput(_ sections: [ReminderTemplateSectionRecord]) -> String {
  sections
    .map {
      [
        $0.id,
        $0.templateTitle,
        $0.title,
      ].joined(separator: "\t")
    }
    .joined(separator: "\n")
}

func reminderTemplateItemHumanOutput(_ item: ReminderTemplateItemRecord) -> String {
  [
    "id: \(item.id)",
    "title: \(item.title)",
    "template: \(item.templateId)",
    "notes: \(item.notes ?? "-")",
    "url: \(item.url ?? "-")",
    "priority: \(item.priority)",
    "due: \(item.dueDate ?? "-")",
    "repeat: \(reminderRepeatSummary(item.repeatRule))",
    "location: \(reminderLocationSummary(item.locationTriggers.first))",
    "early_reminder_minutes_before: \(minuteList(item.earlyReminderMinutesBefore))",
    "alarm_at: \(dateList(item.absoluteAlarmDates))",
    "tags: \(item.tags.joined(separator: ", "))",
    "flagged: \(item.isFlagged.map(String.init) ?? "-")",
    "urgent: \(item.isUrgent.map(String.init) ?? "-")",
    "section: \(item.sectionTitle ?? "-")",
    "parent: \(item.parentReminderTitle ?? "-")",
    "subtasks: \(item.subtaskCount)",
    "attachments: \(reminderAttachmentSummary(item.attachments))",
  ].joined(separator: "\n")
}

func reminderSectionsHumanOutput(_ sections: [ReminderSectionRecord]) -> String {
  sections
    .map { "\($0.id)\t\($0.listTitle)\t\($0.title)" }
    .joined(separator: "\n")
}

func reminderTagsHumanOutput(_ tags: [ReminderTagRecord]) -> String {
  tags
    .map {
      [
        $0.id,
        $0.name,
        $0.canonicalName ?? "-",
        "\($0.relatedObjectCount)",
        "\($0.reminderReferenceCount)",
      ].joined(separator: "\t")
    }
    .joined(separator: "\n")
}

func remindersHumanOutput(_ reminders: [ReminderSummary]) -> String {
  reminders
    .map {
      "\($0.id)\t\($0.dueDate ?? "-")\t\($0.title)"
        + "\tcreated=\($0.createdAt ?? "-")"
        + "\tmodified=\($0.modifiedAt ?? "-")"
        + "\tsection=\($0.sectionTitle ?? "-")"
        + "\tparent=\($0.parentReminderTitle ?? "-")"
        + "\tsubtasks=\($0.subtaskCount)"
        + "\tattachments=\($0.attachments.count)"
        + "\tassignments=\($0.assignments.count)"
        + "\tflagged=\($0.isFlagged.map(String.init) ?? "-")"
        + "\turgent=\($0.isUrgent.map(String.init) ?? "-")"
        + "\tearly=\($0.earlyReminderMinutesBefore.isEmpty ? "-" : minuteList($0.earlyReminderMinutesBefore))"
        + "\talarms=\($0.absoluteAlarmDates.isEmpty ? "-" : dateList($0.absoluteAlarmDates))"
        + "\ttags=\($0.tags.isEmpty ? "-" : $0.tags.joined(separator: ","))"
    }
    .joined(separator: "\n")
}

func reminderHumanOutput(_ reminder: ReminderDetail) -> String {
  let repeatSummary = reminderRepeatSummary(reminder.repeatRule)
  let locationSummary = reminderLocationSummary(reminder.locationTriggers)
  return [
    "id: \(reminder.id)",
    "title: \(reminder.title)",
    "list: \(reminder.listTitle)",
    "completed: \(reminder.isCompleted)",
    "created: \(reminder.createdAt ?? "-")",
    "modified: \(reminder.modifiedAt ?? "-")",
    "url: \(reminder.url ?? "-")",
    "due: \(reminder.dueDate ?? "-")",
    "section: \(reminder.sectionTitle ?? "-")",
    "parent: \(reminder.parentReminderTitle ?? "-")",
    "subtasks: \(reminder.subtaskCount)",
    "attachments: \(reminderAttachmentSummary(reminder.attachments))",
    "assignments: \(reminderAssignmentSummary(reminder.assignments))",
    "location: \(locationSummary.isEmpty ? "-" : locationSummary)",
    "early reminders: \(reminder.earlyReminderMinutesBefore.isEmpty ? "-" : minuteList(reminder.earlyReminderMinutesBefore))",
    "alarms: \(reminder.absoluteAlarmDates.isEmpty ? "-" : dateList(reminder.absoluteAlarmDates))",
    "repeat: \(repeatSummary.isEmpty ? "-" : repeatSummary)",
    "flagged: \(reminder.isFlagged.map(String.init) ?? "-")",
    "urgent: \(reminder.isUrgent.map(String.init) ?? "-")",
    "tags: \(reminder.tags.isEmpty ? "-" : reminder.tags.joined(separator: ","))",
  ].joined(separator: "\n")
}

func reminderAttachmentSummary(_ attachments: [ReminderAttachmentRecord]) -> String {
  guard !attachments.isEmpty else {
    return "-"
  }
  return attachments.map { attachment in
    [
      attachment.kind,
      attachment.fileName ?? attachment.url ?? attachment.typeIdentifier ?? "-",
    ].joined(separator: ":")
  }.joined(separator: ",")
}

func reminderAssignmentSummary(_ assignments: [ReminderAssignmentRecord]) -> String {
  guard !assignments.isEmpty else {
    return "-"
  }
  let summaries = assignments.map { assignment in
    [
      assignment.assigneeIdentifier ?? "",
      assignment.personId ?? "",
      assignment.contactLabel ?? "",
      assignment.assignedAtRaw.map { String(describing: $0) } ?? "",
    ].filter { !$0.isEmpty }.joined(separator: ":")
  }
  return summaries.joined(separator: ",")
}
func remindersStoreDebugHumanOutput(_ debug: RemindersStoreDebugResponse) -> String {
  var lines = [
    "scope: \(debug.scope)",
    "container: \(debug.containerExists ? "present" : "missing") \(debug.containerPath)",
    "stores: \(debug.storesDirectoryExists ? "present" : "missing") \(debug.storesPath)",
    "sqlite files: \(debug.sqliteFiles.count)",
  ]
  lines.append(
    contentsOf: debug.sqliteFiles.map {
      "\($0.isReadable ? "readable" : "unreadable")\t\($0.sizeBytes)\t\($0.path)"
    })
  if !debug.schemaTables.isEmpty {
    lines.append("schema tables:")
    lines.append(
      contentsOf: debug.schemaTables.map {
        "\($0.tableName)\tcolumns=\($0.columnCount)\t\($0.storePath)"
      })
  }
  if !debug.objectSummaries.isEmpty {
    lines.append("object summaries:")
    lines.append(
      contentsOf: debug.objectSummaries.map {
        "\($0.relation)\tuti=\($0.uti ?? "-")"
          + "\tcount=\($0.count)\turls=\($0.urlCount)\tfiles=\($0.fileNameCount)"
          + "\tassignments=\($0.assignmentCount)"
          + "\tassigneeIds=\($0.assigneeIdentifierCount)\t\($0.storePath)"
      })
  }
  if !debug.lists.isEmpty {
    lines.append("lists:")
    lines.append(
      contentsOf: debug.lists.map {
        "pk=\($0.primaryKey)\tid=\($0.ckIdentifier ?? $0.externalIdentifier ?? "-")"
          + "\ttitle=\($0.title ?? "-")\ttype=\($0.listType ?? "-")"
          + "\tparent=\($0.parentListTitle ?? $0.parentListIdentifier ?? "-")"
          + "\tparentIsGroup=\($0.parentListIsGroup.map(String.init) ?? "-")"
          + "\tchildLists=\($0.childListCount)\tchildGroups=\($0.childGroupCount)"
          + "\tsmart=\($0.smartListType ?? "-")\tpinned=\($0.isPinned.map(String.init) ?? "-")"
          + "\torder=\($0.displayOrder.map(String.init) ?? "-")"
          + "\tsort=\($0.sortingStyle ?? "-")"
          + "\tlargeAttachments=\($0.showingLargeAttachments.map(String.init) ?? "-")"
          + "\tcolor=\($0.hasColor.map(String.init) ?? "-")"
          + "\tautoCategory=\($0.shouldAutoCategorizeItems.map(String.init) ?? "-")"
          + "\tgrocery=\($0.shouldCategorizeGroceryItems.map(String.init) ?? "-")"
          + "\tgrocerySuggest=\($0.shouldSuggestConversionToGroceryList.map(String.init) ?? "-")"
          + "\tgroceryLocale=\($0.groceryLocaleIdentifier ?? "-")"
          + "\tgroceryCached=\($0.cachedGroceryItemsCount.map(String.init) ?? "-")"
          + "\tfilterBytes=\($0.filterDataLengthBytes.map(String.init) ?? "-")"
          + "\tautoCorrectionBytes=\($0.autoCategorizationLocalCorrectionsLengthBytes.map(String.init) ?? "-")"
          + "\tgroceryMembershipBytes=\($0.grocerySectionMembershipsLengthBytes.map(String.init) ?? "-")"
      })
  }
  if !debug.reminders.isEmpty {
    lines.append("reminders:")
    lines.append(
      contentsOf: debug.reminders.map {
        "pk=\($0.primaryKey)\tid=\($0.calendarItemIdentifier ?? $0.ckIdentifier ?? $0.externalIdentifier ?? "-")"
          + "\ttitle=\($0.title ?? "-")\tlist=\($0.listTitle ?? $0.listIdentifier ?? "-")"
          + "\tcompleted=\($0.completed.map(String.init) ?? "-")"
          + "\tflagged=\($0.flagged.map(String.init) ?? "-")"
          + "\tsection=\($0.sectionTitle ?? "-")"
          + "\tparent=\($0.parentReminderTitle ?? "-")"
          + "\tsubtasks=\($0.subtaskCount)\tobjects=\($0.relatedObjectCount)"
      })
  }
  if !debug.sections.isEmpty {
    lines.append("sections:")
    lines.append(
      contentsOf: debug.sections.map {
        "pk=\($0.primaryKey)\tlist=\($0.listPrimaryKey.map(String.init) ?? "-")"
          + "\tlistId=\($0.listIdentifier ?? "-")\tlistTitle=\($0.listTitle ?? "-")"
          + "\tlistType=\($0.listType ?? "-")"
          + "\tgrocery=\($0.listShouldCategorizeGroceryItems.map(String.init) ?? "-")"
          + "\tdeleted=\($0.markedForDeletion.map(String.init) ?? "-")"
          + "\t\($0.displayName ?? "-")"
      })
  }
  if !debug.tags.isEmpty {
    lines.append("tags:")
    lines.append(
      contentsOf: debug.tags.map {
        "pk=\($0.primaryKey)\tname=\($0.name ?? "-")\tcanonical=\($0.canonicalName ?? "-")"
          + "\tobjects=\($0.relatedObjectCount)\treminderRefs=\($0.reminderReferenceCount)"
      })
  }
  if !debug.warnings.isEmpty {
    lines.append("warnings:")
    lines.append(contentsOf: debug.warnings.map { "- \($0)" })
  }
  return lines.joined(separator: "\n")
}

func remindersItemDebugHumanOutput(_ debug: RemindersItemDebugResponse) -> String {
  var lines = [
    "id: \(debug.reminder.id)",
    "title: \(debug.reminder.title)",
    "reminder_url: \(debug.reminder.url ?? "-")",
    "private_store_matches: \(debug.privateStoreMatches.count)",
    "visible_url_objects: \(debug.visibleURLObjects.count)",
    "attachment_objects: \(debug.attachmentObjects.count)",
    "assignment_objects: \(debug.assignmentObjects.count)",
  ]
  for match in debug.privateStoreMatches {
    lines.append(
      "store_match: pk=\(match.primaryKey) section=\(match.sectionTitle ?? "-") parent=\(match.parentReminderTitle ?? "-") subtasks=\(match.subtaskCount) objects=\(match.relatedObjectCount) ics_url=\(match.icsURL ?? "-") \(match.storePath)"
    )
    for object in match.objects {
      lines.append(
        "object: pk=\(object.primaryKey) relation=\(object.relation) uti=\(object.uti ?? "-") url=\(object.url ?? "-") file=\(object.fileName ?? "-") tag=\(object.tagName ?? object.tagCanonicalName ?? "-")"
      )
    }
  }
  if !debug.warnings.isEmpty {
    lines.append("warnings:")
    lines.append(contentsOf: debug.warnings.map { "- \($0)" })
  }
  return lines.joined(separator: "\n")
}

func remindersListDebugHumanOutput(_ debug: RemindersListDebugResponse) -> String {
  var lines = [
    "id: \(debug.list.id)",
    "title: \(debug.list.title)",
    "list_type: \(debug.list.listType ?? "-")",
    "smart_list_type: \(debug.list.smartListType ?? "-")",
    "pinned: \(debug.list.isPinned.map(String.init) ?? "-")",
    "display_order: \(debug.list.displayOrder.map(String.init) ?? "-")",
    "sorting_style: \(debug.list.sortingStyle ?? "-")",
    "show_large_attachments: \(debug.list.showingLargeAttachments.map(String.init) ?? "-")",
    "has_color: \(debug.list.hasColor.map(String.init) ?? "-")",
    "private_store_matches: \(debug.privateStoreMatches.count)",
    "sections: \(debug.sections.count)",
  ]
  for match in debug.privateStoreMatches {
    lines.append(
      "store_match: pk=\(match.primaryKey) type=\(match.listType ?? "-") parent=\(match.parentListTitle ?? match.parentListIdentifier ?? "-") parentIsGroup=\(match.parentListIsGroup.map(String.init) ?? "-") childLists=\(match.childListCount) childGroups=\(match.childGroupCount) pinned=\(match.isPinned.map(String.init) ?? "-") order=\(match.displayOrder.map(String.init) ?? "-") sort=\(match.sortingStyle ?? "-") largeAttachments=\(match.showingLargeAttachments.map(String.init) ?? "-") colorBytes=\(match.colorLengthBytes.map(String.init) ?? "-") grocery=\(match.shouldCategorizeGroceryItems.map(String.init) ?? "-") smart=\(match.smartListType ?? "-") title=\(match.title ?? "-") \(match.storePath)"
    )
    lines.append(
      "list_diagnostics: autoCategory=\(match.shouldAutoCategorizeItems.map(String.init) ?? "-") grocerySuggest=\(match.shouldSuggestConversionToGroceryList.map(String.init) ?? "-") groceryLocale=\(match.groceryLocaleIdentifier ?? "-") groceryCached=\(match.cachedGroceryItemsCount.map(String.init) ?? "-") filterBytes=\(match.filterDataLengthBytes.map(String.init) ?? "-") autoCorrectionBytes=\(match.autoCategorizationLocalCorrectionsLengthBytes.map(String.init) ?? "-") groceryMembershipBytes=\(match.grocerySectionMembershipsLengthBytes.map(String.init) ?? "-")"
    )
  }
  for section in debug.sections {
    lines.append(
      "section: pk=\(section.primaryKey) list=\(section.listPrimaryKey.map(String.init) ?? "-") listId=\(section.listIdentifier ?? "-") listTitle=\(section.listTitle ?? "-") listType=\(section.listType ?? "-") grocery=\(section.listShouldCategorizeGroceryItems.map(String.init) ?? "-") deleted=\(section.markedForDeletion.map(String.init) ?? "-") title=\(section.displayName ?? "-")"
    )
  }
  if !debug.warnings.isEmpty {
    lines.append("warnings:")
    lines.append(contentsOf: debug.warnings.map { "- \($0)" })
  }
  return lines.joined(separator: "\n")
}

func formatDate(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}
