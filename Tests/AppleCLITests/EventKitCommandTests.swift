@testable import CalendarCLI
import EventKit
import Foundation
import Testing
import Utility

@Suite
struct EventKitCommandTests {
  @Test(arguments: ["Asia/Shanghai", "Pacific/Kiritimati", "America/Los_Angeles"])
  func calendarAllDayExportPreservesLocalDatesAndExclusiveEnd(timeZoneIdentifier: String) throws {
    let timeZone = try #require(TimeZone(identifier: timeZoneIdentifier))
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    let start = try #require(calendar.date(from: DateComponents(year: 2027, month: 3, day: 13)))
    let end = try #require(calendar.date(byAdding: .day, value: 2, to: start))
    let event = CalendarEventSummary(id: "all-day", calendarId: "fixture", calendarTitle: "Fixture",
      title: "Two calendar days", start: start, end: end, isAllDay: true,
      timeZoneIdentifier: timeZoneIdentifier)
    let content = try renderICalendar([event])
    #expect(content.contains("DTSTART;VALUE=DATE:20270313\r\n"))
    #expect(content.contains("DTEND;VALUE=DATE:20270315\r\n"))
    if timeZoneIdentifier == "America/Los_Angeles" {
      #expect(end.timeIntervalSince(start) == 47 * 3600)
    }
  }

