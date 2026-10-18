import CryptoKit
import Foundation
import Utility

public struct MessagesAppleScriptSender: MessagesSending {
  public init() {}

  public func sendMessage(_ request: MessageSendRequest) throws -> Bool {
    let script = """
      tell application "Messages"
        set targetService to first service whose service type = iMessage
        set targetBuddy to buddy "\(appleScriptString(request.recipient))" of targetService
        send "\(appleScriptString(request.text))" to targetBuddy
      end tell
      return "submitted"
      """

    var errorInfo: NSDictionary?
    guard let appleScript = NSAppleScript(source: script) else {
      throw CLIError(code: .internalError, message: "Failed to compile Messages send script.")
    }

    _ = appleScript.executeAndReturnError(&errorInfo)
    if let errorInfo {
      throw messagesAutomationError(errorInfo)
    }
    return true
  }

  public func sendMessageToConversation(_ request: MessageConversationSendRequest) throws -> Bool {
    let script = """
      tell application "Messages"
        set targetChat to first chat whose id = "\(appleScriptString(request.automationId))"
        send "\(appleScriptString(request.text))" to targetChat
      end tell
      return "submitted"
      """

    var errorInfo: NSDictionary?
    guard let appleScript = NSAppleScript(source: script) else {
      throw CLIError(
        code: .internalError, message: "Failed to compile Messages conversation send script.")
    }

    _ = appleScript.executeAndReturnError(&errorInfo)
    if let errorInfo {
      throw messagesAutomationError(errorInfo)
    }
    return true
  }
}

public struct SQLiteMessagesBackend: MessagesReading {
  private let databasePath: String
  private let runner: any SQLiteCommandRunning

  public init(
    databasePath: String = "\(NSHomeDirectory())/Library/Messages/chat.db",
    runner: any SQLiteCommandRunning = SQLiteProcessRunner()
  ) {
    self.databasePath = databasePath
    self.runner = runner
  }

  public func listConversations(limit: Int) throws -> [MessagesConversationRecord] {
    try conversationRows(whereClause: nil, limit: limit)
  }

  public func searchConversations(query: String, limit: Int) throws -> [MessagesConversationRecord]
  {
    let pattern = sqlStringLiteral(likePattern(query))
    return try conversationRows(
      whereClause: """
        WHERE COALESCE(c.display_name, '') LIKE \(pattern) ESCAPE '\\'
           OR COALESCE(c.chat_identifier, '') LIKE \(pattern) ESCAPE '\\'
           OR EXISTS (
                SELECT 1
                FROM chat_handle_join chj
                JOIN handle h3 ON h3.ROWID = chj.handle_id
                WHERE chj.chat_id = c.ROWID
                  AND COALESCE(h3.id, '') LIKE \(pattern) ESCAPE '\\'
           )
           OR EXISTS (
                SELECT 1
                FROM chat_message_join cmj2
                JOIN message m2 ON m2.ROWID = cmj2.message_id
                LEFT JOIN handle h2 ON h2.ROWID = m2.handle_id
                WHERE cmj2.chat_id = c.ROWID
                  AND COALESCE(h2.id, '') LIKE \(pattern) ESCAPE '\\'
           )
        """,
      limit: limit
    )
  }

  public func conversationIdentity(id: String) throws -> MessagesConversationIdentity? {
    let conversationID = try numericIdentifier(id, prefix: "conversation:")
    let rows = try queryRows(
      """
      SELECT
        c.ROWID AS id,
        c.guid AS automationId,
        COALESCE(NULLIF(c.display_name, ''), NULLIF(c.chat_identifier, '')) AS displayName,
        c.service_name AS serviceName,
        MAX(m.date) AS lastMessageAt,
        COUNT(m.ROWID) AS messageCount,
        (
          SELECT GROUP_CONCAT(DISTINCT h2.id)
          FROM chat_handle_join chj
          JOIN handle h2 ON h2.ROWID = chj.handle_id
          WHERE chj.chat_id = c.ROWID
        ) AS participantHandles
      FROM chat c
      LEFT JOIN chat_message_join cmj ON cmj.chat_id = c.ROWID
      LEFT JOIN message m ON m.ROWID = cmj.message_id
      WHERE c.ROWID = \(conversationID)
      GROUP BY c.ROWID
      LIMIT 1;
      """)
    return try rows.first.map(parseConversationIdentity)
  }

  public func listMessages(conversationId: String, limit: Int) throws -> [MessagesMessageSummary] {
    let id = try numericIdentifier(conversationId, prefix: "conversation:")
    return try messageRows(
      whereClause: "WHERE cmj.chat_id = \(id)",
      limit: limit
    )
  }

  public func searchMessages(query: String, conversationId: String?, limit: Int) throws
    -> [MessagesMessageSummary]
  {
    let pattern = sqlStringLiteral(likePattern(query))
    var clauses = ["COALESCE(m.text, '') LIKE \(pattern) ESCAPE '\\'"]
    if let conversationId {
      clauses.append(
        "cmj.chat_id = \(try numericIdentifier(conversationId, prefix: "conversation:"))")
    }
    return try messageRows(
      whereClause: "WHERE \(clauses.joined(separator: " AND "))",
      limit: limit
    )
  }

