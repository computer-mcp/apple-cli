# Finder Capability List

## Source Authority

Finder capabilities are accepted from path-bounded filesystem behavior and
Finder-adjacent user actions.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| File metadata | `items list/search/metadata` | FileManager/resource APIs | Path-bounded read. |
| External actions | `items open/reveal` | NSWorkspace/Finder-bound actions | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |
| File mutation | `items move/trash/delete/write-text/overwrite-text` | FileManager | Supports `--dry-run`; execution requires `--allow-artifact-action` and remains single-file bounded where applicable. |
| Tags | `items tags set/add/remove/clear` | File resource metadata APIs | Supports `--dry-run`; execution requires `--allow-artifact-action`. |

## Rejected / Gated

- Broad overwrite.
- Directory delete and recursive delete.
- Bulk content mutation.
