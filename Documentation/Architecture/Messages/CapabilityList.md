# Messages Capability List

## Source Authority

Messages capabilities are accepted from local Messages data and Messages.app
send behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Conversation reads | `conversations list/search` | Read-only local Messages database inspection | Bounded read; privacy failures fail closed. |
| Message reads | `list`, `search`, `read` | Read-only local Messages database inspection | Bounded read. |
| Sends | `send`, `send-conversation`, `send-many` | Messages.app structured send automation | Supports `--dry-run`; execution requires `--allow-external-dispatch` and recipient or conversation binding. |

## Rejected / Gated

- Generic chat automation.
- New group creation.
- File-transfer metadata until separately proven.
