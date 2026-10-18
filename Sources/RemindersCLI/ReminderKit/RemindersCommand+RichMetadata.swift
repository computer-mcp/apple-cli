import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

private typealias ReminderKitImportStore = REMStore
private typealias ReminderKitInternalImportStoreInvocation = REMStoreInvocation

extension RemindersCommand {

  public func preflightVisibleURLMutation() throws {
    try ReminderVisibleURLWriter.preflight()
  }

  public func preflightVisibleURLMutation(reminderID: String?) throws {
    try ReminderVisibleURLWriter.preflight(reminderID: reminderID)
  }

  public func setVisibleURL(reminderID: String, url: String?) throws {
    try ReminderVisibleURLWriter.setVisibleURL(reminderID: reminderID, url: url)
  }

  public func preflightRepeatMutation(reminderID: String?) throws {
    try ReminderRepeatWriter.preflight(reminderID: reminderID)
  }

  public func setRepeat(reminderID: String, repeatRule: ReminderRepeatRule?) throws {
    try ReminderRepeatWriter.setRepeat(reminderID: reminderID, repeatRule: repeatRule)
  }

  public func preflightTagMutation() throws {
    try ReminderTagWriter.preflight(reminderID: nil)
  }

  public func preflightTagMutation(reminderID: String?) throws {
    try ReminderTagWriter.preflight(reminderID: reminderID)
  }

  public func updateTags(
    reminderID: String,
    tags: [String]?,
    addTags: [String],
    removeTags: [String],
    clearTags: Bool
  ) throws {
    try ReminderTagWriter.updateTags(
      reminderID: reminderID,
      tags: tags,
      addTags: addTags,
      removeTags: removeTags,
      clearTags: clearTags
    )
  }

  public func renameTag(tagName: String, newName: String, reminderIDs: [String]) throws {
    try ReminderTagWriter.renameTag(tagName: tagName, newName: newName, reminderIDs: reminderIDs)
  }

  public func deleteTag(tagName: String, reminderIDs: [String]) throws {
    try ReminderTagWriter.deleteTag(tagName: tagName, reminderIDs: reminderIDs)
  }

  public func preflightSectionMutation() throws {
    try ReminderSectionWriter.preflight(listID: nil, reminderID: nil)
  }

  public func preflightSectionMutation(listID: String?, reminderID: String?) throws {
    try ReminderSectionWriter.preflight(listID: listID, reminderID: reminderID)
  }

  public func moveReminder(reminderID: String, toSectionTitle sectionTitle: String) throws {
    try ReminderSectionWriter.moveReminder(reminderID: reminderID, toSectionTitle: sectionTitle)
  }

  public func createSection(listID: String, title: String) throws {
    try ReminderSectionWriter.createSection(listID: listID, title: title)
  }

  public func renameSection(listID: String, sectionTitle: String, newTitle: String) throws {
    try ReminderSectionWriter.renameSection(
      listID: listID,
      sectionTitle: sectionTitle,
      newTitle: newTitle
    )
  }

  public func deleteSection(listID: String, sectionTitle: String) throws {
    try ReminderSectionWriter.deleteSection(listID: listID, sectionTitle: sectionTitle)
  }

  public func reorderSection(
    listID: String,
    sectionTitle: String,
    anchorSectionTitle: String,
    placement: ReminderSectionReorderPlacement
  ) throws {
    try ReminderSectionWriter.reorderSection(
      listID: listID,
      sectionTitle: sectionTitle,
      anchorSectionTitle: anchorSectionTitle,
      placement: placement
    )
  }

  public func preflightSubtaskMutation() throws {
    try ReminderSubtaskWriter.preflight(reminderID: nil)
  }

  public func preflightSubtaskMutation(reminderID: String?) throws {
    try ReminderSubtaskWriter.preflight(reminderID: reminderID)
  }

  public func createSubtask(parentReminderID: String, title: String) throws -> ReminderDetail {
    try ReminderSubtaskWriter.createSubtask(parentReminderID: parentReminderID, title: title)
  }

  public func moveSubtask(reminderID: String, toParentReminderID parentReminderID: String) throws {
    try ReminderSubtaskWriter.moveSubtask(
      reminderID: reminderID,
      toParentReminderID: parentReminderID
    )
  }

