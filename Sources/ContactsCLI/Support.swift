import Contacts
import Foundation
import Utility

struct ContactMutationIdentity {
  var contact: ContactDetail
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ContactGroupMutationIdentity {
  var group: ContactGroupRecord
  var contact: ContactDetail
  var isMember: Bool
  var scopeDigest: String
  var summaryFields: [String: String]
}

struct ContactDuplicateBucket {
  var value: String
  var contactIDs: Set<String> = []
  var contacts: [ContactSummary] = []
}

struct ContactDuplicateCandidate {
  var key: String
  var value: String
}

func validateGroupMembershipChange(_ identity: ContactGroupMutationIdentity, adding: Bool) throws {
  if adding, identity.isMember {
    throw CLIError(
      code: .validationError,
      message: "Contact is already a member of the group.",
      details: ["group_id": identity.group.id, "contact_id": identity.contact.id]
    )
  }

  if !adding, !identity.isMember {
    throw CLIError(
      code: .validationError,
      message: "Contact is not a member of the group.",
      details: ["group_id": identity.group.id, "contact_id": identity.contact.id]
    )
  }
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateMutationIntent(_ options: CLIOptions) throws {}

func validateExportIntent(_ options: CLIOptions) throws {}

func validateTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String>,
  allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(unknownFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` is required."
    )
  }

  return value
}

func duplicateField(_ options: CLIOptions) throws -> String {
  let field = try requiredOption("field", options: options)
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
  guard ["email", "phone", "name"].contains(field) else {
    throw CLIError(
      code: .validationError,
      message: "`--field` must be email, phone, or name.",
      details: ["field": field]
    )
  }
  return field
}

func contactExportFormat(_ options: CLIOptions) throws -> String {
  let format = try requiredOption("format", options: options)
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
  guard format == "vcard" else {
    throw CLIError(
      code: .validationError,
      message: "`--format` must be vcard.",
      details: ["format": format]
    )
  }
  return format
}

enum ContactExportSelection {
  case single(String)
  case explicitIDs([String])
  case all(Int)
}

enum ContactDeleteSelection {
  case single
  case explicitIDs([String])
}

struct ContactImportSource {
  var path: String
  var data: Data
  var modifiedAt: Date?
}

func contactExportSelection(_ options: CLIOptions) throws -> ContactExportSelection {
  let hasID = options.targetOption("id") != nil
  let hasIDs = options.targetOption("ids") != nil
  let hasAll = options.hasTargetFlag("all")
  let selectorCount = [hasID, hasIDs, hasAll].filter { $0 }.count
  guard selectorCount == 1 else {
    throw CLIError(
      code: .validationError,
      message: "Exactly one of `--id`, `--ids`, or `--all` is required for contact export."
    )
  }

  if hasAll {
    guard options.limit != nil else {
      throw CLIError(
        code: .validationError,
        message: "`--all` contact export requires an explicit `--limit` cap."
      )
    }
    return .all(try commandLimit(options))
  }

  let rawIDs: [String]
  if hasID {
    rawIDs = [try requiredOption("id", options: options)]
  } else {
    rawIDs = try requiredOption("ids", options: options)
      .split(separator: ",", omittingEmptySubsequences: false)
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  }

  let ids = rawIDs.filter { !$0.isEmpty }
  guard ids.count == rawIDs.count, !ids.isEmpty else {
    throw CLIError(code: .validationError, message: "`--ids` must contain non-empty contact IDs.")
  }
  guard ids.count <= 100 else {
    throw CLIError(
      code: .validationError, message: "`--ids` cannot contain more than 100 contacts.")
  }
  var seen: Set<String> = []
  for id in ids where !seen.insert(id).inserted {
    throw CLIError(
      code: .validationError, message: "`--ids` must not contain duplicate contact IDs.",
      details: ["id": id])
  }
  if hasID {
    return .single(ids[0])
  }
  return .explicitIDs(ids)
}

func contactDeleteSelection(_ options: CLIOptions) throws -> ContactDeleteSelection {
  let hasID = options.targetOption("id") != nil
  let hasIDs = options.targetOption("ids") != nil
  let selectorCount = [hasID, hasIDs].filter { $0 }.count
  guard selectorCount == 1 else {
    throw CLIError(
      code: .validationError,
      message: "Exactly one of `--id` or `--ids` is required for contact delete."
    )
  }

  if hasID {
    _ = try requiredOption("id", options: options)
    return .single
  }

  let rawIDs = try requiredOption("ids", options: options)
    .split(separator: ",", omittingEmptySubsequences: false)
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  let ids = rawIDs.filter { !$0.isEmpty }
  guard ids.count == rawIDs.count, !ids.isEmpty else {
    throw CLIError(code: .validationError, message: "`--ids` must contain non-empty contact IDs.")
  }
  guard ids.count <= 100 else {
    throw CLIError(
      code: .validationError, message: "`--ids` cannot contain more than 100 contacts.")
  }
  var seen: Set<String> = []
  for id in ids where !seen.insert(id).inserted {
    throw CLIError(
      code: .validationError, message: "`--ids` must not contain duplicate contact IDs.",
      details: ["id": id])
  }
  return .explicitIDs(ids)
}

func contactDeleteMatchingQuery(_ options: CLIOptions) throws -> String {
  let query = try requiredOption("query", options: options)
    .trimmingCharacters(in: .whitespacesAndNewlines)
  guard query.count >= 3 else {
    throw CLIError(
      code: .validationError,
      message:
        "`contacts delete-matching` requires `--query` with at least 3 non-whitespace characters."
    )
  }
  return query
}

func contactDeleteMatchingLimit(_ options: CLIOptions) throws -> Int {
  guard let limit = options.limit else {
    throw CLIError(
      code: .validationError,
      message: "`contacts delete-matching` requires an explicit `--limit` cap."
    )
  }
  guard limit <= 25 else {
    throw CLIError(
      code: .validationError,
      message: "`--limit` cannot exceed 25 for contact delete-matching."
    )
  }
  return limit
}

func contactImportLimit(_ options: CLIOptions) throws -> Int {
  guard let limit = options.limit else {
    throw CLIError(
      code: .validationError, message: "Contact import requires an explicit `--limit` cap.")
  }
  guard limit <= 100 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 100 for contact import.")
  }
  return limit
}

func contactImportDuplicatePolicy(_ options: CLIOptions) throws -> ContactImportDuplicatePolicy {
  guard
    let rawPolicy = try normalizedOption(options.targetOption("on-duplicate"), name: "on-duplicate")
  else {
    throw CLIError(
      code: .validationError,
      message: "`contacts import` requires explicit `--on-duplicate create-new|fail|skip-existing`."
    )
  }
  guard let policy = ContactImportDuplicatePolicy(rawValue: rawPolicy.lowercased()) else {
    throw CLIError(
      code: .validationError,
      message: "`--on-duplicate` must be create-new, fail, or skip-existing."
    )
  }
  return policy
}

func contactImportSource(path: String) throws -> ContactImportSource {
  let absolutePath = standardizedAbsolutePath(path)
  let url = URL(fileURLWithPath: absolutePath).standardizedFileURL
  let attributes: [FileAttributeKey: Any]
  do {
    attributes = try FileManager.default.attributesOfItem(atPath: url.path)
  } catch {
    throw CLIError(
      code: .notFound, message: "vCard import file was not found.", details: ["path": url.path])
  }

  guard attributes[.type] as? FileAttributeType == .typeRegular else {
    throw CLIError(
      code: .validationError, message: "`--file` must reference a regular vCard file.",
      details: ["path": url.path])
  }
  guard ["vcf", "vcard"].contains(url.pathExtension.lowercased()) else {
    throw CLIError(
      code: .validationError, message: "`--file` must end in `.vcf` or `.vcard`.",
      details: ["path": url.path])
  }

  let data = try Data(contentsOf: url)
  guard data.count <= 1_000_000 else {
    throw CLIError(
      code: .validationError, message: "vCard import files must be 1 MB or smaller.",
      details: ["path": url.path])
  }
  guard !data.isEmpty else {
    throw CLIError(
      code: .validationError, message: "vCard import file must not be empty.",
      details: ["path": url.path])
  }

  return ContactImportSource(
    path: url.path,
    data: data,
    modifiedAt: attributes[.modificationDate] as? Date
  )
}

func normalizedOption(_ value: String?, name: String) throws -> String? {
  guard let value else {
    return nil
  }

  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` must not be empty.")
  }

  return trimmed
}

func normalizedEmail(_ value: String?) throws -> String? {
  guard let email = try normalizedOption(value, name: "email") else {
    return nil
  }

  guard email.contains("@") else {
    throw CLIError(code: .validationError, message: "`--email` must look like an email address.")
  }

  return email
}

enum ContactLabeledFieldKind: Equatable {
  case email
  case phone
}

func contactFieldLabel(_ value: String?, kind: ContactLabeledFieldKind) throws -> String? {
  guard let raw = try normalizedOption(value, name: kind == .email ? "email-label" : "phone-label")
  else {
    return nil
  }
  let normalized = raw.lowercased()
  let allowed: Set<String> =
    kind == .email
    ? ["home", "work", "other"]
    : [
      "home", "work", "mobile", "iphone", "main", "other", "home-fax", "work-fax", "other-fax",
      "pager",
    ]
  guard allowed.contains(normalized) else {
    throw CLIError(
      code: .validationError,
      message:
        "`--\(kind == .email ? "email-label" : "phone-label")` must be one of \(allowed.sorted().joined(separator: ", "))."
    )
  }
  return normalized
}

func contactsLabelConstant(_ label: String) -> String {
  switch label {
  case "home": return CNLabelHome
  case "work": return CNLabelWork
  case "other": return CNLabelOther
  case "mobile": return CNLabelPhoneNumberMobile
  case "iphone": return CNLabelPhoneNumberiPhone
  case "main": return CNLabelPhoneNumberMain
  case "home-fax": return CNLabelPhoneNumberHomeFax
  case "work-fax": return CNLabelPhoneNumberWorkFax
  case "other-fax": return CNLabelPhoneNumberOtherFax
  case "pager": return CNLabelPhoneNumberPager
  default: return label
  }
}

func contactsLabelName(_ label: String?) -> String {
  switch label {
  case CNLabelHome: return "home"
  case CNLabelWork: return "work"
  case CNLabelOther: return "other"
  case CNLabelPhoneNumberMobile: return "mobile"
  case CNLabelPhoneNumberiPhone: return "iphone"
  case CNLabelPhoneNumberMain: return "main"
  case CNLabelPhoneNumberHomeFax: return "home-fax"
  case CNLabelPhoneNumberWorkFax: return "work-fax"
  case CNLabelPhoneNumberOtherFax: return "other-fax"
  case CNLabelPhoneNumberPager: return "pager"
  case .some(let label): return label
  case .none: return ""
  }
}

func contactCreateScopeDigest(_ draft: ContactCreateDraft) -> String {
  let payload = [
    draft.givenName,
    draft.familyName,
    draft.organizationName ?? "",
    draft.jobTitle ?? "",
    draft.emailAddress ?? "",
    draft.phoneNumber ?? "",
    draft.emailLabel ?? "",
    draft.phoneLabel ?? "",
  ].joined(separator: "|")
  return "contact-create:\(sha256Hex(payload))"
}

func contactIdentityScopeDigest(_ contact: ContactDetail) -> String {
  let payload = [
    contact.id,
    contact.displayName,
    contact.givenName,
    contact.familyName,
    contact.organizationName ?? "",
    contact.jobTitle ?? "",
    contactLabeledScopeDigest(values: contact.emailAddresses, labels: contact.emailLabels),
    contactLabeledScopeDigest(values: contact.phoneNumbers, labels: contact.phoneLabels),
  ].joined(separator: "|")
  return "contact:\(sha256Hex(payload))"
}

func contactLabeledScopeDigest(values: [String], labels: [String]) -> String {
  values.enumerated()
    .map { index, value in
      let label = index < labels.count ? labels[index] : ""
      return "\(label)=\(value)"
    }
    .joined(separator: ",")
}

func contactUpdateScopeDigest(current: ContactDetail, patch: ContactPatch) -> String {
  let payload = [
    contactIdentityScopeDigest(current),
    patch.givenName ?? "",
    patch.familyName ?? "",
    patch.organizationName ?? "",
    patch.jobTitle ?? "",
    patch.emailAddress ?? "",
    patch.phoneNumber ?? "",
    patch.emailLabel ?? "",
    patch.phoneLabel ?? "",
    "\(patch.clearOrganization)",
    "\(patch.clearJobTitle)",
    "\(patch.clearEmail)",
    "\(patch.clearPhone)",
  ].joined(separator: "|")
  return "contact-update:\(sha256Hex(payload))"
}

func contactBulkDeleteIdentityHash(contacts: [ContactDetail]) -> String {
  sha256Hex(contacts.map(contactIdentityScopeDigest).joined(separator: ","))
}

func contactBulkDeleteScopeDigest(contacts: [ContactDetail]) -> String {
  let payload = [
    contacts.map(\.id).joined(separator: ","),
    contactBulkDeleteIdentityHash(contacts: contacts),
  ].joined(separator: "|")
  return "contact-delete-many:\(sha256Hex(payload))"
}

func contactDeleteMatchingScopeDigest(query: String, limit: Int, contacts: [ContactDetail]) -> String {
  let payload = [
    query,
    "\(limit)",
    contacts.map(\.id).joined(separator: ","),
    contactBulkDeleteIdentityHash(contacts: contacts),
  ].joined(separator: "|")
  return "contact-delete-matching:\(sha256Hex(payload))"
}

func groupMembershipScopeDigest(group: ContactGroupRecord, contact: ContactDetail, isMember: Bool)
  -> String
{
  let payload = [
    group.id,
    group.name,
    contactIdentityScopeDigest(contact),
    "\(isMember)",
  ].joined(separator: "|")
  return "contact-group-membership:\(sha256Hex(payload))"
}

func contactExportScopeDigest(
  contact: ContactDetail,
  data: Data,
  format: String,
  destinationPath: String
) -> String {
  let payload = [
    contactIdentityScopeDigest(contact),
    format,
    destinationPath,
    sha256Hex(data),
  ].joined(separator: "|")
  return "contact-export:\(sha256Hex(payload))"
}

func contactBulkExportScopeDigest(
  payloads: [ContactExportPayload],
  data: Data,
  format: String,
  destinationPath: String
) -> String {
  let payload = [
    payloads.map { contactIdentityScopeDigest($0.contact) }.joined(separator: ","),
    format,
    destinationPath,
    sha256Hex(data),
  ].joined(separator: "|")
  return "contact-export-many:\(sha256Hex(payload))"
}

func contactImportScopeDigest(
  source: ContactImportSource,
  preview: ContactImportPreview,
  format: String,
  limit: Int
) -> String {
  let payload = [
    source.path,
    "\(source.data.count)",
    source.modifiedAt.map { "\($0.timeIntervalSince1970)" } ?? "",
    sha256Hex(source.data),
    format,
    "\(limit)",
    preview.duplicatePolicy.rawValue,
    "\(preview.contacts.count)",
    "\(preview.importableCount)",
    "\(preview.skippedCount)",
    contactImportIdentityHash(preview.contacts),
    contactImportDuplicateHash(preview.duplicates),
  ].joined(separator: "|")
  return "contact-import:\(sha256Hex(payload))"
}

func contactCreateSummary(_ draft: ContactCreateDraft) -> [String: String] {
  [
    "given_name": draft.givenName,
    "family_name": draft.familyName,
    "organization": draft.organizationName ?? "",
    "email": draft.emailAddress ?? "",
    "phone": draft.phoneNumber ?? "",
    "email_label": draft.emailLabel ?? "",
    "phone_label": draft.phoneLabel ?? "",
  ]
}

func contactUpdateSummary(current: ContactDetail, patch: ContactPatch) -> [String: String] {
  var summary = [
    "id": current.id,
    "display_name": current.displayName,
  ]
  if let givenName = patch.givenName {
    summary["new_given_name"] = givenName
  }
  if let familyName = patch.familyName {
    summary["new_family_name"] = familyName
  }
  if let organizationName = patch.organizationName {
    summary["new_organization"] = organizationName
  }
  if let jobTitle = patch.jobTitle {
    summary["new_job_title"] = jobTitle
  }
  if let emailAddress = patch.emailAddress {
    summary["new_email"] = emailAddress
  }
  if let emailLabel = patch.emailLabel {
    summary["email_label"] = emailLabel
  }
  if let phoneNumber = patch.phoneNumber {
    summary["new_phone"] = phoneNumber
  }
  if let phoneLabel = patch.phoneLabel {
    summary["phone_label"] = phoneLabel
  }
  if patch.clearOrganization {
    summary["clear_organization"] = "true"
  }
  if patch.clearJobTitle {
    summary["clear_job_title"] = "true"
  }
  if patch.clearEmail {
    summary["clear_email"] = "true"
  }
  if patch.clearPhone {
    summary["clear_phone"] = "true"
  }
  return summary
}

func contactBulkDeleteSummary(contacts: [ContactDetail]) -> [String: String] {
  [
    "ids": contacts.map(\.id).joined(separator: ","),
    "contact_count": "\(contacts.count)",
    "identity_hash": contactBulkDeleteIdentityHash(contacts: contacts),
  ]
}

func contactDeleteMatchingSummary(query: String, limit: Int, contacts: [ContactDetail]) -> [String:
  String]
{
  [
    "query": query,
    "limit": "\(limit)",
    "ids": contacts.map(\.id).joined(separator: ","),
    "contact_count": "\(contacts.count)",
    "identity_hash": contactBulkDeleteIdentityHash(contacts: contacts),
  ]
}

func contactExportSummary(
  contact: ContactDetail,
  data: Data,
  format: String,
  destinationPath: String
) -> [String: String] {
  [
    "id": contact.id,
    "display_name": contact.displayName,
    "format": format,
    "destination_path": destinationPath,
    "byte_count": "\(data.count)",
    "vcard_sha256": sha256Hex(data),
  ]
}

func contactBulkExportSummary(
  payloads: [ContactExportPayload],
  data: Data,
  format: String,
  destinationPath: String
) -> [String: String] {
  let ids = payloads.map(\.contact.id)
  return [
    "ids": ids.joined(separator: ","),
    "contact_count": "\(payloads.count)",
    "format": format,
    "destination_path": destinationPath,
    "byte_count": "\(data.count)",
    "vcard_sha256": sha256Hex(data),
  ]
}

func contactImportSummary(
  source: ContactImportSource,
  preview: ContactImportPreview,
  format: String,
  limit: Int
) -> [String: String] {
  [
    "source_path": source.path,
    "source_byte_count": "\(source.data.count)",
    "source_sha256": sha256Hex(source.data),
    "format": format,
    "limit": "\(limit)",
    "on_duplicate": preview.duplicatePolicy.rawValue,
    "contact_count": "\(preview.contacts.count)",
    "importable_count": "\(preview.importableCount)",
    "skipped_count": "\(preview.skippedCount)",
    "duplicate_count": "\(preview.duplicates.count)",
    "contact_identity_hash": contactImportIdentityHash(preview.contacts),
    "duplicate_identity_hash": contactImportDuplicateHash(preview.duplicates),
  ]
}

func contactExportData(_ payloads: [ContactExportPayload]) -> Data {
  payloads.reduce(into: Data()) { result, payload in
    result.append(payload.data)
  }
}

func contactImportIdentityHash(_ contacts: [ContactDetail]) -> String {
  let payload = contacts.map { contact in
    [
      contact.displayName,
      contact.givenName,
      contact.familyName,
      contact.organizationName ?? "",
      contact.jobTitle ?? "",
      contact.emailAddresses.joined(separator: ","),
      contact.phoneNumbers.joined(separator: ","),
    ].joined(separator: "|")
  }.joined(separator: "\n")
  return sha256Hex(payload)
}

func contactImportDuplicateHash(_ duplicates: [ContactImportDuplicate]) -> String {
  let payload =
    duplicates
    .sorted {
      if $0.importedIndex == $1.importedIndex {
        if $0.matchKind == $1.matchKind {
          return $0.existingID < $1.existingID
        }
        return $0.matchKind < $1.matchKind
      }
      return $0.importedIndex < $1.importedIndex
    }
    .map { duplicate in
      [
        "\(duplicate.importedIndex)",
        duplicate.existingID,
        duplicate.matchKind,
        duplicate.matchValueHash,
      ].joined(separator: "|")
    }
    .joined(separator: "\n")
  return sha256Hex(payload)
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 50
  guard limit <= 500 else {
    throw CLIError(
      code: .validationError,
      message: "`--limit` cannot exceed 500 for Contacts commands."
    )
  }
  return limit
}

func parseVCardContactDetails(data: Data, limit: Int) throws -> [ContactDetail] {
  try parseVCardContacts(data: data, limit: limit).map(contactDetail)
}

func parseVCardContacts(data: Data, limit: Int) throws -> [CNContact] {
  let contacts: [CNContact]
  do {
    contacts = try CNContactVCardSerialization.contacts(with: data)
  } catch {
    throw CLIError(
      code: .validationError,
      message: "vCard import file could not be parsed.",
      details: CLIError.diagnosticDetails(for: error)
    )
  }

  guard !contacts.isEmpty else {
    throw CLIError(code: .validationError, message: "vCard import file did not contain contacts.")
  }
  guard contacts.count <= limit else {
    throw CLIError(
      code: .validationError,
      message: "vCard import file contains more contacts than `--limit`.",
      details: ["limit": "\(limit)", "contact_count": "\(contacts.count)"]
    )
  }
  return contacts
}

func contactStoreWithReadAccess() throws -> CNContactStore {
  switch CNContactStore.authorizationStatus(for: .contacts) {
  case .authorized:
    return CNContactStore()
  case .notDetermined:
    return try requestContactsAccess(
      deniedMessage: CLIPermissionWording.accessNotGranted(
        "Contacts", operation: "read/search commands"))
  case .denied, .restricted:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted(
        "Contacts", operation: "read/search commands")
    )
  @unknown default:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessStatusUnknown("Contacts")
    )
  }
}

