# Safari As SDEF Parity Sample Target

## Status

Accepted

## Context

Safari exposes a focused Safari-specific scripting dictionary with windows,
tabs, page URL/title/text/source, Reading List, JavaScript evaluation, email
contents, web search, bookmarks UI, and hidden/private/internal commands.

The repository already has SDEF-backed target-local automation for Notes, Mail,
Messages send, and part of Numbers. ADR 0010 defines complete SDEF accounting:
every relevant SDEF row must become a domain CLI command, semantic replacement,
strong-gate candidate, or proof-failed record.

Safari is the best sample target for proving this rule because its SDEF surface
is smaller than Mail or Numbers but still includes reads, state actions,
persistent mutations, code execution, cross-app actions, and hidden entries.

## Decision

Safari is accepted for implementation as a first-class `safari` target under
the canonical `apple` CLI.

The implementation remains target-local in `SafariCLI`. It must use typed
`swift-argument-parser` commands, structured Safari AppleScript, target-local
validation, bounded output, `DryRun` payloads, and strong gates. It must not expose a raw
AppleScript runner, JXA runner, generic browser automation surface, or hidden
MCP-only behavior.

Architecture current truth is updated only after source implementation, tests,
executable contract validation, and docs drift scans pass.

## Consequences

- `SafariCLI` becomes the sample for complete SDEF mapping and safety gates.
- The MCP adapter lists `safari` only because it is part of the canonical CLI
  target catalog; MCP does not get Safari-specific tools.
- Strong-gate Safari commands require explicit allow flags, selector binding,
  timeouts, output caps where applicable, and payload/script hashes.
- Hidden/private/internal Safari entries stay visible as strong-gate or
  proof-failed records instead of being dropped.
- Other SDEF-backed targets should use Safari as the comparison point for
  mapping, gates, and proof tests.

## Alternatives Considered

- Keep Safari candidate-only. This preserves the catalog but leaves the SDEF
  parity design unproven in production.
- Implement only Safari read commands. This would create another partial demo
  target and fail the complete SDEF accounting rule.
- Expose generic browser AppleScript. This would be faster but violates the
  target-first CLI contract and safety model.

## Related Documentation

- Date: 2026-05-18
- Related docs:
  - [SDEF Parity And Safety Gates](0010-SDEFParityAndSafetyGates.md)
  - [Safety Gates](../Reference/SafetyGates.md)
  - [Target Implementation Mechanisms](../Architecture/TargetImplementationMechanisms.md)
