# FaceTime Capability List

## Source Authority

FaceTime capabilities are accepted from Contacts.framework identity resolution
and FaceTime URL call behavior.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Contact resolution | `contacts resolve` | Contacts.framework | Read-only. |
| Call preview | `calls prepare` | Contacts.framework plus FaceTime URL planning | Read-only preview. |
| Call start | `calls start` | FaceTime URL external action | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |

## Rejected / Gated

- Raw FaceTime.app scripting.
- Background or silent call initiation.
