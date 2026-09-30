# Calendar Developer Guide

Use package-local tests for Calendar changes:

```bash
swift test --filter EventKit
```

Run `apple calendar doctor --json` when diagnosing EventKit authorization or
local calendar availability.
