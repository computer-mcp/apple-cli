# Notes Developer Guide

## Command Execution Layout

`Sources/NotesCLI/Commands/Commands.swift` owns the typed parser.
`Command.swift` composes injected dependencies and dispatches accepted positional
paths. The `NotesCommand<Domain>.swift` extensions hold the corresponding
execution branches and helpers for accounts, folders, Smart Folders, tags,
read/search, lifecycle, links, body, attachments, state, security, settings and
import/export. `NotesCommandWorkflowAudits.swift` owns the three Notes-wide
guide/workflow/shortcut audits; domain audits stay with their domain.

Keep validation, identity/state resolution, dry-run or execution, and verifier
readback in their established order. Unknown execution paths return `nil`
without backend access. Cross-file helpers remain internal; same-file helpers
remain private. `NotesCommandSupport.swift` holds shared mechanics, without
absorbing domain behavior.

## Implementation Direction

Notes has closed the current private-framework-backed milestone. Treat
`NotesReading` and `NotesMutating` as target-local implementation injection
surfaces. `NotesAppleScriptParityReader` is a read-only parity reader and must
not conform to `NotesMutating`. AppleScript may be used for bounded parity
diagnostics, but it must not become a durable implementation selection model or
writer surface.

Accepted production behavior should use generated Notes framework imports.
Read-only Notes SQLite reading is allowed for enrichment, doctor output, parity
checks, and post-write verification. Direct Notes SQLite writes are rejected.

## Private Framework Intake

The current intake path follows the Reminders pattern:

```bash
Scripts/notes-private-framework-normalize-full-dump \
  --dump-root <ipsw-class-dump-root> \
  --sources-root Sources
```

The generated surfaces live under:

- `Sources/NotesSupport/include/`
- `Sources/NotesHTML/include/`
- `Sources/NotesShared/include/`
- `Sources/NotesUI/include/`
- `Sources/NotesEditor/include/`
- `Sources/NotesPreviewKit/include/`

Local patched `.tbd` framework overlays may be generated from the macOS SDK
when direct linking needs SDK allowed-client metadata removed. The overlays
must preserve system framework install names and should be audited before
production code relies on direct typed private class references.

From the repository root, run `Scripts/bootstrap` before the first build.
The default Notes target links the generated framework stub overlay at
`.build/notes-private-framework-link-stubs/current`. Bootstrap uses the selected
Xcode SDK, preserves system install names, and records SDK/toolchain and input
hashes in `provenance.json`. Rerun it after changing the SDK. Normal builds use
the saved generated headers and do not require a new class dump.

Override the stub root only when validating a freshly generated overlay:

```bash
APPLE_CLI_NOTES_PRIVATE_FRAMEWORK_STUBS=<generated-link-stub-root>
```

`Package.swift` always defines `APPLE_CLI_NOTES_FRAMEWORKS_LINKED`, adds the
selected framework search path, and links the selected Notes private
frameworks. Missing generated stubs should fail the build rather than silently
falling back to AppleScript or an unavailable implementation.

## Doctor and Verifier Work

Run doctor when diagnosing local readiness:

```bash
swift run apple notes doctor --json
```

Default private-framework-backed builds are expected to report
`notes_implementation` as `ok`. Tests may inject test implementations for
command-layer isolation, but the product path should not use an unavailable
implementation or AppleScript fallback.

Doctor output should cover app presence, private framework loadability,
generated import readiness, patched link-stub readiness where applicable, group
container presence, and bounded store/index evidence. It must not print note
bodies.

Current `doctor` includes `notes_store`, a read-only check for the Notes group
container, `NoteStore.sqlite`, SQLite schema counts, entity row counts, WAL/SHM
presence, and Notes index-state files. This evidence is diagnostic/verifier
input only; it does not make the local SQLite store a write mechanism.

`doctor store` exposes the same store/index evidence as a scoped JSON command:

```bash
swift run apple notes doctor store --scope summary --json
swift run apple notes doctor store --scope schema --json
swift run apple notes doctor store --scope entities --json
swift run apple notes doctor store --scope indexes --json
```

The `schema` scope exposes table and column names only, not row content. The
`entities` and `indexes` scopes expose counts only.

Scoped note, folder, and account diagnostics resolve identity through the
current Notes read path first, then attach privacy-preserving private readback
and read-only store-object evidence:

```bash
  swift run apple notes doctor note --id NOTE_ID --json
  swift run apple notes doctor folder --folder FOLDER_ID_OR_NAME --json
  swift run apple notes doctor account --account ACCOUNT_ID_OR_NAME --json
```

These commands expose hashes, lengths, entity matches, primary-key evidence,
counts, and index-state counts only. They must not output raw note IDs, note
titles, note bodies, folder names, account names, or direct SQLite write
behavior.

External account lifecycle commands are delegated boundary commands, not Notes
data mutations:

```bash
swift run apple notes accounts add --provider PROVIDER --json
swift run apple notes accounts remove --account ACCOUNT_ID --json
swift run apple notes accounts enable --account ACCOUNT_ID --json
swift run apple notes accounts disable --account ACCOUNT_ID --json
```

These commands account for the Apple Notes add/remove/enable/disable account
workflows while keeping the implementation boundary honest. They validate the
required provider or account selector, return `unsupported_operation` with
`status: delegated`, `required_implementation:
macos_internet_accounts_route`, `required_verifier:
delegated_internet_accounts_accounting`, and `backend_calls: none`, and must not
echo raw account or provider values. They must not call the Notes implementation,
AppleScript, or `SQLiteReader`. `settings on-my-mac --enabled true|false` is
the separate accepted private local-account lifecycle path; disablement is
allowed only when private readback proves an empty non-default local account and
another active Notes account.

Guide audit is command-layer official Table of Contents coverage accounting:

```bash
swift run apple notes guide audit --json
```

The command must reject note, folder, account, title, body, text, paragraph,
query, and other selectors before dispatch. It reports the current macOS Tahoe
Apple Notes User Guide Table of Contents as 36 page records: 28 supported pages
whose dominant capability is covered by accepted commands or family audits, 5
delegated system/UI pages, 2 gated pages whose dominant remaining work still
needs secret-safe private proof, and 1 rejected non-capability reference
page. Supported records include Quick Note system-paper creation through the
private note writer. It must not call the private Notes reader/writer,
AppleScript, or `SQLiteReader`, and it must not read notes, accounts, folders,
attachments, credentials, UI state, local store rows, or guide page contents at
runtime.

Account workflow audit is command-layer official-guide accounting:

```bash
swift run apple notes accounts workflow audit --json
```

The command must reject account, provider, folder, name, query, and other
selectors before dispatch. It reports the Apple Add/remove accounts page as 13
records: supported private account metadata/account-scoped visibility plus On
My Mac enablement/empty-local-account disablement, delegated macOS Internet
Accounts/browser/device routes, no gated local-account records, and rejected
provider/local-account limitations. It must not call the private Notes
reader/writer, AppleScript, or `SQLiteReader`, and it must not read credentials,
account provider values, notes, or folders.

Folder workflow audit is command-layer official-guide accounting:

```bash
swift run apple notes folders workflow audit --json
```

The command must reject account, folder, parent, name, query, and other
selectors before dispatch. It reports the Apple About accounts/folders and
Add/remove folders pages as 26 records: supported private folder metadata and
accepted folder/note placement commands, delegated Notes.app sidebar/menu/drag
UI routes, no gated folder semantics, and rejected Apple product limitations.
The supported folder semantics include `folders move-impact`, a read-only
`ICMoveDecision` preflight that reports shared-permission and cross-account
fidelity-risk evidence as hashes, counts, and booleans before the separate move
operation. The audit command itself must not call the private Notes
reader/writer, AppleScript, or `SQLiteReader`, and it must not read note bodies,
folder contents, account values, or folder names from the local store.

Private text write readiness is checked by the write lab probe:

```bash
swift run apple notes doctor write-lab --json
```

The probe checks required private write selectors and optional dynamic
property evidence such as
`ICNote.newNoteWithString:inFolder:error:`,
`ICNote.appendAttributedString:error:`, `ICNote.textStorage`,
`ICNote.beginEditing`, `ICNote.didChangeNoteText`, `ICNote.endEditing`,
`ICNote.markForDeletion`,
`ICNote.noteWithIdentifier:includeDeleted:context:`,
`ICNote.isDeletedOrInTrash`, `ICNote.unmarkForDeletion`,
`ICNote.purgeNote:`, `ICNote.isPinnable`,
`ICNote.changePinStatusIfPossible`, optional `ICNote.isPinned`, `ICNote.save`,
`ICFolder.newFolderInAccount:`, `ICFolder.newFolderInParentFolder:`,
`ICFolder.isTitleValid:account:parentFolder:error:`,
`ICFolder.canAddSubfolder`, `ICFolder.isRenamable`,
`ICFolder.isTitleValid:error:`, `ICFolder.setTitle:`,
`ICFolder.updateChangeCountWithReason:`, `ICNoteContext.save:`, and
`NSManagedObjectContext.ic_save` without executing a write. Optional fallback
and dynamic Core Data accessors, such as `ICFolder.newNoteInContext:` and
`ICFolder.setDateForLastTitleModification:`, are reported separately. A
ready probe is a selector gate only; richer private writes still need
capability-specific execution, post-write verification, preservation checks,
and tests before promotion.

Private rich capability readiness is checked by the rich lab probe:

```bash
swift run apple notes doctor rich-lab --json
```

The probe covers eight candidate families: links, attachments, tags, Smart
Folders, body structure, accepted body table mutation, optional future
body math mutation, and archive/import/export. It checks class and selector
availability, including the `NotesEditor.ICMPrintController` note-to-PDF
selectors, `NotesUI.ICMarkdownRepresentation` / `NotesUI.ICMarkdownString`
note-to-Markdown selectors, `NotesUI.ICNote` note-to-HTML selectors,
`NotesUI.ICShareNoteExporter` note-to-RTFD/RTF-member selectors,
`ICTable`/`ICTableTextAttachment` table candidates, and
`ICCalculateDocumentController`/`ICCalculateRecognitionController` math
candidates, only. It must report `mode: probe_only` and `write_access: none`; it must not
instantiate rich objects, open user files, or write Notes data. Its
`accepted_capability` field lists promoted rich slices such as `body_structure`,
`body_collapsible_list`, `body_collapsible_set`, `body_collapsible_create_update`, `body_paragraph_style`,
`body_paragraph_align`, `body_paragraph_quote`, `body_inline_format`,
`body_inline_color`, `body_inline_highlight`, `body_inline_font`,
`body_checklist_add`, `body_checklist_set`, `body_checklist_set_all`,
`body_checklist_sort`, `body_checklist_convert`,
`body_checklist_convert_range`, `body_checklist_reorder`,
`body_checklist_indent`, `body_checklist_delete`, `body_list_add`,
`body_list_convert`, `body_list_convert_range`, `body_list_set_style`,
`body_list_reorder`, `body_list_indent`, `body_list_delete`,
`body_table_list`, `body_table_create`, `body_table_import`, `body_table_update`,
`body_table_delete`, `body_table_convert_to_text`, `body_table_copy`, `body_table_move`, `body_table_structure_edit`, `attachment_copy`, `rich_replace`, `body_math_list`,
`body_math_insert`, and `body_math_update`.
Optional
candidate gaps, such as attachment property getters that are not visible in
the runtime method table, should be recorded as evidence without blocking the
required family gates. Table list/create/import/update/delete/convert-to-text and math-result
list/insert/update are accepted through private attachment readback, private
writer paths, and verifier readback.

Notes visible-note listing and text search are promoted bounded read slices:

```bash
  swift run apple notes list --account ACCOUNT --folder FOLDER --json

  swift run apple notes search --query QUERY --scope text --json

  swift run apple notes search --account ACCOUNT --query QUERY --json

  swift run apple notes search --query QUERY --include-recently-deleted --json

  swift run apple notes search --id NOTE_ID --query QUERY --json

  swift run apple notes search natural-language --query QUERY --json

swift run apple notes search attachment-content --query QUERY --family pdf --json

swift run apple notes search locked-title --query QUERY --json

swift run apple notes search audit --json
```

The command must validate `--query` before implementation reads and reject queries
shorter than two non-whitespace characters. Default search and `--scope text`
use the private visible-note text/title search path and return note summaries
only, while password-protected or locked notes are title-only for search.
`--account ACCOUNT` dispatches through `NotesAccountScopedSearching` and limits
the same visible-note text/title summary search to one selected account.
`notes list --account ACCOUNT [--folder FOLDER]` dispatches through
`NotesAccountScopedListing` and returns only note summaries; it must not fetch
note bodies to apply the account selector.
`--id NOTE_ID` reads one selected note through the private note read path,
matches query against title/body, and returns only the note summary; it must not
print the note body and cannot be combined with `--account` or `--folder`.
Password-protected or locked selected notes must match only by title.
`--include-recently-deleted` additionally searches bounded restore-only private
restorable-note readback, supports the same account/folder filters and the
single-id path, and must not print deleted note bodies.
Non-text scopes are explicit boundaries:
`attachment-name` delegates to `attachments search`, `audio-transcript`
delegates to `attachments audio search`, `pdf-content` delegates to
`attachments pdf search`, scan/image/drawing/handwriting scopes delegate to
`attachments scan search`, `attachments image search`, or
`attachments drawing search`, and `suggested` delegates to the existing
state/tag/Smart Folder/attachment semantic commands. The visual attachment
search commands read existing private searchable/indexable text and report only
query/content hashes, byte counts, match counts, source kinds, and attachment
metadata. `notes search locked-title --query QUERY [--account ACCOUNT]
[--folder FOLDER]` and `--scope locked-title` must use visible-note summaries
plus private note-state readback to match only password-protected or locked note
titles without reading or matching locked bodies. `notes search
attachment-content --query QUERY [--folder FOLDER|--id NOTE_ID] [--family
FAMILY]` must compose accepted private attachment metadata, PDF text, existing
audio transcript, and scan/image/drawing searchable-text readback. Result JSON
must include query hash/count, searched slice summaries, note/attachment
metadata, content byte-count/SHA-256, match counts, and verifier evidence
without raw query or raw attachment content. The `--scope attachment-content`
route maps to the same composite search without the family guard option.
Natural-language search must run the private `ICSearchQueryOperation`
natural-language path, prove that a private NL query was created, map private
results to note summaries, and return query SHA-256/byte-count plus
result-accounting evidence without raw query or note body output. Recognized-text artifact export/generation is
supported separately by `attachments recognized-text export` and `attachments
recognized-text generate`; selected-attachment search-index mutation is
supported separately by `attachments recognized-text index`. The remaining
visual-recognition boundary command is `attachments image objects`.
`notes search audit` is a command-layer capability-accounting command for the
current Apple Notes search guide. It must reject `--query`, make no Notes
implementation, AppleScript, attachment reader, or `SQLiteReader` calls, and verify
that supported text/account/single-note/Recently Deleted search,
natural-language search, locked-title-only search, composite attachment-content search, delegated
attachment, PDF, audio, scan/image/drawing/handwriting searchable-text,
suggested, Siri, and Spotlight surfaces are all accounted for with explicit
command strings where present and without raw
query, note body, locked body, deleted note body, attachment content, recognized
text, Siri, Spotlight, or search-index output.

`notes workflow audit` is the command-layer capability-accounting surface for
the current Apple Notes Create/Edit, Quick Note, View Notes, Sort and Pin,
Delete, and Keyboard Shortcuts/Gestures guide pages:

```bash
  swift run apple notes workflow audit --json
```

The command must reject note, folder, title, body, text, query, and other
selectors before any implementation dispatch. It must not call the private Notes
reader/writer, AppleScript, or `SQLiteReader`, and it must not read note bodies,
locked content, clipboard contents, activity text, participant names, provider
sync data, or local UI state. The verifier must prove the 40-record accounting
shape, supported private-framework note lifecycle/view/settings families
including Quick Note system-paper creation, explicit multi-note lifecycle
  batches, private passphrase unlock plus authenticated locked-content artifact
  export, delegated Notes.app/macOS/system/provider surfaces, no remaining note
lifecycle gated records, the Quick Note lock product limitation, and
`backend_calls=none`. This audit is the
durable target-local place for official base note workflows that are already
supported through semantic CLI commands, delegated to UI/system surfaces, or
still need capability-specific private proof.

`notes quick-note create` is a semantic persisted Quick Note writer:

- Parser path: `notes quick-note create`.
- Allowed options: `folder`, `title`, and `body`.
- Draft model: the regular `NotesCreateDraft` with `isSystemPaper: true`.
- Private writer: `ICNote.newNote(...)`, followed by
  Swift-imported `ICNote.mark(asSystemPaperIfNeeded: true)`.
- Verifier: ordinary create readback plus note-state `isSystemPaper == true`.
- Boundary: hot corner/Fn-Q launch, Safari active-page capture, thumbnails, and
  other Notes.app UI invocation surfaces stay delegated; Quick Note locking is
  rejected because Notes.app itself does not allow it.

`notes workflow shortcuts audit` is the command-layer capability-accounting
surface for the current Apple Notes Keyboard Shortcuts and Gestures guide page:

```bash
swift run apple notes workflow shortcuts audit --json
```

The command must reject note, folder, title, body, text, paragraph, query, and
other selectors before any implementation dispatch. It must not call the private Notes
reader/writer, AppleScript, or `SQLiteReader`, and it must not read note bodies,
table cell text, link payloads, attachments, clipboard contents, UI focus, or
selection state. The verifier must prove the 58-record accounting shape, 37
supported semantic shortcut equivalents, 21 delegated Notes.app/macOS UI and
navigation surfaces, 0 gated remaining shortcut semantics, official shortcut
section coverage, and `backend_calls=none`. Table-cell newline and literal-tab
input count as supported only through `body table update --text` plus
hash/byte-count readback; list/checklist soft-return insertion counts as
supported only through `body list line-break` and `body checklist line-break`;
ordinary-list literal-tab insertion counts as supported only through
`body list tab`; Monostyled paragraph format counts as supported only through
`body paragraph style --style monostyled` plus private body-structure
readback. End-list body paragraph insertion belongs to the Add Lists workflow
audit and is supported through `body list end` and `body checklist end`; it is
not a separate keyboard shortcut record. Do not mark a shortcut supported
because the keyboard gesture exists in Notes.app; supported means the equivalent
semantic CLI command and verifier proof already exist.

`tags audit` is the command-layer capability-accounting surface for the current
Apple Notes Use Tags guide page:

```bash
swift run apple notes tags audit --json
```

The command must reject tag, note, name, account, query, and other selectors
before any implementation dispatch. It must not call the private Notes tag reader or
writer, Smart Folder reader, AppleScript, or `SQLiteReader`, and it must not
read tag values, note bodies, Smart Folder criteria, shared-note participant
identifiers, Reminders tags, or UI state. The verifier must prove the
15-record accounting shape, supported private-framework tag list/search/
membership/rename/delete families including rename-to-existing merge and
multi-tag delete plus Smart Folder criteria delta readback for rename/delete,
supported Convert to Text body plaintext preservation readback,
delegated suggested-tag/sidebar/shared-note UI surfaces, no remaining Use Tags
gated semantics, and
`backend_calls=none`. Multi-tag All/Any search and
include/exclude tag search are supported only through `tags search` with tag
selector hash/count accounting and private note tag readback filtering. Convert
to Text is supported only through `tags convert-to-text` with private body-text
preservation readback; ordinary `tags remove` remains membership removal.

Tag listing and tag-scoped note search are promoted rich-family read slices.
Validate them only in a default private-framework-backed build:

```bash
  swift run apple notes tags list --json
  swift run apple notes tags search --tag Urgent --json
  swift run apple notes tags search --tags Urgent,Home --mode all --json
  swift run apple notes tags search --include-tags Urgent,Yonder --exclude-tags Home --mode any --json
```

The implementation uses typed `ICHashtag` APIs, bounded visible-use counts, and
tag-scoped `ICNote.notesContainingHashtagWithStandarizedContent:context:`
readback. Tag search validates every included and excluded tag selector before
query execution, supports All/Any mode filtering, filters candidate notes using
private note tag readback, and returns note summaries plus selector hash/count
accounting only; it must not print note bodies or raw tag selector values.
Single-note tag membership add/remove is implemented through the private
writer:

```bash
  swift run apple notes tags add --id NOTE_ID --tag Urgent --dry-run --json
  swift run apple notes tags remove --id NOTE_ID --tag Urgent --dry-run --json
  swift run apple notes tags convert-to-text --id NOTE_ID --tag Urgent --dry-run --json
  swift run apple notes tags rename --tag Urgent --name Important --dry-run --json
  swift run apple notes tags delete --tag Urgent --dry-run --json
  swift run apple notes tags delete --tags Urgent,Review --dry-run --json
```

The writer uses typed `ICHashtag` and `ICNote` hashtag body APIs. Membership
writes use note-level hashtag APIs. Convert to Text uses the private hashtag
removal path only after private body plaintext byte-count/SHA-256 readback is
available, and `NotesMutationVerifier` must prove plaintext preservation, tag
query exclusion, and target tag membership absence. Rename uses
`ICHashtag.canRenameTagWithNewDisplayText:`,
`ICHashtag.renameHashtagsWithStandardizedContent:newDisplayText:context:`, and
tag-scoped `ICNote.notesContainingHashtagWithStandarizedContent:context:`
readback. Delete uses `ICHashtag.removeUsage` after
`ICFolder.smartFoldersThatWillBeDeletedAfterDeletingHashtags:` reports no Smart
Folder cascade impact. Successful execution must include
`NotesMutationVerifier` evidence for target tag membership, Convert to Text,
rename, or delete;
affected-note identity preservation; old-tag removal; new-tag presence for
rename; title/folder/account preservation; non-target tag preservation; and tag
query/list absence after delete. `tags rename --allow-merge` supports merging
into an existing tag with explicit merge intent and source-affected note
readback. `tags delete --tag` removes one visible tag, while `tags delete --tags` removes at least two explicit
unique tags by reusing the same private delete path for each selected tag.
Batch delete dry-runs and results keep tag-set evidence hash-only, report
affected counts and affected note ID hashes, and verify per-tag query/list
absence plus affected-note identity/title/folder/account and non-deleted tag
preservation. `tags delete` requires `--allow-destructive-selection` because it
mutates a dynamically selected set of notes.

Single-note move is implemented through the private writer:

```bash
  swift run apple notes move --id NOTE_ID --folder FOLDER_ID --dry-run --json
```

The writer uses typed `ICNote` and `ICFolder` model relationships, the same
private save path as text mutations, and `NotesMutationVerifier` readback. The
folder relation is a Core Data dynamic accessor, so `doctor write-lab` treats
the `primitiveFolder` method-table entries as optional evidence while still
requiring the visible move gates such as `isMovable`, `setAccount:`, and
`ensureHashtagsExistInDestinationAccount`. A successful execution must prove
identity preservation, destination folder/account, title/body preservation,
tag-set preservation, and optional store-object evidence. Trash, Smart Folder,
system folder, and read-only folder targets are rejected. Locked/protected
copy and broader folder customization remain gated.

Single-note copy is implemented through the private writer for readable,
non-password-protected notes:

```bash
  swift run apple notes copy --id NOTE_ID --folder FOLDER_ID --dry-run --json
```

