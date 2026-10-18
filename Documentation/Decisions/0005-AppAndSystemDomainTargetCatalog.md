# App and System Domain Target Catalog

## Status

Accepted. Product naming from the original catalog was superseded by
[0007](0007-UnifiedAppleCommandTreeAndOfficialSwiftMechanics.md): these are
now command targets under the canonical `apple` executable, not separate
`apple-*` products.

## Context

Useful command-line coverage of macOS includes Apple app, Apple domain, and
system domain capabilities beyond the currently scaffolded Notes, Calendar,
Reminders, Contacts, and Mail products. The `intelligence` target is a concrete
example of the intended posture: a Swift-first CLI implementation should cover
the domain completely while avoiding delivery risks such as shell patching,
runtime `curl`, silent debug attach, default persistence, and unpinned release
binaries. The package goal is complete app, domain, and accepted system-domain
capability coverage within the repository's accepted scope, without drifting
into generic whole-macOS automation.

## Decision

Adopt a complete intended command-target catalog for Apple app/domain and
accepted system domain capabilities:

- `notes`
- `calendar`
- `reminders`
- `contacts`
- `mail`
- `messages`
- `maps`
- `finder`
- `numbers`
- `pages`
- `keynote`
- `facetime`
- `print`
- `clipboard`
- `notifications`
- `intelligence`

Each target owns its capability surface independently. Current architecture
truth lives in `Documentation/Architecture/`.

Command grammar, tests, backend techniques, and error-handling patterns are
designed per target to fit the local CLI contract. External tools and projects
are inputs, not architectural authority.

Generic AppleScript/JXA execution, OSA tool discovery, Accessibility/UI
automation, shell execution, schedulers, remote Mac control, screen/OCR
automation, Automator workflow generation, and arbitrary app control remain
deferred outside the app/domain/system target catalog.

## Consequences

- The current targets are command targets under `apple`, not the final extent
  of the architecture.
- New app/domain/system targets are additive command targets, not new
  executable products and not methods on a shared bridge core.
- MCP adapters and external agent integrations may expand with the catalog, but
  they remain adapters over CLI contracts.
- In-scope target implementations are expected to provide complete command
  breadth, safety, diagnostics, and scriptability for their domain.
- High-risk external actions such as sending messages, initiating calls, and
  submitting print jobs require target-local safety gates.
- Clipboard, Notifications, and Intelligence are accepted system domain targets,
  not generic automation targets.

## Alternatives Considered

- Keep the architecture limited to the currently scaffolded targets.
- Adopt an existing multi-app automation suite wholesale.
- Add a generic script execution target to cover every capability.

## Related Documentation

- Date: 2026-05-11
- Related architecture docs:
  - [Repository Identity](../Architecture/RepositoryIdentity.md)
  - [Target-First CLI](../Architecture/TargetFirstCli.md)
  - [CLI Contract](../Architecture/CliContract.md)
