# Permission And Wording

## Scope / Purpose

This document defines how `apple-cli` models macOS permissions, TCC recovery,
and reader-facing permission wording. It covers CLI messages that a terminal
user, assistant, MCP client, or external agent may display. It does not make human text
part of the machine contract.

## Permission Ownership

Each target owns the permission semantics for its backend:

- EventKit targets own Calendar and Reminders authorization, including
  `.notDetermined`, write-only, full-access, denied, restricted, and unknown
  status handling.
- Contacts-backed targets own Contacts authorization and request behavior.
- Automation-backed targets own their app automation failures and guidance.
- File and database backed targets own Full Disk Access diagnostics for the
  exact resource they try to read.
- `notifications` owns the local notification surface and must not claim a
  reliable global notification-permission probe from the unbundled SwiftPM CLI.
- `tcc` owns TCC service catalog lookup, current-process identity diagnostics,
  read-only TCC database inspection, official reset, explicit public
  preflight/request helpers, and gated private database/framework diagnostics.

Shared code may provide contract mechanics and common wording helpers. It must
not hide target-specific permission state machines behind a generic permission
abstraction.

## Permission Request Design

Keep the request policy small:

- Diagnostic commands such as `doctor`, `access preflight`, and database info
  do not prompt. They report state and recovery guidance.
- Commands that are about to perform a protected operation may request access
  when a public request API exists and current status is `.notDetermined`.
- Explicit request commands, such as `tcc access request`, must be named as
  request flows and gated with precise `--allow-*` flags.
- Denied, restricted, Full Disk Access, and Automation recovery paths must not
  pretend the CLI can grant access. They return guidance for the actual process
  identity that needs approval.
- Private TCC writes remain diagnostics only and must not become normal
  onboarding or silent grants.

Before the EventKit and Contacts request fixes, framework-backed commands mostly
checked authorization status and returned `permission_denied` for
`.notDetermined`; they did not consistently call the public request APIs.

## Prompt And Request Rules

When a public framework provides an authorization request API, target commands
that need the protected operation should handle `.notDetermined` by using that
API and then continue or return a structured permission error. They must not
treat `.notDetermined` as denied before a request path has had a chance to run.

Commands that exist only to inspect state, including `doctor`, must report
`notDetermined` without prompting. They are safe diagnostic surfaces and should
not surprise a user or agent by opening a system prompt.

A command whose purpose is to request permission must be explicit,
JSON-reportable, and clear about whether it opens system UI. TCC prompts and
resets use explicit `--allow-*` flags because they affect process or system
privacy state outside ordinary command execution.

If permission was already denied or restricted, do not keep re-requesting in a
loop. Return a structured permission error with recovery guidance. Use System
Settings guidance only as a recovery path; deep links are best-effort and must
not be treated as a stable granting API.

Private TCC database or framework writes are recovery diagnostics only. They
require target-local allow flags and `DryRun` payload shape where the selected row or
schema can drift. They must not silently grant permissions, bypass system UI, or
replace target-local permission handling in app/domain targets.

Current explicit request coverage is limited to EventKit, Contacts.framework,
FaceTime's Contacts-backed preparation, and supported `tcc access request`
routes. Everything else should stay diagnostic until a target-local public
request path is proven and implemented.

## Wording Boundary

Machine semantics are owned by stable structured fields, not by human text:

- `error.code` owns the broad CLI error class and exit behavior;
- target-local failure enums, such as `IntelligenceFailure`, own stable
  target-specific failure reasons in `details.failure`;
- typed `details` fields own recovery inputs such as `required_flag`,
  `operation`, `path`, `state`, `sip`, or process identity;
- clients, MCP adapters, and agents must branch on structured fields, not on
  `message`.

Reader-facing wording belongs in Swift wording helpers when it explains:

- permission grants, denials, not-requested states, or unknown status;
- Full Disk Access, Automation, TCC identity, TCC database readability, or
  System Settings recovery;
- `--allow-*` requirements, DryRun gates, or refused unsafe permission
  mutations;
- `doctor` diagnostics that a user or assistant is expected to surface.

Target-specific wording wrappers own target-specific vocabulary, such as
`TCCWording` in `TCCCLI` or `IntelligenceWording` in `IntelligenceCLI`.
Cross-target framework wording belongs in `Utility`, such as
`CLIPermissionWording`. This keeps wording consistent without moving backend
decisions out of target modules.

Parser help belongs beside the `swift-argument-parser` command and option
definitions because it describes the command surface directly. Full usage
runbooks belong in focused manuals under `Documentation/Reference/`.

Do not move these into wording helpers or string catalogs by default:

- stable machine fields such as `error.code`, `details`, `target`,
  `operation`, IDs, enum-like state values, or `DryRun` fields;
- ordinary parser validation or simple selector errors that are target-local;
- low-level subprocess, SQLite, framework, or internal debug errors unless they
  become user recovery guidance;
- dynamic stdout fragments such as a `DryRun` payload label or execution prose;
- catalog labels whose stability matters more than prose style, such as raw TCC
  service names.

JSON `error.message` and doctor `message` fields are reader-facing and may use
Swift wording helpers. Clients must still branch on codes and structured
details, not on message text.

## Localization Mechanics

This package does not require a localization system for normal CLI wording.
Command help, target-local errors, diagnostics, and manuals must not add
`.strings` or `.xcstrings` resources. Use Swift wording helpers plus stable
`error.code`, target-local `details.failure`, and structured details.

If a future localization initiative is accepted, it must define a new package
resource strategy and prove SwiftPM runtime lookup with build and runtime tests
before production code depends on localized resources.

## Adapter Contract

MCP clients and external agents may display reader-facing permission wording,
but their logic must use the CLI envelope:

- use `ok`, `error.code`, `details`, `meta.target`, exit code, and `DryRun` payload
  fields for branching;
- preserve `message` for users and logs;
- do not inspect localized wording to decide whether an operation is safe,
  retryable, or authorized;
- do not invent alternate permission-recovery commands that bypass the CLI
  target's safety policy.

## Related Decisions

- [CLI Contract Is Canonical](../Decisions/0002-CliContractIsCanonical.md)
- [DryRun And Risk Flag Safety Model](../Decisions/0015-DryRunAndRiskFlagSafetyModel.md)
- [Options Safety Naming And Risk Flags](../Decisions/0013-OptionsSafetyNamingAndRiskFlags.md)
- [TCC Target Surface And Safety Gates](../Decisions/0014-TccTargetSurfaceAndSafetyGates.md)
