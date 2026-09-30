# Maps Architecture

`maps` owns place lookup, directions preview, and Maps open actions under
`apple maps`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Maps currently uses CoreLocation-style lookup behavior and
validated `maps:` URL external actions. It does not currently rely on a private
Maps implementation mechanism.

## Source Authority

CoreLocation-backed lookup behavior and validated Maps URLs define the accepted
CLI contract.

## Implementation Mechanisms

Maps uses CoreLocation-style place/direction resolution and validated `maps:`
URL external actions. Structured Maps.app scripting is not a current
implementation mechanism.

## Validation

Use command help and Maps command tests. Detailed command status lives in
`CapabilityList.md`.
