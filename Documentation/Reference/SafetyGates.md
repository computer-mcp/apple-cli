# Safety Gates

## Scope / Purpose

This reference defines the current command safety vocabulary used by the CLI.
It is a cross-target vocabulary, not a runtime authorization registry and not a
complete per-command matrix.

The active model is `DryRun` plus explicit risk flags:

- `--dry-run` is a mutation preview mode. It runs parsing, normalization,
  target-local resolution, and validation, then stops before side effects.
- A `DryRun` JSON payload reports the normalized arguments, resolved scope,
  would-be mutations, required allow flags, permission notes, and risk classes.
- Real execution returns an `OperationResult`.
- Risk acknowledgement uses concrete `--allow-*` flags. Agents must not add an
  allow flag unless the user explicitly authorized that risk.

Target-specific gate details belong in
`Documentation/Architecture/<Target>/CapabilityList.md` and target developer
guides.

## Gate Definitions

| Gate | Meaning | Required mechanics |
| --- | --- | --- |
| `readOnly` | Metadata read, diagnosis, verification, or bounded inspection with no durable state change. | Normal validation and JSON envelope. Reject `--dry-run` unless the target explicitly supports read preview. |
| `boundedRead` | Read may expose large, private, or sensitive content. | Explicit selector plus target-local `--limit`, `--max-bytes`, include flag, truncation metadata, or equivalent cap. |
| `ordinaryMutation` | Explicit single-object or explicitly addressed mutation. | Supports `--dry-run`; real execution does not require a generic allow flag unless the target declares an extra risk. |
| `destructiveSelection` | Query, bulk, cleanup, broad selection, delete, remove, overwrite, or similar destructive selection. | Supports `--dry-run`; real execution requires `--allow-destructive-selection` or a stronger target-specific allow flag. |
| `externalDispatch` | Sends work to another app, system service, URL handler, print service, notification center, communication service, or external process. | Supports `--dry-run`; real execution requires `--allow-external-dispatch` or a stronger target-specific allow flag. |
| `riskBoundSystemAction` | Mutates local system-domain state, security state, services, caches, or private/protected OS surfaces. | Supports `--dry-run` where the target can resolve up to the side-effect boundary; real execution requires a target-specific `--allow-*` flag. |
| `artifactAction` | Creates, overwrites, moves, deletes, exports, imports, or packages filesystem artifacts. | Supports `--dry-run`; real execution requires `--allow-artifact-action` unless the target declares a stronger flag. |
| `persistentAction` | Installs, removes, or changes state intended to outlive the immediate command. | Supports `--dry-run` where useful; real execution requires `--allow-persistent-action` or a stronger target-specific flag. |
| `proofFailed` | Evidence names a desired mapping, but implementation proof fails because of OS, entitlement, TCC, stability, or safety constraints. | Do not expose as supported; record proof and failure mode. |

## Target Summaries

| Target | Safety summary |
| --- | --- |
| `notes` | Reads are normal or bounded; note mutations use `DryRun` and target-local mutation policy. |
| `calendar` | Event reads are bounded by date ranges; export uses artifact safety, and event mutations use mutation safety. |
| `reminders` | Reads and doctor/store inspection are read-only; lifecycle and metadata mutations use `DryRun` and target-local verification. |
| `contacts` | Contact reads are bounded; import/export and contact/group mutations use `DryRun`, artifact flags, destructive-selection flags, or explicit IDs as appropriate. |
| `mail` | Message bodies are bounded reads; draft/send/move/archive/delete use mutation, destructive-selection, or external-dispatch gates. |
| `messages` | Local message reads are bounded; sends use external-dispatch safety with recipient binding. |
| `maps` | Place/direction previews are reads; Maps open uses external-dispatch safety. |
| `finder` | File reads are path-bounded; open/reveal use external-dispatch safety, file outputs use artifact safety, and destructive file actions use destructive-selection safety. |
| `numbers` | Document/table reads are path-bounded; export/open/cell writes use artifact, external-dispatch, or mutation safety. |
| `pages` | Document reads are path-bounded; open/export use external-dispatch or artifact safety. |
| `keynote` | Presentation/slide reads are path-bounded; open/export use external-dispatch or artifact safety. |
| `facetime` | Contact resolution and call preparation are read/preview; call start uses external-dispatch safety. |
| `safari` | Page content reads are bounded; browser state actions, durable browser mutations, and strong-gated page/extension actions follow target-local gates. |
| `photos` | Library/media reads are bounded; imports/exports/metadata writes use artifact, mutation, destructive-selection, and target-specific strong gates. |
| `print` | Printer/job reads are normal; submit/cancel use external-dispatch safety. |
| `clipboard` | Clipboard read is bounded-sensitive; write/clear use persistent-action safety. |
| `notifications` | Preview is read-only; send uses external-dispatch safety for notifications created by this tool. |
| `intelligence` | Local cache/service actions use target-specific risk flags such as `--allow-system-cache-write`. |
| `tcc` | Diagnostics are read-only; prompt/reset/private diagnostics require explicit risk flags and target-local gates. |

## Related Documents

- [CLI Contract](../Architecture/CliContract.md)
- [Capability List](../Architecture/CapabilityList.md)
- [Target Implementation Mechanisms](../Architecture/TargetImplementationMechanisms.md)
