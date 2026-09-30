# Safari Capability List

## Source Authority

Safari capabilities are accepted from Safari.app scripting behavior and
read-only Safari browser state snapshots.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Windows and tabs | `windows list`, `tab list/current/read/select/open/navigate/close`, compatibility `tabs ...` | Safari.app structured scripting | Reads are bounded; state/destructive actions use target gates. |
| Page reads/actions | `pages read/email-contents/evaluate-javascript` | Safari.app structured scripting | Text/source reads are bounded; email/JavaScript are strong-gated. |
| Profiles and snapshots | `profile list/read`, `window list/read/profile`, `window tab list` | Read-only `SafariTabs.db` snapshots | Read-only with schema detection. |
| Reading List and search | `reading-list add`, `search web` | Safari.app structured scripting | Reading List supports `--dry-run` and execution requires `--allow-external-dispatch`; search is state-action. |
| Tab Groups | `tab group diagnose/list/read/open/select/create/rename/delete/add-tab/remove-tab` | Read-only snapshot for diagnostics/read; mutation/open/select proof remains target-local | Reads supported; mutation/open/select commands fail closed where no accepted Safari-owned mechanism exists. |

## Rejected / Gated

- Direct `SafariTabs.db` writes.
- Raw AppleScript/JXA/UI scripting runners.
- Hidden provider/process metadata and credential-adjacent settings unless separately accepted behind strong gates.
