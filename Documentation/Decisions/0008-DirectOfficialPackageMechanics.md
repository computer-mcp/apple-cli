# Direct Official Package Mechanics

## Status

Accepted

## Context

The repository previously had two kinds of local replacement mechanics:

- hand-written MCP JSON-RPC, protocol value, tool, and stdio framing code
- a partial `swift-argument-parser` command shell that tunneled real target
  options into a hand-written `CLIArgumentParser`

During the migration, a proposed generic target command runtime would have
removed the old parser but still hidden `ArgumentParser` behind a local facade.
That repeats the same architectural mistake in a thinner form.

## Decision

Official Swift packages are used directly at their ownership boundary, the same
way `Foundation` is used directly.

For CLI grammar, each `<Target>CLI` module imports `ArgumentParser` and declares
its own typed target/resource/action commands, options, flags, and option
groups. `AppleCLI` only composes the root `apple` command and target
subcommands.

For MCP, `AppleMCPServer` and `AppleMCPAdapter` import `MCP` and use SDK
`Server`, `StdioTransport`, `Tool`, `Value`, `ListTools`, `CallTool`, and
`CallTool.Result` directly.

Local MCP adapter payload structs may describe CLI contract data, such as the
accepted target list and subprocess stdout/stderr/exit status, but they are not
MCP protocol models. They must not be named or shaped as replacements for SDK
`Tool`, `Value`, or `CallTool.Result`.

`Utility` may hold repository contract mechanics such as JSON envelopes, error
payloads, `DryRun` payloads, diagnostics, small shared option groups, and result/error
rendering helpers. It must not hold a generic target parser, generic command
runtime, command descriptor framework, MCP protocol model clone, or SDK-shaped
wrapper.

## Consequences

- No local `JSONValue`, `CLIMCPTool`, custom MCP framing, or MCP JSON-RPC
  dispatcher remains in production code.
- MCP structured content payloads remain CLI contract payloads, not local MCP
  SDK facades.
- No local `CLIArgumentParser`, `TargetCommandBridge`, `LegacyTargetCommand`,
  `LegacyLeafCommand`, `CLIScaffoldCommand`, `CLITargetRuntime`, or equivalent
  generic command facade remains in production code.
- Target-specific options stay in target modules.
- Some small duplication across target command trees is acceptable when it keeps
  ownership clear and avoids replacing official mechanics.
- Tests should exercise public executable behavior and target-local command
  parsing/validation, not a repository-owned parser facade.

## Alternatives Considered

- Keep hand-written MCP protocol/framing code.
- Clone MCP SDK tool/value/result types locally.
- Hide `ArgumentParser` behind a generic target command protocol and runtime.
- Preserve the former hand-written parser as the production grammar behind
  typed shells.

## Related Documentation

- Date: 2026-05-12
- Related docs:
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
  - [MCP Adapter Boundary](../Architecture/McpAdapterBoundary.md)
  - [CLI Contract](../Architecture/CliContract.md)
  - [Unified Apple Command Tree And Official Swift Mechanics](0007-UnifiedAppleCommandTreeAndOfficialSwiftMechanics.md)
