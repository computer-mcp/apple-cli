# Notes Architecture

## Positioning

`notes` is the canonical Notes target under the `apple` CLI product:

```text
apple notes <resource?> <action> [options]
```

The target covers local Notes.app data-management workflows with semantic
command names. User-facing commands describe Notes concepts such as accounts,
folders, notes, links, attachments, tags, Smart Folders, import/export, and
diagnostics. They must not expose AppleScript, SQLite tables, raw private class
names, or implementation selection.

Notes has closed the current private-framework-backed milestone. Linked builds
use the imported Notes framework modules for accepted reads and writes across
accounts, folders, notes, tags, attachments, links, Smart Folders, rich body
editing, state/security, settings, import/export, print, and common mutation
workflows. Read-only local evidence remains available for doctor output,
enrichment, parity checks, and post-write verification.

## Capability Maturity

Current level: `L1.5 Private Framework Implemented`

Rationale: The imported Notes framework modules are the production path for
accepted Notes reads and writes in the default private-framework-backed build. Remaining capability gaps are
explicitly gated, delegated, or rejected in target-local capability
documentation.

## Capability Authority

The Notes capability baseline is defined in this order:

1. Apple Notes User Guide pages define user-visible capability candidates.
2. Installed Notes.app behavior on the target macOS version resolves local
   account, provider, locale, and feature availability.
3. The accepted `apple notes` command contract defines the CLI promise.
4. Generated Notes framework imports provide the production implementation
   mechanism for accepted reads and writes once each capability is proven.
5. Read-only Notes store and index inspection provides enrichment, diagnostics,
   parity evidence, and verifier evidence.

The Notes.app SDEF and read-only AppleScript parity reader remain useful
bounded comparison evidence. They are not the long-term capability source,
product ceiling, fallback architecture, writer surface, or peer implementation.

A capability enters the CLI promise only after it has a semantic command shape,
target-local safety policy, typed private framework path, verifier rule, tests,
and documentation. Durable capability accounting lives in
`CapabilityList.md`.

## Ownership

- `Sources/NotesCLI/Commands/` should own the typed `swift-argument-parser`
  command tree, option mapping, identity binding, result envelopes, dry-run
  payloads, destructive-selection gates, and user-facing diagnostics.
  `Commands.swift` owns parsing and option mapping; `Command.swift` owns
  dependency injection and positional dispatch. `NotesCommand<Domain>.swift`
  extensions own domain execution, drafts, audits and verification presentation.
  Only shared execution mechanics belong in `NotesCommandSupport.swift`.
- `Sources/NotesCLI/Operations/` owns accepted Notes reads, writes, verifiers,
  and implementation injection surfaces.
- `Sources/NotesCLI/Diagnostics/` owns doctor checks, runtime readiness, and
  read-only parity diagnostics.
- `Sources/NotesCLI/SQLiteReader/` should own the read-only
  `SQLiteReader` store and index
  discovery, bounded queries, enrichment, doctor evidence, and post-write
  verifier evidence.
- `Sources/NotesCLI/Models/` should own target models returned by commands and
  used by dry-run payloads.
- `Sources/NotesCLI/Support/` should own validation, parsing, privacy-preserving
  digests, local environment discovery, and human output helpers.

`NotesReading` and `NotesMutating` are target-local implementation injection
surfaces. `NotesAppleScriptParityReader` is a read-only parity reader, not a
`NotesMutating` implementation. Reads and mutations route through the Notes
production implementation in the default private-framework-backed build. AppleScript should remain
parity-only and should not become a durable multi-implementation selection
model.

## Implementation Model

| Component | Role | Boundary |
| --- | --- | --- |
| Imported Notes framework modules | Production implementation path for accepted Notes reads and writes. | Uses generated full-dump headers and local patched `.tbd` overlays where direct linking needs allowed-client metadata removed. |
| `SQLiteReader` | Enrichment, doctor diagnostics, parity checks, and post-mutation verification. | Reads bounded local evidence only. It never writes to `NoteStore.sqlite` or index state. |
| Apple Notes User Guide / installed app | Product capability baseline. | Defines candidate workflows and local availability before CLI acceptance. |
| AppleScript/SDEF parity reader | Read-only parity reference for bounded metadata comparison. | Must not become a fallback, writer, compatibility implementation, or product capability ceiling. |

Direct Notes SQLite writes are rejected. Broad Notes-only RAG or persistent
index product behavior is outside this target unless a future accepted design
changes the product boundary.

## Notes Framework Import Boundary

Notes framework access is built from SwiftPM Clang module targets for the
selected Notes private frameworks, including `NotesSupport`, `NotesHTML`,
`NotesShared`, `NotesUI`, `NotesEditor`, and `NotesPreviewKit`.

The import boundary is full-dump-derived: local dyld shared cache headers are
dumped, normalized for Swift/Clang import, and exposed through generated
headers and module maps under `Sources/<NotesFramework>/include`. Local
patched `.tbd` overlays may remove SDK allowed-client metadata while preserving
system framework install names. This keeps production code typed while avoiding
system SDK edits.

The generated framework surface is implementation evidence, not product
definition. Command names and JSON models remain semantic Notes CLI contracts.

## Command Semantics

Current command coverage is:

- `guide audit`
- `accounts list`
- `accounts workflow audit`
- `accounts add`
- `accounts remove`
- `accounts enable`
- `accounts disable`
- `folders list`
- `folders workflow audit`
- `folders create`
- `folders rename`
- `folders move`
- `folders delete`
- `folders purge`
- `smart-folders list`
- `smart-folders criteria`
- `smart-folders explain`
- `smart-folders audit`
- `smart-folders notes`
- `smart-folders create`
- `smart-folders update`
- `smart-folders create-criteria`
- `smart-folders update-criteria`
- `smart-folders duplicate`
- `smart-folders copy-criteria`
- `smart-folders export-criteria`
- `smart-folders import-criteria`
- `smart-folders rename`
- `smart-folders delete`
- `tags list`
- `tags search`
- `tags audit`
- `tags add`, `tags remove`, `tags convert-to-text`, `tags rename`, and
  `tags delete`
- `attachments list`
- `attachments audit`
- `attachments workflow audit`
- `attachments add`
- `attachments copy`
- `attachments rename`
- `attachments remove`
- `attachments export`
- `attachments export-pdf`
- `attachments pdf inspect`
- `attachments scan inspect`
- `attachments markup inspect`
- `attachments markup edit`
- `attachments recognized-text generate`
- `attachments recognized-text export`
- `attachments recognized-text index`
- `attachments image objects`
- `attachments image description get`
- `attachments image description set`
- `attachments markup add-shape`
- `attachments markup add-text`
- `attachments markup add-signature`
- `attachments markup highlight`
- `attachments markup sketch`
- `attachments markup draw`
- `attachments add-webpage`
- `attachments update-webpage`
- `attachments audio audit`
- `attachments audio rename`
- `attachments audio save`
- `attachments audio delete`
- `attachments audio transcript`
- `attachments audio search`
- `export audit`
- `export pdf`
- `export markdown`
- `export html`
- `export rtf`
- `export rtfd`
- `import audit`
- `import text`
- `import markdown`
- `import folder`
- `import rtf`
- `import rtfd`
- `import html`
- `import enex`
- `replace markdown`
- `replace html`
- `replace rtf`
- `replace rtfd`
- `print`
- `links list`
- `links audit`
- `links backlinks`
- `links add`
- `links add-app`
- `links add-file`
- `links add-note`
- `links add-paragraph`
- `links update`
- `links update-app`
- `links update-file`
- `links update-note`
- `links update-paragraph`
- `links remove`
- `links remove-app`
- `links remove-file`
- `links remove-note`
- `links remove-paragraph`
- `body structure`
- `body surfaces`
- `body format audit`
- `body collapsible list`
- `body collapsible set`
- `body paragraph style`
- `body paragraph align`
- `body paragraph quote`
- `body inline format`
- `body inline color`
- `body inline highlight`
- `body inline font`
- `body checklist add`
- `body checklist set`
- `body checklist set-all`
- `body checklist convert`
- `body checklist convert-range`
- `body checklist reorder`
- `body checklist indent`
- `body checklist delete`
- `body checklist line-break`
- `body checklist end`
- `body list add`
- `body list convert`
- `body list convert-range`
- `body list set-style`
- `body list reorder`
- `body list indent`
- `body list delete`
- `body list line-break`
- `body list tab`
- `body list end`
- `state read`
- `state audit`
- `state lockability`
- `state collaboration audit`
- `state security audit`
- `state participants`
- `state activity`
- `workflow audit`, `workflow shortcuts audit`, `list`, `search`,
  `search audit`, and `read`
- `quick-note create`
- `create`, `import text`, `import markdown`, `import rtf`, `import rtfd`, `import html`,
  `import enex`, `replace markdown`, `replace html`, `replace rtf`, `replace rtfd`,
  `update`, `append`, `move`, `copy`,
  `restore`, `delete`, `purge`, `pin`, and `unpin`
- `doctor`, `doctor store`, `doctor note`, `doctor folder`,
  `doctor account`, `doctor write-lab`, and `doctor rich-lab`

