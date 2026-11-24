import Foundation
import Utility

struct ReminderAttachmentReminderSelector {
  let value: String
  let objectUUID: UUID?
  let explicitObjectID: Bool

  init(_ value: String) throws {
    guard !value.isEmpty,
      !value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains)
    else {
      throw CLIError(code: .validationError, message: "A valid reminder ID is required.")
    }
    self.value = value
    explicitObjectID = value.hasPrefix("x-apple-reminderkit:")
    if explicitObjectID {
      guard let url = URL(string: value), url.scheme == "x-apple-reminderkit",
        url.host == "REMCDReminder", url.user == nil, url.password == nil, url.port == nil,
        url.query == nil, url.fragment == nil, url.pathComponents.count == 2,
        let uuid = UUID(uuidString: url.lastPathComponent)
      else {
        throw CLIError(
          code: .validationError, message: "Expected a ReminderKit reminder object ID.")
      }
      objectUUID = uuid
    } else {
      objectUUID = UUID(uuidString: value)
    }
  }
}

enum ReminderAttachmentIndexError: Error {
  case unavailable
}

extension RemindersSQLiteReader {
  func attachmentInventory(for selector: ReminderAttachmentReminderSelector) throws
    -> ReminderAttachmentInventory?
  {
    let files: [RemindersStoreFileRecord]
    do {
      files = try discoverSQLiteStoreFiles(in: remindersStoresURL)
    } catch {
      throw ReminderAttachmentIndexError.unavailable
    }
    guard !files.isEmpty else { throw ReminderAttachmentIndexError.unavailable }

    let id = sqliteStringLiteral(selector.value)
    var predicates: [String] = []
    if let uuid = selector.objectUUID {
      predicates.append("r.ZIDENTIFIER = X'\(attachmentUUIDHex(uuid))'")
    }
    if !selector.explicitObjectID {
      predicates.append("r.ZDACALENDARITEMUNIQUEIDENTIFIER = \(id) COLLATE BINARY")
      if selector.objectUUID != nil {
        predicates.append("r.ZCKIDENTIFIER = \(id) COLLATE NOCASE")
      } else {
        predicates.append("r.ZCKIDENTIFIER = \(id) COLLATE BINARY")
      }
    }

    let livePredicate = selector.explicitObjectID ? "" : "AND r.ZMARKEDFORDELETION = 0"
    var selected: (path: String, row: [String: Any])?
    var foundDeletedReminder = false
    for file in files {
      let url = URL(fileURLWithPath: file.path)
      let properties = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
      guard file.isReadable, properties?.isRegularFile == true, properties?.isSymbolicLink == false
      else { throw ReminderAttachmentIndexError.unavailable }
      let rows = try attachmentIndexRows(
        storePath: file.path,
        sql: """
          SELECT r.Z_PK AS pk, r.ZACCOUNT AS account_pk, hex(r.ZIDENTIFIER) AS uuid,
            r.ZMARKEDFORDELETION AS deleted
          FROM ZREMCDREMINDER r
          WHERE (\(predicates.joined(separator: " OR "))) \(livePredicate)
          ORDER BY CASE WHEN r.ZMARKEDFORDELETION = 0 THEN 0 ELSE 1 END
          LIMIT 2;
          """)
      for row in rows {
        guard int64Value(row["deleted"]) == 0 else {
          foundDeletedReminder = true
          continue
        }
        guard selected == nil else {
          throw CLIError(
            code: .ambiguousIdentity, message: "Reminder ID matches multiple active reminders.",
            details: ["id": selector.value])
        }
        selected = (file.path, row)
      }
    }
    if selected == nil, foundDeletedReminder {
      throw CLIError(code: .notFound, message: "The selected reminder is deleted.")
    }
    guard let selected else { return nil }
    guard let reminderPK = int64Value(selected.row["pk"]),
      let accountPK = int64Value(selected.row["account_pk"]),
      let reminderUUID = attachmentIndexUUID(selected.row["uuid"])
    else { throw attachmentIndexConflict() }

    let columns: Set<String>
    do {
      columns = try tableColumnNames(storePath: selected.path, tableName: "ZREMCDOBJECT")
    } catch {
      throw ReminderAttachmentIndexError.unavailable
    }
    let digest = columns.contains("ZSHA512SUM") ? "o.ZSHA512SUM" : "NULL"
    let size = columns.contains("ZFILESIZE") ? "o.ZFILESIZE" : "NULL"
    let rows = try attachmentIndexRows(
      storePath: selected.path,
      sql: """
        WITH RECURSIVE attachment_entities(id, name) AS (
          SELECT Z_ENT, Z_NAME FROM Z_PRIMARYKEY WHERE Z_NAME = 'REMCDAttachment'
          UNION
          SELECT e.Z_ENT, e.Z_NAME FROM Z_PRIMARYKEY e
          JOIN attachment_entities p ON e.Z_SUPER = p.id
        )
        SELECT hex(a.ZIDENTIFIER) AS account_uuid, o.Z_PK AS attachment_pk,
          o.ZACCOUNT AS attachment_account, hex(o.ZIDENTIFIER) AS attachment_uuid, e.name AS entity,
          o.ZMARKEDFORDELETION AS deleted, o.ZFILENAME AS filename, o.ZUTI AS uti,
          \(size) AS size, \(digest) AS sha512
        FROM ZREMCDREMINDER r
        JOIN ZREMCDOBJECT a ON a.Z_PK = r.ZACCOUNT AND a.ZMARKEDFORDELETION = 0
        JOIN Z_PRIMARYKEY ae ON ae.Z_ENT = a.Z_ENT AND ae.Z_NAME = 'REMCDAccount'
        LEFT JOIN ZREMCDOBJECT o ON o.ZREMINDER2 = r.Z_PK
          AND o.Z_ENT IN (SELECT id FROM attachment_entities)
        LEFT JOIN attachment_entities e ON e.id = o.Z_ENT
        WHERE r.Z_PK = \(reminderPK) AND r.ZACCOUNT = \(accountPK)
          AND r.ZIDENTIFIER = X'\(attachmentUUIDHex(reminderUUID))' AND r.ZMARKEDFORDELETION = 0
          AND EXISTS (SELECT 1 FROM attachment_entities WHERE name = 'REMCDFileAttachment');
        """)
    guard let accountUUID = attachmentIndexUUID(rows.first?["account_uuid"]) else {
      throw ReminderAttachmentIndexError.unavailable
    }

    var sources: [ReminderAttachmentSource] = []
    var deletedAttachmentIDs: Set<UUID> = []
    for row in rows where row["attachment_pk"] is NSNumber {
      if int64Value(row["deleted"]) != 0 {
        if let uuid = attachmentIndexUUID(row["attachment_uuid"]) {
          deletedAttachmentIDs.insert(uuid)
        }
        continue
      }
      guard int64Value(row["attachment_account"]) == accountPK,
        let uuid = attachmentIndexUUID(row["attachment_uuid"])
      else { throw attachmentIndexConflict() }
      let kind: ReminderAttachmentKind =
        switch row["entity"] as? String {
        case "REMCDFileAttachment": .file
        case "REMCDImageAttachment": .image
        case "REMCDAudioAttachment": .audio
        case "REMCDURLAttachment": .link
        default: .unsupported
        }
      let size = int64Value(row["size"])
      guard size.map({ $0 >= 0 }) ?? true else { throw attachmentIndexConflict() }
      sources.append(
        ReminderAttachmentSource(
          id: uuid, kind: kind, fileName: emptyToNil(row["filename"] as? String),
          typeIdentifier: emptyToNil(row["uti"] as? String), sizeBytes: size,
          storedSHA512: emptyToNil(stringValue(row["sha512"]))))
    }

    // Legacy rows are a distinct backing model. Only ReminderKit can identify
    // their originals on a store layout that this resolver cannot verify.
    let legacyExists = try attachmentIndexRows(
      storePath: selected.path,
      sql: """
        SELECT 1 FROM sqlite_schema WHERE type = 'table' AND name = 'ZREMCDSAVEDATTACHMENT';
        """)
    if !legacyExists.isEmpty {
      let legacy = try attachmentIndexRows(
        storePath: selected.path,
        sql: """
          SELECT 1 FROM ZREMCDSAVEDATTACHMENT
          WHERE ZREMINDER = \(reminderPK) AND ZACCOUNT = \(accountPK)
            AND ZMARKEDFORDELETION = 0 LIMIT 1;
          """)
      if !legacy.isEmpty { throw ReminderAttachmentIndexError.unavailable }
    }

    return ReminderAttachmentInventory(
      reminderId: selector.value, reminderUUID: reminderUUID, accountUUID: accountUUID,
      attachments: sources, deletedAttachmentIDs: deletedAttachmentIDs)
  }

  private func attachmentIndexRows(storePath: String, sql: String) throws -> [[String: Any]] {
    do {
      return try sqliteJSONRows(storePath: storePath, sql: sql)
    } catch {
      throw ReminderAttachmentIndexError.unavailable
    }
  }

  private func attachmentIndexUUID(_ sqliteValue: Any?) -> UUID? {
    uuidStringFromSQLiteHex(sqliteValue as? String).flatMap(UUID.init(uuidString:))
  }
}

private func attachmentUUIDHex(_ uuid: UUID) -> String {
  uuid.uuidString.replacingOccurrences(of: "-", with: "")
}

func attachmentIndexConflict() -> CLIError {
  CLIError(
    code: .backendUnavailable, message: "Reminders attachment identities are inconsistent.",
    details: ["reason": "inconsistent_attachment_index"])
}
