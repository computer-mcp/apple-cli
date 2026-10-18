# Photos Capability And Validation Matrix

`apple photos` owns library, query, export, metadata and app-action behavior.
This matrix summarizes the implemented mechanisms and their validation owners.
The detailed current surface is in [Capability List](CapabilityList.md), with
operating guidance in [User Guide](../../Reference/Photos/UserGuide.md).

| Capability family | Target-owned mechanism | Package-local validation |
| --- | --- | --- |
| Library discovery and package metadata | FileManager, plist inspection and read-only SQLite snapshots | `PhotosSnapshotTests`, `PhotosCommandTests` |
| Albums, folders and media records | Typed snapshot queries and normalized records | `PhotosSnapshotTests`, `PhotosQueryTests` |
| Query, ordering and field projection | Typed Swift selectors over copied SQLite inputs | `PhotosQueryTests` |
| Library backup, export planning and files | Explicit destinations, FileManager and ImageIO | `PhotosExportAndMetadataTests` |
| Reports, export state and cleanup | Local state, bounded reports and `.apple-cli-photos-keep` rules | `PhotosExportAndMetadataTests` |
| Metadata sidecars and optional tools | Target-local encoders, explicit tool resolution and risk gates | `PhotosExportAndMetadataTests`, `PhotosCommandTests` |
| Import, selection, album/folder mutations and slideshow | Structured Photos.app scripting and typed command validation | `PhotosCommandTests`; host-specific app verification |
| Scalar metadata writes and undo | Selector-bound actions and local undo state | `PhotosCommandTests`; host-specific app verification |
| Template values and Swift hooks | Swift template rendering and JSON subprocess contracts | `PhotosHookTests`, `PhotosCommandTests` |
| Post-export commands | Target-local bounded subprocess execution with explicit risk flags | `PhotosHookTests`, `PhotosExportAndMetadataTests` |

Default tests use synthetic libraries, temporary files and controlled backends.
They validate the local CLI contract and covered file/database shapes. Actual
Photos.app behavior, permissions, account state and private database schemas
require separate validation on each intended host.

The source library remains owned by Photos.app. Snapshot reads use copied
inputs, export/state destinations stay outside `.photoslibrary`, and metadata,
cleanup, code execution and external actions retain their concrete risk gates.
See [Developer Guide](../../Reference/Photos/DeveloperGuide.md) for the current
test entry points and fixture ownership.
