# Reminders User Guide

## Scope

This guide covers ordinary use of the canonical `apple reminders` target.
Architecture and implementation boundaries live in
`../../Architecture/Reminders/Architecture.md`; official capability accounting
lives in `../../Architecture/Reminders/CapabilityList.md`; validation harness
details live in `DeveloperGuide.md`.

Start with help:

```bash
apple reminders --help
apple reminders lists --help
apple reminders update --help
```

Use `--json` for scripts, agents, and automation. Use `--dry-run` to preview a
mutation before side effects.

## Read Lists And Reminders

`apple reminders lists list --json` returns normal list identity from ReminderKit
and includes `listType`, `smartListType`, `isPinned`, `displayOrder`,
`sortingStyle`, `showingLargeAttachments`, `color`, and `hasColor` when
ReminderKit and read-only SQLite evidence can verify them. `color` is emitted
as a stable hex value such as `#0A84FF`. Recognized `listType` values are
`standard`, `shopping`, and `smart`.

```bash
apple reminders lists list --json
apple reminders list --json
apple reminders search --query Follow --json
apple reminders read --id REMINDER_ID --json
```

Reminder `list`, `search`, and `read` output includes `createdAt` and
`modifiedAt` when ReminderKit returns them. It may also include `tags`,
`isFlagged`, visible link-card `url`, `sectionId`, `sectionTitle`,
`parentReminderId`, `parentReminderTitle`, `subtaskCount`, `attachments`, and
`assignments` when read-only Reminders SQLite evidence can map those objects back
to ReminderKit reminder identity.

## Lists

Use `lists create` to create a standard Reminders list. Omit `--source` to use
the default Reminders source, or pass a source id/title when needed:

```bash
apple reminders lists create --title "Japan Shopping" --dry-run --json
apple reminders lists create --title "Japan Shopping" --source iCloud --dry-run --json
```

Use `lists delete` to delete a Reminders list. It supports `--dry-run`; execution is scoped to the list
identity plus a bounded current reminder snapshot:

```bash
apple reminders lists delete --list LIST_ID_OR_TITLE --dry-run --json
```

`lists update` is the semantic list metadata mutation command. `--title`,
`--color`, and `--icon` update Reminders list appearance fields through
ReminderKit. `--color` accepts native color names or hex values such as
`#0A84FF`. Use `lists icons list` to choose a native Reminders badge token for
`--icon`. `--type standard|shopping`, `--pinned`, `--sort`, and
`--show-large-attachments` update Reminders-owned list metadata through the
target implementation and verify through read-only evidence:

```bash
apple reminders lists icons list --json
apple reminders lists update --list LIST_ID_OR_TITLE --type shopping --dry-run --json
apple reminders lists update --list LIST_ID_OR_TITLE --pinned true --sort due-date --dry-run --json
apple reminders lists update --list LIST_ID_OR_TITLE --show-large-attachments true --dry-run --json
apple reminders lists update --list LIST_ID_OR_TITLE --title "Japan Shopping" --dry-run --json
apple reminders lists update --list LIST_ID_OR_TITLE --color '#0A84FF' --icon shopping2 --dry-run --json
```

Use `lists reorder` for Reminders.app sidebar list-order intent:

```bash
apple reminders lists reorder --list LIST_ID_OR_TITLE --before OTHER_LIST_ID_OR_TITLE --dry-run --json
apple reminders lists reorder --list LIST_ID_OR_TITLE --after OTHER_LIST_ID_OR_TITLE --dry-run --json
```

Use `lists groups` for Reminders.app sidebar group hierarchy:

```bash
apple reminders lists groups list --json
apple reminders lists groups create --title "Trip" --dry-run --json
apple reminders lists groups rename --group GROUP_ID_OR_TITLE --title "Japan" --dry-run --json
apple reminders lists groups move-list --list LIST_ID_OR_TITLE --group GROUP_ID_OR_TITLE --dry-run --json
apple reminders lists groups remove-list --list LIST_ID_OR_TITLE --dry-run --json
apple reminders lists groups delete --group GROUP_ID_OR_TITLE --dry-run --json
```

## Templates

Use `templates` for official Reminders list templates. The command family maps
to Reminders.app's View Templates flow: `templates` is the collection entry, and
`--template` selects the one template to use or mutate:

