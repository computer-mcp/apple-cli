import Foundation

public struct RemindersSQLiteReader: Sendable {
  let homeDirectory: URL

  struct PrivateListState {
    var listType: String
    var smartListType: String?
    var isPinned: Bool?
    var pinnedDateRaw: Double?
    var displayOrder: Int?
    var sortingStyle: String?
    var showingLargeAttachments: Bool?
    var hasColor: Bool?
    var colorLengthBytes: Int?
  }

  struct PrivateAssignmentSharee: Hashable {
    var primaryKey: Int64
    var identifier: String
    var displayName: String?
    var firstName: String?
    var lastName: String?
    var address: String?
  }

  struct PrivateSectionOrderingCandidate {
    var record: ReminderSectionRecord
    var sectionIdentifier: String?
    var orderingIdentifiers: [String]
    var fallbackPrimaryKey: Int64
  }

  struct ReminderPrivateState {
    var tagSet: Set<String> = []
    var tags: [String] = []
    var isFlagged: Bool?
    var isUrgent: Bool?
    var visibleURLs: [String] = []
    var visibleURL: String? { visibleURLs.first }
    var sectionId: String?
    var sectionTitle: String?
    var sectionPrimaryKey: Int64?
    var parentReminderId: String?
    var parentReminderTitle: String?
    var subtaskCount: Int = 0
    var attachments: [ReminderAttachmentRecord] = []
    var assignments: [ReminderAssignmentRecord] = []
    var messagingContactHandles: [ReminderMessagingContactRecord] = []
    var repeatRule: ReminderRepeatRule?

    func normalized() -> ReminderPrivateState {
      let sortedTags = tagSet.sorted { lhs, rhs in
        lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
      }
      let sortedAssignments = assignments.sorted { lhs, rhs in
        assignmentSortKey(lhs) < assignmentSortKey(rhs)
      }
      return ReminderPrivateState(
        tagSet: tagSet,
        tags: sortedTags,
        isFlagged: isFlagged,
        isUrgent: isUrgent,
        visibleURLs: visibleURLs,
        sectionId: sectionId,
        sectionTitle: sectionTitle,
        sectionPrimaryKey: sectionPrimaryKey,
        parentReminderId: parentReminderId,
        parentReminderTitle: parentReminderTitle,
        subtaskCount: subtaskCount,
        attachments: attachments,
        assignments: sortedAssignments,
        messagingContactHandles: messagingContactHandles,
        repeatRule: repeatRule
      )
    }

    private func assignmentSortKey(_ assignment: ReminderAssignmentRecord) -> String {
      [
        assignment.assigneeIdentifier ?? "",
        assignment.personId ?? "",
        assignment.contactLabel ?? "",
        assignment.assignedAtRaw.map { String(describing: $0) } ?? "",
      ].joined(separator: "|")
    }
  }

  struct ReminderPrivateSectionState {
    var id: String
    var primaryKey: Int64
    var title: String
  }

  struct ReminderPrivateSubtaskState {
    var parentId: String?
    var parentTitle: String?
    var subtaskCount: Int = 0
  }

  public init(
    homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
  ) {
    self.homeDirectory = homeDirectory
  }
}
