# Versioning

apple-cli adopts the [Computer MCP version rules](https://github.com/computer-mcp/.github/blob/master/VERSIONING.md).
The following repository-specific requirements supplement them. Release facts,
commands and checks are owned by the [release reference](Documentation/Reference/Release.md).

## Version Identity

Product versions have no build metadata. Build/run identifiers, commit hashes
and timestamps belong in provenance.

## Prerelease Acceptance

Prerelease counters are positive integers, starting at 1 for each stage.
For an unreleased base version, successive alpha previews increment that
counter. Beta indicates that the planned scope is complete; rc indicates that
the candidate meets the intended release acceptance. Stages are optional.
Removing the prerelease suffix requires acceptance for the declared release
scope.

## Stable Interface Acceptance

Adopting `1.0.0` requires evidence for the essential documented workflows in
the supported environment. Capability completeness is judged against the
declared scope; target limitations and private-system-API constraints remain
explicit in the product guides.

## Changelog Content

Each release entry explains the affected component, the change and its upgrade
reason.

## Candidate Corrections

A failed untagged candidate may be corrected at the same product version.
A failed workflow attempt alone does not change the product version.
