# Keynote User Guide

Use `apple keynote --help` and subcommand help as the first reference.

Common reads:

```bash
apple keynote presentations list --path . --json
apple keynote presentations read --path Deck.key --json
apple keynote slides list --path Deck.key --json
```

Open and export use the DryRun safety flow:

```bash
apple keynote presentations export --path Deck.key --output Deck.pdf --format pdf --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Keynote/CapabilityList.md`.
