import Foundation

public struct ReminderListRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var sourceId: String
  public var sourceTitle: String
  public var allowsContentModifications: Bool
  public var listType: String?
  public var smartListType: String?
  public var isPinned: Bool?
  public var displayOrder: Int?
  public var sortingStyle: String?
  public var showingLargeAttachments: Bool?
  public var color: String?
  public var hasColor: Bool?

  public init(
    id: String,
    title: String,
    sourceId: String = "",
    sourceTitle: String,
    allowsContentModifications: Bool,
    listType: String? = nil,
    smartListType: String? = nil,
    isPinned: Bool? = nil,
    displayOrder: Int? = nil,
    sortingStyle: String? = nil,
    showingLargeAttachments: Bool? = nil,
    color: String? = nil,
    hasColor: Bool? = nil
  ) {
    self.id = id
    self.title = title
    self.sourceId = sourceId
    self.sourceTitle = sourceTitle
    self.allowsContentModifications = allowsContentModifications
    self.listType = listType
    self.smartListType = smartListType
    self.isPinned = isPinned
    self.displayOrder = displayOrder
    self.sortingStyle = sortingStyle
    self.showingLargeAttachments = showingLargeAttachments
    self.color = color
    self.hasColor = hasColor
  }
}

public struct ReminderListSourceRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var sourceType: String
  public var reminderListCount: Int

  public init(id: String, title: String, sourceType: String, reminderListCount: Int) {
    self.id = id
    self.title = title
    self.sourceType = sourceType
    self.reminderListCount = reminderListCount
  }
}
public struct ReminderListsResponse: Codable, Equatable, Sendable {
  public var lists: [ReminderListRecord]
}

public struct ReminderListIconRecord: Codable, Equatable, Sendable {
  public var token: String
  public var assetName: String
  public var category: String
  public var kind: String

  public init(token: String, assetName: String, category: String, kind: String = "symbol") {
    self.token = token
    self.assetName = assetName
    self.category = category
    self.kind = kind
  }
}

public struct ReminderListIconsResponse: Codable, Equatable, Sendable {
  public var icons: [ReminderListIconRecord]
}

public struct ReminderListGroupRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var childListCount: Int
  public var childGroupCount: Int

  public init(
    id: String,
    title: String,
    childListCount: Int = 0,
    childGroupCount: Int = 0
  ) {
    self.id = id
    self.title = title
    self.childListCount = childListCount
    self.childGroupCount = childGroupCount
  }
}

public struct ReminderListGroupsResponse: Codable, Equatable, Sendable {
  public var groups: [ReminderListGroupRecord]
}

public struct ReminderTemplateRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var sourceId: String
  public var sourceTitle: String
  public var sourceListId: String?
  public var sourceListTitle: String?
  public var sortingStyle: String?
  public var showingLargeAttachments: Bool?
  public var color: String?
  public var hasColor: Bool?

  public init(
    id: String,
    title: String,
    sourceId: String,
    sourceTitle: String,
    sourceListId: String? = nil,
    sourceListTitle: String? = nil,
    sortingStyle: String? = nil,
    showingLargeAttachments: Bool? = nil,
    color: String? = nil,
    hasColor: Bool? = nil
  ) {
    self.id = id
    self.title = title
    self.sourceId = sourceId
    self.sourceTitle = sourceTitle
    self.sourceListId = sourceListId
    self.sourceListTitle = sourceListTitle
    self.sortingStyle = sortingStyle
    self.showingLargeAttachments = showingLargeAttachments
    self.color = color
    self.hasColor = hasColor
  }
}

public struct ReminderTemplatesResponse: Codable, Equatable, Sendable {
  public var templates: [ReminderTemplateRecord]
}

public struct ReminderTemplateSectionRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var templateId: String
  public var templateTitle: String

  public init(
    id: String,
    title: String,
    templateId: String,
    templateTitle: String
  ) {
    self.id = id
    self.title = title
    self.templateId = templateId
    self.templateTitle = templateTitle
  }
}

public struct ReminderTemplateSectionsResponse: Codable, Equatable, Sendable {
  public var sections: [ReminderTemplateSectionRecord]
}

public struct ReminderTemplateItemResponse: Codable, Equatable, Sendable {
  public var item: ReminderTemplateItemRecord
}

public struct ReminderTemplateItemsResponse: Codable, Equatable, Sendable {
  public var items: [ReminderTemplateItemRecord]
}

