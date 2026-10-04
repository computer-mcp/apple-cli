import Foundation
import Utility

public struct MessagesCommand: Sendable {
  private let reader: any MessagesReading
  private let sender: any MessagesSending
  private let target = "messages"

  public init(
    reader: any MessagesReading = SQLiteMessagesBackend(),
    sender: any MessagesSending = MessagesAppleScriptSender()
  ) {
    self.reader = reader
    self.sender = sender
  }

  public init(backend: any MessagesReading & MessagesSending) {
    self.reader = backend
    self.sender = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["conversations", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let conversations = try reader.listConversations(limit: try commandLimit(options))
      return try result(
        MessagesConversationsResponse(conversations: conversations),
        human: conversationsHumanOutput(conversations),
        options: options
      )
    case ["conversations", "search"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query"])
      let query = try nonTrivialQuery(options)
      let conversations = try reader.searchConversations(
        query: query, limit: try commandLimit(options))
      return try result(
        MessagesConversationsResponse(conversations: conversations),
        human: conversationsHumanOutput(conversations),
        options: options
      )
    case ["messages", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["conversation"])
      let conversationId = try requiredOption("conversation", options: options)
      let messages = try reader.listMessages(
        conversationId: conversationId, limit: try commandLimit(options))
      return try result(
        MessagesMessagesResponse(messages: messages),
        human: messagesHumanOutput(messages),
        options: options
      )
    case ["messages", "search"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query", "conversation"])
      let query = try nonTrivialQuery(options)
      let messages = try reader.searchMessages(
        query: query,
        conversationId: options.targetOption("conversation"),
        limit: try commandLimit(options)
      )
      return try result(
        MessagesMessagesResponse(messages: messages),
        human: messagesHumanOutput(messages),
        options: options
      )
    case ["messages", "read"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let message = try reader.readMessage(id: id) else {
        throw CLIError(code: .notFound, message: "Message was not found.", details: ["id": id])
      }
      return try result(
        MessagesMessageResponse(message: message),
        human: messageHumanOutput(message),
        options: options
      )
    case ["messages", "send"]:
      try validateTargetOptions(options, allowedOptions: ["to", "text", "service"])
      try validateMutationIntent(options)
      let request = try messageSendRequest(options)
      return try send(request, options: options)
    case ["messages", "send-conversation"]:
      try validateTargetOptions(options, allowedOptions: ["conversation", "text"])
      try validateMutationIntent(options)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-external-dispatch",
          in: options,
          category: .externalDispatch,
          message:
            "Messages conversation send dispatches to Messages.app and requires `--allow-external-dispatch`."
        )
      }
      let request = try messageConversationSendRequest(options, reader: reader)
      return try sendConversation(request, options: options)
    case ["messages", "send-many"]:
      try validateTargetOptions(options, allowedOptions: ["to", "text", "service"])
      try validateMutationIntent(options)
      let requests = try messageBatchSendRequests(options)
      return try sendMany(requests, options: options)
    default:
      return nil
    }
  }

  private func send(_ request: MessageSendRequest, options: CLIOptions) throws -> CLICommandResult {
    let operation = "messages.send"
    let scopeDigest = messageSendScopeDigest(request)
    let summary = messageSendSummary(request)

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "Messages send dispatches to Messages.app and requires `--allow-external-dispatch`."
    )

    let submitted = try sender.sendMessage(request)
    return try result(
      MessageSendResult(
        operation: operation,
        submitted: submitted,
        recipient: request.recipient,
        service: request.service,
        textIncluded: false
      ),
      human: "messages.send submitted=\(submitted)",
      options: options
    )
  }

  private func sendConversation(
    _ request: MessageConversationSendRequest,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "messages.send-conversation"
    let scopeDigest = messageConversationSendScopeDigest(request)
    let summary = messageConversationSendSummary(request)

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message:
        "Messages conversation send dispatches to Messages.app and requires `--allow-external-dispatch`."
    )

    let submitted = try sender.sendMessageToConversation(request)
    return try result(
      MessageConversationSendResult(
        operation: operation,
        submitted: submitted,
        conversationId: request.conversationId,
        participantCount: request.participantHandles.count,
        service: request.service,
        textIncluded: false
      ),
      human: "messages.send-conversation submitted=\(submitted)",
      options: options
    )
  }

  private func sendMany(_ requests: [MessageSendRequest], options: CLIOptions) throws
    -> CLICommandResult
  {
    let operation = "messages.send-many"
    let scopeDigest = messageBatchSendScopeDigest(requests)
    let summary = messageBatchSendSummary(requests)

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "Messages send-many dispatches to Messages.app and requires `--allow-external-dispatch`."
    )

    var recipientResults: [MessageBatchSendRecipientResult] = []
    for request in requests {
      do {
        let submitted = try sender.sendMessage(request)
        recipientResults.append(
          MessageBatchSendRecipientResult(
            recipient: request.recipient,
            service: request.service,
            submitted: submitted
          )
        )
      } catch let error as CLIError {
        recipientResults.append(
          MessageBatchSendRecipientResult(
            recipient: request.recipient,
            service: request.service,
            submitted: false,
            errorCode: error.code.rawValue,
            errorMessage: error.message
          )
        )
      } catch {
        recipientResults.append(
          MessageBatchSendRecipientResult(
            recipient: request.recipient,
            service: request.service,
            submitted: false,
            errorCode: CLIErrorCode.internalError.rawValue,
            errorMessage: "Messages send failed for this recipient."
          )
        )
      }
    }

    return try result(
      MessageBatchSendResult(
        operation: operation, recipients: recipientResults, service: requests[0].service),
      human:
        "\(operation) submitted=\(recipientResults.filter(\.submitted).count)/\(requests.count)",
      options: options
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
