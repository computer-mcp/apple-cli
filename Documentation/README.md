# Documentation

Start with a guide for the task at hand:

| Guide | Use it for |
| --- | --- |
| [Apple CLI User Guide](Reference/AppleCLIUserGuide.md) | Command discovery, JSON output, MCP and permissions |
| [Release Guide](Reference/ReleaseGuide.md) | Installation, builds, CI publication and compatibility |
| [Versioning and Release](Architecture/VersioningAndRelease.md) | Version authority, upgrades, tags and accepted release evidence |
| [Capability List](Architecture/CapabilityList.md) | Supported scope and target-specific limits |
| [Safety Gates](Reference/SafetyGates.md) | Dry runs, mutations and external actions |

## Target Guides

Each target has a user guide, developer guide and architecture entry:

| Target | User guide | Developer guide | Architecture |
| --- | --- | --- | --- |
| `notes` | [Usage](Reference/Notes/UserGuide.md) | [Development](Reference/Notes/DeveloperGuide.md) | [Design](Architecture/Notes/Architecture.md) |
| `calendar` | [Usage](Reference/Calendar/UserGuide.md) | [Development](Reference/Calendar/DeveloperGuide.md) | [Design](Architecture/Calendar/Architecture.md) |
| `reminders` | [Usage](Reference/Reminders/UserGuide.md) | [Development](Reference/Reminders/DeveloperGuide.md) | [Design](Architecture/Reminders/Architecture.md) |
| `contacts` | [Usage](Reference/Contacts/UserGuide.md) | [Development](Reference/Contacts/DeveloperGuide.md) | [Design](Architecture/Contacts/Architecture.md) |
| `mail` | [Usage](Reference/Mail/UserGuide.md) | [Development](Reference/Mail/DeveloperGuide.md) | [Design](Architecture/Mail/Architecture.md) |
| `messages` | [Usage](Reference/Messages/UserGuide.md) | [Development](Reference/Messages/DeveloperGuide.md) | [Design](Architecture/Messages/Architecture.md) |
| `maps` | [Usage](Reference/Maps/UserGuide.md) | [Development](Reference/Maps/DeveloperGuide.md) | [Design](Architecture/Maps/Architecture.md) |
| `finder` | [Usage](Reference/Finder/UserGuide.md) | [Development](Reference/Finder/DeveloperGuide.md) | [Design](Architecture/Finder/Architecture.md) |
| `numbers` | [Usage](Reference/Numbers/UserGuide.md) | [Development](Reference/Numbers/DeveloperGuide.md) | [Design](Architecture/Numbers/Architecture.md) |
| `pages` | [Usage](Reference/Pages/UserGuide.md) | [Development](Reference/Pages/DeveloperGuide.md) | [Design](Architecture/Pages/Architecture.md) |
| `keynote` | [Usage](Reference/Keynote/UserGuide.md) | [Development](Reference/Keynote/DeveloperGuide.md) | [Design](Architecture/Keynote/Architecture.md) |
| `facetime` | [Usage](Reference/FaceTime/UserGuide.md) | [Development](Reference/FaceTime/DeveloperGuide.md) | [Design](Architecture/FaceTime/Architecture.md) |
| `safari` | [Usage](Reference/Safari/UserGuide.md) | [Development](Reference/Safari/DeveloperGuide.md) | [Design](Architecture/Safari/Architecture.md) |
| `photos` | [Usage](Reference/Photos/UserGuide.md) | [Development](Reference/Photos/DeveloperGuide.md) | [Design](Architecture/Photos/Architecture.md) |
| `print` | [Usage](Reference/Print/UserGuide.md) | [Development](Reference/Print/DeveloperGuide.md) | [Design](Architecture/Print/Architecture.md) |
| `clipboard` | [Usage](Reference/Clipboard/UserGuide.md) | [Development](Reference/Clipboard/DeveloperGuide.md) | [Design](Architecture/Clipboard/Architecture.md) |
| `notifications` | [Usage](Reference/Notifications/UserGuide.md) | [Development](Reference/Notifications/DeveloperGuide.md) | [Design](Architecture/Notifications/Architecture.md) |
| `intelligence` | [Usage](Reference/Intelligence/UserGuide.md) | [Development](Reference/Intelligence/DeveloperGuide.md) | [Design](Architecture/Intelligence/Architecture.md) |
| `tcc` | [Usage](Reference/TCC/UserGuide.md) | [Development](Reference/TCC/DeveloperGuide.md) | [Design](Architecture/TCC/Architecture.md) |

## Documentation Areas

This tree keeps repository documentation roles separate.

- [Architecture](Architecture/README.md) states current architecture truth.
- [Reference](Reference/README.md) holds user guides, developer guides, safety
  references, and supporting material that does not define architecture truth.
- [Decisions](Decisions/README.md) records accepted decisions and rationale.
- [Proposals](Proposals/README.md) holds design-in-progress.
- [Migrations](Migrations/README.md) records transition and rollout notes.
- [Archive](Archive/README.md) keeps retired or superseded material.

The root `README.md` remains the public package entry point. This file is only
the documentation reading index.

## Global Documents

- [Capability List](Architecture/CapabilityList.md): global target capability
  index.
- [Target Implementation Mechanisms](Architecture/TargetImplementationMechanisms.md):
  global implementation mechanism index.
- [Apple CLI User Guide](Reference/AppleCLIUserGuide.md): global CLI usage
  guide.
- [Safety Gates](Reference/SafetyGates.md): global command safety vocabulary.

## Target-Specific Documentation

Single-target documentation stays under the owning documentation role:

- `Documentation/Architecture/<Target>/` for target-specific architecture truth
  and capability lists.
- `Documentation/Reference/<Target>/` for target-specific user guides,
  developer guides, validation notes, and supporting references.

Cross-target architecture and reference files should summarize and link to
these directories instead of carrying detailed target designs, capability lists,
runbooks, implementation evidence, or command-level mappings.

## DocC Placement

This package does not currently ship target-level DocC catalogs. If API
documentation is added later, keep each catalog with the SwiftPM target it
documents, normally at `Sources/<Target>/<Target>.docc/`. Keep generated
`.doccarchive` output out of source documentation unless a publishing policy
explicitly says otherwise.
