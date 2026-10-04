# apple-cli Agent Guide

This repository is a docs-first and CLI-first SwiftPM package.

## First-Principles Work

- Name the behavior, root cause, invariant, owner, data flow, and validation
  before changing reusable files.
- Change the owning layer: architecture truth, decision/history, target-local
  CLI code, MCP adapter, docs, or active execution state.
- Keep changes traceable to the request, source evidence, or owning invariant.
- Validate Swift package changes with package-local build or test checks.

## Task Route

Read `README.md` first for repository purpose and entry points.

## Current Truth

Use `Documentation/Architecture/` for current architecture truth:

- `RepositoryIdentity.md`
- `TargetFirstCli.md`
- `CapabilityList.md`
- `CliContract.md`
- `McpAdapterBoundary.md`
- `TargetImplementationMechanisms.md`
- `Intelligence/Architecture.md`

Target-specific current truth lives under the owning documentation role, for
example `Documentation/Architecture/Reminders/Architecture.md` and
`Documentation/Architecture/Reminders/CapabilityList.md`.

Decision records live in `Documentation/Decisions/`.

## Authority

- `AGENTS.md` is the agent guide for repository work.
- `README.md` is the repository entry point.
- `Documentation/Architecture/*` owns current architecture truth.
- `Documentation/Architecture/<Target>/*` owns target-specific architecture
  truth and capability lists.
- `Documentation/Reference/<Target>/*` owns target-specific user guides,
  developer guides, and validation references.
- `Documentation/Decisions/*` owns accepted history.
- `Documentation/Reference/*` owns supporting reference material.
- `.agent/*` owns temporary execution state.
- `Package.swift` owns SwiftPM package structure.

## Documentation Role Rules

When changing documentation, keep roles separate:

- `AGENTS.md` is the agent guide for repository work.
- `README.md` files index and introduce content.
- `Documentation/Architecture/` states current truth.
- `Documentation/Architecture/<Target>/` states target-specific truth.
- `Documentation/Reference/<Target>/` holds target-specific supporting guides.
- `Documentation/Decisions/` records accepted history.
- `Documentation/Reference/` holds supporting reference material.

## Boundary Guardrails

- Do not promote machine-local paths, one-run state, fixture-only values, or
  temporary execution state into reusable docs, scripts, templates, or
  automation.
- Keep shipped docs focused on current product facts, supported behavior, and
  operating guidance. Keep temporary implementation notes, local evidence, and
  historical comparison notes out of README files, Reference docs, API docs, and
  user-facing artifacts.
- Do not inherit external product architecture or promote raw external project
  facts into architecture truth.
- Keep `.agent/*` as temporary execution state unless reviewed material is
  promoted into the owning durable docs.
- For agent integration and usage-guidance ownership, route to
  `Documentation/Architecture/CliContract.md` and
  `Documentation/Reference/AppleCLIUserGuide.md`. Target-specific usage guidance
  belongs in `Documentation/Reference/<Target>/UserGuide.md` when that target
  has a dedicated reference directory.

## Operating Notes

The following sections are package-specific operating notes.

## Brand Delivery

README headers and the social preview come from the Computer MCP organization
`.github` repository through `.github/brand/brand.lock.json`. Update them only
with that repository's `python3 Brand/brand.py sync`; CI verifies the lock.

## Execution Plans

Use `.agent/PLANS.md` as the active temporary execution-state surface for
large, multi-step, or handoff-prone work. It is not architecture truth,
reference material, a decision record, or GitHub governance.

Keep `.agent/PLANS.md` self-contained and current while work is active:
record status, next action, progress, discoveries, decisions, validation, risks,
and closeout notes. Do not put active agent plans at repository root, under
`Documentation/`, under `.github/`, or in ad-hoc `plans/` files unless an
explicit future repository policy changes this route.

## Source Review Work

Keep temporary source review notes, local evidence, and temporary analysis out
of durable architecture truth. Promote only stable current-truth material into
`Documentation/Architecture/`, accepted history into
`Documentation/Decisions/`, and stable reference material into
`Documentation/Reference/`.

Do not inherit external product architecture or promote raw external project
facts into architecture truth. External sources are inputs for target-local
reuse decisions, not the source of this repository's architecture.

## Implementation Boundary

Do not implement Apple app CLI functionality during docs-first intake passes.
Keep target ownership independent. The package declares exactly two executable
products:

- `apple`
- `apple-cli-mcp`

`apple` is the canonical target-first CLI. `apple-cli-mcp` is an adapter over
that CLI contract.

The accepted command targets under `apple` are:

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

Each `<Target>CLI` module owns its typed `swift-argument-parser` command tree,
  target-local validation, implementation behavior, diagnostics, and mutation or
external-action safety policy. `AppleCLI` only composes the root `apple`
command. `AppleMCPServer` and `AppleMCPAdapter` use the official MCP Swift SDK
directly; business modules do not import MCP.

The complete target catalog lives in
`Documentation/Architecture/RepositoryIdentity.md` and
`Documentation/Architecture/TargetFirstCli.md`. The current accepted target
capability surface lives in
`Documentation/Architecture/CapabilityList.md`.

SwiftPM target/module names should use Swift identifier style, for example
`NotesCLI`. CLI products remain `apple` and `apple-cli-mcp`; command targets
stay lowercase under `apple`, for example `apple notes`.
