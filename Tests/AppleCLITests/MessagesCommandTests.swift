import Foundation
import MessagesCLI
import Testing
import Utility

@Suite
struct MessagesCommandTests {
  @Test func messagesConversationsListReturnsJSON() throws {
    let command = MessagesCommand(backend: FakeMessagesBackend())
    let options = try CLIOptionsFixture.parse(["conversations", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let conversations = data?["conversations"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(conversations?.first?["id"] as? String == "conversation:1")
  }

  @Test func messagesSearchRequiresNonTrivialQuery() throws {
    let command = MessagesCommand(backend: FakeMessagesBackend())
    let options = try CLIOptionsFixture.parse(["messages", "search", "--query", "a", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesListRequiresConversationIdentity() throws {
    let command = MessagesCommand(backend: FakeMessagesBackend())
    let options = try CLIOptionsFixture.parse(["messages", "list", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing conversation to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesReadMissingMessageReturnsNotFound() throws {
    let command = MessagesCommand(backend: FakeMessagesBackend())
    let options = try CLIOptionsFixture.parse(["messages", "read", "--id", "message:404", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing message to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesReadOnlyCommandsRejectDryRuns() throws {
    let command = MessagesCommand(backend: FakeMessagesBackend())
    let options = try CLIOptionsFixture.parse([
      "conversations",
      "list",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only Messages command to reject dryRun.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesSendRequiresAllowExternalDispatchBeforeBackend() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "messages",
      "send",
      "--to",
      "ada@example.com",
      "--text",
      "Ship it",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Messages send execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.sentRequests.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesSendDryRunAndAllowFlagExecutesSend() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send",
      "--to",
      "ada@example.com",
      "--text",
      "Secret launch note",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    #expect(dryRun.stdout?.contains("Secret launch note") == false)
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]
    #expect(summary?["to"] as? String == "ada@example.com")
    #expect(summary?["text_byte_count"] as? String == "18")

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send",
      "--to",
      "ada@example.com",
      "--text",
      "Secret launch note",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "messages.send")
    #expect(executedData?["submitted"] as? Bool == true)
    #expect(executedData?["textIncluded"] as? Bool == false)
    #expect(
      backend.sentRequests == [
        MessageSendRequest(recipient: "ada@example.com", text: "Secret launch note")
      ])
  }

  @Test func messagesSendManyRequiresAllowExternalDispatchBeforeBackend() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,grace@example.com",
      "--text",
      "Ship it",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Messages send-many execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.sentRequests.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesSendConversationRequiresAllowExternalDispatchBeforeLookup() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "messages",
      "send-conversation",
      "--conversation",
      "conversation:1",
      "--text",
      "Ship it",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Messages send-conversation execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.conversationIdentityLookups.isEmpty)
      #expect(backend.sentConversationRequests.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesSendConversationDryRunAndAllowFlagExecutesConversation() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-conversation",
      "--conversation",
      "conversation:1",
      "--text",
      "Secret launch note",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    #expect(dryRun.stdout?.contains("Secret launch note") == false)
    #expect(dryRun.stdout?.contains("iMessage;-;chat-ada-grace") == false)
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]
    #expect(data?["operation"] as? String == "messages.send-conversation")
    #expect(summary?["conversation"] as? String == "conversation:1")
    #expect(summary?["participant_count"] as? String == "2")
    #expect(summary?["text_byte_count"] as? String == "18")

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-conversation",
      "--conversation",
      "conversation:1",
      "--text",
      "Secret launch note",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["operation"] as? String == "messages.send-conversation")
    #expect(executedData?["submitted"] as? Bool == true)
    #expect(executedData?["conversationId"] as? String == "conversation:1")
    #expect(executedData?["participantCount"] as? Int == 2)
    #expect(executedData?["textIncluded"] as? Bool == false)
    #expect(
      backend.sentConversationRequests == [
        MessageConversationSendRequest(
          conversationId: "conversation:1",
          automationId: "iMessage;-;chat-ada-grace",
          service: "iMessage",
          participantHandles: ["ada@example.com", "grace@example.com"],
          text: "Secret launch note"
        )
      ])
  }

  @Test func messagesSendConversationAllowExecutionUsesCurrentParticipants() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-conversation",
      "--conversation",
      "conversation:1",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]
    backend.conversationParticipantHandles = ["ada@example.com", "katherine@example.com"]

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-conversation",
      "--conversation",
      "conversation:1",
      "--text",
      "Original",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.sentConversationRequests.first?.participantHandles == [
      "ada@example.com", "katherine@example.com",
    ])
  }

  @Test func messagesSendConversationRejectsNonIMessageConversations() throws {
    let backend = FakeMessagesBackend()
    backend.conversationServiceName = "SMS"
    backend.conversationAutomationId = "SMS;-;chat-ada"
    let command = MessagesCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "messages",
      "send-conversation",
      "--conversation",
      "conversation:1",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected non-iMessage Messages conversation to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsupportedOperation)
      #expect(backend.sentConversationRequests.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesSendManyDryRunAndAllowFlagExecutesRecipients() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,grace@example.com",
      "--text",
      "Secret launch note",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    #expect(dryRun.stdout?.contains("Secret launch note") == false)
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]
    #expect(data?["operation"] as? String == "messages.send-many")
    #expect(summary?["to"] as? String == "ada@example.com,grace@example.com")
    #expect(summary?["recipient_count"] as? String == "2")
    #expect(summary?["text_byte_count"] as? String == "18")

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,grace@example.com",
      "--text",
      "Secret launch note",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let recipients = executedData?["recipients"] as? [[String: Any]]

    #expect(executedData?["operation"] as? String == "messages.send-many")
    #expect(executedData?["requestedCount"] as? Int == 2)
    #expect(executedData?["submittedCount"] as? Int == 2)
    #expect(executedData?["failedCount"] as? Int == 0)
    #expect(executedData?["textIncluded"] as? Bool == false)
    #expect(
      recipients?.map { $0["recipient"] as? String } == ["ada@example.com", "grace@example.com"])
    #expect(
      backend.sentRequests == [
        MessageSendRequest(recipient: "ada@example.com", text: "Secret launch note"),
        MessageSendRequest(recipient: "grace@example.com", text: "Secret launch note"),
      ])
  }

  @Test func messagesSendManyAllowExecutionUsesCurrentRecipients() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,grace@example.com",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "grace@example.com,ada@example.com",
      "--text",
      "Original",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.sentRequests.map(\.recipient) == ["grace@example.com", "ada@example.com"])
  }

  @Test func messagesSendManyRejectsDuplicateRecipients() throws {
    let command = MessagesCommand(backend: FakeMessagesBackend())
    let options = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,Ada@example.com",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected duplicate Messages send-many recipients to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func messagesSendManyReportsPerRecipientFailure() throws {
    let backend = FakeMessagesBackend()
    backend.failingRecipients = ["grace@example.com"]
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,grace@example.com",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send-many",
      "--to",
      "ada@example.com,grace@example.com",
      "--text",
      "Original",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let recipients = try #require(executedData?["recipients"] as? [[String: Any]])

    #expect(executedData?["requestedCount"] as? Int == 2)
    #expect(executedData?["submittedCount"] as? Int == 1)
    #expect(executedData?["failedCount"] as? Int == 1)
    #expect(recipients[0]["submitted"] as? Bool == true)
    #expect(recipients[1]["submitted"] as? Bool == false)
    #expect(recipients[1]["errorCode"] as? String == "backend_unavailable")
    #expect(
      backend.sentRequests == [MessageSendRequest(recipient: "ada@example.com", text: "Original")])
  }

  @Test func messagesSendAllowExecutionUsesCurrentText() throws {
    let backend = FakeMessagesBackend()
    let command = MessagesCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "messages",
      "send",
      "--to",
      "ada@example.com",
      "--text",
      "Original",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "messages",
      "send",
      "--to",
      "ada@example.com",
      "--text",
      "Changed",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.sentRequests == [MessageSendRequest(recipient: "ada@example.com", text: "Changed")])
  }

  @Test func sqliteMessagesBackendParsesConversationAndMessages() throws {
    let backend = SQLiteMessagesBackend(databasePath: "/tmp/chat.db", runner: FakeSQLiteRunner())

    let conversations = try backend.listConversations(limit: 10)
    let conversationIdentity = try #require(try backend.conversationIdentity(id: "conversation:1"))
    let messages = try backend.listMessages(conversationId: "conversation:1", limit: 10)
    let detail = try #require(try backend.readMessage(id: "message:42"))

    #expect(conversations.first?.id == "conversation:1")
    #expect(conversations.first?.participantHandles == ["ada@example.com"])
    #expect(conversationIdentity.automationId == "iMessage;-;chat-ada")
    #expect(messages.first?.id == "message:42")
    #expect(messages.first?.textPreview == "Build finished")
    #expect(detail.text == "Build finished")
  }

  @Test func sqliteMessagesBackendMapsAuthorizationDeniedToPermissionDenied() throws {
    let backend = SQLiteMessagesBackend(databasePath: "/tmp/chat.db", runner: DeniedSQLiteRunner())

    do {
      _ = try backend.listConversations(limit: 10)
      Issue.record("Expected permission denial to throw.")
    } catch let error as CLIError {
      #expect(error.code == .permissionDenied)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private final class FakeMessagesBackend: MessagesReading, MessagesSending, @unchecked Sendable {
  var sentRequests: [MessageSendRequest] = []
  var sentConversationRequests: [MessageConversationSendRequest] = []
  var conversationIdentityLookups: [String] = []
  var conversationAutomationId = "iMessage;-;chat-ada-grace"
  var conversationServiceName = "iMessage"
  var conversationParticipantHandles = ["ada@example.com", "grace@example.com"]
  var failingRecipients: Set<String> = []

  func listConversations(limit: Int) throws -> [MessagesConversationRecord] {
    conversations().prefix(limit).map { $0 }
  }

  func searchConversations(query: String, limit: Int) throws -> [MessagesConversationRecord] {
    conversations()
      .filter { ($0.displayName ?? "").localizedCaseInsensitiveContains(query) }
      .prefix(limit)
      .map { $0 }
  }

  func conversationIdentity(id: String) throws -> MessagesConversationIdentity? {
    conversationIdentityLookups.append(id)
    guard id == "conversation:1" else {
      return nil
    }
    return MessagesConversationIdentity(
      record: conversations()[0], automationId: conversationAutomationId)
  }

  func listMessages(conversationId: String, limit: Int) throws -> [MessagesMessageSummary] {
    messages()
      .filter { $0.conversationId == conversationId }
      .prefix(limit)
      .map { $0 }
  }

  func searchMessages(query: String, conversationId: String?, limit: Int) throws
    -> [MessagesMessageSummary]
  {
    messages()
      .filter { message in
        (conversationId == nil || message.conversationId == conversationId)
          && (message.textPreview ?? "").localizedCaseInsensitiveContains(query)
      }
      .prefix(limit)
      .map { $0 }
  }

  func readMessage(id: String) throws -> MessagesMessageDetail? {
    guard id == "message:42" else {
      return nil
    }
    return MessagesMessageDetail(
      id: "message:42",
      conversationId: "conversation:1",
      handle: "ada@example.com",
      serviceName: "iMessage",
      text: "Build finished",
      isFromMe: false
    )
  }

  private func conversations() -> [MessagesConversationRecord] {
    [
      MessagesConversationRecord(
        id: "conversation:1",
        displayName: "Ada + Grace",
        serviceName: conversationServiceName,
        participantHandles: conversationParticipantHandles,
        messageCount: 1
      )
    ]
  }

  private func messages() -> [MessagesMessageSummary] {
    [
      MessagesMessageSummary(
        id: "message:42",
        conversationId: "conversation:1",
        handle: "ada@example.com",
        serviceName: "iMessage",
        textPreview: "Build finished",
        isFromMe: false
      )
    ]
  }

  func sendMessage(_ request: MessageSendRequest) throws -> Bool {
    if failingRecipients.contains(request.recipient) {
      throw CLIError(code: .backendUnavailable, message: "Messages send failed for this recipient.")
    }
    sentRequests.append(request)
    return true
  }

  func sendMessageToConversation(_ request: MessageConversationSendRequest) throws -> Bool {
    sentConversationRequests.append(request)
    return true
  }
}

private struct FakeSQLiteRunner: SQLiteCommandRunning {
  func runSQLite(databasePath: String, sql: String) throws -> String {
    if sql.contains("FROM chat c") {
      return """
        [{
          "id": 1,
          "displayName": "Ada",
          "serviceName": "iMessage",
          "automationId": "iMessage;-;chat-ada",
          "lastMessageAt": 799286400000000000,
          "messageCount": 1,
          "participantHandles": "ada@example.com"
        }]
        """
    }

    if sql.contains("FROM message m") {
      return """
        [{
          "id": 42,
          "conversationId": 1,
          "handle": "ada@example.com",
          "serviceName": "iMessage",
          "text": "Build finished",
          "sentAt": 799286400000000000,
          "isFromMe": 0
        }]
        """
    }

    return "[]"
  }
}

private struct DeniedSQLiteRunner: SQLiteCommandRunning {
  func runSQLite(databasePath: String, sql: String) throws -> String {
    throw CLIError(code: .permissionDenied, message: "Messages database access was denied.")
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw MessagesCommandTestError.notObject
  }
  return object
}

private enum MessagesCommandTestError: Error {
  case notObject
}
