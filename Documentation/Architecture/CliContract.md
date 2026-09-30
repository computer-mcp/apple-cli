# CLI Contract

## Scope / Purpose

This document defines the current CLI behavior contract for the canonical
`apple` executable.

## Command Contract

All behavior is exposed through:

```text
apple <target> <resource?> <action> [options]
```

Each target owns exactly one capability surface:

- `notes` owns Notes.
- `calendar` owns Calendar.
- `reminders` owns Reminders.
- `contacts` owns Contacts.
- `mail` owns Mail.
- `messages` owns Messages.
- `maps` owns Maps.
- `finder` owns Finder/app-bound file workflows.
- `numbers` owns Numbers.
- `pages` owns Pages.
- `keynote` owns Keynote.
- `facetime` owns FaceTime and call-initiation workflows.
- `safari` owns Safari windows, tabs, page reads, browser state actions, and
  safety-gated Safari SDEF workflows.
- `photos` owns Photos library, album, media item, export, metadata, and
  gated hook workflows.
- `print` owns local printing workflows.
- `clipboard` owns pasteboard workflows.
- `notifications` owns this tool's local notification output workflows.
- `intelligence` owns Apple Intelligence workflows. Its current production line
  is a Swift-owned local-cache enablement path.
- `tcc` owns TCC diagnostics and explicit permission recovery workflows.

The primary resource is omitted when it would repeat the target, such as
`apple notes list`, `apple messages send`, and `apple clipboard read`.
Secondary resources remain explicit, such as `apple calendar events list`,
`apple contacts groups members`, and `apple mail messages read`.

## Constraints

- Commands must be scriptable in non-interactive sessions.
- Permission failures must return structured errors in JSON mode.
- Mutating commands require explicit operation names and safety rules.
- Destructive defaults are not allowed.
- Adapters must not introduce command behavior that the CLI target does not
  expose.
- Shared conventions are CLI mechanics only. They must not introduce shared
  Apple app business models or cross-app CRUD abstractions.
- Behavior must stay normalized to this envelope, exit-code, diagnostics,
  identity, and command safety-policy model before adapters rely on it.

## Current Capability Baseline

- `notes`: Notes.app accounts, folders, Smart Folders, tags, links,
  attachments, rich body structure/formatting/list/checklist/collapsible-state
  operations, note state reads/audits, import/export/print/Page handoff, note
  lifecycle mutations, doctor diagnostics, and explicit gated refusals for
  unsafe lock/share/collaboration or unsupported rich surfaces. The
  target-owned source hierarchy and full supported/gated/delegated/rejected
  matrix live in `Documentation/Architecture/Notes/CapabilityList.md`.
- `calendar`: calendar listing, event list/search/read, occurrences,
  availability, statistics, iCalendar export, create/update/delete, attendee
  metadata, alarms, and recurrence.
- `reminders`: list listing with read-only list-type/smart-list/list-metadata enrichment where
  available, safety-gated `lists update --title/--color/--icon` through structured
  Reminders.app scripting, safety-gated `lists create/delete`, read-only
  `tags list` and `sections list`, ReminderKit-backed visible URL/link-card
  writes, file/image attachment add/remove, item tag set/add/remove/clear, tags
  rename/delete, section create/rename/delete/reorder, item section membership, and subtask create/move/promote,
  urgent reminder state, shared assignment, and
  `lists update --type standard|shopping` plus `--pinned/--sort`, and
  `lists groups create/rename/delete/move-list/remove-list`,
  `lists reorder`, and `lists smart create/update/delete/convert` for supported custom Smart List criteria
  and standard-list conversion,
  reminder list/search/read with read-only
  assignment/tag/flag/visible URL enrichment where available,
  doctor, doctor store, doctor item, and doctor list diagnostics, create/update
  with notes, flag state, due date, and priority, and
  complete/uncomplete/complete-many/uncomplete-many/complete-matching/uncomplete-matching/delete/cleanup-completed.
- `contacts`: search/read, duplicate detection, group listing/member reads,
  vCard export/import, create/update/delete, explicit-ID bulk delete,
  query-bound delete, and group membership commands.
- `mail`: accounts/mailboxes, message list/unread/search/read, bounded body
  search, explicit body preview, reply/forward preview, draft/reply-draft/
  forward-draft/send/move/archive/delete.
