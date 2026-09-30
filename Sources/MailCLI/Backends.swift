import CryptoKit
import Foundation
import Utility

public struct MailActionPreviewResponse: Codable, Equatable, Sendable {
  public var operation: String
  public var source: MailMessageDetail
  public var draft: MailDraftPreview
}

public struct MailAppleScriptBackend: MailReading, MailDrafting, MailSending, MailMessageMutating {
  public init() {}

  public func listAccounts() throws -> [MailAccountRecord] {
    try runRows(
      """
      set output to {}
      tell application "Mail"
        repeat with eachAccount in accounts
          set end of output to {name of eachAccount as text}
        end repeat
      end tell
      return output
      """
    ).map { MailAccountRecord(name: $0[safe: 0] ?? "") }
  }

  public func listMailboxes(account: String?, limit: Int) throws -> [MailboxRecord] {
    try runRows(
      """
      set output to {}
      tell application "Mail"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          if \(appleScriptEqualsOrTrue("accountName", selector: account)) then
            repeat with eachMailbox in mailboxes of eachAccount
              if (count of output) is greater than or equal to \(limit) then return output
              set end of output to {accountName, name of eachMailbox as text}
            end repeat
          end if
        end repeat
      end tell
      return output
      """
    ).map { MailboxRecord(accountName: $0[safe: 0] ?? "", name: $0[safe: 1] ?? "") }
  }

  public func readMailbox(account: String?, mailbox: String) throws -> MailboxRecord? {
    try runRows(
      """
      set output to {}
      tell application "Mail"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          if \(appleScriptEqualsOrTrue("accountName", selector: account)) then
            repeat with eachMailbox in mailboxes of eachAccount
              set mailboxName to name of eachMailbox as text
              if mailboxName is equal to "\(appleScriptString(mailbox))" then
                set end of output to {accountName, mailboxName}
                return output
              end if
            end repeat
          end if
        end repeat
      end tell
      return output
      """
    ).first.map { MailboxRecord(accountName: $0[safe: 0] ?? "", name: $0[safe: 1] ?? "") }
  }

  public func listMessages(_ query: MailMessageQuery) throws -> [MailMessageSummary] {
    try messageRows(query: query, messageId: nil, limit: query.limit).map(messageSummary)
  }

  public func readMessage(id: String, account: String?, mailbox: String) throws
    -> MailMessageDetail?
  {
    let query = MailMessageQuery(account: account, mailbox: mailbox, limit: 1)
    return try messageRows(query: query, messageId: id, limit: 1).first.map(messageDetail)
  }

  public func previewMessageBody(
    id: String,
    account: String?,
    mailbox: String,
    maxBytes: Int
  ) throws -> MailBodyPreviewResponse? {
    let rows = try runRows(
      """
      set output to {}
      tell application "Mail"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          if \(appleScriptEqualsOrTrue("accountName", selector: account)) then
            repeat with eachMailbox in mailboxes of eachAccount
              set mailboxName to name of eachMailbox as text
              if mailboxName is equal to "\(appleScriptString(mailbox))" then
                repeat with eachMessage in messages of eachMailbox
                  set stableId to |message id| of eachMessage as text
                  if stableId is equal to "\(appleScriptString(id))" then
                    set subjectValue to subject of eachMessage as text
                    set senderValue to sender of eachMessage as text
                    set receivedValue to |date received| of eachMessage
                    set readValue to |read status| of eachMessage
                    set readFlagValue to "false"
                    if readValue then set readFlagValue to "true"
                    set bodyValue to content of eachMessage as text
                    set truncatedFlagValue to "false"
                    if (count characters of bodyValue) is greater than \(maxBytes) then
                      set bodyValue to text 1 thru \(maxBytes) of bodyValue
                      set truncatedFlagValue to "true"
                    end if
                    set end of output to {stableId, accountName, mailboxName, subjectValue, senderValue, receivedValue, readFlagValue, bodyValue, truncatedFlagValue}
                    return output
                  end if
                end repeat
              end if
            end repeat
          end if
        end repeat
      end tell
      return output
      """)

    return rows.first.map(mailBodyPreview)
  }

  public func createDraft(_ draft: MailDraftRequest) throws -> MailDraftRecord {
    let rows = try runRows(
      """
      set output to {}
      tell application "Mail"
        set newMessage to make new outgoing message with properties {subject:"\(appleScriptString(draft.subject))", content:"\(appleScriptString(draft.body))", visible:false}
        \(recipientStatements(draft))
        set draftId to ""
        try
          set draftId to id of newMessage as text
        end try
        save newMessage
        set end of output to {draftId, subject of newMessage as text}
      end tell
      return output
      """)

    let row = rows.first ?? []
    return MailDraftRecord(
      id: row[safe: 0]?.isEmpty == false ? row[safe: 0] : nil,
      to: draft.to,
      cc: draft.cc,
      bcc: draft.bcc,
      subject: row[safe: 1] ?? draft.subject,
      bodyIncluded: false
    )
  }

