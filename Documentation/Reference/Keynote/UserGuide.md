# Keynote User Guide

Use `apple keynote --help` and subcommand help as the first reference.

Read metadata or native slides:

```bash
apple keynote presentations list --path . --json
apple keynote presentations read --path Deck.key --json
apple keynote slides list --path Deck.key --limit 50 --json
```

File and package presentations are accepted. Native slide reads require Keynote
and Automation permission for the process running `apple`. They include skipped
slides, default title/body text and plain presenter notes. `totalSlideCount`
reports all slides; `truncated` reports whether the limit shortened the result.
An unavailable native read returns an error.

`documentID` identifies the open Keynote document. Slide `id` values identify
positions within one `snapshotID`; `identityKind` is `snapshot_position`. Read
again after editing or reordering. These IDs cannot track a slide between reads.
`readSource` indicates whether the operation borrowed a `live_document` or
opened the saved file as `opened_file`. Borrowed documents keep their unsaved
edits and remain open.

Export a native PDF, including skipped slides with one page per slide:

```bash
apple keynote presentations export --path Deck.key --to Deck.pdf --format pdf --dry-run --json
apple keynote presentations export --path Deck.key --to Deck.pdf --format pdf --allow-artifact-action --json
```

A dry run validates paths and formats without rendering. Execution requires
Automation and a fresh destination. The result includes document identity,
source, page count, bytes and SHA-256. Artifact verification checks PDF validity
and page count. If a native operation times out, inspect the reported staging
path before retrying. `residualArtifactPaths` reports staging artifacts when
publication succeeds but cleanup cannot remove them.

Inspect or copy available cache images independently:

```bash
apple keynote previews list --path Deck.key --json
apple keynote previews export --path Deck.key --to DeckPreviews --format images --dry-run --json
apple keynote previews export --path Deck.key --to DeckPreviews --format images --allow-artifact-action --json
```

Preview order describes cache files. Missing previews do not imply an empty
presentation. These commands inspect package caches; they do not extract caches
from single-file presentations. `presentations export --format preview-pdf`
copies the cached PDF, `thumbnail` copies the cached JPEG, and `package` copies
a package presentation. Cached artifacts may be absent or stale.

Open actions require `--allow-external-dispatch`; exports require
`--allow-artifact-action`. The capability boundary lives in
`../../Architecture/Keynote/CapabilityList.md`.