In default private-framework-backed builds, account/folder/tag/Smart
Folder/attachment/link/body-structure/note reads use the typed private
framework reader. Single attachment raw data export uses the typed
`ICAttachment`/`ICMedia` read path plus the command-layer artifact writer.
Single attachment generated/fallback PDF export uses the same selected
attachment readback plus private PDF data paths for PDF/scan/paper attachments,
writes only a verified `.pdf` artifact, and keeps PDF/scan editing beyond that
artifact export gated.
Existing audio transcript read/export/copy/search uses selected or bounded
private audio-document readback over `ICAttachment.audioModel.audioDocument` /
`ICAttachment.attachmentModel.audioDocument`; copy-to-note appends one selected
existing transcript-family text through the private note append path with
target body suffix hash readback, delegated clipboard copy writes one selected
transcript-family text to the system pasteboard behind `--allow-persistent-action`
with clipboard readback/change-count evidence, and search returns query hashes,
content-kind match counts, content hashes, source kind, and verifier evidence
without printing transcript text, copied text, target note body, clipboard text,
or the raw query. Bounded audio transcript search accepts the same account/folder
visible-note selection and keeps `--id` mutually exclusive with account/folder
selectors.
`notes search` is a bounded visible-note text search by default. `--scope text`
keeps the supported title/body summary path, and `--id NOTE_ID --query QUERY`
searches one selected note's title/body through the private note read path while
returning only note summaries and never printing the body. Password-protected or
locked notes are title-only for search, including single-note search.
`--account ACCOUNT` limits the same title/body summary search to one selected
account through the private account selector path; it cannot be combined with
`--id`. `notes list --account ACCOUNT [--folder FOLDER]` uses the same
account-scoped visible-note selector for summary listing without reading note
bodies. `--include-recently-deleted` merges the visible search result set with
bounded restore-only private restorable-note readback, supports account/folder
and single-id selection, and still returns summaries only without deleted note
bodies. `notes search locked-title --query QUERY` and `--scope locked-title`
use private visible-note summaries plus note-state readback to match only
password-protected or locked note titles without reading or matching locked
bodies. Non-text Apple Notes search surfaces are explicit scope boundaries:
`attachment-name` delegates to `attachments search`, `audio-transcript`
delegates to `attachments audio search`, `pdf-content` delegates to
`attachments pdf search`, scan/image/drawing/handwriting scopes delegate to
`attachments scan search`, `attachments image search`, or
`attachments drawing search`, and `suggested` delegates to the existing semantic
state/tag/Smart Folder/attachment commands. The visual attachment search
commands read existing Notes private searchable/indexable text and return only
hashes, byte counts, match counts, and attachment metadata. `notes search
natural-language` is supported through the typed private `ICSearchQueryOperation`
natural-language search path, private NL query readback, note-summary mapping,
and hash/accounting evidence; it does not print raw query text or note content.
`notes search attachment-content` is supported as a composite over accepted
private attachment metadata, PDF text, existing audio transcript, and
scan/image/drawing searchable-text slices with hash-only evidence; `--scope
attachment-content` maps to the same composite search without the family guard
option. Recognized-text artifact export/generation is supported
separately by `attachments recognized-text export` and `attachments
recognized-text generate`, `attachments recognized-text index`, and hash-only
image classification summary readback through `attachments image objects`; arbitrary
attachment-content semantics beyond those accepted slices remain attachment/media gated surfaces.
`notes search audit` is the read-only capability-family accounting surface for
the Apple Notes search guide. It requires no query, makes no Notes implementation call,
and accounts for supported visible/account/single-note/Recently Deleted text,
natural-language search, locked-title-only search, and composite
attachment-content search, plus delegated attachment-name/PDF/audio/
scan-image-drawing-handwriting/suggested/Siri/Spotlight surfaces with explicit
command strings where present.
`notes guide audit` is the selector-free, no-implementation official Notes User Guide
Table of Contents coverage slice for the current macOS Tahoe Notes guide. It
reports 36 page records: 28 supported, 5 delegated, 2 gated, and 1 rejected.
Supported records point to guide pages whose dominant semantic surface is
already covered by accepted CLI commands or family audits. Delegated records
cover external account setup, Calculator handoff, widgets, appearance, and
system notification surfaces; these records are accounted boundaries, not
implemented Notes CLI behavior. Gated records identify guide pages whose
remaining private-framework work is future password/security backlog rather
than a current daily-use closeout blocker: Lock Notes and Change password. The
rejected record captures the
Copyright and trademarks page as a non-capability reference page. The audit
rejects selectors and makes no Notes implementation, AppleScript, or `SQLiteReader`
calls.
`notes accounts workflow audit` is the selector-free, no-implementation official
Add/remove accounts accounting slice. It reports 13 records: 4 supported, 7
delegated, 0 gated, and 2 rejected. Supported records point to accepted private
account listing, account-scoped visible-note/folder selection, On My Mac
enablement, and empty-local-account On My Mac disablement. Delegated records
cover macOS Internet Accounts add/remove/service toggle, account type and
credential UI, Safari/System Settings sign-in continuation, and
cross-device/Handoff setup. Rejected
records capture Apple's provider feature-parity and On My Mac cross-device
limits. The audit rejects selectors and makes no Notes implementation, AppleScript, or
`SQLiteReader` calls.
`notes folders workflow audit` is the selector-free, no-implementation official About
accounts/folders and Add/remove folders accounting slice. It reports 26
records: 14 supported, 6 delegated, 0 gated, and 6 rejected. Supported records
point to accepted private folder hierarchy/system-folder reads, folder
create/rename/move/delete/purge/sort/reorder commands, move-impact preflight,
shared-permission and cross-account fidelity-risk accounting, and note
move/copy folder placement. Delegated records cover Notes.app sidebar, account
disclosure, sidebar resize, File menu/context menu, and drag-and-drop UI routes.
No official folder workflow record remains gated; Apple's documented
cross-account formatting/attachment loss behavior is represented as private
preflight risk accounting rather than a guaranteed preservation promise.
Rejected records capture
Apple's system-folder, All/Notes folder, Recently Deleted provider, shared-note
account, and locked-note account-move limits. The audit rejects selectors and
makes no Notes implementation, AppleScript, or `SQLiteReader` calls.
`notes workflow audit` is the selector-free, no-implementation official note lifecycle
and viewing workflow accounting slice for the current Apple Notes Create/Edit,
Quick Note, View Notes, Sort and Pin, Delete, and Keyboard Shortcuts/Gestures
guide pages. It reports 40 records: 22 supported, 17 delegated, 0 gated, and 1
rejected. Supported records point to accepted private-framework note
list/read/create/update/append/copy/move/delete/restore/purge/pin/unpin, batch
pin/unpin/move/copy/delete, Quick Note system-paper creation, settings
sort/text-size/Quick Note resume, folder sort, collapsible-section state, note
date/folder-count metadata, shared activity metadata paths, and private
unlock plus authenticated locked-content artifact export.
Delegated records cover Siri, Notes.app toolbar/Touch Bar/window/sidebar/list/
gallery UI, macOS text services, clipboard and Universal Clipboard, Writing
Tools, Quick Note hot corner/Fn-Q/window UI, Safari Quick Note integration,
locked-note authentication UI, per-note zoom, note-count display, shortcuts,
gestures, widgets, and provider retention timing. No note lifecycle workflow
record remains gated; ordinary note-level exporters still gate currently locked
notes outside the dedicated authenticated locked-content command. The rejected
record captures Apple's Quick Note lock limitation. The
audit rejects note, folder, title, body, text, query, and other selectors and
makes no Notes implementation, AppleScript, or `SQLiteReader` calls.
`notes workflow shortcuts audit` is the selector-free, no-implementation official
Keyboard Shortcuts and Gestures accounting slice. It reports 58 records: 37
supported, 21 delegated, 0 gated, and 0 rejected. Supported records map
shortcut actions to accepted semantic CLI commands for note/Quick Note/folder
creation, duplicate/copy, search, print, pin/delete, attachment/link/table,
paragraph/list/checklist/block-quote/font/monostyled/list-indent/reorder, table row/
column insertion, table-cell newline/tab text input, list/checklist soft-return
insertion, and ordinary-list literal-tab insertion. Delegated records cover
Notes.app window/view/focus, share/collaboration UI toggles, linked-note
navigation, per-note zoom, table navigation, and table selection. The
audit rejects selectors and makes no Notes implementation, AppleScript, or
`SQLiteReader` calls.
`notes tags audit` is the selector-free, no-implementation official Use Tags workflow
accounting slice for the current Apple Notes tags guide page. It reports 15
records: 12 supported, 3 delegated, and 0 gated. Supported records point to
accepted private-framework tag metadata listing, single-tag note search,
multi-tag All/Any tag search, include/exclude tag search, single-note tag
add/remove, non-merge tag rename, rename-to-existing merge with explicit
`--allow-merge`, and single or multi-tag delete with Smart Folder cascade
preflight plus private Smart Folder criteria delta readback, and
`tags convert-to-text` with private body plaintext hash preservation readback.
Delegated records cover suggested tag picker UI, sidebar click-selection UI,
and participant-specific shared-note tag adoption. No Use Tags workflow remains
gated in this target audit. The audit rejects tag, note, name, account,
query, and other selectors and makes no Notes implementation,
AppleScript, or `SQLiteReader` calls.
Attachment add uses the typed `ICNote.addAttachmentWithData:filename:`
private writer plus attachment export hash readback for one local file or a
bounded preflighted batch.
Single attachment remove uses typed `ICAttachment.isDeletable` and
`ICAttachment.markForDeletion` plus attachment absence readback.
Single web URL link add uses typed `ICNote.addURLAttachmentWithURL:` plus link
metadata readback.
Single web URL link update uses typed
`ICInlineAttachment.tokenContentIdentifier`, `ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate` plus selected-link identity,
URL hash, old URL replacement, and note readback.
Single app URL link add uses typed `ICNote.addURLAttachmentWithURL:` plus
link metadata readback, app scheme/hash verification, and raw app URL absence.
Single app URL link update uses typed
`ICInlineAttachment.tokenContentIdentifier`, `ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate` plus app-link metadata
readback, selected-link identity, URL hash, raw app URL absence, old URL
replacement, and note readback.
Single file URL link add uses the same typed URL attachment selector for one
regular local file or directory URL, but command output exposes only file
URL/path hashes, source kind, scheme, link metadata readback, URL hash
verification, raw local file URL absence, and note readback.
Single file URL link update uses typed
`ICInlineAttachment.tokenContentIdentifier`, `ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate` plus file-link metadata readback,
selected-link identity, file URL hash, raw local file URL absence, source-kind
evidence, old URL replacement, and note readback.
Single note-to-note link add uses typed
`ICInlineAttachment.newLinkAttachmentToNote:fromNote:parentAttachment:` plus
link metadata, note-link kind, source note, target note, and target identity
readback.
Single note-to-note link update uses typed
`ICInlineAttachment.changeLinkDestinationFromNote:toNote:` to retarget the
selected ordinary note link in place, preserving selected-link identity while
verifying link metadata, note-link kind, source note, target note, target
identity, target backlink readback, and old-target backlink absence.
Single web URL link remove uses typed `ICInlineAttachment` metadata,
`ICInlineAttachment.isDeletable`, and `ICInlineAttachment.markForDeletion`
plus link absence readback.
Single app URL link remove uses typed `ICInlineAttachment` metadata, app URL
scheme evidence, `ICInlineAttachment.isDeletable`, and
`ICInlineAttachment.markForDeletion` plus link absence, selected-link identity,
and note readback.
Single file URL link remove uses typed `ICInlineAttachment` metadata, file URL
scheme evidence, `ICInlineAttachment.isDeletable`, and
`ICInlineAttachment.markForDeletion` plus link absence, selected-link identity,
and note readback.
Single note-to-note link remove uses typed `ICInlineAttachment` metadata,
ordinary note-link discrimination, `ICInlineAttachment.isDeletable`, and
`ICInlineAttachment.markForDeletion` plus link absence, note-link kind,
selected-link identity, and note readback.
Visible-note PDF export uses the typed `NotesEditor` print controller path
plus the same command-layer artifact writer and artifact verifier.
Visible-note Markdown export uses typed `NotesUI`
`ICMarkdownRepresentation` / `ICMarkdownString` conversion plus the same
command-layer artifact writer and artifact verifier. When
`--include-attachments` is requested, exportable attachment resources are read
through typed private Notes media APIs and written as a verified Markdown
package.
Visible-note HTML export uses the typed `NotesUI`
`ICNote.htmlStringWithAttachments(false/true)` path plus the same command-layer
artifact writer and artifact verifier; the `true` path is available only when
the user explicitly requests `--include-attachments`.
Visible-note RTF member export uses the typed `NotesUI` share exporter path
and only extracts a single RTF file when the generated RTFD package contains
no other resources.
Visible-note RTFD package export uses the typed `NotesUI` share exporter path,
then command-layer package writing and directory-tree verification.
Delegated open in Pages uses the same private RTFD share-export evidence,
stages an RTFD package for Pages, requires `--allow-external-dispatch`, and
verifies application dispatch metadata, package tree hash, RTF member presence,
and private note readback.
Current text, folder create/rename/move/delete/sort/date-header toggle, note
move/copy/restore/purge/pin/unpin, and tag-membership mutations use the typed
`NotesShared`/`NotesUI` private writer. Folder reads include hierarchy and
state metadata such as parent ID/presence, depth, visible-note counts,
child-folder counts, folder capability flags, read-only
`customNoteSortTypeValue`, structured `ICFolderCustomNoteSortType` evidence,
and date-header state/type. Folder sort mutation is supported for editable concrete
folders that advertise custom sort support; folder date-header toggle is
supported for editable concrete folders that advertise date-header support.
Folder move supports explicit editable parents and selected account roots,
including cross-account parent/root placement with bounded descendant account
readback.
Default/query date-header type preferences are supported separately through
`settings group-by-date --scope default|query`.
Generated Notes framework link-stub failures stop the build instead of falling back to
AppleScript.

The final Notes command family must account for:

- accounts, folders, subfolders, folder reorganization, sort, pin, and broader Recently Deleted behavior
- note lifecycle reads and writes
- rich body structure, formatting, highlights, lists, checklists, tables,
  collapsible sections, and math-result surfaces where exposed