  @Test(arguments: ["weekly", "monthly", "yearly"])
  func calendarNativeRecurrenceProjectionPreservesCustomSelectors(frequency: String) throws {
    let native: EKRecurrenceRule
    let selectors: [String]
    switch frequency {
    case "weekly":
      native = EKRecurrenceRule(recurrenceWith: .weekly, interval: 2,
        daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday), EKRecurrenceDayOfWeek(.wednesday)],
        daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil,
        daysOfTheYear: nil, setPositions: [-1], end: nil)
      selectors = ["BYDAY=MO,WE", "BYSETPOS=-1", "WKST=MO"]
    case "monthly":
      native = EKRecurrenceRule(recurrenceWith: .monthly, interval: 1,
        daysOfTheWeek: [EKRecurrenceDayOfWeek(.friday, weekNumber: 2),
          EKRecurrenceDayOfWeek(.monday, weekNumber: -1)],
        daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil,
        daysOfTheYear: nil, setPositions: nil, end: EKRecurrenceEnd(occurrenceCount: 6))
      selectors = ["BYDAY=2FR,-1MO", "COUNT=6"]
    default:
      native = EKRecurrenceRule(recurrenceWith: .yearly, interval: 1,
        daysOfTheWeek: nil, daysOfTheMonth: nil, monthsOfTheYear: [2, 12],
        weeksOfTheYear: [1, -1], daysOfTheYear: [1, -366], setPositions: [1, -1], end: nil)
      selectors = ["BYMONTH=2,12", "BYWEEKNO=1,-1", "BYYEARDAY=1,-366", "BYSETPOS=1,-1"]
    }
    let record = recurrenceRecord(native)
    let object = try jsonObject(CLIJSON.encodeString(record))
    #expect(object["calendarIdentifier"] as? String == native.calendarIdentifier)
    #expect(object["firstDayOfTheWeek"] as? Int == native.firstDayOfTheWeek)
    let serialized = iCalendarRecurrence(record)
    for selector in selectors { #expect(serialized.contains(selector)) }
    #expect(try recurrenceRecord(eventKitRecurrenceRule(record)) == record)
  }

  @Test(arguments: [
    ["daily", "--recurrence-by-day", "MO"],
    ["weekly", "--recurrence-by-day", "2MO"],
    ["monthly", "--recurrence-by-day", "6MO"],
    ["monthly", "--recurrence-by-month-day", "0"],
    ["monthly", "--recurrence-by-month", "2"],
    ["yearly", "--recurrence-by-week-no", "54"],
    ["yearly", "--recurrence-by-year-day", "367"],
    ["yearly", "--recurrence-by-set-pos", "-1"],
    ["yearly", "--recurrence-by-day", "2MO", "--recurrence-by-week-no", "1"],
  ])
  func calendarRecurrenceRejectsIgnoredOrInvalidSelectors(_ fields: [String]) throws {
    let options = try CLIOptionsFixture.parse(["--recurrence-frequency", fields[0]] + fields.dropFirst())
    #expect(throws: CLIError.self) {
      try recurrenceRuleOption(options, effectiveStart: isoDate("2026-01-01T00:00:00Z"))
    }
  }

  @Test(arguments: ["2026-02-30", "2026-13-01", "2026-00-10", "2026-10-00", "26-1-1"])
  func calendarDateOnlyRejectsInvalidOrNoncanonicalCalendarDays(_ value: String) {
    #expect(parseDateOnly(value, role: .lower) == nil)
    #expect(throws: CLIError.self) { try parseEventDate(value) }
  }

  @Test(arguments: [
    String(repeating: "会议😀", count: 30),
    "e" + String(repeating: "\u{0301}", count: 100),
    String(repeating: "x", count: 150),
  ])
  func calendarICalendarFoldingBoundsUTF8AndPreservesTheUnfoldedContent(_ title: String) {
    let line = "SUMMARY:" + title
    let folded = foldICalendarLine(line)
    #expect(folded.components(separatedBy: "\r\n").allSatisfy { $0.utf8.count <= 75 })
    let unfolded = folded.replacingOccurrences(of: "\r\n ", with: "", options: .literal)
    #expect(Array(unfolded.utf8) == Array(line.utf8))
  }

  @Test func calendarWriteOnlyAccessCannotReadMutationIdentity() {
    #expect(throws: CLIError.self) {
      try eventStoreWithCalendarWriteAccess(authorizationStatus: .writeOnly)
    }
  }

  @Test func calendarCollectionReadsKeepSourceIDsAndExposeTruncation() throws {
    let backend = FakeCalendarBackend()
    var second = backend.calendars[0]
    second.id = "cal-second"
    second.sourceId = "source-second"
    backend.calendars.append(second)
    backend.sources.append(CalendarSourceRecord(
      id: "source-second", title: "iCloud", type: "caldav", typeRawValue: 2,
      isDelegate: false, calendarIds: [second.id]))
    let command = CalendarCommand(backend: backend)
    let source = try #require(try command.run(options: CLIOptionsFixture.parse([
      "sources", "read", "--id", "source-second", "--json"])))
    let sourceData = try #require(try jsonObject(source.stdout ?? "")["data"] as? [String: Any])
    #expect((sourceData["source"] as? [String: Any])?["id"] as? String == "source-second")
    let filtered = try #require(try command.run(options: CLIOptionsFixture.parse([
      "calendars", "list", "--source", "source-second", "--limit", "1", "--json"])))
    let filteredData = try #require(try jsonObject(filtered.stdout ?? "")["data"] as? [String: Any])
    #expect((filteredData["calendars"] as? [[String: Any]])?.first?["id"] as? String == second.id)
    #expect(filteredData["truncated"] as? Bool == false)
    let limited = try #require(try command.run(options: CLIOptionsFixture.parse([
      "calendars", "list", "--limit", "1", "--json"])))
    #expect((try jsonObject(limited.stdout ?? "")["data"] as? [String: Any])?["truncated"] as? Bool == true)
  }

  @Test func calendarCollectionLifecycleUsesBoundIDsAndSkipsUnchangedUpdates() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let create = ["calendars", "create", "--source", "source-icloud", "--title", "临时日历 🗓",
      "--color", "#abcdef", "--json"]
    _ = try command.run(options: CLIOptionsFixture.parse(create + ["--dry-run"]))
    #expect(backend.createdCalendars.isEmpty)
    _ = try command.run(options: CLIOptionsFixture.parse(create))
    #expect(backend.createdCalendars.first?.sourceId == "source-icloud")
    #expect(backend.createdCalendars.first?.color == "#ABCDEFFF")
    let created = try #require(try backend.readCalendar(id: "cal-created"))
    let update = ["calendars", "update", "--id", created.id, "--title", "改名 🗓", "--json"]
    _ = try command.run(options: CLIOptionsFixture.parse(update))
    #expect(backend.updatedCalendars.first?.0 == created)
    #expect(backend.updatedCalendars.first?.1.color == nil)
    let repeated = try #require(try command.run(options: CLIOptionsFixture.parse(update)))
    #expect((try jsonObject(repeated.stdout ?? "")["data"] as? [String: Any])?["changed"] as? Bool == false)
    #expect(backend.updatedCalendars.count == 1)
    #expect(try backend.readCalendar(id: created.id)?.color == created.color)
    _ = try command.run(options: CLIOptionsFixture.parse([
      "calendars", "delete", "--id", created.id, "--dry-run", "--json"]))
    #expect(backend.deletedCalendars.isEmpty)
    _ = try command.run(options: CLIOptionsFixture.parse([
      "calendars", "delete", "--id", created.id, "--json"]))
    #expect(backend.deletedCalendars.first?.id == created.id)
  }

  @Test func calendarAttributeImmutabilityDoesNotBlockEventWritesAndBadFieldsDoNotReadSources() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    for fields in [["--title", " ", "--color", "#FFFFFF"], ["--title", "Valid", "--color", "#GGGGGG"]] {
      #expect(throws: CLIError.self) {
        try command.run(options: CLIOptionsFixture.parse([
          "calendars", "create", "--source", "source-icloud", "--json"] + fields))
      }
    }
    #expect(backend.readSourceIDs.isEmpty)
    backend.calendars[0].isImmutable = true
    let unchanged = try #require(try command.run(options: CLIOptionsFixture.parse([
      "calendars", "update", "--id", "cal-work", "--title", "Work", "--json"])))
    #expect((try jsonObject(unchanged.stdout ?? "")["data"] as? [String: Any])?["changed"] as? Bool == false)
    #expect(throws: CLIError.self) {
      try command.run(options: CLIOptionsFixture.parse([
        "calendars", "update", "--id", "cal-work", "--title", "Change", "--json"]))
    }
    #expect(backend.updatedCalendars.isEmpty)
    _ = try command.run(options: CLIOptionsFixture.parse([
      "events", "create", "--calendar", "cal-work", "--title", "Event",
      "--start", "2026-01-01T09:00:00Z", "--end", "2026-01-01T10:00:00Z", "--json"]))
    #expect(backend.createdDrafts.count == 1)
  }

  @Test func calendarCommandListsCalendarsAsJSON() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse(["calendars", "list", "--json"])

    let result = try #require(try command.run(options: options))
    #expect(result.exitCode == 0)

    let object = try jsonObject(result.stdout ?? "")
    #expect(object["ok"] as? Bool == true)

    let data = object["data"] as? [String: Any]
    let calendars = data?["calendars"] as? [[String: Any]]
    #expect(calendars?.first?["title"] as? String == "Work")
  }

  @Test func calendarEventsRequireBoundedRange() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse(["events", "list", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing date range to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func calendarSearchUsesQueryAndLimit() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "events",
      "search",
      "--from",
      "2026-01-01T00:00:00Z",
      "--to",
      "2026-01-02T00:00:00Z",
      "--query",
      "launch",
      "--limit",
      "1",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let events = data?["events"] as? [[String: Any]]

    #expect(events?.count == 1)
    #expect(events?.first?["title"] as? String == "Launch review")
  }

  @Test func calendarEventReadIncludesAttendeeMetadata() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "events",
      "read",
      "--id",
      "event-launch",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let event = data?["event"] as? [String: Any]
    let attendees = event?["attendees"] as? [[String: Any]]

    #expect(attendees?.count == 1)
    #expect(attendees?.first?["name"] as? String == "Ada Lovelace")
    #expect(attendees?.first?["url"] as? String == "mailto:ada@example.com")
    #expect(attendees?.first?["status"] as? String == "accepted")
    #expect(attendees?.first?["role"] as? String == "required")
    #expect(attendees?.first?["type"] as? String == "person")
    #expect(attendees?.first?["isCurrentUser"] as? Bool == false)
  }

  @Test func calendarEventOccurrencesReturnBoundedSeriesRows() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "events",
      "occurrences",
      "--id",
      "event-launch",
      "--from",
      "2026-01-01T00:00:00Z",
      "--to",
      "2026-02-01T00:00:00Z",
      "--limit",
      "2",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let series = data?["series"] as? [String: Any]
    let occurrences = data?["occurrences"] as? [[String: Any]]

    #expect(series?["id"] as? String == "event-launch")
    #expect(occurrences?.count == 2)
    #expect(occurrences?.first?["occurrenceKey"] as? String == "event-launch@2026-01-01T00:00:00Z")
    #expect(occurrences?.first?["seriesId"] as? String == "event-launch")
    #expect(occurrences?.first?["start"] as? String == "2026-01-01T00:00:00Z")
    #expect(occurrences?.first?["isDetached"] as? Bool == false)
    #expect(backend.occurrenceQueries.first?.eventId == "event-launch")
    #expect(backend.occurrenceQueries.first?.limit == 2)
  }

  @Test func calendarEventOccurrencesRejectDryRunOptions() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "events",
      "occurrences",
      "--id",
      "event-launch",
      "--from",
      "2026-01-01",
      "--to",
      "2026-02-01",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected event occurrences to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func calendarAvailabilityCheckReturnsBusyConflicts() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "availability",
      "check",
      "--from",
      "2026-01-01T00:30:00Z",
      "--to",
      "2026-01-01T00:45:00Z",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let conflicts = data?["conflicts"] as? [[String: Any]]

    #expect(data?["isBusy"] as? Bool == true)
    #expect(data?["conflictCount"] as? Int == 1)
    #expect(conflicts?.first?["id"] as? String == "event-launch")
  }

  @Test func calendarAvailabilityCheckReturnsFreeWindow() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "availability",
      "check",
      "--from",
      "2026-01-01T04:00:00Z",
      "--to",
      "2026-01-01T04:30:00Z",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let conflicts = data?["conflicts"] as? [[String: Any]]

    #expect(data?["isBusy"] as? Bool == false)
    #expect(data?["conflictCount"] as? Int == 0)
    #expect(conflicts?.isEmpty == true)
  }

  @Test func calendarAvailabilityCheckRejectsDryRunOptions() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "availability",
      "check",
      "--from",
      "2026-01-01T09:00:00Z",
      "--to",
      "2026-01-01T10:00:00Z",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected availability check to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func calendarEventsStatsReturnsBoundedCounts() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "events",
      "stats",
      "--from",
      "2026-01-01T00:00:00Z",
      "--to",
      "2026-01-01T04:00:00Z",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let calendars = data?["calendars"] as? [[String: Any]]

    #expect(data?["eventCount"] as? Int == 2)
    #expect(data?["allDayEventCount"] as? Int == 0)
    #expect(data?["busySeconds"] as? Int == 7_200)
    #expect(calendars?.first?["calendarTitle"] as? String == "Work")
    #expect(calendars?.first?["eventCount"] as? Int == 2)
  }

  @Test func calendarEventsStatsRejectsDryRunOptions() throws {
    let command = CalendarCommand(backend: FakeCalendarBackend())
    let options = try CLIOptionsFixture.parse([
      "events",
      "stats",
      "--from",
      "2026-01-01",
      "--to",
      "2026-01-02",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected calendar event stats to reject dryRun options.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func calendarEventsExportRequiresAllowArtifactActionBeforeBackend() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let destination = temporaryICalendarPath()
    let options = try CLIOptionsFixture.parse([
      "events",
      "export",
      "--from",
      "2026-01-01",
      "--to",
      "2026-01-02",
      "--format",
      "ics",
      "--output",
      destination,
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected calendar event export execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
      #expect(backend.listEventQueries.isEmpty)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func calendarEventsExportDryRunAndAllowFlagExecutesEvents() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let destination = temporaryICalendarPath()
    defer { try? FileManager.default.removeItem(atPath: destination) }

    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "export",
      "--from",
      "2026-01-01T00:00:00Z",
      "--to",
      "2026-01-01T04:00:00Z",
      "--format",
      "ics",
      "--output",
      destination,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["event_count"] as? String == "2")
    #expect(FileManager.default.fileExists(atPath: destination) == false)

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "export",
      "--from",
      "2026-01-01T00:00:00Z",
      "--to",
      "2026-01-01T04:00:00Z",
      "--format",
      "ics",
      "--output",
      destination,
      "--allow-artifact-action",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let content = try String(contentsOfFile: destination, encoding: .utf8)

    #expect(data?["operation"] as? String == "events.export")
    #expect(data?["eventCount"] as? Int == 2)
    #expect((data?["byteCount"] as? Int ?? 0) > 0)
    #expect(content.contains("BEGIN:VCALENDAR"))
    #expect(content.contains("BEGIN:VEVENT"))
    #expect(content.contains("SUMMARY:Launch review"))
    #expect(content.contains("BEGIN:VALARM"))
    try FileManager.default.removeItem(atPath: destination)
    backend.listedRecurrence = CalendarRecurrenceRule(frequency: "weekly")
    for options in [dryRunOptions, executeOptions] {
      do {
        _ = try command.run(options: options)
        Issue.record("Expanded occurrences cannot provide complete series export data.")
      } catch let error as CLIError {
        #expect(error.code == .unsupportedOperation)
      }
      #expect(!FileManager.default.fileExists(atPath: destination))
    }
  }

  @Test func calendarEventCreateExecutesWithoutAllowFlag() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--json",
    ])

    _ = try #require(try command.run(options: options))

    #expect(backend.createdDrafts.map(\.title) == ["Launch review"])
  }

  @Test func calendarEventCreateDryRunAndExecutionCreatesDraft() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--location",
      "Room 1",
      "--alarm-minutes-before",
      "30,10",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--location",
      "Room 1",
      "--alarm-minutes-before",
      "30,10",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let event = executedData?["event"] as? [String: Any]

    #expect(event?["id"] as? String == "event-created")
    #expect((event?["alarmMinutesBefore"] as? [Any])?.compactMap { $0 as? Int } == [10, 30])
    #expect(backend.createdDrafts.map(\.title) == ["Launch review"])
    #expect(backend.createdDrafts.first?.alarmMinutesBefore == [10, 30])
  }

  @Test func calendarEventCreateDryRunAndExecutionUsesAbsoluteAlarms() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--alarm-at",
      "2026-01-01T08:45:00Z,2026-01-01T08:30:00Z",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let summary = data?["normalizedArguments"] as? [String: Any]

    #expect(summary?["alarm_at"] as? String == "2026-01-01T08:30:00Z,2026-01-01T08:45:00Z")

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--alarm-at",
      "2026-01-01T08:45:00Z,2026-01-01T08:30:00Z",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let event = executedData?["event"] as? [String: Any]

    #expect(event?["id"] as? String == "event-created")
    #expect(
      event?["absoluteAlarmDates"] as? [String] == ["2026-01-01T08:30:00Z", "2026-01-01T08:45:00Z"])
    #expect(
      backend.createdDrafts.first?.absoluteAlarmDates == [
        try isoDate("2026-01-01T08:30:00Z"),
        try isoDate("2026-01-01T08:45:00Z"),
      ])
  }

  @Test func calendarEventUpdateDryRunAndExecutionAppliesPatch() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "update",
      "--id",
      "event-launch",
      "--title",
      "Launch readiness",
      "--clear-location",
      "--alarm-minutes-before",
      "15,5",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "update",
      "--id",
      "event-launch",
      "--title",
      "Launch readiness",
      "--clear-location",
      "--alarm-minutes-before",
      "15,5",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let event = executedData?["event"] as? [String: Any]

    #expect(event?["title"] as? String == "Launch readiness")
    #expect(event?["location"] == nil)
    #expect((event?["alarmMinutesBefore"] as? [Any])?.compactMap { $0 as? Int } == [5, 15])
    #expect(backend.updatedPatches["event-launch"]?.title == "Launch readiness")
    #expect(backend.updatedPatches["event-launch"]?.alarmMinutesBefore == [5, 15])
  }

  @Test func calendarEventUpdateDryRunDryRunCanClearAlarms() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "update",
      "--id",
      "event-launch",
      "--clear-alarms",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "update",
      "--id",
      "event-launch",
      "--clear-alarms",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let event = executedData?["event"] as? [String: Any]

    #expect((event?["alarmMinutesBefore"] as? [Any])?.compactMap { $0 as? Int } == [])
    #expect(event?["absoluteAlarmDates"] as? [String] == [])
    #expect(backend.updatedPatches["event-launch"]?.clearAlarms == true)
  }

  @Test func calendarEventCreateDryRunAndExecutionUsesRecurrence() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--recurrence-frequency",
      "weekly",
      "--recurrence-interval",
      "2",
      "--recurrence-count",
      "5",
      "--recurrence-by-day",
      "WE,MO",
      "--recurrence-by-set-pos",
      "-1",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "create",
      "--calendar",
      "Work",
      "--title",
      "Launch review",
      "--start",
      "2026-01-01T09:00:00Z",
      "--end",
      "2026-01-01T10:00:00Z",
      "--recurrence-frequency",
      "weekly",
      "--recurrence-interval",
      "2",
      "--recurrence-count",
      "5",
      "--recurrence-by-day",
      "WE,MO",
      "--recurrence-by-set-pos",
      "-1",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let event = executedData?["event"] as? [String: Any]
    let recurrence = event?["recurrence"] as? [String: Any]

    #expect(recurrence?["frequency"] as? String == "weekly")
    #expect(recurrence?["interval"] as? Int == 2)
    #expect(recurrence?["occurrenceCount"] as? Int == 5)
    let days = try #require(recurrence?["daysOfTheWeek"] as? [[String: Any]])
    #expect(days.compactMap { $0["dayOfWeek"] as? String } == ["MO", "WE"])
    #expect((recurrence?["setPositions"] as? [Int]) == [-1])
    #expect(backend.createdDrafts.first?.recurrence?.frequency == "weekly")
  }

  @Test func calendarEventUpdateDryRunDryRunCanClearRecurrence() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events",
      "update",
      "--id",
      "event-launch",
      "--clear-recurrence",
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "update",
      "--id",
      "event-launch",
      "--clear-recurrence",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]
    let event = executedData?["event"] as? [String: Any]

    #expect(event?["recurrence"] == nil)
    #expect(backend.updatedPatches["event-launch"]?.clearRecurrence == true)
  }

  @Test func calendarEventDeleteDryRunAndExecutionDeletesEvent() throws {
    let backend = FakeCalendarBackend()
    let command = CalendarCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "events", "delete", "--id", "event-launch", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    _ = dryRunObject["data"] as? [String: Any]

    let executeOptions = try CLIOptionsFixture.parse([
      "events",
      "delete",
      "--id",
      "event-launch",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["deletedID"] as? String == "event-launch")
    #expect(backend.deletedIDs == ["event-launch"])
  }

}

