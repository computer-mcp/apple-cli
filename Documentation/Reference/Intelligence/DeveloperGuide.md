# Intelligence Developer Guide

Use package-local tests for Intelligence changes:

```bash
swift test --filter Intelligence
```

Risk-flagged commands must keep explicit `--allow-*` semantics for fixed-risk
local cache mechanisms.
