# apple-cli

`apple-cli` is a CLI-target-first Swift package for local Apple app and
Apple domain capabilities on macOS.

Its canonical GitHub identity is `computer-mcp/apple-cli`. This is an initial
preview; see the [Release Guide](Documentation/Reference/ReleaseGuide.md) for
build, installation and compatibility details.

The [apple-cli Source-Visible License](LICENSE) permits source inspection and
personal, non-commercial use of unmodified official releases. Commercial use,
paid or hosted services, source builds, modifications and redistribution require
prior written permission from the copyright holder. Third-party components retain
their own licenses; see [Third-Party Notices](THIRD_PARTY_NOTICES.md).

The package turns Apple app capabilities into one scriptable Swift executable
with target-first subcommands. The complete target catalog is documented in
[Repository Identity](Documentation/Architecture/RepositoryIdentity.md), and the
accepted command capability surface is documented in
[Capability List](Documentation/Architecture/CapabilityList.md).

The canonical CLI product is:

- `apple`

Its command contract is:

```text
apple <target> <resource?> <action> [options]
```

The accepted targets are:

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
- `safari`
- `photos`
- `print`
- `clipboard`
- `notifications`
- `intelligence`
- `tcc`

MCP servers and external agents adapt to these CLI targets. They do not own the
canonical capability contract.

The optional adapter product is:

- `apple-cli-mcp`

It is an MCP adapter over the canonical CLI targets. It supports stdio by
default and Streamable HTTP when started with `serve http`. It exposes only
CLI-derived tools, includes CLI-derived per-command catalog schemas for clients,
and preserves the CLI JSON/error/safety-policy flow. The adapter uses the
official MCP Swift SDK server, transport, tool, value, and result types directly.

Each `<Target>CLI` module owns its typed `swift-argument-parser` command tree.
`AppleCLI` only composes the root `apple` command and target subcommands.
Repository shared code is limited to contract mechanics such as JSON envelopes,
exit codes, diagnostics, `DryRun` previews, safety flags, small shared option groups, and subprocess
execution helpers.

Usage guidance belongs to CLI help, this README, and focused manuals under
`Documentation/Reference/`. Target-specific architecture and capability truth
may live under `Documentation/Architecture/<Target>/`, with usage guidance under
`Documentation/Reference/<Target>/`. Repository work constraints live in
`AGENTS.md` and architecture documents.

## Current Status

The package declares the canonical `apple` executable plus the optional
`apple-cli-mcp` adapter. All accepted targets have target-local architecture,
capability, user, and developer documentation.

Use these global indexes for the current target catalog:

- [Capability List](Documentation/Architecture/CapabilityList.md)
- [Target Implementation Mechanisms](Documentation/Architecture/TargetImplementationMechanisms.md)
- [Apple CLI User Guide](Documentation/Reference/AppleCLIUserGuide.md)
- [Safety Gates](Documentation/Reference/SafetyGates.md)

Current target documentation starts here:

