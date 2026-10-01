# Versioning and Release

This document owns the version and release rules for apple-cli. The shared
packaging, archive acceptance and GitHub publication workflow are implemented.
Version selection and compatibility review are manual. Operating instructions
live in the [Release Guide](../Reference/ReleaseGuide.md).

## Version Authority

| Component or field | Authority | Check |
| --- | --- | --- |
| `apple`, its target commands and `apple-cli-mcp` | `CLIVersion.current` in `Sources/Utility/CLIVersion.swift` | Executable and MCP initialization tests |
| Product version and release notes | The version declaration and its single entry in `CHANGELOG.md` | `Scripts/validate-version` |
| Release tag | `v` followed by the product version, resolving to the candidate commit | `Scripts/validate-version --tag TAG` |
| Archive name, provenance and acceptance receipt | The checked source version and accepted build | `Scripts/package-release` and `Scripts/verify-release` |

Both products release together. Target modules and source skills follow the
repository release; they have no independent product version declaration.
Installed binaries and previous build directories do not determine the next
source version.

## Format and Upgrades

The project follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html)
with the following release formats:

- `MAJOR.MINOR.PATCH` for a release without a prerelease suffix.
- `MAJOR.MINOR.PATCH-alpha.N`, `-beta.N` or `-rc.N` for prereleases.
- All numeric fields use ASCII digits without leading zeros; `N` starts at 1.

Build/run identifiers, commit hashes and timestamps belong in provenance.
Compatibility covers command paths and options, exit codes, structured output,
MCP tool schemas, mutation and external-action gates, and documented runtime
requirements. Review the affected behavior and its tests before classifying a
change. A version comparison does not establish compatibility.

| Change to released behavior | During `0.x` development | From `1.0.0` onward |
| --- | --- | --- |
| Compatible bug fix | Increment PATCH | Increment PATCH |
| Compatible feature | Increment MINOR and reset PATCH | Increment MINOR and reset PATCH |
| Incompatible contract or supported-runtime change | Increment MINOR and reset PATCH; describe the break | Increment MAJOR and reset MINOR and PATCH; describe the break |

The `0.x` contract is under development. The table provides predictable upgrade
signals without promising long-term API stability. Documentation, CI and cleanup
changes alone do not require a new product release. If a dependency change
affects shipped behavior, classify that behavior under the same table.

For an unreleased base version, iterate its preview with `alpha.1`, `alpha.2`
and subsequent positive numbers. Use beta when the planned scope is complete
and rc when the candidate meets the intended release acceptance. Each stage
starts at 1; stages are optional. For example, `0.1.0-alpha.2` can advance to
`0.1.0-beta.1`, `0.1.0-rc.1`, then `0.1.0`. Removing the prerelease suffix
requires acceptance for the declared release scope.

Adopt `1.0.0` when the public contract is ready for stability commitments and
the essential documented workflows have evidence for the supported environment.
Capability completeness is judged against that scope. Known target limitations
and private-system-API constraints remain explicit in the product guides.

Select versions manually by updating the declaration and adding a nonempty
Changelog entry. The entry explains the affected component, change and upgrade
reason. Keep prior release entries as history. Read-only checks fail on drift;
they do not edit versions or infer an upgrade from changed files.

## Dependencies and Verified Combinations

`Package.swift` owns dependency ranges. ArgumentParser and the MCP Swift SDK
use exact versions; Hummingbird and Subprocess are bounded by the next minor
version, and HTTPTypes by the next major version. `Package.resolved` owns the
selected versions and revisions. Test and release builds use `--force-resolved-versions`,
and provenance records the lockfile digest and the resolved dependencies.

When updating a dependency, confirm that its selected upstream release tag
resolves to the locked revision, using that project's tag spelling. This is a
maintenance review step; the release checker verifies the local lockfile and
its provenance digest. Update the dependency notices and copied licenses with
the selected sources. Revalidate affected behavior when a dependency changes.

The MCP protocol baseline, the MCP SDK dependency version, the Swift toolchain
and the apple-cli product version have separate meanings. A successful run
establishes the locked dependency, OS, SDK and toolchain combination recorded
in its evidence, within the checks actually performed.

## Candidate, Acceptance and Publication

`Scripts/validate-version` checks the single declaration, accepted format and
one nonempty Changelog entry. Its optional tag check requires an existing
matching tag at `HEAD`. It can check a working tree during editing; release
packaging additionally requires a clean committed source checkout.

The CI workflow builds and accepts an untagged candidate. The release workflow
checks out an existing version tag and uses the same packaging and archive
acceptance scripts. The macOS build job has read-only repository permissions.
The publication job receives the four accepted files and scoped write access,
checks their provenance and the remote tag, uploads and verifies draft assets,
then publishes those same bytes. Prerelease versions retain prerelease status.

Tags identify immutable source commits. Published versions and artifact bytes
are immutable. Changed source after a version tag needs a new version tag;
an updated preview increments its prerelease number. Before tagging, a failed
candidate can be corrected without consuming a formal patch version. A failed
workflow attempt alone does not change the product version.

An interrupted publication can reuse the successful build's accepted files.
Matching draft assets are verified; missing ones are uploaded. A rebuild or
re-sign requires new artifact acceptance. The Release Guide describes recovery
when an incomplete draft has different bytes.

## Evidence Reuse and Invalidation

Provenance binds the candidate to its commit/tree, dependency lock, selected
toolchain and SDK, generated link inputs, validation logs and binary/archive
digests. Archive acceptance records the exact checker digest and tested
environment. The publication job requires matching provenance and acceptance
receipts from the same GitHub run and confirms the remote tag's commit.

Reuse successful evidence only for matching inputs and intact accepted bytes.
Source, dependency, build configuration or packaging changes need a new
candidate and affected downstream checks. Checker changes invalidate checker
evidence. The current scripts require the archive's exact clean source
commit/tree: even a check-only change committed on a new revision needs a fresh
CI candidate. That requirement does not itself force a product version bump.

Source tests do not replace installation checks on the actual archive.
Preserve failed logs and identify subsequent attempts separately; local evidence
and compatibility claims remain limited to the source, artifacts and checks
they cover.

## Entry Points and Retention

| Operation | Entry point | Access |
| --- | --- | --- |
| Select a version | Edit `CLIVersion.current` and its Changelog entry | Source write |
| Check version inputs | `Scripts/validate-version [--tag TAG] [--json]` | Source read |
| Test release-input gates | `python3 -B -m unittest discover -s Tests/ReleaseTools` | Temporary fixture write |
| Build and accept a candidate | `Scripts/package-release`, then `Scripts/verify-release --run-tests` | Local build output or CI build job |
| Verify existing accepted files | `Scripts/verify-release --require-verification` | Source and artifact read |
| Publish and resume | Existing-tag release workflow; rerun failed publication job | Scoped GitHub release write |

Validation outputs and run logs belong beneath `.build`; active local execution
records belong beneath `.agent`. Retain required evidence and rollback artifacts.
Before removing reproducible caches or completed temporary outputs, check their
run ownership and preserve unique source changes and anything used by active
processes. Production app data is outside release-output cleanup.
