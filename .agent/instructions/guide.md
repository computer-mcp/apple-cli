---
description: Route apple-cli changes through its architecture documents and keep each command target independent.
---
# apple-cli Agent Guide

## Task Route

- Before changing versions, dependencies, packaging or release workflows, read
  `VERSIONING.md` and `Documentation/Reference/Release.md`, and use the release
  reference's check entry points.
- Before changing a command target or the CLI contract, read the relevant
  document in `Documentation/Architecture/`; the target catalog is in
  `RepositoryIdentity.md` and `TargetFirstCli.md`, the accepted capabilities in
  `CapabilityList.md`. Target-specific architecture lives in
  `Documentation/Architecture/<Target>/` and target usage in
  `Documentation/Reference/<Target>/`.
- For agent integration and usage guidance, update
  `Documentation/Architecture/CliContract.md` and
  `Documentation/Reference/AppleCLIUserGuide.md`.

## Implementation Boundary

- Each `<Target>CLI` module owns its typed `swift-argument-parser` command
  tree, target-local validation, behavior, diagnostics, and mutation or
  external-action safety policy. `AppleCLI` only composes the root `apple`
  command, and `apple-cli-mcp` is an adapter over the CLI contract.
- `AppleMCPServer` and `AppleMCPAdapter` use the official MCP Swift SDK
  directly; business modules do not import MCP.
- SwiftPM target and module names use Swift identifier style, such as
  `NotesCLI`. The products stay `apple` and `apple-cli-mcp`, and command
  targets stay lowercase under `apple`, such as `apple notes`.
- External projects are inputs for target-local reuse decisions, never this
  repository's architecture truth.
