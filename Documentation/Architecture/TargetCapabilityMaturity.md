# Target Capability Maturity

## Scope / Purpose

This document defines the accepted target-level capability maturity direction
for `apple-cli`. It is not a code layering model and it is not command-level
scoring. It describes how each accepted target should evolve from basic Apple
exposed mechanisms toward a complete local app/domain CLI.

Accepted command surfaces remain in [Capability List](CapabilityList.md) and
target-local capability lists. Implementation mechanism detail remains in
[Target Implementation Mechanisms](TargetImplementationMechanisms.md) and
target-owned architecture documents.

## Maturity Levels

| Level | Name | Meaning |
| --- | --- | --- |
| `L0` | Public Framework / SDEF / AppleScript | The target is usable through Apple exposed or readily observable mechanisms such as public frameworks, SDEF/app scripting, AppleScript, URL schemes, file/package APIs, read-only store snapshots, or bounded subprocesses. This is a valid starting point, but app-domain targets at this level are often limited by the exposed surface. |
| `L1` | Private Framework | A core app/domain capability is implemented through an Apple private framework or equivalent Apple-owned private implementation mechanism, and the mechanism proves a material capability improvement over the L0 surface. |
| `L1.5` | Private Framework Implemented | The private framework or equivalent Apple-owned private implementation mechanism is the main path for most of the target's app/domain capability surface. Core objects, relationships, search/read/write workflows, import/export paths, or key rich metadata are implemented, while explicit gaps or gated areas remain. |
| `L2` | Full App/Domain CLI | Outside visual UI presentation, the CLI approaches the app/domain capability surface: data model, relationships, state, search, import/export, common and advanced mutations, rich content, sync/share boundaries, validation, recovery, and diagnostics are coherent. This does not require exposing every Apple internal experiment, preference, animation, or visual UI affordance. |

## Level Rules

- Maturity is assigned at the target level. Target-local capability lists may
  record command-family gaps, gated behavior, rejected behavior, and proof
  requirements without turning this model into per-command scoring.
- A target can use multiple implementation mechanisms at any level, but the
  level should reflect the strongest proven mechanism and the effective target
  capability coverage.
- `L1` is not granted for finding a private framework. The private mechanism
  must be usable and must improve the target beyond its L0 surface.
- `L1.5` means the private implementation is broadly implemented, not merely
  probed. Remaining gaps must be explicit.
- `L2` means full support for the app/domain CLI direction outside visual UI,
  not a clone of every Apple app feature or private diagnostic entry.
- When a public Apple framework is already the strongest complete mechanism for
  a domain, target-owned architecture may justify high maturity without a
  private framework rewrite.

## Relationship To Proposed Capabilities

Target maturity does not accept proposed commands, targets, private APIs, or
direct store writes by itself. Proposed capabilities belong in
`Documentation/Proposals/` until accepted into architecture truth and
target-local capability lists.

Read-only store snapshots may support diagnostics, enrichment, and verification
when target-owned docs allow them. Direct store writes remain rejected unless a
future target-specific decision explicitly accepts that mechanism and its
validation boundaries.

## Related Documents

- [Capability List](CapabilityList.md)
- [Target Implementation Mechanisms](TargetImplementationMechanisms.md)
- [Target-First CLI](TargetFirstCli.md)
- [Target Capability Maturity Decision](../Decisions/0016-TargetCapabilityMaturity.md)
