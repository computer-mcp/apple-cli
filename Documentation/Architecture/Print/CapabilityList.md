# Print Capability List

## Source Authority

Print capabilities are accepted from local CUPS printer and job behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Printer reads | `printers list/read` | CUPS inspection | Read-only. |
| Job reads | `jobs list` | CUPS inspection | Read-only. |
| Job actions | `jobs submit`, `jobs cancel` | Bounded `lp`/`cancel` subprocess actions | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |

## Rejected / Gated

- App-specific print workflows until separately proven.
- Silent print submission without explicit external-dispatch authorization.
