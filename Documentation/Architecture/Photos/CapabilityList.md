# Photos Capability List

## Scope / Purpose

This document accounts for the implemented `apple photos` target. It is the
target-local capability truth for Photos, not a runtime command registry.

Photos has multiple credible evidence sources:

- Photos.app SDEF for app-local automation behavior.
- `.photoslibrary` package layout for library discovery, snapshot, backup, and
  mutation hazard handling.
- Swift read-only SQLite access for a local snapshot query backend.
- PhotoKit as an official API candidate for concrete fields or operations after
  command-level proof.
- exiftool as an optional community metadata writer with stronger metadata
  breadth than Apple command-line tools.

The target owns typed local query, export and metadata semantics together with
structured Photos.app actions. Current mechanisms and validation owners are
summarized in `ValidationMatrix.md`; this file defines the accepted capability
surface and its safety boundaries.

## Mechanism Sources

| Mechanism | Current role | Runtime requirement |
| --- | --- | --- |
| Photos.app scripting dictionary | Structured app actions and typed Photos records. | Installed Photos.app and the selected operation's permissions. |
| SQLite C API | Read-only query, report and export planning over temporary snapshots. | Supported source schema and access to the selected library. |
| FileManager and Apple media APIs | Package discovery, backup, export files and resource metadata. | Explicit paths and operation-specific validation. |
| Optional exiftool | Selected external metadata writes. | Doctor-checked executable and concrete risk flags. |
| `.photoslibrary` package | Library inputs and app-owned state. | Snapshot/copy ownership rules and selected-library validation. |

## Backend Selection Rules

- Use Swift read-only SQLite snapshot for deep query, search, export planning,
  report and metadata reads whose selectors and schema mappings are covered by
  local tests; validate source schemas on the intended host.
- Use Photos SDEF / synchronous `NSAppleScript` for Photos.app app-local
  actions: open library, selection, import/export where the app owns behavior,
  album/folder/media item mutation, slideshow, spotlight, and app search proof.
- Use FileManager for `.photoslibrary` package discovery, backup/copy, export
  output, export state DB, sidecars, and reports.
- Use Apple APIs such as ImageIO/CoreGraphics/xattr/mdls only when they cover a
  concrete metadata/read behavior with proof.
- Use PhotoKit only after a command-specific proof shows it covers or exceeds
  SDEF or database semantics.
- Use exiftool only as an optional, doctor-gated metadata writer with `--dry-run` support and strong-gate execution.
- Do not implement direct Photos DB writes, arbitrary AppleScript/JXA/UI
  scripting, raw SQL as a normal query surface, arbitrary external-tool passthrough,
  or unsafe original mutation inside the Photos library.

## Command Families