func contactStoreWithWriteAccess() throws -> CNContactStore {
  switch CNContactStore.authorizationStatus(for: .contacts) {
  case .authorized:
    return CNContactStore()
  case .notDetermined:
    return try requestContactsAccess(
      deniedMessage: CLIPermissionWording.accessNotGranted(
        "Contacts", operation: "mutation commands"))
  case .denied, .restricted:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted(
        "Contacts", operation: "mutation commands")
    )
  @unknown default:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessStatusUnknown("Contacts")
    )
  }
}

func requestContactsAccess(deniedMessage: String) throws -> CNContactStore {
  let store = CNContactStore()
  let box = ContactsAccessRequestBox()
  let semaphore = DispatchSemaphore(value: 0)

  store.requestAccess(for: .contacts) { granted, error in
    box.store(granted: granted, error: error)
    semaphore.signal()
  }

  guard semaphore.wait(timeout: .now() + .seconds(60)) == .success else {
    throw CLIError(
      code: .timeout,
      message: CLIPermissionWording.accessRequestTimedOut("Contacts")
    )
  }

  let result = box.take()
  if let error = result.error {
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessRequestFailed("Contacts"),
      details: CLIError.diagnosticDetails(for: error)
    )
  }
  guard result.granted else {
    throw CLIError(code: .permissionDenied, message: deniedMessage)
  }

  return store
}

