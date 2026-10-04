# Clipboard Developer Guide

Use the existing SystemDomainCommandTests suite for command behavior:

```bash
swift test --filter SystemDomainCommandTests
```

The native workflow is explicitly enabled:

```bash
APPLE_CLI_RUN_CLIPBOARD_INTEGRATION_TESTS=1 \
  swift test --filter clipboardNativeReplacementPreservesItemsAndVerifiesChanges
```

It creates a unique named pasteboard and temporary files, runs the production
backend, verifies ordered representations and native RTF/image/URL consumers,
and exercises byte bounds, no-op writes, stale counters and data providers.
Cleanup clears the owned board, checks empty state and requests its global
release. General-pasteboard content is not read or written by this workflow.

ClipboardCLI owns payload validation, byte/item bounds, native failure
handling and mutation verification. MCP discovers its typed command tree
through CLI help. Keep tests that inspect production behavior in the owning
suite; avoid separate implementations of native conversion rules in fakes.

Raw representations are obtained as complete AppKit Data values before the
byte cap is checked. Retain checks after provider calls: promised data can
be unavailable, or a provider can change ownership while fulfilling it.
`changeCount` tracks ownership, not every provider update.

Replacement uses fresh, unbound NSPasteboardItems. Verify all requested bytes
and ordering after native writes. Native compatibility formats can be added
by the system; pre-write no-op decisions account for RTF-derived text only
after comparing its decoded text. Read snapshots include those generated
formats.

Input types follow [Apple's UTI syntax](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_conc/understand_utis_conc.html) and AppKit item validation. Previews prepare fresh in-memory items with the same validation used before replacement.

Input JSON is read from a bounded regular file and checked for file changes.
Its encoded cap is `4 × ceil(maxBytes / 3) + 2 MiB` for base64 data and JSON
metadata. Decoded representations still share the raw byte cap.
Snapshot-only metadata is not an input mutation instruction.

Use [NSPasteboard's current-device contents option](https://developer.apple.com/documentation/appkit/nspasteboard/contentsoptions/currenthostonly)
for `--current-host-only`. An explicit restriction requires
`prepareForNewContents(with:)`, even when bytes match, because the public API
cannot read back the active contents options. Preserve the existing counter
precondition and content verification around that ownership claim.

File-promise formats come from NSFilePromiseReceiver's public
`readableDraggedTypes`. Reject them during complete input validation before
obtaining ownership. [Apple's file-promise API](https://developer.apple.com/documentation/appkit/supporting-drag-and-drop-through-file-promises)
requires provider and receiver lifecycles and asynchronous file creation;
serializing their metadata does not supply that behavior. Raw item reads do
not call `receivePromisedFiles(atDestination:options:operationQueue:reader:)`.

The framework provides no atomic conditional replacement. Preserve a newer
owner on verification failures; report possible mutation rather than restoring
an old snapshot. Native tests on unique boards do not validate the general
pasteboard's per-app privacy setting or another macOS release.
