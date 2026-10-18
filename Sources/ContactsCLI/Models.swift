import Contacts
import CryptoKit
import Foundation
import Utility

public struct ContactSearchQuery: Equatable, Sendable {
  public var query: String
  public var limit: Int

  public init(query: String, limit: Int) {
    self.query = query
    self.limit = limit
  }
}

public struct ContactDuplicateQuery: Equatable, Sendable {
  public var field: String
  public var limit: Int

  public init(field: String, limit: Int) {
    self.field = field
    self.limit = limit
  }
}

public struct ContactSummary: Codable, Equatable, Sendable {
  public var id: String
  public var displayName: String
  public var organizationName: String?
  public var emailAddresses: [String]
  public var phoneNumbers: [String]
  public var emailLabels: [String]
  public var phoneLabels: [String]

  public init(
    id: String,
    displayName: String,
    organizationName: String? = nil,
    emailAddresses: [String] = [],
    phoneNumbers: [String] = [],
    emailLabels: [String] = [],
    phoneLabels: [String] = []
  ) {
    self.id = id
    self.displayName = displayName
    self.organizationName = organizationName
    self.emailAddresses = emailAddresses
    self.phoneNumbers = phoneNumbers
    self.emailLabels = emailLabels
    self.phoneLabels = phoneLabels
  }
}

public struct ContactDetail: Codable, Equatable, Sendable {
  public var id: String
  public var displayName: String
  public var givenName: String
  public var familyName: String
  public var organizationName: String?
  public var jobTitle: String?
  public var emailAddresses: [String]
  public var phoneNumbers: [String]
  public var emailLabels: [String]
  public var phoneLabels: [String]

  public init(
    id: String,
    displayName: String,
    givenName: String,
    familyName: String,
    organizationName: String? = nil,
    jobTitle: String? = nil,
    emailAddresses: [String] = [],
    phoneNumbers: [String] = [],
    emailLabels: [String] = [],
    phoneLabels: [String] = []
  ) {
    self.id = id
    self.displayName = displayName
    self.givenName = givenName
    self.familyName = familyName
    self.organizationName = organizationName
    self.jobTitle = jobTitle
    self.emailAddresses = emailAddresses
    self.phoneNumbers = phoneNumbers
    self.emailLabels = emailLabels
    self.phoneLabels = phoneLabels
  }
}

public struct ContactGroupRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

public struct ContactsSearchResponse: Codable, Equatable, Sendable {
  public var contacts: [ContactSummary]
}

public struct ContactReadResponse: Codable, Equatable, Sendable {
  public var contact: ContactDetail
}

public struct ContactGroupsResponse: Codable, Equatable, Sendable {
  public var groups: [ContactGroupRecord]
}

public struct ContactGroupMembersResponse: Codable, Equatable, Sendable {
  public var group: ContactGroupRecord
  public var contacts: [ContactSummary]

  public init(group: ContactGroupRecord, contacts: [ContactSummary]) {
    self.group = group
    self.contacts = contacts
  }
}

public struct ContactDuplicateGroup: Codable, Equatable, Sendable {
  public var field: String
  public var value: String
  public var normalizedValueHash: String
  public var matchCount: Int
  public var contacts: [ContactSummary]

  public init(
    field: String,
    value: String,
    normalizedValueHash: String,
    matchCount: Int,
    contacts: [ContactSummary]
  ) {
    self.field = field
    self.value = value
    self.normalizedValueHash = normalizedValueHash
    self.matchCount = matchCount
    self.contacts = contacts
  }
}

public struct ContactDuplicatesResponse: Codable, Equatable, Sendable {
  public var duplicateGroups: [ContactDuplicateGroup]
}

public struct ContactExportPayload: Equatable, Sendable {
  public var contact: ContactDetail
  public var data: Data

  public init(contact: ContactDetail, data: Data) {
    self.contact = contact
    self.data = data
  }
}