The writer uses typed `ICNote.duplicate`, `ICFolder` targets, the same private
save path as text mutations, and `NotesMutationVerifier` readback. A successful
execution must prove a new note identity, source note preservation,
destination folder/account, title/body preservation, tag-set preservation, and
optional store-object evidence. Password-protected/locked note copy remains
gated until locked-content preservation can be proven without exposing secrets.
Trash, Smart Folder, system folder, and read-only folder targets are rejected.

Single-note restore is implemented through the private writer and requires an
explicit target folder:

```bash
  swift run apple notes restore --id NOTE_ID --folder FOLDER_ID --dry-run --json
```

The command uses restore-only include-deleted `ICNote` lookup for preflight,
then `ICNote.unmarkForDeletion`, target `ICFolder` placement, the same private
save path as text mutations, and `NotesMutationVerifier` readback. Normal
list/search/read remain visible-note only. A successful execution must prove
identity preservation, visible readback, destination folder/account,
title/body preservation, tag-set preservation, and optional store-object
evidence. Trash, Smart Folder, system folder, and read-only folder targets are
rejected.

Bounded restore-all is implemented as a dynamic-selection lifecycle mutation
over restorable private-framework notes:

```bash
  swift run apple notes restore-all --folder FOLDER_ID --dry-run --json
```

The command lists currently deleted/trashed notes through the same restore-only
read path used by empty-trash, refuses batches above the 2,000-note safety
bound, and restores every preflight target to one explicit editable concrete
folder through `ICNote.unmarkForDeletion`, target `ICFolder` placement, and the
private save path. Execution requires `--allow-destructive-selection` because
the target set is dynamic. Output returns affected counts and ID hashes, not
note titles or bodies. Successful execution must prove visible readback,
restore-only absence, destination folder/account, title/body preservation, and
tag-set preservation for every preflight target.

Single-note purge is implemented through the private writer for notes that are
already deleted or trashed:

```bash
  swift run apple notes purge --id NOTE_ID --dry-run --json
```

The command uses restore-only include-deleted `ICNote` lookup for preflight,
then `ICNote.purgeNote:`, the same private save path as text mutations, and
`NotesMutationVerifier` readback. Execution requires
`--allow-destructive-selection` because it permanently removes the selected
note. A successful execution must prove that visible readback and restorable
readback are both absent, with optional store-object evidence. Folder purge is
implemented separately; system-folder purge remains gated.

Empty trash is implemented as a bounded destructive-selection batch over
restorable private-framework notes:

```bash
  swift run apple notes empty-trash --dry-run --json
```

The command lists currently deleted/trashed notes through `ICNote.allNotes(inContext:)`
and `ICNote.isDeletedOrInTrash`, refuses batches above the 2,000-note safety
bound, then executes each permanent removal through the same `ICNote.purgeNote:`
private writer path as single-note purge. Execution requires
`--allow-destructive-selection`. Output returns affected counts and ID hashes,
not note titles or bodies. Successful execution must prove every preflight
target is absent from visible readback and restore-only readback.

Single-note pin and unpin are implemented through the private writer:

```bash
  swift run apple notes pin --id NOTE_ID --dry-run --json
  swift run apple notes unpin --id NOTE_ID --dry-run --json
```

The command reads `ICNote.isPinned` and `ICNote.isPinnable` before execution.
It calls `ICNote.changePinStatusIfPossible` only when the current state differs
from the requested state, then uses the same private save path as text
mutations. Successful execution must prove final note-state readback,
target pinned state, note identity preservation, title/folder/account
preservation, and optional store pinned evidence. Folder sort mutation is
supported separately by `folders sort`; folder date-header toggle is supported
separately by `folders date-headers`; `folders list` exposes current
date-header metadata as read-only evidence.

Multi-note lifecycle batches are implemented as bounded explicit-selection
wrappers over the same private single-note lifecycle writers:

```bash
  swift run apple notes batch pin --ids NOTE_ID,NOTE_ID --dry-run --json
  swift run apple notes batch move --ids NOTE_ID,NOTE_ID --folder FOLDER_ID --dry-run --json
  swift run apple notes batch delete --ids NOTE_ID,NOTE_ID --allow-destructive-selection --json
```

`--ids` must contain at least two unique note IDs. Batch pin/unpin read
`ICNote.isPinned` and `ICNote.isPinnable`, write only state changes through
the private pin writer, and verify final note-state readback for every selected
note. Batch move/copy validate one editable concrete target folder, then reuse
the private move/copy writer paths and verify destination folder/account plus
title/body/tag preservation. Batch delete requires
`--allow-destructive-selection`, reuses the private delete writer path, and
verifies selected-note absence. Dry-runs and results use note counts and ID
hashes instead of raw selected IDs, titles, or bodies; copy results also return
created-note ID hashes.

Folder hierarchy metadata listing is the promoted organization read slice:

```bash
  swift run apple notes folders list --json
```

The reader uses typed `ICFolder.visibleFolders(inContext:)` as the seed and
private `visibleSubFolders` / `recursiveVisibleSubfolders` hierarchy selectors
to emit a complete visible flat tree within the requested account/limit. Parent
folders are returned before children, object IDs are de-duplicated, and JSON
includes `returnedFolderCount`, `incompleteFolderCount`, and
`incompleteFolders` so callers can detect a limit-truncated or private-API
visibility-incomplete tree. Rows include folder identifiers, names, account
names, parent ID/presence, depth, type, visible-note counts, child-folder
counts, folder capability flags, `customNoteSortTypeValue`,
`supportsCustomNoteSortType`, structured `ICFolderCustomNoteSortType`
order/direction/default/ascending/resolved-order/description evidence, and
date-header state from `supportsDateHeaders` and `isShowingDateHeaders`.
It also records `dateHeadersType` as enum evidence for verifier readback. It
must not read or print note bodies and must not use `SQLiteReader`, AppleScript,
or fake folder data. Folder create, folder move, folder sort, and folder
date-header toggle use this state as verifier input. Future folder
purge and broader
reorganization commands must use the same readback model rather than direct
SQLite writes.

Single-folder create is implemented through the private writer:

```bash
  swift run apple notes folders create --name Planning --account ACCOUNT_ID --dry-run --json
  swift run apple notes folders create --name Planning --parent FOLDER_ID --dry-run --json
```

The writer uses typed `ICFolder.newFolderInAccount:`,
`ICFolder.newFolderInParentFolder:`, private title validation, the same private
save path as note mutations, and `NotesMutationVerifier` folder readback. A
successful execution must prove folder name, account, parent placement for
subfolders, and optional store-object evidence. Parent folders must be editable
concrete folders that allow subfolders. Folder move handles cross-account
placement separately.

Single-folder rename is implemented through the private writer:

```bash
  swift run apple notes folders rename --folder FOLDER_ID --name Projects --dry-run --json
```

The writer uses typed `ICFolder.isRenamable`, `ICFolder.isTitleValid:error:`,
title/date mutation, `ICFolder.updateChangeCountWithReason:`, the same private
save path as note mutations, and `NotesMutationVerifier` folder readback. A
successful execution must prove folder identity preservation, target name,
account preservation, parent preservation when the original folder has a
user-visible parent, and optional store-object evidence. Root/account-level
move is handled by `folders move --account`; cross-account parent/root moves
are supported with bounded descendant account readback. Folder purge is
supported for already-deleted purgable concrete folders.

Single-folder parent/root move is implemented through the private writer:

```bash
  swift run apple notes folders move --folder FOLDER_ID --parent PARENT_FOLDER_ID --dry-run --json

  swift run apple notes folders move --folder FOLDER_ID --account ACCOUNT_ID --dry-run --json
```

The writer uses typed `ICFolder.isMovable`, `ICFolder.parent`,
`ICFolder.account`, target-folder validation for `--parent`,
`ICFolder.updateChangeCountWithReason:`, the same private save path as note
mutations, and `NotesMutationVerifier` folder readback. `--parent` assigns the
target editable parent and adopts that parent's account; `--account` clears the
folder parent and places the folder at the selected account root. A successful
execution must prove folder identity preservation, name preservation, target
account, target parent or account root, bounded descendant account readback for
subtree moves, and optional store-object evidence.

Single-folder delete is implemented through the private writer:

```bash
  swift run apple notes folders delete --folder FOLDER_ID --dry-run --json
```

The writer uses typed `ICFolder.isDeletable`, `ICFolder.markForDeletion`,
`ICFolder.updateChangeCountWithReason:`, the same private save path as note
mutations, and `NotesMutationVerifier` folder readback. A successful execution
must prove that the folder no longer appears in visible folder readback and
include optional store-object evidence. The promoted path follows Notes'
Recently Deleted behavior for notes inside the folder.

Single-folder purge is implemented through the private writer for folders that
are already discoverable through Notes' purgable-folder request:

```bash
  swift run apple notes folders purge --folder FOLDER_ID --dry-run --json

  swift run apple notes folders purge --folder FOLDER_ID --allow-destructive-selection --json
```

The command resolves targets only from `ICFolder.purgableFoldersFetchRequest`,
rejects Trash, Smart Folder, system/default targets, requires
`--allow-destructive-selection`, calls `ICFolder.purgeFolder:`, uses the same
private save path as note mutations, and verifies that the folder is absent
from both visible folder readback and purgable-folder readback with optional
store-object evidence. System folder deletion and direct local database
deletion remain gated.

Single-folder date-header toggle is implemented through the private writer:

```bash
  swift run apple notes folders date-headers --folder FOLDER_ID --enabled true --dry-run --json
```

The writer uses typed `ICFolder.supportsDateHeaders`,
`ICFolder.isShowingDateHeaders`, `ICFolder.applyDateHeadersType:`,
`ICFolder.updateChangeCountWithReason:`, the same private save path as note
mutations, and `NotesMutationVerifier` folder readback. A successful execution
must prove folder identity preservation, date-header support, final
date-header visibility, final `dateHeadersType`, and optional store-object
evidence. The command toggles the current folder visibility state only.
Default/query date-header type preference customization is supported separately
by `settings group-by-date --scope default|query`.

Smart Folder workflow audit is a command-layer official-guide accounting
surface:

```bash
swift run apple notes smart-folders workflow audit --json
```

The command must not require a Smart Folder selector and must reject any
selector-like input before dispatch. It accounts for the current Apple Use
Smart Folders page as supported, delegated, gated, or rejected without calling
the Notes implementation, invoking AppleScript, reading `SQLiteReader`, or reading
Smart Folder/note data. Keep it distinct from `smart-folders audit`:
`smart-folders audit` is private criteria-family readback over existing Smart
Folders, while `smart-folders workflow audit` is static official workflow
coverage accounting. Its verifier must prove record-count consistency, create/
convert/edit/delete guide-section coverage, `backend_calls=none`, selector-free
execution, privacy boundaries, delegated UI routes, remaining gated semantics,
and rejected Apple product limitations. Untagged Notes Only belongs to the
supported criteria-construction bucket once `ICTagSelection.mode` 2 and
selected-tag count readback are verified; it is not a remaining gated workflow.
Promoted per-filter add, update, and remove semantics are supported through
`smart-folders filters add`, `smart-folders filters update`, and
`smart-folders filters remove`; those commands must reconstruct only accepted
private filter-selection criteria, rewrite the full criteria through the
private Smart Folder writer, verify ordinal delta plus matching-note readback,
and avoid raw folder, criteria, tag, or participant value leakage. Raw-only,
tag-selection, object-bound, or otherwise unreconstructable filters remain
explicit gated residuals.

Smart Folder filter catalog audit is separate command-layer catalog accounting:

```bash
swift run apple notes smart-folders filters audit --json
```

The command must not require a Smart Folder selector and must reject selector-like
input before dispatch. It must not call the Notes implementation, AppleScript, or
`SQLiteReader`. It accounts for the accepted private criteria writer catalog
and rejected private-catalog residuals without reading user Smart Folders: one
or more selected tags with All/Any-selected-tags semantics, Untagged Notes Only, promoted built-in/folder/date/participant/
mention criteria, combined All/Any private filter-selection/query-factory
criteria, and explicit rejected residuals for unsupported tag
operator/mode semantics, missing private tag hints, participant/mention
identity without hash evidence, raw/object-bound filters, and unreviewed
OS-specific filters. Runtime add/update/remove must still refuse existing
criteria that cannot be reconstructed from privacy-safe private readback before
writing. Its verifier must prove supported criteria set consistency
with `notesSmartFolderBuiltInCriteriaKinds`, official example family coverage,
installed private family accounting, rejected residual accounting,
selector-free execution, `backend_calls=none`, and privacy boundaries.

Attachment metadata listing is the first promoted attachment-family read slice:

```bash
  swift run apple notes attachments list --id NOTE_ID --json

  swift run apple notes attachments list --account ACCOUNT --json

  swift run apple notes attachments list --folder FOLDER --json

  swift run apple notes attachments list --account ACCOUNT --folder FOLDER --json

  swift run apple notes attachments list --folder FOLDER --family photo-video --json
```

With `--id`, the reader uses one typed `ICNote` attachment collection and emits
metadata only: attachment IDs, titles, type hints, content identifiers, file
sizes, media filenames, inline state, and deletion state. Without `--id`, the
command lists a bounded visible-note selection through the private Notes reader,
optionally under `--account` and/or `--folder`, calls the private attachment
metadata reader for each note, filters deleted or trash attachments from the
collection view, and returns per-note attachment metadata plus collection
verifier evidence. Account-scoped collection listing must dispatch through
`NotesAccountScopedListing`; `--id` is mutually exclusive with `--account` and
`--folder`.
`--family` narrows either single-note or collection output by metadata-derived
attachment categories. Supported aliases include `photo-video`, `photo-image`,
`video`, `scanned-document`/`scans`, `map-preview`/`maps`,
`webpage-preview`, `pdf`, `audio-recording`, `drawing-or-sketch`, `file`, and
`unknown`; unsupported family selectors must be rejected before any implementation
read and reported by hash. The collection verifier must prove scanned-note
bounds, notes-with-attachments counts, attachment counts, visible-attachment
filtering, family-count accounting, category-filter application, and
metadata-only batch readback. The command must not read note bodies, read
attachment bytes, call export paths, or expose local media paths.

Attachment metadata search is the promoted attachment-name/type search slice:

```bash
  swift run apple notes attachments search --account ACCOUNT --query QUERY --json

  swift run apple notes attachments search --folder FOLDER --query QUERY --json

  swift run apple notes attachments search \
    --id NOTE_ID \
    --family audio-recording \
    --query QUERY \
    --json
```

The command validates `--query` before implementation reads, rejects queries shorter
than two non-whitespace characters, and rejects unsupported `--family` selectors
before implementation reads. `--id` is mutually exclusive with `--account` and
`--folder`. Account/folder/global search scans bounded visible note summaries;
single-note search reads attachment metadata for the supplied note identifier
without calling note body/detail read paths. Search fields are title, media
filename, content identifier, type UTI, attachment type, and derived attachment
family. The verifier must prove query-hash/byte-count accounting, bounded scan,
account/folder selector dispatch, scanned attachment accounting, metadata field
accounting, visible attachment records only, family-filter application, and
metadata-only batch readback. The command must not read note bodies, read
attachment bytes, search inside arbitrary attachment file contents, call export
paths, or expose local media paths.

Attachment family audit is the promoted batch attachment/PDF/scan/audio
accounting slice:

```bash
  swift run apple notes attachments audit --account ACCOUNT --json

  swift run apple notes attachments audit --folder FOLDER --json
```

The command lists a bounded visible-note selection through the private Notes
reader, optionally under `--account` and/or `--folder`, and then calls the
existing private attachment metadata reader for each note. It classifies exposed
metadata into official Notes attachment families:
photos/images, videos, PDFs, scanned documents, drawings/sketches, audio
recordings, webpage previews, map previews, files, and unknown attachments. The verifier
must prove record counts, visible attachment counts, family counts,
extension/type count bounds, account/folder selector dispatch, raw UTI hash
accounting, delegated workflow families, gated mutation families, and the
privacy boundary. The result may
include note ID hashes, counts, extensions, and attachment type values; it must
not print note titles, note bodies, attachment titles, attachment filenames, raw
UTIs, local media paths, transcripts, or attachment bytes. It does not promote
scan capture, audio recording/transcription generation, or semantic Markup
tool-palette operations as private Notes model writes; those surfaces are
delegated to Notes.app/system capture, transcription, or interactive Markup UI.
It does not promote non-title attachment updates or richer transforms. Notes OCR artifact generation/search-index mutation and hash-only image classification summary readback are promoted through dedicated commands. Audio recording
append/edit UI is delegated to Notes.app, and arbitrary PDF content edit plus
transcript text edit are rejected as current Apple Notes product non-capabilities. Webpage preview add/update is promoted separately through typed
private URL attachment writes, attachment display-title rename is promoted
separately through typed `ICAttachment` metadata mutation, selected
scanned-document crop/rotation/filter/page move/delete are promoted separately through
`ICAttachment.croppingQuad`/`ICDocCamScannedDocumentEditor.setQuad`,
`setOrientation`, `applyFilter`, `movePageFromIndex`, and
`deletePagesAtIndexes`, ordinary PDF crop/rotate/move/delete is promoted
separately through direct-media `ICMedia.writeData` plus PDFKit page mutation,
audio
rename/save/delete is promoted separately through audio-family-gated private
attachment metadata/export/remove paths, Markup model inspection/export/apply
is promoted separately through `ICMarkupUtilities`, and existing audio
transcript read/export/copy-to-note/clipboard/search is promoted separately through private
audio-document readback.

Attachment/media workflow audit is a no-implementation command-layer accounting
surface over the current Apple Notes Add photos/PDFs/more, Manage PDFs/scans,
Mark up attachments, and View attachments guide pages:

```bash
  swift run apple notes attachments workflow audit --json
```

The command must reject note, attachment, file, and query selectors before any
implementation dispatch. It must not call the private Notes reader/writer, AppleScript,
or `SQLiteReader`, and it must not read note bodies, attachment metadata,
attachment bytes, local media paths, PDF text, OCR text, Markup model bytes, or
transcripts. The verifier must prove the 43-record accounting shape, the
23 supported private-framework families, 18 delegated UI/system/external-dispatch
families, 0 gated workflow gaps, the arbitrary PDF-content non-capability
rejection, the Exchange provider rejection, and `backend_calls=none`. This audit is the durable target-local place for official
attachment/media guide workflows that belong to Notes but are not yet, or
should not be, represented as direct private Notes framework commands.

Attachment add is the promoted attachment-family write slice for one local file
or a bounded batch:

```bash
  swift run apple notes attachments add \
    --id NOTE_ID \
    --file ./Brief.pdf \
    --name Brief.pdf \
    --dry-run \
    --json

  swift run apple notes attachments add \
    --id NOTE_ID \
    --files ./Photo.jpg,./Scan.pdf \
    --dry-run \
    --json
```

The writer resolves one visible editable note, validates that it is not
locked/password-protected, read-only, deleted, or in trash, and preflights all
source files before mutation. `--file` accepts one regular local file and can
pair with `--name`; `--files` accepts comma-separated paths, rejects `--name`,
is bounded to 32 files and 250 MB total, and rejects repeated source paths.
Execution is an ordinary Notes mutation, so it does not require
`--allow-artifact-action`. Each accepted source is written sequentially through
typed `ICNote.addAttachmentWithData:filename:` followed by the private save
path. The per-attachment verifier must prove attachment metadata readback,
filename preservation, attachment export byte count/SHA-256, and note readback.
The batch verifier additionally proves attachment count, unique attachment
result IDs, total byte count, per-attachment verifier success, target-note
preservation, and note readback before reporting success. Command results must
not print attachment bytes or promote local source paths into the persisted
Notes model.

Attachment copy is the promoted existing-attachment copy slice:

```bash
  swift run apple notes attachments copy \
    --id SOURCE_NOTE_ID \
    --attachment ATTACHMENT_ID \
    --target TARGET_NOTE_ID \
    --name Copied.pdf \
    --dry-run \
    --json
```

The command layer resolves a readable source note and selected source
attachment, exports bytes through the accepted private attachment export path,
validates the target note with the same visible/editable/non-trash/non-locked
mutation policy as attachment add, and writes the copied bytes through
`ICNote.addAttachmentWithData:filename:`. Source and target may be the same
note for explicit duplication. The verifier must prove source byte
count/SHA-256, new target attachment metadata, target export byte
count/SHA-256, target note readback, and hash-only source/target identity
evidence. Results must not print attachment bytes, source local media paths,
note bodies, or raw private identifiers.

Webpage preview add/update is the promoted webpage/map attachment mutation
slice:

```bash
  swift run apple notes attachments add-webpage \
    --id NOTE_ID \
    --url https://example.com/brief \
    --dry-run \
    --json

  swift run apple notes attachments update-webpage \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --url https://example.com/updated \
    --dry-run \
    --json
```

The add path creates one private URL attachment through
`ICNote.addURLAttachmentWithURL:`. The update path resolves one selected
webpage preview or map preview attachment from the private attachment collection, maps it
to the corresponding `ICInlineAttachment`, updates
`tokenContentIdentifier`/`altText`, calls `markDisplayTextNeedsUpdate`, and
saves through the private note context. The verifier must prove link metadata
readback, webpage-preview attachment metadata readback, attachment-family
preservation, URL hash replacement, selected identity preservation, and note
readback. It must refuse ordinary file/PDF/image/audio attachments,
non-preview links, unchanged URLs, non-web URLs, locked/protected notes,
read-only notes, deleted/trash notes, and ambiguous selectors.

Single attachment rename is the promoted attachment metadata-mutation slice:

```bash
  swift run apple notes attachments rename \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --name "Brief renamed.pdf" \
    --dry-run \
    --json
```

The writer resolves one selected attachment from one visible editable note,
validates that the note is not locked/password-protected, read-only, deleted,
or in trash, validates that the attachment is visible, not read-only, and
advertises `ICAttachment.supportsRenaming`, then updates typed
`ICAttachment.title` and `ICAttachment.userTitle`, calls attachment change
hooks, and saves through the private note context. Execution is an ordinary
Notes mutation and does not require `--allow-artifact-action`. The verifier
must prove selected attachment metadata readback, title hash readback,
old-title replacement, and note readback before reporting success. The command
does not replace attachment bytes or mutate the media filename.

Single attachment remove is the promoted attachment-family removal slice:

```bash
  swift run apple notes attachments remove \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --dry-run \
    --json
```

The writer resolves one selected attachment from one visible editable note,
validates that the note is not locked/password-protected, read-only, deleted,
or in trash, validates that the attachment is deletable and not already deleted,
and calls typed `ICAttachment.markForDeletion` followed by the private save
path. Execution is an ordinary Notes mutation and does not require
`--allow-artifact-action`. The verifier must prove attachment metadata absence,
attachment export absence, and note readback before reporting success. The
command result must not print attachment bytes.

Single raw attachment export is the first promoted attachment-family artifact
slice:

```bash
  swift run apple notes attachments export \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --output ./Attachment.bin \
    --dry-run \
    --json
```

The export reader resolves one attachment from the note's private-framework
attachment collection, reads bytes through typed `ICAttachment`/`ICMedia`
data APIs, and leaves filesystem writes in the command layer. Execution
requires `--allow-artifact-action`, refuses existing destination files, writes
atomically, and verifies destination existence, byte count, SHA-256, and
attachment metadata readback before reporting success. It must not print
attachment bytes or source local media paths. Broader non-title attachment
update, broader
Markup edit/write workflows beyond model apply, raw page snapshot generation controls, preview image refresh
controls, and richer transforms remain gated; scan capture, audio
recording/transcription generation, and audio recording append/edit UI are
delegated system or Notes.app surfaces. Transcript text edit is rejected as a
current Apple Notes product non-capability.
Existing audio rename/save/delete, audio transcript
read/export/copy-to-note/clipboard/search, and Markup model inspection/export/apply are promoted
separately.

