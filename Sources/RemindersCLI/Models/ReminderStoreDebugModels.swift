import Foundation

public struct RemindersStoreFileRecord: Codable, Equatable, Sendable {
  public var path: String
  public var sizeBytes: Int64
  public var isReadable: Bool

  public init(path: String, sizeBytes: Int64, isReadable: Bool) {
    self.path = path
    self.sizeBytes = sizeBytes
    self.isReadable = isReadable
  }
}

public struct RemindersStoreSchemaTableRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var tableName: String
  public var columnCount: Int
  public var columns: [String]

  public init(storePath: String, tableName: String, columnCount: Int, columns: [String]) {
    self.storePath = storePath
    self.tableName = tableName
    self.columnCount = columnCount
    self.columns = columns
  }
}

public struct RemindersPrivateObjectSummaryRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var uti: String?
  public var relation: String
  public var count: Int
  public var urlCount: Int
  public var fileNameCount: Int
  public var assignmentCount: Int
  public var assigneeIdentifierCount: Int

  public init(
    storePath: String,
    uti: String? = nil,
    relation: String,
    count: Int,
    urlCount: Int,
    fileNameCount: Int,
    assignmentCount: Int = 0,
    assigneeIdentifierCount: Int = 0
  ) {
    self.storePath = storePath
    self.uti = uti
    self.relation = relation
    self.count = count
    self.urlCount = urlCount
    self.fileNameCount = fileNameCount
    self.assignmentCount = assignmentCount
    self.assigneeIdentifierCount = assigneeIdentifierCount
  }
}

public struct RemindersPrivateSectionDebugRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var primaryKey: Int64
  public var displayName: String?
  public var listPrimaryKey: Int64?
  public var listIdentifier: String?
  public var listTitle: String?
  public var listType: String?
  public var listSmartListType: String?
  public var listShouldCategorizeGroceryItems: Bool?
  public var markedForDeletion: Bool?

  public init(
    storePath: String,
    primaryKey: Int64,
    displayName: String? = nil,
    listPrimaryKey: Int64? = nil,
    listIdentifier: String? = nil,
    listTitle: String? = nil,
    listType: String? = nil,
    listSmartListType: String? = nil,
    listShouldCategorizeGroceryItems: Bool? = nil,
    markedForDeletion: Bool? = nil
  ) {
    self.storePath = storePath
    self.primaryKey = primaryKey
    self.displayName = displayName
    self.listPrimaryKey = listPrimaryKey
    self.listIdentifier = listIdentifier
    self.listTitle = listTitle
    self.listType = listType
    self.listSmartListType = listSmartListType
    self.listShouldCategorizeGroceryItems = listShouldCategorizeGroceryItems
    self.markedForDeletion = markedForDeletion
  }
}

public struct RemindersPrivateTagDebugRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var primaryKey: Int64
  public var name: String?
  public var canonicalName: String?
  public var accountIdentifier: String?
  public var relatedObjectCount: Int
  public var reminderReferenceCount: Int

  public init(
    storePath: String,
    primaryKey: Int64,
    name: String? = nil,
    canonicalName: String? = nil,
    accountIdentifier: String? = nil,
    relatedObjectCount: Int = 0,
    reminderReferenceCount: Int = 0
  ) {
    self.storePath = storePath
    self.primaryKey = primaryKey
    self.name = name
    self.canonicalName = canonicalName
    self.accountIdentifier = accountIdentifier
    self.relatedObjectCount = relatedObjectCount
    self.reminderReferenceCount = reminderReferenceCount
  }
}
public struct RemindersPrivateListDebugRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var primaryKey: Int64
  public var ckIdentifier: String?
  public var externalIdentifier: String?
  public var title: String?
  public var smartListType: String?
  public var shouldAutoCategorizeItems: Bool?
  public var shouldCategorizeGroceryItems: Bool?
  public var shouldSuggestConversionToGroceryList: Bool?
  public var groceryLocaleIdentifier: String?
  public var cachedGroceryItemsCount: Int?
  public var isGroup: Bool?
  public var parentListPrimaryKey: Int64?
  public var parentListIdentifier: String?
  public var parentListTitle: String?
  public var parentListIsGroup: Bool?
  public var childListCount: Int
  public var childGroupCount: Int
  public var listType: String?
  public var isPinned: Bool?
  public var pinnedDateRaw: Double?
  public var displayOrder: Int?
  public var sortingStyle: String?
  public var showingLargeAttachments: Bool?
  public var hasColor: Bool?
  public var colorLengthBytes: Int?
  public var filterDataLengthBytes: Int?
  public var autoCategorizationLocalCorrectionsLengthBytes: Int?
  public var grocerySectionMembershipsLengthBytes: Int?

  public init(
    storePath: String,
    primaryKey: Int64,
    ckIdentifier: String? = nil,
    externalIdentifier: String? = nil,
    title: String? = nil,
    smartListType: String? = nil,
    shouldAutoCategorizeItems: Bool? = nil,
    shouldCategorizeGroceryItems: Bool? = nil,
    shouldSuggestConversionToGroceryList: Bool? = nil,
    groceryLocaleIdentifier: String? = nil,
    cachedGroceryItemsCount: Int? = nil,
    isGroup: Bool? = nil,
    parentListPrimaryKey: Int64? = nil,
    parentListIdentifier: String? = nil,
    parentListTitle: String? = nil,
    parentListIsGroup: Bool? = nil,
    childListCount: Int = 0,
    childGroupCount: Int = 0,
    listType: String? = nil,
    isPinned: Bool? = nil,
    pinnedDateRaw: Double? = nil,
    displayOrder: Int? = nil,
    sortingStyle: String? = nil,
    showingLargeAttachments: Bool? = nil,
    hasColor: Bool? = nil,
    colorLengthBytes: Int? = nil,
    filterDataLengthBytes: Int? = nil,
    autoCategorizationLocalCorrectionsLengthBytes: Int? = nil,
    grocerySectionMembershipsLengthBytes: Int? = nil
  ) {
    self.storePath = storePath
    self.primaryKey = primaryKey
    self.ckIdentifier = ckIdentifier
    self.externalIdentifier = externalIdentifier
    self.title = title
    self.smartListType = smartListType
    self.shouldAutoCategorizeItems = shouldAutoCategorizeItems
    self.shouldCategorizeGroceryItems = shouldCategorizeGroceryItems
    self.shouldSuggestConversionToGroceryList = shouldSuggestConversionToGroceryList
    self.groceryLocaleIdentifier = groceryLocaleIdentifier
    self.cachedGroceryItemsCount = cachedGroceryItemsCount
    self.isGroup = isGroup
    self.parentListPrimaryKey = parentListPrimaryKey
    self.parentListIdentifier = parentListIdentifier
    self.parentListTitle = parentListTitle
    self.parentListIsGroup = parentListIsGroup
    self.childListCount = childListCount
    self.childGroupCount = childGroupCount
    self.listType = listType
    self.isPinned = isPinned
    self.pinnedDateRaw = pinnedDateRaw
    self.displayOrder = displayOrder
    self.sortingStyle = sortingStyle
    self.showingLargeAttachments = showingLargeAttachments
    self.hasColor = hasColor
    self.colorLengthBytes = colorLengthBytes
    self.filterDataLengthBytes = filterDataLengthBytes
    self.autoCategorizationLocalCorrectionsLengthBytes =
      autoCategorizationLocalCorrectionsLengthBytes
    self.grocerySectionMembershipsLengthBytes = grocerySectionMembershipsLengthBytes
  }
}

