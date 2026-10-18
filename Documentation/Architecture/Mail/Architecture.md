# Mail Architecture

`mail` owns local Mail.app workflows under `apple mail`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Mail currently uses target-local structured Mail.app scripting for
accepted account, mailbox, message, draft, send, and mailbox action workflows.
It does not currently rely on a broad private Mail implementation mechanism.

## Source Authority

The Mail.app user model and local Mail scripting dictionary are the accepted
source for accounts, mailboxes, message metadata, drafts, sends, and mailbox
actions.

## Implementation Mechanisms

Mail uses target-local structured Mail.app scripting. Persistent `.emlx` or
full-text indexing is not part of the accepted implementation mechanism.

Send success reports Mail's accepted submission through `sent.submitted`.
Rejected or unconfirmed submissions return a structured error; Mail owns
delivery tracking. Body preview limits apply to UTF-8 bytes.

## Validation

Use `apple mail doctor --json`, bounded message commands, and Mail command
tests. Detailed command status lives in `CapabilityList.md`.
