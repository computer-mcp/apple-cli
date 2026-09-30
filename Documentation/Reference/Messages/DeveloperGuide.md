# Messages Developer Guide

Use package-local tests for Messages changes:

```bash
swift test --filter Messages
```

Messages reads depend on local privacy permissions and database availability.
Sends should stay recipient-bound; execution requires `--allow-external-dispatch`.
