# Changelog

## Unreleased

- Adopt the Computer MCP Swift SDK fork at `0.13.1-computer-mcp.1`. MCP requests
  containing integers outside the signed `Int` range, including `_meta` and
  numeric tool arguments, now return JSON-RPC parse error `-32700` before
  adapter dispatch. In-range integers retain exact values and existing tool
  validation bounds.
- Align Swift dependency requirement kinds with the organization versioning
  policy and use the shared swift-subprocess `1.0.2` baseline.