private final class ContactsAccessRequestBox: @unchecked Sendable {
  private let lock = NSLock()
  private var granted = false
  private var error: Error?

  func store(granted: Bool, error: Error?) {
    lock.lock()
    self.granted = granted
    self.error = error
    lock.unlock()
  }

  func take() -> (granted: Bool, error: Error?) {
    lock.lock()
    let result = (granted, error)
    lock.unlock()
    return result
  }
}

func applyDraft(_ draft: ContactCreateDraft, to contact: CNMutableContact) {
  contact.givenName = draft.givenName
  contact.familyName = draft.familyName
  contact.organizationName = draft.organizationName ?? ""
  contact.jobTitle = draft.jobTitle ?? ""
  if let emailAddress = draft.emailAddress {
    contact.emailAddresses = [
      CNLabeledValue(
        label: contactsLabelConstant(draft.emailLabel ?? "work"), value: emailAddress as NSString)
    ]
  }
  if let phoneNumber = draft.phoneNumber {
    contact.phoneNumbers = [
      CNLabeledValue(
        label: contactsLabelConstant(draft.phoneLabel ?? "mobile"),
        value: CNPhoneNumber(stringValue: phoneNumber)
      )
    ]
  }
}

func applyPatch(_ patch: ContactPatch, to contact: CNMutableContact) throws {
  if let givenName = patch.givenName {
    contact.givenName = givenName
  }
  if let familyName = patch.familyName {
    contact.familyName = familyName
  }
  if let organizationName = patch.organizationName {
    contact.organizationName = organizationName
  } else if patch.clearOrganization {
    contact.organizationName = ""
  }
  if let jobTitle = patch.jobTitle {
    contact.jobTitle = jobTitle
  } else if patch.clearJobTitle {
    contact.jobTitle = ""
  }
  if let emailAddress = patch.emailAddress {
    if let emailLabel = patch.emailLabel {
      contact.emailAddresses = try replaceSingleLabeledEmail(
        in: contact.emailAddresses,
        label: emailLabel,
        value: emailAddress
      )
    } else {
      contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: emailAddress as NSString)]
    }
  } else if patch.clearEmail {
    if let emailLabel = patch.emailLabel {
      contact.emailAddresses = contact.emailAddresses.filter {
        contactsLabelName($0.label) != emailLabel
      }
    } else {
      contact.emailAddresses = []
    }
  }
  if let phoneNumber = patch.phoneNumber {
    if let phoneLabel = patch.phoneLabel {
      contact.phoneNumbers = try replaceSingleLabeledPhone(
        in: contact.phoneNumbers,
        label: phoneLabel,
        value: phoneNumber
      )
    } else {
      contact.phoneNumbers = [
        CNLabeledValue(
          label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phoneNumber))
      ]
    }
  } else if patch.clearPhone {
    if let phoneLabel = patch.phoneLabel {
      contact.phoneNumbers = contact.phoneNumbers.filter {
        contactsLabelName($0.label) != phoneLabel
      }
    } else {
      contact.phoneNumbers = []
    }
  }
}

