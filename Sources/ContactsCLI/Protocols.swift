import Contacts
import CryptoKit
import Foundation
import Utility

public protocol ContactsReading: Sendable {
  func searchContacts(_ query: ContactSearchQuery) throws -> [ContactSummary]
  func findDuplicateContacts(_ query: ContactDuplicateQuery) throws -> [ContactDuplicateGroup]
  func readContact(id: String) throws -> ContactDetail?
  func exportContact(id: String) throws -> ContactExportPayload?
  func exportAllContacts(limit: Int) throws -> [ContactExportPayload]
  func listGroups(limit: Int) throws -> [ContactGroupRecord]
  func listGroupMembers(groupID: String, limit: Int) throws -> ContactGroupMembersResponse?
}

public protocol ContactsMutating: Sendable {
  func contactForMutation(id: String) throws -> ContactDetail?
  func groupForMutation(id: String) throws -> ContactGroupRecord?
  func isContact(_ contactID: String, memberOfGroup groupID: String) throws -> Bool
  func previewContactImport(data: Data, limit: Int, duplicatePolicy: ContactImportDuplicatePolicy)
    throws -> ContactImportPreview
  func importContacts(data: Data, limit: Int, duplicatePolicy: ContactImportDuplicatePolicy) throws
    -> ContactImportExecution
  func createContact(_ draft: ContactCreateDraft) throws -> ContactDetail
  func updateContact(id: String, patch: ContactPatch) throws -> ContactDetail
  func deleteContact(id: String) throws -> Bool
  func deleteContacts(ids: [String]) throws -> [String]
  func addContact(id: String, toGroupID groupID: String) throws -> Bool
  func removeContact(id: String, fromGroupID groupID: String) throws -> Bool
}
