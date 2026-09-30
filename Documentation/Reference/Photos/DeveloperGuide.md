# Photos Developer Guide

## Scope / Purpose

This reference describes the Photos test evidence. It is not a test runner and
not Architecture current truth. It separates default tests that run in normal
`swift test` from opt-in Swift Testing validation that uses large external fixtures or
opens Photos.app.

The testing goal is semantic parity. Row-level closeout status is summarized in
`../../Architecture/Photos/ParityMatrix.md`, while donor-specific fixture details stay under
`.agent`.

- Photos SDEF-backed behavior is verified through the `apple photos` CLI
  contract, not raw scripting dictionary output.
- Large `.photoslibrary` fixtures may be used as inputs only in gated tests;
  they must be copied to temp before any Photos.app or AppleScript interaction.

## Test Tiers

| Tier | Runs by default | Inputs | Purpose | Prohibited behavior |
| --- | --- | --- | --- | --- |
| Unit command tests | Yes | Fake backends and small JSON fixtures | Validate ArgumentParser command tree, JSON envelopes, `DryRun` payloads, strong-gate refusal, and rejected/unsupported behavior. | Launching Photos.app, reading user Photos library, invoking external reference tools, invoking exiftool unless explicitly mocked. |
| Snapshot/query tests | Yes | Small synthetic SQLite/JSON fixtures under `Tests/AppleCLITests/Fixtures/Photos/` | Validate snapshot copy, read-only SQLite open, typed query DSL, normalized records. | Opening live `.photoslibrary`, direct DB writes, raw SQL user input except strong-gate refusal tests. |
| Hook tests | Yes | Inline Swift snippets and temp files | Validate `PhotoHookInput` stdin, `PhotoHookOutput` stdout, JSON validation, template dynamic values, source-content hash, timeout, output cap. | Passing Swift strong types across process boundaries. |
| Metadata tests | Yes | Temp exported files and mocked optional tools | Validate sidecars/reports/xattr paths and missing exiftool diagnostics. | Requiring exiftool by default or mutating originals. |
| Executable contract tests | Yes | Safe local commands and temp outputs | Validate `photos status`, `photos doctor`, safe read refusal/diagnostics, missing `DryRun` preview mutation refusal, strong-gate refusal, MCP target listing. | Requiring a user Photos library with private content. |
| Reference oracle Swift Testing | No | External reference fixture root | Compare normalized Swift output against distilled golden data. | Running in default CI, opening fixtures in place, comparing raw stdout. |
| Photos.app/SDEF Swift Testing | No | Temp-copied `.photoslibrary` or user-provided test library | Validate SDEF open/import/export/selection/slideshow/search behavior. | Touching original fixture libraries or relying on UI scripting. |

## Default Fixture Plan

| Fixture | Shape | Covered behavior | Notes |
| --- | --- | --- | --- |
| `minimal-library.sqlite` | Small synthetic DB with media item, album, folder, keyword, person, place, dimensions, date, favorite, hidden fields where schema proof exists. | Snapshot open, query filters, normalized media/album/folder records. | Schema must be documented in test code; if real Photos schema cannot be safely minimized, use JSON golden fixtures for mapper tests. |
| `minimal-records.json` | Normalized `PhotosMediaItemRecord`, `PhotosAlbumRecord`, `PhotosFolderRecord`, and library records. | CLI JSON envelope and fake backend tests. | Does not claim database parity by itself. |
| `export-plan.json` | Expected export plan for originals, edited, Live Photo movie, RAW sidecar, sidecar/report outputs. | Dry-run export planner and `DryRun` payload shape. | File writes target temp dirs only. |
| Photos.app/SDEF Swift Testing fixture | User-supplied safe `.photoslibrary` copied to temp before Photos.app opens it; use a GUI-openable non-empty test library. | Batch SDEF proof for `libraries open` with `--dry-run`, bounded `selection list`, selected-query routing, `slideshow status`, folder/album create/delete/add with `--dry-run`, media-item duplicate, spotlight, and slideshow controls. | Skips by default unless the opt-in test fixture path is configured. Never opens the original library path. Apple Events `-1743` / `-25211` mean local Automation/TCC permission must be granted before app-backed rows can close. |
| `hook-input.json` | `PhotoHookInput` examples for template, query, post, and post-command categories. | Swift eval JSON contract and output validation. | Includes invalid JSON and oversized output cases. |
| `metadata-sidecar.json`; `metadata-sidecar.xmp` | Expected sidecar outputs for stable metadata fields. | Sidecar writer and report tests. | exiftool-compatible JSON is generated without requiring exiftool. |

