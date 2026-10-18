# Notes User Guide

Use `apple notes --help` and subcommand help as the first reference. The Notes
target is a private-framework-backed semantic CLI for accepted Notes reads,
writes, rich content operations, import/export, and diagnostics. The command
surface stays user-facing; implementation details are documented in
`../../Architecture/Notes/Architecture.md`.

## Reads

```bash
apple notes guide audit --json
apple notes accounts list --json
apple notes accounts workflow audit --json
apple notes accounts add --provider google --json
apple notes accounts remove --account ACCOUNT_ID --json
apple notes accounts enable --account ACCOUNT_ID --json
apple notes accounts disable --account ACCOUNT_ID --json
apple notes folders list --json
apple notes folders move-impact --folder Work --account Archive --json
apple notes folders workflow audit --json
apple notes smart-folders list --json
apple notes smart-folders notes --folder Focus --account ACCOUNT_ID --json
apple notes smart-folders criteria --folder Focus --account ACCOUNT_ID --json
apple notes smart-folders explain --folder Focus --account ACCOUNT_ID --json
apple notes smart-folders audit --json
apple notes smart-folders workflow audit --json
apple notes smart-folders create --name Focus --account ACCOUNT_ID --tag TAG --dry-run --json
apple notes smart-folders update --folder Focus --account ACCOUNT_ID --tag TAG --dry-run --json
apple notes smart-folders create-criteria --name Pinned --account ACCOUNT_ID --criteria pinned --dry-run --json
apple notes smart-folders update-criteria --folder Pinned --account ACCOUNT_ID --criteria not-shared --dry-run --json
apple notes smart-folders create-criteria --name Work --account ACCOUNT_ID --criteria folder --criteria-folder Work --dry-run --json
apple notes smart-folders duplicate --folder Focus --account ACCOUNT_ID --name FocusCopy --dry-run --json
apple notes smart-folders copy-criteria --from Focus --to Archive --account ACCOUNT_ID --dry-run --json
apple notes smart-folders export-criteria --folder Focus --account ACCOUNT_ID --output ./Focus.criteria.json --dry-run --json
apple notes smart-folders import-criteria --folder Focus --account ACCOUNT_ID --file ./Focus.criteria.json --dry-run --json
apple notes smart-folders rename --folder Focus --account ACCOUNT_ID --name Archive --dry-run --json
apple notes smart-folders delete --folder Focus --account ACCOUNT_ID --dry-run --json
apple notes tags list --json
apple notes tags audit --json
apple notes workflow audit --json
apple notes workflow shortcuts audit --json
apple notes attachments list --id NOTE_ID --json
apple notes attachments list --folder FOLDER --json
apple notes attachments list --folder FOLDER --family photo-video --json
apple notes attachments copy --id SOURCE_NOTE_ID --attachment ATTACHMENT_ID --target TARGET_NOTE_ID --dry-run --json
apple notes attachments audit --folder FOLDER --json
apple notes attachments workflow audit --json
apple notes attachments markup inspect --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments markup edit --id NOTE_ID --attachment ATTACHMENT_ID --file ./Attachment.markupdata --dry-run --json
apple notes attachments audio rename --id NOTE_ID --attachment ATTACHMENT_ID --name "Team recording.m4a" --dry-run --json
apple notes attachments audio save --id NOTE_ID --attachment ATTACHMENT_ID --output ./Team.m4a --dry-run --json
apple notes attachments audio delete --id NOTE_ID --attachment ATTACHMENT_ID --dry-run --json
apple notes attachments audio transcript --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments audio transcript --id NOTE_ID --attachment ATTACHMENT_ID --content summary --output ./Summary.txt --dry-run --json
apple notes attachments audio copy-transcript --id NOTE_ID --attachment ATTACHMENT_ID --target TARGET_NOTE_ID --dry-run --json
apple notes attachments audio copy-transcript --id NOTE_ID --attachment ATTACHMENT_ID --scope clipboard --dry-run --json
apple notes attachments audio search --query "follow up" --json
apple notes export pdf --id NOTE_ID --output ./Note.pdf --dry-run --json
apple notes print --id NOTE_ID --printer PRINTER_NAME --dry-run --json
apple notes export markdown --id NOTE_ID --output ./Note.md --dry-run --json
apple notes export markdown --id NOTE_ID --output ./Note.mdpkg --include-attachments --dry-run --json
apple notes export html --id NOTE_ID --output ./Note.html --dry-run --json
apple notes export html --id NOTE_ID --output ./Note.htmlpkg --include-attachments --dry-run --json
apple notes export rtf --id NOTE_ID --output ./Note.rtf --dry-run --json
apple notes export rtfd --id NOTE_ID --output ./Note.rtfd --dry-run --json
apple notes import audit --file ./ImportFolder --json
apple notes import text --folder FOLDER_ID --file ./note.txt --dry-run --json
apple notes import markdown --folder FOLDER_ID --file ./Note.mdpkg --include-attachments --dry-run --json
apple notes import rtf --folder FOLDER_ID --file ./Note.rtf --dry-run --json
apple notes import rtfd --folder FOLDER_ID --file ./Note.rtfd --dry-run --json
apple notes import html --folder FOLDER_ID --file ./Note.html --dry-run --json
apple notes import html --folder FOLDER_ID --file ./Note.htmlpkg --include-attachments --dry-run --json
apple notes import enex --folder FOLDER_ID --file ./Evernote.enex --dry-run --json
apple notes import folder --folder FOLDER_ID --file ./NotesExport --dry-run --json
apple notes replace markdown --id NOTE_ID --file ./Reorganized.mdpkg --include-attachments --dry-run --json
apple notes replace html --id NOTE_ID --file ./Reorganized.htmlpkg --include-attachments --dry-run --json
apple notes replace rtf --id NOTE_ID --file ./Reorganized.rtf --dry-run --json
apple notes replace rtfd --id NOTE_ID --file ./Reorganized.rtfd --dry-run --json
apple notes open-in-pages --id NOTE_ID --dry-run --json
apple notes links list --id NOTE_ID --json
apple notes body structure --id NOTE_ID --json
apple notes body paragraph quote --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --state on --dry-run --json
apple notes body inline format --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --format bold --state on --dry-run --json
apple notes body inline color --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --color "#336699" --dry-run --json
apple notes body inline highlight --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --color yellow --dry-run --json
apple notes body inline font --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --family FONT_FAMILY --size 18 --dry-run --json
apple notes body checklist add --id NOTE_ID --text "Review contract" --dry-run --json
apple notes body checklist set --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --state checked --dry-run --json
apple notes body checklist set-all --id NOTE_ID --state open --dry-run --json
apple notes body checklist sort --id NOTE_ID --dry-run --json
apple notes body checklist convert --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --state open --dry-run --json
apple notes body checklist convert-range --id NOTE_ID --from-ordinal 3 --to-ordinal 5 --state open --dry-run --json
apple notes body checklist reorder --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --to-ordinal 1 --dry-run --json
apple notes body checklist indent --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --by 1 --dry-run --json
apple notes body checklist delete --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes body checklist line-break --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes body checklist end --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes body list add --id NOTE_ID --text "Discuss launch" --style bulleted --dry-run --json
apple notes body list convert --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --style numbered --dry-run --json
apple notes body list set-style --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --style dashed --dry-run --json
apple notes body list reorder --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --to-ordinal 1 --dry-run --json
apple notes body list indent --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --by 1 --dry-run --json
apple notes body list delete --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes body list line-break --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes body list tab --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes body list end --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --dry-run --json
apple notes state read --id NOTE_ID --json
apple notes state audit --account ACCOUNT_ID --folder FOLDER --json
apple notes list --json
apple notes list --account ACCOUNT_ID --json
apple notes search --query Plan --json
apple notes search audit --json
apple notes read --id NOTE_ID --json
```

Read and diagnostic commands should be bounded enough for local private data.
Doctor and parity diagnostics must not print note bodies.

Use `guide audit --json` to see the current Apple Notes User Guide page-level
coverage baseline without reading notes, folders, accounts, attachments, UI
state, AppleScript, or `SQLiteReader` evidence:

```bash
apple notes guide audit --json
```

The audit reports the current macOS Tahoe Notes User Guide Table of Contents as
36 page records: 28 supported pages whose dominant capability is already
covered by accepted semantic commands or family audits, 5 delegated system/UI
pages, 2 gated pages whose dominant remaining work still needs secret-safe
private proof, and 1 rejected non-capability reference page. Use it as the
target-owned map from Apple's guide pages to the lower-level family audits and
semantic commands.

External Notes account lifecycle commands are explicit delegated boundaries:
`accounts add`, `accounts remove`, `accounts enable`, and `accounts disable`
validate the requested provider or account selector, return
`unsupported_operation` with `status: delegated`, and make no Notes implementation,
AppleScript, or SQLite calls. They do not echo raw account or provider values.
Use macOS Internet Accounts or the user-facing Notes account settings surface
for those workflows until a future accepted route exists. On My Mac enablement
and empty-local-account disablement are supported separately by
`settings on-my-mac --enabled true|false`; disablement is limited to an empty
non-default local account when another active Notes account exists.

Use `accounts workflow audit --json` to see the official Add/remove accounts
page accounting without reading accounts, notes, credentials, or providers. It
reports 13 records: supported account metadata/account-scoped visibility/On My
Mac enablement/empty-local-account disablement, delegated macOS Internet
Accounts and sign-in routes, no gated local-account records, and rejected
provider/local-account product limits.

Use `folders workflow audit --json` to see the official About accounts/folders
and Add/remove folders page accounting without reading notes or folders. It
reports 26 records: supported private folder hierarchy/system-folder metadata,
folder create/rename/move/delete/purge/sort/reorder, `folders move-impact`
preflight, shared-permission and cross-account fidelity-risk accounting, and
note move/copy placement; delegated Notes.app sidebar/menu/drag UI; no gated
folder workflow records; and rejected Apple product limits for system folders,
All/Notes destinations, provider trash support, shared-note account moves, and
locked-note account moves.

Use `folders move-impact` before a potentially sensitive folder move when you
need Notes' private move-decision evidence without changing Notes:

```bash
apple notes folders move-impact --folder Work --account Archive --json
apple notes folders move-impact --folder Work --parent Projects --json
```

The result is hash/count/bool evidence from `ICMoveDecision`: whether the move
is cross-account, whether shared-permission review is required, and whether
cross-account formatting or attachment-loss review is required. It does not
print folder names, participant identifiers, note bodies, attachment bytes, or
private object URIs. Apple documents cross-account formatting and attachment
loss as a risk; this command reports that risk before a move rather than
promising preservation.

`notes search` is text search over visible notes by default. Use `--scope text`
to make that explicit, `--account` to limit visible-note text search to one
selected account, `--include-recently-deleted` to opt into bounded matching of
restorable Recently Deleted notes, or `--id` to search one selected note while
returning only the matching note summary:

```bash
apple notes search --query Plan --scope text --json
apple notes search --account iCloud --query Plan --json
apple notes search --query Plan --include-recently-deleted --json
apple notes search --id NOTE_ID --query "follow up" --json
apple notes search natural-language --query "notes I changed last month" --json
apple notes search attachment-content --query "invoice total" --family pdf --json
apple notes search locked-title --query "Archive" --json
apple notes search audit --json
```

Use `notes list --account ACCOUNT_ID [--folder FOLDER]` to list visible note
summaries for one account without reading note bodies.

Use `notes search audit --json` to see the current official Notes search-family
accounting. The audit does not take `--query`, does not call the Notes implementation,
and reports supported text/account/single-note/Recently Deleted/
natural-language/locked-title search plus composite attachment-content search,
and delegated attachment, PDF, audio, scan/image/drawing/handwriting
searchable-text, suggested, Siri, and Spotlight surfaces. OCR artifact generation, selected-attachment search indexing, and hash-only image
classification summary readback are supported under attachment/media commands:
`attachments recognized-text generate`, `attachments recognized-text index`, and
`attachments image objects`.

Use `notes workflow audit --json` to see the official base note lifecycle and
viewing workflow accounting without reading notes:

```bash
apple notes workflow audit --json
```

The audit covers the current Create/Edit, Quick Note, View Notes, Sort and Pin,
Delete, and Keyboard Shortcuts/Gestures guide pages. It reports 40 workflow
records: 22 supported, 17 delegated, 0 gated, and 1 rejected. Accepted note
list/read/create/update/append/copy/move/delete/restore/purge/pin/unpin, batch
pin/unpin/move/copy/delete, Quick Note system-paper creation, settings
sort/text-size/Quick Note resume, folder sort, collapsible-section state, note
date/folder-count metadata, shared activity metadata paths, private unlock, and
authenticated locked-content artifact export are supported;
Siri, Notes.app UI, macOS text/clipboard services, Writing Tools, Quick Note
window/Safari UI, locked-note authentication UI, per-note zoom, widgets,
shortcuts, gestures, and provider retention timing are delegated; no note
lifecycle workflow record remains gated; and locking a Quick Note is rejected
because Apple documents it as unavailable. The command rejects note, folder,
title, body, text, query, and other selectors and reports `backend_calls: none`.

Use `notes workflow shortcuts audit --json` to see the official Keyboard
Shortcuts and Gestures page accounting without reading notes, UI state, tables,
links, attachments, or the clipboard:

```bash
apple notes workflow shortcuts audit --json
```

The audit reports 58 records: 37 supported shortcut actions that map to
accepted semantic CLI commands, 21 delegated Notes.app/macOS window, view,
focus, share, navigation, zoom, table navigation, and table selection surfaces,
0 gated shortcut semantics, and 0 rejected records. Monostyled paragraph
format is supported through `body paragraph style --style monostyled`, and
list/checklist soft-return insertion is supported through `body list line-break`
and `body checklist line-break`. Ordinary-list literal-tab insertion is
supported through `body list tab`; table-cell newline and literal-tab input are
supported through `body table update --text` with hash/byte-count readback. The
command rejects note, folder, title, body, text, query, and other selectors and
reports `backend_calls: none`.

Non-text Notes search surfaces are explicit. Use `attachments search` for
attachment names or filenames, and `attachments audio search` for existing audio
transcripts, and `attachments pdf search` for embedded PDF text. `notes search
--scope attachment-name`, `--scope audio-transcript`, `--scope pdf`, and
`--scope suggested` return structured delegation metadata. `--scope scan-ocr`,
`--scope image-text`, `--scope drawing`, and `--scope handwriting` return
structured delegation metadata that points to the matching semantic command:
`attachments scan search`, `attachments image search`, or
`attachments drawing search`. Locked-note title-only search is supported by
`notes search locked-title --query QUERY` and the `--scope locked-title` route;
it uses note summaries plus private note-state readback, matches only
password-protected or locked note titles, and does not search locked note
bodies. `notes search attachment-content --query QUERY [--family FAMILY]`
combines accepted private metadata, PDF text, existing audio transcript, and
scan/image/drawing searchable-text slices with hash-only evidence; the legacy
`--scope attachment-content` route maps to the same composite search without the
family guard option. Natural-language search is supported by `notes search
natural-language --query QUERY` and `--scope natural-language`; it uses the
private Notes natural-language search operation, returns note summaries, and
reports query hash/count plus result-accounting evidence without printing the
raw query or note bodies. Delegated search boundary errors hash the query and do
not call the Notes implementation.

`folders list` is available in default private-framework-backed builds. It reads
the complete visible folder tree within the requested account/limit by using the
private folder hierarchy APIs, returns parent folders before children, and emits
folder identifiers, names, account names, parent ID/presence, depth, folder
type, visible-note counts, child-folder counts, and folder state/capability
flags such as default, trash, Smart Folder, system, leaf, renamable, movable,
deletable, subfolder creation, edit support, sort/date-header metadata, and
shared/read-only state. JSON output includes `returnedFolderCount`,
`incompleteFolderCount`, and `incompleteFolders`; a nonzero incomplete count
means the returned rows do not prove every reported direct child folder, usually
because of the command `--limit` or an OS private API visibility gap.
Sort/date-header output is read-only metadata: custom sort values,
order/direction/default/ascending/resolved-order evidence, description,
date-header support, and current date-header visibility. It does not print note
bodies and does not use `SQLiteReader`, AppleScript, or a fake folder tree. Use
`folders sort` to change custom note sorting for an editable folder that
supports custom sort. Use `folders date-headers` to toggle date headers for an
editable folder that supports date headers.

`smart-folders list` is available in default private-framework-backed builds. It
returns Smart Folder identifiers, names, account names, descriptions, editable
state, visible-note counts, query evidence as length/hash fields, and
privacy-safe criteria summaries. It does not print raw criteria JSON, raw
filter values, tag names, folder identifiers, participant identifiers, or
private class names.

`smart-folders notes` is available in default private-framework-backed builds for one
visible Smart Folder:

```bash
apple notes smart-folders notes --folder Focus --account ACCOUNT_ID --json
```

It resolves the Smart Folder by folder selector plus optional account and
returns visible matching note summaries, returned-note count, and visible-note
count. It does not print note bodies, raw criteria JSON, raw filter values,
participant identifiers, or private class names.

`smart-folders criteria` is available in default private-framework-backed builds for
one visible Smart Folder:

```bash
apple notes smart-folders criteria --folder Focus --account ACCOUNT_ID --json
```

It returns the selected Smart Folder, a privacy-safe criteria summary, bounded
matching note summaries, returned-note count, visible-note count when Notes
reports it, and readback verification. It does not print note bodies, raw
criteria JSON, raw filter values, raw tag names, folder identifiers inside
criteria, participant identifiers, or private class names. Raw criteria artifact
export/import is handled by `smart-folders export-criteria` and
`smart-folders import-criteria`; arbitrary criteria construction remains gated.

`smart-folders explain` is available in default private-framework-backed builds for
one visible Smart Folder:

```bash
apple notes smart-folders explain --folder Focus --account ACCOUNT_ID --json
```

It returns the selected Smart Folder, bounded matching note summaries, a
privacy-safe criteria explanation, and readback verification. The explanation
records query kind, filter count, whether the criteria is multi-condition, safe
read families that are understood, and mutation families that remain gated. It
does not print note bodies, raw criteria JSON, raw filter values, raw tag
names, folder identifiers inside criteria, participant identifiers, or private
class names. User-editable multi-condition construction, raw-value comparison
without semantic readback, participant/mention identity comparison when private
hash evidence is unavailable, broader mention object-bound comparison,
remaining tag identifier/object-bound filter comparison beyond accepted
folder/not-folder and accepted tag-set hints, and broader runtime Smart Folder
criteria mutation remain gated.

`smart-folders reasoning` is available in default private-framework-backed builds for
per-note membership evidence from one visible Smart Folder:

```bash
apple notes smart-folders reasoning --folder Focus --account ACCOUNT_ID --json
```

It returns the selected Smart Folder, the privacy-safe criteria explanation,
one record per returned matching note, the criteria families associated with
that match, privacy-safe tag-selection and tag-count readback where available,
partial per-filter state/count/attachment-family evidence where the CLI can
prove it from private note state, body structure, attachment metadata, or note
tag metadata, and gated-reasoning families for the parts the CLI cannot prove
without exposing raw criteria internals. It proves membership through private
Smart Folder readback. Pinned, shared, locked, attachment, checklist, math,
call, and system-paper filters can report boolean or count readback. Pinned,
shared, and locked inclusion readback, recognized attachment/checklist
selection types, and known date selections clear raw-value gates when the
private criteria summary exposes semantic inclusion or selection metadata. Tag
criteria can report selected-tag count, per-note tag count, single included-tag
positive hash matches, and default-operator included/excluded tag-set hash
matches where private criteria hints and note tag metadata align, while keeping
unsupported operator/mode and tag selections without private hints gated. Attachment criteria can report generic,
no-attachment, photo/video, scan, drawing, map preview, webpage preview, audio,
and document family counts. Checklist criteria can report total, open, done,
and no-checklist counts. Accepted folder/not-folder criteria can report
per-note folder-object hash comparison without printing folder identifiers
inside criteria. Created/edited date criteria can report per-note date-source
presence, known relative selections such as today, yesterday, last 7 days, last
30 days, last 3 months, and last 12 months can report selection readback, and
explicit on/before/after/between/relative date criteria can report semantic
date-parameter comparison without printing raw date criteria values.
Participant filters can report note-state participant-count readback and, when
criteria and note state both expose selected participant hashes, participant
identity hash comparison without printing participant identifiers. Mention
filters can report body-structure mention attachment-count readback and, when
criteria and mention attachments both expose selected user hashes,
mentioned-participant hash comparison without printing mention text or
participant identifiers.
For multi-condition Smart Folders, each match can include a `booleanTrace`
summary with condition counts, proved/failed/unknown counts, tag-selection
proof status, and gated reasoning families. The trace is `verified` only when
every current supported filter and tag-selection condition has private readback
evidence and no unresolved gates; otherwise it remains
`partial_gated_filters`. Participant/mention identity comparison when private
hash evidence is unavailable, broader mention object-bound comparison,
object-bound criteria beyond accepted folder/not-folder and accepted tag-set
hints, raw-value comparison without semantic readback, unsupported
operator/mode tag comparison, missing-hint tag comparison, and arbitrary/full
multi-condition comparison beyond supported-filter trace remain gated. It
does not print note bodies, raw criteria JSON, raw filter values, raw tag
names, participant identifiers, or private class names.

