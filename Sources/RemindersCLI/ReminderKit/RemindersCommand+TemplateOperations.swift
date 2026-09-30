import Foundation
import Utility

extension RemindersCommand {
  public func listReminderTemplates() throws -> [ReminderTemplateRecord] {
    try fetchReminderTemplatesWithReminderKit()
  }

  public func saveReminderTemplate(
    sourceList: ReminderListRecord,
    title: String,
    includeCompleted: Bool
  ) throws -> ReminderTemplateRecord {
    let template = try saveReminderTemplateWithReminderKit(
      sourceListID: sourceList.id,
      title: title,
      includeCompleted: includeCompleted
    )
    guard try listReminderTemplates().contains(where: { $0.id == template.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder template was not present after save.",
        details: ["id": template.id, "mechanism": "reminderkit"]
      )
    }
    return template
  }

  public func createReminderListFromTemplate(
    template: ReminderTemplateRecord,
    title: String
  ) throws -> ReminderListRecord {
    let list = try createReminderListFromTemplateWithReminderKit(
      templateID: template.id,
      title: title
    )
    guard try listReminderLists().contains(where: { $0.id == list.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder list created from template was not present after creation.",
        details: ["id": list.id, "mechanism": "reminderkit"]
      )
    }
    do {
      return try sqliteReader.enrichLists([list]).first ?? list
    } catch {
      return list
    }
  }

  public func updateReminderTemplate(
    template: ReminderTemplateRecord,
    patch: ReminderTemplatePatch
  ) throws -> ReminderTemplateRecord {
    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError,
        message: "At least one reminder template update field is required."
      )
    }
    let updated = try updateReminderTemplateWithReminderKit(
      templateID: template.id,
      patch: patch
    )
    guard try listReminderTemplates().contains(where: { $0.id == updated.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder template was not present after update.",
        details: ["id": updated.id, "mechanism": "reminderkit"]
      )
    }
    return updated
  }

  public func replaceReminderTemplate(
    template: ReminderTemplateRecord,
    sourceList: ReminderListRecord,
    title: String,
    includeCompleted: Bool
  ) throws -> ReminderTemplateRecord {
    let replaced = try replaceReminderTemplateWithReminderKit(
      templateID: template.id,
      sourceListID: sourceList.id,
      title: title,
      includeCompleted: includeCompleted
    )
    let templates = try listReminderTemplates()
    guard templates.contains(where: { $0.id == replaced.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Replacement reminder template was not present after replace.",
        details: ["id": replaced.id, "mechanism": "reminderkit"]
      )
    }
    guard !templates.contains(where: { $0.id == template.id }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Original reminder template was still present after replace.",
        details: ["id": template.id, "mechanism": "reminderkit"]
      )
    }
    return replaced
  }

  public func deleteReminderTemplate(template: ReminderTemplateRecord) throws -> Bool {
    let changed = try deleteReminderTemplateWithReminderKit(templateID: template.id)
    if try listReminderTemplates().contains(where: { $0.id == template.id }) {
      throw CLIError(
        code: .backendUnavailable,
        message: "Reminder template was still present after delete.",
        details: ["id": template.id, "mechanism": "reminderkit"]
      )
    }
    return changed
  }
}
