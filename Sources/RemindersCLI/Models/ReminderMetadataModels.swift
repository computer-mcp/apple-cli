import Foundation

public struct ReminderSectionRecord: Codable, Equatable, Sendable {
  public var id: String
  public var listId: String
  public var listTitle: String
  public var title: String

  public init(id: String, listId: String, listTitle: String, title: String) {
    self.id = id
    self.listId = listId
    self.listTitle = listTitle
    self.title = title
  }
}

public struct ReminderSectionsResponse: Codable, Equatable, Sendable {
  public var list: ReminderListRecord
  public var sections: [ReminderSectionRecord]
}

public struct ReminderSectionReorderPlacement: Codable, Equatable, Sendable {
  public var beforeSectionId: String?
  public var afterSectionId: String?

  public init(beforeSectionId: String? = nil, afterSectionId: String? = nil) {
    self.beforeSectionId = beforeSectionId
    self.afterSectionId = afterSectionId
  }

  public var anchorSectionId: String? {
    beforeSectionId ?? afterSectionId
  }

  public var relation: String {
    beforeSectionId != nil ? "before" : "after"
  }
}

public struct ReminderSectionMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var list: ReminderListRecord
  public var section: ReminderSectionRecord?
  public var anchorSection: ReminderSectionRecord?
  public var placement: ReminderSectionReorderPlacement?
  public var sections: [ReminderSectionRecord]
  public var deletedSectionTitle: String?

  public init(
    operation: String,
    changed: Bool,
    list: ReminderListRecord,
    section: ReminderSectionRecord? = nil,
    anchorSection: ReminderSectionRecord? = nil,
    placement: ReminderSectionReorderPlacement? = nil,
    sections: [ReminderSectionRecord] = [],
    deletedSectionTitle: String? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.list = list
    self.section = section
    self.anchorSection = anchorSection
    self.placement = placement
    self.sections = sections
    self.deletedSectionTitle = deletedSectionTitle
  }
}

public struct ReminderSubtaskMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var reminder: ReminderDetail
  public var parentReminder: ReminderDetail?

  public init(
    operation: String,
    changed: Bool,
    reminder: ReminderDetail,
    parentReminder: ReminderDetail? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.reminder = reminder
    self.parentReminder = parentReminder
  }
}

struct ReminderAttachmentMutationIdentity: Sendable {
  var reminder: ReminderMutationIdentity
  var attachment: ReminderAttachmentRecord?
  var attachmentSelector: String?
  var filePath: String?
  var fileName: String?
  var fileSizeBytes: Int64?
  var fileContentSHA256: String?
  var attachmentEvidenceSHA256: String
  var scopeDigest: String
  var summaryFields: [String: String]

  init(
    reminder: ReminderMutationIdentity,
    attachment: ReminderAttachmentRecord? = nil,
    attachmentSelector: String? = nil,
    filePath: String? = nil,
    fileName: String? = nil,
    fileSizeBytes: Int64? = nil,
    fileContentSHA256: String? = nil,
    attachmentEvidenceSHA256: String,
    scopeDigest: String,
    summaryFields: [String: String]
  ) {
    self.reminder = reminder
    self.attachment = attachment
    self.attachmentSelector = attachmentSelector
    self.filePath = filePath
    self.fileName = fileName
    self.fileSizeBytes = fileSizeBytes
    self.fileContentSHA256 = fileContentSHA256
    self.attachmentEvidenceSHA256 = attachmentEvidenceSHA256
    self.scopeDigest = scopeDigest
    self.summaryFields = summaryFields
  }
}

public struct ReminderAttachmentMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var reminder: ReminderDetail
  public var attachment: ReminderAttachmentRecord?
  public var attachmentSelector: String?

  public init(
    operation: String,
    changed: Bool,
    reminder: ReminderDetail,
    attachment: ReminderAttachmentRecord? = nil,
    attachmentSelector: String? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.reminder = reminder
    self.attachment = attachment
    self.attachmentSelector = attachmentSelector
  }
}

struct ReminderAssignmentMutationIdentity: Sendable {
  var reminder: ReminderMutationIdentity
  var assignment: ReminderAssignmentRecord?
  var assignmentSelector: String?
  var assigneeSelector: String?
  var assignmentEvidenceSHA256: String
  var scopeDigest: String
  var summaryFields: [String: String]

  init(
    reminder: ReminderMutationIdentity,
    assignment: ReminderAssignmentRecord? = nil,
    assignmentSelector: String? = nil,
    assigneeSelector: String? = nil,
    assignmentEvidenceSHA256: String,
    scopeDigest: String,
    summaryFields: [String: String]
  ) {
    self.reminder = reminder
    self.assignment = assignment
    self.assignmentSelector = assignmentSelector
    self.assigneeSelector = assigneeSelector
    self.assignmentEvidenceSHA256 = assignmentEvidenceSHA256
    self.scopeDigest = scopeDigest
    self.summaryFields = summaryFields
  }
}

public struct ReminderAssignmentMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var reminder: ReminderDetail
  public var assignment: ReminderAssignmentRecord?
  public var assignmentSelector: String?
  public var assigneeSelector: String?

  public init(
    operation: String,
    changed: Bool,
    reminder: ReminderDetail,
    assignment: ReminderAssignmentRecord? = nil,
    assignmentSelector: String? = nil,
    assigneeSelector: String? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.reminder = reminder
    self.assignment = assignment
    self.assignmentSelector = assignmentSelector
    self.assigneeSelector = assigneeSelector
  }
}
public struct ReminderTagRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var canonicalName: String?
  public var relatedObjectCount: Int
  public var reminderReferenceCount: Int

  public init(
    id: String,
    name: String,
    canonicalName: String? = nil,
    relatedObjectCount: Int = 0,
    reminderReferenceCount: Int = 0
  ) {
    self.id = id
    self.name = name
    self.canonicalName = canonicalName
    self.relatedObjectCount = relatedObjectCount
    self.reminderReferenceCount = reminderReferenceCount
  }
}

public struct ReminderTagsResponse: Codable, Equatable, Sendable {
  public var tags: [ReminderTagRecord]

  public init(tags: [ReminderTagRecord]) {
    self.tags = tags
  }
}

public struct ReminderTagMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var tag: ReminderTagRecord?
  public var deletedTagName: String?

  public init(
    operation: String,
    changed: Bool,
    tag: ReminderTagRecord? = nil,
    deletedTagName: String? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.tag = tag
    self.deletedTagName = deletedTagName
  }
}