public struct ReminderTemplateItemRecord: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var notes: String?
  public var templateId: String
  public var url: String?
  public var priority: Int
  public var dueDate: String?
  public var dueDateKind: String?
  public var repeatRule: ReminderRepeatRule?
  public var locationTriggers: [ReminderLocationTrigger]
  public var earlyReminderMinutesBefore: [Int]
  public var absoluteAlarmDates: [Date]
  public var tags: [String]
  public var isFlagged: Bool?
  public var isUrgent: Bool?
  public var sectionId: String?
  public var sectionTitle: String?
  public var parentReminderId: String?
  public var parentReminderTitle: String?
  public var subtaskCount: Int
  public var attachments: [ReminderAttachmentRecord]

  public init(
    id: String,
    title: String,
    notes: String? = nil,
    templateId: String,
    url: String? = nil,
    priority: Int = 0,
    dueDate: String? = nil,
    dueDateKind: String? = nil,
    repeatRule: ReminderRepeatRule? = nil,
    locationTriggers: [ReminderLocationTrigger] = [],
    earlyReminderMinutesBefore: [Int] = [],
    absoluteAlarmDates: [Date] = [],
    tags: [String] = [],
    isFlagged: Bool? = nil,
    isUrgent: Bool? = nil,
    sectionId: String? = nil,
    sectionTitle: String? = nil,
    parentReminderId: String? = nil,
    parentReminderTitle: String? = nil,
    subtaskCount: Int = 0,
    attachments: [ReminderAttachmentRecord] = []
  ) {
    self.id = id
    self.title = title
    self.notes = notes
    self.templateId = templateId
    self.url = url
    self.priority = priority
    self.dueDate = dueDate
    self.dueDateKind = dueDateKind
    self.repeatRule = repeatRule
    self.locationTriggers = locationTriggers
    self.earlyReminderMinutesBefore = earlyReminderMinutesBefore
    self.absoluteAlarmDates = absoluteAlarmDates
    self.tags = tags
    self.isFlagged = isFlagged
    self.isUrgent = isUrgent
    self.sectionId = sectionId
    self.sectionTitle = sectionTitle
    self.parentReminderId = parentReminderId
    self.parentReminderTitle = parentReminderTitle
    self.subtaskCount = subtaskCount
    self.attachments = attachments
  }
}

