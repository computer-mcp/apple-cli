# Reminders Architecture

## Positioning

`reminders` is the canonical Reminders target under the `apple` CLI product:

```text
apple reminders <resource?> <action> [options]
```

The target covers the accepted Reminders.app data-management scope: reminder
and list content, organization metadata, notification triggers, rich item
metadata, and shared-list metadata. Command names describe user intent in
Reminders terms, and normal usage stays independent from implementation details.

## Capability Maturity

Current level: `L1.5 Private Framework Implemented`

Rationale: ReminderKit and ReminderKitInternal broadly implement accepted
Reminders reads and writes. Read-only Reminders store inspection remains
evidence for enrichment, diagnostics, and verification rather than a write
mechanism.

## Capability Authority

The Reminders capability baseline is defined in this order:

1. Apple Reminders User Guide pages define user-visible capability candidates.
2. Installed Reminders.app behavior on the target macOS version resolves local
   account, locale, and feature availability.
3. The accepted `apple reminders` command contract defines the CLI promise.
4. `ReminderKit` / `ReminderKitInternal` imports provide the production
   implementation mechanism for accepted reads and writes.
5. The read-only Reminders `SQLiteReader` provides enrichment, diagnostics, and
   verifier evidence.

Reminder and list existence and identity come from ReminderKit. SQLite
enrichment matches native identifiers and fills missing metadata; retained
store rows belong to diagnostics.
Saved template item listing uses a bounded read-only index to discover IDs
under the selected native template and account. Every returned item is fetched
through ReminderKit and checked for saved-item entity, template, and account
membership. An unavailable or ambiguous index fails the read.

Custom Smart List storage supplies the list identity, account identity, type,
and filter data. Creation and conversion retain the new change item's ID.
Rule verification reloads that exact native identity and compares its account
and requested JSON rules. Rule updates preserve the list's other fields and
return without saving when the rules already match. Deletion verifies native
absence. Unconfirmed post-save verification reports possible mutation and
inspection guidance.

Smart List membership reads use ReminderKit's custom Smart List data-view
invocation with the selected native Smart List and account storages. The
native view evaluates its saved rules; the CLI decodes its property-list
result, checks the requested list identity, and fetches the full reminder
objects by their native IDs. Contextual subtasks are flattened and deduplicated
by identity. Output retains physical list and parent relationships. Completion,
date, and search filters run before the output limit. Unavailable invocation
methods or unknown result shapes fail the read.

EventKit and the Reminders.app SDEF remain useful reference evidence for Apple
model boundaries. Production Reminders reads and writes use ReminderKit.

A capability enters the CLI promise after it has a semantic command shape,
safety policy, ReminderKit write/read path, and verifier rule. Durable
capability accounting lives in `CapabilityList.md`.

## Ownership

- `Sources/RemindersCLI/Commands/` owns the typed
  `swift-argument-parser` command tree, dispatch, top-level validation,
  identity binding, `DryRun` payloads, result envelopes, and
  destructive-selection gating. Files are split into root target wiring,
  command tree definitions, option mapping, identity binding, selection, and
  result rendering.
- `Sources/RemindersCLI/ReminderKit/` owns production Reminders reads and
  writes through `ReminderKit` / `ReminderKitInternal` calls. Files are split
  by product capability: reminder core, list metadata, list groups, Smart
  Lists, repeat rules, visible URL, tags, sections, subtasks, attachments,
  assignments, rich notes, urgent state, Messaging-person triggers, field verification, and
  preservation verification. Smart List writing keeps operation entry points,
  change-item configuration, resolution, conversion, store/save helpers,
  matching, preflight checks, and criteria encoding in separate target-local
  files.
- `Sources/RemindersCLI/SQLiteReader/` owns read-only Reminders SQLite
  discovery, bounded SQLite queries, normal read enrichment, doctor diagnostics,
  shared assignment sharee resolution, and post-write verifier evidence. Files
  are split by discovery, SQLite support, reminder/list/section/tag queries,
  section/subtask/list/rich-metadata state, enrichment, debug views, and
  assignment resolution.
- `Sources/RemindersCLI/Models/` owns typed target models returned by CLI
  commands and used by `DryRun` payloads. Files are split by core reminder
  records, list records, rich metadata records, and read-only SQLite diagnostics.
- `Sources/RemindersCLI/Support/` owns target-local identity structs,
  validation, scope digests, parsing, and human output helpers. Parsing is
  split by common options, list metadata, rich metadata, triggers, and repeat
  rules.

## Implementation Model

The Reminders target has one command owner: `RemindersCommand`. Production reads
and writes call `ReminderKit` / `ReminderKitInternal` from `RemindersCommand`
extensions. Helper names describe concrete behavior, such as
`coreResolveList`, `coreSaveReminderKit`, and `verifyAttachmentPresent`.

| Component | Role | Boundary |
| --- | --- | --- |
| ReminderKit implementation | Production implementation for accepted Reminders data-model commands. | Uses `REMStore`, `REMSaveRequest`, change items, data views, contexts, and object IDs. |
| Read-only Reminders `SQLiteReader` | Enrichment, doctor diagnostics, and post-write verification. | Reads bounded local evidence for fields that Reminders.app persists outside the regular model shape. |
| Apple Reminders User Guide / installed app | Product capability baseline. | Defines user-visible candidates before they become accepted CLI commands. |

