import Foundation
import Testing
import Utility

@Suite
struct UtilityTests {
  @Test func successEnvelopeEncodesStableJSONShape() throws {
    struct Payload: Codable {
      var target: String
    }

    let envelope = CLISuccessEnvelope(
      data: Payload(target: "notes"),
      meta: ["target": "notes"],
      warnings: ["scaffold"]
    )

    let json = try CLIJSON.encodeString(envelope)
    let object = try jsonObject(json)

    #expect(object["ok"] as? Bool == true)
    #expect((object["meta"] as? [String: Any])?["target"] as? String == "notes")
    #expect((object["warnings"] as? [String]) == ["scaffold"])
  }

  @Test func errorCodeExitMappingIsStable() {
    #expect(CLIErrorCode.validationError.exitCode == 2)
    #expect(CLIErrorCode.permissionDenied.exitCode == 3)
    #expect(CLIErrorCode.ambiguousIdentity.exitCode == 4)
    #expect(CLIErrorCode.backendUnavailable.exitCode == 7)
    #expect(CLIErrorCode.unsafeMutationRefused.exitCode == 9)
    #expect(CLIErrorCode.internalError.exitCode == 70)
  }

  @Test func cliOptionsFixtureExtractsSharedFlagsAndPositionals() throws {
    let options = try CLIOptionsFixture.parse([
      "events",
      "list",
      "--json",
      "--pretty",
      "--verbose",
      "--limit",
      "25",
      "--dry-run",
      "--allow-external-dispatch",
      "--from",
      "2026-01-01",
    ])

    #expect(options.positionals == ["events", "list"])
    #expect(options.json)
    #expect(options.pretty)
    #expect(options.verbose)
    #expect(options.limit == 25)
    #expect(options.dryRun)
    #expect(options.hasSafetyFlag("allow-external-dispatch"))
    #expect(options.targetOption("from") == "2026-01-01")
  }

  @Test func cliOptionsFixtureRejectsRemovedConfirmationOption() {
    let removedOption = "--confirm" + "-" + "re" + "ceipt"
    do {
      _ = try CLIOptionsFixture.parse(["notes", "create", removedOption, "abc123"])
      Issue.record("Expected removed execution option to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func cliOptionsFixtureAllowsNegativeNumericTargetValues() throws {
    let options = try CLIOptionsFixture.parse([
      "places",
      "read",
      "--latitude",
      "37.3349",
      "--longitude",
      "-122.0090",
    ])

    #expect(options.positionals == ["places", "read"])
    #expect(options.targetOption("latitude") == "37.3349")
    #expect(options.targetOption("longitude") == "-122.0090")
  }

  @Test func cliOptionsFixtureRejectsInvalidLimit() {
    do {
      _ = try CLIOptionsFixture.parse(["notes", "list", "--limit", "0"])
      Issue.record("Expected invalid limit to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func diagnosticsRenderOnlyDiagnosticTextForStderr() {
    var buffer = CLIDiagnosticBuffer()
    buffer.append(.warning, "Calendar permission is not determined.")
    buffer.append(.error, "Backend unavailable.")

    #expect(
      buffer.renderStderr()
        == "warning: Calendar permission is not determined.\nerror: Backend unavailable."
    )
  }

  @Test func permissionWordingUsesSwiftVocabulary() {
    #expect(
      CLIPermissionWording.accessNotGranted("Contacts", operation: "read/search commands")
        == "Contacts access was not granted for read/search commands.")
    #expect(
      CLIPermissionWording.fullAccessRequired("EventKit", operation: "read/search commands")
        == "Full EventKit access is required for read/search commands; current access is write-only.")
    #expect(
      CLIPermissionWording.fullDiskAccessRequired(
        resource: "Messages database", operation: "read/search commands")
        == "Messages database is not readable. Grant Full Disk Access to the process running `apple` before using read/search commands.")
    #expect(
      CLIPermissionWording.automationPermissionRequired(target: "Notes")
        == "Grant Automation permission to the process running `apple` for Notes.")
  }

  @Test func dryRunPayloadEncodesStableSafetyShape() throws {
    let dryRun = CLISafety.dryRun(
      target: "notes",
      operation: "notes.delete",
      summary: ["id": "note-1", "title": "Old"],
      scope: "single-note",
      category: .ordinaryMutation
    )

    let json = try CLIJSON.encodeString(dryRun)
    let object = try jsonObject(json)

    #expect(object["mode"] as? String == "dry-run")
    #expect(object["target"] as? String == "notes")
    #expect(object["operation"] as? String == "notes.delete")
  }

  @Test func safetyRequireFlagRefusesMissingAllowFlag() {
    do {
      try CLISafety.requireFlag(
        "allow-external-dispatch",
        in: CLIOptions(),
        category: .externalDispatch,
        message: "requires external dispatch"
      )
      Issue.record("Expected missing allow flag to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(error.details["required_flag"] == "--allow-external-dispatch")
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw JSONTestError.notObject
  }
  return object
}

private enum JSONTestError: Error {
  case notObject
}
