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

Cell write comparison uses the native value type, actual value, and formula.
Formatted text is presentation evidence. A write is skipped only for identical
literal text with a confirmed absence of a formula. After a write, the command
reads the saved cell again and checks its identity, value, type, and formula.

Path-based writes require ownership of the document's open/save lifecycle.
The writer refuses a document already open in Numbers, including one resolved
by the app to an existing document, to protect pending edits.

## Validation

Use document path validation, iWork command tests, and Numbers-specific tests.
Detailed command status lives in `CapabilityList.md`.
