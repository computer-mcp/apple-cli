# Changelog

## Unreleased

- Adopt the [Computer MCP Swift SDK fork `0.13.2-computer-mcp.1`](https://github.com/computer-mcp/swift-sdk/blob/0.13.2-computer-mcp.1/FORK.md).
  Undecodable params, including integers outside the signed `Int` range in
  `_meta` and numeric tool arguments, return JSON-RPC `-32602` with the request's
  own id before adapter dispatch. Invalid JSON returns `-32700` with a null id;
  invalid requests return `-32600` with a readable id or a null id.
  Notifications receive no reply, and undecodable responses never take a
  request route. HTTP decode errors complete the carrying POST with typed id
  routing; HTTP batches receive `-32600`, and undecodable initialization params
  create no session. In-range integers retain exact values and existing tool
  validation bounds.
- Align Swift dependency requirement kinds with the organization versioning
  policy and use the shared swift-subprocess `1.0.2` baseline.