public struct RemindersStoreDebugResponse: Codable, Equatable, Sendable {
  public var scope: String
  public var containerPath: String
  public var storesPath: String
  public var containerExists: Bool
  public var storesDirectoryExists: Bool
  public var sqliteFiles: [RemindersStoreFileRecord]
  public var schemaTables: [RemindersStoreSchemaTableRecord]
  public var objectSummaries: [RemindersPrivateObjectSummaryRecord]
  public var lists: [RemindersPrivateListDebugRecord]
  public var reminders: [RemindersPrivateReminderDebugRecord]
  public var sections: [RemindersPrivateSectionDebugRecord]
  public var tags: [RemindersPrivateTagDebugRecord]
  public var warnings: [String]

  public init(
    scope: String,
    containerPath: String,
    storesPath: String,
    containerExists: Bool,
    storesDirectoryExists: Bool,
    sqliteFiles: [RemindersStoreFileRecord],
    schemaTables: [RemindersStoreSchemaTableRecord] = [],
    objectSummaries: [RemindersPrivateObjectSummaryRecord] = [],
    lists: [RemindersPrivateListDebugRecord] = [],
    reminders: [RemindersPrivateReminderDebugRecord] = [],
    sections: [RemindersPrivateSectionDebugRecord] = [],
    tags: [RemindersPrivateTagDebugRecord] = [],
    warnings: [String] = []
  ) {
    self.scope = scope
    self.containerPath = containerPath
    self.storesPath = storesPath
    self.containerExists = containerExists
    self.storesDirectoryExists = storesDirectoryExists
    self.sqliteFiles = sqliteFiles
    self.schemaTables = schemaTables
    self.objectSummaries = objectSummaries
    self.lists = lists
    self.reminders = reminders
    self.sections = sections
    self.tags = tags
    self.warnings = warnings
  }
}

public struct RemindersListDebugResponse: Codable, Equatable, Sendable {
  public var list: ReminderListRecord
  public var privateStoreMatches: [RemindersPrivateListDebugRecord]
  public var sections: [RemindersPrivateSectionDebugRecord]
  public var warnings: [String]

  public init(
    list: ReminderListRecord,
    privateStoreMatches: [RemindersPrivateListDebugRecord],
    sections: [RemindersPrivateSectionDebugRecord],
    warnings: [String] = []
  ) {
    self.list = list
    self.privateStoreMatches = privateStoreMatches
    self.sections = sections
    self.warnings = warnings
  }
}

public struct RemindersPrivateObjectDebugRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var primaryKey: Int64
  public var relation: String
  public var uti: String?
  public var url: String?
  public var fileName: String?
  public var tagName: String?
  public var tagCanonicalName: String?
  public var assigneePrimaryKey: Int64?
  public var assignedAtRaw: Double?
  public var personId: String?
  public var contactLabel: String?
  public var assigneeIdentifier: String?
  public var sharedToMeReminderIdentifier: String?

  public init(
    storePath: String,
    primaryKey: Int64,
    relation: String,
    uti: String? = nil,
    url: String? = nil,
    fileName: String? = nil,
    tagName: String? = nil,
    tagCanonicalName: String? = nil,
    assigneePrimaryKey: Int64? = nil,
    assignedAtRaw: Double? = nil,
    personId: String? = nil,
    contactLabel: String? = nil,
    assigneeIdentifier: String? = nil,
    sharedToMeReminderIdentifier: String? = nil
  ) {
    self.storePath = storePath
    self.primaryKey = primaryKey
    self.relation = relation
    self.uti = uti
    self.url = url
    self.fileName = fileName
    self.tagName = tagName
    self.tagCanonicalName = tagCanonicalName
    self.assigneePrimaryKey = assigneePrimaryKey
    self.assignedAtRaw = assignedAtRaw
    self.personId = personId
    self.contactLabel = contactLabel
    self.assigneeIdentifier = assigneeIdentifier
    self.sharedToMeReminderIdentifier = sharedToMeReminderIdentifier
  }
}

