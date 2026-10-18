import Contacts
import Foundation
import Utility

public struct ContactsCommand: Sendable {
  private let backend: any ContactsReading & ContactsMutating
  private let target = "contacts"

  public init(backend: any ContactsReading & ContactsMutating = ContactsFrameworkBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["contacts", "search"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["query"])
      let query = try requiredOption("query", options: options)
      guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
        throw CLIError(
          code: .validationError,
          message: "`--query` must contain at least 2 non-whitespace characters."
        )
      }
      let contacts = try backend.searchContacts(
        ContactSearchQuery(query: query, limit: try commandLimit(options))
      )
      return try result(
        ContactsSearchResponse(contacts: contacts),
        human: contactsHumanOutput(contacts),
        options: options
      )
    case ["contacts", "duplicates"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["field"])
      let field = try duplicateField(options)
      let groups = try backend.findDuplicateContacts(
        ContactDuplicateQuery(field: field, limit: try commandLimit(options))
      )
      return try result(
        ContactDuplicatesResponse(duplicateGroups: groups),
        human: duplicateGroupsHumanOutput(groups),
        options: options
      )
    case ["contacts", "read"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let contact = try backend.readContact(id: id) else {
        throw CLIError(
          code: .notFound,
          message: "Contact was not found.",
          details: ["id": id]
        )
      }
      return try result(
        ContactReadResponse(contact: contact),
        human: contactHumanOutput(contact),
        options: options
      )
    case ["contacts", "export"]:
      try validateTargetOptions(
        options, allowedOptions: ["id", "ids", "format", "output"], allowedFlags: ["all"])
      try validateExportIntent(options)
      let format = try contactExportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateVCardExportDestination(destinationPath)
      let selection = try contactExportSelection(options)
      switch selection {
      case .single(let id):
        guard let payload = try backend.exportContact(id: id) else {
          throw CLIError(
            code: .notFound,
            message: "Contact was not found.",
            details: ["id": id]
          )
        }
        return try exportContact(
          payload, format: format, destinationPath: destinationPath, options: options)
      case .explicitIDs(let ids):
        let payloads = try ids.map { id in
          guard let payload = try backend.exportContact(id: id) else {
            throw CLIError(
              code: .notFound,
              message: "Contact was not found.",
              details: ["id": id]
            )
          }
          return payload
        }
        return try exportContacts(
          payloads, format: format, destinationPath: destinationPath, options: options)
      case .all(let limit):
        let payloads = try backend.exportAllContacts(limit: limit)
        guard !payloads.isEmpty else {
          throw CLIError(
            code: .notFound,
            message: "No contacts were available to export."
          )
        }
        return try exportContacts(
          payloads,
          format: format,
          destinationPath: destinationPath,
          options: options,
          operation: "contacts.export_all",
          scope: "contact-export-all"
        )
      }
    case ["groups", "list"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let groups = try backend.listGroups(limit: try commandLimit(options))
      return try result(
        ContactGroupsResponse(groups: groups),
        human: groupsHumanOutput(groups),
        options: options
      )
    case ["groups", "members"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard
        let response = try backend.listGroupMembers(groupID: id, limit: try commandLimit(options))
      else {
        throw CLIError(
          code: .notFound,
          message: "Contact group was not found.",
          details: ["id": id]
        )
      }
      return try result(
        response,
        human: groupMembersHumanOutput(response),
        options: options
      )
    case ["groups", "add-member"]:
      try validateTargetOptions(options, allowedOptions: ["group-id", "contact-id"])
      try validateMutationIntent(options)
      let identity = try groupMembershipIdentity(options)
      if options.dryRun {
        try validateGroupMembershipChange(identity, adding: true)
      }
      return try mutation(
        operation: "groups.add-member",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        try validateGroupMembershipChange(identity, adding: true)
        let changed = try backend.addContact(id: identity.contact.id, toGroupID: identity.group.id)
        return ContactMutationResult(
          operation: "groups.add-member",
          changed: changed,
          contact: identity.contact,
          group: identity.group
        )
      }
    case ["groups", "remove-member"]:
      try validateTargetOptions(options, allowedOptions: ["group-id", "contact-id"])
      try validateMutationIntent(options)
      let identity = try groupMembershipIdentity(options)
      if options.dryRun {
        try validateGroupMembershipChange(identity, adding: false)
      }
      return try mutation(
        operation: "groups.remove-member",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        try validateGroupMembershipChange(identity, adding: false)
        let changed = try backend.removeContact(
          id: identity.contact.id, fromGroupID: identity.group.id)
        return ContactMutationResult(
          operation: "groups.remove-member",
          changed: changed,
          contact: identity.contact,
          group: identity.group
        )
      }
    case ["contacts", "create"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "given-name",
          "family-name",
          "organization",
          "job-title",
          "email",
          "phone",
          "email-label",
          "phone-label",
        ]
      )
      try validateMutationIntent(options)
      let draft = try contactCreateDraft(options)
      return try mutation(
        operation: "contacts.create",
        scopeDigest: contactCreateScopeDigest(draft),
        summary: contactCreateSummary(draft),
        options: options
      ) {
        let contact = try backend.createContact(draft)
        return ContactMutationResult(
          operation: "contacts.create", changed: true, contact: contact, deletedID: nil)
      }
    case ["contacts", "import"]:
      try validateTargetOptions(options, allowedOptions: ["file", "format", "on-duplicate"])
      try validateMutationIntent(options)
      let format = try contactExportFormat(options)
      let limit = try contactImportLimit(options)
      let duplicatePolicy = try contactImportDuplicatePolicy(options)
      let source = try contactImportSource(path: try requiredOption("file", options: options))
      let preview = try backend.previewContactImport(
        data: source.data, limit: limit, duplicatePolicy: duplicatePolicy)
      return try importContacts(
        preview,
        source: source,
        format: format,
        limit: limit,
        duplicatePolicy: duplicatePolicy,
        options: options
      )
    case ["contacts", "update"]:
      try validateTargetOptions(
        options,
        allowedOptions: [
          "id",
          "given-name",
          "family-name",
          "organization",
          "job-title",
          "email",
          "phone",
          "email-label",
          "phone-label",
        ],
        allowedFlags: ["clear-organization", "clear-job-title", "clear-email", "clear-phone"]
      )
      try validateMutationIntent(options)
      let patch = try contactPatch(options)
      let identity = try contactMutationIdentity(options)
      return try mutation(
        operation: "contacts.update",
        scopeDigest: contactUpdateScopeDigest(current: identity.contact, patch: patch),
        summary: contactUpdateSummary(current: identity.contact, patch: patch),
        options: options
      ) {
        let contact = try backend.updateContact(id: identity.contact.id, patch: patch)
        return ContactMutationResult(
          operation: "contacts.update", changed: true, contact: contact, deletedID: nil)
      }
    case ["contacts", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id", "ids"])
      try validateMutationIntent(options)
      let selection = try contactDeleteSelection(options)
      switch selection {
      case .single:
        let identity = try contactMutationIdentity(options)
        return try mutation(
          operation: "contacts.delete",
          scopeDigest: identity.scopeDigest,
          summary: identity.summaryFields,
          options: options
        ) { () throws -> ContactMutationResult in
          let changed = try backend.deleteContact(id: identity.contact.id)
          return ContactMutationResult(
            operation: "contacts.delete", changed: changed, contact: nil,
            deletedID: identity.contact.id)
        }
      case .explicitIDs(let ids):
        let identities = try contactMutationIdentities(ids: ids)
        let contacts = identities.map(\.contact)
        return try mutation(
          operation: "contacts.delete-many",
          scopeDigest: contactBulkDeleteScopeDigest(contacts: contacts),
          summary: contactBulkDeleteSummary(contacts: contacts),
          options: options
        ) { () throws -> ContactBulkMutationResult in
          let deletedIDs = try backend.deleteContacts(ids: ids)
          return ContactBulkMutationResult(
            operation: "contacts.delete-many",
            changed: !deletedIDs.isEmpty,
            contactIDs: deletedIDs
          )
        }
      }
    case ["contacts", "delete-matching"]:
      try validateTargetOptions(options, allowedOptions: ["query"])
      try validateMutationIntent(options)
      let query = try contactDeleteMatchingQuery(options)
      let limit = try contactDeleteMatchingLimit(options)
      let identities = try contactMatchingMutationIdentities(query: query, limit: limit)
      let contacts = identities.map(\.contact)
      let ids = contacts.map(\.id)
      return try mutation(
        operation: "contacts.delete-matching",
        scopeDigest: contactDeleteMatchingScopeDigest(query: query, limit: limit, contacts: contacts),
        summary: contactDeleteMatchingSummary(query: query, limit: limit, contacts: contacts),
        options: options
      ) { () throws -> ContactBulkMutationResult in
        let deletedIDs = try backend.deleteContacts(ids: ids)
        return ContactBulkMutationResult(
          operation: "contacts.delete-matching",
          changed: !deletedIDs.isEmpty,
          contactIDs: deletedIDs
        )
      }
    default:
      return nil
    }
  }

  private func contactCreateDraft(_ options: CLIOptions) throws -> ContactCreateDraft {
    let draft = ContactCreateDraft(
      givenName: try normalizedOption(options.targetOption("given-name"), name: "given-name") ?? "",
      familyName: try normalizedOption(options.targetOption("family-name"), name: "family-name")
        ?? "",
      organizationName: try normalizedOption(
        options.targetOption("organization"), name: "organization"),
      jobTitle: try normalizedOption(options.targetOption("job-title"), name: "job-title"),
      emailAddress: try normalizedEmail(options.targetOption("email")),
      phoneNumber: try normalizedOption(options.targetOption("phone"), name: "phone"),
      emailLabel: try contactFieldLabel(options.targetOption("email-label"), kind: .email),
      phoneLabel: try contactFieldLabel(options.targetOption("phone-label"), kind: .phone)
    )
    if draft.emailLabel != nil, draft.emailAddress == nil {
      throw CLIError(code: .validationError, message: "`--email-label` requires `--email`.")
    }
    if draft.phoneLabel != nil, draft.phoneNumber == nil {
      throw CLIError(code: .validationError, message: "`--phone-label` requires `--phone`.")
    }

    guard
      !draft.givenName.isEmpty
        || !draft.familyName.isEmpty
        || draft.organizationName != nil
    else {
      throw CLIError(
        code: .validationError,
        message: "`contacts create` requires `--given-name`, `--family-name`, or `--organization`."
      )
    }

    return draft
  }

  private func contactPatch(_ options: CLIOptions) throws -> ContactPatch {
    if options.hasTargetFlag("clear-organization"), options.targetOption("organization") != nil {
      throw CLIError(
        code: .validationError,
        message: "`--clear-organization` cannot be combined with `--organization`.")
    }
    if options.hasTargetFlag("clear-job-title"), options.targetOption("job-title") != nil {
      throw CLIError(
        code: .validationError,
        message: "`--clear-job-title` cannot be combined with `--job-title`.")
    }
    if options.hasTargetFlag("clear-email"), options.targetOption("email") != nil {
      throw CLIError(
        code: .validationError, message: "`--clear-email` cannot be combined with `--email`.")
    }
    if options.hasTargetFlag("clear-phone"), options.targetOption("phone") != nil {
      throw CLIError(
        code: .validationError, message: "`--clear-phone` cannot be combined with `--phone`.")
    }

    let patch = ContactPatch(
      givenName: try normalizedOption(options.targetOption("given-name"), name: "given-name"),
      familyName: try normalizedOption(options.targetOption("family-name"), name: "family-name"),
      organizationName: try normalizedOption(
        options.targetOption("organization"), name: "organization"),
      jobTitle: try normalizedOption(options.targetOption("job-title"), name: "job-title"),
      emailAddress: try normalizedEmail(options.targetOption("email")),
      phoneNumber: try normalizedOption(options.targetOption("phone"), name: "phone"),
      emailLabel: try contactFieldLabel(options.targetOption("email-label"), kind: .email),
      phoneLabel: try contactFieldLabel(options.targetOption("phone-label"), kind: .phone),
      clearOrganization: options.hasTargetFlag("clear-organization"),
      clearJobTitle: options.hasTargetFlag("clear-job-title"),
      clearEmail: options.hasTargetFlag("clear-email"),
      clearPhone: options.hasTargetFlag("clear-phone")
    )
    if patch.emailLabel != nil, patch.emailAddress == nil, !patch.clearEmail {
      throw CLIError(
        code: .validationError, message: "`--email-label` requires `--email` or `--clear-email`.")
    }
    if patch.phoneLabel != nil, patch.phoneNumber == nil, !patch.clearPhone {
      throw CLIError(
        code: .validationError, message: "`--phone-label` requires `--phone` or `--clear-phone`.")
    }

    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError, message: "At least one contact field must be supplied for update.")
    }