Single attachment generated/fallback PDF export and embedded PDF text search
are the promoted PDF/scan attachment read slices:

```bash
  swift run apple notes attachments export-pdf \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --output ./Attachment.pdf \
    --dry-run \
    --json

  swift run apple notes attachments pdf search \
    --account ACCOUNT \
    --query QUERY \
    --json

  swift run apple notes attachments pdf inspect \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --json

  swift run apple notes attachments scan inspect \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --json

  swift run apple notes attachments pdf search \
    --id NOTE_ID \
    --query QUERY \
    --json
```

The export reader resolves one selected attachment from the private attachment
collection and accepts PDF data from existing `ICMedia` bytes when already
present, `ICAttachmentCryptoStrategy.decryptedFallbackPDFData`, or
`ICAttachmentPaperBundleModel.generateFallbackPDFDataForAttachment:`, and can
also read a generated document-camera PDF URL from
`ICDocCamPDFGenerator.generatePDFURLForAttachment:` or
`ICDocCamPDFGenerator.pdfURLForAttachment:`. Filesystem writes stay in the
command layer. Execution requires
`--allow-artifact-action`, accepts only `.pdf` destinations, refuses existing
destination files, writes atomically, and verifies destination existence, byte
count, SHA-256, `%PDF` header, source kind, and attachment metadata readback
before reporting success. It must not print attachment bytes or source local
media paths.

The PDF text search reader scans one selected note or a bounded visible-note
selection, optionally limited by `--account` and/or `--folder`, filters visible
PDF and scanned-document attachments, reads PDF bytes through the same private
PDF media/fallback/generated path, and extracts embedded text through PDFKit.
`--id` is mutually exclusive with `--account` and `--folder`. Result JSON must
report only query SHA-256/byte count, scanned-note and scanned-attachment
counts, scanned/skipped PDF attachment counts, note/attachment metadata, PDF
source kind, PDF byte count/SHA-256, text source kind, page count, extracted-text
byte count/SHA-256, match count, and verifier evidence. It must not print the
raw query, extracted PDF text, attachment bytes, scan image data, or local media
paths. Existing scan searchable text is supported separately by
`attachments scan search`; recognized-text artifact export/generation is
supported separately by `attachments recognized-text export` and `attachments
recognized-text generate`; PDF search itself does not OCR image-only scans, and
`attachments recognized-text index` supports selected-attachment search indexing through the private CoreSpotlight reindexer.

The PDF/scan inspect reader resolves one selected attachment and returns only
privacy-safe readback evidence: PDF byte count/SHA-256/page count/source kind
when PDF data is available, orientation value/hash, scan metadata
presence/count/hash, document-camera PDF version evidence, source kinds,
accepted-family proof, and attachment metadata readback. `pdf inspect` accepts
PDF or scanned-document attachments; `scan inspect` requires scanned-document
evidence. It must not print PDF text, scan images, crop geometry, attachment
bytes, local media paths, or raw private objects. Selected scanned-document
crop/rotation/filter/page move/delete are supported separately through private scan
writers, and ordinary PDF crop/rotate/move/delete is supported separately
through the direct-media PDF writer; selected recognized-text search indexing is supported separately by `attachments recognized-text index`, while arbitrary PDF content edit is rejected as a product non-capability.

Visual-content attachment search commands read existing private searchable text:

```bash
apple notes attachments scan search --query "receipt" --json
apple notes attachments image search --account ACCOUNT_ID --query "diagram" --json
apple notes attachments drawing search --id NOTE_ID --query "whiteboard" --json
```

These commands validate `--query` and selector shape, keep `--id` mutually
exclusive with `--account`/`--folder`, scan a bounded visible-note selection,
filter to scanned-document, photo/image, or drawing/sketch attachment families,
and call `NotesAttachmentReading.readAttachmentSearchableText`. The private
reader may use `ICAttachment.searchableTextContent`,
`ICAttachment.searchableTextContentWithoutTitle`,
`ICAttachment.attachmentModel.searchableTextContent`,
`ICAttachment.attachmentModel.searchableTextContentForLocation`,
`ICAttachment.attachmentModel.searchableTextContentInNote`,
`ICAttachment.attachmentModel.additionalIndexableTextContentInNote`, and
`ICAttachment.attachmentModel.textContentInNote`. Result JSON must report only
query SHA-256/byte count, scanned-note and scanned-attachment counts,
candidate/skipped counts, note/attachment metadata, content source kind,
content byte count/SHA-256, match counts, and verifier evidence. It must not
print raw query text, raw searchable text, OCR text, attachment bytes, scan image
data, image pixels, drawing bytes, handwriting strokes, note bodies, local media
paths, or transcript text. `notes search attachment-content` composes this
readback with accepted metadata, PDF text, and audio transcript slices.
Generated recognized-text artifacts are supported separately by `attachments
recognized-text generate`; hash-only image classification summary readback is supported through
`attachments image objects`, and `attachments recognized-text index` supports selected-attachment search indexing through the private CoreSpotlight reindexer.

Recognized-text artifact export/generation reuses the accepted private
searchable-text reader or private attachment media/PDF readback for one selected
scanned-document, photo/image, or drawing/sketch attachment:

```bash
apple notes attachments recognized-text export --id NOTE_ID --attachment ATTACHMENT_ID --family image --output ./recognized.txt --dry-run --json
apple notes attachments recognized-text export --id NOTE_ID --attachment ATTACHMENT_ID --output ./recognized.txt --allow-artifact-action --json
apple notes attachments recognized-text generate --id NOTE_ID --attachment ATTACHMENT_ID --family scan --output ./recognized.txt --dry-run --json
apple notes attachments recognized-text generate --id NOTE_ID --attachment ATTACHMENT_ID --output ./recognized.txt --allow-artifact-action --json
apple notes attachments recognized-text index --id NOTE_ID --attachment ATTACHMENT_ID --family image --dry-run --json
apple notes attachments recognized-text index --id NOTE_ID --attachment ATTACHMENT_ID --allow-persistent-action --json
```

Artifact commands must validate `--id`, `--attachment`, and `.txt` `--output`;
`--family scan|image|drawing` is optional and must be verified against the
selected attachment family. For non-dry-run artifact execution, the command must
require `--allow-artifact-action` before any filesystem write. Dry-run may read
the private searchable text or private media/PDF bytes to produce hash-only
normalized arguments. Execution writes only the explicit artifact, then verifies
destination existence, byte count, SHA-256, accepted attachment family, supported
source kind, and fresh private readback. Result JSON must not contain raw
recognized text, scan images, image bytes, drawing bytes, note bodies,
attachment bytes, local media paths, or raw private objects.

`attachments recognized-text index` must not write a text artifact. It validates
the same selected scan/image/drawing family, requires
`--allow-persistent-action` for execution, calls the private CoreSpotlight
reindexer with the attachment Core Data object URI, and verifies selector
preservation, object URI SHA-256 presence, accepted implementation call, completion
status, and privacy boundary without printing raw Core Data URIs or recognized
text. These commands do not support arbitrary attachment-content export or image
object understanding.

Existing audio title/save/delete is the promoted existing-audio operation
slice over private attachment primitives:

```bash
  swift run apple notes attachments audio rename \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --name "Team recording.m4a" \
    --dry-run \
    --json

  swift run apple notes attachments audio save \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --output ./Team.m4a \
    --dry-run \
    --json

  swift run apple notes attachments audio delete \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --dry-run \
    --json
```

These commands reuse the accepted private attachment title, media export, and
remove paths, but first require the selected attachment to classify as the
`audio_recording` family from private attachment metadata. Rename verifies
title readback, save writes selected audio bytes only to a user-directed
artifact with `--allow-artifact-action` and verifies byte count/SHA-256, and
delete verifies metadata/export absence. Command JSON must not print audio
bytes, transcript text, or local media paths.

Existing audio transcript read/export/copy-to-note/clipboard/search is the promoted audio transcript
readback, copy-to-note, delegated clipboard copy, and bounded-search slice:

```bash
  swift run apple notes attachments audio transcript \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --json

  swift run apple notes attachments audio transcript \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --content summary \
    --output ./Summary.txt \
    --dry-run \
    --json

  swift run apple notes attachments audio copy-transcript \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --target TARGET_NOTE_ID \
    --content transcript \
    --dry-run \
    --json

  swift run apple notes attachments audio copy-transcript \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --scope clipboard \
    --content transcript \
    --dry-run \
    --json

  swift run apple notes attachments audio search \
    --query "follow up" \
    --content all \
    --json

  swift run apple notes attachments audio search \
    --account ACCOUNT \
    --query "follow up" \
    --content all \
    --json

  swift run apple notes attachments audio search \
    --id NOTE_ID \
    --query "readback" \
    --content transcript \
    --json
```

The reader resolves one selected audio attachment from the private attachment
collection and reads existing audio-document text through
`ICAttachment.audioModel.audioDocument` or
`ICAttachment.attachmentModel.audioDocument`, using
`ICTTAudioDocument.transcriptAsPlainText`,
`ICTTAudioDocument.recordingSummaryAsPlainText`,
`ICTTAudioDocument.topLineSummaryAsPlainText`, and
`ICTTAudioDocument.transcriptVersion`. Command JSON reports presence, byte
counts, SHA-256 hashes, transcript version, source kind, and verifier evidence
only. It must not print transcript or summary text unless the user explicitly
requests an artifact with `--output`. Artifact execution requires a new `.txt`
destination and `--allow-artifact-action`; the verifier checks destination
existence, byte count, SHA-256, and attachment metadata readback.

The copy paths reuse the same audio-document readback. `--scope note` is the
default and uses the accepted private note append writer. `--id` selects the
source note containing the audio attachment; `--target` selects the note that
receives the copied existing transcript-family text and defaults to `--id`.
Command-layer validation requires the target note to be visible, editable,
non-trash, and not password-protected or read-only shared. The note verifier
checks audio-document readback, copied text byte count/SHA-256, target note
identity, target body suffix readback, attachment metadata readback, and
target-body hash accounting. `--scope clipboard` refuses `--target`, performs a
delegated system pasteboard write through `NotesClipboardWriting`, requires
`--allow-persistent-action` for execution, and verifies clipboard text readback,
clipboard SHA-256, change-count evidence, audio-document readback, and
attachment metadata readback. Results must not print copied transcript text,
target note body, or clipboard text.

The search reader scans either one selected note or a bounded visible-note
selection, optionally limited by `--account` and/or `--folder`, lists each
note's private attachment metadata, filters to audio-recording attachments, and
reads existing audio-document text through the same `ICTTAudioDocument` paths.
`--id` is mutually exclusive with `--account` and `--folder`. It accepts
transcript, recording-summary, top-line-summary, or all content kinds. Result
JSON must report only query SHA-256 and byte count, scanned-note and
scanned-audio-attachment counts, skipped audio-document counts, note/attachment
metadata, per-content-kind match counts, byte counts, SHA-256 hashes,
transcript version, source kind, and verifier evidence. It must not print the
raw query, transcript text, summary text, or top-line summary text. Audio
attachments without an existing
audio-document transcript are skipped and counted rather than turning a bounded
search into a fatal failure. The read/export/copy-to-note/clipboard/search commands do not record
audio, trigger new transcription generation, mutate transcript content, or edit
audio. Only `copy-transcript --scope clipboard` writes the delegated system
clipboard surface.

Markup model inspection/export/apply is the promoted narrow Markup model slice
for existing Markup model data:

```bash
  swift run apple notes attachments markup inspect \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --json

  swift run apple notes attachments markup inspect \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --output ./Attachment.markupdata \
    --dry-run \
    --json

  swift run apple notes attachments markup edit \
    --id NOTE_ID \
    --attachment ATTACHMENT_ID \
    --file ./Attachment.markupdata \
    --dry-run \
    --json
```

The private reader resolves one selected attachment, reads its media bytes
through the accepted `ICMedia` data paths, and invokes
`ICMarkupUtilities.markupModelDataFromData:`. Result JSON reports only
attachment byte count/SHA-256, Markup model presence, Markup model byte
count/SHA-256 when present, source kind, and verifier evidence. Artifact export
requires `--allow-artifact-action`, refuses existing destinations, writes
atomically in the command layer, and verifies destination existence, byte count,
SHA-256, and attachment metadata readback. The command must not print
attachment bytes, Markup bytes, source local media paths, or note bodies.
`attachments markup edit --file MODEL` reads one user-provided Markup model
file, applies it to a selected PDF, scanned-document, or image attachment with
`ICMarkupUtilities.applyMarkupModelData`, and verifies the same Markup model
byte count/SHA-256 through private readback. It does not call
`applyReturnedMarkupURL:attachment:completionBlock:`, embed/extract returned
Markup URLs, or implement semantic Notes UI filter, shape, signature,
style/color/text-style, Continuity annotate, or drawing tools.
Those Markup tool surfaces are delegated to the interactive Markup UI rather
than treated as stable Notes private-framework data writers.

`attachments audio audit` is the read-only command-layer accounting surface for
the Apple Notes audio guide. It must not call the Notes implementation, AppleScript, or
`SQLiteReader`, and it must reject note/attachment selectors. Result JSON
records workflow families for recording, playback, audio edit, transcript,
summary, save/share/delete, and Apple Intelligence summary generation with
supported, delegated, or rejected status. The verifier checks record
counts, accepted existing-audio commands, delegated playback/share/Apple
Intelligence surfaces, delegated recording/transcription/append surfaces, the
rejected transcript-edit non-capability, no gated audio data edits,
selector-free execution, and `backend_calls=none`.

Selected scanned-document crop, rotation, filter, page move, and page delete are
supported private mutations. Crop writes `ICAttachment.croppingQuad` scalar
fields and calls `ICDocCamScannedDocumentEditor.setQuad`; rotation uses
`ICDocCamScannedDocumentEditor.setOrientation`; filter uses
`ICDocCamScannedDocumentEditor.applyFilter`; page move/delete use
`ICDocCamScannedDocumentEditor.movePageFromIndex` and
`ICDocCamScannedDocumentEditor.deletePagesAtIndexes`. The verifier checks
before/after `ICAttachment.croppingQuad`, `ICAttachment.orientation`,
`ICAttachment.imageFilterType`, PDF page count, PDF hash, or scanned-document
metadata hash readback and must not print scan images, PDF text, attachment
bytes, crop geometry, local media paths, or raw private objects:

```bash
apple notes attachments scan crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left 0.10,0.12 --top-right 0.91,0.10 --bottom-right 0.88,0.93 --bottom-left 0.08,0.90 --json
apple notes attachments scan crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left 0.05,0.05 --top-right 0.95,0.05 --bottom-right 0.95,0.95 --bottom-left 0.05,0.95 --dry-run --json
apple notes attachments scan rotate --id NOTE_ID --attachment ATTACHMENT_ID --by 90 --json
apple notes attachments scan rotate --id NOTE_ID --attachment ATTACHMENT_ID --direction right --dry-run --json
apple notes attachments scan filter --id NOTE_ID --attachment ATTACHMENT_ID --style grayscale --json
apple notes attachments scan filter --id NOTE_ID --attachment ATTACHMENT_ID --style photo --dry-run --json
apple notes attachments scan page move --id NOTE_ID --attachment ATTACHMENT_ID --from 1 --to 3 --json
apple notes attachments scan page delete --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 2 --dry-run --json
```

Ordinary PDF page rotate, move, and delete are a separate direct-media PDF
writer slice. The command resolves one editable visible non-password-protected
note, requires the selected attachment to read back as directly writable
ordinary PDF media, mutates a `PDFDocument`, persists the resulting bytes through
`ICMedia.writeData`, refreshes attachment metadata/previews, and verifies PDF
page count, crop/rotation or order/delete hash delta, PDF SHA-256 readback,
attachment metadata, and note readback without printing PDF text, page images,
attachment bytes, local media paths, or raw private objects:

```bash
apple notes attachments pdf crop --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 1 --top-left 0.10,0.10 --top-right 0.90,0.10 --bottom-right 0.90,0.85 --bottom-left 0.10,0.85 --dry-run --json
apple notes attachments pdf page rotate --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 1 --direction right --json
apple notes attachments pdf page move --id NOTE_ID --attachment ATTACHMENT_ID --from 1 --to 3 --dry-run --json
apple notes attachments pdf page delete --id NOTE_ID --attachment ATTACHMENT_ID --ordinal 2 --json
```

Embedded PDF text search, ordinary PDF crop/rotate/move/delete, selected
scanned-document crop/rotation/filter/page move/delete, existing
scan/image/drawing searchable-text search, existing recognized-text artifact
export, inline image-description alt-text read/write, existing audio
title/save/delete, and transcript read/export/copy-to-note/clipboard/search are
supported separately. Image-description read/write uses private
`ICInlineAttachment.altText` for one selected inline image-family attachment,
normalizes empty descriptions as clears, and verifies readback with byte-count
and SHA-256 evidence only:

```bash
apple notes attachments image description get --id NOTE_ID --attachment ATTACHMENT_ID --json
apple notes attachments image description set --id NOTE_ID --attachment ATTACHMENT_ID --description DESCRIPTION --json
```

Direct image crop/rotate is supported separately from Markup model editing. The
writer resolves one editable visible non-password-protected note, requires the
selected attachment to read back as photo/image media, reads private media bytes,
uses ImageIO/CoreGraphics for an axis-aligned normalized crop or quarter-turn
rotation, persists the transformed bytes through `ICMedia.writeData`, refreshes
attachment metadata, and verifies image byte-count plus SHA-256 delta readback,
attachment metadata, and note readback without printing image pixels, crop
geometry, attachment bytes, local media paths, or raw private objects:

```bash
apple notes attachments image crop --id NOTE_ID --attachment ATTACHMENT_ID --top-left 0.10,0.10 --top-right 0.90,0.10 --bottom-right 0.90,0.90 --bottom-left 0.10,0.90 --json
apple notes attachments image rotate --id NOTE_ID --attachment ATTACHMENT_ID --direction right --json
```

Remaining PDF, scan, visual-recognition, semantic Markup, and audio
generation/edit workflow intent is represented by explicit semantic unsupported
commands. Scan capture, audio recording, audio transcription generation, and
semantic Markup element/style tools are delegated; remaining private media
semantic gaps stay gated until
capability-specific private operation proof is accepted:

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

Each command validates required selectors, then returns
`unsupported_operation` with `status: delegated` and a `delegated_surface` for
scan/audio generation, audio recording append, Markup tool-palette, and
Continuity annotate surfaces; with `status: gated` and a `future_gate` for
remaining private media semantic gaps; or with `status: rejected` and a
`product_limit` for transcript edit. Delegated responses use
`required_implementation: delegated_notes_app_or_system_surface` and
`required_verifier: delegated_ui_or_system_accounting`; gated responses use
`required_implementation: typed_private_notes_framework` and
`required_verifier: private_framework_attachment_readback+media_operation_delta`;
rejected responses use `required_implementation: not_applicable` and
`required_verifier: official_product_limitation_accounting`.
All responses report `backend_calls: none`. The command layer must not call the Notes implementation
and must not echo note IDs, attachment IDs, output paths, raw recognized text,
object prompts, style/color values, Markup text,
signature identifiers, selection text, device names, local media paths,
transcript text, or attachment bytes in
refusal details. Actual capture/record/transcribe generation behavior remains
delegated to Notes.app/system surfaces; semantic Markup element/style tools and
Continuity annotate remain delegated to Markup or nearby-device UI. Edit
behavior and arbitrary attachment-content semantics beyond the accepted composite search slices remain gated until typed
private attachment/media mutation or search/index proof plus readback
verification exists. Hash-only image classification summary readback is already supported through `attachments image objects`. Existing searchable-text scan/image/drawing search, recognized-text
artifact export/generation, inline image-description alt-text read/write, Markup model
inspection/export/apply, direct image crop/rotate, and transcript
read/export/copy-to-note/clipboard/search are supported
separately and must not be treated as proof for broader Markup UI transforms or
generating/editing transcripts.

Export audit is the read-only family accounting surface for note-level export,
print, and Pages handoff behavior:

```bash
  swift run apple notes export audit \
    --id NOTE_ID \
    --json
```

The command resolves one selected note through the private-framework read path,
reads `NotesNoteStateRecord` through `NotesNoteStateReading`, and emits hash-only
note/title identity plus records for accepted PDF, Markdown single-file/package,
HTML single-file/package, RTF, RTFD, accepted package resource preservation,
delegated print, delegated Pages handoff, the dedicated locked-content export
path, selected note-state gates, and rejected unbounded conversion-fidelity
residuals.
For password-protected notes already unlocked in the current Notes session,
artifact exporters are accounted as supported and protected-note print/Pages
handoff are accounted as delegated. Still-locked password-protected notes keep
ordinary note-level exporters gated, while `state export-locked-content` is
accounted as supported when execution supplies a passphrase source.
It must not call `NotesNoteExporting`, write artifacts, submit external
dispatch, print note body/title/folder/account values, or use AppleScript or
`SQLiteReader`. Verification checks record-count consistency, Apple
PDF/Markdown/print/Pages accounting, private HTML/RTF/RTFD accounting, delegated
dispatch accounting, selected-note-state gating including session-unlocked
protected artifact and external-dispatch support, authenticated
locked-content-export accounting, artifact-action gate accounting, residual
export-family accounting, rejected residual accounting, and the hash-only
privacy surface.

Single-note PDF export is the first promoted note-level export artifact slice:

```bash
  swift run apple notes export pdf \
    --id NOTE_ID \
    --output ./Note.pdf \
    --dry-run \
    --json
```

The reader resolves one visible note through the private-framework read path,
rejects deleted, trashed, still-locked, and unknown locked-state notes, then
generates PDF bytes with typed `NotesEditor.ICMPrintController.init(note:frame:)`
and `pdfRepresentation()`. Password-protected notes are accepted only when
already unlocked in the current Notes session. Filesystem writes remain in the
command layer. Execution requires `--allow-artifact-action`, refuses existing
destinations, requires a `.pdf` path, writes atomically, suppresses protected
note title/body in JSON/stdout, and verifies destination existence, byte count,
SHA-256, PDF header, protected-state boundary, and note readback before
reporting success. Unlisted richer export/import formats, ordinary note-level
export for currently locked notes, protected-note external dispatch, and
attachment PDF/scan generation remain gated. Dedicated locked-content plaintext
export is covered by `state export-locked-content`.

Single-note print is a delegated external-dispatch slice over the private PDF
generator:

```bash
  swift run apple notes print \
    --id NOTE_ID \
    --printer PRINTER_NAME \
    --dry-run \
    --json
```

The command resolves one visible non-password-protected note or one
password-protected note already unlocked in the current Notes session through
the private-framework read path, rejects deleted, trashed, and still-locked
notes, validates the named printer, and generates PDF bytes with the same
`NotesEditor.ICMPrintController` path used by `export pdf`. Execution requires
`--allow-external-dispatch` and submits the generated PDF bytes to the system
print service. The result must verify PDF header, byte count, SHA-256, selected
printer, submitted job ID, protected external-dispatch boundary, and note
readback before reporting success. Protected note title/body are suppressed in
JSON/stdout.

Single-note open in Pages is a delegated external-dispatch slice over the
private RTFD exporter:

```bash
  swift run apple notes open-in-pages \
    --id NOTE_ID \
    --dry-run \
    --json
```

