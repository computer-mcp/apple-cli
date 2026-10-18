import Foundation
import Testing
import Utility
@testable import MailCLI

@Suite
struct MailBackendTests {
  @Test func mailSubmissionRequiresNativeAcceptance() throws {
    let backend = MailAppleScriptBackend { _ in
      return [["true"]]
    }
    let result = try backend.sendMail(
      MailDraftRequest(to: ["fixture@example.com"], subject: "Fixture", body: "Private fixture"))

    #expect(result.submitted)
    #expect(result.subject == "Fixture")
    #expect(!result.bodyIncluded)
  }

  @Test(arguments: [[["false"]], [], [["unexpected"]]])
  func mailRejectedOrUnknownSubmissionIsAnError(rows: [[String]]) throws {
    let backend = MailAppleScriptBackend { _ in rows }
    do {
      _ = try backend.sendMail(MailDraftRequest(to: ["fixture@example.com"], subject: "Fixture"))
      Issue.record("Unconfirmed Mail submission must fail.")
    } catch let error as CLIError {
      #expect(error.code == .backendUnavailable)
      #expect(error.details["submission_status"] == (rows == [["false"]] ? "rejected" : "unknown"))
      #expect(error.details["retry_guidance"] == "inspect_mail_before_retrying")
    }
  }

  @Test func mailAutomationFailurePreservesCodeAndUnknownSubmission() throws {
    let backend = MailAppleScriptBackend { _ in
      throw CLIError(code: .permissionDenied, message: "Mail automation denied.")
    }
    do {
      _ = try backend.sendMail(MailDraftRequest(to: ["fixture@example.com"], subject: "Fixture"))
      Issue.record("Mail automation failure must propagate.")
    } catch let error as CLIError {
      #expect(error.code == .permissionDenied)
      #expect(error.details["submission_status"] == "unknown")
    }
  }

  @Test func mailBodyPreviewBoundsUTF8AndKeepsCompleteCharacters() throws {
    for (source, cap, expected) in [
      ("你好世界", 5, "你"),
      ("A😀B", 4, "A"),
      ("A😀B", 5, "A😀"),
      ("a\u{301}b", 2, ""),
      ("plain", 5, "plain"),
    ] {
      let backend = MailAppleScriptBackend { _ in
        [["message-1", "Fixture", "Inbox", "Fixture", "fixture@example.com", "", "false", source, "false"]]
      }
      let result = try #require(try backend.previewMessageBody(
        id: "message-1", account: "Fixture", mailbox: "Inbox", maxBytes: cap))

      #expect(result.body == expected)
      #expect(result.bodyByteCount <= cap)
      #expect(result.bodyByteCount == expected.utf8.count)
      #expect(result.truncated == (source != expected))
      #expect(result.message.bodyIncluded)
    }
  }

  @Test func mailBodyPreviewPreservesAppTruncation() throws {
    let backend = MailAppleScriptBackend { _ in
      [["message-1", "Fixture", "Inbox", "Fixture", "fixture@example.com", "", "false", "short", "true"]]
    }
    let result = try #require(try backend.previewMessageBody(
      id: "message-1", account: "Fixture", mailbox: "Inbox", maxBytes: 10))

    #expect(result.body == "short")
    #expect(result.truncated)
  }

  @Test(arguments: [0, -1, 100_001, Int.max])
  func mailBodyPreviewRejectsInvalidLimitsBeforeAutomation(maxBytes: Int) throws {
    let backend = MailAppleScriptBackend { _ in
      Issue.record("Invalid limits must not access Mail.")
      return []
    }
    do {
      _ = try backend.previewMessageBody(
        id: "message-1", account: "Fixture", mailbox: "Inbox", maxBytes: maxBytes)
      Issue.record("Invalid Mail body limits must fail.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    }
  }
}