```bash
apple reminders templates list --json
apple reminders templates save --list LIST_ID_OR_TITLE --title "Trip Checklist" --dry-run --json
apple reminders templates save --list LIST_ID_OR_TITLE --title "Trip Checklist" --include-completed --dry-run --json
apple reminders templates create-list --template "Trip Checklist" --title "Japan Trip" --dry-run --json
apple reminders templates update --template "Trip Checklist" --title "Travel Checklist" --dry-run --json
apple reminders templates replace --template "Trip Checklist" --list "Trip Checklist Draft" --dry-run --json
apple reminders templates sections list --template "Trip Checklist" --json
apple reminders templates sections add --template "Trip Checklist" --title "Documents" --dry-run --json
apple reminders templates sections rename --template "Trip Checklist" --section "Documents" --title "Entry Documents" --dry-run --json
apple reminders templates sections reorder --template "Trip Checklist" --section "Entry Documents" --before "Packing" --dry-run --json
apple reminders templates sections delete --template "Trip Checklist" --section "Entry Documents" --dry-run --json
apple reminders templates items list --template "Trip Checklist" --limit 20 --json
apple reminders templates items read --id TEMPLATE_ITEM_ID --json
apple reminders templates items add --template "Trip Checklist" --title "Passport" --notes "Check expiration date" --dry-run --json
apple reminders templates items add --template "Trip Checklist" --title "Flight check-in" --due 2026-07-01T09:00:00Z --alarm-at 2026-06-30T20:00:00Z --section "Travel Day" --dry-run --json
apple reminders templates items update --id TEMPLATE_ITEM_ID --title "Passport and visa" --dry-run --json
apple reminders templates items attachments add --id TEMPLATE_ITEM_ID --file /path/to/photo.png --dry-run --json
apple reminders templates items attachments remove --id TEMPLATE_ITEM_ID --attachment photo.png --dry-run --json
apple reminders templates items subtasks create --parent-id TEMPLATE_ITEM_ID --title "Copy passport" --dry-run --json
apple reminders templates items subtasks move --id TEMPLATE_CHILD_ITEM_ID --parent-id TEMPLATE_PARENT_ITEM_ID --dry-run --json
apple reminders templates items subtasks promote --id TEMPLATE_CHILD_ITEM_ID --dry-run --json
apple reminders templates items delete --id TEMPLATE_ITEM_ID --dry-run --json
apple reminders templates delete --template "Trip Checklist" --dry-run --json
```

`templates save` stores the selected Reminders list as a saved template.
`templates create-list` creates a new Reminders list from a saved template.
`templates update` edits template title and appearance fields. `templates
replace` replaces template content from a normal Reminders list. `templates
sections` edits saved template sections directly. `templates items list` reads
saved items, including subtasks, with a default limit
of 50. `items read` reads one saved item. The item IDs from `items list` and
`items add` can be used by `items read`, `items update`, `items attachments`,
`items subtasks`, and `items delete`. Template item add and
update support title, notes, visible URL, due date, priority, repeat, location,
absolute alarm, flag, tags, and section membership. Template item attachments
support file/image add and remove. Template item subtasks support one-level
parent-child structure. Urgent, early reminders, Messaging person, and shared
assignment are normal reminder fields; they are not template item fields. After
a saved template has been verified with `templates create-list`, the source
draft list can be deleted with `lists delete` when it is no longer needed. After
`templates replace`, use the returned template identity for later ID-based
commands.

## Smart Lists

Custom Smart List create/update supports bounded criteria such as
`flagged:true`, `priority:high`, `tags:travel`, `any-tag:true`, `date:today`,
and absolute date tokens. Convert is a separate conversion action over a
standard source list:

```bash
apple reminders lists smart create --title "Travel" --criteria tags:travel --dry-run --json
apple reminders lists smart update --list "Travel" --criteria priority:high --dry-run --json
apple reminders lists smart convert --list LIST_ID_OR_TITLE --dry-run --json
apple reminders lists smart delete --list LIST_ID_OR_TITLE --dry-run --json
```

