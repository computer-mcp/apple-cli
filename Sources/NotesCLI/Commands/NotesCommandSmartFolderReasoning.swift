import Foundation
import Utility

extension NotesCommand {

  func verifySmartFolderCriteria(
    smartFolder: NotesSmartFolderRecord,
    notes: [NotesNoteSummary]
  ) throws -> NotesMutationVerificationReport {
    let readbackFolders = try smartFolderReader().listSmartFolders(account: smartFolder.accountName, limit: 2_000)
    let readback = readbackFolders.first { $0.id == smartFolder.id }
    let readbackNotes = try smartFolderReader().listSmartFolderNotes(smartFolderID: smartFolder.id, limit: 2_000)
    let criteria = smartFolder.criteria

    var checks: [NotesVerificationCheckRecord] = [
      verificationBoolCheck(name: "smart_folder_readback", expected: true, actual: readback != nil),
      verificationBoolCheck(name: "query_present", expected: true, actual: smartFolder.queryPresent),
      verificationBoolCheck(name: "criteria_summary_present", expected: true, actual: criteria != nil),
      verificationBoolCheck(
        name: "criteria_kind_present",
        expected: true,
        actual: criteria?.queryKind.isEmpty == false
      ),
      verificationBoolCheck(
        name: "matching_note_readback",
        expected: true,
        actual: readbackNotes.count >= notes.count
      ),
    ]

    if let readback {
      checks.append(
        verificationBoolCheck(
          name: "query_hash_preserved",
          expected: true,
          actual: smartFolder.querySHA256 == nil || smartFolder.querySHA256 == readback.querySHA256
        )
      )
      checks.append(
        verificationBoolCheck(
          name: "criteria_filter_count_preserved",
          expected: true,
          actual: criteria?.filterCount == readback.criteria?.filterCount
        )
      )
      checks.append(
        verificationBoolCheck(
          name: "criteria_tag_selection_preserved",
          expected: true,
          actual: (criteria?.tagSelection != nil) == (readback.criteria?.tagSelection != nil)
        )
      )
    } else {
      checks.append(verificationBoolCheck(name: "query_hash_preserved", expected: true, actual: false))
      checks.append(verificationBoolCheck(name: "criteria_filter_count_preserved", expected: true, actual: false))
      checks.append(verificationBoolCheck(name: "criteria_tag_selection_preserved", expected: true, actual: false))
    }

    if let visibleNoteCount = smartFolder.visibleNoteCount {
      checks.append(
        verificationBoolCheck(
          name: "visible_note_count_bound",
          expected: true,
          actual: readbackNotes.count <= visibleNoteCount
        )
      )
    } else {
      checks.append(NotesVerificationCheckRecord(name: "visible_note_count_bound", status: "not_applicable"))
    }

    var warnings: [String] = []
    if criteria == nil {
      warnings.append("criteria_summary_unavailable")
    }

    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.smart-folders.criteria",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_smart_folder_criteria+matching_note_readback",
      targetIDSHA256: sha256Hex(smartFolder.id),
      checks: checks,
      warnings: warnings
    )
  }

  func smartFolderCriteriaExplanation(
    _ criteria: NotesSmartFolderCriteriaSummary?
  ) -> NotesSmartFolderCriteriaExplanationSummary {
    guard let criteria else {
      return NotesSmartFolderCriteriaExplanationSummary(
        queryKind: "unavailable",
        filterCount: 0,
        tagSelectionPresent: false,
        predicateHashPresent: false,
        multiCondition: false,
        supportedReadFamilies: [],
        gatedMutationFamilies: ["criteria_summary_unavailable"],
        filters: []
      )
    }

    let conditionCount = criteria.filters.count + (criteria.tagSelection == nil ? 0 : 1)
    let multiCondition = conditionCount > 1 || criteria.queryKind == "mixed_selection"
    var supportedReadFamilies = criteria.filters.map(\.kind)
    if criteria.tagSelection != nil {
      supportedReadFamilies.append("tag_selection")
    }
    if criteria.predicatePresent {
      supportedReadFamilies.append("predicate_hash")
    }
    supportedReadFamilies = Array(Set(supportedReadFamilies)).sorted()

    var gatedMutationFamilies = ["user_editable_criteria_construction"]
    if multiCondition {
      gatedMutationFamilies.append("multi_condition_update")
    }
    let gatedFilterFamilies = criteria.filters
      .map { "filter_\($0.kind)_update" }
      .filter { $0 != "filter_tags_update" || criteria.tagSelection == nil || multiCondition }
    gatedMutationFamilies.append(contentsOf: gatedFilterFamilies)
    gatedMutationFamilies = Array(Set(gatedMutationFamilies)).sorted()

    let filters = criteria.filters.enumerated().map { offset, filter in
      NotesSmartFolderCriteriaFilterExplanation(
        ordinal: offset + 1,
        kind: filter.kind,
        readbackStatus: filter.rawValuePresent ? "hash_only" : "summarized",
        mutationStatus: multiCondition ? "gated_multi_condition" : "gated_filter_update",
        selectionType: filter.selectionType,
        inclusionType: filter.inclusionType,
        joinOperator: filter.joinOperator,
        rawValuePresent: filter.rawValuePresent,
        rawValueLength: filter.rawValueLength,
        rawValueSHA256: filter.rawValueSHA256,
        count: filter.count,
        includedCount: filter.includedCount,
        excludedCount: filter.excludedCount,
        hasPrimaryDate: filter.hasPrimaryDate,
        hasSecondaryDate: filter.hasSecondaryDate,
        hasRelativeRange: filter.hasRelativeRange,
        participantUserIDSHA256s: filter.participantUserIDSHA256s
      )
    }

    return NotesSmartFolderCriteriaExplanationSummary(
      queryKind: criteria.queryKind,
      filterCount: criteria.filterCount,
      tagSelectionPresent: criteria.tagSelection != nil,
      predicateHashPresent: criteria.predicateFormatSHA256 != nil,
      multiCondition: multiCondition,
      supportedReadFamilies: supportedReadFamilies,
      gatedMutationFamilies: gatedMutationFamilies,
      filters: filters
    )
  }

  func smartFolderMatchReasonRecords(
    notes: [NotesNoteSummary],
    criteria: NotesSmartFolderCriteriaSummary?,
    explanation: NotesSmartFolderCriteriaExplanationSummary
  ) throws -> [NotesSmartFolderMatchReasonRecord] {
    let reasoningStatus =
      explanation.queryKind == "unavailable"
      ? "criteria_summary_unavailable"
      : "criteria_family_summary"
    let stateReader = try noteStateReader()
    let structureReader = try bodyStructureReader()
    let attachmentReader = explanation.filters.contains { $0.kind == "attachments" }
      ? try self.attachmentReader()
      : nil
    let needsTagDetail =
      explanation.tagSelectionPresent || explanation.filters.contains { $0.kind == "tags" }
    return try notes.map { note in
      let detail = needsTagDetail ? try implementation.readNote(id: note.id) : nil
      let state = try stateReader.readNoteState(noteID: note.id)
      let structure = try structureReader.readBodyStructure(noteID: note.id)
      let attachments = try attachmentReader?.listAttachments(noteID: note.id, limit: 2_000) ?? []
      let filterReasons = smartFolderFilterReasonRecords(
        filters: explanation.filters,
        criteriaFilters: criteria?.filters ?? [],
        note: note,
        detail: detail,
        state: state,
        structure: structure,
        attachments: attachments,
        tagSelection: criteria?.tagSelection
      )
      let tagSelectionReason = smartFolderTagSelectionReason(
        criteria?.tagSelection,
        detail: detail
      )
      let booleanTrace = smartFolderBooleanTrace(
        criteria: criteria,
        explanation: explanation,
        filterReasons: filterReasons,
        tagSelectionReason: tagSelectionReason
      )
      return NotesSmartFolderMatchReasonRecord(
        note: note,
        matchStatus: "matched_by_private_smart_folder_readback",
        reasoningStatus: booleanTrace?.status == "verified" ? "multi_condition_boolean_trace" : reasoningStatus,
        criteriaFamilies: explanation.supportedReadFamilies,
        filters: explanation.filters,
        filterReasons: filterReasons,
        tagSelectionReason: tagSelectionReason,
        booleanTrace: booleanTrace,
        tagSelectionPresent: explanation.tagSelectionPresent,
        predicateHashPresent: explanation.predicateHashPresent,
        multiCondition: explanation.multiCondition,
        gatedReasoningFamilies: smartFolderMatchReasoningGates(
          explanation,
          filterReasons: filterReasons,
          tagSelectionReason: tagSelectionReason,
          booleanTrace: booleanTrace
        )
      )
    }
  }

  private func smartFolderMatchReasoningGates(
    _ explanation: NotesSmartFolderCriteriaExplanationSummary,
    filterReasons: [NotesSmartFolderFilterReasonRecord] = [],
    tagSelectionReason: NotesSmartFolderFilterReasonRecord? = nil,
    booleanTrace: NotesSmartFolderBooleanTraceRecord? = nil
  ) -> [String] {
    var gates = Set<String>()
    let unsupportedFilterGates = filterReasons
      .flatMap(\.gatedReasoningFamilies)
      .filter { $0 != "raw_value_comparison" }
    gates.formUnion(unsupportedFilterGates)
    if let tagSelectionReason {
      gates.formUnion(tagSelectionReason.gatedReasoningFamilies)
    } else if explanation.tagSelectionPresent {
      gates.insert("tag_selection_readback")
    }
    if filterReasons.isEmpty, !explanation.filters.isEmpty {
      gates.insert("per_filter_boolean_evaluation")
    }
    let rawComparisonStatusByOrdinal = Dictionary(
      uniqueKeysWithValues: filterReasons.map { ($0.ordinal, $0.rawValueComparisonStatus) }
    )
    if explanation.filters.contains(where: { filter in
      guard filter.rawValuePresent else { return false }
      let status = rawComparisonStatusByOrdinal[filter.ordinal]
      return status != "verified_hash_match" && status != "verified_semantic_value"
    }) {
      gates.insert("raw_value_comparison")
    }
    if let booleanTrace {
      gates.formUnion(booleanTrace.gatedReasoningFamilies)
    } else if explanation.multiCondition {
      gates.insert("multi_condition_boolean_trace")
    }
    if explanation.queryKind == "unavailable" {
      gates.insert("criteria_summary_unavailable")
    }
    return gates.sorted()
  }

  private func smartFolderBooleanTrace(
    criteria: NotesSmartFolderCriteriaSummary?,
    explanation: NotesSmartFolderCriteriaExplanationSummary,
    filterReasons: [NotesSmartFolderFilterReasonRecord],
    tagSelectionReason: NotesSmartFolderFilterReasonRecord?
  ) -> NotesSmartFolderBooleanTraceRecord? {
    guard explanation.multiCondition else {
      return nil
    }

    var gates = Set<String>()
    let reasonsByOrdinal = Dictionary(uniqueKeysWithValues: filterReasons.map { ($0.ordinal, $0) })
    let filterCount = explanation.filters.count
    var provedFilterCount = 0
    var failedFilterCount = 0
    var unknownFilterCount = 0

    if filterReasons.count != filterCount {
      gates.insert("filter_reasoning_missing")
    }

    for filter in explanation.filters {
      guard let reason = reasonsByOrdinal[filter.ordinal] else {
        unknownFilterCount += 1
        continue
      }
      gates.formUnion(reason.gatedReasoningFamilies)
      if !reason.gatedReasoningFamilies.isEmpty {
        unknownFilterCount += 1
        continue
      }
      switch reason.actualBool {
      case true:
        provedFilterCount += 1
      case false:
        failedFilterCount += 1
      case nil:
        unknownFilterCount += 1
      }
    }

    let tagSelectionProved: Bool?
    if explanation.tagSelectionPresent {
      guard let tagSelectionReason else {
        gates.insert("tag_selection_readback")
        return NotesSmartFolderBooleanTraceRecord(
          status: "partial_gated_filters",
          joinOperator: criteria?.joinOperator,
          conditionCount: filterCount + 1,
          filterCount: filterCount,
          provedConditionCount: provedFilterCount,
          failedConditionCount: failedFilterCount,
          unknownConditionCount: unknownFilterCount + 1,
          provedFilterCount: provedFilterCount,
          failedFilterCount: failedFilterCount,
          unknownFilterCount: unknownFilterCount,
          tagSelectionPresent: true,
          tagSelectionProved: nil,
          predicateHashPresent: explanation.predicateHashPresent,
          gatedReasoningFamilies: Array(gates.union(["multi_condition_boolean_trace"])).sorted()
        )
      }
      gates.formUnion(tagSelectionReason.gatedReasoningFamilies)
      if !tagSelectionReason.gatedReasoningFamilies.isEmpty {
        tagSelectionProved = nil
      } else {
        tagSelectionProved = tagSelectionReason.actualBool
      }
    } else {
      tagSelectionProved = nil
    }

    let tagUnknownCount = explanation.tagSelectionPresent && tagSelectionProved == nil ? 1 : 0
    let tagProvedCount = tagSelectionProved == true ? 1 : 0
    let tagFailedCount = tagSelectionProved == false ? 1 : 0
    let unknownConditionCount = unknownFilterCount + tagUnknownCount
    let provedConditionCount = provedFilterCount + tagProvedCount
    let failedConditionCount = failedFilterCount + tagFailedCount
    let fullyKnown = gates.isEmpty && unknownConditionCount == 0
    let status = fullyKnown ? "verified" : "partial_gated_filters"
    let allKnownConditionsPassed = fullyKnown ? (failedConditionCount == 0) : nil
    if !fullyKnown {
      gates.insert("multi_condition_boolean_trace")
    }

    return NotesSmartFolderBooleanTraceRecord(
      status: status,
      joinOperator: criteria?.joinOperator,
      conditionCount: filterCount + (explanation.tagSelectionPresent ? 1 : 0),
      filterCount: filterCount,
      provedConditionCount: provedConditionCount,
      failedConditionCount: failedConditionCount,
      unknownConditionCount: unknownConditionCount,
      provedFilterCount: provedFilterCount,
      failedFilterCount: failedFilterCount,
      unknownFilterCount: unknownFilterCount,
      tagSelectionPresent: explanation.tagSelectionPresent,
      tagSelectionProved: tagSelectionProved,
      predicateHashPresent: explanation.predicateHashPresent,
      allKnownConditionsPassed: allKnownConditionsPassed,
      gatedReasoningFamilies: gates.sorted()
    )
  }

  private func smartFolderFilterReasonRecords(
    filters: [NotesSmartFolderCriteriaFilterExplanation],
    criteriaFilters: [NotesSmartFolderCriteriaFilter],
    note: NotesNoteSummary,
    detail: NotesNoteDetail?,
    state: NotesNoteStateRecord,
    structure: NotesBodyStructureRecord,
    attachments: [NotesAttachmentRecord],
    tagSelection: NotesSmartFolderTagCriteria?
  ) -> [NotesSmartFolderFilterReasonRecord] {
    filters.enumerated().map { offset, filter in
      smartFolderFilterReasonRecord(
        filter: filter,
        criteriaFilter: criteriaFilters.indices.contains(offset) ? criteriaFilters[offset] : nil,
        note: note,
        detail: detail,
        state: state,
        structure: structure,
        attachments: attachments,
        tagSelection: tagSelection
      )
    }
  }

  private func smartFolderFilterReasonRecord(
    filter: NotesSmartFolderCriteriaFilterExplanation,
    criteriaFilter: NotesSmartFolderCriteriaFilter?,
    note: NotesNoteSummary,
    detail: NotesNoteDetail?,
    state: NotesNoteStateRecord,
    structure: NotesBodyStructureRecord,
    attachments: [NotesAttachmentRecord],
    tagSelection: NotesSmartFolderTagCriteria?
  ) -> NotesSmartFolderFilterReasonRecord {
    let rawGate = filter.rawValuePresent ? ["raw_value_comparison"] : []
    switch filter.kind {
    case "tags":
      return smartFolderTagFilterReason(
        filter,
        detail: detail,
        tagSelection: tagSelection,
        rawGates: rawGate
      )
    case "pinned":
      return smartFolderBoolFilterReason(filter, actual: state.isPinned, source: "note_state", rawGates: rawGate)
    case "shared":
      return smartFolderBoolFilterReason(
        filter,
        actual: state.isSharedViaICloud || state.isSharedViaICloudFolder,
        source: "note_state",
        rawGates: rawGate
      )
    case "locked":
      return smartFolderBoolFilterReason(
        filter,
        actual: state.isPasswordProtected || state.isPasswordProtectedAndLocked == true,
        source: "note_state",
        rawGates: rawGate
      )
    case "participants":
      return smartFolderParticipantFilterReason(filter, state: state, rawGates: rawGate)
    case "mentions":
      return smartFolderMentionFilterReason(filter, structure: structure, rawGates: rawGate)
    case "folders":
      return smartFolderFolderFilterReason(filter, criteriaFilter: criteriaFilter, state: state, rawGates: rawGate)
    case "date_created", "date_edited", "date":
      return smartFolderDateFilterReason(filter, criteriaFilter: criteriaFilter, note: note, rawGates: rawGate)
    case "attachments":
      return smartFolderAttachmentFilterReason(filter, attachments: attachments, rawGates: rawGate)
    case "checklists":
      return smartFolderChecklistFilterReason(filter, structure: structure, rawGates: rawGate)
    case "math":
      return smartFolderBoolFilterReason(
        filter,
        actual: state.isMathNote ? true : structure.mathAttachmentCount.map { $0 > 0 },
        source: "note_state+body_structure",
        rawGates: rawGate
      )
    case "call":
      return smartFolderBoolFilterReason(filter, actual: state.isCallNote, source: "note_state", rawGates: rawGate)
    case "system_paper", "system-paper":
      return smartFolderBoolFilterReason(filter, actual: state.isSystemPaper, source: "note_state", rawGates: rawGate)
    default:
      var gates = rawGate
      gates.append("filter_\(filter.kind)_boolean_evaluation")
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "gated",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "criteria_summary_only",
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }
  }

  private func smartFolderBoolFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    actual: Bool?,
    source: String,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    let evaluatedActual: Bool?
    switch filter.inclusionType {
    case 0:
      evaluatedActual = actual.map { !$0 }
    case 1, nil:
      evaluatedActual = actual
    case let unsupported?:
      var gates = rawGates
      gates.append("filter_\(filter.kind)_inclusion_type_\(unsupported)_boolean_evaluation")
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "gated",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: source,
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }
    guard let evaluatedActual else {
      return smartFolderUnavailableBodyReason(filter, source: source, count: nil, rawGates: rawGates)
    }
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: filter.inclusionType == nil ? "boolean_readback" : "inclusion_boolean_readback",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: source,
      actualBool: evaluatedActual,
      rawValueComparisonStatus: smartFolderSemanticRawValueStatus(filter),
      gatedReasoningFamilies: smartFolderSemanticRawGates(rawGates)
    )
  }

  private func smartFolderSemanticRawValueStatus(
    _ filter: NotesSmartFolderCriteriaFilterExplanation
  ) -> String {
    filter.rawValuePresent ? "verified_semantic_value" : "not_applicable"
  }

  private func smartFolderSemanticRawGates(_ rawGates: [String]) -> [String] {
    rawGates.filter { $0 != "raw_value_comparison" }
  }

  private func smartFolderParticipantFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    state: NotesNoteStateRecord,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    let participantCount = state.participantCount ?? 0
    let hasParticipants = participantCount > 0
    let selectedParticipantMatched = smartFolderSelectedHashesMatch(
      expected: filter.participantUserIDSHA256s,
      actual: state.participantUserIDSHA256s
    )
    let hasSpecificSelection = filter.rawValuePresent
      || (filter.count ?? 0) > 0
      || (filter.includedCount ?? 0) > 0
      || (filter.excludedCount ?? 0) > 0
      || !filter.participantUserIDSHA256s.isEmpty
    let evaluatedActual: Bool
    switch filter.inclusionType {
    case 0:
      evaluatedActual = selectedParticipantMatched.map { !$0 } ?? !hasParticipants
    case 1, nil:
      evaluatedActual = selectedParticipantMatched ?? hasParticipants
    case let unsupported?:
      var gates = rawGates
      gates.append("filter_participants_inclusion_type_\(unsupported)_boolean_evaluation")
      if hasSpecificSelection {
        gates.append("participant_identifier_comparison")
      }
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "gated",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "note_state.participantCount",
        actualCount: participantCount,
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    if let selectedParticipantMatched {
      var gates = smartFolderSemanticRawGates(rawGates)
      if !evaluatedActual {
        gates.append("filter_participants_value_comparison")
      }
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: selectedParticipantMatched
          ? "participant_identifier_hash_match_readback"
          : "participant_identifier_hash_mismatch_readback",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "note_state.participantUserIDSHA256s+criteria_hash",
        expectedBool: filter.inclusionType == 0 ? false : true,
        actualBool: evaluatedActual,
        expectedCount: filter.participantUserIDSHA256s.count,
        actualCount: participantCount,
        rawValueComparisonStatus: "verified_hash_match",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    var gates = smartFolderSemanticRawGates(rawGates)
    if hasSpecificSelection {
      gates.append("participant_identifier_comparison")
    }
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: hasSpecificSelection
        ? "participant_count_readback_partial"
        : "participant_count_readback",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: "note_state.participantCount",
      expectedBool: filter.inclusionType == 0 ? false : true,
      actualBool: evaluatedActual,
      expectedCount: filter.count,
      actualCount: participantCount,
      rawValueComparisonStatus: filter.rawValuePresent
        ? "gated_hash_only"
        : (hasSpecificSelection ? "count_readback_only" : "verified_semantic_value"),
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func smartFolderTagFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    detail: NotesNoteDetail?,
    tagSelection: NotesSmartFolderTagCriteria?,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    if let hashMatch = smartFolderTagSelectionHashMatch(tagSelection, detail: detail) {
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: hashMatch,
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "note_detail.tags+criteria_hash",
        expectedBool: true,
        actualBool: true,
        expectedCount: filter.count ?? tagSelection?.selectedTagCount,
        actualCount: detail?.tags.count ?? 0,
        rawValueComparisonStatus: "verified_hash_match"
      )
    }
    var gates = rawGates
    gates.append("filter_tags_value_comparison")
    if tagSelection?.tagIdentifiersSHA256 != nil || tagSelection?.displayTextsSHA256 != nil {
      gates.append("tag_selection_identifier_comparison")
    }
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: detail == nil ? "tag_metadata_missing" : "tag_count_readback_partial",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: detail == nil ? "note_detail_unavailable" : "note_detail.tags",
      expectedCount: filter.count ?? tagSelection?.selectedTagCount,
      actualCount: detail?.tags.count ?? 0,
      rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func smartFolderMentionFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    structure: NotesBodyStructureRecord,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    let mentionCount = bodyAttachmentKindCount("mention", in: structure)
    let hasMentions = mentionCount.map { $0 > 0 }
    let selectedMentionMatched = smartFolderSelectedHashesMatch(
      expected: filter.participantUserIDSHA256s,
      actual: structure.mentionUserIDSHA256s
    )
    let hasSpecificSelection = filter.rawValuePresent
      || (filter.count ?? 0) > 0
      || (filter.includedCount ?? 0) > 0
      || (filter.excludedCount ?? 0) > 0
      || !filter.participantUserIDSHA256s.isEmpty
    let evaluatedActual: Bool?
    switch filter.inclusionType {
    case 0:
      evaluatedActual = selectedMentionMatched.map { !$0 } ?? hasMentions.map { !$0 }
    case 1, nil:
      evaluatedActual = selectedMentionMatched ?? hasMentions
    case let unsupported?:
      var gates = rawGates
      gates.append("filter_mentions_inclusion_type_\(unsupported)_boolean_evaluation")
      if hasSpecificSelection {
        gates.append("mention_participant_identifier_comparison")
      }
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "gated",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "body_structure.attachmentKindCounts.mention",
        actualCount: mentionCount,
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    if let selectedMentionMatched {
      var gates = smartFolderSemanticRawGates(rawGates)
      if evaluatedActual == false {
        gates.append("filter_mentions_value_comparison")
      }
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: selectedMentionMatched
          ? "mention_participant_hash_match_readback"
          : "mention_participant_hash_mismatch_readback",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "body_structure.mentionUserIDSHA256s+criteria_hash",
        expectedBool: filter.inclusionType == 0 ? false : true,
        actualBool: evaluatedActual,
        expectedCount: filter.participantUserIDSHA256s.count,
        actualCount: mentionCount,
        rawValueComparisonStatus: "verified_hash_match",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    guard let evaluatedActual else {
      return smartFolderUnavailableBodyReason(filter,
        source: "body_structure.attachmentKindCounts.mention", count: mentionCount, rawGates: rawGates)
    }
    var gates = smartFolderSemanticRawGates(rawGates)
    if hasSpecificSelection {
      gates.append("mention_participant_identifier_comparison")
    }
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: hasSpecificSelection
        ? "mention_attachment_count_readback_partial"
        : "mention_attachment_count_readback",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: "body_structure.attachmentKindCounts.mention",
      expectedBool: filter.inclusionType == 0 ? false : true,
      actualBool: evaluatedActual,
      expectedCount: filter.count,
      actualCount: mentionCount,
      rawValueComparisonStatus: filter.rawValuePresent
        ? "gated_hash_only"
        : (hasSpecificSelection ? "count_readback_only" : "verified_semantic_value"),
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func bodyAttachmentKindCount(_ kind: String, in structure: NotesBodyStructureRecord) -> Int? {
    structure.attachmentKindCounts.map { $0.first { $0.kind == kind }?.count ?? 0 }
  }

  private func smartFolderSelectedHashesMatch(expected: [String], actual: [String]?) -> Bool? {
    let expectedSet = Set(expected.filter { !$0.isEmpty })
    guard !expectedSet.isEmpty else {
      return nil
    }
    guard let actual else { return nil }
    let actualSet = Set(actual.filter { !$0.isEmpty })
    return expectedSet.isSubset(of: actualSet)
  }

  private func smartFolderTagSelectionReason(
    _ tagSelection: NotesSmartFolderTagCriteria?,
    detail: NotesNoteDetail?
  ) -> NotesSmartFolderFilterReasonRecord? {
    guard let tagSelection else { return nil }
    let hashMatch = smartFolderTagSelectionHashMatch(tagSelection, detail: detail)
    var gates: [String] = hashMatch == nil ? ["tag_selection_identifier_comparison"] : []
    if hashMatch == nil, smartFolderTagSelectionNeedsOperatorGate(tagSelection) {
      gates.append("tag_selection_operator_semantics")
    }
    let hasSelectionHashes = tagSelection.tagIdentifiersSHA256 != nil || tagSelection.displayTextsSHA256 != nil
    return NotesSmartFolderFilterReasonRecord(
      ordinal: 0,
      kind: "tag_selection",
      reasoningStatus: detail == nil
        ? "tag_metadata_missing"
        : (hashMatch ?? "tag_selection_readback_partial"),
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: detail == nil
        ? "note_detail_unavailable"
        : (hashMatch == nil ? "note_detail.tags" : "note_detail.tags+criteria_hash"),
      expectedBool: hashMatch == nil ? nil : true,
      actualBool: hashMatch == nil ? nil : true,
      expectedCount: tagSelection.selectedTagCount,
      actualCount: detail?.tags.count ?? 0,
      rawValueComparisonStatus: hashMatch != nil
        ? "verified_hash_match"
        : (hasSelectionHashes ? "gated_hash_only" : "not_applicable"),
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func smartFolderTagSelectionHashMatch(
    _ tagSelection: NotesSmartFolderTagCriteria?,
    detail: NotesNoteDetail?
  ) -> String? {
    guard let tagSelection, let detail, !smartFolderTagSelectionNeedsOperatorGate(tagSelection) else {
      return nil
    }
    if smartFolderSingleIncludedTagHashMatches(tagSelection, detail: detail) {
      return "single_tag_hash_match_readback"
    }
    if smartFolderTagSelectionSetMatches(tagSelection, detail: detail) {
      return "tag_set_hash_match_readback"
    }
    return nil
  }

  private func smartFolderSingleIncludedTagHashMatches(
    _ tagSelection: NotesSmartFolderTagCriteria?,
    detail: NotesNoteDetail?
  ) -> Bool {
    guard let tagSelection,
      smartFolderCanEvaluateSingleIncludedTagHash(tagSelection),
      let detail
    else {
      return false
    }
    return detail.tags.contains { tag in
      if let displayTextsSHA256 = tagSelection.displayTextsSHA256,
        sha256Hex(tag.displayText) == displayTextsSHA256
      {
        return true
      }
      if let tagIdentifiersSHA256 = tagSelection.tagIdentifiersSHA256,
        sha256Hex(tag.id) == tagIdentifiersSHA256
      {
        return true
      }
      return false
    }
  }

  private func smartFolderCanEvaluateSingleIncludedTagHash(
    _ tagSelection: NotesSmartFolderTagCriteria
  ) -> Bool {
    guard tagSelection.selectedTagCount == 1 else {
      return false
    }
    if let includedTagCount = tagSelection.includedTagCount, includedTagCount != 1 {
      return false
    }
    if let excludedTagCount = tagSelection.excludedTagCount, excludedTagCount != 0 {
      return false
    }
    if smartFolderTagSelectionNeedsOperatorGate(tagSelection) {
      return false
    }
    return tagSelection.tagIdentifiersSHA256 != nil || tagSelection.displayTextsSHA256 != nil
  }

  private func smartFolderTagSelectionSetMatches(
    _ tagSelection: NotesSmartFolderTagCriteria,
    detail: NotesNoteDetail
  ) -> Bool {
    let noteTagIDs = Set(detail.tags.map(\.id))
    let noteDisplayTexts = Set(detail.tags.map(\.displayText))
    if smartFolderTagValuesMatch(
      included: tagSelection.includedTagIdentifiers ?? [],
      excluded: tagSelection.excludedTagIdentifiers ?? [],
      noteValues: noteTagIDs,
      tagOperator: tagSelection.tagOperator)
    {
      return true
    }
    if smartFolderTagValuesMatch(
      included: tagSelection.includedDisplayTexts ?? [],
      excluded: tagSelection.excludedDisplayTexts ?? [],
      noteValues: noteDisplayTexts,
      tagOperator: tagSelection.tagOperator)
    {
      return true
    }
    return smartFolderTagSelectionExactHashMatches(tagSelection, detail: detail)
  }

  private func smartFolderTagValuesMatch(
    included: [String],
    excluded: [String],
    noteValues: Set<String>,
    tagOperator: Int?
  ) -> Bool {
    guard !included.isEmpty || !excluded.isEmpty else {
      return false
    }
    let includedMatches: Bool
    if included.isEmpty {
      includedMatches = true
    } else if tagOperator == notesSmartFolderTagSelectionOperatorAny {
      includedMatches = included.contains { noteValues.contains($0) }
    } else {
      includedMatches = included.allSatisfy { noteValues.contains($0) }
    }
    return includedMatches && excluded.allSatisfy { !noteValues.contains($0) }
  }

  private func smartFolderTagSelectionExactHashMatches(
    _ tagSelection: NotesSmartFolderTagCriteria,
    detail: NotesNoteDetail
  ) -> Bool {
    guard tagSelection.excludedTagCount ?? 0 == 0,
      tagSelection.selectedTagCount == detail.tags.count
    else {
      return false
    }
    let tagIDHash = sha256Hex(detail.tags.map(\.id).sorted().joined(separator: "\0"))
    if let tagIdentifiersSHA256 = tagSelection.tagIdentifiersSHA256, tagIDHash == tagIdentifiersSHA256 {
      return true
    }
    let displayTextHash = sha256Hex(detail.tags.map(\.displayText).sorted().joined(separator: "\0"))
    if let displayTextsSHA256 = tagSelection.displayTextsSHA256, displayTextHash == displayTextsSHA256 {
      return true
    }
    return false
  }

  private func smartFolderTagSelectionNeedsOperatorGate(
    _ tagSelection: NotesSmartFolderTagCriteria
  ) -> Bool {
    if let tagOperator = tagSelection.tagOperator,
      tagOperator != notesSmartFolderTagSelectionOperatorAll
        && tagOperator != notesSmartFolderTagSelectionOperatorAny
    {
      return true
    }
    if let mode = tagSelection.mode, mode != notesSmartFolderTagSelectionModeAllTagged {
      return true
    }
    return false
  }

  private func smartFolderFolderFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    criteriaFilter: NotesSmartFolderCriteriaFilter?,
    state: NotesNoteStateRecord,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    if let noteFolderID = state.folderID,
      let inclusionType = filter.inclusionType,
      let expectedFolderMatchesNote = smartFolderFolderFilterMatchesNoteFolder(
        filter: filter,
        criteriaFilter: criteriaFilter,
        noteFolderID: noteFolderID
      )
    {
      let actual = inclusionType == 0 ? !expectedFolderMatchesNote : expectedFolderMatchesNote
      if actual {
        return NotesSmartFolderFilterReasonRecord(
          ordinal: filter.ordinal,
          kind: filter.kind,
          reasoningStatus: "folder_object_hash_match_readback",
          matchStatus: "matched_by_private_smart_folder_readback",
          evidenceSource: "note_state.folderID+criteria_hash",
          expectedBool: true,
          actualBool: true,
          expectedCount: filter.count,
          actualCount: 1,
          rawValueComparisonStatus: filter.rawValuePresent ? "verified_hash_match" : "not_applicable",
          gatedReasoningFamilies: []
        )
      }
    }

    var gates = rawGates
    gates.append("filter_folders_object_comparison")
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: "folder_state_readback_partial",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: "note_state",
      expectedCount: filter.count,
      actualCount: state.folderID == nil ? 0 : 1,
      rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func smartFolderFolderFilterMatchesNoteFolder(
    filter: NotesSmartFolderCriteriaFilterExplanation,
    criteriaFilter: NotesSmartFolderCriteriaFilter?,
    noteFolderID: String
  ) -> Bool? {
    if let folderID = criteriaFilter?.folderID, !folderID.isEmpty {
      return folderID == noteFolderID
    }
    guard let rawValueSHA256 = filter.rawValueSHA256 else {
      return nil
    }
    return rawValueSHA256 == sha256Hex(noteFolderID)
  }

  private func smartFolderDateFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    criteriaFilter: NotesSmartFolderCriteriaFilter?,
    note: NotesNoteSummary,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    let date: Date?
    let evidenceSource: String
    switch filter.kind {
    case "date_created":
      date = note.createdAt
      evidenceSource = "note_summary.createdAt"
    case "date_edited":
      date = note.updatedAt
      evidenceSource = "note_summary.updatedAt"
    default:
      date = note.updatedAt ?? note.createdAt
      evidenceSource = "note_summary.createdAt_or_updatedAt"
    }

    guard let date else {
      var gates = rawGates
      gates.append("filter_\(filter.kind)_date_source_readback")
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "date_source_missing",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: evidenceSource,
        actualBool: false,
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    if let selectionType = filter.selectionType,
      let actual = smartFolderDateMatchesKnownSelection(date, selectionType: selectionType)
    {
      var gates = smartFolderSemanticRawGates(rawGates)
      if !actual {
        gates.append("filter_\(filter.kind)_value_comparison")
      }
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "date_selection_readback",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: evidenceSource,
        actualBool: actual,
        rawValueComparisonStatus: smartFolderSemanticRawValueStatus(filter),
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    if let selectionType = filter.selectionType,
      let actual = smartFolderDateMatchesPrivateCriteria(
        date,
        selectionType: selectionType,
        criteriaFilter: criteriaFilter
      )
    {
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "date_value_readback",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "\(evidenceSource)+criteria_parameters",
        actualBool: actual,
        rawValueComparisonStatus: filter.rawValuePresent ? "verified_semantic_value" : "not_applicable",
        gatedReasoningFamilies: actual ? [] : ["filter_\(filter.kind)_value_comparison"]
      )
    }

    var gates = rawGates
    gates.append("filter_\(filter.kind)_value_comparison")
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: "date_source_readback_partial",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: evidenceSource,
      actualBool: true,
      rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func smartFolderDateMatchesKnownSelection(_ date: Date, selectionType: Int) -> Bool? {
    let calendar = Calendar.current
    let now = Date()
    switch selectionType {
    case 0:
      return calendar.isDateInToday(date)
    case 1:
      return calendar.isDateInYesterday(date)
    case 2:
      return date >= (calendar.date(byAdding: .day, value: -7, to: now) ?? now) && date <= now
    case 3:
      return date >= (calendar.date(byAdding: .day, value: -30, to: now) ?? now) && date <= now
    case 4:
      return date >= (calendar.date(byAdding: .month, value: -3, to: now) ?? now) && date <= now
    case 5:
      return date >= (calendar.date(byAdding: .month, value: -12, to: now) ?? now) && date <= now
    default:
      return nil
    }
  }

  private func smartFolderDateMatchesPrivateCriteria(
    _ date: Date,
    selectionType: Int,
    criteriaFilter: NotesSmartFolderCriteriaFilter?
  ) -> Bool? {
    let calendar = Calendar.current
    switch selectionType {
    case 6:
      guard let start = criteriaFilter?.primaryDate,
        let end = criteriaFilter?.secondaryDate
      else {
        return nil
      }
      return date >= start && date <= end
    case 7:
      guard let amount = criteriaFilter?.relativeRangeAmount,
        let selectionType = criteriaFilter?.relativeRangeSelectionType
      else {
        return nil
      }
      let component: Calendar.Component
      switch selectionType {
      case 1:
        component = .hour
      case 2:
        component = .day
      case 3:
        component = .weekOfYear
      case 4:
        component = .month
      case 5:
        component = .year
      default:
        return nil
      }
      let now = Date()
      return date >= (calendar.date(byAdding: component, value: -amount, to: now) ?? now) && date <= now
    case 8:
      guard let target = criteriaFilter?.primaryDate else {
        return nil
      }
      return calendar.isDate(date, inSameDayAs: target)
    case 9:
      guard let target = criteriaFilter?.primaryDate else {
        return nil
      }
      return date < calendar.startOfDay(for: target)
    case 10:
      guard let target = criteriaFilter?.primaryDate else {
        return nil
      }
      return date > notesSmartFolderCriteriaEndOfDay(target)
    default:
      return nil
    }
  }

  private func smartFolderAttachmentFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    attachments: [NotesAttachmentRecord],
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    let visible = attachments.filter { $0.isDeletedOrInTrash != true }
    let families = visible.map(attachmentAuditFamily)
    let selectionType = filter.selectionType ?? 1
    let familyCount: Int
    let actualBool: Bool
    let reasoningStatus = "family_count_readback"
    let gates = smartFolderSemanticRawGates(rawGates)

    switch selectionType {
    case 1:
      familyCount = visible.count
      actualBool = familyCount > 0
    case 2:
      familyCount = families.filter { $0 == "photo_image" || $0 == "video" }.count
      actualBool = familyCount > 0
    case 3:
      familyCount = families.filter { $0 == "scanned_document" }.count
      actualBool = familyCount > 0
    case 4:
      familyCount = families.filter { $0 == "drawing_or_sketch" }.count
      actualBool = familyCount > 0
    case 5:
      familyCount = families.filter { $0 == "map_preview" }.count
      actualBool = familyCount > 0
    case 6:
      familyCount = families.filter { $0 == "webpage_preview" }.count
      actualBool = familyCount > 0
    case 7:
      familyCount = families.filter { $0 == "audio_recording" }.count
      actualBool = familyCount > 0
    case 8:
      familyCount = families.filter { $0 == "pdf" || $0 == "file" }.count
      actualBool = familyCount > 0
    case 9:
      familyCount = visible.count
      actualBool = familyCount == 0
    default:
      var unknownGates = rawGates
      unknownGates.append("filter_attachments_selection_type_\(selectionType)_boolean_evaluation")
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "gated",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "attachment_metadata",
        actualCount: visible.count,
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(unknownGates)).sorted()
      )
    }

    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: reasoningStatus,
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: "attachment_metadata",
      actualBool: actualBool,
      actualCount: familyCount,
      rawValueComparisonStatus: smartFolderSemanticRawValueStatus(filter),
      gatedReasoningFamilies: Array(Set(gates)).sorted()
    )
  }

  private func smartFolderChecklistFilterReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    structure: NotesBodyStructureRecord,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    let selectionType = filter.selectionType ?? 0
    let count: Int?
    let actualBool: Bool?

    switch selectionType {
    case 0:
      count = structure.checklistItemCount
      actualBool = count.map { $0 > 0 }
    case 1:
      count = structure.checklistOpenCount
      actualBool = count.map { $0 > 0 }
    case 2:
      count = structure.checklistDoneCount
      actualBool = count.map { $0 > 0 }
    case 3:
      count = structure.checklistItemCount
      actualBool = count.map { $0 == 0 }
    default:
      var gates = rawGates
      gates.append("filter_checklists_selection_type_\(selectionType)_boolean_evaluation")
      return NotesSmartFolderFilterReasonRecord(
        ordinal: filter.ordinal,
        kind: filter.kind,
        reasoningStatus: "gated",
        matchStatus: "matched_by_private_smart_folder_readback",
        evidenceSource: "body_structure",
        actualCount: structure.checklistItemCount,
        rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
        gatedReasoningFamilies: Array(Set(gates)).sorted()
      )
    }

    guard let actualBool else {
      return smartFolderUnavailableBodyReason(filter, source: "body_structure", count: count, rawGates: rawGates)
    }
    return NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: "selection_count_readback",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: "body_structure",
      actualBool: actualBool,
      actualCount: count,
      rawValueComparisonStatus: smartFolderSemanticRawValueStatus(filter),
      gatedReasoningFamilies: smartFolderSemanticRawGates(rawGates)
    )
  }

  private func smartFolderUnavailableBodyReason(
    _ filter: NotesSmartFolderCriteriaFilterExplanation,
    source: String,
    count: Int?,
    rawGates: [String]
  ) -> NotesSmartFolderFilterReasonRecord {
    NotesSmartFolderFilterReasonRecord(
      ordinal: filter.ordinal,
      kind: filter.kind,
      reasoningStatus: "body_readback_unavailable",
      matchStatus: "matched_by_private_smart_folder_readback",
      evidenceSource: source,
      actualCount: count,
      rawValueComparisonStatus: filter.rawValuePresent ? "gated_hash_only" : "not_applicable",
      gatedReasoningFamilies: Array(Set(rawGates + ["filter_\(filter.kind)_body_readback"])).sorted()
    )
  }

  func verifySmartFolderCriteriaExplanation(
    smartFolder: NotesSmartFolderRecord,
    notes: [NotesNoteSummary],
    explanation: NotesSmartFolderCriteriaExplanationSummary
  ) throws -> NotesMutationVerificationReport {
    let criteriaReport = try verifySmartFolderCriteria(smartFolder: smartFolder, notes: notes)
    var checks = criteriaReport.checks
    checks.append(
      verificationBoolCheck(
        name: "criteria_explanation_present",
        expected: true,
        actual: explanation.queryKind != "unavailable"
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "criteria_explanation_filter_count_matches",
        expected: true,
        actual: (smartFolder.criteria?.filterCount ?? 0) == explanation.filterCount
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "criteria_explanation_filters_match",
        expected: true,
        actual: (smartFolder.criteria?.filters.count ?? 0) == explanation.filters.count
      )
    )

    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.smart-folders.explain",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_smart_folder_criteria_explanation+matching_note_readback",
      targetIDSHA256: sha256Hex(smartFolder.id),
      checks: checks,
      warnings: criteriaReport.warnings
    )
  }

  func verifySmartFolderMatchReasoning(
    smartFolder: NotesSmartFolderRecord,
    notes: [NotesNoteSummary],
    explanation: NotesSmartFolderCriteriaExplanationSummary,
    matches: [NotesSmartFolderMatchReasonRecord]
  ) throws -> NotesMutationVerificationReport {
    let criteriaReport = try verifySmartFolderCriteria(smartFolder: smartFolder, notes: notes)
    let noteIDs = notes.map(\.id)
    let matchNoteIDs = matches.map(\.note.id)
    var checks = criteriaReport.checks
    checks.append(
      verificationBoolCheck(
        name: "match_reason_count_matches_notes",
        expected: true,
        actual: matches.count == notes.count
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "all_reason_notes_match_readback",
        expected: true,
        actual: matchNoteIDs == noteIDs
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "membership_readback_status_reported",
        expected: true,
        actual: matches.allSatisfy { $0.matchStatus == "matched_by_private_smart_folder_readback" }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "criteria_families_accounted",
        expected: true,
        actual: matches.allSatisfy { $0.criteriaFamilies == explanation.supportedReadFamilies }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "filter_evidence_accounted",
        expected: true,
        actual: matches.allSatisfy { $0.filters.count == explanation.filters.count }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "filter_reason_evidence_accounted",
        expected: true,
        actual: matches.allSatisfy { $0.filterReasons.count == explanation.filters.count }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "filter_reason_ordinals_match",
        expected: true,
        actual: matches.allSatisfy { match in
          match.filterReasons.map(\.ordinal) == explanation.filters.map(\.ordinal)
        }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "filter_reasoning_status_recorded",
        expected: true,
        actual: matches.allSatisfy { match in
          match.filterReasons.allSatisfy { !$0.reasoningStatus.isEmpty && !$0.matchStatus.isEmpty }
        }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "tag_selection_reasoning_accounted",
        expected: true,
        actual: !explanation.tagSelectionPresent || matches.allSatisfy { $0.tagSelectionReason != nil }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "tag_selection_reasoning_status_recorded",
        expected: true,
        actual: !explanation.tagSelectionPresent || matches.allSatisfy { match in
          guard let reason = match.tagSelectionReason else { return false }
          return !reason.reasoningStatus.isEmpty && !reason.matchStatus.isEmpty
        }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "boolean_trace_accounted",
        expected: true,
        actual: matches.allSatisfy { match in
          explanation.multiCondition ? match.booleanTrace != nil : match.booleanTrace == nil
        }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "boolean_trace_counts_match",
        expected: true,
        actual: matches.allSatisfy { match in
          guard let trace = match.booleanTrace else {
            return !explanation.multiCondition
          }
          let expectedConditionCount = explanation.filters.count + (explanation.tagSelectionPresent ? 1 : 0)
          return trace.filterCount == explanation.filters.count
            && trace.conditionCount == expectedConditionCount
            && trace.provedFilterCount + trace.failedFilterCount + trace.unknownFilterCount == trace.filterCount
            && trace.provedConditionCount + trace.failedConditionCount + trace.unknownConditionCount
              == trace.conditionCount
        }
      )
    )
    checks.append(
      verificationBoolCheck(
        name: "boolean_trace_gate_status_matches",
        expected: true,
        actual: matches.allSatisfy { match in
          guard let trace = match.booleanTrace else {
            return !explanation.multiCondition
          }
          let matchGates = Set(match.gatedReasoningFamilies)
          let traceGates = Set(trace.gatedReasoningFamilies)
          if trace.status == "verified" {
            return traceGates.isEmpty
              && !matchGates.contains("multi_condition_boolean_trace")
              && trace.allKnownConditionsPassed != nil
          }
          return trace.status == "partial_gated_filters"
            && traceGates.contains("multi_condition_boolean_trace")
            && matchGates.contains("multi_condition_boolean_trace")
        }
      )
    )

    var warnings = criteriaReport.warnings
    let gates = Set(matches.flatMap(\.gatedReasoningFamilies))
    if !gates.isEmpty {
      warnings.append("filter_reasoning_partial")
      warnings.append(contentsOf: gates.sorted())
    }

    return NotesMutationVerificationReport(
      verifier: "notes_read_v1",
      operation: "notes.smart-folders.reasoning",
      verified: checks.allSatisfy { $0.status == "passed" || $0.status == "not_applicable" },
      evidenceLevel: "private_framework_smart_folder_membership_reasoning+criteria_summary+boolean_trace",
      targetIDSHA256: sha256Hex(smartFolder.id),
      checks: checks,
      warnings: Array(Set(warnings)).sorted()
    )
  }
}