## External Reference Fixture Intake

External reference fixture sets can contain multiple test `.photoslibrary`
packages, JSON data, and command tests. These are valuable for
cross-validation but too large and stateful for default tests. Donor-specific
fixture names and run history stay under `.agent`.

| Upstream fixture / case family | Local use | Gate | Notes |
| --- | --- | --- | --- |
| `Test-*.photoslibrary` packages | Optional gated input for snapshot parity and export planning. | `OSXPHOTOS_REFERENCE_FIXTURES`; copy to temp before app open. | Opening in Photos.app can trigger `photoanalysisd` mutations; never open in place. |
| `Test-RAW-*.photoslibrary` | RAW sidecar, original/rendered export, metadata parity. | Reference oracle Swift Testing. | Normalize semantic fields, not raw paths. |
| `Test-Shared-*.photoslibrary` | Shared/iCloud edge cases and known macOS version limitations. | Reference oracle Swift Testing. | macOS-version-specific fixture gaps are recorded as explicit skips or final parity decisions rather than open Photos parity states. |
| `Test-Faces-*.photoslibrary` and face data generators | Persons/faces/regions metadata parity. | Reference oracle Swift Testing; default tests use distilled JSON. | Face-region visual verification stays manual or optional until Swift-native proof exists. |
| `TestTimeWarp-*.photoslibrary` | Date/time/timezone/timewarp semantics. | Reference oracle Swift Testing. | Mutating app/library state requires temp copy and `DryRun` payload. |
| CLI query/export tests | Donor for local `PhotosQueryTests`, `PhotosExportAndMetadataTests`, and gated oracle validation. | Default distilled cases plus gated oracle. | Do not copy upstream command flags wholesale. |
| `tests/iphoto_test_data.json` | Optional future iPhoto import/reference proof. | Gated/future. | iPhoto library support is not required for first PhotosCLI closeout unless mapped explicitly. |

## Test Files

