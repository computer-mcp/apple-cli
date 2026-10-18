# Finder User Guide

Use `apple finder --help` and subcommand help as the first reference.

Common reads:

```bash
apple finder items list --path . --json
apple finder items metadata --path Package.swift --json
apple finder items search --path . --query README --json
```

File actions and mutations use the DryRun safety flow:

```bash
apple finder items reveal --path Package.swift --dry-run --json
apple finder items move --path old.txt --to new.txt --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Finder/CapabilityList.md`.