| Family | Domain CLI | Primary backend | Gate default | Implementation note |
| --- | --- | --- | --- | --- |
| Library discovery | `photos libraries list`; `photos libraries info` | FileManager + package plist/SQLite snapshot | `none` / `bounded-read` | `photos libraries list` scans Pictures packages, Photos last-opened preference, photolibraryd system-library preference, default Pictures library, and bounded best-effort Spotlight `mdfind` results. `photos libraries info` returns typed identity, path, system/last flags, database version metadata, and major count categories from a temp read-only snapshot. |
| Library actions | `photos libraries open`; `photos libraries backup`; `photos libraries compare` | SDEF `open`; FileManager backup/copy; read-only snapshot compare | `DryRun` payload for actions, `bounded-read` for compare | SDEF open photo library; package backup without live mutation; normalized read-only comparisons of two explicit libraries. |
| Albums | `photos albums list/read/create/delete/add-items` | Snapshot reads + SDEF `make`/`delete`/`add` | `bounded-read` / `DryRun` payload | Album reads filter user/shared albums separately from folders, expose stable UUID/name/parent UUID fields, compute item counts from membership joins when needed, mark shared albums with `specialKind=shared`, and include typed media-item children on request. Mutation behavior is accounted for in the SDEF table below. |
| Folders | `photos folders list/read/create/delete` | Snapshot reads + SDEF `make`/`delete` | `bounded-read` / `DryRun` payload | Folder reads filter folder rows separately from albums, expose stable UUID/name/parent UUID hierarchy, and include typed child containers/albums/folders on request. Mutation behavior is accounted for in the SDEF table below. |
| Media items | `photos media-items list/search/read/dump/inspect/update/undo/duplicate` | Snapshot query + SDEF item update/duplicate + local undo state | `bounded-read` / `DryRun` payload | SDEF media item reads plus mutable title/description/keyword/favorite/date/location/album fields. Dump, inspect, and batch-edit behavior stay typed and local. |
| Selection | `photos selection list` | SDEF application `selection`; optional snapshot enrichment | `bounded-read` | Photos UI selection represented as bounded typed rows. |
| Import | `photos imports import` | SDEF `import` plus Swift import grouping and folder placement | `DryRun` payload | Path validation, grouped import plan, duplicate-check policy, album/folder placement, and imported item results. |
| Export | `photos exports export/report` | Snapshot export planner + FileManager + ImageIO/CoreGraphics + SDEF export and album mutation where needed | `DryRun` payload / `strong-gate` for cleanup, metadata writes, and hooks | Current implementation covers original file copy, edited render copy, original and edited Live Photo movie copy, explicit missing-original reporting in originals mode, destination/filename templates with collision suffixes, paired RAW sidecar copy, RAW/JPEG pairing flags, derivative preview export, preview-if-missing fallback, AAE and original AAE adjustment sidecar export, non-JPEG ImageIO JPEG conversion with quality/extension/orientation controls, export skip filters for edited/original/burst/live/raw/uuid, current-name/date-folder/touch-file layout behavior, machine-readable JSON reports with item-level exported/skipped/missing UUID categories, post-export album additions with `--dry-run` support for those categories, append-only JSON state DB history, strong-gated cleanup/keep/cleanup-command behavior over the explicit export destination, strong-gated exiftool metadata writes to exported resources, and strong-gated Finder tag/xattr template writes to exported resources. |
| Metadata listing | `photos metadata keywords/persons/places/labels` | Snapshot query + derived reports | `bounded-read` | Typed aggregate values and counts. |
| Sidecars | `photos metadata sidecar` | Swift sidecar writer | `DryRun` payload | JSON, XMP, and user-template text sidecars are implemented without mandatory exiftool. exiftool-specific writes are covered by EXIF/push-exif strong-gate rows. |
| EXIF writes | `photos metadata exif`; `photos metadata push-exif` | optional exiftool + Swift sidecar/report/projection proof | `DryRun` payload / `strong-gate` | Current implementation can emit an EXIF plan, read imported snapshot EXIF, run explicit exiftool fields behind strong gate for external files, or derive fixed EXIF/IPTC/XMP fields from selected Photos metadata with `metadata push-exif`. push-exif requires explicit selector, accepted metadata fields, executable exiftool path, derived field hash, target path hash, timeout, and output cap; it refuses raw exiftool passthrough and `.photoslibrary` package targets. |
| Database diagnostics | `photos database info`; `photos database query`; `photos database grep`; `photos database debug-dump`; `photos database orphans` | Snapshot SQLite C API | `bounded-read` for metadata and typed DSL; `strong-gate` for grep/debug/orphan/raw SQL diagnostics | Typed database metadata, bounded query grammar, and gated diagnostics with operation-specific risk gates and bounded output. |
| Templates | `photos templates render` | Swift template engine + snapshot records + optional Swift eval JSON hook | `bounded-read`; eval hooks are `strong-gate` | Normalized field projection, defaults, deterministic filters, and conditionals are implemented for template render and export filename/directory templates. Dynamic template values are implemented as `--dry-run`-mode `hook.<key>` values from Swift JSON template hooks. |
| Hooks | `photos hooks template/query/post`; `photos templates render --source/--source-file`; `photos exports export --source/--source-file` | Swift eval JSON wire | `strong-gate` | Template hooks add dynamic render values, query hooks filter typed candidate records through `PhotoHookInput` / `PhotoHookOutput.accepted`, and export lifecycle post-functions run after export execution with item list, export plan, and exported/skipped/missing context. Hook `DryRun` payloads bind source contents, selectors/context, timeout, and output cap. |
| Post commands | `photos post-commands run`; `photos exports export --command` | Shell subprocess with `DryRun` payload/hash/timeout/output cap | `strong-gate` | Post-command categories use explicit category plus JSON stdin. Export lifecycle post-commands run only after export execution and share command hash, timeout, and output-cap binding. |
| Slideshow | `photos slideshow status/running/start/stop/next/previous/pause/resume` | SDEF slideshow property and commands | `bounded-read` for status; `state-action` / `DryRun` payload for start selectors if needed | SDEF slideshow access group. |
| Show / spotlight | `photos show spotlight` | SDEF `spotlight`; app search proof | `state-action` / `bounded-read` | SDEF spotlight/search. |

