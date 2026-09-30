# Options Safety Naming And Risk Flags

## Status

Accepted

## Context

The CLI needs option names that distinguish configuration, behavior switches,
and explicit risk acknowledgement. System-domain commands made this especially
important because some operations change fixed local mechanisms where the user
needs to acknowledge a risk class rather than replay a preview token.

## Decision

Define Options and Safety Naming in the CLI contract:

- `option`: a configuration value; it does not authorize risk.
- `flag`: a Boolean behavior switch; it does not authorize risk by itself.
- `risk flag` / `allow flag`: an explicit `--allow-*` acknowledgement for a
  named risk class.
- `operation`: a stable semantic action name.
- `OperationResult`: the completed execution result.

Every mutation or external action must declare a safety policy. Fixed
system-domain mechanisms use precise `--allow-*` flags and return typed
operation results. The first target to exercise this policy is `intelligence`.

## Consequences

- New fixed-mechanism system-domain commands should prefer precise `--allow-*`
  risk flags over generic `--force`, `--yes`, or adapter-level confirmation.
- MCP adapters and external agent integrations must preserve the target-local
  safety policy.
- Public docs must describe which policy a command uses.
- The repository-wide mutation preview model is defined by
  [0015: DryRun And Risk Flag Safety Model](0015-DryRunAndRiskFlagSafetyModel.md).

## Related Documentation

- Date: 2026-06-04
- Related architecture docs:
  - [CLI Contract](../Architecture/CliContract.md)
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
  - [Capability List](../Architecture/CapabilityList.md)
