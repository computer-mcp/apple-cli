# MCP Adapter Boundary

## Scope / Purpose

This document defines how MCP should relate to `apple-cli`.

## Context / Boundaries

MCP is an integration surface for clients. It is not the product core. MCP
tools adapt to the `apple` command tree across the target catalog and inherit
its safety constraints.

The dependency direction is CLI to MCP adapter, not MCP to core behavior. MCP
protocol and transport mechanics belong to the official MCP Swift SDK and are
used directly in the adapter layer.

## Constraints

- MCP must not bypass CLI validation.
- MCP must not expose hidden write or destructive operations.
- MCP must not become a reason to hide target-local ownership behind generic
  tools.
- MCP must not define the core command grammar.
- MCP SDK types must not be cloned into local protocol models. Use SDK
  `Server`, `StdioTransport`, `StatefulHTTPServerTransport`, `Tool`, `Value`,
  `ListTools`, and `CallTool` types directly at the `AppleMCPServer` /
  `AppleMCPAdapter` boundary.
- Local structured content payload structs are allowed only when they describe
  CLI contract data such as accepted targets, subprocess stdout/stderr, and exit
  status. They must not be MCP SDK-shaped replacements for `Tool`, `Value`, or
  `CallTool.Result`.

## Current Structure

`apple-cli-mcp` is an official-SDK-backed MCP server executable over the
canonical CLI targets. It supports stdio as the default local transport and
Streamable HTTP as an explicit `serve http` transport.

`AppleMCPServer` uses the MCP SDK server lifecycle, stdio transport, and
`StatefulHTTPServerTransport` directly. Its tool handler wiring is created by a
shared `AppleMCPServerFactory` in the adapter boundary so server runtime and
client/server tests exercise the same official SDK `ListTools` and `CallTool`
handlers. Hummingbird is used only as the HTTP host shell for Streamable HTTP:
it listens on host/port, routes the configured endpoint path, collects request
bodies, converts HTTP requests and responses, and streams SSE response chunks.
Hummingbird does not own MCP protocol, JSON-RPC dispatch, sessions, or tools.

`AppleMCPAdapter` uses MCP SDK tool/value/result types directly, validates the
requested target against the accepted target catalog, appends `--json` for
generic command execution when needed, appends `--help` for help discovery when
needed, builds bounded command catalogs by recursively reading CLI help, and
awaits the canonical `apple` executable as a subprocess. The runner and tool
handler propagate cancellation through process cleanup; unrelated requests can
progress concurrently. A catalog traverses help sequentially within its depth
and command bounds. Command catalogs are
derived from the CLI help surface and include command paths, usage lines,
subcommands, parsed option metadata, and per-command `inputSchema` objects
derived from each command's `USAGE` and `OPTIONS:` text. Those schemas identify
CLI option property names, required options visible in the usage line,
boolean flags, valued options, basic value types, CLI flag names, and CLI
argument order for client UI/validation. They do not define a separate MCP
grammar or bypass the CLI parser. Its tool responses preserve CLI stdout,
stderr, exit code, JSON envelopes, error categories, help output, and DryRun
safety behavior.

The server declares the MCP tools capability only. It does not expose MCP
resources or prompts.

MCP packages or executables translate tool requests into
`apple <target> <resource?> <action> [options]` commands.

## Current Tool Catalog

The current MCP catalog has exactly six tools:

| Tool | Behavior |
| --- | --- |
| `apple_cli_list_targets` | Returns the accepted `apple` target catalog from `AppleMCPAdapter`. |
| `apple_cli_doctor` | Runs `apple <target> doctor --json` for one accepted target and preserves permission diagnostics. |
| `apple_cli_status` | Runs `apple <target> --json` for one accepted target and returns the canonical target status envelope. |
| `apple_cli_help` | Runs `apple <target> [subcommand path] --help` for one accepted target and preserves CLI help output without appending `--json`. |
| `apple_cli_command_catalog` | Recursively runs `apple <target> [subcommand path] --help` up to bounded `maxDepth` and `maxCommands`, parses usage, subcommands, `OPTIONS:` metadata, and per-command `inputSchema` metadata, and returns a CLI-derived command catalog without appending `--json`. |
| `apple_cli_run` | Runs one accepted target with explicit CLI arguments, appends `--json` when omitted, validates the target against the 19 accepted targets, and accepts `timeoutSeconds` from 1 through 120. |

This six-tool catalog is a generic CLI adapter, not a hidden product surface.
It does not add behavior that is unavailable through `apple`. Future
per-command tools or stronger schemas may be introduced only when their schemas
are derived from the canonical CLI contract and preserve the same validation,
`DryRun` payload, stdout/stderr, exit-code, and JSON-envelope behavior.

## Key Principles

- The CLI contract is canonical.
- MCP tool names should map clearly to CLI operations or to explicit adapter
  operations over the CLI contract.
- MCP errors should preserve CLI error categories.
- MCP clients must preserve reader-facing `message` text for display, but must
  not branch on localized wording. Use CLI codes, details, exit status, and
  `DryRun` fields for logic.
- Lifecycle, configuration, and client setup are adapter concerns.
- SDK protocol, JSON-RPC, and transport mechanics are SDK concerns. This
  repository should not maintain `JSONValue`, `CLIMCPTool`, custom framing, or
  other MCP-shaped protocol clones.
- HTTP listener and request/response bridging are host-shell concerns in
  `AppleMCPServer`; they must not move into business target modules.
- Adapter payload types should be named and shaped around CLI contract data, not
  around MCP protocol mechanics already owned by the SDK.
- MCP tools may mirror CLI command names, but the CLI contract remains
  canonical.
- Expanding the target catalog expands what MCP may adapt, but it does not
  allow MCP to introduce hidden behavior or generic whole-Mac tools.

## Cross-cutting Concerns

- Client-specific MCP setup belongs in adapter docs.
- Adapter lifecycle and client setup must stay outside the core CLI contract.
- Permission wording and recovery boundaries follow
  [Permission And Wording](PermissionAndWording.md).
- Stdio remains the default transport. Streamable HTTP must be requested
  explicitly with `apple-cli-mcp serve http`.
- Streamable HTTP binds to loopback by default. Non-loopback serving must be an
  explicit opt-in and must be protected by bearer token or deployment-layer
  controls.

## Risks / Known Gaps

- MCP schemas must stay derived from CLI contracts.
- In-process SDK client/server validation covers tool listing, catalog schema
  consumption, and `apple_cli_run` safety argument preservation through official
  MCP transports and method handlers. Executable black-box stdio validation
  starts the real `apple-cli-mcp stdio` process and verifies initialize,
  `listTools`, and `callTool` through an official SDK client. Executable
  black-box Streamable HTTP validation starts the real `apple-cli-mcp serve http`
  process and verifies initialize, `listTools`, and `callTool` through
  `HTTPClientTransport`.

## Related Decisions

- [Repository Identity](RepositoryIdentity.md)
- [0003: MCP Is Adapter, Not Core](../Decisions/0003-McpIsAdapterNotCore.md)
- [0008: Direct Official Package Mechanics](../Decisions/0008-DirectOfficialPackageMechanics.md)
- [0009: MCP Streamable HTTP Uses Hummingbird](../Decisions/0009-McpStreamableHttpUsesHummingbird.md)
