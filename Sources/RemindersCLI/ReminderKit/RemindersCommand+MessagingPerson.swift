import AppKit
import Contacts
import Darwin
import Dispatch
import Foundation
import ReminderKit
import ReminderKitInternal
import UniformTypeIdentifiers
import Utility

enum ReminderMessagingPersonWriter {
  static let capability = "messaging_person_reminders"

  static func preflight(reminderID: String?) throws {
    let missing = missingRequirements()
    guard missing.isEmpty else {
      throw reminderKitMethodUnavailable(capability: capability, missing: missing)
    }
    guard let reminderID else {
      return
    }
    _ = try fetchReminder(reminderID: reminderID, operation: "preflight")
  }

  static func setMessagingPerson(reminderID: String, personSelector: String?) throws {
    try preflight(reminderID: nil)
    let operation = personSelector == nil ? "clear" : "set"
    let resolved = try fetchReminder(reminderID: reminderID, operation: operation)
    if personSelector != nil {
      try validatePersonTriggersSupported(
        reminder: resolved.reminder,
        operation: operation,
        details: ["reminder_id": reminderID]
      )
    }
    guard let saveRequest = REMSaveRequest(store: resolved.store) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save request could not be created.",
        details: ["reminder_id": reminderID]
      )
    }
    guard let changeItem = saveRequest.updateReminder(resolved.reminder) as? REMReminderChangeItem
    else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit reminder change item could not be updated.",
        details: ["reminder_id": reminderID]
      )
    }

    if let personSelector {
      let handles = try ReminderMessagingContactResolver.resolve(selector: personSelector)
      try setContactHandles(
        REMContactRepresentation(
          phones: handles.phones,
          emails: handles.emails
        ),
        on: changeItem,
        operation: operation,
        details: [
          "reminder_id": reminderID,
          "person_selector": personSelector,
        ]
      )
    } else {
      try setContactHandles(
        nil,
        on: changeItem,
        operation: operation,
        details: ["reminder_id": reminderID]
      )
    }

    var saveError: AnyObject?
    guard saveRequest.saveSynchronouslyWithError(&saveError) else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit save failed.",
        details: [
          "reminder_id": reminderID,
          "person_selector": personSelector ?? "",
          "save_error": saveError.map(String.init(describing:)) ?? "",
        ]
      )
    }
  }

  private static func validatePersonTriggersSupported(
    reminder: Any,
    operation: String,
    details: [String: String]
  ) throws {
    guard let reminder = reminder as? REMReminder,
      let account = reminder.account,
      let capabilities = account.capabilities
    else {
      return
    }
    guard capabilities.supportsPersonTrigger else {
      throw CLIError(
        code: .validationError,
        message: "The selected Reminders account does not support When Messaging triggers.",
        details: details.merging(["operation": operation], uniquingKeysWith: { _, new in new })
      )
    }
  }

  private static func fetchReminder(
    reminderID: String,
    operation: String
  ) throws -> (store: REMStore, reminder: Any) {
    guard let store = REMStore() else {
      throw reminderKitOperationFailed(
        capability: capability,
        operation: operation,
        message: "ReminderKit store could not be created.",
        details: ["reminder_id": reminderID]
      )
    }

    var fetchError: AnyObject?
    let externalReminder = store.fetchReminder(
      withDACalendarItemUniqueIdentifier: reminderID,
      inList: nil,
      error: &fetchError
    )
    if let externalReminder {
      return (store, externalReminder)
    }

    if let objectID = remObjectID(entity: "REMCDReminder", identifier: reminderID),
      let reminder = store.fetchReminder(
        withObjectID: objectID, fetchOptions: nil, error: &fetchError)
    {
      return (store, reminder)
    }

    throw reminderKitOperationFailed(
      capability: capability,
      operation: operation,
      message: "ReminderKit could not fetch the reminder by external or ReminderKit identifier.",
      details: [
        "reminder_id": reminderID,
        "fetch_error": fetchError.map(String.init(describing:)) ?? "",
      ]
    )
  }

  private static func remObjectID(entity: String, identifier: String) -> REMObjectID? {
    let urlString =
      identifier.hasPrefix("x-apple-reminderkit://")
      ? identifier
      : "x-apple-reminderkit://\(entity)/\(identifier)"
    guard let url = URL(string: urlString) else {
      return nil
    }
    return REMObjectID.objectID(withURL: url) as? REMObjectID
  }

  private static func setContactHandles(
    _ handles: REMContactRepresentation?,
    on changeItem: REMReminderChangeItem,
    operation: String,
    details: [String: String]
  ) throws {
    guard changeItem.responds(to: NSSelectorFromString("setContactHandles:")) else {
      throw reminderKitMethodUnavailable(
        capability: capability,
        missing: ["REMReminderChangeItem.setContactHandles:"],
        details: details.merging(
          ["operation": operation],
          uniquingKeysWith: { _, new in new }
        )
      )
    }
    changeItem.contactHandles = handles
  }

  private static func missingRequirements() -> [String] {
    let requirements: [(String, Bool)] = [
      ("REMStore", NSClassFromString("REMStore") != nil),
      ("REMSaveRequest", NSClassFromString("REMSaveRequest") != nil),
      ("REMObjectID", NSClassFromString("REMObjectID") != nil),
      ("REMReminder", NSClassFromString("REMReminder") != nil),
      ("REMReminderChangeItem", NSClassFromString("REMReminderChangeItem") != nil),
      ("REMContactRepresentation", NSClassFromString("REMContactRepresentation") != nil),
      (
        "REMObjectID.objectIDWithURL:",
        REMObjectID.responds(to: NSSelectorFromString("objectIDWithURL:"))
      ),
      (
        "REMStore.fetchReminderWithDACalendarItemUniqueIdentifier:inList:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withDACalendarItemUniqueIdentifier:inList:error:))
        )
      ),
      (
        "REMStore.fetchReminderWithObjectID:fetchOptions:error:",
        REMStore.instancesRespond(
          to: #selector(REMStore.fetchReminder(withObjectID:fetchOptions:error:))
        )
      ),
      (
        "REMSaveRequest.updateReminder:",
        REMSaveRequest.instancesRespond(to: #selector(REMSaveRequest.updateReminder(_:)))
      ),
      (
        "REMSaveRequest.saveSynchronouslyWithError:",
        REMSaveRequest.instancesRespond(to: NSSelectorFromString("saveSynchronouslyWithError:"))
      ),
      (
        "REMContactRepresentation.initWithPhones:emails:",
        REMContactRepresentation.instancesRespond(
          to: NSSelectorFromString("initWithPhones:emails:")
        )
      ),
      (
        "REMAccountCapabilities.supportsPersonTrigger",
        REMAccountCapabilities.instancesRespond(to: NSSelectorFromString("supportsPersonTrigger"))
      ),
    ]
    return requirements.compactMap { name, available in available ? nil : name }
  }
}

