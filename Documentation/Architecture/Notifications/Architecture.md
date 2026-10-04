# Notifications Architecture

`notifications` owns notification preview, settings, explicit authorization,
submission and pending/delivered management for notifications created by this tool.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Notifications uses public UserNotifications APIs scoped to Apple CLI.
Authorization and submission are distinct from on-screen presentation.

## Source Authority

[UserNotifications](https://developer.apple.com/documentation/usernotifications)
defines application authorization, request submission and local triggers.

## Implementation Mechanisms

The `apple` executable embeds its application identity,
`io.github.computer-mcp.apple-cli`, in its Info.plist. The backend checks that identity
before obtaining UNUserNotificationCenter. The adapter invokes the same CLI.

`settings` and `doctor` query this application's native settings without
requesting authorization. Only `permissions request` asks the system for
alert, sound and badge authorization; execution requires
`--allow-persistent-action`. Denial is reported in the authorization result.

`send` requires `--allow-external-dispatch` and a native authorized or
provisional state. It does not request authorization automatically. A successful
add callback establishes `submitted`; a native rejection returns an error.
An add timeout reports possible mutation and the request ID, because a late
completion may still accept the request.

Request IDs use the `apple-cli:` namespace. Omitted IDs are generated at
execution; provided IDs replace the same native request according to the
framework contract. Optional delays create one-time native time-interval
triggers. Focus, presentation settings and suppression remain system behavior.

Pending and delivered queries use native callbacks and expose only IDs in this
tool's namespace. Lists are sorted by ID and cap returned summaries; exact reads
include title, subtitle, body and native trigger information. Delivered entries
include the native delivery date and cover entries still in Notification Center.

`pending cancel` and `delivered remove` require `--allow-persistent-action`.
They remove only the selected ID and query the same collection again. Results
separate `attempted`, `wasPresent` and `verifiedAbsent`; an absent ID is a no-op.
A failed readback or an entry that remains returns an error with possible-mutation
details. The pending absence check does not establish whether the request fired
during cancellation, and IDs do not provide atomic comparison against a concurrent
replacement. Removal does not establish user-read status.

## Validation

Use the existing SystemDomainCommandTests and executable metadata tests.
The callback regression checks native error mapping, first completion and
unknown timeouts. Native-object projection covers content, namespace and triggers;
real executable reads cover settings and scoped collections. Authorized scheduling,
request persistence after CLI exit, nonempty cancellation and presentation require
separate native verification. Detailed command status lives in `CapabilityList.md`.
