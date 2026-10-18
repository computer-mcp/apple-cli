# Calendar Developer Guide

Use package-local tests for Calendar changes:

```bash
swift test --filter EventKit
```

Run `apple calendar doctor --json` when diagnosing EventKit authorization or
local calendar availability.

`Package.swift` embeds `Sources/AppleCLI/Info.plist` into the `apple` executable's
`__TEXT,__info_plist` section. It provides both the full-access Calendar purpose
description and the legacy description used on macOS 13. The executable tests
check that `calendar doctor` can read these descriptions from the running
product; the same suite runs against installed and unpacked release binaries.

The EventKit command suite retains its command coverage and checks invalid
date-only inputs, UTF-8 iCalendar line folding and exact unfolding, and rejection
of write-only access when mutation identity requires reads.

`CalendarCollections.swift` owns EventKit source/calendar collection reads and
mutations. It keeps every saved calendar and its source in one store, then uses
a fresh store to verify persistence. Source IDs are required at creation;
update/delete compare the resolved calendar record with the command's selected
record. `isImmutable` governs calendar attributes and deletion independently of
`allowsContentModifications`, which governs event content. Missing source or
attribute-permission evidence prevents collection mutations.

Collection command arguments use typed required IDs/source/title declarations.
The MCP catalog derives those requirements from the same CLI help. Tests reuse
the EventKit command suite for source identity/filtering/truncation, collection
lifecycle/no-op behavior, and the distinction between attribute and event
permissions. Provider persistence and recurrence behavior need controlled native
validation in addition to these command tests.

`Recurrence.swift` owns recurrence parsing, frequency/selector validation,
native construction, projection and rule text. It uses the full
`EKRecurrenceRule` initializer and compares requested conditions with native
getters. EventKit may ignore incompatible selectors or raise Objective-C
exceptions for invalid weekday ordinals, so validation precedes construction.
Monthly weekday ordinals are limited to five; weekly rules require unnumbered
weekdays. Yearly numbered weekdays cannot be combined with week-number filters.

The original EventKit suite checks weekly, monthly and yearly rule objects
directly, including native reconstruction, and rejects invalid conditions. Its
existing create/export tests cover custom CLI arguments and refusal to produce a
recurring artifact from expanded rows. These checks do not prove provider saves
or complete recurring-series export. Native saving, occurrence selection,
exceptions and time-zone fidelity require their own controlled evidence.

All-day serializer tests use explicit time zones, including a two-day Los
Angeles interval spanning daylight-saving time that lasts 47 hours. The output
must retain both local dates and the exclusive end. These are serializer
regressions, separate from Calendar app persistence evidence.
