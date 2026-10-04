# Native Fixture Validation

Default Swift Testing checks use controlled backends and temporary data.
`NativeMutationFixtureTests` provides separate, opt-in Notes and Reminders
workflows against configured app data. A skipped test provides no native
mutation evidence.

## Configure the Test Environment

Use the macOS user and account selected for native validation. Prepare a
dedicated, empty Notes folder or standard Reminders list for each run. Generate a fresh UUID, and
name the container `Apple CLI Fixture <lowercase-run-uuid>`.

The Notes folder must support editing and must be unshared, writable, ordinary,
and have no child folders. Default, system, trash, and smart folders are
refused. The Reminders list must be writable, standard, and unshared. Container
identity, name, and ownership are checked again before object mutations and
cleanup. Preparation and removal of the test containers belong to the test
environment; the suite creates and cleans its own note or reminder.

Read account and container identities through the package CLI:

```bash
.build/debug/apple notes accounts list --json
.build/debug/apple notes folders list --account ACCOUNT_ID --json
.build/debug/apple reminders lists list --json
```

Use the exact IDs returned by the app. Notes IDs use `x-coredata://`; Reminders
IDs use `x-apple-reminderkit://`. Names, default selectors, and private-list
identifiers cannot select a mutation fixture.

## Fixture Manifest

Store a JSON manifest outside published product content. The
[manifest schema](NativeFixtureManifest.schema.json) describes its fields.

| Field | Required value |
| --- | --- |
| `schemaVersion` | Integer `1` |
| `runID` | Fresh UUID for this run |
| `host.userID` | Numeric UID of the test user |
| `host.osVersion` | OS version as `major.minor.patch` |
| `host.osBuild` | Exact OS build |
| `host.architecture` | `arm64` or `x86_64` |
| `evidenceDirectory` | Absolute canonical path ending in the lowercase run UUID; its parent must exist |
| `notes.accountID`, `notes.containerID` | Exact test account and folder IDs when running Notes |
| `reminders.accountID`, `reminders.containerID` | Exact test source and list IDs when running Reminders |
| `<target>.appVersion`, `<target>.appBuild` | Exact installed app version and build |

Obtain UID and OS metadata with `id -u`, `sw_vers`, and `uname -m`. App version
and build are `CFBundleShortVersionString` and `CFBundleVersion` from the
installed app's `Info.plist`. An app or OS update requires fresh metadata.
The active target's scope must be present; the other scope may be omitted.
The manifest must be a regular file no larger than 64 KiB.

The suite creates private run and target directories. An existing target run
directory is refused, including a previous failed run. Keep its evidence and
inspect any remaining objects before preparing a new UUID and container name.

## Run an Individual Workflow

Build the package executables and tests from the repository root:

```bash
xcrun swift build --build-tests --force-resolved-versions --jobs 2
```

Set `APPLE_CLI_NATIVE_FIXTURE_MANIFEST` to the absolute path of the prepared
manifest. Enable and select only the workflow being validated:

```bash
APPLE_CLI_RUN_NOTES_MUTATION_TESTS=1 \
  xcrun swift test --skip-build --force-resolved-versions \
  --filter notesSaveFormatAndColdReadback

APPLE_CLI_RUN_REMINDERS_MUTATION_TESTS=1 \
  xcrun swift test --skip-build --force-resolved-versions \
  --filter remindersCompletionHistoryAndColdReadback
```

Both workflows are serialized within their suite. Run one test process at a
time against the app environment. Each CLI invocation starts a new process,
has a 20-second deadline, and bounds output to 2 MiB. The suite invokes the
repository's `.build/debug/apple`; it does not select an executable from `PATH`
or the manifest.

Notes creates a marked note, applies bold and strikethrough to a Unicode
selection, checks an idempotent retry, compares plain content and identity
after cold reads, and checks structure and native HTML export. It also renames
the note, verifies preserved content, formatting and paragraph identities,
and checks that a repeated title edit is a no-op. Reminders
creates a marked reminder, completes it with a historical timestamp, retries,
and explicitly corrects the timestamp while checking unrelated fields.
These are specific workflow checks; broader target and OS coverage requires
additional validation.

## Evidence and Recovery

Each target directory contains a manifest snapshot, container snapshots,
created object, before/after records, operation receipts, and `ledger.json`.
Command receipts retain bounded stdout and stderr, including failed command
results. Notes also retains the native HTML artifact. Snapshot files are written
exclusively. Evidence includes app content and exact IDs; keep it local to the
test environment.

The ledger records intent before creation and stores the returned object ID
before subsequent writes. Cleanup checks the recorded ID, title marker, and
current container membership. A failed creation response can be reconciled
only to a unique object matching the recorded intent in the dedicated
container. A controlled rename records the pending title before the command;
only that object's exact old or pending title remains owned until cold readback
confirms the transition. Other renamed, moved, ambiguous, or foreign objects stop cleanup.

Notes cleanup moves the owned note to Recently Deleted and purges that exact
ID after matching its title. Purge readback must return an empty exact-ID
result or the matching `not_found` error and exit code. Permission failures,
invalid output, and timeouts leave cleanup unverified. Reminders deletion
requires cold confirmation that the ID has left its dedicated list and that
ordinary exact-ID reads return the matching `not_found` result.

Validation failures stop the workflow and still enter cleanup. The ledger
retains operation and cleanup failures separately, with error codes and
diagnostic hashes. Objects are marked cleaned only after the applicable
readback succeeds. If the process stops or cleanup fails, inspect the ledger
and current native state, then recover only the recorded objects through the
owning CLI. Keep any unresolved object as a reported residual; do not reuse
the old run directory or infer success from a submitted operation.
