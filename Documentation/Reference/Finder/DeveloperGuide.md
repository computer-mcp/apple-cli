# Finder Developer Guide

Use package-local tests for Finder changes:

```bash
swift test --filter Finder
```

Keep destructive file behavior path-bounded; artifact execution requires `--allow-artifact-action`.
