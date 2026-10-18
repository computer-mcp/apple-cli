# TCC Developer Guide

Use package-local tests for TCC changes:

```bash
swift test --filter TCC
```

TCC must remain a diagnostics and explicit recovery target, not a silent
permission bypass for other targets.
