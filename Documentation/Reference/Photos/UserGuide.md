# Photos User Guide

Use `apple photos --help` and subcommand help as the first reference.

Common reads:

```bash
apple photos libraries list --json
apple photos media-items search --keyword travel --limit 20 --json
apple photos albums list --json
apple photos folders list --json
```

Import/export and metadata mutation workflows use `DryRun` payloads or strong gates
where command help requires them:

```bash
apple photos exports export --library "$HOME/Pictures/Photos Library.photoslibrary" --destination ./export --dry-run --json
```

For authorized export cleanup, `.apple-cli-photos-keep` in the export
destination supplies additional keep patterns, one per line. Empty lines and
lines beginning with `#` are ignored. Cleanup protects this file and retained
matches together with current exports, reports and state.

The detailed capability boundary lives in
`../../Architecture/Photos/CapabilityList.md`.