The command resolves one visible non-password-protected note or one
password-protected note already unlocked in the current Notes session through
the private-framework export path, rejects deleted, trashed, and still-locked
notes through the RTFD exporter, normalizes the generated RTFD package file
list, and records file count, total byte count, and tree SHA-256 in dry-run
output. Execution requires `--allow-external-dispatch`, stages the RTFD package
in a temporary directory, dispatches it to Pages, and verifies application name,
staged path hash, file count, total byte count, tree SHA-256, RTF member
presence, protected external-dispatch boundary, and note readback before
reporting success. Protected note title/body are suppressed in JSON/stdout. It
does not create a user-requested persistent artifact; use `export rtfd` for
durable package export.

Single-note Markdown export is promoted for both single-file output without
packaged resources and explicit attachment-resource package output:

```bash
  swift run apple notes export markdown \
    --id NOTE_ID \
    --output ./Note.md \
    --dry-run \
    --json

  swift run apple notes export markdown \
    --id NOTE_ID \
    --output ./Note.mdpkg \
    --include-attachments \
    --dry-run \
    --json
```

The reader resolves one visible note through the private-framework read path,
rejects deleted, trashed, still-locked, and unknown locked-state notes.
Password-protected notes are accepted only when already unlocked in the current
Notes session. It converts the attributed body through typed
`NotesUI.ICMarkdownRepresentation.createMarkdownString(from:context:rangeMapping:)`
with `NotesUI.ICMarkdownString.stringWithMarkdownStyles(fromAttributedString:withContext:)`
as fallback and returns UTF-8 Markdown bytes to the command layer. When
`--include-attachments` is present, exportable attachment resources are read
through typed private Notes media APIs and written under a `Resources/` package
subtree.

Filesystem writes remain in the command layer. Single-file execution
requires `--allow-artifact-action`, refuses existing destinations, requires a
`.md` or `.markdown` path, writes atomically, and verifies destination
existence, byte count, SHA-256, UTF-8/nonempty Markdown, protected-state
boundary, and note readback.
Attachment-resource package execution requires `.mdpkg` or
`.markdownpackage`, writes the package atomically, and verifies directory
existence, file count, total byte count, tree SHA-256, Markdown member,
attachment resource count, attachment policy, protected-state boundary, and note readback before
reporting success. Package resource import and single-file relative image
resource import are supported separately by `import markdown --include-attachments`;
ordinary note-level export for currently locked notes and attachment PDF/scan
generation remain gated. Dedicated locked-content plaintext export is covered
by `state export-locked-content`. Accepted package resource preservation is
supported through Markdown package verification, while
unbounded perfect conversion fidelity is rejected by `export audit` as a
non-current-guide guarantee.
RTF/RTFD/HTML rich import and ENEX note/normalized-tag/resource attachment import are
supported separately by `import rtf`, `import rtfd`, `import html`, and
`import enex`.

Markdown import is promoted for single-file semantic import, single-file
relative image resource import, and explicit attachment-resource package
round-trip:

```bash
  swift run apple notes import markdown \
    --folder FOLDER_ID \
    --file ./Note.md \
    --dry-run \
    --json

  swift run apple notes import markdown \
    --folder FOLDER_ID \
    --file ./Note.md \
    --include-attachments \
    --dry-run \
    --json

  swift run apple notes import markdown \
    --folder FOLDER_ID \
    --file ./Note.mdpkg \
    --include-attachments \
    --dry-run \
    --json
```

Single-file import accepts one regular UTF-8 `.md` or `.markdown` file, derives
the default title from the first `# ` heading or filename, converts Markdown
through `NotesUI.ICMarkdownRepresentation` with a Foundation Markdown fallback,
writes the attributed body through typed private `ICNote.textStorage`, and
verifies note readback, title/folder readback, nonempty imported plain text,
body-structure readback, semantic heading/list accounting when present, and
attributed-run accounting.
When `--include-attachments` is explicit for a regular Markdown file, local
relative inline image destinations under the Markdown file directory are
preflighted, imported through the same private
`ICNote.addAttachmentWithData:filename:` writer used by `attachments add`, and
verified by attachment metadata/export-hash readback. Remote or schemed URLs,
protocol-relative paths, absolute paths, parent-directory escapes, symlinks,
hidden files, non-regular files, empty files, oversized resources, and
duplicate attachment filenames are rejected before mutation.
Package import requires explicit `--include-attachments` and accepts only
`.mdpkg` or `.markdownpackage` directories with exactly one main `.md` or
`.markdown` member outside `Resources/`. Any additional files must be direct
children of `Resources/`; symbolic links, duplicate resource filenames, empty
resources, nested resources, hidden files, and unsafe relative paths are
rejected or ignored as appropriate before mutation. The command writes the main
Markdown member through the semantic Markdown import path, then imports each
resource through the same private `ICNote.addAttachmentWithData:filename:`
writer used by `attachments add`.

The Markdown import verifier aggregates `NotesMutationVerifier` created-note
readback with per-resource attachment metadata/export-hash verification when
resources are present. Result output records package mode, main Markdown
relative path when applicable, source byte count/body hash, semantic counts,
imported plain-text hash/length, attributed-run count, package file count,
package total byte count, package tree SHA-256, resource count, attachment
metadata, and verification evidence. It must not print imported body text or
resource bytes. This is a semantic Markdown import plus resource round-trip
contract for packages produced by `export markdown --include-attachments` and
for local relative inline image references in regular Markdown files.

Single-note TXT import is the promoted official text import slice:

```bash
  swift run apple notes import text \
    --folder FOLDER_ID \
    --file ./note.txt \
    --dry-run \
    --json
```

The command accepts one regular UTF-8 `.txt` file, bounds file size, derives the
default title from the filename when `--title` is absent, and builds the same
semantic create draft used by the private note creation path. Dry-run output
records source path, source name, byte count, and SHA-256 but must not print the
imported body. Execution creates the note through the accepted private writer
and requires `NotesMutationVerifier` readback before reporting success.

RTF, RTFD, and HTML rich import are promoted private writer slices:

```bash
  swift run apple notes import rtf \
    --folder FOLDER_ID \
    --file ./Note.rtf \
    --dry-run \
    --json

  swift run apple notes import rtfd \
    --folder FOLDER_ID \
    --file ./Note.rtfd \
    --dry-run \
    --json

  swift run apple notes import html \
    --folder FOLDER_ID \
    --file ./Note.html \
    --dry-run \
    --json

  swift run apple notes import html \
    --folder FOLDER_ID \
    --file ./Note.htmlpkg \
    --include-attachments \
    --dry-run \
    --json
```

The command layer accepts one regular `.rtf`, `.html`, or `.htm` file or one
`.rtfd` package. `import html --include-attachments` additionally accepts one
strict `.htmlpkg` or `.htmlpackage` directory with exactly one root `.html` or
`.htm` member plus direct `Resources/` files. The command layer bounds the
read and records source byte count, source SHA-256 for the rich body member,
source-path SHA-256, source-name SHA-256, package file count, resource file
count, total byte count, package tree SHA-256, and resource count without
printing the raw source path, file name, source body text, package resource
bytes, or imported note body. Execution converts the source to
`NSAttributedString`, writes the resulting attributed content through
`ICNote.textStorage` and the private Notes save path, imports HTML package
resources through the private attachment writer, and verifies created-note
readback, title/folder preservation, nonempty rich text, body-structure
readback, format-family accounting, package tree/size/resource accounting, HTML
package attachment export hashes, and privacy redaction before reporting
success.
ENEX note/normalized-tag/resource attachment import with inline body-position placement is
supported separately by `import enex`; Markdown semantic import is supported
separately by `import markdown`.

Rich replace is the promoted in-place body replacement path for existing notes:

```bash
  swift run apple notes replace markdown \
    --id NOTE_ID \
    --file ./Reorganized.mdpkg \
    --include-attachments \
    --dry-run \
    --json

  swift run apple notes replace html \
    --id NOTE_ID \
    --file ./Reorganized.htmlpkg \
    --include-attachments \
    --dry-run \
    --json

  swift run apple notes replace rtf \
    --id NOTE_ID \
    --file ./Reorganized.rtf \
    --dry-run \
    --json

  swift run apple notes replace rtfd \
    --id NOTE_ID \
    --file ./Reorganized.rtfd \
    --dry-run \
    --json
```

The command layer resolves one existing visible editable note, refuses locked,
password-protected, deleted/trash, non-editable, and shared read-only targets,
preserves title unless `--title` is supplied, parses the external source through
the same Markdown/rich source validators used by import, and dispatches a
`NotesRichReplaceDraft` to the rich replacer. The writer converts Markdown,
HTML, RTF, or RTFD to attributed Notes content and replaces the selected note
body through `ICNote.textStorage` and the private save path. It must not create
a replacement note, change the selected note ID, or write through SQLite.

Markdown and HTML package resources are not appended blindly. Before rich
conversion, local relative references are replaced with stable markers. After
conversion, the writer locates each marker, removes it, writes the resource
through the private attachment writer, and inserts the resulting attachment at
the marker text location with `ICAttachmentInsertionController`. Remote URLs
remain links. RTFD relies on attributed attachment runs produced by the rich
conversion path. The verifier must prove note identity preservation, imported
plain-text hash/length, attributed-run count, attachment-run count, resource
count, inline reference/placement counts, marker absence, per-resource
attachment metadata/export-hash readback, and privacy redaction. Results must
not print source paths, source body text, target note body text, package
resource bytes, local media paths, or raw private identifiers.

ENEX import with supported tag, attachment resource preservation, and inline
resource reference accounting is promoted for one bounded `.enex` source:

```bash
  swift run apple notes import enex \
    --folder FOLDER_ID \
    --file ./Evernote.enex \
    --dry-run \
    --json
```

The command-layer parser bounds file size, note count, tag count, resource
count, and decoded resource byte size. It extracts ENEX note
title/content/tag/date/resource metadata, decodes base64 resource payloads,
normalizes resource filenames, parses inline `<en-media>` references, matches
each reference to one decoded resource by ENEX resource MD5, and keeps dry-run
output to source path/name hashes, byte count, note count, tag count,
normalized tag count, resource count, resource byte count, inline resource
reference count, matched reference count, and unmatched reference count.
Execution validates the parsed source before any mutation, normalizes
whitespace-bearing tags to single-word Notes tag text, and refuses unmatched
inline media references, unsupported resource payloads, and parse failures. Accepted notes
are written through `ICNote.textStorage` and the private Notes save path;
normalized tags are applied through `ICHashtag` membership APIs; ENEX resources
are imported through `ICNote.addAttachmentWithData:filename:` and placed at
their converted ENEX body locations through `ICAttachmentInsertionController`.
Verification checks supported resource payloads, supported tag shape, inline
resource reference matching, imported note count, note/title/folder/tag
readback, per-resource inline reference counts, per-resource inline placement
counts, inline attachment readback, per-resource attachment metadata/export-hash
readback, optional created/updated date preservation, and privacy redaction.

Folder-preserve import is promoted for one bounded source directory tree:

```bash
  swift run apple notes import folder \
    --folder FOLDER_ID \
    --file ./NotesExport \
    --name Imported \
    --dry-run \
    --json
```

The command layer preflights the full source tree before mutation, rejects
unsupported files or unsupported ENEX shapes, bounds total source bytes, records
source path/name hashes, source tree SHA-256, family counts, and
directory/file/note/resource counts, and never prints local paths, file names,
source body text, package resource bytes, ENEX resource bytes, or imported note
bodies. Execution requires `--allow-destructive-selection`, creates one import
root under the selected editable parent folder, recreates supported source
subdirectories below that root through the private folder writer, routes
supported TXT, Markdown, Markdown package, RTF, RTFD, HTML, and ENEX files
through their accepted private-framework-backed import paths, and verifies root
folder creation, subfolder creation, per-file import readback, aggregate counts,
family accounting, and privacy redaction before reporting success.

Import audit is the read-only family accounting surface for the Apple Notes
import baseline:

```bash
swift run apple notes import audit --file ./ImportFolder --json
```

The command accepts one source file or directory through `--file`, scans only
filesystem metadata, bounds returned records through the normal command limit,
and treats `.rtfd`, `.mdpkg`, and `.markdownpackage` directories as packages
rather than descending into their internals. It records path SHA-256, file-name
SHA-256, extension, byte count, source kind, format family, and import status.
It must not read source file contents, create Notes data, print raw local paths
or file names, or use AppleScript/SQLite. Verification checks record-count
consistency, accepted TXT/Markdown/Markdown-package/RTF/RTFD/HTML/ENEX
note-tag-resource family accounting, supported ENEX inline resource reference
accounting, supported folder-preserve import accounting, supported normalized ENEX tag accounting, and
the hash-only privacy surface.

Single-note HTML export supports both the promoted single-file HTML artifact
slice and explicit attachment-resource package export:

```bash
  swift run apple notes export html \
    --id NOTE_ID \
    --output ./Note.html \
    --dry-run \
    --json

  swift run apple notes export html \
    --id NOTE_ID \
    --output ./Note.htmlpkg \
    --include-attachments \
    --dry-run \
    --json
```

The reader resolves one visible note through the private-framework read path,
rejects deleted, trashed, still-locked, and unknown locked-state notes, and
refuses notes whose private attachment collection is non-empty unless the
command has explicit `--include-attachments`. Password-protected notes are
accepted only when already unlocked in the current Notes session. Accepted
notes call typed
`ICNote.htmlString(withAttachments: false)` by default or
`ICNote.htmlString(withAttachments: true)` for the explicit resource request,
then return UTF-8 HTML bytes plus direct private attachment resource files to
the command layer. Filesystem writes remain in the command layer. Execution
requires `--allow-artifact-action`, refuses existing destinations, writes either
a `.html` file or a `.htmlpkg`/`.htmlpackage` directory atomically, and verifies
file byte count/SHA-256/HTML marker or package file count/total byte count/tree
SHA-256/HTML member/resource count, attachment-policy preservation, and note
readback plus protected-state boundary before reporting success. Protected note
title/body are suppressed in JSON/stdout. External non-package resource
preservation, ordinary note-level export for currently locked notes, and
attachment PDF/scan generation remain gated. Dedicated locked-content plaintext
export is covered by `state export-locked-content`.

Single-note RTF member export is a strict single-file artifact slice over the
private RTFD exporter:

```bash
  swift run apple notes export rtf \
    --id NOTE_ID \
    --output ./Note.rtf \
    --dry-run \
    --json
```

The reader resolves one visible note through the private-framework read path,
rejects deleted, trashed, still-locked, and unknown locked-state notes, obtains
`FileWrapper` package output with typed
`NotesUI.ICShareNoteExporter.fileWrapper(forNote:)`, and extracts RTF bytes
only when the package contains exactly one RTF file and no other resources.
Password-protected notes are accepted only when already unlocked in the current
Notes session.
If the package contains attachments or other files, the command must refuse
with guidance to use `export rtfd` so content is not silently dropped.
Filesystem writes remain in the command layer. Execution requires
`--allow-artifact-action`, refuses existing destinations, requires a `.rtf`
path, writes atomically, and verifies destination existence, byte count,
SHA-256, RTF header, protected-state boundary, and note readback before
reporting success. Protected note title/body are suppressed in JSON/stdout.
RTF single-file resource-loss boundaries, ordinary note-level export for
currently locked notes, and attachment PDF/scan generation remain gated.
Dedicated locked-content plaintext export is covered by
`state export-locked-content`. Accepted package resource preservation is
supported through
Markdown/HTML/RTFD package verification, while unbounded perfect conversion
fidelity is rejected by `export audit` as a non-current-guide guarantee.

Single-note RTFD package export is the first promoted rich note package export
slice:

```bash
  swift run apple notes export rtfd \
    --id NOTE_ID \
    --output ./Note.rtfd \
    --dry-run \
    --json
```

The reader resolves one visible note through the private-framework read path,
rejects deleted, trashed, still-locked, and unknown locked-state notes, then obtains
`FileWrapper` package output with typed
`NotesUI.ICShareNoteExporter.fileWrapper(forNote:)`. Password-protected notes
are accepted only when already unlocked in the current Notes session. The
private reader recursively expands the wrapper into safe relative paths plus
bytes; filesystem writes remain in the command layer. Execution requires
`--allow-artifact-action`, refuses existing destinations, requires a `.rtfd`
package path, writes through a temporary sibling package, and verifies
destination directory existence, file count, total byte count, tree SHA-256,
RTF member presence, protected-state boundary, and note readback. Protected note
title/body are suppressed in JSON/stdout. Tree verification resolves symlinks
before deriving relative paths so `/var` and `/private/var` temporary-directory
spellings do not create false verifier failures. HTML resource packages and
RTFD package resources are supported through package verification; RTF
single-file resource-loss boundaries, ordinary note-level export for currently
locked notes, and attachment PDF/scan generation remain gated. Dedicated
locked-content plaintext export is covered by `state export-locked-content`.

Open-in-Pages is a delegated external-dispatch slice over the private RTFD
exporter:

```bash
  swift run apple notes open-in-pages \
    --id NOTE_ID \
    --dry-run \
    --json
```

The command resolves one visible non-password-protected note or one
password-protected note already unlocked in the current Notes session through
the private-framework export path, obtains the same normalized RTFD package
files used by `export rtfd`, and records file count, total byte count, and tree
SHA-256 in dry-run output. Execution requires `--allow-external-dispatch`; the
dispatcher stages the RTFD package under a temporary directory, calls the system
open service for Pages, and returns only application name, staged path hash,
file count, total byte count, tree SHA-256, and protected-state flags.
Verification checks Pages dispatch metadata, staged-path hash presence, package
file count, total bytes, tree hash, RTF member presence, protected
external-dispatch boundary, and note readback. The command must not print RTFD
package bytes, protected note title/body, or raw staging paths. The staging
package is intentionally not deleted immediately because Pages may still need
to read it after `open -a Pages` returns.

Official Links workflow accounting is selector-free:

```bash
swift run apple notes links audit --json
```

The command accounts for the current Apple "Add links in Notes on Mac" guide
page without resolving a note, reading link metadata, mutating link records,
calling AppleScript, or using `SQLiteReader`. It reports supported semantic
private-framework paths for link metadata, destination resolution, backlinks,
web/app/note/paragraph link add, edit, remove, selected-text URL conversion, and
explicit note-link display-text/title-sync semantics. It reports Notes.app/macOS
menu and keyboard flows, Smart Links, note-link typeahead, active-app capture,
Quick Note thumbnails, link-color appearance settings, and legacy OS
compatibility as delegated. Passing
`--id`, `--link`, `--url`, `--target`, `--text`, or other selectors must fail
validation before implementation access, and error details must list option names
only, not raw note IDs, URLs, or selected text.

Link metadata listing is the first promoted link-family read slice:

```bash
  swift run apple notes links list --id NOTE_ID --json
```

The reader uses typed `ICNote.allNoteTextInlineAttachments` and inline
attachment link metadata. It emits identifiers, kind, display/alt text, safe
public URL strings, URL schemes, and hashes. Public `http`, `https`, `mailto`,
`tel`, and `sms` URLs may be printed for explicit `links list`; local file URLs
and internal Notes link tokens must be represented by scheme/hash rather than
raw paths or raw internal identifiers.

Backlink metadata listing is the paired promoted link-family read slice:

```bash
  swift run apple notes links backlinks --id TARGET_NOTE_ID --json
```

The reader resolves the target note, calls typed
`ICInlineAttachment.enumerateLinksToNote:batchSize:visibleOnly:saveAfterBatch:context:usingBlock:`,
and reads each incoming link's source note through `ICBaseAttachment.note`. The
result includes source note summaries and the existing privacy-safe
`NotesLinkRecord` shape. It must not print source or target note bodies, raw
local file/app URLs, paragraph UUIDs, or raw internal link tokens. Richer
target-note resolution remains gated.

Privacy-safe link destination resolution is the promoted read slice for one
selected link:

```bash
  swift run apple notes links resolve --id NOTE_ID --link LINK_ID --json
```

The reader resolves the source note, maps the selector back to one
`ICInlineAttachment`, and uses `ICAppURLUtilities.noteIdentifierFromNotesAppURL:`
and `ICAppURLUtilities.paragraphIDForURL:` for internal Notes destinations.
The result may print public web URLs, but app/file destinations return only
scheme and SHA-256 evidence. Internal note and paragraph destinations return
target note identity/hash and paragraph hash evidence without raw internal
tokens, raw paragraph UUIDs, paragraph titles, target note bodies, raw app URLs,
or raw local file URLs. Verification rereads the selected link, destination
note, backlink evidence for internal links, and paragraph hash evidence for
paragraph links before reporting success.

Single web URL link add is the first promoted link-family write slice:

```bash
  swift run apple notes links add \
    --id NOTE_ID \
    --url https://example.com/brief \
    --dry-run \
    --json
```

The writer resolves one visible editable note, validates that it is not
locked/password-protected, read-only, deleted, or in trash, accepts only
`http` and `https` URLs, and calls typed `ICNote.addURLAttachmentWithURL:`
followed by the private save path. Execution is an ordinary Notes mutation, so
it does not require `--allow-artifact-action`. The verifier must prove link
metadata readback, URL kind/scheme, and note readback before reporting success.

Single app URL link add is the promoted app-link write slice:

```bash
  swift run apple notes links add-app \
    --id NOTE_ID \
    --url podcasts://episode/ID \
    --dry-run \
    --json
```

The writer resolves one visible editable note, validates that it is not
locked/password-protected, read-only, deleted, or in trash, accepts only
non-web and non-file app URL schemes, and calls typed
`ICNote.addURLAttachmentWithURL:` followed by the private save path. The
dry-run and execution result must not print the raw app URL; they expose only
scheme and hash fields. The verifier must prove app-link metadata readback,
scheme/hash match, raw app URL absence, and note readback before reporting
success.

Single file URL link add is the promoted file-link creation slice:

```bash
  swift run apple notes links add-file \
    --id NOTE_ID \
    --file ./Brief.pdf \
    --dry-run \
    --json
```

The command resolves one visible editable note, validates that it is not
locked/password-protected, read-only, deleted, or in trash, accepts one existing
readable regular local file or directory path, and calls typed
`ICNote.addURLAttachmentWithURL:` with the normalized `file://` URL followed by
the private save path. The dry-run and execution result must not print the raw
local path or raw file URL; they expose only source kind, scheme, and hash
fields. The verifier must prove file-link metadata readback, file URL scheme,
URL hash match, raw file URL absence, source-kind evidence, and note readback
before reporting success.

Single note-to-note link add is the promoted internal Notes link write slice:

```bash
  swift run apple notes links add-note \
    --id SOURCE_NOTE_ID \
    --target TARGET_NOTE_ID \
    --text "Display text" \
    --dry-run \
    --json

  swift run apple notes links add-note \
    --id SOURCE_NOTE_ID \
    --target TARGET_NOTE_ID \
    --use-note-title \
    --dry-run \
    --json
```

The writer resolves one visible editable source note and one visible
non-password-protected target note, then calls typed
`ICInlineAttachment.newLinkAttachmentToNote:fromNote:parentAttachment:`
followed by optional `ICInlineAttachment.altText` mutation and
`ICInlineAttachment.markDisplayTextNeedsUpdate` before the private save path.
`--text` stores custom display text through private alt-text state;
`--use-note-title` clears custom alt text so Notes derives display text from the
target note title. Execution is an ordinary Notes mutation and does not require
`--allow-artifact-action`. The verifier must prove link metadata readback,
note-link kind, source note readback, target note readback, target identity, and
optional display-text hash/source-kind evidence before reporting success. The
command/result surface does not print target note title/body, custom display
text, or raw internal link tokens. Raw internal-token output remains gated.

