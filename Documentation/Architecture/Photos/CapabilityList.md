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

The target design goal is complete Photos SDEF accounting plus typed local
query/export/metadata semantics. Current row-level status is summarized in
`ParityMatrix.md`; this file describes the durable implementation direction.
Parity does not mean copying third-party command surfaces, Python APIs, raw SQL
passthrough, or exposing raw AppleScript.

## Evidence Snapshot

| Evidence | Local result | Role | Boundary |
| --- | --- | --- | --- |
| Photos.app SDEF | `/System/Applications/Photos.app` is present; `sdef /System/Applications/Photos.app` succeeds. | Canonical source for Photos.app app-local actions and SDEF parity rows. | Structured, target-local `NSAppleScript`; no generic AppleScript/JXA/UI scripting runner. |
| PhotoKit | `swift -e 'import Photos'` succeeds. | Official API proof candidate for specific fields/commands. | Not assumed canonical until it covers or exceeds the mapped SDEF/DB semantics. |
| SQLite C API | `swift -e 'import SQLite3'` succeeds. | Swift-native read-only snapshot query backend. | Always copy Photos DB inputs to temp first; never write inside `.photoslibrary`. |
| exiftool | `exiftool` is not bundled with macOS. | Optional metadata writer and doctor-gated capability. | Missing binary yields structured diagnostics; destructive writes require `DryRun` payload or strong gate. |
| `.photoslibrary` package | Real Photos libraries can include large packages, DB sidecars, and `photoanalysisd` mutation risk. | Library discovery, snapshot, backup, and gated fixture validation rules. | Gated validation must copy libraries before opening them in Photos.app. |

## Backend Selection Rules

- Use Swift read-only SQLite snapshot for deep query, search, export planning,
  report, and metadata reads where local tests and gated reference validation
  prove stable semantics.
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