- links, attachments, PDFs, scans, markup metadata, and webpage previews
- tags and Smart Folders
- import, export, print, archive, and open in Pages surfaces
- locked-note and shared/collaboration boundaries
- scoped diagnostics such as `doctor`, `doctor store`, `doctor note`,
  `doctor folder`, `doctor account`, `doctor write-lab`, and
  `doctor rich-lab`

Candidate command families remain gated until private framework behavior,
safety policy, and verifier evidence are proven.

## Preservation Invariant

Commands that modify, move, copy, import, export, delete, restore, purge, or
reorganize notes must preserve known Notes state unless the user explicitly
requests a change to that state. This includes account/folder placement,
attachments, links, tags, rich text structure, checklists, tables, scans/PDFs,
archive metadata, pin/sort state, locked state, shared/collaboration state, and
timestamps where Notes.app preserves them.

Mutations should capture private framework readback and read-only store/index
evidence before the change, execute the private framework path, then verify the
final state. If a field cannot be preserved or verified, the command must
refuse, remain experimental, or document the unsupported boundary before
promotion.

Current text, folder-create/rename/move/delete, and tag-membership mutations use
`NotesMutationVerifier` after execution. The verifier reads the final folder
or note state through the current Notes read path, adds privacy-preserving
store-object evidence when available, and fails the command when required
post-write checks do not pass. Folder create verification checks name,
account, parent placement, and optional store evidence. Folder rename
verification checks identity preservation, name, account preservation, parent
preservation, and optional store evidence. Folder move verification checks
identity preservation, name preservation, target account, target parent or
account root, and optional store evidence. Folder delete verification checks visible folder
removal and optional store evidence. Tag membership
verification checks target tag presence or absence, title/folder/account
preservation, and preservation of non-target tags. Tag rename verification
checks affected-note identity preservation, old-tag removal, new-tag presence,
title/folder/account preservation, and preservation of non-target tags. This
verifier contract must be kept as richer private write implementations are
promoted.

## Doctor Diagnostics

`doctor` reports Notes app presence, implementation readiness, private framework
loadability, generated header/module availability, patched link-stub readiness
when applicable, class/method availability, private write-lab selector
availability, rich capability-lab candidate availability, group container
presence, and bounded store/index readiness. The current `notes_store` check is
read-only and reports store/index counts and file evidence without printing
note bodies.

Scoped diagnostics are added incrementally as verifier evidence matures:

- `doctor store --scope summary|schema|entities|indexes` is supported for
  store/index discovery, schema presence, entity counts, and bounded index
  status. It reads local evidence only and does not print note titles or bodies.
- `doctor note --id <note-id>` for identity resolution, private framework
  readback, and bounded store/index object evidence. It hashes identifiers,
  title/body-derived evidence, account/folder names, and reports counts and
  lengths rather than raw content.
- `doctor folder --folder <folder-id-or-name>` and
  `doctor account --account <account-id-or-name>` for account/folder
  availability, private readback, store entity matches, relationship counts,
  and bounded index evidence.
- `doctor write-lab` for required and optional private write selector
  availability. It is probe-only, reports `write_access: none`, and does not
  accept or execute a mutation.
- `doctor rich-lab` for links, attachments, tags, Smart Folders, body
  structure, accepted table and math-result insert/update paths, and
  archive/import/export private framework candidate availability. It is
  probe-only, reports accepted rich slices such as `body_structure`,
  `body_collapsible_list`, `body_collapsible_set`,
  `body_checklist_add`, `body_checklist_set`, `body_checklist_set_all`,
  `body_checklist_sort`, `body_checklist_convert`, `body_checklist_convert_range`,
  `body_checklist_reorder`, `body_checklist_indent`, and
  `body_checklist_delete` with
  `write_access: none`, reports table list/create/import/update/delete/convert-to-text plus
  math-result list/insert/update readiness in `accepted_capability`, and does
  not execute a rich mutation.