`smart-folders audit` is available in default private-framework-backed builds as a
read-only batch criteria-family accounting command:

```bash
apple notes smart-folders audit --account ACCOUNT_ID --json
```

It returns visible Smart Folder records, aggregate query/criteria summary
counts, filter-kind counts, raw-value hash counts, safe supported-read
families, gated mutation families, and readback verification. It does not fetch
matching notes and does not print note bodies, raw criteria JSON, raw filter
values, raw tag names, folder identifiers inside criteria, participant
identifiers, or private class names.

`smart-folders filters audit` is available in the default private-framework-backed
build as selector-free Smart Folder filter catalog accounting:

```bash
apple notes smart-folders filters audit --json
```

It reports the target-owned Smart Folder filter/value-shape catalog without
reading notes, Smart Folders, local store data, AppleScript, or `SQLiteReader`
evidence. Supported records cover the current accepted private criteria writer
catalog: one or more selected tags with All/Any-selected-tags semantics, Untagged Notes Only, pinned/unpinned, shared/
not-shared, folder/not-folder, locked/unlocked, Quick Notes/not Quick Notes,
attachment family criteria, checklist state criteria, created/edited date
criteria, selected participant and mention criteria, math, call, system paper,
and recently deleted math. Rejected records explicitly account for unsupported tag
operator/mode semantics, missing private tag hints, participant/mention
identity comparison without private hash
evidence, raw-value or object-bound filters without semantic readback, and
unreviewed OS-specific filter types because they are not current Apple Notes
guide capabilities. Runtime filter add/update/remove still refuses existing
criteria that cannot be reconstructed from privacy-safe private readback. It
does not print tag names, folder
identifiers, participant identifiers, criteria raw values, note bodies, or
private object values.

`smart-folders create` is available in default private-framework-backed builds for one
or more existing visible tags in one account, with default All-selected-tags
matching or explicit Any-selected-tags matching:

```bash
apple notes smart-folders create --name Focus --account ACCOUNT_ID --tag Work,Urgent --match any --dry-run --json
```

Execution verifies the created Smart Folder's account, query presence, selected
tag count, tag-selection operator/mode, matching-note count, and visible-note
count when Notes reports it.

`smart-folders update` is available in default private-framework-backed builds for
replacing one editable Smart Folder's criteria with one or more existing visible tags in
the same account:

```bash
apple notes smart-folders update --folder Focus --account ACCOUNT_ID --tag Work,Urgent --match all --dry-run --json
```

Execution preserves the Smart Folder identity, name, and account, replaces the
criteria with a private `ICTagSelection` query, and verifies selected tag count,
tag-selection operator/mode, matching-note count, and visible-note count when
Notes reports it. Broader
criteria construction and multi-condition criteria editing remain gated.

`smart-folders create-criteria` and `smart-folders update-criteria` are
available in default private-framework-backed builds for the promoted built-in,
folder-object, date, participant, mention, and single Untagged criteria set
`pinned`, `unpinned`, `shared`, `not-shared`, `folder`, `not-folder`,
`untagged`, `math`, `call`,
`system-paper`, `recently-deleted-math`, `locked`, `unlocked`, `quick-notes`,
`not-quick-notes`, `attachments`, `no-attachments`,
`attachment-photo-video`, `attachment-scans`, `attachment-drawings`,
`attachment-maps`, `attachment-websites`, `attachment-audio`,
`attachment-documents`, `checklists`, `incomplete-checklists`,
`completed-checklists`, `no-checklists`, `created-today`,
`created-yesterday`, `created-last-7-days`, `created-last-30-days`,
`created-last-3-months`, `created-last-12-months`, `created-on`,
`created-before`, `created-after`, `created-between`, `created-relative`,
`edited-today`, `edited-yesterday`, `edited-last-7-days`,
`edited-last-30-days`, `edited-last-3-months`, `edited-last-12-months`,
`edited-on`, `edited-before`, `edited-after`, `edited-between`,
`edited-relative`, `participants`, and `mentions`:

```bash
apple notes smart-folders create-criteria \
  --name Pinned \
  --account ACCOUNT_ID \
  --criteria pinned \
  --dry-run \
  --json

apple notes smart-folders update-criteria \
  --folder Pinned \
  --account ACCOUNT_ID \
  --criteria system-paper \
  --include-recently-deleted \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name Documents \
  --account ACCOUNT_ID \
  --criteria attachment-documents \
  --dry-run \
  --json

apple notes smart-folders update-criteria \
  --folder Tasks \
  --account ACCOUNT_ID \
  --criteria incomplete-checklists \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name Work \
  --account ACCOUNT_ID \
  --criteria folder \
  --criteria-folder Work \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name Untagged \
  --account ACCOUNT_ID \
  --criteria untagged \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name WorkOrArchive \
  --account ACCOUNT_ID \
  --criteria folder,unlocked \
  --criteria-folder Work,Archive \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name CreatedThisMonth \
  --account ACCOUNT_ID \
  --criteria created-between \
  --start-date 2026-06-01 \
  --end-date 2026-06-20 \
  --dry-run \
  --json

apple notes smart-folders update-criteria \
  --folder RecentEdits \
  --account ACCOUNT_ID \
  --criteria edited-relative \
  --relative-amount 2 \
  --relative-unit weeks \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name SharedWithPerson \
  --account ACCOUNT_ID \
  --criteria participants \
  --participant-user-id PARTICIPANT_USER_ID \
  --dry-run \
  --json

apple notes smart-folders update-criteria \
  --folder Mentions \
  --account ACCOUNT_ID \
  --criteria mentions \
  --participant-user-id PARTICIPANT_USER_ID \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name FocusedShared \
  --account ACCOUNT_ID \
  --criteria pinned,shared,participants \
  --participant-user-id PARTICIPANT_USER_ID \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name MathPinned \
  --account ACCOUNT_ID \
  --criteria math,pinned \
  --dry-run \
  --json

apple notes smart-folders create-criteria \
  --name PinnedOrUnshared \
  --account ACCOUNT_ID \
  --criteria pinned,not-shared \
  --match any \
  --dry-run \
  --json
```

Execution builds the private Notes query for the selected promoted criteria or
comma-separated All/Any combination of promoted private filter-selection
criteria plus the `math`, `call`, `system-paper`, and
`recently-deleted-math` query-factory criteria that expose private filter
selections for combination. Single `untagged` criteria use private
`ICTagSelection.mode` 2 (All Untagged) and verify selected-tag count 0 plus
matching-note readback; `untagged` is not accepted inside comma-separated
combinations yet. Use `--match all` for the default AND behavior or
`--match any` for OR behavior; the verifier reads the private join operator
back from the created or updated Smart Folder. It optionally includes recently
deleted notes when that private query factory or filter-selection path accepts
the flag; `recently-deleted-math` carries that scope through its dedicated
criterion and still rejects the explicit flag. It verifies criteria readback
plus matching-note count. Attachment, checklist, date, folder, participant,
mention, locked, Quick Note, pinned, shared, math, call, system-paper, and
recently-deleted-math combination criteria use typed private filter selections,
not raw criteria JSON. Single `folder` or
`not-folder` criteria use `--criteria-folder FOLDER[,FOLDER...]`; a combined
`folder,not-folder` command uses `--include-criteria-folder` and
`--exclude-criteria-folder` to bind separate included and excluded folder sets.
Every target must be a concrete visible folder in the same account, and command
output reports selected-folder count plus hash evidence. Single-date criteria use
`--date YYYY-MM-DD`; range criteria use `--start-date` and `--end-date`;
relative date criteria use `--relative-amount` plus `--relative-unit
hours|days|weeks|months|years`. Participant and mention criteria use an
explicit opaque `--participant-user-id`; command JSON hashes that value and
reports selected-user count evidence rather than printing participant
identifiers. Combined criteria are supported when every selected kind can be
represented by a private filter selection; `math`, `call`, `system-paper`, and
`recently-deleted-math` are accepted in combinations through private
query-factory extraction. `recently-deleted-math` rejects
`--include-recently-deleted` because it already uses the dedicated recently
deleted math-note query. `untagged` is accepted only as a single criteria kind
until a private filter-selection equivalent is proven. Results do not print raw
criteria JSON, predicate text, raw filter values, raw criteria folder identifiers, note bodies, or private class
names. Participant/mention identity comparison when private hash evidence is
unavailable, broader mention object-bound comparison, arbitrary
criteria beyond promoted private filter-selection/query-factory combinations,
richer shared-state criteria, raw-value comparison without semantic readback,
remaining tag
identifier/object-bound filter
comparison beyond accepted folder/not-folder, and arbitrary/full
multi-condition boolean tracing beyond supported-filter trace remain gated.

`smart-folders duplicate` and `smart-folders copy-criteria` are available in
default private-framework-backed builds for existing Smart Folder criteria reuse:

```bash
apple notes smart-folders duplicate \
  --folder Focus \
  --account ACCOUNT_ID \
  --name FocusCopy \
  --dry-run \
  --json

apple notes smart-folders copy-criteria \
  --from Focus \
  --to Archive \
  --account ACCOUNT_ID \
  --dry-run \
  --json
```

The duplicate path creates a new same-account Smart Folder from the source
private query. The copy path replaces one editable same-account target Smart
Folder's criteria with the source private query. Results verify source/target
identity boundaries, criteria summary preservation, matching-note count, and
visible-note count when Notes reports it without printing raw criteria JSON.

`smart-folders export-criteria` and `smart-folders import-criteria` are available
in default private-framework-backed builds for raw criteria artifact round trips:

```bash
apple notes smart-folders export-criteria \
  --folder Focus \
  --account ACCOUNT_ID \
  --output ./Focus.criteria.json \
  --dry-run \
  --json

apple notes smart-folders export-criteria \
  --folder Focus \
  --account ACCOUNT_ID \
  --output ./Focus.criteria.json \
  --allow-artifact-action \
  --json

apple notes smart-folders import-criteria \
  --folder Archive \
  --account ACCOUNT_ID \
  --file ./Focus.criteria.json \
  --dry-run \
  --json
```

Export writes only to a user-selected `.json` path, refuses existing
destinations, requires `--allow-artifact-action` for execution, and verifies file
existence, byte count, SHA-256, JSON readability, source query presence, and
Smart Folder readback. Import validates a UTF-8 JSON object or array, replaces
one editable Smart Folder's criteria through private read/write APIs, and
verifies imported query hash/length, identity/name/account preservation,
criteria summary readback, and matching-note readback. Command JSON does not
print the raw criteria JSON except in the explicit exported artifact.

`smart-folders rename` is available in default private-framework-backed builds for one
editable Smart Folder:

```bash
apple notes smart-folders rename --folder Focus --account ACCOUNT_ID --name Archive --dry-run --json
```

Execution preserves the Smart Folder identity, account, query, and visible-note
count when Notes reports those fields.

`smart-folders delete` is available in default private-framework-backed builds for one
editable Smart Folder:

```bash
apple notes smart-folders delete --folder Focus --account ACCOUNT_ID --dry-run --json
```

Execution deletes only the Smart Folder container, not matching notes, and
verifies that the Smart Folder no longer appears in visible Smart Folder
readback.

`smart-folders convert-folder` is available in default private-framework-backed builds
for one eligible concrete folder:

```bash
apple notes smart-folders convert-folder --folder Projects --account ACCOUNT_ID --dry-run --json

apple notes smart-folders convert-folder \
  --folder Projects \
  --account ACCOUNT_ID \
  --allow-destructive-selection \
  --allow-persistent-action \
  --json
```

Execution follows Apple Notes conversion semantics: every visible note in the
source folder is tagged with the folder name, moved to the account's default
Notes folder, a matching Smart Folder is created, and the source folder is
removed. The command refuses shared, locked, read-only, deleted, default,
system, Smart Folder, trash, or subfolder-containing targets. The result and
verifier report folder IDs, counts, target folder, tag metadata, and note ID
hashes without printing note bodies or raw private criteria.

`smart-folders workflow audit` is available in the default private-framework-backed
build. It accounts for the official Apple Use Smart Folders guide surface
without reading Smart Folders, notes, or criteria:

```bash
apple notes smart-folders workflow audit --json
```

The audit reports 27 workflow records: supported private-framework or
command-layer Smart Folder workflows, delegated Notes.app menu/contextual/
sidebar UI routes, supported filter catalog accounting, supported promoted
filter add/update/remove ordinal mutations, and rejected Apple product limits such as
locking, subfolder nesting, sharing, ineligible conversion, and empty-filter
Smart Folders. Folder conversion, Any/OR rule scope, Untagged Notes Only, and
filter catalog accounting are supported through `convert-folder`, `--match any`,
`--criteria untagged`, and `filters audit`. Use `smart-folders audit` when you
want existing Smart Folder criteria readback; use `smart-folders filters audit`
when you want the filter catalog; use `smart-folders workflow audit` when you
want official guide coverage accounting.

`smart-folders filters add`, `smart-folders filters update`, and
`smart-folders filters remove` support promoted private filter-selection
criteria by reconstructing the current Smart Folder filter list, applying one
ordinal add/update/remove, rewriting the full criteria, and verifying the
filter delta plus matching-note readback. They reject tag-selection, raw-only,
or object-bound criteria that cannot be reconstructed from privacy-safe private
readback.

`tags audit` reports the official Use Tags workflow status without reading tags,
notes, Smart Folders, or note bodies: supported list/search/add/remove/rename/delete paths
including explicit rename-to-existing merge and Smart Folder criteria delta
readback for rename/delete, delegated Notes.app suggestion/sidebar/shared-note
UI surfaces, and supported Convert to Text semantics with private body plaintext
hash preservation readback. No Use Tags workflow remains gated in this target
audit.

Other tag commands are available in default private-framework-backed builds.
`tags list` returns visible Notes tags with account names and bounded visible-use counts.
`tags search` returns visible note summaries for one tag, multiple tags in
All/Any mode, or include/exclude tag sets without printing note bodies or raw
tag selector values. `tags add` and `tags remove` change membership for one note and verify
readback before reporting success. `tags convert-to-text` removes one selected
hashtag token from a note and verifies body plaintext byte-count/hash
preservation plus tag membership absence without printing note body text.
`tags rename` renames one visible tag across
affected visible notes and verifies affected-note preservation before reporting
success; `tags rename --allow-merge` merges affected source-tag notes into an
existing target tag, verifies source-tag absence and target membership on the
source affected notes, and does not count pre-existing target-only notes as
affected. `tags delete` removes one visible tag's usage across affected visible
notes, or at least two explicit unique tags with `--tags`. Delete execution
requires `--allow-destructive-selection`, returns hash-only evidence for batch
tag selection, and refuses when the private Smart Folder cascade check reports
that deleting a selected tag would delete Smart Folders.

`attachments list` is available in default private-framework-backed builds. With
`--id NOTE_ID`, it returns metadata for one note's attachments and keeps the
single-note selector surface used by export, rename, remove, Markup, PDF, and
audio commands:

```bash
apple notes attachments list --id NOTE_ID --json
apple notes attachments list --id NOTE_ID --family audio-recording --json
```

Without `--id`, it scans a bounded visible-note selection and returns per-note
visible attachment metadata. Use `--account` and/or `--folder` to limit the
view:

```bash
apple notes attachments list --account ACCOUNT_ID --json
apple notes attachments list --folder FOLDER --json
apple notes attachments list --account ACCOUNT_ID --folder FOLDER --json
apple notes attachments list --folder FOLDER --family scans --json
apple notes attachments list --limit 100 --json
```

The metadata includes identifiers, titles, type hints, content identifiers, file
sizes, media filenames, inline state, and deletion state where applicable. The
collection view filters deleted or trash attachments. It does not read
attachment bytes, note bodies, or local media paths. `--family` narrows the
view by attachment category. Accepted aliases include `photo-video`,
`photo-image`, `video`, `scanned-document`/`scans`, `map-preview`/`maps`,
`webpage-preview`, `pdf`, `audio-recording`, `drawing-or-sketch`, `file`, and
`unknown`.

`attachments search` searches the same attachment metadata surface by name or
type hints without reading note bodies or attachment bytes:

```bash
apple notes attachments search --account ACCOUNT_ID --query "Quarterly" --json
apple notes attachments search --folder FOLDER --query "Quarterly" --json
apple notes attachments search --account ACCOUNT_ID --folder FOLDER --query "scan" --json
apple notes attachments search --folder FOLDER --family scans --query "scan" --json
apple notes attachments search --id NOTE_ID --query "invoice" --json
```

The search checks attachment title, media filename, content identifier, type
UTI, attachment type, and derived attachment family. Results report the query
SHA-256 and byte count, scanned-note and scanned-attachment counts,
matched-field names, matched attachment metadata, and verifier evidence. It does
not read attachment file contents, search inside arbitrary PDFs/images/documents,
export attachments, or expose local media paths. Attachment content search is
supported only where a separate semantic command has accepted verifier proof,
such as existing audio transcript search or embedded PDF text search.

`attachments audit` is available in default private-framework-backed builds for a
bounded visible-note selection:

```bash
apple notes attachments audit --account ACCOUNT_ID --json
apple notes attachments audit --folder FOLDER --json
apple notes attachments audit --account ACCOUNT_ID --folder FOLDER --json
```

The audit aggregates attachment-family counts for photos/images, videos, PDFs,
scanned documents, drawings/sketches, audio recordings, webpage previews, map previews,
files, and unknown attachments. It returns note ID hashes, counts, extension
counts, attachment type counts, supported read families, delegated workflow
families, gated mutation families, and verifier evidence. It does not print note titles, note bodies,
attachment titles, attachment filenames, raw UTIs, local media paths,
transcripts, or attachment bytes. Existing audio title/save/delete operations,
audio transcript metadata/export/copy/search, Markup model inspection/export/apply,
webpage preview add/update, attachment display-title rename, selected
scanned-document crop/rotation/filter/page move/delete, ordinary PDF page
crop/rotate/move/delete, direct image crop/rotate, and generated/fallback PDF
artifact export are supported separately. Scan capture, audio
recording/transcription generation, audio recording append/edit UI, semantic
Markup element/style tool palettes, and Continuity annotate are delegated to
Notes.app or system surfaces. Non-title attachment updates and richer transforms remain gated; selected recognized-text search indexing and hash-only image classification summary readback are supported separately. Arbitrary PDF content edit and transcript text edit are rejected
as current Apple Notes product non-capabilities.

Use `attachments workflow audit` to see the official Notes attachment/media
workflow accounting without reading notes or attachments:

```bash
apple notes attachments workflow audit --json
```

The audit covers the current Add photos/PDFs/more, Manage PDFs/scans, Mark up
attachments, and View attachments guide pages. It returns supported,
delegated, gated, and rejected workflow records: accepted private attachment
metadata/add/export/PDF/search/rename/webpage preview, selected scan
crop/rotation/filter/page move/delete, ordinary PDF crop/rotate/move/delete,
scan/image/drawing searchable-text search, existing recognized-text export,
image crop/rotate, inline image-description alt-text, and Markup model paths are
supported; Photos picker, drag/drop, Continuity, Share sheet, Quick Look,
default-app open, Notes.app attachment view UI, Markup UI, and related system
settings surfaces are delegated, including scan capture through Continuity
Camera and nearby-device Markup annotate; there are no remaining gated workflow
records; hash-only image classification summary readback is supported separately by `attachments image objects`; and arbitrary PDF content edit plus the Exchange
account limitation for file, map, and webpage preview attachments are rejected.
The command does not accept note, attachment, file, or query
selectors and reports `backend_calls: none`.

