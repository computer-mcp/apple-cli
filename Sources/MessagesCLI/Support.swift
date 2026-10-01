import CryptoKit
import Foundation
import Utility

func conversationRecord(_ row: [String: Any]) throws -> MessagesConversationRecord {
  let rawID = try requiredInt(row["id"], field: "id")
  return MessagesConversationRecord(
    id: "conversation:\(rawID)",
    displayName: optionalString(row["displayName"]),
    serviceName: optionalString(row["serviceName"]),
    participantHandles: splitHandles(optionalString(row["participantHandles"])),
    lastMessageAt: messageDate(row["lastMessageAt"]),
    messageCount: optionalInt(row["messageCount"]) ?? 0
  )
}

func parseConversationIdentity(_ row: [String: Any]) throws -> MessagesConversationIdentity {
  guard let automationId = optionalString(row["automationId"]) else {
    throw CLIError(
      code: .backendUnavailable,
      message: "Messages conversation identity is missing its automation id."
    )
  }
  return try MessagesConversationIdentity(
    record: conversationRecord(row), automationId: automationId)
}

func messageSummary(_ row: [String: Any]) throws -> MessagesMessageSummary {
  let rawID = try requiredInt(row["id"], field: "id")
  let conversationID = try requiredInt(row["conversationId"], field: "conversationId")
  return MessagesMessageSummary(
    id: "message:\(rawID)",
    conversationId: "conversation:\(conversationID)",
    handle: optionalString(row["handle"]),
    serviceName: optionalString(row["serviceName"]),
    textPreview: optionalString(row["text"]).map { truncated($0, limit: 160) },
    sentAt: messageDate(row["sentAt"]),
    isFromMe: optionalBool(row["isFromMe"]) ?? false
  )
}

func messageDetail(_ row: [String: Any]) throws -> MessagesMessageDetail {
  let rawID = try requiredInt(row["id"], field: "id")
  let conversationID = try requiredInt(row["conversationId"], field: "conversationId")
  return MessagesMessageDetail(
    id: "message:\(rawID)",
    conversationId: "conversation:\(conversationID)",
    handle: optionalString(row["handle"]),
    serviceName: optionalString(row["serviceName"]),
    text: optionalString(row["text"]),
    sentAt: messageDate(row["sentAt"]),
    isFromMe: optionalBool(row["isFromMe"]) ?? false
  )
}

func validateReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation or external-action commands."
    )
  }
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateMutationIntent(_ options: CLIOptions) throws {}

func validateTargetOptions(_ options: CLIOptions, allowedOptions: Set<String>) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if !unknownOptions.isEmpty || !options.targetFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(options.targetFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name),
    !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  else {
    throw CLIError(code: .validationError, message: "Missing required option `--\(name)`.")
  }
  return value
}

func nonTrivialQuery(_ options: CLIOptions) throws -> String {
  let query = try requiredOption("query", options: options)
  guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
    throw CLIError(
      code: .validationError,
      message: "`--query` must contain at least 2 non-whitespace characters.")
  }
  return query
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 25
  guard limit <= 200 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 200 for Messages read commands.")
  }
  return limit
}

func numericIdentifier(_ value: String, prefix: String) throws -> Int64 {
  guard value.hasPrefix(prefix), let id = Int64(value.dropFirst(prefix.count)), id > 0 else {
    throw CLIError(
      code: .validationError,
      message: "Expected identifier with prefix `\(prefix)`.",
      details: ["id": value]
    )
  }
  return id
}

func requiredInt(_ value: Any?, field: String) throws -> Int64 {
  if let number = value as? NSNumber {
    return number.int64Value
  }
  if let string = value as? String, let int = Int64(string) {
    return int
  }
  throw CLIError(code: .internalError, message: "Missing sqlite field.", details: ["field": field])
}

func optionalInt(_ value: Any?) -> Int? {
  if let number = value as? NSNumber {
    return number.intValue
  }
  if let string = value as? String {
    return Int(string)
  }
  return nil
}

func optionalBool(_ value: Any?) -> Bool? {
  if let number = value as? NSNumber {
    return number.intValue != 0
  }
  if let string = value as? String, let int = Int(string) {
    return int != 0
  }
  return nil
}

