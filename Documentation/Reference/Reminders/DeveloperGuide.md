# Reminders Developer Guide

## Scope / Purpose

This guide is for maintaining and validating the `apple reminders` target. It
covers package checks, doctor commands, and fixture-backed Swift Testing validation.
Ordinary usage lives in `UserGuide.md`.

## Framework Header Generation

`Scripts/reminderkit-normalize-full-dump` generates the official `ReminderKit`
and `ReminderKitInternal` module surfaces from one dump or a digest-checked
versioned input manifest. It shares declaration merging and complete output
publication with the Notes generation command. See [Framework Header Generation](../FrameworkGeneration.md)
for conflicts, import checks, observed availability, and recovery. Runtime
requirements and ReminderKit save behavior remain owned by this target.

## Runtime Entry Requirements

All default store factories, save-request factories, and synchronous saves
use target-owned entry points. They check method scope, return type, and
argument encodings before typed dispatch. Save-request creation checks save
availability before the request can be modified, and saving checks the actual
receiver again. Core account and default-list/account reads also check their
consumed signatures. Existing feature-specific validation and error handling
continue to own their operation behavior.

Explicit host read validation is available separately:

```bash
APPLE_CLI_RUN_REMINDERKIT_READONLY_TESTS=1 swift test --filter ReminderKitReadonlyTests
```

It requires configured accounts and an existing list. It initializes a real
store, reads accounts/lists, and inspects save signatures without creating a
save request or committing changes. These reads and metadata checks establish
entry-point evidence; mutation preservation and older OS compatibility need
separate validation. Runtime requirements apply after framework loading; see
the [Release Guide](../ReleaseGuide.md) for startup dependencies.

## Default Validation

The opt-in `remindersCompletionHistoryAndColdReadback` workflow creates a
marked reminder in a configured, dedicated test list and checks historical
completion, retry preservation, cold reads, and exact-ID cleanup. See
[Native Fixture Validation](../NativeFixtureValidation.md) for the manifest,
mutation switch, evidence, and recovery procedure. Its default skip provides
no native write evidence.

Run package-local checks for Reminders changes:

```bash
swift build
swift test --filter reminders
```

## Doctor Checks

Use these commands to validate local readiness and verifier evidence:

```bash
apple reminders doctor --json
apple reminders doctor store --scope summary --json
```

`doctor` checks ReminderKit module/framework readiness, method
availability, and read-access access for accounts, lists, reminders, Smart
Lists, and sections. `doctor store`, `doctor item`, and `doctor list` expose
bounded verifier evidence through read-only SQLite access.

`templates items list` discovers saved item IDs in the read-only local index,
bound to the exact template and account, then fetches each item through
ReminderKit. It checks native entity and membership before producing output.
The index query excludes deleted rows and fails when unavailable or ambiguous.
`templates items read` uses the native saved-item fetch directly; ID parsing
keeps ordinary reminder and saved-item entities distinct. These boundaries are
covered in the existing `RemindersCommandTests` suite.

Custom Smart List reads use `REMSmartList.storage` for identity, account,
metadata, and filter data. Runtime signature checks run on the actual storage
receiver. SQLite list enrichment supplies missing metadata only after an exact
native identifier match. Rule readback compares the freshly fetched native
identity, account, custom type, and complete JSON filter. Update allocates no
save request when the filter already matches and changes only the requested
rules. These boundaries are covered in `RemindersCommandTests` with a temporary
SQLite store and mismatched native readback values; persistence checks use
owned native fixtures.

Smart membership reads belong to `ReminderSmartListQuery`. The fixed
`REMRemindersListDataView_CustomSmartListInvocation` constructor is resolved by
runtime name and checked before dispatch, avoiding a strong reference to that
query class. Store invocation and result getters check their actual receiver
signatures. Parameters use binary property lists with the Smart List UUID,
native enum encodings, completion visibility, and subtask fetching. Storages
are bound to the native Smart List, account, and parent group when referenced.
The result must identify the requested Smart List and provide a reminder model.
The decoder accepts contextual child/root duplication, preserves first-seen
identity, and rejects foreign entities, invalid UUIDs, cycles, unknown shapes,
and results beyond its byte or hierarchy bounds. Full reminder objects provide
the physical list and parent fields; common query filters and the output limit
apply afterward. The existing suite covers the decoder boundaries, while owned
native fixtures establish actual membership and field preservation.

## Fixture-Backed Swift Testing Validation

Rich notes behavior belongs to `RemindersCommand+Notes`, with range selection,
native attribute edits, and semantic projection in `ReminderNotesFormatting`.
Consumed native selectors are checked against actual receiver signatures.
List-style changes copy paragraph styles before editing; plain uses the native
paragraph-style removal operation. Post-save validation compares the complete
attributed text and reminder fields, allowing only the modification timestamp
to differ. Identical attributed text returns without saving. An unconfirmed
readback reports possible mutation and inspection guidance.

The existing `RemindersCommandTests` suite covers these production helpers
with in-memory native attributes, literal Unicode selection, untouched ranges,
links, paragraph metadata, and no-op requests. Persistence and cold reads use
dedicated native fixtures as described in [Native Fixture Validation](../NativeFixtureValidation.md).

Reminders validation belongs in Swift Testing. Default tests use fixture-backed
data, temporary files, and ReminderKit implementation guardrails to cover command
parsing, JSON envelopes, `DryRun` payloads, safety gates, ReminderKit
semantics, and read-only `SQLiteReader` evidence.

When adding behavior, add or update tests under `Tests/AppleCLITests/`. Prepare
demo data through test fixtures, in-memory fakes, or temporary files so default
validation stays isolated from the user's Reminders data.

The behavior families that must remain covered by Swift Testing include:

- ReminderKit list title, color, and icon updates, with `--icon` validated
  against the target-local native Reminders badge token catalog exposed by
  `lists icons list`
- ReminderKit reminder flag set and clear
- attributed notes reads, inline formats, and paragraph list styles
- hourly repeat set and clear
- visible URL create/set and clear
- item tag set, add/remove, clear, tag rename, and tag delete
- section create, rename, delete, reorder, and item section assignment
- file attachment add and remove
- subtask create, move, and promote
- urgent state set and clear
- list type, pin, sort, and sidebar order
- list group create, rename, delete, move-list, and remove-list
- list template list, save, create-list, update, replace, section add/rename/delete/reorder,
  item add/update/delete, item attachment add/remove, item subtask create/move/promote,
  and generated-list verification for template item
  visible URL, due date, repeat, location, absolute alarm, priority, flag,
  tags, section membership, file/image attachments, and one-level subtasks
- Smart List create, update, delete, and standard-list convert
- When Messaging and shared assignment behavior using modeled selector evidence

Manual local readiness checks:

```bash
apple reminders doctor --json
apple reminders doctor store --scope summary --json
```

The `doctor store` path uses read-only SQLite verification over local
Reminders evidence.

## Failure Triage

- If fixture-backed Swift Testing fails, update the fixture or implementation
  expectation in the owning test.
- If ReminderKit readiness fails, check framework availability and the current
  local macOS environment before treating the command as a data issue.
- If read-only verifier evidence is missing after a fixture-backed mutation
  test, adjust the ReminderKit implementation or verifier expectation in
  the owning test.
