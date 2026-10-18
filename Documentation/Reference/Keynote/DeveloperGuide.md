# Keynote Developer Guide

Use package-local Swift Testing for Keynote changes:

```bash
swift test --filter 'KeynoteContentTests|IWorkDocumentCommandTests'
```

The installed scripting dictionary can be checked independently:

```bash
APPLE_CLI_VALIDATE_IWORK_SDEF=1 swift test --filter KeynoteContentTests.keynoteScriptsCompileAgainstInstalledDictionary
```

That check compiles the scripts without executing document reads or exports.
Native acceptance needs controlled presentations with known slide order,
skipped state, default text, presenter notes and PDF page counts. Test both
single-file and package forms, reordered slides, absent/stale caches, borrowed
unsaved documents, source preservation and Automation failures.

Keep typed decoding strict: incomplete rows, missing required metadata and
unknown scalar types must fail. Optional native text remains unknown when
unavailable. Snapshot-position identities must not become persistent selectors.
Export verification must precede publication and preserve existing destinations.
