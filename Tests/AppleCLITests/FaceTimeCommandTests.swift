import FaceTimeCLI
import Foundation
import Testing
import Utility

@Suite
struct FaceTimeCommandTests {
  @Test func faceTimeContactResolveReturnsJSON() throws {
    let command = FaceTimeCommand(resolver: FakeFaceTimeResolver(), caller: FakeFaceTimeCaller())
    let options = try CLIOptionsFixture.parse(["contacts", "resolve", "--query", "Ada", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let contacts = data?["contacts"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(contacts?.first?["displayName"] as? String == "Ada Lovelace")
  }

  @Test func faceTimeContactResolveRequiresNonTrivialQuery() throws {
    let command = FaceTimeCommand(resolver: FakeFaceTimeResolver(), caller: FakeFaceTimeCaller())
    let options = try CLIOptionsFixture.parse(["contacts", "resolve", "--query", "a", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short FaceTime contact query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func faceTimeCallPrepareReturnsPreviewWithoutExternalAction() throws {
    let command = FaceTimeCommand(resolver: FakeFaceTimeResolver(), caller: FakeFaceTimeCaller())
    let options = try CLIOptionsFixture.parse([
      "calls",
      "prepare",
      "--handle",
      "ada@example.com",
      "--kind",
      "audio",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let call = data?["call"] as? [String: Any]

    #expect(call?["kind"] as? String == "audio")
    #expect(call?["externalAction"] as? Bool == false)
    #expect((call?["url"] as? String)?.hasPrefix("facetime-audio://") == true)
  }

  @Test func faceTimeCallStartRequiresAllowExternalDispatch() throws {
    let command = FaceTimeCommand(resolver: FakeFaceTimeResolver(), caller: FakeFaceTimeCaller())
    let options = try CLIOptionsFixture.parse([
      "calls", "start", "--handle", "ada@example.com", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected FaceTime call start execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func faceTimeCallStartDryRunAndAllowFlagExecutesStart() throws {
    let caller = FakeFaceTimeCaller()
    let command = FaceTimeCommand(resolver: FakeFaceTimeResolver(), caller: caller)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "calls",
      "start",
      "--handle",
      "ada@example.com",
      "--dry-run",
      "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "calls",
      "start",
      "--handle",
      "ada@example.com",
      "--allow-external-dispatch",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["submitted"] as? Bool == true)
    #expect(caller.startedURLs().count == 1)
  }

  @Test func faceTimeCallStartAllowExecutionUsesCurrentHandle() throws {
    let caller = FakeFaceTimeCaller()
    let command = FaceTimeCommand(resolver: FakeFaceTimeResolver(), caller: caller)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "calls",
      "start",
      "--handle",
      "ada@example.com",
      "--dry-run",
      "--json",
    ])
    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "calls",
      "start",
      "--handle",
      "grace@example.com",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(caller.startedURLs().count == 1)
  }
}

private struct FakeFaceTimeResolver: FaceTimeResolving {
  func resolveContacts(query: String, limit: Int) throws -> [FaceTimeContactCandidate] {
    [
      FaceTimeContactCandidate(
        contactId: "contact-ada",
        displayName: "Ada Lovelace",
        handles: [
          FaceTimeHandle(kind: "email", value: "ada@example.com"),
          FaceTimeHandle(kind: "phone", value: "+15555550100"),
        ]
      )
    ]
    .filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    .prefix(limit)
    .map { $0 }
  }
}

private final class FakeFaceTimeCaller: FaceTimeCalling, @unchecked Sendable {
  private var urls: [String] = []

  func startCall(_ preview: FaceTimeCallPreview) throws -> Bool {
    urls.append(preview.url)
    return true
  }

  func startedURLs() -> [String] {
    urls
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw FaceTimeCommandTestError.notObject
  }
  return object
}

private enum FaceTimeCommandTestError: Error {
  case notObject
}