Combine criteria with whitespace inside a quoted value and choose `--match all`
or `--match any`. Specify each filter once: use comma-separated tags or
priorities, and `date-range:YYYY-MM-DD..YYYY-MM-DD` for a date range.
Absolute dates must be valid `YYYY-MM-DD` calendar dates; a range's start must
be on or before its end. Flag and any-tag filters accept `true`.

Read or search a custom Smart List by native ID or unique title:

```bash
apple reminders list --list SMART_LIST_ID --status all --limit 50 --json
apple reminders search --list SMART_LIST_ID --query "Travel" --limit 20 --json
```

These commands use the saved rules in Reminders. Results keep each reminder's
physical `listId` and `parentReminderId`. A matching parent can bring contextual
subtasks that do not independently match the rules. Each reminder appears once,
even when it also matches on its own. Status, date, and search filters apply
before the limit. With no list selector, reads cover physical lists once.

`lists list` includes native Smart List IDs and account IDs. Creation and
updates check the saved rules against the request. Repeating the same rules
returns `changed: false`. If verification is unconfirmed, inspect the list
before retrying: the save may already have occurred.

## Reminder Fields And Triggers

Create/update supports notes, due dates, completion state, priority, recurrence,
location triggers, early reminders, absolute alarms, visible URL/link-card,
flagged state, urgent state, and When Messaging:

```bash
apple reminders create --list LIST_ID_OR_TITLE --title "Hydrate" --url https://example.com/context --due 2026-07-01T09:00:00Z --repeat hourly --repeat-interval 2 --dry-run --json
apple reminders update --id REMINDER_ID --url https://example.com/context --dry-run --json
apple reminders update --id REMINDER_ID --flagged true --dry-run --json
apple reminders update --id REMINDER_ID --urgent true --dry-run --json
apple reminders update --id REMINDER_ID --messaging-person "Alex" --dry-run --json
apple reminders update --id REMINDER_ID --clear-messaging-person --dry-run --json
```

Use `--repeat` with `hourly`, `daily`, `weekly`, `monthly`, or `yearly`, plus
optional interval, count, until, selected weekdays, selected weekday positions,
selected month days, selected months, or BYSETPOS-style set positions:

```bash
apple reminders create --list LIST_ID_OR_TITLE --title "Weekly review" --due 2026-07-01 --repeat weekly --repeat-days-of-week mon,wed --dry-run --json
apple reminders create --list LIST_ID_OR_TITLE --title "Second Monday" --due 2026-07-01 --repeat monthly --repeat-weekday-positions mon:2 --dry-run --json
apple reminders update --id REMINDER_ID --repeat monthly --repeat-days-of-week mon,tue,wed,thu,fri --repeat-set-positions -1 --dry-run --json
apple reminders update --id REMINDER_ID --clear-repeat --dry-run --json
```

Use explicit coordinates for location triggers:

```bash
apple reminders create --list LIST_ID_OR_TITLE --title "Pick up package" --location "Post Office" --location-latitude 37.332 --location-longitude -122.031 --location-proximity entering --dry-run --json
apple reminders update --id REMINDER_ID --clear-location --dry-run --json
```

Use `--alarm-at` for explicit absolute alarms and
`--early-reminder-minutes-before` for Reminders.app Early Reminder minute
offsets before a timed due date:

```bash
apple reminders create --list LIST_ID_OR_TITLE --title "Prepare report" --alarm-at 2026-07-01T09:00:00Z --dry-run --json
apple reminders update --id REMINDER_ID --early-reminder-minutes-before 10,30 --dry-run --json
apple reminders update --id REMINDER_ID --clear-alarms --clear-early-reminders --dry-run --json
```

## Notes Formatting

Read structured notes, including plain text, UTF-16 formatting ranges, links,
and recognized paragraph list styles:

```bash
apple reminders notes read --id REMINDER_ID --json
```

Set one inline format with `--format bold|italic|underline|strikethrough` and
`--state on|off`. `--text` selects literal text; repeated matches require a
one-based `--occurrence`. Omit `--text` to select all notes.

```bash
apple reminders notes format --id REMINDER_ID --text "Bring passport" --format bold --state on --dry-run --json
apple reminders notes format --id REMINDER_ID --text "Check" --occurrence 2 --format underline --state off --dry-run --json
apple reminders notes list-style --id REMINDER_ID --text "Packing" --style bulleted --dry-run --json
```

