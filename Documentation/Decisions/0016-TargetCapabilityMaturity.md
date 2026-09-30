# 0016: Target Capability Maturity

## Status

Accepted.

## Context

`apple-cli` is a target-first CLI for local Apple app, Apple domain, and system
domain capabilities. Existing architecture already records accepted targets,
capability lists, implementation mechanisms, CLI contract rules, and safety
gates. The project also needs a concise way to describe each target's direction
from exposed Apple surfaces toward a complete local app/domain CLI.

SDEF/app scripting, AppleScript, public frameworks, URL schemes, file/package
APIs, read-only store snapshots, and bounded subprocesses can make useful
targets, but they are often incomplete app-domain surfaces. Private frameworks
and equivalent Apple-owned private mechanisms can expose richer local object
models, state, metadata, and mutations when they can be proven and validated.

The repository also needs to keep accepted maturity separate from proposed
capabilities. A target maturity model is accepted direction; a private
framework inventory or capability opportunity remains proposed until promoted
into architecture truth.

## Decision

Adopt target capability maturity levels as current architecture truth:

- `L0 Public Framework / SDEF / AppleScript`
- `L1 Private Framework`
- `L1.5 Private Framework Implemented`
- `L2 Full App/Domain CLI`

The canonical definitions live in
[Target Capability Maturity](../Architecture/TargetCapabilityMaturity.md).

Maturity is target-level capability coverage, not a code layering model and not
per-command scoring. Target-local capability lists remain the place for
command-family support, gated behavior, rejected behavior, and proof
requirements.

The maturity model does not accept new private APIs, direct store writes,
commands, or targets. Proposed capabilities remain in
`Documentation/Proposals/` until accepted through the normal architecture and
decision process.

## Consequences

- Architecture docs can describe target direction without overloading
  implementation mechanism tables.
- SDEF/app scripting and AppleScript remain valid implementation mechanisms,
  but they are not the desired ceiling for app-domain targets where a stronger
  local Apple mechanism can be proven.
- Private frameworks are not accepted merely by discovery. They must produce
  usable, target-local capability improvements with documented validation and
  safety boundaries.
- Proposed capability mapping can remain design-in-progress without implying
  supported behavior.
- Direct store writes remain rejected unless a future target-specific decision
  explicitly accepts the mechanism.

## Related Documentation

- Date: 2026-06-19
- Related docs:
  - [Target Capability Maturity](../Architecture/TargetCapabilityMaturity.md)
  - [Target Implementation Mechanisms](../Architecture/TargetImplementationMechanisms.md)
  - [Capability List](../Architecture/CapabilityList.md)
  - [Proposed Capability Table](../Proposals/ProposedCapabilityTable.md)