func replaceSingleLabeledEmail(
  in values: [CNLabeledValue<NSString>],
  label: String,
  value: String
) throws -> [CNLabeledValue<NSString>] {
  let matches = values.filter { contactsLabelName($0.label) == label }
  guard matches.count <= 1 else {
    throw CLIError(
      code: .ambiguousIdentity,
      message:
        "Multiple email addresses use label `\(label)`; clear or export the contact before changing that label."
    )
  }
  let replacement = CNLabeledValue(label: contactsLabelConstant(label), value: value as NSString)
  guard !matches.isEmpty else {
    return values + [replacement]
  }
  return values.map { contactsLabelName($0.label) == label ? replacement : $0 }
}

func replaceSingleLabeledPhone(
  in values: [CNLabeledValue<CNPhoneNumber>],
  label: String,
  value: String
) throws -> [CNLabeledValue<CNPhoneNumber>] {
  let matches = values.filter { contactsLabelName($0.label) == label }
  guard matches.count <= 1 else {
    throw CLIError(
      code: .ambiguousIdentity,
      message:
        "Multiple phone numbers use label `\(label)`; clear or export the contact before changing that label."
    )
  }
  let replacement = CNLabeledValue(
    label: contactsLabelConstant(label), value: CNPhoneNumber(stringValue: value))
  guard !matches.isEmpty else {
    return values + [replacement]
  }
  return values.map { contactsLabelName($0.label) == label ? replacement : $0 }
}

