# Messages Architecture

`messages` owns local Messages reads and sends under `apple messages`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Messages currently uses read-only local database inspection for
reads and Messages.app structured send automation for accepted sends. It does
not currently rely on a broad private Messages or IMCore implementation
mechanism.

## Source Authority

The local Messages database is the source for accepted read-only conversation
and message inspection. Messages.app structured send behavior is the source for
accepted sends.

## Implementation Mechanisms

Messages uses read-only local database inspection for reads and target-local
Messages.app send automation for safety-gated sends.

## Validation

Use command help, privacy-permission diagnostics, and Messages command tests.
Detailed command status lives in `CapabilityList.md`.
