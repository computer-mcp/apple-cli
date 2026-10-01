# Intelligence User Guide

## Scope

This manual describes the current supported local workflow for
`apple intelligence`. The target is the Apple Intelligence product surface; its
current production line is a Swift-owned local-cache enablement path. The
current backend operates on local macOS eligibility cache and `eligibilityd`
state. It does not guarantee that Apple services, account eligibility, regional
availability, model downloads, or the System Settings UI will ultimately expose
Apple Intelligence.

The current mainline uses Swift-owned plist/cache operations only.

## Version And Mechanism Boundaries

`apple intelligence` ships one production line today: a Swift-owned local-cache
path. The current backend edits known eligibility plist/cache files and can ask
`eligibilityd` to recompute. This is not a claim that every Apple Intelligence
version or implementation mechanism uses the same route.

| Capability | Local mechanism | Version boundary |
| --- | --- | --- |
| `--patch-scope answer` | Sets known `os_eligibility_answer_t` cache values to the eligible answer. | Modern local-cache path. This is the smallest patch and is useful when the target cache files exist. |
| `--patch-scope comprehensive` | Applies answer values plus known GREYMATTER/CALCIUM status input values. | Modern local-cache path and the default enablement scope. |
| `--eligibility-country CC` | Rewrites uppercase alpha-2 country-code strings in `countryCodeCache.plist`. | Optional country-cache path for releases where `countryd` contributes to location-gated behavior. |
| `recompute` | Performs a bounded `lldb` attach to `eligibilityd` and recomputes. | Optional refresh path when plist/cache values are present but the daemon has not picked them up. |
| `service install` | Installs this CLI's LaunchDaemon to run the Swift CLI recompute command. | Optional persistence for recompute only; not part of default enablement. |
| macOS beta-only region spoof or feature-flag experiments | Not implemented in the production CLI. | Out of current scope until there is a source-owned, testable design. |

Feature version landmarks and product boundaries:

- Apple Intelligence eligibility is a macOS 15.1+ feature family. This CLI can
  write the GREYMATTER and FOUNDATION_MODELS local cache values, but the cache
  patch is not the same thing as Apple service availability.
- ChatGPT integration is a macOS 15.2+ feature family. When local country cache
  state contributes to that behavior, use `--eligibility-country`; account,
  network, language, and server-side gates remain outside this CLI.
- macOS 26.5 beta 4+ and macOS 27 beta behavior is not claimed as supported by
  this product. Beta-only region spoofing, feature flags, kernel-extension
  experiments, or other mechanisms require separate source-owned design and
  tests before promotion.

`support` and `doctor` report warnings for unproven OS boundaries such as
macOS 26.5+ and releases newer than 26.x.

`verify` checks local plist/cache state only. A successful `verify` result does
not prove Apple service availability, model downloads, account eligibility, or
that System Settings has exposed the Apple Intelligence UI.

## Before You Start

Use an Apple silicon Mac on a modern macOS release. For the best chance of
Apple Intelligence working after local eligibility cache changes, configure
Apple ID region, system region, system language, Siri language, and network
environment to values Apple supports for the desired feature. This CLI does not
change those account, language, Siri, or network settings.

System cache writes require root. On the real system root (`--root /`), the CLI
also refuses writes while SIP is enabled.

Check SIP from normal macOS:

```bash
csrutil status
```

If SIP is enabled and you intend to write system eligibility cache files, reboot
into Recovery, open Terminal, and run:

```bash
csrutil disable
```

Reboot back into macOS before continuing.

## Recommended Flow

From the package root, build or use an existing local binary:

```bash
swift build
```

Run read-only diagnostics first:

```bash
.build/debug/apple intelligence doctor --json
.build/debug/apple intelligence verify --json
```

Apply the modern comprehensive patch:

```bash
sudo .build/debug/apple intelligence enable \
  --patch-scope comprehensive \
  --allow-system-cache-write \
  --json
```

Reboot, then verify the local cache state:

```bash
.build/debug/apple intelligence verify --json
```

Open System Settings and inspect Apple Intelligence & Siri. If the local cache
state matches but the UI has not picked it up, reboot once more before using
debug attach.

## Optional Country Cache Rewrite

Changing the eligibility country cache is optional. Use it only when you need
to force the cached eligibility country, usually to `US`, for location-gated
features such as ChatGPT integration, Apple News, or international Maps.
The command rewrites uppercase two-letter country-code strings in
`countryCodeCache.plist`; `countryd` remains an internal touched subsystem, not
a user-facing option.

If you use iPhone Mirroring, pair the iPhone with the Mac before changing the
eligibility country.

```bash
sudo .build/debug/apple intelligence enable \
  --patch-scope comprehensive \
  --eligibility-country US \
  --allow-system-cache-write \
  --json
```

Run `verify` again after this command.

## Optional Recompute

Use `recompute` only when plist/cache values look correct but `eligibilityd`
has not refreshed. This attaches a debugger to `eligibilityd`, so it requires
an explicit risk flag:

```bash
sudo .build/debug/apple intelligence recompute \
  --allow-debug-attach \
  --json
```

Prefer rebooting before using `recompute`.

## Optional Persistent Service

The service label is `io.github.computer-mcp.apple-cli.intelligence.recompute`.
Its plist lives under `/Library/LaunchDaemons` within the selected `--root`.

The LaunchDaemon service is not part of the default path. Install it only if
you need persistent recompute behavior after boot or daemon reload:

```bash
sudo .build/debug/apple intelligence service install \
  --allow-debug-attach \
  --allow-persistent-service \
  --json
```

Uninstall it with:

```bash
sudo .build/debug/apple intelligence service uninstall \
  --allow-persistent-service \
  --json
```

## Recovery And Cleanup

Use rollback for changes made by this CLI:

```bash
sudo .build/debug/apple intelligence rollback \
  --state latest \
  --allow-system-cache-write \
  --json
```

`reset-cache` deletes only known eligibility cache files so the system can
recreate them. Do not use it as the first enable step:

```bash
sudo .build/debug/apple intelligence reset-cache \
  --allow-cache-reset \
  --json
```

After the desired behavior is verified, you may re-enable SIP from Recovery:

```bash
csrutil enable
```

Then reboot back into macOS.

## Troubleshooting

- `unsafe_mutation_refused` with `euid`: rerun the command with `sudo`.
- `unsafe_mutation_refused` mentioning SIP: disable SIP in Recovery before
  writing system eligibility cache files.
- `verify` reports mismatched values after enable: inspect the JSON action
  results and confirm the command wrote the expected root.
- `verify` matches but the UI does not show Apple Intelligence: reboot, confirm
  supported account/region/language/network settings, then consider
  `recompute`.
- iPhone Mirroring pairing fails after changing country: rollback or restore
  the country cache, pair the iPhone, then reapply the country change.
