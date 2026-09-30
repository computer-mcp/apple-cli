# Repository Identity

## Scope / Purpose

`apple-cli` is a macOS SwiftPM package that provides a scriptable,
target-first command line suite for local Apple app, Apple domain, and accepted
system domain data and workflows.

Its canonical GitHub repository identity is `computer-mcp/apple-cli`.
The organization owns the product namespace; this identity does not change
target ownership or the CLI/MCP boundary.

The canonical executable product is `apple`. Its command contract is:

```text
apple <target> <resource?> <action> [options]
```

The optional adapter executable is `apple-cli-mcp`. It is an adapter over the
canonical CLI contract and does not own behavior.

## Target Catalog

The accepted target catalog is:

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

Each target owns its local command surface, backend boundary, diagnostics,
permission handling, identity rules, and mutation or external-action safety
policy.

## Current Structure

The package exposes two executable products:

- `apple`
- `apple-cli-mcp`

`AppleCLI` is the single command entry point and root command composer. Each
`<Target>CLI` module uses `swift-argument-parser` directly for its typed
target/resource/action grammar and owns target-local implementation. `Utility`
owns repository contract mechanics such as JSON envelopes, exit codes,
diagnostics, `DryRun` preview mechanics, small shared option groups, and shared
bounded subprocess execution. Synchronous CLI callers use native `Process`
execution with independent pipe drainage; asynchronous adapter callers await
the official `swift-subprocess` API with cancellation and deadline handling.
`CLIOptions` remains only as a compatibility execution context for target-local
backend dispatch; it is not the production parser or command grammar.

Official Swift packages are direct dependencies at their ownership boundary,
not hidden behind local SDK-shaped facades. `ArgumentParser` is used directly by
target command types. The MCP Swift SDK is used directly by the MCP
server/adapter layer.

Implemented target capabilities:

- `notes`: Notes.app accounts/folders/smart folder metadata/tags/attachment
  metadata/add/remove/export/link metadata/web URL add/update/remove/app URL
  add/update/remove/file URL add/update/remove/note link add/update/remove/paragraph note-link add/remove/body structure/note
  state/list/search/read plus safety-gated create/import markdown/update/append/delete/tag
  membership.
- `calendar`: EventKit read/search/occurrences/availability/statistics plus
  safety-gated iCalendar export and event create/update/delete with
  attendee metadata, relative/absolute alarms, and recurrence rules.
- `reminders`: ReminderKit read/search, reminder/list lifecycle mutations,
  visible URL/link cards, file/image attachments, tags, sections, subtasks,
  urgent reminder state, shared assignment, standard/shopping list type, list
  pinning, list sorting style, list order, list groups, custom Smart List
  create/update/delete/convert, and read-only SQLite enrichment/doctor paths.
- `contacts`: Contacts.framework search/read/duplicate/group-list/member-read,
  vCard export/import, contact create/update/delete, explicit-ID bulk delete,
  query-bound delete, and group membership mutation paths.
- `mail`: Mail.app accounts/mailboxes/list/unread/search/read metadata,
  bounded body search, explicit body preview, reply/forward preview, and
  safety-gated draft/reply-draft/forward-draft/send/move/archive/delete.
- `messages`: read-only local Messages database conversations/messages
  list/search/read plus safety-gated iMessage send, existing-chat
  conversation send, and explicit-recipient send-many.
- `maps`: CoreLocation-backed place search/read, coordinate-aware directions
  preview, and safety-gated Maps open.
- `finder`: path-validated item list/search/metadata plus safety-gated
  open/reveal/tag/move/trash/delete/write-text/overwrite-text. Delete and
  overwrite-text are limited to one regular file; write-text is create-only.
- `numbers`: path-bounded document metadata, sheets list, tables read,
  safety-gated table CSV/TSV export, single-cell table text write,
  document open, and QuickLook PDF/thumbnail/package export.
- `pages`: path-bounded document metadata, safety-gated document open, and
  QuickLook PDF/thumbnail/package export.
- `keynote`: path-bounded presentation metadata, QuickLook-backed slide list,
  safety-gated slide image export, presentation open, and QuickLook
  PDF/thumbnail/package export.
- `facetime`: Contacts-backed contact resolve, call prepare, and
  safety-gated call start.
- `safari`: Safari.app windows/tabs/page reads, profile, snapshot window, and
  Tab Group read-only snapshot reads including snapshot window mappings, state-action tab
  select/open/navigate and web search, safety-gated tab close and Reading
  List add, strong-gated JavaScript/email/bookmarks/extensions/privacy-report
  SDEF actions, and proof-failed hidden/private entries.