func contactKeys() -> [CNKeyDescriptor] {
  [
    CNContactIdentifierKey as CNKeyDescriptor,
    CNContactGivenNameKey as CNKeyDescriptor,
    CNContactFamilyNameKey as CNKeyDescriptor,
    CNContactOrganizationNameKey as CNKeyDescriptor,
    CNContactJobTitleKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
  ]
}

func contactImportDuplicates(
  for importedContacts: [ContactDetail],
  store: CNContactStore
) throws -> [ContactImportDuplicate] {
  var existingMatches: [String: Set<String>] = [:]
  let request = CNContactFetchRequest(keysToFetch: contactKeys())
  try store.enumerateContacts(with: request) { contact, _ in
    for candidate in contactImportCandidates(contactDetail(contact)) {
      existingMatches[candidate.key, default: []].insert(contact.identifier)
    }
  }

  var duplicates: [ContactImportDuplicate] = []
  var seen: Set<String> = []
  for (index, contact) in importedContacts.enumerated() {
    for candidate in contactImportCandidates(contact) {
      for existingID in existingMatches[candidate.key, default: []].sorted() {
        let duplicateKey = "\(index)|\(existingID)|\(candidate.kind)|\(candidate.valueHash)"
        guard seen.insert(duplicateKey).inserted else {
          continue
        }
        duplicates.append(
          ContactImportDuplicate(
            importedIndex: index,
            existingID: existingID,
            matchKind: candidate.kind,
            matchValueHash: candidate.valueHash
          )
        )
      }
    }
  }
  return duplicates.sorted {
    if $0.importedIndex == $1.importedIndex {
      if $0.matchKind == $1.matchKind {
        return $0.existingID < $1.existingID
      }
      return $0.matchKind < $1.matchKind
    }
    return $0.importedIndex < $1.importedIndex
  }
}

