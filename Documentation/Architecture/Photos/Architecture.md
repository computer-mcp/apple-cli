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

`media-items dump` uses `PhotosMediaItemDumpRecord` for JSON and CSV. Its
Codable field keys own both formats. CSV uses those keys in alphabetical order,
emits its complete header for empty results, leaves optional absent values empty,
and quotes text or joined string arrays containing commas, quotes or newlines.

Photos uses read-only SQLite snapshots, Photos.app structured scripting,
FileManager/ImageIO/CoreGraphics export helpers, optional explicit exiftool
calls, and gated Swift or shell hook subprocesses. Direct Photos database
writes, raw AppleScript/JXA/UI runners, arbitrary external-tool passthrough,
and unsafe in-library original mutation are rejected.

Hook and Spotlight subprocesses use the bounded `Utility` execution layer.
Hook JSON input is written while stdout and stderr are drained; the deadline
and per-stream output cap apply throughout execution. Hook failures expose an
exit status and recovery message without copying their raw stderr into errors.

## Validation

Use default Photos tests for snapshot, query, export and command routing.
Verify actual Photos.app behavior separately on the intended host with a copied
throwaway library and the operation-specific risk flags. Detailed capability
status lives in `CapabilityList.md`; validation ownership lives in
`ValidationMatrix.md`.
