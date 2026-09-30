# Reminders Capability List

## Scope / Purpose

This target-owned capability list records the accepted `apple reminders`
command set, implementation mechanism, verifier, and gate for Reminders.app
data-management workflows. Current Reminders architecture truth lives in
`Architecture.md`; ordinary usage lives in
`../../Reference/Reminders/UserGuide.md`.

The target design goal is semantic CLI coverage for accepted Reminders.app
reminder, list, organization, trigger, and rich-metadata workflows.
ReminderKit is the production implementation mechanism for accepted reads and
writes. The read-only `SQLiteReader` supports semantic read enrichment, doctor
diagnostics, and post-mutation verification.

## Official Source Hierarchy

Use this hierarchy when deciding whether a Reminders capability belongs in the
accepted CLI promise:

1. Apple Reminders User Guide for Mac is the user-facing product source for
   capability candidates. Current reference pages include:
   - <https://support.apple.com/guide/reminders/welcome/mac>
   - <https://support.apple.com/guide/reminders/add-or-change-reminders-remndc729e28/mac>
   - <https://support.apple.com/guide/reminders/tag-reminders-remn45640f4f/mac>
   - <https://support.apple.com/guide/reminders/manage-sections-in-reminder-lists-remn14bf0e77/mac>
   - <https://support.apple.com/guide/reminders/use-reminder-list-templates-remn29caf6e1/mac>
   - <https://support.apple.com/guide/reminders/create-custom-smart-lists-remnfec66479/mac>
2. Installed Reminders.app behavior on the target macOS version resolves
   account, locale, and feature availability.
3. The accepted `apple reminders` command contract defines the CLI promise.
4. `ReminderKit` / `ReminderKitInternal` imports provide implementation
   evidence for accepted commands.
5. Read-only Reminders SQLite evidence provides verifier and doctor evidence for
   persisted Reminders.app state.

EventKit and the Reminders.app SDEF can clarify Apple model boundaries. The
accepted production implementation mechanism is ReminderKit.

## Current Capability Matrix

| Capability | CLI support | Command | Implementation mechanism | Verifier | Gate | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Reminder title, notes, due date, priority, completion, and list membership | supported | `create`; `update`; `complete`; `complete --completed-at`; `uncomplete`; `delete`; `cleanup-completed`; `list`; `search`; `read` | ReminderKit reminder/list change items | ReminderKit readback plus optional read-only SQLite diagnostics | `DryRun` payload for mutations / bounded-read for reads | Core reminder identity and list identity come from ReminderKit. `--completed-at` preserves explicit historical completion timestamps. |
| Recurrence, location, early reminder, and absolute alarm triggers | supported | `create/update --repeat`; `--location`; `--early-reminder-minutes-before`; `--alarm-at` and clear variants | ReminderKit recurrence and alarm contexts | ReminderKit readback and read-only SQLite recurrence evidence where needed | `DryRun` payload / read-only verified | Covers hourly, daily, weekly, monthly, yearly, weekday positions, selected month days/months, and BYSETPOS-style set positions. |
| Standard lists and list appearance | supported | `lists list`; `lists icons list`; `lists create`; `lists delete`; `lists update --title/--color/--icon` | ReminderKit list/account change items plus target-local native badge token catalog | ReminderKit readback, read-only list evidence, color hex readback, and badge-token catalog tests | `DryRun` payload / bounded-read | Color input accepts names or hex values and normal reads emit `color` as hex plus `hasColor`; icon input is semantic and validated against the native badge token catalog before write. |
| Visible URL/link-card and file/image attachments | supported | `create --url`; `update --url`; `--clear-url`; `attachments add/remove` | ReminderKit attachment/link context | Read-only SQLite attachment/link evidence | `DryRun` payload / read-only verified | Normal reads expose visible link and attachment metadata when verifier evidence maps to reminder identity. |
| Tags | supported | `tags list`; `update --tags`; `--add-tags`; `--remove-tags`; `--clear-tags`; `tags rename/delete` | ReminderKit hashtag context plus read-only affected-reminder discovery | Read-only tag relation evidence | bounded-read / `DryRun` payload / read-only verified | Rename/delete applies to reminders with explicit tag membership evidence. |
| Sections and item section membership | supported | `sections list`; `sections create/rename/delete/reorder`; `update --section` | ReminderKit list-section context | Read-only section and ordering evidence | bounded-read / `DryRun` payload / read-only verified | Section order verification reads ordered identifiers from Reminders SQLite evidence. |
| Subtasks | supported | `subtasks create/move/promote`; normal reads expose hierarchy when evidence exists | ReminderKit reminder/subtask context | Read-only parent/child evidence | `DryRun` payload / read-only verified | Same-list and cross-list reparenting verify final parent evidence after save. |
| Shopping list type and automatic grocery metadata | supported | `lists update --type standard|shopping`; list reads and doctor list/SQLite evidence | ReminderKit list grocery context | Read-only list type and grocery evidence | `DryRun` payload / read-only verified | Account and locale availability resolve on the local Reminders.app account. |
| List type, pin, sort, order, and groups | supported | `lists update --pinned/--sort/--show-large-attachments`; `lists reorder`; `lists groups create/rename/delete/move-list/remove-list` | ReminderKit list/account/appearance/group contexts | Read-only list metadata and group parent/child evidence | bounded-read / `DryRun` payload / read-only verified | Covers pinned lists, sorting style, large attachment display, sidebar order, and list groups. |
| List templates | supported | `templates list`; `templates save`; `templates create-list`; `templates update`; `templates replace`; `templates sections list/add/rename/delete/reorder`; `templates items add/update/delete`; `templates items attachments add/remove`; `templates items subtasks create/move/promote`; `templates delete` | ReminderKit template/account save requests, template section contexts, template list representation, saved reminder change items, attachment context, and subtask context | ReminderKit template/list readback and generated-list smoke verification where needed | bounded-read / `DryRun` payload | Saves a source list as an official Reminders template, creates new lists from saved templates, edits template title/appearance, replaces template content from a list, directly edits template sections, directly edits saved template items by `REMCDSavedReminder` ID, edits template item attachments and one-level subtasks, and deletes templates. Template items support instantiable content and structure: title, notes, visible URL, due date, priority, repeat, location, absolute alarm, flag, tags, section membership, file/image attachments, and one-level subtasks. Current-user or execution-context fields such as urgent, early reminders, Messaging person, and shared assignment remain normal reminder fields. |
| Smart Lists | supported for bounded criteria | `lists smart create/update/delete/convert` | ReminderKit Smart List, list, and reminder change items | Read-only Smart List type and filter evidence | `DryRun` payload / read-only verified | Supported criteria include bounded tag, priority, flag, date, and boolean selectors. |
| Shared assignment | supported when sharee evidence is resolvable | `assignments assign/unassign`; normal reads expose assignment evidence | ReminderKit assignment context plus read-only sharee resolver | Read-only assignment/sharee evidence | `DryRun` payload / read-only verified | Assignment validation uses shared-list sharee evidence for the selected account. |
| Flagged, urgent, and Messaging-person reminders | supported | `update --flagged`; `update --urgent`; `update --messaging-person`; clear variants | ReminderKit reminder, urgent alarm, and contact-handle contexts | Read-only SQLite evidence | `DryRun` payload / read-only verified | Messaging-person display-name selectors require exactly one Contacts match. |