struct ContactImportMatchCandidate {
  var key: String
  var kind: String
  var valueHash: String
}

func contactImportCandidates(_ contact: ContactDetail) -> [ContactImportMatchCandidate] {
  let emailCandidates = contact.emailAddresses.compactMap { email -> ContactImportMatchCandidate? in
    let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !normalized.isEmpty else {
      return nil
    }
    let key = "email:\(normalized)"
    return ContactImportMatchCandidate(key: key, kind: "email", valueHash: sha256Hex(key))
  }
  let phoneCandidates = contact.phoneNumbers.compactMap { phone -> ContactImportMatchCandidate? in
    let digits = phone.filter(\.isNumber)
    guard !digits.isEmpty else {
      return nil
    }
    let key = "phone:\(digits)"
    return ContactImportMatchCandidate(key: key, kind: "phone", valueHash: sha256Hex(key))
  }
  return emailCandidates + phoneCandidates
}

func vCardContactKeys() -> [CNKeyDescriptor] {
  contactKeys() + [CNContactVCardSerialization.descriptorForRequiredKeys()]
}

func contactMatches(_ contact: CNContact, query: String) -> Bool {
  let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
  let searchable =
    [
      displayName(contact),
      contact.givenName,
      contact.familyName,
      contact.organizationName,
    ] + contact.emailAddresses.map { String($0.value) }
    + contact.phoneNumbers.map { $0.value.stringValue }

  return searchable.contains {
    $0.localizedCaseInsensitiveContains(trimmed)
  }
}