| Family | Domain CLI | Primary backend | Gate default | Parity tracking note |
| --- | --- | --- | --- | --- |
| Library discovery | `photos libraries list`; `photos libraries info` | FileManager + package plist/SQLite snapshot | `none` / `bounded-read` | `photos libraries list` scans Pictures packages, Photos last-opened preference, photolibraryd system-library preference, default Pictures library, and bounded best-effort Spotlight `mdfind` results. `photos libraries info` returns typed identity, path, system/last flags, database version metadata, and major count categories from a temp read-only snapshot. |
| Library actions | `photos libraries open`; `photos libraries backup`; `photos libraries compare` | SDEF `open`; FileManager backup/copy; read-only snapshot compare | `DryRun` payload for actions, `bounded-read` for compare | SDEF open photo library; package backup without live mutation; normalized compare across two libraries without raw sqldiff/database snapshot grammar. |
| Albums | `photos albums list/read/create/delete/add-items` | Snapshot reads + SDEF `make`/`delete`/`add` | `bounded-read` / `DryRun` payload | Album reads filter user/shared albums separately from folders, expose stable UUID/name/parent UUID fields, compute item counts from membership joins when needed, mark shared albums with `specialKind=shared`, and include typed media-item children on request. Mutation parity remains row-tracked. |
| Folders | `photos folders list/read/create/delete` | Snapshot reads + SDEF `make`/`delete` | `bounded-read` / `DryRun` payload | Folder reads filter folder rows separately from albums, expose stable UUID/name/parent UUID hierarchy, and include typed child containers/albums/folders on request. Mutation parity remains row-tracked. |
| Media items | `photos media-items list/search/read/dump/inspect/update/undo/duplicate` | Snapshot query + SDEF item update/duplicate + local undo state | `bounded-read` / `DryRun` payload | SDEF media item reads plus mutable title/description/keyword/favorite/date/location/album fields. Dump, inspect, and batch-edit behavior stay typed and local. |
| Selection | `photos selection list` | SDEF application `selection`; optional snapshot enrichment | `bounded-read` | Photos UI selection represented as bounded typed rows. |
| Import | `photos imports import` | SDEF `import` plus Swift import grouping and folder placement | `DryRun` payload | Path validation, grouped import plan, duplicate-check policy, album/folder placement, and imported item results. |
| Export | `photos exports export/report` | Snapshot export planner + FileManager + ImageIO/CoreGraphics + SDEF export and album mutation where needed | `DryRun` payload / `strong-gate` for cleanup, metadata writes, and hooks | Current implementation covers original file copy, edited render copy, original and edited Live Photo movie copy, explicit missing-original reporting in originals mode, destination/filename templates with collision suffixes, paired RAW sidecar copy, RAW/JPEG pairing flags, derivative preview export, preview-if-missing fallback, AAE and original AAE adjustment sidecar export, non-JPEG ImageIO JPEG conversion with quality/extension/orientation controls, export skip filters for edited/original/burst/live/raw/uuid, current-name/date-folder/touch-file layout behavior, machine-readable JSON reports with item-level exported/skipped/missing UUID categories, post-export album additions with `--dry-run` support for those categories, append-only JSON state DB history, strong-gated cleanup/keep/cleanup-command behavior over the explicit export destination, strong-gated exiftool metadata writes to exported resources, and strong-gated Finder tag/xattr template writes to exported resources. External checkpoint/repair product controls are not copied into production grammar. |
| Metadata listing | `photos metadata keywords/persons/places/labels` | Snapshot query + derived reports | `bounded-read` | Typed aggregate values and counts. |
| Sidecars | `photos metadata sidecar` | Swift sidecar writer | `DryRun` payload | JSON, XMP, and user-template text sidecars are implemented without mandatory exiftool. exiftool-specific writes are covered by EXIF/push-exif strong-gate rows. |
| EXIF writes | `photos metadata exif`; `photos metadata push-exif` | optional exiftool + Swift sidecar/report/projection proof | `DryRun` payload / `strong-gate` | Current implementation can emit an EXIF plan, read imported snapshot EXIF, run explicit exiftool fields behind strong gate for external files, or derive fixed EXIF/IPTC/XMP fields from selected Photos metadata with `metadata push-exif`. push-exif requires explicit selector, accepted metadata fields, executable exiftool path, derived field hash, target path hash, timeout, and output cap; it refuses raw exiftool passthrough and `.photoslibrary` package targets. |
| Database diagnostics | `photos database info`; `photos database query`; `photos database grep`; `photos database debug-dump`; `photos database orphans` | Snapshot SQLite C API | `bounded-read` for metadata and typed DSL; `strong-gate` for grep/debug/orphan/raw SQL diagnostics | Typed database metadata, bounded query grammar, and gated diagnostics without normal raw SQL, Python-object dump, direct database mutation, or grep grammar. |
| Templates | `photos templates render` | Swift template engine + snapshot records + optional Swift eval JSON hook | `bounded-read`; eval hooks are `strong-gate` | Normalized field projection, defaults, deterministic filters, and conditionals are implemented for template render and export filename/directory templates. Dynamic template values are implemented as `--dry-run`-mode `hook.<key>` values from Swift JSON template hooks. |
| Hooks | `photos hooks template/query/post`; `photos templates render --source/--source-file`; `photos exports export --source/--source-file` | Swift eval JSON wire | `strong-gate` | Template hooks add dynamic render values, query hooks filter typed candidate records through `PhotoHookInput` / `PhotoHookOutput.accepted`, and export lifecycle post-functions run after export execution with item list, export plan, and exported/skipped/missing context. Hook `DryRun` payloads bind source contents, selectors/context, timeout, and output cap. |
| Post commands | `photos post-commands run`; `photos exports export --command` | Shell subprocess with `DryRun` payload/hash/timeout/output cap | `strong-gate` | Post-command categories use explicit category plus JSON stdin. Export lifecycle post-commands run only after export execution and share command hash, timeout, and output-cap binding. |
| Slideshow | `photos slideshow status/running/start/stop/next/previous/pause/resume` | SDEF slideshow property and commands | `bounded-read` for status; `state-action` / `DryRun` payload for start selectors if needed | SDEF slideshow access group. |
| Show / spotlight | `photos show spotlight` | SDEF `spotlight`; app search proof | `state-action` / `bounded-read` | SDEF spotlight/search. |

## Photos SDEF Accounting

Local SDEF evidence exposes Standard Suite plus Photos Suite rows. The target
accounts for each row below through a command, semantic replacement, strong
gate, or `rejected-by-decision` record. Current row status is maintained in
`ParityMatrix.md`.

