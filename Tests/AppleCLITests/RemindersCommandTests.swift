import Foundation
import Testing
import Utility
@testable import RemindersCLI

@Suite
struct RemindersCommandTests {
  @Test func remindersHelpDescribesUserFacingCommands() throws {
    let help = RemindersTarget.helpMessage()

    #expect(help.contains("ReminderKit workflows"))
    #expect(help.contains("lists"))
    #expect(help.contains("tags"))
    #expect(help.contains("sections"))
    #expect(help.contains("subtasks"))
    #expect(help.contains("attachments"))
    #expect(help.contains("assignments"))
    #expect(help.contains("templates"))
    #expect(help.contains("doctor"))
    #expect(!help.contains("capabilities"))
  }

  @Test func remindersTemplatesHelpIsSelfDescribing() throws {
    let help = RemindersTarget.Templates.helpMessage()
    let itemsHelp = RemindersTarget.Templates.Items.helpMessage()

    #expect(help.contains("templates"))
    #expect(help.contains("list"))
    #expect(help.contains("save"))
    #expect(help.contains("create-list"))
    #expect(help.contains("update"))
    #expect(help.contains("replace"))
    #expect(help.contains("delete"))
    #expect(itemsHelp.contains("attachments"))
    #expect(itemsHelp.contains("subtasks"))
  }

  @Test func remindersCompleteHelpDescribesHistoricalCompletionTime() throws {
    let help = RemindersTarget.Complete.helpMessage()

    #expect(help.contains("completed-at"))
    #expect(help.contains("ISO-8601"))
    #expect(help.contains("2021-01-02T03:04:05Z"))
  }

  @Test func remindersIconsListIsSelfDescribingWithoutStoreLookup() throws {
    let command = RemindersCommand()
    let result = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "lists", "icons", "list", "--json",
        ])))
    let object = try remindersJSONObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let icons = data?["icons"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(icons?.isEmpty == false)
    #expect(icons?.first?["token"] as? String != nil)
  }

  @Test func remindersHexColorsCreateReminderKitColors() throws {
    let rgb = try #require(coreReminderColor("#8E8E93"))
    #expect(abs(rgb.red - (142.0 / 255.0)) < 0.001)
    #expect(abs(rgb.green - (142.0 / 255.0)) < 0.001)
    #expect(abs(rgb.blue - (147.0 / 255.0)) < 0.001)
    #expect(abs(rgb.alpha - 1) < 0.001)
    #expect(coreReminderColorHex(rgb) == "#8E8E93")

    let rgba = try #require(coreReminderColor("5B7DAACC"))
    #expect(abs(rgba.red - (91.0 / 255.0)) < 0.001)
    #expect(abs(rgba.green - (125.0 / 255.0)) < 0.001)
    #expect(abs(rgba.blue - (170.0 / 255.0)) < 0.001)
    #expect(abs(rgba.alpha - (204.0 / 255.0)) < 0.001)
    #expect(coreReminderColorHex(rgba) == "#5B7DAACC")

    #expect(coreReminderColor("not-a-color") == nil)
  }

  @Test func remindersListAndTemplateRecordsExposeColorHex() throws {
    let list = ReminderListRecord(
      id: "list-id",
      title: "Wish List",
      sourceTitle: "iCloud",
      allowsContentModifications: true,
      color: "#DCD3C5",
      hasColor: true
    )
    let template = ReminderTemplateRecord(
      id: "template-id",
      title: "Trip Template",
      sourceId: "source-id",
      sourceTitle: "iCloud",
      color: "#0A84FF",
      hasColor: true
    )

    let encoder = JSONEncoder()
    let listJSON = String(
      data: try encoder.encode(ReminderListsResponse(lists: [list])),
      encoding: .utf8
    )
    let templateJSON = String(
      data: try encoder.encode(ReminderTemplatesResponse(templates: [template])),
      encoding: .utf8
    )

    #expect(listJSON?.contains("\"color\":\"#DCD3C5\"") == true)
    #expect(templateJSON?.contains("\"color\":\"#0A84FF\"") == true)
  }

  @Test func remindersDoctorUsesReminderKitReadAccessByDefault() {
    let checks = remindersDoctorChecks()
    let names = Set(checks.map(\.name))

    #expect(names.contains("reminderkit_framework"))
    #expect(names.contains("reminderkit_read_access"))
    #expect(!names.contains("reminders_store_readonly_inspector"))
  }

  @Test func remindersCreateValidationDoesNotRequireStoreLookup() throws {
    let command = RemindersCommand()
    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "reminders", "create", "--title", "Buy milk", "--dry-run", "--json",
        ]))
      Issue.record("Expected missing list validation to throw before any ReminderKit mutation.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("--list"))
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func remindersUnknownTargetOptionValidatesBeforeStoreLookup() throws {
    let command = RemindersCommand()
    do {
      _ = try command.run(
        options: CLIOptionsFixture.parse([
          "reminders", "update", "--bogus", "value", "--dry-run", "--json",
        ]))
      Issue.record("Expected unknown option validation to throw before identity lookup.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      #expect(error.message.contains("Unsupported option"))
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }
}

private func remindersJSONObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw RemindersCommandTestError.notObject
  }
  return object
}

private enum RemindersCommandTestError: Error {
  case notObject
}
