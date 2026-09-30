import Contacts
import CryptoKit
import Foundation
import Utility

public struct ContactsFrameworkBackend: ContactsReading, ContactsMutating {
  public init() {}

  public func searchContacts(_ query: ContactSearchQuery) throws -> [ContactSummary] {
    let store = try contactStoreWithReadAccess()
    let keys = contactKeys()
    let request = CNContactFetchRequest(keysToFetch: keys)
    request.sortOrder = .userDefault

    var results: [ContactSummary] = []
    try store.enumerateContacts(with: request) { contact, stop in
      guard contactMatches(contact, query: query.query) else {
        return
      }

      results.append(contactSummary(contact))
      if results.count >= query.limit {
        stop.pointee = true
      }
    }

    return results
  }

  public func readContact(id: String) throws -> ContactDetail? {
    let store = try contactStoreWithReadAccess()
    do {
      let contact = try store.unifiedContact(withIdentifier: id, keysToFetch: contactKeys())
      return contactDetail(contact)
    } catch let error as CNError where error.code == .recordDoesNotExist {
      return nil
    }
  }

  public func exportContact(id: String) throws -> ContactExportPayload? {
    let store = try contactStoreWithReadAccess()
    do {
      let contact = try store.unifiedContact(withIdentifier: id, keysToFetch: vCardContactKeys())
      return try ContactExportPayload(
        contact: contactDetail(contact),
        data: CNContactVCardSerialization.data(with: [contact])
      )
    } catch let error as CNError where error.code == .recordDoesNotExist {
      return nil
    }
  }

  public func exportAllContacts(limit: Int) throws -> [ContactExportPayload] {
    let store = try contactStoreWithReadAccess()
    let request = CNContactFetchRequest(keysToFetch: vCardContactKeys())
    request.sortOrder = .userDefault

    var contacts: [CNContact] = []
    try store.enumerateContacts(with: request) { contact, stop in
      contacts.append(contact)
      if contacts.count > limit {
        stop.pointee = true
      }
    }

    guard contacts.count <= limit else {
      throw CLIError(
        code: .validationError,
        message:
          "Contact export matched more than `--limit` contacts. Increase `--limit` up to 500 or use explicit `--ids`.",
        details: ["limit": "\(limit)"]
      )
    }

    return try contacts.map { contact in
      try ContactExportPayload(
        contact: contactDetail(contact),
        data: CNContactVCardSerialization.data(with: [contact])
      )
    }
  }

