import Foundation
import Utility

extension RemindersSQLiteReader {
  public func resolveAssignmentTarget(
    reminder: ReminderDetail,
    assigneeSelector: String
  ) throws -> ReminderAssignmentTargetRecord {
    let selector = assigneeSelector.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !selector.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "`--assignee` requires a name, email, phone number, or sharee identifier."
      )
    }

    let store = try debugStore(scope: "summary")
    let reminderID = sqliteStringLiteral(reminder.id)
    var sawReminderList = false
    var lastWarnings = store.warnings

    for file in store.sqliteFiles where file.isReadable {
      do {
        let rows = try sqliteJSONRows(
          storePath: file.path,
          sql: """
            with target as (
              select
                r.Z_PK as reminder_primary_key,
                r.ZLIST as list_primary_key,
                coalesce(lower(hex(l.ZSHAREDOWNERIDENTIFIER)), '') as owner_identifier_hex
              from ZREMCDREMINDER r
              left join ZREMCDBASELIST l on l.Z_PK = r.ZLIST
              where r.ZMARKEDFORDELETION = 0
                and (
                  r.ZDACALENDARITEMUNIQUEIDENTIFIER = \(reminderID)
                  or r.ZCKIDENTIFIER = \(reminderID)
                  or r.ZEXTERNALIDENTIFIER = \(reminderID)
                )
              limit 1
            )
            select
              t.list_primary_key as list_primary_key,
              t.owner_identifier_hex as owner_identifier_hex,
              s.Z_PK as sharee_primary_key,
              coalesce(s.ZCKIDENTIFIER, '') as sharee_identifier,
              coalesce(s.ZDISPLAYNAME, '') as display_name,
              coalesce(s.ZFIRSTNAME, '') as first_name,
              coalesce(s.ZLASTNAME, '') as last_name,
              coalesce(s.ZADDRESS1, '') as address
            from target t
            left join ZREMCDOBJECT s on (
              s.Z_ENT = 36
              and s.ZMARKEDFORDELETION = 0
              and s.ZLIST = t.list_primary_key
            )
            order by s.Z_PK;
            """
        )
        guard !rows.isEmpty else {
          continue
        }
        sawReminderList = true

        let ownerIdentifier =
          rows
          .compactMap { uuidStringFromSQLiteHex(stringValue($0["owner_identifier_hex"])) }
          .first
        let sharees = rows.compactMap { row -> PrivateAssignmentSharee? in
          guard let primaryKey = int64Value(row["sharee_primary_key"]),
            let identifier = emptyToNil(stringValue(row["sharee_identifier"]))
          else {
            return nil
          }
          return PrivateAssignmentSharee(
            primaryKey: primaryKey,
            identifier: identifier,
            displayName: emptyToNil(stringValue(row["display_name"])),
            firstName: emptyToNil(stringValue(row["first_name"])),
            lastName: emptyToNil(stringValue(row["last_name"])),
            address: emptyToNil(stringValue(row["address"]))
          )
        }

        guard !sharees.isEmpty else {
          throw CLIError(
            code: .validationError,
            message: "Reminder assignment requires a shared Reminders list.",
            details: ["reminder_id": reminder.id, "list_id": reminder.listId]
          )
        }
        guard let ownerIdentifier else {
          throw CLIError(
            code: .backendUnavailable,
            message: "Could not identify the current-user sharee for assignment originator.",
            details: ["reminder_id": reminder.id, "list_id": reminder.listId]
          )
        }
        guard
          let originator = sharees.first(where: {
            identifiersEqual($0.identifier, ownerIdentifier)
          })
        else {
          throw CLIError(
            code: .backendUnavailable,
            message: "Current-user sharee is not present in this Reminders list.",
            details: [
              "reminder_id": reminder.id,
              "list_id": reminder.listId,
              "originator_identifier": ownerIdentifier,
            ]
          )
        }

        let assignee = try resolveAssignmentSharee(
          selector: selector,
          sharees: sharees,
          currentUserIdentifier: ownerIdentifier
        )

        return ReminderAssignmentTargetRecord(
          assigneeIdentifier: assignee.identifier,
          originatorIdentifier: originator.identifier,
          assigneeLabel: displayName(for: assignee),
          assigneeAddress: assignee.address,
          originatorLabel: displayName(for: originator),
          originatorAddress: originator.address
        )
      } catch let error as CLIError {
        throw error
      } catch {
        lastWarnings.append("\(file.path): \(error)")
      }
    }

    if sawReminderList {
      throw CLIError(
        code: .backendUnavailable,
        message: "Could not resolve Reminders assignment sharees from the read-only SQLite.",
        details: ["reminder_id": reminder.id, "warnings": lastWarnings.joined(separator: "\n")]
      )
    }

    throw CLIError(
      code: .notFound,
      message: "Reminder was not found in read-only Reminders SQLite evidence.",
      details: ["reminder_id": reminder.id]
    )
  }

  func resolveAssignmentSharee(
    selector: String,
    sharees: [PrivateAssignmentSharee],
    currentUserIdentifier: String
  ) throws -> PrivateAssignmentSharee {
    if ["me", "myself"].contains(normalizedLookup(selector)) {
      if let sharee = sharees.first(where: {
        identifiersEqual($0.identifier, currentUserIdentifier)
      }) {
        return sharee
      }
      throw CLIError(
        code: .backendUnavailable,
        message: "Current-user sharee is not present in this Reminders list.",
        details: ["originator_identifier": currentUserIdentifier]
      )
    }

    let selectorKey = normalizedLookup(selector)
    var exact: [PrivateAssignmentSharee] = []
    var contains: [PrivateAssignmentSharee] = []
    for sharee in sharees {
      if String(sharee.primaryKey) == selector {
        exact.append(sharee)
        continue
      }
      for term in assignmentShareeMatchTerms(sharee) {
        let termKey = normalizedLookup(term)
        if termKey == selectorKey {
          exact.append(sharee)
          break
        }
        if !selectorKey.isEmpty, termKey.contains(selectorKey) {
          contains.append(sharee)
          break
        }
      }
    }

    let matches = uniqueSharees(exact.isEmpty ? contains : exact)
    if matches.count == 1, let match = matches.first {
      return match
    }
    if matches.count > 1 {
      throw CLIError(
        code: .validationError,
        message: "Assignment assignee selector matched multiple sharees.",
        details: [
          "assignee_selector": selector,
          "matches": matches.map(shareeOptionDescription).joined(separator: ", "),
        ]
      )
    }

    throw CLIError(
      code: .validationError,
      message: "Assignment assignee selector did not match a sharee in this Reminders list.",
      details: [
        "assignee_selector": selector,
        "available_sharees": sharees.map(shareeOptionDescription).joined(separator: ", "),
      ]
    )
  }

  func assignmentShareeMatchTerms(_ sharee: PrivateAssignmentSharee) -> [String] {
    var terms = [
      sharee.identifier,
      sharee.displayName,
      sharee.firstName,
      sharee.lastName,
      displayName(for: sharee),
      sharee.address,
    ].compactMap { $0 }
    if let address = sharee.address, let suffix = address.split(separator: ":", maxSplits: 1).last {
      terms.append(String(suffix))
    }
    return terms
  }

  func shareeOptionDescription(_ sharee: PrivateAssignmentSharee) -> String {
    let label = displayName(for: sharee) ?? sharee.identifier
    if let address = sharee.address {
      return "\(label) (\(address))"
    }
    return "\(label) (\(sharee.identifier))"
  }

  func displayName(for sharee: PrivateAssignmentSharee) -> String? {
    if let displayName = sharee.displayName {
      return displayName
    }
    let parts = [sharee.firstName, sharee.lastName].compactMap { $0 }
    if !parts.isEmpty {
      return parts.joined(separator: " ")
    }
    return sharee.address
  }

  func uniqueSharees(_ sharees: [PrivateAssignmentSharee]) -> [PrivateAssignmentSharee] {
    var seen: Set<Int64> = []
    var unique: [PrivateAssignmentSharee] = []
    for sharee in sharees where !seen.contains(sharee.primaryKey) {
      seen.insert(sharee.primaryKey)
      unique.append(sharee)
    }
    return unique
  }
}
