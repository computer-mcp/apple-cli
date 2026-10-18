# Contacts User Guide

Use `apple contacts --help` and subcommand help as the first reference.

Common reads:

```bash
apple contacts search --query "Ada" --json
apple contacts read --id CONTACT_ID --json
apple contacts duplicates --field email --json
apple contacts groups list --json
```

Import/export and contact mutations use the DryRun safety flow:

```bash
apple contacts export --ids CONTACT_ID --output contacts.vcf --dry-run --json
apple contacts create --given-name Ada --family-name Lovelace --dry-run --json
```

The detailed capability boundary lives in
`../../Architecture/Contacts/CapabilityList.md`.
