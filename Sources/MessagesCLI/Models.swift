import CryptoKit
import Foundation
import Utility

public struct MessagesConversationRecord: Codable, Equatable, Sendable {
  public var id: String
  public var displayName: String?
  public var serviceName: String?
  public var participantHandles: [String]
  public var lastMessageAt: Date?
  public var messageCount: Int

  public init(
    id: String,
    displayName: String? = nil,
    serviceName: String? = nil,
    participantHandles: [String] = [],
    lastMessageAt: Date? = nil,
    messageCount: Int = 0
  ) {
    self.id = id
    self.displayName = displayName
    self.serviceName = serviceName
    self.participantHandles = participantHandles
    self.lastMessageAt = lastMessageAt
    self.messageCount = messageCount
  }
}

public struct MessagesConversationIdentity: Equatable, Sendable {
  public var record: MessagesConversationRecord
  public var automationId: String

  public init(record: MessagesConversationRecord, automationId: String) {
    self.record = record
    self.automationId = automationId
  }
}

public struct MessagesMessageSummary: Codable, Equatable, Sendable {
  public var id: String
  public var conversationId: String
  public var handle: String?
  public var serviceName: String?
  public var textPreview: String?
  public var sentAt: Date?
  public var isFromMe: Bool

  public init(
    id: String,
    conversationId: String,
    handle: String? = nil,
    serviceName: String? = nil,
    textPreview: String? = nil,
    sentAt: Date? = nil,
    isFromMe: Bool
  ) {
    self.id = id
    self.conversationId = conversationId
    self.handle = handle
    self.serviceName = serviceName
    self.textPreview = textPreview
    self.sentAt = sentAt
    self.isFromMe = isFromMe
  }
}

public struct MessagesMessageDetail: Codable, Equatable, Sendable {
  public var id: String
  public var conversationId: String
  public var handle: String?
  public var serviceName: String?
  public var text: String?
  public var sentAt: Date?
  public var isFromMe: Bool

  public init(
    id: String,
    conversationId: String,
    handle: String? = nil,
    serviceName: String? = nil,
    text: String? = nil,
    sentAt: Date? = nil,
    isFromMe: Bool
  ) {
    self.id = id
    self.conversationId = conversationId
    self.handle = handle
    self.serviceName = serviceName
    self.text = text
    self.sentAt = sentAt
    self.isFromMe = isFromMe
  }
}

public struct MessagesConversationsResponse: Codable, Equatable, Sendable {
  public var conversations: [MessagesConversationRecord]
}

public struct MessagesMessagesResponse: Codable, Equatable, Sendable {
  public var messages: [MessagesMessageSummary]
}

public struct MessagesMessageResponse: Codable, Equatable, Sendable {
  public var message: MessagesMessageDetail
}

public struct MessageSendRequest: Codable, Equatable, Sendable {
  public var recipient: String
  public var service: String
  public var text: String

  public init(recipient: String, service: String = "iMessage", text: String) {
    self.recipient = recipient
    self.service = service
    self.text = text
  }
}


public struct MessageSendResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var recipient: String
  public var service: String
  public var textIncluded: Bool
}

public struct MessageConversationSendRequest: Codable, Equatable, Sendable {
  public var conversationId: String
  public var automationId: String
  public var service: String
  public var participantHandles: [String]
  public var text: String

  public init(
    conversationId: String,
    automationId: String,
    service: String,
    participantHandles: [String],
    text: String
  ) {
    self.conversationId = conversationId
    self.automationId = automationId
    self.service = service
    self.participantHandles = participantHandles
    self.text = text
  }
}

public struct MessageConversationSendResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var conversationId: String
  public var participantCount: Int
  public var service: String
  public var textIncluded: Bool
}

public struct MessageBatchSendRecipientResult: Codable, Equatable, Sendable {
  public var recipient: String
  public var service: String
  public var submitted: Bool
  public var errorCode: String?
  public var errorMessage: String?

  public init(
    recipient: String,
    service: String,
    submitted: Bool,
    errorCode: String? = nil,
    errorMessage: String? = nil
  ) {
    self.recipient = recipient
    self.service = service
    self.submitted = submitted
    self.errorCode = errorCode
    self.errorMessage = errorMessage
  }
}

public struct MessageBatchSendResult: Codable, Equatable, Sendable {
  public var operation: String
  public var requestedCount: Int
  public var submittedCount: Int
  public var failedCount: Int
  public var recipients: [MessageBatchSendRecipientResult]
  public var service: String
  public var textIncluded: Bool

  public init(operation: String, recipients: [MessageBatchSendRecipientResult], service: String) {
    self.operation = operation
    self.requestedCount = recipients.count
    self.submittedCount = recipients.filter(\.submitted).count
    self.failedCount = recipients.filter { !$0.submitted }.count
    self.recipients = recipients
    self.service = service
    self.textIncluded = false
  }
}