`attachments add` is available in default private-framework-backed builds for one
editable visible non-password-protected note at a time. Use `--file` for one
attachment, or `--files` with comma-separated paths for a bounded batch:

```bash
apple notes attachments add \
  --id NOTE_ID \
  --file ./Brief.pdf \
  --name Brief.pdf \
  --dry-run \
  --json

apple notes attachments add \
  --id NOTE_ID \
  --file ./Brief.pdf \
  --name Brief.pdf \
  --json

apple notes attachments add \
  --id NOTE_ID \
  --files ./Photo.jpg,./Scan.pdf \
  --dry-run \
  --json
```

The command imports one regular local file, or up to 32 files and 250 MB total
through `--files`, as Notes attachments. `--name` is accepted only with
single-file `--file`. Dry-run shows the target note, filename/count, byte
count or total byte count, and hashes without writing Notes data. Execution
preflights the batch, writes attachments sequentially, and verifies each added
attachment through metadata readback, filename preservation, exported byte
count/SHA-256, plus aggregate attachment-count/total-byte-count and note
readback. It does not print attachment bytes. Locked, password-protected,
read-only, deleted, and trash notes are refused.

`attachments copy` copies an existing attachment from one note to another
editable visible note, or explicitly duplicates it within the same note:

```bash
apple notes attachments copy \
  --id SOURCE_NOTE_ID \
  --attachment ATTACHMENT_ID \
  --target TARGET_NOTE_ID \
  --name Copied.pdf \
  --dry-run \
  --json
```

Execution reads the source attachment through the private attachment export
path, writes the bytes to the target note through the private attachment writer,
and verifies the new attachment by metadata and export-hash readback. Output
includes byte count, SHA-256, hash-only source/target evidence, and new
attachment metadata. It does not print attachment bytes, source local media
paths, note bodies, or raw private identifiers. Locked, password-protected,
read-only, deleted, and trash target notes are refused.

`attachments add-webpage` and `attachments update-webpage` are available in
default private-framework-backed builds for one editable visible non-password-protected
note at a time:

```bash
apple notes attachments add-webpage \
  --id NOTE_ID \
  --url https://example.com/brief \
  --dry-run \
  --json

apple notes attachments update-webpage \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --url https://example.com/updated \
  --dry-run \
  --json
```

`add-webpage` creates one `http` or `https` webpage preview or map preview attachment.
`update-webpage` selects an existing webpage preview or map preview attachment from
`attachments list` and changes it to one new `http` or `https` URL. Execution
verifies link metadata readback, webpage-preview attachment metadata readback,
`webpage_preview` or `map_preview` attachment-family preservation, URL
replacement, and note readback. Ordinary file/PDF/image/audio attachments and
non-preview links are refused.

`attachments rename` is available in default private-framework-backed builds for one
attachment at a time. Select an attachment using an ID from `attachments list`:

```bash
apple notes attachments rename \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --name "Brief renamed.pdf" \
  --dry-run \
  --json

apple notes attachments rename \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --name "Brief renamed.pdf" \
  --json
```

The command changes the attachment display title and leaves attachment bytes
and the media filename unchanged. Execution verifies selected attachment
metadata readback, title hash readback, old-title replacement, and note
readback. Locked, password-protected, read-only, deleted, and trash notes are
refused, as are deleted attachments, non-renamable attachments, unchanged
names, path separators, NUL, newlines, and overlong names. Scan/PDF/audio/markup
content transforms remain gated.

`attachments remove` is available in default private-framework-backed builds for one
attachment at a time. Select an attachment using an ID from `attachments list`:

```bash
apple notes attachments remove \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --dry-run \
  --json

apple notes attachments remove \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --json
```

The command removes one selected attachment from one editable visible note.
Execution verifies attachment metadata absence, attachment export absence, and
note readback. It does not print attachment bytes. Locked, password-protected,
read-only, deleted, and trash notes are refused, as are non-deletable or
already-deleted attachments.

`attachments export` is available in default private-framework-backed builds for one
attachment at a time. Select an attachment using an ID from `attachments list`,
then provide an output file path:

```bash
apple notes attachments export \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Attachment.bin \
  --dry-run \
  --json

apple notes attachments export \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Attachment.bin \
  --allow-artifact-action \
  --json
```

The command refuses existing destinations, requires
`--allow-artifact-action` for execution, and verifies the written file by
existence, byte count, SHA-256, and attachment metadata readback. It does not
print attachment bytes or source local media paths.

`attachments export-pdf` is available in default private-framework-backed builds for
one PDF, scanned-document, or paper attachment at a time. It can use existing
PDF bytes, private fallback PDF data, or a generated document-camera PDF when
Notes exposes one. Select an attachment using an ID from `attachments list`,
then provide a `.pdf` output file path:

```bash
apple notes attachments export-pdf \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Attachment.pdf \
  --dry-run \
  --json

apple notes attachments export-pdf \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Attachment.pdf \
  --allow-artifact-action \
  --json
```

The command refuses existing destinations, requires
`--allow-artifact-action` for execution, and verifies the written PDF by
existence, byte count, SHA-256, `%PDF` header, and attachment metadata
readback. It also reports the privacy-safe PDF source kind, such as existing
media, fallback PDF, or generated document-camera PDF. It does not print
attachment bytes or source local media paths.

`attachments pdf inspect` and `attachments scan inspect` read private PDF/scan
metadata without writing files:

```bash
apple notes attachments pdf inspect \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --json

apple notes attachments scan inspect \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --json
```

`pdf inspect` accepts PDF or scanned-document attachments. `scan inspect`
requires scanned-document evidence. Results include PDF byte count, SHA-256,
page count, source kind, orientation value/hash, scan metadata
presence/count/hash, document-camera PDF version evidence when available, and
verifier checks. They do not print PDF text, scan images, crop geometry,
attachment bytes, local media paths, or raw private objects. Selected
scanned-document crop/rotation/filter/page move/delete are supported separately by
`attachments scan crop`, `attachments scan rotate`, `attachments scan filter`, `attachments scan page
move`, and `attachments scan page delete`; ordinary PDF crop/rotate/move/delete
is supported separately by `attachments pdf crop`, `attachments pdf page rotate`,
`attachments pdf page move`, and `attachments pdf page delete`; OCR/index
mutation remains gated, while arbitrary PDF content edit is rejected as a
product non-capability.

`attachments pdf search` searches embedded text in existing PDF, scanned-document,
or paper attachments when Notes exposes PDF bytes and PDFKit can extract text:

```bash
apple notes attachments pdf search --query "invoice" --json
apple notes attachments pdf search --account ACCOUNT_ID --query "invoice" --json
apple notes attachments pdf search --folder FOLDER --query "invoice" --json
apple notes attachments pdf search --id NOTE_ID --query "invoice" --json
```

The result reports query SHA-256, scanned-note and scanned-attachment counts,
PDF source kind, page count, PDF/text byte counts, SHA-256 hashes, match counts,
note/attachment metadata, skipped PDF count, and verifier evidence. It does not
print raw query text, extracted PDF text, attachment bytes, scan image data, or
local media paths. Existing scan searchable text is supported separately by
`attachments scan search`; PDF search itself does not OCR image-only scans, but
`attachments recognized-text generate` can produce a separate `.txt` artifact
from private attachment media/PDF bytes. `attachments recognized-text index` supports selected-attachment search indexing through the private CoreSpotlight reindexer.

Visual-content search surfaces read existing private searchable text:

```bash
apple notes attachments scan search --query "receipt" --json
apple notes attachments image search --account ACCOUNT_ID --query "diagram" --json
apple notes attachments drawing search --id NOTE_ID --query "whiteboard" --json
```

These commands validate query and selector shape, scan a bounded note selection,
filter to scanned-document, photo/image, or drawing/sketch attachments, and read
existing `ICAttachment`/`ICAttachment.attachmentModel` searchable/indexable text.
They return query hashes, content hashes, byte counts, match counts, source
kinds, note metadata, and attachment metadata only. They do not print raw query
text, raw searchable text, OCR text, scan images, image bytes, drawing bytes,
handwriting strokes, note bodies, or local media paths. Generated recognized-text
artifacts are supported separately by `attachments recognized-text generate`;
arbitrary attachment-content semantics beyond the accepted composite search slices remain
gated.

Export existing recognized/searchable text, or generate recognized text from
private attachment media/PDF bytes, for one scan, image, or drawing attachment
to an explicit text artifact:

```bash
apple notes attachments recognized-text export \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --family image \
  --output ./recognized.txt \
  --dry-run \
  --json

apple notes attachments recognized-text export \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./recognized.txt \
  --allow-artifact-action \
  --json

apple notes attachments recognized-text generate \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --family scan \
  --output ./recognized.txt \
  --dry-run \
  --json

apple notes attachments recognized-text generate \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./recognized.txt \
  --allow-artifact-action \
  --json

apple notes attachments recognized-text index \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --family image \
  --dry-run \
  --json

apple notes attachments recognized-text index \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --allow-persistent-action \
  --json
```

`--family scan|image|drawing` is optional and acts as a guard against selecting
the wrong attachment family. Dry-run reports only hashes, byte counts,
content/source kinds, normalized selector evidence, and generated-text
observation counts when generation is requested. Execution requires
`--allow-artifact-action` for export/generate artifacts, writes the existing or
generated recognized text to a new `.txt` file, and verifies the artifact
SHA-256 against fresh private searchable-text or attachment media/PDF readback.
`recognized-text index` requires `--allow-persistent-action`, reindexes the
selected attachment through the private CoreSpotlight reindexer, and reports
only the implementation call, completion status, and object URI hash. These commands do
not print recognized text, scan images,
image bytes, drawing bytes, note bodies, raw Core Data URIs, or attachment bytes
in JSON.

`attachments markup inspect` and `attachments markup edit` are available in
default private-framework-backed builds for one selected attachment at a time:

```bash
apple notes attachments markup inspect \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --json

apple notes attachments markup inspect \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Attachment.markupdata \
  --dry-run \
  --json

apple notes attachments markup inspect \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Attachment.markupdata \
  --allow-artifact-action \
  --json

apple notes attachments markup edit \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --file ./Attachment.markupdata \
  --dry-run \
  --json

apple notes attachments markup edit \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --file ./Attachment.markupdata \
  --json
```

Without `--output`, the command reports whether private
`ICMarkupUtilities` can derive Markup model data from the selected
attachment's media bytes, plus byte counts, SHA-256 hashes, source kind, and
verifier evidence. With `--output`, it writes the Markup model bytes to a new
artifact and verifies destination existence, byte count, SHA-256, and
attachment metadata readback. It does not print attachment bytes or Markup
bytes. `attachments markup edit --file MODEL` applies one user-provided Markup
model file to a selected PDF, scanned-document, or image attachment and verifies
the same model byte count and SHA-256 through private readback. It does not
implement the full Notes Markup UI tools such as scan filters, PDF rotation,
shapes, style/color tools, Continuity annotate, or signatures. `attachments image description get/set` reads or writes
private inline `ICInlineAttachment.altText` for selected inline image-family
attachments and reports only description hashes and byte counts. Generated
recognized-text artifacts are supported separately by `attachments
recognized-text generate`; hash-only image classification summary readback is supported under
`attachments image objects`; selected-attachment search indexing is supported by `attachments recognized-text index`.
Element-level/style Markup tools return delegated Markup tool-palette metadata
under `attachments markup
add-shape/add-text/add-signature/highlight/sketch/draw/shape-style/border-color/fill-color/text-style`;
`attachments markup annotate` returns delegated Continuity metadata. These
boundaries return structured no-implementation-call refusal metadata.

```bash
apple notes attachments image description get --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments image description set --id NOTE_ID --attachment ATTACHMENT_ID --description DESCRIPTION --json
```

The image description commands operate on one inline image-family attachment.
`set --description ""` clears the description. JSON output includes presence,
byte-count, SHA-256, source-kind, and verifier fields, but not the raw
description or image bytes.

Image crop and rotate are direct private media mutations for one selected
photo/image attachment:

```bash
apple notes attachments image crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left 0.10,0.10 --top-right 0.90,0.10 --bottom-right 0.90,0.90 --bottom-left 0.10,0.90 --json
apple notes attachments image rotate --id NOTE_ID --attachment ATTACHMENT_ID --direction right --json
```

The commands read private image bytes, apply an axis-aligned normalized crop or
quarter-turn rotation, write the transformed media back through the private
attachment media path, and verify byte-count plus SHA-256 delta readback. JSON
output includes hashes, byte counts, source kind, requested operation evidence,
and verifier checks, but not image pixels, attachment bytes, crop geometry, note
bodies, or local media paths.

Use `attachments audio audit` to see the current Apple Notes audio workflow
accounting without reading notes or attachments:

```bash
apple notes attachments audio audit --json
```

The audit accounts for the audio guide surface as supported, delegated, or
rejected. Supported workflows include existing audio title rename, save,
delete, existing transcript read/export/search/copy, and existing summary
readback. Delegated workflows include Notes playback controls, Share Audio, and
Apple Intelligence summary generation, audio recording, recording pause/resume,
live note editing while recording, appending to a recording, and transcription
generation. Transcript text editing is rejected because the current Apple Notes
guide exposes viewing, searching, and copying transcript text, not editing it.
The audit reports 19 records: 8 supported, 10 delegated, 0 gated, and 1
rejected. It does not
require or accept note or attachment selectors and reports `backend_calls:
none`.

`attachments audio rename`, `attachments audio save`, and `attachments audio
delete` are available for existing audio recording attachments in
default private-framework-backed builds:

```bash
apple notes attachments audio rename \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --name "Team recording.m4a" \
  --json

apple notes attachments audio save \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --output ./Team.m4a \
  --allow-artifact-action \
  --json

apple notes attachments audio delete \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --dry-run \
  --json
```

These commands require the selected attachment to read back as the
`audio_recording` family. Rename verifies title readback, save writes the
selected audio bytes only to an explicit file and verifies byte count/SHA-256,
and delete verifies attachment metadata and export absence. They do not print
audio bytes, transcript text, or local media paths. Use `--dry-run` to preview
the mutation or artifact write; `audio save` requires `--allow-artifact-action`
for execution.

`attachments audio transcript` is available in default private-framework-backed builds
for one audio attachment at a time. Select an attachment using an ID from
`attachments list`:

```bash
apple notes attachments audio transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --json

apple notes attachments audio transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --content summary \
  --output ./Summary.txt \
  --dry-run \
  --json

apple notes attachments audio transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --content summary \
  --output ./Summary.txt \
  --allow-artifact-action \
  --json
```

Without `--output`, the command reads existing transcript, recording-summary,
and top-line-summary metadata only: presence, byte counts, SHA-256 hashes,
transcript version, source kind, and verifier evidence. It does not print
transcript text. With `--output`, the command exports one selected content kind
(`transcript`, `summary`, or `topline-summary`) to a new `.txt` file, requires
`--allow-artifact-action` for execution, and verifies the artifact by
destination existence, byte count, SHA-256, and attachment metadata readback.
This command does not record audio or trigger Notes transcription generation.

`attachments audio copy-transcript` copies existing transcript-family text into
a note body through the private Notes append path by default, or to the system
clipboard through a delegated pasteboard write:

```bash
apple notes attachments audio copy-transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --target TARGET_NOTE_ID \
  --json

apple notes attachments audio copy-transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --content summary \
  --dry-run \
  --json

apple notes attachments audio copy-transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --scope clipboard \
  --content transcript \
  --dry-run \
  --json

apple notes attachments audio copy-transcript \
  --id NOTE_ID \
  --attachment ATTACHMENT_ID \
  --scope clipboard \
  --content transcript \
  --allow-persistent-action \
  --json
```

`--id` selects the note containing the audio attachment. `--scope note` is the
default. In note scope, `--target` selects the note to receive the copied text
and defaults to `--id`; the target must be a visible editable non-trash note.
`--scope clipboard` writes the selected text to the system clipboard, refuses
`--target`, and requires `--allow-persistent-action` for execution. The command
supports `--content transcript`, `--content summary`, and
`--content topline-summary`. It verifies source audio-document readback, copied
text byte count/SHA-256, attachment metadata readback, and either target note
suffix readback or clipboard text readback/change-count evidence. It does not
print the copied transcript, target note body, or clipboard text. It does not
record audio, generate a new transcript, or edit transcript content.

`attachments audio search` searches existing transcript, recording-summary,
and top-line-summary content for audio attachments in default private-framework-backed
builds. It scans a bounded visible-note selection by default, or one selected
note with `--id`:

```bash
apple notes attachments audio search \
  --query "follow up" \
  --json

apple notes attachments audio search \
  --account iCloud \
  --query "follow up" \
  --json

apple notes attachments audio search \
  --folder Meetings \
  --query "budget" \
  --content transcript \
  --json

apple notes attachments audio search \
  --id NOTE_ID \
  --query "readback" \
  --content summary \
  --json
```

The result reports the query SHA-256 and byte count, scanned-note and scanned
audio-attachment counts, matched note/attachment metadata, content kind,
match count, byte count, content SHA-256, transcript version, source kind, and
verifier evidence. It does not print the raw query or transcript text. Audio
attachments without an existing audio-document transcript are skipped and
counted. The command does not record audio, generate transcription, or edit
transcripts.

Rotate one existing scanned-document attachment in an editable visible note:

```bash
apple notes attachments scan rotate --id NOTE_ID --attachment ATTACHMENT_ID --by 90 --dry-run --json
apple notes attachments scan rotate --id NOTE_ID --attachment ATTACHMENT_ID --direction right --json
```

The command accepts `--by -270|-180|-90|90|180|270` or `--direction
left|right|clockwise|counterclockwise|cw|ccw`. It uses the private
`ICDocCamScannedDocumentEditor.setOrientation` path, verifies before/after
`ICAttachment.orientation` readback, and does not print scan images, PDF text,
attachment bytes, crop geometry, local media paths, or raw private objects. It
requires scanned-document evidence and refuses locked, read-only, deleted, or
trash notes.

Crop one existing scanned-document attachment in an editable visible note:

```bash
apple notes attachments scan crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left 0.05,0.05 --top-right 0.95,0.05 --bottom-right 0.95,0.95 --bottom-left 0.05,0.95 --dry-run --json
apple notes attachments scan crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left 0.10,0.12 --top-right 0.91,0.10 --bottom-right 0.88,0.93 --bottom-left 0.08,0.90 --json
```

Crop points are normalized `x,y` values from 0 through 1 in the scanned-document
page coordinate space. The command uses private `ICAttachment.croppingQuad`
metadata plus `ICDocCamScannedDocumentEditor.setQuad`, verifies crop metadata
hash delta and page-count preservation, and does not print crop geometry, scan
images, PDF text, attachment bytes, local media paths, or raw private objects.
Ordinary PDF crop is supported separately by `attachments pdf crop`; arbitrary
PDF content edit is rejected under `attachments pdf edit` because it is not an
Apple Notes product capability.

Apply a filter to one existing scanned-document attachment in an editable visible note:

```bash
apple notes attachments scan filter --id NOTE_ID --attachment ATTACHMENT_ID --style grayscale --dry-run --json
apple notes attachments scan filter --id NOTE_ID --attachment ATTACHMENT_ID --style black-and-white --json
```

The command accepts `--style color|grayscale|black-and-white|photo`. It uses
the private `ICDocCamScannedDocumentEditor.applyFilter` path, verifies
before/after `ICAttachment.imageFilterType` readback, and does not print scan
images, PDF text, attachment bytes, crop geometry, local media paths, or raw
private objects. It requires scanned-document evidence and refuses locked,
read-only, deleted, trash, or unchanged filter targets.

Move or delete one page in an existing scanned-document attachment:

```bash
apple notes attachments scan page move --id NOTE_ID --attachment ATTACHMENT_ID --from 1 --to 3 --dry-run --json
apple notes attachments scan page delete --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 2 --json
```

Page numbers are 1-based. Page move uses the private
`ICDocCamScannedDocumentEditor.movePageFromIndex` path and preserves page count;
page delete uses `ICDocCamScannedDocumentEditor.deletePagesAtIndexes` and refuses
to remove the only page. Both commands verify PDF page count plus PDF/scan
metadata hash readback and do not print scan images, PDF text, attachment bytes,
crop geometry, local media paths, or raw private objects.