| Target | Architecture | User guide |
| --- | --- | --- |
| `notes` | [Architecture](Documentation/Architecture/Notes/Architecture.md) | [User Guide](Documentation/Reference/Notes/UserGuide.md) |
| `calendar` | [Architecture](Documentation/Architecture/Calendar/Architecture.md) | [User Guide](Documentation/Reference/Calendar/UserGuide.md) |
| `reminders` | [Architecture](Documentation/Architecture/Reminders/Architecture.md) | [User Guide](Documentation/Reference/Reminders/UserGuide.md) |
| `contacts` | [Architecture](Documentation/Architecture/Contacts/Architecture.md) | [User Guide](Documentation/Reference/Contacts/UserGuide.md) |
| `mail` | [Architecture](Documentation/Architecture/Mail/Architecture.md) | [User Guide](Documentation/Reference/Mail/UserGuide.md) |
| `messages` | [Architecture](Documentation/Architecture/Messages/Architecture.md) | [User Guide](Documentation/Reference/Messages/UserGuide.md) |
| `maps` | [Architecture](Documentation/Architecture/Maps/Architecture.md) | [User Guide](Documentation/Reference/Maps/UserGuide.md) |
| `finder` | [Architecture](Documentation/Architecture/Finder/Architecture.md) | [User Guide](Documentation/Reference/Finder/UserGuide.md) |
| `numbers` | [Architecture](Documentation/Architecture/Numbers/Architecture.md) | [User Guide](Documentation/Reference/Numbers/UserGuide.md) |
| `pages` | [Architecture](Documentation/Architecture/Pages/Architecture.md) | [User Guide](Documentation/Reference/Pages/UserGuide.md) |
| `keynote` | [Architecture](Documentation/Architecture/Keynote/Architecture.md) | [User Guide](Documentation/Reference/Keynote/UserGuide.md) |
| `facetime` | [Architecture](Documentation/Architecture/FaceTime/Architecture.md) | [User Guide](Documentation/Reference/FaceTime/UserGuide.md) |
| `safari` | [Architecture](Documentation/Architecture/Safari/Architecture.md) | [User Guide](Documentation/Reference/Safari/UserGuide.md) |
| `photos` | [Architecture](Documentation/Architecture/Photos/Architecture.md) | [User Guide](Documentation/Reference/Photos/UserGuide.md) |
| `print` | [Architecture](Documentation/Architecture/Print/Architecture.md) | [User Guide](Documentation/Reference/Print/UserGuide.md) |
| `clipboard` | [Architecture](Documentation/Architecture/Clipboard/Architecture.md) | [User Guide](Documentation/Reference/Clipboard/UserGuide.md) |
| `notifications` | [Architecture](Documentation/Architecture/Notifications/Architecture.md) | [User Guide](Documentation/Reference/Notifications/UserGuide.md) |
| `intelligence` | [Architecture](Documentation/Architecture/Intelligence/Architecture.md) | [User Guide](Documentation/Reference/Intelligence/UserGuide.md) |
| `tcc` | [Architecture](Documentation/Architecture/TCC/Architecture.md) | [User Guide](Documentation/Reference/TCC/UserGuide.md) |

All targets expose shared help/status/doctor mechanics. Detailed command
surfaces, implementation mechanisms, safety gates, verifiers, and gaps belong
in target-local docs, not in this README.

SwiftPM target/module names use Swift identifier style, such as
`NotesCLI`, while the executable product name is `apple`.

## Source Build Requirements

Source builds are for the copyright holder and developers with prior written
permission under the project license.

- A macOS host with an Xcode toolchain providing Swift 6.3 or newer.
- A macOS SDK containing the six Notes private frameworks used by the package.
  Run the bootstrap below before building. Generated link inputs remain local.

The package declares a macOS 13 deployment floor. Private-framework runtime
compatibility requires separate validation for each OS and architecture; a
deployment declaration alone is not a tested support claim.

## Install And Invocation

Use an official release for personal, non-commercial use. Verify its checksum
and follow the [Release Guide](Documentation/Reference/ReleaseGuide.md) to add
the complete extracted `bin` directory to `PATH`. Keep both executables and any
bundled Swift runtime libraries together, then run:

```bash
apple notes doctor --json
apple notes search --query "Project" --json
```

## Authorized Source Builds

From the repository root, prepare the selected SDK's link inputs, then build
with SwiftPM. Rerun bootstrap after changing Xcode or the SDK:

```bash
Scripts/bootstrap
swift build
.build/debug/apple --help
swift build -c release
.build/release/apple notes doctor --json
```

## Quick Start

Start with help, status, and doctor before reading or mutating app data:

```bash
apple --help
apple notes --json
apple notes doctor --json
apple notes search --query "Project" --json
```

Use `--dry-run` to preview a mutation before side effects. The preview runs
parsing, normalization, target-local resolution, and validation, then returns a
`DryRun` payload:

```bash
apple reminders create \
  --list Today \
  --title "Follow up" \
  --dry-run \
  --json
```

Ordinary explicit mutations can execute without a generic allow flag:

```bash
apple reminders create \
  --list Today \
  --title "Follow up" \
  --json
```

Risky selections and external actions require concrete `--allow-*` flags. For
example, print submission dispatches to the system print service:

```bash
apple print jobs submit \
  --printer Office_Printer \
  --file Example.pdf \
  --allow-external-dispatch \
  --json
```

