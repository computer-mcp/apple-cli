# Pages Capability List

## Source Authority

Pages capabilities are accepted from `.pages` package metadata and QuickLook
behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Document reads | `documents list/search/read` | File/package metadata | Path-bounded read. |
| Open/export | `documents open/export` | Document open action and QuickLook/package export | Supports `--dry-run`; open execution requires `--allow-external-dispatch` and export execution requires `--allow-artifact-action`. |

## Rejected / Gated

- Rich app-native export.
- Pages document writes.
- Deep content extraction beyond accepted metadata/export behavior.
