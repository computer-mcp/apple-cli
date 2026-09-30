# Photos Parity Closeout Summary

## Scope / Purpose

This reference records the final `apple photos` closeout state in product
terms. It is supporting reference material, not architecture truth and not a
runtime command registry.

Upstream fixture details, donor-command accounting, and comparison-run history
stay in the `.agent` tracking files. This file keeps only the durable local
contract: what `apple photos` supports, what is strongly gated, what is
rejected, and which validation gates closed the target.

## Evidence Snapshot

| Evidence | Result used here |
| --- | --- |
| Photos.app SDEF | Standard commands, Photos Suite commands, app properties, container/album/folder/media item classes, and hidden rows are all accounted for. |
| Current `PhotosCLI` | Production parity rows have final closeout states as of 2026-05-26. |
| Default validation | `swift build`, full `swift test`, focused Photos behavior tests, and executable contract tests passed. |
| Gated reference validation | Normalized external comparison passed with 52 fixture libraries, 52,667 compared rows, zero skips, and zero diffs. |
| Gated live validation | Photos.app/SDEF Swift Testing passed against a copied modern test library, proving live selection, selected-query routing, slideshow, temporary album/folder mutation, duplicate, and spotlight/show actions. |

## Closeout Counts

| Scope | Total rows | Implemented or semantic replacement | Current missing | Strong-gate implemented | Rejected by decision |
| --- | ---: | ---: | ---: | ---: | ---: |
| Photos SDEF | 52 | 45 | 0 | 0 | 7 |
| Local query/read families | 34 | 32 | 0 | 1 | 1 |
| Local export/report families | 22 | 16 | 0 | 5 | 1 |
| Local metadata/import/mutation/diagnostic families | 16 | 9 | 0 | 6 | 1 |
| Local template/hook/code-exec families | 8 | 2 | 0 | 4 | 2 |
| Total | 164 | 124 | 0 | 24 | 16 |

Every row is now in a final closeout status.

## Photos SDEF Decisions

| SDEF row | Domain CLI / local treatment | Current state | Closeout state | Proof |
| --- | --- | --- | --- | --- |
| Standard `open` photo library | `photos libraries open` uses LaunchServices/NSWorkspace to open `.photoslibrary` packages. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | `DryRun` payload shape is covered by default command tests; gated app-backed Swift Testing proves copied-library open before live reads and actions. |
| Standard `quit` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Whole-app quit is outside the Photos target contract. |
| Standard `count` | Bounded list/report/metadata responses expose stable count fields. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Default command tests prove list response counts and aggregate report counts. |
| Standard `exists` | Existence is represented by typed read/not-found behavior. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Snapshot and command tests cover missing library, missing database, ambiguity, and not-found behavior. |
| Application `name` | `photos doctor --json` exposes app bundle metadata. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Bundle metadata parsing has default test proof without Apple Events. |
| Application `frontmost` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Foreground/focus state is whole-app UI state, not Photos library data. |
| Application `version` | `photos doctor --json` exposes app version/build. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Bundle metadata parsing has default test proof without Apple Events. |
| Application elements `container`, `album`, `folder`, `media item` | Snapshot-backed `albums`, `folders`, and `media-items` reads expose typed local records. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Default snapshot tests prove kind separation, parent mapping, child projection, stable IDs, and typed media item fields. |
| Application `selection` | `photos selection list`; selected query-backed commands route through the same structured selection read. | `implemented` | `implemented` | Gated app-backed Swift Testing proves bounded selection list and selected-query routing. |
| Application `favorites album` | Favorite-state query filters replace the special SDEF album property. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Default query tests prove typed favorite and not-favorite selectors. |
| Hidden `last import album` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Hidden import recency context is outside accepted Photos workflows. |
| Application `slideshow running` | `photos slideshow status` / `photos slideshow running` read the SDEF boolean property. | `implemented` | `implemented` | Default command tests prove bounded output; gated app-backed Swift Testing proves the live read. |
| Application `recently deleted album` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Deleted-item recovery state is privacy-sensitive and outside accepted bounded query/export semantics. |
| Hidden element/class `moment` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Hidden/private grouping is rejected; explicit date/place/shared fields cover accepted semantics. |
| Command `import` | `photos imports import` uses a Swift import plan and Photos.app import. | `implemented` | `implemented` | Default tests prove `DryRun` preview file validation, grouping, duplicate policy, folder/album placement, response shape, and scope validation refusal. |
| Command `export` | `photos exports export` uses the local export planner plus Photos.app export where app rendering is canonical. | `implemented` | `implemented` | Default export tests prove destination `DryRun` payloads, resource families, reports/state, cleanup, metadata writes, and post-export album mutations. |
| Command `duplicate` | `photos media-items duplicate`. | `implemented` | `implemented` | Gated app-backed Swift Testing proves `--dry-run` duplication on a copied library. |
| Command `make` | `photos albums create`; `photos folders create`. | `implemented` | `implemented` | Default command tests and gated app-backed Swift Testing prove temporary album/folder creation. |
| Command `delete` | `photos albums delete`; `photos folders delete`. | `implemented` | `implemented` | Default command tests and gated app-backed Swift Testing prove `--dry-run` temporary album/folder deletion. |
| Command `add` | `photos albums add-items`. | `implemented` | `implemented` | Default command tests and gated app-backed Swift Testing prove selector-bound add to album. |
| Slideshow commands | `photos slideshow start/stop/next/previous/pause/resume`. | `implemented` | `implemented` | Default command tests and gated app-backed Swift Testing prove command routing. |
| Command `spotlight` | `photos show spotlight`. | `implemented` | `implemented` | Default selector validation and gated app-backed Swift Testing prove the action. |
| Command `search` | Typed `photos media-items search`; no raw UI search command. | `semantic-replacement-implemented` | `semantic-replacement-implemented` | Default query tests prove bounded data search and result projection. |
| Hidden `moment.id` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Hidden moment identity is not exposed through CLI or MCP. |
| Hidden `moment.name` | No production command. | `rejected-by-decision` | `rejected-by-decision` | Hidden moment naming is not exposed through CLI or MCP. |

## Local Capability Groups

| Group | Local treatment | Gate |
| --- | --- | --- |
| Library discovery and info | FileManager, Photos preference hints, package metadata, and read-only snapshots. | none / bounded read |
| Albums and folders | Snapshot reads plus Photos.app mutations with `--dry-run` support. | bounded read / `DryRun` payload |
| Media item reads and queries | Typed snapshot query DSL with explicit selectors and bounded output. | bounded read |
| Media item mutations | Selector-bound SDEF writes plus local undo state where supported. | `DryRun` payload |
| Import | Grouped import plan with `--dry-run` support before Photos.app import. | `DryRun` payload |
| Export/report/state | Local planner, explicit destinations, report/state files, resource copying, and app rendering where required. | `DryRun` payload |
| Cleanup, dynamic hooks, metadata writes, and shell post-commands | Explicit allow flags, `DryRun` payloads, selector/source/command hashes, timeout, output cap, and MCP preservation tests. | strong gate |
| Templates and sidecars | Swift renderer and writer over normalized records. | bounded read / `DryRun` payload |
| Slideshow and show actions | Target-local Photos.app SDEF actions. | bounded read / state action / `DryRun` payload where selectors are broad |

## Rejected Baseline

- Direct Photos database writes.
- Raw AppleScript, JXA, UI scripting, or whole-Mac automation runners.
- Raw SQL as normal query grammar.
- Arbitrary external-tool passthrough.
- Unsafe original mutation inside a Photos library package.
- Hidden/private Photos SDEF rows as ordinary commands or MCP-only behavior.