Crop, rotate, move, or delete one page in an existing ordinary PDF attachment:

```bash
apple notes attachments pdf crop --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 1 --top-left 0.10,0.10 --top-right 0.90,0.10 --bottom-right 0.90,0.85 --bottom-left 0.10,0.85 --dry-run --json
apple notes attachments pdf page rotate --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 1 --by 90 --dry-run --json
apple notes attachments pdf page move --id NOTE_ID --attachment ATTACHMENT_ID --from 1 --to 3 --json
apple notes attachments pdf page delete --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 2 --json
```

Page numbers are 1-based. PDF crop takes an axis-aligned normalized crop
rectangle using `--top-left`, `--top-right`, `--bottom-right`, and
`--bottom-left`; PDF page rotation accepts `--by` degrees or `--direction
left|right|clockwise|counterclockwise|cw|ccw`. These commands operate only on
directly writable ordinary PDF media; scanned documents and fallback/generated
PDF sources stay on their own scan/export paths. Execution rewrites the PDF
media through the private attachment writer, verifies page count, crop/rotation
or order/delete hash delta, PDF SHA-256 readback, and attachment metadata, and
does not print crop geometry, page images, PDF text, attachment bytes, local
media paths, or raw private objects. `attachments image objects --id NOTE_ID
--attachment ATTACHMENT_ID [--query TEXT]` reads private image classification
summary metadata for one photo/image attachment and returns only presence, byte
counts, hashes, version, optional query hash, and match count. It does not print
raw object labels, query text, image pixels, attachment bytes, note bodies, or
local media paths.

Media workflow commands that are not direct accepted private Notes operations
return explicit unsupported-operation metadata. Scan capture, audio recording,
audio transcription generation, audio recording append/edit UI, semantic Markup
element/style tools, and Continuity annotate are delegated surfaces; arbitrary
PDF content editing and transcript text editing are rejected as current Apple
Notes product non-capabilities:

```bash
apple notes attachments scan capture --id NOTE_ID --json
apple notes attachments pdf edit --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments markup add-shape --id NOTE_ID --attachment ATTACHMENT_ID --shape SHAPE --json
apple notes attachments markup add-text --id NOTE_ID --attachment ATTACHMENT_ID --text TEXT --json
apple notes attachments markup add-signature --id NOTE_ID --attachment ATTACHMENT_ID --signature SIGNATURE --json
apple notes attachments markup highlight --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments markup sketch --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments markup draw --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments markup shape-style --id NOTE_ID --attachment ATTACHMENT_ID --style STYLE --json
apple notes attachments markup border-color --id NOTE_ID --attachment ATTACHMENT_ID --color COLOR --json
apple notes attachments markup fill-color --id NOTE_ID --attachment ATTACHMENT_ID --color COLOR --json
apple notes attachments markup text-style --id NOTE_ID --attachment ATTACHMENT_ID --style STYLE --json
apple notes attachments markup annotate --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments audio record --id NOTE_ID --json
apple notes attachments audio transcribe --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments audio edit --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments audio edit-transcript --id NOTE_ID --attachment ATTACHMENT_ID --json
```

These commands validate the required selectors, then return
`unsupported_operation` with `status: delegated` for scan/audio capture,
generation, Markup tool-palette, or nearby-device annotate surfaces, or `status: gated` for
remaining private media semantic gaps. Delegated responses use
`required_implementation: delegated_notes_app_or_system_surface` and
`required_verifier: delegated_ui_or_system_accounting`; gated responses use
`required_implementation: typed_private_notes_framework` and
`required_verifier: private_framework_attachment_readback+media_operation_delta`.
All responses report `backend_calls: none`. They do not mutate Notes data and do not echo note
IDs, attachment IDs, output paths, raw recognized text, object prompts, image
descriptions, style/color values, Markup text,
signature identifiers, selection text, device names, local media paths,
transcript text, or attachment bytes in the refusal details. Actual scan
capture, audio recording, audio transcription generation, semantic Markup
element/style tools, and nearby-device annotate remain delegated to
Notes.app/system surfaces. Arbitrary attachment-content semantics
beyond the accepted composite search slices, and non-title attachment transforms
remain gated until private-framework operation or search/index proof and
verifier readback are accepted. Arbitrary PDF content edit is rejected as a
product non-capability. Existing
scan/image/drawing searchable-text search is supported by `attachments scan search`,
`attachments image search`, and `attachments drawing search`; existing
recognized-text export is supported by `attachments recognized-text export`. Existing
audio recording title/save/delete is supported by `attachments audio
rename/save/delete`, transcript read/export is supported by `attachments audio
transcript`, existing transcript copy-to-note and delegated clipboard copy are supported by
`attachments audio copy-transcript`, existing transcript search is supported by
`attachments audio search`, ordinary PDF crop/rotate/move/delete is supported by
`attachments pdf crop` and `attachments pdf page rotate/move/delete`, and Markup model read/export/apply is
supported by `attachments markup inspect` and `attachments markup edit`; direct
image crop/rotate is supported by `attachments image crop` and `attachments
image rotate`; all
remain separate from delegated scan/audio generation/append surfaces, gated PDF
or visual-recognition workflows, and the rejected transcript-edit non-capability.

`export pdf` is available in default private-framework-backed builds for one visible
non-password-protected note or one password-protected note already unlocked in
the current Notes session:

```bash
apple notes export pdf \
  --id NOTE_ID \
  --output ./Note.pdf \
  --dry-run \
  --json

apple notes export pdf \
  --id NOTE_ID \
  --output ./Note.pdf \
  --allow-artifact-action \
  --json
```

The command uses the private Notes editor PDF path, refuses existing
destinations, requires a `.pdf` output path, requires `--allow-artifact-action`
for execution, and verifies destination existence, byte count, SHA-256, PDF
header, protected-state boundary, and note readback. Protected note titles and
bodies are not printed in JSON/stdout. Still-locked, deleted, and trashed notes
remain gated.

`print` is available for one visible non-password-protected note or one
password-protected note already unlocked in the current Notes session. It uses
the same private PDF generation path as `export pdf`, then delegates the
generated PDF bytes to the system print service:

```bash
apple notes print \
  --id NOTE_ID \
  --printer PRINTER_NAME \
  --dry-run \
  --json

apple notes print \
  --id NOTE_ID \
  --printer PRINTER_NAME \
  --allow-external-dispatch \
  --json
```

Dry-run reports the selected note, printer, PDF byte count, and PDF SHA-256
without submitting a print job. Execution requires
`--allow-external-dispatch`; the result records the printer, submitted job ID,
PDF byte count, PDF SHA-256, and verification evidence. The command does not
print note bodies or protected note titles. Still-locked, deleted, and trashed
notes remain gated.

`export markdown` is available in default private-framework-backed builds for one
visible non-password-protected note or one password-protected note already
unlocked in the current Notes session. By default it writes one single-file
Markdown artifact without packaged resources:

```bash
apple notes export markdown \
  --id NOTE_ID \
  --output ./Note.md \
  --dry-run \
  --json

apple notes export markdown \
  --id NOTE_ID \
  --output ./Note.md \
  --allow-artifact-action \
  --json
```

For notes with exportable attachment resources, add `--include-attachments` and
use a package output path:

```bash
apple notes export markdown \
  --id NOTE_ID \
  --output ./Note.mdpkg \
  --include-attachments \
  --dry-run \
  --json

apple notes export markdown \
  --id NOTE_ID \
  --output ./Note.mdpkg \
  --include-attachments \
  --allow-artifact-action \
  --json
```

Single-file output requires `.md` or `.markdown`; package output requires
`.mdpkg` or `.markdownpackage`. The command uses the private Notes Markdown
conversion path, refuses existing destinations, requires
`--allow-artifact-action` for execution, and verifies the artifact before
reporting success. Single-file verification checks destination existence, byte
count, SHA-256, UTF-8/nonempty Markdown, protected-state boundary, and note
readback. Package
verification checks directory existence, file count, total byte count, tree
SHA-256, a Markdown member, attachment resource count, attachment policy, and
protected-state boundary plus note readback. Output does not print protected
note titles, note bodies, Markdown text, resource bytes, source media paths, or
raw private IDs. Still-locked, deleted, and trashed notes remain gated.
Markdown package resource
import/round-trip and Markdown single-file relative image resource import are
supported separately by `import markdown --include-attachments`.

`export html` is available in default private-framework-backed builds for one visible
non-password-protected note or one password-protected note already unlocked in
the current Notes session. Use a `.html` output for single-file HTML. For notes
with exportable attachment resources, add
`--include-attachments` and use a `.htmlpkg` or `.htmlpackage` output package
so resources are written under `Resources/` instead of being silently dropped:

```bash
apple notes export html \
  --id NOTE_ID \
  --output ./Note.html \
  --dry-run \
  --json

apple notes export html \
  --id NOTE_ID \
  --output ./Note.html \
  --allow-artifact-action \
  --json

apple notes export html \
  --id NOTE_ID \
  --output ./Note.htmlpkg \
  --include-attachments \
  --allow-artifact-action \
  --json
```

The command uses the private Notes HTML conversion path, refuses existing
destinations, requires `--allow-artifact-action` for execution, and verifies
either file byte count/SHA-256/HTML marker or package file count/total byte
count/tree SHA-256/HTML member/resource count, plus attachment-policy
preservation, protected-state boundary, and note readback. Protected note
titles and bodies are not printed in JSON/stdout. Still-locked, deleted, and
trashed notes remain gated. Accepted package resource preservation is supported
through HTML package verification, while unbounded perfect conversion fidelity
is rejected by `export audit` as a non-current-guide guarantee.

`export rtf` is available in default private-framework-backed builds for one visible
non-password-protected note or one password-protected note already unlocked in
the current Notes session when the private RTFD export contains a single RTF
file and no package resources:

```bash
apple notes export rtf \
  --id NOTE_ID \
  --output ./Note.rtf \
  --dry-run \
  --json

apple notes export rtf \
  --id NOTE_ID \
  --output ./Note.rtf \
  --allow-artifact-action \
  --json
```

The command uses the private Notes share exporter path, refuses existing
destinations, requires a `.rtf` output path, requires
`--allow-artifact-action` for execution, and verifies destination existence,
byte count, SHA-256, RTF header, protected-state boundary, and note readback.
If the generated package contains attachments or other resources, the command
refuses instead of dropping content; use `export rtfd` for those notes.
Protected note titles and bodies are not printed in JSON/stdout. Still-locked,
deleted, and trashed notes remain gated.

`export rtfd` is available in default private-framework-backed builds for one visible
non-password-protected note or one password-protected note already unlocked in
the current Notes session:

```bash
apple notes export rtfd \
  --id NOTE_ID \
  --output ./Note.rtfd \
  --dry-run \
  --json

apple notes export rtfd \
  --id NOTE_ID \
  --output ./Note.rtfd \
  --allow-artifact-action \
  --json
```

The command uses the private Notes share exporter path, refuses existing
destinations, requires a `.rtfd` output package path, requires
`--allow-artifact-action` for execution, and verifies package existence,
directory state, file count, total byte count, tree SHA-256, RTF member
presence, protected-state boundary, and note readback. Protected note titles
and bodies are not printed in JSON/stdout. Still-locked, deleted, and trashed
notes remain gated.

`links list` is available in default private-framework-backed builds. It returns
metadata for one note's inline links, including identifiers, kind, display/alt
text, public web URL strings, URL schemes, and hashes. Local file URLs and
app URLs, plus internal Notes link tokens, are hashed instead of printed raw.

`links audit` accounts for the current Apple Links guide workflows without
reading a note or calling the Notes implementation:

```bash
apple notes links audit --json
```

The audit reports supported private-framework link reads and writes, supported
selected-text web/app/file URL link conversion, supported note-link display-text
and target-title display semantics, and delegated Notes.app/macOS UI surfaces
such as Smart Links, Command-K, typeahead, active app capture, Quick Note
thumbnails, and link-color appearance settings. It rejects note/link/text/URL
selectors because it is a workflow accounting command, not a note read or
mutation.

`links backlinks` is available in default private-framework-backed builds. It returns
visible source notes that link to one target note plus privacy-safe metadata for
the incoming link:

```bash
apple notes links backlinks \
  --id TARGET_NOTE_ID \
  --json
```

The output includes source note summaries and link identifiers, kind,
display/alt text, URL schemes, and hashes. It does not print source or target
note bodies, raw local file/app URLs, paragraph UUIDs, or raw internal link
tokens.

`links resolve` is available in default private-framework-backed builds. It resolves
one selected link from `links list` without exposing private link tokens or
local paths:

```bash
apple notes links resolve \
  --id NOTE_ID \
  --link LINK_ID \
  --json
```

Public web URLs may be printed. App and file links return scheme and SHA-256
evidence only. Note and paragraph links return target note identity/hash and,
for paragraph links, the target paragraph hash. The result does not print note
bodies, raw internal link tokens, raw paragraph UUIDs, paragraph titles, raw
app URLs, or raw local file URLs.

`links add` is available in default private-framework-backed builds for one web URL at
a time:

```bash
apple notes links add \
  --id NOTE_ID \
  --url https://example.com/brief \
  --dry-run \
  --json

apple notes links add \
  --id NOTE_ID \
  --url https://example.com/brief \
  --json
```

The command adds one `http` or `https` link to one editable visible note.
To convert existing note text into the link display text, select a paragraph by
hash or ordinal plus a text occurrence:

```bash
apple notes links add \
  --id NOTE_ID \
  --url https://example.com/brief \
  --paragraph PARAGRAPH_ID_SHA256 \
  --text "Project brief" \
  --occurrence 1 \
  --json
```

Selected-text mode is also available on `links add-app` and `links add-file`.
Dry-run and execution output include selected-text byte count, SHA-256,
paragraph evidence, and occurrence only; command JSON redacts selected
display/alt text.

`links add-app` adds one non-web, non-file app URL link to one editable visible note
without printing the raw app URL:

```bash
apple notes links add-app \
  --id NOTE_ID \
  --url podcasts://episode/ID \
  --dry-run \
  --json

apple notes links add-app \
  --id NOTE_ID \
  --url podcasts://episode/ID \
  --json
```

The command records URL SHA-256, scheme, and host hash in dry-run output and
verifies app-link metadata readback, URL hash, raw app URL absence, and note
readback after execution. Web, file, Notes, mail, telephone, and SMS schemes
are rejected. Locked, password-protected, read-only, deleted, and trash notes
are refused.

`links add-file` adds one local file URL link for a regular file or directory
to one editable visible note without printing the local path or raw file URL:

```bash
apple notes links add-file \
  --id NOTE_ID \
  --file ./Brief.pdf \
  --dry-run \
  --json

apple notes links add-file \
  --id NOTE_ID \
  --file ./Brief.pdf \
  --json
```

The command records file URL SHA-256, path SHA-256, source kind, and scheme in
dry-run output. Execution verifies file-link metadata readback, URL hash, raw
local file URL absence, source kind, and note readback. Missing, unreadable,
and non-file/non-directory paths are rejected.

`links add-note` adds one internal Notes link from one editable visible source
note to one visible non-password-protected target note:

```bash
apple notes links add-note \
  --id SOURCE_NOTE_ID \
  --target TARGET_NOTE_ID \
  --dry-run \
  --json

apple notes links add-note \
  --id SOURCE_NOTE_ID \
  --target TARGET_NOTE_ID \
  --json

apple notes links add-note \
  --id SOURCE_NOTE_ID \
  --target TARGET_NOTE_ID \
  --text "Display text" \
  --json

apple notes links add-note \
  --id SOURCE_NOTE_ID \
  --target TARGET_NOTE_ID \
  --use-note-title \
  --json
```

Execution verifies link metadata readback, note-link kind, source note
readback, target note readback, target identity, and optional display-text
hash/source-kind evidence. `--text` stores custom link display text;
`--use-note-title` asks Notes to derive display text from the target note title.
Those options are mutually exclusive. The result includes source and target note
IDs plus target hashes, but does not print the target title/body, custom display
text, or raw internal link token.

`links add-paragraph` adds one internal Notes paragraph link from one editable
visible source note to one paragraph anchor in a visible non-password-protected
target note. First read the target note structure and use
`paragraphAnchors[].idSHA256` as the paragraph selector:

```bash
apple notes body structure \
  --id TARGET_NOTE_ID \
  --json

apple notes links add-paragraph \
  --id SOURCE_NOTE_ID \
  --target TARGET_NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json

apple notes links add-paragraph \
  --id SOURCE_NOTE_ID \
  --target TARGET_NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --json
```

Execution verifies paragraph-link metadata readback, source note readback,
target note readback, and target paragraph identity by hash. The result does
not print the target paragraph UUID, target paragraph title, target note body,
or raw internal link token.

`links update-note` retargets one selected ordinary note-to-note link on one
editable visible source note to the requested visible non-password-protected
target note. Use an identifier or hash from `links list`:

```bash
apple notes links update-note \
  --id SOURCE_NOTE_ID \
  --link LINK_ID \
  --target TARGET_NOTE_ID \
  --dry-run \
  --json

apple notes links update-note \
  --id SOURCE_NOTE_ID \
  --link LINK_ID \
  --target TARGET_NOTE_ID \
  --json

apple notes links update-note \
  --id SOURCE_NOTE_ID \
  --link LINK_ID \
  --target TARGET_NOTE_ID \
  --text "Display text" \
  --json

apple notes links update-note \
  --id SOURCE_NOTE_ID \
  --link LINK_ID \
  --target TARGET_NOTE_ID \
  --use-note-title \
  --json
```

Execution verifies selected note-link metadata readback, selected-link identity
preservation, note-link kind, source note readback, target note readback,
target identity, target-or-display-text change, target backlink readback,
old-target backlink absence when retargeted, and optional display-text
hash/source-kind evidence. `--text` changes custom display text even when the
target note stays the same; `--use-note-title` clears custom text so Notes uses
the target note title. The result includes source and target note IDs plus target
hashes, but does not print target note title/body, custom display text, or raw
internal link token. Paragraph-link update uses `links update-paragraph`.

`links update-paragraph` retargets one selected paragraph/internal paragraph
link on one editable visible source note to the requested visible target
paragraph. First read the target note structure and use
`paragraphAnchors[].idSHA256` as the paragraph selector:

```bash
apple notes body structure \
  --id TARGET_NOTE_ID \
  --json

apple notes links update-paragraph \
  --id SOURCE_NOTE_ID \
  --link LINK_ID \
  --target TARGET_NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json

apple notes links update-paragraph \
  --id SOURCE_NOTE_ID \
  --link LINK_ID \
  --target TARGET_NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --json
```

Execution verifies selected paragraph-link metadata readback, selected-link
identity preservation, paragraph-link kind, source note readback, old target
note readback, target note readback, target paragraph identity, target token
hash replacement, target backlink readback, and old-target backlink absence
when the target note changes. Ordinary note-to-note links, web links, app
links, file links, unchanged target paragraphs, ambiguous selectors, raw
paragraph UUIDs, paragraph titles, and raw internal link tokens are refused or
hidden.

`links update` changes one selected web URL link on one editable visible note
to a different web URL. Use an identifier or public URL from `links list`:

```bash
apple notes links update \
  --id NOTE_ID \
  --link LINK_ID \
  --url https://example.com/revised \
  --dry-run \
  --json

apple notes links update \
  --id NOTE_ID \
  --link LINK_ID \
  --url https://example.com/revised \
  --json
```

Only `http` and `https` URL links can be updated by this command. Execution
verifies link metadata readback, selected-link identity, URL hash, old URL
replacement, and note readback. App links and file links use their dedicated
update commands; note-to-note links use `links update-note`; paragraph links
use `links update-paragraph`; unchanged URLs are refused.

`links update-app` changes one selected app URL link on one editable visible
note to a different non-web, non-file app URL without printing the raw app URL.
Use an identifier or hash from `links list`:

```bash
apple notes links update-app \
  --id NOTE_ID \
  --link LINK_ID \
  --url podcasts://episode/NEW_ID \
  --dry-run \
  --json

apple notes links update-app \
  --id NOTE_ID \
  --link LINK_ID \
  --url podcasts://episode/NEW_ID \
  --json
```

