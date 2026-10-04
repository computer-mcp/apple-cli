import AppKit
import Contacts
import Foundation
import Utility

func callPreview(_ options: CLIOptions) throws -> FaceTimeCallPreview {
  let handle = try normalizedHandle(requiredOption("handle", options: options))
  let kind = try callKind(options)
  let url = try faceTimeURL(handle: handle, kind: kind)
  return FaceTimeCallPreview(
    handle: handle, kind: kind, url: url.absoluteString, externalAction: false)
}

func callKind(_ options: CLIOptions) throws -> String {
  let kind = options.targetOption("kind") ?? "video"
  guard ["video", "audio"].contains(kind) else {
    throw CLIError(
      code: .validationError,
      message: "`--kind` must be `video` or `audio`.",
      details: ["kind": kind]
    )
  }
  return kind
}

func normalizedHandle(_ value: String) throws -> String {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard trimmed.count >= 3 else {
    throw CLIError(
      code: .validationError, message: "`--handle` must contain at least 3 characters.")
  }

  if trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    || trimmed.rangeOfCharacter(from: .controlCharacters) != nil
  {
    throw CLIError(
      code: .validationError, message: "`--handle` cannot contain whitespace or control characters."
    )
  }

  let digits = trimmed.filter(\.isNumber)
  guard trimmed.contains("@") || digits.count >= 3 else {
    throw CLIError(
      code: .validationError, message: "`--handle` must be an email-style Apple ID or phone number."
    )
  }

  return trimmed
}

func faceTimeURL(handle: String, kind: String) throws -> URL {
  let scheme = kind == "audio" ? "facetime-audio" : "facetime"
  guard let encoded = handle.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
    let url = URL(string: "\(scheme)://\(encoded)")
  else {
    throw CLIError(
      code: .validationError, message: "`--handle` cannot be encoded as a FaceTime URL.")
  }
  return url
}

func validateDryRunOptions(_ options: CLIOptions) throws {}

func validateTargetOptions(_ options: CLIOptions, allowedOptions: Set<String>) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  if !unknownOptions.isEmpty || !options.targetFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(options.targetFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")]
    )
  }
}

func requiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name), !value.isEmpty else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }

  return value
}

func commandLimit(_ options: CLIOptions) throws -> Int {
  let limit = options.limit ?? 25
  guard limit <= 100 else {
    throw CLIError(
      code: .validationError, message: "`--limit` cannot exceed 100 for FaceTime resolve commands.")
  }
  return limit
}

func contactStoreWithReadAccess() throws -> CNContactStore {
  switch CNContactStore.authorizationStatus(for: .contacts) {
  case .authorized:
    return CNContactStore()
  case .notDetermined:
    return try requestContactsAccess(
      deniedMessage:
        CLIPermissionWording.accessNotGranted(
          "Contacts", operation: "FaceTime contact resolve commands"))
  case .denied, .restricted:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted(
        "Contacts", operation: "FaceTime contact resolve commands"))
  @unknown default:
    throw CLIError(
      code: .permissionDenied,
      message: CLIPermissionWording.accessStatusUnknown("Contacts"))
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

func contactKeys() -> [CNKeyDescriptor] {
  [
    CNContactIdentifierKey as CNKeyDescriptor,
    CNContactGivenNameKey as CNKeyDescriptor,
    CNContactFamilyNameKey as CNKeyDescriptor,
    CNContactOrganizationNameKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
  ]
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

  return searchable.contains { $0.localizedCaseInsensitiveContains(trimmed) }
}

func faceTimeHandles(_ contact: CNContact) -> [FaceTimeHandle] {
  let emails = contact.emailAddresses.map { FaceTimeHandle(kind: "email", value: String($0.value)) }
  let phones = contact.phoneNumbers.map {
    FaceTimeHandle(kind: "phone", value: $0.value.stringValue)
  }
  return emails + phones
}

func displayName(_ contact: CNContact) -> String {
  CNContactFormatter.string(from: contact, style: .fullName)
    ?? [contact.givenName, contact.familyName]
    .filter { !$0.isEmpty }
    .joined(separator: " ")
}

func callScopeDigest(_ preview: FaceTimeCallPreview) -> String {
  "facetime:\(preview.kind):\(sha256Hex(preview.handle.lowercased()))"
}

func callSummary(_ preview: FaceTimeCallPreview) -> [String: String] {
  [
    "kind": preview.kind,
    "handle": preview.handle,
    "url": preview.url,
  ]
}

func contactsHumanOutput(_ contacts: [FaceTimeContactCandidate]) -> String {
  contacts.map { contact in
    let handles = contact.handles.map { "\($0.kind):\($0.value)" }.joined(separator: ",")
    return "\(contact.contactId)\t\(contact.displayName)\t\(handles)"
  }.joined(separator: "\n")
}

func callHumanOutput(_ preview: FaceTimeCallPreview) -> String {
  [
    "handle: \(preview.handle)",
    "kind: \(preview.kind)",
    "url: \(preview.url)",
  ].joined(separator: "\n")
}
