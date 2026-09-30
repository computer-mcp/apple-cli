# Print Architecture

`print` owns printer and job inspection plus print job actions under
`apple print`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Print currently uses CUPS inspection and bounded `lp` or `cancel`
subprocess actions for accepted behavior. It does not currently rely on a
private print-domain implementation mechanism.

## Source Authority

CUPS printer and job behavior defines the accepted target contract.

## Implementation Mechanisms

Print uses CUPS inspection and bounded `lp`/`cancel` subprocess actions.
PrintCore or app-specific print mechanisms require separate proof.

## Validation

Use Print command tests and command help. Detailed command status lives in
`CapabilityList.md`.
