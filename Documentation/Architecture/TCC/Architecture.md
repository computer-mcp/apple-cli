# TCC Architecture

`tcc` owns Transparency, Consent, and Control diagnostics and explicit recovery
workflows under `apple tcc`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: TCC currently uses service catalogs, read-only SQLite inspection,
`tccutil`, public permission APIs, and gated private diagnostics. It does not
currently rely on a broad private TCC implementation mechanism for accepted
behavior.

## Source Authority

The TCC service catalog, local TCC database schema, `tccutil`, public
permission APIs, and gated private TCC.framework diagnostics define the
accepted target behavior.

## Implementation Mechanisms

TCC uses service catalogs, code-signing/LaunchServices identity reads, read-only
SQLite inspection, `/usr/bin/tccutil`, public permission APIs, and gated private
TCC.framework diagnostics. It must not become a target-local permission bypass.

## Validation

Use `apple tcc doctor --json`, TCC command tests, and explicit risk-flag tests.
Detailed command status lives in `CapabilityList.md`.
