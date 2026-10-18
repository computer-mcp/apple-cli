# Pages User Guide

Use `apple pages --help` and subcommand help as the first reference.

Common reads:

```bash
apple pages documents list --path . --json
apple pages documents read --path Draft.pages --json
```

Open and export use the DryRun safety flow:

```bash
apple pages documents export --path Draft.pages --output Draft.pdf --format pdf --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Pages/CapabilityList.md`.
