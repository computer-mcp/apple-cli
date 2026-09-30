# Calendar Capability List

## Source Authority

Calendar capabilities are accepted from EventKit behavior and the local CLI
contract.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Calendar reads | `calendars list` | EventKit | Read-only; authorization failures are explicit. |
| Event reads | `events list/search/read/occurrences/stats`, `availability check` | EventKit | Date ranges and limits bound output. |
| Event export | `events export` | EventKit plus file output | Supports `--dry-run`; execution requires `--allow-artifact-action`. |
| Event mutation | `events create/update/delete` | EventKit | Supports `--dry-run`; execution uses current event identity and attendee metadata. |

## Rejected / Gated

- Occurrence-scoped mutation.
- Attendee invite administration beyond accepted metadata behavior.
- Broad calendar-server administration.
