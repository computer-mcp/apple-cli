import CryptoKit
import Foundation
import Utility

public protocol MailReading: Sendable {
  func listAccounts() throws -> [MailAccountRecord]
  func listMailboxes(account: String?, limit: Int) throws -> [MailboxRecord]
  func readMailbox(account: String?, mailbox: String) throws -> MailboxRecord?
  func listMessages(_ query: MailMessageQuery) throws -> [MailMessageSummary]
  func readMessage(id: String, account: String?, mailbox: String) throws -> MailMessageDetail?
  func previewMessageBody(id: String, account: String?, mailbox: String, maxBytes: Int) throws
    -> MailBodyPreviewResponse?
}

public protocol MailDrafting: Sendable {
  func createDraft(_ draft: MailDraftRequest) throws -> MailDraftRecord
}

public protocol MailSending: Sendable {
  func sendMail(_ draft: MailDraftRequest) throws -> MailSendRecord
}

public protocol MailMessageMutating: Sendable {
  func moveMessage(_ message: MailMessageDetail, destinationMailbox: String) throws
    -> MailMessageMutationRecord
  func archiveMessage(_ message: MailMessageDetail, archiveMailbox: String) throws
    -> MailMessageMutationRecord
  func deleteMessage(_ message: MailMessageDetail) throws -> MailMessageMutationRecord
}
