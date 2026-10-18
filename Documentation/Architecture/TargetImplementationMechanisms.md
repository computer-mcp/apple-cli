# Target Implementation Mechanisms

## Scope / Purpose

This document is the global index of implementation mechanisms used by each
canonical `apple` target: public frameworks, private frameworks, SDEF/app
scripting, read-only store snapshots, system APIs, file/package APIs, and
bounded subprocesses.

Keep command-level implementation evidence in target-owned architecture and
capability documents. This file only records target-level mechanism direction
and links to the target owner.

## Mechanism Rules

- A target adopts only the mechanisms needed for its accepted CLI contract.
- A target may mix mechanisms only inside the target owner, with command-level
  behavior documented in target-local architecture and capability lists.
- Public frameworks are preferred when they fully cover the accepted behavior.
- Private frameworks are acceptable implementation mechanisms for this CLI when
  target-local capability, verifier, and safety boundaries are documented.
- Structured app scripting stays target-local and semantic.
- Read-only store snapshots may enrich reads, diagnostics, and verification;
  target-local docs own each target's write policy.

## Target Mechanisms

| Target | Implementation mechanisms | Target architecture |
| --- | --- | --- |
| `notes` | Breaking migration from Notes.app structured scripting to generated private Notes framework imports for production reads/writes, with read-only Notes store/index evidence for diagnostics, enrichment, and verification. | [Notes](Notes/Architecture.md) |
| `calendar` | EventKit for calendar/event identity, reads, export planning, and mutations. | [Calendar](Calendar/Architecture.md) |
| `reminders` | ReminderKit imports for production reads/writes plus read-only Reminders store inspection for enrichment, doctor output, and verification. | [Reminders](Reminders/Architecture.md) |
| `contacts` | Contacts.framework for people, groups, labels, vCard import/export, and authorization. | [Contacts](Contacts/Architecture.md) |
| `mail` | Mail.app structured scripting for accounts, mailboxes, messages, drafts, sends, and mailbox actions. | [Mail](Mail/Architecture.md) |
| `messages` | Read-only Messages database inspection for reads; Messages.app structured send automation for sends. | [Messages](Messages/Architecture.md) |
| `maps` | MapKit search/place IDs/routes/ETA, CoreLocation reverse geocoding, MapsSync saved reads and collection/member changes with native verification, and validated Maps URL external actions. | [Maps](Maps/Architecture.md) |
| `finder` | FileManager/file-resource APIs, NSWorkspace/Finder-bound external actions, and file tag/resource metadata APIs. | [Finder](Finder/Architecture.md) |
| `numbers` | File/package metadata, QuickLook export, and Numbers.app structured scripting for sheet/table/cell behavior. | [Numbers](Numbers/Architecture.md) |
| `pages` | File/package metadata and QuickLook export/open mechanisms. | [Pages](Pages/Architecture.md) |
| `keynote` | File/package metadata, Keynote native slide/PDF scripting, explicit cached previews, package copy and presentation open mechanisms. | [Keynote](Keynote/Architecture.md) |
| `facetime` | Contacts.framework resolution and FaceTime URL external actions. | [FaceTime](FaceTime/Architecture.md) |
| `safari` | Safari.app structured scripting plus read-only `SafariTabs.db` snapshots for profiles, windows, and Tab Groups. | [Safari](Safari/Architecture.md) |
| `photos` | Read-only Photos SQLite snapshots, Photos.app structured scripting, file/ImageIO export helpers, optional explicit exiftool, and gated Swift/shell hooks. | [Photos](Photos/Architecture.md) |
| `print` | CUPS inspection and bounded `lp`/`cancel` subprocess actions. | [Print](Print/Architecture.md) |
| `clipboard` | NSPasteboard. | [Clipboard](Clipboard/Architecture.md) |
| `notifications` | Public UserNotifications callbacks, scoped collections and exact-ID removal/readback using the embedded CLI identity. | [Notifications](Notifications/Architecture.md) |
| `intelligence` | Foundation plist APIs plus bounded subprocess calls for local eligibility/cache/service workflows. | [Intelligence](Intelligence/Architecture.md) |
| `tcc` | TCC service catalog, read-only SQLite inspection, `tccutil`, public permission APIs, and gated private TCC.framework diagnostics. | [TCC](TCC/Architecture.md) |

## Related Documents

- [Capability List](CapabilityList.md)
- [Target-First CLI](TargetFirstCli.md)
- [Command Safety Gates](../Reference/SafetyGates.md)
