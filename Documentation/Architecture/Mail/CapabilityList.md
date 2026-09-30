# Mail Capability List

## Source Authority

Mail capabilities are accepted from Mail.app behavior, the Mail scripting
surface, and the target-local CLI contract.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Account/mailbox reads | `accounts list`, `mailboxes list` | Mail.app structured scripting | Read-only. |
| Message metadata and body reads | `messages list/unread/search/read/body-preview` | Mail.app structured scripting | Body reads are bounded by explicit scope or byte caps. |
| Draft and send workflows | `messages draft/reply-draft/forward-draft/send` | Mail.app structured scripting | Supports `--dry-run`; send execution requires `--allow-external-dispatch`. |
| Mailbox mutation | `messages move/archive/delete` | Mail.app structured scripting | Supports `--dry-run`; execution revalidates the current message and mailbox scope before side effects. |

## Rejected / Gated

- Persistent `.emlx` or full-text indexes.
- Attachment extraction/save until separate privacy and path proof exists.
- Broad mailbox automation beyond accepted commands.