List styles are `plain`, `bulleted`, `dashed`, and `numbered`. They apply to the
whole paragraphs containing the selected text. Plain clears those paragraphs'
list layout. Inline formatting preserves other formatting and links; notes
formatting preserves the text and other reminder fields. Empty notes cannot be
formatted. Repeat requests that already match return `changed: false`.

Create/update `--notes` supplies a plain-text replacement. Use the formatting
commands when changing only appearance. Preview with `--dry-run`, then omit it
to apply the same request. If a save reports unconfirmed verification, inspect
notes before retrying.

## Tags, Sections, Subtasks, Attachments, And Assignments

Tag update intent is shaped as normal reminder update options. Tag rename/delete
discovers affected reminders through read-only evidence and migrates or removes
explicit tag membership:

```bash
apple reminders tags list --json
apple reminders update --id REMINDER_ID --tags travel,food --dry-run --json
apple reminders update --id REMINDER_ID --add-tags food --remove-tags snacks --dry-run --json
apple reminders update --id REMINDER_ID --clear-tags --dry-run --json
apple reminders tags rename --tag travel --title trip --dry-run --json
apple reminders tags delete --tag snacks --dry-run --json
```

Sections are a Reminders.app list organization concept:

```bash
apple reminders sections list --list LIST_ID_OR_TITLE --json
apple reminders update --id REMINDER_ID --section "Games" --dry-run --json
apple reminders sections create --list LIST_ID_OR_TITLE --title "Games" --dry-run --json
apple reminders sections rename --list LIST_ID_OR_TITLE --section "Games" --title "Shopping" --dry-run --json
apple reminders sections delete --list LIST_ID_OR_TITLE --section "Games" --dry-run --json
apple reminders sections reorder --list LIST_ID_OR_TITLE --section "Games" --after "Transit" --dry-run --json
```

Use `subtasks` commands for Reminders.app parent/child hierarchy intent:

```bash
apple reminders subtasks create --parent-id REMINDER_ID --title "Pack cable" --dry-run --json
apple reminders subtasks move --id REMINDER_ID --parent-id PARENT_REMINDER_ID --dry-run --json
apple reminders subtasks promote --id REMINDER_ID --dry-run --json
```

Use `attachments` commands for file/image attachment intent:

```bash
apple reminders attachments add --id REMINDER_ID --file /path/to/image.png --dry-run --json
apple reminders attachments remove --id REMINDER_ID --attachment photo.jpg --dry-run --json
```

Use `assignments` commands for shared-list assignment intent:

```bash
apple reminders assignments assign --id REMINDER_ID --assignee "Taylor" --dry-run --json
apple reminders assignments unassign --id REMINDER_ID --assignment "Taylor" --dry-run --json
```

## Doctor

Use `doctor` to inspect ReminderKit readiness. Use `doctor store`,
`doctor item`, and `doctor list` to explain Reminders.app SQLite evidence:

```bash
apple reminders doctor --json
apple reminders doctor store --scope summary --json
apple reminders doctor store --scope lists --json
apple reminders doctor store --scope reminders --json
apple reminders doctor store --scope sections --json
apple reminders doctor store --scope tags --json
apple reminders doctor store --scope attachments --json
apple reminders doctor store --scope assignments --json
apple reminders doctor item --id REMINDER_ID --json
apple reminders doctor list --list LIST_ID_OR_TITLE --json
```

Doctor output reports ReminderKit readiness and, for store-scoped doctor
commands, read-only verifier evidence for semantic Reminders commands.

## DryRun Preview

Use `--dry-run` to preview the exact action:

```bash
apple reminders complete --id REMINDER_ID --dry-run --json
```

Then run the intended mutation without `--dry-run`:

```bash
apple reminders complete --id REMINDER_ID --json
```

To preserve historical archive state, pass an explicit completion timestamp:

```bash
apple reminders complete --id REMINDER_ID --completed-at 2021-01-02T03:04:05Z --json
```

For destructive selection, artifact actions, external dispatch, persistent
actions, or target-specific system risk, add the specific `--allow-*` flag only
after the user authorizes that risk.