| SDEF row | Domain CLI | Canonical backend primitive | Gate | Proof/test |
| --- | --- | --- | --- | --- |
| Standard `open` photo library | `photos libraries open` | LaunchServices/NSWorkspace `.photoslibrary` open semantic replacement | `DryRun` payload | App bundle check, library path validation, `DryRun` preview, and app-backed validation guarded by temp/copy policy. Photos SDEF Standard `open` returns `-609` on copied fixtures on some macOS versions. |
| Standard `quit` | no production command | none | `rejected-by-decision` | Quitting Photos is whole-app state control and is not part of the accepted target surface. |
| Standard `count` | list/report/metadata responses | typed response `count` fields and domain-specific report counts | `bounded-read` | Libraries, albums, folders, and media-item list responses expose JSON `count` fields; export reports and metadata aggregates expose scoped counts. |
| Standard `exists` | typed read and validation behavior | snapshot/package validation plus structured `not_found` / `ambiguous_identity` errors | `bounded-read` | Explicit library paths must exist as `.photoslibrary` packages; album/folder/media-item selectors fail through structured CLI errors. |
| Application `name`, `frontmost`, `version` | `photos doctor`; `photos libraries info` metadata where useful | Bundle metadata for name/version; no backend for frontmost | `none` / `rejected-by-decision` | `photos_app_metadata` doctor check exposes bundle name, version, build, and identifier without Apple Events; frontmost stays rejected as whole-app UI focus state. |
| Application elements `container`, `album`, `folder`, `media item` | `albums list/read`; `folders list/read`; `media-items list/search/read` | Snapshot reads first; SDEF references for app-local selectors when needed | `bounded-read` | Container `id`, `name`, and `parent` are proven by snapshot fixture tests with album/folder kind separation and parent UUID mapping. Album media-item and folder child elements are proven through explicit include-output tests. Media-item records use UUID-based local IDs and expose typed title, description, favorite, keyword, person, album, and folder projections from the snapshot. Mutation rows remain separately tracked. |
| Media item `height`, `width`, `filename`, `size` | `photos media-items list/search/read/dump`; templates/export/compare | SQLite snapshot with original-file size fallback | `bounded-read` | Default snapshot/query tests and gated fixture oracle prove stable dimensions, filename, and original file-size semantics. |
| Hidden element `moment` | no production command | none | `rejected-by-decision` | Hidden/private SDEF grouping is rejected: explicit date/place/shared-moment fields cover accepted semantics without exposing hidden moment objects. |
| Application `selection` | `photos selection list` | SDEF selection read + snapshot enrichment | `bounded-read` | Handles empty selection and output caps; gated app-backed Swift Testing proves live selection plus selected-query routing against a copied test library. |
| `favorites album` | `photos media-items search --favorite` / `--not-favorite` | SQLite snapshot favorite-state query | `bounded-read` | No special raw SDEF property command is exposed; typed favorite queries replace the special album property for read semantics. |
| Hidden `last import album` | no production command | none | `rejected-by-decision` | Rejected because hidden import recency context is not a standalone Photos-domain command. Import results/report rows cover accepted workflows. |
| `recently deleted album` | no production command | none | `rejected-by-decision` | Rejected because deleted-item recovery state is privacy-sensitive and outside accepted bounded query/export semantics. |
| `slideshow running` | `photos slideshow status`; `photos slideshow running` | SDEF boolean property | `bounded-read` | Production bounded read and default command proof exist; gated app-backed Swift Testing proves the live SDEF status read against a copied test library. |
| Command `import` | `photos imports import` | SDEF import plus Swift import plan | `DryRun` payload | File path validation, deterministic edited/original/live/raw/AAE grouping, duplicate-check option binding, folder-scoped album placement, imported item identity, missing `DryRun` preview refusal, and scope validation refusal. |
| Command `export` | `photos exports export` | Export planner + SDEF export where Photos app export is canonical | `DryRun` payload | Default export tests cover destination validation, `DryRun` previews, original/rendered resource families, reports/state, cleanup, metadata writes, and post-export album mutations; gated Photos.app/SDEF Swift Testing covers the structured export backend. |
| Command `duplicate` | `photos media-items duplicate` | SDEF duplicate media item | `DryRun` payload | Selector binding to media item ID/title/date hash; gated app-backed Swift Testing proves live duplication on the copied fixture. |
| Command `make` album/folder | `photos albums create`; `photos folders create` | SDEF make new album/folder | `DryRun` payload | Parent folder selector, name validation, duplicate behavior proof, and gated app-backed folder/album creation proof. |
| Command `delete` album/folder | `photos albums delete`; `photos folders delete` | SDEF delete | `DryRun` payload | Destructive scope `DryRun` payload; gated app-backed Swift Testing deletes only the temporary album and folder created during validation. |
| Command `add` media items to album | `photos albums add-items` | SDEF add | `DryRun` payload | Album selector + media item selector hash; gated app-backed Swift Testing proves live add to a temporary album. |
| Slideshow commands | `photos slideshow status/running/start/stop/next/previous/pause/resume` | SDEF slideshow property and commands | `bounded-read` / `state-action` | Gated app-backed Swift Testing proves status, start, pause, resume, next, previous, and stop without UI scripting. |
| Command `spotlight` | `photos show spotlight` | SDEF spotlight | `state-action` | Selector/path validation and gated app-backed proof; no broad UI automation. |
| Command `search` | `photos media-items search` | Snapshot typed query for data search | `bounded-read` | SDEF UI search is not exposed as a separate raw command; typed search is proven against the snapshot fixture with query and result projection checks. |
| Media item mutable `keywords`, `name`, `description`, `favorite`, `date` | `photos media-items update`; `photos media-items undo`; metadata/timewarp commands | SDEF write, local undo state, and optional PhotoKit proof | `DryRun` payload | Field-level `DryRun` payloads bind explicit selectors and field hashes. Default tests prove keyword replace/additive de-duplication, title undo restore, description batch updates, favorite set/clear validation, ISO date writes, location writes, album membership, scalar undo restore, and MCP `DryRun` payload argument preservation; exiftool side effects are separated. |
| Media item read-only `height`, `width`, `filename`, `altitude`, `size`, `location`; identity row `id` | `photos media-items read`; query filters; template output | Snapshot read semantic replacement | `bounded-read` | Dimensions, filename, size, latitude/longitude, and altitude are proven by default snapshot/query/template tests plus gated reference validation where applicable. Snapshot and SDEF-backed records share the `photos-media-item:<uuid>` local ID shape; default snapshot command tests and gated validation cover the local identity projection. |
| Container `id`, `name`, `parent` | `albums read`; `folders read` | Snapshot read; SDEF parity proof | `bounded-read` | Hierarchy fixture tests. |
| Album element `media item` | `albums read --include items`; `media-items list --album` | Snapshot query; SDEF reference proof | `bounded-read` | Limit/max-bytes and album membership tests. |
| Folder element `container`, `album`, `folder` | `folders read --include children` | Snapshot query; SDEF reference proof | `bounded-read` | Hierarchy tests. |
| Hidden class `moment` properties | no production command | none | `rejected-by-decision` | Rejected with hidden `moment`; no hidden moment identity/name selector is exposed through CLI or MCP. |