All writes flow through ReminderKit save requests. SQLite reading stays
read-only and supports verifier evidence for CloudKit-owned, account-owned, and
Reminders.app-owned state.

## ReminderKit Import Boundary

ReminderKit framework access is built from SwiftPM Clang module targets:
`ReminderKit` and `ReminderKitInternal`. The target import boundary is
full-dump-derived: generated from framework declarations and normalized where
required for Swift/Clang import.

The headers under `Sources/ReminderKit/include` and
`Sources/ReminderKitInternal/include` are broad implementation headers for this
target. Keep the user-facing Reminders command model semantic even as the header
generation process improves.

## Command Semantics

Command names remain semantic:

- Use `apple reminders create`, `update`, `complete`, `uncomplete`, bulk
  completion, `delete`, and `cleanup-completed` for reminder mutation.
- Use `apple reminders list`, `search`, and `read` for normal reminder reads.
- Use `apple reminders notes read`, `notes format`, and `notes list-style`
  for attributed notes and selective formatting changes.
- Use `apple reminders lists list`, `lists create`, `lists delete`,
  `lists update`, `lists reorder`, `lists groups ...`, and `lists smart ...` for
  list organization intent.
- Use `apple reminders templates list`, `templates save`,
  `templates create-list`, `templates update`, `templates replace`,
  `templates sections ...`, `templates items ...`,
  `templates items attachments ...`, `templates items subtasks ...`, and
  `templates delete` for official Reminders list-template intent.
  `templates` is the collection entry, matching Reminders.app's View Templates
  flow; `--template` selects the one template to mutate in the stateless CLI.
  Template sections support direct list/add/rename/delete/reorder. Template
  items support direct list/read/add/update/delete on saved reminders, including title,
  notes, visible URL, due date, priority, repeat, location, absolute alarm,
  flag, tags, section membership, file/image attachments, and one-level
  subtasks. Current-user or execution-context fields such as urgent, early
  reminders, Messaging person, and shared assignment are normal reminder fields,
  not template item fields.
- Use `apple reminders create/update --url`, and `apple reminders update --flagged`, `--urgent`,
  `--messaging-person`, `--tags`, and `--section` for item metadata intent.
- Use `apple reminders tags ...`, `sections ...`, `subtasks ...`,
  `attachments ...`, and `assignments ...` for rich Reminders metadata intent.
- Use `apple reminders doctor`, `doctor store`, `doctor item`, and `doctor list`
  for ReminderKit readiness, read-only state explanation, and verifier diagnostics.

## Preservation Invariant

Notes formatting reads native attributed text and selects literal text in
UTF-16 ranges. Repeated text requires an explicit one-based occurrence;
omitting text selects all notes. Inline changes preserve other attributes and
unselected content. List styles apply to complete selected paragraphs:
bulleted, dashed, and numbered styles preserve existing paragraph metadata,
while plain clears the selected paragraph's list layout. Changes save once
through the native reminder change item and require a fresh attributed-text
readback plus unchanged reminder fields, except the modification timestamp.
An identical request does not save. Unconfirmed saves report possible mutation
and require inspecting notes before retrying.

Subtask verification binds the child, parent, and list by identity. A successful
fresh ReminderKit lookup and readable store relationship evidence are required;
parent titles do not identify the relationship. Moving to the current parent
preserves the reminder and reports `changed: false`.

Promotion adds the existing reminder change item to its original list's
top-level membership in the same save request. Saved template items use their
template's list representation for this membership change. Verification
requires that the child still exists in its list or template and has no parent
relationship.

Commands that move, recreate, merge, extract, or reorganize reminders preserve
known rich reminder state. This includes visible URLs, assignments, attachments,
tags, sections, subtask relationships, recurrence, alarms, and list metadata.

The command reads the reminder/list through ReminderKit, captures
read-only SQLite evidence for related objects, performs the ReminderKit
save request, then verifies ReminderKit readback and read-only SQLite evidence
where that field requires it. Commands that intentionally change or clear a
field verify the requested final state.

## Doctor Diagnostics

`doctor` checks ReminderKit module/framework readiness, method availability,
and read access for accounts, lists, reminders, Smart Lists, and sections.

`doctor store` inspects store-file presence, schema, link-object summaries,
attachment object summaries, assignment object summaries, section rows, tag
rows, list metadata, Smart List evidence, and list group evidence using bounded
read-only access.

`doctor item --id <reminder-id>` and `doctor list --list <list-id-or-title>`
resolve identity through ReminderKit, then inspect matching read-only
store facts for explanation and verification.

## Evidence Sources

Product capability evidence comes from Apple Reminders user-visible behavior and
local Reminders.app observations. Implementation evidence comes from ReminderKit
behavior and read-only Reminders store verification.

## Validation

Reminders changes use package-local Swift checks:

```bash
swift build
swift test --filter reminders
```

ReminderKit behavior is validated with bounded Swift Testing using demo data,
temporary files, ReminderKit probes where isolated stores are available,
and read-only doctor/SQLite evidence. Operational validation instructions live in
`../../Reference/Reminders/DeveloperGuide.md`.

New Reminders variants become supported after the semantic command,
ReminderKit behavior, safety policy, and verifier evidence are all in place.
