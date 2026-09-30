# Maps Capability List

## Source Authority

Maps capabilities are accepted from place/direction lookup behavior and
validated Maps URL actions.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Place lookup | `places search`, `places read` | CoreLocation-backed lookup | Read-only. |
| Directions | `directions preview` | Coordinate/query-aware preview planning | Read-only preview. |
| Open action | `open` | Validated Maps URL external action | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |

## Rejected / Gated

- Raw Maps.app scripting.
- Unvalidated external URL opens.
