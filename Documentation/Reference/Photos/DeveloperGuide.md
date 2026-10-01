# Photos Developer Guide

`PhotosCLI` owns the `apple photos` command tree, validation, local library
snapshots, export files, metadata operations and structured Photos.app actions.
The current command surface and safety gates are documented in
[Capability List](../../Architecture/Photos/CapabilityList.md) and
[User Guide](UserGuide.md).

## Package-Local Tests

From the repository root, run:

```bash
Scripts/bootstrap
xcrun swift test --filter Photos --force-resolved-versions
```

Tests construct synthetic libraries, SQLite databases, media files and JSON
records in test-owned temporary directories. `PhotosTestSupport.swift` supplies
the shared library fixture. The default suite exercises typed contracts and
file behavior with controlled backends.

| Test suite | Coverage |
| --- | --- |
| `PhotosCommandTests` | Command parsing, JSON responses, selector validation, dry-run plans, risk flags and backend routing. |
| `PhotosSnapshotTests` | Library discovery, temporary snapshots, read-only database access, schema detection and record mapping. |
| `PhotosQueryTests` | Typed filters, ordering, selectors, normalized fields and synthetic database joins. |
| `PhotosExportAndMetadataTests` | Export planning and outputs, reports, state, cleanup protection, metadata sidecars and mutation gates. |
| `PhotosHookTests` | Swift hook JSON input/output, categories, validation, timeout and output limits. |

These tests establish behavior for their controlled inputs. Runtime readiness
on a particular macOS release, a user's library and Photos.app permissions
requires validation on that host.

## Library And File Ownership

Read the source `.photoslibrary` through a temporary snapshot. SQLite queries
open the snapshot read-only. Source database files and media originals remain
owned by Photos.app. Export outputs and state files use explicit destinations
outside the source library.

Photos.app operations go through the target's structured scripting backend.
Verify the selected library and permissions with `apple photos doctor --json`
and the relevant bounded read before exercising an app action. For manual
validation, use a copy of a dedicated test library and inspect each operation's
`--dry-run` payload and required `--allow-*` flags.

## Export Cleanup

`PhotosFileBackend` reads `.apple-cli-photos-keep` from the export destination.
Each nonempty, non-comment line contributes a keep pattern alongside explicit
command keep rules. Cleanup protects the keep file, current exports, report,
state and any matching retained files. Keep these rules and the cleanup risk
gates aligned with `PhotosExportAndMetadataTests` when changing file behavior.

## Hooks And Optional Tools

Swift hooks use the target's JSON wire types. Keep source hashes, selector
binding, timeouts, output limits and target-specific risk flags in the command
and backend flow. Optional metadata tools are diagnosed before use; unit tests
supply controlled inputs rather than depending on an installed tool.
