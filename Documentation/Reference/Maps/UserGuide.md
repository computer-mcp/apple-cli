# Maps User Guide

Use `apple maps --help` and subcommand help as the first reference.

Common reads and previews:

```bash
apple maps places search --query "coffee" --json
apple maps places read --id PLACE_ID --json
apple maps directions preview --from "Cupertino" --to "San Francisco" --json
```

Opening Maps uses the DryRun safety flow:

```bash
apple maps open --query "Apple Park" --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Maps/CapabilityList.md`.