    return patch
  }

  private func contactMutationIdentity(_ options: CLIOptions) throws -> ContactMutationIdentity {
    let id = try requiredOption("id", options: options)
    guard let contact = try backend.contactForMutation(id: id) else {
      throw CLIError(code: .notFound, message: "Contact was not found.", details: ["id": id])
    }

    return ContactMutationIdentity(
      contact: contact,
      scopeDigest: contactIdentityScopeDigest(contact),
      summaryFields: [
        "id": contact.id,
        "display_name": contact.displayName,
        "email_count": "\(contact.emailAddresses.count)",
        "phone_count": "\(contact.phoneNumbers.count)",
      ]
    )
  }

  private func contactMutationIdentities(ids: [String]) throws -> [ContactMutationIdentity] {
    try ids.map { id in
      guard let contact = try backend.contactForMutation(id: id) else {
        throw CLIError(code: .notFound, message: "Contact was not found.", details: ["id": id])
      }
      return ContactMutationIdentity(
        contact: contact,
        scopeDigest: contactIdentityScopeDigest(contact),
        summaryFields: [
          "id": contact.id,
          "display_name": contact.displayName,
          "email_count": "\(contact.emailAddresses.count)",
          "phone_count": "\(contact.phoneNumbers.count)",
        ]
      )
    }
  }

  private func contactMatchingMutationIdentities(query: String, limit: Int) throws
    -> [ContactMutationIdentity]
  {
    let matches = try backend.searchContacts(ContactSearchQuery(query: query, limit: limit + 1))
    guard matches.count <= limit else {
      throw CLIError(
        code: .validationError,
        message:
          "Contact delete matching query matched more than `--limit` contacts. Narrow the query or increase `--limit` up to 25.",
        details: ["limit": "\(limit)"]
      )
    }
    guard !matches.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "No contacts matched the delete query.",
        details: ["query": query]
      )
    }

    let ids = matches.map(\.id)
    var seen: Set<String> = []
    for id in ids where !seen.insert(id).inserted {
      throw CLIError(
        code: .validationError,
        message: "Contact delete matching query returned duplicate contact IDs.",
        details: ["id": id]
      )
    }

    return try contactMutationIdentities(ids: ids)
  }

  private func groupMembershipIdentity(_ options: CLIOptions) throws -> ContactGroupMutationIdentity
  {
    let groupID = try requiredOption("group-id", options: options)
    let contactID = try requiredOption("contact-id", options: options)

    guard let group = try backend.groupForMutation(id: groupID) else {
      throw CLIError(
        code: .notFound, message: "Contact group was not found.", details: ["group_id": groupID])
    }
    guard let contact = try backend.contactForMutation(id: contactID) else {
      throw CLIError(
        code: .notFound, message: "Contact was not found.", details: ["contact_id": contactID])
    }

    let isMember = try backend.isContact(contact.id, memberOfGroup: group.id)
    return ContactGroupMutationIdentity(
      group: group,
      contact: contact,
      isMember: isMember,
      scopeDigest: groupMembershipScopeDigest(group: group, contact: contact, isMember: isMember),
      summaryFields: [
        "group_id": group.id,
        "group_name": group.name,
        "contact_id": contact.id,
        "display_name": contact.displayName,
        "current_member": "\(isMember)",
      ]
    )
  }

  private func exportContact(
    _ payload: ContactExportPayload,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "contacts.export"
    let scope = "contact-export"
    let summary = contactExportSummary(
      contact: payload.contact,
      data: payload.data,
      format: format,
      destinationPath: destinationPath
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "Contact export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeContactExport(payload.data, to: destinationPath)
    return try result(
      ContactExportResult(
        operation: operation,
        changed: true,
        contactID: payload.contact.id,
        displayName: payload.contact.displayName,
        destinationPath: destinationPath,
        format: format,
        byteCount: payload.data.count,
        sha256: sha256Hex(payload.data)
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func exportContacts(
    _ payloads: [ContactExportPayload],
    format: String,
    destinationPath: String,
    options: CLIOptions,
    operation: String = "contacts.export_many",
    scope: String = "contact-export-many"
  ) throws -> CLICommandResult {
    let data = contactExportData(payloads)
    let summary = contactBulkExportSummary(
      payloads: payloads,
      data: data,
      format: format,
      destinationPath: destinationPath
    )

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "Contact export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    try writeContactExport(data, to: destinationPath)
    let ids = payloads.map(\.contact.id)
    return try result(
      ContactBulkExportResult(
        operation: operation,
        changed: true,
        contactIDs: ids,
        destinationPath: destinationPath,
        format: format,
        byteCount: data.count,
        sha256: sha256Hex(data)
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func mutation<Result: Encodable>(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    commit: () throws -> Result
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest,
          category: operation.contains("delete-matching") ? .destructiveSelection : .ordinaryMutation,
          allowFlags: operation.contains("delete-matching") ? ["--allow-destructive-selection"] : []
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    if operation.contains("delete-matching") {
      try CLISafety.requireFlag(
        "allow-destructive-selection",
        in: options,
        category: .destructiveSelection,
        message:
          "Contact delete-matching mutates a dynamically selected set and requires `--allow-destructive-selection`."
      )
    }

    return try result(try commit(), human: "\(operation) executed", options: options)
  }

  private func importContacts(
    _ preview: ContactImportPreview,
    source: ContactImportSource,
    format: String,
    limit: Int,
    duplicatePolicy: ContactImportDuplicatePolicy,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "contacts.import"
    let scope = "contact-import"
    if duplicatePolicy == .fail, !preview.duplicates.isEmpty {
      throw CLIError(
        code: .validationError,
        message:
          "Contact import matched existing contacts. Use `--on-duplicate skip-existing` or `--on-duplicate create-new` explicitly.",
        details: [
          "duplicate_count": "\(preview.duplicates.count)",
          "duplicate_contact_count": "\(Set(preview.duplicates.map(\.importedIndex)).count)",
        ]
      )
    }
    let summary = contactImportSummary(
      source: source, preview: preview, format: format, limit: limit)

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    let importResult = try backend.importContacts(
      data: source.data, limit: limit, duplicatePolicy: duplicatePolicy)
    return try result(
      ContactImportResult(
        operation: operation,
        changed: !importResult.contacts.isEmpty,
        contacts: importResult.contacts,
        skippedDuplicates: importResult.skippedDuplicates,
        duplicatePolicy: duplicatePolicy,
        sourcePath: source.path,
        byteCount: source.data.count,
        sha256: sha256Hex(source.data)
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
