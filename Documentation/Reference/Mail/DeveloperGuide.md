# Mail Developer Guide

Use package-local tests for Mail changes:

```bash
swift test --filter Mail
```

Run `apple mail doctor --json` when diagnosing Mail.app automation,
authorization, or local mailbox availability.
