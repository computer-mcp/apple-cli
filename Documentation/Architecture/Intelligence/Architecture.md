# Apple Intelligence Target Architecture

## Positioning

`intelligence` is a Swift-owned Apple Intelligence system-domain target under the canonical
`apple` CLI product:

```text
apple intelligence <action> [options]
```

The CLI is the production behavior surface. MCP and external agents adapt to
the CLI contract; they do not add hidden Apple Intelligence behavior. The target
name tracks the product goal, not a single permanent system mechanism: the
current production line is a Swift-owned local-cache enablement path.
External implementation research is internal evidence only and does not define
runtime dependencies, product identity, or command names.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Intelligence currently uses Foundation plist APIs, bounded
subprocess calls, local cache files, and service workflows for accepted
behavior. It does not currently rely on a proven Apple Intelligence private
framework as the broad production implementation mechanism.

## Ownership

- `Sources/IntelligenceCLI/Commands.swift` owns the typed
  `swift-argument-parser` command tree and target options.
- `Sources/IntelligenceCLI/Command.swift` owns command dispatch, option
  validation, risk-flag gates, and JSON/human rendering.
- `Sources/IntelligenceCLI/Backends.swift` owns target-local backend execution:
  Foundation plist reads/writes, backup state, bounded subprocess calls,
  LaunchDaemon plist installation, local preflight checks, and rollback
  confinement.
- `Sources/IntelligenceCLI/Models.swift` owns typed target models: patch scopes,
  cache files, domains, mechanisms, state manifests, verification results, and
  `typed operation result`.

## Command Surface

Read-only commands:

- `support`: classify host support and recommended local commands.
- `doctor`: inspect host facts, target files, service files, and state
  directory.
- `verify`: read expected plist domain values through Swift plist APIs.

`support` intentionally does not emit a broad readiness classification.
Readiness is derived from concrete fields: `doctor` reports host facts and file
status, `verify` reports expected cache values, and execution commands run
target-local preflight before mutation.

Risk-flag-gated execution commands:

- `enable`: apply answer or comprehensive plist eligibility rules, optionally
  rewriting eligibility country cache values. Requires
  `--allow-system-cache-write`.
- `reset-cache`: remove known eligibility cache plists and optionally kickstart
  `eligibilityd`. Requires `--allow-cache-reset`.
- `rollback`: restore `latest` or a state id created by this CLI. Requires
  `--allow-system-cache-write`.
- `unlock`: remove file locks/flags from known eligibility files. Requires
  `--allow-system-cache-write`.
- `recompute`: run a bounded one-shot `lldb` recompute flow. Requires
  `--allow-debug-attach`. It invokes `EligibilityEngine.recomputeAllDomainAnswers`
  using the daemon's current inputs.
- `service install`: write this CLI's LaunchDaemon plist with direct Swift CLI
  `recompute` invocation. Requires
  `--allow-debug-attach --allow-persistent-service`.
- `service uninstall`: remove this CLI's LaunchDaemon plist. Requires
  `--allow-persistent-service`.

`intelligence` does not expose `plan` or runtime intake reports. Execution
commands return a typed operation result.

## Version Scope

The production target currently owns a Swift-owned local-cache enablement line
only. The current backend uses macOS eligibility cache files and `eligibilityd`.
Its
implemented mechanisms are:

- answer patch: writes known `os_eligibility_answer_t` cache values;
- comprehensive patch: extends answer patching with known GREYMATTER/CALCIUM
  status input values;
- country cache rewrite: optionally rewrites `countryd` alpha-2 country-code
  strings;
- recompute and service persistence: refresh `eligibilityd` through bounded
  Swift-owned command paths.

Beta-only region spoof, feature-flag experiments, or alternate mechanisms are
outside the production command surface. They require a separate source-owned
design before promotion.
The CLI's `verify` result is local cache verification, not proof that Apple
services, account checks, model downloads, or System Settings UI gates have
completed.

Feature version landmarks and product boundaries:

- Apple Intelligence domain cache patching belongs to the macOS 15.1+ feature
  family.
- ChatGPT-related local country-cache behavior belongs to the macOS 15.2+
  feature family when the surrounding account, network, language, and service
  gates are satisfied.
- macOS 26.5 beta 4+ and macOS 27 beta are not compatibility claims for this
  target; beta-only region spoof, feature-flag, or kernel-extension mechanisms
  are outside the current production line.

## Data Flow

1. `ArgumentParser` parses `apple intelligence ...` into target command structs.
2. The command struct converts parsed options into the compatibility
   `CLIOptions` context.
3. `IntelligenceCommand` validates allowed options and required risk flags.
4. `IntelligenceBackend` performs target-local work through Foundation plist
   APIs or fixed subprocess invocations.
5. File-changing operations create backup state under `state-dir` before
   mutation where rollback is meaningful.
6. Results return through the shared CLI JSON envelope or concise human output.

## Mechanisms

- Answer and comprehensive patch scopes are typed `IntelligencePatchRule` values
  written with `PropertyListSerialization`.
- Country cache rewriting uses `--eligibility-country`, validates a
  two-letter country code, rewrites all uppercase alpha-2 country-code string
  values in the `countryd` plist, reports `countryd` as the touched subsystem,
  and emits an iPhone Mirroring pairing warning.
- Reset uses known cache paths and optional `launchctl kickstart`, not broad
  deletion.
- Recompute uses a fixed `lldb` command sequence only with explicit debug-attach
  consent.
- Service persistence writes this CLI's LaunchDaemon label only with explicit
  persistence consent and can be uninstalled by this target.

## Rejected Boundaries

- Runtime `curl`, `curl | bash`, or third-party script execution.
- Unpinned or downloaded external artifact execution.
- Silent debug attach.
- Default LaunchDaemon persistence.
- Broad cache or directory deletion.
- Publishing third-party project names as CLI behavior, JSON contract, or
  product positioning.
- Adding adapter-only Apple Intelligence capabilities.

## Validation

Apple Intelligence changes must be validated with package-local Swift checks:

```bash
swift build
swift test --filter Intelligence
```

Command references, safety gates, and architecture docs must stay aligned with
the actual `IntelligenceTarget` command tree.