- `messages`: conversations/messages search/read, iMessage send,
  existing-chat conversation send, and explicit-recipient send-many.
- `maps`: place search/read, coordinate-aware directions, and open-in-Maps.
- `finder`: file listing, reveal/open, metadata/tag/search, move/trash/delete,
  create-only text write, and single-file overwrite.
- `numbers`: document/sheet/table read, table CSV/TSV export, single-cell table
  text write, document open, and QuickLook PDF/thumbnail/package export.
- `pages`: document read/open/export, including QuickLook
  PDF/thumbnail/package export.
- `keynote`: presentation/slide read, slide image export, open, and QuickLook
  PDF/thumbnail/package export.
- `facetime`: contact/call preparation and gated call initiation.
- `safari`: windows/tabs/current/read, profile, snapshot window, and Tab Group
  snapshot reads including snapshot window mappings, bounded page text/source reads, state-action
  tab select/open/navigate and web search, safety-gated tab close and
  Reading List add, strong-gated JavaScript/email/bookmarks/extensions/privacy
  report actions, and proof-failed hidden/private SDEF entries.
- `photos`: library discovery, read-only SQLite snapshot media queries,
  album/folder/media item SDEF actions, import/export/report,
  metadata sidecar/EXIF planning, slideshow/spotlight, and strong-gated Swift
  eval hooks/post-commands.
- `print`: printer/job inspection and external-dispatch-gated print submit/cancel.
- `clipboard`: pasteboard read/type inspection and safety-gated write/clear.
- `notifications`: local notification preview and safety-gated send for
  notifications created by this tool.
- `intelligence`: support/doctor/verify plus risk-flag-gated local-cache
  answer/comprehensive plist enablement, eligibility country cache rewrite,
  `reset-cache` with optional kickstart, rollback, unlock, high-risk `lldb`
  recompute, and optional LaunchDaemon service management.
- `tcc`: service catalog, identity diagnostics, database info/digest and
  records inspection, doctor mapping, access preflight/request, official reset,
  and gated private database/framework diagnostics.

## Shared CLI Conventions

Every target uses the same mechanical conventions where practical:

- `--json`: emit the machine-readable envelope.
- `--pretty`: pretty-print JSON when `--json` is active.
- `--verbose`: write additional diagnostics to stderr.
- `--limit <n>`: cap list/search output. Targets may set stricter caps.
- `--dry-run`: run parsing, normalization, target-local resolution, and
  validation for a mutating or external-action command, then stop before side
  effects and return a `DryRun` payload.
- `--allow-destructive-selection`: allow query, bulk, cleanup, broad selection,
  delete, overwrite, or similar destructive selection when the target requires
  it.
- `--allow-external-dispatch`: allow dispatch to another app, URL handler,
  system service, print service, notification center, communication service, or
  external process when the target requires it.
- `--allow-artifact-action`: allow creation, overwrite, movement, removal,
  import, export, or packaging of filesystem artifacts when the target requires
  it.
- `--allow-persistent-action`: allow state that is intended to persist beyond
  the immediate command output when the target requires it.
- `--help`: explain supported commands and safety requirements.

Human-readable text output is allowed for direct terminal use, but adapter
surfaces must use `--json`.

## Options And Safety Naming

CLI options and flags use role-based names:

- An `option` carries a configuration value. It never authorizes risk by
  itself. Examples: `--patch-scope`, `--state`, `--timeout`, `--root`.
- A regular `flag` is a Boolean behavior switch. It is not a risk
  acknowledgement by itself. Examples: `--verbose`, `--pretty`,
  `--skip-lock`.
- A `risk flag` or `allow flag` explicitly acknowledges a named risk class.
  It must use `--allow-<risk>` naming and describe the affected capability,
  not the user's intent. Examples: `--allow-system-cache-write`,
  `--allow-cache-reset`, `--allow-debug-attach`,
  and `--allow-persistent-service`.
- Avoid generic authorization names such as `--force`, `--yes`, or
  `--unsafe` as the primary safety mechanism for new commands.
- `operation` names are stable semantic action names such as
  `intelligence.enable` or `mail.send`. They are not raw command lines.
- `DryRun` payloads describe the result of preview mode before side effects.
  They are not authorization tokens and are not replayed during execution.
