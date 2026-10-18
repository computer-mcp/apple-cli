import Foundation
import Testing
import Utility

@testable import MailCLI
@testable import MessagesCLI
@testable import NotesCLI
@testable import RemindersCLI
@testable import SafariCLI

@Suite
struct ErrorPrivacyTests {
  @Test func reminderKitErrorsDescribeCodesWithoutNativeObjectContents() {
    final class OpaqueFailure: NSObject {
      override var description: String { "private-object-canary" }
    }
    let error = NSError(
      domain: "SyntheticReminderFailure", code: 42,
      userInfo: [NSLocalizedDescriptionKey: "private-reminder-canary"])
    let summary = RemindersCLI.reminderKitErrorSummary(error)
    #expect(summary == "SyntheticReminderFailure (42)")
    #expect(!summary.contains("private-reminder-canary"))
    #expect(!RemindersCLI.reminderKitErrorSummary(OpaqueFailure()).contains("private-object-canary"))
    #expect(RemindersCLI.reminderKitErrorSummary(nil).isEmpty)
  }

  @Test(arguments: [false, true])
  func unexpectedErrorsRetainOnlyDiagnosticMetadata(verbose: Bool) throws {
    let underlying = NSError(
      domain: "SyntheticBackend", code: 17,
      userInfo: [
        NSLocalizedDescriptionKey: "private-error-description-canary",
        NSFilePathErrorKey: "/tmp/private-error-file-canary",
        "password": "private-password-canary",
      ])
    let error = CLIError.unexpected(underlying, verbose: verbose)
    let output = try CLIJSON.encodeString(CLIErrorEnvelope(error: error.payload))

    #expect(error.code == .internalError)
    #expect(error.code.exitCode == 70)
    #expect(!output.contains("canary"))
    #expect(
      error.details
        == (verbose ? ["error_domain": "SyntheticBackend", "error_code": "17"] : [:]))
    #expect(
      CLIError.diagnosticDetails(for: underlying)
        == ["error_domain": "SyntheticBackend", "error_code": "17"])
  }

  @Test(arguments: [-1743, -25211, -1712, -1728, -2700])
  func appleEventErrorsDoNotCopyAppContentIntoOutput(number: Int) throws {
    let errorInfo: NSDictionary = [
      NSAppleScript.errorNumber: number,
      NSAppleScript.errorMessage: "private-app-content-canary /tmp/private-file-canary",
    ]
    let errors = [
      MailCLI.automationError(errorInfo),
      MessagesCLI.messagesAutomationError(errorInfo),
      NotesCLI.automationError(errorInfo),
      SafariCLI.safariAutomationError(errorInfo),
    ]

    for error in errors {
      let output = try CLIJSON.encodeString(
        CLIErrorEnvelope(error: error.payload, meta: [:]))
      #expect(error.details["apple_event_error"] == "\(number)")
      #expect(!output.contains("private-app-content-canary"))
      #expect(!output.contains("private-file-canary"))
    }
    #expect(errors[0].code == (number == -1743 ? .permissionDenied : .backendUnavailable))
    #expect(
      errors[1].code
        == (number == -1743 ? .permissionDenied : number == -1728 ? .notFound : .backendUnavailable))
    #expect(
      errors[2].code
        == ([-1743, -25211].contains(number)
          ? .permissionDenied : number == -1712 ? .timeout : .backendUnavailable))
    #expect(
      errors[3].code
        == ([-1743, -25211].contains(number)
          ? .permissionDenied
          : number == -1712 ? .timeout : number == -1728 ? .notFound : .backendUnavailable))
  }
}