func optionalString(_ value: Any?) -> String? {
  guard let value, !(value is NSNull) else {
    return nil
  }
  if let string = value as? String {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
  return String(describing: value)
}

func splitHandles(_ value: String?) -> [String] {
  guard let value else {
    return []
  }
  return value.split(separator: ",")
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
    .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
}

func messageDate(_ value: Any?) -> Date? {
  let raw: Double?
  if let number = value as? NSNumber {
    raw = number.doubleValue
  } else if let string = value as? String {
    raw = Double(string)
  } else {
    raw = nil
  }

  guard let raw, raw > 0 else {
    return nil
  }

  if raw > 10_000_000_000 {
    return Date(timeIntervalSinceReferenceDate: raw / 1_000_000_000)
  }

  return Date(timeIntervalSinceReferenceDate: raw)
}

func messageSendRequest(_ options: CLIOptions) throws -> MessageSendRequest {
  let recipient = try normalizedRecipient(try requiredOption("to", options: options))
  let text = try messageText(options)

  return MessageSendRequest(
    recipient: recipient,
    service: try messageService(options.targetOption("service")),
    text: text
  )
}

func messageConversationSendRequest(
  _ options: CLIOptions,
  reader: any MessagesReading
) throws -> MessageConversationSendRequest {
  let conversationId = try requiredOption("conversation", options: options)
  _ = try numericIdentifier(conversationId, prefix: "conversation:")
  let text = try messageText(options)

  guard let identity = try reader.conversationIdentity(id: conversationId) else {
    throw CLIError(
      code: .notFound, message: "Messages conversation was not found.",
      details: ["id": conversationId])
  }

  let service = try conversationSendService(identity)
  let participants = try normalizedConversationParticipants(identity.record.participantHandles)
  let automationId = try normalizedConversationAutomationId(identity.automationId)
  return MessageConversationSendRequest(
    conversationId: identity.record.id,
    automationId: automationId,
    service: service,
    participantHandles: participants,
    text: text
  )
}

func messageBatchSendRequests(_ options: CLIOptions) throws -> [MessageSendRequest] {
  let rawRecipients = try requiredOption("to", options: options)
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  let nonEmptyRecipients = rawRecipients.filter { !$0.isEmpty }
  guard nonEmptyRecipients.count == rawRecipients.count, !nonEmptyRecipients.isEmpty else {
    throw CLIError(
      code: .validationError, message: "`--to` must contain non-empty comma-separated recipients.")
  }
  guard nonEmptyRecipients.count <= 10 else {
    throw CLIError(
      code: .validationError,
      message: "`--to` cannot contain more than 10 recipients for `messages send-many`.")
  }

  let recipients = try nonEmptyRecipients.map(normalizedRecipient)
  var seen: Set<String> = []
  for recipient in recipients {
    let key = recipient.lowercased()
    guard seen.insert(key).inserted else {
      throw CLIError(
        code: .validationError,
        message: "`--to` must not contain duplicate recipients.",
        details: ["recipient": recipient]
      )
    }
  }

  let service = try messageService(options.targetOption("service"))
  let text = try messageText(options)
  return recipients.map { MessageSendRequest(recipient: $0, service: service, text: text) }
}

func messageText(_ options: CLIOptions) throws -> String {
  let text = try requiredOption("text", options: options)
  let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmedText.isEmpty else {
    throw CLIError(code: .validationError, message: "`--text` must not be empty.")
  }
  guard Data(text.utf8).count <= 10_000 else {
    throw CLIError(code: .validationError, message: "`--text` must be 10000 bytes or less.")
  }
  return text
}

func normalizedRecipient(_ value: String) throws -> String {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard trimmed.count >= 3 else {
    throw CLIError(code: .validationError, message: "`--to` must contain at least 3 characters.")
  }
  guard trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil,
    trimmed.rangeOfCharacter(from: .controlCharacters) == nil
  else {
    throw CLIError(
      code: .validationError, message: "`--to` cannot contain whitespace or control characters.")
  }
  return trimmed
}

func messageService(_ value: String?) throws -> String {
  let service = value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "imessage"
  guard service == "imessage" else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Messages send currently supports only iMessage service.",
      details: ["service": service]
    )
  }
  return "iMessage"
}

func conversationSendService(_ identity: MessagesConversationIdentity) throws -> String {
  let serviceName = identity.record.serviceName?.trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
  let automationId = identity.automationId.trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
  guard serviceName == "imessage" || automationId.hasPrefix("imessage;") else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Messages conversation send currently supports only existing iMessage chats.",
      details: ["conversation": identity.record.id]
    )
  }
  return "iMessage"
}

func normalizedConversationAutomationId(_ value: String) throws -> String {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(
      code: .backendUnavailable, message: "Messages conversation automation id is empty.")
  }
  guard trimmed.rangeOfCharacter(from: .controlCharacters) == nil else {
    throw CLIError(
      code: .backendUnavailable, message: "Messages conversation automation id is invalid.")
  }
  return trimmed
}