Single note-to-note link update is the promoted ordinary Notes link retarget
slice:

```bash
  swift run apple notes links update-note \
    --id SOURCE_NOTE_ID \
    --link LINK_ID \
    --target TARGET_NOTE_ID \
    --text "Display text" \
    --dry-run \
    --json

  swift run apple notes links update-note \
    --id SOURCE_NOTE_ID \
    --link LINK_ID \
    --target TARGET_NOTE_ID \
    --use-note-title \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one ordinary note-to-note link, rejects paragraph/internal links, then
resolves the object back to `ICInlineAttachment` from
`ICNote.allNoteTextInlineAttachments()`. The writer resolves the old target
from the selected link's Notes app URL, calls typed
`ICInlineAttachment.changeLinkDestinationFromNote:toNote:` when the target note
changes, mutates optional `ICInlineAttachment.altText`, marks display text as
needing update, and saves through the private save path. `--text` can update only
custom display text while leaving the target note unchanged; `--use-note-title`
clears custom alt text so Notes derives display text from the target note title.
The verifier must prove selected note-link metadata readback, selected-link
identity preservation, note-link kind, source note readback, target note
readback, target identity, target-or-display-text change, target backlink
readback, old-target backlink absence when retargeted, and optional display-text
hash/source-kind evidence before reporting success. The command/result surface
does not print target note title/body, custom display text, or raw internal link
tokens. Raw internal-token output remains gated.

Single paragraph note-link add is the promoted paragraph-link write slice:

```bash
  swift run apple notes body structure \
    --id TARGET_NOTE_ID \
    --json

  swift run apple notes links add-paragraph \
    --id SOURCE_NOTE_ID \
    --target TARGET_NOTE_ID \
    --paragraph PARAGRAPH_ID_SHA256 \
    --dry-run \
    --json
```

The reader enumerates `ICNote.attributedString()` paragraph style objects,
hashes `ICTTParagraphStyle.uuid`, and records paragraph title byte count/hash
from `ICNote.titleForParagraphID:` without printing raw paragraph UUIDs,
paragraph titles, or body text. The resolver maps
`paragraphAnchors[].idSHA256` back to the local paragraph ID only inside the
implementation. The writer then calls typed
`ICInlineAttachment.newLinkAttachmentToNote:paragraphID:paragraphName:fromNote:parentAttachment:`
followed by the private save path. The verifier must prove paragraph-link
metadata readback, source note readback, target note readback, and target
paragraph identity by hash before reporting success. Raw internal-token output
remains gated.

Single paragraph note-link update is the promoted paragraph-link retarget slice:

```bash
  swift run apple notes body structure \
    --id TARGET_NOTE_ID \
    --json

  swift run apple notes links update-paragraph \
    --id SOURCE_NOTE_ID \
    --link LINK_ID \
    --target TARGET_NOTE_ID \
    --paragraph PARAGRAPH_ID_SHA256 \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one paragraph or internal paragraph link, rejects ordinary note-to-note
and web/file/app links, then resolves the object back to `ICInlineAttachment`
from `ICNote.allNoteTextInlineAttachments()`. The target paragraph resolver
maps `paragraphAnchors[].idSHA256` back to the local paragraph ID only inside
the implementation. The writer parses the old paragraph-link destination from the
selected link token, builds the new private paragraph URL through
`ICAppURLUtilities.appURLForNote:paragraphID:`, updates the selected
attachment's `tokenContentIdentifier` and `altText`, marks display text as
needing update, optionally calls
`ICInlineAttachment.changeLinkDestinationFromNote:toNote:` when the target note
changes, and saves through the private save path. The verifier must prove
selected paragraph-link metadata readback, selected-link identity preservation,
paragraph-link kind, source note readback, old target note readback, target
note readback, target paragraph identity, target token hash replacement, target
backlink readback, and old-target backlink absence when the target note changes
before reporting success. The command/result surface does not print raw
paragraph UUIDs, paragraph titles, target note bodies, or raw internal link
tokens.

Single web URL link update is the promoted edit-link write slice:

```bash
  swift run apple notes links update \
    --id NOTE_ID \
    --link LINK_ID \
    --url https://example.com/revised \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one `http` or `https` URL link, rejects unchanged URLs, then resolves the
object back to `ICInlineAttachment` from
`ICNote.allNoteTextInlineAttachments()`. The writer checks
`ICInlineAttachment.isLinkAttachment`, rejects paragraph/internal links, checks
web URL scheme evidence, `isVisible`, and `markedForDeletion`, then updates
typed `ICInlineAttachment.tokenContentIdentifier`, `ICInlineAttachment.altText`,
calls `ICInlineAttachment.markDisplayTextNeedsUpdate`, and saves through the
private save path. The verifier proves link metadata readback, selected-link
identity, new URL hash, old URL replacement, and note readback before reporting
success. File links use `links update-file`; ordinary note links use
`links update-note`; paragraph links use `links update-paragraph`; raw
internal-token output remains gated.

Single app URL link update is the promoted app-link edit slice:

```bash
  swift run apple notes links update-app \
    --id NOTE_ID \
    --link LINK_ID \
    --url podcasts://episode/NEW_ID \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one app URL link, rejects unchanged URLs by hash, then resolves the object
back to `ICInlineAttachment` from `ICNote.allNoteTextInlineAttachments()`. The
writer checks `ICInlineAttachment.isLinkAttachment`, rejects
paragraph/internal links, checks app URL scheme evidence, `isVisible`, and
`markedForDeletion`, then updates typed
`ICInlineAttachment.tokenContentIdentifier`, `ICInlineAttachment.altText`,
calls `ICInlineAttachment.markDisplayTextNeedsUpdate`, and saves through the
private save path. Dry-run and execution output must not print the raw app URL;
they expose only scheme and hash fields. The verifier proves app-link metadata
readback, selected-link identity, new URL hash, raw app URL absence, old URL
replacement, and note readback before reporting success. File links use
`links update-file`; ordinary note links use `links update-note`; paragraph
links use `links update-paragraph`; raw internal-token output remains gated.

Single file URL link update is the promoted file-link edit slice:

```bash
  swift run apple notes links update-file \
    --id NOTE_ID \
    --link LINK_ID \
    --file ./NewBrief.pdf \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one file URL link, validates one existing readable regular local file or
directory path, rejects unchanged URLs by hash, then resolves the object back to
`ICInlineAttachment` from `ICNote.allNoteTextInlineAttachments()`. The writer
checks `ICInlineAttachment.isLinkAttachment`, rejects paragraph/internal links,
checks file URL scheme evidence, `isVisible`, and `markedForDeletion`, then
updates typed `ICInlineAttachment.tokenContentIdentifier`,
`ICInlineAttachment.altText`, calls
`ICInlineAttachment.markDisplayTextNeedsUpdate`, and saves through the private
save path. Dry-run and execution output must not print the raw local path or raw
file URL; they expose only scheme and hash fields. The verifier proves file-link
metadata readback, selected-link identity, new URL hash, raw local file URL
absence, source-kind evidence, old URL replacement, and note readback before
reporting success.
Ordinary note links use `links update-note`; paragraph links use
`links update-paragraph`; raw internal-token output remains gated.

Single paragraph note-link remove is the paired paragraph-link removal slice:

```bash
  swift run apple notes links remove-paragraph \
    --id NOTE_ID \
    --link LINK_ID \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one paragraph or internal paragraph link, rejects ordinary note-to-note
and web/file/app links, then resolves the object back to `ICInlineAttachment`
from `ICNote.allNoteTextInlineAttachments()`. The writer checks paragraph-link
selector evidence, `isVisible`, `markedForDeletion`, and `isDeletable`, then
calls typed `ICInlineAttachment.markForDeletion` followed by the private save
path. The verifier proves selected link metadata absence, paragraph-link kind,
selected-link identity, and note readback before reporting success. Raw
paragraph UUIDs and raw internal link tokens remain gated; web, app, file, and
ordinary note links use their dedicated removal commands.

Single note-to-note link remove is the paired internal Notes link removal
slice:

```bash
  swift run apple notes links remove-note \
    --id NOTE_ID \
    --link LINK_ID \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one ordinary note-to-note link, rejects paragraph/internal links, then
resolves the object back to `ICInlineAttachment` from
`ICNote.allNoteTextInlineAttachments()`. The writer checks
`ICInlineAttachment.isLinkAttachment`, ordinary note-link scheme evidence when
available, `isVisible`, `markedForDeletion`, and `isDeletable`, then calls
typed `ICInlineAttachment.markForDeletion` followed by the private save path.
The verifier proves selected link metadata absence, note-link kind,
selected-link identity, and note readback before reporting success. Paragraph
links are handled separately by `links remove-paragraph`; app, file, and web
links use their dedicated removal commands. Raw internal-token output remains
gated.

Single web URL link remove is the paired promoted link-family removal slice:

```bash
  swift run apple notes links remove \
    --id NOTE_ID \
    --link LINK_ID \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one `http` or `https` URL link, then resolves the object back to
`ICInlineAttachment` from `ICNote.allNoteTextInlineAttachments()`. The writer
checks `ICInlineAttachment.isLinkAttachment`, rejects paragraph/internal links,
checks `isVisible`, `markedForDeletion`, and `isDeletable`, then calls typed
`ICInlineAttachment.markForDeletion` followed by the private save path. The
verifier proves selected link metadata absence, URL kind/scheme, and note
readback before reporting success. File URL removal is handled separately by
`links remove-file`; app URL removal is handled separately by
`links remove-app`; web URL update is handled separately by `links update`; app
URL update is handled separately by `links update-app`; file URL update is
handled separately by `links update-file`. Backlinks and generic non-web link
update beyond app/file URLs remain gated.

Single app URL link remove is the paired promoted app-link removal slice:

```bash
  swift run apple notes links remove-app \
    --id NOTE_ID \
    --link LINK_ID \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one app URL link, then resolves the object back to `ICInlineAttachment`
from `ICNote.allNoteTextInlineAttachments()`. The writer checks
`ICInlineAttachment.isLinkAttachment`, rejects web/file and Notes internal
links, checks app URL scheme evidence, `isVisible`, `markedForDeletion`, and
`isDeletable`, then calls typed `ICInlineAttachment.markForDeletion` followed
by the private save path. The verifier proves selected link metadata absence,
app-link kind, selected-link identity, and note readback before reporting
success. Raw app URLs remain gated.

Single file URL link remove is the paired promoted file-link removal slice:

```bash
  swift run apple notes links remove-file \
    --id NOTE_ID \
    --link LINK_ID \
    --dry-run \
    --json
```

The command resolves the selected link through `links list` metadata, accepts
only one file URL link, then resolves the object back to `ICInlineAttachment`
from `ICNote.allNoteTextInlineAttachments()`. The writer checks
`ICInlineAttachment.isLinkAttachment`, rejects paragraph/internal links, checks
file URL scheme evidence, `isVisible`, `markedForDeletion`, and `isDeletable`,
then calls typed `ICInlineAttachment.markForDeletion` followed by the private
save path. The verifier proves selected link metadata absence, file URL scheme,
selected-link identity, and note readback before reporting success. Raw local
file URLs are not printed; app URL removal is handled separately by
`links remove-app`.

Smart Folder metadata listing, criteria resolution/explanation/audit,
matching-note summary reads, per-note membership reasoning, single-tag
creation, single-tag criteria update, typed built-in/folder/date/participant/mention/Untagged criteria
creation/update, criteria duplicate/copy,
raw criteria artifact export/import, single rename, and single delete are the
promoted Smart Folder slices:

```bash
  swift run apple notes smart-folders list --json
  swift run apple notes smart-folders notes --folder Focus --account ACCOUNT_ID --json
  swift run apple notes smart-folders criteria --folder Focus --account ACCOUNT_ID --json
  swift run apple notes smart-folders explain --folder Focus --account ACCOUNT_ID --json
  swift run apple notes smart-folders reasoning --folder Focus --account ACCOUNT_ID --json
  swift run apple notes smart-folders audit --account ACCOUNT_ID --json
  swift run apple notes smart-folders create --name Focus --account ACCOUNT_ID --tag Work,Urgent --match any --dry-run --json
  swift run apple notes smart-folders update --folder Focus --account ACCOUNT_ID --tag Work,Urgent --match all --dry-run --json
  swift run apple notes smart-folders create-criteria --name Pinned --account ACCOUNT_ID --criteria pinned --dry-run --json
  swift run apple notes smart-folders create-criteria --name Work --account ACCOUNT_ID --criteria folder --criteria-folder Work --dry-run --json
  swift run apple notes smart-folders create-criteria --name WorkOrArchive --account ACCOUNT_ID --criteria folder,unlocked --criteria-folder Work,Archive --dry-run --json
  swift run apple notes smart-folders create-criteria --name WorkNotArchive --account ACCOUNT_ID --criteria folder,not-folder --include-criteria-folder Work --exclude-criteria-folder Archive --dry-run --json
  swift run apple notes smart-folders create-criteria --name SharedWithPerson --account ACCOUNT_ID --criteria participants --participant-user-id PARTICIPANT_USER_ID --dry-run --json
  swift run apple notes smart-folders update-criteria --folder Mentions --account ACCOUNT_ID --criteria mentions --participant-user-id PARTICIPANT_USER_ID --dry-run --json
  swift run apple notes smart-folders create-criteria --name FocusedShared --account ACCOUNT_ID --criteria pinned,shared,participants --participant-user-id PARTICIPANT_USER_ID --dry-run --json
  swift run apple notes smart-folders create-criteria --name MathPinned --account ACCOUNT_ID --criteria math,pinned --dry-run --json
  swift run apple notes smart-folders update-criteria --folder Pinned --account ACCOUNT_ID --criteria system-paper --dry-run --json
  swift run apple notes smart-folders duplicate --folder Focus --account ACCOUNT_ID --name FocusCopy --dry-run --json
  swift run apple notes smart-folders copy-criteria --from Focus --to Archive --account ACCOUNT_ID --dry-run --json
  swift run apple notes smart-folders export-criteria --folder Focus --account ACCOUNT_ID --output ./Focus.criteria.json --dry-run --json
  swift run apple notes smart-folders import-criteria --folder Archive --account ACCOUNT_ID --file ./Focus.criteria.json --dry-run --json
  swift run apple notes smart-folders rename --folder Focus --account ACCOUNT_ID --name Archive --dry-run --json
  swift run apple notes smart-folders delete --folder Focus --account ACCOUNT_ID --dry-run --json
```

The reader uses typed `ICFolder.visibleFolders(inContext:)`, filters
`isSmartFolder`, and emits Smart Folder identifiers, names, account names,
descriptions, editable state, visible-note counts, query JSON length/hash
evidence, and privacy-safe criteria summaries from `ICQuery` filter/tag
selection readback. It must not print raw `smartFolderQueryJSON`, raw filter
values, tag names, folder identifiers, participant identifiers, or private
class names. `smart-folders criteria` resolves one visible Smart Folder by
name/account, returns its privacy-safe criteria summary with bounded
matching-note summary readback, and verifies identity, query presence/hash,
criteria kind/filter/tag-selection preservation, matching-note readback, and
visible-note count bounds without printing raw criteria JSON, raw filter
values, raw tag names, note bodies, folder identifiers inside criteria, or
private class names. `smart-folders explain` uses the same readback boundary to
return privacy-safe query kind, filter count, multi-condition status,
supported-read-family accounting, and gated-mutation-family accounting for one
Smart Folder without printing raw criteria JSON, raw filter values, raw tag
names, note bodies, folder identifiers inside criteria, or private class
names. `smart-folders audit` lists visible Smart Folders and aggregates
criteria-family evidence across them: query/criteria summary counts,
multi-condition counts, predicate/tag-selection counts, filter-kind counts,
raw-value hash counts, supported read families, gated mutation families, and
readback verification. It does not fetch matching notes and does not print raw
criteria JSON, raw filter values, raw tag names, note bodies, folder
identifiers inside criteria, or private class names. `smart-folders reasoning`
uses the same criteria explanation plus private Smart Folder note readback to
return one privacy-safe membership evidence record per returned matching note,
including criteria families, partial per-filter state/body-structure/
attachment-metadata/note-tag evidence for tags, pinned, shared, locked,
attachment, checklist, folder, date, math, call, system-paper, participants, and mentions filters,
tag-selection reason evidence when present, single included-tag positive hash
matches and default-operator included/excluded tag-set hash matches where
private criteria hints and note tag metadata align, accepted folder/not-folder
object hash comparison, explicit date-parameter semantic comparison for
on/before/after/between/relative criteria, supported-filter boolean-trace
evidence for multi-condition matches, semantic raw-value/inclusion readback
for accepted state, attachment/checklist selection, and known date filters,
participant-count readback for participant filters through note-state evidence,
mention attachment-count readback through body-structure evidence, selected
participant identity hash comparison when criteria and note-state participant
hashes align, selected mentioned-participant hash comparison when criteria and
mention attachment hashes align, and gated-reasoning families for
raw-value comparison without semantic readback, unsupported operator/mode tag
comparison, missing-hint tag comparison, participant/mention identity
comparison when private hash evidence is unavailable, broader mention
object-bound comparison, object-bound criteria beyond accepted folder/not-folder
and accepted tag-set hints, and arbitrary/full multi-condition comparison
beyond supported-filter trace,
without printing note bodies, raw criteria JSON, raw filter values, raw tag
names, raw criteria folder identifiers, raw date criteria values, participant
identifiers, or private class names. The boolean trace records join operator,
condition/filter counts, proved/failed/unknown counts, tag-selection proof
status, all-known pass status, and trace gates; `verified` traces clear the
`multi_condition_boolean_trace` gate, while partial traces keep it.
`smart-folders notes`
resolves one visible Smart Folder by
name/account, then uses `listSmartFolderNotes` over the folder's visible note
collections to return note summaries, returned-note count, and visible-note
count without printing note bodies or raw criteria internals. The create path
supports one or more existing visible tags in one account through
`ICTagSelection`, `ICTagSelection.addObjectID`, explicit `mode=all_tagged`,
All/Any `tagOperator` readback,
`ICQuery.queryForNotes(matchingTagSelection:)`, and
`ICFolder.smartFolder(withQuery:titleComponents:account:)`, then verifies
folder identity, account, query presence, selected tag count, operator/mode,
matching-note count, and visible-note count when available. The update path
supports one editable Smart Folder selected by name/account and replaces its
criteria with one or more existing visible tags in the same account through
`ICTagSelection`, All/Any `tagOperator` readback,
`ICQuery.queryForNotes(matchingTagSelection:)`, and the writable
`ICFolder.smartFolderQuery` property. It verifies Smart Folder identity, name,
account, query presence, tag-selection criteria, selected tag count,
operator/mode, matching-note count, and visible-note count when available.

The built-in criteria path supports `pinned`, `unpinned`, `shared`,
`not-shared`, `folder`, `not-folder`, `untagged`, `math`, `call`,
`system-paper`, and
`recently-deleted-math` through typed `ICQuery` factories:
`ICQuery.query(forPinnedNotes:allowsRecentlyDeleted:)`,
`ICQuery.query(forSharedNotes:allowsRecentlyDeleted:)`,
`ICQuery.query(forMathNotesAllowsRecentlyDeleted:)`,
`ICQuery.query(forCallNotesAllowsRecentlyDeleted:)`,
`ICQuery.query(forSystemPaperNotesAllowsRecentlyDeleted:)`, and
`ICQuery.queryForRecentlyDeletedMathNotes()`. Single `untagged` criteria use
`ICTagSelection.initWithManagedObjectContext:mode:` with mode `2` (All
Untagged), require selected-tag count `0`, and build the query through
`ICQuery.queryForNotes(matchingTagSelection:)`; they are intentionally not
accepted in comma-separated criteria combinations until a private
filter-selection equivalent is proven. The path also supports `locked`,
`unlocked`, `quick-notes`, `not-quick-notes`, `attachments`,
`no-attachments`, `attachment-photo-video`, `attachment-scans`,
`attachment-drawings`, `attachment-maps`, `attachment-websites`,
`attachment-audio`, `attachment-documents`, `checklists`,
`incomplete-checklists`, `completed-checklists`, `no-checklists`,
`created-today`, `created-yesterday`, `created-last-7-days`,
`created-last-30-days`, `created-last-3-months`,
`created-last-12-months`, `created-on`, `created-before`, `created-after`,
`created-between`, `created-relative`, `edited-today`, `edited-yesterday`,
`edited-last-7-days`, `edited-last-30-days`, `edited-last-3-months`,
`edited-last-12-months`, `edited-on`, `edited-before`, `edited-after`,
`edited-between`, `edited-relative`, `participants`, and `mentions` through typed
`ICLockedNotesFilterTypeSelection`,
`ICQuickNotesFilterTypeSelection`, `ICAttachmentsFilterTypeSelection`,
`ICChecklistsFilterTypeSelection`, `ICFoldersFilterTypeSelection`,
`ICDateCreatedFilterTypeSelection`, `ICDateEditedFilterTypeSelection`,
`ICParticipantsFilterTypeSelection`, and `ICMentionsFilterTypeSelection`
wrapped in a private `ICFilterSelection` query. Comma-separated criteria are
supported when each kind can be represented by a private filter selection; the
writer extracts typed `ICFilterTypeSelection` objects from promoted
filter-selection paths and from the `math`, `call`, `system-paper`, and
`recently-deleted-math` query-factory paths, combines them with
`ICFilterSelection.initWithFilterTypeSelections(_:joinOperator:)`, and builds
the private query with `ICQuery.queryForNotes(matchingFilterSelection:)`.
The default `--match all` path writes join operator `1`; `--match any` writes
join operator `0`. The mutation verifier reads the Smart Folder criteria back
and records `criteria_join_operator` so All/Any scope is proven through private
framework evidence rather than command parsing alone.
Untagged verifier evidence is recorded separately with
`untagged_tag_selection_readback`, `untagged_tag_selection_mode`, and
`untagged_selected_tag_count`.
`recently-deleted-math` combinations preserve the dedicated criterion's
effective recently deleted scope. Single `folder` or `not-folder` criteria may
use `--criteria-folder FOLDER[,FOLDER...]`; combined
`folder,not-folder` criteria use `--include-criteria-folder` and
`--exclude-criteria-folder` so each folder filter has its own concrete visible
same-account folder set. Folder criteria use `ICFoldersFilterTypeSelection`,
and the writer passes all selected object identifiers for each filter through
`folderIdentifiers`. Parameterized date criteria set `primaryDate`,
`setSpecificDateRangeFrom:to:`, or `relativeRangeAmount` plus
`relativeRangeSelectionType` on the typed date selection. Participant and mention
criteria use `--participant-user-id` as an opaque private Notes participant
identifier, add it to the typed selection, and expose only SHA-256/count
evidence. Create uses
`ICFolder.smartFolder(withQuery:titleComponents:account:)`; update assigns the
new private query to writable `ICFolder.smartFolderQuery`, records the private
change reason, and saves through the same Notes private context path.
`--include-recently-deleted` is passed only to query factories or
filter-selection paths that accept that flag; `recently-deleted-math` rejects
the explicit flag because its factory already selects recently deleted math
notes. Both
commands verify query presence, privacy-safe built-in criteria readback,
criteria kind-list and filter-count readback for combined criteria,
tag-selection mode/count readback for single Untagged criteria,
attachment/checklist/date `selectionType` evidence where applicable, folder
selection count/inclusion evidence, date primary/secondary or relative-range
evidence where applicable, participant/mention selected-user count evidence,
matching-note count, and, for updates, Smart Folder identity/name/account
preservation. They
must not print raw criteria JSON, predicate text, raw filter values, note
bodies, raw criteria folder identifiers, participant identifiers, or private
class names.

The criteria reuse paths support duplicating one visible Smart Folder's existing criteria into a
new Smart Folder and copying one visible source Smart Folder's criteria onto
one editable same-account target Smart Folder. They reuse the source
`ICFolder.smartFolderQuery` without printing raw criteria JSON, then verify
source/target identity boundaries, source query presence, query kind, filter
count, predicate hash when available, tag-selection count when available,
matching-note count, and visible-note count when available without printing raw
criteria JSON, raw filter values, raw tag names, note bodies, or private class
names. The raw artifact path exports one visible Smart Folder's
`ICFolder.smartFolderQueryJSON` to a verified `.json` artifact only with
`--allow-artifact-action`, and imports one validated UTF-8 JSON artifact into
one editable Smart Folder through writable `ICFolder.smartFolderQueryJSON`.
Export verification checks artifact existence, byte count, SHA-256, JSON
readability, source query presence, and Smart Folder readback. Import
verification checks identity/name/account preservation, imported query hash and
length, criteria summary readback, and matching-note readback. Command JSON
must not print raw criteria JSON except in the explicit exported artifact. The
rename path
supports one editable Smart Folder selected by name/account, updates
`ICFolder.title`, sets `dateForLastTitleModification`, saves through the
private save path, and verifies identity, name, account, query hash
preservation, and visible-note count preservation when available. The delete path supports one editable Smart
Folder selected by name/account, uses `ICFolder.markForDeletion`, and verifies
visible removal without deleting matching notes. The reasoning path resolves one
visible Smart Folder, reads the matching notes through private Smart Folder
readback, reads private note state, body structure, attachment metadata, and
note tag metadata where needed for each returned note, and returns per-note membership evidence
plus criteria-family, filter-reason, and gated-reasoning-family accounting
without raw criteria output. Tag filters and tag selections return selected-tag
count, per-note tag count, single included-tag positive hash-match proof, and
default-operator included/excluded tag-set hash proof where private criteria
hints and note tag metadata align, while keeping unsupported operator/mode and
missing-hint tag comparison gated. Attachment filters produce family-count evidence
for generic/no-attachment, photo/video, scan, drawing, map preview, webpage
preview, audio, and document selection types. Checklist filters produce
total/open/done/no-checklist count evidence. Accepted folder/not-folder filters
compare private note-state folder IDs with internal-only criteria filter hints
or criteria hashes and report folder-object hash readback without printing raw
criteria folder identifiers. Explicit on/before/after/between/relative date
filters compare private note created/edited dates with internal-only date
criteria hints and report semantic date-parameter readback without printing raw
date criteria values. Pinned/shared/locked inclusion filters, accepted
attachment/checklist selection filters, and known date selections use semantic
criteria-summary fields to mark raw filter values as verified semantic values
instead of hash-only gates. Participant filters can report participant-count
readback from private note state and selected participant identity hash matches
when both the criteria filter and note-state participant metadata expose hashes;
they never print participant identifiers. Mention filters can report mention
attachment-count readback from private body structure and selected
mentioned-participant hash matches when both the criteria filter and mention
attachments expose hashes; they never print mention text or participant
identifiers.
Arbitrary user-editable Smart Folder criteria construction beyond promoted
private filter-selection/query-factory combinations and the single Untagged
tag-selection-mode path, participant/mention
identity comparison when private hash evidence is unavailable, broader mention
object-bound comparison, object-bound criteria beyond accepted folder/not-folder
and accepted tag-set hints, state criteria beyond accepted tag,
single Untagged, and promoted built-in/folder/date/participant/mention criteria, raw-value
comparison without semantic readback, remaining selected-tag
identifier/operator comparison, arbitrary/full multi-condition boolean tracing
beyond supported-filter trace, and affected-note evidence remain gated.
Supported-filter multi-condition reasoning is promoted separately through the
per-match `booleanTrace` summary and its verifier checks.

Rich body structure summary is the first promoted rich body read slice:

```bash
  swift run apple notes body structure --id NOTE_ID --json
