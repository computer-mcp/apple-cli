import ClipboardCLI
import Foundation
import NotificationsCLI
import Testing
import Utility

@Suite
struct SystemDomainCommandTests {
  @Test func clipboardTypesReturnsJSONWithoutContent() throws {
    let backend = FakeClipboardBackend(text: "secret")
    let command = ClipboardCommand(backend: backend)
    let options = try CLIOptionsFixture.parse(["clipboard", "types", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(object["ok"] as? Bool == true)
    #expect(data?["types"] as? [String] == ["public.utf8-plain-text"])
    #expect(result.stderr == nil)
  }

  @Test func clipboardReadKeepsSensitiveContentInStdoutResultOnly() throws {
    let backend = FakeClipboardBackend(text: "private clipboard value")
    let command = ClipboardCommand(backend: backend)
    let options = try CLIOptionsFixture.parse(["clipboard", "read", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let item = data?["item"] as? [String: Any]

    #expect(data?["sensitive"] as? Bool == true)
    #expect(item?["value"] as? String == "private clipboard value")
    #expect(result.stderr == nil)
  }

  @Test func clipboardWriteRequiresAllowPersistentAction() throws {
    let command = ClipboardCommand(backend: FakeClipboardBackend(text: "old"))
    let options = try CLIOptionsFixture.parse(["clipboard", "write", "--text", "new", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected clipboard write execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func clipboardWriteDryRunAndAllowFlagExecutesWrite() throws {
    let backend = FakeClipboardBackend(text: "old")
    let command = ClipboardCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "clipboard",
      "write",
      "--text",
      "new",
      "--dry-run",
      "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "clipboard",
      "write",
      "--text",
      "new",
      "--allow-persistent-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["changed"] as? Bool == true)
    #expect(backend.currentText() == "new")
  }

  @Test func clipboardClearAllowExecutionClearsCurrentState() throws {
    let backend = FakeClipboardBackend(text: "old")
    let command = ClipboardCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse(["clipboard", "clear", "--dry-run", "--json"])
    _ = try #require(try command.run(options: dryRunOptions))

    _ = try backend.writeText("changed before execution")

    let executeOptions = try CLIOptionsFixture.parse([
      "clipboard",
      "clear",
      "--allow-persistent-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.currentText() == "")
  }

  @Test func notificationPreviewReturnsJSONWithoutExternalAction() throws {
    let command = NotificationsCommand(backend: FakeNotificationBackend())
    let options = try CLIOptionsFixture.parse([
      "notifications",
      "preview",
      "--title",
      "Build",
      "--body",
      "Done",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let notification = data?["notification"] as? [String: Any]

    #expect(data?["externalAction"] as? Bool == false)
    #expect(notification?["title"] as? String == "Build")
    #expect(notification?["body"] as? String == "Done")
  }

  @Test func notificationSendRequiresAllowExternalDispatch() throws {
    let command = NotificationsCommand(backend: FakeNotificationBackend())
    let options = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected notification send execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func notificationSendDryRunAndAllowFlagExecutesSend() throws {
    let backend = FakeNotificationBackend()
    let command = NotificationsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--dry-run",
      "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--allow-external-dispatch",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["submitted"] as? Bool == true)
    #expect(backend.sentTitles() == ["Build"])
  }

  @Test func notificationAllowExecutionSendsCurrentPayload() throws {
    let backend = FakeNotificationBackend()
    let command = NotificationsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--dry-run",
      "--json",
    ])
    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Changed",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.sentTitles() == ["Build"])
  }
}

private final class FakeClipboardBackend: ClipboardAccessing, @unchecked Sendable {
  private let lock = NSLock()
  private var text: String
  private var changeCount: Int

  init(text: String) {
    self.text = text
    self.changeCount = 1
  }

  func types() -> [String] {
    ["public.utf8-plain-text"]
  }

  func readString(preferredType: String?) -> ClipboardReadItem? {
    ClipboardReadItem(type: preferredType ?? "public.utf8-plain-text", value: currentText())
  }

  func stateDigest() -> String {
    lock.lock()
    let state = "change:\(changeCount)"
    lock.unlock()
    return state
  }

  func writeText(_ text: String) throws -> Bool {
    lock.lock()
    self.text = text
    changeCount += 1
    lock.unlock()
    return true
  }

  func clear() throws -> Bool {
    lock.lock()
    text = ""
    changeCount += 1
    lock.unlock()
    return true
  }

  func currentText() -> String {
    lock.lock()
    let current = text
    lock.unlock()
    return current
  }
}

private final class FakeNotificationBackend: NotificationDelivering, @unchecked Sendable {
  private let lock = NSLock()
  private var sent: [LocalNotificationRequest] = []

  func send(_ request: LocalNotificationRequest) throws -> Bool {
    lock.lock()
    sent.append(request)
    lock.unlock()
    return true
  }

  func sentTitles() -> [String] {
    lock.lock()
    let titles = sent.map(\.title)
    lock.unlock()
    return titles
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw SystemDomainCommandTestError.notObject
  }
  return object
}

private enum SystemDomainCommandTestError: Error {
  case notObject
}
