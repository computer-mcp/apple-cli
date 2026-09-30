# Pages Architecture

`pages` owns path-bounded `.pages` document workflows under `apple pages`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Pages currently uses file/package metadata, document open actions,
and QuickLook export mechanisms for accepted behavior. It does not currently
rely on a private Pages implementation mechanism.

## Source Authority

The `.pages` package shape and QuickLook output define the accepted target
contract.

## Implementation Mechanisms

Pages uses package/FileManager metadata, document open actions, and QuickLook
PDF/thumbnail/package export. Rich app-native extraction and writes are not
current implementation mechanisms.

## Validation

Use document path validation and iWork command tests. Detailed command status
lives in `CapabilityList.md`.
