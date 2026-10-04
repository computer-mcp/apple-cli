# Intelligence Developer Guide

Use package-local tests for Intelligence changes:

```bash
swift test --filter Intelligence
```

Risk-flagged commands must keep explicit `--allow-*` semantics for fixed-risk
local cache mechanisms.

Country-cache regressions use synthetic keyed archives with native UIDs, shared
active/history/local references, and unrelated country-like strings. They
verify complete object preservation, no-op bytes, rejection before backup or
unlock, write/readback failures, concurrent replacement, and exact rollback.

A separate explicit opt-in validates the host archive using copies in memory:

```bash
APPLE_CLI_RUN_INTELLIGENCE_COUNTRY_READONLY=1 swift test --filter IntelligenceCountryCacheReadonlyTests
```

This test reads the system country cache without writing it. It does not prove
country daemon acceptance, service availability, or model readiness. Default
package tests do not read that host cache.