`--json` only controls output shape. It never authorizes writes. `DryRun`
payloads are previews, not execution tokens. Agents must not add an allow flag
unless the user explicitly authorized that risk.

System-domain mechanisms also use explicit risk flags. For example,
`intelligence` commands execute only with named `--allow-*` flags and return a
typed operation result:

```bash
apple intelligence enable \
  --patch-scope comprehensive \
  --allow-system-cache-write \
  --json

apple intelligence recompute \
  --allow-debug-attach \
  --json
```

See the [Intelligence User Guide](Documentation/Reference/Intelligence/UserGuide.md) for
the recommended run order, SIP/root prerequisites, optional country cache
rewrite, recompute, rollback, and cleanup guidance.

## Common Commands

```bash
apple notes --help
apple notes accounts list --json
apple notes search --query Plan --json
apple notes create --folder Work --title "Launch notes" --dry-run --json
apple notes import markdown --folder Work --file ./plan.md --dry-run --json
apple calendar calendars list --json
apple calendar events list --from 2026-01-01 --to 2026-01-02 --json
apple calendar availability check \
  --from 2026-01-01T09:00:00Z \
  --to 2026-01-01T10:00:00Z \
  --json
apple calendar events stats --from 2026-01-01 --to 2026-01-02 --json
apple calendar events export \
  --from 2026-01-01 \
  --to 2026-01-02 \
  --format ics \
  --output /tmp/calendar.ics \
  --dry-run \
  --json
apple calendar events create \
  --calendar Work \
  --title "Launch review" \
  --start 2026-01-01T09:00:00Z \
  --end 2026-01-01T10:00:00Z \
  --alarm-minutes-before 10 \
  --alarm-at 2026-01-01T08:30:00Z \
  --dry-run \
  --json
apple reminders lists list --json
apple reminders list --json
apple reminders create --list Today --title "Follow up" --dry-run --json
apple reminders update \
  --id REMINDER_ID \
  --title "Follow up today" \
  --url https://example.com/context \
  --due 2026-01-01T09:00:00Z \
  --early-reminder-minutes-before 30 \
  --dry-run \
  --json
apple reminders complete-many --ids REMINDER_ID,OTHER_ID --dry-run --json
apple reminders complete-matching --list Today --query "Follow" --dry-run --json
apple reminders cleanup-completed \
  --list Today \
  --completed-before 2026-05-01 \
  --dry-run \
  --json
apple contacts search --query Ada --json
apple contacts duplicates --field email --json
apple contacts export \
  --id CONTACT_ID \
  --format vcard \
  --output /tmp/contact.vcf \
  --dry-run \
  --json
apple contacts export \
  --ids CONTACT_ID,OTHER_ID \
  --format vcard \
  --output /tmp/contacts.vcf \
  --dry-run \
  --json
apple contacts export \
  --all \
  --limit 100 \
  --format vcard \
  --output /tmp/all-contacts.vcf \
  --dry-run \
  --json
apple contacts import \
  --file ./contacts.vcf \
  --format vcard \
  --limit 25 \
  --on-duplicate fail \
  --dry-run \
  --json
apple contacts groups list --json
apple contacts groups members --id GROUP_ID --json
apple contacts create \
  --given-name Grace \
  --family-name Hopper \
  --email grace@example.com \
  --dry-run \
  --json
apple contacts update \
  --id CONTACT_ID \
  --email ada-home@example.com \
  --email-label home \
  --dry-run \
  --json
apple contacts delete --ids CONTACT_ID,OTHER_ID --dry-run --json
apple contacts delete-matching --query "Ada" --limit 5 --dry-run --json
apple contacts groups add-member \
  --group-id GROUP_ID \
  --contact-id CONTACT_ID \
  --dry-run \
  --json
apple mail accounts list --json
apple mail messages search --mailbox Inbox --query launch --scope subject --json
apple mail messages search \
  --mailbox Inbox \
  --query launch \
  --scope body \
  --max-scan 500 \
  --json
apple mail messages body-preview \
  --mailbox Inbox \
  --id MESSAGE_ID \
  --max-bytes 20000 \
  --json
apple mail messages reply-preview \
  --mailbox Inbox \
  --id MESSAGE_ID \
  --body "Thanks" \
  --json
apple mail messages reply-draft \
  --mailbox Inbox \
  --id MESSAGE_ID \
  --body "Thanks" \
  --dry-run \
  --json
apple mail messages draft \
  --to team@example.com \
  --subject "Launch" \
  --body "Review notes attached" \
  --dry-run \
  --json
apple mail messages send \
  --to team@example.com \
  --subject "Launch" \
  --body "Review notes attached" \
  --dry-run \
  --json
apple mail messages move \
  --mailbox Inbox \
  --id MESSAGE_ID \
  --destination-mailbox Archive \
  --dry-run \
  --json
apple messages conversations list --json
apple messages search --query launch --json
apple messages send --to ada@example.com --text "Launch is green" --dry-run --json
apple messages send-conversation \
  --conversation CONVERSATION_ID \
  --text "Launch is green" \
  --dry-run \
  --json
apple messages send-many \
  --to ada@example.com,grace@example.com \
  --text "Launch is green" \
  --dry-run \
  --json
apple maps directions preview --to "Apple Park" --json
apple maps directions preview \
  --from-latitude 37.3318 \
  --from-longitude -122.0312 \
  --to-latitude 37.3349 \
  --to-longitude -122.0090 \
  --to-name "Apple Park" \
  --json
apple maps open --url "maps:?q=Apple%20Park" --dry-run --json
apple finder items list --path . --json
apple finder items metadata --path Package.swift --json
apple finder items open --path Package.swift --dry-run --json
apple finder items tags set --path Package.swift --tags Work --dry-run --json
apple finder items delete --path EXISTING_FILE --dry-run --json
apple finder items write-text --path /tmp/new-note.txt --text "Draft" --dry-run --json
apple finder items overwrite-text --path EXISTING_FILE --text "Draft" --dry-run --json
apple numbers documents list --path . --json
apple numbers sheets list --path Example.numbers --json
apple numbers tables read --path Example.numbers --sheet Summary --table Budget --json
apple numbers tables export \
  --path Example.numbers \
  --sheet Summary \
  --table Budget \
  --format csv \
  --to Budget.csv \
  --dry-run \
  --json
apple numbers tables export \
  --path Example.numbers \
  --sheet Summary \
  --table Budget \
  --format tsv \
  --to Budget.tsv \
  --dry-run \
  --json
apple numbers tables set-cell \
  --path Example.numbers \
  --sheet Summary \
  --table Budget \
  --row 2 \
  --column 2 \
  --value "125" \
  --dry-run \
  --json
apple numbers documents open --path Example.numbers --dry-run --json
apple numbers documents export \
  --path Example.numbers \
  --format pdf \
  --to Example.pdf \
  --dry-run \
  --json
apple numbers documents export \
  --path Example.numbers \
  --format thumbnail \
  --to Example.jpg \
  --dry-run \
  --json
apple numbers documents export \
  --path Example.numbers \
  --format package \
  --to ExampleCopy.numbers \
  --dry-run \
  --json
apple pages documents list --path . --json
apple pages documents open --path Example.pages --dry-run --json
apple pages documents export \
  --path Example.pages \
  --format pdf \
  --to Example.pdf \
  --dry-run \
  --json
apple pages documents export \
  --path Example.pages \
  --format thumbnail \
  --to Example.jpg \
  --dry-run \
  --json
apple pages documents export \
  --path Example.pages \
  --format package \
  --to ExampleCopy.pages \
  --dry-run \
  --json
apple keynote presentations list --path . --json
apple keynote slides list --path Example.key --json
apple keynote slides export \
  --path Example.key \
  --format images \
  --to ExampleSlides \
  --dry-run \
  --json
apple keynote presentations open --path Example.key --dry-run --json
apple keynote presentations export \
  --path Example.key \
  --format pdf \
  --to Example.pdf \
  --dry-run \
  --json
apple keynote presentations export \
  --path Example.key \
  --format thumbnail \
  --to Example.jpg \
  --dry-run \
  --json
apple keynote presentations export \
  --path Example.key \
  --format package \
  --to ExampleCopy.key \
  --dry-run \
  --json
apple facetime calls prepare --handle ada@example.com --json
apple facetime calls start --handle ada@example.com --dry-run --json
apple safari windows list --json
apple safari window list --json
apple safari window tab list --window-id safari-window:row:1 --json
apple safari tabs list --json
apple safari pages read \
  --window-index 1 \
  --tab-index 1 \
  --include text \
  --max-bytes 20000 \
  --json
apple safari reading-list add \
  --url "https://www.apple.com/" \
  --dry-run \
  --json
apple safari pages evaluate-javascript \
  --window-index 1 \
  --tab-index 1 \
  --script "document.title" \
  --allow-javascript \
  --dry-run \
  --json
apple photos libraries list --json
apple photos database info --json
apple photos database grep \
  --pattern "IMG_[0-9]+" \
  --allow-database-grep \
  --dry-run \
  --json
apple photos database debug-dump \
  --dump photos \
  --dump keywords \
  --allow-database-debug-dump \
  --dry-run \
  --json
apple photos database orphans \
  --allow-database-orphans \
  --dry-run \
  --json
apple photos media-items search \
  --keyword travel \
  --exif EXIF:Make=Apple \
  --limit 20 \
  --json
apple photos media-items dump \
  --keyword travel \
  --limit 20 \
  --json
apple photos media-items inspect \
  --uuid 3DD2C897-F19E-4CA6-8C22-B027D5A71907 \
  --json
apple photos libraries compare \
  --library ./Before.photoslibrary \
  --other-library ./After.photoslibrary \
  --json
apple photos exports export \
  --album "Travel" \
  --destination ./PhotosExport \
  --dry-run \
  --json
apple photos exports export \
  --trait raw \
  --skip-raw-jpeg \
  --destination ./RawOnlyExport \
  --dry-run \
  --json
apple photos exports export \
  --album "Travel" \
  --skip-uuid-from-file ./skip-photos.txt \
  --skip-original-if-edited \
  --skip-bursts \
  --destination ./FilteredExport \
  --dry-run \
  --json
apple photos exports export \
  --album "Travel" \
  --destination ./TemplatedExport \
  --directory-template "{year}/{album,No Album}" \
  --filename-template "{favorite?favorite-,}{title|strip,untitled}.{ext}" \
  --dry-run \
  --json
apple photos exports export \
  --album "Travel" \
  --destination ./DatedExport \
  --current-name \
  --export-by-date \
  --touch-file \
  --dry-run \
  --json
apple photos exports export \
  --album "Travel" \
  --destination ./IncrementalExport \
  --state-db ./IncrementalExport/photos-export-state.json \
  --update \
  --ignore-signature \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./SinglePhotoExport \
  --overwrite \
  --retry-count 2 \
  --retry-wait-seconds 1 \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./PreviewExport \
  --preview \
  --preview-suffix _preview \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./MissingOriginalFallback \
  --preview-if-missing \
  --preview-suffix "" \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./AdjustedExport \
  --export-aae \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./EditedRenderExport \
  --skip-original-if-edited \
  --edited-suffix _edited \
  --dry-run \
  --json
apple photos exports export \
  --trait live \
  --destination ./LivePhotoExport \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./JPEGExport \
  --convert-to-jpeg \
  --jpeg-quality 0.85 \
  --jpeg-extension jpg \
  --fix-orientation \
  --dry-run \
  --json
apple photos metadata sidecar \
  --uuid PHOTO_UUID \
  --format template \
  --template "{title|strip,untitled} {keywords|sort|join(, )}" \
  --destination ./PhotoSidecars \
  --dry-run \
  --json
apple photos metadata exif \
  --uuid PHOTO_UUID \
  --json
apple photos metadata push-exif \
  --uuid PHOTO_UUID \
  --field all \
  --exiftool-path /opt/homebrew/bin/exiftool \
  --allow-destructive-metadata \
  --dry-run \
  --json
apple photos metadata timewarp \
  --uuid PHOTO_UUID \
  --set-date 2024-01-02T03:04:05Z \
  --allow-destructive-metadata \
  --dry-run \
  --json
apple photos metadata add-locations \
  --uuid PHOTO_UUID \
  --set-location 37.3317,-122.0301 \
  --allow-destructive-metadata \
  --dry-run \
  --json
apple photos metadata sync \
  --uuid PHOTO_UUID \
  --source-file ./photo-metadata.json \
  --field title \
  --field location \
  --report-only \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./Export \
  --add-exported-to-album "Exported by apple" \
  --add-skipped-to-album "Skipped by apple" \
  --add-missing-to-album "Missing by apple" \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./Export \
  --field XMP:Title=Beach \
  --exiftool-path /opt/homebrew/bin/exiftool \
  --allow-destructive-metadata \
  --dry-run \
  --json
apple photos exports export \
  --uuid PHOTO_UUID \
  --destination ./Export \
  --finder-tag-template "{keywords}" \
  --xattr-template "org.example.photos.title={title}" \
  --allow-destructive-metadata \
  --dry-run \
  --json
apple print printers list --json
apple print jobs list --json
apple print jobs submit --printer Office_Printer --file Example.pdf --dry-run --json
apple clipboard types --json
apple clipboard read --json
apple notifications preview --title "Build" --body "Done" --json
```


