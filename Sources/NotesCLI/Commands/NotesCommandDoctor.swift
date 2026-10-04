import Foundation
import Utility

extension NotesCommand {
  func runDoctor(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {

    case ["doctor", "note"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let note = try implementation.readNote(id: id) else {
        throw CLIError(
          code: .notFound,
          message: "Note was not found.",
          details: ["id_sha256": sha256Hex(id)]
        )
      }
      let debug = sqliteReader.debugNote(note)
      return try result(
        debug,
        human: notesObjectDebugHumanOutput(debug),
        options: options
      )
    case ["doctor", "folder"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["folder"])
      let selector = try requiredOption("folder", options: options)
      let folder = try folderIdentity(selector: selector)
      let debug = sqliteReader.debugFolder(folder, selector: selector)
      return try result(
        debug,
        human: notesObjectDebugHumanOutput(debug),
        options: options
      )
    case ["doctor", "account"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["account"])
      let selector = try requiredOption("account", options: options)
      let account = try accountIdentity(selector: selector)
      let debug = sqliteReader.debugAccount(account, selector: selector)
      return try result(
        debug,
        human: notesObjectDebugHumanOutput(debug),
        options: options
      )
    case ["doctor", "store"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["scope"])
      let debug = try sqliteReader.debugStore(scope: options.targetOption("scope") ?? "summary")
      return try result(
        debug,
        human: notesStoreDebugHumanOutput(debug),
        options: options
      )
    case ["doctor", "write-lab"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let check = notesWriteCapabilityDoctorCheck()
      return try result(
        check,
        human: notesDoctorCheckHumanOutput(check),
        options: options
      )
    case ["doctor", "rich-lab"]:
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let check = notesRichCapabilityDoctorCheck()
      return try result(
        check,
        human: notesDoctorCheckHumanOutput(check),
        options: options
      )    default:
      return nil
    }
  }

}
