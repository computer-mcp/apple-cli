# Apple CLI User Guide

## Scope

This guide describes ordinary use of the canonical `apple` executable. It is a
global CLI guide, not architecture truth and not a target-specific manual.
Target-specific usage lives in `Documentation/Reference/<Target>/UserGuide.md`.

The [apple-cli Source-Visible License](../../LICENSE) limits official releases to
personal, non-commercial use. Commercial use, source builds, modifications and
redistribution require prior written permission from the copyright holder.

Use CLI help as the first discovery surface:

```bash
apple --help
apple <target> --help
apple <target> <resource?> <action> --help
```

For the copyright holder or developers with written permission to build, run
from a development checkout with:

```bash
Scripts/bootstrap
swift run apple --help
swift run apple <target> --help
```

Bootstrap prepares local Notes link inputs from the selected SDK. See the
[Release Guide](ReleaseGuide.md) for requirements, packaged installation and
the distinction between deployment floor and tested runtime compatibility.

For an authorized staged release build from that checkout, use:

```bash
swift build -c release
.build/release/apple --help
```

## Output

Use `--json` for scripts, agents, and adapters:

```bash
apple notes search --query Plan --json
```

Successful JSON returns `ok: true`; failures return `ok: false` with a stable
`error.code`. Treat `--json` only as an output mode. It never authorizes a
write, external action, permission prompt, debug attach, or system mutation.

Use `--pretty` only for human inspection when `--json` is active.

## Discovery

Start with `apple --help` to see accepted targets. Then inspect target help:

```bash
apple notes --help
apple reminders --help
apple photos --help
```

The accepted targets are:

```text
notes calendar reminders contacts mail messages maps finder numbers pages
keynote facetime safari photos print clipboard notifications intelligence tcc
```

Use [Capability List](../Architecture/CapabilityList.md) for the target-level
accepted capability index.

MCP clients should use the adapter discovery tools instead of hard-coding target
subcommands. `apple_cli_list_targets` returns the accepted target catalog,
`apple_cli_status` runs `apple <target> --json`, and `apple_cli_help` reads
`apple <target> [subcommand path] --help` without appending `--json`.
`apple_cli_command_catalog` returns a bounded command tree parsed from that CLI
help surface, including command paths, usage lines, subcommands, and CLI-derived
option metadata. Each catalog entry also includes a CLI-derived `inputSchema`
for client UI and validation: option properties, required options visible in the
usage line, boolean flags, valued options, basic value types, CLI flag names,
and argument order. These schemas describe how to form CLI arguments; they do
not authorize writes or replace the target-local CLI parser.
Mutating and external-action workflows still go through `apple_cli_run` and the
same target-local `--dry-run` and `--allow-*` rules as the CLI.

## Diagnostics

Use `doctor` for setup, dependency, permission, implementation mechanism, and
readiness diagnostics:

```bash
apple notes doctor --json
apple tcc doctor --for-target reminders --json
apple intelligence doctor --json
```

`doctor` may return remediation hints, but it is not the workflow guide. Use
command help, this guide, target user guides, and target developer guides for
operation order.

## Safe Reads First

Prefer read, search, list, preview, or report commands before mutations unless
the user explicitly asks for a write or external action.

Examples:

```bash
apple notes search --query Plan --json
apple calendar events list --from 2026-01-01 --to 2026-01-02 --json
apple reminders lists list --json
apple contacts duplicates --field email --json
apple mail messages body-preview --mailbox Inbox --id MESSAGE_ID --max-bytes 20000 --json
apple safari pages read --window-index 1 --tab-index 1 --include text --max-bytes 20000 --json
apple photos media-items search --keyword travel --limit 20 --json
apple finder items metadata --path Package.swift --json
```

## DryRun And Risk Flags

Use `--dry-run` to preview a mutation or external action before side effects.
The command runs parsing, normalization, target-local resolution, and
validation, then returns a `DryRun` payload:

```bash
apple reminders complete --id REMINDER_ID --dry-run --json
```

Ordinary explicit mutations can execute directly:

```bash
apple reminders complete --id REMINDER_ID --json
```

Commands with destructive selection, external dispatch, artifact writes,
persistent state, or system risk require the concrete `--allow-*` flag named by
the target. Do not add an allow flag unless the user explicitly authorized that
risk.

## Fixed-Risk Actions

Some fixed system-domain mechanisms use explicit `--allow-*` risk flags instead
of ordinary mutation execution. These flags acknowledge a named risk class; they are not generic
`--yes` flags.

Examples:

```bash
apple intelligence enable --patch-scope comprehensive --allow-system-cache-write --json
apple intelligence recompute --allow-debug-attach --json
apple intelligence service install --allow-debug-attach --allow-persistent-service --json
apple tcc access request ScreenCapture --allow-tcc-prompt --json
apple tcc reset Reminders com.example.App --allow-tcc-reset --json
```

When the CLI returns `unsafe_mutation_refused`, do not bypass it with a direct
mechanism, AppleScript, database write, shell command, or framework call.

## Permission Recovery

If a command fails with `permission_denied`, stop and run the target's
diagnostic command:

```bash
apple <target> doctor --json
```

For TCC-specific investigation, prefer:

```bash
apple tcc doctor --for-target <target> --json
```

After the user grants a permission in System Settings or an app prompt, rerun
`doctor --json`, then rerun the original read or preview command.

## Sensitive Output

Mail bodies, note bodies, message text, Safari page text/source, clipboard
content, local file paths, and Photos metadata can be sensitive. Prefer
metadata, bounded previews, and explicit user intent. Do not echo full
sensitive content unless the user asks for it and the command surface
explicitly returns it.

## Target Guides

Detailed target usage belongs under `Documentation/Reference/<Target>/`:

- [Notes](Notes/UserGuide.md)
- [Calendar](Calendar/UserGuide.md)
- [Reminders](Reminders/UserGuide.md)
- [Contacts](Contacts/UserGuide.md)
- [Mail](Mail/UserGuide.md)
- [Messages](Messages/UserGuide.md)
- [Maps](Maps/UserGuide.md)
- [Finder](Finder/UserGuide.md)
- [Numbers](Numbers/UserGuide.md)
- [Pages](Pages/UserGuide.md)
- [Keynote](Keynote/UserGuide.md)
- [FaceTime](FaceTime/UserGuide.md)
- [Safari](Safari/UserGuide.md)
- [Photos](Photos/UserGuide.md)
- [Print](Print/UserGuide.md)
- [Clipboard](Clipboard/UserGuide.md)
- [Notifications](Notifications/UserGuide.md)
- [Intelligence](Intelligence/UserGuide.md)
- [TCC](TCC/UserGuide.md)
