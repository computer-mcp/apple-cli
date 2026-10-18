# Maps Developer Guide

Use package-local tests for Maps changes:

```bash
swift test --filter Maps
```

Keep URL opening validation target-local; execution requires `--allow-external-dispatch`.

MapKit callbacks arrive on the main queue. Keep the synchronous command's main
run loop runnable and cancel the native request when its deadline expires.
The synchronous backend is called from the CLI's synchronous entrypoint or a
worker with the main queue available. It must not block an active MainActor job.
Search uses an optional region bias and preserves native result ordering.
Report the returned batch count separately from the CLI cap.

Route endpoint queries must have exactly one candidate. Keep requested and
returned transport modes consistent; transit supports ETA only. MapKit route
distances use meters and durations use seconds. Project native steps and
polyline coordinates with counts and explicit truncation flags.

Native place ID lookup is guarded at macOS 15; modern location/address
projection is guarded at macOS 26. Earlier runtimes use placemark projection.
These guards do not replace validation on the intended OS. Package tests use
native objects and controlled callbacks without issuing network requests;
current-host network verification is a separate check. `doctor` checks local
readiness and does not verify regional service connectivity.

Saved reads belong to `MapsSyncSavedPlacesBackend`. Use the native default-store
factory and the designated query-options initializer. Bound native fetches to
`limit + 1`, preserve native UUIDs and optional values, and derive `hasMore` from
that returned batch. Sort by position and UUID and validate the native range's
offset/limit values, rather than object identity. Hidden favorite records remain
part of the projection. Read selectors use UUID predicates; member reads validate
the exact parent and its relationship. Missing parents and empty collections have
distinct outcomes.
Do not replace unreadable fields with empty strings or zero coordinates.

MapsSync's fetch method uses a Swift extended Objective-C encoding, which the
runtime argument-count parser splits incorrectly. Validate the complete expected
encoding before making that call. Guard other constructors and getters by their
ABI. Store and fetch callbacks share a deadline; late callbacks are closed out,
and no native cancellation method is available on this request. Deterministic
command tests use a configured reader; native store identity and fields require
a separate real CLI/MCP read.

Collection writes also belong to `MapsSyncSavedPlacesBackend`. Validate mutation
inputs and the native constructor/setter/save/delete ABIs before changing objects.
Creation assigns the requested UUID and verifies it before save. Repeated creation
with matching requested fields, unchanged metadata and existing desired links
return without saving. The built-in Favorites guide's metadata and deletion are
protected independently of member links.

Recheck exact selected records before write. Compare text by UTF-8 bytes so Swift's
canonical Unicode equality cannot hide a changed native value. Take complete
relationship snapshots through typed store queries, rather than cached wrapper
collections. Fetch at most 10,001 results and refuse the operation if the extra
result indicates a scope larger than 10,000. Raw cover data, member fields and
other parents must survive the intended change. Save the parent and item after
the parent's addPlace/removePlace operation; collection deletion invokes native
delete on the selected collection only.

Store creation, snapshots, save/delete callback and fresh verification share a
20-second write deadline. Verify changed fields and relationships after save;
verify parent absence and shared members' remaining links after delete. Native
callbacks have no cancellation method here. Post-submission failures retain
`mutation_outcome: unverified`; a timeout does not prove that a write was undone.

New place creation uses the MapsSync-owned `MSCollectionPlaceItem.strippedMapItemWith:`
conversion of a native GEO item. Service place IDs remain opaque and distinct
from saved UUIDs and numeric native place identifiers. Explicit coordinates are
saved as coordinate points. The creation path shares a 25-second deadline across
source lookup, store operations and verification, checking full native storage
semantics and unknown-field bytes alongside fields, cover and relationships.
Input and dry-run regression tests cover the command; its native end-to-end
workflow remains unverified.

Controlled current-host workflows verify nonempty place membership, collection
creation/update/deletion, shared member links and cover preservation. They compare
existing records, independently read native persistence and clean up exact owned
UUIDs. Full Maps view refresh, transit-member workflows and another OS remain
unverified.
