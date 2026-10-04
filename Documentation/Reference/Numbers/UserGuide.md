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
apple numbers tables set-cell --path Budget.numbers --sheet Sheet1 --table Table1 --row 1 --column 1 --value "Quarterly total" --dry-run --json
```

Cell writes set literal text. Close the source document in Numbers before
executing a write so that the command owns opening, saving, and closing it.
Execution requires `--allow-persistent-action`.

Equal displayed text does not skip a write when the actual value is numeric,
a date, a boolean, or a formula. A write includes `verified: true` after saved
readback confirms the requested literal text and no formula. A no-op is based
on the current native cell value. If
readback cannot confirm the result, the command reports an error with
`mutation_may_have_occurred: "true"`; inspect the document before retrying.

The detailed capability boundary lives in
`../../Architecture/Numbers/CapabilityList.md`.
