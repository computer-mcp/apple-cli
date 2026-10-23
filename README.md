<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/logo/logo-dark.png">
    <img src=".github/assets/logo/logo-light.png" width="128" height="128" alt="">
  </picture>
</p>

<h1 align="center">Apple CLI</h1>

<p align="center">A local macOS CLI and MCP server for Apple apps.</p>

<p align="center">
  <a href="https://github.com/computer-mcp/apple-cli/actions/workflows/ci.yml"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/computer-mcp/apple-cli/ci.yml?branch=master&label=CI&style=flat"></a>
  <a href="Package.swift"><img alt="Swift 6.3 or newer" src="https://img.shields.io/badge/Swift-6.3%2B-orange?style=flat"></a>
  <a href="Documentation/Reference/ReleaseGuide.md"><img alt="Platform: macOS arm64" src="https://img.shields.io/badge/platform-macOS%20arm64-lightgrey?style=flat"></a>
  <a href="LICENSE"><img alt="License: Apache-2.0" src="https://img.shields.io/badge/license-Apache--2.0-blue?style=flat"></a>
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#usage">Usage</a> ·
  <a href="#targets">Targets</a> ·
  <a href="#mcp">MCP</a> ·
  <a href="#documentation">Documentation</a>
</p>

## Overview

Apple apps, from your terminal. `apple` brings Notes, Reminders, Calendar, Mail, Photos and other
Apple app and system targets to one macOS command, with structured JSON output and an optional MCP
server for local agents.

- **Script everyday workflows.** Search Notes, organize Reminders, inspect calendars, query
  Photos and work with local files.
- **Use predictable output.** JSON results, stable error codes and bounded reads make commands
  usable in scripts.
- **Connect your agent.** The MCP server exposes the same CLI capabilities through stdio or
  Streamable HTTP.

> **Alpha preview · macOS arm64.** Feature availability depends on the target, OS, account and
> permissions. See the [Release Guide](Documentation/Reference/ReleaseGuide.md) for the tested
> build environment and installation details.

## Quick look

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/terminal/terminal-dark.svg">
  <img alt="apple --version prints the version, and apple notifications preview returns the notification it would show as JSON without sending it." src=".github/assets/terminal/terminal-light.svg">
</picture>

Every command follows one shape:

~~~text
apple <target> <resource?> <action> [options]
~~~

## Install

### Build from source

Use macOS with an Xcode toolchain providing Swift 6.3 or newer and the Notes private frameworks
required by the package. From the repository root:

~~~bash
scripts/bootstrap
xcrun swift build --force-resolved-versions
.build/debug/apple --help
~~~

Rerun `scripts/bootstrap` after changing Xcode or the SDK. The declared macOS 13 deployment floor
is a build setting; runtime support requires validation on the intended OS and architecture.

### Releases

No release has been published yet. From the first release, two channels install it on macOS
arm64.

**Homebrew**, from the organization tap, which installs both executables and their runtime
libraries from the accepted GitHub release and declares the tested macOS requirement:

~~~bash
brew install computer-mcp/tap/apple-cli
apple --version
~~~