The mutation verifier covers folder create/rename/move/delete/purge plus note create/import/update/append/move/copy/restore/delete/purge/pin/unpin readback,
field preservation, folder placement/preservation, move/copy/restore destination checks,
existence/deletion checks, and optional store-object evidence. `folders create`
verifies folder name, account, parent placement, and optional store evidence.
`folders rename` verifies folder identity, target name, account preservation,
parent preservation, and optional store evidence. `folders move` verifies
folder identity, name preservation, target account, target parent or account
root, and optional store evidence. `folders delete` verifies that the folder no longer appears in
visible folder readback and includes optional store evidence. `folders purge`
verifies visible-folder absence plus purgable-folder absence for one
already-deleted purgable concrete folder and includes optional store evidence.
`move` verifies note identity preservation,
target folder/account, title/body preservation, and tag-set preservation. `copy`
verifies a new note identity, source preservation, target folder/account,
title/body preservation, and tag-set preservation. `restore` uses restore-only
include-deleted lookup, then verifies identity preservation, target
folder/account, title/body preservation, and tag-set preservation after the
note returns to the visible read path. `purge` uses restore-only
include-deleted lookup, then `ICNote.purgeNote:`, and verifies that the note is
absent from both visible and restorable readback. `pin` and `unpin` read the
current `ICNote.isPinned` state, call `ICNote.changePinStatusIfPossible` only
when the target state differs, and verify target pin state plus
identity/title/folder/account preservation. The current write lab covers
the required high-level text, folder create/rename/move/delete, note move/copy/restore/purge/pin, and delete write selectors
used by the private writer. The current rich lab shows required candidate
selectors are present for links, attachments, tags, Smart Folders, body
structure, and archive/import/export, while optional attachment/body property
evidence may be missing from the runtime method table. `tags list` is the first
promoted rich family read slice, and `tags search` is the promoted tag-scoped
note search read slice with summary-only output. `tags add`, `tags remove`,
`tags convert-to-text`, `tags rename`, and `tags delete` are promoted rich
family mutation slices. `tags convert-to-text` requires private body plaintext
hash readback before mutation and verifies body hash preservation plus target
tag absence.
`tags delete --tag` removes one visible tag; `tags delete --tags` removes at
least two explicit unique tags with hash-only batch evidence. Delete execution
requires `--allow-destructive-selection` and refuses when the private Smart
Folder cascade check reports that deleting a selected tag would delete Smart
Folders.
`attachments list` is the promoted attachment-family metadata read slice for
one selected note or a bounded visible-note collection. With `--id`, it keeps
the single-note selector surface used by export, rename, remove, Markup, PDF,
and audio commands. Without `--id`, it scans visible note summaries, optionally
under `--account` and/or `--folder`, reads each note's private attachment
metadata, filters deleted or trash attachments from the collection view,
optionally narrows the view by metadata-derived attachment family through
`--family`, and verifies collection counts, family counts, account/folder
selector dispatch, and category-filter application without reading note bodies,
attachment bytes, or local media paths.
`attachments search` is the promoted metadata-name search slice for the same
attachment surface. It accepts `--query` plus either a bounded visible-note
selection or one `--id` selector, optionally under `--account` and/or `--folder`
for bounded collection search, optionally applies the same `--family` category
filter, searches only metadata fields (title, media filename, content
identifier, type UTI, attachment type, and derived family), hashes the query in
JSON/verifier evidence, and verifies scanned-note/attachment counts,
account/folder selector dispatch, and searched-field accounting. It does not
call note body readers, read attachment bytes, inspect attachment file contents,
export attachments, or expose local media paths. Attachment content search
remains limited to separately promoted audio transcript search and embedded PDF
text search until another content-specific verifier is accepted.
`attachments audit` is the promoted batch attachment-family accounting slice:
it lists a bounded visible-note selection, optionally under `--account` and/or
`--folder`, reads each note's attachment
metadata through the typed private reader, classifies official Notes attachment
families such as photos/images, videos, PDFs, scanned documents,
drawings/sketches, audio recordings, webpage previews/maps, files, and unknown
attachments, and verifies account/folder selector dispatch, family counts,
extension/type bounds, raw UTI hash accounting, delegated workflow families,
and gated mutation families. It
does not read attachment bytes or print note titles, note bodies, attachment
titles, attachment filenames, raw UTIs, local media paths, transcripts, or
attachment bytes. `attachments workflow audit` is the selector-free, no-implementation
official attachment/media workflow accounting slice for the current Apple Notes
Add photos/PDFs/more, Manage PDFs/scans, Mark up attachments, and View
attachments guide pages. It reports 43 records: 23 supported, 18 delegated, 0
gated, and 2 rejected. Supported records point to accepted private-framework
attachment metadata, add, webpage/map preview, export, generated/fallback PDF,
rename, PDF text search, ordinary PDF crop/rotate/move/delete,
scan/image/drawing searchable-text search, existing recognized-text export,
scanned-document crop/rotation/filter/page move/delete, inline image-description
alt-text, direct image crop/rotate, and Markup model inspect/apply paths.
Delegated
records cover user-facing or system surfaces such as the Photos picker,
drag-and-drop, Continuity insert and scan capture, emoji/Genmoji input, Share sheet dispatch,
Attachments Browser UI, Quick Look, default-app open, attachment view-size and
PDF page-navigation UI, external attachment sharing, the interactive Markup
palette, Markup extension enablement, semantic Markup tool/style surfaces, and
Continuity annotate. Rejected records capture arbitrary PDF content edit as a
Notes product non-capability and Apple's Exchange Notes account-provider
attachment limitation. Generated recognized-text artifacts are supported separately by `attachments
recognized-text generate`, and hash-only image classification summary readback is
supported separately by `attachments image objects` outside those workflow records.
limitation for file, map, and webpage preview attachments. The audit rejects
note, attachment, file, and query selectors and makes no Notes implementation,
AppleScript, or `SQLiteReader` calls. `attachments add` is
the promoted attachment-family write slice: it adds one regular local file or a
bounded preflighted comma-separated `--files` batch to one editable visible
non-password-protected note through `ICNote.addAttachmentWithData:filename:`,
uses the ordinary mutation dry-run contract, and verifies attachment metadata
readback, filename preservation, exported byte count/SHA-256, per-attachment
verification, attachment-count/total-byte-count accounting, and note readback
without printing attachment bytes. `attachments copy` is the promoted
existing-attachment copy slice: it resolves one selected source attachment,
reads source bytes through the accepted private attachment export path, writes
those bytes to the target note through `ICNote.addAttachmentWithData:filename:`,
allows source and target to be the same note for explicit duplication, and
verifies byte count, SHA-256, new attachment metadata/export hash, target note
readback, and hash-only source/target evidence without printing raw bytes,
local media paths, or private identifiers. `attachments remove` is the promoted
single-attachment removal slice: it
removes one selected attachment from one editable visible non-password-protected
note through `ICAttachment.markForDeletion`, uses the ordinary mutation dry-run
contract, and verifies attachment metadata absence, attachment export absence,
and note readback without printing attachment bytes. `attachments export` is
the first promoted attachment-family artifact slice: it exports one selected
attachment's raw data through `ICMedia`, requires `--allow-artifact-action`,
refuses existing destinations, and verifies destination existence, byte count,
SHA-256, and attachment metadata readback without printing source local media
paths.
`attachments export-pdf` is the promoted PDF/scan attachment artifact slice:
it exports one selected PDF, scanned-document, or paper attachment to a `.pdf`
artifact by reading existing PDF media bytes, private fallback PDF data, or
generating a PDF through the private NotesUI document-camera PDF generator,
requires `--allow-artifact-action`, refuses existing destinations, and verifies
destination existence, byte count, SHA-256, PDF header, and attachment metadata
readback without printing attachment bytes or source local media paths.
`attachments pdf inspect` and `attachments scan inspect` are the promoted
PDF/scan private metadata readback slice: they read one selected attachment,
derive PDF byte count/SHA-256/page count and source-kind evidence when PDF data
is exposed, and hash private scan metadata such as orientation, image filter
type, cropping-quad, scanned-document metadata, and document-camera PDF version evidence without
printing crop geometry, page images, PDF text, attachment bytes, or local media
paths. `scan inspect` requires scanned-document evidence; `pdf inspect` accepts
PDF or scanned-document attachments. This readback supports crop, ordinary PDF
crop, page rotation/order/delete, and scanned-document page-order verifier work;
selected scanned-document crop, rotation, filter, page move, and page delete are supported separately by
`attachments scan crop`, `attachments scan rotate`, `attachments scan filter`,
`attachments scan page move`, and `attachments scan page delete`; ordinary PDF
crop/rotate/move/delete is supported separately by `attachments pdf crop`,
`attachments pdf page rotate`, `attachments pdf page move`, and
`attachments pdf page delete`.
`attachments pdf search` is the promoted PDF text-search slice: it scans one
selected note or a bounded account/folder visible-note selection, filters
visible PDF and scanned-document attachments, reads PDF bytes through the same
private PDF media/fallback/generated path, extracts embedded text through
PDFKit, and returns only query hashes, PDF/text byte counts, SHA-256 evidence,
page counts, match counts, source kind, note/attachment metadata, and verifier
evidence. It does not print PDF text, scan image data, attachment bytes, local
media paths, or raw queries, and it does not perform OCR for image-only scans.
`attachments scan search`, `attachments image search`, and
`attachments drawing search` are promoted existing searchable/indexable text
readback slices for scan, image, drawing, and handwriting-adjacent content.
They validate query and selector shape, keep `--id` mutually exclusive with
account/folder collection selectors, scan a bounded visible-note selection or
one selected note, filter to the selected attachment family, read
`ICAttachment.searchableTextContent*` and `ICAttachment.attachmentModel`
searchable/indexable text paths, and return only query hashes, content source
kinds, content byte counts/SHA-256, match counts, note/attachment metadata, and
verifier evidence. They do not read or print scan images, image pixels, drawing
bytes, handwriting strokes, raw recognized text, note bodies, raw queries, or
local media paths. `attachments recognized-text export` can export existing
private searchable/recognized text from one selected scanned-document, image,
or drawing attachment to an explicit `.txt` artifact with
`--allow-artifact-action` and fresh private readback hash verification. The same
private searchable-text readback participates in the supported
`notes search attachment-content` composite; `attachments recognized-text
generate` can create a separate recognized-text `.txt` artifact from private
attachment media/PDF bytes. `attachments recognized-text index` supports selected-attachment search indexing through the private CoreSpotlight reindexer. `attachments image objects` supports hash-only private `ICAttachment.imageClassificationSummary` readback.
`attachments markup inspect` is the promoted Markup model read/artifact slice:
it reads one selected attachment's media bytes through the private attachment
reader, derives Markup model data with
`ICMarkupUtilities.markupModelDataFromData:`, reports only presence, byte count,
SHA-256, source kind, and verifier evidence, and can export the Markup model
bytes to an explicit artifact with `--allow-artifact-action`.
`attachments markup edit` is the promoted Markup model apply slice: it accepts
one user-provided Markup model file for a selected PDF, scanned-document, or
image attachment, applies it through `ICMarkupUtilities.applyMarkupModelData`,
and verifies the result by reading back attachment metadata plus the Markup
model byte count and SHA-256 through `attachments markup inspect`. It does not
claim Notes UI crop/filter/PDF-rotation, shape, signature, style/color,
Continuity annotate, URL-return embed/extract, or arbitrary PDF/scan/image
byte-edit semantics; those Markup tool surfaces are delegated rather than
modeled as stable Notes data-layer writers. `attachments
image description get/set` is the promoted Apple Markup Image Description slice:
it reads or sets `ICInlineAttachment.altText` on one selected inline
image-family attachment, verifies private readback, and reports only description
byte counts and hashes. It does not perform OCR or broader semantic Markup editing; image classification
summary readback is supported separately by `attachments image objects`. `attachments image crop` and `attachments image
rotate` are promoted direct-media image transform commands: they require one
selected photo/image attachment on an editable visible non-password-protected
note, read private media bytes, crop or quarter-turn rotate with
ImageIO/CoreGraphics, write the result back through `ICMedia.writeData`, and
verify byte-count plus SHA-256 delta readback without printing image pixels,
attachment bytes, crop geometry, local media paths, or raw private objects.
`attachments markup add-shape`, `add-text`,
`add-signature`, `highlight`, `sketch`, `draw`, `shape-style`, `border-color`,
`fill-color`, and `text-style` return explicit delegated Markup tool-palette
metadata. `attachments markup annotate` is delegated to Continuity Markup
nearby-device UI.
`attachments audio rename`, `attachments audio save`, and `attachments audio
delete` are the promoted existing-audio attachment operation slice: they reuse
the accepted private attachment title, media export, and removal paths, but
require the selected attachment to read back as `audio_recording`. Rename
verifies title readback, save writes the selected audio bytes only to an
explicit artifact with `--allow-artifact-action` and verifies byte count plus
SHA-256, and delete verifies attachment metadata/export absence. Command JSON
does not print audio bytes, transcripts, or source local media paths.
`attachments audio edit` accounts for Apple's append-to-recording workflow as a
delegated Notes.app recording UI surface. `attachments audio edit-transcript`
is rejected as a non-capability because the current Apple Notes audio guide
supports viewing, searching, and copying transcript text, not editing it.
`attachments add-webpage` and `attachments update-webpage` are the promoted
webpage-preview/map mutation slice: they create or update one `http`/`https`
URL `ICInlineAttachment` through private Notes URL attachment APIs and private
save paths, select updates by attachment identity from `attachments list`, and
verify link metadata readback, webpage-preview attachment metadata readback,
attachment-family preservation, URL replacement, and note readback without
printing note bodies or raw private tokens. Raw page snapshot generation
controls, preview image refresh controls, and non-webpage attachment transforms
remain gated separately. Scan capture is delegated to the Continuity Camera /
nearby-device capture surface rather than modeled as a direct Notes private
data write.
`export audit` is the promoted read-only export-family accounting slice: it
resolves one selected note and private note-state evidence, reports hash-only
note/title identity, classifies accepted PDF, Markdown single-file/package,
HTML single-file/package, RTF, RTFD, delegated print, and delegated Pages
handoff records, and accounts for accepted package resource preservation as
supported, general locked-note export beyond the session-unlocked `.txt`
artifact slice as gated, and unbounded perfect conversion fidelity as rejected
because the current Apple guide does not promise that contract. It
does not invoke artifact exporters, write files, submit external dispatch, or
print note bodies, titles, folder names, account names, or local paths.
`export pdf` is the first promoted note-level export artifact slice: it
generates a PDF for one visible non-password-protected note through
`NotesEditor.ICMPrintController`, requires `--allow-artifact-action`, refuses
existing `.pdf` destinations, and verifies destination existence, byte count,
SHA-256, PDF header, and note readback.
`print` is the delegated print slice over the same private PDF generator: it
resolves one visible non-password-protected note, validates the named system
printer, produces PDF bytes through the private Notes path, requires
`--allow-external-dispatch` for execution, submits those bytes to the system
print service, and verifies PDF header, byte count, SHA-256, selected printer,
job ID, and note readback.
`import text` is the promoted official TXT import slice: it reads one local
UTF-8 `.txt` file, builds a semantic note draft with optional explicit title,
records source path/name/byte count/SHA-256 in dry-run output without printing
the imported body, creates the note through the accepted private note creation
path, and verifies note readback.
`import markdown` is the promoted Markdown semantic import slice: it reads one
bounded UTF-8 `.md` or `.markdown` file, optionally imports local relative
inline Markdown image resources when `--include-attachments` is explicit for a
regular Markdown file, or reads one strict Markdown resource package when
`--include-attachments` is explicit for a package path. It records source
byte/hash, semantic count, and package/resource evidence without printing
imported body text or resource bytes, converts the Markdown through
`NotesUI.ICMarkdownRepresentation` with a Foundation Markdown fallback, writes
the attributed body through typed private `ICNote.textStorage`, verifies
private note and body-structure readback plus semantic heading/list accounting
when present, and imports accepted single-file or package resources through the
accepted private attachment writer.
`import rtf`, `import rtfd`, and `import html` are the promoted rich import
slices: the command layer reads one bounded local `.rtf`, `.html`, `.htm`, or
`.rtfd` package source, or one strict `.htmlpkg`/`.htmlpackage` package when
`--include-attachments` is explicit, records source byte/hash evidence and
path/name hashes without printing source paths, file names, source body text,
package resource bytes, or imported note body, converts the rich body source to
`NSAttributedString`, writes it through typed private `ICNote.textStorage` and
private save paths, imports HTML package `Resources/` members through the
accepted private attachment writer, and verifies note readback, title/folder
preservation, nonempty rich text, body-structure readback, format-family
accounting, privacy redaction, RTFD/HTML package file/resource counts plus
package tree SHA-256, and HTML package attachment export hashes. ENEX
note/normalized-tag/resource attachment import with inline body-position placement and
Markdown semantic import are supported separately by `import enex` and
`import markdown`.
`replace markdown`, `replace html`, `replace rtf`, and `replace rtfd` are the
promoted rich in-place replacement slices for content reorganization work: the
command layer reads one external rich source, resolves one existing visible
editable note, preserves the selected note identity, folder, account, pin and
shared metadata, optionally updates the title, converts the source through the
same private Markdown/rich conversion helpers used by import, and replaces the
note body through `ICNote.textStorage` and the private save path. Markdown and
HTML local package resources are matched to stable markers before conversion,
then inserted at body positions through `ICAttachmentInsertionController` after
marker removal; remote URLs remain links. RTFD relies on the attributed
attachment runs produced by the rich conversion path. Verification checks note
readback, imported text hash/count evidence, attributed and attachment run
counts, resource count, inline reference/placement counts, attachment export
hashes, marker absence, and privacy redaction. Locked, password-protected,
trash, deleted, non-editable, and shared read-only notes remain gated.
`import enex` is the promoted ENEX note/normalized-tag/resource attachment and inline
body-position placement import slice: the
command layer bounded-parses one `.enex` XML source, records source path/name
hashes, byte count, note count, tag count, normalized tag count, resource count,
and resource byte count without printing local paths, file names, ENEX body text,
resource bytes, or imported note bodies, parses inline `<en-media>` references,
matches each reference to one decoded resource by ENEX resource MD5, normalizes
whitespace-bearing tags to single-word Notes tag text, refuses unmatched inline
media references before mutation, writes each accepted note through typed private
`ICNote.textStorage`, applies normalized tags
through private `ICHashtag` membership APIs, imports decoded base64 resources
through private `ICNote.addAttachmentWithData:filename:`, records per-resource
inline reference counts, and verifies note readback, title/folder/normalized-tag
membership, inline reference match counts, attachment metadata/export hashes,
optional date preservation, imported note count, body-position inline
attachment readback, tag normalization accounting, and privacy redaction.
`import folder` is the promoted folder-preserve import slice: the command layer
preflights one bounded source directory tree, creates one import-root folder
under the selected editable parent folder, recreates supported subdirectories
under that root, imports supported TXT, Markdown, Markdown package, RTF, RTFD,
HTML, and ENEX files through their accepted private-framework-backed import
paths, and verifies root/subfolder creation, per-file import readback,
aggregate imported-note/resource counts, and privacy redaction. Execution
requires `--allow-destructive-selection`; dry-run and execution output use
source tree hashes, path/name hashes, counts, and verifier evidence rather than
printing local paths, file names, source bodies, resource bytes, or imported
note bodies.
`import audit` is the promoted read-only import-family accounting slice: it
scans one file or bounded directory tree, classifies TXT, Markdown, Markdown
package, RTF, RTFD, HTML, ENEX, folder-preserve, and unsupported families,
verifies that accepted TXT/Markdown/RTF/RTFD/HTML/ENEX note-normalized-tag-resource
import families, supported ENEX normalized-tag accounting, supported ENEX inline
resource reference accounting, and supported directory-tree import are
accounted for without printing local paths/file names beyond extensions and
hashes. ENEX audit may bounded-parse `.enex` metadata to
classify supported, supported-normalized-tag, or parse-gated ENEX sources without
creating notes or printing imported content.
`export markdown` is the promoted Markdown export slice aligned with Apple's
current Notes import/export guide: it converts one visible note through typed
`NotesUI.ICMarkdownRepresentation` with `ICMarkdownString` fallback, including
password-protected notes already unlocked in the current Notes session. It
requires `--allow-artifact-action`, refuses existing destinations, keeps
protected-note title/body out of JSON/stdout, and verifies either a
`.md`/`.markdown` single-file artifact or an explicit
`.mdpkg`/`.markdownpackage` attachment-resource package. Package verification
checks directory existence, file count, total byte count, tree SHA-256,
Markdown member, attachment resource count, attachment policy, protected-state
boundary, and note readback.
`export html` is the promoted HTML export slice: by default it uses
`ICNote.htmlStringWithAttachments(false)` for one visible note only when the
private attachment collection is empty and writes a single `.html` artifact;
with `--include-attachments`, it uses
`ICNote.htmlStringWithAttachments(true)`, reads exportable attachment resources
through private media APIs, and writes an explicit `.htmlpkg`/`.htmlpackage`
package. Password-protected notes are accepted only when already unlocked in
the current Notes session. It requires `--allow-artifact-action`, refuses
existing destinations, suppresses protected-note title/body in JSON/stdout, and
verifies file byte count/SHA-256/HTML marker or package file count/total byte
count/tree SHA-256/HTML member/resource count, attachment-policy preservation,
protected-state boundary, and note readback. Accepted package resource
preservation is supported through HTML package verification, while unbounded
perfect conversion fidelity is rejected by `export audit` as a non-current-guide
guarantee.
`export rtf` is the promoted single-file RTF slice over the private share
exporter: it expands the same `NotesUI.ICShareNoteExporter` file-wrapper
output used by RTFD export, extracts exactly one RTF member only when the
package has no other resources, requires `--allow-artifact-action`, refuses
existing `.rtf` destinations, and verifies destination existence, byte count,
SHA-256, RTF header, protected-state boundary, and note readback. It accepts
password-protected notes only when already unlocked in the current Notes
session and suppresses protected-note title/body in JSON/stdout. Notes that
would require package resources are refused with guidance to use `export rtfd`.
`export rtfd` is the first promoted rich note package export slice: it expands
`NotesUI.ICShareNoteExporter` file-wrapper output for one visible note,
including password-protected notes already unlocked in the current Notes
session. It requires `--allow-artifact-action`, refuses existing `.rtfd`
destinations, suppresses protected-note title/body in JSON/stdout, and verifies
directory existence, file count, total byte count, tree SHA-256, RTF member
presence, protected-state boundary, and note readback.
`open-in-pages` is the promoted delegated Pages handoff slice: it derives a
staged RTFD package through the same private RTFD share exporter, requires
`--allow-external-dispatch`, dispatches the package to Pages, and verifies the
application name, staged path hash, file count, total byte count, tree SHA-256,
RTF member presence, and note readback without printing staged local paths or
package bytes.
`links audit` is the no-implementation official Links workflow accounting slice for
the current Apple "Add links in Notes on Mac" guide page. It reports semantic
private-framework link reads/writes as supported, Notes.app/macOS menu,
shortcut, Smart Links, active-app capture, Quick Note thumbnail, link-color,
and legacy OS compatibility surfaces as delegated, selected-text web/app/file
URL link conversion as supported, and explicit note-link display-text/title-sync
semantics as supported through hash-only display-text readback.
The audit requires no note/link selector, makes no Notes implementation,
AppleScript, or `SQLiteReader` calls, and verifies the count/status families
with `notes_read_v1` capability-accounting evidence.
`links list` is the first promoted link-family metadata read slice.
`links backlinks` is the promoted link-family backlink read slice: it calls
`ICInlineAttachment.enumerateLinksToNote:batchSize:visibleOnly:saveAfterBatch:context:usingBlock:`
and reports source note summaries plus privacy-safe link metadata without
printing note bodies or raw internal tokens. `links add`, `links update`, and
`links remove` are the promoted web URL link write slices:
add creates one `http` or `https` URL on one editable visible
non-password-protected note through `ICNote.addURLAttachmentWithURL:`, update
changes one selected web URL inline link through
`ICInlineAttachment.tokenContentIdentifier`,
`ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate`, and remove deletes one selected
web URL inline link through `ICInlineAttachment.markForDeletion`. `links add-app`,
`links update-app`, and `links remove-app` are the promoted app URL link write
slices: add creates one non-web, non-file app URL link while hiding the raw app
URL behind hashes, update changes one selected app URL inline link through
`ICInlineAttachment.tokenContentIdentifier`,
`ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate` without printing the raw app URL,
and remove deletes one selected app URL inline link through
`ICInlineAttachment.markForDeletion`. `links add-file`, `links update-file`,
and `links remove-file` are the promoted file URL link write slices: add creates
one regular local file or directory URL link through
`ICNote.addURLAttachmentWithURL:` while hiding the raw local path and file URL
behind hashes, update changes one selected file URL inline link through
`ICInlineAttachment.tokenContentIdentifier`,
`ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate` without printing the raw local
path or file URL, and remove deletes one selected file URL inline link through
`ICInlineAttachment.markForDeletion`.
`links add`, `links add-app`, and `links add-file` also support selected-text
conversion mode with `--paragraph` or `--ordinal`, `--text`, and optional
`--occurrence`: the writer creates an `ICInlineAttachment` through
`ICInlineAttachment.newLinkAttachmentWithURL:name:currentNote:`, replaces the
selected `ICNote.textStorage` range with an `ICInlineTextAttachment`, and
verifies link metadata plus selected-text display hash readback while command
JSON exposes only selected-text byte count/SHA-256 and paragraph/occurrence
evidence.
`links add-note`, `links update-note`,
and `links remove-note` are the promoted note-to-note write slices: add creates
one internal note link from an editable visible source note to a visible
non-password-protected target note through
`ICInlineAttachment.newLinkAttachmentToNote:fromNote:parentAttachment:`, update
retargets one selected ordinary note-to-note inline link in place through
`ICInlineAttachment.changeLinkDestinationFromNote:toNote:`, and
remove deletes one selected ordinary note-to-note inline link through
`ICInlineAttachment.markForDeletion`. `links add-paragraph`,
`links update-paragraph`, and `links remove-paragraph` are the promoted
paragraph note-link write slices: add resolves target paragraph anchors from
privacy-safe `body structure` anchor hashes, then calls
`ICInlineAttachment.newLinkAttachmentToNote:paragraphID:paragraphName:fromNote:parentAttachment:`,
update retargets one selected paragraph/internal paragraph inline link through
`ICAppURLUtilities.appURLForNote:paragraphID:`,
`ICInlineAttachment.changeLinkDestinationFromNote:toNote:`,
`ICInlineAttachment.tokenContentIdentifier`,
`ICInlineAttachment.altText`, and
`ICInlineAttachment.markDisplayTextNeedsUpdate`, while remove deletes one
selected paragraph/internal paragraph inline link through
`ICInlineAttachment.markForDeletion`.
These commands use the ordinary mutation dry-run contract and verify link
metadata readback or absence plus note readback; web URL update also verifies
selected-link identity, new URL hash, and old URL replacement; file URL update
also verifies selected-link identity, file URL hash, raw local file URL absence,
source-kind evidence, and old URL replacement; note-link add
also verifies target readback and target identity, note-link update verifies
selected-link identity preservation, target readback, target identity, target
backlink readback, and old-target backlink absence, paragraph add verifies
target paragraph identity, paragraph update verifies selected-link identity
preservation, target paragraph identity, target token replacement, target
backlink readback, and old-target backlink absence when the target note changes,
and app-link/file-link/note-link/paragraph-link remove verify selected-link
identity. App URL update also verifies selected-link identity, app URL hash,
raw app URL absence, and old URL replacement. `links resolve` is the promoted
privacy-safe link destination read slice: it resolves one selected link through
private link metadata and `ICAppURLUtilities`, reports public web URLs directly,
reports app/file URLs as scheme/hash evidence, and reports note/paragraph
destinations through target note and paragraph hashes without printing raw
internal tokens, paragraph UUIDs, paragraph titles, note bodies, or local paths.
Generic link mutation beyond the accepted web/app/file/note/paragraph commands
and raw internal-token output remain gated.
`smart-folders list` is the promoted Smart Folder metadata read slice; it
reports descriptions, editable state, visible-note counts, query length/hash
evidence, and privacy-safe criteria summaries without printing raw criteria
JSON, raw filter values, tag names, folder identifiers, participant
identifiers, or private class names. `smart-folders criteria` is the promoted
single Smart Folder criteria resolution read slice; it resolves one visible
Smart Folder, returns privacy-safe criteria summaries plus bounded matching-note
readback, and verifies query/criteria identity without printing raw criteria
JSON, raw filter values, raw tag names, note bodies, folder identifiers inside
criteria, or private class names. `smart-folders explain` is the promoted
privacy-safe criteria explanation slice; it reuses criteria readback to report
query kind, filter count, multi-condition status, supported read families, and
gated mutation families without printing raw criteria internals or note bodies.
`smart-folders audit` is the promoted batch Smart Folder criteria-family
accounting slice; it lists visible Smart Folders, aggregates query/criteria
summary counts, filter-kind counts, raw-value hash accounting, supported read
families, and gated mutation families without fetching matching notes or
printing raw criteria internals.
`smart-folders filters audit` is the selector-free filter catalog accounting
slice; it reports the accepted private Smart Folder filter/value-shape catalog
plus rejected private-catalog residuals without reading notes, Smart Folders, AppleScript, or
`SQLiteReader` evidence. Supported records cover the current single/multi-tag
All-selected-tags,
Untagged Notes Only, pinned/shared/folder/locked/Quick Note, attachment,
checklist, created/edited date, selected participant/mention, and special
note-kind criteria writer catalog. Rejected records explicitly account for
unsupported tag operator/mode semantics, missing private tag hints,
participant/mention identity comparison without private hash
evidence, raw-value or object-bound filters without semantic readback, and
unreviewed OS-specific filter types because they are not current Apple Notes
guide capabilities. `smart-folders filters add`,
`smart-folders filters update`, and `smart-folders filters remove` are accepted
for promoted private filter-selection criteria by reconstructing the current
private filter list, rewriting the full criteria, and verifying the ordinal
delta plus matching-note readback. Runtime mutation still refuses
tag-selection/raw/object-bound criteria that cannot be reconstructed from
privacy-safe private readback before writing.
`smart-folders workflow audit` is the selector-free, no-implementation official Use
Smart Folders workflow accounting slice. It accounts for Apple's create,
convert, edit, and delete Smart Folder guide sections as supported,
delegated, gated, or rejected without reading Smart Folders or notes. Supported
records point to accepted private Smart Folder metadata, criteria, matching
notes, promoted criteria construction/update, rename, delete, and folder
conversion commands plus promoted per-filter add/update/remove and filter
catalog accounting.
Delegated records cover Notes.app menu/contextual/sidebar UI routes. Gated
records are empty for the current official Smart Folder workflow audit; residual
private filter value-shape catalog records are rejected by
`smart-folders filters audit`. Folder conversion is
supported by `smart-folders convert-folder`, which tags source-folder notes
with the folder name, moves them to the account default Notes folder, creates a
matching Smart Folder, removes the source folder, and verifies source-folder
absence plus note move/tag readback. Untagged Notes Only is supported through
`ICTagSelection.mode` 2, selected-tag count readback, and matching-note
verification; Any/OR multi-rule scope is supported through
`ICFilterSelection.joinOperator` readback. Rejected
records capture Apple's Smart Folder product limits: no locking, no subfolder
nesting, no sharing, no ineligible folder conversion, and no empty-filter Smart
Folders. The audit rejects selectors and makes no Notes implementation, AppleScript,
or `SQLiteReader` calls.
`smart-folders notes` is the promoted
matching-note summary read slice; it resolves one visible Smart Folder and
returns visible note summaries, returned-note count, and visible-note count
without printing note bodies or raw criteria internals. `smart-folders
reasoning` is the promoted per-note membership evidence slice; it resolves one
visible Smart Folder, returns one record per returned matching note, reports
criteria families, emits partial per-filter state, body-structure count, and
attachment-family metadata evidence for filters that can be proven from private
note state, body structure, or attachment metadata, and verifies
membership through private Smart Folder readback without printing note bodies,
raw criteria JSON, raw filter values, raw tag names, participant identifiers,
or private class names. Pinned, shared, locked, attachment, checklist, math,
call, and system-paper filters can report boolean or count readback.
Attachment criteria can report generic/no-attachment, photo/video, scan,
drawing, map preview, webpage preview, audio, and document family counts from
attachment metadata. Checklist criteria can report total, open, done, and no-checklist
counts from body structure. Accepted folder/not-folder criteria can report
target folder-count metadata and per-note folder-object hash comparison
without printing raw criteria folder identifiers. Created/edited date criteria
can report per-note date-source presence, known relative selections such as
today, yesterday, last 7 days, last 30 days, last 3 months, and last 12 months
can report selection readback, and explicit on/before/after/between/relative
criteria can report semantic date-parameter comparison without printing raw
date criteria values. Tag criteria can report selected-tag count, per-note tag
count, single included-tag positive hash matches, and default-operator
included/excluded tag-set hash matches when private criteria hints and note tag
metadata align. Participant filters can report participant-count readback from
note state and selected participant identity hash matches when criteria hashes
and note-state participant hashes align. Mention filters can report mention
attachment-count readback from body structure and selected mentioned-participant
hash matches when criteria hashes and mention attachment hashes align, without
printing participant identifiers or mention text.
`smart-folders create-criteria` and `smart-folders update-criteria` can also
construct selected participant and selected mention criteria from an explicit
opaque `--participant-user-id`, using private participant/mention filter
selection objects and hashing the user ID in all command and verifier output.
Participant/mention identity comparison remains gated when private hash
evidence is unavailable, and broader mention object-bound comparison,
object-bound criteria beyond accepted folder/not-folder and accepted tag-set
hints, raw-value comparison without semantic readback, unsupported operator/mode
tag comparison, missing-hint tag comparison, and arbitrary/full multi-condition comparison beyond supported-filter trace remain gated per
filter. `smart-folders create` is promoted for one or more existing visible tags
in one account; it creates a private `ICTagSelection` query with explicit
All/Any tag-selection operator readback and verifies account, query presence,
selected tag count, matching-note count, and visible-note count when available.
`smart-folders update` is promoted for replacing one editable Smart Folder's
criteria with one or more existing visible tags in the same account; it uses
`ICTagSelection`, All/Any tag-selection operator readback,
`ICQuery.queryForNotes(matchingTagSelection:)`, and writable
`ICFolder.smartFolderQuery`, then verifies identity, name/account
preservation, tag-selection criteria, selected tag count, matching-note count,
and visible-note count when available.
`smart-folders create-criteria` and `smart-folders update-criteria` are
promoted for the current typed built-in, folder-object, parameterized date,
participant/mention, and combined private filter-selection/query-factory
criteria builder boundary:
`pinned`, `unpinned`, `shared`, `not-shared`, `folder`, `not-folder`, `math`, `call`,
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
`edited-relative`, `participants`, and `mentions`. They use
`ICQuery.query(forPinnedNotes:allowsRecentlyDeleted:)`,
`ICQuery.query(forSharedNotes:allowsRecentlyDeleted:)`,
`ICQuery.query(forMathNotesAllowsRecentlyDeleted:)`,
`ICQuery.query(forCallNotesAllowsRecentlyDeleted:)`,
`ICQuery.query(forSystemPaperNotesAllowsRecentlyDeleted:)`, or
`ICQuery.queryForRecentlyDeletedMathNotes()` for single query-factory criteria
and typed `ICLockedNotesFilterTypeSelection`,
`ICQuickNotesFilterTypeSelection`, `ICAttachmentsFilterTypeSelection`,
`ICChecklistsFilterTypeSelection`, `ICFoldersFilterTypeSelection`,
`ICDateCreatedFilterTypeSelection`, `ICDateEditedFilterTypeSelection`,
`ICParticipantsFilterTypeSelection`, or `ICMentionsFilterTypeSelection` inside
a single or combined `ICFilterSelection` query for locked, Quick Note,
attachment, checklist, folder, date, participant, and mention criteria.
Comma-separated criteria are supported when every selected kind can be
represented by a private filter selection; the writer extracts typed selections
from promoted filter-selection paths and from the `math`, `call`,
`system-paper`, and `recently-deleted-math` query-factory paths before
combining them with `ICFilterSelection`. `recently-deleted-math` combinations
preserve the dedicated criterion's effective recently deleted scope; the
explicit `--include-recently-deleted` flag remains rejected for that criterion
because it already selects recently deleted math notes. Single `folder` or
`not-folder` criteria use
`--criteria-folder FOLDER[,FOLDER...]`; combined `folder,not-folder` criteria
use `--include-criteria-folder` and `--exclude-criteria-folder` so each filter
has its own concrete visible same-account folder set. The private writer stores
all selected object identifiers for each folder filter in
`ICFoldersFilterTypeSelection.folderIdentifiers`.
Parameterized date criteria use `--date` for on/before/after, `--start-date`
plus `--end-date` for between, and `--relative-amount` plus `--relative-unit`
for relative ranges. Create uses `ICFolder.smartFolder(withQuery:titleComponents:account:)`;
update assigns writable `ICFolder.smartFolderQuery`. Both verify query presence,
criteria readback, criteria kind-list and filter-count readback for combined
criteria, attachment/checklist/date `selectionType` evidence,
folder selection count and inclusion evidence, date primary/secondary or
relative-range evidence where applicable, participant/mention selected-user
count evidence, matching-note count, and identity/account preservation for
updates without printing raw criteria JSON, raw predicate text, raw filter
values, note bodies, raw criteria folder identifiers, participant identifiers,
or private class names.
`smart-folders duplicate` and `smart-folders copy-criteria` are promoted for
criteria reuse without printing raw criteria JSON. They reuse an existing
visible source Smart Folder's typed private `ICFolder.smartFolderQuery` to
create a new Smart Folder or replace one editable same-account target Smart
Folder's criteria, then verify source/target identity boundaries, source query
presence, query kind, filter count, predicate hash when available, tag-selection
count when available, matching-note count, and visible-note count when
available without printing raw criteria JSON, raw filter values, raw tag names,
note bodies, or private class names.
`smart-folders export-criteria` is promoted for raw criteria artifact export:
it reads one visible Smart Folder's `ICFolder.smartFolderQueryJSON`, writes only
to a user-selected `.json` destination with `--allow-artifact-action`, and
verifies file existence, byte count, SHA-256, JSON readability, and Smart Folder
readback. `smart-folders import-criteria` is promoted for replacing one editable
Smart Folder's criteria from a `.json` artifact through writable
`ICFolder.smartFolderQueryJSON`; it validates UTF-8 JSON, verifies imported
query hash/length, Smart Folder identity/name/account preservation, criteria
summary readback, and matching-note readback.
`smart-folders rename` is promoted for one editable Smart Folder selected by
`--folder` plus optional `--account`; it uses typed private `ICFolder` title
mutation and verifies identity, account, query, and visible-note count
preservation when available. `smart-folders delete` is promoted for one
editable Smart Folder selected by `--folder` plus optional `--account`; it uses
private `ICFolder` deletion and verifies the Smart Folder is absent from
visible Smart Folder readback without deleting matching notes.
`smart-folders convert-folder` is promoted for one eligible concrete folder
selected by `--folder` plus optional `--account`; it uses private
`ICFolder.visibleNotesInFolder`, `ICNote.primitiveFolder`, `ICHashtag`,
`ICTagSelection`, `ICQuery`, `ICFolder.smartFolder(withQuery:)`, and
`ICFolder.markForDeletion` to implement Apple's irreversible conversion
semantics. It requires `--allow-destructive-selection` plus
`--allow-persistent-action` for execution, refuses shared/locked/read-only/
deleted/default/system/trash/Smart Folder/subfolder-containing targets, and
verifies source-folder absence, matching Smart Folder creation, target-folder
note placement, tag readback, and note ID hashes without printing note bodies.
`smart-folders reasoning` can also report privacy-safe tag-selection and tag
filter evidence from per-note private tag metadata: selected-tag count,
per-note tag count, single included-tag positive hash matches, and
default-operator included/excluded tag-set hash matches are recorded without
printing raw tag names or tag identifiers. Non-default tag operator comparison
and tag selection without private criteria hints remain gated.
Arbitrary user-editable Smart Folder criteria construction beyond promoted
private filter-selection/query-factory combinations,
participant/mention identity comparison when private hash evidence is
unavailable, broader mention object-bound criteria, and object-bound criteria beyond the
accepted tag, accepted folder/not-folder, and promoted criteria, richer shared-state criteria beyond the accepted
shared/not-shared built-ins, raw-value comparison without semantic readback, tag
identifier/object-bound filter comparison beyond accepted folder/not-folder and
accepted tag-set hints, and arbitrary/full multi-condition boolean tracing beyond
supported-filter trace remain gated until they have typed private query construction
and verifier proof.
`body structure` is the first promoted rich body read slice; it reports body
hash/length, paragraph-style runs, privacy-safe paragraph anchor hashes,
paragraph style/alignment names, inline format run counts, bold/italic/
underline/strikethrough/font run counts, foreground/highlight run counts,
privacy-safe color/font-hash counts, checklist indentation levels,
checklist/table/math/link/attachment counts, and rich-state flags without
printing note bodies, titles, raw paragraph UUIDs, paragraph titles, raw
attributed content, raw paragraph style data, raw colors, raw font objects, or
private color/font objects. `body surfaces` is the promoted special-surface
accounting slice: it reports table, math-result, collapsible-section, and
collapsed-section counts plus supported/gated read and mutation families,
verifies the accounting through private body structure readback, reports
  privacy-safe table selector listing, table create, collapsible-section
  create/update, state mutation, single-cell table update, table delete,
  table convert-to-text, table convert-from-text, table copy, table move, table row/column insert/delete/move/copy/clear, math-result selector listing, math-result
