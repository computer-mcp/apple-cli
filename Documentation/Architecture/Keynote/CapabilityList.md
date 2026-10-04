# Keynote Capability List

## Source Authority

Keynote's scripting dictionary owns native slide and PDF behavior. File and
package metadata and QuickLook cache inspection have separate authority.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Presentation metadata | `presentations list/search/read` | FileManager, file and package `.key` paths | Path-bounded; metadata does not extract slide content. |
| Slide reads | `slides list` | Keynote scripting | Automation required; ordered default title/body, skipped state and plain presenter notes; bounded response with snapshot-position IDs. Native workflow coverage requires controlled fixtures. |
| Cached image previews | `previews list/export` | QuickLook cache entries | No relationship to native slide count or order; export requires `--allow-artifact-action`. |
| Native PDF export | `presentations export --format pdf` | Keynote export | `--allow-artifact-action`; readable PDF and page-count validation before publication; native rendering coverage requires controlled fixtures. |
| Cached PDF/thumbnail copy | `presentations export --format preview-pdf/thumbnail` | QuickLook cache | Explicit cache source; cache may be absent or stale; `--allow-artifact-action`. |
| Package copy | `presentations export --format package` | FileManager package copy | Package source and fresh destination required; `--allow-artifact-action`. |
| Presentation open | `presentations open` | NSWorkspace | `--allow-external-dispatch`; reports submitted, rather than app readiness. |

## Gated Capabilities

- Rich text, arbitrary slide objects, tables, media and layout extraction.
- Native image, PowerPoint and other export formats.
- Presentation and slide writes.
- Native workflow and version coverage beyond validated fixtures.
