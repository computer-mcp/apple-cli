import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes state audit command")
struct NotesStateAuditCommandTests {
  @Test func auditReturnsAggregateLockAndSharingBoundaryOnly() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "audit", "--folder", "Archive", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let verification = data?["verification"] as? [String: Any]
    let checks = verification?["checks"] as? [[String: Any]] ?? []
    let checkNames = checks.compactMap { $0["name"] as? String }
    let supportedFamilies = summary?["supportedReadFamilies"] as? [String] ?? []
    let gatedFamilies = summary?["gatedMutationFamilies"] as? [String] ?? []
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["returnedNoteCount"] as? Int == 4)
    #expect(records?.count == 4)
    #expect(summary?["noteCount"] as? Int == 4)
    #expect(summary?["passwordProtectedCount"] as? Int == 2)
    #expect(summary?["lockedCount"] as? Int == 1)
    #expect(summary?["sharedNoteCount"] as? Int == 1)
    #expect(summary?["sharedReadOnlyCount"] as? Int == 1)
    #expect(summary?["participantCount"] as? Int == 2)
    #expect(supportedFamilies.contains("lock_status"))
    #expect(supportedFamilies.contains("lock_remove_lock_mutation"))
    #expect(supportedFamilies.contains("session_unlocked_locked_content_export"))
    #expect(supportedFamilies.contains("share_status"))
    #expect(supportedFamilies.contains("collaboration_activity_metadata"))
    #expect(gatedFamilies.contains("unlock_locked_note"))
    #expect(gatedFamilies.contains("locked_content_export") == false)
    #expect(gatedFamilies.contains("sharing_permission_mutation") == false)
    #expect(gatedFamilies.contains("participant_invite") == false)
    #expect(gatedFamilies.contains("shared_folder_permission_mutation") == false)
    #expect(gatedFamilies.contains("collaboration_activity_export") == false)
    #expect(verification?["operation"] as? String == "notes.state.audit")
    #expect(verification?["verified"] as? Bool == true)
    #expect(checkNames.contains("privacy_surface_limited_to_state"))
    #expect(checkNames.contains("sharing_mutations_supported"))
    #expect(implementation.noteStateReadIDs == [
      "note-archive",
      "note-shared",
      "note-locked",
      "note-unlocked-protected",
    ])
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(output.contains("Private archive body") == false)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Private locked body") == false)
    #expect(output.contains("Unlocked protected body") == false)
    #expect(output.contains("Archive Plan") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Ada") == false)
  }

  @Test func auditCanLimitCollectionToAccount() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "audit", "--account", "Local", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let summary = data?["summary"] as? [String: Any]
    let records = data?["records"] as? [[String: Any]]
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data?["account"] as? String == "Local")
    #expect(data?["returnedNoteCount"] as? Int == 1)
    #expect(records?.count == 1)
    #expect(summary?["noteCount"] as? Int == 1)
    #expect(summary?["sharedNoteCount"] as? Int == 0)
    #expect(implementation.accountListQueries == ["Local||50"])
    #expect(implementation.noteStateReadIDs == ["note-local"])
    #expect(output.contains("Local private body") == false)
    #expect(output.contains("Local Plan") == false)
  }

  @Test func lockabilityExplainsProvableReasonsWithoutLeakingContent() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "lockability", "--id", "note-shared", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let reasons = try #require(data["reasons"] as? [[String: Any]])
    let reasonIDs = Set(reasons.compactMap { $0["reasonID"] as? String })
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let prohibited = data["prohibitedAttachmentFamilyCounts"] as? [String: Int]
    let allowed = data["allowedAttachmentFamilyCounts"] as? [String: Int]
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.lockability")
    #expect(data["changed"] as? Bool == false)
    #expect(data["privateFrameworkLockable"] as? Bool == false)
    #expect(data["blockingReasonCount"] as? Int == 3)
    #expect(data["unresolvedReasonCount"] as? Int == 0)
    #expect(data["tagCount"] as? Int == 1)
    #expect((data["tagSetSHA256"] as? String)?.count == 64)
    #expect(data["accountCanPasswordProtectNotes"] as? Bool == true)
    #expect(data["accountCanHaveCryptoStrategy"] as? Bool == true)
    #expect(data["accountIsInICloud"] as? Bool == true)
    #expect(data["accountIsLocal"] as? Bool == false)
    #expect((data["accountLockedNotesModeSHA256"] as? String)?.count == 64)
    #expect((data["accountResolvedLockedNotesModeSHA256"] as? String)?.count == 64)
    #expect(data["accountPasswordProtectedNoteCount"] as? Int == 1)
    #expect(data["attachmentCount"] as? Int == 2)
    #expect(prohibited?["pdf"] == 1)
    #expect(allowed?["photo_image"] == 1)
    #expect(reasonIDs == ["shared_note", "contains_tags", "unsupported_attachment_family"])
    #expect(verification["operation"] as? String == "notes.state.lockability")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("state_readback_identity"))
    #expect(checkNames.contains("tag_hash_accounting"))
    #expect(checkNames.contains("attachment_family_accounting"))
    #expect(checkNames.contains("account_lockability_evidence_readback"))
    #expect(checkNames.contains("privacy_surface_limited_to_hashes_counts_and_booleans"))
    #expect(implementation.noteStateReadIDs == ["note-shared"])
    #expect(implementation.readNoteLookups == ["note-shared"])
    #expect(implementation.attachmentReadIDs == ["note-shared"])
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("SecretProject") == false)
    #expect(output.contains("Private Contract") == false)
  }

  @Test func lockabilityExplainsAccountProviderBlockerWithoutLeakingAccountValues() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "lockability", "--id", "note-provider-blocked", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let reasons = try #require(data["reasons"] as? [[String: Any]])
    let reasonIDs = Set(reasons.compactMap { $0["reasonID"] as? String })
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["privateFrameworkLockable"] as? Bool == false)
    #expect(data["blockingReasonCount"] as? Int == 3)
    #expect(data["unresolvedReasonCount"] as? Int == 0)
    #expect(data["accountCanPasswordProtectNotes"] as? Bool == false)
    #expect(data["accountCanHaveCryptoStrategy"] as? Bool == false)
    #expect(data["accountIsInICloud"] as? Bool == false)
    #expect(data["accountIsLocal"] as? Bool == false)
    #expect((data["accountLockedNotesModeSHA256"] as? String)?.count == 64)
    #expect((data["accountResolvedLockedNotesModeSHA256"] as? String)?.count == 64)
    #expect(data["accountPasswordProtectedNoteCount"] as? Int == 0)
    #expect(reasonIDs == [
      "account_provider_does_not_support_locking",
      "account_cannot_password_protect_notes",
      "account_has_no_crypto_strategy",
    ])
    #expect(reasonIDs.contains("icloud_upgrade_or_private_reason_unproven") == false)
    #expect(checkNames.contains("account_lockability_evidence_readback"))
    #expect(verification["verified"] as? Bool == true)
    #expect(implementation.noteStateReadIDs == ["note-provider-blocked"])
    #expect(implementation.readNoteLookups == ["note-provider-blocked"])
    #expect(implementation.attachmentReadIDs == ["note-provider-blocked"])
    #expect(output.contains("External Provider") == false)
    #expect(output.contains("Provider Plan") == false)
    #expect(output.contains("Provider private body") == false)
  }

  @Test func activityReturnsPrivacySafeCollaborationMetadata() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "state", "activity", "--id", "note-shared", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let activity = try #require(data["activity"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.activity")
    #expect(data["changed"] as? Bool == false)
    #expect(activity["noteID"] as? String == "note-shared")
    #expect((activity["noteIDSHA256"] as? String)?.count == 64)
    #expect(activity["isShared"] as? Bool == true)
    #expect(activity["isSharedReadOnly"] as? Bool == true)
    #expect(activity["participantCount"] as? Int == 2)
    #expect((activity["participantUserIDSHA256s"] as? [String])?.count == 2)
    #expect(activity["activityEventsPresent"] as? Bool == true)
    #expect(activity["activityEventsByteCount"] as? Int == StateAuditImplementation.activityEventBytes.count)
    #expect((activity["activityEventsSHA256"] as? String)?.count == 64)
    #expect(activity["activityEventsDocumentPresent"] as? Bool == true)
    #expect(activity["persistedActivityEventsStorageCount"] as? Int == 2)
    #expect(activity["shareTimestampPresent"] as? Bool == true)
    #expect((activity["shareTimestampSHA256"] as? String)?.count == 64)
    #expect(activity["privacyBoundary"] as? String == "hashes_counts_and_booleans_only")
    #expect(verification["verified"] as? Bool == true)
    #expect(
      checks.contains {
        $0["name"] as? String == "privacy_surface_limited_to_activity_metadata"
          && $0["status"] as? String == "passed"
      })
    #expect(implementation.noteActivityReadIDs == ["note-shared"])
    #expect(implementation.noteStateReadIDs.isEmpty)
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Ada Lovelace") == false)
    #expect(output.contains("Grace Hopper") == false)
    #expect(output.contains("Edited the launch checklist") == false)
  }

  @Test func activityExportUsesArtifactSafetyAndReadbackVerification() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("NotesActivityExportTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("activity.json").path

    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "activity", "--id", "note-shared", "--output", destination, "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.activity")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-artifact-action"])
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["destination_path"] as? String == destination)
    #expect(FileManager.default.fileExists(atPath: destination) == false)
    #expect(dryRunImplementation.noteActivityReadIDs == ["note-shared"])

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "activity", "--id", "note-shared", "--output", destination,
      "--allow-artifact-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let activity = try #require(data["activity"] as? [String: Any])
    let artifact = try #require(data["artifact"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let artifactData = try Data(contentsOf: URL(fileURLWithPath: destination))
    let artifactObject = try jsonObject(String(decoding: artifactData, as: UTF8.self))
    let output = (executed.stdout ?? "") + String(decoding: artifactData, as: UTF8.self)

    #expect(object["ok"] as? Bool == true)
    #expect(data["changed"] as? Bool == true)
    #expect(activity["activityEventsByteCount"] as? Int == StateAuditImplementation.activityEventBytes.count)
    #expect(artifact["destinationPath"] as? String == destination)
    #expect(artifact["byteCount"] as? Int == artifactData.count)
    #expect((artifact["sha256"] as? String) == sha256Hex(artifactData))
    #expect(artifactObject["activityEventsByteCount"] as? Int == StateAuditImplementation.activityEventBytes.count)
    #expect(verification["verified"] as? Bool == true)
    #expect(implementation.noteActivityReadIDs == ["note-shared", "note-shared"])
    #expect(implementation.noteStateReadIDs.isEmpty)
    #expect(implementation.readNoteLookups.isEmpty)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Ada Lovelace") == false)
    #expect(output.contains("Grace Hopper") == false)
    #expect(output.contains("Edited the launch checklist") == false)
  }

  @Test func participantsReturnsPrivacySafeAccessMetadata() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "participants", "--id", "note-shared", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let participants = try #require(data["participants"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let first = try #require(participants.first)
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.participants")
    #expect(data["changed"] as? Bool == false)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect(data["wasShared"] as? Bool == true)
    #expect(data["isReadOnly"] as? Bool == true)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect((data["ownerRecordNameSHA256"] as? String)?.count == 64)
    #expect(data["publicPermissionValue"] as? Int == 2)
    #expect(data["publicPermissionLabel"] as? String == "read-only")
    #expect(data["participantCount"] as? Int == 2)
    #expect(data["returnedParticipantCount"] as? Int == 2)
    #expect((data["participantIdentitySetSHA256"] as? String)?.count == 64)
    #expect(participants.count == 2)
    #expect((first["participantIDSHA256"] as? String)?.count == 64)
    #expect((first["userRecordNameSHA256s"] as? [String])?.first?.count == 64)
    #expect(first["permissionValue"] as? Int == 3)
    #expect(first["permissionLabel"] as? String == "read-write")
    #expect(first["roleLabel"] as? String == "private-user")
    #expect(first["acceptanceStatusLabel"] as? String == "accepted")
    #expect(verification["operation"] as? String == "notes.state.participants")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_state_preflight"))
    #expect(checkNames.contains("participant_count_accounting"))
    #expect(checkNames.contains("participant_identity_hash_set"))
    #expect(checkNames.contains("permission_enum_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationParticipantReads == [NotesCollaborationParticipantsDraft(noteID: "note-shared")])
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Ada Lovelace") == false)
    #expect(output.contains("Grace Hopper") == false)
    #expect(output.contains("ada@example.com") == false)
    #expect(output.contains(StateAuditImplementation.sharedNoteLink) == false)

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "participants", "--folder", "Private Shared Folder", "--json",
    ])))
    let folderObject = try jsonObject(folderResult.stdout ?? "")
    let folderData = try #require(folderObject["data"] as? [String: Any])
    #expect(folderData["targetKind"] as? String == "folder")
    #expect(folderData["participantCount"] as? Int == 2)
    #expect(folderImplementation.collaborationParticipantReads == [
      NotesCollaborationParticipantsDraft(folderID: "Private Shared Folder"),
    ])
    #expect((folderResult.stdout ?? "").contains("Private Shared Folder") == false)

    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("NotesParticipantExportTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("participants.json").path

    let exportDryRunImplementation = StateAuditImplementation()
    let exportDryRunCommand = NotesCommand(implementation: exportDryRunImplementation)
    let exportDryRun = try #require(try exportDryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "participants", "--id", "note-shared", "--output", destination, "--dry-run", "--json",
    ])))
    let exportDryRunObject = try jsonObject(exportDryRun.stdout ?? "")
    let exportDryRunData = try #require(exportDryRunObject["data"] as? [String: Any])
    let exportDryRunRequirements = try #require(exportDryRunData["requirements"] as? [String: Any])
    let exportDryRunArgs = try #require(exportDryRunData["normalizedArguments"] as? [String: Any])

    #expect(exportDryRunObject["ok"] as? Bool == true)
    #expect(exportDryRunData["operation"] as? String == "notes.state.participants")
    #expect(exportDryRunRequirements["allowFlags"] as? [String] == ["--allow-artifact-action"])
    #expect(exportDryRunArgs["destination"] as? String == "artifact")
    #expect((exportDryRunArgs["output_path_sha256"] as? String)?.count == 64)
    #expect(FileManager.default.fileExists(atPath: destination) == false)
    #expect(exportDryRunImplementation.collaborationParticipantReads == [NotesCollaborationParticipantsDraft(noteID: "note-shared")])

    let exportImplementation = StateAuditImplementation()
    let exportCommand = NotesCommand(implementation: exportImplementation)
    let exportResult = try #require(try exportCommand.run(options: try CLIOptionsFixture.parse([
      "state", "participants", "--id", "note-shared", "--output", destination,
      "--allow-artifact-action", "--json",
    ])))
    let exportObject = try jsonObject(exportResult.stdout ?? "")
    let exportData = try #require(exportObject["data"] as? [String: Any])
    let exportArtifact = try #require(exportData["artifact"] as? [String: Any])
    let exportVerification = try #require(exportData["verification"] as? [String: Any])
    let exportChecks = try #require(exportVerification["checks"] as? [[String: Any]])
    let exportCheckNames = Set(exportChecks.compactMap { $0["name"] as? String })
    let artifactData = try Data(contentsOf: URL(fileURLWithPath: destination))
    let artifactObject = try jsonObject(String(decoding: artifactData, as: UTF8.self))
    let exportedOutput = (exportResult.stdout ?? "") + String(decoding: artifactData, as: UTF8.self)

    #expect(exportObject["ok"] as? Bool == true)
    #expect(exportData["changed"] as? Bool == true)
    #expect(exportArtifact["destinationPath"] as? String == destination)
    #expect(exportArtifact["byteCount"] as? Int == artifactData.count)
    #expect(exportArtifact["sha256"] as? String == sha256Hex(artifactData))
    #expect(exportArtifact["contentKind"] as? String == "collaboration_participant_metadata_json")
    #expect(artifactObject["targetKind"] as? String == "note")
    #expect(artifactObject["participantCount"] as? Int == 2)
    #expect(exportVerification["verified"] as? Bool == true)
    #expect(exportCheckNames.contains("artifact_metadata_matches_readback"))
    #expect(exportCheckNames.contains("participant_readback_stable"))
    #expect(exportImplementation.collaborationParticipantReads == [
      NotesCollaborationParticipantsDraft(noteID: "note-shared"),
      NotesCollaborationParticipantsDraft(noteID: "note-shared"),
    ])
    #expect(exportedOutput.contains("Private shared body") == false)
    #expect(exportedOutput.contains("Shared Plan") == false)
    #expect(exportedOutput.contains("Ada Lovelace") == false)
    #expect(exportedOutput.contains("Grace Hopper") == false)
    #expect(exportedOutput.contains("ada@example.com") == false)
    #expect(exportedOutput.contains(StateAuditImplementation.sharedNoteLink) == false)

    let nonSharedImplementation = StateAuditImplementation()
    let nonSharedCommand = NotesCommand(implementation: nonSharedImplementation)
    do {
      _ = try nonSharedCommand.run(options: try CLIOptionsFixture.parse([
        "state", "participants", "--id", "note-local", "--json",
      ]))
      Issue.record("Expected participant metadata read to reject a non-shared note.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["operation"] == "notes.state.participants")
      #expect(error.details["required_state"] == "shared")
      #expect((error.details["note_id_sha256"] ?? "").count == 64)
      #expect(error.details.values.contains("note-local") == false)
    }
    #expect(nonSharedImplementation.collaborationParticipantReads == [NotesCollaborationParticipantsDraft(noteID: "note-local")])
  }

  @Test func gatedLockAndPasswordMutationCommandsRefuseWithoutImplementationAccess() throws {
    let cases: [(args: [String], operation: String, capability: String)] = [
      (
        ["state", "change-password", "--account", "private@example.com"],
        "notes.state.change-password", "locked_notes_password_change"
      ),
    ]

    for item in cases {
      let implementation = StateAuditImplementation()
      let command = NotesCommand(implementation: implementation)
      let options = try CLIOptionsFixture.parse(item.args + ["--json"])

      do {
        _ = try command.run(options: options)
        Issue.record("Expected \(item.operation) to be gated.")
      } catch let error as CLIError {
        #expect(error.code == .unsupportedOperation)
        #expect(error.details["operation"] == item.operation)
        #expect(error.details["capability"] == item.capability)
        #expect(error.details["status"] == "gated")
        #expect(error.details["required_implementation"] == "typed_private_notes_framework")
        #expect(error.details["required_verifier"] == "private_framework_state_readback+privacy_boundary")
        #expect(error.details["backend_calls"] == "none")
        #expect(error.details.values.contains("person@example.com") == false)
        #expect(error.details.values.contains("private@example.com") == false)
        #expect(error.details.values.contains("Private Shared Folder") == false)
        #expect(error.details.values.contains("/tmp/private-share-link.txt") == false)
        #expect(error.details.values.contains("Private mention context") == false)
      }

      #expect(implementation.noteStateReadIDs.isEmpty)
      #expect(implementation.readNoteLookups.isEmpty)
      #expect(implementation.customPassphraseDrafts.isEmpty)
      #expect(implementation.settingsWriteOperations.isEmpty)
    }
  }

  @Test func unlockUsesPrivateAuthenticationStateAndSecretSourceBoundary() throws {
    let secret = "correct horse battery staple"
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "unlock", "--id", "note-locked", "--passphrase-env", "NOTES_TEST_PASSPHRASE",
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.unlock")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["capability"] as? String == "unlock_locked_note")
    #expect(dryRunArgs["passphrase_source_kind"] as? String == "env")
    #expect((dryRunArgs["passphrase_source_sha256"] as? String)?.count == 64)
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect((dryRun.stdout ?? "").contains("NOTES_TEST_PASSPHRASE") == false)
    #expect((dryRun.stdout ?? "").contains(secret) == false)
    #expect(dryRunImplementation.noteUnlockDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    setenv("NOTES_TEST_PASSPHRASE", secret, 1)
    defer { unsetenv("NOTES_TEST_PASSPHRASE") }
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "unlock", "--id", "note-locked", "--passphrase-env", "NOTES_TEST_PASSPHRASE", "--json",
      ]))
      Issue.record("Expected state unlock without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(missingAllowImplementation.noteUnlockDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "unlock", "--id", "note-locked", "--passphrase-env", "NOTES_TEST_PASSPHRASE",
      "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.unlock")
    #expect(data["changed"] as? Bool == true)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["passphraseSourceKind"] as? String == "env")
    #expect(data["beforePasswordProtected"] as? Bool == true)
    #expect(data["beforePasswordProtectedAndLocked"] as? Bool == true)
    #expect(data["afterPasswordProtected"] as? Bool == true)
    #expect(data["afterPasswordProtectedAndLocked"] as? Bool == false)
    #expect(data["afterAuthenticated"] as? Bool == true)
    #expect(data["afterHasAuthenticatedObject"] as? Bool == true)
    #expect(data["backendCalls"] as? String == "ICAuthenticationState.authenticateObject:withPassphrase:")
    #expect(verification["verified"] as? Bool == true)
    #expect(verification["verifier"] as? String == "notes_unlock_session_v1")
    #expect(checkNames.contains("passphrase_source_supported"))
    #expect(checkNames.contains("private_authentication_state_implementation"))
    #expect(checkNames.contains("locked_note_session_unlocked"))
    #expect(implementation.noteUnlockDrafts.count == 1)
    #expect(implementation.noteUnlockDrafts.first?.noteID == "note-locked")
    #expect(implementation.noteUnlockDrafts.first?.passphrase == secret)
    #expect(executed.stdout?.contains(secret) == false)
    #expect(executed.stdout?.contains("Private locked body") == false)
    #expect(executed.stdout?.contains("NOTES_TEST_PASSPHRASE") == false)
  }

  @Test func settingsLockedNotesCustomPasswordUsesPrivatePassphraseManagerAndSecretBoundary() throws {
    let secret = "correct horse battery staple"
    let hint = "project hint"
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "locked-notes", "--account", "iCloud", "--scope", "custom",
      "--passphrase-env", "NOTES_TEST_PASSPHRASE", "--hint", hint,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])
    let dryRunOutput = dryRun.stdout ?? ""

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.settings.locked-notes")
    #expect(dryRunArgs["setting_id"] as? String == "locked_notes")
    #expect((dryRunArgs["account_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["scope"] as? String == "custom")
    #expect(dryRunArgs["passphrase_source_kind"] as? String == "env")
    #expect((dryRunArgs["passphrase_source_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["locked_notes_state_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["hint_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["hint_length"] as? String == "\(hint.utf8.count)")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.customPassphraseDrafts.isEmpty)
    #expect(dryRunOutput.contains("iCloud") == false)
    #expect(dryRunOutput.contains("NOTES_TEST_PASSPHRASE") == false)
    #expect(dryRunOutput.contains(secret) == false)
    #expect(dryRunOutput.contains(hint) == false)

    setenv("NOTES_TEST_PASSPHRASE", secret, 1)
    defer { unsetenv("NOTES_TEST_PASSPHRASE") }
    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "settings", "locked-notes", "--account", "iCloud", "--scope", "custom",
        "--passphrase-env", "NOTES_TEST_PASSPHRASE", "--hint", hint, "--json",
      ]))
      Issue.record("Expected locked-notes password setup without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(missingAllowImplementation.customPassphraseDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "locked-notes", "--account", "iCloud", "--scope", "custom",
      "--passphrase-env", "NOTES_TEST_PASSPHRASE", "--hint", hint,
      "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = executed.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.settings.locked-notes")
    #expect(data["changed"] as? Bool == true)
    #expect(data["settingID"] as? String == "locked_notes")
    #expect(data["valueKind"] as? String == "account_passphrase_state")
    #expect((data["accountSHA256"] as? String)?.count == 64)
    #expect((data["valueSHA256"] as? String)?.count == 64)
    #expect((data["beforeValueSHA256"] as? String)?.count == 64)
    #expect((data["afterValueSHA256"] as? String)?.count == 64)
    #expect(data["passphraseSourceKind"] as? String == "env")
    #expect((data["hintSHA256"] as? String)?.count == 64)
    #expect(data["hintLength"] as? Int == hint.utf8.count)
    #expect(data["backendCalls"] as? String == "ICAccountPassphraseManager.setPassphrase:hint:")
    #expect(verification["verified"] as? Bool == true)
    #expect(verification["evidenceLevel"] as? String == "ICAccountPassphraseManager.setPassphrase+account_crypto_strategy_readback+secret_source_boundary")
    #expect(checkNames.contains("passphrase_source_supported"))
    #expect(checkNames.contains("private_passphrase_manager_implementation"))
    #expect(checkNames.contains("hint_hash_boundary"))
    #expect(checkNames.contains("account_hash_accounting"))
    #expect(implementation.customPassphraseDrafts.count == 1)
    #expect(implementation.customPassphraseDrafts.first?.account == "iCloud")
    #expect(implementation.customPassphraseDrafts.first?.passphrase == secret)
    #expect(implementation.customPassphraseDrafts.first?.hint == hint)
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("NOTES_TEST_PASSPHRASE") == false)
    #expect(output.contains(secret) == false)
    #expect(output.contains(hint) == false)

    let invalidLoginMethodImplementation = StateAuditImplementation()
    let invalidLoginMethodCommand = NotesCommand(implementation: invalidLoginMethodImplementation)
    do {
      _ = try invalidLoginMethodCommand.run(options: try CLIOptionsFixture.parse([
        "settings", "locked-notes", "--account", "iCloud", "--scope", "login-password",
        "--passphrase-env", "NOTES_TEST_PASSPHRASE", "--json",
      ]))
      Issue.record("Expected login-password Notes method selection to reject custom passphrase input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["operation"] == "notes.settings.locked-notes")
      #expect(error.details["scope"] == "login-password")
      #expect(error.details["unsupported_options"] == "--passphrase-env")
      #expect(invalidLoginMethodImplementation.lockedNotesMethodDrafts.isEmpty)
    }
  }

  @Test func settingsLockedNotesLoginPasswordUsesPrivateModeWriterAndPreflightBoundary() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "locked-notes", "--account", "iCloud", "--scope", "login-password",
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])
    let dryRunOutput = dryRun.stdout ?? ""

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.settings.locked-notes")
    #expect(dryRunArgs["setting_id"] as? String == "locked_notes_method")
    #expect((dryRunArgs["account_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["scope"] as? String == "login-password")
    #expect((dryRunArgs["locked_notes_mode_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["locked_notes_mode_raw_value"] as? String == "2")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.lockedNotesMethodDrafts.isEmpty)
    #expect(dryRunOutput.contains("iCloud") == false)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "settings", "locked-notes", "--account", "iCloud", "--scope", "login-password", "--json",
      ]))
      Issue.record("Expected login-password locked-notes method selection without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(missingAllowImplementation.lockedNotesMethodDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "locked-notes", "--account", "iCloud", "--scope", "login-password",
      "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = executed.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.settings.locked-notes")
    #expect(data["changed"] as? Bool == true)
    #expect(data["settingID"] as? String == "locked_notes_method")
    #expect(data["valueKind"] as? String == "locked_notes_mode_state")
    #expect((data["accountSHA256"] as? String)?.count == 64)
    #expect((data["valueSHA256"] as? String)?.count == 64)
    #expect((data["beforeValueSHA256"] as? String)?.count == 64)
    #expect((data["afterValueSHA256"] as? String)?.count == 64)
    #expect(data["systemPasscodeAvailable"] as? Bool == true)
    #expect(data["lockedNotesModeSupported"] as? Bool == true)
    #expect(data["passwordProtectedNoteCountBefore"] as? Int == 0)
    #expect(data["backendCalls"] as? String == "ICAccount.setResolvedLockedNotesMode:")
    #expect(verification["verified"] as? Bool == true)
    #expect(verification["evidenceLevel"] as? String == "ICAccount.setResolvedLockedNotesMode+system_passcode_preflight+empty_protected_notes_preflight")
    #expect(checkNames.contains("system_passcode_precondition"))
    #expect(checkNames.contains("locked_notes_mode_supported"))
    #expect(checkNames.contains("no_existing_password_protected_notes_preflight"))
    #expect(checkNames.contains("private_locked_notes_mode_implementation"))
    #expect(checkNames.contains("account_hash_accounting"))
    #expect(implementation.lockedNotesMethodDrafts.count == 1)
    #expect(implementation.lockedNotesMethodDrafts.first?.account == "iCloud")
    #expect(implementation.lockedNotesMethodDrafts.first?.methodScope == "login-password")
    #expect(implementation.lockedNotesMethodDrafts.first?.modeRawValue == 2)
    #expect((implementation.lockedNotesMethodDrafts.first?.modeSHA256.count ?? 0) == 64)
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("NOTES_TEST_PASSPHRASE") == false)
  }

  @Test func settingsResetPasswordUsesPrivatePassphraseManagerResetBoundary() throws {
    let secret = "new correct horse battery staple"
    let hint = "reset hint"
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "reset-password", "--account", "iCloud",
      "--passphrase-env", "NOTES_TEST_RESET_PASSPHRASE", "--hint", hint,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])
    let dryRunOutput = dryRun.stdout ?? ""

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.settings.reset-password")
    #expect(dryRunArgs["setting_id"] as? String == "locked_notes")
    #expect((dryRunArgs["account_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["reset"] as? String == "true")
    #expect(dryRunArgs["passphrase_source_kind"] as? String == "env")
    #expect((dryRunArgs["passphrase_source_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["locked_notes_state_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["hint_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["hint_length"] as? String == "\(hint.utf8.count)")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.customPassphraseDrafts.isEmpty)
    #expect(dryRunOutput.contains("iCloud") == false)
    #expect(dryRunOutput.contains("NOTES_TEST_RESET_PASSPHRASE") == false)
    #expect(dryRunOutput.contains(secret) == false)
    #expect(dryRunOutput.contains(hint) == false)

    setenv("NOTES_TEST_RESET_PASSPHRASE", secret, 1)
    defer { unsetenv("NOTES_TEST_RESET_PASSPHRASE") }
    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "settings", "reset-password", "--account", "iCloud",
        "--passphrase-env", "NOTES_TEST_RESET_PASSPHRASE", "--hint", hint, "--json",
      ]))
      Issue.record("Expected reset-password without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(missingAllowImplementation.customPassphraseDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "reset-password", "--account", "iCloud",
      "--passphrase-env", "NOTES_TEST_RESET_PASSPHRASE", "--hint", hint,
      "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = executed.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.settings.reset-password")
    #expect(data["changed"] as? Bool == true)
    #expect(data["settingID"] as? String == "locked_notes")
    #expect(data["valueKind"] as? String == "account_passphrase_state")
    #expect((data["accountSHA256"] as? String)?.count == 64)
    #expect((data["valueSHA256"] as? String)?.count == 64)
    #expect((data["beforeValueSHA256"] as? String)?.count == 64)
    #expect((data["afterValueSHA256"] as? String)?.count == 64)
    #expect(data["passphraseSourceKind"] as? String == "env")
    #expect((data["hintSHA256"] as? String)?.count == 64)
    #expect(data["hintLength"] as? Int == hint.utf8.count)
    #expect(data["backendCalls"] as? String == "ICAccountPassphraseManager.setPassphrase:hint:isReset:")
    #expect(data["resetRequested"] as? Bool == true)
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("passphrase_source_supported"))
    #expect(checkNames.contains("private_passphrase_manager_implementation"))
    #expect(checkNames.contains("reset_passphrase_boundary"))
    #expect(checkNames.contains("hint_hash_boundary"))
    #expect(checkNames.contains("account_hash_accounting"))
    #expect(implementation.customPassphraseDrafts.count == 1)
    #expect(implementation.customPassphraseDrafts.first?.account == "iCloud")
    #expect(implementation.customPassphraseDrafts.first?.passphrase == secret)
    #expect(implementation.customPassphraseDrafts.first?.hint == hint)
    #expect(implementation.customPassphraseDrafts.first?.isReset == true)
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("NOTES_TEST_RESET_PASSPHRASE") == false)
    #expect(output.contains(secret) == false)
    #expect(output.contains(hint) == false)
  }

  @Test func settingsChangePasswordUsesPrivatePassphraseManagerChangeBoundary() throws {
    let oldSecret = "old correct horse battery staple"
    let newSecret = "new correct horse battery staple"
    let hint = "changed hint"
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "change-password", "--account", "iCloud",
      "--old-passphrase-env", "NOTES_TEST_OLD_PASSPHRASE",
      "--new-passphrase-env", "NOTES_TEST_NEW_PASSPHRASE",
      "--hint", hint, "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])
    let dryRunOutput = dryRun.stdout ?? ""

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.settings.change-password")
    #expect(dryRunArgs["setting_id"] as? String == "locked_notes")
    #expect((dryRunArgs["account_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["password_change"] as? String == "true")
    #expect(dryRunArgs["old_passphrase_source_kind"] as? String == "env")
    #expect(dryRunArgs["new_passphrase_source_kind"] as? String == "env")
    #expect((dryRunArgs["old_passphrase_source_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["new_passphrase_source_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["locked_notes_state_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["hint_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["hint_length"] as? String == "\(hint.utf8.count)")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.customPassphraseChangeDrafts.isEmpty)
    #expect(dryRunOutput.contains("iCloud") == false)
    #expect(dryRunOutput.contains("NOTES_TEST_OLD_PASSPHRASE") == false)
    #expect(dryRunOutput.contains("NOTES_TEST_NEW_PASSPHRASE") == false)
    #expect(dryRunOutput.contains(oldSecret) == false)
    #expect(dryRunOutput.contains(newSecret) == false)
    #expect(dryRunOutput.contains(hint) == false)

    setenv("NOTES_TEST_OLD_PASSPHRASE", oldSecret, 1)
    setenv("NOTES_TEST_NEW_PASSPHRASE", newSecret, 1)
    defer {
      unsetenv("NOTES_TEST_OLD_PASSPHRASE")
      unsetenv("NOTES_TEST_NEW_PASSPHRASE")
    }
    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "settings", "change-password", "--account", "iCloud",
        "--old-passphrase-env", "NOTES_TEST_OLD_PASSPHRASE",
        "--new-passphrase-env", "NOTES_TEST_NEW_PASSPHRASE",
        "--hint", hint, "--json",
      ]))
      Issue.record("Expected change-password without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(missingAllowImplementation.customPassphraseChangeDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "change-password", "--account", "iCloud",
      "--old-passphrase-env", "NOTES_TEST_OLD_PASSPHRASE",
      "--new-passphrase-env", "NOTES_TEST_NEW_PASSPHRASE",
      "--hint", hint, "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = executed.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.settings.change-password")
    #expect(data["changed"] as? Bool == true)
    #expect(data["settingID"] as? String == "locked_notes")
    #expect(data["valueKind"] as? String == "account_passphrase_state")
    #expect((data["accountSHA256"] as? String)?.count == 64)
    #expect((data["valueSHA256"] as? String)?.count == 64)
    #expect((data["beforeValueSHA256"] as? String)?.count == 64)
    #expect((data["afterValueSHA256"] as? String)?.count == 64)
    #expect(data["oldPassphraseSourceKind"] as? String == "env")
    #expect(data["newPassphraseSourceKind"] as? String == "env")
    #expect((data["hintSHA256"] as? String)?.count == 64)
    #expect(data["hintLength"] as? Int == hint.utf8.count)
    #expect(data["backendCalls"] as? String == "ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:")
    #expect(data["passwordChangeRequested"] as? Bool == true)
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("passphrase_source_supported"))
    #expect(checkNames.contains("private_passphrase_manager_implementation"))
    #expect(checkNames.contains("change_passphrase_boundary"))
    #expect(checkNames.contains("old_new_passphrase_source_boundary"))
    #expect(checkNames.contains("hint_hash_boundary"))
    #expect(checkNames.contains("account_hash_accounting"))
    #expect(implementation.customPassphraseChangeDrafts.count == 1)
    #expect(implementation.customPassphraseChangeDrafts.first?.account == "iCloud")
    #expect(implementation.customPassphraseChangeDrafts.first?.oldPassphrase == oldSecret)
    #expect(implementation.customPassphraseChangeDrafts.first?.newPassphrase == newSecret)
    #expect(implementation.customPassphraseChangeDrafts.first?.hint == hint)
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("NOTES_TEST_OLD_PASSPHRASE") == false)
    #expect(output.contains("NOTES_TEST_NEW_PASSPHRASE") == false)
    #expect(output.contains(oldSecret) == false)
    #expect(output.contains(newSecret) == false)
    #expect(output.contains(hint) == false)
  }

  @Test func lockAndRemoveLockUsePrivateLockManagerAndVerifier() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "lock", "--id", "note-local", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.lock")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["action"] as? String == "lock")
    #expect(dryRunArgs["capability"] as? String == "note_lock_state_mutation")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.noteLockMutationDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "lock", "--id", "note-local", "--json",
      ]))
      Issue.record("Expected state lock without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.noteLockMutationDrafts.isEmpty)
    }

    let lockImplementation = StateAuditImplementation()
    let lockCommand = NotesCommand(implementation: lockImplementation)
    let lockResult = try #require(try lockCommand.run(options: try CLIOptionsFixture.parse([
      "state", "lock", "--id", "note-local", "--allow-persistent-action", "--json",
    ])))
    let lockObject = try jsonObject(lockResult.stdout ?? "")
    let lockData = try #require(lockObject["data"] as? [String: Any])
    let lockVerification = try #require(lockData["verification"] as? [String: Any])
    let lockChecks = try #require(lockVerification["checks"] as? [[String: Any]])
    let lockCheckNames = Set(lockChecks.compactMap { $0["name"] as? String })

    #expect(lockObject["ok"] as? Bool == true)
    #expect(lockData["operation"] as? String == "notes.state.lock")
    #expect(lockData["changed"] as? Bool == true)
    #expect(lockData["action"] as? String == "lock")
    #expect(lockData["beforePasswordProtected"] as? Bool == false)
    #expect(lockData["afterPasswordProtected"] as? Bool == true)
    #expect(lockData["backendCalls"] as? String == "ICNoteLockManager.addLock")
    #expect(lockVerification["verified"] as? Bool == true)
    #expect(lockVerification["verifier"] as? String == "notes_lock_state_mutation_v1")
    #expect(lockCheckNames.contains("private_note_lock_manager_implementation"))
    #expect(lockCheckNames.contains("requested_lock_state_readback"))
    #expect(lockImplementation.noteLockMutationDrafts == [NotesNoteLockMutationDraft(noteID: "note-local", action: "lock")])
    #expect(lockResult.stdout?.contains("Local private body") == false)

    let removeImplementation = StateAuditImplementation()
    let removeCommand = NotesCommand(implementation: removeImplementation)
    let removeResult = try #require(try removeCommand.run(options: try CLIOptionsFixture.parse([
      "state", "remove-lock", "--id", "note-unlocked-protected", "--allow-persistent-action", "--json",
    ])))
    let removeObject = try jsonObject(removeResult.stdout ?? "")
    let removeData = try #require(removeObject["data"] as? [String: Any])
    let removeVerification = try #require(removeData["verification"] as? [String: Any])

    #expect(removeObject["ok"] as? Bool == true)
    #expect(removeData["operation"] as? String == "notes.state.remove-lock")
    #expect(removeData["changed"] as? Bool == true)
    #expect(removeData["action"] as? String == "remove-lock")
    #expect(removeData["beforePasswordProtected"] as? Bool == true)
    #expect(removeData["beforePasswordProtectedAndLocked"] as? Bool == false)
    #expect(removeData["afterPasswordProtected"] as? Bool == false)
    #expect(removeData["afterPasswordProtectedAndLocked"] as? Bool == false)
    #expect(removeData["backendCalls"] as? String == "ICNoteLockManager.removeLock")
    #expect(removeVerification["verified"] as? Bool == true)
    #expect(removeImplementation.noteLockMutationDrafts == [
      NotesNoteLockMutationDraft(noteID: "note-unlocked-protected", action: "remove-lock"),
    ])
    #expect(removeResult.stdout?.contains("Unlocked protected body") == false)
  }

  @Test func exportLockedContentUsesSessionUnlockedPrivateReadbackAndArtifactSafety() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("NotesLockedContentExportTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("locked.txt").path

    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "export-locked-content", "--id", "note-unlocked-protected", "--output", destination,
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.export-locked-content")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["output_path_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["capability"] as? String == "session_unlocked_locked_content_export")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-artifact-action"])
    #expect(FileManager.default.fileExists(atPath: destination) == false)
    #expect(dryRunImplementation.lockedContentExportDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "export-locked-content", "--id", "note-unlocked-protected", "--output", destination, "--json",
      ]))
      Issue.record("Expected locked-content export without --allow-artifact-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-artifact-action")
      #expect(error.details["risk"] == "artifactAction")
    }
    #expect(missingAllowImplementation.lockedContentExportDrafts.isEmpty)

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let executed = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "export-locked-content", "--id", "note-unlocked-protected", "--output", destination,
      "--allow-artifact-action", "--json",
    ])))
    let object = try jsonObject(executed.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let artifact = try #require(data["artifact"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let artifactText = try String(contentsOfFile: destination, encoding: .utf8)
    let artifactData = Data(artifactText.utf8)

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.export-locked-content")
    #expect(data["changed"] as? Bool == true)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["isPasswordProtected"] as? Bool == true)
    #expect(data["isPasswordProtectedAndLocked"] as? Bool == false)
    #expect(data["contentByteCount"] as? Int == artifactData.count)
    #expect(data["contentSHA256"] as? String == sha256Hex(artifactData))
    #expect(data["backendCalls"] as? String == "ICNote.noteAsPlainTextWithoutTitle")
    #expect(artifact["destinationPath"] as? String == destination)
    #expect(artifact["byteCount"] as? Int == artifactData.count)
    #expect(artifact["sha256"] as? String == sha256Hex(artifactData))
    #expect(artifact["contentKind"] as? String == "session_unlocked_locked_note_plain_text")
    #expect(artifactText == "Unlocked protected body")
    #expect(verification["verified"] as? Bool == true)
    #expect(verification["verifier"] as? String == "notes_locked_content_export_v1")
    #expect(checkNames.contains("session_unlocked_locked_note_readback"))
    #expect(checkNames.contains("artifact_text_readback"))
    #expect(implementation.lockedContentExportDrafts == [
      NotesLockedContentExportDraft(noteID: "note-unlocked-protected"),
    ])
    #expect(executed.stdout?.contains("Unlocked protected body") == false)

    let lockedImplementation = StateAuditImplementation()
    let lockedCommand = NotesCommand(implementation: lockedImplementation)
    let stillLockedDestination = root.appendingPathComponent("still-locked.txt").path
    do {
      _ = try lockedCommand.run(options: try CLIOptionsFixture.parse([
        "state", "export-locked-content", "--id", "note-locked",
        "--output", stillLockedDestination,
        "--allow-artifact-action", "--json",
      ]))
      Issue.record("Expected still-locked note export to require future unlock flow.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(error.details["future_gate"] == "secret_safe_authentication_session")
      #expect(error.details["required_state"] == nil || error.details["required_state"] == "password_protected_unlocked_note")
    }
    #expect(FileManager.default.fileExists(atPath: stillLockedDestination) == false)

    let passphraseFile = root.appendingPathComponent("passphrase.txt")
    try "correct horse battery staple\n".write(to: passphraseFile, atomically: true, encoding: .utf8)

    let missingPersistentImplementation = StateAuditImplementation()
    let missingPersistentCommand = NotesCommand(implementation: missingPersistentImplementation)
    do {
      _ = try missingPersistentCommand.run(options: try CLIOptionsFixture.parse([
        "state", "export-locked-content", "--id", "note-locked",
        "--output", root.appendingPathComponent("missing-persistent.txt").path,
        "--passphrase-file", passphraseFile.path,
        "--allow-artifact-action", "--json",
      ]))
      Issue.record("Expected locked-content export with passphrase to require --allow-persistent-action.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(error.details["risk"] == "persistentAction")
    }
    #expect(missingPersistentImplementation.lockedContentExportDrafts.isEmpty)

    let authenticatedDestination = root.appendingPathComponent("authenticated.txt").path
    let authenticatedImplementation = StateAuditImplementation()
    let authenticatedCommand = NotesCommand(implementation: authenticatedImplementation)
    let authenticated = try #require(try authenticatedCommand.run(options: try CLIOptionsFixture.parse([
      "state", "export-locked-content", "--id", "note-locked",
      "--output", authenticatedDestination,
      "--passphrase-file", passphraseFile.path,
      "--allow-artifact-action", "--allow-persistent-action", "--json",
    ])))
    let authenticatedObject = try jsonObject(authenticated.stdout ?? "")
    let authenticatedData = try #require(authenticatedObject["data"] as? [String: Any])
    let authenticatedArtifact = try #require(authenticatedData["artifact"] as? [String: Any])
    let authenticatedVerification = try #require(authenticatedData["verification"] as? [String: Any])
    let authenticatedChecks = try #require(authenticatedVerification["checks"] as? [[String: Any]])
    let authenticatedCheckNames = Set(authenticatedChecks.compactMap { $0["name"] as? String })
    let authenticatedText = try String(contentsOfFile: authenticatedDestination, encoding: .utf8)
    let authenticatedDataBytes = Data(authenticatedText.utf8)

    #expect(authenticatedObject["ok"] as? Bool == true)
    #expect(authenticatedData["operation"] as? String == "notes.state.export-locked-content")
    #expect(authenticatedData["changed"] as? Bool == true)
    #expect(authenticatedData["passphraseSourceKind"] as? String == "file")
    #expect(authenticatedData["isPasswordProtected"] as? Bool == true)
    #expect(authenticatedData["isPasswordProtectedAndLocked"] as? Bool == false)
    #expect(authenticatedData["authenticatedDuringExport"] as? Bool == true)
    #expect(authenticatedData["backendCalls"] as? String == "ICAuthenticationState.authenticateObject:withPassphrase:+ICNote.noteAsPlainTextWithoutTitle")
    #expect(authenticatedArtifact["contentKind"] as? String == "authenticated_locked_note_plain_text")
    #expect(authenticatedArtifact["byteCount"] as? Int == authenticatedDataBytes.count)
    #expect(authenticatedArtifact["sha256"] as? String == sha256Hex(authenticatedDataBytes))
    #expect(authenticatedText == "Private locked body")
    #expect(authenticatedVerification["verified"] as? Bool == true)
    #expect(authenticatedCheckNames.contains("secret_safe_authentication_session"))
    #expect(authenticatedCheckNames.contains("passphrase_source_supported_when_present"))
    #expect(authenticatedImplementation.lockedContentExportDrafts.count == 1)
    #expect(authenticatedImplementation.lockedContentExportDrafts.first?.noteID == "note-locked")
    #expect(authenticatedImplementation.lockedContentExportDrafts.first?.passphraseSourceKind == "file")
    #expect(authenticatedImplementation.noteUnlockDrafts == [
      NotesNoteUnlockDraft(
        noteID: "note-locked",
        passphrase: "correct horse battery staple",
        passphraseSourceKind: "file"
      ),
    ])
    #expect(authenticated.stdout?.contains("correct horse battery staple") == false)
    #expect(authenticated.stdout?.contains(passphraseFile.path) == false)
    #expect(authenticated.stdout?.contains("Private locked body") == false)
  }

  @Test func shareAndInviteUsePrivateParticipantLookupAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "share", "--id", "note-archive", "--target", "new@example.com",
      "--scope", "read-write", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.share")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["participant_target_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["requested_permission"] as? String == "read-write")
    #expect(dryRunArgs["capability"] as? String == "collaboration_share_mutation")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationShareDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains("new@example.com") == false)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "share", "--id", "note-archive", "--target", "new@example.com",
        "--scope", "read-write", "--json",
      ]))
      Issue.record("Expected collaboration share without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationShareDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "share", "--id", "note-archive", "--target", "new@example.com",
      "--scope", "read-write", "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.share")
    #expect(data["changed"] as? Bool == true)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["targetSHA256"] as? String)?.count == 64)
    #expect((data["targetParticipantIDSHA256"] as? String)?.count == 64)
    #expect(data["requestedPermissionValue"] as? Int == 3)
    #expect(data["requestedPermissionLabel"] as? String == "read-write")
    #expect(data["beforeWasShared"] as? Bool == false)
    #expect(data["afterWasShared"] as? Bool == true)
    #expect(data["beforeParticipantCount"] as? Int == 0)
    #expect(data["afterParticipantCount"] as? Int == 1)
    #expect(data["targetPresentBefore"] as? Bool == false)
    #expect(data["targetPresentAfter"] as? Bool == true)
    #expect(data["afterPermissionValue"] as? Int == 3)
    #expect(data["afterPermissionLabel"] as? String == "read-write")
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect((data["shareURLSHA256"] as? String)?.count == 64)
    #expect(data["backendCalls"] as? String == "CKContainer.fetchShareParticipant+CKShare.addParticipant+ICCollaborationController.saveServerShare")
    #expect(verification["operation"] as? String == "notes.state.share")
    #expect(verification["verifier"] as? String == "notes_collaboration_share_mutation_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("share_target_preflight"))
    #expect(checkNames.contains("private_participant_lookup_implementation"))
    #expect(checkNames.contains("participant_delta_readback"))
    #expect(checkNames.contains("permission_enum_readback"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationShareDrafts == [
      NotesCollaborationShareMutationDraft(
        operation: "notes.state.share",
        noteID: "note-archive",
        target: "new@example.com",
        permissionValue: 3,
        permissionLabel: "read-write",
        createShareIfNeeded: true
      ),
    ])
    #expect(output.contains("new@example.com") == false)
    #expect(output.contains("Archive Plan") == false)
    #expect(output.contains("Private archive body") == false)

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "share-folder", "--folder", "Archive", "--target", "folder-new@example.com",
      "--scope", "read-only", "--allow-persistent-action", "--json",
    ])))
    let folderOutput = folderResult.stdout ?? ""
    let folderObject = try jsonObject(folderOutput)
    let folderData = try #require(folderObject["data"] as? [String: Any])
    let folderVerification = try #require(folderData["verification"] as? [String: Any])

    #expect(folderObject["ok"] as? Bool == true)
    #expect(folderData["operation"] as? String == "notes.state.share-folder")
    #expect(folderData["targetKind"] as? String == "folder")
    #expect((folderData["folderIDSHA256"] as? String)?.count == 64)
    #expect(folderData["requestedPermissionValue"] as? Int == 2)
    #expect(folderData["afterParticipantCount"] as? Int == 1)
    #expect(folderVerification["verified"] as? Bool == true)
    #expect(folderImplementation.collaborationShareDrafts == [
      NotesCollaborationShareMutationDraft(
        operation: "notes.state.share-folder",
        folderID: "folder-archive",
        target: "folder-new@example.com",
        permissionValue: 2,
        permissionLabel: "read-only",
        createShareIfNeeded: true
      ),
    ])
    #expect(folderOutput.contains("Archive") == false)
    #expect(folderOutput.contains("folder-new@example.com") == false)

    let inviteImplementation = StateAuditImplementation()
    let inviteCommand = NotesCommand(implementation: inviteImplementation)
    let inviteResult = try #require(try inviteCommand.run(options: try CLIOptionsFixture.parse([
      "state", "invite", "--id", "note-shared-editable", "--target", "invite@example.com",
      "--scope", "read-only", "--allow-persistent-action", "--json",
    ])))
    let inviteOutput = inviteResult.stdout ?? ""
    let inviteObject = try jsonObject(inviteOutput)
    let inviteData = try #require(inviteObject["data"] as? [String: Any])
    let inviteVerification = try #require(inviteData["verification"] as? [String: Any])
    let inviteChecks = try #require(inviteVerification["checks"] as? [[String: Any]])
    let inviteCheckNames = Set(inviteChecks.compactMap { $0["name"] as? String })

    #expect(inviteObject["ok"] as? Bool == true)
    #expect(inviteData["operation"] as? String == "notes.state.invite")
    #expect(inviteData["targetKind"] as? String == "note")
    #expect(inviteData["beforeWasShared"] as? Bool == true)
    #expect(inviteData["afterWasShared"] as? Bool == true)
    #expect(inviteData["beforeParticipantCount"] as? Int == 2)
    #expect(inviteData["afterParticipantCount"] as? Int == 3)
    #expect(inviteData["requestedPermissionValue"] as? Int == 2)
    #expect(inviteVerification["verified"] as? Bool == true)
    #expect(inviteCheckNames.contains("existing_share_preflight"))
    #expect(inviteImplementation.collaborationShareDrafts == [
      NotesCollaborationShareMutationDraft(
        operation: "notes.state.invite",
        noteID: "note-shared-editable",
        target: "invite@example.com",
        permissionValue: 2,
        permissionLabel: "read-only",
        createShareIfNeeded: false
      ),
    ])
    #expect(inviteOutput.contains("invite@example.com") == false)
    #expect(inviteOutput.contains("Shared Plan") == false)
    #expect(inviteOutput.contains("Private shared body") == false)
  }

  @Test func shareAccessScopeUsesPrivatePublicPermissionReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "share", "--id", "note-shared-editable", "--scope", "invited-only", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.share")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["requested_access_scope"] as? String == "invited-only")
    #expect(dryRunArgs["capability"] as? String == "collaboration_access_scope_mutation")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationAccessScopeDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "share", "--id", "note-shared-editable", "--scope", "invited-only", "--json",
      ]))
      Issue.record("Expected share access-scope mutation without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationAccessScopeDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "share", "--id", "note-shared-editable", "--scope", "invited-only",
      "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.share")
    #expect(data["changed"] as? Bool == true)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["folderIDSHA256"] == nil)
    #expect(data["requestedAccessScopeLabel"] as? String == "invited-only")
    #expect(data["requestedPublicPermissionValue"] as? Int == 1)
    #expect(data["requestedPublicPermissionLabel"] as? String == "none")
    #expect(data["beforeAccessScopeLabel"] as? String == "anyone-with-link")
    #expect(data["beforePublicPermissionValue"] as? Int == 2)
    #expect(data["beforePublicPermissionLabel"] as? String == "read-only")
    #expect(data["afterAccessScopeLabel"] as? String == "invited-only")
    #expect(data["afterPublicPermissionValue"] as? Int == 1)
    #expect(data["afterPublicPermissionLabel"] as? String == "none")
    #expect(data["wasShared"] as? Bool == true)
    #expect(data["participantCount"] as? Int == 2)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect(data["backendCalls"] as? String == "CKShare.publicPermission+ICCollaborationController.saveServerShare")
    #expect(verification["operation"] as? String == "notes.state.share")
    #expect(verification["verifier"] as? String == "notes_collaboration_access_scope_mutation_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_note_preflight"))
    #expect(checkNames.contains("private_access_scope_implementation"))
    #expect(checkNames.contains("requested_access_scope_readback"))
    #expect(checkNames.contains("public_permission_enum_readback"))
    #expect(checkNames.contains("before_after_delta_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationAccessScopeDrafts == [
      NotesCollaborationAccessScopeMutationDraft(
        noteID: "note-shared-editable",
        accessScopeLabel: "invited-only"
      ),
    ])
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains(StateAuditImplementation.sharedNoteLink) == false)

    let folderDryRunImplementation = StateAuditImplementation()
    let folderDryRunCommand = NotesCommand(implementation: folderDryRunImplementation)
    let folderDryRun = try #require(try folderDryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "share", "--folder", "Private Shared Folder", "--scope", "invited-only",
      "--dry-run", "--json",
    ])))
    let folderDryRunObject = try jsonObject(folderDryRun.stdout ?? "")
    let folderDryRunData = try #require(folderDryRunObject["data"] as? [String: Any])
    let folderDryRunArgs = try #require(folderDryRunData["normalizedArguments"] as? [String: Any])

    #expect(folderDryRunObject["ok"] as? Bool == true)
    #expect(folderDryRunArgs["target_kind"] as? String == "folder")
    #expect((folderDryRunArgs["folder_id_sha256"] as? String)?.count == 64)
    #expect(folderDryRunArgs["requested_access_scope"] as? String == "invited-only")
    #expect(folderDryRunImplementation.collaborationAccessScopeDrafts.isEmpty)

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "share", "--folder", "Private Shared Folder", "--scope", "invited-only",
      "--allow-persistent-action", "--json",
    ])))
    let folderOutput = folderResult.stdout ?? ""
    let folderObject = try jsonObject(folderOutput)
    let folderData = try #require(folderObject["data"] as? [String: Any])
    let folderVerification = try #require(folderData["verification"] as? [String: Any])

    #expect(folderObject["ok"] as? Bool == true)
    #expect(folderData["operation"] as? String == "notes.state.share")
    #expect(folderData["targetKind"] as? String == "folder")
    #expect((folderData["targetIDSHA256"] as? String)?.count == 64)
    #expect(folderData["noteIDSHA256"] == nil)
    #expect((folderData["folderIDSHA256"] as? String)?.count == 64)
    #expect(folderData["requestedAccessScopeLabel"] as? String == "invited-only")
    #expect(folderData["afterAccessScopeLabel"] as? String == "invited-only")
    #expect(folderData["participantCount"] as? Int == 2)
    #expect(folderVerification["verified"] as? Bool == true)
    #expect(folderImplementation.collaborationAccessScopeDrafts == [
      NotesCollaborationAccessScopeMutationDraft(
        folderID: "folder-shared",
        accessScopeLabel: "invited-only"
      ),
    ])
    #expect(folderOutput.contains("Private Shared Folder") == false)
    #expect(folderOutput.contains(StateAuditImplementation.sharedFolderLink) == false)
  }

  @Test func stopSharingUsesPrivateShareAbsenceReadbackAndDestructiveSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "stop-sharing", "--id", "note-shared-editable", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.stop-sharing")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["capability"] as? String == "collaboration_stop_sharing")
    #expect(dryRunRequirements["allowFlags"] as? [String] == [
      "--allow-destructive-selection", "--allow-persistent-action",
    ])
    #expect(dryRunImplementation.collaborationStopSharingDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "stop-sharing", "--id", "note-shared-editable", "--allow-persistent-action", "--json",
      ]))
      Issue.record("Expected stop-sharing without --allow-destructive-selection to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationStopSharingDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "stop-sharing", "--id", "note-shared-editable",
      "--allow-destructive-selection", "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.stop-sharing")
    #expect(data["changed"] as? Bool == true)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["folderIDSHA256"] == nil)
    #expect(data["beforeWasShared"] as? Bool == true)
    #expect(data["afterWasShared"] as? Bool == false)
    #expect(data["beforeParticipantCount"] as? Int == 2)
    #expect(data["afterParticipantCount"] as? Int == 0)
    #expect((data["beforeShareRecordIDSHA256"] as? String)?.count == 64)
    #expect(data["afterShareRecordIDSHA256"] == nil)
    #expect(data["backendCalls"] as? String == "ICCollaborationController.removeShareIfNeededWithOwnedObjectID")
    #expect(verification["operation"] as? String == "notes.state.stop-sharing")
    #expect(verification["verifier"] as? String == "notes_collaboration_stop_sharing_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_note_preflight"))
    #expect(checkNames.contains("private_stop_sharing_implementation"))
    #expect(checkNames.contains("share_absence_readback"))
    #expect(checkNames.contains("participant_access_removed_readback"))
    #expect(checkNames.contains("before_after_delta_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationStopSharingDrafts == [
      NotesCollaborationStopSharingDraft(noteID: "note-shared-editable"),
    ])
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains(StateAuditImplementation.sharedNoteLink) == false)

    let folderDryRunImplementation = StateAuditImplementation()
    let folderDryRunCommand = NotesCommand(implementation: folderDryRunImplementation)
    let folderDryRun = try #require(try folderDryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "stop-sharing", "--folder", "Private Shared Folder", "--dry-run", "--json",
    ])))
    let folderDryRunObject = try jsonObject(folderDryRun.stdout ?? "")
    let folderDryRunData = try #require(folderDryRunObject["data"] as? [String: Any])
    let folderDryRunArgs = try #require(folderDryRunData["normalizedArguments"] as? [String: Any])
    let folderDryRunRequirements = try #require(folderDryRunData["requirements"] as? [String: Any])

    #expect(folderDryRunObject["ok"] as? Bool == true)
    #expect(folderDryRunArgs["target_kind"] as? String == "folder")
    #expect((folderDryRunArgs["folder_id_sha256"] as? String)?.count == 64)
    #expect(folderDryRunRequirements["allowFlags"] as? [String] == [
      "--allow-destructive-selection", "--allow-persistent-action",
    ])
    #expect(folderDryRunImplementation.collaborationStopSharingDrafts.isEmpty)

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "stop-sharing", "--folder", "Private Shared Folder",
      "--allow-destructive-selection", "--allow-persistent-action", "--json",
    ])))
    let folderOutput = folderResult.stdout ?? ""
    let folderObject = try jsonObject(folderOutput)
    let folderData = try #require(folderObject["data"] as? [String: Any])
    let folderVerification = try #require(folderData["verification"] as? [String: Any])

    #expect(folderObject["ok"] as? Bool == true)
    #expect(folderData["operation"] as? String == "notes.state.stop-sharing")
    #expect(folderData["changed"] as? Bool == true)
    #expect(folderData["targetKind"] as? String == "folder")
    #expect((folderData["targetIDSHA256"] as? String)?.count == 64)
    #expect(folderData["noteIDSHA256"] == nil)
    #expect((folderData["folderIDSHA256"] as? String)?.count == 64)
    #expect(folderData["beforeWasShared"] as? Bool == true)
    #expect(folderData["afterWasShared"] as? Bool == false)
    #expect(folderData["beforeParticipantCount"] as? Int == 2)
    #expect(folderData["afterParticipantCount"] as? Int == 0)
    #expect(folderVerification["verified"] as? Bool == true)
    #expect(folderImplementation.collaborationStopSharingDrafts == [
      NotesCollaborationStopSharingDraft(folderID: "folder-shared"),
    ])
    #expect(folderOutput.contains("Private Shared Folder") == false)
    #expect(folderOutput.contains(StateAuditImplementation.sharedFolderLink) == false)
  }

  @Test func allowInvitesUsesPrivateParticipantRoleReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "allow-invites", "--id", "note-shared-editable", "--enabled", "false", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.allow-invites")
    #expect(dryRunArgs["target_kind"] as? String == "note")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["requested_allows_invites"] as? String == "false")
    #expect(dryRunArgs["capability"] as? String == "collaboration_invite_policy_mutation")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationInvitePolicyDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "allow-invites", "--id", "note-shared-editable", "--enabled", "false", "--json",
      ]))
      Issue.record("Expected allow-invites without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationInvitePolicyDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "allow-invites", "--id", "note-shared-editable", "--enabled", "false",
      "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.allow-invites")
    #expect(data["changed"] as? Bool == true)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["folderIDSHA256"] == nil)
    #expect(data["requestedAllowsInvites"] as? Bool == false)
    #expect(data["beforeAllowsInvites"] as? Bool == true)
    #expect(data["afterAllowsInvites"] as? Bool == false)
    #expect(data["participantCount"] as? Int == 2)
    #expect(data["eligibleParticipantCount"] as? Int == 2)
    #expect(data["beforeAdministratorCount"] as? Int == 2)
    #expect(data["afterAdministratorCount"] as? Int == 0)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect(data["backendCalls"] as? String == "CKShareParticipant.role+ICCollaborationController.saveServerShare")
    #expect(verification["operation"] as? String == "notes.state.allow-invites")
    #expect(verification["verifier"] as? String == "notes_collaboration_invite_policy_mutation_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_note_preflight"))
    #expect(checkNames.contains("eligible_participant_role_readback"))
    #expect(checkNames.contains("private_invite_policy_implementation"))
    #expect(checkNames.contains("requested_invite_policy_readback"))
    #expect(checkNames.contains("before_after_delta_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationInvitePolicyDrafts == [
      NotesCollaborationAllowInvitesDraft(noteID: "note-shared-editable", enabled: false),
    ])
    #expect(output.contains("ada@example.com") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains(StateAuditImplementation.sharedNoteLink) == false)

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "allow-invites", "--folder", "Private Shared Folder", "--enabled", "false",
      "--allow-persistent-action", "--json",
    ])))
    let folderOutput = folderResult.stdout ?? ""
    let folderObject = try jsonObject(folderOutput)
    let folderData = try #require(folderObject["data"] as? [String: Any])
    let folderVerification = try #require(folderData["verification"] as? [String: Any])

    #expect(folderObject["ok"] as? Bool == true)
    #expect(folderData["operation"] as? String == "notes.state.allow-invites")
    #expect(folderData["targetKind"] as? String == "folder")
    #expect((folderData["targetIDSHA256"] as? String)?.count == 64)
    #expect(folderData["noteIDSHA256"] == nil)
    #expect((folderData["folderIDSHA256"] as? String)?.count == 64)
    #expect(folderData["requestedAllowsInvites"] as? Bool == false)
    #expect(folderData["beforeAllowsInvites"] as? Bool == true)
    #expect(folderData["afterAllowsInvites"] as? Bool == false)
    #expect(folderData["participantCount"] as? Int == 2)
    #expect(folderData["beforeAdministratorCount"] as? Int == 2)
    #expect(folderData["afterAdministratorCount"] as? Int == 0)
    #expect(folderVerification["verified"] as? Bool == true)
    #expect(folderImplementation.collaborationInvitePolicyDrafts == [
      NotesCollaborationAllowInvitesDraft(folderID: "folder-shared", enabled: false),
    ])
    #expect(folderOutput.contains("Private Shared Folder") == false)
    #expect(folderOutput.contains("ada@example.com") == false)
    #expect(folderOutput.contains(StateAuditImplementation.sharedFolderLink) == false)
  }

  @Test func removeSelfUsesPrivateCurrentUserParticipantReadbackAndDestructiveSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "remove-self", "--id", "note-shared", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.remove-self")
    #expect(dryRunArgs["target_kind"] as? String == "note")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["capability"] as? String == "collaboration_self_removal")
    #expect(dryRunRequirements["allowFlags"] as? [String] == [
      "--allow-destructive-selection", "--allow-persistent-action",
    ])
    #expect(dryRunImplementation.collaborationSelfRemovalDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "remove-self", "--id", "note-shared", "--allow-persistent-action", "--json",
      ]))
      Issue.record("Expected remove-self without --allow-destructive-selection to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationSelfRemovalDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "remove-self", "--id", "note-shared",
      "--allow-destructive-selection", "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.remove-self")
    #expect(data["changed"] as? Bool == true)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["folderIDSHA256"] == nil)
    #expect(data["beforeWasShared"] as? Bool == true)
    #expect(data["beforeCurrentUserPresent"] as? Bool == true)
    #expect(data["afterCurrentUserPresent"] as? Bool == false)
    #expect((data["currentUserParticipantIDSHA256"] as? String)?.count == 64)
    #expect((data["currentUserRecordNameSHA256"] as? String)?.count == 64)
    #expect(data["beforeParticipantCount"] as? Int == 3)
    #expect(data["afterParticipantCount"] as? Int == 2)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect(
      data["backendCalls"] as? String
        == "CKShare.removeParticipant(currentUserParticipant)+ICCollaborationController.saveServerShare"
    )
    #expect(verification["operation"] as? String == "notes.state.remove-self")
    #expect(verification["verifier"] as? String == "notes_collaboration_self_removal_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_target_preflight"))
    #expect(checkNames.contains("current_user_participant_resolved"))
    #expect(checkNames.contains("private_self_removal_implementation"))
    #expect(checkNames.contains("current_user_absence_readback"))
    #expect(checkNames.contains("before_after_delta_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationSelfRemovalDrafts == [
      NotesCollaborationSelfRemovalDraft(noteID: "note-shared"),
    ])
    #expect(output.contains("current-user@example.com") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains(StateAuditImplementation.sharedNoteLink) == false)

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "remove-self", "--folder", "Private Shared Folder",
      "--allow-destructive-selection", "--allow-persistent-action", "--json",
    ])))
    let folderOutput = folderResult.stdout ?? ""
    let folderObject = try jsonObject(folderOutput)
    let folderData = try #require(folderObject["data"] as? [String: Any])
    let folderVerification = try #require(folderData["verification"] as? [String: Any])

    #expect(folderObject["ok"] as? Bool == true)
    #expect(folderData["operation"] as? String == "notes.state.remove-self")
    #expect(folderData["targetKind"] as? String == "folder")
    #expect((folderData["targetIDSHA256"] as? String)?.count == 64)
    #expect(folderData["noteIDSHA256"] == nil)
    #expect((folderData["folderIDSHA256"] as? String)?.count == 64)
    #expect(folderData["beforeWasShared"] as? Bool == true)
    #expect(folderData["beforeCurrentUserPresent"] as? Bool == true)
    #expect(folderData["afterCurrentUserPresent"] as? Bool == false)
    #expect(folderData["beforeParticipantCount"] as? Int == 3)
    #expect(folderData["afterParticipantCount"] as? Int == 2)
    #expect(folderVerification["verified"] as? Bool == true)
    #expect(folderImplementation.collaborationSelfRemovalDrafts == [
      NotesCollaborationSelfRemovalDraft(folderID: "folder-shared"),
    ])
    #expect(folderOutput.contains("Private Shared Folder") == false)
    #expect(folderOutput.contains("current-user@example.com") == false)
    #expect(folderOutput.contains(StateAuditImplementation.sharedFolderLink) == false)
  }

  @Test func setPermissionUsesPrivateShareParticipantReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "set-permission", "--id", "note-shared-editable", "--target", "ada@example.com",
      "--scope", "read-only", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.set-permission")
    #expect(dryRunArgs["target_kind"] as? String == "note")
    #expect(dryRunArgs["requested_permission"] as? String == "read-only")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["target_sha256"] as? String)?.count == 64)
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationPermissionDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains("ada@example.com") == false)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "set-permission", "--id", "note-shared-editable", "--target", "ada@example.com",
        "--scope", "read-only", "--json",
      ]))
      Issue.record("Expected set-permission without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationPermissionDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "set-permission", "--id", "note-shared-editable", "--target", "ada@example.com",
      "--scope", "read-only", "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.set-permission")
    #expect(data["changed"] as? Bool == true)
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["folderIDSHA256"] == nil)
    #expect((data["targetSHA256"] as? String)?.count == 64)
    #expect((data["targetParticipantIDSHA256"] as? String)?.count == 64)
    #expect((data["targetUserRecordNameSHA256"] as? String)?.count == 64)
    #expect(data["requestedPermissionValue"] as? Int == 2)
    #expect(data["requestedPermissionLabel"] as? String == "read-only")
    #expect(data["beforePermissionValue"] as? Int == 3)
    #expect(data["beforePermissionLabel"] as? String == "read-write")
    #expect(data["afterPermissionValue"] as? Int == 2)
    #expect(data["afterPermissionLabel"] as? String == "read-only")
    #expect(data["wasShared"] as? Bool == true)
    #expect(data["participantCount"] as? Int == 2)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect(data["backendCalls"] as? String == "CKShareParticipant.permission+ICCollaborationController.saveServerShare")
    #expect(verification["operation"] as? String == "notes.state.set-permission")
    #expect(verification["verifier"] as? String == "notes_collaboration_permission_mutation_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_note_preflight"))
    #expect(checkNames.contains("participant_target_resolved"))
    #expect(checkNames.contains("private_permission_writer_implementation"))
    #expect(checkNames.contains("requested_permission_readback"))
    #expect(checkNames.contains("before_after_delta_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationPermissionDrafts == [
      NotesCollaborationPermissionMutationDraft(
        operation: "notes.state.set-permission",
        noteID: "note-shared-editable",
        target: "ada@example.com",
        permissionValue: 2,
        permissionLabel: "read-only"
      ),
    ])
    #expect(output.contains("ada@example.com") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Private shared body") == false)

    let folderDryRunImplementation = StateAuditImplementation()
    let folderDryRunCommand = NotesCommand(implementation: folderDryRunImplementation)
    let folderDryRun = try #require(try folderDryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "folder-permission", "--folder", "Private Shared Folder", "--target", "ada@example.com",
      "--scope", "read-only", "--dry-run", "--json",
    ])))
    let folderDryRunObject = try jsonObject(folderDryRun.stdout ?? "")
    let folderDryRunData = try #require(folderDryRunObject["data"] as? [String: Any])
    let folderDryRunArgs = try #require(folderDryRunData["normalizedArguments"] as? [String: Any])
    let folderDryRunRequirements = try #require(folderDryRunData["requirements"] as? [String: Any])

    #expect(folderDryRunObject["ok"] as? Bool == true)
    #expect(folderDryRunData["operation"] as? String == "notes.state.folder-permission")
    #expect(folderDryRunArgs["target_kind"] as? String == "folder")
    #expect((folderDryRunArgs["folder_id_sha256"] as? String)?.count == 64)
    #expect((folderDryRunArgs["target_sha256"] as? String)?.count == 64)
    #expect(folderDryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(folderDryRunImplementation.collaborationPermissionDrafts.isEmpty)
    #expect((folderDryRun.stdout ?? "").contains("Private Shared Folder") == false)
    #expect((folderDryRun.stdout ?? "").contains("ada@example.com") == false)

    let folderMissingAllowImplementation = StateAuditImplementation()
    let folderMissingAllowCommand = NotesCommand(implementation: folderMissingAllowImplementation)
    do {
      _ = try folderMissingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "folder-permission", "--folder", "Private Shared Folder", "--target", "ada@example.com",
        "--scope", "read-only", "--json",
      ]))
      Issue.record("Expected folder-permission without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(folderMissingAllowImplementation.collaborationPermissionDrafts.isEmpty)
    }

    let folderImplementation = StateAuditImplementation()
    let folderCommand = NotesCommand(implementation: folderImplementation)
    let folderResult = try #require(try folderCommand.run(options: try CLIOptionsFixture.parse([
      "state", "folder-permission", "--folder", "Private Shared Folder", "--target", "ada@example.com",
      "--scope", "read-only", "--allow-persistent-action", "--json",
    ])))
    let folderOutput = folderResult.stdout ?? ""
    let folderObject = try jsonObject(folderOutput)
    let folderData = try #require(folderObject["data"] as? [String: Any])
    let folderVerification = try #require(folderData["verification"] as? [String: Any])

    #expect(folderObject["ok"] as? Bool == true)
    #expect(folderData["operation"] as? String == "notes.state.folder-permission")
    #expect(folderData["changed"] as? Bool == true)
    #expect(folderData["targetKind"] as? String == "folder")
    #expect((folderData["targetIDSHA256"] as? String)?.count == 64)
    #expect(folderData["noteIDSHA256"] == nil)
    #expect((folderData["folderIDSHA256"] as? String)?.count == 64)
    #expect((folderData["targetSHA256"] as? String)?.count == 64)
    #expect((folderData["targetParticipantIDSHA256"] as? String)?.count == 64)
    #expect((folderData["targetUserRecordNameSHA256"] as? String)?.count == 64)
    #expect(folderData["requestedPermissionValue"] as? Int == 2)
    #expect(folderData["requestedPermissionLabel"] as? String == "read-only")
    #expect(folderData["beforePermissionValue"] as? Int == 3)
    #expect(folderData["beforePermissionLabel"] as? String == "read-write")
    #expect(folderData["afterPermissionValue"] as? Int == 2)
    #expect(folderData["afterPermissionLabel"] as? String == "read-only")
    #expect(folderData["wasShared"] as? Bool == true)
    #expect(folderData["participantCount"] as? Int == 2)
    #expect((folderData["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect(folderData["backendCalls"] as? String == "CKShareParticipant.permission+ICCollaborationController.saveServerShare")
    #expect(folderVerification["operation"] as? String == "notes.state.folder-permission")
    #expect(folderVerification["verifier"] as? String == "notes_collaboration_permission_mutation_v1")
    #expect(folderVerification["verified"] as? Bool == true)
    #expect(folderImplementation.collaborationPermissionDrafts == [
      NotesCollaborationPermissionMutationDraft(
        operation: "notes.state.folder-permission",
        folderID: "folder-shared",
        target: "ada@example.com",
        permissionValue: 2,
        permissionLabel: "read-only"
      ),
    ])
    #expect(folderOutput.contains("Private Shared Folder") == false)
    #expect(folderOutput.contains("ada@example.com") == false)
  }

  @Test func removeParticipantUsesPrivateShareParticipantReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "remove-participant", "--id", "note-shared-editable", "--target", "ada@example.com",
      "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.remove-participant")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["target_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["capability"] as? String == "collaboration_participant_removal")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationParticipantRemovalDrafts.isEmpty)
    #expect((dryRun.stdout ?? "").contains("ada@example.com") == false)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "remove-participant", "--id", "note-shared-editable", "--target", "ada@example.com", "--json",
      ]))
      Issue.record("Expected remove-participant without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(missingAllowImplementation.collaborationParticipantRemovalDrafts.isEmpty)
    }

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "remove-participant", "--id", "note-shared-editable", "--target", "ada@example.com",
      "--allow-persistent-action", "--json",
    ])))
    let output = result.stdout ?? ""
    let object = try jsonObject(output)
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.remove-participant")
    #expect(data["changed"] as? Bool == true)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect((data["targetSHA256"] as? String)?.count == 64)
    #expect((data["targetParticipantIDSHA256"] as? String)?.count == 64)
    #expect((data["targetUserRecordNameSHA256"] as? String)?.count == 64)
    #expect(data["beforeParticipantCount"] as? Int == 2)
    #expect(data["afterParticipantCount"] as? Int == 1)
    #expect(data["targetPresentAfter"] as? Bool == false)
    #expect(data["wasShared"] as? Bool == true)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect(data["backendCalls"] as? String == "CKShare.removeParticipant+ICCollaborationController.saveServerShare")
    #expect(verification["operation"] as? String == "notes.state.remove-participant")
    #expect(verification["verifier"] as? String == "notes_collaboration_participant_removal_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_note_preflight"))
    #expect(checkNames.contains("participant_target_resolved"))
    #expect(checkNames.contains("private_participant_removal_implementation"))
    #expect(checkNames.contains("target_participant_absence_readback"))
    #expect(checkNames.contains("before_after_delta_accounting"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationParticipantRemovalDrafts == [
      NotesCollaborationParticipantRemovalDraft(
        noteID: "note-shared-editable",
        target: "ada@example.com"
      ),
    ])
    #expect(output.contains("ada@example.com") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Private shared body") == false)
  }

  @Test func hideAlertsUsesPrivateSharedNotePreferenceReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "hide-alerts", "--id", "note-shared", "--enabled", "true", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.hide-alerts")
    #expect(dryRunArgs["requested_hidden"] as? String == "true")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.stateHideAlertsWrites.isEmpty)
    #expect(dryRunImplementation.noteStateReadIDs.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "hide-alerts", "--id", "note-shared", "--enabled", "true", "--json",
      ]))
      Issue.record("Expected shared-note Hide Alerts mutation without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(error.details["risk"] == "persistentAction")
    }
    #expect(missingAllowImplementation.stateHideAlertsWrites.isEmpty)

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "hide-alerts", "--id", "note-shared", "--enabled", "true",
      "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.hide-alerts")
    #expect(data["changed"] as? Bool == true)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect(data["requestedHidden"] as? Bool == true)
    #expect(data["beforeHidden"] as? Bool == false)
    #expect(data["afterHidden"] as? Bool == true)
    #expect((data["recordIDSHA256"] as? String)?.count == 64)
    #expect(data["wasShared"] as? Bool == true)
    #expect(data["participantCount"] as? Int == 2)
    #expect(verification["operation"] as? String == "notes.state.hide-alerts")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_note_state_preflight"))
    #expect(checkNames.contains("record_id_readback"))
    #expect(checkNames.contains("requested_alert_preference_readback"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.stateHideAlertsWrites == ["note-shared:true"])
    #expect(implementation.noteStateReadIDs.isEmpty)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Ada Lovelace") == false)
    #expect(output.contains("Grace Hopper") == false)
    #expect(output.contains("record-note-shared") == false)

    let nonSharedImplementation = StateAuditImplementation()
    let nonSharedCommand = NotesCommand(implementation: nonSharedImplementation)
    do {
      _ = try nonSharedCommand.run(options: try CLIOptionsFixture.parse([
        "state", "hide-alerts", "--id", "note-local", "--enabled", "true",
        "--allow-persistent-action", "--json",
      ]))
      Issue.record("Expected shared-note Hide Alerts to reject a non-shared note.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["operation"] == "notes.state.hide-alerts")
      #expect(error.details["required_state"] == "shared_note")
      #expect((error.details["note_id_sha256"] ?? "").count == 64)
      #expect(error.details.values.contains("note-local") == false)
    }
    #expect(nonSharedImplementation.stateHideAlertsWrites.isEmpty)
  }

  @Test func participantMentionUsesPrivateMentionAttachmentReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "mention", "--id", "note-shared-editable", "--target", "ada@example.com",
      "--text", "Private mention context", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])
    let dryRunOutput = dryRun.stdout ?? ""

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.mention")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["target_sha256"] as? String)?.count == 64)
    #expect((dryRunArgs["mention_text_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["mention_text_byte_count"] as? String == "23")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationMentionDrafts.isEmpty)
    #expect(dryRunOutput.contains("ada@example.com") == false)
    #expect(dryRunOutput.contains("Private mention context") == false)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "mention", "--id", "note-shared-editable", "--target", "ada@example.com",
        "--text", "Private mention context", "--json",
      ]))
      Issue.record("Expected participant mention without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(error.details["risk"] == "persistentAction")
    }
    #expect(missingAllowImplementation.collaborationMentionDrafts.isEmpty)

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "mention", "--id", "note-shared-editable", "--target", "ada@example.com",
      "--text", "Private mention context", "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.mention")
    #expect(data["changed"] as? Bool == true)
    #expect((data["noteIDSHA256"] as? String)?.count == 64)
    #expect((data["targetSHA256"] as? String)?.count == 64)
    #expect((data["targetParticipantIDSHA256"] as? String)?.count == 64)
    #expect((data["targetUserRecordNameSHA256"] as? String)?.count == 64)
    #expect((data["mentionTextSHA256"] as? String)?.count == 64)
    #expect(data["mentionTextByteCount"] as? Int == 23)
    #expect(data["beforeMentionCount"] as? Int == 0)
    #expect(data["afterMentionCount"] as? Int == 1)
    #expect(data["targetBeforeMentionCount"] as? Int == 0)
    #expect(data["targetAfterMentionCount"] as? Int == 1)
    #expect(data["participantCount"] as? Int == 2)
    #expect(data["backendCalls"] as? String == "ICInlineAttachment.newMentionAttachmentWithIdentifier+ICNote.textStorage")
    #expect(verification["verifier"] as? String == "notes_collaboration_mention_v1")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("private_mention_attachment_implementation"))
    #expect(checkNames.contains("mention_count_delta"))
    #expect(checkNames.contains("target_mention_count_delta"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.collaborationMentionDrafts == [
      NotesCollaborationMentionDraft(
        noteID: "note-shared-editable",
        target: "ada@example.com",
        text: "Private mention context"
      ),
    ])
    #expect(output.contains("ada@example.com") == false)
    #expect(output.contains("Private mention context") == false)
  }

  @Test func closeLockedUsesPrivateAuthenticationStateReadbackAndPersistentSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "close-locked", "--account", "iCloud", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.close-locked")
    #expect(dryRunArgs["scope"] as? String == "all_authenticated_locked_objects_after_account_preflight")
    #expect((dryRunArgs["account_selector_sha256"] as? String)?.count == 64)
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.lockedSessionCloseDrafts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "close-locked", "--account", "iCloud", "--json",
      ]))
      Issue.record("Expected locked-session close without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(error.details["risk"] == "persistentAction")
    }
    #expect(missingAllowImplementation.lockedSessionCloseDrafts.isEmpty)

    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "close-locked", "--account", "iCloud", "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.close-locked")
    #expect(data["changed"] as? Bool == true)
    #expect((data["accountSelectorSHA256"] as? String)?.count == 64)
    #expect((data["accountSHA256"] as? String)?.count == 64)
    #expect(data["scope"] as? String == "all_authenticated_locked_objects_after_account_preflight")
    #expect(data["beforeAuthenticated"] as? Bool == true)
    #expect(data["beforeHasAuthenticatedObject"] as? Bool == true)
    #expect(data["afterAuthenticated"] as? Bool == false)
    #expect(data["afterHasAuthenticatedObject"] as? Bool == false)
    #expect(data["backendCalls"] as? String == "ICAuthenticationState.deauthenticateAllObjects")
    #expect(verification["verified"] as? Bool == true)
    #expect(verification["evidenceLevel"] as? String == "private_authentication_state_deauthenticate_all_objects_readback")
    #expect(checkNames.contains("private_deauthenticate_all_objects_call"))
    #expect(checkNames.contains("locked_session_closed_readback"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(implementation.lockedSessionCloseDrafts == [NotesLockedSessionCloseDraft(account: "iCloud")])
    #expect(output.contains("Private locked body") == false)
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("hunter2") == false)
  }

  @Test func copyLinkUsesPrivateShareURLReadbackAndClipboardSafety() throws {
    let dryRunImplementation = StateAuditImplementation()
    let dryRunClipboard = StateAuditClipboardWriter()
    let dryRunCommand = NotesCommand(implementation: dryRunImplementation, clipboardWriter: dryRunClipboard)
    let dryRun = try #require(try dryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "copy-link", "--id", "note-shared", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["operation"] as? String == "notes.state.copy-link")
    #expect(dryRunArgs["target_kind"] as? String == "note")
    #expect((dryRunArgs["note_id_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["destination"] as? String == "clipboard")
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(dryRunImplementation.collaborationLinkReads.isEmpty)
    #expect(dryRunClipboard.writtenTexts.isEmpty)

    let missingAllowImplementation = StateAuditImplementation()
    let missingAllowClipboard = StateAuditClipboardWriter()
    let missingAllowCommand = NotesCommand(implementation: missingAllowImplementation, clipboardWriter: missingAllowClipboard)
    do {
      _ = try missingAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "copy-link", "--id", "note-shared", "--json",
      ]))
      Issue.record("Expected collaboration link copy without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
      #expect(error.details["risk"] == "persistentAction")
    }
    #expect(missingAllowImplementation.collaborationLinkReads.isEmpty)
    #expect(missingAllowClipboard.writtenTexts.isEmpty)

    let implementation = StateAuditImplementation()
    let clipboard = StateAuditClipboardWriter()
    let command = NotesCommand(implementation: implementation, clipboardWriter: clipboard)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "state", "copy-link", "--id", "note-shared", "--allow-persistent-action", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.state.copy-link")
    #expect(data["changed"] as? Bool == true)
    #expect(data["destination"] as? String == "clipboard")
    #expect(data["targetKind"] as? String == "note")
    #expect((data["targetIDSHA256"] as? String)?.count == 64)
    #expect((data["urlSHA256"] as? String)?.count == 64)
    #expect(data["urlByteCount"] as? Int == StateAuditImplementation.sharedNoteLink.utf8.count)
    #expect((data["shareRecordIDSHA256"] as? String)?.count == 64)
    #expect((data["ownerRecordNameSHA256"] as? String)?.count == 64)
    #expect(data["participantCount"] as? Int == 2)
    #expect(data["clipboardChangeCount"] as? Int == 1)
    #expect(clipboard.writtenTexts == [StateAuditImplementation.sharedNoteLink])
    #expect(implementation.collaborationLinkReads == [NotesCollaborationLinkDraft(noteID: "note-shared")])
    #expect(verification["operation"] as? String == "notes.state.copy-link")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("shared_state_preflight"))
    #expect(checkNames.contains("private_share_url_readback"))
    #expect(checkNames.contains("clipboard_text_readback"))
    #expect(checkNames.contains("clipboard_url_sha256"))
    #expect(checkNames.contains("clipboard_change_count"))
    #expect(checkNames.contains("privacy_boundary"))
    #expect(output.contains(StateAuditImplementation.sharedNoteLink) == false)
    #expect(output.contains("Private shared body") == false)
    #expect(output.contains("Shared Plan") == false)
    #expect(output.contains("Ada Lovelace") == false)
    #expect(output.contains("Grace Hopper") == false)

    let nonSharedImplementation = StateAuditImplementation()
    let nonSharedClipboard = StateAuditClipboardWriter()
    let nonSharedCommand = NotesCommand(implementation: nonSharedImplementation, clipboardWriter: nonSharedClipboard)
    do {
      _ = try nonSharedCommand.run(options: try CLIOptionsFixture.parse([
        "state", "copy-link", "--id", "note-local", "--allow-persistent-action", "--json",
      ]))
      Issue.record("Expected collaboration link copy to reject a non-shared note.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["operation"] == "notes.state.copy-link")
      #expect(error.details["required_state"] == "shared")
      #expect((error.details["note_id_sha256"] ?? "").count == 64)
      #expect(error.details.values.contains("note-local") == false)
    }
    #expect(nonSharedImplementation.collaborationLinkReads == [NotesCollaborationLinkDraft(noteID: "note-local")])
    #expect(nonSharedClipboard.writtenTexts.isEmpty)

    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent("NotesCollaborationLinkExportTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let destination = root.appendingPathComponent("shared-link.txt").path

    let exportDryRunImplementation = StateAuditImplementation()
    let exportDryRunClipboard = StateAuditClipboardWriter()
    let exportDryRunCommand = NotesCommand(implementation: exportDryRunImplementation, clipboardWriter: exportDryRunClipboard)
    let exportDryRun = try #require(try exportDryRunCommand.run(options: try CLIOptionsFixture.parse([
      "state", "copy-link", "--folder", "Private Shared Folder", "--output", destination,
      "--dry-run", "--json",
    ])))
    let exportDryRunObject = try jsonObject(exportDryRun.stdout ?? "")
    let exportDryRunData = try #require(exportDryRunObject["data"] as? [String: Any])
    let exportDryRunRequirements = try #require(exportDryRunData["requirements"] as? [String: Any])
    let exportDryRunArgs = try #require(exportDryRunData["normalizedArguments"] as? [String: Any])

    #expect(exportDryRunObject["ok"] as? Bool == true)
    #expect(exportDryRunData["operation"] as? String == "notes.state.copy-link")
    #expect(exportDryRunRequirements["allowFlags"] as? [String] == ["--allow-artifact-action"])
    #expect(exportDryRunArgs["destination"] as? String == "artifact")
    #expect((exportDryRunArgs["folder_id_sha256"] as? String)?.count == 64)
    #expect((exportDryRunArgs["output_path_sha256"] as? String)?.count == 64)
    #expect(FileManager.default.fileExists(atPath: destination) == false)
    #expect(exportDryRunImplementation.collaborationLinkReads.isEmpty)
    #expect(exportDryRunClipboard.writtenTexts.isEmpty)

    let missingArtifactAllowImplementation = StateAuditImplementation()
    let missingArtifactAllowClipboard = StateAuditClipboardWriter()
    let missingArtifactAllowCommand = NotesCommand(
      implementation: missingArtifactAllowImplementation,
      clipboardWriter: missingArtifactAllowClipboard
    )
    do {
      _ = try missingArtifactAllowCommand.run(options: try CLIOptionsFixture.parse([
        "state", "copy-link", "--folder", "Private Shared Folder", "--output", destination, "--json",
      ]))
      Issue.record("Expected collaboration link artifact export without --allow-artifact-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-artifact-action")
      #expect(error.details["risk"] == "artifactAction")
    }
    #expect(missingArtifactAllowImplementation.collaborationLinkReads.isEmpty)
    #expect(missingArtifactAllowClipboard.writtenTexts.isEmpty)

    let exportImplementation = StateAuditImplementation()
    let exportClipboard = StateAuditClipboardWriter()
    let exportCommand = NotesCommand(implementation: exportImplementation, clipboardWriter: exportClipboard)
    let exportResult = try #require(try exportCommand.run(options: try CLIOptionsFixture.parse([
      "state", "copy-link", "--folder", "Private Shared Folder", "--output", destination,
      "--allow-artifact-action", "--json",
    ])))
    let exportObject = try jsonObject(exportResult.stdout ?? "")
    let exportData = try #require(exportObject["data"] as? [String: Any])
    let exportArtifact = try #require(exportData["artifact"] as? [String: Any])
    let exportVerification = try #require(exportData["verification"] as? [String: Any])
    let exportChecks = try #require(exportVerification["checks"] as? [[String: Any]])
    let exportCheckNames = Set(exportChecks.compactMap { $0["name"] as? String })
    let artifactText = try String(contentsOfFile: destination, encoding: .utf8)
    let artifactData = Data(artifactText.utf8)

    #expect(exportObject["ok"] as? Bool == true)
    #expect(exportData["changed"] as? Bool == true)
    #expect(exportData["destination"] as? String == "artifact")
    #expect(exportData["targetKind"] as? String == "folder")
    #expect((exportData["targetIDSHA256"] as? String)?.count == 64)
    #expect((exportData["urlSHA256"] as? String)?.count == 64)
    #expect(exportData["urlByteCount"] as? Int == StateAuditImplementation.sharedFolderLink.utf8.count)
    #expect(exportData["clipboardChangeCount"] as? Int == 0)
    #expect(exportArtifact["destinationPath"] as? String == destination)
    #expect(exportArtifact["byteCount"] as? Int == artifactData.count)
    #expect(exportArtifact["sha256"] as? String == sha256Hex(artifactData))
    #expect(exportArtifact["contentKind"] as? String == "raw_collaboration_link")
    #expect(artifactText == StateAuditImplementation.sharedFolderLink)
    #expect(exportVerification["verified"] as? Bool == true)
    #expect(exportCheckNames.contains("artifact_text_readback"))
    #expect(exportCheckNames.contains("collaboration_link_readback_stable"))
    #expect(exportImplementation.collaborationLinkReads == [
      NotesCollaborationLinkDraft(folderID: "Private Shared Folder"),
      NotesCollaborationLinkDraft(folderID: "Private Shared Folder"),
    ])
    #expect(exportClipboard.writtenTexts.isEmpty)
    #expect((exportResult.stdout ?? "").contains(StateAuditImplementation.sharedFolderLink) == false)
  }

  @Test func settingsReadReturnsOfficialFamilyAccountingWithoutPrivateValues() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "settings", "read", "--account", "iCloud", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let families = try #require(data["families"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = try #require(verification["checks"] as? [[String: Any]])
    let byID = Dictionary(uniqueKeysWithValues: families.compactMap { family -> (String, [String: Any])? in
      guard let id = family["id"] as? String else { return nil }
      return (id, family)
    })
    let output = result.stdout ?? ""

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.settings.read")
    #expect(data["changed"] as? Bool == false)
    #expect(data["accountScope"] as? String == "selected")
    #expect((data["requestedAccountSHA256"] as? String)?.count == 64)
    #expect(data["selectedAccountCount"] as? Int == 1)
    #expect(data["accountCount"] as? Int == 2)
    #expect((data["defaultAccountIDSHA256"] as? String)?.count == 64)
    #expect(data["onMyMacAccountPresent"] as? Bool == true)
    #expect(families.count == notesSettingsOfficialFamilyIDs().count)
    #expect(byID["sort_notes_by"]?["status"] as? String == "supported")
    #expect(byID["sort_notes_by"]?["valueKind"] as? String == "note_list_sort_sha256")
    #expect((byID["sort_notes_by"]?["valueSHA256"] as? String)?.count == 64)
    #expect(byID["default_account"]?["status"] as? String == "supported")
    #expect(byID["default_account"]?["valueKind"] as? String == "account_id_sha256")
    #expect((byID["default_account"]?["valueSHA256"] as? String)?.count == 64)
    #expect(byID["new_notes_start_with"]?["status"] as? String == "supported")
    #expect(byID["new_notes_start_with"]?["valueKind"] as? String == "paragraph_style_sha256")
    #expect((byID["new_notes_start_with"]?["valueSHA256"] as? String)?.count == 64)
    #expect(byID["group_notes_by_date"]?["status"] as? String == "supported")
    #expect(byID["group_notes_by_date"]?["valueKind"] as? String == "bool")
    #expect(byID["group_notes_by_date"]?["boolValue"] as? Bool == true)
    #expect(byID["default_date_headers_type"]?["status"] as? String == "supported")
    #expect(byID["default_date_headers_type"]?["valueKind"] as? String == "date_headers_type_sha256")
    #expect((byID["default_date_headers_type"]?["valueSHA256"] as? String)?.count == 64)
    #expect(byID["query_date_headers_type"]?["status"] as? String == "supported")
    #expect(byID["query_date_headers_type"]?["valueKind"] as? String == "date_headers_type_sha256")
    #expect((byID["query_date_headers_type"]?["valueSHA256"] as? String)?.count == 64)
    #expect(data["supportsQueryDateHeaders"] as? Bool == true)
    #expect(data["showsQueryDateHeaders"] as? Bool == true)
    #expect(byID["always_resume_to_last_quick_note"]?["status"] as? String == "supported")
    #expect(byID["always_resume_to_last_quick_note"]?["valueKind"] as? String == "bool")
    #expect(byID["always_resume_to_last_quick_note"]?["boolValue"] as? Bool == true)
    #expect(byID["enable_on_my_mac_account"]?["status"] as? String == "supported")
    #expect(byID["enable_on_my_mac_account"]?["boolValue"] as? Bool == true)
    #expect(byID["automatically_sort_checked_items"]?["status"] as? String == "supported")
    #expect(byID["automatically_sort_checked_items"]?["valueKind"] as? String == "bool")
    #expect(byID["automatically_sort_checked_items"]?["boolValue"] as? Bool == true)
    #expect(byID["allow_mention_notifications"]?["status"] as? String == "supported")
    #expect(byID["allow_mention_notifications"]?["valueKind"] as? String == "bool")
    #expect(byID["allow_mention_notifications"]?["boolValue"] as? Bool == true)
    #expect(byID["default_text_size"]?["status"] as? String == "supported")
    #expect(byID["default_text_size"]?["valueKind"] as? String == "text_size_sha256")
    #expect((byID["default_text_size"]?["valueSHA256"] as? String)?.count == 64)
    #expect(byID["locked_notes"]?["status"] as? String == "supported")
    #expect(byID["locked_notes"]?["valueKind"] as? String == "account_passphrase_state")
    #expect(byID["locked_notes"]?["boolValue"] as? Bool == false)
    #expect((byID["locked_notes"]?["valueSHA256"] as? String)?.count == 64)
    #expect(byID["use_touch_id"]?["status"] as? String == "supported")
    #expect(byID["use_touch_id"]?["valueKind"] as? String == "account_scoped_bool")
    #expect(byID["use_touch_id"]?["boolValue"] as? Bool == true)
    #expect(verification["verified"] as? Bool == true)
    #expect(
      checks.contains {
        $0["name"] as? String == "official_settings_family_accounting"
          && $0["status"] as? String == "passed"
      })
    #expect(
      checks.contains {
        $0["name"] as? String == "supported_private_readback_accounting"
          && $0["status"] as? String == "passed"
      })
    #expect(output.contains("iCloud") == false)
    #expect(output.contains("private@example.com") == false)
    #expect(output.contains("account-icloud") == false)
    #expect(output.contains("account-local") == false)
    #expect(output.contains("Title") == false)
    #expect(output.contains("Heading") == false)
    #expect(implementation.noteStateReadIDs.isEmpty)
    #expect(implementation.readNoteLookups.isEmpty)
  }

  @Test func settingsPreferenceMutationsUsePrivateReadbackAndPersistentSafety() throws {
    let implementation = StateAuditImplementation()
    let command = NotesCommand(implementation: implementation)

    let dryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "new-note-style", "--style", "heading", "--dry-run", "--json",
    ])))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = try #require(dryRunObject["data"] as? [String: Any])
    let dryRunArgs = try #require(dryRunData["normalizedArguments"] as? [String: Any])
    let dryRunRequirements = try #require(dryRunData["requirements"] as? [String: Any])

    #expect(dryRunObject["ok"] as? Bool == true)
    #expect(dryRunData["mode"] as? String == "dry-run")
    #expect(dryRunData["operation"] as? String == "notes.settings.new-note-style")
    #expect((dryRunArgs["style_sha256"] as? String)?.count == 64)
    #expect(dryRunArgs["style"] as? String == nil)
    #expect(dryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(implementation.settingsWriteOperations.isEmpty)
    #expect((dryRun.stdout ?? "").contains("heading") == false)

    do {
      _ = try command.run(options: try CLIOptionsFixture.parse([
        "settings", "new-note-style", "--style", "monostyled", "--dry-run", "--json",
      ]))
      Issue.record("Expected monostyled default new-note style to be rejected.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("--style"))
      #expect(error.details["allowed"] == NotesBodyParagraphStyle.defaultNewNoteAllowedDescription)
      #expect(implementation.settingsWriteOperations.isEmpty)
    }

    let sortDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "sort", "--by", "date-created", "--direction", "oldest-first", "--dry-run", "--json",
    ])))
    let sortDryRunObject = try jsonObject(sortDryRun.stdout ?? "")
    let sortDryRunData = try #require(sortDryRunObject["data"] as? [String: Any])
    let sortDryRunArgs = try #require(sortDryRunData["normalizedArguments"] as? [String: Any])
    #expect(sortDryRunObject["ok"] as? Bool == true)
    #expect(sortDryRunData["operation"] as? String == "notes.settings.sort")
    #expect((sortDryRunArgs["sort_sha256"] as? String)?.count == 64)
    #expect(sortDryRunArgs["by"] as? String == nil)
    #expect(sortDryRunArgs["direction"] as? String == nil)
    #expect((sortDryRun.stdout ?? "").contains("date-created") == false)
    #expect((sortDryRun.stdout ?? "").contains("oldest-first") == false)

    let groupDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "group-by-date", "--enabled", "false", "--dry-run", "--json",
    ])))
    let groupDryRunObject = try jsonObject(groupDryRun.stdout ?? "")
    let groupDryRunData = try #require(groupDryRunObject["data"] as? [String: Any])
    let groupDryRunArgs = try #require(groupDryRunData["normalizedArguments"] as? [String: Any])
    #expect(groupDryRunObject["ok"] as? Bool == true)
    #expect(groupDryRunData["operation"] as? String == "notes.settings.group-by-date")
    #expect(groupDryRunArgs["setting_id"] as? String == "group_notes_by_date")
    #expect(groupDryRunArgs["enabled"] as? String == "false")
    #expect(groupDryRunArgs["scope"] as? String == "current")
    #expect(implementation.settingsWriteOperations.isEmpty)

    let defaultDateHeadersDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "group-by-date", "--scope", "default", "--enabled", "false", "--dry-run", "--json",
    ])))
    let defaultDateHeadersDryRunObject = try jsonObject(defaultDateHeadersDryRun.stdout ?? "")
    let defaultDateHeadersDryRunData = try #require(defaultDateHeadersDryRunObject["data"] as? [String: Any])
    let defaultDateHeadersDryRunArgs = try #require(defaultDateHeadersDryRunData["normalizedArguments"] as? [String: Any])
    #expect(defaultDateHeadersDryRunObject["ok"] as? Bool == true)
    #expect(defaultDateHeadersDryRunData["operation"] as? String == "notes.settings.group-by-date")
    #expect(defaultDateHeadersDryRunArgs["setting_id"] as? String == "default_date_headers_type")
    #expect(defaultDateHeadersDryRunArgs["scope"] as? String == "default")
    #expect(defaultDateHeadersDryRunArgs["date_headers_type_value"] as? String == "1")
    #expect((defaultDateHeadersDryRunArgs["date_headers_type_sha256"] as? String)?.count == 64)
    #expect((defaultDateHeadersDryRun.stdout ?? "").contains("ICDateHeadersUtilities") == false)
    #expect(implementation.settingsWriteOperations.isEmpty)

    let quickNoteDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "quick-note-resume", "--enabled", "false", "--dry-run", "--json",
    ])))
    let quickNoteDryRunObject = try jsonObject(quickNoteDryRun.stdout ?? "")
    let quickNoteDryRunData = try #require(quickNoteDryRunObject["data"] as? [String: Any])
    let quickNoteDryRunArgs = try #require(quickNoteDryRunData["normalizedArguments"] as? [String: Any])
    #expect(quickNoteDryRunObject["ok"] as? Bool == true)
    #expect(quickNoteDryRunData["operation"] as? String == "notes.settings.quick-note-resume")
    #expect(quickNoteDryRunArgs["setting_id"] as? String == "always_resume_to_last_quick_note")
    #expect(quickNoteDryRunArgs["enabled"] as? String == "false")
    #expect(implementation.settingsWriteOperations.isEmpty)

    let mentionDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "mention-notifications", "--enabled", "false", "--dry-run", "--json",
    ])))
    let mentionDryRunObject = try jsonObject(mentionDryRun.stdout ?? "")
    let mentionDryRunData = try #require(mentionDryRunObject["data"] as? [String: Any])
    let mentionDryRunArgs = try #require(mentionDryRunData["normalizedArguments"] as? [String: Any])
    let mentionDryRunRequirements = try #require(mentionDryRunData["requirements"] as? [String: Any])
    #expect(mentionDryRunObject["ok"] as? Bool == true)
    #expect(mentionDryRunData["operation"] as? String == "notes.settings.mention-notifications")
    #expect(mentionDryRunArgs["setting_id"] as? String == "allow_mention_notifications")
    #expect(mentionDryRunArgs["enabled"] as? String == "false")
    #expect(mentionDryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(implementation.settingsWriteOperations.isEmpty)

    let touchIDDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "touch-id", "--account", "iCloud", "--enabled", "false", "--dry-run", "--json",
    ])))
    let touchIDDryRunObject = try jsonObject(touchIDDryRun.stdout ?? "")
    let touchIDDryRunData = try #require(touchIDDryRunObject["data"] as? [String: Any])
    let touchIDDryRunArgs = try #require(touchIDDryRunData["normalizedArguments"] as? [String: Any])
    let touchIDDryRunRequirements = try #require(touchIDDryRunData["requirements"] as? [String: Any])
    #expect(touchIDDryRunObject["ok"] as? Bool == true)
    #expect(touchIDDryRunData["operation"] as? String == "notes.settings.touch-id")
    #expect(touchIDDryRunArgs["setting_id"] as? String == "use_touch_id")
    #expect((touchIDDryRunArgs["account_sha256"] as? String)?.count == 64)
    #expect(touchIDDryRunArgs["account"] as? String == nil)
    #expect(touchIDDryRunArgs["enabled"] as? String == "false")
    #expect(touchIDDryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect((touchIDDryRun.stdout ?? "").contains("iCloud") == false)
    #expect(implementation.settingsWriteOperations.isEmpty)

    let textSizeDryRun = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "text-size", "--size", "18", "--dry-run", "--json",
    ])))
    let textSizeDryRunObject = try jsonObject(textSizeDryRun.stdout ?? "")
    let textSizeDryRunData = try #require(textSizeDryRunObject["data"] as? [String: Any])
    let textSizeDryRunArgs = try #require(textSizeDryRunData["normalizedArguments"] as? [String: Any])
    let textSizeDryRunRequirements = try #require(textSizeDryRunData["requirements"] as? [String: Any])
    #expect(textSizeDryRunObject["ok"] as? Bool == true)
    #expect(textSizeDryRunData["operation"] as? String == "notes.settings.text-size")
    #expect(textSizeDryRunArgs["setting_id"] as? String == "default_text_size")
    #expect((textSizeDryRunArgs["size_sha256"] as? String)?.count == 64)
    #expect(textSizeDryRunArgs["size"] as? String == nil)
    #expect(textSizeDryRunRequirements["allowFlags"] as? [String] == ["--allow-persistent-action"])
    #expect(implementation.settingsWriteOperations.isEmpty)

    let onMyMacImplementation = StateAuditImplementation(onMyMacAccountPresent: false)
    let onMyMacCommand = NotesCommand(implementation: onMyMacImplementation)
    let onMyMacDryRun = try #require(try onMyMacCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "on-my-mac", "--enabled", "true", "--dry-run", "--json",
    ])))
    let onMyMacDryRunObject = try jsonObject(onMyMacDryRun.stdout ?? "")
    let onMyMacDryRunData = try #require(onMyMacDryRunObject["data"] as? [String: Any])
    let onMyMacDryRunArgs = try #require(onMyMacDryRunData["normalizedArguments"] as? [String: Any])
    #expect(onMyMacDryRunObject["ok"] as? Bool == true)
    #expect(onMyMacDryRunData["operation"] as? String == "notes.settings.on-my-mac")
    #expect(onMyMacDryRunArgs["setting_id"] as? String == "enable_on_my_mac_account")
    #expect(onMyMacDryRunArgs["enabled"] as? String == "true")
    #expect(onMyMacImplementation.settingsWriteOperations.isEmpty)

    let onMyMacDisableImplementation = StateAuditImplementation(onMyMacAccountPresent: true)
    let onMyMacDisableCommand = NotesCommand(implementation: onMyMacDisableImplementation)
    let onMyMacDisableDryRun = try #require(try onMyMacDisableCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "on-my-mac", "--enabled", "false", "--dry-run", "--json",
    ])))
    let onMyMacDisableDryRunObject = try jsonObject(onMyMacDisableDryRun.stdout ?? "")
    let onMyMacDisableDryRunData = try #require(onMyMacDisableDryRunObject["data"] as? [String: Any])
    let onMyMacDisableDryRunArgs = try #require(onMyMacDisableDryRunData["normalizedArguments"] as? [String: Any])
    #expect(onMyMacDisableDryRunObject["ok"] as? Bool == true)
    #expect(onMyMacDisableDryRunData["operation"] as? String == "notes.settings.on-my-mac")
    #expect(onMyMacDisableDryRunArgs["setting_id"] as? String == "enable_on_my_mac_account")
    #expect(onMyMacDisableDryRunArgs["enabled"] as? String == "false")
    #expect(onMyMacDisableImplementation.settingsWriteOperations.isEmpty)

    do {
      _ = try command.run(options: try CLIOptionsFixture.parse([
        "settings", "mention-notifications", "--enabled", "false", "--json",
      ]))
      Issue.record("Expected Notes settings mutation without --allow-persistent-action to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-persistent-action")
    #expect(error.details["risk"] == "persistentAction")
    }
    #expect(implementation.settingsWriteOperations.isEmpty)

    let sortResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "sort", "--by", "date-created", "--direction", "oldest-first",
      "--allow-persistent-action", "--json",
    ])))
    let sortObject = try jsonObject(sortResult.stdout ?? "")
    let sortData = try #require(sortObject["data"] as? [String: Any])
    let sortVerification = try #require(sortData["verification"] as? [String: Any])

    #expect(sortObject["ok"] as? Bool == true)
    #expect(sortData["operation"] as? String == "notes.settings.sort")
    #expect(sortData["changed"] as? Bool == true)
    #expect(sortData["settingID"] as? String == "sort_notes_by")
    #expect(sortData["valueKind"] as? String == "note_list_sort_sha256")
    #expect((sortData["valueSHA256"] as? String)?.count == 64)
    #expect(sortVerification["verified"] as? Bool == true)
    #expect((sortResult.stdout ?? "").contains("date-created") == false)

    let defaultAccountResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "default-account", "--account", "On My Mac", "--allow-persistent-action", "--json",
    ])))
    let defaultAccountObject = try jsonObject(defaultAccountResult.stdout ?? "")
    let defaultAccountData = try #require(defaultAccountObject["data"] as? [String: Any])
    let defaultAccountVerification = try #require(defaultAccountData["verification"] as? [String: Any])

    #expect(defaultAccountObject["ok"] as? Bool == true)
    #expect(defaultAccountData["operation"] as? String == "notes.settings.default-account")
    #expect(defaultAccountData["changed"] as? Bool == true)
    #expect(defaultAccountData["settingID"] as? String == "default_account")
    #expect(defaultAccountData["valueKind"] as? String == "account_id_sha256")
    #expect((defaultAccountData["valueSHA256"] as? String)?.count == 64)
    #expect(defaultAccountVerification["verified"] as? Bool == true)
    #expect((defaultAccountResult.stdout ?? "").contains("On My Mac") == false)
    #expect((defaultAccountResult.stdout ?? "").contains("account-local") == false)

    let groupResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "group-by-date", "--enabled", "false", "--allow-persistent-action", "--json",
    ])))
    let groupObject = try jsonObject(groupResult.stdout ?? "")
    let groupData = try #require(groupObject["data"] as? [String: Any])
    let groupVerification = try #require(groupData["verification"] as? [String: Any])

    #expect(groupObject["ok"] as? Bool == true)
    #expect(groupData["operation"] as? String == "notes.settings.group-by-date")
    #expect(groupData["changed"] as? Bool == true)
    #expect(groupData["settingID"] as? String == "group_notes_by_date")
    #expect(groupData["valueKind"] as? String == "bool")
    #expect(groupData["boolValue"] as? Bool == false)
    #expect(groupData["beforeBoolValue"] as? Bool == true)
    #expect(groupData["afterBoolValue"] as? Bool == false)
    #expect(groupVerification["verified"] as? Bool == true)

    let queryDateHeadersResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "group-by-date", "--scope", "query", "--enabled", "false",
      "--allow-persistent-action", "--json",
    ])))
    let queryDateHeadersObject = try jsonObject(queryDateHeadersResult.stdout ?? "")
    let queryDateHeadersData = try #require(queryDateHeadersObject["data"] as? [String: Any])
    let queryDateHeadersVerification = try #require(queryDateHeadersData["verification"] as? [String: Any])

    #expect(queryDateHeadersObject["ok"] as? Bool == true)
    #expect(queryDateHeadersData["operation"] as? String == "notes.settings.group-by-date")
    #expect(queryDateHeadersData["changed"] as? Bool == true)
    #expect(queryDateHeadersData["settingID"] as? String == "query_date_headers_type")
    #expect(queryDateHeadersData["valueKind"] as? String == "date_headers_type_sha256")
    #expect((queryDateHeadersData["valueSHA256"] as? String)?.count == 64)
    #expect((queryDateHeadersData["beforeValueSHA256"] as? String)?.count == 64)
    #expect((queryDateHeadersData["afterValueSHA256"] as? String)?.count == 64)
    #expect(queryDateHeadersVerification["verified"] as? Bool == true)
    #expect((queryDateHeadersResult.stdout ?? "").contains("ICDateHeadersUtilities") == false)

    let quickNoteResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "quick-note-resume", "--enabled", "false", "--allow-persistent-action", "--json",
    ])))
    let quickNoteObject = try jsonObject(quickNoteResult.stdout ?? "")
    let quickNoteData = try #require(quickNoteObject["data"] as? [String: Any])
    let quickNoteVerification = try #require(quickNoteData["verification"] as? [String: Any])

    #expect(quickNoteObject["ok"] as? Bool == true)
    #expect(quickNoteData["operation"] as? String == "notes.settings.quick-note-resume")
    #expect(quickNoteData["changed"] as? Bool == true)
    #expect(quickNoteData["settingID"] as? String == "always_resume_to_last_quick_note")
    #expect(quickNoteData["valueKind"] as? String == "bool")
    #expect(quickNoteData["boolValue"] as? Bool == false)
    #expect(quickNoteData["beforeBoolValue"] as? Bool == true)
    #expect(quickNoteData["afterBoolValue"] as? Bool == false)
    #expect(quickNoteVerification["verified"] as? Bool == true)

    let mentionResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "mention-notifications", "--enabled", "false", "--allow-persistent-action", "--json",
    ])))
    let mentionObject = try jsonObject(mentionResult.stdout ?? "")
    let mentionData = try #require(mentionObject["data"] as? [String: Any])
    let mentionVerification = try #require(mentionData["verification"] as? [String: Any])

    #expect(mentionObject["ok"] as? Bool == true)
    #expect(mentionData["operation"] as? String == "notes.settings.mention-notifications")
    #expect(mentionData["changed"] as? Bool == true)
    #expect(mentionData["settingID"] as? String == "allow_mention_notifications")
    #expect(mentionData["valueKind"] as? String == "bool")
    #expect(mentionData["boolValue"] as? Bool == false)
    #expect(mentionData["beforeBoolValue"] as? Bool == true)
    #expect(mentionData["afterBoolValue"] as? Bool == false)
    #expect(mentionVerification["verified"] as? Bool == true)

    let touchIDResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "touch-id", "--account", "iCloud", "--enabled", "false",
      "--allow-persistent-action", "--json",
    ])))
    let touchIDObject = try jsonObject(touchIDResult.stdout ?? "")
    let touchIDData = try #require(touchIDObject["data"] as? [String: Any])
    let touchIDVerification = try #require(touchIDData["verification"] as? [String: Any])
    let touchIDChecks = try #require(touchIDVerification["checks"] as? [[String: Any]])

    #expect(touchIDObject["ok"] as? Bool == true)
    #expect(touchIDData["operation"] as? String == "notes.settings.touch-id")
    #expect(touchIDData["changed"] as? Bool == true)
    #expect(touchIDData["settingID"] as? String == "use_touch_id")
    #expect(touchIDData["valueKind"] as? String == "account_scoped_bool")
    #expect((touchIDData["accountSHA256"] as? String)?.count == 64)
    #expect((touchIDData["preferenceKeySHA256"] as? String)?.count == 64)
    #expect(touchIDData["boolValue"] as? Bool == false)
    #expect(touchIDData["beforeBoolValue"] as? Bool == true)
    #expect(touchIDData["afterBoolValue"] as? Bool == false)
    #expect(touchIDVerification["verified"] as? Bool == true)
    #expect(touchIDVerification["evidenceLevel"] as? String == "private_touch_id_preference_readback+local_auth_boundary")
    #expect(touchIDChecks.contains { $0["name"] as? String == "account_hash_accounting" })
    #expect(touchIDChecks.contains { $0["name"] as? String == "touch_id_preference_key_hash" })
    #expect(touchIDChecks.contains { $0["name"] as? String == "local_auth_boundary_accounting" })
    #expect((touchIDResult.stdout ?? "").contains("iCloud") == false)

    let textSizeResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "text-size", "--size", "18", "--allow-persistent-action", "--json",
    ])))
    let textSizeObject = try jsonObject(textSizeResult.stdout ?? "")
    let textSizeData = try #require(textSizeObject["data"] as? [String: Any])
    let textSizeVerification = try #require(textSizeData["verification"] as? [String: Any])

    #expect(textSizeObject["ok"] as? Bool == true)
    #expect(textSizeData["operation"] as? String == "notes.settings.text-size")
    #expect(textSizeData["changed"] as? Bool == true)
    #expect(textSizeData["settingID"] as? String == "default_text_size")
    #expect(textSizeData["valueKind"] as? String == "text_size_sha256")
    #expect((textSizeData["valueSHA256"] as? String)?.count == 64)
    #expect((textSizeData["beforeValueSHA256"] as? String)?.count == 64)
    #expect((textSizeData["afterValueSHA256"] as? String)?.count == 64)
    #expect(textSizeVerification["verified"] as? Bool == true)
    #expect((textSizeResult.stdout ?? "").contains("\"size\"") == false)

    let onMyMacResult = try #require(try onMyMacCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "on-my-mac", "--enabled", "true", "--allow-persistent-action", "--json",
    ])))
    let onMyMacObject = try jsonObject(onMyMacResult.stdout ?? "")
    let onMyMacData = try #require(onMyMacObject["data"] as? [String: Any])
    let onMyMacVerification = try #require(onMyMacData["verification"] as? [String: Any])

    #expect(onMyMacObject["ok"] as? Bool == true)
    #expect(onMyMacData["operation"] as? String == "notes.settings.on-my-mac")
    #expect(onMyMacData["changed"] as? Bool == true)
    #expect(onMyMacData["settingID"] as? String == "enable_on_my_mac_account")
    #expect(onMyMacData["valueKind"] as? String == "bool")
    #expect(onMyMacData["boolValue"] as? Bool == true)
    #expect(onMyMacData["beforeBoolValue"] as? Bool == false)
    #expect(onMyMacData["afterBoolValue"] as? Bool == true)
    #expect(onMyMacVerification["verified"] as? Bool == true)
    #expect(onMyMacImplementation.settingsWriteOperations == ["enable_on_my_mac_account"])
    #expect((onMyMacResult.stdout ?? "").contains("On My Mac") == false)

    let onMyMacDisableResult = try #require(try onMyMacDisableCommand.run(options: try CLIOptionsFixture.parse([
      "settings", "on-my-mac", "--enabled", "false", "--allow-persistent-action", "--json",
    ])))
    let onMyMacDisableObject = try jsonObject(onMyMacDisableResult.stdout ?? "")
    let onMyMacDisableData = try #require(onMyMacDisableObject["data"] as? [String: Any])
    let onMyMacDisableVerification = try #require(onMyMacDisableData["verification"] as? [String: Any])
    let onMyMacDisableChecks = try #require(onMyMacDisableVerification["checks"] as? [[String: Any]])

    #expect(onMyMacDisableObject["ok"] as? Bool == true)
    #expect(onMyMacDisableData["operation"] as? String == "notes.settings.on-my-mac")
    #expect(onMyMacDisableData["changed"] as? Bool == true)
    #expect(onMyMacDisableData["settingID"] as? String == "enable_on_my_mac_account")
    #expect(onMyMacDisableData["valueKind"] as? String == "bool")
    #expect(onMyMacDisableData["boolValue"] as? Bool == false)
    #expect(onMyMacDisableData["beforeBoolValue"] as? Bool == true)
    #expect(onMyMacDisableData["afterBoolValue"] as? Bool == false)
    #expect(onMyMacDisableVerification["verified"] as? Bool == true)
    #expect(onMyMacDisableVerification["evidenceLevel"] as? String == "private_framework_local_account_lifecycle+settings_readback")
    #expect(onMyMacDisableChecks.contains { $0["name"] as? String == "empty_local_account_notes_preflight" })
    #expect(onMyMacDisableChecks.contains { $0["name"] as? String == "empty_local_account_folders_preflight" })
    #expect(onMyMacDisableChecks.contains { $0["name"] as? String == "non_local_account_available" })
    #expect(onMyMacDisableImplementation.settingsWriteOperations == ["enable_on_my_mac_account"])
    #expect((onMyMacDisableResult.stdout ?? "").contains("On My Mac") == false)

    let nonEmptyOnMyMacImplementation = StateAuditImplementation(onMyMacAccountPresent: true, localAccountNoteCount: 1)
    let nonEmptyOnMyMacCommand = NotesCommand(implementation: nonEmptyOnMyMacImplementation)
    do {
      _ = try nonEmptyOnMyMacCommand.run(options: try CLIOptionsFixture.parse([
        "settings", "on-my-mac", "--enabled", "false", "--allow-persistent-action", "--json",
      ]))
      Issue.record("Expected non-empty On My Mac disable to be refused.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.details["operation"] == "notes.settings.on-my-mac")
      #expect(error.details["capability"] == "enable_on_my_mac_account")
      #expect(error.details["status"] == "refused")
      #expect(error.details["local_note_count"] == "1")
    }
    #expect(nonEmptyOnMyMacImplementation.settingsWriteOperations.isEmpty)

    let styleResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "new-note-style", "--style", "heading", "--allow-persistent-action", "--json",
    ])))
    let styleObject = try jsonObject(styleResult.stdout ?? "")
    let styleData = try #require(styleObject["data"] as? [String: Any])
    let styleVerification = try #require(styleData["verification"] as? [String: Any])
    let styleChecks = try #require(styleVerification["checks"] as? [[String: Any]])

    #expect(styleObject["ok"] as? Bool == true)
    #expect(styleData["operation"] as? String == "notes.settings.new-note-style")
    #expect(styleData["changed"] as? Bool == true)
    #expect(styleData["settingID"] as? String == "new_notes_start_with")
    #expect(styleData["valueKind"] as? String == "paragraph_style_sha256")
    #expect((styleData["valueSHA256"] as? String)?.count == 64)
    #expect((styleData["beforeValueSHA256"] as? String)?.count == 64)
    #expect((styleData["afterValueSHA256"] as? String)?.count == 64)
    #expect(styleVerification["verified"] as? Bool == true)
    #expect(styleChecks.contains { $0["name"] as? String == "requested_value_readback" })
    #expect((styleResult.stdout ?? "").contains("heading") == false)

    let checklistResult = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "settings", "checklist-sort", "--enabled", "false", "--allow-persistent-action", "--json",
    ])))
    let checklistObject = try jsonObject(checklistResult.stdout ?? "")
    let checklistData = try #require(checklistObject["data"] as? [String: Any])
    let checklistVerification = try #require(checklistData["verification"] as? [String: Any])

    #expect(checklistObject["ok"] as? Bool == true)
    #expect(checklistData["operation"] as? String == "notes.settings.checklist-sort")
    #expect(checklistData["changed"] as? Bool == true)
    #expect(checklistData["settingID"] as? String == "automatically_sort_checked_items")
    #expect(checklistData["valueKind"] as? String == "bool")
    #expect(checklistData["boolValue"] as? Bool == false)
    #expect(checklistData["beforeBoolValue"] as? Bool == true)
    #expect(checklistData["afterBoolValue"] as? Bool == false)
    #expect(checklistVerification["verified"] as? Bool == true)
    #expect(implementation.settingsWriteOperations == [
      "sort_notes_by",
      "default_account",
      "group_notes_by_date",
      "query_date_headers_type",
      "always_resume_to_last_quick_note",
      "allow_mention_notifications",
      "use_touch_id",
      "default_text_size",
      "new_notes_start_with",
      "automatically_sort_checked_items",
    ])
    #expect(implementation.noteStateReadIDs.isEmpty)
    #expect(implementation.readNoteLookups.isEmpty)
  }

  @Test func settingsBoundaryCommandsReturnStructuredRefusalsWithoutImplementationAccess() throws {
    let cases: [
      (
        args: [String],
        operation: String,
        capability: String,
        status: String,
        futureGate: String,
        requiredImplementation: String,
        requiredVerifier: String
      )
    ] = [
      (
        ["settings", "view-layout", "--style", "gallery"],
        "notes.settings.view-layout",
        "view_layout",
        "delegated",
        "notes_window_view_surface_delegation",
        "notes_window_view_surface",
        "delegated_window_view_accounting"
      ),
      (
        ["settings", "link-highlight-color", "--color", "purple"],
        "notes.settings.link-highlight-color",
        "link_and_highlight_color",
        "delegated",
        "macos_appearance_settings_delegation",
        "macos_appearance_settings_route",
        "delegated_appearance_settings_accounting"
      ),
      (
        ["settings", "notifications", "--account", "private@example.com"],
        "notes.settings.notifications",
        "notes_notification_settings",
        "delegated",
        "system_notification_settings_delegation",
        "macos_notification_settings_route",
        "delegated_system_settings_accounting"
      ),
      (
        ["settings", "widgets", "--account", "private@example.com"],
        "notes.settings.widgets",
        "notes_widgets",
        "delegated",
        "macos_widget_surface_delegation",
        "macos_widget_system",
        "delegated_widget_surface_accounting"
      ),
      (
        ["settings", "password", "--account", "private@example.com"],
        "notes.settings.password",
        "locked_notes_password_change",
        "gated",
        "locked_notes_password_settings_mutation",
        "typed_private_notes_framework",
        "private_framework_state_readback+privacy_boundary"
      ),
    ]

    for item in cases {
      let implementation = StateAuditImplementation()
      let command = NotesCommand(implementation: implementation)
      let options = try CLIOptionsFixture.parse(item.args + ["--json"])

      do {
        _ = try command.run(options: options)
        Issue.record("Expected \(item.operation) to be gated or delegated.")
      } catch let error as CLIError {
        #expect(error.code == .unsupportedOperation)
        #expect(error.details["operation"] == item.operation)
        #expect(error.details["capability"] == item.capability)
        #expect(error.details["status"] == item.status)
        #expect(error.details["future_gate"] == item.futureGate)
        #expect(error.details["required_implementation"] == item.requiredImplementation)
        #expect(error.details["required_verifier"] == item.requiredVerifier)
        #expect(error.details["backend_calls"] == "none")
        #expect(error.details.values.contains("private@example.com") == false)
        #expect(error.details.values.contains("heading") == false)
        #expect(error.details.values.contains("purple") == false)
        #expect(error.details.values.contains("gallery") == false)
      }

      #expect(implementation.noteStateReadIDs.isEmpty)
      #expect(implementation.readNoteLookups.isEmpty)
    }
  }

  @Test func accountLifecycleBoundaryCommandsReturnDelegatedRefusalsWithoutImplementationAccess() throws {
    let cases: [
      (
        args: [String],
        operation: String,
        capability: String,
        appleCapability: String
      )
    ] = [
      (
        ["accounts", "add", "--provider", "google", "--account", "private@example.com"],
        "notes.accounts.add",
        "external_notes_account_add",
        "add_notes_account"
      ),
      (
        ["accounts", "remove", "--account", "private@example.com"],
        "notes.accounts.remove",
        "external_notes_account_remove",
        "remove_notes_account"
      ),
      (
        ["accounts", "enable", "--account", "private@example.com"],
        "notes.accounts.enable",
        "external_notes_account_service_enable",
        "enable_notes_for_account"
      ),
      (
        ["accounts", "disable", "--account", "private@example.com"],
        "notes.accounts.disable",
        "external_notes_account_service_disable",
        "disable_notes_for_account"
      ),
    ]

    for item in cases {
      let implementation = StateAuditImplementation()
      let command = NotesCommand(implementation: implementation)
      let options = try CLIOptionsFixture.parse(item.args + ["--json"])

      do {
        _ = try command.run(options: options)
        Issue.record("Expected \(item.operation) to be delegated.")
      } catch let error as CLIError {
        #expect(error.code == .unsupportedOperation)
        #expect(error.details["operation"] == item.operation)
        #expect(error.details["capability"] == item.capability)
        #expect(error.details["apple_notes_capability"] == item.appleCapability)
        #expect(error.details["status"] == "delegated")
        #expect(error.details["future_gate"] == "internet_accounts_account_management_delegation")
        #expect(error.details["required_implementation"] == "macos_internet_accounts_route")
        #expect(error.details["required_verifier"] == "delegated_internet_accounts_accounting")
        #expect(error.details["backend_calls"] == "none")
        #expect(error.details.values.contains("private@example.com") == false)
        #expect(error.details.values.contains("google") == false)
      }

      #expect(implementation.accountListQueries.isEmpty)
      #expect(implementation.settingsWriteOperations.isEmpty)
      #expect(implementation.noteStateReadIDs.isEmpty)
      #expect(implementation.readNoteLookups.isEmpty)
    }
  }
}

