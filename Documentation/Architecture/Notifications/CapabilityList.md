# Notifications Capability List

## Source Authority

Notifications capabilities are accepted for notifications created by this tool.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Preview | `preview` | Target-local notification preview | Read-only preview. |
| Send | `send` | Target-local notification delivery | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |

## Rejected / Gated

- Global notification history.
- Broad system notification automation.
