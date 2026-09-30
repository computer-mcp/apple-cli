# Numbers Architecture

`numbers` owns path-bounded `.numbers` document workflows under
`apple numbers`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Numbers currently uses file/package metadata, QuickLook export, and
target-local Numbers.app structured scripting for accepted document, sheet,
table, and cell workflows. It does not currently rely on a private Numbers
implementation mechanism.

## Source Authority

The `.numbers` package shape, QuickLook output, and accepted Numbers.app
sheet/table scripting define the current target contract.

## Implementation Mechanisms

Numbers uses package/FileManager metadata, QuickLook export, and target-local
Numbers.app structured scripting for sheet/table reads and single-cell text
writes.

## Validation

Use document path validation, iWork command tests, and Numbers-specific tests.
Detailed command status lives in `CapabilityList.md`.