The command records old/new URL hashes, scheme, and host hash only. Execution
verifies app-link metadata readback, selected-link identity, URL hash, raw app
URL absence, old URL replacement, and note readback. Web links and file links
use their dedicated update commands; note-to-note links use `links update-note`;
paragraph links use `links update-paragraph`; unsupported app schemes and
unchanged URLs are refused.

`links update-file` changes one selected file URL link on one editable visible
note to a different local regular-file or directory URL without printing the
local path or raw file URL. Use an identifier or hash from `links list`:

```bash
apple notes links update-file \
  --id NOTE_ID \
  --link LINK_ID \
  --file ./NewBrief.pdf \
  --dry-run \
  --json

apple notes links update-file \
  --id NOTE_ID \
  --link LINK_ID \
  --file ./NewBrief.pdf \
  --json
```

The command records old/new URL hashes, path hash, source kind, and scheme
only. Execution verifies file-link metadata readback, selected-link identity,
URL hash, raw local file URL absence, source kind, old URL replacement, and
note readback. Web links and app links use their dedicated update commands;
note-to-note links use `links update-note`; paragraph links use
`links update-paragraph`; missing/unreadable/non-file/non-directory paths
and unchanged URLs are refused.

`links remove-paragraph` removes one selected paragraph/internal paragraph note
link from one editable visible source note. Use an identifier or hash from
`links list`:

```bash
apple notes links remove-paragraph \
  --id NOTE_ID \
  --link LINK_ID \
  --dry-run \
  --json

apple notes links remove-paragraph \
  --id NOTE_ID \
  --link LINK_ID \
  --json
```

Execution verifies link metadata absence, paragraph-link kind, selected-link
identity, and note readback. Ordinary note-to-note links, web links, app links,
and file links use their dedicated remove commands; raw internal-token output
remains gated for this command.

`links remove-note` removes one selected ordinary note-to-note link from one
editable visible source note. Use an identifier or hash from `links list`:

```bash
apple notes links remove-note \
  --id NOTE_ID \
  --link LINK_ID \
  --dry-run \
  --json

apple notes links remove-note \
  --id NOTE_ID \
  --link LINK_ID \
  --json
```

Execution verifies link metadata absence, note-link kind, selected-link
identity, and note readback. Paragraph/internal links, app links, file links,
and web links use their dedicated remove commands; raw internal-token output
remains gated for this command.

`links remove` removes one selected web URL link from one editable visible
note. Use an identifier or public URL from `links list`:

```bash
apple notes links remove \
  --id NOTE_ID \
  --link LINK_ID \
  --dry-run \
  --json

apple notes links remove \
  --id NOTE_ID \
  --link LINK_ID \
  --json
```

Only `http` and `https` URL links are supported for web URL removal. File URL
link removal is supported separately by `links remove-file`; ordinary
note-to-note link removal is supported separately by `links remove-note`;
paragraph note-link removal is supported separately by `links remove-paragraph`;
app URL link removal is supported separately by `links remove-app`.
Execution verifies link metadata readback, URL kind/scheme, and note readback.
Locked, password-protected, read-only, deleted, and trash notes are refused.

`links remove-file` removes one selected file URL link from one editable
visible note. Use an identifier or hash from `links list`; raw local file URLs
are not printed:

```bash
apple notes links remove-file \
  --id NOTE_ID \
  --link LINK_ID \
  --dry-run \
  --json

apple notes links remove-file \
  --id NOTE_ID \
  --link LINK_ID \
  --json
```

Execution verifies link metadata absence, file URL scheme, selected-link
identity, and note readback. Regular-file and directory file URL links are both
handled by this command.

`links remove-app` removes one selected app URL link from one editable visible
note. Use an identifier or hash from `links list`; raw app URLs are not printed:

```bash
apple notes links remove-app \
  --id NOTE_ID \
  --link LINK_ID \
  --dry-run \
  --json

apple notes links remove-app \
  --id NOTE_ID \
  --link LINK_ID \
  --json
```

Execution verifies link metadata absence, app-link kind, selected-link
identity, and note readback. Web links, file links, ordinary note links, and
paragraph/internal links are rejected by this command.

`body structure` is available in default private-framework-backed builds. It returns a
privacy-safe structure summary for one note: body byte count/hash, paragraph
counts, paragraph-style runs, paragraph anchor hashes, inline format run
counts, bold/italic/underline/strikethrough/font run counts,
foreground/highlight run counts, privacy-safe color/font-hash counts, checklist
indentation levels, checklist/table/math/link/attachment counts, and rich-state flags. Use
`paragraphAnchors[].idSHA256` with `links add-paragraph`,
`body paragraph style`, `body paragraph align`, `body paragraph quote`, `body inline format`, `body inline color`, `body inline highlight`, `body inline font`, `body collapsible set`, `body checklist set`, `body checklist convert`, `body checklist reorder`,
`body checklist indent`, `body checklist delete`, `body list convert`,
`body list set-style`, `body list reorder`, `body list indent`, or
`body list delete`. Use `paragraphAnchors[].ordinal` with
`body checklist convert-range` and `body list convert-range`.

For inline format, color, highlight, font, and selected-text link insertion,
`--ordinal` selects the actual text paragraph, counting the title as paragraph
1. This includes ordinary body paragraphs without a persistent anchor.
`--paragraph` accepts a native anchor hash or the text snapshot hash returned
in an inline operation's paragraph evidence. Text snapshot hashes identify a
range in that note's current text and must be selected again after text edits.
Persistent native anchor hashes continue to select paragraph links and
structural paragraph operations.

Commands selecting an existing checklist or ordinary-list item use an ordinal
within that item family. Conversion commands use `paragraphAnchors[].ordinal`.
Inline font or color changes do not add items or change those ordinals.
Structural edits apply to the complete selected paragraph. Item edits and
reordering return `ambiguous_identity` when a paragraph hash matches multiple
paragraphs; select the intended item by ordinal.

It does not print note body text, note title, raw attributed content, raw
paragraph UUIDs, paragraph titles, raw paragraph style data, raw colors, raw
font objects, or private color/font objects.

Counts, collections, and rich-state flags are omitted when their readback is
unavailable. Zero counts and empty collections mean the data was read and found
empty. Available plain-text, link, attachment, and state metadata remains in
the summary. `body surfaces` marks missing counts as unavailable and does not
verify them; table/math/outline listing reports an error when its source cannot
be read. Smart Folder reasons retain unknown body evidence, including criteria
that exclude checklists or mentions. If required evidence is unavailable after
a mutation, the command reports verification failure; read the note before
retrying.

`body surfaces` is the higher-level special-surface accounting view:

```bash
apple notes body surfaces \
  --id NOTE_ID \
  --json
```

It returns table, math-result, collapsible-section, and collapsed-section
counts, inline attachment count, `isMathNote`, supported read families, gated
read families, supported mutation families, gated mutation families, and read
verification. Privacy-safe table selector listing is supported through
`body table list`. Collapsible-section state mutation is supported through
`body collapsible list` and `body collapsible set`, and collapsible-section
create/update is supported through `body paragraph style` by promoting a
paragraph to `heading` or `subheading` or demoting it to `body` or `title`.
Table update is supported for one selected cell by ordinal, row, and column;
table conversion to tab/newline plain text is supported for one selected table;
table row and column insertion/deletion/move/copy/content clearing are supported
by table ordinal, 1-based row/column index, destination index for move/copy,
and optional count where applicable.
Existing math-result selector listing and result update are supported by
ordinal, and new math-result insertion is supported by appending to the note or
inserting after a selected paragraph hash/ordinal. It does not print note body text,
body hashes, paragraph anchors, paragraph titles, raw attributed content, table
cell text, math expression text, raw outline state, raw outline UUIDs, or
private class names.

Use `body format audit` to account for the current Apple Format Notes,
Add Lists, and Add a Table workflow family without reading a note:

```bash
apple notes body format audit --json
```

The audit reports 36 formatting workflows as supported, delegated, gated, or
rejected with `backend_calls: none`. Supported workflows include inline
emphasis, text color, highlight color, font family/size, paragraph style
including monostyled, default new-note paragraph style, text alignment, collapsible sections,
ordinary list add/style/indent/reorder, checklist add/convert/state/set-all/
auto-sort/reorder, list/checklist end and soft returns, ordinary-list literal tabs,
table create, external table import, single-cell update, table-to-text conversion,
text-to-table conversion, external table import conversion, table move by ordinal, table row/column insert/delete/move/copy/clear, and table row/column formatting. Delegated workflows include
Touch Bar controls, Format/Edit menu and keyboard shortcut interaction, table
navigation/selection UI, and typing suggestions. No formatting workflow remains
gated in this target audit. The audit
accepts no note, text, paragraph, table, account, or query selectors.

Use `body math audit` to account for the current Apple Solve Math and Open Math
Notes from Calculator workflow family without reading a note:

```bash
apple notes body math audit --json
```

The audit reports 14 Math Notes workflows as supported, delegated, gated, or
rejected with `backend_calls: none`. Supported workflows include privacy-safe
math surface accounting, existing math-result selector listing, expression
result insertion, existing result update, Math Results display preference,
variable definition and dependent-result update commands, ordinary note
operations in a Math Notes folder, and Smart Folder math criteria. They also
include expression verification through the private calculate scanner for
numeric script/operator coverage proof.
Delegated workflows include
Notes.app suggestion acceptance, live variable color rendering, variable value
stepper UI, and Calculator app handoff/folder creation/sync. No Math Notes
workflow remains gated in this audit. The audit accepts no note, text,
paragraph, ordinal, account, folder, or query selectors.

Table listing, table create, external table import, table update, table convert-to-text, table
convert-from-text, table copy, row/column structure editing, and table delete
are supported, and math results can be listed, inserted, updated, have their
display mode set, or have a standalone expression verified
by privacy-safe selectors:

```bash
apple notes body table list --id NOTE_ID --json
apple notes body table create --id NOTE_ID --text $'A\tB\n1\t2' --json
apple notes body table import --id NOTE_ID --file Imported.csv --format csv --json
apple notes body table update --id NOTE_ID --ordinal 1 --row 2 --column 1 --text "Updated" --json
apple notes body table convert-to-text --id NOTE_ID --ordinal 1 --json
apple notes body table convert-from-text --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json
apple notes body table copy --id SOURCE_NOTE_ID --ordinal 1 --target TARGET_NOTE_ID --json
apple notes body table rows insert --id NOTE_ID --ordinal 1 --index 2 --count 1 --json
apple notes body table rows delete --id NOTE_ID --ordinal 1 --index 2 --json
apple notes body table rows move --id NOTE_ID --ordinal 1 --index 1 --to 2 --json
apple notes body table rows copy --id NOTE_ID --ordinal 1 --index 1 --to 2 --json
apple notes body table rows clear --id NOTE_ID --ordinal 1 --index 1 --json
apple notes body table columns insert --id NOTE_ID --ordinal 1 --index 2 --count 1 --json
apple notes body table columns delete --id NOTE_ID --ordinal 1 --index 2 --json
apple notes body table columns move --id NOTE_ID --ordinal 1 --index 1 --to 2 --json
apple notes body table columns copy --id NOTE_ID --ordinal 1 --index 1 --to 2 --json
apple notes body table columns clear --id NOTE_ID --ordinal 1 --index 1 --json
apple notes body table delete --id NOTE_ID --ordinal 1 --json
apple notes body math audit --json
apple notes body math list --id NOTE_ID --json
apple notes body math update --id NOTE_ID --ordinal 1 --text "4" --json
apple notes body math insert --id NOTE_ID --text "2+2=" --json
apple notes body math results --id NOTE_ID --mode insert --json
apple notes body math variable set --id NOTE_ID --name x --value 2 --expression "x + 2" --json
apple notes body math variable update --id NOTE_ID --definition-ordinal 2 --dependent-ordinal 3 --value 5 --json
apple notes body math verify-expression --text "2+2=" --json
```

`body table list` returns one privacy-safe selector record per table using the
table ordinal, hashed table/attachment identifiers, optional row and column
counts, and deletion capability evidence. It is the selector source for table
update/delete work and does not print table cell text, raw attachment
identifiers, raw content identifiers, or private class names.

`body table create` appends one Notes table attachment from
tab/newline-delimited text on one editable visible non-password-protected note.
Dry-run and result payloads hash table text and report byte, row, and max-column
counts without printing table cell text. `body table import --id NOTE_ID
(--text TSV|--file PATH) [--format tsv|csv]` appends one Notes table from
explicit inline or file input. CSV input is normalized to the same tab/newline
table text used by the private Notes table writer. Dry-run and result payloads
report source kind, format, byte counts, SHA-256 hashes, row/column/cell counts,
and verifier state without printing local paths, source text, or table cell
text. `body table delete` removes one table
selected by ordinal, verifies that the selected table hash disappears from the
post-write table list, and checks table, table-attachment-kind, and inline
attachment-count deltas without printing table cell text. `body table convert-to-text`
replaces one selected table with tab/newline-delimited plain text in the note
body. Result payloads report converted-text byte count/SHA-256 plus row,
column, and cell counts, and verification checks selected-table disappearance,
table/inline attachment-count deltas, converted-text readback, and privacy
redaction without printing table cell text. `body table convert-from-text`
replaces one selected ordinary body paragraph, chosen by paragraph hash or
ordinal, with a Notes table attachment. Result payloads report source-text byte
count/SHA-256 plus row, column, and cell counts; verification checks source
paragraph removal, table/inline attachment-count deltas, per-cell hash readback,
and privacy redaction without printing source text or table cell text. `body table update`
replaces one selected cell by table ordinal, row, and column through the private
table writer. Dry-run and result payloads hash the replacement text, report the
cell selector and byte count/SHA-256, and verify selected table preservation,
target cell hash readback, table-count preservation, and inline
attachment-count preservation without printing old or new cell text.
`body table copy --id SOURCE_NOTE_ID --ordinal N [--target TARGET_NOTE_ID]`
copies one selected source table to the same note by default, or appends it to
the explicit target note when `--target` is supplied. Dry-run and result
payloads report source/target selectors, copied-text byte count/SHA-256, row,
column, and cell counts, and verification checks source-table preservation,
target table and inline-attachment deltas, copied-text hash evidence, and
per-cell hash readback without printing table cell text.
`body table rows insert`, `body table rows delete`,
`body table rows move`, `body table rows copy`, `body table rows clear`,
`body table columns insert`, `body table columns delete`,
`body table columns move`, `body table columns copy`, and
`body table columns clear` change one selected table's row or column structure
or clear selected row/column contents. Insert commands accept an index from 1
through the current row/column count plus one; delete and clear commands must
stay inside the current row/column count, and delete commands must leave at
least one row or column. Move commands move one row or column from `--index` to
`--to` inside the selected table. Copy commands duplicate one row or column
from `--index` into a newly inserted row or column at `--to`.
Dry-run and result payloads report only table ordinal, axis, action, index,
destination index where applicable, count, privacy-safe moved-slice
count/SHA-256 evidence for moves, copied-slice count/SHA-256 evidence for
copies, and cleared-slice count/SHA-256 evidence for clears. Verification
checks selected-table preservation, row/column count readback or dimension
preservation, moved-slice destination readback for moves, copied-slice
destination readback for copies, cleared-slice empty readback for clears,
table-count preservation, and inline attachment-count preservation without
printing table cell text.
`body math list` returns one privacy-safe selector record per existing math
result using the result ordinal, hashed identities, expression/result byte
counts and SHA-256 hashes, validity, and direction metadata. It does not print
expression or result text, raw attachment identifiers, raw content identifiers,
or private class names. `body math insert --id NOTE_ID [--paragraph HASH|--ordinal N]
--text EXPRESSION` inserts one recognized calculation expression/result. Without
a paragraph selector it appends to the note; with `--paragraph` or `--ordinal`
it inserts after the selected paragraph from `body structure`. Dry-run and
result payloads hash the expression, report placement, and verify a new
math-result identity, expression hash readback, math-result count delta, and
inline attachment-count delta without printing expression or result text.
`body math update` updates one existing math-result
attachment selected by ordinal. Dry-run and result payloads hash the new result
text, report the selector and byte count/SHA-256, and verify selected-result
preservation, result hash readback, math-result count preservation, inline
attachment-count preservation, and privacy redaction without printing old or
new result text. `body math results --id NOTE_ID --mode insert|suggest|off`
changes how Notes displays Math Results for the selected note through the
private Notes preview behavior. Dry-run and result payloads report the requested
mode, private raw value, and preference hashes; verification checks independent
preference readback and body preservation without printing note content.
`body math variable set --id NOTE_ID --name NAME --value VALUE --expression
EXPRESSION` inserts one variable-definition expression and one dependent
expression through the private Notes calculate path. `--name` accepts a
Latin-alphabet letter or word, matching Notes' variable-recognition rule.
Dry-run and result payloads hash the variable name, value, definition
expression, and dependent expression;
verification checks distinct private readback for both expression hashes and
math-result deltas without printing variable names, values, expressions,
results, or note text. `body math variable update --id NOTE_ID
--definition-ordinal N --dependent-ordinal N --value VALUE` updates one selected
variable-definition expression and requires private dependent-result delta
readback. Verification checks that the dependent result changed while the
dependent expression hash stayed stable, without printing variable values,
expressions, results, or note text.
`body math verify-expression --text EXPRESSION` verifies one caller-provided
expression through the private calculate scanner. It returns only expression
hashes, byte and UTF-16 range accounting, scanner object count/type hash, and
implementation-call evidence, and does not mutate a note or print raw expression/result
text.

`body collapsible list` lists existing collapsible sections for one note:

```bash
apple notes body collapsible list \
  --id NOTE_ID \
  --json
```

It returns one privacy-safe record per existing collapsible section: section
ordinal, paragraph hash, title byte count/hash, and collapsed state. The ordinal
is a collapsible-section ordinal, not the full `body structure` paragraph
ordinal.

`body collapsible set` changes the collapsed state of one existing collapsible
section:

```bash
apple notes body collapsible set \
  --id NOTE_ID \
  --ordinal 2 \
  --state collapsed \
  --dry-run \
  --json

apple notes body collapsible set \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --state expanded \
  --json
```

`--state` accepts `collapsed`, `expanded`, or `toggle`. Execution verifies note
identity, target paragraph hash preservation, section-count preservation,
collapsed-count delta, target state readback, and privacy redaction. To create
or remove a collapsible section, use `body paragraph style` with `heading` or
`subheading` to promote the paragraph, or `body` or `title` to demote it.

`body inline format`, `body inline color`, `body inline highlight`, and
`body inline font` change
one text selection inside one paragraph from `body structure`:

```bash
apple notes body inline format \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --text "Important" \
  --format bold \
  --state on \
  --dry-run \
  --json

apple notes body inline color \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --text "Important" \
  --color "#336699" \
  --json

apple notes body inline highlight \
  --id NOTE_ID \
  --ordinal 1 \
  --text "Important" \
  --color yellow \
  --json

apple notes body inline font \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --text "Important" \
  --family FONT_FAMILY \
  --size 18 \
  --json
```

Supported inline formats are `bold`, `italic`, `underline`, and
`strikethrough`. Use `--state off` to remove a format. Color and highlight
accept named colors, `#RRGGBB`, `#RRGGBBAA`, or `none`/`clear`/`remove`/`off`
to clear that color role. `body inline font` accepts an installed font family
and a point size from 1 through 288. If the selected text appears more than once
in the selected paragraph, add `--occurrence N`. Dry-run and result output hash
the selected text, colors, and font-family evidence; they do not print selected
text, raw attributed content, raw colors, raw font objects, or private color/font
objects. Text selection is literal. Execution independently locates the requested
occurrence and verifies that the whole selected range has the requested format,
font, or color, even when other attributes split it into several runs. It also
checks paragraph-anchor order, body byte-count/hash preservation, and note
identity/title/folder/account. Missing selection or formatting readback prevents
verified success. Structure run/paragraph positions use UTF-16 offsets in the
whole attributed body; `richTextSHA256` hashes that body's text.

`body paragraph style` changes one non-list, non-checklist, non-block-quote
paragraph to an Apple Notes paragraph style. Prefer the paragraph hash from
`body structure`; `--ordinal` is available as a fallback selector:

