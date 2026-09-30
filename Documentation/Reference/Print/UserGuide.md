# Print User Guide

Use `apple print --help` and subcommand help as the first reference.

Common reads:

```bash
apple print printers list --json
apple print jobs list --json
```

Submitting and canceling jobs use the DryRun safety flow:

```bash
apple print jobs submit --printer PRINTER_ID --file document.pdf --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Print/CapabilityList.md`.
