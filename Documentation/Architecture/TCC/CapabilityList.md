# TCC Capability List

## Source Authority

TCC capabilities are accepted from macOS TCC service, identity, database,
public API, and gated private diagnostic behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Service and identity reads | `services list/read`, `identity read/resolve` | Service catalog and code-signing/LaunchServices reads | Read-only. |
| Database diagnostics | `database info/digest`, `records list/read` | Read-only SQLite inspection | Read-only; no silent grant. |
| Access recovery | `access preflight/request`, `reset` | Public permission APIs and `tccutil` | Explicit risk flags. |
| Private diagnostics | `framework probe/add/reset` | Gated private TCC.framework diagnostics | Explicit allow flags and target-local gates; write results report an attempted call with unverified effect. |

## Rejected / Gated

- Silent permission grants.
- Target-local permission bypasses.
- Ungated private database/framework writes.