```bash
apple notes body paragraph style \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --style heading \
  --dry-run \
  --json

apple notes body paragraph style \
  --id NOTE_ID \
  --ordinal 1 \
  --style body \
  --json

apple notes body paragraph style \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --style monostyled \
  --json
```

Supported styles are `title`, `heading`, `subheading`, `body`, and
`monostyled`.
`heading` and `subheading` create or keep a collapsible section for that
paragraph. `body` and `title` remove collapsibility for that paragraph when it
was previously a collapsible section. `monostyled` applies Apple's fixed-width
paragraph style without creating a collapsible section. Execution verifies target style readback,
collapsible-section promotion or demotion, paragraph title-hash preservation,
paragraph-anchor order preservation, list/checklist count preservation, body
hash preservation, and note identity/title/folder/account preservation. The
command refuses list, checklist, and block-quote paragraphs; use
`body paragraph quote` for block quote state and the dedicated list/checklist
commands for list items.

`body paragraph align` changes one non-list, non-checklist, non-block-quote
paragraph alignment:

```bash
apple notes body paragraph align \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --alignment center \
  --dry-run \
  --json
```

Supported alignments are `left`, `center`, `right`, `justified`, and
`natural`. Dry-run records only the target note ID, selector, and requested
style or alignment. Results return note summary, structure, and verifier
evidence; they do not print note body text, paragraph text, raw paragraph
UUIDs, paragraph titles, or raw attributed content.

`body paragraph quote` toggles block quote formatting for one non-list,
non-checklist paragraph:

```bash
apple notes body paragraph quote \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --state on \
  --dry-run \
  --json
```

Use `--state off` to remove block quote formatting. Execution verifies target
block-quote readback, block-quote count, paragraph-anchor order preservation,
list/checklist count preservation, body byte-count/hash preservation, and note
identity/title/folder/account preservation. The command refuses list and
checklist paragraphs; use the dedicated list/checklist commands for list items.

`body checklist add` is available in default private-framework-backed builds for one
editable visible non-password-protected note at a time:

```bash
apple notes body checklist add \
  --id NOTE_ID \
  --text "Review contract" \
  --dry-run \
  --json

apple notes body checklist add \
  --id NOTE_ID \
  --text "Review contract" \
  --checked \
  --json
```

Execution appends one checklist item and verifies note identity/title/folder/
account preservation plus checklist item, checked, and open counts through body
structure readback. The result returns note summary and structure evidence, not
raw attributed content. Dry-run records text hash/count and checked state.

`body checklist set` changes one existing checklist item state. Prefer the
paragraph hash from `body structure`; `--ordinal` is available as a fallback
selector:

```bash
apple notes body checklist set \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --state checked \
  --dry-run \
  --json

apple notes body checklist set \
  --id NOTE_ID \
  --ordinal 2 \
  --state open \
  --json
```

Execution verifies item-count preservation, checked/open count deltas, body hash
preservation, and paragraph-anchor preservation when selected by hash. It does
not print checklist item text, raw attributed content, raw paragraph UUIDs, or
paragraph titles.

`body checklist set-all` changes every checklist item state on one note:

```bash
apple notes body checklist set-all \
  --id NOTE_ID \
  --state checked \
  --dry-run \
  --json

apple notes body checklist set-all \
  --id NOTE_ID \
  --state open \
  --json
```

Execution verifies item-count preservation, all checked/open target counts, body
hash preservation, and checklist paragraph-anchor preservation. It does not
print checklist item text, raw attributed content, raw paragraph UUIDs, or
paragraph titles.

`body checklist sort` moves checked checklist items after open items on one
note while preserving the relative order within each group:

```bash
apple notes body checklist sort \
  --id NOTE_ID \
  --dry-run \
  --json

apple notes body checklist sort \
  --id NOTE_ID \
  --json
```

Execution verifies checked items read back after open items, open-item and
checked-item relative order, checklist item/checked/open counts, and body byte
count. It does not print checklist item text, raw attributed content, raw
paragraph UUIDs, or paragraph titles.

`body checklist convert` changes one non-checklist paragraph anchor into a
checklist item. Select the paragraph hash from `body structure`; `--ordinal`
uses the paragraph-anchor ordinal from that same output:

```bash
apple notes body checklist convert \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --state open \
  --dry-run \
  --json

apple notes body checklist convert \
  --id NOTE_ID \
  --ordinal 3 \
  --state checked \
  --json
```

Execution verifies the selected paragraph anchor existed before the write,
was not already a checklist item, and is a checklist item after readback. It
also verifies checked/open count deltas, body hash preservation, and paragraph
title-hash preservation without printing paragraph text, raw paragraph UUIDs,
or raw attributed content. Use `body checklist set` for paragraphs that are
already checklist items.

`body checklist convert-range` changes a contiguous `body structure` paragraph
ordinal range into checklist items. The range uses body paragraph ordinals, not
checklist-item ordinals, and every selected paragraph must be non-checklist:

```bash
apple notes body checklist convert-range \
  --id NOTE_ID \
  --from-ordinal 3 \
  --to-ordinal 5 \
  --state open \
  --dry-run \
  --json

apple notes body checklist convert-range \
  --id NOTE_ID \
  --from-ordinal 3 \
  --to-ordinal 5 \
  --state checked \
  --json
```

Execution verifies selected paragraph count, non-checklist-before/
checklist-after state, checked/open count deltas, paragraph-anchor order, body
hash preservation, and paragraph title-hash preservation. It does not print
paragraph text, raw paragraph UUIDs, paragraph titles, or raw attributed
content. Mixed ranges that already contain checklist paragraphs are rejected;
use `body checklist set` or `body checklist set-all` for existing checklist
items.

`body checklist reorder` moves one existing checklist item to another checklist
ordinal on the same note. Prefer the paragraph hash from `body structure`;
`--ordinal` is available as a fallback checklist-item selector:

```bash
apple notes body checklist reorder \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --to-ordinal 1 \
  --dry-run \
  --json

apple notes body checklist reorder \
  --id NOTE_ID \
  --ordinal 2 \
  --to-ordinal 1 \
  --json
```

Execution verifies note identity/title/folder/account preservation, checklist
item/done/open count preservation, source paragraph title-hash preservation,
body byte-count preservation, and the resulting checklist anchor order. It
does not print checklist item text, raw attributed content, raw paragraph UUIDs,
or paragraph titles. Automatic checked-item sorting preferences and multi-item
drag semantics remain gated.

`body checklist indent` increases or decreases one existing checklist item's
list level by one. Prefer the paragraph hash from `body structure`; `--ordinal`
is available as a fallback checklist-item selector. Use `--by 1` to increase
the level and `--by -1` to decrease it:

```bash
apple notes body checklist indent \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --by 1 \
  --dry-run \
  --json

apple notes body checklist indent \
  --id NOTE_ID \
  --ordinal 2 \
  --by -1 \
  --json
```

Execution verifies note identity/title/folder/account preservation, checklist
item/done/open count preservation, body hash preservation, target paragraph
title-hash preservation, target indentation level/delta, and checklist anchor
order preservation. It does not print checklist item text, raw attributed
content, raw paragraph UUIDs, or paragraph titles.

`body list add` appends one ordinary list item to one editable visible
non-password-protected note. Supported styles are `bulleted`, `dashed`, and
`numbered`:

```bash
apple notes body list add \
  --id NOTE_ID \
  --text "Discuss launch" \
  --style bulleted \
  --dry-run \
  --json
```

Execution verifies note identity/title/folder/account preservation, list item
count increment, requested list style readback, and privacy-safe item text
hash/count evidence. It does not print list item text, raw attributed content,
raw paragraph UUIDs, or paragraph titles.

`body list convert` changes one non-list paragraph anchor into an ordinary list
item. Prefer the paragraph hash from `body structure`; `--ordinal` is available
as a fallback body-paragraph selector:

```bash
apple notes body list convert \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --style numbered \
  --dry-run \
  --json

apple notes body list convert \
  --id NOTE_ID \
  --ordinal 3 \
  --style dashed \
  --json
```

Execution rejects existing checklist and ordinary list paragraphs, verifies the
same paragraph anchor becomes the requested ordinary list style, and preserves
body hash, paragraph title hash, and paragraph anchor order.

`body list convert-range` changes a contiguous range of non-list body paragraph
ordinals into ordinary list items:

```bash
apple notes body list convert-range \
  --id NOTE_ID \
  --from-ordinal 3 \
  --to-ordinal 5 \
  --style bulleted \
  --dry-run \
  --json
```

Execution rejects ranges containing existing checklist or ordinary list
paragraphs, verifies every selected anchor becomes the requested style, and
preserves body hash, paragraph title hashes, and paragraph anchor order.

`body list set-style` changes one existing ordinary list item between
bulleted, dashed, and numbered styles. Prefer the paragraph hash from
`body structure`; `--ordinal` is available as a fallback ordinary-list-item
selector:

```bash
apple notes body list set-style \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --style dashed \
  --dry-run \
  --json

apple notes body list set-style \
  --id NOTE_ID \
  --ordinal 2 \
  --style numbered \
  --json
```

Execution verifies ordinary-list selection, requested style readback, list
item count preservation, ordinary list anchor order preservation, body hash
preservation, and target title-hash preservation. It reports no-op when the
item already has the requested style.

`body list reorder` moves one existing ordinary list item to another ordinary
list ordinal on the same note while excluding checklist items. Prefer the
paragraph hash from `body structure`; `--ordinal` is available as a fallback
ordinary-list-item selector:

```bash
apple notes body list reorder \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --to-ordinal 1 \
  --dry-run \
  --json

apple notes body list reorder \
  --id NOTE_ID \
  --ordinal 2 \
  --to-ordinal 1 \
  --json
```

Execution verifies note identity/title/folder/account preservation, that the
target is an ordinary list item rather than a checklist item, ordinary list
anchor order, ordinary/list item count preservation, checklist item/done/open
count preservation, body byte-count/hash preservation, and source paragraph
title-hash preservation. It does not print list item text, raw attributed
content, raw paragraph UUIDs, or paragraph titles.

`body list indent` increases or decreases one existing ordinary list item's
level by one. Prefer the paragraph hash from `body structure`; `--ordinal` is
available as a fallback ordinary-list-item selector. Use `--by 1` to increase
the level and `--by -1` to decrease it:

```bash
apple notes body list indent \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --by 1 \
  --dry-run \
  --json

apple notes body list indent \
  --id NOTE_ID \
  --ordinal 2 \
  --by -1 \
  --json
```

Execution verifies note identity/title/folder/account preservation, that the
target is an ordinary list item rather than a checklist item, target indentation
level/delta, ordinary list anchor order preservation, checklist item/done/open
count preservation, body byte-count/hash preservation, and target paragraph
title-hash preservation. It does not print list item text, raw attributed
content, raw paragraph UUIDs, or paragraph titles.

`body list delete` removes one existing ordinary list item. Prefer the
paragraph hash from `body structure`; `--ordinal` is available as a fallback
ordinary-list-item selector:

```bash
apple notes body list delete \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json

apple notes body list delete \
  --id NOTE_ID \
  --ordinal 2 \
  --json
```

Execution verifies note identity/title/folder/account preservation, that the
target is an ordinary list item rather than a checklist item, target ordinary
list anchor absence, list item count decrement, ordinary list anchor order
preservation, checklist item/done/open count preservation, and body
byte-count/hash change. It does not print list item text, raw attributed
content, raw paragraph UUIDs, or paragraph titles.

`body list line-break` inserts one soft line break inside an existing ordinary
list item. `body checklist line-break` does the same for one checklist item.
Prefer the paragraph hash from `body structure`; `--ordinal` is available as a
fallback item selector for the selected target family:

```bash
apple notes body list line-break \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json

apple notes body checklist line-break \
  --id NOTE_ID \
  --ordinal 1 \
  --json
```

Execution inserts a single soft-return character through the private text
storage writer and verifies target anchor preservation, target type/style
preservation, list/checklist count preservation, paragraph count preservation,
body byte-count delta, and body hash change. The JSON reports only the inserted
kind, byte count, and SHA-256, not the inserted character or item text.

`body list tab` inserts one literal tab character inside an existing ordinary
list item:

```bash
apple notes body list tab \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json
```

Literal tab insertion is scoped to ordinary list items, matching the Apple
shortcut wording. Checklist tab insertion is not accepted. Execution verifies
the same target preservation and body delta checks as `body list line-break`
without printing list item text.

`body list end` creates one ordinary body paragraph after an existing ordinary
list item. `body checklist end` does the same after one checklist item:

```bash
apple notes body list end \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json

apple notes body checklist end \
  --id NOTE_ID \
  --ordinal 1 \
  --json
```

Execution verifies target item preservation, created body paragraph readback,
list/checklist count preservation, paragraph-count delta, and body hash change.
The JSON does not print list item text, paragraph text, raw paragraph UUIDs, or
paragraph titles.

`body checklist delete` removes one existing checklist item. Prefer the
paragraph hash from `body structure`; `--ordinal` is available as a fallback
checklist-item selector:

```bash
apple notes body checklist delete \
  --id NOTE_ID \
  --paragraph PARAGRAPH_ID_SHA256 \
  --dry-run \
  --json

apple notes body checklist delete \
  --id NOTE_ID \
  --ordinal 2 \
  --json
```

Execution verifies note identity/title/folder/account preservation, target
checklist anchor absence, checklist/list item count decrement, checked/open
count decrement for the removed item, remaining checklist anchor order
preservation, and body byte-count/hash change. It does not print checklist item
text, raw attributed content, raw paragraph UUIDs, or paragraph titles.
Automatic checked-item sorting preferences, multi-item deletion, and drag/range
semantics remain gated.

`state read`, `state audit`, `state lockability`, `state participants`, and `state activity` are available in
default private-framework-backed builds. `state read --id NOTE_ID` returns privacy-safe
state flags for one note: deleted/trash, pinned, password protection,
editable/lockable, shared/read-only, system-paper, math/call-note, cloud-fetch,
participant count, and folder state flags. `state audit [--account ACCOUNT]
[--folder FOLDER]` returns bounded state records and aggregate
lock/share/collaboration accounting for visible notes. `state lockability --id
NOTE_ID` reads one selected note's private state, account/provider lockability
evidence, tag membership, and attachment metadata to return lockability flags
plus reason IDs, booleans, counts, and hashes for provable blockers such as
Quick Note status, shared state, unsupported provider/account crypto state,
tags, unsupported attachment families, unknown attachment families, and
cloud-fetch requirements. It does not print account names, account identifiers,
provider values, note bodies, note titles, tag text, attachment titles, or
attachment filenames. `state participants --id NOTE_ID|--folder FOLDER`
reads existing shared-object participant/access metadata and returns target,
share, owner, participant identity, and user-record hashes plus participant
counts and permission/role/acceptance/public-permission enum values. It does
not print participant names, contact values, raw participant identifiers, share
links, note titles, note bodies, or folder names. With `--output FILE.json`, it
exports the same hash-only metadata artifact after `--allow-artifact-action` and
verifies artifact hash plus private participant readback. `state activity --id
NOTE_ID` returns collaboration activity metadata only: shared flags,
participant count, participant identifier hashes, activity-event byte
count/SHA-256, activity-document presence, and share timestamp hash. With
`--output FILE.json`, it exports the same privacy-safe JSON artifact only after
`--allow-artifact-action`, and verifies artifact hash plus private activity
readback. These commands do not print note body text, note title,
folder/account names, tag names, attachment titles or filenames, participant
names, shared owner names, activity text, or raw collaboration handles.

```bash
apple notes state lockability --id NOTE_ID --json
apple notes state participants --id NOTE_ID --json
apple notes state participants --folder FOLDER --json
apple notes state participants --id NOTE_ID --output ./participants.json --dry-run --json
apple notes state participants --id NOTE_ID --output ./participants.json --allow-artifact-action --json
apple notes state activity --id NOTE_ID --json
apple notes state activity --id NOTE_ID --output ./activity.json --dry-run --json
apple notes state activity --id NOTE_ID --output ./activity.json --allow-artifact-action --json
```

Audit the current Apple sharing and collaboration workflow surface without
reading a note or changing collaboration state:

```bash
apple notes state collaboration audit --json
```

The audit reports each official sharing/collaboration workflow as supported,
delegated, gated, or rejected. Supported workflows include private shared-state
reads, shared-folder state accounting, editable shared-note mutation through the
ordinary accepted note/body writers, privacy-safe activity metadata readback,
privacy-safe activity metadata artifact export, participant/access metadata
readback/artifact export, existing collaboration link clipboard/artifact output,
semantic participant mention insertion, existing participant permission changes,
existing participant removal, existing access-scope changes for already shared
notes or folders, shared note/folder stop-sharing, and per-shared-note Hide
Alerts.
It reports 26 workflow records: 15 supported, 6 delegated, 5 gated, and
0 rejected. Delegated workflows include
Send Copy and invitation delivery through the system share surface, opening
shared links through iCloud/Apple Account verification, realtime presence,
highlights, and activity highlight UI in Notes.app. Gated workflows include
starting note or folder collaboration, allowing others to
invite, inviting people, and removing yourself until private mutation/preference
proof and verifier readback are accepted. The audit accepts no note, folder, participant,
account, or query
selectors and reports `backend_calls: none`.

Audit the current Apple Lock Notes and locked-notes password workflow surface
without reading a note, accepting secrets, or changing lock state:

```bash
apple notes state security audit --json
```

The audit reports each official Lock Notes/password workflow as supported,
delegated, gated, or rejected. Supported workflows include privacy-safe lock
state readback, lockability status readback, provable lockability-reason
readback including account-upgrade/provider evidence, password-settings
family accounting, account-scoped Touch ID preference mutation, eligible
note unlock/lock/remove-lock mutation, custom locked-notes password setup,
custom locked-notes password change, custom locked-notes password reset, and
initial login-password method selection for accounts with no existing
password-protected notes, and locked-session close. It reports
19 workflow records: 15 supported, 3 delegated, 1 gated, and 0 rejected.
Delegated workflows include Touch ID authentication, Mac login password authentication, and
Notes.app locked-session timeout behavior because those are system or
user-facing app surfaces. Supported workflows also include eligible note
unlock through private `ICAuthenticationState` plus lock/remove-lock mutation
through private `ICNoteLockManager` with lock-state/session readback. Custom
password change/reset are supported through private account passphrase manager
selectors with hash-only secret-source, hint, and account accounting. Gated
workflows include password method changes for existing locked notes until
private migration/rekey proof and verifier readback are accepted. Still-locked content export without prior
unlock remains a separate export/security boundary.
The audit accepts no note, account,
folder, password, or query selectors and reports `backend_calls: none`.

Close the current private locked-note authentication session without reading or
printing locked content:

```bash
apple notes state close-locked --dry-run --json
apple notes state close-locked --allow-persistent-action --json
apple notes state close-locked --account ACCOUNT_ID --allow-persistent-action --json
```

`state close-locked` calls private
`ICAuthenticationState.deauthenticateAllObjects` and verifies
`isAuthenticated` and `hasAuthenticatedObject` readback. `--account` is a
selector preflight only; the private session close applies to all authenticated
locked-note objects. Output is limited to scope strings, account hashes,
before/after booleans, implementation-call metadata, and verifier checks.

Insert one semantic participant mention in an already shared editable note:

```bash
apple notes state mention --id NOTE_ID --target PARTICIPANT_ID --dry-run --json
apple notes state mention --id NOTE_ID --target PARTICIPANT_ID --text TEXT --allow-persistent-action --json
```

`state mention` resolves `--target` against existing private participant
metadata, creates an `ICInlineAttachment` mention, inserts it through
`ICNote.textStorage`, and verifies mention-count plus target-participant
readback. Output is limited to note, target, participant, mention-text,
attachment, count, and verifier hashes; it does not print participant names,
participant handles, or mention text.

Change one existing participant's permission on an already shared note or
folder:

```bash
apple notes state set-permission --id NOTE_ID --target PARTICIPANT_ID --scope read-only --dry-run --json
apple notes state set-permission --id NOTE_ID --target PARTICIPANT_ID --scope read-write --allow-persistent-action --json
apple notes state set-permission --folder FOLDER --target PARTICIPANT_ID --scope read-only --dry-run --json
apple notes state folder-permission --folder FOLDER --target PARTICIPANT_ID --scope read-write --allow-persistent-action --json
```