  public func sendMail(_ draft: MailDraftRequest) throws -> MailSendRecord {
    _ = try runRows(
      """
      set output to {}
      tell application "Mail"
        set newMessage to make new outgoing message with properties {subject:"\(appleScriptString(draft.subject))", content:"\(appleScriptString(draft.body))", visible:false}
        \(recipientStatements(draft))
        send newMessage
        set end of output to {subject of newMessage as text}
      end tell
      return output
      """)

    return MailSendRecord(
      to: draft.to,
      cc: draft.cc,
      bcc: draft.bcc,
      subject: draft.subject,
      bodyIncluded: false
    )
  }

  public func moveMessage(
    _ message: MailMessageDetail,
    destinationMailbox: String
  ) throws -> MailMessageMutationRecord {
    try runMessageMailboxScript(
      message: message, destinationMailbox: destinationMailbox, action: "move")
    return messageMutationRecord(message, destinationMailbox: destinationMailbox)
  }

  public func archiveMessage(
    _ message: MailMessageDetail,
    archiveMailbox: String
  ) throws -> MailMessageMutationRecord {
    try runMessageMailboxScript(
      message: message, destinationMailbox: archiveMailbox, action: "move")
    return messageMutationRecord(message, destinationMailbox: archiveMailbox)
  }

  public func deleteMessage(_ message: MailMessageDetail) throws -> MailMessageMutationRecord {
    try runMessageMailboxScript(message: message, destinationMailbox: nil, action: "delete")
    return messageMutationRecord(message, destinationMailbox: nil)
  }

  private func messageRows(query: MailMessageQuery, messageId: String?, limit: Int) throws
    -> [[String]]
  {
    let scanGuard =
      query.maxScan.map {
        """
                if scannedCount is greater than or equal to \($0) then return output
                set scannedCount to scannedCount + 1
        """
      } ?? "set scannedCount to scannedCount + 1"
    let bodyTextSetup =
      query.searchScope == "body"
      ? "set bodyText to content of eachMessage as text"
      : "set bodyText to \"\""

    return try runRows(
      """
      set output to {}
      set scannedCount to 0
      tell application "Mail"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          if \(appleScriptEqualsOrTrue("accountName", selector: query.account)) then
            repeat with eachMailbox in mailboxes of eachAccount
              set mailboxName to name of eachMailbox as text
              if mailboxName is equal to "\(appleScriptString(query.mailbox))" then
                repeat with eachMessage in messages of eachMailbox
                  if (count of output) is greater than or equal to \(limit) then return output
      \(scanGuard)
                  set stableId to |message id| of eachMessage as text
                  set subjectText to subject of eachMessage as text
                  set senderText to sender of eachMessage as text
                  set receivedValue to |date received| of eachMessage
                  set readValue to |read status| of eachMessage
                  set readFlagValue to "false"
                  if readValue then set readFlagValue to "true"
                  \(bodyTextSetup)
                  if \(messagePredicate(query: query, messageId: messageId)) then
                    set end of output to {stableId, accountName, mailboxName, subjectText, senderText, receivedValue, readFlagValue, ""}
                  end if
                end repeat
              end if
            end repeat
          end if
        end repeat
      end tell
      return output
      """)
  }

  private func runMessageMailboxScript(
    message: MailMessageDetail,
    destinationMailbox: String?,
    action: String
  ) throws {
    let destinationSetup: String
    let actionStatement: String
    if let destinationMailbox {
      destinationSetup = """
          set destinationMailboxRef to missing value
          repeat with candidateMailbox in mailboxes of eachAccount
            if (name of candidateMailbox as text) is equal to "\(appleScriptString(destinationMailbox))" then
              set destinationMailboxRef to candidateMailbox
              exit repeat
            end if
          end repeat
          if destinationMailboxRef is missing value then return output
        """
      actionStatement = "move eachMessage to destinationMailboxRef"
    } else {
      destinationSetup = ""
      actionStatement = "delete eachMessage"
    }

    let rows = try runRows(
      """
      set output to {}
      tell application "Mail"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          if accountName is equal to "\(appleScriptString(message.accountName))" then
      \(destinationSetup)
            repeat with eachMailbox in mailboxes of eachAccount
              set mailboxName to name of eachMailbox as text
              if mailboxName is equal to "\(appleScriptString(message.mailboxName))" then
                repeat with eachMessage in messages of eachMailbox
                  set stableId to message id of eachMessage as text
                  if stableId is equal to "\(appleScriptString(message.id))" then
                    set end of output to {stableId}
                    \(actionStatement)
                    return output
                  end if
                end repeat
              end if
            end repeat
          end if
        end repeat
      end tell
      return output
      """)

    guard rows.first?[safe: 0] == message.id else {
      throw CLIError(
        code: .notFound, message: "Mail message was not found.", details: ["id": message.id])
    }
  }
}
