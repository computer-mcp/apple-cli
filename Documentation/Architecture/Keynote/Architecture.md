# Keynote Architecture

`keynote` owns path-bounded `.key` presentation workflows under
`apple keynote`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Keynote currently uses package/FileManager metadata, QuickLook
slide and export mechanisms, and presentation open actions. It does not
currently rely on a private Keynote implementation mechanism.

## Source Authority

The `.key` package shape, QuickLook slide output, and accepted presentation
open/export behavior define the current target contract.

## Implementation Mechanisms

Keynote uses package/FileManager metadata, QuickLook-backed slide listing and
export, presentation open actions, and QuickLook PDF/thumbnail/package export.

## Validation

Use document path validation and iWork command tests. Detailed command status
lives in `CapabilityList.md`.
