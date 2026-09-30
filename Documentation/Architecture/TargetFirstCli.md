# Target-First CLI

## Scope / Purpose

This document defines the current CLI product shape and target ownership model.

## Command Shape

The canonical executable product is `apple`.

```text
apple <target> <resource?> <action> [options]
```

The primary resource is omitted when it would repeat the target:

- `apple notes list`
- `apple reminders create`
- `apple messages send`
- `apple maps open`
- `apple clipboard read`
- `apple notifications send`
- `apple intelligence doctor`

Non-primary resources stay explicit:

- `apple notes accounts list`
- `apple calendar events list`
- `apple contacts groups members`
- `apple mail messages read`
- `apple finder items search`
- `apple numbers tables read`
- `apple keynote slides export`
- `apple print jobs submit`

## Current Structure

`AppleCLI` owns process entry and root command composition only. Each
`<Target>CLI` module directly imports `swift-argument-parser` and owns the
typed target/resource/action command grammar for its target. Each `<Target>CLI`
also owns backend behavior, target-local validation, identity rules, and
target-local safety policy. `Utility` owns repository contract mechanics only:
JSON envelopes, exit codes, diagnostics, DryRun preview, small shared
option groups, and bounded process execution helpers. Synchronous CLI execution
uses native `Process` and drains both output pipes without scheduling Swift
tasks. Asynchronous adapters await the official `swift-subprocess` API.
`CLIOptions` is a compatibility execution context for target-local backends; it
is not a parser, command descriptor model, or public grammar surface.

Command-to-backend mapping is documentation truth, not runtime grammar. Durable
mapping tables may live in `Documentation/Reference/` to show how target-local
CLI commands map to SDEF entries, public frameworks, file APIs, subprocesses,
or system APIs. Those tables must not become a shared command registry,
descriptor framework, parser facade, or bridge layer.

Official Swift packages are used directly at their ownership boundary, the same
way `Foundation` is used directly. Do not hide `ArgumentParser` behind a local
target command runtime, parser facade, descriptor framework, or generic bridge.
The `apple` executable command tree is synchronous: `AppleCLI` and each
`<Target>CLI` command type use `ParsableCommand` with synchronous `run()`
methods. Do not convert the local CLI grammar to `AsyncParsableCommand` merely
to share shape with adapters or future async work. `apple-cli-mcp` may remain
async because it owns server lifecycle and transport, but it is an adapter over
the CLI contract, not the production grammar for local Apple app commands.

Accepted targets:

- `notes`
- `calendar`
- `reminders`
- `contacts`
- `mail`
- `messages`
- `maps`
- `finder`
- `numbers`
- `pages`
- `keynote`
- `facetime`
- `safari`
- `photos`
- `print`
- `clipboard`
- `notifications`
- `intelligence`
- `tcc`

The package executable products are exactly:

- `apple`
- `apple-cli-mcp`

There are no legacy `apple-*` executable products or aliases.

## Target Boundaries

Each accepted target owns its target architecture document for backend design,
command-specific safety policy, diagnostics, and capability expansion details.
Cross-target architecture documents summarize and link; they must not become
the place where one target's detailed design is mixed with another target's
design.

- `notes` owns Notes accounts, folders, Smart Folder metadata, tag
  listing/membership, attachment metadata/add/remove/export, link metadata/web URL
  add/update/remove/app URL add/update/remove/file URL add/update/remove, note link add/update/remove/paragraph note-link add/remove,
  body structure, note state, note list/search/read, and safety-gated note writes.
- `calendar` owns calendars, events, occurrences, availability, statistics,
  iCalendar export, and event mutation.
- `reminders` owns reminder lists, reminder read/search, explicit-ID and
  filter-bound completion flows, cleanup-completed, and reminder lifecycle
  mutation.
- `contacts` owns Contacts.framework records, duplicate detection, groups,
  vCard import/export, and group membership changes.
- `mail` owns accounts, mailboxes, message metadata, bounded body search,
  explicit bounded body preview, reply/forward preview, draft,
  reply-draft/forward-draft, send, move, archive, and delete.
- `messages` owns local Messages read/search and safety-gated send flows.
- `maps` owns place search/read, query or coordinate directions preview, and
  safety-gated `maps:` URL open.
- `finder` owns path-bounded Finder/app-bound file workflows.
- `numbers`, `pages`, and `keynote` own path-bounded iWork document workflows,
  QuickLook/package export paths, and the focused iWork reads or writes already
  proven inside their target modules.
- `facetime` owns contact resolution, call preparation, and call start.
- `safari` owns Safari windows/tabs/page reads, profile, snapshot window, and
  Tab Group read-only snapshot reads including snapshot window mappings, browser state actions,
  safety-gated tab/Reading List mutations, strong-gated SDEF commands,
  and proof-failed hidden/private entries.
- `photos` owns Photos library discovery, read-only snapshot queries,
  albums/folders/media items, import/export/report with edited-render and
  Live Photo movie export, derivative preview fallback, and JPEG conversion,
  metadata sidecar/EXIF planning, target-local SDEF actions,
  slideshow/spotlight, and strong-gated Swift eval hooks or post-commands.