public struct RemindersPrivateReminderDebugRecord: Codable, Equatable, Sendable {
  public var storePath: String
  public var primaryKey: Int64
  public var calendarItemIdentifier: String?
  public var ckIdentifier: String?
  public var externalIdentifier: String?
  public var title: String?
  public var listPrimaryKey: Int64?
  public var listIdentifier: String?
  public var listTitle: String?
  public var icsURL: String?
  public var flagged: Bool?
  public var isUrgent: Bool?
  public var completed: Bool?
  public var sectionId: String?
  public var sectionTitle: String?
  public var parentReminderId: String?
  public var parentReminderTitle: String?
  public var subtaskCount: Int
  public var messagingContactHandles: [ReminderMessagingContactRecord]
  public var relatedObjectCount: Int
  public var objects: [RemindersPrivateObjectDebugRecord]

  public init(
    storePath: String,
    primaryKey: Int64,
    calendarItemIdentifier: String? = nil,
    ckIdentifier: String? = nil,
    externalIdentifier: String? = nil,
    title: String? = nil,
    listPrimaryKey: Int64? = nil,
    listIdentifier: String? = nil,
    listTitle: String? = nil,
    icsURL: String? = nil,
    flagged: Bool? = nil,
    isUrgent: Bool? = nil,
    completed: Bool? = nil,
    sectionId: String? = nil,
    sectionTitle: String? = nil,
    parentReminderId: String? = nil,
    parentReminderTitle: String? = nil,
    subtaskCount: Int = 0,
    messagingContactHandles: [ReminderMessagingContactRecord] = [],
    relatedObjectCount: Int,
    objects: [RemindersPrivateObjectDebugRecord]
  ) {
    self.storePath = storePath
    self.primaryKey = primaryKey
    self.calendarItemIdentifier = calendarItemIdentifier
    self.ckIdentifier = ckIdentifier
    self.externalIdentifier = externalIdentifier
    self.title = title
    self.listPrimaryKey = listPrimaryKey
    self.listIdentifier = listIdentifier
    self.listTitle = listTitle
    self.icsURL = icsURL
    self.flagged = flagged
    self.isUrgent = isUrgent
    self.completed = completed
    self.sectionId = sectionId
    self.sectionTitle = sectionTitle
    self.parentReminderId = parentReminderId
    self.parentReminderTitle = parentReminderTitle
    self.subtaskCount = subtaskCount
    self.messagingContactHandles = messagingContactHandles
    self.relatedObjectCount = relatedObjectCount
    self.objects = objects
  }
}

public struct RemindersItemDebugResponse: Codable, Equatable, Sendable {
  public var reminder: ReminderDetail
  public var privateStoreMatches: [RemindersPrivateReminderDebugRecord]
  public var visibleURLObjects: [RemindersPrivateObjectDebugRecord]
  public var attachmentObjects: [RemindersPrivateObjectDebugRecord]
  public var assignmentObjects: [RemindersPrivateObjectDebugRecord]
  public var messagingContactHandles: [ReminderMessagingContactRecord]
  public var warnings: [String]

  public init(
    reminder: ReminderDetail,
    privateStoreMatches: [RemindersPrivateReminderDebugRecord],
    visibleURLObjects: [RemindersPrivateObjectDebugRecord],
    attachmentObjects: [RemindersPrivateObjectDebugRecord] = [],
    assignmentObjects: [RemindersPrivateObjectDebugRecord] = [],
    messagingContactHandles: [ReminderMessagingContactRecord] = [],
    warnings: [String] = []
  ) {
    self.reminder = reminder
    self.privateStoreMatches = privateStoreMatches
    self.visibleURLObjects = visibleURLObjects
    self.attachmentObjects = attachmentObjects
    self.assignmentObjects = assignmentObjects
    self.messagingContactHandles = messagingContactHandles
    self.warnings = warnings
  }
}