private enum StateAuditImplementationError: Error {
  case unsupported
}

private final class StateAuditClipboardWriter: NotesClipboardWriting, @unchecked Sendable {
  var writtenTexts: [String] = []
  private var changeCount = 0

  func writeString(_ value: String) throws -> NotesClipboardWriteRecord {
    writtenTexts.append(value)
    changeCount += 1
    return NotesClipboardWriteRecord(changeCount: changeCount)
  }

  func readString() throws -> String? {
    writtenTexts.last
  }
}

private final class StateAuditImplementation: NotesReading, NotesAccountScopedListing, NotesNoteStateReading, NotesNoteStateMutating,
  NotesLockedContentExporting,
  NotesCollaborationLinkReading, NotesCollaborationParticipantsReading, NotesCollaborationPermissionMutating,
  NotesCollaborationSharingMutating, NotesCollaborationAccessScopeMutating, NotesCollaborationStopSharingMutating, NotesCollaborationInvitePolicyMutating,
  NotesCollaborationSelfRemovalMutating, NotesCollaborationParticipantMutating, NotesCollaborationMentionMutating,
  NotesNoteActivityReading,
  NotesSettingsReading, NotesSettingsMutating, NotesAttachmentReading, NotesMutating,
  @unchecked Sendable
{
  static let sharedNoteLink = "https://www.icloud.com/notes/shared-note-link"
  static let sharedFolderLink = "https://www.icloud.com/notes/shared-folder-link"
  static let activityEventBytes = Data(
    #"{"events":[{"actor":"Ada Lovelace","summary":"Edited the launch checklist"},{"actor":"Grace Hopper","summary":"Added a collaboration note"}]}"#
      .utf8)

  var readNoteLookups: [String] = []
  var accountListQueries: [String] = []
  var noteStateReadIDs: [String] = []
  var noteActivityReadIDs: [String] = []
  var collaborationLinkReads: [NotesCollaborationLinkDraft] = []
  var collaborationParticipantReads: [NotesCollaborationParticipantsDraft] = []
  var collaborationPermissionDrafts: [NotesCollaborationPermissionMutationDraft] = []
  var collaborationShareDrafts: [NotesCollaborationShareMutationDraft] = []
  var collaborationAccessScopeDrafts: [NotesCollaborationAccessScopeMutationDraft] = []
  var collaborationStopSharingDrafts: [NotesCollaborationStopSharingDraft] = []
  var collaborationInvitePolicyDrafts: [NotesCollaborationAllowInvitesDraft] = []
  var collaborationSelfRemovalDrafts: [NotesCollaborationSelfRemovalDraft] = []
  var collaborationParticipantRemovalDrafts: [NotesCollaborationParticipantRemovalDraft] = []
  var collaborationMentionDrafts: [NotesCollaborationMentionDraft] = []
  var attachmentReadIDs: [String] = []
  var settingsWriteOperations: [String] = []
  var stateHideAlertsWrites: [String] = []
  var lockedSessionCloseDrafts: [NotesLockedSessionCloseDraft] = []
  var noteLockMutationDrafts: [NotesNoteLockMutationDraft] = []
  var noteUnlockDrafts: [NotesNoteUnlockDraft] = []
  var customPassphraseDrafts: [NotesSettingsPassphraseMutationDraft] = []
  var customPassphraseChangeDrafts: [NotesSettingsPassphraseChangeMutationDraft] = []
  var lockedNotesMethodDrafts: [NotesSettingsLockedNotesMethodMutationDraft] = []
  var lockedContentExportDrafts: [NotesLockedContentExportDraft] = []
  private let accounts = [
    NotesAccountRecord(id: "account-icloud", name: "iCloud"),
    NotesAccountRecord(id: "account-local", name: "On My Mac"),
  ]
  private var defaultAccountIDSHA256 = sha256Hex("account-icloud")
  private var noteListSortSHA256 = StateAuditImplementation.settingsSortSHA256(by: "date-edited", direction: "newest-first")
  private var defaultParagraphStyleSHA256 = StateAuditImplementation.settingsParagraphStyleSHA256(.title)
  private var groupNotesByDateEnabled = true
  private var defaultDateHeadersTypeSHA256 = notesDateHeadersTypeSHA256(scope: "default", privateValue: 2)
  private var queryDateHeadersTypeSHA256 = notesDateHeadersTypeSHA256(scope: "query", privateValue: 2)
  private var supportsQueryDateHeaders = true
  private var showsQueryDateHeaders = true
  private var quickNoteResumeLastEnabled = true
  private var mentionNotificationsEnabled = true
  private var defaultTextSizeSHA256 = StateAuditImplementation.settingsTextSizeSHA256(14)
  private var touchIDPreferenceEnabled = true
  private var lockedNotesPassphraseSet = false
  private var lockedNotesHintSHA256: String?
  private var lockedNotesModeRawValue = 1
  private var onMyMacAccountPresent: Bool
  private var localAccountNoteCount: Int
  private var localAccountCustomFolderCount: Int
  private var nonLocalAccountCount: Int
  private var defaultAccountIsLocal: Bool
  private var checklistAutoSortEnabled = true
  private var lockedSessionAuthenticated = true
  private var lockedSessionHasAuthenticatedObject = true
  private var mentionCountsByNote: [String: Int] = [:]
  private var mentionCountsByNoteAndParticipant: [String: Int] = [:]
  private var participantPermissionsByTargetAndUser: [String: Int] = [:]
  private var administratorParticipantsByTarget: [String: Set<String>] = [:]
  private var publicPermissionsByTarget: [String: Int] = [:]
  private var removedParticipantsByTarget: [String: Set<String>] = [:]
  private var invitedParticipantsByTarget: [String: Set<String>] = [:]
  private var removedSelfTargets = Set<String>()
  private var stoppedSharingTargets = Set<String>()

  init(
    onMyMacAccountPresent: Bool = true,
    localAccountNoteCount: Int = 0,
    localAccountCustomFolderCount: Int = 0,
    nonLocalAccountCount: Int = 1,
    defaultAccountIsLocal: Bool = false
  ) {
    self.onMyMacAccountPresent = onMyMacAccountPresent
    self.localAccountNoteCount = localAccountNoteCount
    self.localAccountCustomFolderCount = localAccountCustomFolderCount
    self.nonLocalAccountCount = nonLocalAccountCount
    self.defaultAccountIsLocal = defaultAccountIsLocal
  }

  private let notes: [NotesNoteDetail] = [
    NotesNoteDetail(
      id: "note-archive",
      title: "Archive Plan",
      folderName: "Archive",
      accountName: "iCloud",
      body: "Private archive body"
    ),
    NotesNoteDetail(
      id: "note-shared",
      title: "Shared Plan",
      folderName: "Archive",
      accountName: "iCloud",
      body: "Private shared body",
      tags: [
        NotesTagRecord(
          id: "tag-secret",
          displayText: "SecretProject",
          standardizedContent: "secretproject",
          accountName: "iCloud",
          visibleUseCount: 1
        ),
      ]
    ),
    NotesNoteDetail(
      id: "note-locked",
      title: "Locked Plan",
      folderName: "Archive",
      accountName: "iCloud",
      body: "Private locked body"
    ),
    NotesNoteDetail(
      id: "note-unlocked-protected",
      title: "Unlocked Protected Plan",
      folderName: "Archive",
      accountName: "iCloud",
      body: "Unlocked protected body"
    ),
    NotesNoteDetail(
      id: "note-other",
      title: "Other Plan",
      folderName: "Other",
      accountName: "iCloud",
      body: "Private other body"
    ),
    NotesNoteDetail(
      id: "note-local",
      title: "Local Plan",
      folderName: "Local",
      accountName: "Local",
      body: "Local private body"
    ),
    NotesNoteDetail(
      id: "note-provider-blocked",
      title: "Provider Plan",
      folderName: "External",
      accountName: "External Provider",
      body: "Provider private body"
    ),
  ]

  private let attachmentsByNote: [String: [NotesAttachmentRecord]] = [
    "note-shared": [
      NotesAttachmentRecord(
        id: "attachment-pdf",
        title: "Private Contract",
        typeUTI: "com.adobe.pdf",
        mediaFilename: "Private Contract.pdf",
        isInline: false,
        isDeletedOrInTrash: false
      ),
      NotesAttachmentRecord(
        id: "attachment-image",
        title: "Launch Photo",
        typeUTI: "public.jpeg",
        mediaFilename: "Launch Photo.jpg",
        isInline: false,
        isDeletedOrInTrash: false
      ),
    ],
  ]

  private var states: [String: NotesNoteStateRecord] = [
    "note-archive": NotesNoteStateRecord(
      noteID: "note-archive",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPinnable: true,
      isPasswordProtected: false,
      isPasswordProtectedAndLocked: false,
      isEditable: true,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      hasUnreadChanges: false,
      isUnsupported: false,
      needsCloudFetch: false,
      participantCount: 0,
      folderID: "folder-archive",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
    "note-shared": NotesNoteStateRecord(
      noteID: "note-shared",
      isDeletedOrInTrash: false,
      isPinned: true,
      isPinnable: true,
      isPasswordProtected: false,
      isPasswordProtectedAndLocked: false,
      isEditable: false,
      isLockable: false,
      isSharedViaICloud: true,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: true,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      hasUnreadChanges: true,
      isUnsupported: false,
      needsCloudFetch: false,
      sharedNoteAlertsHidden: false,
      participantCount: 2,
      participantUserIDSHA256s: [
        sha256Hex("Ada Lovelace"),
        sha256Hex("Grace Hopper"),
      ],
      accountCanPasswordProtectNotes: true,
      accountCanHaveCryptoStrategy: true,
      accountIsInICloud: true,
      accountIsLocal: false,
      accountLockedNotesModeSHA256: sha256Hex("locked_notes_mode:1"),
      accountResolvedLockedNotesModeSHA256: sha256Hex("resolved_locked_notes_mode:1"),
      accountPasswordProtectedNoteCount: 1,
      folderID: "folder-archive",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: true,
      folderIsSharedReadOnly: false
    ),
    "note-shared-editable": NotesNoteStateRecord(
      noteID: "note-shared-editable",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPinnable: true,
      isPasswordProtected: false,
      isPasswordProtectedAndLocked: false,
      isEditable: true,
      isLockable: false,
      isSharedViaICloud: true,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      hasUnreadChanges: true,
      isUnsupported: false,
      needsCloudFetch: false,
      sharedNoteAlertsHidden: false,
      participantCount: 2,
      participantUserIDSHA256s: [
        sha256Hex("Ada Lovelace"),
        sha256Hex("Grace Hopper"),
      ],
      accountCanPasswordProtectNotes: true,
      accountCanHaveCryptoStrategy: true,
      accountIsInICloud: true,
      accountIsLocal: false,
      accountLockedNotesModeSHA256: sha256Hex("locked_notes_mode:1"),
      accountResolvedLockedNotesModeSHA256: sha256Hex("resolved_locked_notes_mode:1"),
      accountPasswordProtectedNoteCount: 1,
      folderID: "folder-archive",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: true,
      folderIsSharedReadOnly: false
    ),
    "note-locked": NotesNoteStateRecord(
      noteID: "note-locked",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPinnable: true,
      isPasswordProtected: true,
      isPasswordProtectedAndLocked: true,
      isEditable: false,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: true,
      isCallNote: false,
      hasUnreadChanges: false,
      isUnsupported: false,
      needsCloudFetch: false,
      participantCount: 0,
      folderID: "folder-archive",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
    "note-unlocked-protected": NotesNoteStateRecord(
      noteID: "note-unlocked-protected",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPinnable: true,
      isPasswordProtected: true,
      isPasswordProtectedAndLocked: false,
      isEditable: true,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      hasUnreadChanges: false,
      isUnsupported: false,
      needsCloudFetch: false,
      participantCount: 0,
      folderID: "folder-archive",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
    "note-local": NotesNoteStateRecord(
      noteID: "note-local",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPinnable: true,
      isPasswordProtected: false,
      isPasswordProtectedAndLocked: false,
      isEditable: true,
      isLockable: true,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      hasUnreadChanges: false,
      isUnsupported: false,
      needsCloudFetch: false,
      participantCount: 0,
      folderID: "folder-local",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
    "note-provider-blocked": NotesNoteStateRecord(
      noteID: "note-provider-blocked",
      isDeletedOrInTrash: false,
      isPinned: false,
      isPinnable: true,
      isPasswordProtected: false,
      isPasswordProtectedAndLocked: false,
      isEditable: true,
      isLockable: false,
      isSharedViaICloud: false,
      isSharedViaICloudFolder: false,
      isSharedReadOnly: false,
      isSystemPaper: false,
      isMathNote: false,
      isCallNote: false,
      hasUnreadChanges: false,
      isUnsupported: false,
      needsCloudFetch: false,
      participantCount: 0,
      accountCanPasswordProtectNotes: false,
      accountCanHaveCryptoStrategy: false,
      accountIsInICloud: false,
      accountIsLocal: false,
      accountLockedNotesModeSHA256: sha256Hex("locked_notes_mode:0"),
      accountResolvedLockedNotesModeSHA256: sha256Hex("resolved_locked_notes_mode:0"),
      accountPasswordProtectedNoteCount: 0,
      folderID: "folder-external",
      folderIsTrash: false,
      folderIsDefault: false,
      folderIsSharedViaICloud: false,
      folderIsSharedReadOnly: false
    ),
  ]

  func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    notes
      .filter { folder == nil || $0.folderName.localizedCaseInsensitiveCompare(folder ?? "") == .orderedSame }
      .prefix(limit)
      .map {
        NotesNoteSummary(
          id: $0.id,
          title: $0.title,
          folderName: $0.folderName,
          accountName: $0.accountName
        )
      }
  }

  func listNotes(account: String?, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    accountListQueries.append("\(account ?? "")|\(folder ?? "")|\(limit)")
    return notes
      .filter {
        (account == nil || $0.accountName.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame)
          && (folder == nil || $0.folderName.localizedCaseInsensitiveCompare(folder ?? "") == .orderedSame)
      }
      .prefix(limit)
      .map {
        NotesNoteSummary(
          id: $0.id,
          title: $0.title,
          folderName: $0.folderName,
          accountName: $0.accountName
        )
      }
  }

  func readNoteState(noteID id: String) throws -> NotesNoteStateRecord {
    noteStateReadIDs.append(id)
    guard let state = states[id] else {
      throw StateAuditImplementationError.unsupported
    }
    return state
  }

  func setSharedNoteAlertsHidden(_ draft: NotesSharedNoteAlertsMutationDraft) throws
    -> NotesSharedNoteAlertsWriteResult
  {
    guard var state = states[draft.noteID] else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state.participantCount ?? 0
    let wasShared = state.isSharedViaICloud || state.isSharedViaICloudFolder || participantCount > 0
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes shared-note Hide Alerts requires a shared note.",
        details: [
          "operation": "notes.state.hide-alerts",
          "capability": "shared_note_notification_preference",
          "required_state": "shared_note",
          "note_id_sha256": sha256Hex(draft.noteID),
          "backend_calls": "private_framework_state_readback_only",
        ]
      )
    }
    let before = state.sharedNoteAlertsHidden ?? false
    state.sharedNoteAlertsHidden = draft.hidden
    states[draft.noteID] = state
    stateHideAlertsWrites.append("\(draft.noteID):\(draft.hidden)")
    return NotesSharedNoteAlertsWriteResult(
      noteID: draft.noteID,
      requestedHidden: draft.hidden,
      beforeHidden: before,
      afterHidden: draft.hidden,
      recordIDSHA256: sha256Hex("record-\(draft.noteID)"),
      wasShared: wasShared,
      participantCount: participantCount
    )
  }

  func closeLockedSession(_ draft: NotesLockedSessionCloseDraft) throws
    -> NotesLockedSessionCloseWriteResult
  {
    let accountID: String?
    if let account = draft.account {
      guard let match = accounts.first(where: { $0.name.localizedCaseInsensitiveCompare(account) == .orderedSame }) else {
        throw CLIError(
          code: .notFound,
          message: "Notes account was not found.",
          details: [
            "operation": "notes.state.close-locked",
            "account_sha256": sha256Hex(account),
          ]
        )
      }
      accountID = match.id
    } else {
      accountID = nil
    }
    lockedSessionCloseDrafts.append(draft)
    let beforeAuthenticated = lockedSessionAuthenticated
    let beforeHasAuthenticatedObject = lockedSessionHasAuthenticatedObject
    lockedSessionAuthenticated = false
    lockedSessionHasAuthenticatedObject = false
    return NotesLockedSessionCloseWriteResult(
      accountSelectorSHA256: draft.account.map(sha256Hex),
      accountSHA256: accountID.map(sha256Hex),
      scope: draft.account == nil
        ? "all_authenticated_locked_objects"
        : "all_authenticated_locked_objects_after_account_preflight",
      beforeAuthenticated: beforeAuthenticated,
      beforeHasAuthenticatedObject: beforeHasAuthenticatedObject,
      afterAuthenticated: lockedSessionAuthenticated,
      afterHasAuthenticatedObject: lockedSessionHasAuthenticatedObject,
      backendCalls: "ICAuthenticationState.deauthenticateAllObjects"
    )
  }

  func setNoteLockState(_ draft: NotesNoteLockMutationDraft) throws
    -> NotesNoteLockMutationWriteResult
  {
    noteLockMutationDrafts.append(draft)
    guard let before = states[draft.noteID] else {
      throw StateAuditImplementationError.unsupported
    }
    var after = before
    switch draft.action {
    case "lock":
      guard before.isLockable == true,
        before.isPasswordProtected == false,
        before.isPasswordProtectedAndLocked != true
      else {
        throw CLIError(
          code: .validationError,
          message: "Notes lock mutation requires a lockable unprotected note.",
          details: [
            "operation": "notes.state.lock",
            "capability": "note_lock_state_mutation",
            "note_id_sha256": sha256Hex(draft.noteID),
          ]
        )
      }
      after.isPasswordProtected = true
      after.isPasswordProtectedAndLocked = false
      after.isLockable = true
      states[draft.noteID] = after
      return NotesNoteLockMutationWriteResult(
        noteID: draft.noteID,
        action: draft.action,
        beforePasswordProtected: before.isPasswordProtected,
        beforePasswordProtectedAndLocked: before.isPasswordProtectedAndLocked,
        beforeLockable: before.isLockable,
        afterPasswordProtected: after.isPasswordProtected,
        afterPasswordProtectedAndLocked: after.isPasswordProtectedAndLocked,
        afterLockable: after.isLockable,
        backendCalls: "ICNoteLockManager.addLock"
      )
    case "remove-lock":
      guard before.isPasswordProtectedAndLocked != true else {
        throw CLIError(
          code: .permissionDenied,
          message: "Notes remove-lock requires an unlocked protected note.",
          details: [
            "operation": "notes.state.remove-lock",
            "capability": "note_lock_state_mutation",
            "note_id_sha256": sha256Hex(draft.noteID),
          ]
        )
      }
      after.isPasswordProtected = false
      after.isPasswordProtectedAndLocked = false
      states[draft.noteID] = after
      return NotesNoteLockMutationWriteResult(
        noteID: draft.noteID,
        action: draft.action,
        beforePasswordProtected: before.isPasswordProtected,
        beforePasswordProtectedAndLocked: before.isPasswordProtectedAndLocked,
        beforeLockable: before.isLockable,
        afterPasswordProtected: after.isPasswordProtected,
        afterPasswordProtectedAndLocked: after.isPasswordProtectedAndLocked,
        afterLockable: after.isLockable,
        backendCalls: before.isPasswordProtected ? "ICNoteLockManager.removeLock" : "ICNoteLockManager.noop"
      )
    default:
      throw StateAuditImplementationError.unsupported
    }
  }

  func unlockNote(_ draft: NotesNoteUnlockDraft) throws -> NotesNoteUnlockWriteResult {
    noteUnlockDrafts.append(draft)
    guard let before = states[draft.noteID] else {
      throw StateAuditImplementationError.unsupported
    }
    guard before.isPasswordProtected else {
      throw CLIError(
        code: .validationError,
        message: "Notes unlock requires a password-protected note.",
        details: [
          "operation": "notes.state.unlock",
          "capability": "unlock_locked_note",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    guard draft.passphrase == "correct horse battery staple" else {
      throw CLIError(
        code: .permissionDenied,
        message: "ICAuthenticationState rejected the supplied passphrase.",
        details: [
          "operation": "notes.state.unlock",
          "capability": "unlock_locked_note",
          "note_id_sha256": sha256Hex(draft.noteID),
          "passphrase_source_kind": draft.passphraseSourceKind,
        ]
      )
    }
    let beforeAuthenticated = lockedSessionAuthenticated
    let beforeHasAuthenticatedObject = lockedSessionHasAuthenticatedObject
    var after = before
    if before.isPasswordProtectedAndLocked == true {
      after.isPasswordProtectedAndLocked = false
      after.isEditable = true
    }
    states[draft.noteID] = after
    lockedSessionAuthenticated = true
    lockedSessionHasAuthenticatedObject = true
    return NotesNoteUnlockWriteResult(
      noteID: draft.noteID,
      passphraseSourceKind: draft.passphraseSourceKind,
      beforePasswordProtected: before.isPasswordProtected,
      beforePasswordProtectedAndLocked: before.isPasswordProtectedAndLocked,
      beforeAuthenticated: beforeAuthenticated,
      beforeHasAuthenticatedObject: beforeHasAuthenticatedObject,
      afterPasswordProtected: after.isPasswordProtected,
      afterPasswordProtectedAndLocked: after.isPasswordProtectedAndLocked,
      afterAuthenticated: lockedSessionAuthenticated,
      afterHasAuthenticatedObject: lockedSessionHasAuthenticatedObject,
      backendCalls: before.isPasswordProtectedAndLocked == true
        ? "ICAuthenticationState.authenticateObject:withPassphrase:"
        : "ICAuthenticationState.noop"
    )
  }

  func exportUnlockedLockedContent(_ draft: NotesLockedContentExportDraft) throws
    -> NotesLockedContentExportSource
  {
    lockedContentExportDrafts.append(draft)
    guard let state = states[draft.noteID],
      let note = notes.first(where: { $0.id == draft.noteID })
    else {
      throw StateAuditImplementationError.unsupported
    }
    guard state.isPasswordProtected else {
      throw CLIError(
        code: .validationError,
        message: "Locked-content export requires a password-protected note.",
        details: [
          "operation": "notes.state.export-locked-content",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    var currentState = state
    var authenticatedDuringExport = false
    if currentState.isPasswordProtectedAndLocked == true,
      let passphrase = draft.passphrase,
      let passphraseSourceKind = draft.passphraseSourceKind
    {
      _ = try unlockNote(
        NotesNoteUnlockDraft(
          noteID: draft.noteID,
          passphrase: passphrase,
          passphraseSourceKind: passphraseSourceKind
        )
      )
      currentState = states[draft.noteID] ?? currentState
      authenticatedDuringExport = true
    }
    guard currentState.isPasswordProtectedAndLocked == false else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Locked-content export requires an unlocked protected note.",
        details: [
          "operation": "notes.state.export-locked-content",
          "note_id_sha256": sha256Hex(draft.noteID),
          "future_gate": "secret_safe_authentication_session",
        ]
      )
    }
    return NotesLockedContentExportSource(
      noteID: draft.noteID,
      isPasswordProtected: currentState.isPasswordProtected,
      isPasswordProtectedAndLocked: currentState.isPasswordProtectedAndLocked,
      authenticatedDuringExport: authenticatedDuringExport,
      passphraseSourceKind: draft.passphraseSourceKind,
      content: note.body ?? "",
      backendCalls: authenticatedDuringExport
        ? "ICAuthenticationState.authenticateObject:withPassphrase:+ICNote.noteAsPlainTextWithoutTitle"
        : "ICNote.noteAsPlainTextWithoutTitle"
    )
  }

  func readCollaborationLink(_ draft: NotesCollaborationLinkDraft) throws
    -> NotesCollaborationLinkReadResult
  {
    collaborationLinkReads.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let isShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || ($0.participantCount ?? 0) > 0
    } ?? (draft.folderID == "Private Shared Folder" || draft.folderID == "folder-shared")
    guard isShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration link copy requires an already shared note or folder.",
        details: [
          "operation": "notes.state.copy-link",
          "capability": "collaboration_link_access",
          "required_state": "shared",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
          "backend_calls": "private_framework_share_readback_only",
        ]
      )
    }
    let urlString = draft.targetKind == "folder" ? Self.sharedFolderLink : Self.sharedNoteLink
    let urlData = Data(urlString.utf8)
    return NotesCollaborationLinkReadResult(
      targetKind: draft.targetKind,
      targetID: targetID,
      urlString: urlString,
      urlSHA256: sha256Hex(urlData),
      urlByteCount: urlData.count,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      ownerRecordNameSHA256: sha256Hex("owner-\(targetID)"),
      wasShared: true,
      participantCount: state?.participantCount ?? (draft.targetKind == "folder" ? 2 : nil)
    )
  }

  func readCollaborationParticipants(_ draft: NotesCollaborationParticipantsDraft) throws
    -> NotesCollaborationParticipantsReadResult
  {
    collaborationParticipantReads.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let isShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || ($0.participantCount ?? 0) > 0
    } ?? (draft.folderID == "Private Shared Folder" || draft.folderID == "folder-shared")
    guard isShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration participant metadata requires an already shared note or folder.",
        details: [
          "operation": "notes.state.participants",
          "capability": "collaboration_participant_access_metadata",
          "required_state": "shared",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
          "backend_calls": "private_framework_share_readback_only",
        ]
      )
    }
    let adaHash = sha256Hex("ada@example.com")
    let graceHash = sha256Hex("grace@example.com")
    let adaPermission = collaborationPermission(targetID: targetID, userRecordNameSHA256: adaHash, defaultValue: 3)
    let gracePermission = collaborationPermission(targetID: targetID, userRecordNameSHA256: graceHash, defaultValue: 2)
    let removedParticipants = removedParticipantsByTarget[targetID, default: []]
    let administrators = administratorParticipantsByTarget[targetID, default: []]
    let participants = [
      NotesCollaborationParticipantRecord(
        ordinal: 1,
        participantIDSHA256: sha256Hex(adaHash),
        userRecordNameSHA256s: [adaHash],
        permissionValue: adaPermission,
        permissionLabel: collaborationPermissionLabel(adaPermission),
        roleValue: administrators.contains(sha256Hex(adaHash)) ? 2 : 3,
        roleLabel: administrators.contains(sha256Hex(adaHash)) ? "administrator" : "private-user",
        acceptanceStatusValue: 2,
        acceptanceStatusLabel: "accepted",
        isCurrentUser: false
      ),
      NotesCollaborationParticipantRecord(
        ordinal: 2,
        participantIDSHA256: sha256Hex(graceHash),
        userRecordNameSHA256s: [graceHash],
        permissionValue: gracePermission,
        permissionLabel: collaborationPermissionLabel(gracePermission),
        roleValue: administrators.contains(sha256Hex(graceHash)) ? 2 : 3,
        roleLabel: administrators.contains(sha256Hex(graceHash)) ? "administrator" : "private-user",
        acceptanceStatusValue: 1,
        acceptanceStatusLabel: "pending",
        isCurrentUser: false
      ),
    ].filter { removedParticipants.contains($0.participantIDSHA256) == false }
      .enumerated()
      .map { index, participant in
        var copy = participant
        copy.ordinal = index + 1
        return copy
      }
    let participantSetHash = sha256Hex(participants.map(\.participantIDSHA256).sorted().joined(separator: "\n"))
    let publicPermission = publicPermissionsByTarget[targetID, default: 2]
    return NotesCollaborationParticipantsReadResult(
      targetKind: draft.targetKind,
      targetIDSHA256: sha256Hex(targetID),
      wasShared: true,
      isReadOnly: state?.isSharedReadOnly ?? false,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      ownerRecordNameSHA256: sha256Hex("owner-\(targetID)"),
      publicPermissionValue: publicPermission,
      publicPermissionLabel: collaborationPermissionLabel(publicPermission),
      participantCount: participants.count,
      participantIdentitySetSHA256: participantSetHash,
      participants: participants
    )
  }

  func setCollaborationParticipantPermission(_ draft: NotesCollaborationPermissionMutationDraft) throws
    -> NotesCollaborationPermissionWriteResult
  {
    collaborationPermissionDrafts.append(draft)
    let operation = draft.operation ?? "notes.state.set-permission"
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let sharedFolder = draft.folderID.map { $0 == "folder-shared" || $0 == "Private Shared Folder" } ?? false
    guard state != nil || sharedFolder else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state?.participantCount ?? (sharedFolder ? 2 : 0)
    let wasShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || participantCount > 0
    } ?? sharedFolder
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration permission mutation requires an already shared note or folder.",
        details: [
          "operation": operation,
          "capability": "collaboration_permission_mutation",
          "required_state": "shared_\(draft.targetKind)",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    guard state?.isSharedReadOnly != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes collaboration permission mutation requires a writable shared note or folder.",
        details: [
          "operation": operation,
          "capability": "collaboration_permission_mutation",
          "required_state": "shared_\(draft.targetKind)_with_manage_permission",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    let participants = [
      (raw: "ada@example.com", recordHash: sha256Hex("ada@example.com"), defaultPermission: 3),
      (raw: "grace@example.com", recordHash: sha256Hex("grace@example.com"), defaultPermission: 2),
    ]
    guard let participant = participants.first(where: { item in
      draft.target == item.raw
        || draft.target == item.recordHash
        || draft.target == sha256Hex(item.recordHash)
    }) else {
      throw CLIError(
        code: .notFound,
        message: "Notes collaboration participant target did not match an existing shared-note participant.",
        details: [
          "operation": operation,
          "capability": "collaboration_permission_mutation",
          "target_sha256": sha256Hex(draft.target),
          "participant_count": "\(participantCount)",
        ]
      )
    }
    let key = collaborationPermissionKey(targetID: targetID, userRecordNameSHA256: participant.recordHash)
    let before = participantPermissionsByTargetAndUser[key] ?? participant.defaultPermission
    participantPermissionsByTargetAndUser[key] = draft.permissionValue
    return NotesCollaborationPermissionWriteResult(
      noteID: draft.noteID,
      folderID: draft.folderID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: sha256Hex(participant.recordHash),
      targetUserRecordNameSHA256: participant.recordHash,
      requestedPermissionValue: draft.permissionValue,
      requestedPermissionLabel: draft.permissionLabel,
      beforePermissionValue: before,
      beforePermissionLabel: collaborationPermissionLabel(before),
      afterPermissionValue: draft.permissionValue,
      afterPermissionLabel: collaborationPermissionLabel(draft.permissionValue),
      changed: before != draft.permissionValue,
      wasShared: true,
      participantCount: participantCount,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      backendCalls: "CKShareParticipant.permission+ICCollaborationController.saveServerShare"
    )
  }

  func shareCollaboration(_ draft: NotesCollaborationShareMutationDraft) throws
    -> NotesCollaborationShareWriteResult
  {
    collaborationShareDrafts.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let sharedFolder = draft.folderID.map { $0 == "folder-shared" || $0 == "Private Shared Folder" } ?? false
    let unsharedFolder = draft.folderID.map { $0 == "folder-archive" || $0 == "Archive" } ?? false
    guard state != nil || sharedFolder || unsharedFolder else {
      throw StateAuditImplementationError.unsupported
    }
    let existingInvites = invitedParticipantsByTarget[targetID, default: []]
    let baseParticipantCount = state?.participantCount ?? (sharedFolder ? 2 : 0)
    let beforeParticipantCount = baseParticipantCount + existingInvites.count
    let beforeWasShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || baseParticipantCount > 0
    } ?? sharedFolder
    guard beforeWasShared || draft.createShareIfNeeded else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration invite requires an already shared note or folder.",
        details: [
          "operation": draft.operation,
          "capability": "collaboration_participant_invite",
          "required_state": "shared_\(draft.targetKind)",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    guard state?.isSharedReadOnly != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes collaboration sharing requires a writable note or folder.",
        details: [
          "operation": draft.operation,
          "capability": draft.createShareIfNeeded ? "collaboration_share_mutation" : "collaboration_participant_invite",
          "required_state": "\(draft.targetKind)_with_manage_permission",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    let targetUserRecordHash = sha256Hex(draft.target)
    let targetParticipantHash = sha256Hex(targetUserRecordHash)
    let targetPresentBefore = existingInvites.contains(targetParticipantHash)
    let beforePermission = participantPermissionsByTargetAndUser[
      collaborationPermissionKey(targetID: targetID, userRecordNameSHA256: targetUserRecordHash)
    ]
    invitedParticipantsByTarget[targetID, default: []].insert(targetParticipantHash)
    participantPermissionsByTargetAndUser[
      collaborationPermissionKey(targetID: targetID, userRecordNameSHA256: targetUserRecordHash)
    ] = draft.permissionValue
    if var noteState = state, let noteID = draft.noteID {
      noteState.isSharedViaICloud = true
      noteState.isSharedReadOnly = false
      noteState.participantCount = baseParticipantCount + invitedParticipantsByTarget[targetID, default: []].count
      noteState.participantUserIDSHA256s.append(targetUserRecordHash)
      states[noteID] = noteState
    }
    let afterParticipantCount = baseParticipantCount + invitedParticipantsByTarget[targetID, default: []].count
    return NotesCollaborationShareWriteResult(
      operation: draft.operation,
      noteID: draft.noteID,
      folderID: draft.folderID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: targetParticipantHash,
      targetUserRecordNameSHA256: targetUserRecordHash,
      requestedPermissionValue: draft.permissionValue,
      requestedPermissionLabel: draft.permissionLabel,
      beforeWasShared: beforeWasShared,
      afterWasShared: true,
      beforeParticipantCount: beforeParticipantCount,
      afterParticipantCount: afterParticipantCount,
      targetPresentBefore: targetPresentBefore,
      targetPresentAfter: true,
      beforePermissionValue: beforePermission,
      beforePermissionLabel: beforePermission.map(collaborationPermissionLabel(_:)),
      afterPermissionValue: draft.permissionValue,
      afterPermissionLabel: collaborationPermissionLabel(draft.permissionValue),
      changed: beforeWasShared == false || targetPresentBefore == false || beforePermission != draft.permissionValue,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      shareURLSHA256: sha256Hex("https://www.icloud.com/notes/share-\(targetID)"),
      backendCalls: "CKContainer.fetchShareParticipant+CKShare.addParticipant+ICCollaborationController.saveServerShare"
    )
  }

  func setCollaborationAccessScope(_ draft: NotesCollaborationAccessScopeMutationDraft) throws
    -> NotesCollaborationAccessScopeWriteResult
  {
    collaborationAccessScopeDrafts.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let sharedFolder = draft.folderID.map { $0 == "folder-shared" || $0 == "Private Shared Folder" } ?? false
    guard state != nil || sharedFolder else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state?.participantCount ?? (sharedFolder ? 2 : 0)
    let wasShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || participantCount > 0
    } ?? (sharedFolder && stoppedSharingTargets.contains(targetID) == false)
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration access scope mutation requires an already shared note or folder.",
        details: [
          "operation": "notes.state.share",
          "capability": "collaboration_access_scope_mutation",
          "required_state": "shared_\(draft.targetKind)",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    guard state?.isSharedReadOnly != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes collaboration access scope mutation requires a writable shared note or folder.",
        details: [
          "operation": "notes.state.share",
          "capability": "collaboration_access_scope_mutation",
          "required_state": "shared_\(draft.targetKind)_with_manage_permission",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    let before = publicPermissionsByTarget[targetID, default: 2]
    let requested = collaborationAccessScopePublicPermissionValue(
      accessScopeLabel: draft.accessScopeLabel,
      beforePublicPermission: before
    )
    publicPermissionsByTarget[targetID] = requested
    return NotesCollaborationAccessScopeWriteResult(
      noteID: draft.noteID,
      folderID: draft.folderID,
      requestedAccessScopeLabel: draft.accessScopeLabel,
      requestedPublicPermissionValue: requested,
      requestedPublicPermissionLabel: collaborationPermissionLabel(requested),
      beforeAccessScopeLabel: collaborationAccessScopeLabel(before),
      beforePublicPermissionValue: before,
      beforePublicPermissionLabel: collaborationPermissionLabel(before),
      afterAccessScopeLabel: collaborationAccessScopeLabel(requested),
      afterPublicPermissionValue: requested,
      afterPublicPermissionLabel: collaborationPermissionLabel(requested),
      changed: before != requested,
      wasShared: true,
      participantCount: participantCount,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      backendCalls: "CKShare.publicPermission+ICCollaborationController.saveServerShare"
    )
  }

  func stopSharing(_ draft: NotesCollaborationStopSharingDraft) throws
    -> NotesCollaborationStopSharingWriteResult
  {
    collaborationStopSharingDrafts.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let sharedFolder = draft.folderID.map { $0 == "folder-shared" || $0 == "Private Shared Folder" } ?? false
    guard state != nil || sharedFolder else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state?.participantCount ?? (sharedFolder ? 2 : 0)
    let wasShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || participantCount > 0
    } ?? (sharedFolder && stoppedSharingTargets.contains(targetID) == false)
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes stop sharing requires an already shared note or folder.",
        details: [
          "operation": "notes.state.stop-sharing",
          "capability": "collaboration_stop_sharing",
          "required_state": "shared_\(draft.targetKind)",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    guard state?.isSharedReadOnly != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes stop sharing requires a writable shared note or folder.",
        details: [
          "operation": "notes.state.stop-sharing",
          "capability": "collaboration_stop_sharing",
          "required_state": "shared_\(draft.targetKind)_with_manage_permission",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    let beforeParticipantCount = participantCount
    if var noteState = state, let noteID = draft.noteID {
      noteState.isSharedViaICloud = false
      noteState.isSharedViaICloudFolder = false
      noteState.isSharedReadOnly = false
      noteState.participantCount = 0
      noteState.participantUserIDSHA256s = []
      states[noteID] = noteState
    }
    stoppedSharingTargets.insert(targetID)
    removedParticipantsByTarget[targetID] = [
      sha256Hex(sha256Hex("ada@example.com")),
      sha256Hex(sha256Hex("grace@example.com")),
    ]
    return NotesCollaborationStopSharingWriteResult(
      noteID: draft.noteID,
      folderID: draft.folderID,
      beforeWasShared: true,
      afterWasShared: false,
      beforeParticipantCount: beforeParticipantCount,
      afterParticipantCount: 0,
      beforeShareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      afterShareRecordIDSHA256: nil,
      changed: true,
      backendCalls: "ICCollaborationController.removeShareIfNeededWithOwnedObjectID"
    )
  }

  func setCollaborationInvitePolicy(_ draft: NotesCollaborationAllowInvitesDraft) throws
    -> NotesCollaborationAllowInvitesWriteResult
  {
    collaborationInvitePolicyDrafts.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let sharedFolder = draft.folderID.map { $0 == "folder-shared" || $0 == "Private Shared Folder" } ?? false
    guard state != nil || sharedFolder else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state?.participantCount ?? (sharedFolder ? 2 : 0)
    let wasShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || participantCount > 0
    } ?? sharedFolder
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes collaboration invite policy mutation requires an already shared note or folder.",
        details: [
          "operation": "notes.state.allow-invites",
          "capability": "collaboration_invite_policy_mutation",
          "required_state": "shared_\(draft.targetKind)",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    guard state?.isSharedReadOnly != true else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes collaboration invite policy mutation requires a writable shared note or folder.",
        details: [
          "operation": "notes.state.allow-invites",
          "capability": "collaboration_invite_policy_mutation",
          "required_state": "shared_\(draft.targetKind)_with_manage_permission",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    let eligible = [
      sha256Hex(sha256Hex("ada@example.com")),
      sha256Hex(sha256Hex("grace@example.com")),
    ]
    let beforeAdministrators = administratorParticipantsByTarget[targetID, default: Set(eligible)]
    let beforeCount = beforeAdministrators.count
    if draft.enabled {
      administratorParticipantsByTarget[targetID] = Set(eligible)
    } else {
      administratorParticipantsByTarget[targetID] = []
    }
    let afterAdministrators = administratorParticipantsByTarget[targetID, default: []]
    let afterCount = afterAdministrators.count
    return NotesCollaborationAllowInvitesWriteResult(
      noteID: draft.noteID,
      folderID: draft.folderID,
      requestedAllowsInvites: draft.enabled,
      beforeAllowsInvites: beforeCount > 0,
      afterAllowsInvites: afterCount > 0,
      participantCount: participantCount,
      eligibleParticipantCount: eligible.count,
      beforeAdministratorCount: beforeCount,
      afterAdministratorCount: afterCount,
      changed: (beforeCount > 0) != draft.enabled,
      wasShared: true,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      backendCalls: "CKShareParticipant.role+ICCollaborationController.saveServerShare"
    )
  }

  func removeSelfFromCollaboration(_ draft: NotesCollaborationSelfRemovalDraft) throws
    -> NotesCollaborationSelfRemovalWriteResult
  {
    collaborationSelfRemovalDrafts.append(draft)
    let targetID = draft.targetID
    let state = draft.noteID.flatMap { states[$0] }
    let sharedFolder = draft.folderID.map { $0 == "folder-shared" || $0 == "Private Shared Folder" } ?? false
    guard state != nil || sharedFolder else {
      throw StateAuditImplementationError.unsupported
    }
    let visibleParticipantCount = state?.participantCount ?? (sharedFolder ? 2 : 0)
    let wasShared = state.map {
      $0.isSharedViaICloud || $0.isSharedViaICloudFolder || visibleParticipantCount > 0
    } ?? sharedFolder
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes self removal requires an already shared note or folder.",
        details: [
          "operation": "notes.state.remove-self",
          "capability": "collaboration_self_removal",
          "required_state": "shared_\(draft.targetKind)",
          "\(draft.targetKind)_id_sha256": sha256Hex(targetID),
        ]
      )
    }
    guard removedSelfTargets.contains(targetID) == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes self removal could not resolve the current user participant.",
        details: [
          "operation": "notes.state.remove-self",
          "capability": "collaboration_self_removal",
          "participant_count": "\(visibleParticipantCount)",
        ]
      )
    }
    let currentUserRecordHash = sha256Hex("current-user@example.com")
    let currentUserParticipantHash = sha256Hex(currentUserRecordHash)
    let beforeParticipantCount = visibleParticipantCount + 1
    removedSelfTargets.insert(targetID)
    if var noteState = state, let noteID = draft.noteID {
      noteState.participantCount = max(0, visibleParticipantCount)
      states[noteID] = noteState
    }
    return NotesCollaborationSelfRemovalWriteResult(
      noteID: draft.noteID,
      folderID: draft.folderID,
      beforeWasShared: true,
      beforeCurrentUserPresent: true,
      afterCurrentUserPresent: false,
      currentUserParticipantIDSHA256: currentUserParticipantHash,
      currentUserRecordNameSHA256: currentUserRecordHash,
      beforeParticipantCount: beforeParticipantCount,
      afterParticipantCount: visibleParticipantCount,
      changed: true,
      shareRecordIDSHA256: sha256Hex("share-\(targetID)"),
      backendCalls: "CKShare.removeParticipant(currentUserParticipant)+ICCollaborationController.saveServerShare"
    )
  }

  func removeCollaborationParticipant(_ draft: NotesCollaborationParticipantRemovalDraft) throws
    -> NotesCollaborationParticipantRemovalWriteResult
  {
    collaborationParticipantRemovalDrafts.append(draft)
    guard var state = states[draft.noteID] else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state.participantCount ?? 0
    let wasShared = state.isSharedViaICloud || state.isSharedViaICloudFolder || participantCount > 0
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant removal requires an already shared note.",
        details: [
          "operation": "notes.state.remove-participant",
          "capability": "collaboration_participant_removal",
          "required_state": "shared_note",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    guard state.isSharedReadOnly == false else {
      throw CLIError(
        code: .permissionDenied,
        message: "Notes participant removal requires a writable shared note.",
        details: [
          "operation": "notes.state.remove-participant",
          "capability": "collaboration_participant_removal",
          "required_state": "shared_note_with_manage_permission",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    let participants = [
      (raw: "ada@example.com", recordHash: sha256Hex("ada@example.com"), stateHash: sha256Hex("Ada Lovelace")),
      (raw: "grace@example.com", recordHash: sha256Hex("grace@example.com"), stateHash: sha256Hex("Grace Hopper")),
    ]
    let removed = removedParticipantsByTarget[draft.noteID, default: []]
    let available = participants.filter { removed.contains(sha256Hex($0.recordHash)) == false }
    guard let participant = available.first(where: { item in
      draft.target == item.raw
        || draft.target == item.recordHash
        || draft.target == sha256Hex(item.recordHash)
    }) else {
      throw CLIError(
        code: .notFound,
        message: "Notes collaboration participant target did not match an existing shared-note participant.",
        details: [
          "operation": "notes.state.remove-participant",
          "capability": "collaboration_participant_removal",
          "target_sha256": sha256Hex(draft.target),
          "participant_count": "\(available.count)",
        ]
      )
    }
    let participantIDHash = sha256Hex(participant.recordHash)
    let beforeCount = available.count
    removedParticipantsByTarget[draft.noteID, default: []].insert(participantIDHash)
    let afterCount = max(0, beforeCount - 1)
    state.participantCount = afterCount
    state.participantUserIDSHA256s = available
      .filter { sha256Hex($0.recordHash) != participantIDHash }
      .map(\.stateHash)
    states[draft.noteID] = state
    return NotesCollaborationParticipantRemovalWriteResult(
      noteID: draft.noteID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: participantIDHash,
      targetUserRecordNameSHA256: participant.recordHash,
      beforeParticipantCount: beforeCount,
      afterParticipantCount: afterCount,
      targetPresentAfter: false,
      changed: true,
      wasShared: true,
      shareRecordIDSHA256: sha256Hex("share-\(draft.noteID)"),
      backendCalls: "CKShare.removeParticipant+ICCollaborationController.saveServerShare"
    )
  }

  private func collaborationPermission(targetID: String, userRecordNameSHA256: String, defaultValue: Int) -> Int {
    participantPermissionsByTargetAndUser[
      collaborationPermissionKey(targetID: targetID, userRecordNameSHA256: userRecordNameSHA256),
      default: defaultValue
    ]
  }

  private func collaborationPermissionKey(targetID: String, userRecordNameSHA256: String) -> String {
    "\(targetID)|\(userRecordNameSHA256)"
  }

  private func collaborationPermissionLabel(_ value: Int) -> String {
    switch value {
    case 1: return "none"
    case 2: return "read-only"
    case 3: return "read-write"
    default: return "unrecognized-\(value)"
    }
  }

  private func collaborationAccessScopeLabel(_ publicPermission: Int) -> String {
    switch publicPermission {
    case 1: return "invited-only"
    case 2, 3: return "anyone-with-link"
    default: return "unrecognized-\(publicPermission)"
    }
  }

  private func collaborationAccessScopePublicPermissionValue(
    accessScopeLabel: String,
    beforePublicPermission: Int
  ) -> Int {
    switch accessScopeLabel {
    case "invited-only":
      return 1
    case "anyone-with-link":
      return beforePublicPermission > 1 ? beforePublicPermission : 2
    default:
      return beforePublicPermission
    }
  }

  func insertParticipantMention(_ draft: NotesCollaborationMentionDraft) throws
    -> NotesCollaborationMentionWriteResult
  {
    collaborationMentionDrafts.append(draft)
    guard let state = states[draft.noteID] else {
      throw StateAuditImplementationError.unsupported
    }
    let participantCount = state.participantCount ?? 0
    let wasShared = state.isSharedViaICloud || state.isSharedViaICloudFolder || participantCount > 0
    guard wasShared else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant mention requires an already shared note.",
        details: [
          "operation": "notes.state.mention",
          "capability": "semantic_participant_mention",
          "required_state": "shared_note",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    guard state.isEditable && state.isSharedReadOnly == false else {
      throw CLIError(
        code: .validationError,
        message: "Notes participant mention requires an editable shared note.",
        details: [
          "operation": "notes.state.mention",
          "capability": "semantic_participant_mention",
          "note_id_sha256": sha256Hex(draft.noteID),
        ]
      )
    }
    let participants = [
      (raw: "ada@example.com", recordHash: sha256Hex("ada@example.com")),
      (raw: "grace@example.com", recordHash: sha256Hex("grace@example.com")),
    ]
    guard let participant = participants.first(where: { item in
      draft.target == item.raw
        || draft.target == item.recordHash
        || draft.target == sha256Hex(item.recordHash)
    }) else {
      throw CLIError(
        code: .notFound,
        message: "Notes participant mention target did not match an existing shared-note participant.",
        details: [
          "operation": "notes.state.mention",
          "capability": "semantic_participant_mention",
          "target_sha256": sha256Hex(draft.target),
          "participant_count": "\(participantCount)",
        ]
      )
    }

    let noteKey = draft.noteID
    let participantKey = "\(draft.noteID)|\(participant.recordHash)"
    let before = mentionCountsByNote[noteKey, default: 0]
    let targetBefore = mentionCountsByNoteAndParticipant[participantKey, default: 0]
    mentionCountsByNote[noteKey] = before + 1
    mentionCountsByNoteAndParticipant[participantKey] = targetBefore + 1
    let mentionText = draft.text ?? "@"
    return NotesCollaborationMentionWriteResult(
      noteID: draft.noteID,
      targetSHA256: sha256Hex(draft.target),
      targetParticipantIDSHA256: sha256Hex(participant.recordHash),
      targetUserRecordNameSHA256: participant.recordHash,
      mentionTextSHA256: sha256Hex(mentionText),
      mentionTextByteCount: mentionText.utf8.count,
      beforeMentionCount: before,
      afterMentionCount: before + 1,
      targetBeforeMentionCount: targetBefore,
      targetAfterMentionCount: targetBefore + 1,
      insertedAttachmentIDSHA256: sha256Hex("mention-attachment-\(draft.noteID)-\(before + 1)"),
      insertedIdentifierSHA256: sha256Hex("mention-identifier-\(draft.noteID)-\(before + 1)"),
      wasShared: wasShared,
      participantCount: participantCount,
      backendCalls: "ICInlineAttachment.newMentionAttachmentWithIdentifier+ICNote.textStorage"
    )
  }

  func readNoteActivity(noteID id: String) throws -> NotesNoteActivityRecord {
    noteActivityReadIDs.append(id)
    guard let state = states[id] else {
      throw StateAuditImplementationError.unsupported
    }
    return NotesNoteActivityRecord(
      noteID: state.noteID,
      isShared: state.isSharedViaICloud || state.isSharedViaICloudFolder,
      isSharedReadOnly: state.isSharedReadOnly,
      isSharedViaICloudFolder: state.isSharedViaICloudFolder,
      hasUnreadChanges: state.hasUnreadChanges,
      participantCount: state.participantCount ?? 0,
      participantUserIDSHA256s: state.participantUserIDSHA256s,
      supportsActivityEvents: true,
      activityEventsPresent: !Self.activityEventBytes.isEmpty,
      activityEventsByteCount: Self.activityEventBytes.count,
      activityEventsSHA256: sha256Hex(Self.activityEventBytes),
      activityEventsDocumentPresent: true,
      persistedActivityEventsStorageCount: 2,
      checklistActivityEventsStorageCount: 1,
      shareTimestampPresent: true,
      shareTimestampSHA256: sha256Hex("2026-06-23T00:00:00Z")
    )
  }

  func readSettings(account: String?) throws -> NotesSettingsReadEvidence {
    let activeAccounts = accounts.filter { record in
      onMyMacAccountPresent || record.id != "account-local"
    }
    let selectedAccounts = activeAccounts.filter { record in
      account == nil
        || record.id.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame
        || record.name.localizedCaseInsensitiveCompare(account ?? "") == .orderedSame
    }
    if account != nil && selectedAccounts.isEmpty {
      throw CLIError(
        code: .notFound,
        message: "Notes settings account scope was not found.",
        details: ["account_sha256": account.map(sha256Hex) ?? ""]
      )
    }
    return NotesSettingsReadEvidence(
      accountScope: account == nil ? "all" : "selected",
      requestedAccountSHA256: account.map(sha256Hex),
      accountCount: activeAccounts.count,
      selectedAccountCount: selectedAccounts.count,
      defaultAccountIDSHA256: defaultAccountIDSHA256,
      onMyMacAccountPresent: onMyMacAccountPresent,
      supportsQueryDateHeaders: supportsQueryDateHeaders,
      showsQueryDateHeaders: showsQueryDateHeaders,
      families: notesSettingsFamilies(
        defaultAccountIDSHA256: defaultAccountIDSHA256,
        onMyMacAccountPresent: onMyMacAccountPresent,
        currentNoteListSortSHA256: noteListSortSHA256,
        defaultParagraphStyleSHA256: defaultParagraphStyleSHA256,
        groupNotesByDateEnabled: groupNotesByDateEnabled,
        defaultDateHeadersTypeSHA256: defaultDateHeadersTypeSHA256,
        queryDateHeadersTypeSHA256: queryDateHeadersTypeSHA256,
        supportsQueryDateHeaders: supportsQueryDateHeaders,
        showsQueryDateHeaders: showsQueryDateHeaders,
        quickNoteResumeLastEnabled: quickNoteResumeLastEnabled,
        mentionNotificationsEnabled: mentionNotificationsEnabled,
        checklistAutoSortEnabled: checklistAutoSortEnabled,
        defaultTextSizeSHA256: defaultTextSizeSHA256,
        touchIDPreferenceAvailable: true,
        touchIDPreferenceEnabled: selectedAccounts.count == 1 ? touchIDPreferenceEnabled : nil,
        lockedNotesPassphraseSet: selectedAccounts.count == 1 ? lockedNotesPassphraseSet : nil,
        lockedNotesStateSHA256: selectedAccounts.count == 1
          ? notesLockedNotesPassphraseStateSHA256(
            hasPassphraseSet: lockedNotesPassphraseSet,
            hintSHA256: lockedNotesHintSHA256
          )
          : nil
      )
    )
  }

  func setNoteListSort(_ draft: NotesSettingsSortMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "sort_notes_by"
    let before = try readSettings(account: nil)
    let requestedValueSHA256 = Self.settingsSortSHA256(by: draft.by, direction: draft.direction)
    noteListSortSHA256 = requestedValueSHA256
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "note_list_sort_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256
    )
  }

  func setDefaultNewNoteStyle(_ draft: NotesSettingsParagraphStyleMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    guard draft.style.isDefaultNewNoteStyle else {
      throw CLIError(code: .validationError, message: "Unsupported default new-note paragraph style.")
    }
    let settingID = "new_notes_start_with"
    let before = try readSettings(account: nil)
    let requestedValueSHA256 = Self.settingsParagraphStyleSHA256(draft.style)
    defaultParagraphStyleSHA256 = requestedValueSHA256
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "paragraph_style_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256
    )
  }

  func setDefaultAccount(_ draft: NotesSettingsDefaultAccountMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "default_account"
    guard accounts.contains(where: { $0.id == draft.accountID }) else {
      throw StateAuditImplementationError.unsupported
    }
    let before = try readSettings(account: nil)
    let requestedValueSHA256 = sha256Hex(draft.accountID)
    defaultAccountIDSHA256 = requestedValueSHA256
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_id_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256
    )
  }

  func setGroupNotesByDate(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "group_notes_by_date"
    let before = try readSettings(account: nil)
    groupNotesByDateEnabled = draft.enabled
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: before.families.first { $0.id == settingID }?.boolValue,
      afterBoolValue: after.families.first { $0.id == settingID }?.boolValue
    )
  }

  func setDateHeadersPreference(_ draft: NotesSettingsDateHeadersMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "\(draft.scope)_date_headers_type"
    let before = try readSettings(account: nil)
    let requestedValueSHA256 = notesDateHeadersTypeSHA256(scope: draft.scope, privateValue: draft.privateValue)
    switch draft.scope {
    case "default":
      defaultDateHeadersTypeSHA256 = requestedValueSHA256
    case "query":
      guard supportsQueryDateHeaders else {
        throw StateAuditImplementationError.unsupported
      }
      queryDateHeadersTypeSHA256 = requestedValueSHA256
      showsQueryDateHeaders = draft.enabled
    default:
      throw StateAuditImplementationError.unsupported
    }
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "date_headers_type_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256
    )
  }

  func setQuickNoteResumeLast(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "always_resume_to_last_quick_note"
    let before = try readSettings(account: nil)
    quickNoteResumeLastEnabled = draft.enabled
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: before.families.first { $0.id == settingID }?.boolValue,
      afterBoolValue: after.families.first { $0.id == settingID }?.boolValue
    )
  }

  func setMentionNotifications(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "allow_mention_notifications"
    let before = try readSettings(account: nil)
    mentionNotificationsEnabled = draft.enabled
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: before.families.first { $0.id == settingID }?.boolValue,
      afterBoolValue: after.families.first { $0.id == settingID }?.boolValue
    )
  }

  func setDefaultTextSize(_ draft: NotesSettingsTextSizeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "default_text_size"
    let before = try readSettings(account: nil)
    let requestedValueSHA256 = Self.settingsTextSizeSHA256(draft.pointSize)
    defaultTextSizeSHA256 = requestedValueSHA256
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "text_size_sha256",
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256
    )
  }

  func setOnMyMacAccountEnabled(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "enable_on_my_mac_account"
    let before = try readSettings(account: nil)
    if draft.enabled {
      onMyMacAccountPresent = true
    } else if onMyMacAccountPresent {
      guard localAccountNoteCount == 0,
        localAccountCustomFolderCount == 0,
        nonLocalAccountCount > 0,
        !defaultAccountIsLocal
      else {
        throw CLIError(
          code: .validationError,
          message: "Disabling the Notes On My Mac account requires an empty non-default local account and another active Notes account.",
          details: [
            "operation": "notes.settings.on-my-mac",
            "capability": settingID,
            "status": "refused",
            "required_local_note_count": "0",
            "local_note_count": "\(localAccountNoteCount)",
            "required_local_custom_folder_count": "0",
            "local_custom_folder_count": "\(localAccountCustomFolderCount)",
            "non_local_account_count": "\(nonLocalAccountCount)",
            "default_account_is_local": defaultAccountIsLocal ? "true" : "false",
            "backend_calls": "private_framework_read_preflight_only",
          ]
        )
      }
      onMyMacAccountPresent = false
    }
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: before.families.first { $0.id == settingID }?.boolValue,
      afterBoolValue: after.families.first { $0.id == settingID }?.boolValue,
      localAccountNoteCountBefore: draft.enabled || !before.onMyMacAccountPresent ? nil : localAccountNoteCount,
      localAccountCustomFolderCountBefore: draft.enabled || !before.onMyMacAccountPresent ? nil : localAccountCustomFolderCount,
      nonLocalAccountCountBefore: draft.enabled || !before.onMyMacAccountPresent ? nil : nonLocalAccountCount
    )
  }

  func setChecklistAutoSort(_ draft: NotesSettingsBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "automatically_sort_checked_items"
    let before = try readSettings(account: nil)
    checklistAutoSortEnabled = draft.enabled
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: nil)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "bool",
      requestedBoolValue: draft.enabled,
      beforeBoolValue: before.families.first { $0.id == settingID }?.boolValue,
      afterBoolValue: after.families.first { $0.id == settingID }?.boolValue
    )
  }

  func setTouchIDPreference(_ draft: NotesSettingsAccountBoolMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "use_touch_id"
    let before = try readSettings(account: draft.account)
    touchIDPreferenceEnabled = draft.enabled
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: draft.account)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_scoped_bool",
      accountSHA256: sha256Hex(draft.account),
      preferenceKeySHA256: sha256Hex("touch-id-key|\(draft.account)"),
      requestedBoolValue: draft.enabled,
      beforeBoolValue: before.families.first { $0.id == settingID }?.boolValue,
      afterBoolValue: after.families.first { $0.id == settingID }?.boolValue,
      localAuthenticationAvailable: true,
      biometricsEnrolled: true,
      biometricsTypeSHA256: sha256Hex("ICLocalAuthentication.biometricsType|1")
    )
  }

  func setCustomPassphrase(_ draft: NotesSettingsPassphraseMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "locked_notes"
    let before = try readSettings(account: draft.account)
    let requestedValueSHA256 = notesLockedNotesPassphraseStateSHA256(
      hasPassphraseSet: true,
      hintSHA256: draft.hintSHA256
    )
    customPassphraseDrafts.append(draft)
    lockedNotesPassphraseSet = true
    lockedNotesHintSHA256 = draft.hintSHA256
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: draft.account)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_passphrase_state",
      accountSHA256: sha256Hex(draft.account),
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256,
      passphraseSourceKind: draft.passphraseSourceKind,
      hintSHA256: draft.hintSHA256,
      hintLength: draft.hint?.utf8.count,
      backendCalls: draft.isReset
        ? "ICAccountPassphraseManager.setPassphrase:hint:isReset:"
        : "ICAccountPassphraseManager.setPassphrase:hint:",
      resetRequested: draft.isReset
    )
  }

  func changeCustomPassphrase(_ draft: NotesSettingsPassphraseChangeMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "locked_notes"
    let before = try readSettings(account: draft.account)
    let requestedValueSHA256 = notesLockedNotesPassphraseStateSHA256(
      hasPassphraseSet: true,
      hintSHA256: draft.hintSHA256
    )
    customPassphraseChangeDrafts.append(draft)
    lockedNotesPassphraseSet = true
    lockedNotesHintSHA256 = draft.hintSHA256
    settingsWriteOperations.append(settingID)
    let after = try readSettings(account: draft.account)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "account_passphrase_state",
      accountSHA256: sha256Hex(draft.account),
      requestedValueSHA256: requestedValueSHA256,
      beforeValueSHA256: before.families.first { $0.id == settingID }?.valueSHA256,
      afterValueSHA256: after.families.first { $0.id == settingID }?.valueSHA256,
      oldPassphraseSourceKind: draft.oldPassphraseSourceKind,
      newPassphraseSourceKind: draft.newPassphraseSourceKind,
      hintSHA256: draft.hintSHA256,
      hintLength: draft.hint?.utf8.count,
      backendCalls: "ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:",
      passwordChangeRequested: true
    )
  }

  func setLockedNotesMethod(_ draft: NotesSettingsLockedNotesMethodMutationDraft) throws
    -> NotesSettingsPreferenceWriteResult
  {
    let settingID = "locked_notes_method"
    let beforeValueSHA256 = notesLockedNotesModeStateSHA256(
      modeRawValue: lockedNotesModeRawValue,
      methodScope: Self.lockedNotesMethodScope(modeRawValue: lockedNotesModeRawValue)
    )
    lockedNotesMethodDrafts.append(draft)
    lockedNotesModeRawValue = draft.modeRawValue
    settingsWriteOperations.append(settingID)
    return NotesSettingsPreferenceWriteResult(
      settingID: settingID,
      valueKind: "locked_notes_mode_state",
      accountSHA256: sha256Hex(draft.account),
      requestedValueSHA256: draft.modeSHA256,
      beforeValueSHA256: beforeValueSHA256,
      afterValueSHA256: notesLockedNotesModeStateSHA256(
        modeRawValue: lockedNotesModeRawValue,
        methodScope: Self.lockedNotesMethodScope(modeRawValue: lockedNotesModeRawValue)
      ),
      backendCalls: "ICAccount.setResolvedLockedNotesMode:",
      systemPasscodeAvailable: true,
      lockedNotesModeSupported: true,
      passwordProtectedNoteCountBefore: 0
    )
  }

  private static func lockedNotesMethodScope(modeRawValue: Int) -> String {
    switch modeRawValue {
    case 1:
      return "custom"
    case 2:
      return "login-password"
    default:
      return "unknown"
    }
  }

  private static func settingsParagraphStyleSHA256(_ style: NotesBodyParagraphStyle) -> String {
    sha256Hex("ICTextStyle.noteDefaultNamedStyle|\(style.rawValue)")
  }

  private static func settingsSortSHA256(by: String, direction: String) -> String {
    sha256Hex("ICNoteListSortUtilities.currentNoteListSortType|\(by)|\(direction)")
  }

  private static func settingsTextSizeSHA256(_ pointSize: Double) -> String {
    sha256Hex("ICMZoomController.globalZoomFactorIndex|\(formattedFontPointSize(pointSize))")
  }

  func listAccounts() throws -> [NotesAccountRecord] { accounts }
  func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    let folders = [
      NotesFolderRecord(
        id: "folder-archive",
        name: "Archive",
        accountName: "iCloud",
        isSharedViaICloud: false,
        isSharedReadOnly: false
      ),
      NotesFolderRecord(
        id: "folder-shared",
        name: "Private Shared Folder",
        accountName: "iCloud",
        isSharedViaICloud: true,
        isSharedReadOnly: false
      ),
    ]
    let filtered = account.map { accountName in
      folders.filter { $0.accountName.localizedCaseInsensitiveCompare(accountName) == .orderedSame }
    } ?? folders
    return Array(filtered.prefix(limit))
  }
  func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    throw StateAuditImplementationError.unsupported
  }
  func readNote(id: String) throws -> NotesNoteDetail? {
    readNoteLookups.append(id)
    return notes.first { $0.id == id }
  }
  func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws -> [NotesNoteDetail] {
    throw StateAuditImplementationError.unsupported
  }

  func listAttachments(noteID id: String, limit: Int) throws -> [NotesAttachmentRecord] {
    attachmentReadIDs.append(id)
    return Array((attachmentsByNote[id] ?? []).prefix(limit))
  }
  func exportAttachment(noteID id: String, attachmentID: String) throws -> NotesAttachmentExportSource {
    throw StateAuditImplementationError.unsupported
  }
  func exportAttachmentPDF(noteID id: String, attachmentID: String) throws -> NotesAttachmentPDFExportSource {
    throw StateAuditImplementationError.unsupported
  }
  func inspectAttachmentMarkup(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentMarkupInspectionSource
  {
    throw StateAuditImplementationError.unsupported
  }
  func readAttachmentAudioTranscript(noteID id: String, attachmentID: String) throws
    -> NotesAttachmentAudioTranscriptSource
  {
    throw StateAuditImplementationError.unsupported
  }

  func createFolder(_ draft: NotesFolderCreateDraft) throws -> NotesFolderRecord {
    throw StateAuditImplementationError.unsupported
  }
  func renameFolder(_ draft: NotesFolderRenameDraft) throws -> NotesFolderRecord {
    throw StateAuditImplementationError.unsupported
  }
  func moveFolder(_ draft: NotesFolderMoveDraft) throws -> NotesFolderRecord {
    throw StateAuditImplementationError.unsupported
  }
  func deleteFolder(_ draft: NotesFolderDeleteDraft) throws -> Bool {
    throw StateAuditImplementationError.unsupported
  }
  func sortFolder(_ draft: NotesFolderSortDraft) throws -> NotesFolderRecord {
    throw StateAuditImplementationError.unsupported
  }
  func setFolderDateHeaders(_ draft: NotesFolderDateHeadersDraft) throws -> NotesFolderRecord {
    throw StateAuditImplementationError.unsupported
  }
  func createNote(_ draft: NotesCreateDraft) throws -> NotesNoteDetail {
    throw StateAuditImplementationError.unsupported
  }
  func updateNote(id: String, patch: NotesUpdatePatch) throws -> NotesNoteDetail {
    throw StateAuditImplementationError.unsupported
  }
  func moveNote(_ draft: NotesMoveDraft) throws -> NotesNoteDetail {
    throw StateAuditImplementationError.unsupported
  }
  func copyNote(_ draft: NotesCopyDraft) throws -> NotesNoteDetail {
    throw StateAuditImplementationError.unsupported
  }
  func readRestorableNote(id: String) throws -> NotesNoteDetail? {
    throw StateAuditImplementationError.unsupported
  }
  func listRestorableNotes(limit: Int) throws -> [NotesNoteDetail] {
    throw StateAuditImplementationError.unsupported
  }
  func restoreNote(_ draft: NotesRestoreDraft) throws -> NotesNoteDetail {
    throw StateAuditImplementationError.unsupported
  }
  func deleteNote(id: String) throws -> Bool { throw StateAuditImplementationError.unsupported }
  func purgeNote(id: String) throws -> Bool { throw StateAuditImplementationError.unsupported }
  func setNotePinned(id: String, pinned: Bool) throws -> NotesNoteDetail {
    throw StateAuditImplementationError.unsupported
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
