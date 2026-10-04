import CryptoKit
import EventKit
import Foundation
import Utility

public struct CalendarCommand: Sendable {
  private let backend: any CalendarReading & CalendarMutating
  private let target = "calendar"

  public init(backend: any CalendarReading & CalendarMutating = EventKitCalendarBackend()) {
    self.backend = backend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["sources", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: [])
      let sources = try backend.listSources()
      let selected = Array(sources.prefix(options.limit ?? sources.count))
      return try result(
        CalendarSourceListResponse(sources: selected, truncated: selected.count < sources.count),
        human: calendarSourcesHumanOutput(selected), options: options)
    case ["sources", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let source = try backend.readSource(id: id) else {
        throw CLIError(
          code: .notFound, message: "Calendar source was not found.", details: ["source_id": id])
      }
      return try result(
        CalendarSourceResponse(source: source), human: calendarSourcesHumanOutput([source]),
        options: options)
    case ["calendars", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["source"])
      let sourceID = try options.targetOption("source").map { _ in
        try requiredOption("source", options: options)
      }
      let calendars = try backend.listCalendars(sourceID: sourceID)
      let selected = Array(calendars.prefix(options.limit ?? calendars.count))
      return try result(
        CalendarListResponse(calendars: selected, truncated: selected.count < calendars.count),
        human: calendarsHumanOutput(selected),
        options: options
      )
    case ["calendars", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let calendar = try calendarCollectionIdentity(options)
      return try result(
        CalendarResponse(calendar: calendar), human: calendarsHumanOutput([calendar]), options: options)
    case ["calendars", "create"]:
      try validateTargetOptions(options, allowedOptions: ["source", "title", "color"])
      let draft = CalendarCreateDraft(
        sourceId: try requiredOption("source", options: options),
        title: try validatedCalendarTitle(requiredOption("title", options: options)),
        color: try options.targetOption("color").map(validatedCalendarColor))
      guard let source = try backend.readSource(id: draft.sourceId) else {
        throw CLIError(
          code: .notFound, message: "Calendar source was not found.",
          details: ["source_id": draft.sourceId])
      }
      try requireCalendarCreationSource(source)
      return try mutation(
        operation: "calendars.create",
        scopeDigest: calendarCollectionScope(
          operation: "calendars.create",
          payload: CalendarCollectionMutationScope(source: source, draft: draft)),
        summary: [
          "source_id": source.id, "source_title": source.title, "title": draft.title,
          "color": draft.color ?? "default",
        ], options: options
      ) {
        let calendar = try backend.createCalendar(draft)
        return CalendarMutationResult(
          operation: "calendars.create", changed: true, event: nil, deletedID: nil, calendar: calendar)
      }
    case ["calendars", "update"]:
      try validateTargetOptions(options, allowedOptions: ["id", "title", "color"])
      let patch = CalendarPatch(
        title: try options.targetOption("title").map(validatedCalendarTitle),
        color: try options.targetOption("color").map(validatedCalendarColor))
      guard patch.title != nil || patch.color != nil else {
        throw CLIError(
          code: .validationError, message: "At least one calendar field must be supplied for update.")
      }
      let current = try calendarCollectionIdentity(options)
      let unchanged = (patch.title == nil || patch.title == current.title)
        && (patch.color == nil || patch.color == current.color)
      if !unchanged { try requireMutableCalendar(current) }
      return try mutation(
        operation: "calendars.update",
        scopeDigest: calendarCollectionScope(
          operation: "calendars.update",
          payload: CalendarCollectionMutationScope(current: current, patch: patch)),
        summary: [
          "id": current.id, "source_id": current.sourceId ?? "unavailable",
          "title": patch.title ?? current.title, "color": patch.color ?? current.color ?? "unavailable",
        ], options: options
      ) {
        if unchanged {
          return CalendarMutationResult(
            operation: "calendars.update", changed: false, event: nil, deletedID: nil, calendar: current)
        }
        let calendar = try backend.updateCalendar(current: current, patch: patch)
        return CalendarMutationResult(
          operation: "calendars.update", changed: calendar != current, event: nil, deletedID: nil,
          calendar: calendar)
      }
    case ["calendars", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      let current = try calendarCollectionIdentity(options)
      try requireMutableCalendar(current)
      return try mutation(
        operation: "calendars.delete",
        scopeDigest: calendarCollectionScope(operation: "calendars.delete", payload: current),
        summary: [
          "id": current.id, "source_id": current.sourceId ?? "unavailable", "title": current.title,
          "deletes_calendar_and_contents": "true",
        ], options: options
      ) {
        let changed = try backend.deleteCalendar(current: current)
        return CalendarMutationResult(
          operation: "calendars.delete", changed: changed, event: nil, deletedID: current.id)
      }
    case ["events", "list"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["from", "to", "calendar"])
      let query = try eventQuery(options: options, searchText: nil)
      let events = try backend.listEvents(query)
      return try result(
        CalendarEventsResponse(events: events),
        human: eventsHumanOutput(events),
        options: options
      )
    case ["events", "search"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["from", "to", "calendar", "query"])
      let searchText = try requiredOption("query", options: options)
      let query = try eventQuery(options: options, searchText: searchText)
      let events = try backend.listEvents(query)
      return try result(
        CalendarEventsResponse(events: events),
        human: eventsHumanOutput(events),
        options: options
      )
    case ["events", "read"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try requiredOption("id", options: options)
      guard let event = try backend.readEvent(id: id) else {
        throw CLIError(
          code: .notFound,
          message: "Calendar event was not found.",
          details: ["id": id]
        )
      }
      return try result(
        CalendarEventResponse(event: event),
        human: eventHumanOutput(event),
        options: options
      )
    case ["events", "occurrences"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["id", "from", "to", "calendar"])
      let query = try eventOccurrenceQuery(options: options)
      guard let response = try backend.listEventOccurrences(query) else {
        throw CLIError(
          code: .notFound,
          message: "Calendar event was not found.",
          details: ["id": query.eventId]
        )
      }
      return try result(
        response,
        human: eventOccurrencesHumanOutput(response.occurrences),
        options: options
      )
    case ["availability", "check"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["from", "to", "calendar"])
      let query = try eventQuery(options: options, searchText: nil)
      let conflicts = try backend.listEvents(query)
      return try result(
        CalendarAvailabilityResponse(
          from: query.from,
          to: query.to,
          calendarSelector: query.calendarSelector,
          isBusy: !conflicts.isEmpty,
          conflictCount: conflicts.count,
          conflicts: conflicts
        ),
        human: availabilityHumanOutput(from: query.from, to: query.to, conflicts: conflicts),
        options: options
      )
    case ["events", "stats"]:
      try validateReadOnly(options)
      try validateTargetOptions(options, allowedOptions: ["from", "to", "calendar"])
      let query = try eventQuery(options: options, searchText: nil)
      let events = try backend.listEvents(query)
      let statistics = calendarStatistics(query: query, events: events)
      return try result(
        statistics,
        human: statisticsHumanOutput(statistics),
        options: options
      )
    case ["events", "export"]:
      try validateTargetOptions(
        options, allowedOptions: ["from", "to", "calendar", "format", "output"])
      try validateExportIntent(options)
      let format = try exportFormat(options)
      let destinationPath = standardizedAbsolutePath(try requiredOption("output", options: options))
      try validateICalendarExportDestination(destinationPath)
      if !options.dryRun {
        try CLISafety.requireFlag(
          "allow-artifact-action",
          in: options,
          category: .artifactAction,
          message: "Calendar export writes a filesystem artifact and requires `--allow-artifact-action`."
        )
      }
      let query = try eventQuery(options: options, searchText: nil)
      let events = try backend.listEvents(query)
      return try exportEvents(
        events, query: query, format: format, destinationPath: destinationPath, options: options)
    case ["events", "create"]:
      try validateTargetOptions(
        options,
        allowedOptions: recurrenceOptionNames.union([
          "calendar",
          "title",
          "start",
          "end",
          "location",
          "notes",
          "alarm-minutes-before",
          "alarm-at",
        ]),
        allowedFlags: ["all-day"]
      )
      try validateMutationIntent(options)
      let draft = try eventCreateDraft(options)
      return try mutation(
        operation: "events.create",
        scopeDigest: eventCreateScopeDigest(draft),
        summary: eventCreateSummary(draft),
        options: options
      ) {
        let event = try backend.createEvent(draft)
        return CalendarMutationResult(
          operation: "events.create", changed: true, event: event, deletedID: nil)
      }
    case ["events", "update"]:
      try validateTargetOptions(
        options,
        allowedOptions: recurrenceOptionNames.union([
          "id",
          "calendar",
          "title",
          "start",
          "end",
          "location",
          "notes",
          "alarm-minutes-before",
          "alarm-at",
        ]),
        allowedFlags: [
          "all-day", "timed", "clear-location", "clear-notes", "clear-alarms", "clear-recurrence",
        ]
      )
      try validateMutationIntent(options)
      let identity = try eventMutationIdentity(options)
      let patch = try eventUpdatePatch(options, current: identity.event)
      return try mutation(
        operation: "events.update",
        scopeDigest: eventUpdateScopeDigest(current: identity.event, patch: patch),
        summary: eventUpdateSummary(current: identity.event, patch: patch),
        options: options
      ) {
        let event = try backend.updateEvent(id: identity.event.id, patch: patch)
        return CalendarMutationResult(
          operation: "events.update", changed: true, event: event, deletedID: nil)
      }
    case ["events", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      try validateMutationIntent(options)
      let identity = try eventMutationIdentity(options)
      return try mutation(
        operation: "events.delete",
        scopeDigest: identity.scopeDigest,
        summary: identity.summaryFields,
        options: options
      ) {
        let changed = try backend.deleteEvent(id: identity.event.id)
        return CalendarMutationResult(
          operation: "events.delete", changed: changed, event: nil, deletedID: identity.event.id)
      }
    default:
      return nil
    }
  }

  private func calendarCollectionIdentity(_ options: CLIOptions) throws -> CalendarRecord {
    let id = try requiredOption("id", options: options)
    guard let calendar = try backend.readCalendar(id: id) else {
      throw CLIError(
        code: .notFound, message: "Calendar was not found.", details: ["calendar_id": id])
    }
    return calendar
  }

  private func eventCreateDraft(_ options: CLIOptions) throws -> CalendarEventDraft {
    let calendarSelector = try requiredOption("calendar", options: options)
    let title = try requiredOption("title", options: options).trimmingCharacters(
      in: .whitespacesAndNewlines)
    guard !title.isEmpty else {
      throw CLIError(code: .validationError, message: "`--title` must not be empty.")
    }

    let start = try parseEventDate(try requiredOption("start", options: options))
    let end = try parseEventDate(try requiredOption("end", options: options))
    try validateEventRange(start: start, end: end)

    let relativeAlarms = try alarmMinutesBeforeOption(options) ?? []
    let absoluteAlarms = try alarmAtOption(options) ?? []
    let recurrence = try recurrenceRuleOption(options, effectiveStart: start)
    let calendar = try backend.calendarForMutation(selector: calendarSelector)
    guard calendar.allowsContentModifications else {
      throw CLIError(code: .validationError, message: "Calendar does not allow modifications.",
        details: ["calendar": calendar.title])
    }

    return CalendarEventDraft(
      calendarId: calendar.id,
      title: title,
      start: start,
      end: end,
      isAllDay: options.hasTargetFlag("all-day"),
      location: options.targetOption("location"),
      notes: options.targetOption("notes"),
      alarmMinutesBefore: relativeAlarms,
      absoluteAlarmDates: absoluteAlarms,
      recurrence: recurrence
    )
  }

  private func eventUpdatePatch(_ options: CLIOptions, current: CalendarEventDetail) throws
    -> CalendarEventPatch
  {
    if options.hasTargetFlag("all-day"), options.hasTargetFlag("timed") {
      throw CLIError(
        code: .validationError, message: "`--all-day` and `--timed` cannot be combined.")
    }

    if options.hasTargetFlag("clear-location"), options.targetOption("location") != nil {
      throw CLIError(
        code: .validationError, message: "`--clear-location` cannot be combined with `--location`.")
    }

    if options.hasTargetFlag("clear-notes"), options.targetOption("notes") != nil {
      throw CLIError(
        code: .validationError, message: "`--clear-notes` cannot be combined with `--notes`.")
    }

    if options.hasTargetFlag("clear-alarms"),
      options.targetOption("alarm-minutes-before") != nil || options.targetOption("alarm-at") != nil
    {
      throw CLIError(
        code: .validationError,
        message: "`--clear-alarms` cannot be combined with alarm replacement options."
      )
    }

    if options.hasTargetFlag("clear-recurrence"), hasRecurrenceOptions(options) {
      throw CLIError(
        code: .validationError,
        message: "`--clear-recurrence` cannot be combined with recurrence options."
      )
    }

    let calendarId: String?
    if let calendarSelector = options.targetOption("calendar") {
      let calendar = try backend.calendarForMutation(selector: calendarSelector)
      guard calendar.allowsContentModifications else {
        throw CLIError(
          code: .validationError, message: "Calendar does not allow modifications.",
          details: ["calendar": calendar.title])
      }
      calendarId = calendar.id
    } else {
      calendarId = nil
    }

    let title = options.targetOption("title")?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let title, title.isEmpty {
      throw CLIError(code: .validationError, message: "`--title` must not be empty.")
    }

    let start = try options.targetOption("start").map(parseEventDate)
    let end = try options.targetOption("end").map(parseEventDate)
    try validateEventRange(start: start ?? current.start, end: end ?? current.end)

    let patch = CalendarEventPatch(
      calendarId: calendarId,
      title: title,
      start: start,
      end: end,
      isAllDay: eventAllDayPatch(options),
      location: options.targetOption("location"),
      notes: options.targetOption("notes"),
      alarmMinutesBefore: try alarmMinutesBeforeOption(options),
      absoluteAlarmDates: try alarmAtOption(options),
      recurrence: try recurrenceRuleOption(options, effectiveStart: start ?? current.start),
      clearLocation: options.hasTargetFlag("clear-location"),
      clearNotes: options.hasTargetFlag("clear-notes"),
      clearAlarms: options.hasTargetFlag("clear-alarms"),
      clearRecurrence: options.hasTargetFlag("clear-recurrence")
    )

    guard patch.hasChanges else {
      throw CLIError(
        code: .validationError, message: "At least one event field must be supplied for update.")
    }

    return patch
  }

  private func eventMutationIdentity(_ options: CLIOptions) throws -> CalendarMutationIdentity {
    let id = try requiredOption("id", options: options)
    guard let event = try backend.eventForMutation(id: id) else {
      throw CLIError(code: .notFound, message: "Calendar event was not found.", details: ["id": id])
    }

    return CalendarMutationIdentity(
      event: event,
      scopeDigest: eventIdentityScopeDigest(event),
      summaryFields: [
        "id": event.id,
        "title": event.title,
        "calendar_id": event.calendarId,
        "start": formatDate(event.start),
        "end": formatDate(event.end),
        "alarm_minutes_before": alarmList(event.alarmMinutesBefore),
        "alarm_at": dateList(event.absoluteAlarmDates),
        "recurrence": recurrenceRulesSummary(event.recurrenceRules ?? event.recurrence.map { [$0] } ?? []),
        "attendee_count": "\(event.attendees.count)",
        "attendees_sha256": sha256Hex(attendeeList(event.attendees)),
      ]
    )
  }

  private func mutation(
    operation: String,
    scopeDigest: String,
    summary: [String: String],
    options: CLIOptions,
    commit: () throws -> CalendarMutationResult
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scopeDigest
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    return try result(try commit(), human: "\(operation) executed", options: options)
  }

  private func exportEvents(
    _ events: [CalendarEventSummary],
    query: CalendarEventQuery,
    format: String,
    destinationPath: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let content = try renderICalendar(events)
    let operation = "events.export"
    let scope = "calendar-event-export"
    let eventHash = sha256Hex(calendarExportEventList(events))
    let summary = [
      "from": formatDate(query.from),
      "to": formatDate(query.to),
      "calendar": query.calendarSelector ?? "",
      "format": format,
      "destination_path": destinationPath,
      "event_count": "\(events.count)",
      "events_sha256": eventHash,
    ]

    if options.dryRun {
      try validateDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .artifactAction,
          allowFlags: ["--allow-artifact-action"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-artifact-action",
      in: options,
      category: .artifactAction,
      message: "Calendar export writes a filesystem artifact and requires `--allow-artifact-action`."
    )

    let data = Data(content.utf8)
    try writeCalendarExport(data, to: destinationPath)
    return try result(
      CalendarExportResult(
        operation: operation,
        changed: true,
        destinationPath: destinationPath,
        format: format,
        eventCount: events.count,
        byteCount: data.count,
        sha256: sha256Hex(data)
      ),
      human: "\(operation) executed",
      options: options
    )
  }

  private func eventQuery(options: CLIOptions, searchText: String?) throws -> CalendarEventQuery {
    let from = try parseDateBoundary(try requiredOption("from", options: options), role: .lower)
    let to = try parseDateBoundary(try requiredOption("to", options: options), role: .upper)

    guard from < to else {
      throw CLIError(
        code: .validationError,
        message: "`--from` must be earlier than `--to`."
      )
    }

    guard to.timeIntervalSince(from) <= 366 * 24 * 60 * 60 else {
      throw CLIError(
        code: .validationError,
        message: "Calendar event queries must be bounded to 366 days or less."
      )
    }

    return CalendarEventQuery(
      from: from,
      to: to,
      calendarSelector: options.targetOption("calendar"),
      searchText: searchText,
      limit: try commandLimit(options)
    )
  }

  private func eventOccurrenceQuery(options: CLIOptions) throws -> CalendarEventOccurrenceQuery {
    let id = try requiredOption("id", options: options)
    let range = try eventQuery(options: options, searchText: nil)
    return CalendarEventOccurrenceQuery(
      eventId: id,
      from: range.from,
      to: range.to,
      calendarSelector: range.calendarSelector,
      limit: range.limit
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }

    return CLICommandResult(stdout: human)
  }
}
