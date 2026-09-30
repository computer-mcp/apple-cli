# MCP Streamable HTTP Uses Hummingbird

## Status

Accepted

## Context

`apple-cli-mcp` currently exposes a stdio MCP server over the canonical `apple`
CLI contract. Stdio is the right default for local MCP clients, but it does not
cover remote-capable MCP clients or tunnel/proxy deployments.

The official MCP Swift SDK provides `StatefulHTTPServerTransport`, which owns
MCP Streamable HTTP session management, SSE response streaming, and session
termination behavior. It is framework-agnostic and still requires an HTTP server
framework to listen on host/port and convert native HTTP requests and responses.

The repository needs an HTTP host boundary without turning the package into a
general Web application.

## Decision

`apple-cli-mcp` supports two transports:

- stdio, as the default local MCP transport
- Streamable HTTP, as an explicit `serve http` transport

Streamable HTTP uses Hummingbird as the HTTP host framework. Hummingbird owns
only HTTP listener, routing, middleware, request body collection, response
conversion, and streaming response output.

MCP protocol, JSON-RPC dispatch, session identifiers, SSE event formatting,
resumability, and transport semantics remain owned by the official MCP Swift SDK
through `StatefulHTTPServerTransport`.

`AppleMCPAdapter` remains the tool adapter over the canonical `apple` CLI
contract. HTTP mode must not add tools or behavior unavailable through `apple`.

The repository does not use Vapor for this boundary and does not maintain a
custom bare-NIO HTTP server for production MCP HTTP transport.

## Consequences

- `apple-cli-mcp` remains the only MCP executable product.
- Existing stdio MCP clients continue to work without configuration changes.
- HTTP deployment becomes an adapter concern, not a core CLI concern.
- Hummingbird is scoped to `AppleMCPServer`; business target modules do not depend
  on it.
- Non-loopback HTTP serving must be explicit and protected by bearer token or an
  equivalent deployment-layer control.
- CLI JSON envelopes, exit codes, stdout/stderr, `DryRun`, and allow-flag
  mutation safety flows remain canonical and unchanged.
- Tests must include executable black-box coverage for both stdio MCP and HTTP
  MCP behavior.

## Alternatives Considered

- Keep stdio only. This preserves local MCP support but does not satisfy remote
  MCP usage.
- Use Vapor. Vapor can host the endpoint, but it is heavier than needed and
  pulls the package toward Web application architecture.
- Write a bare NIO HTTP server. This gives full control but makes the repository
  own HTTP request parsing, streaming response writing, lifecycle, and
  backpressure glue.
- Use `StatelessHTTPServerTransport`. It is simpler but does not provide the
  full session and SSE behavior wanted for the HTTP target state.

## Related Documentation

- Date: 2026-05-13
- Related docs:
  - [MCP Adapter Boundary](../Architecture/McpAdapterBoundary.md)
  - [CLI Contract](../Architecture/CliContract.md)
  - [Direct Official Package Mechanics](0008-DirectOfficialPackageMechanics.md)
