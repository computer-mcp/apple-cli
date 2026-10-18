# Messages User Guide

Use `apple messages --help` and subcommand help as the first reference.

Common reads:

```bash
apple messages conversations list --json
apple messages search --query "meeting" --json
apple messages read --id MESSAGE_ID --json
```

Sends use the DryRun safety flow:

```bash
apple messages send --to +15555550100 --text "Running late" --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Messages/CapabilityList.md`.
