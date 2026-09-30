# CLI Contract Is Canonical

## Status

Accepted

## Context

The package supports MCP integration through an adapter. External agents and
scripts also need a stable behavior contract that can be tested without a
specific client.

## Decision

The CLI contract is canonical. MCP and external agent surfaces must adapt to
executable targets instead of defining behavior independently.

## Consequences

- SwiftPM build and run workflows remain the primary verification path.
- Adapters must preserve CLI validation and error categories.
- CLI command grammar must be designed carefully before adapter work expands.

## Alternatives Considered

- Make MCP tools the canonical API.
- Let each adapter define its own command semantics.

## Related Documentation

- Date: 2026-05-11
- Related architecture docs:
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
  - [CLI Contract](../Architecture/CliContract.md)
