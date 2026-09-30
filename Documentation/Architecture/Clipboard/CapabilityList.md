# Clipboard Capability List

## Source Authority

Clipboard capabilities are accepted from NSPasteboard behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Type/read | `types`, `read` | NSPasteboard | Sensitive bounded read. |
| Mutation | `write`, `clear` | NSPasteboard | Supports `--dry-run`; execution requires `--allow-persistent-action`. |

## Rejected / Gated

- Clipboard history.
- Cross-device clipboard automation.
