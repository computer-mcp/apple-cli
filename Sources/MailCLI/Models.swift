import CryptoKit
import Foundation
import Utility

public struct MailAccountRecord: Codable, Equatable, Sendable {
  public var name: String

  public init(name: String) {
    self.name = name
  }
}

public struct MailboxRecord: Codable, Equatable, Sendable {
  public var accountName: String
  public var name: String

  public init(accountName: String, name: String) {
    self.accountName = accountName
    self.name = name
  }
}

public struct MailMessageQuery: Equatable, Sendable {
  public var account: String?
  public var mailbox: String
  public var unreadOnly: Bool
  public var searchText: String?
  public var searchScope: String?
  public var limit: Int
  public var maxScan: Int?

  public init(
    account: String? = nil,
    mailbox: String,
    unreadOnly: Bool = false,
    searchText: String? = nil,
    searchScope: String? = nil,
    limit: Int,
    maxScan: Int? = nil
  ) {
    self.account = account
    self.mailbox = mailbox
    self.unreadOnly = unreadOnly
    self.searchText = searchText
    self.searchScope = searchScope
    self.limit = limit
    self.maxScan = maxScan
  }
}

public struct MailMessageSummary: Codable, Equatable, Sendable {
  public var id: String
  public var accountName: String
  public var mailboxName: String
  public var subject: String
  public var sender: String
  public var receivedAt: Date?
  public var isRead: Bool

  public init(
    id: String,
    accountName: String,
    mailboxName: String,
    subject: String,
    sender: String,
    receivedAt: Date? = nil,
    isRead: Bool
  ) {
    self.id = id
    self.accountName = accountName
    self.mailboxName = mailboxName
    self.subject = subject
    self.sender = sender
    self.receivedAt = receivedAt
    self.isRead = isRead
  }
}

public struct MailMessageDetail: Codable, Equatable, Sendable {
  public var id: String
  public var accountName: String
  public var mailboxName: String
  public var subject: String
  public var sender: String
  public var recipients: [String]
  public var receivedAt: Date?
  public var isRead: Bool
  public var bodyIncluded: Bool

  public init(
    id: String,
    accountName: String,
    mailboxName: String,
    subject: String,
    sender: String,
    recipients: [String] = [],
    receivedAt: Date? = nil,
    isRead: Bool,
    bodyIncluded: Bool = false
  ) {
    self.id = id
    self.accountName = accountName
    self.mailboxName = mailboxName
    self.subject = subject
    self.sender = sender
    self.recipients = recipients
    self.receivedAt = receivedAt
    self.isRead = isRead
    self.bodyIncluded = bodyIncluded
  }
}

public struct MailAccountsResponse: Codable, Equatable, Sendable {
  public var accounts: [MailAccountRecord]
}

public struct MailboxesResponse: Codable, Equatable, Sendable {
  public var mailboxes: [MailboxRecord]
}

public struct MailMessagesResponse: Codable, Equatable, Sendable {
  public var messages: [MailMessageSummary]
}

public struct MailMessageResponse: Codable, Equatable, Sendable {
  public var message: MailMessageDetail
}

public struct MailBodyPreviewResponse: Codable, Equatable, Sendable {
  public var message: MailMessageDetail
  public var body: String
  public var bodyIncluded: Bool
  public var bodyByteCount: Int
  public var bodySHA256: String
  public var truncated: Bool

  public init(message: MailMessageDetail, body: String, truncated: Bool) {
    self.message = message
    self.body = body
    self.bodyIncluded = true
    self.bodyByteCount = body.utf8.count
    self.bodySHA256 = sha256Hex(body)
    self.truncated = truncated
  }
}

public struct MailDraftPreview: Codable, Equatable, Sendable {
  public var to: [String]
  public var cc: [String]
  public var bcc: [String]
  public var subject: String
  public var bodyIncluded: Bool
  public var bodyByteCount: Int
  public var bodySHA256: String

  public init(
    to: [String],
    cc: [String] = [],
    bcc: [String] = [],
    subject: String,
    bodyIncluded: Bool = false,
    bodyByteCount: Int,
    bodySHA256: String
  ) {
    self.to = to
    self.cc = cc
    self.bcc = bcc
    self.subject = subject
    self.bodyIncluded = bodyIncluded
    self.bodyByteCount = bodyByteCount
    self.bodySHA256 = bodySHA256
  }
}

public struct MailDraftRequest: Codable, Equatable, Sendable {
  public var to: [String]
  public var cc: [String]
  public var bcc: [String]
  public var subject: String
  public var body: String

  public init(
    to: [String],
    cc: [String] = [],
    bcc: [String] = [],
    subject: String,
    body: String = ""
  ) {
    self.to = to
    self.cc = cc
    self.bcc = bcc
    self.subject = subject
    self.body = body
  }
}

public struct MailDraftRecord: Codable, Equatable, Sendable {
  public var id: String?
  public var to: [String]
  public var cc: [String]
  public var bcc: [String]
  public var subject: String
  public var bodyIncluded: Bool

  public init(
    id: String? = nil,
    to: [String],
    cc: [String] = [],
    bcc: [String] = [],
    subject: String,
    bodyIncluded: Bool = false
  ) {
    self.id = id
    self.to = to
    self.cc = cc
    self.bcc = bcc
    self.subject = subject
    self.bodyIncluded = bodyIncluded
  }
}

public struct MailSendRecord: Codable, Equatable, Sendable {
  public var to: [String]
  public var cc: [String]
  public var bcc: [String]
  public var subject: String
  public var bodyIncluded: Bool

  public init(
    to: [String],
    cc: [String] = [],
    bcc: [String] = [],
    subject: String,
    bodyIncluded: Bool = false
  ) {
    self.to = to
    self.cc = cc
    self.bcc = bcc
    self.subject = subject
    self.bodyIncluded = bodyIncluded
  }
}

public struct MailMessageMutationRecord: Codable, Equatable, Sendable {
  public var id: String
  public var accountName: String
  public var sourceMailboxName: String
  public var destinationMailboxName: String?
  public var subject: String
  public var sender: String

  public init(
    id: String,
    accountName: String,
    sourceMailboxName: String,
    destinationMailboxName: String? = nil,
    subject: String,
    sender: String
  ) {
    self.id = id
    self.accountName = accountName
    self.sourceMailboxName = sourceMailboxName
    self.destinationMailboxName = destinationMailboxName
    self.subject = subject
    self.sender = sender
  }
}


public struct MailMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var draft: MailDraftRecord?
  public var sent: MailSendRecord?
  public var message: MailMessageMutationRecord?

  public init(
    operation: String,
    changed: Bool,
    draft: MailDraftRecord? = nil,
    sent: MailSendRecord? = nil,
    message: MailMessageMutationRecord? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.draft = draft
    self.sent = sent
    self.message = message
  }
}
