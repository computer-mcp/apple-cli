# Calendar Architecture

`calendar` owns local Calendar/EventKit workflows under `apple calendar`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Calendar currently uses EventKit, a public Apple framework, for
accepted reads, export planning, and mutations. It does not currently rely on a
broad private Calendar implementation mechanism.

## Source Authority

EventKit is the source of authority for accepted calendar and event identity,
authorization, recurrence, alarms, attendee metadata, and mutations.

## Implementation Mechanisms

Calendar uses EventKit for calendars, event list/search/read, occurrences,
availability, statistics, iCalendar export planning, and safety-gated
event create/update/delete.

## Validation

Use `apple calendar doctor --json`, bounded date ranges in command help, and
EventKit command tests. Detailed command status lives in `CapabilityList.md`.