## Safety And Permissions

Some targets require macOS permissions or app automation approval. Use
`doctor --json` on the target before assuming data is missing:

```bash
apple calendar doctor --json
apple contacts doctor --json
apple mail doctor --json
```

The CLI preserves stdout/stderr separation, stable JSON envelopes, and stable
exit codes for scripts and adapters. Permission failures, validation failures,
unsupported operations, and unsafe mutation refusals are reported as explicit
CLI errors.

## MCP Adapter

`apple-cli-mcp` is an MCP adapter over the canonical CLI contract. The default
transport is stdio for local MCP clients:

```bash
apple-cli-mcp
```

The explicit stdio command is also available:

```bash
apple-cli-mcp stdio
```

For remote-capable MCP clients, run the Streamable HTTP transport:

```bash
apple-cli-mcp serve http --host 127.0.0.1 --port 8765 --path /mcp
```

Loopback HTTP serving can be reached from another machine with an SSH tunnel:

```bash
ssh -L 8765:127.0.0.1:8765 user@mac-host
```

To bind a non-loopback address, opt in explicitly and require a bearer token:

```bash
export APPLE_CLI_MCP_TOKEN="replace-with-a-secret"
apple-cli-mcp serve http \
  --host 0.0.0.0 \
  --port 8765 \
  --path /mcp \
  --allow-non-loopback \
  --token-env APPLE_CLI_MCP_TOKEN
```