private final class FakeCalendarBackend: CalendarReading, CalendarMutating, @unchecked Sendable {
  var calendars = [CalendarRecord(
    id: "cal-work", title: "Work", sourceTitle: "iCloud", allowsContentModifications: true,
    sourceId: "source-icloud", type: "caldav", typeRawValue: 1, isImmutable: false,
    isSubscribed: false, color: "#123456FF", allowedEntityTypesRawValue: 1,
    supportedEventAvailabilitiesRawValue: 15)]
  var sources = [CalendarSourceRecord(
    id: "source-icloud", title: "iCloud", type: "caldav", typeRawValue: 2,
    isDelegate: false, calendarIds: ["cal-work"])]
  var readSourceIDs: [String] = []
  var createdCalendars: [CalendarCreateDraft] = []
  var updatedCalendars: [(CalendarRecord, CalendarPatch)] = []
  var deletedCalendars: [CalendarRecord] = []
  var listedRecurrence: CalendarRecurrenceRule?
  var createdDrafts: [CalendarEventDraft] = []
  var updatedPatches: [String: CalendarEventPatch] = [:]
  var deletedIDs: [String] = []
  var listEventQueries: [CalendarEventQuery] = []
  var occurrenceQueries: [CalendarEventOccurrenceQuery] = []
  let launchAbsoluteAlarm = Date(timeIntervalSince1970: 1_767_222_900)
  var attendees = [
    CalendarAttendeeRecord(
      name: "Ada Lovelace",
      url: "mailto:ada@example.com",
      status: "accepted",
      role: "required",
      type: "person"
    )
  ]

