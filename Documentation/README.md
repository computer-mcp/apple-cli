# Documentation

This tree keeps repository documentation roles separate.

- [Architecture](Architecture/README.md) states current architecture truth.
- [Reference](Reference/README.md) holds user guides, developer guides, safety
  references, and supporting material that does not define architecture truth.
- [Decisions](Decisions/README.md) records accepted decisions and rationale.
- [Proposals](Proposals/README.md) holds design-in-progress.
- [Migrations](Migrations/README.md) records transition and rollout notes.
- [Archive](Archive/README.md) keeps retired or superseded material.

The root `README.md` remains the public package entry point. This file is only
the documentation reading index.

## Global Documents

- [Capability List](Architecture/CapabilityList.md): global target capability
  index.
- [Target Implementation Mechanisms](Architecture/TargetImplementationMechanisms.md):
  global implementation mechanism index.
- [Apple CLI User Guide](Reference/AppleCLIUserGuide.md): global CLI usage
  guide.
- [Safety Gates](Reference/SafetyGates.md): global command safety vocabulary.

## Target-Specific Documentation

Single-target documentation stays under the owning documentation role:

- `Documentation/Architecture/<Target>/` for target-specific architecture truth
  and capability lists.
- `Documentation/Reference/<Target>/` for target-specific user guides,
  developer guides, validation notes, and supporting references.

Cross-target architecture and reference files should summarize and link to
these directories instead of carrying detailed target designs, capability lists,
runbooks, implementation evidence, or command-level mappings.

## DocC Placement

This package does not currently ship target-level DocC catalogs. If API
documentation is added later, keep each catalog with the SwiftPM target it
documents, normally at `Sources/<Target>/<Target>.docc/`. Keep generated
`.doccarchive` output out of source documentation unless a publishing policy
explicitly says otherwise.
