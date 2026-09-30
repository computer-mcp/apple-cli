# Notifications User Guide

Use `apple notifications --help` and subcommand help as the first reference.

Preview and send:

```bash
apple notifications preview --title "Build" --body "Done" --json
apple notifications send --title "Build" --body "Done" --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Notifications/CapabilityList.md`.
