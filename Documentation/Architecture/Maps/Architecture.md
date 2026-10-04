# Maps Architecture

`maps` owns place search and detail lookup, saved favorite reads, collection
reads and changes, collection membership, route and ETA requests, directions link
previews, and Maps open actions under `apple maps`.

## Capability Maturity

Current level: `L1 Private Framework Increment`

Rationale: MapsSync provides verified native favorite, collection and member
reads, collection creation/update/deletion and links between collections and
existing saved members. Public mechanisms provide place and routing services,
reverse geocoding and validated Maps URL actions. New saved-place creation has
an implemented command path awaiting native end-to-end validation. Favorite
changes and history remain incomplete; private mechanisms do not own
most Maps capabilities.

## Source Authority

The typed MapsCLI command tree owns selectors, limits, transport modes, result
projection and external-action policy. Native service responses own place
details, route metrics, geometry, instructions and ETA. The current user's native
Maps store owns saved identities, names, visibility, positions, dates and
collection membership.

## Implementation Mechanisms

`MKLocalSearch` searches addresses and points of interest. An explicit region
biases search; it is not a radius filter. Native place identifiers are exposed
when the service supplies them on macOS 15 or newer; `MKMapItemRequest` reads
those identifiers. Coordinate snapshots have derived IDs and cannot be fetched
by ID. Coordinate lookup uses `CLGeocoder` reverse geocoding.

`MKDirections` calculates driving, walking and cycling routes, or ETA for those
modes and transit. Both endpoints must be explicit. Query endpoints must
resolve to exactly one place; ambiguous results require the caller to select
coordinates. The returned overall mode must match the requested mode. Native
departure and arrival times are mutually exclusive.

MapKit requests use a monotonic deadline and cancel on timeout. Synchronous commands
keep the main run loop available for native callbacks. Search and detail reads
have a 10-second deadline; routing shares a 25-second deadline across endpoint
resolution and the route or ETA request. Missing callbacks and service failures
remain errors.

Saved reads use the native MapsSync default store and typed favorite, collection
or collection-item request.
Query options bound the native fetch to the CLI limit plus one, allowing an
accurate `hasMore` flag without a total-count claim. The default limit is 20;
valid limits are 1...100. `--offset` accepts 0...1,000,000. Lists sort by native
position and UUID; `nextOffset` is present when another batch exists. These are
live store reads, so concurrent changes can affect separate pages. Results keep
hidden favorite entries and optional fields.

Favorites, collections and collection items use `maps-favorite:`,
`maps-collection:` and `maps-collection-item:` UUID namespaces, distinct from
service place IDs. Favorite and collection reads select the typed native UUID;
missing or duplicate identities remain errors. Member queries first require the
exact parent collection, then filter its native relationship. An absent parent
does not become a successful empty member list.

Collection records preserve the native reported place count independently of the
bounded member batch. Place members expose available names, address, coordinates,
category and note. Transit members retain a lossless string line identifier.
Unknown member classes are unsupported, rather than discarded.

Collection changes use the same default-store owner. Creation accepts an optional
collection UUID and otherwise generates one before execution. A matching existing
UUID and requested fields return `changed: false`; different content at that UUID
is refused. Positions are nonnegative native indices; creation appends after the
last native position by default. Updates change only supplied title, description
or position fields. The built-in Favorites guide's metadata and deletion remain
owned by Maps; member links can still be changed.

Update, delete and membership commands resolve exact UUIDs and recheck the selected
records before writing. Relationship snapshots use typed native store queries,
with a maximum of 10,000 results per relationship; larger scopes are refused.
Changes commit through native save/delete callbacks and then verify fresh store
reads. Metadata updates preserve cover data and membership. Member add/remove
operates on an existing `maps-collection-item:` identity, preserving its fields,
cover data and other collection links. Removing a link does not delete the item.
Deleting a collection preserves members still belonging to another collection;
Maps owns the lifetime of members with no remaining collection.

Mutation commands support `--dry-run` without invoking native save/delete.
Unchanged updates and repeated links return `changed: false` without saving.
Write callbacks and verification share a 20-second deadline. A write whose outcome
cannot be confirmed returns an error with `mutation_outcome: unverified`; callers
must read the selected identity before retrying.

Saved-place access uses runtime class and ABI checks, including the complete
extended encoding of the native fetch callback. Unsupported interfaces fail with
`backend_unavailable`. Store creation and fetching share a 10-second callback
deadline. MapsSync exposes no request cancellation here; late callbacks are
discarded. Read commands do not invoke native save, delete, reset or edit methods.

`directions preview` constructs a URL without contacting a service. `open`
dispatches a validated Maps URL through NSWorkspace after its external-action
gate. Native reads use explicit input and do not request the device's current
location. Network and regional service availability affect results.

## Validation

`collections places create` accepts a native service place ID or explicit
coordinates, an optional recoverable member UUID, custom name and note. Its
backend uses MapsSync's saved-place storage conversion and checks native fields,
storage and relationships after saving. Command input and dry-run behavior have
deterministic coverage; native end-to-end validation of this command remains
pending. Mechanism prototypes do not establish command-level persistence or
supported OS coverage.

Command tests cover input, projection, callback delivery, timeout cancellation,
mode fidelity, saved identities, mutation inputs, dry-run separation and
external-action gates. Native network and saved-store workflows are checked
separately from deterministic package tests. Controlled collection workflows
verify cover preservation, shared member links, repeated operations and deletion,
followed by independent cleanup and unchanged existing records. Saved-store access
is verified on the current development OS; full Maps view refresh and another OS
remain unverified. Detailed command status lives in `CapabilityList.md`.
