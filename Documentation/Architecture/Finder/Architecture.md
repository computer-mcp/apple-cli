# Finder Architecture

`finder` owns path-bounded file and Finder-adjacent workflows under
`apple finder`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Finder currently uses FileManager, file-resource APIs, NSWorkspace
or Finder-bound external actions, and tag metadata APIs. It does not currently
rely on a broad private Finder implementation mechanism.

## Source Authority

The local filesystem, FileManager/resource APIs, and Finder-bound external
actions define the accepted target behavior.

## Implementation Mechanisms

Finder uses FileManager/file-resource APIs, NSWorkspace/Finder-bound external
actions, and resource tag metadata APIs. It does not expose broad raw Finder
scripting.

## Validation

Use path-bounded command help and Finder command tests. Detailed command status
lives in `CapabilityList.md`.