func normalizedConversationParticipants(_ values: [String]) throws -> [String] {
  let participants =
    values
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
    .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

  guard !participants.isEmpty else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Messages conversation send requires a conversation with resolvable participants."
    )
  }
  guard participants.count <= 10 else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Messages conversation send is capped at 10 participants."
    )
  }

  var seen: Set<String> = []
  for participant in participants {
    guard participant.rangeOfCharacter(from: .controlCharacters) == nil else {
      throw CLIError(
        code: .backendUnavailable, message: "Messages conversation participant identity is invalid."
      )
    }
    guard seen.insert(participant.lowercased()).inserted else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Messages conversation participant identities are not unique.")
    }
  }
  return participants
}

func messageSendScopeDigest(_ request: MessageSendRequest) -> String {
  let payload = [
    request.recipient,
    request.service,
    sha256Hex(request.text),
  ].joined(separator: "|")
  return "messages-send:\(sha256Hex(payload))"
}

func messageConversationSendScopeDigest(_ request: MessageConversationSendRequest) -> String {
  let payload = [
    request.conversationId,
    request.automationId,
    request.service,
    participantIdentityHash(request.participantHandles),
    sha256Hex(request.text),
  ].joined(separator: "|")
  return "messages-send-conversation:\(sha256Hex(payload))"
}

func messageBatchSendScopeDigest(_ requests: [MessageSendRequest]) -> String {
  let payload = [
    requests.map(\.recipient).joined(separator: ","),
    requests[0].service,
    sha256Hex(requests[0].text),
  ].joined(separator: "|")
  return "messages-send-many:\(sha256Hex(payload))"
}

func messageSendSummary(_ request: MessageSendRequest) -> [String: String] {
  [
    "to": request.recipient,
    "service": request.service,
    "text_byte_count": "\(Data(request.text.utf8).count)",
    "text_sha256": sha256Hex(request.text),
  ]
}

func messageConversationSendSummary(_ request: MessageConversationSendRequest) -> [String: String] {
  [
    "conversation": request.conversationId,
    "participant_count": "\(request.participantHandles.count)",
    "participant_sha256": participantIdentityHash(request.participantHandles),
    "service": request.service,
    "text_byte_count": "\(Data(request.text.utf8).count)",
    "text_sha256": sha256Hex(request.text),
  ]
}

func messageBatchSendSummary(_ requests: [MessageSendRequest]) -> [String: String] {
  [
    "to": requests.map(\.recipient).joined(separator: ","),
    "recipient_count": "\(requests.count)",
    "service": requests[0].service,
    "text_byte_count": "\(Data(requests[0].text.utf8).count)",
    "text_sha256": sha256Hex(requests[0].text),
  ]
}

func participantIdentityHash(_ participants: [String]) -> String {
  sha256Hex(participants.map { $0.lowercased() }.joined(separator: "\n"))
}

func sqlStringLiteral(_ value: String) -> String {
  "'\(value.replacingOccurrences(of: "'", with: "''"))'"
}

func likePattern(_ query: String) -> String {
  let escaped =
    query
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "%", with: "\\%")
    .replacingOccurrences(of: "_", with: "\\_")
  return "%\(escaped)%"
}

func isPermissionDenied(_ output: String) -> Bool {
  let lowercased = output.lowercased()
  return lowercased.contains("authorization denied")
    || lowercased.contains("operation not permitted")
    || lowercased.contains("permission denied")
    || lowercased.contains("not authorized")
}

func truncated(_ value: String, limit: Int) -> String {
  if value.count <= limit {
    return value
  }
  return String(value.prefix(limit))
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func appleScriptString(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
}

func messagesAutomationError(_ errorInfo: NSDictionary) -> CLIError {
  let number = errorInfo[NSAppleScript.errorNumber] as? Int
  let code: CLIErrorCode
  switch number {
  case -1743:
    code = .permissionDenied
  case -1728:
    code = .notFound
  default:
    code = .backendUnavailable
  }
  return CLIError.appleEventFailure(
    target: "Messages", code: code, number: number)
}

func conversationsHumanOutput(_ conversations: [MessagesConversationRecord]) -> String {
  conversations.map { conversation in
    [conversation.id, conversation.displayName ?? "", conversation.serviceName ?? ""].joined(
      separator: "\t")
  }
  .joined(separator: "\n")
}

func messagesHumanOutput(_ messages: [MessagesMessageSummary]) -> String {
  messages.map { message in
    [message.id, message.conversationId, message.handle ?? "", message.textPreview ?? ""].joined(
      separator: "\t")
  }
  .joined(separator: "\n")
}

func messageHumanOutput(_ message: MessagesMessageDetail) -> String {
  [
    "id: \(message.id)",
    "conversation: \(message.conversationId)",
    "handle: \(message.handle ?? "")",
    "fromMe: \(message.isFromMe)",
    "text: \(message.text ?? "")",
  ].joined(separator: "\n")
}
