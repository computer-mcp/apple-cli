# Changelog

## 0.1.0-alpha.4 — Unreleased

### Breaking

- Keynote: `slides export` is replaced by `previews list` and `previews export`;
  `slides list` reads slides through Keynote scripting and needs Automation
  access.
- Notifications: `send` requires notification authorization and reports native
  rejection as an error; request IDs use the `apple-cli:` namespace.
- Calendar: exporting recurring or detached events returns unsupported, invalid
  date-only values are rejected, and mutations need full Calendar access.
- Clipboard: `read` returns bounded text; typed data moves to `items read` and
  `items write`.
- MCP tool schemas change with these command paths.

### Added

- Calendar sources, calendar create, read, update and delete, and custom
  recurrence conditions.
- Maps saved collections, collection places and Favorites reads; directions
  `calculate` and `eta`.
- Notifications settings, authorization request, and pending and delivered
  queries and removal.
- Clipboard typed items, byte caps, change-count preconditions and current-host
  writes.
- Reminders rich notes (`notes read`, `notes format`, `notes list-style`) and
  Smart List reads; Keynote native PDF export.

### Fixed

- Notes and Reminders edits preserve content, titles, lifecycle and subtask and
  template data, with native readback verification.
- Result fidelity for Numbers cells, Mail, Finder and TCC.

### Development

- `apple` embeds an Info.plist with the bundle identifier
  `io.github.computer-mcp.apple-cli` and Calendar usage descriptions.
- Shared framework header generator with versioned input manifests; opt-in
  native fixture validation, documented and shipped in release archives.
- swift-subprocess 1.0, swift-argument-parser 1.8.2 and swift-http-types 1.8.0.

Known limitation: Maps `collections places create` awaits native end-to-end
validation.

## 0.1.0-alpha.3 — 2026-10-02

First public alpha of the target-first `apple` CLI and optional `apple-cli-mcp`
adapter for macOS.

- Nineteen typed Apple app and system targets, structured JSON, bounded reads,
  target-owned diagnostics and explicit mutation or external-action rules.
- CLI-derived MCP tools over stdio and Streamable HTTP, with bounded subprocess
  execution, cancellation and HTTP session limits.
- Self-contained macOS arm64 archives with bundled Swift runtime libraries,
  source and dependency provenance, checksums and executable acceptance records.
- GitHub Actions builds and accepts the tagged archive before publishing the
  same files. Draft assets are uploaded and verified by their release identity.
- Organization Homebrew distribution and weekly dependency update pull requests.

Known limitation: Notes body structure summaries can underreport strikethrough
formatting on existing notes. A zero count does not prove that the note has no
strikethrough text; inspect the HTML export for format-sensitive workflows.
`notes read` returns plain text.

Compatibility and per-target limitations are described in the
[Release Guide](Documentation/Reference/ReleaseGuide.md) and target manuals.

## 0.1.0-alpha.2 — 2026-10-01

Tagged only; the release workflow did not publish a GitHub Release for this
version. Its contents shipped in 0.1.0-alpha.3.

- Nineteen typed Apple app and system targets, structured JSON, bounded reads,
  target-owned diagnostics and explicit mutation or external-action rules.
- CLI-derived MCP tools over stdio and Streamable HTTP, with bounded subprocess
  execution, cancellation and HTTP session limits.
- Self-contained macOS arm64 archives with bundled Swift runtime libraries,
  source and dependency provenance, checksums and executable acceptance records.
- GitHub Actions builds and accepts the tagged archive before publishing the
  same files. Draft release lookup uses the release identity for creation and
  continuation.
- Organization Homebrew distribution and weekly dependency update pull requests.

Known limitation: Notes body structure summaries can underreport strikethrough
formatting on existing notes. A zero count does not prove that the note has no
strikethrough text; inspect the HTML export for format-sensitive workflows.
`notes read` returns plain text.

Compatibility and per-target limitations are described in the
[Release Guide](Documentation/Reference/ReleaseGuide.md) and target manuals.

## 0.1.0-alpha.1 — 2026-10-01

Tagged only; the release workflow did not publish a GitHub Release for this
version. Its contents shipped in 0.1.0-alpha.3.

- Nineteen typed CLI targets, with target-owned diagnostics, JSON output,
  identity resolution and mutation or external-action safety rules.
- CLI-derived MCP tools over stdio and Streamable HTTP, with bounded process
  execution and cancellation propagation.
- HTTP session limits include concurrent initializations; failed initialization
  and session closure release capacity.
- MCP execution responses contain command results without duplicating request
  arguments. Error output retains categories and recovery metadata without raw
  exception descriptions or app-content diagnostics.
- Photos hooks use bounded input/output drainage and process cleanup; invalid
  HTTP host configuration is rejected before server startup.
- Asynchronous subprocesses preserve buffered output after child exit under
  concurrent load, with bounded timeout, cancellation and cleanup handling.
- Photos CSV dumps share the JSON record field names; eligibility recompute
  refreshes the daemon's current inputs.
- SDK-derived local Notes link inputs generated by `Scripts/bootstrap`.
- A single product version, clean help/version exits, and colocated or explicit
  CLI installation for the adapter.
- Default tests use fixtures and mocks; host Notes reads require explicit
  integration-test opt-in.
- Release packaging bundles required Swift compatibility runtime libraries,
  strips development debug symbols, checks staged files for local paths, and
  records source, dependency, toolchain and binary provenance alongside SHA-256
  checksums.
- Version-tag GitHub Actions builds and accepts the actual archive before
  publishing the same files; prerelease versions retain their prerelease status.
- Notes readiness diagnostics distinguish missing APIs from model-backed
  dynamic accessors that require operation-context verification.

Known limitation: Notes body structure summaries can underreport strikethrough
formatting on existing notes. A zero count does not prove that the note has no
strikethrough text; inspect the HTML export for format-sensitive workflows.
`notes read` returns plain text.

Compatibility and per-target limitations are described in the
[Release Guide](Documentation/Reference/ReleaseGuide.md) and target manuals.
