# Notifications Capability List

## Source Authority

Notifications capabilities are accepted for notifications created by this tool.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Preview | `preview` | Target-local notification preview | Read-only preview. |
| Settings | `settings` | UNUserNotificationCenter | This application's authorization and alert/sound/badge/center/lock-screen settings; no authorization request. |
| Authorization | `permissions request` | Native authorization callback | Supports `--dry-run`; execution requires `--allow-persistent-action` and the person's system choice. |
| Send | `send` | Native add callback | Supports `--dry-run`; requires `--allow-external-dispatch` and authorization. Native rejection is an error; successful submission does not prove presentation. |
| Identity and delay | `--id`, `--delay-seconds` on preview/send | Native request ID and one-time trigger | IDs use `apple-cli:`; optional delay is 1...604800 seconds. Authorized persistence and delivery need native verification. |
| Pending queries | `pending list`, `pending read` | Native pending-request callback | Own namespace; ID-sorted summaries with default limit 50 and maximum 500; exact reads include content and trigger fields. |
| Pending cancellation | `pending cancel` | Exact-ID removal and fresh pending readback | `--dry-run` or `--allow-persistent-action`; absent IDs make no removal call. Absence does not prove the notification did not fire. |
| Notification Center queries | `delivered list`, `delivered read` | Native delivered-notification callback | Own namespace and entries still in the center; includes delivery date, not read status or complete history. |
| Notification Center removal | `delivered remove` | Exact-ID removal and fresh delivered readback | `--dry-run` or `--allow-persistent-action`; reports attempted/previous presence/verified absence. Nonempty removal requires native verification. |
| Diagnostics | `doctor` | Native per-app settings and embedded identity | Queries this application; does not request authorization. |

## Rejected / Gated

- Global notification history.
- Broad system notification automation.
- Creation with richer triggers, actions, sounds, badges and attachments.

The current-host native proof covers identity, settings, empty scoped collections
and an unauthorized submission rejection with cold absence. Authorized scheduling,
CLI-exit persistence, nonempty cancellation/removal and presentation remain unverified.