## Photos SDEF Accounting

Local SDEF evidence exposes Standard Suite plus Photos Suite rows. The target
accounts for each row below through a command, semantic replacement, strong
gate, or `rejected-by-decision` record. Mechanisms and validation ownership are maintained in
`ValidationMatrix.md`.

| SDEF row | Domain CLI | Canonical backend primitive | Gate | Proof/test |
| --- | --- | --- | --- | --- |
| Standard `open` photo library | `photos libraries open` | LaunchServices/NSWorkspace `.photoslibrary` open semantic replacement | `DryRun` payload | App bundle and library path validation plus dry-run command tests. Verify live opening on the intended host using a copied test library. |
| Standard `quit` | no production command | none | `rejected-by-decision` | Quitting Photos is whole-app state control and is not part of the accepted target surface. |
| Standard `count` | list/report/metadata responses | typed response `count` fields and domain-specific report counts | `bounded-read` | Libraries, albums, folders, and media-item list responses expose JSON `count` fields; export reports and metadata aggregates expose scoped counts. |
| Standard `exists` | typed read and validation behavior | snapshot/package validation plus structured `not_found` / `ambiguous_identity` errors | `bounded-read` | Explicit library paths must exist as `.photoslibrary` packages; album/folder/media-item selectors fail through structured CLI errors. |
| Application `name`, `frontmost`, `version` | `photos doctor`; `photos libraries info` metadata where useful | Bundle metadata for name/version; no backend for frontmost | `none` / `rejected-by-decision` | `photos_app_metadata` doctor check exposes bundle name, version, build, and identifier without Apple Events; frontmost stays rejected as whole-app UI focus state. |
| Application elements `container`, `album`, `folder`, `media item` | `albums list/read`; `folders list/read`; `media-items list/search/read` | Snapshot reads first; SDEF references for app-local selectors when needed | `bounded-read` | Container `id`, `name`, and `parent` are proven by snapshot fixture tests with album/folder kind separation and parent UUID mapping. Album media-item and folder child elements are proven through explicit include-output tests. Media-item records use UUID-based local IDs and expose typed title, description, favorite, keyword, person, album, and folder projections from the snapshot. Mutation rows remain separately tracked. |
| Media item `height`, `width`, `filename`, `size` | `photos media-items list/search/read/dump`; templates/export/compare | SQLite snapshot with original-file size fallback | `bounded-read` | Synthetic snapshot/query tests cover dimensions, filename and original file-size mapping. |
| Hidden element `moment` | no production command | none | `rejected-by-decision` | Hidden/private SDEF grouping is rejected: explicit date/place/shared-moment fields cover accepted semantics without exposing hidden moment objects. |
| Application `selection` | `photos selection list` | SDEF selection read + snapshot enrichment | `bounded-read` | The structured backend bounds selection output. Command tests cover selected-query routing with controlled responses; verify actual app selection on the intended host. |
| `favorites album` | `photos media-items search --favorite` / `--not-favorite` | SQLite snapshot favorite-state query | `bounded-read` | No special raw SDEF property command is exposed; typed favorite queries replace the special album property for read semantics. |
| Hidden `last import album` | no production command | none | `rejected-by-decision` | Rejected because hidden import recency context is not a standalone Photos-domain command. Import results/report rows cover accepted workflows. |
| `recently deleted album` | no production command | none | `rejected-by-decision` | Rejected because deleted-item recovery state is privacy-sensitive and outside accepted bounded query/export semantics. |
| `slideshow running` | `photos slideshow status`; `photos slideshow running` | SDEF boolean property | `bounded-read` | Bounded status reads and command routing tests; verify the app property on the intended host. |
| Command `import` | `photos imports import` | SDEF import plus Swift import plan | `DryRun` payload | File path validation, deterministic edited/original/live/raw/AAE grouping, duplicate-check option binding, folder-scoped album placement, imported item identity, missing `DryRun` preview refusal, and scope validation refusal. |
| Command `export` | `photos exports export` | Export planner + SDEF export where Photos app export is canonical | `DryRun` payload | Export tests cover destination validation, dry-run previews, original/rendered resource families, reports/state, cleanup, metadata writes and post-export album routing. Verify actual app export on the intended host using a copied library. |
| Command `duplicate` | `photos media-items duplicate` | SDEF duplicate media item | `DryRun` payload | The target command binds the selected media item and dry-run plan. Verify actual duplication with a copied library on the intended host. |
| Command `make` album/folder | `photos albums create`; `photos folders create` | SDEF make new album/folder | `DryRun` payload | The target command validates parent/name fields and the creation plan. Verify actual creation with a copied library on the intended host. |
| Command `delete` album/folder | `photos albums delete`; `photos folders delete` | SDEF delete | `DryRun` payload | The target command binds the destructive selector and dry-run plan. Verify actual deletion with a copied library on the intended host. |
| Command `add` media items to album | `photos albums add-items` | SDEF add | `DryRun` payload | The target command binds album and media-item selectors. Export command tests cover result-category album routing; verify app mutations with a copied library on the intended host. |
| Slideshow commands | `photos slideshow status/running/start/stop/next/previous/pause/resume` | SDEF slideshow property and commands | `bounded-read` / `state-action` | Status, start selector validation and structured action routing in command tests. Verify app state actions on the intended host. |
| Command `spotlight` | `photos show spotlight` | SDEF spotlight | `state-action` | Target-local selector and path validation; verify app dispatch on the intended host. |
| Command `search` | `photos media-items search` | Snapshot typed query for data search | `bounded-read` | SDEF UI search is not exposed as a separate raw command; typed search is proven against the snapshot fixture with query and result projection checks. |
| Media item mutable `keywords`, `name`, `description`, `favorite`, `date` | `photos media-items update`; `photos media-items undo`; metadata/timewarp commands | SDEF write, local undo state, and optional PhotoKit proof | `DryRun` payload | Field-level `DryRun` payloads bind explicit selectors and field hashes. Default tests prove keyword replace/additive de-duplication, title undo restore, description batch updates, favorite set/clear validation, ISO date writes, location writes, album membership, scalar undo restore, and MCP `DryRun` payload argument preservation; exiftool side effects are separated. |
| Media item read-only `height`, `width`, `filename`, `altitude`, `size`, `location`; identity row `id` | `photos media-items read`; query filters; template output | Snapshot read semantic replacement | `bounded-read` | Synthetic snapshot, query and template tests cover mapped fields and the local `photos-media-item:<uuid>` identity shape. Validate source schemas and actual app values on the intended host. |
| Container `id`, `name`, `parent` | `albums read`; `folders read` | Snapshot read and structured app selectors | `bounded-read` | Hierarchy fixture tests. |
| Album element `media item` | `albums read --include items`; `media-items list --album` | Snapshot query and structured app selectors | `bounded-read` | Limit/max-bytes and album membership tests. |
| Folder element `container`, `album`, `folder` | `folders read --include children` | Snapshot query and structured app selectors | `bounded-read` | Hierarchy tests. |
| Hidden class `moment` properties | no production command | none | `rejected-by-decision` | Rejected with hidden `moment`; no hidden moment identity/name selector is exposed through CLI or MCP. |

