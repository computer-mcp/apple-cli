# Clipboard Developer Guide

Use package-local tests for Clipboard changes:

```bash
swift test --filter SystemDomain
```

Clipboard reads can expose sensitive local data; keep output explicit and
bounded by command policy.
