import CryptoKit
import Dispatch
import Foundation
import Utility

struct ReminderMutationIdentity {
  var reminder: ReminderDetail
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderCleanupPlan {
  var candidates: [ReminderSummary]
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderMatchingCompletionContext {
  var identities: [ReminderMutationIdentity]
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderListReorderIdentity {
  var list: ReminderListRecord
  var anchorList: ReminderListRecord
  var placement: ReminderListReorderPlacement
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderListDeleteIdentity {
  var list: ReminderListRecord
  var reminderCount: Int
  var reminderSnapshotHash: String
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderListCreateIdentity {
  var title: String
  var source: ReminderListSourceRecord
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderSectionMutationIdentity {
  var list: ReminderListRecord
  var sections: [ReminderSectionRecord]
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderTagMutationIdentity {
  var tag: ReminderTagRecord
  var tags: [ReminderTagRecord]
  var reminderIDs: [String]
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderSubtaskCreateIdentity {
  var parent: ReminderMutationIdentity
  var title: String
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ReminderSubtaskMoveIdentity {
  var reminder: ReminderMutationIdentity
  var parent: ReminderMutationIdentity?
  var scopeDigest: String
  var summaryFields: [String: String]
}