  public func promoteSubtask(reminderID: String) throws {
    try ReminderSubtaskWriter.promoteSubtask(reminderID: reminderID)
  }

  public func preflightAttachmentMutation() throws {
    try ReminderAttachmentWriter.preflight(reminderID: nil)
  }

  public func preflightAttachmentMutation(reminderID: String?) throws {
    try ReminderAttachmentWriter.preflight(reminderID: reminderID)
  }

  public func addAttachment(reminderID: String, fileURL: URL) throws {
    try ReminderAttachmentWriter.addAttachment(
      reminderID: reminderID,
      fileURL: fileURL
    )
  }

  public func removeAttachment(
    reminderID: String,
    attachment: ReminderAttachmentRecord,
    attachmentSelector: String
  ) throws {
    try ReminderAttachmentWriter.removeAttachment(
      reminderID: reminderID,
      attachment: attachment,
      attachmentSelector: attachmentSelector
    )
  }

  public func preflightAssignmentMutation() throws {
    try ReminderAssignmentWriter.preflight(reminderID: nil)
  }

  public func preflightAssignmentMutation(reminderID: String?) throws {
    try ReminderAssignmentWriter.preflight(reminderID: reminderID)
  }

  public func assignReminder(reminderID: String, target: ReminderAssignmentTargetRecord) throws {
    try ReminderAssignmentWriter.assign(reminderID: reminderID, target: target)
  }

  public func unassignReminder(
    reminderID: String,
    assignment: ReminderAssignmentRecord,
    assignmentSelector: String?
  ) throws {
    try ReminderAssignmentWriter.unassign(
      reminderID: reminderID,
      assignment: assignment,
      assignmentSelector: assignmentSelector
    )
  }

  public func preflightUrgentMutation() throws {
    try ReminderUrgentWriter.preflight(reminderID: nil)
  }

  public func preflightUrgentMutation(reminderID: String?) throws {
    try ReminderUrgentWriter.preflight(reminderID: reminderID)
  }

  public func setUrgent(reminderID: String, urgent: Bool) throws {
    try ReminderUrgentWriter.setUrgent(reminderID: reminderID, urgent: urgent)
  }

  public func preflightMessagingPersonMutation() throws {
    try ReminderMessagingPersonWriter.preflight(reminderID: nil)
  }

  public func preflightMessagingPersonMutation(reminderID: String?) throws {
    try ReminderMessagingPersonWriter.preflight(reminderID: reminderID)
  }

  public func setMessagingPerson(reminderID: String, personSelector: String?) throws {
    try ReminderMessagingPersonWriter.setMessagingPerson(
      reminderID: reminderID,
      personSelector: personSelector
    )
  }

  public func preflightSmartListMutation() throws {
    try ReminderSmartListWriter.preflight(listID: nil)
  }

  public func preflightSmartListMutation(listID: String?) throws {
    try ReminderSmartListWriter.preflight(listID: listID)
  }

  public func createSmartList(
    title: String,
    sourceID: String,
    criteria: ReminderSmartListCriteria
  ) throws -> String {
    try ReminderSmartListWriter.createSmartList(
      title: title,
      sourceID: sourceID,
      criteria: criteria
    )
  }

  public func updateSmartListCriteria(listID: String, criteria: ReminderSmartListCriteria) throws -> Bool {
    try ReminderSmartListWriter.updateSmartListCriteria(listID: listID, criteria: criteria)
  }

  public func convertListToSmartList(listID: String) throws -> String {
    try ReminderSmartListWriter.convertListToSmartList(listID: listID)
  }

  public func deleteSmartList(listID: String) throws {
    try ReminderSmartListWriter.deleteSmartList(listID: listID)
  }

  public func preflightListMetadataMutation() throws {
    try ReminderListMetadataWriter.preflight(listID: nil)
  }

  public func preflightListMetadataMutation(listID: String?) throws {
    try ReminderListMetadataWriter.preflight(listID: listID)
  }

  public func updateReminderListMetadata(listID: String, patch: ReminderListPatch) throws {
    try ReminderListMetadataWriter.updateListMetadata(listID: listID, patch: patch)
  }

