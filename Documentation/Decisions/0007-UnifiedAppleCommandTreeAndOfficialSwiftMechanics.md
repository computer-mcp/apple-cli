# Unified Apple Command Tree And Official Swift Mechanics

## Status

Accepted and implemented

## Context

The package previously exposed first-class executable products for each
accepted target. That shape has been replaced by a single canonical
human/script entrypoint, with typed Swift grammar and concrete process
execution provided by official Swift packages.

This decision now records accepted implemented architecture. `Package.swift`,
target declarations, adapters, and tests use exactly the two executable
products recorded below.

## Decision

Adopt `apple <target> <resource?> <action> [options]` as the canonical command
tree.

The product shape is:

- `apple`
- `apple-cli-mcp`

The implemented package removed the 15 direct `apple-*` target executable
products rather than preserving legacy aliases.

Target names under `apple` use short nouns such as `notes`, `calendar`,
`reminders`, `contacts`, `mail`, `messages`, `maps`, `finder`, `numbers`,
`pages`, `keynote`, `facetime`, `print`, `clipboard`, and `notifications`.

Omit a repeated primary resource when the target already names that resource.
For example:

- `apple notes list`
- `apple contacts search`
- `apple messages send`
- `apple clipboard read`
- `apple notifications send`

Keep explicit resource layers when they add meaning. For example:

- `apple notes accounts list`
- `apple calendar events list`
- `apple mail messages read`
- `apple finder items search`
- `apple numbers tables read`

Use `swift-argument-parser` as the production command grammar dependency. Treat
it like `Foundation`: target modules import it directly and declare real
`ParsableCommand`, `@Option`, `@Flag`, and `@OptionGroup` grammar for the
local `apple` CLI. Do not default `apple` target commands to
`AsyncParsableCommand` for symmetry with adapters or future async work; local
Apple app commands are synchronous unless a concrete target backend proves
otherwise. Do not hide `ArgumentParser` behind a local parser facade, command
runtime, descriptor framework, or generic target command protocol. Each
`<Target>CLI` owns its typed command tree and may expose `ArgumentParser`
command types as public API. `CLIOptions` may remain an internal target
implementation context for existing backend dispatch, but it is not the
production command grammar and must not be populated by a repository parser
facade.

Use `swift-subprocess` as the production subprocess execution dependency for
concrete process-backed runners. It is an execution mechanic and does not need
to become public target CLI module API.

`Utility` remains the owner of repository contract concerns: JSON envelopes,
exit codes, diagnostics, `DryRun` payloads, result rendering, small shared option
groups, and shared output helpers. It must not provide a generic target
parser/runtime facade that replaces direct `ArgumentParser` usage.

`apple-cli-mcp` remains an adapter executable over the canonical CLI contract.
MCP protocol, server lifecycle, tool/value/result types, and stdio transport are
owned by the official MCP Swift SDK and are used directly in `AppleMCPServer` and
`AppleMCPAdapter`; this repository must not clone those SDK types into local MCP
models.

Async execution belongs at true async boundaries such as `apple-cli-mcp` server
lifecycle. In-process `NSAppleScript` target backends must not be pushed behind
an async command executor as a generic grammar choice; this can hang Apple Event
execution even when the same AppleScript works in a direct synchronous process.
The reproduced failure shape covers app object enumeration for Notes accounts,
Mail accounts, Messages services, and Numbers documents; shallow scripts that
only return an app name do not exercise the same failure mode.

## Command Examples

```text
apple notes list
apple notes accounts list
apple calendar events list
apple mail messages read
apple messages send
apple maps open
apple finder items search
apple numbers tables read
apple clipboard read
apple notifications send
```

## Consequences

- This was a breaking CLI and target kit API change.
- Current architecture documents describe the implemented truth; no legacy
  `apple-*` target executable products or aliases remain.
- Direct dependency decisions are recorded in decision records and current
  architecture truth.
- Future MCP adapter work and any external agent integration must call the
  unified `apple` grammar.
- No legacy `apple-*` aliases are planned.
- Official packages are dependency boundaries, not abstraction targets. Local
  types are for `apple-cli` behavior and contract, not replacement APIs
  for `ArgumentParser`, MCP SDK, or `swift-subprocess`.

## Alternatives Considered

- Keep 15 direct `apple-*` products as canonical entrypoints.
- Add `apple` while preserving `apple-*` legacy aliases.
- Hide `ArgumentParser` behind a local parser facade.
- Hide `ArgumentParser` behind a local generic command runtime or descriptor
  framework.
- Clone MCP SDK protocol/tool/value/result types locally.
- Expose `swift-subprocess` types through target kit public APIs.

## Related Documentation

- Date: 2026-05-12
- Related architecture docs:
  - [Repository Identity](../Architecture/RepositoryIdentity.md)
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
  - [CLI Contract](../Architecture/CliContract.md)
