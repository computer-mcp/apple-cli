import Foundation
import ReminderKit
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
    #expect(help.contains("notes"))
    #expect(RemindersTarget.Notes.helpMessage().contains("list-style"))
    #expect(RemindersTarget.Notes.Format.helpMessage().contains("occurrence"))
    #expect(RemindersTargetOptions().cliTargetOptions.isEmpty)
    let format = try RemindersTarget.Notes.Format.parse([
      "--id", "fixture", "--text", "😀x", "--occurrence", "2", "--format", "bold", "--state", "on",
    ])
    #expect(format.targetOptions.cliTargetOptions == ["id": "fixture", "text": "😀x",
      "occurrence": "2", "format": "bold", "state": "on"])
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
    #expect(itemsHelp.contains("read"))
    #expect(itemsHelp.contains("list"))
  }

  @Test func remindersCompleteHelpDescribesHistoricalCompletionTime() throws {
    let help = RemindersTarget.Complete.helpMessage()

    #expect(help.contains("completed-at"))
    #expect(help.contains("ISO-8601"))
    #expect(help.contains("2021-01-02T03:04:05Z"))
  }

  @Test(arguments: ReminderNotesFormat.allCases)
  func richNotesFormatsPreserveOtherAttributesAndTheUnselectedOccurrence(format: ReminderNotesFormat) throws {
    var attributes: [NSAttributedString.Key: Any] = [.init("TTHints"): NSNumber(value: 16),
      .init("NSLink"): URL(string: "https://example.com/notes")!, .init("TTColor"): "preserved"]
    if format != .underline { attributes[.init("TTUnderline")] = NSNumber(value: 1) }
    if format != .strikethrough { attributes[.init("TTStrikethrough")] = NSNumber(value: 1) }
    let original = NSAttributedString(string: "😀x 😀x", attributes: attributes)
    let text = NSMutableAttributedString(attributedString: original)
    let selection = try reminderNotesSelection(in: text.string as NSString, literal: "😀x", occurrence: 2)
    #expect(selection == NSRange(location: 4, length: 3))
    try reminderNotesFormat(text, range: selection, format: format, enabled: false)
    #expect(text.isEqual(to: original))
    try reminderNotesFormat(text, range: selection, format: format, enabled: true)
    let record = try reminderNotesRecord(id: "fixture", notes: text)
    let selected = try #require(record.runs.last)
    switch format {
    case .bold: #expect(selected.bold)
    case .italic: #expect(selected.italic)
    case .underline: #expect(selected.underline)
    case .strikethrough: #expect(selected.strikethrough)
    }
    #expect(text.attributedSubstring(from: .init(location: 0, length: 4)).isEqual(
      to: original.attributedSubstring(from: .init(location: 0, length: 4))))
    #expect(selected.link == "https://example.com/notes")
    #expect(text.attribute(.init("TTColor"), at: 4, effectiveRange: nil) as? String == "preserved")
    let hints = try #require(text.attribute(.init("TTHints"), at: 4, effectiveRange: nil) as? NSNumber)
    #expect(hints.uint64Value & 16 == 16)
    let once = NSAttributedString(attributedString: text)
    try reminderNotesFormat(text, range: selection, format: format, enabled: true)
    #expect(text.isEqual(to: once))
    try reminderNotesFormat(text, range: selection, format: format, enabled: false)
    let off = try #require(try reminderNotesRecord(id: "fixture", notes: text).runs.last)
    switch format {
    case .bold: #expect(!off.bold)
    case .italic: #expect(!off.italic)
    case .underline: #expect(!off.underline)
    case .strikethrough: #expect(!off.strikethrough)
    }
    #expect(off.link == selected.link)
    #expect(text.string == original.string)
  }

  @Test(arguments: ReminderNotesListStyle.allCases)
  func richNotesListStylePreservesOtherParagraphsAndInlineAttributes(style: ReminderNotesListStyle) throws {
    let native = try #require(TTParagraphStyle.paragraphStyleNamed(style == .plain ? 100 : 3) as? TTParagraphStyle)
    let originalStyle = try #require(native.mutableCopy() as? TTParagraphStyle)
    originalStyle.indent = 2; originalStyle.startingItemNumber = 7; originalStyle.hints = 16
    let text = NSMutableAttributedString(string: "First 😀\r\nSecond e\u{301}\n")
    let paragraph = NSRange(location: 10, length: 10)
    text.addAttribute(.init("TTStyle"), value: originalStyle, range: paragraph)
    text.addAttribute(.init("TTHints"), value: NSNumber(value: 1), range: .init(location: 10, length: 6))
    let before = NSAttributedString(attributedString: text)
    try reminderNotesListStyle(text, range: .init(location: 11, length: 1), style: style)
    if style == .plain {
      #expect(text.attribute(.init("TTStyle"), at: 10, effectiveRange: nil) == nil)
    } else {
      let afterStyle = try #require(text.attribute(.init("TTStyle"), at: 10, effectiveRange: nil) as? TTParagraphStyle)
      #expect(afterStyle.style == style.nativeValue)
      #expect(afterStyle.indent == 2 && afterStyle.startingItemNumber == 7 && afterStyle.hints == 16)
    }
    #expect(originalStyle.style == native.style)
    #expect(text.attributedSubstring(from: .init(location: 0, length: 10)).isEqual(
      to: before.attributedSubstring(from: .init(location: 0, length: 10))))
    #expect((text.attribute(.init("TTHints"), at: 10, effectiveRange: nil) as? NSNumber)?.intValue == 1)
    let once = NSAttributedString(attributedString: text)
    try reminderNotesListStyle(text, range: .init(location: 11, length: 1), style: style)
    #expect(text.isEqual(to: once))
    #expect(try reminderNotesRecord(id: "fixture", notes: text).runs.last?.listStyle == style)
  }

  @Test func richNotesSelectionRejectsAmbiguityAndKeepsLiteralUnicodeIdentity() throws {
    let text = "e\u{301} é é" as NSString
    #expect(try reminderNotesSelection(in: text, literal: "é", occurrence: 2) == .init(location: 5, length: 1))
    for (literal, occurrence) in [("", nil as Int?), (nil as String?, 1), ("é", 0), ("é", nil), ("absent", nil)] {
      #expect(throws: CLIError.self) {
        try reminderNotesSelection(in: text, literal: literal, occurrence: occurrence)
      }
    }
    #expect(throws: CLIError.self) {
      try reminderNotesRecord(id: "fixture", notes: NSAttributedString(string: "x", attributes: [.init("TTHints"): "unknown"]))
    }
  }

  @Test func reminderLookupErrorsCannotBeReportedAsMissingItems() throws {
    try coreValidateReminderFetchError(resultExists: false, error: nil, operation: "test")
    let absent = NSError(domain: "com.apple.reminderkit", code: -3000)
    try coreValidateReminderFetchError(resultExists: false, error: absent, operation: "test")
    for (exists, error) in [(true, absent), (false, NSError(domain: NSCocoaErrorDomain, code: 4099))] {
      #expect(throws: CLIError.self) {
        try coreValidateReminderFetchError(resultExists: exists, error: error, operation: "test")
      }
    }
  }

  @Test func reminderObjectIdentifiersRespectEntityBoundaries() throws {
    let uuid = UUID().uuidString
    let raw = try coreREMObjectID(entity: "REMCDSavedReminder", identifier: uuid)
    let saved = try coreREMObjectID(entity: "REMCDSavedReminder",
      identifier: "x-apple-reminderkit://REMCDSavedReminder/\(uuid)")
    #expect(raw?.entityName == "REMCDSavedReminder")
    #expect(saved?.uuid == raw?.uuid)
    #expect(coreObjectIDsMatch(raw, saved))
    #expect(!coreObjectIDsMatch(nil, nil))
    #expect(!coreObjectIDsMatch(raw, try coreREMObjectID(entity: "REMCDReminder", identifier: uuid)))
    #expect(try coreREMObjectID(entity: "REMCDSavedReminder",
      identifier: "x-apple-reminderkit://REMCDReminder/\(uuid)") == nil)
    for invalid in ["invalid", "x-apple-reminderkit://REMCDSavedReminder/\(uuid)?query=1",
      "x-apple-reminderkit://REMCDSavedReminder/\(uuid)#fragment",
      "x-apple-reminderkit://REMCDSavedReminder/\(uuid)/extra"] {
      #expect(try coreREMObjectID(entity: "REMCDSavedReminder", identifier: invalid) == nil)
    }
  }

  @Test func listEnrichmentRequiresNativeIdentityInsteadOfCreatingStoreRows() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let reader = RemindersSQLiteReader(homeDirectory: root)
    try FileManager.default.createDirectory(at: reader.remindersStoresURL, withIntermediateDirectories: true)
    let store = reader.remindersStoresURL.appendingPathComponent("Data-fixture.sqlite")
    let id = UUID().uuidString
    let setup = try CLISubprocess.run(.path("/usr/bin/sqlite3"), arguments: [store.path, """
      create table ZREMCDBASELIST(Z_PK integer, ZCKIDENTIFIER text, ZEXTERNALIDENTIFIER text,
        ZNAME text, ZSMARTLISTTYPE text, ZSHOULDCATEGORIZEGROCERYITEMS integer, ZISGROUP integer,
        ZISPINNEDBYCURRENTUSER integer, ZPINNEDDATE real, ZDADISPLAYORDER integer,
        ZSORTINGSTYLE text, ZCOLOR blob, ZMARKEDFORDELETION integer);
      insert into ZREMCDBASELIST values(1, '\(id)', '', 'Shared title',
        'com.apple.reminders.smartlist.custom', 0, 0, 1, 1, 7, '', null, 0);
      """], timeoutSeconds: 5, outputLimit: 4096)
    try #require(setup.exitCode == 0)
    #expect(try reader.enrichLists([]).isEmpty)
    let unrelated = ReminderListRecord(id: UUID().uuidString, title: "Shared title",
      sourceId: "native-account", sourceTitle: "Account", allowsContentModifications: true,
      listType: "standard")
    #expect(try reader.enrichLists([unrelated]) == [unrelated])
    var bound = unrelated
    bound.id = "x-apple-reminderkit://REMCDSmartList/\(id)"
    bound.listType = "smart"
    bound.smartListType = ReminderSmartListWriter.customSmartListType
    bound.isPinned = false
    bound.sortingStyle = "manual"
    let enriched = try #require(try reader.enrichLists([bound]).first)
    #expect(enriched.listType == "smart" && enriched.isPinned == false && enriched.displayOrder == 7)
    #expect(enriched.sortingStyle == "manual")
    #expect(enriched.id == bound.id && enriched.sourceId == bound.sourceId)
  }

  @Test(arguments: [
    "priority:low priority:high", "tags:alpha any-tag:true",
    "date:today date-before:2026-10-08", "date-on:2026-10-08 date-on:2026-10-09",
    "date-range:2026-10-09..2026-10-08", "date-on:2026-02-30",
    "date-on:2026-10-04T12:00:00Z",
  ])
  func smartListCriteriaRejectLostConditionsAndInvalidDates(_ descriptor: String) {
    #expect(throws: CLIError.self) {
      try ReminderSmartListFilterEncoder.encode(criteria: .init(match: "all", descriptor: descriptor))
    }
  }

  @Test func smartListReadbackRequiresExactIdentityAccountAndRequestedRules() throws {
    let id = UUID().uuidString
    let source = "x-apple-reminderkit://REMCDAccount/\(UUID().uuidString)"
    let list = ReminderListRecord(id: id, title: "Shared title", sourceId: source,
      sourceTitle: "Account", allowsContentModifications: true, listType: "smart",
      smartListType: ReminderSmartListWriter.customSmartListType)
    let expected = try ReminderSmartListFilterEncoder.encode(
      criteria: .init(match: "all", descriptor: "flagged:true priority:high"))
    let actual = Data(#"{ "priorities": ["high"], "operation": "and", "flagged": true }"#.utf8)
    let snapshot = ReminderSmartListSnapshot(list: list, filterData: actual)
    func matches(_ value: ReminderSmartListSnapshot?) -> Bool {
      reminderSmartListReadbackMatches(value, id: id, sourceID: source, expectedFilter: expected)
    }
    #expect(matches(snapshot))
    #expect(reminderSmartListReadbackMatches(snapshot,
      id: "x-apple-reminderkit://REMCDSmartList/\(id)", sourceID: source, expectedFilter: expected))
    #expect(!matches(nil))
    for (field, value) in [("id", UUID().uuidString), ("id", "x-apple-reminderkit://REMCDList/\(id)"),
      ("source", ""), ("source", "another-account"), ("type", "standard"), ("smartType", "built-in")]
    {
      var wrong = snapshot
      switch field {
      case "id": wrong.list.id = value
      case "source": wrong.list.sourceId = value
      case "type": wrong.list.listType = value
      default: wrong.list.smartListType = value
      }
      #expect(!matches(wrong), "\(field)=\(value)")
    }
    for data in [nil, Data(), Data("[]".utf8), Data("invalid".utf8),
      Data(#"{"flagged":true,"operation":"and","priorities":["low"]}"#.utf8)] as [Data?] {
      #expect(!matches(.init(list: list, filterData: data)))
    }
    #expect(!reminderSmartListReadbackMatches(snapshot, id: id, sourceID: "", expectedFilter: expected))
  }

  @Test func nativeSmartListQueryPreservesContextualChildrenAndDeduplicatesRootMatches() throws {
    let smart = UUID(), parent = UUID(), child = UUID()
    let childNode: [String: Any] = ["objectID": ["entityName": "REMCDReminder", "uuid": child.uuidString]]
    let rootNode: [String: Any] = ["objectID": ["entityName": "REMCDReminder", "uuid": parent.uuidString],
      "subtasks": [childNode]]
    let data = try PropertyListSerialization.data(fromPropertyList: [
      "smartList": ["objectIDUUID": smart.uuidString], "model": ["reminders": [rootNode, childNode]],
    ], format: .binary, options: 0)
    #expect(try reminderSmartListQueryIDs(data, smartListID: smart) == [parent, child])
    let empty = try PropertyListSerialization.data(fromPropertyList: [
      "smartList": ["objectIDUUID": smart.uuidString], "model": ["reminders": []],
    ], format: .binary, options: 0)
    #expect(try reminderSmartListQueryIDs(empty, smartListID: smart).isEmpty)
  }

  @Test(arguments: ["identity", "model", "entity", "uuid", "subtasks", "cycle", "malformed"])
  func nativeSmartListQueryRejectsUnknownOrForeignResults(_ failure: String) throws {
    let smart = UUID(), reminder = UUID()
    var node: [String: Any] = ["objectID": ["entityName": "REMCDReminder", "uuid": reminder.uuidString]]
    var result: [String: Any] = ["smartList": ["objectIDUUID": smart.uuidString]]
    switch failure {
    case "identity": result["smartList"] = ["objectIDUUID": UUID().uuidString]
    case "entity": node["objectID"] = ["entityName": "REMCDList", "uuid": reminder.uuidString]
    case "uuid": node["objectID"] = ["entityName": "REMCDReminder", "uuid": "unknown"]
    case "subtasks": node["subtasks"] = "unknown"
    case "cycle": node["subtasks"] = [node]
    default: break
    }
    if failure != "model" { result["model"] = ["reminders": [node]] }
    let data = failure == "malformed" ? Data("invalid".utf8)
      : try PropertyListSerialization.data(fromPropertyList: result, format: .binary, options: 0)
    #expect(throws: CLIError.self) { try reminderSmartListQueryIDs(data, smartListID: smart) }
  }

  @Test func templateItemIndexFindsSavedItemsWithExactTemplateBoundary() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let reader = RemindersSQLiteReader(homeDirectory: root)
    try FileManager.default.createDirectory(at: reader.remindersStoresURL, withIntermediateDirectories: true)
    let store = reader.remindersStoresURL.appendingPathComponent("Data-fixture.sqlite")
    let template = UUID().uuidString, foreign = UUID().uuidString
    let parent = UUID().uuidString, child = UUID().uuidString
    func blob(_ uuid: String) -> String { "X'\(uuid.replacingOccurrences(of: "-", with: ""))'" }
    let setup = try CLISubprocess.run(.path("/usr/bin/sqlite3"), arguments: [store.path, """
      create table ZREMCDTEMPLATE(Z_PK integer, ZIDENTIFIER blob, ZMARKEDFORDELETION integer);
      create table ZREMCDSAVEDREMINDER(Z_PK integer, ZTEMPLATE integer, ZIDENTIFIER blob, ZMARKEDFORDELETION integer);
      insert into ZREMCDTEMPLATE values(1, \(blob(template)), 0), (2, \(blob(foreign)), 0);
      insert into ZREMCDSAVEDREMINDER values(1, 1, \(blob(parent)), 0), (2, 1, \(blob(child)), 0),
        (3, 1, \(blob(UUID().uuidString)), 1), (4, 2, \(blob(UUID().uuidString)), 0);
      """], timeoutSeconds: 5, outputLimit: 4096)
    try #require(setup.exitCode == 0)
    let templateID = "x-apple-reminderkit://REMCDTemplate/\(template)"
    #expect(try reader.templateItemIDs(templateID: templateID, limit: 9) == [parent, child])
    #expect(try reader.templateItemIDs(templateID: templateID, limit: 1) == [parent])
    #expect(throws: CLIError.self) {
      try reader.templateItemIDs(templateID: "x-apple-reminderkit://REMCDTemplate/\(UUID().uuidString)", limit: 9)
    }
    try FileManager.default.removeItem(at: store)
    #expect(throws: CLIError.self) {
      try reader.templateItemIDs(templateID: templateID, limit: 9)
    }
  }

  @Test func completingAgainPreservesHistoricalCompletionDate() {
    let historicalDate = Date(timeIntervalSince1970: 1_609_556_645)
    let retryDate = Date(timeIntervalSince1970: 1_700_000_000)
    var clockReads = 0
    func readClock() -> Date {
      clockReads += 1
      return retryDate
    }

    let date = coreReminderCompletionDate(
      current: historicalDate,
      completed: true,
      completedAt: nil,
      now: readClock()
    )

    #expect(date == historicalDate)
    #expect(clockReads == 0)
  }

  @Test func firstCompletionUsesCurrentTime() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)

    #expect(coreReminderCompletionDate(
      current: nil, completed: true, completedAt: nil, now: now
    ) == now)
  }

  @Test func explicitCompletionDateCorrectsHistory() {
    let previous = Date(timeIntervalSince1970: 1_700_000_000)
    let requested = Date(timeIntervalSince1970: 1_609_556_645)

    #expect(coreReminderCompletionDate(
      current: previous, completed: true, completedAt: requested
    ) == requested)
    #expect(coreReminderCompletionDate(
      current: nil, completed: true, completedAt: requested
    ) == requested)
  }

  @Test func uncompletingClearsCompletionDate() {
    let previous = Date(timeIntervalSince1970: 1_609_556_645)

    #expect(coreReminderCompletionDate(
      current: previous, completed: false, completedAt: nil
    ) == nil)
    #expect(coreReminderCompletionDate(
      current: nil, completed: false, completedAt: nil
    ) == nil)
  }

  @Test func subtaskParentVerificationUsesIdentityRatherThanTitle() {
    let command = RemindersCommand()
    let parent = ReminderDetail(id: "expected-parent", listId: "list", listTitle: "List",
      title: "Same title", isCompleted: false, priority: 0)
    let child = ReminderDetail(id: "child", listId: "list", listTitle: "List",
      title: "Child", isCompleted: false, priority: 0)
    for parentID in ["wrong-parent" as String?, nil] {
      let match = RemindersPrivateReminderDebugRecord(storePath: "fixture.sqlite", primaryKey: 1,
        calendarItemIdentifier: child.id, subtaskRelationshipAvailable: true,
        parentReminderId: parentID, parentReminderTitle: parent.title,
        relatedObjectCount: 0, objects: [])
      let debug = RemindersItemDebugResponse(reminder: child, privateStoreMatches: [match], visibleURLObjects: [])
      #expect(!command.subtaskParentSatisfied(debug: debug, expectedParent: parent))
    }
    var match = RemindersPrivateReminderDebugRecord(storePath: "fixture.sqlite", primaryKey: 1,
      calendarItemIdentifier: child.id, subtaskRelationshipAvailable: true, parentReminderId: parent.id,
      parentReminderTitle: "Renamed title", relatedObjectCount: 0, objects: [])
    var debug = RemindersItemDebugResponse(reminder: child, privateStoreMatches: [match], visibleURLObjects: [])
    #expect(command.subtaskParentSatisfied(debug: debug, expectedParent: parent))
    debug.reminder.listId = "wrong-list"
    #expect(!command.subtaskParentSatisfied(debug: debug, expectedParent: parent))
    debug.reminder.listId = parent.listId
    debug.privateStoreMatches = [match, match]
    #expect(!command.subtaskParentSatisfied(debug: debug, expectedParent: parent))
    match.calendarItemIdentifier = "different-child"
    debug.privateStoreMatches = [match]
    #expect(!command.subtaskParentSatisfied(debug: debug, expectedParent: parent))
    let uuid = UUID().uuidString
    debug.reminder.id = uuid
    debug.reminder.listId = "x-apple-reminderkit://REMCDList/\(uuid)"
    var identifiedParent = parent
    identifiedParent.id = uuid
    identifiedParent.listId = uuid.lowercased()
    match.calendarItemIdentifier = uuid.lowercased()
    match.parentReminderId = "x-apple-reminderkit://REMCDReminder/\(uuid)"
    debug.privateStoreMatches = [match]
    #expect(command.subtaskParentSatisfied(debug: debug, expectedParent: identifiedParent))
    debug.privateStoreMatches[0].parentReminderId = "x-apple-reminderkit://REMCDList/\(uuid)"
    #expect(!command.subtaskParentSatisfied(debug: debug, expectedParent: identifiedParent))
  }

  @Test func subtaskPromotionRejectsUnavailableRelationshipEvidence() {
    let command = RemindersCommand()
    let child = ReminderDetail(id: "child", listId: "list", listTitle: "List",
      title: "Child", isCompleted: false, priority: 0)
    let match = RemindersPrivateReminderDebugRecord(storePath: "fixture.sqlite", primaryKey: 1,
      calendarItemIdentifier: child.id, relatedObjectCount: 0, objects: [])
    var debug = RemindersItemDebugResponse(reminder: child, privateStoreMatches: [match],
      visibleURLObjects: [], warnings: ["Unrelated attachment evidence unavailable."])
    #expect(!command.subtaskPromotionSatisfied(debug: debug))
    debug.privateStoreMatches[0].subtaskRelationshipAvailable = false
    #expect(!command.subtaskPromotionSatisfied(debug: debug))
    debug.privateStoreMatches[0].subtaskRelationshipAvailable = true
    #expect(command.subtaskPromotionSatisfied(debug: debug))
    debug.reminder.parentReminderId = "native-parent"
    #expect(!command.subtaskPromotionSatisfied(debug: debug))
    debug.reminder.parentReminderId = nil
    debug.privateStoreMatches = []
    #expect(!command.subtaskPromotionSatisfied(debug: debug))
  }

  @Test func subtaskChangeReportsCompareParentAndListIdentities() {
    let command = RemindersCommand()
    let uuid = UUID().uuidString
    let before = ReminderDetail(id: "child", listId: uuid, listTitle: "List",
      title: "Child", isCompleted: false, priority: 0, parentReminderId: uuid)
    var after = before
    after.listId = "x-apple-reminderkit://REMCDList/\(uuid.lowercased())"
    after.parentReminderId = "x-apple-reminderkit://REMCDReminder/\(uuid.lowercased())"
    after.parentReminderTitle = "Renamed title"
    #expect(!command.subtaskRelationshipChanged(from: before, to: after))
    after.parentReminderId = nil
    #expect(command.subtaskRelationshipChanged(from: before, to: after))
    after.parentReminderId = uuid
    after.listId = "other-list"
    #expect(command.subtaskRelationshipChanged(from: before, to: after))
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