```

The reader uses typed `ICNote.attributedString`, `ICNote` rich-state flags,
paragraph style objects, inline format/color/highlight attributes, and inline
attachment metadata to emit counts and hashes only. It reports body byte
count/hash, paragraph counts, paragraph-style runs, inline format run counts,
bold/italic/underline/strikethrough/font run counts, foreground/highlight run
counts, privacy-safe color/font-hash counts, checklist/table/math/link/attachment
counts, and rich-state flags. It must not print note body text, note title,
raw attributed content, raw paragraph style data, raw colors, raw font objects,
private color/font objects, table cell text, or checklist item text.

Rich body special-surface accounting, collapsible-section state mutation, and
collapsible-section create/update through paragraph style are promoted for
table/math/collapsible accounting and collapsible state/content-boundary
changes:

```bash
  swift run apple notes body surfaces --id NOTE_ID --json
```

The command derives table, math-result, collapsible-section, and collapsed-
section counts from the private body structure reader, returns supported read
families, reports table selector listing, table create, table delete,
single-cell table update, table copy, table row/column structure edit, existing
math-result selector listing/insert/update,
collapsible-section state mutation, and collapsible create/update as supported,
includes a `notes.body.surfaces` verification report. `body collapsible list`
uses `ICOutlineController` with private
paragraph UUIDs internally to return section ordinals, paragraph hashes, title
byte counts/hashes, and collapsed state. `body collapsible set` uses
`ICOutlineController` and `ICOutlineState` to collapse, expand, or toggle one
existing section selected by collapsible-section ordinal or paragraph hash.
`body paragraph style` promotes one non-list, non-checklist, non-block-quote
paragraph to a collapsible section with `heading` or `subheading`, and demotes
it with `body` or `title`. It also applies Apple's Monostyled paragraph style
through the private fixed-width text style. The response must not print body text, body hashes,
raw paragraph anchors, raw outline state, raw outline UUIDs, table cell text,
math expression text, or private class names.

`body format audit` is a no-implementation official workflow accounting surface for
the current Apple Format Notes, Add Lists, and Add a Table guide pages. It must
reject note, folder, account, query, paragraph, text, table, row, column, and
artifact selectors before any implementation lookup. The response records every
workflow as supported, delegated, gated, or rejected; supported records may
point only to already accepted inline, paragraph, collapsible, ordinary-list,
checklist, table, and settings commands including list-ending body paragraph
insertion, whole-table movement, selected ordinary text-to-table conversion,
external table import conversion, row/column formatting, and Monostyled paragraph styling.
Delegated records must stay limited to
Notes.app or system UI surfaces such as Touch Bar controls, menu/keyboard
interaction, table navigation/selection, and typing suggestions. No formatting
record remains gated in this target audit.
The verifier checks record-count consistency,
supported inline/paragraph/collapsible/list/checklist/table coverage,
delegated UI/system coverage, no remaining formatting-semantics gates,
selector-free invocation, and `backend_calls=none`. Command JSON must not
contain selected text, note bodies, note titles, paragraph text, table cell
text, raw colors, raw fonts, AppleScript output, `SQLiteReader` evidence, or
local paths.

Table selector listing, table create, external table import, single-cell table update, table
row/column insert/delete/move/copy/clear, table delete, table convert-to-text,
table convert-from-text, table copy, math-result selector listing, and
math-result insert/update are represented by supported semantic commands.
`body table list --id NOTE_ID`
enumerates inline table attachment records through private attributed-body
readback and returns ordinals, hashed identities, optional row/column counts,
and deletion capability evidence without printing table cell text.
`body table create --id NOTE_ID --text TEXT` appends one Notes table
attachment from tab/newline-delimited text, hashes the table text in dry-run
and result payloads, and verifies table-count, table attachment-kind, and
inline attachment-count deltas without printing table cell text.
`body table import --id NOTE_ID (--text TSV|--file PATH) [--format tsv|csv]`
appends one Notes table attachment from explicit external table input through
`ICNote.addTableAttachmentWithText:` after command-layer TSV/CSV normalization.
The verifier checks source kind/format accounting, source and normalized table
text hashes, new-table identity, table dimensions, per-cell hash readback,
table-count and inline attachment-count deltas, and privacy redaction without
printing local paths, source text, or table cell text.
`body table delete --id NOTE_ID --ordinal N` removes one inline table selected
by privacy-safe ordinal through `ICNote.removeInlineAttachmentsObject:`, then
verifies selected-table disappearance, table-count, table attachment-kind, and
inline attachment-count deltas without printing table cell text.
`body table convert-to-text --id NOTE_ID --ordinal N` reads selected table cells
through `ICTable.stringForColumnIndex:rowIndex:`, builds tab/newline-delimited
plain text, replaces the selected table attachment range in `ICNote.textStorage`,
then verifies selected-table disappearance, table-count, table attachment-kind,
inline attachment-count deltas, converted-text hash/readback, and privacy
redaction without printing table cell text.
`body table convert-from-text --id NOTE_ID (--paragraph HASH|--ordinal N)`
uses `ICNote.addTableAttachmentWithText:` to create a Notes table from the
selected ordinary paragraph text, then moves the attributed table run into the
source paragraph range with `ICNote.textStorage`. The verifier checks source
paragraph disappearance, table-count and inline attachment-count deltas, source
text hash/byte-count accounting, table dimensions, per-cell hash readback,
password state, and source/cell privacy without printing source text or table
cell text.
`body table copy --id SOURCE_NOTE_ID --ordinal N [--target TARGET_NOTE_ID]`
reads selected source-table cells through `ICTable.stringForColumnIndex:rowIndex:`,
then appends a copied table to the same note or explicit target note through
`ICNote.addTableAttachmentWithText:`. Verification checks source-table
preservation, target table-count, table attachment-kind, and inline
attachment-count deltas, copied-text hash evidence, target table dimensions,
and per-cell hash readback without printing table cell text.
`body table update --id NOTE_ID --ordinal N --row R --column C --text TEXT`
replaces one selected cell through
`ICTable.setAttributedString:columnIndex:rowIndex:` and verifies readback with
`ICTable.stringForColumnIndex:rowIndex:`. Verification checks selected table
identity preservation, target cell hash/byte-count match, table/list/attachment
count preservation, password state, and privacy redaction without printing old
or new cell text. `body table rows insert/delete --id NOTE_ID --ordinal N
--index I [--count C]` and `body table columns insert/delete --id NOTE_ID
--ordinal N --index I [--count C]` use private `ICTable` structure selectors
to change one selected table's row or column count. The verifier checks
selected-table identity preservation, row/column count readback, table-count
and inline attachment-count preservation, password state, and privacy redaction
without printing table cell text. `body table rows move --id NOTE_ID --ordinal N
--index I --to J` and `body table columns move --id NOTE_ID --ordinal N
--index I --to J` use private `ICTable.moveRowAtIndex:toIndex:` and
`ICTable.moveColumnAtIndex:toIndex:` selectors to move one selected row or
column. The verifier checks selected-table identity preservation, dimension
preservation, moved-slice SHA-256 destination readback, table-count and inline
attachment-count preservation, password state, and privacy redaction without
printing table cell text. `body table rows copy --id NOTE_ID --ordinal N
--index I --to J` and `body table columns copy --id NOTE_ID --ordinal N
--index I --to J` read source cells, insert one destination row or column, and
write copied cell values through the private table cell writer. The verifier
checks selected-table identity preservation, dimension growth, copied-slice
SHA-256 destination readback, table-count and inline attachment-count
preservation, password state, and privacy redaction without printing table cell
text. `body table rows clear --id NOTE_ID --ordinal N
--index I [--count C]` and `body table columns clear --id NOTE_ID --ordinal N
--index I [--count C]` use private `ICTable.identifierForRowAtIndex:`,
`ICTable.identifierForColumnAtIndex:`,
`ICTable.undoablyRemoveContentsOfRow:`, and
`ICTable.undoablyRemoveContentsOfColumn:` where available, with the accepted
single-cell table writer as a fallback, to clear selected row or column
contents without deleting the row or column. The verifier checks selected-table
identity preservation, dimension preservation, cleared-slice empty readback and
SHA-256 evidence, table-count and inline attachment-count preservation,
password state, and privacy redaction without printing table cell text.
`body math audit` is a read-only command-layer accounting surface for the
current Apple Solve Math and Open Math Notes from Calculator guide pages. It
does not call the implementation, AppleScript, or `SQLiteReader`; it only reports the
accepted private math result list/insert/update and Smart Folder/folder-note
paths, accepted Math Results display preference mutation, accepted private
calculate variable definition and dependent-result update mutations, accepted
private calculate scanner expression verification, and delegated
Notes.app/Calculator UI routes.
`body math list --id NOTE_ID` enumerates existing math-result
attachments and returns ordinals, identity hashes, expression/result byte
counts and hashes, validity, and direction metadata without expression or
result text. `body math update --id NOTE_ID --ordinal N --text RESULT` updates
one existing result through `ICInlineAttachment.updateCalculateResult:isRightToLeft:`
and verifies selected-result identity preservation, result hash/byte-count
readback, math-result count preservation, inline attachment count preservation,
table/list/checklist/collapsible count preservation, password state, and
privacy redaction without printing old or new result text. `body math insert
--id NOTE_ID [--paragraph HASH|--ordinal N] --text EXPRESSION` inserts one
recognized calculation expression/result through `ICNote.textStorage`,
`ICalculateRecognitionController.didInsertString:atRange:`, and
`ICCalculateRecognitionController.insertResultAtRange:`. The verifier checks a
new math-result identity, expression hash/byte-count readback, math-result
count delta, inline attachment-count delta, table/list/checklist/collapsible
count preservation, password state, and privacy redaction without printing the
expression or generated result text. `body math results --id NOTE_ID --mode
insert|suggest|off` writes the note-scoped Math Results display preference
through private `ICNote.calculatePreviewBehavior` /
`ICNote.setCalculatePreviewBehavior:`. Its verifier checks reported change
state, requested private raw-value readback, independent preference readback,
body plain-text hash preservation, rich-text length preservation, rich-body
surface counts, password state, and hashed preference-key evidence without
printing note content. `body math variable set --id NOTE_ID --name NAME --value
VALUE --expression EXPRESSION` writes a variable definition before a dependent
expression through `ICNote.textStorage`, `ICalculateRecognitionController`, and
`ICCalculateDocumentController`. Its verifier requires new private readback for
both expression hashes, math-result count delta, math attachment delta, distinct
definition/dependent identities, Latin-alphabet `--name` validation matching
Notes' variable-recognition rule, and privacy redaction without printing
variable names, values, expressions, results, or note text. `body math variable
update --id NOTE_ID --definition-ordinal N --dependent-ordinal N --value VALUE`
updates one selected variable-definition expression range through
`ICCalculateDocumentController.expressionRangeForResultAttachment:` and
`updateAffectingChangeCounts:`. Its verifier requires selected definition and
dependent readback, math-result count preservation, changed definition evidence,
dependent-result delta, dependent-expression hash preservation, and privacy
redaction without printing variable values, expressions, results, or note text.
`body math verify-expression --text EXPRESSION` runs the
private `ICCalculateStringScanner.scanStringforRange:previewedExpressionString:`
path over a caller-provided expression and verifies expression hash presence,
UTF-16 range coverage, private scanner implementation-call evidence, recognized scan
output, and the hash-only privacy boundary without printing raw expression,
result, note content, or private type names. `doctor rich-lab` now reports accepted readiness for table
list/create/import/update/delete/convert-to-text/convert-from-text/copy/move/structure edit through `ICNote.addTableAttachmentWithText:`,
`ICTable.setAttributedString:columnIndex:rowIndex:`,
`ICNote.removeInlineAttachmentsObject:`, `ICTable.stringForColumnIndex:rowIndex:`,
and `ICNote.textStorage`, accepted readiness for existing
math-result insert/update and variable-definition/dependent-result update
through `ICCalculateRecognitionController`, `ICCalculateDocumentController`,
and `ICInlineAttachment.updateCalculateResult:isRightToLeft:` while remaining
probe-only.

Paragraph style/alignment/block quote, inline format/color/highlight/font, checklist
add/set/set-all/sort/convert/convert-range/reorder/indent/delete, and ordinary list
add/convert/convert-range/set-style/reorder/indent/delete are promoted rich
body mutation slices:

```bash
  swift run apple notes body paragraph style --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --style heading --json

  swift run apple notes body paragraph align --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --alignment center --json

  swift run apple notes body paragraph quote --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --state on --json

  swift run apple notes body inline format --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --format bold --state on --json

  swift run apple notes body inline color --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --color "#336699" --json

  swift run apple notes body inline highlight --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --color yellow --json

  swift run apple notes body inline font --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --text "Important" --family FONT_FAMILY --size 18 --json

  swift run apple notes body checklist add --id NOTE_ID --text "Review contract" --json

  swift run apple notes body checklist set --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --state checked --json

  swift run apple notes body checklist set-all --id NOTE_ID --state open --json

  swift run apple notes body checklist sort --id NOTE_ID --json

  swift run apple notes body checklist convert --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --state checked --json

  swift run apple notes body checklist convert-range --id NOTE_ID --from-ordinal 3 --to-ordinal 5 --state open --json

  swift run apple notes body checklist reorder --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --to-ordinal 1 --json

  swift run apple notes body checklist indent --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --by 1 --json

  swift run apple notes body checklist delete --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json

  swift run apple notes body checklist line-break --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json

  swift run apple notes body checklist end --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json

  swift run apple notes body list add --id NOTE_ID --text "Discuss launch" --style bulleted --json

  swift run apple notes body list convert --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --style numbered --json

  swift run apple notes body list convert-range --id NOTE_ID --from-ordinal 3 --to-ordinal 5 --style dashed --json

  swift run apple notes body list set-style --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --style dashed --json

  swift run apple notes body list reorder --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --to-ordinal 1 --json

  swift run apple notes body list indent --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --by 1 --json

  swift run apple notes body list delete --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json

  swift run apple notes body list line-break --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json

  swift run apple notes body list tab --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json

  swift run apple notes body list end --id NOTE_ID --paragraph PARAGRAPH_ID_SHA256 --json
```

The writer uses typed `ICNote.appendAttributedString:`, `ICNote.textStorage`,
`ICTTParagraphStyle.uuid`, `ICTTParagraphStyle.mutableCopy`,
`ICTTMutableParagraphStyle`, `ICTTParagraphStyle.indent`,
`ICTTParagraphStyle.alignment`, `ICTextStyle` named style values,
`ICTTMutableParagraphStyle.blockQuoteLevel`, `ICTTTodo.todoWithDone:`, `NSFont`,
attributed paragraph range deletion, `NSTextStorage` bounded insertion, and Notes paragraph-style
attributes. Paragraph style changes one ordinary body paragraph to title,
heading, subheading, or body through typed `ICTextStyle` values. Paragraph
alignment changes one ordinary body paragraph to left, center, right,
justified, or natural through `ICTTParagraphStyle` alignment conversion.
Paragraph quote toggles `blockQuoteLevel` on one ordinary paragraph. These
paragraph commands reject list and checklist paragraphs; style/alignment also
reject existing block-quote paragraphs so block-quote state is handled only by
`body paragraph quote`. They preserve target paragraph title hash,
paragraph-anchor order, paragraph/list/checklist counts, body byte-count/hash,
and note identity/title/folder/account; and verify target style, alignment, or
block-quote readback without printing raw attributed content, paragraph UUIDs,
or paragraph titles. Checklist add accepts one editable visible non-password-protected note,
supports `--checked`, and verifies note identity/title/folder/account
preservation plus checklist item/done/open count deltas through body structure
readback. Set changes one existing checklist item state by paragraph anchor hash
or ordinal and verifies item-count preservation, checked/open count deltas, body
hash preservation, and paragraph-anchor preservation when selected by hash.
Set-all changes every checklist item state on one note and verifies item-count
preservation, all checked/open target counts, body hash preservation, and
checklist paragraph-anchor preservation. Sort moves checked checklist items
after open items on one note and verifies sorted readback, open-item and
checked-item relative order preservation, checklist item/done/open count
preservation, and body byte-count preservation. Convert changes one non-checklist
paragraph anchor from `body structure` into a checklist item and verifies the
same anchor becomes checklist while body hash and paragraph title hash remain
stable. Reorder moves one existing checklist item to a target checklist ordinal
on the same note by paragraph hash or checklist ordinal; it verifies item/done/
open count preservation, source paragraph title-hash preservation, body
byte-count preservation, and checklist anchor order readback. Indent increases
or decreases one checklist item's list level by one and verifies target
indentation level/delta, item/done/open count preservation, body hash
preservation, target paragraph title-hash preservation, and checklist anchor
order preservation. Delete removes one existing checklist item by paragraph
hash or checklist ordinal and verifies target anchor absence, checklist/list
item count decrement, done/open decrement for the removed item, remaining
checklist anchor order preservation, and body byte-count/hash change. Ordinary
list reorder moves one existing ordinary list item to a target ordinary-list
ordinal while excluding checklist paragraphs and verifies ordinary list anchor
order readback, ordinary/list item count preservation, checklist item/done/open
count preservation, body byte-count/hash preservation, and source title-hash
preservation. Ordinary list indent increases or decreases one existing ordinary
list item's level by one and verifies the target is not a checklist item,
target indentation level/delta, ordinary list anchor order preservation,
checklist item/done/open count preservation, body byte-count/hash preservation,
and target title-hash preservation. Ordinary list delete removes one existing ordinary list item and
verifies the target is not a checklist item, target anchor absence, list item
count decrement, ordinary list anchor order preservation, checklist
item/done/open count preservation, and body byte-count/hash change. Ordinary
list add appends one bulleted, dashed, or numbered list item through
`ICNote.appendAttributedString:` and typed `ICTTMutableParagraphStyle` style
values. Ordinary list convert and convert-range mutate one non-list paragraph
anchor or contiguous non-list body paragraph ordinal range to the requested
style while rejecting checklist/list inputs. Ordinary list set-style mutates
one existing ordinary list item's paragraph style to bulleted, dashed, or
numbered and reports no-op when already set. The verifier checks requested
style readback, list count deltas or preservation, anchor order preservation,
title-hash preservation, body hash preservation for convert/range/set-style,
and note identity/title/folder/account preservation. The command
result returns note summary and structure/verifier evidence rather than raw
attributed content. Inline format/color/highlight/font writes use
`ICNote.textStorage` and attributed-string attributes to change one selected
text range inside a paragraph selected by paragraph hash or ordinal. The
command layer hashes selected text, color input, and font-family evidence for
dry-run/result output; point size is reported as a normalized number. The
verifier checks selected-text hash/count, target inline run readback,
font-hash readback for font mutations, changed/no-op reporting,
paragraph-anchor order preservation, body byte-count/hash preservation, and note
identity/title/folder/account preservation.

Richer table-format operations beyond supported import/copy/convert-to-text and
row/column insert/delete/move/copy/clear/format, broader rich formatting surfaces, and
full formatting export remain gated until
preservation and post-write verifier proof are accepted.

Note state reading, lockability reasoning, and audit are the promoted
locked/shared boundary read slices:

```bash
  swift run apple notes state read --id NOTE_ID --json

  swift run apple notes state audit --account ACCOUNT --json

  swift run apple notes state audit --folder FOLDER --json

  swift run apple notes state lockability --id NOTE_ID --json
