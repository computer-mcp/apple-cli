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

Read and mutation workflows require full Calendar access. Mutations resolve
calendars and current events before writing; write-only access cannot supply
those identities. `apple` embeds its Calendar access purpose descriptions from
`Sources/AppleCLI/Info.plist` through the package's executable linker settings.
`calendar doctor` checks this metadata without requesting authorization.

## Implementation Mechanisms

Calendar uses EventKit for source/account reads, calendar list/read and
create/update/delete, event list/search/read, occurrences, availability,
statistics, iCalendar export planning, and event create/update/delete.

Calendar collection mutations use explicit source or calendar IDs. Source
identity is fixed when a calendar is created. Calendar updates modify only
requested title/color fields; immutable calendar attributes are separate from
permission to modify its events. Update/delete re-resolve and compare the
calendar record before writing. Successful saves require matching fields from
a fresh EventKit store; deletion requires absence there. Provider save failures
retain their diagnostics and require checking current state before retrying.

Event summaries and details expose all EventKit recurrence rules in
`recurrenceRules`; `recurrence` contains the first rule. Each rule retains
weekday ordinals, month/day/week selectors, set positions, recurrence-calendar
identity and the native first weekday. A zero first weekday means unspecified.
Custom recurrence input replaces the event's rules; other field updates leave
them intact. Invalid frequency/selector combinations are rejected before native
construction. The full EventKit initializer must retain the requested conditions
in its getters before the rule is attached to an event.

iCalendar export accepts non-recurring events. Bounded EventKit queries return
expanded occurrences without complete series masters and exception data.
Recurring or detached rows therefore return an unsupported result before an
artifact is written. Series export requires complete original occurrence,
exception, UID and time-zone data.

All-day export uses the observed event time zone, or the current macOS time
zone when EventKit supplies none. Its date-only end remains exclusive across
daylight-saving changes. Summaries/details retain the observed time-zone
identifier; timed export currently represents UTC instants.

## Validation

Use `apple calendar doctor --json`, bounded date ranges in command help, and
EventKit command tests. Detailed command status lives in `CapabilityList.md`.
