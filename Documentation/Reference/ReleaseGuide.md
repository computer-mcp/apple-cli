# Release Guide

## Candidate Scope

The canonical repository identity is `computer-mcp/apple-cli`. The products are
`apple` and `apple-cli-mcp`. [Versioning and Release](../Architecture/VersioningAndRelease.md)
owns version authority, upgrade rules, tag identity and evidence requirements.
This guide owns the build, installation and publication procedures.

The initial preview targets native macOS arm64 builds. The package's macOS 13
deployment floor describes compilation, not a tested runtime range. Notes and
Reminders link private system frameworks, whose availability and selectors can
change between system versions. Inspect the packaged provenance for the exact
tested OS, architecture, toolchain and SDK. Intel and older macOS versions
require separate build and runtime evidence.

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
Scripts/bootstrap
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

## GitHub Release Publication

Before selecting a tag, update the canonical version and its Changelog entry
under the version policy, then check the working tree's release inputs:

```bash
Scripts/validate-version --json
python3 -B -m unittest discover -s Tests/ReleaseTools
```

The check is read-only and accepts an uncommitted working tree. Its optional
`--tag TAG` check requires that existing tag at `HEAD`. The packager and archive
checker use the same version-input validation. CI runs the gate's fixture tests
before packaging. Use Python 3.12 or newer for the release scripts.

Formal releases are built, accepted and published by
[release.yml](https://github.com/computer-mcp/apple-cli/blob/master/.github/workflows/release.yml).
Pushing a version tag such as
`v0.1.0-alpha.2` triggers the workflow. Its manual `tag` input accepts an existing
version tag for a new run. The tag must agree with `CLIVersion.current` and the
checked-out commit; `CHANGELOG.md` must contain that version's entry.

The macOS build job uses read-only repository permissions. It runs source
validation, locked test/release builds with two build jobs, default concurrent
tests, staged binary content/signature checks and installed CLI/MCP acceptance.
`Scripts/verify-release --run-tests` then validates the actual archive and runs
the existing CLI/MCP tests against its safely extracted programs. This acceptance
includes PATH/symlink startup and stdio/loopback HTTP forwarding.

The workflow transfers four files to an independent publication job:

- the macOS arm64 `.tar.gz` archive;
- its `.tar.gz.sha256` checksum;
- its `.provenance.json` source/build manifest;
- its `.verification.json` archive/executable acceptance receipt.

The publisher uses the job-scoped `GITHUB_TOKEN` with `contents: write`. It
rechecks the source, archive, receipt and remote tag, creates a draft, uploads
the accepted files, verifies the uploaded bytes, then publishes it. Versions
containing a prerelease suffix are published as prereleases. No rebuild or
re-sign occurs between acceptance and publication.

For an interrupted upload, rerun the failed publication job to reuse its
successful build's artifact. Matching draft assets are verified and missing
assets are uploaded. A published release with the same accepted bytes is an
idempotent success. Different draft or published bytes are refused; a new build
candidate requires disposing of any incomplete previous draft before retrying.
Published versions remain immutable under this workflow.

## Local Packaging Validation

Commit the complete intended source, including the selected project license,
dependency notices and `Package.resolved`. Start from a clean checkout of that
commit, then run:

```bash
Scripts/package-release --jobs 2
Scripts/verify-release --run-tests
```

`Scripts/package-release` is the shared packaging step used by CI and local
development checks. It bootstraps the selected SDK, builds tests with locked
dependencies, runs default concurrent tests, builds both optimized products, and
runs CLI/MCP black-box tests using the staged release binaries. The MCP tests execute real
CLI help and a benign notification preview from an unrelated directory through
stdio and loopback HTTP. They cover PATH/symlink installation and explicit
`APPLE_CLI_BIN_DIR` selection.

Output defaults to `.build/releases`. Use `--output DIRECTORY` for another
location. Existing output names are refused. The archive includes both binaries,
required Swift runtime libraries, installation guidance, the project license and
dependency notices. `swift-stdlib-tool` selects runtime libraries from the same
toolchain used to build. The packager removes toolchain run paths from staged
executables, strips debug symbols and applies ad-hoc signatures before
testing those bytes. Public-content validation scans every staged executable and
Swift runtime library for machine-local directory paths before CLI/MCP acceptance.
Every linked library must resolve through a system path or the bundled Swift
libraries; runtime collection does not expand the tested macOS range. The adjacent
manifest records the source commit/tree, lockfile hash, toolchain, SDK, link-input
hashes, linked libraries, run paths, executable and runtime library hashes, and successful validation-log
hashes. The checksum covers the actual archive bytes. Build timestamps and
compiler output can vary; this process does not claim bit-for-bit rebuilds.

For an existing version tag at the candidate commit:

```bash
Scripts/package-release --tag v0.1.0-alpha.2
```

The tag must match the canonical source version and resolve to `HEAD`.
The script does not create a repository, tag, remote push or GitHub release.
`Scripts/verify-release` uses Python 3.12 or newer for archive validation. Its
`--run-tests` mode requires the matching source checkout, build-validation logs
and test executables. Its `--require-verification` mode checks the existing
receipt and archive without running macOS executables, as the publication job
does on Linux. A development-machine candidate is local validation evidence;
formal GitHub releases use the files accepted by the release workflow.

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

Verify the downloaded archive against its adjacent checksum before extracting:

```bash
shasum -a 256 -c apple-cli-0.1.0-alpha.2-macos-arm64.tar.gz.sha256
tar -xzf apple-cli-0.1.0-alpha.2-macos-arm64.tar.gz
cd apple-cli-0.1.0-alpha.2-macos-arm64
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

## CI Runner And Evidence

`ci.yml` validates pushes to `master`, pull requests and manual runs, including
actual archive extraction and executable acceptance. It uploads workflow
artifacts and logs. `release.yml` adds the independent publication job for
version tags. Both use the shared packaging/verification scripts and pinned
action revisions. Only the release publication job receives repository write
permission.

The configured `xcode-27` arm64 image is a public-preview runner, with Xcode
27.0 selected explicitly. Its availability is documented by
[GitHub's runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
and its toolchain by the
[runner image inventory](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md).
This infrastructure choice is not evidence that a workflow has run. Review the
actual workflow result and artifact provenance before publishing; image updates
require renewed validation.