```

The reader uses typed `ICNote`, `ICCloudSyncingObject`, and folder state
selectors to emit flags, bounded records, aggregate counts, and activity
metadata only: deleted/trash, pinned, password protection, locked status,
editable/lockable, shared/read-only, system-paper, math/call-note, cloud-fetch,
participant count, participant identifier hashes, folder state, activity-event
byte count/SHA-256, activity-document presence, share timestamp hash, supported
  read families, and gated mutation families. `state lockability` combines
  private state, account/provider lockability, tag-membership, and
  attachment-family readback to emit only lockability flags, reason IDs, booleans,
  counts, and hashes for provable blockers such as Quick Note status, shared
  state, unsupported provider/account crypto state, tag presence, unsupported
  attachment families, unknown attachment families, and cloud-fetch requirements.
  Account evidence comes from `ICNote.account`, `ICAccount.canPasswordProtectNotes`,
  `ICAccount.canHaveCryptoStrategy`, provider booleans, `ICAccountData.lockedNotesMode`,
  resolved lock mode hash evidence, and password-protected-note counts without
  printing account values. The verifier checks selected-state identity, tag hash
  accounting, account lockability evidence, attachment family accounting, reason
  evidence for non-lockable notes, and a hashes/counts/booleans privacy boundary.
  `state audit` starts from bounded visible note summaries,
optionally limited by `--account` and/or `--folder`, only to obtain note IDs,
then calls the state reader. Account-scoped audit must dispatch through
`NotesAccountScopedListing`.
`state activity` calls the activity reader and may export the same privacy-safe
metadata to a `.json` artifact with `--allow-artifact-action` and artifact
readback verification. These commands must not fetch note bodies or print note
body text, note title, folder/account names, tag names, attachment titles or
filenames, participant names, shared owner names, activity text, or raw
collaboration handles.

`state collaboration audit` is a no-implementation official workflow accounting
surface for the current Apple sharing/collaboration guide pages. It must reject
all note, folder, account, participant, query, and artifact selectors before
any implementation lookup. The response records every workflow as supported,
delegated, gated, or rejected; supported records may point only to already
accepted state/activity reads, privacy-safe activity artifact export, and
ordinary editable shared-note mutation paths with read-only/read-write gates,
privacy-safe participant/access metadata readback, existing collaboration link
clipboard copy, and per-shared-note Hide Alerts through private recordID and
`ICShareNotifier` preference readback, existing participant permission mutation
through private share participant readback, existing participant removal through
private share participant absence readback, existing access-scope mutation for
shared notes or folders through private share public-permission readback, shared
note/folder stop-sharing through private collaboration-controller share removal
plus share absence readback, invite-policy mutation through private participant
role readback, current-user self-removal through private share participant
absence readback, starting note/folder collaboration and participant invite/add
through private share creation or existing-share lookup plus CloudKit participant
lookup/add, and semantic participant mention insertion.
Delegated records must stay limited to system or Notes UI surfaces such as
share-sheet delivery, iCloud link opening, realtime presence, highlights, and
activity highlight UI. The current collaboration workflow audit must have no
gated records. The verifier checks record-count
consistency, supported state/activity read coverage, delegated UI/system
coverage, supported access-scope, shared note/folder stop-sharing, shared
note/folder participant permission mutation coverage, share/invite participant
mutation coverage, invite-policy mutation coverage, no-gated-collaboration
coverage, selector-free invocation, and
`backend_calls=none`. Command
JSON must not contain raw share links, participant
targets, contact values, note bodies, note titles, folder/account names,
activity detail text, AppleScript output, or `SQLiteReader` evidence.

`state security audit` is a no-implementation official workflow accounting surface for
the current Apple Lock Notes and locked-notes password guide pages. It must
reject all note, folder, account, query, and secret-bearing selectors before
any implementation lookup. The response records every workflow as supported,
delegated, gated, or rejected; supported records may point only to already
  accepted lock-state, lockability, note/account/provider lockability reason,
  account-upgrade/provider reason evidence, settings-family accounting reads,
  custom locked-notes passphrase setup through
  `ICAccountPassphraseManager.setPassphrase:hint:`, custom locked-notes
  passphrase change through
  `ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:`,
  custom locked-notes passphrase reset through
  `ICAccountPassphraseManager.setPassphrase:hint:isReset:`, account-scoped
  Touch ID preference mutation, initial login-password method selection through
  `ICLocalAuthentication.hasPasscode`,
  `ICLockedNotesModeMigrator.account:supportsMode:`, and
  `ICAccount.setResolvedLockedNotesMode:`, private passphrase unlock through
  `ICAuthenticationState.authenticateObject:withPassphrase:`, eligible note
  lock/remove-lock mutation through `ICNoteLockManager`, or explicit
  locked-session close through `ICAuthenticationState.deauthenticateAllObjects`
  with authenticated state readback.
Delegated records must stay limited to system or Notes.app surfaces such as
Touch ID, Mac login password authentication, and locked-session timeout. Gated
  records must cover password-method change/migration mutations until a typed
  private migration/rekey operation, secret-safe credential flow, and
  privacy-safe verifier readback are accepted. Same-command authenticated
  locked-content export is supported separately by `state export-locked-content`.
  Custom password reset is supported separately
  through the private account passphrase manager reset selector. Custom password
  change is supported separately through the private account passphrase manager
  change selector with separate old/new secret-source accounting.
  Initial login-password method selection is supported only for accounts with
  zero existing password-protected notes; method switching for existing locked
  notes remains gated until migration/rekey readback is accepted.
  Session-unlocked locked-content artifact export is covered separately by
  `state export-locked-content` and must not be treated as password setup or
  password-method support. The verifier checks 19-record count consistency,
  supported state/settings/lockability-reason/session-control/unlock/custom-passphrase/change/reset/method
  coverage, delegated system authentication coverage, gated password mutation
  coverage, selector-free invocation, and `backend_calls=none`. Command JSON must
not contain passwords, password hints, account values, note bodies, note titles,
AppleScript output, SQLite evidence, or local secret material.

The semantic locked-password mutation command names that still need private
proof are reserved at the CLI boundary as future password/security backlog:
`state change-password`, password-method migration/change paths, and the legacy
`settings password`. Until capability-specific private framework mutation proof
is accepted, they validate only the required selectors, throw
`unsupported_operation`, include gated capability metadata, set `backend_calls`
to `none`, and must not echo account values, passwords, password hints, note
bodies, locked content, or local artifact contents. `state unlock` is supported
separately through private
`ICAuthenticationState.authenticateObject:withPassphrase:` with stdin/env/file
passphrase sources and must not print passphrases, source names/paths, locked
content, note bodies, or note titles.
`settings locked-notes --account ACCOUNT --scope custom
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`
is supported separately through `ICAccountPassphraseManager.setPassphrase:hint:`.
It must require `--allow-persistent-action`, support dry-run without reading the
passphrase, reject hints equal to the passphrase, verify selected-account
crypto-strategy readback through `notes_settings_mutation_v1`, and never print
passphrases, source names/paths, hints, account values, keychain material, or
locked content.
`settings reset-password --account ACCOUNT
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`
is supported separately through
`ICAccountPassphraseManager.setPassphrase:hint:isReset:`. It must require
`--allow-persistent-action`, support dry-run without reading the passphrase,
reject hints equal to the passphrase, verify selected-account crypto-strategy
readback plus reset-boundary accounting through `notes_settings_mutation_v1`,
and never print passphrases, source names/paths, hints, account values,
keychain material, or locked content.
`settings change-password --account ACCOUNT
--old-passphrase-stdin|--old-passphrase-env NAME|--old-passphrase-file FILE
--new-passphrase-stdin|--new-passphrase-env NAME|--new-passphrase-file FILE
[--hint HINT]` is supported separately through
`ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:`.
It must require `--allow-persistent-action`, support dry-run without reading
old or new passphrases, reject identical old/new passphrases, reject hints equal
to the new passphrase, reject both old and new stdin sources in one invocation,
verify selected-account crypto-strategy readback plus change-boundary accounting
through `notes_settings_mutation_v1`, and never print passphrases, source
names/paths, hints, account values, keychain material, or locked content.
Share-folder and invite participant
operations are supported separately through private share creation or
existing-share lookup, CloudKit participant lookup/add, private share save, and
participant/permission delta readback.
`state export-locked-content` is not part of that pure refusal set anymore:
it supports only password-protected notes already unlocked in the current
Notes session, writes plaintext solely to an explicit `.txt` artifact behind
`--allow-artifact-action`, verifies artifact hash/readback, and must continue
to refuse currently locked notes until the selected note is first unlocked in
the current Notes session.
`state lock --id NOTE_ID --allow-persistent-action` and
`state remove-lock --id NOTE_ID --allow-persistent-action` are accepted
exceptions: they must require `--allow-persistent-action`, call
`ICNoteLockManager.addLockWithCompletionHandler` or
`ICNoteLockManager.removeLockWithCompletionHandler` only for eligible notes,
verify lock-state before/after readback, and return only lock flags,
implementation-call metadata, and verifier checks. They must not accept or print
passwords, password hints, keychain material, note bodies, titles, or locked
content.
`state hide-alerts --id NOTE_ID --enabled true|false` is the accepted exception:
it must require `--allow-persistent-action`, use private shared-note recordID
readback and `ICShareNotifier` preference readback, and return only
note/record hashes, booleans, counts, and verifier checks.
`state close-locked [--account ACCOUNT]` is another accepted exception: it must
require `--allow-persistent-action`, call private
`ICAuthenticationState.deauthenticateAllObjects`, use `--account` only as an
account selector preflight, verify `isAuthenticated` and
`hasAuthenticatedObject` are false after execution, and return only account
hashes, scope strings, booleans, implementation-call metadata, and verifier checks.
`state copy-link --id NOTE_ID|--folder FOLDER [--output FILE.txt]` is also an
accepted exception for existing-link output: clipboard output must require
`--allow-persistent-action`, artifact output must require
`--allow-artifact-action`, both paths must read a private share URL only for an
already shared note or folder, and both must verify hash/readback evidence
without printing the raw collaboration URL to JSON or stdout. Raw link output
remains confined to the explicit existing-link copy/export paths.
`state share --id NOTE_ID|--folder FOLDER --scope invited-only|anyone-with-link`
is also an accepted exception for changing one already shared note or folder's access scope: it must
require `--allow-persistent-action`, mutate `CKShare.publicPermission`, save the
private collaboration share, verify public-permission enum readback, and return
only target/share hashes, public-permission enum labels, participant count, and
verifier checks. Passing `--target` to `state share`, using
`state share-folder`, or using `state invite` is also an accepted exception for
one share participant operation: it must require `--allow-persistent-action`,
create or reuse the private collaboration share, resolve the target through
CloudKit share-participant lookup, call `CKShare.addParticipant`, save the
private collaboration share, verify participant/permission delta readback, and
return only target, participant, share, permission, count, and verifier hashes or
enum labels.
`state set-permission --id NOTE_ID|--folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write`
and `state folder-permission --folder FOLDER --target PARTICIPANT_ID --scope read-only|read-write`
are also accepted exceptions for changing one existing shared note or folder
participant's permission: they must require `--allow-persistent-action`, resolve
`--target` against private participant metadata, mutate
`CKShareParticipant.permission`, save the private collaboration share, verify
before/after permission enum readback, and return only target, participant,
share, permission, and verifier hashes or enum labels.
`state remove-participant --id NOTE_ID --target PARTICIPANT_ID` is also an
accepted exception for removing one existing non-owner, non-current-user
shared-note participant: it must require `--allow-persistent-action`, resolve
`--target` against private participant metadata, call
`CKShare.removeParticipant`, save the private collaboration share, verify target
participant absence plus before/after participant-count readback, and return
only note, target, participant, share, count, and verifier hashes.
`state remove-self --id NOTE_ID|--folder FOLDER` is also an accepted destructive
exception for removing the current user from one already shared note or folder:
it must require both `--allow-destructive-selection` and
`--allow-persistent-action`, resolve the current user participant through
private share metadata, call `CKShare.removeParticipant`, save the private
collaboration share, verify current-user participant absence plus before/after
participant-count readback, and return only target, current-user participant,
share, count, and verifier hashes.
`state stop-sharing --id NOTE_ID|--folder FOLDER` is also an accepted destructive exception for
one already shared note or folder: it must require both `--allow-destructive-selection`
and `--allow-persistent-action`, call private
`ICCollaborationController.removeShareIfNeededWithOwnedObjectID`, verify share
absence plus before/after participant-count readback, and return only target,
share, participant-count, implementation-call, and verifier hashes or booleans.
`state allow-invites --id NOTE_ID|--folder FOLDER --enabled true|false` is also
an accepted exception for changing whether existing collaborators can add people
to one already shared note or folder: it must require
`--allow-persistent-action`, mutate private `CKShareParticipant.role` values,
save the private collaboration share, verify administrator-role count readback,
and return only target/share hashes, booleans, participant/admin counts,
implementation-call metadata, and verifier checks.
`state mention --id NOTE_ID --target PARTICIPANT_ID [--text TEXT]` is also an
accepted exception for one semantic mention insertion in an already shared
editable note: it must require `--allow-persistent-action`, resolve `--target`
against existing private participant metadata, create an
`ICInlineAttachment` mention, insert it through `ICNote.textStorage`, verify
mention-count and target-participant readback, and return only note, target,
participant, mention-text, attachment, count, and verifier hashes. It must not
print participant names, participant handles, note body text, or mention text.
`state participants --id NOTE_ID|--folder FOLDER [--output FILE.json]` is the
accepted participant/access metadata read/artifact path: it must require exactly
one note or folder selector, refuse non-shared targets, read private
`serverShare` participant and public-permission metadata plus note/folder shared
state, and return only target/share/owner hashes, participant identity hash set,
user-record hashes, counts, permission/role/acceptance/public-permission enum
values, and verifier checks. Artifact output must require
`--allow-artifact-action`, write only the same hash/enum metadata, and verify
artifact SHA-256 plus stable participant readback. It must not print participant
names, email addresses, phone numbers, raw participant identifiers, share URLs,
note titles, note bodies, folder names, or contact values. Participant
invite remains gated.
`state activity` is a read/artifact metadata command only; raw activity-detail export and collaboration mutation implementations must
not be wired to these names until they have post-write private-framework state
readback and privacy-boundary tests.

The Notes settings boundary is explicit and separate from note mutation:
`settings audit` is selector-free command-layer accounting for the official
Change Notes settings, Customize how notes appear, Use Notes widgets, and Manage
notifications pages. It must not call the Notes implementation, AppleScript,
`SQLiteReader`, macOS widget settings, System Settings, or notification APIs; it
must report exactly the supported private settings/folder-date/local-account
workflows and the delegated macOS/system/Notes.app UI surfaces: 28 records,
19 supported, 9 delegated, and no gated or rejected records, with
`backend_calls: none` and no raw selector/value echo. `settings read` validates
optional account scope. `settings read` is a read-only private-framework account
of the official settings families; it may use typed account/default-account
evidence such as `ICAccount.isLocalAccount` and `ICDefaultAccountUtilities.defaultAccount`, plus
`ICNoteListSortUtilities.currentNoteListSortType` for the note-list sort
preference,
`ICTextStyle.noteDefaultNamedStyle` for the default new-note paragraph style,
`ICDateHeadersUtilities.currentDateHeadersOn` for global date grouping,
`ICDateHeadersUtilities.defaultDateHeadersType` and
`ICDateHeadersUtilities.queryDateHeadersType` for default/query date-header
type hash evidence,
`ICPaperCommonUtilities.shouldResumeLastQuickNote` for the Quick Note resume
preference, `ICSettingsUtilities.bool(forKey:)` with
`ICMentionNotificationsPrefIdentifier` for the allow-mention-notifications
preference, `ICMZoomController.globalZoomFactorIndex` and
`ICMZoomController.globalZoomFactors` for the default text size preference, and
`ICTextController.checklistAutoSortEnabled` for the automatic checked-item
sorting preference, plus `ICAccount.cryptoStrategy.hasPassphraseSet` and
hint-hash state for the selected account's locked-notes setup state, but it
must not dump raw defaults, paragraph style names,
date-header enum values, text-size values, account names, account IDs,
passwords, password hints, AppleScript output, or
`SQLiteReader` evidence.
`settings sort`, `settings default-account`, `settings group-by-date`,
`settings group-by-date --scope default|query`,
`settings quick-note-resume`, `settings mention-notifications`,
`settings text-size`, `settings new-note-style`,
`settings checklist-sort`, `settings locked-notes --account ACCOUNT --scope custom
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`,
`settings change-password --account ACCOUNT
--old-passphrase-stdin|--old-passphrase-env NAME|--old-passphrase-file FILE
--new-passphrase-stdin|--new-passphrase-env NAME|--new-passphrase-file FILE
[--hint HINT]`,
`settings reset-password --account ACCOUNT
--passphrase-stdin|--passphrase-env NAME|--passphrase-file FILE [--hint HINT]`,
`settings on-my-mac --enabled true|false`, and
`state hide-alerts --id NOTE_ID --enabled true|false` are
accepted private-framework preference/account-lifecycle mutations.
They must use typed setters (`ICNoteListSortUtilities.setCurrentNoteListSortType`,
`ICDefaultAccountUtilities.setDefaultAccountIdentifier`,
`ICDateHeadersUtilities.setDateHeadersOn`,
`ICDateHeadersUtilities.setDefaultDateHeadersType`,
`ICDateHeadersUtilities.setQueryDateHeadersType`,
`ICSettingsUtilities.setBool(_:forKey:)` with
`ICResumeLastQuickNotePrefIdentifier`,
`ICSettingsUtilities.setBool(_:forKey:)` with
`ICMentionNotificationsPrefIdentifier`,
`ICMZoomController.setGlobalZoomFactorIndex`,
`ICTextStyle.setNoteDefaultNamed(_:)`, and
`ICTextController.setChecklistAutoSortEnabled`), the typed
`ICAccountPassphraseManager.setPassphrase:hint:`,
`ICAccountPassphraseManager.changePassphrase:toPassphrase:hint:completion:`,
and `ICAccountPassphraseManager.setPassphrase:hint:isReset:` account passphrase paths, or the typed
`ICNoteContext` local-account lifecycle entry points; Hide Alerts uses private
shared-note `recordID` readback plus `ICShareNotifier.setShouldPreventNotifications`.
`settings touch-id --account ACCOUNT --enabled true|false` uses private
`ICAuthenticationState.setBiometricsEnabled:forAccount:` and verifies
account-scoped preference readback plus Touch ID preference-key and
LocalAuthentication boundary evidence.
All of these commands require
`--allow-persistent-action` for execution, support dry-run without writing, and
verify post-write readback through either `notes_settings_mutation_v1` or
`notes_shared_note_alerts_mutation_v1` without printing raw sort values, style
names, date-header enum values, text-size values, defaults, account values,
passphrases, password hints, note titles, note bodies, participant values, raw record IDs, or
AppleScript/SQLite evidence.
`settings on-my-mac --enabled false` must preflight
local visible/trashed note count, local custom-folder count, default-account
state, and non-local account availability before calling the private local
account deletion path.
Remaining official setting mutation commands are semantic boundary commands:
password-method migration/change paths and the legacy `settings password`
command return gated `unsupported_operation` metadata as future
password/security backlog until accepted private settings/password mutation
proof and readback exist. `settings view-layout`,
`settings link-highlight-color`, `settings notifications`, and
`settings widgets` are delegated to macOS, appearance, window, notification, or
widget user-facing surfaces unless a future accepted route proves otherwise.
All delegated/gated settings commands validate
their command-specific selector or requested value, set `backend_calls` to
`none`, and must not echo account values, style names, color values, or other
setting payload values.

Locked/shared/collaboration mutations and locked/protected copy mutations
remain gated until preservation and post-write verifier proof are accepted.
Pin/unpin, bounded restore-all, and bounded empty-trash are promoted separately.

Private-vs-AppleScript read parity is explicit opt-in so normal doctor runs do
not trigger Notes automation permission prompts. The AppleScript parity implementation
is read-only and cannot be injected as the Notes mutation implementation:

```bash
APPLE_CLI_NOTES_READ_PARITY=1 \
  swift run apple notes doctor --json
