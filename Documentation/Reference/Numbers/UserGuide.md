# Numbers User Guide

Use `apple numbers --help` and subcommand help as the first reference.

Common reads:

```bash
apple numbers documents list --path . --json
apple numbers documents read --path Budget.numbers --json
apple numbers sheets list --path Budget.numbers --json
apple numbers tables read --path Budget.numbers --sheet Sheet1 --table Table1 --json
```

Open/export/cell writes use the DryRun safety flow:

```bash
apple numbers tables set-cell --path Budget.numbers --sheet Sheet1 --table Table1 --cell A1 --value "42" --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Numbers/CapabilityList.md`.
