# Photos Oracle Fixtures

This directory holds normalized JSON fixtures for Photos oracle fixture tests.

Oracle JSON is not raw osxphotos stdout. It is a stable comparison format for
the local CLI contract. A comparison report contains:

- `fixture`: copied `.photoslibrary` package name;
- `apple_count` and `osxphotos_count`;
- `compared_row_count`;
- `diff_count`;
- `diffs`, capped to representative normalized differences;
- `apple_command` and `osxphotos_command` for reproducibility.

Large upstream `.photoslibrary` packages are not checked into this repository.
Use the Photos oracle Swift Testing workflow with a locked osxphotos fixture root to
generate gated comparison reports, optionally writing refreshed oracle output to
a temporary directory for review. The runner prints aggregate compared, skipped,
row, and diff counts.

As of the 2026-05-24 Photos query pass, the gated comparison covers database
version metadata, metadata aggregate command counts, baseline media fields,
normalized traits, ordinary album membership, folder paths, edited/external-edit
state, original file size, legacy/modern keyword joins, modern long
descriptions, modern and legacy person/face joins, default oldest-first query
ordering, and stable query semantic cases for
boolean/media/trait membership. It also runs selected black-box `apple photos`
query cases, currently including regex title/filename queries,
duplicate/not-duplicate detection, date-created/date-added/time-of-day filters,
burst trait filters, and repeated keyword/person/title/description selector
comparisons plus repeated UUID and UUID-from-file selector comparisons against
osxphotos. GPS location/no-location selectors are also compared against
osxphotos `--location` / `--no-location`, original UTI selectors are compared
against osxphotos `--uti`, and reverse-geocoded place/no-place selectors are
compared against osxphotos `--place` / `--no-place`. Shared comments/likes are
compared as normalized records and through osxphotos `--has-comment` /
`--no-comment` / `--has-likes` / `--no-likes`. Missing/not-missing selectors
are compared against osxphotos `--missing` / `--not-missing`. Shared and iCloud
cloud-asset selectors are compared against osxphotos `--shared` /
`--not-shared` and `--cloudasset` / `--not-cloudasset`, and the broader
cloud/shared provenance flags `--incloud`, `--syndicated`, `--saved-to-library`,
`--shared-moment`, and `--shared-library`. AI label selectors are compared
against osxphotos `--label` using the Photos `database/search/psi.sqlite`
sidecar.