TLS, OAuth providers, and public network exposure belong in a reverse proxy or
deployment layer. The in-process HTTP mode only hosts MCP Streamable HTTP and
does not add Apple app capabilities outside the CLI contract.

It exposes only CLI-derived behavior through six tools:

- `apple_cli_list_targets`
- `apple_cli_doctor`
- `apple_cli_status`
- `apple_cli_help`
- `apple_cli_command_catalog`
- `apple_cli_run`

`apple_cli_command_catalog` derives command paths, usage lines, subcommands,
and option metadata from CLI help output.
The adapter does not add hidden Apple app capabilities. Mutations and external
actions still require the target-local safety policy defined by the CLI.

## Authorized Development Tests

The following validation steps are for the copyright holder and developers
with the required written permission.

```bash
Scripts/bootstrap
swift test
```

The default suite uses fixtures and mocks. Bounded reads of the host's Notes
data require explicit integration-test opt-in:

```bash
APPLE_CLI_RUN_NOTES_INTEGRATION_TESTS=1 swift test --filter NotesReaderTests
```

Maintainers preparing a committed local release candidate use
`Scripts/package-release`.
The [Release Guide](Documentation/Reference/ReleaseGuide.md) describes its
validation, archive contents and provenance.

## Documentation

- [Documentation](Documentation/README.md)
- [Architecture](Documentation/Architecture/README.md)
- [Decisions](Documentation/Decisions/README.md)
- [Reference](Documentation/Reference/README.md)
- [Apple CLI User Guide](Documentation/Reference/AppleCLIUserGuide.md)
- [Intelligence User Guide](Documentation/Reference/Intelligence/UserGuide.md)
- [Contributing](CONTRIBUTING.md)
- [Release Guide](Documentation/Reference/ReleaseGuide.md)
- [Security](SECURITY.md)
- [Dependency Notices](THIRD_PARTY_NOTICES.md)
