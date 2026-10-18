# Clipboard User Guide

Use `apple clipboard --help` and subcommand help as the first reference.

Inspect types and the current ownership counter without returning content:

```bash
apple clipboard types --json
apple clipboard doctor --json
```

Read plain text, or inspect rich content with item boundaries preserved:

```bash
apple clipboard read --max-bytes 1048576 --json
apple clipboard items read --limit 50 --max-bytes 1048576 --json
apple clipboard items read --type public.png --json
```

`read` uses the native text behavior, which can join text from multiple items.
`items read` returns each item's native representations. `dataBase64` contains
the exact data for a type; an omitted value means the declared data could not
be obtained. `ordinal` is the item's original one-based position.

Reads are sensitive. The default byte cap is 1 MiB and the maximum is 64 MiB,
counting raw data across returned representations, including native derived
formats. The item limit defaults to 50 and cannot exceed 500. An exceeded byte
cap fails the read. Item limits report `truncated`; a type filter reports
`filtered`. macOS may ask for pasteboard access according to the app's
Paste from Other Apps setting.

Preview a plain-text replacement:

```bash
apple clipboard write --text "hello" --dry-run --json
apple clipboard write --text "hello" --allow-persistent-action --json
```

Add `--current-host-only` to either write command to keep its new contents
on this device:

```bash
apple clipboard write --text "hello" --current-host-only \
  --allow-persistent-action --json
```

An explicit `--text ""` writes an empty text item. `clear` removes all items:

```bash
apple clipboard clear --dry-run --json
apple clipboard clear --allow-persistent-action --json
```

Save a complete typed snapshot, then preview or restore it:

```bash
apple clipboard items read --limit 500 --json > clipboard.json
apple clipboard items write --input clipboard.json --dry-run --json
apple clipboard items write --input clipboard.json --allow-persistent-action --json
```

The input accepts the complete read envelope or a plain payload:

```json
{
  "items": [
    {
      "representations": [
        {"type": "public.utf8-plain-text", "dataBase64": "aGVsbG8="}
      ]
    }
  ]
}
```

Input item and representation order is preserved. Read ordinals are metadata.
Every representation needs a unique UTI type and valid base64 data. Truncated,
filtered and unavailable snapshots are rejected. Empty item arrays use `clear`.
Input must be a regular JSON file; symlinks are rejected. There are at most
500 items and 256 representations per item. Preview output includes counts
and hashes, not clipboard content.

File-promise snapshots return `unsupported_operation` on replacement, including
in previews. Their metadata depends on a running provider that creates files
when a transfer is accepted. Reading the raw data does not receive those files.

Use `--if-change-count` with the counter from `types` or `items read` to refuse
a stale replacement:

```bash
apple clipboard items write --input clipboard.json \
  --if-change-count 42 --allow-persistent-action --json
```

Replace `42` with the observed counter. The precondition does not reserve the
clipboard or make the operation atomic. A preview does not claim ownership.

Successful writes return `changed` and the verified `changeCount`. Identical
complete requests and empty clears skip writing. With `--current-host-only`,
each write renews ownership to apply the restriction even for identical data.
The contents option cannot be recovered from a raw snapshot. AppKit may generate
additional plain-text formats for RTF. If a write cannot be verified, its
error may report `mutation_may_have_occurred`; reread the current clipboard
before deciding whether to retry. Referenced file URLs preserve their URL
data; consumers still need access to those files.

The capability boundary lives in the
[Clipboard Capability List](../../Architecture/Clipboard/CapabilityList.md).
