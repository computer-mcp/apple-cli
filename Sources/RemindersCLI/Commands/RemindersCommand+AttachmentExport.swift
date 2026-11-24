import Foundation
import Utility

extension RemindersCommand {
  func runAttachmentReadCommand(
    _ options: CLIOptions,
    readNative: (String) throws -> ReminderNativeAttachmentInventory? =
      readNativeReminderAttachments
  ) throws -> CLICommandResult {
    let id = try ReminderAttachmentReminderSelector(requiredOption("id", options: options))
    let resolver = ReminderAttachmentResolver(sqliteReader: sqliteReader)

    if options.positionals == ["attachments", "list"] {
      try CLISafety.rejectDryRunForReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      if let limit = options.limit, limit < 1 {
        throw CLIError(code: .validationError, message: "`--limit` must be positive.")
      }
      let native = try? readNative(id.value)
      defer { withExtendedLifetime(native) {} }
      let inventory = try resolver.inventory(for: id, native: native?.inventory)
      let selected = inventory.attachments.prefix(options.limit ?? inventory.attachments.count)
      let entries = selected.map { resolver.resolve($0, account: inventory.accountUUID).inspection }
      let human =
        (["Reminder \(inventory.reminderId)"]
        + entries.map { attachment in
          let name = attachment.fileName ?? attachment.kind.rawValue
          return "\(attachment.id.uuidString)  \(name)  \(attachment.status.rawValue)"
        }).joined(separator: "\n")
      return try result(
        ReminderAttachmentsListResult(reminderId: inventory.reminderId, attachments: entries),
        human: human, options: options)
    }

    try validateTargetOptions(
      options, allowedOptions: ["id", "attachment", "output"], allowedFlags: ["all"])
    let all = options.hasTargetFlag("all")
    let attachment = options.targetOption("attachment")
    guard all ? attachment == nil : attachment?.isEmpty == false, options.limit == nil else {
      throw CLIError(
        code: .validationError,
        message:
          "Choose exactly one of `--attachment` and `--all` for export. Export does not accept `--limit`."
      )
    }
    try CLISafety.requireFlag(
      "allow-artifact-action", in: options, category: .artifactAction,
      message: "Reminders attachment export requires `--allow-artifact-action`.")
    let destination = try ReminderAttachmentExportDestination(
      requiredOption("output", options: options), all: all,
      protectedDirectory: sqliteReader.remindersContainerURL)

    return try destination.withParent { parent in
      let native = try? readNative(id.value)
      defer { withExtendedLifetime(native) {} }
      let inventory = try resolver.inventory(for: id, native: native?.inventory)
      let selected = try attachmentsToExport(inventory.attachments, attachment: attachment)
      let skipped = all ? inventory.attachments.filter { $0.kind == .link }.map(\.id) : []
      let entries = try destination.entries(
        for: selected.map {
          resolver.resolve($0, account: inventory.accountUUID)
        })
      var human = entries.map(\.receipt.path)
      if !skipped.isEmpty { human.append("Skipped URL attachments: \(skipped.count)") }
      if options.dryRun {
        let operation = "reminders.attachments.export"
        let preview = CLIDryRun(
          target: target, operation: operation,
          normalizedArguments: [
            "id": inventory.reminderId, "output": destination.path, "all": String(all),
          ],
          resolvedScope: [
            "skipped_attachment_ids": skipped.map(\.uuidString).joined(separator: ",")
          ],
          wouldMutate: entries.map { entry in
            CLIDryRunMutation(
              action: "create", resource: "file", identifier: entry.receipt.path,
              fields: [
                "attachment_id": entry.receipt.attachmentId.uuidString,
                "size_bytes": String(entry.receipt.sizeBytes), "sha512": entry.receipt.sha512,
              ])
          },
          requirements: CLIDryRunRequirements(allowFlags: ["--allow-artifact-action"]),
          risks: [
            CLIDryRunRisk(
              category: .artifactAction, flag: "--allow-artifact-action",
              message: "Export creates local files at the selected destination.")
          ])
        return try result(
          preview,
          human: "dry-run: \(operation)\n"
            + human.joined(separator: "\n"), options: options)
      }

      try destination.publish(entries, in: parent)
      let receipt = ReminderAttachmentExportResult(
        reminderId: inventory.reminderId, files: entries.map(\.receipt),
        skippedAttachmentIds: skipped)
      return try result(receipt, human: human.joined(separator: "\n"), options: options)
    }
  }

  private func attachmentsToExport(_ attachments: [ReminderAttachmentSource], attachment: String?)
    throws -> [ReminderAttachmentSource]
  {
    if let attachment {
      let matches: [ReminderAttachmentSource]
      if let id = UUID(uuidString: attachment) {
        matches = attachments.filter { $0.id == id }
      } else {
        matches = attachments.filter { $0.fileName == attachment }
      }
      guard matches.count <= 1 else {
        throw CLIError(
          code: .ambiguousIdentity,
          message:
            "The attachment filename is ambiguous. Use an attachment ID from `attachments list`.")
      }
      guard let selected = matches.first else {
        throw CLIError(
          code: .notFound, message: "The selected reminder has no matching attachment.")
      }
      return [selected]
    }
    let files = attachments.filter { $0.kind != .link }
    guard !files.isEmpty else {
      throw CLIError(
        code: .notFound, message: "The selected reminder has no file attachments.",
        details: ["skipped_attachment_ids": attachments.map(\.id.uuidString).joined(separator: ",")]
      )
    }
    return files
  }
}