`state set-permission` resolves `--target` against existing private participant
metadata, mutates `CKShareParticipant.permission`, saves the private
collaboration share, and verifies before/after permission readback. Output is
limited to target, participant, share, permission, and verifier hashes or enum
labels; it does not print participant handles, contact values, share links,
note titles, folder names, or body text. `state folder-permission` is the
folder-specific entry point for the same private mutation.

Change who can access one already shared note or folder:

```bash
apple notes state share --id NOTE_ID --scope invited-only --dry-run --json
apple notes state share --id NOTE_ID --scope anyone-with-link --allow-persistent-action --json
apple notes state share --folder FOLDER --scope invited-only --dry-run --json
apple notes state share --folder FOLDER --scope anyone-with-link --allow-persistent-action --json
```

Without `--target`, `state share` changes only the existing share's access
scope. It mutates `CKShare.publicPermission`, saves the private collaboration
share, and verifies public-permission enum readback. If an invited-only share is
made link-accessible, the command uses read-only public permission unless the
share already has a broader public permission. Output is limited to target/share
hashes, public-permission enum labels, participant count, and verifier checks;
it does not print share links, participant handles, note titles, folder names,
or body text.

Change whether existing collaborators can add people to one already shared note
or folder:

```bash
apple notes state allow-invites --id NOTE_ID --enabled false --dry-run --json
apple notes state allow-invites --id NOTE_ID --enabled true --allow-persistent-action --json
apple notes state allow-invites --folder FOLDER --enabled false --dry-run --json
apple notes state allow-invites --folder FOLDER --enabled true --allow-persistent-action --json
```

`state allow-invites` mutates private `CKShareParticipant.role` values for the
existing share, saves the private collaboration share, and verifies
administrator-role count readback. Execution requires
`--allow-persistent-action`. Output is limited to target/share hashes,
requested/before/after booleans, participant/admin counts, implementation-call
metadata, and verifier checks; it does not print participant handles, contact
values, share links, note titles, folder names, or body text.

Remove one existing non-owner, non-current-user participant from an already
shared note:

```bash
apple notes state remove-participant --id NOTE_ID --target PARTICIPANT_ID --dry-run --json
apple notes state remove-participant --id NOTE_ID --target PARTICIPANT_ID --allow-persistent-action --json
```

`state remove-participant` resolves `--target` against existing private
participant metadata, calls `CKShare.removeParticipant`, saves the private
collaboration share, and verifies participant absence plus before/after
participant-count readback. Output is limited to note, target, participant,
share, count, and verifier hashes; it does not print participant handles,
contact values, share links, note titles, or body text.

Remove yourself from one already shared note or folder:

```bash
apple notes state remove-self --id NOTE_ID --dry-run --json
apple notes state remove-self --id NOTE_ID --allow-destructive-selection --allow-persistent-action --json
apple notes state remove-self --folder FOLDER --dry-run --json
apple notes state remove-self --folder FOLDER --allow-destructive-selection --allow-persistent-action --json
```

`state remove-self` resolves the current user participant through private share
metadata, calls `CKShare.removeParticipant`, saves the private collaboration
share, and verifies current-user absence plus before/after participant-count
readback. Because this removes your access to the shared item, execution
requires both `--allow-destructive-selection` and `--allow-persistent-action`.
Output is limited to target, current-user participant, share, count, and
verifier hashes; it does not print account values, participant handles, contact
values, share links, note titles, folder names, or body text.

Stop sharing one already shared note or folder:

```bash
apple notes state stop-sharing --id NOTE_ID --dry-run --json
apple notes state stop-sharing --id NOTE_ID --allow-destructive-selection --allow-persistent-action --json
apple notes state stop-sharing --folder FOLDER --dry-run --json
apple notes state stop-sharing --folder FOLDER --allow-destructive-selection --allow-persistent-action --json
```

`state stop-sharing` calls private
`ICCollaborationController.removeShareIfNeededWithOwnedObjectID` for one
already shared note or folder and verifies that the private share and
participant access are gone afterward. Because this removes collaboration access, execution
requires both `--allow-destructive-selection` and `--allow-persistent-action`.
Output is limited to target/share hashes, before/after shared booleans,
participant counts, implementation-call metadata, and verifier checks; it does not
print participant handles, share links, note titles, folder names, or body text.

Lock or remove locked-note protection for eligible notes:

```bash
apple notes state lock --id NOTE_ID --dry-run --json
apple notes state lock --id NOTE_ID --allow-persistent-action --json
apple notes state remove-lock --id NOTE_ID --dry-run --json
apple notes state remove-lock --id NOTE_ID --allow-persistent-action --json
```

`state lock` adds locked-note protection to one eligible
non-password-protected note through private `ICNoteLockManager` and verifies
password-protected state readback. `state remove-lock` removes locked-note
protection from one already unlocked protected note and verifies lock absence.
Both execution paths require `--allow-persistent-action`; neither accepts or
prints passwords, password hints, locked content, note bodies, note titles, or
keychain material.

Unlock one password-protected note for the current Notes session:

```bash
apple notes state unlock --id NOTE_ID --passphrase-stdin --dry-run --json
apple notes state unlock --id NOTE_ID --passphrase-stdin --allow-persistent-action --json
apple notes state unlock --id NOTE_ID --passphrase-env NOTES_PASSPHRASE --allow-persistent-action --json
apple notes state unlock --id NOTE_ID --passphrase-file ./passphrase.txt --allow-persistent-action --json
```

`state unlock` calls private
`ICAuthenticationState.authenticateObject:withPassphrase:` and verifies
password-protected/locked state plus authentication-session readback. It accepts
exactly one passphrase source: stdin, an environment variable name, or a file.
Command output reports source kind, source hash when applicable, lock-state
booleans, authentication booleans, implementation-call metadata, and verifier checks;
it never prints the passphrase, environment variable name, passphrase file path,
password hint, locked content, note title, or note body. Execution requires
`--allow-persistent-action`.

Export the text content of a password-protected note that is already unlocked
in the current Notes session:

```bash
apple notes state export-locked-content --id NOTE_ID --output ./locked.txt --dry-run --json
apple notes state export-locked-content --id NOTE_ID --output ./locked.txt --allow-artifact-action --json
```

Export the text content of a password-protected note by authenticating in the
same command:

```bash
apple notes state export-locked-content --id NOTE_ID --output ./locked.txt --passphrase-stdin --dry-run --json
apple notes state export-locked-content --id NOTE_ID --output ./locked.txt --passphrase-stdin --allow-artifact-action --allow-persistent-action --json
apple notes state export-locked-content --id NOTE_ID --output ./locked.txt --passphrase-env NOTES_PASSPHRASE --allow-artifact-action --allow-persistent-action --json
apple notes state export-locked-content --id NOTE_ID --output ./locked.txt --passphrase-file ./passphrase.txt --allow-artifact-action --allow-persistent-action --json
```

`state export-locked-content` accepts at most one passphrase source. With no
passphrase source, the selected note must already be unlocked in the current
Notes session. With a passphrase source, the command authenticates through the
private Notes framework, reads private plaintext through the Notes framework,
writes the content only to the requested `.txt` artifact, and verifies the
artifact hash/readback. Passphrase export requires both
`--allow-artifact-action` and `--allow-persistent-action`; session-unlocked
export requires `--allow-artifact-action`. Command JSON reports hashes, byte
counts, lock-state booleans, implementation-call metadata, artifact metadata, and
verifier checks; it does not print the locked content, passphrase, env names, or
local secret paths to stdout. Currently locked notes without a passphrase source
still return `unsupported_operation` until they are unlocked in the current
Notes session.

The locked-password mutation command that still needs private mutation proof is
present as an explicit gated refusal surface:

```bash
apple notes state change-password --account ACCOUNT_ID --json
```

This command currently returns `unsupported_operation` with future gated
password/security backlog metadata and makes no implementation calls. The output does
not echo account values, passwords, password hints, note bodies, locked content,
or local artifact contents.

Share participant operations are supported separately through private Notes
collaboration and CloudKit participant paths:

```bash
apple notes state share --id NOTE_ID --target PARTICIPANT_ID --scope read-only --allow-persistent-action --json
apple notes state share-folder --folder FOLDER --target PARTICIPANT_ID --scope read-write --allow-persistent-action --json
apple notes state invite --id NOTE_ID --target PARTICIPANT_ID --allow-persistent-action --json
```

Those commands return only target, participant, share, permission, count, and
verifier hashes or enum labels. The output does not echo participant
targets, folder names, account values, raw collaboration handles, share links,
or local artifact paths. Still-locked content export and raw activity-detail
export remain gated until private-framework mutation proof and privacy-safe
verifier readback are accepted. Locked-note password setup, custom password
change/reset, unlock, and current-session locked-content export have dedicated
supported private paths.

Copy or export an existing collaboration link for an already shared note or
folder:

```bash
apple notes state copy-link --id NOTE_ID --dry-run --json
apple notes state copy-link --id NOTE_ID --allow-persistent-action --json
apple notes state copy-link --folder FOLDER --allow-persistent-action --json
apple notes state copy-link --folder FOLDER --output ./shared-link.txt --dry-run --json
apple notes state copy-link --folder FOLDER --output ./shared-link.txt --allow-artifact-action --json
```

Execution reads the existing private share URL and writes it to the system
clipboard with `--allow-persistent-action` or to an explicit `.txt` artifact
with `--allow-artifact-action`. JSON output returns target, URL, share, and owner
hashes, URL byte count, clipboard/artifact verification, and verifier checks; it
does not print the raw collaboration link. Creating a new link remains gated;
changing access scope for an already shared note or folder is supported
separately by
`state share --id NOTE_ID|--folder FOLDER --scope invited-only|anyone-with-link`.

Read participant/access metadata for an already shared note or folder:

```bash
apple notes state participants --id NOTE_ID --json
apple notes state participants --folder FOLDER --json
apple notes state participants --id NOTE_ID --output ./participants.json --dry-run --json
apple notes state participants --id NOTE_ID --output ./participants.json --allow-artifact-action --json
```

The command is read-only unless `--output` is provided. JSON output returns
target/share/owner hashes, participant identity hash set, user-record hashes,
participant counts, and permission/role/acceptance/public-permission enum values
plus verifier checks. The artifact form writes the same hash-only metadata to
the requested `.json` file after `--allow-artifact-action`. It does not print
participant names, emails, phone numbers, raw participant identifiers, note
titles, note bodies, folder names, or share links. New participant invites
remain gated; invite-policy changes, one existing participant's permission,
self-removal, and one already shared note or folder's access scope are supported
separately.

Per-note Hide Alerts for a shared note is supported as a persistent private
preference mutation:

```bash
apple notes state hide-alerts --id NOTE_ID --enabled true --dry-run --json
apple notes state hide-alerts --id NOTE_ID --enabled true --allow-persistent-action --json
```

Execution requires a shared note and private recordID readback. The result
returns the note ID hash, record ID hash, before/after booleans, participant
count, and verifier checks only; it does not print the note title, body,
participant values, raw record ID, or share links.

Notes settings, notification settings, widgets, and locked-notes password
settings have explicit accounting or boundary commands:

```bash
apple notes settings audit --json
apple notes settings read --account ACCOUNT_ID --json
apple notes settings sort --by date-edited --dry-run --json
apple notes settings sort --by date-edited --allow-persistent-action --json
apple notes settings new-note-style --style heading --dry-run --json
apple notes settings new-note-style --style heading --allow-persistent-action --json
apple notes settings default-account --account ACCOUNT_ID --dry-run --json
apple notes settings default-account --account ACCOUNT_ID --allow-persistent-action --json
apple notes settings group-by-date --enabled true --dry-run --json
apple notes settings group-by-date --enabled true --allow-persistent-action --json
apple notes settings group-by-date --scope default --enabled true --allow-persistent-action --json
apple notes settings group-by-date --scope query --enabled false --allow-persistent-action --json
apple notes settings quick-note-resume --enabled false --dry-run --json
apple notes settings quick-note-resume --enabled false --allow-persistent-action --json
apple notes settings checklist-sort --enabled true --dry-run --json
apple notes settings checklist-sort --enabled true --allow-persistent-action --json
apple notes settings mention-notifications --enabled false --dry-run --json
apple notes settings mention-notifications --enabled false --allow-persistent-action --json
apple notes settings text-size --size 18 --dry-run --json
apple notes settings text-size --size 18 --allow-persistent-action --json
apple notes settings touch-id --enabled true --account ACCOUNT_ID --dry-run --json
apple notes settings touch-id --enabled true --account ACCOUNT_ID --allow-persistent-action --json
apple notes settings on-my-mac --enabled true --dry-run --json
apple notes settings on-my-mac --enabled true --allow-persistent-action --json
apple notes settings locked-notes --account ACCOUNT_ID --scope custom --passphrase-stdin --dry-run --json
apple notes settings locked-notes --account ACCOUNT_ID --scope custom --passphrase-stdin --hint HINT --allow-persistent-action --json
apple notes settings locked-notes --account ACCOUNT_ID --scope custom --passphrase-env NOTES_PASSPHRASE --allow-persistent-action --json
apple notes settings locked-notes --account ACCOUNT_ID --scope custom --passphrase-file ./passphrase.txt --allow-persistent-action --json
apple notes settings locked-notes --account ACCOUNT_ID --scope login-password --json
apple notes settings change-password --account ACCOUNT_ID --old-passphrase-env OLD_NOTES_PASSPHRASE --new-passphrase-env NEW_NOTES_PASSPHRASE --dry-run --json
apple notes settings change-password --account ACCOUNT_ID --old-passphrase-env OLD_NOTES_PASSPHRASE --new-passphrase-env NEW_NOTES_PASSPHRASE --hint HINT --allow-persistent-action --json
apple notes settings change-password --account ACCOUNT_ID --old-passphrase-file ./old-passphrase.txt --new-passphrase-file ./new-passphrase.txt --allow-persistent-action --json
apple notes settings change-password --account ACCOUNT_ID --old-passphrase-stdin --new-passphrase-env NEW_NOTES_PASSPHRASE --allow-persistent-action --json
apple notes settings reset-password --account ACCOUNT_ID --passphrase-stdin --dry-run --json
apple notes settings reset-password --account ACCOUNT_ID --passphrase-stdin --hint HINT --allow-persistent-action --json
apple notes settings reset-password --account ACCOUNT_ID --passphrase-env NOTES_PASSPHRASE --allow-persistent-action --json
apple notes settings reset-password --account ACCOUNT_ID --passphrase-file ./passphrase.txt --allow-persistent-action --json
apple notes settings view-layout --style gallery --json
apple notes settings link-highlight-color --color purple --json
apple notes settings notifications --account ACCOUNT_ID --json
apple notes settings widgets --account ACCOUNT_ID --json
apple notes settings password --account ACCOUNT_ID --json
```

`settings audit` accounts for the official Change Notes settings, Customize how
notes appear, Use Notes widgets, and Manage notifications pages without reading
settings or notes. It reports 28 workflow records: 19 supported
private-framework/command paths, 9 delegated macOS/system/Notes.app UI surfaces,
and 0 gated security/password mutation gaps. The
audit rejects selectors, makes no Notes implementation, AppleScript,
or `SQLiteReader` calls, and does not print account values, setting values,
passwords, hints, note bodies, or implementation evidence.

`settings read` returns a privacy-safe read-only account of the official Notes
settings families: each family is reported as supported, gated, or delegated,
with default-account SHA-256 evidence, default new-note paragraph style
SHA-256 evidence, note-list sort SHA-256 evidence, group-by-date boolean
evidence, default/query date-header type SHA-256 evidence, Quick Note resume boolean evidence, mention-notification boolean
evidence, default text-size hash evidence, checklist auto-sort boolean evidence,
selected-account locked-notes passphrase state evidence,
account-scoped Touch ID preference evidence, On My Mac account presence,
account counts, and verifier checks.
It does not print raw account
names, account IDs, paragraph style names, defaults, date-header enum values, passwords, or setting
payloads. `settings sort`, `settings default-account`,
`settings group-by-date`, `settings quick-note-resume`,
`settings mention-notifications`, `settings text-size`,
`settings new-note-style`, `settings checklist-sort`, and
`settings locked-notes --account ACCOUNT --scope custom`,
`settings locked-notes --account ACCOUNT --scope login-password`,
`settings change-password --account ACCOUNT`,
`settings reset-password --account ACCOUNT`, and
`settings touch-id --account ACCOUNT --enabled true|false`, and
`settings on-my-mac --enabled true|false` are supported private-framework
preference/account-lifecycle mutations. `settings locked-notes --scope custom`
sets a custom locked-notes password for one selected account through private
`ICAccountPassphraseManager.setPassphrase:hint:`, accepts passphrases only from
stdin/env/file sources, requires `--allow-persistent-action`, and reports only
account, source, hint, and state hashes/lengths.
`settings locked-notes --account ACCOUNT --scope login-password` sets the
selected account to the login-password locked-notes method only when macOS
login-password preflight passes, private mode support readback succeeds, and
private `passwordProtectedNotes` readback proves zero existing
password-protected notes. It requires `--allow-persistent-action`, does not
accept custom passphrase or hint input, and reports only account/mode hashes,
preflight booleans, and counts. `settings reset-password`
resets the custom locked-notes password for one selected account through
private `ICAccountPassphraseManager.setPassphrase:hint:isReset:`, accepts
passphrases only from stdin/env/file sources, requires
`--allow-persistent-action`, and records the reset boundary without printing
passwords, hints, account values, env names, or file paths. `settings
change-password` changes the selected account custom locked-notes password
through private
`ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:`,
accepts separate old and new passphrase sources from stdin/env/file selectors,
requires `--allow-persistent-action`, and records change-boundary evidence
without printing old/new passwords, hints, account values, env names, or file
paths. It rejects using stdin for both old and new passphrases in the same
invocation to avoid ambiguous stream ownership. `settings group-by-date --scope
default|query` changes the default or query date-header type preference and
reports hash-only enum readback. `settings touch-id` changes the Notes
account-scoped Touch ID preference through private `ICAuthenticationState`
readback and reports only account/preference hashes, bools, and
LocalAuthentication boundary checks; biometric authentication remains delegated
to macOS. Disabling On My Mac requires an empty
non-default local account, another active Notes account, dry-run support,
`--allow-persistent-action`, and private settings/account readback verification.
Official setting change commands for password-method migration/change and
the legacy `settings password` command currently return
`unsupported_operation` with `status: gated`. They are future password/security
backlog, not current daily-use closeout blockers, until private settings
mutation proof and verifier readback are accepted. Window view layout, link/highlight
color, system notification settings, and widgets return `unsupported_operation`
with `status: delegated` because they are macOS, appearance, window,
notification, or widget surfaces rather than direct Notes preference writes.
The gated/delegated commands make no Notes implementation, AppleScript, or SQLite calls
and do not echo account values or requested setting values.

## Mutations

Common mutations use the `DryRun` safety flow:

```bash
apple notes create --folder FOLDER_ID --title "Plan" --body "Draft" --dry-run --json
apple notes quick-note create --folder FOLDER_ID --title "Scratch" --body "Draft" --dry-run --json
apple notes append --id NOTE_ID --body "Next step" --dry-run --json
apple notes update --id NOTE_ID --title "Updated plan" --dry-run --json
apple notes move --id NOTE_ID --folder FOLDER_ID --dry-run --json
apple notes copy --id NOTE_ID --folder FOLDER_ID --dry-run --json
apple notes restore --id NOTE_ID --folder FOLDER_ID --dry-run --json
apple notes restore-all --folder FOLDER_ID --dry-run --json
apple notes restore-all --folder FOLDER_ID --allow-destructive-selection --json
apple notes purge --id NOTE_ID --dry-run --json
apple notes purge --id NOTE_ID --allow-destructive-selection --json
apple notes empty-trash --dry-run --json
apple notes empty-trash --allow-destructive-selection --json
apple notes pin --id NOTE_ID --dry-run --json
apple notes unpin --id NOTE_ID --dry-run --json
apple notes batch pin --ids NOTE_ID,NOTE_ID --dry-run --json
apple notes batch unpin --ids NOTE_ID,NOTE_ID --dry-run --json
apple notes batch move --ids NOTE_ID,NOTE_ID --folder FOLDER_ID --dry-run --json
apple notes batch copy --ids NOTE_ID,NOTE_ID --folder FOLDER_ID --dry-run --json
apple notes batch delete --ids NOTE_ID,NOTE_ID --dry-run --json
apple notes batch delete --ids NOTE_ID,NOTE_ID --allow-destructive-selection --json
apple notes folders create --name "Planning" --account ACCOUNT_ID --dry-run --json
apple notes folders create --name "Planning" --parent FOLDER_ID --dry-run --json
apple notes folders rename --folder FOLDER_ID --name "Projects" --dry-run --json
apple notes folders move --folder FOLDER_ID --parent PARENT_FOLDER_ID --dry-run --json
apple notes folders move --folder FOLDER_ID --account ACCOUNT_ID --dry-run --json
apple notes folders delete --folder FOLDER_ID --dry-run --json
apple notes folders purge --folder FOLDER_ID --dry-run --json
apple notes folders purge --folder FOLDER_ID --allow-destructive-selection --json
apple notes folders sort --folder FOLDER_ID --by date-edited --direction newest-first --dry-run --json
apple notes folders date-headers --folder FOLDER_ID --enabled true --dry-run --json
apple notes tags audit --json
apple notes tags search --tag Urgent --json
apple notes tags search --tags Urgent,Home --mode all --json
apple notes tags search --include-tags Urgent,Yonder --exclude-tags Home --mode any --json
apple notes tags add --id NOTE_ID --tag Urgent --dry-run --json
apple notes tags remove --id NOTE_ID --tag Urgent --dry-run --json
apple notes tags convert-to-text --id NOTE_ID --tag Urgent --dry-run --json
apple notes tags rename --tag Urgent --name Important --dry-run --json
apple notes tags rename --tag Urgent --name Important --allow-merge --dry-run --json
apple notes tags delete --tag Urgent --dry-run --json
apple notes tags delete --tag Urgent --allow-destructive-selection --json
apple notes tags delete --tags Urgent,Review --dry-run --json
apple notes tags delete --tags Urgent,Review --allow-destructive-selection --json
apple notes delete --id NOTE_ID --dry-run --json
```

`update --title` changes only the title and preserves the existing attributed
body and its paragraph separator. The title must be one non-empty paragraph.
For readable notes, the CLI reports the complete title paragraph when native
evidence resolves Notes' shortened display title.
Submitting the current title again returns `changed: false` without saving the
note. An explicit `update --body` replaces the plain-text body; use the rich
content replacement commands for formatted content.

Create, update, and append keep the supplied body text exactly, including
leading and trailing whitespace. `update --body ""` clears the body while
preserving the title and its formatting. Supplying both `--title` and `--body`
updates them together. Append requires a non-empty body.

`quick-note create` creates one persisted Quick Note/system-paper note through
the private note writer in an explicit folder. Execution verifies ordinary note
readback plus private note-state `isSystemPaper` readback. Quick Note UI launch
through hot corner, Fn-Q, Safari active-page capture, and thumbnails remains a
delegated Notes.app UI surface.

`--json` controls output shape only. It does not authorize side effects.
`--dry-run` previews parsing, normalization, scope digest, and mutation summary
without executing the write.

When a mutation executes, JSON output includes a `verification` report. The
report records privacy-preserving post-write checks such as readback hashes,
field lengths, existence checks, and bounded store evidence. If the final
Notes state cannot be verified, the command fails instead of reporting a
successful mutation.

In default private-framework-backed builds, current text, folder, note lifecycle, and
tag mutations execute through the typed private Notes framework
writer. `folders create` creates one root folder with `--account` or one
subfolder with `--parent`, then verifies name, account, parent placement, and
optional store evidence. `folders rename` renames one editable concrete folder,
then verifies identity, name, account preservation, parent preservation, and
optional store evidence. `folders move` moves one editable concrete folder
under an explicit editable parent with `--parent` or to a selected account root
with `--account`, including cross-account parent/root placement, then verifies
identity, name preservation, target account, target parent or account root,
bounded descendant account readback, and optional store evidence.
`folders delete` deletes one user-deletable concrete folder through Notes'
Recently Deleted behavior, then verifies visible folder removal and optional
store evidence. `folders purge` permanently removes one already-deleted
purgable concrete folder only with `--allow-destructive-selection`, then
verifies the folder is absent from both visible and purgable-folder readback
with optional store evidence. `folders sort` changes one editable concrete folder's custom
note sort and verifies order/direction/default/ascending/resolved-order
readback. `folders date-headers` toggles date headers for one editable concrete
folder and verifies support plus final visibility/type state. Parent folders must be
editable concrete folders that allow subfolders. Default/query date-header
preference customization is supported separately by `settings group-by-date
--scope default|query`; system folder deletion remains gated. `move` verifies
identity preservation, destination folder/account, title/body preservation, and
tag preservation before reporting success. `copy` verifies a new note identity, source preservation, destination
folder/account, title/body preservation, and tag preservation. `restore`
requires a target folder and verifies identity preservation, visible readback,
destination folder/account, title/body preservation, and tag preservation.
`restore-all` restores every currently discoverable note in Recently Deleted
up to the 2,000-note safety bound into one explicit editable concrete folder.
It requires `--allow-destructive-selection`, returns counts and ID hashes
rather than note titles or bodies, and verifies visible readback, restore-only
absence, destination folder/account, title/body preservation, and tag
preservation for the batch.
`purge` permanently removes one note that is already in Recently Deleted or
Trash. It requires `--allow-destructive-selection` for execution and verifies
that the note is absent from both visible and restorable readback before
reporting success. `empty-trash` permanently removes every currently
discoverable note in Recently Deleted up to the 2,000-note safety bound. It
requires `--allow-destructive-selection`, returns counts and ID hashes rather
than note titles or bodies, and verifies visible plus restorable readback
absence for the batch. `pin` and `unpin` change one visible note's pinned state.
They are idempotent, read current state before writing, and verify final
pinned state plus identity/title/folder/account preservation before reporting
success.
`batch pin`, `batch unpin`, `batch move`, `batch copy`, and `batch delete`
operate on at least two explicit unique note IDs from `--ids`. Batch move and
copy require one explicit editable concrete target folder. Batch delete
requires `--allow-destructive-selection` for execution. Results and dry-runs
return note counts, created-copy counts where applicable, and ID hashes rather
than raw note IDs, titles, or bodies. Execution reuses the typed private
single-note lifecycle writer paths and verifies every selected note with
private readback before reporting success.
Normal list/search/read remain visible-note only. Trash, Smart Folder, system
folder, and read-only folder targets are rejected. Copying
password-protected/locked notes remains gated. Non-default private-framework-backed builds report the
private framework build requirement instead of falling back to AppleScript.

## Import

`import text` imports one local UTF-8 `.txt` file into a new note:

```bash
apple notes import text \
  --folder FOLDER_ID \
  --file ./note.txt \
  --title "Imported note" \
  --dry-run \
  --json
```

Dry-run records the source path, source name, byte count, and source SHA-256
without creating the note or printing the imported body. Execution creates the
note through the accepted private note creation path and verifies note readback.
Only `.txt` input is accepted by this command.

Markdown import supports a single-file semantic path, single-file local
relative image resources, and an explicit attachment-resource package path:

```bash
apple notes import markdown --folder FOLDER_ID --file ./note.md --dry-run --json
apple notes import markdown --folder FOLDER_ID --file ./note.md --include-attachments --dry-run --json
apple notes import markdown --folder FOLDER_ID --file ./Note.mdpkg --include-attachments --dry-run --json
```

Single-file import reads one `.md` or `.markdown` file as UTF-8 Markdown,
converts it to attributed Notes content through the private Markdown conversion
path, writes it through private Notes text storage, and verifies note and body
structure readback. With `--include-attachments` on a regular Markdown file,
local relative inline image destinations under the Markdown file directory are
imported as attachments through the private attachment writer and verified by
attachment metadata/export-hash readback. Remote or schemed URLs, absolute
paths, parent-directory escapes, symlinks, hidden files, non-regular files,
empty files, oversized resources, and duplicate attachment filenames are
refused before mutation. Package import requires `.mdpkg` or
`.markdownpackage` plus `--include-attachments`. The package must contain
exactly one `.md` or `.markdown` member and any resources must be direct files
under `Resources/`; the Markdown member is imported through the same semantic
path, and resources are imported as attachments through the same verifier path.
Dry-run records source path, byte count, body hash, semantic counts, package
file count, package tree SHA-256, and resource count without printing the
imported body or resource bytes.

RTF, RTFD, and HTML rich import are available in default private-framework-backed
builds for one local source:

```bash
apple notes import rtf --folder FOLDER_ID --file ./Note.rtf --dry-run --json
apple notes import rtfd --folder FOLDER_ID --file ./Note.rtfd --dry-run --json
apple notes import html --folder FOLDER_ID --file ./Note.html --dry-run --json
apple notes import html --folder FOLDER_ID --file ./Note.htmlpkg --include-attachments --dry-run --json
```

The importer accepts one regular `.rtf`, `.html`, or `.htm` file or one
`.rtfd` package. HTML package import additionally accepts one `.htmlpkg` or
`.htmlpackage` directory when `--include-attachments` is explicit. The package
must contain exactly one `.html` or `.htm` member outside `Resources/`, and any
resources must be direct files under `Resources/`; the HTML member is imported
through the same rich import path, and resources are imported as attachments
through the private attachment writer and verified by attachment
metadata/export-hash readback. Rich import converts the source to attributed
content through the private Notes writer and verifies the created note by note
readback, title/folder readback, nonempty rich text, body-structure readback,
format-family accounting, source byte/hash evidence, and privacy checks. RTFD
and HTML package import also record package file count, resource file count,
total byte count, and package tree SHA-256. Dry-run and execution hash source
paths and file names and must not print the source path, file name, source body
text, package resource bytes, or imported note body.

ENEX import with supported tag, attachment resource preservation, and inline
resource reference accounting is available in default private-framework-backed builds:

```bash
apple notes import enex --folder FOLDER_ID --file ./Evernote.enex --dry-run --json
```

The importer accepts one bounded regular `.enex` file, creates one Notes note per
ENEX note in the selected editable folder, preserves supported tags, imports
decoded ENEX resources as Notes attachments, matches inline media references to
decoded resources by ENEX resource MD5, inserts matched resources at converted
body positions, and verifies note readback, title/folder readback, tag
membership, inline reference and placement counts, inline attachment readback,
attachment export hashes, imported-note count, and optional ENEX created/updated
date preservation.
Dry-run reports
source path/name hashes, byte count, note count, tag count, normalized tag count, resource count,
resource byte count, inline resource reference count, matched reference count,
and unmatched reference count without printing the local path, file name, ENEX
body text, resource bytes, or imported note body. Execution refuses before
mutation when the ENEX contains whitespace-bearing tags that need normalization,
unmatched inline media references, or an unsupported resource/parse shape.
Matched inline media references are accounted and tied to decoded resources by
ENEX resource MD5 before mutation.

Import a bounded directory tree while preserving supported folders:

```bash
apple notes import folder \
  --folder FOLDER_ID \
  --file ./NotesExport \
  --name Imported \
  --dry-run \
  --json
```

Dry-run reports source path/name hashes, source tree SHA-256, family counts,
directory/file/note/resource counts, and verifier requirements without printing
local paths, file names, source bodies, resource bytes, or imported note bodies.
Execution requires `--allow-destructive-selection`, creates one import-root
folder under the selected editable parent folder, recreates supported
subdirectories, imports supported TXT, Markdown, Markdown package, RTF, RTFD,
HTML, and ENEX files through their accepted import paths, and verifies folder
creation plus per-file import readback before reporting success. Unsupported
files and unsupported ENEX shapes are refused before mutation.

Use import audit before broader import work to account for supported and gated
import candidates without importing data:

```bash
apple notes import audit --file ./ImportFolder --json
```

The audit scans one file or bounded directory tree, reports supported TXT,
Markdown, Markdown package, RTF, RTFD, HTML, and ENEX note/normalized-tag/resource
attachment import families plus supported ENEX normalized-tag accounting,
supported ENEX inline resource reference accounting, supported ENEX inline
body-position placement, and supported folder-preserve import, and records
unsupported families as unsupported. It hashes paths and names instead of
printing local paths or file names.

## Replace

Use `replace` when you have reorganized note content outside Notes and want to
write the resulting rich document back into the same existing note:

```bash
apple notes replace markdown --id NOTE_ID --file ./Reorganized.md --dry-run --json
apple notes replace markdown --id NOTE_ID --file ./Reorganized.mdpkg --include-attachments --dry-run --json
apple notes replace html --id NOTE_ID --file ./Reorganized.htmlpkg --include-attachments --dry-run --json
apple notes replace rtf --id NOTE_ID --file ./Reorganized.rtf --dry-run --json
apple notes replace rtfd --id NOTE_ID --file ./Reorganized.rtfd --dry-run --json
```

The command preserves the selected note identity, folder, account, pin/shared
metadata, and other external state, then replaces the rich body through the
private Notes rich text writer. Pass `--title` to change the title; omit it to
keep the current title. Markdown and HTML package resources are inserted at
matched body positions when `--include-attachments` is explicit; remote URLs
remain links. RTFD uses the attributed attachment runs produced by the rich
conversion path.

Dry-run and execution output report source/package/resource counts, source and
body hashes, attributed-run and attachment-run counts, inline placement counts,
attachment export hashes, and verifier evidence. They do not print source
paths, source body text, target note body text, resource bytes, local media
paths, or raw private identifiers. Locked, password-protected, read-only,
deleted, trash, non-editable, and shared read-only notes are refused.

Use export audit before broader export or handoff work to account for supported,
delegated, and gated export-family behavior without writing files:

```bash
apple notes export audit --id NOTE_ID --json
```

The audit reads the selected note identity plus private note-state evidence,
hashes note ID and title, and reports accepted PDF, Markdown single-file/package,
HTML single-file/package, RTF, RTFD, accepted package resource preservation,
delegated print, and delegated Pages handoff records. Password-protected notes
already unlocked in the current Notes session report artifact exporters,
package resource preservation, and locked-content export as supported, with
print/Pages handoff delegated. Deleted, trashed, unsupported, or
cloud-fetch-needed notes are reported as selected-note gates. Still-locked
password-protected notes keep ordinary note-level exporters gated, while the
dedicated `state export-locked-content` path is supported when execution
supplies a passphrase source. Unbounded perfect conversion fidelity is rejected
as a non-current-guide guarantee. The command does not write artifacts,
submit print or Pages handoffs, or print note bodies, titles, folder/account
names, artifact bytes, or local paths.

Open a visible note in Pages through the delegated RTFD handoff:

```bash
apple notes open-in-pages \
  --id NOTE_ID \
  --allow-external-dispatch \
  --json
```

Dry-run reports the RTFD package file count, total byte count, and tree
SHA-256 without dispatching. Execution derives a staged RTFD package through
the private Notes share-export path, submits it to Pages only with
`--allow-external-dispatch`, and verifies application dispatch metadata, package
tree SHA-256, RTF member presence, protected external-dispatch boundary, and
note readback. Session-unlocked password-protected notes are accepted with
protected title/body suppressed from JSON/stdout; still-locked notes remain
gated.

Broader RTF conversion, broader HTML/RTF/general external resource
preservation, and broader non-title attachment update/transforms remain gated
until the private framework implementation and verifier proof are accepted.
Single or bounded batch attachment add, single attachment rename/remove, single raw attachment export, attachment-family
audit, visible-note
exports, TXT import, Markdown single-file relative resource import,
Markdown package resource round-trip, delegated print, and
delegated open in Pages
are supported separately through `attachments audit`, `attachments add`,
`attachments rename`, `attachments remove`, `attachments export`, `export pdf`, `export markdown`, `export html`,
`export rtf`, `export rtfd`, `export audit`, `import audit`, `import text`, `import markdown`,
`import rtf`, `import rtfd`, `import html`, `import enex`, `import folder`,
`print`, and
`open-in-pages`.

## Diagnostics

```bash
apple notes doctor --json
```

`doctor` reports local Notes app readiness and private framework probe status.
Use `doctor store` for read-only store/index diagnostics:

```bash
apple notes doctor store --scope summary --json
apple notes doctor store --scope schema --json
apple notes doctor store --scope entities --json
apple notes doctor store --scope indexes --json
```

Store diagnostics expose bounded file, schema, entity-count, and index-state
evidence. They do not print note bodies or note titles.

Use scoped doctor commands for private readback plus bounded store-object
evidence:

```bash
apple notes doctor note --id NOTE_ID --json
apple notes doctor folder --folder FOLDER_ID_OR_NAME --json
apple notes doctor account --account ACCOUNT_ID_OR_NAME --json
apple notes doctor write-lab --json
apple notes doctor rich-lab --json
```

Scoped diagnostics hash identifiers, titles, names, and body-derived evidence.
They expose counts, lengths, entity matches, and store/index state only; they
do not print note bodies, note titles, folder names, account names, or raw note
IDs.

`doctor write-lab` probes private Notes write selectors without executing a
write. It reports required and optional selector availability for the private
write candidate path, including folder create/rename/move/delete, attachment
remove, web/app/file URL link add/remove, web/app/file URL link update,
note-to-note link add/update/remove, paragraph note-link add/update/remove, and note purge/pin selectors, and always reports
`write_access: none`.

`doctor rich-lab` probes private Notes candidates for links, attachments, tags,
Smart Folders, body structure, accepted table mutation readiness, optional
future math mutation readiness,
and archive/import/export without executing a rich write. It reports accepted rich slices such as `body_structure`,
`body_checklist_add`, `body_checklist_set`, `body_checklist_set_all`,
`body_checklist_sort`, `body_checklist_convert`, `body_checklist_convert_range`,
`body_checklist_reorder`, `body_checklist_indent`, `body_checklist_delete`,
`body_paragraph_style`, `body_paragraph_align`,
`body_list_add`, `body_list_convert`, `body_list_convert_range`,
`body_paragraph_quote`, `body_inline_format`, `body_inline_color`,
`body_inline_highlight`, `body_inline_font`, `body_list_set_style`,
`body_list_reorder`, `body_list_indent`, and
`body_list_delete` while keeping `write_access: none`. It also reports
`accepted_capability` for table list/create/import/update/delete/convert-to-text/copy and math
list/insert/update; that is diagnostic evidence, not an execution path.
Attachment and link metadata listing, backlink metadata listing, single web URL link add/update/remove, single
app URL link add/update/remove, single file URL link add/update/remove, single note-to-note link add/update/remove, single paragraph note-link add/update/remove, single or bounded batch attachment add, single attachment rename/remove, and single raw
attachment export are supported separately through `attachments list`,
`attachments add`, `attachments rename`, `attachments remove`, `attachments export`, `export pdf`, `export markdown`, `export html`,
`export rtf`, `export rtfd`, `print`, `import text`, `import markdown`, `import rtf`, `import rtfd`, `import html`, `import enex`, `links list`, `links backlinks`, `links resolve`, `links add`, `links add-app`, `links add-file`, `links add-note`,
`links add-paragraph`, `links update`, `links update-app`, `links update-file`, `links update-note`, `links update-paragraph`, `links remove`, `links remove-app`, `links remove-file`, `links remove-note`,
`links remove-paragraph`, `smart-folders list`, `smart-folders criteria`, `smart-folders explain`, `smart-folders audit`, `smart-folders notes`, `smart-folders create`,
`smart-folders update`, `smart-folders duplicate`, `smart-folders copy-criteria`,
`smart-folders export-criteria`, `smart-folders import-criteria`,
`smart-folders rename`, `smart-folders delete`,
`body structure`, `body paragraph style`, `body paragraph align`, `body paragraph quote`, `body inline format`, `body inline color`, `body inline highlight`, `body inline font`, `body checklist add`, `body checklist set`,
`body checklist set-all`, `body checklist sort`, `body checklist convert`, `body checklist convert-range`, `body checklist reorder`, `body checklist indent`,
`body checklist delete`, `body checklist line-break`, `body checklist end`, `body list add`, `body list convert`,
`body list convert-range`, `body list set-style`, `body list reorder`,
`body list indent`, `body list delete`, `body list line-break`, `body list tab`, `body list end`, `state read`, and `state audit`.

## Capability Boundary

The detailed capability boundary lives in
`../../Architecture/Notes/CapabilityList.md`.

Direct Notes SQLite writes are rejected. AppleScript/SDEF is a read-only parity
reader, not a production implementation, writer, or fallback mode.