- `photos`: Photos library discovery, read-only SQLite snapshot media
  list/search/read/query, target-local SDEF album/folder/media item actions,
  selection, import/export with edited-render and Live Photo movie export,
  derivative preview fallback, and JPEG conversion, export reports,
  sidecar/EXIF planning, slideshow/spotlight, and strong-gated Swift eval hooks
  and post-commands.
- `print`: CUPS-backed printer/job inspection plus safety-gated
  submit/cancel.
- `clipboard`: NSPasteboard type/read/write/clear with DryRun preview for
  mutation.
- `notifications`: local notification preview/send for notifications created by
  this tool, with DryRun preview for send.
- `intelligence`: Apple Intelligence workflows, currently implemented as a
  Swift-owned local-cache path. The current backend uses macOS eligibility
  cache files and `eligibilityd`. It includes
  support/doctor/verify,
  risk-flag-gated answer/comprehensive plist enablement, optional eligibility
  country cache rewrite, `reset-cache` with optional kickstart, rollback,
  unlock, one-shot `lldb` recompute, optional LaunchDaemon service
  install/uninstall. Runtime `curl`, third-party script execution, silent debug
  attach, default persistence, unpinned external artifact execution, and
  beta-only system spoofing experiments are rejected.
- `tcc`: TCC service catalog, current-process identity diagnostics, read-only
  user/system database inspection, target-assisted doctor mapping, official
  `tccutil reset`, public framework preflight/request helpers, and `DryRun`-
  plus-risk-flag-gated private database/framework write diagnostics. Silent
  permission grants and broad private TCC mutation are rejected.

## Constraints

- The repo is a Swift package, not an app bundle.
- CLI behavior is the canonical integration contract.
- MCP is an adapter surface. External agents use the CLI contract directly.
- Broad computer control, generic AppleScript/JXA execution, OSA tool
  discovery, Accessibility/UI automation, shell execution, scheduler behavior,
  remote Mac control, screen/OCR automation, Automator workflow generation, and
  arbitrary app control are outside the accepted target catalog.
- The canonical architecture does not require a macOS host app product.

Explicit non-goals:

- MCP-first architecture.
- Whole-macOS automation.
- A unified `AppleBridgeCore`.
- A generic AppleScript or JXA executor.
- A Notes-only RAG product.
- A macOS host app as the core product.
- Legacy `apple-*` executable aliases.

## Key Principles

- Keep capability ownership target-local even though execution enters through
  the single `apple` product.
- Prefer native macOS frameworks where they provide the required behavior.
- Make permission and safety failures explicit.
- Use shared modules only for mechanical CLI concerns.
- Keep Apple app/domain/system business logic out of utility mechanics.

## Cross-cutting Concerns

- Local Apple app data can be sensitive.
- Some capabilities need TCC permissions.
- Mutating operations need explicit target-local safety policies before
  execution.
- JSON envelopes, exit codes, diagnostics, identity, doctor, DryRun behavior
  where applicable, and risk-flag behavior must remain stable for scripts and
  adapters.

## Risks / Known Gaps

- Messages generic chat automation, new group creation, and oversized
  conversation sends stay gated pending focused recipient identity policy.
- Deep iWork content extraction, app-native export beyond implemented package
  copy-out/QuickLook-backed paths, and broader writes need target-local
  validation before support.
- Finder broad overwrite, directory delete, recursive delete, and bulk content
  mutations are rejected.

## Related Decisions

- [0001: No AppleBridgeCore](../Decisions/0001-NoAppleBridgeCore.md)
- [0002: CLI Contract Is Canonical](../Decisions/0002-CliContractIsCanonical.md)
- [0003: MCP Is Adapter, Not Core](../Decisions/0003-McpIsAdapterNotCore.md)
- [0008: Direct Official Package Mechanics](../Decisions/0008-DirectOfficialPackageMechanics.md)
- [0015: DryRun And Risk Flag Safety Model](../Decisions/0015-DryRunAndRiskFlagSafetyModel.md)
- [0007: Unified Apple Command Tree and Official Swift Mechanics](../Decisions/0007-UnifiedAppleCommandTreeAndOfficialSwiftMechanics.md)
- [0013: Options Safety Naming And Risk Flags](../Decisions/0013-OptionsSafetyNamingAndRiskFlags.md)
- [0014: TCC Target Surface And Safety Gates](../Decisions/0014-TccTargetSurfaceAndSafetyGates.md)
