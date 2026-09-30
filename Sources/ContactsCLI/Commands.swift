import ArgumentParser
import Contacts
import Utility

public struct ContactsTarget: ParsableCommand {
  public static let targetName = "contacts"
  public static let targetStatus =
    "Implemented: Contacts.framework search/read/duplicate/group-list/member-read paths plus dry-run previewed single, explicit-IDs, and bounded all-contacts vCard export, vCard import with explicit duplicate policy, contact create/update/delete with label-aware create/update, explicit-ID bulk delete, query-bound delete, and group membership add/remove."
  public static let isImplemented = true

  public static let configuration = CommandConfiguration(
    commandName: "contacts",
    abstract: "Contacts and groups workflows.",
    version: CLIVersion.current,
    subcommands: [
      Search.self, Duplicates.self, Read.self, Export.self, Import.self, Create.self, Update.self,
      Delete.self, DeleteMatching.self, Groups.self, Doctor.self,
    ]
  )

  @OptionGroup public var shared: CLISharedOptions
  public init() {}

  public mutating func run() throws {
    try CLICommandOutput.writeStatus(
      target: Self.targetName,
      status: Self.targetStatus,
      implemented: Self.isImplemented,
      json: shared.json,
      pretty: shared.pretty
    )
  }

  public struct Search: Leaf {
    public static let configuration = CommandConfiguration(commandName: "search")
    public static let positionals = ["contacts", "search"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Duplicates: Leaf {
    public static let configuration = CommandConfiguration(commandName: "duplicates")
    public static let positionals = ["contacts", "duplicates"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Read: Leaf {
    public static let configuration = CommandConfiguration(commandName: "read")
    public static let positionals = ["contacts", "read"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Export: Leaf {
    public static let configuration = CommandConfiguration(commandName: "export")
    public static let positionals = ["contacts", "export"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Import: Leaf {
    public static let configuration = CommandConfiguration(commandName: "import")
    public static let positionals = ["contacts", "import"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Create: Leaf {
    public static let configuration = CommandConfiguration(commandName: "create")
    public static let positionals = ["contacts", "create"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Update: Leaf {
    public static let configuration = CommandConfiguration(commandName: "update")
    public static let positionals = ["contacts", "update"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct Delete: Leaf {
    public static let configuration = CommandConfiguration(commandName: "delete")
    public static let positionals = ["contacts", "delete"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }
  public struct DeleteMatching: Leaf {
    public static let configuration = CommandConfiguration(commandName: "delete-matching")
    public static let positionals = ["contacts", "delete-matching"]
    @OptionGroup public var shared: CLISharedOptions
    @OptionGroup public var targetOptions: ContactsTargetOptions
    public init() {}
  }

  public struct Groups: ParsableCommand {
    public static let configuration = CommandConfiguration(
      commandName: "groups",
      subcommands: [List.self, Members.self, AddMember.self, RemoveMember.self]
    )
    public init() {}

    public struct List: Leaf {
      public static let configuration = CommandConfiguration(commandName: "list")
      public static let positionals = ["groups", "list"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: ContactsTargetOptions
      public init() {}
    }
    public struct Members: Leaf {
      public static let configuration = CommandConfiguration(commandName: "members")
      public static let positionals = ["groups", "members"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: ContactsTargetOptions
      public init() {}
    }
    public struct AddMember: Leaf {
      public static let configuration = CommandConfiguration(commandName: "add-member")
      public static let positionals = ["groups", "add-member"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: ContactsTargetOptions
      public init() {}
    }
    public struct RemoveMember: Leaf {
      public static let configuration = CommandConfiguration(commandName: "remove-member")
      public static let positionals = ["groups", "remove-member"]
      @OptionGroup public var shared: CLISharedOptions
      @OptionGroup public var targetOptions: ContactsTargetOptions
      public init() {}
    }
  }

  public struct Doctor: ParsableCommand {
    public static let configuration = CommandConfiguration(commandName: "doctor")
    @OptionGroup public var shared: CLISharedOptions
    public init() {}

    public mutating func run() throws {
      try CLICommandOutput.writeDoctor(
        target: ContactsTarget.targetName,
        checks: contactsDoctorChecks(),
        json: shared.json,
        pretty: shared.pretty
      )
    }
  }
}

extension ContactsTarget {
  fileprivate static func runCommand(options: CLIOptions) throws {
    do {
      guard let result = try ContactsCommand().run(options: options) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "Command is documented but this target backend is not implemented yet.",
          details: [
            "target": targetName,
            "command": options.positionals.joined(separator: " "),
          ]
        )
      }

      try CLICommandOutput.write(result)
    } catch let exitCode as ExitCode {
      throw exitCode
    } catch let error as CLIError {
      try CLICommandOutput.write(
        error, target: targetName, json: options.json, pretty: options.pretty)
    } catch {
      try CLICommandOutput.write(
        CLIError(
          code: .internalError,
          message: "Unhandled CLI error.",
          details: ["error": String(describing: error)]
        ),
        target: targetName,
        json: options.json,
        pretty: options.pretty
      )
    }
  }

  public protocol Leaf: ParsableCommand {
    static var positionals: [String] { get }
    var shared: CLISharedOptions { get }
    var targetOptions: ContactsTargetOptions { get }
  }
}

extension ContactsTarget.Leaf {
  public mutating func run() throws {
    let options = shared.cliOptions(
      targetOptions: targetOptions.cliTargetOptions,
      targetFlags: targetOptions.cliTargetFlags,
      positionals: Self.positionals
    )
    try ContactsTarget.runCommand(options: options)
  }
}

public struct ContactsTargetOptions: ParsableArguments, Sendable {
  @Option public var query: String?
  @Option public var field: String?
  @Option public var id: String?
  @Option public var ids: String?
  @Option public var format: String?
  @Option public var output: String?
  @Option public var file: String?
  @Option(name: .customLong("on-duplicate")) public var onDuplicate: String?
  @Option(name: .customLong("given-name")) public var givenName: String?
  @Option(name: .customLong("family-name")) public var familyName: String?
  @Option public var organization: String?
  @Option(name: .customLong("job-title")) public var jobTitle: String?
  @Option public var email: String?
  @Option public var phone: String?
  @Option(name: .customLong("email-label")) public var emailLabel: String?
  @Option(name: .customLong("phone-label")) public var phoneLabel: String?
  @Option(name: .customLong("group-id")) public var groupID: String?
  @Option(name: .customLong("contact-id")) public var contactID: String?
  @Flag public var all = false
  @Flag(name: .customLong("clear-organization")) public var clearOrganization = false
  @Flag(name: .customLong("clear-job-title")) public var clearJobTitle = false
  @Flag(name: .customLong("clear-email")) public var clearEmail = false
  @Flag(name: .customLong("clear-phone")) public var clearPhone = false

  public init() {}

  public var cliTargetOptions: [String: String] {
    CLITargetOptionBuilder.options([
      ("query", query),
      ("field", field),
      ("id", id),
      ("ids", ids),
      ("format", format),
      ("output", output),
      ("file", file),
      ("on-duplicate", onDuplicate),
      ("given-name", givenName),
      ("family-name", familyName),
      ("organization", organization),
      ("job-title", jobTitle),
      ("email", email),
      ("phone", phone),
      ("email-label", emailLabel),
      ("phone-label", phoneLabel),
      ("group-id", groupID),
      ("contact-id", contactID),
    ])
  }

  public var cliTargetFlags: Set<String> {
    CLITargetOptionBuilder.flags([
      ("all", all),
      ("clear-organization", clearOrganization),
      ("clear-job-title", clearJobTitle),
      ("clear-email", clearEmail),
      ("clear-phone", clearPhone),
    ])
  }
}

public func contactsDoctorChecks() -> [CLIDoctorCheck] {
  [
    contactsAuthorizationCheck(),
    CLIDoctorCheck(
      name: "contacts_read_backend",
      status: .ok,
      message:
        "Contacts.framework search/read/duplicate/export/group-list/member-read commands are implemented."
    ),
    CLIDoctorCheck(
      name: "contacts_mutation_backend",
      status: .ok,
      message:
        "Contacts.framework single, explicit-IDs, and bounded all-contacts vCard export, vCard import with explicit duplicate policy, create/update/delete with label-aware create/update, explicit-ID bulk delete, query-bound delete, and group membership add/remove commands are dry-run previewed."
    ),
  ]
}

public func contactsAuthorizationCheck() -> CLIDoctorCheck {
  let status = CNContactStore.authorizationStatus(for: .contacts)
  let details = ["authorization_status": String(describing: status)]

  switch status {
  case .authorized:
    return CLIDoctorCheck(
      name: "contacts_authorization",
      status: .ok,
      message: CLIPermissionWording.accessGranted("Contacts"),
      details: details
    )
  case .denied, .restricted:
    return CLIDoctorCheck(
      name: "contacts_authorization",
      status: .permissionDenied,
      message: CLIPermissionWording.accessDeniedOrRestricted("Contacts"),
      details: details
    )
  case .notDetermined:
    return CLIDoctorCheck(
      name: "contacts_authorization",
      status: .warning,
      message: CLIPermissionWording.accessNotRequested("Contacts"),
      details: details
    )
  @unknown default:
    return CLIDoctorCheck(
      name: "contacts_authorization",
      status: .warning,
      message: CLIPermissionWording.unknownAuthorizationStatus("Contacts"),
      details: details
    )
  }
}
