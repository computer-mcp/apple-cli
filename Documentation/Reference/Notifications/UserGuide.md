# Notifications User Guide

Use `apple notifications --help` and subcommand help as the first reference.

Preview and send:

```bash
apple notifications preview --title "Build" --body "Done" --json
apple notifications send --title "Build" --body "Done" --dry-run --json
```

Check this tool's native authorization:

```bash
apple notifications settings --json
apple notifications doctor --json
```

Ask for authorization explicitly:

```bash
apple notifications permissions request --dry-run --json
apple notifications permissions request --allow-persistent-action --json
```

The system may present a permission prompt for **Apple CLI**. Denied settings
can be changed in System Settings. Preview and diagnostics do not request
permission; sending does not request it automatically.

After authorization, submit immediately or with a one-time delay:

```bash
apple notifications send --title "Build" --body "Done" \
  --id build-result --delay-seconds 60 --allow-external-dispatch --json
```

The returned ID is `apple-cli:build-result`. Reusing an ID replaces that native
request. Omit `--id` to generate a new ID for each submission. Delays accept
whole seconds from 1 to 604800; omitted delays submit immediately.
Normalized IDs, including `apple-cli:`, accept at most 500 UTF-8 bytes.

`submitted: true` means the native service accepted the request. Focus and
system presentation settings affect whether it appears. Native rejection is
an error. If an add times out, `mutation_may_have_occurred` means the result is
unknown; keep the reported ID when diagnosing the request.

Inspect requests waiting for their trigger:

```bash
apple notifications pending list --limit 50 --json
apple notifications pending read --id build-result --json
apple notifications pending cancel --id build-result --dry-run --json
apple notifications pending cancel --id build-result --allow-persistent-action --json
```

Lists return summaries sorted by ID; `--limit` accepts 1...500 and defaults to 50.
Exact reads include title, subtitle, body and trigger information. These queries
do not request notification permission. A missing read returns `not_found`.

Inspect or remove this tool's entries still in Notification Center:

```bash
apple notifications delivered list --json
apple notifications delivered read --id build-result --json
apple notifications delivered remove --id build-result --allow-persistent-action --json
```

Removal results distinguish `attempted`, `wasPresent` and `verifiedAbsent`.
An already absent ID is a no-op. After a removal call, the tool queries the
selected collection again; failed verification reports an error and possible
mutation. No other IDs are removed.

A request can fire while cancellation is in progress. Pending absence therefore
does not prove it was never displayed; delivered entries can be inspected
separately. Delivered entries do not establish user-read status or complete
notification history. Reusing the same ID concurrently can change which native
request an exact-ID removal affects.

The detailed capability boundary lives in
[Notifications Capability List](../../Architecture/Notifications/CapabilityList.md).
