# Release

Release status: packaging, archive acceptance and GitHub publication are
implemented by [package-release](https://github.com/computer-mcp/apple-cli/blob/master/Scripts/package-release),
[verify-release](https://github.com/computer-mcp/apple-cli/blob/master/Scripts/verify-release),
[publish-release](https://github.com/computer-mcp/apple-cli/blob/master/Scripts/publish-release)
and the [release workflow](https://github.com/computer-mcp/apple-cli/blob/master/.github/workflows/release.yml).
Version selection, compatibility review and tag signature verification are
manual.

apple-cli adopts the [organization VERSIONING](https://github.com/computer-mcp/.github/blob/master/VERSIONING.md),
supplemented by the repository's [VERSIONING](../../VERSIONING.md). Those
documents own version rules, including tags, release timing, version choice and
the changelog. This reference owns release facts and procedures. The
[Release Guide](ReleaseGuide.md) covers source builds, installation, startup
dependencies and target-specific validation limits.

## Components and Version Sources

| Shipped component | Version meaning | Version source | Mirrors and derived fields | Update and read-only check |
| --- | --- | --- | --- | --- |
| `apple` and its target commands | Shared product version | `CLIVersion.current` in `Sources/Utility/CLIVersion.swift` | `apple --version`, archive identity and provenance | Edit the declaration manually; `Scripts/validate-version`; `CLIExecutableTests` |
| `apple-cli-mcp` | Same product version | The same `CLIVersion.current` | `apple-cli-mcp --version`, MCP initialization `serverInfo.version` | Same declaration; `CLIExecutableTests`, `AppleMCPAdapterTests` and `MCPExecutableTests` |

Both executable products release together. Target modules and source skills
follow the repository release and have no independent product version
declaration. `Sources/AppleCLI/Info.plist` supplies bundle identity and usage
descriptions, with no separate version or build-number field. Installed
binaries and previous build directories are not version sources.

`CHANGELOG.md` supplies release notes for the declared product version. Its
entry and the optional existing release tag are checked against that
declaration; archive names and receipts are derived from the checked source
and build.

## Compatibility Surface

Consumers depend on the two executable names, command paths and options, exit
codes, structured output and error codes, MCP tool schemas and transports,
mutation and external-action gates, and documented runtime requirements.
The [CLI contract](https://github.com/computer-mcp/apple-cli/blob/master/Documentation/Architecture/CliContract.md)
and [MCP adapter boundary](https://github.com/computer-mcp/apple-cli/blob/master/Documentation/Architecture/McpAdapterBoundary.md)
own those contracts. The archive layout keeps both programs and their Swift
runtime libraries together in `bin`; the adapter's sibling lookup and
`APPLE_CLI_BIN_DIR` directory override are installation interfaces.

`Package.swift` declares Swift tools 6.3 and macOS 13 as the deployment floor.
Builds need a compatible Xcode toolchain and the Notes private-framework SDK
inputs described in the Release Guide. Native macOS arm64 is the implemented
packaging and executable-acceptance target. The deployment declaration does
not establish a tested runtime range; Intel and older macOS releases require
separate evidence. Review affected behavior and tests to establish
compatibility; version-number comparisons do not establish it.

## Dependencies and Verified Combinations

[Package.swift](https://github.com/computer-mcp/apple-cli/blob/master/Package.swift)
owns requirements under the organization VERSIONING;
[Package.resolved](https://github.com/computer-mcp/apple-cli/blob/master/Package.resolved)
records selected versions and full revisions. The direct declarations are:

| Dependency | Declared requirement | Locked version | Role |
| --- | --- | --- | --- |
| `apple/swift-argument-parser` | `from: "1.8.2"` | `1.8.2` | Typed command parsing |
| `hummingbird-project/hummingbird` | `.upToNextMinor(from: "2.23.0")` | `2.23.0` | HTTP host shell |
| `computer-mcp/swift-sdk` | `exact: "0.13.2-computer-mcp.1"` | [`0.13.2-computer-mcp.1`](https://github.com/computer-mcp/swift-sdk/blob/0.13.2-computer-mcp.1/FORK.md) | MCP protocol and transports; decode errors retain request ids and HTTP errors complete their POST |
| `apple/swift-http-types` | `from: "1.8.0"` | `1.8.0` | HTTP request and response types |
| `swiftlang/swift-subprocess` | `.upToNextMinor(from: "1.0.2")` | `1.0.2` | Process execution |

The MCP SDK comes from the [Computer MCP fork](https://github.com/computer-mcp/swift-sdk).
Transitive requirements, including swift-nio and swift-crypto, belong to the
packages declaring them; their selected revisions are in the lockfile.

Dependency updates include manual confirmation that each selected source
release tag peels to its locked revision. Use the dependency's actual tag
spelling, accounting for any prefix SwiftPM normalizes in the recorded version.
The release scripts check the local lockfile and its provenance digest; an
automated dependency-tag verification command is not established. Update
dependency notices and copied licenses with their selected sources, and
revalidate downstream behavior affected by an update.

Test and release builds use `--force-resolved-versions`. Provenance records the
lockfile digest, resolved dependency records, OS, architecture, Xcode, Swift
toolchain, SDK and generated Notes link inputs. A successful candidate
establishes that recorded combination within the checks performed. The MCP
protocol baseline, SDK version, toolchain version and product version have
separate meanings.

The [CI workflow](https://github.com/computer-mcp/apple-cli/blob/master/.github/workflows/ci.yml)
and release build job select the `xcode-27` arm64 runner with Xcode 27.0.
That configuration is not evidence of a completed run or broader OS coverage;
runner image updates require renewed validation. The actual tested combination
comes from successful workflow results and packaged provenance.
[Dependabot](https://github.com/computer-mcp/apple-cli/blob/master/.github/dependabot.yml)
checks Swift dependencies and Actions weekly. Its update pull requests run CI
and need compatibility, lockfile and dependency-notice review.

## Derived Metadata and Drift Checks

| Field or artifact | Authority and production | Read-only verification |
| --- | --- | --- |
| Executable version and MCP `serverInfo.version` | Compiled from `CLIVersion.current` | Executable and MCP initialization tests; packager checks both staged `--version` results |
| Release notes | Matching entry in `CHANGELOG.md`; publisher renders that entry and source/Actions links | `Scripts/validate-version [--tag TAG]` and publisher input validation |
| Archive basename | `apple-cli-VERSION-macos-arm64`, derived by `Scripts/package-release` | `Scripts/verify-release` compares names, source version, tag and architecture |
| `.provenance.json` and embedded `provenance.json` | Packager records source commit/tree, lock digest and dependencies, environment, link inputs, linked libraries, run paths, binary/runtime hashes and successful validation-log hashes | Verifier checks source identity, lock digest, required checks, archive contents and embedded/adjacent manifest equality, apart from the adjacent archive digest |
| `.tar.gz.sha256` | Packager hashes the archive bytes | Verifier recomputes the archive digest and exact checksum contents |
| `.verification.json` | `Scripts/verify-release --run-tests` records archive/provenance/checksum hashes, checker hash, tested environment, successful checks and test-log digest; Actions adds run identity | `Scripts/verify-release --require-verification` checks identity, hashes, required checks and positive test/suite counts |

Provenance and verification receipts use `schema_version: 1`. Provenance also
records a build timestamp. Build timestamps and compiler output can vary; the
packager does not claim bit-for-bit rebuilds.

[Scripts/validate-version](https://github.com/computer-mcp/apple-cli/blob/master/Scripts/validate-version)
requires exactly one canonical declaration in the supported version format.
For untagged validation, a changelog whose sole section is `Unreleased` may be
empty. Otherwise it requires exactly one nonempty entry for the product
version. `--tag TAG` additionally requires versioned notes, the expected tag
name and an existing tag whose peeled commit equals `HEAD`. These checks can
read an uncommitted working tree; they do not edit versions or infer upgrades.
Automated tag checks cover name and commit identity. Annotation and signature
verification remain manual under VERSIONING.

Packaging requires a clean committed source checkout before and after its
checks. Locked builds constrain dependency resolution, and the verifier
compares the lockfile digest with provenance. Missing or conflicting version,
repository, source, artifact or receipt identity fails validation.

## Candidate, Acceptance and Publication

1. Manually prepare the canonical declaration and changelog under VERSIONING,
   then run the source gates:

   ```bash
   Scripts/validate-version --json
   Scripts/validate-public-content
   python3 -B -m unittest discover -s Tests/ReleaseTools
   ```

2. Commit the complete candidate, including the lockfile, project license and
   dependency notices. From its clean checkout, build and accept the archive:

   ```bash
   Scripts/package-release --jobs 2
   Scripts/verify-release --run-tests
   ```

   The packager bootstraps SDK link inputs, builds tests, runs default
   concurrent tests and separate MCP executable tests, and builds both release
   products. It collects Swift runtime libraries from the selected toolchain,
   removes external toolchain run paths, strips executable debug symbols and
   applies ad-hoc executable signatures. Runtime libraries retain their
   toolchain signatures. It checks standalone linkage, signatures, architecture,
   staged content and CLI/MCP behavior before creating the archive. These
   steps do not establish project Developer ID signing or notarization.

   Archive verification checks safe extraction, source-matching bundled
   documents and licenses, binary inventory and digests, local Markdown links
   and machine-local path scans. `--run-tests` then verifies installed
   signatures and runs `CLIExecutableTests`, `AppleMCPAdapterTests` and
   `MCPExecutableTests` against the extracted binaries. This includes
   PATH/symlink startup, explicit CLI-directory selection and stdio/loopback
   HTTP forwarding with CLI help and a benign notification preview. It needs
   the matching source, build logs and built test executables. Default tests
   do not establish app/account permissions or native mutation behavior; see
   the Release Guide and [Native Fixture Validation](NativeFixtureValidation.md).

3. For a candidate with an existing release tag at its commit, pass that tag
   to both shared steps:

   ```bash
   Scripts/package-release --tag vVERSION --jobs 2
   Scripts/verify-release --tag vVERSION --run-tests
   ```

   Packaging creates no tag, remote push or GitHub release. CI runs the source
   gates, packaging and archive acceptance for pushes to `master`, pull requests
   and manual runs. The release workflow performs the same checks on its
   checked-out tag, triggered by a `v*` tag push or a manual existing `tag`
   input. Each release workflow build independently accepts its tagged archive.

4. The release build job has read-only repository permissions. It transfers
   the accepted archive, checksum, provenance and verification receipt to an
   independent Linux publication job in `computer-mcp/apple-cli`. The publisher
   needs Python 3.12 or newer and `gh`; its job-scoped token has
   `contents: write`. It verifies the four files against the tag checkout,
   source handoff and acceptance run, then checks the remote tag's peeled
   commit. It creates or resumes a draft, verifies existing assets, uploads
   missing files, checks uploaded sizes and digests, rechecks the remote tag
   and publishes those accepted bytes. Prerelease versions set the GitHub
   prerelease flag. The publication step does not rebuild or re-sign.

The release scripts require Python 3.12 or newer for archive validation.
`Scripts/verify-release --require-verification` checks accepted files and the
receipt without executing macOS programs, as used by the Linux publisher.
Local candidate acceptance is development evidence; formal publication requires
the release workflow's accepted files and run identity. Installation and
Homebrew distribution procedures are in the Release Guide; the
[organization tap](https://github.com/computer-mcp/homebrew-tap) owns its
distribution metadata and downstream installation acceptance.

## Evidence Reuse and Invalidation

Trusted publication evidence is the release workflow's accepted four-file
artifact. Provenance binds it to the source commit/tree, dependency lock,
toolchain, SDK, generated link inputs, validation-log hashes and binary/archive
digests. Archive acceptance binds the checker digest and tested environment.
The publisher verifies those receipts and the remote tag, and requires the
acceptance repository, run ID and run URL to match its current Actions run.
These are consistency checks on trusted workflow outputs, not independently
signed receipt attestations.

Reuse successful evidence for matching inputs and intact accepted bytes.
Source, dependency, build configuration, packaging, rebuild or re-sign changes
require a new candidate and affected downstream acceptance. Checker changes
invalidate checker evidence. Current verification requires the archive's exact
clean source commit/tree, so a committed check-only change also requires a
fresh candidate. There is no separate check-only artifact-reuse mechanism.
Source tests do not replace installation checks on the actual archive.

For interrupted publication, rerun the failed publication job in the same
Actions run to reuse its successful build's artifact. The original acceptance
attempt remains recorded; publication matches the run ID rather than requiring
that original attempt to equal the retry attempt. Matching draft assets are
verified and missing assets are uploaded. An already published release with
the same complete accepted files succeeds read-only. Incomplete, different or
unexpected assets are refused. Reusing a draft with different build bytes
requires manual disposal of that incomplete draft before a fresh candidate is
published, under VERSIONING. An expired or unavailable workflow artifact needs
a new build and acceptance; a standalone recovery command is not established.

Preserve failed logs and identify subsequent attempts separately before
retrying. Archive executable acceptance has a 120-second deadline and reuses
its log path for the same archive name. Build logs use separate run
directories. Workflow attempt records and logs retain timing and failure
context; local evidence supports only the source, artifacts and checks it
covers.

## Entry Points and Artifact Retention

Run repository commands from the source root. `VERSION` and `TAG` below denote
the intended candidate's existing version and tag, not inferred installed
values.

| Operation | Existing command or explicit manual procedure | Required access |
| --- | --- | --- |
| Version update and check | Manually edit `CLIVersion.current` and changelog; `Scripts/validate-version [--tag TAG] [--json]`. Automated version selection/update is not established. | Source write for edits; read for validation |
| Source/documentation checks | `Scripts/validate-public-content`; `python3 -B -m unittest discover -s Tests/ReleaseTools` | Source read; temporary fixture writes; Swift toolchain |
| Candidate validation and build | `Scripts/package-release [--output DIRECTORY] [--tag TAG] [--jobs COUNT]`, then `Scripts/verify-release [--directory DIRECTORY] [--tag TAG] --run-tests` | Clean source; native macOS arm64, Xcode/SDK and writable build output |
| Existing accepted-file check | `Scripts/verify-release [--directory DIRECTORY] [--tag TAG] --require-verification` | Clean matching source and artifact read; Python 3.12+ |
| Status and interrupted-run recovery | Inspect the Actions run and artifact manually; rerun its failed publication job with the original accepted files. A standalone status/recovery command is not established. | Actions read; workflow rerun permission |
| Acceptance and publication | Existing-tag release workflow; its publish job invokes `Scripts/publish-release [--directory DIRECTORY]` | Workflow environment, accepted artifact and scoped GitHub release write |
| Cleanup | Manually inventory and remove owned reproducible output; no cleanup command is established. | Write access to the owned output |

Output defaults to `.build/releases`. One verification directory contains just
the archive, checksum, adjacent provenance and, after executable acceptance,
verification receipt. Existing packaging output names are refused. Both
workflows upload those files and preserve `.build/release-validation` logs even
after failed validation. Their artifact names include run ID and attempt. The
workflows set no `retention-days`; Actions retention depends on settings not
established in this repository. Published assets and release notes hold the
durable release record under VERSIONING.

Build logs, Notes link inputs, staging and caches belong beneath `.build`.
The packager removes its temporary staging directory on exit. Before manually
removing reproducible caches or completed outputs, check run ownership and
preserve unique source changes, required evidence, active-process inputs and
necessary rollback artifacts. Production app data is outside release-output
cleanup.
