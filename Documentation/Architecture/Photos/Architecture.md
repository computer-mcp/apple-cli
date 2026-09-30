# Photos Architecture

`photos` owns Photos library, media, album, folder, import, export, metadata,
slideshow, and hook workflows under `apple photos`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Photos currently uses read-only SQLite snapshots, Photos.app
structured scripting where proven, file/ImageIO/CoreGraphics helpers, optional
explicit exiftool, and gated hook subprocesses. It does not currently rely on
a broad private Photos implementation mechanism.

## Source Authority

Accepted Photos capabilities come from Photos.app user-visible behavior,
Photos.app scripting where proven, read-only local Photos library snapshots,
and target-local export/metadata mechanics.

## Implementation Mechanisms

Photos uses read-only SQLite snapshots, Photos.app structured scripting,
FileManager/ImageIO/CoreGraphics export helpers, optional explicit exiftool
calls, and gated Swift or shell hook subprocesses. Direct Photos database
writes, raw AppleScript/JXA/UI runners, arbitrary external-tool passthrough,
and unsafe in-library original mutation are rejected.

## Validation

Use default Photos tests for snapshot/query/export behavior and gated
Photos.app-backed Swift Testing only with a copied throwaway library. Detailed
capability status lives in `CapabilityList.md`; parity closeout lives in
`ParityMatrix.md`.
