# Contributing

## License And Contributions

apple-cli uses the [Apache License 2.0](LICENSE). Unless you explicitly state
otherwise or a separate agreement applies, contributions intentionally submitted
for inclusion are licensed under these terms. Contributors retain copyright in
their original work and must have the right to submit it. Preserve the licenses
and notices of third-party components.

## Repository Work

Keep repository documentation changes small, boundary-first, and placed by
role.

The canonical project is `computer-mcp/apple-cli`. Read `README.md` and
`AGENTS.md` before changing a target. Keep command behavior, diagnostics,
identity resolution and risk gates with their owning target.

## Where To Change

- Route instructions: `AGENTS.md`
- Public manual and entry index: root `README.md`
- Documentation reading index: `Documentation/README.md`
- Current architecture truth: `Documentation/Architecture/*`
- Design-in-progress: `Documentation/Proposals/*`
- Historical decision records: `Documentation/Decisions/*`
- Migration and rollout records: `Documentation/Migrations/*`
- Retired or superseded material: `Documentation/Archive/*`
- Supporting reference material: `Documentation/Reference/*`
- GitHub-facing collaboration files: `.github/*`
- Repo-wide contributor policy: root governance files such as this file

## Placement Discipline

- Keep route instructions in `AGENTS.md`.
- Keep repository and subtree indexes in `README`-class files.
- Keep current canonical structure in `Documentation/Architecture/*`.
- Keep open alternatives and design drafts in `Documentation/Proposals/*`.
- Keep adopted rationale in `Documentation/Decisions/*`.
- Keep transition records in `Documentation/Migrations/*`.
- Keep retired, non-current material in `Documentation/Archive/*`.
- Keep stable supporting material in `Documentation/Reference/*`.
- Keep GitHub-specific collaboration files in `.github/`.

## Validation

For documentation-only changes, run path and link scans for moved files. For
changes that touch scripts, tests, package manifests, or generated package
contents, also run the repository package validation commands.

```bash
Scripts/validate-public-content
Scripts/validate-version
python3 -B -m unittest discover -s Tests/ReleaseTools
Scripts/bootstrap
xcrun swift build --force-resolved-versions
xcrun swift test --force-resolved-versions
```

Default tests should use fixtures or injected backends. Host Notes reads require
`APPLE_CLI_RUN_NOTES_INTEGRATION_TESTS=1`; do not enable them in ordinary CI or
replace a failing default test with a skipped test. Use synthetic data in
fixtures, issue reports and logs. Preserve passphrase and personal-data boundaries.

Include the problem, resulting behavior and relevant validation in a pull
request. Dependency changes must update `Package.resolved`, the copied license
texts and `THIRD_PARTY_NOTICES.md` together. Version selection follows
[Versioning and Release](Documentation/Architecture/VersioningAndRelease.md).
See the [Release Guide](Documentation/Reference/ReleaseGuide.md) for candidate packaging,
compatibility evidence and publishing boundaries.