  func listSources() throws -> [CalendarSourceRecord] { sources }

  func readSource(id: String) throws -> CalendarSourceRecord? {
    readSourceIDs.append(id)
    return sources.first { $0.id == id }
  }

  func listCalendars(sourceID: String?) throws -> [CalendarRecord] {
    calendars.filter { sourceID == nil || $0.sourceId == sourceID }
  }

  func readCalendar(id: String) throws -> CalendarRecord? {
    calendars.first { $0.id == id }
  }

  func createCalendar(_ draft: CalendarCreateDraft) throws -> CalendarRecord {
    createdCalendars.append(draft)
    let source = try #require(sources.first { $0.id == draft.sourceId })
    let calendar = CalendarRecord(
      id: "cal-created", title: draft.title, sourceTitle: source.title, allowsContentModifications: true,
      sourceId: source.id, type: "caldav", typeRawValue: 1, isImmutable: false,
      isSubscribed: false, color: draft.color, allowedEntityTypesRawValue: 1,
      supportedEventAvailabilitiesRawValue: 15)
    calendars.append(calendar)
    return calendar
  }

  func updateCalendar(current: CalendarRecord, patch: CalendarPatch) throws -> CalendarRecord {
    updatedCalendars.append((current, patch))
    let index = try #require(calendars.firstIndex { $0.id == current.id })
    if let title = patch.title { calendars[index].title = title }
    if let color = patch.color { calendars[index].color = color }
    return calendars[index]
  }

