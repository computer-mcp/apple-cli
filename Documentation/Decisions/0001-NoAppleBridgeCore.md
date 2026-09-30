# No AppleBridgeCore

## Status

Accepted

## Context

The package needs multiple Apple app capabilities, but concrete backend and
command needs differ by app. A broad bridge layer would hide target-local
semantics behind a premature common core.

## Decision

Do not introduce `AppleBridgeCore`. Build independent executable products and
allow shared code only after repeated implementation pressure is visible.

## Consequences

- Initial code may contain some duplication across targets.
- App-specific backend differences stay visible.
- A shared module can still be introduced with evidence.
- Any shared module is limited to mechanical CLI concerns and must not contain
  Apple app business logic.

## Alternatives Considered

- Start with one shared bridge core.
- Start with one multi-app executable.
- Start with an MCP server and move shared behavior behind tools.

## Related Documentation

- Date: 2026-05-11
- Related architecture docs:
  - [Repository Identity](../Architecture/RepositoryIdentity.md)
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
  - [Target Implementation Mechanisms](../Architecture/TargetImplementationMechanisms.md)