private struct ReminderMessagingContactHandles {
  var phones: [String]
  var emails: [String]
}

private enum ReminderMessagingContactResolver {
  static func resolve(selector: String) throws -> ReminderMessagingContactHandles {
    let selector = selector.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !selector.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "`--messaging-person` must not be empty."
      )
    }

    if isEmail(selector) {
      return ReminderMessagingContactHandles(phones: [], emails: [selector])
    }
    if isPhoneLike(selector) {
      return ReminderMessagingContactHandles(phones: [selector], emails: [])
    }

    let store = try contactsStoreWithReadAccess()
    let keys: [CNKeyDescriptor] = [
      CNContactIdentifierKey as CNKeyDescriptor,
      CNContactGivenNameKey as CNKeyDescriptor,
      CNContactFamilyNameKey as CNKeyDescriptor,
      CNContactOrganizationNameKey as CNKeyDescriptor,
      CNContactEmailAddressesKey as CNKeyDescriptor,
      CNContactPhoneNumbersKey as CNKeyDescriptor,
    ]
    let request = CNContactFetchRequest(keysToFetch: keys)
    var exactMatches: [CNContact] = []
    var containsMatches: [CNContact] = []
    try store.enumerateContacts(with: request) { contact, _ in
      let terms = matchTerms(contact)
      if contact.identifier == selector
        || terms.contains(where: {
          normalizedLookup($0) == normalizedLookup(selector)
        })
      {
        exactMatches.append(contact)
      } else if terms.contains(where: { normalizedLookup($0).contains(normalizedLookup(selector)) })
      {
        containsMatches.append(contact)
      }
    }

    let matches = uniqueContacts(exactMatches.isEmpty ? containsMatches : exactMatches)
    guard matches.count == 1, let match = matches.first else {
      throw CLIError(
        code: matches.isEmpty ? .notFound : .ambiguousIdentity,
        message: matches.isEmpty
          ? "Messaging contact selector did not match any contact."
          : "Messaging contact selector matched multiple contacts.",
        details: ["selector": selector, "match_count": "\(matches.count)"]
      )
    }

    let handles = ReminderMessagingContactHandles(
      phones: match.phoneNumbers.map { $0.value.stringValue },
      emails: match.emailAddresses.map { String($0.value) }
    )
    guard !handles.phones.isEmpty || !handles.emails.isEmpty else {
      throw CLIError(
        code: .validationError,
        message: "Messaging contact must have at least one phone number or email address.",
        details: ["selector": selector, "contact_id": match.identifier]
      )
    }
    return handles
  }

  private static func contactsStoreWithReadAccess() throws -> CNContactStore {
    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized:
      return CNContactStore()
    case .notDetermined:
      return try requestContactsAccess(
        deniedMessage: CLIPermissionWording.accessNotGranted(
          "Contacts",
          operation: "When Messaging reminder contact lookup"
        )
      )
    case .denied, .restricted:
      throw CLIError(
        code: .permissionDenied,
        message: CLIPermissionWording.accessDeniedOrRestricted(
          "Contacts",
          operation: "When Messaging reminder contact lookup"
        )
      )
    @unknown default:
      throw CLIError(
        code: .permissionDenied,
        message: CLIPermissionWording.accessStatusUnknown("Contacts")
      )
    }
  }

  private static func requestContactsAccess(deniedMessage: String) throws -> CNContactStore {
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
        details: ["error": String(describing: error)]
      )
    }
    guard result.granted else {
      throw CLIError(code: .permissionDenied, message: deniedMessage)
    }
    return store
  }

  private static func matchTerms(_ contact: CNContact) -> [String] {
    [
      contact.identifier,
      contact.givenName,
      contact.familyName,
      [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " "),
      contact.organizationName,
    ]
      + contact.emailAddresses.map { String($0.value) }
      + contact.phoneNumbers.map { $0.value.stringValue }
  }

  private static func uniqueContacts(_ contacts: [CNContact]) -> [CNContact] {
    var seen: Set<String> = []
    var result: [CNContact] = []
    for contact in contacts where !seen.contains(contact.identifier) {
      seen.insert(contact.identifier)
      result.append(contact)
    }
    return result
  }

  private static func normalizedLookup(_ value: String) -> String {
    value
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
      .lowercased()
  }

  private static func isEmail(_ value: String) -> Bool {
    value.contains("@") && value.contains(".") && !value.contains(" ")
  }

  private static func isPhoneLike(_ value: String) -> Bool {
    let digits = value.filter(\.isNumber)
    return digits.count >= 5
      && value.allSatisfy { character in
        character.isNumber || "+-() .".contains(character)
      }
  }
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
