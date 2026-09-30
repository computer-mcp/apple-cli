# SDEF Parity And Safety Gates

## Status

Accepted

## Context

Some Apple apps expose structured scripting dictionaries through `sdef`. The
repository already uses SDEF-backed target-local AppleScript for Notes, Mail,
Messages send, and part of Numbers. Safari also has local SDEF evidence and is
a strong future target candidate.

The repository also uses stronger non-SDEF backends where they fit the accepted
CLI contract better: EventKit for Calendar and Reminders, Contacts.framework
for Contacts, FileManager/QuickLook for iWork document metadata/export paths,
FileManager/NSWorkspace for Finder workflows, CUPS for Print, and NSPasteboard
for Clipboard.

The design needs a way to pursue complete SDEF parity without turning the CLI
into a generic AppleScript runner, whole-Mac automation surface, or runtime
command descriptor system.

## Decision

SDEF-backed targets must account for the relevant scripting dictionary through
domain CLI commands, safety-gated candidates, or proof-failed records.

Non-hidden SDEF entries should map to target-domain CLI commands when they
belong to the target. Hidden, private, or internal SDEF entries are not silently
dropped; they are recorded in reference mappings and treated as `strong-gate`
or `proof-failed` candidates before any production support.

Framework-backed and system-backed targets do not raw-expose SDEF entries.
Instead, they must demonstrate semantic parity or an intentional accepted
superset for stable user-facing SDEF semantics.

Command-to-backend mapping and safety-gate classification live in
`Documentation/Reference/`. They are durable reference truth for review,
implementation planning, and tests. They are not runtime registries, parser
facades, target descriptors, or cross-target dispatch layers.

The canonical CLI remains domain named and target first. No target may expose a
generic `run-applescript`, `run-javascript`, JXA runner, or whole-Mac automation
escape hatch as the mechanism for completeness.

## Consequences

- Future Safari work starts from complete SDEF mapping and safety gates before
  source implementation.
- SDEF-backed targets gain a clearer definition of completeness: every SDEF
  entry is either mapped, safety-gated, or proof-failed.
- Hidden/private/internal SDEF entries require explicit allow flags, `DryRun`
  payloads where applicable, timeout, output caps, payload hashes, and local
  proof before support.
- Framework-backed targets keep their stronger backend choices but must prove
  stable semantic coverage rather than ignoring scriptable app evidence.
- Architecture current truth remains separate from Reference mapping detail.
- The repository does not add a generic command registry or AppleScript
  abstraction layer.

## Alternatives Considered

- Expose raw SDEF commands directly. This would be complete but would create a
  raw automation shell and weaken target-domain CLI design.
- Ignore hidden/private/internal SDEF entries. This keeps the CLI smaller but
  hides important evidence and makes completeness claims unverifiable.
- Require AppleScript for every scriptable app. This would discard stronger
  framework and system backends for Calendar, Reminders, Contacts, Finder, and
  other targets.
- Keep mapping only in tests. Tests help prevent drift, but durable reference
  tables are easier to review before implementation and across targets.

## Related Documentation

- Date: 2026-05-18
- Related docs:
  - [Target Implementation Mechanisms](../Architecture/TargetImplementationMechanisms.md)
  - [CLI Contract](../Architecture/CliContract.md)
  - [Safety Gates](../Reference/SafetyGates.md)
