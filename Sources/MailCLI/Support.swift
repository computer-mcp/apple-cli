import CryptoKit
import Foundation
import Utility

func messagePredicate(query: MailMessageQuery, messageId: String?) -> String {
  var predicates: [String] = []

  if let messageId {
    predicates.append("stableId is equal to \"\(appleScriptString(messageId))\"")
  }

  if query.unreadOnly {
    predicates.append("readValue is false")
  }

  if let searchText = query.searchText, let scope = query.searchScope {
    let escaped = appleScriptString(searchText)
    switch scope {
    case "subject":
      predicates.append("subjectText contains \"\(escaped)\"")
    case "sender":
      predicates.append("senderText contains \"\(escaped)\"")
    case "body":
      predicates.append("bodyText contains \"\(escaped)\"")
    default:
      predicates.append("false")
    }
  }

  return predicates.isEmpty ? "true" : predicates.joined(separator: " and ")
}

func runRows(_ source: String) throws -> [[String]] {
  var errorInfo: NSDictionary?
  guard let script = NSAppleScript(source: source) else {
    throw CLIError(code: .internalError, message: "Failed to compile Mail automation script.")
  }

  let descriptor = script.executeAndReturnError(&errorInfo)
  if let errorInfo {
    throw automationError(errorInfo)
  }

  return descriptor.rows()
}

func automationError(_ errorInfo: NSDictionary) -> CLIError {
  let number = errorInfo[NSAppleScript.errorNumber] as? Int
  let code: CLIErrorCode = number == -1743 ? .permissionDenied : .backendUnavailable
  return CLIError.appleEventFailure(
    target: "Mail", code: code, number: number)
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
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }

  return value
}

func normalizedOption(_ name: String, options: CLIOptions) throws -> String {
  let value = try requiredOption(name, options: options).trimmingCharacters(
    in: .whitespacesAndNewlines)
  guard !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }
  guard !value.contains("\n"), !value.contains("\r") else {
    throw CLIError(code: .validationError, message: "`--\(name)` must be a single line.")
  }
  return value
}