  func deleteCalendar(current: CalendarRecord) throws -> Bool {
    deletedCalendars.append(current)
    calendars.removeAll { $0.id == current.id }
    return true
  }

  func listEvents(_ query: CalendarEventQuery) throws -> [CalendarEventSummary] {
    listEventQueries.append(query)
    let events = [
      CalendarEventSummary(
        id: "event-launch",
        calendarId: "cal-work",
        calendarTitle: "Work",
        title: "Launch review",
        start: Date(timeIntervalSince1970: 1_767_225_600),
        end: Date(timeIntervalSince1970: 1_767_229_200),
        isAllDay: false,
        location: "Room 1",
        alarmMinutesBefore: [30],
        absoluteAlarmDates: [launchAbsoluteAlarm],
        recurrence: listedRecurrence,
        attendees: attendees
      ),
      CalendarEventSummary(
        id: "event-other",
        calendarId: "cal-work",
        calendarTitle: "Work",
        title: "Planning",
        start: Date(timeIntervalSince1970: 1_767_232_800),
        end: Date(timeIntervalSince1970: 1_767_236_400),
        isAllDay: false
      ),
    ]

    return
      events
      .filter { event in
        guard event.start < query.to, event.end > query.from else {
          return false
        }
        guard let searchText = query.searchText else {
          return true
        }
        return event.title.localizedCaseInsensitiveContains(searchText)
      }
      .prefix(query.limit)
      .map { $0 }
  }