public struct ReminderListMutationIdentity: Equatable, Sendable {
  public var list: ReminderListRecord
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderListGroupMutationIdentity: Equatable, Sendable {
  public var group: ReminderListGroupRecord
  public var groups: [ReminderListGroupRecord]
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderListGroupCreateIdentity: Equatable, Sendable {
  public var title: String
  public var groups: [ReminderListGroupRecord]
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderListGroupMoveIdentity: Equatable, Sendable {
  public var list: ReminderListRecord
  public var group: ReminderListGroupRecord?
  public var currentGroup: ReminderListGroupRecord?
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderSmartListCriteria: Codable, Equatable, Sendable {
  public var match: String
  public var descriptor: String

  public init(match: String, descriptor: String) {
    self.match = match
    self.descriptor = descriptor
  }
}

public struct ReminderSmartListCreateIdentity: Equatable, Sendable {
  public var title: String
  public var source: ReminderListSourceRecord
  public var criteria: ReminderSmartListCriteria
  public var sourceListHash: String
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderSmartListMutationIdentity: Equatable, Sendable {
  public var list: ReminderListRecord
  public var criteria: ReminderSmartListCriteria?
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderTemplatePatch: Codable, Equatable, Sendable {
  public var title: String?
  public var color: String?
  public var icon: String?
  public var sortingStyle: String?
  public var showingLargeAttachments: Bool?
  public var replacementSourceListId: String?
  public var includeCompleted: Bool?

  public init(
    title: String? = nil,
    color: String? = nil,
    icon: String? = nil,
    sortingStyle: String? = nil,
    showingLargeAttachments: Bool? = nil,
    replacementSourceListId: String? = nil,
    includeCompleted: Bool? = nil
  ) {
    self.title = title
    self.color = color
    self.icon = icon
    self.sortingStyle = sortingStyle
    self.showingLargeAttachments = showingLargeAttachments
    self.replacementSourceListId = replacementSourceListId
    self.includeCompleted = includeCompleted
  }

  public var hasChanges: Bool {
    title != nil || color != nil || icon != nil || sortingStyle != nil
      || showingLargeAttachments != nil || replacementSourceListId != nil
  }
}

public struct ReminderTemplateSaveIdentity: Equatable, Sendable {
  public var sourceList: ReminderListRecord
  public var title: String
  public var includeCompleted: Bool
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderTemplateCreateListIdentity: Equatable, Sendable {
  public var template: ReminderTemplateRecord
  public var title: String
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderTemplateMutationIdentity: Equatable, Sendable {
  public var template: ReminderTemplateRecord
  public var patch: ReminderTemplatePatch
  public var sourceList: ReminderListRecord?
  public var scopeDigest: String
  public var summaryFields: [String: String]
}

public struct ReminderListPatch: Codable, Equatable, Sendable {
  public var title: String?
  public var listType: String?
  public var color: String?
  public var icon: String?
  public var pinned: Bool?
  public var sortingStyle: String?
  public var showingLargeAttachments: Bool?

  public init(
    title: String? = nil,
    listType: String? = nil,
    color: String? = nil,
    icon: String? = nil,
    pinned: Bool? = nil,
    sortingStyle: String? = nil,
    showingLargeAttachments: Bool? = nil
  ) {
    self.title = title
    self.listType = listType
    self.color = color
    self.icon = icon
    self.pinned = pinned
    self.sortingStyle = sortingStyle
    self.showingLargeAttachments = showingLargeAttachments
  }

  public var hasChanges: Bool {
    title != nil || listType != nil || color != nil || icon != nil || pinned != nil
      || sortingStyle != nil || showingLargeAttachments != nil
  }

  public var requiresReadOnlyVerification: Bool {
    listType != nil || color != nil || pinned != nil || sortingStyle != nil
      || showingLargeAttachments != nil
  }
}

public struct ReminderListMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var list: ReminderListRecord?
  public var group: ReminderListGroupRecord?

  public init(
    operation: String,
    changed: Bool,
    list: ReminderListRecord? = nil,
    group: ReminderListGroupRecord? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.list = list
    self.group = group
  }
}

public struct ReminderTemplateMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var template: ReminderTemplateRecord?
  public var list: ReminderListRecord?
  public var section: ReminderTemplateSectionRecord?
  public var item: ReminderTemplateItemRecord?

  public init(
    operation: String,
    changed: Bool,
    template: ReminderTemplateRecord? = nil,
    list: ReminderListRecord? = nil,
    section: ReminderTemplateSectionRecord? = nil,
    item: ReminderTemplateItemRecord? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.template = template
    self.list = list
    self.section = section
    self.item = item
  }
}

public struct ReminderSmartListMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var list: ReminderListRecord
  public var criteria: ReminderSmartListCriteria?

  public init(
    operation: String,
    changed: Bool,
    list: ReminderListRecord,
    criteria: ReminderSmartListCriteria? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.list = list
    self.criteria = criteria
  }
}

public struct ReminderListReorderPlacement: Codable, Equatable, Sendable {
  public var beforeListId: String?
  public var afterListId: String?

  public init(beforeListId: String? = nil, afterListId: String? = nil) {
    self.beforeListId = beforeListId
    self.afterListId = afterListId
  }

  public var anchorListId: String? {
    beforeListId ?? afterListId
  }

  public var relation: String {
    beforeListId != nil ? "before" : "after"
  }
}

public struct ReminderListReorderResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var list: ReminderListRecord
  public var anchorList: ReminderListRecord
  public var placement: ReminderListReorderPlacement

  public init(
    operation: String,
    changed: Bool,
    list: ReminderListRecord,
    anchorList: ReminderListRecord,
    placement: ReminderListReorderPlacement
  ) {
    self.operation = operation
    self.changed = changed
    self.list = list
    self.anchorList = anchorList
    self.placement = placement
  }
}

public struct ReminderListDeleteResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var deletedListID: String
  public var deletedListTitle: String
  public var deletedReminderCount: Int

  public init(
    operation: String,
    changed: Bool,
    deletedListID: String,
    deletedListTitle: String,
    deletedReminderCount: Int
  ) {
    self.operation = operation
    self.changed = changed
    self.deletedListID = deletedListID
    self.deletedListTitle = deletedListTitle
    self.deletedReminderCount = deletedReminderCount
  }
}
