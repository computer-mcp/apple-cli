# Clipboard Capability List

## Source Authority

Clipboard capabilities follow public NSPasteboard and NSPasteboardItem behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Metadata | `types` | NSPasteboard | Type union and `changeCount`; no content output. |
| Text | `read [--type] [--max-bytes]` | NSPasteboard | Explicit sensitive read; UTF-8 byte cap; rejects changed ownership or unavailable declared text. |
| Typed items | `items read [--type] [--limit] [--max-bytes]` | NSPasteboardItem | Ordered items and representations, base64 bytes, unavailable data, total count and explicit filtered/truncated state. |
| Text replacement | `write --text` | Fresh NSPasteboardItem | Explicit empty text supported; size preflight, unchanged-state check and native readback. |
| Typed replacement | `items write --input` | Fresh NSPasteboardItems | Complete JSON payload/envelope; preserves declared order and bytes, reports native failures. Truncated, filtered, unavailable or file-promise snapshots cannot be replayed. |
| Device scope | `--current-host-only` on writes | NSPasteboard.ContentsOptions | Applies the current-device restriction when claiming new contents; renews ownership even for identical data. |
| Clear | `clear` | NSPasteboard | Empty no-op and native empty readback. |
| Conditional replacement | `--if-change-count` on writes/clear | Ownership counter | Refuses stale preconditions; does not reserve the pasteboard or provide atomic compare-and-swap. |
| Diagnostics | `doctor` | Metadata and macOS access behavior | Does not request content; exposes configured programmatic-read denial when available. |

All mutations support `--dry-run`; execution requires
`--allow-persistent-action`. Raw data defaults to 1 MiB with a 64 MiB ceiling.
Item reads default to 50 with a ceiling of 500. Oversized content produces an
error, not a partial successful representation.

## Rejected / Gated

- Clipboard history.
- Cross-device clipboard automation.
- Live file-promise transfer and drag-session ownership.

Consumers retain their own permission requirements for referenced file URLs.
Unique-pasteboard native validation does not prove general-pasteboard privacy
access or compatibility on other macOS versions.