## External Reference Accounting

Command-family mapping details, fixture names, and comparison row counts are
not part of this list. Durable docs keep only the local CLI contract and the
final validation summary. The local product surface remains typed Swift
commands; no third-party CLI grammar or runtime shape is part of the production
contract.
| `batch-edit` | `photos media-items update`; `photos media-items undo`; metadata command families | SDEF/PhotoKit field writes plus local undo state | `DryRun` payload | Title/description/keywords/favorite/date/location/albums map to selector-bound typed commands. Undo is implemented as a local external state file over scalar single-item fields; album-membership undo is explicitly refused while album membership itself is updated through the same SDEF album path. |
| `timewarp` | `photos metadata timewarp` | SDEF scalar date writes over typed query selection | `strong-gate` | Requires `--allow-destructive-metadata`, `DryRun` preview, set-date/delta/timezone-offset binding, timeout, and output cap; default tests prove allow refusal, scope validation, and executed update field submission. |
| `add-locations` | `photos metadata add-locations` | SDEF scalar location writes over typed query selection plus JSON/CSV track matching | `strong-gate` | Requires `--allow-destructive-metadata`, `DryRun` preview, explicit coordinate or track path/content hash, max-match bound, timeout, and output cap; default tests prove track matching and executed location update field submission. |
| `push-exif` | `photos metadata push-exif` | optional explicit exiftool | `strong-gate` | Explicit selector, allow flag, `DryRun` payload, accepted field list, derived field hash, target-path hash, executable exiftool path, timeout, output cap, raw-field refusal, missing-tool diagnostics, and `.photoslibrary` target refusal are implemented and default-tested. |
| `sync`; compare libraries | `photos metadata sync`; `photos libraries compare`; `photos exports report` | Snapshot + export state DB + external JSON metadata source | `bounded-read` for compare/report-only; `strong-gate` for sync mutations | Library compare is implemented as normalized read-only diff. `metadata sync --report-only` returns a bounded plan; mutating sync requires allow flag, `DryRun` payload, source path/content hash, selected field hash, timeout, and output cap before SDEF scalar metadata writes. |
| `orphans`; compare/debug utilities | `photos database orphans`; `photos libraries compare`; `photos database grep/debug-dump` | Snapshot only | `bounded-read` / `strong-gate` | Orphans is implemented as a read-only package/database consistency diagnostic with `--dry-run` support with timeout and output cap. Diagnostics must not become raw DB shell or direct Photos library mutation. |
| Template system | `photos templates render` | Swift template engine; optional Swift eval JSON hook values | `bounded-read` / `strong-gate` | Normalized field projection, defaults, deterministic filters, and conditionals are implemented in the local pure Swift renderer. Python function-filter semantics are represented by strong-gated Swift JSON hook values under `hook.<key>`, not by Python ABI compatibility. |
| `{function:file.py::function}` template hooks | `photos templates render --source/--source-file`; `photos hooks template` | Swift eval JSON hook | `strong-gate` | Semantic parity, not Python ABI/API compatibility. Template render hook `DryRun` payloads bind query selector, template hash, source-content hash, timeout, and output cap. |
| `--query-function`; `--query-eval` | `photos hooks query` | Swift eval JSON hook | `strong-gate` | Input/output JSON validated; hash/timeout/cap enforced; `accepted=true` keeps the candidate item and `accepted=false` filters it out. |
| `--post-function` | `photos exports export --source/--source-file`; `photos hooks post` | Swift eval JSON hook | `strong-gate` | Runs after export execution with typed category, selected items, sanitized export plan, exported/skipped/missing/report context, source-content hash, timeout, and output cap. |
| `--post-command CATEGORY COMMAND` | `photos exports export --command`; `photos post-commands run` | Shell subprocess | `strong-gate` | `DryRun` payload binds command hash, category, destination, timeout, and output cap; export lifecycle command receives the same JSON post-export input. |
| `run`; `repl`; `install`; `theme`; `docs`; `tutorial`; shell completion | no production PhotosCLI behavior | none | `rejected-by-decision` | Third-party product/runtime helpers are not Photos domain capabilities. |