func recipientList(_ name: String, options: CLIOptions, required: Bool) throws -> [String] {
  guard let value = options.targetOption(name) else {
    if required {
      throw CLIError(code: .validationError, message: "`--\(name)` is required.")
    }
    return []
  }

  let recipients =
    value
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

  guard !recipients.isEmpty, recipients.allSatisfy({ !$0.isEmpty }) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` must contain comma-separated non-empty recipients.")
  }
  guard recipients.allSatisfy({ !$0.contains("\n") && !$0.contains("\r") }) else {
    throw CLIError(
      code: .validationError, message: "`--\(name)` recipients must be single-line values.")
  }
  return recipients
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 500 for Mail read commands.")
  }
  return limit
}

func bodyPreviewMaxBytes(_ options: CLIOptions) throws -> Int {
  guard let rawValue = options.targetOption("max-bytes") else {
    return 20_000
  }
  guard let value = Int(rawValue), value > 0 else {
    throw CLIError(code: .validationError, message: "`--max-bytes` must be a positive integer.")
  }
  guard value <= 100_000 else {
    throw CLIError(
      code: .validationError, message: "`--max-bytes` cannot exceed 100000 for Mail body preview.")
  }
  return value
}

func searchScope(_ options: CLIOptions) throws -> String {
  let scope = options.targetOption("scope") ?? "subject"
  guard ["subject", "sender", "body"].contains(scope) else {
    throw CLIError(
      code: .unsupportedOperation,
      message: "Mail search scope is not supported by the live backend.",
      details: ["scope": scope, "supported_scopes": "subject,sender,body"]
    )
  }
  return scope
}

func searchQuery(_ options: CLIOptions, scope: String) throws -> String {
  let value = try normalizedOption("query", options: options)
  if scope == "body", value.count < 3 {
    throw CLIError(
      code: .validationError,
      message: "`--query` must contain at least 3 characters for Mail body search."
    )
  }
  return value
}

func searchMaxScan(_ options: CLIOptions, scope: String) throws -> Int? {
  guard let rawValue = options.targetOption("max-scan") else {
    return scope == "body" ? 500 : nil
  }
  guard let value = Int(rawValue), value > 0 else {
    throw CLIError(code: .validationError, message: "`--max-scan` must be a positive integer.")
  }
  guard value <= 5_000 else {
    throw CLIError(
      code: .validationError, message: "`--max-scan` cannot exceed 5000 for Mail search.")
  }
  return value
}

func draftScopeDigest(_ draft: MailDraftRequest) -> String {
  let fields = [
    draft.to.joined(separator: ","),
    draft.cc.joined(separator: ","),
    draft.bcc.joined(separator: ","),
    draft.subject,
    sha256Hex(draft.body),
  ]
  return "mail-draft:\(sha256Hex(fields.joined(separator: "|")))"
}

func sendScopeDigest(_ draft: MailDraftRequest) -> String {
  let fields = [
    draft.to.joined(separator: ","),
    draft.cc.joined(separator: ","),
    draft.bcc.joined(separator: ","),
    draft.subject,
    sha256Hex(draft.body),
  ]
  return "mail-send:\(sha256Hex(fields.joined(separator: "|")))"
}

func sourceDraftScopeDigest(operation: String, source: MailMessageDetail, draft: MailDraftRequest)
  -> String
{
  let fields = [
    messageIdentityScopeDigest(source),
    draftScopeDigest(draft),
  ]
  return "\(operation):\(sha256Hex(fields.joined(separator: "|")))"
}

func mailboxActionScopeDigest(
  operation: String,
  source: MailMessageDetail,
  destination: MailboxRecord?
) -> String {
  let fields = [
    messageIdentityScopeDigest(source),
    destination?.accountName ?? "",
    destination?.name ?? "",
  ]
  return "\(operation):\(sha256Hex(fields.joined(separator: "|")))"
}

func messageIdentityScopeDigest(_ message: MailMessageDetail) -> String {
  let fields = [
    message.id,
    message.accountName,
    message.mailboxName,
    message.subject,
    message.sender,
    message.recipients.joined(separator: ","),
    message.receivedAt.map { ISO8601DateFormatter().string(from: $0) } ?? "",
    "\(message.isRead)",
  ]
  return "mail-message:\(sha256Hex(fields.joined(separator: "|")))"
}

func messageMutationRecord(
  _ message: MailMessageDetail,
  destinationMailbox: String?
) -> MailMessageMutationRecord {
  MailMessageMutationRecord(
    id: message.id,
    accountName: message.accountName,
    sourceMailboxName: message.mailboxName,
    destinationMailboxName: destinationMailbox,
    subject: message.subject,
    sender: message.sender
  )
}

func draftSummary(_ draft: MailDraftRequest) -> [String: String] {
  [
    "to": draft.to.joined(separator: ","),
    "cc": draft.cc.joined(separator: ","),
    "bcc": draft.bcc.joined(separator: ","),
    "subject": draft.subject,
    "body_sha256": sha256Hex(draft.body),
  ]
}

func sourceDraftSummary(source: MailMessageDetail, draft: MailDraftRequest) -> [String: String] {
  var summary = draftSummary(draft)
  summary["source_id"] = source.id
  summary["source_account"] = source.accountName
  summary["source_mailbox"] = source.mailboxName
  summary["source_subject"] = source.subject
  summary["source_sender"] = source.sender
  return summary
}

func mailboxActionSummary(
  source: MailMessageDetail,
  destination: MailboxRecord?
) -> [String: String] {
  var summary = [
    "source_id": source.id,
    "source_account": source.accountName,
    "source_mailbox": source.mailboxName,
    "source_subject": source.subject,
    "source_sender": source.sender,
  ]
  if let destination {
    summary["destination_account"] = destination.accountName
    summary["destination_mailbox"] = destination.name
  }
  return summary
}

func replySubject(_ subject: String) -> String {
  subject.hasPrefixIgnoringCase("re:") ? subject : "Re: \(subject)"
}

func forwardSubject(_ subject: String) -> String {
  subject.hasPrefixIgnoringCase("fwd:") || subject.hasPrefixIgnoringCase("fw:")
    ? subject : "Fwd: \(subject)"
}

func sha256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func messageSummary(_ row: [String]) -> MailMessageSummary {
  MailMessageSummary(
    id: row[safe: 0] ?? "",
    accountName: row[safe: 1] ?? "",
    mailboxName: row[safe: 2] ?? "",
    subject: row[safe: 3] ?? "",
    sender: row[safe: 4] ?? "",
    receivedAt: parseAppleScriptDate(row[safe: 5]),
    isRead: (row[safe: 6] ?? "false") == "true"
  )
}

func messageDetail(_ row: [String]) -> MailMessageDetail {
  MailMessageDetail(
    id: row[safe: 0] ?? "",
    accountName: row[safe: 1] ?? "",
    mailboxName: row[safe: 2] ?? "",
    subject: row[safe: 3] ?? "",
    sender: row[safe: 4] ?? "",
    receivedAt: parseAppleScriptDate(row[safe: 5]),
    isRead: (row[safe: 6] ?? "false") == "true",
    bodyIncluded: false
  )
}

func mailBodyPreview(_ row: [String], maxBytes: Int) -> MailBodyPreviewResponse {
  var message = MailMessageDetail(
    id: row[safe: 0] ?? "",
    accountName: row[safe: 1] ?? "",
    mailboxName: row[safe: 2] ?? "",
    subject: row[safe: 3] ?? "",
    sender: row[safe: 4] ?? "",
    receivedAt: parseAppleScriptDate(row[safe: 5]),
    isRead: (row[safe: 6] ?? "false") == "true",
    bodyIncluded: true
  )
  message.recipients = []
  let sourceBody = row[safe: 7] ?? ""
  var body = ""
  var byteCount = 0
  for character in sourceBody {
    let characterBytes = character.utf8.count
    guard characterBytes <= maxBytes - byteCount else { break }
    body.append(character)
    byteCount += characterBytes
  }
  return MailBodyPreviewResponse(
    message: message,
    body: body,
    truncated: (row[safe: 8] ?? "false") == "true" || body != sourceBody
  )
}

func messageHumanOutput(_ message: MailMessageDetail) -> String {
  [
    "id: \(message.id)",
    "subject: \(message.subject)",
    "sender: \(message.sender)",
    "mailbox: \(message.mailboxName)",
    "bodyIncluded: \(message.bodyIncluded)",
  ].joined(separator: "\n")
}

func bodyPreviewHumanOutput(_ preview: MailBodyPreviewResponse) -> String {
  [
    "id: \(preview.message.id)",
    "subject: \(preview.message.subject)",
    "sender: \(preview.message.sender)",
    "mailbox: \(preview.message.mailboxName)",
    "truncated: \(preview.truncated)",
    preview.body,
  ].joined(separator: "\n")
}

func mailPreviewHumanOutput(operation: String, source: MailMessageDetail, draft: MailDraftPreview)
  -> String
{
  [
    "operation: \(operation)",
    "source: \(source.id)",
    "to: \(draft.to.joined(separator: ","))",
    "subject: \(draft.subject)",
    "bodyIncluded: \(draft.bodyIncluded)",
  ].joined(separator: "\n")
}

func appleScriptEqualsOrTrue(_ variable: String, selector: String?) -> String {
  guard let selector, !selector.isEmpty else {
    return "true"
  }
  return "\(variable) is equal to \"\(appleScriptString(selector))\""
}

extension String {
  func hasPrefixIgnoringCase(_ prefix: String) -> Bool {
    range(of: prefix, options: [.anchored, .caseInsensitive]) != nil
  }
}

func recipientStatements(_ draft: MailDraftRequest) -> String {
  [
    recipientStatements("to recipient", collection: "to recipients", addresses: draft.to),
    recipientStatements("cc recipient", collection: "cc recipients", addresses: draft.cc),
    recipientStatements("bcc recipient", collection: "bcc recipients", addresses: draft.bcc),
  ]
  .filter { !$0.isEmpty }
  .joined(separator: "\n          ")
}

func recipientStatements(_ recipientClass: String, collection: String, addresses: [String])
  -> String
{
  addresses.map { address in
    "make new \(recipientClass) at end of \(collection) of newMessage with properties {address:\"\(appleScriptString(address))\"}"
  }
  .joined(separator: "\n          ")
}

func appleScriptString(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
}

func parseAppleScriptDate(_ value: String?) -> Date? {
  guard let value else {
    return nil
  }

  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm:ss a"
  return formatter.date(from: value)
}

extension NSAppleEventDescriptor {
  func rows() -> [[String]] {
    guard numberOfItems > 0 else {
      return []
    }

    return (1...numberOfItems).map { index in
      guard let row = atIndex(index) else {
        return []
      }
      return row.strings()
    }
  }

  func strings() -> [String] {
    guard numberOfItems > 0 else {
      return [stringValue ?? ""]
    }

    return (1...numberOfItems).map { index in
      atIndex(index)?.stringValue ?? ""
    }
  }
}

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
