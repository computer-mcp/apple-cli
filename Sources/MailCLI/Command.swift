import CryptoKit
import Foundation
import Utility

public struct MailCommand: Sendable {
  private let backend: any MailReading & MailDrafting & MailSending & MailMessageMutating
  private let target = "mail"

  public init(
    backend: any MailReading & MailDrafting & MailSending & MailMessageMutating =
      MailAppleScriptBackend()
  ) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["accounts", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let accounts = try backend.listAccounts()
      return try result(
        MailAccountsResponse(accounts: accounts),
        human: accounts.map(\.name).joined(separator: "\n"),
        options: options
      )
    case ["mailboxes", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let mailboxes = try backend.listMailboxes(
        account: options.targetOption("account"), limit: try commandLimit(options))
      return try result(
        MailboxesResponse(mailboxes: mailboxes),
        human: mailboxes.map { "\($0.accountName)\t\($0.name)" }.joined(separator: "\n"),
        options: options
      )
    case ["mail", "list"]:
      let query = try messageQuery(
        options: options, unreadOnly: false, searchText: nil, searchScope: nil,
        allowedOptions: ["account", "mailbox"])
      let messages = try backend.listMessages(query)
      return try result(
        MailMessagesResponse(messages: messages),
        human: messages.map { "\($0.id)\t\($0.mailboxName)\t\($0.subject)" }.joined(
          separator: "\n"),
        options: options
      )
    case ["mail", "unread"]:
      let query = try messageQuery(
        options: options, unreadOnly: true, searchText: nil, searchScope: nil,
        allowedOptions: ["account", "mailbox"])
      let messages = try backend.listMessages(query)
      return try result(
        MailMessagesResponse(messages: messages),
        human: messages.map { "\($0.id)\t\($0.mailboxName)\t\($0.subject)" }.joined(
          separator: "\n"),
        options: options
      )
    case ["mail", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(
        options, allowedOptions: ["account", "mailbox", "query", "scope", "max-scan"])
      let scope = try searchScope(options)
      let searchText = try searchQuery(options, scope: scope)
      let query = try messageQuery(
        options: options,
        unreadOnly: false,
        searchText: searchText,
        searchScope: scope,
        maxScan: try searchMaxScan(options, scope: scope),
        allowedOptions: ["account", "mailbox", "query", "scope", "max-scan"]
      )
      let messages = try backend.listMessages(query)
      return try result(
        MailMessagesResponse(messages: messages),
        human: messages.map { "\($0.id)\t\($0.mailboxName)\t\($0.subject)" }.joined(
          separator: "\n"),
        options: options
      )
    case ["mail", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account", "mailbox", "id"])
      let mailbox = try requiredOption("mailbox", options: options)
      let id = try requiredOption("id", options: options)
      guard
        let message = try backend.readMessage(
          id: id, account: options.targetOption("account"), mailbox: mailbox)
      else {
        throw CLIError(code: .notFound, message: "Mail message was not found.", details: ["id": id])
      }
      return try result(
        MailMessageResponse(message: message),
        human: messageHumanOutput(message),
        options: options
      )
    case ["mail", "body-preview"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account", "mailbox", "id", "max-bytes"])
      let mailbox = try requiredOption("mailbox", options: options)
      let id = try requiredOption("id", options: options)
      let maxBytes = try bodyPreviewMaxBytes(options)
      guard
        let preview = try backend.previewMessageBody(
          id: id,
          account: options.targetOption("account"),
          mailbox: mailbox,
          maxBytes: maxBytes
        )
      else {
        throw CLIError(code: .notFound, message: "Mail message was not found.", details: ["id": id])
      }
      return try result(
        preview,
        human: bodyPreviewHumanOutput(preview),
        options: options
      )
    case ["mail", "reply-preview"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account", "mailbox", "id", "body"])
      let message = try messageForPreview(options)
      let body = options.targetOption("body") ?? ""
      let draft = MailDraftPreview(
        to: [message.sender],
        subject: replySubject(message.subject),
        bodyByteCount: body.utf8.count,
        bodySHA256: sha256Hex(body)
      )
      return try result(
        MailActionPreviewResponse(operation: "mail.reply-preview", source: message, draft: draft),
        human: mailPreviewHumanOutput(
          operation: "mail.reply-preview", source: message, draft: draft),
        options: options
      )
    case ["mail", "forward-preview"]:
      try validateReadOnly(options)
      try validateTargetOptions(
        options, allowedOptions: ["account", "mailbox", "id", "to", "cc", "bcc", "body"])
      let to = try recipientList("to", options: options, required: true)
      let cc = try recipientList("cc", options: options, required: false)
      let bcc = try recipientList("bcc", options: options, required: false)
      let message = try messageForPreview(options)
      let body = options.targetOption("body") ?? ""
      let draft = MailDraftPreview(
        to: to,
        cc: cc,
        bcc: bcc,
        subject: forwardSubject(message.subject),
        bodyByteCount: body.utf8.count,
        bodySHA256: sha256Hex(body)
      )
      return try result(
        MailActionPreviewResponse(operation: "mail.forward-preview", source: message, draft: draft),
        human: mailPreviewHumanOutput(
          operation: "mail.forward-preview", source: message, draft: draft),
        options: options
      )
    case ["mail", "reply-draft"]:
      try validateTargetOptions(
        options, allowedOptions: ["account", "mailbox", "id", "cc", "bcc", "body"])
      try validateMutationIntent(options)
      let cc = try recipientList("cc", options: options, required: false)
      let bcc = try recipientList("bcc", options: options, required: false)
      let message = try messageForPreview(options)
      let draft = MailDraftRequest(
        to: [message.sender],
        cc: cc,
        bcc: bcc,
        subject: replySubject(message.subject),
        body: options.targetOption("body") ?? ""
      )
      return try mutation(
        operation: "mail.reply-draft",
        scopeDigest: sourceDraftScopeDigest(operation: "mail.reply-draft", source: message, draft: draft),
        summary: sourceDraftSummary(source: message, draft: draft),
        options: options
      ) {
        let record = try backend.createDraft(draft)
        return MailMutationResult(
          operation: "mail.reply-draft", changed: true, draft: record, sent: nil)
      }
    case ["mail", "forward-draft"]:
      try validateTargetOptions(
        options, allowedOptions: ["account", "mailbox", "id", "to", "cc", "bcc", "body"])
      try validateMutationIntent(options)
      let to = try recipientList("to", options: options, required: true)
      let cc = try recipientList("cc", options: options, required: false)
      let bcc = try recipientList("bcc", options: options, required: false)
      let message = try messageForPreview(options)
      let draft = MailDraftRequest(
        to: to,
        cc: cc,
        bcc: bcc,
        subject: forwardSubject(message.subject),
        body: options.targetOption("body") ?? ""
      )
      return try mutation(
        operation: "mail.forward-draft",
        scopeDigest: sourceDraftScopeDigest(operation: "mail.forward-draft", source: message, draft: draft),
        summary: sourceDraftSummary(source: message, draft: draft),
        options: options
      ) {
        let record = try backend.createDraft(draft)
        return MailMutationResult(
          operation: "mail.forward-draft", changed: true, draft: record, sent: nil)
      }
    case ["mail", "draft"]:
      try validateTargetOptions(options, allowedOptions: ["to", "cc", "bcc", "subject", "body"])
      try validateMutationIntent(options)
      let draft = try draftRequest(options)
      return try mutation(
        operation: "mail.draft",
        scopeDigest: draftScopeDigest(draft),
        summary: draftSummary(draft),
        options: options
      ) {
        let record = try backend.createDraft(draft)
        return MailMutationResult(operation: "mail.draft", changed: true, draft: record, sent: nil)
      }
    case ["mail", "send"]:
      try validateTargetOptions(options, allowedOptions: ["to", "cc", "bcc", "subject", "body"])
      try validateMutationIntent(options)
      let draft = try draftRequest(options)
      return try mutation(
        operation: "mail.send",
        scopeDigest: sendScopeDigest(draft),
        summary: draftSummary(draft),
        options: options
      ) {
        let record = try backend.sendMail(draft)
        guard record.submitted else {
          throw CLIError(
            code: .backendUnavailable,
            message: "Mail rejected the send request. Inspect outgoing drafts before retrying.",
            details: ["submission_status": "rejected", "retry_guidance": "inspect_mail_before_retrying"]
          )
        }
        return MailMutationResult(operation: "mail.send", changed: true, draft: nil, sent: record)
      }
    case ["mail", "move"]:
      try validateTargetOptions(
        options, allowedOptions: ["account", "mailbox", "id", "destination-mailbox"])
      try validateMutationIntent(options)
      let message = try messageForPreview(options)
      let destination = try destinationMailbox(
        optionName: "destination-mailbox",
        source: message,
        options: options
      )
      return try mutation(
        operation: "mail.move",
        scopeDigest: mailboxActionScopeDigest(
          operation: "mail.move", source: message, destination: destination),
        summary: mailboxActionSummary(source: message, destination: destination),
        options: options
      ) {
        let record = try backend.moveMessage(message, destinationMailbox: destination.name)
        return MailMutationResult(operation: "mail.move", changed: true, message: record)
      }
    case ["mail", "archive"]:
      try validateTargetOptions(
        options, allowedOptions: ["account", "mailbox", "id", "archive-mailbox"])
      try validateMutationIntent(options)
      let message = try messageForPreview(options)
      let destination = try destinationMailbox(
        optionName: "archive-mailbox",
        source: message,
        options: options
      )
      return try mutation(
        operation: "mail.archive",
        scopeDigest: mailboxActionScopeDigest(
          operation: "mail.archive", source: message, destination: destination),
        summary: mailboxActionSummary(source: message, destination: destination),
        options: options
      ) {
        let record = try backend.archiveMessage(message, archiveMailbox: destination.name)
        return MailMutationResult(operation: "mail.archive", changed: true, message: record)
      }
    case ["mail", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["account", "mailbox", "id"])
      try validateMutationIntent(options)
      let message = try messageForPreview(options)
      return try mutation(
        operation: "mail.delete",
        scopeDigest: mailboxActionScopeDigest(operation: "mail.delete", source: message, destination: nil),
        summary: mailboxActionSummary(source: message, destination: nil),
        options: options
      ) {
        let record = try backend.deleteMessage(message)
        return MailMutationResult(operation: "mail.delete", changed: true, message: record)
      }
    default:
      return nil
    }
  }

  private func messageQuery(
    options: CLIOptions,
    unreadOnly: Bool,
    searchText: String?,
    searchScope: String?,
    maxScan: Int? = nil,
    allowedOptions: Set<String>
  ) throws -> MailMessageQuery {
    try validateReadOnly(options)
    try validateTargetOptions(options, allowedOptions: allowedOptions)
    return MailMessageQuery(
      account: options.targetOption("account"),
      mailbox: try requiredOption("mailbox", options: options),
      unreadOnly: unreadOnly,
      searchText: searchText,
      searchScope: searchScope,
      limit: try commandLimit(options),
      maxScan: maxScan
    )
  }

  private func messageForPreview(_ options: CLIOptions) throws -> MailMessageDetail {
    let mailbox = try requiredOption("mailbox", options: options)
    let id = try requiredOption("id", options: options)
    guard
      let message = try backend.readMessage(
        id: id, account: options.targetOption("account"), mailbox: mailbox)
    else {
      throw CLIError(code: .notFound, message: "Mail message was not found.", details: ["id": id])
    }
    return message
  }

  private func destinationMailbox(
    optionName: String,
    source: MailMessageDetail,
    options: CLIOptions
  ) throws -> MailboxRecord {
    let destinationName = try normalizedOption(optionName, options: options)
    guard destinationName != source.mailboxName else {
      throw CLIError(
        code: .validationError,
        message: "`--\(optionName)` must differ from the source mailbox."
      )
    }
    guard
      let destination = try backend.readMailbox(
        account: source.accountName, mailbox: destinationName)
    else {
      throw CLIError(
        code: .notFound,
        message: "Destination mailbox was not found.",
        details: ["account": source.accountName, "mailbox": destinationName]
      )
    }
    return destination
  }

  private func draftRequest(_ options: CLIOptions) throws -> MailDraftRequest {
    MailDraftRequest(
      to: try recipientList("to", options: options, required: true),
      cc: try recipientList("cc", options: options, required: false),
      bcc: try recipientList("bcc", options: options, required: false),
      subject: try normalizedOption("subject", options: options),
      body: options.targetOption("body") ?? ""
    )
  }

  private func mutation(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    commit: () throws -> MailMutationResult
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    if operation.contains(".send") {
      try CLISafety.requireFlag(
        "allow-external-dispatch",
        in: options,
        category: .externalDispatch,
        message: "\(operation) sends mail and requires `--allow-external-dispatch`."
      )
    }

    return try result(try commit(), human: "\(operation) executed", options: options)
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