## Domain Capability Accounting

| Family | CLI contract | Mechanism and safety |
| --- | --- | --- |
| Selection and query | `photos media-items search`; query-backed read/export/report commands | Typed selectors over read-only snapshots. |
| Export and reports | `photos exports export/report` | Explicit destinations, local resource planning, state and metadata outputs. Cleanup and hooks retain their risk flags. |
| Scalar metadata and undo | `photos media-items update/undo`; `photos metadata batch-edit` | Selector-bound structured app actions and local state. |
| Dates and locations | `photos metadata timewarp/add-locations` | Bounded matching, explicit values and destructive-metadata authorization. |
| External metadata writes | `photos metadata push-exif` | Optional tool resolution, accepted fields, source/selector hashes and risk flags. |
| Compare and synchronization | `photos libraries compare`; `photos metadata sync` | Read-only normalized comparison; explicitly authorized scalar mutations for sync. |
| Database diagnostics | `photos database orphans/grep/debug-dump` | Read-only snapshot diagnostics, bounded output and operation-specific gates. |
| Template rendering | `photos templates render` | Target-owned Swift values, deterministic filters and optional gated hooks. |
| Swift hooks | `photos hooks template/query/post` | JSON input/output, source hashes, timeouts, output limits and code-execution authorization. |
| Post-export commands | `photos post-commands run`; export lifecycle commands | Target-local subprocess contracts with command hashes and explicit risk flags. |

