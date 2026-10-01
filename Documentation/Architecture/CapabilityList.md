# Capability List

## Scope / Purpose

This document is the global capability index for the canonical `apple` CLI.
It records the accepted target-level surface and links to target-owned
capability lists for detailed command, implementation mechanism, gate,
verifier, and gap accounting.

Keep detailed target design out of this file. Target-specific truth belongs in
`Documentation/Architecture/<Target>/CapabilityList.md` and
`Documentation/Architecture/<Target>/Architecture.md`.

## Common Contract

- `apple` is the canonical CLI behavior product.
- `apple-cli-mcp` adapts the CLI contract and does not add hidden behavior.
- Each `<Target>CLI` owns its typed command tree, validation, implementation
  behavior, diagnostics, and mutation or external-action safety policy.
- Read and search commands must be bounded enough to be scriptable and safe for
  local private data.
- Mutations and external actions must declare a target-local safety policy.

## Target Index

| Target | Accepted capability summary | Detailed capability list |
| --- | --- | --- |
| `notes` | Notes accounts, folders, Smart Folder metadata/criteria/matching-note reads plus single-tag create/update/rename/delete, tag listing/search/membership/rename/delete, attachment metadata/add/remove/export, link metadata/backlinks/resolution, web/app/file URL link add/update/remove, note-to-note link add/update/remove, paragraph note-link add/update/remove, visible-note PDF/Markdown/HTML/RTF/RTFD export, body structure, checklist add/set/set-all/convert/convert-range/reorder/indent/delete, single ordinary list item reorder/indent/delete, note state, list/search/read, safety-gated text note mutations, private-framework readiness checks, and capability diagnostics for rich Notes workflows. | [Notes](Notes/CapabilityList.md) |
| `calendar` | EventKit calendars, event reads/searches/occurrences/stats/availability/export, and safety-gated event create/update/delete. | [Calendar](Calendar/CapabilityList.md) |
| `reminders` | ReminderKit reads/writes, rich Reminders metadata, Smart Lists, list organization, and read-only SQLite verifier/doctor evidence. | [Reminders](Reminders/CapabilityList.md) |
| `contacts` | Contacts search/read/duplicates/groups, vCard import/export, contact mutations, and group membership changes. | [Contacts](Contacts/CapabilityList.md) |
| `mail` | Mail accounts/mailboxes/message reads, bounded body preview/search, draft/reply/forward/send, and mailbox mutations. | [Mail](Mail/CapabilityList.md) |
| `messages` | Local Messages conversation/message reads and safety-gated sends. | [Messages](Messages/CapabilityList.md) |
| `maps` | Place search/read, directions preview, and safety-gated Maps open actions. | [Maps](Maps/CapabilityList.md) |
| `finder` | Path-bounded file metadata, open/reveal, move/trash/delete, tags, and bounded file text writes. | [Finder](Finder/CapabilityList.md) |
| `numbers` | `.numbers` document metadata, sheet/table reads, table export, single-cell text write, open, and QuickLook/package export. | [Numbers](Numbers/CapabilityList.md) |
| `pages` | `.pages` document metadata, open, and QuickLook/package export. | [Pages](Pages/CapabilityList.md) |
| `keynote` | `.key` presentation metadata, slide listing/export, open, and QuickLook/package export. | [Keynote](Keynote/CapabilityList.md) |
| `facetime` | Contact resolution, call preparation, and safety-gated FaceTime call start. | [FaceTime](FaceTime/CapabilityList.md) |
| `safari` | Safari windows/tabs/pages/profile reads, selected browser actions, Reading List, gated page/extension actions, and Tab Group diagnostics. | [Safari](Safari/CapabilityList.md) |
| `photos` | Photos library/media/album/folder reads, import/export/report, metadata workflows, slideshow/actions, spotlight, and gated hooks. | [Photos](Photos/CapabilityList.md) |
| `print` | Printer/job inspection plus safety-gated print submission and cancellation. | [Print](Print/CapabilityList.md) |
| `clipboard` | Pasteboard type/read plus safety-gated write/clear. | [Clipboard](Clipboard/CapabilityList.md) |
| `notifications` | Notification preview and safety-gated send for notifications created by this tool. | [Notifications](Notifications/CapabilityList.md) |
| `intelligence` | Apple Intelligence local-cache support/doctor/verify and risk-flag-gated enablement/recovery/service workflows. | [Intelligence](Intelligence/CapabilityList.md) |
| `tcc` | TCC service/identity/database diagnostics, access preflight/request, reset, and gated private diagnostics. | [TCC](TCC/CapabilityList.md) |

## Related Architecture

- [Target-First CLI](TargetFirstCli.md)
- [CLI Contract](CliContract.md)
- [Target Implementation Mechanisms](TargetImplementationMechanisms.md)
- [Command Safety Gates](../Reference/SafetyGates.md)
