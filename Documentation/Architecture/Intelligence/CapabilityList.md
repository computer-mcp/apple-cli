# Intelligence Capability List

## Source Authority

Intelligence capabilities are accepted from the target-local Apple Intelligence
local-cache workflow and host diagnostics. This file is the target-local
capability truth for `apple intelligence`.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Support and diagnosis | `support`, `doctor`, `verify` | Foundation plist reads and bounded host fact checks | Read-only diagnostics. |
| Enablement | `enable` | Foundation plist writes to local eligibility cache | Requires explicit `--allow-system-cache-write`; not `DryRun` payload-based. |
| Cache and recovery | `reset-cache`, `rollback`, `unlock` | Bounded file/cache/service operations | Uses target-specific risk flags. |
| Recompute and service | `recompute`, `service install/uninstall` | Bounded subprocess and LaunchDaemon workflows | Requires explicit debug/service risk flags. |

## Rejected / Gated

- Runtime `curl` or third-party script execution.
- Unpinned external binaries.
- Silent debug attach.
- Broad cache deletion and beta-only system spoofing experiments.
