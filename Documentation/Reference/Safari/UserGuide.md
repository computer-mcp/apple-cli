# Safari User Guide

Use `apple safari --help` and subcommand help as the first reference.

Common reads:

```bash
apple safari windows list --json
apple safari tab current --json
apple safari pages read --window-index 1 --tab-index 1 --include text --max-bytes 20000 --json
apple safari tab group list --json
```

Browser mutations and persistent actions use target-local gates:

```bash
apple safari tab open --url https://example.com --json
apple safari reading-list add --url https://example.com --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Safari/CapabilityList.md`.