  public func readMessage(id: String) throws -> MessagesMessageDetail? {
    let messageID = try numericIdentifier(id, prefix: "message:")
    let rows = try queryRows(
      """
      SELECT
        m.ROWID AS id,
        cmj.chat_id AS conversationId,
        h.id AS handle,
        COALESCE(m.service, h.service) AS serviceName,
        m.text AS text,
        m.date AS sentAt,
        m.is_from_me AS isFromMe
      FROM message m
      LEFT JOIN chat_message_join cmj ON cmj.message_id = m.ROWID
      LEFT JOIN handle h ON h.ROWID = m.handle_id
      WHERE m.ROWID = \(messageID)
      ORDER BY cmj.chat_id
      LIMIT 1;
      """)
    return try rows.first.map(messageDetail)
  }

  public func diagnosticCheck() -> CLIDoctorCheck {
    do {
      _ = try queryRows("SELECT COUNT(*) AS count FROM chat LIMIT 1;")
      return CLIDoctorCheck(
        name: "messages_read_backend",
        status: .ok,
        message: "Messages read/search backend is available."
      )
    } catch let error as CLIError where error.code == .permissionDenied {
      return CLIDoctorCheck(
        name: "messages_read_backend",
        status: .permissionDenied,
        message: CLIPermissionWording.fullDiskAccessRequired(
          resource: "Messages database", operation: "read/search commands")
      )
    } catch let error as CLIError {
      return CLIDoctorCheck(
        name: "messages_read_backend",
        status: error.code == .backendUnavailable ? .backendUnavailable : .warning,
        message: error.message
      )
    } catch {
      return CLIDoctorCheck(
        name: "messages_read_backend",
        status: .backendUnavailable,
        message: "Messages read/search backend could not be checked."
      )
    }
  }

  private func conversationRows(whereClause: String?, limit: Int) throws
    -> [MessagesConversationRecord]
  {
    let sql = """
      SELECT
        c.ROWID AS id,
        COALESCE(NULLIF(c.display_name, ''), NULLIF(c.chat_identifier, '')) AS displayName,
        c.service_name AS serviceName,
        MAX(m.date) AS lastMessageAt,
        COUNT(m.ROWID) AS messageCount,
        (
          SELECT GROUP_CONCAT(DISTINCT h2.id)
          FROM chat_handle_join chj
          JOIN handle h2 ON h2.ROWID = chj.handle_id
          WHERE chj.chat_id = c.ROWID
        ) AS participantHandles
      FROM chat c
      LEFT JOIN chat_message_join cmj ON cmj.chat_id = c.ROWID
      LEFT JOIN message m ON m.ROWID = cmj.message_id
      \(whereClause ?? "")
      GROUP BY c.ROWID
      ORDER BY lastMessageAt DESC
      LIMIT \(limit);
      """

    return try queryRows(sql).map(conversationRecord)
  }

  private func messageRows(whereClause: String, limit: Int) throws -> [MessagesMessageSummary] {
    let sql = """
      SELECT
        m.ROWID AS id,
        cmj.chat_id AS conversationId,
        h.id AS handle,
        COALESCE(m.service, h.service) AS serviceName,
        m.text AS text,
        m.date AS sentAt,
        m.is_from_me AS isFromMe
      FROM message m
      JOIN chat_message_join cmj ON cmj.message_id = m.ROWID
      LEFT JOIN handle h ON h.ROWID = m.handle_id
      \(whereClause)
      ORDER BY m.date DESC
      LIMIT \(limit);
      """

    return try queryRows(sql).map(messageSummary)
  }

  private func queryRows(_ sql: String) throws -> [[String: Any]] {
    let output = try runner.runSQLite(databasePath: databasePath, sql: sql)
    let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return []
    }

    let data = Data(trimmed.utf8)
    do {
      guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
        throw CLIError(code: .internalError, message: "Unexpected sqlite JSON shape.")
      }
      return rows
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .internalError, message: "Failed to parse sqlite JSON output.")
    }
  }
}

public struct SQLiteProcessRunner: SQLiteCommandRunning {
  public init() {}

  public func runSQLite(databasePath: String, sql: String) throws -> String {
    let result: CLISubprocessResult
    do {
      result = try CLISubprocess.run(
        .path("/usr/bin/sqlite3"),
        arguments: ["-readonly", "-json", databasePath, sql]
      )
    } catch let error as CLIError {
      throw error
    } catch {
      throw CLIError(code: .backendUnavailable, message: "`sqlite3` could not be started.")
    }

    if result.exitCode == 0 {
      return result.stdout
    }

    if isPermissionDenied(result.stderr) || isPermissionDenied(result.stdout) {
      throw CLIError(
        code: .permissionDenied,
        message: CLIPermissionWording.fullDiskAccessRequired(
          resource: "Messages database", operation: "read/search commands"),
        details: ["backend": "messages_chat_db"]
      )
    }

    if result.stderr.contains("no such table") || result.stderr.contains("no such column") {
      throw CLIError(
        code: .backendUnavailable,
        message: "Messages database schema is not compatible with this backend."
      )
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "`sqlite3` failed while inspecting Messages.",
      details: ["status": "\(result.exitCode)"]
    )
  }
}
