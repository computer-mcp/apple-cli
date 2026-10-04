# Keynote Architecture

`keynote` owns path-bounded `.key` file and package workflows under
`apple keynote`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

The target uses FileManager metadata, Keynote scripting, QuickLook cache
inspection, and NSWorkspace open actions. It has no private framework path.

## Source Authority

Keynote owns slide content, ordering, skipped state, presenter notes and PDF
rendering. Filesystem metadata describes the saved presentation. QuickLook
artifacts describe cached previews.

## Implementation Mechanisms

Native slide reads use the document ID and ordered slide collection exposed by
Keynote's scripting dictionary. Reads return default title/body text and plain
presenter notes, including skipped slides. `totalSlideCount` and `truncated`
describe the native collection and requested limit. Missing or invalid native
content produces an error.

Keynote exposes no persistent slide ID through this mechanism. Each response
has a new `snapshotID`; slide IDs have `identityKind: snapshot_position` and
identify positions only within that response. They cannot identify a slide
across edits, reordering or later reads.

Operations distinguish `live_document` from `opened_file`. Already-open
documents are borrowed without saving or closing. Only documents opened and
identified as belonging to the operation are closed, with saving disabled.

PDF export invokes Keynote with individual slides, skipped slides included,
and build stages disabled. The artifact must be a readable, unencrypted PDF
with one page per native slide. It is published without replacing an existing
destination. `verification` covers that artifact validation, rather than rich
content equivalence. Native failures and timeouts do not fall back to caches.

`previews list/export`, `preview-pdf` and `thumbnail` inspect or copy available
QuickLook cache artifacts. Preview order and IDs describe cache entries.
`package` copies a package presentation. These paths do not require Automation.

## Validation

Swift Testing covers typed native responses, cache independence, selection
limits, snapshot identity, native failures, PDF validation and destination
preservation. An opt-in dictionary test compiles scripts against installed
Keynote. Native workflow validation requires controlled presentations and
Automation permission; default tests and compilation do not prove rendering,
rich formatting preservation or multi-version behavior.