  func readEvent(id: String) throws -> CalendarEventDetail? {
    guard id == "event-launch" else {
      return nil
    }

    return CalendarEventDetail(
      id: "event-launch",
      calendarId: "cal-work",
      calendarTitle: "Work",
      title: "Launch review",
      start: Date(timeIntervalSince1970: 1_767_225_600),
      end: Date(timeIntervalSince1970: 1_767_229_200),
      isAllDay: false,
      notes: "Private notes stay in stdout JSON only.",
      alarmMinutesBefore: [30],
      absoluteAlarmDates: [launchAbsoluteAlarm],
      recurrence: CalendarRecurrenceRule(frequency: "weekly", interval: 1, occurrenceCount: 4),
      attendees: attendees
    )
  }

  func listEventOccurrences(_ query: CalendarEventOccurrenceQuery) throws
    -> CalendarEventOccurrencesResponse?
  {
    occurrenceQueries.append(query)
    guard let series = try readEvent(id: query.eventId) else {
      return nil
    }

    let starts = [
      Date(timeIntervalSince1970: 1_767_225_600),
      Date(timeIntervalSince1970: 1_767_830_400),
      Date(timeIntervalSince1970: 1_768_435_200),
      Date(timeIntervalSince1970: 1_769_040_000),
    ]
    let occurrences = starts.enumerated()
      .map { index, start in
        CalendarEventOccurrence(
          occurrenceKey: "\(query.eventId)@\(isoDateString(start))",
          id: index == 0 ? "event-launch" : "event-launch-\(index + 1)",
          seriesId: query.eventId,
          calendarId: "cal-work",
          calendarTitle: "Work",
          title: "Launch review",
          start: start,
          end: start.addingTimeInterval(60 * 60),
          occurrenceDate: start,
          isDetached: index == 2,
          isAllDay: false,
          location: "Room 1",
          alarmMinutesBefore: [30],
          absoluteAlarmDates: index == 0 ? [launchAbsoluteAlarm] : [],
          attendees: attendees
        )
      }
      .filter { $0.start < query.to && $0.end > query.from }
      .prefix(query.limit)

    return CalendarEventOccurrencesResponse(
      series: series,
      from: query.from,
      to: query.to,
      calendarSelector: query.calendarSelector,
      occurrences: Array(occurrences)
    )
  }

