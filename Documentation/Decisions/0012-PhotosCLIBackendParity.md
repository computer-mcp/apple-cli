# PhotosCLI Backend Parity

## Status

Accepted

## Context

The repository has a target-first SwiftPM CLI architecture. Each `<Target>CLI`
module owns typed `swift-argument-parser` commands, target-local validation,
backend behavior, diagnostics, and safety-gated mutation or external-action
flows. `AppleCLI` only composes the root command. MCP is an adapter over the
canonical CLI contract and must not expose hidden MCP-only behavior.

Photos.app publishes a structured scripting dictionary (SDEF). The SDEF
exposes photo library open, containers, albums, folders, media items, selection,
favorites/recently deleted albums, import/export, duplicate/make/delete/add,
slideshow, spotlight/search, and hidden rows such as `moment` and `last import
album`.

External reference fixtures and command behavior are available for Photos
library query, export, archive, metadata, sidecar, export-state, template, hook,
and test semantics. These references inform tests and behavior; they are not
architecture truth.

PhotoKit is an official Swift-accessible framework and imports successfully on
supported macOS versions. SQLite3 also imports successfully from Swift. exiftool is
optional and provides metadata write coverage beyond Apple command-line tools.

The design needs to accept Photos as a first-class target without importing
third-party product architecture, adding a raw automation runner, adding raw SQL as
normal grammar, or making third-party tools mandatory core dependencies.

## Decision

`photos` is accepted for implementation as the next first-class target under
the canonical `apple` CLI.

The implementation is mixed-backend and target-local:

- Swift read-only SQLite snapshot is the canonical backend for deep query,
  search, metadata reads, export planning, report inputs, and normalized
  reference parity.
- Photos SDEF via synchronous `NSAppleScript` is the canonical backend for
  Photos.app app-local actions such as library open, selection, import/export
  where Photos owns behavior, album/folder/media item mutation, slideshow,
  spotlight, and app-search proof.
- FileManager/package behavior owns `.photoslibrary` discovery, package info,
  backup/copy, export destination writes, export state DBs, reports, and
  sidecars.
- PhotoKit is used only for concrete fields or commands after proof that it
  covers or exceeds the mapped SDEF or snapshot semantics.
- exiftool is optional, doctor-gated, and risk-flag gated. Missing exiftool
  produces structured diagnostics.

External reference behavior is a semantic reference and gated test oracle, not a
default production runtime. The local target must account for accepted
query/export/archive, metadata, sidecar, export-state, import, batch-edit,
sync, timewarp, add-locations, push-exif, template, query-hook, post-hook, and
post-command semantics, but it does not copy third-party flags, Python APIs,
Click UX, raw SQL passthrough, or runtime/product helper commands.

Swift eval hooks replace user-code hook semantics through a JSON wire:
the CLI sends `PhotoHookInput` JSON on stdin and expects `PhotoHookOutput` JSON
on stdout. Template, query, and post hooks are `strong-gate`. Shell
post-command behavior is also `strong-gate`. MCP may expose these only through
the canonical CLI surface and cannot bypass allow flags, selector
binding, source/command hashes, timeout, or output caps.

Architecture current truth is updated only after `PhotosCLI` source
implementation, tests, executable contract validation, MCP projection, README
updates, and docs drift scans pass.

## Consequences

- `apple photos` becomes the planned seventeenth target, but it is not recorded
  as implemented Architecture truth until implementation closeout.
- `PhotosCLI` must own Photos business behavior. `Utility` remains mechanics
  only.
- Every Photos SDEF row and every accepted external reference family must map to
  a typed domain command, semantic replacement, `strong-gate`, or
  `proof-failed` record.
- Query/export code must copy Photos database inputs to a temp snapshot before
  opening them through SQLite C API, and must never write inside a
  `.photoslibrary`.
- Direct Photos database writes, arbitrary AppleScript/JXA/UI scripting,
  arbitrary external-tool passthrough, raw SQL as normal grammar, and unsafe
  in-library original mutation remain proof-failed unless a later ADR changes
  the boundary.
- Default tests must not require large external fixtures, a populated user
  Photos library, Photos.app UI interaction, or exiftool.
- Gated reference validation may use external fixtures only through an
  explicit environment variable and must copy any `.photoslibrary` before
  Photos.app opens it.

## Alternatives Considered

- Use a third-party Photos tool as a production subprocess backend. This would
  ship fast, but imports Python dependency shape, Click UX, raw SQL/user-code
  surfaces, and a third-party runtime into the local CLI architecture.
- Use PhotoKit as the only backend immediately. PhotoKit is official, but the
  target still needs SDEF accounting and normalized reference proof before
  assuming one framework covers the full contract.
- Use Photos SDEF only. SDEF covers app-local automation, but it does not match
  the accepted depth for query/export/archive/metadata/report behavior.
- Implement only read-only library queries first. That would create a partial
  target and fail the complete accounting goal for Photos SDEF and accepted
  reference semantics.
- Expose raw AppleScript, raw SQL, or third-party passthrough. This would be broad
  but violates the target-first CLI contract and safety model.

## Related Documentation

- Date: 2026-05-19
- Related docs:
  - [SDEF Parity And Safety Gates](0010-SDEFParityAndSafetyGates.md)
  - [Photos Capability List](../Architecture/Photos/CapabilityList.md)
  - [Photos Developer Guide](../Reference/Photos/DeveloperGuide.md)
  - [Safety Gates](../Reference/SafetyGates.md)
  - [Target Implementation Mechanisms](../Architecture/TargetImplementationMechanisms.md)
