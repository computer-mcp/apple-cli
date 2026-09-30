# Security

apple-cli operates on local app data and exposes target-specific mutation,
artifact and external-action controls. Report vulnerabilities in permission
handling, sensitive output, identity selection, risk gates or MCP transport
boundaries privately.

Use [GitHub private vulnerability reporting](https://github.com/computer-mcp/apple-cli/security/advisories/new)
when it is enabled. Otherwise use the contact method published on the
[maintainer's profile](https://github.com/showxu). Public issues should contain
only a request for a private reporting channel, without vulnerability details.

Include the CLI version, macOS version and architecture, affected command,
expected boundary, and a minimal reproduction using synthetic data. Remove
credentials, passphrases, personal app content and local database copies.

The current preview is the supported reporting target. A report does not
authorize access to another person's data or bypassing their system permissions.