  func calendarForMutation(selector: String) throws -> CalendarRecord {
    let calendars = try listCalendars(sourceID: nil)
    if let match = calendars.first(where: { $0.id == selector }) {
      return match
    }

    let titleMatches = calendars.filter {
      $0.title.localizedCaseInsensitiveCompare(selector) == .orderedSame
    }
    if titleMatches.count > 1 {
      throw CLIError(
        code: .ambiguousIdentity, message: "Calendar selector matched multiple calendars.",
        details: ["selector": selector])
    }

    guard let match = titleMatches.first else {
      throw CLIError(
        code: .notFound, message: "Calendar selector did not match any calendar.",
        details: ["selector": selector])
    }

    return match
  }

  func eventForMutation(id: String) throws -> CalendarEventDetail? {
    try readEvent(id: id)
  }

  func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEventDetail {
    createdDrafts.append(draft)
    return CalendarEventDetail(
      id: "event-created",
      calendarId: draft.calendarId,
      calendarTitle: "Work",
      title: draft.title,
      start: draft.start,
      end: draft.end,
      isAllDay: draft.isAllDay,
      location: draft.location,
      notes: draft.notes,
      alarmMinutesBefore: draft.alarmMinutesBefore,
      absoluteAlarmDates: draft.absoluteAlarmDates,
      recurrence: draft.recurrence
    )
  }

