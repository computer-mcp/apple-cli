# Clipboard Architecture

`clipboard` owns local pasteboard workflows under `apple clipboard`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Clipboard currently uses NSPasteboard, a public system pasteboard
mechanism, for accepted read, write, and clear behavior. It does not currently
rely on a private pasteboard implementation mechanism.

## Source Authority

NSPasteboard defines the accepted pasteboard type, read, write, and clear
behavior.

## Implementation Mechanisms

Clipboard uses NSPasteboard. It is a narrow system-domain target, not a broad
clipboard history or cross-device clipboard automation surface.

## Validation

Use command help and system-domain command tests. Detailed command status lives
in `CapabilityList.md`.
