# Reminders Developer Guide

## Scope / Purpose

This guide is for maintaining and validating the `apple reminders` target. It
covers package checks, doctor commands, and fixture-backed Swift Testing validation.
Ordinary usage lives in `UserGuide.md`.

## Default Validation

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

## Fixture-Backed Swift Testing Validation

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
