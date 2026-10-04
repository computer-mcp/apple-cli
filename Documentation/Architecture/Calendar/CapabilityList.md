# Calendar Capability List

## Source Authority

Calendar capabilities are accepted from EventKit behavior and the local CLI
contract.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Source/account reads | `sources list/read` | EventKit | Native source IDs, type, delegation state and event-calendar membership; `read` requires an ID. |
| Calendar reads | `calendars list/read` | EventKit | Full Calendar access; optional source-ID filtering, explicit-limit truncation and native source/type/attribute permissions/color metadata. |
| Calendar mutation | `calendars create/update/delete` | EventKit | Creation requires source ID; update/delete require calendar ID. Preview before writing; immutable attribute changes/deletion rejected; unchanged requests skip saves. Saves and deletion use fresh-store verification. Updates support title/color and preserve other projected fields. Provider restrictions remain explicit. |
| Event reads | `events list/search/read/occurrences/stats`, `availability check` | EventKit | Date ranges and limits bound output; invalid or noncanonical date-only values are rejected. Summaries/details retain all recurrence rules and their custom conditions. |
| Event export | `events export` | EventKit plus file output | Non-recurring events; supports `--dry-run` and requires `--allow-artifact-action` for execution. Recurring/detached rows require complete series and exception data and currently return unsupported before writing. |
| Event mutation | `events create/update/delete` | EventKit | Supports `--dry-run`; full Calendar access is required to resolve calendar and event identity. Custom weekday/month/week/year-day/set-position conditions are validated and checked against native rule getters; provider persistence requires controlled native validation. |

## Rejected / Gated

- Occurrence-scoped mutation.
- Complete recurring-series iCalendar export.
- Attendee invite administration beyond accepted metadata behavior.
- Broad calendar-server administration.
