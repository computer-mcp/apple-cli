# Notifications Developer Guide

Use package-local tests for Notifications changes:

```bash
swift test --filter 'SystemDomainCommandTests|CLIExecutableTests|AppleMCPAdapterTests'
```

This target is limited to notifications created by this tool.

AppleCLI owns the embedded executable Info.plist. Keep the backend's expected
bundle identity aligned with it and verify the actual built executable after
linking. A test-host bundle has a separate identity and must not accidentally
use the production notification namespace.

Use native callback results for submission and authorization. Preserve the
first completion, bound waits and retain possible-mutation details on timeout.
Do not infer rejected submission from a timeout or silently retry with a new ID.
Settings callbacks are read-only; permission requests are explicit mutations.

Keep API native error domain/code in diagnostics without echoing localized
descriptions that may include selected content. The ordinary suite exercises
production mapping and CLI behavior; it does not grant notification permission.

Reuse the shared `--limit` option. Scope native pending/delivered callbacks to
the request namespace before sorting and output limits. Preserve exact content,
time-interval/calendar trigger fields and native delivery dates; summaries omit
the body. Normalize IDs once semantically, with an idempotent 500-byte bound
including the namespace.

Removal APIs have no completion callback. Preflight the exact ID, remove only
that ID and query the selected collection again. Report attempted/presence/absence
separately; a readback failure must retain possible-mutation details. An absent
pending request may have fired, and concurrent ID replacement has no atomic
comparison guarantee. Never clear the application's entire collection.

For native scheduling verification, use fresh `apple-cli:` IDs and one-time
delays long enough for independent readback and cancellation before firing.
Record exact IDs and payloads before submission, and verify cleanup from a
separate process. Confirm that a second owned request is unchanged. Authorized
scheduling, nonempty removal and presentation are distinct evidence; empty-query
and no-op proofs do not replace them. Their current gaps live in the capability list.
