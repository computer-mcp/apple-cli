# Safari Developer Guide

`SafariCLI` owns typed browser commands, bounded page reads and selected
read-only Safari database diagnostics. The command contract and risk gates are
listed in [Capability List](../../Architecture/Safari/CapabilityList.md).

## Package-Local Tests

```bash
Scripts/bootstrap
xcrun swift test --filter Safari --force-resolved-versions
```

`SafariCommandTests` supplies controlled browser backends and a synthetic
SQLite fixture. It covers command routing, JSON responses, page output limits,
Tab Group reads, schema diagnostics and mutation gates. App-backed behavior
requires the host's Safari installation and Automation permissions.

## Tab Group Snapshots

`SafariTabGroupsSQLiteBackend` reads the current user's
`~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db`.
It copies database inputs to a temporary snapshot and opens SQLite read-only.
Schema diagnostics check `bookmarks` and these required columns before reads:

```text
id parent type subtype title url num_children hidden order_index
```

The backend maps the database hierarchy into target-owned profile, window,
Tab Group and tab records. Available optional tables contribute diagnostics and
metadata. Missing files, denied access and unsupported schemas produce target
errors or diagnostic warnings.

The database schema is private and can change with Safari. Validate the schema
on the target host with `apple safari tab-groups diagnose --json`; the package's
deployment floor does not establish schema compatibility on every release.
Page text and source reads must remain bounded, and accepted browser actions
continue to use their structured target-local backend and risk flags.