```

The parity check compares bounded accounts, folders, and note metadata using
counts and SHA-256 digests only. It does not print note titles or bodies.
`APPLE_CLI_NOTES_READ_PARITY_LIMIT` may be set from `1` to `2000`; the default
is `1000`.

Parity details may include matched-ID counts, per-field mismatch counts,
coarse date-delta buckets, and bounded mismatch samples. Those values are
diagnostics only; they should remain hashes, counts, and non-sensitive private
metadata. They must not include raw note titles, folder names, note IDs, or
bodies.

Verifier work should be per capability. The current mutation surface uses
`NotesMutationVerifier` after execution for
folder create/rename/move/delete plus note create/import/update/append/move/copy/restore/delete/purge/pin/unpin.
It reads the final folder or note state through the current Notes read path,
emits hashes, lengths, boolean checks, and bounded store-object evidence, and
fails the command if required post-write checks do not pass. Folder create
verification checks folder name, account, parent placement, and optional store
evidence. Folder rename verification checks folder identity preservation,
target name, account preservation, parent preservation, and optional store
evidence. Folder move verification checks folder identity preservation, name
preservation, target account, target parent or account root, and optional store
evidence. Folder delete verification checks visible folder removal and optional store
evidence. Note move verification additionally checks destination folder/account and
title/body/tag preservation. Copy verification checks a new note identity,
source note preservation, destination folder/account, and
title/body/tag preservation. Restore verification checks identity preservation,
visible readback, destination folder/account, and title/body/tag preservation.
Purge verification checks that one already-deleted note is absent from both
visible readback and restorable readback after execution.
Pin/unpin verification checks final note-state readback, target pinned state,
identity preservation, title/folder/account preservation, and optional store
pinned evidence.
Tag rename verification checks affected-note identity preservation, old-tag
removal, new-tag presence, title/folder/account preservation, and non-target
tag preservation.
The verifier report is part of successful JSON mutation output under
`verification`.

A promoted private mutation still needs preflight, dry-run summary, private
framework execution, private framework readback, and read-only store/index
evidence where that field requires it. Preserve known rich Notes state unless
the user explicitly asks to change it.

## Validation

Use package-local checks for Notes changes:

```bash
swift build
swift test --filter Notes
swift run apple notes doctor --json
```

For private framework boundary changes, also check linkage and direct store
write absence:

```bash
swift test --filter Notes
swift run apple notes doctor --json
otool -L .build/debug/apple
rg -n "(INSERT|UPDATE|DELETE|REPLACE|CREATE|DROP).*NoteStore|sqlite3_exec|executeUpdate" Sources/NotesCLI
```

Expected results:

- Build succeeds.
- Notes-focused tests pass.
- Doctor reports the Notes implementation as active.
- `tags list --json` and single-tag, multi-tag All/Any, and include/exclude
  `tags search` forms work in the default private-framework-backed build and remain read-only. Tag search
  output is note summaries plus selector hash/count accounting only.
- `smart-folders list --json` works in the default private-framework-backed build and reports privacy-safe
  criteria summaries without printing raw criteria JSON, raw filter values,
  tag names, folder identifiers, participant identifiers, or private class
  names.
- `smart-folders notes --folder FOLDER [--account ACCOUNT] --json` works in
  default private-framework-backed builds and returns visible matching note summaries without printing
  note bodies, raw criteria JSON, raw filter values, participant identifiers,
  or private class names.
- `smart-folders criteria --folder FOLDER [--account ACCOUNT] --json` works in
  default private-framework-backed builds and returns one Smart Folder's privacy-safe criteria summary,
  bounded matching-note summaries, and readback verification without printing
  note bodies, raw criteria JSON, raw filter values, raw tag names, folder
  identifiers inside criteria, participant identifiers, or private class names.
- `smart-folders explain --folder FOLDER [--account ACCOUNT] --json` works in
  default private-framework-backed builds and returns privacy-safe criteria explanation, supported-read
  family accounting, gated-mutation family accounting, bounded matching-note
  summaries, and readback verification without printing note bodies, raw
  criteria JSON, raw filter values, raw tag names, folder identifiers inside
  criteria, participant identifiers, or private class names.
- `smart-folders reasoning --folder FOLDER [--account ACCOUNT] --json` works
  in the default private-framework-backed build and returns privacy-safe per-note membership evidence,
  criteria families, partial filter-level state/count/folder/date/
  attachment-family/tag evidence, semantic raw-value/inclusion readback for
  accepted filters, tag-selection reason evidence, gated-reasoning families, and
  readback verification without
  printing note bodies, raw criteria JSON, raw filter values, raw tag names,
  participant identifiers, or private class names.
- `smart-folders audit [--account ACCOUNT] --json` works in the default private-framework-backed build and
  returns batch criteria-family accounting, filter-kind counts, raw-value hash
  accounting, supported-read families, gated-mutation families, and readback
  verification without fetching matching notes or printing note bodies, raw
  criteria JSON, raw filter values, raw tag names, folder identifiers inside
  criteria, participant identifiers, or private class names.
- `smart-folders create --name NAME --account ACCOUNT --tag TAG[,TAG...] [--match all|any] --json` works
  in the default private-framework-backed build for one or more existing visible tags and reports verifier evidence
  without printing raw criteria JSON or private class names.
- `smart-folders update --folder FOLDER [--account ACCOUNT] --tag TAG[,TAG...] [--match all|any] --json`
  works in the default private-framework-backed build for one editable Smart Folder and replaces criteria
  with one or more existing visible tags while preserving identity, name, and account
  without printing raw criteria JSON, raw tag names, or private class names.
- `smart-folders create-criteria --name NAME --account ACCOUNT --criteria
  pinned|unpinned|shared|not-shared|folder|not-folder|untagged|math|call|system-paper|recently-deleted-math|locked|unlocked|quick-notes|not-quick-notes|attachments|no-attachments|attachment-photo-video|attachment-scans|attachment-drawings|attachment-maps|attachment-websites|attachment-audio|attachment-documents|checklists|incomplete-checklists|completed-checklists|no-checklists|created-today|created-yesterday|created-last-7-days|created-last-30-days|created-last-3-months|created-last-12-months|created-on|created-before|created-after|created-between|created-relative|edited-today|edited-yesterday|edited-last-7-days|edited-last-30-days|edited-last-3-months|edited-last-12-months|edited-on|edited-before|edited-after|edited-between|edited-relative|participants|mentions
  --json` works in the default private-framework-backed build for the
  accepted criteria set and verifies criteria readback,
  Untagged tag-selection mode/count evidence, attachment/checklist/date
  `selectionType` evidence, folder selection evidence, date parameter evidence
  where applicable, and matching-note count without printing raw predicate text
  or private class names. Date criteria require `--date`, `--start-date` plus
  `--end-date`, or `--relative-amount` plus `--relative-unit` depending on the
  criteria kind. Single folder criteria require
  `--criteria-folder FOLDER[,FOLDER...]`; single `untagged` criteria are not
  accepted in comma-separated combinations yet; combined `folder,not-folder` criteria
  require `--include-criteria-folder FOLDER[,FOLDER...]` and
  `--exclude-criteria-folder FOLDER[,FOLDER...]`. `math`, `call`,
  `system-paper`, and `recently-deleted-math` may be combined with promoted
  private filter-selection criteria.
- `smart-folders update-criteria --folder FOLDER [--account ACCOUNT]
  --criteria pinned|unpinned|shared|not-shared|folder|not-folder|untagged|math|call|system-paper|recently-deleted-math|locked|unlocked|quick-notes|not-quick-notes|attachments|no-attachments|attachment-photo-video|attachment-scans|attachment-drawings|attachment-maps|attachment-websites|attachment-audio|attachment-documents|checklists|incomplete-checklists|completed-checklists|no-checklists|created-today|created-yesterday|created-last-7-days|created-last-30-days|created-last-3-months|created-last-12-months|created-on|created-before|created-after|created-between|created-relative|edited-today|edited-yesterday|edited-last-7-days|edited-last-30-days|edited-last-3-months|edited-last-12-months|edited-on|edited-before|edited-after|edited-between|edited-relative|participants|mentions
  --json` works in the default private-framework-backed build
  for one editable Smart Folder, preserves identity/name/account, and verifies
  criteria readback, attachment/checklist/date `selectionType` evidence, date
  parameter evidence where applicable, plus matching-note count. Single folder
  criteria require `--criteria-folder FOLDER[,FOLDER...]`; single `untagged`
  criteria verify tag-selection mode/count readback; combined
  `folder,not-folder` criteria require `--include-criteria-folder` and
  `--exclude-criteria-folder`. `math`, `call`, `system-paper`, and
  `recently-deleted-math` may be combined with promoted private
  filter-selection criteria.
- `smart-folders duplicate --folder FOLDER [--account ACCOUNT] --name NAME
  --json` works in the default private-framework-backed build for one visible editable Smart Folder and
  creates a new same-account Smart Folder using the source private query while
  verifying query kind, filter count, predicate/tag-selection evidence,
  matching-note count, and visible-note count without printing raw criteria
  internals.
- `smart-folders copy-criteria --from SOURCE --to TARGET [--account ACCOUNT]
  --json` works in the default private-framework-backed build for one visible source Smart Folder and one
  editable same-account target Smart Folder, replacing the target criteria with
  the source private query while preserving target identity/name/account and
  verifying the copied criteria and matching-note count without printing raw
  criteria internals.
- `smart-folders export-criteria --folder FOLDER [--account ACCOUNT] --output
  FILE.json --json` works in the default private-framework-backed build for one visible Smart Folder and
  writes raw criteria JSON only to a verified `.json` artifact with
  `--allow-artifact-action`; command JSON reports path/hash/count evidence, not
  the raw criteria body.
- `smart-folders import-criteria --folder FOLDER [--account ACCOUNT] --file
  FILE.json --json` works in the default private-framework-backed build for one editable Smart Folder,
  validates a UTF-8 JSON artifact, replaces criteria through
  `ICFolder.smartFolderQueryJSON`, and verifies imported query hash/length plus
  Smart Folder readback without printing the raw criteria body.
- `smart-folders rename --folder FOLDER [--account ACCOUNT] --name NAME
  --json` works in the default private-framework-backed build for one editable Smart Folder and verifies
  identity, account, query, and visible-note count preservation without
  printing raw criteria JSON or private class names.
- `smart-folders delete --folder FOLDER [--account ACCOUNT] --json` works in
  default private-framework-backed builds for one editable Smart Folder and verifies visible Smart Folder
  absence without deleting matching notes or printing raw criteria JSON/private
  class names.
- `body structure --id NOTE_ID --json` works in the default private-framework-backed build and emits only
  structure counts/hashes, inline format/highlight/color run and color-hash
  counts, plus paragraph anchor hashes, not note body text, raw paragraph
  UUIDs, paragraph titles, raw attributed content, raw colors, or private color
  objects.
- `body inline format --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --text TEXT --format bold|italic|underline|strikethrough --state on|off
  --json` works in the default private-framework-backed build for one selected text range and verifies the
  target inline format run plus preservation checks without printing selected
  text.
- `body inline color --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --text TEXT --color COLOR --json` and `body inline highlight --id NOTE_ID
  (--paragraph PARAGRAPH_ID_SHA256|--ordinal N) --text TEXT --color COLOR
  --json` work in the default private-framework-backed build for one selected text range and verify
  foreground/highlight color run readback while hashing selected text and color
  evidence.
- `body inline font --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --text TEXT --family FAMILY --size POINTS --json` works in the default private-framework-backed build for
  one selected text range and verifies font-hash readback while hashing selected
  text and font-family evidence.
- `body paragraph style --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --style title|heading|subheading|body|monostyled --json` works in the default private-framework-backed build for one
  non-list, non-checklist, non-block-quote body paragraph and verifies target
  style readback, Monostyled fixed-width style readback, collapsible-section promotion or demotion for heading,
  subheading, body, and title, title-hash preservation, paragraph-anchor order
  preservation, paragraph/list/checklist count preservation, body byte-count/hash
  preservation, and note identity/title/folder/account preservation without
  printing raw paragraph text, titles, UUIDs, outline UUIDs, or attributed content.
- `body paragraph align --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --alignment left|center|right|justified|natural --json` works in the default private-framework-backed build
  for one non-list, non-checklist, non-block-quote body paragraph and verifies
  target alignment readback, title-hash preservation, paragraph-anchor order
  preservation, paragraph/list/checklist count preservation, body
  byte-count/hash preservation, and note identity/title/folder/account
  preservation without printing raw paragraph text, titles, UUIDs, or attributed
  content.
- `body paragraph quote --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --state on|off --json` works in the default private-framework-backed build for one non-list, non-checklist
  body paragraph and verifies target block-quote readback, block-quote count,
  title-hash preservation, paragraph-anchor order preservation,
  paragraph/list/checklist count preservation, body byte-count/hash
  preservation, and note identity/title/folder/account preservation without
  printing raw paragraph text, titles, UUIDs, or attributed content.
- `body checklist add --id NOTE_ID --text TEXT [--checked] --json` works in
  default private-framework-backed builds for one editable visible non-password-protected note and
  verifies checklist count deltas without printing raw attributed content.
- `body checklist set --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --state checked|open --json` works in the default private-framework-backed build for one existing checklist
  item and verifies item-count preservation, checked/open deltas, body hash
  preservation, and paragraph-anchor preservation when selected by hash.
- `body checklist set-all --id NOTE_ID --state checked|open --json` works in
  default private-framework-backed builds for every checklist item on one note and verifies item-count
  preservation, all checked/open target counts, body hash preservation, and
  checklist paragraph-anchor preservation.
- `body checklist sort --id NOTE_ID --json` works in the default private-framework-backed build for one note
  and verifies checked items read back after open items, open-item and
  checked-item relative order preservation, checklist item/done/open count
  preservation, and body byte-count preservation without printing raw checklist
  text or UUIDs.
- `body checklist convert --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --state checked|open --json` works in the default private-framework-backed build for one non-checklist
  paragraph anchor from `body structure` and verifies anchor conversion,
  checked/open count deltas, body hash preservation, and paragraph title-hash
  preservation without printing raw paragraph text or UUIDs.
- `body checklist convert-range --id NOTE_ID --from-ordinal N --to-ordinal N
  --state checked|open --json` works in the default private-framework-backed build for one contiguous
  `body structure` paragraph ordinal range when every selected paragraph is
  non-checklist. It verifies selected paragraph count, checklist conversion,
  checked/open count deltas, paragraph-anchor order preservation, body hash
  preservation, and paragraph title-hash preservation without printing raw
  paragraph text, titles, or UUIDs.
- `body checklist reorder --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --to-ordinal N --json` works in the default private-framework-backed build for one existing checklist item
  on one note and verifies checklist anchor order, item/done/open count
  preservation, source title-hash preservation, and body byte-count preservation
  without printing raw paragraph text or UUIDs.
- `body checklist indent --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --by 1|-1 --json` works in the default private-framework-backed build for one existing checklist item on
  one note and verifies target indentation level/delta, checklist anchor order
  preservation, item/done/open count preservation, body hash preservation, and
  target title-hash preservation without printing raw paragraph text or UUIDs.
- `body checklist delete --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing checklist item on one note
  and verifies target anchor absence, checklist/list item count decrement,
  done/open decrement for the removed item, remaining checklist anchor order
  preservation, and body byte-count/hash change without printing raw paragraph
  text or UUIDs.
- `body checklist line-break --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing checklist item on one note
  and inserts one soft line break through `ICNote.textStorage`, verifying target
  anchor/type/style preservation, list/checklist count preservation, paragraph
  count preservation, body byte-count delta, body hash change, and inserted-text
  hash/count evidence without printing the inserted character, raw paragraph
  text, titles, or UUIDs.
- `body checklist end --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing checklist item on one note
  and creates one following ordinary body paragraph through `ICNote.textStorage`
  and a fresh `ICTTMutableParagraphStyle` UUID, verifying target preservation,
  created body paragraph readback, list/checklist count preservation,
  paragraph-count delta, and body hash change without printing item text,
  paragraph text, titles, or UUIDs.
- `body list add --id NOTE_ID --text TEXT --style bulleted|dashed|numbered --json`
  works in the default private-framework-backed build for one editable visible non-password-protected note
  and verifies list item count increment, requested style readback, and
  privacy-safe text hash/count evidence without printing raw list text or UUIDs.
- `body list convert --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --style bulleted|dashed|numbered --json` works in the default private-framework-backed build for one
  non-list paragraph anchor from `body structure` and verifies requested style
  conversion, anchor preservation, body hash preservation, and paragraph
  title-hash preservation without printing raw paragraph text or UUIDs.
- `body list convert-range --id NOTE_ID --from-ordinal N --to-ordinal N
  --style bulleted|dashed|numbered --json` works in the default private-framework-backed build for one
  contiguous non-list body paragraph ordinal range and verifies selected anchor
  conversion, requested style readback, anchor order preservation, body hash
  preservation, and paragraph title-hash preservation without printing raw
  paragraph text, titles, or UUIDs.
- `body list set-style --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --style bulleted|dashed|numbered --json` works in the default private-framework-backed build for one
  existing ordinary list item and verifies requested style readback,
  ordinary-list selection, list count preservation, ordinary list anchor order
  preservation, body hash preservation, and target title-hash preservation
  without printing raw paragraph text or UUIDs.
- `body list reorder --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --to-ordinal N --json` works in the default private-framework-backed build for one existing ordinary list
  item on one note and verifies ordinary-list selection, ordinary list anchor
  order, ordinary/list item count preservation, checklist count preservation,
  body byte-count/hash preservation, and source title-hash preservation without
  printing raw paragraph text or UUIDs.
- `body list indent --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --by 1|-1 --json` works in the default private-framework-backed build for one existing ordinary list item
  on one note and verifies target ordinary-list selection, indentation
  level/delta, ordinary list anchor order preservation, checklist count
  preservation, body byte-count/hash preservation, and target title-hash
  preservation without printing raw paragraph text or UUIDs.
- `body list delete --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing ordinary list item on one
  note and verifies target ordinary-list selection, target anchor absence, list
  item count decrement, ordinary list anchor order preservation, checklist count
  preservation, and body byte-count/hash change without printing raw paragraph
  text or UUIDs.
- `body list line-break --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing ordinary list item on one
  note and inserts one soft line break through `ICNote.textStorage`, verifying
  target anchor/type/style preservation, list/checklist count preservation,
  paragraph count preservation, body byte-count delta, body hash change, and
  inserted-text hash/count evidence without printing the inserted character, raw
  paragraph text, titles, or UUIDs.
- `body list tab --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing ordinary list item on one
  note and inserts one literal tab through `ICNote.textStorage`, with the same
  privacy-safe verifier shape as `body list line-break`. Checklist tab
  insertion remains outside the accepted command surface.
- `body list end --id NOTE_ID (--paragraph PARAGRAPH_ID_SHA256|--ordinal N)
  --json` works in the default private-framework-backed build for one existing ordinary list item on one
  note and creates one following ordinary body paragraph through
  `ICNote.textStorage` and a fresh `ICTTMutableParagraphStyle` UUID, verifying
  target preservation, created body paragraph readback, list/checklist count
  preservation, paragraph-count delta, and body hash change without printing
  item text, paragraph text, titles, or UUIDs.
- `links add-paragraph --id SOURCE_NOTE_ID --target TARGET_NOTE_ID --paragraph
  PARAGRAPH_ID_SHA256 --dry-run --json` resolves a paragraph anchor by hash and
  emits no raw paragraph UUID, paragraph title, target note body, or internal
  link token.
- `links add-app --id NOTE_ID --url APP_URL --dry-run --json` accepts only
  non-web, non-file app URL schemes and emits no raw app URL.
- `links add-file --id NOTE_ID --file PATH --dry-run --json` accepts one
  existing readable regular local file or directory path, emits no raw path or
  file URL, and rejects missing, unreadable, and non-file/non-directory paths.
- `links audit --json` returns official Links workflow accounting without
  selectors or implementation calls, reports supported/delegated/gated status records,
  and rejects raw note/link/text/URL inputs before any link reader or writer is
  touched.
- `links update --id NOTE_ID --link LINK_ID --url URL --dry-run --json`
  resolves one web URL link from `links list` metadata, emits old/new URL
  hashes, and rejects file, app, ordinary note-to-note, paragraph/internal, and
  unchanged links.
- `links update-app --id NOTE_ID --link LINK_ID --url APP_URL --dry-run
  --json` resolves one app URL link from `links list` metadata, emits no raw
  app URL, emits old/new URL hashes, and rejects web, file, ordinary
  note-to-note, paragraph/internal, unsupported-scheme, and unchanged links.
- `links update-file --id NOTE_ID --link LINK_ID --file PATH --dry-run --json`
  resolves one file URL link from `links list` metadata, emits no raw local path
  or file URL, emits old/new URL hashes, and rejects web, app, ordinary
  note-to-note, paragraph/internal, missing/unreadable/non-file/non-directory,
  and unchanged links.
- `links update-paragraph --id NOTE_ID --link LINK_ID --target TARGET_NOTE_ID
  --paragraph PARAGRAPH_ID_SHA256 --dry-run --json` resolves one
  paragraph/internal paragraph link from `links list` metadata, resolves the
  target paragraph through `body structure` anchor hashes, emits no raw
  paragraph UUID, paragraph title, target note body, or internal link token, and
  rejects ordinary note-to-note, web, app, file, and unchanged paragraph targets.
- `links backlinks --id NOTE_ID --json` returns source note summaries and
  privacy-safe incoming-link metadata without note bodies, raw local file/app
  URLs, paragraph UUIDs, or raw internal link tokens.
- `links resolve --id NOTE_ID --link LINK_ID --json` resolves one selected link
  from `links list` metadata. It prints public web URLs when present, emits
  scheme/hash evidence for app and file URLs, emits target note and paragraph
  hashes for internal links, and hides raw internal tokens, raw paragraph UUIDs,
  paragraph titles, note bodies, raw app URLs, and raw local file URLs.
- `links remove-paragraph --id NOTE_ID --link LINK_ID --dry-run --json`
  resolves one paragraph/internal paragraph link from `links list` metadata and
  rejects ordinary note-to-note, web, app, and file links.
- `links remove-app --id NOTE_ID --link LINK_ID --dry-run --json` resolves one
  app URL link from `links list` metadata, emits no raw app URL, and rejects
  web, file, ordinary note-to-note, and paragraph/internal links.
- `links remove-file --id NOTE_ID --link LINK_ID --dry-run --json` resolves one
  file URL link from `links list` metadata, emits no raw local file URL, and
  rejects web, ordinary note-to-note, paragraph/internal, and app links.
- `state read --id NOTE_ID --json`, `state lockability --id NOTE_ID --json`, and
  `state audit [--folder FOLDER] --json` work in the default private-framework-backed build and emit only
  state flags/counts, note/account/provider lockability reason IDs/booleans/counts/hashes,
  aggregate lock/share/collaboration accounting, and verifier evidence; they do
  not emit note body text, titles, folder/account names, tag names, attachment
  titles or filenames, participant names, or collaboration handles.
- `export pdf`, `export markdown`, `export html`, `export rtf`,
  `export rtfd`, `import text`, `import markdown`, `import rtf`, `import rtfd`,
  `import html`, `import enex`, `replace markdown`, `replace html`,
  `replace rtf`, `replace rtfd`, and `print` dry-run paths return artifact,
  source, rich-replace, or external-dispatch summaries; tested execution paths
  verify file/package output, note readback, imported note readback, in-place
  rich body replacement readback, or print job evidence. Live execution should
  be done only against intentional test notes, destinations, and printers.
- `attachments copy --json` dry-run and tested execution paths include source
  byte hash, new attachment metadata/export hash, target note readback, and
  hash-only source/target evidence; live mutation should be done only against
  intentional test notes and attachments.
- `tags add/remove/convert-to-text/rename/delete --json` dry-run and tested
  execution paths include membership, body plaintext preservation,
  affected-note rename, or affected-note delete verification; live mutation
  should be done only against intentional test notes and tags.
- `move --json` dry-run and tested execution paths include destination and
  preservation verification; live mutation should be done only against an
  intentional test note.
- `copy --json` dry-run and tested execution paths include new-identity,
  source-preservation, destination, and content-preservation verification; live
  mutation should be done only against an intentional test note.
- `restore --json` dry-run and tested execution paths include restore-only
  preflight, identity preservation, destination, and content-preservation
  verification; live mutation should be done only against an intentional test
  note.
- `purge --json` dry-run and tested execution paths include restore-only
  preflight, destructive-selection gating, visible readback absence, and
  restorable readback absence; live mutation should be done only against an
  intentional deleted test note.
- `pin/unpin --json` dry-run and tested execution paths include current-state
  preflight, idempotent change detection, target pinned-state verification,
  and store pinned evidence when available; live mutation should be done only
  against an intentional test note.
- `folders create --json` dry-run and tested execution paths include folder
  name, account, parent placement, and store-evidence verification; live
  mutation should be done only against an intentional test account/folder.
- `folders rename --json` dry-run and tested execution paths include folder
  identity, target name, account preservation, parent preservation, and
  store-evidence verification; live mutation should be done only against an
  intentional test folder.
- `folders move --json` dry-run and tested execution paths include folder
  identity, name preservation, target parent or account-root placement,
  cross-account target account readback, bounded descendant account readback,
  and store-evidence verification; live mutation should be done only against an
  intentional test folder.
- `folders delete --json` dry-run and tested execution paths include visible
  folder removal and store-evidence verification; live mutation should be done
  only against an intentional test folder.
- `folders purge --json` dry-run and tested execution paths include visible
  and purgable-folder removal plus store-evidence verification; execution
  requires `--allow-destructive-selection` and live mutation should be done only
  against an intentional already-deleted test folder.
- Executed text, folder create/rename/move/delete/purge, web/app/file URL link
  add/remove, web/app/file URL link update, note-to-note link add/update/remove, paragraph
  note-link add/update/remove, note move/copy/restore/purge/pin/unpin, and delete
  mutations include a privacy-safe `verification` report, and stale or
  mismatched post-write readback fails the command.
- `doctor write-lab --json` reports required private write selectors without
  executing any write.
- `doctor rich-lab --json` reports required rich capability candidates without
  executing any rich write, lists accepted rich slices in
  `accepted_capability`, and lists still-gated math future readiness in
  `gated_future_capability`.
- Diagnostics do not print note bodies.
- No direct Notes store write SQL is introduced.

## Documentation Roles

Current architecture truth belongs in
`../../Architecture/Notes/Architecture.md`. Capability status belongs in
`../../Architecture/Notes/CapabilityList.md`. This guide should stay focused on
developer workflow, validation, and target-local operating notes.
