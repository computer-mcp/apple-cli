# Documentation Path Normalization

## Status

Completed on 2026-05-13.

## Context

The repository already separated architecture truth, decision history, and
reference material, but used a short documentation path that did not match the
SwiftPM documentation role model used for this package.

## Migration

- Moved repository documentation from the legacy short path to
  `Documentation/`.
- Preserved current architecture truth under `Documentation/Architecture/`.
- Preserved accepted decision records under `Documentation/Decisions/`.
- Preserved supporting reference material under `Documentation/Reference/`.
- Added empty role indexes for `Documentation/Proposals/`,
  `Documentation/Migrations/`, and `Documentation/Archive/`.
- Added root `CONTRIBUTING.md` and `.github/README.md` to make collaboration
  and governance placement explicit.
- Updated repository links, scripts, and tests to use `Documentation/`.

## Validation

- No legacy documentation path references remain outside generated or ignored
  build output.
- Markdown local links passed repository-local link checking.
- `swift build` passed.
- `swift test` passed with 327 tests.
- The then-current executable contract validation passed across the CLI target
  catalog plus `apple-cli-mcp`.

## Current Truth

Current architecture truth remains in `Documentation/Architecture/`. This
migration record is historical and does not redefine architecture.
