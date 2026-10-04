# Calendar User Guide

Use `apple calendar --help` and subcommand help as the first reference.

Calendar reads and mutations require full Calendar access in macOS. Write-only
access cannot resolve the selected calendar or existing events. Run
`apple calendar doctor --json` to check authorization and the executable's access
purpose descriptions without requesting access.

Date-only inputs use `YYYY-MM-DD` in the local time zone and must name a real
Gregorian calendar day. A date-only `--to` includes that day by ending the range
at the next local day. Use an ISO-8601 date-time with an offset for an explicit
instant.

Common reads:

```bash
apple calendar sources list --json
apple calendar sources read --id SOURCE_ID --json
apple calendar calendars list --json
apple calendar calendars list --source SOURCE_ID --json
apple calendar calendars read --id CALENDAR_ID --json
apple calendar events list --from 2026-01-01 --to 2026-01-31 --json
apple calendar events read --id EVENT_ID --json
apple calendar availability check --from 2026-01-01T09:00:00Z --to 2026-01-01T10:00:00Z --json
```

Sources represent Calendar accounts. Use their IDs to select an account when
creating a calendar. Calendar reads include the source ID, type, attribute
permissions and color when available. An explicit `--limit` on source/calendar
lists sets `truncated` when it omits rows. IDs can change after a full sync;
refresh the list if an ID is no longer found.

Calendar creation and property changes:

```bash
apple calendar calendars create --source SOURCE_ID --title "Work" --color '#4A90E2' --dry-run --json
apple calendar calendars update --id CALENDAR_ID --title "Projects" --dry-run --json
apple calendar calendars update --id CALENDAR_ID --color '#4A90E2' --dry-run --json
apple calendar calendars delete --id CALENDAR_ID --dry-run --json
```

Remove `--dry-run` to execute. Update requires a title, color, or both; an
unchanged request returns `changed: false`. Colors use `#RRGGBB` or `#RRGGBBAA`
and read back as `#RRGGBBAA`. A calendar's source cannot be changed through an
update. Deletion removes the calendar and its contents. Account providers may
restrict creation or deletion, and immutable calendars cannot be renamed,
recolored or deleted even when they allow event writes. Requests that match the
current name/color still return an unchanged result without saving. Check current state
before retrying a save or deletion that failed.

Event export and mutations use the DryRun safety flow:

```bash
apple calendar events create --calendar Work --title "Review" --start 2026-01-01T09:00:00Z --end 2026-01-01T10:00:00Z --dry-run --json
```

Custom repeats can specify numbered weekdays or select the last matching day:

```bash
apple calendar events create --calendar Work --title "Monthly review" --start 2027-03-12T09:00:00Z --end 2027-03-12T10:00:00Z --recurrence-frequency monthly --recurrence-by-day 2FR --recurrence-count 6 --dry-run --json
apple calendar events create --calendar Work --title "Month end" --start 2027-03-31T09:00:00Z --end 2027-03-31T10:00:00Z --recurrence-frequency monthly --recurrence-by-day MO,TU,WE,TH,FR --recurrence-by-set-pos=-1 --dry-run --json
```

| Option | Meaning |
| --- | --- |
| `--recurrence-by-day` | `SU,MO,TU,WE,TH,FR,SA`; monthly/yearly rules also accept ordinals such as `2FR` or `-1MO`. Weekly rules require unnumbered weekdays. |
| `--recurrence-by-month-day` | Monthly days `1...31` or `-31...-1`, counted from the end. |
| `--recurrence-by-month` | Months `1...12` for yearly rules. |
| `--recurrence-by-week-no` | Yearly weeks `1...53` or `-53...-1`. Cannot combine with numbered weekdays. |
| `--recurrence-by-year-day` | Yearly days `1...366` or `-366...-1`. |
| `--recurrence-by-set-pos` | Select positions within another condition's matches; `-1` selects the last. Values range from `-366...-1` or `1...366`. |

List values use commas. Zero is invalid for numeric selectors. Monthly weekday
ordinals range from `-5...-1` or `1...5`; yearly ordinals range from `-53...-1` or
`1...53`. Supply `--recurrence-frequency` with any recurrence options. A count
and an end date cannot be combined. Updating recurrence replaces the existing
rules; omitting recurrence options preserves them.

Event summaries and details include all observed `recurrenceRules`, with the
first also available as `recurrence`. Rules include custom conditions, their
calendar identifier and first weekday (`1` is Sunday, `7` is Saturday, and `0`
means unspecified).

`events export` currently writes non-recurring events. A query containing a
repeating event or an individually changed occurrence returns unsupported
without creating a file. Complete series and exception export is still
unavailable.

All-day export preserves the event's local calendar dates and exclusive end;
it uses the current macOS time zone when the event has no explicit zone. Timed
events export UTC instants. Event reads include the observed time-zone
identifier when available; full original-zone and floating-time export remain
unavailable.

The detailed capability boundary lives in
`../../Architecture/Calendar/CapabilityList.md`.
