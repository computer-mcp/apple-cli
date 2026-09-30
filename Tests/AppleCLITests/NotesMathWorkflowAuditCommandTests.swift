import Foundation
import Testing
import Utility
@testable import NotesCLI

@Suite("Notes math workflow audit command")
struct NotesMathWorkflowAuditCommandTests {
  @Test func mathWorkflowAuditAccountsForOfficialMathWorkflowsWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let result = try #require(try command.run(options: try CLIOptionsFixture.parse([
      "body", "math", "audit", "--json",
    ])))
    let object = try jsonObject(result.stdout ?? "")
    let data = try #require(object["data"] as? [String: Any])
    let summary = try #require(data["summary"] as? [String: Any])
    let records = try #require(data["records"] as? [[String: Any]])
    let verification = try #require(data["verification"] as? [String: Any])
    let checks = verification["checks"] as? [[String: Any]] ?? []
    let checkNames = Set(checks.compactMap { $0["name"] as? String })
    let byFamily = Dictionary(
      uniqueKeysWithValues: records.compactMap { record -> (String, [String: Any])? in
        guard let family = record["workflowFamily"] as? String else {
          return nil
        }
        return (family, record)
      })

    #expect(object["ok"] as? Bool == true)
    #expect(data["operation"] as? String == "notes.body.math.audit")
    #expect(data["changed"] as? Bool == false)
    #expect(data["returnedRecordCount"] as? Int == 14)
    #expect(summary["supportedRecordCount"] as? Int == 10)
    #expect(summary["delegatedRecordCount"] as? Int == 4)
    #expect(summary["gatedRecordCount"] as? Int == 0)
    #expect(summary["rejectedRecordCount"] as? Int == 0)
    #expect(summary["auditRequiresSelector"] as? Bool == false)
    #expect(summary["backendCalls"] as? String == "none")
    #expect(byFamily["math_surface_accounting"]?["status"] as? String == "supported")
    #expect(byFamily["existing_math_result_selector_list"]?["status"] as? String == "supported")
    #expect(byFamily["expression_result_insert"]?["status"] as? String == "supported")
    #expect(byFamily["existing_result_update"]?["status"] as? String == "supported")
    #expect(byFamily["math_note_folder_note_operations"]?["status"] as? String == "supported")
    #expect(byFamily["math_smart_folder_criteria"]?["status"] as? String == "supported")
    #expect(byFamily["math_results_display_preference"]?["status"] as? String == "supported")
    #expect(byFamily["math_results_display_preference"]?["command"] as? String == "body math results --id NOTE_ID --mode insert|suggest|off")
    #expect(byFamily["math_result_suggestion_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["variable_recognition_color_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["variable_value_stepper_ui"]?["status"] as? String == "delegated")
    #expect(byFamily["calculator_math_notes_handoff"]?["status"] as? String == "delegated")
    #expect(byFamily["variable_definition_semantics"]?["status"] as? String == "supported")
    #expect(byFamily["variable_definition_semantics"]?["command"] as? String == "body math variable set --id NOTE_ID --name NAME --value VALUE --expression EXPRESSION")
    #expect(byFamily["variable_expression_auto_update"]?["status"] as? String == "supported")
    #expect(byFamily["variable_expression_auto_update"]?["command"] as? String == "body math variable update --id NOTE_ID --definition-ordinal N --dependent-ordinal N --value VALUE")
    #expect(byFamily["numeric_script_operator_coverage"]?["status"] as? String == "supported")
    #expect(byFamily["numeric_script_operator_coverage"]?["command"] as? String == "body math verify-expression --text EXPRESSION")
    #expect(byFamily["numeric_script_operator_coverage"]?["requiredImplementation"] as? String == "ICCalculateStringScanner.scanStringforRange:previewedExpressionString:")
    #expect(verification["verified"] as? Bool == true)
    #expect(checkNames.contains("official_pages_accounted"))
    #expect(checkNames.contains("private_math_result_workflows_supported"))
    #expect(checkNames.contains("ui_and_calculator_workflows_delegated"))
    #expect(checkNames.contains("no_remaining_math_semantics_gated"))
    #expect(checkNames.contains("backend_calls_none"))
    #expect(result.stdout?.contains("Private math expression") == false)
    #expect(result.stdout?.contains("note-1") == false)
    #expect(implementation.bodyMathInsertDrafts.isEmpty)
    #expect(implementation.bodyMathUpdateDrafts.isEmpty)
    #expect(implementation.bodyMathVariableSetDrafts.isEmpty)
    #expect(implementation.bodyMathVariableUpdateDrafts.isEmpty)
    #expect(implementation.smartFolderCreateDrafts.isEmpty)
    #expect(implementation.smartFolderUpdateDrafts.isEmpty)
    #expect(implementation.searchQueries.isEmpty)
    #expect(implementation.accountSearchQueries.isEmpty)
  }

  @Test func mathWorkflowAuditRejectsSelectorInputWithoutImplementationCalls() throws {
    let implementation = TestNotesImplementation()
    let command = NotesCommand(implementation: implementation)
    let options = try CLIOptionsFixture.parse([
      "body",
      "math",
      "audit",
      "--id",
      "note-1",
      "--text",
      "Private math expression",
      "--ordinal",
      "1",
      "--paragraph",
      "private-paragraph",
      "--query",
      "private result",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected math workflow audit to reject selector input.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
      let rejectedOptions = error.details["options"] ?? ""
      #expect(rejectedOptions.contains("--id"))
      #expect(rejectedOptions.contains("--text"))
      #expect(rejectedOptions.contains("--ordinal"))
      #expect(rejectedOptions.contains("--paragraph"))
      #expect(rejectedOptions.contains("--query"))
      #expect(error.details.values.contains("note-1") == false)
      #expect(error.details.values.contains("Private math expression") == false)
      #expect(error.details.values.contains("1") == false)
      #expect(error.details.values.contains("private-paragraph") == false)
      #expect(error.details.values.contains("private result") == false)
      #expect(implementation.bodyMathInsertDrafts.isEmpty)
      #expect(implementation.bodyMathUpdateDrafts.isEmpty)
      #expect(implementation.smartFolderCreateDrafts.isEmpty)
      #expect(implementation.smartFolderUpdateDrafts.isEmpty)
      #expect(implementation.searchQueries.isEmpty)
      #expect(implementation.accountSearchQueries.isEmpty)
    }
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = try #require(json.data(using: .utf8))
  let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
  return try #require(object)
}
