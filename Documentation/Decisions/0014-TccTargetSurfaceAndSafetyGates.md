# 0014: TCC Target Surface And Safety Gates

## Status

Current.

## Context

TCC failures affect multiple `apple-cli` targets, but duplicating service
catalogs, process identity checks, database inspection, reset commands, or
private-write experiments inside each target would make permission diagnosis
inconsistent and unsafe.

## Decision

Add `tcc` as a system-domain target.

The current command families are:

- service catalog normalization for suffixes, aliases, and raw
  `kTCCService...` names
- client identity parsing for bundle identifiers and absolute paths
- current-process/path/bundle code identity diagnostics
- read-only TCC.db info, digest, list, and read commands
- target-assisted `doctor --for-target`
- public preflight/request routes where macOS exposes them
- official `/usr/bin/tccutil reset SERVICE [CLIENT]`
- private TCC.db add/remove/enable/disable
- private TCC.framework probe/add/reset diagnostics

Private database and framework writes are supported CLI capabilities, not
hidden MCP-only behavior. They must use the `DryRun` and risk-flag model:

- private TCC.db writes require `--allow-private-tcc-db-write` and `--dry-run`
  preview support
- private TCC.framework writes require
  `--allow-private-tcc-framework-write` and `--dry-run` preview support
- unknown raw service writes require `--allow-unknown-tcc-service`
- official reset requires `--allow-tcc-reset`
- public prompt requests require `--allow-tcc-prompt`

TCC.db reads use read-only SQLite opens, never create the database, and query
named schema columns rather than `select *`. TCC.db writes use parameterized SQL,
exact client equality, no bundle-id `LIKE`, schema digest/column binding,
current row hash binding, intended diff binding, backup path binding, and stale
schema/row rejection before execution.

Other target doctors may reference `apple tcc doctor --for-target <target>`.
They must not copy private TCC database logic into target-local doctors.

## Consequences

- TCC diagnosis becomes a first-class CLI surface and can be projected through
  MCP and external agent integrations because it is no longer proposal-only.
- Dangerous TCC operations remain available only through explicit risk flags
  and target-local `DryRun` previews where the operation can resolve up to the
  side-effect boundary.
- The repo keeps TCC semantics local to `TCCCLI`; app/domain targets keep their
  own framework-specific permission flows.
- Private TCC.framework execution may fail on protected systems. That failure is
  returned structurally instead of being hidden or replaced by a rough fallback.