- `print` owns local printer/job inspection and print submit/cancel.
- `clipboard` owns pasteboard type/read/write/clear.
- `notifications` owns this tool's notification preview/send surface through a
  target-local legacy CLI delivery backend; direct `UserNotifications` probing
  is disabled for the unbundled SwiftPM CLI process.
- `intelligence` owns Apple Intelligence workflows as a Swift target-local
  implementation. Its current production line is a local-cache path; the
  current backend uses macOS eligibility cache files and `eligibilityd`. It
  includes support/doctor/verify,
  risk-flag-gated answer/comprehensive plist enablement, optional eligibility
  country cache rewrite, `reset-cache` with optional kickstart, rollback,
  unlock, one-shot `lldb` recompute, optional LaunchDaemon service
  install/uninstall.
- `tcc` owns TCC service catalog, current-process identity diagnostics,
  read-only database inspection, target-assisted doctor mapping, official
  `tccutil reset`, explicit permission preflight/request helpers, and
  gated private TCC database/framework write diagnostics.

## Constraints

- Do not introduce `AppleBridgeCore`.
- Do not make MCP the canonical behavior surface.
- Do not add legacy `apple-*` executable aliases.
- Do not introduce cross-app business abstractions such as `AppleBridge`,
  `BridgeProtocol`, `AppleResource`, `AppCapability`, or generic CRUD models.
- Do not introduce a common permission abstraction that hides target-specific
  backend semantics.
- Shared permission wording helpers may standardize reader-facing prose, but
  they must not become shared permission backends or hide target-local
  authorization/request semantics.
- Do not introduce a local generic `ArgumentParser` replacement such as
  `CLITargetRuntime`, `CLITargetLeafCommand`, `CLITargetDescriptor`,
  `TargetCommandBridge`, or a command descriptor framework.
- Do not turn reference command/backend mappings into executable command
  registration, cross-target dispatch, or a target capability registry.
- Do not route user input through a cross-target parser model. After
  `ArgumentParser` has parsed a command, any conversion into `CLIOptions` must
  remain a target-local implementation detail, not a shared command facade.
- Do not make `apple` target commands async unless a concrete target backend
  requires async execution and the app automation/threading behavior has been
  validated. In-process Apple automation should not be pushed into Swift async
  executors as a convenience refactor.

## Key Principles

- CLI behavior is the canonical contract.
- MCP is an adapter over the CLI contract. External agents use CLI help,
  manuals, JSON output, and `doctor`.
- Target boundaries follow Apple app/domain/system capability boundaries.
- `swift-argument-parser` command and property-wrapper types may appear directly
  in target modules; this is intentional direct use of an official package.
- `apple` target commands use synchronous `ParsableCommand`; async execution is
  reserved for true async boundaries such as MCP server lifecycle.
- Shared abstractions require repeated implementation pressure visible in real
  target code.
- Small duplication across targets is acceptable when it preserves ownership.
- `finder` is not a shell executor, recursive file processor, or general
  content-write surface.
- `messages` does not create groups or expose generic Messages automation.
- iWork targets are bounded to their own document or presentation paths.
- `print` submit/cancel are high-risk actions and require `--dry-run` preview
  support plus `--allow-external-dispatch` for execution.
- `clipboard` is a sensitive system domain target, not arbitrary app
  automation.
- `notifications` must not claim global notification history access.
- `intelligence` must not silently execute `curl`, external release binaries,
  `lldb` attachment, LaunchDaemon persistence, or system cache mutation without
  the target-local `--allow-*` risk flags.

## Cross-cutting Concerns

- TCC permission failures must be explicit.
- Read/search operations should arrive before destructive mutations.
- Output formats must be stable for scripts and adapters.
- `Utility` must not include target-local business logic for any Apple
  app/domain/system target.
- Permission and safety wording follows
  [Permission And Wording](PermissionAndWording.md).

## Risks / Known Gaps

- Messages generic chat automation, new group creation, and oversized
  conversation sends need focused identity policy before support.
- Deep iWork content extraction, app-native export beyond implemented
  QuickLook-backed/package paths, and broader writes need validation in
  target-local implementations.
- Other write/external actions need focused identity and DryRun validation
  before support.
- Mail attachment extraction/save needs focused privacy, size, file-type,
  output-path, and DryRun design before support.
- CLI contract details are owned by `CliContract.md`.

## Related Decisions

- [Repository Identity](RepositoryIdentity.md)
- [0001: No AppleBridgeCore](../Decisions/0001-NoAppleBridgeCore.md)
- [0002: CLI Contract Is Canonical](../Decisions/0002-CliContractIsCanonical.md)
- [0003: MCP Is Adapter, Not Core](../Decisions/0003-McpIsAdapterNotCore.md)
- [0015: DryRun And Risk Flag Safety Model](../Decisions/0015-DryRunAndRiskFlagSafetyModel.md)
- [0007: Unified Apple Command Tree and Official Swift Mechanics](../Decisions/0007-UnifiedAppleCommandTreeAndOfficialSwiftMechanics.md)
- [0008: Direct Official Package Mechanics](../Decisions/0008-DirectOfficialPackageMechanics.md)
- [0013: Options Safety Naming And Risk Flags](../Decisions/0013-OptionsSafetyNamingAndRiskFlags.md)
- [0014: TCC Target Surface And Safety Gates](../Decisions/0014-TccTargetSurfaceAndSafetyGates.md)
