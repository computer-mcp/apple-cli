# Clipboard Architecture

`clipboard` owns the current macOS pasteboard under `apple clipboard`.

## Capability Maturity

Current level: `L0 Public Framework / SDEF / AppleScript`

Clipboard uses the public NSPasteboard and NSPasteboardItem APIs. Typed item
reads and replacement preserve item order, declared format order and raw bytes.
The target's capability list states the supported surface.

## Source Authority

[NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
and [NSPasteboardItem](https://developer.apple.com/documentation/appkit/nspasteboarditem)
define the pasteboard's ownership, representations and native conversions.

## Implementation Mechanisms

The backend uses the general pasteboard for CLI commands. It retains a
pasteboard name rather than sharing native item objects between operations.
Native items used for writes are fresh and unbound.

`types` returns metadata and an ownership counter. Legacy `read` retains
NSPasteboard's text selection and multi-item text joining behavior. `items read`
returns individual items, their native format order and base64 data. Unavailable
promised data stays unavailable; a missing representation is not empty data.

Byte caps bound accepted and returned raw representation data after AppKit
fetches it. AppKit obtains each complete representation from its provider;
these caps do not bound that provider's allocation or response time.

Replacement validates the entire payload before clearing the pasteboard.
Formats advertised by NSFilePromiseReceiver are rejected: their data contains
transfer metadata that requires a live provider to create the promised files.
Raw reads can inspect those bytes but do not accept or fulfill a file promise.
Write results require successful native writes, the requested item order,
format order and bytes, and unchanged ownership during readback. AppKit may
add compatibility formats. Complete identical payloads skip writing; RTF's
additional native plain-text formats permit a skip only when their decoded
text agrees with the RTF. Other extra formats require replacement.

Writes support `--current-host-only` through NSPasteboard's
`prepareForNewContents(with: .currentHostOnly)`. Contents options have no public
getter, so an explicit restriction always obtains new ownership, including
when the data is unchanged. Byte equality alone cannot verify that option.

The ownership counter and `--if-change-count` guard observable ownership
changes. NSPasteboard has no atomic compare-and-swap operation; an owner can
also supply promised data without changing that counter. These checks do not
provide an atomic content snapshot or reserve the pasteboard.

An unverified replacement reports an error with possible mutation, and does
not restore an old snapshot over a newer owner. Empty clear requests preserve
the counter and return `changed: false`. Programmatic reads follow the app's
macOS pasteboard access setting.

## Validation

The SystemDomainCommandTests suite owns Clipboard contract regressions and
the opt-in native workflow. It uses a unique pasteboard, verifies native rich
text/image/URL consumers and checks empty cleanup before releasing it.
Detailed operating instructions live in the Developer Guide.
