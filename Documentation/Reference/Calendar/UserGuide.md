# Calendar User Guide

Use `apple calendar --help` and subcommand help as the first reference.

Common reads:

```bash
apple calendar calendars list --json
apple calendar events list --from 2026-01-01 --to 2026-01-31 --json
apple calendar events read --id EVENT_ID --json
apple calendar availability check --from 2026-01-01T09:00:00Z --to 2026-01-01T10:00:00Z --json
```

Event export and mutations use the DryRun safety flow:

```bash
apple calendar events create --calendar Work --title "Review" --start 2026-01-01T09:00:00Z --end 2026-01-01T10:00:00Z --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Calendar/CapabilityList.md`.