public struct ContactExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var contactID: String
  public var displayName: String
  public var destinationPath: String
  public var format: String
  public var byteCount: Int
  public var sha256: String

  public init(
    operation: String,
    changed: Bool,
    contactID: String,
    displayName: String,
    destinationPath: String,
    format: String,
    byteCount: Int,
    sha256: String
  ) {
    self.operation = operation
    self.changed = changed
    self.contactID = contactID
    self.displayName = displayName
    self.destinationPath = destinationPath
    self.format = format
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public struct ContactBulkExportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var contactIDs: [String]
  public var contactCount: Int
  public var destinationPath: String
  public var format: String
  public var byteCount: Int
  public var sha256: String

  public init(
    operation: String,
    changed: Bool,
    contactIDs: [String],
    destinationPath: String,
    format: String,
    byteCount: Int,
    sha256: String
  ) {
    self.operation = operation
    self.changed = changed
    self.contactIDs = contactIDs
    self.contactCount = contactIDs.count
    self.destinationPath = destinationPath
    self.format = format
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}

public enum ContactImportDuplicatePolicy: String, Codable, Equatable, Sendable {
  case createNew = "create-new"
  case fail = "fail"
  case skipExisting = "skip-existing"
}

public struct ContactImportDuplicate: Codable, Equatable, Sendable {
  public var importedIndex: Int
  public var existingID: String
  public var matchKind: String
  public var matchValueHash: String

  public init(importedIndex: Int, existingID: String, matchKind: String, matchValueHash: String) {
    self.importedIndex = importedIndex
    self.existingID = existingID
    self.matchKind = matchKind
    self.matchValueHash = matchValueHash
  }
}

public struct ContactImportPreview: Equatable, Sendable {
  public var contacts: [ContactDetail]
  public var duplicatePolicy: ContactImportDuplicatePolicy
  public var duplicates: [ContactImportDuplicate]
  public var importableCount: Int
  public var skippedCount: Int

  public init(
    contacts: [ContactDetail],
    duplicatePolicy: ContactImportDuplicatePolicy = .createNew,
    duplicates: [ContactImportDuplicate] = []
  ) {
    self.contacts = contacts
    self.duplicatePolicy = duplicatePolicy
    self.duplicates = duplicates
    self.skippedCount =
      duplicatePolicy == .skipExisting ? Set(duplicates.map(\.importedIndex)).count : 0
    self.importableCount = contacts.count - skippedCount
  }
}

public struct ContactImportExecution: Equatable, Sendable {
  public var contacts: [ContactDetail]
  public var skippedDuplicates: [ContactImportDuplicate]

  public init(contacts: [ContactDetail], skippedDuplicates: [ContactImportDuplicate] = []) {
    self.contacts = contacts
    self.skippedDuplicates = skippedDuplicates
  }
}

public struct ContactImportResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var contacts: [ContactDetail]
  public var contactCount: Int
  public var skippedDuplicates: [ContactImportDuplicate]
  public var skippedCount: Int
  public var duplicatePolicy: ContactImportDuplicatePolicy
  public var sourcePath: String
  public var byteCount: Int
  public var sha256: String

  public init(
    operation: String,
    changed: Bool,
    contacts: [ContactDetail],
    skippedDuplicates: [ContactImportDuplicate] = [],
    duplicatePolicy: ContactImportDuplicatePolicy = .createNew,
    sourcePath: String,
    byteCount: Int,
    sha256: String
  ) {
    self.operation = operation
    self.changed = changed
    self.contacts = contacts
    self.contactCount = contacts.count
    self.skippedDuplicates = skippedDuplicates
    self.skippedCount = Set(skippedDuplicates.map(\.importedIndex)).count
    self.duplicatePolicy = duplicatePolicy
    self.sourcePath = sourcePath
    self.byteCount = byteCount
    self.sha256 = sha256
  }
}


public struct ContactMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var contact: ContactDetail?
  public var deletedID: String?
  public var group: ContactGroupRecord?

  public init(
    operation: String,
    changed: Bool,
    contact: ContactDetail? = nil,
    deletedID: String? = nil,
    group: ContactGroupRecord? = nil
  ) {
    self.operation = operation
    self.changed = changed
    self.contact = contact
    self.deletedID = deletedID
    self.group = group
  }
}

public struct ContactBulkMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var contactIDs: [String]
  public var deletedCount: Int

  public init(operation: String, changed: Bool, contactIDs: [String]) {
    self.operation = operation
    self.changed = changed
    self.contactIDs = contactIDs
    self.deletedCount = contactIDs.count
  }
}

public struct ContactCreateDraft: Codable, Equatable, Sendable {
  public var givenName: String
  public var familyName: String
  public var organizationName: String?
  public var jobTitle: String?
  public var emailAddress: String?
  public var phoneNumber: String?
  public var emailLabel: String?
  public var phoneLabel: String?

  public init(
    givenName: String = "",
    familyName: String = "",
    organizationName: String? = nil,
    jobTitle: String? = nil,
    emailAddress: String? = nil,
    phoneNumber: String? = nil,
    emailLabel: String? = nil,
    phoneLabel: String? = nil
  ) {
    self.givenName = givenName
    self.familyName = familyName
    self.organizationName = organizationName
    self.jobTitle = jobTitle
    self.emailAddress = emailAddress
    self.phoneNumber = phoneNumber
    self.emailLabel = emailLabel
    self.phoneLabel = phoneLabel
  }
}

public struct ContactPatch: Codable, Equatable, Sendable {
  public var givenName: String?
  public var familyName: String?
  public var organizationName: String?
  public var jobTitle: String?
  public var emailAddress: String?
  public var phoneNumber: String?
  public var emailLabel: String?
  public var phoneLabel: String?
  public var clearOrganization: Bool
  public var clearJobTitle: Bool
  public var clearEmail: Bool
  public var clearPhone: Bool

  public init(
    givenName: String? = nil,
    familyName: String? = nil,
    organizationName: String? = nil,
    jobTitle: String? = nil,
    emailAddress: String? = nil,
    phoneNumber: String? = nil,
    emailLabel: String? = nil,
    phoneLabel: String? = nil,
    clearOrganization: Bool = false,
    clearJobTitle: Bool = false,
    clearEmail: Bool = false,
    clearPhone: Bool = false
  ) {
    self.givenName = givenName
    self.familyName = familyName
    self.organizationName = organizationName
    self.jobTitle = jobTitle
    self.emailAddress = emailAddress
    self.phoneNumber = phoneNumber
    self.emailLabel = emailLabel
    self.phoneLabel = phoneLabel
    self.clearOrganization = clearOrganization
    self.clearJobTitle = clearJobTitle
    self.clearEmail = clearEmail
    self.clearPhone = clearPhone
  }

  var hasChanges: Bool {
    givenName != nil
      || familyName != nil
      || organizationName != nil
      || jobTitle != nil
      || emailAddress != nil
      || phoneNumber != nil
      || clearOrganization
      || clearJobTitle
      || clearEmail
      || clearPhone
  }
}