func duplicateCandidates(_ contact: CNContact, field: String) -> [ContactDuplicateCandidate] {
  switch field {
  case "email":
    return contact.emailAddresses.compactMap { value in
      let raw = String(value.value).trimmingCharacters(in: .whitespacesAndNewlines)
      let normalized = raw.lowercased()
      guard normalized.contains("@") else {
        return nil
      }
      return ContactDuplicateCandidate(key: "email:\(normalized)", value: raw)
    }
  case "phone":
    return contact.phoneNumbers.compactMap { value in
      let raw = value.value.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
      let digits = raw.filter(\.isNumber)
      guard digits.count >= 3 else {
        return nil
      }
      return ContactDuplicateCandidate(key: "phone:\(digits)", value: raw)
    }
  case "name":
    let raw = displayName(contact).trimmingCharacters(in: .whitespacesAndNewlines)
    let normalized = normalizedDuplicateName(raw)
    guard normalized.count >= 2 else {
      return []
    }
    return [ContactDuplicateCandidate(key: "name:\(normalized)", value: raw)]
  default:
    return []
  }
}

func normalizedDuplicateName(_ value: String) -> String {
  value
    .split(whereSeparator: { $0.isWhitespace })
    .map { String($0).lowercased() }
    .joined(separator: " ")
}

