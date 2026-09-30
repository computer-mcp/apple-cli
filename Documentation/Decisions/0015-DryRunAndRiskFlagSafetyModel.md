# 0015: DryRun And Risk Flag Safety Model

## Status

Accepted.

## Context

The CLI needs a safety model that works for humans and agents without storing
confirmation state or replaying opaque tokens. The previous two-step model made
the preview payload look like authorization data and pushed too much behavior
into confirmation mechanics. That made target docs, MCP descriptions, skills,
and tests easy to misread.

Kubernetes dry-run is the upstream reference for the new semantics:

- [Kubernetes API concepts: dry run](https://kubernetes.io/docs/reference/using-api/api-concepts/#dry-run)
- [Kubernetes Dry Run KEP 576](https://github.com/kubernetes/enhancements/blob/master/keps/sig-api-machinery/576-dry-run/README.md)

The local CLI adaptation keeps the same core invariant: process a mutation
request through parsing, normalization, resolution, and validation, then stop
before side effects and return the would-be result.

## Decision

Use `DryRun` plus concrete risk flags as the repository-wide safety model.

- `--dry-run` is preview mode for mutation and external-action commands.
- A `DryRun` payload reports `mode`, `target`, `operation`,
  `normalizedArguments`, `resolvedScope`, `wouldMutate`, `requirements`, and
  `risks`.
- Real execution returns an `OperationResult`.
- No CLI command stores confirmation state or requires a preview token.
- Ordinary explicit mutations may execute without a generic allow flag.
- Risky operations require concrete `--allow-*` flags.
- Read-only commands reject `--dry-run` unless a target explicitly supports a
  read preview.
- MCP adapters preserve the target-local CLI safety policy. They do not add
  hidden authorization behavior.
- Skills instruct agents to use `--dry-run` for preview and to add `--allow-*`
  only when the user explicitly authorized the risk.

## Safety Vocabulary

The accepted cross-target categories are:

- `readOnly`
- `boundedRead`
- `ordinaryMutation`
- `destructiveSelection`
- `externalDispatch`
- `riskBoundSystemAction`
- `artifactAction`
- `persistentAction`

`Documentation/Reference/SafetyGates.md` owns the reader-facing definitions.

## Consequences

- This is a breaking migration. The old execution option is removed rather
  than kept as compatibility behavior.
- Public docs and examples describe `DryRun`, `OperationResult`, and concrete
  allow flags.
- Test coverage should verify parser rejection of the removed option, dry-run
  payload shape, ordinary mutation execution, and required allow flags for
  destructive, external-dispatch, artifact, persistent, and system-risk
  commands.
- Target implementation remains target-local. The shared Utility layer owns
  only mechanics and vocabulary, not Apple app business models.

## Related Documentation

- Date: 2026-06-18
- Related architecture docs:
  - [CLI Contract](../Architecture/CliContract.md)
  - [Safety Gates](../Reference/SafetyGates.md)
  - [MCP Adapter Boundary](../Architecture/McpAdapterBoundary.md)
