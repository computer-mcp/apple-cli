# Numbers Capability List

## Source Authority

Numbers capabilities are accepted from `.numbers` package metadata, QuickLook,
and proven Numbers.app sheet/table scripting.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Document reads | `documents list/search/read` | File/package metadata | Path-bounded read. |
| Sheet/table reads | `sheets list`, `tables read` | Numbers.app structured scripting | Bounded read. |
| Export/open | `documents open/export`, `tables export` | QuickLook/package export and app action | Supports `--dry-run`; open execution requires `--allow-external-dispatch` and export execution requires `--allow-artifact-action`. |
| Cell write | `tables set-cell` | Numbers.app structured scripting | Supports `--dry-run`; execution requires `--allow-persistent-action` and a closed source document. Compares actual text/type/formula and verifies saved readback. |

## Rejected / Gated

- Formula-looking values.
- Range edits, row/column edits, document create/update.
- Broader writes until separately proven.