| Local test | Default | Responsibilities |
| --- | --- | --- |
| `PhotosCommandTests.swift` | Yes | Command parsing, target-local validation, JSON envelope, fake backend, `DryRun` payloads, strong-gate refusal, rejected/unsupported behavior, file-based UUID selector parsing, standard UUID normalization, import grouping/duplicate-policy/folder-placement `DryRun` payload proof, export post-category album-add `DryRun` payload shape, metadata mutation strong-gate proof for timewarp/add-locations/sync, and batch media-item update proof for selector-bound title/description/keyword/favorite/date/location/album writes plus scalar undo boundaries. |
| `PhotosSnapshotTests.swift` | Yes | Snapshot copy, required DB sidecars, read-only SQLite open, missing/locked DB diagnostics, no source writes. |
| `PhotosQueryTests.swift` | Yes | Typed DSL coverage for implemented filters. Current default tests cover shared/iCloud cloud-asset state, incloud/syndicated/saved-to-library/shared-moment/shared-library provenance, filename/path, date-created and date-added boundary behavior, strict and relative added filters, time-of-day upper-bound behavior, size range, media type aliases, media traits, folder path matching, in-album/not-in-album, edited/external-edit state, duplicate-signature semantics, repeated keyword/person/title/description selector semantics, exact keyword membership, GPS location presence, reverse-geocoded place parser/conflict behavior, shared comment/like record mapping and has/no-comment/likes filters, original UTI filtering, missing/not-missing original resource semantics, and no-keyword/no-title/no-description presence filters. AI label filtering, full place fixture coverage, and full shared comment/like fixture coverage are covered by gated reference validation because they depend on auxiliary Photos library data. |
| `PhotosHookTests.swift` / `PhotosExportAndMetadataTests.swift` | Yes | Swift eval stdin/stdout JSON, template dynamic hook rendering, source-content hash binding for inline and `--source-file` hooks, timeout, output cap, invalid JSON, shell post-command refusal/execution, export lifecycle post-function/post-command execution after export execution, export exported/skipped/missing UUID category classification, strong-gated export cleanup/keep/cleanup-command behavior, explicit exiftool metadata writes to exported resources, Photos-derived push-exif writes to external original files, and Finder tag/xattr template writes to exported resources. |
| `PhotosMetadataTests.swift` | Yes | Sidecar/report/xattr behavior and exiftool missing/available paths through dependency injection or temp executable. Current exiftool and export-file-metadata write proof lives in `PhotosExportAndMetadataTests.swift` with a temp fake executable or temp exported file so default tests do not require exiftool. |
| `PhotosOracleFixtureTests.swift` | Yes | Ensures bundled oracle fixture resources remain available to default tests. Semantic parity assertions belong in behavior tests or gated oracle validation, not in source-shape or document-grep tests. |
| `AppleMCPAdapterTests.swift` | Yes | Proves the MCP adapter exposes `photos` only through the canonical `apple photos` argument path and preserves Photos strong-gate or `DryRun` payload arguments for import, export hooks, cleanup, metadata sync, push-exif, and media-item batch updates rather than adding bypass behavior. |
| Opt-in oracle tests | No | Support copied fixture read checks and gated normalized reference comparison. Current comparisons report fixture, skipped-fixture, row, and diff counts for database metadata, aggregate metadata, normalized fields, order semantics, and selected typed query filters. |

## Gate And Environment Variables

| Variable | Meaning | Required behavior |
| --- | --- | --- |
| Reference fixture root | Optional absolute path used by the oracle tests. | If unset, opt-in oracle tests skip with a clear message. |
| Photos.app fixture path | Optional user-provided test `.photoslibrary`. | Must be copied to temp before any Photos.app/SDEF operation unless the command is read-only snapshot access. The fixture must be GUI-openable and non-empty for full app-backed validation. |
| `APPLE_PHOTOS_EXIFTOOL` | Optional path to exiftool for metadata writer tests. | Missing path exercises structured doctor/error behavior. |

## Acceptance Evidence

- Default `swift test` does not require large external fixtures, Photos.app UI
  interaction, exiftool, or a populated user Photos library.
- Opt-in oracle tests must compare normalized records and export plans, not
  raw external-tool stdout.
- Any fixture opened by Photos.app is copied to temp first.
- Tests cover missing `DryRun` preview refusal and strong-gate refusal before successful
  safety-gated paths.
- Export cleanup tests prove allow-flag refusal, `DryRun` payload summary hashes,
  keep-rule / `--keep` preservation, dotfile preservation, bounded
  cleanup-command execution, and stale-file deletion reporting under temp
  destination paths.
- Exiftool write tests prove explicit `--exiftool-path`, allow-flag refusal,
  `DryRun` payload summary hashes, timeout/output-cap binding, exported-file targeting,
  external-file targeting, and fake-exiftool invocation without requiring the
  real binary.
- MCP adapter tests prove Photos cleanup allow flags, media-item update `DryRun` payload
  tokens, cleanup-command, timeout, and output cap remain canonical CLI
  arguments.
- Proof-failed rows have executable negative tests or documented drift scans so
  they do not silently become supported.
