# Notifications Architecture

`notifications` owns notification preview and send workflows for notifications
created by this tool.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Rationale: Notifications currently uses a target-local delivery path for this
tool's notifications. It does not currently rely on a broad private
notification history or system notification implementation mechanism.

## Source Authority

The target-local notification delivery behavior defines the accepted command
surface.

## Implementation Mechanisms

Notifications uses the target-local legacy CLI delivery path. Direct broad
UserNotifications probing is not part of the unbundled SwiftPM CLI process.

## Validation

Use system-domain command tests and executable contract validation. Detailed
command status lives in `CapabilityList.md`.
