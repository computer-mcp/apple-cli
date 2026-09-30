# Safari Architecture

`safari` owns Safari browser windows, tabs, pages, profiles, and selected
browser actions under `apple safari`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Safari currently uses target-local structured Safari.app scripting
and read-only `SafariTabs.db` snapshots for accepted behavior. It does not
currently rely on a broad private Safari implementation mechanism.

## Source Authority

Safari.app's local scripting dictionary is the source for accepted browser
window/tab/page actions. Read-only `SafariTabs.db` snapshots are accepted for
profile, snapshot window, and Tab Group diagnostics.

## Implementation Mechanisms

Safari uses target-local structured Safari.app scripting and read-only
`SafariTabs.db` snapshots. It does not expose a raw browser automation runner
or direct Safari database writes.

## Validation

Use Safari command tests, bounded page reads, and target developer guidance.
Detailed command status lives in `CapabilityList.md`.