## Evidence Snapshot

| Evidence | Role | Notes |
| --- | --- | --- |
| Apple Reminders User Guide and installed Reminders.app | Product capability baseline | Establishes user-visible candidate workflows and local feature availability. |
| ReminderKit module import boundary | Build-facing import boundary | Broad full-dump-derived headers compile as Swift imports for `ReminderKit` and `ReminderKitInternal`. |
| ReminderKit behavior | Production implementation mechanism | Covers accepted reminder/list reads, standard mutations, rich metadata, list metadata, list groups, Smart Lists, and trigger metadata. |
| Read-only Reminders `SQLiteReader` | Enrichment, doctor explanation, and post-mutation verification | Provides bounded evidence for fields persisted outside the normal ReminderKit model projection. |

## Implementation Selection Rules

- Use ReminderKit for accepted Reminders reads and writes.
- Keep the full-dump-derived ReminderKit module import boundary as the compile contract.
- Keep normal commands semantic and user-facing; implementation details stay in
  target-local code and architecture docs.
- Use read-only SQLite inspection to enrich normal reads, support doctor output,
  and verify post-write state.

## Command Families

| Family | Domain CLI | Implementation mechanism | Gate default | Accounting note |
| --- | --- | --- | --- | --- |
| List reads | `lists list`; `lists groups list`; `doctor store --scope lists`; `doctor list` | ReminderKit + read-only SQLite enrichment | `bounded-read` | ReminderKit reads emit list/template color as stable hex when present; SQLite enrichment can add list type, Smart List type, pin/order/sort metadata, color-presence evidence, grocery diagnostics, Smart List filter-data length, and sidebar group evidence. |
| List lifecycle | `lists create`; `lists delete` | ReminderKit list/account save requests | `DryRun` payload | Create and delete bind source/list identity and verify readback. |
| List appearance metadata | `lists icons list`; `lists update --title`; `--color`; `--icon` | ReminderKit list change items plus native badge catalog | `bounded-read` / `DryRun` payload | The CLI accepts color names or hex values, reads colors back as hex, enumerates and validates native Reminders badge tokens for `--icon`, then writes ReminderKit list metadata. |
| List type, pin, sort, order, and groups | `lists update --type`; `--pinned`; `--sort`; `--show-large-attachments`; `lists reorder`; `lists groups create/rename/delete/move-list/remove-list` | ReminderKit list/account/appearance/group contexts | `DryRun` payload / `read-only verified` | Covers grocery/list type, pin, sort, large attachment display, list order, and group hierarchy. |
| List templates | `templates list`; `templates save`; `templates create-list`; `templates update`; `templates replace`; `templates sections list/add/rename/delete/reorder`; `templates items add/update/delete`; `templates items attachments add/remove`; `templates items subtasks create/move/promote`; `templates delete` | ReminderKit template/account contexts, template section contexts, template list representation, saved reminder change items, attachment context, and subtask context | `bounded-read` / `DryRun` payload / `ReminderKit readback` | Template save binds the source list and template title. Template create-list binds the saved template and destination list title. Template replace binds the old template, replacement source list, and final title. Template sections and items mutate saved template internals directly without requiring a source draft list. Template item generated-list smoke covers visible URL, due date, repeat, location, absolute alarm, priority, flag, tags, section membership, file/image attachments, and one-level subtasks. |
| Smart Lists | `lists smart create/update/delete/convert`; Smart List reads | ReminderKit custom Smart List, list, and reminder change items plus read-only verifier | `bounded-read` / `DryRun` payload / `read-only verified` | Reads may expose `listType=smart`, `smartListType`, and bounded filter evidence. |
| Reminder core fields | `create`; `update --title`; `--notes`; `--due`; `--priority`; `complete`; `complete --completed-at`; `uncomplete`; `delete`; `cleanup-completed` | ReminderKit reminder/list save requests | `DryRun` payload for mutations / `bounded-read` | SQLite diagnostics expose bounded row evidence for explanation and preservation checks, including completion timestamps. |
| Repeat, location, early reminders, alarms | `create/update --repeat`; `--repeat-days-of-week`; `--repeat-weekday-positions`; `--repeat-days-of-month`; `--repeat-months-of-year`; `--repeat-set-positions`; `--location`; `--early-reminder-minutes-before`; `--alarm-at`; clear variants | ReminderKit recurrence, structured location, due-date delta, and alarm contexts | `DryRun` payload / `read-only verified` | ReminderKit covers hourly recurrence, daily/weekly/monthly/yearly rules, weekday week-number positions, selected month days/months, BYSETPOS-style set positions, geofence alarms, relative early reminders, and explicit alarms. |
| Visible URL / link card | `create --url`; `update --url`; `--clear-url`; normal read `url` | ReminderKit attachment/link context + read-only verifier | `DryRun` payload / `read-only verified` | Production write/clear reports success after read-only SQLite verification. |
| Flagged | `update --flagged true|false`; normal read `isFlagged` | ReminderKit reminder change items + read-only verifier | `DryRun` payload | Read enrichment and verification use SQLite flag evidence where available. |
| Tags | `tags list`; normal read `tags`; `update --tags`; `--add-tags`; `--remove-tags`; `--clear-tags`; `tags rename`; `tags delete` | ReminderKit hashtag context and read-only affected-reminder discovery | `bounded-read` / `DryRun` payload / `read-only verified` | Tag rename/delete migrates or removes explicit tag membership on affected reminders. |
| Sections | `sections list`; `sections create/rename/delete/reorder`; `update --section` | ReminderKit list-section context | `bounded-read` / `DryRun` payload / `read-only verified` | Section order verification reads ordered identifiers from Reminders SQLite evidence. |
| Subtasks | normal read parent/child fields; `subtasks create/move/promote` | ReminderKit reminder/subtask context | `bounded-read` / `DryRun` payload / `read-only verified` | Parent evidence is verified after save. |
| Shared assignment | normal read `assignments`; `assignments assign/unassign`; `doctor store --scope assignments`; `doctor item` | ReminderKit assignment context and read-only sharee resolver | `bounded-read` / `DryRun` payload / `read-only verified` | Assign/unassign resolves assignee/current-user originator from read-only shared-list sharee evidence. |
| Attachments | normal read `attachments`; `attachments add/remove`; `doctor store --scope attachments`; `doctor item` | ReminderKit attachment context | `bounded-read` / `DryRun` payload / `read-only verified` | Add/remove commands bind file content or current attachment evidence. |
| Urgent reminders | `update --urgent true|false`; normal read `isUrgent`; `doctor item` SQLite evidence | ReminderKit urgent alarm context plus read-only SQLite verifier | `DryRun` payload / `read-only verified` | Verifies urgent-state evidence when the local schema exposes it. |
| Messaging-person reminders | `update --messaging-person`; `update --clear-messaging-person`; normal read `messagingContactHandles`; `doctor item` SQLite evidence | ReminderKit contact-handle mutation plus read-only SQLite verifier | `DryRun` payload / `read-only verified` | Accepts email/phone handles and exact Contacts display-name matches. |

## Validation And Proof Expectations

- Default package tests cover command parsing, `DryRun` payload shape,
  ReminderKit implementation dispatch, read enrichment, and supported error
  behavior.
- ReminderKit mutations use fixed semantic write paths, method
  availability checks, save-path verification, and post-write
  ReminderKit/read-only SQLite verification.
- SQLite diagnostics may expose implementation evidence in doctor output; normal
  commands stay semantic and user-facing.