func contactSummary(_ contact: CNContact) -> ContactSummary {
  ContactSummary(
    id: contact.identifier,
    displayName: displayName(contact),
    organizationName: emptyToNil(contact.organizationName),
    emailAddresses: contact.emailAddresses.map { String($0.value) },
    phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
    emailLabels: contact.emailAddresses.map { contactsLabelName($0.label) },
    phoneLabels: contact.phoneNumbers.map { contactsLabelName($0.label) }
  )
}

func contactDetail(_ contact: CNContact) -> ContactDetail {
  ContactDetail(
    id: contact.identifier,
    displayName: displayName(contact),
    givenName: contact.givenName,
    familyName: contact.familyName,
    organizationName: emptyToNil(contact.organizationName),
    jobTitle: emptyToNil(contact.jobTitle),
    emailAddresses: contact.emailAddresses.map { String($0.value) },
    phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
    emailLabels: contact.emailAddresses.map { contactsLabelName($0.label) },
    phoneLabels: contact.phoneNumbers.map { contactsLabelName($0.label) }
  )
}

func contactGroupRecord(_ group: CNGroup) -> ContactGroupRecord {
  ContactGroupRecord(id: group.identifier, name: group.name)
}

func displayName(_ contact: CNContact) -> String {
  CNContactFormatter.string(from: contact, style: .fullName)
    ?? [contact.givenName, contact.familyName]
    .filter { !$0.isEmpty }
    .joined(separator: " ")
}

func emptyToNil(_ value: String) -> String? {
  value.isEmpty ? nil : value
}

func standardizedAbsolutePath(_ path: String) -> String {
  let expanded = (path as NSString).expandingTildeInPath
  if expanded.hasPrefix("/") {
    return URL(fileURLWithPath: expanded).standardizedFileURL.path
  }

  return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent(expanded)
    .standardizedFileURL
    .path
}

func validateVCardExportDestination(_ destinationPath: String) throws {
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  guard destination.pathExtension.lowercased() == "vcf" else {
    throw CLIError(
      code: .validationError, message: "`--output` must end in `.vcf` for vcard export.",
      details: ["path": destination.path])
  }
  guard !FileManager.default.fileExists(atPath: destination.path) else {
    throw CLIError(
      code: .validationError, message: "Destination path already exists.",
      details: ["path": destination.path])
  }
  let parent = destination.deletingLastPathComponent()
  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory),
    isDirectory.boolValue
  else {
    throw CLIError(
      code: .notFound, message: "Destination parent directory was not found.",
      details: ["path": parent.path])
  }
}

func writeContactExport(_ data: Data, to destinationPath: String) throws {
  try validateVCardExportDestination(destinationPath)
  let destination = URL(fileURLWithPath: destinationPath).standardizedFileURL
  let parent = destination.deletingLastPathComponent()
  let temporary = parent.appendingPathComponent(
    ".\(destination.lastPathComponent).\(UUID().uuidString).tmp")

  do {
    try data.write(to: temporary, options: [.atomic])
    try FileManager.default.moveItem(at: temporary, to: destination)
  } catch {
    try? FileManager.default.removeItem(at: temporary)
    throw error
  }
}

func contactsHumanOutput(_ contacts: [ContactSummary]) -> String {
  contacts
    .map { "\($0.id)\t\($0.displayName)" }
    .joined(separator: "\n")
}

func duplicateGroupsHumanOutput(_ groups: [ContactDuplicateGroup]) -> String {
  guard !groups.isEmpty else {
    return "duplicateGroups: 0"
  }

  return
    groups
    .map { "\($0.field)\t\($0.value)\tmatches=\($0.matchCount)" }
    .joined(separator: "\n")
}

func contactHumanOutput(_ contact: ContactDetail) -> String {
  [
    "id: \(contact.id)",
    "name: \(contact.displayName)",
    "organization: \(contact.organizationName ?? "-")",
  ].joined(separator: "\n")
}

func groupsHumanOutput(_ groups: [ContactGroupRecord]) -> String {
  groups
    .map { "\($0.id)\t\($0.name)" }
    .joined(separator: "\n")
}

func groupMembersHumanOutput(_ response: ContactGroupMembersResponse) -> String {
  let header = "group: \(response.group.name) (\(response.group.id))"
  guard !response.contacts.isEmpty else {
    return "\(header)\nmembers: 0"
  }

  return ([header] + response.contacts.map { "\($0.id)\t\($0.displayName)" })
    .joined(separator: "\n")
}
