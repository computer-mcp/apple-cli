# Reminders

This directory owns current target-specific architecture truth for
`apple reminders`. Cross-target architecture documents summarize and link here;
they should not carry detailed Reminders capability design.

- [Architecture](Architecture.md): current Reminders target architecture,
  implementation boundaries, ReminderKit ownership, and safety policy.
- [Capability List](CapabilityList.md): official Reminders capability baseline
  plus current CLI support, command, implementation mechanism, verifier, gate,
  and gap status.

Supporting usage and maintenance references live under
`Documentation/Reference/Reminders/`:

- [Reminders User Guide](../../Reference/Reminders/UserGuide.md): ordinary
  `apple reminders` usage.
- [Reminders Developer Guide](../../Reference/Reminders/DeveloperGuide.md):
  package validation, doctor checks, fixture-backed Swift Testing validation, and
  failure triage.

The command entry point is:

```bash
apple reminders --help
```
