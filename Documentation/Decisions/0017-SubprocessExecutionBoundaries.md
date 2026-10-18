# Subprocess Execution Boundaries

## Status

Accepted, 2026-09-30

## Context

Target commands use synchronous `ParsableCommand` execution. The previous
subprocess bridge scheduled an asynchronous task and blocked the caller until
that task completed. Concurrent synchronous callers could exhaust the Swift
cooperative executor while the awaited work needed that same executor.

The pinned `swift-subprocess` API is asynchronous. Moving only the initial task
to another executor cannot establish independent progress for the library's
unstructured cleanup tasks, and newer executor APIs would raise the deployment
requirement. MCP already has an asynchronous request boundary.

## Decision

`Utility` owns two process entry points with the same result shape and byte
limits. Synchronous CLI callers execute native `Foundation.Process` and poll
both output pipes directly. No Swift task must run for this path to finish.
Asynchronous callers await the official `Subprocess.run` API directly.

Each execution owns its pipes, deadline, exit observation, and cleanup. Output
overflow fails rather than returning a truncated success. Deadlines include
process lifetime even when both pipes close early. An exited child cannot wait
indefinitely for descendants holding an output writer.

The asynchronous path creates an isolated process group, redirects output
through the SDK to caller-owned nonblocking pipes, and polls without blocking
the executor. It can close its readers on failure even when a descendant
retains a writer, and signals the owned group during cleanup.
Exit observation does not reap the child: the SDK retains that ownership.
Cancellation propagates through the MCP runner and handler. Signals cannot
affect descendants that deliberately leave the owned process group.

## Consequences

- Target command grammars and app automation remain synchronous.
- MCP subprocess waits yield instead of blocking a cooperative worker.
- The existing macOS deployment declaration remains unchanged.
- A synchronous caller blocks only its own execution while native IO and
  process management make progress independently.
- Tests cover executor saturation, both pipes, byte limits, deadlines,
  cancellation, signals, and inherited writers under an external watchdog.

## Related Documentation

- [Target-First CLI](../Architecture/TargetFirstCli.md)
- [MCP Adapter Boundary](../Architecture/McpAdapterBoundary.md)
- [Direct Official Package Mechanics](0008-DirectOfficialPackageMechanics.md)
