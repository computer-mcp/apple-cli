# MCP Is Adapter, Not Core

## Status

Accepted

## Context

MCP is valuable for assistant and client integration, but making it the core
would pull package architecture toward server lifecycle concerns too early.

## Decision

MCP is an adapter over CLI targets. The CLI contract remains canonical, and MCP
cannot become the owner of target behavior.

## Consequences

- No MCP target is created during initial package setup.
- MCP lifecycle, client config, and host app UX remain adapter concerns.
- MCP cannot expose behavior that the CLI does not support.

## Alternatives Considered

- Start with a single MCP server binary.
- Build a host app before CLI targets.

## Related Documentation

- Date: 2026-05-11
- Related architecture docs:
  - [Repository Identity](../Architecture/RepositoryIdentity.md)
  - [MCP Adapter Boundary](../Architecture/McpAdapterBoundary.md)
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