- `OperationResult` payloads describe completed execution. They are not
  previews, plans, or authorization data.

Each mutation or external action must declare a target-local safety policy:

| Policy | Contract meaning |
| --- | --- |
| `readOnly` | Inspection, diagnosis, or verification. It rejects `--dry-run` and risk flags unless the target explicitly supports read preview. |
| `boundedRead` | Read may expose large, private, or sensitive content. It requires explicit selectors, limits, byte caps, truncation metadata, or equivalent target-local controls. |
| `ordinaryMutation` | Explicit single-object or explicitly addressed mutation. It supports `--dry-run`; real execution does not require a generic allow flag unless the target declares an extra risk. |
| `destructiveSelection` | Query, bulk, cleanup, broad selection, delete, overwrite, or similar destructive selection. It supports `--dry-run`; real execution requires `--allow-destructive-selection` or a stronger target-specific allow flag. |
| `externalDispatch` | Sends work to another app, system service, URL handler, print service, notification center, communication service, or external process. It supports `--dry-run`; real execution requires `--allow-external-dispatch` or a stronger target-specific allow flag. |
| `riskBoundSystemAction` | Mutates local system-domain state, security state, services, caches, or private/protected OS surfaces. It supports `--dry-run` where the target can resolve up to the side-effect boundary; real execution requires a target-specific `--allow-*` flag. |
| `artifactAction` | Creates, overwrites, moves, deletes, exports, imports, or packages filesystem artifacts. It supports `--dry-run`; real execution requires `--allow-artifact-action` unless the target declares a stronger flag. |
| `persistentAction` | Installs, removes, or changes state intended to outlive the immediate command. It supports `--dry-run` where useful; real execution requires `--allow-persistent-action` or a stronger target-specific flag. |

## Validation Ownership

Swift package tests validate Swift CLI behavior and typed public CLI contracts:
parser behavior, JSON envelopes, exit codes, target-local safety policy,
permission/error behavior, backend semantics, and packaged test resources.

Swift tests must not be used as prose-grep guards for `README.md`,
`Documentation/`, release notes, or temporary `.agent` execution
state. Documentation and release-surface drift belongs to the owning surface's
generation, linting, review, or scaffold validation process, not target
behavior tests.

## Agent And Usage Guidance Ownership

Development and agent constraints belong in `AGENTS.md` and architecture
documents. Ordinary usage belongs in CLI help, README material, and focused
manuals under `Documentation/Reference/`. Setup, dependency, permission, and
readiness diagnosis belongs in target-local `doctor` commands. Do not create a
parallel user-facing command guide outside those owners.

Tests should also avoid source-shape assertions that grep implementation files
for specific snippets. Prefer behavior tests through target APIs, fake
backends, fixtures, or executable contract checks.

## Stdout / Stderr

- stdout is reserved for command results.
- stderr is reserved for diagnostics, warnings, permission guidance, and
  verbose logs.
- Machine-readable result JSON must not be mixed with stderr diagnostics.
- Sensitive Apple app content should not be duplicated into stderr.

## JSON Envelope

Successful JSON output uses this shape:

```json
{
  "ok": true,
  "data": {},
  "meta": {
    "target": "notes"
  },
  "warnings": []
}
```

Error JSON output uses this shape:

```json
{
  "ok": false,
  "error": {
    "code": "permission_denied",
    "message": "Apple Notes automation permission is not granted.",
    "details": {}
  },
  "meta": {
    "target": "notes"
  },
  "warnings": []
}
```

Error codes are stable snake_case strings. Human text may change; adapter logic
must key off `error.code` and structured `details`.

## User-Visible Wording

JSON `error.message`, `warnings`, doctor diagnostic prose, and terminal stderr
guidance are reader-facing. They may be normalized through Swift wording
helpers when they explain permissions, TCC, Automation, Full Disk Access,
safety gates, allow-flag requirements, or recovery steps.

Target-specific failure semantics belong in structured details, normally
`details.failure`, backed by a target-local enum when the target has enough
distinct failure reasons to justify it. Do not add `.strings` or `.xcstrings`
resources for CLI help, diagnostics, or target-local errors.

Stable machine fields are not wording. Do not localize or branch on
`error.code`, `details`, `meta.target`, `operation`, `DryRun` fields, identifiers,
`details.failure`, or enum-like state strings. See
[Permission And Wording](PermissionAndWording.md) for the permission wording
boundary.

