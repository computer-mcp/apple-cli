# Contacts Capability List

## Source Authority

Contacts capabilities are accepted from Contacts.framework and the target-local
CLI contract.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Contact reads | `search`, `read`, `duplicates` | Contacts.framework | Read-only or bounded private data reads. |
| Group reads | `groups list`, `groups members` | Contacts.framework | Read-only. |
| Import/export | `export`, `import` | Contacts.framework vCard APIs | Supports `--dry-run`; export execution requires `--allow-artifact-action` and import execution requires `--allow-external-dispatch`. |
| Contact mutation | `create`, `update`, `delete`, `delete-matching` | Contacts.framework | Supports `--dry-run`; execution revalidates current selector or query scope, and broad delete selection requires `--allow-destructive-selection`. |
| Group membership | `groups add-member`, `groups remove-member` | Contacts.framework | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |

## Rejected / Gated

- Automatic merge/update-on-import without explicit duplicate policy.
- Broad bulk profile rewrites outside accepted selectors.