  func updateEvent(id: String, patch: CalendarEventPatch) throws -> CalendarEventDetail {
    updatedPatches[id] = patch
    guard var event = try readEvent(id: id) else {
      throw CLIError(code: .notFound, message: "Calendar event was not found.", details: ["id": id])
    }

    if let calendarId = patch.calendarId {
      event.calendarId = calendarId
    }
    if let title = patch.title {
      event.title = title
    }
    if let start = patch.start {
      event.start = start
    }
    if let end = patch.end {
      event.end = end
    }
    if let isAllDay = patch.isAllDay {
      event.isAllDay = isAllDay
    }
    if let location = patch.location {
      event.location = location
    } else if patch.clearLocation {
      event.location = nil
    }
    if let notes = patch.notes {
      event.notes = notes
    } else if patch.clearNotes {
      event.notes = nil
    }
    if let alarmMinutesBefore = patch.alarmMinutesBefore {
      event.alarmMinutesBefore = alarmMinutesBefore
      event.absoluteAlarmDates = patch.absoluteAlarmDates ?? []
    } else if let absoluteAlarmDates = patch.absoluteAlarmDates {
      event.alarmMinutesBefore = []
      event.absoluteAlarmDates = absoluteAlarmDates
    } else if patch.clearAlarms {
      event.alarmMinutesBefore = []
      event.absoluteAlarmDates = []
    }
    if let recurrence = patch.recurrence {
      event.recurrence = recurrence
    } else if patch.clearRecurrence {
      event.recurrence = nil
    }

    return event
  }

  func deleteEvent(id: String) throws -> Bool {
    deletedIDs.append(id)
    return true
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw EventKitCommandTestError.notObject
  }
  return object
}

private func isoDate(_ value: String) throws -> Date {
  guard let date = ISO8601DateFormatter().date(from: value) else {
    throw EventKitCommandTestError.invalidDate
  }
  return date
}

private func isoDateString(_ date: Date) -> String {
  ISO8601DateFormatter().string(from: date)
}

private func temporaryICalendarPath() -> String {
  FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-\(UUID().uuidString).ics")
    .path
}

private enum EventKitCommandTestError: Error {
  case notObject
  case invalidDate
}
