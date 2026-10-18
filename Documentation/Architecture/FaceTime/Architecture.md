# FaceTime Architecture

`facetime` owns contact resolution and call initiation under `apple facetime`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: FaceTime currently uses Contacts.framework resolution and FaceTime
URL external actions for accepted behavior. It does not currently rely on a
private FaceTime implementation mechanism.

## Source Authority

Contacts.framework provides accepted contact identity. FaceTime URL behavior
provides accepted call start mechanics.

## Implementation Mechanisms

FaceTime uses Contacts.framework for resolution and FaceTime URL external
actions for call start. Structured FaceTime.app scripting is not a current
implementation mechanism.

## Validation

Use FaceTime command tests and command help. Detailed command status lives in
`CapabilityList.md`.