## `.photoslibrary` Package Accounting

| Package concern | Behavior | Gate | Proof/test |
| --- | --- | --- | --- |
| Library path discovery | `photos libraries list` scans known user/system locations, Photos last/system preferences, bounded Spotlight-discovered `.photoslibrary` packages, and explicit `--library` paths. | `none` | Synthetic path tests prove de-duplication, system/last flags, injected Spotlight discovery, and default resolution order; no app launch. |
| Package metadata | `photos libraries info` reads plist/package metadata and snapshot DB version where proven. | `none` / `bounded-read` | Fixtures with minimal plists/DB. |
| Database snapshot | Copy Photos DB and required sidecar DB files to temp, then open read-only through SQLite C API. | `bounded-read` | Tests prove source library is not written and locked DB maps to structured error. |
| Backup/copy | `photos libraries backup` writes only to explicit destination. | `DryRun` payload | Dry-run plan, `DryRun` payload, temp output tests. |
| Export output | `photos exports export` writes only outside `.photoslibrary` unless an explicit later ADR allows otherwise. | `DryRun` payload | Destination refusal tests. |
| Export state DB | Store outside `.photoslibrary` at explicit `--state-db`. | `DryRun` payload | Append-only JSON run history with latest and historical lookup tests plus per-resource source/destination/semantic signatures for `--update`, `--force-update`, `--only-new`, and `--ignore-signature`. |
| Opening fixture libraries | Gated app-backed validation copies `.photoslibrary` to temp before opening in Photos.app. | `DryRun` payload / gated external test | Prevents `photoanalysisd` mutations of reference fixtures. |
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
- Generic external-tool passthrough or Python API compatibility surface.
- Raw SQL as normal query grammar.
- Arbitrary plugin/package installation or third-party `run`/`repl` equivalents.
- Opening reference `.photoslibrary` fixtures in Photos.app without first
  copying them to temp.
