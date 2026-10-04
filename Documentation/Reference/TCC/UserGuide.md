# TCC User Guide

Use `apple tcc --help` and subcommand help as the first reference.

Common diagnostics:

```bash
apple tcc services list --json
apple tcc doctor --for-target reminders --json
apple tcc access preflight Reminders com.example.App --json
```

Prompt and reset workflows use explicit risk flags:

```bash
apple tcc access request ScreenCapture --allow-tcc-prompt --json
apple tcc reset Reminders com.example.App --allow-tcc-reset --json
```

The detailed capability boundary lives in
`../../Architecture/TCC/CapabilityList.md`.

Private framework write results report `attempted: true` and
`verification: "unverified"` when the native call returns. `changed` is omitted
until the permission effect can be independently confirmed. Inspect the
permission state for the same app identity after a framework operation.
