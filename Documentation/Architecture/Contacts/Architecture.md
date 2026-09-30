# Contacts Architecture

`contacts` owns local Contacts.framework workflows under `apple contacts`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Contacts currently uses Contacts.framework, a public Apple
framework, for accepted people, group, vCard, authorization, and mutation
behavior. It does not currently rely on a broad private Contacts implementation
mechanism.

## Source Authority

Contacts.framework is the authority for accepted person, group, label, vCard,
authorization, and mutation behavior.

## Implementation Mechanisms

Contacts uses Contacts.framework for search, read, duplicate detection, group
membership reads, vCard import/export, contact create/update/delete, and group
membership mutations.

## Validation

Use `apple contacts doctor --json` and Contacts command tests. Detailed command
status lives in `CapabilityList.md`.
