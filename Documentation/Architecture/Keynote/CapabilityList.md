# Keynote Capability List

## Source Authority

Keynote capabilities are accepted from `.key` package metadata and QuickLook
behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Presentation reads | `presentations list/search/read` | File/package metadata | Path-bounded read. |
| Slide reads/export | `slides list/export` | QuickLook-backed slide output | Read-only for listing; export supports `--dry-run` and execution requires `--allow-artifact-action`. |
| Presentation open/export | `presentations open/export` | Presentation open action and QuickLook/package export | Supports `--dry-run`; open execution requires `--allow-external-dispatch` and export execution requires `--allow-artifact-action`. |

## Rejected / Gated

- Rich app-native extraction.
- Presentation writes.
- Deeper Keynote automation until separately proven.
