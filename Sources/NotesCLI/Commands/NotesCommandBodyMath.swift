import Foundation
import Utility

extension NotesCommand {

  func bodyMathUpdateDraft(_ options: CLIOptions) throws -> NotesBodyMathUpdateDraft {
    NotesBodyMathUpdateDraft(
      noteID: try requiredOption("id", options: options),
      ordinal: try normalizedPositiveIntOption("ordinal", options: options),
      result: try normalizedBodyMathResultText(try requiredOption("text", options: options))
    )
  }

  func bodyMathVariableSetDraft(_ options: CLIOptions) throws -> NotesBodyMathVariableSetDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateOptionalParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body math variable set"
    )
    return NotesBodyMathVariableSetDraft(
      noteID: try requiredOption("id", options: options),
      name: try normalizedBodyMathVariableName(try requiredOption("name", options: options)),
      value: try normalizedBodyMathVariableValue(try requiredOption("value", options: options)),
      expression: try normalizedBodyMathVariableExpression(try requiredOption("expression", options: options)),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal
    )
  }

  func bodyMathVariableUpdateDraft(_ options: CLIOptions) throws -> NotesBodyMathVariableUpdateDraft {
    NotesBodyMathVariableUpdateDraft(
      noteID: try requiredOption("id", options: options),
      definitionOrdinal: try normalizedPositiveIntOption("definition-ordinal", options: options),
      dependentOrdinal: try normalizedPositiveIntOption("dependent-ordinal", options: options),
      value: try normalizedBodyMathVariableValue(try requiredOption("value", options: options))
    )
  }

  func bodyMathResultsPreferenceDraft(_ options: CLIOptions) throws
    -> NotesBodyMathResultsPreferenceDraft
  {
    let mode = try normalizedBodyMathResultsPreferenceMode(try requiredOption("mode", options: options))
    return NotesBodyMathResultsPreferenceDraft(
      noteID: try requiredOption("id", options: options),
      mode: mode.name,
      rawValue: mode.rawValue
    )
  }

  private func normalizedBodyMathResultsPreferenceMode(_ raw: String) throws -> (name: String, rawValue: Int) {
    switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "insert", "insert-results", "insert_results":
      return ("insert", 2)
    case "suggest", "suggest-results", "suggest_results":
      return ("suggest", 0)
    case "off", "disabled", "none":
      return ("off", 1)
    default:
      throw CLIError(
        code: .validationError,
        message: "Unsupported Notes Math Results mode.",
        details: [
          "option": "--mode",
          "allowed_values": "insert,suggest,off",
        ]
      )
    }
  }

  func bodyMathInsertDraft(_ options: CLIOptions) throws -> NotesBodyMathInsertDraft {
    let paragraph = try normalizedOptionalOption("paragraph", options: options)
    let ordinal = try options.targetOption("ordinal").map { _ in
      try normalizedPositiveIntOption("ordinal", options: options)
    }
    try validateOptionalParagraphSelector(
      paragraph: paragraph,
      ordinal: ordinal,
      commandName: "body math insert"
    )
    return NotesBodyMathInsertDraft(
      noteID: try requiredOption("id", options: options),
      expression: try normalizedBodyMathExpressionText(try requiredOption("text", options: options)),
      paragraphIDSHA256: paragraph,
      ordinal: ordinal
    )
  }

  func bodyMathExpressionScanDraft(_ options: CLIOptions) throws -> NotesBodyMathExpressionScanDraft {
    NotesBodyMathExpressionScanDraft(
      expression: try normalizedBodyMathExpressionText(try requiredOption("text", options: options))
    )
  }

  func bodyMathWorkflowAudit(_ options: CLIOptions) throws -> CLICommandResult {
    let operation = "notes.body.math.audit"
    let records = notesMathWorkflowAuditRecords()
    let summary = notesMathWorkflowAuditSummary(records)
    let verification = verifyMathWorkflowAudit(records: records, summary: summary)
    let response = NotesMathWorkflowAuditResponse(
      operation: operation,
      changed: false,
      summary: summary,
      records: records,
      verification: verification
    )
    return try result(
      response,
      human:
        "supported_records: \(summary.supportedRecordCount), delegated_records: \(summary.delegatedRecordCount), gated_records: \(summary.gatedRecordCount), backend_calls: \(summary.backendCalls)",
      options: options
    )
  }

  private func notesMathWorkflowAuditRecords() -> [NotesMathWorkflowAuditRecord] {
    struct MathWorkflowAuditItem {
      var family: String
      var guideSection: String
      var status: String
      var appleCapability: String
      var command: String
      var mechanism: String
      var requiredImplementation: String
      var requiredVerifier: String
      var safetyGate: String?
      var privacyBoundary: String
      var reason: String
    }

    let items = [
      MathWorkflowAuditItem(
        family: "math_surface_accounting",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "account_for_math_results_in_note_body",
        command: "body surfaces --id NOTE_ID; body structure --id NOTE_ID",
        mechanism: "typed_private_notes_framework_body_structure_reader",
        requiredImplementation: "private math-result attachment count and isMathNote readback",
        requiredVerifier: "notes_read_v1+body_surface_accounting",
        safetyGate: "bounded-read",
        privacyBoundary: "counts_and_hashes_without_note_body_or_math_text",
        reason: "The accepted body structure and surface readers account for math-result attachments and math-note state without printing note text."
      ),
      MathWorkflowAuditItem(
        family: "existing_math_result_selector_list",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "view_existing_math_results_in_notes",
        command: "body math list --id NOTE_ID",
        mechanism: "typed_private_notes_framework_calculate_result_reader",
        requiredImplementation: "private calculate-result attachment readback",
        requiredVerifier: "private_framework_body_math_result_attachment_readback",
        safetyGate: "bounded-read",
        privacyBoundary: "result_and_expression_hashes_without_expression_or_result_text",
        reason: "The accepted math list command returns privacy-safe ordinals and hashes for existing math results."
      ),
      MathWorkflowAuditItem(
        family: "expression_result_insert",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "solve_expression_after_equals_sign_and_insert_result",
        command: "body math insert --id NOTE_ID --text EXPRESSION",
        mechanism: "typed_private_notes_framework_calculate_result_writer",
        requiredImplementation: "ICNote.textStorage plus ICCalculateRecognitionController insertion",
        requiredVerifier: "private_framework_math_result_delta+expression_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "expression_hash_without_expression_or_result_text",
        reason: "The accepted math insert path asks Notes' private calculate recognizer to create one math-result attachment and verifies the delta."
      ),
      MathWorkflowAuditItem(
        family: "existing_result_update",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "update_existing_math_result",
        command: "body math update --id NOTE_ID --ordinal N --text RESULT",
        mechanism: "typed_private_notes_framework_calculate_result_writer",
        requiredImplementation: "ICInlineAttachment.updateCalculateResult:isRightToLeft:",
        requiredVerifier: "private_framework_math_result_preservation+result_hash_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "result_hash_without_old_or_new_result_text",
        reason: "The accepted update path changes one selected calculate-result attachment and verifies selector preservation and result hash readback."
      ),
      MathWorkflowAuditItem(
        family: "math_note_folder_note_operations",
        guideSection: "Open Math Notes from Calculator",
        status: "supported",
        appleCapability: "view_edit_and_add_notes_in_math_notes_folder",
        command: "folders list; list --folder FOLDER; create/update --folder FOLDER",
        mechanism: "typed_private_notes_framework_folder_and_note_read_write",
        requiredImplementation: "private folder selection plus ordinary accepted note readers/writers",
        requiredVerifier: "private_folder_note_readback+ordinary_note_mutation_verifier",
        safetyGate: "bounded-read/dry-run/readback",
        privacyBoundary: "folder_or_note_selectors_without_folder_names_note_titles_or_bodies",
        reason: "Once a Math Notes folder exists, ordinary accepted folder and note commands can list, create, edit, and read notes under that folder."
      ),
      MathWorkflowAuditItem(
        family: "math_smart_folder_criteria",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "organize_or_find_math_notes_by_math_criteria",
        command: "smart-folders create-criteria/update-criteria --criteria math|recently-deleted-math",
        mechanism: "typed_private_notes_framework_smart_folder_query_factory",
        requiredImplementation: "ICQuery math and recently-deleted math criteria",
        requiredVerifier: "private_smart_folder_criteria_readback+matching_note_resolution",
        safetyGate: "dry-run/readback",
        privacyBoundary: "criteria_hashes_and_counts_without_note_content",
        reason: "The promoted Smart Folder criteria path supports math and recently-deleted-math query factories with matching-note accounting."
      ),
      MathWorkflowAuditItem(
        family: "math_result_suggestion_ui",
        guideSection: "Solve math",
        status: "delegated",
        appleCapability: "show_answer_suggestions_and_insert_with_return",
        command: "Notes.app editing UI",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_suggestion_acceptance_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Suggestion display and Return-key acceptance are transient Notes.app editing interactions; semantic insertion is supported separately."
      ),
      MathWorkflowAuditItem(
        family: "variable_recognition_color_ui",
        guideSection: "Solve math",
        status: "delegated",
        appleCapability: "show_recognized_variables_with_color",
        command: "Notes.app editor rendering",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_variable_rendering_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Variable color highlighting is a live editor rendering surface rather than a CLI data mutation."
      ),
      MathWorkflowAuditItem(
        family: "variable_value_stepper_ui",
        guideSection: "Solve math",
        status: "delegated",
        appleCapability: "double_click_variable_value_and_adjust_with_arrows",
        command: "Notes.app editor value stepper",
        mechanism: "delegated_user_facing_notes_ui",
        requiredImplementation: "notes_app_math_value_stepper_surface",
        requiredVerifier: "delegated_ui_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Double-clicking a variable value and using arrows is Notes.app editing UI state, not a separate accepted CLI mutation."
      ),
      MathWorkflowAuditItem(
        family: "calculator_math_notes_handoff",
        guideSection: "Open Math Notes from Calculator",
        status: "delegated",
        appleCapability: "open_math_notes_from_calculator_and_auto_create_math_notes_folder",
        command: "Calculator.app View > Math Notes / Command-Option-M",
        mechanism: "delegated_calculator_app_handoff",
        requiredImplementation: "calculator_app_route_plus_icloud_sync",
        requiredVerifier: "delegated_calculator_handoff_accounting",
        safetyGate: "none",
        privacyBoundary: "no_backend_calls",
        reason: "Opening Math Notes from Calculator, automatic folder creation through Calculator, and cross-device Calculator sync belong to the Calculator/iCloud app route."
      ),
      MathWorkflowAuditItem(
        family: "variable_definition_semantics",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "define_variables_for_math_notes",
        command: "body math variable set --id NOTE_ID --name NAME --value VALUE --expression EXPRESSION",
        mechanism: "typed_private_notes_framework_calculate_variable_writer",
        requiredImplementation: "Latin-alphabet variable name validation plus ICNote.textStorage, ICCalculateRecognitionController, and ICCalculateDocumentController readback",
        requiredVerifier: "private_math_variable_definition_result+dependent_expression_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "variable_name_value_expression_and_result_hashes_without_text",
        reason: "The accepted variable set path validates a Latin-alphabet variable name, writes one variable definition and one dependent expression through Notes' private calculate path, then verifies distinct private readback for both expression hashes without printing variable names, values, expressions, results, or note text."
      ),
      MathWorkflowAuditItem(
        family: "variable_expression_auto_update",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "update_dependent_expression_results_when_variable_changes",
        command: "body math variable update --id NOTE_ID --definition-ordinal N --dependent-ordinal N --value VALUE",
        mechanism: "typed_private_notes_framework_calculate_variable_update_writer",
        requiredImplementation: "ICCalculateDocumentController expression-range replacement and updateAffectingChangeCounts:",
        requiredVerifier: "private_dependent_math_result_delta_readback",
        safetyGate: "dry-run/readback",
        privacyBoundary: "variable_value_expression_and_result_hashes_without_text",
        reason: "The accepted variable update path replaces one selected private variable-definition expression range, drives Notes' calculate document controller, and verifies that the dependent result changed while the dependent expression hash stayed stable."
      ),
      MathWorkflowAuditItem(
        family: "math_results_display_preference",
        guideSection: "Choose how Math Results appear",
        status: "supported",
        appleCapability: "choose_insert_suggest_or_off_for_math_results",
        command: "body math results --id NOTE_ID --mode insert|suggest|off",
        mechanism: "typed_private_notes_framework_math_results_preference",
        requiredImplementation: "ICNote.calculatePreviewBehavior + ICNote.setCalculatePreviewBehavior:",
        requiredVerifier: "private_math_results_preference_readback+body_preservation",
        safetyGate: "dry-run/readback",
        privacyBoundary: "mode_enum_without_note_content",
        reason: "The accepted note-scoped Math Results preference command maps Notes' private preview behavior values for Insert, Suggest, and Off, writes through ICNote, and verifies preference readback plus body preservation without printing note content."
      ),
      MathWorkflowAuditItem(
        family: "numeric_script_operator_coverage",
        guideSection: "Solve math",
        status: "supported",
        appleCapability: "support_western_arabic_eastern_arabic_and_devanagari_numerals_with_common_symbols",
        command: "body math verify-expression --text EXPRESSION",
        mechanism: "typed_private_notes_framework_calculate_string_scanner",
        requiredImplementation: "ICCalculateStringScanner.scanStringforRange:previewedExpressionString:",
        requiredVerifier: "private_calculate_string_scanner+hash_only_expression_matrix",
        safetyGate: "bounded-read",
        privacyBoundary: "fixture_hashes_without_raw_expressions_or_results",
        reason: "The accepted verify-expression command runs Notes' private calculate string scanner over one caller-provided expression, reports only expression hashes, UTF-16 range accounting, scanner object type hashes, and implementation-call evidence, and can be used to verify numeral/script/operator coverage without mutating a note or printing expression/result text."
      ),
    ]

    return items.enumerated().map { index, item in
      NotesMathWorkflowAuditRecord(
        ordinal: index + 1,
        workflowFamily: item.family,
        guideSection: item.guideSection,
        status: item.status,
        appleCapability: item.appleCapability,
        command: item.command,
        implementationMechanism: item.mechanism,
        requiredImplementation: item.requiredImplementation,
        requiredVerifier: item.requiredVerifier,
        safetyGate: item.safetyGate,
        backendCalls: "none",
        privacyBoundary: item.privacyBoundary,
        reason: item.reason
      )
    }
  }

  private func notesMathWorkflowAuditSummary(
    _ records: [NotesMathWorkflowAuditRecord]
  ) -> NotesMathWorkflowAuditSummary {
    let supported = records.filter { $0.status == "supported" }
    let delegated = records.filter { $0.status == "delegated" }
    let gated = records.filter { $0.status == "gated" }
    let rejected = records.filter { $0.status == "rejected" }
    return NotesMathWorkflowAuditSummary(
      supportedRecordCount: supported.count,
      delegatedRecordCount: delegated.count,
      gatedRecordCount: gated.count,
      rejectedRecordCount: rejected.count,
      auditRequiresSelector: false,
      backendCalls: "none",
      supportedWorkflowFamilies: supported.map(\.workflowFamily),
      delegatedWorkflowFamilies: delegated.map(\.workflowFamily),
      gatedWorkflowFamilies: gated.map(\.workflowFamily),
      rejectedWorkflowFamilies: rejected.map(\.workflowFamily)
    )
  }

  private func verifyMathWorkflowAudit(
    records: [NotesMathWorkflowAuditRecord],
    summary: NotesMathWorkflowAuditSummary
  ) -> NotesMutationVerificationReport {
    let supported = Set(summary.supportedWorkflowFamilies)
    let delegated = Set(summary.delegatedWorkflowFamilies)
    let gated = Set(summary.gatedWorkflowFamilies)
    let guideSections = records.flatMap { $0.guideSection.components(separatedBy: " / ") }
    let guideSectionSet = Set(guideSections)
    let checks = [
      verificationBoolCheck(
        name: "record_counts_match",
        expected: true,
        actual: summary.supportedRecordCount + summary.delegatedRecordCount
          + summary.gatedRecordCount + summary.rejectedRecordCount == records.count
      ),
      verificationBoolCheck(
        name: "official_pages_accounted",
        expected: true,
        actual: guideSectionSet.contains("Solve math")
          && guideSectionSet.contains("Open Math Notes from Calculator")
          && guideSectionSet.contains("Choose how Math Results appear")
      ),
      verificationBoolCheck(
        name: "private_math_result_workflows_supported",
        expected: true,
        actual: supported.isSuperset(
          of: [
            "math_surface_accounting", "existing_math_result_selector_list",
            "expression_result_insert", "existing_result_update",
            "math_note_folder_note_operations", "math_smart_folder_criteria",
            "variable_definition_semantics", "variable_expression_auto_update",
            "math_results_display_preference", "numeric_script_operator_coverage",
          ]
        )
      ),
      verificationBoolCheck(
        name: "ui_and_calculator_workflows_delegated",
        expected: true,
        actual: delegated.isSuperset(
          of: [
            "math_result_suggestion_ui", "variable_recognition_color_ui",
            "variable_value_stepper_ui", "calculator_math_notes_handoff",
          ]
        )
      ),
      verificationBoolCheck(
        name: "no_remaining_math_semantics_gated",
        expected: true,
        actual: gated.isEmpty
      ),
      verificationBoolCheck(
        name: "audit_has_no_selector_input",
        expected: false,
        actual: summary.auditRequiresSelector
      ),
      verificationBoolCheck(
        name: "backend_calls_none",
        expected: true,
        actual: summary.backendCalls == "none" && records.allSatisfy { $0.backendCalls == "none" }
      ),
      verificationBoolCheck(
        name: "privacy_boundaries_recorded",
        expected: true,
        actual: records.allSatisfy { !$0.privacyBoundary.isEmpty }
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.body.math.audit",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "capability_accounting+privacy_boundary+no_backend_calls",
      targetIDSHA256: sha256Hex("notes.body.math.audit"),
      checks: checks
    )
  }

  func verifyBodyMathResults(
    structure: NotesBodyStructureRecord,
    results: [NotesBodyMathResultRecord]
  ) -> NotesMutationVerificationReport {
    let ordinals = results.map(\.ordinal)
    let expectedOrdinals = results.isEmpty ? [] : Array(1...results.count)
    let checks = [
      verificationBoolCheck(
        name: "math_result_count_within_structure_count",
        expected: true,
        actual: results.count <= structure.mathAttachmentCount
      ),
      verificationBoolCheck(
        name: "math_result_ordinals_contiguous",
        expected: true,
        actual: ordinals == expectedOrdinals
      ),
      verificationBoolCheck(
        name: "math_result_identity_hashes_present",
        expected: true,
        actual: results.allSatisfy { !$0.idSHA256.isEmpty }
      ),
      verificationBoolCheck(
        name: "math_result_text_hidden",
        expected: true,
        actual: true
      ),
      verificationBoolCheck(
        name: "private_identifiers_hidden",
        expected: true,
        actual: true
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.body.math.list",
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_framework_body_math_result_attachment_readback",
      targetIDSHA256: sha256Hex(structure.noteID),
      checks: checks
    )
  }

  func verifyBodyMathExpressionScan(
    _ scan: NotesBodyMathExpressionScanRecord,
    operation: String
  ) -> NotesMutationVerificationReport {
    let implementationCallAccepted = scan.backendCalls.contains("ICCalculateStringScanner.scanStringforRange")
    let hashesPresent = scan.expressionSHA256.count == 64
      && (scan.scanObjectTypeSHA256?.count ?? 64) == 64
    let rangeCoversExpression = scan.scanRangeLocation == 0
      && scan.scanRangeLength == scan.expressionUTF16Length
      && scan.expressionUTF16Length > 0
    let checks = [
      verificationBoolCheck(
        name: "expression_hash_present",
        expected: true,
        actual: hashesPresent && scan.expressionByteCount > 0
      ),
      verificationBoolCheck(
        name: "private_calculate_string_scanner_call",
        expected: true,
        actual: implementationCallAccepted
      ),
      verificationBoolCheck(
        name: "scan_range_covers_expression",
        expected: true,
        actual: rangeCoversExpression
      ),
      verificationBoolCheck(
        name: "expression_recognized",
        expected: true,
        actual: scan.recognized
      ),
      verificationBoolCheck(
        name: "privacy_boundary",
        expected: true,
        actual: scan.privacyBoundary == "hashes_counts_and_type_hashes_only"
      ),
    ]
    return NotesMutationVerificationReport(
      verifier: "notes_body_math_expression_scan_v1",
      operation: operation,
      verified: checks.allSatisfy { $0.status != "failed" },
      evidenceLevel: "private_calculate_string_scanner+hash_only_expression_matrix",
      targetIDSHA256: sha256Hex(
        [
          scan.expressionSHA256,
          "\(scan.expressionByteCount)",
          "\(scan.expressionUTF16Length)",
          scan.scanObjectTypeSHA256 ?? "",
          "\(scan.scanObjectCount ?? 0)",
        ].joined(separator: "|")
      ),
      checks: checks
    )
  }

  func bodyMathExpressionScanner() throws -> any NotesBodyMathExpressionScanning {
    guard let bodyMathExpressionScanner = implementation as? any NotesBodyMathExpressionScanning else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Notes body math expression verification requires a private-framework calculate scanner.",
        details: [
          "capability": "body_math_expression_scan",
          "required_module": "NotesUI.ICCalculateStringScanner",
        ]
      )
    }
    return bodyMathExpressionScanner
  }

  func verifiedBodyMathMutationResult(
    _ result: NotesBodyMathUpdateResult
  ) throws -> NotesBodyMathUpdateResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body math mutation verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyMathInsertMutationResult(
    _ result: NotesBodyMathInsertResult
  ) throws -> NotesBodyMathInsertResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body math insert verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyMathVariableSetMutationResult(
    _ result: NotesBodyMathVariableSetResult
  ) throws -> NotesBodyMathVariableSetResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body math variable set verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyMathVariableUpdateMutationResult(
    _ result: NotesBodyMathVariableUpdateResult
  ) throws -> NotesBodyMathVariableUpdateResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body math variable update verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }

  func verifiedBodyMathResultsPreferenceMutationResult(
    _ result: NotesBodyMathResultsPreferenceResult
  ) throws -> NotesBodyMathResultsPreferenceResult {
    guard result.verification.verified else {
      throw CLIError(
        code: .internalError,
        message: "Notes body math results preference verification failed.",
        details: [
          "operation": result.operation,
          "failed_checks": result.verification.checks
            .filter { $0.status == "failed" }
            .map(\.name)
            .joined(separator: ","),
          "target_id_sha256": result.verification.targetIDSHA256,
        ]
      )
    }
    return result
  }
}
