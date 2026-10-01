# GitHub Collaboration Files

This directory indexes GitHub-facing collaboration and governance files for
`apple-cli`.

## Belongs Here

- pull request templates
- issue templates
- issue-template configuration
- GitHub Actions workflows
- other GitHub-specific collaboration configuration

## Does Not Belong Here

- current docs architecture truth
- design proposals
- decision records and migrations
- long-form contributor guidance better kept in root governance files

## Related Files

- `../CONTRIBUTING.md`: repo-wide contributor guidance
- `../SECURITY.md`: private vulnerability reporting guidance
- `workflows/ci.yml`: build, test and archive acceptance for main/PR changes
- `workflows/release.yml`: version-tag build, acceptance and GitHub Release publication
- `scripts/publish-release`: same-artifact publication and interrupted-upload recovery
- `actionlint.yaml`: additional supported runner label for workflow lint
- `../Documentation/README.md`: documentation reading index
- `../Documentation/Architecture/README.md`: current architecture index