  public func findDuplicateContacts(_ query: ContactDuplicateQuery) throws
    -> [ContactDuplicateGroup]
  {
    let store = try contactStoreWithReadAccess()
    let request = CNContactFetchRequest(keysToFetch: contactKeys())
    request.sortOrder = .userDefault
    var buckets: [String: ContactDuplicateBucket] = [:]

    try store.enumerateContacts(with: request) { contact, _ in
      let summary = contactSummary(contact)
      for candidate in duplicateCandidates(contact, field: query.field) {
        var bucket = buckets[candidate.key] ?? ContactDuplicateBucket(value: candidate.value)
        if bucket.contactIDs.insert(summary.id).inserted {
          bucket.contacts.append(summary)
        }
        buckets[candidate.key] = bucket
      }
    }

    return
      buckets
      .map { key, bucket in
        ContactDuplicateGroup(
          field: query.field,
          value: bucket.value,
          normalizedValueHash: sha256Hex(key),
          matchCount: bucket.contacts.count,
          contacts: bucket.contacts.sorted {
            if $0.displayName == $1.displayName {
              return $0.id < $1.id
            }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName)
              == .orderedAscending
          }
        )
      }
      .filter { $0.matchCount > 1 }
      .sorted {
        if $0.matchCount == $1.matchCount {
          return $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending
        }
        return $0.matchCount > $1.matchCount
      }
      .prefix(query.limit)
      .map { $0 }
  }

  public func listGroups(limit: Int) throws -> [ContactGroupRecord] {
    let store = try contactStoreWithReadAccess()
    return try store.groups(matching: nil)
      .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
      .prefix(limit)
      .map(contactGroupRecord)
  }

  public func listGroupMembers(groupID: String, limit: Int) throws -> ContactGroupMembersResponse? {
    let store = try contactStoreWithReadAccess()
    let groups = try store.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [groupID]))
    guard let group = groups.first else {
      return nil
    }

    let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
    let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: contactKeys())
      .sorted {
        displayName($0).localizedCaseInsensitiveCompare(displayName($1)) == .orderedAscending
      }
      .prefix(limit)
      .map { contactSummary($0) }

    return ContactGroupMembersResponse(
      group: contactGroupRecord(group),
      contacts: Array(contacts)
    )
  }

  public func contactForMutation(id: String) throws -> ContactDetail? {
    try readContact(id: id)
  }

  public func groupForMutation(id: String) throws -> ContactGroupRecord? {
    let store = try contactStoreWithReadAccess()
    guard let group = try group(id: id, store: store) else {
      return nil
    }
    return contactGroupRecord(group)
  }

  public func isContact(_ contactID: String, memberOfGroup groupID: String) throws -> Bool {
    let store = try contactStoreWithReadAccess()
    guard let group = try group(id: groupID, store: store) else {
      throw CLIError(
        code: .notFound, message: "Contact group was not found.", details: ["group_id": groupID])
    }

    let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
    let contacts = try store.unifiedContacts(
      matching: predicate,
      keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
    )
    return contacts.contains { $0.identifier == contactID }
  }

  public func createContact(_ draft: ContactCreateDraft) throws -> ContactDetail {
    let store = try contactStoreWithWriteAccess()
    let contact = CNMutableContact()
    applyDraft(draft, to: contact)

    let request = CNSaveRequest()
    request.add(contact, toContainerWithIdentifier: nil)
    try store.execute(request)
    return contactDetail(contact)
  }

  public func previewContactImport(
    data: Data,
    limit: Int,
    duplicatePolicy: ContactImportDuplicatePolicy
  ) throws -> ContactImportPreview {
    let contacts = try parseVCardContactDetails(data: data, limit: limit)
    let duplicates =
      duplicatePolicy == .createNew
      ? []
      : try contactImportDuplicates(for: contacts, store: contactStoreWithReadAccess())
    return ContactImportPreview(
      contacts: contacts, duplicatePolicy: duplicatePolicy, duplicates: duplicates)
  }

  public func importContacts(
    data: Data,
    limit: Int,
    duplicatePolicy: ContactImportDuplicatePolicy
  ) throws -> ContactImportExecution {
    let contacts = try parseVCardContacts(data: data, limit: limit)
    let store = try contactStoreWithWriteAccess()
    let contactDetails = contacts.map(contactDetail)
    let duplicates =
      duplicatePolicy == .createNew
      ? []
      : try contactImportDuplicates(for: contactDetails, store: store)
    if duplicatePolicy == .fail, !duplicates.isEmpty {
      throw CLIError(
        code: .validationError,
        message:
          "Contact import matched existing contacts. Use `--on-duplicate skip-existing` or `--on-duplicate create-new` explicitly.",
        details: ["duplicate_count": "\(duplicates.count)"]
      )
    }
    let skippedIndexes = Set(duplicates.map(\.importedIndex))
    let importCandidates =
      duplicatePolicy == .skipExisting
      ? contacts.enumerated().filter { !skippedIndexes.contains($0.offset) }.map(\.element)
      : contacts
    let imported = try importCandidates.map { contact in
      guard let mutable = contact.mutableCopy() as? CNMutableContact else {
        throw CLIError(
          code: .internalError, message: "Failed to prepare imported contact for saving.")
      }
      return mutable
    }

    if !imported.isEmpty {
      let request = CNSaveRequest()
      for contact in imported {
        request.add(contact, toContainerWithIdentifier: nil)
      }
      try store.execute(request)
    }
    return ContactImportExecution(
      contacts: imported.map(contactDetail), skippedDuplicates: duplicates)
  }

  public func updateContact(id: String, patch: ContactPatch) throws -> ContactDetail {
    let store = try contactStoreWithWriteAccess()
    let current = try mutableContact(id: id, store: store)
    try applyPatch(patch, to: current)

    let request = CNSaveRequest()
    request.update(current)
    try store.execute(request)
    return contactDetail(current)
  }

  public func deleteContact(id: String) throws -> Bool {
    let store = try contactStoreWithWriteAccess()
    let current = try mutableContact(id: id, store: store)

    let request = CNSaveRequest()
    request.delete(current)
    try store.execute(request)
    return true
  }

  public func deleteContacts(ids: [String]) throws -> [String] {
    let store = try contactStoreWithWriteAccess()
    let contacts = try ids.map { id in
      try mutableContact(id: id, store: store)
    }

    let request = CNSaveRequest()
    for contact in contacts {
      request.delete(contact)
    }
    try store.execute(request)
    return ids
  }

  public func addContact(id: String, toGroupID groupID: String) throws -> Bool {
    let store = try contactStoreWithWriteAccess()
    let contact = try contact(id: id, store: store)
    guard let group = try group(id: groupID, store: store) else {
      throw CLIError(
        code: .notFound, message: "Contact group was not found.", details: ["group_id": groupID])
    }

    let request = CNSaveRequest()
    request.addMember(contact, to: group)
    try store.execute(request)
    return true
  }

  public func removeContact(id: String, fromGroupID groupID: String) throws -> Bool {
    let store = try contactStoreWithWriteAccess()
    let contact = try contact(id: id, store: store)
    guard let group = try group(id: groupID, store: store) else {
      throw CLIError(
        code: .notFound, message: "Contact group was not found.", details: ["group_id": groupID])
    }

    let request = CNSaveRequest()
    request.removeMember(contact, from: group)
    try store.execute(request)
    return true
  }

  private func contact(id: String, store: CNContactStore) throws -> CNContact {
    do {
      return try store.unifiedContact(withIdentifier: id, keysToFetch: contactKeys())
    } catch let error as CNError where error.code == .recordDoesNotExist {
      throw CLIError(code: .notFound, message: "Contact was not found.", details: ["id": id])
    }
  }

  private func group(id: String, store: CNContactStore) throws -> CNGroup? {
    let groups = try store.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [id]))
    return groups.first
  }

  private func mutableContact(id: String, store: CNContactStore) throws -> CNMutableContact {
    do {
      let contact = try store.unifiedContact(withIdentifier: id, keysToFetch: contactKeys())
      guard let mutable = contact.mutableCopy() as? CNMutableContact else {
        throw CLIError(code: .internalError, message: "Failed to create a mutable contact copy.")
      }
      return mutable
    } catch let error as CNError where error.code == .recordDoesNotExist {
      throw CLIError(code: .notFound, message: "Contact was not found.", details: ["id": id])
    }
  }
}