## `.photoslibrary` Package Accounting

| Package concern | Behavior | Gate | Proof/test |
| --- | --- | --- | --- |
| Library path discovery | `photos libraries list` scans known user/system locations, Photos last/system preferences, bounded Spotlight-discovered `.photoslibrary` packages, and explicit `--library` paths. | `none` | Synthetic path tests prove de-duplication, system/last flags, injected Spotlight discovery, and default resolution order; no app launch. |
| Package metadata | `photos libraries info` reads plist/package metadata and snapshot DB version where proven. | `none` / `bounded-read` | Fixtures with minimal plists/DB. |
| Database snapshot | Copy Photos DB and required sidecar DB files to temp, then open read-only through SQLite C API. | `bounded-read` | Tests prove source library is not written and locked DB maps to structured error. |
| Backup/copy | `photos libraries backup` writes only to explicit destination. | `DryRun` payload | Dry-run plan, `DryRun` payload, temp output tests. |
| Export output | `photos exports export` writes only outside `.photoslibrary` unless an explicit later ADR allows otherwise. | `DryRun` payload | Destination refusal tests. |
| Export state DB | Store outside `.photoslibrary` at explicit `--state-db`. | `DryRun` payload | Append-only JSON run history with latest and historical lookup tests plus per-resource source/destination/semantic signatures for `--update`, `--force-update`, `--only-new`, and `--ignore-signature`. |
| Manual app validation | Use a copied dedicated test `.photoslibrary` for Photos.app operations. | Operation-specific risk flags and dry-run inspection | Keep app-triggered changes inside the selected test copy. |
| Direct database writes | Not supported. | `rejected-by-decision` | Must remain absent from production code and docs except as explicit rejection. |

## PhotoKit Proof Candidates

PhotoKit is official and importable, but this target does not assume it replaces
SDEF or snapshot semantics globally. It is evaluated row by row.

| Candidate | Potential use | Required proof |
| --- | --- | --- |
| Asset identity and core fields | Replace or validate snapshot fields for media item ID, date, favorite, dimensions, media type. | Same IDs and values as SDEF/snapshot for representative fixtures. |
| Asset collections | Validate album/folder membership and special albums. | Stable mapping to SDEF container/album/folder rows. |
| Mutations | Update selected asset metadata or collection membership. | Authorization, `DryRun` payload identity, dry-run preview, round-trip Swift Testing proof. |
| Resource/export APIs | Export originals, rendered assets, Live Photo resources. | Covers accepted export semantics or declares gaps. |
| iCloud/missing originals | Diagnose availability/download state. | Stable failure mapping and no implicit network downloads unless explicitly modeled with `--dry-run` and target-specific allow flags. |

## Rejected / Unsafe Baseline

These remain rejected or gated unless a later implementation proof and ADR
changes them:

- Direct Photos database writes.
- In-place mutation of originals inside `.photoslibrary`.
- Generic `run-applescript`, JXA, UI scripting, or whole-Mac automation.
- Generic external-tool passthrough.
- Raw SQL as normal query grammar.
- Opening test `.photoslibrary` inputs in Photos.app without first copying
  them to a temporary dedicated library.