## Exit Codes

Current stable exit codes:

| Code | Meaning |
| --- | --- |
| `0` | Success |
| `1` | General failure |
| `2` | Usage or validation error |
| `3` | Permission or TCC failure |
| `4` | Ambiguous or conflicting identity |
| `5` | Resource not found |
| `6` | Timeout |
| `7` | Backend unavailable |
| `8` | Unsupported operation |
| `9` | Unsafe mutation refused |
| `70` | Internal implementation error |

## Identity Policy

- Prefer backend-provided stable identifiers when available.
- Treat titles, subjects, names, and natural-language labels as selectors, not
  stable identifiers.
- If a selector matches multiple resources, return an ambiguity error instead
  of guessing.
- Destructive or update operations should require stable identifiers once the
  target can provide them.
- Notes duplicate titles are expected and must be handled explicitly.

## Date, Time, and Pagination

- Dates should use `YYYY-MM-DD`.
- Date-times should use ISO 8601 / RFC 3339 with an explicit time zone offset
  or a separately supplied IANA time zone.
- Calendar and Reminders commands must make range boundaries explicit.
- List/search commands should support `--limit`; large result sets should
  return pagination metadata when needed.
- Targets may impose lower default limits for privacy or performance.

## Mutation and Destructive Action Policy

- Reads and searches are the safest default workflows.
- Mutations must have explicit verbs such as `create`, `update`, `append`,
  `complete`, or `uncomplete`.
- Every mutation or external action must declare one of the safety policies
  above.
- `--dry-run` runs the same parsing, normalization, target-local resolution,
  and validation as execution, then stops before the side-effect boundary and
  returns a `DryRun` payload.
- Destructive operations such as delete, move, archive, bulk import, and broad
  export/update flows require a concrete allow flag when the selection is
  dynamic, broad, destructive, or otherwise target-declared risky.
- Direct Mail send is not a casual default operation.
- External actions such as message send, call initiation, print submission, and
  print cancellation require external-dispatch safety when they cross into
  another app, service, or process.
- Fixed system-domain mechanisms use precise risk flags. For example,
  `intelligence` uses target-specific `--allow-*` flags and returns a typed
  operation result.

## Safety Gate Classes

Targets may classify commands by safety gate. The gate is part of the CLI
contract for a command, but the command remains owned by its target.

| Gate | Contract meaning |
| --- | --- |
| `readOnly` | Metadata or bounded inspection that does not change user state. |
| `boundedRead` | Read that may expose private or large content; it requires explicit selectors, limits, byte caps, truncation metadata, or equivalent target-local controls. |
| `ordinaryMutation` | Explicit mutation with a narrow user-provided target and no extra declared risk. |
| `destructiveSelection` | Query, bulk, cleanup, broad selection, delete, overwrite, or similar destructive selection requiring a concrete allow flag. |
| `externalDispatch` | Cross-app, URL, service, print, notification, communication, or subprocess dispatch requiring a concrete allow flag. |
| `riskBoundSystemAction` | System-domain cache, service, security, or private/protected surface mutation requiring a target-specific allow flag. |
| `artifactAction` | Filesystem artifact creation, overwrite, movement, removal, import, export, or packaging requiring a concrete allow flag. |
| `persistentAction` | Installation or state intended to persist beyond the immediate command requiring a concrete allow flag. |
| `proofFailed` | Desired mapping exists in evidence, but local OS, entitlement, TCC, stability, or safety proof failed; the command must not silently masquerade as supported. |

The durable gate catalog is in
[Safety Gates](../Reference/SafetyGates.md). The catalog is
documentation and test guidance, not a runtime registry.

## Related Decisions

- [0002: CLI Contract Is Canonical](../Decisions/0002-CliContractIsCanonical.md)
- [0015: DryRun And Risk Flag Safety Model](../Decisions/0015-DryRunAndRiskFlagSafetyModel.md)
- [0007: Unified Apple Command Tree and Official Swift Mechanics](../Decisions/0007-UnifiedAppleCommandTreeAndOfficialSwiftMechanics.md)
- [0010: SDEF Parity And Safety Gates](../Decisions/0010-SDEFParityAndSafetyGates.md)