insertion, and existing math-result update as supported.
`body format audit` accounts for the current Apple Format Notes, Add Lists,
and Add a Table guide workflows without requiring a note selector or calling
the Notes implementation. It reports accepted inline emphasis/color/highlight/font,
paragraph style including Monostyled/alignment/default-style, collapsible-section, ordinary-list,
checklist including list-ending body paragraph insertion, table structure, whole-table movement, row/column formatting, selected ordinary
text-to-table workflows, and external table import conversion as supported; Touch Bar, menu/keyboard
UI, table navigation/selection, and typing suggestions as delegated app/system
surfaces. No formatting workflow record remains gated in this target audit.
`body table list` reads inline table attachment records through the private
attributed-body table surface and returns table ordinals, hashed identities,
optional row/column counts, and deletion capability evidence without table
cell text. `body table update` replaces one selected cell by table ordinal,
row, and column through `ICTable.setAttributedString:columnIndex:rowIndex:`
and verifies the selected table identity, selected cell hash, table counts, and
  inline attachment counts without printing table cell text. `body table delete`
  removes one selected table through `ICNote.removeInlineAttachmentsObject:` and
  verifies table selector and body structure deltas without printing table cell
  text. `body table convert-to-text` replaces one selected table attachment in
  `ICNote.textStorage` with tab/newline-delimited plain text built from
  `ICTable.stringForColumnIndex:rowIndex:`, then verifies selected-table
  disappearance, table/inline attachment deltas, converted-text hash readback,
  and privacy redaction without printing table cell text. `body table convert-from-text`
  replaces one selected ordinary body paragraph with a Notes table attachment
  through `ICNote.addTableAttachmentWithText:` plus `ICNote.textStorage`, then
  verifies source paragraph removal, table/inline attachment deltas, source text
  hash, per-cell hash readback, and privacy redaction without printing source
  text or table cell text. `body table import` appends one table from explicit
  inline/file TSV or CSV input through `ICNote.addTableAttachmentWithText:`
  after command-layer normalization, then verifies source/normalized text
  hashes, table/inline attachment deltas, and per-cell hash readback without
  printing source text, table cell text, or local file paths. `body table copy`
  copies one selected source table to the same note or an explicit target note
  through `ICTable.stringForColumnIndex:rowIndex:` plus
  `ICNote.addTableAttachmentWithText:`, then verifies source-table
  preservation, target table/inline attachment deltas, copied-text hash
  evidence, and per-cell hash readback without printing table cell text. `body table rows insert/delete/move/copy/clear` and `body table columns
insert/delete/move/copy/clear` use private `ICTable` row/column structure selectors,
cell readback, cell writes, and content-removal selectors to change, copy, or
clear selected rows and columns.
They verify selected-table identity preservation, row/column count readback or
dimension preservation, table-count preservation, inline attachment
preservation, table-cell privacy, moved row/column slice SHA-256 readback for
move operations, copied row/column slice SHA-256 destination readback for copy
operations, and cleared slice empty-readback SHA-256 evidence for clear operations.
`body math audit` accounts for the current Apple Solve math and Open Math Notes
from Calculator guide pages without reading notes or calling a implementation. It
reports supported private math-result list/insert/update, Math Results display
preference, variable definition and dependent-result update commands,
expression verification through the private calculate scanner, Math Notes
folder note operations, and Smart Folder math criteria; and delegated Notes.app
suggestion, variable-color, variable-stepper, and Calculator handoff surfaces.
`body math list` reads existing math-result inline attachment records and
returns only ordinals, identity hashes, expression/result byte counts and
SHA-256 hashes, validity, and direction metadata. `body math update --id NOTE_ID
--ordinal N --text RESULT` updates one existing result attachment through
`ICInlineAttachment.updateCalculateResult:isRightToLeft:` and verifies selected
math-result identity preservation, result hash readback, math/inline
attachment-count preservation, note identity preservation, and privacy
redaction without printing expression or result text. `body math insert --id
NOTE_ID [--paragraph HASH|--ordinal N] --text EXPRESSION` inserts one
recognized calculation expression/result through `ICNote.textStorage`,
`ICalculateRecognitionController.didInsertString:atRange:`, and
`ICCalculateRecognitionController.insertResultAtRange:`. It appends by default
or inserts after a selected paragraph ordinal/hash, then verifies a new
math-result identity, expression hash readback, math-result count delta,
inline-attachment delta, note identity preservation, and privacy redaction
without printing expression or result text. `body math results --id NOTE_ID
--mode insert|suggest|off` changes the note-scoped Math Results display
preference through private `ICNote.calculatePreviewBehavior` /
`setCalculatePreviewBehavior:` and verifies private readback plus body
preservation without printing note content. `body math variable set --id
NOTE_ID --name NAME --value VALUE --expression EXPRESSION` inserts one private
variable-definition expression and one dependent expression through
`ICNote.textStorage`, `ICCalculateRecognitionController`, and
`ICCalculateDocumentController`. The command accepts only Latin-alphabet
letters/words for `--name`, matching Notes' variable-recognition rule, then
verifies distinct private expression hash readback without printing variable
names, values, expressions, results, or note text. `body math variable update
--id NOTE_ID --definition-ordinal N
--dependent-ordinal N --value VALUE` replaces one selected private
variable-definition expression range, drives Notes' calculate document
controller, and verifies that the dependent result changed while the dependent
expression hash stayed stable. `body math verify-expression --text
EXPRESSION` runs `ICCalculateStringScanner.scanStringforRange:previewedExpressionString:`
over one caller-provided expression and returns expression SHA-256/byte-count
and UTF-16 range accounting, scanner object count/type hash, implementation-call
evidence, and no raw expression or result text without mutating a note. `doctor
rich-lab` reports accepted
table and math-result insert/update path evidence without executing writes. `body collapsible list` returns
one privacy-safe record per existing collapsible section using
`ICOutlineController`, and `body collapsible set` uses `ICOutlineController`
plus `ICOutlineState` to collapse, expand, or toggle one existing section
selected by collapsible-section ordinal or paragraph hash while preserving
section count and note identity.
`body paragraph style`,
`body paragraph align`, `body paragraph quote`, `body inline format`,
`body inline color`, `body inline highlight`, `body inline font`, `body checklist add`,
`body checklist set`, `body checklist set-all`, `body checklist convert`,
`body checklist convert-range`, `body checklist reorder`, `body checklist indent`, `body checklist delete`,
`body checklist line-break`, `body checklist end`,
`body list add`, `body list convert`, `body list convert-range`,
`body list set-style`, `body list reorder`, `body list indent`, `body list delete`,
`body list line-break`, `body list tab`, and `body list end` are promoted rich body mutation
slices. Paragraph style changes one non-list, non-checklist, non-block-quote
paragraph selected by `body structure` hash or ordinal to title, heading,
subheading, or body through typed `ICTextStyle` and `ICTTParagraphStyle`
evidence; `heading` and `subheading` create or keep a collapsible section,
while `body` and `title` demote/remove collapsibility for that paragraph.
Paragraph align changes one such paragraph to a supported alignment
through typed `ICTTParagraphStyle` alignment conversion. Paragraph quote toggles
block-quote state for one non-list, non-checklist paragraph through
`ICTTMutableParagraphStyle.blockQuoteLevel`. Inline font applies one available
font family and point size to a selected text range through `NSFont` and
attributed string font attributes, while dry-run/result output reports only
selected-text and font-family hashes plus point size. Add appends
one checklist item to one editable visible non-password-protected note with
typed `ICTTMutableParagraphStyle` and `ICTTTodo` evidence. Set changes one
existing checklist item's checked/open state by paragraph anchor hash or ordinal
using typed paragraph-style/todo mutation. Set-all changes every checklist item
state on one target note using the same typed paragraph-style/todo path.
Convert changes one non-checklist body-structure paragraph anchor into a
checklist item while preserving its paragraph UUID and text hash. Convert-range
changes a contiguous `body structure` paragraph ordinal range into checklist
items when every selected paragraph is non-checklist, preserving paragraph
anchor order and title hashes. Checklist reorder moves
one existing checklist item to a target checklist ordinal on the same note using
typed `ICNote.textStorage` attributed paragraph ranges. Indent increases or
decreases one checklist item's list level by one through
`ICTTMutableParagraphStyle.indent`. Delete removes one existing checklist
paragraph through `ICNote.textStorage` paragraph range deletion. List reorder
moves one existing ordinary list item to a target ordinary-list ordinal using
typed `ICNote.textStorage` attributed paragraph ranges while explicitly
excluding checklist paragraphs. List indent
increases or decreases one ordinary list item's level by one through
`ICTTMutableParagraphStyle.indent` while explicitly excluding checklist
paragraphs. List delete removes one ordinary list paragraph through
`ICNote.textStorage` paragraph range deletion while explicitly excluding
checklist paragraphs. List add appends one ordinary bulleted, dashed, or
numbered list item. List convert and convert-range change one non-list
paragraph anchor or contiguous non-list paragraph ordinal range into the
requested ordinary list style while preserving paragraph anchors and title
hashes. List set-style changes one existing ordinary list item to bulleted,
dashed, or numbered, or reports a no-op when already at the requested style.
The verifier checks set
item-count preservation,
add/convert item-count deltas, done/open count deltas or all-item target
counts, body hash preservation, paragraph-anchor preservation for hash-selected
and all-item set operations, paragraph-anchor checklist conversion, requested
ordinary-list style readback, reorder anchor-order readback, checklist and
ordinary-list indentation level/delta readback, ordinary list delete target
absence, ordinary list anchor-order preservation, delete target-anchor
absence, source or target title-hash preservation, and body byte-count/hash
preservation, with paragraph style/alignment/block-quote verifier checks added
for target style/alignment/block-quote readback, collapsible-section
promotion/demotion readback for paragraph-style changes, paragraph-anchor order
preservation, list/checklist count preservation, and body hash preservation,
and inline format/color/highlight/font verifier checks added for selected-text
hash/count, target run/font-hash readback,
paragraph-anchor order preservation, body byte-count/hash preservation, and
note identity/title/folder/account preservation. The commands return note
summary and structure evidence rather than raw attributed content.
`state read`, `state audit`, `state lockability`,
`state collaboration audit`,
`state security audit`, and `state activity`
are the promoted locked/shared boundary read/accounting slices. `state read`
reports state flags and counts for one note, while `state audit` batches visible
notes under the selected account/folder/limit and returns state records plus
aggregate lock/share/collaboration accounting. `state lockability` reads one
selected note through the private state, account/provider lockability, tag, and
attachment metadata surfaces and returns lockability flags plus privacy-safe
reason IDs, booleans, counts, and hashes for provable blockers such as Quick
Note status, shared state, unsupported provider/account crypto state, tags,
unsupported attachment families, unknown attachment families, and cloud-fetch
requirements. `state collaboration audit`
accounts for the current Apple sharing/collaboration guide workflows as
supported, delegated, gated, or rejected without selectors or implementation calls. It
now reports 26 records: 20 supported, 6 delegated, 0 gated, and 0 rejected.
State/activity reads, participant/access metadata readback, participant/access
metadata artifact export, activity artifact export, editable shared-note
mutation paths, starting note/folder collaboration, participant invite/add,
existing collaboration access-scope changes for shared notes or folders,
invite-policy changes, shared note/folder stop-sharing, semantic participant
mention insertion, existing collaboration link clipboard/artifact output,
existing participant permission mutation, existing participant removal,
self-removal from an already shared note or folder, and per-shared-note Hide
Alerts are supported;
system share/invitation delivery,
iCloud link opening, realtime presence, highlights, and activity UI are
delegated; no collaboration workflow remains gated.
`state participants --id NOTE_ID|--folder FOLDER` reads existing
shared-object participant/access metadata and returns target/share/owner hashes,
participant identity hash set, user-record hashes, counts, and
permission/role/acceptance/public-permission enum values without raw
participant, contact, link, title, or body values. With `--output FILE.json`, it
exports the same hash-only metadata artifact behind `--allow-artifact-action`
and verifies artifact hash plus participant readback. `state security audit` accounts for the current Apple Lock Notes and
locked-notes password workflows without selectors or implementation calls: lock state,
lockability, provable note/account/provider lockability-reason readback,
account-upgrade/provider reason evidence, and password-settings family
accounting plus custom locked-notes passphrase setup, change, and reset through
`ICAccountPassphraseManager`, the account-scoped Touch ID preference, private
passphrase unlock through `ICAuthenticationState`, eligible note
lock/remove-lock mutation through `ICNoteLockManager`, explicit locked session
close, and `.txt` locked-content artifact export for both current-session
unlocked notes and same-command passphrase authentication are supported; Touch
ID authentication, Mac login password authentication, and Notes.app
locked-session timeout remain delegated system/app surfaces; initial
login-password method selection is supported for accounts with no existing
password-protected notes through private mode readback; and password method
changes remain gated until private migration/rekey proof and readback are
accepted. Password reset is supported
for the selected custom-password account path through the private account
passphrase manager reset selector and hash-only verifier accounting; password
change is supported for the selected custom-password account path through the
private account passphrase manager change selector with separate old/new
secret-source accounting. `state activity` reads private
`ICCloudSyncingObject`
activity-event metadata for one note and can export a verified `.json` artifact
containing only shared flags, participant counts/hashes, event byte-count/hash,
activity-document presence, and share timestamp hash. These surfaces do not
print note bodies, titles, folder/account names, participant names, shared owner
names, activity text, raw share links, or raw collaboration handles. The
semantic remaining locked/password mutation command `state change-password` is
an explicit future-backlog gated-refusal surface: it validates required
selectors, returns structured `unsupported_operation` metadata, and makes no
implementation calls until capability-specific private-framework mutation/readback
proof is accepted.
`state unlock --id NOTE_ID --passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE`
is supported separately through private `ICAuthenticationState` session
authentication and requires `--allow-persistent-action`.
`settings locked-notes --account ACCOUNT --scope custom
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`
is supported separately through private
`ICAccountPassphraseManager.setPassphrase:hint:`, verifies selected-account
crypto-strategy readback, requires `--allow-persistent-action`, and does not
print passphrases, source names, file paths, hints, account values, or keychain
material.
`settings change-password --account ACCOUNT
--old-passphrase-stdin|--old-passphrase-env NAME|--old-passphrase-file FILE
--new-passphrase-stdin|--new-passphrase-env NAME|--new-passphrase-file FILE
[--hint HINT]` is supported separately through private
`ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:`,
verifies selected-account crypto-strategy readback plus change-boundary
accounting, requires `--allow-persistent-action`, and does not print old or new
passphrases, source names, file paths, hints, account values, or keychain
material.
`state export-locked-content --id NOTE_ID --output FILE.txt` is supported
separately when the selected password-protected note is already unlocked in the
current Notes session or when the same command supplies exactly one passphrase
source. It authenticates through private
`ICAuthenticationState.authenticateObject:withPassphrase:` when needed, uses
private plaintext readback, writes only the explicit artifact behind
`--allow-artifact-action`, requires `--allow-persistent-action` only for
same-command authentication, verifies artifact hash/readback, and does not
print passphrases, source selectors, note titles, or locked content.
`state lock --id NOTE_ID --allow-persistent-action` and
`state remove-lock --id NOTE_ID --allow-persistent-action` are supported
separately for eligible notes through `ICNoteLockManager` and private
lock-state readback. They do not print note bodies, titles, password hints,
locked content, or keychain material; currently locked notes can be unlocked
first through the secret-source-bounded `state unlock` command before
remove-lock runs.
`state stop-sharing --id NOTE_ID|--folder FOLDER` is supported separately for
one already shared note or folder through
`ICCollaborationController.removeShareIfNeededWithOwnedObjectID`,
requires `--allow-destructive-selection` and `--allow-persistent-action`, and
verifies share absence plus participant-count delta without printing participant
handles or share links.
`state allow-invites --id NOTE_ID|--folder FOLDER --enabled true|false` is
supported separately for one already shared note or folder through private
`CKShareParticipant.role` mutation plus collaboration share save, requires
`--allow-persistent-action`, and verifies administrator-role count readback
without printing participant handles, share links, note titles, folder names, or
body text.
`state close-locked [--account ACCOUNT] --allow-persistent-action` is supported
separately: it calls private `ICAuthenticationState.deauthenticateAllObjects`,
uses optional account input only as a privacy-safe selector preflight, and
verifies `isAuthenticated`/`hasAuthenticatedObject` readback without printing
account values, passwords, locked note content, or keychain material.
`state copy-link --id NOTE_ID|--folder FOLDER` is supported separately for an
already shared note or folder: it reads the existing private collaboration URL,
writes it to the system clipboard behind `--allow-persistent-action` or to an
explicit `.txt` artifact behind `--allow-artifact-action`, and returns
hash/byte-count verifier evidence without printing the raw share link to JSON or
stdout. Link creation remains gated.
`state share --id NOTE_ID|--folder FOLDER --scope invited-only|anyone-with-link`
is supported separately for one already shared note or folder: it mutates `CKShare.publicPermission`,
saves the private collaboration share, requires `--allow-persistent-action`,
and verifies public-permission enum readback without printing share links,
participant handles, note titles, folder names, or body text. Passing `--target`
to `state share`, using `state share-folder`, or using `state invite` is also
supported for one note/folder share participant operation: the command creates or
reuses the private collaboration share, resolves the target through CloudKit
share-participant lookup, calls `CKShare.addParticipant`, saves the private
collaboration share, requires `--allow-persistent-action`, and verifies
participant/permission delta readback without echoing the raw target.
`state set-permission --id NOTE_ID|--folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write`
and `state folder-permission --folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write`
are supported separately for one existing participant on an already shared note
or folder:
it resolves the participant through private participant metadata, mutates
`CKShareParticipant.permission`, saves the private collaboration share, requires
`--allow-persistent-action`, and verifies before/after permission enum readback
without printing participant handles, contact values, share links, note titles,
folder names, or body text.
`state remove-participant --id NOTE_ID --target PARTICIPANT_ID` is supported
separately for one existing non-owner, non-current-user participant on an
already shared note: it resolves the participant through private share metadata,
calls `CKShare.removeParticipant`, saves the private collaboration share,
requires `--allow-persistent-action`, and verifies participant absence plus
before/after participant-count readback without printing participant handles,
contact values, share links, note titles, or body text.
`state remove-self --id NOTE_ID|--folder FOLDER` is supported separately for
one already shared note or folder: it resolves the current user participant
through private share metadata, calls `CKShare.removeParticipant`, saves the
private collaboration share, requires both `--allow-destructive-selection` and
`--allow-persistent-action`, and verifies current-user absence plus
before/after participant-count readback without printing account values,
participant handles, contact values, share links, note titles, folder names, or
body text.
`state hide-alerts --id NOTE_ID --enabled true|false` is the supported
per-shared-note notification-preference mutation: it uses private shared-note
recordID readback with `ICShareNotifier`, requires `--allow-persistent-action`,
and returns only note/record hashes, booleans, counts, and verifier evidence.
`state mention --id NOTE_ID --target PARTICIPANT_ID [--text TEXT]` is supported
for one already shared editable note: it resolves an existing participant
through private participant metadata, creates an `ICInlineAttachment` mention,
inserts it through `ICNote.textStorage`, requires `--allow-persistent-action`,
and returns only note, target, participant, text, attachment, and verifier
hash/count evidence.
The settings boundary is also explicit: `settings audit` accounts for the
current official Change Notes settings, Customize how notes appear, Use Notes
widgets, and Manage notifications pages without requiring selectors or calling
the Notes implementation. It reports 28 workflow records: 19 supported
private-framework/command paths, 9 delegated macOS/system/Notes.app UI surfaces,
and 0 gated security/password mutation gaps. `settings read` returns read-only official settings-family
accounting backed by private account/default-account,
note-list sort, default new-note paragraph style, global date grouping,
default/query date-header type,
Quick Note resume preference, allow-mention-notifications preference,
default text size/global zoom preference, checklist auto-sort preference,
selected-account locked-notes passphrase state, account-scoped Touch ID
preference, and On My Mac account evidence.
`settings sort`, `settings default-account`, `settings group-by-date`,
`settings group-by-date --scope default|query`,
`settings quick-note-resume`, `settings mention-notifications`,
`settings text-size`, `settings new-note-style`, `settings checklist-sort`,
`settings locked-notes --account ACCOUNT --scope custom
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`,
`settings locked-notes --account ACCOUNT --scope login-password`,
`settings change-password --account ACCOUNT
--old-passphrase-stdin|--old-passphrase-env NAME|--old-passphrase-file FILE
--new-passphrase-stdin|--new-passphrase-env NAME|--new-passphrase-file FILE [--hint HINT]`,
`settings reset-password --account ACCOUNT
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`,
`settings touch-id --account ACCOUNT --enabled true|false`, and
`settings on-my-mac --enabled true|false` are supported persistent
preference or local-account lifecycle mutations. The false form is accepted only
when private readback proves the local account has no visible or trashed notes,
no custom folders, is not the default account, and another Notes account is
active. These writes use typed private setters, account passphrase manager, or
account lifecycle APIs with
`--allow-persistent-action` and post-write settings readback verification.
Password-method migration/change paths and `settings password` return future
backlog gated metadata and
`settings notifications` / `settings widgets` return delegated metadata for
macOS/system user-facing surfaces. The settings read command reports hashes and
booleans only; the accepted settings mutations also report hash/bool readback
only. They do not dump defaults, paragraph style names, raw account values,
date-header enum values, text-size values, passwords, hints, or setting payloads. The remaining gated/delegated
commands make no Notes implementation, AppleScript, or SQLite calls and do not echo
account values.
External Notes account add, remove, enable, and disable workflows are explicit
delegated account-lifecycle boundaries: `accounts add`, `accounts remove`,
`accounts enable`, and `accounts disable` validate the requested provider or
account selector, return structured `unsupported_operation` metadata with
`status=delegated`, and make no Notes implementation calls. These workflows belong to
macOS Internet Accounts or user-facing account management surfaces until a
future accepted route proves otherwise. On My Mac enablement and empty local
account disablement remain the separate supported private Notes paths exposed by
`settings on-my-mac --enabled true|false`.
`pin` and `unpin` are promoted state mutations for one visible note.
`empty-trash` is promoted as a bounded destructive-selection batch over
restorable private-framework notes; it returns counts and ID hashes only and
verifies visible plus restore-only readback absence. Generic link mutation beyond the accepted link commands, raw internal-token output, Smart Folder criteria construction beyond accepted tag, accepted folder/not-folder, selected participant/mention, promoted built-in/folder/date/participant/mention criteria, and single Untagged tag-selection-mode criteria, remaining Smart Folder raw-value/tag-identifier/object-bound/date-folder value comparison and full multi-condition tracing, non-title attachment update/transform,
  still-locked note PDF or RTF/RTFD export, broader object-label output beyond hash-only classification summary readback, broader markup edit/write workflows beyond Markup model inspection/export/apply, richer table-format operations beyond supported table create/import/update/delete/convert-to-text/convert-from-text/copy/move and row/column insert/delete/move/copy/clear, and richer rich-body mutation beyond supported paragraph style/alignment/block quote, inline format/color/highlight/font, collapsible state/create-update, table list/create/import/update/delete/copy/move/convert-to-text/convert-from-text/row-column structure edit, math-result list/insert/update, and list/checklist slices,
locked/shared mutations, richer preservation diagnostics,
and broader rich private write execution
remain gated until the corresponding private
write or rich-read behavior is proven.

Doctor output must not print note bodies. Sensitive local paths, identifiers,
and content-derived evidence should be redacted, hashed, counted, or bounded.

## Evidence Sources

Product capability evidence comes from Apple Notes user-visible behavior and
local Notes.app observations. Implementation evidence comes from private Notes
framework behavior and read-only local store/index verification. Scripting
evidence is migration-only.

## Validation

Notes changes use package-local checks:

```bash
swift build
swift test --filter Notes
swift run apple notes doctor --json
```

Private framework boundary changes should also audit linkage and direct store
write absence:

```bash
otool -L .build/debug/apple
rg -n "(INSERT|UPDATE|DELETE|REPLACE|CREATE|DROP).*NoteStore|sqlite3_exec|executeUpdate" Sources/NotesCLI
```

New Notes variants become supported after the semantic command, private
framework behavior, safety policy, verifier evidence, tests, and documentation
are all in place.
