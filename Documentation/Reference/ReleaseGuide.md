# Release Guide

## Candidate Scope

The canonical repository identity is `computer-mcp/apple-cli`. The products are
`apple` and `apple-cli-mcp`. `Sources/Utility/CLIVersion.swift` owns the version;
release tags use `v` followed by that value.

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

## Prepare A Local Candidate

Commit the complete intended source, including the selected project license,
dependency notices and `Package.resolved`. Start from a clean checkout of that
commit, then run:

```bash
Scripts/package-release
```

The script bootstraps the selected SDK, builds tests with locked dependencies,
runs default concurrent tests, builds both optimized products, and runs CLI/MCP
black-box tests using the staged release binaries. The MCP tests execute real
CLI help and a benign notification preview from an unrelated directory through
stdio and loopback HTTP. They cover PATH/symlink installation and explicit
`APPLE_CLI_BIN_DIR` selection.

Output defaults to `.build/releases`. Use `--output DIRECTORY` for another
location. Existing output names are refused. The archive includes both binaries,
required Swift runtime libraries, installation guidance, the project license and
dependency notices. `swift-stdlib-tool` selects runtime libraries from the same
toolchain used to build. The packager removes toolchain run paths from staged
executables, strips debug symbols and applies local ad-hoc signatures before
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
Scripts/package-release --tag v0.1.0-alpha.1
```

The tag must match the canonical source version and resolve to `HEAD`.
The script does not create a repository, tag, remote push or GitHub release.
Publishing is a separate maintainer action after inspecting the candidate.

## Install The Archive

Verify the downloaded archive against its adjacent checksum before extracting:

```bash
shasum -a 256 -c apple-cli-0.1.0-alpha.1-macos-arm64.tar.gz.sha256
tar -xzf apple-cli-0.1.0-alpha.1-macos-arm64.tar.gz
cd apple-cli-0.1.0-alpha.1-macos-arm64
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

Packaged executables use local ad-hoc signatures after relocation; Swift runtime
libraries retain their toolchain signatures. Project Developer ID signing
and notarization are not established by checksum verification, and macOS may
apply its download-origin checks. A build from the inspected source is another
installation route. Do not disable system security protections as an installation
step. Inspect target help and doctor output for specific permission recovery.

## GitHub Validation

`ci.yml` validates pushes to `main`, pull requests and manual runs. `release.yml`
is a manual candidate workflow for an existing version tag. Both use the same
local packaging script, read-only repository permissions and pinned action
revisions. They upload artifacts and logs; they do not publish a GitHub release.

The configured `xcode-27` arm64 image is a public-preview runner, with Xcode
27.0 selected explicitly. Its availability is documented by
[GitHub's runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
and its toolchain by the
[runner image inventory](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md).
This infrastructure choice is not evidence that a workflow has run. Review the
actual workflow result and artifact provenance before publishing; image updates
require renewed validation.