**Release archive**, built, tested and published by GitHub Actions on
[GitHub Releases](https://github.com/computer-mcp/apple-cli/releases). In the download directory,
replacing `VERSION`:

~~~bash
shasum -a 256 -c apple-cli-VERSION-macos-arm64.tar.gz.sha256
tar -xzf apple-cli-VERSION-macos-arm64.tar.gz
export PATH="$PWD/apple-cli-VERSION-macos-arm64/bin:$PATH"
apple --version
~~~

Keep the complete `bin` directory together: `apple`, `apple-cli-mcp` and any bundled Swift runtime
libraries. The [Release Guide](Documentation/Reference/ReleaseGuide.md#install-the-archive) covers
relocation, signatures and compatibility.

## Usage

Discover a target and check its readiness:

~~~bash
apple --help
apple notes --help
apple notes doctor --json
~~~

Read app data with explicit queries and limits:

~~~bash
apple notes search --query "Plan" --limit 20 --json
apple reminders lists list --json
apple calendar calendars list --json
apple photos media-items search --keyword travel --limit 20 --json
~~~

Preview a reminder before creating it. Replace `Today` with an existing list:

~~~bash
apple reminders create \
  --list Today \
  --title "Follow up" \
  --dry-run \
  --json
~~~

An explicit create request can then run with the same list and title:

~~~bash
apple reminders create --list Today --title "Follow up" --json
~~~

### Structured output

`--json` returns an envelope with `ok` and `data`. Errors use `ok: false` and a stable
`error.code`. Add `--pretty` for readable formatting. The Quick look's notification preview works
without accessing app data or sending a notification.

### Permissions and writes

Start with `apple <target> doctor --json` when a target cannot access an app or its data. Some
workflows need macOS permissions or app automation approval.

Use `--dry-run` to inspect a proposed mutation. External dispatch, destructive selections and
system operations require the specific `--allow-*` flag named by the command. `--json` controls
output; authorization comes from the requested operation and its gates. See
[Safety Gates](Documentation/Reference/SafetyGates.md) for the full contract.

## Targets

Choose a target to open its user guide:

| Workflow | Targets |
| --- | --- |
| Notes and planning | [`notes`](Documentation/Reference/Notes/UserGuide.md) · [`reminders`](Documentation/Reference/Reminders/UserGuide.md) · [`calendar`](Documentation/Reference/Calendar/UserGuide.md) · [`contacts`](Documentation/Reference/Contacts/UserGuide.md) |
| Communication | [`mail`](Documentation/Reference/Mail/UserGuide.md) · [`messages`](Documentation/Reference/Messages/UserGuide.md) · [`facetime`](Documentation/Reference/FaceTime/UserGuide.md) |
| Browsing, media and files | [`safari`](Documentation/Reference/Safari/UserGuide.md) · [`maps`](Documentation/Reference/Maps/UserGuide.md) · [`photos`](Documentation/Reference/Photos/UserGuide.md) · [`finder`](Documentation/Reference/Finder/UserGuide.md) |
| Documents | [`pages`](Documentation/Reference/Pages/UserGuide.md) · [`numbers`](Documentation/Reference/Numbers/UserGuide.md) · [`keynote`](Documentation/Reference/Keynote/UserGuide.md) |
| System utilities | [`print`](Documentation/Reference/Print/UserGuide.md) · [`clipboard`](Documentation/Reference/Clipboard/UserGuide.md) · [`notifications`](Documentation/Reference/Notifications/UserGuide.md) · [`intelligence`](Documentation/Reference/Intelligence/UserGuide.md) · [`tcc`](Documentation/Reference/TCC/UserGuide.md) |

Coverage varies by target. Pages focuses on metadata and export; Keynote supports native slide
reads and PDF export alongside cached previews. Numbers supports reads, exports and single-cell
writes. Safari Tab Group mutations and some Notes media workflows return an explicit unsupported
result. Read the [Capability List](Documentation/Architecture/CapabilityList.md) for the supported
scope of each target.

## MCP

`apple-cli-mcp` connects local MCP clients to the `apple` CLI. Configure your client with the full
path to the executable and `stdio` as its argument:

| Client setting | Value |
| --- | --- |
| Command | `/path/to/extracted-release/bin/apple-cli-mcp` |
| Arguments | `stdio` |

For Homebrew, get the full command path with `echo "$(brew --prefix)/bin/apple-cli-mcp"`. To start
the server directly:

~~~bash
apple-cli-mcp stdio
~~~

The adapter finds `apple` beside its own executable. Keep both programs and the bundled runtime
libraries together. For a separate CLI directory, set `APPLE_CLI_BIN_DIR` to the directory
containing `apple`.

Streamable HTTP is also available on loopback:

~~~bash
apple-cli-mcp serve http --host 127.0.0.1 --port 8765 --path /mcp
~~~

The same target permissions and mutation gates apply through MCP. See
[MCP setup](Documentation/Reference/AppleCLIUserGuide.md#mcp-setup) for discovery, remote access and
authentication.

The source tree also includes a [Reminder Creator skill](skills/reminder-creator/SKILL.md) for
modeling reminder content, lists, sections and shopping workflows. See its
[shopping reference](skills/reminder-creator/references/shopping-list.md) for scenario guidance.

## Requirements

- macOS on arm64, the tested runtime; see the [Release Guide](Documentation/Reference/ReleaseGuide.md).
- To build: an Xcode toolchain with Swift 6.3 or newer and the Notes private frameworks the
  package requires.
- Per target: the macOS permissions or app automation approval its workflows need.

## Documentation

| Start here | What it covers |
| --- | --- |
| [User guide](Documentation/Reference/AppleCLIUserGuide.md) | Discovery, output, permissions, MCP and workflow safety |
| [Target guides](Documentation/README.md#target-guides) | User and developer documentation for every target |
| [Release guide](Documentation/Reference/ReleaseGuide.md) | Installation, source builds and runtime requirements |
| [Release reference](Documentation/Reference/Release.md) | Version sources, candidate acceptance, CI publication and evidence |
| [Version rules](VERSIONING.md) | Organization version rules and repository acceptance requirements |
| [Architecture](Documentation/Architecture/README.md) | CLI ownership, implementation mechanisms and MCP boundaries |
| [Security](SECURITY.md) | Vulnerability reporting |

## Contributing

~~~bash
scripts/bootstrap
xcrun swift test --force-resolved-versions
scripts/validate-public-content
~~~

The default suite uses fixtures and controlled backends. Real app behavior, accounts and OS
compatibility need separate validation; the
[Release Guide](Documentation/Reference/ReleaseGuide.md#build-from-source) describes the available
integration checks. See the [contributor guide](CONTRIBUTING.md) for repository conventions.

## License

Copyright (c) 2026 Xudong Xu. Licensed under the [Apache License 2.0](LICENSE). Third-party
components retain their own licenses; see [Third-Party Notices](THIRD_PARTY_NOTICES.md).
