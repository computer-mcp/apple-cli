# FaceTime User Guide

Use `apple facetime --help` and subcommand help as the first reference.

Common reads and previews:

```bash
apple facetime contacts resolve --query Ada --json
apple facetime calls prepare --to +15555550100 --json
```

Starting a call uses the DryRun safety flow:

```bash
apple facetime calls start --to +15555550100 --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/FaceTime/CapabilityList.md`.