  public func reorderReminderListMetadata(
    listID: String,
    anchorListID: String,
    placement: ReminderListReorderPlacement
  ) throws {
    try ReminderListMetadataWriter.reorderList(
      listID: listID,
      anchorListID: anchorListID,
      placement: placement
    )
  }

  public func createReminderListGroupChange(title: String) throws {
    try ReminderListGroupWriter.createGroup(title: title)
  }

  public func renameReminderListGroupChange(groupID: String, title: String) throws {
    try ReminderListGroupWriter.renameGroup(groupID: groupID, title: title)
  }

  public func deleteReminderListGroupChange(groupID: String) throws {
    try ReminderListGroupWriter.deleteGroup(groupID: groupID)
  }

  public func moveReminderListToGroup(listID: String, toGroupID groupID: String) throws {
    try ReminderListGroupWriter.moveList(listID: listID, toGroupID: groupID)
  }

  public func removeReminderListFromGroupChange(listID: String) throws {
    try ReminderListGroupWriter.removeListFromGroup(listID: listID)
  }
}

func reminderKitUnsupportedAction(
  capability: String,
  details additionalDetails: [String: String] = [:]
) -> CLIError {
  var details = [
    "mechanism": "reminderkit",
    "capability": capability,
    "required_mechanism": "ReminderKit.framework",
    "proof_status": "unsupported_action",
  ]
  for (key, value) in additionalDetails where !value.isEmpty {
    details[key] = value
  }
  return CLIError(
    code: .backendUnavailable,
    message: "ReminderKit write path does not support the requested variant.",
    details: details
  )
}

func reminderKitMethodUnavailable(
  capability: String,
  missing: [String],
  details additionalDetails: [String: String] = [:]
) -> CLIError {
  var details = [
    "mechanism": "reminderkit",
    "capability": capability,
    "proof_status": "method_unavailable",
    "missing": missing.joined(separator: ","),
  ]
  for (key, value) in additionalDetails where !value.isEmpty {
    details[key] = value
  }
  return CLIError(
    code: .backendUnavailable,
    message: "ReminderKit method is unavailable on this system.",
    details: details
  )
}

func reminderKitOperationFailed(
  capability: String,
  operation: String,
  message: String,
  details additionalDetails: [String: String] = [:]
) -> CLIError {
  var details = [
    "mechanism": "reminderkit",
    "capability": capability,
    "operation": operation,
    "proof_status": "operation_failed",
  ]
  for (key, value) in additionalDetails where !value.isEmpty {
    details[key] = value
  }
  return CLIError(code: .backendUnavailable, message: message, details: details)
}

public func reminderKitDoctorCheck() -> CLIDoctorCheck {
  let readiness = ReminderKitReadiness.current()
  return CLIDoctorCheck(
    name: "reminderkit_framework",
    status: readiness.status,
    message: readiness.message,
    details: readiness.details
  )
}

private struct ReminderKitReadiness {
  var frameworkProbes: [ReminderKitFrameworkProbe]
  var classProbes: [ReminderKitClassProbe]

  static func current() -> ReminderKitReadiness {
    ReminderKitReadiness(
      frameworkProbes: ReminderKitFrameworkProbe.defaultFrameworks.map {
        ReminderKitFrameworkProbe.probe(name: $0.name, binaryPath: $0.binaryPath)
      },
      classProbes: ReminderKitClassProbe.defaultClasses.map {
        ReminderKitClassProbe.probe(name: $0)
      }
    )
  }

  var status: CLIDoctorStatus {
    guard frameworkProbes.allSatisfy(\.bundlePresent),
      frameworkProbes.allSatisfy(\.dlopenAvailable)
    else {
      return .backendUnavailable
    }
    return classProbes.allSatisfy(\.available) ? .ok : .warning
  }

  var message: String {
    guard frameworkProbes.allSatisfy(\.bundlePresent),
      frameworkProbes.allSatisfy(\.dlopenAvailable)
    else {
      return "ReminderKit framework bundle was not available."
    }
    guard classProbes.allSatisfy(\.available) else {
      return
        "ReminderKit frameworks are available; some expected ReminderKit classes were not found."
    }
    return
      "ReminderKit modules compile and framework probes are available; implemented capability actions still verify through read-only SQLite evidence."
  }

