# Maps Capability List

## Source Authority

MapsCLI owns the command contract; native Maps services supply place, route and
ETA data, and MapsSync supplies saved favorites, collections and membership from
the current Maps store.

## Supported Capabilities

| Capability | CLI surface | Implementation mechanism | Gate / verifier / gap |
| --- | --- | --- | --- |
| Place search | `places search` | MKLocalSearch address/POI search, optional region bias | Read-only; limit 1...50; reports service result count and truncation. |
| Place detail | `places read` | Coordinate reverse geocoding or MKMapItemRequest | Native `maps-item:` ID lookup requires macOS 15+; snapshot IDs cannot be fetched. Available details include address, phone, website, category and time zone. |
| Saved favorite reads | `favorites list/read` | MapsSync default store and native favorite request | Native UUID selection, hidden entries, positions and available names/address/coordinates/dates. List limit 1...100, default 20; offset, `hasMore` and `nextOffset`. Runtime ABI compatibility is required. |
| Saved collections | `collections list/read` | MapsSync native collection request | UUID selection, title/description/image URL, position, dates and native reported place count; bounded live pagination. |
| Collection membership | `collections places list` | Parent UUID lookup and native collection relationship predicate | Requires an existing exact parent; bounded pagination. Place details/notes and lossless transit line IDs; unknown member types fail. The returned batch does not replace the native reported count. |
| Collection creation | `collections create` | MapsSync native collection constructor and save callback | Required title; optional description, UUID and nonnegative position. Matching requested fields at the same UUID return `changed: false`; different content is refused. Fresh read verifies persistence. Supports `--dry-run`. |
| Collection metadata | `collections update` | Native title/description/position setters and save callback | Exact UUID and current record recheck; only supplied fields change. Cover and members remain intact. `--clear-description` removes a description. Supports `--dry-run`. |
| Collection deletion | `collections delete` | Native collection delete callback | Exact UUID and current record recheck; verifies absence and preserves shared members' other collection links. Supports `--dry-run`. |
| Existing member links | `collections places add/remove` | Native collection addPlace/removePlace and save callback | Requires collection and existing `maps-collection-item:` UUIDs. Verifies both relationships, member fields and cover preservation. Repeated operations do not save. Supports `--dry-run`. |
| Route calculation | `directions calculate` | MKDirections routes, instructions, metrics and geometry | Requests driving/walking/cycling; rejects a response reporting another mode. Explicit endpoints; queries must resolve uniquely. Alternative routes are optional; output cap 1...10, default 3. |
| Travel estimate | `directions eta` | MKDirections ETA | Driving/walking/cycling/transit; distance, duration and native departure/arrival estimates. |
| Link planning | `directions preview` | Coordinate/query-aware URL construction | No network request or application dispatch. Driving/walking/transit link modes. |
| Open action | `open` | Validated Maps URL external action | Supports `--dry-run`; execution requires `--allow-external-dispatch`. |

## Capabilities Awaiting Native Validation

`collections places create` implements new place saving by `--place maps-item:`
or explicit `--latitude` and `--longitude`. `--id` selects the collection;
`--item` optionally supplies a recoverable member UUID. Custom names and notes
are literal text, and the command supports `--dry-run`. Input and dry-run tests
do not establish native end-to-end persistence; that validation is pending.

## Boundaries

- Transit route steps and geometry are unavailable through the public routing
  API; transit ETA is supported.
- Transit-member creation, favorite changes, collection cover
  editing, app sort modes, visited places, curated guides, offline maps and sharing
  state are not implemented. A native position index is not an app sort mode.
- Maps owns metadata and deletion of its built-in Favorites guide. Collection
  member links remain available. Deleting a custom collection preserves shared
  members; no lifetime guarantee is made for members with no remaining collection.
- Writes recheck selected records and require complete native relationship
  snapshots of at most 10,000 results each. Unverified write outcomes remain
  errors; the caller must read the selected identity before retrying.
- Favorite reads include hidden native entries. A missing name, address or
  coordinate remains absent; it is not reconstructed through a place search.
- Saved identifiers cannot be used as service place identifiers. `hasMore`
  describes a bounded saved batch; it is not a total count. Pages use position and
  UUID ordering, and reflect the live store rather than a retained snapshot.
- Nonempty place membership, collection lifecycle and shared member changes have
  current-host native verification. Full Maps view refresh and another OS remain
  unverified. Transit member projection has guarded native interfaces; its full
  current-host workflow remains unverified.
- Each route includes at most 2,000 steps and 20,000 polyline points, with native
  counts and truncation flags. A truncated polyline is a prefix, not a complete
  route geometry.
- Search service counts describe the returned batch, not the total number of
  places in an area. Search does not paginate the service.
- Network reads do not open Maps or request current-location authorization.
  External opens require the explicit dispatch gate.
