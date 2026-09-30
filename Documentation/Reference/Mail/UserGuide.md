# Mail User Guide

Use `apple mail --help` and subcommand help as the first reference.

Common reads:

```bash
apple mail accounts list --json
apple mail mailboxes list --account ACCOUNT_ID --json
apple mail messages search --mailbox Inbox --query "invoice" --json
apple mail messages body-preview --mailbox Inbox --id MESSAGE_ID --max-bytes 20000 --json
```

Draft, send, and mailbox mutations use the DryRun safety flow:

```bash
apple mail messages draft --to user@example.com --subject "Hi" --body "Hello" --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Mail/CapabilityList.md`.