  var proofStatus: String {
    guard frameworkProbes.allSatisfy(\.bundlePresent),
      frameworkProbes.allSatisfy(\.dlopenAvailable)
    else {
      return "framework_missing"
    }
    return classProbes.allSatisfy(\.available) ? "framework_ready" : "class_probe_partial"
  }

  var details: [String: String] {
    var details: [String: String] = [
      "mechanism": "reminderkit",
      "proof_status": proofStatus,
      "compiled_modules": "ReminderKit,ReminderKitInternal",
      "compile_boundary": "swift_import",
      "frameworks": frameworkProbes.map(\.name).joined(separator: ","),
      "framework_bundle_paths": frameworkProbes.map(\.bundlePath).joined(separator: ","),
      "framework_binary_paths": frameworkProbes.map(\.binaryPath).joined(separator: ","),
      "framework_bundle_status": frameworkProbes.map(\.bundleStatus).joined(separator: ","),
      "framework_dlopen_status": frameworkProbes.map(\.dlopenStatus).joined(separator: ","),
      "reminderkit_classes": classProbes.map(\.statusDescription).joined(separator: ","),
      "readiness": "framework_probe_plus_action_specific_verifiers",
    ]
    let diagnostics = frameworkProbes.compactMap(\.diagnostic)
    if !diagnostics.isEmpty {
      details["diagnostics"] = diagnostics.joined(separator: "\n")
    }
    return details
  }
}

private struct ReminderKitFrameworkProbe {
  static let defaultFrameworks: [(name: String, binaryPath: String)] = [
    (
      "ReminderKit.framework",
      "/System/Library/PrivateFrameworks/ReminderKit.framework/ReminderKit"
    ),
    (
      "ReminderKitInternal.framework",
      "/System/Library/PrivateFrameworks/ReminderKitInternal.framework/ReminderKitInternal"
    ),
  ]

  var name: String
  var binaryPath: String
  var bundlePath: String
  var bundlePresent: Bool
  var binaryPresent: Bool
  var dlopenAvailable: Bool
  var diagnostic: String?

  static func probe(name: String, binaryPath: String) -> ReminderKitFrameworkProbe {
    let bundlePath = (binaryPath as NSString).deletingLastPathComponent
    let fileManager = FileManager.default
    let handle = dlopen(binaryPath, RTLD_LAZY)
    defer {
      if let handle {
        dlclose(handle)
      }
    }

    let diagnostic: String?
    if handle == nil, let error = dlerror() {
      diagnostic = "\(name): \(String(cString: error))"
    } else {
      diagnostic = nil
    }

    return ReminderKitFrameworkProbe(
      name: name,
      binaryPath: binaryPath,
      bundlePath: bundlePath,
      bundlePresent: fileManager.fileExists(atPath: bundlePath),
      binaryPresent: fileManager.fileExists(atPath: binaryPath),
      dlopenAvailable: handle != nil,
      diagnostic: diagnostic
    )
  }

  var bundleStatus: String {
    "\(name)=\(bundlePresent ? "present" : "missing")"
  }

  var dlopenStatus: String {
    "\(name)=\(dlopenAvailable ? "available" : "unavailable")"
  }
}

private struct ReminderKitClassProbe {
  static let defaultClasses = [
    "REMStore",
    "REMSaveRequest",
    "REMReminderChangeItem",
    "REMReminderAttachmentContext",
    "REMReminderHashtagContext",
    "REMReminderSubtaskContext",
    "REMReminderAssignmentContext",
    "REMListSectionContext",
    "REMListGroceryContext",
    "REMAccountGroupContext",
    "REMAccountGroupContextChangeItem",
    "REMListsDataView",
    "REMListSublistContext",
    "REMSmartList",
  ]

  var name: String
  var available: Bool

  static func probe(name: String) -> ReminderKitClassProbe {
    ReminderKitClassProbe(name: name, available: NSClassFromString(name) != nil)
  }

  var statusDescription: String {
    "\(name)=\(available ? "available" : "missing")"
  }
}
