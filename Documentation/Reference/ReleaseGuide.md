# Release Guide

## Candidate Scope

The canonical repository identity is `computer-mcp/apple-cli`. The products are
`apple` and `apple-cli-mcp`. This guide covers source builds, installation,
startup requirements and target validation limits. The [release reference](Release.md)
owns version sources, candidate acceptance, publication and evidence; it links
the applicable VERSIONING rules.

The initial preview targets native macOS arm64 builds. The package's macOS 13
deployment floor describes compilation, not a tested runtime range. Notes and
Reminders link private system frameworks, whose availability and selectors can
change between system versions. Inspect the packaged provenance for the exact
tested OS, architecture, toolchain and SDK. Intel and older macOS versions
require separate build and runtime evidence.

The `apple` executable currently loads all six Notes frameworks, `ReminderKit`
and `ReminderKitInternal` as required libraries at startup. A missing framework
can prevent every command, including `doctor`, from starting. The MCP service
forwards commands to this executable, so forwarding also requires its startup
dependencies. Selector checks run after the system loader and do not establish
framework loadability on another OS.

Successful help, version and MCP forwarding checks establish executable
startup and the CLI contract. They do not establish every app capability, account,
permission or private selector. Run the relevant target's `doctor` and read its
manual before using app data. Notes framework/class/selector readiness is
distinct from permission to read a particular account. Intelligence retains
its documented OS eligibility gates; Notifications retains its documented
backend policy.

Notes startup diagnostics distinguish missing API implementations from dynamic
Core Data accessors described by the installed model. `deferred_model_accessors`
remain unverified in an operation context and retain a readiness warning.
Model metadata does not establish account access or a successful app operation.

## Known Preview Limitations

Notes body structure summaries can underreport strikethrough formatting on
existing notes. A zero `strikethroughRunCount` does not establish that no text
is struck through. For workflows that depend on that formatting, inspect the
HTML export from `apple notes export html`; preserve
the distinction between struck-through text and a struck-through line break.
`notes read` returns plain text and does not preserve inline formatting.

## License And Use

The project is licensed under the [Apache License 2.0](../../LICENSE).
Third-party components retain their own licenses, as listed in
[Third-Party Notices](../../THIRD_PARTY_NOTICES.md).

## Build From Source

Use an Xcode toolchain with Swift 6.3 or newer and a macOS SDK containing
NotesSupport, NotesHTML, NotesShared, NotesUI, NotesEditor and NotesPreviewKit.
Keep the same selected Xcode for bootstrap and build. `DEVELOPER_DIR`, when set,
selects it for both scripts and `xcrun` commands.

```bash
scripts/bootstrap
xcrun swift build --force-resolved-versions
xcrun swift test --force-resolved-versions
xcrun swift build -c release --force-resolved-versions
.build/release/apple --version
.build/release/apple-cli-mcp --version
```

Bootstrap writes local transformed link inputs and their provenance beneath
`.build/notes-private-framework-link-stubs/current`. It preserves system
install names, reads all six inputs before replacement, and does not change the
SDK. Rerun it after changing Xcode. `APPLE_CLI_NOTES_PRIVATE_FRAMEWORK_STUBS`
overrides the output and build-input directory when explicitly set for both
steps. Framework binaries, SDK files and generated link inputs are not included
in the release archive.

The default suite uses mocks and fixtures. Bounded reads of the current host's
Notes data require opt-in on a development machine:

```bash
APPLE_CLI_RUN_NOTES_INTEGRATION_TESTS=1 xcrun swift test --filter NotesReaderTests
```

This integration suite reads local Notes data and may need the host's existing
permissions and account configuration. It does not replace default tests or
authorize a mutation.

Notes and Reminders also have separate, opt-in mutation workflows requiring a
dedicated native fixture manifest. See [Native Fixture Validation](NativeFixtureValidation.md)
for scope, evidence, and recovery. Default skips and successful host reads do
not establish native mutation or multi-OS support.

## Install With Homebrew

The [organization tap](https://github.com/computer-mcp/homebrew-tap) owns the
`apple-cli` formula. It consumes the published macOS arm64 archive and its
accepted checksum, keeps both programs with their bundled runtime libraries,
and declares the recorded macOS requirement. It does not rebuild the programs
on the user's machine.

```bash
brew install computer-mcp/tap/apple-cli
apple --version
apple-cli-mcp --version
```

The formula version follows the product release version. Tap CI validates
installation before publishing an update. For a client configuration, use
`apple-cli-mcp` from Homebrew's `bin` directory.

## Install The Archive

Verify the downloaded archive against its adjacent checksum before extracting,
replacing `VERSION` with the downloaded version:

```bash
shasum -a 256 -c apple-cli-VERSION-macos-arm64.tar.gz.sha256
tar -xzf apple-cli-VERSION-macos-arm64.tar.gz
cd apple-cli-VERSION-macos-arm64
export PATH="$PWD/bin:$PATH"
apple --version
apple --help
apple-cli-mcp stdio
```

Keep the complete contents of `bin`, including any Swift runtime libraries,
together when installing elsewhere. The adapter
resolves its actual executable location, including symlinks, to find that sibling.
For a separate CLI directory, set `APPLE_CLI_BIN_DIR` to the directory containing
`apple`. It is a directory override, not an executable filename.

Packaged executables use ad-hoc signatures after relocation; Swift runtime
libraries retain their toolchain signatures. Project Developer ID signing
and notarization are not established by checksum verification, and macOS may
apply its download-origin checks. A build from the inspected source is another
installation route. Do not disable system security protections as an installation
step. Inspect target help and doctor output for specific permission recovery.
