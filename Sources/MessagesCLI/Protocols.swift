import CryptoKit
import Foundation
import Utility

public protocol MessagesReading: Sendable {
  func listConversations(limit: Int) throws -> [MessagesConversationRecord]
  func searchConversations(query: String, limit: Int) throws -> [MessagesConversationRecord]
  func conversationIdentity(id: String) throws -> MessagesConversationIdentity?
  func listMessages(conversationId: String, limit: Int) throws -> [MessagesMessageSummary]
  func searchMessages(query: String, conversationId: String?, limit: Int) throws
    -> [MessagesMessageSummary]
  func readMessage(id: String) throws -> MessagesMessageDetail?
}

public protocol MessagesSending: Sendable {
  func sendMessage(_ request: MessageSendRequest) throws -> Bool
  func sendMessageToConversation(_ request: MessageConversationSendRequest) throws -> Bool
}

public protocol SQLiteCommandRunning: Sendable {
  func runSQLite(databasePath: String, sql: String) throws -> String
}
