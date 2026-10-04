# Maps User Guide

Use `apple maps --help` and subcommand help as the first reference.

Search addresses or points of interest. An explicit region biases results;
it does not impose a distance filter. Search returns at most 10 places by
default, with `--limit` from 1 to 50:

```bash
apple maps places search --query "coffee" --kind poi --json
apple maps places search --query "三里屯" --kind all \
  --region-latitude 39.9338 --region-longitude 116.4552 \
  --region-span-meters 10000 --limit 5 --json
apple maps places read --latitude 39.9338 --longitude 116.4552 --json
```

On macOS 15 or newer, a result may include a native `maps-item:` ID. Use that
returned ID for `places read --id`. A derived `maps-place:` coordinate snapshot
ID cannot be looked up. Details depend on the service and can include address,
phone, website, category and time zone. Reads require network access and regional
coverage; they do not request your current location.

Read favorites saved in the current user's Maps store:

```bash
apple maps favorites list --limit 20 --json
```

The default limit is 20; `--limit` accepts 1...100. Results include native
`maps-favorite:` IDs, visibility (`hidden`), positions and available names,
addresses, coordinates and dates. Hidden native entries are included and may
have no place details. Missing details remain absent. Results keep native batch
order by position and UUID. When `hasMore` is true, pass the returned `nextOffset`
as `--offset` to retrieve another batch. Offset accepts 0...1,000,000. Separate
pages reflect current data; concurrent changes can affect their contents.
Favorite IDs are distinct from `maps-item:` place IDs.

Read one favorite using the ID returned by its list:

```bash
apple maps favorites read --id 'maps-favorite:<returned-uuid>' --json
```

Replace `<returned-uuid>` with the corresponding list's UUID. Read your saved
collections and the places belonging to one collection:

```bash
apple maps collections list --limit 20 --offset 0 --json
apple maps collections read --id 'maps-collection:<returned-uuid>' --json
apple maps collections places list --id 'maps-collection:<returned-uuid>' \
  --limit 20 --offset 0 --json
```

Collections include available title, description, image URL and dates, plus
position and `reportedPlaceCount` from Maps. Member results include the selected
collection and native member IDs. Place members include available names, address,
coordinates, category and note; transit members have a string line ID. Missing
details remain absent. A missing parent collection returns `not_found`.
`reportedPlaceCount` is independent of the returned member batch. Both lists use
the same limit/offset rules. These read commands do not edit saved data.

Create a custom collection, previewing the request first:

```bash
apple maps collections create --title "Weekend" --description "Places to visit" \
  --dry-run --json
apple maps collections create --title "Weekend" --description "Places to visit" --json
```

Use the returned `collection.id` in later commands. To reuse the preview's
generated identity, pass `normalizedArguments.id` as `--id` when creating. A retry with the same
UUID and requested fields returns `changed: false`; different content at that
UUID is refused. Each creation without `--id` generates a new UUID. `--position`
accepts a nonnegative native index; creation appends by default.

Update only the fields you supply, or delete the selected custom collection:

```bash
apple maps collections update --id 'maps-collection:<returned-uuid>' \
  --title "Weekend plans" --position 2 --json
apple maps collections update --id 'maps-collection:<returned-uuid>' \
  --clear-description --json
apple maps collections delete --id 'maps-collection:<returned-uuid>' --dry-run --json
```

`--description` and `--clear-description` cannot be combined. Metadata updates
preserve the collection's cover and members. The built-in Favorites guide's
metadata and deletion are managed by Maps.

Link an existing saved member, taking its `maps-collection-item:` ID from a
collection's member list:

```bash
apple maps collections places add --id 'maps-collection:<collection-uuid>' \
  --item 'maps-collection-item:<member-uuid>' --json
apple maps collections places remove --id 'maps-collection:<collection-uuid>' \
  --item 'maps-collection-item:<member-uuid>' --json
```

These commands change a link; they do not create a place from a search result or
favorite ID. Removing a link preserves the saved member and its other collection
links. Deleting a collection preserves members shared with another collection;
Maps determines what happens to members with no remaining collection.

New place saving is exposed by `collections places create --help`, using either
a native `--place maps-item:` ID or explicit latitude and longitude, with optional
custom name, note and recoverable `--item` UUID. Native end-to-end validation of
this command is pending; it is not part of the verified saved-place workflows.

Collection mutation commands accept `--dry-run`; update, delete and member previews
read the selected records without saving. Remove `--dry-run` to execute an explicit
request. Unchanged updates and repeated add/remove requests return `changed: false`.
Writes refuse stale selected records or relationship scopes exceeding 10,000
results. If an error reports `mutation_outcome: unverified`, read the selected
collection and member list before retrying: the native write may have occurred.

Saved-store access depends on compatible MapsSync interfaces and the current
user's Maps state. An unavailable interface or failed native read returns
`backend_unavailable`; it does not return an empty successful list.

Calculate a route between explicit coordinates, using coordinates returned by
search for the desired places:

```bash
apple maps directions calculate \
  --from-latitude 39.9338 --from-longitude 116.4552 \
  --to-latitude 39.9419 --to-longitude 116.4552 \
  --mode walking --json
apple maps directions eta \
  --from-latitude 39.9338 --from-longitude 116.4552 \
  --to-latitude 39.9419 --to-longitude 116.4552 \
  --mode transit --json
```

`calculate` accepts driving, walking and cycling requests where the service
supports them. A response reporting another mode is rejected with
`backend_unavailable`; it is not labelled as the requested mode. It returns distances in
meters, travel times in seconds, route steps, advisory notices, toll/highway
indicators and latitude/longitude geometry. `--alternatives` asks for alternate
routes; `--limit` caps returned routes from 1 to 10, default 3. Steps and geometry
carry counts and truncation flags; a truncated geometry does not represent the
whole route. `eta` also supports transit and reports native departure and arrival
estimates. These are estimates, not live navigation or transit timetables.

Both commands accept query endpoints through `--from` and `--to`, but require
each query to resolve uniquely. If a query is ambiguous, search first and choose
explicit coordinates. `--departure` or `--arrival` accepts ISO 8601 with a time
zone; supply only one. Service availability and mode coverage vary by region.

Create a directions link without making a network request or opening Maps:

```bash
apple maps directions preview --from "Cupertino" --to "San Francisco" --json
```

Opening Maps uses a `maps:` URL from a place result or directions preview:

```bash
apple maps open --url 'maps:?q=Cupertino' --dry-run --json
apple maps open --url 'maps:?q=Cupertino' --allow-external-dispatch --json
```

`submitted` reports the application's dispatch result. The detailed capability
boundary lives in [Maps Capability List](../../Architecture/Maps/CapabilityList.md).
