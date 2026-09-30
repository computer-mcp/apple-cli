# Clipboard User Guide

Use `apple clipboard --help` and subcommand help as the first reference.

Common reads:

```bash
apple clipboard types --json
apple clipboard read --json
```

Writes and clear use the DryRun safety flow:

```bash
apple clipboard write --text "hello" --dry-run --json
apple clipboard clear --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Clipboard/CapabilityList.md`.
